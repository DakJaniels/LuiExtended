-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local HudScene = LUIE.HudScene

local eventManager = GetEventManager()

local WORLD_MAP_SCENE_NAME_KEYBOARD = "worldMap"
local WORLD_MAP_SCENE_NAME_GAMEPAD = "gamepad_worldMap"

--- ZOS has no public unregister for scene StateChange; avoid duplicate handlers on re-init.
local miniMapWorldMapSceneGateRegistered = false
local miniMapWorldMapWasOpen = false

local function GetFollowPositionUpdateName()
    return MiniMap.moduleName .. "FollowPosition"
end

--- @return boolean true when follow recovery ran or is no longer needed
function MiniMap.ApplyFollowRecoveryAfterWorldMap()
    if not miniMapWorldMapWasOpen then
        return true
    end
    if not MiniMap.GetMapFollowsPlayer() then
        miniMapWorldMapWasOpen = false
        return true
    end
    local mapController = MiniMap.mapController
    local runtime = MiniMap.runtime
    if not mapController or not runtime then
        return false
    end
    if not mapController:IsReady() then
        return false
    end
    miniMapWorldMapWasOpen = false
    runtime:ClearFollowScrollCache()
    runtime:ApplyScrollCenterOnPlayer(
        mapController:GetMapContentWidth(),
        mapController:GetMapContentHeight()
    )
    return true
end


--- @class MiniMapHUDSceneFragment : ZO_HUDFadeSceneFragment
--- @field SetHiddenForReason fun(self: MiniMapHUDSceneFragment, reason: string, hidden: boolean, customShowDuration?: number, customHideDuration?: number)
local MiniMapHUDSceneFragment = ZO_HUDFadeSceneFragment:Subclass()

function MiniMapHUDSceneFragment:New(...)
    return ZO_HUDFadeSceneFragment.New(self, ...)
end

--- @param control Control
function MiniMapHUDSceneFragment:Initialize(control)
    ZO_HUDFadeSceneFragment.Initialize(self, control, 0, 0)
end

function MiniMapHUDSceneFragment:OnShown()
    ZO_HUDFadeSceneFragment.OnShown(self)
    MiniMap.ApplyFollowRecoveryAfterWorldMap()
    MiniMap.TryAttachNativeWorldMapContainer()
    if MiniMap.mapController and MiniMap.mapController:IsReady() then
        MiniMap.RefreshNativeWorldMapContainer()
        MiniMap.ReapplyNativeHudMapOverlayLayout()
    end
    MiniMap.UpdateGameplayTickers()
end

function MiniMapHUDSceneFragment:OnHidden()
    ZO_HUDFadeSceneFragment.OnHidden(self)
    MiniMap.UpdateGameplayTickers()
end

MiniMap.MiniMapHUDSceneFragment = MiniMapHUDSceneFragment

--- @param scene ZO_Scene|nil
--- @return boolean
function MiniMap.IsMiniMapHudScene(scene)
    if not HudScene.IsHudGameplayScene(scene) then
        return false
    end
    if scene == LOOT_SCENE then
        return MiniMap.SV.allowOnLootScene == true
    end
    return true
end

function MiniMap.IsWorldMapBlockingMiniMapWork()
    return MiniMap.worldMapBlocksMiniMapWork == true or ZO_WorldMap_IsWorldMapShowing()
end

function MiniMap.UpdateGameplayTickers()
    local followPositionUpdateName = GetFollowPositionUpdateName()
    eventManager:UnregisterForUpdate(followPositionUpdateName)
    local topLevel = LUIE_MiniMap
    if topLevel then
        topLevel:SetHandler("OnUpdate", nil)
    end
    if not MiniMap.ShouldRunFollowUpdate() then
        return
    end
    eventManager:RegisterForUpdate(followPositionUpdateName, MiniMap.GetMovingPinRefreshMs(), function ()
        local runtime = MiniMap.runtime
        if runtime then
            runtime:OnFollowTick()
        end
    end)
end

function MiniMap.ApplyFragmentHiddenReasons()
    local hudSceneFragment = MiniMap.hudSceneFragment
    if not hudSceneFragment then
        return
    end
    MiniMap.fragmentHiddenReasonCache = MiniMap.fragmentHiddenReasonCache or {}
    local cache = MiniMap.fragmentHiddenReasonCache

    local function setHiddenReasonIfChanged(reason, hidden)
        if cache[reason] ~= hidden then
            cache[reason] = hidden
            hudSceneFragment:SetHiddenForReason(reason, hidden)
        end
    end

    if MiniMap.consoleLayoutPreviewActive == true then
        setHiddenReasonIfChanged("MiniMapSession", false)
        setHiddenReasonIfChanged("MiniMapCombat", false)
        setHiddenReasonIfChanged("MiniMapMounted", false)
        setHiddenReasonIfChanged("MiniMapHousing", false)
        return
    end

    local sessionHidden = MiniMap.sessionMapVisible == false or MiniMap.SV.allowOnGameplayHud == false
    setHiddenReasonIfChanged("MiniMapSession", sessionHidden)
    setHiddenReasonIfChanged("MiniMapCombat", IsUnitInCombat("player") and MiniMap.SV.allowDuringCombat ~= true)
    setHiddenReasonIfChanged("MiniMapMounted", IsMounted() and MiniMap.SV.allowWhileMounted ~= true)
    setHiddenReasonIfChanged("MiniMapHousing", MiniMap.IsPlayerInHouse() and MiniMap.SV.allowInPlayerHousing ~= true)
    local deathRecapHidden = MiniMap.IsDeathRecapVisible() and MiniMap.SV.allowOnDeathRecap == false
    setHiddenReasonIfChanged("MiniMapDeathRecap", deathRecapHidden)
end

function MiniMap.OnWorldMapOpening(sceneName)
    miniMapWorldMapWasOpen = true
    if MiniMap.runtime then
        MiniMap.runtime:ClearFollowScrollCache()
    end
    MiniMap.RestoreWorldMapContainerToWorldMap()
    MiniMap.worldMapBlocksMiniMapWork = true
    local pinController = MiniMap.pinController
    if pinController then
        pinController:RestoreAllDigSitePolygonsToWorldMap()
    end
    MiniMap.UpdateGameplayTickers()
    SCENE_MANAGER:CallWhen(sceneName, SCENE_HIDDEN, function ()
        MiniMap.OnWorldMapClosed()
    end)
end

function MiniMap.FlushWorldMapQueuedWork()
    if not MiniMap.Enabled then
        return
    end
    local pinMirrorStateMachine = MiniMap.pinMirrorStateMachine
    if pinMirrorStateMachine.mapReloadQueuedWhileWorldMap then
        pinMirrorStateMachine.mapReloadQueuedWhileWorldMap = false
        local reloadReason = pinMirrorStateMachine.mapReloadQueuedReason or "WorldMapClosed"
        pinMirrorStateMachine.mapReloadQueuedReason = nil
        pinMirrorStateMachine:RequestMapReload(reloadReason)
    elseif pinMirrorStateMachine.pinSyncQueuedWhileWorldMap then
        pinMirrorStateMachine.pinSyncQueuedWhileWorldMap = false
        MiniMap.TryAttachNativeWorldMapContainer()
        MiniMap.RefreshNativeWorldMapContainer()
        MiniMap.ReapplyNativeHudMapOverlayLayout()
        MiniMap.FirePinResyncCallbacks()
        MiniMap.ApplyHudNativePinLayoutAfterRefresh()
    end
    local mapEventController = MiniMap.mapEventController
    if mapEventController and mapEventController.companionPinSyncQueuedWhileWorldMap then
        mapEventController.companionPinSyncQueuedWhileWorldMap = false
        MiniMap.RunWithPlayerMapForMirror(function ()
            WORLD_MAP_MANAGER:RefreshCompanionPins()
        end)
    end
end

function MiniMap.OnWorldMapClosed()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.worldMapBlocksMiniMapWork = false
    MiniMap.FlushWorldMapQueuedWork()
    MiniMap.UpdateGameplayTickers()
    MiniMap.TryAttachNativeWorldMapContainer()
    if MiniMap.mapController and MiniMap.mapController:IsReady() then
        MiniMap.RefreshNativeWorldMapContainer()
        MiniMap.ReapplyNativeHudMapOverlayLayout()
    end
    MiniMap.ApplyFollowRecoveryAfterWorldMap()
end

local function OnWorldMapSceneStateChange(sceneName, oldState, newState)
    if not MiniMap.Enabled then
        return
    end
    if newState == SCENE_SHOWING then
        MiniMap.OnWorldMapOpening(sceneName)
    end
end

local function RegisterWorldMapSceneGate(scene, sceneName)
    scene:RegisterCallback("StateChange", function (oldState, newState)
        OnWorldMapSceneStateChange(sceneName, oldState, newState)
    end)
end

function MiniMap.SyncLootSceneFragmentAttachment()
    local hudSceneFragment = MiniMap.hudSceneFragment
    if not hudSceneFragment then
        return
    end
    if MiniMap.SV.allowOnLootScene == true then
        HudScene.AddFragmentToScenes(hudSceneFragment, { LOOT_SCENE })
    else
        HudScene.RemoveFragmentFromScenes(hudSceneFragment, { LOOT_SCENE })
    end
end

function MiniMap.RegisterMiniMapSceneIntegration()
    if MiniMap.hudSceneFragment then
        return
    end

    local topLevel = LUIE_MiniMap
    local hudSceneFragment = MiniMapHUDSceneFragment:New(topLevel)
    MiniMap.hudSceneFragment = hudSceneFragment
    topLevel.hudSceneFragment = hudSceneFragment

    HudScene.AddFragmentToScenes(hudSceneFragment, HudScene.GetGameplayScenesExcludingLoot())
    MiniMap.SyncLootSceneFragmentAttachment()

    if not miniMapWorldMapSceneGateRegistered then
        RegisterWorldMapSceneGate(WORLD_MAP_SCENE, WORLD_MAP_SCENE_NAME_KEYBOARD)
        RegisterWorldMapSceneGate(GAMEPAD_WORLD_MAP_SCENE, WORLD_MAP_SCENE_NAME_GAMEPAD)
        miniMapWorldMapSceneGateRegistered = true
    end

    if ZO_WorldMap_IsWorldMapShowing() then
        local sceneName = SCENE_MANAGER:IsShowing(WORLD_MAP_SCENE_NAME_GAMEPAD)
            and WORLD_MAP_SCENE_NAME_GAMEPAD
            or WORLD_MAP_SCENE_NAME_KEYBOARD
        MiniMap.OnWorldMapOpening(sceneName)
    else
        MiniMap.worldMapBlocksMiniMapWork = false
        MiniMap.UpdateGameplayTickers()
    end
end

function MiniMap.UnregisterMiniMapSceneIntegration()
    miniMapWorldMapSceneGateRegistered = false
    miniMapWorldMapWasOpen = false
    MiniMap.SetConsoleLayoutPreviewActive(false)
    MiniMap.ShutdownNativeWorldMapContainer()
    MiniMap.worldMapBlocksMiniMapWork = false
    eventManager:UnregisterForUpdate(GetFollowPositionUpdateName())
    if LUIE_MiniMap then
        LUIE_MiniMap:SetHandler("OnUpdate", nil)
    end

    local hudSceneFragment = MiniMap.hudSceneFragment
    if not hudSceneFragment then
        return
    end

    local scenesToClear = HudScene.GetGameplayScenesExcludingLoot()
    scenesToClear[#scenesToClear + 1] = LOOT_SCENE
    HudScene.RemoveFragmentFromScenes(hudSceneFragment, scenesToClear)

    LUIE_MiniMap.hudSceneFragment = nil
    MiniMap.hudSceneFragment = nil
    MiniMap.fragmentHiddenReasonCache = nil
end

function MiniMap.RefreshSceneFragments()
    MiniMap.SyncLootSceneFragmentAttachment()
end
