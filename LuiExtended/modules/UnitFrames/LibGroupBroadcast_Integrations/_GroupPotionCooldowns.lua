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
local POTION_ICON = "LuiExtended/media/icons/potions/potion_001.dds"

-- Local cache of potion cooldown data (keyed by unitTag)
-- We maintain our own cache because the library's GetUnitPotionData() is buggy
local potionDataCache = {}

-- Add potion cooldown display to a custom frame
local function AddPotionCooldownToFrame(frameData, isRaid)
    if not frameData or not frameData.control then return end

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

        -- Potion icon backdrop
        if isRaid then
            -- Raid: Use pre-created ultContainer with flex layout
            if frameData.ultContainer then
                frameData.potionCooldown.backdrop = UI:Backdrop(frameData.ultContainer, nil, { iconSize, iconSize }, nil, { 0, 0, 0, 0.8 }, true)
                frameData.potionCooldown.backdrop:SetFlexGrow(0)
                frameData.potionCooldown.backdrop:SetFlexShrink(0)
                frameData.potionCooldown.backdrop:SetFlexMargin(FLEX_EDGE_RIGHT, 3)
            end
        else
            -- Small group: anchor to right of health bar (external, original positioning)
            local anchorTarget = backdrop
            local anchorPoint = RIGHT

            if frameData.combatStats and frameData.combatStats.ult2Backdrop then
                anchorTarget = frameData.combatStats.ult2Backdrop
                anchorPoint = RIGHT
            elseif frameData.combatStats and frameData.combatStats.ult1Backdrop then
                anchorTarget = frameData.combatStats.ult1Backdrop
                anchorPoint = RIGHT
            end

            frameData.potionCooldown.backdrop = UI:Backdrop(frameData.control, nil, { iconSize, iconSize }, nil, { 0, 0, 0, 0.8 }, true)
            frameData.potionCooldown.backdrop:SetAnchor(LEFT, anchorTarget, anchorPoint, offsetX, offsetY)
        end

        frameData.potionCooldown.backdrop:SetDrawLayer(DL_BACKGROUND)
        frameData.potionCooldown.backdrop:SetDrawLevel(13)

        -- Potion icon
        frameData.potionCooldown.icon = UI:Texture(frameData.potionCooldown.backdrop, { CENTER, CENTER }, { iconSize - 2, iconSize - 2 }, nil, DL_OVERLAY, false)
        frameData.potionCooldown.icon:SetTexture(POTION_ICON)
        frameData.potionCooldown.icon:SetDrawLevel(15)
        frameData.potionCooldown.icon:SetHidden(false)

        -- Cooldown time label (optional, shows remaining time)
        if Settings.showRemainingTime then
            local fontSize = isRaid and 10 or 12
            frameData.potionCooldown.label = UI:Label(frameData.potionCooldown.backdrop, { CENTER, BOTTOM, 0, 0 }, nil, { 1, 1 }, nil, "", false)
            frameData.potionCooldown.label:SetDrawLayer(DL_OVERLAY)
            frameData.potionCooldown.label:SetDrawLevel(16)
            local rootSettings = Shared.GetSettings()
            local fontFace = LUIE.Fonts[rootSettings.CustomFontFace]
            local fontStyle = rootSettings.CustomFontStyle
            frameData.potionCooldown.label:SetFont(ZO_CreateFontString(fontFace, fontSize, fontStyle))
            frameData.potionCooldown.label:SetHidden(true)
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

            -- Use our cached data instead of querying the buggy library method
            for unitTag, potionData in pairs(potionDataCache) do
                local frameData = Shared.GetFrameData(unitTag)
                if potionData and frameData and frameData.potionCooldown then
                    UpdatePotionCooldownDisplay(unitTag, potionData)
                end
            end
        end)
    end

    isInitialized = true
end

-- Setup potion cooldown displays on all frames
function GroupPotionCooldownsManager.SetupFrames()
    local Settings = Shared.GetPotionCooldownSettings()
    if not Settings or not Settings.enabled then return end

    Shared.ForEachGroupFrame(function (unitTag, frameData, isRaid)
        if not frameData.potionCooldown then
            AddPotionCooldownToFrame(frameData, isRaid)
        end
    end)
end

-- Refresh all potion cooldown displays (called from settings)
function GroupPotionCooldownsManager.RefreshAll()
    if not lgpc then return end
    if not IsUnitGrouped("player") then return end

    -- Use our cached data instead of querying the buggy library method
    for unitTag, potionData in pairs(potionDataCache) do
        local frameData = Shared.GetFrameData(unitTag)
        if potionData and frameData and frameData.potionCooldown then
            UpdatePotionCooldownDisplay(unitTag, potionData)
        end
    end
end
