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
--- @param bagId Bag
--- @param slotId integer
--- @param isNewItem boolean
--- @param itemSoundCategory integer
--- @param inventoryUpdateReason InventoryUpdateReason
--- @param stackCountChange integer
function ChatAnnouncements.InventoryUpdateBank(eventId, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- End right now if this is any other reason (durability loss, etc)
    if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then
        return
    end

    local receivedBy = ""
    if bagId == BAG_BACKPACK then
        local gainOrLoss
        local logPrefix
        local icon
        local stack
        local itemType
        local itemId
        local itemLink
        local removed
        -- NEW ITEM
        if not S.g_inventoryStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_inventoryStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = S.g_bankBag == 1 and ChatAnnouncements.GetContextMessage("CurrencyMessageWithdraw") or (S.g_currentBankBagId == BAG_FURNITURE_VAULT and ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawFurnitureVault") or ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawStorage"))
            if S.g_InventoryOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif S.g_inventoryStacks[slotId] then
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

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = S.g_bankBag == 1 and ChatAnnouncements.GetContextMessage("CurrencyMessageWithdraw") or (S.g_currentBankBagId == BAG_FURNITURE_VAULT and ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawFurnitureVault") or ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawStorage"))
                if S.g_InventoryOn then
                    ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if S.g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDestroy")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if S.g_InventoryOn and not S.g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = S.g_bankBag == 1 and ChatAnnouncements.GetContextMessage("CurrencyMessageDeposit") or (S.g_currentBankBagId == BAG_FURNITURE_VAULT and ChatAnnouncements.GetContextMessage("CurrencyMessageDepositFurnitureVault") or ChatAnnouncements.GetContextMessage("CurrencyMessageDepositStorage"))
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if S.g_inventoryStacks[slotId] then
                    S.g_inventoryStacks[slotId] = nil
                end
            else
                S.g_inventoryStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
            end

            if not S.g_itemWasDestroyed then
                S.g_bankOn = true
            end
            if not S.g_itemWasDestroyed then
                S.g_InventoryOn = false
            end
            if not S.g_itemWasDestroyed then
                zo_callLater(ChatAnnouncements.BankFixer, 50)
            end
        end
    end

    if bagId == BAG_BANK then
        local gainOrLoss
        local logPrefix
        local icon
        local stack
        local itemType
        local itemId
        local itemLink
        local removed
        -- NEW ITEM
        if not S.g_bankStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_bankStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDeposit")
            if S.g_bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif S.g_bankStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = S.g_bankStacks[slotId].icon
                stack = S.g_bankStacks[slotId].stack
                itemType = S.g_bankStacks[slotId].itemType
                itemId = S.g_bankStacks[slotId].itemId
                itemLink = S.g_bankStacks[slotId].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotId)
                itemType = GetItemType(bagId, slotId)
                itemId = GetItemId(bagId, slotId)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDeposit")
                if S.g_bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if S.g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDestroy")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if S.g_bankOn and not S.g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDeposit")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if S.g_bankStacks[slotId] then
                    S.g_bankStacks[slotId] = nil
                end
            else
                S.g_bankStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not S.g_itemWasDestroyed then
                S.g_InventoryOn = true
            end
            if not S.g_itemWasDestroyed then
                S.g_bankOn = false
            end
            if not S.g_itemWasDestroyed then
                zo_callLater(ChatAnnouncements.BankFixer, 50)
            end
        end
    end

    if bagId == BAG_SUBSCRIBER_BANK then
        local gainOrLoss
        local logPrefix
        local icon
        local stack
        local itemType
        local itemId
        local itemLink
        local removed
        -- NEW ITEM
        if not S.g_banksubStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_banksubStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDeposit")
            if S.g_bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif S.g_banksubStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = S.g_banksubStacks[slotId].icon
                stack = S.g_banksubStacks[slotId].stack
                itemType = S.g_banksubStacks[slotId].itemType
                itemId = S.g_banksubStacks[slotId].itemId
                itemLink = S.g_banksubStacks[slotId].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotId)
                itemType = GetItemType(bagId, slotId)
                itemId = GetItemId(bagId, slotId)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDeposit")
                if S.g_bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if S.g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDestroy")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if S.g_bankOn and not S.g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDeposit")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if S.g_banksubStacks[slotId] then
                    S.g_banksubStacks[slotId] = nil
                end
            else
                S.g_banksubStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not S.g_itemWasDestroyed then
                S.g_InventoryOn = true
            end
            if not S.g_itemWasDestroyed then
                S.g_bankOn = false
            end
            if not S.g_itemWasDestroyed then
                zo_callLater(ChatAnnouncements.BankFixer, 50)
            end
        end
    end

    if BAG_FURNITURE_VAULT and bagId == BAG_FURNITURE_VAULT then
        local gainOrLoss
        local logPrefix
        local icon
        local stack
        local itemType
        local itemId
        local itemLink
        local removed
        -- NEW ITEM
        if not S.g_furnitureVaultStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_furnitureVaultStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDepositFurnitureVault") or ChatAnnouncements.GetContextMessage("CurrencyMessageDepositStorage")
            if S.g_bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif S.g_furnitureVaultStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                icon = S.g_furnitureVaultStacks[slotId].icon
                stack = S.g_furnitureVaultStacks[slotId].stack
                itemType = S.g_furnitureVaultStacks[slotId].itemType
                itemId = S.g_furnitureVaultStacks[slotId].itemId
                itemLink = S.g_furnitureVaultStacks[slotId].itemLink
                removed = true
            else
                icon, stack = GetItemInfo(bagId, slotId)
                itemType = GetItemType(bagId, slotId)
                itemId = GetItemId(bagId, slotId)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDepositFurnitureVault") or ChatAnnouncements.GetContextMessage("CurrencyMessageDepositStorage")
                if S.g_bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if S.g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDestroy")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if S.g_bankOn and not S.g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawFurnitureVault") or ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawStorage")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if S.g_furnitureVaultStacks[slotId] then
                    S.g_furnitureVaultStacks[slotId] = nil
                end
            else
                S.g_furnitureVaultStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not S.g_itemWasDestroyed then
                S.g_InventoryOn = true
            end
            if not S.g_itemWasDestroyed then
                S.g_bankOn = false
            end
            if not S.g_itemWasDestroyed then
                zo_callLater(ChatAnnouncements.BankFixer, 50)
            end
        end
    end

    if bagId > 6 and bagId < 16 then
        local gainOrLoss
        local logPrefix
        local icon
        local stack
        local itemType
        local itemId
        local itemLink
        local removed
        -- NEW ITEM
        if not S.g_houseBags[bagId][slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_houseBags[bagId][slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDepositStorage")
            if S.g_bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif S.g_houseBags[bagId][slotId] then
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = S.g_houseBags[bagId][slotId].icon
                stack = S.g_houseBags[bagId][slotId].stack
                itemType = S.g_houseBags[bagId][slotId].itemType
                itemId = S.g_houseBags[bagId][slotId].itemId
                itemLink = S.g_houseBags[bagId][slotId].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotId)
                itemType = GetItemType(bagId, slotId)
                itemId = GetItemId(bagId, slotId)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDepositStorage")
                if S.g_bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if S.g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDestroy")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if S.g_bankOn and not S.g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDepositStorage")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if S.g_houseBags[bagId][slotId] then
                    S.g_houseBags[bagId][slotId] = nil
                end
            else
                S.g_houseBags[bagId][slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not S.g_itemWasDestroyed then
                S.g_InventoryOn = true
            end
            if not S.g_itemWasDestroyed then
                S.g_bankOn = false
            end
            if not S.g_itemWasDestroyed then
                zo_callLater(ChatAnnouncements.BankFixer, 50)
            end
        end
    end

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
            logPrefix = S.g_bankBag == 1 and ChatAnnouncements.GetContextMessage("CurrencyMessageDeposit") or (S.g_currentBankBagId == BAG_FURNITURE_VAULT and ChatAnnouncements.GetContextMessage("CurrencyMessageDepositFurnitureVault") or ChatAnnouncements.GetContextMessage("CurrencyMessageDepositStorage"))
            stack = stackCountChange * -1
        else
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = S.g_bankBag == 1 and ChatAnnouncements.GetContextMessage("CurrencyMessageWithdraw") or (S.g_currentBankBagId == BAG_FURNITURE_VAULT and ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawFurnitureVault") or ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawStorage"))
            stack = stackCountChange
        end

        ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
    end

    S.g_itemWasDestroyed = false
    S.g_lockpickBroken = false
end

function ChatAnnouncements.BankFixer()
    S.g_InventoryOn = false
    S.g_bankOn = false
end
