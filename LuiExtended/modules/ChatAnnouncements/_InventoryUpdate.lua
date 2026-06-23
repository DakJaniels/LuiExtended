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

local crownRidingIds =
{
    [64700] = true,  -- Crown Lesson: Riding Speed
    [64701] = true,  -- Crown Lesson: Riding Stamina
    [64702] = true,  -- Crown Lesson: Riding Capacity
    [135115] = true, -- Crown Lesson: Riding Speed
    [135116] = true, -- Crown Lesson: Riding Stamina
    [135117] = true, -- Crown Lesson: Riding Capacity
}

--- @param eventId integer
--- @param bagId Bag
--- @param slotId integer
--- @param isNewItem boolean
--- @param itemSoundCategory integer
--- @param inventoryUpdateReason InventoryUpdateReason
--- @param stackCountChange integer
function ChatAnnouncements.InventoryUpdate(eventId, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- End right now if this is any other reason (durability loss, etc)
    if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then
        return
    end

    if GetInteractionType() == INTERACTION_PICKPOCKET then
        ChatAnnouncements.MarkPickpocketLootContext()
    end

    if IsItemStolen(bagId, slotId) then
        S.g_isStolen = true
        local function ResetIsStolen()
            S.g_isStolen = false
        end
        eventManager:RegisterForUpdate(moduleName .. "ResetStolen", 150, ResetIsStolen, true)
    end

    local receivedBy = ""
    if bagId == BAG_WORN then
        local gainOrLoss
        local logPrefix
        local icon
        local stack
        local itemType
        local itemId
        local itemLink
        local removed
        -- NEW ITEM
        if not S.g_equippedStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_equippedStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
            if ChatAnnouncements.SV.Inventory.LootShowDisguise and slotId == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
                gainOrLoss = 3
                receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDisguiseEquip")
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif S.g_equippedStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = S.g_equippedStacks[slotId].icon
                stack = S.g_equippedStacks[slotId].stack
                itemType = S.g_equippedStacks[slotId].itemType
                itemId = S.g_equippedStacks[slotId].itemId
                itemLink = S.g_equippedStacks[slotId].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotId)
                itemType = GetItemType(bagId, slotId)
                itemId = GetItemId(bagId, slotId)
                removed = false
            end

            -- STACK COUNT REMAINED THE SAME (GEAR SWAPPED)
            if stackCountChange == 0 then
                if ChatAnnouncements.SV.Inventory.LootShowDisguise and slotId == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
                    gainOrLoss = 3
                    receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDisguiseEquip")
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
                if not S.g_itemWasDestroyed then
                    if ChatAnnouncements.SV.Inventory.LootShowDisguise and slotId == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
                        if IsUnitInCombat("player") then
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDisguiseDestroy")
                            receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        else
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDisguiseRemove")
                            receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                            gainOrLoss = 3
                        end
                        ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                    elseif not S.g_itemWasDestroyed and S.g_removableIDs[itemId] and ChatAnnouncements.SV.Inventory.LootShowRemove then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageRemove")
                        ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                    end
                end
            end

            if removed then
                if S.g_equippedStacks[slotId] then
                    S.g_equippedStacks[slotId] = nil
                end
            else
                S.g_equippedStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
            end
        end
    end

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
            -- Flag stack split as true - this will occur when a stack of items is split into multiple stacks.
            if not isNewItem then
                S.g_stackSplit = true
                eventManager:RegisterForUpdate(moduleName .. "StackTracker", 50, ChatAnnouncements.ResetStackSplit, true)
            end
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_inventoryStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            local mailSender
            local lootMailId
            if I.IsMailLootActive() then
                mailSender, logPrefix, lootMailId = I.GetMailSenderForInventoryLoot()
            else
                logPrefix = ""
            end
            if S.g_weAreInADig then
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageExcavate")
            end
            if S.g_packSiege and itemType == ITEMTYPE_SIEGE then
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageStow")
            end
            if not S.g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not S.g_inTrade and not I.IsMailLootActive() then
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true, nil, false, true, nil, true)
            end
            if I.IsMailLootActive() and isNewItem then
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, mailSender, logPrefix, gainOrLoss, false, nil, nil, nil, lootMailId)
            end
            -- EXISTING ITEM
        elseif S.g_inventoryStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            -- For item removal, we save whatever the currently indexed item is here.
            local removedIcon = S.g_inventoryStacks[slotId].icon
            local removedItemType = S.g_inventoryStacks[slotId].itemType
            local removedItemId = S.g_inventoryStacks[slotId].itemId
            local removedItemLink = S.g_inventoryStacks[slotId].itemLink
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
                -- Flag stack split as true - this will occur when two items are stacked together (dragged over each other)
                if not isNewItem then
                    S.g_stackSplit = true
                    eventManager:RegisterForUpdate(moduleName .. "StackTracker", 50, ChatAnnouncements.ResetStackSplit, true)
                end

                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                local mailSender
                local lootMailId
                if I.IsMailLootActive() then
                    mailSender, logPrefix, lootMailId = I.GetMailSenderForInventoryLoot()
                else
                    logPrefix = ""
                end
                if S.g_weAreInADig then
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageExcavate")
                end
                if S.g_packSiege and itemType == ITEMTYPE_SIEGE then
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageStow")
                end
                if not S.g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not S.g_inTrade and not I.IsMailLootActive() then
                    ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true, nil, false, true, nil, true)
                end
                if I.IsMailLootActive() and isNewItem then
                    ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, mailSender, logPrefix, gainOrLoss, false, nil, nil, nil, lootMailId)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                -- Check Destroyed first
                if S.g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDestroy")
                    ChatAnnouncements.ItemPrinter(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false)
                    -- Check Lockpick next
                elseif ChatAnnouncements.SV.Inventory.LootShowLockpick and S.g_lockpickBroken then
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageLockpick")
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    ChatAnnouncements.ItemPrinter(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false)
                    -- Check container is emptied next
                elseif ChatAnnouncements.SV.Inventory.LootShowContainer and (removedItemType == ITEMTYPE_CONTAINER or removedItemType == ITEMTYPE_CONTAINER_CURRENCY) then
                    -- Don't display a message if the specialized item type is a "Container Style Page"
                    local _, specializedType = GetItemLinkItemType(itemLink)
                    if specializedType ~= SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageContainer")
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        ChatAnnouncements.ItemPrinter(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true)
                    end
                    -- Check to see if the item was removed in dialogue and Quest Item turnin is on.
                elseif S.g_talkingToNPC and not S.g_weAreInAStore and ChatAnnouncements.SV.Inventory.LootShowTurnIn then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageQuestTurnIn")
                    zo_callLater(function ()
                                     if S.g_stackSplit == false then
                                         ChatAnnouncements.ItemCounterDelay(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false, false, true, false)
                                         eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                                     end
                                 end, 25)
                elseif S.g_weAreInAGuildStore and ChatAnnouncements.SV.Inventory.LootShowList then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageList")
                    S.g_savedItem = { icon = removedIcon, stack = change, itemLink = removedItemLink }
                    -- Check to see if the item was used
                elseif not S.g_itemWasDestroyed and not S.g_talkingToNPC and not S.g_inTrade and not I.IsMailLootActive() then
                    local flag -- When set to true we deliver a message on a zo_callLater
                    if ChatAnnouncements.SV.Inventory.LootShowUsePotion and removedItemType == ITEMTYPE_POTION then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessagePotion")
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseFood and removedItemType == ITEMTYPE_FOOD then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageFood")
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseDrink and removedItemType == ITEMTYPE_DRINK then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDrink")
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseRepairKit and (removedItemType == ITEMTYPE_TOOL or removedItemType == ITEMTYPE_CROWN_REPAIR or removedItemType == ITEMTYPE_AVA_REPAIR or removedItemType == ITEMTYPE_GROUP_REPAIR) then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageUse")
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseSoulGem and removedItemType == ITEMTYPE_SOUL_GEM then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageUse")
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseSiege and removedItemType == ITEMTYPE_SIEGE then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageDeploy")
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseFish and removedItemType == ITEMTYPE_FISH then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageFillet")
                        flag = true
                    end
                    -- If this is a Skill respec scroll, manually call an announcement for it if enabled (for some reason doesn't display an EVENT_DISPLAY_ANNOUNCEMENT on use anymore)
                    if removedItemType == ITEMTYPE_CROWN_ITEM and (itemId == 64524 or itemId == 135128) then
                        zo_callLater(function ()
                                         ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_SKILLS)
                                     end, 25)
                    end
                    -- If this is an Attribute respec scroll, manually call an announcement for it if enabled (we disable EVENT_DISPLAY_ANNOUNCEMENT for this to sync it better)
                    if removedItemType == ITEMTYPE_CROWN_ITEM and (itemId == 64523 or itemId == 135130) then
                        zo_callLater(function ()
                                         ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_ATTRIBUTES)
                                     end, 25)
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseMisc and (removedItemType == ITEMTYPE_RECALL_STONE or removedItemType == ITEMTYPE_TROPHY or removedItemType == ITEMTYPE_MASTER_WRIT or removedItemType == ITEMTYPE_CROWN_ITEM) then
                        -- Check to make sure the items aren't riding lesson books.
                        if not crownRidingIds[removedItemId] then
                            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageUse")
                            flag = true
                        end
                    end
                    -- Learn Recipe
                    if ChatAnnouncements.SV.Inventory.LootShowRecipe and removedItemType == ITEMTYPE_RECIPE then
                        -- Show recipe message if a recipe is learned.
                        if not S.g_combinedRecipe then
                            gainOrLoss = 4
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageLearnRecipe")
                            flag = true
                            if ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
                                PlaySound(SOUNDS.RECIPE_LEARNED)
                            end
                        else
                            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageUse")
                            flag = true
                        end
                    end
                    -- Learn Motif
                    if ChatAnnouncements.SV.Inventory.LootShowMotif and removedItemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
                        gainOrLoss = 4
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageLearnMotif")
                        flag = true
                    end
                    -- Learn Style
                    if ChatAnnouncements.SV.Inventory.LootShowStylePage and removedItemType == ITEMTYPE_COLLECTIBLE then
                        -- Don't display a message if the specialized item type is not "Collectible Style Page"
                        local _, specializedType = GetItemLinkItemType(itemLink)
                        if specializedType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then
                            gainOrLoss = 4
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageLearnStyle")
                            flag = true
                        end
                    end
                    -- Learn Style (TODO: Check if needed since style pages were switched to ITEMTYPE_COLLECTIBLE)
                    if ChatAnnouncements.SV.Inventory.LootShowStylePage and removedItemType == ITEMTYPE_CONTAINER then
                        -- Don't display a message if the specialized item type is not "Container Style Page"
                        local _, specializedType = GetItemLinkItemType(itemLink)
                        if specializedType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then
                            gainOrLoss = 4
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageLearnStyle")
                            flag = true
                        end
                    end
                    -- If any of these options were flagged, run a callLater on a 50ms delay to make sure we didn't just split stacks.
                    if flag then
                        zo_callLater(function ()
                                         if S.g_stackSplit == false then
                                             ChatAnnouncements.ItemCounterDelay(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false, false, true, false)
                                             eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                                         end
                                     end, 25)
                    end
                    -- For any leftover cases for items removed.
                elseif not S.g_itemWasDestroyed and S.g_removableIDs[itemId] and ChatAnnouncements.SV.Inventory.LootShowRemove then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageRemove")
                    ChatAnnouncements.ItemPrinter(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false)
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
        local logPrefix
        local mailSender
        local lootMailId
        if I.IsMailLootActive() then
            mailSender, logPrefix, lootMailId = I.GetMailSenderForInventoryLoot()
        else
            logPrefix = ""
        end
        if S.g_weAreInADig then
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageExcavate")
        end
        local itemLink = tostring(ChatAnnouncements.GetItemLinkFromItemId(slotId))
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotId
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)

        if not S.g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not S.g_inTrade and not I.IsMailLootActive() then
            ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true, nil, false, true, nil, true)
        end
        if I.IsMailLootActive() and isNewItem then
            ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, mailSender, logPrefix, gainOrLoss, false, nil, nil, nil, lootMailId)
        end
    end

    S.g_itemWasDestroyed = false
    S.g_lockpickBroken = false
end
