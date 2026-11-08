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

local IMPROVEMENT_RESULT_DELAY_MS = 150
local improvementResultUpdateName = moduleName .. "ImprovementResult"

local improvementBoosterItemTypes =
{
    [ITEMTYPE_BLACKSMITHING_BOOSTER] = true,
    [ITEMTYPE_CLOTHIER_BOOSTER] = true,
    [ITEMTYPE_WOODWORKING_BOOSTER] = true,
    [ITEMTYPE_JEWELRYCRAFTING_BOOSTER] = true,
}

--- @param itemType ItemType
--- @return boolean
function I.IsImprovementBoosterItemType(itemType)
    return improvementBoosterItemTypes[itemType] == true
end

--- Same item id with a higher functional quality is an in-place improvement.
--- @param previousItemLink string|nil
--- @param itemId integer|nil
--- @param itemLink string|nil
--- @return boolean
function I.IsImprovementQualityIncrease(previousItemLink, itemId, itemLink)
    if not previousItemLink or previousItemLink == "" or not itemLink or itemLink == "" or not itemId then
        return false
    end
    if GetItemLinkItemId(previousItemLink) ~= itemId then
        return false
    end
    return GetItemLinkFunctionalQuality(itemLink) > GetItemLinkFunctionalQuality(previousItemLink)
end

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
    local craftingInteractionType = GetCraftingInteractionType()
    if craftingInteractionType == CRAFTING_TYPE_ENCHANTING then
        logPrefixPos = S.g_enchant_prefix_pos[S.g_enchanting.GetMode()]
        logPrefixNeg = S.g_enchant_prefix_neg[S.g_enchanting.GetMode()]
    end
    local isSmithingCraftingType = IsSmithingCraftingType(craftingInteractionType)
    local smithingMode = SMITHING_MODE_ROOT
    if isSmithingCraftingType then
        smithingMode = S.g_smithing.GetMode()
        if isSmithingDeconstruction then
            smithingMode = SMITHING_MODE_DECONSTRUCTION
        end
        logPrefixPos = S.g_smithing_prefix_pos[smithingMode]
        logPrefixNeg = S.g_smithing_prefix_neg[smithingMode]
    end

    -- Universal deconstruction (Giladil, etc.) may not report a smithing interaction type; still use decon verbs.
    if isSmithingDeconstruction and craftingInteractionType ~= CRAFTING_TYPE_ENCHANTING then
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

    local libLazyCraftingActive = I.CheckLibLazyCraftingActive()
    if libLazyCraftingActive then
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

    local applyImprovementInventoryFilter = smithingMode == SMITHING_MODE_IMPROVEMENT and not libLazyCraftingActive

    local function AnnounceImprovementQualityIncrease(previousItemLink, icon, itemType, itemId, itemLink)
        if not I.IsImprovementQualityIncrease(previousItemLink, itemId, itemLink) then
            return
        end
        S.g_oldItem = { itemLink = previousItemLink, icon = icon }
        S.g_improvementSucceeded = true
        local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
        ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefixPos, gainOrLoss, false)
    end

    local function AnnounceImprovementBoosterUse(icon, removedStackCount, itemType, itemId, itemLink)
        if not I.IsImprovementBoosterItemType(itemType) then
            return
        end
        local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
        local logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageUse")
        ChatAnnouncements.ItemCounterDelay(icon, removedStackCount, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
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
            if not applyImprovementInventoryFilter then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
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

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                local previousItemLink = S.g_equippedStacks[slotId].itemLink
                if applyImprovementInventoryFilter then
                    AnnounceImprovementQualityIncrease(previousItemLink, icon, itemType, itemId, itemLink)
                else
                    S.g_oldItem = { itemLink = previousItemLink, icon = icon }
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = logPrefixPos
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                if not applyImprovementInventoryFilter then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = logPrefixPos
                    if itemId == 33753 then
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                    end
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if applyImprovementInventoryFilter then
                    AnnounceImprovementBoosterUse(icon, change, itemType, itemId, itemLink)
                else
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(itemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
                    if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                        logPrefix = ApplyCraftItemLossVerb(itemType, logPrefix)
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
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_inventoryStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
            if not applyImprovementInventoryFilter then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
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

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                local previousItemLink = S.g_inventoryStacks[slotId].itemLink
                if applyImprovementInventoryFilter then
                    AnnounceImprovementQualityIncrease(previousItemLink, icon, itemType, itemId, itemLink)
                else
                    S.g_oldItem = { itemLink = previousItemLink, icon = icon }
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = logPrefixPos
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                if not applyImprovementInventoryFilter then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = logPrefixPos
                    if itemId == 33753 then
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                    end
                    -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                    ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if applyImprovementInventoryFilter then
                    AnnounceImprovementBoosterUse(removedIcon, change, removedItemType, removedItemId, removedItemLink)
                else
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(removedItemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
                    if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                        -- ChatAnnouncements.ItemPrinter(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false)
                        logPrefix = ApplyCraftItemLossVerb(removedItemType, logPrefix)
                        ChatAnnouncements.ItemCounterDelay(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
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
            if not applyImprovementInventoryFilter then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
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

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                local previousItemLink = S.g_bankStacks[slotId].itemLink
                if applyImprovementInventoryFilter then
                    AnnounceImprovementQualityIncrease(previousItemLink, icon, itemType, itemId, itemLink)
                else
                    S.g_oldItem = { itemLink = previousItemLink, icon = icon }
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = logPrefixPos
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                if not applyImprovementInventoryFilter then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = logPrefixPos
                    if itemId == 33753 then
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                    end
                    -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                    ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if applyImprovementInventoryFilter then
                    AnnounceImprovementBoosterUse(icon, change, itemType, itemId, itemLink)
                else
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(itemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
                    if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                        -- ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                        logPrefix = ApplyCraftItemLossVerb(itemType, logPrefix)
                        ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
                    end
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
            if not applyImprovementInventoryFilter then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
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

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                local previousItemLink = S.g_banksubStacks[slotId].itemLink
                if applyImprovementInventoryFilter then
                    AnnounceImprovementQualityIncrease(previousItemLink, icon, itemType, itemId, itemLink)
                else
                    S.g_oldItem = { itemLink = previousItemLink, icon = icon }
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = logPrefixPos
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                if not applyImprovementInventoryFilter then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = logPrefixPos
                    if itemId == 33753 then
                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                    end
                    -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                    ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if applyImprovementInventoryFilter then
                    AnnounceImprovementBoosterUse(icon, change, itemType, itemId, itemLink)
                else
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = (not isSmithingDeconstruction and ResolveCraftingUsed(itemType) and ChatAnnouncements.GetContextMessage("CurrencyMessageUse")) or logPrefixNeg
                    if not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUse") or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                        logPrefix = ApplyCraftItemLossVerb(itemType, logPrefix)
                        ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
                    end
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
        local change
        local alwaysFirst

        if applyImprovementInventoryFilter then
            if stackCountChange < 0 then
                AnnounceImprovementBoosterUse(icon, stackCountChange * -1, itemType, itemId, itemLink)
            end
        else
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
    end

    S.g_itemWasDestroyed = false
    S.g_lockpickBroken = false
end

--- Snapshot the improvement slot before the item quality can change.
--- EVENT_CRAFT_STARTED args match ZO_CraftingResults_Base:OnCraftStarted(craftingType, context).
--- @param eventId integer
--- @param craftingType TradeskillType
--- @param context integer
function ChatAnnouncements.OnSmithingImprovementCraftStarted(eventId, craftingType, context)
    eventManager:UnregisterForUpdate(improvementResultUpdateName)
    S.g_improvementAttempt = nil
    S.g_improvementSucceeded = false
    if context == CRAFTING_PROCESS_CONTEXT_CONSUME_ATTUNABLE_STATIONS or not IsSmithingCraftingType(craftingType) or LUIE.IsSmithingDeconstructionContext() then
        return
    end
    if I.CheckLibLazyCraftingActive() or S.g_smithing.GetMode() ~= SMITHING_MODE_IMPROVEMENT then
        return
    end
    local improvementSlot = ZO_Smithing_GetActiveObject().improvementPanel.improvementSlot
    if not improvementSlot:HasItem() then
        return
    end
    local bagId, slotIndex = improvementSlot:GetBagAndSlot()
    local itemLink = GetItemLink(bagId, slotIndex, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
    local icon = GetItemInfo(bagId, slotIndex)
    S.g_improvementAttempt =
    {
        bagId = bagId,
        slotIndex = slotIndex,
        icon = icon,
        itemType = GetItemType(bagId, slotIndex),
        itemId = GetItemId(bagId, slotIndex),
        itemLink = itemLink,
        functionalQuality = GetItemLinkFunctionalQuality(itemLink),
    }
end

--- @param eventId integer
--- @param craftingType TradeskillType
function ChatAnnouncements.OnSmithingImprovementCraftCompleted(eventId, craftingType)
    if not S.g_improvementAttempt or not IsSmithingCraftingType(craftingType) then
        return
    end
    eventManager:RegisterForUpdate(improvementResultUpdateName, IMPROVEMENT_RESULT_DELAY_MS, ChatAnnouncements.ResolveSmithingImprovementResult, true)
end

--- Print a failed upgrade only when the slotted item's functional quality did not increase.
function ChatAnnouncements.ResolveSmithingImprovementResult()
    eventManager:UnregisterForUpdate(improvementResultUpdateName)
    local improvementAttempt = S.g_improvementAttempt
    local improvementSucceeded = S.g_improvementSucceeded
    S.g_improvementAttempt = nil
    S.g_improvementSucceeded = false
    if not improvementAttempt then
        return
    end

    local qualityIncreased = improvementSucceeded
    if not qualityIncreased then
        local currentItemLink = GetItemLink(improvementAttempt.bagId, improvementAttempt.slotIndex, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        if currentItemLink ~= "" and GetItemId(improvementAttempt.bagId, improvementAttempt.slotIndex) == improvementAttempt.itemId then
            qualityIncreased = GetItemLinkFunctionalQuality(currentItemLink) > improvementAttempt.functionalQuality
        end
    end
    if qualityIncreased then
        return
    end

    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
    local logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageUpgradeFail")
    ChatAnnouncements.ItemPrinter(improvementAttempt.icon, 1, improvementAttempt.itemType, improvementAttempt.itemId, improvementAttempt.itemLink, "LUIE_RECEIVE_CRAFT", logPrefix, gainOrLoss, false)
end
