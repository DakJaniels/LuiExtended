-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local printToChat = LUIE.PrintToChat

local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type CrownStoreCollectibles
local isShopCollectible = Data.CrownStoreCollectibles
--- @type Effects
local Effects = Data.Effects
--- @type Quests
local Quests = Data.Quests

-- -----------------------------------------------------------------------------
-- ESO API Locals.
-- -----------------------------------------------------------------------------

local animationManager = GetAnimationManager()
local eventManager = GetEventManager()
local windowManager = GetWindowManager()

local GetString = GetString
local zo_strformat = zo_strformat



-- -----------------------------------------------------------------------------
-- Lua Locals.
-- -----------------------------------------------------------------------------

local pairs = pairs
local select = select
local tonumber = tonumber
local unpack = unpack
local string = string
local string_format = string.format
local table = table
local table_concat = table.concat
local table_insert = table.insert

--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local moduleName = ChatAnnouncements.moduleName

------------------------------------------------


------------------------------------------------

--- Gets the total stack count for an item link from backpack, bank, and craft bag.
--- @param itemlink string The item link to check stack counts for
--- @return integer count The total stack count (backpack + bank + craft bag)
--[[[
* GetItemLinkStacks(*string* _itemLink_)
** _Returns:_ *integer* _stackCountBackpack_, *integer* _stackCountBank_, *integer* _stackCountCraftBag_, *integer* _stackCountHouseBanks_, *integer* _stackCountFurnitureVault_, *integer* _stackCountVengeanceBag_

**Example:**
Acai Berry
Results of function `GetItemLinkStacks("|H1:item:34349:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")`:
- `0` -- stackCountBackpack
- `0` -- stackCountBank
- `9441` -- stackCountCraftBag
- `0` -- stackCountHouseBanks
- `0` -- stackCountFurnitureVault
- `0` -- stackCountVengeanceBag
]]
local function getItemLinkStackCount(itemlink)
    local stackCountBackpack, stackCountBank, stackCountCraftBag, stackCountHouseBanks, stackCountFurnitureVault, stackCountVengeanceBag = GetItemLinkStacks(itemlink)
    local count = (stackCountBackpack + stackCountBank + stackCountCraftBag) or 0
    return count
end

---
--- @param topLevelIndex integer
--- @return string name
local function GetAchievementCategoryInfoName(topLevelIndex)
    local AchievementCategoryInfo = { GetAchievementCategoryInfo(topLevelIndex) }
    local name = AchievementCategoryInfo[1]
    return name
end

---
--- @param topLevelIndex luaindex
--- @param subCategoryIndex luaindex
--- @return string name
local function GetAchievementSubCategoryInfoName(topLevelIndex, subCategoryIndex)
    local AchievementSubCategoryInfo = { GetAchievementSubCategoryInfo(topLevelIndex, subCategoryIndex) }
    local name = AchievementSubCategoryInfo[1]
    return name
end

---
--- @param achievementId integer
--- @return textureName icon
local function GetAchievementInfoIcon(achievementId)
    local AchievementInfo = { GetAchievementInfo(achievementId) }
    local icon = AchievementInfo[4]
    return icon
end

local function escapePercents(s)
    return s and s:gsub("%%", "%%%%") or s
end


local g_firstLoad = true

local ChatEventFormattersDelete =
{
    [EVENT_BATTLEGROUND_INACTIVITY_WARNING] = true,
    [EVENT_BROADCAST] = true,
    [EVENT_FRIEND_PLAYER_STATUS_CHANGED] = true,
    [EVENT_GROUP_INVITE_RESPONSE] = true,
    [EVENT_GROUP_MEMBER_LEFT] = true,
    [EVENT_GROUP_TYPE_CHANGED] = true,
    [EVENT_IGNORE_ADDED] = true,
    [EVENT_IGNORE_REMOVED] = true,
    [EVENT_SOCIAL_ERROR] = true,
    [EVENT_TRIAL_FEATURE_RESTRICTED] = true,
}

function ChatAnnouncements.SlayChatHandlers()
    -- Unregister ZOS handlers for events we need to modify
    for eventCode, _ in pairs(ChatEventFormattersDelete) do
        eventManager:UnregisterForEvent("ChatRouter", eventCode)
    end

    -- Slay these events in case LibChatMessage is active and hooks them
    local ChatEventFormatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    for eventType, _ in pairs(ChatEventFormattersDelete) do
        ChatEventFormatters[eventType] = nil
    end
end

function ChatAnnouncements.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        ChatAnnouncements.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "ChatAnnouncements", ChatAnnouncements.Defaults)
    else
        ChatAnnouncements.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "ChatAnnouncements", ChatAnnouncements.Defaults)
    end

    -- Some modules might need to pull some of the color settings from CA so we want these to always be set regardless of CA module being enabled/disabled.
    ChatAnnouncements.RegisterColorEvents()
    -- Always register this function for other components to use
    eventManager:RegisterForEvent(moduleName, EVENT_COLLECTIBLE_USE_RESULT, ChatAnnouncements.CollectibleUsed)

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    ChatAnnouncements.Enabled = true

    ChatAnnouncements.isWritCreatorEnabled = LUIE.IsItEnabled("DolgubonsLazyWritCreator")

    -- Get current group leader
    ChatAnnouncements.currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
    ChatAnnouncements.currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
    ChatAnnouncements.currentActivityId = GetCurrentLFGActivityId()

    -- PostHook Crafting Interface (Keyboard)
    ChatAnnouncements.CraftModeOverrides()

    -- Register events
    ChatAnnouncements.RegisterGoldEvents()
    ChatAnnouncements.RegisterLootEvents()
    ChatAnnouncements.Mail.Initialize()
    ChatAnnouncements.RegisterXPEvents()
    ChatAnnouncements.RegisterAchievementsEvent()
    -- TODO: Possibly don't register these unless enabled, I'm not sure -- at least move to better sorted order
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, ChatAnnouncements.StorageBag)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_BANK_CAPACITY_CHANGED, ChatAnnouncements.StorageBank)
    -- TODO: Move these too:
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, ChatAnnouncements.HandleClickEvent)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, ChatAnnouncements.HandleClickEvent)

    -- TODO: also move this
    eventManager:RegisterForEvent(moduleName, EVENT_SKILL_XP_UPDATE, ChatAnnouncements.SkillXPUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, ChatAnnouncements.OnPlayerActivated)

    -- TODO: Maybe move this, is needed for ALL INVENTORY & QUEST
    eventManager:RegisterForEvent(moduleName, EVENT_CHATTER_BEGIN, ChatAnnouncements.OnChatterBegin)
    eventManager:RegisterForEvent(moduleName, EVENT_CHATTER_END, ChatAnnouncements.OnChatterEnd)

    -- TEMP: Social Error Register
    eventManager:RegisterForEvent(moduleName, EVENT_SOCIAL_ERROR, ChatAnnouncements.OnErrorSocialChat)

    -- TEMP: Register Antiquity Dig Toggle
    eventManager:RegisterForEvent(moduleName, EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY, ChatAnnouncements.OnDigStart)
    eventManager:RegisterForEvent(moduleName, EVENT_ANTIQUITY_DIGGING_GAME_OVER, ChatAnnouncements.OnDigEnd)

    -- Timed Activity
    eventManager:RegisterForEvent(moduleName, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, ChatAnnouncements.OnTimedActivityProgressUpdated)

    -- Promotional Events Activity
    eventManager:RegisterForEvent(moduleName, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED, ChatAnnouncements.OnPromotionalEventsActivityProgressUpdated)

    eventManager:RegisterForEvent(moduleName, EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED, ChatAnnouncements.OnCraftedAbilityLockStateChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED, ChatAnnouncements.OnCraftedAbilityScriptLockStateChanged)

    ChatAnnouncements.RegisterGuildEvents()
    ChatAnnouncements.RegisterSocialEvents()
    ChatAnnouncements.RegisterDisguiseEvents()
    ChatAnnouncements.RegisterQuestEvents()

    ChatAnnouncements.HookFunction()

    -- Index members for Group Loot
    ChatAnnouncements.IndexGroupLoot()

    -- Stop other chat handlers from registering, then stop them again a few more times just in case.
    ChatAnnouncements.SlayChatHandlers()
    -- Call this again a few times shortly after load just in case.
    LUIE_callLater(ChatAnnouncements.SlayChatHandlers, 1000)
    LUIE_callLater(ChatAnnouncements.SlayChatHandlers, 5000)
end

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENT HANDLER AND COLOR REGISTRATION -----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

function ChatAnnouncements.RegisterColorEvents()
    local SV = ChatAnnouncements.SV -- store the SV table in a local variable for better performance

    ChatAnnouncements.Colors.CurrencyColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyColor))
    ChatAnnouncements.Colors.CurrencyUpColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyColorUp))
    ChatAnnouncements.Colors.CurrencyDownColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyColorDown))
    ChatAnnouncements.Colors.CollectibleColorize1 = ZO_ColorDef:New(unpack(SV.Collectibles.CollectibleColor1))
    ChatAnnouncements.Colors.CollectibleColorize2 = ZO_ColorDef:New(unpack(SV.Collectibles.CollectibleColor2))
    ChatAnnouncements.Colors.CollectibleUseColorize = ZO_ColorDef:New(unpack(SV.Collectibles.CollectibleUseColor))
    ChatAnnouncements.Colors.CurrencyGoldColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyGoldColor))
    ChatAnnouncements.Colors.CurrencyAPColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyAPColor))
    ChatAnnouncements.Colors.CurrencyTVColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTVColor))
    ChatAnnouncements.Colors.CurrencyWVColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyWVColor))
    ChatAnnouncements.Colors.CurrencyOutfitTokenColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyOutfitTokenColor))
    ChatAnnouncements.Colors.CurrencyUndauntedColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyUndauntedColor))
    ChatAnnouncements.Colors.CurrencyTransmuteColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTransmuteColor))
    ChatAnnouncements.Colors.CurrencyEventColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyEventColor))
    ChatAnnouncements.Colors.CurrencyCrownsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyCrownsColor))
    ChatAnnouncements.Colors.CurrencyCrownGemsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyCrownGemsColor))
    ChatAnnouncements.Colors.CurrencyEndeavorsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyEndeavorsColor))
    ChatAnnouncements.Colors.CurrencyEndlessColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyEndlessColor))
    ChatAnnouncements.Colors.DisguiseAlertColorize = ZO_ColorDef:New(unpack(SV.Notify.DisguiseAlertColor))
    ChatAnnouncements.Colors.AchievementColorize1 = ZO_ColorDef:New(unpack(SV.Achievement.AchievementColor1))
    ChatAnnouncements.Colors.AchievementColorize2 = ZO_ColorDef:New(unpack(SV.Achievement.AchievementColor2))
    ChatAnnouncements.Colors.LorebookColorize1 = ZO_ColorDef:New(unpack(SV.Lorebooks.LorebookColor1))
    ChatAnnouncements.Colors.LorebookColorize2 = ZO_ColorDef:New(unpack(SV.Lorebooks.LorebookColor2))
    ChatAnnouncements.Colors.ExperienceMessageColorize = ZO_ColorDef:New(unpack(SV.XP.ExperienceColorMessage)):ToHex()
    ChatAnnouncements.Colors.ExperienceNameColorize = ZO_ColorDef:New(unpack(SV.XP.ExperienceColorName)):ToHex()
    ChatAnnouncements.Colors.ExperienceLevelUpColorize = ZO_ColorDef:New(unpack(SV.XP.ExperienceLevelUpColor))
    ChatAnnouncements.Colors.SkillPointColorize1 = ZO_ColorDef:New(unpack(SV.Skills.SkillPointColor1))
    ChatAnnouncements.Colors.SkillPointColorize2 = ZO_ColorDef:New(unpack(SV.Skills.SkillPointColor2))
    ChatAnnouncements.Colors.SkillLineColorize = ZO_ColorDef:New(unpack(SV.Skills.SkillLineColor))
    ChatAnnouncements.Colors.SkillGuildColorize = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColor)):ToHex()
    ChatAnnouncements.Colors.SkillGuildColorizeFG = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorFG)):ToHex()
    ChatAnnouncements.Colors.SkillGuildColorizeMG = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorMG)):ToHex()
    ChatAnnouncements.Colors.SkillGuildColorizeUD = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorUD)):ToHex()
    ChatAnnouncements.Colors.SkillGuildColorizeTG = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorTG)):ToHex()
    ChatAnnouncements.Colors.SkillGuildColorizeDB = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorDB)):ToHex()
    ChatAnnouncements.Colors.SkillGuildColorizePO = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorPO)):ToHex()
    ChatAnnouncements.Colors.QuestColorLocNameColorize = ZO_ColorDef:New(unpack(SV.Quests.QuestColorLocName)):ToHex()
    ChatAnnouncements.Colors.QuestColorLocDescriptionColorize = ZO_ColorDef:New(unpack(SV.Quests.QuestColorLocDescription)):ToHex()
    ChatAnnouncements.Colors.QuestColorQuestNameColorize = ZO_ColorDef:New(unpack(SV.Quests.QuestColorName))
    ChatAnnouncements.Colors.QuestColorQuestDescriptionColorize = ZO_ColorDef:New(unpack(SV.Quests.QuestColorDescription)):ToHex()
    ChatAnnouncements.Colors.StorageRidingColorize = ZO_ColorDef:New(unpack(SV.Notify.StorageRidingColor))
    ChatAnnouncements.Colors.StorageRidingBookColorize = ZO_ColorDef:New(unpack(SV.Notify.StorageRidingBookColor))
    ChatAnnouncements.Colors.StorageBagColorize = ZO_ColorDef:New(unpack(SV.Notify.StorageBagColor))
    ChatAnnouncements.Colors.GuildColorize = ZO_ColorDef:New(unpack(SV.Social.GuildColor))
    ChatAnnouncements.Colors.AntiquityColorize = ZO_ColorDef:New(unpack(SV.Antiquities.AntiquityColor))
end

function ChatAnnouncements.RegisterSocialEvents()
    eventManager:RegisterForEvent(moduleName, EVENT_FRIEND_ADDED, ChatAnnouncements.FriendAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_FRIEND_REMOVED, ChatAnnouncements.FriendRemoved)
    eventManager:RegisterForEvent(moduleName, EVENT_INCOMING_FRIEND_INVITE_ADDED, ChatAnnouncements.FriendInviteAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_IGNORE_ADDED, ChatAnnouncements.IgnoreAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_IGNORE_REMOVED, ChatAnnouncements.IgnoreRemoved)
    eventManager:RegisterForEvent(moduleName, EVENT_FRIEND_PLAYER_STATUS_CHANGED, ChatAnnouncements.FriendPlayerStatus)
end

function ChatAnnouncements.RegisterQuestEvents()
    eventManager:RegisterForEvent(moduleName, EVENT_QUEST_SHARED, ChatAnnouncements.QuestShared)
    -- Create a table for quests
    for i = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(i) then
            local name = GetJournalQuestName(i)
            local questType = GetJournalQuestType(i)
            local instanceDisplayType = GetJournalQuestZoneDisplayType(i)

            if name == "" then
                name = GetString(SI_QUEST_JOURNAL_UNKNOWN_QUEST_NAME)
            end

            ChatAnnouncements.questIndex[name] =
            {
                questType = questType,
                instanceDisplayType = instanceDisplayType,
            }
        end
    end
end

function ChatAnnouncements.RegisterGuildEvents()
    -- TODO: Possibly implement conditionals here again in the future
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_SELF_JOINED_GUILD, ChatAnnouncements.GuildAddedSelf)
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_INVITE_ADDED, ChatAnnouncements.GuildInviteAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_RANK_CHANGED, ChatAnnouncements.GuildRankChanged)
    -- eventManager:RegisterForEvent(moduleName, EVENT_HERALDRY_SAVED, ChatAnnouncements.GuildHeraldrySaved) -- TODO: Fix later
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_RANKS_CHANGED, ChatAnnouncements.GuildRanksSaved)
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_RANK_CHANGED, ChatAnnouncements.GuildRankSaved)
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_DESCRIPTION_CHANGED, ChatAnnouncements.GuildTextChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_MOTD_CHANGED, ChatAnnouncements.GuildTextChanged)
end

function ChatAnnouncements.RegisterAchievementsEvent()
    eventManager:UnregisterForEvent(moduleName, EVENT_ACHIEVEMENT_UPDATED)
    if ChatAnnouncements.SV.Achievement.AchievementUpdateCA or ChatAnnouncements.SV.Achievement.AchievementUpdateAlert then
        eventManager:RegisterForEvent(moduleName, EVENT_ACHIEVEMENT_UPDATED, ChatAnnouncements.OnAchievementUpdated)
    end
end

function ChatAnnouncements.RegisterGoldEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_CURRENCY_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_LOOT_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_ADDED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_REMOVED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_CLOSE_MAILBOX)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_SEND_SUCCESS)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_COD_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_REMOVED)

    eventManager:RegisterForEvent(moduleName, EVENT_CURRENCY_UPDATE, function (_, currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
        ChatAnnouncements.OnCurrencyUpdate(currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_LOOT_UPDATED, ChatAnnouncements.OnLootUpdated)
end

function ChatAnnouncements.RegisterLootEvents()
    -- NON CONDITIONAL EVENTS
    -- LOCKPICK
    eventManager:RegisterForEvent(moduleName, EVENT_LOCKPICK_BROKE, ChatAnnouncements.MiscAlertLockBroke)
    eventManager:RegisterForEvent(moduleName, EVENT_LOCKPICK_SUCCESS, ChatAnnouncements.MiscAlertLockSuccess)
    -- LOOT RECEIVED
    eventManager:UnregisterForEvent(moduleName, EVENT_LOOT_RECEIVED)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED)
    -- QUEST REWARD CONTEXT
    -- INDEX
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    -- VENDOR
    eventManager:UnregisterForEvent(moduleName, EVENT_BUYBACK_RECEIPT)
    eventManager:UnregisterForEvent(moduleName, EVENT_BUY_RECEIPT)
    eventManager:UnregisterForEvent(moduleName, EVENT_SELL_RECEIPT)
    eventManager:UnregisterForEvent(moduleName, EVENT_OPEN_FENCE)
    eventManager:UnregisterForEvent(moduleName, EVENT_CLOSE_STORE)
    eventManager:UnregisterForEvent(moduleName, EVENT_OPEN_STORE)
    eventManager:UnregisterForEvent(moduleName, EVENT_CLOSE_TRADING_HOUSE)
    eventManager:UnregisterForEvent(moduleName, EVENT_OPEN_TRADING_HOUSE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ITEM_LAUNDER_RESULT)
    -- TRADING POST
    eventManager:UnregisterForEvent(moduleName, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED)
    -- BANK
    eventManager:UnregisterForEvent(moduleName, EVENT_OPEN_BANK)
    eventManager:UnregisterForEvent(moduleName, EVENT_CLOSE_BANK)
    eventManager:UnregisterForEvent(moduleName, EVENT_OPEN_GUILD_BANK)
    eventManager:UnregisterForEvent(moduleName, EVENT_CLOSE_GUILD_BANK)
    eventManager:UnregisterForEvent(moduleName, EVENT_GUILD_BANK_ITEM_ADDED)
    eventManager:UnregisterForEvent(moduleName, EVENT_GUILD_BANK_ITEM_REMOVED)
    -- CRAFT
    eventManager:UnregisterForEvent(moduleName, EVENT_CRAFTING_STATION_INTERACT)
    eventManager:UnregisterForEvent(moduleName, EVENT_END_CRAFTING_STATION_INTERACT)
    -- TRADE
    eventManager:UnregisterForEvent(moduleName, EVENT_TRADE_ITEM_ADDED)
    eventManager:UnregisterForEvent(moduleName, EVENT_TRADE_ITEM_REMOVED)
    -- JUSTICE
    eventManager:UnregisterForEvent(moduleName, EVENT_JUSTICE_STOLEN_ITEMS_REMOVED)
    -- LOOT FAILED
    eventManager:UnregisterForEvent(moduleName, EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_IS_FULL)
    eventManager:UnregisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED)

    -- LOOT RECEIVED
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootQuestAdd or ChatAnnouncements.SV.Inventory.LootQuestRemove then
        eventManager:RegisterForEvent(moduleName, EVENT_LOOT_RECEIVED, ChatAnnouncements.OnLootReceived)
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED, ChatAnnouncements.OnInventoryItemUsed)
    end
    -- QUEST LOOT
    if ChatAnnouncements.SV.Inventory.LootQuestAdd or ChatAnnouncements.SV.Inventory.LootQuestRemove then
        ChatAnnouncements.AddQuestItemsToIndex()
    end
    -- INDEX
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL, ChatAnnouncements.InventoryFullQuest)
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_IS_FULL, ChatAnnouncements.InventoryFull)
        eventManager:RegisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED, ChatAnnouncements.LootItemFailed)
        ChatAnnouncements.equippedStacks = {}
        ChatAnnouncements.inventoryStacks = {}
        ChatAnnouncements.IndexEquipped()
        ChatAnnouncements.IndexInventory()
    end
    -- VENDOR
    if ChatAnnouncements.SV.Inventory.LootVendor then
        eventManager:RegisterForEvent(moduleName, EVENT_BUYBACK_RECEIPT, ChatAnnouncements.OnBuybackItem)
        eventManager:RegisterForEvent(moduleName, EVENT_BUY_RECEIPT, ChatAnnouncements.OnBuyItem)
        eventManager:RegisterForEvent(moduleName, EVENT_SELL_RECEIPT, ChatAnnouncements.OnSellItem)
        eventManager:RegisterForEvent(moduleName, EVENT_ITEM_LAUNDER_RESULT, ChatAnnouncements.FenceSuccess)
    end
    -- TRADING POST
    if ChatAnnouncements.SV.Inventory.LootShowList then
        eventManager:RegisterForEvent(moduleName, EVENT_TRADING_HOUSE_RESPONSE_RECEIVED, ChatAnnouncements.TradingHouseResponseReceived)
    end
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootVendor then
        eventManager:RegisterForEvent(moduleName, EVENT_OPEN_FENCE, ChatAnnouncements.FenceOpen)
        eventManager:RegisterForEvent(moduleName, EVENT_OPEN_STORE, ChatAnnouncements.StoreOpen)
        eventManager:RegisterForEvent(moduleName, EVENT_CLOSE_STORE, ChatAnnouncements.StoreClose)
        eventManager:RegisterForEvent(moduleName, EVENT_OPEN_TRADING_HOUSE, ChatAnnouncements.GuildStoreOpen)
        eventManager:RegisterForEvent(moduleName, EVENT_CLOSE_TRADING_HOUSE, ChatAnnouncements.GuildStoreClose)
    end
    -- BANK
    if ChatAnnouncements.SV.Inventory.LootBank then
        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_BANK_ITEM_ADDED, ChatAnnouncements.GuildBankItemAdded)
        eventManager:RegisterForEvent(moduleName, EVENT_GUILD_BANK_ITEM_REMOVED, ChatAnnouncements.GuildBankItemRemoved)
    end
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootBank then
        eventManager:RegisterForEvent(moduleName, EVENT_OPEN_BANK, ChatAnnouncements.BankOpen)
        eventManager:RegisterForEvent(moduleName, EVENT_CLOSE_BANK, ChatAnnouncements.BankClose)
        eventManager:RegisterForEvent(moduleName, EVENT_OPEN_GUILD_BANK, ChatAnnouncements.GuildBankOpen)
        eventManager:RegisterForEvent(moduleName, EVENT_CLOSE_GUILD_BANK, ChatAnnouncements.GuildBankClose)
    end
    if ChatAnnouncements.SV.Inventory.LootTrade then
        eventManager:RegisterForEvent(moduleName, EVENT_TRADE_ITEM_ADDED, ChatAnnouncements.OnTradeAdded)
        eventManager:RegisterForEvent(moduleName, EVENT_TRADE_ITEM_REMOVED, ChatAnnouncements.OnTradeRemoved)
    end
    -- TRADE
    eventManager:RegisterForEvent(moduleName, EVENT_TRADE_INVITE_ACCEPTED, ChatAnnouncements.TradeInviteAccepted)
    -- CRAFT
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootCraft then
        eventManager:RegisterForEvent(moduleName, EVENT_CRAFTING_STATION_INTERACT, ChatAnnouncements.CraftingOpen)
        eventManager:RegisterForEvent(moduleName, EVENT_END_CRAFTING_STATION_INTERACT, ChatAnnouncements.CraftingClose)
    end
    -- DESTROY
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_DESTROYED, ChatAnnouncements.DestroyItem)
    -- PACK SIEGE
    eventManager:RegisterForEvent(moduleName, EVENT_DISABLE_SIEGE_PACKUP_ABILITY, ChatAnnouncements.OnPackSiege)
    -- JUSTICE
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Notify.NotificationConfiscateCA or ChatAnnouncements.SV.Notify.NotificationConfiscateAlert or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_JUSTICE_STOLEN_ITEMS_REMOVED, ChatAnnouncements.JusticeStealRemove)
    end
end

function ChatAnnouncements.RegisterDisguiseEvents()
    eventManager:UnregisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED)
    if ChatAnnouncements.SV.Notify.DisguiseCA or ChatAnnouncements.SV.Notify.DisguiseCSA or ChatAnnouncements.SV.Notify.DisguiseAlert or ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnCSA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
        eventManager:RegisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, ChatAnnouncements.DisguiseState)
        eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        ChatAnnouncements.currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0 -- Get the currently equipped disguise itemId if any
        if g_firstLoad then
            ChatAnnouncements.disguiseState = 0
            g_firstLoad = false
        else
            ChatAnnouncements.disguiseState = GetUnitDisguiseState("player") -- Get current player disguise state
            if ChatAnnouncements.disguiseState > 0 then
                ChatAnnouncements.disguiseState = 1                          -- Simplify all the various states into a basic 0 = false, 1 = true value
            end
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------

-- Called by most functions that use character or display name to resolve LINK display method.
--
--- @param characterName string The character name
--- @param displayName string The display name
--- @return string nameLink The resolved name link
function ChatAnnouncements.ResolveNameLink(characterName, displayName)
    local useBrackets = ChatAnnouncements.SV.BracketOptionCharacter ~= 1
    local displayOption = ChatAnnouncements.SV.ChatPlayerDisplayOptions

    if displayOption == 1 then
        return useBrackets and ZO_LinkHandler_CreateDisplayNameLink(displayName) or
            ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
    elseif displayOption == 2 then
        return useBrackets and ZO_LinkHandler_CreateCharacterLink(characterName) or
            ZO_LinkHandler_CreateLinkWithoutBrackets(characterName, nil, CHARACTER_LINK_TYPE, characterName)
    else
        local displayBothString = zo_strformat("<<1>><<2>>", characterName, displayName)
        return useBrackets and ZO_LinkHandler_CreateLink(displayBothString, nil, DISPLAY_NAME_LINK_TYPE, displayName) or
            ZO_LinkHandler_CreateLinkWithoutBrackets(displayBothString, nil, DISPLAY_NAME_LINK_TYPE, displayName)
    end
end

-- Called by most functions that use character or display name to resolve NON-LINK display method (mostly used for alerts).
--
--- @param characterName string The character name
--- @param displayName string The display name
--- @return string nameLink The resolved name string
function ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
    local displayOption = ChatAnnouncements.SV.ChatPlayerDisplayOptions

    if displayOption == 1 then
        return displayName
    elseif displayOption == 2 then
        return characterName
    else
        return zo_strformat("<<1>><<2>>", characterName, displayName)
    end
end

local function ShouldShowSocialErrorInChat(error)
    return not ShouldShowSocialErrorInAlert(error)
end

-- TODO: Better function later when we implement more error handlers
-- EVENT_SOCIAL_ERROR - New handler to replace the chat handler
function ChatAnnouncements.OnErrorSocialChat(eventCode, error)
    if not IsSocialErrorIgnoreResponse(error) and ShouldShowSocialErrorInChat(error) then
        printToChat(zo_strformat(GetString("SI_SOCIALACTIONRESULT", error)))
    end
end

function ChatAnnouncements.OnDigStart()
    ChatAnnouncements.weAreInADig = true
end

--- - **EVENT_ANTIQUITY_DIGGING_GAME_OVER **
---
--- @param eventId integer
--- @param gameOverFlags DiggingGameOverFlags
function ChatAnnouncements.OnDigEnd(eventId, gameOverFlags)
    LUIE_callLater(function ()
                       ChatAnnouncements.weAreInADig = false
                   end, 1000)
end

-- TODO: Fix later
--[[
function ChatAnnouncements.GuildHeraldrySaved()
    if ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        local value = g_pendingHeraldryCost > 0 and g_pendingHeraldryCost or 1000
        local messageType = "LUIE_CURRENCY_HERALDRY"
        local formattedValue = nil -- Un-needed, we're not going to try to show the total guild bank gold here.
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(value)
        local currencyTypeColor = ChatAnnouncements.Colors.CurrencyGoldColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_MONEY), 16,16) or ""
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, value)
        local currencyTotal = nil
        local messageTotal = ""
        local messageChange = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_HERALDRY)
        ChatAnnouncements.CurrencyPrinter(formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
    end

    if ChatAnnouncements.selectedGuild ~= nil then
        local id = ChatAnnouncements.selectedGuild
        local guildName = GetGuildName(id)

        local guildAlliance = GetGuildAlliance(id)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if ChatAnnouncements.SV.Social.GuildManageCA then
            local finalMessage = zo_strformat(GetString(LUIE_STRING_CA_GUILD_HERALDRY_UPDATE), guildNameAlliance)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages )
        end
        if ChatAnnouncements.SV.Social.GuildManageAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_HERALDRY_UPDATE), guildNameAllianceAlert))
        end
    end
end
]]
--



function ChatAnnouncements.GuildRanksSaved(eventCode, guildId)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

    if ChatAnnouncements.SV.Social.GuildManageCA then
        local finalMessage = zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANKS_UPDATE), guildNameAlliance)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = finalMessage,
            messageType = "NOTIFICATION",
            isSystem = true
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    if ChatAnnouncements.SV.Social.GuildManageAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANKS_UPDATE), guildNameAllianceAlert))
    end
end

function ChatAnnouncements.GuildRankSaved(eventCode, guildId, rankIndex)
    local rankName
    local rankNameDefault = GetDefaultGuildRankName(guildId, rankIndex)
    local rankNameCustom = GetGuildRankCustomName(guildId, rankIndex)

    if rankNameCustom == "" then
        rankName = rankNameDefault
    else
        rankName = rankNameCustom
    end

    local icon = GetGuildRankIconIndex(guildId, rankIndex)
    local icon1 = GetGuildRankLargeIcon(icon)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon1, 16, 16), rankName)) or (guildColor:Colorize(rankName))
    local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon1, "100%", "100%", rankName) or rankName

    if ChatAnnouncements.SV.Social.GuildManageCA then
        printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UPDATE), rankSyntax, guildNameAlliance), true)
    end
    if ChatAnnouncements.SV.Social.GuildManageAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UPDATE), rankSyntaxAlert, guildNameAllianceAlert))
    end
end

function ChatAnnouncements.GuildTextChanged(eventCode, guildId)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    -- Depending on event code set message context.
    local messageString = eventCode == EVENT_GUILD_DESCRIPTION_CHANGED and LUIE_STRING_CA_GUILD_DESCRIPTION_CHANGED or EVENT_GUILD_MOTD_CHANGED and LUIE_STRING_CA_GUILD_MOTD_CHANGED or nil

    if messageString ~= nil then
        if ChatAnnouncements.SV.Social.GuildManageCA then
            local finalMessage = zo_strformat(GetString(messageString), guildNameAlliance)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = finalMessage,
                messageType = "NOTIFICATION",
                isSystem = true
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Social.GuildManageAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(messageString), guildNameAllianceAlert))
        end
    end
end

function ChatAnnouncements.GuildRankChanged(eventCode, guildId, displayName, newRank)
    -- Don't show this for the player since EVENT_GUILD_PLAYER_RANK_CHANGED will handle that
    if displayName == LUIE.PlayerDisplayName then
        return
    end
    -- If the player just updated someones rank then we hide this generic message.
    if ChatAnnouncements.disableRankMessage == true then
        ChatAnnouncements.disableRankMessage = false
        return
    end

    local memberIndex = GetPlayerGuildMemberIndex(guildId)
    local rankIndex = select(3, GetGuildMemberInfo(guildId, memberIndex))

    local hasPermission1 = DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_PROMOTE)
    local hasPermission2 = DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_DEMOTE)

    if ((hasPermission1 or hasPermission2) and ChatAnnouncements.SV.Social.GuildRankDisplayOptions == 2) or (ChatAnnouncements.SV.Social.GuildRankDisplayOptions == 3) then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        end
        local rankText = GetFinalGuildRankName(guildId, newRank)

        local icon = GetFinalGuildRankTextureSmall(guildId, newRank)
        local guildName = GetGuildName(guildId)

        local guilds = GetNumGuilds()
        for i = 1, guilds do
            local id = GetGuildId(i)
            local name = GetGuildName(id)

            local guildAlliance = GetGuildAlliance(id)
            local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
            local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
            local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
            local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
            local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

            if guildName == name then
                if ChatAnnouncements.SV.Social.GuildRankCA then
                    printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED), displayNameLink, guildNameAlliance, rankSyntax), true)
                end
                if ChatAnnouncements.SV.Social.GuildRankAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED), displayName, guildNameAllianceAlert, rankSyntaxAlert))
                end
                break
            end
        end
    end
end

--- - **EVENT_GUILD_PLAYER_RANK_CHANGED **
---
--- @param eventId integer
--- @param guildId integer
--- @param rankIndex luaindex
--- @param guildRankChangeAction GuildRankChangeAction
function ChatAnnouncements.GuildPlayerRankChanged(eventId, guildId, rankIndex, guildRankChangeAction)
    local rankText = GetFinalGuildRankName(guildId, rankIndex)
    local icon = GetFinalGuildRankTextureSmall(guildId, rankIndex)
    local guildName = GetGuildName(guildId)

    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
    local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

    local syntax
    if guildRankChangeAction == GUILD_RANK_CHANGE_ACTION_PROMOTE then
        if ChatAnnouncements.SV.Social.GuildRankCA then
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UP_SELF), rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UP_SELF), rankSyntaxAlert, guildNameAllianceAlert))
        end
    elseif guildRankChangeAction == GUILD_RANK_CHANGE_ACTION_DEMOTE then
        if ChatAnnouncements.SV.Social.GuildRankCA then
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_DOWN_SELF), rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_DOWN_SELF), rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
end

--- - **EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL **
---
--- @param eventId integer
--- @param playerName string
--- @param newRankIndex integer
--- @param guildId integer
function ChatAnnouncements.GuildMemberPromoteSuccessful(eventId, playerName, newRankIndex, guildId)
    if newRankIndex > 0 then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(playerName, nil, DISPLAY_NAME_LINK_TYPE, playerName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(playerName, nil, DISPLAY_NAME_LINK_TYPE, playerName)
        end
        local rankText = GetFinalGuildRankName(guildId, newRankIndex)
        local icon = GetFinalGuildRankTextureSmall(guildId, newRankIndex)
        local guildName = GetGuildName(guildId)

        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
        local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
        local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

        if ChatAnnouncements.SV.Social.GuildRankCA then
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_PROMOTE), displayNameLink, rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_PROMOTE), playerName, rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
    ChatAnnouncements.disableRankMessage = true
end

--- - **EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL **
---
--- @param eventId integer
--- @param playerName string
--- @param newRankIndex integer
--- @param guildId integer
function ChatAnnouncements.GuildMemberDemoteSuccessful(eventId, playerName, newRankIndex, guildId)
    if newRankIndex <= GetNumGuildRanks(guildId) then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(playerName, nil, DISPLAY_NAME_LINK_TYPE, playerName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(playerName, nil, DISPLAY_NAME_LINK_TYPE, playerName)
        end
        local rankText = GetFinalGuildRankName(guildId, newRankIndex)
        local icon = GetFinalGuildRankTextureSmall(guildId, newRankIndex)
        local guildName = GetGuildName(guildId)

        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
        local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
        local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

        if ChatAnnouncements.SV.Social.GuildRankCA then
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_DEMOTE), displayNameLink, rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_DEMOTE), playerName, rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
    ChatAnnouncements.disableRankMessage = true
end

--- - **EVENT_GUILD_SELF_JOINED_GUILD **
---
--- @param eventId integer
--- @param guildServerId integer
--- @param characterName string
--- @param guildId integer
function ChatAnnouncements.GuildAddedSelf(eventId, guildServerId, characterName, guildId)
    local guilds = GetNumGuilds()
    for i = 1, guilds do
        local id = GetGuildId(i)
        local name = GetGuildName(id)
        local guildName = GetGuildName(guildId)
        local guildAlliance = GetGuildAlliance(id)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if guildName == name then
            if ChatAnnouncements.SV.Social.GuildCA then
                printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_JOIN_SELF), guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_JOIN_SELF), guildNameAllianceAlert))
            end
            break
        end
    end
end

--- - **EVENT_GUILD_INVITE_ADDED **
---
--- @param eventId integer
--- @param guildId integer
--- @param guildName string
--- @param guildAlliance Alliance
--- @param inviterDisplayName string
function ChatAnnouncements.GuildInviteAdded(eventId, guildId, guildName, guildAlliance, inviterDisplayName)
    local displayNameLink
    if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
        displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(inviterDisplayName, nil, DISPLAY_NAME_LINK_TYPE, inviterDisplayName)
    else
        displayNameLink = ZO_LinkHandler_CreateLink(inviterDisplayName, nil, DISPLAY_NAME_LINK_TYPE, inviterDisplayName)
    end
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ChatAnnouncements.Colors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    if ChatAnnouncements.SV.Social.GuildCA then
        printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), displayNameLink, guildNameAlliance), true)
    end
    if ChatAnnouncements.SV.Social.GuildAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), inviterDisplayName, guildNameAllianceAlert))
    end
end

--- - **EVENT_FRIEND_ADDED **
---
--- @param eventId integer
--- @param displayName string
function ChatAnnouncements.FriendAdded(eventId, displayName)
    if ChatAnnouncements.SV.Social.FriendIgnoreCA then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        end
        printToChat(zo_strformat(LUIE_STRING_CA_FRIENDS_FRIEND_ADDED, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_FRIENDS_FRIEND_ADDED, displayName))
    end
end

--- - **EVENT_FRIEND_REMOVED **
---
--- @param eventId integer
--- @param displayName string
function ChatAnnouncements.FriendRemoved(eventId, displayName)
    if ChatAnnouncements.SV.Social.FriendIgnoreCA then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        end
        printToChat(zo_strformat(LUIE_STRING_CA_FRIENDS_FRIEND_REMOVED, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_FRIENDS_FRIEND_REMOVED, displayName))
    end
end

--- - **EVENT_INCOMING_FRIEND_INVITE_ADDED **
---
--- @param eventId integer
--- @param displayName string
function ChatAnnouncements.FriendInviteAdded(eventId, displayName)
    if ChatAnnouncements.SV.Social.FriendIgnoreCA then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        end
        printToChat(zo_strformat(LUIE_STRING_CA_FRIENDS_INCOMING_FRIEND_REQUEST, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_FRIENDS_INCOMING_FRIEND_REQUEST, displayName))
    end
end

--- - **EVENT_IGNORE_ADDED **
---
--- @param eventId integer
--- @param displayName string
function ChatAnnouncements.IgnoreAdded(eventId, displayName)
    if ChatAnnouncements.SV.Social.FriendIgnoreCA then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        end
        printToChat(zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_IGNORE_ADDED, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_IGNORE_ADDED, displayName))
    end
end

--- - **EVENT_IGNORE_REMOVED **
---
--- @param eventId integer
--- @param displayName string
function ChatAnnouncements.IgnoreRemoved(eventId, displayName)
    if ChatAnnouncements.SV.Social.FriendIgnoreCA then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        end
        printToChat(zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_IGNORE_REMOVED, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_IGNORE_REMOVED, displayName))
    end
end

--- - **EVENT_FRIEND_PLAYER_STATUS_CHANGED **
---
--- @param eventId integer
--- @param displayName string
--- @param characterName string
--- @param oldStatus PlayerStatus
--- @param newStatus PlayerStatus
function ChatAnnouncements.FriendPlayerStatus(eventId, displayName, characterName, oldStatus, newStatus)
    local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
    local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

    displayName = zo_strformat("<<1>>", displayName)
    characterName = zo_strformat("<<1>>", characterName)

    if wasOnline ~= isOnline then
        local chatText
        local alertText
        local displayNameLink
        local characterNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
            characterNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(characterName, nil, CHARACTER_LINK_TYPE, characterName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
            characterNameLink = ZO_LinkHandler_CreateLink(characterName, nil, CHARACTER_LINK_TYPE, characterName)
        end
        if isOnline then
            if characterName ~= "" then
                chatText = zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_CHARACTER_LOGGED_ON, displayNameLink, characterNameLink)
                alertText = zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_CHARACTER_LOGGED_ON, displayName, characterName)
            else
                chatText = zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_LOGGED_ON, displayNameLink)
                alertText = zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_LOGGED_ON, displayName)
            end
        else
            if characterName ~= "" then
                chatText = zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_CHARACTER_LOGGED_OFF, displayNameLink, characterNameLink)
                alertText = zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_CHARACTER_LOGGED_OFF, displayName, characterName)
            else
                chatText = zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_LOGGED_OFF, displayNameLink)
                alertText = zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_LOGGED_OFF, displayName)
            end
        end

        if ChatAnnouncements.SV.Social.FriendStatusCA then
            printToChat(chatText, true)
        end
        if ChatAnnouncements.SV.Social.FriendStatusAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
        end
    end
end

--- - **EVENT_QUEST_SHARED **
---
--- @param eventId integer
--- @param questId integer
function ChatAnnouncements.QuestShared(eventId, questId)
    if ChatAnnouncements.SV.Quests.QuestShareCA or ChatAnnouncements.SV.Quests.QuestShareAlert then
        local questName, characterName, timeSinceRequestMs, displayName = GetOfferedQuestShareInfo(questId)

        local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)

        local message = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE), finalName, ChatAnnouncements.Colors.QuestColorQuestNameColorize:Colorize(questName))
        local alertMessage = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE_P2P), finalName, questName)

        if ChatAnnouncements.SV.Quests.QuestShareCA then
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Quests.QuestShareAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end
    end
end

-- EVENT_CHATTER_BEGIN
--- @param eventId integer
--- @param optionCount integer
--- @param debugSource integer
function ChatAnnouncements.OnChatterBegin(eventId, optionCount, debugSource)
    ChatAnnouncements.talkingToNPC = true
end

--- - **EVENT_CHATTER_END**
---
--- @param eventId integer
function ChatAnnouncements.OnChatterEnd(eventId)
    ChatAnnouncements.talkingToNPC = false
end

--- - **EVENT_GROUPING_TOOLS_LFG_JOINED **
---
--- @param eventId integer
--- @param locationName string
function ChatAnnouncements.GroupingToolsLFGJoined(eventId, locationName)
    -- Update the current activity id with the one we are in now.
    ChatAnnouncements.currentActivityId = GetCurrentLFGActivityId()
    -- Get the name of the current activityId that is generated on initialization.
    local currentActivityName = GetActivityName(ChatAnnouncements.currentActivityId)
    -- If the locationName is different thant the saved currentActivityName we have entered a new LFG instance, so display this message.
    if locationName ~= currentActivityName then
        if ChatAnnouncements.SV.Group.GroupLFGCA then
            printToChat(zo_strformat(LUIE_STRING_CA_GROUPFINDER_ALERT_LFG_JOINED, locationName), true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUPFINDER_ALERT_LFG_JOINED, locationName))
        end
        ChatAnnouncements.lfgDisableGroupEvents = true
        LUIE_callLater(function ()
                           ChatAnnouncements.lfgDisableGroupEvents = false
                       end, 3000)
    end
    ChatAnnouncements.joinLFGOverride = true
end

--- - **EVENT_ACTIVITY_FINDER_STATUS_UPDATE **
---
--- @param eventId integer
--- @param result ActivityFinderStatus
function ChatAnnouncements.ActivityStatusUpdate(eventId, result)
    -- d("result: " .. result)
    local message
    if ChatAnnouncements.showActivityStatus then
        if not ChatAnnouncements.weDeclinedTheQueue then
            -- If we are NOT queued and were formerly queued, forming group, or in a ready check, display left queue message.
            if result == ACTIVITY_FINDER_STATUS_NONE and (ChatAnnouncements.savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED or ChatAnnouncements.savedQueueValue == ACTIVITY_FINDER_STATUS_READY_CHECK) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_END))
            end
            -- If we are queued and previously we were not queued then display a message.
            if result == ACTIVITY_FINDER_STATUS_QUEUED and (ChatAnnouncements.savedQueueValue == ACTIVITY_FINDER_STATUS_NONE or ChatAnnouncements.savedQueueValue == ACTIVITY_FINDER_STATUS_IN_PROGRESS) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_START))
            end
            -- If we were in the queue and are now in progress without a ready check triggered, we left the queue to find a replacement member so this should be displayed.
            if result == ACTIVITY_FINDER_STATUS_IN_PROGRESS and (ChatAnnouncements.savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_END))
            end
        end
    end

    -- If we queue as a group in a completed LFG activity then if someone drops the queue don't show that a group was successfully formed.
    -- This event handles everyone but the player that declined the check.
    if (result == ACTIVITY_FINDER_STATUS_COMPLETE and ChatAnnouncements.savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED) or (result == ACTIVITY_FINDER_STATUS_QUEUED and ChatAnnouncements.savedQueueValue == ACTIVITY_FINDER_STATUS_READY_CHECK) then
        -- Don't show if we already got a ready check cancel message.
        if not ChatAnnouncements.lfgHideStatusCancel then
            message = (GetString(SI_LFGREADYCHECKCANCELREASON3))
        end
        ChatAnnouncements.showRCUpdates = true
    end

    if message then
        if ChatAnnouncements.SV.Group.GroupLFGQueueCA then
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGQueueAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
    end

    -- Should always trigger at the end result of a ready check failing (none when not in an activity already, complete when in a finished one).
    if result == ACTIVITY_FINDER_STATUS_NONE then
        ChatAnnouncements.showRCUpdates = true
    end
    if result == ACTIVITY_FINDER_STATUS_READY_CHECK then
        ChatAnnouncements.showRCUpdates = false
    end

    -- Debug
    if result == ACTIVITY_FINDER_STATUS_FORMING_GROUP and ChatAnnouncements.savedQueueValue ~= ACTIVITY_FINDER_STATUS_FORMING_GROUP then
        if LUIE.IsDevDebugEnabled() then
            LUIE:Log("Debug", "Old ACTIVITY_FINDER_STATUS_FORMING_GROUP event triggered")
        end
    end

    ChatAnnouncements.savedQueueValue = result
end

-- Map activity types to their string IDs and descriptors
local ACTIVITY_TYPE_STRINGS =
{
    [LFG_ACTIVITY_AVA] = { stringId = SI_LFGACTIVITY1 },
    [LFG_ACTIVITY_DUNGEON] = { stringId = SI_LFGACTIVITY2, descriptor = SI_DUNGEON_FINDER_GENERAL_ACTIVITY_DESCRIPTOR },
    [LFG_ACTIVITY_MASTER_DUNGEON] = { stringId = SI_LFGACTIVITY3, descriptor = SI_DUNGEON_FINDER_GENERAL_ACTIVITY_DESCRIPTOR },
    [LFG_ACTIVITY_TRIAL] = { stringId = SI_LFGACTIVITY4 },
    [LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = { stringId = SI_LFGACTIVITY5, descriptor = SI_BATTLEGROUND_FINDER_GENERAL_ACTIVITY_DESCRIPTOR },
    [LFG_ACTIVITY_HOME_SHOW] = { stringId = SI_LFGACTIVITY6 },
    [LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = { stringId = SI_LFGACTIVITY7, descriptor = SI_BATTLEGROUND_FINDER_GENERAL_ACTIVITY_DESCRIPTOR },
    [LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = { stringId = SI_LFGACTIVITY8, descriptor = SI_BATTLEGROUND_FINDER_GENERAL_ACTIVITY_DESCRIPTOR },
    [LFG_ACTIVITY_TRIBUTE_COMPETITIVE] = { stringId = SI_LFGACTIVITY9 },
    [LFG_ACTIVITY_TRIBUTE_CASUAL] = { stringId = SI_LFGACTIVITY10 },
    -- [LFG_ACTIVITY_EXPLORATION] = { stringId = SI_LFGACTIVITY11 },
    -- [LFG_ACTIVITY_ARENA] = { stringId = SI_LFGACTIVITY12 },
    -- [LFG_ACTIVITY_ENDLESS_DUNGEON] = { stringId = SI_LFGACTIVITY13 },
}

-- Helper function to get activity name based on type
local function GetActivityName(activityType)
    local activityInfo = ACTIVITY_TYPE_STRINGS[activityType]
    if not activityInfo then return nil end

    if activityInfo.descriptor then
        return zo_strformat("<<1>> <<2>>", GetString(activityInfo.stringId), GetString(activityInfo.descriptor))
    else
        return GetString(activityInfo.stringId)
    end
end

--- - **EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED**
---
--- @param eventId integer
function ChatAnnouncements.ReadyCheckUpdate(eventId)
    if HasLFGReadyCheckNotification() then
        local activityType, playerRole, timeRemainingSeconds = GetLFGReadyCheckNotificationInfo()
        local tanksAccepted, tanksPending, healersAccepted, healersPending, dpsAccepted, dpsPending = GetLFGReadyCheckCounts()

        if ChatAnnouncements.showRCUpdates then
            -- Return early if invalid activity type
            if activityType == LFG_ACTIVITY_INVALID then return end

            local activityName = GetString("SI_LFGACTIVITY", activityType)
            if not activityName then return end

            local message, alertText
            if playerRole ~= 0 then
                local roleIconSmall = zo_strformat("<<1>> ", zo_iconFormat(LUIE.GetRoleIcon(playerRole), 16, 16)) or ""
                local roleIconLarge = zo_strformat("<<1>> ", zo_iconFormat(LUIE.GetRoleIcon(playerRole), "100%", "100%")) or ""
                local roleString = GetString("SI_LFGROLE", playerRole)

                message = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_READY_CHECK_ACTIVITY_ROLE), activityName, roleIconSmall, roleString)
                alertText = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_READY_CHECK_ACTIVITY_ROLE), activityName, roleIconLarge, roleString)
            else
                message = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_READY_CHECK_ACTIVITY), activityName)
                alertText = message
            end

            if ChatAnnouncements.SV.Group.GroupLFGCA then
                printToChat(message, true)
            end
            if ChatAnnouncements.SV.Group.GroupLFGAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
            end
        end

        ChatAnnouncements.showRCUpdates = false

        -- Handle ready check completion or cancellation
        local allCountsZero = tanksAccepted == 0 and tanksPending == 0 and
            healersAccepted == 0 and healersPending == 0 and
            dpsAccepted == 0 and dpsPending == 0

        if not ChatAnnouncements.showRCUpdates and allCountsZero and not ChatAnnouncements.rcSpamPrevention then
            ChatAnnouncements.rcSpamPrevention = true

            -- Reset spam prevention after 1 second
            LUIE_callLater(function ()
                               ChatAnnouncements.rcSpamPrevention = false
                           end, 1000)

            -- Reset activity status after 1 second
            ChatAnnouncements.showActivityStatus = false
            LUIE_callLater(function ()
                               ChatAnnouncements.showActivityStatus = true
                           end, 1000)

            -- Reset group leave queue after 1 second
            ChatAnnouncements.stopGroupLeaveQueue = true
            LUIE_callLater(function ()
                               ChatAnnouncements.stopGroupLeaveQueue = false
                           end, 1000)

            ChatAnnouncements.showRCUpdates = true
        end
    end
end

--[[ Would love to be able to use this function but its too buggy for now. Spams every single time someone updates their role, as well as when people join/leave group. If the player joins a large party for the first time then
this broadcasts the role of every single player in the party. Too bad this doesn't only trigger when someone in group actually updates their role instead.
No localization support yet.
function ChatAnnouncements.GMRC(eventCode, unitTag, dps, healer, tank)

local updatedRoleName = GetUnitName(unitTag)
local updatedRoleAccountName = GetUnitDisplayName(unitTag)

local characterNameLink = ZO_LinkHandler_CreateCharacterLink(updatedRoleName)
local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(updatedRoleAccountName)
local displayBothString = ( zo_strformat("<<1>><<2>>", updatedRoleName, updatedRoleAccountName) )
local displayBoth = ZO_LinkHandler_CreateLink(displayBothString, nil, DISPLAY_NAME_LINK_TYPE, updatedRoleAccountName)

local rolestring1 = ""
local rolestring2 = ""
local rolestring3 = ""
local message = ""

    -- Return here in case something happens
    if not (dps or healer or tank) then
        return
    end

    -- fill in strings for roles
    if dps then
        rolestring3 = "DPS"
    end
    if healer then
        rolestring2 = "Healer"
    end
    if tank then
        rolestring1 = "Tank"
    end

    -- Get appropriate 2nd string for role
    if dps and not (healer or tank) then
        message = (zo_strformat("<<1>>", rolestring3) )
    elseif healer and not (dps or tank) then
        message = (zo_strformat("<<1>>", rolestring2) )
    elseif tank and not (dps or healer) then
        message = (zo_strformat("<<1>>", rolestring1) )
    elseif dps and healer and not tank then
        message = (zo_strformat("<<1>>, <<2>>", rolestring2, rolestring3) )
    elseif dps and tank and not healer then
        message = (zo_strformat("<<1>>, <<2>>", rolestring1, rolestring3) )
    elseif healer and tank and not dps then
        message = (zo_strformat("<<1>>, <<2>>", rolestring1, rolestring2) )
    elseif dps and healer and tank then
        message = (zo_strformat("<<1>>, <<2>>, <<3>>", rolestring1, rolestring2, rolestring3) )
    end

    if updatedRoleName ~= LUIE.PlayerNameFormatted then
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 1 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has updated their role: <<2>>", displayNameLink, message) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 2 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has updated their role: <<2>>", characterNameLink, message) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 3 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has updated their role: <<2>>", displayBoth, message) )
        end
    else
        printToChat(zo_strformat("You have updated your role: <<1>>", message) )
    end
end
]]
--

--[[ Would love to be able to use this function but its too buggy for now. When a single player disconnects for the first time in the group, another player will see a message for the online/offline status of every other
player in the group. Possibly reimplement and limit it to 2 player groups?
No localization support yet.
function ChatAnnouncements.GMCS(eventCode, unitTag, isOnline)

    local onlineRoleName = GetUnitName(unitTag)
    local onlineRoleDisplayName = GetUnitDisplayName(unitTag)

    local characterNameLink = ZO_LinkHandler_CreateCharacterLink(onlineRoleName)
    local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(onlineRoleDisplayName)
    local displayBothString = ( zo_strformat("<<1>><<2>>", onlineRoleName, onlineRoleDisplayName) )
    local displayBoth = ZO_LinkHandler_CreateLink(displayBothString, nil, DISPLAY_NAME_LINK_TYPE, onlineRoleDisplayName)


    if not isOnline and onlineRoleName ~=LUIE.PlayerNameFormatted then
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 1 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has disconnected.", displayNameLink) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 2 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has disconnected.", characterNameLink) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 3 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has disconnected.", displayBoth) )
        end
    elseif isOnline and onlineRoleName ~=LUIE.PlayerNameFormatted then
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 1 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has reconnected.", displayNameLink) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 2 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has reconnected.", characterNameLink) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 3 then
            printToChat(zo_strformat("|cFFFFFF<<1>>|r has reconnected.", displayBoth) )
        end
    end
end
]]
--

local RESPEC_TYPE_CHAMPION = 1
local RESPEC_TYPE_ATTRIBUTES = 2
local RESPEC_TYPE_SKILLS = 3
local RESPEC_TYPE_MORPHS = 4

local LUIE_AttributeDisplayType =
{
    [RESPEC_TYPE_CHAMPION] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_CHAMPION),
    [RESPEC_TYPE_ATTRIBUTES] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_ATTRIBUTES),
    [RESPEC_TYPE_SKILLS] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILLS),
    [RESPEC_TYPE_MORPHS] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_MORPHS),
}

-- Called by various functions to display a respec message, type serves as the message type, delay allows the message to sync timing with the chat printer based on source.
---
--- @param respecType RespecType
function ChatAnnouncements.PointRespecDisplay(respecType)
    local message = LUIE_AttributeDisplayType[respecType] .. "."
    local messageCSA = LUIE_AttributeDisplayType[respecType]

    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.CA then
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = message,
            messageType = "MESSAGE",
            isSystem = true
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.CSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        messageParams:SetText(messageCSA)
        messageParams:SetSound(SOUNDS.DISPLAY_ANNOUNCEMENT)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.Alert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
    end
end

--- - **EVENT_LOOT_UPDATED**
---
--- @param eventId integer
function ChatAnnouncements.OnLootUpdated(eventId)
    ChatAnnouncements.containerRecentlyOpened = true
    local function ResetContainerRecentlyOpened()
        ChatAnnouncements.containerRecentlyOpened = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetContainer")
    end
    eventManager:UnregisterForUpdate(moduleName .. "ResetContainer")
    eventManager:RegisterForUpdate(moduleName .. "ResetContainer", 150, ResetContainerRecentlyOpened)
end

local CURRENCY_CONFIGS =
{
    [CURT_MONEY] =
    {
        enabled = "CurrencyGoldChange",
        color = "CurrencyGoldColorize",
        name = "CurrencyGoldName",
        total = "CurrencyGoldShowTotal",
        messageTotal = "CurrencyMessageTotalGold",
    },
    [CURT_ALLIANCE_POINTS] =
    {
        enabled = "CurrencyAPShowChange",
        color = "CurrencyAPColorize",
        name = "CurrencyAPName",
        total = "CurrencyAPShowTotal",
        messageTotal = "CurrencyMessageTotalAP",
    },
    [CURT_TELVAR_STONES] =
    {
        enabled = "CurrencyTVChange",
        color = "CurrencyTVColorize",
        name = "CurrencyTVName",
        total = "CurrencyTVShowTotal",
        messageTotal = "CurrencyMessageTotalTV",
    },
    [CURT_WRIT_VOUCHERS] =
    {
        enabled = "CurrencyWVChange",
        color = "CurrencyWVColorize",
        name = "CurrencyWVName",
        total = "CurrencyWVShowTotal",
        messageTotal = "CurrencyMessageTotalWV",
    },
    [CURT_STYLE_STONES] =
    {
        enabled = "CurrencyOutfitTokenChange",
        color = "CurrencyOutfitTokenColorize",
        name = "CurrencyOutfitTokenName",
        total = "CurrencyOutfitTokenShowTotal",
        messageTotal = "CurrencyMessageTotalOutfitToken",
    },
    [CURT_CHAOTIC_CREATIA] =
    {
        enabled = "CurrencyTransmuteChange",
        color = "CurrencyTransmuteColorize",
        name = "CurrencyTransmuteName",
        total = "CurrencyTransmuteShowTotal",
        messageTotal = "CurrencyMessageTotalTransmute",
    },
    [CURT_EVENT_TICKETS] =
    {
        enabled = "CurrencyEventChange",
        color = "CurrencyEventColorize",
        name = "CurrencyEventName",
        total = "CurrencyEventShowTotal",
        messageTotal = "CurrencyMessageTotalEvent",
    },
    [CURT_UNDAUNTED_KEYS] =
    {
        enabled = "CurrencyUndauntedChange",
        color = "CurrencyUndauntedColorize",
        name = "CurrencyUndauntedName",
        total = "CurrencyUndauntedShowTotal",
        messageTotal = "CurrencyMessageTotalUndaunted",
    },
    [CURT_CROWNS] =
    {
        enabled = "CurrencyCrownsChange",
        color = "CurrencyCrownsColorize",
        name = "CurrencyCrownsName",
        total = "CurrencyCrownsShowTotal",
        messageTotal = "CurrencyMessageTotalCrowns",
    },
    [CURT_CROWN_GEMS] =
    {
        enabled = "CurrencyCrownGemsChange",
        color = "CurrencyCrownGemsColorize",
        name = "CurrencyCrownGemsName",
        total = "CurrencyCrownGemsShowTotal",
        messageTotal = "CurrencyMessageTotalCrownGems",
    },
    [CURT_ENDEAVOR_SEALS] =
    {
        enabled = "CurrencyEndeavorsChange",
        color = "CurrencyEndeavorsColorize",
        name = "CurrencyEndeavorsName",
        total = "CurrencyEndeavorsShowTotal",
        messageTotal = "CurrencyMessageTotalEndeavors",
    },
    [CURT_ARCHIVAL_FORTUNES] =
    {
        enabled = "CurrencyEndlessChange",
        color = "CurrencyEndlessColorize",
        name = "CurrencyEndlessName",
        total = "CurrencyEndlessShowTotal",
        messageTotal = "CurrencyMessageTotalEndless",
        iconType = CURT_ARCHIVAL_FORTUNES,
    },
}

local AP_THROTTLE_REASONS =
{
    [CURRENCY_CHANGE_REASON_KILL] = true,
    [CURRENCY_CHANGE_REASON_KEEP_REPAIR] = true,
    [CURRENCY_CHANGE_REASON_PVP_RESURRECT] = true,
}

local TV_THROTTLE_REASONS =
{
    [CURRENCY_CHANGE_REASON_LOOT] = true,
    [CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER] = true,
}

local DEBUG_REASON_SET =
{
    [CURRENCY_CHANGE_REASON_ACTION] = true,
    [CURRENCY_CHANGE_REASON_KEEP_UPGRADE] = true,
    [CURRENCY_CHANGE_REASON_DEPRECATED_0] = true,
    [CURRENCY_CHANGE_REASON_DEPRECATED_2] = true,
    [CURRENCY_CHANGE_REASON_SOUL_HEAL] = true,
    [CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY] = true,
    [CURRENCY_CHANGE_REASON_ABILITY_UPGRADE_PURCHASE] = true,
    [CURRENCY_CHANGE_REASON_DEPRECATED_1] = true,
    [CURRENCY_CHANGE_REASON_STABLESPACE] = true,
    [CURRENCY_CHANGE_REASON_ACHIEVEMENT] = true,
    [CURRENCY_CHANGE_REASON_TRAIT_REVEAL] = true,
    [CURRENCY_CHANGE_REASON_REFORGE] = true,
    [CURRENCY_CHANGE_REASON_RECIPE] = true,
    [CURRENCY_CHANGE_REASON_CONSUME_FOOD_DRINK] = true,
    [CURRENCY_CHANGE_REASON_CONSUME_POTION] = true,
    [CURRENCY_CHANGE_REASON_HARVEST_REAGENT] = true,
    [CURRENCY_CHANGE_REASON_RESEARCH_TRAIT] = true,
    [CURRENCY_CHANGE_REASON_GUILD_TABARD] = true,
    [CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP] = true,
    [CURRENCY_CHANGE_REASON_BANK_FEE] = true,
    [CURRENCY_CHANGE_REASON_CHARACTER_UPGRADE] = true,
    [CURRENCY_CHANGE_REASON_TRIBUTE] = true,
}

local REASON_MESSAGE_KEYS =
{
    [CURRENCY_CHANGE_REASON_QUESTREWARD] = "CurrencyMessageReceive",
    [CURRENCY_CHANGE_REASON_DECONSTRUCT] = "CurrencyMessageReceive",
    [CURRENCY_CHANGE_REASON_MEDAL] = "CurrencyMessageReceive",
    [CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND] = "CurrencyMessageReceive",
    [CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND] = "CurrencyMessageReceive",
    [CURRENCY_CHANGE_REASON_CONVERSATION] = "CurrencyMessagePay",
    [CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY] = "CurrencyMessageSpend",
    [CURRENCY_CHANGE_REASON_GUILD_TABARD] = "CurrencyMessageSpend",
    [CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD] = "CurrencyMessageWayshrine",
    [CURRENCY_CHANGE_REASON_CRAFT] = "CurrencyMessageUse",
    [CURRENCY_CHANGE_REASON_RECONSTRUCTION] = "CurrencyMessageUse",
    [CURRENCY_CHANGE_REASON_ENDLESS_DUNGEON_VISION_REROLL] = "CurrencyMessageUse",
    [CURRENCY_CHANGE_REASON_VENDOR_REPAIR] = "CurrencyMessageRepair",
    [CURRENCY_CHANGE_REASON_STUCK] = "CurrencyMessageUnstuck",
    [CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE] = "CurrencyMessageBounty",
    [CURRENCY_CHANGE_REASON_KEEP_REPAIR] = "CurrencyMessageEarn",
    [CURRENCY_CHANGE_REASON_PVP_RESURRECT] = "CurrencyMessageEarn",
    [CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD] = "CurrencyMessageEarn",
    [CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD] = "CurrencyMessageEarn",
    [CURRENCY_CHANGE_REASON_ANTIQUITY_REWARD] = "CurrencyMessageExcavate",
    [CURRENCY_CHANGE_REASON_BANK_DEPOSIT] = "CurrencyMessageDeposit",
    [CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT] = "CurrencyMessageDepositGuild",
    [CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL] = "CurrencyMessageWithdraw",
    [CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL] = "CurrencyMessageWithdrawGuild",
    [CURRENCY_CHANGE_REASON_PICKPOCKET] = "CurrencyMessagePickpocket",
    [CURRENCY_CHANGE_REASON_LOOT] = "CurrencyMessageLoot",
    [CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER] = "CurrencyMessageLoot",
    [CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER] = "CurrencyMessageLoot",
    [CURRENCY_CHANGE_REASON_LOOT_STOLEN] = "CurrencyMessageSteal",
    [CURRENCY_CHANGE_REASON_DEATH] = "CurrencyMessageLost",
    [CURRENCY_CHANGE_REASON_CROWN_CRATE_DUPLICATE] = "CurrencyMessageReceive",
    [CURRENCY_CHANGE_REASON_ITEM_CONVERTED_TO_GEMS] = "CurrencyMessageReceive",
    [CURRENCY_CHANGE_REASON_CROWNS_PURCHASED] = "CurrencyMessageReceive",
    [CURRENCY_CHANGE_REASON_PURCHASED_WITH_ENDEAVOR_SEALS] = "CurrencyMessageSpend",
}

local function SavePurchaseData(changeType, formattedValue, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageTotal)
    local saved = ChatAnnouncements.savedPurchase
    saved.changeType = changeType
    saved.formattedValue = formattedValue
    saved.currencyTypeColor = currencyTypeColor
    saved.currencyIcon = currencyIcon
    saved.currencyName = currencyName
    saved.currencyTotal = currencyTotal
    saved.messageTotal = messageTotal
end

local function SavePurchaseIfEnabled(context)
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        SavePurchaseData(context.changeType, context.formattedValue, context.currencyTypeColor, context.currencyIcon, context.currencyName, context.currencyTotal, context.messageTotal)
        return true
    end
    return false
end

local function HandleCurrencyThrottleAndFilter(currencyType, reason, delta)
    local svCurrency = ChatAnnouncements.SV.Currency

    if currencyType == CURT_MONEY then
        if svCurrency.CurrencyGoldThrottle and (reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_KILL) then
            LUIE_callLater(ChatAnnouncements.CurrencyGoldThrottlePrinter, 50)
            ChatAnnouncements.currencyGoldThrottleValue = ChatAnnouncements.currencyGoldThrottleValue + delta
            ChatAnnouncements.currencyGoldThrottleTotal = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
            return true
        end
        if svCurrency.CurrencyGoldFilter > 0 and (reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_KILL) and delta < svCurrency.CurrencyGoldFilter then
            return true
        end
        return false
    end

    if currencyType == CURT_ALLIANCE_POINTS then
        if svCurrency.CurrencyAPThrottle > 0 and AP_THROTTLE_REASONS[reason] then
            eventManager:UnregisterForUpdate(moduleName .. "BufferedAP")
            eventManager:RegisterForUpdate(moduleName .. "BufferedAP", svCurrency.CurrencyAPThrottle, ChatAnnouncements.CurrencyAPThrottlePrinter)
            ChatAnnouncements.currencyAPThrottleValue = ChatAnnouncements.currencyAPThrottleValue + delta
            ChatAnnouncements.currencyAPThrottleTotal = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
            return true
        end
        if svCurrency.CurrencyAPFilter > 0 and AP_THROTTLE_REASONS[reason] and delta < svCurrency.CurrencyAPFilter then
            return true
        end
        if svCurrency.CurrencyAPThrottle > 0 and not AP_THROTTLE_REASONS[reason] then
            ChatAnnouncements.CurrencyAPThrottlePrinter()
        end
        return false
    end

    if currencyType == CURT_TELVAR_STONES then
        if svCurrency.CurrencyTVThrottle > 0 and TV_THROTTLE_REASONS[reason] and not ChatAnnouncements.containerRecentlyOpened then
            eventManager:UnregisterForUpdate(moduleName .. "BufferedTV")
            eventManager:RegisterForUpdate(moduleName .. "BufferedTV", svCurrency.CurrencyTVThrottle, ChatAnnouncements.CurrencyTVThrottlePrinter)
            ChatAnnouncements.currencyTVThrottleValue = ChatAnnouncements.currencyTVThrottleValue + delta
            ChatAnnouncements.currencyTVThrottleTotal = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
            return true
        end
        if svCurrency.CurrencyTVFilter > 0 and TV_THROTTLE_REASONS[reason] and delta < svCurrency.CurrencyTVFilter then
            return true
        end
        if svCurrency.CurrencyTVThrottle > 0 and not TV_THROTTLE_REASONS[reason] then
            ChatAnnouncements.CurrencyTVThrottlePrinter()
        end
        return false
    end

    return false
end

local function BuildCurrencyDisplay(config, currencyType, delta)
    local svCurrency = ChatAnnouncements.SV.Currency
    local iconType = config.iconType or currencyType
    local currencyTypeColor = ChatAnnouncements.Colors[config.color]:ToHex()
    local currencyIcon = svCurrency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(iconType), 16, 16) or ""
    local currencyName = zo_strformat(svCurrency[config.name], delta)
    local currencyTotal = svCurrency[config.total]
    local messageTotal = svCurrency[config.messageTotal]
    return currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageTotal
end

local function ResolveMessageByReason(context)
    local svContext = ChatAnnouncements.SV.ContextMessages
    local reason = context.reason
    local delta = context.delta

    if reason == CURRENCY_CHANGE_REASON_VENDOR then
        context.messageChange = delta > 0 and svContext.CurrencyMessageReceive or svContext.CurrencyMessageSpend
        if SavePurchaseIfEnabled(context) then
            return true
        end
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_BUYBACK then
        context.messageChange = svContext.CurrencyMessageSpend
        if SavePurchaseIfEnabled(context) then
            return true
        end
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_SELL_STOLEN then
        context.messageChange = svContext.CurrencyMessageReceive
        if SavePurchaseIfEnabled(context) then
            return true
        end
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING then
        if ChatAnnouncements.SV.Currency.CurrencyGoldHideListingAH then
            return true
        end
        SavePurchaseData(context.changeType, context.formattedValue, context.currencyTypeColor, context.currencyIcon, context.currencyName, context.currencyTotal, context.messageTotal)
        return true
    end

    if reason == CURRENCY_CHANGE_REASON_VENDOR_LAUNDER then
        context.messageChange = svContext.CurrencyMessageSpend
        if SavePurchaseIfEnabled(context) then
            return true
        end
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE then
        if ChatAnnouncements.SV.Currency.CurrencyGoldHideAH then
            return true
        end
        context.messageChange = svContext.CurrencyMessageSpend
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_TRADE then
        local tradeTarget = ChatAnnouncements.tradeTarget or ""
        if delta > 0 then
            context.messageChange = tradeTarget ~= "" and svContext.CurrencyMessageTradeIn or svContext.CurrencyMessageTradeInNoName
        else
            context.messageChange = tradeTarget ~= "" and svContext.CurrencyMessageTradeOut or svContext.CurrencyMessageTradeOutNoName
        end
        if tradeTarget ~= "" then
            context.messageType = "LUIE_CURRENCY_TRADE"
        end
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_MAIL then
        if delta > 0 then
            local mailSender = ChatAnnouncements.Mail.GetNextSender() or ""
            ChatAnnouncements.currentMailSender = mailSender
            context.messageChange = mailSender ~= "" and svContext.CurrencyMessageMailIn or svContext.CurrencyMessageMailInNoName
            if mailSender ~= "" then
                context.messageType = "LUIE_CURRENCY_MAIL"
            end
        else
            if ChatAnnouncements.Mail.codPresent then
                local mailSender = ChatAnnouncements.Mail.GetNextSender() or ""
                ChatAnnouncements.currentMailSender = mailSender
                context.messageChange = svContext.CurrencyMessageMailCOD
                if mailSender ~= "" then
                    context.messageType = "LUIE_CURRENCY_MAIL"
                end
            else
                return true
            end
        end
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_BAGSPACE then
        context.messageChange = svContext.CurrencyMessageStorage
        context.messageType = "LUIE_CURRENCY_BAG"
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_BANKSPACE then
        context.messageChange = svContext.CurrencyMessageStorage
        context.messageType = "LUIE_CURRENCY_BANK"
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_BATTLEGROUND then
        context.messageChange = delta < 0 and svContext.CurrencyMessageCampaign or svContext.CurrencyMessageReceive
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_RESPEC_SKILLS then
        ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_SKILLS)
        context.messageChange = svContext.CurrencyMessageSkills
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES then
        ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_ATTRIBUTES)
        context.messageChange = svContext.CurrencyMessageAttributes
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_RESPEC_MORPHS then
        ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_MORPHS)
        context.messageChange = svContext.CurrencyMessageMorphs
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_RESPEC_CHAMPION then
        ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_CHAMPION)
        context.messageChange = svContext.CurrencyMessageChampion
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD or reason == CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED then
        context.messageChange = svContext.CurrencyMessageConfiscate
        LUIE_callLater(ChatAnnouncements.JusticeDisplayConfiscate, 50)
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_REWARD then
        context.messageChange = context.currencyType == CURT_ENDEAVOR_SEALS and svContext.CurrencyMessageEarn or svContext.CurrencyMessageReceive
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_KILL then
        context.messageChange = context.currencyType == CURT_ALLIANCE_POINTS and svContext.CurrencyMessageEarn or svContext.CurrencyMessageLoot
        return false
    end

    if reason == CURRENCY_CHANGE_REASON_PURCHASED_WITH_GEMS or reason == CURRENCY_CHANGE_REASON_PURCHASED_WITH_CROWNS then
        if context.currencyType == CURT_STYLE_STONES or context.currencyType == CURT_EVENT_TICKETS then
            context.messageChange = svContext.CurrencyMessageReceive
        else
            context.messageChange = svContext.CurrencyMessageSpend
        end
        return false
    end

    local messageKey = REASON_MESSAGE_KEYS[reason]
    if messageKey then
        context.messageChange = svContext[messageKey]
        return false
    end

    if DEBUG_REASON_SET[reason] then
        context.messageChange = zo_strformat(GetString(LUIE_STRING_CA_DEBUG_MSG_CURRENCY), reason)
        return false
    end

    context.messageChange = svContext.CurrencyMessageLoot
    return false
end

--- - **EVENT_CURRENCY_UPDATE **
---
--- @param currencyType CurrencyType
--- @param currencyLocation CurrencyLocation
--- @param newAmount integer
--- @param oldAmount integer
--- @param reason CurrencyChangeReason
--- @param reasonSupplementaryInfo integer
function ChatAnnouncements.OnCurrencyUpdate(currencyType, currencyLocation, newAmount, oldAmount, reason, reasonSupplementaryInfo)
    if currencyLocation ~= CURRENCY_LOCATION_CHARACTER and currencyLocation ~= CURRENCY_LOCATION_ACCOUNT then
        return
    end

    local UpOrDown = newAmount - oldAmount

    -- If the total gold change was 0 or (Reason 7 = Command) or (Reason 28 = Mount Feed) or (Reason 35 = Player Init) or (Reason 81 = Expiration) - End Now
    if UpOrDown == 0 or reason == CURRENCY_CHANGE_REASON_COMMAND or reason == CURRENCY_CHANGE_REASON_FEED_MOUNT or reason == CURRENCY_CHANGE_REASON_PLAYER_INIT or reason == CURRENCY_CHANGE_REASON_EXPIRATION then
        return
    end

    -- DEBUG
    if LUIE.IsDevDebugEnabled() then
        local traceback = "Currency Update:\n" ..
            "--> currencyType: " .. tostring(currencyType) .. "\n" ..
            "--> currencyLocation: " .. tostring(currencyLocation) .. "\n" ..
            "--> newAmount: " .. tostring(newAmount) .. "\n" ..
            "--> oldAmount: " .. tostring(oldAmount) .. "\n" ..
            "--> reason: " .. tostring(reason) .. "\n" ..
            "--> reasonSupplementaryInfo: " .. tostring(reasonSupplementaryInfo)
        LUIE:Log("Debug", traceback)
    end

    local formattedValue = ZO_CommaDelimitDecimalNumber(newAmount)
    -- Gets the value from ChatAnnouncements.Colors.CurrencyUpColorize or ChatAnnouncements.Colors.CurrencyDownColorize to color strings.
    local changeColor       --- @type string
    -- Amount of currency gained or lost.
    local changeType        --- @type string
    -- Determines color to use for colorization of currency based off currency type.
    local currencyTypeColor --- @type string
    -- Determines icon to use for currency based off currency type.
    local currencyIcon      --- @type string
    -- Determines name to use for currency based off type.
    local currencyName      --- @type string
    -- Determines if the total should be displayed based off type.
    local currencyTotal     --- @type boolean
    -- Set to a string value based on the reason code.
    local messageChange     --- @type string
    -- Set to a string value based on the currency type.
    local messageTotal      --- @type string
    local messageType

    local config = CURRENCY_CONFIGS[currencyType]
    if not config then
        return
    end

    if config.enabled and not ChatAnnouncements.SV.Currency[config.enabled] then
        return
    end

    if HandleCurrencyThrottleAndFilter(currencyType, reason, UpOrDown) then
        return
    end

    currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageTotal = BuildCurrencyDisplay(config, currencyType, UpOrDown)

    -- Did we gain or lose currency
    if UpOrDown > 0 then
        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
            changeColor = ChatAnnouncements.Colors.CurrencyUpColorize:ToHex()
        else
            changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
        end
        changeType = ZO_CommaDelimitDecimalNumber(newAmount - oldAmount)
    else
        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
            changeColor = ChatAnnouncements.Colors.CurrencyDownColorize:ToHex()
        else
            changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
        end
        changeType = ZO_CommaDelimitDecimalNumber(oldAmount - newAmount)
    end

    local context =
    {
        reason = reason,
        delta = UpOrDown,
        currencyType = currencyType,
        changeType = changeType,
        formattedValue = formattedValue,
        currencyTypeColor = currencyTypeColor,
        currencyIcon = currencyIcon,
        currencyName = currencyName,
        currencyTotal = currencyTotal,
        messageTotal = messageTotal,
        messageChange = nil,
        messageType = nil,
    }

    if ResolveMessageByReason(context) then
        return
    end

    messageChange = context.messageChange
    messageType = context.messageType

    -- Haven't seen this one yet but it's more recently added and thus probably used for something.
    if reason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER then
        if LUIE.IsDevDebugEnabled() then
            LUIE:Log("Debug", "Currency Change Reason 76 - CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER")
        end
    end

    -- Send relevant values over to the currency printer
    ChatAnnouncements.CurrencyPrinter(currencyType, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, "", "")
end

--- @alias LUIE_CURRENCY_TYPE
--- | "LUIE_CURRENCY_BAG"
--- | "LUIE_CURRENCY_BANK"
--- | "LUIE_CURRENCY_HERALDRY"
--- | "LUIE_CURRENCY_MAIL"
--- | "LUIE_CURRENCY_POSTAGE"
--- | "LUIE_CURRENCY_RIDING_CAPACITY"
--- | "LUIE_CURRENCY_RIDING_SPEED"
--- | "LUIE_CURRENCY_RIDING_STAMINA"
--- | "LUIE_CURRENCY_THROTTLE"
--- | "LUIE_CURRENCY_TRADE"
--- | "LUIE_CURRENCY_VENDOR"

local function ResolveStorageType(changeColor, messageType)
    local bagType
    local icon
    if messageType == "LUIE_CURRENCY_BAG" then
        bagType = string_format(ChatAnnouncements.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_BAGTYPE1) .. ChatAnnouncements.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
        icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/icons/store_upgrade_bag.dds|t " or ""
    end
    if messageType == "LUIE_CURRENCY_BANK" then
        bagType = string_format(ChatAnnouncements.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_BAGTYPE2) .. ChatAnnouncements.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
        icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/icons/store_upgrade_bank.dds|t " or ""
    end
    return string_format("|r" .. icon .. "|cFFFFFF" .. bagType .. "|r|c" .. changeColor)
end

local function ResolveRidingStats(changeColor, messageType)
    -- if some var then icon = else no
    local skillType
    local icon
    if messageType == "LUIE_CURRENCY_RIDING_SPEED" then
        skillType = string_format(ChatAnnouncements.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE1) .. ChatAnnouncements.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
        icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_speed.dds|t " or ""
    elseif messageType == "LUIE_CURRENCY_RIDING_CAPACITY" then
        skillType = string_format(ChatAnnouncements.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE2) .. ChatAnnouncements.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
        icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_capacity.dds|t " or ""
    elseif messageType == "LUIE_CURRENCY_RIDING_STAMINA" then
        skillType = string_format(ChatAnnouncements.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE3) .. ChatAnnouncements.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
        icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_stamina.dds|t " or ""
    end
    return string_format("|r" .. icon .. "|cFFFFFF" .. skillType .. "|r|c" .. changeColor)
end

-- Printer function receives values from currency update or from other functions that display currency updates.
-- Type here refers to an LUIE_CURRENCY_TYPE
---
--- @param baseCurrencyType CurrencyType
--- @param formattedValue string
--- @param changeColor string
--- @param changeType string
--- @param currencyTypeColor string
--- @param currencyIcon string
--- @param currencyName string
--- @param currencyTotal boolean
--- @param messageChange string
--- @param messageTotal string
--- @param messageType LUIE_CURRENCY_TYPE
--- @param carriedItem string
--- @param carriedItemTotal string
function ChatAnnouncements.CurrencyPrinter(baseCurrencyType, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, carriedItem, carriedItemTotal)
    messageType = messageType or ""
    changeColor = changeColor or ""
    currencyTypeColor = currencyTypeColor or ""
    currencyIcon = currencyIcon or ""
    changeType = changeType or ""
    currencyName = currencyName or ""
    formattedValue = formattedValue or ""
    messageChange = messageChange or ""
    messageTotal = messageTotal or ""
    carriedItem = carriedItem or ""
    carriedItemTotal = carriedItemTotal or ""

    local isVendor = messageType == "LUIE_CURRENCY_VENDOR"
    local isHeraldry = messageType == "LUIE_CURRENCY_HERALDRY"
    local isPostage = messageType == "LUIE_CURRENCY_POSTAGE"
    local showVendorTotal = isVendor and ChatAnnouncements.SV.Inventory.LootVendorTotalCurrency
    local shouldBuildTotal = (currencyTotal and not isHeraldry) or showVendorTotal
    local shouldFormatTotal = currencyTotal or showVendorTotal
    local shouldShowTotal = (currencyTotal and not isHeraldry and not isVendor and not isPostage) or showVendorTotal

    local messageP1 = string_format("|r|c%s%s %s%s|r|c%s", currencyTypeColor, currencyIcon, changeType, currencyName, changeColor)
    local messageP2 = shouldBuildTotal and string_format("|r|c%s%s %s|r|c%s", currencyTypeColor, currencyIcon, formattedValue, changeColor) or "|r"

    local formattedMessageP1
    if messageType == "LUIE_CURRENCY_BAG" or messageType == "LUIE_CURRENCY_BANK" then
        formattedMessageP1 = string_format(messageChange, ResolveStorageType(changeColor, messageType), messageP1)
        -- TODO: Fix later
        --[[
    elseif messageType == "LUIE_CURRENCY_HERALDRY" then
        local icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:LuiExtended/media/unitframes/ca_heraldry.dds|t " or ""
        local heraldryMessage = string_format("|r" .. icon .. "|cFFFFFF" .. ChatAnnouncements.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_CURRENCY_NAME_HERALDRY) .. ChatAnnouncements.linkBracket2[ChatAnnouncements.SV.BracketOptionItem] .. "|r|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, messageP1, heraldryMessage))
        ]]
        --
    elseif messageType == "LUIE_CURRENCY_RIDING_SPEED" or messageType == "LUIE_CURRENCY_RIDING_CAPACITY" or messageType == "LUIE_CURRENCY_RIDING_STAMINA" then
        formattedMessageP1 = string_format(messageChange, ResolveRidingStats(changeColor, messageType), messageP1)
    elseif isVendor then
        local item = string_format("|r%s|c%s", carriedItem, changeColor)
        formattedMessageP1 = string_format(messageChange, item, messageP1)
    elseif messageType == "LUIE_CURRENCY_TRADE" then
        local tradeTarget = ChatAnnouncements.tradeTarget or ""
        local name = string_format("|r%s|c%s", tradeTarget, changeColor)
        formattedMessageP1 = string_format(messageChange, messageP1, name)
    elseif messageType == "LUIE_CURRENCY_MAIL" then
        -- Use currentMailSender which was set from the queue when currency change occurred
        -- Don't use Mail.target as fallback during take all, as it gets contaminated
        local mailSender = ChatAnnouncements.currentMailSender or ""
        local name = string_format("|r%s|c%s", mailSender, changeColor)
        formattedMessageP1 = string_format(messageChange, messageP1, name)
    else
        formattedMessageP1 = string_format(messageChange, messageP1)
    end
    local formattedMessageP2 = shouldFormatTotal and ((messageTotal ~= "" and string_format(messageTotal, messageP2)) or messageP2) or messageP2
    local finalMessage
    if shouldShowTotal then
        if isVendor then
            finalMessage = string_format("|c%s%s|r%s |c%s%s|r", changeColor, formattedMessageP1, carriedItemTotal, changeColor, formattedMessageP2)
        else
            finalMessage = string_format("|c%s%s|r |c%s%s|r", changeColor, formattedMessageP1, changeColor, formattedMessageP2)
        end
    else
        if isVendor then
            finalMessage = string_format("|c%s%s|r%s", changeColor, formattedMessageP1, carriedItemTotal)
        else
            finalMessage = string_format("|c%s%s|r", changeColor, formattedMessageP1)
        end
    end

    -- If this value is being sent from the Throttle Printer, do not throttle the printout of the value
    if messageType == "LUIE_CURRENCY_THROTTLE" then
        printToChat(finalMessage)
        -- Otherwise sent to our Print Queued Messages function to be processed on a 50 ms delay.
    else
        local resolveType = (messageType == "LUIE_CURRENCY_POSTAGE" and "CURRENCY_POSTAGE") or (baseCurrencyType == CURT_CROWNS and "EXPERIENCE") or "CURRENCY"
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = finalMessage,
            messageType = resolveType
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
end

function ChatAnnouncements.CurrencyGoldThrottlePrinter()
    if ChatAnnouncements.currencyGoldThrottleValue > 0 and ChatAnnouncements.currencyGoldThrottleValue > ChatAnnouncements.SV.Currency.CurrencyGoldFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyUpColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(ChatAnnouncements.currencyGoldThrottleValue)
        local currencyTypeColor = ChatAnnouncements.Colors.CurrencyGoldColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_MONEY), 16, 16) or ""
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, ChatAnnouncements.currencyGoldThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
        local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalGold
        local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
        local messageType = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, "", "")
    end
    ChatAnnouncements.currencyGoldThrottleValue = 0
    ChatAnnouncements.currencyGoldThrottleTotal = 0
end

function ChatAnnouncements.CurrencyAPThrottlePrinter()
    if ChatAnnouncements.currencyAPThrottleValue > 0 and ChatAnnouncements.currencyAPThrottleValue > ChatAnnouncements.SV.Currency.CurrencyAPFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(ChatAnnouncements.currencyAPThrottleTotal)
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyUpColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(ChatAnnouncements.currencyAPThrottleValue)
        local currencyTypeColor = ChatAnnouncements.Colors.CurrencyAPColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_ALLIANCE_POINTS), 16, 16) or ""
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyAPName, ChatAnnouncements.currencyAPThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyAPShowTotal
        local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalAP
        local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageEarn
        local messageType = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(
            CURT_ALLIANCE_POINTS,
            formattedValue,
            changeColor,
            changeType,
            currencyTypeColor,
            currencyIcon,
            currencyName,
            currencyTotal,
            messageChange,
            messageTotal,
            messageType,
            nil,
            nil
        )
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedAP")
    ChatAnnouncements.currencyAPThrottleValue = 0
    ChatAnnouncements.currencyAPThrottleTotal = 0
end

function ChatAnnouncements.CurrencyTVThrottlePrinter()
    if ChatAnnouncements.currencyTVThrottleValue > 0 and ChatAnnouncements.currencyTVThrottleValue > ChatAnnouncements.SV.Currency.CurrencyTVFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(ChatAnnouncements.currencyTVThrottleTotal)
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyUpColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(ChatAnnouncements.currencyTVThrottleValue)
        local currencyTypeColor = ChatAnnouncements.Colors.CurrencyTVColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_TELVAR_STONES), 16, 16) or ""
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyTVName, ChatAnnouncements.currencyTVThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyTVShowTotal
        local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalTV
        local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
        local messageType = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(
            CURT_TELVAR_STONES,
            formattedValue,
            changeColor,
            changeType,
            currencyTypeColor,
            currencyIcon,
            currencyName,
            currencyTotal,
            messageChange,
            messageTotal,
            messageType,
            nil,
            nil
        )
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedTV")
    ChatAnnouncements.currencyTVThrottleValue = 0
    ChatAnnouncements.currencyTVThrottleTotal = 0
end

--- - **EVENT_LOCKPICK_BROKE **
---
--- @param eventId integer
--- @param inactivityLengthMs integer
function ChatAnnouncements.MiscAlertLockBroke(eventId, inactivityLengthMs)
    ChatAnnouncements.lockpickBroken = true
    LUIE_callLater(function ()
                       ChatAnnouncements.lockpickBroken = false
                   end, 200)
end

--- - **EVENT_LOCKPICK_SUCCESS**
---
--- @param eventId integer
function ChatAnnouncements.MiscAlertLockSuccess(eventId)
    if ChatAnnouncements.SV.Notify.NotificationLockpickCA then
        local message = GetString(LUIE_STRING_CA_LOCKPICK_SUCCESS)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = message,
            messageType = "NOTIFICATION"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_LOCKPICK_SUCCESS))
    end
    ChatAnnouncements.lockpickBroken = true
    LUIE_callLater(function ()
                       ChatAnnouncements.lockpickBroken = false
                   end, 200)
end

--- - **EVENT_INVENTORY_BAG_CAPACITY_CHANGED **
---
--- @param eventId integer
--- @param previousCapacity integer
--- @param currentCapacity integer
--- @param previousUpgrade integer
--- @param currentUpgrade integer
function ChatAnnouncements.StorageBag(eventId, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
        if ChatAnnouncements.SV.Notify.StorageBagCA then
            local formattedString = ChatAnnouncements.Colors.StorageBagColorize:Colorize(zo_strformat(SI_INVENTORY_BAG_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.StorageBagAlert then
            local text = zo_strformat(LUIE_STRING_CA_STORAGE_BAG_UPGRADE)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end
    end
end

--- - **EVENT_INVENTORY_BANK_CAPACITY_CHANGED **
---
--- @param eventId integer
--- @param previousCapacity integer
--- @param currentCapacity integer
--- @param previousUpgrade integer
--- @param currentUpgrade integer
function ChatAnnouncements.StorageBank(eventId, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
        if ChatAnnouncements.SV.Notify.StorageBagCA then
            local formattedString = ChatAnnouncements.Colors.StorageBagColorize:Colorize(zo_strformat(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = formattedString,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.StorageBagAlert then
            local text = zo_strformat(LUIE_STRING_CA_STORAGE_BANK_UPGRADE)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end
    end
end

--- - **EVENT_BUYBACK_RECEIPT **
---
--- @param eventId integer
--- @param itemLink string
--- @param itemQuantity integer
--- @param money integer
--- @param itemSoundCategory ItemUISoundCategory
function ChatAnnouncements.OnBuybackItem(eventId, itemLink, itemQuantity, money, itemSoundCategory)
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    end
    local itemName = GetItemLinkName(itemLink)
    local itemIcon = GetItemLinkIcon(itemLink)
    local icon = itemIcon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local messageType = "LUIE_CURRENCY_VENDOR"
    local messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageBuyback or ChatAnnouncements.SV.ContextMessages.CurrencyMessageBuybackNoV
    local itemCount = itemQuantity > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. itemQuantity .. "|r") or ""
    local carriedItem
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        carriedItem = (formattedIcon .. itemName .. itemCount)
    else
        carriedItem = (formattedIcon .. StringOnlyGSUB(itemName, "^|H0", "|H1", 1) .. itemCount)
    end

    local carriedItemTotal = ""
    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
        local total = getItemLinkStackCount(itemLink)
        if total >= 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if ChatAnnouncements.savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(
                nil,
                ChatAnnouncements.savedPurchase.formattedValue,
                changeColor,
                ChatAnnouncements.savedPurchase.changeType,
                ChatAnnouncements.savedPurchase.currencyTypeColor,
                ChatAnnouncements.savedPurchase.currencyIcon,
                ChatAnnouncements.savedPurchase.currencyName,
                ChatAnnouncements.savedPurchase.currencyTotal,
                messageChange,
                ChatAnnouncements.savedPurchase.messageTotal,
                messageType,
                carriedItem,
                carriedItemTotal
            )
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = finalMessage,
            messageType = "CURRENCY"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    ChatAnnouncements.savedPurchase = {}
end

--- - **EVENT_BUY_RECEIPT **
---
--- @param eventId integer
--- @param entryName string
--- @param entryType StoreEntryType
--- @param entryQuantity integer
--- @param money integer
--- @param specialCurrencyType1 CurrencyType
--- @param specialCurrencyInfo1 string
--- @param specialCurrencyQuantity1 integer
--- @param specialCurrencyType2 CurrencyType
--- @param specialCurrencyInfo2 string
--- @param specialCurrencyQuantity2 integer
--- @param itemSoundCategory ItemUISoundCategory
function ChatAnnouncements.OnBuyItem(eventId, entryName, entryType, entryQuantity, money, specialCurrencyType1, specialCurrencyInfo1, specialCurrencyQuantity1, specialCurrencyType2, specialCurrencyInfo2, specialCurrencyQuantity2, itemSoundCategory)
    -- Default the icon to the missing texture path to start with.
    local itemIcon = ZO_NO_TEXTURE_FILE
    if entryType == STORE_ENTRY_TYPE_COLLECTIBLE then
        if isShopCollectible[entryName] then
            local id = isShopCollectible[entryName]
            entryName = GetCollectibleLink(id, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            itemIcon = GetCollectibleIcon(id) or ZO_NO_TEXTURE_FILE
        else
            local collectibleId = GetCollectibleIdFromLink(entryName)
            if collectibleId then
                itemIcon = GetCollectibleIcon(collectibleId) or ZO_NO_TEXTURE_FILE
            else
                itemIcon = ZO_NO_TEXTURE_FILE
            end
        end
    else
        -- Try to get an icon for non-collectibles, or set a different default
        itemIcon = GetItemLinkIcon(entryName) or ZO_NO_TEXTURE_FILE
    end

    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    end
    local icon = itemIcon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local messageType = "LUIE_CURRENCY_VENDOR"
    local messageChange = ((money ~= 0 or specialCurrencyQuantity1 ~= 0 or specialCurrencyQuantity2 ~= 0) and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageBuy or ChatAnnouncements.SV.ContextMessages.CurrencyMessageBuyNoV
    local itemCount = entryQuantity > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. entryQuantity .. "|r") or ""
    local carriedItem
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        carriedItem = (formattedIcon .. entryName .. itemCount)
    else
        carriedItem = (formattedIcon .. StringOnlyGSUB(entryName, "^|H0", "|H1", 1) .. itemCount)
    end

    local carriedItemTotal = ""
    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
        local total = getItemLinkStackCount(entryName)
        if total >= 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if (money ~= 0 or specialCurrencyQuantity1 ~= 0 or specialCurrencyQuantity2 ~= 0) and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if ChatAnnouncements.savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(
                nil,
                ChatAnnouncements.savedPurchase.formattedValue,
                changeColor,
                ChatAnnouncements.savedPurchase.changeType,
                ChatAnnouncements.savedPurchase.currencyTypeColor,
                ChatAnnouncements.savedPurchase.currencyIcon,
                ChatAnnouncements.savedPurchase.currencyName,
                ChatAnnouncements.savedPurchase.currencyTotal,
                messageChange,
                ChatAnnouncements.savedPurchase.messageTotal,
                messageType,
                carriedItem,
                carriedItemTotal
            )
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = finalMessage,
            messageType = "CURRENCY"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    ChatAnnouncements.savedPurchase = {}
end

--- - **EVENT_SELL_RECEIPT **
---
--- @param eventId integer
--- @param itemName string
--- @param itemQuantity integer
--- @param money integer
function ChatAnnouncements.OnSellItem(eventId, itemName, itemQuantity, money)
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyUpColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    end
    local itemIcon = GetItemLinkIcon(itemName)
    local icon = itemIcon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local messageType = "LUIE_CURRENCY_VENDOR"
    local messageChange
    if ChatAnnouncements.weAreInAFence then
        messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageFence or ChatAnnouncements.SV.ContextMessages.CurrencyMessageFenceNoV
    else
        messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageSell or ChatAnnouncements.SV.ContextMessages.CurrencyMessageSellNoV
    end
    local itemCount = itemQuantity > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. itemQuantity .. "|r") or ""
    local carriedItem
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        carriedItem = (formattedIcon .. itemName .. itemCount)
    else
        carriedItem = (formattedIcon .. StringOnlyGSUB(itemName, "^|H0", "|H1", 1) .. itemCount)
    end

    local carriedItemTotal = ""
    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
        local total = getItemLinkStackCount(itemName)
        if total >= 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if ChatAnnouncements.savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(
                nil,
                ChatAnnouncements.savedPurchase.formattedValue,
                changeColor,
                ChatAnnouncements.savedPurchase.changeType,
                ChatAnnouncements.savedPurchase.currencyTypeColor,
                ChatAnnouncements.savedPurchase.currencyIcon,
                ChatAnnouncements.savedPurchase.currencyName,
                ChatAnnouncements.savedPurchase.currencyTotal,
                messageChange,
                ChatAnnouncements.savedPurchase.messageTotal,
                messageType,
                carriedItem,
                carriedItemTotal
            )
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = finalMessage,
            messageType = "CURRENCY"
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    ChatAnnouncements.savedPurchase = {}
end

--- - **EVENT_TRADING_HOUSE_RESPONSE_RECEIVED **
---
--- @param eventId integer
--- @param responseType TradingHouseResult
--- @param result TradingHouseResult
function ChatAnnouncements.TradingHouseResponseReceived(eventId, responseType, result)
    -- Bail if a pending item isn't being sold
    if not responseType == TRADING_HOUSE_RESULT_POST_PENDING then
        return
    end
    -- If we don't have both a valid saved currency transaction and saved message then bail out.
    if not ChatAnnouncements.savedPurchase.formattedValue or not ChatAnnouncements.savedItem.itemLink then
        ChatAnnouncements.savedPurchase = {}
        ChatAnnouncements.savedItem = {}
        return
    end

    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    end
    local messageType = "LUIE_CURRENCY_VENDOR"
    local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageListingValue

    local icon = ChatAnnouncements.savedItem.icon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local stack = ChatAnnouncements.savedItem.stack
    local itemCount = stack > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. stack .. "|r") or ""
    local itemName = ChatAnnouncements.savedItem.itemLink

    local carriedItem
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        carriedItem = (formattedIcon .. itemName .. itemCount)
    else
        carriedItem = (formattedIcon .. StringOnlyGSUB(itemName, "^|H0", "|H1", 1) .. itemCount)
    end

    local carriedItemTotal = ""
    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
        local total = getItemLinkStackCount(itemName)
        if total >= 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        ChatAnnouncements.CurrencyPrinter(
            nil,
            ChatAnnouncements.savedPurchase.formattedValue,
            changeColor,
            ChatAnnouncements.savedPurchase.changeType,
            ChatAnnouncements.savedPurchase.currencyTypeColor,
            ChatAnnouncements.savedPurchase.currencyIcon,
            ChatAnnouncements.savedPurchase.currencyName,
            ChatAnnouncements.savedPurchase.currencyTotal,
            messageChange,
            ChatAnnouncements.savedPurchase.messageTotal,
            messageType,
            carriedItem,
            carriedItemTotal
        )
    else
        messageType = "CURRENCY"
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageList
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = finalMessage,
            messageType = messageType
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageListing
        ChatAnnouncements.CurrencyPrinter(
            nil,
            ChatAnnouncements.savedPurchase.formattedValue,
            changeColor,
            ChatAnnouncements.savedPurchase.changeType,
            ChatAnnouncements.savedPurchase.currencyTypeColor,
            ChatAnnouncements.savedPurchase.currencyIcon,
            ChatAnnouncements.savedPurchase.currencyName,
            ChatAnnouncements.savedPurchase.currencyTotal,
            messageChange,
            ChatAnnouncements.savedPurchase.messageTotal,
            messageType,
            nil,
            nil
        )
    end
    ChatAnnouncements.savedPurchase = {}
    ChatAnnouncements.savedItem = {}
end

-- Helper function to return color (without |c prefix) according to current percentage
local function AchievementPctToColor(pct)
    return pct == 1 and "71DE73" or pct < 0.33 and "F27C7C" or pct < 0.66 and "EDE858" or "CCF048"
end

--- - **EVENT_ACHIEVEMENT_UPDATED **
---
--- @param eventId integer
--- @param id integer
function ChatAnnouncements.OnAchievementUpdated(eventId, id)
    local topLevelIndex, categoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(id)
    -- Bail out if this achievement comes from unwanted category
    if ChatAnnouncements.SV.Achievement.AchievementCategoryIgnore[topLevelIndex] then
        return
    end

    if ChatAnnouncements.SV.Achievement.AchievementUpdateCA or ChatAnnouncements.SV.Achievement.AchievementUpdateAlert then
        local totalCmp = 0
        local totalReq = 0
        local showInfo = false

        local numCriteria = GetAchievementNumCriteria(id)
        local cmpInfo = {}
        for i = 1, numCriteria do
            local name, numCompleted, numRequired = GetAchievementCriterion(id, i)

            table_insert(cmpInfo, { zo_strformat(name), numCompleted, numRequired })

            -- Collect the numbers to calculate the correct percentage
            totalCmp = totalCmp + numCompleted
            totalReq = totalReq + numRequired

            -- Show the achievement on every special achievement because it's a rare event
            if numRequired == 1 and numCompleted == 1 then
                showInfo = true
            end
        end

        -- TODO: Resume debug later
        -- d(totalCmp)
        -- d(totalReq)
        -- d(showInfo)

        if not showInfo then
            -- If the progress is 100%, return (sometimes happens)
            if totalCmp == totalReq then
                return
            end

            -- This is the first progress step, show every time
            if totalCmp == 1 or (ChatAnnouncements.SV.Achievement.AchievementStep == 0) then
                showInfo = true
            else
                -- Achievement step hit
                local percentage = zo_floor(100 / totalReq * totalCmp)

                if percentage > 0 and percentage % ChatAnnouncements.SV.Achievement.AchievementStep == 0 and ChatAnnouncements.achievementLastPercentage[id] ~= percentage then
                    showInfo = true
                    ChatAnnouncements.achievementLastPercentage[id] = percentage
                end
            end
        end

        -- Bail out here if this achievement update event is not going to be printed to chat
        if not showInfo then
            return
        end

        local link = zo_strformat(GetAchievementLink(id, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionAchievement]))
        local name = zo_strformat(GetAchievementNameFromLink(link))

        if ChatAnnouncements.SV.Achievement.AchievementUpdateCA then
            local catName = GetAchievementCategoryInfoName(topLevelIndex)
            local subcatName = categoryIndex ~= nil and GetAchievementSubCategoryInfoName(topLevelIndex, categoryIndex) or "General"
            local icon = GetAchievementInfoIcon(id)
            icon = ChatAnnouncements.SV.Achievement.AchievementIcon and ("|t16:16:" .. icon .. "|t ") or ""

            local stringpart1 = ChatAnnouncements.Colors.AchievementColorize1:Colorize(string_format("%s%s%s %s%s", ChatAnnouncements.bracket1[ChatAnnouncements.SV.Achievement.AchievementBracketOptions], ChatAnnouncements.SV.Achievement.AchievementProgressMsg, ChatAnnouncements.bracket2[ChatAnnouncements.SV.Achievement.AchievementBracketOptions], icon, link))

            local stringpart2 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and string_format(" %s|c%s%d%%|r", ChatAnnouncements.Colors.AchievementColorize2:Colorize("("), AchievementPctToColor(totalCmp / totalReq), zo_floor(100 * totalCmp / totalReq)) or ChatAnnouncements.Colors.AchievementColorize2:Colorize(string_format("%d%%", zo_floor(100 * totalCmp / totalReq)))

            local stringpart3
            if ChatAnnouncements.SV.Achievement.AchievementCategory and ChatAnnouncements.SV.Achievement.AchievementSubcategory then
                stringpart3 = ChatAnnouncements.Colors.AchievementColorize2:Colorize(string_format(") %s%s - %s%s", ChatAnnouncements.bracket3[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions], catName, subcatName, ChatAnnouncements.bracket4[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions]))
            elseif ChatAnnouncements.SV.Achievement.AchievementCategory and not ChatAnnouncements.SV.Achievement.AchievementSubcategory then
                stringpart3 = ChatAnnouncements.Colors.AchievementColorize2:Colorize(string_format(") %s%s%s", ChatAnnouncements.bracket3[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions], catName, ChatAnnouncements.bracket4[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions]))
            else
                stringpart3 = ChatAnnouncements.Colors.AchievementColorize2:Colorize(")")
            end

            -- Prepare details information
            local stringpart4 = ""
            if ChatAnnouncements.SV.Achievement.AchievementDetails then
                -- Skyshards needs separate treatment otherwise text become too long
                -- We also put this short information for achievements that has too many subitems
                if topLevelIndex == 9 or #cmpInfo > 12 then
                    stringpart4 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and string_format(" %s|c%s%d|r%s|c71DE73%d|c87B7CC|r%s", ChatAnnouncements.Colors.AchievementColorize2:Colorize("("), AchievementPctToColor(totalCmp / totalReq), totalCmp, ChatAnnouncements.Colors.AchievementColorize2:Colorize("/"), totalReq, ChatAnnouncements.Colors.AchievementColorize2:Colorize(")")) or ChatAnnouncements.Colors.AchievementColorize2:Colorize(string_format(" (%d/%d)", totalCmp, totalReq))
                else
                    for i = 1, #cmpInfo do
                        -- Boolean achievement stage
                        if cmpInfo[i][3] == 1 then
                            cmpInfo[i] = ChatAnnouncements.SV.Achievement.AchievementColorProgress and string_format("|c%s%s", AchievementPctToColor(cmpInfo[i][2]), cmpInfo[i][1]) or ChatAnnouncements.Colors.AchievementColorize2:Colorize(string_format("%s%s", cmpInfo[i][2], cmpInfo[i][1]))
                            -- Others
                        else
                            local pct = cmpInfo[i][2] / cmpInfo[i][3]
                            cmpInfo[i] = ChatAnnouncements.SV.Achievement.AchievementColorProgress and string_format("%s %s|c%s%d|r%s|c71DE73%d|r%s", ChatAnnouncements.Colors.AchievementColorize2:Colorize(cmpInfo[i][1]), ChatAnnouncements.Colors.AchievementColorize2:Colorize("("), AchievementPctToColor(pct), cmpInfo[i][2], ChatAnnouncements.Colors.AchievementColorize2:Colorize("/"), cmpInfo[i][3], ChatAnnouncements.Colors.AchievementColorize2:Colorize(")")) or ChatAnnouncements.Colors.AchievementColorize2:Colorize(string_format("%s (%d/%d)", cmpInfo[i][1], cmpInfo[i][2], cmpInfo[i][3]))
                        end
                    end
                    stringpart4 = " " .. table_concat(cmpInfo, ChatAnnouncements.Colors.AchievementColorize2:Colorize(", ")) .. ""
                end
            end
            local finalString = string_format("%s%s%s%s", stringpart1, stringpart2, stringpart3, stringpart4)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = finalString,
                messageType = "ACHIEVEMENT"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Achievement.AchievementUpdateAlert then
            local alertMessage = zo_strformat("<<1>>: <<2>>", ChatAnnouncements.SV.Achievement.AchievementProgressMsg, name)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end
    end
end

--- - *EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED*
--- @param eventCode integer
--- @param timedActivityIndex luaindex
--- @param previousProgress integer
--- @param currentProgress integer
--- @param complete boolean
function ChatAnnouncements.OnTimedActivityProgressUpdated(eventCode, timedActivityIndex, previousProgress, currentProgress, complete)
    if ChatAnnouncements.SV.Notify.TimedActivityCA or ChatAnnouncements.SV.Notify.TimedActivityAlert then
        local name = GetTimedActivityName(timedActivityIndex)
        local messageType = GetTimedActivityType(timedActivityIndex)
        local maxProgress = GetTimedActivityMaxProgress(timedActivityIndex)
        local progress = string_format("%i / %i", currentProgress, maxProgress)

        local typeName
        if messageType == TIMED_ACTIVITY_TYPE_DAILY then
            typeName = GetString(SI_TIMEDACTIVITYTYPE0)
        elseif messageType == TIMED_ACTIVITY_TYPE_WEEKLY then
            typeName = GetString(SI_TIMEDACTIVITYTYPE1)
        end

        local message = string_format("[%s] %s: %s", zo_strformat(GetString(LUIE_STRING_CA_DISPLAY_TIMED_ACTIVITIES), typeName), name, progress)

        if ChatAnnouncements.SV.Notify.TimedActivityCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "MESSAGE",
                activityIndex = timedActivityIndex,
                previousProgress = previousProgress,
                currentProgress = currentProgress,
                complete = complete
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.TimedActivityAlert then
            local alertMessage = zo_strformat(GetString(SI_APPLYOUTFITCHANGESRESULT0), GetString(SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES))
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end
    end
end

--- - *EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED*
--- @param eventCode integer
--- @param campaignKey id64
--- @param activityIndex luaindex
--- @param previousProgress integer
--- @param newProgress integer
--- @param rewardFlags PromotionalEventRewardFlags
function ChatAnnouncements.OnPromotionalEventsActivityProgressUpdated(eventCode, campaignKey, activityIndex, previousProgress, newProgress, rewardFlags)
    if ChatAnnouncements.SV.Notify.PromotionalEventsActivityCA or ChatAnnouncements.SV.Notify.PromotionalEventsActivityAlert then
        local activityId, displayName, description, completionThreshold, rewardId, rewardQuantity = GetPromotionalEventCampaignActivityInfo(campaignKey, activityIndex)
        local progress = string_format("%i / %i", newProgress, completionThreshold)

        local message = string_format("[%s] %s: %s", GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER), displayName, progress)

        if ChatAnnouncements.SV.Notify.PromotionalEventsActivityCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "MESSAGE",
                activityId = activityId,
                rewardId = rewardId,
                rewardQuantity = rewardQuantity
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.PromotionalEventsActivityAlert then
            local alertMessage = zo_strformat(GetString(SI_APPLYOUTFITCHANGESRESULT0), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER))
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end
    end
end

--- - *EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED*
--- @param eventCode integer
--- @param craftedAbilityDefId integer
--- @param isUnlocked boolean
--- @param isFromInit boolean
function ChatAnnouncements.OnCraftedAbilityLockStateChanged(eventCode, craftedAbilityDefId, isUnlocked, isFromInit)
    -- Only show messages for new unlocks, not initial loading
    if isFromInit then return end

    if ChatAnnouncements.SV.Notify.CraftedAbilityCA or ChatAnnouncements.SV.Notify.CraftedAbilityAlert then
        local abilityName = GetCraftedAbilityDisplayName(craftedAbilityDefId)
        -- Get the ability icon
        local icon = GetCraftedAbilityIcon(craftedAbilityDefId)
        local iconString = icon and ("|t16:16:" .. icon .. "|t ") or ""

        -- Color formatting
        local nameColor = "FFFF00"  -- Yellow for the name
        local stateColor = "71DE73" -- Green for unlocked state

        local message = string_format("|c%s%s|r: %s|c%s%s|r",
                                      stateColor, GetString(SI_CRAFTED_ABILITY_UNLOCKED_ANNOUNCE_TITLE),
                                      iconString,
                                      nameColor, abilityName)

        if ChatAnnouncements.SV.Notify.CraftedAbilityCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "SKILL",
                abilityDefId = craftedAbilityDefId,
                isUnlocked = isUnlocked
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.CraftedAbilityAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
    end
end

--- - *EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED*
--- @param eventCode integer
--- @param craftedAbilityScriptDefId integer
--- @param isUnlocked boolean
function ChatAnnouncements.OnCraftedAbilityScriptLockStateChanged(eventCode, craftedAbilityScriptDefId, isUnlocked)
    -- For scripts, we should only show messages when they're newly unlocked
    if not isUnlocked then return end

    if ChatAnnouncements.SV.Notify.CraftedAbilityScriptCA or ChatAnnouncements.SV.Notify.CraftedAbilityScriptAlert then
        local scriptName = GetCraftedAbilityScriptDisplayName(craftedAbilityScriptDefId)
        -- Get the script icon
        local icon = GetCraftedAbilityScriptIcon(craftedAbilityScriptDefId)
        local iconString = icon and ("|t16:16:" .. icon .. "|t ") or ""

        -- Color formatting
        local nameColor = "FFFF00"  -- Yellow for the name
        local stateColor = "71DE73" -- Green for unlocked state

        local message = string_format("|c%s%s|r: %s|c%s%s|r",
                                      stateColor, GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE),
                                      iconString,
                                      nameColor, scriptName)

        if ChatAnnouncements.SV.Notify.CraftedAbilityScriptCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "SKILL",
                scriptDefId = craftedAbilityScriptDefId,
                isUnlocked = isUnlocked
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.CraftedAbilityScriptAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
    end
end

--- - **EVENT_GUILD_BANK_ITEM_ADDED **
---
---
--- @param eventId integer
--- @param slotId integer
--- @param addedByLocalPlayer boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param isLastUpdateForMessage boolean
function ChatAnnouncements.GuildBankItemAdded(eventId, slotId, addedByLocalPlayer, itemSoundCategory, isLastUpdateForMessage)
    if addedByLocalPlayer then
        LUIE_callLater(ChatAnnouncements.LogGuildBankChange, 50)
    end
end

--- - **EVENT_GUILD_BANK_ITEM_REMOVED **
---
---
--- @param eventId integer
--- @param slotId integer
--- @param addedByLocalPlayer boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param isLastUpdateForMessage boolean
function ChatAnnouncements.GuildBankItemRemoved(eventId, slotId, addedByLocalPlayer, itemSoundCategory, isLastUpdateForMessage)
    if addedByLocalPlayer then
        LUIE_callLater(ChatAnnouncements.LogGuildBankChange, 50)
    end
end

function ChatAnnouncements.LogGuildBankChange()
    if ChatAnnouncements.guildBankCarry ~= nil then
        ChatAnnouncements.ItemPrinter(
            ChatAnnouncements.guildBankCarry.icon,
            ChatAnnouncements.guildBankCarry.stack,
            ChatAnnouncements.guildBankCarry.itemType,
            ChatAnnouncements.guildBankCarry.itemId,
            ChatAnnouncements.guildBankCarry.itemLink,
            ChatAnnouncements.guildBankCarry.receivedBy,
            ChatAnnouncements.guildBankCarry.logPrefix,
            ChatAnnouncements.guildBankCarry.gainOrLoss,
            false,
            nil,
            nil,
            nil
        )
    end
    ChatAnnouncements.guildBankCarry = nil
end

function ChatAnnouncements.IndexInventory()
    -- d("Debug - Inventory Indexed!")
    local bagsize = GetBagSize(BAG_BACKPACK)

    for i = 0, bagsize do
        local icon, stack = GetItemInfo(BAG_BACKPACK, i)
        local itemType = GetItemType(BAG_BACKPACK, i)
        local itemId = GetItemId(BAG_BACKPACK, i)
        local itemLink = GetItemLink(BAG_BACKPACK, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        if itemLink ~= "" then
            ChatAnnouncements.inventoryStacks[i] =
            {
                icon = icon,
                stack = stack,
                itemId = itemId,
                itemType = itemType,
                itemLink = itemLink
            }
        end
    end
end

function ChatAnnouncements.IndexEquipped()
    -- d("Debug - Equipped Items Indexed!")
    local bagsize = GetBagSize(BAG_WORN)

    for i = 0, bagsize do
        local icon, stack = GetItemInfo(BAG_WORN, i)
        local itemType = GetItemType(BAG_WORN, i)
        local itemId = GetItemId(BAG_WORN, i)
        local itemLink = GetItemLink(BAG_WORN, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        if itemLink ~= "" then
            ChatAnnouncements.equippedStacks[i] =
            {
                icon = icon,
                stack = stack,
                itemId = itemId,
                itemType = itemType,
                itemLink = itemLink
            }
        end
    end
end

function ChatAnnouncements.IndexBank()
    -- ("Debug - Bank Indexed!")
    local bagsizebank = GetBagSize(BAG_BANK)
    local bagsizesubbank = GetBagSize(BAG_SUBSCRIBER_BANK)

    for i = 0, bagsizebank do
        local icon, stack = GetItemInfo(BAG_BANK, i)
        local bagitemlink = GetItemLink(BAG_BANK, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemId = GetItemId(BAG_BANK, i)
        local itemLink = GetItemLink(BAG_BANK, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemType = GetItemType(BAG_BANK, i)
        if bagitemlink ~= "" then
            ChatAnnouncements.bankStacks[i] =
            {
                icon = icon,
                stack = stack,
                itemId = itemId,
                itemType = itemType,
                itemLink = itemLink
            }
        end
    end

    for i = 0, bagsizesubbank do
        local icon, stack = GetItemInfo(BAG_SUBSCRIBER_BANK, i)
        local bagitemlink = GetItemLink(BAG_SUBSCRIBER_BANK, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemId = GetItemId(BAG_SUBSCRIBER_BANK, i)
        local itemLink = GetItemLink(BAG_SUBSCRIBER_BANK, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemType = GetItemType(BAG_SUBSCRIBER_BANK, i)
        if bagitemlink ~= "" then
            ChatAnnouncements.bankSubscriberStacks[i] =
            {
                icon = icon,
                stack = stack,
                itemId = itemId,
                itemType = itemType,
                itemLink = itemLink
            }
        end
    end
end

local HouseBags =
{
    [1] = BAG_HOUSE_BANK_ONE,
    [2] = BAG_HOUSE_BANK_TWO,
    [3] = BAG_HOUSE_BANK_THREE,
    [4] = BAG_HOUSE_BANK_FOUR,
    [5] = BAG_HOUSE_BANK_FIVE,
    [6] = BAG_HOUSE_BANK_SIX,
    [7] = BAG_HOUSE_BANK_SEVEN,
    [8] = BAG_HOUSE_BANK_EIGHT,
    [9] = BAG_HOUSE_BANK_NINE,
    [10] = BAG_HOUSE_BANK_TEN,
}

function ChatAnnouncements.IndexHouseBags()
    for bagIndex = 1, 10 do
        local bag = HouseBags[bagIndex]
        local bagsize = GetBagSize(bag)
        ChatAnnouncements.houseBags[bag] = {}

        for i = 0, bagsize do
            local icon, stack = GetItemInfo(bag, i)
            local bagitemlink = GetItemLink(bag, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            local itemId = GetItemId(bag, i)
            local itemLink = GetItemLink(bag, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            local itemType = GetItemType(bag, i)
            if bagitemlink ~= "" then
                ChatAnnouncements.houseBags[bag][i] =
                {
                    icon = icon,
                    stack = stack,
                    itemId = itemId,
                    itemType = itemType,
                    itemLink = itemLink
                }
            end
        end
    end
end

--- - **EVENT_CRAFTING_STATION_INTERACT **
---
--- @param eventId integer
--- @param craftSkill TradeskillType
--- @param sameStation boolean
--- @param craftMode CraftingInteractionMode
function ChatAnnouncements.CraftingOpen(eventId, craftSkill, sameStation, craftMode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootCraft then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateCraft)
        ChatAnnouncements.inventoryStacks = {}
        ChatAnnouncements.bankStacks = {}
        ChatAnnouncements.bankSubscriberStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
        ChatAnnouncements.IndexBank()      -- Index Bank
    end
end

--- - **EVENT_END_CRAFTING_STATION_INTERACT **
---
--- @param eventId integer
--- @param craftSkill TradeskillType
--- @param craftMode CraftingInteractionMode
function ChatAnnouncements.CraftingClose(eventId, craftSkill, craftMode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        ChatAnnouncements.inventoryStacks = {}
    end
    ChatAnnouncements.bankStacks = {}
    ChatAnnouncements.bankSubscriberStacks = {}
end

--- - **EVENT_OPEN_BANK **
---
--- @param eventId integer
--- @param bankBag Bag
function ChatAnnouncements.BankOpen(eventId, bankBag)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootBank then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateBank)
        ChatAnnouncements.inventoryStacks = {}
        ChatAnnouncements.bankStacks = {}
        ChatAnnouncements.bankSubscriberStacks = {}
        ChatAnnouncements.houseBags = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
        ChatAnnouncements.IndexBank()      -- Index Bank
        ChatAnnouncements.IndexHouseBags() -- Index House Bags
    end
    ChatAnnouncements.bankBag = bankBag > 6 and 2 or 1
end

--- - **EVENT_CLOSE_BANK**
---
--- @param eventId integer
function ChatAnnouncements.BankClose(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        ChatAnnouncements.inventoryStacks = {}
    end
    ChatAnnouncements.bankStacks = {}
    ChatAnnouncements.bankSubscriberStacks = {}
    ChatAnnouncements.houseBags = {}
end

--- - **EVENT_OPEN_GUILD_BANK**
---
--- @param eventId integer
function ChatAnnouncements.GuildBankOpen(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootBank then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateGuildBank)
        ChatAnnouncements.inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
end

--- - **EVENT_CLOSE_GUILD_BANK**
---
--- @param eventId integer
function ChatAnnouncements.GuildBankClose(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        ChatAnnouncements.inventoryStacks = {}
    end
end

--- - **EVENT_OPEN_FENCE **
---
--- @param eventId integer
--- @param allowSell boolean
--- @param allowLaunder boolean
function ChatAnnouncements.FenceOpen(eventId, allowSell, allowLaunder)
    ChatAnnouncements.weAreInAFence = true
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootVendor then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateFence)
        ChatAnnouncements.inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
end

--- - **EVENT_OPEN_STORE**
---
--- @param eventId integer
function ChatAnnouncements.StoreOpen(eventId)
    ChatAnnouncements.weAreInAStore = true
end

--- - **EVENT_CLOSE_STORE**
---
--- @param eventId integer
function ChatAnnouncements.StoreClose(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        ChatAnnouncements.inventoryStacks = {}
    end
    LUIE_callLater(function ()
                       ChatAnnouncements.weAreInAStore = false
                       ChatAnnouncements.weAreInAFence = false
                   end, 1000)
end

--- - **EVENT_OPEN_TRADING_HOUSE**
---
--- @param eventId integer
function ChatAnnouncements.GuildStoreOpen(eventId)
    ChatAnnouncements.weAreInAStore = true
    ChatAnnouncements.weAreInAGuildStore = true
end

--- - **EVENT_CLOSE_TRADING_HOUSE**
---
--- @param eventId integer
function ChatAnnouncements.GuildStoreClose(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        ChatAnnouncements.inventoryStacks = {}
    end
    LUIE_callLater(function ()
                       ChatAnnouncements.weAreInAStore = false
                       ChatAnnouncements.weAreInAGuildStore = false
                   end, 1000)
end

--- - **EVENT_ITEM_LAUNDER_RESULT **
---
--- @param eventId integer
--- @param result ItemLaunderResult
function ChatAnnouncements.FenceSuccess(eventId, result)
    if result == ITEM_LAUNDER_RESULT_SUCCESS then
        if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
            if ChatAnnouncements.savedPurchase.formattedValue ~= nil and ChatAnnouncements.savedPurchase.formattedValue ~= "" then
                ChatAnnouncements.CurrencyPrinter(nil, ChatAnnouncements.savedPurchase.formattedValue, ChatAnnouncements.savedPurchase.changeColor, ChatAnnouncements.savedPurchase.changeType, ChatAnnouncements.savedPurchase.currencyTypeColor, ChatAnnouncements.savedPurchase.currencyIcon, ChatAnnouncements.savedPurchase.currencyName, ChatAnnouncements.savedPurchase.currencyTotal, ChatAnnouncements.savedPurchase.messageChange, ChatAnnouncements.savedPurchase.messageTotal, ChatAnnouncements.savedPurchase.messageType, ChatAnnouncements.savedPurchase.carriedItem, ChatAnnouncements.savedPurchase.carriedItemTotal)
            end
        else
            if ChatAnnouncements.savedLaunder.itemId ~= nil and ChatAnnouncements.savedLaunder.itemId ~= "" then
                ChatAnnouncements.ItemPrinter(
                    ChatAnnouncements.savedLaunder.icon,
                    ChatAnnouncements.savedLaunder.stack,
                    ChatAnnouncements.savedLaunder.itemType,
                    ChatAnnouncements.savedLaunder.itemId,
                    ChatAnnouncements.savedLaunder.itemLink,
                    "",
                    ChatAnnouncements.savedLaunder.logPrefix,
                    ChatAnnouncements.savedLaunder.gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
            end
        end
        ChatAnnouncements.savedLaunder = {}
        ChatAnnouncements.savedPurchase = {}
    end
end

-- Only active if destroyed items is enabled, flags the next item that is removed from inventory as destroyed.
--- - **EVENT_INVENTORY_ITEM_DESTROYED **
---
--- @param eventId integer
--- @param itemSoundCategory ItemUISoundCategory
function ChatAnnouncements.DestroyItem(eventId, itemSoundCategory)
    ChatAnnouncements.itemWasDestroyed = true
end

--- - **EVENT_DISABLE_SIEGE_PACKUP_ABILITY**
---
--- @param eventId integer
function ChatAnnouncements.OnPackSiege(eventId)
    local function ResetPackSiege()
        ChatAnnouncements.packSiege = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetPackSiege")
    end
    ChatAnnouncements.packSiege = true
    eventManager:UnregisterForUpdate(moduleName .. "ResetPackSiege")
    eventManager:RegisterForUpdate(moduleName .. "ResetPackSiege", 4000, ResetPackSiege)
end

-- Helper function for Craft Bag
function ChatAnnouncements.GetItemLinkFromItemId(itemId)
    local name = GetItemLinkName(ZO_LinkHandler_CreateLink("Test Trash", nil, ITEM_LINK_TYPE, itemId, 1, 26, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 10000, 0))
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        return ZO_LinkHandler_CreateLinkWithoutBrackets(zo_strformat("<<t:1>>", name), nil, ITEM_LINK_TYPE, itemId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    else
        return ZO_LinkHandler_CreateLink(zo_strformat("<<t:1>>", name), nil, ITEM_LINK_TYPE, itemId, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    end
end

function ChatAnnouncements.AddQuestItemsToIndex()
    ChatAnnouncements.questItemIndex = {}

    for questIndex = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(questIndex) then
            -- Get quest tools
            for toolIndex = 1, GetQuestToolCount(questIndex) do
                local icon, stackCount, _, _, questItemId = GetQuestToolInfo(questIndex, toolIndex)
                if questItemId ~= 0 then
                    ChatAnnouncements.questItemIndex[questItemId] =
                    {
                        stack = stackCount,
                        counter = 0,
                        icon = icon
                    }
                end
            end

            -- Get quest items from each step and condition
            for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
                for conditionIndex = 1, GetJournalQuestNumConditions(questIndex, stepIndex) do
                    local icon, stackCount, name, questItemId = GetQuestItemInfo(questIndex, stepIndex, conditionIndex)
                    if questItemId ~= 0 then
                        ChatAnnouncements.questItemIndex[questItemId] =
                        {
                            stack = stackCount,
                            counter = 0,
                            icon = icon
                        }
                    end
                end
            end
        end
    end
end

function ChatAnnouncements.ResolveQuestItemChange()
    for itemId, _ in pairs(ChatAnnouncements.questItemIndex) do
        local countChange = nil
        local newValue = ChatAnnouncements.questItemIndex[itemId].stack + ChatAnnouncements.questItemIndex[itemId].counter

        -- Only if the value changes
        if newValue > ChatAnnouncements.questItemIndex[itemId].stack or newValue < ChatAnnouncements.questItemIndex[itemId].stack then
            local icon = ChatAnnouncements.questItemIndex[itemId].icon
            local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""

            local itemLink
            if ChatAnnouncements.SV.BracketOptionItem == 1 then
                itemLink = string_format("|H0:quest_item:" .. itemId .. "|h|h")
            else
                itemLink = string_format("|H1:quest_item:" .. itemId .. "|h|h")
            end

            local color
            local logPrefix
            local total = ChatAnnouncements.questItemIndex[itemId].stack + ChatAnnouncements.questItemIndex[itemId].counter
            local totalString

            local formattedMessageP1
            local formattedMessageP2
            local finalMessage

            -- Lower
            if newValue < ChatAnnouncements.questItemIndex[itemId].stack then
                -- Easy temporary debug for my accounts only
                -- if LUIE.IsDevDebugEnabled() then
                --     LUIE.LUIE:Log("Debug",itemId .. " Removed")
                -- end
                --

                countChange = newValue + ChatAnnouncements.questItemIndex[itemId].counter
                ChatAnnouncements.questItemRemoved[itemId] = true
                LUIE_callLater(function ()
                                   ChatAnnouncements.questItemRemoved[itemId] = false
                               end, 100)

                if not Quests.QuestItemHideRemove[itemId] and not ChatAnnouncements.loginHideQuestLoot then
                    if ChatAnnouncements.SV.Inventory.LootQuestRemove then
                        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
                            color = ChatAnnouncements.Colors.CurrencyDownColorize:ToHex()
                        else
                            color = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
                        end

                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRemove

                        -- Any items that are removed at the same time a quest is turned or advanced in will be flagged to display as "Turned In."
                        if ChatAnnouncements.itemReceivedIsQuestReward then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestTurnIn
                        end

                        if Quests.ItemRemovedMessage[itemId] and not Quests.ItemIgnoreTurnIn[itemId] then
                            logPrefix = Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_TURNIN and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestTurnIn or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_USE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestUse or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_EXHAUST and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestExhaust or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_OFFER and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestOffer or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_DISCARD and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestDiscard or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_CONFISCATE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestConfiscate or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_OPEN and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestOpen or
                                Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_ADMINISTER and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestAdminister or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_PLACE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestPlace
                        end

                        if Quests.ItemRemovedInDialogueMessage[itemId] and ChatAnnouncements.talkingToNPC then
                            logPrefix = Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_TURNIN and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestTurnIn or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_USE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestUse or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_EXHAUST and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestExhaust or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_OFFER and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestOffer or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_DISCARD and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestDiscard or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_CONFISCATE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestConfiscate or
                                Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_OPEN and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestOpen or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_ADMINISTER and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestAdminister or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_PLACE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestPlace
                        end

                        -- Any items that are removed at the same time a quest is abandoned will be flagged to display as "Removed."
                        if ChatAnnouncements.itemReceivedIsQuestAbandon then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRemove
                        end

                        local quantity = (countChange * -1) > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. (countChange * -1) .. "|r") or ""

                        formattedMessageP1 = ("|r" .. formattedIcon .. itemLink .. quantity .. "|c" .. color)
                        formattedMessageP2 = string_format(logPrefix, formattedMessageP1)

                        if ChatAnnouncements.SV.Inventory.LootTotal and total > 1 then
                            totalString = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        else
                            totalString = ""
                        end

                        finalMessage = string_format("|c%s%s|r%s", color, formattedMessageP2, totalString)

                        eventManager:UnregisterForUpdate(moduleName .. "Printer")
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                        {
                            message = finalMessage,
                            messageType = "QUEST_LOOT_REMOVE",
                            itemId = itemId
                        }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages)
                    end
                end

                if Quests.QuestItemModifyOnRemove[itemId] then
                    Quests.QuestItemModifyOnRemove[itemId]()
                end
            end

            -- Higher
            if newValue > ChatAnnouncements.questItemIndex[itemId].stack then
                -- Easy debug for my devs only
                -- if LUIE.IsDevDebugEnabled() then
                --     LUIE.LUIE:Log("Debug",itemId .. " Added")
                -- end
                --
                countChange = newValue - ChatAnnouncements.questItemIndex[itemId].stack
                ChatAnnouncements.questItemAdded[itemId] = true
                LUIE_callLater(function ()
                                   ChatAnnouncements.questItemAdded[itemId] = false
                               end, 100)

                if not Quests.QuestItemHideLoot[itemId] and not ChatAnnouncements.loginHideQuestLoot then
                    if ChatAnnouncements.SV.Inventory.LootQuestAdd then
                        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
                            color = ChatAnnouncements.Colors.CurrencyUpColorize:ToHex()
                        else
                            color = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
                        end

                        if ChatAnnouncements.isLooted and not ChatAnnouncements.itemReceivedIsQuestReward and not ChatAnnouncements.isPickpocketed and not ChatAnnouncements.isStolen then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
                            -- reset variables that control looted, or at least LUIE_callLater them
                        elseif ChatAnnouncements.isPickpocketed then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePickpocket
                        elseif ChatAnnouncements.isStolen and not ChatAnnouncements.isPickpocketed then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSteal
                        else
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                        end
                        if Quests.ItemReceivedMessage[itemId] then
                            logPrefix = Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_BUNDLE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestBundle or Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_LOOT and ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot or Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_COMBINE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestCombine or Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_MIX and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestMix or Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_STEAL and ChatAnnouncements.SV.ContextMessages.CurrencyMessageSteal
                        end

                        -- Some quest items we want to limit the maximum possible quantity displayed when looted (for weird item swapping) so replace the actual quantity with this value.
                        if Quests.QuestItemMaxQuantityAdd[itemId] then
                            countChange = Quests.QuestItemMaxQuantityAdd[itemId]
                        end
                        local quantity = countChange > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. countChange .. "|r") or ""

                        formattedMessageP1 = ("|r" .. formattedIcon .. itemLink .. quantity .. "|c" .. color)
                        -- Message for items being merged.
                        if Quests.QuestItemMerge[itemId] then
                            local line = ""
                            for i = 1, #Quests.QuestItemMerge[itemId] do
                                local comma
                                if #Quests.QuestItemMerge[itemId] > 2 then
                                    comma = i == #Quests.QuestItemMerge[itemId] and ", and " or i > 1 and ", " or ""
                                else
                                    comma = i > 1 and " and " or ""
                                end
                                local icon2 = GetQuestItemIcon(Quests.QuestItemMerge[itemId][i])
                                local formattedIcon1 = (ChatAnnouncements.SV.Inventory.LootIcons and icon2 and icon2 ~= "") and ("|t16:16:" .. icon2 .. "|t ") or ""
                                local usedId = Quests.QuestItemMerge[itemId][i]
                                local usedLink = ""
                                if ChatAnnouncements.SV.BracketOptionItem == 1 then
                                    usedLink = string_format("|H0:quest_item:" .. usedId .. "|h|h")
                                else
                                    usedLink = string_format("|H1:quest_item:" .. usedId .. "|h|h")
                                end
                                line = (line .. comma .. "|r" .. formattedIcon1 .. usedLink .. quantity .. "|c" .. color)
                            end

                            formattedMessageP2 = string_format(logPrefix, line, formattedMessageP1)
                            -- Or if we don't have a merged message just use the normal one
                        else
                            formattedMessageP2 = string_format(logPrefix, formattedMessageP1)
                        end

                        if ChatAnnouncements.SV.Inventory.LootTotal and total > 1 then
                            totalString = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        else
                            totalString = ""
                        end

                        finalMessage = string_format("|c%s%s|r%s", color, formattedMessageP2, totalString)

                        eventManager:UnregisterForUpdate(moduleName .. "Printer")
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                        {
                            message = finalMessage,
                            messageType = "QUEST_LOOT_ADD",
                            itemId = itemId
                        }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages)
                    end
                end

                if Quests.QuestItemModifyOnAdd[itemId] then
                    Quests.QuestItemModifyOnAdd[itemId]()
                end
            end
        end

        -- If count changed, update it
        if countChange then
            ChatAnnouncements.questItemIndex[itemId].stack = newValue
            ChatAnnouncements.questItemIndex[itemId].counter = 0
            -- d("New Stack Value = " .. ChatAnnouncements.questItemIndex[itemId].stack)
            if ChatAnnouncements.questItemIndex[itemId].stack < 1 then
                ChatAnnouncements.questItemIndex[itemId] = nil
                -- d("Item reached 0 or below stacks, removing")
            end
        end
    end

    eventManager:UnregisterForUpdate(moduleName .. "QuestItemUpdater")
end

--- - **EVENT_LOOT_RECEIVED **
---
---
--- @param eventId integer
--- @param receivedBy string
--- @param itemName string
--- @param quantity integer
--- @param soundCategory ItemUISoundCategory
--- @param lootType LootItemType
--- @param lootedBySelf boolean
--- @param isPickpocketLoot boolean
--- @param questItemIcon string
--- @param itemId integer
--- @param isStolen boolean
function ChatAnnouncements.OnLootReceived(eventId, receivedBy, itemName, quantity, soundCategory, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
    local itemLink = itemName

    -- if LUIE.IsDevDebugEnabled() then
    --     local traceback = "Loot Received:\n" ..
    --         "--> eventCode: " .. tostring(eventId) .. "\n" ..
    --         "--> receivedBy: " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, receivedBy) .. "\n" ..
    --         "--> itemLink: " .. tostring(itemLink) .. "\n" ..
    --         "--> quantity: " .. tostring(quantity) .. "\n" ..
    --         "--> itemSound: " .. tostring(soundCategory) .. "\n" ..
    --         "--> lootType: " .. tostring(lootType) .. "\n" ..
    --         "--> lootedBySelf: " .. tostring(lootedBySelf) .. "\n" ..
    --         "--> isPickpocketLoot: " .. tostring(isPickpocketLoot) .. "\n" ..
    --         "--> questItemIcon: " .. tostring(questItemIcon) .. "\n" ..
    --         "--> itemId: " .. tostring(itemId) .. "\n" ..
    --         "--> isStolen: " .. tostring(isStolen)
    --     LUIE:Log("Debug",traceback)
    -- end

    -- If the player loots an item
    if not isPickpocketLoot and lootedBySelf then
        ChatAnnouncements.isLooted = true

        local function ResetIsLooted()
            ChatAnnouncements.isLooted = false
            eventManager:UnregisterForUpdate(moduleName .. "ResetLooted")
        end
        eventManager:UnregisterForUpdate(moduleName .. "ResetLooted")
        eventManager:RegisterForUpdate(moduleName .. "ResetLooted", 150, ResetIsLooted)
    end

    -- If the player pickpockets an item
    if isPickpocketLoot and lootedBySelf then
        ChatAnnouncements.isPickpocketed = true

        local function ResetIsPickpocketed()
            ChatAnnouncements.isPickpocketed = false
            eventManager:UnregisterForUpdate(moduleName .. "ResetPickpocket")
        end
        eventManager:UnregisterForUpdate(moduleName .. "ResetPickpocket")
        eventManager:RegisterForUpdate(moduleName .. "ResetPickpocket", 150, ResetIsPickpocketed)
    end

    -- Return right now if we don't have group loot set to display
    if not ChatAnnouncements.SV.Inventory.LootGroup then
        return
    end

    -- Group loot handling
    if not lootedBySelf then
        local itemType = GetItemLinkItemType(itemLink)
        -- Check filter and if this item isn't included bail out now
        if not ChatAnnouncements.ItemFilter(itemType, itemId, itemLink, true) then
            return
        end

        local icon = GetItemLinkIcon(itemLink)
        local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
        local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageGroup

        local formattedItemLink
        if ChatAnnouncements.SV.BracketOptionItem == 1 then
            formattedItemLink = itemLink
        else
            formattedItemLink = StringOnlyGSUB(itemLink, "^|H0", "|H1", 1)
        end

        local formatName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, receivedBy)

        local recipient
        if ChatAnnouncements.groupLootIndex[formatName] then
            recipient = ZO_SELECTED_TEXT:Colorize(ChatAnnouncements.ResolveNameLink(ChatAnnouncements.groupLootIndex[formatName].characterName, ChatAnnouncements.groupLootIndex[formatName].displayName))
        else
            local nameLink
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(formatName, nil, CHARACTER_LINK_TYPE, formatName)
            else
                nameLink = ZO_LinkHandler_CreateLink(formatName, nil, CHARACTER_LINK_TYPE, formatName)
            end
            recipient = ZO_SELECTED_TEXT:Colorize(nameLink)
        end
        ChatAnnouncements.ItemPrinter(
            icon,
            quantity,
            itemType,
            itemId,
            formattedItemLink,
            recipient,
            logPrefix,
            gainOrLoss,
            false,
            true,
            nil,
            nil
        )
    end
end

--- - **EVENT_INVENTORY_ITEM_USED **
---
--- @param eventId integer
--- @param itemSoundCategory ItemUISoundCategory
function ChatAnnouncements.OnInventoryItemUsed(eventId, itemSoundCategory)
    local function ResetCombinedRecipe()
        ChatAnnouncements.combinedRecipe = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetCombinedRecipe")
    end

    -- Trophy items used for recipe combination seem to have no itemSoundCategory.
    if itemSoundCategory == 0 then
        ChatAnnouncements.combinedRecipe = true
        eventManager:UnregisterForUpdate(moduleName .. "ResetCombinedRecipe")
        eventManager:RegisterForUpdate(moduleName .. "ResetCombinedRecipe", 150, ResetCombinedRecipe)
    end
end

-- If filter is true, we run the item through this function to determine if we should display it. Filter only gets set to true for group loot and relevant loot functions. Mail, trade, stores, etc don't apply the filter.
function ChatAnnouncements.ItemFilter(itemType, itemId, itemLink, groupLoot)
    if ChatAnnouncements.SV.Inventory.LootBlacklist and ChatAnnouncements.blacklistIDs[itemId] or (ChatAnnouncements.SV.Inventory.LootLogOverride and LootLog) then
        return false
    end

    local specializedItemType = select(2, GetItemLinkItemType(itemLink))
    local itemQuality = GetItemLinkFunctionalQuality(itemLink)
    local itemIsSet = GetItemLinkSetInfo(itemLink, false)

    local itemIsKeyFragment = (itemType == ITEMTYPE_TROPHY) and (specializedItemType == SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT)
    local itemIsSpecial = (itemType == ITEMTYPE_TROPHY and not itemIsKeyFragment) or (itemType == ITEMTYPE_COLLECTIBLE) or IsItemLinkConsumable(itemLink)

    if ChatAnnouncements.SV.Inventory.LootOnlyNotable or groupLoot then
        -- Notable items are: any set items, any purple+ items, blue+ special items (e.g., treasure maps)
        if itemIsSet or (itemQuality >= ITEM_FUNCTIONAL_QUALITY_ARCANE and itemIsSpecial) or (itemQuality >= ITEM_FUNCTIONAL_QUALITY_ARTIFACT and not itemIsKeyFragment) or (itemType == ITEMTYPE_COSTUME) or (itemType == ITEMTYPE_DISGUISE) or ChatAnnouncements.notableIDs[itemId] then
            return true
        end
    elseif ChatAnnouncements.SV.Inventory.LootNotTrash and (itemQuality == ITEM_FUNCTIONAL_QUALITY_TRASH) and not ((itemType == ITEMTYPE_ARMOR) or (itemType == ITEMTYPE_COSTUME) or (itemType == ITEMTYPE_DISGUISE)) then
        return false
    else
        return true
    end
end

local function CheckLibLazyCraftingActive()
    -- If an addon is installed that uses LibLazyCrafting, we need to replace the messages with used and crafted.
    if LibLazyCrafting then
        if LibLazyCrafting:IsPerformingCraftProcess() then
            return true
        end
    else
        return false
    end
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
--- @param groupLoot boolean
--- @param alwaysFirst boolean
--- @param delay boolean
function ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, filter, groupLoot, alwaysFirst, delay)
    if filter then
        -- If filter returns false then bail out right now, we're not displaying this item.
        if not ChatAnnouncements.ItemFilter(itemType, itemId, itemLink, false) then
            return
        end
    end

    -- Bail out if any key information is missing for some reason.
    if icon == nil or stack == nil or itemLink == nil then
        return
    end

    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon ~= "") and zo_strformat("<<1>> ", zo_iconFormat(icon, 16, 16)) or ""
    local color
    if gainOrLoss == 1 then
        color = ChatAnnouncements.Colors.CurrencyUpColorize:ToHex()
    elseif gainOrLoss == 2 then
        color = ChatAnnouncements.Colors.CurrencyDownColorize:ToHex()
        -- 3 = Gain no color, 4 = Loss no color (differentiation only exists for Crafting Strings)
    elseif gainOrLoss == 3 or gainOrLoss == 4 then
        color = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
        -- Fallback if gainOrLoss is nil or an invalid number for some reason
    else
        color = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
    end

    local formattedRecipient
    local formattedQuantity
    local formattedTrait
    local formattedArmorType
    local formattedStyle

    if receivedBy == "" or receivedBy == nil or receivedBy == "LUIE_RECEIVE_CRAFT" or receivedBy == "LUIE_INVENTORY_UPDATE_DISGUISE" then
        -- Don't display yourself
        formattedRecipient = ""
    else
        formattedRecipient = receivedBy
    end

    -- Error handling
    if not formattedRecipient then
        formattedRecipient = ""
    end

    if stack > 1 then
        formattedQuantity = string_format(" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "%d|r", stack)
    else
        formattedQuantity = ""
    end

    local armorType = GetItemLinkArmorType(itemLink) -- Get Armor Type of item
    formattedArmorType = (ChatAnnouncements.SV.Inventory.LootShowArmorType and armorType ~= ARMORTYPE_NONE and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail) and string_format(" |cFFFFFF(%s)|r", GetString("SI_ARMORTYPE", armorType)) or ""

    local traitType = GetItemLinkTraitInfo(itemLink) -- Get Trait type of item
    formattedTrait = (ChatAnnouncements.SV.Inventory.LootShowTrait and traitType ~= ITEM_TRAIT_TYPE_NONE and itemType ~= ITEMTYPE_ARMOR_TRAIT and itemType ~= ITEMTYPE_WEAPON_TRAIT and itemType ~= ITEMTYPE_JEWELRY_TRAIT and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail) and string_format(" |cFFFFFF(%s)|r", GetString("SI_ITEMTRAITTYPE", traitType)) or ""

    local styleType = GetItemLinkItemStyle(itemLink) -- Get Style of the item
    local unformattedStyle = zo_strformat("<<1>>", GetItemStyleName(styleType))
    formattedStyle = (ChatAnnouncements.SV.Inventory.LootShowStyle and styleType ~= 0 and styleType ~= ITEMSTYLE_UNIQUE and styleType ~= ITEMSTYLE_UNIVERSAL and itemType ~= ITEMTYPE_STYLE_MATERIAL and itemType ~= ITEMTYPE_GLYPH_ARMOR and itemType ~= ITEMTYPE_GLYPH_JEWELRY and itemType ~= ITEMTYPE_GLYPH_WEAPON and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail) and string_format(" |cFFFFFF(%s)|r", unformattedStyle) or ""

    local formattedTotal = ""
    if ChatAnnouncements.SV.Inventory.LootTotal and receivedBy ~= "LUIE_INVENTORY_UPDATE_DISGUISE" and receivedBy ~= "LUIE_RECEIVE_CRAFT" and not groupLoot and (logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnRecipe and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnMotif and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnStyle) then
        local total = getItemLinkStackCount(itemLink)
        if total >= 1 then
            formattedTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    local itemString = string_format("%s%s%s%s%s%s", formattedIcon, itemLink, formattedQuantity, formattedArmorType, formattedTrait, formattedStyle)

    local delayTimer = 50
    local messageType = alwaysFirst and "CONTAINER" or "LOOT"

    -- Printer function, separate handling for listed entires (from crafting) or simple function that sends a message over to the printer.
    if receivedBy == "LUIE_RECEIVE_CRAFT" and (gainOrLoss == 1 or gainOrLoss == 3) and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail then
        local itemString2 = itemString

        if ChatAnnouncements.itemStringGain ~= "" then
            ChatAnnouncements.itemStringGain = string_format("%s|c%s,|r %s", ChatAnnouncements.itemStringGain, color, itemString2)
        end
        if ChatAnnouncements.itemStringGain == "" then
            ChatAnnouncements.itemStringGain = itemString
        end

        ChatAnnouncements.itemCounterGainTracker = ChatAnnouncements.itemCounterGainTracker + 1
        if ChatAnnouncements.itemCounterGainTracker > 50 then
            ChatAnnouncements.itemStringGain = string_format("|c%s too many items to display|r", color)
        end

        if ChatAnnouncements.itemCounterGain == 0 then
            ChatAnnouncements.itemCounterGain = ChatAnnouncements.QueuedMessagesCounter
        end
        if ChatAnnouncements.QueuedMessagesCounter - 1 == ChatAnnouncements.itemCounterGain then
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.itemCounterGain
        end
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.itemCounterGain] =
        {
            message = ChatAnnouncements.itemStringGain,
            messageType = messageType,
            formattedRecipient = formattedRecipient,
            color = color,
            logPrefix = logPrefix,
            totalString = "",
            groupLoot = groupLoot,
        }
        eventManager:RegisterForUpdate(moduleName .. "Printer", delayTimer, ChatAnnouncements.PrintQueuedMessages)
    elseif receivedBy == "LUIE_RECEIVE_CRAFT" and (gainOrLoss == 2 or gainOrLoss == 4) and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail then
        local itemString2 = itemString
        if ChatAnnouncements.itemStringLoss ~= "" then
            ChatAnnouncements.itemStringLoss = string_format("%s|c%s,|r %s", ChatAnnouncements.itemStringLoss, color, itemString2)
        end
        if ChatAnnouncements.itemStringLoss == "" then
            ChatAnnouncements.itemStringLoss = itemString
        end

        ChatAnnouncements.itemCounterLossTracker = ChatAnnouncements.itemCounterLossTracker + 1
        if ChatAnnouncements.itemCounterLossTracker > 50 then
            ChatAnnouncements.itemStringLoss = string_format("|c%s too many items to display|r", color)
        end

        if ChatAnnouncements.itemCounterLoss == 0 then
            ChatAnnouncements.itemCounterLoss = ChatAnnouncements.QueuedMessagesCounter
        end
        if ChatAnnouncements.QueuedMessagesCounter - 1 == ChatAnnouncements.itemCounterLoss then
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.itemCounterLoss
        end
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.itemCounterLoss] =
        {
            message = ChatAnnouncements.itemStringLoss,
            messageType = messageType,
            formattedRecipient = formattedRecipient,
            color = color,
            logPrefix = logPrefix,
            totalString = "",
            groupLoot = groupLoot,
        }
        eventManager:RegisterForUpdate(moduleName .. "Printer", delayTimer, ChatAnnouncements.PrintQueuedMessages)
    else
        local totalString = formattedTotal
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = itemString,
            messageType = messageType,
            formattedRecipient = formattedRecipient,
            color = color,
            logPrefix = logPrefix,
            totalString = totalString,
            groupLoot = groupLoot,
        }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        if delay then
            delayTimer = 25
            eventManager:UnregisterForUpdate(moduleName .. "Printer")
        end
        eventManager:RegisterForUpdate(moduleName .. "Printer", delayTimer, ChatAnnouncements.PrintQueuedMessages)
    end
end

-- Simple function combines our strings or modifies the prefix if RECEIEVED instead of looted
---
--- @param message string
--- @param formattedRecipient string
--- @param color string
--- @param logPrefix string
--- @param totalString string
--- @param groupLoot boolean
function ChatAnnouncements.ResolveItemMessage(message, formattedRecipient, color, logPrefix, totalString, groupLoot)
    -- Conditions for looted/quest item rewards to adjust string prefix.
    if logPrefix == "" then
        if ChatAnnouncements.isLooted and not ChatAnnouncements.itemReceivedIsQuestReward and not ChatAnnouncements.isPickpocketed and not ChatAnnouncements.isStolen then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
            -- reset variables that control looted, or at least ZO_CallLater them
        elseif ChatAnnouncements.isPickpocketed then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePickpocket
        elseif ChatAnnouncements.isStolen and not ChatAnnouncements.isPickpocketed then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSteal
        else
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
        end
    end

    local formattedMessageP1
    local formattedMessageP2

    -- Handle non group loot messages
    if not groupLoot then
        -- Adds additional string for previous variant of an item when an item is upgraded.
        if logPrefix == ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade and ChatAnnouncements.oldItem ~= nil and (ChatAnnouncements.oldItem.itemLink ~= "" and ChatAnnouncements.oldItem.itemLink ~= nil) and ChatAnnouncements.oldItem.icon ~= nil then
            local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and ChatAnnouncements.oldItem.icon ~= "") and zo_strformat("<<1>> ", zo_iconFormat(ChatAnnouncements.oldItem.icon, 16, 16)) or ""
            local formattedMessageUpgrade = ("|r" .. formattedIcon .. ChatAnnouncements.oldItem.itemLink .. "|c" .. color)
            formattedMessageP1 = ("|r" .. message .. "|c" .. color)
            formattedMessageP2 = string_format(logPrefix, formattedMessageUpgrade, formattedMessageP1)
            ChatAnnouncements.oldItem = {}
        else
            formattedMessageP1 = ("|r" .. message .. "|c" .. color)
            if formattedRecipient == "" then
                formattedMessageP2 = string_format(logPrefix, formattedMessageP1, "")
            else
                local recipient = ("|r" .. formattedRecipient .. "|c" .. color)
                formattedMessageP2 = string_format(logPrefix, formattedMessageP1, recipient)
            end
        end
        -- Handle group loot messages
    else
        formattedMessageP1 = ("|r" .. message .. "|c" .. color)
        local recipient = ("|r" .. formattedRecipient .. "|c" .. color)
        formattedMessageP2 = string_format(logPrefix, recipient, formattedMessageP1)
    end

    local finalMessage = string_format("|c%s%s|r%s", color, formattedMessageP2, totalString)

    -- LUIE.SV.DummyDumpString = finalMessage

    printToChat(finalMessage)

    -- Reset variables for crafted item counter
    ChatAnnouncements.itemCounterGain = 0
    ChatAnnouncements.itemCounterGainTracker = 0
    ChatAnnouncements.itemCounterLoss = 0
    ChatAnnouncements.itemCounterLossTracker = 0
    ChatAnnouncements.itemStringGain = ""
    ChatAnnouncements.itemStringLoss = ""

    -- "You loot %s."
    -- "You receive %s."
end

-- Simple PostHook into ZOS crafting mode functions, based off MultiCraft, thanks Ayantir!
function ChatAnnouncements.CraftModeOverrides()
    -- Get SMITHING mode
    ChatAnnouncements.smithing.GetMode = LUIE.GetSmithingMode

    -- Get ENCHANTING mode
    ChatAnnouncements.enchanting.GetMode = LUIE.GetEnchantingMode

    -- NOTE: Alchemy and provisioning don't matter, as the only options are to craft and use materials.

    -- Crafting Mode Syntax (Enchanting - Item Gain)
    ChatAnnouncements.enchant_prefix_pos =
    {
        [1] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft,
        [2] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive,
        [3] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft,
    }

    -- Crafting Mode Syntax (Enchanting - Item Loss)
    ChatAnnouncements.enchant_prefix_neg =
    {
        [1] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse,
        [2] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExtract,
        [3] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse,
    }

    -- Crafting Mode Syntax (Blacksmithing - Item Gain)
    ChatAnnouncements.smithing_prefix_pos =
    {
        [1] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive,
        [2] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft,
        [3] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive,
        [4] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade,
        [5] = "",
        [6] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft,
    }

    -- Crafting Mode Syntax (Blacksmithing - Item Loss)
    ChatAnnouncements.smithing_prefix_neg =
    {
        [1] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRefine,
        [2] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse,
        [3] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeconstruct,
        [4] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail,
        [5] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageResearch,
        [6] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse,
    }
end

--- @class DelayedItemPool
--- @field icon string
--- @field stack integer
--- @field itemType ItemType
--- @field itemId integer
--- @field itemLink string
--- @field receivedBy string
--- @field logPrefix string
--- @field gainOrLoss integer
--- @field filter boolean
--- @field groupLoot boolean
--- @field alwaysFirst boolean
--- @field delay boolean

--- @alias delayedItemPool_itemTable { [integer] : DelayedItemPool }

--- @type delayedItemPool_itemTable
local delayedItemPool = {}    -- Store items we are counting up when the player loots multiple bodies at once to print combined counts for any duplicate items
--- @type delayedItemPool_itemTable
local delayedItemPoolOut = {} -- Stacks for outbound delayed item pool

---
--- @param icon string
--- @param stack integer
--- @param itemType ItemType
--- @param itemId integer
--- @param itemLink string
--- @param receivedBy string
--- @param logPrefix string
--- @param gainOrLoss integer
--- @param filter boolean
--- @param groupLoot boolean
--- @param alwaysFirst boolean
--- @param delay boolean
function ChatAnnouncements.ItemCounterDelay(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, filter, groupLoot, alwaysFirst, delay)
    -- Return if we have an invalid itemId or stack
    if itemId == 0 or not stack then
        if LUIE.IsDevDebugEnabled() then
            LUIE:Log("Debug", "Item counter returned invalid items")
        end
        return
    end

    -- Add stack counts if item exists in pool, with nil check
    if delayedItemPool[itemId] and delayedItemPool[itemId].stack then
        stack = delayedItemPool[itemId].stack + stack
    end

    -- Save parameters to delayed item pool
    delayedItemPool[itemId] =
    {
        icon = icon,
        stack = stack or 0, -- Provide default value if nil
        itemType = itemType,
        itemId = itemId,
        itemLink = itemLink,
        receivedBy = receivedBy,
        logPrefix = logPrefix,
        gainOrLoss = gainOrLoss,
        filter = filter,
        groupLoot = groupLoot,
        alwaysFirst = alwaysFirst,
        delay = delay
    } -- Save relevant parameters

    -- Pass along all values to SendDelayedItems()
    eventManager:UnregisterForUpdate(moduleName .. "SendDelayedItems")
    eventManager:RegisterForUpdate(moduleName .. "SendDelayedItems", 25, ChatAnnouncements.SendDelayedItems)
end

function ChatAnnouncements.SendDelayedItems()
    for id, data in pairs(delayedItemPool) do
        if id then
            ChatAnnouncements.ItemPrinter(
                data.icon,
                data.stack,
                data.itemType,
                data.itemId,
                data.itemLink,
                data.receivedBy,
                data.logPrefix,
                data.gainOrLoss,
                data.filter,
                data.groupLoot,
                data.alwaysFirst,
                data.delay
            )
        end
    end
    -- Clear pool
    delayedItemPool = {}
end

---
--- @param icon string
--- @param stack integer
--- @param itemType ItemType
--- @param itemId integer
--- @param itemLink string
--- @param receivedBy string
--- @param logPrefix string
--- @param gainOrLoss integer
--- @param filter boolean
--- @param groupLoot boolean
--- @param alwaysFirst boolean
--- @param delay boolean
function ChatAnnouncements.ItemCounterDelayOut(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, filter, groupLoot, alwaysFirst, delay)
    if delayedItemPoolOut[itemId] then
        stack = delayedItemPoolOut[itemId].stack + stack -- Add stack count first, only if item already exists.
    end
    delayedItemPoolOut[itemId] =
    {
        icon = icon,
        stack = stack or 0, -- Provide default value if nil
        itemType = itemType,
        itemId = itemId,
        itemLink = itemLink,
        receivedBy = receivedBy,
        logPrefix = logPrefix,
        gainOrLoss = gainOrLoss,
        filter = filter,
        groupLoot = groupLoot,
        alwaysFirst = alwaysFirst,
        delay = delay
    } -- Save relevant parameters

    -- Pass along all values to SendDelayedItems()
    eventManager:UnregisterForUpdate(moduleName .. "SendDelayedItemsOut")
    eventManager:RegisterForUpdate(moduleName .. "SendDelayedItemsOut", 25, ChatAnnouncements.SendDelayedItemsOut)
end

function ChatAnnouncements.SendDelayedItemsOut()
    for id, data in pairs(delayedItemPoolOut) do
        if id then
            ChatAnnouncements.ItemPrinter(
                data.icon,
                data.stack,
                data.itemType,
                data.itemId,
                data.itemLink,
                data.receivedBy,
                data.logPrefix,
                data.gainOrLoss,
                data.filter,
                data.groupLoot,
                data.alwaysFirst,
                data.delay
            )
        end
    end
    -- Clear pool
    delayedItemPoolOut = {}
end

local crownRidingIds =
{
    [64700] = true,  -- Crown Lesson: Riding Speed
    [64701] = true,  -- Crown Lesson: Riding Stamina
    [64702] = true,  -- Crown Lesson: Riding Capacity
    [135115] = true, -- Crown Lesson: Riding Speed
    [135116] = true, -- Crown Lesson: Riding Stamina
    [135117] = true, -- Crown Lesson: Riding Capacity
}

--- Runs on - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
---
--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function ChatAnnouncements.InventoryUpdate(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update:\n" ..
    --         "--> eventId: " .. tostring(eventId) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotIndex: " .. tostring(slotIndex) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange) .. "\n" ..
    --         "--> triggeredByCharacterName: " .. tostring(triggeredByCharacterName) .. "\n" ..
    --         "--> triggeredByDisplayName: " .. tostring(triggeredByDisplayName) .. "\n" ..
    --         "--> isLastUpdateForMessage: " .. tostring(isLastUpdateForMessage) .. "\n" ..
    --         "--> bonusDropSource: " .. tostring(bonusDropSource)
    --     LUIE:Log("Debug",traceback)
    -- end

    -- End right now if this is any other reason (durability loss, etc)
    if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then
        return
    end

    if IsItemStolen(bagId, slotIndex) then
        ChatAnnouncements.isStolen = true
        local function ResetIsStolen()
            ChatAnnouncements.isStolen = false
            eventManager:UnregisterForUpdate(moduleName .. "ResetStolen")
        end
        eventManager:UnregisterForUpdate(moduleName .. "ResetStolen")
        eventManager:RegisterForUpdate(moduleName .. "ResetStolen", 150, ResetIsStolen)
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
        if not ChatAnnouncements.equippedStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.equippedStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            if ChatAnnouncements.SV.Inventory.LootShowDisguise and slotIndex == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
                gainOrLoss = 3
                receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDisguiseEquip
                ChatAnnouncements.ItemPrinter(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
            end
            -- EXISTING ITEM
        elseif ChatAnnouncements.equippedStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.equippedStacks[slotIndex].icon
                stack = ChatAnnouncements.equippedStacks[slotIndex].stack
                itemType = ChatAnnouncements.equippedStacks[slotIndex].itemType
                itemId = ChatAnnouncements.equippedStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.equippedStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT REMAINED THE SAME (GEAR SWAPPED)
            if stackCountChange == 0 then
                if ChatAnnouncements.SV.Inventory.LootShowDisguise and slotIndex == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
                    gainOrLoss = 3
                    receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDisguiseEquip
                    ChatAnnouncements.ItemPrinter(
                        icon,
                        stackCountChange,
                        itemType,
                        itemId,
                        itemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        nil,
                        nil
                    )
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(
                        icon,
                        change,
                        itemType,
                        itemId,
                        itemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        nil,
                        nil
                    )
                end
                if not ChatAnnouncements.itemWasDestroyed then
                    if ChatAnnouncements.SV.Inventory.LootShowDisguise and slotIndex == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
                        if IsUnitInCombat("player") then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDisguiseDestroy
                            receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        else
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDisguiseRemove
                            receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                            gainOrLoss = 3
                        end
                        ChatAnnouncements.ItemPrinter(
                            icon,
                            change,
                            itemType,
                            itemId,
                            itemLink,
                            receivedBy,
                            logPrefix,
                            gainOrLoss,
                            false,
                            nil,
                            nil,
                            nil
                        )
                    elseif not ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.removableIDs[itemId] and ChatAnnouncements.SV.Inventory.LootShowRemove then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRemove
                        ChatAnnouncements.ItemPrinter(
                            icon,
                            change,
                            itemType,
                            itemId,
                            itemLink,
                            receivedBy,
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

            if removed then
                if ChatAnnouncements.equippedStacks[slotIndex] then
                    ChatAnnouncements.equippedStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.equippedStacks[slotIndex] =
                {
                    icon = icon,
                    stack = stack,
                    itemId = itemId,
                    itemType = itemType,
                    itemLink = itemLink
                }
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
        if not ChatAnnouncements.inventoryStacks[slotIndex] then
            -- Flag stack split as true - this will occur when a stack of items is split into multiple stacks.
            if not isNewItem then
                ChatAnnouncements.stackSplit = true
                eventManager:RegisterForUpdate(moduleName .. "StackTracker", 50, ChatAnnouncements.ResetStackSplit)
            end
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.inventoryStacks[slotIndex] =
            {
                icon = icon,
                stack = stack,
                itemId = itemId,
                itemType = itemType,
                itemLink = itemLink
            }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            local mailSender = ""
            if ChatAnnouncements.inMail then
                -- Get the correct sender from the queue for this item
                mailSender = ChatAnnouncements.Mail.GetNextSender() or ""
                logPrefix = mailSender ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
            else
                logPrefix = ""
            end
            if ChatAnnouncements.weAreInADig then
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExcavate
            end
            if ChatAnnouncements.packSiege and itemType == ITEMTYPE_SIEGE then
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageStow
            end
            if not ChatAnnouncements.weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not ChatAnnouncements.inTrade and not ChatAnnouncements.inMail then
                ChatAnnouncements.ItemCounterDelay(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    true,
                    nil,
                    false,
                    true
                )
            end
            if ChatAnnouncements.inMail and isNewItem then
                ChatAnnouncements.ItemCounterDelay(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    mailSender,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
            end
            -- EXISTING ITEM
        elseif ChatAnnouncements.inventoryStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            -- For item removal, we save whatever the currently indexed item is here.
            local removedIcon = ChatAnnouncements.inventoryStacks[slotIndex].icon
            local removedItemType = ChatAnnouncements.inventoryStacks[slotIndex].itemType
            local removedItemId = ChatAnnouncements.inventoryStacks[slotIndex].itemId
            local removedItemLink = ChatAnnouncements.inventoryStacks[slotIndex].itemLink
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.inventoryStacks[slotIndex].icon
                stack = ChatAnnouncements.inventoryStacks[slotIndex].stack
                itemType = ChatAnnouncements.inventoryStacks[slotIndex].itemType
                itemId = ChatAnnouncements.inventoryStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.inventoryStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                -- Flag stack split as true - this will occur when two items are stacked together (dragged over each other)
                if not isNewItem then
                    ChatAnnouncements.stackSplit = true
                    eventManager:RegisterForUpdate(moduleName .. "StackTracker", 50, ChatAnnouncements.ResetStackSplit)
                end

                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                local mailSender = ""
                if ChatAnnouncements.inMail then
                    logPrefix = ChatAnnouncements.Mail.target ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
                else
                    logPrefix = ""
                end
                if ChatAnnouncements.weAreInADig then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExcavate
                end
                if ChatAnnouncements.packSiege and itemType == ITEMTYPE_SIEGE then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageStow
                end
                if not ChatAnnouncements.weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not ChatAnnouncements.inTrade and not ChatAnnouncements.inMail then
                    ChatAnnouncements.ItemCounterDelay(
                        icon,
                        stackCountChange,
                        itemType,
                        itemId,
                        itemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        true,
                        nil,
                        false,
                        true
                    )
                end
                if ChatAnnouncements.inMail and isNewItem then
                    -- Get the correct sender from the queue for new items
                    mailSender = ChatAnnouncements.Mail.GetNextSender() or ""
                    logPrefix = mailSender ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
                    ChatAnnouncements.ItemCounterDelay(
                        icon,
                        stackCountChange,
                        itemType,
                        itemId,
                        itemLink,
                        mailSender,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        nil,
                        nil
                    )
                end
                -- Handle stacked items from mail (they still need to consume from queue)
                if ChatAnnouncements.inMail and not isNewItem and stackCountChange > 0 then
                    -- Consume from queue for stacked items too
                    mailSender = ChatAnnouncements.Mail.GetNextSender() or ""
                    logPrefix = mailSender ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
                    if mailSender ~= "" then
                        ChatAnnouncements.ItemCounterDelay(
                            icon,
                            stackCountChange,
                            itemType,
                            itemId,
                            itemLink,
                            mailSender,
                            logPrefix,
                            gainOrLoss,
                            false,
                            nil,
                            nil,
                            nil
                        )
                    end
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                -- Check Destroyed first
                if ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(
                        removedIcon,
                        change,
                        removedItemType,
                        removedItemId,
                        removedItemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        nil,
                        nil
                    )
                    -- Check Lockpick next
                elseif ChatAnnouncements.SV.Inventory.LootShowLockpick and ChatAnnouncements.lockpickBroken then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLockpick
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    ChatAnnouncements.ItemPrinter(
                        removedIcon,
                        change,
                        removedItemType,
                        removedItemId,
                        removedItemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        nil,
                        nil
                    )
                    -- Check container is emptied next
                elseif ChatAnnouncements.SV.Inventory.LootShowContainer and (removedItemType == ITEMTYPE_CONTAINER or removedItemType == ITEMTYPE_CONTAINER_CURRENCY) then
                    -- Don't display a message if the specialized item type is a "Container Style Page"
                    local _, specializedType = GetItemLinkItemType(itemLink)
                    if specializedType ~= SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageContainer
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        ChatAnnouncements.ItemPrinter(
                            removedIcon,
                            change,
                            removedItemType,
                            removedItemId,
                            removedItemLink,
                            receivedBy,
                            logPrefix,
                            gainOrLoss,
                            false,
                            nil,
                            true,
                            nil
                        )
                    end
                    -- Check to see if the item was removed in dialogue and Quest Item turnin is on.
                elseif ChatAnnouncements.talkingToNPC and not ChatAnnouncements.weAreInAStore and ChatAnnouncements.SV.Inventory.LootShowTurnIn then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestTurnIn
                    LUIE_callLater(function ()
                                       if ChatAnnouncements.stackSplit == false then
                                           ChatAnnouncements.ItemCounterDelay(
                                               removedIcon,
                                               change,
                                               removedItemType,
                                               removedItemId,
                                               removedItemLink,
                                               receivedBy,
                                               logPrefix,
                                               gainOrLoss,
                                               false,
                                               false,
                                               true,
                                               false
                                           )
                                           eventManager:UnregisterForUpdate(moduleName .. "Printer")
                                           eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                                       end
                                   end, 25)
                elseif ChatAnnouncements.weAreInAGuildStore and ChatAnnouncements.SV.Inventory.LootShowList then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageList
                    ChatAnnouncements.savedItem = { icon = removedIcon, stack = change, itemLink = removedItemLink }
                    -- Check to see if the item was used
                elseif not ChatAnnouncements.itemWasDestroyed and not ChatAnnouncements.talkingToNPC and not ChatAnnouncements.inTrade and not ChatAnnouncements.inMail then
                    local flag -- When set to true we deliver a message on a LUIE_callLater
                    if ChatAnnouncements.SV.Inventory.LootShowUsePotion and removedItemType == ITEMTYPE_POTION then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePotion
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseFood and removedItemType == ITEMTYPE_FOOD then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFood
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseDrink and removedItemType == ITEMTYPE_DRINK then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDrink
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseRepairKit and (removedItemType == ITEMTYPE_TOOL or removedItemType == ITEMTYPE_CROWN_REPAIR or removedItemType == ITEMTYPE_AVA_REPAIR or removedItemType == ITEMTYPE_GROUP_REPAIR) then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseSoulGem and removedItemType == ITEMTYPE_SOUL_GEM then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseSiege and removedItemType == ITEMTYPE_SIEGE then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeploy
                        flag = true
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseFish and removedItemType == ITEMTYPE_FISH then
                        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
                        flag = true
                    end
                    -- If this is a Skill respec scroll, manually call an announcement for it if enabled (for some reason doesn't display an EVENT_DISPLAY_ANNOUNCEMENT on use anymore)
                    if removedItemType == ITEMTYPE_CROWN_ITEM and (itemId == 64524 or itemId == 135128) then
                        LUIE_callLater(function ()
                                           ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_SKILLS)
                                       end, 25)
                    end
                    -- If this is an Attribute respec scroll, manually call an announcement for it if enabled (we disable EVENT_DISPLAY_ANNOUNCEMENT for this to sync it better)
                    if removedItemType == ITEMTYPE_CROWN_ITEM and (itemId == 64523 or itemId == 135130) then
                        LUIE_callLater(function ()
                                           ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_ATTRIBUTES)
                                       end, 25)
                    end
                    if ChatAnnouncements.SV.Inventory.LootShowUseMisc and (removedItemType == ITEMTYPE_RECALL_STONE or removedItemType == ITEMTYPE_TROPHY or removedItemType == ITEMTYPE_MASTER_WRIT or removedItemType == ITEMTYPE_CROWN_ITEM) then
                        -- Check to make sure the items aren't riding lesson books.
                        if not crownRidingIds[removedItemId] then
                            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
                            flag = true
                        end
                    end
                    -- Learn Recipe
                    if ChatAnnouncements.SV.Inventory.LootShowRecipe and removedItemType == ITEMTYPE_RECIPE then
                        -- Show recipe message if a recipe is learned.
                        if not ChatAnnouncements.combinedRecipe then
                            gainOrLoss = 4
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnRecipe
                            flag = true
                            if ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
                                PlaySound(SOUNDS.RECIPE_LEARNED)
                            end
                        else
                            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
                            flag = true
                        end
                    end
                    -- Learn Motif
                    if ChatAnnouncements.SV.Inventory.LootShowMotif and removedItemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
                        gainOrLoss = 4
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnMotif
                        flag = true
                    end
                    -- Learn Style
                    if ChatAnnouncements.SV.Inventory.LootShowStylePage and removedItemType == ITEMTYPE_COLLECTIBLE then
                        -- Don't display a message if the specialized item type is not "Collectible Style Page"
                        local _, specializedType = GetItemLinkItemType(itemLink)
                        if specializedType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then
                            gainOrLoss = 4
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnStyle
                            flag = true
                        end
                    end
                    -- Learn Style (TODO: Check if needed since style pages were switched to ITEMTYPE_COLLECTIBLE)
                    if ChatAnnouncements.SV.Inventory.LootShowStylePage and removedItemType == ITEMTYPE_CONTAINER then
                        -- Don't display a message if the specialized item type is not "Container Style Page"
                        local _, specializedType = GetItemLinkItemType(itemLink)
                        if specializedType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then
                            gainOrLoss = 4
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnStyle
                            flag = true
                        end
                    end
                    -- If any of these options were flagged, run a callLater on a 50ms delay to make sure we didn't just split stacks.
                    if flag then
                        LUIE_callLater(function ()
                                           if ChatAnnouncements.stackSplit == false then
                                               ChatAnnouncements.ItemCounterDelay(
                                                   removedIcon,
                                                   change,
                                                   removedItemType,
                                                   removedItemId,
                                                   removedItemLink,
                                                   receivedBy,
                                                   logPrefix,
                                                   gainOrLoss,
                                                   false,
                                                   false,
                                                   true,
                                                   false
                                               )
                                               eventManager:UnregisterForUpdate(moduleName .. "Printer")
                                               eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                                           end
                                       end, 25)
                    end
                    -- For any leftover cases for items removed.
                elseif not ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.removableIDs[itemId] and ChatAnnouncements.SV.Inventory.LootShowRemove then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRemove
                    ChatAnnouncements.ItemPrinter(
                        removedIcon,
                        change,
                        removedItemType,
                        removedItemId,
                        removedItemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        nil,
                        nil
                    )
                end
            end

            if removed then
                if ChatAnnouncements.inventoryStacks[slotIndex] then
                    ChatAnnouncements.inventoryStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.inventoryStacks[slotIndex] =
                {
                    icon = icon,
                    tack = stack,
                    itemId = itemId,
                    itemType = itemType,
                    itemLink = itemLink
                }
            end
        end
    end

    if bagId == BAG_VIRTUAL then
        local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
        local logPrefix
        local mailSender = ""
        if ChatAnnouncements.inMail then
            -- Get the correct sender from the queue for this item
            mailSender = ChatAnnouncements.Mail.GetNextSender() or ""
            logPrefix = mailSender ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
        else
            logPrefix = ""
        end
        if ChatAnnouncements.weAreInADig then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExcavate
        end
        local itemLink = tostring(ChatAnnouncements.GetItemLinkFromItemId(slotIndex))
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotIndex
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)

        if not ChatAnnouncements.weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not ChatAnnouncements.inTrade and not ChatAnnouncements.inMail then
            ChatAnnouncements.ItemCounterDelay(
                icon,
                stackCountChange,
                itemType,
                itemId,
                itemLink,
                receivedBy,
                logPrefix,
                gainOrLoss,
                true,
                nil,
                false,
                true
            )
        end
        if ChatAnnouncements.inMail and isNewItem then
            ChatAnnouncements.ItemCounterDelay(
                icon,
                stackCountChange,
                itemType,
                itemId,
                itemLink,
                mailSender,
                logPrefix,
                gainOrLoss,
                false,
                nil,
                nil,
                nil
            )
        end
    end

    ChatAnnouncements.itemWasDestroyed = false
    ChatAnnouncements.lockpickBroken = false
end

--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
---
--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function ChatAnnouncements.InventoryUpdateCraft(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update Craft:\n" ..
    --         "--> eventId: " .. tostring(eventId) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotIndex: " .. tostring(slotIndex) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange) .. "\n" ..
    --         "--> triggeredByCharacterName: " .. tostring(triggeredByCharacterName) .. "\n" ..
    --         "--> triggeredByDisplayName: " .. tostring(triggeredByDisplayName) .. "\n" ..
    --         "--> isLastUpdateForMessage: " .. tostring(isLastUpdateForMessage) .. "\n" ..
    --         "--> bonusDropSource: " .. tostring(bonusDropSource)
    --     LUIE:Log("Debug",traceback)
    -- end
    -- End right now if this is any other reason (durability loss, etc)
    if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then
        return
    end

    local ResolveCraftingUsed = LUIE.ResolveCraftingUsed

    local receivedBy = "LUIE_RECEIVE_CRAFT" -- This keyword tells our item printer to print the items in a list separated by commas, to conserve space for the display of crafting mats consumed.
    local logPrefixPos = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft
    local logPrefixNeg = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse

    -- Get string values from our crafting hook function
    if GetCraftingInteractionType() == CRAFTING_TYPE_ENCHANTING then
        logPrefixPos = ChatAnnouncements.enchant_prefix_pos[ChatAnnouncements.enchanting.GetMode()]
        logPrefixNeg = ChatAnnouncements.enchant_prefix_neg[ChatAnnouncements.enchanting.GetMode()]
    end
    if GetCraftingInteractionType() == CRAFTING_TYPE_BLACKSMITHING or GetCraftingInteractionType() == CRAFTING_TYPE_CLOTHIER or GetCraftingInteractionType() == CRAFTING_TYPE_WOODWORKING or GetCraftingInteractionType() == CRAFTING_TYPE_JEWELRYCRAFTING then
        logPrefixPos = ChatAnnouncements.smithing_prefix_pos[ChatAnnouncements.smithing.GetMode()]
        logPrefixNeg = ChatAnnouncements.smithing_prefix_neg[ChatAnnouncements.smithing.GetMode()]
    end

    -- If the hook function didn't return a string value (for example because the player was in Gamepad mode), then we use a default override.
    if logPrefixPos == nil then
        logPrefixPos = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft
    end
    if logPrefixNeg == nil then
        logPrefixNeg = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeconstruct
    end

    if CheckLibLazyCraftingActive() then
        logPrefixPos = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft
        logPrefixNeg = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
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
        if not ChatAnnouncements.equippedStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.equippedStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(
                icon,
                stackCountChange,
                itemType,
                itemId,
                itemLink,
                receivedBy,
                logPrefix,
                gainOrLoss,
                false,
                nil,
                nil,
                nil
            )
            -- EXISTING ITEM
        elseif ChatAnnouncements.equippedStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.equippedStacks[slotIndex].icon
                stack = ChatAnnouncements.equippedStacks[slotIndex].stack
                itemType = ChatAnnouncements.equippedStacks[slotIndex].itemType
                itemId = ChatAnnouncements.equippedStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.equippedStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                ChatAnnouncements.oldItem = { itemLink = ChatAnnouncements.equippedStacks[slotIndex].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                end
                ChatAnnouncements.ItemPrinter(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ResolveCraftingUsed(itemType) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or logPrefixNeg
                if logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    if itemType == ITEMTYPE_FISH then
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
                    end
                    ChatAnnouncements.ItemPrinter(
                        icon,
                        change,
                        itemType,
                        itemId,
                        itemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        nil,
                        nil
                    )
                end
            end

            if removed then
                if ChatAnnouncements.equippedStacks[slotIndex] then
                    ChatAnnouncements.equippedStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.equippedStacks[slotIndex] =
                {
                    icon = icon,
                    stack = stack,
                    itemId = itemId,
                    itemType = itemType,
                    itemLink = itemLink
                }
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
        if not ChatAnnouncements.inventoryStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.inventoryStacks[slotIndex] =
            {
                icon = icon,
                stack = stack,
                itemId = itemId,
                itemType = itemType,
                itemLink = itemLink
            }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            ChatAnnouncements.ItemCounterDelay(
                icon,
                stackCountChange,
                itemType,
                itemId,
                itemLink,
                receivedBy,
                logPrefix,
                gainOrLoss,
                false,
                nil,
                false,
                true
            )
            -- EXISTING ITEM
        elseif ChatAnnouncements.inventoryStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            -- For item removal, we save whatever the currently indexed item is here.
            local removedIcon = ChatAnnouncements.inventoryStacks[slotIndex].icon
            local removedItemType = ChatAnnouncements.inventoryStacks[slotIndex].itemType
            local removedItemId = ChatAnnouncements.inventoryStacks[slotIndex].itemId
            local removedItemLink = ChatAnnouncements.inventoryStacks[slotIndex].itemLink
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.inventoryStacks[slotIndex].icon
                stack = ChatAnnouncements.inventoryStacks[slotIndex].stack
                itemType = ChatAnnouncements.inventoryStacks[slotIndex].itemType
                itemId = ChatAnnouncements.inventoryStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.inventoryStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                ChatAnnouncements.oldItem = { itemLink = ChatAnnouncements.inventoryStacks[slotIndex].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    false,
                    true
                )
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ResolveCraftingUsed(removedItemType) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or logPrefixNeg
                if logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    -- ChatAnnouncements.ItemPrinter(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false)
                    if removedItemType == ITEMTYPE_FISH then
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
                    end
                    ChatAnnouncements.ItemCounterDelay(
                        removedIcon,
                        change,
                        removedItemType,
                        removedItemId,
                        removedItemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        true,
                        true
                    )
                end
            end

            if removed then
                if ChatAnnouncements.inventoryStacks[slotIndex] then
                    ChatAnnouncements.inventoryStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.inventoryStacks[slotIndex] =
                {
                    icon = icon,
                    stack = stack,
                    itemId = itemId,
                    itemType = itemType,
                    itemLink = itemLink
                }
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
        if not ChatAnnouncements.bankStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.bankStacks[slotIndex] =
            {
                icon = icon,
                stack = stack,
                itemId = itemId,
                itemType = itemType,
                itemLink = itemLink
            }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(
                icon,
                stackCountChange,
                itemType,
                itemId,
                itemLink,
                receivedBy,
                logPrefix,
                gainOrLoss,
                false,
                nil,
                nil,
                nil
            )
            -- EXISTING ITEM
        elseif ChatAnnouncements.bankStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.bankStacks[slotIndex].icon
                stack = ChatAnnouncements.bankStacks[slotIndex].stack
                itemType = ChatAnnouncements.bankStacks[slotIndex].itemType
                itemId = ChatAnnouncements.bankStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.bankStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                ChatAnnouncements.oldItem = { itemLink = ChatAnnouncements.bankStacks[slotIndex].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    false,
                    true
                )
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ResolveCraftingUsed(itemType) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or logPrefixNeg
                if logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    -- ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                    if itemType == ITEMTYPE_FISH then
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
                    end
                    ChatAnnouncements.ItemCounterDelay(
                        icon,
                        change,
                        itemType,
                        itemId,
                        itemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        true,
                        true
                    )
                end
            end

            if removed then
                if ChatAnnouncements.bankStacks[slotIndex] then
                    ChatAnnouncements.bankStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.bankStacks[slotIndex] =
                {
                    icon = icon,
                    stack = stack,
                    itemId = itemId,
                    itemType = itemType,
                    itemLink = itemLink
                }
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
        if not ChatAnnouncements.bankSubscriberStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.bankSubscriberStacks[slotIndex] =
            {
                icon = icon,
                stack = stack,
                itemId = itemId,
                itemType = itemType,
                itemLink = itemLink
            }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(
                icon,
                stackCountChange,
                itemType,
                itemId,
                itemLink,
                receivedBy,
                logPrefix,
                gainOrLoss,
                false,
                nil,
                nil,
                nil
            )
            -- EXISTING ITEM
        elseif ChatAnnouncements.bankSubscriberStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.bankSubscriberStacks[slotIndex].icon
                stack = ChatAnnouncements.bankSubscriberStacks[slotIndex].stack
                itemType = ChatAnnouncements.bankSubscriberStacks[slotIndex].itemType
                itemId = ChatAnnouncements.bankSubscriberStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.bankSubscriberStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT CHANGE = 0 (UPGRADE)
            if stackCountChange == 0 then
                ChatAnnouncements.oldItem = { itemLink = ChatAnnouncements.bankSubscriberStacks[slotIndex].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil
                )
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    false,
                    true
                )
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ResolveCraftingUsed(itemType) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or logPrefixNeg
                if logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    if itemType == ITEMTYPE_FISH then
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
                    end
                    ChatAnnouncements.ItemCounterDelay(
                        icon,
                        change,
                        itemType,
                        itemId,
                        itemLink,
                        receivedBy,
                        logPrefix,
                        gainOrLoss,
                        false,
                        nil,
                        true,
                        true
                    )
                end
            end

            if removed then
                if ChatAnnouncements.bankSubscriberStacks[slotIndex] then
                    ChatAnnouncements.bankSubscriberStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.bankSubscriberStacks[slotIndex] =
                {
                    icon = icon,
                    stack = stack,
                    itemId = itemId,
                    itemType = itemType,
                    itemLink = itemLink
                }
            end
        end
    end

    if bagId == BAG_VIRTUAL then
        local gainOrLoss
        local logPrefix
        local itemLink = tostring(ChatAnnouncements.GetItemLinkFromItemId(slotIndex))
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotIndex
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)
        local change
        local alwaysFirst

        if stackCountChange > 0 then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ResolveCraftingUsed(itemType) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive or logPrefixPos
            change = stackCountChange
            alwaysFirst = false
        end

        if stackCountChange < 0 then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ResolveCraftingUsed(itemType) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or logPrefixNeg
            change = stackCountChange * -1
            alwaysFirst = true
        end

        if logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or ChatAnnouncements.SV.Inventory.LootShowCraftUse then
            if itemType == ITEMTYPE_FISH then
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
            end
            if itemId == 33753 then
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
            end
            ChatAnnouncements.ItemCounterDelay(
                icon,
                change,
                itemType,
                itemId,
                itemLink,
                receivedBy,
                logPrefix,
                gainOrLoss,
                false,
                nil,
                alwaysFirst,
                true
            )
        end
    end

    ChatAnnouncements.itemWasDestroyed = false
    ChatAnnouncements.lockpickBroken = false
end

--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
---
--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function ChatAnnouncements.InventoryUpdateBank(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update Bank:\n" ..
    --         "--> eventId: " .. tostring(eventId) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotIndex: " .. tostring(slotIndex) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange) .. "\n" ..
    --         "--> triggeredByCharacterName: " .. tostring(triggeredByCharacterName) .. "\n" ..
    --         "--> triggeredByDisplayName: " .. tostring(triggeredByDisplayName) .. "\n" ..
    --         "--> isLastUpdateForMessage: " .. tostring(isLastUpdateForMessage) .. "\n" ..
    --         "--> bonusDropSource: " .. tostring(bonusDropSource)
    --     LUIE:Log("Debug",traceback)
    -- end
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
        if not ChatAnnouncements.inventoryStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.inventoryStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdraw or ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawStorage
            if ChatAnnouncements.InventoryOn then
                ChatAnnouncements.ItemPrinter(
                    icon,
                    stackCountChange,
                    itemType,
                    itemId,
                    itemLink,
                    receivedBy,
                    logPrefix,
                    gainOrLoss,
                    false,
                    nil,
                    nil,
                    nil)
            end
            -- EXISTING ITEM
        elseif ChatAnnouncements.inventoryStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.inventoryStacks[slotIndex].icon
                stack = ChatAnnouncements.inventoryStacks[slotIndex].stack
                itemType = ChatAnnouncements.inventoryStacks[slotIndex].itemType
                itemId = ChatAnnouncements.inventoryStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.inventoryStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = ChatAnnouncements.bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdraw or ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawStorage
                if ChatAnnouncements.InventoryOn then
                    ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                if ChatAnnouncements.InventoryOn and not ChatAnnouncements.itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit or ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
            end

            if removed then
                if ChatAnnouncements.inventoryStacks[slotIndex] then
                    ChatAnnouncements.inventoryStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.inventoryStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not ChatAnnouncements.itemWasDestroyed then
                ChatAnnouncements.bankOn = true
            end
            if not ChatAnnouncements.itemWasDestroyed then
                ChatAnnouncements.InventoryOn = false
            end
            if not ChatAnnouncements.itemWasDestroyed then
                LUIE_callLater(ChatAnnouncements.BankFixer, 50)
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
        if not ChatAnnouncements.bankStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.bankStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
            if ChatAnnouncements.bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
            end
            -- EXISTING ITEM
        elseif ChatAnnouncements.bankStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.bankStacks[slotIndex].icon
                stack = ChatAnnouncements.bankStacks[slotIndex].stack
                itemType = ChatAnnouncements.bankStacks[slotIndex].itemType
                itemId = ChatAnnouncements.bankStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.bankStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
                if ChatAnnouncements.bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                if ChatAnnouncements.bankOn and not ChatAnnouncements.itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
            end

            if removed then
                if ChatAnnouncements.bankStacks[slotIndex] then
                    ChatAnnouncements.bankStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.bankStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not ChatAnnouncements.itemWasDestroyed then
                ChatAnnouncements.InventoryOn = true
            end
            if not ChatAnnouncements.itemWasDestroyed then
                ChatAnnouncements.bankOn = false
            end
            if not ChatAnnouncements.itemWasDestroyed then
                LUIE_callLater(ChatAnnouncements.BankFixer, 50)
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
        if not ChatAnnouncements.bankSubscriberStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.bankSubscriberStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
            if ChatAnnouncements.bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
            end
            -- EXISTING ITEM
        elseif ChatAnnouncements.bankSubscriberStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.bankSubscriberStacks[slotIndex].icon
                stack = ChatAnnouncements.bankSubscriberStacks[slotIndex].stack
                itemType = ChatAnnouncements.bankSubscriberStacks[slotIndex].itemType
                itemId = ChatAnnouncements.bankSubscriberStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.bankSubscriberStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
                if ChatAnnouncements.bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                if ChatAnnouncements.bankOn and not ChatAnnouncements.itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
            end

            if removed then
                if ChatAnnouncements.bankSubscriberStacks[slotIndex] then
                    ChatAnnouncements.bankSubscriberStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.bankSubscriberStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not ChatAnnouncements.itemWasDestroyed then
                ChatAnnouncements.InventoryOn = true
            end
            if not ChatAnnouncements.itemWasDestroyed then
                ChatAnnouncements.bankOn = false
            end
            if not ChatAnnouncements.itemWasDestroyed then
                LUIE_callLater(ChatAnnouncements.BankFixer, 50)
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
        if not ChatAnnouncements.houseBags[bagId][slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.houseBags[bagId][slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
            if ChatAnnouncements.bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
            end
            -- EXISTING ITEM
        elseif ChatAnnouncements.houseBags[bagId][slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.houseBags[bagId][slotIndex].icon
                stack = ChatAnnouncements.houseBags[bagId][slotIndex].stack
                itemType = ChatAnnouncements.houseBags[bagId][slotIndex].itemType
                itemId = ChatAnnouncements.houseBags[bagId][slotIndex].itemId
                itemLink = ChatAnnouncements.houseBags[bagId][slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            -- STACK COUNT INCREMENTED UP
            if stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
                if ChatAnnouncements.bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                if ChatAnnouncements.bankOn and not ChatAnnouncements.itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
            end

            if removed then
                if ChatAnnouncements.houseBags[bagId][slotIndex] then
                    ChatAnnouncements.houseBags[bagId][slotIndex] = nil
                end
            else
                ChatAnnouncements.houseBags[bagId][slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not ChatAnnouncements.itemWasDestroyed then
                ChatAnnouncements.InventoryOn = true
            end
            if not ChatAnnouncements.itemWasDestroyed then
                ChatAnnouncements.bankOn = false
            end
            if not ChatAnnouncements.itemWasDestroyed then
                LUIE_callLater(ChatAnnouncements.BankFixer, 50)
            end
        end
    end

    if bagId == BAG_VIRTUAL then
        local gainOrLoss
        local stack
        local logPrefix
        local itemLink = tostring(ChatAnnouncements.GetItemLinkFromItemId(slotIndex))
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotIndex
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)

        if stackCountChange < 1 then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit or ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
            stack = stackCountChange * -1
        else
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdraw or ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawStorage
            stack = stackCountChange
        end

        ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
    end

    ChatAnnouncements.itemWasDestroyed = false
    ChatAnnouncements.lockpickBroken = false
end

--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
---
--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function ChatAnnouncements.InventoryUpdateGuildBank(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update Guild Bank:\n" ..
    --         "--> eventId: " .. tostring(eventId) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotIndex: " .. tostring(slotIndex) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange) .. "\n" ..
    --         "--> triggeredByCharacterName: " .. tostring(triggeredByCharacterName) .. "\n" ..
    --         "--> triggeredByDisplayName: " .. tostring(triggeredByDisplayName) .. "\n" ..
    --         "--> isLastUpdateForMessage: " .. tostring(isLastUpdateForMessage) .. "\n" ..
    --         "--> bonusDropSource: " .. tostring(bonusDropSource)
    --     LUIE:Log("Debug",traceback)
    -- end

    local receivedBy = ""
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

        if not ChatAnnouncements.inventoryStacks[slotIndex] then -- NEW ITEM
            local icon1, stack1 = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.inventoryStacks[slotIndex] = { icon = icon1, stack = stack1, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawGuild
            ChatAnnouncements.guildBankCarry = {}
            ChatAnnouncements.guildBankCarry.icon = icon1
            ChatAnnouncements.guildBankCarry.stack = stack1
            ChatAnnouncements.guildBankCarry.gainOrLoss = gainOrLoss
            ChatAnnouncements.guildBankCarry.logPrefix = logPrefix
            ChatAnnouncements.guildBankCarry.receivedBy = receivedBy
            ChatAnnouncements.guildBankCarry.itemLink = itemLink
            ChatAnnouncements.guildBankCarry.itemId = itemId
            ChatAnnouncements.guildBankCarry.itemType = itemType
        elseif ChatAnnouncements.inventoryStacks[slotIndex] then -- EXISTING ITEM
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.inventoryStacks[slotIndex].icon
                stack = ChatAnnouncements.inventoryStacks[slotIndex].stack
                itemType = ChatAnnouncements.inventoryStacks[slotIndex].itemType
                itemId = ChatAnnouncements.inventoryStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.inventoryStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            if stackCountChange > 0 then -- STACK COUNT INCREMENTED UP
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawGuild
                ChatAnnouncements.guildBankCarry = {}
                ChatAnnouncements.guildBankCarry.icon = icon
                ChatAnnouncements.guildBankCarry.stack = stack
                ChatAnnouncements.guildBankCarry.gainOrLoss = gainOrLoss
                ChatAnnouncements.guildBankCarry.logPrefix = logPrefix
                ChatAnnouncements.guildBankCarry.receivedBy = receivedBy
                ChatAnnouncements.guildBankCarry.itemLink = itemLink
                ChatAnnouncements.guildBankCarry.itemId = itemId
                ChatAnnouncements.guildBankCarry.itemType = itemType
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
                if not ChatAnnouncements.itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositGuild
                    ChatAnnouncements.guildBankCarry = {}
                    ChatAnnouncements.guildBankCarry.icon = icon
                    ChatAnnouncements.guildBankCarry.stack = stack
                    ChatAnnouncements.guildBankCarry.gainOrLoss = gainOrLoss
                    ChatAnnouncements.guildBankCarry.logPrefix = logPrefix
                    ChatAnnouncements.guildBankCarry.receivedBy = receivedBy
                    ChatAnnouncements.guildBankCarry.itemLink = itemLink
                    ChatAnnouncements.guildBankCarry.itemId = itemId
                    ChatAnnouncements.guildBankCarry.itemType = itemType
                end
            end

            if removed then
                if ChatAnnouncements.inventoryStacks[slotIndex] then
                    ChatAnnouncements.inventoryStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.inventoryStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end
    end

    ---------------------------------- CRAFTING BAG ----------------------------------
    if bagId == BAG_VIRTUAL then
        local gainOrLoss
        local stack
        local logPrefix
        local itemLink = tostring(ChatAnnouncements.GetItemLinkFromItemId(slotIndex))
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotIndex
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)

        if stackCountChange < 1 then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositGuild
            stack = stackCountChange * -1
        else
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawGuild
            stack = stackCountChange
        end

        ChatAnnouncements.guildBankCarry = {}
        ChatAnnouncements.guildBankCarry.icon = icon
        ChatAnnouncements.guildBankCarry.stack = stack
        ChatAnnouncements.guildBankCarry.gainOrLoss = gainOrLoss
        ChatAnnouncements.guildBankCarry.logPrefix = logPrefix
        ChatAnnouncements.guildBankCarry.receivedBy = receivedBy
        ChatAnnouncements.guildBankCarry.itemLink = itemLink
        ChatAnnouncements.guildBankCarry.itemId = itemId
        ChatAnnouncements.guildBankCarry.itemType = itemType
        ChatAnnouncements.guildBankCarry.itemQuality = itemQuality
    end

    ChatAnnouncements.itemWasDestroyed = false
    ChatAnnouncements.lockpickBroken = false
end

--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
---
--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function ChatAnnouncements.InventoryUpdateFence(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update Fence:\n" ..
    --         "--> eventId: " .. tostring(eventId) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotIndex: " .. tostring(slotIndex) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange) .. "\n" ..
    --         "--> triggeredByCharacterName: " .. tostring(triggeredByCharacterName) .. "\n" ..
    --         "--> triggeredByDisplayName: " .. tostring(triggeredByDisplayName) .. "\n" ..
    --         "--> isLastUpdateForMessage: " .. tostring(isLastUpdateForMessage) .. "\n" ..
    --         "--> bonusDropSource: " .. tostring(bonusDropSource)
    --     LUIE:Log("Debug",traceback)
    -- end

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
        if not ChatAnnouncements.inventoryStacks[slotIndex] then
            icon, stack = GetItemInfo(bagId, slotIndex)
            itemType = GetItemType(bagId, slotIndex)
            itemId = GetItemId(bagId, slotIndex)
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            ChatAnnouncements.inventoryStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            -- EXISTING ITEM
        elseif ChatAnnouncements.inventoryStacks[slotIndex] then
            itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = ChatAnnouncements.inventoryStacks[slotIndex].icon
                stack = ChatAnnouncements.inventoryStacks[slotIndex].stack
                itemType = ChatAnnouncements.inventoryStacks[slotIndex].itemType
                itemId = ChatAnnouncements.inventoryStacks[slotIndex].itemId
                itemLink = ChatAnnouncements.inventoryStacks[slotIndex].itemLink
                removed = true
            else
                -- If we get a value for itemLink, then we want to use bag info to fill in the blanks
                icon, stack = GetItemInfo(bagId, slotIndex)
                itemType = GetItemType(bagId, slotIndex)
                itemId = GetItemId(bagId, slotIndex)
                removed = false
            end

            if stackCountChange == 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunder or ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunderNoV
                if not ChatAnnouncements.weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
                    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                        changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
                    end
                    local messageType = "LUIE_CURRENCY_VENDOR"

                    local parts = { ZO_LinkHandler_ParseLink(itemLink) }
                    parts[22] = "1"
                    local partss = table_concat(parts, ":"):sub(2, -1)
                    itemLink = zo_strformat("|H<<1>>|h|h", partss)

                    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
                    local itemCount = stack > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. stack .. "|r") or ""
                    local carriedItem = (formattedIcon .. itemLink .. itemCount)
                    local carriedItemTotal = ""
                    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                        local total = getItemLinkStackCount(itemLink)
                        if total >= 1 then
                            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        end
                    end

                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                        ChatAnnouncements.savedPurchase.changeColor = changeColor
                        ChatAnnouncements.savedPurchase.messageChange = logPrefix
                        ChatAnnouncements.savedPurchase.messageType = messageType
                        ChatAnnouncements.savedPurchase.carriedItem = carriedItem
                        ChatAnnouncements.savedPurchase.carriedItemTotal = carriedItemTotal
                    else
                        ChatAnnouncements.savedLaunder =
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
                logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunder or ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunderNoV
                --[[                 if not ChatAnnouncements.weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
                    --ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true)
                end ]]
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if ChatAnnouncements.itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                else
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunder or ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunderNoV
                    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                        changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
                    end
                    local messageType = "LUIE_CURRENCY_VENDOR"

                    local parts = { ZO_LinkHandler_ParseLink(itemLink) }
                    parts[22] = "1"
                    local partss = table_concat(parts, ":"):sub(2, -1)
                    itemLink = zo_strformat("|H<<1>>|h|h", partss)

                    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
                    local itemCount = stack > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. stack .. "|r") or ""
                    local carriedItem = (formattedIcon .. itemLink .. itemCount)
                    local carriedItemTotal = ""
                    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                        local total = getItemLinkStackCount(itemLink)
                        if total >= 1 then
                            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        end
                    end

                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                        ChatAnnouncements.savedPurchase.changeColor = changeColor
                        ChatAnnouncements.savedPurchase.messageChange = logPrefix
                        ChatAnnouncements.savedPurchase.messageType = messageType
                        ChatAnnouncements.savedPurchase.carriedItem = carriedItem
                        ChatAnnouncements.savedPurchase.carriedItemTotal = carriedItemTotal
                    else
                        ChatAnnouncements.savedLaunder =
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
                if ChatAnnouncements.inventoryStacks[slotIndex] then
                    ChatAnnouncements.inventoryStacks[slotIndex] = nil
                end
            else
                ChatAnnouncements.inventoryStacks[slotIndex] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end
    end

    if bagId == BAG_VIRTUAL then
        local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
        local logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunder or ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunderNoV
        local itemLink = GetItemLink(bagId, slotIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotIndex
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)

        if not ChatAnnouncements.weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
            local change = stackCountChange > 0 and stackCountChange or stackCountChange * -1
            local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ChatAnnouncements.Colors.CurrencyDownColorize:ToHex() or ChatAnnouncements.Colors.CurrencyColorize:ToHex()
            if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                changeColor = ChatAnnouncements.Colors.CurrencyColorize:ToHex()
            end
            local messageType = "LUIE_CURRENCY_VENDOR"

            local parts = { ZO_LinkHandler_ParseLink(itemLink) }
            parts[22] = "1"
            local partss = table_concat(parts, ":"):sub(2, -1)
            itemLink = zo_strformat("|H<<1>>|h|h", partss)

            local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
            local itemCount = stackCountChange > 1 and (" |cFFFFFF" .. LUIE_TINY_X_FORMATTER .. "" .. stackCountChange .. "|r") or ""
            local carriedItem = (formattedIcon .. itemLink .. itemCount)
            local carriedItemTotal = ""
            if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                local total = getItemLinkStackCount(itemLink)
                if total >= 1 then
                    carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                end
            end

            if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                ChatAnnouncements.savedPurchase.changeColor = changeColor
                ChatAnnouncements.savedPurchase.messageChange = logPrefix
                ChatAnnouncements.savedPurchase.messageType = messageType
                ChatAnnouncements.savedPurchase.carriedItem = carriedItem
                ChatAnnouncements.savedPurchase.carriedItemTotal = carriedItemTotal
            else
                ChatAnnouncements.savedLaunder =
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

    ChatAnnouncements.itemWasDestroyed = false
    ChatAnnouncements.lockpickBroken = false
end

-- Makes it so bank withdraw/deposit events only occur when we can confirm the item is crossing over.
function ChatAnnouncements.BankFixer()
    ChatAnnouncements.InventoryOn = false
    ChatAnnouncements.bankOn = false
end

function ChatAnnouncements.JusticeStealRemove(eventCode)
    LUIE_callLater(ChatAnnouncements.JusticeRemovePrint, 50)
end

function ChatAnnouncements.JusticeDisplayConfiscate()
    local function getConfiscateMessage()
        if ChatAnnouncements.itemsConfiscated then
            return GetString(LUIE_STRING_CA_JUSTICE_CONFISCATED_BOUNTY_ITEMS_MSG)
        else
            return GetString(LUIE_STRING_CA_JUSTICE_CONFISCATED_MSG)
        end
    end
    if ChatAnnouncements.SV.Notify.NotificationConfiscateCA or ChatAnnouncements.SV.Notify.NotificationConfiscateAlert then
        local ConfiscateMessage = getConfiscateMessage()
        if ChatAnnouncements.SV.Notify.NotificationConfiscateCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = ConfiscateMessage,
                messageType = "NOTIFICATION",
                isSystem = true
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        else
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, ConfiscateMessage)
        end
    end
    ChatAnnouncements.itemsConfiscated = false
end

function ChatAnnouncements.JusticeRemovePrint()
    ChatAnnouncements.itemsConfiscated = true

    -- PART 1 -- INVENTORY
    if ChatAnnouncements.SV.Inventory.LootConfiscate then
        local bagsize = GetBagSize(BAG_BACKPACK)

        -- First pass: Build current inventory state
        for i = 0, bagsize do
            local icon, stack = GetItemInfo(BAG_BACKPACK, i)
            local itemType = GetItemType(BAG_BACKPACK, i)
            local itemId = GetItemId(BAG_BACKPACK, i)
            local itemLink = GetItemLink(BAG_BACKPACK, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])

            if itemLink ~= "" then
                ChatAnnouncements.JusticeStacks[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end

        -- Second pass: Compare with previous inventory state
        for i = 0, bagsize do
            local inventoryitem = ChatAnnouncements.inventoryStacks[i]
            local justiceitem = ChatAnnouncements.JusticeStacks[i]
            if inventoryitem ~= nil and justiceitem == nil then
                local receivedBy = ""
                local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
                ChatAnnouncements.ItemPrinter(inventoryitem.icon, inventoryitem.stack, inventoryitem.itemType, inventoryitem.itemId, inventoryitem.itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
            end
        end

        -- Reset Justice Stacks to reuse for equipped
        ChatAnnouncements.JusticeStacks = {}

        -- PART 2 -- EQUIPPED
        bagsize = GetBagSize(BAG_WORN)
        -- Store weapon slot indices
        local MAIN_HAND_SLOT = 4
        local OFF_HAND_SLOT = 5
        local BACKUP_MAIN_SLOT = 20
        local BACKUP_OFF_SLOT = 21

        -- Get current weapon pair
        local activeWeaponPair = GetActiveWeaponPairInfo()

        -- Build equipped items snapshot (after confiscation)
        local currentEquippedItems = {}
        for i = 0, bagsize do
            local icon, stack = GetItemInfo(BAG_WORN, i)
            local itemType = GetItemType(BAG_WORN, i)
            local itemId = GetItemId(BAG_WORN, i)
            local itemLink = GetItemLink(BAG_WORN, i, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])

            if itemLink ~= "" then
                currentEquippedItems[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end

        -- Compare equipped items
        for i = 0, bagsize do
            -- Skip weapon slots - we'll handle those separately
            if i ~= MAIN_HAND_SLOT and i ~= OFF_HAND_SLOT and
            i ~= BACKUP_MAIN_SLOT and i ~= BACKUP_OFF_SLOT then
                local previousItem = ChatAnnouncements.equippedStacks[i]
                local currentItem = currentEquippedItems[i]

                if previousItem ~= nil and currentItem == nil then
                    local receivedBy = ""
                    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
                    ChatAnnouncements.ItemPrinter(previousItem.icon, previousItem.stack, previousItem.itemType, previousItem.itemId, previousItem.itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
                end
            end
        end

        -- Handle weapon slots
        local activeMain = (activeWeaponPair == 1) and MAIN_HAND_SLOT or BACKUP_MAIN_SLOT
        local activeOff = (activeWeaponPair == 1) and OFF_HAND_SLOT or BACKUP_OFF_SLOT

        -- Check if active main hand was confiscated
        local previousActiveMain = ChatAnnouncements.equippedStacks[activeMain]
        local currentActiveMain = currentEquippedItems[activeMain]
        if previousActiveMain ~= nil and currentActiveMain == nil then
            local receivedBy = ""
            local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
            ChatAnnouncements.ItemPrinter(previousActiveMain.icon, previousActiveMain.stack, previousActiveMain.itemType, previousActiveMain.itemId, previousActiveMain.itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
        end

        -- Check if active off hand was confiscated
        local previousActiveOff = ChatAnnouncements.equippedStacks[activeOff]
        local currentActiveOff = currentEquippedItems[activeOff]
        if previousActiveOff ~= nil and currentActiveOff == nil then
            local receivedBy = ""
            local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
            ChatAnnouncements.ItemPrinter(previousActiveOff.icon, previousActiveOff.stack, previousActiveOff.itemType, previousActiveOff.itemId, previousActiveOff.itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, nil, nil)
        end
    end

    ChatAnnouncements.JusticeStacks = {} -- Clear the Justice Item Stacks since we don't need this for anything else!
    ChatAnnouncements.equippedStacks = {}
    ChatAnnouncements.inventoryStacks = {}
    ChatAnnouncements.IndexEquipped()
    ChatAnnouncements.IndexInventory() -- Reindex the inventory with the correct values!
end

--- - **EVENT_DISGUISE_STATE_CHANGED **
---
--- @param eventId integer
--- @param unitTag string
--- @param disguiseState DisguiseState
function ChatAnnouncements.DisguiseState(eventId, unitTag, disguiseState)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Disguise State:\n" ..
    --         "--> eventCode: " .. tostring(eventCode) .. "\n" ..
    --         "--> unitTag: " .. tostring(unitTag) .. "\n" ..
    --         "--> disguiseState: " .. tostring(disguiseState)
    --     LUIE:Log("Debug",traceback)
    -- end

    if disguiseState == DISGUISE_STATE_DANGER then
        if ChatAnnouncements.SV.Notify.DisguiseWarnCA then
            local message = GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DANGER)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.GROUP_ELECTION_REQUESTED)
            messageParams:SetText(ChatAnnouncements.Colors.DisguiseAlertColorize:Colorize(GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DANGER)))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DANGER))
        end

        if (ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert) and not ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
        end
    end

    if disguiseState == DISGUISE_STATE_SUSPICIOUS then
        if ChatAnnouncements.SV.Notify.DisguiseWarnCA then
            local message = GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_SUSPICIOUS)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.GROUP_ELECTION_REQUESTED)
            messageParams:SetText(ChatAnnouncements.Colors.DisguiseAlertColorize:Colorize(GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_SUSPICIOUS)))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_SUSPICIOUS))
        end
        if (ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert) and not ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
        end
    end

    -- If we're still disguised and ChatAnnouncements.disguiseState is true then don't waste resources and end the function
    if ChatAnnouncements.disguiseState == 1 and (disguiseState == DISGUISE_STATE_DISGUISED or disguiseState == DISGUISE_STATE_DANGER or disguiseState == DISGUISE_STATE_SUSPICIOUS or disguiseState == DISGUISE_STATE_DISCOVERED) then
        return
    end

    if ChatAnnouncements.disguiseState == 1 and (disguiseState == DISGUISE_STATE_NONE) then
        local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_NONE), Effects.DisguiseIcons[ChatAnnouncements.currentDisguise].description)
        if ChatAnnouncements.SV.Notify.DisguiseCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.DisguiseAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
        if ChatAnnouncements.SV.Notify.DisguiseCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
            messageParams:SetText(message)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end

    if ChatAnnouncements.disguiseState == 0 and (disguiseState == DISGUISE_STATE_DISGUISED or disguiseState == DISGUISE_STATE_DANGER or disguiseState == DISGUISE_STATE_SUSPICIOUS or disguiseState == DISGUISE_STATE_DISCOVERED) then
        ChatAnnouncements.currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
        local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DISGUISED), Effects.DisguiseIcons[ChatAnnouncements.currentDisguise].description)
        if ChatAnnouncements.SV.Notify.DisguiseCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                messageType = "MESSAGE"
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.DisguiseAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
        if ChatAnnouncements.SV.Notify.DisguiseCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
            messageParams:SetText(message)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end

    ChatAnnouncements.disguiseState = GetUnitDisguiseState("player")

    if ChatAnnouncements.disguiseState > 0 then
        ChatAnnouncements.disguiseState = 1
    end
end

--- - **EVENT_PLAYER_ACTIVATED **
---
--- @param eventId integer
--- @param initial boolean
function ChatAnnouncements.OnPlayerActivated(eventId, initial)
    -- Get current trades if UI is reloaded
    local characterName, millisecondsSinceRequest, displayName = GetTradeInviteInfo()

    if characterName ~= "" and displayName ~= "" then
        local tradeName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
        ChatAnnouncements.tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, tradeName))
    end

    if g_firstLoad then
        -- pChat registers formatters in EVENT_PLAYER_ACTIVATED, so delay to ensure pChat has finished
        LUIE_callLater(function ()
                           ChatAnnouncements.SlayChatHandlers()
                       end, 50)
        g_firstLoad = false
    end

    LUIE_callLater(function ()
                       ChatAnnouncements.loginHideQuestLoot = false
                   end, 3000)

    if ChatAnnouncements.SV.Notify.DisguiseCA or ChatAnnouncements.SV.Notify.DisguiseCSA or ChatAnnouncements.SV.Notify.DisguiseAlert or ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnCSA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
        if ChatAnnouncements.disguiseState == 0 then
            ChatAnnouncements.disguiseState = GetUnitDisguiseState("player")
            if ChatAnnouncements.disguiseState == 0 then
                return
            elseif ChatAnnouncements.disguiseState ~= 0 then
                ChatAnnouncements.disguiseState = 1
                ChatAnnouncements.currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
                local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DISGUISED), Effects.DisguiseIcons[ChatAnnouncements.currentDisguise].description)
                if ChatAnnouncements.SV.Notify.DisguiseCA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                    {
                        message = message,
                        messageType = "MESSAGE"
                    }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end
                if ChatAnnouncements.SV.Notify.DisguiseAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
                end
                if ChatAnnouncements.SV.Notify.DisguiseCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
                    messageParams:SetText(message)
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
                return
            end
        elseif ChatAnnouncements.disguiseState == 1 then
            ChatAnnouncements.disguiseState = GetUnitDisguiseState("player")
            if ChatAnnouncements.disguiseState == 0 then
                local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_NONE), Effects.DisguiseIcons[ChatAnnouncements.currentDisguise].description)
                if ChatAnnouncements.SV.Notify.DisguiseCA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
                    {
                        message = message,
                        messageType = "MESSAGE"
                    }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end
                if ChatAnnouncements.SV.Notify.DisguiseAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
                end
                if ChatAnnouncements.SV.Notify.DisguiseCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
                    messageParams:SetText(message)
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
                return
            elseif ChatAnnouncements.disguiseState ~= 0 then
                ChatAnnouncements.disguiseState = 1
                ChatAnnouncements.currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
                return
            end
        end
    end
end

--[[ STUCK REFERENCE
function ChatAnnouncements.StuckOnCooldown(eventCode)
    local cooldownText = ZO_FormatTime(GetStuckCooldown(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    local cooldownRemainingText = ZO_FormatTimeMilliseconds(GetTimeUntilStuckAvailable(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    printToChat(zo_strformat(GetString(SI_STUCK_ERROR_ON_COOLDOWN), cooldownText, cooldownRemainingText ))
end
]]

--- - **EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL**
---
--- @param eventId integer
function ChatAnnouncements.InventoryFullQuest(eventId)
    printToChat(GetString(SI_INVENTORY_ERROR_INVENTORY_FULL))
end

--- - **EVENT_INVENTORY_IS_FULL **
---
--- @param eventId integer
--- @param numSlotsRequested integer
--- @param numSlotsFree integer
function ChatAnnouncements.InventoryFull(eventId, numSlotsRequested, numSlotsFree)
    local function DisplayItemFailed()
        if numSlotsRequested == 1 then
            printToChat(GetString(SI_INVENTORY_ERROR_INVENTORY_FULL))
        else
            printToChat(zo_strformat(GetString(SI_INVENTORY_ERROR_INSUFFICIENT_SPACE), (numSlotsRequested - numSlotsFree)))
        end
    end

    LUIE_callLater(DisplayItemFailed, 100)
end

--- - **EVENT_LOOT_ITEM_FAILED **
---
--- @param eventId integer
--- @param reason LootItemResult
--- @param itemLink string
function ChatAnnouncements.LootItemFailed(eventId, reason, itemLink)
    -- Stop Spam
    eventManager:UnregisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED)
    local itemName = GetItemLinkName(itemLink)
    local function ReactivateLootItemFailed()
        printToChat(zo_strformat(GetString("SI_LOOTITEMRESULT", reason), itemName))
        eventManager:RegisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED, ChatAnnouncements.LootItemFailed)
    end

    LUIE_callLater(ReactivateLootItemFailed, 100)
end

-------------------------------------------------------------------------
-- LINK HANDLER STUFF.
-------------------------------------------------------------------------

-- LINK_HANDLER.LINK_MOUSE_UP_EVENT
-- LINK_HANDLER.LINK_CLICKED_EVENT
-- Custom Link Handlers to deal with when a book link in chat is clicked, this will open the book rather than the default link that only shows whether a lore entry has been read or not.
function ChatAnnouncements.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, categoryIndex, collectionIndex, bookIndex)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Handle Click Event:\n" ..
    --         "--> rawLink: " .. tostring(rawLink) .. "\n" ..
    --         "--> mouseButton: " .. tostring(mouseButton) .. "\n" ..
    --         "--> linkText: " .. tostring(linkText) .. "\n" ..
    --         "--> linkStyle: " .. tostring(linkStyle) .. "\n" ..
    --         "--> linkType: " .. tostring(linkType) .. "\n" ..
    --         "--> categoryIndex: " .. tostring(categoryIndex) .. "\n" ..
    --         "--> collectionIndex: " .. tostring(collectionIndex) .. "\n" ..
    --         "--> bookIndex: " .. tostring(bookIndex)
    --     LUIE:Log("Debug",traceback)
    -- end

    if linkType == "LINK_TYPE_LUIE_BOOK" then
        -- Read the book
        ZO_LoreLibrary_ReadBook(categoryIndex, collectionIndex, bookIndex)
        return true
    end
    if linkType == "LINK_TYPE_LUIE_ANTIQUITY" then
        local categoryIndex1 = tonumber(categoryIndex)
        -- Open the codex
        if IsInGamepadPreferredMode() then
            local DONT_PUSH = false
            local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(categoryIndex1)
            assert(antiquityData ~= nil)
            if antiquityData then
                ANTIQUITY_LORE_GAMEPAD:ShowAntiquityOrSet(antiquityData, DONT_PUSH)
            end
        else
            ANTIQUITY_LORE_KEYBOARD:ShowAntiquity(categoryIndex1)
        end
        return true
    end
end

--- Handles trade invite accepted events.
--- @param eventCode number The event code that triggered this function
function ChatAnnouncements.TradeInviteAccepted(eventCode)
    if ChatAnnouncements.SV.Notify.NotificationTradeCA then
        printToChat(GetString(LUIE_STRING_CA_TRADE_INVITE_ACCEPTED), true)
    end
    if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_TRADE_INVITE_ACCEPTED))
    end

    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootTrade then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        ChatAnnouncements.inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
    ChatAnnouncements.inTrade = true
end

--- - **EVENT_TRADE_ITEM_ADDED **
---
--- @param eventId integer
--- @param who TradeParticipant
--- @param tradeIndex luaindex
--- @param itemSoundCategory ItemUISoundCategory
function ChatAnnouncements.OnTradeAdded(eventId, who, tradeIndex, itemSoundCategory)
    local index = tradeIndex
    local name, icon, stack = GetTradeItemInfo(who, tradeIndex)
    local itemLink = GetTradeItemLink(who, tradeIndex, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
    local itemId = GetItemLinkItemId(itemLink)
    local itemType = GetItemLinkItemType(itemLink)

    if who == 0 then
        ChatAnnouncements.tradeStacksOut[index] = { icon = icon, stack = stack, itemId = itemId, itemLink = itemLink, itemType = itemType }
    else
        ChatAnnouncements.tradeStacksIn[index] = { icon = icon, stack = stack, itemId = itemId, itemLink = itemLink, itemType = itemType }
    end
end

--- - **EVENT_TRADE_ITEM_REMOVED **
---
--- @param eventId integer
--- @param who TradeParticipant
--- @param tradeIndex luaindex
--- @param itemSoundCategory ItemUISoundCategory
function ChatAnnouncements.OnTradeRemoved(eventId, who, tradeIndex, itemSoundCategory)
    local indexOut = tradeIndex
    if who == 0 then
        ChatAnnouncements.tradeStacksOut[indexOut] = nil
    else
        ChatAnnouncements.tradeStacksIn[indexOut] = nil
    end
end

-- Called on player joining a group to determine if message syntax should show group or LFG group.
function ChatAnnouncements.CheckLFGStatusJoin()
    if not ChatAnnouncements.stopGroupLeaveQueue then
        if not ChatAnnouncements.lfgDisableGroupEvents then
            if IsInLFGGroup() and not ChatAnnouncements.joinLFGOverride then
                if ChatAnnouncements.SV.Group.GroupCA then
                    printToChat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF_LFG), true)
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF_LFG))
                end
            elseif not IsInLFGGroup() and not ChatAnnouncements.joinLFGOverride then
                local isLeader = IsUnitGroupLeader("player") -- If the player is the leader, then they must have formed the group.
                if ChatAnnouncements.SV.Group.GroupCA then
                    if isLeader then
                        printToChat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_FORM), true)
                    else
                        printToChat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF), true)
                    end
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    if isLeader then
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_FORM))
                    else
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF))
                    end
                end
                -- If the player is the leader, show the other member as joining the group.
                if isLeader and not IsInLFGGroup() then
                    local groupSize = GetGroupSize() + GetNumCompanionsInGroup()
                    -- If for some reason the group is bigger or smaller than just 2 people (initial formation), then don't proceed here.
                    if groupSize == 2 then
                        local unitToJoin
                        if GetUnitDisplayName("group1") == LUIE.PlayerDisplayName then
                            unitToJoin = "group2"
                        else
                            unitToJoin = "group1"
                        end
                        local joinedMemberName = GetUnitName(unitToJoin)
                        local joinedMemberAccountName = GetUnitDisplayName(unitToJoin)
                        -- Resolve name links
                        local finalName = ChatAnnouncements.ResolveNameLink(joinedMemberName, joinedMemberAccountName)
                        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(joinedMemberName, joinedMemberAccountName)
                        -- Set final messages to send
                        local SendMessage = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalName))
                        local SendAlert = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalAlertName))
                        ChatAnnouncements.PrintJoinStatusNotSelf(SendMessage, SendAlert)
                    end
                end
            end
        end
        ChatAnnouncements.joinLFGOverride = false
    end
end

--- Called when another player joins the group.
--- @param SendMessage boolean Whether to send a chat message
--- @param SendAlert boolean Whether to send an alert
function ChatAnnouncements.PrintJoinStatusNotSelf(SendMessage, SendAlert)
    -- Bail out if we're hiding events from LFG.
    if ChatAnnouncements.stopGroupLeaveQueue or ChatAnnouncements.lfgDisableGroupEvents then
        return
    end

    -- Otherwise print the message
    if ChatAnnouncements.SV.Group.GroupCA then
        printToChat(SendMessage, true)
    end
    if ChatAnnouncements.SV.Group.GroupAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, SendAlert)
    end
end

--- Called on player leaving a group to determine if message syntax should show group or LFG group.
--- @param WasKicked boolean Whether the player was kicked from the group
function ChatAnnouncements.CheckLFGStatusLeave(WasKicked)
    -- Bail out if we joined an LFG group.
    if ChatAnnouncements.stopGroupLeaveQueue or ChatAnnouncements.lfgDisableGroupEvents then
        ChatAnnouncements.leaveLFGOverride = false
        return
    end
    if ChatAnnouncements.leaveLFGOverride and GetGroupSize() == 0 then
        if ChatAnnouncements.SV.Group.GroupCA then
            printToChat(GetString(LUIE_STRING_CA_GROUP_QUIT_LFG), true)
        end
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_GROUP_QUIT_LFG))
        end
    end
    ChatAnnouncements.leaveLFGOverride = false
end

--- - **EVENT_GROUP_INVITE_RECEIVED **
---
--- @param eventId integer
--- @param inviterCharacterName string
--- @param inviterDisplayName string
function ChatAnnouncements.OnGroupInviteReceived(eventId, inviterCharacterName, inviterDisplayName)
    if ChatAnnouncements.SV.Group.GroupCA then
        local finalName = ChatAnnouncements.ResolveNameLink(inviterCharacterName, inviterDisplayName)
        local message = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MESSAGE), finalName)
        printToChat(message, true)
    end
    if ChatAnnouncements.SV.Group.GroupAlert then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterCharacterName, inviterDisplayName)
        local alertText = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MESSAGE), finalAlertName)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
    end
end

--- Indexes group loot.
function ChatAnnouncements.IndexGroupLoot()
    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local characterName = GetUnitName("group" .. i)
        local displayName = GetUnitDisplayName("group" .. i)
        ChatAnnouncements.groupLootIndex[characterName] =
        {
            characterName = characterName,
            displayName = displayName
        }
    end
end

--- Handles group type change events. Runs on the `EVENT_GROUP_TYPE_CHANGED` event.
--- @param eventCode number The event code that triggered this function
--- @param largeGroup boolean Whether the group is now a large group
function ChatAnnouncements.OnGroupTypeChanged(eventCode, largeGroup)
    local message
    if largeGroup then
        message = GetString(SI_CHAT_ANNOUNCEMENT_IN_LARGE_GROUP)
    else
        message = GetString(SI_CHAT_ANNOUNCEMENT_IN_SMALL_GROUP)
    end

    if ChatAnnouncements.SV.Group.GroupCA then
        printToChat(message, true)
    end
    if ChatAnnouncements.SV.Group.GroupAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
    end
end

--- Handles vote notification events. Runs on the `EVENT_GROUP_ELECTION_NOTIFICATION_ADDED` event.
--- @param eventCode number The event code that triggered this function
function ChatAnnouncements.VoteNotify(eventCode)
    local electionType, timeRemainingSeconds, electionDescriptor, targetUnitTag = GetGroupElectionInfo()
    if electionType == GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS then -- Ready Check
        if ChatAnnouncements.SV.Group.GroupVoteCA then
            printToChat(GetString(SI_GROUP_ELECTION_READY_CHECK_MESSAGE), true)
        end
        if ChatAnnouncements.SV.Group.GroupVoteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(SI_GROUP_ELECTION_READY_CHECK_MESSAGE))
        end
    end

    if electionType == GROUP_ELECTION_TYPE_KICK_MEMBER then -- Vote Kick
        local kickMemberName = GetUnitName(targetUnitTag)
        local kickMemberAccountName = GetUnitDisplayName(targetUnitTag)

        if ChatAnnouncements.SV.Group.GroupVoteCA then
            local finalName = ChatAnnouncements.ResolveNameLink(kickMemberName, kickMemberAccountName)
            local message = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_START), finalName)
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupVoteAlert then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(kickMemberName, kickMemberAccountName)
            local alertText = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_START), finalAlertName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
        end
    end
end

--- Handles LFG leave events. Runs on the `EVENT_GROUPING_TOOLS_NO_LONGER_LFG` event.
--- @param eventCode number The event code that triggered this function
function ChatAnnouncements.LFGLeft(eventCode)
    ChatAnnouncements.leaveLFGOverride = true
end

--- - **EVENT_PLEDGE_OF_MARA_OFFER **
---
--- @param eventId integer
--- @param targetCharacterName string
--- @param isSender boolean
--- @param targetDisplayName string
function ChatAnnouncements.MaraOffer(eventId, targetCharacterName, isSender, targetDisplayName)
    -- Display CA
    if ChatAnnouncements.SV.Social.PledgeOfMaraCA then
        local finalName = ChatAnnouncements.ResolveNameLink(targetCharacterName, targetDisplayName)
        if isSender then
            printToChat(zo_strformat(GetString(SI_PLEDGE_OF_MARA_SENDER_MESSAGE), finalName), true)
        else
            printToChat(zo_strformat(GetString(SI_PLEDGE_OF_MARA_MESSAGE), finalName), true)
        end
    end

    -- Display Alert
    if ChatAnnouncements.SV.Social.PledgeOfMaraAlert then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(targetCharacterName, targetDisplayName)
        local alertString
        if isSender then
            alertString = zo_strformat(GetString(SI_PLEDGE_OF_MARA_SENDER_MESSAGE), finalAlertName)
        else
            alertString = zo_strformat(GetString(SI_PLEDGE_OF_MARA_MESSAGE), finalAlertName)
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertString)
    end
end

--- Handles duel start events. Runs on the `EVENT_DUEL_STARTED` event.
--- @param eventCode number The event code that triggered this function
function ChatAnnouncements.DuelStarted(eventCode)
    -- Display CA
    if ChatAnnouncements.SV.Social.DuelStartCA or ChatAnnouncements.SV.Social.DuelStartAlert then
        local message
        local formattedIcon = zo_iconFormat("EsoUI/Art/HUD/HUD_Countdown_Badge_Dueling.dds", 16, 16)
        if ChatAnnouncements.SV.Social.DuelStartOptions == 1 then
            message = zo_strformat(GetString(LUIE_STRING_CA_DUEL_STARTED_WITH_ICON), formattedIcon)
        elseif ChatAnnouncements.SV.Social.DuelStartOptions == 2 then
            message = GetString(LUIE_STRING_CA_DUEL_STARTED)
        elseif ChatAnnouncements.SV.Social.DuelStartOptions == 3 then
            message = zo_strformat("<<1>>", formattedIcon)
        end

        if ChatAnnouncements.SV.Social.DuelStartCA then
            printToChat(message, true)
        end

        if ChatAnnouncements.SV.Social.DuelStartAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
    end

    -- Play sound if CSA is not enabled
    if not ChatAnnouncements.SV.Social.DuelStartCSA then
        PlaySound(SOUNDS.DUEL_START)
    end
end

--- Resets stack split tracking.
function ChatAnnouncements.ResetStackSplit()
    ChatAnnouncements.stackSplit = false
    eventManager:UnregisterForUpdate(moduleName .. "StackTracker")
end

local mementoTable =
{
    [10287] = GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_CAKE),
    [1167] = GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_PIE),
    [1168] = GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_MEAD),
    [479] = GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_WITCH),
}

--- Announces memento usage in chat.
function ChatAnnouncements.AnnounceMemento()
    local messageString = mementoTable[LUIE.LastMementoUsed] or nil
    if messageString == nil then
        LUIE.LastMementoUsed = 0
        return
    end

    local collectibleId = LUIE.LastMementoUsed
    local name = GetCollectibleName(collectibleId)
    local icon = GetCollectibleIcon(collectibleId)
    local link = GetCollectibleLink(collectibleId, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionCollectibleUse])

    local formattedIcon = ChatAnnouncements.SV.Collectibles.CollectibleUseIcon and ("|t16:16:" .. icon .. "|t ") or ""

    local message = zo_strformat(messageString, link, formattedIcon)
    local alert = zo_strformat(messageString, name, "")

    if message and ChatAnnouncements.SV.Collectibles.CollectibleUseCA or collectibleId > 0 then
        message = ChatAnnouncements.Colors.CollectibleUseColorize:Colorize(message)
        printToChat(message)
    end
    if alert and ChatAnnouncements.SV.Collectibles.CollectibleUseAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alert)
    end

    LUIE.LastMementoUsed = 0
end

--- Handles collectible usage events. Runs on the `EVENT_COLLECTIBLE_USE_RESULT` event.
--- @param eventCode number The event code that triggered this function
--- @param result CollectibleUsageBlockReason The result of the collectible usage attempt (COLLECTIBLE_USAGE_BLOCK_REASON_*)
--- @param isAttemptingActivation boolean
function ChatAnnouncements.CollectibleUsed(eventCode, result, isAttemptingActivation)
    if result ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
        return
    end
    local latency = GetLatency()
    latency = latency + 100
    LUIE_callLater(ChatAnnouncements.CollectibleResult, latency)
end

--- Processes the result of a collectible usage.
function ChatAnnouncements.CollectibleResult()
    ChatAnnouncements.AnnounceMemento()

    local newAssistant = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newCompanion = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newVanity = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newSpecial = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newHat = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newHair = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAIR, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newHeadMark = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newFacialHair = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newMajorAdorn = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newMinorAdorn = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newCostume = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newBodyMarking = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newSkin = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newPersonality = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
    local newPolymorph = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, GAMEPLAY_ACTOR_CATEGORY_PLAYER)

    if newAssistant ~= ChatAnnouncements.currentAssistant then
        if newAssistant == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentAssistant
        else
            ChatAnnouncements.lastCollectibleUsed = newAssistant
            -- ChatAnnouncements.currentCompanion = newAssistant -- fixes summoning assistant, if companion already summoned, from using sys message/icon of old companion instead of new assistant
        end
    end
    if newCompanion ~= ChatAnnouncements.currentCompanion then
        if newCompanion == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentCompanion
        else
            ChatAnnouncements.lastCollectibleUsed = newCompanion
        end
    end
    if newVanity ~= ChatAnnouncements.currentVanity then
        if newVanity == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentVanity
        else
            ChatAnnouncements.lastCollectibleUsed = newVanity
        end
    end
    if newSpecial ~= ChatAnnouncements.currentSpecial then
        if newSpecial == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentSpecial
        else
            ChatAnnouncements.lastCollectibleUsed = newSpecial
        end
    end
    if newHat ~= ChatAnnouncements.currentHat then
        if newHat == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentHat
        else
            ChatAnnouncements.lastCollectibleUsed = newHat
        end
    end
    if newHair ~= ChatAnnouncements.currentHair then
        if newHair == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentHair
        else
            ChatAnnouncements.lastCollectibleUsed = newHair
        end
    end
    if newHeadMark ~= ChatAnnouncements.currentHeadMark then
        if newHeadMark == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentHeadMark
        else
            ChatAnnouncements.lastCollectibleUsed = newHeadMark
        end
    end
    if newFacialHair ~= ChatAnnouncements.currentFacialHair then
        if newFacialHair == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentFacialHair
        else
            ChatAnnouncements.lastCollectibleUsed = newFacialHair
        end
    end
    if newMajorAdorn ~= ChatAnnouncements.currentMajorAdorn then
        if newMajorAdorn == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentMajorAdorn
        else
            ChatAnnouncements.lastCollectibleUsed = newMajorAdorn
        end
    end
    if newMinorAdorn ~= ChatAnnouncements.currentMinorAdorn then
        if newMinorAdorn == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentMinorAdorn
        else
            ChatAnnouncements.lastCollectibleUsed = newMinorAdorn
        end
    end
    if newCostume ~= ChatAnnouncements.currentCostume then
        if newCostume == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentCostume
        else
            ChatAnnouncements.lastCollectibleUsed = newCostume
        end
    end
    if newBodyMarking ~= ChatAnnouncements.currentBodyMarking then
        if newBodyMarking == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentBodyMarking
        else
            ChatAnnouncements.lastCollectibleUsed = newBodyMarking
        end
    end
    if newSkin ~= ChatAnnouncements.currentSkin then
        if newSkin == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentSkin
        else
            ChatAnnouncements.lastCollectibleUsed = newSkin
        end
    end
    if newPersonality ~= ChatAnnouncements.currentPersonality then
        if newPersonality == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentPersonality
        else
            ChatAnnouncements.lastCollectibleUsed = newPersonality
        end
    end
    if newPolymorph ~= ChatAnnouncements.currentPolymorph then
        if newPolymorph == 0 then
            ChatAnnouncements.lastCollectibleUsed = ChatAnnouncements.currentPolymorph
        else
            ChatAnnouncements.lastCollectibleUsed = newPolymorph
        end
    end

    ChatAnnouncements.currentAssistant = newAssistant
    ChatAnnouncements.currentCompanion = newCompanion
    ChatAnnouncements.currentVanity = newVanity
    ChatAnnouncements.currentSpecial = newSpecial
    ChatAnnouncements.currentHat = newHat
    ChatAnnouncements.currentHair = newHair
    ChatAnnouncements.currentHeadMark = newHeadMark
    ChatAnnouncements.currentFacialHair = newFacialHair
    ChatAnnouncements.currentMajorAdorn = newMajorAdorn
    ChatAnnouncements.currentMinorAdorn = newMinorAdorn
    ChatAnnouncements.currentCostume = newCostume
    ChatAnnouncements.currentBodyMarking = newBodyMarking
    ChatAnnouncements.currentSkin = newSkin
    ChatAnnouncements.currentPersonality = newPersonality
    ChatAnnouncements.currentPolymorph = newPolymorph

    -- If neither menu option is enabled, then bail out here
    if not (ChatAnnouncements.SV.Collectibles.CollectibleUseCA or ChatAnnouncements.SV.Collectibles.CollectibleUseAlert) then
        if not LUIE.SlashCollectibleOverride then
            ChatAnnouncements.lastCollectibleUsed = 0
            return
        end
    end

    if ChatAnnouncements.lastCollectibleUsed == 0 then
        LUIE.SlashCollectibleOverride = false
        return
    end
    local collectibleType = GetCollectibleCategoryType(ChatAnnouncements.lastCollectibleUsed)

    local message = ""
    local alert = ""
    local link = GetCollectibleLink(ChatAnnouncements.lastCollectibleUsed, ChatAnnouncements.linkBrackets[ChatAnnouncements.SV.BracketOptionCollectibleUse])
    local name = GetCollectibleName(ChatAnnouncements.lastCollectibleUsed)
    local nickname = GetCollectibleNickname(ChatAnnouncements.lastCollectibleUsed)
    local icon = GetCollectibleIcon(ChatAnnouncements.lastCollectibleUsed)
    local formattedIcon = ChatAnnouncements.SV.Collectibles.CollectibleUseIcon and ("|t16:16:" .. icon .. "|t ") or ""

    -- Vanity
    if collectibleType == COLLECTIBLE_CATEGORY_TYPE_VANITY_PET and (ChatAnnouncements.SV.Collectibles.CollectibleUseCategory10 or LUIE.SlashCollectibleOverride) then
        if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, GAMEPLAY_ACTOR_CATEGORY_PLAYER) > 0 then
            if ChatAnnouncements.SV.Collectibles.CollectibleUsePetNickname and nickname then
                message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_SUMMON_NN), link, nickname, formattedIcon)
                alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_SUMMON_NN), name, nickname, "")
            else
                message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_SUMMON), link, formattedIcon)
                alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_SUMMON), name, "")
            end
        else
            if ChatAnnouncements.SV.Collectibles.CollectibleUsePetNickname and nickname then
                message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_UNSUMMON_NN), link, nickname, formattedIcon)
                alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_UNSUMMON_NN), name, nickname, "")
            else
                message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_UNSUMMON), link, formattedIcon)
                alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_UNSUMMON), name, "")
            end
        end
    end

    -- Assistants / Companions
    if (collectibleType == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT or collectibleType == COLLECTIBLE_CATEGORY_TYPE_COMPANION) and (ChatAnnouncements.SV.Collectibles.CollectibleUseCategory7 or LUIE.SlashCollectibleOverride) then
        local activeAssistant = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        local activeCompanion = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, GAMEPLAY_ACTOR_CATEGORY_PLAYER)

        -- If summoning a new assistant/companion
        if (collectibleType == COLLECTIBLE_CATEGORY_TYPE_ASSISTANT and activeAssistant > 0) or
        (collectibleType == COLLECTIBLE_CATEGORY_TYPE_COMPANION and activeCompanion > 0) then
            message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_SUMMON), link, formattedIcon)
            alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_SUMMON), name, "")
        else
            -- If dismissing the current assistant/companion
            message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_UNSUMMON), link, formattedIcon)
            alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_UNSUMMON), name, "")
        end
    end

    -- Special / Appearance
    if collectibleType == COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE or collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAT or collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAIR or collectibleType == COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING or collectibleType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS or collectibleType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY or collectibleType == COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY or collectibleType == COLLECTIBLE_CATEGORY_TYPE_COSTUME or collectibleType == COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING or collectibleType == COLLECTIBLE_CATEGORY_TYPE_SKIN or collectibleType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY or collectibleType == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH then
        local categoryString = (collectibleType == COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE) and GetString(SI_COLLECTIBLECATEGORYTYPE30) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAT) and GetString(SI_COLLECTIBLECATEGORYTYPE10) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAIR) and GetString(SI_COLLECTIBLECATEGORYTYPE13) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING) and GetString(SI_COLLECTIBLECATEGORYTYPE17) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS) and GetString(SI_COLLECTIBLECATEGORYTYPE14) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY) and GetString(SI_COLLECTIBLECATEGORYTYPE15) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY) and GetString(SI_COLLECTIBLECATEGORYTYPE16) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_COSTUME) and GetString(SI_COLLECTIBLECATEGORYTYPE4) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING) and GetString(SI_COLLECTIBLECATEGORYTYPE18) or
            (collectibleType == COLLECTIBLE_CATEGORY_TYPE_SKIN) and GetString(SI_COLLECTIBLECATEGORYTYPE11) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY) and GetString(SI_COLLECTIBLECATEGORYTYPE9) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH) and GetString(SI_COLLECTIBLECATEGORYTYPE12)

        if collectibleType == (COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE and (ChatAnnouncements.SV.Collectibles.CollectibleUseCategory12 or LUIE.SlashCollectibleOverride)) or (collectibleType ~= COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE and (ChatAnnouncements.SV.Collectibles.CollectibleUseCategory3 or LUIE.SlashCollectibleOverride)) then
            if GetActiveCollectibleByType(GetCollectibleCategoryType(ChatAnnouncements.lastCollectibleUsed), GAMEPLAY_ACTOR_CATEGORY_PLAYER) > 0 then
                message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_USE_CATEGORY), categoryString, link, formattedIcon)
                alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_USE_CATEGORY), categoryString, name, "")
            else
                message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_DISABLE_CATEGORY), categoryString, link, formattedIcon)
                alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_DISABLE_CATEGORY), categoryString, name, "")
            end
        end
    end

    if message and ChatAnnouncements.SV.Collectibles.CollectibleUseCA or LUIE.SlashCollectibleOverride then
        message = ChatAnnouncements.Colors.CollectibleUseColorize:Colorize(message)
        printToChat(message)
    end
    if alert and ChatAnnouncements.SV.Collectibles.CollectibleUseAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alert)
    end

    ChatAnnouncements.lastCollectibleUsed = 0
    LUIE.SlashCollectibleOverride = false
end
