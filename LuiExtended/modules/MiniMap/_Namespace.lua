-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- Facade for the HUD minimap. XML handlers, keybinds, settings and InfoPanel call into this table;
--- the runtime lives in `LUIE_MiniMap_Manager` (modules/MiniMap/MiniMap_Manager.lua).
--- @class (partial) LUIE.MiniMap : ZO_Object
--- @field SV MiniMapDefaults
--- @field Defaults MiniMapDefaults
--- @field Enabled boolean
--- @field moduleName string
--- @field manager LUIE_MiniMap_Manager|nil
local MiniMap = ZO_Object:Subclass()
LUIE.MiniMap = MiniMap

MiniMap.moduleName = LUIE.name .. "MiniMap"
MiniMap.Enabled = false
MiniMap.manager = nil

--- Exported map mode id for third-party integration (external addons compare against this constant).
MiniMap.MAP_MODE_LUIE_MINIMAP = 42

MiniMap.PLAYER_PIN_BASE_SIZE = 16
MiniMap.ZONE_LABEL_OFFSET = 4
--- Drag bar (padlock + drag handle) sits inside the map's bottom-left corner; the zoom buttons own the bottom-right.
--- The bar control is the hit region; its backdrop is inset by DRAG_BAR_HIT_PADDING so mouse-over has a few px of grace.
MiniMap.DRAG_BAR_HIT_PADDING = 4
MiniMap.DRAG_BAR_CORNER_INSET = 4
MiniMap.DRAG_BAR_BAR_HEIGHT = 28
MiniMap.DRAG_BAR_BAR_WIDTH_UNLOCKED = 56
MiniMap.DRAG_BAR_BAR_WIDTH_LOCKED = 32
MiniMap.PLAYER_CAMERA_PIP_SIZE_RATIO = 6

MiniMap.MINIMAP_ZOOM_MIN_FALLBACK = 0.35
MiniMap.MINIMAP_ZOOM_MAX = 1.8
MiniMap.MINIMAP_ZOOM_STEP = 0.1

--- Floor matches ZOS: ZO_WorldMap's Update only moves pins every CONSTANTS.PIN_UPDATE_DELAY = 0.04s
--- (EsoUI/Ingame/Map/WorldMap.lua:55, 1681-1687), so updating or mirroring faster than 40ms re-reads identical data.
--- Follow scroll and pip headings are per frame regardless (LUIE_MiniMap_Manager:OnFrameUpdate).
MiniMap.MINIMAP_PIN_REFRESH_MS_MIN = 40
MiniMap.MINIMAP_PIN_REFRESH_MS_MAX = 500

-- EsoUI/Ingame/Map/MapPin.lua CONSTANTS (DEFAULT_PIN_SIZE = 20, MIN_PIN_SIZE = 18, MIN_PIN_SCALE = 0.6, MAX_PIN_SCALE = 1)
MiniMap.MINIMAP_PIN_DEFAULT_SIZE = 20
MiniMap.MINIMAP_PIN_MIN_SIZE = 18
MiniMap.MINIMAP_PIN_MIN_SCALE = 0.6
MiniMap.MINIMAP_PIN_MAX_SCALE = 1.0

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
--- @field zoneScrollLockByMapName table<string, { x: number, y: number }>
--- @field pinScaleQuest number
--- @field pinScaleGroup number
--- @field pinScalePoi number
--- @field pinScaleWayshrine number
--- @field pinScaleDigSite number
--- @field pinScaleOther number
--- @field pinScaleHarvestMap number
--- @field pinTypeScales table<integer, number>
--- @field compassOverride number Legacy key kept for saved-variable compatibility; no longer read.
--- @field showPlayerPip boolean
--- @field playerPipColor { r: number, g: number, b: number, a: number }
--- @field cameraWedgeColor { r: number, g: number, b: number, a: number }
--- @field borderOpacity number
--- @field pinMirrorStateMachineDebug boolean
--- @field anchorInfoPanelToMiniMap boolean
--- @field infoPanelRestoreAnchor MiniMapInfoPanelRestoreAnchor|nil
--- @field showZoneName boolean
--- @field zoneNameAboveMap boolean
--- @field zoneNameFontFace string
--- @field zoneNameFontSize number
--- @field zoneNameFontStyle number
--- @field movingPinRefreshMs number
--- @field pinMouseOverRefreshMs number Legacy key kept for saved-variable compatibility; no longer read.

--- World-map pin fields the pin layer reads (EsoUI/Ingame/Map/MapPin.lua).
--- @class (partial) ZO_MapPin
--- @field backgroundControl TextureControl
--- @field highlightControl TextureControl
--- @field pinBlob TextureControl|nil
--- @field polygonBlob PolygonControl|nil
--- @field radius number|nil
--- @field borderInformation { borderPoints: { x: number, y: number }[], borderWidth: number, borderHeight: number }|nil
--- @field m_PinType integer|nil

--- Pin entry control (`LUIE_MiniMap_Pin` virtual template).
--- @class LUIE_MiniMap_PinControl : Control
--- @field background TextureControl
--- @field highlight TextureControl
--- @field worldMapPin ZO_MapPin|nil
--- @field poolKey any
--- @field isMoving boolean|nil
--- @field lastTexture string|nil
--- @field lastHighlightTexture string|nil
--- @field lastSize number|nil
--- @field lastOffsetX number|nil
--- @field lastOffsetY number|nil
--- @field lastRotation number|nil

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
    pinScaleHarvestMap = 1,
    pinTypeScales = {},
    compassOverride = 0,
    showPlayerPip = true,
    playerPipColor = { r = 1, g = 1, b = 1, a = 1 },
    cameraWedgeColor = { r = 1, g = 1, b = 1, a = 1 },
    borderOpacity = 1,
    pinMirrorStateMachineDebug = false,
    anchorInfoPanelToMiniMap = false,
    showZoneName = true,
    zoneNameAboveMap = false,
    zoneNameFontFace = "LUIE Default Font",
    zoneNameFontSize = 18,
    zoneNameFontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
    movingPinRefreshMs = 100,
    pinMouseOverRefreshMs = 200,
}

--- @type MiniMapDefaults
MiniMap.SV = ...

--- Dev debug output. Gated by `SV.pinMirrorStateMachineDebug` (toggled from the LAM/LibHarvens Advanced submenu).
MiniMap.debugLoggingEnabled = false

--- @param formatString string
--- @param ... any
function MiniMap.LogDebug(formatString, ...)
    if not MiniMap.debugLoggingEnabled then
        return
    end
    LUIE:Log("Debug", string.format("[MiniMap] " .. formatString, ...))
end

--- Re-reads the saved debug flag (settings setFunc) and forwards it to the manager state machine.
function MiniMap.ApplyDebugLogging()
    MiniMap.debugLoggingEnabled = MiniMap.SV ~= nil and MiniMap.SV.pinMirrorStateMachineDebug == true
    local manager = MiniMap.manager
    if manager and manager.mapStateMachine then
        manager.mapStateMachine:SetDebugLoggingEnabled(MiniMap.debugLoggingEnabled)
    end
end

--- @param mapName string
--- @return string
function MiniMap.StripMapNameFormatting(mapName)
    return (string.gsub(mapName, "%^(.+)", ""))
end

--- @return number
function MiniMap.GetMovingPinRefreshMs()
    local refreshMs = MiniMap.SV.movingPinRefreshMs or MiniMap.Defaults.movingPinRefreshMs
    return zo_clamp(refreshMs, MiniMap.MINIMAP_PIN_REFRESH_MS_MIN, MiniMap.MINIMAP_PIN_REFRESH_MS_MAX)
end

--- @return number
function MiniMap.GetPlayerPinDrawSize()
    local scale = MiniMap.SV.playerPinScale or MiniMap.Defaults.playerPinScale
    return zo_round(MiniMap.PLAYER_PIN_BASE_SIZE * scale)
end

--- @param savedColor { r: number, g: number, b: number, a: number }|nil
--- @param defaultColor { r: number, g: number, b: number, a: number }
--- @return number red, number green, number blue, number alpha
local function GetSavedColorComponents(savedColor, defaultColor)
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

--- @return number red, number green, number blue, number alpha
function MiniMap.GetPlayerPipColor()
    return GetSavedColorComponents(MiniMap.SV.playerPipColor, MiniMap.Defaults.playerPipColor)
end

--- @return number red, number green, number blue, number alpha
function MiniMap.GetPlayerCameraPipColor()
    return GetSavedColorComponents(MiniMap.SV.cameraWedgeColor, MiniMap.Defaults.cameraWedgeColor)
end
