-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State
local I = ChatAnnouncements.Internal
local B = ChatAnnouncements.Brackets

local ColorizeColors = ChatAnnouncements.Colors

local Data = LuiData.Data
local Effects = Data.Effects
local Quests = Data.Quests

local ChatOutput = LUIE.ChatOutput
local string_format = string.format
local table_insert = table.insert
local table_concat = table.concat

local eventManager = GetEventManager()

local moduleName = LUIE.name .. "ChatAnnouncements"

------------------------------------------------
-- LOCAL (GLOBAL) VARIABLE SETUP ---------------
------------------------------------------------

-- Basic
S.g_activatedFirstLoad = true

-- Loot/Currency
S.g_savedPurchase = {}
S.g_savedLaunder = {}
S.g_savedItem = {}
S.g_isLooted = false                -- Toggled on to modify loot notification to "looted."
S.g_isPickpocketed = false          -- Toggled on to modify loot notification to "pickpocketed."
S.g_isStolen = false                -- Toggled on to modify loot notification to "stolen."
S.g_containerRecentlyOpened = false -- Toggled on when a container has been recently opened.
S.g_deferredContainerCurrency = {}  -- Gold/currency loot held until "You empty [container]" prints first
S.g_deferredContainerGoldThrottleAmount = 0
S.g_deferredContainerGoldThrottleTotal = 0
S.g_itemReceivedIsQuestReward = false  -- Toggled on to modify loot notification to "received." This overrides the "looted" tag applied to quest item rewards.
S.g_itemReceivedIsQuestAbandon = false -- Toggled on to modify remove notification to "removed" when a quest is abandoned.
S.g_itemsConfiscated = false           -- Toggled on when items are confiscated to modify the notification message.
S.g_weAreInAStore = false              -- Toggled on when the player opens a store.
S.g_weAreInAFence = false              -- Toggled on when the player opens a fence.
S.g_weAreInAGuildStore = false         -- Toggled on when the player opens a guild store.
S.g_itemWasDestroyed = false           -- Tracker for item being destroyed
S.g_packSiege = false                  -- Tracker for siege packed
S.g_lockpickBroken = false             -- Tracker for lockpick being broken
S.g_groupLootIndex = {}                -- Table to hold group member names for group loot display.
S.g_factionRepAnnounceDedupe = { delta = 0, time = 0 }
S.g_stackSplit = false                 -- Determines if we just split an inventory item stack
S.g_combinedRecipe = false             -- Determines if we just used an item that combines a recipe to stop the "learned" message from showing.
S.g_InventoryOn = false                -- Determines if Inventory Updates for Item Changes are on
S.g_bankOn = false                     -- Determines if Bank Updates for Item Changes are on

-- Currency Throttle
S.g_currencyGoldThrottleValue = 0 -- Held value for gold throttle (counter)
S.g_currencyGoldThrottleTotal = 0 -- Held value for gold throttle (total gold)
S.g_currencyAPThrottleValue = 0   -- Held value for AP throttle (counter)
S.g_currencyAPThrottleTotal = 0   -- Held value for AP throttle (total gold)
S.g_currencyTVThrottleValue = 0   -- Held value for TV throttle (counter)
S.g_currencyTVThrottleTotal = 0   -- Held value for TV throttle (total gold)

-- Loot (Crafting)
S.g_smithing = {}   -- Table for smithing mode
S.g_enchanting = {} -- Table for enchanting mode
S.g_enchant_prefix_pos = {}
S.g_enchant_prefix_neg = {}
S.g_smithing_prefix_pos = {}
S.g_smithing_prefix_neg = {}
S.g_itemCounterGain = 0        -- Counter value for items created via crafting
S.g_itemCounterGainTracker = 0 -- Tracker for how many items have been counted, when we reach a certain threshold, it is too many items to display so we cut the string off.
S.g_itemStringGain = ""        -- Counter value for items created via crafting
S.g_itemCounterLoss = 0        -- Counter value for items removed via crafting
S.g_itemCounterLossTracker = 0 -- Tracker for how many items have been counted, when we reach a certain threshold, it is too many items to display so we cut the string off.
S.g_itemStringLoss = ""        -- Combined string variable for items removed via crafting
S.g_oldItem = {}               -- Saved old item for crafting upgrades

-- Mail
S.g_mailCOD = 0            -- Tracks COD amount
S.g_postageAmount = 0      -- Tracks Postage amount
S.g_mailAmount = 0         -- Tracks sent money amount
S.g_mailCODPresent = false -- Tracks whether the currently opened mail has a COD value present. On receiving items from the mail this will modify the message displayed.
S.g_inMail = false         -- Toggled on when looting mail to prevent notable item display from hiding items acquired.
S.g_mailTarget = ""        -- Target of mail being sent.
S.g_mailStacksOut = {}     -- Table for storing items to be mailed out.
-- Take All loot queue: one entry per gold/attachment slot (mailId + sender), inbox index order at Take All start
S.g_mailLootQueue = {}
S.g_mailSenderMap = {}        -- mailId -> colored sender (filled on take-success; used for lookup)
S.g_mailDelayedLootLines = {} -- Batch Take All: lines buffered then printed sorted by mailId (CompareId64s)
S.g_mailLootLineSequence = 0
S.g_mailIsTakingMail = false
S.g_mailBatchTakeAll = false        -- Category Take All in progress (no S.g_mailTarget fallback)
S.g_mailIncomingCurrencySender = "" -- Per-line mail gold sender during batch Take All
S.g_mailPendingCurrencySender = ""  -- Set by EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS before currency update
S.g_mailPendingCurrencyMailId = nil -- mailId paired with pending currency sender (dedupe per mail)
S.g_mailPendingItemSender = ""      -- Legacy; prefer S.g_mailItemSenderFifo per attachment
S.g_mailItemSenderFifo = {}         -- FIFO { mailId, sender } per attachment line (LWC / rapid take)
S.g_mailNotifySuppressUntilMs = 0   -- Suppress Mail received/deleted while Loot Mail lines are in flight
local MAIL_CURRENCY_ANNOUNCE_DEDUPE_MS = 2500
local MAIL_NOTIFY_SUPPRESS_AFTER_LOOT_MS = 2000
S.g_lastMailCurrencyAnnounce = { amount = 0, senderKey = "", mailId = nil, timeMs = 0 }

local TIMED_ACTIVITY_PROGRESS_ANNOUNCE_DEDUPE_MS = 500
S.g_lastTimedActivityProgressAnnounce = {}

-- Disguise
S.g_currentDisguise = nil -- Holds current disguise itemId
S.g_disguiseState = nil   -- Holds current disguise state

-- Indexing
S.g_bankBag = nil
S.g_currentBankBagId = nil    -- actual bag id of current bank tab (BAG_BANK, BAG_FURNITURE_VAULT, house bank, etc.)
S.g_bankStacks = {}           -- Bank Inventory Index
S.g_banksubStacks = {}        -- Subscriber Bank Inventory Index
S.g_houseBags = {}            -- House Storage Index
S.g_furnitureVaultStacks = {} -- Furnishing Vault (BAG_FURNITURE_VAULT) index
S.g_equippedStacks = {}       -- Equipped Items Index
S.g_inventoryStacks = {}      -- Inventory Index
S.g_JusticeStacks = {}        -- Justice Items Index (only filled as a comparison table when items are confiscated)
S.g_guildBankCarry = nil      -- Saves item data when an item is removed/deposited into the guild bank.

-- Group
S.g_currentGroupLeaderRawName = nil     -- Tracks current Group Leader Name
S.g_currentGroupLeaderDisplayName = nil -- Tracks current Group Leader Display Name

-- LFG
S.g_currentActivityId = nil       -- current activity ID for LFG.
S.g_stopGroupLeaveQueue = false   -- Stops group notification messages from printing for a short time an LFG group is formed - Called when a ready check has the possible result of success.
S.g_lfgDisableGroupEvents = false -- Stops group notification messages from printing for a short time an LFG group is formed - Called when succesfully joining a new LFG activity.
S.g_joinLFGOverride = false       -- Toggled on to stop display of standard group join message when joining an LFG group. Instead an alternate message with the LFG activity name will display.
S.g_leaveLFGOverride = false      -- Toggled on to modify group leave message to display "You are no longer in an LFG group."
S.g_showActivityStatus = true     -- Variable to control display of LFG status
S.g_lfgHideStatusCancel = false   -- Hide the cancel message that can be triggered by someone dropping queue while in an existing group.
S.g_showRCUpdates = true          -- Variable to control display of LFG Ready Check Announcements
S.g_weDeclinedTheQueue = false    -- Flagged when we decline a ready check popup for LFG queue.
S.g_savedQueueValue = 0           -- Saved LFG queue status
S.g_rcSpamPrevention = false      -- Stops LFG failed ready checks from spamming the player

-- Guild
S.g_selectedGuild = 1          -- Set selected guild to 1 by default, whenever the player reloads their first guild will always be selected
S.g_pendingHeraldryCost = 0    -- Pending cost of heraldry change used to modify currency messages. TODO: Fix later
S.g_heraldrySaveGuildId = nil  -- Guild ID whose heraldry save was last initiated (apply or purchase); cleared after use in GuildHeraldrySaved
S.g_disableRankMessage = false -- Variable is toggled to true when the player modifies a guild memeber's rank, this prevents the normal rank change message from displaying.

-- Achievements
S.g_achievementLastPercentage = {} -- Here we will store last displayed percentage for achievement

-- Collectible Usage Tracking
S.currentAssistant = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentCompanion = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentVanity = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentSpecial = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentHat = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentHair = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAIR, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentHeadMark = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentFacialHair = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentMajorAdorn = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentMinorAdorn = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentCostume = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentBodyMarking = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentSkin = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentPersonality = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.currentPolymorph = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
S.lastCollectibleUsed = 0

-- Customized Actions (COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE) — one active collectible per harvest/ability slot
S.currentPlayerFxHarvest = {}
S.currentPlayerFxAbility = 0

--- @param harvestingType PlayerFxWhileHarvestingType
--- @return boolean
function I.IsPlayerFxHarvestTypeTracked(harvestingType)
    return harvestingType ~= PLAYER_FX_WHILE_HARVESTING_TYPE_NONE
        and harvestingType ~= PLAYER_FX_WHILE_HARVESTING_TYPE_TEMP_VALUE_1
        and harvestingType ~= PLAYER_FX_WHILE_HARVESTING_TYPE_TEMP_VALUE_2
        and harvestingType ~= PLAYER_FX_WHILE_HARVESTING_TYPE_TEMP_VALUE_3
end

--- @param harvestingType PlayerFxWhileHarvestingType
--- @return integer collectibleId
function I.GetActivePlayerFxHarvestCollectibleId(harvestingType)
    local total = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE)
    for i = 1, total do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE, i)
        if collectibleId and collectibleId > 0 then
            if  GetCollectiblePlayerFxOverrideType(collectibleId) == PLAYER_FX_OVERRIDE_TYPE_HARVEST
            and GetCollectiblePlayerFxWhileHarvestingType(collectibleId) == harvestingType
            and IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
                return collectibleId
            end
        end
    end
    return 0
end

--- @return integer collectibleId
function I.GetActivePlayerFxAbilityCollectibleId()
    local total = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE)
    for i = 1, total do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE, i)
        if collectibleId and collectibleId > 0 then
            if  GetCollectiblePlayerFxOverrideType(collectibleId) == PLAYER_FX_OVERRIDE_TYPE_ABILITY
            and IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
                return collectibleId
            end
        end
    end
    return 0
end

function I.InitPlayerFxOverrideState()
    for harvestingType = PLAYER_FX_WHILE_HARVESTING_TYPE_ITERATION_BEGIN, PLAYER_FX_WHILE_HARVESTING_TYPE_ITERATION_END do
        if I.IsPlayerFxHarvestTypeTracked(harvestingType) then
            S.currentPlayerFxHarvest[harvestingType] = I.GetActivePlayerFxHarvestCollectibleId(harvestingType)
        end
    end
    S.currentPlayerFxAbility = I.GetActivePlayerFxAbilityCollectibleId()
end

I.InitPlayerFxOverrideState()

-- Quest
S.g_stopDisplaySpam = false   -- Toggled on to stop spam display of EVENT_DISPLAY_ANNOUNCEMENTS from IC zone transitions.
--- @type  {[string]:{questType:QuestType,zoneDisplayType:ZoneDisplayType}}
S.g_questIndex = {}           -- Index of all current quests. Allows us to read the index so that all quest notifications can use the difficulty icon.
S.g_questItemAdded = {}       -- Hold index of Quest items that are added - Prevents pointless and annoying messages from appearing when the same quest item is immediately added and removed when quest updates.
S.g_questItemRemoved = {}     -- Hold index of Quest items that are removed - Prevents pointless and annoying messages from appearing when the same quest item is immediately added and removed when quest updates.
S.g_loginHideQuestLoot = true -- Set to true onPlayerActivated and toggled after 3 sec
S.g_talkingToNPC = false      -- Toggled when we're in dialogue with an NPC (EVENT_CHATTER_BEGIN & EVENT_CHATTER_END)

-- Trade
S.g_tradeTarget = ""      -- Saves name of target player being traded with.
S.g_tradeStacksIn = {}    -- Table for storing items to be traded in.
S.g_tradeStacksOut = {}   -- Table for storing items to be traded out.
S.g_inTrade = false       -- Toggled on when in a trade.

S.pendingHomeJump = false -- Set before RequestJumpToHouse from slash; cleared on EVENT_JUMP_FAILED.

-- Antiquities
S.g_weAreInADig = false -- When in a digsite.

---
--- @param currencyType CurrencyType
--- @return integer CurrencyType
I.GetCarriedCurrencyAmount = function (currencyType)
    return GetCurrencyAmount(currencyType, CURRENCY_LOCATION_CHARACTER)
end
------------------------------------------------
-- ITEM BLACKLIST ------------------------------
------------------------------------------------

-- List of items to whitelist as notable loot
S.g_notableIDs =
{
    [56862] = true, -- Fortified Nirncrux
    [56863] = true, -- Potent Nirncrux
    [68342] = true, -- Hakeijo
}

-- List of items that can be removed from the players equipped item slots.
S.g_removableIDs =
{
    [44486] = true, -- Prismatic Blade (Fighters Guild Quests)
    [44487] = true, -- Prismatic Greatblade (Fighters Guild Quests)
    [44488] = true, -- Prismatic Long Bow (Fighters Guild Quests)
    [44489] = true, -- Prismatic Flamestaff (Fighters Guild Quests)
    [33235] = true, -- Wabbajack (Mages Guild Quests)
}

-- List of items to blacklist as annoying loot
S.g_blacklistIDs =
{
    -- General
    [64713] = true, -- Laurel
    [64690] = true, -- Malachite Shard
    [69432] = true, -- Glass Style Motif Fragment

    -- Trial Plunder
    [114427] = true, -- Undaunted Plunder
    [81180] = true,  -- The Serpent's Egg-Tooth
    [74453] = true,  -- The Rid-Thar's Moon Pearls
    [87701] = true,  -- Star-Studded Champion's Baldric
    [87700] = true,  -- Periapt of Elinhir

    -- Trial Weekly Coffers
    [139664] = true, -- Mage's Ignorant Coffer
    [139674] = true, -- Saint's Beatified Coffer
    [139670] = true, -- Dro-m'Athra's Burnished Coffer
    [138711] = true, -- Welkynar's Grounded Coffer

    -- Transmutation Geodes
    [134583] = true, -- Transmutation Geode
    [134588] = true, -- Transmutation Geode
    [134590] = true, -- Transmutation Geode
    [134591] = true, -- Transmutation Geode
    [134595] = true, -- Tester's Infinite Transmutation Geode
    [134618] = true, -- Uncracked Transmutation Geode
    [134622] = true, -- Uncracked Transmutation Geode
    [134623] = true, -- Uncracked Transmutation Geode
    [140222] = true, -- 200 Transmute Crystals (This is probably just a test item)
}

--- @param value boolean
function ChatAnnouncements.SetPendingHomeJump(value)
    S.pendingHomeJump = value
end

--- @param message string
--- @param alertCategory integer
--- @param sound integer|nil
function ChatAnnouncements.AnnounceNotifyAlert(message, alertCategory, sound)
    if not ChatAnnouncements.SV or not ChatAnnouncements.SV.Notify then
        return
    end
    ZO_Alert(alertCategory or UI_ALERT_CATEGORY_ALERT, sound or SOUNDS.NONE, message)
end

--- @param message string
--- @param alertCategory integer
--- @param sound integer|nil
--- @param caEnabled boolean
--- @param alertEnabled boolean
function ChatAnnouncements.AnnounceNotify(message, alertCategory, sound, caEnabled, alertEnabled)
    if not ChatAnnouncements.SV or not ChatAnnouncements.SV.Notify then
        return
    end
    if ChatAnnouncements.Enabled and caEnabled then
        ChatOutput:Print(message, true)
    end
    if alertEnabled then
        ChatAnnouncements.AnnounceNotifyAlert(message, alertCategory, sound)
    end
end

--- @param message string
--- @param alertCategory integer
--- @param sound integer|nil
--- @param caKey string
--- @param alertKey string
function ChatAnnouncements.AnnounceNotifySetting(message, alertCategory, sound, caKey, alertKey)
    if not ChatAnnouncements.Enabled or not ChatAnnouncements.SV or not ChatAnnouncements.SV.Notify then
        return
    end
    local notify = ChatAnnouncements.SV.Notify
    ChatAnnouncements.AnnounceNotify(message, alertCategory, sound, notify[caKey], notify[alertKey])
end

local function CampaignQueueStateLabel(state)
    local stateText = GetString("SI_CAMPAIGNQUEUEREQUESTSTATETYPE", state)
    if stateText == nil or stateText == "" then
        return tostring(state)
    end
    return stateText
end

function ChatAnnouncements.OnCampaignQueueJoined(_, campaignId)
    local campaignName = GetCampaignName(campaignId)
    local message = zo_strformat(GetString(LUIE_STRING_CA_CAMPAIGN_QUEUE_JOINED), campaignName)
    ChatAnnouncements.AnnounceNotifySetting(message, UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "CampaignQueueCA", "CampaignQueueAlert")
end

function ChatAnnouncements.OnCampaignQueueLeft(_, campaignId)
    local campaignName = GetCampaignName(campaignId)
    local message = zo_strformat(GetString(LUIE_STRING_CA_CAMPAIGN_QUEUE_LEFT), campaignName)
    ChatAnnouncements.AnnounceNotifySetting(message, UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "CampaignQueueCA", "CampaignQueueAlert")
end

function ChatAnnouncements.OnCampaignQueueStateChanged(_, campaignId, isGroup, state)
    local campaignName = GetCampaignName(campaignId)
    local stateLabel = CampaignQueueStateLabel(state)
    local message = zo_strformat(GetString(LUIE_STRING_CA_CAMPAIGN_QUEUE_STATE), campaignName, stateLabel)
    ChatAnnouncements.AnnounceNotifySetting(message, UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, "CampaignQueueCA", "CampaignQueueAlert")
end

function ChatAnnouncements.RegisterCampaignQueueEvents()
    eventManager:RegisterForEvent(moduleName, EVENT_CAMPAIGN_QUEUE_JOINED, ChatAnnouncements.OnCampaignQueueJoined)
    eventManager:RegisterForEvent(moduleName, EVENT_CAMPAIGN_QUEUE_LEFT, ChatAnnouncements.OnCampaignQueueLeft)
    eventManager:RegisterForEvent(moduleName, EVENT_CAMPAIGN_QUEUE_STATE_CHANGED, ChatAnnouncements.OnCampaignQueueStateChanged)
end

function ChatAnnouncements.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIE.SV.CharacterSpecificSV
    if isCharacterSpecific then
        ChatAnnouncements.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.ChatAnnouncements, LUIE.SVVer, nil, ChatAnnouncements.Defaults, LUIE.SavedVarsProfile)
    else
        ChatAnnouncements.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.ChatAnnouncements, LUIE.SVVer, nil, ChatAnnouncements.Defaults, LUIE.SavedVarsProfile)
    end

    ChatAnnouncements.RefreshMessageFormatDefaultsTable()
    ChatAnnouncements.NormalizeStoredMessageFormats()

    ChatAnnouncements.SV.Social = ChatAnnouncements.SV.Social or {}
    if ChatAnnouncements.SV.Social.FriendStatusNameFormat == nil then
        ChatAnnouncements.SV.Social.FriendStatusNameFormat = ChatAnnouncements.Defaults.Social.FriendStatusNameFormat
    end

    ChatAnnouncements.InvalidateQuestCounterFilterCache()

    -- Some modules might need to pull some of the color settings from CA so we want these to always be set regardless of CA module being enabled/disabled.
    ChatAnnouncements.RegisterColorEvents()
    -- Always register this function for other components to use
    eventManager:RegisterForEvent(moduleName, EVENT_COLLECTIBLE_USE_RESULT, ChatAnnouncements.CollectibleUsed)

    -- Disable module if setting not toggled on
    if not enabled then
        ChatAnnouncements.Enabled = false
        return
    end
    ChatAnnouncements.Enabled = true

    -- Get current group leader
    S.g_currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
    S.g_currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
    S.g_currentActivityId = GetCurrentLFGActivityId()

    -- Posthook Crafting Interface
    ChatAnnouncements.CraftModeOverrides()
    eventManager:RegisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function ()
        ChatAnnouncements.CraftModeOverrides()
    end)

    -- Register events
    ChatAnnouncements.RegisterGoldEvents()
    ChatAnnouncements.RegisterLootEvents()
    ChatAnnouncements.RegisterLootHistoryHooks()
    ChatAnnouncements.RegisterMailEvents()
    ChatAnnouncements.RegisterXPEvents()
    ChatAnnouncements.RegisterAchievementsEvent()
    -- TODO: Possibly don't register these unless enabled, I'm not sure -- at least move to better sorted order
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, ChatAnnouncements.StorageBag)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_BANK_CAPACITY_CHANGED, ChatAnnouncements.StorageBank)
    -- TODO: Move these too:
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_MOUSE_UP_EVENT, LUIE.HandleClickEvent)
    LINK_HANDLER:RegisterCallback(LINK_HANDLER.LINK_CLICKED_EVENT, LUIE.HandleClickEvent)

    -- TODO: also move this
    eventManager:RegisterForEvent(moduleName, EVENT_SKILL_XP_UPDATE, ChatAnnouncements.SkillXPUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, ChatAnnouncements.OnPlayerActivated)

    -- TODO: Maybe move this, is needed for ALL INVENTORY & QUEST
    eventManager:RegisterForEvent(moduleName, EVENT_CHATTER_BEGIN, ChatAnnouncements.OnChatterBegin)
    eventManager:RegisterForEvent(moduleName, EVENT_CHATTER_END, ChatAnnouncements.OnChatterEnd)

    -- TEMP: Register Antiquity Dig Toggle
    eventManager:RegisterForEvent(moduleName, EVENT_ANTIQUITY_DIGGING_READY_TO_PLAY, ChatAnnouncements.OnDigStart)
    eventManager:RegisterForEvent(moduleName, EVENT_ANTIQUITY_DIGGING_GAME_OVER, ChatAnnouncements.OnDigEnd)

    -- Timed Activity
    if IsTimedActivitySystemAvailable() then
        eventManager:UnregisterForEvent(moduleName, EVENT_TIMED_ACTIVITY_TRACKING_UPDATED)
        eventManager:UnregisterForEvent(moduleName, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED)
        eventManager:RegisterForEvent(moduleName, EVENT_TIMED_ACTIVITY_TRACKING_UPDATED, ChatAnnouncements.OnTimedActivityTrackingUpdated)
        eventManager:RegisterForEvent(moduleName, EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED, ChatAnnouncements.OnTimedActivityProgressUpdated)
    end

    -- Promotional Events Activity
    eventManager:RegisterForEvent(moduleName, EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED, ChatAnnouncements.OnPromotionalEventsActivityProgressUpdated)

    eventManager:RegisterForEvent(moduleName, EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED, ChatAnnouncements.OnCraftedAbilityLockStateChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED, ChatAnnouncements.OnCraftedAbilityScriptLockStateChanged)

    ChatAnnouncements.RegisterGuildEvents()
    ChatAnnouncements.RegisterSocialEvents()
    ChatAnnouncements.RegisterCampaignQueueEvents()
    ChatAnnouncements.RegisterDisguiseEvents()
    ChatAnnouncements.RegisterQuestEvents()

    ChatAnnouncements.HookFunction()

    -- Index members for Group Loot
    ChatAnnouncements.IndexGroupLoot()
end

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENT HANDLER AND COLOR REGISTRATION -----------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

function ChatAnnouncements.RegisterColorEvents()
    local SV = ChatAnnouncements.SV -- store the SV table in a local variable for better performance

    ColorizeColors.CurrencyColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyColor))
    ColorizeColors.CurrencyUpColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyColorUp))
    ColorizeColors.CurrencyDownColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyColorDown))
    ColorizeColors.CollectibleColorize1 = ZO_ColorDef:New(unpack(SV.Collectibles.CollectibleColor1))
    ColorizeColors.CollectibleColorize2 = ZO_ColorDef:New(unpack(SV.Collectibles.CollectibleColor2))
    ColorizeColors.CollectibleUseColorize = ZO_ColorDef:New(unpack(SV.Collectibles.CollectibleUseColor))
    ColorizeColors.CurrencyGoldColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyGoldColor))
    ColorizeColors.CurrencyAPColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyAPColor))
    ColorizeColors.CurrencyTVColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTVColor))
    ColorizeColors.CurrencyWVColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyWVColor))
    ColorizeColors.CurrencyOutfitTokenColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyOutfitTokenColor))
    ColorizeColors.CurrencyUndauntedColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyUndauntedColor))
    ColorizeColors.CurrencyTransmuteColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTransmuteColor))
    ColorizeColors.CurrencyCrownsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyCrownsColor))
    ColorizeColors.CurrencyCrownGemsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyCrownGemsColor))
    ColorizeColors.CurrencyEndlessColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyEndlessColor))
    ColorizeColors.CurrencySealsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencySealsColor))
    ColorizeColors.CurrencyTradeBarsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTradeBarsColor))
    ColorizeColors.CurrencyTomePointsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTomePointsColor))
    ColorizeColors.CurrencyTomePointCachesColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTomePointCachesColor))
    ColorizeColors.CurrencyTomeTokensColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTomeTokensColor))
    ColorizeColors.CurrencyTomeChallengeRerollsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyTomeChallengeRerollsColor))
    ColorizeColors.DisguiseAlertColorize = ZO_ColorDef:New(unpack(SV.Notify.DisguiseAlertColor))
    ColorizeColors.AchievementColorize1 = ZO_ColorDef:New(unpack(SV.Achievement.AchievementColor1))
    ColorizeColors.AchievementColorize2 = ZO_ColorDef:New(unpack(SV.Achievement.AchievementColor2))
    ColorizeColors.LorebookColorize1 = ZO_ColorDef:New(unpack(SV.Lorebooks.LorebookColor1))
    ColorizeColors.LorebookColorize2 = ZO_ColorDef:New(unpack(SV.Lorebooks.LorebookColor2))
    ColorizeColors.ExperienceMessageColorize = ZO_ColorDef:New(unpack(SV.XP.ExperienceColorMessage)):ToHex()
    ColorizeColors.ExperienceNameColorize = ZO_ColorDef:New(unpack(SV.XP.ExperienceColorName)):ToHex()
    ColorizeColors.ExperienceLevelUpColorize = ZO_ColorDef:New(unpack(SV.XP.ExperienceLevelUpColor))
    ColorizeColors.SkillPointColorize1 = ZO_ColorDef:New(unpack(SV.Skills.SkillPointColor1))
    ColorizeColors.SkillPointColorize2 = ZO_ColorDef:New(unpack(SV.Skills.SkillPointColor2))
    ColorizeColors.SkillLineColorize = ZO_ColorDef:New(unpack(SV.Skills.SkillLineColor))
    ColorizeColors.SkillGuildColorize = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColor)):ToHex()
    ColorizeColors.SkillGuildColorizeFG = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorFG)):ToHex()
    ColorizeColors.SkillGuildColorizeMG = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorMG)):ToHex()
    ColorizeColors.SkillGuildColorizeUD = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorUD)):ToHex()
    ColorizeColors.SkillGuildColorizeTG = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorTG)):ToHex()
    ColorizeColors.SkillGuildColorizeDB = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorDB)):ToHex()
    ColorizeColors.SkillGuildColorizePO = ZO_ColorDef:New(unpack(SV.Skills.SkillGuildColorPO)):ToHex()
    ColorizeColors.QuestColorLocNameColorize = ZO_ColorDef:New(unpack(SV.Quests.QuestColorLocName)):ToHex()
    ColorizeColors.QuestColorLocDescriptionColorize = ZO_ColorDef:New(unpack(SV.Quests.QuestColorLocDescription)):ToHex()
    ColorizeColors.QuestColorQuestNameColorize = ZO_ColorDef:New(unpack(SV.Quests.QuestColorName))
    ColorizeColors.QuestColorQuestDescriptionColorize = ZO_ColorDef:New(unpack(SV.Quests.QuestColorDescription)):ToHex()
    ColorizeColors.StorageRidingColorize = ZO_ColorDef:New(unpack(SV.Notify.StorageRidingColor))
    ColorizeColors.StorageRidingBookColorize = ZO_ColorDef:New(unpack(SV.Notify.StorageRidingBookColor))
    ColorizeColors.StorageBagColorize = ZO_ColorDef:New(unpack(SV.Notify.StorageBagColor))
    ColorizeColors.GuildColorize = ZO_ColorDef:New(unpack(SV.Social.GuildColor))
    ColorizeColors.AntiquityColorize = ZO_ColorDef:New(unpack(SV.Antiquities.AntiquityColor))
end

local function GetChatOutputSocialSettings()
    return LUIE.SV and LUIE.SV.ChatOutput and LUIE.SV.ChatOutput.Social
end

function ChatAnnouncements.RegisterSocialEvents()
    eventManager:RegisterForEvent(moduleName, EVENT_FRIEND_ADDED, ChatAnnouncements.FriendAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_FRIEND_REMOVED, ChatAnnouncements.FriendRemoved)
    eventManager:RegisterForEvent(moduleName, EVENT_INCOMING_FRIEND_INVITE_ADDED, ChatAnnouncements.FriendInviteAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_IGNORE_ADDED, ChatAnnouncements.IgnoreAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_IGNORE_REMOVED, ChatAnnouncements.IgnoreRemoved)
    eventManager:RegisterForEvent(moduleName, EVENT_FRIEND_PLAYER_STATUS_CHANGED, ChatAnnouncements.FriendPlayerStatus)
    ChatAnnouncements.RegisterSocialChatRouter()
end

function ChatAnnouncements.RegisterQuestEvents()
    eventManager:RegisterForEvent(moduleName, EVENT_QUEST_SHARED, ChatAnnouncements.QuestShared)
    -- Create a table for quests
    for i = 1, MAX_JOURNAL_QUESTS do
        if IsValidQuestIndex(i) then
            local name = GetJournalQuestName(i)
            local questType = GetJournalQuestType(i)
            local zoneDisplayType = GetJournalQuestZoneDisplayType(i)

            if name == "" then
                name = GetString(SI_QUEST_JOURNAL_UNKNOWN_QUEST_NAME)
            end

            S.g_questIndex[name] =
            {
                questType = questType,
                zoneDisplayType = zoneDisplayType,
            }
        end
    end
end

function ChatAnnouncements.RegisterGuildEvents()
    -- TODO: Possibly implement conditionals here again in the future
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_SELF_JOINED_GUILD, ChatAnnouncements.GuildAddedSelf)
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_INVITE_ADDED, ChatAnnouncements.GuildInviteAdded)
    eventManager:RegisterForEvent(moduleName, EVENT_GUILD_MEMBER_RANK_CHANGED, ChatAnnouncements.GuildRankChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_HERALDRY_SAVED, ChatAnnouncements.GuildHeraldrySaved) -- TODO: Fix later
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

function ChatAnnouncements.RegisterXPEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_EXPERIENCE_GAIN)
    if ChatAnnouncements.SV.XP.Experience or ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
        eventManager:RegisterForEvent(moduleName, EVENT_EXPERIENCE_GAIN, ChatAnnouncements.OnExperienceGain)
    end
end

function ChatAnnouncements.RegisterGoldEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_CURRENCY_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_PENDING_CURRENCY_REWARD_CACHED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_ADDED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_REMOVED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_CLOSE_MAILBOX)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_SEND_SUCCESS)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_COD_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_REMOVED)

    eventManager:RegisterForEvent(moduleName, EVENT_CURRENCY_UPDATE, ChatAnnouncements.OnCurrencyUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PENDING_CURRENCY_REWARD_CACHED, ChatAnnouncements.OnPendingCurrencyRewardCached)
    eventManager:RegisterForEvent(moduleName, EVENT_LOOT_UPDATED, ChatAnnouncements.OnLootUpdated)
    eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_ADDED, ChatAnnouncements.OnMailAttach)
    eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_REMOVED, ChatAnnouncements.OnMailAttachRemove)
    eventManager:RegisterForEvent(moduleName, EVENT_MAIL_CLOSE_MAILBOX, ChatAnnouncements.OnMailCloseBox)
    eventManager:RegisterForEvent(moduleName, EVENT_MAIL_SEND_SUCCESS, ChatAnnouncements.OnMailSuccess)
    eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED, ChatAnnouncements.MailMoneyChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_MAIL_COD_CHANGED, ChatAnnouncements.MailCODChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_MAIL_REMOVED, ChatAnnouncements.MailRemoved)
end

function ChatAnnouncements.RegisterMailEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_READABLE)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_ADDED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_REMOVED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_OPEN_MAILBOX)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_CLOSE_MAILBOX)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_SEND_SUCCESS)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_COD_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_REMOVED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_INBOX_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootMail then
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_READABLE, ChatAnnouncements.OnMailReadable)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, ChatAnnouncements.OnMailTakeAttachedItem)
    end
    if ChatAnnouncements.SV.Inventory.LootMail or ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_TAKE_ATTACHED_MONEY_SUCCESS, ChatAnnouncements.OnMailTakeAttachedMoney)
    end
    eventManager:RegisterForEvent(moduleName, EVENT_MAIL_TAKE_ALL_ATTACHMENTS_IN_CATEGORY_RESPONSE, ChatAnnouncements.OnMailTakeAllResponse)
    ChatAnnouncements.InstallTakeAllMailHook()
    if ChatAnnouncements.SV.Inventory.LootMail or ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_ADDED, ChatAnnouncements.OnMailAttach)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_REMOVED, ChatAnnouncements.OnMailAttachRemove)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_SEND_SUCCESS, ChatAnnouncements.OnMailSuccess)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED, ChatAnnouncements.MailMoneyChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_COD_CHANGED, ChatAnnouncements.MailCODChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_REMOVED, ChatAnnouncements.MailRemoved)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_INBOX_UPDATE, ChatAnnouncements.OnMailInboxUpdate)
    end
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootMail or ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_OPEN_MAILBOX, ChatAnnouncements.OnMailOpenBox)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_CLOSE_MAILBOX, ChatAnnouncements.OnMailCloseBox)
    end
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
    eventManager:UnregisterForEvent(moduleName, EVENT_FURNITURE_ITEMS_TRANSFERRED_TO_FURNITURE_VAULT)
    -- CRAFT
    eventManager:UnregisterForEvent(moduleName, EVENT_CRAFTING_STATION_INTERACT)
    eventManager:UnregisterForEvent(moduleName, EVENT_END_CRAFTING_STATION_INTERACT)
    -- TRADE
    eventManager:UnregisterForEvent(moduleName, EVENT_TRADE_ITEM_ADDED)
    eventManager:UnregisterForEvent(moduleName, EVENT_TRADE_ITEM_REMOVED)
    -- JUSTICE
    eventManager:UnregisterForEvent(moduleName, EVENT_JUSTICE_STOLEN_ITEMS_REMOVED)
    eventManager:UnregisterForEvent(moduleName .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    -- LOOT FAILED
    eventManager:UnregisterForEvent(moduleName, EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_IS_FULL)
    eventManager:UnregisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ADVENTURE_ZONE_FACTION_REPUTATION_CHANGED)

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
        S.g_equippedStacks = {}
        S.g_inventoryStacks = {}
        ChatAnnouncements.IndexEquipped()
        ChatAnnouncements.IndexInventory()
    end
    if ChatAnnouncements.SV.Inventory.Loot then
        eventManager:RegisterForEvent(moduleName, EVENT_ADVENTURE_ZONE_FACTION_REPUTATION_CHANGED, ChatAnnouncements.OnAdventureZoneFactionReputationChanged)
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
        eventManager:RegisterForEvent(moduleName, EVENT_FURNITURE_ITEMS_TRANSFERRED_TO_FURNITURE_VAULT, ChatAnnouncements.OnFurnitureItemsTransferredToVault)
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
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootConfiscate or ChatAnnouncements.SV.Notify.NotificationConfiscateCA or ChatAnnouncements.SV.Notify.NotificationConfiscateAlert then
        eventManager:RegisterForEvent(moduleName .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ChatAnnouncements.OnActiveWeaponPairChanged)
    end

    --[[if ChatAnnouncements.SV.ShowLootFail then
        eventManager:RegisterForEvent(moduleName, EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL, ChatAnnouncements.InventoryFullQuest)
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_IS_FULL, ChatAnnouncements.InventoryFull)
        eventManager:RegisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED, ChatAnnouncements.LootItemFailed)
    end]]
end

function ChatAnnouncements.RegisterLootHistoryHooks()
    -- See HookFunction for rationale: ZO_PostHook is multiplicative; sentinel
    -- prevents double-fire if RegisterLootHistoryHooks is invoked more than once.
    if ChatAnnouncements._lootHistoryHooksInstalled then
        return
    end
    if ZO_LootHistory_Shared and ZO_LootHistory_Shared.AddAdventureZoneFactionReputation then
        ZO_PostHook(ZO_LootHistory_Shared, "AddAdventureZoneFactionReputation", function (_, reputationAdded)
            ChatAnnouncements.QueueAdventureZoneFactionReputationGain(reputationAdded)
        end)
        ChatAnnouncements._lootHistoryHooksInstalled = true
    end
end

function ChatAnnouncements.RegisterDisguiseEvents()
    eventManager:UnregisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED)
    if ChatAnnouncements.SV.Notify.DisguiseCA or ChatAnnouncements.SV.Notify.DisguiseCSA or ChatAnnouncements.SV.Notify.DisguiseAlert or ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnCSA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
        eventManager:RegisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, ChatAnnouncements.DisguiseState)
        eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        S.g_currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0 -- Get the currently equipped disguise itemId if any
        if S.g_activatedFirstLoad then
            S.g_disguiseState = 0
            S.g_activatedFirstLoad = false
        else
            S.g_disguiseState = GetUnitDisguiseState("player") -- Get current player disguise state
            if S.g_disguiseState > 0 then
                S.g_disguiseState = 1                          -- Simplify all the various states into a basic 0 = false, 1 = true value
            end
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

--- Build a display-name chat link, or plain linkText if undecoratedDisplayName is missing (avoids malformed |H1:display|h links).
--- @param linkText string Text shown for the link
--- @param undecoratedDisplayName string|nil Undecorated @name stored in link data (must be non-empty for a link)
--- @return string
function ChatAnnouncements.CreateDisplayNameLink(linkText, undecoratedDisplayName)
    if undecoratedDisplayName == nil or undecoratedDisplayName == "" then
        return linkText or ""
    end
    if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
        return ZO_LinkHandler_CreateLinkWithoutBrackets(linkText, nil, DISPLAY_NAME_LINK_TYPE, undecoratedDisplayName)
    end
    return ZO_LinkHandler_CreateLink(linkText, nil, DISPLAY_NAME_LINK_TYPE, undecoratedDisplayName)
end

--- Build a character chat link, or empty string if characterName is missing.
--- @param characterName string|nil
--- @return string
function ChatAnnouncements.CreateCharacterLink(characterName)
    if characterName == nil or characterName == "" then
        return ""
    end
    if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
        return ZO_LinkHandler_CreateLinkWithoutBrackets(characterName, nil, CHARACTER_LINK_TYPE, characterName)
    end
    return ZO_LinkHandler_CreateLink(characterName, nil, CHARACTER_LINK_TYPE, characterName)
end

local function NameFieldNonEmpty(name)
    return name ~= nil and name ~= ""
end

-- Called by most functions that use character or display name to resolve LINK display method.
function ChatAnnouncements.ResolveNameLink(characterName, displayName)
    local hasChar = NameFieldNonEmpty(characterName)
    local hasDisplay = NameFieldNonEmpty(displayName)
    local opt = ChatAnnouncements.SV.ChatPlayerDisplayOptions

    if opt == 1 then
        if hasDisplay then
            return ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        end
        if hasChar then
            return ChatAnnouncements.CreateCharacterLink(characterName)
        end
        return ""
    elseif opt == 2 then
        if hasChar then
            return ChatAnnouncements.CreateCharacterLink(characterName)
        end
        if hasDisplay then
            return ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        end
        return ""
    elseif opt == 3 then
        if hasDisplay then
            local displayBothString = zo_strformat("<<1>><<2>>", hasChar and characterName or "", displayName)
            return ChatAnnouncements.CreateDisplayNameLink(displayBothString, displayName)
        end
        if hasChar then
            return ChatAnnouncements.CreateCharacterLink(characterName)
        end
        return ""
    end
    return ""
end

-- Called by most functions that use character or display name to resolve NON-LINK display method (mostly used for alerts).
function ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
    local hasChar = NameFieldNonEmpty(characterName)
    local hasDisplay = NameFieldNonEmpty(displayName)
    local opt = ChatAnnouncements.SV.ChatPlayerDisplayOptions

    if opt == 1 then
        return (hasDisplay and displayName) or (hasChar and characterName) or ""
    elseif opt == 2 then
        return (hasChar and characterName) or (hasDisplay and displayName) or ""
    elseif opt == 3 then
        return zo_strformat("<<1>><<2>>", hasChar and characterName or "", hasDisplay and displayName or "")
    end
    return ""
end

function ChatAnnouncements.OnDigStart()
    S.g_weAreInADig = true
end

function ChatAnnouncements.OnDigEnd()
    zo_callLater(function ()
                     S.g_weAreInADig = false
                 end, 1000)
end

-- TODO: Fix later
function ChatAnnouncements.GuildHeraldrySaved()
    if ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        local value = S.g_pendingHeraldryCost > 0 and S.g_pendingHeraldryCost or 1000
        local type = "LUIE_CURRENCY_HERALDRY"
        local formattedValue = nil -- Un-needed, we're not going to try to show the total guild bank gold here.
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(value)
        local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and "|t16:16:/esoui/art/currency/currency_gold.dds|t" or ""
        local currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyGoldName"), value)
        local currencyTotal = nil
        local messageTotal = ""
        local messageChange = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_HERALDRY)
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
    end

    local id = S.g_heraldrySaveGuildId or S.g_selectedGuild
    if id ~= nil then
        local guildName = GetGuildName(id)

        local guildAlliance = GetGuildAlliance(id)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if ChatAnnouncements.SV.Social.GuildManageCA then
            local finalMessage = zo_strformat(GetString(LUIE_STRING_CA_GUILD_HERALDRY_UPDATE), guildNameAlliance)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Social.GuildManageAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_HERALDRY_UPDATE), guildNameAllianceAlert))
        end
    end
    S.g_heraldrySaveGuildId = nil
end

-- Copied from Writ Creator for CSA handling purposes - Only called when WritCreater is detected so shouldn't cause issues
function I.isQuestWritQuest(questId)
    local writs = WritCreater.writSearch()
    for k, v in pairs(writs) do
        if v == questId then
            return true
        end
    end
end

-- Copied from Writ Creator for CSA handling purposes - Only called when WritCreater is detected so shouldn't cause issues
function I.rejectQuest(questIndex)
    for itemLink, _ in pairs(WritCreater:GetSettings().skipItemQuests) do
        if not WritCreater:GetSettings().skipItemQuests[itemLink] then
            for i = 1, GetJournalQuestNumConditions(questIndex, QUEST_MAIN_STEP_INDEX) do
                if DoesItemLinkFulfillJournalQuestCondition(itemLink, questIndex, 1, i) then
                    return itemLink
                end
            end
        end
    end
    return false
end

function ChatAnnouncements.GuildRanksSaved(eventId, guildId)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

    if ChatAnnouncements.SV.Social.GuildManageCA then
        local finalMessage = zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANKS_UPDATE), guildNameAlliance)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "NOTIFICATION", isSystem = true }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    if ChatAnnouncements.SV.Social.GuildManageAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANKS_UPDATE), guildNameAllianceAlert))
    end
end

function ChatAnnouncements.GuildRankSaved(eventId, guildId, rankIndex)
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
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon1, 16, 16), rankName)) or (guildColor:Colorize(rankName))
    local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon1, "100%", "100%", rankName) or rankName

    if ChatAnnouncements.SV.Social.GuildManageCA then
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UPDATE), rankSyntax, guildNameAlliance), true)
    end
    if ChatAnnouncements.SV.Social.GuildManageAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UPDATE), rankSyntaxAlert, guildNameAllianceAlert))
    end
end

function ChatAnnouncements.GuildTextChanged(eventId, guildId)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    -- Depending on event code set message context.
    local messageString = eventId == EVENT_GUILD_DESCRIPTION_CHANGED and LUIE_STRING_CA_GUILD_DESCRIPTION_CHANGED or EVENT_GUILD_MOTD_CHANGED and LUIE_STRING_CA_GUILD_MOTD_CHANGED or nil

    if messageString ~= nil then
        if ChatAnnouncements.SV.Social.GuildManageCA then
            local finalMessage = zo_strformat(GetString(messageString), guildNameAlliance)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Social.GuildManageAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(messageString), guildNameAllianceAlert))
        end
    end
end

function ChatAnnouncements.GuildRankChanged(eventId, guildId, displayName, newRank)
    -- Don't show this for the player since EVENT_GUILD_PLAYER_RANK_CHANGED will handle that
    if displayName == LUIE.PlayerDisplayName then
        return
    end
    -- If the player just updated someones rank then we hide this generic message.
    if S.g_disableRankMessage == true then
        S.g_disableRankMessage = false
        return
    end

    local memberIndex = GetPlayerGuildMemberIndex(guildId)
    local rankIndex = select(3, GetGuildMemberInfo(guildId, memberIndex))

    local hasPermission1 = DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_PROMOTE)
    local hasPermission2 = DoesGuildRankHavePermission(guildId, rankIndex, GUILD_PERMISSION_DEMOTE)

    if ((hasPermission1 or hasPermission2) and ChatAnnouncements.SV.Social.GuildRankDisplayOptions == 2) or (ChatAnnouncements.SV.Social.GuildRankDisplayOptions == 3) then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        local rankText = GetFinalGuildRankName(guildId, newRank)

        local icon = GetFinalGuildRankTextureSmall(guildId, newRank)
        local guildName = GetGuildName(guildId)

        local guilds = GetNumGuilds()
        for i = 1, guilds do
            local id = GetGuildId(i)
            local name = GetGuildName(id)

            local guildAlliance = GetGuildAlliance(id)
            local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
            local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
            local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
            local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
            local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

            if guildName == name then
                if ChatAnnouncements.SV.Social.GuildRankCA then
                    ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED), displayNameLink, guildNameAlliance, rankSyntax), true)
                end
                if ChatAnnouncements.SV.Social.GuildRankAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED), displayName, guildNameAllianceAlert, rankSyntaxAlert))
                end
                break
            end
        end
    end
end

function ChatAnnouncements.GuildPlayerRankChanged(eventId, guildId, rankIndex, guildRankChangeAction)
    local rankText = GetFinalGuildRankName(guildId, rankIndex)
    local icon = GetFinalGuildRankTextureSmall(guildId, rankIndex)
    local guildName = GetGuildName(guildId)

    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
    local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

    local syntax
    if guildRankChangeAction == GUILD_RANK_CHANGE_ACTION_PROMOTE then
        if ChatAnnouncements.SV.Social.GuildRankCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UP_SELF), rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_UP_SELF), rankSyntaxAlert, guildNameAllianceAlert))
        end
    elseif guildRankChangeAction == GUILD_RANK_CHANGE_ACTION_DEMOTE then
        if ChatAnnouncements.SV.Social.GuildRankCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_DOWN_SELF), rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_DOWN_SELF), rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
end

function ChatAnnouncements.GuildMemberPromoteSuccessful(eventId, displayName, newRankIndex, guildId)
    if newRankIndex > 0 then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        local rankText = GetFinalGuildRankName(guildId, newRankIndex)
        local icon = GetFinalGuildRankTextureSmall(guildId, newRankIndex)
        local guildName = GetGuildName(guildId)

        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
        local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
        local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

        if ChatAnnouncements.SV.Social.GuildRankCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_PROMOTE), displayNameLink, rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_PROMOTE), displayName, rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
    S.g_disableRankMessage = true
end

function ChatAnnouncements.GuildMemberDemoteSuccessful(eventId, displayName, newRankIndex, guildId)
    if newRankIndex <= GetNumGuildRanks(guildId) then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        local rankText = GetFinalGuildRankName(guildId, newRankIndex)
        local icon = GetFinalGuildRankTextureSmall(guildId, newRankIndex)
        local guildName = GetGuildName(guildId)

        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
        local rankSyntax = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(icon, 16, 16), rankText)) or (guildColor:Colorize(rankText))
        local rankSyntaxAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(icon, "100%", "100%", rankText) or rankText

        if ChatAnnouncements.SV.Social.GuildRankCA then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_DEMOTE), displayNameLink, rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_DEMOTE), displayName, rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
    S.g_disableRankMessage = true
end

-- EVENT_GUILD_SELF_JOINED_GUILD
function ChatAnnouncements.GuildAddedSelf(eventId, guildId, guildName)
    local guilds = GetNumGuilds()
    for i = 1, guilds do
        local id = GetGuildId(i)
        local name = GetGuildName(id)

        local guildAlliance = GetGuildAlliance(id)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if guildName == name then
            if ChatAnnouncements.SV.Social.GuildCA then
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_JOIN_SELF), guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_JOIN_SELF), guildNameAllianceAlert))
            end
            break
        end
    end
end

-- EVENT_GUILD_INVITE_ADDED
function ChatAnnouncements.GuildInviteAdded(eventId, guildId, guildName, guildAlliance, inviterName)
    local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(inviterName, inviterName)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    if ChatAnnouncements.SV.Social.GuildCA then
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), displayNameLink, guildNameAlliance), true)
    end
    if ChatAnnouncements.SV.Social.GuildAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), inviterName, guildNameAllianceAlert))
    end
end

function ChatAnnouncements.FriendAdded(eventId, displayName)
    local social = GetChatOutputSocialSettings()
    if social and social.FriendIgnoreCA then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        ChatOutput:Print(zo_strformat(LUIE_STRING_CA_FRIENDS_FRIEND_ADDED, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_FRIENDS_FRIEND_ADDED, displayName))
    end
end

function ChatAnnouncements.FriendRemoved(eventId, displayName)
    local social = GetChatOutputSocialSettings()
    if social and social.FriendIgnoreCA then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        ChatOutput:Print(zo_strformat(LUIE_STRING_CA_FRIENDS_FRIEND_REMOVED, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_FRIENDS_FRIEND_REMOVED, displayName))
    end
end

function ChatAnnouncements.FriendInviteAdded(eventId, displayName)
    local social = GetChatOutputSocialSettings()
    if social and social.FriendIgnoreCA then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        ChatOutput:Print(zo_strformat(LUIE_STRING_CA_FRIENDS_INCOMING_FRIEND_REQUEST, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_FRIENDS_INCOMING_FRIEND_REQUEST, displayName))
    end
end

function ChatAnnouncements.IgnoreAdded(eventId, displayName)
    local social = GetChatOutputSocialSettings()
    if social and social.FriendIgnoreCA then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        ChatOutput:Print(zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_IGNORE_ADDED, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_IGNORE_ADDED, displayName))
    end
end

function ChatAnnouncements.IgnoreRemoved(eventId, displayName)
    local social = GetChatOutputSocialSettings()
    if social and social.FriendIgnoreCA then
        local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
        ChatOutput:Print(zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_IGNORE_REMOVED, displayNameLink), true)
    end
    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_FRIENDS_LIST_IGNORE_REMOVED, displayName))
    end
end

function ChatAnnouncements.FriendPlayerStatus(eventId, displayName, characterName, oldStatus, newStatus)
    local wasOnline = oldStatus ~= PLAYER_STATUS_OFFLINE
    local isOnline = newStatus ~= PLAYER_STATUS_OFFLINE

    if wasOnline ~= isOnline then
        local loggedString = isOnline and LUIE_STRING_CA_FRIENDS_LIST_LOGGED_ON or LUIE_STRING_CA_FRIENDS_LIST_LOGGED_OFF
        local loggedCharacterString = isOnline and LUIE_STRING_CA_FRIENDS_LIST_CHARACTER_LOGGED_ON or LUIE_STRING_CA_FRIENDS_LIST_CHARACTER_LOGGED_OFF
        local nameFormat = ChatAnnouncements.SV.Social.FriendStatusNameFormat or 1
        local hasChar = NameFieldNonEmpty(characterName)
        local chatText
        local alertText

        if nameFormat == 2 and hasChar then
            local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(displayName, displayName)
            local characterNameLink = ChatAnnouncements.CreateCharacterLink(characterName)
            chatText = zo_strformat(loggedCharacterString, displayNameLink, characterNameLink)
            alertText = zo_strformat(loggedCharacterString, displayName, characterName)
        else
            local nameLink = ChatAnnouncements.ResolveNameLink(characterName, displayName)
            local alertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
            chatText = zo_strformat(loggedString, nameLink)
            alertText = zo_strformat(loggedString, alertName)
        end

        local social = GetChatOutputSocialSettings()
        if social and social.FriendStatusCA then
            ChatOutput:Print(chatText, true)
        end
        if ChatAnnouncements.SV.Social.FriendStatusAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertText)
        end
    end
end

function ChatAnnouncements.QuestShared(eventId, questId)
    if ChatAnnouncements.SV.Quests.QuestShareCA or ChatAnnouncements.SV.Quests.QuestShareAlert then
        local questName, characterName, timeSinceRequestMs, displayName = GetOfferedQuestShareInfo(questId)

        local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)

        local message = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE), finalName, ColorizeColors.QuestColorQuestNameColorize:Colorize(questName))
        local alertMessage = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE_P2P), finalName, questName)

        if ChatAnnouncements.SV.Quests.QuestShareCA then
            ChatOutput:Print(message, true)
        end
        if ChatAnnouncements.SV.Quests.QuestShareAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertMessage)
        end
    end
end

-- EVENT_CHATTER_BEGIN
function ChatAnnouncements.OnChatterBegin()
    S.g_talkingToNPC = true
end

-- EVENT_CHATTER_END
function ChatAnnouncements.OnChatterEnd()
    S.g_talkingToNPC = false
end

-- EVENT_GROUPING_TOOLS_LFG_JOINED
function ChatAnnouncements.GroupingToolsLFGJoined(eventId, locationName)
    -- Update the current activity id with the one we are in now.
    S.g_currentActivityId = GetCurrentLFGActivityId()
    -- Get the name of the current activityId that is generated on initialization.
    local currentActivityName = I.GetActivityName(S.g_currentActivityId)
    -- If the locationName is different thant the saved currentActivityName we have entered a new LFG instance, so display this message.
    if locationName ~= currentActivityName then
        if ChatAnnouncements.SV.Group.GroupLFGCA then
            ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GROUPFINDER_ALERT_LFG_JOINED, locationName), true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_GROUPFINDER_ALERT_LFG_JOINED, locationName))
        end
        S.g_lfgDisableGroupEvents = true
        zo_callLater(function ()
                         S.g_lfgDisableGroupEvents = false
                     end, 3000)
    end
    S.g_joinLFGOverride = true
end

-- EVENT_ACTIVITY_FINDER_STATUS_UPDATE
function ChatAnnouncements.ActivityStatusUpdate(eventId, status)
    -- d("status: " .. status)
    local message
    if S.g_showActivityStatus then
        if not S.g_weDeclinedTheQueue then
            -- If we are NOT queued and were formerly queued, forming group, or in a ready check, display left queue message.
            if status == ACTIVITY_FINDER_STATUS_NONE and (S.g_savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED or S.g_savedQueueValue == ACTIVITY_FINDER_STATUS_READY_CHECK) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_END))
            end
            -- If we are queued and previously we were not queued then display a message.
            if status == ACTIVITY_FINDER_STATUS_QUEUED and (S.g_savedQueueValue == ACTIVITY_FINDER_STATUS_NONE or S.g_savedQueueValue == ACTIVITY_FINDER_STATUS_IN_PROGRESS) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_START))
            end
            -- If we were in the queue and are now in progress without a ready check triggered, we left the queue to find a replacement member so this should be displayed.
            if status == ACTIVITY_FINDER_STATUS_IN_PROGRESS and (S.g_savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_END))
            end
        end
    end

    -- If we queue as a group in a completed LFG activity then if someone drops the queue don't show that a group was succesfully formed.
    -- This event handles everyone but the player that declined the check.
    if (status == ACTIVITY_FINDER_STATUS_COMPLETE and S.g_savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED) or (status == ACTIVITY_FINDER_STATUS_QUEUED and S.g_savedQueueValue == ACTIVITY_FINDER_STATUS_READY_CHECK) then
        -- Don't show if we already got a ready check cancel message.
        if not S.g_lfgHideStatusCancel then
            message = (GetString(SI_LFGREADYCHECKCANCELREASON3))
        end
        S.g_showRCUpdates = true
    end

    if message then
        if ChatAnnouncements.SV.Group.GroupLFGQueueCA then
            ChatOutput:Print(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGQueueAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
    end

    -- Should always trigger at the end result of a ready check failing (none when not in an activity already, complete when in a finished one).
    if status == ACTIVITY_FINDER_STATUS_NONE then
        S.g_showRCUpdates = true
    end
    if status == ACTIVITY_FINDER_STATUS_READY_CHECK then
        S.g_showRCUpdates = false
    end

    -- Debug
    -- if status == ACTIVITY_FINDER_STATUS_FORMING_GROUP and S.g_savedQueueValue ~= ACTIVITY_FINDER_STATUS_FORMING_GROUP then
    --     if LUIE.IsDevDebugEnabled() then
    --         LUIE:Log("Debug", "Old ACTIVITY_FINDER_STATUS_FORMING_GROUP event triggered")
    --     end
    -- end

    S.g_savedQueueValue = status
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
function I.GetActivityName(activityType)
    local activityInfo = ACTIVITY_TYPE_STRINGS[activityType]
    if not activityInfo then return nil end

    if activityInfo.descriptor then
        return zo_strformat("<<1>> <<2>>", GetString(activityInfo.stringId), GetString(activityInfo.descriptor))
    else
        return GetString(activityInfo.stringId)
    end
end

function ChatAnnouncements.ReadyCheckUpdate(eventId)
    local activityType, playerRole = GetLFGReadyCheckNotificationInfo()
    local tanksAccepted, tanksPending, healersAccepted, healersPending, dpsAccepted, dpsPending = GetLFGReadyCheckCounts()

    if S.g_showRCUpdates then
        -- Return early if invalid activity type
        if activityType == LFG_ACTIVITY_INVALID then return end

        local activityName = I.GetActivityName(activityType)
        if not activityName then return end

        local message, alertText
        if playerRole ~= 0 then
            local roleIconSmall = zo_strformat("<<1>> ", zo_iconFormat(ZO_GetRoleIcon(playerRole), 16, 16)) or ""
            local roleIconLarge = zo_strformat("<<1>> ", zo_iconFormat(ZO_GetRoleIcon(playerRole), "100%", "100%")) or ""
            local roleString = GetString("SI_LFGROLE", playerRole)

            message = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_READY_CHECK_ACTIVITY_ROLE), activityName, roleIconSmall, roleString)
            alertText = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_READY_CHECK_ACTIVITY_ROLE), activityName, roleIconLarge, roleString)
        else
            message = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_READY_CHECK_ACTIVITY), activityName)
            alertText = message
        end

        if ChatAnnouncements.SV.Group.GroupLFGCA then
            ChatOutput:Print(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertText)
        end
    end

    S.g_showRCUpdates = false

    -- Handle ready check completion or cancellation
    local allCountsZero = tanksAccepted == 0 and tanksPending == 0 and
        healersAccepted == 0 and healersPending == 0 and
        dpsAccepted == 0 and dpsPending == 0

    if not S.g_showRCUpdates and allCountsZero and not S.g_rcSpamPrevention then
        S.g_rcSpamPrevention = true

        -- Reset spam prevention after 1 second
        zo_callLater(function ()
                         S.g_rcSpamPrevention = false
                     end, 1000)

        -- Reset activity status after 1 second
        S.g_showActivityStatus = false
        zo_callLater(function ()
                         S.g_showActivityStatus = true
                     end, 1000)

        -- Reset group leave queue after 1 second
        S.g_stopGroupLeaveQueue = true
        zo_callLater(function ()
                         S.g_stopGroupLeaveQueue = false
                     end, 1000)

        S.g_showRCUpdates = true
    end
end

--[[ Would love to be able to use this function but its too buggy for now. Spams every single time someone updates their role, as well as when people join/leave group. If the player joins a large party for the first time then
this broadcasts the role of every single player in the party. Too bad this doesn't only trigger when someone in group actually updates their role instead.
No localization support yet.
function ChatAnnouncements.GMRC(eventId, unitTag, dps, healer, tank)

local updatedRoleName = GetUnitName(unitTag)
local updatedRoleAccountName = GetUnitDisplayName(unitTag)

local characterNameLink = ZO_LinkHandler_CreateCharacterLink(updatedRoleName)
local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(updatedRoleAccountName)
local displayBothString = ( zo_strformat("<<1>><<2>>", updatedRoleName, updatedRoleAccountName) )
local displayBoth = ChatAnnouncements.CreateDisplayNameLink(displayBothString, updatedRoleAccountName)

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
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_ROLE_UPDATED), displayNameLink, message) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 2 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_ROLE_UPDATED), characterNameLink, message) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 3 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_ROLE_UPDATED), displayBoth, message) )
        end
    else
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_ROLE_UPDATED_SELF), message) )
    end
end
]]
--

--[[ Would love to be able to use this function but its too buggy for now. When a single player disconnects for the first time in the group, another player will see a message for the online/offline status of every other
player in the group. Possibly reimplement and limit it to 2 player groups?
No localization support yet.
function ChatAnnouncements.GMCS(eventId, unitTag, isOnline)

    local onlineRoleName = GetUnitName(unitTag)
    local onlineRoleDisplayName = GetUnitDisplayName(unitTag)

    local characterNameLink = ZO_LinkHandler_CreateCharacterLink(onlineRoleName)
    local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(onlineRoleDisplayName)
    local displayBothString = ( zo_strformat("<<1>><<2>>", onlineRoleName, onlineRoleDisplayName) )
    local displayBoth = ChatAnnouncements.CreateDisplayNameLink(displayBothString, onlineRoleDisplayName)


    if not isOnline and onlineRoleName ~=LUIE.PlayerNameFormatted then
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 1 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_DISCONNECTED), displayNameLink) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 2 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_DISCONNECTED), characterNameLink) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 3 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_DISCONNECTED), displayBoth) )
        end
    elseif isOnline and onlineRoleName ~=LUIE.PlayerNameFormatted then
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 1 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_RECONNECTED), displayNameLink) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 2 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_RECONNECTED), characterNameLink) )
        end
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 3 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_GROUP_RECONNECTED), displayBoth) )
        end
    end
end
]]
--

local RESPEC_TYPE_CHAMPION = 1
local RESPEC_TYPE_ATTRIBUTES = 2
local RESPEC_TYPE_SKILLS = 3
local RESPEC_TYPE_MORPHS = 4
local RESPEC_TYPE_SKILL_LINE = 5

local LUIE_AttributeDisplayType =
{
    [RESPEC_TYPE_CHAMPION] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_CHAMPION),
    [RESPEC_TYPE_ATTRIBUTES] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_ATTRIBUTES),
    [RESPEC_TYPE_SKILLS] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILLS),
    [RESPEC_TYPE_MORPHS] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_MORPHS),
    [RESPEC_TYPE_SKILL_LINE] = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILL_LINE),
}

-- Called by various functions to display a respec message, type serves as the message type, delay allows the message to sync timing with the chat printer based on source.
function ChatAnnouncements.PointRespecDisplay(respecType)
    local message = LUIE_AttributeDisplayType[respecType] .. "."
    local messageCSA = LUIE_AttributeDisplayType[respecType]

    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.CA then
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "MESSAGE", isSystem = true }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.CSA then
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
        messageParams:SetText(messageCSA)
        messageParams:SetSound(SOUNDS.DISPLAY_ANNOUNCEMENT)
        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
    end

    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.Alert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
    end
end

function I.IsContainerLootCurrencyReason(changeReason)
    return changeReason == CURRENCY_CHANGE_REASON_LOOT
        or changeReason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER
end

function I.IsLootLikeCurrencyReason(changeReason)
    return changeReason == CURRENCY_CHANGE_REASON_LOOT
        or changeReason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER
        or changeReason == CURRENCY_CHANGE_REASON_KILL
        or changeReason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER
        or changeReason == CURRENCY_CHANGE_REASON_REWARD
        or changeReason == CURRENCY_CHANGE_REASON_QUESTREWARD
end

function ChatAnnouncements.FlushDeferredContainerLootCurrency()
    if S.g_deferredContainerGoldThrottleAmount > 0 then
        S.g_currencyGoldThrottleValue = S.g_deferredContainerGoldThrottleAmount
        S.g_currencyGoldThrottleTotal = S.g_deferredContainerGoldThrottleTotal
        S.g_deferredContainerGoldThrottleAmount = 0
        S.g_deferredContainerGoldThrottleTotal = 0
        ChatAnnouncements.CurrencyGoldThrottlePrinter()
    end
    for i = 1, #S.g_deferredContainerCurrency do
        local d = S.g_deferredContainerCurrency[i]
        ChatAnnouncements.CurrencyPrinter(d.currency, d.formattedValue, d.changeColor, d.changeType, d.currencyTypeColor, d.currencyIcon, d.currencyName, d.currencyTotal, d.messageChange, d.messageTotal, d.type)
    end
    S.g_deferredContainerCurrency = {}
end

function I.BeginContainerLootOrderingWindow()
    S.g_containerRecentlyOpened = true
    local function ResetContainerRecentlyOpened()
        ChatAnnouncements.FlushDeferredContainerLootCurrency()
        S.g_containerRecentlyOpened = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetContainer")
    end
    eventManager:UnregisterForUpdate(moduleName .. "ResetContainer")
    eventManager:RegisterForUpdate(moduleName .. "ResetContainer", 200, ResetContainerRecentlyOpened)
end

function ChatAnnouncements.OnLootUpdated(eventId)
    I.BeginContainerLootOrderingWindow()
end

--- @param eventId integer
--- @param currency CurrencyType
--- @param currencyLocation CurrencyLocation
--- @param newValue integer
--- @param oldValue integer
--- @param reason CurrencyChangeReason
--- @param reasonSupplementaryInfo integer
function ChatAnnouncements.OnCurrencyUpdate(eventId, currency, currencyLocation, newValue, oldValue, reason, reasonSupplementaryInfo)
    if currencyLocation ~= CURRENCY_LOCATION_CHARACTER and currencyLocation ~= CURRENCY_LOCATION_ACCOUNT then
        return
    end

    local UpOrDown = newValue - oldValue

    -- DEBUG
    -- d("currency: " .. currency)
    -- d("NV: " .. newValue)
    -- d("OV: " .. oldValue)
    -- d("reason: " .. reason)

    -- If the total gold change was 0 or (Reason 7 = Command) or (Reason 28 = Mount Feed) or (Reason 35 = Player Init) or (Reason 81 = Expiration) - End Now
    if UpOrDown == 0 or reason == CURRENCY_CHANGE_REASON_COMMAND or reason == CURRENCY_CHANGE_REASON_FEED_MOUNT or reason == CURRENCY_CHANGE_REASON_PLAYER_INIT or reason == CURRENCY_CHANGE_REASON_EXPIRATION then
        return
    end

    -- CURT_TRADE_BARS loot-like gains follow ZOS loot history via EVENT_CURRENCY_UPDATE (see LootHistory_Manager).
    -- If PTR shows gaps without CURRENCY_UPDATE, register EVENT_TRADE_BAR_UPDATE and forward to OnCurrencyUpdate.
    if currency == CURT_TRADE_BARS and UpOrDown > 0 and I.IsLootLikeCurrencyReason(reason) then
        if not ChatAnnouncements.SV.Inventory.Loot or not ChatAnnouncements.SV.Currency.CurrencyTradeBarsChange then
            return
        end
    end

    local formattedValue = ZO_CommaDelimitDecimalNumber(newValue)
    local changeColor       -- Gets the value from ColorizeColors.CurrencyUpColorize or ColorizeColors.CurrencyDownColorize to color strings
    local changeType        -- Amount of currency gained or lost
    local currencyTypeColor -- Determines color to use for colorization of currency based off currency type.
    local currencyIcon      -- Determines icon to use for currency based off currency type.
    local currencyName      -- Determines name to use for currency based off type.
    local currencyTotal     -- Determines if the total should be displayed based off type.
    local messageChange     -- Set to a string value based on the reason code.
    local messageTotal      -- Set to a string value based on the currency type.
    local type

    local function SavePurchaseToBuffer(changeTypeForBuffer, formattedValueForBuffer, currencyTypeColorForBuffer, currencyIconForBuffer, currencyNameForBuffer, currencyTotalForBuffer, messageTotalForBuffer)
        S.g_savedPurchase.changeType = changeTypeForBuffer
        S.g_savedPurchase.formattedValue = formattedValueForBuffer
        S.g_savedPurchase.currencyTypeColor = currencyTypeColorForBuffer
        S.g_savedPurchase.currencyIcon = currencyIconForBuffer
        S.g_savedPurchase.currencyName = currencyNameForBuffer
        S.g_savedPurchase.currencyTotal = currencyTotalForBuffer
        S.g_savedPurchase.messageTotal = messageTotalForBuffer
    end

    local function GetChangeColorAndType(amountDelta, oldvalue, newvalue)
        if amountDelta > 0 then
            local changeColorHex = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
            return changeColorHex, ZO_CommaDelimitDecimalNumber(newvalue - oldvalue)
        elseif amountDelta < 0 then
            local changeColorHex = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
            return changeColorHex, ZO_CommaDelimitDecimalNumber(oldvalue - newvalue)
        end
    end

    -- Descriptor table for currencies without throttle/filter (icon path uses |t16:16:...|t when CurrencyIcon is true)
    local SIMPLE_CURRENCY =
    {
        [CURT_WRIT_VOUCHERS]          = { "CurrencyWVChange", "CurrencyWVColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_WRIT_VOUCHERS), "CurrencyWVName", "CurrencyWVShowTotal", "CurrencyMessageTotalWV" },
        [CURT_STYLE_STONES]           = { "CurrencyOutfitTokenChange", "CurrencyOutfitTokenColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_STYLE_STONES), "CurrencyOutfitTokenName", "CurrencyOutfitTokenShowTotal", "CurrencyMessageTotalOutfitToken" },
        [CURT_TRANSMUTE_CRYSTALS]     = { "CurrencyTransmuteChange", "CurrencyTransmuteColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_TRANSMUTE_CRYSTALS), "CurrencyTransmuteName", "CurrencyTransmuteShowTotal", "CurrencyMessageTotalTransmute" },
        [CURT_UNDAUNTED_KEYS]         = { "CurrencyUndauntedChange", "CurrencyUndauntedColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_UNDAUNTED_KEYS), "CurrencyUndauntedName", "CurrencyUndauntedShowTotal", "CurrencyMessageTotalUndaunted" },
        [CURT_CROWNS]                 = { "CurrencyCrownsChange", "CurrencyCrownsColorize", ZO_Currency_GetPlatformCurrencyIcon(CURT_CROWNS), "CurrencyCrownsName", "CurrencyCrownsShowTotal", "CurrencyMessageTotalCrowns" },
        [CURT_CROWN_GEMS]             = { "CurrencyCrownGemsChange", "CurrencyCrownGemsColorize", ZO_Currency_GetPlatformCurrencyIcon(CURT_CROWN_GEMS), "CurrencyCrownGemsName", "CurrencyCrownGemsShowTotal", "CurrencyMessageTotalCrownGems" },
        [CURT_ARCHIVAL_FORTUNES]      = { "CurrencyEndlessChange", "CurrencyEndlessColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_ARCHIVAL_FORTUNES), "CurrencyEndlessName", "CurrencyEndlessShowTotal", "CurrencyMessageTotalEndless" },
        [CURT_SEALS]                  = { "CurrencySealsChange", "CurrencySealsColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_SEALS), "CurrencySealsName", "CurrencySealsShowTotal", "CurrencyMessageTotalSeals" },
        [CURT_TRADE_BARS]             = { "CurrencyTradeBarsChange", "CurrencyTradeBarsColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_TRADE_BARS), "CurrencyTradeBarsName", "CurrencyTradeBarsShowTotal", "CurrencyMessageTotalTradeBars" },
        [CURT_TOME_POINTS]            = { "CurrencyTomePointsChange", "CurrencyTomePointsColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_TOME_POINTS), "CurrencyTomePointsName", "CurrencyTomePointsShowTotal", "CurrencyMessageTotalTomePoints" },
        [CURT_TOME_POINT_CACHES]      = { "CurrencyTomePointCachesChange", "CurrencyTomePointCachesColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_TOME_POINT_CACHES), "CurrencyTomePointCachesName", "CurrencyTomePointCachesShowTotal", "CurrencyMessageTotalTomePointCaches" },
        [CURT_TOME_TOKENS]            = { "CurrencyTomeTokensChange", "CurrencyTomeTokensColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_TOME_TOKENS), "CurrencyTomeTokensName", "CurrencyTomeTokensShowTotal", "CurrencyMessageTotalTomeTokens" },
        [CURT_TOME_CHALLENGE_REROLLS] = { "CurrencyTomeChallengeRerollsChange", "CurrencyTomeChallengeRerollsColorize", ZO_Currency_GetPlatformCurrencyLootIcon(CURT_TOME_CHALLENGE_REROLLS), "CurrencyTomeChallengeRerollsName", "CurrencyTomeChallengeRerollsShowTotal", "CurrencyMessageTotalTomeChallengeRerolls" },
    }

    local function GetCurrencyDisplayInfo(currencyType, amountDelta, changeReason)
        local currencySettings = ChatAnnouncements.SV.Currency
        if currencyType == CURT_MONEY then
            if not currencySettings.CurrencyGoldChange then return nil end
            if currencySettings.CurrencyGoldThrottle and (changeReason == CURRENCY_CHANGE_REASON_LOOT or changeReason == CURRENCY_CHANGE_REASON_KILL) then
                if S.g_containerRecentlyOpened and amountDelta > 0 and I.IsContainerLootCurrencyReason(changeReason) then
                    S.g_deferredContainerGoldThrottleAmount = S.g_deferredContainerGoldThrottleAmount + amountDelta
                    S.g_deferredContainerGoldThrottleTotal = I.GetCarriedCurrencyAmount(1)
                    return "skip"
                end
                zo_callLater(ChatAnnouncements.CurrencyGoldThrottlePrinter, 50)
                S.g_currencyGoldThrottleValue = S.g_currencyGoldThrottleValue + amountDelta
                S.g_currencyGoldThrottleTotal = I.GetCarriedCurrencyAmount(1)
                return "skip"
            end
            if currencySettings.CurrencyGoldFilter > 0 and (changeReason == CURRENCY_CHANGE_REASON_LOOT or changeReason == CURRENCY_CHANGE_REASON_KILL) and amountDelta < currencySettings.CurrencyGoldFilter then
                return "skip"
            end
            return
            {
                currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex(),
                currencyIcon = currencySettings.CurrencyIcon and "|t16:16:/esoui/art/currency/currency_gold.dds|t" or "",
                currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyGoldName"), amountDelta),
                currencyTotal = currencySettings.CurrencyGoldShowTotal,
                messageTotal = ChatAnnouncements.GetCurrencyMessageFormat("CurrencyMessageTotalGold"),
            }
        elseif currencyType == CURT_ALLIANCE_POINTS then
            if not currencySettings.CurrencyAPShowChange then return nil end
            if currencySettings.CurrencyAPThrottle > 0 and (changeReason == CURRENCY_CHANGE_REASON_KILL or changeReason == CURRENCY_CHANGE_REASON_KEEP_REPAIR or changeReason == CURRENCY_CHANGE_REASON_PVP_RESURRECT) then
                eventManager:UnregisterForUpdate(moduleName .. "BufferedAP")
                eventManager:RegisterForUpdate(moduleName .. "BufferedAP", currencySettings.CurrencyAPThrottle, ChatAnnouncements.CurrencyAPThrottlePrinter)
                S.g_currencyAPThrottleValue = S.g_currencyAPThrottleValue + amountDelta
                S.g_currencyAPThrottleTotal = I.GetCarriedCurrencyAmount(2)
                return "skip"
            end
            if currencySettings.CurrencyAPFilter > 0 and (changeReason == CURRENCY_CHANGE_REASON_KILL or changeReason == CURRENCY_CHANGE_REASON_KEEP_REPAIR or changeReason == CURRENCY_CHANGE_REASON_PVP_RESURRECT) and amountDelta < currencySettings.CurrencyAPFilter then
                return "skip"
            end
            if currencySettings.CurrencyAPThrottle > 0 and (changeReason ~= CURRENCY_CHANGE_REASON_KILL and changeReason ~= CURRENCY_CHANGE_REASON_KEEP_REPAIR and changeReason ~= CURRENCY_CHANGE_REASON_PVP_RESURRECT) then
                ChatAnnouncements.CurrencyAPThrottlePrinter()
            end
            return
            {
                currencyTypeColor = ColorizeColors.CurrencyAPColorize:ToHex(),
                currencyIcon = currencySettings.CurrencyIcon and "|t16:16:/esoui/art/currency/alliancepoints.dds|t" or "",
                currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyAPName"), amountDelta),
                currencyTotal = currencySettings.CurrencyAPShowTotal,
                messageTotal = ChatAnnouncements.GetCurrencyMessageFormat("CurrencyMessageTotalAP"),
            }
        elseif currencyType == CURT_TELVAR_STONES then
            if not currencySettings.CurrencyTVChange then return nil end
            if currencySettings.CurrencyTVThrottle > 0 and (changeReason == CURRENCY_CHANGE_REASON_LOOT or changeReason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER) and not S.g_containerRecentlyOpened then
                eventManager:UnregisterForUpdate(moduleName .. "BufferedTV")
                eventManager:RegisterForUpdate(moduleName .. "BufferedTV", currencySettings.CurrencyTVThrottle, ChatAnnouncements.CurrencyTVThrottlePrinter)
                S.g_currencyTVThrottleValue = S.g_currencyTVThrottleValue + amountDelta
                S.g_currencyTVThrottleTotal = I.GetCarriedCurrencyAmount(3)
                return "skip"
            end
            if currencySettings.CurrencyTVFilter > 0 and (changeReason == CURRENCY_CHANGE_REASON_LOOT or changeReason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER) and amountDelta < currencySettings.CurrencyTVFilter then
                return "skip"
            end
            if currencySettings.CurrencyTVThrottle > 0 and (changeReason ~= CURRENCY_CHANGE_REASON_LOOT and changeReason ~= CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER) then
                ChatAnnouncements.CurrencyTVThrottlePrinter()
            end
            return
            {
                currencyTypeColor = ColorizeColors.CurrencyTVColorize:ToHex(),
                currencyIcon = currencySettings.CurrencyIcon and "|t16:16:/esoui/art/currency/currency_telvar.dds|t" or "",
                currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyTVName"), amountDelta),
                currencyTotal = currencySettings.CurrencyTVShowTotal,
                messageTotal = ChatAnnouncements.GetCurrencyMessageFormat("CurrencyMessageTotalTV"),
            }
        else
            local currencyDescriptor = SIMPLE_CURRENCY[currencyType]
            if not currencyDescriptor then return nil end
            local enabledKey, colorizeKey, iconPath, nameKey, showTotalKey, messageTotalKey = currencyDescriptor[1], currencyDescriptor[2], currencyDescriptor[3], currencyDescriptor[4], currencyDescriptor[5], currencyDescriptor[6]
            if not currencySettings[enabledKey] then return nil end
            local iconString = "|t16:16:" .. iconPath .. "|t"
            return
            {
                currencyTypeColor = ColorizeColors[colorizeKey]:ToHex(),
                currencyIcon = currencySettings.CurrencyIcon and iconString or "",
                currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat(nameKey), amountDelta),
                currencyTotal = currencySettings[showTotalKey],
                messageTotal = ChatAnnouncements.GetCurrencyMessageFormat(messageTotalKey),
            }
        end
    end

    local displayInfo = GetCurrencyDisplayInfo(currency, UpOrDown, reason)
    if displayInfo == nil or displayInfo == "skip" then return end
    currencyTypeColor = displayInfo.currencyTypeColor
    currencyIcon = displayInfo.currencyIcon
    currencyName = displayInfo.currencyName
    currencyTotal = displayInfo.currencyTotal
    messageTotal = displayInfo.messageTotal

    -- Did we gain or lose currency
    changeColor, changeType = GetChangeColorAndType(UpOrDown, oldValue, newValue)

    -- Reason -> message key (ContextMessages key) for simple cases; reason -> type for bag/bank
    local reasonToMessageKey =
    {
        [CURRENCY_CHANGE_REASON_QUESTREWARD] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_DECONSTRUCT] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_MEDAL] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_CONVERSATION] = "CurrencyMessagePay",
        [CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD] = "CurrencyMessageWayshrine",
        [CURRENCY_CHANGE_REASON_VENDOR_REPAIR] = "CurrencyMessageRepair",
        [CURRENCY_CHANGE_REASON_STUCK] = "CurrencyMessageUnstuck",
        [CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE] = "CurrencyMessageBounty",
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
        [CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY] = "CurrencyMessageSpend",
        [CURRENCY_CHANGE_REASON_GUILD_TABARD] = "CurrencyMessageSpend",
        [CURRENCY_CHANGE_REASON_KEEP_REPAIR] = "CurrencyMessageEarn",
        [CURRENCY_CHANGE_REASON_PVP_RESURRECT] = "CurrencyMessageEarn",
        [CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD] = "CurrencyMessageEarn",
        [CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD] = "CurrencyMessageEarn",
        [CURRENCY_CHANGE_REASON_CRAFT] = "CurrencyMessageUse",
        [CURRENCY_CHANGE_REASON_RECONSTRUCTION] = "CurrencyMessageUse",
        [CURRENCY_CHANGE_REASON_CROWN_CRATE_DUPLICATE] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_ITEM_CONVERTED_TO_GEMS] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_CROWNS_PURCHASED] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_PURCHASED_WITH_SEALS] = "CurrencyMessageSpend",
        [CURRENCY_CHANGE_REASON_PURCHASED_WITH_TRADE_BARS] = "CurrencyMessageSpend",
        [CURRENCY_CHANGE_REASON_EVENT_TICKET_TO_TRADE_BARS_CONVERSION] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_CACHE_REDEEMED_FOR_TOME_POINTS] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_PURCHASED_TAMRIEL_TOMES_PREMIUM_PLUS] = "CurrencyMessageSpend",
        [CURRENCY_CHANGE_REASON_PURCHASED_TAMRIEL_TOMES_REWARD] = "CurrencyMessageSpend",
        [CURRENCY_CHANGE_REASON_TOME_CHALLENGE_REROLL] = "CurrencyMessageSpend",
        [CURRENCY_CHANGE_REASON_WEEKLY_REROLL_GRANT] = "CurrencyMessageReceive",
        [CURRENCY_CHANGE_REASON_ENDLESS_DUNGEON_VISION_REROLL] = "CurrencyMessageSpend",
    }
    local reasonToCurrencyType =
    {
        [CURRENCY_CHANGE_REASON_BAGSPACE] = "LUIE_CURRENCY_BAG",
        [CURRENCY_CHANGE_REASON_BANKSPACE] = "LUIE_CURRENCY_BANK",
    }
    local debugReasonIds =
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
        [CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP] = true,
        [CURRENCY_CHANGE_REASON_BANK_FEE] = true,
        [CURRENCY_CHANGE_REASON_CHARACTER_UPGRADE] = true,
        [CURRENCY_CHANGE_REASON_TRIBUTE] = true,
    }

    local function GetMessageChangeAndType(changeReason, currencyType, amountDelta)
        if changeReason == CURRENCY_CHANGE_REASON_VENDOR and amountDelta > 0 then
            if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                return ChatAnnouncements.GetContextMessage("CurrencyMessageReceive"), nil, "saved_purchase_return"
            end
            return ChatAnnouncements.GetContextMessage("CurrencyMessageReceive"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_VENDOR and amountDelta < 0 then
            if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                return ChatAnnouncements.GetContextMessage("CurrencyMessageSpend"), nil, "saved_purchase_return"
            end
            return ChatAnnouncements.GetContextMessage("CurrencyMessageSpend"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_MAIL and amountDelta > 0 then
            local mailSender = S.g_mailPendingCurrencySender
            local pendingMailId = S.g_mailPendingCurrencyMailId
            S.g_mailPendingCurrencySender = ""
            S.g_mailPendingCurrencyMailId = nil
            if mailSender == "" then
                mailSender = ChatAnnouncements.GetNextMailSender()
            end
            if S.g_mailBatchTakeAll then
                S.g_mailIncomingCurrencySender = mailSender
            elseif mailSender ~= "" then
                S.g_mailTarget = mailSender
            end
            local currencySender = S.g_mailBatchTakeAll and mailSender or S.g_mailTarget
            if currencyType == CURT_MONEY then
                local senderKey = currencySender ~= "" and currencySender or ""
                local nowMs = GetGameTimeMilliseconds()
                local mailIdForDedupe = pendingMailId
                if  mailIdForDedupe == nil
                and S.g_lastMailCurrencyAnnounce.amount == amountDelta
                and S.g_lastMailCurrencyAnnounce.senderKey == senderKey then
                    mailIdForDedupe = S.g_lastMailCurrencyAnnounce.mailId
                end
                if  not S.g_mailBatchTakeAll
                and S.g_lastMailCurrencyAnnounce.amount == amountDelta
                and S.g_lastMailCurrencyAnnounce.senderKey == senderKey
                and I.MailCurrencyDedupeIdsMatch(mailIdForDedupe, S.g_lastMailCurrencyAnnounce.mailId)
                and (nowMs - S.g_lastMailCurrencyAnnounce.timeMs) < MAIL_CURRENCY_ANNOUNCE_DEDUPE_MS then
                    return nil, nil, "return"
                end
                S.g_lastMailCurrencyAnnounce.amount = amountDelta
                S.g_lastMailCurrencyAnnounce.senderKey = senderKey
                S.g_lastMailCurrencyAnnounce.mailId = pendingMailId
                S.g_lastMailCurrencyAnnounce.timeMs = nowMs
            end
            local mailMessageChange = currencySender ~= "" and ChatAnnouncements.GetContextMessage("CurrencyMessageMailIn") or ChatAnnouncements.GetContextMessage("CurrencyMessageMailInNoName")
            local mailCurrencyType = (currencySender ~= "") and "LUIE_CURRENCY_MAIL" or nil
            return mailMessageChange, mailCurrencyType, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_MAIL and amountDelta < 0 then
            if not S.g_mailCODPresent then return nil, nil, "return" end
            local mailSender = S.g_mailPendingCurrencySender
            S.g_mailPendingCurrencySender = ""
            S.g_mailPendingCurrencyMailId = nil
            if mailSender == "" then
                mailSender = ChatAnnouncements.GetNextMailSender()
            end
            if S.g_mailBatchTakeAll then
                S.g_mailIncomingCurrencySender = mailSender
            elseif mailSender ~= "" then
                S.g_mailTarget = mailSender
            end
            local currencySender = S.g_mailBatchTakeAll and mailSender or S.g_mailTarget
            return ChatAnnouncements.GetContextMessage("CurrencyMessageMailCOD"), (currencySender ~= "" and "LUIE_CURRENCY_MAIL" or nil), "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_BUYBACK then
            if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                return ChatAnnouncements.GetContextMessage("CurrencyMessageSpend"), nil, "saved_purchase_return"
            end
            return ChatAnnouncements.GetContextMessage("CurrencyMessageSpend"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_TRADE and amountDelta > 0 then
            return (S.g_tradeTarget ~= "" and ChatAnnouncements.GetContextMessage("CurrencyMessageTradeIn") or ChatAnnouncements.GetContextMessage("CurrencyMessageTradeInNoName")), (S.g_tradeTarget ~= "" and "LUIE_CURRENCY_TRADE" or nil), "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_TRADE and amountDelta < 0 then
            return (S.g_tradeTarget ~= "" and ChatAnnouncements.GetContextMessage("CurrencyMessageTradeOut") or ChatAnnouncements.GetContextMessage("CurrencyMessageTradeOutNoName")), (S.g_tradeTarget ~= "" and "LUIE_CURRENCY_TRADE" or nil), "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_SELL_STOLEN then
            if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                return ChatAnnouncements.GetContextMessage("CurrencyMessageReceive"), nil, "saved_purchase_return"
            end
            return ChatAnnouncements.GetContextMessage("CurrencyMessageReceive"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_BAGSPACE then
            return ChatAnnouncements.GetContextMessage("CurrencyMessageStorage"), "LUIE_CURRENCY_BAG", "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_BANKSPACE then
            return ChatAnnouncements.GetContextMessage("CurrencyMessageStorage"), "LUIE_CURRENCY_BANK", "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_BATTLEGROUND then
            return (amountDelta < 0 and ChatAnnouncements.GetContextMessage("CurrencyMessageCampaign") or ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING then
            if ChatAnnouncements.SV.Currency.CurrencyGoldHideListingAH then
                return nil, nil, "return"
            end
            return nil, nil, "saved_purchase_return"
        elseif changeReason == CURRENCY_CHANGE_REASON_RESPEC_SKILLS then
            ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_SKILLS)
            return ChatAnnouncements.GetContextMessage("CurrencyMessageSkills"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES then
            ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_ATTRIBUTES)
            return ChatAnnouncements.GetContextMessage("CurrencyMessageAttributes"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_RESPEC_MORPHS then
            ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_MORPHS)
            return ChatAnnouncements.GetContextMessage("CurrencyMessageMorphs"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_RESPEC_SUBCLASS then
            ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_SKILL_LINE)
            return ChatAnnouncements.GetContextMessage("CurrencyMessageSkillLine"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_RESPEC_CHAMPION then
            ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_CHAMPION)
            return ChatAnnouncements.GetContextMessage("CurrencyMessageChampion"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_VENDOR_LAUNDER then
            if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                return ChatAnnouncements.GetContextMessage("CurrencyMessageSpend"), nil, "saved_purchase_return"
            end
            return ChatAnnouncements.GetContextMessage("CurrencyMessageSpend"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_REWARD then
            return (currencyType == CURT_SEALS and ChatAnnouncements.GetContextMessage("CurrencyMessageEarn") or ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE then
            if ChatAnnouncements.SV.Currency.CurrencyGoldHideAH then
                return nil, nil, "return"
            end
            return ChatAnnouncements.GetContextMessage("CurrencyMessageSpend"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD or changeReason == CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED then
            zo_callLater(ChatAnnouncements.JusticeDisplayConfiscate, 100)
            return ChatAnnouncements.GetContextMessage("CurrencyMessageConfiscate"), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_KILL then
            return (currencyType == CURT_ALLIANCE_POINTS and ChatAnnouncements.GetContextMessage("CurrencyMessageEarn") or ChatAnnouncements.GetContextMessage("CurrencyMessageLoot")), nil, "continue"
        elseif changeReason == CURRENCY_CHANGE_REASON_PURCHASED_WITH_GEMS or changeReason == CURRENCY_CHANGE_REASON_PURCHASED_WITH_CROWNS then
            return (currencyType == CURT_STYLE_STONES or currencyType == CURT_SEALS or currencyType == CURT_TRADE_BARS) and ChatAnnouncements.GetContextMessage("CurrencyMessageReceive") or ChatAnnouncements.GetContextMessage("CurrencyMessageSpend"), nil, "continue"
        elseif debugReasonIds[changeReason] then
            return zo_strformat(GetString(LUIE_STRING_CA_DEBUG_MSG_CURRENCY), changeReason), nil, "continue"
        end
        local contextMessageKey = reasonToMessageKey[changeReason]
        if contextMessageKey then
            return ChatAnnouncements.GetContextMessage(contextMessageKey), reasonToCurrencyType[changeReason], "continue"
        end
        return ChatAnnouncements.GetContextMessage("CurrencyMessageLoot"), nil, "continue"
    end

    local messageChangeResult, typeResult, action = GetMessageChangeAndType(reason, currency, UpOrDown)
    if action == "return" then return end
    if action == "saved_purchase_return" then
        SavePurchaseToBuffer(changeType, formattedValue, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageTotal)
        return
    end
    messageChange = messageChangeResult
    type = typeResult

    -- Gold from opening a container often fires before the container item is removed; defer until "You empty …" prints.
    if S.g_containerRecentlyOpened and UpOrDown > 0 and currency == CURT_MONEY and I.IsContainerLootCurrencyReason(reason) then
        S.g_deferredContainerCurrency[#S.g_deferredContainerCurrency + 1] =
        {
            currency = currency,
            formattedValue = formattedValue,
            changeColor = changeColor,
            changeType = changeType,
            currencyTypeColor = currencyTypeColor,
            currencyIcon = currencyIcon,
            currencyName = currencyName,
            currencyTotal = currencyTotal,
            messageChange = messageChange,
            messageTotal = messageTotal,
            type = type,
        }
        return
    end

    -- CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER (76): opening currency containers (e.g. Transmutation Geode, other geodes that grant crystals/currency). Mapped to CurrencyMessageLoot above.
    -- if reason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER then
    --     if LUIE.IsDevDebugEnabled() then
    --         LUIE:Log("Debug", "Currency Change Reason 76 - CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER")
    --     end
    -- end

    -- Send relevant values over to the currency printer
    ChatAnnouncements.CurrencyPrinter(currency, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
end

-- Printer function receives values from currency update or from other functions that display currency updates.
-- Type here refers to an LUIE_CURRENCY_TYPE
function ChatAnnouncements.CurrencyPrinter(baseCurrencyType, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type, carriedItem, carriedItemTotal)
    local messageP1 -- First part of message - Change
    local messageP2 -- Second part of the message (if enabled) - Total
    local item
    local name

    messageP1 = ("|r|c" .. currencyTypeColor .. currencyIcon .. " " .. changeType .. currencyName .. "|r|c" .. changeColor)

    if (currencyTotal and type ~= "LUIE_CURRENCY_HERALDRY") or (type == "LUIE_CURRENCY_VENDOR" and ChatAnnouncements.SV.Inventory.LootVendorTotalCurrency) then
        messageP2 = ("|r|c" .. currencyTypeColor .. currencyIcon .. " " .. formattedValue .. "|r|c" .. changeColor)
    else
        messageP2 = "|r"
    end

    local formattedMessageP1
    if type == "LUIE_CURRENCY_BAG" or type == "LUIE_CURRENCY_BANK" then
        local function ResolveStorageType()
            local bagType
            local icon
            if type == "LUIE_CURRENCY_BAG" then
                bagType = string_format(B.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_BAGTYPE1) .. B.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/icons/store_upgrade_bag.dds|t " or ""
            end
            if type == "LUIE_CURRENCY_BANK" then
                bagType = string_format(B.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_BAGTYPE2) .. B.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/icons/store_upgrade_bank.dds|t " or ""
            end
            return string_format("|r" .. icon .. "|cFFFFFF" .. bagType .. "|r|c" .. changeColor)
        end
        formattedMessageP1 = (string_format(messageChange, ResolveStorageType(), messageP1))
        -- TODO:
    elseif type == "LUIE_CURRENCY_HERALDRY" then
        local icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:" .. LUIE_MEDIA_UNITFRAMES_CA_HERALDRY_DDS .. "|t " or ""
        local heraldryMessage = string_format("|r" .. icon .. "|cFFFFFF" .. B.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_CURRENCY_NAME_HERALDRY) .. B.linkBracket2[ChatAnnouncements.SV.BracketOptionItem] .. "|r|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, messageP1, heraldryMessage))
    elseif type == "LUIE_CURRENCY_RIDING_SPEED" or type == "LUIE_CURRENCY_RIDING_CAPACITY" or type == "LUIE_CURRENCY_RIDING_STAMINA" then
        local function ResolveRidingStats()
            -- if somevar then icon = else no
            local skillType
            local icon
            if type == "LUIE_CURRENCY_RIDING_SPEED" then
                skillType = string_format(B.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE1) .. B.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_speed.dds|t " or ""
            elseif type == "LUIE_CURRENCY_RIDING_CAPACITY" then
                skillType = string_format(B.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE2) .. B.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_capacity.dds|t " or ""
            elseif type == "LUIE_CURRENCY_RIDING_STAMINA" then
                skillType = string_format(B.linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE3) .. B.linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_stamina.dds|t " or ""
            end
            return string_format("|r" .. icon .. "|cFFFFFF" .. skillType .. "|r|c" .. changeColor)
        end
        formattedMessageP1 = (string_format(messageChange, ResolveRidingStats(), messageP1))
    elseif type == "LUIE_CURRENCY_VENDOR" then
        item = string_format("|r" .. carriedItem .. "|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, item, messageP1))
    elseif type == "LUIE_CURRENCY_TRADE" then
        name = string_format("|r" .. S.g_tradeTarget .. "|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, messageP1, name))
    elseif type == "LUIE_CURRENCY_MAIL" then
        local mailCurrencyName = S.g_mailIncomingCurrencySender ~= "" and S.g_mailIncomingCurrencySender or S.g_mailTarget
        S.g_mailIncomingCurrencySender = ""
        name = string_format("|r" .. mailCurrencyName .. "|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, messageP1, name))
    else
        formattedMessageP1 = (string_format(messageChange, messageP1))
    end
    local formattedMessageP2 = (currencyTotal or (type == "LUIE_CURRENCY_VENDOR" and ChatAnnouncements.SV.Inventory.LootVendorTotalCurrency)) and (string_format(messageTotal, messageP2)) or messageP2
    local finalMessage
    if currencyTotal and type ~= "LUIE_CURRENCY_HERALDRY" and type ~= "LUIE_CURRENCY_VENDOR" and type ~= "LUIE_CURRENCY_POSTAGE" or (type == "LUIE_CURRENCY_VENDOR" and ChatAnnouncements.SV.Inventory.LootVendorTotalCurrency) then
        if type == "LUIE_CURRENCY_VENDOR" then
            finalMessage = string_format("|c%s%s|r%s |c%s%s|r", changeColor, formattedMessageP1, carriedItemTotal, changeColor, formattedMessageP2)
        else
            finalMessage = string_format("|c%s%s|r |c%s%s|r", changeColor, formattedMessageP1, changeColor, formattedMessageP2)
        end
    else
        if type == "LUIE_CURRENCY_VENDOR" then
            finalMessage = string_format("|c%s%s|r%s", changeColor, formattedMessageP1, carriedItemTotal)
        else
            finalMessage = string_format("|c%s%s|r", changeColor, formattedMessageP1)
        end
    end

    -- If this value is being sent from the Throttle Printer, do not throttle the printout of the value
    if type == "LUIE_CURRENCY_THROTTLE" then
        ChatOutput:Print(finalMessage)
        -- Otherwise sent to our Print Queued Messages function to be processed on a 50 ms delay.
    else
        local resolveType = (type == "LUIE_CURRENCY_POSTAGE" and "CURRENCY POSTAGE") or (baseCurrencyType == CURT_CROWNS and "EXPERIENCE") or "CURRENCY"
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = resolveType }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
end

function ChatAnnouncements.CurrencyGoldThrottlePrinter()
    if S.g_currencyGoldThrottleValue > 0 and S.g_currencyGoldThrottleValue > ChatAnnouncements.SV.Currency.CurrencyGoldFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(I.GetCarriedCurrencyAmount(1))
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(S.g_currencyGoldThrottleValue)
        local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and "|t16:16:/esoui/art/currency/currency_gold.dds|t" or ""
        local currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyGoldName"), S.g_currencyGoldThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
        local messageTotal = ChatAnnouncements.GetCurrencyMessageFormat("CurrencyMessageTotalGold")
        local messageChange = ChatAnnouncements.GetContextMessage("CurrencyMessageLoot")
        local type = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
    end
    S.g_currencyGoldThrottleValue = 0
    S.g_currencyGoldThrottleTotal = 0
end

function ChatAnnouncements.CurrencyAPThrottlePrinter()
    if S.g_currencyAPThrottleValue > 0 and S.g_currencyAPThrottleValue > ChatAnnouncements.SV.Currency.CurrencyAPFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(S.g_currencyAPThrottleTotal)
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(S.g_currencyAPThrottleValue)
        local currencyTypeColor = ColorizeColors.CurrencyAPColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and "|t16:16:/esoui/art/currency/alliancepoints.dds|t" or ""
        local currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyAPName"), S.g_currencyAPThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyAPShowTotal
        local messageTotal = ChatAnnouncements.GetCurrencyMessageFormat("CurrencyMessageTotalAP")
        local messageChange = ChatAnnouncements.GetContextMessage("CurrencyMessageEarn")
        local type = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedAP")
    S.g_currencyAPThrottleValue = 0
    S.g_currencyAPThrottleTotal = 0
end

function ChatAnnouncements.CurrencyTVThrottlePrinter()
    if S.g_currencyTVThrottleValue > 0 and S.g_currencyTVThrottleValue > ChatAnnouncements.SV.Currency.CurrencyTVFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(S.g_currencyTVThrottleTotal)
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(S.g_currencyTVThrottleValue)
        local currencyTypeColor = ColorizeColors.CurrencyTVColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and "|t16:16:/esoui/art/currency/currency_telvar.dds|t" or ""
        local currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyTVName"), S.g_currencyTVThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyTVShowTotal
        local messageTotal = ChatAnnouncements.GetCurrencyMessageFormat("CurrencyMessageTotalTV")
        local messageChange = ChatAnnouncements.GetContextMessage("CurrencyMessageLoot")
        local type = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedTV")
    S.g_currencyTVThrottleValue = 0
    S.g_currencyTVThrottleTotal = 0
end

function ChatAnnouncements.MiscAlertLockBroke(eventId, inactivityLengthMs)
    S.g_lockpickBroken = true
    zo_callLater(function ()
                     S.g_lockpickBroken = false
                 end, 200)
end

function ChatAnnouncements.MiscAlertLockSuccess(eventId)
    if ChatAnnouncements.SV.Notify.NotificationLockpickCA then
        local message = GetString(LUIE_STRING_CA_LOCKPICK_SUCCESS)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "NOTIFICATION" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_LOCKPICK_SUCCESS))
    end
    S.g_lockpickBroken = true
    zo_callLater(function ()
                     S.g_lockpickBroken = false
                 end, 200)
end

function ChatAnnouncements.StorageBag(eventId, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
        if ChatAnnouncements.SV.Notify.StorageBagCA then
            local formattedString = ColorizeColors.StorageBagColorize:Colorize(zo_strformat(SI_INVENTORY_BAG_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.StorageBagAlert then
            local text = zo_strformat(LUIE_STRING_CA_STORAGE_BAG_UPGRADE)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
        end
    end
end

function ChatAnnouncements.StorageBank(eventId, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
        if ChatAnnouncements.SV.Notify.StorageBagCA then
            local formattedString = ColorizeColors.StorageBagColorize:Colorize(zo_strformat(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.StorageBagAlert then
            local text = zo_strformat(LUIE_STRING_CA_STORAGE_BANK_UPGRADE)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
        end
    end
end

function ChatAnnouncements.OnBuybackItem(eventId, itemName, quantity, money, itemSound)
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ColorizeColors.CurrencyColorize:ToHex()
    end
    local itemIcon, _, _, _, _ = GetItemLinkInfo(itemName)
    local icon = itemIcon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local type = "LUIE_CURRENCY_VENDOR"
    local messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.GetContextMessage("CurrencyMessageBuyback") or ChatAnnouncements.GetContextMessage("CurrencyMessageBuybackNoV")
    local itemCount = quantity > 1 and (" |cFFFFFFx" .. quantity .. "|r") or ""
    local carriedItem
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        carriedItem = (formattedIcon .. itemName .. itemCount)
    else
        carriedItem = (formattedIcon .. zo_strgsub(itemName, "^|H0", "|H1", 1) .. itemCount)
    end

    local carriedItemTotal = ""
    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
        local total1, total2, total3 = GetItemLinkStacks(itemName)
        local total = total1 + total2 + total3
        if total > 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if S.g_savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(nil, S.g_savedPurchase.formattedValue, changeColor, S.g_savedPurchase.changeType, S.g_savedPurchase.currencyTypeColor, S.g_savedPurchase.currencyIcon, S.g_savedPurchase.currencyName, S.g_savedPurchase.currencyTotal, messageChange, S.g_savedPurchase.messageTotal, type, carriedItem, carriedItemTotal)
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "CURRENCY" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    S.g_savedPurchase = {}
end

-- TODO: Move to a data table outside of CA (maybe?)
local isShopCollectible =
{
    [GetCollectibleInfo(3)] = 3, -- Brown Paint Horse
    [GetCollectibleInfo(4)] = 4, -- Bay Dun Horse
    [GetCollectibleInfo(5)] = 5, -- Midnight Steed

    -- [GetCollectibleInfo(4673)] = 4673, -- Storage Coffer, Fortified (from level up rewards)
    [GetCollectibleInfo(4674)] = 4674, -- Storage Chest, Fortified (Tel Var / Writ Vouchers)
    [GetCollectibleInfo(4675)] = 4675, -- Storage Coffer, Oaken (Tel Var / Writ Vouchers)
    [GetCollectibleInfo(4676)] = 4676, -- Storage Coffer, Secure (Tel Var / Writ Vouchers)
    [GetCollectibleInfo(4677)] = 4677, -- Storage Coffer, Sturdy (Tel Var / Writ Vouchers)
    [GetCollectibleInfo(4678)] = 4678, -- Storage Chest, Oaken (Tel Var / Writ Vouchers)
    [GetCollectibleInfo(4679)] = 4679, -- Storage Chest, Secure (Tel Var / Writ Vouchers)
    [GetCollectibleInfo(4680)] = 4680, -- Storage Chest, Sturdy (Tel Var / Writ Vouchers)

    [GetCollectibleInfo(6706)] = 6706, -- Emerald Indrik Feather
    [GetCollectibleInfo(6707)] = 6707, -- Gilded Indrik Feather
    [GetCollectibleInfo(6708)] = 6708, -- Onyx Indrik Feather
    [GetCollectibleInfo(6709)] = 6709, -- Opaline Indrik Feather

    [GetCollectibleInfo(6659)] = 6659, -- Dawnwood Berries of Bloom
    [GetCollectibleInfo(6660)] = 6660, -- Dawnwood Berries of Budding
    [GetCollectibleInfo(6661)] = 6661, -- Dawnwood Berries of Growth
    [GetCollectibleInfo(6662)] = 6662, -- Dawnwood Berries of Ripeness

    [GetCollectibleInfo(6694)] = 6694, -- Luminous Berries of Bloom
    [GetCollectibleInfo(6695)] = 6695, -- Luminous Berries of Budding
    [GetCollectibleInfo(6696)] = 6696, -- Luminous Berries of Growth
    [GetCollectibleInfo(6697)] = 6697, -- Luminous Berries of Ripeness

    [GetCollectibleInfo(6698)] = 6698, -- Onyx Berries of Bloom
    [GetCollectibleInfo(6699)] = 6699, -- Onyx Berries of Budding
    [GetCollectibleInfo(6700)] = 6700, -- Onyx Berries of Growth
    [GetCollectibleInfo(6701)] = 6701, -- Onyx Berries of Ripeness

    [GetCollectibleInfo(6702)] = 6702, -- Pure-Snow Berries of Bloom
    [GetCollectibleInfo(6703)] = 6703, -- Pure-Snow Berries of Budding
    [GetCollectibleInfo(6704)] = 6704, -- Pure-Snow Berries of Growth
    [GetCollectibleInfo(6705)] = 6705, -- Pure-Snow Berries of Ripeness

    [GetCollectibleInfo(7021)] = 7021, -- Spectral Berries of Bloom
    [GetCollectibleInfo(7022)] = 7022, -- Spectral Berries of Budding
    [GetCollectibleInfo(7023)] = 7023, -- Spectral Berries of Growth
    [GetCollectibleInfo(7024)] = 7024, -- Spectral Berries of Ripeness

    [GetCollectibleInfo(7791)] = 7791, -- Icebreath Berries of Bloom
    [GetCollectibleInfo(7792)] = 7792, -- Icebreath Berries of Budding
    [GetCollectibleInfo(7793)] = 7793, -- Icebreath Berries of Growth
    [GetCollectibleInfo(7794)] = 7794, -- Icebreath Berries of Ripeness

    [GetCollectibleInfo(8126)] = 8126, -- Mossheart Berries of Bloom
    [GetCollectibleInfo(8127)] = 8127, -- Mossheart Berries of Budding
    [GetCollectibleInfo(8128)] = 8128, -- Mossheart Berries of Growth
    [GetCollectibleInfo(8129)] = 8129, -- Mossheart Berries of Ripeness

    [GetCollectibleInfo(8196)] = 8196, -- Pact Breton Terrier
    [GetCollectibleInfo(8197)] = 8197, -- Dominion Breton Terrier
    [GetCollectibleInfo(8198)] = 8198, -- Covenant Breton Terrier

    [GetCollectibleInfo(8866)] = 8866, -- Deadlands Flint (Unstable Morpholith)
    [GetCollectibleInfo(8867)] = 8867, -- Rune-Etched Striker (Unstable Morpholith)
    [GetCollectibleInfo(8868)] = 8868, -- Smoldering Bloodgrass Tinder (Unstable Morpholith)

    [GetCollectibleInfo(8869)] = 8869, -- Rune-Scribed Daedra Hide (Deadlands Scorcher)
    [GetCollectibleInfo(8870)] = 8870, -- Rune-Scribed Daedra Sleeve (Deadlands Scorcher)
    [GetCollectibleInfo(8871)] = 8871, -- Rune-Scribed Daedra Veil (Deadlands Scorcher)

    [GetCollectibleInfo(9085)] = 9085, -- Vial of Simmering Daedric Brew (Deadlands Firewalker)
    [GetCollectibleInfo(9086)] = 9086, -- Vial of Bubbling Daedric Brew (Deadlands Firewalker)
    [GetCollectibleInfo(9087)] = 9087, -- Vial of Scalding Daedric Brew (Deadlands Firewalker)

    [GetCollectibleInfo(9163)] = 9163, -- Black Iron Bit and Bridle (Dagonic Quasigriff)
    [GetCollectibleInfo(9164)] = 9164, -- Black Iron Stirrups (Dagonic Quasigriff)
    [GetCollectibleInfo(9162)] = 9162, -- Smoke-Wreathed Griffon Feather (Dagonic Quasigriff)
}

function ChatAnnouncements.OnBuyItem(eventId, itemName, entryType, quantity, money, specialCurrencyType1, specialCurrencyInfo1, specialCurrencyQuantity1, specialCurrencyType2, specialCurrencyInfo2, specialCurrencyQuantity2, itemSoundCategory)
    local itemIcon
    if entryType == STORE_ENTRY_TYPE_COLLECTIBLE then
        if isShopCollectible[itemName] then
            local id = isShopCollectible[itemName]
            itemName = GetCollectibleLink(id, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            itemIcon = select(3, GetCollectibleInfo(id))
        else
            itemIcon = GetItemLinkInfo(itemName)
        end
    end

    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ColorizeColors.CurrencyColorize:ToHex()
    end
    local icon = itemIcon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local type = "LUIE_CURRENCY_VENDOR"
    local messageChange = ((money ~= 0 or specialCurrencyQuantity1 ~= 0 or specialCurrencyQuantity2 ~= 0) and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.GetContextMessage("CurrencyMessageBuy") or ChatAnnouncements.GetContextMessage("CurrencyMessageBuyNoV")
    local itemCount = quantity > 1 and (" |cFFFFFFx" .. quantity .. "|r") or ""
    local carriedItem
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        carriedItem = (formattedIcon .. itemName .. itemCount)
    else
        carriedItem = (formattedIcon .. zo_strgsub(itemName, "^|H0", "|H1", 1) .. itemCount)
    end

    local carriedItemTotal = ""
    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
        local total1, total2, total3 = GetItemLinkStacks(itemName)
        local total = total1 + total2 + total3
        if total > 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if (money ~= 0 or specialCurrencyQuantity1 ~= 0 or specialCurrencyQuantity2 ~= 0) and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if S.g_savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(nil, S.g_savedPurchase.formattedValue, changeColor, S.g_savedPurchase.changeType, S.g_savedPurchase.currencyTypeColor, S.g_savedPurchase.currencyIcon, S.g_savedPurchase.currencyName, S.g_savedPurchase.currencyTotal, messageChange, S.g_savedPurchase.messageTotal, type, carriedItem, carriedItemTotal)
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "CURRENCY" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    S.g_savedPurchase = {}
end

function ChatAnnouncements.OnSellItem(eventId, itemName, quantity, money)
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ColorizeColors.CurrencyColorize:ToHex()
    end
    local itemIcon, _, _, _, _ = GetItemLinkInfo(itemName)
    local icon = itemIcon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local type = "LUIE_CURRENCY_VENDOR"
    local messageChange
    if S.g_weAreInAFence then
        messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.GetContextMessage("CurrencyMessageFence") or ChatAnnouncements.GetContextMessage("CurrencyMessageFenceNoV")
    else
        messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.GetContextMessage("CurrencyMessageSell") or ChatAnnouncements.GetContextMessage("CurrencyMessageSellNoV")
    end
    local itemCount = quantity > 1 and (" |cFFFFFFx" .. quantity .. "|r") or ""
    local carriedItem
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        carriedItem = (formattedIcon .. itemName .. itemCount)
    else
        carriedItem = (formattedIcon .. zo_strgsub(itemName, "^|H0", "|H1", 1) .. itemCount)
    end

    local carriedItemTotal = ""
    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
        local total1, total2, total3 = GetItemLinkStacks(itemName)
        local total = total1 + total2 + total3
        if total > 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if S.g_savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(nil, S.g_savedPurchase.formattedValue, changeColor, S.g_savedPurchase.changeType, S.g_savedPurchase.currencyTypeColor, S.g_savedPurchase.currencyIcon, S.g_savedPurchase.currencyName, S.g_savedPurchase.currencyTotal, messageChange, S.g_savedPurchase.messageTotal, type, carriedItem, carriedItemTotal)
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "CURRENCY" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    S.g_savedPurchase = {}
end

function ChatAnnouncements.TradingHouseResponseReceived(eventId, TradingHouseResult, result)
    -- Bail if a pending item isn't being sold
    if not TradingHouseResult == TRADING_HOUSE_RESULT_POST_PENDING then
        return
    end
    -- If we don't have both a valid saved currency transaction and saved message then bail out.
    if not S.g_savedPurchase.formattedValue or not S.g_savedItem.itemLink then
        S.g_savedPurchase = {}
        S.g_savedItem = {}
        return
    end

    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ColorizeColors.CurrencyColorize:ToHex()
    end
    local type = "LUIE_CURRENCY_VENDOR"
    local messageChange = ChatAnnouncements.GetContextMessage("CurrencyMessageListingValue")

    local icon = S.g_savedItem.icon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local stack = S.g_savedItem.stack
    local itemCount = stack > 1 and (" |cFFFFFFx" .. stack .. "|r") or ""
    local itemName = S.g_savedItem.itemLink

    local carriedItem
    if ChatAnnouncements.SV.BracketOptionItem == 1 then
        carriedItem = (formattedIcon .. itemName .. itemCount)
    else
        carriedItem = (formattedIcon .. zo_strgsub(itemName, "^|H0", "|H1", 1) .. itemCount)
    end

    local carriedItemTotal = ""
    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
        local total1, total2, total3 = GetItemLinkStacks(itemName)
        local total = total1 + total2 + total3
        if total > 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        ChatAnnouncements.CurrencyPrinter(nil, S.g_savedPurchase.formattedValue, changeColor, S.g_savedPurchase.changeType, S.g_savedPurchase.currencyTypeColor, S.g_savedPurchase.currencyIcon, S.g_savedPurchase.currencyName, S.g_savedPurchase.currencyTotal, messageChange, S.g_savedPurchase.messageTotal, type, carriedItem, carriedItemTotal)
    else
        type = "CURRENCY"
        messageChange = ChatAnnouncements.GetContextMessage("CurrencyMessageList")
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = type }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        messageChange = ChatAnnouncements.GetContextMessage("CurrencyMessageListing")
        ChatAnnouncements.CurrencyPrinter(nil, S.g_savedPurchase.formattedValue, changeColor, S.g_savedPurchase.changeType, S.g_savedPurchase.currencyTypeColor, S.g_savedPurchase.currencyIcon, S.g_savedPurchase.currencyName, S.g_savedPurchase.currencyTotal, messageChange, S.g_savedPurchase.messageTotal, type)
    end
    S.g_savedPurchase = {}
    S.g_savedItem = {}
end

function ChatAnnouncements.MailMoneyChanged(eventId)
    S.g_mailCOD = 0
    S.g_postageAmount = GetQueuedMailPostage()
    local previousMailAmount = S.g_mailAmount
    local getMailAmount = GetQueuedMoneyAttachment()
    -- If we send more then half of the gold in our bags for some reason this event fires again so this is a workaround
    if getMailAmount == GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) and getMailAmount ~= previousMailAmount then
        return
    else
        S.g_mailAmount = getMailAmount
    end
end

function ChatAnnouncements.MailCODChanged(eventId)
    S.g_mailCOD = GetQueuedCOD()
    S.g_postageAmount = GetQueuedMailPostage()
    S.g_mailAmount = GetQueuedMoneyAttachment()
end

function I.IsMailLootActive()
    return S.g_inMail or S.g_mailIsTakingMail or S.g_mailBatchTakeAll or #S.g_mailItemSenderFifo > 0
end

function I.TouchMailNotifySuppressWindow()
    S.g_mailNotifySuppressUntilMs = GetGameTimeMilliseconds() + MAIL_NOTIFY_SUPPRESS_AFTER_LOOT_MS
end

--- Loot Mail item lines already cover the take; skip redundant Mail received / Mail deleted notifications.
function I.ShouldSkipMailReceivedDeletedNotifications()
    if not ChatAnnouncements.SV.Inventory.LootMail then
        return false
    end
    if I.IsMailLootActive() then
        return true
    end
    return GetGameTimeMilliseconds() < S.g_mailNotifySuppressUntilMs
end

function ChatAnnouncements.MailRemoved(eventId)
    if I.ShouldSkipMailReceivedDeletedNotifications() then
        return
    end
    if ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
        if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
            local message = GetString(LUIE_STRING_CA_MAIL_DELETED_MSG)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_MAIL_DELETED_MSG))
        end
    end
end

-- Guild trader sale proceeds use system mail with subject "Item Sold" (localized; must match client).
function I.IsGuildStoreItemSoldMail(fromSystem, subject)
    if not fromSystem or subject == nil or subject == "" then
        return false
    end
    return subject == GetString(LUIE_STRING_CA_MAIL_GUILD_STORE_ITEM_SOLD_SUBJECT)
end

function I.ResolveGuildStoreSaleMailSender(authoritativeSender)
    local displayName = (authoritativeSender and authoritativeSender ~= "") and authoritativeSender
        or GetString(SI_GAMEPAD_GUILD_HEADER_GUILD_SERVICES_STORE)
    return ZO_GAME_REPRESENTATIVE_TEXT:Colorize(displayName)
end

-- Resolve sender display string and COD/attachment info for a mail (used by Take All queue).
function I.ResolveMailSender(mailId)
    local senderDisplayName, senderCharacterName, subject, _, _, fromSystem, fromCustomerService, _, numAttachments, attachedMoney, codAmount = GetMailItemInfo(mailId)
    numAttachments = numAttachments or 0
    attachedMoney = attachedMoney or 0
    local mailTarget = ""
    local authoritativeSender = GetMailSender(mailId)
    if I.IsGuildStoreItemSoldMail(fromSystem, subject) then
        mailTarget = I.ResolveGuildStoreSaleMailSender(authoritativeSender)
    elseif fromSystem or fromCustomerService then
        if authoritativeSender and authoritativeSender ~= "" then
            mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(authoritativeSender)
        else
            mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(senderDisplayName or "")
        end
    elseif senderDisplayName ~= "" or senderCharacterName ~= "" then
        local finalName
        if senderDisplayName ~= "" and senderCharacterName ~= "" then
            finalName = ChatAnnouncements.ResolveNameLink(senderCharacterName, senderDisplayName)
        elseif senderDisplayName ~= "" then
            finalName = ChatAnnouncements.CreateDisplayNameLink(senderDisplayName, senderDisplayName)
        else
            finalName = ChatAnnouncements.CreateCharacterLink(senderCharacterName)
        end
        mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
    end
    if mailTarget == "" and (numAttachments > 0 or attachedMoney > 0) then
        if authoritativeSender and authoritativeSender ~= "" then
            mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(authoritativeSender)
        end
    end
    -- Gold from NPC/system services (e.g. Guild Store) often only has a reliable name in GetMailSender.
    if attachedMoney > 0 and authoritativeSender and authoritativeSender ~= "" and (fromSystem or fromCustomerService or senderCharacterName == "") then
        mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(authoritativeSender)
    end
    return mailTarget, (codAmount and codAmount > 0), numAttachments, attachedMoney
end

function I.MailCurrencyDedupeIdsMatch(a, b)
    if a == nil and b == nil then
        return true
    end
    if a == nil or b == nil then
        return false
    end
    return CompareId64s(a, b) == 0
end

function I.StoreMailSenderForMailId(mailId, mailTarget)
    if mailId and mailTarget and mailTarget ~= "" then
        S.g_mailSenderMap[mailId] = mailTarget
    end
end

-- Build sender queue in Take All order (by category/index; one entry per attached gold).
-- Batch item loot uses g_mailItemSenderFifo, not this queue.
-- categoryFilter: when set, only that MailCategory is queued (category Take All).
function I.EnqueueMailLootEntry(mailId, mailTarget)
    table.insert(S.g_mailLootQueue, { mailId = mailId, sender = mailTarget })
end

function I.PopMailLootEntry()
    if #S.g_mailLootQueue > 0 then
        return table.remove(S.g_mailLootQueue, 1)
    end
    return nil
end

function I.IsMailInLootLogPrefix(logPrefix)
    return ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageMailIn")
        or ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageMailInNoName")
end

function I.PrintMailDelayedLootLines(sortByMailId)
    if #S.g_mailDelayedLootLines == 0 then
        return
    end
    if sortByMailId then
        table.sort(S.g_mailDelayedLootLines, function (a, b)
            if a.mailId and b.mailId then
                local cmp = CompareId64s(a.mailId, b.mailId)
                if cmp ~= 0 then
                    return cmp < 0
                end
            elseif a.mailId then
                return true
            elseif b.mailId then
                return false
            end
            return a.order < b.order
        end)
    end
    for i = 1, #S.g_mailDelayedLootLines do
        local data = S.g_mailDelayedLootLines[i]
        ChatAnnouncements.ItemPrinter(data.icon, data.stack, data.itemType, data.itemId, data.itemLink, data.receivedBy, data.logPrefix, data.gainOrLoss, data.filter, data.groupLoot, data.alwaysFirst, data.delay)
    end
    S.g_mailDelayedLootLines = {}
    S.g_mailLootLineSequence = 0
end

function ChatAnnouncements.FlushMailDelayedLootLines()
    I.PrintMailDelayedLootLines(true)
end

function ChatAnnouncements.SendDelayedMailItems()
    if S.g_mailBatchTakeAll then
        return
    end
    I.PrintMailDelayedLootLines(false)
end

--- Clears mail loot/session state. When preserveMailboxOpen is true, keeps S.g_inMail and S.g_mailTarget (mailbox still open after Take All).
--- @param preserveMailboxOpen boolean|nil
function ChatAnnouncements.ResetMailSession(preserveMailboxOpen)
    if preserveMailboxOpen then
        S.g_mailIsTakingMail = false
        S.g_mailBatchTakeAll = false
        S.g_mailLootQueue = {}
        S.g_mailSenderMap = {}
        S.g_mailDelayedLootLines = {}
        S.g_mailLootLineSequence = 0
        S.g_mailIncomingCurrencySender = ""
        S.g_mailPendingCurrencySender = ""
        S.g_mailPendingCurrencyMailId = nil
        S.g_mailPendingItemSender = ""
        S.g_mailItemSenderFifo = {}
        eventManager:UnregisterForUpdate(moduleName .. "ClearMailTakingFlag")
        eventManager:UnregisterForUpdate(moduleName .. "FlushMailLoot")
        return
    end
    S.g_inMail = false
    S.g_mailTarget = ""
    S.g_mailCODPresent = false
    S.g_mailIsTakingMail = false
    S.g_mailBatchTakeAll = false
    S.g_mailStacksOut = {}
    S.g_mailLootQueue = {}
    S.g_mailSenderMap = {}
    S.g_mailDelayedLootLines = {}
    S.g_mailLootLineSequence = 0
    S.g_mailIncomingCurrencySender = ""
    S.g_mailPendingCurrencySender = ""
    S.g_mailPendingCurrencyMailId = nil
    S.g_mailPendingItemSender = ""
    S.g_mailItemSenderFifo = {}
    S.g_mailNotifySuppressUntilMs = 0
    eventManager:UnregisterForUpdate(moduleName .. "SendDelayedMailItems")
    eventManager:UnregisterForUpdate(moduleName .. "ClearMailTakingFlag")
    eventManager:UnregisterForUpdate(moduleName .. "FlushMailLoot")
end

function I.PopulateMailSenderQueue(categoryFilter)
    S.g_mailLootQueue = {}
    S.g_mailSenderMap = {}
    local categoryBegin = categoryFilter ~= nil and categoryFilter or MAIL_CATEGORY_ITERATION_BEGIN
    local categoryEnd = categoryFilter ~= nil and categoryFilter or MAIL_CATEGORY_ITERATION_END
    for category = categoryBegin, categoryEnd do
        local numMailItems = GetNumMailItemsByCategory(category)
        for index = 1, numMailItems do
            local mailId = GetMailIdByIndex(category, index)
            if mailId then
                local mailTarget, hasCOD, numAttachments, attachedMoney = I.ResolveMailSender(mailId)
                if (numAttachments and numAttachments > 0) or (attachedMoney and attachedMoney > 0) then
                    if attachedMoney > 0 then
                        I.EnqueueMailLootEntry(mailId, mailTarget)
                    end
                    I.StoreMailSenderForMailId(mailId, mailTarget)
                end
            end
        end
    end
end

--- Returns the next sender from the Take All queue, or "" if queue is empty (e.g. single mail open).
function ChatAnnouncements.GetNextMailSender()
    local entry = I.PopMailLootEntry()
    if entry and entry.sender then
        return entry.sender
    end
    return ""
end

function I.GetMailSenderForInventoryLoot()
    local mailSender = ""
    local mailId
    if #S.g_mailItemSenderFifo > 0 then
        local fifoEntry = table.remove(S.g_mailItemSenderFifo, 1)
        mailSender = fifoEntry.sender or ""
        mailId = fifoEntry.mailId
    elseif S.g_mailPendingItemSender ~= "" then
        mailSender = S.g_mailPendingItemSender
        S.g_mailPendingItemSender = ""
    else
        local entry = I.PopMailLootEntry()
        if entry then
            mailSender = entry.sender or ""
            mailId = entry.mailId
        end
    end
    if mailSender == "" and mailId and S.g_mailSenderMap[mailId] then
        mailSender = S.g_mailSenderMap[mailId]
    end
    if mailSender == "" and not S.g_mailBatchTakeAll then
        mailSender = S.g_mailTarget
    end
    local logPrefix = mailSender ~= "" and ChatAnnouncements.GetContextMessage("CurrencyMessageMailIn") or ChatAnnouncements.GetContextMessage("CurrencyMessageMailInNoName")
    return mailSender, logPrefix, mailId
end

function I.OnPreTakeAllMailAttachmentsInCategory(category, deleteOnClaim)
    S.g_mailBatchTakeAll = true
    S.g_mailIsTakingMail = true
    I.TouchMailNotifySuppressWindow()
    S.g_mailPendingCurrencySender = ""
    S.g_mailPendingCurrencyMailId = nil
    S.g_mailPendingItemSender = ""
    S.g_mailDelayedLootLines = {}
    S.g_mailLootLineSequence = 0
    eventManager:UnregisterForUpdate(moduleName .. "SendDelayedItems")
    -- Inventory updates usually run before EVENT_MAIL_TAKE_*_SUCCESS during category Take All.
    I.PopulateMailSenderQueue(category)
end

function ChatAnnouncements.InstallTakeAllMailHook()
    if ChatAnnouncements._takeAllMailHookInstalled then
        return
    end
    -- ZO_PreHook global API (EsoUI/Libraries/Utility/ZO_Hook.lua); must run before the C call applies loot.
    local hookedGlobal = ZO_PreHook("TakeAllMailAttachmentsInCategory", I.OnPreTakeAllMailAttachmentsInCategory)
    if not hookedGlobal and ESO_Dialogs["MAIL_CONFIRM_TAKE_ALL"] then
        local takeAllButton = ESO_Dialogs["MAIL_CONFIRM_TAKE_ALL"].buttons[1]
        if takeAllButton then
            ZO_PreHook(takeAllButton, "callback", function (dialog)
                local category = dialog.data.category
                I.OnPreTakeAllMailAttachmentsInCategory(category, MAIL_MANAGER:ShouldDeleteOnClaim())
            end)
        end
    end
    ChatAnnouncements._takeAllMailHookInstalled = true
end

function ChatAnnouncements.OnMailReadable(eventId, mailId)
    local senderDisplayName, senderCharacterName, _, _, _, fromSystem, fromCustomerService, _, _, _, codAmount = GetMailItemInfo(mailId)

    -- Use different color if the mail is from System (Hireling Mail, Rewards for the Worthy, etc)
    if fromSystem or fromCustomerService then
        S.g_mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(senderDisplayName)
    elseif senderDisplayName ~= "" and senderCharacterName ~= "" then
        local finalName = ChatAnnouncements.ResolveNameLink(senderCharacterName, senderDisplayName)
        S.g_mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
    else
        local finalName
        if senderDisplayName ~= "" then
            finalName = ChatAnnouncements.CreateDisplayNameLink(senderDisplayName, senderDisplayName)
        elseif senderCharacterName ~= "" then
            finalName = ChatAnnouncements.CreateCharacterLink(senderCharacterName)
        else
            finalName = ""
        end
        S.g_mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
    end

    S.g_mailCODPresent = (codAmount and codAmount > 0)
end

function ChatAnnouncements.OnMailTakeAttachedItem(eventId, mailId)
    S.g_mailIsTakingMail = true
    I.TouchMailNotifySuppressWindow()
    local mailTarget, hasCOD, numAttachments = I.ResolveMailSender(mailId)
    I.StoreMailSenderForMailId(mailId, mailTarget)
    S.g_mailCODPresent = hasCOD
    numAttachments = numAttachments or 0
    if numAttachments < 1 then
        numAttachments = 1
    end
    for _ = 1, numAttachments do
        S.g_mailItemSenderFifo[#S.g_mailItemSenderFifo + 1] = { mailId = mailId, sender = mailTarget }
    end
    if not S.g_mailBatchTakeAll then
        I.EnqueueMailLootEntry(mailId, mailTarget)
    end

    eventManager:UnregisterForUpdate(moduleName .. "ClearMailTakingFlag")
    eventManager:RegisterForUpdate(moduleName .. "ClearMailTakingFlag", 200, function ()
        S.g_mailIsTakingMail = false
        eventManager:UnregisterForUpdate(moduleName .. "ClearMailTakingFlag")
        if not S.g_mailBatchTakeAll then
            eventManager:UnregisterForUpdate(moduleName .. "SendDelayedMailItems")
            ChatAnnouncements.SendDelayedMailItems()
        end
    end)

    if not I.ShouldSkipMailReceivedDeletedNotifications() and (ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert) then
        local mailString
        if hasCOD then
            mailString = GetString(LUIE_STRING_CA_MAIL_RECEIVED_COD)
        else
            mailString = GetString(LUIE_STRING_CA_MAIL_RECEIVED)
        end
        if mailString then
            if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = mailString, type = "NOTIFICATION", isSystem = true }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, mailString)
            end
        end
    end
end

function ChatAnnouncements.OnMailTakeAttachedMoney(eventId, mailId)
    S.g_mailIsTakingMail = true
    I.TouchMailNotifySuppressWindow()
    local mailTarget = I.ResolveMailSender(mailId)
    I.StoreMailSenderForMailId(mailId, mailTarget)
    S.g_mailPendingCurrencySender = mailTarget
    S.g_mailPendingCurrencyMailId = mailId
    if not S.g_mailBatchTakeAll then
        I.EnqueueMailLootEntry(mailId, mailTarget)
    end
    eventManager:UnregisterForUpdate(moduleName .. "ClearMailTakingFlag")
    eventManager:RegisterForUpdate(moduleName .. "ClearMailTakingFlag", 200, function ()
        S.g_mailIsTakingMail = false
        eventManager:UnregisterForUpdate(moduleName .. "ClearMailTakingFlag")
    end)
end

function ChatAnnouncements.OnMailTakeAllResponse(eventId, result, category, headersRemoved)
    local function FinishMailTakeAllBatch()
        ChatAnnouncements.FlushMailDelayedLootLines()
        ChatAnnouncements.ResetMailSession(true)
    end
    ChatAnnouncements.FlushMailDelayedLootLines()
    eventManager:UnregisterForUpdate(moduleName .. "FlushMailLoot")
    eventManager:RegisterForUpdate(moduleName .. "FlushMailLoot", 75, FinishMailTakeAllBatch)
end

function ChatAnnouncements.OnMailInboxUpdate(eventId)
    -- Sender queue is built in OnMailOpenBox and OnPreTakeAllMailAttachmentsInCategory only.
end

function ChatAnnouncements.OnMailAttach(eventId, attachmentSlot)
    S.g_postageAmount = GetQueuedMailPostage()
    S.g_mailAmount = GetQueuedMoneyAttachment()
    local mailIndex = attachmentSlot
    local bagId, slotId, icon, stack = GetQueuedItemAttachmentInfo(attachmentSlot)
    local itemId = GetItemId(bagId, slotId)
    local itemLink = GetMailQueuedAttachmentLink(attachmentSlot, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
    local itemType = GetItemLinkItemType(itemLink)
    S.g_mailStacksOut[mailIndex] = { icon = icon, stack = stack, itemId = itemId, itemLink = itemLink, itemType = itemType }
end

-- Removes items from index if they are removed from the trade
function ChatAnnouncements.OnMailAttachRemove(eventId, attachmentSlot)
    S.g_postageAmount = GetQueuedMailPostage()
    S.g_mailAmount = GetQueuedMoneyAttachment()
    local mailIndex = attachmentSlot
    S.g_mailStacksOut[mailIndex] = nil
end

function ChatAnnouncements.OnMailOpenBox(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootMail then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        S.g_inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
    S.g_inMail = true
end

function ChatAnnouncements.OnMailCloseBox(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        S.g_inventoryStacks = {}
    end
    eventManager:UnregisterForUpdate(moduleName .. "SendDelayedMailItems")
    ChatAnnouncements.SendDelayedMailItems()
    ChatAnnouncements.FlushMailDelayedLootLines()
    ChatAnnouncements.ResetMailSession()
end

-- Sends results of the trade to the Item Log print function and clears variables so they are reset for next trade interactions

function ChatAnnouncements.OnMailSuccess(eventId)
    local formattedValue = ZO_CommaDelimitDecimalNumber(I.GetCarriedCurrencyAmount(1))
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
    local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and "|t16:16:/esoui/art/currency/currency_gold.dds|t" or ""
    local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
    local messageTotal = ChatAnnouncements.GetCurrencyMessageFormat("CurrencyMessageTotalGold")

    if S.g_postageAmount > 0 then
        local type = "LUIE_CURRENCY_POSTAGE"
        local changeType = ZO_CommaDelimitDecimalNumber(S.g_postageAmount)
        local currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyGoldName"), S.g_postageAmount)
        local messageChange = ChatAnnouncements.GetContextMessage("CurrencyMessagePostage")
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
    end

    if not S.g_mailCODPresent and S.g_mailAmount > 0 then
        local type = "LUIE_CURRENCY_MAIL"
        local changeType = ZO_CommaDelimitDecimalNumber(S.g_mailAmount)
        local currencyName = zo_strformat(ChatAnnouncements.GetCurrencyDisplayNameFormat("CurrencyGoldName"), S.g_mailAmount)
        local messageChange = S.g_mailTarget ~= "" and ChatAnnouncements.GetContextMessage("CurrencyMessageMailOut") or ChatAnnouncements.GetContextMessage("CurrencyMessageMailOutNoName")
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, type)
    end

    if ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
        local mailString
        if not S.g_mailCODPresent then
            mailString = S.g_mailCOD > 1 and GetString(LUIE_STRING_CA_MAIL_SENT_COD) or GetString(LUIE_STRING_CA_MAIL_SENT)
        end
        if mailString then
            if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = mailString, type = "NOTIFICATION", isSystem = true }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, mailString)
            end
        end
    end

    if ChatAnnouncements.SV.Inventory.LootMail then
        for mailIndex = 1, 6 do
            local item = S.g_mailStacksOut[mailIndex]
            if item ~= nil then
                local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                local logPrefix = S.g_mailTarget ~= "" and ChatAnnouncements.GetContextMessage("CurrencyMessageMailOut") or ChatAnnouncements.GetContextMessage("CurrencyMessageMailOutNoName")
                ChatAnnouncements.ItemCounterDelayOut(item.icon, item.stack, item.itemType, item.itemId, item.itemLink, S.g_mailTarget, logPrefix, gainOrLoss, false)
            end
        end
    end

    S.g_mailCODPresent = false
    S.g_mailCOD = 0
    S.g_postageAmount = 0
    S.g_mailAmount = 0
    S.g_mailStacksOut = {}
end

-- Helper function to return color (without |c prefix) according to current percentage
function I.AchievementPctToColor(pct)
    return pct == 1 and "71DE73" or pct < 0.33 and "F27C7C" or pct < 0.66 and "EDE858" or "CCF048"
end

--- @param achievementId any
--- @return number|nil
function I.GetCategoryInfoFromAchievementIdDetailed(achievementId)
    -- If the user is selecting from the recent achievements list, there
    --  will not be an open category id, so attempt to get the category
    --  from the achievement.
    local categoryId = GetCategoryInfoFromAchievementId(achievementId)
    if categoryId then
        return categoryId
    end

    -- Some achievements cannot find their category id properly, so try
    --  walking the achievement chain and look for one that has a category
    --  id.
    local tryAchievementId = GetFirstAchievementInLine(achievementId)
    while tryAchievementId ~= 0 do
        categoryId = GetCategoryInfoFromAchievementId(tryAchievementId)
        if categoryId then
            return categoryId
        end
        tryAchievementId = GetNextAchievementInLine(tryAchievementId)
    end

    -- We were unable to determine the correct category id.
    return nil
end

function ChatAnnouncements.OnAchievementUpdated(eventId, id)
    local topLevelIndex, categoryIndex, achievementIndex = I.GetCategoryInfoFromAchievementIdDetailed(id)
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

                if percentage > 0 and percentage % ChatAnnouncements.SV.Achievement.AchievementStep == 0 and S.g_achievementLastPercentage[id] ~= percentage then
                    showInfo = true
                    S.g_achievementLastPercentage[id] = percentage
                end
            end
        end

        -- Bail out here if this achievement update event is not going to be printed to chat
        if not showInfo then
            return
        end

        local link = zo_strformat(GetAchievementLink(id, B.linkBrackets[ChatAnnouncements.SV.BracketOptionAchievement]))
        local name = zo_strformat(GetAchievementNameFromLink(link))

        if ChatAnnouncements.SV.Achievement.AchievementUpdateCA then
            local catName = GetAchievementCategoryInfo(topLevelIndex)
            local subcatName = categoryIndex ~= nil and GetAchievementSubCategoryInfo(topLevelIndex, categoryIndex) or GetString(SI_JOURNAL_PROGRESS_CATEGORY_GENERAL)
            local _, _, _, icon = GetAchievementInfo(id)
            icon = ChatAnnouncements.SV.Achievement.AchievementIcon and ("|t16:16:" .. icon .. "|t ") or ""

            -- Build string parts without using string_format on pre-formatted strings
            local stringpart1 = ColorizeColors.AchievementColorize1:Colorize(
                B.bracket1[ChatAnnouncements.SV.Achievement.AchievementBracketOptions] ..
                ChatAnnouncements.GetModuleMessageFormat("Achievement", "AchievementProgressMsg") ..
                B.bracket2[ChatAnnouncements.SV.Achievement.AchievementBracketOptions] .. " " ..
                icon .. link
            )

            local stringpart2 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and
                ColorizeColors.AchievementColorize2:Colorize(" (") ..
                "|c" .. I.AchievementPctToColor(totalCmp / totalReq) .. zo_floor(100 * totalCmp / totalReq) .. "%|r" ..
                ColorizeColors.AchievementColorize2:Colorize(")") or
                ColorizeColors.AchievementColorize2:Colorize(" (" .. zo_floor(100 * totalCmp / totalReq) .. "%)")

            local stringpart3 = ""
            if ChatAnnouncements.SV.Achievement.AchievementCategory then
                stringpart3 = ColorizeColors.AchievementColorize2:Colorize(
                    " " .. B.bracket3[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions] ..
                    catName ..
                    (ChatAnnouncements.SV.Achievement.AchievementSubcategory and (" - " .. subcatName) or "") ..
                    B.bracket4[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions]
                )
            end

            -- Prepare details information
            local stringpart4 = ""
            if ChatAnnouncements.SV.Achievement.AchievementDetails then
                -- Skyshards needs separate treatment otherwise text become too long
                -- We also put this short information for achievements that has too many subitems
                if topLevelIndex == 9 or #cmpInfo > 12 then
                    stringpart4 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and
                        ColorizeColors.AchievementColorize2:Colorize(" (") ..
                        "|c" .. I.AchievementPctToColor(totalCmp / totalReq) .. totalCmp .. "|r" ..
                        ColorizeColors.AchievementColorize2:Colorize("/") ..
                        "|c71DE73" .. totalReq .. "|r" ..
                        ColorizeColors.AchievementColorize2:Colorize(")") or
                        ColorizeColors.AchievementColorize2:Colorize(" (" .. totalCmp .. "/" .. totalReq .. ")")
                else
                    for i = 1, #cmpInfo do
                        if cmpInfo[i][3] == 1 then
                            cmpInfo[i] = "|c" .. I.AchievementPctToColor(cmpInfo[i][2]) .. cmpInfo[i][1] .. "|r"
                        else
                            local pct = cmpInfo[i][2] / cmpInfo[i][3]
                            cmpInfo[i] = ColorizeColors.AchievementColorize2:Colorize(cmpInfo[i][1] .. " (") ..
                                "|c" .. I.AchievementPctToColor(pct) .. cmpInfo[i][2] .. "|r" ..
                                ColorizeColors.AchievementColorize2:Colorize("/") ..
                                "|c71DE73" .. cmpInfo[i][3] .. "|r" ..
                                ColorizeColors.AchievementColorize2:Colorize(")")
                        end
                    end
                    stringpart4 = table_concat(cmpInfo, ColorizeColors.AchievementColorize2:Colorize(", "))
                end
            end

            -- Concatenate final string without using string_format
            local finalString = stringpart1 .. stringpart2 .. stringpart3 .. stringpart4
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalString, type = "ACHIEVEMENT" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Achievement.AchievementUpdateAlert then
            local alertMessage = zo_strformat("<<1>>: <<2>>", ChatAnnouncements.GetModuleMessageFormat("Achievement", "AchievementProgressMsg"), name)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertMessage)
        end
    end
end

--- @param index luaindex
--- @param timedActivityEncodedId id64|nil Event or tracked encoded id when index lookup may be stale
--- @return string
function I.GetTimedActivityProgressAnnounceKey(index, timedActivityEncodedId)
    if timedActivityEncodedId ~= nil then
        return string_format("e:%s", Id64ToString(timedActivityEncodedId))
    end
    local encodedId = GetTimedActivityEncodedId(index)
    if encodedId ~= nil then
        return string_format("e:%s", Id64ToString(encodedId))
    end
    local activityId = GetTimedActivityId(index)
    if activityId and activityId > 0 then
        return string_format("id:%i", activityId)
    end
    return string_format("i:%i", index)
end

--- Suppress duplicate chat/alert for the same challenge slot at the same progress (2 game events --> 2 lines, not 4).
--- @param index luaindex
--- @param currentProgress integer
--- @param timedActivityEncodedId id64|nil
--- @return boolean suppress
function I.ShouldSuppressTimedActivityProgressAnnounce(index, currentProgress, timedActivityEncodedId)
    local key = I.GetTimedActivityProgressAnnounceKey(index, timedActivityEncodedId)
    local nowMs = GetFrameTimeMilliseconds()
    local last = S.g_lastTimedActivityProgressAnnounce[key]
    if last and last.progress == currentProgress and (nowMs - last.timeMs) < TIMED_ACTIVITY_PROGRESS_ANNOUNCE_DEDUPE_MS then
        return true
    end
    return false
end

--- @param index luaindex
--- @param currentProgress integer
--- @param timedActivityEncodedId id64|nil
function I.RecordTimedActivityProgressAnnounce(index, currentProgress, timedActivityEncodedId)
    local key = I.GetTimedActivityProgressAnnounceKey(index, timedActivityEncodedId)
    S.g_lastTimedActivityProgressAnnounce[key] =
    {
        progress = currentProgress,
        timeMs = GetFrameTimeMilliseconds(),
    }
end

--- @param message string
--- @param encodedIdKey string|nil Same-slot key from GetTimedActivityProgressAnnounceKey; skips duplicate queue rows for one print batch
function I.QueueTimedActivityChatMessage(message, encodedIdKey)
    for i = 1, ChatAnnouncements.QueuedMessagesCounter - 1 do
        local queued = ChatAnnouncements.QueuedMessages[i]
        if queued and queued.type == "MESSAGE" then
            if queued.message == message then
                return
            end
            if encodedIdKey and queued.timedActivityAnnounceKey == encodedIdKey and queued.message == message then
                return
            end
        end
    end
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
    {
        message = message,
        type = "MESSAGE",
        timedActivityAnnounceKey = encodedIdKey,
    }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

--- @param index luaindex
--- @param currentProgress integer
--- @param maxProgress integer
--- @param chatEnabled boolean
--- @param alertEnabled boolean
--- @param timedActivityEncodedId id64|nil
function I.AnnounceTimedActivityProgress(index, currentProgress, maxProgress, chatEnabled, alertEnabled, timedActivityEncodedId)
    if I.ShouldSuppressTimedActivityProgressAnnounce(index, currentProgress, timedActivityEncodedId) then
        return
    end
    I.RecordTimedActivityProgressAnnounce(index, currentProgress, timedActivityEncodedId)
    local announceKey = I.GetTimedActivityProgressAnnounceKey(index, timedActivityEncodedId)
    if chatEnabled then
        local message = I.BuildTimedActivityMessage(index, currentProgress, maxProgress)
        I.QueueTimedActivityChatMessage(message, announceKey)
    end
    if alertEnabled then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, I.BuildTimedActivityMessage(index, currentProgress, maxProgress, true))
    end
end

--- Claimed suffix for challenges (matches Timed Activities UI when total claimable > 0).
--- @param index luaindex
--- @param forAlert boolean|nil
--- @return string suffix Empty when infinitely repeatable (total claimable == 0)
function I.BuildTimedActivityClaimedSuffix(index, forAlert)
    local totalClaimable = GetTimedActivityTotalNumTimesClaimable(index)
    if totalClaimable <= 0 then
        return ""
    end
    local numClaimed = GetTimedActivityNumTimesClaimed(index)
    local formatStr = GetString(SI_TIMED_ACTIVITY_CLAIMED_PROGRESS):gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
    local claimedProgress = zo_strformat(formatStr, numClaimed, totalClaimable)
    if forAlert then
        return string_format(" |cAAAAAA[%s]|r", claimedProgress)
    end
    return " [" .. claimedProgress .. "]"
end

--- @param index luaindex
--- @param currentProgress integer|nil
--- @param maxProgress integer|nil
--- @param forAlert boolean|nil
--- @return string
function I.BuildTimedActivityMessage(index, currentProgress, maxProgress, forAlert)
    local name = GetTimedActivityName(index)
    local activityType = GetTimedActivityType(index)
    currentProgress = currentProgress or GetTimedActivityProgress(index)
    maxProgress = maxProgress or GetTimedActivityMaxProgress(index)
    local progress = string_format("%i / %i", currentProgress, maxProgress)
    local claimedSuffix = I.BuildTimedActivityClaimedSuffix(index, forAlert)
    local typeName
    if activityType == TIMED_ACTIVITY_TYPE_DAILY then
        typeName = GetString(SI_TIMEDACTIVITYTYPE0)
    elseif activityType == TIMED_ACTIVITY_TYPE_WEEKLY then
        typeName = GetString(SI_TIMEDACTIVITYTYPE1)
    elseif activityType == TIMED_ACTIVITY_TYPE_SEASONAL then
        typeName = GetString(SI_TIMEDACTIVITYTYPE2) or "Seasonal"
    else
        typeName = tostring(activityType)
    end
    local challengeHeader = string_format("[%s]", zo_strformat(GetString(SI_TIMED_ACTIVITIES_TYPE_HEADER), typeName))
    local bracketOpt = ChatAnnouncements.SV.BracketOptionItem or 1
    local formattedName = (bracketOpt == 1) and name or ("[" .. name .. "]")
    if forAlert then
        local headerColor = "71DE73"
        local nameColor = "FFFF00"
        local progressColor = "FFFFFF"
        return string_format("|c%s%s|r |c%s%s|r: |c%s%s|r%s", headerColor, challengeHeader, nameColor, formattedName, progressColor, progress, claimedSuffix)
    end
    return string_format("%s %s: %s%s", challengeHeader, formattedName, progress, claimedSuffix)
end

--- - *EVENT_TIMED_ACTIVITY_TRACKING_UPDATED* (P49)
--- @param eventId number
--- @param timedActivityEncodedId id64
function ChatAnnouncements.OnTimedActivityTrackingUpdated(eventId, timedActivityEncodedId)
    if not IsTimedActivitySystemAvailable() then return end
    if not (ChatAnnouncements.SV.Notify.TimedActivityCA or ChatAnnouncements.SV.Notify.TimedActivityAlert) then return end
    local index, trackedEncodedId = GetTrackedTimedActivityInfo()
    if index == nil or trackedEncodedId ~= timedActivityEncodedId then return end
    -- Progress handler owns kill/update lines when its chat or alert toggles are on.
    if ChatAnnouncements.SV.Notify.TimedActivityProgressCA or ChatAnnouncements.SV.Notify.TimedActivityProgressAlert then
        return
    end
    local currentProgress = GetTimedActivityProgress(index)
    local maxProgress = GetTimedActivityMaxProgress(index)
    I.AnnounceTimedActivityProgress(
        index,
        currentProgress,
        maxProgress,
        ChatAnnouncements.SV.Notify.TimedActivityCA,
        ChatAnnouncements.SV.Notify.TimedActivityAlert,
        timedActivityEncodedId
    )
end

--- - *EVENT_TIMED_ACTIVITY_PROGRESS_UPDATED*
--- @param eventId number
--- @param index luaindex
--- @param previousProgress integer
--- @param currentProgress integer
--- @param complete boolean
function ChatAnnouncements.OnTimedActivityProgressUpdated(eventId, index, previousProgress, currentProgress, complete)
    if not IsTimedActivitySystemAvailable() then return end
    if not (ChatAnnouncements.SV.Notify.TimedActivityProgressCA or ChatAnnouncements.SV.Notify.TimedActivityProgressAlert) then return end
    local scope = ChatAnnouncements.SV.Notify.TimedActivityProgressScope or "all"
    if scope == "tracked" then
        local trackedIndex = GetTrackedTimedActivityInfo()
        if trackedIndex == nil or trackedIndex ~= index then return end
    end
    local numActivities = GetNumTimedActivities()
    if index < 1 or index > numActivities then return end
    local maxProgress = GetTimedActivityMaxProgress(index)
    local freq = ChatAnnouncements.SV.Notify.TimedActivityProgressFrequency or "complete"
    if freq == "complete" and not complete then return end
    if freq == "milestone" then
        if maxProgress <= 0 then return end
        local pctPrev = (previousProgress / maxProgress) * 100
        local pctCur = (currentProgress / maxProgress) * 100
        local atMilestone = false
        for _, m in ipairs({ 25, 50, 75, 100 }) do
            if pctPrev < m and pctCur >= m then
                atMilestone = true
                break
            end
        end
        if not atMilestone then return end
    end
    I.AnnounceTimedActivityProgress(
        index,
        currentProgress,
        maxProgress,
        ChatAnnouncements.SV.Notify.TimedActivityProgressCA,
        ChatAnnouncements.SV.Notify.TimedActivityProgressAlert
    )
end

--- - *EVENT_PROMOTIONAL_EVENTS_ACTIVITY_PROGRESS_UPDATED*
--- @param eventId integer
--- @param campaignKey id64
--- @param activityIndex luaindex
--- @param previousProgress integer
--- @param newProgress integer
--- @param rewardFlags PromotionalEventRewardFlags
function ChatAnnouncements.OnPromotionalEventsActivityProgressUpdated(eventId, campaignKey, activityIndex, previousProgress, newProgress, rewardFlags)
    if ChatAnnouncements.SV.Notify.PromotionalEventsActivityCA or ChatAnnouncements.SV.Notify.PromotionalEventsActivityAlert then
        local activityId, displayName, description, completionThreshold, rewardId, rewardQuantity = GetPromotionalEventCampaignActivityInfo(campaignKey, activityIndex)
        local progress = string_format("%i / %i", newProgress, completionThreshold)
        local iconString = zo_iconTextFormat("EsoUI/Art/LFG/LFG_indexIcon_PromotionalEvents_up.dds", 16, 16, GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER), true, true)
        local message = string_format("[%s] %s: %s", iconString, displayName, progress)

        if ChatAnnouncements.SV.Notify.PromotionalEventsActivityCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
            {
                message = message,
                type = "MESSAGE",
                activityId = activityId,
                rewardId = rewardId,
                rewardQuantity = rewardQuantity
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.PromotionalEventsActivityAlert then
            local header = GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)
            local alertMessage = string_format("|c71DE73[%s]|r |cFFFF00%s|r: |cFFFFFF%s|r", header, displayName, progress)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertMessage)
        end
    end
end

--- - *EVENT_CRAFTED_ABILITY_LOCK_STATE_CHANGED*
--- @param eventId integer
--- @param craftedAbilityDefId integer
--- @param isUnlocked boolean
--- @param isFromInit boolean
function ChatAnnouncements.OnCraftedAbilityLockStateChanged(eventId, craftedAbilityDefId, isUnlocked, isFromInit)
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
                type = "SKILL",
                abilityDefId = craftedAbilityDefId,
                isUnlocked = isUnlocked
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.CraftedAbilityAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
    end
end

--- - *EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED*
--- @param eventId integer
--- @param craftedAbilityScriptDefId integer
--- @param isUnlocked boolean
function ChatAnnouncements.OnCraftedAbilityScriptLockStateChanged(eventId, craftedAbilityScriptDefId, isUnlocked)
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
                type = "SKILL",
                scriptDefId = craftedAbilityScriptDefId,
                isUnlocked = isUnlocked
            }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.CraftedAbilityScriptAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
    end
end

function ChatAnnouncements.GuildBankItemAdded(eventId, slotId, addedByLocalPlayer)
    if addedByLocalPlayer then
        zo_callLater(ChatAnnouncements.LogGuildBankChange, 50)
    end
end

function ChatAnnouncements.GuildBankItemRemoved(eventId, slotId, addedByLocalPlayer)
    if addedByLocalPlayer then
        zo_callLater(ChatAnnouncements.LogGuildBankChange, 50)
    end
end

function ChatAnnouncements.LogGuildBankChange()
    if S.g_guildBankCarry ~= nil then
        ChatAnnouncements.ItemPrinter(S.g_guildBankCarry.icon, S.g_guildBankCarry.stack, S.g_guildBankCarry.itemType, S.g_guildBankCarry.itemId, S.g_guildBankCarry.itemLink, S.g_guildBankCarry.receivedBy, S.g_guildBankCarry.logPrefix, S.g_guildBankCarry.gainOrLoss, false)
    end
    S.g_guildBankCarry = nil
end

function ChatAnnouncements.OnFurnitureItemsTransferredToVault(eventId, numEligibleSlotsTransferred, numEligibleSlots)
    if not ChatAnnouncements.SV.Inventory.LootBank or numEligibleSlotsTransferred == 0 then
        return
    end
    local msg
    if numEligibleSlotsTransferred == numEligibleSlots then
        msg = zo_strformat(GetString(SI_FURNITURE_VAULT_STOWED_ALL_ITEMS), numEligibleSlotsTransferred)
    else
        msg = zo_strformat(GetString(SI_FURNITURE_VAULT_STOWED_ITEMS), numEligibleSlotsTransferred, numEligibleSlots)
    end
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = msg, type = "MESSAGE" }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

function ChatAnnouncements.IndexInventory()
    -- d("Debug - Inventory Indexed!")
    S.g_inventoryStacks = {}
    local bagsize = GetBagSize(BAG_BACKPACK)

    for i = 0, bagsize do
        local icon, stack = GetItemInfo(BAG_BACKPACK, i)
        local itemType = GetItemType(BAG_BACKPACK, i)
        local itemId = GetItemId(BAG_BACKPACK, i)
        local itemLink = GetItemLink(BAG_BACKPACK, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        if itemLink ~= "" then
            S.g_inventoryStacks[i] = I.MakeStackEntry(BAG_BACKPACK, i, icon, stack, itemId, itemType, itemLink)
        end
    end
end

function ChatAnnouncements.IndexEquipped()
    -- d("Debug - Equipped Items Indexed!")
    S.g_equippedStacks = {}
    local bagsize = GetBagSize(BAG_WORN)

    for i = 0, bagsize do
        local icon, stack = GetItemInfo(BAG_WORN, i)
        local itemType = GetItemType(BAG_WORN, i)
        local itemId = GetItemId(BAG_WORN, i)
        local itemLink = GetItemLink(BAG_WORN, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        if itemLink ~= "" then
            S.g_equippedStacks[i] = I.MakeStackEntry(BAG_WORN, i, icon, stack, itemId, itemType, itemLink)
        end
    end
end

function ChatAnnouncements.IndexBank()
    -- ("Debug - Bank Indexed!")
    local bagsizebank = GetBagSize(BAG_BANK)
    local bagsizesubbank = GetBagSize(BAG_SUBSCRIBER_BANK)

    for i = 0, bagsizebank do
        local icon, stack = GetItemInfo(BAG_BANK, i)
        local bagitemlink = GetItemLink(BAG_BANK, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemId = GetItemId(BAG_BANK, i)
        local itemLink = GetItemLink(BAG_BANK, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemType = GetItemType(BAG_BANK, i)
        if bagitemlink ~= "" then
            S.g_bankStacks[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
        end
    end

    for i = 0, bagsizesubbank do
        local icon, stack = GetItemInfo(BAG_SUBSCRIBER_BANK, i)
        local bagitemlink = GetItemLink(BAG_SUBSCRIBER_BANK, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemId = GetItemId(BAG_SUBSCRIBER_BANK, i)
        local itemLink = GetItemLink(BAG_SUBSCRIBER_BANK, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemType = GetItemType(BAG_SUBSCRIBER_BANK, i)
        if bagitemlink ~= "" then
            S.g_banksubStacks[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
        S.g_houseBags[bag] = {}

        for i = 0, bagsize do
            local icon, stack = GetItemInfo(bag, i)
            local bagitemlink = GetItemLink(bag, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            local itemId = GetItemId(bag, i)
            local itemLink = GetItemLink(bag, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            local itemType = GetItemType(bag, i)
            if bagitemlink ~= "" then
                S.g_houseBags[bag][i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end
    end
end

function ChatAnnouncements.IndexFurnitureVault()
    S.g_furnitureVaultStacks = {}
    local slotId = GetNextFurnitureVaultSlotId(nil)
    while slotId do
        local icon, stack = GetItemInfo(BAG_FURNITURE_VAULT, slotId)
        local bagitemlink = GetItemLink(BAG_FURNITURE_VAULT, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemId = GetItemId(BAG_FURNITURE_VAULT, slotId)
        local itemLink = GetItemLink(BAG_FURNITURE_VAULT, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemType = GetItemType(BAG_FURNITURE_VAULT, slotId)
        if bagitemlink ~= "" then
            S.g_furnitureVaultStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
        end
        slotId = GetNextFurnitureVaultSlotId(slotId)
    end
end

function ChatAnnouncements.CraftingOpen(eventId, craftSkill, sameStation)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootCraft then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateCraft)
        S.g_inventoryStacks = {}
        S.g_bankStacks = {}
        S.g_banksubStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
        ChatAnnouncements.IndexBank()      -- Index Bank
    end
end

function ChatAnnouncements.CraftingClose(eventId, craftSkill)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        S.g_inventoryStacks = {}
    end
    S.g_bankStacks = {}
    S.g_banksubStacks = {}
end

function ChatAnnouncements.BankOpen(eventId, bankBag)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootBank then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateBank)
        S.g_inventoryStacks = {}
        S.g_bankStacks = {}
        S.g_banksubStacks = {}
        S.g_houseBags = {}
        S.g_furnitureVaultStacks = {}
        ChatAnnouncements.IndexInventory()      -- Index Inventory
        ChatAnnouncements.IndexBank()           -- Index Bank
        ChatAnnouncements.IndexHouseBags()      -- Index House Bags
        ChatAnnouncements.IndexFurnitureVault() -- Index Furnishing Vault
    end
    S.g_bankBag = bankBag > 6 and 2 or 1
    S.g_currentBankBagId = bankBag
end

function ChatAnnouncements.BankClose(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        S.g_inventoryStacks = {}
    end
    S.g_bankStacks = {}
    S.g_banksubStacks = {}
    S.g_houseBags = {}
    S.g_furnitureVaultStacks = {}
end

function ChatAnnouncements.GuildBankOpen(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootBank then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateGuildBank)
        S.g_inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
end

function ChatAnnouncements.GuildBankClose(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        S.g_inventoryStacks = {}
    end
end

function ChatAnnouncements.FenceOpen(eventId, allowSell, allowLaunder)
    S.g_weAreInAFence = true
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootVendor then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateFence)
        S.g_inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
end

function ChatAnnouncements.StoreOpen(eventId)
    S.g_weAreInAStore = true
end

function ChatAnnouncements.StoreClose(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        S.g_inventoryStacks = {}
    end
    zo_callLater(function ()
                     S.g_weAreInAStore = false
                     S.g_weAreInAFence = false
                 end, 1000)
end

function ChatAnnouncements.GuildStoreOpen(eventId)
    S.g_weAreInAStore = true
    S.g_weAreInAGuildStore = true
end

function ChatAnnouncements.GuildStoreClose(eventId)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        S.g_inventoryStacks = {}
    end
    zo_callLater(function ()
                     S.g_weAreInAStore = false
                     S.g_weAreInAGuildStore = false
                 end, 1000)
end

function ChatAnnouncements.FenceSuccess(eventId, result)
    if result == ITEM_LAUNDER_RESULT_SUCCESS then
        if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
            if S.g_savedPurchase.formattedValue ~= nil and S.g_savedPurchase.formattedValue ~= "" then
                ChatAnnouncements.CurrencyPrinter(nil, S.g_savedPurchase.formattedValue, S.g_savedPurchase.changeColor, S.g_savedPurchase.changeType, S.g_savedPurchase.currencyTypeColor, S.g_savedPurchase.currencyIcon, S.g_savedPurchase.currencyName, S.g_savedPurchase.currencyTotal, S.g_savedPurchase.messageChange, S.g_savedPurchase.messageTotal, S.g_savedPurchase.type, S.g_savedPurchase.carriedItem, S.g_savedPurchase.carriedItemTotal)
            end
        else
            if S.g_savedLaunder.itemId ~= nil and S.g_savedLaunder.itemId ~= "" then
                ChatAnnouncements.ItemPrinter(S.g_savedLaunder.icon, S.g_savedLaunder.stack, S.g_savedLaunder.itemType, S.g_savedLaunder.itemId, S.g_savedLaunder.itemLink, "", S.g_savedLaunder.logPrefix, S.g_savedLaunder.gainOrLoss, false)
            end
        end
        S.g_savedLaunder = {}
        S.g_savedPurchase = {}
    end
end

-- Only active if destroyed items is enabled, flags the next item that is removed from inventory as destroyed.
function ChatAnnouncements.DestroyItem(eventId, itemSoundCategory)
    S.g_itemWasDestroyed = true
end

function ChatAnnouncements.OnPackSiege()
    local function ResetPackSiege()
        S.g_packSiege = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetPackSiege")
    end
    S.g_packSiege = true
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

--- @class questItem
--- @field questIndex integer
--- @field questItemId integer
--- @field stackCount integer
--- @field inventory table
--- @field slotIndex integer
--- @field iconFile string

--- @alias questItem_itemTable { [integer] : questItem }

--- @alias luiequestItemIndex {
--- stack : integer,
--- counter : integer,
--- icon : string,
--- }

--- @type table<integer, luiequestItemIndex>
local questItemIndex = {}

function ChatAnnouncements.AddQuestItemsToIndex()
    questItemIndex = {}

    local function AddQuests(questIndex)
        local inventory = PLAYER_INVENTORY.inventories[INVENTORY_QUEST_ITEM]
        local itemTable = inventory.slots[questIndex]
        if itemTable then
            -- remove all quest items from search
            for i = 1, #itemTable do
                local itemId = itemTable[i].questItemId
                local stackCount = itemTable[i].stackCount
                local icon = itemTable[i].iconFile
                questItemIndex[itemId] = { stack = stackCount, counter = 0, icon = icon }
            end
        end
    end

    for questIndex = 1, MAX_JOURNAL_QUESTS do
        AddQuests(questIndex)
    end
end

function ChatAnnouncements.ResolveQuestItemChange()
    for itemId, _ in pairs(questItemIndex) do
        local countChange = nil
        local newValue = questItemIndex[itemId].stack + questItemIndex[itemId].counter

        -- Only if the value changes
        if newValue > questItemIndex[itemId].stack or newValue < questItemIndex[itemId].stack then
            local icon = questItemIndex[itemId].icon
            local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""

            local itemLink
            if ChatAnnouncements.SV.BracketOptionItem == 1 then
                itemLink = string_format("|H0:quest_item:" .. itemId .. "|h|h")
            else
                itemLink = string_format("|H1:quest_item:" .. itemId .. "|h|h")
            end

            local color
            local logPrefix
            local total = questItemIndex[itemId].stack + questItemIndex[itemId].counter
            local totalString

            local formattedMessageP1
            local formattedMessageP2
            local finalMessage

            -- Lower
            if newValue < questItemIndex[itemId].stack then
                -- Easy temporary debug for my accounts only
                -- if LUIE.IsDevDebugEnabled() then
                --     LUIE:Log("Debug", itemId .. " Removed")
                -- end
                --

                countChange = newValue + questItemIndex[itemId].counter
                S.g_questItemRemoved[itemId] = true
                -- nil (not false) so the key is removed from the table and the
                -- map stays bounded to currently-debouncing items rather than
                -- accumulating every unique quest itemId seen during the session.
                -- Downstream check at PrintQueuedMessages uses `if not S.g_questItemRemoved[itemId]`
                -- which evaluates the same for nil and false.
                zo_callLater(function ()
                                 S.g_questItemRemoved[itemId] = nil
                             end, 100)

                if not Quests.QuestItemHideRemove[itemId] and not S.g_loginHideQuestLoot then
                    if ChatAnnouncements.SV.Inventory.LootQuestRemove then
                        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
                            color = ColorizeColors.CurrencyDownColorize:ToHex()
                        else
                            color = ColorizeColors.CurrencyColorize:ToHex()
                        end

                        logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageRemove")

                        -- Any items that are removed at the same time a quest is turned or advanced in will be flagged to display as "Turned In."
                        if S.g_itemReceivedIsQuestReward then
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageQuestTurnIn")
                        end

                        if Quests.ItemRemovedMessage[itemId] and not Quests.ItemIgnoreTurnIn[itemId] then
                            logPrefix = Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_TURNIN and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestTurnIn") or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_USE and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestUse") or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_EXHAUST and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestExhaust") or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_OFFER and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestOffer") or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_DISCARD and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestDiscard") or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_CONFISCATE and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestConfiscate") or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_OPEN and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestOpen") or
                                Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_ADMINISTER and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestAdminister") or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_PLACE and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestPlace")
                        end

                        if Quests.ItemRemovedInDialogueMessage[itemId] and S.g_talkingToNPC then
                            logPrefix = Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_TURNIN and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestTurnIn") or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_USE and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestUse") or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_EXHAUST and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestExhaust") or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_OFFER and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestOffer") or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_DISCARD and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestDiscard") or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_CONFISCATE and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestConfiscate") or
                                Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_OPEN and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestOpen") or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_ADMINISTER and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestAdminister") or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_PLACE and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestPlace")
                        end

                        -- Any items that are removed at the same time a quest is abandoned will be flagged to display as "Removed."
                        if S.g_itemReceivedIsQuestAbandon then
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageRemove")
                        end

                        local quantity = (countChange * -1) > 1 and (" |cFFFFFFx" .. (countChange * -1) .. "|r") or ""

                        formattedMessageP1 = ("|r" .. formattedIcon .. itemLink .. quantity .. "|c" .. color)
                        formattedMessageP2 = string_format(logPrefix, formattedMessageP1)

                        if ChatAnnouncements.SV.Inventory.LootTotal and total > 1 then
                            totalString = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        else
                            totalString = ""
                        end

                        finalMessage = string_format("|c%s%s|r%s", color, formattedMessageP2, totalString)

                        eventManager:UnregisterForUpdate(moduleName .. "Printer")
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "QUEST LOOT REMOVE", itemId = itemId }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages)
                    end
                end

                if Quests.QuestItemModifyOnRemove[itemId] then
                    Quests.QuestItemModifyOnRemove[itemId]()
                end
            end

            -- Higher
            if newValue > questItemIndex[itemId].stack then
                -- Easy debug for my devs only
                -- if LUIE.IsDevDebugEnabled() then
                --     LUIE:Log("Debug", itemId .. " Added")
                -- end
                --
                countChange = newValue - questItemIndex[itemId].stack
                S.g_questItemAdded[itemId] = true
                -- See g_questItemRemoved above: nil keeps the map bounded.
                zo_callLater(function ()
                                 S.g_questItemAdded[itemId] = nil
                             end, 100)

                if not Quests.QuestItemHideLoot[itemId] and not S.g_loginHideQuestLoot then
                    if ChatAnnouncements.SV.Inventory.LootQuestAdd then
                        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
                            color = ColorizeColors.CurrencyUpColorize:ToHex()
                        else
                            color = ColorizeColors.CurrencyColorize:ToHex()
                        end

                        if S.g_isLooted and not S.g_itemReceivedIsQuestReward and not S.g_isPickpocketed and not S.g_isStolen then
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageLoot")
                            -- reset variables that control looted, or at least ZO_CallLater them
                        elseif S.g_isPickpocketed then
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessagePickpocket")
                        elseif S.g_isStolen and not S.g_isPickpocketed then
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageSteal")
                        else
                            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
                        end
                        if Quests.ItemReceivedMessage[itemId] then
                            logPrefix = Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_BUNDLE and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestBundle") or Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_LOOT and ChatAnnouncements.GetContextMessage("CurrencyMessageLoot") or Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_COMBINE and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestCombine") or Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_MIX and ChatAnnouncements.GetContextMessage("CurrencyMessageQuestMix") or Quests.ItemReceivedMessage[itemId] == LUIE_QUEST_MESSAGE_STEAL and ChatAnnouncements.GetContextMessage("CurrencyMessageSteal")
                        end

                        -- Some quest items we want to limit the maximum possible quantity displayed when looted (for wierd item swapping) so replace the actual quantity with this value.
                        if Quests.QuestItemMaxQuantityAdd[itemId] then
                            countChange = Quests.QuestItemMaxQuantityAdd[itemId]
                        end
                        local quantity = countChange > 1 and (" |cFFFFFFx" .. countChange .. "|r") or ""

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
                            totalString = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        else
                            totalString = ""
                        end

                        finalMessage = string_format("|c%s%s|r%s", color, formattedMessageP2, totalString)

                        eventManager:UnregisterForUpdate(moduleName .. "Printer")
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "QUEST LOOT ADD", itemId = itemId }
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
            questItemIndex[itemId].stack = newValue
            questItemIndex[itemId].counter = 0
            -- d("New Stack Value = " .. questItemIndex[itemId].stack)
            if questItemIndex[itemId].stack < 1 then
                questItemIndex[itemId] = nil
                -- d("Item reached 0 or below stacks, removing")
            end
        end
    end

    eventManager:UnregisterForUpdate(moduleName .. "QuestItemUpdater")
end

function I.DisplayQuestItem(itemId, stackCount, icon, reset)
    if not questItemIndex[itemId] then
        questItemIndex[itemId] = { stack = 0, counter = 0, icon = icon }
        -- d("New item created with 0 stack")
    end

    if reset then
        -- d(itemId .. " - Decrement by: " .. stackCount)
        questItemIndex[itemId].counter = questItemIndex[itemId].counter - stackCount
    else
        -- d(itemId .. " - Increment by: " .. stackCount)
        questItemIndex[itemId].counter = questItemIndex[itemId].counter + stackCount
    end
    eventManager:RegisterForUpdate(moduleName .. "QuestItemUpdater", 25, ChatAnnouncements.ResolveQuestItemChange)
end

function ChatAnnouncements.OnLootReceived(eventId, receivedBy, itemLink, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
    -- If the player loots an item
    if not isPickpocketLoot and lootedBySelf then
        S.g_isLooted = true

        local function ResetIsLooted()
            S.g_isLooted = false
            eventManager:UnregisterForUpdate(moduleName .. "ResetLooted")
        end
        eventManager:UnregisterForUpdate(moduleName .. "ResetLooted")
        eventManager:RegisterForUpdate(moduleName .. "ResetLooted", 150, ResetIsLooted)
    end

    -- If the player pickpockets an item
    if isPickpocketLoot and lootedBySelf then
        S.g_isPickpocketed = true

        local function ResetIsPickpocketed()
            S.g_isPickpocketed = false
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
        local logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageGroup")

        local formattedItemLink
        if ChatAnnouncements.SV.BracketOptionItem == 1 then
            formattedItemLink = itemLink
        else
            formattedItemLink = zo_strgsub(itemLink, "^|H0", "|H1", 1)
        end

        local formatName = zo_strformat("<<C:1>>", receivedBy)

        local recipient
        if S.g_groupLootIndex[formatName] then
            recipient = ZO_SELECTED_TEXT:Colorize(ChatAnnouncements.ResolveNameLink(S.g_groupLootIndex[formatName].characterName, S.g_groupLootIndex[formatName].displayName))
        else
            local nameLink
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(formatName, nil, CHARACTER_LINK_TYPE, formatName)
            else
                nameLink = ZO_LinkHandler_CreateLink(formatName, nil, CHARACTER_LINK_TYPE, formatName)
            end
            recipient = ZO_SELECTED_TEXT:Colorize(nameLink)
        end
        ChatAnnouncements.ItemPrinter(icon, quantity, itemType, itemId, formattedItemLink, recipient, logPrefix, gainOrLoss, false, true)
    end
end

--- @param deltaReputation integer
--- @param playerReputationTotal integer|nil From EVENT_ADVENTURE_ZONE_FACTION_REPUTATION_CHANGED _newReputation_; else GetAdventureZonePlayerReputation()
function ChatAnnouncements.QueueAdventureZoneFactionReputationGain(deltaReputation, playerReputationTotal)
    if not ChatAnnouncements.SV.Inventory.Loot or deltaReputation == 0 then
        return
    end

    local now = GetGameTimeMilliseconds()
    if S.g_factionRepAnnounceDedupe.delta == deltaReputation and (now - S.g_factionRepAnnounceDedupe.time) < 250 then
        return
    end
    S.g_factionRepAnnounceDedupe.delta = deltaReputation
    S.g_factionRepAnnounceDedupe.time = now

    local faction = GetUnitAdventureZoneFaction("player")
    local label = GetString(SI_LOOT_HISTORY_ADVENTURE_ZONE_FACTION_REPUTATION)
    local iconPath = ZO_GetAdventureZoneFactionIcon(faction) or ""
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and iconPath ~= "") and zo_strformat("<<1>> ", zo_iconFormat(iconPath, 16, 16)) or ""

    local color
    local gainOrLoss
    if deltaReputation > 0 then
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
    else
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
    end
    if gainOrLoss == 1 then
        color = ColorizeColors.CurrencyUpColorize:ToHex()
    elseif gainOrLoss == 2 then
        color = ColorizeColors.CurrencyDownColorize:ToHex()
    else
        color = ColorizeColors.CurrencyColorize:ToHex()
    end

    local absDelta = math.abs(deltaReputation)
    local quantity = string_format(" |cFFFFFFx%d|r", absDelta)
    local itemString = string_format("%s%s%s", formattedIcon, label, quantity)

    local logPrefix = ChatAnnouncements.GetContextMessagePrefix()

    local totalString = ""
    if ChatAnnouncements.SV.Inventory.LootTotal and faction ~= ADVENTURE_ZONE_FACTION_NONE then
        local totalRep = playerReputationTotal or GetAdventureZonePlayerReputation()
        if totalRep > 0 then
            totalString = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(totalRep))
        end
    end

    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
    {
        message = itemString,
        type = "LOOT",
        formattedRecipient = "",
        color = color,
        logPrefix = logPrefix,
        totalString = totalString,
        groupLoot = false,
    }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

--- @param eventId integer
--- @param newReputation integer
--- @param deltaReputation integer
function ChatAnnouncements.OnAdventureZoneFactionReputationChanged(eventId, newReputation, deltaReputation)
    ChatAnnouncements.QueueAdventureZoneFactionReputationGain(deltaReputation, newReputation)
end

--- @param eventId integer
--- @param currencyType CurrencyType
--- @param currencyLocation CurrencyLocation
--- @param amount integer
--- @param reason CurrencyChangeReason
--- @param reasonSupplementaryInfo integer
function ChatAnnouncements.OnPendingCurrencyRewardCached(eventId, currencyType, currencyLocation, amount, reason, reasonSupplementaryInfo)
    if amount == 0 then
        return
    end
    ChatAnnouncements.OnCurrencyUpdate(eventId, currencyType, currencyLocation, amount, 0, reason, reasonSupplementaryInfo)
end

function ChatAnnouncements.OnInventoryItemUsed(eventId, itemSoundCategory)
    -- Container opens from the bag use this event before currency/inventory updates; start defer window early.
    I.BeginContainerLootOrderingWindow()

    local function ResetCombinedRecipe()
        S.g_combinedRecipe = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetCombinedRecipe")
    end

    -- Trophy items used for recipe combination seem to have no itemSoundCategory.
    if itemSoundCategory == 0 then
        S.g_combinedRecipe = true
        eventManager:UnregisterForUpdate(moduleName .. "ResetCombinedRecipe")
        eventManager:RegisterForUpdate(moduleName .. "ResetCombinedRecipe", 150, ResetCombinedRecipe)
    end
end

-- If filter is true, we run the item through this function to determine if we should display it. Filter only gets set to true for group loot and relevant loot functions. Mail, trade, stores, etc don't apply the filter.
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
    elseif ChatAnnouncements.SV.Inventory.LootNotTrash and (itemQuality == ITEM_FUNCTIONAL_QUALITY_TRASH) and not ((itemType == ITEMTYPE_ARMOR) or (itemType == ITEMTYPE_COSTUME) or (itemType == ITEMTYPE_DISGUISE)) then
        return false
    else
        return true
    end
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

function ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, filter, groupLoot, alwaysFirst, delay, showCollectionStatus)
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
        color = ColorizeColors.CurrencyUpColorize:ToHex()
    elseif gainOrLoss == 2 then
        color = ColorizeColors.CurrencyDownColorize:ToHex()
        -- 3 = Gain no color, 4 = Loss no color (differentiation only exists for Crafting Strings)
    elseif gainOrLoss == 3 or gainOrLoss == 4 then
        color = ColorizeColors.CurrencyColorize:ToHex()
        -- Fallback if gainOrLoss is nil or an invalid number for some reason
    else
        color = ColorizeColors.CurrencyColorize:ToHex()
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
        formattedQuantity = string_format(" |cFFFFFFx%d|r", stack)
    else
        formattedQuantity = ""
    end

    local armorType = GetItemLinkArmorType(itemLink) -- Get Armor Type of item
    formattedArmorType = (ChatAnnouncements.SV.Inventory.LootShowArmorType and armorType ~= ARMORTYPE_NONE and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgrade") and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgradeFail")) and string_format(" |cFFFFFF(%s)|r", GetString("SI_ARMORTYPE", armorType)) or ""

    local traitType = GetItemLinkTraitInfo(itemLink) -- Get Trait type of item
    formattedTrait = (ChatAnnouncements.SV.Inventory.LootShowTrait and traitType ~= ITEM_TRAIT_TYPE_NONE and itemType ~= ITEMTYPE_ARMOR_TRAIT and itemType ~= ITEMTYPE_WEAPON_TRAIT and itemType ~= ITEMTYPE_JEWELRY_TRAIT and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgrade") and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgradeFail")) and string_format(" |cFFFFFF(%s)|r", GetString("SI_ITEMTRAITTYPE", traitType)) or ""

    local styleType = GetItemLinkItemStyle(itemLink) -- Get Style of the item
    local unformattedStyle = zo_strformat("<<1>>", GetItemStyleName(styleType))
    formattedStyle = (ChatAnnouncements.SV.Inventory.LootShowStyle and styleType ~= 0 and styleType ~= 10 and styleType ~= GetUniversalStyleId() and itemType ~= ITEMTYPE_STYLE_MATERIAL and itemType ~= ITEMTYPE_GLYPH_ARMOR and itemType ~= ITEMTYPE_GLYPH_JEWELRY and itemType ~= ITEMTYPE_GLYPH_WEAPON and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgrade") and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgradeFail")) and string_format(" |cFFFFFF(%s)|r", unformattedStyle) or ""

    local formattedTotal = ""
    if ChatAnnouncements.SV.Inventory.LootTotal and receivedBy ~= "LUIE_INVENTORY_UPDATE_DISGUISE" and receivedBy ~= "LUIE_RECEIVE_CRAFT" and not groupLoot and (not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageLearnRecipe") and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageLearnMotif") and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageLearnStyle")) then
        local total1, total2, total3 = GetItemLinkStacks(itemLink)
        local total = total1 + total2 + total3
        if total > 1 then
            formattedTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.GetLootTotalString(), formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    local formattedCollectionStatus = (showCollectionStatus and ChatAnnouncements.GetFormattedCollectionStatusIcon(itemLink)) or ""
    local itemString = string_format("%s%s%s%s%s%s%s", formattedIcon, formattedCollectionStatus, itemLink, formattedQuantity, formattedArmorType, formattedTrait, formattedStyle)

    local delayTimer = 50
    local messageType = alwaysFirst and "CONTAINER" or "LOOT"

    -- Printer function, separate handling for listed entires (from crafting) or simple function that sends a message over to the printer.
    if receivedBy == "LUIE_RECEIVE_CRAFT" and (gainOrLoss == 1 or gainOrLoss == 3) and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgradeFail") then
        local itemString2 = itemString

        if S.g_itemStringGain ~= "" then
            S.g_itemStringGain = string_format("%s|c%s,|r %s", S.g_itemStringGain, color, itemString2)
        end
        if S.g_itemStringGain == "" then
            S.g_itemStringGain = itemString
        end

        S.g_itemCounterGainTracker = S.g_itemCounterGainTracker + 1
        if S.g_itemCounterGainTracker > 50 then
            S.g_itemStringGain = string_format(GetString(LUIE_STRING_CA_LOOT_TOO_MANY_ITEMS_COLORED), color)
        end

        if S.g_itemCounterGain == 0 then
            S.g_itemCounterGain = ChatAnnouncements.QueuedMessagesCounter
        end
        if ChatAnnouncements.QueuedMessagesCounter - 1 == S.g_itemCounterGain then
            ChatAnnouncements.QueuedMessagesCounter = S.g_itemCounterGain
        end
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        ChatAnnouncements.QueuedMessages[S.g_itemCounterGain] =
        {
            message = S.g_itemStringGain,
            type = messageType,
            formattedRecipient = formattedRecipient,
            color = color,
            logPrefix = logPrefix,
            totalString = "",
            groupLoot = groupLoot,
        }
        eventManager:RegisterForUpdate(moduleName .. "Printer", delayTimer, ChatAnnouncements.PrintQueuedMessages)
    elseif receivedBy == "LUIE_RECEIVE_CRAFT" and (gainOrLoss == 2 or gainOrLoss == 4) and not ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgradeFail") then
        local itemString2 = itemString
        if S.g_itemStringLoss ~= "" then
            S.g_itemStringLoss = string_format("%s|c%s,|r %s", S.g_itemStringLoss, color, itemString2)
        end
        if S.g_itemStringLoss == "" then
            S.g_itemStringLoss = itemString
        end

        S.g_itemCounterLossTracker = S.g_itemCounterLossTracker + 1
        if S.g_itemCounterLossTracker > 100 then
            S.g_itemStringLoss = string_format(GetString(LUIE_STRING_CA_LOOT_TOO_MANY_ITEMS_COLORED), color)
        end

        if S.g_itemCounterLoss == 0 then
            S.g_itemCounterLoss = ChatAnnouncements.QueuedMessagesCounter
        end
        if ChatAnnouncements.QueuedMessagesCounter - 1 == S.g_itemCounterLoss then
            ChatAnnouncements.QueuedMessagesCounter = S.g_itemCounterLoss
        end
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        ChatAnnouncements.QueuedMessages[S.g_itemCounterLoss] =
        {
            message = S.g_itemStringLoss,
            type = messageType,
            formattedRecipient = formattedRecipient,
            color = color,
            logPrefix = logPrefix,
            totalString = "",
            groupLoot = groupLoot,
        }
        eventManager:RegisterForUpdate(moduleName .. "Printer", delayTimer, ChatAnnouncements.PrintQueuedMessages)
    elseif ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageContainer") and alwaysFirst then
        ChatAnnouncements.ResolveItemMessage(itemString, formattedRecipient, color, logPrefix, formattedTotal, groupLoot)
        ChatAnnouncements.FlushDeferredContainerLootCurrency()
    else
        local totalString = formattedTotal
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
        {
            message = itemString,
            type = messageType,
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

function ChatAnnouncements.ResolveItemMessage(message, formattedRecipient, color, logPrefix, totalString, groupLoot)
    -- Default missing parameters to valid values
    message = message or ""
    formattedRecipient = formattedRecipient or ""
    color = color and (type(color) == "table" and color:IsColorDef() and color or ZO_ColorDef:New(color)) or ZO_ColorDef:New("FFFFFF")
    logPrefix = logPrefix or ""
    totalString = totalString or ""

    -- Determine the appropriate message prefix based on item acquisition context
    if logPrefix == "" then
        logPrefix = ChatAnnouncements.GetContextMessagePrefix() or ""
    else
        logPrefix = ChatAnnouncements.ResolveLogPrefix(logPrefix)
    end

    -- Format the message parts with nil checks
    local formattedMessageP1 = string_format("|r%s|c%s", message, color:ToHex()) or ""
    local formattedMessageP2 = ChatAnnouncements.FormatContextMessage(logPrefix, formattedMessageP1, formattedRecipient, color:ToHex(), groupLoot) or ""

    -- Construct and output the final message with additional safety checks
    local finalMessage = string_format("|c%s%s|r%s", color:ToHex(), formattedMessageP2 or "", totalString or "")
    if finalMessage and finalMessage ~= "" then
        ChatOutput:Print(finalMessage)
    end

    -- Reset all tracking variables
    ChatAnnouncements.ResetTrackingVariables()
end

-- Helper function to determine message prefix based on context
function ChatAnnouncements.GetContextMessagePrefix()
    if S.g_isLooted and not S.g_itemReceivedIsQuestReward and not S.g_isPickpocketed and not S.g_isStolen then
        return ChatAnnouncements.GetContextMessage("CurrencyMessageLoot")
    elseif S.g_isPickpocketed then
        return ChatAnnouncements.GetContextMessage("CurrencyMessagePickpocket")
    elseif S.g_isStolen and not S.g_isPickpocketed then
        return ChatAnnouncements.GetContextMessage("CurrencyMessageSteal")
    end
    return ChatAnnouncements.GetContextMessage("CurrencyMessageReceive")
end

-- Helper function to format the context message
function ChatAnnouncements.FormatContextMessage(logPrefix, formattedMessageP1, formattedRecipient, color, groupLoot)
    -- Handle upgrade messages
    if ChatAnnouncements.ContextMessageMatches(logPrefix, "CurrencyMessageUpgrade") and ChatAnnouncements.IsValidOldItem() then
        local formattedIcon = ChatAnnouncements.GetFormattedIcon(S.g_oldItem.icon)
        local formattedMessageUpgrade = string_format("|r%s%s|c%s", formattedIcon, S.g_oldItem.itemLink, color)
        S.g_oldItem = {}
        return string_format(logPrefix, formattedMessageUpgrade, formattedMessageP1)
    end

    -- Handle regular messages
    if groupLoot then
        local recipient = string_format("|r%s|c%s", formattedRecipient, color)
        return string_format(logPrefix, recipient, formattedMessageP1)
    end

    -- Handle messages without recipient
    if formattedRecipient == "" then
        return string_format(logPrefix, formattedMessageP1, "")
    end

    -- Handle messages with recipient
    local recipient = string_format("|r%s|c%s", formattedRecipient, color)
    return string_format(logPrefix, formattedMessageP1, recipient)
end

-- Helper function to check if old item data is valid
function ChatAnnouncements.IsValidOldItem()
    return S.g_oldItem ~= nil and S.g_oldItem.itemLink ~= "" and S.g_oldItem.itemLink ~= nil and S.g_oldItem.icon ~= nil
end

-- Helper function to format icon
function ChatAnnouncements.GetFormattedIcon(icon)
    if not ChatAnnouncements.SV.Inventory.LootIcons or icon == "" then
        return ""
    end
    -- Use zo_iconTextFormat with just the icon (no text)
    -- 16x16 dimensions maintained, empty text string
    return zo_iconTextFormat(icon, 16, 16, "", nil)
end

-- Reset all tracking variables
function ChatAnnouncements.ResetTrackingVariables()
    S.g_itemCounterGain = 0
    S.g_itemCounterGainTracker = 0
    S.g_itemCounterLoss = 0
    S.g_itemCounterLossTracker = 0
    S.g_itemStringGain = ""
    S.g_itemStringLoss = ""
end

-- Simple posthook into ZOS crafting mode functions, based off MultiCraft, thanks Ayantir!
function ChatAnnouncements.CraftModeOverrides()
    -- Get SMITHING mode
    S.g_smithing.GetMode = LUIE.GetSmithingMode

    -- Get ENCHANTING mode
    S.g_enchanting.GetMode = LUIE.GetEnchantingMode

    -- NOTE: Alchemy and provisioning don't matter, as the only options are to craft and use materials.

    -- Crafting Mode Syntax (Enchanting - Item Gain)
    S.g_enchant_prefix_pos =
    {
        [1] = ChatAnnouncements.GetContextMessage("CurrencyMessageCraft"),
        [2] = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive"),
        [3] = ChatAnnouncements.GetContextMessage("CurrencyMessageCraft"),
    }

    -- Crafting Mode Syntax (Enchanting - Item Loss)
    S.g_enchant_prefix_neg =
    {
        [1] = ChatAnnouncements.GetContextMessage("CurrencyMessageUse"),
        [2] = ChatAnnouncements.GetContextMessage("CurrencyMessageExtract"),
        [3] = ChatAnnouncements.GetContextMessage("CurrencyMessageUse"),
    }

    -- Crafting Mode Syntax (Blacksmithing - Item Gain)
    S.g_smithing_prefix_pos =
    {
        [1] = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive"),
        [2] = ChatAnnouncements.GetContextMessage("CurrencyMessageCraft"),
        [3] = ChatAnnouncements.GetContextMessage("CurrencyMessageReceive"),
        [4] = ChatAnnouncements.GetContextMessage("CurrencyMessageUpgrade"),
        [5] = "",
        [6] = ChatAnnouncements.GetContextMessage("CurrencyMessageCraft"),
    }

    -- Crafting Mode Syntax (Blacksmithing - Item Loss)
    S.g_smithing_prefix_neg =
    {
        [1] = ChatAnnouncements.GetContextMessage("CurrencyMessageRefine"),
        [2] = ChatAnnouncements.GetContextMessage("CurrencyMessageUse"),
        [3] = ChatAnnouncements.GetContextMessage("CurrencyMessageDeconstruct"),
        [4] = ChatAnnouncements.GetContextMessage("CurrencyMessageUpgradeFail"),
        [5] = ChatAnnouncements.GetContextMessage("CurrencyMessageResearch"),
        [6] = ChatAnnouncements.GetContextMessage("CurrencyMessageUse"),
    }
end

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
        eventManager:UnregisterForUpdate(moduleName .. "SendDelayedItems")
        if not S.g_mailBatchTakeAll then
            eventManager:UnregisterForUpdate(moduleName .. "SendDelayedMailItems")
            eventManager:RegisterForUpdate(moduleName .. "SendDelayedMailItems", 25, ChatAnnouncements.SendDelayedMailItems)
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
    eventManager:UnregisterForUpdate(moduleName .. "SendDelayedItems")
    eventManager:RegisterForUpdate(moduleName .. "SendDelayedItems", 25, ChatAnnouncements.SendDelayedItems)
end

function ChatAnnouncements.SendDelayedItems()
    if S.g_mailBatchTakeAll then
        return
    end
    I.FlushDelayedItemPoolInDisplayOrder(delayedItemPool)
    delayedItemPool = {}
end

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
    eventManager:UnregisterForUpdate(moduleName .. "SendDelayedItemsOut")
    eventManager:RegisterForUpdate(moduleName .. "SendDelayedItemsOut", 25, ChatAnnouncements.SendDelayedItemsOut)
end

function ChatAnnouncements.SendDelayedItemsOut()
    I.FlushDelayedItemPoolInDisplayOrder(delayedItemPoolOut)
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

function ChatAnnouncements.InventoryUpdate(eventId, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- End right now if this is any other reason (durability loss, etc)
    if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then
        return
    end

    if IsItemStolen(bagId, slotId) then
        S.g_isStolen = true
        local function ResetIsStolen()
            S.g_isStolen = false
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
                eventManager:RegisterForUpdate(moduleName .. "StackTracker", 50, ChatAnnouncements.ResetStackSplit)
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
                    eventManager:RegisterForUpdate(moduleName .. "StackTracker", 50, ChatAnnouncements.ResetStackSplit)
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
                                         eventManager:UnregisterForUpdate(moduleName .. "Printer")
                                         eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
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
                                             eventManager:UnregisterForUpdate(moduleName .. "Printer")
                                             eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
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

-- TODO: DELETE - This is a dummy function for testing chat messages being cut off.
function ChatAnnouncements.Dummy()
    -- Items Removed
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 808, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, -200)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 4482, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, -500)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 5820, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, -800)

    -- Items Gained
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 4487, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 83)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 5413, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 134)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 6000, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 33)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 6001, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 232)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 23107, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 12)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46128, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 73)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46129, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 44)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46130, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 58)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 64489, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 91)
    LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 533, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 91)

    d(
        "|c0b610bYou craft |r|t16:16:/esoui/art/icons/crafting_smith_plug_standard_r_001.dds|t |H1:item:6000:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Dwarven Ingot]|h |cFFFFFFx33|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ore_base_ebony_r3.dds|t |H1:item:6001:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Ebony Ingot]|h |cFFFFFFx232|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ore_base_iron_r3.dds|t |H1:item:23107:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Orichalcum Ingot]|h |cFFFFFFx12|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ore_base_iron_r2.dds|t |H1:item:5413:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Iron Ingot]|h |cFFFFFFx134|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ore_base_high_iron_r3.dds|t |H1:item:4487:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Steel Ingot]|h |cFFFFFFx83|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_colossus_iron.dds|t |H1:item:64489:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Rubedite Ingot]|h |cFFFFFFx91|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_wood_base_oak_r3.dds|t |H1:item:533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Sanded Oak]|h |cFFFFFFx91|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ingot_voidstone.dds|t |H1:item:46130:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Voidstone Ingot]|h |cFFFFFFx58|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ingot_moonstone.dds|t |H1:item:46129:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Quicksilver Ingot]|h |cFFFFFFx44|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ingot_galatite.dds|t |H1:item:46128:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Galatite Ingot]|h |cFFFFFFx73|r|c0b610b.|r")

    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 803, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 24)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 23121, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 78)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 23122, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 56)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 23123, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 33)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46139, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 131)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46140, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 215)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46141, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 80)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46142, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 66)
end

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

function ChatAnnouncements.InventoryUpdateGuildBank(eventId, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
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

        if not S.g_inventoryStacks[slotId] then -- NEW ITEM
            local icon1, stack1 = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            S.g_inventoryStacks[slotId] = I.MakeStackEntry(bagId, slotId, icon1, stack1, itemId, itemType, itemLink)
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageWithdrawGuild")
            S.g_guildBankCarry = {}
            S.g_guildBankCarry.icon = icon1
            S.g_guildBankCarry.stack = stack1
            S.g_guildBankCarry.gainOrLoss = gainOrLoss
            S.g_guildBankCarry.logPrefix = logPrefix
            S.g_guildBankCarry.receivedBy = receivedBy
            S.g_guildBankCarry.itemLink = itemLink
            S.g_guildBankCarry.itemId = itemId
            S.g_guildBankCarry.itemType = itemType
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
                S.g_guildBankCarry = {}
                S.g_guildBankCarry.icon = icon
                S.g_guildBankCarry.stack = stack
                S.g_guildBankCarry.gainOrLoss = gainOrLoss
                S.g_guildBankCarry.logPrefix = logPrefix
                S.g_guildBankCarry.receivedBy = receivedBy
                S.g_guildBankCarry.itemLink = itemLink
                S.g_guildBankCarry.itemId = itemId
                S.g_guildBankCarry.itemType = itemType
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
                    S.g_guildBankCarry = {}
                    S.g_guildBankCarry.icon = icon
                    S.g_guildBankCarry.stack = stack
                    S.g_guildBankCarry.gainOrLoss = gainOrLoss
                    S.g_guildBankCarry.logPrefix = logPrefix
                    S.g_guildBankCarry.receivedBy = receivedBy
                    S.g_guildBankCarry.itemLink = itemLink
                    S.g_guildBankCarry.itemId = itemId
                    S.g_guildBankCarry.itemType = itemType
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

        S.g_guildBankCarry = {}
        S.g_guildBankCarry.icon = icon
        S.g_guildBankCarry.stack = stack
        S.g_guildBankCarry.gainOrLoss = gainOrLoss
        S.g_guildBankCarry.logPrefix = logPrefix
        S.g_guildBankCarry.receivedBy = receivedBy
        S.g_guildBankCarry.itemLink = itemLink
        S.g_guildBankCarry.itemId = itemId
        S.g_guildBankCarry.itemType = itemType
    end

    S.g_itemWasDestroyed = false
    S.g_lockpickBroken = false
end

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

-- Makes it so bank withdraw/deposit events only occur when we can confirm the item is crossing over.
function ChatAnnouncements.BankFixer()
    S.g_InventoryOn = false
    S.g_bankOn = false
end

function ChatAnnouncements.OnActiveWeaponPairChanged()
    zo_callLater(function ()
        S.g_equippedStacks = {}
        ChatAnnouncements.IndexEquipped()
    end, 50)
end

function ChatAnnouncements.JusticeStealRemove(eventId)
    zo_callLater(ChatAnnouncements.JusticeRemovePrint, 50)
end

function ChatAnnouncements.JusticeDisplayConfiscate()
    if ChatAnnouncements.SV.Notify.NotificationConfiscateCA or ChatAnnouncements.SV.Notify.NotificationConfiscateAlert then
        local ConfiscateMessage
        if S.g_itemsConfiscated then
            ConfiscateMessage = GetString(LUIE_STRING_CA_JUSTICE_CONFISCATED_BOUNTY_ITEMS_MSG)
        else
            ConfiscateMessage = GetString(LUIE_STRING_CA_JUSTICE_CONFISCATED_MSG)
        end

        if ChatAnnouncements.SV.Notify.NotificationConfiscateCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = ConfiscateMessage, type = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        else
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, ConfiscateMessage)
        end
    end
    S.g_itemsConfiscated = false
end

function I.MakeStackEntry(bagId, slotId, icon, stack, itemId, itemType, itemLink)
    return
    {
        icon = icon,
        stack = stack,
        itemId = itemId,
        itemType = itemType,
        itemLink = itemLink,
        stolen = IsItemStolen(bagId, slotId),
    }
end

function I.BuildItemCountMap(stacksTable)
    --- @type table<string,{count:integer,sample:{icon:any,stack:integer,itemId:integer,itemType:integer,itemLink:string,stolen:boolean}}>
    local map = {}
    if not stacksTable then
        return map
    end
    for _, item in pairs(stacksTable) do
        if item and item.itemLink and item.itemLink ~= "" then
            local key = item.itemLink
            local stack = tonumber(item.stack) or 0
            local entry = map[key]
            if entry then
                entry.count = entry.count + stack
                if item.stolen then
                    entry.sample.stolen = true
                end
            else
                map[key] = { count = stack, sample = item }
            end
        end
    end
    return map
end

function I.DiffRemoved(beforeMap, afterMap)
    --- @type {removedCount:integer,sample:{icon:any,stack:integer,itemId:integer,itemType:integer,itemLink:string}}[]
    local removed = {}
    for itemLink, beforeEntry in pairs(beforeMap) do
        local afterCount = (afterMap[itemLink] and afterMap[itemLink].count) or 0
        local removedCount = (beforeEntry.count or 0) - afterCount
        if removedCount and removedCount > 0 then
            removed[#removed + 1] = { removedCount = removedCount, sample = beforeEntry.sample }
        end
    end
    return removed
end

function ChatAnnouncements.JusticeRemovePrint()
    S.g_itemsConfiscated = false
    local stolenConfiscatePrinted = 0

    -- PART 1 -- INVENTORY
    if ChatAnnouncements.SV.Inventory.LootConfiscate then
        -- Build an "after" snapshot across BOTH backpack and worn.
        -- Confiscation can force gear to move between worn/backpack; we only want items removed entirely.
        local afterStacks = {}

        local backpackSize = GetBagSize(BAG_BACKPACK)
        for i = 0, backpackSize do
            local icon, stack = GetItemInfo(BAG_BACKPACK, i)
            local itemType = GetItemType(BAG_BACKPACK, i)
            local itemId = GetItemId(BAG_BACKPACK, i)
            local itemLink = GetItemLink(BAG_BACKPACK, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink ~= "" then
                afterStacks[#afterStacks + 1] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end

        local wornSize = GetBagSize(BAG_WORN)
        for i = 0, wornSize do
            local icon, stack = GetItemInfo(BAG_WORN, i)
            local itemType = GetItemType(BAG_WORN, i)
            local itemId = GetItemId(BAG_WORN, i)
            local itemLink = GetItemLink(BAG_WORN, i, B.linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink ~= "" then
                afterStacks[#afterStacks + 1] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end

        -- Build a "before" snapshot across BOTH backpack and worn.
        local beforeAll = {}
        for _, item in pairs(S.g_inventoryStacks) do
            beforeAll[#beforeAll + 1] = item
        end
        for _, item in pairs(S.g_equippedStacks) do
            beforeAll[#beforeAll + 1] = item
        end

        local beforeMap = I.BuildItemCountMap(beforeAll)
        local afterMap = I.BuildItemCountMap(afterStacks)
        local removedItems = I.DiffRemoved(beforeMap, afterMap)

        for i = 1, #removedItems do
            local removed = removedItems[i]
            local sample = removed.sample
            if sample and removed.removedCount > 0 and sample.stolen then
                local receivedBy = ""
                local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                local logPrefix = ChatAnnouncements.GetContextMessage("CurrencyMessageConfiscate")
                ChatAnnouncements.ItemPrinter(sample.icon, removed.removedCount, sample.itemType, sample.itemId, sample.itemLink, receivedBy, logPrefix, gainOrLoss, false)
                stolenConfiscatePrinted = stolenConfiscatePrinted + 1
            end
        end
    end

    if stolenConfiscatePrinted > 0 then
        S.g_itemsConfiscated = true
    end

    S.g_JusticeStacks = {} -- Clear the Justice Item Stacks since we don't need this for anything else!
    S.g_equippedStacks = {}
    S.g_inventoryStacks = {}
    ChatAnnouncements.IndexEquipped()
    ChatAnnouncements.IndexInventory() -- Reindex the inventory with the correct values!
end

function ChatAnnouncements.DisguiseState(eventId, unitTag, disguiseState)
    -- if LUIE.IsDevDebugEnabled() then
    --     local traceback = "Disguise State:\n" ..
    --         "--> eventId: " .. tostring(eventId) .. "\n" ..
    --         "--> unitTag: " .. tostring(unitTag) .. "\n" ..
    --         "--> disguiseState: " .. tostring(disguiseState)
    --     LUIE:Log("Debug", traceback)
    -- end

    if disguiseState == DISGUISE_STATE_DANGER then
        if ChatAnnouncements.SV.Notify.DisguiseWarnCA then
            local message = GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DANGER)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.GROUP_ELECTION_REQUESTED)
            messageParams:SetText(ColorizeColors.DisguiseAlertColorize:Colorize(GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DANGER)))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DANGER))
        end

        if (ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert) and not ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
        end
    end

    if disguiseState == DISGUISE_STATE_SUSPICIOUS then
        if ChatAnnouncements.SV.Notify.DisguiseWarnCA then
            local message = GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_SUSPICIOUS)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_MAJOR_TEXT, SOUNDS.GROUP_ELECTION_REQUESTED)
            messageParams:SetText(ColorizeColors.DisguiseAlertColorize:Colorize(GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_SUSPICIOUS)))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_SUSPICIOUS))
        end
        if (ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert) and not ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
        end
    end

    -- If we're still disguised and S.g_disguiseState is true then don't waste resources and end the function
    if S.g_disguiseState == 1 and (disguiseState == DISGUISE_STATE_DISGUISED or disguiseState == DISGUISE_STATE_DANGER or disguiseState == DISGUISE_STATE_SUSPICIOUS or disguiseState == DISGUISE_STATE_DISCOVERED) then
        return
    end

    if S.g_disguiseState == 1 and (disguiseState == DISGUISE_STATE_NONE) then
        local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_NONE), Effects.DisguiseIcons[S.g_currentDisguise].description)
        if ChatAnnouncements.SV.Notify.DisguiseCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.DisguiseAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
        if ChatAnnouncements.SV.Notify.DisguiseCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
            messageParams:SetText(message)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end

    if S.g_disguiseState == 0 and (disguiseState == DISGUISE_STATE_DISGUISED or disguiseState == DISGUISE_STATE_DANGER or disguiseState == DISGUISE_STATE_SUSPICIOUS or disguiseState == DISGUISE_STATE_DISCOVERED) then
        S.g_currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
        local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DISGUISED), Effects.DisguiseIcons[S.g_currentDisguise].description)
        if ChatAnnouncements.SV.Notify.DisguiseCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.DisguiseAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
        if ChatAnnouncements.SV.Notify.DisguiseCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
            messageParams:SetText(message)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
    end

    S.g_disguiseState = GetUnitDisguiseState("player")

    if S.g_disguiseState > 0 then
        S.g_disguiseState = 1
    end
end

function ChatAnnouncements.OnPlayerActivated(eventId)
    S.pendingHomeJump = false
    ChatAnnouncements.ResetMailSession()

    -- Get current trades if UI is reloaded
    local characterName, _, displayName = GetTradeInviteInfo()

    if characterName ~= "" and displayName ~= "" then
        local tradeName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
        S.g_tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat("<<C:1>>", tradeName))
    end

    zo_callLater(function ()
                     S.g_loginHideQuestLoot = false
                 end, 3000)

    if ChatAnnouncements.SV.Notify.DisguiseCA or ChatAnnouncements.SV.Notify.DisguiseCSA or ChatAnnouncements.SV.Notify.DisguiseAlert or ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnCSA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
        if S.g_disguiseState == 0 then
            S.g_disguiseState = GetUnitDisguiseState("player")
            if S.g_disguiseState == 0 then
                return
            elseif S.g_disguiseState ~= 0 then
                S.g_disguiseState = 1
                S.g_currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
                local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DISGUISED), Effects.DisguiseIcons[S.g_currentDisguise].description)
                if ChatAnnouncements.SV.Notify.DisguiseCA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "MESSAGE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end
                if ChatAnnouncements.SV.Notify.DisguiseAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
                end
                if ChatAnnouncements.SV.Notify.DisguiseCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
                    messageParams:SetText(message)
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
                return
            end
        elseif S.g_disguiseState == 1 then
            S.g_disguiseState = GetUnitDisguiseState("player")
            if S.g_disguiseState == 0 then
                local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_NONE), Effects.DisguiseIcons[S.g_currentDisguise].description)
                if ChatAnnouncements.SV.Notify.DisguiseCA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = "MESSAGE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end
                if ChatAnnouncements.SV.Notify.DisguiseAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
                end
                if ChatAnnouncements.SV.Notify.DisguiseCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
                    messageParams:SetText(message)
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
                return
            elseif S.g_disguiseState ~= 0 then
                S.g_disguiseState = 1
                S.g_currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
                return
            end
        end
    end
end

--[[ STUCK REFERENCE
function ChatAnnouncements.StuckOnCooldown(eventId)
    local cooldownText = ZO_FormatTime(GetStuckCooldown(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    local cooldownRemainingText = ZO_FormatTimeMilliseconds(GetTimeUntilStuckAvailable(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    ChatOutput:Print(zo_strformat(GetString(SI_STUCK_ERROR_ON_COOLDOWN), cooldownText, cooldownRemainingText ))
end
]]

-- TODO: Replace/Remove

--[[
function ChatAnnouncements.InventoryFullQuest(eventId)
    ChatOutput:Print(GetString(SI_INVENTORY_ERROR_INVENTORY_FULL), true)
end

function ChatAnnouncements.InventoryFull(eventId, numSlotsRequested, numSlotsFree)
    local function DisplayItemFailed()
        if numSlotsRequested == 1 then
            ChatOutput:Print(GetString(SI_INVENTORY_ERROR_INVENTORY_FULL), true)
        else
            ChatOutput:Print(zo_strformat(GetString(SI_INVENTORY_ERROR_INSUFFICIENT_SPACE), (numSlotsRequested - numSlotsFree) ))
        end
    end

    zo_callLater(DisplayItemFailed, 100)
end

function ChatAnnouncements.LootItemFailed(eventId, reason, itemName)
    -- Stop Spam
    eventManager:UnregisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED)

    local function ReactivateLootItemFailed()
    ChatOutput:Print(zo_strformat(GetString("SI_LOOTITEMRESULT", reason), itemName))
        eventManager:RegisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED, ChatAnnouncements.LootItemFailed)
    end

    zo_callLater(ReactivateLootItemFailed, 100)
end
]]

-------------------------------------------------------------------------
-- UPDATED CODE
-------------------------------------------------------------------------

-- LINK_HANDLER.LINK_MOUSE_UP_EVENT
-- LINK_HANDLER.LINK_CLICKED_EVENT
-- Custom Link Handlers to deal with when a book link in chat is clicked, this will open the book rather than the default link that only shows whether a lore entry has been read or not.
function LUIE.HandleClickEvent(rawLink, mouseButton, linkText, linkStyle, linkType, categoryIndex, collectionIndex, bookIndex)
    -- if LUIE.IsDevDebugEnabled() then
    --     local traceback = "Handle Click Event:\n" ..
    --         "--> rawLink: " .. tostring(rawLink) .. "\n" ..
    --         "--> mouseButton: " .. tostring(mouseButton) .. "\n" ..
    --         "--> linkText: " .. tostring(linkText) .. "\n" ..
    --         "--> linkStyle: " .. tostring(linkStyle) .. "\n" ..
    --         "--> linkType: " .. tostring(linkType) .. "\n" ..
    --         "--> categoryIndex: " .. tostring(categoryIndex) .. "\n" ..
    --         "--> collectionIndex: " .. tostring(collectionIndex) .. "\n" ..
    --         "--> bookIndex: " .. tostring(bookIndex)
    --     LUIE:Log("Debug", traceback)
    -- end

    if linkType == "LINK_TYPE_LUIBOOK" then
        -- Read the book
        ZO_LoreLibrary_ReadBook(categoryIndex, collectionIndex, bookIndex)
        return true
    end
    if linkType == "LINK_TYPE_LUIANTIQUITY" then
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

-- Alert & CSA prehooks: ChatAnnouncements.HookFunction() in ChatAnnouncementsHooks.lua


-- Called when another player joins the group.
function ChatAnnouncements.PrintJoinStatusNotSelf(SendMessage, SendAlert)
    -- Bail out if we're hiding events from LFG.
    if S.g_stopGroupLeaveQueue or S.g_lfgDisableGroupEvents then
        return
    end

    -- Otherwise print the message
    if ChatAnnouncements.SV.Group.GroupCA then
        ChatOutput:Print(SendMessage, true)
    end
    if ChatAnnouncements.SV.Group.GroupAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, SendAlert)
    end
end

-- Called on player leaving a group to determine if message syntax should show group or LFG group.
function ChatAnnouncements.CheckLFGStatusLeave(WasKicked)
    -- Bail out if we joined an LFG group.
    if S.g_stopGroupLeaveQueue or S.g_lfgDisableGroupEvents then
        S.g_leaveLFGOverride = false
        return
    end
    if S.g_leaveLFGOverride and GetGroupSize() == 0 then
        if ChatAnnouncements.SV.Group.GroupCA then
            ChatOutput:Print(GetString(LUIE_STRING_CA_GROUP_QUIT_LFG), true)
        end
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_GROUP_QUIT_LFG))
        end
    end
    S.g_leaveLFGOverride = false
end

-- EVENT_GROUP_INVITE_RECEIVED
function ChatAnnouncements.OnGroupInviteReceived(eventId, inviterName, inviterDisplayName)
    if ChatAnnouncements.SV.Group.GroupCA then
        local finalName = ChatAnnouncements.ResolveNameLink(inviterName, inviterDisplayName)
        local message = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MESSAGE), finalName)
        ChatOutput:Print(message, true)
    end
    if ChatAnnouncements.SV.Group.GroupAlert then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterName, inviterDisplayName)
        local alertText = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MESSAGE), finalAlertName)
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertText)
    end
end

function ChatAnnouncements.IndexGroupLoot()
    -- Rebuild rather than merge: previously this function only ever inserted,
    -- so every group composition seen during the session left a permanent
    -- characterName key in g_groupLootIndex (real growth across PUG/LFG nights).
    ZO_ClearTable(S.g_groupLootIndex)
    local groupSize = GetGroupSize()
    for i = 1, groupSize do
        local characterName = GetUnitName("group" .. i)
        local displayName = GetUnitDisplayName("group" .. i)
        if displayName == nil or displayName == "" then
            displayName = characterName
        end
        S.g_groupLootIndex[characterName] = { characterName = characterName, displayName = displayName }
    end
end

-- EVENT_GROUP_TYPE_CHANGED
function ChatAnnouncements.OnGroupTypeChanged(eventId, largeGroup)
    local message
    if largeGroup then
        message = GetString(SI_CHAT_ANNOUNCEMENT_IN_LARGE_GROUP)
    else
        message = GetString(SI_CHAT_ANNOUNCEMENT_IN_SMALL_GROUP)
    end

    if ChatAnnouncements.SV.Group.GroupCA then
        ChatOutput:Print(message, true)
    end
    if ChatAnnouncements.SV.Group.GroupAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
    end
end

-- EVENT_GROUP_ELECTION_NOTIFICATION_ADDED
function ChatAnnouncements.VoteNotify(eventId)
    local electionType, timeRemainingSeconds, electionDescriptor, targetUnitTag = GetGroupElectionInfo()
    if electionType == GROUP_ELECTION_TYPE_GENERIC_UNANIMOUS then -- Ready Check
        if ChatAnnouncements.SV.Group.GroupVoteCA then
            ChatOutput:Print(GetString(SI_GROUP_ELECTION_READY_CHECK_MESSAGE), true)
        end
        if ChatAnnouncements.SV.Group.GroupVoteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, GetString(SI_GROUP_ELECTION_READY_CHECK_MESSAGE))
        end
    end

    if electionType == GROUP_ELECTION_TYPE_KICK_MEMBER then -- Vote Kick
        local kickMemberName = GetUnitName(targetUnitTag)
        local kickMemberAccountName = GetUnitDisplayName(targetUnitTag)

        if ChatAnnouncements.SV.Group.GroupVoteCA then
            local finalName = ChatAnnouncements.ResolveNameLink(kickMemberName, kickMemberAccountName)
            local message = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_START), finalName)
            ChatOutput:Print(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupVoteAlert then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(kickMemberName, kickMemberAccountName)
            local alertText = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_START), finalAlertName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertText)
        end
    end
end

-- EVENT_GROUPING_TOOLS_NO_LONGER_LFG
function ChatAnnouncements.LFGLeft(eventId)
    S.g_leaveLFGOverride = true
end

-- EVENT_PLEDGE_OF_MARA_OFFER - EVENT HANDLER
function ChatAnnouncements.MaraOffer(eventId, characterName, isSender, displayName)
    -- Display CA
    if ChatAnnouncements.SV.Social.PledgeOfMaraCA then
        local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
        if isSender then
            ChatOutput:Print(zo_strformat(GetString(SI_PLEDGE_OF_MARA_SENDER_MESSAGE), finalName), true)
        else
            ChatOutput:Print(zo_strformat(GetString(SI_PLEDGE_OF_MARA_MESSAGE), finalName), true)
        end
    end

    -- Display Alert
    if ChatAnnouncements.SV.Social.PledgeOfMaraAlert then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
        local alertString
        if isSender then
            alertString = zo_strformat(GetString(SI_PLEDGE_OF_MARA_SENDER_MESSAGE), finalAlertName)
        else
            alertString = zo_strformat(GetString(SI_PLEDGE_OF_MARA_MESSAGE), finalAlertName)
        end
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertString)
    end
end

-- EVENT_DUEL_STARTED -- EVENT HANDLER
function ChatAnnouncements.DuelStarted(eventId)
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
            ChatOutput:Print(message, true)
        end

        if ChatAnnouncements.SV.Social.DuelStartAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
    end

    -- Play sound if CSA is not enabled
    if not ChatAnnouncements.SV.Social.DuelStartCSA then
        PlaySound(SOUNDS.DUEL_START)
    end
end

function ChatAnnouncements.ResetStackSplit()
    S.g_stackSplit = false
    eventManager:UnregisterForUpdate(moduleName .. "StackTracker")
end

function ChatAnnouncements.PrintQueuedMessages()
    local messageTypes =
    {
        "NOTIFICATION",
        "QUEST_POI",
        "QUEST",
        "EXPERIENCE",
        "EXPERIENCE LEVEL",
        "SKILL GAIN",
        "SKILL MORPH",
        "SKILL LINE",
        "SKILL",
        "CURRENCY POSTAGE",
        "QUEST LOOT REMOVE",
        "CONTAINER",
        "CURRENCY",
        "QUEST LOOT ADD",
        "LOOT",
        "ANTIQUITY",
        "COLLECTIBLE",
        "ACHIEVEMENT",
        "MESSAGE"
    }

    for _, messageType in pairs(messageTypes) do
        for i = 1, #ChatAnnouncements.QueuedMessages do
            local message = ChatAnnouncements.QueuedMessages[i]
            if message and message.message ~= "" and message.type == messageType then
                if messageType == "QUEST LOOT REMOVE" then
                    local itemId = message.itemId
                    if not S.g_questItemAdded[itemId] then
                        ChatOutput:Print(message.message)
                    end
                elseif messageType == "CONTAINER" or messageType == "LOOT" then
                    ChatAnnouncements.ResolveItemMessage(message.message, message.formattedRecipient, message.color, message.logPrefix, message.totalString, message.groupLoot)
                elseif messageType == "QUEST LOOT ADD" then
                    local itemId = message.itemId
                    if not S.g_questItemRemoved[itemId] then
                        ChatOutput:Print(message.message)
                    end
                else
                    local isSystem = message.isSystem or false
                    ChatOutput:Print(message.message, isSystem)
                end
            end
        end
    end

    ZO_ClearTable(ChatAnnouncements.QueuedMessages)
    ChatAnnouncements.QueuedMessagesCounter = 1
    eventManager:UnregisterForUpdate(moduleName .. "Printer")
end

local mementoTable =
{
    [10287] = GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_CAKE),
    [1167] = GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_PIE),
    [1168] = GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_MEAD),
    [479] = GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_WITCH),
}

function ChatAnnouncements.AnnounceMemento()
    local string = mementoTable[LUIE.LastMementoUsed] or nil
    if string == nil then
        LUIE.LastMementoUsed = 0
        return
    end

    local link = GetCollectibleLink(LUIE.LastMementoUsed, B.linkBrackets[ChatAnnouncements.SV.BracketOptionCollectibleUse])
    local name = GetCollectibleName(LUIE.LastMementoUsed)
    local icon = GetCollectibleIcon(LUIE.LastMementoUsed)

    local formattedIcon = ChatAnnouncements.SV.Collectibles.CollectibleUseIcon and ("|t16:16:" .. icon .. "|t ") or ""

    local message = zo_strformat(string, link, formattedIcon)
    local alert = zo_strformat(string, name, "")

    if message and ChatAnnouncements.SV.Collectibles.CollectibleUseCA or LUIE.LastMementoUsed > 0 then
        message = ColorizeColors.CollectibleUseColorize:Colorize(message)
        ChatOutput:Print(message)
    end
    if alert and ChatAnnouncements.SV.Collectibles.CollectibleUseAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alert)
    end

    LUIE.LastMementoUsed = 0
end

function ChatAnnouncements.CollectibleUsed(eventId, result, isAttemptingActivation)
    if result ~= COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED then
        return
    end
    local latency = GetLatency()
    latency = latency + 100
    zo_callLater(ChatAnnouncements.CollectibleResult, latency)
end

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

    if newAssistant ~= S.currentAssistant then
        if newAssistant == 0 then
            S.lastCollectibleUsed = S.currentAssistant
        else
            S.lastCollectibleUsed = newAssistant
            -- S.currentCompanion = newAssistant -- fixes summoning assistant, if companion already summoned, from using sys message/icon of old companion instead of new assistant
        end
    end
    if newCompanion ~= S.currentCompanion then
        if newCompanion == 0 then
            S.lastCollectibleUsed = S.currentCompanion
        else
            S.lastCollectibleUsed = newCompanion
        end
    end
    if newVanity ~= S.currentVanity then
        if newVanity == 0 then
            S.lastCollectibleUsed = S.currentVanity
        else
            S.lastCollectibleUsed = newVanity
        end
    end
    if newSpecial ~= S.currentSpecial then
        if newSpecial == 0 then
            S.lastCollectibleUsed = S.currentSpecial
        else
            S.lastCollectibleUsed = newSpecial
        end
    end
    if newHat ~= S.currentHat then
        if newHat == 0 then
            S.lastCollectibleUsed = S.currentHat
        else
            S.lastCollectibleUsed = newHat
        end
    end
    if newHair ~= S.currentHair then
        if newHair == 0 then
            S.lastCollectibleUsed = S.currentHair
        else
            S.lastCollectibleUsed = newHair
        end
    end
    if newHeadMark ~= S.currentHeadMark then
        if newHeadMark == 0 then
            S.lastCollectibleUsed = S.currentHeadMark
        else
            S.lastCollectibleUsed = newHeadMark
        end
    end
    if newFacialHair ~= S.currentFacialHair then
        if newFacialHair == 0 then
            S.lastCollectibleUsed = S.currentFacialHair
        else
            S.lastCollectibleUsed = newFacialHair
        end
    end
    if newMajorAdorn ~= S.currentMajorAdorn then
        if newMajorAdorn == 0 then
            S.lastCollectibleUsed = S.currentMajorAdorn
        else
            S.lastCollectibleUsed = newMajorAdorn
        end
    end
    if newMinorAdorn ~= S.currentMinorAdorn then
        if newMinorAdorn == 0 then
            S.lastCollectibleUsed = S.currentMinorAdorn
        else
            S.lastCollectibleUsed = newMinorAdorn
        end
    end
    if newCostume ~= S.currentCostume then
        if newCostume == 0 then
            S.lastCollectibleUsed = S.currentCostume
        else
            S.lastCollectibleUsed = newCostume
        end
    end
    if newBodyMarking ~= S.currentBodyMarking then
        if newBodyMarking == 0 then
            S.lastCollectibleUsed = S.currentBodyMarking
        else
            S.lastCollectibleUsed = newBodyMarking
        end
    end
    if newSkin ~= S.currentSkin then
        if newSkin == 0 then
            S.lastCollectibleUsed = S.currentSkin
        else
            S.lastCollectibleUsed = newSkin
        end
    end
    if newPersonality ~= S.currentPersonality then
        if newPersonality == 0 then
            S.lastCollectibleUsed = S.currentPersonality
        else
            S.lastCollectibleUsed = newPersonality
        end
    end
    if newPolymorph ~= S.currentPolymorph then
        if newPolymorph == 0 then
            S.lastCollectibleUsed = S.currentPolymorph
        else
            S.lastCollectibleUsed = newPolymorph
        end
    end

    for harvestingType = PLAYER_FX_WHILE_HARVESTING_TYPE_ITERATION_BEGIN, PLAYER_FX_WHILE_HARVESTING_TYPE_ITERATION_END do
        if I.IsPlayerFxHarvestTypeTracked(harvestingType) then
            local newPlayerFxHarvest = I.GetActivePlayerFxHarvestCollectibleId(harvestingType)
            local previousPlayerFxHarvest = S.currentPlayerFxHarvest[harvestingType] or 0
            if newPlayerFxHarvest ~= previousPlayerFxHarvest then
                if newPlayerFxHarvest == 0 then
                    S.lastCollectibleUsed = previousPlayerFxHarvest
                else
                    S.lastCollectibleUsed = newPlayerFxHarvest
                end
                S.currentPlayerFxHarvest[harvestingType] = newPlayerFxHarvest
            end
        end
    end

    local newPlayerFxAbility = I.GetActivePlayerFxAbilityCollectibleId()
    if newPlayerFxAbility ~= S.currentPlayerFxAbility then
        if newPlayerFxAbility == 0 then
            S.lastCollectibleUsed = S.currentPlayerFxAbility
        else
            S.lastCollectibleUsed = newPlayerFxAbility
        end
        S.currentPlayerFxAbility = newPlayerFxAbility
    end

    S.currentAssistant = newAssistant
    S.currentCompanion = newCompanion
    S.currentVanity = newVanity
    S.currentSpecial = newSpecial
    S.currentHat = newHat
    S.currentHair = newHair
    S.currentHeadMark = newHeadMark
    S.currentFacialHair = newFacialHair
    S.currentMajorAdorn = newMajorAdorn
    S.currentMinorAdorn = newMinorAdorn
    S.currentCostume = newCostume
    S.currentBodyMarking = newBodyMarking
    S.currentSkin = newSkin
    S.currentPersonality = newPersonality
    S.currentPolymorph = newPolymorph

    -- If neither menu option is enabled, then bail out here
    if not (ChatAnnouncements.SV.Collectibles.CollectibleUseCA or ChatAnnouncements.SV.Collectibles.CollectibleUseAlert) then
        if not LUIE.SlashCollectibleOverride then
            S.lastCollectibleUsed = 0
            return
        end
    end

    if S.lastCollectibleUsed == 0 then
        LUIE.SlashCollectibleOverride = false
        return
    end
    local collectibleType = GetCollectibleCategoryType(S.lastCollectibleUsed)

    local message
    local alert
    local link = GetCollectibleLink(S.lastCollectibleUsed, B.linkBrackets[ChatAnnouncements.SV.BracketOptionCollectibleUse])
    local name = GetCollectibleName(S.lastCollectibleUsed)
    local nickname = GetCollectibleNickname(S.lastCollectibleUsed)
    local icon = GetCollectibleIcon(S.lastCollectibleUsed)
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

    -- Special / Appearance / Customized Actions
    if collectibleType == COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE or collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAT or collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAIR or collectibleType == COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING or collectibleType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS or collectibleType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY or collectibleType == COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY or collectibleType == COLLECTIBLE_CATEGORY_TYPE_COSTUME or collectibleType == COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING or collectibleType == COLLECTIBLE_CATEGORY_TYPE_SKIN or collectibleType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY or collectibleType == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH or collectibleType == COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE then
        local categoryString
        if collectibleType == COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE then
            local overrideType = GetCollectiblePlayerFxOverrideType(S.lastCollectibleUsed)
            if overrideType == PLAYER_FX_OVERRIDE_TYPE_HARVEST then
                local harvestType = GetCollectiblePlayerFxWhileHarvestingType(S.lastCollectibleUsed)
                categoryString = GetString("SI_PLAYERFXWHILEHARVESTINGTYPE", harvestType)
            elseif overrideType == PLAYER_FX_OVERRIDE_TYPE_ABILITY then
                local abilityType = GetCollectiblePlayerFxOverrideAbilityType(S.lastCollectibleUsed)
                categoryString = GetString("SI_PLAYERFXOVERRIDEABILITYTYPE", abilityType)
            else
                categoryString = GetString(SI_COLLECTIBLECATEGORYTYPE29)
            end
        else
            categoryString = (collectibleType == COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE) and GetString(SI_COLLECTIBLECATEGORYTYPE30) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAT) and GetString(SI_COLLECTIBLECATEGORYTYPE10) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_HAIR) and GetString(SI_COLLECTIBLECATEGORYTYPE13) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING) and GetString(SI_COLLECTIBLECATEGORYTYPE17) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS) and GetString(SI_COLLECTIBLECATEGORYTYPE14) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY) and GetString(SI_COLLECTIBLECATEGORYTYPE15) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY) and GetString(SI_COLLECTIBLECATEGORYTYPE16) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_COSTUME) and GetString(SI_COLLECTIBLECATEGORYTYPE4) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING) and GetString(SI_COLLECTIBLECATEGORYTYPE18) or
                (collectibleType == COLLECTIBLE_CATEGORY_TYPE_SKIN) and GetString(SI_COLLECTIBLECATEGORYTYPE11) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_PERSONALITY) and GetString(SI_COLLECTIBLECATEGORYTYPE9) or (collectibleType == COLLECTIBLE_CATEGORY_TYPE_POLYMORPH) and GetString(SI_COLLECTIBLECATEGORYTYPE12)
        end

        if (collectibleType == COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE and (ChatAnnouncements.SV.Collectibles.CollectibleUseCategory12 or LUIE.SlashCollectibleOverride))
        or (collectibleType ~= COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE and (ChatAnnouncements.SV.Collectibles.CollectibleUseCategory3 or LUIE.SlashCollectibleOverride)) then
            local isActive
            if collectibleType == COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE then
                isActive = IsCollectibleActive(S.lastCollectibleUsed, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
            else
                isActive = GetActiveCollectibleByType(GetCollectibleCategoryType(S.lastCollectibleUsed), GAMEPLAY_ACTOR_CATEGORY_PLAYER) > 0
            end
            if isActive then
                message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_USE_CATEGORY), categoryString, link, formattedIcon)
                alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_USE_CATEGORY), categoryString, name, "")
            else
                message = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_DISABLE_CATEGORY), categoryString, link, formattedIcon)
                alert = zo_strformat(GetString(LUIE_STRING_SLASHCMDS_COLLECTIBLE_DISABLE_CATEGORY), categoryString, name, "")
            end
        end
    end

    if message and ChatAnnouncements.SV.Collectibles.CollectibleUseCA or LUIE.SlashCollectibleOverride then
        message = ColorizeColors.CollectibleUseColorize:Colorize(message)
        ChatOutput:Print(message)
    end
    if alert and ChatAnnouncements.SV.Collectibles.CollectibleUseAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alert)
    end

    S.lastCollectibleUsed = 0
    LUIE.SlashCollectibleOverride = false
end
