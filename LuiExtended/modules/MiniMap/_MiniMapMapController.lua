-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local MINIMAP_ZOOM_MIN_FALLBACK = 0.35
local MINIMAP_ZOOM_MAX = 1.8

--- @class MiniMapMapData
--- @field rawName string
--- @field numHorizontalTiles number
--- @field numVerticalTiles number
--- @field numTiles number
--- @field tileWidth number
--- @field tileHeight number
--- @field width number
--- @field height number

--- @class MiniMapMapController : ZO_InitializingObject
--- @field view MiniMapView
--- @field map MiniMapMapData|nil
--- @field ready boolean
--- @field lastLoadedMapRawName string|nil
local MiniMapMapController = ZO_InitializingObject:Subclass()
MiniMap.MiniMapMapController = MiniMapMapController

--- @param view MiniMapView
function MiniMapMapController:Initialize(view)
    self.view = view
    self.map = nil
    self.ready = false
    self.lastLoadedMapRawName = nil
end

--- @return number
function MiniMapMapController:GetMapContentWidth()
    local mapData = self.map
    if not mapData or mapData.width == 0 then
        return 0
    end
    return MiniMap.zoom * mapData.width
end

--- @return number
function MiniMapMapController:GetMapContentHeight()
    local mapData = self.map
    if not mapData or mapData.height == 0 then
        return 0
    end
    return MiniMap.zoom * mapData.height
end

function MiniMapMapController:GetZoom()
    return MiniMap.zoom
end

--- Whole zone visible; map content not smaller than scroll viewport (no letterboxing).
--- @return number
function MiniMapMapController:GetMinimumZoom()
    local mapData = self.map
    if not mapData or mapData.width <= 0 or mapData.height <= 0 then
        return MINIMAP_ZOOM_MIN_FALLBACK
    end
    local scroll = self.view.scroll
    local scrollWidth = scroll:GetWidth()
    local scrollHeight = scroll:GetHeight()
    if scrollWidth <= 0 or scrollHeight <= 0 then
        return MINIMAP_ZOOM_MIN_FALLBACK
    end
    return zo_min(scrollWidth / mapData.width, scrollHeight / mapData.height)
end

--- @param relayoutWhenReady boolean|nil
function MiniMapMapController:ClampZoomToLimits(relayoutWhenReady)
    relayoutWhenReady = relayoutWhenReady ~= false
    local previousContentWidth = self:GetMapContentWidth()
    local previousContentHeight = self:GetMapContentHeight()
    local zoomMinimum = self:GetMinimumZoom()
    if MiniMap.zoom < zoomMinimum then
        MiniMap.zoom = zoomMinimum
    elseif MiniMap.zoom > MINIMAP_ZOOM_MAX then
        MiniMap.zoom = MINIMAP_ZOOM_MAX
    end
    self.view:SetZoomLabel(MiniMap.zoom)
    if relayoutWhenReady and self.ready then
        self:BuildMapLayout()
        local mapData = self.map
        if mapData and MiniMap.pinController then
            MiniMap.pinController:RelayoutActivePinsForZoom(mapData)
        end
        MiniMap.OnNativeWorldMapContainerZoomChanged()
        if MiniMap.runtime then
            MiniMap.runtime:ApplyScrollAfterZoom(previousContentWidth, previousContentHeight)
        end
    end
end

--- @param delta number
--- @param revealZoomLabel boolean|nil When false, refresh label text only (no transient show).
function MiniMapMapController:ApplyZoom(delta, revealZoomLabel)
    local previousContentWidth = self:GetMapContentWidth()
    local previousContentHeight = self:GetMapContentHeight()

    if delta == 0 then
        MiniMap.zoom = MiniMap.SV.resetZoomLevel
    else
        MiniMap.zoom = MiniMap.zoom + (delta / 10)
    end
    local zoomMinimum = self:GetMinimumZoom()
    if MiniMap.zoom < zoomMinimum then
        MiniMap.zoom = zoomMinimum
    elseif MiniMap.zoom > MINIMAP_ZOOM_MAX then
        MiniMap.zoom = MINIMAP_ZOOM_MAX
    end
    self.view:SetZoomLabel(MiniMap.zoom, revealZoomLabel ~= false)
    if self.ready then
        self:BuildMapLayout()
        local mapData = self.map
        if mapData and MiniMap.pinController then
            MiniMap.pinController:RelayoutActivePinsForZoom(mapData)
        end
        MiniMap.OnNativeWorldMapContainerZoomChanged()
        if MiniMap.runtime then
            MiniMap.runtime:ApplyScrollAfterZoom(previousContentWidth, previousContentHeight)
        end
    end
end

function MiniMapMapController:ClearPinControlsForOtherZones()
    if MiniMap.pinController then
        MiniMap.pinController:ReleaseAllPinPools()
    end
end

function MiniMapMapController:ClearPendingTileTextureHandlers()
    local pendingTileControls = self.pendingTileTextureControls
    if not pendingTileControls then
        return
    end
    for tileIndex = 1, #pendingTileControls do
        pendingTileControls[tileIndex]:SetHandler("OnTextureLoaded", nil)
    end
    self.pendingTileTextureControls = nil
end

--- Map info is not ready. Stay in MapReloading until EVENT_PLAYER_ACTIVATED or EVENT_ZONE_CHANGED.
--- @param view MiniMapView
--- @param statusMessage string
function MiniMapMapController:DeferWorldMapReloadUntilPlayerMapEvent(view, statusMessage)
    self:ClearPendingTileTextureHandlers()
    view.statusLabel:SetText(statusMessage)
    local pinMirrorStateMachine = MiniMap.pinMirrorStateMachine
    if pinMirrorStateMachine then
        pinMirrorStateMachine.mapReloadInProgress = false
        pinMirrorStateMachine.mapReloadAwaitingPlayerMapEvent = true
    end
end

--- @param reloadAttemptIndex number
function MiniMapMapController:ResumeWorldMapReloadAfterTileReady(reloadAttemptIndex)
    local pinMirrorStateMachine = MiniMap.pinMirrorStateMachine
    if not MiniMap.Enabled or not pinMirrorStateMachine then
        return
    end
    if pinMirrorStateMachine.mapReloadInProgress or not pinMirrorStateMachine:IsCurrentState("MapReloading") then
        return
    end
    self:ClearPendingTileTextureHandlers()
    pinMirrorStateMachine.mapReloadAwaitingPlayerMapEvent = false
    pinMirrorStateMachine.mapReloadCompletionHandled = false
    pinMirrorStateMachine.mapReloadInProgress = true
    self:ReloadWorldMap(pinMirrorStateMachine.pendingMapReloadReason or "TextureLoaded", reloadAttemptIndex or 0)
end

--- Unloaded tiles finish on OnTextureLoaded (ESOUIDocumentation.txt). Missing tile controls wait for a zone event.
--- @param view MiniMapView
--- @param statusMessage string
--- @param reloadAttemptIndex number
function MiniMapMapController:DeferWorldMapReloadForUnloadedTiles(view, statusMessage, reloadAttemptIndex)
    self:ClearPendingTileTextureHandlers()
    view.statusLabel:SetText(statusMessage)
    local mapData = self.map
    if not mapData or mapData.numTiles == 0 then
        self:DeferWorldMapReloadUntilPlayerMapEvent(view, statusMessage)
        return
    end
    local pendingTileControls = {}
    for tileIndex = 1, mapData.numTiles do
        local nativeTile = WORLD_MAP_TILES_MANAGER:GetActiveObject(tileIndex)
        if not nativeTile then
            self:DeferWorldMapReloadUntilPlayerMapEvent(view, statusMessage)
            return
        end
        if not nativeTile:IsTextureLoaded() then
            pendingTileControls[#pendingTileControls + 1] = nativeTile
        end
    end
    if #pendingTileControls == 0 then
        self:DeferWorldMapReloadUntilPlayerMapEvent(view, statusMessage)
        return
    end
    local pinMirrorStateMachine = MiniMap.pinMirrorStateMachine
    if pinMirrorStateMachine then
        pinMirrorStateMachine.mapReloadInProgress = false
        pinMirrorStateMachine.mapReloadAwaitingPlayerMapEvent = true
    end
    self.pendingTileTextureControls = pendingTileControls
    local mapController = self
    local function OnHudMapTileTextureLoaded(tileControl)
        tileControl:SetHandler("OnTextureLoaded", nil)
        local registeredTiles = mapController.pendingTileTextureControls
        if not registeredTiles then
            return
        end
        for registeredTileIndex = 1, #registeredTiles do
            if not registeredTiles[registeredTileIndex]:IsTextureLoaded() then
                return
            end
        end
        mapController:ResumeWorldMapReloadAfterTileReady(reloadAttemptIndex)
    end
    for pendingTileIndex = 1, #pendingTileControls do
        pendingTileControls[pendingTileIndex]:SetHandler("OnTextureLoaded", OnHudMapTileTextureLoaded)
    end
end

--- @param previousMapData MiniMapMapData|nil
--- @param mapZoneIdentityChanged boolean
--- @param horizontalTiles number
--- @param verticalTiles number
--- @param logicalWidth number
--- @param logicalHeight number
--- @return boolean
function MiniMapMapController:CanReuseTilesForWorldMapReload(previousMapData, mapZoneIdentityChanged, horizontalTiles, verticalTiles, logicalWidth, logicalHeight)
    return not mapZoneIdentityChanged
        and previousMapData ~= nil
        and previousMapData.numHorizontalTiles == horizontalTiles
        and previousMapData.numVerticalTiles == verticalTiles
        and previousMapData.width == logicalWidth
        and previousMapData.height == logicalHeight
        and previousMapData.tileWidth > 0
        and previousMapData.tileHeight > 0
end

--- @param mapData MiniMapMapData
--- @param previousMapData MiniMapMapData|nil
--- @param canReuseLoadedTiles boolean
--- @return boolean texturesLoaded
function MiniMapMapController:LoadWorldMapReloadTextures(mapData, previousMapData, canReuseLoadedTiles)
    if canReuseLoadedTiles and previousMapData then
        mapData.tileWidth = previousMapData.tileWidth
        mapData.tileHeight = previousMapData.tileHeight
        return true
    end
    local invokeUpdateTextures = MiniMap.ShouldInvokeNativeWorldMapUpdateTexturesForMapData(mapData)
    return MiniMap.WaitForNativeWorldMapTilesReady(mapData, { invokeUpdateTextures = invokeUpdateTextures })
end

--- @param mapData MiniMapMapData
--- @param logicalWidth number
--- @param logicalHeight number
--- @param mapZoneIdentityChanged boolean
function MiniMapMapController:FinalizeWorldMapReloadFromMirror(mapData, logicalWidth, logicalHeight, mapZoneIdentityChanged)
    MiniMap.AssignMiniMapMapDataPixelDimensions(mapData, logicalWidth, logicalHeight)
    self.ready = true
    MiniMap.ClampSavedDefaultZoom()
    if mapZoneIdentityChanged then
        MiniMap.zoom = MiniMap.GetEffectiveDefaultZoom()
        MiniMap.RecordHudMapZoomContextSignature()
    else
        MiniMap.ApplyHudContextZoomWhenMapContextChanged()
    end
    self:ClampZoomToLimits(true)
    self.view:HideLoading()
    MiniMap.keepPreviousHudMapTilesVisible = false
    MiniMap.SetAttachedNativeWorldMapContainerHiddenForReload(false)
    MiniMap.SchedulePostReloadUILayout(self, mapData)
    self:ClearPendingTileTextureHandlers()
    MiniMap.pinMirrorStateMachine.mapReloadAwaitingPlayerMapEvent = false
    MiniMap.pinMirrorStateMachine:ScheduleNotifyMapReloadCompleteAfterMirror()
end

--- @param reloadAttemptIndex number
function MiniMapMapController:ReloadWorldMapInPlayerMapMirror(reloadAttemptIndex)
    local view = self.view
    self:ClearPinControlsForOtherZones()

    local mapData, logicalWidth, logicalHeight = MiniMap.CollectMiniMapMapDataFromPlayerMap()
    local previousLoadedMapRawName = self.lastLoadedMapRawName
    local previousMapData = self.map
    local mapZoneIdentityChanged = previousLoadedMapRawName ~= mapData.rawName

    if mapZoneIdentityChanged and previousLoadedMapRawName then
        MiniMap.SV.panOffsetX = 0
        MiniMap.SV.panOffsetY = 0
    end
    self.lastLoadedMapRawName = mapData.rawName
    self.map = mapData
    MiniMap.ApplyHudLocationLabelFromPlayerLocation()

    if mapData.numTiles == 0 then
        self:DeferWorldMapReloadUntilPlayerMapEvent(view, string.format("Loading map info [%d]", reloadAttemptIndex))
        return
    end

    local canReuseLoadedTiles = self:CanReuseTilesForWorldMapReload(
        previousMapData,
        mapZoneIdentityChanged,
        mapData.numHorizontalTiles,
        mapData.numVerticalTiles,
        logicalWidth,
        logicalHeight)

    if not self:LoadWorldMapReloadTextures(mapData, previousMapData, canReuseLoadedTiles) then
        self:DeferWorldMapReloadForUnloadedTiles(view, string.format("Loading textures [%d]", reloadAttemptIndex), reloadAttemptIndex)
        return
    end

    self:FinalizeWorldMapReloadFromMirror(mapData, logicalWidth, logicalHeight, mapZoneIdentityChanged)
end

--- @param reason string
--- @param reloadAttemptIndex number
--- @return boolean
function MiniMapMapController:ReloadWorldMap(reason, reloadAttemptIndex)
    self:ClearPendingTileTextureHandlers()
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return self.ready
    end
    local view = self.view
    local wasReady = self.ready
    self.ready = false
    if wasReady then
        MiniMap.keepPreviousHudMapTilesVisible = true
    end
    MiniMap.ShowNativeWorldMapContainerForTileLoad()
    MiniMap.pinMirrorStateMachine:OnMapReloadStarted()
    if MiniMap.keepPreviousHudMapTilesVisible then
        ZO_WorldMapContainer:SetAlpha(1)
        ZO_WorldMapContainer:SetHidden(false)
    else
        MiniMap.SetAttachedNativeWorldMapContainerHiddenForReload(true)
        view:ShowLoading("Loading")
    end
    reloadAttemptIndex = reloadAttemptIndex + 1

    local mapController = self
    local mirrorWorkScheduled = MiniMap.RunWithPlayerMapForMirror(function ()
        mapController:ReloadWorldMapInPlayerMapMirror(reloadAttemptIndex)
    end)
    if not mirrorWorkScheduled then
        mapController.ready = wasReady
        MiniMap.keepPreviousHudMapTilesVisible = false
        MiniMap.ReturnStagedWorldMapContainerToWorldMap()
        if wasReady then
            MiniMap.SetAttachedNativeWorldMapContainerHiddenForReload(false)
        end
    end

    return self.ready
end

function MiniMapMapController:BuildMapLayout()
    local mapData = self.map
    if not mapData or mapData.numTiles == 0 then
        return
    end

    local mapWidth = self:GetMapContentWidth()
    local mapHeight = self:GetMapContentHeight()

    local mapControl = self.view.map
    mapControl:SetDimensions(mapWidth, mapHeight)
    self.view.pins:SetDimensions(mapWidth, mapHeight)

    MiniMap.OnNativeWorldMapContainerZoomChanged()
end

--- @return MiniMapMapData|nil
function MiniMapMapController:GetMapData()
    return self.map
end

function MiniMapMapController:IsReady()
    return self.ready
end
