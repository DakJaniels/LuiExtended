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

local nativeWorldMapContainerAttached = false

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

function MiniMap.CancelNativeHudMapOverlayLayoutReapply()
    nativeHudMapOverlayLayoutReapplyScheduled = false
    nativeHudMapOverlayLayoutReapplySecondFrameScheduled = false
    EVENT_MANAGER:UnregisterForUpdate(GetNativeHudMapOverlayLayoutReapplyUpdateName())
    EVENT_MANAGER:UnregisterForUpdate(MiniMap.moduleName .. "NativeHudMapOverlayLayoutReapply2")
end

--- Runs ZOS g_mapRefresh:UpdateRefreshGroups via the world map OnUpdate handler (keep / link / location dirty groups).
function MiniMap.FlushWorldMapPinRefreshGroups()
    if not WORLD_MAP_MANAGER or not WORLD_MAP_MANAGER.control then
        return
    end
    local worldMapControl = WORLD_MAP_MANAGER.control
    local onUpdate = worldMapControl:GetHandler("OnUpdate")
    if onUpdate then
        onUpdate(worldMapControl, GetFrameTimeSeconds())
    end
end

--- Stops ZO_MapPanAndZoom from re-anchoring ZO_WorldMapContainer to CENTER while it is parented under the HUD minimap.
function MiniMap.ResetNativeHudWorldMapPanState()
    local panAndZoom = ZO_WorldMap_GetPanAndZoom()
    if not panAndZoom then
        return
    end
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
    MiniMap.RefreshWorldMapPinsForMirror()
    MiniMap.FlushWorldMapPinRefreshGroups()
    MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    MiniMap.ResetNativeHudWorldMapPanState()
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
    EVENT_MANAGER:RegisterForUpdate(updateName, 0, function ()
        EVENT_MANAGER:UnregisterForUpdate(updateName)
        nativeHudMapOverlayLayoutReapplyScheduled = false
        MiniMap.ReapplyNativeHudMapOverlayLayout()
        MiniMap.ScheduleNativeHudMapOverlayLayoutReapplySecondFrame()
    end)
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
    EVENT_MANAGER:RegisterForUpdate(secondFrameUpdateName, 0, function ()
        EVENT_MANAGER:UnregisterForUpdate(secondFrameUpdateName)
        nativeHudMapOverlayLayoutReapplySecondFrameScheduled = false
        MiniMap.ReapplyNativeHudMapOverlayLayout()
    end)
end

--- @return boolean
function MiniMap.IsNativeWorldMapContainerAttached()
    return nativeWorldMapContainerAttached == true
end

--- Group / companion / dragon / objective pin positions (ZOS PIN_UPDATE_DELAY path while world map is closed).
function MiniMap.UpdateNativeWorldMapMovingPins()
    if not MiniMap.Enabled then
        return
    end
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    if MiniMap.playerMapMirrorDepth > 0 then
        return
    end
    if MiniMap.IsPinMirrorMachineBusy() then
        return
    end
    local mapController = MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    ZO_WorldMap_GetPinManager():UpdateMovingPins()
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
    local playerMapPin = ZO_WorldMap_GetPinManager():GetPlayerPin()
    local playerWorldPinControl = playerMapPin:GetControl()
    nativeWorldMapContainerRestore.playerWorldPinControl = playerWorldPinControl
    if nativeWorldMapContainerRestore.playerWorldPinWasHidden == nil then
        nativeWorldMapContainerRestore.playerWorldPinWasHidden = playerWorldPinControl:IsHidden()
    end
    if MiniMap.GetMapFollowsPlayer() then
        playerWorldPinControl:SetHidden(true)
    else
        playerWorldPinControl:SetHidden(false)
    end
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
    for tileIndex = 1, WORLD_MAP_TILES_MANAGER.totalTiles do
        WORLD_MAP_TILES_MANAGER:GetActiveObject(tileIndex):SetHidden(false)
    end

    local pinManager = ZO_WorldMap_GetPinManager()
    pinManager:UpdateMovingPins()
    pinManager:UpdatePinsForMapSizeChange()
    WORLD_MAP_MANAGER:UpdateBlobs()

    MiniMap.ApplyNativeWorldMapPlayerPinVisibility()

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

function MiniMap.SetLuiMiniMapTileLayerHidden(hidden)
    local mapController = MiniMap.mapController
    if not mapController or not mapController.tilesManager then
        return
    end
    for _, tileControl in pairs(mapController.tilesManager:GetActiveObjects()) do
        tileControl:SetHidden(hidden == true)
    end
end

function MiniMap.RefreshNativeWorldMapContainer()
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
    MiniMap.RunWithPlayerMapForMirror(function ()
        WORLD_MAP_TILES_MANAGER:UpdateTextures()
        MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
        MiniMap.RefreshWorldMapPinsForMirror()
        if MiniMap.IsNativeWorldMapContainerAttached() then
            MiniMap.SetLuiMiniMapTileLayerHidden(true)
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
    MiniMap.SetLuiMiniMapTileLayerHidden(true)
    MiniMap.RefreshNativeWorldMapContainer()
    MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
end

function MiniMap.RestoreWorldMapContainerToWorldMap()
    if not nativeWorldMapContainerAttached then
        return
    end

    MiniMap.CancelNativeHudMapOverlayLayoutReapply()
    RestoreWorldMapPlayerPinVisibility()

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
    ZO_WorldMap_GetPinManager():UpdatePinsForMapSizeChange()

    nativeWorldMapContainerAttached = false
    nativeWorldMapContainerRestore = nil
    MiniMap.SetLuiMiniMapTileLayerHidden(false)

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
    MiniMap.RestoreWorldMapContainerToWorldMap()
end
