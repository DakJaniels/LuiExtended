-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- The MiniMap module table. The minimap reuses the real ZO_WorldMap (driven into
--- a dedicated map mode and shown on the HUD via WORLD_MAP_FRAGMENT), so this table
--- holds only module state, saved vars, constants, type aliases, and ownerless
--- utility functions. The engine, scheduler, pin tweaks, and public API attach the
--- rest of their surface to this same table.
--- @class (partial) LUIE.MiniMap
--- @field SV MiniMapDefaults
--- @field Defaults MiniMapDefaults
--- @field Enabled boolean
--- @field moduleName string
--- @field zoom number
--- @field fastTravel boolean
--- @field mapFollowsPlayer boolean
--- @field async MiniMapAsyncScheduler
local MiniMap = {}
MiniMap.__index = MiniMap
LUIE.MiniMap = MiniMap

MiniMap.moduleName = LUIE.name .. "MiniMap"
MiniMap.Enabled = false

-- Current context target zoom scale (see zoom-context handling in MiniMap.lua).
MiniMap.zoom = 0.5
-- True while a fast/keep travel interaction has pushed the world map into a special mode.
MiniMap.fastTravel = false
-- Runtime follow flag, seeded from SV.followPlayer when the module starts.
MiniMap.mapFollowsPlayer = true

--- Dedicated world-map mode id used to drive ZO_WorldMap as the HUD minimap.
--- Exported for third-party integration.
MiniMap.MAP_MODE_LUIE_MINIMAP = 42

MiniMap.PLAYER_PIN_BASE_SIZE = 16
MiniMap.ZONE_LABEL_CHROME_OFFSET = 4
MiniMap.FRAME_CHROME_HOVER_SIZE = 24
MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_X = 2
MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_Y = 0
MiniMap.FRAME_CHROME_LEFT_EDGE_MARGIN = 8
MiniMap.FRAME_CHROME_CONTROL_GAP = 4
MiniMap.FRAME_CHROME_BAR_WIDTH = 44
MiniMap.FRAME_CHROME_BAR_HEIGHT = 20

MiniMap.MINIMAP_PIN_REFRESH_MS_MIN = 16
MiniMap.MINIMAP_PIN_REFRESH_MS_MAX = 500

-- Saved default zoom is stored as a context scale; clamp keeps it in a usable band.
MiniMap.RESET_ZOOM_SCALE_MIN = 0.35
MiniMap.RESET_ZOOM_SCALE_MAX = 1.8

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
--- @field playerHeadingPipColor { r: number, g: number, b: number, a: number }
--- @field borderOpacity number
--- @field anchorInfoPanelToMiniMap boolean
--- @field infoPanelRestoreAnchor MiniMapInfoPanelRestoreAnchor|nil
--- @field showZoneName boolean
--- @field zoneNameFontFace string
--- @field zoneNameFontSize number
--- @field zoneNameFontStyle number
--- @field movingPinRefreshMs number
--- @field pinMouseOverRefreshMs number

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
    playerHeadingPipColor = { r = 1, g = 1, b = 1, a = 1 },
    borderOpacity = 1,
    anchorInfoPanelToMiniMap = false,
    showZoneName = true,
    zoneNameFontFace = "LUIE Default Font",
    zoneNameFontSize = 18,
    zoneNameFontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
    movingPinRefreshMs = 100,
    pinMouseOverRefreshMs = 200,
}

-- Saved vars are bound during MiniMap.Initialize (LUIE_MiniMap_SV).
MiniMap.SV = nil

--- @param mapName string
--- @return string
function MiniMap.StripMapNameFormatting(mapName)
    return (string.gsub(mapName, "%^(.+)", ""))
end

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

--- Simple time-based throttle keyed by a string; returns true when the buffer has elapsed.
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

--- @return boolean
function MiniMap.GetMapFollowsPlayer()
    if MiniMap.SV.zoneScrollLockEnabled == true then
        return false
    end
    return MiniMap.mapFollowsPlayer == true
end

--- @return number
function MiniMap.GetPlayerPinDrawSize()
    local scale = MiniMap.SV.playerPinScale
    return zo_round(MiniMap.PLAYER_PIN_BASE_SIZE * scale)
end

--- Clamp the stored default zoom scale into the usable band.
function MiniMap.ClampSavedDefaultZoom()
    if MiniMap.SV.resetZoomLevel < MiniMap.RESET_ZOOM_SCALE_MIN then
        MiniMap.SV.resetZoomLevel = MiniMap.RESET_ZOOM_SCALE_MIN
    elseif MiniMap.SV.resetZoomLevel > MiniMap.RESET_ZOOM_SCALE_MAX then
        MiniMap.SV.resetZoomLevel = MiniMap.RESET_ZOOM_SCALE_MAX
    end
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
    return GetMiniMapSavedColorComponents(settings.playerPipColor, defaults.playerPipColor)
end

--- @return number r, number g, number b, number a
function MiniMap.GetPlayerHeadingPipColor()
    local defaults = MiniMap.Defaults
    local settings = MiniMap.SV
    return GetMiniMapSavedColorComponents(settings.playerHeadingPipColor, defaults.playerHeadingPipColor)
end
