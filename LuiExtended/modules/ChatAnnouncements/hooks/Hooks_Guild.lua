-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements hook shared context (CSA / alerts)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State
local I = ChatAnnouncements.Internal
local B = ChatAnnouncements.Brackets
local ColorizeColors = ChatAnnouncements.Colors
local Data = LuiData.Data
local Quests = Data.Quests
local ChatOutput = LUIE.ChatOutput
local string_format = string.format
local table_insert = table.insert
local windowManager = GetWindowManager()

local guildEventManager = GetEventManager()
local guildModuleName = LUIE.name .. "ChatAnnouncements"

local GUILD_MAIL_INCOMING_SUPPRESS_MS = 3000

local function FormatGuildMailSubject(subject)
    if subject == "" then
        return GetString(SI_MAIL_READ_NO_SUBJECT)
    end
    return subject
end

local function IsGuildMailVisibleToPlayer(guildMailId)
    if MAIL_MANAGER and MAIL_MANAGER.HasDeletedGuildMail and MAIL_MANAGER:HasDeletedGuildMail(guildMailId) then
        return false
    end
    return true
end

local function QueueGuildMailReceivedNotification(message)
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "NOTIFICATION", isSystem = true }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    guildEventManager:RegisterForUpdate(guildModuleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
end

local function FormatGuildMailRankEntry(guildId, rankIndex, guildColor, forAlert)
    local rankName = GetFinalGuildRankName(guildId, rankIndex)
    if ChatAnnouncements.SV.Social.GuildIcon then
        local icon = GetFinalGuildRankTextureSmall(guildId, rankIndex)
        if forAlert then
            return zo_iconTextFormat(icon, "100%", "100%", rankName)
        end
        return guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankName))
    end
    if forAlert then
        return rankName
    end
    return guildColor:Colorize(rankName)
end

local function FormatGuildMailTargetRanks(guildId, rankIds, forAlert)
    if not rankIds or #rankIds == 0 then
        return GetString(SI_GUILD_MAIL_MANAGEMENT_RANKS_DROPDOWN_NO_SELECTION_TEXT)
    end

    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize

    local labels = {}
    for _, rankId in ipairs(rankIds) do
        local rankIndex = GetGuildRankIndex(guildId, rankId)
        if rankIndex then
            table_insert(labels, FormatGuildMailRankEntry(guildId, rankIndex, guildColor, forAlert))
        end
    end
    if #labels > 0 then
        return ZO_GenerateCommaSeparatedListWithoutAnd(labels)
    end
    return GetString(SI_GUILD_MAIL_MANAGEMENT_RANKS_DROPDOWN_NO_SELECTION_TEXT)
end

local function AppendGuildMailSentDetails(messageCA, messageAlert, guildId, rankIds)
    local ranksCA = FormatGuildMailTargetRanks(guildId, rankIds, false)
    local ranksAlert = FormatGuildMailTargetRanks(guildId, rankIds, true)
    messageCA = messageCA .. " " .. zo_strformat(GetString(LUIE_STRING_CA_GUILD_MAIL_SENT_TO), ranksCA)
    messageAlert = messageAlert .. "\n" .. zo_strformat(GetString(LUIE_STRING_CA_GUILD_MAIL_SENT_TO), ranksAlert)
    if GetNumActiveGuildMailsForGuild and MAX_GUILD_MAIL_PER_GUILD then
        local numActive = GetNumActiveGuildMailsForGuild(guildId)
        local activeLine = zo_strformat(GetString(LUIE_STRING_CA_GUILD_MAIL_SENT_ACTIVE), numActive, MAX_GUILD_MAIL_PER_GUILD)
        messageCA = messageCA .. " " .. activeLine
        messageAlert = messageAlert .. "\n" .. activeLine
    end
    return messageCA, messageAlert
end

local function GetGuildFormattedNames(guildId)
    return ChatAnnouncements.FormatGuildLabelForChat(guildId), ChatAnnouncements.FormatGuildLabelForAlert(guildId)
end

local function QueueGuildManageNotification(message)
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "NOTIFICATION", isSystem = true }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    guildEventManager:RegisterForUpdate(guildModuleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
end

local function EmitGuildManageSuccess(social, messageCA, messageAlert, sound)
    if social.GuildManageCA then
        QueueGuildManageNotification(messageCA)
    end
    if social.GuildManageAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, sound, messageAlert or messageCA)
    else
        PlaySound(sound)
    end
end

local function EmitGuildManageError(social, message)
    if social.GuildManageCA then
        QueueGuildManageNotification(message)
    end
    if social.GuildManageAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.GENERAL_ALERT_ERROR, message)
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
end

local function GuildMailIdIterator(_, previousMailId)
    if GetNextValidGuildMailId then
        return GetNextValidGuildMailId(previousMailId)
    end
end

function ChatAnnouncements.OnGuildMailUpdate()
    if not GetNextValidGuildMailId or not IsValidGuildMail then
        return
    end

    local newMailIds = {}
    for guildMailId in GuildMailIdIterator do
        if IsGuildMailVisibleToPlayer(guildMailId) and IsValidGuildMail(guildMailId) then
            local key = zo_getSafeId64Key(guildMailId)
            if not S.knownGuildMailIds[key] then
                S.knownGuildMailIds[key] = true
                if S.g_guildMailIdsSeeded then
                    table_insert(newMailIds, guildMailId)
                end
            end
        end
    end

    if not S.g_guildMailIdsSeeded then
        S.g_guildMailIdsSeeded = true
        return
    end

    if GetGameTimeMilliseconds() < S.guildMailIncomingSuppressUntilMs then
        return
    end

    local notify = ChatAnnouncements.SV.Notify
    if not (ChatAnnouncements.Enabled and (notify.NotificationMailSendCA or notify.NotificationMailSendAlert)) then
        return
    end

    for _, guildMailId in ipairs(newMailIds) do
        local guildId, subject = GetGuildMailItemInfo(guildMailId)
        subject = FormatGuildMailSubject(subject)
        local guildLabel = zo_strformat(SI_GUILD_MAIL_SENDER_FORMATTER, GetGuildName(guildId))
        local message = zo_strformat(GetString(LUIE_STRING_CA_GUILD_MAIL_RECEIVED), guildLabel, subject)
        if notify.NotificationMailSendCA then
            QueueGuildMailReceivedNotification(message)
        end
        if notify.NotificationMailSendAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
    end
end

function ChatAnnouncements.RegisterGuildEvents()
    -- TODO: Possibly implement conditionals here again in the future
    guildEventManager:RegisterForEvent(guildModuleName, EVENT_GUILD_SELF_JOINED_GUILD, ChatAnnouncements.GuildAddedSelf)
    guildEventManager:RegisterForEvent(guildModuleName, EVENT_GUILD_INVITE_ADDED, ChatAnnouncements.GuildInviteAdded)
    guildEventManager:RegisterForEvent(guildModuleName, EVENT_GUILD_MEMBER_RANK_CHANGED, ChatAnnouncements.GuildRankChanged)
    guildEventManager:RegisterForEvent(guildModuleName, EVENT_HERALDRY_SAVED, ChatAnnouncements.GuildHeraldrySaved) -- TODO: Fix later
    guildEventManager:RegisterForEvent(guildModuleName, EVENT_GUILD_RANKS_CHANGED, ChatAnnouncements.GuildRanksSaved)
    guildEventManager:RegisterForEvent(guildModuleName, EVENT_GUILD_RANK_CHANGED, ChatAnnouncements.GuildRankSaved)
    guildEventManager:RegisterForEvent(guildModuleName, EVENT_GUILD_DESCRIPTION_CHANGED, ChatAnnouncements.GuildTextChanged)
    guildEventManager:RegisterForEvent(guildModuleName, EVENT_GUILD_MOTD_CHANGED, ChatAnnouncements.GuildTextChanged)
    if EVENT_GUILD_MAIL_UPDATE then
        guildEventManager:RegisterForEvent(guildModuleName, EVENT_GUILD_MAIL_UPDATE, ChatAnnouncements.OnGuildMailUpdate)
    end
end

function ChatAnnouncements.GuildHeraldrySaved()
    if ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        local value = S.g_pendingHeraldryCost > 0 and S.g_pendingHeraldryCost or 1000
        local type = "LUIE_CURRENCY_HERALDRY"
        local formattedValue = nil -- Un-needed, we're not going to try to show the total guild bank gold here.
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(value)
        local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and "|t16:16:/esoui/art/currency/currency_gold.dds|t" or ""
        local currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyGoldName"), value)
        local currencyTotal = nil
        local messageTotal = ""
        local messageChange = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_HERALDRY)
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
    end

    local id = S.g_heraldrySaveGuildId or S.g_selectedGuild
    if id ~= nil then
        local guildName = GetGuildName(id)

        local guildAlliance = GetGuildAlliance(id)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if ChatAnnouncements.SV.Social.GuildManageCA then
            local finalMessage = zo_strformat(GetString(LUIE_STRING_CA_GUILD_HERALDRY_UPDATE), guildNameAlliance)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            guildEventManager:RegisterForUpdate(guildModuleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end
        if ChatAnnouncements.SV.Social.GuildManageAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_HERALDRY_UPDATE), guildNameAllianceAlert))
        end
    end
    S.g_heraldrySaveGuildId = nil
end

--- @param eventId integer
--- @param guildId integer
function ChatAnnouncements.GuildRanksSaved(eventId, guildId)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

    if ChatAnnouncements.SV.Social.GuildManageCA then
        local finalMessage = zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANKS_UPDATE), guildNameAlliance)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "NOTIFICATION", isSystem = true }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        guildEventManager:RegisterForUpdate(guildModuleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
    end
    if ChatAnnouncements.SV.Social.GuildManageAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANKS_UPDATE), guildNameAllianceAlert))
    end
end

--- @param eventId integer
--- @param guildId integer
--- @param rankIndex integer
function ChatAnnouncements.GuildRankSaved(eventId, guildId, rankIndex)
    local rankName
    local rankNameDefault = GetDefaultGuildRankName(guildId, rankIndex)
    local rankNameCustom = GetGuildRankCustomName(guildId, rankIndex)

    if rankNameCustom == "" then
        rankName = rankNameDefault
    else
        rankName = rankNameCustom
    end

    local icon = GetGuildRankIconIndex(guildId, rankIndex)
    local icon1 = GetGuildRankLargeIcon(icon)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon1, 16, 16), rankName)) or (guildColor:Colorize(rankName))
    local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon1, "100%", "100%", rankName) or rankName

    if ChatAnnouncements.SV.Social.GuildManageCA then
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UPDATE), rankSyntax, guildNameAlliance), true)
    end
    if ChatAnnouncements.SV.Social.GuildManageAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UPDATE), rankSyntaxAlert, guildNameAllianceAlert))
    end
end

--- @param eventId integer
--- @param guildId integer
function ChatAnnouncements.GuildTextChanged(eventId, guildId)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    -- Depending on event code set message context.
    local messageString = eventId == EVENT_GUILD_DESCRIPTION_CHANGED and LUIE_STRING_CA_GUILD_DESCRIPTION_CHANGED or EVENT_GUILD_MOTD_CHANGED and LUIE_STRING_CA_GUILD_MOTD_CHANGED or nil

    if messageString ~= nil then
        if ChatAnnouncements.SV.Social.GuildManageCA then
            local finalMessage = zo_strformat(GetString(messageString), guildNameAlliance)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            guildEventManager:RegisterForUpdate(guildModuleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end
        if ChatAnnouncements.SV.Social.GuildManageAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(messageString), guildNameAllianceAlert))
        end
    end
end

--- @param eventId integer
--- @param guildId integer
--- @param displayName string
--- @param newRank integer
function ChatAnnouncements.GuildRankChanged(eventId, guildId, displayName, newRank)
    -- Don't show this for the player since EVENT_GUILD_PLAYER_RANK_CHANGED will handle that
    if displayName == LUIE.PlayerDisplayName then
        return
    end
    -- If the player just updated someones rank then we hide this generic message.
    if S.g_disableRankMessage == true then
        S.g_disableRankMessage = false
        return
    end

    local memberIndex = GetPlayerGuildMemberIndex(guildId)
    local rankIndex = select(3, GetGuildMemberInfo(guildId, memberIndex))

    local hasPermission1 = DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_PROMOTE)
    local hasPermission2 = DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_DEMOTE)

    if ((hasPermission1 or hasPermission2) and ChatAnnouncements.SV.Social.GuildRankDisplayOptions == 2) or (ChatAnnouncements.SV.Social.GuildRankDisplayOptions == 3) then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        local rankText = GetFinalGuildRankName(guildId, newRank)

        local icon = GetFinalGuildRankTextureSmall(guildId, newRank)
        local guildName = GetGuildName(guildId)

        local guilds = GetNumGuilds()
        for i = 1, guilds do
            local id = GetGuildId(i)
            local name = GetGuildName(id)

            local guildAlliance = GetGuildAlliance(id)
            local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
            local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
            local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
            local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
            local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

            if guildName == name then
                if ChatAnnouncements.SV.Social.GuildRankCA then
                    ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED), displayNameLink, guildNameAlliance, rankSyntax), true)
                end
                if ChatAnnouncements.SV.Social.GuildRankAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED), displayName, guildNameAllianceAlert, rankSyntaxAlert))
                end
                break
            end
        end
    end
end

--- @param eventId integer
--- @param guildId integer
--- @param rankIndex integer
--- @param guildRankChangeAction GuildRankChangeAction
function ChatAnnouncements.GuildPlayerRankChanged(eventId, guildId, rankIndex, guildRankChangeAction)
    local rankText = GetFinalGuildRankName(guildId, rankIndex)
    local icon = GetFinalGuildRankTextureSmall(guildId, rankIndex)
    local guildName = GetGuildName(guildId)

    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
    local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

    local syntax
    if guildRankChangeAction == GUILD_RANK_CHANGE_ACTION_PROMOTE then
        if ChatAnnouncements.SV.Social.GuildRankCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UP_SELF), rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UP_SELF), rankSyntaxAlert, guildNameAllianceAlert))
        end
    elseif guildRankChangeAction == GUILD_RANK_CHANGE_ACTION_DEMOTE then
        if ChatAnnouncements.SV.Social.GuildRankCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_DOWN_SELF), rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_DOWN_SELF), rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
end

--- @param eventId integer
--- @param displayName string
--- @param newRankIndex integer
--- @param guildId integer
function ChatAnnouncements.GuildMemberPromoteSuccessful(eventId, displayName, newRankIndex, guildId)
    if newRankIndex > 0 then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        local rankText = GetFinalGuildRankName(guildId, newRankIndex)
        local icon = GetFinalGuildRankTextureSmall(guildId, newRankIndex)
        local guildName = GetGuildName(guildId)

        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
        local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
        local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

        if ChatAnnouncements.SV.Social.GuildRankCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_PROMOTE), displayNameLink, rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_PROMOTE), displayName, rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
    S.g_disableRankMessage = true
end

--- @param eventId integer
--- @param displayName string
--- @param newRankIndex integer
--- @param guildId integer
function ChatAnnouncements.GuildMemberDemoteSuccessful(eventId, displayName, newRankIndex, guildId)
    if newRankIndex <= GetNumGuildRanks(guildId) then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        local rankText = GetFinalGuildRankName(guildId, newRankIndex)
        local icon = GetFinalGuildRankTextureSmall(guildId, newRankIndex)
        local guildName = GetGuildName(guildId)

        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
        local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
        local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

        if ChatAnnouncements.SV.Social.GuildRankCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_DEMOTE), displayNameLink, rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_DEMOTE), displayName, rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
    S.g_disableRankMessage = true
end

-- EVENT_GUILD_SELF_JOINED_GUILD
--- @param eventId integer
--- @param guildId integer
--- @param guildName string
function ChatAnnouncements.GuildAddedSelf(eventId, guildId, guildName)
    local guilds = GetNumGuilds()
    for i = 1, guilds do
        local id = GetGuildId(i)
        local name = GetGuildName(id)

        local guildAlliance = GetGuildAlliance(id)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if guildName == name then
            if ChatAnnouncements.SV.Social.GuildCA then
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_JOIN_SELF), guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_JOIN_SELF), guildNameAllianceAlert))
            end
            break
        end
    end
end

-- EVENT_GUILD_INVITE_ADDED
--- @param eventId integer
--- @param guildId integer
--- @param guildName string
--- @param guildAlliance Alliance
--- @param inviterName string
function ChatAnnouncements.GuildInviteAdded(eventId, guildId, guildName, guildAlliance, inviterName)
    local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(inviterName, inviterName)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    if ChatAnnouncements.SV.Social.GuildCA then
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), displayNameLink, guildNameAlliance), true)
    end
    if ChatAnnouncements.SV.Social.GuildAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), inviterName, guildNameAllianceAlert))
    end
end

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterGuild(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler

    SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_GUILD_REQUEST, GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), 1)
    SafeAddString(SI_GUILD_INVITE_MESSAGE, GetString(LUIE_STRING_CA_GUILD_INVITE_MESSAGE), 3)

    -- EVENT_GUILD_SELF_LEFT_GUILD (Alert Handler)
    local function GuildSelfLeftAlert(guildId, guildName)
        local GuildIndexData = LUIE.GuildIndexData
        for i = 1, 5 do
            local guild = GuildIndexData[i]
            if guild.name == guildName then
                local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guild.guildAlliance) or ColorizeColors.GuildColorize
                local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guild.guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
                local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guild.guildAlliance), "100%", "100%", guildName) or guildName
                local messageString = (ShouldDisplaySelfKickedFromGuildAlert(guildId)) and SI_GUILD_SELF_KICKED_FROM_GUILD or LUIE_STRING_CA_GUILD_LEAVE_SELF
                local sound = (ShouldDisplaySelfKickedFromGuildAlert(guildId)) and SOUNDS.GENERAL_ALERT_ERROR or SOUNDS.GUILD_SELF_LEFT
                if ChatAnnouncements.SV.Social.GuildCA then
                    ChatOutput:Print(zo_strformat(GetString(messageString), guildNameAlliance), true)
                end
                if ChatAnnouncements.SV.Social.GuildAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(messageString), guildNameAllianceAlert))
                end
                PlaySound(sound)
                break
            end
        end

        return true
    end

    -- EVENT_SAVE_GUILD_RANKS_RESPONSE (Alert Handler)
    local function GuildRanksResponseAlert(guildId, result)
        if result ~= SOCIAL_RESULT_NO_ERROR then
            if ChatAnnouncements.SV.Social.GuildCA then
                ChatOutput:Print(GetString("SI_SOCIALACTIONRESULT", result), true)
            elseif ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString("SI_SOCIALACTIONRESULT", result))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        return true
    end

    ZO_PreHook(alertHandlers, EVENT_GUILD_SELF_LEFT_GUILD, GuildSelfLeftAlert)
    ZO_PreHook(alertHandlers, EVENT_SAVE_GUILD_RANKS_RESPONSE, GuildRanksResponseAlert)

    -- Hook for EVENT_GUILD_MEMBER_ADDED
    --- @diagnostic disable-next-line: duplicate-set-field
    GUILD_ROSTER_MANAGER.OnGuildMemberAdded = function (self, guildId, displayName)
        self:RefreshData()

        local data = self:FindDataByDisplayName(displayName)
        if data and data.rankId ~= DEFAULT_INVITED_RANK then
            local hasCharacter, rawCharacterName, zone, class, alliance, level, championPoints = GetGuildMemberCharacterInfo(self.guildId, data.index)
            local displayNameLink = ChatAnnouncements.ResolveNameLink(rawCharacterName, displayName)
            local guildName = self.guildName
            local guildAlliance = GetGuildAlliance(guildId)
            local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
            local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
            local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

            if ChatAnnouncements.SV.Social.GuildCA then
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_ADDED), displayNameLink, guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_ADDED), displayName, guildNameAllianceAlert))
            end
            PlaySound(SOUNDS.GUILD_ROSTER_ADDED)
        end
    end

    -- Hook for EVENT_GUILD_MEMBER_REMOVED
    --- @diagnostic disable-next-line: duplicate-set-field
    GUILD_ROSTER_MANAGER.OnGuildMemberRemoved = function (self, guildId, rawCharacterName, displayName)
        local displayNameLink = ChatAnnouncements.ResolveNameLink(rawCharacterName, displayName)
        local guildName = self.guildName
        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if ChatAnnouncements.SV.Social.GuildCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_LEFT), displayNameLink, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_LEFT), displayName, guildNameAllianceAlert))
        end
        PlaySound(SOUNDS.GUILD_ROSTER_REMOVED)

        self:RefreshData()
    end

    local EVENT_NAMESPACE = "GuildRoster"
    -- Unregister ZOS Guild Roster events and replace with our own.
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_PLAYER_RANK_CHANGED)
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL)
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_PLAYER_RANK_CHANGED, ChatAnnouncements.GuildPlayerRankChanged)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL, ChatAnnouncements.GuildMemberPromoteSuccessful)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL, ChatAnnouncements.GuildMemberDemoteSuccessful)

    -- Hook for Guild Invite function used from Guild Menu
    --- @diagnostic disable-next-line: missing-global-doc
    ZO_TryGuildInvite = function (guildId, displayName)
        -- TODO: Update when more alerts are added to CA
        if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_INVITE) then
            ZO_AlertEvent(EVENT_SOCIAL_ERROR, SOCIAL_RESULT_NO_INVITE_PERMISSION)
            return
        end

        -- TODO: Update when more alerts are added to CA
        if GetNumGuildMembers(guildId) == MAX_GUILD_MEMBERS then
            ZO_AlertEvent(EVENT_SOCIAL_ERROR, SOCIAL_RESULT_NO_ROOM)
            return
        end

        local guildName = GetGuildName(guildId)
        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if ZO_IsConsoleOrGameCoreUI() then
            local function GuildInviteCallback(success)
                if success then
                    GuildInvite(guildId, displayName)
                    if ChatAnnouncements.SV.Social.GuildCA then
                        ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, UndecorateDisplayName(displayName), guildNameAlliance), true)
                    end
                    if ChatAnnouncements.SV.Social.GuildAlert then
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, UndecorateDisplayName(displayName), guildNameAllianceAlert))
                    end
                end
            end

            ZO_ConsoleAttemptInteractOrError(GuildInviteCallback, displayName, ZO_PLAYER_CONSOLE_INFO_REQUEST_DONT_BLOCK, ZO_CONSOLE_CAN_COMMUNICATE_ERROR_ALERT, ZO_ID_REQUEST_TYPE_DISPLAY_NAME, displayName)
        else
            -- TODO: This needs fixed in the API so that character names are also factored in here. This check here is just about pointless as it stands.
            if IsIgnored(displayName) then
                if ChatAnnouncements.SV.Social.GuildCA then
                    ChatOutput:Print(GetString(LUIE_STRING_IGNORE_ERROR_GUILD), true)
                end
                if ChatAnnouncements.SV.Social.GuildAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_IGNORE_ERROR_GUILD))
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                return
            end

            GuildInvite(guildId, displayName)
            if ChatAnnouncements.SV.Social.GuildCA then
                ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, displayName, guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, displayName, guildNameAllianceAlert))
            end
        end
    end

    -- Called when changing guilds in the Guild tab
    GUILD_SHARED_INFO.SetGuildId = function (self, guildId)
        self.guildId = guildId
        self:Refresh(guildId)
        -- Set selected guild for use when resolving Rank/Heraldry updates
        S.g_selectedGuild = guildId
    end

    -- Called when changing guilds in the Guild tab or leaving/joining a guild
    GUILD_SHARED_INFO.Refresh = function (self, guildId)
        if self.guildId and self.guildId == guildId then
            local count = GetControl(self.control, "Count")
            local numGuildMembers, numOnline = GetGuildInfo(guildId)
            if count then
                count:SetText(zo_strformat(SI_GUILD_NUM_MEMBERS_ONLINE_FORMAT, numOnline, numGuildMembers))
            end
            self.canDepositToBank = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT)
            if self.canDepositToBank then
                self.bankIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.bankIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end

            self.canUseTradingHouse = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE)
            if self.canUseTradingHouse then
                self.tradingHouseIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.tradingHouseIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end

            self.canUseHeraldry = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_HERALDRY)
            if self.canUseHeraldry then
                self.heraldryIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.heraldryIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end
        end
        -- Set selected guild for use when resolving Rank/Heraldry updates
        S.g_selectedGuild = guildId
    end

    -- Used to pull the cost of guild Heraldry change
    local orig_ConfirmHeraldryApplyChanges = ZO_GuildHeraldryManager_Shared.ConfirmHeraldryApplyChanges
    --- @diagnostic disable-next-line: duplicate-set-field
    ZO_GuildHeraldryManager_Shared.ConfirmHeraldryApplyChanges = function (self, control, showDialogFunc)
        S.g_heraldrySaveGuildId = self.guildId
        return orig_ConfirmHeraldryApplyChanges(self, control, showDialogFunc)
    end
    local orig_ConfirmHeraldryPurchase = ZO_GuildHeraldryManager_Shared.ConfirmHeraldryPurchase
    --- @diagnostic disable-next-line: duplicate-set-field
    ZO_GuildHeraldryManager_Shared.ConfirmHeraldryPurchase = function (self, control, showDialogFunc)
        S.g_heraldrySaveGuildId = self.guildId
        return orig_ConfirmHeraldryPurchase(self, control, showDialogFunc)
    end
    --- @diagnostic disable-next-line: duplicate-set-field
    ZO_GuildHeraldryManager_Shared.AttemptSaveAndExit = function (self, showBaseScene)
        local blocked = false

        if HasPendingHeraldryChanges() then
            self:SetPendingExit(true)
            if not IsCreatingHeraldryForFirstTime() then
                local pendingCost = GetPendingHeraldryCost()
                -- Pull Heraldry Cost to currency function to use
                S.g_pendingHeraldryCost = pendingCost
                S.g_heraldrySaveGuildId = self.guildId
                local heraldryFunds = GetHeraldryGuildBankedMoney()
                if heraldryFunds and pendingCost <= heraldryFunds then
                    self:ConfirmHeraldryApplyChanges()
                    blocked = true
                end
            end
        end

        if not blocked then
            self:ConfirmExit(showBaseScene)
        end
    end

    if RequestSendGuildMail then
        local origRequestSendGuildMail = RequestSendGuildMail
        local function CapturePendingGuildMailSend(guildId, subject, message, ...)
            local rankIds = { ... }
            S.pendingGuildMailSend = { guildId = guildId, subject = subject, rankIds = rankIds }
            return origRequestSendGuildMail(guildId, subject, message, ...)
        end
        --- @diagnostic disable-next-line: duplicate-set-field, missing-global-doc
        RequestSendGuildMail = CapturePendingGuildMailSend
    end

    if RequestDeleteGuildMail and GetGuildMailItemInfo then
        local origRequestDeleteGuildMail = RequestDeleteGuildMail
        local function CapturePendingGuildMailDelete(guildMailId)
            if IsValidGuildMail and IsValidGuildMail(guildMailId) then
                local guildId, subject = GetGuildMailItemInfo(guildMailId)
                S.pendingGuildMailDelete = { guildMailId = guildMailId, guildId = guildId, subject = subject }
            else
                S.pendingGuildMailDelete = { guildMailId = guildMailId }
            end
            return origRequestDeleteGuildMail(guildMailId)
        end
        --- @diagnostic disable-next-line: duplicate-set-field, missing-global-doc
        RequestDeleteGuildMail = CapturePendingGuildMailDelete
    end

    if EVENT_CREATE_GUILD_MAIL_RESULT and GUILD_MAIL_RESULT_SUCCESS then
        local function BuildGuildMailSentMessages(guildId, subject, rankIds)
            local guildNameAlliance, guildNameAllianceAlert = GetGuildFormattedNames(guildId)
            subject = FormatGuildMailSubject(subject)
            local messageCA = zo_strformat(GetString(LUIE_STRING_CA_GUILD_MAIL_SENT), guildNameAlliance, subject)
            local messageAlert = zo_strformat(GetString(LUIE_STRING_CA_GUILD_MAIL_SENT), guildNameAllianceAlert, subject)
            return AppendGuildMailSentDetails(messageCA, messageAlert, guildId, rankIds)
        end

        local function BuildGuildMailDeletedMessages(guildId, subject)
            local guildNameAlliance, guildNameAllianceAlert = GetGuildFormattedNames(guildId)
            subject = FormatGuildMailSubject(subject)
            local messageCA = zo_strformat(GetString(LUIE_STRING_CA_GUILD_MAIL_DELETED), guildNameAlliance, subject)
            local messageAlert = zo_strformat(GetString(LUIE_STRING_CA_GUILD_MAIL_DELETED), guildNameAllianceAlert, subject)
            return messageCA, messageAlert
        end

        local function HandleGuildMailerResultAlert(result, operation)
            local social = ChatAnnouncements.SV.Social
            local manageEnabled = ChatAnnouncements.Enabled and (social.GuildManageCA or social.GuildManageAlert)

            if result == GUILD_MAIL_RESULT_SUCCESS then
                if not manageEnabled then
                    S.pendingGuildMailSend = nil
                    S.pendingGuildMailDelete = nil
                    return false
                end
                local messageCA
                local messageAlert
                local sound
                if operation == "create" then
                    local pending = S.pendingGuildMailSend
                    if pending and pending.guildId then
                        messageCA, messageAlert = BuildGuildMailSentMessages(pending.guildId, pending.subject, pending.rankIds)
                    else
                        messageCA = GetString(SI_GUILD_MAIL_MANAGEMENT_MAIL_SENT)
                        messageAlert = messageCA
                    end
                    S.guildMailIncomingSuppressUntilMs = GetGameTimeMilliseconds() + GUILD_MAIL_INCOMING_SUPPRESS_MS
                    sound = SOUNDS.MAIL_SENT
                else
                    local pending = S.pendingGuildMailDelete
                    if pending and pending.guildId then
                        messageCA, messageAlert = BuildGuildMailDeletedMessages(pending.guildId, pending.subject)
                    else
                        messageCA = GetString(SI_GUILD_MAIL_MANAGEMENT_MAIL_DELETED)
                        messageAlert = messageCA
                    end
                    sound = SOUNDS.MAIL_ITEM_DELETED
                end
                S.pendingGuildMailSend = nil
                S.pendingGuildMailDelete = nil
                EmitGuildManageSuccess(social, messageCA, messageAlert, sound)
                return true
            end

            if not manageEnabled then
                S.pendingGuildMailSend = nil
                S.pendingGuildMailDelete = nil
                return false
            end
            local message = GetString("SI_GUILDMAILERRESULT", result)
            S.pendingGuildMailSend = nil
            S.pendingGuildMailDelete = nil
            EmitGuildManageError(social, message)
            return true
        end

        ZO_PreHook(alertHandlers, EVENT_CREATE_GUILD_MAIL_RESULT, function (result)
            return HandleGuildMailerResultAlert(result, "create")
        end)
        ZO_PreHook(alertHandlers, EVENT_DELETE_GUILD_MAIL_RESULT, function (result)
            return HandleGuildMailerResultAlert(result, "delete")
        end)
    end
end
