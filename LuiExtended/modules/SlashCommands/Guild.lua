-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.SlashCommands
local SlashCommands = LUIE.SlashCommands

local ChatOutput = LUIE.ChatOutput
local zo_strformat = zo_strformat

local pairs = pairs

-- Slash Command to invite someone to a guild
function SlashCommands.SlashGuildInvite(option)
    -- If no input was entered, display an error and end.
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_INV), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_INV)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Parse input
    local options = {}
    local searchResult = { zo_strmatch(option, "^(%S*)%s*(.-)$") }
    for i, v in pairs(searchResult) do
        if v ~= nil and v ~= "" then
            options[i] = v
        end
    end

    local guildnumber = options[1]
    local name = options[2]

    -- If no name was entered, display an error and end.
    if guildnumber == nil or name == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_INV), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_INV)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    if guildnumber == "1" and LUIE.GuildIndexData[1] then
        guildnumber = LUIE.GuildIndexData[1].id
    elseif guildnumber == "2" and LUIE.GuildIndexData[2] then
        guildnumber = LUIE.GuildIndexData[2].id
    elseif guildnumber == "3" and LUIE.GuildIndexData[3] then
        guildnumber = LUIE.GuildIndexData[3].id
    elseif guildnumber == "4" and LUIE.GuildIndexData[4] then
        guildnumber = LUIE.GuildIndexData[4].id
    elseif guildnumber == "5" and LUIE.GuildIndexData[5] then
        guildnumber = LUIE.GuildIndexData[5].id
    else -- If we enter anything outside of the range of 1-5, display an error and end.
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_INV), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_INV)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    ZO_TryGuildInvite(guildnumber, name)
end

-- Slash Command to leave a guild
function SlashCommands.SlashGuildQuit(guildnumber)
    if guildnumber == "1" and LUIE.GuildIndexData[1] then
        guildnumber = LUIE.GuildIndexData[1].id
    elseif guildnumber == "2" and LUIE.GuildIndexData[2] then
        guildnumber = LUIE.GuildIndexData[2].id
    elseif guildnumber == "3" and LUIE.GuildIndexData[3] then
        guildnumber = LUIE.GuildIndexData[3].id
    elseif guildnumber == "4" and LUIE.GuildIndexData[4] then
        guildnumber = LUIE.GuildIndexData[4].id
    elseif guildnumber == "5" and LUIE.GuildIndexData[5] then
        guildnumber = LUIE.GuildIndexData[5].id
    else
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILD_LEAVE), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILD_LEAVE)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- If we try to leave a guild we don't have display an error and end.
    if guildnumber == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILD_LEAVE), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILD_LEAVE)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- If neither of the above errors were triggered, leave the guild number.
    GuildLeave(guildnumber)
end

-- Slash Command to kick someone from a guild
function SlashCommands.SlashGuildKick(option)
    -- If no input was entered, display an error and end.
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_KICK), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_KICK)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Parse input
    local options = {}
    local searchResult = { zo_strmatch(option, "^(%S*)%s*(.-)$") }
    for i, v in pairs(searchResult) do
        if v ~= nil and v ~= "" then
            options[i] = v
        end
    end

    local guildnumber = options[1]
    local name = options[2]

    -- If no name was entered, display an error and end.
    if guildnumber == nil or name == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_KICK), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_KICK)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    if guildnumber == "1" and LUIE.GuildIndexData[1] then
        guildnumber = LUIE.GuildIndexData[1].id
    elseif guildnumber == "2" and LUIE.GuildIndexData[2] then
        guildnumber = LUIE.GuildIndexData[2].id
    elseif guildnumber == "3" and LUIE.GuildIndexData[3] then
        guildnumber = LUIE.GuildIndexData[3].id
    elseif guildnumber == "4" and LUIE.GuildIndexData[4] then
        guildnumber = LUIE.GuildIndexData[4].id
    elseif guildnumber == "5" and LUIE.GuildIndexData[5] then
        guildnumber = LUIE.GuildIndexData[5].id
        -- If we enter anything outside of the range of 1-5, display an error and end.
    else
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_KICK), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDGUILDACC_KICK)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    if not DoesPlayerHaveGuildPermission(guildnumber, GUILD_PERMISSION_REMOVE) then
        ChatOutput:Print(GetString(SI_SOCIALACTIONRESULT18), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(SI_SOCIALACTIONRESULT18)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Index guild members so we can use character name as a kick option
    local guildNumbers = GetNumGuildMembers(guildnumber)
    local compareChar = zo_strlower(name)

    local g_guildNamesTable = {}

    for i = 1, guildNumbers do
        local displayName = GetGuildMemberInfo(guildnumber, i)
        local _, characterName = GetGuildMemberCharacterInfo(guildnumber, i)
        local compareDisplay = zo_strlower(displayName)
        local compareCharacter = zo_strlower(characterName)

        compareCharacter = StringOnlyGSUB(compareCharacter, "%^%a+", "")

        g_guildNamesTable[i] =
        {
            displayName = displayName,
            characterName = characterName,
            compareDisplay = compareDisplay,
            compareCharacter = compareCharacter,
        }
        -- d(compareDisplay .. compareCharacter)
        -- d("comparing vs... " .. compareChar)
    end

    local finalName = ""

    for i = 1, #g_guildNamesTable do
        local comparing = g_guildNamesTable[i]
        if comparing.compareDisplay == compareChar or comparing.compareCharacter == compareChar then
            finalName = comparing.displayName
            break
        end
    end

    if finalName ~= "" then
        GuildRemove(guildnumber, finalName)
    else
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDNAME_GUILD), true)
        if LUIE.ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDNAME_GUILD)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
end
