-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Assumes ingame map globals; see EsoUI/Ingame/Map (CMapHandlers, WorldMap, MapPin).

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap
local pinManager = ZO_WorldMap_GetPinManager()

function MiniMap.RefreshWorldMapPingsForMirror()
    WORLD_MAP_MANAGER:RefreshMapPings()
end

function MiniMap.RefreshWorldMapSuggestionPinsForMirror()
    if ZO_WorldMap_IsPinGroupShown(MAP_FILTER_QUESTS) then
        WORLD_MAP_MANAGER:RefreshSuggestionPins()
    end
end

--- Service icons (stable, bank, etc.) on g_mapPinManager; mirrors ZO_MapLocationPins_Manager:RefreshLocations.
function MiniMap.RefreshWorldMapLocationPinsForMirror()
    pinManager:RemovePins("loc")
    for locationIndex = 1, GetNumMapLocations() do
        if IsMapLocationVisible(locationIndex) then
            local icon, normalizedX, normalizedY = GetMapLocationIcon(locationIndex)
            if icon ~= "" and ZO_WorldMap_IsNormalizedPointInsideMapBounds(normalizedX, normalizedY) then
                local tag = ZO_MapPin.CreateLocationPinTag(locationIndex, icon)
                pinManager:CreatePin(MAP_PIN_TYPE_LOCATION, tag, normalizedX, normalizedY)
            end
        end
    end
end

--- Repopulate world-map pins on the current player map for the reparented ZO_WorldMapContainer (g_mapPinManager + keep network).
function MiniMap.RefreshWorldMapPinsForMirror()
    C_MAP_HANDLERS:RefreshAllQuestPins()
    C_MAP_HANDLERS:RefreshZoneStory()
    C_MAP_HANDLERS:RefreshAntiquityDigSitePins()

    local mapFilterType = GetMapFilterType()
    local playerInAvAZone = IsInCyrodiil() or IsInJerallPass() or IsInImperialCity()
    if playerInAvAZone then
        if mapFilterType == MAP_FILTER_TYPE_AVA_CYRODIIL then
            ZO_WorldMap_RefreshKeeps()
            ZO_WorldMap_RefreshKeepNetwork()
            ZO_WorldMap_RefreshObjectives()
            ZO_WorldMap_RefreshForwardCamps()
            ZO_WorldMap_RefreshAccessibleAvAGraveyards()
        elseif mapFilterType == MAP_FILTER_TYPE_AVA_IMPERIAL then
            ZO_WorldMap_RefreshKeeps()
            ZO_WorldMap_RefreshObjectives()
        end
    end

    if ZO_WorldMap_IsPinGroupShown(MAP_FILTER_DIG_SITES) then
        WORLD_MAP_MANAGER:RefreshAllAntiquityDigSites()
    end

    ZO_WorldMap_RefreshAllPOIs()
    MiniMap.RefreshWorldMapSuggestionPinsForMirror()
    MiniMap.RefreshWorldMapPingsForMirror()
    MiniMap.RefreshWorldMapLocationPinsForMirror()
end

--- Layout-only HUD recovery after ZOS quest pin data is already current (CMapHandlers callbacks, breadcrumbs, etc.).
function MiniMap.ApplyNativeHudQuestPinLayoutAfterCMapHandlers()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    if MiniMap.playerMapMirrorDepth > 0 or MiniMap.IsPinMirrorMachineBusy() then
        return
    end
    local mapController = MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    MiniMap.ResetNativeHudWorldMapPanState()
    MiniMap.RefreshWorldMapSuggestionPinsForMirror()
    MiniMap.RefreshWorldMapPingsForMirror()
    MiniMap.FlushWorldMapPinRefreshGroups()
end

--- @param journalIndex luaindex|nil
function MiniMap.OnCMapHandlersRefreshedQuestPins(journalIndex)
    MiniMap.ApplyNativeHudQuestPinLayoutAfterCMapHandlers()
end

--- Light quest mirror: refresh pin data when ZOS did not (tracker), then HUD layout. No full container / POI walk.
--- @param journalIndex luaindex|nil
--- @param refreshAll boolean|nil
function MiniMap.RunQuestPinLightSyncForMirror(journalIndex, refreshAll)
    if not MiniMap.Enabled then
        return
    end
    MiniMap.RunWithPlayerMapForMirror(function ()
        if refreshAll then
            C_MAP_HANDLERS:RefreshAllQuestPins()
        elseif journalIndex then
            C_MAP_HANDLERS:RefreshSingleQuestPins(journalIndex)
        end
        MiniMap.ApplyNativeHudQuestPinLayoutAfterCMapHandlers()
    end)
end
