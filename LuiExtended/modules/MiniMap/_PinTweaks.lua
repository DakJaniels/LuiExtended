-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

-- -----------------------------------------------------------------------------
-- Pin-refresh tweaks.
--
-- Reusing ZO_WorldMap as the HUD minimap means the still-synchronous pin
-- refreshes (POIs, wayshrines, forward camps, kill locations, location pins,
-- custom pins, map-size relayout) run on the critical path every time the
-- follow tick changes the map. We wrap those surfaces and route them through
-- the MiniMap coroutine scheduler so repeated requests coalesce into a single
-- deferred pass that waits for the texture/zoom to settle.
--
-- Categories already frame-deferred by g_mapRefresh:UpdateRefreshGroups
-- (keeps, objectives, locations groups, keep network, group, world events) are
-- intentionally left alone - wrapping them would add nothing.
--
-- The wrappers pass through unchanged whenever the minimap is not driving the
-- HUD (module disabled, not in minimap mode, or the full world map is open), so
-- the real world map behaves exactly as ZOS intends.
-- -----------------------------------------------------------------------------

local CALLBACK_MANAGER = CALLBACK_MANAGER
local scheduler = MiniMap.async

--- @return boolean
local function ShouldDeferForMiniMap()
    return MiniMap.Enabled == true
        and MiniMap.IsMiniMapModeActive()
        and not ZO_WorldMap_IsWorldMapShowing()
end

--- The pan/zoom animation has settled and the map texture is ready to lay out pins.
--- @return boolean
local function IsZoomSettled()
    local panAndZoom = ZO_WorldMap_GetPanAndZoom()
    return panAndZoom.targetNormalizedZoom == nil and panAndZoom:CanInitializeMap()
end

-- -----------------------------------------------------------------------------
-- Deferred no-argument global refreshes
-- -----------------------------------------------------------------------------

--- @param globalName string
--- @param taskName string
--- @param fireResync boolean|nil Fire the pin resync registry once the pass runs.
local function InstallDeferredGlobalRefresh(globalName, taskName, fireResync)
    local originalRefresh = _G[globalName]
    local task = scheduler:CreateTask(taskName)
    _G[globalName] = function (...)
        if not ShouldDeferForMiniMap() then
            return originalRefresh(...)
        end
        task:Cancel():WaitUntil(IsZoomSettled):QueueStep(function ()
            originalRefresh()
            if fireResync then
                MiniMap.FirePinResyncCallbacks()
            end
        end)
    end
end

InstallDeferredGlobalRefresh("ZO_WorldMap_RefreshAllPOIs", MiniMap.moduleName .. "_POIs", true)
InstallDeferredGlobalRefresh("ZO_WorldMap_RefreshWayshrines", MiniMap.moduleName .. "_Wayshrines")
InstallDeferredGlobalRefresh("ZO_WorldMap_RefreshForwardCamps", MiniMap.moduleName .. "_ForwardCamps")
InstallDeferredGlobalRefresh("ZO_WorldMap_RefreshKillLocations", MiniMap.moduleName .. "_KillLocations")

-- -----------------------------------------------------------------------------
-- Deferred custom pin refresh (preserves the optional pin-type argument)
-- -----------------------------------------------------------------------------

do
    local originalRefreshCustomPins = ZO_WorldMapPins_Manager.RefreshCustomPins
    local task = scheduler:CreateTask(MiniMap.moduleName .. "_CustomPins")
    local pendingAll = false
    local pendingPinTypes = {}

    function ZO_WorldMapPins_Manager:RefreshCustomPins(optionalPinType)
        if not ShouldDeferForMiniMap() then
            return originalRefreshCustomPins(self, optionalPinType)
        end
        if optionalPinType then
            pendingPinTypes[optionalPinType] = true
        else
            pendingAll = true
        end
        local pinManager = self
        task:Cancel():WaitUntil(IsZoomSettled):QueueStep(function ()
            if pendingAll then
                originalRefreshCustomPins(pinManager)
            else
                for pinType in pairs(pendingPinTypes) do
                    originalRefreshCustomPins(pinManager, pinType)
                end
            end
            pendingAll = false
            ZO_ClearTable(pendingPinTypes)
            MiniMap.FirePinResyncCallbacks()
        end)
    end
end

-- -----------------------------------------------------------------------------
-- Deferred location pins
-- -----------------------------------------------------------------------------

do
    local originalRefreshLocations = ZO_MapLocationPins_Manager.RefreshLocations
    local task = scheduler:CreateTask(MiniMap.moduleName .. "_Locations")

    function ZO_MapLocationPins_Manager:RefreshLocations()
        if not ShouldDeferForMiniMap() then
            return originalRefreshLocations(self)
        end
        local locationManager = self
        task:Cancel():WaitUntil(IsZoomSettled):QueueStep(function ()
            originalRefreshLocations(locationManager)
        end)
    end
end

-- -----------------------------------------------------------------------------
-- Coalesced map-size relayout (deduplicated by dimensions + zone)
-- -----------------------------------------------------------------------------

do
    local originalUpdatePinsForMapSizeChange = ZO_WorldMapPins_Manager.UpdatePinsForMapSizeChange
    local task = scheduler:CreateTask(MiniMap.moduleName .. "_MapSizeChange")
    local lastWidth, lastHeight, lastZone = -1, -1, -1

    function ZO_WorldMapPins_Manager:UpdatePinsForMapSizeChange()
        if not ShouldDeferForMiniMap() then
            lastWidth, lastHeight, lastZone = -1, -1, -1
            return originalUpdatePinsForMapSizeChange(self)
        end
        local width, height = ZO_WorldMapContainer:GetDimensions()
        width, height = zo_round(width), zo_round(height)
        local zone = GetMapTileTexture()
        if width == lastWidth and height == lastHeight and zone == lastZone then
            return
        end
        lastWidth, lastHeight, lastZone = width, height, zone
        local pinManager = self
        task:Cancel():QueueStep(function ()
            originalUpdatePinsForMapSizeChange(pinManager)
        end)
    end
end

-- -----------------------------------------------------------------------------
-- Engine quest/antiquity pins (C-side, refreshed via callbacks)
-- -----------------------------------------------------------------------------

--- When the engine refreshes quest pins while we are following on the HUD, make
--- sure the map still matches the player location so the new pins are visible.
local function OnQuestPinsRefreshed()
    if ZO_WorldMap_IsWorldMapShowing() or not MiniMap.IsMiniMapModeActive() then
        return
    end
    if not DoesCurrentMapMatchMapForPlayerLocation() then
        if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
            CALLBACK_MANAGER:FireCallbacks("OnWorldMapChanged")
        end
    end
end

C_MAP_HANDLERS:RegisterCallback("RefreshedAllQuestPins", OnQuestPinsRefreshed)
C_MAP_HANDLERS:RegisterCallback("RefreshedSingleQuestPins", OnQuestPinsRefreshed)

-- -----------------------------------------------------------------------------
-- Public async refresh entry point (used by RequestPinResync)
-- -----------------------------------------------------------------------------

function MiniMap.RequestAsyncPinRefresh()
    if not MiniMap.IsMiniMapModeActive() then
        return
    end
    ZO_WorldMap_RefreshAllPOIs()
    ZO_WorldMap_RefreshWayshrines()
    ZO_WorldMap_RefreshForwardCamps()
    ZO_WorldMap_RefreshKillLocations()
    ZO_WorldMap_GetPinManager():RefreshCustomPins()
end
