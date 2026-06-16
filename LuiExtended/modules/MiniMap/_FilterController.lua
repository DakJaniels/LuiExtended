-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Assumes ingame map globals; see EsoUI/Ingame/Map (CMapHandlers, WorldMap, MapPin).

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

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
    local pinManager = ZO_WorldMap_GetPinManager()
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
