-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State

local ColorizeColors = ChatAnnouncements.Colors

local string_format = string.format

--- @param logPrefix string
--- @return boolean
local function shouldShowLootDetailSuffixes(logPrefix)
    return not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgrade")
        and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgradeFail")
end

--- @param logPrefix string
--- @param receivedBy string
--- @param groupLoot boolean
--- @return boolean
local function shouldShowLootInventoryTotal(logPrefix, receivedBy, groupLoot)
    if not ChatAnnouncements.SV.Inventory.LootTotal then
        return false
    end
    if receivedBy == "LUIE_INVENTORY_UPDATE_DISGUISE" or receivedBy == "LUIE_RECEIVE_CRAFT" or groupLoot then
        return false
    end
    if ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageLearnRecipe")
    or ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageLearnMotif")
    or ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageLearnStyle") then
        return false
    end
    return true
end

--- @param gainOrLoss integer|nil
--- @return string
function ChatAnnouncements.GetLootGainOrLossColorHex(gainOrLoss)
    if gainOrLoss == 1 then
        return ColorizeColors.CurrencyUpColorize:ToHex()
    elseif gainOrLoss == 2 then
        return ColorizeColors.CurrencyDownColorize:ToHex()
    end
    return ColorizeColors.CurrencyColorize:ToHex()
end

--- @param receivedBy string|nil
--- @return string
function ChatAnnouncements.FormatLootRecipient(receivedBy)
    if receivedBy == "" or receivedBy == nil or receivedBy == "LUIE_RECEIVE_CRAFT" or receivedBy == "LUIE_INVENTORY_UPDATE_DISGUISE" then
        return ""
    end
    return receivedBy or ""
end

-- If filter is true, we run the item through this function to determine if we should display it. Filter only gets set to true for group loot and relevant loot functions. Mail, trade, stores, etc don't apply the filter.
--- @param itemType ItemType
--- @param itemId integer
--- @param itemLink string
--- @param groupLoot boolean
--- @return boolean
function ChatAnnouncements.ItemFilter(itemType, itemId, itemLink, groupLoot)
    if ChatAnnouncements.SV.Inventory.LootBlacklist and S.g_blacklistIDs[itemId] or (ChatAnnouncements.SV.Inventory.LootLogOverride and LootLog) then
        return false
    end
    local specializedItemType
    itemType, specializedItemType = GetItemLinkItemType(itemLink)
    local itemQuality = GetItemLinkFunctionalQuality(itemLink)
    local hasSet, setName, numBonuses, numNormalEquipped, maxEquipped, setId, numPerfectedEquipped = GetItemLinkSetInfo(itemLink, false)

    local itemIsKeyFragment = (itemType == ITEMTYPE_TROPHY) and (specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT)
    local itemIsSpecial = (itemType == ITEMTYPE_TROPHY and not itemIsKeyFragment) or (itemType == ITEMTYPE_COLLECTIBLE) or IsItemLinkConsumable(itemLink)

    if ChatAnnouncements.SV.Inventory.LootOnlyNotable or groupLoot then
        -- Notable items are: any set items, any purple+ items, blue+ special items (e.g., treasure maps)
        if hasSet or (itemQuality >= ITEM_FUNCTIONAL_QUALITY_ARCANE and itemIsSpecial) or (itemQuality >= ITEM_FUNCTIONAL_QUALITY_ARTIFACT and not itemIsKeyFragment) or (itemType == ITEMTYPE_COSTUME) or (itemType == ITEMTYPE_DISGUISE) or S.g_notableIDs[itemId] then
            return true
        end
        return false
    elseif ChatAnnouncements.SV.Inventory.LootNotTrash and (itemQuality == ITEM_FUNCTIONAL_QUALITY_TRASH) and not ((itemType == ITEMTYPE_ARMOR) or (itemType == ITEMTYPE_COSTUME) or (itemType == ITEMTYPE_DISGUISE)) then
        return false
    else
        return true
    end
end

--- @param itemLink string
--- @return integer collectionStatus 0 not collectible; 1/3 not collected; 2/4 collected
function ChatAnnouncements.GetItemLinkSetCollectionStatus(itemLink)
    if IsItemLinkSetCollectionPiece(itemLink) then
        if IsItemSetCollectionPieceUnlocked(GetItemLinkItemId(itemLink)) then
            return 4
        else
            return 3
        end
    else
        local id = GetItemLinkContainerCollectibleId(itemLink)
        if id > 0 then
            if IsCollectibleOwnedByDefId(id) then
                return 2
            elseif GetCollectibleCategoryType(id) == COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT and not CanCombinationFragmentBeUnlocked(id) then
                return 2
            else
                return 1
            end
        end
        return 0
    end
end

--- @param itemLink string
--- @return string
function ChatAnnouncements.GetFormattedCollectionStatusIcon(itemLink)
    if not ChatAnnouncements.SV.Inventory.LootShowCollectionStatus or not itemLink or itemLink == "" then
        return ""
    end
    local status = ChatAnnouncements.GetItemLinkSetCollectionStatus(itemLink)
    if status == 0 then
        return ""
    end
    if status == 2 or status == 4 then
        return zo_strformat("<<1>> ", ZO_SUCCEEDED_TEXT:Colorize(zo_iconFormatInheritColor(ZO_CHECK_ICON, 16, 16)))
    end
    return zo_strformat("<<1>> ", ZO_ERROR_COLOR:Colorize(zo_iconFormatInheritColor("EsoUI/Art/Buttons/decline_up.dds", 16, 16)))
end

--- @param text1 string|nil
--- @param text2 string|nil
--- @param text3 string|nil
--- @return string
function ChatAnnouncements.FormatLootItemTypeSlotLine(text1, text2, text3)
    if not text1 or text1 == "" then
        return ""
    end

    if text2 then
        if text3 then
            return zo_strformat(SI_ITEM_FORMAT_STR_TEXT1_TEXT2_ITEMSTYLE, text1, text2, text3)
        else
            return zo_strformat(SI_ITEM_FORMAT_STR_TEXT1_TEXT2, text1, text2)
        end
    end
    return zo_strformat(SI_ITEM_FORMAT_STR_TEXT1, text1)
end

--- Tooltip-style type line (see EsoUI PublicAllIngames/Tooltip/ItemTooltips.lua AddTopSection).
--- @param itemLink string
--- @return string
function ChatAnnouncements.GetLootItemTypeDisplayText(itemLink)
    if not itemLink or itemLink == "" then
        return ""
    end

    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if itemType == ITEMTYPE_NONE then
        return ""
    end

    local specializedItemTypeText = ZO_GetSpecializedItemTypeText(itemType, specializedItemType)
    local equipType = GetItemLinkEquipType(itemLink)
    local text1
    local text2
    local text3

    if itemType == ITEMTYPE_SIEGE then
        local siegeType = GetItemLinkSiegeType(itemLink)
        if siegeType ~= SIEGE_TYPE_NONE then
            return GetString("SI_SIEGETYPE", siegeType)
        end
        return ""
    elseif itemType == ITEMTYPE_COSTUME then
        text1 = specializedItemTypeText
    elseif itemType == ITEMTYPE_RECIPE then
        if IsItemLinkRecipeKnown(itemLink) then
            text1 = specializedItemTypeText
        else
            text1 = GetString(SI_ITEM_FORMAT_STR_UNKNOWN_RECIPE)
        end
        text2 = GetCraftingSkillName(GetItemLinkRecipeCraftingSkillType(itemLink))
    elseif itemType == ITEMTYPE_FURNISHING then
        text1 = GetString("SI_ITEMTYPE", itemType)
        local furnitureDataId = GetItemLinkFurnitureDataId(itemLink)
        local categoryId, subcategoryId = GetFurnitureDataCategoryInfo(furnitureDataId)
        text2 = GetFurnitureCategoryName(categoryId)
        local furnitureSubcategoryText = GetFurnitureCategoryName(subcategoryId)
        if furnitureSubcategoryText ~= "" then
            text3 = furnitureSubcategoryText
        end
    elseif equipType ~= EQUIP_TYPE_INVALID then
        local weaponType = GetItemLinkWeaponType(itemLink)
        if itemType == ITEMTYPE_ARMOR and weaponType == WEAPONTYPE_NONE then
            text1 = GetString("SI_EQUIPTYPE", equipType)
            local armorType = GetItemLinkArmorType(itemLink)
            if armorType ~= ARMORTYPE_NONE then
                text2 = GetString("SI_ARMORTYPE", armorType)
            end
        elseif weaponType ~= WEAPONTYPE_NONE then
            text1 = GetString("SI_WEAPONTYPE", weaponType)
            text2 = GetString("SI_EQUIPTYPE", equipType)
        elseif itemType == ITEMTYPE_POISON or itemType == ITEMTYPE_DISGUISE then
            text1 = specializedItemTypeText
        end
    elseif itemType == ITEMTYPE_LURE and IsItemLinkConsumable(itemLink) then
        text1 = GetString(SI_ITEM_SUB_TYPE_BAIT)
    elseif GetItemLinkBookTitle(itemLink) then
        if specializedItemType ~= SPECIALIZED_ITEMTYPE_NONE then
            text1 = specializedItemTypeText
        else
            text1 = GetString(SI_ITEM_SUB_TYPE_BOOK)
        end
    elseif DoesItemLinkStartQuest(itemLink) then
        text1 = GetString(SI_ITEM_FORMAT_STR_QUEST_STARTER_ITEM)
    elseif DoesItemLinkFinishQuest(itemLink) then
        text1 = GetString(SI_ITEM_FORMAT_STR_QUEST_ITEM)
    else
        local craftingSkillType = GetItemLinkCraftingSkillType(itemLink)
        if craftingSkillType ~= CRAFTING_TYPE_INVALID then
            text1 = specializedItemTypeText
            text2 = GetCraftingSkillName(craftingSkillType)
        else
            text1 = specializedItemTypeText
        end
    end

    local displayText = ChatAnnouncements.FormatLootItemTypeSlotLine(text1, text2, text3)
    if displayText == "" then
        return ""
    end

    if itemType == ITEMTYPE_TREASURE then
        local treasureTagDescriptions = {}
        local numItemTags = GetItemLinkNumItemTags(itemLink)
        for tagIndex = 1, numItemTags do
            local itemTagDescription, itemTagCategory = GetItemLinkItemTagInfo(itemLink, tagIndex)
            if itemTagDescription ~= "" and itemTagCategory == TAG_CATEGORY_MIN_VALUE then
                treasureTagDescriptions[#treasureTagDescriptions + 1] = itemTagDescription
            end
        end
        if #treasureTagDescriptions > 0 then
            table.sort(treasureTagDescriptions)
            local treasureTypeList = table.concat(treasureTagDescriptions, GetString(SI_LIST_COMMA_SEPARATOR))
            displayText = zo_strformat(SI_ITEM_FORMAT_STR_TEXT1_TEXT2, displayText, treasureTypeList)
        end
    end

    return displayText
end

--- @param icon string
--- @param stack integer
--- @param itemType ItemType
--- @param itemLink string
--- @param receivedBy string
--- @param logPrefix string
--- @param gainOrLoss integer
--- @param groupLoot boolean
--- @param showCollectionStatus boolean|nil
--- @return string itemString
--- @return string formattedTotal
--- @return string formattedRecipient
--- @return string color
function ChatAnnouncements.BuildLootItemDisplayString(icon, stack, itemType, itemLink, receivedBy, logPrefix, gainOrLoss, groupLoot, showCollectionStatus)
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon ~= "") and zo_strformat("<<1>> ", zo_iconFormat(icon, 16, 16)) or ""
    local color = ChatAnnouncements.GetLootGainOrLossColorHex(gainOrLoss)
    local formattedRecipient = ChatAnnouncements.FormatLootRecipient(receivedBy)

    local formattedQuantity = stack > 1 and string_format(" |cFFFFFFx%d|r", stack) or ""

    local showDetailSuffixes = shouldShowLootDetailSuffixes(logPrefix)

    local armorType = GetItemLinkArmorType(itemLink)
    local formattedArmorType = (ChatAnnouncements.SV.Inventory.LootShowArmorType and armorType ~= ARMORTYPE_NONE and showDetailSuffixes) and string_format(" |cFFFFFF(%s)|r", GetString("SI_ARMORTYPE", armorType)) or ""

    local traitType = GetItemLinkTraitInfo(itemLink)
    local formattedTrait = (ChatAnnouncements.SV.Inventory.LootShowTrait and traitType ~= ITEM_TRAIT_TYPE_NONE and itemType ~= ITEMTYPE_ARMOR_TRAIT and itemType ~= ITEMTYPE_WEAPON_TRAIT and itemType ~= ITEMTYPE_JEWELRY_TRAIT and showDetailSuffixes) and string_format(" |cFFFFFF(%s)|r", GetString("SI_ITEMTRAITTYPE", traitType)) or ""

    local styleType = GetItemLinkItemStyle(itemLink)
    local unformattedStyle = zo_strformat("<<1>>", GetItemStyleName(styleType))
    local formattedStyle = (ChatAnnouncements.SV.Inventory.LootShowStyle and styleType ~= 0 and styleType ~= 10 and styleType ~= GetUniversalStyleId() and itemType ~= ITEMTYPE_STYLE_MATERIAL and itemType ~= ITEMTYPE_GLYPH_ARMOR and itemType ~= ITEMTYPE_GLYPH_JEWELRY and itemType ~= ITEMTYPE_GLYPH_WEAPON and showDetailSuffixes) and string_format(" |cFFFFFF(%s)|r", unformattedStyle) or ""

    local itemTypeLabel = ChatAnnouncements.GetLootItemTypeDisplayText(itemLink)
    local formattedItemType = (ChatAnnouncements.SV.Inventory.LootShowItemType and itemTypeLabel ~= "" and showDetailSuffixes) and string_format(" |cFFFFFF(%s)|r", itemTypeLabel) or ""

    local formattedTotal = ""
    if shouldShowLootInventoryTotal(logPrefix, receivedBy, groupLoot) then
        local total1, total2, total3 = GetItemLinkStacks(itemLink)
        local total = total1 + total2 + total3
        if total > 1 then
            formattedTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    local formattedCollectionStatus = (showCollectionStatus and ChatAnnouncements.GetFormattedCollectionStatusIcon(itemLink)) or ""
    local itemString = string_format("%s%s%s%s%s%s%s%s", formattedIcon, formattedCollectionStatus, itemLink, formattedQuantity, formattedArmorType, formattedTrait, formattedStyle, formattedItemType)

    return itemString, formattedTotal, formattedRecipient, color
end
