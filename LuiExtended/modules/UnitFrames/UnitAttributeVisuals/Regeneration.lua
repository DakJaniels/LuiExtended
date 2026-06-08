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

--- Module for handling increased/decreased regeneration power visuals
--- @class LUIE_RegenerationModule : LUIE_UnitAttributeVisualizerModuleBase
local RegenerationModule = LUIE_UnitAttributeVisualizerModuleBase:Subclass()

function RegenerationModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER
end

function RegenerationModule:OnUnitChanged(unitTag)
    if not DoesUnitExist(unitTag) then
        return
    end

    -- Reinitialize regen visuals for all power types
    -- Health
    self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, unitTag)
    self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, unitTag)
    self:UpdateRegen(unitTag, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)

    -- Magicka
    self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, COMBAT_MECHANIC_FLAGS_MAGICKA, unitTag)
    self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, COMBAT_MECHANIC_FLAGS_MAGICKA, unitTag)
    self:UpdateRegen(unitTag, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, COMBAT_MECHANIC_FLAGS_MAGICKA)

    -- Stamina
    self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, COMBAT_MECHANIC_FLAGS_STAMINA, unitTag)
    self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, COMBAT_MECHANIC_FLAGS_STAMINA, unitTag)
    self:UpdateRegen(unitTag, STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, COMBAT_MECHANIC_FLAGS_STAMINA)
end

-- -----------------------------------------------------------------------------
-- Internal Implementation
-- -----------------------------------------------------------------------------

--- Performs actual display of animation control
--- @param control {animation:AnimationObject, timeline:AnimationTimeline}|object
--- @param isShown boolean
function RegenerationModule:DisplayRegen(control, isShown)
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

--- Updates regen/degen animation for given unit
--- @param unitTag string
--- @param statType DerivedStats
--- @param attributeType Attributes
--- @param powerType CombatMechanicFlags
function RegenerationModule:UpdateRegen(unitTag, statType, attributeType, powerType)
    -- Support all power types (health, magicka, stamina)
    if  powerType ~= COMBAT_MECHANIC_FLAGS_HEALTH
    and powerType ~= COMBAT_MECHANIC_FLAGS_MAGICKA
    and powerType ~= COMBAT_MECHANIC_FLAGS_STAMINA then
        return
    end

    local value1 = UnitFrames.GetAttributeVisualEffectValue(unitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, statType, attributeType, powerType)
    local value2 = UnitFrames.GetAttributeVisualEffectValue(unitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, statType, attributeType, powerType)

    if value1 < 0 then
        value1 = 1
    end
    if value2 > 0 then
        value2 = -1
    end
    local value = value1 + value2

    self:ForEachPowerEntry(unitTag, powerType, function (powerEntry)
        self:DisplayRegen(powerEntry.regen1, value > 0)
        self:DisplayRegen(powerEntry.regen2, value > 0)
        self:DisplayRegen(powerEntry.degen1, value < 0)
        self:DisplayRegen(powerEntry.degen2, value < 0)
    end)
end

-- -----------------------------------------------------------------------------
-- Event Handlers
-- -----------------------------------------------------------------------------

function RegenerationModule:OnVisualizationAdded(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdateRegen(unitTag, statType, attributeType, powerType)
end

function RegenerationModule:OnVisualizationRemoved(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdateRegen(unitTag, statType, attributeType, powerType)
end

function RegenerationModule:OnVisualizationUpdated(unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    self:UpdateRegen(unitTag, statType, attributeType, powerType)
end

LUIE_RegenerationModule = RegenerationModule
UnitFrames.VisualizerModuleClasses.RegenerationModule = RegenerationModule
UnitFrames.VisualizerModules.RegenerationModule = RegenerationModule

return RegenerationModule
