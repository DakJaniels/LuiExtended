-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
-- -----------------------------------------------------------------------------

local function FormatNumber(value)
    local AbbreviateNumber = LUIE.AbbreviateNumber
    local SHORTEN = UnitFrames.SV.ShortenNumbers or false
    local COMMA = true
    local formattedNumber = tostring(AbbreviateNumber(value, SHORTEN, COMMA))
    return formattedNumber
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_POWER_UPDATE listener.
-- This handler fires every time unit attribute changes.
---
--- @param unitTag string
--- @param powerIndex luaindex
--- @param powerType CombatMechanicFlags
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
function UnitFrames.OnPowerUpdate(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    -- Save Health value for future reference -- do it only for tracked unitTags that were defined on initialization
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and UnitFrames.savedHealth[unitTag] then
        UnitFrames.savedHealth[unitTag] = { powerValue, powerMax, powerEffectiveMax, UnitFrames.savedHealth[unitTag][4] or 0, UnitFrames.savedHealth[unitTag][5] or 0 }
    end

    -- DEBUG code. Normally should be commented out because it is redundant
    -- if LUIE.IsDevDebugEnabled() then
    --     if UnitFrames.DefaultFrames[unitTag] and UnitFrames.DefaultFrames[unitTag].unitTag ~= unitTag then
    --         LUIE.Debug("LUIE_DBG DF: " .. tostring(UnitFrames.DefaultFrames[unitTag].unitTag) .. " ~= " .. tostring(unitTag))
    --     end
    --     if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].unitTag ~= unitTag then
    --         LUIE.Debug("LUIE_DBG CF: " .. tostring(UnitFrames.CustomFrames[unitTag].unitTag) .. " ~= " .. tostring(unitTag))
    --     end
    --     if UnitFrames.AvaCustFrames[unitTag] and UnitFrames.AvaCustFrames[unitTag].unitTag ~= unitTag then
    --         LUIE.Debug("LUIE_DBG AF: " .. tostring(UnitFrames.AvaCustFrames[unitTag].unitTag) .. " ~= " .. tostring(unitTag))
    --     end
    -- end

    -- Update frames ( if we manually not forbade it )
    if UnitFrames.DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, powerType, UnitFrames.DefaultFrames[unitTag][powerType], powerValue, powerEffectiveMax, false, nil)
    end
    if UnitFrames.CustomFrames[unitTag] then
        if unitTag == "reticleover" and powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
            local isCritter = (UnitFrames.savedHealth.reticleover[3] <= 9)
            local isGuard = IsUnitInvulnerableGuard("reticleover")
            if (isCritter or isGuard) and powerValue >= 1 then
                return
            else
                UnitFrames.UpdateAttribute(unitTag, powerType, UnitFrames.CustomFrames[unitTag][powerType], powerValue, powerEffectiveMax, false, nil)
            end
        else
            UnitFrames.UpdateAttribute(unitTag, powerType, UnitFrames.CustomFrames[unitTag][powerType], powerValue, powerEffectiveMax, false, nil)
        end
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
        -- Hide skull when target dies
        if powerValue == 0 then
            UnitFrames.CustomFrames["reticleover"].skull:SetHidden(true)
            -- But show for _below_threshold_ level targets
        elseif 100 * powerValue / powerEffectiveMax < UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH].threshold then
            UnitFrames.CustomFrames["reticleover"].skull:SetHidden(false)
        end
    end
end

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
    if attributeFrame == nil then
        return
    end

    local pct = zo_floor(100 * powerValue / powerEffectiveMax)

    -- Update Shield / Trauma values IF this is the health bar
    local shield = (powerType == COMBAT_MECHANIC_FLAGS_HEALTH and UnitFrames.savedHealth[unitTag][4] > 0) and UnitFrames.savedHealth[unitTag][4] or nil
    local trauma = (powerType == COMBAT_MECHANIC_FLAGS_HEALTH and UnitFrames.savedHealth[unitTag][5] > 0) and UnitFrames.savedHealth[unitTag][5] or nil
    local isUnwaveringPower = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_UNWAVERING_POWER, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH) or 0)
    local isGuard = (UnitFrames.CustomFrames and UnitFrames.CustomFrames["reticleover"] and attributeFrame == UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH] and IsUnitInvulnerableGuard("reticleover"))

    -- Adjust health bar value to subtract the trauma bar value
    local adjustedBarValue = powerValue
    if powerType == COMBAT_MECHANIC_FLAGS_HEALTH and trauma then
        adjustedBarValue = powerValue - trauma
        if adjustedBarValue < 0 then
            adjustedBarValue = 0
        end
    end

    for _, label in pairs({ "label", "labelOne", "labelTwo" }) do
        if attributeFrame[label] ~= nil then
            -- Format specific to selected label
            local format = tostring(attributeFrame[label].format or UnitFrames.SV.Format)
            local str
            str = StringOnlyGSUB(format, "Percentage", tostring(pct))
            str = StringOnlyGSUB(str, "Max", FormatNumber(powerEffectiveMax))
            str = StringOnlyGSUB(str, "Current", FormatNumber(powerValue))
            str = StringOnlyGSUB(str, "+ Shield", shield and ("+ " .. FormatNumber(shield)) or "")
            str = StringOnlyGSUB(str, "- Trauma", trauma and ("- (" .. FormatNumber(trauma) .. ")") or "")
            str = StringOnlyGSUB(str, "Nothing", "")
            str = StringOnlyGSUB(str, "  ", " ")

            -- Change text
            if isGuard and label == "labelOne" then
                attributeFrame[label]:SetText(" - Invulnerable - ")
            else
                attributeFrame[label]:SetText(str)
            end

            -- Don't update if dead
            if (label == "labelOne" or label == "labelTwo") and UnitFrames.CustomFrames and UnitFrames.CustomFrames["reticleover"] and attributeFrame == UnitFrames.CustomFrames["reticleover"][COMBAT_MECHANIC_FLAGS_HEALTH] and powerValue == 0 then
                attributeFrame[label]:SetHidden(true)
            end
            -- If the unit is Invulnerable or a Guard show don't show a low HP color
            if (isUnwaveringPower == 1 and powerValue > 0) or isGuard then
                attributeFrame[label]:SetColor(unpack(attributeFrame.color or { 1, 1, 1, 1 }))
            else
                -- And color it RED if attribute value is lower than the threshold
                attributeFrame[label]:SetColor(unpack((pct < (attributeFrame.threshold or UnitFrames.defaultThreshold)) and { 1, 0.25, 0.38, 1 } or attributeFrame.color or { 1, 1, 1, 1 }))
            end
        end
    end

    -- If attribute has also custom statusBar, update its value
    if attributeFrame.bar ~= nil then
        if UnitFrames.SV.CustomSmoothBar and not isTraumaFlag then
            -- Make it twice faster then default UI ones: last argument .085
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

        -- If there is an invulnerable bar on this frame, then modify it if based on if Unwavering Power is active on the frame
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
    end
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED listener.
---
--- @param eventId integer
--- @param unitTag string
--- @param unitAttributeVisual UnitAttributeVisual
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
--- @param value number
--- @param maxValue number
--- @param sequenceId integer
function UnitFrames.OnVisualizationAdded(eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        UnitFrames.UpdateShield(unitTag, value, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        UnitFrames.UpdateTrauma(unitTag, value, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
        UnitFrames.UpdateRegen(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
        UnitFrames.UpdateStat(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER then
        UnitFrames.UpdateInvulnerable(unitTag)
    end
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED listener.
---
--- @param eventId integer
--- @param unitTag string
--- @param unitAttributeVisual UnitAttributeVisual
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
--- @param value number
--- @param maxValue number
--- @param sequenceId integer
function UnitFrames.OnVisualizationRemoved(eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        UnitFrames.UpdateShield(unitTag, 0, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        UnitFrames.UpdateTrauma(unitTag, 0, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
        UnitFrames.UpdateRegen(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
        UnitFrames.UpdateStat(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER then
        UnitFrames.UpdateInvulnerable(unitTag)
    end
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED listener.
---
--- @param eventId integer
--- @param unitTag string
--- @param unitAttributeVisual UnitAttributeVisual
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
--- @param oldValue number
--- @param newValue number
--- @param oldMaxValue number
--- @param newMaxValue number
--- @param sequenceId integer
function UnitFrames.OnVisualizationUpdated(eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        UnitFrames.UpdateShield(unitTag, newValue, newMaxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        UnitFrames.UpdateTrauma(unitTag, newValue, newMaxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER then
        UnitFrames.UpdateRegen(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_STAT or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_STAT then
        UnitFrames.UpdateStat(unitTag, statType, attributeType, powerType)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER then
        UnitFrames.UpdateInvulnerable(unitTag)
    end
end

-- -----------------------------------------------------------------------------
-- Updates Invulnerable Overlay for given unit.
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
---
--- @param unitTag string
function UnitFrames.UpdateInvulnerable(unitTag)
    if UnitFrames.savedHealth[unitTag] == nil then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("LUIE DEBUG: Stored health is nil: ", unitTag)
        -- end
        return
    end

    local healthValue, _, healthEffectiveMax, _ = unpack(UnitFrames.savedHealth[unitTag])
    -- Update frames
    if UnitFrames.DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
    end
    if UnitFrames.CustomFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
    end
    if UnitFrames.AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
    end
end

-- -----------------------------------------------------------------------------
-- Updates shield value for given unit.
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
--- @param unitTag string
--- @param value number
--- @param maxValue number
function UnitFrames.UpdateShield(unitTag, value, maxValue)
    if UnitFrames.savedHealth[unitTag] == nil then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("LUIE DEBUG: Stored health is nil: ", unitTag, " | Shield Value: ", value, " | Shield Max: ", maxValue)
        -- end
        return
    end

    UnitFrames.savedHealth[unitTag][4] = value

    local healthValue, _, healthEffectiveMax, _ = unpack(UnitFrames.savedHealth[unitTag])
    -- Update frames
    if UnitFrames.DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        UnitFrames.UpdateShieldBar(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
    if UnitFrames.CustomFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        UnitFrames.UpdateShieldBar(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
    if UnitFrames.AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        UnitFrames.UpdateShieldBar(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
end

-- -----------------------------------------------------------------------------
-- Updates trauma value for given unit.
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
--- @param unitTag string
--- @param value number
--- @param maxValue number
function UnitFrames.UpdateTrauma(unitTag, value, maxValue)
    if UnitFrames.savedHealth[unitTag] == nil then
        return
    end

    UnitFrames.savedHealth[unitTag][5] = value

    local healthValue, _, healthEffectiveMax, _ = unpack(UnitFrames.savedHealth[unitTag])
    -- Update frames
    if UnitFrames.DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        UnitFrames.UpdateTraumaBar(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end
    if UnitFrames.CustomFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        UnitFrames.UpdateTraumaBar(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end
    if UnitFrames.AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        UnitFrames.UpdateTraumaBar(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end
end

-- -----------------------------------------------------------------------------
-- Here actual update of shield bar on attribute is done
---
--- @param attributeFrame table|{shield:StatusBarControl,shieldbackdrop:BackdropControl}
--- @param shieldValue number
--- @param healthEffectiveMax number
function UnitFrames.UpdateShieldBar(attributeFrame, shieldValue, healthEffectiveMax)
    if attributeFrame == nil or attributeFrame.shield == nil then
        return
    end

    local hideShield = not (shieldValue > 0)

    if hideShield then
        attributeFrame.shield:SetValue(0)
    else
        if UnitFrames.SV.CustomSmoothBar then
            -- Make it twice faster then default UI ones: last argument .085
            ZO_StatusBar_SmoothTransition(attributeFrame.shield, shieldValue, healthEffectiveMax, false, nil, 250)
        else
            attributeFrame.shield:SetMinMax(0, healthEffectiveMax)
            attributeFrame.shield:SetValue(shieldValue)
        end
    end

    attributeFrame.shield:SetHidden(hideShield)
    if attributeFrame.shieldbackdrop then
        attributeFrame.shieldbackdrop:SetHidden(hideShield)
    end
end

-- -----------------------------------------------------------------------------
-- Here actual update of trauma bar on attribute is done
---
--- @param attributeFrame table|{trauma:StatusBarControl}
--- @param traumaValue number
--- @param healthValue number
--- @param healthEffectiveMax number
function UnitFrames.UpdateTraumaBar(attributeFrame, traumaValue, healthValue, healthEffectiveMax)
    if attributeFrame == nil or attributeFrame.trauma == nil then
        return
    end

    local hideTrauma = not (traumaValue > 0)

    if hideTrauma then
        attributeFrame.trauma:SetValue(0)
    else
        -- We don't use a smooth bar transition here - this immediately replaces the HP bar and the HP value smooth transitions
        attributeFrame.trauma:SetMinMax(0, healthEffectiveMax)
        attributeFrame.trauma:SetValue(healthValue)
    end

    attributeFrame.trauma:SetHidden(hideTrauma)
end

-- -----------------------------------------------------------------------------
-- Reroutes call for regen/degen animation for given unit.
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
--- @param unitTag string
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
function UnitFrames.UpdateRegen(unitTag, statType, attributeType, powerType)
    if powerType ~= COMBAT_MECHANIC_FLAGS_HEALTH then
        return
    end

    -- Calculate actual value, and fallback to 0 if we call this function with nil parameters
    local value1 = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, statType, attributeType, powerType) or 0)
    local value2 = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, statType, attributeType, powerType) or 0)
    if value1 < 0 then
        value1 = 1
    end
    if value2 > 0 then
        value2 = -1
    end
    local value = value1 + value2

    -- Here we assume, that every unitTag entry in tables has COMBAT_MECHANIC_FLAGS_HEALTH key
    if UnitFrames.DefaultFrames[unitTag] and UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DisplayRegen(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        UnitFrames.DisplayRegen(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        UnitFrames.DisplayRegen(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        UnitFrames.DisplayRegen(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        UnitFrames.DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        UnitFrames.DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        UnitFrames.DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
    if UnitFrames.AvaCustFrames[unitTag] and UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        UnitFrames.DisplayRegen(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        UnitFrames.DisplayRegen(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        UnitFrames.DisplayRegen(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        UnitFrames.DisplayRegen(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
end

-- -----------------------------------------------------------------------------
-- Performs actual display of animation control if any
---
--- @param control {animation:AnimationObject, timeline:AnimationTimeline}|object
--- @param isShown boolean
function UnitFrames.DisplayRegen(control, isShown)
    if control == nil then
        return
    end

    control:SetHidden(not isShown)
    if isShown then
        -- We restart the animation here only if its not already playing (prevents sharp fades mid-animation)
        if control.animation:IsPlaying() then
            return
        end
        control.timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
        control.timeline:PlayFromStart()
    else
        control.timeline:SetPlaybackLoopsRemaining(0)
    end
end

-- -----------------------------------------------------------------------------
-- Updates decreasedArmor texture for given unit.
-- While this applicable only to custom frames, we do not need to split this function into 2 different ones
-- Called from EVENT_UNIT_ATTRIBUTE_VISUAL_* listeners.
--- @param unitTag string
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
function UnitFrames.UpdateStat(unitTag, statType, attributeType, powerType)
    -- Build a list of UI controls to hold this statType on different UnitFrames lists
    local statControls = {}

    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][powerType] and UnitFrames.CustomFrames[unitTag][powerType].stat and UnitFrames.CustomFrames[unitTag][powerType].stat[statType] then
        table.insert(statControls, UnitFrames.CustomFrames[unitTag][powerType].stat[statType])
    end
    if UnitFrames.AvaCustFrames[unitTag] and UnitFrames.AvaCustFrames[unitTag][powerType] and UnitFrames.AvaCustFrames[unitTag][powerType].stat and UnitFrames.AvaCustFrames[unitTag][powerType].stat[statType] then
        table.insert(statControls, UnitFrames.AvaCustFrames[unitTag][powerType].stat[statType])
    end

    -- If we have a control, proceed next
    if #statControls > 0 then
        -- Calculate actual value, and fallback to 0 if we call this function with nil parameters
        local value = (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, statType, attributeType, powerType) or 0) + (GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, statType, attributeType, powerType) or 0)

        for _, control in pairs(statControls) do
            -- Hide proper controls if they exist
            if control.dec then
                control.dec:SetHidden(value >= 0)
            end
            if control.inc then
                control.inc:SetHidden(value <= 0)
            end
        end
    end
end

-- -----------------------------------------------------------------------------
