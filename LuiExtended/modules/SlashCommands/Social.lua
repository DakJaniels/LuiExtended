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

-- Slash Command to add someone to the friendslist
function SlashCommands.SlashFriend(option)
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_FRIEND_FAILED_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_FRIEND_FAILED_NONAME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    ZO_Dialogs_ShowDialog("REQUEST_FRIEND", { name = option })
end

-- Slash Command to add someone to ignore list
function SlashCommands.SlashIgnore(option)
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_NONAME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    AddIgnore(option)
end

-- Slash Command to remove someone from friends list
function SlashCommands.SlashRemoveFriend(option)
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_FRIEND_REMOVE_FAILED_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_FRIEND_REMOVE_FAILED_NONAME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local compareChar = zo_strlower(option)
    local friends = GetNumFriends()
    local g_friendIndex = {}
    for i = 1, friends do
        local displayName = GetFriendInfo(i)
        local _, characterName = GetFriendCharacterInfo(i)
        local compareDisplay = zo_strlower(displayName)
        local compareCharacter = zo_strlower(characterName)
        compareCharacter = StringOnlyGSUB(compareCharacter, "%^%a+", "")
        g_friendIndex[i] =
        {
            displayName = displayName,
            characterName = characterName,
            compareDisplay = compareDisplay,
            compareCharacter = compareCharacter,
        }
    end

    local finalName = ""

    for i = 1, #g_friendIndex do
        local comparing = g_friendIndex[i]
        if comparing.compareDisplay == compareChar or comparing.compareCharacter == compareChar then
            finalName = comparing.displayName
            break
        end
    end

    if finalName ~= "" then
        RemoveFriend(finalName)
    else
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_FRIEND_REMOVE_FAILED_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_FRIEND_REMOVE_FAILED_NONAME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end
end

-- Slash Command to remove a given name from the ignore list
function SlashCommands.SlashRemoveIgnore(option)
    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_NONAME_REMOVE), true)
        if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_NONAME_REMOVE)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local compareChar = zo_strlower(option)
    local ignore = GetNumIgnored()
    local g_ignoreIndex = {}
    for i = 1, ignore do
        local displayName = GetIgnoredInfo(i)
        displayName = zo_strlower(displayName)
        g_ignoreIndex[i] = { displayName = displayName }
    end

    local finalName = ""

    for i = 1, #g_ignoreIndex do
        local comparing = g_ignoreIndex[i]
        if comparing.displayName == compareChar then
            finalName = comparing.displayName
            break
        end
    end

    if finalName ~= "" then
        RemoveIgnore(option)
    else
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_NONAME_REMOVE), true)
        if LUIE.ChatAnnouncements.SV.Social.FriendIgnoreAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_IGNORE_FAILED_NONAME_REMOVE)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
end
