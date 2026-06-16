-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local MINIMAP_MAP_NAME_FALLBACK_MS = 45000

--- @class MiniMapMapEventController : ZO_InitializingCallbackObject
--- @field mapController MiniMapMapController
--- @field pinController MiniMapPinController
--- @field pinMirrorStateMachine MiniMapPinMirrorStateMachine
--- @field eventAnchor Control
--- @field registeredEvents integer[]
--- @field onQuestTrackerTrackingStateChanged function|nil
--- @field onQuestTrackerAssistStateChanged function|nil
--- @field onAntiquitiesUpdated function|nil
--- @field onSingleAntiquityDigSitesUpdated function|nil
--- @field onCMapHandlersRefreshedSingleQuestPins function|nil
--- @field onCMapHandlersRefreshedAllQuestPins function|nil
local MiniMapMapEventController = ZO_InitializingCallbackObject:Subclass()
MiniMap.MiniMapMapEventController = MiniMapMapEventController

local CMAP_QUEST_PIN_SYNC_EVENT_IDS =
{
    EVENT_QUEST_LIST_UPDATED,
    EVENT_QUEST_ADVANCED,
    EVENT_QUEST_REMOVED,
    EVENT_QUEST_ADDED,
    EVENT_QUEST_COMPLETE,
    EVENT_QUEST_COMPLETE_DIALOG,
    EVENT_QUEST_OPTIONAL_STEP_ADVANCED,
}

local CMAP_ZONE_STORY_EVENT_IDS =
{
    EVENT_ZONE_STORY_ACTIVITY_TRACKING_INIT,
    EVENT_ZONE_STORY_ACTIVITY_TRACKED,
    EVENT_ZONE_STORY_ACTIVITY_UNTRACKED,
}

local CMAP_ANTIQUITY_EVENT_IDS =
{
    EVENT_ANTIQUITY_TRACKING_INITIALIZED,
    EVENT_ANTIQUITY_TRACKING_UPDATE,
}

local CMAP_BREADCRUMB_EVENT_IDS =
{
    EVENT_PATH_FINDING_NETWORK_LINK_CHANGED,
    EVENT_LINKED_WORLD_POSITION_CHANGED,
}

local CMAP_KEEP_EVENT_IDS =
{
    EVENT_KEEP_ALLIANCE_OWNER_CHANGED,
    EVENT_KEEP_UNDER_ATTACK_CHANGED,
    EVENT_KEEP_IS_PASSABLE_CHANGED,
    EVENT_KEEP_PIECE_DIRECTIONAL_ACCESS_CHANGED,
    EVENT_KEEP_INITIALIZED,
    EVENT_KEEP_GATE_STATE_CHANGED,
    EVENT_KEEPS_INITIALIZED,
    EVENT_CURRENT_SUBZONE_LIST_CHANGED,
}

local PIN_DIRTY_EVENT_IDS =
{
    EVENT_MAP_PING,
    EVENT_OBJECTIVES_UPDATED,
    EVENT_POIS_INITIALIZED,
    EVENT_POI_UPDATED,
    EVENT_POI_DISCOVERED,
    EVENT_GROUP_UPDATE,
    EVENT_GROUP_MEMBER_JOINED,
    EVENT_GROUP_MEMBER_LEFT,
    EVENT_WORLD_EVENTS_INITIALIZED,
    EVENT_WORLD_EVENT_ACTIVATED,
    EVENT_WORLD_EVENT_DEACTIVATED,
    EVENT_WORLD_EVENT_UNIT_CREATED,
    EVENT_WORLD_EVENT_UNIT_DESTROYED,
    EVENT_WORLD_EVENT_UNIT_CHANGED_PIN_TYPE,
}

--- @param mapController MiniMapMapController
--- @param pinController MiniMapPinController
--- @param pinMirrorStateMachine MiniMapPinMirrorStateMachine
function MiniMapMapEventController:Initialize(mapController, pinController, pinMirrorStateMachine)
    self.mapController = mapController
    self.pinController = pinController
    self.pinMirrorStateMachine = pinMirrorStateMachine
    self.eventAnchor = LUIE_MiniMap
    self.registeredEvents = {}
end

--- @param reason string
function MiniMapMapEventController:RequestMapReload(reason)
    self.pinMirrorStateMachine:RequestMapReload(reason or "Event")
end

function MiniMapMapEventController:RunPinSync()
    if not MiniMap.Enabled or not self.pinController or not self.mapController then
        return
    end
    self.pinMirrorStateMachine:RequestPinSyncDebounced()
end

function MiniMapMapEventController:SchedulePinSync()
    self:RunPinSync()
end

--- Quest journal / tracker updates world-map quest pins asynchronously.
function MiniMapMapEventController:RequestQuestPinSync()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.RefreshNativeWorldMapContainer()
end

function MiniMapMapEventController:RunLightQuestPinSync(questIndex)
    if not MiniMap.Enabled or MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    MiniMap.RunWithPlayerMapForMirror(function ()
        if questIndex then
            MiniMap.RefreshWorldMapQuestPinsLight(questIndex)
        else
            for activeQuestIndex in pairs(WORLD_MAP_QUEST_BREADCRUMBS.activeQuests) do
                C_MAP_HANDLERS:RefreshSingleQuestPins(activeQuestIndex)
            end
            MiniMap.RefreshWorldMapPingsForMirror()
            MiniMap.RefreshWorldMapSuggestionPinsForMirror()
            if MiniMap.IsNativeWorldMapContainerAttached() then
                MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(MiniMap.mapController)
            end
        end
    end)
end

function MiniMapMapEventController:ScheduleLightQuestPinSyncAfterPositionComplete()
    local mapEventController = self
    local updateName = MiniMap.moduleName .. "QuestPositionLightPinSync"
    local doOnce = true
    EVENT_MANAGER:RegisterForUpdate(updateName, 0, function ()
                                        mapEventController:RunLightQuestPinSync(nil)
                                    end, doOnce)
end

function MiniMapMapEventController:OnCMapHandlersRefreshedSingleQuestPins(questIndex)
    if not MiniMap.Enabled or MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    MiniMap.RunWithPlayerMapForMirror(function ()
        MiniMap.RefreshWorldMapQuestPinsLight(questIndex)
    end)
end

function MiniMapMapEventController:OnCMapHandlersRefreshedAllQuestPins()
    if not MiniMap.Enabled or MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    MiniMap.RunWithPlayerMapForMirror(function ()
        MiniMap.RefreshWorldMapPingsForMirror()
        MiniMap.RefreshWorldMapSuggestionPinsForMirror()
        MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(MiniMap.mapController)
    end)
end

function MiniMapMapEventController:RequestDigSitePinSync()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.RefreshNativeWorldMapContainer()
end

function MiniMapMapEventController:RequestCompanionPinSync()
    if not MiniMap.Enabled then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    MiniMap.RunWithPlayerMapForMirror(function ()
        WORLD_MAP_MANAGER:RefreshCompanionPins()
    end)
end

function MiniMapMapEventController:RequestZoneStoryPinSync()
    if not MiniMap.Enabled then
        return
    end
    self:SchedulePinSync()
end

function MiniMapMapEventController:RequestBreadcrumbPinSync()
    self:RequestQuestPinSync()
    self:RequestZoneStoryPinSync()
end

--- After ZOS `CMapHandlers` tracker callbacks update `SetMapQuestPinsTrackingLevel`, mirror on the next frame.
function MiniMapMapEventController:ScheduleDeferredQuestPinSyncFromTracker()
    local mapEventController = self
    local questPinSyncUpdateName = MiniMap.moduleName .. "QuestTrackerPinSync"
    local doOnce = true
    EVENT_MANAGER:RegisterForUpdate(questPinSyncUpdateName, 0, function ()
                                        mapEventController:RunLightQuestPinSync(nil)
                                    end, doOnce)
end

--- Same guard as ZOS `CMapHandlers` `EVENT_QUEST_CONDITION_COUNTER_CHANGED` handler.
--- @param eventId integer
--- @param journalIndex luaindex
--- @param questName string
--- @param conditionText string
--- @param conditionType QuestConditionType
--- @param currConditionVal integer
--- @param newConditionVal integer
--- @param conditionMax integer
--- @param isFailCondition boolean
--- @param stepOverrideText string
--- @param isPushed boolean
--- @param isComplete boolean
--- @param isConditionComplete boolean
--- @param isStepHidden boolean
--- @param isConditionCompleteStatusChanged boolean
--- @param isConditionCompletableBySiblingStatusChanged boolean
function MiniMapMapEventController:OnQuestConditionCounterChanged(eventId, journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden, isConditionCompleteStatusChanged, isConditionCompletableBySiblingStatusChanged)
    if not isConditionComplete and (isConditionCompleteStatusChanged or isConditionCompletableBySiblingStatusChanged) then
        self:RequestQuestPinSync()
    end
end

function MiniMapMapEventController:OnZoneChanged()
    self.pinMirrorStateMachine.pendingMapReloadReason = "EVENT_ZONE_CHANGED"
    self.pinMirrorStateMachine.pendingMapReloadAttempt = 0
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        self.pinMirrorStateMachine.mapReloadQueuedWhileWorldMap = true
        self.pinMirrorStateMachine.mapReloadQueuedReason = "EVENT_ZONE_CHANGED"
        return
    end
    self.pinMirrorStateMachine:InterruptZoneReset()
end

function MiniMapMapEventController:OnPlayerActivated()
    if not self.pinMirrorStateMachine:TryPinSyncOnlyOnPlayerActivated() then
        self:RequestMapReload("EVENT_PLAYER_ACTIVATED")
    end
end

function MiniMapMapEventController:OnPlayerZoneUpdate()
    self:RequestMapReload("EVENT_ZONE_UPDATE")
end

function MiniMapMapEventController:OnFastTravelStart()
    MiniMap.fastTravel = true
    self.pinMirrorStateMachine:OnFastTravelStart()
end

function MiniMapMapEventController:OnFastTravelEnd()
    MiniMap.fastTravel = false
    self.pinMirrorStateMachine:OnFastTravelEnd()
    self:RequestMapReload("FastTravelEnd")
end

function MiniMapMapEventController:OnMapNameFallbackTick()
    if MiniMap.fastTravel or not self.mapController:IsReady() then
        return
    end
    if not DoesCurrentMapMatchMapForPlayerLocation() then
        return
    end
    local mapData = self.mapController:GetMapData()
    if mapData and mapData.rawName ~= GetMapName() then
        self:RequestMapReload("MapNameFallback")
    end
end

--- @param eventId integer
--- @param handler function
function MiniMapMapEventController:RegisterGameEvent(eventId, handler)
    self.eventAnchor:RegisterForEvent(eventId, handler)
    self.registeredEvents[#self.registeredEvents + 1] = eventId
end

function MiniMapMapEventController:Register()
    local mapEventController = self
    self:RegisterGameEvent(EVENT_ZONE_CHANGED, function () mapEventController:OnZoneChanged() end)
    self:RegisterGameEvent(EVENT_PLAYER_ACTIVATED, function () mapEventController:OnPlayerActivated() end)
    self:RegisterGameEvent(EVENT_ZONE_UPDATE, function () mapEventController:OnPlayerZoneUpdate() end)
    self.eventAnchor:AddFilterForEvent(EVENT_ZONE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    self:RegisterGameEvent(EVENT_START_FAST_TRAVEL_INTERACTION, function () mapEventController:OnFastTravelStart() end)
    self:RegisterGameEvent(EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, function () mapEventController:OnFastTravelStart() end)
    self:RegisterGameEvent(EVENT_END_FAST_TRAVEL_INTERACTION, function () mapEventController:OnFastTravelEnd() end)
    self:RegisterGameEvent(EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, function () mapEventController:OnFastTravelEnd() end)
    for _, eventId in ipairs(PIN_DIRTY_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:SchedulePinSync() end)
    end
    for _, eventId in ipairs(CMAP_QUEST_PIN_SYNC_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:RequestQuestPinSync() end)
    end
    self:RegisterGameEvent(EVENT_QUEST_POSITION_REQUEST_COMPLETE, function ()
        mapEventController:ScheduleLightQuestPinSyncAfterPositionComplete()
    end)
    self:RegisterGameEvent(EVENT_QUEST_CONDITION_COUNTER_CHANGED, function (...)
        mapEventController:OnQuestConditionCounterChanged(...)
    end)
    self:RegisterGameEvent(EVENT_PLAYER_TELEPORTED_LOCALLY, function () mapEventController:RequestQuestPinSync() end)
    for _, eventId in ipairs(CMAP_ZONE_STORY_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:RequestZoneStoryPinSync() end)
    end
    for _, eventId in ipairs(CMAP_ANTIQUITY_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:RequestDigSitePinSync() end)
    end
    for _, eventId in ipairs(CMAP_BREADCRUMB_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:RequestBreadcrumbPinSync() end)
    end
    for _, eventId in ipairs(CMAP_KEEP_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:SchedulePinSync() end)
    end
    self:RegisterGameEvent(EVENT_COMPANION_ACTIVATED, function () mapEventController:RequestCompanionPinSync() end)
    self:RegisterGameEvent(EVENT_COMPANION_DEACTIVATED, function () mapEventController:RequestCompanionPinSync() end)
    self.onQuestTrackerTrackingStateChanged = function (_questTracker, _tracked, trackType)
        if trackType == TRACK_TYPE_QUEST then
            mapEventController:ScheduleDeferredQuestPinSyncFromTracker()
        end
    end
    self.onQuestTrackerAssistStateChanged = function (unassistedData, assistedData)
        if unassistedData and unassistedData:GetJournalIndex() then
            mapEventController:ScheduleDeferredQuestPinSyncFromTracker()
        elseif assistedData and assistedData:GetJournalIndex() then
            mapEventController:ScheduleDeferredQuestPinSyncFromTracker()
        end
    end
    FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerTrackingStateChanged", self.onQuestTrackerTrackingStateChanged)
    FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", self.onQuestTrackerAssistStateChanged)
    self.onAntiquitiesUpdated = function ()
        mapEventController:RequestDigSitePinSync()
    end
    self.onSingleAntiquityDigSitesUpdated = function ()
        mapEventController:RequestDigSitePinSync()
    end
    ANTIQUITY_DATA_MANAGER:RegisterCallback("AntiquitiesUpdated", self.onAntiquitiesUpdated)
    ANTIQUITY_DATA_MANAGER:RegisterCallback("SingleAntiquityDigSitesUpdated", self.onSingleAntiquityDigSitesUpdated)
    self.onCMapHandlersRefreshedSingleQuestPins = function (questIndex)
        mapEventController:OnCMapHandlersRefreshedSingleQuestPins(questIndex)
    end
    self.onCMapHandlersRefreshedAllQuestPins = function ()
        mapEventController:OnCMapHandlersRefreshedAllQuestPins()
    end
    C_MAP_HANDLERS:RegisterCallback("RefreshedSingleQuestPins", self.onCMapHandlersRefreshedSingleQuestPins)
    C_MAP_HANDLERS:RegisterCallback("RefreshedAllQuestPins", self.onCMapHandlersRefreshedAllQuestPins)
    EVENT_MANAGER:RegisterForUpdate(MiniMap.moduleName .. "MapNameFallback", MINIMAP_MAP_NAME_FALLBACK_MS, function ()
        mapEventController:OnMapNameFallbackTick()
    end)
    self.pinMirrorStateMachine:Start()
    MiniMap.RegisterMiniMapSceneIntegration()
    MiniMap.RefreshSceneFragments()
    MiniMap.ApplyFragmentHiddenReasons()
    MiniMap.UpdateGameplayTickers()
end

function MiniMapMapEventController:Unregister()
    MiniMap.UnregisterMiniMapSceneIntegration()
    if self.pinMirrorStateMachine then
        self.pinMirrorStateMachine:Stop()
    end
    for _, eventId in ipairs(self.registeredEvents) do
        self.eventAnchor:UnregisterForEvent(eventId)
    end
    self.registeredEvents = {}
    EVENT_MANAGER:UnregisterForUpdate(MiniMap.moduleName .. "MapNameFallback")
    if self.pinController then
        self.pinController:CancelPinSyncCoroutine()
    end
    if self.onQuestTrackerTrackingStateChanged then
        FOCUSED_QUEST_TRACKER:UnregisterCallback("QuestTrackerTrackingStateChanged", self.onQuestTrackerTrackingStateChanged)
        self.onQuestTrackerTrackingStateChanged = nil
    end
    if self.onQuestTrackerAssistStateChanged then
        FOCUSED_QUEST_TRACKER:UnregisterCallback("QuestTrackerAssistStateChanged", self.onQuestTrackerAssistStateChanged)
        self.onQuestTrackerAssistStateChanged = nil
    end
    if self.onAntiquitiesUpdated then
        ANTIQUITY_DATA_MANAGER:UnregisterCallback("AntiquitiesUpdated", self.onAntiquitiesUpdated)
        self.onAntiquitiesUpdated = nil
    end
    if self.onSingleAntiquityDigSitesUpdated then
        ANTIQUITY_DATA_MANAGER:UnregisterCallback("SingleAntiquityDigSitesUpdated", self.onSingleAntiquityDigSitesUpdated)
        self.onSingleAntiquityDigSitesUpdated = nil
    end
    if self.onCMapHandlersRefreshedSingleQuestPins then
        C_MAP_HANDLERS:UnregisterCallback("RefreshedSingleQuestPins", self.onCMapHandlersRefreshedSingleQuestPins)
        self.onCMapHandlersRefreshedSingleQuestPins = nil
    end
    if self.onCMapHandlersRefreshedAllQuestPins then
        C_MAP_HANDLERS:UnregisterCallback("RefreshedAllQuestPins", self.onCMapHandlersRefreshedAllQuestPins)
        self.onCMapHandlersRefreshedAllQuestPins = nil
    end
end
