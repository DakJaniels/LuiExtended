-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_ZOOMIN", "Zoom in")
ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_ZOOMOUT", "Zoom out")
ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_ZOOMRESET", "Zoom reset")
ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_RECENTER", "Recenter MiniMap")
ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_TOGGLE_SHOW", "Toggle MiniMap visibility")
ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_TOGGLE_COMBAT", "Toggle MiniMap in combat")
ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_TOGGLE_FIXED", "Toggle zone scroll lock")
ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_HOLD_ZOOMIN", "Hold zoom in MiniMap")
ZO_CreateStringId("SI_BINDING_NAME_LUIE_MINIMAP_HOLD_ZOOMOUT", "Hold zoom out MiniMap")

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

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
        if MiniMap.mapEventController then
            MiniMap.mapEventController:Unregister()
        end
        if MiniMap.runtime then
            MiniMap.runtime:Stop()
        end
        MiniMap.ShutdownNativeWorldMapContainer()
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

    MiniMap.view:ApplySavedLayout(MiniMap.SV)
    MiniMap.view:SetupPlayerIcons()
    MiniMap.view:SetZoomLabel(MiniMap.zoom)
    MiniMap.mapEventController:Register()
    MiniMap.ApplyLiveSettings()
    MiniMap.RegisterVisibilityEvents()
    MiniMap.ApplyChromeFromSettings()
    MiniMap.ApplyFragmentHiddenReasons()
    MiniMap.UpdateConditionalVisibility()

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
        MiniMap.view:ApplySavedLayout(MiniMap.SV)
    end
end
