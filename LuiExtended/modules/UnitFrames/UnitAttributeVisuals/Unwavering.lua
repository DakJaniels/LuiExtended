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

--- Module for handling Unwavering Power (invulnerability) visuals
--- @class LUIE_UnwaveringModule : LUIE_UnitAttributeVisualizerModuleBase
local UnwaveringModule = LUIE_UnitAttributeVisualizerModuleBase:New()

UnitFrames.VisualizerModules.UnwaveringModule = UnwaveringModule

function UnwaveringModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER
end

-- -----------------------------------------------------------------------------
-- Internal Implementation
-- -----------------------------------------------------------------------------

--- Updates invulnerable overlay for given unit
--- @param unitTag string
function UnwaveringModule:UpdateInvulnerable(unitTag)
    if UnitFrames.savedHealth[unitTag] == nil then
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
-- Event Handlers
-- -----------------------------------------------------------------------------

function UnwaveringModule:OnVisualizationAdded(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdateInvulnerable(unitTag)
end

function UnwaveringModule:OnVisualizationRemoved(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    self:UpdateInvulnerable(unitTag)
end

function UnwaveringModule:OnVisualizationUpdated(unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    self:UpdateInvulnerable(unitTag)
end
