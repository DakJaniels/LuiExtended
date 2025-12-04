-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local eventManager = GetEventManager()

-- -----------------------------------------------------------------------------

local NEXT_VISUALIZER_NAMESPACE_INDEX = 0

--- Coordinator class for managing unit attribute visualizers per unitTag
--- Matches ZOS UnitAttributeVisualizer pattern
--- @class LUIE_UnitAttributeVisualizer : ZO_CallbackObject
LUIE_UnitAttributeVisualizer = ZO_CallbackObject:Subclass()

--- Creates a new visualizer instance for a specific unitTag
--- @param unitTag string
--- @return LUIE_UnitAttributeVisualizer
function LUIE_UnitAttributeVisualizer:New(unitTag)
    local visualizer = ZO_CallbackObject.New(self)
    visualizer:Initialize(unitTag)
    return visualizer
end

--- Initialize the visualizer for a specific unit
--- @param unitTag string
function LUIE_UnitAttributeVisualizer:Initialize(unitTag)
    self.unitTag = unitTag
    --- Registry of module references for this unit (mirrors UnitFrames.VisualizerModules)
    self.modules = {}

    -- Copy all registered modules to this visualizer
    -- NOTE: Modules are singletons shared across all visualizers, so don't call SetOwner!
    -- Each module method receives unitTag explicitly to identify which unit it's operating on
    zo_mixin(self.modules, UnitFrames.VisualizerModules)

    -- Create unique event namespace for this visualizer instance
    local eventNamespace = "LUIE_UnitAttributeVisualizer" .. unitTag .. NEXT_VISUALIZER_NAMESPACE_INDEX
    NEXT_VISUALIZER_NAMESPACE_INDEX = NEXT_VISUALIZER_NAMESPACE_INDEX + 1
    self.eventNamespace = eventNamespace

    -- Register for attribute visual events with unit tag filtering
    eventManager:RegisterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function (eventCode, ...)
        self:OnUnitAttributeVisualAdded(...)
    end)
    eventManager:AddFilterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, unitTag)

    eventManager:RegisterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function (eventCode, ...)
        self:OnUnitAttributeVisualUpdated(...)
    end)
    eventManager:AddFilterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, unitTag)

    eventManager:RegisterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function (eventCode, ...)
        self:OnUnitAttributeVisualRemoved(...)
    end)
    eventManager:AddFilterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, unitTag)

    -- Special handling for reticleover (unit pointer changes constantly but unitTag stays same)
    -- Note: ZOS also handles "target" with EVENT_TARGET_CHANGED, but LUIE doesn't use that unitTag
    if unitTag == "reticleover" then
        eventManager:RegisterForEvent(eventNamespace, EVENT_RETICLE_TARGET_CHANGED, function ()
            self:OnUnitChanged()
        end)
    end
end

--- Gets the unitTag this visualizer is managing
--- @return string
function LUIE_UnitAttributeVisualizer:GetUnitTag()
    return self.unitTag
end

--- Called when the unit this visualizer tracks has changed
function LUIE_UnitAttributeVisualizer:OnUnitChanged()
    if DoesUnitExist(self.unitTag) then
        --- @type string, LUIE_PowerShieldModule|LUIE_RegenerationModule|LUIE_StatChangeModule|LUIE_UnwaveringModule|LUIE_PossessionModule
        for moduleName, module in pairs(self.modules) do
            module:OnUnitChanged(self.unitTag)
        end
    end
end

--- Dispatches EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED to registered modules
function LUIE_UnitAttributeVisualizer:OnUnitAttributeVisualAdded(unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
    --- @type string, LUIE_PowerShieldModule|LUIE_RegenerationModule|LUIE_StatChangeModule|LUIE_UnwaveringModule|LUIE_PossessionModule
    for _, module in pairs(self.modules) do
        if module:IsRelevant(visualType, stat, attribute, powerType) then
            local mostRecentUpdate = module:GetMostRecentUpdate(visualType, stat, attribute, powerType, unitTag)
            if not mostRecentUpdate then
                module:OnVisualizationAdded(unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
                module:SetMostRecentUpdate(visualType, stat, attribute, powerType, sequenceId, unitTag)
            end
        end
    end
end

--- Dispatches EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED to registered modules
function LUIE_UnitAttributeVisualizer:OnUnitAttributeVisualUpdated(unitTag, visualType, stat, attribute, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    --- @type string, LUIE_PowerShieldModule|LUIE_RegenerationModule|LUIE_StatChangeModule|LUIE_UnwaveringModule|LUIE_PossessionModule
    for _, module in pairs(self.modules) do
        if module:IsRelevant(visualType, stat, attribute, powerType) then
            local mostRecentUpdate = module:GetMostRecentUpdate(visualType, stat, attribute, powerType, unitTag)
            if mostRecentUpdate and sequenceId > mostRecentUpdate then
                module:OnVisualizationUpdated(unitTag, visualType, stat, attribute, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
                module:SetMostRecentUpdate(visualType, stat, attribute, powerType, sequenceId, unitTag)
            end
        end
    end
end

--- Dispatches EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED to registered modules
function LUIE_UnitAttributeVisualizer:OnUnitAttributeVisualRemoved(unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
    --- @type string, LUIE_PowerShieldModule|LUIE_RegenerationModule|LUIE_StatChangeModule|LUIE_UnwaveringModule|LUIE_PossessionModule
    for _, module in pairs(self.modules) do
        if module:IsRelevant(visualType, stat, attribute, powerType) then
            local mostRecentUpdate = module:GetMostRecentUpdate(visualType, stat, attribute, powerType, unitTag)
            if mostRecentUpdate and sequenceId >= mostRecentUpdate then
                module:OnVisualizationRemoved(unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
                module:SetMostRecentUpdate(visualType, stat, attribute, powerType, nil, unitTag)
            end
        end
    end
end

--- Triggers platform style updates for all modules
function LUIE_UnitAttributeVisualizer:ApplyPlatformStyle()
    --- @type string, LUIE_PowerShieldModule|LUIE_RegenerationModule|LUIE_StatChangeModule|LUIE_UnwaveringModule|LUIE_PossessionModule
    for _, module in pairs(self.modules) do
        module:ApplyPlatformStyle()
    end
end

--- Triggers alpha updates for all modules
--- @param isNearby boolean
function LUIE_UnitAttributeVisualizer:DoAlphaUpdate(isNearby)
    --- @type string, LUIE_PowerShieldModule|LUIE_RegenerationModule|LUIE_StatChangeModule|LUIE_UnwaveringModule|LUIE_PossessionModule
    for _, module in pairs(self.modules) do
        module:DoAlphaUpdate(isNearby)
    end
end

--- Unregisters all events for this visualizer
function LUIE_UnitAttributeVisualizer:Destroy()
    if self.eventNamespace then
        eventManager:UnregisterForEvent(self.eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
        eventManager:UnregisterForEvent(self.eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
        eventManager:UnregisterForEvent(self.eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
        eventManager:UnregisterForEvent(self.eventNamespace, EVENT_RETICLE_TARGET_CHANGED)
    end
end
