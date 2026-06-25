-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

-- -----------------------------------------------------------------------------
-- MiniMap engine.
--
-- The minimap is the real ZO_WorldMap driven into a dedicated map mode
-- (MiniMap.MAP_MODE_LUIE_MINIMAP) and shown on the HUD through the conditional
-- WORLD_MAP_FRAGMENT. This file owns the mode flip, visibility, follow tick,
-- zoom, position persistence, chrome, native pin styling, and the public
-- facades referenced by keybinds, settings, and the info panel.
--
-- Technique reference: VotansMiniMap. Every ZOS hook below is verified against
-- the live source in esoui/esoui/ingame/map/. No Votan identifiers are reused.
-- -----------------------------------------------------------------------------

local EVENT_MANAGER = GetEventManager()
local CALLBACK_MANAGER = CALLBACK_MANAGER
local WORLD_MAP_MANAGER = WORLD_MAP_MANAGER

local LUIE_MINIMAP_MODE = MiniMap.MAP_MODE_LUIE_MINIMAP

-- Context-scale band (MiniMap.zoom). Mirrors the legacy minimap scale range.
local MINIMAP_ZOOM_SCALE_MIN = MiniMap.RESET_ZOOM_SCALE_MIN
local MINIMAP_ZOOM_SCALE_MAX = MiniMap.RESET_ZOOM_SCALE_MAX
local MINIMAP_HOLD_ZOOM_IN_MULTIPLIER = 0.55
local MINIMAP_HOLD_ZOOM_OUT_MULTIPLIER = 1.25
local MINIMAP_ZOOM_STEP = 0.1
local MINIMAP_EDGE_AUTO_ZOOM_THRESHOLD = 0.04

-- Follow-tick cadence (seconds) ported from the reference minimap.
local MINIMAP_MAP_CHECK_INTERVAL_SECONDS = 1.0
local MINIMAP_PAN_INTERVAL_SECONDS = 0.2

local MINIMAP_COMPASS_OVERRIDE_DEFAULT = 0
local MINIMAP_COMPASS_OVERRIDE_HIDE = 1
local MINIMAP_COMPASS_OVERRIDE_SHOW = 2

local COMPASS_CONTROLS =
{
    ZO_CompassCenterOverPinLabel,
    ZO_CompassContainer,
    ZO_CompassFrameLeft,
    ZO_CompassFrameCenter,
    ZO_CompassFrameRight,
}

local LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME = "LibHarvensAddonSettingsScene"
local INFO_PANEL_DEFAULT_OFFSET_X = -24
local INFO_PANEL_DEFAULT_OFFSET_Y = 20

-- Session state populated by Initialize.
MiniMap.sessionMapVisible = true
MiniMap.consoleLayoutPreviewActive = false
MiniMap.holdZoomActive = false
MiniMap.holdZoomSavedScale = nil
MiniMap.worldMapSavedVars = nil
MiniMap.hooksInstalled = false

-- Cached map controls (resolved in Initialize once the base UI exists).
local worldMapControl
local worldMapScrollControl
-- Overlay arrow showing the player's body facing. The native ZO_WorldMap player
-- pin rotates to GetPlayerCameraHeading() (mappin_manager.lua), so this second
-- pip provides the player-direction half of the dual heading indicator.
local playerHeadingPip

-- Original ZOS functions captured when hooks are installed.
local originalGetMapDimensions
local originalUpdateSizeHandler
local originalGetMapTitle
local originalMouseDown
local originalResizeStop
local originalShowWorldMap
local originalRefreshMapFrameAnchor
local originalPushSpecialMode
local originalTryShowSpectacleHeader
local originalWorldMapOnUpdate

-- Follow-tick bookkeeping.
local followJumpNextPan = true
local lastFollowMapCheckSeconds = 0
local lastFollowPanSeconds = 0
local lastFollowMapTexture = nil

local function NoOperation() end

-- -----------------------------------------------------------------------------
-- Mode helpers
-- -----------------------------------------------------------------------------

--- @return boolean
function MiniMap.IsMiniMapModeActive()
    return WORLD_MAP_MANAGER:IsInMode(LUIE_MINIMAP_MODE)
end

--- @return boolean
function MiniMap.IsMiniMapVisible()
    return MiniMap.IsMiniMapModeActive() and WORLD_MAP_FRAGMENT:IsShowing()
end

--- @return ZO_MapPanAndZoom
local function GetPanAndZoom()
    return ZO_WorldMap_GetPanAndZoom()
end

--- Copy the small custom mode table into mode 42 so SetToMode finds modeData.
--- @param savedVars table
function MiniMap.OnWorldMapSavedVarsReady(savedVars)
    MiniMap.worldMapSavedVars = savedVars
    local existingMode = savedVars[LUIE_MINIMAP_MODE]
    if not existingMode then
        existingMode = ZO_DeepTableCopy(savedVars[MAP_MODE_SMALL_CUSTOM])
        savedVars[LUIE_MINIMAP_MODE] = existingMode
        -- MAP_MODE_SMALL_CUSTOM ships keepSquare = true, which forces ZOS to clamp
        -- the map to a square on every resize. The minimap defaults to free
        -- rectangular sizing; ApplyKeepSquareSetting re-syncs this from the setting.
        existingMode.keepSquare = false
    end
    -- Keep the pin filter checked-state aligned with the full custom map.
    local sourceFilters = savedVars[MAP_MODE_LARGE_CUSTOM] and savedVars[MAP_MODE_LARGE_CUSTOM].filters
    if sourceFilters and existingMode.filters then
        for filterType, filterValues in pairs(sourceFilters) do
            existingMode.filters[filterType] = filterValues
        end
    end
end

--- @return table|nil
local function GetMiniMapModeData()
    local savedVars = MiniMap.worldMapSavedVars
    return savedVars and savedVars[LUIE_MINIMAP_MODE] or nil
end

-- -----------------------------------------------------------------------------
-- Position / size persistence
-- -----------------------------------------------------------------------------

--- Anchor and size ZO_WorldMap from the LUIE saved layout without forcing a full
--- map update (the reference minimap suppresses ZO_WorldMap_UpdateMap here).
function MiniMap.RestoreMapPosition()
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    local settings = MiniMap.SV
    local defaults = MiniMap.Defaults
    local uiWidth, uiHeight = GuiRoot:GetDimensions()

    local savedUpdateMap = ZO_WorldMap_UpdateMap
    ZO_WorldMap_UpdateMap = NoOperation
    ZO_WorldMap_OnResizeStart(worldMapControl)

    worldMapControl:ClearAnchors()
    worldMapControl:SetDimensionConstraints(128, 144, uiWidth, uiHeight)
    worldMapControl:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, settings.offsetX or defaults.offsetX, settings.offsetY or defaults.offsetY)
    worldMapControl:SetDimensions(zo_max(settings.width or defaults.width, 100), zo_max(settings.height or defaults.height, 100))

    ZO_WorldMap_OnResizeStop(worldMapControl)
    ZO_WorldMap_UpdateMap = savedUpdateMap

    MiniMap.ApplyChromePlacement()
    MiniMap.ApplySuppressedNativeWorldMapChrome()
end

--- Persist the current ZO_WorldMap rectangle back into the LUIE saved layout.
function MiniMap.SaveMapPosition()
    local settings = MiniMap.SV
    local rootRight, rootBottom = GuiRoot:GetRight(), GuiRoot:GetBottom()
    settings.offsetX = worldMapControl:GetRight() - rootRight
    settings.offsetY = worldMapControl:GetBottom() - rootBottom
    settings.width, settings.height = worldMapControl:GetDimensions()

    local modeData = GetMiniMapModeData()
    if modeData then
        modeData.width, modeData.height = settings.width, settings.height
    end
end

function MiniMap.ResetPosition()
    MiniMap.SV.offsetX = MiniMap.Defaults.offsetX
    MiniMap.SV.offsetY = MiniMap.Defaults.offsetY
    MiniMap.ApplyFrameLayoutFromSavedSettings(true)
end

--- Sync the LUIE keepSquareAspect setting onto the ZOS mode-42 data. ZOS owns the
--- aspect during a live resize via modeData.keepSquare (worldmap.lua: the
--- g_resizingMap branch in the map OnUpdate and RefreshMapFrameAnchor), so the
--- minimap resizes freely (rectangular) when this is false and is conformed to a
--- square when true. No custom aspect math is needed on our side.
function MiniMap.ApplyKeepSquareSetting()
    local modeData = GetMiniMapModeData()
    if not modeData then
        return
    end
    local keepSquare = MiniMap.SV.keepSquareAspect == true
    modeData.keepSquare = keepSquare
    if keepSquare then
        local size = zo_max(MiniMap.SV.width or MiniMap.Defaults.width, MiniMap.SV.height or MiniMap.Defaults.height)
        MiniMap.SV.width, MiniMap.SV.height = size, size
    end
    if MiniMap.IsMiniMapModeActive() then
        MiniMap.RestoreMapPosition()
    end
end

--- @param settings MiniMapDefaults
function MiniMap.SnapFrameLayoutToPositionGrid(settings)
    if not settings.positionGridDivisor or settings.positionGridDivisor <= 1 then
        return
    end
    local divisor = settings.positionGridDivisor
    settings.width = zo_max(zo_round((settings.width or MiniMap.Defaults.width) / divisor) * divisor, 100)
    settings.height = zo_max(zo_round((settings.height or MiniMap.Defaults.height) / divisor) * divisor, 100)
    settings.offsetX = zo_round(settings.offsetX / divisor) * divisor
    settings.offsetY = zo_round(settings.offsetY / divisor) * divisor
end

--- @param settings MiniMapDefaults
function MiniMap.ApplyPositionGridSnap(settings)
    if not settings then
        return
    end
    MiniMap.SnapFrameLayoutToPositionGrid(settings)
    MiniMap.ApplyFrameLayoutFromSavedSettings(true)
end

--- @param skipPositionGridSnap boolean|nil
function MiniMap.ApplyFrameLayoutFromSavedSettings(skipPositionGridSnap)
    local settings = MiniMap.SV
    if skipPositionGridSnap ~= true and settings.positionGridDivisor and settings.positionGridDivisor > 1 then
        MiniMap.SnapFrameLayoutToPositionGrid(settings)
    end
    settings.width = zo_max(settings.width or MiniMap.Defaults.width, 100)
    settings.height = zo_max(settings.height or MiniMap.Defaults.height, 100)
    local modeData = GetMiniMapModeData()
    if modeData then
        modeData.keepSquare = settings.keepSquareAspect == true
    end
    MiniMap.RestoreMapPosition()
    MiniMap.ApplyChromeStacking()
    MiniMap.RefreshCustomZoom()
end

--- Enable or disable window mouse/move/resize per the lock settings.
function MiniMap.ApplyFrameLock()
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    local positionUnlocked = MiniMap.SV.lockPosition ~= true and not IsInGamepadPreferredMode()
    worldMapControl:SetMovable(positionUnlocked)
    worldMapControl:SetMouseEnabled(positionUnlocked or MiniMap.SV.lockSize ~= true)
    worldMapControl:SetResizeHandleSize(MiniMap.SV.lockSize == true and 0 or 8)
    MiniMap.ApplyFrameChromeLockState()
end

-- -----------------------------------------------------------------------------
-- Zoom
-- -----------------------------------------------------------------------------

--- @return boolean
function MiniMap.IsInBattlegroundMap()
    return IsActiveWorldBattleground()
end

--- @return boolean
function MiniMap.IsInDungeonMap()
    return IsUnitInDungeon("player")
end

--- Context base scale chosen from the active map type, mirroring legacy behavior.
--- @return number
function MiniMap.GetContextBaseScale()
    local settings = MiniMap.SV
    if MiniMap.IsInBattlegroundMap() then
        return settings.battlegroundMapZoom or settings.resetZoomLevel
    end
    local mapContentType = GetMapContentType()
    if mapContentType == MAP_CONTENT_BATTLEGROUND then
        return settings.battlegroundMapZoom or settings.resetZoomLevel
    end
    if mapContentType == MAP_CONTENT_DUNGEON or MiniMap.IsInDungeonMap() then
        return settings.dungeonMapZoom or settings.resetZoomLevel
    end
    local horizontalTiles = select(1, GetMapNumTiles())
    if horizontalTiles and horizontalTiles > 1 and settings.overworldMultiTileZoom then
        return settings.overworldMultiTileZoom
    end
    return settings.resetZoomLevel
end

--- @return number
function MiniMap.GetMountedZoomMultiplier()
    local settings = MiniMap.SV
    if IsMounted() and settings.mountedZoomMultiplier then
        return settings.mountedZoomMultiplier
    end
    return 1
end

--- @return number
function MiniMap.GetContextTargetScale()
    return MiniMap.GetContextBaseScale() * MiniMap.GetMountedZoomMultiplier()
end

--- @param scale number
--- @return number
local function ClampZoomScale(scale)
    return zo_clamp(scale, MINIMAP_ZOOM_SCALE_MIN, MINIMAP_ZOOM_SCALE_MAX)
end

--- Translate the LUIE context scale into a ZOS normalized custom max zoom that
--- keeps the map texture at (or below) native pixel density. Ported math from
--- the reference minimap, verified against ZO_MapPanAndZoom:ComputeMaxZoom.
--- @param targetScale number
--- @return number|nil
local function ComputeCustomMaxZoom(targetScale)
    local panAndZoom = GetPanAndZoom()
    if not panAndZoom or not panAndZoom:CanInitializeMap() then
        return nil
    end
    local numTiles = GetMapNumTiles()
    local firstTile = ZO_WorldMapContainer1
    local tilePixelWidth = firstTile and firstTile:GetTextureFileDimensions() or 1
    local totalPixels = numTiles * tilePixelWidth
    local scrollWidth, scrollHeight = worldMapScrollControl:GetDimensions()
    scrollWidth, scrollHeight = zo_round(scrollWidth), zo_round(scrollHeight)
    local mapAreaUIUnits = zo_min(scrollWidth, scrollHeight)
    if mapAreaUIUnits < 1 then
        return nil
    end
    local mapAreaPixels = zo_max(mapAreaUIUnits * GetUIGlobalScale(), 1)
    local aspect = zo_max(scrollWidth, scrollHeight) / mapAreaUIUnits
    local maxZoom = math.floor((totalPixels / mapAreaPixels - aspect) * 500 * targetScale) / 500 + aspect
    return zo_max(maxZoom, 1)
end

--- Re-derive and apply the custom zoom levels for the current context scale.
function MiniMap.RefreshCustomZoom()
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    local panAndZoom = GetPanAndZoom()
    if not panAndZoom then
        return
    end
    local maxZoom = ComputeCustomMaxZoom(MiniMap.zoom)
    if not maxZoom then
        return
    end
    ZO_WorldMap_SetCustomZoomLevels(panAndZoom:ComputeMinZoom(), maxZoom)
    panAndZoom:SetCurrentNormalizedZoom(1)
    MiniMap.SetZoomLabel(MiniMap.zoom)
end

function MiniMap.ApplyContextDefaultZoom()
    MiniMap.zoom = ClampZoomScale(MiniMap.GetContextTargetScale())
    MiniMap.RefreshCustomZoom()
end

--- Keybind / button zoom. direction 0 resets to the context default.
--- @param direction number
function MiniMap.Zoom(direction)
    if not MiniMap.Enabled then
        return
    end
    if direction == 0 then
        MiniMap.ApplyContextDefaultZoom()
    else
        MiniMap.zoom = ClampZoomScale(MiniMap.zoom + direction * MINIMAP_ZOOM_STEP)
        MiniMap.RefreshCustomZoom()
    end
    MiniMap.SetZoomLabel(MiniMap.zoom, true)
end

--- @param zoomIn boolean
function MiniMap.BeginHoldZoom(zoomIn)
    if not MiniMap.Enabled or MiniMap.holdZoomActive then
        return
    end
    MiniMap.holdZoomActive = true
    MiniMap.holdZoomSavedScale = MiniMap.zoom
    local factor = zoomIn and MINIMAP_HOLD_ZOOM_IN_MULTIPLIER or MINIMAP_HOLD_ZOOM_OUT_MULTIPLIER
    MiniMap.zoom = ClampZoomScale(MiniMap.zoom * factor)
    MiniMap.RefreshCustomZoom()
end

function MiniMap.EndHoldZoom()
    if not MiniMap.holdZoomActive or MiniMap.holdZoomSavedScale == nil then
        MiniMap.holdZoomActive = false
        return
    end
    MiniMap.zoom = MiniMap.holdZoomSavedScale
    MiniMap.holdZoomSavedScale = nil
    MiniMap.holdZoomActive = false
    MiniMap.RefreshCustomZoom()
end

--- Zoom one step out when the player nears the visible map edge while following.
local function TryAutoZoomOutAtEdge()
    if MiniMap.SV.autoZoomOutAtEdge ~= true or not MiniMap.GetMapFollowsPlayer() then
        return
    end
    local normalizedX, normalizedY = GetMapPlayerPosition("player")
    if normalizedX <= 0 or normalizedY <= 0 then
        return
    end
    if  normalizedX > MINIMAP_EDGE_AUTO_ZOOM_THRESHOLD and normalizedX < (1 - MINIMAP_EDGE_AUTO_ZOOM_THRESHOLD)
    and normalizedY > MINIMAP_EDGE_AUTO_ZOOM_THRESHOLD and normalizedY < (1 - MINIMAP_EDGE_AUTO_ZOOM_THRESHOLD) then
        return
    end
    MiniMap.Zoom(-1)
end

-- -----------------------------------------------------------------------------
-- Fixed map position (zone scroll lock)
-- -----------------------------------------------------------------------------

function MiniMap.ToggleFixedMapPosition()
    local settings = MiniMap.SV
    settings.zoneScrollLockEnabled = not settings.zoneScrollLockEnabled
    settings.zoneScrollLockByMapName = settings.zoneScrollLockByMapName or {}

    if settings.zoneScrollLockEnabled then
        local mapTexture = GetMapTileTexture()
        local normalizedX, normalizedY = GetMapPlayerPosition("player")
        if normalizedX > 0 and normalizedY > 0 then
            settings.zoneScrollLockByMapName[mapTexture] = { x = normalizedX, y = normalizedY }
        end
        MiniMap.mapFollowsPlayer = false
    else
        MiniMap.RecenterFollow()
    end
end

--- Pan the locked map to its saved focus point. Returns true when handled.
--- @return boolean
local function ApplyFixedMapScroll()
    local settings = MiniMap.SV
    if settings.zoneScrollLockEnabled ~= true or not settings.zoneScrollLockByMapName then
        return false
    end
    local fixedEntry = settings.zoneScrollLockByMapName[GetMapTileTexture()]
    if not fixedEntry then
        return false
    end
    ZO_WorldMap_PanToNormalizedPosition(fixedEntry.x, fixedEntry.y)
    return true
end

-- -----------------------------------------------------------------------------
-- Follow player
-- -----------------------------------------------------------------------------

function MiniMap.StartFollowPlayer()
    followJumpNextPan = true
end

function MiniMap.RecenterFollow()
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    MiniMap.mapFollowsPlayer = MiniMap.SV.followPlayer == true and MiniMap.SV.zoneScrollLockEnabled ~= true
    followJumpNextPan = true
    if DoesCurrentMapMatchMapForPlayerLocation() then
        ZO_WorldMap_JumpToPlayer()
    end
end

--- Move the map to the player using a jump (snap) or pan (smooth) as requested.
local function MoveMapToPlayer()
    if followJumpNextPan then
        ZO_WorldMap_JumpToPlayer()
        followJumpNextPan = false
    else
        ZO_WorldMap_PanToPlayer()
    end
end

--- Follow/update tick. Keeps the HUD map centered on the player and the map
--- matched to the player location, throttled like the reference minimap.
--- @param currentTimeSeconds number
local function UpdateFollowTick(currentTimeSeconds)
    if not MiniMap.IsMiniMapModeActive() or not WORLD_MAP_FRAGMENT:IsShowing() then
        return
    end
    if MiniMap.GetMapFollowsPlayer() ~= true then
        if (currentTimeSeconds - lastFollowPanSeconds) >= MINIMAP_PAN_INTERVAL_SECONDS then
            lastFollowPanSeconds = currentTimeSeconds
            ApplyFixedMapScroll()
        end
        return
    end

    local needsMapChange = false
    if (currentTimeSeconds - lastFollowMapCheckSeconds) >= MINIMAP_MAP_CHECK_INTERVAL_SECONDS then
        lastFollowMapCheckSeconds = currentTimeSeconds
        local mapTexture = GetMapTileTexture()
        needsMapChange = not DoesCurrentMapMatchMapForPlayerLocation() or mapTexture ~= lastFollowMapTexture
        if needsMapChange then
            SetMapToPlayerLocation()
            lastFollowMapTexture = GetMapTileTexture()
            followJumpNextPan = true
            TryAutoZoomOutAtEdge()
        end
    end

    if not needsMapChange and (currentTimeSeconds - lastFollowPanSeconds) >= MINIMAP_PAN_INTERVAL_SECONDS then
        lastFollowPanSeconds = currentTimeSeconds
        -- Suppress the heavy full update while we only re-center.
        local savedUpdateMap, savedSetMapToPlayer = ZO_WorldMap_UpdateMap, SetMapToPlayerLocation
        ZO_WorldMap_UpdateMap, SetMapToPlayerLocation = NoOperation, NoOperation
        MoveMapToPlayer()
        ZO_WorldMap_UpdateMap, SetMapToPlayerLocation = savedUpdateMap, savedSetMapToPlayer
        TryAutoZoomOutAtEdge()
    end
end

-- -----------------------------------------------------------------------------
-- Player heading pip (player body facing overlay)
-- -----------------------------------------------------------------------------

-- The only real player-pip art is UI-WorldMapPlayerPip.dds and its tintable
-- white twin. The native pin (camera heading) uses the colored art; this overlay
-- uses the white art so its tint applies cleanly.
local PLAYER_HEADING_PIP_TEXTURE = "EsoUI/Art/MapPins/UI-WorldMapPlayerPip_white.dds"

local function CreatePlayerHeadingPip()
    if playerHeadingPip or not worldMapControl then
        return
    end
    local playerPin = ZO_WorldMap_GetPinManager():GetPlayerPin()
    local playerControl = playerPin and playerPin:GetControl()
    if not playerControl then
        return
    end
    local parent = playerControl:GetParent()
    playerHeadingPip = CreateControl(parent:GetName() .. "LUIEPlayerHeadingPip", parent, CT_TEXTURE)
    playerHeadingPip:SetTexture(PLAYER_HEADING_PIP_TEXTURE)
    playerHeadingPip:SetAnchor(CENTER, playerControl, CENTER, 0, 0)
    playerHeadingPip:SetPixelRoundingEnabled(true)
    playerHeadingPip:SetDrawLayer(DL_OVERLAY)
    playerHeadingPip:SetDrawLevel(playerControl:GetDrawLevel() + 1)
    MiniMap.ApplyPlayerHeadingPipColor()
    MiniMap.ApplyPlayerHeadingPipSize()
end

function MiniMap.ApplyPlayerHeadingPipColor()
    if not playerHeadingPip then
        return
    end
    playerHeadingPip:SetColor(MiniMap.GetPlayerHeadingPipColor())
end

function MiniMap.ApplyPlayerHeadingPipSize()
    if not playerHeadingPip then
        return
    end
    local size = MiniMap.GetPlayerPinDrawSize()
    playerHeadingPip:SetDimensions(size, size)
end

local function UpdatePlayerHeadingPip()
    if not playerHeadingPip then
        return
    end
    if not MiniMap.IsMiniMapVisible() then
        playerHeadingPip:SetHidden(true)
        return
    end
    -- GetMapPlayerPosition returns the player's body heading as its third value;
    -- the native pin separately rotates to the camera heading.
    local _, _, heading, isShownInCurrentMap, isSymbolicLocation = GetMapPlayerPosition("player")
    if not isShownInCurrentMap or isSymbolicLocation then
        playerHeadingPip:SetHidden(true)
        return
    end
    playerHeadingPip:SetHidden(false)
    playerHeadingPip:SetTextureRotation(heading, 0.5, 0.5)
end

-- -----------------------------------------------------------------------------
-- Native pin styling
-- -----------------------------------------------------------------------------

-- Unit pins (player/group/companion) keep a larger floor so they stay readable.
local unitPinTypeLookup = nil
local function GetUnitPinTypeLookup()
    if not unitPinTypeLookup then
        unitPinTypeLookup = {}
        for pinType in pairs(ZO_MapPin.UNIT_PIN_TYPES) do
            unitPinTypeLookup[pinType] = true
        end
    end
    return unitPinTypeLookup
end

--- @param pinType integer
--- @return number
local function GetMiniMapPinScale(pinType)
    local userScale = MiniMap.GetPinTypeScaleMultiplier(pinType)
    if pinType == MAP_PIN_TYPE_PLAYER then
        userScale = (MiniMap.SV.playerPinScale or 1) * (MiniMap.SV.defaultPinScale or 1)
    end
    -- Compensate for the zoomed-in HUD map so pins do not balloon.
    local zoomCompensation = zo_clamp(MiniMap.zoom * 0.75, 0.6, 1.0)
    if GetUnitPinTypeLookup()[pinType] then
        zoomCompensation = zo_max(zoomCompensation, 0.8)
    end
    return userScale * zoomCompensation
end

--- Replacement for ZO_MapPin:UpdateSize that scales pins only on the HUD map.
local function MiniMapUpdateSize(pin)
    if not MiniMap.IsMiniMapModeActive() or (pin.radius and pin.radius > 0) then
        return originalUpdateSizeHandler(pin)
    end
    local pinType = pin:GetPinType()
    local pinTypeData = ZO_MapPin.PIN_DATA[pinType]
    if not pinTypeData then
        return originalUpdateSizeHandler(pin)
    end
    local originalSize, originalMinSize = pinTypeData.size or 20, pinTypeData.minSize
    local pinScale = GetMiniMapPinScale(pinType)
    pinTypeData.size = originalSize * pinScale
    pinTypeData.minSize = originalMinSize and (originalMinSize * pinScale) or nil
    originalUpdateSizeHandler(pin)
    pinTypeData.size, pinTypeData.minSize = originalSize, originalMinSize
end

function MiniMap.ApplyPlayerPinTint()
    local playerPin = ZO_WorldMap_GetPinManager():GetPlayerPin()
    if not playerPin then
        return
    end
    -- The pin container has no color; the tintable texture is its "Background"
    -- child. Swap to the white pip art so the tint applies cleanly (the default
    -- colored art muddies custom colors).
    local background = playerPin:GetControl():GetNamedChild("Background")
    background:SetTexture(PLAYER_HEADING_PIP_TEXTURE)
    background:SetColor(MiniMap.GetPlayerPipColor())
end

-- -----------------------------------------------------------------------------
-- Waypoint placement (shift / plain click per setting)
-- -----------------------------------------------------------------------------

local function ToggleWaypointAtMouse()
    local normalizedX, normalizedY = NormalizeMousePositionToControl(ZO_WorldMapContainer)
    local waypointX, waypointY = GetMapPlayerWaypoint()
    if waypointX ~= 0 and waypointY ~= 0 then
        local deltaX, deltaY = normalizedX - waypointX, normalizedY - waypointY
        local distance = math.sqrt(deltaX * deltaX + deltaY * deltaY) * GetPanAndZoom():GetCurrentNormalizedZoom()
        if distance <= 0.023 then
            ZO_WorldMap_RemovePlayerWaypoint()
            return
        end
    end
    PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, normalizedX, normalizedY, ZO_WorldMap)
end

local function MiniMapMouseDown(button, ctrl, alt, shift)
    if MiniMap.IsMiniMapModeActive() and button == MOUSE_BUTTON_INDEX_LEFT and not alt then
        local requiresShift = MiniMap.SV.waypointClickRequiresShift == true
        local modifierMatches = (requiresShift and shift) or (not requiresShift and not shift and not ctrl)
        if modifierMatches and MouseIsOver(ZO_WorldMapContainer) then
            ToggleWaypointAtMouse()
            return
        end
    end
    return originalMouseDown(button, ctrl, alt, shift)
end

-- -----------------------------------------------------------------------------
-- Title / zone name
-- -----------------------------------------------------------------------------

--- @param zoneName string|nil
--- @param subZoneName string|nil
--- @return string
local function ComposeMapTitle(zoneName, subZoneName)
    if subZoneName and #subZoneName > 0 then
        zoneName = subZoneName
    end
    if not zoneName or #zoneName == 0 then
        zoneName = GetMapName()
        if not zoneName or #zoneName == 0 then
            zoneName = GetZoneNameByIndex(GetUnitZoneIndex("player"))
        end
    end
    return ZO_CachedStrFormat(SI_WINDOW_TITLE_WORLD_MAP, zoneName)
end

local function ComposeCurrentLocationTitle()
    return ComposeMapTitle(GetPlayerLocationName(), GetPlayerActiveSubzoneName())
end

local function MiniMapGetMapTitle()
    if MiniMap.IsMiniMapModeActive() and DoesCurrentMapMatchMapForPlayerLocation() then
        return ComposeCurrentLocationTitle()
    end
    return originalGetMapTitle()
end

--- @return string
local function GetMiniMapZoneDisplayName()
    local subZoneName = GetPlayerActiveSubzoneName()
    if subZoneName and #subZoneName > 0 then
        return subZoneName
    end
    local locationName = GetPlayerLocationName()
    if locationName and #locationName > 0 then
        return locationName
    end
    local mapName = GetMapName()
    if mapName and #mapName > 0 then
        return mapName
    end
    return GetZoneNameByIndex(GetUnitZoneIndex("player")) or ""
end

--- Update the LUIE chrome zone label from the current location.
function MiniMap.RefreshZoneLabel()
    MiniMap.SetZoneText(GetMiniMapZoneDisplayName())
end

local function OnZoneChanged(_, zoneName, subZoneName)
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    MiniMap.RefreshZoneLabel()
end

-- Settings facades: the zone label font + visibility live on the LUIE chrome
-- (MiniMap.ApplyChromeZoneSettings in _Chrome.lua).
function MiniMap.ApplyZoneNameFont()
    MiniMap.ApplyChromeZoneSettings()
end

function MiniMap.ApplyZoneNameVisibility()
    MiniMap.ApplyChromeZoneSettings()
end

-- -----------------------------------------------------------------------------
-- Compass override
-- -----------------------------------------------------------------------------

local function SetCompassControlsHidden(hidden)
    for index = 1, #COMPASS_CONTROLS do
        COMPASS_CONTROLS[index]:SetHidden(hidden)
    end
end

function MiniMap.ApplyCompassMode()
    local mode = MiniMap.SV.compassOverride or MINIMAP_COMPASS_OVERRIDE_DEFAULT
    -- Restore the compass when the override is off or the minimap is not driving the HUD.
    if mode == MINIMAP_COMPASS_OVERRIDE_DEFAULT or not MiniMap.IsMiniMapVisible() then
        if MiniMap.compassOverrideActive then
            SetCompassControlsHidden(false)
            MiniMap.compassOverrideActive = false
        end
        return
    end
    MiniMap.compassOverrideActive = true
    SetCompassControlsHidden(mode ~= MINIMAP_COMPASS_OVERRIDE_SHOW)
end

-- -----------------------------------------------------------------------------
-- Chrome
-- -----------------------------------------------------------------------------

--- ZOS small-map layout reserves title + button bands (MAP_CONTAINER_LAYOUT
--- paddingY in worldmap.lua). SetToMode turns TitleBarBG/ButtonsBG back on;
--- hide them so only the LUIE overlay chrome shows (no solid black strips).
function MiniMap.ApplySuppressedNativeWorldMapChrome()
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    ZO_WorldMapTitle:SetHidden(true)
    ZO_WorldMapTitleBar:SetHidden(true)
    ZO_WorldMapZoom:SetHidden(true)
    if ZO_WorldMapTitleBarBG then
        ZO_WorldMapTitleBarBG:SetHidden(true)
    end
    if ZO_WorldMapButtonsBG then
        ZO_WorldMapButtonsBG:SetHidden(true)
    end
    if ZO_WorldMapButtons then
        ZO_WorldMapButtons:SetHidden(true)
    end
end

function MiniMap.ApplyDrawLayerPreference()
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    if MiniMap.SV.preferElevatedDrawTier == true then
        worldMapControl:SetDrawLayer(DL_CONTROLS)
        worldMapControl:SetDrawLevel(1000)
    else
        worldMapControl:SetDrawLayer(DL_BACKGROUND)
        worldMapControl:SetDrawLevel(0)
    end
end

-- Settings facade: zoom-button visibility lives on the LUIE chrome.
function MiniMap.ApplyZoomButtonVisibility()
    MiniMap.ApplyChromeZoomButtonSettings()
end

--- Re-anchor the info panel and any chrome stacking under the map.
function MiniMap.ApplyChromeStacking()
    if MiniMap.IsInfoPanelAnchorActive() then
        MiniMap.ApplyInfoPanelAnchor()
    end
end

function MiniMap.ApplyChromeFromSettings()
    MiniMap.ApplyDrawLayerPreference()
    local chrome = MiniMap.chrome
    if chrome then
        chrome.background:SetAlpha(MiniMap.SV.borderOpacity or 1)
    end
    MiniMap.ApplyChromeZoomButtonSettings()
    MiniMap.ApplyChromeZoneSettings()
    MiniMap.ApplyFrameChromeLockState()
    MiniMap.ApplySuppressedNativeWorldMapChrome()
    MiniMap.ApplyChromePlacement()
    MiniMap.ApplyCompassMode()
end

-- -----------------------------------------------------------------------------
-- Live settings entry point
-- -----------------------------------------------------------------------------

function MiniMap.ApplyLiveSettings()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.ApplyFrameLock()
    MiniMap.ApplyChromeFromSettings()
    MiniMap.ApplyPlayerPinTint()
    MiniMap.ApplyPlayerHeadingPipColor()
    MiniMap.ApplyPlayerHeadingPipSize()
    MiniMap.ApplyFrameLayoutFromSavedSettings()
    WORLD_MAP_FRAGMENT:Refresh()
end

-- -----------------------------------------------------------------------------
-- Info panel anchoring
-- -----------------------------------------------------------------------------

--- @return boolean
function MiniMap.IsInfoPanelAnchorActive()
    if not MiniMap.Enabled or MiniMap.SV.anchorInfoPanelToMiniMap ~= true then
        return false
    end
    local infoPanel = LUIE.InfoPanel
    return infoPanel ~= nil and infoPanel.Enabled == true and LUIE_InfoPanel ~= nil
end

function MiniMap.CaptureInfoPanelAnchorSnapshot()
    local infoPanel = LUIE.InfoPanel
    if not infoPanel or infoPanel.Enabled ~= true or LUIE_InfoPanel == nil then
        return
    end
    local isValidAnchor, point, _, relativePoint, offsetX, offsetY = LUIE_InfoPanel:GetAnchor(0)
    if not isValidAnchor then
        return
    end
    MiniMap.SV.infoPanelRestoreAnchor =
    {
        point = point,
        relativePoint = relativePoint,
        offsetX = offsetX,
        offsetY = offsetY,
    }
end

function MiniMap.RestoreInfoPanelAnchor()
    local infoPanel = LUIE.InfoPanel
    if not infoPanel or infoPanel.Enabled ~= true or LUIE_InfoPanel == nil then
        return
    end
    local snapshot = MiniMap.SV and MiniMap.SV.infoPanelRestoreAnchor
    if snapshot and snapshot.point ~= nil and snapshot.relativePoint ~= nil then
        LUIE_InfoPanel:ClearAnchors()
        LUIE_InfoPanel:SetAnchor(snapshot.point, GuiRoot, snapshot.relativePoint, snapshot.offsetX or 0, snapshot.offsetY or 0)
        MiniMap.SV.infoPanelRestoreAnchor = nil
        return
    end
    if infoPanel.ApplyPanelPosition then
        infoPanel.ApplyPanelPosition()
        if infoPanel.SV and infoPanel.SV.position ~= nil and #infoPanel.SV.position == 2 then
            return
        end
    end
    LUIE_InfoPanel:ClearAnchors()
    LUIE_InfoPanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, INFO_PANEL_DEFAULT_OFFSET_X, INFO_PANEL_DEFAULT_OFFSET_Y)
end

function MiniMap.ApplyInfoPanelAnchor()
    if not MiniMap.IsInfoPanelAnchorActive() then
        return
    end
    local host = (MiniMap.chrome and MiniMap.chrome.background) or worldMapControl
    if not host then
        return
    end
    LUIE_InfoPanel:ClearAnchors()
    LUIE_InfoPanel:SetAnchor(TOP, host, BOTTOM, 0, MiniMap.ZONE_LABEL_CHROME_OFFSET)
end

-- -----------------------------------------------------------------------------
-- Visibility
-- -----------------------------------------------------------------------------

--- @return boolean
function MiniMap.IsPlayerInHouse()
    return GetCurrentZoneHouseId() ~= 0
end

--- @return boolean
function MiniMap.GetContextAllowsMiniMap()
    if not MiniMap.Enabled or MiniMap.sessionMapVisible == false then
        return false
    end
    if MiniMap.SV.allowOnGameplayHud == false then
        return false
    end
    if IsUnitInCombat("player") and MiniMap.SV.allowDuringCombat ~= true then
        return false
    end
    if IsMounted() and MiniMap.SV.allowWhileMounted ~= true then
        return false
    end
    if MiniMap.IsPlayerInHouse() and MiniMap.SV.allowInPlayerHousing ~= true then
        return false
    end
    return true
end

--- Conditional used by WORLD_MAP_FRAGMENT to decide HUD visibility.
--- @return boolean
function MiniMap.RefreshVisibility()
    -- Full map scene or non-minimap mode: let ZOS own the fragment.
    if not MiniMap.IsMiniMapModeActive() then
        return true
    end
    if not MiniMap.Enabled or MiniMap.sessionMapVisible == false then
        return false
    end
    if MiniMap.consoleLayoutPreviewActive then
        return true
    end
    local settings = MiniMap.SV
    if settings.allowOnGameplayHud == false then
        return false
    end
    if not DEATH_RECAP_FRAGMENT:IsHidden() then
        return settings.allowOnDeathRecap == true
    end
    if IsMounted() then
        return settings.allowWhileMounted == true
    end
    if SIEGE_BAR_SCENE:IsShowing() then
        return settings.allowOnGameplayHud == true
    end
    if MiniMap.IsPlayerInHouse() then
        return settings.allowInPlayerHousing == true
    end
    if LOOT_SCENE:IsShowing() then
        return settings.allowOnLootScene == true
    end
    if IsUnitInCombat("player") then
        return settings.allowDuringCombat == true
    end
    return settings.allowOnGameplayHud == true
end

function MiniMap.UpdateVisibility()
    if not MiniMap.Enabled then
        return
    end
    WORLD_MAP_FRAGMENT:Refresh()
    if WORLD_MAP_FRAGMENT:IsShowing() then
        MiniMap.StartFollowPlayer()
    end
    MiniMap.ApplyCompassMode()
end

function MiniMap.ToggleShowMap()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.sessionMapVisible = not MiniMap.sessionMapVisible
    MiniMap.UpdateVisibility()
    local message = MiniMap.sessionMapVisible and GetString(LUIE_STRING_MINIMAP_TOGGLE_SHOW_ON) or GetString(LUIE_STRING_MINIMAP_TOGGLE_SHOW_OFF)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
    messageParams:SetText(message)
    messageParams:SetSound(SOUNDS.NONE)
    messageParams:SetLifespanMS(5000)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function MiniMap.ToggleShowInCombatSetting()
    MiniMap.SV.allowDuringCombat = not MiniMap.SV.allowDuringCombat
    MiniMap.UpdateVisibility()
end

-- -----------------------------------------------------------------------------
-- Console layout preview (LibHarvens settings scene)
-- -----------------------------------------------------------------------------

--- @param active boolean
function MiniMap.SetConsoleLayoutPreviewActive(active)
    local wantActive = active == true
    if MiniMap.consoleLayoutPreviewActive == wantActive then
        return
    end
    MiniMap.consoleLayoutPreviewActive = wantActive

    local settingsScene = SCENE_MANAGER:GetScene(LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME)
    if wantActive then
        MiniMap.sessionMapVisible = true
        if settingsScene and not settingsScene:HasFragment(WORLD_MAP_FRAGMENT) then
            settingsScene:AddFragment(WORLD_MAP_FRAGMENT)
        end
    elseif settingsScene and settingsScene:HasFragment(WORLD_MAP_FRAGMENT) then
        settingsScene:RemoveFragment(WORLD_MAP_FRAGMENT)
    end
    MiniMap.UpdateVisibility()
end

function MiniMap.ToggleConsoleLayoutPreview()
    if not MiniMap.Enabled or not ZO_IsConsoleOrGameCoreUI() then
        return
    end
    if MiniMap.consoleLayoutPreviewActive then
        MiniMap.SetConsoleLayoutPreviewActive(false)
    else
        MiniMap.SetConsoleLayoutPreviewActive(true)
        MiniMap.ApplyFrameLayoutFromSavedSettings()
    end
end

-- -----------------------------------------------------------------------------
-- Mode flip (enter minimap mode / leave to full map)
-- -----------------------------------------------------------------------------

--- Drive ZO_WorldMap into the minimap mode and re-apply our layout/zoom/chrome.
--- @param skipWorldMapUpdate boolean|nil
function MiniMap.EnterMiniMapMode(skipWorldMapUpdate)
    if not MiniMap.Enabled then
        return
    end
    if MiniMap.IsMiniMapModeActive() then
        MiniMap.ApplySuppressedNativeWorldMapChrome()
        MiniMap.RefreshZoneLabel()
        return
    end
    if WORLD_MAP_MANAGER.inSpecialMode then
        return
    end

    local savedUpdateMap = ZO_WorldMap_UpdateMap
    ZO_WorldMap_UpdateMap = skipWorldMapUpdate and NoOperation or savedUpdateMap
    ZO_MapPin.UpdateSize = MiniMapUpdateSize
    WORLD_MAP_MANAGER:SetToMode(LUIE_MINIMAP_MODE)
    ZO_WorldMap_ClearCustomZoomLevels()
    ZO_WorldMap_UpdateMap = savedUpdateMap

    MiniMap.ApplySuppressedNativeWorldMapChrome()
    MiniMap.SetChromeHidden(false)
    worldMapControl:StopMovingOrResizing()
    MiniMap.StartFollowPlayer()
    MiniMap.RestoreMapPosition()
    MiniMap.ApplyFrameLock()
    MiniMap.ApplyContextDefaultZoom()
    MiniMap.ApplyChromeFromSettings()
    MiniMap.ApplyPlayerPinTint()
    MiniMap.RefreshZoneLabel()
    WORLD_MAP_MANAGER:UpdateFloorAndLevelNavigation()
end

--- Hand ZO_WorldMap back to the full custom map (player opened the world map).
function MiniMap.ExitToWorldMapMode()
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    ZO_MapPin.UpdateSize = originalUpdateSizeHandler

    local savedUpdateMap, savedSetMapToPlayer = ZO_WorldMap_UpdateMap, SetMapToPlayerLocation
    ZO_WorldMap_UpdateMap, SetMapToPlayerLocation = NoOperation, NoOperation
    ZO_WorldMap_ClearCustomZoomLevels()
    WORLD_MAP_MANAGER:SetToMode(MAP_MODE_LARGE_CUSTOM)
    local panAndZoom = GetPanAndZoom()
    if panAndZoom then
        panAndZoom:SetCurrentNormalizedZoom(0)
    end
    CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged", true)
    ZO_WorldMap_UpdateMap, SetMapToPlayerLocation = savedUpdateMap, savedSetMapToPlayer

    MiniMap.SetChromeHidden(true)
    -- Restore the native zoom control for the full world map (ZOS re-applies the
    -- title bar layout via SetToMode above).
    ZO_WorldMapZoom:SetHidden(false)
    worldMapControl:SetMouseEnabled(true)
    WORLD_MAP_MANAGER:UpdateFloorAndLevelNavigation()
end

-- -----------------------------------------------------------------------------
-- ZOS hooks
-- -----------------------------------------------------------------------------

local function InstallHooks()
    if MiniMap.hooksInstalled then
        return
    end
    MiniMap.hooksInstalled = true

    originalGetMapDimensions = ZO_WorldMap_GetMapDimensions
    function ZO_WorldMap_GetMapDimensions()
        if MiniMap.IsMiniMapModeActive() then
            return ZO_WorldMapContainer:GetDimensions()
        end
        return originalGetMapDimensions()
    end

    originalUpdateSizeHandler = ZO_MapPin.UpdateSize

    originalGetMapTitle = ZO_WorldMap_GetMapTitle
    ZO_WorldMap_GetMapTitle = MiniMapGetMapTitle

    originalMouseDown = ZO_WorldMap_MouseDown
    ZO_WorldMap_MouseDown = MiniMapMouseDown

    originalResizeStop = ZO_WorldMap_OnResizeStop
    function ZO_WorldMap_OnResizeStop(...)
        originalResizeStop(...)
        if MiniMap.IsMiniMapModeActive() then
            MiniMap.SaveMapPosition()
        end
    end

    originalShowWorldMap = ZO_WorldMap_ShowWorldMap
    function ZO_WorldMap_ShowWorldMap(...)
        if MiniMap.IsMiniMapModeActive() then
            MiniMap.ExitToWorldMapMode()
        end
        return originalShowWorldMap(...)
    end

    originalRefreshMapFrameAnchor = ZO_WorldMapManager.RefreshMapFrameAnchor
    function ZO_WorldMapManager.RefreshMapFrameAnchor(manager, ...)
        if MiniMap.Enabled and manager:IsInMode(LUIE_MINIMAP_MODE) then
            MiniMap.RestoreMapPosition()
            return
        end
        return originalRefreshMapFrameAnchor(manager, ...)
    end

    originalTryShowSpectacleHeader = ZO_WorldMapManager.TryShowSpectacleMapHeader
    function ZO_WorldMapManager.TryShowSpectacleMapHeader(manager, ...)
        if manager:GetMode() == LUIE_MINIMAP_MODE then
            manager:ClearMapHeader()
            return
        end
        return originalTryShowSpectacleHeader(manager, ...)
    end

    -- Travel pushes a special mode; hand the map over and re-enter afterwards.
    originalPushSpecialMode = ZO_WorldMapManager.PushSpecialMode
    function ZO_WorldMapManager.PushSpecialMode(manager, mode, ...)
        if not manager.inSpecialMode and MiniMap.IsMiniMapModeActive() then
            local savedUpdateMap = ZO_WorldMap_UpdateMap
            ZO_WorldMap_UpdateMap = NoOperation
            MiniMap.ExitToWorldMapMode()
            ZO_WorldMap_UpdateMap = savedUpdateMap
        end
        return originalPushSpecialMode(manager, mode, ...)
    end

    -- Player opens the full map -> leave minimap; map closes -> re-enter.
    local function OnWorldMapSceneStateChange(_, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            MiniMap.ExitToWorldMapMode()
        elseif newState == SCENE_FRAGMENT_HIDING then
            MiniMap.EnterMiniMapMode(WORLD_MAP_MANAGER:GetMode() <= MAP_MODE_LARGE_CUSTOM)
        end
    end
    WORLD_MAP_SCENE:RegisterCallback("StateChange", OnWorldMapSceneStateChange)
    GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", OnWorldMapSceneStateChange)

    -- Re-assert minimap mode after special-mode (travel) flows end. PopSpecialMode
    -- restores the user mode (small/large custom), not mode 42, so when the full
    -- map scene is not open we step back into the minimap mode on the next frame.
    CALLBACK_MANAGER:RegisterCallback("OnWorldMapModeChanged", function ()
        if not MiniMap.Enabled or WORLD_MAP_MANAGER.inSpecialMode then
            return
        end
        if MiniMap.IsMiniMapModeActive() or ZO_WorldMap_IsWorldMapShowing() then
            return
        end
        zo_callLater(function ()
            if  MiniMap.Enabled
            and not WORLD_MAP_MANAGER.inSpecialMode
            and not ZO_WorldMap_IsWorldMapShowing()
            and not MiniMap.IsMiniMapModeActive() then
                MiniMap.EnterMiniMapMode(true)
                MiniMap.UpdateVisibility()
            end
        end, 0)
    end)

    -- Follow tick + player heading pip ride on the live map OnUpdate handler.
    originalWorldMapOnUpdate = worldMapControl:GetHandler("OnUpdate")
    worldMapControl:SetHandler("OnUpdate", function (control, currentTimeSeconds)
        UpdatePlayerHeadingPip()
        UpdateFollowTick(currentTimeSeconds)
        if originalWorldMapOnUpdate then
            originalWorldMapOnUpdate(control, currentTimeSeconds)
        end
    end)

    WORLD_MAP_FRAGMENT:SetConditional(MiniMap.RefreshVisibility)
    WORLD_MAP_FRAGMENT:RegisterCallback("StateChange", function (_, newState)
        if newState == SCENE_FRAGMENT_SHOWING then
            MiniMap.StartFollowPlayer()
        end
    end)

    EVENT_MANAGER:RegisterForEvent(MiniMap.moduleName, EVENT_ZONE_CHANGED, OnZoneChanged)
end

-- -----------------------------------------------------------------------------
-- HUD scene registration
-- -----------------------------------------------------------------------------

local HUD_FRAGMENT_SCENES = nil
local function GetHudFragmentScenes()
    if not HUD_FRAGMENT_SCENES then
        HUD_FRAGMENT_SCENES = { HUD_SCENE, HUD_UI_SCENE, LOOT_SCENE, SIEGE_BAR_SCENE }
    end
    return HUD_FRAGMENT_SCENES
end

local function AddMiniMapToHudScenes()
    for _, scene in ipairs(GetHudFragmentScenes()) do
        if not scene:HasFragment(WORLD_MAP_FRAGMENT) then
            scene:AddFragment(WORLD_MAP_FRAGMENT)
        end
    end
end

local function RemoveMiniMapFromHudScenes()
    for _, scene in ipairs(GetHudFragmentScenes()) do
        if scene:HasFragment(WORLD_MAP_FRAGMENT) then
            scene:RemoveFragment(WORLD_MAP_FRAGMENT)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Visibility events
-- -----------------------------------------------------------------------------

local function RegisterVisibilityEvents()
    EVENT_MANAGER:RegisterForEvent(MiniMap.moduleName .. "_Combat", EVENT_PLAYER_COMBAT_STATE, MiniMap.UpdateVisibility)
    EVENT_MANAGER:RegisterForEvent(MiniMap.moduleName .. "_Mount", EVENT_MOUNTED_STATE_CHANGED, MiniMap.UpdateVisibility)
    EVENT_MANAGER:RegisterForEvent(MiniMap.moduleName .. "_House", EVENT_HOUSING_PLAYER_INFO_CHANGED, MiniMap.UpdateVisibility)
    EVENT_MANAGER:RegisterForEvent(MiniMap.moduleName .. "_Dead", EVENT_PLAYER_DEAD, MiniMap.UpdateVisibility)
    EVENT_MANAGER:RegisterForEvent(MiniMap.moduleName .. "_Alive", EVENT_PLAYER_ALIVE, MiniMap.UpdateVisibility)

    if not MiniMap.deathRecapHookRegistered then
        MiniMap.deathRecapHookRegistered = true
        DEATH_RECAP_FRAGMENT:RegisterCallback("StateChange", MiniMap.UpdateVisibility)
    end
end

local function UnregisterVisibilityEvents()
    EVENT_MANAGER:UnregisterForEvent(MiniMap.moduleName .. "_Combat", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(MiniMap.moduleName .. "_Mount", EVENT_MOUNTED_STATE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(MiniMap.moduleName .. "_House", EVENT_HOUSING_PLAYER_INFO_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(MiniMap.moduleName .. "_Dead", EVENT_PLAYER_DEAD)
    EVENT_MANAGER:UnregisterForEvent(MiniMap.moduleName .. "_Alive", EVENT_PLAYER_ALIVE)
end

-- -----------------------------------------------------------------------------
-- Initialize / teardown
-- -----------------------------------------------------------------------------

local function OnPlayerActivated()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.EnterMiniMapMode(true)
    MiniMap.UpdateVisibility()
end

local function OnPlayerDeactivated()
    if not MiniMap.Enabled then
        return
    end
    if WORLD_MAP_MANAGER.inSpecialMode then
        WORLD_MAP_MANAGER:PopSpecialMode()
    end
end

--- @param enabled boolean
function MiniMap.Initialize(enabled)
    if LUIE.IsCharacterSpecificSavedVarsEnabled() then
        MiniMap.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.MiniMap, LUIE.SVVer, nil, MiniMap.Defaults, LUIE.SavedVarsProfile)
    else
        MiniMap.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.MiniMap, LUIE.SVVer, nil, MiniMap.Defaults, LUIE.SavedVarsProfile)
    end

    if not enabled then
        if MiniMap.Enabled then
            RemoveMiniMapFromHudScenes()
            UnregisterVisibilityEvents()
            EVENT_MANAGER:UnregisterForEvent(MiniMap.moduleName, EVENT_PLAYER_ACTIVATED)
            EVENT_MANAGER:UnregisterForEvent(MiniMap.moduleName, EVENT_PLAYER_DEACTIVATED)
            if MiniMap.IsMiniMapModeActive() then
                MiniMap.ExitToWorldMapMode()
            end
            MiniMap.SetChromeHidden(true)
        end
        MiniMap.Enabled = false
        return
    end

    worldMapControl = ZO_WorldMap
    worldMapScrollControl = ZO_WorldMapScroll

    MiniMap.Enabled = true
    MiniMap.sessionMapVisible = true
    MiniMap.ClampSavedDefaultZoom()
    MiniMap.zoom = MiniMap.SV.resetZoomLevel
    MiniMap.mapFollowsPlayer = MiniMap.SV.followPlayer == true and MiniMap.SV.zoneScrollLockEnabled ~= true

    MiniMap.CreateChrome()
    CreatePlayerHeadingPip()
    InstallHooks()

    AddMiniMapToHudScenes()
    RegisterVisibilityEvents()
    EVENT_MANAGER:RegisterForEvent(MiniMap.moduleName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent(MiniMap.moduleName, EVENT_PLAYER_DEACTIVATED, OnPlayerDeactivated)

    MiniMap.ApplyLiveSettings()

    -- On /reloadui the player is already in-world, so EVENT_PLAYER_ACTIVATED
    -- fires shortly after this and drives EnterMiniMapMode + UpdateVisibility.
end

-- File-scope: capture the world-map saved vars the instant ZOS publishes them.
-- This callback fires from ZO_Ingame's load (before our EVENT_ADD_ON_LOADED), so
-- it must be registered at file execution time, not inside Initialize.
CALLBACK_MANAGER:RegisterCallback("OnWorldMapSavedVarsReady", function (savedVars)
    MiniMap.OnWorldMapSavedVarsReady(savedVars)
end)
