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
local RegenerationModule = LUIE_UnitAttributeVisualizerModuleBase:New()

UnitFrames.VisualizerModules.RegenerationModule = RegenerationModule

function RegenerationModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return unitAttributeVisual == ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER or unitAttributeVisual == ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER
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
        self:DisplayRegen(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        self:DisplayRegen(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        self:DisplayRegen(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        self:DisplayRegen(UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
    if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        self:DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        self:DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        self:DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        self:DisplayRegen(UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
    if UnitFrames.AvaCustFrames[unitTag] and UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
        self:DisplayRegen(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen1, value > 0)
        self:DisplayRegen(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].regen2, value > 0)
        self:DisplayRegen(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen1, value < 0)
        self:DisplayRegen(UnitFrames.AvaCustFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].degen2, value < 0)
    end
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
