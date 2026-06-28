-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Reparents ZO_WorldMapContainer under the HUD minimap while the full world map is closed.
-- Uses ZO_WorldMap_GetPinManager() and WORLD_MAP_TILES_MANAGER on the real container (EsoUI/Ingame/Map/WorldMap.lua).

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local eventManager = GetEventManager()

local pinManager = ZO_WorldMap_GetPinManager()
local panAndZoom = ZO_WorldMap_GetPanAndZoom()

local nativeWorldMapContainerAttached = false
local nativeWorldMapContainerHiddenForReload = false

--- @class MiniMapNativeWorldMapContainerRestore
--- @field parent Control
--- @field mapConstantsWidth number
--- @field mapConstantsHeight number
--- @field containerMouseEnabled boolean
--- @field playerWorldPinControl Control|nil
--- @field playerWorldPinWasHidden boolean|nil

local nativeWorldMapContainerRestore --- @type MiniMapNativeWorldMapContainerRestore|nil
local nativeHudMapOverlayLayoutReapplyScheduled = false
local nativeHudMapOverlayLayoutReapplySecondFrameScheduled = false
local NATIVE_HUD_MAP_OVERLAY_LAYOUT_REAPPLY_UPDATE_NAME = nil

local function GetNativeHudMapOverlayLayoutReapplyUpdateName()
    if not NATIVE_HUD_MAP_OVERLAY_LAYOUT_REAPPLY_UPDATE_NAME then
        NATIVE_HUD_MAP_OVERLAY_LAYOUT_REAPPLY_UPDATE_NAME = MiniMap.moduleName .. "NativeHudMapOverlayLayoutReapply"
    end
    return NATIVE_HUD_MAP_OVERLAY_LAYOUT_REAPPLY_UPDATE_NAME
end

--- Hides reparented ZO_WorldMapContainer while ReloadWorldMap runs so ZO_WorldMap_UpdateMap cannot flash full-zone dimensions.
--- @param hidden boolean
function MiniMap.SetAttachedNativeWorldMapContainerHiddenForReload(hidden)
    nativeWorldMapContainerHiddenForReload = hidden == true
    if not nativeWorldMapContainerAttached then
        return
    end
    ZO_WorldMapContainer:SetHidden(nativeWorldMapContainerHiddenForReload)
end

--- @return boolean
function MiniMap.IsAttachedNativeWorldMapContainerHiddenForReload()
    return nativeWorldMapContainerHiddenForReload
end

--- After ZO_WorldMap_UpdateMap while the container is under the HUD minimap, re-apply minimap MAP_WIDTH/HEIGHT or stay hidden during reload.
function MiniMap.ApplyNativeHudLayoutAfterWorldMapUpdateMap()
    if not nativeWorldMapContainerAttached then
        return
    end
    if nativeWorldMapContainerHiddenForReload then
        ZO_WorldMapContainer:SetHidden(true)
        return
    end
    local mapController = MiniMap.mapController
    if mapController and mapController:IsReady() then
        ZO_WorldMapContainer:SetHidden(false)
        MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    else
        ZO_WorldMapContainer:SetHidden(true)
    end
end

function MiniMap.CancelNativeHudMapOverlayLayoutReapply()
    nativeHudMapOverlayLayoutReapplyScheduled = false
    nativeHudMapOverlayLayoutReapplySecondFrameScheduled = false
    eventManager:UnregisterForUpdate(GetNativeHudMapOverlayLayoutReapplyUpdateName())
    eventManager:UnregisterForUpdate(MiniMap.moduleName .. "NativeHudMapOverlayLayoutReapply2")
end

--- Runs ZOS g_mapRefresh:UpdateRefreshGroups via the world map OnUpdate handler (keep / link / location dirty groups).
function MiniMap.FlushWorldMapPinRefreshGroups()
    local worldMapControl = WORLD_MAP_MANAGER.control
    local onUpdate = worldMapControl:GetHandler("OnUpdate")
    if onUpdate then
        onUpdate(worldMapControl, GetFrameTimeSeconds())
    end
end

--- Stops ZO_MapPanAndZoom from re-anchoring ZO_WorldMapContainer to CENTER while it is parented under the HUD minimap.
function MiniMap.ResetNativeHudWorldMapPanState()
    panAndZoom:ClearLockPoint()
    panAndZoom:ClearTargetOffset()
    panAndZoom:ClearTargetNormalizedZoom()
    panAndZoom:SetCurrentOffset(0, 0)
end

--- Restores HUD minimap MAP constants and ZOS pins/links after ZO_WorldMap_UpdateMap / SetMapWindowSize.
function MiniMap.ReapplyNativeHudMapOverlayLayout()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    local mapController = MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    MiniMap.ResetNativeHudWorldMapPanState()
    MiniMap.FlushWorldMapPinRefreshGroups()
    MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    MiniMap.ResetNativeHudWorldMapPanState()
    MiniMap.RefreshWorldMapSuggestionPinsForMirror()
    MiniMap.RefreshWorldMapPingsForMirror()
end

function MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if nativeHudMapOverlayLayoutReapplyScheduled then
        return
    end
    nativeHudMapOverlayLayoutReapplyScheduled = true
    local updateName = GetNativeHudMapOverlayLayoutReapplyUpdateName()
    eventManager:RegisterForUpdate(updateName, 0, function ()
                                       nativeHudMapOverlayLayoutReapplyScheduled = false
                                       MiniMap.ReapplyNativeHudMapOverlayLayout()
                                       MiniMap.ScheduleNativeHudMapOverlayLayoutReapplySecondFrame()
                                   end, true)
end

--- Second frame after ZOS g_mapRefresh:UpdateRefreshGroups (world map OnUpdate).
function MiniMap.ScheduleNativeHudMapOverlayLayoutReapplySecondFrame()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if nativeHudMapOverlayLayoutReapplySecondFrameScheduled then
        return
    end
    nativeHudMapOverlayLayoutReapplySecondFrameScheduled = true
    local secondFrameUpdateName = MiniMap.moduleName .. "NativeHudMapOverlayLayoutReapply2"
    eventManager:RegisterForUpdate(secondFrameUpdateName, 0, function ()
                                       nativeHudMapOverlayLayoutReapplySecondFrameScheduled = false
                                       MiniMap.ReapplyNativeHudMapOverlayLayout()
                                   end, true)
end

--- @return boolean
function MiniMap.IsNativeWorldMapContainerAttached()
    return nativeWorldMapContainerAttached == true
end

--- @return boolean
function MiniMap.HasNativeMovingPinTargets()
    if GetGroupSize() > 1 then
        return true
    end
    return DoesUnitExist("companion")
end

--- Native HUD player pin + group/companion moving pins. Called from OnFollowTick after its guards.
--- @param followPlayer boolean|nil
function MiniMap.TickHudMovingAndPlayerPins(followPlayer)
    if followPlayer == nil then
        followPlayer = MiniMap.GetMapFollowsPlayer()
    end
    if not nativeWorldMapContainerAttached then
        return
    end
    local hasGroupOrCompanionPins = MiniMap.HasNativeMovingPinTargets()
    if followPlayer then
        if hasGroupOrCompanionPins then
            pinManager:UpdateMovingPins()
        else
            MiniMap.UpdateNativeHudPlayerMapPin()
        end
    else
        pinManager:UpdateMovingPins()
    end
    MiniMap.ApplyNativeHudPlayerPinScale()
    MiniMap.ApplyNativeWorldMapPlayerPinColors()
end

--- ZOS UpdateMovingPins player block only (MapPin_Manager.lua) for solo follow pip sync.
function MiniMap.UpdateNativeHudPlayerMapPin()
    local playerMapPin = pinManager:GetPlayerPin()
    local xLoc, yLoc, _, isShownInCurrentMap, isSymbolicLocation = GetMapPlayerPosition("player")
    playerMapPin:SetOriginalPosition(xLoc, yLoc)
    playerMapPin:SetIsSymbolicPosition(isSymbolicLocation)
    playerMapPin:SetLocation(xLoc, yLoc)
    if isShownInCurrentMap then
        playerMapPin:SetHidden(false)
        local rotation = isSymbolicLocation and 0 or GetPlayerCameraHeading()
        playerMapPin:SetRotation(rotation)
    else
        playerMapPin:SetHidden(true)
    end
end

--- Native HUD player pin uses the same pip art as the overlay; size comes from Player Pip scale only.
function MiniMap.ApplyNativeHudPlayerPinScale()
    local playerMapPin = pinManager:GetPlayerPin()
    local drawSize = MiniMap.GetPlayerPinDrawSize()
    playerMapPin:SetScaleModifier(drawSize / MiniMap.PLAYER_PIN_BASE_SIZE)
end

--- Tints the ZOS HUD player map pin (ZO_WorldMapPins_Manager:GetPlayerPin), not a fixed pool index.
function MiniMap.ApplyNativeWorldMapPlayerPinColors()
    local playerMapPin = pinManager:GetPlayerPin()
    local backgroundControl = playerMapPin.backgroundControl
    local red, green, blue, alpha
    if MiniMap.GetMapFollowsPlayer() then
        red, green, blue, alpha = MiniMap.GetCameraWedgeColor()
    else
        red, green, blue, alpha = MiniMap.GetPlayerPipColor()
    end
    backgroundControl:SetColor(red, green, blue, alpha)
end

local function ApplyNativeWorldMapHudDrawOrder(view)
    view.pins:SetDrawLayer(DL_OVERLAY)
    view.pins:SetDrawTier(DT_HIGH)
    view.player:SetDrawTier(DT_HIGH)
    view.playerCam:SetDrawTier(DT_HIGH)
end

function MiniMap.ApplyNativeWorldMapPlayerPinVisibility()
    if not nativeWorldMapContainerAttached or not nativeWorldMapContainerRestore then
        return
    end
    local playerMapPin = pinManager:GetPlayerPin()
    local playerWorldPinControl = playerMapPin:GetControl()
    nativeWorldMapContainerRestore.playerWorldPinControl = playerWorldPinControl
    if nativeWorldMapContainerRestore.playerWorldPinWasHidden == nil then
        nativeWorldMapContainerRestore.playerWorldPinWasHidden = playerWorldPinControl:IsHidden()
    end
    MiniMap.ApplyNativeWorldMapPlayerPinColors()
end

local function RestoreWorldMapPlayerPinVisibility()
    if not nativeWorldMapContainerRestore then
        return
    end
    local playerWorldPinControl = nativeWorldMapContainerRestore.playerWorldPinControl
    if playerWorldPinControl and nativeWorldMapContainerRestore.playerWorldPinWasHidden ~= nil then
        playerWorldPinControl:SetHidden(nativeWorldMapContainerRestore.playerWorldPinWasHidden)
    end
    nativeWorldMapContainerRestore.playerWorldPinControl = nil
    nativeWorldMapContainerRestore.playerWorldPinWasHidden = nil
end

--- @param mapContentWidth number
--- @param mapContentHeight number
function MiniMap.ApplyNativeWorldMapContainerLayout(mapContentWidth, mapContentHeight)
    if mapContentWidth <= 0 or mapContentHeight <= 0 then
        return
    end

    ZO_MAP_CONSTANTS.MAP_WIDTH = mapContentWidth
    ZO_MAP_CONSTANTS.MAP_HEIGHT = mapContentHeight

    ZO_WorldMapContainer:SetDimensions(mapContentWidth, mapContentHeight)
    ZO_WorldMapContainer:ClearAnchors()
    ZO_WorldMapContainer:SetAnchor(TOPLEFT, ZO_WorldMapContainer:GetParent(), TOPLEFT, 0, 0)

    WORLD_MAP_TILES_MANAGER:LayoutTiles()
    -- for tileIndex = 1, WORLD_MAP_TILES_MANAGER.totalTiles do
    --     WORLD_MAP_TILES_MANAGER:GetActiveObject(tileIndex):SetHidden(false)
    -- end

    pinManager:UpdateMovingPins()
    pinManager:UpdatePinsForMapSizeChange()
    WORLD_MAP_MANAGER:UpdateBlobs()

    MiniMap.ApplyNativeWorldMapPlayerPinVisibility()
    MiniMap.ApplyNativeWorldMapPlayerPinColors()
    MiniMap.ApplyNativeHudPlayerPinScale()
    if MiniMap.pinController then
        MiniMap.pinController:ApplyUserScaleToNativeWorldMapPins()
    end

    MiniMap.ResetNativeHudWorldMapPanState()

    if GetMapFilterType() == MAP_FILTER_TYPE_AVA_CYRODIIL then
        ZO_WorldMap_RefreshKeepNetwork()
    end
end

--- @param mapController MiniMapMapController|nil
function MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    mapController = mapController or MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    local mapContentWidth = mapController:GetMapContentWidth()
    local mapContentHeight = mapController:GetMapContentHeight()
    MiniMap.ApplyNativeWorldMapContainerLayout(mapContentWidth, mapContentHeight)
end

function MiniMap.RefreshNativeWorldMapContainer(refreshOptions)
    if not MiniMap.Enabled then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    local mapController = MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    local syncSubzoneMapGeometry = refreshOptions and refreshOptions.syncSubzoneMapGeometry == true
    local applyContextZoomIfChanged = refreshOptions and refreshOptions.applyContextZoomIfChanged == true
    MiniMap.RunWithPlayerMapForMirror(function ()
        local geometryChanged = false
        if syncSubzoneMapGeometry then
            geometryChanged = MiniMap.SyncHudMapDataDimensionsFromPlayerMap(mapController)
        end
        if applyContextZoomIfChanged then
            MiniMap.ApplyHudContextZoomWhenMapContextChanged()
        end
        local mapData = mapController.map
        if mapData and mapData.numTiles > 0 then
            local invokeUpdateTextures = geometryChanged
                or MiniMap.ShouldInvokeNativeWorldMapUpdateTexturesForMapData(mapData)
            MiniMap.BindNativeWorldMapTilesForHud(mapData, invokeUpdateTextures)
        end
        MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
        MiniMap.RefreshWorldMapPinsForMirror()
        if MiniMap.IsNativeWorldMapContainerAttached() then
            MiniMap.FlushWorldMapPinRefreshGroups()
            MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
            MiniMap.ResetNativeHudWorldMapPanState()
        end
    end)
end

function MiniMap.TryAttachNativeWorldMapContainer()
    if not MiniMap.Enabled then
        return
    end
    if nativeWorldMapContainerAttached then
        MiniMap.ReapplyNativeHudMapOverlayLayout()
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    local view = MiniMap.view
    local mapController = MiniMap.mapController
    if not view or not mapController or not mapController:IsReady() then
        return
    end

    nativeWorldMapContainerRestore =
    {
        parent = ZO_WorldMapContainer:GetParent(),
        mapConstantsWidth = ZO_MAP_CONSTANTS.MAP_WIDTH,
        mapConstantsHeight = ZO_MAP_CONSTANTS.MAP_HEIGHT,
        containerMouseEnabled = ZO_WorldMapContainer:IsMouseEnabled(),
    }

    ZO_WorldMapContainer:SetParent(view.map)
    ZO_WorldMapContainer:SetDrawTier(DT_MEDIUM)
    ZO_WorldMapContainer:SetHidden(false)
    -- Keep ZOS WorldMap.xml mouse handlers off the HUD minimap (right-click would MapZoomOut / change map).
    ZO_WorldMapContainer:SetMouseEnabled(false)

    nativeWorldMapContainerAttached = true
    ApplyNativeWorldMapHudDrawOrder(view)
    MiniMap.RefreshNativeWorldMapContainer()
    MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
end

function MiniMap.RestoreWorldMapContainerToWorldMap()
    if not nativeWorldMapContainerAttached then
        return
    end

    MiniMap.CancelNativeHudMapOverlayLayoutReapply()
    RestoreWorldMapPlayerPinVisibility()
    if MiniMap.pinController then
        MiniMap.pinController:ResetNativeWorldMapPinUserScale()
    end

    local restore = nativeWorldMapContainerRestore
    local restoreParent = restore and restore.parent or ZO_WorldMapScroll
    ZO_WorldMapContainer:SetParent(restoreParent)
    ZO_WorldMapContainer:ClearAnchors()
    ZO_WorldMapContainer:SetAnchor(CENTER, restoreParent, CENTER, 0, 0)

    if restore then
        ZO_MAP_CONSTANTS.MAP_WIDTH = restore.mapConstantsWidth
        ZO_MAP_CONSTANTS.MAP_HEIGHT = restore.mapConstantsHeight
        ZO_WorldMapContainer:SetDimensions(restore.mapConstantsWidth, restore.mapConstantsHeight)
        ZO_WorldMapContainer:SetMouseEnabled(restore.containerMouseEnabled)
    else
        ZO_WorldMapContainer:SetMouseEnabled(true)
    end

    WORLD_MAP_TILES_MANAGER:LayoutTiles()
    pinManager:UpdatePinsForMapSizeChange()

    nativeWorldMapContainerAttached = false
    nativeWorldMapContainerRestore = nil

    if MiniMap.pinController then
        MiniMap.pinController:RestoreAllDigSitePolygonsToWorldMap()
    end
end

function MiniMap.OnNativeWorldMapContainerZoomChanged()
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController()
end

function MiniMap.ShutdownNativeWorldMapContainer()
    nativeWorldMapContainerHiddenForReload = false
    MiniMap.RestoreWorldMapContainerToWorldMap()
end
