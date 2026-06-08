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

--- Module for handling Power Shields, Trauma, and No-Healing overlays
--- @class LUIE_PowerShieldModule : LUIE_UnitAttributeVisualizerModuleBase
local PowerShieldModule = LUIE_UnitAttributeVisualizerModuleBase:Subclass()

function PowerShieldModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING
        or unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA
        or unitAttributeVisual == ATTRIBUTE_VISUAL_NO_HEALING
end

function PowerShieldModule:OnUnitChanged(unitTag)
    if not DoesUnitExist(unitTag) then
        return
    end

    -- Reinitialize all relevant visuals for the new unit using GetInitialValueAndMarkMostRecent
    -- This properly marks sequence IDs to prevent stale events
    local shieldValue, shieldMaxValue = self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, unitTag)
    self:UpdateShield(unitTag, shieldValue, shieldMaxValue)

    local traumaValue, traumaMaxValue = self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_TRAUMA, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, unitTag)
    self:UpdateTrauma(unitTag, traumaValue, traumaMaxValue)

    local noHealingValue = self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_NO_HEALING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, unitTag)
    self:UpdateNoHealing(unitTag, noHealingValue)
end

-- -----------------------------------------------------------------------------
-- Internal Implementation
-- -----------------------------------------------------------------------------

--- Health from GetUnitPower when the unit exists so overlay updates stay in sync with
--- coalesced EVENT_POWER_UPDATE (UAV events can fire before savedHealth is flushed).
--- @param unitTag string
--- @return integer healthValue, integer healthEffectiveMax
local function GetHealthPowerForUnit(unitTag)
    if DoesUnitExist(unitTag) then
        local healthValue, _, healthEffectiveMax = GetUnitPower(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
        return healthValue, healthEffectiveMax
    end
    local saved = UnitFrames.savedHealth[unitTag]
    if saved then
        return saved[1], saved[3]
    end
    return 0, 1
end

--- Updates shield value for given unit
--- @param unitTag string
--- @param value number
--- @param maxValue number
function PowerShieldModule:UpdateShield(unitTag, value, maxValue)
    if UnitFrames.savedHealth[unitTag] == nil then
        return
    end

    UnitFrames.savedHealth[unitTag][4] = value

    local healthValue, healthEffectiveMax = GetHealthPowerForUnit(unitTag)

    self:ForEachUnitFrameTable(unitTag, function (frameTable)
        local healthFrame = frameTable[COMBAT_MECHANIC_FLAGS_HEALTH]
        if healthFrame then
            UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, healthFrame, healthValue, healthEffectiveMax, false, false)
            self:UpdateShieldBar(healthFrame, value, healthEffectiveMax)
        end
    end)
end

--- Here actual update of shield bar on attribute is done
--- @param attributeFrame table|{shield:StatusBarControl,shieldbackdrop:BackdropControl}
--- @param shieldValue number
--- @param healthEffectiveMax number
function PowerShieldModule:UpdateShieldBar(attributeFrame, shieldValue, healthEffectiveMax)
    if attributeFrame == nil or attributeFrame.shield == nil then
        return
    end

    local hideShield = not (shieldValue > 0)

    if hideShield then
        attributeFrame.shield:SetValue(0)
        attributeFrame.shield:SetHidden(true)
        if attributeFrame.shieldbackdrop then
            attributeFrame.shieldbackdrop:SetHidden(true)
        end
    else
        -- Set min/max before unhiding
        attributeFrame.shield:SetMinMax(0, healthEffectiveMax)

        -- If smooth bar enabled, let ZO_StatusBar_SmoothTransition handle value setting with animation
        -- Otherwise set value directly for instant update
        if UnitFrames.SV.CustomSmoothBar then
            attributeFrame.shield:SetHidden(false)
            if attributeFrame.shieldbackdrop then
                attributeFrame.shieldbackdrop:SetHidden(false)
            end
            ZO_StatusBar_SmoothTransition(attributeFrame.shield, shieldValue, healthEffectiveMax, false, nil, 250)
        else
            attributeFrame.shield:SetValue(shieldValue)
            attributeFrame.shield:SetHidden(false)
            if attributeFrame.shieldbackdrop then
                attributeFrame.shieldbackdrop:SetHidden(false)
            end
        end
    end
end

--- Updates trauma value for given unit
--- @param unitTag string
--- @param value number
--- @param maxValue number
function PowerShieldModule:UpdateTrauma(unitTag, value, maxValue)
    if UnitFrames.savedHealth[unitTag] == nil then
        return
    end

    UnitFrames.savedHealth[unitTag][5] = value

    local healthValue, healthEffectiveMax = GetHealthPowerForUnit(unitTag)

    self:ForEachUnitFrameTable(unitTag, function (frameTable)
        local healthFrame = frameTable[COMBAT_MECHANIC_FLAGS_HEALTH]
        if healthFrame then
            UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, healthFrame, healthValue, healthEffectiveMax, true, false)
            self:UpdateTraumaBar(healthFrame, value, healthValue, healthEffectiveMax)
        end
    end)

    -- Update no-healing overlay inner ring when trauma changes
    local noHealingValue = UnitFrames.GetAttributeVisualEffectValue(unitTag, ATTRIBUTE_VISUAL_NO_HEALING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)

    if noHealingValue > 0 then
        self:UpdateNoHealing(unitTag, noHealingValue)
    else
        self:UpdateNoHealing(unitTag, 0)
    end
end

--- Here actual update of trauma bar on attribute is done
--- @param attributeFrame table|{trauma:StatusBarControl}
--- @param traumaValue number
--- @param healthValue number
--- @param healthEffectiveMax number
function PowerShieldModule:UpdateTraumaBar(attributeFrame, traumaValue, healthValue, healthEffectiveMax)
    if attributeFrame == nil or attributeFrame.trauma == nil then
        return
    end

    local hideTrauma = not (traumaValue > 0)

    if hideTrauma then
        attributeFrame.trauma:SetValue(0)
    else
        attributeFrame.trauma:SetMinMax(0, healthEffectiveMax)
        attributeFrame.trauma:SetValue(healthValue)
    end

    attributeFrame.trauma:SetHidden(hideTrauma)
end

--- Updates no-healing overlay for given unit
--- @param unitTag string
--- @param value number
function PowerShieldModule:UpdateNoHealing(unitTag, value)
    if UnitFrames.savedHealth[unitTag] == nil then
        return
    end

    local isActive = value > 0
    local healthValue, healthEffectiveMax = GetHealthPowerForUnit(unitTag)
    local traumaValue = UnitFrames.savedHealth[unitTag][5] or 0

    -- Helper to update no-healing overlays with fade animation
    -- Works like shield overlay: actively sets value to match health
    local function updateNoHealingOverlays(frame)
        if not frame then return end

        local overlay = frame.noHealingOverlay
        local stripe = frame.noHealingStripe
        local fadeAnim = frame.noHealingFadeAnimation

        if overlay then
            if isActive then
                -- Set overlay min/max
                overlay:SetMinMax(0, healthEffectiveMax)
                if stripe then
                    stripe:SetMinMax(0, healthEffectiveMax)
                end

                -- Show overlay and stripe, fade in
                overlay:SetHidden(false)
                if stripe then
                    stripe:SetHidden(false)
                end

                if fadeAnim and not fadeAnim:IsPlaying() then
                    fadeAnim:PlayForward()
                end

                -- Apply smooth transition if enabled, otherwise set value directly
                if UnitFrames.SV.CustomSmoothBar then
                    ZO_StatusBar_SmoothTransition(overlay, healthValue, healthEffectiveMax, false, nil, 250)
                    if stripe then
                        ZO_StatusBar_SmoothTransition(stripe, healthValue, healthEffectiveMax, false, nil, 250)
                    end
                else
                    overlay:SetValue(healthValue)
                    if stripe then
                        stripe:SetValue(healthValue)
                    end
                end
            else
                -- Fade out, then hide
                if fadeAnim then
                    fadeAnim:PlayBackward()
                else
                    overlay:SetValue(0)
                    overlay:SetHidden(true)
                    if stripe then
                        stripe:SetValue(0)
                        stripe:SetHidden(true)
                    end
                end
            end
        end
    end

    self:ForEachPowerEntry(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, function (frame)
        updateNoHealingOverlays(frame)
    end)
end

-- -----------------------------------------------------------------------------
-- Event Handlers
-- -----------------------------------------------------------------------------

function PowerShieldModule:OnVisualizationAdded(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        self:UpdateShield(unitTag, value, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        self:UpdateTrauma(unitTag, value, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_NO_HEALING then
        self:UpdateNoHealing(unitTag, value)
    end
end

function PowerShieldModule:OnVisualizationRemoved(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        self:UpdateShield(unitTag, 0, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        self:UpdateTrauma(unitTag, 0, maxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_NO_HEALING then
        self:UpdateNoHealing(unitTag, 0)
    end
end

function PowerShieldModule:OnVisualizationUpdated(unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    if unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING then
        self:UpdateShield(unitTag, newValue, newMaxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA then
        self:UpdateTrauma(unitTag, newValue, newMaxValue)
    elseif unitAttributeVisual == ATTRIBUTE_VISUAL_NO_HEALING then
        self:UpdateNoHealing(unitTag, newValue)
    end
end

LUIE_PowerShieldModule = PowerShieldModule
UnitFrames.VisualizerModuleClasses.PowerShieldModule = PowerShieldModule
UnitFrames.VisualizerModules.PowerShieldModule = PowerShieldModule

return PowerShieldModule
