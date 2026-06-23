-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.MiniMap : ZO_Object
--- @field SV MiniMapDefaults
--- @field Defaults MiniMapDefaults
--- @field Enabled boolean
--- @field moduleName string
--- @field zoom number
--- @field fastTravel boolean
--- @field resize boolean
--- @field resizeIsWidthDriven boolean|nil
--- @field view MiniMapView|nil
--- @field mapController MiniMapMapController|nil
--- @field pinController MiniMapPinController|nil
--- @field runtime MiniMapRuntime|nil
--- @field mapEventController MiniMapMapEventController|nil
--- @field pinMirrorStateMachine MiniMapPinMirrorStateMachine|nil
--- @field inputController MiniMapInputController|nil
--- @field hudSceneFragment MiniMapHUDSceneFragment|nil
--- @field worldMapBlocksMiniMapWork boolean
local MiniMap = ZO_Object:Subclass()
LUIE.MiniMap = MiniMap

MiniMap.moduleName = LUIE.name .. "MiniMap"
MiniMap.Enabled = false
MiniMap.zoom = 0.5
MiniMap.fastTravel = false
MiniMap.resize = false
MiniMap.resizeIsWidthDriven = nil
MiniMap.view = nil
MiniMap.mapController = nil
MiniMap.pinController = nil
MiniMap.runtime = nil
MiniMap.mapEventController = nil
MiniMap.pinMirrorStateMachine = nil
MiniMap.inputController = nil
MiniMap.hudSceneFragment = nil
MiniMap.worldMapBlocksMiniMapWork = false
MiniMap.playerMapMirrorDepth = 0
MiniMap.playerMapMirrorPendingCallback = nil
MiniMap.playerMapMirrorZosTilesUpdated = false
MiniMap.playerMapMirrorZosTilesMapRawName = nil
MiniMap.playerMapMirrorZosTilesHorizontal = nil
MiniMap.playerMapMirrorZosTilesVertical = nil
MiniMap.lastHudMapZoomContextSignature = nil
MiniMap.pendingPostReloadUILayout = nil

--- Runs after map index restore when the outermost RunWithPlayerMapForMirror finishes.
function MiniMap.CompletePostPlayerMapMirrorWork()
    local pendingLayout = MiniMap.pendingPostReloadUILayout
    if pendingLayout then
        MiniMap.pendingPostReloadUILayout = nil
        local mapController = pendingLayout.mapController
        local mapData = pendingLayout.mapData
        if mapData and mapController then
            if MiniMap.ApplyFixedMapScroll(mapData) then
                -- fixed map position for this zone
            elseif MiniMap.GetMapFollowsPlayer() and MiniMap.runtime then
                MiniMap.runtime:ClearFollowScrollCache()
                MiniMap.runtime:ApplyScrollCenterOnPlayer(
                    mapController:GetMapContentWidth(),
                    mapController:GetMapContentHeight()
                )
            end
        end
    end
    MiniMap.ScheduleFollowRecoveryAfterWorldMap()
    MiniMap.TryAttachNativeWorldMapContainer()
    if MiniMap.IsNativeWorldMapContainerAttached() then
        MiniMap.ReapplyNativeHudMapOverlayLayout()
        MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
    end
    local pinMirrorStateMachine = MiniMap.pinMirrorStateMachine
    if pinMirrorStateMachine.mapReloadCompletePendingAfterMirror then
        pinMirrorStateMachine.mapReloadCompletePendingAfterMirror = false
        if pinMirrorStateMachine:IsCurrentState("MapReloading") then
            pinMirrorStateMachine:NotifyMapReloadComplete()
        end
    end
end

--- @param mapController MiniMapMapController
--- @param mapData MiniMapMapData
function MiniMap.SchedulePostReloadUILayout(mapController, mapData)
    MiniMap.pendingPostReloadUILayout =
    {
        mapController = mapController,
        mapData = mapData,
    }
end

--- @return boolean
function MiniMap.IsPinMirrorMachineBusy()
    local pinMirrorStateMachine = MiniMap.pinMirrorStateMachine
    if not pinMirrorStateMachine or not pinMirrorStateMachine:HasCurrentState() then
        return false
    end
    return pinMirrorStateMachine:IsCurrentState("MapReloading")
        or pinMirrorStateMachine:IsCurrentState("ZoneReset")
end

--- Prefer tile reload over pin-only sync when map raw name changed while world map was blocking work.
--- @param pinMirrorStateMachine MiniMapPinMirrorStateMachine
function MiniMap.QueuePinMirrorWorkWhileWorldMapBlocked(pinMirrorStateMachine)
    local mapController = pinMirrorStateMachine.mapController
    local lastLoadedMapRawName = mapController and mapController.lastLoadedMapRawName
    if lastLoadedMapRawName and lastLoadedMapRawName ~= GetMapName() then
        pinMirrorStateMachine.mapReloadQueuedWhileWorldMap = true
        if not pinMirrorStateMachine.mapReloadQueuedReason then
            pinMirrorStateMachine.mapReloadQueuedReason = "MapIdentityWhileWorldMap"
        end
    else
        pinMirrorStateMachine.pinSyncQueuedWhileWorldMap = true
    end
end

--- LUIE waypoint / player overlays on view.pins after native g_mapPinManager refresh.
function MiniMap.SyncHudOverlayPinsAfterNativeRefresh()
    if not MiniMap.Enabled then
        return
    end
    local mapController = MiniMap.mapController
    local pinController = MiniMap.pinController
    if not mapController or not mapController:IsReady() or not pinController then
        return
    end
    local mapData = mapController:GetMapData()
    if not mapData then
        return
    end
    pinController:SyncPlayerWaypoint(mapData)
    pinController:SyncPlayerMapPin(mapData)
end

--- Flush ZOS g_mapRefresh groups and re-apply HUD minimap layout on reparented ZO_WorldMapContainer.
function MiniMap.ApplyHudNativePinLayoutAfterRefresh()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    MiniMap.FlushWorldMapPinRefreshGroups()
    MiniMap.ReapplyNativeHudMapOverlayLayout()
end

MiniMap.PLAYER_PIN_BASE_SIZE = 16
MiniMap.ZONE_LABEL_CHROME_OFFSET = 4
MiniMap.FRAME_CHROME_HOVER_SIZE = 24
MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_X = 2
MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_Y = 0
MiniMap.FRAME_CHROME_LEFT_EDGE_MARGIN = 8
MiniMap.FRAME_CHROME_CONTROL_GAP = 4
MiniMap.FRAME_CHROME_BAR_WIDTH = 44
MiniMap.FRAME_CHROME_BAR_HEIGHT = 20
MiniMap.PLAYER_CAMERA_PIP_SIZE_RATIO = 6

--- @class MiniMapInfoPanelRestoreAnchor
--- @field point integer
--- @field relativePoint integer
--- @field offsetX number
--- @field offsetY number

--- @class MiniMapDefaults
--- @field offsetX number
--- @field offsetY number
--- @field width number
--- @field height number
--- @field resetZoomLevel number
--- @field defaultPinScale number
--- @field playerPinScale number
--- @field followPlayer boolean
--- @field panOffsetX number
--- @field panOffsetY number
--- @field lockPosition boolean
--- @field lockSize boolean
--- @field waypointClickRequiresShift boolean
--- @field showZoomButtons boolean
--- @field allowOnGameplayHud boolean
--- @field allowDuringCombat boolean
--- @field allowOnLootScene boolean
--- @field allowOnDeathRecap boolean
--- @field allowWhileMounted boolean
--- @field allowInPlayerHousing boolean
--- @field preferElevatedDrawTier boolean
--- @field overworldMultiTileZoom number
--- @field dungeonMapZoom number
--- @field battlegroundMapZoom number
--- @field mountedZoomMultiplier number
--- @field autoZoomOutAtEdge boolean
--- @field zoneScrollLockEnabled boolean
--- @field zoneScrollLockByMapName table
--- @field pinScaleQuest number
--- @field pinScaleGroup number
--- @field pinScalePoi number
--- @field pinScaleWayshrine number
--- @field pinScaleDigSite number
--- @field pinScaleOther number
--- @field pinTypeScales table
--- @field compassOverride number
--- @field keepSquareAspect boolean
--- @field positionGridDivisor number
--- @field playerPipColor { r: number, g: number, b: number, a: number }
--- @field cameraWedgeColor { r: number, g: number, b: number, a: number }
--- @field borderOpacity number
--- @field pinMirrorStateMachineDebug boolean
--- @field anchorInfoPanelToMiniMap boolean
--- @field infoPanelRestoreAnchor MiniMapInfoPanelRestoreAnchor|nil
--- @field showZoneName boolean
--- @field zoneNameFontFace string
--- @field zoneNameFontSize number
--- @field zoneNameFontStyle number
--- @field movingPinRefreshMs number
--- @field pinMouseOverRefreshMs number

--- @class (partial) ZO_MapPin
--- @field polygonBlob ZO_PinPolygonBlob|nil
--- @field polygonBlobKey any
--- @field luiMiniMapPolygonOnMiniMap boolean|nil
--- @field luiMiniMapDigSiteZoneName string|nil
--- @field validLocation boolean|nil

--- World-map pin host control carrying `m_Pin` (ZO map pin instance).
--- @class ZO_WorldMapPinHostControl : Control
--- @field m_Pin ZO_MapPin|nil

--- Minimap mirrored pin control (texture root or composite); `zoneName` when synced from world map.
--- @class MiniMapPinControl : Control, TextureControl, TextureCompositeControl
--- @field zoneName string|nil
--- @field luiMiniMapPinIsComposite boolean|nil
--- @field luiMiniMapPinBackground TextureControl|nil
--- @field luiMiniMapPinGlow TextureControl|nil
--- @field luiMiniMapPinTexture string|nil
--- @field luiMiniMapPinColor table|nil
--- @field luiMiniMapLastDrawWidth number|nil
--- @field luiMiniMapLastDrawHeight number|nil
--- @field luiMiniMapTextureAnimKey string|nil
--- @field luiMiniMapTextureAnimTimeline AnimationTimeline|nil
--- @field luiMiniMapCompositeSurfaceIndex number|nil
--- @field luiMiniMapNormalizedX number|nil
--- @field luiMiniMapNormalizedY number|nil
--- @field luiMiniMapPinWidth number|nil
--- @field luiMiniMapPinHeight number|nil
--- @field luiMiniMapPinScale number|nil
--- @field luiMiniMapPinType MapDisplayPinType|nil
--- @field SetTexture fun(self: MiniMapPinControl, texture: string)
--- @field SetColor fun(self: MiniMapPinControl, r: number, g: number, b: number, a?: number)
--- @field SetTextureCoords fun(self: MiniMapPinControl, left: number, right: number, top: number, bottom: number)
--- @field SetTextureRotation fun(self: MiniMapPinControl, radians: number, centerX?: number, centerY?: number)
--- @field ClearAllSurfaces fun(self: MiniMapPinControl)
--- @field AddSurface fun(self: MiniMapPinControl, left: number, right: number, top: number, bottom: number):surfaceIndex: luaindex

--- @type MiniMapDefaults
MiniMap.Defaults =
{
    offsetX = -36,
    offsetY = -36,
    width = 272,
    height = 272,
    resetZoomLevel = 0.65,
    defaultPinScale = 1,
    playerPinScale = 1,
    followPlayer = true,
    panOffsetX = 0,
    panOffsetY = 0,
    lockPosition = false,
    lockSize = false,
    waypointClickRequiresShift = true,
    showZoomButtons = false,
    allowOnGameplayHud = true,
    allowDuringCombat = true,
    allowOnLootScene = true,
    allowOnDeathRecap = true,
    allowWhileMounted = true,
    allowInPlayerHousing = true,
    preferElevatedDrawTier = false,
    overworldMultiTileZoom = 0.6,
    dungeonMapZoom = 0.75,
    battlegroundMapZoom = 0.55,
    mountedZoomMultiplier = 1.0,
    autoZoomOutAtEdge = true,
    zoneScrollLockEnabled = false,
    zoneScrollLockByMapName = {},
    pinScaleQuest = 1,
    pinScaleGroup = 1,
    pinScalePoi = 1,
    pinScaleWayshrine = 1,
    pinScaleDigSite = 1,
    pinScaleOther = 1,
    pinTypeScales = {},
    compassOverride = 0,
    keepSquareAspect = false,
    positionGridDivisor = 0,
    playerPipColor = { r = 1, g = 1, b = 1, a = 1 },
    cameraWedgeColor = { r = 1, g = 1, b = 1, a = 1 },
    borderOpacity = 1,
    pinMirrorStateMachineDebug = false,
    anchorInfoPanelToMiniMap = false,
    showZoneName = true,
    zoneNameFontFace = "LUIE Default Font",
    zoneNameFontSize = 18,
    zoneNameFontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
    movingPinRefreshMs = 100,
    pinMouseOverRefreshMs = 200,
}

--- @type MiniMapDefaults
MiniMap.SV = ...

--- @param mapName string
--- @return string
function MiniMap.StripMapNameFormatting(mapName)
    return (string.gsub(mapName, "%^(.+)", ""))
end

MiniMap.MINIMAP_PIN_REFRESH_MS_MIN = 16
MiniMap.MINIMAP_PIN_REFRESH_MS_MAX = 500

--- @return number
function MiniMap.GetMovingPinRefreshMs()
    local refreshMs = MiniMap.SV.movingPinRefreshMs
    return zo_clamp(refreshMs, MiniMap.MINIMAP_PIN_REFRESH_MS_MIN, MiniMap.MINIMAP_PIN_REFRESH_MS_MAX)
end

--- @return number
function MiniMap.GetPinMouseOverRefreshMs()
    local refreshMs = MiniMap.SV.pinMouseOverRefreshMs
    return zo_clamp(refreshMs, MiniMap.MINIMAP_PIN_REFRESH_MS_MIN, MiniMap.MINIMAP_PIN_REFRESH_MS_MAX)
end

--- @param key string
--- @param bufferMs number
--- @return boolean
function MiniMap.ShouldRunThrottled(key, bufferMs)
    MiniMap.throttle = MiniMap.throttle or {}
    local entry = MiniMap.throttle[key]
    local now = GetFrameTimeMilliseconds()
    if not entry then
        MiniMap.throttle[key] = { last = now, buffer = bufferMs }
        return true
    end
    if (now - entry.last) >= bufferMs then
        entry.last = now
        return true
    end
    return false
end

--- @param delta number
function MiniMap.Zoom(delta)
    if not MiniMap.Enabled or not MiniMap.mapController then
        return
    end
    MiniMap.mapController:ApplyZoom(delta)
end

function MiniMap.RecenterFollow()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.SV.followPlayer = true
    MiniMap.runtime:SetMapFollowsPlayer(true)
    MiniMap.runtime:ClearFollowScrollCache()
    if MiniMap.mapController and MiniMap.mapController:IsReady() then
        MiniMap.runtime:ApplyScrollCenterOnPlayer(
            MiniMap.mapController:GetMapContentWidth(),
            MiniMap.mapController:GetMapContentHeight()
        )
    end
end

--- @return boolean
function MiniMap.GetMapFollowsPlayer()
    if MiniMap.SV.zoneScrollLockEnabled == true then
        return false
    end
    if MiniMap.runtime then
        return MiniMap.runtime.mapFollowsPlayer
    end
    return MiniMap.SV.followPlayer
end

--- @return number
function MiniMap.GetPlayerPinDrawSize()
    local scale = MiniMap.SV.playerPinScale
    return zo_round(MiniMap.PLAYER_PIN_BASE_SIZE * scale)
end

function MiniMap.ClampSavedDefaultZoom()
    local zoomMinimum = 0.35
    if MiniMap.mapController then
        zoomMinimum = MiniMap.mapController:GetMinimumZoom()
    end
    if MiniMap.SV.resetZoomLevel < zoomMinimum then
        MiniMap.SV.resetZoomLevel = zoomMinimum
    elseif MiniMap.SV.resetZoomLevel > 1.8 then
        MiniMap.SV.resetZoomLevel = 1.8
    end
end

function MiniMap.ApplyInteractionLocks()
    if not MiniMap.view then
        return
    end
    MiniMap.view:ApplyInteractionLocks(MiniMap.SV)
end

function MiniMap.ApplyChromeVisibility()
    if not MiniMap.view then
        return
    end
    MiniMap.view:ApplyChromeVisibility(MiniMap.SV)
end

--- @param savedColor { r: number, g: number, b: number, a: number }|nil
--- @param defaultColor { r: number, g: number, b: number, a: number }
--- @return number r, number g, number b, number a
local function GetMiniMapSavedColorComponents(savedColor, defaultColor)
    if not savedColor then
        return defaultColor.r, defaultColor.g, defaultColor.b, defaultColor.a
    end
    local red = savedColor.r
    if red == nil then
        red = defaultColor.r
    end
    local green = savedColor.g
    if green == nil then
        green = defaultColor.g
    end
    local blue = savedColor.b
    if blue == nil then
        blue = defaultColor.b
    end
    local alpha = savedColor.a
    if alpha == nil then
        alpha = defaultColor.a
    end
    return red, green, blue, alpha
end

--- @return number r, number g, number b, number a
function MiniMap.GetPlayerPipColor()
    local defaults = MiniMap.Defaults
    local settings = MiniMap.SV
    local defaultColor = defaults.playerPipColor
    local savedColor = settings.playerPipColor
    return GetMiniMapSavedColorComponents(savedColor, defaultColor)
end

--- @return number r, number g, number b, number a
function MiniMap.GetCameraWedgeColor()
    local defaults = MiniMap.Defaults
    local settings = MiniMap.SV
    local defaultColor = defaults.cameraWedgeColor
    local savedColor = settings.cameraWedgeColor
    return GetMiniMapSavedColorComponents(savedColor, defaultColor)
end

function MiniMap.ApplyPlayerPipColors()
    if not MiniMap.view then
        return
    end
    local playerRed, playerGreen, playerBlue, playerAlpha = MiniMap.GetPlayerPipColor()
    local wedgeRed, wedgeGreen, wedgeBlue, wedgeAlpha = MiniMap.GetCameraWedgeColor()
    MiniMap.view.player:SetColor(playerRed, playerGreen, playerBlue, playerAlpha)
    local followPlayer = MiniMap.GetMapFollowsPlayer()
    local nativeHudMapAttached = MiniMap.IsNativeWorldMapContainerAttached()
    if not (nativeHudMapAttached and followPlayer) then
        MiniMap.view.playerCam:SetColor(wedgeRed, wedgeGreen, wedgeBlue, wedgeAlpha)
    end
    if nativeHudMapAttached then
        MiniMap.ApplyNativeWorldMapPlayerPinColors()
    end
end

function MiniMap.ApplyLiveSettings()
    if not MiniMap.Enabled or not MiniMap.view then
        return
    end
    MiniMap.view:ApplyInteractionLocks(MiniMap.SV)
    MiniMap.view:ApplyChromeVisibility(MiniMap.SV)
    MiniMap.ApplyZoneNameFont()
    MiniMap.view:ApplyPlayerIconDimensions()
    if MiniMap.IsNativeWorldMapContainerAttached() then
        MiniMap.ApplyNativeHudPlayerPinScale()
    end
    MiniMap.ApplyPlayerPipColors()
    MiniMap.runtime:UpdateCenterPlayerPipVisibility()
    MiniMap.inputController:ApplyFrameDragMouseEnabled()
    MiniMap.ApplyChromeFromSettings()
    MiniMap.ApplyChromeStacking()
    MiniMap.RefreshSceneFragments()
    MiniMap.UpdateConditionalVisibility()
    if MiniMap.pinController and MiniMap.mapController and MiniMap.mapController:IsReady() then
        local mapData = MiniMap.mapController:GetMapData()
        if mapData then
            MiniMap.pinController:RelayoutActivePinsForUserPinScale(mapData)
        end
    end
end
