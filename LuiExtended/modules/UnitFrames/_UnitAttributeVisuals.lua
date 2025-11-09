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

--- Creates and initializes a visualizer coordinator for a unitTag
--- @param unitTag string
function UnitFrames.CreateVisualizer(unitTag)
    if UnitFrames.Visualizers[unitTag] then
        return -- Already exists
    end

    -- Create visualizer (modules are automatically added via mixin in Initialize)
    local visualizer = LUIE_UnitAttributeVisualizer:New(unitTag)
    UnitFrames.Visualizers[unitTag] = visualizer
end

--- Initializes visualizers for all tracked units
function UnitFrames.InitializeVisualizers()
    -- Core units
    UnitFrames.CreateVisualizer("player")
    UnitFrames.CreateVisualizer("reticleover")
    UnitFrames.CreateVisualizer("companion")
    UnitFrames.CreateVisualizer("controlledsiege")

    -- Group members
    for i = 1, 12 do
        UnitFrames.CreateVisualizer("group" .. i)
    end

    -- Bosses
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        UnitFrames.CreateVisualizer("boss" .. i)
    end

    -- Pets
    for i = 1, 7 do
        UnitFrames.CreateVisualizer("playerpet" .. i)
    end
end

--- Gets the visualizer coordinator for a specific unit
--- @param unitTag string
--- @return LUIE_UnitAttributeVisualizer|nil
function UnitFrames.GetVisualizerForUnit(unitTag)
    return UnitFrames.Visualizers[unitTag]
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

-- -----------------------------------------------------------------------------
-- Power Update Handler
-- -----------------------------------------------------------------------------

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
        end
    end

    -- Update frames
    if UnitFrames.DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, powerType, UnitFrames.DefaultFrames[unitTag][powerType], powerValue, powerEffectiveMax, false, nil)
    end

    if UnitFrames.CustomFrames[unitTag] then
        -- Special handling for reticleover health to skip critters and guards
        if unitTag == "reticleover" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
            local isCritter = (UnitFrames.savedHealth.reticleover[3] <= 9)
            local isGuard = IsUnitInvulnerableGuard("reticleover")
            if (isCritter or isGuard) and powerValue >= 1 then
                return
            end
        end
        UnitFrames.UpdateAttribute(unitTag, powerType, UnitFrames.CustomFrames[unitTag][powerType], powerValue, powerEffectiveMax, false, nil)
    end

    if UnitFrames.AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, powerType, UnitFrames.AvaCustFrames[unitTag][powerType], powerValue, powerEffectiveMax, false, nil)
    end

    -- Record state of power loss to change transparency of player frame
    if unitTag == "player" and (powerType == COMBAT_MECHANIC_FLAGS_HEALTH or powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA or powerType == COMBAT_MECHANIC_FLAGS_MOUNT_STAMINA) then
        UnitFrames.statFull[powerType] = (powerValue == powerEffectiveMax)
        UnitFrames.CustomFramesApplyInCombat()
    end

    -- If players powerValue is zero, issue new blinking event on Custom Frames
    if unitTag == "player" and powerValue == 0 and powerType ~= COMBAT_MECHANIC_FLAGS_WEREWOLF then
        UnitFrames.OnCombatEvent(nil, nil, true, nil, nil, nil, nil, COMBAT_UNIT_TYPE_PLAYER, nil, COMBAT_UNIT_TYPE_PLAYER, 0, powerType, nil, false, nil, nil, nil, nil)
    end

    -- Display skull icon for alive execute-level targets
    if unitTag == "reticleover" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH and UnitFrames.CustomFrames["reticleover"] and UnitFrames.CustomFrames["reticleover"].hostile then
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

    -- Cache all attribute visualizer effects for this unit in one batch call
    local attributeVisualCache = {}
    local results = { GetAllUnitAttributeVisualizerEffectInfo(unitTag) }
    for i = 1, #results, 6 do
        local visualType = results[i]
        local statType = results[i + 1]
        local attributeType = results[i + 2]
        local powerTypeResult = results[i + 3]
        local value = results[i + 4]

        -- Build cache key: visualType_statType_attributeType_powerType
        local cacheKey = string.format("%d_%d_%d_%d", visualType, statType, attributeType, powerTypeResult)
        attributeVisualCache[cacheKey] = value
    end

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
            ZO_StatusBar_SmoothTransition(attributeFrame.bar, adjustedBarValue, powerEffectiveMax, forceInit, nil, 250)
            if trauma then
                ZO_StatusBar_SmoothTransition(attributeFrame.trauma, powerValue, powerEffectiveMax, forceInit, nil, 250)
            end
        else
            attributeFrame.bar:SetMinMax(0, powerEffectiveMax)
            attributeFrame.bar:SetValue(adjustedBarValue)
            if trauma then
                attributeFrame.trauma:SetMinMax(0, powerEffectiveMax)
                attributeFrame.trauma:SetValue(powerValue)
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
