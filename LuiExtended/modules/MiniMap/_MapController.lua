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
local MINIMAP_MAP_RELOAD_MAX_ATTEMPTS = 10

--- Save world-map list index, run mirror work on player map, then restore selection.
--- @param mirrorCallback function
--- @return boolean true when mirror work ran or was queued on the single-flight slot
function MiniMap.RunWithPlayerMapForMirror(mirrorCallback)
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return false
    end
    if MiniMap.playerMapMirrorDepth > 0 then
        MiniMap.playerMapMirrorPendingCallback = mirrorCallback
        return true
    end
    MiniMap.playerMapMirrorDepth = MiniMap.playerMapMirrorDepth + 1
    local savedMapIndex = GetCurrentMapIndex()
    SetMapToPlayerLocation()
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        ZO_WorldMap_UpdateMap()
    end
    mirrorCallback()
    if savedMapIndex ~= nil and savedMapIndex ~= GetCurrentMapIndex() then
        if MiniMap.IsNativeWorldMapContainerAttached() then
            SetMapToPlayerLocation()
        else
            SetMapToMapListIndex(savedMapIndex)
        end
        ZO_WorldMap_UpdateMap()
    end
    MiniMap.playerMapMirrorDepth = MiniMap.playerMapMirrorDepth - 1
    local pendingMirrorCallback = MiniMap.playerMapMirrorPendingCallback
    if MiniMap.playerMapMirrorDepth == 0 and pendingMirrorCallback then
        MiniMap.playerMapMirrorPendingCallback = nil
        MiniMap.RunWithPlayerMapForMirror(pendingMirrorCallback)
        return true
    end
    if MiniMap.playerMapMirrorDepth == 0 then
        if MiniMap.IsNativeWorldMapContainerAttached() then
            MiniMap.ReapplyNativeHudMapOverlayLayout()
            MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
        end
        MiniMap.CompletePostPlayerMapMirrorWork()
    end
    return true
end

--- @param mapController MiniMapMapController
--- @param mapData MiniMapMapData
--- @return boolean texturesLoaded
function MiniMap.ApplyNativeWorldMapTileTextures(mapController, mapData)
    WORLD_MAP_TILES_MANAGER:UpdateTextures()
    mapController.tilesManager:UpdateMapData()

    for tileIndex = 1, mapData.numTiles do
        local nativeTile = WORLD_MAP_TILES_MANAGER:GetActiveObject(tileIndex)
        if nativeTile then
            if mapData.tileWidth == 0 or mapData.tileHeight == 0 then
                mapData.tileWidth, mapData.tileHeight = nativeTile:GetTextureFileDimensions()
            end
            if not nativeTile:IsTextureLoaded() then
                return false
            end
        else
            return false
        end
    end
    return mapData.tileWidth > 0 and mapData.tileHeight > 0
end

--- Player map coords for mirror scroll/pins; global map index may differ after restore.
--- @param unitTag string
--- @return number|nil normalizedX
--- @return number|nil normalizedY
--- @return number|nil heading
--- @return boolean|nil isShownInCurrentMap
function MiniMap.GetMapPlayerPositionForMirror(unitTag)
    unitTag = unitTag or "player"
    if MiniMap.playerMapMirrorDepth > 0 then
        local normalizedX, normalizedY, heading, isShownInCurrentMap = GetMapPlayerPosition(unitTag)
        return normalizedX, normalizedY, heading, isShownInCurrentMap
    end
    local normalizedX, normalizedY, heading, isShownInCurrentMap
    if DoesCurrentMapMatchMapForPlayerLocation() then
        normalizedX, normalizedY, heading, isShownInCurrentMap = GetMapPlayerPosition(unitTag)
        return normalizedX, normalizedY, heading, isShownInCurrentMap
    end
    MiniMap.RunWithPlayerMapForMirror(function ()
        normalizedX, normalizedY, heading, isShownInCurrentMap = GetMapPlayerPosition(unitTag)
    end)
    return normalizedX, normalizedY, heading, isShownInCurrentMap
end

--- @return number|nil waypointX
--- @return number|nil waypointY
function MiniMap.GetMapPlayerWaypointForMirror()
    if MiniMap.playerMapMirrorDepth > 0 then
        return GetMapPlayerWaypoint()
    end
    if DoesCurrentMapMatchMapForPlayerLocation() then
        return GetMapPlayerWaypoint()
    end
    local waypointX, waypointY
    MiniMap.RunWithPlayerMapForMirror(function ()
        waypointX, waypointY = GetMapPlayerWaypoint()
    end)
    return waypointX, waypointY
end

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
--- @field tilesManager ZO_WorldMapTiles_Manager
--- @field ready boolean
--- @field lastLoadedMapRawName string|nil
local MiniMapMapController = ZO_InitializingObject:Subclass()
MiniMap.MiniMapMapController = MiniMapMapController

--- @param view MiniMapView
function MiniMapMapController:Initialize(view)
    self.view = view
    self.map = nil
    self.ready = false
    self.tilesManager = ZO_WorldMapTiles_Manager:New(view.map)
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
function MiniMapMapController:ApplyZoom(delta)
    local previousContentWidth = self:GetMapContentWidth()
    local previousContentHeight = self:GetMapContentHeight()

    if delta == 0 then
        MiniMap.zoom = MiniMap.SV.defaultZoom
    else
        MiniMap.zoom = MiniMap.zoom + (delta / 10)
    end
    local zoomMinimum = self:GetMinimumZoom()
    if MiniMap.zoom < zoomMinimum then
        MiniMap.zoom = zoomMinimum
    elseif MiniMap.zoom > MINIMAP_ZOOM_MAX then
        MiniMap.zoom = MINIMAP_ZOOM_MAX
    end
    self.view:SetZoomLabel(MiniMap.zoom)
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

function MiniMapMapController:ClearTiles()
    if self.tilesManager then
        self.tilesManager:ReleaseAllObjects()
    end
end

function MiniMapMapController:ClearPinControlsForOtherZones()
    if MiniMap.pinController then
        MiniMap.pinController:ReleaseAllPinPools()
    end
end

--- @param reason string
--- @param reloadAttemptIndex number
--- @return boolean
function MiniMapMapController:ReloadWorldMap(reason, reloadAttemptIndex)
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return self.ready
    end
    local view = self.view
    local wasReady = self.ready
    self.ready = false
    MiniMap.pinMirrorStateMachine:OnMapReloadStarted()
    view:ShowLoading("Loading")
    reloadAttemptIndex = reloadAttemptIndex + 1

    local mapController = self
    local mirrorWorkScheduled = MiniMap.RunWithPlayerMapForMirror(function ()
        mapController:ClearPinControlsForOtherZones()

        local horizontalTiles, verticalTiles = GetMapNumTiles()
        local logicalWidth, logicalHeight = ZO_WorldMap_GetMapDimensions()
        --- @type MiniMapMapData
        local mapData =
        {
            rawName = GetMapName(),
            numHorizontalTiles = horizontalTiles,
            numVerticalTiles = verticalTiles,
            numTiles = horizontalTiles * verticalTiles,
            tileWidth = 0,
            tileHeight = 0,
            width = 0,
            height = 0,
        }

        local previousLoadedMapRawName = mapController.lastLoadedMapRawName
        local mapZoneIdentityChanged = previousLoadedMapRawName ~= mapData.rawName

        if mapZoneIdentityChanged and previousLoadedMapRawName then
            MiniMap.SV.panOffsetX = 0
            MiniMap.SV.panOffsetY = 0
        end
        mapController.lastLoadedMapRawName = mapData.rawName
        mapController.map = mapData

        view:SetZoneName(mapData.rawName)

        if mapData.numTiles == 0 then
            view.statusLabel:SetText(string.format("Loading map info [%d]", reloadAttemptIndex))
            if reloadAttemptIndex < MINIMAP_MAP_RELOAD_MAX_ATTEMPTS then
                zo_callLater(function ()
                                 mapController:ReloadWorldMap(string.format("Map info reload [%d]", reloadAttemptIndex), reloadAttemptIndex)
                             end, 1000 * reloadAttemptIndex)
            else
                view.statusLabel:SetText("Loading failed")
                MiniMap.pinMirrorStateMachine.mapReloadInProgress = false
            end
            return
        end

        local texturesLoaded
        mapController:ClearTiles()
        texturesLoaded = MiniMap.ApplyNativeWorldMapTileTextures(mapController, mapData)

        if not texturesLoaded then
            view.statusLabel:SetText(string.format("Loading textures [%d]", reloadAttemptIndex))
            if reloadAttemptIndex < MINIMAP_MAP_RELOAD_MAX_ATTEMPTS then
                zo_callLater(function ()
                                 mapController:ReloadWorldMap(string.format("Texture reload [%d]", reloadAttemptIndex), reloadAttemptIndex)
                             end, 1000 * reloadAttemptIndex)
            else
                view.statusLabel:SetText("Loading failed")
                MiniMap.pinMirrorStateMachine.mapReloadInProgress = false
            end
            return
        end

        mapData.width = logicalWidth
        mapData.height = logicalHeight
        if mapData.tileWidth > 0 and mapData.tileHeight > 0 then
            mapData.width = mapData.tileWidth * mapData.numHorizontalTiles
            mapData.height = mapData.tileHeight * mapData.numVerticalTiles
        elseif mapData.numHorizontalTiles > 0 and mapData.numVerticalTiles > 0 then
            mapData.tileWidth = logicalWidth / mapData.numHorizontalTiles
            mapData.tileHeight = logicalHeight / mapData.numVerticalTiles
        end
        mapController.ready = true
        MiniMap.ClampSavedDefaultZoom()
        if mapZoneIdentityChanged then
            MiniMap.zoom = MiniMap.GetEffectiveDefaultZoom()
        end
        mapController:ClampZoomToLimits(true)
        view:HideLoading()
        MiniMap.SetLuiMiniMapTileLayerHidden(true)
        MiniMap.SchedulePostReloadUILayout(mapController, mapData)
        MiniMap.pinMirrorStateMachine:ScheduleNotifyMapReloadCompleteAfterMirror()
    end)
    if not mirrorWorkScheduled then
        mapController.ready = wasReady
    end

    return self.ready
end

function MiniMapMapController:BuildMapLayout()
    local mapData = self.map
    if not mapData or mapData.numTiles == 0 then
        return
    end

    local zoom = MiniMap.zoom
    local tileWidth = zoom * mapData.tileWidth
    local tileHeight = zoom * mapData.tileHeight
    local mapWidth = self:GetMapContentWidth()
    local mapHeight = self:GetMapContentHeight()

    local mapControl = self.view.map
    mapControl:SetDimensions(mapWidth, mapHeight)
    self.view.pins:SetDimensions(mapWidth, mapHeight)

    for tileIndex = 1, mapData.numTiles do
        local tile = self.tilesManager:GetActiveObject(tileIndex)
        if tile then
            tile:SetHidden(true)
        end
    end
    MiniMap.OnNativeWorldMapContainerZoomChanged()
end

--- @return MiniMapMapData|nil
function MiniMapMapController:GetMapData()
    return self.map
end

function MiniMapMapController:IsReady()
    return self.ready
end
