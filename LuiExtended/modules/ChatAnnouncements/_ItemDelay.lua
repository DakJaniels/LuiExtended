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

local delayedItemPool = {}    -- Store items we are counting up when the player loots multiple bodies at once to print combined counts for any duplicate items
local delayedItemPoolOut = {} -- Stacks for outbound delayed item pool

-- ZOS enchanting station: potency -> essence -> aspect (Enchanting_Keyboard.lua creationSlotAnimation).
local DELAYED_POOL_ENCHANTING_RUNE_ORDER =
{
    [ITEMTYPE_ENCHANTING_RUNE_POTENCY] = 1,
    [ITEMTYPE_ENCHANTING_RUNE_ESSENCE] = 2,
    [ITEMTYPE_ENCHANTING_RUNE_ASPECT] = 3,
}

-- ZOS smithing/jewelry creation: material -> style -> trait (SmithingCreation_Keyboard.lua panel order).
local DELAYED_POOL_SMITHING_COMPONENT_ORDER =
{
    [ITEMTYPE_BLACKSMITHING_MATERIAL] = 1,
    [ITEMTYPE_CLOTHIER_MATERIAL] = 1,
    [ITEMTYPE_WOODWORKING_MATERIAL] = 1,
    [ITEMTYPE_JEWELRYCRAFTING_MATERIAL] = 1,
    [ITEMTYPE_BLACKSMITHING_RAW_MATERIAL] = 1,
    [ITEMTYPE_CLOTHIER_RAW_MATERIAL] = 1,
    [ITEMTYPE_WOODWORKING_RAW_MATERIAL] = 1,
    [ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL] = 1,
    [ITEMTYPE_RAW_MATERIAL] = 1,
    [ITEMTYPE_STYLE_MATERIAL] = 2,
    [ITEMTYPE_ARMOR_TRAIT] = 3,
    [ITEMTYPE_WEAPON_TRAIT] = 3,
    [ITEMTYPE_JEWELRY_TRAIT] = 3,
    [ITEMTYPE_JEWELRY_RAW_TRAIT] = 3,
}

-- ZOS alchemy station: solvent then reagents (Alchemy_Gamepad.lua slotAnimation: solventSlot, reagentSlots[1..n]).
local DELAYED_POOL_ALCHEMY_COMPONENT_ORDER =
{
    [ITEMTYPE_POTION_BASE] = 1,
    [ITEMTYPE_POISON_BASE] = 1,
    [ITEMTYPE_REAGENT] = 2,
}

-- Provisioner UI lists recipe ingredients by ingredientIndex (Provisioner.lua / GamepadProvisioner.lua).
-- Primary food/drink bases are shown before additives and rare seasonings (ItemFilterUtils.lua categories).
--- @param itemLink string
--- @return integer|nil
function I.GetProvisionerIngredientSortOrder(itemLink)
    if not itemLink or itemLink == "" then
        return nil
    end
    local itemType, specializedItemType = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_INGREDIENT then
        return nil
    end
    if specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT
    or specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE
    or specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT
    or specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL
    or specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_TEA
    or specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC then
        return 1
    end
    if specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE
    or specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE then
        return 2
    end
    if specializedItemType == SPECIALIZED_ITEMTYPE_INGREDIENT_RARE then
        return 3
    end
    return nil
end

--- @param itemType ItemType
--- @param itemLink string
--- @return integer|nil
function I.GetDelayedPoolDisplaySortOrder(itemType, itemLink)
    local order = DELAYED_POOL_ENCHANTING_RUNE_ORDER[itemType]
        or DELAYED_POOL_SMITHING_COMPONENT_ORDER[itemType]
        or DELAYED_POOL_ALCHEMY_COMPONENT_ORDER[itemType]
    if order then
        return order
    end
    return I.GetProvisionerIngredientSortOrder(itemLink)
end

-- ItemCounterDelay also batches loot and other items; rows with no entry above sort by itemId only.
--- @param pool table
function I.FlushDelayedItemPoolInDisplayOrder(pool)
    local ids = {}
    for itemId in pairs(pool) do
        table_insert(ids, itemId)
    end
    table.sort(ids, function (a, b)
        local da, db = pool[a], pool[b]
        local pa = I.GetDelayedPoolDisplaySortOrder(da.itemType, da.itemLink)
        local pb = I.GetDelayedPoolDisplaySortOrder(db.itemType, db.itemLink)
        if pa ~= nil and pb ~= nil then
            if pa ~= pb then
                return pa < pb
            end
        elseif pa ~= nil then
            return true
        elseif pb ~= nil then
            return false
        end
        return a < b
    end)
    for i = 1, #ids do
        local itemId = ids[i]
        local data = pool[itemId]
        ChatAnnouncements.ItemPrinter(data.icon, data.stack, data.itemType, itemId, data.itemLink, data.receivedBy, data.logPrefix, data.gainOrLoss, data.filter, data.groupLoot, data.alwaysFirst, data.delay, data.showCollectionStatus)
    end
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
--- @param lootMailId? id64
--- @param showCollectionStatus? boolean
function ChatAnnouncements.ItemCounterDelay(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, filter, groupLoot, alwaysFirst, delay, lootMailId, showCollectionStatus)
    -- Return if we have an invalid itemId or stack
    if itemId == 0 or not stack then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE:Log("Debug", "Item counter returned invalid items")
        -- end
        return
    end

    -- Mail loot: one chat line per attachment (never merge by itemId like generic delayedItemPool).
    if I.IsMailLootActive() and I.IsMailInLootLogPrefix(logPrefix) then
        S.g_mailLootLineSequence = S.g_mailLootLineSequence + 1
        S.g_mailDelayedLootLines[#S.g_mailDelayedLootLines + 1] =
        {
            mailId = lootMailId,
            order = S.g_mailLootLineSequence,
            icon = icon,
            itemType = itemType,
            itemLink = itemLink,
            stack = stack or 0,
            itemId = itemId,
            receivedBy = receivedBy,
            logPrefix = logPrefix,
            gainOrLoss = gainOrLoss,
            filter = filter,
            groupLoot = groupLoot,
            alwaysFirst = alwaysFirst,
            delay = delay,
        }
        if not S.g_mailBatchTakeAll then
            eventManager:RegisterForUpdate(moduleName .. "SendDelayedMailItems", 25, ChatAnnouncements.SendDelayedMailItems, true)
        end
        return
    end

    -- Add stack counts if item exists in pool, with nil check
    if delayedItemPool[itemId] and delayedItemPool[itemId].stack then
        stack = delayedItemPool[itemId].stack + stack
        showCollectionStatus = showCollectionStatus or delayedItemPool[itemId].showCollectionStatus
    end

    -- Save parameters to delayed item pool
    delayedItemPool[itemId] =
    {
        icon = icon,
        itemType = itemType,
        itemLink = itemLink,
        stack = stack or 0, -- Provide default value if nil
        receivedBy = receivedBy,
        logPrefix = logPrefix,
        gainOrLoss = gainOrLoss,
        filter = filter,
        groupLoot = groupLoot,
        alwaysFirst = alwaysFirst,
        delay = delay,
        showCollectionStatus = showCollectionStatus,
    }

    -- Pass along all values to SendDelayedItems()
    eventManager:RegisterForUpdate(moduleName .. "SendDelayedItems", 25, ChatAnnouncements.SendDelayedItems, true)
end

function ChatAnnouncements.SendDelayedItems()
    if S.g_mailBatchTakeAll then
        return
    end
    I.FlushDelayedItemPoolInDisplayOrder(delayedItemPool)
    delayedItemPool = {}
end

--- @param icon string
--- @param stack integer
--- @param itemType ItemType
--- @param itemId integer
--- @param itemLink string
--- @param receivedBy string
--- @param logPrefix string
--- @param gainOrLoss integer
--- @param filter boolean
--- @param groupLoot? boolean
--- @param alwaysFirst? boolean
--- @param delay? boolean
function ChatAnnouncements.ItemCounterDelayOut(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, filter, groupLoot, alwaysFirst, delay)
    if delayedItemPoolOut[itemId] then
        stack = delayedItemPoolOut[itemId].stack + stack -- Add stack count first, only if item already exists.
    end
    delayedItemPoolOut[itemId] =
    {
        icon = icon,
        itemType = itemType,
        itemLink = itemLink,
        stack = stack,
        receivedBy = receivedBy,
        logPrefix = logPrefix,
        gainOrLoss = gainOrLoss,
        filter = filter,
        groupLoot = groupLoot,
        alwaysFirst = alwaysFirst,
        delay = delay,
    } -- Save relevant parameters

    -- Pass along all values to SendDelayedItems()
    eventManager:RegisterForUpdate(moduleName .. "SendDelayedItemsOut", 25, ChatAnnouncements.SendDelayedItemsOut, true)
end

function ChatAnnouncements.SendDelayedItemsOut()
    I.FlushDelayedItemPoolInDisplayOrder(delayedItemPoolOut)
    delayedItemPoolOut = {}
end
