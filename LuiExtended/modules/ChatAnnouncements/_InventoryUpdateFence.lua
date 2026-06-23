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

local ColorizeColors = ChatAnnouncements.Colors

local string_format = string.format
local table_insert = table.insert
local table_concat = table.concat

local eventManager = GetEventManager()

local moduleName = LUIE.name .. "ChatAnnouncements"

--- @param eventId integer
--- @param bagId Bag
--- @param slotId integer
--- @param isNewItem boolean
--- @param itemSoundCategory integer
--- @param inventoryUpdateReason InventoryUpdateReason
--- @param stackCountChange integer
function ChatAnnouncements.InventoryUpdateFence(eventId, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
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

            if stackCountChange == 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.GetContextMessage("CurrencyMessageLaunder") or ChatAnnouncements.GetContextMessage("CurrencyMessageLaunderNoV")
                if not S.g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
                    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                        changeColor = ColorizeColors.CurrencyColorize:ToHex()
                    end
                    local type = "LUIE_CURRENCY_VENDOR"

                    local parts = { ZO_LinkHandler_ParseLink(itemLink) }
                    parts[22] = "1"
                    parts = table_concat(parts, ":"):sub(2, -1)
                    itemLink = zo_strformat("|H<<1>>|h|h", parts)

                    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
                    local itemCount = stack > 1 and (" |cFFFFFFx" .. stack .. "|r") or ""
                    local carriedItem = (formattedIcon .. itemLink .. itemCount)
                    local carriedItemTotal = ""
                    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                        local total1, total2, total3 = GetItemLinkStacks(itemLink)
                        local total = total1 + total2 + total3
                        if total > 1 then
                            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        end
                    end

                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                        S.g_savedPurchase.changeColor = changeColor
                        S.g_savedPurchase.messageChange = logPrefix
                        S.g_savedPurchase.type = type
                        S.g_savedPurchase.carriedItem = carriedItem
                        S.g_savedPurchase.carriedItemTotal = carriedItemTotal
                    else
                        S.g_savedLaunder =
                        {
                            icon = icon,
                            stack = 0,
                            itemType = itemType,
                            itemId = itemId,
                            itemLink = itemLink,
                            logPrefix = logPrefix,
                            gainOrLoss = gainOrLoss,
                        }
                    end
                end
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.GetContextMessage("CurrencyMessageLaunder") or ChatAnnouncements.GetContextMessage("CurrencyMessageLaunderNoV")
                --[[                 if not S.g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
                    --ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true)
                end ]]
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if S.g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDestroy")
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                else
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.GetContextMessage("CurrencyMessageLaunder") or ChatAnnouncements.GetContextMessage("CurrencyMessageLaunderNoV")
                    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                        changeColor = ColorizeColors.CurrencyColorize:ToHex()
                    end
                    local type = "LUIE_CURRENCY_VENDOR"

                    local parts = { ZO_LinkHandler_ParseLink(itemLink) }
                    parts[22] = "1"
                    parts = table_concat(parts, ":"):sub(2, -1)
                    itemLink = zo_strformat("|H<<1>>|h|h", parts)

                    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
                    local itemCount = stack > 1 and (" |cFFFFFFx" .. stack .. "|r") or ""
                    local carriedItem = (formattedIcon .. itemLink .. itemCount)
                    local carriedItemTotal = ""
                    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                        local total1, total2, total3 = GetItemLinkStacks(itemLink)
                        local total = total1 + total2 + total3
                        if total > 1 then
                            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        end
                    end

                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                        S.g_savedPurchase.changeColor = changeColor
                        S.g_savedPurchase.messageChange = logPrefix
                        S.g_savedPurchase.type = type
                        S.g_savedPurchase.carriedItem = carriedItem
                        S.g_savedPurchase.carriedItemTotal = carriedItemTotal
                    else
                        S.g_savedLaunder =
                        {
                            icon = icon,
                            stack = change,
                            itemType = itemType,
                            itemId = itemId,
                            itemLink = itemLink,
                            logPrefix = logPrefix,
                            gainOrLoss = gainOrLoss,
                        }
                    end
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

    if bagId == BAG_VIRTUAL then
        local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
        local logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.GetContextMessage("CurrencyMessageLaunder") or ChatAnnouncements.GetContextMessage("CurrencyMessageLaunderNoV")
        local itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotId
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)

        if not S.g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
            local change = stackCountChange > 0 and stackCountChange or stackCountChange * -1
            local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
            if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                changeColor = ColorizeColors.CurrencyColorize:ToHex()
            end
            local type = "LUIE_CURRENCY_VENDOR"

            local parts = { ZO_LinkHandler_ParseLink(itemLink) }
            parts[22] = "1"
            parts = table_concat(parts, ":"):sub(2, -1)
            itemLink = zo_strformat("|H<<1>>|h|h", parts)

            local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
            local itemCount = stackCountChange > 1 and (" |cFFFFFFx" .. stackCountChange .. "|r") or ""
            local carriedItem = (formattedIcon .. itemLink .. itemCount)
            local carriedItemTotal = ""
            if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                local total1, total2, total3 = GetItemLinkStacks(itemLink)
                local total = total1 + total2 + total3
                if total > 1 then
                    carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                end
            end

            if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                S.g_savedPurchase.changeColor = changeColor
                S.g_savedPurchase.messageChange = logPrefix
                S.g_savedPurchase.type = type
                S.g_savedPurchase.carriedItem = carriedItem
                S.g_savedPurchase.carriedItemTotal = carriedItemTotal
            else
                S.g_savedLaunder =
                {
                    icon = icon,
                    stack = change,
                    itemType = itemType,
                    itemId = itemId,
                    itemLink = itemLink,
                    logPrefix = logPrefix,
                    gainOrLoss = gainOrLoss,
                }
            end
        end
    end

    S.g_itemWasDestroyed = false
    S.g_lockpickBroken = false
end
