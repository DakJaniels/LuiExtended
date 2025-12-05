-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
if not UnitFrames then return end

-- Early return if LibGroupPotionCooldowns is not available
if not LibGroupPotionCooldowns then
    return
end

local UI = LUIE.UI

--- @class GroupPotionCooldownsManager
local GroupPotionCooldownsManager = {}
UnitFrames.GroupPotionCooldowns = GroupPotionCooldownsManager

local Shared = UnitFrames.LibGroupBroadcastShared

local lgpc
local isInitialized = false

-- Potion icon texture path (using existing LUIE potion icon)
local POTION_ICON = LUIE_MEDIA_ICONS_POTIONS_POTION_001_DDS

-- Local cache of potion cooldown data (keyed by unitTag)
-- We maintain our own cache because the library's GetUnitPotionData() is buggy
local potionDataCache = {}

-- Add potion cooldown display to a custom frame
local function AddPotionCooldownToFrame(frameData, isRaid)
    if not frameData or not frameData.control then return end

    -- Only create for SmallGroup frames, not RaidGroup
    if isRaid then return end

    local Settings = Shared.GetPotionCooldownSettings()
    if not Settings or not Settings.enabled then return end

    local backdrop = Shared.GetHealthBackdrop(frameData)
    if not backdrop then return end

    -- Create potion display if it doesn't exist
    if not frameData.potionCooldown then
        frameData.potionCooldown = {}

        -- If ultimate icons are enabled, match their size for visual consistency
        local iconSize
        local combatStatsSettings = Shared.GetCombatStatsSettings()
        if combatStatsSettings and combatStatsSettings.enabled and combatStatsSettings.showUltimate then
            iconSize = isRaid and combatStatsSettings.ultIconRaidSize or combatStatsSettings.ultIconGroupSize
        else
            iconSize = isRaid and Settings.potionIconRaidSize or Settings.potionIconGroupSize
        end

        local offsetX = isRaid and Settings.potionIconRaidOffsetX or Settings.potionIconGroupOffsetX
        local offsetY = isRaid and Settings.potionIconRaidOffsetY or Settings.potionIconGroupOffsetY

        -- Get the container (already exists in XML)
        local container = frameData.libGroupContainer
        if not container then
            -- Fallback: get from control if not set in frameData
            container = frameData.control and frameData.control:GetNamedChild("_LibGroupContainer") or nil
            if container then
                frameData.libGroupContainer = container
            else
                return -- Can't proceed without container
            end
        end

        -- Anchor container to health bar if not already anchored
        local numAnchors = container:GetNumAnchors()
        if numAnchors == 0 then
            local healthBackdrop = Shared.GetHealthBackdrop(frameData)
            container:SetAnchor(LEFT, healthBackdrop, RIGHT, offsetX, offsetY)
        end

        -- Get potion controls from XML
        frameData.potionCooldown.backdrop = container:GetNamedChild("_PotionBackdrop")
        if not frameData.potionCooldown.backdrop then
            return -- Can't proceed without potion controls
        end
        frameData.potionCooldown.icon = frameData.potionCooldown.backdrop:GetNamedChild("_Icon")
        frameData.potionCooldown.label = frameData.potionCooldown.backdrop:GetNamedChild("_Label")

        -- Set dimensions based on settings
        frameData.potionCooldown.backdrop:SetDimensions(iconSize, iconSize)
        frameData.potionCooldown.icon:SetDimensions(iconSize - 2, iconSize - 2)

        -- Anchor within container (order: food/drink -> ult1 -> ult2 -> potion)
        frameData.potionCooldown.backdrop:ClearAnchors()
        if frameData.combatStats and frameData.combatStats.ult2Backdrop then
            frameData.potionCooldown.backdrop:SetAnchor(LEFT, frameData.combatStats.ult2Backdrop, RIGHT, 3, 0)
        elseif frameData.combatStats and frameData.combatStats.ult1Backdrop then
            frameData.potionCooldown.backdrop:SetAnchor(LEFT, frameData.combatStats.ult1Backdrop, RIGHT, 3, 0)
        elseif frameData.foodDrinkBuff and frameData.foodDrinkBuff.backdrop then
            frameData.potionCooldown.backdrop:SetAnchor(LEFT, frameData.foodDrinkBuff.backdrop, RIGHT, 3, 0)
        else
            frameData.potionCooldown.backdrop:SetAnchor(LEFT, container, LEFT, 0, 0)
        end

        -- Set draw properties
        frameData.potionCooldown.backdrop:SetDrawLayer(DL_BACKGROUND)
        frameData.potionCooldown.backdrop:SetDrawLevel(13)
        frameData.potionCooldown.icon:SetTexture(POTION_ICON)
        frameData.potionCooldown.icon:SetDrawLevel(15)

        -- Apply font to label if showRemainingTime is enabled
        if Settings.showRemainingTime then
            local fontSize = isRaid and 10 or 12
            local rootSettings = Shared.GetSettings()
            local fontFace = LUIE.Fonts[rootSettings.CustomFontFace]
            local fontStyle = rootSettings.CustomFontStyle
            frameData.potionCooldown.label:SetFont(ZO_CreateFontString(fontFace, fontSize, fontStyle))
        end
    end
end

-- Update potion cooldown display
local function UpdatePotionCooldownDisplay(unitTag, potionData)
    if not potionData then return end

    local frameData = Shared.GetFrameData(unitTag)
    if not frameData or not frameData.potionCooldown then return end

    local Settings = Shared.GetPotionCooldownSettings()
    if not Settings or not Settings.enabled then return end

    local backdrop = frameData.potionCooldown.backdrop
    local icon = frameData.potionCooldown.icon
    local label = frameData.potionCooldown.label

    if potionData.isOnCooldown then
        -- Calculate remaining time
        local currentTime = GetGameTimeMilliseconds()
        local hasCooldownUntil = potionData.hasCooldownUntil or 0
        local remainingMS = hasCooldownUntil - currentTime

        -- On cooldown - show red/dark tint
        backdrop:SetCenterColor(0.3, 0, 0, 0.9)
        icon:SetColor(0.5, 0.5, 0.5, 1) -- Desaturated

        -- Show remaining time if enabled
        if Settings.showRemainingTime and label then
            if remainingMS > 0 then
                local seconds = math.ceil(remainingMS / 1000)
                label:SetText(string.format("|cFF6666%ds|r", seconds))
                label:SetHidden(false)
            else
                label:SetHidden(true)
            end
        end
    else
        -- Ready - show normal/green tint
        backdrop:SetCenterColor(0, 0.15, 0, 0.8)
        icon:SetColor(1, 1, 1, 1) -- Full color

        if label then
            label:SetHidden(true)
        end
    end

    backdrop:SetHidden(false)
    icon:SetHidden(false)
end

-- Hide potion cooldown display
local function HidePotionCooldown(unitTag)
    local frameData = Shared.GetFrameData(unitTag)
    if not frameData or not frameData.potionCooldown then return end

    if frameData.potionCooldown.icon then
        frameData.potionCooldown.icon:SetHidden(true)
    end
    if frameData.potionCooldown.backdrop then
        frameData.potionCooldown.backdrop:SetHidden(true)
    end
    if frameData.potionCooldown.label then
        frameData.potionCooldown.label:SetHidden(true)
    end
end

-- Initialize LibGroupPotionCooldowns integration
function GroupPotionCooldownsManager.Initialize()
    if isInitialized then return end

    local Settings = Shared.GetPotionCooldownSettings()
    if not Settings or not Settings.enabled then return end

    -- Register with LibGroupPotionCooldowns
    lgpc = LibGroupPotionCooldowns.RegisterAddon("LuiExtended")
    if not lgpc then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Error("[LUIE] Failed to register with LibGroupPotionCooldowns")
        -- end
        return
    end

    -- Register for cooldown updates
    -- Note: We rely ONLY on the event callbacks because the library's GetUnitPotionData()
    -- query method is buggy and returns nil/empty data even when cooldowns are active
    lgpc:RegisterForEvent(LibGroupPotionCooldowns.EVENT_GROUP_COOLDOWN_UPDATE, function (unitTag, potionData)
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("[LUIE] GROUP_COOLDOWN_UPDATE: " .. unitTag .. " isOnCooldown=" .. tostring(potionData.isOnCooldown))
        -- end
        -- Cache the data for periodic updates
        potionDataCache[unitTag] = potionData
        UpdatePotionCooldownDisplay(unitTag, potionData)
    end)

    lgpc:RegisterForEvent(LibGroupPotionCooldowns.EVENT_PLAYER_COOLDOWN_UPDATE, function (unitTag, potionData)
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("[LUIE] PLAYER_COOLDOWN_UPDATE: " .. unitTag .. " isOnCooldown=" .. tostring(potionData.isOnCooldown))
        -- end
        -- Cache the data for periodic updates
        potionDataCache[unitTag] = potionData
        UpdatePotionCooldownDisplay(unitTag, potionData)
    end)

    -- Periodic update to refresh displays (for remaining time countdown)
    if Settings.showRemainingTime then
        EVENT_MANAGER:RegisterForUpdate("LUIE_GroupPotionCooldowns_Update", 1000, function ()
            if not IsUnitGrouped("player") then return end

            -- Iterate over active group members and update from cache
            Shared.ForEachActiveGroupMember(function (unitTag, frameData)
                local potionData = potionDataCache[unitTag]
                if potionData and frameData.potionCooldown then
                    UpdatePotionCooldownDisplay(unitTag, potionData)
                end
            end)
        end)
    end

    isInitialized = true
end

-- Setup potion cooldown displays on all frames
function GroupPotionCooldownsManager.SetupFrames()
    local Settings = Shared.GetPotionCooldownSettings()
    if not Settings or not Settings.enabled then return end

    -- Use shared frame setup helper with unhide callback
    Shared.SetupIntegrationFrames("potionCooldown", AddPotionCooldownToFrame, function (frameData)
        -- Unhide container when reusing SmallGroup frames
        if frameData.libGroupContainer then
            frameData.libGroupContainer:SetHidden(false)
        end
        -- Request fresh data from cache
        local unitTag = frameData.unitTag
        if unitTag then
            local potionData = potionDataCache[unitTag]
            if potionData then
                UpdatePotionCooldownDisplay(unitTag, potionData)
            end
        end
    end)
end

-- Refresh all potion cooldown displays (called from settings)
function GroupPotionCooldownsManager.RefreshAll()
    if not lgpc then return end
    if not IsUnitGrouped("player") then return end

    -- Iterate over active group members and update from cache
    Shared.ForEachActiveGroupMember(function (unitTag, frameData)
        local potionData = potionDataCache[unitTag]
        if potionData and frameData.potionCooldown then
            UpdatePotionCooldownDisplay(unitTag, potionData)
        end
    end)
end
