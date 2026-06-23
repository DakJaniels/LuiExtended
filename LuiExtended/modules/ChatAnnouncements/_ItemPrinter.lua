-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State

local ChatOutput = LUIE.ChatOutput

local string_format = string.format

local eventManager = GetEventManager()

local moduleName = LUIE.name .. "ChatAnnouncements"

local CRAFT_AGGREGATE_TOO_MANY_GAIN = 50
local CRAFT_AGGREGATE_TOO_MANY_LOSS = 100

local PICKPOCKET_LOOT_CONTEXT_MS = 500

local DEFAULT_PRINTER_DELAY_MS = 50
local FAST_PRINTER_DELAY_MS = 25

--- @param message string
--- @param messageType string
--- @param formattedRecipient string
--- @param color string
--- @param logPrefix string
--- @param totalString string
--- @param groupLoot boolean
--- @param guildAnnounceGuildId integer|nil
--- @return CAQueuedItemMessage
local function buildQueuedItemMessage(message, messageType, formattedRecipient, color, logPrefix, totalString, groupLoot, guildAnnounceGuildId)
    return
    {
        message = message,
        type = messageType,
        formattedRecipient = formattedRecipient,
        color = color,
        logPrefix = logPrefix,
        totalString = totalString,
        groupLoot = groupLoot,
        guildAnnounceGuildId = guildAnnounceGuildId,
    }
end

--- @param isGain boolean
--- @param itemString string
--- @param color string
--- @param messageType string
--- @param formattedRecipient string
--- @param logPrefix string
--- @param groupLoot boolean
--- @param guildAnnounceGuildId integer|nil
--- @param delayTimer integer
local function queueCraftAggregatedItem(isGain, itemString, color, messageType, formattedRecipient, logPrefix, groupLoot, guildAnnounceGuildId, delayTimer)
    local aggregatedString
    local tooManyThreshold

    if isGain then
        aggregatedString = S.g_itemStringGain
        tooManyThreshold = CRAFT_AGGREGATE_TOO_MANY_GAIN
    else
        aggregatedString = S.g_itemStringLoss
        tooManyThreshold = CRAFT_AGGREGATE_TOO_MANY_LOSS
    end

    if aggregatedString ~= "" then
        aggregatedString = string_format("%s|c%s,|r %s", aggregatedString, color, itemString)
    else
        aggregatedString = itemString
    end

    if isGain then
        S.g_itemStringGain = aggregatedString
        S.g_itemCounterGainTracker = S.g_itemCounterGainTracker + 1
        if S.g_itemCounterGainTracker > tooManyThreshold then
            S.g_itemStringGain = string_format(GetString(LUIE_STRING_CA_LOOT_TOO_MANY_ITEMS_COLORED), color)
        end
        if S.g_itemCounterGain == 0 then
            S.g_itemCounterGain = ChatAnnouncements.QueuedMessagesCounter
        end
        if ChatAnnouncements.QueuedMessagesCounter - 1 == S.g_itemCounterGain then
            ChatAnnouncements.QueuedMessagesCounter = S.g_itemCounterGain
        end
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        ChatAnnouncements.QueuedMessages[S.g_itemCounterGain] = buildQueuedItemMessage(S.g_itemStringGain, messageType, formattedRecipient, color, logPrefix, "", groupLoot, guildAnnounceGuildId)
    else
        S.g_itemStringLoss = aggregatedString
        S.g_itemCounterLossTracker = S.g_itemCounterLossTracker + 1
        if S.g_itemCounterLossTracker > tooManyThreshold then
            S.g_itemStringLoss = string_format(GetString(LUIE_STRING_CA_LOOT_TOO_MANY_ITEMS_COLORED), color)
        end
        if S.g_itemCounterLoss == 0 then
            S.g_itemCounterLoss = ChatAnnouncements.QueuedMessagesCounter
        end
        if ChatAnnouncements.QueuedMessagesCounter - 1 == S.g_itemCounterLoss then
            ChatAnnouncements.QueuedMessagesCounter = S.g_itemCounterLoss
        end
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        ChatAnnouncements.QueuedMessages[S.g_itemCounterLoss] = buildQueuedItemMessage(S.g_itemStringLoss, messageType, formattedRecipient, color, logPrefix, "", groupLoot, guildAnnounceGuildId)
    end

    eventManager:RegisterForUpdate(moduleName .. "Printer", delayTimer, ChatAnnouncements.PrintQueuedMessages, true)
end

--- @param logPrefix string
--- @return integer|nil guildAnnounceGuildId
local function getGuildAnnounceGuildIdForLogPrefix(logPrefix)
    if ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageDepositGuild") or ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageWithdrawGuild") then
        return S.g_guildBankAnnounceGuildId or ChatAnnouncements.GetActiveGuildBankId()
    end
    return nil
end

--- @param icon string
--- @param stack integer
--- @param itemType ItemType
--- @param itemId integer
--- @param itemLink string
--- @param receivedBy string
--- @param logPrefix string
--- @param gainOrLoss? integer
--- @param filter? boolean
--- @param groupLoot? boolean
--- @param alwaysFirst? boolean
--- @param delay? boolean
--- @param showCollectionStatus? boolean
function ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, filter, groupLoot, alwaysFirst, delay, showCollectionStatus)
    if filter then
        if not ChatAnnouncements.ItemFilter(itemType, itemId, itemLink, false) then
            return
        end
    end

    if icon == nil or stack == nil or itemLink == nil then
        return
    end

    logPrefix = ChatAnnouncements.ResolveLootLogPrefix(logPrefix)

    local itemString, formattedTotal, formattedRecipient, color = ChatAnnouncements.BuildLootItemDisplayString(icon, stack, itemType, itemLink, receivedBy, logPrefix, gainOrLoss, groupLoot, showCollectionStatus)

    local delayTimer = DEFAULT_PRINTER_DELAY_MS
    local messageType = alwaysFirst and "CONTAINER" or "LOOT"
    local guildAnnounceGuildId = getGuildAnnounceGuildIdForLogPrefix(logPrefix)

    if receivedBy == "LUIE_RECEIVE_CRAFT" and (gainOrLoss == 1 or gainOrLoss == 3) and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgradeFail") then
        queueCraftAggregatedItem(true, itemString, color, messageType, formattedRecipient, logPrefix, groupLoot, guildAnnounceGuildId, delayTimer)
    elseif receivedBy == "LUIE_RECEIVE_CRAFT" and (gainOrLoss == 2 or gainOrLoss == 4) and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgradeFail") then
        queueCraftAggregatedItem(false, itemString, color, messageType, formattedRecipient, logPrefix, groupLoot, guildAnnounceGuildId, delayTimer)
    elseif ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageContainer") and alwaysFirst then
        ChatAnnouncements.ResolveItemMessage(itemString, formattedRecipient, color, logPrefix, formattedTotal, groupLoot, guildAnnounceGuildId)
        ChatAnnouncements.FlushDeferredContainerLootCurrency()
    else
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = buildQueuedItemMessage(itemString, messageType, formattedRecipient, color, logPrefix, formattedTotal, groupLoot, guildAnnounceGuildId)
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        if delay then
            delayTimer = FAST_PRINTER_DELAY_MS
        end
        eventManager:RegisterForUpdate(moduleName .. "Printer", delayTimer, ChatAnnouncements.PrintQueuedMessages, true)
    end
end

--- @param message string
--- @param formattedRecipient string
--- @param color string|table|ZO_ColorDef
--- @param logPrefix string
--- @param totalString string
--- @param groupLoot boolean
--- @param guildAnnounceGuildId integer|nil
function ChatAnnouncements.ResolveItemMessage(message, formattedRecipient, color, logPrefix, totalString, groupLoot, guildAnnounceGuildId)
    message = message or ""
    formattedRecipient = formattedRecipient or ""
    -- normalize color to a ZO_ColorDef
    if type(color) == "table" and ZO_ColorDef:IsInstanceOf(color) then
        -- already a ZO_ColorDef; keep as-is
    elseif type(color) == "string" then
        color = ZO_ColorDef:New(color)
    elseif type(color) == "table" then
        -- plain table color {r=..., g=..., b=...}
        color = ZO_ColorDef:New(color)
    else
        color = ZO_ColorDef:New("FFFFFF")
    end
    logPrefix = logPrefix or ""
    totalString = totalString or ""

    if logPrefix == "" then
        logPrefix = ChatAnnouncements.GetContextMessagePrefix() or ""
    else
        logPrefix = ChatAnnouncements.ResolveLogPrefix(logPrefix)
    end

    local formattedMessageP1 = string_format("|r%s|c%s", message, color:ToHex()) or ""
    local formattedMessageP2 = ChatAnnouncements.FormatContextMessage(logPrefix, formattedMessageP1, formattedRecipient, color:ToHex(), groupLoot, guildAnnounceGuildId) or ""

    local finalMessage = string_format("|c%s%s|r%s", color:ToHex(), formattedMessageP2 or "", totalString or "")
    if finalMessage and finalMessage ~= "" then
        ChatOutput:Print(finalMessage)
    end

    ChatAnnouncements.ResetTrackingVariables()
end

function ChatAnnouncements.MarkPickpocketLootContext()
    S.g_isPickpocketed = true

    local function ResetIsPickpocketed()
        S.g_isPickpocketed = false
    end
    eventManager:RegisterForUpdate(moduleName .. "ResetPickpocket", PICKPOCKET_LOOT_CONTEXT_MS, ResetIsPickpocketed, true)
end

--- @param logPrefix string
--- @return string
function ChatAnnouncements.ResolveLootLogPrefix(logPrefix)
    if logPrefix and logPrefix ~= "" then
        return logPrefix
    end
    return ChatAnnouncements.GetContextMessagePrefix()
end

--- @return string
function ChatAnnouncements.GetContextMessagePrefix()
    if S.g_isLooted and not S.g_itemReceivedIsQuestReward and not S.g_isPickpocketed and not S.g_isStolen then
        return ChatAnnouncements.GetContextMessage("CurrencyMessageLoot")
    elseif S.g_isPickpocketed then
        return ChatAnnouncements.GetContextMessage("CurrencyMessagePickpocket")
    elseif S.g_isStolen and not S.g_isPickpocketed then
        return ChatAnnouncements.GetContextMessage("CurrencyMessageSteal")
    elseif GetInteractionType() == INTERACTION_PICKPOCKET then
        return ChatAnnouncements.GetContextMessage("CurrencyMessagePickpocket")
    end
    return ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
end

--- @param logPrefix string
--- @param formattedMessageP1 string
--- @param formattedRecipient string
--- @param color string
--- @param groupLoot boolean
--- @param guildAnnounceGuildId integer|nil
--- @return string
function ChatAnnouncements.FormatContextMessage(logPrefix, formattedMessageP1, formattedRecipient, color, groupLoot, guildAnnounceGuildId)
    if ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgrade") and ChatAnnouncements.IsValidOldItem() then
        local formattedIcon = ChatAnnouncements.GetFormattedIcon(S.g_oldItem.icon)
        local formattedMessageUpgrade = string_format("|r%s%s|c%s", formattedIcon, S.g_oldItem.itemLink, color)
        S.g_oldItem = {}
        return string_format(logPrefix, formattedMessageUpgrade, formattedMessageP1)
    end

    if groupLoot then
        local recipient = string_format("|r%s|c%s", formattedRecipient, color)
        return string_format(logPrefix, recipient, formattedMessageP1)
    end

    if formattedRecipient == "" then
        if ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageDepositGuild")
        or ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageWithdrawGuild") then
            local guildId = guildAnnounceGuildId or S.g_guildBankAnnounceGuildId or ChatAnnouncements.GetActiveGuildBankId()
            local guildLabel = ChatAnnouncements.FormatGuildLabelForChat(guildId) or ""
            return ChatAnnouncements.FormatGuildBankContextMessage(logPrefix, formattedMessageP1, guildLabel)
        end
        return string_format(logPrefix, formattedMessageP1, "")
    end

    local recipient = string_format("|r%s|c%s", formattedRecipient, color)
    return string_format(logPrefix, formattedMessageP1, recipient)
end

--- @return boolean
function ChatAnnouncements.IsValidOldItem()
    return S.g_oldItem ~= nil and S.g_oldItem.itemLink ~= "" and S.g_oldItem.itemLink ~= nil and S.g_oldItem.icon ~= nil
end

--- @param icon string
--- @return string
function ChatAnnouncements.GetFormattedIcon(icon)
    if not ChatAnnouncements.SV.Inventory.LootIcons or icon == "" then
        return ""
    end
    return zo_iconTextFormat(icon, 16, 16, "", nil)
end

function ChatAnnouncements.ResetTrackingVariables()
    S.g_itemCounterGain = 0
    S.g_itemCounterGainTracker = 0
    S.g_itemCounterLoss = 0
    S.g_itemCounterLossTracker = 0
    S.g_itemStringGain = ""
    S.g_itemStringLoss = ""
    S.g_guildBankAnnounceGuildId = nil
end
