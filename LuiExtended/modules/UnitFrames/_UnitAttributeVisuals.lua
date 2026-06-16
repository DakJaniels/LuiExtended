-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local string_sub = string.sub

-- -----------------------------------------------------------------------------
-- Coordinator Setup
-- -----------------------------------------------------------------------------

--- @param unitTag string
--- @return LUIE_UnitAttributeVisualizer|nil
function UnitFrames.GetVisualizerForUnit(unitTag)
    if not unitTag then
        return nil
    end

    local customFrame = UnitFrames.CustomFrames[unitTag]
    if customFrame and customFrame.attributeVisualizer then
        return customFrame.attributeVisualizer
    end

    if UnitFrames.defaultVisualizers and UnitFrames.defaultVisualizers[unitTag] then
        return UnitFrames.defaultVisualizers[unitTag]
    end

    return UnitFrames.Visualizers[unitTag]
end

--- Invokes callback for every visualizer tracking game unitTag (custom + default + aliases).
--- @param unitTag string
--- @param callback fun(visualizer: LUIE_UnitAttributeVisualizer)
function UnitFrames.ForEachVisualizerForUnit(unitTag, callback)
    if not unitTag or not callback then
        return
    end

    local seen = {}

    local function visit(visualizer)
        if visualizer and not seen[visualizer] then
            seen[visualizer] = true
            callback(visualizer)
        end
    end

    visit(UnitFrames.GetVisualizerForUnit(unitTag))

    for _, frame in pairs(UnitFrames.CustomFrames) do
        if type(frame) == "table" and frame.GetVisualizerUnitTag and frame:GetVisualizerUnitTag() == unitTag then
            visit(frame.attributeVisualizer)
        end
    end
end

--- Initializes default-frame visualizers for units without custom-frame visualizers.
function UnitFrames.InitializeDefaultVisualizers()
    if UnitFrames.InitializeDefaultVisualizersImpl then
        UnitFrames.InitializeDefaultVisualizersImpl()
    end
end

-- -----------------------------------------------------------------------------
-- Helper Functions
-- -----------------------------------------------------------------------------

local function FormatNumber(value)
    local AbbreviateNumber = LUIE.AbbreviateNumber
    local SHORTEN = UnitFrames.SV.ShortenNumbers or false
    local COMMA = true
    return tostring(AbbreviateNumber(value, SHORTEN, COMMA))
end

local attributeVisualEffectCacheFrameId
local attributeVisualEffectCacheByUnitTag = {}

--- Per-frame cache of GetAllUnitAttributeVisualizerEffectInfo for a unitTag.
--- @param unitTag string
--- @return table<string, integer>
function UnitFrames.GetAttributeVisualEffectValueCache(unitTag)
    local frameId = GetFrameTimeSeconds()
    if attributeVisualEffectCacheFrameId ~= frameId then
        attributeVisualEffectCacheFrameId = frameId
        ZO_ClearTable(attributeVisualEffectCacheByUnitTag)
    end

    local attributeVisualCache = attributeVisualEffectCacheByUnitTag[unitTag]
    if attributeVisualCache then
        return attributeVisualCache
    end

    attributeVisualCache = {}
    local results = { GetAllUnitAttributeVisualizerEffectInfo(unitTag) }
    for i = 1, #results, 6 do
        local cacheKey = string.format("%d_%d_%d_%d", results[i], results[i + 1], results[i + 2], results[i + 3])
        attributeVisualCache[cacheKey] = results[i + 4]
    end

    local debugOverrides = UnitFrames.debugAttributeVisualOverrides
    if debugOverrides and debugOverrides[unitTag] then
        for cacheKey, overrideValue in pairs(debugOverrides[unitTag]) do
            attributeVisualCache[cacheKey] = overrideValue
        end
    end

    attributeVisualEffectCacheByUnitTag[unitTag] = attributeVisualCache
    return attributeVisualCache
end

--- Clears cached GetAllUnitAttributeVisualizerEffectInfo for one or all unit tags (debug overrides).
--- @param unitTag string|nil
function UnitFrames.InvalidateAttributeVisualEffectCache(unitTag)
    if unitTag then
        attributeVisualEffectCacheByUnitTag[unitTag] = nil
    else
        ZO_ClearTable(attributeVisualEffectCacheByUnitTag)
    end
end

--- @param unitTag string
--- @param visualType UnitAttributeVisual
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerTypeQuery CombatMechanicFlags
--- @return integer
function UnitFrames.GetAttributeVisualEffectValue(unitTag, visualType, statType, attributeType, powerTypeQuery)
    local cache = UnitFrames.GetAttributeVisualEffectValueCache(unitTag)
    local cacheKey = string.format("%d_%d_%d_%d", visualType, statType, attributeType, powerTypeQuery)
    return cache[cacheKey] or 0
end

-- -----------------------------------------------------------------------------
-- Power Update Handler
-- -----------------------------------------------------------------------------

UnitFrames.powerUpdateSnapshot = UnitFrames.powerUpdateSnapshot or {}

--- Clears cached power values used to skip redundant UpdateAttribute work (see ZO_PlayerAttributeBar:OnPowerUpdate).
--- @param unitTag string
--- @param powerType CombatMechanicFlags|nil If nil, clears all power types for unitTag
function UnitFrames.ClearPowerUpdateSnapshot(unitTag, powerType)
    local unitSnap = UnitFrames.powerUpdateSnapshot[unitTag]
    if not unitSnap then
        return
    end
    if powerType then
        unitSnap[powerType] = nil
    else
        UnitFrames.powerUpdateSnapshot[unitTag] = nil
    end
end

--- Drops the per-unitTag updateRecencyInfo subtree on every registered visualizer
--- module so its nested tables can be collected when a unit is destroyed.
--- Visualizer modules are singletons (one set in UnitFrames.VisualizerModules,
--- mixed into each LUIE_UnitAttributeVisualizer), so without this call every
--- unitTag ever seen by a UAV event retains its full sequence-id subtree until
--- /reloadui.
--- @param unitTag string
function UnitFrames.ClearVisualizerRecencyInfo(unitTag)
    if not unitTag then return end

    local function clearModules(visualizer)
        if not visualizer or not visualizer.visualModules then return end
        for module in pairs(visualizer.visualModules) do
            if module and module.ClearUnitTag then
                module:ClearUnitTag(unitTag)
            end
        end
    end

    clearModules(UnitFrames.GetVisualizerForUnit(unitTag))
    clearModules(UnitFrames.defaultVisualizers and UnitFrames.defaultVisualizers[unitTag])

    local customFrame = UnitFrames.CustomFrames[unitTag]
    if customFrame and customFrame.attributeVisualizer then
        clearModules(customFrame.attributeVisualizer)
    end
end

--- @param unitTag string
--- @param powerType CombatMechanicFlags
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
--- @return boolean
function UnitFrames.HasPowerUpdateChanged(unitTag, powerType, powerValue, powerMax, powerEffectiveMax)
    local unitSnap = UnitFrames.powerUpdateSnapshot[unitTag]
    local snap = unitSnap and unitSnap[powerType]
    if not snap then
        return true
    end
    return snap[1] ~= powerValue or snap[2] ~= powerMax or snap[3] ~= powerEffectiveMax
end

--- @param unitTag string
--- @param powerType CombatMechanicFlags
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
function UnitFrames.CommitPowerUpdateSnapshot(unitTag, powerType, powerValue, powerMax, powerEffectiveMax)
    local unitSnap = UnitFrames.powerUpdateSnapshot[unitTag]
    if not unitSnap then
        unitSnap = {}
        UnitFrames.powerUpdateSnapshot[unitTag] = unitSnap
    end
    unitSnap[powerType] = { powerValue, powerMax, powerEffectiveMax }
end

--- Runs on the EVENT_POWER_UPDATE listener.
--- This handler fires every time unit attribute changes.
---
--- @param unitTag string
--- @param powerIndex luaindex
--- @param powerType CombatMechanicFlags
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
function UnitFrames.OnPowerUpdate(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    -- Save Health value for future reference
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and UnitFrames.savedHealth[unitTag] then
        local previousHealth = UnitFrames.savedHealth[unitTag]
        local bossMaxChanged = false

        if previousHealth and string_sub(unitTag, 1, 4) == "boss" then
            local previousMax = previousHealth[2]
            local previousEffectiveMax = previousHealth[3]
            bossMaxChanged = (previousMax and previousMax ~= powerMax) or (previousEffectiveMax and previousEffectiveMax ~= powerEffectiveMax)
        end

        UnitFrames.savedHealth[unitTag] =
        {
            powerValue,
            powerMax,
            powerEffectiveMax,
            previousHealth[4] or 0, -- shield
            previousHealth[5] or 0  -- trauma
        }

        if bossMaxChanged then
            UnitFrames.UpdateBossThresholds()
        elseif string_sub(unitTag, 1, 4) == "boss" then
            UnitFrames.RepaintBossThresholdMarkers()
        end
    end

    local powerChanged = UnitFrames.HasPowerUpdateChanged(unitTag, powerType, powerValue, powerMax, powerEffectiveMax)
    if not powerChanged then
        return
    end

    local defaultPowerEntry = UnitFrames.DefaultFrames[unitTag] and UnitFrames.DefaultFrames[unitTag][powerType]
    local customFrame = UnitFrames.CustomFrames[unitTag]
    local customPowerEntry = customFrame and customFrame[powerType]
    local avaPowerEntry = UnitFrames.AvaCustFrames[unitTag] and UnitFrames.AvaCustFrames[unitTag][powerType]

    local skipCustomPowerUpdate = false
    if customFrame and unitTag == "reticleover" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
        local isCritter = (UnitFrames.savedHealth.reticleover[3] <= 9)
        local isGuard = IsUnitInvulnerableGuard("reticleover")
        if (isCritter or isGuard) and powerValue >= 1 then
            skipCustomPowerUpdate = true
        end
    end

    local hasUpdateTarget = defaultPowerEntry or avaPowerEntry or (customPowerEntry and not skipCustomPowerUpdate)
    if not hasUpdateTarget then
        return
    end

    UnitFrames.CommitPowerUpdateSnapshot(unitTag, powerType, powerValue, powerMax, powerEffectiveMax)

    if defaultPowerEntry then
        UnitFrames.UpdateAttribute(unitTag, powerType, defaultPowerEntry, powerValue, powerEffectiveMax, false, nil)
    end

    if customFrame and customPowerEntry and not skipCustomPowerUpdate then
        UnitFrames.UpdateCustomFramePower(unitTag, powerType, powerValue, powerMax, powerEffectiveMax, false, nil)
    end

    if avaPowerEntry then
        UnitFrames.UpdateAttribute(unitTag, powerType, avaPowerEntry, powerValue, powerEffectiveMax, false, nil)
    end

    -- Record state of power loss to change transparency of player frame
    if unitTag == "player" and (powerType == COMBAT_MECHANIC_FLAGS_HEALTH or powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA or powerType == COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA) then
        UnitFrames.statFull[powerType] = (powerValue == powerEffectiveMax)
        UnitFrames.CustomFramesApplyInCombat()
    end

    if unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
        if not UnitFrames.PlayerDodgePrediction.ShouldUseLUIEStaminaSmooth() then
            UnitFrames.PlayerDodgePrediction.Refresh(true)
        end
    end

    -- If players powerValue is zero, issue new blinking event on Custom Frames
    if unitTag == "player" and powerValue == 0 and powerType ~= COMBAT_MECHANIC_FLAGS_WEREWOLF then
        UnitFrames.OnCombatEvent(nil, nil, true, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, nil, COMBAT_UNIT_TYPE_PLAYER, 0, powerType, nil, false, nil, nil, nil, nil)
    end

    -- Display skull icon for alive execute-level targets
    if unitTag == "reticleover" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH and UnitFrames.CustomFrames["reticleover"] and UnitFrames.reticleoverHostile then
        if powerValue == 0 then
            UnitFrames.CustomFrames["reticleover"].skull:SetHidden(true)
        elseif 100 * powerValue / powerEffectiveMax < UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold then
            UnitFrames.CustomFrames["reticleover"].skull:SetHidden(false)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Attribute Update
-- -----------------------------------------------------------------------------

--- Updates attribute values and visuals for unit frames
--- @param unitTag string The unit identifier (e.g. "player", "reticleover")
--- @param powerType integer The type of power/attribute being updated (e.g. COMBAT_MECHANIC_FLAGS_HEALTH)
--- @param attributeFrame table The frame containing the attribute UI elements
--- @param powerValue integer Current value of the power/attribute
--- @param powerEffectiveMax integer Maximum value of the power/attribute
--- @param isTraumaFlag boolean Whether this update is triggered by trauma changes
--- @param forceInit boolean Whether to force initialization of the status bar
function UnitFrames.UpdateAttribute(unitTag, powerType, attributeFrame, powerValue, powerEffectiveMax, isTraumaFlag, forceInit)
    if not attributeFrame then
        return
    end

    local pct = zo_floor(100 * powerValue / powerEffectiveMax)

    local attributeVisualCache = UnitFrames.GetAttributeVisualEffectValueCache(unitTag)

    -- Helper to query cache
    local function getAttributeVisual(visualType, statType, attributeType, powerTypeQuery)
        local cacheKey = string.format("%d_%d_%d_%d", visualType, statType, attributeType, powerTypeQuery)
        return attributeVisualCache[cacheKey] or 0
    end

    -- Update Shield / Trauma values IF this is the health bar
    local shield = (powerType == COMBAT_MECHANIC_FLAGS_HEALTH and UnitFrames.savedHealth[unitTag][4] > 0) and UnitFrames.savedHealth[unitTag][4] or nil
    local trauma = (powerType == COMBAT_MECHANIC_FLAGS_HEALTH and UnitFrames.savedHealth[unitTag][5] > 0) and UnitFrames.savedHealth[unitTag][5] or nil
    local isUnwaveringPower = getAttributeVisual(ATTRIBUTE_VISUAL_UNWAVERING_POWER, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    local isGuard = (UnitFrames.CustomFrames and UnitFrames.CustomFrames["reticleover"] and attributeFrame == UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH] and IsUnitInvulnerableGuard("reticleover"))

    -- Adjust health bar value to subtract the trauma bar value
    local adjustedBarValue = powerValue
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and trauma then
        adjustedBarValue = powerValue - trauma
        if adjustedBarValue < 0 then
            adjustedBarValue = 0
        end
    end

    -- Update labels
    for _, label in pairs({ "label", "labelOne", "labelTwo" }) do
        if attributeFrame[label] then
            local format = tostring(attributeFrame[label].format or UnitFrames.SV.Format)
            local str = format
            str = StringOnlyGSUB(str, "Percentage", tostring(pct))
            str = StringOnlyGSUB(str, "Max", FormatNumber(powerEffectiveMax))
            str = StringOnlyGSUB(str, "Current", FormatNumber(powerValue))
            str = StringOnlyGSUB(str, "+ Shield", shield and ("+ " .. FormatNumber(shield)) or "")
            str = StringOnlyGSUB(str, "- Trauma", trauma and ("- (" .. FormatNumber(trauma) .. ")") or "")
            str = StringOnlyGSUB(str, "Nothing", "")
            str = StringOnlyGSUB(str, "  ", " ")

            if isGuard and label == "labelOne" then
                attributeFrame[label]:SetText(" - Invulnerable - ")
            else
                attributeFrame[label]:SetText(str)
            end

            -- Hide if dead
            if (label == "labelOne" or label == "labelTwo") and UnitFrames.CustomFrames and UnitFrames.CustomFrames["reticleover"] and attributeFrame == UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH] and powerValue == 0 then
                attributeFrame[label]:SetHidden(true)
            end

            -- Color handling
            if (isUnwaveringPower == 1 and powerValue > 0) or isGuard then
                attributeFrame[label]:SetColor(unpack(attributeFrame.color or { 1, 1, 1, 1 }))
            else
                local isLow = pct < (attributeFrame.threshold or UnitFrames.defaultThreshold)
                attributeFrame[label]:SetColor(unpack(isLow and { 1, 0.25, 0.38, 1 } or attributeFrame.color or { 1, 1, 1, 1 }))
            end
        end
    end

    -- Update status bar
    if attributeFrame.bar then
        if UnitFrames.SV.CustomSmoothBar and not isTraumaFlag then
            if  unitTag == "player"
            and powerType == COMBAT_MECHANIC_FLAGS_STAMINA
            and UnitFrames.PlayerDodgePrediction.ShouldUseLUIEStaminaSmooth() then
                UnitFrames.PlayerDodgePrediction.SmoothTransitionStaminaBar(attributeFrame.bar, adjustedBarValue, powerEffectiveMax, forceInit)
            else
                if unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
                    UnitFrames.PlayerDodgePrediction.StopStaminaBarSmoothAnimation(attributeFrame.bar)
                end
                ZO_StatusBar_SmoothTransition(attributeFrame.bar, adjustedBarValue, powerEffectiveMax, forceInit, nil, 250)
            end
            if trauma then
                ZO_StatusBar_SmoothTransition(attributeFrame.trauma, powerValue, powerEffectiveMax, forceInit, nil, 250)
            elseif attributeFrame.trauma then
                attributeFrame.trauma:SetValue(0)
                attributeFrame.trauma:SetHidden(true)
            end
        else
            if unitTag == "player" and powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
                UnitFrames.PlayerDodgePrediction.StopStaminaBarSmoothAnimation(attributeFrame.bar)
            end
            attributeFrame.bar:SetMinMax(0, powerEffectiveMax)
            attributeFrame.bar:SetValue(adjustedBarValue)
            if trauma then
                attributeFrame.trauma:SetMinMax(0, powerEffectiveMax)
                attributeFrame.trauma:SetValue(powerValue)
            elseif attributeFrame.trauma then
                attributeFrame.trauma:SetValue(0)
                attributeFrame.trauma:SetHidden(true)
            end
        end

        -- Handle invulnerable bar
        if attributeFrame.invulnerable then
            if (isUnwaveringPower == 1 and powerValue > 0) or isGuard then
                attributeFrame.invulnerable:SetMinMax(0, powerEffectiveMax)
                attributeFrame.invulnerable:SetValue(powerValue)
                attributeFrame.invulnerable:SetHidden(false)
                attributeFrame.invulnerableInlay:SetMinMax(0, powerEffectiveMax)
                attributeFrame.invulnerableInlay:SetValue(powerValue)
                attributeFrame.invulnerableInlay:SetHidden(false)
                attributeFrame.bar:SetHidden(true)
            else
                attributeFrame.invulnerable:SetHidden(true)
                attributeFrame.invulnerableInlay:SetHidden(true)
                attributeFrame.bar:SetHidden(false)
            end
        end

        -- Update no-healing overlay (default frames)
        if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and attributeFrame.noHealingInner and attributeFrame.noHealingOuter then
            local noHealingValue = getAttributeVisual(ATTRIBUTE_VISUAL_NO_HEALING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
            if noHealingValue > 0 and not attributeFrame.noHealingInner:IsHidden() then
                attributeFrame.noHealingOuter:SetMinMax(0, powerEffectiveMax)
                attributeFrame.noHealingOuter:SetValue(powerValue)
                attributeFrame.noHealingInner:SetMinMax(0, powerEffectiveMax)
                attributeFrame.noHealingInner:SetValue(adjustedBarValue)
            end
        end

        -- Update no-healing overlay and stripe (custom frames)
        if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and attributeFrame.noHealingOverlay then
            local noHealingValue = getAttributeVisual(ATTRIBUTE_VISUAL_NO_HEALING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
            if noHealingValue > 0 and not attributeFrame.noHealingOverlay:IsHidden() then
                -- Update overlay value to match current health
                if UnitFrames.SV.CustomSmoothBar then
                    ZO_StatusBar_SmoothTransition(attributeFrame.noHealingOverlay, powerValue, powerEffectiveMax, forceInit, nil, 250)
                    if attributeFrame.noHealingStripe then
                        ZO_StatusBar_SmoothTransition(attributeFrame.noHealingStripe, powerValue, powerEffectiveMax, forceInit, nil, 250)
                    end
                else
                    attributeFrame.noHealingOverlay:SetMinMax(0, powerEffectiveMax)
                    attributeFrame.noHealingOverlay:SetValue(powerValue)
                    if attributeFrame.noHealingStripe then
                        attributeFrame.noHealingStripe:SetMinMax(0, powerEffectiveMax)
                        attributeFrame.noHealingStripe:SetValue(powerValue)
                    end
                end
            end
        end
    end
end
