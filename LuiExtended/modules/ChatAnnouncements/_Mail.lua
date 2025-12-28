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

-- -----------------------------------------------------------------------------
-- Mail Module
-- -----------------------------------------------------------------------------

--- @class ChatAnnouncements.Mail
--- @field parent ChatAnnouncements
--- @field moduleName string
--- @field cod integer
--- @field postageAmount integer
--- @field amount integer
--- @field codPresent boolean
--- @field target string
--- @field stacksOut table
--- @field senderMap table
--- @field senderQueue table
--- @field isTakingMail boolean
--- @field Initialize fun()
--- @field RegisterEvents fun()
--- @field GetNextSender fun(): string
ChatAnnouncements.Mail = ChatAnnouncements.Mail or {}
local Mail = ChatAnnouncements.Mail

-- Store reference to parent for accessing shared services
Mail.parent = ChatAnnouncements
Mail.moduleName = ChatAnnouncements.moduleName .. "_Mail"

-- Module state
Mail.cod = 0
Mail.postageAmount = 0
Mail.amount = 0
Mail.codPresent = false
Mail.target = ""
Mail.stacksOut = {}
Mail.senderMap = {}
Mail.senderQueue = {}
Mail.isTakingMail = false

--- - **EVENT_MAIL_ATTACHED_MONEY_CHANGED **
---
--- @param eventId integer
--- @param moneyAmount integer
function Mail.OnMoneyChanged(eventId, moneyAmount)
    Mail.cod = 0
    Mail.postageAmount = GetQueuedMailPostage()
    local previousMailAmount = Mail.amount
    local getMailAmount = moneyAmount or GetQueuedMoneyAttachment()
    -- If we send more then half of the gold in our bags for some reason this event fires again so this is a workaround
    if getMailAmount == GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) and getMailAmount ~= previousMailAmount then
        return
    else
        Mail.amount = getMailAmount
    end
end

--- - **EVENT_MAIL_COD_CHANGED **
---
--- @param eventId integer
--- @param codAmount integer
function Mail.OnCODChanged(eventId, codAmount)
    Mail.cod = codAmount or GetQueuedCOD()
    Mail.postageAmount = GetQueuedMailPostage()
    Mail.amount = GetQueuedMoneyAttachment()
end

--- - **EVENT_MAIL_REMOVED **
---
--- @param eventId integer
--- @param mailId id64
function Mail.OnRemoved(eventId, mailId)
    if Mail.parent.SV.Notify.NotificationMailSendCA or Mail.parent.SV.Notify.NotificationMailSendAlert then
        if Mail.parent.SV.Notify.NotificationMailSendCA then
            local message = GetString(LUIE_STRING_CA_MAIL_DELETED_MSG)
            Mail.parent.QueuedMessages[Mail.parent.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "NOTIFICATION",
                isSystem = true
            }
            Mail.parent.QueuedMessagesCounter = Mail.parent.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(Mail.parent.moduleName .. "Printer", 50, Mail.parent.PrintQueuedMessages)
        end
        if Mail.parent.SV.Notify.NotificationMailSendAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_MAIL_DELETED_MSG))
        end
    end
end

--- - **EVENT_MAIL_READABLE **
---
--- @param eventId integer
--- @param mailId id64
function Mail.OnReadable(eventId, mailId)
    for category = MAIL_CATEGORY_ITERATION_BEGIN, MAIL_CATEGORY_ITERATION_END do
        local numMailItems = GetNumMailItemsByCategory(category)
        for index = 1, numMailItems do
            mailId = GetMailIdByIndex(category, index)
            local dataTable = {}
            --- @alias MailDataTable {
            --- GetExpiresText: function,
            --- GetFormattedReplySubject: function,
            --- GetFormattedSubject: function,
            --- GetReceivedText: function,
            --- IsExpirationImminent: function,
            --- attachedMoney: integer,
            --- category: MailCategory,
            --- codAmount: integer,
            --- expiresInDays: integer,
            --- firstItemIcon: textureName,
            --- fromCS: boolean,
            --- fromSystem: boolean,
            --- isFromPlayer: boolean,
            --- isReadInfoReady: boolean,
            --- mailId: id64,
            --- numAttachments: integer,
            --- returned: boolean,
            --- secsSinceReceived: integer,
            --- senderCharacterName: string,
            --- senderDisplayName: string,
            --- subject: string,
            --- unread: boolean,
            --- }
            --- @cast dataTable MailDataTable
            ZO_MailInboxShared_PopulateMailData(dataTable, mailId)

            -- -- Debug: Log the raw sender names for verification
            -- if LUIE.IsDevDebugEnabled() then
            --     LUIE.Debug(string.format("Raw Mail Data - Display: %s, Character: %s, Category: %s, FromPlayer: %s",
            --                              dataTable.senderDisplayName, dataTable.senderCharacterName, dataTable.category, tostring(dataTable.isFromPlayer)))
            -- end

            -- Resolve the sender's name based on mail category and sender type
            if dataTable.fromSystem or dataTable.fromCS then
                Mail.target = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(dataTable.senderDisplayName)
            end
            if dataTable.isFromPlayer then
                if dataTable.senderDisplayName ~= "" and dataTable.senderCharacterName ~= "" then
                    local finalName = Mail.parent.ResolveNameLink(dataTable.senderCharacterName, dataTable.senderDisplayName)
                    Mail.target = ZO_SELECTED_TEXT:Colorize(finalName)
                else
                    local finalName
                    if Mail.parent.SV.BracketOptionCharacter == 1 then
                        finalName = ZO_LinkHandler_CreateLinkWithoutBrackets(dataTable.senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, dataTable.senderDisplayName)
                    else
                        finalName = ZO_LinkHandler_CreateLink(dataTable.senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, dataTable.senderDisplayName)
                    end
                    Mail.target = ZO_SELECTED_TEXT:Colorize(finalName)
                end
            end

            -- Handle COD
            Mail.codPresent = (dataTable.codAmount > 0)
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
            local finalName = Mail.parent.ResolveNameLink(senderCharacterName, senderDisplayName)
            mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
        else
            local finalName
            if Mail.parent.SV.BracketOptionCharacter == 1 then
                finalName = ZO_LinkHandler_CreateLinkWithoutBrackets(senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, senderDisplayName)
            else
                finalName = ZO_LinkHandler_CreateLink(senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, senderDisplayName)
            end
            mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
        end
    end

    return mailTarget, codAmount > 0, numAttachments, attachedMoney
end

function Mail.GetNextSender()
    if #Mail.senderQueue > 0 then
        local sender = table.remove(Mail.senderQueue, 1)
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug(string.format("Mail sender queue: consumed '%s', remaining: %d", sender, #Mail.senderQueue))
        -- end
        return sender
    end
    return ""
end

--- - **EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS **
---
--- @param eventId integer
--- @param mailId id64
function Mail.OnTakeAttachedItem(eventId, mailId)
    Mail.isTakingMail = true

    local mailTarget, hasCOD = ResolveMailSender(mailId)
    Mail.senderMap[mailId] = mailTarget
    -- Don't set Mail.target during take all to prevent contamination
    -- Mail.target is only used as fallback, and queue system handles take all correctly
    Mail.codPresent = hasCOD

    eventManager:UnregisterForUpdate(Mail.moduleName .. "ClearTakingFlag")
    eventManager:RegisterForUpdate(Mail.moduleName .. "ClearTakingFlag", 200, function ()
        Mail.isTakingMail = false
        eventManager:UnregisterForUpdate(Mail.moduleName .. "ClearTakingFlag")
    end)

    if Mail.parent.SV.Notify.NotificationMailSendCA or Mail.parent.SV.Notify.NotificationMailSendAlert then
        local mailString
        if hasCOD then
            mailString = GetString(LUIE_STRING_CA_MAIL_RECEIVED_COD)
        else
            mailString = GetString(LUIE_STRING_CA_MAIL_RECEIVED)
        end
        if mailString then
            if Mail.parent.SV.Notify.NotificationMailSendCA then
                Mail.parent.QueuedMessages[Mail.parent.QueuedMessagesCounter] =
                {
                    message = mailString,
                    messageType = "NOTIFICATION",
                    isSystem = true
                }
                Mail.parent.QueuedMessagesCounter = Mail.parent.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(Mail.parent.moduleName .. "Printer", 50, Mail.parent.PrintQueuedMessages)
            end
            if Mail.parent.SV.Notify.NotificationMailSendAlert then
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
--- @param headersRemoved boolean
function Mail.OnTakeAllResponse(eventId, result, category, headersRemoved)
    Mail.isTakingMail = false
    eventManager:UnregisterForUpdate(Mail.moduleName .. "ClearTakingFlag")

    -- if LUIE.IsDevDebugEnabled() then
    --     local resultStr = result == MAIL_TAKE_ATTACHMENT_RESULT_SUCCESS and "SUCCESS" or "FAIL"
    --     LUIE.Debug(string.format("Take All completed: result=%s, category=%d, headersRemoved=%s, queue remaining=%d",
    --         resultStr, category, tostring(headersRemoved), #Mail.senderQueue))
    -- end
end

--- - **EVENT_MAIL_ATTACHMENT_ADDED **
---
--- @param eventId integer
--- @param attachmentSlot luaindex
function Mail.OnAttach(eventId, attachmentSlot)
    Mail.postageAmount = GetQueuedMailPostage()
    Mail.amount = GetQueuedMoneyAttachment()
    local mailIndex = attachmentSlot
    local bagId, slotIndex, icon, stack = GetQueuedItemAttachmentInfo(attachmentSlot)
    local itemId = GetItemId(bagId, slotIndex)
    local itemLink = GetMailQueuedAttachmentLink(attachmentSlot, Mail.parent.linkBrackets[Mail.parent.SV.BracketOptionItem])
    local itemType = GetItemLinkItemType(itemLink)
    Mail.stacksOut[mailIndex] =
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
function Mail.OnAttachRemove(eventId, attachmentSlot)
    Mail.postageAmount = GetQueuedMailPostage()
    Mail.amount = GetQueuedMoneyAttachment()
    local mailIndex = attachmentSlot
    Mail.stacksOut[mailIndex] = nil
end

local function PopulateMailSenderQueue()
    Mail.senderQueue = {}
    Mail.senderMap = {}
    local mailCount = 0

    -- Iterate through all mail categories to ensure we get mail in the correct processing order
    -- Take all processes mail by category, so we need to match that order
    for category = MAIL_CATEGORY_ITERATION_BEGIN, MAIL_CATEGORY_ITERATION_END do
        local numMailItems = GetNumMailItemsByCategory(category)
        for index = 1, numMailItems do
            local mailId = GetMailIdByIndex(category, index)
            if mailId then
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

                    -- Add money first, then items, to match the order they're processed
                    if attachedMoney > 0 then
                        table.insert(Mail.senderQueue, mailTarget)
                    end
                    for i = 1, numAttachments do
                        table.insert(Mail.senderQueue, mailTarget)
                    end

                    Mail.senderMap[mailId] = mailTarget
                end
            end
        end
    end

    -- if LUIE.IsDevDebugEnabled() then
    --     LUIE.Debug(string.format("Mail sender queue populated: %d mails found, %d queue entries", mailCount, #Mail.senderQueue))
    -- end
end

--- - **EVENT_MAIL_INBOX_UPDATE**
---
--- @param eventId integer
function Mail.OnInboxUpdate(eventId)
    if Mail.parent.inMail and not Mail.isTakingMail then
        PopulateMailSenderQueue()
    end
end

--- - **EVENT_MAIL_OPEN_MAILBOX**
---
--- @param eventId integer
function Mail.OnOpenBox(eventId)
    eventManager:UnregisterForEvent(Mail.parent.moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if Mail.parent.SV.Inventory.LootMail then
        eventManager:RegisterForEvent(Mail.parent.moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Mail.parent.InventoryUpdate)
        Mail.parent.inventoryStacks = {}
        Mail.parent.IndexInventory() -- Index Inventory
    end
    Mail.parent.inMail = true
    -- Populate queue when mailbox opens to ensure it's ready for take all
    PopulateMailSenderQueue()
end

--- - **EVENT_MAIL_CLOSE_MAILBOX**
---
--- @param eventId integer
function Mail.OnCloseBox(eventId)
    eventManager:UnregisterForEvent(Mail.parent.moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if Mail.parent.SV.Inventory.Loot or Mail.parent.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(Mail.parent.moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, Mail.parent.InventoryUpdate)
    end
    if not (Mail.parent.SV.Inventory.Loot or Mail.parent.SV.Inventory.LootShowDisguise) then
        Mail.parent.inventoryStacks = {}
    end
    Mail.parent.inMail = false
    Mail.stacksOut = {}
    Mail.parent.currentMailSender = ""
    Mail.senderMap = {}
    Mail.senderQueue = {}
    Mail.isTakingMail = false
    eventManager:UnregisterForUpdate(Mail.moduleName .. "ClearTakingFlag")
end

--- - **EVENT_MAIL_SEND_SUCCESS **
---
--- @param eventId integer
--- @param playerName string
function Mail.OnSendSuccess(eventId, playerName)
    local formattedValue = ZO_CommaDelimitDecimalNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))
    local changeColor = Mail.parent.SV.Currency.CurrencyContextColor and Mail.parent.Colors.CurrencyDownColorize:ToHex() or Mail.parent.Colors.CurrencyColorize:ToHex()
    local currencyTypeColor = Mail.parent.Colors.CurrencyGoldColorize:ToHex()
    local currencyIcon = Mail.parent.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetKeyboardCurrencyIcon(CURT_MONEY), 16, 16) or ""
    local currencyTotal = Mail.parent.SV.Currency.CurrencyGoldShowTotal
    local messageTotal = Mail.parent.SV.Currency.CurrencyMessageTotalGold

    if Mail.postageAmount > 0 then
        local messageType = "LUIE_CURRENCY_POSTAGE"
        local changeType = ZO_CommaDelimitDecimalNumber(Mail.postageAmount)
        local currencyName = zo_strformat(Mail.parent.SV.Currency.CurrencyGoldName, Mail.postageAmount)
        local messageChange = Mail.parent.SV.ContextMessages.CurrencyMessagePostage
        Mail.parent.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, nil, nil)
    end

    if not Mail.codPresent and Mail.amount > 0 then
        local messageType = "LUIE_CURRENCY_MAIL"
        local changeType = ZO_CommaDelimitDecimalNumber(Mail.amount)
        local currencyName = zo_strformat(Mail.parent.SV.Currency.CurrencyGoldName, Mail.amount)
        local messageChange = Mail.target ~= "" and Mail.parent.SV.ContextMessages.CurrencyMessageMailOut or Mail.parent.SV.ContextMessages.CurrencyMessageMailOutNoName
        Mail.parent.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, nil, nil)
    end

    if Mail.parent.SV.Notify.NotificationMailSendCA or Mail.parent.SV.Notify.NotificationMailSendAlert then
        local mailString
        if not Mail.codPresent then
            mailString = Mail.cod > 1 and GetString(LUIE_STRING_CA_MAIL_SENT_COD) or GetString(LUIE_STRING_CA_MAIL_SENT)
        end
        if mailString then
            if Mail.parent.SV.Notify.NotificationMailSendCA then
                Mail.parent.QueuedMessages[Mail.parent.QueuedMessagesCounter] =
                {
                    message = mailString,
                    messageType = "NOTIFICATION",
                    isSystem = true
                }
                Mail.parent.QueuedMessagesCounter = Mail.parent.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(Mail.parent.moduleName .. "Printer", 50, Mail.parent.PrintQueuedMessages)
            end
            if Mail.parent.SV.Notify.NotificationMailSendAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, mailString)
            end
        end
    end

    if Mail.parent.SV.Inventory.LootMail then
        for mailIndex = 1, 6 do
            local item = Mail.stacksOut[mailIndex]
            if item ~= nil then
                local gainOrLoss = Mail.parent.SV.Currency.CurrencyContextColor and 2 or 4
                local logPrefix = Mail.target ~= "" and Mail.parent.SV.ContextMessages.CurrencyMessageMailOut or Mail.parent.SV.ContextMessages.CurrencyMessageMailOutNoName
                Mail.parent.ItemCounterDelayOut(
                    item.icon,
                    item.stack,
                    item.itemType,
                    item.itemId,
                    item.itemLink,
                    Mail.target,
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

    Mail.codPresent = false
    Mail.cod = 0
    Mail.postageAmount = 0
    Mail.amount = 0
    Mail.stacksOut = {}
end

function Mail.Initialize()
    -- Initialize state
    Mail.cod = 0
    Mail.postageAmount = 0
    Mail.amount = 0
    Mail.codPresent = false
    Mail.target = ""
    Mail.stacksOut = {}
    Mail.senderMap = {}
    Mail.senderQueue = {}
    Mail.isTakingMail = false

    -- Register events
    Mail.RegisterEvents()
end

function Mail.RegisterEvents()
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_READABLE)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_ATTACHMENT_ADDED)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_ATTACHMENT_REMOVED)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_OPEN_MAILBOX)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_CLOSE_MAILBOX)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_SEND_SUCCESS)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_COD_CHANGED)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_REMOVED)
    eventManager:UnregisterForEvent(Mail.moduleName, EVENT_MAIL_INBOX_UPDATE)
    if Mail.parent.SV.Inventory.LootMail then
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_READABLE, Mail.OnReadable)
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, Mail.OnTakeAttachedItem)
    end
    eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE, Mail.OnTakeAllResponse)
    if Mail.parent.SV.Inventory.LootMail or Mail.parent.SV.Currency.CurrencyGoldChange then
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_ATTACHMENT_ADDED, Mail.OnAttach)
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_ATTACHMENT_REMOVED, Mail.OnAttachRemove)
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_SEND_SUCCESS, Mail.OnSendSuccess)
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED, Mail.OnMoneyChanged)
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_COD_CHANGED, Mail.OnCODChanged)
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_REMOVED, Mail.OnRemoved)
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_INBOX_UPDATE, Mail.OnInboxUpdate)
    end
    if Mail.parent.SV.Inventory.Loot or Mail.parent.SV.Inventory.LootMail or Mail.parent.SV.Currency.CurrencyGoldChange then
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_OPEN_MAILBOX, Mail.OnOpenBox)
        eventManager:RegisterForEvent(Mail.moduleName, EVENT_MAIL_CLOSE_MAILBOX, Mail.OnCloseBox)
    end
end
