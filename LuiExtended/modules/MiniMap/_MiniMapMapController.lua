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

--- @param view MiniMapView
--- @param statusMessage string
--- @param retryReason string
--- @param reloadAttemptIndex number
function MiniMapMapController:ScheduleWorldMapReloadRetryOrFail(view, statusMessage, retryReason, reloadAttemptIndex)
    view.statusLabel:SetText(statusMessage)
    if reloadAttemptIndex < MINIMAP_MAP_RELOAD_MAX_ATTEMPTS then
        local mapController = self
        zo_callLater(function ()
                         mapController:ReloadWorldMap(retryReason, reloadAttemptIndex)
                     end, 1000 * reloadAttemptIndex)
        return
    end
    view.statusLabel:SetText("Loading failed")
    view:HideLoading()
    MiniMap.SetAttachedNativeWorldMapContainerHiddenForReload(false)
    local pinMirrorStateMachine = MiniMap.pinMirrorStateMachine
    if pinMirrorStateMachine then
        pinMirrorStateMachine:NotifyMapReloadFailed()
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
    MiniMap.SetAttachedNativeWorldMapContainerHiddenForReload(false)
    MiniMap.SchedulePostReloadUILayout(self, mapData)
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
        self:ScheduleWorldMapReloadRetryOrFail(
            view,
            string.format("Loading map info [%d]", reloadAttemptIndex),
            string.format("Map info reload [%d]", reloadAttemptIndex),
            reloadAttemptIndex)
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
        self:ScheduleWorldMapReloadRetryOrFail(
            view,
            string.format("Loading textures [%d]", reloadAttemptIndex),
            string.format("Texture reload [%d]", reloadAttemptIndex),
            reloadAttemptIndex)
        return
    end

    self:FinalizeWorldMapReloadFromMirror(mapData, logicalWidth, logicalHeight, mapZoneIdentityChanged)
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
    MiniMap.SetAttachedNativeWorldMapContainerHiddenForReload(true)
    MiniMap.pinMirrorStateMachine:OnMapReloadStarted()
    view:ShowLoading("Loading")
    reloadAttemptIndex = reloadAttemptIndex + 1

    local mapController = self
    local mirrorWorkScheduled = MiniMap.RunWithPlayerMapForMirror(function ()
        mapController:ReloadWorldMapInPlayerMapMirror(reloadAttemptIndex)
    end)
    if not mirrorWorkScheduled then
        mapController.ready = wasReady
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
