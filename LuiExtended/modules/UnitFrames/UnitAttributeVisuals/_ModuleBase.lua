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
--- @field New fun(self, ...): LUIE_UnitAttributeVisualizerModuleBase
LUIE_UnitAttributeVisualizerModuleBase = ZO_Object:Subclass()

local g_numModulesCreated = 0

--- Creates a new instance of a module
--- @param ... self
--- @return LUIE_UnitAttributeVisualizerModuleBase
function LUIE_UnitAttributeVisualizerModuleBase:New(...)
    --- @class LUIE_UnitAttributeVisualizerModuleBase
    local module = ZO_Object.New(self)
    g_numModulesCreated = g_numModulesCreated + 1
    module.moduleId = g_numModulesCreated
    module:Initialize(...)
    return module
end

--- Gets the unique module ID for this instance
--- @return integer
function LUIE_UnitAttributeVisualizerModuleBase:GetModuleId()
    return self.moduleId
end

--- Sets the owner (parent visualizer) for this module
--- @param owner table
function LUIE_UnitAttributeVisualizerModuleBase:SetOwner(owner)
    self.owner = owner
end

--- Gets the owner (parent visualizer) for this module
--- @return table
function LUIE_UnitAttributeVisualizerModuleBase:GetOwner()
    return self.owner
end

--- Gets the unitTag this module's owner is managing
--- @return string|nil
function LUIE_UnitAttributeVisualizerModuleBase:GetUnitTag()
    return self.owner and self.owner:GetUnitTag() or nil
end

--- Gets the most recent sequence ID for a given visual type combination
--- Used to prevent processing old/stale events
--- @param visualType UnitAttributeVisual
--- @param stat DerivedStats
--- @param attribute Attributes
--- @param powerType CombatMechanicFlags
--- @param unitTag string|nil Optional unitTag (if not provided, uses owner's unitTag)
--- @return integer|nil
function LUIE_UnitAttributeVisualizerModuleBase:GetMostRecentUpdate(visualType, stat, attribute, powerType, unitTag)
    -- Allow explicit unitTag parameter for singleton modules shared across visualizers
    unitTag = unitTag or self:GetUnitTag()
    if not unitTag then return nil end

    if self.updateRecencyInfo then
        local unitInfo = self.updateRecencyInfo[unitTag]
        if unitInfo then
            local visualTypeInfo = unitInfo[visualType]
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
end

--- Sets the most recent sequence ID for a given visual type combination
--- @param visualType UnitAttributeVisual
--- @param stat DerivedStats
--- @param attribute Attributes
--- @param powerType CombatMechanicFlags
--- @param sequenceId integer|nil
--- @param unitTag string|nil Optional unitTag (if not provided, uses owner's unitTag)
function LUIE_UnitAttributeVisualizerModuleBase:SetMostRecentUpdate(visualType, stat, attribute, powerType, sequenceId, unitTag)
    -- Allow explicit unitTag parameter for singleton modules shared across visualizers
    unitTag = unitTag or self:GetUnitTag()
    if not unitTag then return end

    if not self.updateRecencyInfo then
        self.updateRecencyInfo = {}
    end

    local unitInfo = self.updateRecencyInfo[unitTag]
    if not unitInfo then
        unitInfo = {}
        self.updateRecencyInfo[unitTag] = unitInfo
    end

    local visualTypeInfo = unitInfo[visualType]
    if not visualTypeInfo then
        visualTypeInfo = {}
        unitInfo[visualType] = visualTypeInfo
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

--- Gets the initial value for a visual and marks the most recent sequence ID
--- This is the proper way to initialize visuals on unit changes
--- @param visualType UnitAttributeVisual
--- @param stat DerivedStats
--- @param attribute Attributes
--- @param powerType CombatMechanicFlags
--- @param unitTag string|nil Optional unitTag (required for singleton modules)
--- @return number value, number maxValue
function LUIE_UnitAttributeVisualizerModuleBase:GetInitialValueAndMarkMostRecent(visualType, stat, attribute, powerType, unitTag)
    unitTag = unitTag or self:GetUnitTag()
    if not unitTag then return 0, 0 end

    local value, maxValue, sequenceId = GetUnitAttributeVisualizerEffectInfo(unitTag, visualType, stat, attribute, powerType)
    if value then
        -- If there is an active UAV of this type return its info and mark that we updated to that sequenceId so we can ignore any older events
        self:SetMostRecentUpdate(visualType, stat, attribute, powerType, sequenceId, unitTag)
        return value, maxValue
    else
        -- Otherwise clear out the UAV sequenceId since there is no active effect
        self:SetMostRecentUpdate(visualType, stat, attribute, powerType, nil, unitTag)
        return 0, 0
    end
end

--- Drops cached recency-tracking state for a unitTag.<br>
--- Modules are singletons shared across all visualizers, so `updateRecencyInfo`
--- accumulates nested tables for every unitTag that has ever fired a UAV event
--- against this module. Without explicit cleanup, the per-tag subtree (visualType
--- --> stat --> attribute --> powerType --> sequenceId) persists for the rest of the
--- session even after the unit is destroyed; this method nils the unitTag entry
--- so its subtree can be collected. Safe to call repeatedly.
--- @param unitTag string
function LUIE_UnitAttributeVisualizerModuleBase:ClearUnitTag(unitTag)
    if not unitTag then return end
    if self.updateRecencyInfo then
        self.updateRecencyInfo[unitTag] = nil
    end
end

--- Called during module creation (override in subclasses if needed)
function LUIE_UnitAttributeVisualizerModuleBase:Initialize(...)
    -- Override in subclasses if needed
end

--- Called when this module is added to a visualizer (override in subclasses if needed)
--- @param healthBarControl table|nil
--- @param magickaBarControl table|nil
--- @param staminaBarControl table|nil
function LUIE_UnitAttributeVisualizerModuleBase:OnAdded(healthBarControl, magickaBarControl, staminaBarControl)
    self.healthBarControl = healthBarControl
    self.magickaBarControl = magickaBarControl
    self.staminaBarControl = staminaBarControl
end

--- Invokes callback for each power entry this visualizer owns for unitTag/powerType.
--- @param unitTag string
--- @param powerType CombatMechanicFlags
--- @param callback fun(powerEntry: table)
function LUIE_UnitAttributeVisualizerModuleBase:ForEachPowerEntry(unitTag, powerType, callback)
    local owner = self.owner
    if owner then
        if owner.customFrame and owner.customFrame[powerType] then
            callback(owner.customFrame[powerType])
        end
        if owner.defaultFrameTable and owner.defaultFrameTable[powerType] then
            callback(owner.defaultFrameTable[powerType])
        end
    end
    if UnitFrames.AvaCustFrames[unitTag] and UnitFrames.AvaCustFrames[unitTag][powerType] then
        callback(UnitFrames.AvaCustFrames[unitTag][powerType])
    end
end

--- Invokes callback for each unit-frame table (custom/default/ava) tied to this visualizer.
--- @param unitTag string
--- @param callback fun(frameTable: table)
function LUIE_UnitAttributeVisualizerModuleBase:ForEachUnitFrameTable(unitTag, callback)
    local owner = self.owner
    if owner then
        if owner.customFrame then
            callback(owner.customFrame)
        end
        if owner.defaultFrameTable then
            callback(owner.defaultFrameTable)
        end
    end
    if UnitFrames.AvaCustFrames[unitTag] then
        callback(UnitFrames.AvaCustFrames[unitTag])
    end
end

--- Called when the unit the unitTag points to has changed (override in subclasses if needed)
--- @param unitTag string The unitTag that has changed
function LUIE_UnitAttributeVisualizerModuleBase:OnUnitChanged(unitTag)
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
