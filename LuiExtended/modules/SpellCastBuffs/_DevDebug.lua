-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

if not LUIE.IsDevDebugEnabled() then
    return
end

-- LUIE utility functions
local AddSystemMessage = LUIE.AddSystemMessage
local printToChat = LUIE.PrintToChat

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs
local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local EffectOverride = Effects.EffectOverride
local DebugAuras = Data.DebugAuras
local DebugResults = Data.DebugResults

-- -----------------------------------------------------------------------------
-- Core Lua function localizations
-- -----------------------------------------------------------------------------

local pairs = pairs
local string_format = string.format
local zo_round = zo_round
local tostring = tostring

local DoesAbilityExist = DoesAbilityExist
local GetZoneId = GetZoneId
local GetCurrentMapZoneIndex = GetCurrentMapZoneIndex
local GetPlayerLocationName = GetPlayerLocationName
local GetCurrentMapId = GetCurrentMapId
local GetCurrentMapIndex = GetCurrentMapIndex
local GetMapInfoById = GetMapInfoById
local GetMapPlayerPosition = GetMapPlayerPosition
local GetMapName = GetMapName
local SetMapToPlayerLocation = SetMapToPlayerLocation
local SetMapToMapListIndex = SetMapToMapListIndex
local MapZoomOut = MapZoomOut
local chatSystem = ZO_GetChatSystem()


--- Formats GPS coordinates for display
--- @param number number The raw coordinate value
--- @return number Rounded coordinate value
local function FormatGPSCoords(number)
    return zo_round(number * 100000)
end

--- Formats coordinates for display with proper formatting
--- @param number number The raw coordinate value
--- @return string Formatted coordinate string
local function FormatCoords(number)
    return ("%05.02f"):format(FormatGPSCoords(number) / 100)
end

-- Account specific DEBUG for ArtOfShred (These are only registered to give me some additional debug options)
function SpellCastBuffs.AuthorCombatDebug(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    local source
    local target
    if sourceName == "" and targetName == "" then
        source = "NIL"
        target = "NIL"
    end
    source = zo_strformat("<<C:1>>", sourceName)
    target = zo_strformat("<<C:1>>", targetName)
    if source == LUIE.PlayerNameFormatted then
        source = "Player"
    end
    if target == LUIE.PlayerNameFormatted then
        target = "Player"
    end

    local formattedResult = DebugResults[result]

    if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
        local finalString = (iconFormatted .. "[" .. abilityId .. "] " .. nameFormatted .. ": HIDDEN LUI" .. ": [S] " .. source .. " --> [T] " .. target .. " [R] " .. formattedResult)
        for k, cc in ipairs(chatSystem.containers) do
            local chatContainer = cc
            local chatWindow = cc.windows[2]
            if chatWindow == nil then chatWindow = cc.windows[1] end
            chatContainer:AddEventMessageToWindow(chatWindow, finalString, CHAT_CATEGORY_SYSTEM)
        end
    end
end

-- Account specific DEBUG for ArtOfShred (These are only registered to give me some additional debug options)
function SpellCastBuffs.AuthorEffectDebug(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer)
    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    unitName = zo_strformat("<<C:1>>", unitName)
    if unitName == LUIE.PlayerNameFormatted then
        unitName = "Player"
    end
    unitName = unitName .. " (" .. unitTag .. ")"

    local refreshOnly = ""
    if EffectOverride[abilityId] and EffectOverride[abilityId].refreshOnly then
        refreshOnly = " |c00E200(Refresh Only - Hidden)|r "
    end

    if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
        local finalString = (iconFormatted .. refreshOnly .. "|c00E200 [" .. abilityId .. "] " .. nameFormatted .. ": HIDDEN LUI" .. ": [Tag] " .. unitName .. "|r")
        for k, cc in ipairs(chatSystem.containers) do
            local chatContainer = cc
            local chatWindow = cc.windows[2]
            if chatWindow == nil then chatWindow = cc.windows[1] end
            chatContainer:AddEventMessageToWindow(chatWindow, finalString, CHAT_CATEGORY_SYSTEM)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Map and Zone Information
-- -----------------------------------------------------------------------------

--- @class ZoneMapInfo
--- @field zoneid integer
--- @field locName string
--- @field mapid integer
--- @field mapindex luaindex|nil
--- @field name string
--- @field mapType UIMapType
--- @field mapContentType MapContentType
--- @field zoneIndex luaindex
--- @field description string
--- @field mapX number
--- @field mapY number
--- @field zoneX number
--- @field zoneY number
--- @field worldX number
--- @field worldY number
--- @field mapName string
--- @field zoneName string
--- @field floorInfo table Floor information if available
--- @field poiInfo table POI information if available
--- @field fastTravelInfo table Fast travel information if available
--- @field zoneFlags table Various boolean flags about the current zone
--- @field keyInfo table Map key information if available
--- @field cadwellInfo table Cadwell's Almanac information if available

--- Collects and returns zone and map information
--- @return ZoneMapInfo Information about current zone and map
local function CollectZoneMapInfo()
    -- Set map to player location and handle callback
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        LUIE:FireCallbacks("OnWorldMapChanged")
    end

    -- Get basic zone and map info
    local zoneIdx = GetCurrentMapZoneIndex()
    local zoneid = GetZoneId(zoneIdx)
    local locName = GetPlayerLocationName()
    local mapid = GetCurrentMapId()
    local mapindex = GetCurrentMapIndex() or GetMapIndexByZoneId(zoneid) or zoneIdx
    local name, mapType, mapContentType, zoneIndex, description = GetMapInfoById(mapid)

    -- Get coordinates at different map levels
    local mapX, mapY = GetMapPlayerPosition("player")
    local zoneX, zoneY = mapX, mapY
    local worldX, worldY = mapX, mapY
    local mapName = GetMapName()
    local zoneName = mapName

    -- Handle dungeon/subzone cases
    if mapContentType == MAP_CONTENT_DUNGEON or mapType == MAPTYPE_SUBZONE then
        MapZoomOut()
        zoneName = GetMapName()
        zoneX, zoneY = GetMapPlayerPosition("player")
    end

    -- Get world coordinates (except for Coldharbour)
    if not (mapindex == 24 or GetCurrentMapIndex() == 24) then
        SetMapToMapListIndex(1) -- Tamriel
        worldX, worldY = GetMapPlayerPosition("player")
    end

    -- Get floor information if available
    local floorInfo = {}
    local currentFloor, numFloors = GetMapFloorInfo()
    if numFloors > 0 then
        floorInfo =
        {
            currentFloor = currentFloor,
            numFloors = numFloors
        }
    end

    -- Get POI info
    local poiInfo = {}
    local numPOIs = GetNumPOIs(zoneIndex)
    if numPOIs > 0 then
        poiInfo.count = numPOIs
        poiInfo.items = {}

        for i = 1, numPOIs do
            local objectiveName, objectiveLevel, startDescription, finishedDescription = GetPOIInfo(zoneIndex, i)
            local poiType = GetPOIType(zoneIndex, i)
            local poiX, poiY, poiPinType, icon, isShown, isLocked, isDiscovered, isNearby = GetPOIMapInfo(zoneIndex, i)

            poiInfo.items[i] =
            {
                name = objectiveName,
                level = objectiveLevel,
                type = poiType,
                x = poiX,
                y = poiY,
                isDiscovered = isDiscovered,
                isNearby = isNearby
            }
        end
    end

    -- Get fast travel information
    local fastTravelInfo = {}
    local numFastTravel = GetNumFastTravelNodes()
    if numFastTravel > 0 then
        fastTravelInfo.count = numFastTravel
        fastTravelInfo.items = {}

        for i = 1, numFastTravel do
            local known, nodeName, nodeX, nodeY, icon, glowIcon, poiType, isShown, isLocked = GetFastTravelNodeInfo(i)
            if isShown then
                local cooldownRemain, cooldownDuration = GetRecallCooldown()
                local recallCost = GetRecallCost(i)
                local recallCurrency = GetRecallCurrency(i)

                fastTravelInfo.items[#fastTravelInfo.items + 1] =
                {
                    name = nodeName,
                    known = known,
                    x = nodeX,
                    y = nodeY,
                    cooldown = { remain = cooldownRemain, duration = cooldownDuration },
                    cost = recallCost,
                    currency = recallCurrency
                }
            end
        end
    end

    -- Zone flags.
    local zoneFlags =
    {
        isInCyrodiil = IsInCyrodiil(),
        isInImperialCity = IsInImperialCity(),
        isInAvAZone = IsInAvAZone(),
        isInOutlawZone = IsInOutlawZone(),
        isInJusticeZone = IsInJusticeEnabledZone(),
        allowsTeleport = CanLeaveCurrentLocationViaTeleport(),
        allowsScaling = DoesCurrentZoneAllowScalingByLevel(),
        hasTelvarBehavior = DoesCurrentZoneHaveTelvarStoneBehavior(),
        allowsBattleLevelScaling = DoesCurrentZoneAllowBattleLevelScaling(),
        isInAvAWorld = IsPlayerInAvAWorld(),
        isInBattleground = IsActiveWorldBattleground(),
        isGroupOwnable = IsActiveWorldGroupOwnable(),
        isStarterWorld = IsActiveWorldStarterWorld()
    }

    -- Get map key information
    local keyInfo = {}
    local numKeySections = GetNumMapKeySections()
    if numKeySections > 0 then
        keyInfo.sections = {}
        for i = 1, numKeySections do
            local sectionName = GetMapKeySectionName(i)
            local numSymbols = GetNumMapKeySectionSymbols(i)

            local symbols = {}
            for j = 1, numSymbols do
                local symbolName, symbolIcon, symbolTooltip = GetMapKeySectionSymbolInfo(i, j)
                symbols[j] =
                {
                    name = symbolName,
                    icon = symbolIcon,
                    tooltip = symbolTooltip
                }
            end

            keyInfo.sections[i] =
            {
                name = sectionName,
                symbols = symbols
            }
        end
    end

    -- Get Cadwell's Almanac information if available
    local cadwellInfo = {}
    local cadwellLevel = GetCadwellProgressionLevel()
    if cadwellLevel > 0 then
        cadwellInfo.level = cadwellLevel
        cadwellInfo.zones = {}

        local numZones = GetNumZonesForCadwellProgressionLevel(cadwellLevel)
        for i = 1, numZones do
            local cadwellZoneName, zoneDesc, zoneOrder = GetCadwellZoneInfo(cadwellLevel, i)
            cadwellInfo.zones[i] =
            {
                name = cadwellZoneName,
                description = zoneDesc,
                order = zoneOrder
            }
        end
    end

    -- Get level scaling constraints
    local scaleLevelType, minScaleLevel, maxScaleLevel = GetCurrentZoneLevelScalingConstraints()

    -- Reset map to player location
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        LUIE:FireCallbacks("OnWorldMapChanged")
    end

    -- Return collected information
    return
    {
        zoneid = zoneid,
        locName = locName,
        mapid = mapid,
        mapindex = mapindex,
        name = name,
        mapType = mapType,
        mapContentType = mapContentType,
        zoneIndex = zoneIndex,
        description = description,
        mapX = mapX,
        mapY = mapY,
        zoneX = zoneX,
        zoneY = zoneY,
        worldX = worldX,
        worldY = worldY,
        mapName = mapName,
        zoneName = zoneName,
        floorInfo = floorInfo,
        poiInfo = poiInfo,
        fastTravelInfo = fastTravelInfo,
        zoneFlags = zoneFlags,
        keyInfo = keyInfo,
        cadwellInfo = cadwellInfo,
        scaleLevelConstraints =
        {
            type = scaleLevelType,
            min = minScaleLevel,
            max = maxScaleLevel
        }
    }
end

-- -----------------------------------------------------------------------------
-- Slash Command Handlers
-- -----------------------------------------------------------------------------

--- Toggles the ability debug filter on/off.
--- When enabled, shows additional debug information for abilities.
function SpellCastBuffs.TempSlashFilter()
    SpellCastBuffs.SV.ShowDebugFilter = not SpellCastBuffs.SV.ShowDebugFilter
    AddSystemMessage(string_format("LUIE --- Ability Debug Filter %s ---",
                                   SpellCastBuffs.SV.ShowDebugFilter and "Enabled" or "Disabled"))
end

--- Toggles ground damage aura visualization on/off.
--- When enabled, shows visual effects for ground-based damage areas.
--- Reloads player effects after toggling.
function SpellCastBuffs.TempSlashGround()
    SpellCastBuffs.SV.GroundDamageAura = not SpellCastBuffs.SV.GroundDamageAura
    AddSystemMessage(string_format("LUIE --- Ground Damage Auras %s ---",
                                   SpellCastBuffs.SV.GroundDamageAura and "Enabled" or "Disabled"))
    LUIE.SpellCastBuffs.ReloadEffects("player")
end

--- Outputs current zone and map information to chat.
--- Retrieves and displays:
--- - Zone ID and location name
--- - Map ID and index
--- - Map name, type, content type
--- - Zone index and description
--- - GPS coordinates for player
function SpellCastBuffs.TempSlashZoneCheck()
    local info = CollectZoneMapInfo()

    local displayInfo =
    {
        { "--------------------"                                                                                                                             },
        { "ZONE & MAP INFO:"                                                                                                                                 },
        { "--------------------"                                                                                                                             },
        { "Zone Id:",            info.zoneid                                                                                                                 },
        { "Location Name:",      info.locName                                                                                                                },
        { "--------------------"                                                                                                                             },
        { "Map Id:",             info.mapid                                                                                                                  },
        { "Map Index:",          info.mapindex or "nil"                                                                                                      },
        { "--------------------"                                                                                                                             },
        { "GPS Coordinates:"                                                                                                                                 },
        { "Map:",                string_format("%s: %s" .. LUIE_TINY_X_FORMATTER .. "%s", info.mapName, FormatCoords(info.mapX), FormatCoords(info.mapY))    },
        { "Zone:",               string_format("%s: %s" .. LUIE_TINY_X_FORMATTER .. "%s", info.zoneName, FormatCoords(info.zoneX), FormatCoords(info.zoneY)) },
        { "World:",              string_format("Tamriel: %s" .. LUIE_TINY_X_FORMATTER .. "%s", FormatCoords(info.worldX), FormatCoords(info.worldY))         },
        { "--------------------"                                                                                                                             },
        { "Map Name:",           info.name                                                                                                                   },
        { "Map Type:",           info.mapType                                                                                                                },
        { "Map Content Type:",   info.mapContentType                                                                                                         },
        { "Zone Index:",         info.zoneIndex                                                                                                              },
        { "Description:",        info.description                                                                                                            },
    }

    -- Floor information
    if info.floorInfo.numFloors and info.floorInfo.numFloors > 0 then
        table.insert(displayInfo, { "--------------------" })
        table.insert(displayInfo, { "Floor Information:" })
        table.insert(displayInfo, { "Current Floor:", info.floorInfo.currentFloor })
        table.insert(displayInfo, { "Total Floors:", info.floorInfo.numFloors })
    end

    -- Zone flags
    table.insert(displayInfo, { "--------------------" })
    table.insert(displayInfo, { "Zone Flags:" })
    local flagsStr = ""
    if info.zoneFlags.isInCyrodiil then flagsStr = flagsStr .. "Cyrodiil, " end
    if info.zoneFlags.isInImperialCity then flagsStr = flagsStr .. "Imperial City, " end
    if info.zoneFlags.isInAvAZone then flagsStr = flagsStr .. "AvA Zone, " end
    if info.zoneFlags.isInOutlawZone then flagsStr = flagsStr .. "Outlaw Zone, " end
    if info.zoneFlags.isInJusticeZone then flagsStr = flagsStr .. "Justice Zone, " end
    if info.zoneFlags.hasTelvarBehavior then flagsStr = flagsStr .. "Telvar Stone, " end
    if info.zoneFlags.isInBattleground then flagsStr = flagsStr .. "Battleground, " end
    if info.zoneFlags.isStarterWorld then flagsStr = flagsStr .. "Starter World, " end
    if flagsStr == "" then flagsStr = "None" else flagsStr = string.sub(flagsStr, 1, -3) end
    table.insert(displayInfo, { "Active Flags:", flagsStr })

    -- Level scaling
    table.insert(displayInfo, { "--------------------" })
    table.insert(displayInfo, { "Level Scaling:" })
    table.insert(displayInfo, { "Scale Type:", info.scaleLevelConstraints.type })
    table.insert(displayInfo, { "Min Level:", info.scaleLevelConstraints.min })
    table.insert(displayInfo, { "Max Level:", info.scaleLevelConstraints.max })

    -- POI information
    if info.poiInfo.count and info.poiInfo.count > 0 then
        AddSystemMessage("--------------------")
        AddSystemMessage("DETAILED POI INFORMATION:")
        AddSystemMessage("--------------------")

        for i, poi in ipairs(info.poiInfo.items) do
            if i <= 5 then -- Limit to first 5 POIs to avoid spam
                AddSystemMessage(string_format("POI %d: %s (Type: %d, Discovered: %s)",
                                               i, poi.name, poi.type, poi.isDiscovered and "Yes" or "No"))
            end
        end

        if #info.poiInfo.items > 5 then
            AddSystemMessage(string_format("... and %d more POIs", #info.poiInfo.items - 5))
        end
    end

    -- Fast travel information
    if info.fastTravelInfo.count and info.fastTravelInfo.count > 0 then
        table.insert(displayInfo, { "--------------------" })
        table.insert(displayInfo, { "Fast Travel Points:", info.fastTravelInfo.count .. " total nodes" })
        table.insert(displayInfo, { "Available:", #info.fastTravelInfo.items .. " in current map" })

        if #info.fastTravelInfo.items > 0 then
            -- Show the nearest wayshrine
            local nearestName = info.fastTravelInfo.items[1].name
            local nearestDist = 999999

            for _, node in ipairs(info.fastTravelInfo.items) do
                local dist = math.sqrt((node.x - info.mapX) ^ 2 + (node.y - info.mapY) ^ 2)
                if dist < nearestDist then
                    nearestDist = dist
                    nearestName = node.name
                end
            end

            table.insert(displayInfo, { "Nearest Wayshrine:", nearestName })
        end
    end

    -- Cadwell's Almanac information
    if info.cadwellInfo.level and info.cadwellInfo.level > 0 then
        table.insert(displayInfo, { "--------------------" })
        table.insert(displayInfo, { "Cadwell's Almanac:" })
        table.insert(displayInfo, { "Progress Level:", info.cadwellInfo.level })
        if info.cadwellInfo.zones and #info.cadwellInfo.zones > 0 then
            table.insert(displayInfo, { "Zones in Current Level:", #info.cadwellInfo.zones })
        end
    end

    table.insert(displayInfo, { "--------------------" })

    for _, v in ipairs(displayInfo) do
        AddSystemMessage(#v == 1 and v[1] or string_format("%s %s", v[1], v[2]))
    end
end

--- Checks for removed abilities by iterating through LuiData.Data.DebugAuras and checking if each ability still exists.
--- Outputs a list of ability IDs that no longer exist in the game to chat.
function SpellCastBuffs.TempSlashCheckRemovedAbilities()
    AddSystemMessage("Removed AbilityIds:")
    for abilityId in pairs(DebugAuras) do
        if not DoesAbilityExist(abilityId) then
            AddSystemMessage(tostring(abilityId))
        end
    end
end

-- Add a new command for full zone info output
function SpellCastBuffs.TempSlashZoneCheckFull()
    local info = CollectZoneMapInfo()

    -- Display basic info first
    SpellCastBuffs.TempSlashZoneCheck()

    -- Display POI details
    if info.poiInfo.count and info.poiInfo.count > 0 then
        AddSystemMessage("--------------------")
        AddSystemMessage("DETAILED POI INFORMATION:")
        AddSystemMessage("--------------------")

        for i, poi in ipairs(info.poiInfo.items) do
            if i <= 5 then -- Limit to first 5 POIs to avoid spam
                AddSystemMessage(string_format("POI %d: %s (Type: %d, Discovered: %s)",
                                               i, poi.name, poi.type, poi.isDiscovered and "Yes" or "No"))
            end
        end

        if #info.poiInfo.items > 5 then
            AddSystemMessage(string_format("... and %d more POIs", #info.poiInfo.items - 5))
        end
    end

    -- Display wayshrine details
    if info.fastTravelInfo.count and info.fastTravelInfo.count > 0 then
        AddSystemMessage("--------------------")
        AddSystemMessage("DETAILED WAYSHRINE INFORMATION:")
        AddSystemMessage("--------------------")

        for i, node in ipairs(info.fastTravelInfo.items) do
            if i <= 5 then -- Limit to first 5 wayshrines
                AddSystemMessage(string_format("Wayshrine %d: %s (Known: %s, Cost: %d)",
                                               i, node.name, node.known and "Yes" or "No", node.cost))
            end
        end

        if #info.fastTravelInfo.items > 5 then
            AddSystemMessage(string_format("... and %d more wayshrines", #info.fastTravelInfo.items - 5))
        end
    end

    -- Display key section info
    if info.keyInfo.sections and #info.keyInfo.sections > 0 then
        AddSystemMessage("--------------------")
        AddSystemMessage("MAP KEY INFORMATION:")
        AddSystemMessage("--------------------")

        for i, section in ipairs(info.keyInfo.sections) do
            AddSystemMessage(string_format("Section: %s (%d symbols)", section.name, #section.symbols))
        end
    end

    AddSystemMessage("--------------------")
end

-- -----------------------------------------------------------------------------
-- Slash Commands Registration
-- -----------------------------------------------------------------------------

-- Slash command mapping
local DEBUG_COMMANDS =
{
    ["/filter"] = SpellCastBuffs.TempSlashFilter,
    ["/ground"] = SpellCastBuffs.TempSlashGround,
    ["/zonecheck"] = SpellCastBuffs.TempSlashZoneCheck,
    ["/zonecheckfull"] = SpellCastBuffs.TempSlashZoneCheckFull,
    ["/abilitydump"] = SpellCastBuffs.TempSlashCheckRemovedAbilities,
}

--- Initializes debug slash commands
--- These commands are only available when developer debug mode is enabled
if LUIE.IsDevDebugEnabled() then
    for command, handler in pairs(DEBUG_COMMANDS) do
        SLASH_COMMANDS[command] = handler
    end
end
-- -----------------------------------------------------------------------------
