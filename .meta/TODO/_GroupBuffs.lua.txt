-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local UI = LUIE.UI
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local eventManager = GetEventManager()

-- Default group buff settings
SpellCastBuffs.DefaultGroupSettings =
{
    GroupBuffIconSize = 24,
    GroupBuffIconOffset = 5,
    GroupBuffStartX = 75,
    GroupBuffStartY = 0,
    SmallGroupBuffStartX = 75,
    SmallGroupBuffStartY = 0,
    LargeGroupBuffStartX = 75,
    LargeGroupBuffStartY = 0,
    GroupBuffTimerSize = 16,
    GroupBuffTimerColor = { 1, 1, 1, 1 },
}

-- Default tracked buffs
SpellCastBuffs.DefaultGroupBuffs =
{
    -- Stuff
    [61771] = true,  -- Power Aura
    [93109] = true,  -- Slayer
    [109966] = true, -- Courage
    [163401] = true, -- Spaulder
    [172055] = true, -- Pill
    [151032] = true, -- Encratis

    -- Special
    [61665] = true,  -- Inner Wrath
    [61694] = true,  -- Reckless
    [61745] = true,  -- Berserk
    [147417] = true, -- Combat Prayer

    -- Jobs
    [61506] = true,  -- Ardent Flame
    [40079] = true,  -- Regeneration
    [217460] = true, -- Elemental Harmony
    [217608] = true, -- Spell Power
    [61693] = true,  -- Power of the Light
    [61747] = true,  -- Force Move

    -- Arena Sigils
    [112893] = true,
    [112903] = true,
    [112874] = true,
}

-- Bugged long duration buffs that need special handling
SpellCastBuffs.BuggedLongDuration =
{
    [147417] = true, -- Combat Prayer
}

-- Create a buff icon for a unit frame
---
--- @param parent Control|TopLevelWindow
--- @param lastIcon any
--- @param index any
--- @return table|TextureControl
local function CreateBuffIcon(parent, lastIcon, index)
    local defaults = SpellCastBuffs.DefaultGroupSettings
    local iconSize = SpellCastBuffs.SV.GroupBuffIconSize or defaults.GroupBuffIconSize
    local icon = UI:Texture(parent, { LEFT, LEFT }, { iconSize, iconSize }, nil, DL_OVERLAY, false)

    if lastIcon then
        icon:SetAnchor(LEFT, lastIcon, RIGHT, SpellCastBuffs.SV.GroupBuffIconOffset or defaults.GroupBuffIconOffset, 0)
    else
        -- Check group size to determine which position settings to use
        local groupSize = GetGroupSize()
        local startX, startY

        if groupSize <= 4 then
            -- Use small group settings
            startX = SpellCastBuffs.SV.SmallGroupBuffStartX or defaults.SmallGroupBuffStartX
            startY = SpellCastBuffs.SV.SmallGroupBuffStartY or defaults.SmallGroupBuffStartY
        else
            -- Use large group settings
            startX = SpellCastBuffs.SV.LargeGroupBuffStartX or defaults.LargeGroupBuffStartX
            startY = SpellCastBuffs.SV.LargeGroupBuffStartY or defaults.LargeGroupBuffStartY
        end

        icon:SetAnchor(LEFT, parent, LEFT, startX, startY)
    end

    -- Add timer label
    local timerSize = SpellCastBuffs.SV.GroupBuffTimerSize or defaults.GroupBuffTimerSize
    local label = UI:Label(icon, { CENTER, CENTER }, nil, { 0, 0 }, string_format("$(BOLD_FONT)|%d|soft-shadow-thick", timerSize), "", false)
    local r, g, b, a = unpack(SpellCastBuffs.SV.GroupBuffTimerColor or defaults.GroupBuffTimerColor)
    label:SetColor(r, g, b, a)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetDrawLevel(2)
    label:SetHidden(false)
    label:SetText("")

    icon.timerLabel = label
    icon.expirationTime = nil

    return icon
end

-- Get unit frame from our custom frames
--- @param unitTag string
--- @return TopLevelWindow|Control|nil
local function GetUnitFrame(unitTag)
    local customFrames = LUIE.UnitFrames.CustomFrames
    if customFrames[unitTag] then
        local control = customFrames[unitTag].control
        return control
    end
    return nil
end

-- Helper to reposition buff icons in a tight row
local function RepositionBuffIcons(unitFrame)
    local keys = {}
    for id in pairs(unitFrame.buffIconsById) do
        table_insert(keys, id)
    end
    table_sort(keys)

    -- Check group size to determine which position settings to use
    local defaults = SpellCastBuffs.DefaultGroupSettings
    local groupSize = GetGroupSize()
    local startX, startY

    if groupSize <= 4 then
        -- Use small group settings
        startX = SpellCastBuffs.SV.SmallGroupBuffStartX or defaults.SmallGroupBuffStartX
        startY = SpellCastBuffs.SV.SmallGroupBuffStartY or defaults.SmallGroupBuffStartY
    else
        -- Use large group settings
        startX = SpellCastBuffs.SV.LargeGroupBuffStartX or defaults.LargeGroupBuffStartX
        startY = SpellCastBuffs.SV.LargeGroupBuffStartY or defaults.LargeGroupBuffStartY
    end

    local lastIcon
    for _, id in ipairs(keys) do
        local bufficon = unitFrame.buffIconsById[id]
        if bufficon and not bufficon:IsHidden() then
            bufficon:ClearAnchors()
            if lastIcon then
                bufficon:SetAnchor(LEFT, lastIcon, RIGHT, SpellCastBuffs.SV.GroupBuffIconOffset or defaults.GroupBuffIconOffset, 0)
            else
                bufficon:SetAnchor(LEFT, unitFrame, LEFT, startX, startY)
            end
            lastIcon = bufficon
        end
    end
end

-- Handle effect changes for group buffs
--- @param eventId integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SpellCastBuffs.OnGroupEffectChanged(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    -- Check if we should track this effect
    local shouldTrack = false
    if effectType == BUFF_EFFECT_TYPE_BUFF and SpellCastBuffs.SV.GroupTrackedBuffs[abilityId] then
        shouldTrack = true
    end
    if not shouldTrack then return end

    local unitFrame = GetUnitFrame(unitTag)
    if not unitFrame then return end

    unitFrame.buffIconsById = unitFrame.buffIconsById or {}

    if changeType == EFFECT_RESULT_GAINED or changeType == EFFECT_RESULT_UPDATED then
        -- Skip if duration is 0 and not a bugged long duration buff
        if (not endTime or endTime == 0 or endTime == beginTime) and not SpellCastBuffs.BuggedLongDuration[abilityId] then
            return
        end

        local icon = unitFrame.buffIconsById[abilityId]
        if not icon then
            icon = CreateBuffIcon(unitFrame)
            unitFrame.buffIconsById[abilityId] = icon
        end

        icon:SetTexture(iconName)
        icon:SetHidden(false)

        -- Handle duration
        if SpellCastBuffs.BuggedLongDuration[abilityId] then
            if endTime and endTime > beginTime then
                icon.expirationTime = GetFrameTimeSeconds() + (endTime - beginTime)
            else
                icon.expirationTime = math.huge
            end
        else
            if endTime > 1000000 then endTime = endTime / 1000 end
            icon.expirationTime = GetFrameTimeSeconds() + (endTime - beginTime)
        end

        icon.timerLabel:SetHidden(false)

        -- Reposition icons
        RepositionBuffIcons(unitFrame)
    elseif changeType == EFFECT_RESULT_FADED then
        local icon = unitFrame.buffIconsById[abilityId]
        if icon then
            local now = GetFrameTimeSeconds()

            if abilityId == 93109 and icon.expirationTime and icon.expirationTime > now then
                return
            end
            if icon.expirationTime == math.huge or (icon.expirationTime and icon.expirationTime > now) then
                icon:SetHidden(true)
                icon.timerLabel:SetHidden(true)
                unitFrame.buffIconsById[abilityId] = nil
                -- Reposition icons after removal
                RepositionBuffIcons(unitFrame)
                return
            end
        end
    end
end

-- Update group buff timers
function SpellCastBuffs.UpdateGroupBuffs()
    local now = GetFrameTimeSeconds()

    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) then
            local unitFrame = GetUnitFrame(unitTag)
            if unitFrame and unitFrame.buffIconsById then
                local repositionNeeded = false
                for _, icon in pairs(unitFrame.buffIconsById) do
                    if not icon:IsHidden() and icon.expirationTime then
                        if icon.expirationTime == math.huge then
                            icon.timerLabel:SetText("∞")
                            icon.timerLabel:SetHidden(false)
                        else
                            local remaining = icon.expirationTime - now
                            if remaining <= 0 then
                                icon:SetHidden(true)
                                icon.timerLabel:SetHidden(true)
                                repositionNeeded = true
                            else
                                icon.timerLabel:SetText(string_format("%.0f", remaining))
                                icon.timerLabel:SetHidden(false)
                            end
                        end
                    end
                end
                if repositionNeeded then
                    RepositionBuffIcons(unitFrame)
                end
            end
        end
    end
end

-- Handle group size changes to update buff positions
local function OnGroupSizeChanged()
    -- Reposition all buff icons for each group member
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) then
            local unitFrame = GetUnitFrame(unitTag)
            if unitFrame and unitFrame.buffIconsById then
                RepositionBuffIcons(unitFrame)
            end
        end
    end
end

-- Initialize group buff tracking
function SpellCastBuffs.InitializeGroupBuffs(enabled)
    if not enabled then
        return
    end

    -- Initialize position settings from defaults
    local defaults = SpellCastBuffs.DefaultGroupSettings

    -- Initialize common settings
    SpellCastBuffs.SV.GroupBuffIconSize = SpellCastBuffs.SV.GroupBuffIconSize or defaults.GroupBuffIconSize
    SpellCastBuffs.SV.GroupBuffIconOffset = SpellCastBuffs.SV.GroupBuffIconOffset or defaults.GroupBuffIconOffset
    SpellCastBuffs.SV.GroupBuffTimerSize = SpellCastBuffs.SV.GroupBuffTimerSize or defaults.GroupBuffTimerSize
    SpellCastBuffs.SV.GroupBuffTimerColor = SpellCastBuffs.SV.GroupBuffTimerColor or defaults.GroupBuffTimerColor

    -- Initialize position settings
    SpellCastBuffs.SV.GroupBuffStartX = SpellCastBuffs.SV.GroupBuffStartX or defaults.GroupBuffStartX
    SpellCastBuffs.SV.GroupBuffStartY = SpellCastBuffs.SV.GroupBuffStartY or defaults.GroupBuffStartY

    -- Initialize small group position settings
    SpellCastBuffs.SV.SmallGroupBuffStartX = SpellCastBuffs.SV.SmallGroupBuffStartX or defaults.SmallGroupBuffStartX
    SpellCastBuffs.SV.SmallGroupBuffStartY = SpellCastBuffs.SV.SmallGroupBuffStartY or defaults.SmallGroupBuffStartY

    -- Initialize large group position settings
    SpellCastBuffs.SV.LargeGroupBuffStartX = SpellCastBuffs.SV.LargeGroupBuffStartX or defaults.LargeGroupBuffStartX
    SpellCastBuffs.SV.LargeGroupBuffStartY = SpellCastBuffs.SV.LargeGroupBuffStartY or defaults.LargeGroupBuffStartY

    -- Set defaults for any new buffs
    for buffId, _ in pairs(SpellCastBuffs.DefaultGroupBuffs) do
        if SpellCastBuffs.SV.GroupTrackedBuffs[buffId] == nil then
            SpellCastBuffs.SV.GroupTrackedBuffs[buffId] = true
        end
    end

    -- Register event handlers
    eventManager:RegisterForEvent("LuiExtendedSpellCastBuffsGroupBuffs", EVENT_EFFECT_CHANGED, SpellCastBuffs.OnGroupEffectChanged)
    eventManager:AddFilterForEvent("LuiExtendedSpellCastBuffsGroupBuffs", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    eventManager:RegisterForUpdate("LuiExtendedSpellCastBuffsGroupBuffsUpdate", 1000, SpellCastBuffs.UpdateGroupBuffs)

    -- Register for group size changes
    eventManager:RegisterForEvent("LuiExtendedSpellCastBuffsGroupSize", EVENT_GROUP_MEMBER_JOINED, OnGroupSizeChanged)
    eventManager:RegisterForEvent("LuiExtendedSpellCastBuffsGroupSize", EVENT_GROUP_MEMBER_LEFT, OnGroupSizeChanged)

    -- Force an initial update of all group members
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) then
            SpellCastBuffs.OnGroupEffectChanged(EVENT_EFFECT_CHANGED, EFFECT_RESULT_GAINED, 0, "", unitTag, 0, 0, 0, "", "", 0, 0, 0, "", 0, 0, 0)
        end
    end
end

-- Shut down group buff tracking
function SpellCastBuffs.ShutdownGroupBuffs()
    -- Unregister all event handlers
    eventManager:UnregisterForEvent("LuiExtendedSpellCastBuffsGroupBuffs", EVENT_EFFECT_CHANGED)
    eventManager:UnregisterForUpdate("LuiExtendedSpellCastBuffsGroupBuffsUpdate")
    eventManager:UnregisterForEvent("LuiExtendedSpellCastBuffsGroupSize", EVENT_GROUP_MEMBER_JOINED)
    eventManager:UnregisterForEvent("LuiExtendedSpellCastBuffsGroupSize", EVENT_GROUP_MEMBER_LEFT)

    -- Hide all existing buff icons for group members
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        if DoesUnitExist(unitTag) then
            local unitFrame = GetUnitFrame(unitTag)
            if unitFrame and unitFrame.buffIconsById then
                for _, icon in pairs(unitFrame.buffIconsById) do
                    icon:SetHidden(true)
                    icon.timerLabel:SetHidden(true)
                end
                unitFrame.buffIconsById = {}
            end
        end
    end
end

-- Add a custom buff to track for group members
function SpellCastBuffs.AddGroupBuff(buffId, name)
    if not buffId or type(buffId) ~= "number" then
        return false
    end

    -- Add to tracked list
    SpellCastBuffs.SV.GroupTrackedBuffs[buffId] = true
    SpellCastBuffs.SV.GroupTrackedBuffs[name] = true
    return true
end

-- Remove a buff from tracking
function SpellCastBuffs.RemoveGroupBuff(buffId, name)
    if not buffId or type(buffId) ~= "number" then
        return false
    end

    -- Remove from tracked list
    SpellCastBuffs.SV.GroupTrackedBuffs[buffId] = nil
    SpellCastBuffs.SV.GroupTrackedBuffs[name] = nil
    return true
end

-- Clear all custom buffs
function SpellCastBuffs.ClearGroupBuffs()
    local defaultBuffs = {}
    -- Keep default buffs
    for buffId in pairs(SpellCastBuffs.DefaultGroupBuffs) do
        defaultBuffs[buffId] = true
    end
    -- Reset to only default buffs
    SpellCastBuffs.SV.GroupTrackedBuffs = defaultBuffs
end
