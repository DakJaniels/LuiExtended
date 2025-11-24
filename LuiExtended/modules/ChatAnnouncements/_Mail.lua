-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- -----------------------------------------------------------------------------
-- ESO API Locals.
-- -----------------------------------------------------------------------------

local eventManager = GetEventManager()
local GetString = GetString
local zo_strformat = zo_strformat


--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local moduleName = ChatAnnouncements.moduleName
local linkBrackets = ChatAnnouncements.linkBrackets

local mailSenderMap = {}
local mailSenderQueue = {}
local isTakingMail = false

--- - **EVENT_MAIL_ATTACHED_MONEY_CHANGED **
---
--- @param eventId integer
--- @param moneyAmount integer
function ChatAnnouncements.MailMoneyChanged(eventId, moneyAmount)
    ChatAnnouncements.mailCOD = 0
    ChatAnnouncements.postageAmount = GetQueuedMailPostage()
    local previousMailAmount = ChatAnnouncements.mailAmount
    local getMailAmount = moneyAmount or GetQueuedMoneyAttachment()
    -- If we send more then half of the gold in our bags for some reason this event fires again so this is a workaround
    if getMailAmount == GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) and getMailAmount ~= previousMailAmount then
        return
    else
        ChatAnnouncements.mailAmount = getMailAmount
    end
end

--- - **EVENT_MAIL_COD_CHANGED **
---
--- @param eventId integer
--- @param codAmount integer
function ChatAnnouncements.MailCODChanged(eventId, codAmount)
    ChatAnnouncements.mailCOD = codAmount or GetQueuedCOD()
    ChatAnnouncements.postageAmount = GetQueuedMailPostage()
    ChatAnnouncements.mailAmount = GetQueuedMoneyAttachment()
end

--- - **EVENT_MAIL_REMOVED **
---
--- @param eventId integer
--- @param mailId id64
function ChatAnnouncements.MailRemoved(eventId, mailId)
    if ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
        if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
            local message = GetString(LUIE_STRING_CA_MAIL_DELETED_MSG)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "NOTIFICATION",
                isSystem = true
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_MAIL_DELETED_MSG))
        end
    end
end

--- - **EVENT_MAIL_READABLE **
---
--- @param eventId integer
--- @param mailId id64
function ChatAnnouncements.OnMailReadable(eventId, mailId)
    for category = MAIL_CATEGORY_ITERATION_BEGIN, MAIL_CATEGORY_ITERATION_END do
        local numMailItems = GetNumMailItemsByCategory(category)
        for index = 1, numMailItems do
            mailId = GetMailIdByIndex(category, index)
            local dataTable = {}
            --- @cast dataTable MailDataTable
            ZO_MailInboxShared_PopulateMailData(dataTable, mailId)

            -- -- Debug: Log the raw sender names for verification
            -- if LUIE.IsDevDebugEnabled() then
            --     LUIE.Debug(string.format("Raw Mail Data - Display: %s, Character: %s, Category: %s, FromPlayer: %s",
            --                              dataTable.senderDisplayName, dataTable.senderCharacterName, dataTable.category, tostring(dataTable.isFromPlayer)))
            -- end

            -- Resolve the sender's name based on mail category and sender type
            if dataTable.fromSystem or dataTable.fromCS then
                ChatAnnouncements.mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(dataTable.senderDisplayName)
            end
            if dataTable.isFromPlayer then
                if dataTable.senderDisplayName ~= "" and dataTable.senderCharacterName ~= "" then
                    local finalName = ChatAnnouncements.ResolveNameLink(dataTable.senderCharacterName, dataTable.senderDisplayName)
                    ChatAnnouncements.mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
                else
                    local finalName
                    if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                        finalName = ZO_LinkHandler_CreateLinkWithoutBrackets(dataTable.senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, dataTable.senderDisplayName)
                    else
                        finalName = ZO_LinkHandler_CreateLink(dataTable.senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, dataTable.senderDisplayName)
                    end
                    ChatAnnouncements.mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
                end
            end

            -- Handle COD
            ChatAnnouncements.mailCODPresent = (dataTable.codAmount > 0)
        end
    end
end

local function ResolveMailSender(mailId)
    local senderDisplayName, senderCharacterName, subject, firstItemIcon, unread, fromSystem, fromCS, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived, category = GetMailItemInfo(mailId)

    local mailTarget = ""
    if fromSystem or fromCS then
        mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(senderDisplayName)
    elseif not (fromSystem or fromCS) then
        if senderDisplayName ~= "" and senderCharacterName ~= "" then
            local finalName = ChatAnnouncements.ResolveNameLink(senderCharacterName, senderDisplayName)
            mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
        else
            local finalName
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                finalName = ZO_LinkHandler_CreateLinkWithoutBrackets(senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, senderDisplayName)
            else
                finalName = ZO_LinkHandler_CreateLink(senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, senderDisplayName)
            end
            mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
        end
    end

    return mailTarget, codAmount > 0, numAttachments, attachedMoney
end

function ChatAnnouncements.GetNextMailSender()
    if #mailSenderQueue > 0 then
        local sender = table.remove(mailSenderQueue, 1)
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug(string.format("Mail sender queue: consumed '%s', remaining: %d", sender, #mailSenderQueue))
        -- end
        return sender
    end
    return ""
end

--- - **EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS **
---
--- @param eventId integer
--- @param mailId id64
function ChatAnnouncements.OnMailTakeAttachedItem(eventId, mailId)
    isTakingMail = true

    local mailTarget, hasCOD = ResolveMailSender(mailId)
    mailSenderMap[mailId] = mailTarget
    ChatAnnouncements.mailTarget = mailTarget
    ChatAnnouncements.mailCODPresent = hasCOD

    eventManager:UnregisterForUpdate(moduleName .. "_Mail" .. "ClearTakingFlag")
    eventManager:RegisterForUpdate(moduleName .. "_Mail" .. "ClearTakingFlag", 200, function ()
        isTakingMail = false
        eventManager:UnregisterForUpdate(moduleName .. "_Mail" .. "ClearTakingFlag")
    end)

    if ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
        local mailString
        if hasCOD then
            mailString = GetString(LUIE_STRING_CA_MAIL_RECEIVED_COD)
        else
            mailString = GetString(LUIE_STRING_CA_MAIL_RECEIVED)
        end
        if mailString then
            if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                {
                    message = mailString,
                    messageType = "NOTIFICATION",
                    isSystem = true
                }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, mailString)
            end
        end
    end
end

--- - **EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE **
---
--- @param eventId integer
--- @param result MailTakeAttachmentResult
--- @param category MailCategory
--- @param headersRemoved bool
function ChatAnnouncements.OnMailTakeAllResponse(eventId, result, category, headersRemoved)
    isTakingMail = false
    eventManager:UnregisterForUpdate(moduleName .. "_Mail" .. "ClearTakingFlag")

    -- if LUIE.IsDevDebugEnabled() then
    --     local resultStr = result == MAIL_TAKE_ATTACHMENT_RESULT_SUCCESS and "SUCCESS" or "FAIL"
    --     LUIE.Debug(string.format("Take All completed: result=%s, category=%d, headersRemoved=%s, queue remaining=%d",
    --         resultStr, category, tostring(headersRemoved), #mailSenderQueue))
    -- end
end

--- - **EVENT_MAIL_ATTACHMENT_ADDED **
---
--- @param eventId integer
--- @param attachmentSlot luaindex
function ChatAnnouncements.OnMailAttach(eventId, attachmentSlot)
    ChatAnnouncements.postageAmount = GetQueuedMailPostage()
    ChatAnnouncements.mailAmount = GetQueuedMoneyAttachment()
    local mailIndex = attachmentSlot
    local bagId, slotIndex, icon, stack = GetQueuedItemAttachmentInfo(attachmentSlot)
    local itemId = GetItemId(bagId, slotIndex)
    local itemLink = GetMailQueuedAttachmentLink(attachmentSlot, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
    local itemType = GetItemLinkItemType(itemLink)
    ChatAnnouncements.mailStacksOut[mailIndex] =
    {
        icon = icon,
        stack = stack,
        itemId = itemId,
        itemLink = itemLink,
        itemType = itemType
    }
end

--- - **EVENT_MAIL_ATTACHMENT_REMOVED **
---
--- @param eventId integer
--- @param attachmentSlot luaindex
function ChatAnnouncements.OnMailAttachRemove(eventId, attachmentSlot)
    ChatAnnouncements.postageAmount = GetQueuedMailPostage()
    ChatAnnouncements.mailAmount = GetQueuedMoneyAttachment()
    local mailIndex = attachmentSlot
    ChatAnnouncements.mailStacksOut[mailIndex] = nil
end

local function PopulateMailSenderQueue()
    mailSenderQueue = {}
    local mailCount = 0

    local mailId = GetNextMailId(nil)
    while mailId do
        mailCount = mailCount + 1
        local mailTarget, hasCOD, numAttachments, attachedMoney = ResolveMailSender(mailId)

        -- if LUIE.IsDevDebugEnabled() then
        --     local senderDisplayName, senderCharacterName = GetMailSender(mailId)
        --     LUIE.Debug(string.format("Found mail %d: mailId=%s, displayName='%s', charName='%s', resolved='%s', attachments=%d, money=%d",
        --         mailCount, Id64ToString(mailId), senderDisplayName or "", senderCharacterName or "", mailTarget or "", numAttachments or 0, attachedMoney or 0))
        -- end

        if (numAttachments and numAttachments > 0) or (attachedMoney and attachedMoney > 0) then
            if mailTarget == "" then
                local senderDisplayName = GetMailSender(mailId)
                if senderDisplayName ~= "" then
                    mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(senderDisplayName)
                end
            end

            -- if LUIE.IsDevDebugEnabled() then
            --     LUIE.Debug(string.format("Populating queue: mailId=%s, sender='%s', attachments=%d, money=%d",
            --         Id64ToString(mailId), mailTarget, numAttachments, attachedMoney))
            -- end

            if attachedMoney > 0 then
                table.insert(mailSenderQueue, mailTarget)
            end
            for i = 1, numAttachments do
                table.insert(mailSenderQueue, mailTarget)
            end

            mailSenderMap[mailId] = mailTarget
        end

        mailId = GetNextMailId(mailId)
    end

    -- if LUIE.IsDevDebugEnabled() then
    --     LUIE.Debug(string.format("Mail sender queue populated: %d mails found, %d queue entries", mailCount, #mailSenderQueue))
    -- end
end

--- - **EVENT_MAIL_INBOX_UPDATE**
---
--- @param eventId integer
function ChatAnnouncements.OnMailInboxUpdate(eventId)
    if ChatAnnouncements.inMail and not isTakingMail then
        PopulateMailSenderQueue()
    end
end

--- - **EVENT_MAIL_OPEN_MAILBOX**
---
--- @param eventId integer
function ChatAnnouncements.OnMailOpenBox(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootMail then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        ChatAnnouncements.inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
    ChatAnnouncements.inMail = true
end

--- - **EVENT_MAIL_CLOSE_MAILBOX**
---
--- @param eventId integer
function ChatAnnouncements.OnMailCloseBox(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        ChatAnnouncements.inventoryStacks = {}
    end
    ChatAnnouncements.inMail = false
    ChatAnnouncements.mailStacksOut = {}
    ChatAnnouncements.currentMailSender = ""
    mailSenderMap = {}
    mailSenderQueue = {}
    isTakingMail = false
    eventManager:UnregisterForUpdate(moduleName .. "_Mail" .. "ClearTakingFlag")
end

--- - **EVENT_MAIL_SEND_SUCCESS **
---
--- @param eventId integer
--- @param playerName string
function ChatAnnouncements.OnMailSuccess(eventId, playerName)
    local formattedValue = ZO_CommaDelimitDecimalNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    local currencyTypeColor = ChatAnnouncements.Colors.CurrencyGoldColorize:ToHex()
    local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetKeyboardCurrencyIcon(CURT_MONEY), 16, 16) or ""
    local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
    local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalGold

    if ChatAnnouncements.postageAmount > 0 then
        local messageType = "LUIE_CURRENCY_POSTAGE"
        local changeType = ZO_CommaDelimitDecimalNumber(ChatAnnouncements.postageAmount)
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, ChatAnnouncements.postageAmount)
        local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePostage
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, nil, nil)
    end

    if not ChatAnnouncements.mailCODPresent and ChatAnnouncements.mailAmount > 0 then
        local messageType = "LUIE_CURRENCY_MAIL"
        local changeType = ZO_CommaDelimitDecimalNumber(ChatAnnouncements.mailAmount)
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, ChatAnnouncements.mailAmount)
        local messageChange = ChatAnnouncements.mailTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailOut or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailOutNoName
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, nil, nil)
    end

    if ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
        local mailString
        if not ChatAnnouncements.mailCODPresent then
            mailString = ChatAnnouncements.mailCOD > 1 and GetString(LUIE_STRING_CA_MAIL_SENT_COD) or GetString(LUIE_STRING_CA_MAIL_SENT)
        end
        if mailString then
            if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                {
                    message = mailString,
                    messageType = "NOTIFICATION",
                    isSystem = true
                }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, mailString)
            end
        end
    end

    if ChatAnnouncements.SV.Inventory.LootMail then
        for mailIndex = 1, 6 do
            local item = ChatAnnouncements.mailStacksOut[mailIndex]
            if item ~= nil then
                local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                local logPrefix = ChatAnnouncements.mailTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailOut or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailOutNoName
                ChatAnnouncements.ItemCounterDelayOut(
                    item.icon,
                    item.stack,
                    item.itemType,
                    item.itemId,
                    item.itemLink,
                    ChatAnnouncements.mailTarget,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
            end
        end
    end

    ChatAnnouncements.mailCODPresent = false
    ChatAnnouncements.mailCOD = 0
    ChatAnnouncements.postageAmount = 0
    ChatAnnouncements.mailAmount = 0
    ChatAnnouncements.mailStacksOut = {}
end

function ChatAnnouncements.RegisterMailEvents()
    local mailModuleName = moduleName .. "_Mail"
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_READABLE)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_ATTACHMENT_ADDED)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_ATTACHMENT_REMOVED)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_OPEN_MAILBOX)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_CLOSE_MAILBOX)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_SEND_SUCCESS)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_COD_CHANGED)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_REMOVED)
    eventManager:UnregisterForEvent(mailModuleName, EVENT_MAIL_INBOX_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootMail then
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_READABLE, ChatAnnouncements.OnMailReadable)
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, ChatAnnouncements.OnMailTakeAttachedItem)
    end
    eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE, ChatAnnouncements.OnMailTakeAllResponse)
    if ChatAnnouncements.SV.Inventory.LootMail or ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_ATTACHMENT_ADDED, ChatAnnouncements.OnMailAttach)
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_ATTACHMENT_REMOVED, ChatAnnouncements.OnMailAttachRemove)
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_SEND_SUCCESS, ChatAnnouncements.OnMailSuccess)
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED, ChatAnnouncements.MailMoneyChanged)
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_COD_CHANGED, ChatAnnouncements.MailCODChanged)
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_REMOVED, ChatAnnouncements.MailRemoved)
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_INBOX_UPDATE, ChatAnnouncements.OnMailInboxUpdate)
    end
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootMail or ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_OPEN_MAILBOX, ChatAnnouncements.OnMailOpenBox)
        eventManager:RegisterForEvent(mailModuleName, EVENT_MAIL_CLOSE_MAILBOX, ChatAnnouncements.OnMailCloseBox)
    end
end
