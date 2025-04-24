-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs
local Effects = LuiData.Data.Effects

-- -----------------------------------------------------------------------------
-- Core Lua function localizations
-- -----------------------------------------------------------------------------

local pairs = pairs
local string_format = string.format
local zo_strformat = zo_strformat
local zo_iconFormat = zo_iconFormat
local zo_strgsub = zo_strgsub
local zo_round = zo_round
local tostring = tostring

-- API function localizations
local GetAbilityIcon = GetAbilityIcon
local GetAbilityName = GetAbilityName
local GetAbilityDuration = GetAbilityDuration
local GetAbilityCastInfo = GetAbilityCastInfo
local DoesAbilityExist = DoesAbilityExist
local GetDisplayName = GetDisplayName
local GetZoneId = GetZoneId
local GetCurrentMapZoneIndex = GetCurrentMapZoneIndex
local GetPlayerLocationName = GetPlayerLocationName
local GetCurrentMapId = GetCurrentMapId
local GetCurrentMapIndex = GetCurrentMapIndex
local GetMapInfoById = GetMapInfoById
local GetMapPlayerPosition = GetMapPlayerPosition
local GetMapName = GetMapName
local GetMapContentType = GetMapContentType
local GetMapType = GetMapType
local SetMapToPlayerLocation = SetMapToPlayerLocation
local SetMapToMapListIndex = SetMapToMapListIndex
local MapZoomOut = MapZoomOut
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local FormatTimeMilliseconds = FormatTimeMilliseconds

-- LUIE utility functions
local AddSystemMessage = LUIE.AddSystemMessage
local FormatMessage = LUIE.FormatMessage
local printToChat = LUIE.PrintToChat

-- -----------------------------------------------------------------------------
-- Debug Configuration
-- -----------------------------------------------------------------------------

--- @class DebugFormatConfig
local DebugFormatConfig =
{
    -- Color configurations
    gainedColor = "|c00E200",
    hiddenColor = "|c00E200",

    -- Format strings
    gainedPrefix = "Gained:",
    fadedPrefix = "Faded:",
    refreshedPrefix = "Refreshed:",
    hiddenText = "(Hidden)",
}

-- -----------------------------------------------------------------------------
-- Formatting Utilities
-- -----------------------------------------------------------------------------

--- Checks if pChat addon is active
--- @return boolean Whether pChat is active
local function IsPChatActive()
    return pChat ~= nil
end

--- Adds a millisecond timestamp to debug messages
--- @param message string The message to add a timestamp to
--- @return string Formatted message with timestamp
local function MillisecondTimestampDebug(message)
    -- Skip adding timestamp if pChat is active or if LUIE timestamps are enabled to avoid duplicate timestamps
    if IsPChatActive() or LUIE.ChatAnnouncements.SV.TimeStamp then
        return message
    end

    local currentTime = GetGameTimeMilliseconds()
    local timestamp = FormatTimeMilliseconds(currentTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_MILLISECONDS_NO_HOURS_OR_DAYS, TIME_FORMAT_DIRECTION_NONE)

    -- Remove unnecessary parts from timestamp
    local replacements =
    {
        { "HH", "" }, { "H ", ":" }, { "hh", "" }, { "h ", ":" },
        { "m ", ":" }, { "s ", ":" }, { "A", "" }, { "a", "" }, { "ms", "" }
    }

    for _, replacement in ipairs(replacements) do
        timestamp = zo_strgsub(timestamp, replacement[1], replacement[2])
    end

    return string_format("|c%s[%s]|r %s", LUIE.TimeStampColorize, timestamp, message)
end

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

--- Formats source and target names for display
--- @param name string Raw name
--- @return string Formatted name
local function FormatActorName(name)
    local formattedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, name)

    if formattedName == LUIE.PlayerNameFormatted then
        return "Player"
    elseif formattedName == "" then
        return "NIL"
    end

    return formattedName
end

--- Formats ability information
--- @param abilityId number The ability ID
--- @param size number? Icon size (default: 16)
--- @return string, string Formatted icon, formatted name
local function FormatAbilityInfo(abilityId, size)
    size = size or 16
    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), size, size)
    local nameFormatted = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(abilityId))

    return iconFormatted, nameFormatted
end

--- Checks if an ability is hidden in CMX
--- @param abilityId number The ability ID
--- @return string Hidden status message
local function GetCMXHiddenStatus(abilityId)
    if CMX and CMX.CustomAbilityHide and CMX.CustomAbilityHide[abilityId] then
        return " + HIDDEN CMX"
    end
    return ""
end

--- Gets the refresh-only status text for an ability
--- @param abilityId number The ability ID
--- @return string Status text
local function GetRefreshOnlyStatus(abilityId)
    if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].refreshOnly then
        return string_format(" %s(%s)%s ", DebugFormatConfig.hiddenColor, DebugFormatConfig.hiddenText, "|r")
    end
    return ""
end

-- -----------------------------------------------------------------------------
-- Debug Message Generators
-- -----------------------------------------------------------------------------

--- Generates a formatted combat debug message
--- @param abilityId number The ability ID
--- @param source string Source name
--- @param target string Target name
--- @param duration number Ability duration
--- @param castInfo table Cast information
--- @param result number Combat result
--- @return string Formatted debug message
local function GenerateCombatDebugMessage(abilityId, source, target, duration, castInfo, result)
    local iconFormatted, nameFormatted = FormatAbilityInfo(abilityId)
    local formattedResult = LuiData.Data.DebugResults[result]
    local castTimeText = ""
    local channelTimeText = ""

    -- Format cast/channel information
    if castInfo.channeled then
        channelTimeText = (" [Chan] " .. castInfo.duration)
    end
    if castInfo.duration ~= 0 then
        castTimeText = (" [Cast] " .. castInfo.duration)
    end

    return string_format("%s [%d] %s: [S] %s --> [T] %s [D] %s%s%s [R] %s",
        iconFormatted, abilityId, nameFormatted, source, target, duration,
        channelTimeText, castTimeText, formattedResult)
end

--- Generates a formatted effect debug message
--- @param changeType number Effect change type (1=gained, 2=faded, other=refreshed)
--- @param abilityId number The ability ID
--- @param unitName string Unit name
--- @param unitTag string Unit tag
--- @param duration number Effect duration
--- @param isHidden boolean Whether the effect is hidden
--- @return string Formatted debug message
local function GenerateEffectDebugMessage(changeType, abilityId, unitName, unitTag, duration, isHidden)
    local iconFormatted, nameFormatted = FormatAbilityInfo(abilityId)
    local refreshOnly = GetRefreshOnlyStatus(abilityId)
    local cmxHiddenStatus = GetCMXHiddenStatus(abilityId)
    local formattedUnitName = unitName .. " (" .. unitTag .. ")"

    -- Handle hidden effects
    if isHidden then
        return string_format("%s%s [%d] %s: HIDDEN LUI%s: [Tag] %s%s",
            iconFormatted, DebugFormatConfig.hiddenColor, abilityId, nameFormatted,
            cmxHiddenStatus, formattedUnitName, "|r")
    end

    -- Format message based on change type
    if changeType == 1 then
        return string_format("%sGained:%s %s%s [%d] %s: [Tag] %s [Dur] %s",
            DebugFormatConfig.gainedColor, "|r", refreshOnly, iconFormatted,
            abilityId, nameFormatted, formattedUnitName, duration)
    elseif changeType == 2 then
        return string_format("%sFaded:%s %s [%d] %s: [Tag] %s",
            DebugFormatConfig.gainedColor, "|r", iconFormatted,
            abilityId, nameFormatted, formattedUnitName)
    else
        return string_format("%sRefreshed:%s %s (%d) [%d] %s: [Tag] %s [Dur] %s",
            DebugFormatConfig.gainedColor, "|r", iconFormatted, changeType,
            abilityId, nameFormatted, formattedUnitName, duration)
    end
end

-- -----------------------------------------------------------------------------
-- Debug Output Handlers
-- -----------------------------------------------------------------------------

--- Sends a debug message to chat
--- @param message string The message to send
--- @param systemChat boolean Whether to also send to system chat windows
local function SendDebugMessage(message, systemChat)
    -- Add formatted timestamp (if pChat isn't active)
    local formattedMessage = MillisecondTimestampDebug(message)

    -- Send to main chat
    printToChat(formattedMessage, true)

    -- If systemChat is true, also send to system chat windows
    if systemChat and ZO_GetChatSystem().primaryContainer then
        for _, cc in ipairs(ZO_GetChatSystem().containers) do
            local chatContainer = cc
            local chatWindow = cc.windows[3] or cc.windows[1]

            if chatContainer and chatWindow then
                chatContainer:AddEventMessageToWindow(chatWindow, formattedMessage, CHAT_CATEGORY_SYSTEM)
            end
        end
    end
end

-- -----------------------------------------------------------------------------
-- Debug Event Handlers
-- -----------------------------------------------------------------------------

--- Debug handler for combat events
--- @param eventCode number Event code
--- @param result number Combat result
--- @param isError boolean Whether an error occurred
--- @param abilityName string Ability name
--- @param abilityGraphic number Ability graphic
--- @param abilityActionSlotType number Ability action slot type
--- @param sourceName string Source name
--- @param sourceType number Source type
--- @param targetName string Target name
--- @param targetType number Target type
--- @param hitValue number Hit value
--- @param powerType number Power type
--- @param damageType number Damage type
--- @param log boolean Log flag
--- @param sourceUnitId number Source unit ID
--- @param targetUnitId number Target unit ID
--- @param abilityId number Ability ID
--- @param overrideRank number Override rank
--- @param casterUnitTag string Caster unit tag
function SpellCastBuffs.EventCombatDebug(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overrideRank, casterUnitTag)
    -- Skip if this aura is filtered
    if LuiData.Data.DebugAuras[abilityId] and SpellCastBuffs.SV.ShowDebugFilter then
        return
    end

    -- Format source and target names
    local source = FormatActorName(sourceName)
    local target = FormatActorName(targetName)

    -- Get ability information
    local duration = GetAbilityDuration(abilityId, overrideRank, casterUnitTag) or 0
    local channeled, durationValue = GetAbilityCastInfo(abilityId, overrideRank, casterUnitTag)
    local castInfo =
    {
        channeled = channeled,
        duration = durationValue
    }

    -- Generate and send debug message
    local message = GenerateCombatDebugMessage(abilityId, source, target, duration, castInfo, result)
    SendDebugMessage(message, false)
end

--- Debug handler for effect events
--- @param eventCode number Event code
--- @param changeType number Change type
--- @param effectSlot number Effect slot
--- @param effectName string Effect name
--- @param unitTag string Unit tag
--- @param beginTime number Begin time
--- @param endTime number End time
--- @param stackCount number Stack count
--- @param iconName string Icon name
--- @param buffType number Buff type
--- @param effectType number Effect type
--- @param abilityType number Ability type
--- @param statusEffectType number Status effect type
--- @param unitName string Unit name
--- @param unitId number Unit ID
--- @param abilityId number Ability ID
--- @param castByPlayer boolean Whether cast by player
function SpellCastBuffs.EventEffectDebug(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer)
    -- Skip if this aura is filtered
    if LuiData.Data.DebugAuras[abilityId] and SpellCastBuffs.SV.ShowDebugFilter then
        return
    end

    -- Format unit name
    local formattedUnitName = FormatActorName(unitName)

    -- Calculate duration
    local duration = (endTime - beginTime) * 1000

    -- Check if effect is hidden
    local isHidden = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].hide

    -- Generate and send debug message
    local message = GenerateEffectDebugMessage(changeType, abilityId, formattedUnitName, unitTag, duration, isHidden)
    SendDebugMessage(message, false)
end

--- Author-specific debug handler for combat events (ArtOfShred only)
--- @param eventCode number Event code
--- @param result number Combat result
--- @param isError boolean Whether an error occurred
--- @param abilityName string Ability name
--- @param abilityGraphic number Ability graphic
--- @param abilityActionSlotType number Ability action slot type
--- @param sourceName string Source name
--- @param sourceType number Source type
--- @param targetName string Target name
--- @param targetType number Target type
--- @param hitValue number Hit value
--- @param powerType number Power type
--- @param damageType number Damage type
--- @param log boolean Log flag
--- @param sourceUnitId number Source unit ID
--- @param targetUnitId number Target unit ID
--- @param abilityId number Ability ID
function SpellCastBuffs.AuthorCombatDebug(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    -- Skip if not a hidden effect
    if not (Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].hide) then
        return
    end

    -- Format source and target names
    local source = FormatActorName(sourceName)
    local target = FormatActorName(targetName)

    -- Format ability information
    local iconFormatted, nameFormatted = FormatAbilityInfo(abilityId)
    local cmxHiddenStatus = GetCMXHiddenStatus(abilityId)
    local formattedResult = LuiData.Data.DebugResults[result]

    -- Generate debug message
    local message = string_format("%s[%d] %s: HIDDEN LUI%s: [S] %s --> [T] %s [R] %s",
        iconFormatted, abilityId, nameFormatted, cmxHiddenStatus, source, target, formattedResult)

    -- Send to system chat windows
    SendDebugMessage(message, true)
end

--- Author-specific debug handler for effect events (ArtOfShred only)
--- @param eventCode number Event code
--- @param changeType number Change type
--- @param effectSlot number Effect slot
--- @param effectName string Effect name
--- @param unitTag string Unit tag
--- @param beginTime number Begin time
--- @param endTime number End time
--- @param stackCount number Stack count
--- @param iconName string Icon name
--- @param buffType number Buff type
--- @param effectType number Effect type
--- @param abilityType number Ability type
--- @param statusEffectType number Status effect type
--- @param unitName string Unit name
--- @param unitId number Unit ID
--- @param abilityId number Ability ID
--- @param castByPlayer boolean Whether cast by player
function SpellCastBuffs.AuthorEffectDebug(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer)
    -- Skip if not a hidden effect
    if not (Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].hide) then
        return
    end

    -- Format unit name
    local formattedUnitName = FormatActorName(unitName)
    formattedUnitName = formattedUnitName .. " (" .. unitTag .. ")"

    -- Format ability information
    local iconFormatted, nameFormatted = FormatAbilityInfo(abilityId)
    local cmxHiddenStatus = GetCMXHiddenStatus(abilityId)
    local refreshOnly = GetRefreshOnlyStatus(abilityId)

    -- Generate debug message
    local message = string_format("%s%s%s [%d] %s: HIDDEN LUI%s: [Tag] %s%s",
        iconFormatted, refreshOnly, DebugFormatConfig.hiddenColor, abilityId,
        nameFormatted, cmxHiddenStatus, formattedUnitName, "|r")

    -- Send to system chat windows
    SendDebugMessage(message, true)
end

-- -----------------------------------------------------------------------------
-- Map and Zone Information
-- -----------------------------------------------------------------------------

--- Collects and returns zone and map information
--- @return table Information about current zone and map
local function CollectZoneMapInfo()
    -- Set map to player location and handle callback
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        LUIE.callbackObject:FireCallbacks("OnWorldMapChanged")
    end

    -- Get basic zone and map info
    local zoneid = GetZoneId(GetCurrentMapZoneIndex())
    local locName = GetPlayerLocationName()
    local mapid = GetCurrentMapId()
    local mapindex = GetCurrentMapIndex()
    local name, mapType, mapContentType, zoneIndex, description = GetMapInfoById(mapid)

    -- Get coordinates at different map levels
    local mapX, mapY = GetMapPlayerPosition("player")
    local zoneX, zoneY = mapX, mapY
    local worldX, worldY = mapX, mapY
    local mapName = GetMapName()
    local zoneName = mapName

    -- Handle dungeon/subzone cases
    if GetMapContentType() == MAP_CONTENT_DUNGEON or GetMapType() == MAPTYPE_SUBZONE then
        MapZoomOut()
        zoneName = GetMapName()
        zoneX, zoneY = GetMapPlayerPosition("player")
    end

    -- Get world coordinates (except for Coldharbour)
    if not (mapindex == 23 or GetCurrentMapIndex() == 23) then
        SetMapToMapListIndex(1) -- Tamriel
        worldX, worldY = GetMapPlayerPosition("player")
    end

    -- Reset map to player location
    if SetMapToPlayerLocation() == SET_MAP_RESULT_MAP_CHANGED then
        LUIE.callbackObject:FireCallbacks("OnWorldMapChanged")
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
        { "--------------------" },
        { "ZONE & MAP INFO:" },
        { "--------------------" },
        { "Zone Id:",            info.zoneid },
        { "Location Name:",      info.locName },
        { "--------------------" },
        { "Map Id:",             info.mapid },
        { "Map Index:",          info.mapindex or "nil" },
        { "--------------------" },
        { "GPS Coordinates:" },
        { "Map:",                string_format("%s: %s\195\151%s", info.mapName, FormatCoords(info.mapX), FormatCoords(info.mapY)) },
        { "Zone:",               string_format("%s: %s\195\151%s", info.zoneName, FormatCoords(info.zoneX), FormatCoords(info.zoneY)) },
        { "World:",              string_format("Tamriel: %s\195\151%s", FormatCoords(info.worldX), FormatCoords(info.worldY)) },
        { "--------------------" },
        { "Map Name:",           info.name },
        { "Map Type:",           info.mapType },
        { "Map Content Type:",   info.mapContentType },
        { "Zone Index:",         info.zoneIndex },
        { "Description:",        info.description },
        { "--------------------" },
    }

    for _, v in ipairs(displayInfo) do
        AddSystemMessage(#v == 1 and v[1] or string_format("%s %s", v[1], v[2]))
    end
end

--- Checks for removed abilities by iterating through LuiData.Data.DebugAuras and checking if each ability still exists.
--- Outputs a list of ability IDs that no longer exist in the game to chat.
function SpellCastBuffs.TempSlashCheckRemovedAbilities()
    AddSystemMessage("Removed AbilityIds:")
    for abilityId in pairs(LuiData.Data.DebugAuras) do
        if not DoesAbilityExist(abilityId) then
            AddSystemMessage(tostring(abilityId))
        end
    end
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
