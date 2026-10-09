-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local eventManager = GetEventManager()

LUIE_MINIMAP_MAP_TRIGGER_COMMANDS =
{
    START = "START",
    STOP = "STOP",
    PAUSE = "PAUSE",
    RESUME = "RESUME",
    MAP_CHANGED = "MAP_CHANGED",
    TILES_READY = "TILES_READY",
}

local PAUSE_REASON_WORLD_MAP = "WorldMap"
local PAUSE_REASON_FAST_TRAVEL = "FastTravel"
--- A map click that ZOS immediately undoes (SetMapToPlayerLocation pops back to the parent map) is a ping-pong;
--- the parent map is then left alone until the next zone change.
local MAP_CLICK_REVERT_WINDOW_MS = 3000

--- Owns every minimap object and the single map state machine (Disabled / LoadingTiles / Idle / Paused).
--- The world map stays untouched: the manager updates the hidden ZO_WorldMap OnUpdate handler so ZOS refreshes its
--- own pins and map identity, and the layers mirror the result.
--- @class LUIE_MiniMap_Manager : ZO_InitializingCallbackObject
--- @field root TopLevelWindow
--- @field frame LUIE_MiniMap_Frame
--- @field panAndZoom LUIE_MiniMap_PanAndZoom
--- @field tileLayer LUIE_MiniMap_TileLayer
--- @field pinLayer LUIE_MiniMap_PinLayer
--- @field playerPip LUIE_MiniMap_PlayerPip
--- @field input LUIE_MiniMap_Input
--- @field visibility LUIE_MiniMap_Visibility
--- @field integrations LUIE_MiniMap_Integrations
--- @field mapStateMachine ZO_StateMachine_Base
--- @field running boolean
--- @field fragmentShowing boolean
--- @field intervalUpdateRegistered boolean
--- @field frameUpdateRegistered boolean
--- @field worldMapUpdateHandler fun(control: Control, currentTimeS: number)|nil
--- @field pauseReasons table<string, boolean>
--- @field mapIdentityDirty boolean
--- @field currentMapName string|nil
--- @field zoneName string|nil
--- @field subZoneName string|nil
--- @field displayedLocationName string|nil
--- @field mapClickSuppressedMapNames table<string, boolean>
--- @field lastMapClickFromMapName string|nil
--- @field lastMapClickToMapName string|nil
--- @field lastMapClickTimeMs number
--- @field mapClickPending boolean
--- @field onWorldMapChangedCallback fun()
LUIE_MiniMap_Manager = ZO_InitializingCallbackObject:Subclass()

--- @param rootControl TopLevelWindow
function LUIE_MiniMap_Manager:Initialize(rootControl)
    self.root = rootControl
    self.running = false
    self.fragmentShowing = false
    self.intervalUpdateRegistered = false
    self.frameUpdateRegistered = false
    self.pauseReasons = {}
    self.mapIdentityDirty = false
    self.currentMapName = nil
    self.zoneName = nil
    self.subZoneName = nil
    self.displayedLocationName = nil
    self.mapClickSuppressedMapNames = {}
    self.lastMapClickFromMapName = nil
    self.lastMapClickToMapName = nil
    self.lastMapClickTimeMs = 0
    self.mapClickPending = false

    self.frame = LUIE_MiniMap_Frame:New(self, rootControl)
    self.panAndZoom = LUIE_MiniMap_PanAndZoom:New(self.frame.scroll, self.frame.map)
    self.tileLayer = LUIE_MiniMap_TileLayer:New(self.frame.tilesLayer, self.panAndZoom)
    self.pinLayer = LUIE_MiniMap_PinLayer:New(self, self.frame.pinsLayer, self.frame.polygonsLayer, self.frame.linksLayer)
    self.playerPip = LUIE_MiniMap_PlayerPip:New(self.frame.player, self.frame.playerCam, self.frame.scroll, self.panAndZoom)
    self.input = LUIE_MiniMap_Input:New(self)
    self.visibility = LUIE_MiniMap_Visibility:New(self, rootControl)
    self.integrations = LUIE_MiniMap_Integrations:New(self)

    self.onWorldMapChangedCallback = function ()
        self:OnWorldMapChanged()
    end

    self.panAndZoom:RegisterCallback("ZoomChanged", function (zoom, revealTemporarily)
        self.frame:SetZoomLabel(zoom, revealTemporarily)
    end)
    self.panAndZoom:RegisterCallback("ContentSizeChanged", function ()
        self:OnContentSizeChanged()
    end)
    self.panAndZoom:RegisterCallback("FollowChanged", function ()
        self.playerPip:ApplyVisibility()
        self.pinLayer:MarkAllDirty()
    end)

    self:CreateMapStateMachine()
    self.frame:SetZoomLabel(self.panAndZoom:GetZoom(), false)
end

-- State machine --------------------------------------------------------------

function LUIE_MiniMap_Manager:CreateMapStateMachine()
    local commands = LUIE_MINIMAP_MAP_TRIGGER_COMMANDS
    local stateMachine = ZO_StateMachine_Base:New("LUIE_MINIMAP_MAP_STATE_MACHINE")
    self.mapStateMachine = stateMachine

    local disabledState = stateMachine:AddState("Disabled")
    local loadingTilesState = stateMachine:AddState("LoadingTiles")
    local idleState = stateMachine:AddState("Idle")
    local pausedState = stateMachine:AddState("Paused")

    stateMachine:AddEdgeAutoName("Disabled", "LoadingTiles")
    stateMachine:AddEdgeAutoName("LoadingTiles", "Idle")
    stateMachine:AddEdgeAutoName("LoadingTiles", "Paused")
    stateMachine:AddEdgeAutoName("LoadingTiles", "Disabled")
    stateMachine:AddEdgeAutoName("Idle", "LoadingTiles")
    stateMachine:AddEdgeAutoName("Idle", "Paused")
    stateMachine:AddEdgeAutoName("Idle", "Disabled")
    stateMachine:AddEdgeAutoName("Paused", "LoadingTiles")
    stateMachine:AddEdgeAutoName("Paused", "Disabled")

    for commandName, command in pairs(commands) do
        stateMachine:AddTrigger(commandName, ZO_StateMachine_TriggerStateCallback, command)
    end

    -- Edges register their triggers only while their from-state is active, so one trigger can serve several edges.
    stateMachine:AddTriggerToEdge("START", "Disabled_TO_LoadingTiles")
    stateMachine:AddTriggerToEdge("TILES_READY", "LoadingTiles_TO_Idle")
    stateMachine:AddTriggerToEdge("PAUSE", "LoadingTiles_TO_Paused")
    stateMachine:AddTriggerToEdge("STOP", "LoadingTiles_TO_Disabled")
    stateMachine:AddTriggerToEdge("MAP_CHANGED", "Idle_TO_LoadingTiles")
    stateMachine:AddTriggerToEdge("PAUSE", "Idle_TO_Paused")
    stateMachine:AddTriggerToEdge("STOP", "Idle_TO_Disabled")
    stateMachine:AddTriggerToEdge("RESUME", "Paused_TO_LoadingTiles")
    stateMachine:AddTriggerToEdge("STOP", "Paused_TO_Disabled")

    disabledState:RegisterCallback("OnActivated", function ()
        self:OnDisabledActivated()
    end)
    loadingTilesState:RegisterCallback("OnActivated", function ()
        self:OnLoadingTilesActivated()
    end)
    -- Updated every frame while loading (ZO_StateMachine_State:SetUpdate registers an interval-0 update).
    loadingTilesState:SetUpdate(function ()
        self:OnLoadingTilesUpdate()
    end)
    idleState:RegisterCallback("OnActivated", function ()
        self:OnIdleActivated()
    end)
    idleState:RegisterCallback("OnDeactivated", function ()
        self:OnIdleDeactivated()
    end)
    pausedState:RegisterCallback("OnActivated", function ()
        self:OnPausedActivated()
    end)

    stateMachine:SetDebugLoggingEnabled(MiniMap.debugLoggingEnabled)
    stateMachine:SetCurrentState("Disabled")
end

--- @param command string
function LUIE_MiniMap_Manager:FireCommand(command)
    MiniMap.LogDebug("Command %s (state %s)", command, self:GetStateName())
    self.mapStateMachine:FireCallbacks(command)
end

--- @return string
function LUIE_MiniMap_Manager:GetStateName()
    local state = self.mapStateMachine:GetCurrentState()
    return state and state:GetName() or "nil"
end

--- @return boolean
function LUIE_MiniMap_Manager:IsIdle()
    return self.mapStateMachine:IsCurrentState("Idle")
end

--- Click actions (waypoint, ping) are valid while the map is idle and not paused.
--- @return boolean
function LUIE_MiniMap_Manager:IsMapInteractive()
    return self.running and self:IsIdle()
end

function LUIE_MiniMap_Manager:OnDisabledActivated()
    self:RefreshUpdateRegistration()
    self.input:CancelPanDrag()
    self.pinLayer:Deactivate()
    self.pinLayer:ReleaseAll()
    self.tileLayer:ReleaseAllObjects()
    self.tileLayer.horizontalTiles = nil
    self.tileLayer.totalTiles = nil
    self.frame:HideLoading()
end

function LUIE_MiniMap_Manager:OnLoadingTilesActivated()
    self.frame:ShowLoading()
    -- Drop the previous map's pin entries now so nothing stale is drawn when the overlay lifts; the first idle interval update
    -- rebuilds them (see OnMapReady).
    self.pinLayer:ReleaseAll()
    self:BeginTileLoad()
end

--- Points the tile pool at the current world map (ZO_WorldMapTiles_Manager:UpdateTextures) and clears the dirty flag.
function LUIE_MiniMap_Manager:BeginTileLoad()
    self.mapIdentityDirty = false
    self.currentMapName = GetMapName()
    self.tileLayer:UpdateTextures()
    MiniMap.LogDebug("Loading tiles for %s (%d tiles)", self.currentMapName, self.tileLayer.totalTiles or 0)
end

function LUIE_MiniMap_Manager:OnLoadingTilesUpdate()
    if self.mapIdentityDirty then
        self:BeginTileLoad()
        return
    end
    -- No tiles (map not available yet) keeps the loading overlay up until the world map changes.
    if self.tileLayer:HasTiles() and self.tileLayer:AreTexturesLoaded() then
        self:FireCommand(LUIE_MINIMAP_MAP_TRIGGER_COMMANDS.TILES_READY)
    end
end

function LUIE_MiniMap_Manager:OnIdleActivated()
    self.frame:HideLoading()
    self:OnMapReady()
    self:RefreshUpdateRegistration()
end

function LUIE_MiniMap_Manager:OnIdleDeactivated()
    self:RefreshUpdateRegistration()
    self.input:CancelPanDrag()
end

function LUIE_MiniMap_Manager:OnPausedActivated()
    self.input:CancelPanDrag()
end

-- Map ready ------------------------------------------------------------------

--- Tiles are resident for the current world map: size the sheet, pick the zoom, scroll, rebuild pin entries.
function LUIE_MiniMap_Manager:OnMapReady()
    local tileLayer = self.tileLayer
    local panAndZoom = self.panAndZoom
    tileLayer:UpdateTilePixelSize()
    panAndZoom:SetBaseMapSize(tileLayer:GetBasePixelSize())
    tileLayer:LayoutTiles()

    if not panAndZoom:ApplyContextZoomWhenMapContextChanged() then
        panAndZoom:ClampZoomToLimits(false)
    end

    local mapName = self.currentMapName or GetMapName()
    if not panAndZoom:ApplyFixedMapScroll(mapName) then
        if panAndZoom:GetFollowsPlayer() then
            panAndZoom:ClearFollowCache()
            panAndZoom:CenterOnPlayer()
        else
            panAndZoom:ApplyPanOffsets()
        end
    end

    -- Activate marks pins and links dirty; the pin entry rebuild runs on the first idle interval update rather than here, so the
    -- map-ready frame only lays out tiles. ZOS keeps creating pins for the new map over the next few updates
    -- (ZO_Refresh groups), each of which dirties the layer again, so a synchronous rebuild here would be redone anyway.
    self.pinLayer:Activate()
    self.playerPip:ApplyVisibility()
    self.integrations:ActivateHarvestMap()
    self.integrations:OnHarvestMapMapChanged()
    self:UpdateLocationLabel()
    MiniMap.LogDebug("Map ready: %s zoom %.2f content %dx%d", mapName, panAndZoom:GetZoom(), panAndZoom:GetContentWidth(), panAndZoom:GetContentHeight())

    -- Deferred to the next interval update: a map click fires MAP_CHANGED, which must not transition from inside OnActivated.
    self.mapClickPending = true
end

--- Zone maps with a city sub-map under the player: ProcessMapClick (C API) opens that sub-map without setting
--- the WorldMap.lua local g_playerChoseCurrentMap, so ZOS keeps following the player afterwards.
function LUIE_MiniMap_Manager:TryProcessMapClickAtPlayer()
    if ZO_WorldMap_IsWorldMapShowing() then
        return
    end
    local fromMapName = GetMapName()
    if self.mapClickSuppressedMapNames[fromMapName] then
        return
    end
    local nowMs = GetFrameTimeMilliseconds()
    if self.lastMapClickFromMapName == fromMapName and (nowMs - self.lastMapClickTimeMs) < MAP_CLICK_REVERT_WINDOW_MS then
        -- We clicked into a sub-map from this map moments ago and are back on it: ZOS undid the map click. Stop fighting it.
        self.mapClickSuppressedMapNames[fromMapName] = true
        MiniMap.LogDebug("Map click suppressed for %s (ping-pong with %s)", fromMapName, tostring(self.lastMapClickToMapName))
        return
    end
    if GetUnitZoneIndex("player") ~= GetCurrentMapZoneIndex() then
        return
    end
    local normalizedX, normalizedY = GetMapPlayerPosition("player")
    if not normalizedX or not normalizedY or not WouldProcessMapClick(normalizedX, normalizedY) then
        return
    end
    local result = ProcessMapClick(normalizedX, normalizedY)
    if result == SET_MAP_RESULT_MAP_CHANGED then
        self.lastMapClickFromMapName = fromMapName
        self.lastMapClickToMapName = GetMapName()
        self.lastMapClickTimeMs = nowMs
        MiniMap.LogDebug("Map click from %s into %s", fromMapName, self.lastMapClickToMapName)
        -- Same notification ZOS sends from its Update loop (WorldMap.lua:1674).
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    end
end

-- World map identity --------------------------------------------------------

--- "OnWorldMapChanged" (WorldMap.lua:1674, 3844) fires whenever the world map identity changes.
function LUIE_MiniMap_Manager:OnWorldMapChanged()
    if not self.running then
        return
    end
    self.mapIdentityDirty = true
    MiniMap.LogDebug("World map changed: %s", GetMapName())
    if self:IsIdle() then
        self:FireCommand(LUIE_MINIMAP_MAP_TRIGGER_COMMANDS.MAP_CHANGED)
    end
end

--- Immediate identity check (zone events): same call and notification as the ZOS Update loop.
function LUIE_MiniMap_Manager:SyncMapToPlayerLocation()
    if not self.running or self:IsPaused() or ZO_WorldMap_IsWorldMapShowing() then
        return
    end
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
    end
end

--- Runs the hidden ZO_WorldMap OnUpdate (WorldMap.lua:1663 Update, installed at 3490) so ZOS flushes its pin
--- refresh groups, moving pins and periodic SetMapToPlayerLocation while the world map is closed.
--- The handler is installed once in ZO_WorldMapManager:Initialize (WorldMap.lua:3490) and never replaced, so it is
--- resolved once in Start() instead of a GetHandler lookup every interval update.
function LUIE_MiniMap_Manager:UpdateWorldMap()
    if ZO_WorldMap_IsWorldMapShowing() then
        return
    end
    local onUpdate = self.worldMapUpdateHandler
    if onUpdate then
        onUpdate(WORLD_MAP_MANAGER.control, GetFrameTimeSeconds())
    end
end

-- Pause / resume -----------------------------------------------------------

--- @return boolean
function LUIE_MiniMap_Manager:IsPaused()
    return next(self.pauseReasons) ~= nil
end

--- @param reason string
function LUIE_MiniMap_Manager:AddPauseReason(reason)
    local wasPaused = self:IsPaused()
    self.pauseReasons[reason] = true
    if not wasPaused and self.running then
        self:FireCommand(LUIE_MINIMAP_MAP_TRIGGER_COMMANDS.PAUSE)
    end
end

--- @param reason string
function LUIE_MiniMap_Manager:RemovePauseReason(reason)
    if not self.pauseReasons[reason] then
        return
    end
    self.pauseReasons[reason] = nil
    if not self:IsPaused() and self.running then
        self.panAndZoom:ClearFollowCache()
        -- ZO_WorldMap_OnHide (WorldMap.lua:2476) only clears g_playerChoseCurrentMap; bring the world map back
        -- to the player before the tiles are re-read so a browsed map is never loaded.
        self:SyncMapToPlayerLocation()
        self:FireCommand(LUIE_MINIMAP_MAP_TRIGGER_COMMANDS.RESUME)
    end
end

function LUIE_MiniMap_Manager:OnWorldMapOpening()
    self:AddPauseReason(PAUSE_REASON_WORLD_MAP)
end

function LUIE_MiniMap_Manager:OnWorldMapClosed()
    self:RemovePauseReason(PAUSE_REASON_WORLD_MAP)
end

function LUIE_MiniMap_Manager:OnFastTravelStart()
    self:AddPauseReason(PAUSE_REASON_FAST_TRAVEL)
end

function LUIE_MiniMap_Manager:OnFastTravelEnd()
    self:RemovePauseReason(PAUSE_REASON_FAST_TRAVEL)
end

-- Fragment / interval update ----------------------------------------------------------

function LUIE_MiniMap_Manager:OnFragmentShown()
    self.fragmentShowing = true
    -- Tile textures use RELEASE_TEXTURE_AT_ZERO_REFERENCES; re-point them in case they were dropped while hidden.
    if self:IsIdle() then
        self.tileLayer:RefreshTextures()
        self.panAndZoom:ClearFollowCache()
        self.pinLayer:MarkAllDirty()
    end
    self:RefreshUpdateRegistration()
end

function LUIE_MiniMap_Manager:OnFragmentHidden()
    self.fragmentShowing = false
    self.input:CancelPanDrag()
    self:RefreshUpdateRegistration()
end

--- @return string
function LUIE_MiniMap_Manager:GetUpdateRegistrationName()
    return MiniMap.moduleName .. "IntervalUpdate"
end

--- One interval update (movingPinRefreshMs) for the world-map update, pin entries and the location label, plus a per-frame
--- OnUpdate on the root control for everything that must track the character smoothly (follow scroll, pip headings,
--- player pin entry). ZOS itself runs ZO_WorldMap's Update every frame and moves pins every PIN_UPDATE_DELAY = 0.04s
--- (WorldMap.lua:55, 1681-1687); a 100ms interval update alone made the arrow and camera pip visibly step.
--- A hidden control's OnUpdate does not run, so the frame handler pauses with the HUD fragment for free.
function LUIE_MiniMap_Manager:RefreshUpdateRegistration()
    local shouldUpdate = self.running and self.fragmentShowing and self:IsIdle()
    self:SetFrameUpdateEnabled(shouldUpdate)
    if shouldUpdate == self.intervalUpdateRegistered then
        if shouldUpdate then
            -- Interval may have changed (movingPinRefreshMs); re-register with the current value.
            eventManager:UnregisterForUpdate(self:GetUpdateRegistrationName())
            eventManager:RegisterForUpdate(self:GetUpdateRegistrationName(), MiniMap.GetMovingPinRefreshMs(), function ()
                self:OnIntervalUpdate()
            end)
        end
        return
    end
    self.intervalUpdateRegistered = shouldUpdate
    if shouldUpdate then
        eventManager:RegisterForUpdate(self:GetUpdateRegistrationName(), MiniMap.GetMovingPinRefreshMs(), function ()
            self:OnIntervalUpdate()
        end)
    else
        eventManager:UnregisterForUpdate(self:GetUpdateRegistrationName())
    end
end

function LUIE_MiniMap_Manager:OnIntervalUpdate()
    self:UpdateWorldMap()
    if not self:IsIdle() then
        return
    end
    if self.mapClickPending then
        self.mapClickPending = false
        self:TryProcessMapClickAtPlayer()
        if not self:IsIdle() then
            return
        end
    end
    local panAndZoom = self.panAndZoom
    if panAndZoom:GetFollowsPlayer() then
        local normalizedX, normalizedY, _, isShownInCurrentMap = GetMapPlayerPosition("player")
        panAndZoom:TryAutoZoomOutAtMapEdge(normalizedX, normalizedY, isShownInCurrentMap)
    end
    self.pinLayer:Update()
    self:UpdateLocationLabel()
end

--- @param frameUpdateEnabled boolean
function LUIE_MiniMap_Manager:SetFrameUpdateEnabled(frameUpdateEnabled)
    if frameUpdateEnabled == self.frameUpdateRegistered then
        return
    end
    self.frameUpdateRegistered = frameUpdateEnabled
    if frameUpdateEnabled then
        self.frame.root:SetHandler("OnUpdate", function ()
            self:OnFrameUpdate()
        end)
    else
        self.frame.root:SetHandler("OnUpdate", nil)
    end
end

--- Per frame: one GetMapPlayerPosition read feeds the follow scroll, the centre arrow / camera pip and the
--- player pin entry, so all three move together instead of stepping at the update interval.
function LUIE_MiniMap_Manager:OnFrameUpdate()
    if not self:IsIdle() then
        return
    end
    local panAndZoom = self.panAndZoom
    local normalizedX, normalizedY, playerHeading, isShownInCurrentMap, isSymbolicLocation = GetMapPlayerPosition("player")
    if panAndZoom:GetFollowsPlayer() then
        panAndZoom:FollowPlayer(normalizedX, normalizedY, isShownInCurrentMap)
        self.playerPip:UpdateHeadings(playerHeading, GetPlayerCameraHeading())
    end
    self.pinLayer:UpdatePlayerPinEntry(normalizedX, normalizedY, isShownInCurrentMap, isSymbolicLocation)
end

-- Content size ---------------------------------------------------------------

function LUIE_MiniMap_Manager:OnContentSizeChanged()
    if not self:IsIdle() then
        return
    end
    self.tileLayer:LayoutTiles()
    self.pinLayer:RelayoutAll()
    self.integrations:OnHarvestMapContentSizeChanged()
end

-- Location label -------------------------------------------------------------

--- Sub-zone, zone (EVENT_ZONE_CHANGED args), GetPlayerLocationName, then GetMapName.
--- @return string
function LUIE_MiniMap_Manager:GetLocationDisplayName()
    if self.subZoneName and self.subZoneName ~= "" then
        return self.subZoneName
    end
    if self.zoneName and self.zoneName ~= "" then
        return self.zoneName
    end
    local locationName = GetPlayerLocationName()
    if locationName and locationName ~= "" then
        return locationName
    end
    return GetMapName()
end

function LUIE_MiniMap_Manager:UpdateLocationLabel()
    local displayName = self:GetLocationDisplayName()
    if displayName == self.displayedLocationName then
        return
    end
    self.displayedLocationName = displayName
    self.frame:SetZoneName(displayName)
end

-- Events ---------------------------------------------------------------------

function LUIE_MiniMap_Manager:RegisterEvents()
    local root = self.root
    root:RegisterForEvent(EVENT_ZONE_CHANGED, function (eventId, zoneName, subZoneName)
        self.zoneName = zoneName
        self.subZoneName = subZoneName
        self.mapClickSuppressedMapNames = {}
        self:UpdateLocationLabel()
        self:SyncMapToPlayerLocation()
    end)
    root:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function ()
        self.zoneName = nil
        self.subZoneName = nil
        self:SyncMapToPlayerLocation()
        self:UpdateLocationLabel()
    end)
    root:RegisterForEvent(EVENT_ZONE_UPDATE, function ()
        self:SyncMapToPlayerLocation()
    end)
    root:AddFilterForEvent(EVENT_ZONE_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
    root:RegisterForEvent(EVENT_CURRENT_SUBZONE_LIST_CHANGED, function ()
        self:SyncMapToPlayerLocation()
    end)
    root:RegisterForEvent(EVENT_START_FAST_TRAVEL_INTERACTION, function ()
        self:OnFastTravelStart()
    end)
    root:RegisterForEvent(EVENT_START_FAST_TRAVEL_KEEP_INTERACTION, function ()
        self:OnFastTravelStart()
    end)
    root:RegisterForEvent(EVENT_END_FAST_TRAVEL_INTERACTION, function ()
        self:OnFastTravelEnd()
    end)
    root:RegisterForEvent(EVENT_END_FAST_TRAVEL_KEEP_INTERACTION, function ()
        self:OnFastTravelEnd()
    end)
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapChanged", self.onWorldMapChangedCallback)
end

function LUIE_MiniMap_Manager:UnregisterEvents()
    local root = self.root
    root:UnregisterForEvent(EVENT_ZONE_CHANGED)
    root:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
    root:UnregisterForEvent(EVENT_ZONE_UPDATE)
    root:UnregisterForEvent(EVENT_CURRENT_SUBZONE_LIST_CHANGED)
    root:UnregisterForEvent(EVENT_START_FAST_TRAVEL_INTERACTION)
    root:UnregisterForEvent(EVENT_START_FAST_TRAVEL_KEEP_INTERACTION)
    root:UnregisterForEvent(EVENT_END_FAST_TRAVEL_INTERACTION)
    root:UnregisterForEvent(EVENT_END_FAST_TRAVEL_KEEP_INTERACTION)
    CALLBACK_MANAGER:UnregisterCallback("OnWorldMapChanged", self.onWorldMapChangedCallback)
end

--- Mounted zoom multiplier applies on mount/dismount (not during a hold-zoom).
function LUIE_MiniMap_Manager:OnMountedStateChanged()
    if not self.running or not self:IsIdle() or self.panAndZoom.holdZoomActive then
        return
    end
    local multiplier = MiniMap.SV.mountedZoomMultiplier
    if multiplier and multiplier ~= 1 then
        self.panAndZoom:ApplyContextDefaultZoom()
    end
end

-- Settings -------------------------------------------------------------------

--- Re-applies every live-editable saved setting (called from LAM/LibHarvens setFuncs via the facade).
function LUIE_MiniMap_Manager:ApplySettings()
    local settings = MiniMap.SV
    local frame = self.frame
    frame:ApplyInteractionLocks(settings)
    frame:ApplyControlVisibility(settings)
    frame:ApplyZoneNameFont()
    frame:ApplyAppearanceFromSettings()
    self.playerPip:ApplyDimensions()
    self.playerPip:ApplyColors()
    self.playerPip:ApplyVisibility()
    self:RefreshFrameAttachments()
    self.visibility:SyncLootSceneAttachment()
    self.visibility:UpdateConditionalVisibility()
    if self:IsIdle() then
        self.pinLayer:RelayoutAll()
        self.integrations:ApplyHarvestMapPinScale()
    end
    self:RefreshUpdateRegistration()
end

function LUIE_MiniMap_Manager:RefreshFrameAttachments()
    self.integrations:RefreshFrameAttachments()
end

--- Settings toggle for followPlayer.
--- @param followPlayer boolean
function LUIE_MiniMap_Manager:SetFollowPlayer(followPlayer)
    MiniMap.SV.followPlayer = followPlayer
    self.panAndZoom:SetFollowsPlayer(followPlayer)
    if followPlayer then
        self.panAndZoom:CenterOnPlayer()
    else
        -- Keep the view where it is: the current scroll becomes the saved pan offset.
        self.panAndZoom:SavePanOffsets()
        self.panAndZoom:ApplyPanOffsets()
    end
    self:ApplySettings()
end

-- Start / Stop ---------------------------------------------------------------

function LUIE_MiniMap_Manager:Start()
    if self.running then
        return
    end
    self.running = true
    self.pauseReasons = {}
    self.mapClickSuppressedMapNames = {}
    self.worldMapUpdateHandler = WORLD_MAP_MANAGER.control:GetHandler("OnUpdate")
    MiniMap.ApplyDebugLogging()

    self.frame:ApplyLayoutFromSavedSettings()
    self.frame.dragBarStateMachine:Start()
    self.frame:ApplyZoneNameFont()
    self.frame:ApplyAppearanceFromSettings()
    self.playerPip:ApplyDimensions()
    self.playerPip:ApplyColors()
    self.playerPip:ApplyVisibility()

    self:RegisterEvents()
    self.visibility:Register()

    self:FireCommand(LUIE_MINIMAP_MAP_TRIGGER_COMMANDS.START)
    if self:IsPaused() then
        self:FireCommand(LUIE_MINIMAP_MAP_TRIGGER_COMMANDS.PAUSE)
    end
    if IsPlayerActivated() then
        self:SyncMapToPlayerLocation()
    end
    self:RefreshFrameAttachments()
end

function LUIE_MiniMap_Manager:Stop()
    if not self.running then
        return
    end
    self:FireCommand(LUIE_MINIMAP_MAP_TRIGGER_COMMANDS.STOP)
    self.running = false
    self.visibility:Unregister()
    self:UnregisterEvents()
    self.integrations:DeactivateHarvestMap()
    self.input:StopDragBarMouseOverUpdate()
    self.frame:ShutdownFadeStateMachines()
    self.pauseReasons = {}
    self.fragmentShowing = false
    self:RefreshUpdateRegistration()
    self.root:SetHidden(true)
end
