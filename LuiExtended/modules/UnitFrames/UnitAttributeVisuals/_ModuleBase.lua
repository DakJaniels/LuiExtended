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

--- Base class for Unit Attribute Visualizer modules
--- Provides the contract that all visualizer modules must implement
--- @class LUIE_UnitAttributeVisualizerModuleBase : ZO_Object
LUIE_UnitAttributeVisualizerModuleBase = ZO_Object:Subclass()

--- Creates a new instance of a module
--- @return LUIE_UnitAttributeVisualizerModuleBase
function LUIE_UnitAttributeVisualizerModuleBase:New()
    return ZO_Object.New(self)
end

--- Sets the owner (parent visualizer) for this module
--- @param owner table
function LUIE_UnitAttributeVisualizerModuleBase:SetOwner(owner)
    self.owner = owner
end

--- Gets the most recent sequence ID for a given visual type combination
--- Used to prevent processing old/stale events
--- @param visualType UnitAttributeVisual
--- @param stat DerivedStats
--- @param attribute Attributes
--- @param powerType CombatMechanicFlags
--- @return integer|nil
function LUIE_UnitAttributeVisualizerModuleBase:GetMostRecentUpdate(visualType, stat, attribute, powerType)
    if self.updateRecencyInfo then
        local visualTypeInfo = self.updateRecencyInfo[visualType]
        if visualTypeInfo then
            local statInfo = visualTypeInfo[stat]
            if statInfo then
                local attributeInfo = statInfo[attribute]
                if attributeInfo then
                    local existingSequenceId = attributeInfo[powerType]
                    return existingSequenceId
                end
            end
        end
    end
end

--- Sets the most recent sequence ID for a given visual type combination
--- @param visualType UnitAttributeVisual
--- @param stat DerivedStats
--- @param attribute Attributes
--- @param powerType CombatMechanicFlags
--- @param sequenceId integer|nil
function LUIE_UnitAttributeVisualizerModuleBase:SetMostRecentUpdate(visualType, stat, attribute, powerType, sequenceId)
    if not self.updateRecencyInfo then
        self.updateRecencyInfo = {}
    end

    local visualTypeInfo = self.updateRecencyInfo[visualType]
    if not visualTypeInfo then
        visualTypeInfo = {}
        self.updateRecencyInfo[visualType] = visualTypeInfo
    end

    local statInfo = visualTypeInfo[stat]
    if not statInfo then
        statInfo = {}
        visualTypeInfo[stat] = statInfo
    end

    local attributeInfo = statInfo[attribute]
    if not attributeInfo then
        attributeInfo = {}
        statInfo[attribute] = attributeInfo
    end

    attributeInfo[powerType] = sequenceId
end

--- Called when the unit the unitTag points to has changed (override in subclasses if needed)
function LUIE_UnitAttributeVisualizerModuleBase:OnUnitChanged()
    -- Override in subclasses if needed
end

--- Called when gamepad preferred mode changes (override in subclasses if needed)
function LUIE_UnitAttributeVisualizerModuleBase:ApplyPlatformStyle()
    -- Override in subclasses if needed
end

--- Called when unit frames update alpha values due to range changes (override in subclasses if needed)
--- @param isNearby boolean
function LUIE_UnitAttributeVisualizerModuleBase:DoAlphaUpdate(isNearby)
    -- Override in subclasses if needed
end

-- -----------------------------------------------------------------------------
-- Abstract Method Declarations (MUST be implemented in subclasses)
-- -----------------------------------------------------------------------------

LUIE_UnitAttributeVisualizerModuleBase.IsRelevant = LUIE_UnitAttributeVisualizerModuleBase:MUST_IMPLEMENT()
LUIE_UnitAttributeVisualizerModuleBase.OnVisualizationAdded = LUIE_UnitAttributeVisualizerModuleBase:MUST_IMPLEMENT()
LUIE_UnitAttributeVisualizerModuleBase.OnVisualizationRemoved = LUIE_UnitAttributeVisualizerModuleBase:MUST_IMPLEMENT()
LUIE_UnitAttributeVisualizerModuleBase.OnVisualizationUpdated = LUIE_UnitAttributeVisualizerModuleBase:MUST_IMPLEMENT()
