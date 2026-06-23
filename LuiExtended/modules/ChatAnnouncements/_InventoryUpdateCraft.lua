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

--- True when LibLazyCrafting is running a request where UI tab/mode is unreliable (writ smithing, improve, provisioning).
--- Uses LibLazyCrafting.isCurrentlyCrafting[1] like LLC internals (see LibLazyCrafting.lua).
--- @return boolean
function I.CheckLibLazyCraftingActive()
    if not LibLazyCrafting or not LibLazyCrafting.isCurrentlyCrafting then
        return false
    end
    if LibLazyCrafting.isCurrentlyCrafting[1] ~= true then
        return false
    end
    -- Manual or LLC deconstruction: use deconstruct/receive (or station decon tab prefixes).
    if LUIE.IsSmithingDeconstructionContext() then
        return false
    end
    -- LLC enchanting uses ENCHANTING mode tables (craft/use vs extract/receive by tab).
    if LibLazyCrafting.isCurrentlyCrafting[2] == "enchanting" then
        return false
    end
    return true
end

--- @param eventId integer
--- @param bagId Bag
--- @param slotId integer
--- @param isNewItem boolean
--- @param itemSoundCategory integer
--- @param inventoryUpdateReason InventoryUpdateReason
--- @param stackCountChange integer
function ChatAnnouncements.InventoryUpdateCraft(eventId, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- End right now if this is any other reason (durability loss, etc)
    if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then
        return
    end

    local ResolveCraftingUsed = LUIE.ResolveCraftingUsed
    local isSmithingDeconstruction = LUIE.IsSmithingDeconstructionContext()

    local receivedBy = "LUIE_RECEIVE_CRAFT" -- This keyword tells our item printer to print the items in a list separated by commas, to conserve space for the display of crafting mats consumed.
    local logPrefixPos = ChatAnnouncements.GetContextMessage("CurrencyMessageCraft")
    local logPrefixNeg = ChatAnnouncements.GetContextMessage("CurrencyMessageUse")

    -- Get string values from our crafting hook function
    if GetCraftingInteractionType() == CRAFTING_TYPE_ENCHANTING then
        logPrefixPos = S.g_enchant_prefix_pos[S.g_enchanting.GetMode()]
        logPrefixNeg = S.g_enchant_prefix_neg[S.g_enchanting.GetMode()]
    end
    local craftingInteractionType = GetCraftingInteractionType()
    local isSmithingCraftingType = craftingInteractionType == CRAFTING_TYPE_BLACKSMITHING
        or craftingInteractionType == CRAFTING_TYPE_CLOTHIER
        or craftingInteractionType == CRAFTING_TYPE_WOODWORKING
        or craftingInteractionType == CRAFTING_TYPE_JEWELRYCRAFTING
        or (IsSmithingCraftingType and IsSmithingCraftingType(craftingInteractionType))

    if isSmithingCraftingType then
        local smithingMode = S.g_smithing.GetMode()
        if LUIE.IsSmithingDeconstructionContext() then
            smithingMode = SMITHING_MODE_DECONSTRUCTION
        end
        logPrefixPos = S.g_smithing_prefix_pos[smithingMode]
        logPrefixNeg = S.g_smithing_prefix_neg[smithingMode]
    end

    -- Universal deconstruction (Giladil, etc.) may not report a smithing interaction type; still use decon verbs.
    if LUIE.IsSmithingDeconstructionContext() and craftingInteractionType ~= CRAFTING_TYPE_ENCHANTING then
        logPrefixPos = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
        logPrefixNeg = ChatAnnouncements.GetContextMessage("CurrencyMessageDeconstruct")
    end

    -- If the hook function didn't return a string value (for example because the player was in Gamepad mode), then we use a default override.
    if logPrefixPos == nil then
        logPrefixPos = ChatAnnouncements.GetContextMessage("CurrencyMessageCraft")
    end
    if logPrefixNeg == nil then
        logPrefixNeg = ChatAnnouncements.GetContextMessage("CurrencyMessageDeconstruct")
    end

    if I.CheckLibLazyCraftingActive() then
        logPrefixPos = ChatAnnouncements.GetContextMessage("CurrencyMessageCraft")
        logPrefixNeg = ChatAnnouncements.GetContextMessage("CurrencyMessageUse")
    end

    local function ApplyCraftItemLossVerb(itemType, logPrefix)
        if itemType == ITEMTYPE_GLYPH_ARMOR or itemType == ITEMTYPE_GLYPH_WEAPON or itemType == ITEMTYPE_GLYPH_JEWELRY then
            if craftingInteractionType == CRAFTING_TYPE_ENCHANTING or isSmithingDeconstruction then
                return ChatAnnouncements.GetContextMessage("CurrencyMessageExtract")
            end
        end
        if itemType == ITEMTYPE_FISH then
            return ChatAnnouncements.GetContextMessage("CurrencyMessageFillet")
        end
        return logPrefix
    end

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
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
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

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                S.g_oldItem = { itemLink = S.g_equippedStacks[slotId].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                end
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(itemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
                if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    logPrefix = ApplyCraftItemLossVerb(itemType, logPrefix)
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
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
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_inventoryStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
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

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                S.g_oldItem = { itemLink = S.g_inventoryStacks[slotId].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(removedItemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
                if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    -- ChatAnnouncements.ItemPrinter(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false)
                    logPrefix = ApplyCraftItemLossVerb(removedItemType, logPrefix)
                    ChatAnnouncements.ItemCounterDelay(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
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
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
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

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                S.g_oldItem = { itemLink = S.g_bankStacks[slotId].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(itemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
                if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    -- ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                    logPrefix = ApplyCraftItemLossVerb(itemType, logPrefix)
                    ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
                end
            end

            if removed then
                if S.g_bankStacks[slotId] then
                    S.g_bankStacks[slotId] = nil
                end
            else
                S.g_bankStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
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

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                S.g_oldItem = { itemLink = S.g_banksubStacks[slotId].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(itemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
                if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    logPrefix = ApplyCraftItemLossVerb(itemType, logPrefix)
                    ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
                end
            end

            if removed then
                if S.g_banksubStacks[slotId] then
                    S.g_banksubStacks[slotId] = nil
                end
            else
                S.g_banksubStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end
    end

    if bagId == BAG_VIRTUAL then
        local gainOrLoss
        local logPrefix
        local itemLink = tostring(ChatAnnouncements.GetItemLinkFromItemId(slotId))
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotId
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)
        local change
        local alwaysFirst

        if stackCountChange > 0 then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(itemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")) or logPrefixPos
            change = stackCountChange
            alwaysFirst = false
        end

        if stackCountChange < 0 then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(itemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
            change = stackCountChange * -1
            alwaysFirst = true
        end

        if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then
            logPrefix = ApplyCraftItemLossVerb(itemType, logPrefix)
            if itemId == 33753 then
                logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
            end
            ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, alwaysFirst, true)
        end
    end

    S.g_itemWasDestroyed = false
    S.g_lockpickBroken = false
end
