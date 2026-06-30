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

--- Per-frame attribute visualizer (ZOS ZO_UnitAttributeVisualizer pattern).
--- @class LUIE_UnitAttributeVisualizer : ZO_CallbackObject
LUIE_UnitAttributeVisualizer = ZO_CallbackObject:Subclass()

--- @param unitTag string
--- @param soundTable table|nil
--- @param healthBarControl Control|nil
--- @param magickaBarControl Control|nil
--- @param staminaBarControl Control|nil
--- @return LUIE_UnitAttributeVisualizer
function LUIE_UnitAttributeVisualizer:New(unitTag, soundTable, healthBarControl, magickaBarControl, staminaBarControl)
    local visualizer = ZO_CallbackObject.New(self)
    visualizer:Initialize(unitTag, soundTable, healthBarControl, magickaBarControl, staminaBarControl)
    return visualizer
end

function LUIE_UnitAttributeVisualizer:Initialize(unitTag, soundTable, healthBarControl, magickaBarControl, staminaBarControl)
    self.unitTag = unitTag
    self.soundTable = soundTable
    self.healthBarControl = healthBarControl
    self.magickaBarControl = magickaBarControl
    self.staminaBarControl = staminaBarControl
    self.visualModules = {}
    self:RegisterAttributeVisualEvents()
end

function LUIE_UnitAttributeVisualizer:UnregisterAttributeVisualEvents()
    if not self.eventNamespace then
        return
    end
    eventManager:UnregisterForEvent(self.eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED)
    eventManager:UnregisterForEvent(self.eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED)
    eventManager:UnregisterForEvent(self.eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED)
    eventManager:UnregisterForEvent(self.eventNamespace, EVENT_RETICLE_TARGET_CHANGED)
    self.eventNamespace = nil
end

function LUIE_UnitAttributeVisualizer:RegisterAttributeVisualEvents()
    self:UnregisterAttributeVisualEvents()

    local unitTagS = self.unitTag
    if not unitTagS then
        return
    end

    local eventNamespace = "LUIE_UnitAttributeVisualizer" .. unitTagS .. NEXT_VISUALIZER_NAMESPACE_INDEX
    NEXT_VISUALIZER_NAMESPACE_INDEX = NEXT_VISUALIZER_NAMESPACE_INDEX + 1
    self.eventNamespace = eventNamespace

    eventManager:RegisterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, function (eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
        self:OnUnitAttributeVisualAdded(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    end)
    eventManager:AddFilterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_ADDED, REGISTER_FILTER_UNIT_TAG, unitTagS)

    eventManager:RegisterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, function (eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
        self:OnUnitAttributeVisualUpdated(unitTag, unitAttributeVisual, statType, attributeType, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    end)
    eventManager:AddFilterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_UPDATED, REGISTER_FILTER_UNIT_TAG, unitTagS)

    eventManager:RegisterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, function(eventId, unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
        self:OnUnitAttributeVisualRemoved(unitTag, unitAttributeVisual, statType, attributeType, powerType, value, maxValue, sequenceId)
    end)
    eventManager:AddFilterForEvent(eventNamespace, EVENT_UNIT_ATTRIBUTE_VISUAL_REMOVED, REGISTER_FILTER_UNIT_TAG, unitTagS)

    if unitTagS == "reticleover" then
        eventManager:RegisterForEvent(eventNamespace, EVENT_RETICLE_TARGET_CHANGED, function ()
            self:OnUnitChanged()
        end)
    end
end

--- Rebind UAV listeners when a custom frame slot is aliased to a different game unitTag (group roster sort).
--- @param newUnitTag string|nil
function LUIE_UnitAttributeVisualizer:SetUnitTag(newUnitTag)
    if self.unitTag == newUnitTag then
        return
    end

    local oldUnitTag = self.unitTag
    if oldUnitTag and UnitFrames.Visualizers[oldUnitTag] == self then
        UnitFrames.Visualizers[oldUnitTag] = nil
    end

    self.unitTag = newUnitTag
    self:RegisterAttributeVisualEvents()

    if newUnitTag then
        UnitFrames.Visualizers[newUnitTag] = self
    end
end

function LUIE_UnitAttributeVisualizer:GetUnitTag()
    return self.unitTag
end

--- @param module LUIE_UnitAttributeVisualizerModuleBase
function LUIE_UnitAttributeVisualizer:AddModule(module)
    if not self.visualModules[module] then
        module:SetOwner(self)
        module:OnAdded(self.healthBarControl, self.magickaBarControl, self.staminaBarControl)
        self.visualModules[module] = true
    end
end

function LUIE_UnitAttributeVisualizer:OnUnitChanged()
    if DoesUnitExist(self.unitTag) then
        for module in pairs(self.visualModules) do
            module:OnUnitChanged(self.unitTag)
        end
    end
end

function LUIE_UnitAttributeVisualizer:OnUnitAttributeVisualAdded(unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
    for module in pairs(self.visualModules) do
        if module:IsRelevant(visualType, stat, attribute, powerType) then
            local mostRecentUpdate = module:GetMostRecentUpdate(visualType, stat, attribute, powerType, unitTag)
            if not mostRecentUpdate then
                module:OnVisualizationAdded(unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
                module:SetMostRecentUpdate(visualType, stat, attribute, powerType, sequenceId, unitTag)
            end
        end
    end
end

function LUIE_UnitAttributeVisualizer:OnUnitAttributeVisualUpdated(unitTag, visualType, stat, attribute, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
    for module in pairs(self.visualModules) do
        if module:IsRelevant(visualType, stat, attribute, powerType) then
            local mostRecentUpdate = module:GetMostRecentUpdate(visualType, stat, attribute, powerType, unitTag)
            if mostRecentUpdate and sequenceId > mostRecentUpdate then
                module:OnVisualizationUpdated(unitTag, visualType, stat, attribute, powerType, oldValue, newValue, oldMaxValue, newMaxValue, sequenceId)
                module:SetMostRecentUpdate(visualType, stat, attribute, powerType, sequenceId, unitTag)
            end
        end
    end
end

function LUIE_UnitAttributeVisualizer:OnUnitAttributeVisualRemoved(unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
    for module in pairs(self.visualModules) do
        if module:IsRelevant(visualType, stat, attribute, powerType) then
            local mostRecentUpdate = module:GetMostRecentUpdate(visualType, stat, attribute, powerType, unitTag)
            if mostRecentUpdate and sequenceId > mostRecentUpdate then
                module:OnVisualizationRemoved(unitTag, visualType, stat, attribute, powerType, value, maxValue, sequenceId)
                module:SetMostRecentUpdate(visualType, stat, attribute, powerType, nil, unitTag)
            end
        end
    end
end

function LUIE_UnitAttributeVisualizer:ApplyPlatformStyle()
    for module in pairs(self.visualModules) do
        module:ApplyPlatformStyle()
    end
end

function LUIE_UnitAttributeVisualizer:DoAlphaUpdate(isNearby)
    for module in pairs(self.visualModules) do
        module:DoAlphaUpdate(isNearby)
    end
end

function LUIE_UnitAttributeVisualizer:Destroy()
    self:UnregisterAttributeVisualEvents()
end
