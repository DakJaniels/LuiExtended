-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
if not UnitFrames then return end

-- Early return if LibGroupBroadcast is not available
if not LibGroupBroadcast then
    return
end

local UI = LUIE.UI

-- Constants
local COMBAT_MECHANIC_FLAGS_MAGICKA = COMBAT_MECHANIC_FLAGS_MAGICKA
local COMBAT_MECHANIC_FLAGS_STAMINA = COMBAT_MECHANIC_FLAGS_STAMINA

-- Get the GroupResources handler API (packaged with LibGroupBroadcast)
local GroupResources = LibGroupBroadcast:GetHandlerApi("GroupResources")
if not GroupResources then
    -- if LUIE.IsDevDebugEnabled() then
    --     LUIE.Error("[LUIE] LibGroupBroadcast GroupResources handler not available")
    -- end
    return
end

--- @class GroupResourcesManager
local GroupResourcesManager = {}
UnitFrames.GroupResources = GroupResourcesManager

local Shared = UnitFrames.LibGroupBroadcastShared

local isInitialized = false

-- Add resource bars to a custom frame (only needed for SmallGroup frames - RaidGroup frames have them pre-created)
local function AddResourceBarsToFrame(frameData, isRaid)
    if not frameData or not frameData.control then return end

    local Settings = Shared.GetResourceSettings()
    if not Settings or not Settings.enabled then return end

    local healthBackdrop = Shared.GetHealthBackdrop(frameData)
    if not healthBackdrop then return end

    -- For raid frames, bars are pre-created in _CreateCustomFrames.lua
    if isRaid then
        return
    end

    -- Create magicka bar if it doesn't exist (SmallGroup only)
    if not frameData.resourceMagicka then
        local magBackdrop = UI:Backdrop(frameData.control, nil, nil, nil, nil, false)
        magBackdrop:SetDrawLayer(DL_BACKGROUND)
        magBackdrop:SetDrawLevel(DL_CONTROLS)

        frameData.resourceMagicka =
        {
            ["backdrop"] = magBackdrop,
            ["bar"] = UI:StatusBar(magBackdrop, nil, nil, nil, false),
        }

        -- Anchor bar to backdrop with 1px inset (done in _CreateCustomFrames for raid)
        frameData.resourceMagicka.bar:SetAnchor(TOPLEFT, magBackdrop, TOPLEFT, 1, 1)
        frameData.resourceMagicka.bar:SetAnchor(BOTTOMRIGHT, magBackdrop, BOTTOMRIGHT, -1, -1)
        frameData.resourceMagicka.bar:SetHidden(true)
    end

    -- Create stamina bar if it doesn't exist (SmallGroup only)
    if not frameData.resourceStamina then
        local stamBackdrop = UI:Backdrop(frameData.control, nil, nil, nil, nil, false)
        stamBackdrop:SetDrawLayer(DL_BACKGROUND)
        stamBackdrop:SetDrawLevel(DL_CONTROLS)

        frameData.resourceStamina =
        {
            ["backdrop"] = stamBackdrop,
            ["bar"] = UI:StatusBar(stamBackdrop, nil, nil, nil, false),
        }

        -- Anchor bar to backdrop with 1px inset (done in _CreateCustomFrames for raid)
        frameData.resourceStamina.bar:SetAnchor(TOPLEFT, stamBackdrop, TOPLEFT, 1, 1)
        frameData.resourceStamina.bar:SetAnchor(BOTTOMRIGHT, stamBackdrop, BOTTOMRIGHT, -1, -1)
        frameData.resourceStamina.bar:SetHidden(true)
    end
end

-- Update resource bar appearance and position
local function UpdateResourceBarLayout(frameData, isRaid)
    if not frameData or not frameData.resourceMagicka or not frameData.resourceStamina then return end

    local Settings = Shared.GetResourceSettings()
    if not Settings then return end

    local staminaFirst = Settings.staminaFirst
    local barHeight = Settings[isRaid and "raidBarHeight" or "groupBarHeight"]
    local barWidth = Settings[isRaid and "raidBarWidth" or "groupBarWidth"]

    local magBackdrop = frameData.resourceMagicka.backdrop
    local stamBackdrop = frameData.resourceStamina.backdrop
    local magBar = frameData.resourceMagicka.bar
    local stamBar = frameData.resourceStamina.bar

    local healthBackdrop = Shared.GetHealthBackdrop(frameData)

    -- Position backdrops
    magBackdrop:ClearAnchors()
    stamBackdrop:ClearAnchors()

    if isRaid then
        -- Raid: side-by-side bars in the gap below health bar
        if staminaFirst then
            -- Stamina left, magicka right
            stamBackdrop:SetAnchor(TOPLEFT, healthBackdrop, BOTTOMLEFT, 0, 0)
            stamBackdrop:SetDimensions(barWidth, barHeight)

            magBackdrop:SetAnchor(LEFT, stamBackdrop, RIGHT, 1, 0)
            magBackdrop:SetDimensions(barWidth, barHeight)
        else
            -- Magicka left, stamina right (default)
            magBackdrop:SetAnchor(TOPLEFT, healthBackdrop, BOTTOMLEFT, 0, 0)
            magBackdrop:SetDimensions(barWidth, barHeight)

            stamBackdrop:SetAnchor(LEFT, magBackdrop, RIGHT, 1, 0)
            stamBackdrop:SetDimensions(barWidth, barHeight)
        end
    else
        -- Small group: stacked bars below health
        if staminaFirst then
            -- Stamina first (top), then magicka (bottom)
            stamBackdrop:SetAnchor(TOPLEFT, healthBackdrop, BOTTOMLEFT, 0, 2)
            stamBackdrop:SetDimensions(barWidth, barHeight)

            magBackdrop:SetAnchor(TOPLEFT, stamBackdrop, BOTTOMLEFT, 0, 1)
            magBackdrop:SetDimensions(barWidth, barHeight)
        else
            -- Magicka first (top), then stamina (bottom) - default
            magBackdrop:SetAnchor(TOPLEFT, healthBackdrop, BOTTOMLEFT, 0, 2)
            magBackdrop:SetDimensions(barWidth, barHeight)

            stamBackdrop:SetAnchor(TOPLEFT, magBackdrop, BOTTOMLEFT, 0, 1)
            stamBackdrop:SetDimensions(barWidth, barHeight)
        end
    end

    -- Apply textures and gradient colors to bars
    local rootSettings = Shared.GetSettings()
    local texture = LUIE.StatusbarTextures[rootSettings.CustomTexture]

    magBar:SetTexture(texture)
    magBar:SetPixelRoundingEnabled(true)

    stamBar:SetTexture(texture)
    stamBar:SetPixelRoundingEnabled(true)

    -- Apply magicka gradient colors
    local magColors = Settings.colors[COMBAT_MECHANIC_FLAGS_MAGICKA]
    if magColors then
        local startR, startG, startB, startA = unpack(magColors.gradientStart)
        local endR, endG, endB, endA = unpack(magColors.gradientEnd)
        magBar:SetGradientColors(startR, startG, startB, startA, endR, endG, endB, endA)
    end

    -- Apply stamina gradient colors
    local stamColors = Settings.colors[COMBAT_MECHANIC_FLAGS_STAMINA]
    if stamColors then
        local startR, startG, startB, startA = unpack(stamColors.gradientStart)
        local endR, endG, endB, endA = unpack(stamColors.gradientEnd)
        stamBar:SetGradientColors(startR, startG, startB, startA, endR, endG, endB, endA)
    end

    local isRoundTexture = rootSettings.CustomTexture == "Tube" or rootSettings.CustomTexture == "Steel"

    if texture then
        magBackdrop:SetCenterTexture(texture)
        magBackdrop:SetBlendMode(TEX_BLEND_MODE_ALPHA)
        magBackdrop:SetPixelRoundingEnabled(true)

        stamBackdrop:SetCenterTexture(texture)
        stamBackdrop:SetBlendMode(TEX_BLEND_MODE_ALPHA)
        stamBackdrop:SetPixelRoundingEnabled(true)

        -- Set edge colors based on texture type
        if isRoundTexture then
            magBackdrop:SetEdgeColor(0, 0, 0, 0)
            stamBackdrop:SetEdgeColor(0, 0, 0, 0)
        else
            magBackdrop:SetEdgeColor(0, 0, 0, 0.5)
            stamBackdrop:SetEdgeColor(0, 0, 0, 0.5)
        end
    end

    -- Apply backdrop colors (dark background like health bar)
    magBackdrop:SetCenterColor(0, 0, 0, 1)
    stamBackdrop:SetCenterColor(0, 0, 0, 1)
end

-- Update resource bar values
local function UpdateResourceBar(unitTag, current, maximum, percentage, powerType)
    if not unitTag or not current or not maximum then return end

    local frameData = Shared.GetFrameData(unitTag)
    if not frameData then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("[LUIE GroupResources] No frameData for unitTag: " .. tostring(unitTag))
        -- end
        return
    end

    local Settings = Shared.GetResourceSettings()
    if not Settings or not Settings.enabled then return end

    local resourceKey = (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA) and "resourceMagicka" or "resourceStamina"
    local resourceData = frameData[resourceKey]

    if not resourceData or not resourceData.bar or not resourceData.backdrop then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("[LUIE GroupResources] Missing resourceData for " .. unitTag .. " " .. resourceKey)
        -- end
        return
    end

    -- if LUIE.IsDevDebugEnabled() then
    --     LUIE.Debug("[LUIE GroupResources] UpdateResourceBar: " .. unitTag .. " " .. resourceKey .. " = " .. current .. "/" .. maximum)
    -- end

    local bar = resourceData.bar
    local oldValue = ZO_StatusBar_GetTargetValue(bar) or bar:GetValue()

    -- Setup fade out effect when resource decreases
    if Settings.enableFadeEffect then
        if current < oldValue then
            -- Resource decreased - show fade out ghost effect
            bar:EnableFadeOut(true)
            bar:SetFadeOutTime(0.5, 0.1)
            bar:SetFadeOutLossColor(1, 1, 1, 0.3)
        else
            -- Resource increased or stayed same - disable fade
            bar:EnableFadeOut(false)
        end
    end

    -- Use smooth transition if enabled
    local rootSettings = Shared.GetSettings()
    if rootSettings.CustomSmoothBar then
        ZO_StatusBar_SmoothTransition(bar, current, maximum, false, nil, 250) -- 250ms smooth transition
    else
        bar:SetMinMax(0, maximum)
        bar:SetValue(current)
    end

    -- Show both backdrop and bar
    resourceData.backdrop:SetHidden(false)
    bar:SetHidden(false)
end

-- Hide resource bars for a unit
local function HideResourceBars(unitTag)
    local frameData = Shared.GetFrameData(unitTag)
    if not frameData then return end

    if frameData.resourceMagicka then
        if frameData.resourceMagicka.bar then
            frameData.resourceMagicka.bar:SetHidden(true)
        end
        if frameData.resourceMagicka.backdrop then
            frameData.resourceMagicka.backdrop:SetHidden(true)
        end
    end

    if frameData.resourceStamina then
        if frameData.resourceStamina.bar then
            frameData.resourceStamina.bar:SetHidden(true)
        end
        if frameData.resourceStamina.backdrop then
            frameData.resourceStamina.backdrop:SetHidden(true)
        end
    end
end

-- Initialize LibGroupBroadcast integration
function GroupResourcesManager.Initialize()
    if isInitialized then return end

    local Settings = Shared.GetResourceSettings()
    if not Settings or not Settings.enabled then return end

    -- Register callbacks for resource updates directly with the GroupResources API
    GroupResources:RegisterForMagickaChanges(function (unitTag, unitName, current, maximum, percentage)
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("[LUIE GroupResources] Magicka callback: " .. tostring(unitTag) .. " " .. tostring(unitName) .. " " .. tostring(current) .. "/" .. tostring(maximum))
        -- end
        UpdateResourceBar(unitTag, current, maximum, percentage, COMBAT_MECHANIC_FLAGS_MAGICKA)
    end)

    GroupResources:RegisterForStaminaChanges(function (unitTag, unitName, current, maximum, percentage)
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("[LUIE GroupResources] Stamina callback: " .. tostring(unitTag) .. " " .. tostring(unitName) .. " " .. tostring(current) .. "/" .. tostring(maximum))
        -- end
        UpdateResourceBar(unitTag, current, maximum, percentage, COMBAT_MECHANIC_FLAGS_STAMINA)
    end)

    -- Handle timeout checking
    EVENT_MANAGER:RegisterForUpdate("LUIE_GroupResources_Timeout", 1000, function ()
        if not IsUnitGrouped("player") then return end

        local currentSettings = Shared.GetResourceSettings()
        if not currentSettings or not currentSettings.hideResourceBarsToggle then return end

        local now = GetGameTimeMilliseconds()
        local timeout = currentSettings.hideResourceBarsTimeout * 1000

        for i = 1, GetGroupSize() do
            local unitTag = GetGroupUnitTagByIndex(i)
            local frameData = Shared.GetFrameData(unitTag)
            if unitTag and frameData then
                local magLast = GroupResources:GetLastMagickaUpdateTime(unitTag)
                local stamLast = GroupResources:GetLastStaminaUpdateTime(unitTag)

                if (now - magLast > timeout) and (now - stamLast > timeout) then
                    HideResourceBars(unitTag)
                end
            end
        end
    end)

    isInitialized = true
end

-- Add resource bars to all group/raid frames
function GroupResourcesManager.SetupFrames()
    local Settings = Shared.GetResourceSettings()
    if not Settings or not Settings.enabled then return end

    -- Determine which frame type is in use (matches logic from CustomFramesGroupUpdate)
    local groupSize = GetGroupSize()
    local useRaidFrames = false

    if groupSize > 4 then
        useRaidFrames = true
    elseif not UnitFrames.CustomFrames["SmallGroup1"] or not UnitFrames.CustomFrames["SmallGroup1"].tlw then
        -- No SmallGroup frames available, must use raid frames
        useRaidFrames = true
    end

    -- Iterate over actual group members
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local frameData = Shared.GetFrameData(unitTag)
            if frameData then
                AddResourceBarsToFrame(frameData, useRaidFrames)
                UpdateResourceBarLayout(frameData, useRaidFrames)
            end
        end
    end
end

-- Update all resource bar layouts (called from menu)
function GroupResourcesManager.UpdateAllLayouts()
    -- Determine which frame type is in use
    local groupSize = GetGroupSize()
    local useRaidFrames = false

    if groupSize > 4 then
        useRaidFrames = true
    elseif not UnitFrames.CustomFrames["SmallGroup1"] or not UnitFrames.CustomFrames["SmallGroup1"].tlw then
        useRaidFrames = true
    end

    -- Iterate over actual group members
    for i = 1, groupSize do
        local unitTag = GetGroupUnitTagByIndex(i)
        if unitTag then
            local frameData = Shared.GetFrameData(unitTag)
            if frameData then
                UpdateResourceBarLayout(frameData, useRaidFrames)
            end
        end
    end
end

-- Refresh colors on all bars
function GroupResourcesManager.RefreshColors()
    GroupResourcesManager.UpdateAllLayouts()
end

-- Calculate extra height needed for resource bars
function GroupResourcesManager.GetResourceBarsHeight(isRaid)
    local Settings = Shared.GetResourceSettings()
    if not Settings or not Settings.enabled then
        return 0
    end

    if isRaid then
        -- Raid: inset bars don't add extra height (they're inside the health frame)
        return 0
    else
        -- Small group: stacked bars add height
        local barHeight = Settings.groupBarHeight
        -- 2px gap from health bar + first bar + 1px gap + second bar
        return 2 + barHeight + 1 + barHeight
    end
end
