-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State


local I = ChatAnnouncements.Internal

local B = ChatAnnouncements.Brackets

local string_format = string.format
local table_insert = table.insert

local eventManager = GetEventManager()

local moduleName = LUIE.name .. "ChatAnnouncements"

--- @param eventId integer
--- @param slotId integer
--- @param addedByLocalPlayer boolean
function ChatAnnouncements.GuildBankItemAdded(eventId, slotId, addedByLocalPlayer)
    if addedByLocalPlayer then
        zo_callLater(ChatAnnouncements.LogGuildBankChange, 50)
    end
end

--- @param eventId integer
--- @param slotId integer
--- @param addedByLocalPlayer boolean
function ChatAnnouncements.GuildBankItemRemoved(eventId, slotId, addedByLocalPlayer)
    if addedByLocalPlayer then
        zo_callLater(ChatAnnouncements.LogGuildBankChange, 50)
    end
end

function ChatAnnouncements.LogGuildBankChange()
    if S.g_guildBankCarry ~= nil then
        S.g_guildBankAnnounceGuildId = S.g_guildBankCarry.guildId
        ChatAnnouncements.ItemPrinter(S.g_guildBankCarry.icon, S.g_guildBankCarry.stack, S.g_guildBankCarry.itemType, S.g_guildBankCarry.itemId, S.g_guildBankCarry.itemLink, S.g_guildBankCarry.receivedBy, S.g_guildBankCarry.logPrefix, S.g_guildBankCarry.gainOrLoss, false)
    end
    S.g_guildBankCarry = nil
end

function ChatAnnouncements.InventoryUpdateGuildBank(eventId, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    local receivedBy = ""
    local activeGuildBankId = ChatAnnouncements.GetActiveGuildBankId()
    ---------------------------------- INVENTORY ----------------------------------
    if bagId == BAG_BACKPACK then
        local gainOrLoss
        local logPrefix
        local icon
        local stack
        local itemType
        local itemId
        local itemLink
        local removed

        if not S.g_inventoryStacks[slotId] then -- NEW ITEM
            local icon1, stack1 = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_inventoryStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon1, stack1, itemId, itemType, itemLink)
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawGuild")
            S.g_guildBankCarry =
            {
                icon = icon1,
                stack = stack1,
                gainOrLoss = gainOrLoss,
                logPrefix = logPrefix,
                receivedBy = receivedBy,
                itemLink = itemLink,
                itemId = itemId,
                itemType = itemType,
                guildId = activeGuildBankId,
            }
        elseif S.g_inventoryStacks[slotId] then -- EXISTING ITEM
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = S.g_inventoryStacks[slotId].icon
                stack = S.g_inventoryStacks[slotId].stack
                itemType = S.g_inventoryStacks[slotId].itemType
                itemId = S.g_inventoryStacks[slotId].itemId
                itemLink = S.g_inventoryStacks[slotId].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotId)
                itemType = GetItemType(bagId, slotId)
                itemId = GetItemId(bagId, slotId)
                removed = false
            end

            if stackCountChange > 0 then -- STACK COUNT INCREMENTED UP
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawGuild")
                S.g_guildBankCarry =
                {
                    icon = icon,
                    stack = stack,
                    gainOrLoss = gainOrLoss,
                    logPrefix = logPrefix,
                    receivedBy = receivedBy,
                    itemLink = itemLink,
                    itemId = itemId,
                    itemType = itemType,
                    guildId = activeGuildBankId,
                }
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if S.g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDestroy")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if not S.g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDepositGuild")
                    S.g_guildBankCarry =
                    {
                        icon = icon,
                        stack = stack,
                        gainOrLoss = gainOrLoss,
                        logPrefix = logPrefix,
                        receivedBy = receivedBy,
                        itemLink = itemLink,
                        itemId = itemId,
                        itemType = itemType,
                        guildId = activeGuildBankId,
                    }
                end
            end

            if removed then
                if S.g_inventoryStacks[slotId] then
                    S.g_inventoryStacks[slotId] = nil
                end
            else
                S.g_inventoryStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
            end
        end
    end

    ---------------------------------- CRAFTING BAG ----------------------------------
    if bagId == BAG_VIRTUAL then
        local gainOrLoss
        local stack
        local logPrefix
        local itemLink = tostring(ChatAnnouncements.GetItemLinkFromItemId(slotId))
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotId
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)

        if stackCountChange < 1 then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDepositGuild")
            stack = stackCountChange * -1
        else
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawGuild")
            stack = stackCountChange
        end

        S.g_guildBankCarry =
        {
            icon = icon,
            stack = stack,
            gainOrLoss = gainOrLoss,
            logPrefix = logPrefix,
            receivedBy = receivedBy,
            itemLink = itemLink,
            itemId = itemId,
            itemType = itemType,
            guildId = activeGuildBankId,
        }
    end

    S.g_itemWasDestroyed = false
    S.g_lockpickBroken = false
end
