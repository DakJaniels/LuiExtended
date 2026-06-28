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
    if MiniMap.playerMapMirrorDepth == 1 then
        MiniMap.ClearPlayerMapMirrorZosTilesUpdatedState()
    end
    local savedMapIndex = GetCurrentMapIndex()
    SetMapToPlayerLocation()
    local mapIndexAfterPlayerLocation = GetCurrentMapIndex()
    local playerMapIndexChanged = savedMapIndex ~= mapIndexAfterPlayerLocation
    if playerMapIndexChanged or not MiniMap.IsNativeWorldMapContainerAttached() then
        ZO_WorldMap_UpdateMap()
        MiniMap.MarkPlayerMapMirrorZosTilesUpdated()
        MiniMap.ApplyNativeHudLayoutAfterWorldMapUpdateMap()
    end
    mirrorCallback()
    if savedMapIndex ~= nil and savedMapIndex ~= GetCurrentMapIndex() then
        if MiniMap.IsNativeWorldMapContainerAttached() then
            SetMapToPlayerLocation()
        else
            SetMapToMapListIndex(savedMapIndex)
        end
        ZO_WorldMap_UpdateMap()
        MiniMap.MarkPlayerMapMirrorZosTilesUpdated()
        MiniMap.ApplyNativeHudLayoutAfterWorldMapUpdateMap()
    end
    MiniMap.playerMapMirrorDepth = MiniMap.playerMapMirrorDepth - 1
    if MiniMap.playerMapMirrorDepth == 0 then
        MiniMap.ClearPlayerMapMirrorZosTilesUpdatedState()
    end
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

--- @return boolean
function MiniMap.IsPlayerMapContextCurrentForHudRead()
    return MiniMap.playerMapMirrorDepth > 0 or DoesCurrentMapMatchMapForPlayerLocation()
end

--- Runs hudMapReadCallback on the player map; mirrors via RunWithPlayerMapForMirror when the global map index differs.
--- @param hudMapReadCallback function
function MiniMap.RunHudMapReadInPlayerMapContext(hudMapReadCallback)
    if MiniMap.IsPlayerMapContextCurrentForHudRead() then
        hudMapReadCallback()
    else
        MiniMap.RunWithPlayerMapForMirror(hudMapReadCallback)
    end
end

--- @return boolean
function MiniMap.DoesHudMirrorMapIdentityMatchLoadedPlayerMap()
    local mapController = MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return false
    end
    local mapData = mapController.map
    if not mapData then
        return false
    end
    local playerMapRawName = GetMapName()
    local lastLoadedMapRawName = mapController.lastLoadedMapRawName
    if not lastLoadedMapRawName or lastLoadedMapRawName ~= playerMapRawName then
        return false
    end
    if mapData.rawName ~= playerMapRawName then
        return false
    end
    if not DoesCurrentMapMatchMapForPlayerLocation() then
        return false
    end
    local horizontalTiles, verticalTiles = GetMapNumTiles()
    if mapData.numHorizontalTiles ~= horizontalTiles or mapData.numVerticalTiles ~= verticalTiles then
        return false
    end
    local logicalWidth, logicalHeight = ZO_WorldMap_GetMapDimensions()
    if logicalWidth <= 0 or logicalHeight <= 0 then
        return false
    end
    local loadedMapWidth = mapData.width
    local loadedMapHeight = mapData.height
    if mapData.tileWidth > 0 and mapData.numHorizontalTiles > 0 then
        loadedMapWidth = mapData.tileWidth * mapData.numHorizontalTiles
        loadedMapHeight = mapData.tileHeight * mapData.numVerticalTiles
    end
    if zo_abs(loadedMapWidth - logicalWidth) > 0.5 or zo_abs(loadedMapHeight - logicalHeight) > 0.5 then
        return false
    end
    return true
end

--- Player-map context: tile grid + context base zoom (see GetContextBaseZoom).
--- @return string
function MiniMap.GetHudMapZoomContextSignature()
    local horizontalTiles, verticalTiles = GetMapNumTiles()
    return string.format("%d:%d:%.4f", horizontalTiles or 0, verticalTiles or 0, MiniMap.GetContextBaseZoom())
end

function MiniMap.RecordHudMapZoomContextSignature()
    MiniMap.lastHudMapZoomContextSignature = MiniMap.GetHudMapZoomContextSignature()
end

--- Snap to context default zoom only when tile/context rules change (not every subzone label hop on the same map sheet).
function MiniMap.ApplyHudContextZoomWhenMapContextChanged()
    if MiniMap.holdZoomActive then
        return
    end
    local signature = MiniMap.GetHudMapZoomContextSignature()
    if MiniMap.lastHudMapZoomContextSignature == signature then
        return
    end
    MiniMap.lastHudMapZoomContextSignature = signature
    MiniMap.zoom = MiniMap.GetEffectiveDefaultZoom()
    MiniMap.ClampSavedDefaultZoom()
    local mapController = MiniMap.mapController
    if mapController and mapController:IsReady() then
        mapController:ClampZoomToLimits(true)
    end
end

--- @param mapController MiniMapMapController
--- @return boolean geometryChanged
function MiniMap.SyncHudMapDataDimensionsFromPlayerMap(mapController)
    local mapData = mapController and mapController.map
    if not mapData or mapData.numTiles == 0 then
        return false
    end
    local horizontalTiles, verticalTiles = GetMapNumTiles()
    local logicalWidth, logicalHeight = ZO_WorldMap_GetMapDimensions()
    if logicalWidth <= 0 or logicalHeight <= 0 then
        return false
    end
    local targetWidth = logicalWidth
    local targetHeight = logicalHeight
    if mapData.tileWidth > 0 and mapData.tileHeight > 0 then
        targetWidth = mapData.tileWidth * horizontalTiles
        targetHeight = mapData.tileHeight * verticalTiles
    end
    if  mapData.numHorizontalTiles == horizontalTiles
    and mapData.numVerticalTiles == verticalTiles
    and zo_abs(mapData.width - targetWidth) < 0.5
    and zo_abs(mapData.height - targetHeight) < 0.5 then
        return false
    end
    mapData.numHorizontalTiles = horizontalTiles
    mapData.numVerticalTiles = verticalTiles
    mapData.numTiles = horizontalTiles * verticalTiles
    MiniMap.AssignMiniMapMapDataPixelDimensions(mapData, logicalWidth, logicalHeight)
    mapController:ClampZoomToLimits(true)
    return true
end

--- @param mapData MiniMapMapData
--- @param logicalWidth number
--- @param logicalHeight number
function MiniMap.AssignMiniMapMapDataPixelDimensions(mapData, logicalWidth, logicalHeight)
    if logicalWidth <= 0 or logicalHeight <= 0 then
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
        mapData.width = mapData.tileWidth * mapData.numHorizontalTiles
        mapData.height = mapData.tileHeight * mapData.numVerticalTiles
    end
end

--- Player-map context (inside RunWithPlayerMapForMirror).
--- @return MiniMapMapData mapData
--- @return number logicalWidth
--- @return number logicalHeight
function MiniMap.CollectMiniMapMapDataFromPlayerMap()
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
    return mapData, logicalWidth, logicalHeight
end

--- Map-context-safe read (SpellCastBuffs `/zonecheck` CollectZoneMapInfo: after SetMapToPlayerLocation).
--- @return string|nil
function MiniMap.CollectHudPlayerLocationNameForDisplay()
    local locationName
    MiniMap.RunHudMapReadInPlayerMapContext(function ()
        locationName = GetPlayerLocationName()
    end)
    return locationName
end

--- @param zoneName string|nil
--- @param subZoneName string|nil
--- @return string|nil
function MiniMap.GetHudLocationDisplayName(zoneName, subZoneName)
    if subZoneName and subZoneName ~= "" then
        return subZoneName
    end
    if zoneName and zoneName ~= "" then
        return zoneName
    end
    local locationName = MiniMap.CollectHudPlayerLocationNameForDisplay()
    if locationName and locationName ~= "" then
        return locationName
    end
    return GetMapName()
end

--- HUD zone label: event args (alert order), then GetPlayerLocationName in player map context, then GetMapName.
--- @param zoneName string|nil
--- @param subZoneName string|nil
function MiniMap.ApplyHudLocationLabelFromZoneNames(zoneName, subZoneName)
    local view = MiniMap.view
    if not view then
        return
    end
    local displayName = MiniMap.GetHudLocationDisplayName(zoneName, subZoneName)
    if displayName and displayName ~= "" then
        view:SetZoneName(displayName)
    end
end

--- @param locationLabel string|nil
function MiniMap.ApplyHudLocationLabelFromZoneUpdate(locationLabel)
    local view = MiniMap.view
    if not view then
        return
    end
    local displayName = locationLabel
    if displayName == nil or displayName == "" then
        displayName = MiniMap.GetHudLocationDisplayName(nil, nil)
    end
    if displayName and displayName ~= "" then
        view:SetZoneName(displayName)
    end
end

function MiniMap.ApplyHudLocationLabelFromPlayerLocation()
    MiniMap.ApplyHudLocationLabelFromZoneNames(nil, nil)
end

--- Pin + layout recovery when zone label changes but map sheet identity is unchanged (no tile reload).
--- @return boolean
function MiniMap.IsMapReloadAffectingHudLayout()
    local pinMirrorStateMachine = MiniMap.pinMirrorStateMachine
    local mapController = MiniMap.mapController
    if not pinMirrorStateMachine or not mapController then
        return false
    end
    if pinMirrorStateMachine:IsCurrentState("ZoneReset") then
        return true
    end
    if pinMirrorStateMachine:IsCurrentState("MapReloading") then
        if pinMirrorStateMachine.mapReloadInProgress or not mapController:IsReady() then
            return true
        end
    end
    return false
end

function MiniMap.ApplyHudMirrorRecoveryAfterSubzoneTransition()
    if not MiniMap.Enabled then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    if MiniMap.playerMapMirrorDepth > 0 or MiniMap.IsPinMirrorMachineBusy() then
        return
    end
    if not MiniMap.DoesHudMirrorMapIdentityMatchLoadedPlayerMap() then
        return
    end
    MiniMap.TryAttachNativeWorldMapContainer()
    MiniMap.RefreshNativeWorldMapContainer({ syncSubzoneMapGeometry = true, applyContextZoomIfChanged = true })
    MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
end

function MiniMap.ClearPlayerMapMirrorZosTilesUpdatedState()
    MiniMap.playerMapMirrorZosTilesUpdated = false
    MiniMap.playerMapMirrorZosTilesMapRawName = nil
    MiniMap.playerMapMirrorZosTilesHorizontal = nil
    MiniMap.playerMapMirrorZosTilesVertical = nil
end

function MiniMap.MarkPlayerMapMirrorZosTilesUpdated()
    MiniMap.playerMapMirrorZosTilesUpdated = true
    MiniMap.playerMapMirrorZosTilesMapRawName = GetMapName()
    MiniMap.playerMapMirrorZosTilesHorizontal, MiniMap.playerMapMirrorZosTilesVertical = GetMapNumTiles()
end

--- @param mapData MiniMapMapData
--- @return boolean
function MiniMap.ShouldInvokeNativeWorldMapUpdateTexturesForMapData(mapData)
    if not MiniMap.playerMapMirrorZosTilesUpdated then
        return true
    end
    if MiniMap.playerMapMirrorZosTilesMapRawName ~= mapData.rawName then
        return true
    end
    if mapData.numHorizontalTiles ~= MiniMap.playerMapMirrorZosTilesHorizontal
    or mapData.numVerticalTiles ~= MiniMap.playerMapMirrorZosTilesVertical then
        return true
    end
    return false
end

--- @param mapData MiniMapMapData
--- @param invokeUpdateTextures boolean
function MiniMap.BindNativeWorldMapTilesForHud(mapData, invokeUpdateTextures)
    -- if invokeUpdateTextures then
    --     WORLD_MAP_TILES_MANAGER:UpdateTextures()
    --     return
    -- end
    -- WORLD_MAP_TILES_MANAGER:UpdateMapData()
    -- if WORLD_MAP_TILES_MANAGER.totalTiles ~= mapData.numTiles
    -- or not WORLD_MAP_TILES_MANAGER:GetActiveObject(1) then
    --     WORLD_MAP_TILES_MANAGER:UpdateTextures()
    -- end
end

--- @class MiniMapNativeWorldMapTilesReadyOptions
--- @field invokeUpdateTextures boolean|nil

--- @param mapData MiniMapMapData
--- @param readyOptions MiniMapNativeWorldMapTilesReadyOptions|nil
--- @return boolean texturesLoaded
function MiniMap.WaitForNativeWorldMapTilesReady(mapData, readyOptions)
    local invokeUpdateTextures = readyOptions and readyOptions.invokeUpdateTextures == true
    MiniMap.BindNativeWorldMapTilesForHud(mapData, invokeUpdateTextures)

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
    if mapData.tileWidth <= 0 or mapData.tileHeight <= 0 then
        local logicalWidth, logicalHeight = ZO_WorldMap_GetMapDimensions()
        MiniMap.AssignMiniMapMapDataPixelDimensions(mapData, logicalWidth, logicalHeight)
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
    local normalizedX, normalizedY, heading, isShownInCurrentMap
    MiniMap.RunHudMapReadInPlayerMapContext(function ()
        normalizedX, normalizedY, heading, isShownInCurrentMap = GetMapPlayerPosition(unitTag)
    end)
    return normalizedX, normalizedY, heading, isShownInCurrentMap
end

--- @return number|nil waypointX
--- @return number|nil waypointY
function MiniMap.GetMapPlayerWaypointForMirror()
    local waypointX, waypointY
    MiniMap.RunHudMapReadInPlayerMapContext(function ()
        waypointX, waypointY = GetMapPlayerWaypoint()
    end)
    return waypointX, waypointY
end

--- Matches ZOS WorldMap ping/waypoint refresh: unset when either axis is 0 (EsoUI/Ingame/Map/WorldMap.lua).
--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @return boolean
function MiniMap.IsMapNormalizedWaypointPlaced(normalizedX, normalizedY)
    return normalizedX ~= nil and normalizedY ~= nil and normalizedX ~= 0 and normalizedY ~= 0
end

--- Player pip / follow scroll: use isShownInCurrentMap like ZO_WorldMapPins_Manager:UpdateMovingPins.
--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param isShownInCurrentMap boolean|nil
--- @return boolean
function MiniMap.IsMapPlayerPositionShownOnHudMap(normalizedX, normalizedY, isShownInCurrentMap)
    return isShownInCurrentMap == true and normalizedX ~= nil and normalizedY ~= nil
end

