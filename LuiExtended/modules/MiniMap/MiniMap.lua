-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap
local eventManager = GetEventManager()

--- @param enabled boolean
function MiniMap.Initialize(enabled)
    local isCharacterSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    if isCharacterSpecific then
        MiniMap.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.MiniMap, LUIE.SVVer, nil, MiniMap.Defaults, LUIE.SavedVarsProfile)
    else
        MiniMap.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.MiniMap, LUIE.SVVer, nil, MiniMap.Defaults, LUIE.SavedVarsProfile)
    end

    if not enabled then
        if MiniMap.view then
            MiniMap.view:ShutdownZoomLabelFade()
            MiniMap.view:ShutdownZoomButtonsFade()
        end
        if MiniMap.pinMirrorStateMachine then
            MiniMap.pinMirrorStateMachine:Stop()
            MiniMap.pinMirrorStateMachine = nil
        end
        MiniMap.playerMapMirrorDepth = 0
        MiniMap.playerMapMirrorPendingCallback = nil
        MiniMap.pendingPostReloadUILayout = nil
        MiniMap.pinResyncCallbacks = nil
        MiniMap.SetConsoleLayoutPreviewActive(false)
        if MiniMap.mapEventController then
            MiniMap.mapEventController:Unregister()
        end
        if MiniMap.runtime then
            MiniMap.runtime:Stop()
        end
        MiniMap.ShutdownNativeWorldMapContainer()
        MiniMap.DisableHudMinimapWorldMapInputPreHooks()
        -- MiniMap.DisableHudMinimapPinInteractionPreHooks()
        MiniMap.UnregisterMiniMapSceneIntegration()
        LUIE_MiniMap:SetHidden(true)
        MiniMap.Enabled = false
        return
    end

    MiniMap.sessionMapVisible = true

    MiniMap.Enabled = true
    MiniMap.zoom = MiniMap.SV.resetZoomLevel

    MiniMap.view = MiniMap.MiniMapView:New(LUIE_MiniMap)
    MiniMap.mapController = MiniMap.MiniMapMapController:New(MiniMap.view)
    MiniMap.ClampSavedDefaultZoom()
    MiniMap.zoom = MiniMap.SV.resetZoomLevel
    MiniMap.mapController:ClampZoomToLimits(false)
    MiniMap.pinController = MiniMap.MiniMapPinController:New(MiniMap.view, MiniMap.mapController)
    MiniMap.pinResyncCallbacks = nil
    MiniMap.RegisterPinResyncCallback(function ()
        MiniMap.SyncHudOverlayPinsAfterNativeRefresh()
    end)
    MiniMap.runtime = MiniMap.MiniMapRuntime:New(MiniMap.view, MiniMap.mapController, MiniMap.pinController)
    local followPlayer = MiniMap.SV.followPlayer == true and MiniMap.SV.zoneScrollLockEnabled ~= true
    MiniMap.runtime.mapFollowsPlayer = followPlayer
    MiniMap.pinMirrorStateMachine = MiniMap.MiniMapPinMirrorStateMachine:New(nil, MiniMap.mapController, MiniMap.pinController)
    MiniMap.mapEventController = MiniMap.MiniMapMapEventController:New(
        MiniMap.mapController,
        MiniMap.pinController,
        MiniMap.pinMirrorStateMachine
    )
    MiniMap.pinMirrorStateMachine.mapEventController = MiniMap.mapEventController
    MiniMap.inputController = MiniMap.MiniMapInputController:New(MiniMap.view, MiniMap.mapController, MiniMap.runtime)
    MiniMap.InstallHudMinimapWorldMapInputPreHooks()
    -- MiniMap.InstallHudMinimapPinInteractionPreHooks()

    MiniMap.view:ApplySavedLayout(MiniMap.SV)
    MiniMap.view:SetupPlayerIcons()
    MiniMap.view:SetZoomLabel(MiniMap.zoom)
    MiniMap.mapEventController:Register()
    MiniMap.ApplyLiveSettings()
    MiniMap.RegisterVisibilityEvents()
    MiniMap.ApplyChromeFromSettings()
    MiniMap.ApplyFragmentHiddenReasons()
    MiniMap.UpdateConditionalVisibility()
    eventManager:RegisterForEvent("LUIE_MiniMap_GamePad_Sync", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function ()
        local mapController = MiniMap.mapController
        local mapData = mapController.map
        MiniMap.pinController:SyncLuiOverlays(mapData)
    end)
    zo_callLater(function ()
                     MiniMap.mapEventController:RequestMapReload("Initialize")
                     if not MiniMap.GetMapFollowsPlayer() then
                         MiniMap.runtime:ApplyScrollFromPanOffsets()
                     end
                     MiniMap.UpdateGameplayTickers()
                 end, 1000)
end

function MiniMap.ResetPosition()
    MiniMap.SV.offsetX = MiniMap.Defaults.offsetX
    MiniMap.SV.offsetY = MiniMap.Defaults.offsetY
    if MiniMap.view then
        MiniMap.ApplyFrameLayoutFromSavedSettings(true)
    end
end
