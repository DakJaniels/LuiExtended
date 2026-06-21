-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local eventManager = GetEventManager()

local pinMirrorGameplayTickersUpdateScheduled = false
local pinMirrorStateMachineLastDebugStateName = nil

MINIMAP_MIRROR_TRIGGER_COMMANDS =
{
    MAP_RELOAD_REQUESTED = "MAP_RELOAD_REQUESTED",
    MAP_RELOAD_COMPLETE = "MAP_RELOAD_COMPLETE",
    FAST_TRAVEL_START = "FAST_TRAVEL_START",
    FAST_TRAVEL_END = "FAST_TRAVEL_END",
    ZONE_RESET_COMPLETE = "ZONE_RESET_COMPLETE",
    MODULE_ENABLED = "MODULE_ENABLED",
    MODULE_DISABLED = "MODULE_DISABLED",
}

--- @class MiniMapPinMirrorStateMachine : ZO_StateMachine_Base
--- @field mapEventController MiniMapMapEventController
--- @field mapController MiniMapMapController
--- @field pinController MiniMapPinController
--- @field pinSyncQueuedWhileMapReloading boolean
--- @field pinSyncQueuedWhileWorldMap boolean
--- @field mapReloadQueuedWhileWorldMap boolean
--- @field mapReloadQueuedReason string|nil
--- @field pendingMapReloadReason string|nil
--- @field pendingMapReloadAttempt number
--- @field mapReloadInProgress boolean
--- @field mapReloadCompletionHandled boolean
--- @field mapReloadCompletePendingAfterMirror boolean
--- @field mapReloadCompleteNotifyDeferredScheduled boolean
MiniMapPinMirrorStateMachine = ZO_StateMachine_Base:Subclass()
MiniMap.MiniMapPinMirrorStateMachine = MiniMapPinMirrorStateMachine

--- @param mapEventController MiniMapMapEventController
--- @param mapController MiniMapMapController
--- @param pinController MiniMapPinController
--- @return MiniMapPinMirrorStateMachine
function MiniMapPinMirrorStateMachine:New(mapEventController, mapController, pinController)
    local object = ZO_StateMachine_Base.New(self)
    --- @cast object MiniMapPinMirrorStateMachine
    object:Initialize(mapEventController, mapController, pinController)
    return object
end

--- @param mapEventController MiniMapMapEventController
--- @param mapController MiniMapMapController
--- @param pinController MiniMapPinController
function MiniMapPinMirrorStateMachine:Initialize(mapEventController, mapController, pinController)
    ZO_StateMachine_Base.Initialize(self, "MINIMAP_MAP_STATE_MACHINE")

    self.mapEventController = mapEventController
    self.mapController = mapController
    self.pinController = pinController
    self.pinSyncQueuedWhileMapReloading = false
    self.pinSyncQueuedWhileWorldMap = false
    self.mapReloadQueuedWhileWorldMap = false
    self.mapReloadQueuedReason = nil
    self.pendingMapReloadReason = nil
    self.pendingMapReloadAttempt = 0
    self.mapReloadInProgress = false
    self.mapReloadCompletionHandled = false
    self.mapReloadCompletePendingAfterMirror = false
    self.mapReloadCompleteNotifyDeferredScheduled = false

    local commands = MINIMAP_MIRROR_TRIGGER_COMMANDS

    self:AddState("Disabled")
    self:AddState("Idle")
    self:AddState("FastTravelBlocked")
    self:AddState("MapReloading")
    self:AddState("ZoneReset")

    self:AddEdgeAutoName("Disabled", "Idle")
    self:AddEdgeAutoName("Idle", "FastTravelBlocked")
    self:AddEdgeAutoName("FastTravelBlocked", "Idle")
    self:AddEdgeAutoName("Idle", "MapReloading")
    self:AddEdgeAutoName("MapReloading", "Idle")
    self:AddEdgeAutoName("ZoneReset", "MapReloading")

    self:AddTrigger("DISABLED_TO_IDLE", ZO_StateMachine_TriggerStateCallback, commands.MODULE_ENABLED)
    self:AddTrigger("IDLE_TO_FAST_TRAVEL_BLOCKED", ZO_StateMachine_TriggerStateCallback, commands.FAST_TRAVEL_START)
    self:AddTrigger("FAST_TRAVEL_BLOCKED_TO_IDLE", ZO_StateMachine_TriggerStateCallback, commands.FAST_TRAVEL_END)
    self:AddTrigger("IDLE_TO_MAP_RELOADING", ZO_StateMachine_TriggerStateCallback, commands.MAP_RELOAD_REQUESTED)
    self:AddTrigger("MAP_RELOADING_TO_IDLE", ZO_StateMachine_TriggerStateCallback, commands.MAP_RELOAD_COMPLETE)
    self:AddTrigger("ZONE_RESET_TO_MAP_RELOADING", ZO_StateMachine_TriggerStateCallback, commands.ZONE_RESET_COMPLETE)

    self:AddTriggerToEdge("DISABLED_TO_IDLE", "Disabled_TO_Idle")
    self:AddTriggerToEdge("IDLE_TO_FAST_TRAVEL_BLOCKED", "Idle_TO_FastTravelBlocked")
    self:AddTriggerToEdge("FAST_TRAVEL_BLOCKED_TO_IDLE", "FastTravelBlocked_TO_Idle")
    self:AddTriggerToEdge("IDLE_TO_MAP_RELOADING", "Idle_TO_MapReloading")
    self:AddTriggerToEdge("MAP_RELOADING_TO_IDLE", "MapReloading_TO_Idle")
    self:AddTriggerToEdge("ZONE_RESET_TO_MAP_RELOADING", "ZoneReset_TO_MapReloading")

    self:GetEdgeByName("Idle_TO_MapReloading"):SetConditional(function ()
        return MiniMap.Enabled and not MiniMap.fastTravel
    end)

    local stateMachine = self

    self:GetStateByName("ZoneReset"):RegisterCallback("OnActivated", function ()
        stateMachine:PerformZoneResetCleanup()
        stateMachine:FireCallbacks(commands.ZONE_RESET_COMPLETE)
    end)

    self:GetStateByName("MapReloading"):RegisterCallback("OnActivated", function ()
        stateMachine.mapReloadCompletionHandled = false
        if MiniMap.IsWorldMapBlockingMiniMapWork() then
            stateMachine.mapReloadQueuedWhileWorldMap = true
            stateMachine.mapReloadQueuedReason = stateMachine.pendingMapReloadReason or "Event"
            stateMachine.mapReloadInProgress = false
            if MiniMap.SV and MiniMap.SV.pinMirrorStateMachineDebug then
                LUIE:Log("Debug", "[MiniMap SM] MapReloading bail ZO still showing")
            end
            stateMachine:SetCurrentState("Idle")
            return
        end
        if stateMachine.mapReloadInProgress then
            return
        end
        stateMachine.mapReloadInProgress = true
        local reason = stateMachine.pendingMapReloadReason or "Event"
        local reloadAttemptIndex = stateMachine.pendingMapReloadAttempt or 0
        stateMachine.mapController:ReloadWorldMap(reason, reloadAttemptIndex)
    end)

    self:RegisterCallback("OnStateChange", function ()
        if not pinMirrorGameplayTickersUpdateScheduled then
            pinMirrorGameplayTickersUpdateScheduled = true
            local gameplayTickersUpdateName = MiniMap.moduleName .. "PinMirrorGameplayTickers"
            eventManager:RegisterForUpdate(gameplayTickersUpdateName, 0, function ()
                                               pinMirrorGameplayTickersUpdateScheduled = false
                                               MiniMap.UpdateGameplayTickers()
                                           end, true)
        end
        if MiniMap.SV and MiniMap.SV.pinMirrorStateMachineDebug then
            local currentState = stateMachine:GetCurrentState()
            if currentState then
                local stateName = currentState:GetName()
                if stateName ~= pinMirrorStateMachineLastDebugStateName then
                    pinMirrorStateMachineLastDebugStateName = stateName
                    LUIE:Log("Debug", string.format("[MiniMap SM] %s", stateName))
                end
            end
        end
    end)
end

function MiniMapPinMirrorStateMachine:ApplyDebugLoggingFromSavedVars()
    self:SetDebugLoggingEnabled(false)
end

function MiniMapPinMirrorStateMachine:Start()
    self:SetCurrentState("Disabled")
    self:ApplyDebugLoggingFromSavedVars()
    self:FireCallbacks(MINIMAP_MIRROR_TRIGGER_COMMANDS.MODULE_ENABLED)
end

function MiniMapPinMirrorStateMachine:Stop()
    pinMirrorGameplayTickersUpdateScheduled = false
    eventManager:UnregisterForUpdate(MiniMap.moduleName .. "PinMirrorGameplayTickers")
    eventManager:UnregisterForUpdate(MiniMap.moduleName .. "MapReloadCompleteNotify")
    MiniMap.CancelWorldMapUnblockedWait()
    self.mapReloadCompleteNotifyDeferredScheduled = false
    self.pinSyncQueuedWhileMapReloading = false
    self.pinSyncQueuedWhileWorldMap = false
    self.mapReloadQueuedWhileWorldMap = false
    self.mapReloadQueuedReason = nil
    self.mapReloadInProgress = false
    self.mapReloadCompletionHandled = false
    self.mapReloadCompletePendingAfterMirror = false
    pinMirrorStateMachineLastDebugStateName = nil
    self:SetCurrentState("Disabled")
    self:Reset()
end

function MiniMapPinMirrorStateMachine:PerformZoneResetCleanup()
    local pinController = self.pinController
    if pinController then
        pinController:ReleaseAllPinPools()
    end
end

function MiniMapPinMirrorStateMachine:InterruptZoneReset()
    self:SetCurrentState("ZoneReset")
end

--- @param reason string
function MiniMapPinMirrorStateMachine:RequestMapReload(reason)
    if not MiniMap.Enabled or not self.mapController then
        return
    end
    if MiniMap.fastTravel then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        self.mapReloadQueuedWhileWorldMap = true
        self.mapReloadQueuedReason = reason or "Event"
        if MiniMap.SV and MiniMap.SV.pinMirrorStateMachineDebug then
            LUIE:Log("Debug", string.format("[MiniMap SM] RequestMapReload queued (world map): %s", reason or "Event"))
        end
        return
    end
    if self:IsCurrentState("MapReloading") and self.mapReloadInProgress then
        return
    end
    self.pendingMapReloadReason = reason or "Event"
    self.pendingMapReloadAttempt = 0

    if self:IsCurrentState("Idle") then
        self:FireCallbacks(MINIMAP_MIRROR_TRIGGER_COMMANDS.MAP_RELOAD_REQUESTED)
    elseif not self:IsCurrentState("MapReloading") and not self:IsCurrentState("ZoneReset") then
        self:SetCurrentState("MapReloading")
    end
end

--- @return boolean true when pin refresh ran without tile reload
function MiniMapPinMirrorStateMachine:TryPinSyncOnlyOnPlayerActivated()
    if not MiniMap.DoesHudMirrorMapIdentityMatchLoadedPlayerMap() then
        return false
    end
    MiniMap.TryAttachNativeWorldMapContainer()
    MiniMap.RefreshNativeWorldMapContainer()
    MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
    return true
end

function MiniMapPinMirrorStateMachine:OnMapReloadStarted()
    if not self:IsCurrentState("MapReloading") and not self:IsCurrentState("ZoneReset") then
        self:SetCurrentState("MapReloading")
    end
end

function MiniMapPinMirrorStateMachine:NotifyMapReloadComplete()
    if not self:IsCurrentState("MapReloading") then
        return
    end
    if self.mapReloadCompletionHandled then
        return
    end
    self.mapReloadCompletionHandled = true
    self.mapReloadInProgress = false
    self:FireCallbacks(MINIMAP_MIRROR_TRIGGER_COMMANDS.MAP_RELOAD_COMPLETE)
    if self:IsCurrentState("Idle") then
        MiniMap.TryAttachNativeWorldMapContainer()
        MiniMap.RefreshNativeWorldMapContainer()
        MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
        MiniMap.FirePinResyncCallbacks()
        self:FlushQueuedPinSyncAfterIdle()
    end
end

--- Terminal reload failure after max retries: return to Idle without native refresh (map not ready).
function MiniMapPinMirrorStateMachine:NotifyMapReloadFailed()
    if not self:IsCurrentState("MapReloading") then
        return
    end
    if self.mapReloadCompletionHandled then
        return
    end
    self.mapReloadCompletionHandled = true
    self.mapReloadInProgress = false
    self:FireCallbacks(MINIMAP_MIRROR_TRIGGER_COMMANDS.MAP_RELOAD_COMPLETE)
    MiniMap.UpdateGameplayTickers()
end

function MiniMapPinMirrorStateMachine:ScheduleNotifyMapReloadCompleteNextFrame()
    if self.mapReloadCompleteNotifyDeferredScheduled then
        return
    end
    self.mapReloadCompleteNotifyDeferredScheduled = true
    local stateMachine = self
    local mapReloadCompleteNotifyUpdateName = MiniMap.moduleName .. "MapReloadCompleteNotify"
    eventManager:RegisterForUpdate(mapReloadCompleteNotifyUpdateName, 0, function ()
                                       stateMachine.mapReloadCompleteNotifyDeferredScheduled = false
                                       if not MiniMap.Enabled then
                                           return
                                       end
                                       if MiniMap.IsWorldMapBlockingMiniMapWork() then
                                           stateMachine.mapReloadCompletePendingAfterMirror = true
                                           MiniMap.RunWhenWorldMapUnblocked(function ()
                                               if not MiniMap.Enabled then
                                                   return
                                               end
                                               if not stateMachine:IsCurrentState("MapReloading") then
                                                   stateMachine.mapReloadCompletePendingAfterMirror = false
                                                   return
                                               end
                                               stateMachine.mapReloadCompletePendingAfterMirror = false
                                               stateMachine:NotifyMapReloadComplete()
                                           end)
                                           return
                                       end
                                       if not stateMachine:IsCurrentState("MapReloading") then
                                           return
                                       end
                                       stateMachine:NotifyMapReloadComplete()
                                   end, true)
end

function MiniMapPinMirrorStateMachine:ScheduleNotifyMapReloadCompleteAfterMirror()
    if MiniMap.playerMapMirrorDepth > 0 then
        self.mapReloadCompletePendingAfterMirror = true
        return
    end
    if self:IsCurrentState("MapReloading") then
        self:ScheduleNotifyMapReloadCompleteNextFrame()
    else
        self:NotifyMapReloadComplete()
    end
end

function MiniMapPinMirrorStateMachine:FlushQueuedPinSyncAfterIdle()
    if self.pinSyncQueuedWhileMapReloading and self:IsCurrentState("Idle") then
        self.pinSyncQueuedWhileMapReloading = false
        MiniMap.TryAttachNativeWorldMapContainer()
        MiniMap.RefreshNativeWorldMapContainer()
        MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
        MiniMap.FirePinResyncCallbacks()
        if MiniMap.IsNativeWorldMapContainerAttached() then
            MiniMap.ApplyHudNativePinLayoutAfterRefresh()
        end
    end
end

function MiniMapPinMirrorStateMachine:OnFastTravelStart()
    if self:IsCurrentState("Idle") then
        self:FireCallbacks(MINIMAP_MIRROR_TRIGGER_COMMANDS.FAST_TRAVEL_START)
    else
        self:SetCurrentState("FastTravelBlocked")
    end
end

function MiniMapPinMirrorStateMachine:OnFastTravelEnd()
    if self:IsCurrentState("FastTravelBlocked") then
        self:FireCallbacks(MINIMAP_MIRROR_TRIGGER_COMMANDS.FAST_TRAVEL_END)
    else
        self:SetCurrentState("Idle")
    end
end

function MiniMapPinMirrorStateMachine:RequestPinSyncImmediate()
    if not MiniMap.Enabled or not self.mapController then
        return
    end
    if MiniMap.fastTravel or self:IsCurrentState("FastTravelBlocked") then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        MiniMap.QueuePinMirrorWorkWhileWorldMapBlocked(self)
        return
    end
    if self:IsCurrentState("MapReloading") or self:IsCurrentState("ZoneReset") then
        self.pinSyncQueuedWhileMapReloading = true
        return
    end
    if not self.mapController:IsReady() then
        self.pinSyncQueuedWhileMapReloading = true
        return
    end
    MiniMap.TryAttachNativeWorldMapContainer()
    MiniMap.RefreshNativeWorldMapContainer()
    MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
    MiniMap.FirePinResyncCallbacks()
    if MiniMap.IsNativeWorldMapContainerAttached() then
        MiniMap.ApplyHudNativePinLayoutAfterRefresh()
    end
end
