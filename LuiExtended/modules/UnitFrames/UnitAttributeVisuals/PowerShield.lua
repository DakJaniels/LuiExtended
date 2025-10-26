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
local PowerShieldModule = LUIE_UnitAttributeVisualizerModuleBase:New()

UnitFrames.VisualizerModules.PowerShieldModule = PowerShieldModule

function PowerShieldModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return unitAttributeVisual == ATTRIBUTE_VISUAL_POWER_SHIELDING
        or unitAttributeVisual == ATTRIBUTE_VISUAL_TRAUMA
        or unitAttributeVisual == ATTRIBUTE_VISUAL_NO_HEALING
end

-- -----------------------------------------------------------------------------
-- Internal Implementation
-- -----------------------------------------------------------------------------

--- Updates shield value for given unit
--- @param unitTag string
--- @param value number
--- @param maxValue number
function PowerShieldModule:UpdateShield(unitTag, value, maxValue)
    if UnitFrames.savedHealth[unitTag] == nil then
        return
    end

    UnitFrames.savedHealth[unitTag][4] = value

    local healthValue, _, healthEffectiveMax, _ = unpack(UnitFrames.savedHealth[unitTag])

    -- Update frames
    if UnitFrames.DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        self:UpdateShieldBar(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
    if UnitFrames.CustomFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        self:UpdateShieldBar(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
    if UnitFrames.AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        self:UpdateShieldBar(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthEffectiveMax)
    end
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
    else
        if UnitFrames.SV.CustomSmoothBar then
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

--- Updates trauma value for given unit
--- @param unitTag string
--- @param value number
--- @param maxValue number
function PowerShieldModule:UpdateTrauma(unitTag, value, maxValue)
    if UnitFrames.savedHealth[unitTag] == nil then
        return
    end

    UnitFrames.savedHealth[unitTag][5] = value

    local healthValue, _, healthEffectiveMax, _ = unpack(UnitFrames.savedHealth[unitTag])

    -- Update frames
    if UnitFrames.DefaultFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        self:UpdateTraumaBar(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end
    if UnitFrames.CustomFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        self:UpdateTraumaBar(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end
    if UnitFrames.AvaCustFrames[unitTag] then
        UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, true, false)
        self:UpdateTraumaBar(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH], value, healthValue, healthEffectiveMax)
    end

    -- Update no-healing overlay inner ring when trauma changes
    local noHealingValue = GetUnitAttributeVisualizerEffectInfo(unitTag, ATTRIBUTE_VISUAL_NO_HEALING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH) or 0
    if noHealingValue > 0 then
        self:UpdateNoHealing(unitTag, noHealingValue)
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
    local healthValue, _, healthEffectiveMax, _ = unpack(UnitFrames.savedHealth[unitTag])
    local traumaValue = UnitFrames.savedHealth[unitTag][5] or 0

    -- Calculate fake health (health minus trauma)
    local fakeHealthValue = healthValue - traumaValue
    if fakeHealthValue < 0 then
        fakeHealthValue = 0
    end

    -- Helper to update no-healing overlays (inner/outer rings + stripe) with fade animation
    local function updateNoHealingOverlays(frame)
        if not frame then return end

        local inner = frame.noHealingInner
        local outer = frame.noHealingOuter
        local stripe = frame.noHealingStripe
        local fadeAnim = frame.noHealingFadeAnimation

        if inner and outer then
            if isActive then
                -- Set values first (before showing)
                outer:SetMinMax(0, healthEffectiveMax)
                outer:SetValue(healthValue)
                inner:SetMinMax(0, healthEffectiveMax)
                inner:SetValue(fakeHealthValue)

                -- Show controls and fade in
                inner:SetHidden(false)
                outer:SetHidden(false)
                if stripe then
                    stripe:SetHidden(false)
                end

                if fadeAnim and not fadeAnim:IsPlaying() then
                    fadeAnim:PlayForward()
                end
            else
                -- Fade out, then hide
                if fadeAnim then
                    fadeAnim:PlayBackward()
                else
                    inner:SetHidden(true)
                    outer:SetHidden(true)
                    if stripe then
                        stripe:SetHidden(true)
                    end
                end
            end
        end
    end

    -- Update frames
    if UnitFrames.DefaultFrames[unitTag] and UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        updateNoHealingOverlays(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH])
    end

    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        updateNoHealingOverlays(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH])
    end

    if UnitFrames.AvaCustFrames[unitTag] and UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        updateNoHealingOverlays(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH])
    end
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
