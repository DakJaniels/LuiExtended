-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local eventManager = GetEventManager()

local MINIMAP_MAP_NAME_FALLBACK_MS = 45000

--- @class MiniMapMapEventController : ZO_InitializingCallbackObject
--- @field mapController MiniMapMapController
--- @field pinController MiniMapPinController
--- @field pinMirrorStateMachine MiniMapPinMirrorStateMachine
--- @field eventAnchor Control
--- @field registeredEvents integer[]
--- @field onQuestTrackerTrackingStateChanged function|nil
--- @field onQuestTrackerAssistStateChanged function|nil
--- @field onCMapHandlersRefreshedSingleQuestPins function|nil
--- @field onCMapHandlersRefreshedAllQuestPins function|nil
--- @field onWorldMapQuestBreadcrumbsQuestAvailable function|nil
--- @field onAntiquitiesUpdated function|nil
--- @field onSingleAntiquityDigSitesUpdated function|nil
local MiniMapMapEventController = ZO_InitializingCallbackObject:Subclass()
MiniMap.MiniMapMapEventController = MiniMapMapEventController

local CMAP_QUEST_PIN_SYNC_FULL_EVENT_IDS =
{
    EVENT_QUEST_COMPLETE,
    EVENT_QUEST_COMPLETE_DIALOG,
    EVENT_QUEST_OPTIONAL_STEP_ADVANCED,
}

local questPinLightSyncPendingJournalIndex --- @type luaindex|nil
local questPinLightSyncPendingRefreshAll = false
local questPinLightSyncPendingLayoutOnly = false

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

local CMAP_KEEP_EVENT_IDS =
{
    EVENT_KEEP_ALLIANCE_OWNER_CHANGED,
    EVENT_KEEP_UNDER_ATTACK_CHANGED,
    EVENT_KEEP_IS_PASSABLE_CHANGED,
    EVENT_KEEP_PIECE_DIRECTIONAL_ACCESS_CHANGED,
    EVENT_KEEP_INITIALIZED,
    EVENT_KEEP_GATE_STATE_CHANGED,
    EVENT_KEEPS_INITIALIZED,
}

local PIN_DIRTY_EVENT_IDS =
{
    EVENT_OBJECTIVES_UPDATED,
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
    self.companionPinSyncQueuedWhileWorldMap = false
end

--- @param reason string
function MiniMapMapEventController:RequestMapReload(reason)
    self.pinMirrorStateMachine:RequestMapReload(reason or "Event")
end

function MiniMapMapEventController:SchedulePinSync()
    if not MiniMap.Enabled or not self.pinController or not self.mapController then
        return
    end
    self.pinMirrorStateMachine:RequestPinSyncImmediate()
end

--- Skyshards, delves, and other map objective pins on the reparented world map container.
function MiniMapMapEventController:RequestMapObjectivePinSync()
    if not MiniMap.Enabled or not self.mapController or not self.pinMirrorStateMachine then
        return
    end
    if MiniMap.fastTravel or self.pinMirrorStateMachine:IsCurrentState("FastTravelBlocked") then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        MiniMap.QueuePinMirrorWorkWhileWorldMapBlocked(self.pinMirrorStateMachine)
        return
    end
    if self.pinMirrorStateMachine:IsCurrentState("MapReloading") or self.pinMirrorStateMachine:IsCurrentState("ZoneReset") then
        self.pinMirrorStateMachine.pinSyncQueuedWhileMapReloading = true
        return
    end
    if not self.mapController:IsReady() then
        self.pinMirrorStateMachine.pinSyncQueuedWhileMapReloading = true
        return
    end
    MiniMap.TryAttachNativeWorldMapContainer()
    local mirrorRan = MiniMap.RunWithPlayerMapForMirror(function ()
        ZO_WorldMap_RefreshAllPOIs()
        MiniMap.RefreshWorldMapLocationPinsForMirror()
    end)
    if not mirrorRan then
        return
    end
    MiniMap.ApplyHudNativePinLayoutAfterRefresh()
    MiniMap.SyncHudOverlayPinsAfterNativeRefresh()
end

--- Mirrors ZOS WorldMap EVENT_MAP_PING handler in player-map context for the HUD mirror.
--- @param _eventCode integer
--- @param pingEventType MapPingEventType
--- @param pingType MapDisplayPinType
--- @param pingTag string
--- @param x number
--- @param y number
--- @param _isPingOwner boolean
function MiniMapMapEventController:OnMapPing(_eventCode, pingEventType, pingType, pingTag, x, y, _isPingOwner)
    if not MiniMap.Enabled or not self.mapController or not self.pinMirrorStateMachine then
        return
    end
    if MiniMap.fastTravel or self.pinMirrorStateMachine:IsCurrentState("FastTravelBlocked") then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        MiniMap.QueuePinMirrorWorkWhileWorldMapBlocked(self.pinMirrorStateMachine)
        return
    end
    if self.pinMirrorStateMachine:IsCurrentState("MapReloading") or self.pinMirrorStateMachine:IsCurrentState("ZoneReset") then
        self.pinMirrorStateMachine.pinSyncQueuedWhileMapReloading = true
        return
    end
    if not self.mapController:IsReady() then
        self.pinMirrorStateMachine.pinSyncQueuedWhileMapReloading = true
        return
    end
    MiniMap.TryAttachNativeWorldMapContainer()
    local pinAdded = false
    local mirrorRan = MiniMap.RunWithPlayerMapForMirror(function ()
        local pinManager = ZO_WorldMap_GetPinManager()
        if pingEventType == PING_EVENT_ADDED then
            pinManager:RemovePins("pings", pingType, pingTag)
            pinManager:CreatePin(pingType, pingTag, x, y)
            pinAdded = true
        elseif pingEventType == PING_EVENT_REMOVED then
            pinManager:RemovePins("pings", pingType, pingTag)
        end
    end)
    if not mirrorRan then
        return
    end
    MiniMap.ApplyHudNativePinLayoutAfterRefresh()
    if pinAdded and self.pinController then
        self.pinController:ApplyUserScaleToNativeWorldMapPins()
    end
    MiniMap.SyncHudOverlayPinsAfterNativeRefresh()
end

--- Full native container refresh for quest flows ZOS CMapHandlers does not own.
function MiniMapMapEventController:RequestQuestPinSyncFull()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.RefreshNativeWorldMapContainer()
end

--- @param journalIndex luaindex|nil
--- @param layoutOnly boolean|nil When true, ZOS already updated quest pins (breadcrumbs); HUD layout only.
function MiniMapMapEventController:RequestQuestPinSyncLight(journalIndex, layoutOnly)
    if not MiniMap.Enabled then
        return
    end
    if layoutOnly then
        questPinLightSyncPendingLayoutOnly = true
    elseif journalIndex then
        questPinLightSyncPendingJournalIndex = journalIndex
    else
        questPinLightSyncPendingRefreshAll = true
    end
    self:ScheduleQuestPinLightSync()
end

function MiniMapMapEventController:ScheduleQuestPinLightSync()
    local mapEventController = self
    local updateName = MiniMap.moduleName .. "QuestPinLightSync"
    eventManager:RegisterForUpdate(updateName, 0, function ()
                                       eventManager:UnregisterForUpdate(updateName)
                                       local journalIndex = questPinLightSyncPendingJournalIndex
                                       local refreshAll = questPinLightSyncPendingRefreshAll
                                       local layoutOnly = questPinLightSyncPendingLayoutOnly
                                       questPinLightSyncPendingJournalIndex = nil
                                       questPinLightSyncPendingRefreshAll = false
                                       questPinLightSyncPendingLayoutOnly = false
                                       if layoutOnly and not journalIndex and not refreshAll then
                                           MiniMap.ApplyNativeHudQuestPinLayoutAfterCMapHandlers()
                                           return
                                       end
                                       MiniMap.RunQuestPinLightSyncForMirror(journalIndex, refreshAll)
                                   end, true)
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
        self.companionPinSyncQueuedWhileWorldMap = true
        if self.pinMirrorStateMachine then
            MiniMap.QueuePinMirrorWorkWhileWorldMapBlocked(self.pinMirrorStateMachine)
        end
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
    self:RequestZoneStoryPinSync()
end

--- After ZOS tracker updates `SetMapQuestPinsTrackingLevel`, mirror quest pins on the next frame (light).
--- @param journalIndex luaindex
function MiniMapMapEventController:ScheduleDeferredQuestPinSyncLight(journalIndex)
    local mapEventController = self
    local questPinSyncUpdateName = MiniMap.moduleName .. "QuestTrackerPinSync"
    eventManager:RegisterForUpdate(questPinSyncUpdateName, 0, function ()
                                       mapEventController:RequestQuestPinSyncLight(journalIndex, false)
                                   end, true)
end

function MiniMapMapEventController:ScheduleSubzoneHudRecovery()
    local mapEventController = self
    local updateName = MiniMap.moduleName .. "SubzoneHudRecovery"
    eventManager:RegisterForUpdate(updateName, 0, function ()
                                       eventManager:UnregisterForUpdate(updateName)
                                       if MiniMap.IsMapReloadAffectingHudLayout() then
                                           mapEventController:ScheduleSubzoneHudRecovery()
                                           return
                                       end
                                       if MiniMap.DoesHudMirrorMapIdentityMatchLoadedPlayerMap() then
                                           MiniMap.ApplyHudMirrorRecoveryAfterSubzoneTransition()
                                           MiniMap.ApplyHudLocationLabelFromPlayerLocation()
                                       else
                                           mapEventController:RequestMapReload("EVENT_ZONE_CHANGED")
                                       end
                                   end, true)
end

function MiniMapMapEventController:OnCurrentSubzoneListChanged()
    if MiniMap.DoesHudMirrorMapIdentityMatchLoadedPlayerMap() then
        self:ScheduleSubzoneHudRecovery()
        return
    end
    self:SchedulePinSync()
end

--- @param zoneName string
--- @param subZoneName string
--- @param newSubzone boolean
--- @param zoneId integer
--- @param subZoneId integer
function MiniMapMapEventController:OnZoneChanged(zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    MiniMap.ApplyHudLocationLabelFromZoneNames(zoneName, subZoneName)
    if MiniMap.SV and MiniMap.SV.pinMirrorStateMachineDebug then
        LUIE:Log("Debug", string.format(
            "[MiniMap] ZONE_CHANGED zone=%s sub=%s newSubzone=%s map=%s identityMatch=%s zoom=%.3f ctxZoom=%.3f tiles=%s locName=%s",
            tostring(zoneName),
            tostring(subZoneName),
            tostring(newSubzone),
            tostring(GetMapName()),
            tostring(MiniMap.DoesHudMirrorMapIdentityMatchLoadedPlayerMap()),
            MiniMap.zoom,
            MiniMap.GetEffectiveDefaultZoom(),
            tostring(select(1, GetMapNumTiles())),
            tostring(MiniMap.CollectHudPlayerLocationNameForDisplay())))
    end
    self:ScheduleSubzoneHudRecovery()
end

function MiniMapMapEventController:OnPlayerActivated()
    if not self.pinMirrorStateMachine:TryPinSyncOnlyOnPlayerActivated() then
        self:RequestMapReload("EVENT_PLAYER_ACTIVATED")
    end
end

function MiniMapMapEventController:OnPlayerZoneUpdate(_eventId, _unitTag, newZoneName)
    MiniMap.ApplyHudLocationLabelFromZoneUpdate(newZoneName)
    self:ScheduleSubzoneHudRecovery()
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
    self:RegisterGameEvent(EVENT_ZONE_CHANGED, function (_, zoneName, subZoneName, newSubzone, zoneId, subZoneId)
        mapEventController:OnZoneChanged(zoneName, subZoneName, newSubzone, zoneId, subZoneId)
    end)
    self:RegisterGameEvent(EVENT_PLAYER_ACTIVATED, function () mapEventController:OnPlayerActivated() end)
    self:RegisterGameEvent(EVENT_ZONE_UPDATE, function (eventId, unitTag, newZoneName)
        mapEventController:OnPlayerZoneUpdate(eventId, unitTag, newZoneName)
    end)
    self.eventAnchor:AddFilterForEvent(EVENT_ZONE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    self:RegisterGameEvent(EVENT_START_FAST_TRAVEL_INTERACTION, function () mapEventController:OnFastTravelStart() end)
    self:RegisterGameEvent(EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, function () mapEventController:OnFastTravelStart() end)
    self:RegisterGameEvent(EVENT_END_FAST_TRAVEL_INTERACTION, function () mapEventController:OnFastTravelEnd() end)
    self:RegisterGameEvent(EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, function () mapEventController:OnFastTravelEnd() end)
    for _, eventId in ipairs(PIN_DIRTY_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:SchedulePinSync() end)
    end
    self:RegisterGameEvent(EVENT_MAP_PING, function (eventCode, pingEventType, pingType, pingTag, x, y, isPingOwner)
        mapEventController:OnMapPing(eventCode, pingEventType, pingType, pingTag, x, y, isPingOwner)
    end)
    self:RegisterGameEvent(EVENT_POI_UPDATED, function ()
        mapEventController:RequestMapObjectivePinSync()
    end)
    self:RegisterGameEvent(EVENT_POI_DISCOVERED, function ()
        mapEventController:RequestMapObjectivePinSync()
    end)
    self:RegisterGameEvent(EVENT_POIS_INITIALIZED, function ()
        mapEventController:RequestMapObjectivePinSync()
    end)
    for _, eventId in ipairs(CMAP_QUEST_PIN_SYNC_FULL_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:RequestQuestPinSyncFull() end)
    end
    for _, eventId in ipairs(CMAP_ZONE_STORY_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:RequestZoneStoryPinSync() end)
    end
    for _, eventId in ipairs(CMAP_ANTIQUITY_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:RequestDigSitePinSync() end)
    end
    for _, eventId in ipairs(CMAP_KEEP_EVENT_IDS) do
        self:RegisterGameEvent(eventId, function () mapEventController:SchedulePinSync() end)
    end
    self:RegisterGameEvent(EVENT_CURRENT_SUBZONE_LIST_CHANGED, function ()
        mapEventController:OnCurrentSubzoneListChanged()
    end)
    self:RegisterGameEvent(EVENT_COMPANION_ACTIVATED, function () mapEventController:RequestCompanionPinSync() end)
    self:RegisterGameEvent(EVENT_COMPANION_DEACTIVATED, function () mapEventController:RequestCompanionPinSync() end)
    self.onQuestTrackerTrackingStateChanged = function (_questTracker, _tracked, trackType, arg1)
        if trackType == TRACK_TYPE_QUEST and arg1 then
            mapEventController:ScheduleDeferredQuestPinSyncLight(arg1)
        end
    end
    self.onQuestTrackerAssistStateChanged = function (unassistedData, assistedData)
        local journalIndex = unassistedData and unassistedData:GetJournalIndex() or assistedData and assistedData:GetJournalIndex()
        if journalIndex then
            mapEventController:ScheduleDeferredQuestPinSyncLight(journalIndex)
        end
    end
    FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerTrackingStateChanged", self.onQuestTrackerTrackingStateChanged)
    FOCUSED_QUEST_TRACKER:RegisterCallback("QuestTrackerAssistStateChanged", self.onQuestTrackerAssistStateChanged)
    self.onCMapHandlersRefreshedSingleQuestPins = function (journalIndex)
        MiniMap.OnCMapHandlersRefreshedQuestPins(journalIndex)
    end
    self.onCMapHandlersRefreshedAllQuestPins = function ()
        MiniMap.OnCMapHandlersRefreshedQuestPins(nil)
    end
    C_MAP_HANDLERS:RegisterCallback("RefreshedSingleQuestPins", self.onCMapHandlersRefreshedSingleQuestPins)
    C_MAP_HANDLERS:RegisterCallback("RefreshedAllQuestPins", self.onCMapHandlersRefreshedAllQuestPins)
    self.onWorldMapQuestBreadcrumbsQuestAvailable = function (questIndex)
        mapEventController:RequestQuestPinSyncLight(questIndex, true)
    end
    WORLD_MAP_QUEST_BREADCRUMBS:RegisterCallback("QuestAvailable", self.onWorldMapQuestBreadcrumbsQuestAvailable)
    self.onAntiquitiesUpdated = function ()
        mapEventController:RequestDigSitePinSync()
    end
    self.onSingleAntiquityDigSitesUpdated = function ()
        mapEventController:RequestDigSitePinSync()
    end
    ANTIQUITY_DATA_MANAGER:RegisterCallback("AntiquitiesUpdated", self.onAntiquitiesUpdated)
    ANTIQUITY_DATA_MANAGER:RegisterCallback("SingleAntiquityDigSitesUpdated", self.onSingleAntiquityDigSitesUpdated)
    eventManager:RegisterForUpdate(MiniMap.moduleName .. "MapNameFallback", MINIMAP_MAP_NAME_FALLBACK_MS, function ()
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
    eventManager:UnregisterForUpdate(MiniMap.moduleName .. "MapNameFallback")
    eventManager:UnregisterForUpdate(MiniMap.moduleName .. "QuestTrackerPinSync")
    eventManager:UnregisterForUpdate(MiniMap.moduleName .. "QuestPinLightSync")
    eventManager:UnregisterForUpdate(MiniMap.moduleName .. "SubzoneHudRecovery")
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
    if self.onWorldMapQuestBreadcrumbsQuestAvailable then
        WORLD_MAP_QUEST_BREADCRUMBS:UnregisterCallback("QuestAvailable", self.onWorldMapQuestBreadcrumbsQuestAvailable)
        self.onWorldMapQuestBreadcrumbsQuestAvailable = nil
    end
end
