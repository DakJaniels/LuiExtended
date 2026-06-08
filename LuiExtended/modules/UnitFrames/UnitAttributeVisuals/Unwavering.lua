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
local UnwaveringModule = LUIE_UnitAttributeVisualizerModuleBase:Subclass()

function UnwaveringModule:IsRelevant(unitAttributeVisual, statType, attributeType, powerType)
    return unitAttributeVisual == ATTRIBUTE_VISUAL_UNWAVERING_POWER
end

function UnwaveringModule:OnUnitChanged(unitTag)
    if not DoesUnitExist(unitTag) then
        return
    end

    -- Reinitialize unwavering power visual for the new unit
    self:GetInitialValueAndMarkMostRecent(ATTRIBUTE_VISUAL_UNWAVERING_POWER, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, unitTag)
    self:UpdateInvulnerable(unitTag)
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

    self:ForEachUnitFrameTable(unitTag, function (frameTable)
        if frameTable[COMBAT_MECHANIC_FLAGS_HEALTH] then
            UnitFrames.UpdateAttribute(unitTag, COMBAT_MECHANIC_FLAGS_HEALTH, frameTable[COMBAT_MECHANIC_FLAGS_HEALTH], healthValue, healthEffectiveMax, false, false)
        end
    end)
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

LUIE_UnwaveringModule = UnwaveringModule
UnitFrames.VisualizerModuleClasses.UnwaveringModule = UnwaveringModule
UnitFrames.VisualizerModules.UnwaveringModule = UnwaveringModule

return UnwaveringModule
