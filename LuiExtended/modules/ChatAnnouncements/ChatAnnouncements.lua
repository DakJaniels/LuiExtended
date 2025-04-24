-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local printToChat = LUIE.PrintToChat
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
local ipairs = ipairs
local select = select
local tonumber = tonumber
local unpack = unpack
local type = type
local string = string
local string_find = string.find
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep
local string_format = string.format
local table = table
local table_concat = table.concat
local table_insert = table.insert
local table_move = table.move
local table_remove = table.remove
local table_sort = table.sort

-- -----------------------------------------------------------------------------
-- ChatAnnouncements namespace
-- -----------------------------------------------------------------------------

local moduleName = LUIE.name .. "ChatAnnouncements"

--- @class (partial) ChatAnnouncements
local ChatAnnouncements =
{
    -- Queued Messages Storage for CA Modules
    QueuedMessages = {},
    QueuedMessagesCounter = 1,
    -- Setup Color Table
    Colors = {},
    ------------------------------------------------
    -- DEFAULT VARIABLE SETUP ----------------------
    ------------------------------------------------
    Enabled = false,
    Defaults =
    {
        -- Chat Message Settings
        ChatPlayerDisplayOptions = 2,
        -- NotificationColor             = { .75, .75, .75, 1 },
        BracketOptionCharacter = 2,
        BracketOptionItem = 2,
        BracketOptionLorebook = 2,
        BracketOptionCollectible = 2,
        BracketOptionCollectibleUse = 2,
        BracketOptionAchievement = 2,
        ChatMethod = "Print to All Tabs",
        ChatBypassFormat = false,
        ChatTab = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true },
        ChatSystemAll = true,
        TimeStamp = false,
        TimeStampFormat = "HH:m:s",
        TimeStampColor = { 143 / 255, 143 / 255, 143 / 255 },

        -- Achievements
        Achievement =
        {
            AchievementCategoryIgnore = {}, -- Inverted list of achievements to be tracked
            AchievementProgressMsg = GetString(LUIE_STRING_CA_ACHIEVEMENT_PROGRESS_MSG),
            AchievementCompleteMsg = GetString(SI_ACHIEVEMENT_AWARDED_CENTER_SCREEN),
            AchievementColorProgress = true,
            AchievementColor1 = { 0.75, 0.75, 0.75, 1 },
            AchievementColor2 = { 1, 1, 1, 1 },
            AchievementCompPercentage = false,
            AchievementUpdateCA = false,
            AchievementUpdateAlert = false,
            AchievementCompleteCA = true,
            AchievementCompleteCSA = true,
            AchievementCompleteAlwaysCSA = true,
            AchievementCompleteAlert = false,
            AchievementIcon = true,
            AchievementCategory = true,
            AchievementSubcategory = true,
            AchievementDetails = true,
            AchievementBracketOptions = 4,
            AchievementCatBracketOptions = 2,
            AchievementStep = 10,
        },

        -- Group
        Group =
        {
            GroupCA = true,
            GroupAlert = false,
            GroupLFGCA = true,
            GroupLFGAlert = false,
            GroupLFGQueueCA = true,
            GroupLFGQueueAlert = false,
            GroupLFGCompleteCA = false,
            GroupLFGCompleteCSA = true,
            GroupLFGCompleteAlert = false,
            GroupVoteCA = true,
            GroupVoteAlert = true,
            GroupRaidCA = false,
            GroupRaidCSA = true,
            GroupRaidAlert = false,
            GroupRaidScoreCA = false,
            GroupRaidScoreCSA = true,
            GroupRaidScoreAlert = false,
            GroupRaidBestScoreCA = false,
            GroupRaidBestScoreCSA = true,
            GroupRaidBestScoreAlert = false,
            GroupRaidReviveCA = false,
            GroupRaidReviveCSA = true,
            GroupRaidReviveAlert = false,
        },

        -- Social
        Social =
        {
            -- Guild
            GuildCA = true,
            GuildAlert = false,
            GuildRankCA = true,
            GuildRankAlert = false,
            GuildManageCA = false,
            GuildManageAlert = false,
            GuildIcon = true,
            GuildAllianceColor = true,
            GuildColor = { 1, 1, 1, 1 },
            GuildRankDisplayOptions = 1,

            -- Friend
            FriendIgnoreCA = true,
            FriendIgnoreAlert = false,
            FriendStatusCA = true,
            FriendStatusAlert = false,

            -- Duel
            DuelCA = true,
            DuelAlert = false,
            DuelBoundaryCA = false,
            DuelBoundaryCSA = true,
            DuelBoundaryAlert = false,
            DuelWonCA = false,
            DuelWonCSA = true,
            DuelWonAlert = false,
            DuelStartCA = false,
            DuelStartCSA = true,
            DuelStartAlert = false,
            DuelStartOptions = 1,

            -- Pledge of Mara
            PledgeOfMaraCA = true,
            PledgeOfMaraCSA = true,
            PledgeOfMaraAlert = false,
            PledgeOfMaraAlertOnlyFail = true,
        },

        -- Notifications
        Notify =
        {
            -- Notifications
            NotificationConfiscateCA = true,
            NotificationConfiscateAlert = false,
            NotificationLockpickCA = true,
            NotificationLockpickAlert = false,
            NotificationMailSendCA = false,
            NotificationMailSendAlert = false,
            NotificationMailErrorCA = true,
            NotificationMailErrorAlert = false,
            NotificationTradeCA = true,
            NotificationTradeAlert = false,

            -- Disguise
            DisguiseCA = false,
            DisguiseCSA = true,
            DisguiseAlert = false,
            DisguiseWarnCA = false,
            DisguiseWarnCSA = true,
            DisguiseWarnAlert = false,
            DisguiseAlertColor = { 1, 0, 0, 1 },

            -- Storage / Riding Upgrades
            StorageRidingColor = { 0.75, 0.75, 0.75, 1 },
            StorageRidingBookColor = { 0.75, 0.75, 0.75, 1 },
            StorageRidingCA = true,
            StorageRidingCSA = true,
            StorageRidingAlert = false,

            StorageBagColor = { 0.75, 0.75, 0.75, 1 },
            StorageBagCA = true,
            StorageBagCSA = true,
            StorageBagAlert = false,

            TimedActivityCA = false,
            TimedActivityAlert = false,
            PromotionalEventsActivityCA = false,
            PromotionalEventsActivityAlert = false,

            CraftedAbilityCA = true,
            CraftedAbilityAlert = false,
            CraftedAbilityScriptCA = true,
            CraftedAbilityScriptAlert = false,
        },

        -- Collectibles
        Collectibles =
        {
            CollectibleCA = true,
            CollectibleCSA = true,
            CollectibleAlert = false,
            CollectibleBracket = 4,
            CollectiblePrefix = GetString(LUIE_STRING_CA_COLLECTIBLE),
            CollectibleIcon = true,
            CollectibleColor1 = { 0.75, 0.75, 0.75, 1 },
            CollectibleColor2 = { 0.75, 0.75, 0.75, 1 },
            CollectibleCategory = true,
            CollectibleSubcategory = true,
            CollectibleUseCA = false,
            CollectibleUseAlert = false,
            CollectibleUsePetNickname = false,
            CollectibleUseIcon = true,
            CollectibleUseColor = { 0.75, 0.75, 0.75, 1 },
            CollectibleUseCategory3 = true,  -- Appearance
            CollectibleUseCategory7 = true,  -- Assistants
            -- CollectibleUseCategory8       = true, -- Mementos
            CollectibleUseCategory10 = true, -- Non-Combat Pets
            CollectibleUseCategory12 = true, -- Special
        },

        -- Lorebooks
        Lorebooks =
        {
            LorebookCA = true,          -- Display a CA for Lorebooks
            LorebookCSA = true,         -- Display a CSA for Lorebooks
            LorebookCSALoreOnly = true, -- Only Display a CSA for non-Eidetic Memory Books
            LorebookAlert = false,      -- Display a ZO_Alert for Lorebooks
            LorebookCollectionCA = true,
            LorebookCollectionCSA = true,
            LorebookCollectionAlert = false,
            LorebookCollectionPrefix = GetString(SI_LORE_LIBRARY_COLLECTION_COMPLETED_LARGE),
            LorebookPrefix1 = GetString(SI_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED),
            LorebookPrefix2 = GetString(LUIE_STRING_CA_LOREBOOK_BOOK),
            LorebookBracket = 4,                      -- Bracket Options
            LorebookColor1 = { 0.75, 0.75, 0.75, 1 }, -- Lorebook Message Color 1
            LorebookColor2 = { 0.75, 0.75, 0.75, 1 }, -- Lorebook Message Color 2
            LorebookIcon = true,                      -- Display an icon for Lorebook CA
            LorebookShowHidden = false,               -- Display books even when they are hidden in the journal menu
            LorebookCategory = true,                  -- Display "added to X category" message
        },

        -- Antiquities
        Antiquities =
        {
            AntiquityCA = true,
            AntiquityCSA = true,
            AntiquityAlert = false,
            AntiquityBracket = 2,
            AntiquityPrefix = GetString(LUIE_STRING_CA_ANTIQUITY_PREFIX),
            AntiquityPrefixBracket = 4,
            AntiquitySuffix = "",
            AntiquityColor = { 0.75, 0.75, 0.75, 1 },
            AntiquityIcon = true,
        },

        -- Quest
        Quests =
        {
            QuestShareCA = true,
            QuestShareAlert = false,
            QuestColorLocName = { 1, 1, 1, 1 },
            QuestColorLocDescription = { 0.75, 0.75, 0.75, 1 },
            QuestColorName = { 1, 0.647058, 0, 1 },
            QuestColorDescription = { 0.75, 0.75, 0.75, 1 },
            QuestLocLong = true,
            QuestIcon = true,
            QuestLong = true,
            QuestLocDiscoveryCA = true,
            QuestLocDiscoveryCSA = true,
            QuestLocDiscoveryAlert = false,
            QuestLocObjectiveCA = true,
            QuestLocObjectiveCSA = true,
            QuestLocObjectiveAlert = false,
            QuestLocCompleteCA = true,
            QuestLocCompleteCSA = true,
            QuestLocCompleteAlert = false,
            QuestAcceptCA = true,
            QuestAcceptCSA = true,
            QuestAcceptAlert = false,
            QuestCompleteCA = true,
            QuestCompleteCSA = true,
            QuestCompleteAlert = false,
            QuestAbandonCA = true,
            QuestAbandonCSA = true,
            QuestAbandonAlert = false,
            QuestFailCA = true,
            QuestFailCSA = true,
            QuestFailAlert = false,
            QuestObjCompleteCA = false,
            QuestObjCompleteCSA = true,
            QuestObjCompleteAlert = false,
            QuestObjUpdateCA = false,
            QuestObjUpdateCSA = true,
            QuestObjUpdateAlert = false,
        },

        -- Experience
        XP =
        {
            ExperienceEnlightenedCA = false,
            ExperienceEnlightenedCSA = true,
            ExperienceEnlightenedAlert = false,
            ExperienceLevelUpCA = true,
            ExperienceLevelUpCSA = true,
            ExperienceLevelUpAlert = false,
            ExperienceLevelUpCSAExpand = true,
            ExperienceLevelUpIcon = true,
            ExperienceLevelColorByLevel = true,
            ExperienceLevelUpColor = { 0.75, 0.75, 0.75, 1 },
            Experience = true,
            ExperienceIcon = true,
            ExperienceMessage = GetString(LUIE_STRING_CA_EXPERIENCE_MESSAGE),
            ExperienceName = GetString(LUIE_STRING_CA_EXPERIENCE_NAME),
            ExperienceHideCombat = false,
            ExperienceFilter = 0,
            ExperienceThrottle = 3500,
            ExperienceColorMessage = { 0.75, 0.75, 0.75, 1 },
            ExperienceColorName = { 0.75, 0.75, 0.75, 1 },
        },

        -- Skills
        Skills =
        {
            SkillPointCA = true,
            SkillPointCSA = true,
            SkillPointAlert = false,
            SkillPointSkyshard = GetString(SI_SKYSHARD_GAINED),
            SkillPointBracket = 4,
            SkillPointsPartial = true,
            SkillPointColor1 = { 0.75, 0.75, 0.75, 1 },
            SkillPointColor2 = { 0.75, 0.75, 0.75, 1 },

            SkillLineUnlockCA = true,
            SkillLineUnlockCSA = true,
            SkillLineUnlockAlert = false,
            SkillLineCA = false,
            SkillLineCSA = true,
            SkillLineAlert = false,
            SkillAbilityCA = false,
            SkillAbilityCSA = true,
            SkillAbilityAlert = false,
            SkillLineIcon = true,
            SkillLineColor = { 0.75, 0.75, 0.75, 1 },

            SkillGuildFighters = true,
            SkillGuildMages = true,
            SkillGuildUndaunted = true,
            SkillGuildThieves = true,
            SkillGuildDarkBrotherhood = true,
            SkillGuildPsijicOrder = true,
            SkillGuildIcon = true,
            SkillGuildMsg = GetString(LUIE_STRING_CA_SKILL_GUILD_MSG),
            SkillGuildRepName = GetString(LUIE_STRING_CA_SKILL_GUILD_REPUTATION),
            SkillGuildColor = { 0.75, 0.75, 0.75, 1 },
            SkillGuildColorFG = { 0.75, 0.37, 0, 1 },
            SkillGuildColorMG = { 0, 0.52, 0.75, 1 },
            SkillGuildColorUD = { 0.58, 0.75, 0, 1 },
            SkillGuildColorTG = { 0.29, 0.27, 0.42, 1 },
            SkillGuildColorDB = { 0.70, 0, 0.19, 1 },
            SkillGuildColorPO = { 0.5, 1, 1, 1 },

            SkillGuildThrottle = 0,
            SkillGuildThreshold = 0,
            SkillGuildAlert = false,
        },

        -- Currency
        Currency =
        {
            CurrencyAPColor = { 0.164706, 0.862745, 0.133333, 1 },
            CurrencyAPFilter = 0,
            CurrencyAPName = GetString(LUIE_STRING_CA_CURRENCY_ALLIANCE_POINT),
            CurrencyIcon = true,
            CurrencyAPShowChange = true,
            CurrencyAPShowTotal = false,
            CurrencyAPThrottle = 3500,
            CurrencyColor = { 0.75, 0.75, 0.75, 1 },
            CurrencyColorDown = { 0.7, 0, 0, 1 },
            CurrencyColorUp = { 0.043137, 0.380392, 0.043137, 1 },
            CurrencyContextColor = true,
            CurrencyContextMergedColor = false,
            CurrencyGoldChange = true,
            CurrencyGoldColor = { 1, 1, 0.2, 1 },
            CurrencyGoldFilter = 0,
            CurrencyGoldHideAH = false,
            CurrencyGoldHideListingAH = false,
            CurrencyGoldName = GetString(LUIE_STRING_CA_CURRENCY_GOLD),
            CurrencyGoldShowTotal = false,
            CurrencyGoldThrottle = true,
            CurrencyTVChange = true,
            CurrencyTVColor = { 0.368627, 0.643137, 1, 1 },
            CurrencyTVFilter = 0,
            CurrencyTVName = GetString(LUIE_STRING_CA_CURRENCY_TELVAR_STONE),
            CurrencyTVShowTotal = false,
            CurrencyTVThrottle = 2500,
            CurrencyWVChange = true,
            CurrencyWVColor = { 1, 1, 1, 1 },
            CurrencyWVName = GetString(LUIE_STRING_CA_CURRENCY_WRIT_VOUCHER),
            CurrencyWVShowTotal = false,
            CurrencyTransmuteChange = true,
            CurrencyTransmuteColor = { 1, 1, 1, 1 },
            CurrencyTransmuteName = GetString(LUIE_STRING_CA_CURRENCY_TRANSMUTE_CRYSTAL),
            CurrencyTransmuteShowTotal = false,
            CurrencyEventChange = true,
            CurrencyEventColor = { 250 / 255, 173 / 255, 187 / 255, 1 },
            CurrencyEventName = GetString(LUIE_STRING_CA_CURRENCY_EVENT_TICKET),
            CurrencyEventShowTotal = false,
            CurrencyCrownsChange = false,
            CurrencyCrownsColor = { 1, 1, 1, 1 },
            CurrencyCrownsName = GetString(LUIE_STRING_CA_CURRENCY_CROWN),
            CurrencyCrownsShowTotal = false,
            CurrencyCrownGemsChange = false,
            CurrencyCrownGemsColor = { 244 / 255, 56 / 255, 247 / 255, 1 },
            CurrencyCrownGemsName = GetString(LUIE_STRING_CA_CURRENCY_CROWN_GEM),
            CurrencyCrownGemsShowTotal = false,
            CurrencyEndeavorsChange = true,
            CurrencyEndeavorsColor = { 1, 1, 1, 1 },
            CurrencyEndeavorsName = GetString(LUIE_STRING_CA_CURRENCY_ENDEAVOR),
            CurrencyEndeavorsShowTotal = false,
            CurrencyOutfitTokenChange = true,
            CurrencyOutfitTokenColor = { 255 / 255, 225 / 255, 125 / 255, 1 },
            CurrencyOutfitTokenName = GetString(LUIE_STRING_CA_CURRENCY_OUTFIT_TOKENS),
            CurrencyOutfitTokenShowTotal = false,
            CurrencyUndauntedChange = true,
            CurrencyUndauntedColor = { 1, 1, 1, 1 },
            CurrencyUndauntedName = GetString(LUIE_STRING_CA_CURRENCY_UNDAUNTED),
            CurrencyUndauntedShowTotal = false,
            CurrencyEndlessChange = true,
            CurrencyEndlessColor = { 1, 1, 1, 1 },
            CurrencyEndlessName = GetString(LUIE_STRING_CA_CURRENCY_ENDLESS),
            CurrencyEndlessTotal = false,
            CurrencyMessageTotalAP = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALAP),
            CurrencyMessageTotalGold = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALGOLD),
            CurrencyMessageTotalTV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTV),
            CurrencyMessageTotalWV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALWV),
            CurrencyMessageTotalTransmute = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTRANSMUTE),
            CurrencyMessageTotalEvent = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALEVENT),
            CurrencyMessageTotalCrowns = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALCROWNS),
            CurrencyMessageTotalCrownGems = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALGEMS),
            CurrencyMessageTotalEndeavors = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALENDEAVORS),
            CurrencyMessageTotalOutfitToken = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALOUTFITTOKENS),
            CurrencyMessageTotalUndaunted = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALUNDAUNTED),
            CurrencyMessageTotalEndless = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALENDLESS),
        },

        -- Loot
        Inventory =
        {
            Loot = true,
            LootLogOverride = false,
            LootIgnoreFiltering = false,
            LootBank = true,
            LootBlacklist = false,
            LootTotal = false,
            LootTotalString = GetString(LUIE_STRING_CA_LOOT_MESSAGE_TOTAL),
            LootCraft = true,
            LootGroup = true,
            LootIcons = true,
            LootMail = true,
            LootNotTrash = true,
            LootOnlyNotable = false,
            LootShowArmorType = false,
            LootShowStyle = false,
            LootShowTrait = false,
            LootConfiscate = true,
            LootTrade = true,
            LootVendor = true,
            LootVendorCurrency = true,
            LootVendorTotalCurrency = false,
            LootVendorTotalItems = false,
            LootShowCraftUse = false,
            LootShowDestroy = true,
            LootShowRemove = true,
            LootShowTurnIn = true,
            LootShowList = true,
            LootShowUsePotion = false,
            LootShowUseFood = false,
            LootShowUseDrink = false,
            LootShowUseRepairKit = true,
            LootShowUseSoulGem = false,
            LootShowUseSiege = true,
            LootShowUseFish = true,
            LootShowUseMisc = false,
            LootShowContainer = true,
            LootShowDisguise = true,
            LootShowLockpick = true,
            LootShowRecipe = true,
            LootShowMotif = true,
            LootShowStylePage = true,
            LootRecipeHideAlert = true,
            LootQuestAdd = true,
            LootQuestRemove = false,
        },

        ContextMessages =
        {
            CurrencyMessageConfiscate = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_CONFISCATE),
            CurrencyMessageDeposit = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSIT),
            CurrencyMessageDepositStorage = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSITSTORAGE),
            CurrencyMessageDepositGuild = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSITGUILD),
            CurrencyMessageEarn = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_EARN),
            CurrencyMessageLoot = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LOOT),
            CurrencyMessageContainer = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_CONTAINER),
            CurrencyMessageSteal = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_STEAL),
            CurrencyMessageLost = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LOST),
            CurrencyMessagePickpocket = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_PICKPOCKET),
            CurrencyMessageReceive = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_RECEIVE),
            CurrencyMessageSpend = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_SPEND),
            CurrencyMessagePay = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_PAY),
            CurrencyMessageUseKit = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_USEKIT),
            CurrencyMessagePotion = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_POTION),
            CurrencyMessageFood = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_EAT),
            CurrencyMessageDrink = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DRINK),
            CurrencyMessageDeploy = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DEPLOY),
            CurrencyMessageStow = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_STOW),
            CurrencyMessageFillet = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_FILLET),
            CurrencyMessageLearnRecipe = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LEARN_RECIPE),
            CurrencyMessageLearnMotif = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LEARN_MOTIF),
            CurrencyMessageLearnStyle = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LEARN_STYLE),
            CurrencyMessageExcavate = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_EXCAVATE),
            CurrencyMessageTradeIn = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TRADEIN),
            CurrencyMessageTradeInNoName = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TRADEIN_NO_NAME),
            CurrencyMessageTradeOut = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TRADEOUT),
            CurrencyMessageTradeOutNoName = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TRADEOUT_NO_NAME),
            CurrencyMessageMailIn = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_MAILIN),
            CurrencyMessageMailInNoName = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_MAILIN_NO_NAME),
            CurrencyMessageMailOut = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_MAILOUT),
            CurrencyMessageMailOutNoName = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_MAILOUT_NO_NAME),
            CurrencyMessageMailCOD = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_MAILCOD),
            CurrencyMessagePostage = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_POSTAGE),
            CurrencyMessageWithdraw = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAW),
            CurrencyMessageWithdrawStorage = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAWSTORAGE),
            CurrencyMessageWithdrawGuild = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAWGUILD),
            CurrencyMessageStable = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_STABLE),
            CurrencyMessageStorage = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_STORAGE),
            CurrencyMessageWayshrine = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_WAYSHRINE),
            CurrencyMessageUnstuck = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_UNSTUCK),
            CurrencyMessageChampion = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_CHAMPION),
            CurrencyMessageAttributes = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_ATTRIBUTES),
            CurrencyMessageSkills = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_SKILLS),
            CurrencyMessageMorphs = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_MORPHS),
            CurrencyMessageBounty = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_BOUNTY),
            CurrencyMessageTrader = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TRADER),
            CurrencyMessageRepair = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_REPAIR),
            CurrencyMessageListing = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LISTING),
            CurrencyMessageListingValue = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LISTING_VALUE),
            CurrencyMessageList = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LIST),
            CurrencyMessageCampaign = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_CAMPAIGN),
            CurrencyMessageFence = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_FENCE_VALUE),
            CurrencyMessageFenceNoV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_FENCE),
            CurrencyMessageSellNoV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_SELL),
            CurrencyMessageBuyNoV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_BUY),
            CurrencyMessageBuybackNoV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_BUYBACK),
            CurrencyMessageSell = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_SELL_VALUE),
            CurrencyMessageBuy = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_BUY_VALUE),
            CurrencyMessageBuyback = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_BUYBACK_VALUE),
            CurrencyMessageLaunder = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LAUNDER_VALUE),
            CurrencyMessageLaunderNoV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LAUNDER),
            CurrencyMessageUse = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_USE),
            CurrencyMessageCraft = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_CRAFT),
            CurrencyMessageExtract = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_EXTRACT),
            CurrencyMessageUpgrade = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_UPGRADE),
            CurrencyMessageUpgradeFail = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_UPGRADE_FAIL),
            CurrencyMessageRefine = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_REFINE),
            CurrencyMessageDeconstruct = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DECONSTRUCT),
            CurrencyMessageResearch = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_RESEARCH),
            CurrencyMessageDestroy = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DESTROY),
            CurrencyMessageLockpick = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_LOCKPICK),
            CurrencyMessageRemove = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_REMOVE),
            CurrencyMessageQuestTurnIn = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TURNIN),
            CurrencyMessageQuestUse = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTUSE),
            CurrencyMessageQuestExhaust = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_EXHAUST),
            CurrencyMessageQuestOffer = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_OFFER),
            CurrencyMessageQuestDiscard = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DISCARD),
            CurrencyMessageQuestConfiscate = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTCONFISCATE),
            CurrencyMessageQuestOpen = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTOPEN),
            CurrencyMessageQuestAdminister = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTADMINISTER),
            CurrencyMessageQuestPlace = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTPLACE),
            CurrencyMessageQuestCombine = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_COMBINE),
            CurrencyMessageQuestMix = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_MIX),
            CurrencyMessageQuestBundle = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_BUNDLE),
            CurrencyMessageGroup = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_GROUP),
            CurrencyMessageDisguiseEquip = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DISGUISE_EQUIP),
            CurrencyMessageDisguiseRemove = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DISGUISE_REMOVE),
            CurrencyMessageDisguiseDestroy = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DISGUISE_DESTROY),
        },

        DisplayAnnouncements =
        {
            Debug = false, -- Display EVENT_DISPLAY_ANNOUNCEMENT debug messages
            General =
            {
                CA = false,
                CSA = true,
                Alert = false,
            },
            GroupArea =
            {
                CA = false,
                CSA = true,
                Alert = false,
            },
            Respec =
            {
                CA = true,
                CSA = true,
                Alert = false,
            },
            ZoneIC =
            {
                CA = true,
                CSA = true,
                Alert = false,
                Description = true, -- For 2nd line of Display Announcements
            },
            ZoneCraglorn =
            {
                CA = false,
                CSA = true,
                Alert = false,
            },
            ArenaMaelstrom =
            {
                CA = true,
                CSA = true,
                Alert = false,
            },
            ArenaDragonstar =
            {
                CA = true,
                CSA = true,
                Alert = false,
            },
            DungeonEndlessArchive =
            {
                CA = true,
                CSA = true,
                Alert = false,
            },
        },
    },
}

------------------------------------------------

local ColorizeColors = {}

------------------------------------------------
-- LOCAL (GLOBAL) VARIABLE SETUP ---------------
------------------------------------------------

local isWritCreatorEnabled = false

-- Basic
local g_activatedFirstLoad = true

-- Loot/Currency
local g_savedPurchase = {}
local g_savedLaunder = {}
local g_savedItem = {}
local g_isLooted = false                   -- Toggled on to modify loot notification to "looted."
local g_isPickpocketed = false             -- Toggled on to modify loot notification to "pickpocketed."
local g_isStolen = false                   -- Toggled on to modify loot notification to "stolen."
local g_containerRecentlyOpened = false    -- Toggled on when a container has been recently opened.
local g_itemReceivedIsQuestReward = false  -- Toggled on to modify loot notification to "received." This overrides the "looted" tag applied to quest item rewards.
local g_itemReceivedIsQuestAbandon = false -- Toggled on to modify remove notification to "removed" when a quest is abandoned.
local g_itemsConfiscated = false           -- Toggled on when items are confiscated to modify the notification message.
local g_weAreInAStore = false              -- Toggled on when the player opens a store.
local g_weAreInAFence = false              -- Toggled on when the player opens a fence.
local g_weAreInAGuildStore = false         -- Toggled on when the player opens a guild store.
local g_itemWasDestroyed = false           -- Tracker for item being destroyed
local g_packSiege = false                  -- Tracker for siege packed
local g_lockpickBroken = false             -- Tracker for lockpick being broken
local g_groupLootIndex = {}                -- Table to hold group member names for group loot display.
local g_stackSplit = false                 -- Determines if we just split an inventory item stack
local g_combinedRecipe = false             -- Determines if we just used an item that combines a recipe to stop the "learned" message from showing.
local g_InventoryOn = false                -- Determines if Inventory Updates for Item Changes are on
local g_bankOn = false                     -- Determines if Bank Updates for Item Changes are on

-- Currency Throttle
local g_currencyGoldThrottleValue = 0 -- Held value for gold throttle (counter)
local g_currencyGoldThrottleTotal = 0 -- Held value for gold throttle (total gold)
local g_currencyAPThrottleValue = 0   -- Held value for AP throttle (counter)
local g_currencyAPThrottleTotal = 0   -- Held value for AP throttle (total gold)
local g_currencyTVThrottleValue = 0   -- Held value for TV throttle (counter)
local g_currencyTVThrottleTotal = 0   -- Held value for TV throttle (total gold)

-- Loot (Crafting)
local g_smithing = {}   -- Table for smithing mode
local g_enchanting = {} -- Table for enchanting mode
local g_enchant_prefix_pos = {}
local g_enchant_prefix_neg = {}
local g_smithing_prefix_pos = {}
local g_smithing_prefix_neg = {}
local g_itemCounterGain = 0        -- Counter value for items created via crafting
local g_itemCounterGainTracker = 0 -- Tracker for how many items have been counted, when we reach a certain threshold, it is too many items to display so we cut the string off.
local g_itemStringGain = ""        -- Counter value for items created via crafting
local g_itemCounterLoss = 0        -- Counter value for items removed via crafting
local g_itemCounterLossTracker = 0 -- Tracker for how many items have been counted, when we reach a certain threshold, it is too many items to display so we cut the string off.
local g_itemStringLoss = ""        -- Combined string variable for items removed via crafting
local g_oldItem = {}               -- Saved old item for crafting upgrades

-- Mail
local g_mailCOD = 0            -- Tracks COD amount
local g_postageAmount = 0      -- Tracks Postage amount
local g_mailAmount = 0         -- Tracks sent money amount
local g_mailCODPresent = false -- Tracks whether the currently opened mail has a COD value present. On receiving items from the mail this will modify the message displayed.
local g_inMail = false         -- Toggled on when looting mail to prevent notable item display from hiding items acquired.
local g_mailTarget = ""        -- Target of mail being sent.
local g_mailStacksOut = {}     -- Table for storing items to be mailed out.

-- Disguise
local g_currentDisguise = nil -- Holds current disguise itemId
local g_disguiseState = nil   -- Holds current disguise state

-- Indexing
local g_bankBag
local g_bankStacks = {}           -- Bank Inventory Index
local g_bankSubscriberStacks = {} -- Subscriber Bank Inventory Index
local g_houseBags = {}            -- House Storage Index
local g_equippedStacks = {}       -- Equipped Items Index
local g_inventoryStacks = {}      -- Inventory Index
local g_JusticeStacks = {}        -- Justice Items Index (only filled as a comparison table when items are confiscated)
local g_guildBankCarry = nil      -- Saves item data when an item is removed/deposited into the guild bank.

-- Group
local g_currentGroupLeaderRawName = nil     -- Tracks current Group Leader Name
local g_currentGroupLeaderDisplayName = nil -- Tracks current Group Leader Display Name

-- LFG
local g_currentActivityId = nil       -- current activity ID for LFG.
local g_stopGroupLeaveQueue = false   -- Stops group notification messages from printing for a short time an LFG group is formed - Called when a ready check has the possible result of success.
local g_lfgDisableGroupEvents = false -- Stops group notification messages from printing for a short time an LFG group is formed - Called when successfully joining a new LFG activity.
local g_joinLFGOverride = false       -- Toggled on to stop display of standard group join message when joining an LFG group. Instead an alternate message with the LFG activity name will display.
local g_leaveLFGOverride = false      -- Toggled on to modify group leave message to display "You are no longer in an LFG group."
local g_showActivityStatus = true     -- Variable to control display of LFG status
local g_lfgHideStatusCancel = false   -- Hide the cancel message that can be triggered by someone dropping queue while in an existing group.
local g_showRCUpdates = true          -- Variable to control display of LFG Ready Check Announcements
local g_weDeclinedTheQueue = false    -- Flagged when we decline a ready check popup for LFG queue.
local g_savedQueueValue = 0           -- Saved LFG queue status
local g_rcSpamPrevention = false      -- Stops LFG failed ready checks from spamming the player

-- Guild
local g_selectedGuild = 1          -- Set selected guild to 1 by default, whenever the player reloads their first guild will always be selected
-- local g_pendingHeraldryCost         = 0             -- Pending cost of heraldry change used to modify currency messages. TODO: Fix later
local g_disableRankMessage = false -- Variable is toggled to true when the player modifies a guild member's rank, this prevents the normal rank change message from displaying.

-- Achievements
local g_achievementLastPercentage = {} -- Here we will store last displayed percentage for achievement

-- Collectible Usage Tracking
local currentAssistant = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentCompanion = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COMPANION, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentVanity = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentSpecial = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ABILITY_FX_OVERRIDE, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentHat = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentHair = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HAIR, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentHeadMark = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentFacialHair = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentMajorAdorn = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentMinorAdorn = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PIERCING_JEWELRY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentCostume = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentBodyMarking = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentSkin = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentPersonality = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_PERSONALITY, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local currentPolymorph = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_POLYMORPH, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
local lastCollectibleUsed = 0

-- Quest
local g_stopDisplaySpam = false   -- Toggled on to stop spam display of EVENT_DISPLAY_ANNOUNCEMENTS from IC zone transitions.
local g_questIndex = {}           -- Index of all current quests. Allows us to read the index so that all quest notifications can use the difficulty icon.
local g_questItemAdded = {}       -- Hold index of Quest items that are added - Prevents pointless and annoying messages from appearing when the same quest item is immediately added and removed when quest updates.
local g_questItemRemoved = {}     -- Hold index of Quest items that are removed - Prevents pointless and annoying messages from appearing when the same quest item is immediately added and removed when quest updates.
local g_loginHideQuestLoot = true -- Set to true onPlayerActivated and toggled after 3 sec
local g_talkingToNPC = false      -- Toggled when we're in dialogue with an NPC (EVENT_CHATTER_BEGIN & EVENT_CHATTER_END)

-- Trade
local g_tradeTarget = ""    -- Saves name of target player being traded with.
local g_tradeStacksIn = {}  -- Table for storing items to be traded in.
local g_tradeStacksOut = {} -- Table for storing items to be traded out.
local g_inTrade = false     -- Toggled on when in a trade.

-- Antiquities
local g_weAreInADig = false -- When in a digsite.

-- Experience
local g_xpCombatBufferValue = 0      -- Buffered XP Value
local g_guildSkillThrottle = 0       -- Buffered Fighter's Guild Reputation Value
local g_guildSkillThrottleLine = nil -- Grab the name for Fighter's Guild reputation (since index isn't always the same) to pass over to Buffered Printer Function

------------------------------------------------
-- BRACKET OPTIONS -----------------------------
------------------------------------------------

-- 5 Option Bracket (1)
local bracket1 =
{
    [1] = "[",
    [2] = "(",
    [3] = "",
    [4] = "",
    [5] = "",
}

-- 5 Option Bracket (2)
local bracket2 =
{
    [1] = "]",
    [2] = ")",
    [3] = " -",
    [4] = ":",
    [5] = "",
}

-- 4 Option Bracket (1)
local bracket3 =
{
    [1] = "[",
    [2] = "(",
    [3] = "- ",
    [4] = "",
}

-- 4 Option Bracket (2)
local bracket4 =
{
    [1] = "]",
    [2] = ")",
    [3] = "",
    [4] = "",
}

------------------------------------------------
-- LINK BRACKET OPTIONS ------------------------
------------------------------------------------

local linkBrackets =
{
    [1] = LINK_STYLE_DEFAULT,
    [2] = LINK_STYLE_BRACKETS,
}

local linkBracket1 =
{
    [1] = "",
    [2] = "[",
}

local linkBracket2 =
{
    [1] = "",
    [2] = "]",
}

------------------------------------------------
-- ITEM BLACKLIST ------------------------------
------------------------------------------------

-- List of items to whitelist as notable loot
local g_notableIDs =
{
    [56862] = true, -- Fortified Nirncrux
    [56863] = true, -- Potent Nirncrux
    [68342] = true, -- Hakeijo
}

-- List of items that can be removed from the players equipped item slots.
local g_removableIDs =
{
    [44486] = true, -- Prismatic Blade (Fighters Guild Quests)
    [44487] = true, -- Prismatic Greatblade (Fighters Guild Quests)
    [44488] = true, -- Prismatic Long Bow (Fighters Guild Quests)
    [44489] = true, -- Prismatic Flamestaff (Fighters Guild Quests)
    [33235] = true, -- Wabbajack (Mages Guild Quests)
}

-- List of items to blacklist as annoying loot
local g_blacklistIDs =
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



local g_firstLoad = true

local ChatEventFormattersDelete =
{
    [EVENT_FRIEND_PLAYER_STATUS_CHANGED] = true,
    [EVENT_GROUP_INVITE_RESPONSE] = true,
    [EVENT_GROUP_MEMBER_LEFT] = true,
    [EVENT_GROUP_TYPE_CHANGED] = true,
    [EVENT_IGNORE_ADDED] = true,
    [EVENT_IGNORE_REMOVED] = true,
    [EVENT_SOCIAL_ERROR] = true,
}

function ChatAnnouncements.SlayChatHandlers()
    -- Unregister ZOS handlers for events we need to modify
    for eventCode, _ in pairs(ChatEventFormattersDelete) do
        eventManager:UnregisterForEvent("ChatRouter", eventCode)
    end

    -- Slay these events in case LibChatMessage is active and hooks them
    local ChatEventFormatters = CHAT_ROUTER:GetRegisteredMessageFormatters()
    for eventType, _ in pairs(ChatEventFormattersDelete) do
        ChatEventFormatters[eventType] = function (...)
        end
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

    isWritCreatorEnabled = LUIE.IsItEnabled("DolgubonsLazyWritCreator")

    -- Get current group leader
    g_currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
    g_currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
    g_currentActivityId = GetCurrentLFGActivityId()

    -- PostHook Crafting Interface (Keyboard)
    ChatAnnouncements.CraftModeOverrides()

    -- Register events
    ChatAnnouncements.RegisterGoldEvents()
    ChatAnnouncements.RegisterLootEvents()
    ChatAnnouncements.RegisterMailEvents()
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
    LUIE_CallLater(ChatAnnouncements.SlayChatHandlers, 100)
    LUIE_CallLater(ChatAnnouncements.SlayChatHandlers, 5000)
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
    ColorizeColors.CurrencyEventColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyEventColor))
    ColorizeColors.CurrencyCrownsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyCrownsColor))
    ColorizeColors.CurrencyCrownGemsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyCrownGemsColor))
    ColorizeColors.CurrencyEndeavorsColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyEndeavorsColor))
    ColorizeColors.CurrencyEndlessColorize = ZO_ColorDef:New(unpack(SV.Currency.CurrencyEndlessColor))
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

            g_questIndex[name] =
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

function ChatAnnouncements.RegisterXPEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_EXPERIENCE_GAIN)
    if ChatAnnouncements.SV.XP.Experience or ChatAnnouncements.SV.XP.ExperienceLevelUp then
        eventManager:RegisterForEvent(moduleName, EVENT_EXPERIENCE_GAIN, ChatAnnouncements.OnExperienceGain)
    end
end

function ChatAnnouncements.RegisterGoldEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_CURRENCY_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_ADDED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_REMOVED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_CLOSE_MAILBOX)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_SEND_SUCCESS)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_COD_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_REMOVED)

    eventManager:RegisterForEvent(moduleName, EVENT_CURRENCY_UPDATE, ChatAnnouncements.OnCurrencyUpdate)
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
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_ADDED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_REMOVED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_OPEN_MAILBOX)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_CLOSE_MAILBOX)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_SEND_SUCCESS)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_COD_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_MAIL_REMOVED)
    if ChatAnnouncements.SV.MiscMail or ChatAnnouncements.SV.Inventory.LootMail then
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_READABLE, ChatAnnouncements.OnMailReadable)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_TAKE_ATTACHED_ITEM_SUCCESS, ChatAnnouncements.OnMailTakeAttachedItem)
    end
    if ChatAnnouncements.SV.MiscMail or ChatAnnouncements.SV.Inventory.LootMail or ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_ADDED, ChatAnnouncements.OnMailAttach)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHMENT_REMOVED, ChatAnnouncements.OnMailAttachRemove)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_SEND_SUCCESS, ChatAnnouncements.OnMailSuccess)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_ATTACHED_MONEY_CHANGED, ChatAnnouncements.MailMoneyChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_COD_CHANGED, ChatAnnouncements.MailCODChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_MAIL_REMOVED, ChatAnnouncements.MailRemoved)
    end
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.MiscMail or ChatAnnouncements.SV.Inventory.LootMail or ChatAnnouncements.SV.Currency.CurrencyGoldChange then
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
    -- CRAFT
    eventManager:UnregisterForEvent(moduleName, EVENT_CRAFTING_STATION_INTERACT, ChatAnnouncements.CraftingOpen)
    eventManager:UnregisterForEvent(moduleName, EVENT_END_CRAFTING_STATION_INTERACT, ChatAnnouncements.CraftingClose)
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
        g_equippedStacks = {}
        g_inventoryStacks = {}
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

    --[[if ChatAnnouncements.SV.ShowLootFail then
        eventManager:RegisterForEvent(moduleName, EVENT_QUEST_COMPLETE_ATTEMPT_FAILED_INVENTORY_FULL, ChatAnnouncements.InventoryFullQuest)
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_IS_FULL, ChatAnnouncements.InventoryFull)
        eventManager:RegisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED, ChatAnnouncements.LootItemFailed)
    end]]
end

function ChatAnnouncements.RegisterDisguiseEvents()
    eventManager:UnregisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED)
    if ChatAnnouncements.SV.Notify.DisguiseCA or ChatAnnouncements.SV.Notify.DisguiseCSA or ChatAnnouncements.SV.Notify.DisguiseAlert or ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnCSA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
        eventManager:RegisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, ChatAnnouncements.DisguiseState)
        eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        g_currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0 -- Get the currently equipped disguise itemId if any
        if g_activatedFirstLoad then
            g_disguiseState = 0
            g_activatedFirstLoad = false
        else
            g_disguiseState = GetUnitDisguiseState("player") -- Get current player disguise state
            if g_disguiseState > 0 then
                g_disguiseState = 1                          -- Simplify all the various states into a basic 0 = false, 1 = true value
            end
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

-- Called by most functions that use character or display name to resolve LINK display method.
--
--- @param characterName string The character name
--- @param displayName string The display name
--- @return string nameLink The resolved name link
function ChatAnnouncements.ResolveNameLink(characterName, displayName)
    local function resolve(nameLink)
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 1 then
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
            else
                nameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
            end
        elseif ChatAnnouncements.SV.ChatPlayerDisplayOptions == 2 then
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(characterName, nil, CHARACTER_LINK_TYPE, characterName)
            else
                nameLink = ZO_LinkHandler_CreateLink(characterName, nil, CHARACTER_LINK_TYPE, characterName)
            end
        elseif ChatAnnouncements.SV.ChatPlayerDisplayOptions == 3 then
            local displayBothString = zo_strformat("<<1>><<2>>", characterName, displayName)
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayBothString, nil, DISPLAY_NAME_LINK_TYPE, displayName)
            else
                nameLink = ZO_LinkHandler_CreateLink(displayBothString, nil, DISPLAY_NAME_LINK_TYPE, displayName)
            end
        end
        return nameLink
    end
    local nameLink = resolve("")
    return nameLink
end

-- Called by most functions that use character or display name to resolve NON-LINK display method (mostly used for alerts).
function ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
    local function resolve(nameLink)
        if ChatAnnouncements.SV.ChatPlayerDisplayOptions == 1 then
            nameLink = displayName
        elseif ChatAnnouncements.SV.ChatPlayerDisplayOptions == 2 then
            nameLink = characterName
        elseif ChatAnnouncements.SV.ChatPlayerDisplayOptions == 3 then
            nameLink = zo_strformat("<<1>><<2>>", characterName, displayName)
        end
        return nameLink
    end
    local nameLink = resolve("")
    return nameLink
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
    g_weAreInADig = true
end

function ChatAnnouncements.OnDigEnd()
    LUIE_CallLater(function ()
        g_weAreInADig = false
    end, 1000)
end

-- TODO: Fix later
--[[
function ChatAnnouncements.GuildHeraldrySaved()
    if ChatAnnouncements.SV.Currency.CurrencyGoldChange then
        local value = g_pendingHeraldryCost > 0 and g_pendingHeraldryCost or 1000
        local messageType = "LUIE_CURRENCY_HERALDRY"
        local formattedValue = nil -- Un-needed, we're not going to try to show the total guild bank gold here.
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(value)
        local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_MONEY), 16,16) or ""
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, value)
        local currencyTotal = nil
        local messageTotal = ""
        local messageChange = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_HERALDRY)
        ChatAnnouncements.CurrencyPrinter(formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
    end

    if g_selectedGuild ~= nil then
        local id = g_selectedGuild
        local guildName = GetGuildName(id)

        local guildAlliance = GetGuildAlliance(id)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
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

-- Copied from Writ Creator for CSA handling purposes - Only called when WritCreater is detected so shouldn't cause issues
local function isQuestWritQuest(questId)
    local writs = WritCreater.writSearch()
    for k, v in pairs(writs) do
        if v == questId then
            return true
        end
    end
end

-- Copied from Writ Creator for CSA handling purposes - Only called when WritCreater is detected so shouldn't cause issues
local function rejectQuest(questIndex)
    for itemLink, _ in pairs(WritCreater:GetSettings().skipItemQuests) do
        if not WritCreater:GetSettings().skipItemQuests[itemLink] then
            for i = 1, GetJournalQuestNumConditions(questIndex, QUEST_MAIN_STEP_INDEX) do
                if DoesItemLinkFulfillJournalQuestCondition(itemLink, questIndex, 1, i, true) then
                    return itemLink
                end
            end
        end
    end
    return false
end

function ChatAnnouncements.GuildRanksSaved(eventCode, guildId)
    local guildName = GetGuildName(guildId)
    local guildAlliance = GetGuildAlliance(guildId)
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

    if ChatAnnouncements.SV.Social.GuildManageCA then
        local finalMessage = zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANKS_UPDATE), guildNameAlliance)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "NOTIFICATION", isSystem = true }
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
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
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
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    -- Depending on event code set message context.
    local messageString = eventCode == EVENT_GUILD_DESCRIPTION_CHANGED and LUIE_STRING_CA_GUILD_DESCRIPTION_CHANGED or EVENT_GUILD_MOTD_CHANGED and LUIE_STRING_CA_GUILD_MOTD_CHANGED or nil

    if messageString ~= nil then
        if ChatAnnouncements.SV.Social.GuildManageCA then
            local finalMessage = zo_strformat(GetString(messageString), guildNameAlliance)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "NOTIFICATION", isSystem = true }
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
    if g_disableRankMessage == true then
        g_disableRankMessage = false
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
            local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
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

function ChatAnnouncements.GuildMemberPromoteSuccessful(eventId, displayName, newRankIndex, guildId)
    if newRankIndex > 0 then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        end
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
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_PROMOTE), displayNameLink, rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_PROMOTE), displayName, rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
    g_disableRankMessage = true
end

function ChatAnnouncements.GuildMemberDemoteSuccessful(eventId, displayName, newRankIndex, guildId)
    if newRankIndex <= GetNumGuildRanks(guildId) then
        local displayNameLink
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        else
            displayNameLink = ZO_LinkHandler_CreateLink(displayName, nil, DISPLAY_NAME_LINK_TYPE, displayName)
        end
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
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_DEMOTE), displayNameLink, rankSyntax, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildRankAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_RANK_CHANGED_DEMOTE), displayName, rankSyntaxAlert, guildNameAllianceAlert))
        end
    end
    g_disableRankMessage = true
end

-- EVENT_GUILD_SELF_JOINED_GUILD
function ChatAnnouncements.GuildAddedSelf(eventCode, guildId, guildName)
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
                printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_JOIN_SELF), guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_JOIN_SELF), guildNameAllianceAlert))
            end
            break
        end
    end
end

-- EVENT_GUILD_INVITE_ADDED
function ChatAnnouncements.GuildInviteAdded(eventCode, guildId, guildName, guildAlliance, inviterName)
    local displayNameLink
    if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
        displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(inviterName, nil, DISPLAY_NAME_LINK_TYPE, inviterName)
    else
        displayNameLink = ZO_LinkHandler_CreateLink(inviterName, nil, DISPLAY_NAME_LINK_TYPE, inviterName)
    end
    local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
    local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName
    if ChatAnnouncements.SV.Social.GuildCA then
        printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), displayNameLink, guildNameAlliance), true)
    end
    if ChatAnnouncements.SV.Social.GuildAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), inviterName, guildNameAllianceAlert))
    end
end

function ChatAnnouncements.FriendAdded(eventCode, displayName)
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

function ChatAnnouncements.FriendRemoved(eventCode, displayName)
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

function ChatAnnouncements.FriendInviteAdded(eventCode, displayName)
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

function ChatAnnouncements.IgnoreAdded(eventCode, displayName)
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

function ChatAnnouncements.IgnoreRemoved(eventCode, displayName)
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

function ChatAnnouncements.FriendPlayerStatus(eventCode, displayName, characterName, oldStatus, newStatus)
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

function ChatAnnouncements.QuestShared(eventCode, questId)
    if ChatAnnouncements.SV.Quests.QuestShareCA or ChatAnnouncements.SV.Quests.QuestShareAlert then
        local questName, characterName, timeSinceRequestMs, displayName = GetOfferedQuestShareInfo(questId)

        local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)

        local message = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE), finalName, ColorizeColors.QuestColorQuestNameColorize:Colorize(questName))
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
function ChatAnnouncements.OnChatterBegin()
    g_talkingToNPC = true
end

-- EVENT_CHATTER_END
function ChatAnnouncements.OnChatterEnd()
    g_talkingToNPC = false
end

-- EVENT_GROUPING_TOOLS_LFG_JOINED
function ChatAnnouncements.GroupingToolsLFGJoined(eventCode, locationName)
    -- Update the current activity id with the one we are in now.
    g_currentActivityId = GetCurrentLFGActivityId()
    -- Get the name of the current activityId that is generated on initialization.
    local currentActivityName = GetActivityName(g_currentActivityId)
    -- If the locationName is different thant the saved currentActivityName we have entered a new LFG instance, so display this message.
    if locationName ~= currentActivityName then
        if ChatAnnouncements.SV.Group.GroupLFGCA then
            printToChat(zo_strformat(LUIE_STRING_CA_GROUPFINDER_ALERT_LFG_JOINED, locationName), true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUPFINDER_ALERT_LFG_JOINED, locationName))
        end
        g_lfgDisableGroupEvents = true
        LUIE_CallLater(function ()
            g_lfgDisableGroupEvents = false
        end, 3000)
    end
    g_joinLFGOverride = true
end

-- EVENT_ACTIVITY_FINDER_STATUS_UPDATE
function ChatAnnouncements.ActivityStatusUpdate(eventCode, status)
    -- d("status: " .. status)
    local message
    if g_showActivityStatus then
        if not g_weDeclinedTheQueue then
            -- If we are NOT queued and were formerly queued, forming group, or in a ready check, display left queue message.
            if status == ACTIVITY_FINDER_STATUS_NONE and (g_savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED or g_savedQueueValue == ACTIVITY_FINDER_STATUS_READY_CHECK) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_END))
            end
            -- If we are queued and previously we were not queued then display a message.
            if status == ACTIVITY_FINDER_STATUS_QUEUED and (g_savedQueueValue == ACTIVITY_FINDER_STATUS_NONE or g_savedQueueValue == ACTIVITY_FINDER_STATUS_IN_PROGRESS) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_START))
            end
            -- If we were in the queue and are now in progress without a ready check triggered, we left the queue to find a replacement member so this should be displayed.
            if status == ACTIVITY_FINDER_STATUS_IN_PROGRESS and (g_savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED) then
                message = (GetString(LUIE_STRING_CA_GROUPFINDER_QUEUE_END))
            end
        end
    end

    -- If we queue as a group in a completed LFG activity then if someone drops the queue don't show that a group was successfully formed.
    -- This event handles everyone but the player that declined the check.
    if (status == ACTIVITY_FINDER_STATUS_COMPLETE and g_savedQueueValue == ACTIVITY_FINDER_STATUS_QUEUED) or (status == ACTIVITY_FINDER_STATUS_QUEUED and g_savedQueueValue == ACTIVITY_FINDER_STATUS_READY_CHECK) then
        -- Don't show if we already got a ready check cancel message.
        if not g_lfgHideStatusCancel then
            message = (GetString(SI_LFGREADYCHECKCANCELREASON3))
        end
        g_showRCUpdates = true
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
    if status == ACTIVITY_FINDER_STATUS_NONE then
        g_showRCUpdates = true
    end
    if status == ACTIVITY_FINDER_STATUS_READY_CHECK then
        g_showRCUpdates = false
    end

    -- Debug
    if status == ACTIVITY_FINDER_STATUS_FORMING_GROUP and g_savedQueueValue ~= ACTIVITY_FINDER_STATUS_FORMING_GROUP then
        if LUIE.IsDevDebugEnabled() then
            LUIE.Debug("Old ACTIVITY_FINDER_STATUS_FORMING_GROUP event triggered")
        end
    end

    g_savedQueueValue = status
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

function ChatAnnouncements.ReadyCheckUpdate(eventCode)
    local activityType, playerRole, timeRemainingSeconds = GetLFGReadyCheckNotificationInfo()
    local tanksAccepted, tanksPending, healersAccepted, healersPending, dpsAccepted, dpsPending = GetLFGReadyCheckCounts()

    if g_showRCUpdates then
        -- Return early if invalid activity type
        if activityType == LFG_ACTIVITY_INVALID then return end

        local activityName = GetActivityName(activityType)
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
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
        end
    end

    g_showRCUpdates = false

    -- Handle ready check completion or cancellation
    local allCountsZero = tanksAccepted == 0 and tanksPending == 0 and
        healersAccepted == 0 and healersPending == 0 and
        dpsAccepted == 0 and dpsPending == 0

    if not g_showRCUpdates and allCountsZero and not g_rcSpamPrevention then
        g_rcSpamPrevention = true

        -- Reset spam prevention after 1 second
        LUIE_CallLater(function ()
            g_rcSpamPrevention = false
        end, 1000)

        -- Reset activity status after 1 second
        g_showActivityStatus = false
        LUIE_CallLater(function ()
            g_showActivityStatus = true
        end, 1000)

        -- Reset group leave queue after 1 second
        g_stopGroupLeaveQueue = true
        LUIE_CallLater(function ()
            g_stopGroupLeaveQueue = false
        end, 1000)

        g_showRCUpdates = true
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
function ChatAnnouncements.PointRespecDisplay(respecType)
    local message = LUIE_AttributeDisplayType[respecType] .. "."
    local messageCSA = LUIE_AttributeDisplayType[respecType]

    if ChatAnnouncements.SV.DisplayAnnouncements.Respec.CA then
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "MESSAGE", isSystem = true }
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

function ChatAnnouncements.OnLootUpdated(eventCode)
    g_containerRecentlyOpened = true
    local function ResetContainerRecentlyOpened()
        g_containerRecentlyOpened = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetContainer")
    end
    eventManager:UnregisterForUpdate(moduleName .. "ResetContainer")
    eventManager:RegisterForUpdate(moduleName .. "ResetContainer", 150, ResetContainerRecentlyOpened)
end

--- @param eventCode integer
--- @param currency CurrencyType
--- @param currencyLocation CurrencyLocation
--- @param newValue integer
--- @param oldValue integer
--- @param reason CurrencyChangeReason
--- @param reasonSupplementaryInfo integer
function ChatAnnouncements.OnCurrencyUpdate(eventCode, currency, currencyLocation, newValue, oldValue, reason, reasonSupplementaryInfo)
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

    local formattedValue = ZO_CommaDelimitDecimalNumber(newValue)
    local changeColor       -- Gets the value from ColorizeColors.CurrencyUpColorize or ColorizeColors.CurrencyDownColorize to color strings
    local changeType        -- Amount of currency gained or lost
    local currencyTypeColor -- Determines color to use for colorization of currency based off currency type.
    local currencyIcon      -- Determines icon to use for currency based off currency type.
    local currencyName      -- Determines name to use for currency based off type.
    local currencyTotal     -- Determines if the total should be displayed based off type.
    local messageChange     -- Set to a string value based on the reason code.
    local messageTotal      -- Set to a string value based on the currency type.
    local messageType

    if currency == CURT_MONEY then -- Gold
        -- Send change info to the throttle printer and end function now if we throttle gold from loot.
        if not ChatAnnouncements.SV.Currency.CurrencyGoldChange then
            return
        end
        if ChatAnnouncements.SV.Currency.CurrencyGoldThrottle and (reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_KILL) then
            -- NOTE: Unlike other throttle events, we used LUIE_CallLater here because we have to make the call immediately
            -- (if some of the gold is looted after items, the message will appear after the loot if we don't use LUIE_CallLater instead of a RegisterForUpdate)
            LUIE_CallLater(ChatAnnouncements.CurrencyGoldThrottlePrinter, 50)
            g_currencyGoldThrottleValue = g_currencyGoldThrottleValue + UpOrDown
            g_currencyGoldThrottleTotal = GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)
            return
        end

        -- If looted gold is below the filter value, end now.
        if ChatAnnouncements.SV.Currency.CurrencyGoldFilter > 0 and (reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_KILL) then
            if UpOrDown < ChatAnnouncements.SV.Currency.CurrencyGoldFilter then
                return
            end
        end

        currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_MONEY), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalGold
    elseif currency == CURT_ALLIANCE_POINTS then -- Alliance Points
        if not ChatAnnouncements.SV.Currency.CurrencyAPShowChange then
            return
        end
        -- Send change info to the throttle printer and end function now if we throttle Alliance Points Gained
        if ChatAnnouncements.SV.Currency.CurrencyAPThrottle > 0 and (reason == CURRENCY_CHANGE_REASON_KILL or reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR or reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT) then
            eventManager:UnregisterForUpdate(moduleName .. "BufferedAP")
            eventManager:RegisterForUpdate(moduleName .. "BufferedAP", ChatAnnouncements.SV.Currency.CurrencyAPThrottle, ChatAnnouncements.CurrencyAPThrottlePrinter)
            g_currencyAPThrottleValue = g_currencyAPThrottleValue + UpOrDown
            g_currencyAPThrottleTotal = GetCurrencyAmount(CURT_ALLIANCE_POINTS, CURRENCY_LOCATION_CHARACTER)
            return
        end

        -- If earned AP is below the filter value, end now.
        if ChatAnnouncements.SV.Currency.CurrencyAPFilter > 0 and (reason == CURRENCY_CHANGE_REASON_KILL or reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR or reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT) then
            if UpOrDown < ChatAnnouncements.SV.Currency.CurrencyAPFilter then
                return
            end
        end

        -- Immediately print value if another source of AP is gained (or spent)
        if ChatAnnouncements.SV.Currency.CurrencyAPThrottle > 0 and (reason ~= CURRENCY_CHANGE_REASON_KILL and reason ~= CURRENCY_CHANGE_REASON_KEEP_REPAIR and reason ~= CURRENCY_CHANGE_REASON_PVP_RESURRECT) then
            ChatAnnouncements.CurrencyAPThrottlePrinter()
        end

        currencyTypeColor = ColorizeColors.CurrencyAPColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_ALLIANCE_POINTS), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyAPName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyAPShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalAP
    elseif currency == CURT_TELVAR_STONES then -- TelVar Stones
        if not ChatAnnouncements.SV.Currency.CurrencyTVChange then
            return
        end
        -- Send change info to the throttle printer and end function now if we throttle Tel Var Gained
        -- If a container was recently opened then don't throttle the currency change.
        if ChatAnnouncements.SV.Currency.CurrencyTVThrottle > 0 and (reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER) and not g_containerRecentlyOpened then
            eventManager:UnregisterForUpdate(moduleName .. "BufferedTV")
            eventManager:RegisterForUpdate(moduleName .. "BufferedTV", ChatAnnouncements.SV.Currency.CurrencyTVThrottle, ChatAnnouncements.CurrencyTVThrottlePrinter)
            g_currencyTVThrottleValue = g_currencyTVThrottleValue + UpOrDown
            g_currencyTVThrottleTotal = GetCurrencyAmount(CURT_TELVAR_STONES, CURRENCY_LOCATION_CHARACTER)
            return
        end

        -- If earned Tel Var is below the filter value, end now.
        if ChatAnnouncements.SV.Currency.CurrencyTVFilter > 0 and (reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER) then
            if UpOrDown < ChatAnnouncements.SV.Currency.CurrencyTVFilter then
                return
            end
        end

        -- Immediately print value if another source of TV is gained or lost
        if ChatAnnouncements.SV.Currency.CurrencyTVThrottle > 0 and (reason ~= CURRENCY_CHANGE_REASON_LOOT and reason ~= CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER) then
            ChatAnnouncements.CurrencyTVThrottlePrinter()
        end

        currencyTypeColor = ColorizeColors.CurrencyTVColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_TELVAR_STONES), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyTVName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyTVShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalTV
    elseif currency == CURT_WRIT_VOUCHERS then -- Writ Vouchers
        if not ChatAnnouncements.SV.Currency.CurrencyWVChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyWVColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_WRIT_VOUCHERS), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyWVName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyWVShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalWV
    elseif currency == CURT_STYLE_STONES then -- Outfit Tokens
        if not ChatAnnouncements.SV.Currency.CurrencyOutfitTokenChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyOutfitTokenColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_STYLE_STONES), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyOutfitTokenName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyOutfitTokenShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalOutfitToken
    elseif currency == CURT_CHAOTIC_CREATIA then -- Transmute Crystals
        if not ChatAnnouncements.SV.Currency.CurrencyTransmuteChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyTransmuteColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_CHAOTIC_CREATIA), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyTransmuteName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyTransmuteShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalTransmute
    elseif currency == CURT_EVENT_TICKETS then -- Event Tickets
        if not ChatAnnouncements.SV.Currency.CurrencyEventChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyEventColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_EVENT_TICKETS), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyEventName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyEventShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalEvent
    elseif currency == CURT_UNDAUNTED_KEYS then -- Undaunted Keys
        if not ChatAnnouncements.SV.Currency.CurrencyUndauntedChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyUndauntedColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_UNDAUNTED_KEYS), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyUndauntedName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyUndauntedShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalUndaunted
    elseif currency == CURT_CROWNS then -- Crowns
        if not ChatAnnouncements.SV.Currency.CurrencyCrownsChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyCrownsColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_CROWNS), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyCrownsName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyCrownsShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalCrowns
    elseif currency == CURT_CROWN_GEMS then -- Crown Gems
        if not ChatAnnouncements.SV.Currency.CurrencyCrownGemsChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyCrownGemsColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_CROWN_GEMS), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyCrownGemsName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyCrownGemsShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalCrownGems
    elseif currency == CURT_ENDEAVOR_SEALS then -- Seals of Endeavor
        if not ChatAnnouncements.SV.Currency.CurrencyEndeavorsChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyEndeavorsColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_ENDEAVOR_SEALS), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyEndeavorsName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyEndeavorsShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalEndeavors
    elseif currency == CURT_ENDLESS_DUNGEON then -- Archival Fortunes
        if not ChatAnnouncements.SV.Currency.CurrencyEndlessChange then
            return
        end
        currencyTypeColor = ColorizeColors.CurrencyEndlessColorize:ToHex()
        currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_ARCHIVAL_FORTUNES), 16, 16) or ""
        currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyEndlessName, UpOrDown)
        currencyTotal = ChatAnnouncements.SV.Currency.CurrencyEndlessShowTotal
        messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalEndless
    else -- If for some reason there is no currency messageType, end the function now
        return
    end

    -- Did we gain or lose currency
    if UpOrDown > 0 then
        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
            changeColor = ColorizeColors.CurrencyUpColorize:ToHex()
        else
            changeColor = ColorizeColors.CurrencyColorize:ToHex()
        end
        changeType = ZO_CommaDelimitDecimalNumber(newValue - oldValue)
    elseif UpOrDown < 0 then
        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
            changeColor = ColorizeColors.CurrencyDownColorize:ToHex()
        else
            changeColor = ColorizeColors.CurrencyColorize:ToHex()
        end
        changeType = ZO_CommaDelimitDecimalNumber(oldValue - newValue)
    end

    -- Determine syntax based on reason
    if reason == CURRENCY_CHANGE_REASON_VENDOR and UpOrDown > 0 then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
        if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
            g_savedPurchase.changeType = changeType
            g_savedPurchase.formattedValue = formattedValue
            g_savedPurchase.currencyTypeColor = currencyTypeColor
            g_savedPurchase.currencyIcon = currencyIcon
            g_savedPurchase.currencyName = currencyName
            g_savedPurchase.currencyTotal = currencyTotal
            g_savedPurchase.messageTotal = messageTotal
            return
        end
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR and UpOrDown < 0 then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSpend
        if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
            g_savedPurchase.changeType = changeType
            g_savedPurchase.formattedValue = formattedValue
            g_savedPurchase.currencyTypeColor = currencyTypeColor
            g_savedPurchase.currencyIcon = currencyIcon
            g_savedPurchase.currencyName = currencyName
            g_savedPurchase.currencyTotal = currencyTotal
            g_savedPurchase.messageTotal = messageTotal
            return
        end
    elseif reason == CURRENCY_CHANGE_REASON_MAIL and UpOrDown > 0 then
        messageChange = g_mailTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
        if g_mailTarget ~= "" then
            messageType = "LUIE_CURRENCY_MAIL"
        end
    elseif reason == CURRENCY_CHANGE_REASON_MAIL and UpOrDown < 0 then
        if g_mailCODPresent then
            messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailCOD
            if g_mailTarget ~= "" then
                messageType = "LUIE_CURRENCY_MAIL"
            end
        else
            return
        end
    elseif reason == CURRENCY_CHANGE_REASON_BUYBACK then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSpend
        if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
            g_savedPurchase.changeType = changeType
            g_savedPurchase.formattedValue = formattedValue
            g_savedPurchase.currencyTypeColor = currencyTypeColor
            g_savedPurchase.currencyIcon = currencyIcon
            g_savedPurchase.currencyName = currencyName
            g_savedPurchase.currencyTotal = currencyTotal
            g_savedPurchase.messageTotal = messageTotal
            return
        end
    elseif reason == CURRENCY_CHANGE_REASON_TRADE and UpOrDown > 0 then
        messageChange = g_tradeTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeInNoName
        if g_tradeTarget ~= "" then
            messageType = "LUIE_CURRENCY_TRADE"
        end
    elseif reason == CURRENCY_CHANGE_REASON_TRADE and UpOrDown < 0 then
        messageChange = g_tradeTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeOut or ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeOutNoName
        if g_tradeTarget ~= "" then
            messageType = "LUIE_CURRENCY_TRADE"
        end
    elseif reason == CURRENCY_CHANGE_REASON_QUESTREWARD or reason == CURRENCY_CHANGE_REASON_DECONSTRUCT or reason == CURRENCY_CHANGE_REASON_MEDAL or reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_REFUND or reason == CURRENCY_CHANGE_REASON_JUMP_FAILURE_REFUND then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
    elseif reason == CURRENCY_CHANGE_REASON_SELL_STOLEN then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
        if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
            g_savedPurchase.changeType = changeType
            g_savedPurchase.formattedValue = formattedValue
            g_savedPurchase.currencyTypeColor = currencyTypeColor
            g_savedPurchase.currencyIcon = currencyIcon
            g_savedPurchase.currencyName = currencyName
            g_savedPurchase.currencyTotal = currencyTotal
            g_savedPurchase.messageTotal = messageTotal
            return
        end
    elseif reason == CURRENCY_CHANGE_REASON_BAGSPACE then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageStorage
        messageType = "LUIE_CURRENCY_BAG"
    elseif reason == CURRENCY_CHANGE_REASON_BANKSPACE then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageStorage
        messageType = "LUIE_CURRENCY_BANK"
    elseif reason == CURRENCY_CHANGE_REASON_CONVERSATION then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePay
    elseif reason == CURRENCY_CHANGE_REASON_EDIT_GUILD_HERALDRY or reason == CURRENCY_CHANGE_REASON_GUILD_TABARD then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSpend
    elseif reason == CURRENCY_CHANGE_REASON_BATTLEGROUND and UpOrDown < 0 then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCampaign
    elseif reason == CURRENCY_CHANGE_REASON_BATTLEGROUND and UpOrDown > 0 then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
    elseif reason == CURRENCY_CHANGE_REASON_TRAVEL_GRAVEYARD then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWayshrine
    elseif reason == CURRENCY_CHANGE_REASON_CRAFT or reason == CURRENCY_CHANGE_REASON_RECONSTRUCTION then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR_REPAIR then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRepair
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_LISTING then
        if ChatAnnouncements.SV.Currency.CurrencyGoldHideListingAH then
            return
        end
        g_savedPurchase.changeType = changeType
        g_savedPurchase.formattedValue = formattedValue
        g_savedPurchase.currencyTypeColor = currencyTypeColor
        g_savedPurchase.currencyIcon = currencyIcon
        g_savedPurchase.currencyName = currencyName
        g_savedPurchase.currencyTotal = currencyTotal
        g_savedPurchase.messageTotal = messageTotal
        return
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_SKILLS then
        ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_SKILLS)
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSkills
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_ATTRIBUTES then
        ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_ATTRIBUTES)
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageAttributes
    elseif reason == CURRENCY_CHANGE_REASON_STUCK then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUnstuck
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_MORPHS then
        ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_MORPHS)
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageMorphs
    elseif reason == CURRENCY_CHANGE_REASON_BOUNTY_PAID_FENCE then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageBounty
    elseif reason == CURRENCY_CHANGE_REASON_RESPEC_CHAMPION then
        ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_CHAMPION)
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageChampion
    elseif reason == CURRENCY_CHANGE_REASON_VENDOR_LAUNDER then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSpend
        if not ChatAnnouncements.SV.Inventory.LootVendorCurrency then
            messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSpend
        else
            g_savedPurchase.changeType = changeType
            g_savedPurchase.formattedValue = formattedValue
            g_savedPurchase.currencyTypeColor = currencyTypeColor
            g_savedPurchase.currencyIcon = currencyIcon
            g_savedPurchase.currencyName = currencyName
            g_savedPurchase.currencyTotal = currencyTotal
            g_savedPurchase.messageTotal = messageTotal
            return
        end
    elseif reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR or reason == CURRENCY_CHANGE_REASON_PVP_RESURRECT or reason == CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD or reason == CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageEarn
    elseif reason == CURRENCY_CHANGE_REASON_REWARD then
        -- Display "earn" for Seals of Endeavor
        if currency == CURT_ENDEAVOR_SEALS then
            messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageEarn
        else
            messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
        end
    elseif reason == CURRENCY_CHANGE_REASON_ANTIQUITY_REWARD then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExcavate
    elseif reason == CURRENCY_CHANGE_REASON_TRADINGHOUSE_PURCHASE then
        if ChatAnnouncements.SV.Currency.CurrencyGoldHideAH then
            return
        end
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSpend
    elseif reason == CURRENCY_CHANGE_REASON_BANK_DEPOSIT then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
    elseif reason == CURRENCY_CHANGE_REASON_GUILD_BANK_DEPOSIT then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositGuild
    elseif reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdraw
    elseif reason == CURRENCY_CHANGE_REASON_GUILD_BANK_WITHDRAWAL then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawGuild
    elseif reason == CURRENCY_CHANGE_REASON_BOUNTY_PAID_GUARD or reason == CURRENCY_CHANGE_REASON_BOUNTY_CONFISCATED then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
        LUIE_CallLater(ChatAnnouncements.JusticeDisplayConfiscate, 50)
    elseif reason == CURRENCY_CHANGE_REASON_PICKPOCKET then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePickpocket
    elseif reason == CURRENCY_CHANGE_REASON_LOOT or reason == CURRENCY_CHANGE_REASON_PVP_KILL_TRANSFER or reason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
    elseif reason == CURRENCY_CHANGE_REASON_LOOT_STOLEN then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSteal
    elseif reason == CURRENCY_CHANGE_REASON_KILL then
        if currency == CURT_ALLIANCE_POINTS then
            messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageEarn
        else
            messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
        end
    elseif reason == CURRENCY_CHANGE_REASON_DEATH then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLost
    elseif reason == CURRENCY_CHANGE_REASON_CROWN_CRATE_DUPLICATE or reason == CURRENCY_CHANGE_REASON_ITEM_CONVERTED_TO_GEMS or reason == CURRENCY_CHANGE_REASON_CROWNS_PURCHASED then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
    elseif reason == CURRENCY_CHANGE_REASON_PURCHASED_WITH_GEMS or reason == CURRENCY_CHANGE_REASON_PURCHASED_WITH_CROWNS then
        if currency == CURT_STYLE_STONES or currency == CURT_EVENT_TICKETS then
            messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
        else
            messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSpend
        end
    elseif reason == CURRENCY_CHANGE_REASON_PURCHASED_WITH_ENDEAVOR_SEALS then
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageSpend
        -- ==============================================================================
        -- DEBUG EVENTS - Don't know if these are implemented or what they are for.
    elseif reason == CURRENCY_CHANGE_REASON_ACTION or reason == CURRENCY_CHANGE_REASON_KEEP_UPGRADE or reason == CURRENCY_CHANGE_REASON_DEPRECATED_0 or reason == CURRENCY_CHANGE_REASON_DEPRECATED_2 or reason == CURRENCY_CHANGE_REASON_SOUL_HEAL or reason == CURRENCY_CHANGE_REASON_CASH_ON_DELIVERY or reason == CURRENCY_CHANGE_REASON_ABILITY_UPGRADE_PURCHASE or reason == CURRENCY_CHANGE_REASON_DEPRECATED_1 or reason == CURRENCY_CHANGE_REASON_STABLESPACE or reason == CURRENCY_CHANGE_REASON_ACHIEVEMENT or reason == CURRENCY_CHANGE_REASON_TRAIT_REVEAL or reason == CURRENCY_CHANGE_REASON_REFORGE or reason == CURRENCY_CHANGE_REASON_RECIPE or reason == CURRENCY_CHANGE_REASON_CONSUME_FOOD_DRINK or reason == CURRENCY_CHANGE_REASON_CONSUME_POTION or reason == CURRENCY_CHANGE_REASON_HARVEST_REAGENT or reason == CURRENCY_CHANGE_REASON_RESEARCH_TRAIT or reason == CURRENCY_CHANGE_REASON_GUILD_TABARD or reason == CURRENCY_CHANGE_REASON_GUILD_FORWARD_CAMP or reason == CURRENCY_CHANGE_REASON_BANK_FEE or reason == CURRENCY_CHANGE_REASON_CHARACTER_UPGRADE or reason == CURRENCY_CHANGE_REASON_TRIBUTE then
        messageChange = zo_strformat(GetString(LUIE_STRING_CA_DEBUG_MSG_CURRENCY), reason)
        -- END DEBUG EVENTS
        -- ==============================================================================
        -- If none of these returned true, then we must have just looted the currency (Potentially a few currency change events I missed too may have to adjust later)
    else
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
    end

    -- Haven't seen this one yet but it's more recently added and thus probably used for something.
    if reason == CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER then
        if LUIE.IsDevDebugEnabled() then
            LUIE.Debug("Currency Change Reason 76 - CURRENCY_CHANGE_REASON_LOOT_CURRENCY_CONTAINER")
        end
    end

    -- Send relevant values over to the currency printer
    ChatAnnouncements.CurrencyPrinter(currency, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
end

-- Printer function receives values from currency update or from other functions that display currency updates.
-- Type here refers to an LUIE_CURRENCY_TYPE
function ChatAnnouncements.CurrencyPrinter(baseCurrencyType, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType, carriedItem, carriedItemTotal)
    local messageP1 -- First part of message - Change
    local messageP2 -- Second part of the message (if enabled) - Total
    local item
    local name

    messageP1 = ("|r|c" .. currencyTypeColor .. currencyIcon .. " " .. changeType .. currencyName .. "|r|c" .. changeColor)

    if (currencyTotal and messageType ~= "LUIE_CURRENCY_HERALDRY") or (messageType == "LUIE_CURRENCY_VENDOR" and ChatAnnouncements.SV.Inventory.LootVendorTotalCurrency) then
        messageP2 = ("|r|c" .. currencyTypeColor .. currencyIcon .. " " .. formattedValue .. "|r|c" .. changeColor)
    else
        messageP2 = "|r"
    end

    local formattedMessageP1
    if messageType == "LUIE_CURRENCY_BAG" or messageType == "LUIE_CURRENCY_BANK" then
        local function ResolveStorageType()
            local bagType
            local icon
            if messageType == "LUIE_CURRENCY_BAG" then
                bagType = string_format(linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_BAGTYPE1) .. linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/icons/store_upgrade_bag.dds|t " or ""
            end
            if messageType == "LUIE_CURRENCY_BANK" then
                bagType = string_format(linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_BAGTYPE2) .. linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/icons/store_upgrade_bank.dds|t " or ""
            end
            return string_format("|r" .. icon .. "|cFFFFFF" .. bagType .. "|r|c" .. changeColor)
        end
        formattedMessageP1 = (string_format(messageChange, ResolveStorageType(), messageP1))
        -- TODO: Fix later
        --[[
    elseif messageType == "LUIE_CURRENCY_HERALDRY" then
        local icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:LuiExtended/media/unitframes/ca_heraldry.dds|t " or ""
        local heraldryMessage = string_format("|r" .. icon .. "|cFFFFFF" .. linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_CURRENCY_NAME_HERALDRY) .. linkBracket2[ChatAnnouncements.SV.BracketOptionItem] .. "|r|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, messageP1, heraldryMessage))
        ]]
        --
    elseif messageType == "LUIE_CURRENCY_RIDING_SPEED" or messageType == "LUIE_CURRENCY_RIDING_CAPACITY" or messageType == "LUIE_CURRENCY_RIDING_STAMINA" then
        local function ResolveRidingStats()
            -- if some var then icon = else no
            local skillType
            local icon
            if messageType == "LUIE_CURRENCY_RIDING_SPEED" then
                skillType = string_format(linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE1) .. linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_speed.dds|t " or ""
            elseif messageType == "LUIE_CURRENCY_RIDING_CAPACITY" then
                skillType = string_format(linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE2) .. linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_capacity.dds|t " or ""
            elseif messageType == "LUIE_CURRENCY_RIDING_STAMINA" then
                skillType = string_format(linkBracket1[ChatAnnouncements.SV.BracketOptionItem] .. GetString(LUIE_STRING_CA_STORAGE_RIDINGTYPE3) .. linkBracket2[ChatAnnouncements.SV.BracketOptionItem])
                icon = ChatAnnouncements.SV.Inventory.LootIcons and "|t16:16:/esoui/art/mounts/ridingskill_stamina.dds|t " or ""
            end
            return string_format("|r" .. icon .. "|cFFFFFF" .. skillType .. "|r|c" .. changeColor)
        end
        formattedMessageP1 = (string_format(messageChange, ResolveRidingStats(), messageP1))
    elseif messageType == "LUIE_CURRENCY_VENDOR" then
        item = string_format("|r" .. carriedItem .. "|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, item, messageP1))
    elseif messageType == "LUIE_CURRENCY_TRADE" then
        name = string_format("|r" .. g_tradeTarget .. "|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, messageP1, name))
    elseif messageType == "LUIE_CURRENCY_MAIL" then
        name = string_format("|r" .. g_mailTarget .. "|c" .. changeColor)
        formattedMessageP1 = (string_format(messageChange, messageP1, name))
    else
        formattedMessageP1 = (string_format(messageChange, messageP1))
    end
    local formattedMessageP2 = (currencyTotal or (messageType == "LUIE_CURRENCY_VENDOR" and ChatAnnouncements.SV.Inventory.LootVendorTotalCurrency)) and (string_format(messageTotal, messageP2)) or messageP2
    local finalMessage
    if currencyTotal and messageType ~= "LUIE_CURRENCY_HERALDRY" and messageType ~= "LUIE_CURRENCY_VENDOR" and messageType ~= "LUIE_CURRENCY_POSTAGE" or (messageType == "LUIE_CURRENCY_VENDOR" and ChatAnnouncements.SV.Inventory.LootVendorTotalCurrency) then
        if messageType == "LUIE_CURRENCY_VENDOR" then
            finalMessage = string_format("|c%s%s|r%s |c%s%s|r", changeColor, formattedMessageP1, carriedItemTotal, changeColor, formattedMessageP2)
        else
            finalMessage = string_format("|c%s%s|r |c%s%s|r", changeColor, formattedMessageP1, changeColor, formattedMessageP2)
        end
    else
        if messageType == "LUIE_CURRENCY_VENDOR" then
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
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = resolveType }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
end

function ChatAnnouncements.CurrencyGoldThrottlePrinter()
    if g_currencyGoldThrottleValue > 0 and g_currencyGoldThrottleValue > ChatAnnouncements.SV.Currency.CurrencyGoldFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(g_currencyGoldThrottleValue)
        local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_MONEY), 16, 16) or ""
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, g_currencyGoldThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
        local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalGold
        local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
        local messageType = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
    end
    g_currencyGoldThrottleValue = 0
    g_currencyGoldThrottleTotal = 0
end

function ChatAnnouncements.CurrencyAPThrottlePrinter()
    if g_currencyAPThrottleValue > 0 and g_currencyAPThrottleValue > ChatAnnouncements.SV.Currency.CurrencyAPFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(g_currencyAPThrottleTotal)
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(g_currencyAPThrottleValue)
        local currencyTypeColor = ColorizeColors.CurrencyAPColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_ALLIANCE_POINTS), 16, 16) or ""
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyAPName, g_currencyAPThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyAPShowTotal
        local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalAP
        local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageEarn
        local messageType = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedAP")
    g_currencyAPThrottleValue = 0
    g_currencyAPThrottleTotal = 0
end

function ChatAnnouncements.CurrencyTVThrottlePrinter()
    if g_currencyTVThrottleValue > 0 and g_currencyTVThrottleValue > ChatAnnouncements.SV.Currency.CurrencyTVFilter then
        local formattedValue = ZO_CommaDelimitDecimalNumber(g_currencyTVThrottleTotal)
        local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
        local changeType = ZO_CommaDelimitDecimalNumber(g_currencyTVThrottleValue)
        local currencyTypeColor = ColorizeColors.CurrencyTVColorize:ToHex()
        local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_TELVAR_STONES), 16, 16) or ""
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyTVName, g_currencyTVThrottleValue)
        local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyTVShowTotal
        local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalTV
        local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
        local messageType = "LUIE_CURRENCY_THROTTLE"
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedTV")
    g_currencyTVThrottleValue = 0
    g_currencyTVThrottleTotal = 0
end

function ChatAnnouncements.MiscAlertLockBroke(eventCode, inactivityLengthMs)
    g_lockpickBroken = true
    LUIE_CallLater(function ()
        g_lockpickBroken = false
    end, 200)
end

function ChatAnnouncements.MiscAlertLockSuccess(eventCode)
    if ChatAnnouncements.SV.Notify.NotificationLockpickCA then
        local message = GetString(LUIE_STRING_CA_LOCKPICK_SUCCESS)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "NOTIFICATION" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_LOCKPICK_SUCCESS))
    end
    g_lockpickBroken = true
    LUIE_CallLater(function ()
        g_lockpickBroken = false
    end, 200)
end

function ChatAnnouncements.StorageBag(eventCode, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
        if ChatAnnouncements.SV.Notify.StorageBagCA then
            local formattedString = ColorizeColors.StorageBagColorize:Colorize(zo_strformat(SI_INVENTORY_BAG_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.StorageBagAlert then
            local text = zo_strformat(LUIE_STRING_CA_STORAGE_BAG_UPGRADE)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end
    end
end

function ChatAnnouncements.StorageBank(eventCode, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
        if ChatAnnouncements.SV.Notify.StorageBagCA then
            local formattedString = ColorizeColors.StorageBagColorize:Colorize(zo_strformat(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "MESSAGE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Notify.StorageBagAlert then
            local text = zo_strformat(LUIE_STRING_CA_STORAGE_BANK_UPGRADE)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end
    end
end

function ChatAnnouncements.OnBuybackItem(eventCode, itemName, quantity, money, itemSound)
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ColorizeColors.CurrencyColorize:ToHex()
    end
    local itemIcon, _, _, _, _ = GetItemLinkInfo(itemName)
    local icon = itemIcon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local messageType = "LUIE_CURRENCY_VENDOR"
    local messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageBuyback or ChatAnnouncements.SV.ContextMessages.CurrencyMessageBuybackNoV
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
        if total >= 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if g_savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(nil, g_savedPurchase.formattedValue, changeColor, g_savedPurchase.changeType, g_savedPurchase.currencyTypeColor, g_savedPurchase.currencyIcon, g_savedPurchase.currencyName, g_savedPurchase.currencyTotal, messageChange, g_savedPurchase.messageTotal, messageType, carriedItem, carriedItemTotal)
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "CURRENCY" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    g_savedPurchase = {}
end

function ChatAnnouncements.OnBuyItem(eventCode, itemName, entryType, quantity, money, specialCurrencyType1, specialCurrencyInfo1, specialCurrencyQuantity1, specialCurrencyType2, specialCurrencyInfo2, specialCurrencyQuantity2, itemSoundCategory)
    local itemIcon
    if entryType == STORE_ENTRY_TYPE_COLLECTIBLE then
        if isShopCollectible[itemName] then
            local id = isShopCollectible[itemName]
            itemName = GetCollectibleLink(id, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            itemIcon = GetCollectibleIcon(id)
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
    local messageType = "LUIE_CURRENCY_VENDOR"
    local messageChange = ((money ~= 0 or specialCurrencyQuantity1 ~= 0 or specialCurrencyQuantity2 ~= 0) and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageBuy or ChatAnnouncements.SV.ContextMessages.CurrencyMessageBuyNoV
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
        if total >= 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if (money ~= 0 or specialCurrencyQuantity1 ~= 0 or specialCurrencyQuantity2 ~= 0) and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if g_savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(nil, g_savedPurchase.formattedValue, changeColor, g_savedPurchase.changeType, g_savedPurchase.currencyTypeColor, g_savedPurchase.currencyIcon, g_savedPurchase.currencyName, g_savedPurchase.currencyTotal, messageChange, g_savedPurchase.messageTotal, messageType, carriedItem, carriedItemTotal)
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "CURRENCY" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end

    g_savedPurchase = {}
end

function ChatAnnouncements.OnSellItem(eventCode, itemName, quantity, money)
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyUpColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ColorizeColors.CurrencyColorize:ToHex()
    end
    local itemIcon, _, _, _, _ = GetItemLinkInfo(itemName)
    local icon = itemIcon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local messageType = "LUIE_CURRENCY_VENDOR"
    local messageChange
    if g_weAreInAFence then
        messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageFence or ChatAnnouncements.SV.ContextMessages.CurrencyMessageFenceNoV
    else
        messageChange = (money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageSell or ChatAnnouncements.SV.ContextMessages.CurrencyMessageSellNoV
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
        if total >= 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if money ~= 0 and ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        -- Stop messages from printing if for some reason the currency event never triggers
        if g_savedPurchase.formattedValue then
            ChatAnnouncements.CurrencyPrinter(nil, g_savedPurchase.formattedValue, changeColor, g_savedPurchase.changeType, g_savedPurchase.currencyTypeColor, g_savedPurchase.currencyIcon, g_savedPurchase.currencyName, g_savedPurchase.currencyTotal, messageChange, g_savedPurchase.messageTotal, messageType, carriedItem, carriedItemTotal)
        end
    else
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "CURRENCY" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
    end
    g_savedPurchase = {}
end

function ChatAnnouncements.TradingHouseResponseReceived(eventCode, TradingHouseResult, result)
    -- Bail if a pending item isn't being sold
    if not TradingHouseResult == TRADING_HOUSE_RESULT_POST_PENDING then
        return
    end
    -- If we don't have both a valid saved currency transaction and saved message then bail out.
    if not g_savedPurchase.formattedValue or not g_savedItem.itemLink then
        g_savedPurchase = {}
        g_savedItem = {}
        return
    end

    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
        changeColor = ColorizeColors.CurrencyColorize:ToHex()
    end
    local messageType = "LUIE_CURRENCY_VENDOR"
    local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageListingValue

    local icon = g_savedItem.icon
    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
    local stack = g_savedItem.stack
    local itemCount = stack > 1 and (" |cFFFFFFx" .. stack .. "|r") or ""
    local itemName = g_savedItem.itemLink

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
        if total >= 1 then
            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
        end
    end

    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
        ChatAnnouncements.CurrencyPrinter(nil, g_savedPurchase.formattedValue, changeColor, g_savedPurchase.changeType, g_savedPurchase.currencyTypeColor, g_savedPurchase.currencyIcon, g_savedPurchase.currencyName, g_savedPurchase.currencyTotal, messageChange, g_savedPurchase.messageTotal, messageType, carriedItem, carriedItemTotal)
    else
        messageType = "CURRENCY"
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageList
        local finalMessageP1 = string_format(carriedItem .. "|r|c" .. changeColor)
        local finalMessageP2 = string_format(messageChange, finalMessageP1)
        local finalMessage = string_format("|c%s%s|r%s", changeColor, finalMessageP2, carriedItemTotal)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = messageType }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageListing
        ChatAnnouncements.CurrencyPrinter(nil, g_savedPurchase.formattedValue, changeColor, g_savedPurchase.changeType, g_savedPurchase.currencyTypeColor, g_savedPurchase.currencyIcon, g_savedPurchase.currencyName, g_savedPurchase.currencyTotal, messageChange, g_savedPurchase.messageTotal, messageType)
    end
    g_savedPurchase = {}
    g_savedItem = {}
end

function ChatAnnouncements.MailMoneyChanged(eventCode)
    g_mailCOD = 0
    g_postageAmount = GetQueuedMailPostage()
    local previousMailAmount = g_mailAmount
    local getMailAmount = GetQueuedMoneyAttachment()
    -- If we send more then half of the gold in our bags for some reason this event fires again so this is a workaround
    if getMailAmount == GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) and getMailAmount ~= previousMailAmount then
        return
    else
        g_mailAmount = getMailAmount
    end
end

function ChatAnnouncements.MailCODChanged(eventCode)
    g_mailCOD = GetQueuedCOD()
    g_postageAmount = GetQueuedMailPostage()
    g_mailAmount = GetQueuedMoneyAttachment()
end

function ChatAnnouncements.MailRemoved(eventCode)
    if ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
        if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
            local message = GetString(LUIE_STRING_CA_MAIL_DELETED_MSG)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_MAIL_DELETED_MSG))
        end
    end
end

function ChatAnnouncements.OnMailReadable(eventCode, mailId)
    local senderDisplayName, senderCharacterName, subject, icon, unread, fromSystem, fromCustomerService, returned, numAttachments, attachedMoney, codAmount, expiresInDays, secsSinceReceived, category = GetMailItemInfo(mailId)

    -- Use different color if the mail is from System (Hireling Mail, Rewards for the Worthy, etc)
    if fromSystem or fromCustomerService then
        g_mailTarget = ZO_GAME_REPRESENTATIVE_TEXT:Colorize(senderDisplayName)
    elseif senderDisplayName ~= "" and senderCharacterName ~= "" then
        local finalName = ChatAnnouncements.ResolveNameLink(senderCharacterName, senderDisplayName)
        g_mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
    else
        local finalName
        if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
            finalName = ZO_LinkHandler_CreateLinkWithoutBrackets(senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, senderDisplayName)
        else
            finalName = ZO_LinkHandler_CreateLink(senderDisplayName, nil, DISPLAY_NAME_LINK_TYPE, senderDisplayName)
        end
        g_mailTarget = ZO_SELECTED_TEXT:Colorize(finalName)
    end

    if codAmount > 0 then
        g_mailCODPresent = true
    end
end

function ChatAnnouncements.OnMailTakeAttachedItem(eventCode, mailId)
    if ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
        local mailString
        if g_mailCODPresent then
            mailString = GetString(LUIE_STRING_CA_MAIL_RECEIVED_COD)
        else
            mailString = GetString(LUIE_STRING_CA_MAIL_RECEIVED)
        end
        if mailString then
            if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = mailString, messageType = "NOTIFICATION", isSystem = true }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, mailString)
            end
        end
    end
end

function ChatAnnouncements.OnMailAttach(eventCode, attachmentSlot)
    g_postageAmount = GetQueuedMailPostage()
    g_mailAmount = GetQueuedMoneyAttachment()
    local mailIndex = attachmentSlot
    local bagId, slotId, icon, stack = GetQueuedItemAttachmentInfo(attachmentSlot)
    local itemId = GetItemId(bagId, slotId)
    local itemLink = GetMailQueuedAttachmentLink(attachmentSlot, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
    local itemType = GetItemLinkItemType(itemLink)
    g_mailStacksOut[mailIndex] = { icon = icon, stack = stack, itemId = itemId, itemLink = itemLink, itemType = itemType }
end

-- Removes items from index if they are removed from the trade
function ChatAnnouncements.OnMailAttachRemove(eventCode, attachmentSlot)
    g_postageAmount = GetQueuedMailPostage()
    g_mailAmount = GetQueuedMoneyAttachment()
    local mailIndex = attachmentSlot
    g_mailStacksOut[mailIndex] = nil
end

function ChatAnnouncements.OnMailOpenBox(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootMail then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        g_inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
    g_inMail = true
end

function ChatAnnouncements.OnMailCloseBox(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        g_inventoryStacks = {}
    end
    g_inMail = false
    g_mailStacksOut = {}
end

-- Sends results of the trade to the Item Log print function and clears variables so they are reset for next trade interactions

function ChatAnnouncements.OnMailSuccess(eventCode)
    local formattedValue = ZO_CommaDelimitDecimalNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))
    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
    local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
    local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_MONEY), 16, 16) or ""
    local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
    local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalGold

    if g_postageAmount > 0 then
        local messageType = "LUIE_CURRENCY_POSTAGE"
        local changeType = ZO_CommaDelimitDecimalNumber(g_postageAmount)
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, g_postageAmount)
        local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePostage
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
    end

    if not g_mailCODPresent and g_mailAmount > 0 then
        local messageType = "LUIE_CURRENCY_MAIL"
        local changeType = ZO_CommaDelimitDecimalNumber(g_mailAmount)
        local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, g_mailAmount)
        local messageChange = g_mailTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailOut or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailOutNoName
        ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
    end

    if ChatAnnouncements.SV.Notify.NotificationMailSendCA or ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
        local mailString
        if not g_mailCODPresent then
            mailString = g_mailCOD > 1 and GetString(LUIE_STRING_CA_MAIL_SENT_COD) or GetString(LUIE_STRING_CA_MAIL_SENT)
        end
        if mailString then
            if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = mailString, messageType = "NOTIFICATION", isSystem = true }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, mailString)
            end
        end
    end

    if ChatAnnouncements.SV.Inventory.LootMail then
        for mailIndex = 1, 6 do
            local item = g_mailStacksOut[mailIndex]
            if item ~= nil then
                local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                local logPrefix = g_mailTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailOut or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailOutNoName
                ChatAnnouncements.ItemCounterDelayOut(item.icon, item.stack, item.itemType, item.itemId, item.itemLink, g_mailTarget, logPrefix, gainOrLoss, false)
            end
        end
    end

    g_mailCODPresent = false
    g_mailCOD = 0
    g_postageAmount = 0
    g_mailAmount = 0
    g_mailStacksOut = {}
end

-- Helper function to return color (without |c prefix) according to current percentage
local function AchievementPctToColor(pct)
    return pct == 1 and "71DE73" or pct < 0.33 and "F27C7C" or pct < 0.66 and "EDE858" or "CCF048"
end

function ChatAnnouncements.OnAchievementUpdated(eventCode, id)
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

                if percentage > 0 and percentage % ChatAnnouncements.SV.Achievement.AchievementStep == 0 and g_achievementLastPercentage[id] ~= percentage then
                    showInfo = true
                    g_achievementLastPercentage[id] = percentage
                end
            end
        end

        -- Bail out here if this achievement update event is not going to be printed to chat
        if not showInfo then
            return
        end

        local link = zo_strformat(GetAchievementLink(id, linkBrackets[ChatAnnouncements.SV.BracketOptionAchievement]))
        local name = zo_strformat(GetAchievementNameFromLink(link))

        if ChatAnnouncements.SV.Achievement.AchievementUpdateCA then
            local catName, _, _, _, _, _ = GetAchievementCategoryInfo(topLevelIndex)
            local subcatName = categoryIndex ~= nil and GetAchievementSubCategoryInfo(topLevelIndex, categoryIndex) or "General"
            local _, _, _, icon, _, _, _ = GetAchievementInfo(id)
            icon = ChatAnnouncements.SV.Achievement.AchievementIcon and ("|t16:16:" .. icon .. "|t ") or ""

            local stringpart1 = ColorizeColors.AchievementColorize1:Colorize(string_format("%s%s%s %s%s", bracket1[ChatAnnouncements.SV.Achievement.AchievementBracketOptions], ChatAnnouncements.SV.Achievement.AchievementProgressMsg, bracket2[ChatAnnouncements.SV.Achievement.AchievementBracketOptions], icon, link))

            local stringpart2 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and string_format(" %s|c%s%d%%|r", ColorizeColors.AchievementColorize2:Colorize("("), AchievementPctToColor(totalCmp / totalReq), zo_floor(100 * totalCmp / totalReq)) or ColorizeColors.AchievementColorize2:Colorize(string_format("%d%%", zo_floor(100 * totalCmp / totalReq)))

            local stringpart3
            if ChatAnnouncements.SV.Achievement.AchievementCategory and ChatAnnouncements.SV.Achievement.AchievementSubcategory then
                stringpart3 = ColorizeColors.AchievementColorize2:Colorize(string_format(") %s%s - %s%s", bracket3[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions], catName, subcatName, bracket4[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions]))
            elseif ChatAnnouncements.SV.Achievement.AchievementCategory and not ChatAnnouncements.SV.Achievement.AchievementSubcategory then
                stringpart3 = ColorizeColors.AchievementColorize2:Colorize(string_format(") %s%s%s", bracket3[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions], catName, bracket4[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions]))
            else
                stringpart3 = ColorizeColors.AchievementColorize2:Colorize(")")
            end

            -- Prepare details information
            local stringpart4 = ""
            if ChatAnnouncements.SV.Achievement.AchievementDetails then
                -- Skyshards needs separate treatment otherwise text become too long
                -- We also put this short information for achievements that has too many subitems
                if topLevelIndex == 9 or #cmpInfo > 12 then
                    stringpart4 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and string_format(" %s|c%s%d|r%s|c71DE73%d|c87B7CC|r%s", ColorizeColors.AchievementColorize2:Colorize("("), AchievementPctToColor(totalCmp / totalReq), totalCmp, ColorizeColors.AchievementColorize2:Colorize("/"), totalReq, ColorizeColors.AchievementColorize2:Colorize(")")) or ColorizeColors.AchievementColorize2:Colorize(string_format(" (%d/%d)", totalCmp, totalReq))
                else
                    for i = 1, #cmpInfo do
                        -- Boolean achievement stage
                        if cmpInfo[i][3] == 1 then
                            cmpInfo[i] = ChatAnnouncements.SV.Achievement.AchievementColorProgress and string_format("|c%s%s", AchievementPctToColor(cmpInfo[i][2]), cmpInfo[i][1]) or ColorizeColors.AchievementColorize2:Colorize(string_format("%s%s", cmpInfo[i][2], cmpInfo[i][1]))
                            -- Others
                        else
                            local pct = cmpInfo[i][2] / cmpInfo[i][3]
                            cmpInfo[i] = ChatAnnouncements.SV.Achievement.AchievementColorProgress and string_format("%s %s|c%s%d|r%s|c71DE73%d|r%s", ColorizeColors.AchievementColorize2:Colorize(cmpInfo[i][1]), ColorizeColors.AchievementColorize2:Colorize("("), AchievementPctToColor(pct), cmpInfo[i][2], ColorizeColors.AchievementColorize2:Colorize("/"), cmpInfo[i][3], ColorizeColors.AchievementColorize2:Colorize(")")) or ColorizeColors.AchievementColorize2:Colorize(string_format("%s (%d/%d)", cmpInfo[i][1], cmpInfo[i][2], cmpInfo[i][3]))
                        end
                    end
                    stringpart4 = " " .. table_concat(cmpInfo, ColorizeColors.AchievementColorize2:Colorize(", ")) .. ""
                end
            end
            local finalString = string_format("%s%s%s%s", stringpart1, stringpart2, stringpart3, stringpart4)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalString, messageType = "ACHIEVEMENT" }
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

function ChatAnnouncements.GuildBankItemAdded(eventCode, slotId, addedByLocalPlayer)
    if addedByLocalPlayer then
        LUIE_CallLater(ChatAnnouncements.LogGuildBankChange, 50)
    end
end

function ChatAnnouncements.GuildBankItemRemoved(eventCode, slotId, addedByLocalPlayer)
    if addedByLocalPlayer then
        LUIE_CallLater(ChatAnnouncements.LogGuildBankChange, 50)
    end
end

function ChatAnnouncements.LogGuildBankChange()
    if g_guildBankCarry ~= nil then
        ChatAnnouncements.ItemPrinter(g_guildBankCarry.icon, g_guildBankCarry.stack, g_guildBankCarry.itemType, g_guildBankCarry.itemId, g_guildBankCarry.itemLink, g_guildBankCarry.receivedBy, g_guildBankCarry.logPrefix, g_guildBankCarry.gainOrLoss, false)
    end
    g_guildBankCarry = nil
end

function ChatAnnouncements.IndexInventory()
    -- d("Debug - Inventory Indexed!")
    local bagsize = GetBagSize(BAG_BACKPACK)

    for i = 0, bagsize do
        local icon, stack = GetItemInfo(BAG_BACKPACK, i)
        local itemType = GetItemType(BAG_BACKPACK, i)
        local itemId = GetItemId(BAG_BACKPACK, i)
        local itemLink = GetItemLink(BAG_BACKPACK, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        if itemLink ~= "" then
            g_inventoryStacks[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
        local itemLink = GetItemLink(BAG_WORN, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        if itemLink ~= "" then
            g_equippedStacks[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
        end
    end
end

function ChatAnnouncements.IndexBank()
    -- ("Debug - Bank Indexed!")
    local bagsizebank = GetBagSize(BAG_BANK)
    local bagsizesubbank = GetBagSize(BAG_SUBSCRIBER_BANK)

    for i = 0, bagsizebank do
        local icon, stack = GetItemInfo(BAG_BANK, i)
        local bagitemlink = GetItemLink(BAG_BANK, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemId = GetItemId(BAG_BANK, i)
        local itemLink = GetItemLink(BAG_BANK, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemType = GetItemType(BAG_BANK, i)
        if bagitemlink ~= "" then
            g_bankStacks[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
        end
    end

    for i = 0, bagsizesubbank do
        local icon, stack = GetItemInfo(BAG_SUBSCRIBER_BANK, i)
        local bagitemlink = GetItemLink(BAG_SUBSCRIBER_BANK, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemId = GetItemId(BAG_SUBSCRIBER_BANK, i)
        local itemLink = GetItemLink(BAG_SUBSCRIBER_BANK, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local itemType = GetItemType(BAG_SUBSCRIBER_BANK, i)
        if bagitemlink ~= "" then
            g_bankSubscriberStacks[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
        g_houseBags[bag] = {}

        for i = 0, bagsize do
            local icon, stack = GetItemInfo(bag, i)
            local bagitemlink = GetItemLink(bag, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            local itemId = GetItemId(bag, i)
            local itemLink = GetItemLink(bag, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            local itemType = GetItemType(bag, i)
            if bagitemlink ~= "" then
                g_houseBags[bag][i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end
    end
end

function ChatAnnouncements.CraftingOpen(eventCode, craftSkill, sameStation)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootCraft then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateCraft)
        g_inventoryStacks = {}
        g_bankStacks = {}
        g_bankSubscriberStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
        ChatAnnouncements.IndexBank()      -- Index Bank
    end
end

function ChatAnnouncements.CraftingClose(eventCode, craftSkill)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        g_inventoryStacks = {}
    end
    g_bankStacks = {}
    g_bankSubscriberStacks = {}
end

function ChatAnnouncements.BankOpen(eventCode, bankBag)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootBank then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateBank)
        g_inventoryStacks = {}
        g_bankStacks = {}
        g_bankSubscriberStacks = {}
        g_houseBags = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
        ChatAnnouncements.IndexBank()      -- Index Bank
        ChatAnnouncements.IndexHouseBags() -- Index House Bags
    end
    g_bankBag = bankBag > 6 and 2 or 1
end

function ChatAnnouncements.BankClose(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        g_inventoryStacks = {}
    end
    g_bankStacks = {}
    g_bankSubscriberStacks = {}
    g_houseBags = {}
end

function ChatAnnouncements.GuildBankOpen(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootBank then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateGuildBank)
        g_inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
end

function ChatAnnouncements.GuildBankClose(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        g_inventoryStacks = {}
    end
end

function ChatAnnouncements.FenceOpen(eventCode, allowSell, allowLaunder)
    g_weAreInAFence = true
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.LootVendor then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdateFence)
        g_inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
end

function ChatAnnouncements.StoreOpen(eventCode)
    g_weAreInAStore = true
end

function ChatAnnouncements.StoreClose(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        g_inventoryStacks = {}
    end
    LUIE_CallLater(function ()
        g_weAreInAStore = false
        g_weAreInAFence = false
    end, 1000)
end

function ChatAnnouncements.GuildStoreOpen(eventCode)
    g_weAreInAStore = true
    g_weAreInAGuildStore = true
end

function ChatAnnouncements.GuildStoreClose(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
    end
    if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
        g_inventoryStacks = {}
    end
    LUIE_CallLater(function ()
        g_weAreInAStore = false
        g_weAreInAGuildStore = false
    end, 1000)
end

function ChatAnnouncements.FenceSuccess(eventCode, result)
    if result == ITEM_LAUNDER_RESULT_SUCCESS then
        if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
            if g_savedPurchase.formattedValue ~= nil and g_savedPurchase.formattedValue ~= "" then
                ChatAnnouncements.CurrencyPrinter(nil, g_savedPurchase.formattedValue, g_savedPurchase.changeColor, g_savedPurchase.changeType, g_savedPurchase.currencyTypeColor, g_savedPurchase.currencyIcon, g_savedPurchase.currencyName, g_savedPurchase.currencyTotal, g_savedPurchase.messageChange, g_savedPurchase.messageTotal, g_savedPurchase.messageType, g_savedPurchase.carriedItem, g_savedPurchase.carriedItemTotal)
            end
        else
            if g_savedLaunder.itemId ~= nil and g_savedLaunder.itemId ~= "" then
                ChatAnnouncements.ItemPrinter(g_savedLaunder.icon, g_savedLaunder.stack, g_savedLaunder.itemType, g_savedLaunder.itemId, g_savedLaunder.itemLink, "", g_savedLaunder.logPrefix, g_savedLaunder.gainOrLoss, false)
            end
        end
        g_savedLaunder = {}
        g_savedPurchase = {}
    end
end

-- Only active if destroyed items is enabled, flags the next item that is removed from inventory as destroyed.
function ChatAnnouncements.DestroyItem(eventCode, itemSoundCategory)
    g_itemWasDestroyed = true
end

function ChatAnnouncements.OnPackSiege()
    local function ResetPackSiege()
        g_packSiege = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetPackSiege")
    end
    g_packSiege = true
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
    ---
    --- @param questIndex integer
    local function AddQuests(questIndex)
        local inventory = PLAYER_INVENTORY.inventories[INVENTORY_QUEST_ITEM]
        local itemTable = inventory.slots[questIndex]
        --- @cast itemTable questItem_itemTable
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
                --     LUIE.Debug(itemId .. " Removed")
                -- end
                --

                countChange = newValue + questItemIndex[itemId].counter
                g_questItemRemoved[itemId] = true
                LUIE_CallLater(function ()
                    g_questItemRemoved[itemId] = false
                end, 100)

                if not Quests.QuestItemHideRemove[itemId] and not g_loginHideQuestLoot then
                    if ChatAnnouncements.SV.Inventory.LootQuestRemove then
                        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
                            color = ColorizeColors.CurrencyDownColorize:ToHex()
                        else
                            color = ColorizeColors.CurrencyColorize:ToHex()
                        end

                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRemove

                        -- Any items that are removed at the same time a quest is turned or advanced in will be flagged to display as "Turned In."
                        if g_itemReceivedIsQuestReward then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestTurnIn
                        end

                        if Quests.ItemRemovedMessage[itemId] and not Quests.ItemIgnoreTurnIn[itemId] then
                            logPrefix = Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_TURNIN and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestTurnIn or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_USE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestUse or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_EXHAUST and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestExhaust or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_OFFER and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestOffer or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_DISCARD and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestDiscard or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_CONFISCATE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestConfiscate or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_OPEN and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestOpen or
                                Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_ADMINISTER and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestAdminister or Quests.ItemRemovedMessage[itemId] == LUIE_QUEST_MESSAGE_PLACE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestPlace
                        end

                        if Quests.ItemRemovedInDialogueMessage[itemId] and g_talkingToNPC then
                            logPrefix = Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_TURNIN and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestTurnIn or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_USE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestUse or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_EXHAUST and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestExhaust or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_OFFER and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestOffer or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_DISCARD and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestDiscard or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_CONFISCATE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestConfiscate or
                                Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_OPEN and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestOpen or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_ADMINISTER and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestAdminister or Quests.ItemRemovedInDialogueMessage[itemId] == LUIE_QUEST_MESSAGE_PLACE and ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestPlace
                        end

                        -- Any items that are removed at the same time a quest is abandoned will be flagged to display as "Removed."
                        if g_itemReceivedIsQuestAbandon then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRemove
                        end

                        local quantity = (countChange * -1) > 1 and (" |cFFFFFFx" .. (countChange * -1) .. "|r") or ""

                        formattedMessageP1 = ("|r" .. formattedIcon .. itemLink .. quantity .. "|c" .. color)
                        formattedMessageP2 = string_format(logPrefix, formattedMessageP1)

                        if ChatAnnouncements.SV.Inventory.LootTotal and total > 1 then
                            totalString = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        else
                            totalString = ""
                        end

                        finalMessage = string_format("|c%s%s|r%s", color, formattedMessageP2, totalString)

                        eventManager:UnregisterForUpdate(moduleName .. "Printer")
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "QUEST_LOOT_REMOVE", itemId = itemId }
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
                --     LUIE.Debug(itemId .. " Added")
                -- end
                --
                countChange = newValue - questItemIndex[itemId].stack
                g_questItemAdded[itemId] = true
                LUIE_CallLater(function ()
                    g_questItemAdded[itemId] = false
                end, 100)

                if not Quests.QuestItemHideLoot[itemId] and not g_loginHideQuestLoot then
                    if ChatAnnouncements.SV.Inventory.LootQuestAdd then
                        if ChatAnnouncements.SV.Currency.CurrencyContextColor then
                            color = ColorizeColors.CurrencyUpColorize:ToHex()
                        else
                            color = ColorizeColors.CurrencyColorize:ToHex()
                        end

                        if g_isLooted and not g_itemReceivedIsQuestReward and not g_isPickpocketed and not g_isStolen then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
                            -- reset variables that control looted, or at least LUIE_CallLater them
                        elseif g_isPickpocketed then
                            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePickpocket
                        elseif g_isStolen and not g_isPickpocketed then
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
                            totalString = string_format(" |c%s%s|r %s|cFFFFFF%s|r", color, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        else
                            totalString = ""
                        end

                        finalMessage = string_format("|c%s%s|r%s", color, formattedMessageP2, totalString)

                        eventManager:UnregisterForUpdate(moduleName .. "Printer")
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "QUEST_LOOT_ADD", itemId = itemId }
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

---
--- @param itemId integer
--- @param stackCount integer
--- @param icon string
--- @param reset boolean
local function DisplayQuestItem(itemId, stackCount, icon, reset)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Quest Item Details:\n" ..
    --         "--> itemId: " .. tostring(itemId) .. "\n" ..
    --         "--> stackCount: " .. tostring(stackCount) .. "\n" ..
    --         "--> questItemIcon: " .. tostring(icon) .. "\n" ..
    --         "--> reset: " .. tostring(reset)
    --     Debug(traceback)
    -- end
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

--- @param eventCode integer
--- @param receivedBy string
--- @param itemLink string
--- @param quantity integer
--- @param itemSound ItemUISoundCategory
--- @param lootType LootItemType
--- @param lootedBySelf boolean
--- @param isPickpocketLoot boolean
--- @param questItemIcon string
--- @param itemId integer
--- @param isStolen boolean
function ChatAnnouncements.OnLootReceived(eventCode, receivedBy, itemLink, quantity, itemSound, lootType, lootedBySelf, isPickpocketLoot, questItemIcon, itemId, isStolen)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Loot Received:\n" ..
    --         "--> eventCode: " .. tostring(eventCode) .. "\n" ..
    --         "--> receivedBy: " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, receivedBy) .. "\n" ..
    --         "--> itemLink: " .. tostring(itemLink) .. "\n" ..
    --         "--> quantity: " .. tostring(quantity) .. "\n" ..
    --         "--> itemSound: " .. tostring(itemSound) .. "\n" ..
    --         "--> lootType: " .. tostring(lootType) .. "\n" ..
    --         "--> lootedBySelf: " .. tostring(lootedBySelf) .. "\n" ..
    --         "--> isPickpocketLoot: " .. tostring(isPickpocketLoot) .. "\n" ..
    --         "--> questItemIcon: " .. tostring(questItemIcon) .. "\n" ..
    --         "--> itemId: " .. tostring(itemId) .. "\n" ..
    --         "--> isStolen: " .. tostring(isStolen)
    --     Debug(traceback)
    -- end
    -- If the player loots an item
    if not isPickpocketLoot and lootedBySelf then
        g_isLooted = true

        local function ResetIsLooted()
            g_isLooted = false
            eventManager:UnregisterForUpdate(moduleName .. "ResetLooted")
        end
        eventManager:UnregisterForUpdate(moduleName .. "ResetLooted")
        eventManager:RegisterForUpdate(moduleName .. "ResetLooted", 150, ResetIsLooted)
    end

    -- If the player pickpockets an item
    if isPickpocketLoot and lootedBySelf then
        g_isPickpocketed = true

        local function ResetIsPickpocketed()
            g_isPickpocketed = false
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
            formattedItemLink = zo_strgsub(itemLink, "^|H0", "|H1", 1)
        end

        local formatName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, receivedBy)

        local recipient
        if g_groupLootIndex[formatName] then
            recipient = ZO_SELECTED_TEXT:Colorize(ChatAnnouncements.ResolveNameLink(g_groupLootIndex[formatName].characterName, g_groupLootIndex[formatName].displayName))
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

function ChatAnnouncements.OnInventoryItemUsed(eventCode, itemSoundCategory)
    local function ResetCombinedRecipe()
        g_combinedRecipe = false
        eventManager:UnregisterForUpdate(moduleName .. "ResetCombinedRecipe")
    end

    -- Trophy items used for recipe combination seem to have no itemSoundCategory.
    if itemSoundCategory == 0 then
        g_combinedRecipe = true
        eventManager:UnregisterForUpdate(moduleName .. "ResetCombinedRecipe")
        eventManager:RegisterForUpdate(moduleName .. "ResetCombinedRecipe", 150, ResetCombinedRecipe)
    end
end

-- If filter is true, we run the item through this function to determine if we should display it. Filter only gets set to true for group loot and relevant loot functions. Mail, trade, stores, etc don't apply the filter.
function ChatAnnouncements.ItemFilter(itemType, itemId, itemLink, groupLoot)
    -- If LootIgnoreFiltering is enabled and this is group loot, bypass filtering
    if groupLoot and ChatAnnouncements.SV.Inventory.LootIgnoreFiltering then
        return true
    end

    if ChatAnnouncements.SV.Inventory.LootBlacklist and g_blacklistIDs[itemId] or (ChatAnnouncements.SV.Inventory.LootLogOverride and LootLog) then
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
        if hasSet or (itemQuality >= ITEM_FUNCTIONAL_QUALITY_ARCANE and itemIsSpecial) or (itemQuality >= ITEM_FUNCTIONAL_QUALITY_ARTIFACT and not itemIsKeyFragment) or (itemType == ITEMTYPE_COSTUME) or (itemType == ITEMTYPE_DISGUISE) or g_notableIDs[itemId] then
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
    formattedArmorType = (ChatAnnouncements.SV.Inventory.LootShowArmorType and armorType ~= ARMORTYPE_NONE and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail) and string_format(" |cFFFFFF(%s)|r", GetString("SI_ARMORTYPE", armorType)) or ""

    local traitType = GetItemLinkTraitInfo(itemLink) -- Get Trait type of item
    formattedTrait = (ChatAnnouncements.SV.Inventory.LootShowTrait and traitType ~= ITEM_TRAIT_TYPE_NONE and itemType ~= ITEMTYPE_ARMOR_TRAIT and itemType ~= ITEMTYPE_WEAPON_TRAIT and itemType ~= ITEMTYPE_JEWELRY_TRAIT and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail) and string_format(" |cFFFFFF(%s)|r", GetString("SI_ITEMTRAITTYPE", traitType)) or ""

    local styleType = GetItemLinkItemStyle(itemLink) -- Get Style of the item
    local unformattedStyle = zo_strformat("<<1>>", GetItemStyleName(styleType))
    formattedStyle = (ChatAnnouncements.SV.Inventory.LootShowStyle and styleType ~= ITEMSTYLE_NONE and styleType ~= ITEMSTYLE_UNIQUE and styleType ~= ITEMSTYLE_UNIVERSAL and itemType ~= ITEMTYPE_STYLE_MATERIAL and itemType ~= ITEMTYPE_GLYPH_ARMOR and itemType ~= ITEMTYPE_GLYPH_JEWELRY and itemType ~= ITEMTYPE_GLYPH_WEAPON and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail) and string_format(" |cFFFFFF(%s)|r", unformattedStyle) or ""

    local formattedTotal = ""
    if ChatAnnouncements.SV.Inventory.LootTotal and receivedBy ~= "LUIE_INVENTORY_UPDATE_DISGUISE" and receivedBy ~= "LUIE_RECEIVE_CRAFT" and not groupLoot and (logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnRecipe and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnMotif and logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnStyle) then
        local total1, total2, total3 = GetItemLinkStacks(itemLink)
        local total = total1 + total2 + total3
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

        if g_itemStringGain ~= "" then
            g_itemStringGain = string_format("%s|c%s,|r %s", g_itemStringGain, color, itemString2)
        end
        if g_itemStringGain == "" then
            g_itemStringGain = itemString
        end

        g_itemCounterGainTracker = g_itemCounterGainTracker + 1
        if g_itemCounterGainTracker > 50 then
            g_itemStringGain = string_format("|c%s too many items to display|r", color)
        end

        if g_itemCounterGain == 0 then
            g_itemCounterGain = ChatAnnouncements.QueuedMessagesCounter
        end
        if ChatAnnouncements.QueuedMessagesCounter - 1 == g_itemCounterGain then
            ChatAnnouncements.QueuedMessagesCounter = g_itemCounterGain
        end
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        ChatAnnouncements.QueuedMessages[g_itemCounterGain] =
        {
            message = g_itemStringGain,
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
        if g_itemStringLoss ~= "" then
            g_itemStringLoss = string_format("%s|c%s,|r %s", g_itemStringLoss, color, itemString2)
        end
        if g_itemStringLoss == "" then
            g_itemStringLoss = itemString
        end

        g_itemCounterLossTracker = g_itemCounterLossTracker + 1
        if g_itemCounterLossTracker > 50 then
            g_itemStringLoss = string_format("|c%s too many items to display|r", color)
        end

        if g_itemCounterLoss == 0 then
            g_itemCounterLoss = ChatAnnouncements.QueuedMessagesCounter
        end
        if ChatAnnouncements.QueuedMessagesCounter - 1 == g_itemCounterLoss then
            ChatAnnouncements.QueuedMessagesCounter = g_itemCounterLoss
        end
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        ChatAnnouncements.QueuedMessages[g_itemCounterLoss] =
        {
            message = g_itemStringLoss,
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

-- Simple function combines our strings or modifies the prefix if RECEIVED instead of looted
function ChatAnnouncements.ResolveItemMessage(message, formattedRecipient, color, logPrefix, totalString, groupLoot)
    -- Conditions for looted/quest item rewards to adjust string prefix.
    if logPrefix == "" then
        if g_isLooted and not g_itemReceivedIsQuestReward and not g_isPickpocketed and not g_isStolen then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLoot
            -- reset variables that control looted, or at least ZO_CallLater them
        elseif g_isPickpocketed then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePickpocket
        elseif g_isStolen and not g_isPickpocketed then
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
        if logPrefix == ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade and g_oldItem ~= nil and (g_oldItem.itemLink ~= "" and g_oldItem.itemLink ~= nil) and g_oldItem.icon ~= nil then
            local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and g_oldItem.icon ~= "") and zo_strformat("<<1>> ", zo_iconFormat(g_oldItem.icon, 16, 16)) or ""
            local formattedMessageUpgrade = ("|r" .. formattedIcon .. g_oldItem.itemLink .. "|c" .. color)
            formattedMessageP1 = ("|r" .. message .. "|c" .. color)
            formattedMessageP2 = string_format(logPrefix, formattedMessageUpgrade, formattedMessageP1)
            g_oldItem = {}
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
    g_itemCounterGain = 0
    g_itemCounterGainTracker = 0
    g_itemCounterLoss = 0
    g_itemCounterLossTracker = 0
    g_itemStringGain = ""
    g_itemStringLoss = ""

    -- "You loot %s."
    -- "You receive %s."
end

-- Simple PostHook into ZOS crafting mode functions, based off MultiCraft, thanks Ayantir!
function ChatAnnouncements.CraftModeOverrides()
    -- Get SMITHING mode
    g_smithing.GetMode = LUIE.GetSmithingMode

    -- Get ENCHANTING mode
    g_enchanting.GetMode = LUIE.GetEnchantingMode

    -- NOTE: Alchemy and provisioning don't matter, as the only options are to craft and use materials.

    -- Crafting Mode Syntax (Enchanting - Item Gain)
    g_enchant_prefix_pos =
    {
        [1] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft,
        [2] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive,
        [3] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft,
    }

    -- Crafting Mode Syntax (Enchanting - Item Loss)
    g_enchant_prefix_neg =
    {
        [1] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse,
        [2] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExtract,
        [3] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse,
    }

    -- Crafting Mode Syntax (Blacksmithing - Item Gain)
    g_smithing_prefix_pos =
    {
        [1] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive,
        [2] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft,
        [3] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive,
        [4] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgrade,
        [5] = "",
        [6] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageCraft,
    }

    -- Crafting Mode Syntax (Blacksmithing - Item Loss)
    g_smithing_prefix_neg =
    {
        [1] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRefine,
        [2] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse,
        [3] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeconstruct,
        [4] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUpgradeFail,
        [5] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageResearch,
        [6] = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse,
    }
end

local delayedItemPool = {}    -- Store items we are counting up when the player loots multiple bodies at once to print combined counts for any duplicate items
local delayedItemPoolOut = {} -- Stacks for outbound delayed item pool

function ChatAnnouncements.ItemCounterDelay(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, filter, groupLoot, alwaysFirst, delay)
    -- Return if we have an invalid itemId or stack
    if itemId == 0 or not stack then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug("Item counter returned invalid items")
        -- end
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
    }

    -- Pass along all values to SendDelayedItems()
    eventManager:UnregisterForUpdate(moduleName .. "SendDelayedItems")
    eventManager:RegisterForUpdate(moduleName .. "SendDelayedItems", 25, ChatAnnouncements.SendDelayedItems)
end

function ChatAnnouncements.SendDelayedItems()
    for id, data in pairs(delayedItemPool) do
        if id then
            ChatAnnouncements.ItemPrinter(data.icon, data.stack, data.itemType, id, data.itemLink, data.receivedBy, data.logPrefix, data.gainOrLoss, data.filter, data.groupLoot, data.alwaysFirst, data.delay)
        end
    end
    -- Clear pool
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
    for id, data in pairs(delayedItemPoolOut) do
        if id then
            ChatAnnouncements.ItemPrinter(data.icon, data.stack, data.itemType, id, data.itemLink, data.receivedBy, data.logPrefix, data.gainOrLoss, data.filter, data.groupLoot, data.alwaysFirst, data.delay)
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

local function HandleNewItem(bagId, slotId, isNewItem, stackCountChange, receivedBy)
    local icon, stack = GetItemInfo(bagId, slotId)
    local itemType = GetItemType(bagId, slotId)
    local itemId = GetItemId(bagId, slotId)
    local itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])

    -- Update the global stack for this slot
    if bagId == BAG_WORN then
        g_equippedStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
    else
        g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
    end

    -- Handle special cases (disguise, mail, etc.)
    if bagId == BAG_WORN and ChatAnnouncements.SV.Inventory.LootShowDisguise and slotId == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
        local gainOrLoss = 3
        receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
        local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDisguiseEquip
        ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
    end

    -- Handle other cases (mail, dig, etc.)
    if bagId == BAG_BACKPACK then
        if not isNewItem then
            g_stackSplit = true
            eventManager:RegisterForUpdate(moduleName .. "StackTracker", 50, ChatAnnouncements.ResetStackSplit)
        end

        local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
        local logPrefix = ""
        if g_inMail then
            logPrefix = g_mailTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
        elseif g_weAreInADig then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExcavate
        elseif g_packSiege and itemType == ITEMTYPE_SIEGE then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageStow
        end

        if not g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not g_inTrade and not g_inMail then
            ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true, nil, false, true)
        end
        if g_inMail and isNewItem then
            ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, g_mailTarget, logPrefix, gainOrLoss, false)
        end
    end
end

local function GetItemDetails(bagId, slotId)
    local icon, stack, itemType, itemId, itemLink, removed

    -- Get current itemLink to determine if item still exists
    local currentItemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])

    -- Storage table to use based on bag type
    local storageTable = (bagId == BAG_WORN) and g_equippedStacks or g_inventoryStacks

    if currentItemLink == nil or currentItemLink == "" then
        -- Item was removed/destroyed, use saved values
        icon = storageTable[slotId].icon
        stack = storageTable[slotId].stack
        itemType = storageTable[slotId].itemType
        itemId = storageTable[slotId].itemId
        itemLink = storageTable[slotId].itemLink
        removed = true
    else
        -- Item still exists, get current values
        icon, stack = GetItemInfo(bagId, slotId)
        itemType = GetItemType(bagId, slotId)
        itemId = GetItemId(bagId, slotId)
        itemLink = currentItemLink
        removed = false
    end

    return icon, stack, itemType, itemId, itemLink, removed
end


local function HandleItemUsage(icon, change, itemType, itemId, itemLink, receivedBy)
    local flag = false
    local gainOrLoss, logPrefix

    -- Check consumable potions
    if ChatAnnouncements.SV.Inventory.LootShowUsePotion and itemType == ITEMTYPE_POTION then
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessagePotion
        flag = true
    end

    -- Check consumable food
    if ChatAnnouncements.SV.Inventory.LootShowUseFood and itemType == ITEMTYPE_FOOD then
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFood
        flag = true
    end

    -- Check consumable drinks
    if ChatAnnouncements.SV.Inventory.LootShowUseDrink and itemType == ITEMTYPE_DRINK then
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDrink
        flag = true
    end

    -- Check repair kits
    if ChatAnnouncements.SV.Inventory.LootShowUseRepairKit and (itemType == ITEMTYPE_TOOL or itemType == ITEMTYPE_CROWN_REPAIR or itemType == ITEMTYPE_AVA_REPAIR or itemType == ITEMTYPE_GROUP_REPAIR) then
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
        flag = true
    end

    -- Check soul gems
    if ChatAnnouncements.SV.Inventory.LootShowUseSoulGem and itemType == ITEMTYPE_SOUL_GEM then
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
        flag = true
    end

    -- Check siege weapons
    if ChatAnnouncements.SV.Inventory.LootShowUseSiege and itemType == ITEMTYPE_SIEGE then
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeploy
        flag = true
    end

    -- Check fish
    if ChatAnnouncements.SV.Inventory.LootShowUseFish and itemType == ITEMTYPE_FISH then
        gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
        flag = true
    end

    -- Special handling for respec scrolls
    if itemType == ITEMTYPE_CROWN_ITEM then
        -- Skill respec scroll
        if itemId == 64524 or itemId == 135128 then
            LUIE_CallLater(function ()
                ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_SKILLS)
            end, 25)
        end

        -- Attribute respec scroll
        if itemId == 64523 or itemId == 135130 then
            LUIE_CallLater(function ()
                ChatAnnouncements.PointRespecDisplay(RESPEC_TYPE_ATTRIBUTES)
            end, 25)
        end
    end

    -- Check miscellaneous items
    if ChatAnnouncements.SV.Inventory.LootShowUseMisc and (itemType == ITEMTYPE_RECALL_STONE or itemType == ITEMTYPE_TROPHY or itemType == ITEMTYPE_MASTER_WRIT or itemType == ITEMTYPE_CROWN_ITEM) then
        -- Check to make sure the items aren't riding lesson books
        if not crownRidingIds[itemId] then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse
            flag = true
        end
    end

    -- Check recipe learning
    if ChatAnnouncements.SV.Inventory.LootShowRecipe and itemType == ITEMTYPE_RECIPE then
        -- Show recipe message if a recipe is learned
        if not g_combinedRecipe then
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

    -- Check motif learning
    if ChatAnnouncements.SV.Inventory.LootShowMotif and itemType == ITEMTYPE_RACIAL_STYLE_MOTIF then
        gainOrLoss = 4
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnMotif
        flag = true
    end

    -- Check style page learning (collectible)
    if ChatAnnouncements.SV.Inventory.LootShowStylePage and itemType == ITEMTYPE_COLLECTIBLE then
        -- Don't display a message if the specialized item type is not "Collectible Style Page"
        local _, specializedType = GetItemLinkItemType(itemLink)
        if specializedType == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then
            gainOrLoss = 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnStyle
            flag = true
        end
    end

    -- Check style page learning (container)
    if ChatAnnouncements.SV.Inventory.LootShowStylePage and itemType == ITEMTYPE_CONTAINER then
        -- Don't display a message if the specialized item type is not "Container Style Page"
        local _, specializedType = GetItemLinkItemType(itemLink)
        if specializedType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then
            gainOrLoss = 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLearnStyle
            flag = true
        end
    end

    -- If any of these options were flagged, run a callLater
    if flag then
        LUIE_CallLater(function ()
            if g_stackSplit == false then
                ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, false, true, false)
                eventManager:UnregisterForUpdate(moduleName .. "Printer")
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
        end, 25)
    end
end


local function HandleItemRemoved(bagId, slotId, stackCountChange, receivedBy, itemDetails)
    local change = stackCountChange * -1
    local icon, itemType, itemId, itemLink = itemDetails.icon, itemDetails.itemType, itemDetails.itemId, itemDetails.itemLink
    local gainOrLoss, logPrefix

    -- Handle BAG_WORN specific cases
    if bagId == BAG_WORN then
        if g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
            ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
        elseif not g_itemWasDestroyed then
            if ChatAnnouncements.SV.Inventory.LootShowDisguise and slotId == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
                if IsUnitInCombat("player") then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDisguiseDestroy
                    receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                else
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDisguiseRemove
                    receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
                    gainOrLoss = 3
                end
                ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            elseif not g_itemWasDestroyed and g_removableIDs[itemId] and ChatAnnouncements.SV.Inventory.LootShowRemove then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRemove
                ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
        end
        return
    end

    -- Handle BAG_BACKPACK specific cases
    if bagId == BAG_BACKPACK then
        -- Check Destroyed first
        if g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
            ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            return
        end

        -- Check Lockpick next
        if ChatAnnouncements.SV.Inventory.LootShowLockpick and g_lockpickBroken then
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageLockpick
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            return
        end

        -- Check container is emptied next
        if ChatAnnouncements.SV.Inventory.LootShowContainer and (itemType == ITEMTYPE_CONTAINER or itemType == ITEMTYPE_CONTAINER_CURRENCY) then
            -- Don't display a message if the specialized item type is a "Container Style Page"
            local _, specializedType = GetItemLinkItemType(itemLink)
            if specializedType ~= SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE then
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageContainer
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true)
            end
            return
        end

        -- Check quest item turn-in
        if g_talkingToNPC and not g_weAreInAStore and ChatAnnouncements.SV.Inventory.LootShowTurnIn then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageQuestTurnIn
            LUIE_CallLater(function ()
                if g_stackSplit == false then
                    ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, false, true, false)
                    eventManager:UnregisterForUpdate(moduleName .. "Printer")
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end
            end, 25)
            return
        end

        -- Check guild store listing
        if g_weAreInAGuildStore and ChatAnnouncements.SV.Inventory.LootShowList then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageList
            g_savedItem = { icon = icon, stack = change, itemLink = itemLink }
            return
        end

        -- Check item usage
        if not g_itemWasDestroyed and not g_talkingToNPC and not g_inTrade and not g_inMail then
            HandleItemUsage(icon, change, itemType, itemId, itemLink, receivedBy)
            return
        end

        -- For any leftover cases for items removed
        if not g_itemWasDestroyed and g_removableIDs[itemId] and ChatAnnouncements.SV.Inventory.LootShowRemove then
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageRemove
            ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
        end
    end
end

local function HandleStackCountUp(bagId, slotId, isNewItem, stackCountChange, receivedBy, itemDetails)
    local icon, itemType, itemId, itemLink = itemDetails.icon, itemDetails.itemType, itemDetails.itemId, itemDetails.itemLink

    -- Flag stack split as true - this will occur when two items are stacked together
    if not isNewItem then
        g_stackSplit = true
        eventManager:RegisterForUpdate(moduleName .. "StackTracker", 50, ChatAnnouncements.ResetStackSplit)
    end

    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
    local logPrefix = ""

    if g_inMail then
        logPrefix = g_mailTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
    elseif g_weAreInADig then
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExcavate
    elseif g_packSiege and itemType == ITEMTYPE_SIEGE then
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageStow
    end

    if not g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not g_inTrade and not g_inMail then
        ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true, nil, false, true)
    end

    if g_inMail and isNewItem then
        ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, g_mailTarget, logPrefix, gainOrLoss, false)
    end
end

local function HandleExistingItem(bagId, slotId, isNewItem, stackCountChange, receivedBy)
    -- Get item details
    local icon, stack, itemType, itemId, itemLink, removed = GetItemDetails(bagId, slotId)
    local itemDetails =
    {
        icon = icon,
        stack = stack,
        itemType = itemType,
        itemId = itemId,
        itemLink = itemLink
    }

    -- Handle based on stack count change
    if stackCountChange == 0 then
        -- STACK COUNT REMAINED THE SAME (GEAR SWAPPED)
        if bagId == BAG_WORN and ChatAnnouncements.SV.Inventory.LootShowDisguise and slotId == EQUIP_SLOT_COSTUME and (itemType == ITEMTYPE_COSTUME or itemType == ITEMTYPE_DISGUISE) then
            local gainOrLoss = 3
            receivedBy = "LUIE_INVENTORY_UPDATE_DISGUISE"
            local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDisguiseEquip
            ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
        end
    elseif stackCountChange > 0 then
        -- STACK COUNT INCREMENTED UP
        HandleStackCountUp(bagId, slotId, isNewItem, stackCountChange, receivedBy, itemDetails)
    elseif stackCountChange < 0 then
        -- STACK COUNT INCREMENTED DOWN
        HandleItemRemoved(bagId, slotId, stackCountChange, receivedBy, itemDetails)
    end

    -- Update stored stacks
    if removed then
        if bagId == BAG_WORN and g_equippedStacks[slotId] then
            g_equippedStacks[slotId] = nil
        elseif bagId == BAG_BACKPACK and g_inventoryStacks[slotId] then
            g_inventoryStacks[slotId] = nil
        end
    else
        if bagId == BAG_WORN then
            g_equippedStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
        else
            g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
        end
    end
end

local function HandleVirtualBag(slotId, isNewItem, stackCountChange, receivedBy)
    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
    local logPrefix = ""

    if g_inMail then
        logPrefix = g_mailTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageMailInNoName
    elseif g_weAreInADig then
        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageExcavate
    end

    local itemLink = tostring(ChatAnnouncements.GetItemLinkFromItemId(slotId))
    local icon = GetItemLinkInfo(itemLink)
    local itemType = GetItemLinkItemType(itemLink)
    local itemId = slotId
    local itemQuality = GetItemLinkFunctionalQuality(itemLink)

    if not g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot and isNewItem and not g_inTrade and not g_inMail then
        ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true, nil, false, true)
    end

    if g_inMail and isNewItem then
        ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, g_mailTarget, logPrefix, gainOrLoss, false)
    end
end

function ChatAnnouncements.InventoryUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update:\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotId: " .. tostring(slotId) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange)
    --     Debug(traceback)
    -- end

    -- End right now if this is any other reason (durability loss, etc)
    if inventoryUpdateReason ~= INVENTORY_UPDATE_REASON_DEFAULT then
        return
    end

    -- Handle stolen items
    if IsItemStolen(bagId, slotId) then
        g_isStolen = true
        local function ResetIsStolen()
            g_isStolen = false
            eventManager:UnregisterForUpdate(moduleName .. "ResetStolen")
        end
        eventManager:UnregisterForUpdate(moduleName .. "ResetStolen")
        eventManager:RegisterForUpdate(moduleName .. "ResetStolen", 150, ResetIsStolen)
    end

    local receivedBy = ""

    -- Handle different bag types with appropriate helper functions
    if bagId == BAG_WORN or bagId == BAG_BACKPACK then
        local storageTable = (bagId == BAG_WORN) and g_equippedStacks or g_inventoryStacks

        -- Handle new items
        if not storageTable[slotId] then
            HandleNewItem(bagId, slotId, isNewItem, stackCountChange, receivedBy)
            -- Handle existing items
        else
            HandleExistingItem(bagId, slotId, isNewItem, stackCountChange, receivedBy)
        end
        -- Handle virtual bag items
    elseif bagId == BAG_VIRTUAL then
        HandleVirtualBag(slotId, isNewItem, stackCountChange, receivedBy)
    end

    -- Reset global flags at the end
    g_itemWasDestroyed = false
    g_lockpickBroken = false
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
        "|c0b610bYou craft |r|t16:16:/esoui/art/icons/crafting_smith_plug_standard_r_001.dds|t |H1:item:6000:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Dwarven Ingot]|h |cFFFFFFx33|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ore_base_ebony_r3.dds|t |H1:item:6001:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Ebony Ingot]|h |cFFFFFFx232|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ore_base_iron_r3.dds|t |H1:item:23107:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Orichalcum Ingot]|h |cFFFFFFx12|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ore_base_iron_r2.dds|t |H1:item:5413:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Iron Ingot]|h |cFFFFFFx134|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ore_base_high_iron_r3.dds|t |H1:item:4487:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Steel Ingot]|h |cFFFFFFx83|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_colossus_iron.dds|t |H1:item:64489:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Rubedite Ingot]|h |cFFFFFFx91|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_wood_base_oak_r3.dds|t |H1:item:533:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Sanded Oak]|h |cFFFFFFx91|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ingot_voidstone.dds|t |H1:item:46130:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Voidstone Ingot]|h |cFFFFFFx58|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ingot_moonstone.dds|t |H1:item:46129:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Quicksilver Ingot]|h |cFFFFFFx44|r|c0b610b,|r |t16:16:/esoui/art/icons/crafting_ingot_galatite.dds|t |H1:item:46128:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h[Galatite Ingot]|h |cFFFFFFx73|r|c0b610b.|r")

    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 803, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 24)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 23121, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 78)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 23122, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 56)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 23123, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 33)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46139, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 131)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46140, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 215)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46141, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 80)
    -- LUIE.ChatAnnouncements.InventoryUpdateCraft(0, BAG_VIRTUAL, 46142, true, nil, INVENTORY_UPDATE_REASON_DEFAULT, 66)
end

function ChatAnnouncements.InventoryUpdateCraft(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update:\n" ..
    --         "--> eventCode: " .. tostring(eventCode) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotId: " .. tostring(slotId) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange)
    --     Debug(traceback)
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
        logPrefixPos = g_enchant_prefix_pos[g_enchanting.GetMode()]
        logPrefixNeg = g_enchant_prefix_neg[g_enchanting.GetMode()]
    end
    if GetCraftingInteractionType() == CRAFTING_TYPE_BLACKSMITHING or GetCraftingInteractionType() == CRAFTING_TYPE_CLOTHIER or GetCraftingInteractionType() == CRAFTING_TYPE_WOODWORKING or GetCraftingInteractionType() == CRAFTING_TYPE_JEWELRYCRAFTING then
        logPrefixPos = g_smithing_prefix_pos[g_smithing.GetMode()]
        logPrefixNeg = g_smithing_prefix_neg[g_smithing.GetMode()]
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
        if not g_equippedStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_equippedStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            -- EXISTING ITEM
        elseif g_equippedStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_equippedStacks[slotId].icon
                stack = g_equippedStacks[slotId].stack
                itemType = g_equippedStacks[slotId].itemType
                itemId = g_equippedStacks[slotId].itemId
                itemLink = g_equippedStacks[slotId].itemLink
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
                g_oldItem = { itemLink = g_equippedStacks[slotId].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                end
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ResolveCraftingUsed(itemType) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or logPrefixNeg
                if logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    if itemType == ITEMTYPE_FISH then
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
                    end
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if g_equippedStacks[slotId] then
                    g_equippedStacks[slotId] = nil
                end
            else
                g_equippedStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
        if not g_inventoryStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
            -- EXISTING ITEM
        elseif g_inventoryStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            -- For item removal, we save whatever the currently indexed item is here.
            local removedIcon = g_inventoryStacks[slotId].icon
            local removedItemType = g_inventoryStacks[slotId].itemType
            local removedItemId = g_inventoryStacks[slotId].itemId
            local removedItemLink = g_inventoryStacks[slotId].itemLink
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_inventoryStacks[slotId].icon
                stack = g_inventoryStacks[slotId].stack
                itemType = g_inventoryStacks[slotId].itemType
                itemId = g_inventoryStacks[slotId].itemId
                itemLink = g_inventoryStacks[slotId].itemLink
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
                g_oldItem = { itemLink = g_inventoryStacks[slotId].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
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
                    ChatAnnouncements.ItemCounterDelay(removedIcon, change, removedItemType, removedItemId, removedItemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
                end
            end

            if removed then
                if g_inventoryStacks[slotId] then
                    g_inventoryStacks[slotId] = nil
                end
            else
                g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
        if not g_bankStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_bankStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            -- EXISTING ITEM
        elseif g_bankStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_bankStacks[slotId].icon
                stack = g_bankStacks[slotId].stack
                itemType = g_bankStacks[slotId].itemType
                itemId = g_bankStacks[slotId].itemId
                itemLink = g_bankStacks[slotId].itemLink
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
                g_oldItem = { itemLink = g_bankStacks[slotId].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
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
                    ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
                end
            end

            if removed then
                if g_bankStacks[slotId] then
                    g_bankStacks[slotId] = nil
                end
            else
                g_bankStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
        if not g_bankSubscriberStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_bankSubscriberStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = logPrefixPos
            ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            -- EXISTING ITEM
        elseif g_bankSubscriberStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_bankSubscriberStacks[slotId].icon
                stack = g_bankSubscriberStacks[slotId].stack
                itemType = g_bankSubscriberStacks[slotId].itemType
                itemId = g_bankSubscriberStacks[slotId].itemId
                itemLink = g_bankSubscriberStacks[slotId].itemLink
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
                g_oldItem = { itemLink = g_bankSubscriberStacks[slotId].itemLink, icon = icon }
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                -- STACK COUNT INCREMENTED UP
            elseif stackCountChange > 0 then
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                logPrefix = logPrefixPos
                if itemId == 33753 then
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageReceive
                end
                -- ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                ChatAnnouncements.ItemCounterDelay(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, false, true)
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                logPrefix = ResolveCraftingUsed(itemType) and ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or logPrefixNeg
                if logPrefix ~= ChatAnnouncements.SV.ContextMessages.CurrencyMessageUse or ChatAnnouncements.SV.Inventory.LootShowCraftUse then -- If the logprefix isn't (used) then this is a deconstructed message, otherwise only display if used item display is enabled.
                    if itemType == ITEMTYPE_FISH then
                        logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageFillet
                    end
                    ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, true, true)
                end
            end

            if removed then
                if g_bankSubscriberStacks[slotId] then
                    g_bankSubscriberStacks[slotId] = nil
                end
            else
                g_bankSubscriberStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
            ChatAnnouncements.ItemCounterDelay(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false, nil, alwaysFirst, true)
        end
    end

    g_itemWasDestroyed = false
    g_lockpickBroken = false
end

function ChatAnnouncements.InventoryUpdateBank(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update:\n" ..
    --         "--> eventCode: " .. tostring(eventCode) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotId: " .. tostring(slotId) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange)
    --     Debug(traceback)
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
        if not g_inventoryStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = g_bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdraw or ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawStorage
            if g_InventoryOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif g_inventoryStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_inventoryStacks[slotId].icon
                stack = g_inventoryStacks[slotId].stack
                itemType = g_inventoryStacks[slotId].itemType
                itemId = g_inventoryStacks[slotId].itemId
                itemLink = g_inventoryStacks[slotId].itemLink
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
                logPrefix = g_bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdraw or ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawStorage
                if g_InventoryOn then
                    ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if g_InventoryOn and not g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = g_bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit or ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if g_inventoryStacks[slotId] then
                    g_inventoryStacks[slotId] = nil
                end
            else
                g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not g_itemWasDestroyed then
                g_bankOn = true
            end
            if not g_itemWasDestroyed then
                g_InventoryOn = false
            end
            if not g_itemWasDestroyed then
                LUIE_CallLater(ChatAnnouncements.BankFixer, 50)
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
        if not g_bankStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_bankStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
            if g_bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif g_bankStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_bankStacks[slotId].icon
                stack = g_bankStacks[slotId].stack
                itemType = g_bankStacks[slotId].itemType
                itemId = g_bankStacks[slotId].itemId
                itemLink = g_bankStacks[slotId].itemLink
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
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
                if g_bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if g_bankOn and not g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if g_bankStacks[slotId] then
                    g_bankStacks[slotId] = nil
                end
            else
                g_bankStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not g_itemWasDestroyed then
                g_InventoryOn = true
            end
            if not g_itemWasDestroyed then
                g_bankOn = false
            end
            if not g_itemWasDestroyed then
                LUIE_CallLater(ChatAnnouncements.BankFixer, 50)
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
        if not g_bankSubscriberStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_bankSubscriberStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
            if g_bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif g_bankSubscriberStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_bankSubscriberStacks[slotId].icon
                stack = g_bankSubscriberStacks[slotId].stack
                itemType = g_bankSubscriberStacks[slotId].itemType
                itemId = g_bankSubscriberStacks[slotId].itemId
                itemLink = g_bankSubscriberStacks[slotId].itemLink
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
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
                if g_bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if g_bankOn and not g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if g_bankSubscriberStacks[slotId] then
                    g_bankSubscriberStacks[slotId] = nil
                end
            else
                g_bankSubscriberStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not g_itemWasDestroyed then
                g_InventoryOn = true
            end
            if not g_itemWasDestroyed then
                g_bankOn = false
            end
            if not g_itemWasDestroyed then
                LUIE_CallLater(ChatAnnouncements.BankFixer, 50)
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
        if not g_houseBags[bagId][slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_houseBags[bagId][slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
            if g_bankOn then
                ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
            -- EXISTING ITEM
        elseif g_houseBags[bagId][slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_houseBags[bagId][slotId].icon
                stack = g_houseBags[bagId][slotId].stack
                itemType = g_houseBags[bagId][slotId].itemType
                itemId = g_houseBags[bagId][slotId].itemId
                itemLink = g_houseBags[bagId][slotId].itemLink
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
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
                if g_bankOn then
                    ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if g_bankOn and not g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end

            if removed then
                if g_houseBags[bagId][slotId] then
                    g_houseBags[bagId][slotId] = nil
                end
            else
                g_houseBags[bagId][slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end

            if not g_itemWasDestroyed then
                g_InventoryOn = true
            end
            if not g_itemWasDestroyed then
                g_bankOn = false
            end
            if not g_itemWasDestroyed then
                LUIE_CallLater(ChatAnnouncements.BankFixer, 50)
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
            logPrefix = g_bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageDeposit or ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositStorage
            stack = stackCountChange * -1
        else
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = g_bankBag == 1 and ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdraw or ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawStorage
            stack = stackCountChange
        end

        ChatAnnouncements.ItemPrinter(icon, stack, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
    end

    g_itemWasDestroyed = false
    g_lockpickBroken = false
end

function ChatAnnouncements.InventoryUpdateGuildBank(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update:\n" ..
    --         "--> eventCode: " .. tostring(eventCode) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotId: " .. tostring(slotId) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange)
    --     Debug(traceback)
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

        if not g_inventoryStacks[slotId] then -- NEW ITEM
            local icon1, stack1 = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_inventoryStacks[slotId] = { icon = icon1, stack = stack1, itemId = itemId, itemType = itemType, itemLink = itemLink }
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawGuild
            g_guildBankCarry = {}
            g_guildBankCarry.icon = icon1
            g_guildBankCarry.stack = stack1
            g_guildBankCarry.gainOrLoss = gainOrLoss
            g_guildBankCarry.logPrefix = logPrefix
            g_guildBankCarry.receivedBy = receivedBy
            g_guildBankCarry.itemLink = itemLink
            g_guildBankCarry.itemId = itemId
            g_guildBankCarry.itemType = itemType
        elseif g_inventoryStacks[slotId] then -- EXISTING ITEM
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_inventoryStacks[slotId].icon
                stack = g_inventoryStacks[slotId].stack
                itemType = g_inventoryStacks[slotId].itemType
                itemId = g_inventoryStacks[slotId].itemId
                itemLink = g_inventoryStacks[slotId].itemLink
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
                logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawGuild
                g_guildBankCarry = {}
                g_guildBankCarry.icon = icon
                g_guildBankCarry.stack = stack
                g_guildBankCarry.gainOrLoss = gainOrLoss
                g_guildBankCarry.logPrefix = logPrefix
                g_guildBankCarry.receivedBy = receivedBy
                g_guildBankCarry.itemLink = itemLink
                g_guildBankCarry.itemId = itemId
                g_guildBankCarry.itemType = itemType
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
                if not g_itemWasDestroyed then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositGuild
                    g_guildBankCarry = {}
                    g_guildBankCarry.icon = icon
                    g_guildBankCarry.stack = stack
                    g_guildBankCarry.gainOrLoss = gainOrLoss
                    g_guildBankCarry.logPrefix = logPrefix
                    g_guildBankCarry.receivedBy = receivedBy
                    g_guildBankCarry.itemLink = itemLink
                    g_guildBankCarry.itemId = itemId
                    g_guildBankCarry.itemType = itemType
                end
            end

            if removed then
                if g_inventoryStacks[slotId] then
                    g_inventoryStacks[slotId] = nil
                end
            else
                g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
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
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDepositGuild
            stack = stackCountChange * -1
        else
            gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
            logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageWithdrawGuild
            stack = stackCountChange
        end

        g_guildBankCarry = {}
        g_guildBankCarry.icon = icon
        g_guildBankCarry.stack = stack
        g_guildBankCarry.gainOrLoss = gainOrLoss
        g_guildBankCarry.logPrefix = logPrefix
        g_guildBankCarry.receivedBy = receivedBy
        g_guildBankCarry.itemLink = itemLink
        g_guildBankCarry.itemId = itemId
        g_guildBankCarry.itemType = itemType
        g_guildBankCarry.itemQuality = itemQuality
    end

    g_itemWasDestroyed = false
    g_lockpickBroken = false
end

function ChatAnnouncements.InventoryUpdateFence(eventCode, bagId, slotId, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Inventory Update:\n" ..
    --         "--> eventCode: " .. tostring(eventCode) .. "\n" ..
    --         "--> bagId: " .. tostring(bagId) .. "\n" ..
    --         "--> slotId: " .. tostring(slotId) .. "\n" ..
    --         "--> isNewItem: " .. tostring(isNewItem) .. "\n" ..
    --         "--> itemSoundCategory: " .. tostring(itemSoundCategory) .. "\n" ..
    --         "--> inventoryUpdateReason: " .. tostring(inventoryUpdateReason) .. "\n" ..
    --         "--> stackCountChange: " .. tostring(stackCountChange)
    --     Debug(traceback)
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
        if not g_inventoryStacks[slotId] then
            icon, stack = GetItemInfo(bagId, slotId)
            itemType = GetItemType(bagId, slotId)
            itemId = GetItemId(bagId, slotId)
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            -- EXISTING ITEM
        elseif g_inventoryStacks[slotId] then
            itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
            if itemLink == nil or itemLink == "" then
                -- If we get a nil or blank item link, the item was destroyed and we need to use the saved value here to fill in the blanks
                icon = g_inventoryStacks[slotId].icon
                stack = g_inventoryStacks[slotId].stack
                itemType = g_inventoryStacks[slotId].itemType
                itemId = g_inventoryStacks[slotId].itemId
                itemLink = g_inventoryStacks[slotId].itemLink
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
                logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunder or ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunderNoV
                if not g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
                    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                        changeColor = ColorizeColors.CurrencyColorize:ToHex()
                    end
                    local messageType = "LUIE_CURRENCY_VENDOR"

                    local parts = { ZO_LinkHandler_ParseLink(itemLink) }
                    parts[22] = "1"
                    local partss = table_concat(parts, ":"):sub(2, -1)
                    itemLink = zo_strformat("|H<<1>>|h|h", partss)

                    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
                    local itemCount = stack > 1 and (" |cFFFFFFx" .. stack .. "|r") or ""
                    local carriedItem = (formattedIcon .. itemLink .. itemCount)
                    local carriedItemTotal = ""
                    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                        local total1, total2, total3 = GetItemLinkStacks(itemLink)
                        local total = total1 + total2 + total3
                        if total >= 1 then
                            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        end
                    end

                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                        g_savedPurchase.changeColor = changeColor
                        g_savedPurchase.messageChange = logPrefix
                        g_savedPurchase.messageType = messageType
                        g_savedPurchase.carriedItem = carriedItem
                        g_savedPurchase.carriedItemTotal = carriedItemTotal
                    else
                        g_savedLaunder =
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
                --[[                 if not g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
                    --ChatAnnouncements.ItemPrinter(icon, stackCountChange, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, true)
                end ]]
                -- STACK COUNT INCREMENTED DOWN
            elseif stackCountChange < 0 then
                local change = stackCountChange * -1
                if g_itemWasDestroyed and ChatAnnouncements.SV.Inventory.LootShowDestroy then
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageDestroy
                    ChatAnnouncements.ItemPrinter(icon, change, itemType, itemId, itemLink, receivedBy, logPrefix, gainOrLoss, false)
                else
                    gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunder or ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunderNoV
                    local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                        changeColor = ColorizeColors.CurrencyColorize:ToHex()
                    end
                    local messageType = "LUIE_CURRENCY_VENDOR"

                    local parts = { ZO_LinkHandler_ParseLink(itemLink) }
                    parts[22] = "1"
                    local partss = table_concat(parts, ":"):sub(2, -1)
                    itemLink = zo_strformat("|H<<1>>|h|h", partss)

                    local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
                    local itemCount = stack > 1 and (" |cFFFFFFx" .. stack .. "|r") or ""
                    local carriedItem = (formattedIcon .. itemLink .. itemCount)
                    local carriedItemTotal = ""
                    if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                        local total1, total2, total3 = GetItemLinkStacks(itemLink)
                        local total = total1 + total2 + total3
                        if total >= 1 then
                            carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                        end
                    end

                    if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                        g_savedPurchase.changeColor = changeColor
                        g_savedPurchase.messageChange = logPrefix
                        g_savedPurchase.messageType = messageType
                        g_savedPurchase.carriedItem = carriedItem
                        g_savedPurchase.carriedItemTotal = carriedItemTotal
                    else
                        g_savedLaunder =
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
                if g_inventoryStacks[slotId] then
                    g_inventoryStacks[slotId] = nil
                end
            else
                g_inventoryStacks[slotId] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end
    end

    if bagId == BAG_VIRTUAL then
        local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
        local logPrefix = ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunder or ChatAnnouncements.SV.ContextMessages.CurrencyMessageLaunderNoV
        local itemLink = GetItemLink(bagId, slotId, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
        local icon = GetItemLinkInfo(itemLink)
        local itemType = GetItemLinkItemType(itemLink)
        local itemId = slotId
        local itemQuality = GetItemLinkFunctionalQuality(itemLink)

        if not g_weAreInAStore and ChatAnnouncements.SV.Inventory.Loot then
            local change = stackCountChange > 0 and stackCountChange or stackCountChange * -1
            local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
            if ChatAnnouncements.SV.Inventory.LootVendorCurrency and ChatAnnouncements.SV.Currency.CurrencyContextMergedColor then
                changeColor = ColorizeColors.CurrencyColorize:ToHex()
            end
            local messageType = "LUIE_CURRENCY_VENDOR"

            local parts = { ZO_LinkHandler_ParseLink(itemLink) }
            parts[22] = "1"
            local partss = table_concat(parts, ":"):sub(2, -1)
            itemLink = zo_strformat("|H<<1>>|h|h", partss)

            local formattedIcon = (ChatAnnouncements.SV.Inventory.LootIcons and icon and icon ~= "") and ("|t16:16:" .. icon .. "|t ") or ""
            local itemCount = stackCountChange > 1 and (" |cFFFFFFx" .. stackCountChange .. "|r") or ""
            local carriedItem = (formattedIcon .. itemLink .. itemCount)
            local carriedItemTotal = ""
            if ChatAnnouncements.SV.Inventory.LootVendorTotalItems then
                local total1, total2, total3 = GetItemLinkStacks(itemLink)
                local total = total1 + total2 + total3
                if total >= 1 then
                    carriedItemTotal = string_format(" |c%s%s|r %s|cFFFFFF%s|r", changeColor, ChatAnnouncements.SV.Inventory.LootTotalString, formattedIcon, ZO_CommaDelimitDecimalNumber(total))
                end
            end

            if ChatAnnouncements.SV.Inventory.LootVendorCurrency then
                g_savedPurchase.changeColor = changeColor
                g_savedPurchase.messageChange = logPrefix
                g_savedPurchase.messageType = messageType
                g_savedPurchase.carriedItem = carriedItem
                g_savedPurchase.carriedItemTotal = carriedItemTotal
            else
                g_savedLaunder =
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

    g_itemWasDestroyed = false
    g_lockpickBroken = false
end

-- Makes it so bank withdraw/deposit events only occur when we can confirm the item is crossing over.
function ChatAnnouncements.BankFixer()
    g_InventoryOn = false
    g_bankOn = false
end

function ChatAnnouncements.JusticeStealRemove(eventCode)
    LUIE_CallLater(ChatAnnouncements.JusticeRemovePrint, 50)
end

function ChatAnnouncements.JusticeDisplayConfiscate()
    local function getConfiscateMessage()
        if g_itemsConfiscated then
            return GetString(LUIE_STRING_CA_JUSTICE_CONFISCATED_BOUNTY_ITEMS_MSG)
        else
            return GetString(LUIE_STRING_CA_JUSTICE_CONFISCATED_MSG)
        end
    end
    if ChatAnnouncements.SV.Notify.NotificationConfiscateCA or ChatAnnouncements.SV.Notify.NotificationConfiscateAlert then
        local ConfiscateMessage = getConfiscateMessage()
        if ChatAnnouncements.SV.Notify.NotificationConfiscateCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = ConfiscateMessage, messageType = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        else
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, ConfiscateMessage)
        end
    end
    g_itemsConfiscated = false
end

function ChatAnnouncements.JusticeRemovePrint()
    g_itemsConfiscated = true

    -- PART 1 -- INVENTORY
    if ChatAnnouncements.SV.Inventory.LootConfiscate then
        local bagsize = GetBagSize(BAG_BACKPACK)

        -- First pass: Build current inventory state
        for i = 0, bagsize do
            local icon, stack = GetItemInfo(BAG_BACKPACK, i)
            local itemType = GetItemType(BAG_BACKPACK, i)
            local itemId = GetItemId(BAG_BACKPACK, i)
            local itemLink = GetItemLink(BAG_BACKPACK, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])

            if itemLink ~= "" then
                g_JusticeStacks[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end

        -- Second pass: Compare with previous inventory state
        for i = 0, bagsize do
            local inventoryitem = g_inventoryStacks[i]
            local justiceitem = g_JusticeStacks[i]
            if inventoryitem ~= nil and justiceitem == nil then
                local receivedBy = ""
                local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
                ChatAnnouncements.ItemPrinter(inventoryitem.icon, inventoryitem.stack, inventoryitem.itemType, inventoryitem.itemId, inventoryitem.itemLink, receivedBy, logPrefix, gainOrLoss, false)
            end
        end

        -- Reset Justice Stacks to reuse for equipped
        g_JusticeStacks = {}

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
            local itemLink = GetItemLink(BAG_WORN, i, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])

            if itemLink ~= "" then
                currentEquippedItems[i] = { icon = icon, stack = stack, itemId = itemId, itemType = itemType, itemLink = itemLink }
            end
        end

        -- Compare equipped items
        for i = 0, bagsize do
            -- Skip weapon slots - we'll handle those separately
            if i ~= MAIN_HAND_SLOT and i ~= OFF_HAND_SLOT and
            i ~= BACKUP_MAIN_SLOT and i ~= BACKUP_OFF_SLOT then
                local previousItem = g_equippedStacks[i]
                local currentItem = currentEquippedItems[i]

                if previousItem ~= nil and currentItem == nil then
                    local receivedBy = ""
                    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
                    ChatAnnouncements.ItemPrinter(previousItem.icon, previousItem.stack, previousItem.itemType, previousItem.itemId, previousItem.itemLink, receivedBy, logPrefix, gainOrLoss, false)
                end
            end
        end

        -- Handle weapon slots
        local activeMain = (activeWeaponPair == 1) and MAIN_HAND_SLOT or BACKUP_MAIN_SLOT
        local activeOff = (activeWeaponPair == 1) and OFF_HAND_SLOT or BACKUP_OFF_SLOT

        -- Check if active main hand was confiscated
        local previousActiveMain = g_equippedStacks[activeMain]
        local currentActiveMain = currentEquippedItems[activeMain]
        if previousActiveMain ~= nil and currentActiveMain == nil then
            local receivedBy = ""
            local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
            ChatAnnouncements.ItemPrinter(previousActiveMain.icon, previousActiveMain.stack, previousActiveMain.itemType, previousActiveMain.itemId, previousActiveMain.itemLink, receivedBy, logPrefix, gainOrLoss, false)
        end

        -- Check if active off hand was confiscated
        local previousActiveOff = g_equippedStacks[activeOff]
        local currentActiveOff = currentEquippedItems[activeOff]
        if previousActiveOff ~= nil and currentActiveOff == nil then
            local receivedBy = ""
            local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
            local logPrefix = ChatAnnouncements.SV.ContextMessages.CurrencyMessageConfiscate
            ChatAnnouncements.ItemPrinter(previousActiveOff.icon, previousActiveOff.stack, previousActiveOff.itemType, previousActiveOff.itemId, previousActiveOff.itemLink, receivedBy, logPrefix, gainOrLoss, false)
        end
    end

    g_JusticeStacks = {} -- Clear the Justice Item Stacks since we don't need this for anything else!
    g_equippedStacks = {}
    g_inventoryStacks = {}
    ChatAnnouncements.IndexEquipped()
    ChatAnnouncements.IndexInventory() -- Reindex the inventory with the correct values!
end

function ChatAnnouncements.DisguiseState(eventCode, unitTag, disguiseState)
    -- if LUIE.IsDevDebugEnabled() then
    --     local Debug = LUIE.Debug
    --     local traceback = "Disguise State:\n" ..
    --         "--> eventCode: " .. tostring(eventCode) .. "\n" ..
    --         "--> unitTag: " .. tostring(unitTag) .. "\n" ..
    --         "--> disguiseState: " .. tostring(disguiseState)
    --     Debug(traceback)
    -- end

    if disguiseState == DISGUISE_STATE_DANGER then
        if ChatAnnouncements.SV.Notify.DisguiseWarnCA then
            local message = GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DANGER)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "MESSAGE" }
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
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DANGER))
        end

        if (ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert) and not ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
        end
    end

    if disguiseState == DISGUISE_STATE_SUSPICIOUS then
        if ChatAnnouncements.SV.Notify.DisguiseWarnCA then
            local message = GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_SUSPICIOUS)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "MESSAGE" }
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
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_SUSPICIOUS))
        end
        if (ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert) and not ChatAnnouncements.SV.Notify.DisguiseWarnCSA then
            PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
        end
    end

    -- If we're still disguised and g_disguiseState is true then don't waste resources and end the function
    if g_disguiseState == 1 and (disguiseState == DISGUISE_STATE_DISGUISED or disguiseState == DISGUISE_STATE_DANGER or disguiseState == DISGUISE_STATE_SUSPICIOUS or disguiseState == DISGUISE_STATE_DISCOVERED) then
        return
    end

    if g_disguiseState == 1 and (disguiseState == DISGUISE_STATE_NONE) then
        local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_NONE), Effects.DisguiseIcons[g_currentDisguise].description)
        if ChatAnnouncements.SV.Notify.DisguiseCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "MESSAGE" }
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

    if g_disguiseState == 0 and (disguiseState == DISGUISE_STATE_DISGUISED or disguiseState == DISGUISE_STATE_DANGER or disguiseState == DISGUISE_STATE_SUSPICIOUS or disguiseState == DISGUISE_STATE_DISCOVERED) then
        g_currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
        local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DISGUISED), Effects.DisguiseIcons[g_currentDisguise].description)
        if ChatAnnouncements.SV.Notify.DisguiseCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "MESSAGE" }
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

    g_disguiseState = GetUnitDisguiseState("player")

    if g_disguiseState > 0 then
        g_disguiseState = 1
    end
end

function ChatAnnouncements.OnPlayerActivated(eventCode)
    -- Get current trades if UI is reloaded
    local characterName, _, displayName = GetTradeInviteInfo()

    if characterName ~= "" and displayName ~= "" then
        local tradeName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
        g_tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, tradeName))
    end

    if g_firstLoad then
        ChatAnnouncements.SlayChatHandlers()
        g_firstLoad = false
    end

    LUIE_CallLater(function ()
        g_loginHideQuestLoot = false
    end, 3000)

    if ChatAnnouncements.SV.Notify.DisguiseCA or ChatAnnouncements.SV.Notify.DisguiseCSA or ChatAnnouncements.SV.Notify.DisguiseAlert or ChatAnnouncements.SV.Notify.DisguiseWarnCA or ChatAnnouncements.SV.Notify.DisguiseWarnCSA or ChatAnnouncements.SV.Notify.DisguiseWarnAlert then
        if g_disguiseState == 0 then
            g_disguiseState = GetUnitDisguiseState("player")
            if g_disguiseState == 0 then
                return
            elseif g_disguiseState ~= 0 then
                g_disguiseState = 1
                g_currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
                local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_DISGUISED), Effects.DisguiseIcons[g_currentDisguise].description)
                if ChatAnnouncements.SV.Notify.DisguiseCA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "MESSAGE" }
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
        elseif g_disguiseState == 1 then
            g_disguiseState = GetUnitDisguiseState("player")
            if g_disguiseState == 0 then
                local message = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_CA_JUSTICE_DISGUISE_STATE_NONE), Effects.DisguiseIcons[g_currentDisguise].description)
                if ChatAnnouncements.SV.Notify.DisguiseCA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "MESSAGE" }
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
            elseif g_disguiseState ~= 0 then
                g_disguiseState = 1
                g_currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0
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

-- TODO: Replace/Remove

--[[
function ChatAnnouncements.InventoryFullQuest(eventCode)
    printToChat(GetString(SI_INVENTORY_ERROR_INVENTORY_FULL))
end

function ChatAnnouncements.InventoryFull(eventCode, numSlotsRequested, numSlotsFree)
    local function DisplayItemFailed()
        if numSlotsRequested == 1 then
            printToChat(GetString(SI_INVENTORY_ERROR_INVENTORY_FULL))
        else
            printToChat(zo_strformat(GetString(SI_INVENTORY_ERROR_INSUFFICIENT_SPACE), (numSlotsRequested - numSlotsFree) ))
        end
    end

    LUIE_CallLater(DisplayItemFailed, 100)
end

function ChatAnnouncements.LootItemFailed(eventCode, reason, itemName)
    -- Stop Spam
    eventManager:UnregisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED)

    local function ReactivateLootItemFailed()
    printToChat(zo_strformat(GetString("SI_LOOTITEMRESULT", reason), itemName))
        eventManager:RegisterForEvent(moduleName, EVENT_LOOT_ITEM_FAILED, ChatAnnouncements.LootItemFailed)
    end

    LUIE_CallLater(ReactivateLootItemFailed, 100)
end
]]

-------------------------------------------------------------------------
-- UPDATED CODE
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
    --     Debug(traceback)
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

-- Used by functions calling bar updates
--- @param barParams CenterScreenPlayerProgressBarParams
local function ValidateProgressBarParams(barParams)
    local barType = barParams:GetParams()
    if not (barType and PLAYER_PROGRESS_BAR:GetBarTypeInfoByBarType(barType)) then
        local INVALID_VALUE = -1
        assert(false, string_format("CSAH Bad Bar Params; barType: %d. Triggering Event: %d.", barType or INVALID_VALUE, barParams:GetTriggeringEvent() or INVALID_VALUE))
    end
end

-- Used by functions calling bar updates
local function GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, triggeringEvent)
    local championXpToNextPoint
    if CanUnitGainChampionPoints("player") then
        championXpToNextPoint = GetNumChampionXPInChampionPoint(championPoints)
    end
    if championXpToNextPoint ~= nil and currentExperience > previousExperience then
        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, previousExperience, currentExperience)
        barParams:SetTriggeringEvent(triggeringEvent)
        return barParams
    else
        local levelSize = GetNumExperiencePointsInLevel(level)
        if levelSize ~= nil and currentExperience > previousExperience then
            local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_XP, level, previousExperience, currentExperience)
            barParams:SetTriggeringEvent(triggeringEvent)
            return barParams
        end
    end
end

-- Used by functions calling bar updates
local function GetCurrentChampionPointsBarParams(triggeringEvent)
    local championPoints = GetPlayerChampionPointsEarned()
    local currentChampionXP = GetPlayerChampionXP()
    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, currentChampionXP, currentChampionXP)
    barParams:SetShowNoGain(true)
    barParams:SetTriggeringEvent(triggeringEvent)
    return barParams
end

-- local vars for EVENT_SKILL_XP
local GUILD_SKILL_SHOW_REASONS =
{
    [PROGRESS_REASON_DARK_ANCHOR_CLOSED] = true,
    [PROGRESS_REASON_DARK_FISSURE_CLOSED] = true,
    [PROGRESS_REASON_BOSS_KILL] = true,
}

-- local vars for EVENT_SKILL_XP
local GUILD_SKILL_SHOW_SOUNDS =
{
    [PROGRESS_REASON_DARK_ANCHOR_CLOSED] = SOUNDS.SKILL_XP_DARK_ANCHOR_CLOSED,
    [PROGRESS_REASON_DARK_FISSURE_CLOSED] = SOUNDS.SKILL_XP_DARK_FISSURE_CLOSED,
    [PROGRESS_REASON_BOSS_KILL] = SOUNDS.SKILL_XP_BOSS_KILLED,
}

-- Used by EVENT_SKILL_POINTS_CHANGED (CSA Handler) to ignore skill point updates in certain cases.
local SUPPRESS_SKILL_POINT_CSA_REASONS =
{
    [SKILL_POINT_CHANGE_REASON_IGNORE] = true,
    [SKILL_POINT_CHANGE_REASON_SKILL_RESPEC] = true,
    [SKILL_POINT_CHANGE_REASON_SKILL_RESET] = true,
}

--- ALERT & EVENT HANDLER PREHOOK FUNCTIONS!
function ChatAnnouncements.HookFunction()
    local alertHandlers = ZO_AlertText_GetHandlers()

    -- EVENT_STYLE_LEARNED (Alert Handler)
    local function StyleLearnedHook(itemStyleId, chapterIndex, isDefaultRacialStyle)
        local flag
        if ChatAnnouncements.SV.Inventory.LootShowMotif and ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
            flag = true
        else
            flag = false
        end

        if not flag then
            if not isDefaultRacialStyle then
                if chapterIndex == ITEM_STYLE_CHAPTER_ALL then
                    local text = zo_strformat(SI_NEW_STYLE_LEARNED, GetItemStyleName(itemStyleId))
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
                else
                    local text = zo_strformat(SI_NEW_STYLE_CHAPTER_LEARNED, GetItemStyleName(itemStyleId), GetString("SI_ITEMSTYLECHAPTER", chapterIndex))
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
                end
            end
        end
        return true
    end

    -- EVENT_RECIPE_LEARNED (Alert Handler)
    local function RecipeLearnedHook(recipeListIndex, recipeIndex)
        local flag
        if ChatAnnouncements.SV.Inventory.LootShowRecipe and ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
            flag = true
        else
            flag = false
        end

        if not flag then
            local _, name = GetRecipeInfo(recipeListIndex, recipeIndex)
            local text = zo_strformat(SI_NEW_RECIPE_LEARNED, name)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.RECIPE_LEARNED, text)
        end
        return true
    end

    -- EVENT_MULTIPLE_RECIPES_LEARNED (Alert Handler)
    local function MultipleRecipeLearnedHook(numLearned)
        local flag
        if ChatAnnouncements.SV.Inventory.LootShowRecipe and ChatAnnouncements.SV.Inventory.LootRecipeHideAlert then
            flag = true
        else
            flag = false
        end

        if not flag then
            local text = zo_strformat(SI_NEW_RECIPES_LEARNED, numLearned)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.RECIPE_LEARNED, text)
        end
        return true
    end

    -- EVENT_LORE_BOOK_ALREADY_KNOWN (Alert Handler)
    -- Note: We just hide this alert because it is pointless pretty much (only ever seen in trigger from server lag)
    local function AlreadyKnowBookHook(bookTitle)
        return true
    end

    -- EVENT_RIDING_SKILL_IMPROVEMENT (Alert Handler)
    -- Note: We allow the CSA handler to handle any changes made from skill books in order to properly throttle all messages, and use the alert handler for stables upgrades.
    local function RidingSkillImprovementAlertHook(ridingSkill, previous, current, source)
        if source == RIDING_TRAIN_SOURCE_STABLES then
            -- If we purchased from the stables, display a currency announcement if relevant
            if ChatAnnouncements.SV.Currency.CurrencyGoldChange then
                local messageType
                if ridingSkill == 1 then
                    messageType = "LUIE_CURRENCY_RIDING_SPEED"
                elseif ridingSkill == 2 then
                    messageType = "LUIE_CURRENCY_RIDING_CAPACITY"
                elseif ridingSkill == 3 then
                    messageType = "LUIE_CURRENCY_RIDING_STAMINA"
                end
                local formattedValue = ZO_CommaDelimitDecimalNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) + 250)
                local changeColor = ChatAnnouncements.SV.Currency.CurrencyContextColor and ColorizeColors.CurrencyDownColorize:ToHex() or ColorizeColors.CurrencyColorize:ToHex()
                local changeType = ZO_CommaDelimitDecimalNumber(250)
                local currencyTypeColor = ColorizeColors.CurrencyGoldColorize:ToHex()
                local currencyIcon = ChatAnnouncements.SV.Currency.CurrencyIcon and zo_iconFormat(ZO_Currency_GetPlatformCurrencyIcon(CURT_MONEY), 16, 16) or ""
                local currencyName = zo_strformat(ChatAnnouncements.SV.Currency.CurrencyGoldName, 250)
                local currencyTotal = ChatAnnouncements.SV.Currency.CurrencyGoldShowTotal
                local messageTotal = ChatAnnouncements.SV.Currency.CurrencyMessageTotalGold
                local messageChange = ChatAnnouncements.SV.ContextMessages.CurrencyMessageStable
                ChatAnnouncements.CurrencyPrinter(nil, formattedValue, changeColor, changeType, currencyTypeColor, currencyIcon, currencyName, currencyTotal, messageChange, messageTotal, messageType)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingCA then
                local formattedString = ColorizeColors.StorageRidingColorize:Colorize(zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingAlert then
                local text = zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
                messageParams:SetText(GetString(SI_RIDING_SKILL_ANNOUCEMENT_BANNER), zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RIDING_SKILL_IMPROVEMENT)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end
        return true
    end

    -- EVENT_LORE_BOOK_LEARNED (Alert Handler)
    local function LoreBookLearnedAlertHook(categoryIndex, collectionIndex, bookIndex, guildReputationIndex, isMaxRank)
        if guildReputationIndex == 0 or isMaxRank then
            -- We only want to fire this event if a player is not part of the guild or if they've reached max level in the guild.
            -- Otherwise, the _SKILL_EXPERIENCE version of this event will send a center screen message instead.
            local name, numCollections, categoryId = GetLoreCategoryInfo(categoryIndex)
            if name == "Crafting Motifs" then
                return
            end

            local collectionName, _, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)

            if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
                local title, icon = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
                local bookName
                local bookLink
                if ChatAnnouncements.SV.BracketOptionLorebook == 1 then
                    bookName = string_format("%s", title)
                    bookLink = string_format("|H0:LINK_TYPE_LUIE_BOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
                else
                    bookName = string_format("[%s]", title)
                    bookLink = string_format("|H1:LINK_TYPE_LUIE_BOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
                end

                local stringPrefix
                local csaPrefix
                if categoryIndex == 1 then
                    -- Is a lore book
                    stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookPrefix1
                    csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED)
                else
                    -- Is a normal book
                    stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookPrefix2
                    csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(LUIE_STRING_CA_LOREBOOK_BOOK)
                end

                -- Chat Announcement
                if ChatAnnouncements.SV.Lorebooks.LorebookCA then
                    local formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. icon .. "|t ") or ""
                    local stringPart1
                    local stringPart2
                    if stringPrefix ~= "" then
                        stringPart1 = ColorizeColors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                    else
                        stringPart1 = ""
                    end
                    if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                        stringPart2 = collectionName ~= "" and ColorizeColors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName)) or ColorizeColors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                    else
                        stringPart2 = ""
                    end

                    local finalMessage = zo_strformat("<<1>><<2>><<3>><<4>>", stringPart1, formattedIcon, bookLink, stringPart2)
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "COLLECTIBLE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end

                -- Alert Announcement
                if ChatAnnouncements.SV.Lorebooks.LorebookAlert then
                    local text = collectionName ~= "" and zo_strformat("<<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName) or zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY))
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat("<<1>> <<2>>", title, text))
                end

                -- Center Screen Announcement
                if ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                    -- Only display a CSA if this is a Lore Book and we have Eidetic Memory books set to not show.
                    if (categoryIndex == 1 and ChatAnnouncements.SV.Lorebooks.LorebookCSALoreOnly) or not ChatAnnouncements.SV.Lorebooks.LorebookCSALoreOnly then
                        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_ACQUIRED)
                        if collectionName ~= "" then
                            messageParams:SetText(csaPrefix, zo_strformat(LUIE_STRING_CA_LOREBOOK_ADDED_CSA, title, collectionName))
                        else
                            messageParams:SetText(csaPrefix, zo_strformat(LUIE_STRING_CA_LOREBOOK_ADDED_CSA, title, GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                        end
                        messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_BOOK_LEARNED)
                        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                    end
                end
                if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                    PlaySound(SOUNDS.BOOK_ACQUIRED)
                end
            end
        end
        return true
    end

    -----------------------------
    -- DUEL ALERTS --------------
    -----------------------------

    -- EVENT_DUEL_INVITE_RECEIVED (Alert Handler)
    local function DuelInviteReceivedAlert(inviterCharacterName, inviterDisplayName)
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            local finalName = ChatAnnouncements.ResolveNameLink(inviterCharacterName, inviterDisplayName)
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), finalName), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterCharacterName, inviterDisplayName)
            local formattedString = zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), finalAlertName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
        end

        return true
    end

    -- EVENT_DUEL_INVITE_ACCEPTED (Alert Handler)
    local function DuelInviteAcceptedAlert()
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            printToChat(GetString(LUIE_STRING_CA_DUEL_INVITE_ACCEPTED), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_DUEL_INVITE_ACCEPTED))
        end
        PlaySound(SOUNDS.DUEL_ACCEPTED)
        return true
    end

    -- EVENT_DUEL_INVITE_SENT (Alert Handler)
    local function DuelInviteSentAlert(inviteeCharacterName, inviteeDisplayName)
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_SENT), finalName), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)
            local formattedString = zo_strformat(GetString(LUIE_STRING_CA_DUEL_INVITE_SENT), finalAlertName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
        end
        return true
    end

    -- Register Strings here for Alert and CSA Handlers

    -- Player to Player replacement strings for Duels
    SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_DUEL, GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), 5)
    SafeAddString(SI_DUEL_INVITE_MESSAGE, GetString(LUIE_STRING_CA_DUEL_INVITE_RECEIVED), 5)
    SafeAddString(SI_PLAYER_TO_PLAYER_INVITE_DUEL, GetString(LUIE_STRING_CA_DUEL_INVITE_PLAYER), 5)
    -- These are likely a standard error response string for Duels
    SafeAddString(SI_DUELSTATE1, GetString(LUIE_STRING_CA_DUEL_STATE1), 5)
    SafeAddString(SI_DUELSTATE1, GetString(LUIE_STRING_CA_DUEL_STATE2), 5)
    -- Group Player to Player notification replacement
    SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_GROUP, GetString(LUIE_STRING_CA_GROUP_INVITE_MESSAGE), 5)
    -- Guild Invite Player to Player notification replacements
    SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_GUILD_REQUEST, GetString(LUIE_STRING_CA_GUILD_INCOMING_GUILD_REQUEST), 1)
    SafeAddString(SI_GUILD_INVITE_MESSAGE, GetString(LUIE_STRING_CA_GUILD_INVITE_MESSAGE), 3)
    -- Friend Invite String Replacements
    SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_FRIEND_REQUEST, GetString(LUIE_STRING_CA_FRIENDS_INCOMING_FRIEND_REQUEST), 5)
    -- Quest Share String Replacements
    SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_QUEST_SHARE, GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE_P2P), 5)
    SafeAddString(SI_QUEST_SHARE_MESSAGE, GetString(LUIE_STRING_CA_GROUP_INCOMING_QUEST_SHARE_P2P), 5)
    -- Trade String Replacements
    SafeAddString(SI_PLAYER_TO_PLAYER_INCOMING_TRADE, GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), 1)
    SafeAddString(SI_TRADE_INVITE_MESSAGE, GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), 1)
    -- Mail String Replacements
    SafeAddString(SI_SENDMAILRESULT2, GetString(LUIE_STRING_CA_MAIL_SENDMAILRESULT2), 5)
    SafeAddString(SI_SENDMAILRESULT3, GetString(LUIE_STRING_CA_MAIL_SENDMAILRESULT3), 5)

    -- EVENT_DUEL_INVITE_FAILED (Alert Handler)
    local function DuelInviteFailedAlert(reason, targetCharacterName, targetDisplayName)
        local userFacingName = ZO_GetPrimaryPlayerNameWithSecondary(targetDisplayName, targetCharacterName)
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            local reasonName
            local finalName = ChatAnnouncements.ResolveNameLink(targetDisplayName, targetCharacterName)
            if userFacingName then
                printToChat(zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason), finalName), true)
            else
                printToChat(zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason)), true)
            end
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(targetDisplayName, targetCharacterName)
            local formattedString = zo_strformat(GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason), finalAlertName)
            if userFacingName then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, formattedString)
            else
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString("LUIE_STRING_CA_DUEL_INVITE_FAILREASON", reason)))
            end
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return true
    end

    -- EVENT_DUEL_INVITE_DECLINED (Alert Handler)
    local function DuelInviteDeclinedAlert()
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            printToChat(GetString(LUIE_STRING_CA_DUEL_INVITE_DECLINED), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(LUIE_STRING_CA_DUEL_INVITE_DECLINED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return true
    end

    -- EVENT_DUEL_INVITE_CANCELED (Alert Handler)
    local function DuelInviteCanceledAlert()
        -- Display CA
        if ChatAnnouncements.SV.Social.DuelCA then
            printToChat(GetString(LUIE_STRING_CA_DUEL_INVITE_CANCELED), true)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Social.DuelAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(LUIE_STRING_CA_DUEL_INVITE_CANCELED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return true
    end

    -- EVENT_PLEDGE_OF_MARA_RESULT (Alert Handler)
    local function PledgeOfMaraResultAlert(result, characterName, displayName)
        -- Note: We replace everything here and move it all into the CSA handler event
        return true
    end

    -- EVENT_GROUP_INVITE_RESPONSE (Alert Handler)
    local function GroupInviteResponseAlert(characterName, response, displayName)
        if response ~= GROUP_INVITE_RESPONSE_ACCEPTED and response ~= GROUP_INVITE_RESPONSE_CONSIDERING_OTHER then
            local message
            local alertMessage
            local finalName
            local finalAlertName

            local nameCheck1 = ZO_GetPrimaryPlayerName(displayName, characterName, false)
            local nameCheck2 = ZO_GetSecondaryPlayerName(displayName, characterName, false)

            if nameCheck1 == "" then
                finalName = displayName
                finalAlertName = displayName
            elseif nameCheck2 == "" then
                finalName = characterName
                finalAlertName = characterName
            elseif nameCheck1 ~= "" and nameCheck2 ~= "" then
                finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
                finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
            else
                finalName = ""
                finalAlertName = ""
            end

            if response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED and (LUIE.PlayerNameFormatted == characterName or LUIE.PlayerDisplayName == displayName) then
                message = zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_SELF_INVITE))
                alertMessage = zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_SELF_INVITE))
            elseif response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED and (IsPlayerInGroup(characterName) or IsPlayerInGroup(displayName)) then
                message = GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
                alertMessage = GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
            elseif response == GROUP_INVITE_RESPONSE_IGNORED then
                message = finalName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalName) or GetString(SI_PLAYER_BUSY)
                alertMessage = finalAlertName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalAlertName) or GetString(SI_PLAYER_BUSY)
            else
                message = finalName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalName) or characterName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), characterName) or GetString(SI_PLAYER_BUSY)
                alertMessage = finalAlertName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalAlertName) or characterName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), characterName) or GetString(SI_PLAYER_BUSY)
            end

            if ChatAnnouncements.SV.Group.GroupCA or response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED or response == GROUP_INVITE_RESPONSE_IGNORED or response == GROUP_INVITE_RESPONSE_PLAYER_NOT_FOUND then
                printToChat(message, true)
            end
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        return true
    end

    -- EVENT_GROUP_INVITE_ACCEPT_RESPONSE_TIMEOUT (Alert Handler)
    local function GroupInviteTimeoutAlert()
        printToChat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_GENERIC_JOIN_FAILURE), true)
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_GENERIC_JOIN_FAILURE))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return true
    end

    -- EVENT_GROUP_NOTIFICATION_MESSAGE (Alert Handler)
    local function GroupNotificationMessageAlert(groupMessageCode)
        local message = GetString("SI_GROUPNOTIFICATIONMESSAGE", groupMessageCode)
        if message ~= "" then
            printToChat(message, true)
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, message)
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        return true
    end

    -- EVENT_GROUP_UPDATE (Alert Handler)
    local function GroupUpdateAlert()
        g_currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
        g_currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
    end

    -- EVENT_GROUP_MEMBER_LEFT (Alert Handler)
    local function GroupMemberLeftAlert(characterName, reason, isLocalPlayer, isLeader, displayName, actionRequiredVote)
        ChatAnnouncements.IndexGroupLoot()

        local message = nil
        local alert = nil
        local message2 = nil
        local alert2 = nil
        local sound = SOUNDS.NONE

        local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)

        -- Used to check for valid links
        local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)
        local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)

        local hasValidNames = characterNameLink ~= "" and displayNameLink ~= ""
        local useDefaultReasonText = false
        if reason == GROUP_LEAVE_REASON_DISBAND then
            if isLeader and not isLocalPlayer then
                useDefaultReasonText = true
            elseif isLeader and isLocalPlayer then
                message = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                alert = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                LUIE_CallLater(function ()
                    ChatAnnouncements.CheckLFGStatusLeave(false)
                end, 100)
            elseif isLocalPlayer then
                LUIE_CallLater(function ()
                    ChatAnnouncements.CheckLFGStatusLeave(false)
                end, 100)
            end
            sound = SOUNDS.GROUP_DISBAND
        elseif reason == GROUP_LEAVE_REASON_KICKED then
            if actionRequiredVote then
                if isLocalPlayer then
                    LUIE_CallLater(function ()
                        ChatAnnouncements.CheckLFGStatusLeave(true)
                    end, 100)
                    message = zo_strformat(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
                    alert = zo_strformat(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
                elseif hasValidNames then
                    LUIE_CallLater(function ()
                        ChatAnnouncements.CheckLFGStatusLeave(false)
                    end, 100)
                    message = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_PASSED, finalName)
                    alert = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_PASSED, finalAlertName)
                    message2 = zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_KICKED), finalName)
                    alert2 = zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_KICKED), finalAlertName)
                end
                sound = SOUNDS.GROUP_KICK
            else
                if isLeader and isLocalPlayer then
                    message = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                    alert = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                    LUIE_CallLater(function ()
                        ChatAnnouncements.CheckLFGStatusLeave(false)
                    end, 100)
                    sound = SOUNDS.GROUP_DISBAND
                elseif isLocalPlayer then
                    LUIE_CallLater(function ()
                        ChatAnnouncements.CheckLFGStatusLeave(true)
                    end, 100)
                    message = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_SELF_KICKED)
                    alert = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_SELF_KICKED)
                    sound = SOUNDS.GROUP_KICK
                else
                    LUIE_CallLater(function ()
                        ChatAnnouncements.CheckLFGStatusLeave(false)
                    end, 100)
                    useDefaultReasonText = true
                    sound = SOUNDS.GROUP_KICK
                end
            end
        elseif reason == GROUP_LEAVE_REASON_VOLUNTARY or reason == GROUP_LEAVE_REASON_LEFT_BATTLEGROUND then
            if not isLocalPlayer then
                useDefaultReasonText = true
                LUIE_CallLater(function ()
                    ChatAnnouncements.CheckLFGStatusLeave(false)
                end, 100)
            else
                message = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_LEAVE_SELF), finalName))
                alert = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_LEAVE_SELF), finalAlertName))
                LUIE_CallLater(function ()
                    ChatAnnouncements.CheckLFGStatusLeave(false)
                end, 100)
            end

            sound = SOUNDS.GROUP_LEAVE
        elseif reason == GROUP_LEAVE_REASON_DESTROYED then
            -- do nothing, we don't want to show additional alerts for this case
        end

        if useDefaultReasonText and hasValidNames then
            message = zo_strformat(GetString("LUIE_STRING_GROUPLEAVEREASON", reason), finalName)
            alert = zo_strformat(GetString("LUIE_STRING_GROUPLEAVEREASON", reason), finalAlertName)
        end

        if isLocalPlayer then
            g_currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
            g_currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
        end

        -- Only print this out if we didn't JUST join an LFG group.
        if g_stopGroupLeaveQueue or g_lfgDisableGroupEvents then
            return true
        else
            if message ~= nil then
                if ChatAnnouncements.SV.Group.GroupCA then
                    printToChat(message, true)
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alert)
                end
                if sound ~= nil then
                    PlaySound(sound)
                end
            end

            if message2 ~= nil then
                if ChatAnnouncements.SV.Group.GroupCA then
                    printToChat(message2, true)
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alert2)
                end
            end
        end

        return true
    end

    -- EVENT_GROUP_MEMBER_JOINED (Alert Handler)
    local function OnGroupMemberJoined(characterName, displayName, isLocalPlayer)
        -- Update index for Group Loot
        ChatAnnouncements.IndexGroupLoot()
        g_currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
        g_currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())

        -- Determine if the member that joined a group is the player or another member.
        if isLocalPlayer then
            LUIE_CallLater(ChatAnnouncements.CheckLFGStatusJoin, 100)
        else
            -- Get character & display names
            local joinedMemberName = ZO_GetPrimaryPlayerName(displayName, characterName, false)
            local joinedMemberAccountName = ZO_GetSecondaryPlayerName(displayName, characterName, false)
            -- Resolve name links
            local finalName = ChatAnnouncements.ResolveNameLink(joinedMemberName, joinedMemberAccountName)
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(joinedMemberName, joinedMemberAccountName)
            -- Set final messages to send
            local SendMessage = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalName))
            local SendAlert = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalAlertName))
            LUIE_CallLater(function ()
                ChatAnnouncements.PrintJoinStatusNotSelf(SendMessage, SendAlert)
            end, 100)
        end

        return true
    end

    -- EVENT_LEADER_UPDATE (Alert Handler)
    -- Note: This event only fires if the characterId of the leader has changed (it's a new leader)
    local function LeaderUpdateAlert(leaderTag)
        local leaderRawName = GetRawUnitName(leaderTag)
        local showAlert = leaderRawName ~= "" and (g_currentGroupLeaderRawName ~= "" and g_currentGroupLeaderRawName ~= nil)
        g_currentGroupLeaderRawName = leaderRawName
        g_currentGroupLeaderDisplayName = GetUnitDisplayName(leaderTag)

        -- If for some reason we don't have a valid leader name, bail out now.
        if g_currentGroupLeaderRawName == "" or g_currentGroupLeaderRawName == nil or g_currentGroupLeaderDisplayName == "" or g_currentGroupLeaderDisplayName == nil then
            return true
        end

        local displayString
        local alertString
        local finalName = ChatAnnouncements.ResolveNameLink(g_currentGroupLeaderRawName, g_currentGroupLeaderDisplayName)
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(g_currentGroupLeaderRawName, g_currentGroupLeaderDisplayName)

        if LUIE.PlayerNameRaw ~= g_currentGroupLeaderRawName then -- If another player became the leader
            displayString = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED), finalName))
            alertString = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED), finalAlertName))
        elseif LUIE.PlayerNameRaw == g_currentGroupLeaderRawName then -- If the player character became the leader
            displayString = (GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED_SELF))
            alertString = (GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED_SELF))
        end

        -- Don't show leader updates when joining LFG.
        if g_stopGroupLeaveQueue or g_lfgDisableGroupEvents then
            return true
        end

        if showAlert then
            if ChatAnnouncements.SV.Group.GroupCA then
                printToChat(displayString, true)
            end
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertString)
            end
            PlaySound(SOUNDS.GROUP_PROMOTE)
        end
        return true
    end

    -- EVENT_ACTIVITY_QUEUE_RESULT (Alert Handler)
    local function ActivityQueueResultAlert(result)
        if result ~= ACTIVITY_QUEUE_RESULT_SUCCESS then
            if ChatAnnouncements.SV.Group.GroupLFGCA then
                printToChat(GetString("SI_ACTIVITYQUEUERESULT", result), true)
            end
            if ChatAnnouncements.SV.Group.GroupLFGAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("SI_ACTIVITYQUEUERESULT", result))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        g_showRCUpdates = true

        return true
    end

    -- EVENT_GROUP_ELECTION_FAILED (Alert Handler)
    local function GroupElectionFailedAlert(failureType, descriptor)
        if failureType ~= GROUP_ELECTION_FAILURE_NONE then
            if ChatAnnouncements.SV.Group.GroupVoteCA then
                printToChat(GetString("SI_GROUPELECTIONFAILURE", failureType), true)
            end
            if ChatAnnouncements.SV.Group.GroupVoteAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("SI_GROUPELECTIONFAILURE", failureType))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        return true
    end

    -- Variables for EVENT_GROUP_ELECTION_RESULT
    local GroupElectionResultToSoundId =
    {
        [GROUP_ELECTION_RESULT_ELECTION_WON] = SOUNDS.GROUP_ELECTION_RESULT_WON,
        [GROUP_ELECTION_RESULT_ELECTION_LOST] = SOUNDS.GROUP_ELECTION_RESULT_LOST,
        [GROUP_ELECTION_RESULT_ABANDONED] = SOUNDS.GROUP_ELECTION_RESULT_LOST,
    }

    -- EVENT_GROUP_ELECTION_RESULT (Alert Handler)
    local function GroupElectionResultAlert(resultType, descriptor)
        if resultType ~= GROUP_ELECTION_RESULT_IN_PROGRESS and resultType ~= GROUP_ELECTION_RESULT_NOT_APPLICABLE then
            resultType = ZO_GetSimplifiedGroupElectionResultType(resultType)
            local alertText
            local message

            -- Try to find override messages based on the descriptor
            local alertTextOverrideLookup = ZO_GroupElectionResultToAlertTextOverrides[resultType]
            if alertTextOverrideLookup then
                message = alertTextOverrideLookup[descriptor]
                alertText = alertTextOverrideLookup[descriptor]
            end

            -- No override found
            if not alertText then
                local electionType, _, _, targetUnitTag = GetGroupElectionInfo()
                if not targetUnitTag then
                    return
                end
                if electionType == GROUP_ELECTION_TYPE_KICK_MEMBER then
                    if resultType == GROUP_ELECTION_RESULT_ELECTION_LOST then
                        local kickMemberName = GetUnitName(targetUnitTag)
                        local kickMemberAccountName = GetUnitDisplayName(targetUnitTag)

                        local kickFinalName = ChatAnnouncements.ResolveNameLink(kickMemberName, kickMemberAccountName)
                        local kickFinalAlertName = ChatAnnouncements.ResolveNameNoLink(kickMemberName, kickMemberAccountName)

                        message = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_FAIL, kickFinalName)
                        alertText = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_FAIL, kickFinalAlertName)
                    else
                        -- Successful kicks are handled in the GROUP_MEMBER_LEFT alert
                        return true
                    end
                end
            end

            -- No specific behavior found, so just do the generic alert for the result
            if not alertText then
                message = GetString("SI_GROUPELECTIONRESULT", resultType)
                alertText = GetString("SI_GROUPELECTIONRESULT", resultType)
            end

            if alertText ~= "" then
                if type(alertText) == "function" then
                    alertText = alertText()
                    message = message()
                end

                if ChatAnnouncements.SV.Group.GroupVoteCA then
                    printToChat(message, true)
                end
                if ChatAnnouncements.SV.Group.GroupVoteAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
                end
                PlaySound(GroupElectionResultToSoundId[resultType])
            end
        end
        return true
    end

    -- EVENT_GROUP_ELECTION_REQUESTED (Alert Handler)
    local function GroupElectionRequestedAlert(descriptor)
        local alertText
        local messageText
        if descriptor then
            messageText = ZO_GroupElectionDescriptorToRequestAlertText[descriptor]
            alertText = ZO_GroupElectionDescriptorToRequestAlertText[descriptor]
        end

        if not alertText then
            messageText = ZO_GroupElectionDescriptorToRequestAlertText[ZO_GROUP_ELECTION_DESCRIPTORS.NONE]
            alertText = ZO_GroupElectionDescriptorToRequestAlertText[ZO_GROUP_ELECTION_DESCRIPTORS.NONE]
        end

        if ChatAnnouncements.SV.Group.GroupVoteCA then
            printToChat(messageText, true)
        end
        if ChatAnnouncements.SV.Group.GroupVoteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertText)
        end
        PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
        return true
    end

    -- EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED (Alert Handler)
    local function GroupReadyCheckCancelAlert(reason)
        local message

        if reason ~= LFG_READY_CHECK_CANCEL_REASON_NOT_IN_READY_CHECK and reason ~= LFG_READY_CHECK_CANCEL_REASON_GROUP_FORMED_SUCCESSFULLY then
            message = GetString("SI_LFGREADYCHECKCANCELREASON", reason)
            if ChatAnnouncements.SV.Group.GroupLFGCA then
                printToChat(message, true)
            end
            if ChatAnnouncements.SV.Group.GroupLFGAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
            end
        end

        -- Stop the cancel message from status update from triggering when any other result here happens.
        g_lfgHideStatusCancel = true
        LUIE_CallLater(function ()
            g_lfgHideStatusCancel = false
        end, 1000)

        -- Sometimes if another player cancels slightly before a player in your group cancels, the "you have been placed in the front of the queue message displays. If this is the case, we want to show queue left for that event."
        if reason ~= LFG_READY_CHECK_CANCEL_REASON_GROUP_REPLACED_IN_QUEUE then
            g_showActivityStatus = false
            LUIE_CallLater(function ()
                g_showActivityStatus = true
            end, 1000)
        end

        g_showRCUpdates = true
    end

    -- EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED (Alert Handler)
    local function GroupDifficultyChangeAlert(isVeteranDifficulty)
        local message
        local sound
        if isVeteranDifficulty then
            message = GetString(SI_DUNGEON_DIFFICULTY_CHANGED_TO_VETERAN)
            sound = SOUNDS.DUNGEON_DIFFICULTY_VETERAN
        else
            message = GetString(SI_DUNGEON_DIFFICULTY_CHANGED_TO_NORMAL)
            sound = SOUNDS.DUNGEON_DIFFICULTY_NORMAL
        end

        if ChatAnnouncements.SV.Group.GroupCA then
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
        PlaySound(sound)

        return true
    end

    -- EVENT_GUILD_SELF_LEFT_GUILD (Alert Handler)
    local function GuildSelfLeftAlert(guildId, guildName)
        local GuildIndexData = LUIE.GuildIndexData
        for i = 1, 5 do
            local guild = GuildIndexData[i]
            if guild.name == guildName then
                local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guild.guildAlliance) or ColorizeColors.GuildColorize
                local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guild.guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
                local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guild.guildAlliance), "100%", "100%", guildName) or guildName
                local messageString = (ShouldDisplaySelfKickedFromGuildAlert(guildId)) and SI_GUILD_SELF_KICKED_FROM_GUILD or LUIE_STRING_CA_GUILD_LEAVE_SELF
                local sound = (ShouldDisplaySelfKickedFromGuildAlert(guildId)) and SOUNDS.GENERAL_ALERT_ERROR or SOUNDS.GUILD_SELF_LEFT
                if ChatAnnouncements.SV.Social.GuildCA then
                    printToChat(zo_strformat(GetString(messageString), guildNameAlliance), true)
                end
                if ChatAnnouncements.SV.Social.GuildAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(messageString), guildNameAllianceAlert))
                end
                PlaySound(sound)
                break
            end
        end

        return true
    end

    -- EVENT_SAVE_GUILD_RANKS_RESPONSE (Alert Handler)
    local function GuildRanksResponseAlert(guildId, result)
        if result ~= SOCIAL_RESULT_NO_ERROR then
            if ChatAnnouncements.SV.Social.GuildCA then
                printToChat(GetString("SI_SOCIALACTIONRESULT", result), true)
            elseif ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("SI_SOCIALACTIONRESULT", result))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        return true
    end

    -- EVENT_LOCKPICK_FAILED (Alert Handler)
    local function LockpickFailedAlert(result)
        if ChatAnnouncements.SV.Notify.NotificationLockpickCA then
            local message = GetString(LUIE_STRING_CA_LOCKPICK_FAILED)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "NOTIFICATION" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_LOCKPICK_FAILED))
        end
        g_lockpickBroken = true
        LUIE_CallLater(function ()
            g_lockpickBroken = false
        end, 200)
        return true
    end

    -- EVENT_CLIENT_INTERACT_RESULT (Alert Handler)
    local function ClientInteractResult(result, interactTargetName)
        local formatString = GetString("SI_CLIENTINTERACTRESULT", result)
        if formatString ~= "" then
            printToChat(zo_strformat(formatString, interactTargetName))
            if ChatAnnouncements.SV.Notify.NotificationLockpickAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, zo_strformat(formatString, interactTargetName))
            end
            local sound = ZO_ClientInteractResultSpecificSound[result] or SOUNDS.GENERAL_ALERT_ERROR
            PlaySound(sound)
        end
        return true
    end

    -- EVENT_TRADE_INVITE_FAILED (Alert Handler)
    local function TradeInviteFailedAlert(errorReason, inviteeCharacterName, inviteeDisplayName)
        if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)

            if ChatAnnouncements.SV.Notify.NotificationTradeCA then
                printToChat(zo_strformat(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", errorReason), finalName), true)
            end

            if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", errorReason), finalAlertName))
            end
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        g_tradeTarget = ""
        return true
    end

    -- EVENT_TRADE_INVITE_CONSIDERING (Alert Handler)
    local function TradeInviteConsideringAlert(inviterCharacterName, inviterDisplayName)
        if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            local finalName = ChatAnnouncements.ResolveNameLink(inviterCharacterName, inviterDisplayName)
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterCharacterName, inviterDisplayName)
            g_tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, finalName))

            if ChatAnnouncements.SV.Notify.NotificationTradeCA then
                printToChat(zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), finalName), true)
            end
            if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_MESSAGE), finalAlertName))
            end
        end
        return true
    end

    -- EVENT_TRADE_INVITE_WAITING (Alert Handler)
    local function TradeInviteWaitingAlert(inviteeCharacterName, inviteeDisplayName)
        if ChatAnnouncements.SV.Notify.NotificationTradeCA or ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            local finalName = ChatAnnouncements.ResolveNameLink(inviteeCharacterName, inviteeDisplayName)
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviteeCharacterName, inviteeDisplayName)
            g_tradeTarget = ZO_SELECTED_TEXT:Colorize(zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, finalName))

            if ChatAnnouncements.SV.Notify.NotificationTradeCA then
                printToChat(zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_CONFIRM), finalName), true)
            end
            if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_TRADE_INVITE_CONFIRM), finalAlertName))
            end
        end
        return true
    end

    -- EVENT_TRADE_INVITE_DECLINED (Alert Handler)
    local function TradeInviteDeclinedAlert()
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            printToChat(GetString(LUIE_STRING_CA_TRADE_INVITE_DECLINED), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_TRADE_INVITE_DECLINED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        g_tradeTarget = ""
        g_tradeStacksIn = {}
        g_tradeStacksOut = {}
        return true
    end

    -- EVENT_TRADE_INVITE_CANCELED (Alert Handler)
    local function TradeInviteCanceledAlert()
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            printToChat(GetString(LUIE_STRING_CA_TRADE_INVITE_CANCELED), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_TRADE_INVITE_CANCELED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        g_tradeTarget = ""
        g_tradeStacksIn = {}
        g_tradeStacksOut = {}
        return true
    end

    -- EVENT_TRADE_CANCELED (Alert Handler)
    local function TradeCanceledAlert()
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            printToChat(GetString(SI_TRADE_CANCELED), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(SI_TRADE_CANCELED))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

        eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
            eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        end
        if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
            g_inventoryStacks = {}
        end

        g_tradeTarget = ""
        g_tradeStacksIn = {}
        g_tradeStacksOut = {}
        g_inTrade = false
        return true
    end

    -- EVENT_TRADE_FAILED (Alert Handler)
    local function TradeFailedAlert(reason)
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            printToChat(GetString("LUIE_STRING_CA_TRADEACTIONRESULT", reason), true)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString("LUIE_STRING_CA_TRADEACTIONRESULT", reason))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

        g_tradeTarget = ""
        g_inTrade = false
        return true
    end

    -- EVENT_TRADE_SUCCEEDED (Alert Handler)
    local function TradeSucceededAlert()
        if ChatAnnouncements.SV.Notify.NotificationTradeCA then
            local message = GetString(SI_TRADE_COMPLETE)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, messageType = "NOTIFICATION", isSystem = true }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end
        if ChatAnnouncements.SV.Notify.NotificationTradeAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(SI_TRADE_COMPLETE))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

        if ChatAnnouncements.SV.Inventory.LootTrade then
            for indexOut = 1, 5 do
                if g_tradeStacksOut[indexOut] ~= nil then
                    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 2 or 4
                    local logPrefix = g_tradeTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeOut or ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeOutNoName
                    local item = g_tradeStacksOut[indexOut]
                    ChatAnnouncements.ItemCounterDelayOut(item.icon, item.stack, item.itemType, item.itemId, item.itemLink, g_tradeTarget, logPrefix, gainOrLoss, false)
                end
            end

            for indexIn = 1, 5 do
                if g_tradeStacksIn[indexIn] ~= nil then
                    local gainOrLoss = ChatAnnouncements.SV.Currency.CurrencyContextColor and 1 or 3
                    local logPrefix = g_tradeTarget ~= "" and ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeIn or ChatAnnouncements.SV.ContextMessages.CurrencyMessageTradeInNoName
                    local item = g_tradeStacksIn[indexIn]
                    ChatAnnouncements.ItemCounterDelay(item.icon, item.stack, item.itemType, item.itemId, item.itemLink, g_tradeTarget, logPrefix, gainOrLoss, false)
                end
            end
        end

        eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
        if ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise then
            eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ChatAnnouncements.InventoryUpdate)
        end
        if not (ChatAnnouncements.SV.Inventory.Loot or ChatAnnouncements.SV.Inventory.LootShowDisguise) then
            g_inventoryStacks = {}
        end

        g_tradeTarget = ""
        g_tradeStacksIn = {}
        g_tradeStacksOut = {}
        g_inTrade = false
        return true
    end

    -- EVENT_DISCOVERY_EXPERIENCE (Alert Handler)
    local function DiscoveryExperienceAlert(subzoneName, level, previousExperience, currentExperience, rank, previousPoints, currentPoints)
        -- Note: We let the CSA Handler take care of this.
        return true
    end

    -- EVENT_MAIL_SEND_FAILED (Alert Handler)
    local function MailSendFailedAlert(reason)
        if reason ~= MAIL_SEND_RESULT_CANCELED then
            local function RestoreMailBackupValues()
                g_postageAmount = GetQueuedMailPostage()
                g_mailAmount = GetQueuedMoneyAttachment()
                g_mailCOD = GetQueuedCOD()
            end

            -- Stop currency messages from printing here
            if reason == MAIL_SEND_RESULT_FAIL_INVALID_NAME then
                for i = 1, #ChatAnnouncements.QueuedMessages do
                    if ChatAnnouncements.QueuedMessages[i].messageType == "CURRENCY" then
                        ChatAnnouncements.QueuedMessages[i].messageType = "GARBAGE"
                    end
                end
                eventManager:UnregisterForEvent(moduleName, EVENT_CURRENCY_UPDATE)
                LUIE_CallLater(function ()
                    eventManager:RegisterForEvent(moduleName, EVENT_CURRENCY_UPDATE, ChatAnnouncements.OnCurrencyUpdate)
                end, 500)
            end

            if ChatAnnouncements.SV.Notify.NotificationMailErrorCA then
                printToChat(GetString("SI_SENDMAILRESULT", reason), true)
            end
            if ChatAnnouncements.SV.Notify.NotificationMailErrorAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString("SI_SENDMAILRESULT", reason))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)

            LUIE_CallLater(RestoreMailBackupValues, 50) -- Prevents values from being cleared by failed message (when inbox is full, the currency change fires first regardless and then is refunded)
        end
        return true
    end

    ZO_PreHook(alertHandlers, EVENT_LORE_BOOK_ALREADY_KNOWN, AlreadyKnowBookHook)
    ZO_PreHook(alertHandlers, EVENT_RIDING_SKILL_IMPROVEMENT, RidingSkillImprovementAlertHook)
    ZO_PreHook(alertHandlers, EVENT_LORE_BOOK_LEARNED, LoreBookLearnedAlertHook)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_RECEIVED, DuelInviteReceivedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_SENT, DuelInviteSentAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_ACCEPTED, DuelInviteAcceptedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_FAILED, DuelInviteFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_DECLINED, DuelInviteDeclinedAlert)
    ZO_PreHook(alertHandlers, EVENT_DUEL_INVITE_CANCELED, DuelInviteCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_PLEDGE_OF_MARA_RESULT, PledgeOfMaraResultAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_INVITE_RESPONSE, GroupInviteResponseAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_INVITE_ACCEPT_RESPONSE_TIMEOUT, GroupInviteTimeoutAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_NOTIFICATION_MESSAGE, GroupNotificationMessageAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_UPDATE, GroupUpdateAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_MEMBER_LEFT, GroupMemberLeftAlert)
    ZO_PreHook(alertHandlers, EVENT_LEADER_UPDATE, LeaderUpdateAlert)
    ZO_PreHook(alertHandlers, EVENT_ACTIVITY_QUEUE_RESULT, ActivityQueueResultAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_FAILED, GroupElectionFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_RESULT, GroupElectionResultAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_REQUESTED, GroupElectionRequestedAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED, GroupReadyCheckCancelAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, GroupDifficultyChangeAlert)

    ZO_PreHook(alertHandlers, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)

    -- This function isn't needed if CA isn't enabled so only load it if CA is enabled
    if ChatAnnouncements.Enabled then
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_TYPE_CHANGED, ChatAnnouncements.OnGroupTypeChanged)
    end
    eventManager:RegisterForEvent(moduleName, EVENT_GROUP_INVITE_RECEIVED, ChatAnnouncements.OnGroupInviteReceived)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUP_ELECTION_NOTIFICATION_ADDED, ChatAnnouncements.VoteNotify)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_NO_LONGER_LFG, ChatAnnouncements.LFGLeft)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_LFG_JOINED, ChatAnnouncements.GroupingToolsLFGJoined)
    eventManager:RegisterForEvent(moduleName, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, ChatAnnouncements.ActivityStatusUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED, ChatAnnouncements.ReadyCheckUpdate)

    ZO_PreHook(alertHandlers, EVENT_GUILD_SELF_LEFT_GUILD, GuildSelfLeftAlert)
    ZO_PreHook(alertHandlers, EVENT_SAVE_GUILD_RANKS_RESPONSE, GuildRanksResponseAlert)
    ZO_PreHook(alertHandlers, EVENT_LOCKPICK_FAILED, LockpickFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_CLIENT_INTERACT_RESULT, ClientInteractResult)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_FAILED, TradeInviteFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_CONSIDERING, TradeInviteConsideringAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_WAITING, TradeInviteWaitingAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_DECLINED, TradeInviteDeclinedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_INVITE_CANCELED, TradeInviteCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_CANCELED, TradeCanceledAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_FAILED, TradeFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_TRADE_SUCCEEDED, TradeSucceededAlert)
    ZO_PreHook(alertHandlers, EVENT_DISCOVERY_EXPERIENCE, DiscoveryExperienceAlert)
    ZO_PreHook(alertHandlers, EVENT_MAIL_SEND_FAILED, MailSendFailedAlert)

    ZO_PreHook(alertHandlers, EVENT_STYLE_LEARNED, StyleLearnedHook)
    ZO_PreHook(alertHandlers, EVENT_RECIPE_LEARNED, RecipeLearnedHook)
    ZO_PreHook(alertHandlers, EVENT_MULTIPLE_RECIPES_LEARNED, MultipleRecipeLearnedHook)

    local csaHandlers = ZO_CenterScreenAnnounce_GetEventHandlers()
    local csaCallbackHandlers = ZO_CenterScreenAnnounce_GetCallbackHandlers()

    -- EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE (CSA Handler)
    local function LoreBookXPHook(categoryIndex, collectionIndex, bookIndex, guildReputationIndex, skillType, skillIndex, rank, previousXP, currentXP)
        if guildReputationIndex > 0 then
            local collectionName, _, numKnownBooks, totalBooks, hidden = GetLoreCollectionInfo(categoryIndex, collectionIndex)
            local title, icon = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
            local bookName
            local bookLink
            if ChatAnnouncements.SV.BracketOptionLorebook == 1 then
                bookName = string_format("%s", title)
                bookLink = string_format("|H0:LINK_TYPE_LUIE_BOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
            else
                bookName = string_format("[%s]", title)
                bookLink = string_format("|H1:LINK_TYPE_LUIE_BOOK:%s:%s:%s|h%s|h", categoryIndex, collectionIndex, bookIndex, bookName)
            end

            local stringPrefix
            local csaPrefix
            if categoryIndex == 1 then
                -- Is a lore book
                stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookPrefix1
                csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED)
            else
                -- Is a normal book
                stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookPrefix2
                csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(LUIE_STRING_CA_LOREBOOK_BOOK)
            end

            -- Chat Announcement
            if ChatAnnouncements.SV.Lorebooks.LorebookCA then
                local formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. icon .. "|t ") or ""
                local stringPart1
                local stringPart2
                if stringPrefix ~= "" then
                    stringPart1 = ColorizeColors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                else
                    stringPart1 = ""
                end
                if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                    stringPart2 = collectionName ~= "" and ColorizeColors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName)) or ColorizeColors.LorebookColorize2:Colorize(zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                else
                    stringPart2 = ""
                end

                local finalMessage = zo_strformat("<<1>><<2>><<3>><<4>>", stringPart1, formattedIcon, bookLink, stringPart2)
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "COLLECTIBLE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            -- Alert Announcement
            if ChatAnnouncements.SV.Lorebooks.LorebookAlert then
                local text = collectionName ~= "" and zo_strformat("<<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), collectionName) or zo_strformat(" <<1>> <<2>>.", GetString(LUIE_STRING_CA_LOREBOOK_ADDED_CA), GetString(SI_WINDOW_TITLE_LORE_LIBRARY))
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat("<<1>> <<2>>", title, text))
            end

            -- Center Screen Announcement
            if ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                -- Only display a CSA if this is a Lore Book and we have Eidetic Memory books set to not show.
                if (categoryIndex == 1 and ChatAnnouncements.SV.Lorebooks.LorebookCSALoreOnly) or not ChatAnnouncements.SV.Lorebooks.LorebookCSALoreOnly then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_ACQUIRED)
                    if not LUIE.SV.HideXPBar then
                        local barType = PLAYER_PROGRESS_BAR:GetBarType(PPB_CLASS_SKILL, skillType, skillIndex)
                        local rankStartXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillIndex, rank)
                        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(barType, rank, previousXP - rankStartXP, currentXP - rankStartXP)
                        barParams:SetTriggeringEvent(EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE)
                        ValidateProgressBarParams(barParams)
                        messageParams:SetBarParams(barParams)
                    end
                    if collectionName ~= "" then
                        messageParams:SetText(csaPrefix, zo_strformat(LUIE_STRING_CA_LOREBOOK_ADDED_CSA, title, collectionName))
                    else
                        messageParams:SetText(csaPrefix, zo_strformat(LUIE_STRING_CA_LOREBOOK_ADDED_CSA, title, GetString(SI_WINDOW_TITLE_LORE_LIBRARY)))
                    end
                    messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_BOOK_LEARNED_SKILL_EXPERIENCE)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
            end
            if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                PlaySound(SOUNDS.BOOK_ACQUIRED)
            end
        end
        return true
    end

    -- EVENT_LORE_COLLECTION_COMPLETED (CSA Handler)
    local function LoreCollectionHook(categoryIndex, collectionIndex, bookIndex, guildReputationIndex, isMaxRank)
        if guildReputationIndex == 0 or isMaxRank then
            -- Only fire this message if we're not part of the guild or at max level within the guild.
            local collectionName, description, numKnownBooks, totalBooks, hidden, textureName = GetLoreCollectionInfo(categoryIndex, collectionIndex)
            local stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookCollectionPrefix
            local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_COLLECTION_COMPLETED_LARGE)
            if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCA then
                    local formattedIcon
                    local stringPart1
                    local stringPart2
                    if stringPrefix ~= "" then
                        stringPart1 = ColorizeColors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                    else
                        stringPart1 = ""
                    end
                    if textureName ~= "" and textureName ~= nil then
                        formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and ("|t16:16:" .. textureName .. "|t ") or ""
                    end
                    if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                        stringPart2 = ColorizeColors.LorebookColorize2:Colorize(zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                    else
                        stringPart2 = ""
                    end

                    local finalMessage = zo_strformat("<<1>><<2>><<3>>", stringPart1, formattedIcon, stringPart2)
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "COLLECTIBLE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end

                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_COLLECTION_COMPLETED)
                    messageParams:SetText(csaPrefix, zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                    messageParams:SetIconData(textureName, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_COLLECTION_COMPLETED)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end

                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionAlert then
                    local text = zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName)
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
                end
                if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                    PlaySound(SOUNDS.BOOK_COLLECTION_COMPLETED)
                end
            end
        end
        return true
    end

    -- EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE (CSA Handler)
    local function LoreCollectionXPHook(categoryIndex, collectionIndex, guildReputationIndex, skillType, skillIndex, rank, previousXP, currentXP)
        if guildReputationIndex > 0 then
            local collectionName, description, numKnownBooks, totalBooks, hidden, textureName = GetLoreCollectionInfo(categoryIndex, collectionIndex)
            local stringPrefix = ChatAnnouncements.SV.Lorebooks.LorebookCollectionPrefix
            local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_LORE_LIBRARY_COLLECTION_COMPLETED_LARGE)
            if not hidden or ChatAnnouncements.SV.Lorebooks.LorebookShowHidden then
                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCA then
                    local formattedIcon
                    local stringPart1
                    local stringPart2
                    if stringPrefix ~= "" then
                        stringPart1 = ColorizeColors.LorebookColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", bracket1[ChatAnnouncements.SV.Lorebooks.LorebookBracket], stringPrefix, bracket2[ChatAnnouncements.SV.Lorebooks.LorebookBracket]))
                    else
                        stringPart1 = ""
                    end
                    if textureName ~= "" and textureName ~= nil then
                        formattedIcon = ChatAnnouncements.SV.Lorebooks.LorebookIcon and zo_strformat("<<1>> ", zo_iconFormat(textureName, 16, 16)) or ""
                    end
                    if ChatAnnouncements.SV.Lorebooks.LorebookCategory then
                        stringPart2 = ColorizeColors.LorebookColorize2:Colorize(zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                    else
                        stringPart2 = ""
                    end

                    local finalMessage = zo_strformat("<<1>><<2>><<3>>", stringPart1, formattedIcon, stringPart2)
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "COLLECTIBLE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end

                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.BOOK_COLLECTION_COMPLETED)
                    if not LUIE.SV.HideXPBar then
                        local barType = PLAYER_PROGRESS_BAR:GetBarType(PPB_CLASS_SKILL, skillType, skillIndex)
                        local rankStartXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillIndex, rank)
                        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(barType, rank, previousXP - rankStartXP, currentXP - rankStartXP)
                        barParams:SetTriggeringEvent(EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE)
                        ValidateProgressBarParams(barParams)
                        messageParams:SetBarParams(barParams)
                    end
                    messageParams:SetText(csaPrefix, zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName))
                    messageParams:SetIconData(textureName, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end

                if ChatAnnouncements.SV.Lorebooks.LorebookCollectionAlert then
                    local text = zo_strformat(SI_LORE_LIBRARY_COLLECTION_COMPLETED_SMALL, collectionName)
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
                end
                if not ChatAnnouncements.SV.Lorebooks.LorebookCSA then
                    PlaySound(SOUNDS.BOOK_COLLECTION_COMPLETED)
                end
            end
        end
        return true
    end

    -- EVENT_SKILL_POINTS_CHANGED (CSA Handler)
    local function SkillPointsChangedHook(oldPoints, newPoints, oldPartialPoints, newPartialPoints, changeReason)
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
        local numSkillPointsGained = newPoints - oldPoints
        local stringPrefix = ChatAnnouncements.SV.Skills.SkillPointSkyshard
        local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_SKYSHARD_GAINED)
        local hasStringPrefix = stringPrefix ~= ""
        local flagDisplay, sound, finalMessage, finalText

        -- check if the skill point change was due to skyshards
        if oldPartialPoints ~= newPartialPoints or changeReason == SKILL_POINT_CHANGE_REASON_SKYSHARD_INSTANT_UNLOCK then
            flagDisplay = true
            sound = SOUNDS.SKYSHARD_GAINED
            if numSkillPointsGained < 0 then
                return
            end
            local numSkyshardsGained = (newPoints * NUM_PARTIAL_SKILL_POINTS_FOR_FULL + newPartialPoints) - (oldPoints * NUM_PARTIAL_SKILL_POINTS_FOR_FULL + oldPartialPoints)
            local largeText = zo_strformat(csaPrefix, numSkyshardsGained)
            local stringPart1, stringPart2

            -- if only the partial points changed, message out the new count of skyshard pieces
            if newPoints == oldPoints then
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_PARTIAL_GAINED)
                local skyshardGainedPoints = zo_strformat(SI_SKYSHARD_GAINED_POINTS, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
                messageParams:SetText(largeText, skyshardGainedPoints)
                finalText = zo_strformat("<<1>> (<<2>>/<<3>>)", largeText, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
                if hasStringPrefix then
                    if ChatAnnouncements.SV.Skills.SkillPointsPartial then
                        stringPart1 = ColorizeColors.SkillPointColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", bracket1[ChatAnnouncements.SV.Skills.SkillPointBracket], largeText, bracket2[ChatAnnouncements.SV.Skills.SkillPointBracket]))
                    else
                        stringPart1 = ColorizeColors.SkillPointColorize1:Colorize(zo_strformat("<<1>>!", largeText))
                    end
                else
                    stringPart1 = ""
                end
                if ChatAnnouncements.SV.Skills.SkillPointsPartial then
                    stringPart2 = ColorizeColors.SkillPointColorize2:Colorize(skyshardGainedPoints)
                else
                    stringPart2 = ""
                end
                finalMessage = zo_strformat("<<1>><<2>>", stringPart1, stringPart2)
            else
                local messageText
                -- if there are no leftover skyshard pieces, don't include them in the message
                if newPartialPoints == 0 then
                    messageText = zo_strformat(SI_SKILL_POINT_GAINED, numSkillPointsGained)
                else
                    messageText = zo_strformat(SI_SKILL_POINT_AND_SKYSHARD_PIECES_GAINED, numSkillPointsGained, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
                end
                messageParams:SetText(largeText, messageText)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_GAINED)
                finalText = messageText
                if hasStringPrefix then
                    stringPart1 = ColorizeColors.SkillPointColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", bracket1[ChatAnnouncements.SV.Skills.SkillPointBracket], largeText, bracket2[ChatAnnouncements.SV.Skills.SkillPointBracket]))
                else
                    stringPart1 = ""
                end
                stringPart2 = ColorizeColors.SkillPointColorize2:Colorize(messageText)
                finalMessage = zo_strformat("<<1>><<2>>.", stringPart1, stringPart2)
            end
        elseif numSkillPointsGained > 0 then
            if not SUPPRESS_SKILL_POINT_CSA_REASONS[changeReason] then
                flagDisplay = true
                sound = SOUNDS.SKILL_POINT_GAINED
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_GAINED)
                local skillPointGained = zo_strformat(SI_SKILL_POINT_GAINED, numSkillPointsGained)
                messageParams:SetText(skillPointGained)
                finalMessage = ColorizeColors.SkillPointColorize2:Colorize(skillPointGained .. ".")
                finalText = skillPointGained .. "."
            end
        end
        if flagDisplay then
            if ChatAnnouncements.SV.Skills.SkillPointCA and finalMessage ~= "" then
                table_insert(ChatAnnouncements.QueuedMessages, { message = finalMessage, messageType = "SKILL" })
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Skills.SkillPointCSA then
                messageParams:SetSound(sound)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Skills.SkillPointAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, finalText)
            end
            if not ChatAnnouncements.SV.Skills.SkillPointCSA then
                PlaySound(sound)
            end
        end
        return true
    end

    -- EVENT_SKILL_LINE_ADDED (CSA Handler) -- Hooked via csaCallbackHandlers[2]
    local function SkillLineAddedHook(skillLineData)
        if skillLineData:IsAvailable() then
            local skillTypeData = skillLineData:GetSkillTypeData()
            local lineName = skillLineData:GetName()
            local icon = skillTypeData:GetAnnounceIcon()

            if ChatAnnouncements.SV.Skills.SkillLineUnlockCA then
                local formattedIcon = ChatAnnouncements.SV.Skills.SkillLineIcon and zo_strformat("<<1>> ", zo_iconFormatInheritColor(icon, 16, 16)) or ""
                local formattedString = ColorizeColors.SkillLineColorize:Colorize(zo_strformat(LUIE_STRING_CA_SKILL_LINE_ADDED, formattedIcon, lineName))
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "SKILL_GAIN" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Skills.SkillLineUnlockCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
                local formattedIcon = zo_iconFormat(icon, 32, 32)
                -- Note: We set the CSA type to SKILL_POINTS_PARTIAL_GAINED instead of SKILL_LINE_ADDED so this orders itself BEFORE some other events.
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_PARTIAL_GAINED)
                messageParams:SetText(zo_strformat(SI_SKILL_LINE_ADDED, formattedIcon, lineName))
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Skills.SkillLineUnlockAlert then
                local formattedIcon = ""
                local text = zo_strformat(SI_SKILL_LINE_ADDED, formattedIcon, lineName)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end
            if not ChatAnnouncements.SV.Skills.SkillLineUnlockCSA then
                PlaySound(SOUNDS.SKILL_LINE_ADDED)
            end
            return true
        end
    end

    -- EVENT_ABILITY_PROGRESSION_RANK_UPDATE (CSA Handler)
    local function AbilityProgressionRankHook(progressionIndex, rank, maxRank, morph)
        local _, _, _, atMorph = GetAbilityProgressionXPInfo(progressionIndex)
        local name = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)

        if atMorph then
            if ChatAnnouncements.SV.Skills.SkillAbilityCA then
                local formattedString = ColorizeColors.SkillLineColorize:Colorize(zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name) .. ".")
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "SKILL_MORPH" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Skills.SkillAbilityCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ABILITY_MORPH_AVAILABLE)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ABILITY_PROGRESSION_RANK_MORPH)
                messageParams:SetText(zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name))
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Skills.SkillAbilityAlert then
                local text = zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name) .. "."
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end

            if not ChatAnnouncements.SV.Skills.SkillAbilityCSA then
                PlaySound(SOUNDS.ABILITY_MORPH_AVAILABLE)
            end
        else
            if ChatAnnouncements.SV.Skills.SkillAbilityCA then
                local formattedString = ColorizeColors.SkillLineColorize:Colorize(zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank) .. ".")
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "SKILL" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Skills.SkillAbilityCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ABILITY_RANK_UP)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ABILITY_PROGRESSION_RANK_UPDATE)
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank))
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Skills.SkillAbilityAlert then
                local text = zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank) .. "."
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end

            if not ChatAnnouncements.SV.Skills.SkillAbilityCSA then
                PlaySound(SOUNDS.ABILITY_RANK_UP)
            end
        end
        return true
    end

    -- EVENT_SKILL_RANK_UPDATE (CSA Handler)
    local function SkillRankUpdateHook(skillType, skillLineIndex, rank)
        -- crafting skill updates get deferred if they're increased while crafting animations are in progress
        -- ZO_Skills_TieSkillInfoHeaderToCraftingSkill handles triggering the deferred center screen announce in that case
        if skillType ~= SKILL_TYPE_RACIAL and (skillType ~= SKILL_TYPE_TRADESKILL or not ZO_CraftingUtils_IsPerformingCraftProcess()) then
            local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillLineIndex)
            if skillLineData and skillLineData:IsAvailable() then
                local lineName = skillLineData:GetName()

                if ChatAnnouncements.SV.Skills.SkillLineCA then
                    local formattedString = ColorizeColors.SkillLineColorize:Colorize(zo_strformat(SI_SKILL_RANK_UP, lineName, rank) .. ".")
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "SKILL_LINE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end

                if ChatAnnouncements.SV.Skills.SkillLineCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.SKILL_LINE_LEVELED_UP)
                    messageParams:SetText(zo_strformat(SI_SKILL_RANK_UP, lineName, rank))
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_RANK_UPDATE)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end

                if ChatAnnouncements.SV.Skills.SkillLineAlert then
                    local formattedText = zo_strformat(SI_SKILL_RANK_UP, lineName, rank) .. "."
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedText)
                end

                if not ChatAnnouncements.SV.Skills.SkillLineCSA then
                    PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                end
            end
        end
        return true
    end

    -- EVENT_SKILL_XP_UPDATE (CSA Handler)
    local function SkillXPUpdateHook(skillType, skillLineIndex, reason, rank, previousXP, currentXP)
        if (skillType == SKILL_TYPE_GUILD and GUILD_SKILL_SHOW_REASONS[reason]) or reason == PROGRESS_REASON_JUSTICE_SKILL_EVENT then
            if not LUIE.SV.HideXPBar then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_NO_TEXT, SOUNDS.NONE)
                local barType = PLAYER_PROGRESS_BAR:GetBarType(PPB_CLASS_SKILL, skillType, skillLineIndex)
                local rankStartXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillLineIndex, rank)
                local sound = GUILD_SKILL_SHOW_SOUNDS[reason]
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_XP_UPDATE)
                if rankStartXP ~= nil then
                    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(barType, rank, previousXP - rankStartXP, currentXP - rankStartXP)
                    barParams:SetTriggeringEvent(EVENT_SKILL_XP_UPDATE)
                    ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                else
                    assert(false, string_format("No Rank Start XP %d %d %d %d %d %d", skillType, skillLineIndex, reason, rank, previousXP, currentXP))
                end
            end
        end
        return true
    end

    -- EVENT_COLLECTION_UPDATED (CSA Handler) -- Hooked via csaCallbackHandlers[1]
    local function CollectibleUnlockedHook(collectionUpdateType, collectiblesByUnlockState)
        if collectionUpdateType == ZO_COLLECTION_UPDATE_TYPE.UNLOCK_STATE_CHANGED then
            local nowOwnedCollectibles = collectiblesByUnlockState[COLLECTIBLE_UNLOCK_STATE_UNLOCKED_OWNED]
            if nowOwnedCollectibles then
                if #nowOwnedCollectibles > MAX_INDIVIDUAL_COLLECTIBLE_UPDATES then
                    local stringPrefix = ChatAnnouncements.SV.Collectibles.CollectiblePrefix
                    local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_TITLE)

                    if ChatAnnouncements.SV.Collectibles.CollectibleCA then
                        local string1
                        if stringPrefix ~= "" then
                            string1 = ColorizeColors.CollectibleColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", bracket1[ChatAnnouncements.SV.Collectibles.CollectibleBracket], stringPrefix, bracket2[ChatAnnouncements.SV.Collectibles.CollectibleBracket]))
                        else
                            string1 = ""
                        end
                        local string2 = ColorizeColors.CollectibleColorize2:Colorize(zo_strformat(SI_COLLECTIBLES_UPDATED_ANNOUNCEMENT_BODY, #nowOwnedCollectibles) .. ".")
                        local finalString = zo_strformat("<<1>><<2>>", string1, string2)
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalString, messageType = "COLLECTIBLE" }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                    end

                    -- Set message params even if CSA is disabled, we just send a dummy event so the callback handler works correctly.
                    -- Note: This also means we don't need to Play Sound if the CSA isn't enabled since a blank one is always sent if the CSA is disabled.
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.COLLECTIBLE_UNLOCKED)
                    if ChatAnnouncements.SV.Collectibles.CollectibleCSA then
                        messageParams:SetText(csaPrefix, zo_strformat(SI_COLLECTIBLES_UPDATED_ANNOUNCEMENT_BODY, #nowOwnedCollectibles))
                        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COLLECTIBLES_UPDATED)
                        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                    end

                    if ChatAnnouncements.SV.Collectibles.CollectibleAlert then
                        local text = zo_strformat(SI_COLLECTIBLES_UPDATED_ANNOUNCEMENT_BODY, #nowOwnedCollectibles) .. "."
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
                    end
                    return true
                else
                    -- local messageParamsObjects = {}
                    for _, collectibleData in ipairs(nowOwnedCollectibles) do
                        local collectibleName = collectibleData:GetName()
                        local icon = collectibleData:GetIcon()
                        local categoryData = collectibleData:GetCategoryData()
                        local majorCategory = categoryData:GetId()
                        local majorCategoryTopLevelIndex = GetCategoryInfoFromCollectibleCategoryId(majorCategory)
                        local majorCategoryName = GetCollectibleCategoryInfo(majorCategoryTopLevelIndex)
                        local categoryName = categoryData:GetName()
                        local collectibleId = collectibleData:GetId()

                        local stringPrefix = ChatAnnouncements.SV.Collectibles.CollectiblePrefix
                        local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_TITLE)

                        if ChatAnnouncements.SV.Collectibles.CollectibleCA then
                            local link = GetCollectibleLink(collectibleId, linkBrackets[ChatAnnouncements.SV.BracketOptionCollectible])
                            local formattedIcon = ChatAnnouncements.SV.Collectibles.CollectibleIcon and string_format("|t16:16:%s|t ", icon) or ""

                            local string1
                            if stringPrefix ~= "" then
                                string1 = ColorizeColors.CollectibleColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", bracket1[ChatAnnouncements.SV.Collectibles.CollectibleBracket], stringPrefix, bracket2[ChatAnnouncements.SV.Collectibles.CollectibleBracket]))
                            else
                                string1 = ""
                            end
                            local string2
                            if ChatAnnouncements.SV.Collectibles.CollectibleCategory or ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                local categoryString
                                if ChatAnnouncements.SV.Collectibles.CollectibleCategory and ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                    categoryString = (majorCategoryName .. " - " .. categoryName)
                                elseif ChatAnnouncements.SV.Collectibles.CollectibleCategory then
                                    categoryString = majorCategoryName
                                else
                                    categoryString = categoryName
                                end
                                string2 = ColorizeColors.CollectibleColorize2:Colorize(zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, link, categoryString) .. ".")
                            else
                                string2 = link
                            end
                            local finalString = zo_strformat("<<1>><<2>><<3>>", string1, formattedIcon, string2)
                            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalString, messageType = "COLLECTIBLE" }
                            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                        end

                        -- Set message params even if CSA is disabled, we just send a dummy event so the callback handler works correctly.
                        -- Note: This also means we don't need to Play Sound if the CSA isn't enabled since a blank one is always sent if the CSA is disabled.
                        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.COLLECTIBLE_UNLOCKED)
                        if ChatAnnouncements.SV.Collectibles.CollectibleCSA then
                            local csaString
                            if ChatAnnouncements.SV.Collectibles.CollectibleCategory or ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                local categoryString
                                if ChatAnnouncements.SV.Collectibles.CollectibleCategory and ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                    categoryString = (majorCategoryName .. " - " .. categoryName)
                                elseif ChatAnnouncements.SV.Collectibles.CollectibleCategory then
                                    categoryString = majorCategoryName
                                else
                                    categoryString = categoryName
                                end
                                csaString = zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, collectibleName, categoryString)
                            else
                                csaString = zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, collectibleName, categoryName)
                            end
                            messageParams:SetText(csaPrefix, csaString)
                            messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
                            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SINGLE_COLLECTIBLE_UPDATED)
                            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                        end

                        if ChatAnnouncements.SV.Collectibles.CollectibleAlert then
                            local alertString
                            if ChatAnnouncements.SV.Collectibles.CollectibleCategory or ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                local categoryString
                                if ChatAnnouncements.SV.Collectibles.CollectibleCategory and ChatAnnouncements.SV.Collectibles.CollectibleSubcategory then
                                    categoryString = (majorCategoryName .. " - " .. categoryName)
                                elseif ChatAnnouncements.SV.Collectibles.CollectibleCategory then
                                    categoryString = majorCategoryName
                                else
                                    categoryString = categoryName
                                end
                                alertString = zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, collectibleName, categoryString .. ".")
                            else
                                alertString = zo_strformat(SI_COLLECTIONS_UPDATED_ANNOUNCEMENT_BODY, collectibleName, categoryName .. ".")
                            end
                            local text = alertString
                            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
                        end
                    end
                    return true
                end
            end
        end
    end

    local function ResetQuestRewardStatus()
        g_itemReceivedIsQuestReward = false
    end

    local function ResetQuestAbandonStatus()
        g_itemReceivedIsQuestAbandon = false
    end

    -- EVENT_QUEST_ADDED (CSA Handler)
    local function QuestAddedHook(journalIndex, questName, objectiveName)
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        local questType = GetJournalQuestType(journalIndex)
        local instanceDisplayType = GetJournalQuestZoneDisplayType(journalIndex)
        local questJournalObject = SYSTEMS:GetObject("questJournal")
        local iconTexture = questJournalObject and questJournalObject:GetIconTexture(questType, instanceDisplayType)

        -- Add quest to index
        g_questIndex[questName] =
        {
            questType = questType,
            instanceDisplayType = instanceDisplayType,
        }

        if ChatAnnouncements.SV.Quests.QuestAcceptCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_ACCEPTED)
            if iconTexture then
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_ACCEPT_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName))
            else
                messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_ACCEPT, questName))
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestAcceptAlert then
            local alertString
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                alertString = zo_strformat(LUIE_STRING_CA_QUEST_ACCEPT_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
            else
                alertString = zo_strformat(SI_NOTIFYTEXT_QUEST_ACCEPT, questName)
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertString)
        end

        -- If we don't have either CSA or Alert on (then we want to play a sound here)
        if not ChatAnnouncements.SV.Quests.QuestAcceptCSA then
            PlaySound(SOUNDS.QUEST_ACCEPTED)
        end

        if ChatAnnouncements.SV.Quests.QuestAcceptCA then
            local questNameFormatted
            local stepText = GetJournalQuestStepInfo(journalIndex, 1)
            local formattedString

            if ChatAnnouncements.SV.Quests.QuestLong then
                questNameFormatted = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ColorizeColors.QuestColorQuestNameColorize:ToHex(), questName, ColorizeColors.QuestColorQuestDescriptionColorize, stepText))
            else
                questNameFormatted = (zo_strformat("|c<<1>><<2>>|r", ColorizeColors.QuestColorQuestNameColorize:ToHex(), questName))
            end
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                formattedString = string_format(GetString(LUIE_STRING_CA_QUEST_ACCEPT) .. zo_iconFormat(iconTexture, 16, 16) .. " " .. questNameFormatted)
            else
                formattedString = string_format("%s%s", GetString(LUIE_STRING_CA_QUEST_ACCEPT), questNameFormatted)
            end

            -- If this message is duplicated by another addon then don't display twice.
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].message == formattedString then
                    return true
                end
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "QUEST" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        return true
    end

    -- EVENT_QUEST_COMPLETE (CSA Handler)
    local function QuestCompleteHook(questName, level, previousExperience, currentExperience, championPoints, questType, instanceDisplayType)
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        local questJournalObject = SYSTEMS:GetObject("questJournal")
        local iconTexture = questJournalObject and questJournalObject:GetIconTexture(questType, instanceDisplayType)

        if ChatAnnouncements.SV.Quests.QuestCompleteCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_COMPLETED)
            if iconTexture then
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName))
            else
                messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questName))
            end
            if not LUIE.SV.HideXPBar then
                messageParams:SetBarParams(GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_QUEST_COMPLETE))
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_COMPLETED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestCompleteAlert then
            local alertString
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                alertString = zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
            else
                alertString = zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questName)
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertString)
        end

        if ChatAnnouncements.SV.Quests.QuestCompleteCA then
            local questNameFormatted = (zo_strformat("|cFFA500<<1>>|r", questName))
            local formattedString
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                formattedString = zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, 16, 16), questNameFormatted)
            else
                formattedString = zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questNameFormatted)
            end
            -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].message == formattedString then
                    return true
                end
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "QUEST" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        -- If we don't have either CSA or Alert on (then we want to play a sound here)
        if not ChatAnnouncements.SV.Quests.QuestCompleteCSA then
            PlaySound(SOUNDS.QUEST_COMPLETED)
        end

        -- We set this variable to true in order to override the [Looted] message syntax that would be applied to a quest reward normally.
        if ChatAnnouncements.SV.Inventory.Loot then
            g_itemReceivedIsQuestReward = true
            LUIE_CallLater(ResetQuestRewardStatus, 500)
        end

        return true
    end

    -- EVENT_OBJECTIVE_COMPLETED (CSA Handler)
    -- Note we don't play a sound if the CSA is disabled here because the Quest complete message will already do this.
    local function ObjectiveCompletedHook(zoneIndex, poiIndex, level, previousExperience, currentExperience, championPoints)
        local name, _, _, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
        local nameFormatted
        local formattedText

        if ChatAnnouncements.SV.Quests.QuestLocLong and finishedDescription ~= "" then
            nameFormatted = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ColorizeColors.QuestColorLocNameColorize, name, ColorizeColors.QuestColorLocDescriptionColorize, finishedDescription))
        else
            nameFormatted = (zo_strformat("|c<<1>><<2>>|r", ColorizeColors.QuestColorLocNameColorize, name))
        end
        formattedText = zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, nameFormatted)

        if ChatAnnouncements.SV.Quests.QuestCompleteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, name))
        end

        if ChatAnnouncements.SV.Quests.QuestCompleteCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_COMPLETED)
            if not LUIE.SV.HideXPBar then
                messageParams:SetBarParams(GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_OBJECTIVE_COMPLETED))
            end
            messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, name), finishedDescription)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_OBJECTIVE_COMPLETED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestCompleteCA then
            -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].message == formattedText then
                    return true
                end
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedText, messageType = "QUEST" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        return true
    end

    -- EVENT_QUEST_CONDITION_COUNTER_CHANGED (CSA Handler)
    -- Note: Used for quest failure and updates
    local function ConditionCounterHook(journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden, isConditionCompleteChanged)
        if isStepHidden or (isPushed and isComplete) or (currConditionVal >= newConditionVal) then
            return true
        end

        -- Debug for DEVS
        --         if LUIE.IsDevDebugEnabled() then
        --             LUIE.Debug([[Quest Condition Update:
        -- --> Type: %s (%d)
        -- --> Quest: %s
        -- --> Condition: %s
        -- --> Progress: %d/%d (Previous: %d)
        -- --> State: %s]],
        --                 tostring(conditionType),
        --                 conditionType,
        --                 questName,
        --                 conditionText,
        --                 newConditionVal,
        --                 conditionMax,
        --                 currConditionVal,
        --                 isConditionComplete and "Complete" or "In Progress"
        --             )
        --         end

        -- Check WritCreater settings first
        if isWritCreatorEnabled and WritCreater and WritCreater:GetSettings().suppressQuestAnnouncements and isQuestWritQuest(journalIndex) then
            --             if LUIE.IsDevDebugEnabled() then
            --                 LUIE.Debug([[Writ Quest Condition Suppressed:
            -- --> Quest: %s
            -- --> Index: %d
            -- --> Condition: %s]],
            --                     questName,
            --                     journalIndex,
            --                     conditionText
            --                 )
            --             end
            return true
        end

        local messageType      -- This variable represents whether this message is an objective update or failure state message (1 = update, 2 = failure) There are too many conditionals to resolve what we need to print inside them so we do it after setting the formatting.
        local alertMessage     -- Variable for alert message
        local formattedMessage -- Variable for CA Message
        local sound            -- Set correct sound based off context
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)

        if newConditionVal ~= currConditionVal and not isFailCondition then
            sound = isConditionComplete and SOUNDS.QUEST_OBJECTIVE_COMPLETE or SOUNDS.QUEST_OBJECTIVE_INCREMENT
            messageParams:SetSound(sound)
        end

        if isConditionComplete and conditionType == QUEST_CONDITION_TYPE_GIVE_ITEM or conditionType == QUEST_CONDITION_TYPE_TALK_TO then
            -- We set this variable to true in order to override the [Looted] message syntax that would be applied to a quest reward normally.
            if ChatAnnouncements.SV.Inventory.Loot then
                g_itemReceivedIsQuestReward = true
                LUIE_CallLater(ResetQuestRewardStatus, 500)
            end
        end

        if isConditionComplete and conditionType == QUEST_CONDITION_TYPE_GIVE_ITEM then
            messageParams:SetText(zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText))
            alertMessage = zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText)
            formattedMessage = zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText)
            messageType = 1
        elseif stepOverrideText == "" then
            if isFailCondition then
                if conditionMax > 1 then
                    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax))
                    alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax)
                    formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax)
                else
                    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText))
                    alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText)
                    formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText)
                end
                messageType = 2
            else
                if conditionMax > 1 and newConditionVal < conditionMax then
                    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax))
                    alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax)
                    formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax)
                else
                    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText))
                    alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText)
                    formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText)
                end
                messageType = 1
            end
        else
            if isFailCondition then
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText))
                alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText)
                formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText)
                messageType = 2
            else
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText))
                alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText)
                formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText)
                messageType = 1
            end
        end

        -- Override text if its listed in the override table.
        if Quests.QuestObjectiveCompleteOverride[formattedMessage] then
            messageParams:SetText(Quests.QuestObjectiveCompleteOverride[formattedMessage])
            alertMessage = Quests.QuestObjectiveCompleteOverride[formattedMessage]
            formattedMessage = Quests.QuestObjectiveCompleteOverride[formattedMessage]
        end

        if isConditionComplete then
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_CONDITION_COMPLETED)
        else
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
        end

        if messageType == 1 then
            if ChatAnnouncements.SV.Quests.QuestObjCompleteCA then
                -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
                for i = 1, #ChatAnnouncements.QueuedMessages do
                    if ChatAnnouncements.QueuedMessages[i].message == formattedMessage then
                        return true
                    end
                end
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, messageType = "MESSAGE" } -- We set the message messageType to MESSAGE so if we loot a quest item that progresses the quest this comes after.
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Quests.QuestObjCompleteAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
            end
            if not ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
                PlaySound(sound)
            end
        end

        if messageType == 2 then
            if ChatAnnouncements.SV.Quests.QuestFailCA then
                -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
                for i = 1, #ChatAnnouncements.QueuedMessages do
                    if ChatAnnouncements.QueuedMessages[i].message == formattedMessage then
                        return true
                    end
                end
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, messageType = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end
            if ChatAnnouncements.SV.Quests.QuestFailCSA then
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Quests.QuestFailAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
            end
            if not ChatAnnouncements.SV.Quests.QuestFailCSA then
                PlaySound(sound)
            end
        end

        return true
    end

    -- EVENT_QUEST_OPTIONAL_STEP_ADVANCED (CSA Handler)
    local function OptionalStepHook(text)
        if text ~= "" then
            local message = zo_strformat("|c<<1>><<2>>|r", ColorizeColors.QuestColorQuestDescriptionColorize, text)
            local formattedString = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, message)

            if ChatAnnouncements.SV.Quests.QuestObjCompleteCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_COMPLETE)
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, text))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Quests.QuestObjCompleteAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
            end
            if not ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
                PlaySound(SOUNDS.QUEST_OBJECTIVE_COMPLETE)
            end
        end
        return true
    end

    -- EVENT_QUEST_REMOVED (Registered through CSA_MiscellaneousHandlers)
    local function OnQuestRemoved(eventId, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
        if isCompleted then
            return
        end

        if ChatAnnouncements.SV.Quests.QuestAbandonCA or ChatAnnouncements.SV.Quests.QuestAbandonCSA or ChatAnnouncements.SV.Quests.QuestAbandonAlert then
            local iconTexture

            if g_questIndex[questName] then
                local questJournalObject = SYSTEMS:GetObject("questJournal")
                local questType = g_questIndex[questName].questType
                local instanceDisplayType = g_questIndex[questName].instanceDisplayType
                iconTexture = questJournalObject and questJournalObject:GetIconTexture(questType, instanceDisplayType)
            end

            if ChatAnnouncements.SV.Quests.QuestAbandonCA then
                local questNameFormatted = (zo_strformat("|cFFA500<<1>>|r", questName))
                local formattedString
                if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, 16, 16), questNameFormatted)
                else
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questNameFormatted)
                end
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Quests.QuestAbandonCSA then
                local formattedString
                if iconTexture then
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
                else
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questName)
                end
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_ABANDONED)
                messageParams:SetText(formattedString)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
                -- CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Quests.QuestAbandonAlert then
                local formattedString
                if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
                else
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questName)
                end
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
            end
        end
        if not ChatAnnouncements.SV.Quests.QuestAbandonCSA then
            PlaySound(SOUNDS.QUEST_ABANDONED)
        end

        -- We set this variable to true in order to override the message syntax that would be applied to a quest reward normally with [Removed] instead.
        if ChatAnnouncements.SV.Inventory.Loot then
            g_itemReceivedIsQuestAbandon = true
            LUIE_CallLater(ResetQuestAbandonStatus, 500)
        end

        g_questIndex[questName] = nil
    end

    -- EVENT_QUEST_ADVANCED (Registered through CSA_MiscellaneousHandlers)
    -- Note: Quest Advancement displays all the "appropriate" conditions that the player needs to do to advance the current step
    local function OnQuestAdvanced(eventId, questIndex, questName, isPushed, isComplete, mainStepChanged, soundOverride)
        -- Check if WritCreater is enabled & then call a copy of a local function from WritCreater to check if this is a Writ Quest
        if isWritCreatorEnabled and WritCreater and WritCreater:GetSettings().suppressQuestAnnouncements and isQuestWritQuest(questIndex) then
            --             if LUIE.IsDevDebugEnabled() then
            --                 LUIE.Debug([[Writ Quest Condition Suppressed:
            -- --> Quest: %s
            -- --> Index: %d
            -- --> Condition: %s]],
            --                     questName,
            --                     questIndex,
            --                     isComplete and "Complete" or "Not Complete"
            --                 )
            --             end
            return true
        end

        if not mainStepChanged then
            return
        end

        local sound = SOUNDS.QUEST_OBJECTIVE_STARTED

        for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
            local _, visibility, stepType, stepOverrideText, conditionCount = GetJournalQuestStepInfo(questIndex, stepIndex)

            -- Override text if its listed in the override table.
            if Quests.QuestAdvancedOverride[stepOverrideText] then
                stepOverrideText = Quests.QuestAdvancedOverride[stepOverrideText]
            end

            if visibility == nil or visibility == QUEST_STEP_VISIBILITY_OPTIONAL then
                if stepOverrideText ~= "" then
                    if ChatAnnouncements.SV.Quests.QuestObjUpdateCA then
                        -- This event sometimes results in duplicate messages - if an equivalent message is already detected in queue, then abort!
                        for i = 1, #ChatAnnouncements.QueuedMessages do
                            if ChatAnnouncements.QueuedMessages[i].message == stepOverrideText then
                                -- Set the old message to blank so it gets skipped by the printer
                                ChatAnnouncements.QueuedMessages[i].message = ""
                            end
                        end
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = stepOverrideText, messageType = "MESSAGE" }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                    end
                    if ChatAnnouncements.SV.Quests.QuestObjUpdateCSA then
                        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, sound)
                        messageParams:SetText(stepOverrideText)
                        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
                        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                        sound = SOUNDS.NONE -- no longer needed, we played it once
                    end
                    if ChatAnnouncements.SV.Quests.QuestObjUpdateAlert then
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, stepOverrideText)
                    end
                else
                    for conditionIndex = 1, conditionCount do
                        local conditionText, curCount, maxCount, isFailCondition, isConditionComplete, _, isVisible = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex, false)

                        if not (isFailCondition or isConditionComplete) and isVisible then
                            if ChatAnnouncements.SV.Quests.QuestObjUpdateCA then
                                -- This event sometimes results in duplicate messages - if an equivalent message is already detected in queue, then abort!
                                for i = 1, #ChatAnnouncements.QueuedMessages do
                                    if ChatAnnouncements.QueuedMessages[i].message == conditionText then
                                        -- Set the old message to blank so it gets skipped by the printer
                                        ChatAnnouncements.QueuedMessages[i].message = ""
                                    end
                                end
                                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = conditionText, messageType = "MESSAGE" }
                                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                            end
                            if ChatAnnouncements.SV.Quests.QuestObjUpdateCSA then
                                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, sound)
                                messageParams:SetText(conditionText)
                                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
                                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                                sound = SOUNDS.NONE -- no longer needed, we played it once
                            end
                            if ChatAnnouncements.SV.Quests.QuestObjUpdateAlert then
                                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, conditionText)
                            end
                        end
                    end
                end
                -- We send soundOverride = true from OnQuestAdded in order to stop the sound from spamming if CSA isn't on and a quest is accepted.
                if not ChatAnnouncements.SV.Quests.QuestObjUpdateCSA and not soundOverride then
                    PlaySound(SOUNDS.QUEST_OBJECTIVE_STARTED)
                end
            end
        end
    end

    -- EVENT_QUEST_ADDED (Registered through CSA_MiscellaneousHandlers)
    local function OnQuestAdded(eventId, questIndex)
        -- Handle WritCrafter integration
        if isWritCreatorEnabled and WritCreater then
            -- Auto-abandon quests with disallowed materials
            local rejectedMat = rejectQuest(questIndex)
            if rejectedMat then
                local questName = GetJournalQuestName(questIndex)
                printToChat(zo_strformat("Writ Crafter abandoned the <<1>> because it requires <<2>> which was disallowed in settings", questName, rejectedMat), true)
                LUIE_CallLater(function ()
                    AbandonQuest(questIndex)
                end, 500)
                return
            end
            -- Suppress announcements for writ quests if configured
            if WritCreater:GetSettings().suppressQuestAnnouncements and isQuestWritQuest(questIndex) then
                return true
            end
        end

        OnQuestAdvanced(EVENT_QUEST_ADVANCED, questIndex, nil, nil, nil, true, true)
    end

    -- EVENT_DISCOVERY_EXPERIENCE (CSA Handler)
    local function DiscoveryExperienceHook(subzoneName, level, previousExperience, currentExperience, championPoints)
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        if ChatAnnouncements.SV.Quests.QuestLocDiscoveryCA then
            local nameFormatted = (zo_strformat("|c<<1>><<2>>|r", ColorizeColors.QuestColorLocNameColorize, subzoneName))
            local formattedString = zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, nameFormatted)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "QUEST" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Quests.QuestLocDiscoveryCSA and not INTERACT_WINDOW:IsShowingInteraction() then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_DISCOVERED)
            if currentExperience > previousExperience then
                if not LUIE.SV.HideXPBar then
                    messageParams:SetBarParams(GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_DISCOVERY_EXPERIENCE))
                end
            end
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, subzoneName))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISCOVERY_EXPERIENCE)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestLocDiscoveryAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, subzoneName))
        end

        if not ChatAnnouncements.SV.Quests.QuestLocDiscoveryCSA then
            PlaySound(SOUNDS.OBJECTIVE_DISCOVERED)
        end
        return true
    end

    -- EVENT_POI_DISCOVERED (CSA Handler)
    local function PoiDiscoveredHook(zoneIndex, poiIndex)
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        local name, _, startDescription = GetPOIInfo(zoneIndex, poiIndex)

        if ChatAnnouncements.SV.Quests.QuestLocObjectiveCA then
            local formattedString = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ColorizeColors.QuestColorLocNameColorize, name, ColorizeColors.QuestColorLocDescriptionColorize, startDescription))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "QUEST_POI" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Quests.QuestLocObjectiveCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_ACCEPTED)
            messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_DISCOVERED, name), startDescription)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestLocObjectiveAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_DISCOVERED, name), startDescription)
        end
        return true
    end

    local XP_GAIN_SHOW_REASONS =
    {
        [PROGRESS_REASON_PVP_EMPEROR] = true,
        [PROGRESS_REASON_DUNGEON_CHALLENGE] = true,
        [PROGRESS_REASON_OVERLAND_BOSS_KILL] = true,
        [PROGRESS_REASON_SCRIPTED_EVENT] = true,
        [PROGRESS_REASON_LOCK_PICK] = true,
        [PROGRESS_REASON_LFG_REWARD] = true,
    }

    local XP_GAIN_SHOW_SOUNDS =
    {
        [PROGRESS_REASON_OVERLAND_BOSS_KILL] = SOUNDS.OVERLAND_BOSS_KILL,
        [PROGRESS_REASON_LOCK_PICK] = SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION,
    }

    -- EVENT_EXPERIENCE_GAIN (CSA Handler)
    -- Note: This function is prehooked in order to allow the XP bar popup to be hidden. In addition we shift the sound over
    local function ExperienceGainHook(reason, level, previousExperience, currentExperience, championPoints)
        local sound = XP_GAIN_SHOW_SOUNDS[reason]

        if XP_GAIN_SHOW_REASONS[reason] and not LUIE.SV.HideXPBar then
            local barParams = GetRelevantBarParams(level, previousExperience, currentExperience, championPoints)
            if barParams then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_NO_TEXT, SOUNDS.NONE)
                barParams:SetSound(sound)
                ValidateProgressBarParams(barParams)
                messageParams:SetBarParams(barParams)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_EXPERIENCE_GAIN)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end

        -- We want to play a sound still even if the bar popup is hidden, but the delay needs to remain intact so we add a blank CSA with sound.
        if XP_GAIN_SHOW_REASONS[reason] and LUIE.SV.HideXPBar and sound ~= nil then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
            messageParams:SetSound(sound)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_EXPERIENCE_GAIN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Level up notification
        local levelSize = GetNumExperiencePointsInLevel(level)
        if levelSize ~= nil and currentExperience >= levelSize then
            eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
            ChatAnnouncements.PrintBufferedXP()

            local CurrentLevel = level + 1
            if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
                local icon
                if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                    icon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and ZO_XP_BAR_GRADIENT_COLORS[2]:Colorize(" " .. zo_iconFormatInheritColor("LuiExtended/media/unitframes/unitframes_level_normal.dds", 16, 16)) or ""
                else
                    icon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and (" " .. zo_iconFormat("LuiExtended/media/unitframes/unitframes_level_normal.dds", 16, 16)) or ""
                end

                local CurrentLevelFormatted = ""
                if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                    CurrentLevelFormatted = ZO_XP_BAR_GRADIENT_COLORS[2]:Colorize(GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL) .. " " .. CurrentLevel)
                else
                    CurrentLevelFormatted = ColorizeColors.ExperienceLevelUpColorize:Colorize(GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL) .. " " .. CurrentLevel)
                end

                local formattedString
                if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                    formattedString = zo_strformat("<<1>><<2>> <<3>><<4>>", ColorizeColors.ExperienceLevelUpColorize:Colorize(GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP)), icon, CurrentLevelFormatted, ColorizeColors.ExperienceLevelUpColorize:Colorize("!"))
                else
                    formattedString = zo_strformat("<<1>><<2>> <<3>><<4>>", ColorizeColors.ExperienceLevelUpColorize:Colorize(GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP)), icon, CurrentLevelFormatted, ColorizeColors.ExperienceLevelUpColorize:Colorize("!"))
                end
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "EXPERIENCE_LEVEL" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                local iconCSA = (" " .. zo_iconFormat("LuiExtended/media/unitframes/unitframes_level_up.dds", "100%", "100%")) or ""
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)
                if ChatAnnouncements.SV.XP.ExperienceLevelUpCSAExpand then
                    local levelUpExpanded = zo_strformat("<<1>><<2>> <<3>> <<4>>", GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP), iconCSA, GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL), CurrentLevel)
                    messageParams:SetText(zo_strformat(SI_LEVEL_UP_NOTIFICATION), levelUpExpanded)
                else
                    messageParams:SetText(GetString(SI_LEVEL_UP_NOTIFICATION))
                end
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LEVEL_GAIN)
                if not LUIE.SV.HideXPBar then
                    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_XP, level + 1, currentExperience - levelSize, currentExperience - levelSize)
                    barParams:SetShowNoGain(true)
                    barParams:SetTriggeringEvent(EVENT_EXPERIENCE_GAIN)
                    ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                end
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
                local iconAlert = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and (" " .. zo_iconFormat("LuiExtended/media/unitframes/unitframes_level_up.dds", "75%", "75%")) or ""
                local text = zo_strformat("<<1>><<2>> <<3>> <<4>>!", GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP), iconAlert, GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL), CurrentLevel)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end

            -- Play Sound even if CSA is disabled
            if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                PlaySound(SOUNDS.LEVEL_UP)
            end
        end

        return true
    end

    -- Called by EnlightenGainHook()
    local function GetEnlightenedGainedAnnouncement(triggeringEvent)
        local formattedString = zo_strformat("<<1>>! <<2>>", GetString(SI_ENLIGHTENED_STATE_GAINED_HEADER), GetString(SI_ENLIGHTENED_STATE_GAINED_DESCRIPTION))
        if ChatAnnouncements.SV.XP.ExperienceEnlightenedCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "EXPERIENCE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ENLIGHTENED_STATE_GAINED)
            messageParams:SetText(zo_strformat(SI_ENLIGHTENED_STATE_GAINED_HEADER), zo_strformat(SI_ENLIGHTENED_STATE_GAINED_DESCRIPTION))
            if not LUIE.SV.HideXPBar then
                local barParams = GetCurrentChampionPointsBarParams(triggeringEvent)
                ValidateProgressBarParams(barParams)
                messageParams:SetBarParams(barParams)
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENLIGHTENMENT_GAINED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.XP.ExperienceEnlightenedAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
        end

        if not ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
            PlaySound(SOUNDS.ENLIGHTENED_STATE_GAINED)
        end

        return true
    end

    -- EVENT_ENLIGHTENED_STATE_GAINED (CSA Handler)
    local function EnlightenGainHook()
        if IsEnlightenedAvailableForCharacter() then
            return GetEnlightenedGainedAnnouncement(EVENT_ENLIGHTENED_STATE_GAINED)
        end
    end

    -- EVENT_ENLIGHTENED_STATE_LOST (CSA Handler)
    local function EnlightenLostHook()
        if IsEnlightenedAvailableForCharacter() then
            local formattedString = zo_strformat("<<1>>!", GetString(SI_ENLIGHTENED_STATE_LOST_HEADER))

            if ChatAnnouncements.SV.XP.ExperienceEnlightenedCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "EXPERIENCE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ENLIGHTENED_STATE_LOST)
                if not LUIE.SV.HideXPBar then
                    local barParams = GetCurrentChampionPointsBarParams(EVENT_ENLIGHTENED_STATE_LOST)
                    ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                end
                messageParams:SetText(zo_strformat(SI_ENLIGHTENED_STATE_LOST_HEADER))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENLIGHTENMENT_LOST)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.XP.ExperienceEnlightenedAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedString)
            end

            if not ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
                PlaySound(SOUNDS.ENLIGHTENED_STATE_LOST)
            end
        end

        return true
    end

    local firstActivation = true
    -- EVENT_PLAYER_ACTIVATED (CSA Handler)
    local function PlayerActivatedHook()
        if firstActivation then
            firstActivation = false

            if IsEnlightenedAvailableForCharacter() and GetEnlightenedPool() > 0 then
                return GetEnlightenedGainedAnnouncement(EVENT_PLAYER_ACTIVATED)
            end
        end
        return true
    end

    -- EVENT_RIDING_SKILL_IMPROVEMENT (CSA Handler)
    -- Note: This function is effected by a throttle in centerscreenannouncehandlers, we resolve any message that needs to be throttled in this function.
    -- Note: We allow the CSA handler to handle any changes made from skill books in order to properly throttle all messages, and use the alert handler for stables upgrades.
    local function RidingSkillImprovementHook(ridingSkill, previous, current, source)
        if source == RIDING_TRAIN_SOURCE_ITEM then
            if ChatAnnouncements.SV.Notify.StorageRidingCA then
                -- TODO: Switch to using Recipe/Learn variable in the future
                if ChatAnnouncements.SV.Inventory.Loot then
                    local icon
                    local bookString
                    local value = current - previous
                    local learnString = GetString(LUIE_STRING_CA_STORAGE_LEARN)

                    if ridingSkill == 1 then
                        if ChatAnnouncements.SV.BracketOptionItem == 1 then
                            bookString = "|H0:item:64700:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                        else
                            bookString = "|H1:item:64700:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                        end
                        icon = "|t16:16:/esoui/art/icons/store_ridinglessons_speed.dds|t "
                    elseif ridingSkill == 2 then
                        if ChatAnnouncements.SV.BracketOptionItem == 1 then
                            bookString = "|H0:item:64702:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                        else
                            bookString = "|H1:item:64702:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                        end
                        icon = "|t16:16:/esoui/art/icons/store_ridinglessons_capacity.dds|t "
                    elseif ridingSkill == 3 then
                        if ChatAnnouncements.SV.BracketOptionItem == 1 then
                            bookString = "|H0:item:64701:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                        else
                            bookString = "|H1:item:64701:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
                        end
                        icon = "|t16:16:/esoui/art/icons/store_ridinglessons_stamina.dds|t "
                    end

                    local formattedColor = ColorizeColors.StorageRidingBookColorize:ToHex()

                    local messageP1 = ChatAnnouncements.SV.Inventory.LootIcons and (icon .. bookString) or bookString
                    local formattedString = (messageP1 .. "|r|cFFFFFF x" .. value .. "|r|c" .. formattedColor)
                    local messageP2 = string_format(learnString, formattedString)
                    local finalMessage = string_format("|c%s%s|r", formattedColor, messageP2)

                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "MESSAGE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
                end

                local formattedString = ColorizeColors.StorageRidingColorize:Colorize(zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingAlert then
                local text = zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end

            if ChatAnnouncements.SV.Notify.StorageRidingCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
                messageParams:SetText(GetString(SI_RIDING_SKILL_ANNOUCEMENT_BANNER), zo_strformat(SI_RIDING_SKILL_ANNOUCEMENT_SKILL_INCREASE, GetString("SI_RIDINGTRAINTYPE", ridingSkill), previous, current))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RIDING_SKILL_IMPROVEMENT)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end
        return true
    end

    -- EVENT_INVENTORY_BAG_CAPACITY_CHANGED (CSA Handler)
    local function InventoryBagCapacityHook(previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
        if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
            if ChatAnnouncements.SV.Notify.StorageBagCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
                messageParams:SetText(GetString(SI_INVENTORY_BAG_UPGRADE_ANOUNCEMENT_TITLE), zo_strformat(SI_INVENTORY_BAG_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BAG_CAPACITY_CHANGED)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end
        return true
    end

    -- EVENT_INVENTORY_BANK_CAPACITY_CHANGED (CSA Handler)
    local function InventoryBankCapacityHook(previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
        if previousCapacity > 0 and previousCapacity ~= currentCapacity and previousUpgrade ~= currentUpgrade then
            if ChatAnnouncements.SV.Notify.StorageBagCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
                messageParams:SetText(GetString(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_TITLE), zo_strformat(SI_INVENTORY_BANK_UPGRADE_ANOUNCEMENT_DESCRIPTION, previousCapacity, currentCapacity))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_BANK_CAPACITY_CHANGED)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end
        return true
    end

    local CHAMPION_UNLOCKED_LIFESPAN_MS = 12000
    -- EVENT_CHAMPION_LEVEL_ACHIEVED (CSA Handler)
    local function ChampionLevelAchievedHook(wasChampionSystemUnlocked)
        local icon = ZO_GetChampionPointsIcon()

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
            local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat("<<1>> ", zo_iconFormatInheritColor(icon, 16, 16)) or ""
            local formattedString = ColorizeColors.ExperienceLevelUpColorize:Colorize(zo_strformat(GetString(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED), formattedIcon))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "EXPERIENCE_LEVEL" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINT_GAINED)
            local formattedIcon = zo_strformat("<<1>> ", zo_iconFormat(icon, "100%", "100%"))
            messageParams:SetText(zo_strformat(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED, formattedIcon))
            if not LUIE.SV.HideXPBar then
                if wasChampionSystemUnlocked then
                    local championPoints = GetPlayerChampionPointsEarned()
                    local currentChampionXP = GetPlayerChampionXP()
                    if not LUIE.SV.HideXPBar then
                        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, currentChampionXP, currentChampionXP)
                        barParams:SetTriggeringEvent(EVENT_CHAMPION_LEVEL_ACHIEVED)
                        barParams:SetShowNoGain(true)
                        ValidateProgressBarParams(barParams)
                        messageParams:SetBarParams(barParams)
                    end
                else
                    local totalChampionPoints = GetPlayerChampionPointsEarned()
                    local championXPGained = 0
                    for i = 0, (totalChampionPoints - 1) do
                        championXPGained = championXPGained + GetNumChampionXPInChampionPoint(i)
                    end
                    if not LUIE.SV.HideXPBar then
                        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, 0, 0, championXPGained)
                        barParams:SetTriggeringEvent(EVENT_CHAMPION_LEVEL_ACHIEVED)
                        ValidateProgressBarParams(barParams)
                        messageParams:SetBarParams(barParams)
                    end
                    messageParams:SetLifespanMS(CHAMPION_UNLOCKED_LIFESPAN_MS)
                end
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_LEVEL_ACHIEVED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
            local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat("<<1>> ", zo_iconFormat(icon, "75%", "75%")) or ""
            local text = zo_strformat(GetString(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED), formattedIcon)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end

        if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            PlaySound(SOUNDS.CHAMPION_POINT_GAINED)
        end

        return true
    end

    local savedEndingPoints = 0 -- We reset this value after the throttled function sends info to the chat printer
    local savedPointDelta = 0   -- We reset this value after the throttled function sends info to the chat printer

    local function ChampionPointGainedPrinter()
        -- adding one so that we are starting from the first gained point instead of the starting champion points
        local startingPoints = savedEndingPoints - savedPointDelta + 1
        local championPointsByType =
        {
            [CHAMPION_DISCIPLINE_TYPE_WORLD] = 0,
            [CHAMPION_DISCIPLINE_TYPE_COMBAT] = 0,
            [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = 0,
        }

        while startingPoints <= savedEndingPoints do
            local pointType = GetChampionPointPoolForRank(startingPoints)
            championPointsByType[pointType] = championPointsByType[pointType] + 1
            startingPoints = startingPoints + 1
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
            local formattedString = ColorizeColors.ExperienceLevelUpColorize:Colorize(zo_strformat(SI_CHAMPION_POINT_EARNED, savedPointDelta) .. ": ")
            eventManager:UnregisterForUpdate(moduleName .. "Printer")
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "EXPERIENCE_LEVEL" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages)
        end

        local secondLine = ""
        if ChatAnnouncements.SV.XP.ExperienceLevelUpCA or ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            for pointType, amount in pairs(championPointsByType) do
                if amount > 0 then
                    local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(pointType)
                    if disciplineData == nil then
                        return
                    end
                    local icon = disciplineData:GetHUDIcon()
                    local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat(" <<1>>", zo_iconFormat(icon, 16, 16)) or ""
                    local disciplineName = disciplineData:GetRawName()

                    local formattedString
                    if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                        formattedString = ZO_CP_BAR_GRADIENT_COLORS[pointType][2]:Colorize(zo_strformat(LUIE_STRING_CHAMPION_POINT_TYPE, amount, formattedIcon, disciplineName))
                    else
                        formattedString = ColorizeColors.ExperienceLevelUpColorize:Colorize(zo_strformat(LUIE_STRING_CHAMPION_POINT_TYPE, amount, formattedIcon, disciplineName))
                    end
                    if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
                        eventManager:UnregisterForUpdate(moduleName .. "Printer")
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, messageType = "EXPERIENCE_LEVEL" }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages)
                    end
                    if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                        secondLine = secondLine .. zo_strformat(SI_CHAMPION_POINT_TYPE, amount, icon, disciplineName) .. "\n"
                    end
                end
            end
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINT_GAINED)
            messageParams:SetText(zo_strformat(SI_CHAMPION_POINT_EARNED, savedPointDelta), secondLine)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
            messageParams:MarkSuppressIconFrame()
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
            local text = zo_strformat("<<1>>!", GetString(SI_CHAMPION_POINT_EARNED, savedPointDelta))
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end

        if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            PlaySound(SOUNDS.CHAMPION_POINT_GAINED)
        end

        savedEndingPoints = 0
        savedPointDelta = 0

        eventManager:UnregisterForUpdate(moduleName .. "ChampionPointThrottle")
    end

    -- EVENT_CHAMPION_POINT_GAINED (CSA Handler)
    local function ChampionPointGainedHook(pointDelta)
        -- Print throttled XP value
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        savedEndingPoints = GetPlayerChampionPointsEarned()
        savedPointDelta = savedPointDelta + pointDelta

        eventManager:UnregisterForUpdate(moduleName .. "ChampionPointThrottle")
        eventManager:RegisterForUpdate(moduleName .. "ChampionPointThrottle", 25, ChampionPointGainedPrinter)

        return true
    end

    -- Local variables and functions for DuelNearBoundaryHook()
    local DUEL_BOUNDARY_WARNING_LIFESPAN_MS = 2000
    local DUEL_BOUNDARY_WARNING_UPDATE_TIME_MS = 2100
    local lastEventTime = 0
    local function CheckBoundary()
        if IsNearDuelBoundary() then
            -- Display CA
            if ChatAnnouncements.SV.Social.DuelBoundaryCA then
                printToChat(GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA), true)
            end

            -- Display CSA
            if ChatAnnouncements.SV.Social.DuelBoundaryCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.DUEL_BOUNDARY_WARNING)
                messageParams:SetText(GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA))
                messageParams:SetLifespanMS(DUEL_BOUNDARY_WARNING_LIFESPAN_MS)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DUEL_NEAR_BOUNDARY)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            -- Display Alert
            if ChatAnnouncements.SV.Social.DuelBoundaryAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, (GetString(LUIE_STRING_CA_DUEL_NEAR_BOUNDARY_CSA)))
            end

            -- Play Sound if CSA if off
            if not ChatAnnouncements.SV.Social.DuelBoundaryCSA then
                PlaySound(SOUNDS.DUEL_BOUNDARY_WARNING)
            end
        end
    end

    -- EVENT_DUEL_NEAR_BOUNDARY (CSA Handler)
    local function DuelNearBoundaryHook(isInWarningArea)
        if isInWarningArea then
            local nowEventTime = GetFrameTimeMilliseconds()
            eventManager:RegisterForUpdate("EVENT_DUEL_NEAR_BOUNDARY_LUIE", DUEL_BOUNDARY_WARNING_UPDATE_TIME_MS, CheckBoundary)
            if nowEventTime > lastEventTime + DUEL_BOUNDARY_WARNING_UPDATE_TIME_MS then
                lastEventTime = nowEventTime
                CheckBoundary()
            end
        else
            eventManager:UnregisterForUpdate("EVENT_DUEL_NEAR_BOUNDARY_LUIE")
        end
        return true
    end

    -- EVENT_DUEL_FINISHED (CSA HANDLER)
    local function DuelFinishedHook(result, wasLocalPlayersResult, opponentCharacterName, opponentDisplayName)
        -- Setup result format, name, and result sound
        local resultString = wasLocalPlayersResult and GetString("LUIE_STRING_CA_DUEL_SELF_RESULT", result) or GetString("LUIE_STRING_CA_DUEL_RESULT", result)

        local localPlayerWonDuel = (result == DUEL_RESULT_WON and wasLocalPlayersResult) or (result == DUEL_RESULT_FORFEIT and not wasLocalPlayersResult)
        local localPlayerForfeitDuel = (result == DUEL_RESULT_FORFEIT and wasLocalPlayersResult)
        local resultSound
        if localPlayerWonDuel then
            resultSound = SOUNDS.DUEL_WON
        elseif localPlayerForfeitDuel then
            resultSound = SOUNDS.DUEL_FORFEIT
        end

        -- Display CA
        if ChatAnnouncements.SV.Social.DuelWonCA then
            local finalName = ChatAnnouncements.ResolveNameLink(opponentCharacterName, opponentDisplayName)
            local resultChatString
            if wasLocalPlayersResult then
                resultChatString = resultString
            else
                resultChatString = zo_strformat(resultString, finalName)
            end
            printToChat(resultChatString, true)
        end

        if ChatAnnouncements.SV.Social.DuelWonCSA or ChatAnnouncements.SV.Social.DuelWonAlert then
            -- Setup String for CSA/Alert
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(opponentCharacterName, opponentDisplayName)
            local resultCSAString
            if wasLocalPlayersResult then
                resultCSAString = resultString
            else
                resultCSAString = zo_strformat(resultString, finalAlertName)
            end

            -- Display CSA
            if ChatAnnouncements.SV.Social.DuelWonCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, resultSound)
                messageParams:SetText(resultCSAString)
                messageParams:MarkShowImmediately()
                messageParams:MarkQueueImmediately()
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DUEL_FINISHED)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            -- Display Alert
            if ChatAnnouncements.SV.Social.DuelWonAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, resultCSAString)
            end
        end

        -- Play sound if CSA is not enabled
        if not ChatAnnouncements.SV.Social.DuelWonCSA then
            PlaySound(resultSound)
        end
        return true
    end

    -- EVENT_DUEL_COUNTDOWN (CSA Handler)
    local function DuelCountdownHook(startTimeMS)
        -- Display CSA
        if ChatAnnouncements.SV.Social.DuelStartCSA then
            local displayTime = startTimeMS - GetFrameTimeMilliseconds()
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_COUNTDOWN_TEXT, SOUNDS.DUEL_START)
            messageParams:SetLifespanMS(displayTime)
            messageParams:SetIconData("EsoUI/Art/HUD/HUD_Countdown_Badge_Dueling.dds")
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COUNTDOWN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        return true
    end

    -- EVENT_RAID_TRIAL_STARTED (CSA Handler)
    local function RaidStartedHook(raidName, isWeekly)
        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidCA then
            local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
            printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, formattedName), true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_STARTED)
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, raidName))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, raidName))
        end

        -- Play sound if CSA is not enabled
        if not ChatAnnouncements.SV.Group.GroupRaidCSA then
            PlaySound(SOUNDS.RAID_TRIAL_STARTED)
        end
        return true
    end

    local TRIAL_COMPLETE_LIFESPAN_MS = 10000
    -- EVENT_RAID_TRIAL_COMPLETE (CSA Handler)
    local function RaidCompleteHook(raidName, score, totalTime)
        local wasUnderTargetTime = GetRaidDuration() <= GetRaidTargetTime()
        local formattedTime = ZO_FormatTimeMilliseconds(totalTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
        local vitalityBonus = GetCurrentRaidLifeScoreBonus()
        local vitalityBonusString = tostring(vitalityBonus)
        local currentCount = GetRaidReviveCountersRemaining()
        local maxCount = GetCurrentRaidStartingReviveCounters()

        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidCA then
            local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
            local vitalityCounterString = zo_strformat("<<1>> <<2>>/<<3>>", zo_iconFormatInheritColor("esoui/art/trials/vitalitydepletion.dds", 16, 16), currentCount, maxCount)
            local finalScore = ZO_DEFAULT_ENABLED_COLOR:Colorize(score)
            vitalityBonusString = ZO_DEFAULT_ENABLED_COLOR:Colorize(vitalityBonusString)
            if currentCount == 0 then
                vitalityCounterString = ZO_DISABLED_TEXT:Colorize(vitalityCounterString)
            else
                vitalityCounterString = ZO_DEFAULT_ENABLED_COLOR:Colorize(vitalityCounterString)
            end
            if wasUnderTargetTime then
                formattedTime = ZO_DEFAULT_ENABLED_COLOR:Colorize(formattedTime)
            else
                formattedTime = ZO_ERROR_COLOR:Colorize(formattedTime)
            end

            printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_COMPLETED_LARGE, formattedName), true)
            printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORETALLY, finalScore, formattedTime, vitalityBonusString, vitalityCounterString), true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_RAID_COMPLETE_TEXT, SOUNDS.RAID_TRIAL_COMPLETED)
            messageParams:SetEndOfRaidData(
                {
                    score,
                    formattedTime,
                    wasUnderTargetTime,
                    vitalityBonus,
                    zo_strformat(SI_REVIVE_COUNTER_REVIVES_USED, currentCount, maxCount),
                })
            messageParams:SetText(zo_strformat(SI_TRIAL_COMPLETED_LARGE, raidName))
            messageParams:SetLifespanMS(TRIAL_COMPLETE_LIFESPAN_MS)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(SI_TRIAL_COMPLETED_LARGE, raidName))
        end

        -- Play sound if CSA is not enabled
        if not ChatAnnouncements.SV.Group.GroupRaidCSA then
            PlaySound(SOUNDS.RAID_TRIAL_COMPLETED)
        end
        return true
    end

    -- EVENT_RAID_TRIAL_FAILED (CSA Handler)
    local function RaidFailedHook(raidName, score)
        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidCA then
            local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
            printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, formattedName), true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_FAILED)
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, raidName))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, raidName))
        end

        -- Play sound if CSA is not enabled
        if not ChatAnnouncements.SV.Group.GroupRaidCSA then
            PlaySound(SOUNDS.RAID_TRIAL_FAILED)
        end
        return true
    end

    -- EVENT_RAID_TRIAL_NEW_BEST_SCORE (CSA Handler)
    local function RaidBestScoreHook(raidName, score, isWeekly)
        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidBestScoreCA then
            local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
            local formattedString = isWeekly and zo_strformat(SI_TRIAL_NEW_BEST_SCORE_WEEKLY, formattedName) or zo_strformat(SI_TRIAL_NEW_BEST_SCORE_LIFETIME, formattedName)
            printToChat(formattedString, true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidBestScoreCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.RAID_TRIAL_NEW_BEST)
            messageParams:SetText(zo_strformat(isWeekly and SI_TRIAL_NEW_BEST_SCORE_WEEKLY or SI_TRIAL_NEW_BEST_SCORE_LIFETIME, raidName))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidBestScoreAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(isWeekly and SI_TRIAL_NEW_BEST_SCORE_WEEKLY or SI_TRIAL_NEW_BEST_SCORE_LIFETIME, raidName))
        end

        -- Play sound ONLY if normal score is not set to display, otherwise the audio will overlap
        if not ChatAnnouncements.SV.Group.GroupRaidBestScoreCSA and not (ChatAnnouncements.SV.Group.GroupRaidScoreCA and ChatAnnouncements.SV.Group.GroupRaidScoreCSA and ChatAnnouncements.SV.Group.GroupRaidScoreAlert) then
            PlaySound(SOUNDS.RAID_TRIAL_NEW_BEST)
        end
        return true
    end

    -- EVENT_RAID_REVIVE_COUNTER_UPDATE (CSA Handler)
    local function RaidReviveCounterHook(currentCount, countDelta)
        if not IsRaidInProgress() then
            return
        end
        if countDelta < 0 then
            if ChatAnnouncements.SV.Group.GroupRaidReviveCA then
                local iconCA = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", 16, 16)
                printToChat(zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconCA))
            end

            if ChatAnnouncements.SV.Group.GroupRaidReviveCSA then
                local iconCSA = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", "100%", "100%")
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_COUNTER_UPDATE)
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconCSA))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Group.GroupRaidReviveAlert then
                local iconAlert = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", "75%", "75%")
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconAlert))
            end

            -- Play Sound if CSA is not enabled
            if not ChatAnnouncements.SV.Group.GroupRaidReviveCSA then
                PlaySound(SOUNDS.RAID_TRIAL_COUNTER_UPDATE)
            end
        end
        return true
    end

    local TRIAL_SCORE_REASON_TO_ASSETS =
    {
        [RAID_POINT_REASON_KILL_MINIBOSS] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_normal.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_NORMAL,
        },
        [RAID_POINT_REASON_KILL_BOSS] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_veryHigh.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH,
        },

        [RAID_POINT_REASON_BONUS_ACTIVITY_LOW] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_veryLow.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_LOW,
        },
        [RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_low.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_LOW,
        },
        [RAID_POINT_REASON_BONUS_ACTIVITY_HIGH] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_high.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH,
        },

        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_ONE] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_veryLow.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_LOW,
        },
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_TWO] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_low.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_LOW,
        },
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_THREE] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_normal.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_NORMAL,
        },
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_FOUR] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_high.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH,
        },
        [RAID_POINT_REASON_SOLO_ARENA_COMPLETE] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_veryHigh.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH,
        },
    }

    -- EVENT_RAID_TRIAL_SCORE_UPDATE (CSA Handler)
    local function RaidScoreUpdateHook(scoreUpdateReason, scoreAmount, totalScore)
        local reasonAssets = TRIAL_SCORE_REASON_TO_ASSETS[scoreUpdateReason]
        if reasonAssets then
            -- Display CA
            if ChatAnnouncements.SV.Group.GroupRaidScoreCA then
                local iconCA = zo_iconFormat(reasonAssets.icon, 16, 16)
                printToChat(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconCA, scoreAmount))
            end

            -- Display CSA
            if ChatAnnouncements.SV.Group.GroupRaidScoreCSA then
                local iconCSA = zo_iconFormat(reasonAssets.icon, "100%", "100%")
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, reasonAssets.soundId)
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconCSA, scoreAmount))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            -- Display Alert
            if ChatAnnouncements.SV.Group.GroupRaidScoreAlert then
                local iconAlert = zo_iconFormat(reasonAssets.icon, "75%", "75%")
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconAlert, scoreAmount))
            end

            -- Play Sound if CSA is not enabled
            if not ChatAnnouncements.SV.Group.GroupRaidScoreCSA then
                PlaySound(reasonAssets.soundId)
            end
        end
        return true
    end

    -- EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE (CSA Handler)
    local function ActivityFinderCompleteHook()
        local message = GetString(SI_ACTIVITY_FINDER_ACTIVITY_COMPLETE_ANNOUNCEMENT_TEXT)
        if ChatAnnouncements.SV.Group.GroupLFGCompleteCA then
            printToChat(message, true)
        end

        if ChatAnnouncements.SV.Group.GroupLFGCompleteCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LFG_COMPLETE_ANNOUNCEMENT)
            messageParams:SetText(message)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACTIVITY_COMPLETE)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Group.GroupLFGCompleteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end

        if not ChatAnnouncements.SV.Group.GroupLFGCompleteCSA then
            PlaySound(SOUNDS.LFG_COMPLETE_ANNOUNCEMENT)
        end

        return true
    end

    local g_previousEndlessDungeonProgression = { 0, 0, 0 } -- Stage, Cycle, Arc

    local function GetEndlessDungeonProgressMessageParams()
        local stage, cycle, arc = ENDLESS_DUNGEON_MANAGER:GetProgression()
        local previousStage, previousCycle, previousArc = unpack(g_previousEndlessDungeonProgression)
        if stage == 1 and cycle == 1 and arc == 1 then
            -- Force the initial CSA to roll over from all 0s to all 1s.
            previousStage, previousCycle, previousArc = 0, 0, 0
        end

        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_ROLLING_METER_PROGRESS_TEXT, SOUNDS.NONE)
        local stageIcon, cycleIcon, arcIcon = ZO_EndlessDungeonManager.GetProgressionIcons()
        local stageNarration, cycleNarration, arcNarration = ZO_EndlessDungeonManager.GetProgressionNarrationDescriptions(stage, cycle, arc)
        local progressData =
        {
            {
                iconTexture = arcIcon,
                narrationDescription = arcNarration,
                initialValue = previousArc,
                finalValue = arc,
            },
            {
                iconTexture = cycleIcon,
                narrationDescription = cycleNarration,
                initialValue = previousCycle,
                finalValue = cycle,
            },
            {
                iconTexture = stageIcon,
                narrationDescription = stageNarration,
                initialValue = previousStage,
                finalValue = stage,
            },
        }
        messageParams:SetRollingMeterProgressData(progressData)

        -- Update the previous progression values.
        g_previousEndlessDungeonProgression[1] = stage
        g_previousEndlessDungeonProgression[2] = cycle
        g_previousEndlessDungeonProgression[3] = arc

        return messageParams
    end

    local function RefreshEndlessDungeonProgressionState()
        local stage, cycle, arc = ENDLESS_DUNGEON_MANAGER:GetProgression()
        g_previousEndlessDungeonProgression[1] = stage
        g_previousEndlessDungeonProgression[2] = cycle
        g_previousEndlessDungeonProgression[3] = arc
    end

    ENDLESS_DUNGEON_MANAGER:RegisterCallback("StateChanged", RefreshEndlessDungeonProgressionState)

    local function UpdateEndlessDungeonTrackers()
        ENDLESS_DUNGEON_HUD_TRACKER:UpdateProgress()
        ENDLESS_DUNGEON_BUFF_TRACKER_GAMEPAD:UpdateProgress()
        if ENDLESS_DUNGEON_BUFF_TRACKER_KEYBOARD then
            ENDLESS_DUNGEON_BUFF_TRACKER_KEYBOARD:UpdateProgress()
        end
    end

    local ZoneIds =
    {
        [1413] = "Endless Archive", -- Dungeon - Endless Archive
        [1436] = "Endless Archive", -- Dungeon - Endless Archive
        [888] = "Craglorn",         -- Zone - Craglorn
        [584] = "Imperial City",    -- Imperial City (Overland)
        [643] = "Imperial City",    -- Imperial City (Sewers)
        [635] = "Dragonstar Arena", -- Dragonstar Arena
    }

    local MapIds =
    {
        [988] = "Maelstrom Arena", -- Vale of the Surreal (Maelstrom Arena - Stage 1)
        [963] = "Maelstrom Arena", -- Seht's Balcony (Maelstrom Arena - Stage 2)
        [2567] = "Endless Archive",
        -- TODO - Need MapIds for Stage 3-9
    }

    local function ResolveDisplayAnnouncementMessages(messageType)
        local settings
        if messageType == "Imperial City" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneIC
        elseif messageType == "Craglorn" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneCraglorn
        elseif messageType == "Maelstrom Arena" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaMaelstrom
        elseif messageType == "Dragonstar Arena" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaDragonstar
        elseif messageType == "Endless Archive" then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.DungeonEndlessArchive
        end
        return settings
    end

    -- EVENT_DISPLAY_ANNOUNCEMENT (CSA Handler)
    local function DisplayAnnouncementHook(primaryText, secondaryText, icon, soundId, lifespanMS, category)
        -- Disable Respec Display Announcement since we handle this from loot announcements (using Respec scroll)
        if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) then
            return true
        end

        -- Setup CSA with default function (don't display CSA here yet, we filter to check)
        soundId = soundId == "" and SOUNDS.DISPLAY_ANNOUNCEMENT or soundId

        local messageParams
        if category == CSA_CATEGORY_ENDLESS_DUNGEON_STAGE_STARTED_TEXT then
            -- Endless Dungeon Progression CSA special case
            messageParams = GetEndlessDungeonProgressMessageParams()
            if not messageParams then
                -- The progression did not change; this should never happen.
                return
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENDLESS_DUNGEON_PROGRESS)
            messageParams:SetOnDisplayCallback(UpdateEndlessDungeonTrackers)
        else
            -- Standard Display Announcement
            messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, soundId)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
        end

        if soundId then
            messageParams:SetSound(soundId)
        end

        if icon ~= ZO_NO_TEXTURE_FILE then
            messageParams:SetIconData(icon)
        end

        if lifespanMS > 0 then
            messageParams:SetLifespanMS(lifespanMS)
        end

        -- Sanitize text.
        if primaryText == "" then
            primaryText = nil
        end
        if secondaryText == "" then
            secondaryText = nil
        end

        -- No message so return
        if primaryText == nil and secondaryText == nil then
            return
        end

        -- Check zoneId or mapId if needed
        local zoneId = GetZoneId(GetCurrentMapZoneIndex())
        local mapId = GetCurrentMapId() -- Some areas don't have proper zoneIds (Maelstrom Arena)
        local messageType
        if ZoneIds[zoneId] then
            messageType = ZoneIds[zoneId]
        elseif MapIds[mapId] then
            messageType = MapIds[mapId]
        end

        local settings     -- local variable for pulling SV
        local debugDisable -- flag to disable debug when its enabled

        -- Settings either use the subcategory settings or the generic settings if no subcategory
        if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE0) or primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.Respec
            debugDisable = true
            -- Update message syntax here
            if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE0) then
                primaryText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_SKILLS)
            end
            if primaryText == GetString(SI_RESPECTYPE_POINTSRESETTITLE1) then
                primaryText = GetString(LUIE_STRING_CA_CURRENCY_NOTIFY_ATTRIBUTES)
            end
        elseif primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_D) or primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_D) then
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.GroupArea
            debugDisable = true
            -- Update message syntax here
            if primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_D) then
                primaryText = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPENTER_C)
            end
            if primaryText == GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_D) then
                primaryText = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_GROUPLEAVE_C)
            end
        elseif messageType then
            settings = ResolveDisplayAnnouncementMessages(messageType)
            debugDisable = true
        else
            settings = LUIE.ChatAnnouncements.SV.DisplayAnnouncements.General
        end

        -- Debug function
        if ChatAnnouncements.SV.DisplayAnnouncements.Debug and not debugDisable then
            CHAT_ROUTER:AddSystemMessage("EVENT_DISPLAY_ANNOUNCEMENT: If you see this message please post a screenshot and context for the event on the LUI Extended ESOUI page.")
            if primaryText then
                CHAT_ROUTER:AddSystemMessage("Primary Text: " .. primaryText)
            end
            if secondaryText then
                CHAT_ROUTER:AddSystemMessage("Secondary Text: " .. secondaryText)
            end
            local zoneid = GetZoneId(GetCurrentMapZoneIndex())
            CHAT_ROUTER:AddSystemMessage("Zone Id: " .. zoneid)
            local mapid = GetCurrentMapId()
            CHAT_ROUTER:AddSystemMessage("Map Id: " .. mapid)
        end

        -- Display CA if enabled
        if settings.CA then
            -- Some formatting may be needed for CA:
            local caPrimary = primaryText
            local caSecondary = secondaryText
            local language = GetCVar("language.2")
            -- Extra formatting in Imperial City: Remove "Entered: " and format it and add it back on and color the message.
            -- Note we don't want to mess with strings outside of EN localization for now (TODO)
            -- Custom formatting for IC messages
            if settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneIC and language == "en" then
                local prefix = GetString(LUIE_STRING_CA_DISPLAY_ANNOUNCEMENT_IC_TITLE_PREFIX)
                caPrimary = zo_strgsub(primaryText, prefix, "")
                caPrimary = settings.Description and string_format("%s|c%s%s: |r", prefix, ColorizeColors.QuestColorLocNameColorize, caPrimary) or string_format("%s|c%s%s|r", prefix, ColorizeColors.QuestColorLocNameColorize, caPrimary)
                caSecondary = settings.Description and string_format("|c%s%s|r", ColorizeColors.QuestColorLocDescriptionColorize, caSecondary) or ""
                printToChat(caPrimary .. caSecondary)
                -- Add an "!" to the CA for Craglorn buffs
            elseif settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ZoneCraglorn and language == "en" then
                caPrimary = primaryText .. "!"
                printToChat(caPrimary)
                -- Add an "!" to the Maelstrom Arena Round CA messages (VMA messages have two lines other then the rounds)
            elseif settings == LUIE.ChatAnnouncements.SV.DisplayAnnouncements.ArenaMaelstrom and secondaryText == nil then
                caPrimary = primaryText .. "!"
                printToChat(caPrimary)
            else
                if primaryText and secondaryText then
                    printToChat(caPrimary .. ": " .. caSecondary)
                elseif primaryText then
                    printToChat(caPrimary)
                elseif secondaryText then
                    printToChat(caSecondary)
                end
            end
        end

        -- Display CSA if enabled
        if settings.CSA then
            messageParams:SetText(primaryText, secondaryText)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert if enabled
        if settings.Alert then
            if primaryText and secondaryText then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, (primaryText .. ": " .. secondaryText))
            elseif primaryText then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, primaryText)
            elseif secondaryText then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, secondaryText)
            end
        end

        -- If the CSA is disabled, play a sound if Chat Announcement or Alert are enabled
        if (settings.CA or settings.Alert) and not settings.CSA then
            if soundId then
                PlaySound(soundId)
                -- Fallback sound if no soundId
            else
                PlaySound(SOUNDS.DISPLAY_ANNOUNCEMENT)
            end
        end

        return true
    end

    -- EVENT_ACHIEVEMENT_AWARDED (CSA Handler)
    local function AchievementAwardedHook(name, points, id)
        local topLevelIndex, categoryIndex, achievementIndex = GetCategoryInfoFromAchievementId(id)

        -- Bail out if this achievement comes from unwanted category & we don't always show CSA
        if ChatAnnouncements.SV.Achievement.AchievementCategoryIgnore[topLevelIndex] and not ChatAnnouncements.SV.Achievement.AchievementCompleteAlwaysCSA then
            return true
        end

        -- Display CSA
        if ChatAnnouncements.SV.Achievement.AchievementCompleteCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ACHIEVEMENT_AWARDED)
            local icon = select(4, GetAchievementInfo(id))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
            messageParams:SetText(ChatAnnouncements.SV.Achievement.AchievementCompleteMsg, zo_strformat(name))
            messageParams:SetIconData(icon, "EsoUI/Art/Achievements/achievements_iconBG.dds")
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Bail out if this achievement comes from unwanted category
        if ChatAnnouncements.SV.Achievement.AchievementCategoryIgnore[topLevelIndex] then
            return true
        end

        if ChatAnnouncements.SV.Achievement.AchievementCompleteCA then
            local link = zo_strformat(GetAchievementLink(id, linkBrackets[ChatAnnouncements.SV.BracketOptionAchievement]))
            local catName = GetAchievementCategoryInfo(topLevelIndex)
            local subcatName = categoryIndex ~= nil and GetAchievementSubCategoryInfo(topLevelIndex, categoryIndex) or "General"
            local _, _, _, icon = GetAchievementInfo(id)
            icon = ChatAnnouncements.SV.Achievement.AchievementIcon and ("|t16:16:" .. icon .. "|t ") or ""

            -- Build string parts without using string_format on pre-formatted strings
            local stringpart1 = ColorizeColors.AchievementColorize1:Colorize(
                bracket1[ChatAnnouncements.SV.Achievement.AchievementBracketOptions] ..
                ChatAnnouncements.SV.Achievement.AchievementCompleteMsg ..
                bracket2[ChatAnnouncements.SV.Achievement.AchievementBracketOptions] .. " " ..
                icon .. link
            )

            local stringpart2 = ""
            if ChatAnnouncements.SV.Achievement.AchievementCompPercentage then
                stringpart2 = ChatAnnouncements.SV.Achievement.AchievementColorProgress and
                    ColorizeColors.AchievementColorize2:Colorize(" (") ..
                    "|c71DE73100%|r" ..
                    ColorizeColors.AchievementColorize2:Colorize(")") or
                    ColorizeColors.AchievementColorize2:Colorize(" (100%)")
            end

            local stringpart3 = ""
            if ChatAnnouncements.SV.Achievement.AchievementCategory then
                stringpart3 = ColorizeColors.AchievementColorize2:Colorize(
                    " " .. bracket1[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions] ..
                    catName ..
                    (ChatAnnouncements.SV.Achievement.AchievementSubcategory and (" - " .. subcatName) or "") ..
                    bracket2[ChatAnnouncements.SV.Achievement.AchievementCatBracketOptions]
                )
            end

            -- Concatenate final string without using string_format
            local finalString = stringpart1 .. stringpart2 .. stringpart3
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalString, messageType = "ACHIEVEMENT" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Achievement.AchievementCompleteAlert then
            local alertMessage = zo_strformat("<<1>>: <<2>>", ChatAnnouncements.SV.Achievement.AchievementCompleteMsg, name)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end

        -- Play sound if CSA is disabled
        if not ChatAnnouncements.SV.Achievement.AchievementCompleteCSA then
            PlaySound(SOUNDS.ACHIEVEMENT_AWARDED)
        end

        return true
    end

    -- EVENT_PLEDGE_OF_MARA_RESULT (CSA Handler)
    local function PledgeOfMaraHook(result, characterName, displayName)
        -- Display CA (Success or Failure)
        if ChatAnnouncements.SV.Social.PledgeOfMaraCA then
            local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
            printToChat(zo_strformat(GetString("LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT", result), finalName), true)
        end

        if ChatAnnouncements.SV.Social.PledgeOfMaraAlert or ChatAnnouncements.SV.Social.PledgeOfMaraCSA then
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)

            -- Display CSA (Success Only)
            if ChatAnnouncements.SV.Social.PledgeOfMaraCSA then
                if result == PLEDGE_OF_MARA_RESULT_PLEDGED then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_PLEDGE_OF_MARA_RESULT)
                    messageParams:SetText(GetString(SI_RITUAL_OF_MARA_COMPLETION_ANNOUNCE_LARGE), zo_strformat(LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT3, finalAlertName))
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
            end

            -- Alert (Success or Failure)
            if ChatAnnouncements.SV.Social.PledgeOfMaraAlert then
                -- If the menu setting to only display Alert on Failure state is toggled, then do not display an Alert on successful Mara Event
                if result == PLEDGE_OF_MARA_RESULT_PLEDGED and not ChatAnnouncements.SV.Social.PledgeOfMaraAlertOnlyFail then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT3, finalAlertName))
                elseif result ~= PLEDGE_OF_MARA_RESULT_PLEDGED and result ~= PLEDGE_OF_MARA_RESULT_BEGIN_PLEDGE then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_MARA_PLEDGEOFMARARESULT", result), finalAlertName))
                end
            end
        end

        -- Play alert sound if error result
        if result ~= PLEDGE_OF_MARA_RESULT_PLEDGED and result ~= PLEDGE_OF_MARA_RESULT_BEGIN_PLEDGE then
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end

        return true
    end

    -- EVENT_ANTIQUITY_LEAD_ACQUIRED (CSA Handler)
    local function AntiquityLeadAcquired(antiquityId)
        -- Get antiquity data
        local antiquityData = ANTIQUITY_DATA_MANAGER:GetAntiquityData(antiquityId)
        -- Get name
        local antiquityName = antiquityData:GetName()

        if ChatAnnouncements.SV.Antiquities.AntiquityCA then
            local antiquityColor = GetAntiquityQualityColor(antiquityData:GetQuality())
            local antiquityIcon = antiquityData:GetIcon()

            local formattedName
            local antiquityLink
            local linkColor = antiquityColor:ToHex()
            if ChatAnnouncements.SV.Antiquities.AntiquityBracket == 1 then
                formattedName = antiquityName
                antiquityLink = string_format("|c%s|H0:LINK_TYPE_LUIE_ANTIQUITY:%s|h%s|h|r", linkColor, antiquityId, formattedName)
            else
                formattedName = ("[" .. antiquityName .. "]")
                antiquityLink = string_format("|c%s|H1:LINK_TYPE_LUIE_ANTIQUITY:%s|h%s|h|r", linkColor, antiquityId, formattedName)
            end

            local formattedIcon = ChatAnnouncements.SV.Antiquities.AntiquityIcon and ("|t16:16:" .. antiquityIcon .. "|t ") or ""

            local messageP1 = ColorizeColors.AntiquityColorize:Colorize(string_format("%s%s%s %s", bracket1[ChatAnnouncements.SV.Antiquities.AntiquityPrefixBracket], ChatAnnouncements.SV.Antiquities.AntiquityPrefix, bracket2[ChatAnnouncements.SV.Antiquities.AntiquityPrefixBracket], formattedIcon))
            local messageP2 = antiquityLink
            local messageP3 = ColorizeColors.AntiquityColorize:Colorize(" " .. ChatAnnouncements.SV.Antiquities.AntiquitySuffix)
            local finalMessage = zo_strformat("<<1>><<2>><<3>>", messageP1, messageP2, messageP3)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "ANTIQUITY" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
        end

        if ChatAnnouncements.SV.Antiquities.AntiquityAlert then
            local alertMessage = zo_strformat("<<1>>: <<2>> <<3>>", ChatAnnouncements.SV.Antiquities.AntiquityPrefix, antiquityName, ChatAnnouncements.SV.Antiquities.AntiquitySuffix)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end

        if ChatAnnouncements.SV.Antiquities.AntiquityCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
            local secondaryText = zo_strformat(SI_ANTIQUITY_LEAD_ACQUIRED_TEXT, antiquityData:GetColorizedName())
            messageParams:SetText(GetString(SI_ANTIQUITY_LEAD_ACQUIRED_TITLE), secondaryText)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ANTIQUITY_LEAD_ACQUIRED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        return true
    end

    -- Unregister the ZOS events for handling Quest Removal/Advanced/Added to replace with our own functions
    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_REMOVED)
    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADVANCED)
    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADDED)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_REMOVED, OnQuestRemoved)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADVANCED, OnQuestAdvanced)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADDED, OnQuestAdded)

    ZO_PreHook(csaHandlers, EVENT_LORE_BOOK_LEARNED_SKILL_EXPERIENCE, LoreBookXPHook)
    ZO_PreHook(csaHandlers, EVENT_LORE_COLLECTION_COMPLETED, LoreCollectionHook)
    ZO_PreHook(csaHandlers, EVENT_LORE_COLLECTION_COMPLETED_SKILL_EXPERIENCE, LoreCollectionXPHook)
    ZO_PreHook(csaHandlers, EVENT_SKILL_POINTS_CHANGED, SkillPointsChangedHook)
    ZO_PreHook(csaCallbackHandlers[2], "callbackFunction", SkillLineAddedHook)
    ZO_PreHook(csaHandlers, EVENT_ABILITY_PROGRESSION_RANK_UPDATE, AbilityProgressionRankHook)
    ZO_PreHook(csaHandlers, EVENT_SKILL_RANK_UPDATE, SkillRankUpdateHook)
    ZO_PreHook(csaHandlers, EVENT_SKILL_XP_UPDATE, SkillXPUpdateHook)
    ZO_PreHook(csaCallbackHandlers[1], "callbackFunction", CollectibleUnlockedHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_ADDED, QuestAddedHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_COMPLETE, QuestCompleteHook)
    ZO_PreHook(csaHandlers, EVENT_OBJECTIVE_COMPLETED, ObjectiveCompletedHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_CONDITION_COUNTER_CHANGED, ConditionCounterHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_OPTIONAL_STEP_ADVANCED, OptionalStepHook)
    ZO_PreHook(csaHandlers, EVENT_DISCOVERY_EXPERIENCE, DiscoveryExperienceHook)
    ZO_PreHook(csaHandlers, EVENT_POI_DISCOVERED, PoiDiscoveredHook)
    ZO_PreHook(csaHandlers, EVENT_EXPERIENCE_GAIN, ExperienceGainHook)
    ZO_PreHook(csaHandlers, EVENT_ENLIGHTENED_STATE_GAINED, EnlightenGainHook)
    ZO_PreHook(csaHandlers, EVENT_ENLIGHTENED_STATE_LOST, EnlightenLostHook)
    ZO_PreHook(csaHandlers, EVENT_PLAYER_ACTIVATED, PlayerActivatedHook)
    ZO_PreHook(csaHandlers, EVENT_RIDING_SKILL_IMPROVEMENT, RidingSkillImprovementHook)
    ZO_PreHook(csaHandlers, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, InventoryBagCapacityHook)
    ZO_PreHook(csaHandlers, EVENT_INVENTORY_BANK_CAPACITY_CHANGED, InventoryBankCapacityHook)
    ZO_PreHook(csaHandlers, EVENT_CHAMPION_LEVEL_ACHIEVED, ChampionLevelAchievedHook)
    ZO_PreHook(csaHandlers, EVENT_CHAMPION_POINT_GAINED, ChampionPointGainedHook)
    ZO_PreHook(csaHandlers, EVENT_DUEL_NEAR_BOUNDARY, DuelNearBoundaryHook)
    ZO_PreHook(csaHandlers, EVENT_DUEL_FINISHED, DuelFinishedHook)
    ZO_PreHook(csaHandlers, EVENT_DUEL_COUNTDOWN, DuelCountdownHook)

    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_STARTED, ChatAnnouncements.DuelStarted)

    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_STARTED, RaidStartedHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_COMPLETE, RaidCompleteHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_FAILED, RaidFailedHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_NEW_BEST_SCORE, RaidBestScoreHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_REVIVE_COUNTER_UPDATE, RaidReviveCounterHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_SCORE_UPDATE, RaidScoreUpdateHook)
    ZO_PreHook(csaHandlers, EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, ActivityFinderCompleteHook)
    ZO_PreHook(csaHandlers, EVENT_DISPLAY_ANNOUNCEMENT, DisplayAnnouncementHook)
    ZO_PreHook(csaHandlers, EVENT_ACHIEVEMENT_AWARDED, AchievementAwardedHook)
    ZO_PreHook(csaHandlers, EVENT_PLEDGE_OF_MARA_RESULT, PledgeOfMaraHook)

    eventManager:RegisterForEvent(moduleName, EVENT_PLEDGE_OF_MARA_OFFER, ChatAnnouncements.MaraOffer)

    ZO_PreHook(csaHandlers, EVENT_ANTIQUITY_LEAD_ACQUIRED, AntiquityLeadAcquired)

    -- HOOK PLAYER_TO_PLAYER Group Notifications to edit Ignore alert
    do
        local KEYBOARD_INTERACT_ICONS =
        {
            [SI_PLAYER_TO_PLAYER_WHISPER] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_whisper_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_whisper_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_whisper_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_whisper_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_ADD_GROUP] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_inviteGroup_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_inviteGroup_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_inviteGroup_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_inviteGroup_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_REMOVE_GROUP] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_removeFromGroup_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_removeFromGroup_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_removeFromGroup_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_removeFromGroup_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_ADD_FRIEND] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_addFriend_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_addFriend_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_addFriend_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_addFriend_disabled.dds",
            },
            [SI_CHAT_PLAYER_CONTEXT_REPORT] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_reportPlayer_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_reportPlayer_over.dds",
            },
            [SI_PLAYER_TO_PLAYER_INVITE_DUEL] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_duel_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_duel_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_duel_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_duel_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_tribute_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_tribute_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_tribute_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_tribute_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_INVITE_TRADE] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_trade_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_trade_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_trade_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_trade_disabled.dds",
            },
            [SI_RADIAL_MENU_CANCEL_BUTTON] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_cancel_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_cancel_over.dds",
            },
            [SI_PLAYER_TO_PLAYER_RIDE_MOUNT] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_joinMount_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_joinMount_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_joinMount_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_joinMount_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_DISMOUNT] =
            {
                enabledNormal = "EsoUI/Art/HUD/radialIcon_dismount_up.dds",
                enabledSelected = "EsoUI/Art/HUD/radialIcon_dismount_over.dds",
                disabledNormal = "EsoUI/Art/HUD/radialIcon_dismount_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/radialIcon_dismount_disabled.dds",
            },
        }

        local GAMEPAD_INTERACT_ICONS =
        {
            [SI_PLAYER_TO_PLAYER_WHISPER] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_whisper_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_whisper_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_whisper_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_whisper_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_ADD_GROUP] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_inviteGroup_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_inviteGroup_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_inviteGroup_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_inviteGroup_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_REMOVE_GROUP] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_removeFromGroup_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_removeFromGroup_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_removeFromGroup_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_removeFromGroup_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_ADD_FRIEND] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_addFriend_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_addFriend_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_addFriend_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_addFriend_disabled.dds",
            },
            [SI_CHAT_PLAYER_CONTEXT_REPORT] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_reportPlayer_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_reportPlayer_down.dds",
            },
            [SI_PLAYER_TO_PLAYER_INVITE_DUEL] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_tribute_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_tribute_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_tribute_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_tribute_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_INVITE_TRADE] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_trade_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_trade_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_trade_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_trade_disabled.dds",
            },
            [SI_RADIAL_MENU_CANCEL_BUTTON] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds",
            },
            [SI_PLAYER_TO_PLAYER_RIDE_MOUNT] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_joinMount_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_joinMount_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_joinMount_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_joinMount_disabled.dds",
            },
            [SI_PLAYER_TO_PLAYER_DISMOUNT] =
            {
                enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_dismount_down.dds",
                enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_dismount_down.dds",
                disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_dismount_disabled.dds",
                disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_dismount_disabled.dds",
            },
        }

        local ALERT_IGNORED_STRING = IsConsoleUI() and SI_PLAYER_TO_PLAYER_BLOCKED or SI_PLAYER_TO_PLAYER_IGNORED

        local function AlertIgnored(SendString)
            local alertString = ALERT_IGNORED_STRING or SendString
            printToChat(GetString(alertString), true)
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, alertString)
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end


        local originalShowPlayerInteractMenu = ZO_PlayerToPlayer.ShowPlayerInteractMenu
        --- @param self ZO_PlayerToPlayer
        --- @param isIgnored boolean
        function ZO_PlayerToPlayer:ShowPlayerInteractMenu(isIgnored)
            -- Call the original function to maintain base behavior
            originalShowPlayerInteractMenu(self, isIgnored)
            local currentTargetCharacterName = self.currentTargetCharacterName
            local currentTargetCharacterNameRaw = self.currentTargetCharacterNameRaw
            local currentTargetDisplayName = self.currentTargetDisplayName
            local primaryName = ZO_GetPrimaryPlayerName(currentTargetDisplayName, currentTargetCharacterName, false)
            local primaryNameInternal = ZO_GetPrimaryPlayerName(currentTargetDisplayName, currentTargetCharacterName, false)
            local platformIcons = IsInGamepadPreferredMode() and GAMEPAD_INTERACT_ICONS or KEYBOARD_INTERACT_ICONS
            local ENABLED = true
            local DISABLED = false
            local ENABLED_IF_NOT_IGNORED = not isIgnored

            self:GetRadialMenu():Clear()
            -- Gamecard--
            if IsConsoleUI() then
                self:AddShowGamerCard(currentTargetDisplayName, currentTargetCharacterName)
            end

            -- Whisper--
            if IsChatSystemAvailableForCurrentPlatform() then
                local nameToUse = IsConsoleUI() and currentTargetDisplayName or primaryNameInternal
                local function WhisperOption()
                    StartChatInput(nil, CHAT_CHANNEL_WHISPER, nameToUse)
                end
                local function WhisperIgnore()
                    AlertIgnored(LUIE_STRING_IGNORE_ERROR_WHISPER)
                end
                local whisperFunction = ENABLED_IF_NOT_IGNORED and WhisperOption or WhisperIgnore
                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_WHISPER), platformIcons[SI_PLAYER_TO_PLAYER_WHISPER], ENABLED_IF_NOT_IGNORED, whisperFunction)
            end

            -- Group--
            local isGroupModificationAvailable = IsGroupModificationAvailable()
            local groupModificationRequiresVoting = DoesGroupModificationRequireVote()
            local isSoloOrLeader = IsUnitSoloOrGroupLeader("player")

            local function AlertGroupDisabled()
                printToChat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE), true)
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE))
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            end

            local function AlertGroupKickDisabled()
                printToChat(GetString(LUIE_STRING_CA_GROUP_LEADERKICK_ERROR))
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_GROUP_LEADERKICK_ERROR), true)
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            end

            local isInGroup = IsPlayerInGroup(currentTargetCharacterNameRaw)

            if isInGroup then
                local groupKickEnabled = isGroupModificationAvailable and isSoloOrLeader and not groupModificationRequiresVoting or IsInLFGGroup()
                local lfgKick = IsInLFGGroup()
                local groupKickFunction = nil
                if groupKickEnabled then
                    if lfgKick then
                        groupKickFunction = function ()
                            LUIE.SlashCommands.SlashVoteKick(currentTargetCharacterName)
                        end
                    else
                        groupKickFunction = function ()
                            GroupKickByName(currentTargetCharacterNameRaw)
                        end
                    end
                else
                    groupKickFunction = AlertGroupKickDisabled
                end

                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_REMOVE_GROUP), platformIcons[SI_PLAYER_TO_PLAYER_REMOVE_GROUP], groupKickEnabled, groupKickFunction)
            else
                local groupInviteEnabled = ENABLED_IF_NOT_IGNORED and isGroupModificationAvailable and isSoloOrLeader
                local groupInviteFunction = nil
                if groupInviteEnabled then
                    groupInviteFunction = function ()
                        local NOT_SENT_FROM_CHAT = false
                        local DISPLAY_INVITED_MESSAGE = true
                        TryGroupInviteByName(primaryNameInternal, NOT_SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE)
                    end
                else
                    if ENABLED_IF_NOT_IGNORED then
                        groupInviteFunction = AlertGroupDisabled
                    else
                        local function GroupIgnore()
                            AlertIgnored(LUIE_STRING_IGNORE_ERROR_GROUP)
                        end
                        groupInviteFunction = GroupIgnore
                    end
                end

                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_ADD_GROUP), platformIcons[SI_PLAYER_TO_PLAYER_ADD_GROUP], groupInviteEnabled, groupInviteFunction)
            end

            -- Friend--
            if IsFriend(currentTargetCharacterNameRaw) then
                local function AlreadyFriendsWarning()
                    printToChat(GetString("SI_SOCIALACTIONRESULT", SOCIAL_RESULT_ACCOUNT_ALREADY_FRIENDS), true)
                    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
                        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, GetString("SI_SOCIALACTIONRESULT", SOCIAL_RESULT_ACCOUNT_ALREADY_FRIENDS))
                    end
                    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                end
                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_ADD_FRIEND), platformIcons[SI_PLAYER_TO_PLAYER_ADD_FRIEND], DISABLED, AlreadyFriendsWarning)
            else
                local function RequestFriendOption()
                    local isConsoleUI = IsConsoleUI()
                    if isConsoleUI then
                        ZO_ShowConsoleAddFriendDialog(currentTargetCharacterName)
                    else
                        RequestFriend(currentTargetDisplayName, nil)
                    end

                    local displayNameLink = ZO_LinkHandler_CreateLink(currentTargetDisplayName, nil, DISPLAY_NAME_LINK_TYPE, currentTargetDisplayName)
                    if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                        displayNameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(currentTargetDisplayName, nil, DISPLAY_NAME_LINK_TYPE, currentTargetDisplayName)
                    end

                    local formattedMessage = zo_strformat(LUIE_STRING_SLASHCMDS_FRIEND_INVITE_MSG_LINK, displayNameLink)

                    if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedMessage)
                    end
                end
                local function FriendIgnore()
                    AlertIgnored(LUIE_STRING_IGNORE_ERROR_FRIEND)
                end
                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_ADD_FRIEND), platformIcons[SI_PLAYER_TO_PLAYER_ADD_FRIEND], ENABLED_IF_NOT_IGNORED, ENABLED_IF_NOT_IGNORED and RequestFriendOption or FriendIgnore)
            end

            -- Passenger Mount--
            if isInGroup then
                local mountedState, isRidingGroupMount, hasFreePassengerSlot = GetTargetMountedStateInfo(currentTargetCharacterNameRaw)
                local isPassengerForTarget = IsGroupMountPassengerForTarget(currentTargetCharacterNameRaw)
                local groupMountEnabled = (mountedState == MOUNTED_STATE_MOUNT_RIDER and isRidingGroupMount and (not IsMounted() or isPassengerForTarget))
                local function MountOption()
                    UseMountAsPassenger(currentTargetCharacterNameRaw)
                end
                local optionToShow = isPassengerForTarget and SI_PLAYER_TO_PLAYER_DISMOUNT or SI_PLAYER_TO_PLAYER_RIDE_MOUNT
                self:AddMenuEntry(GetString(optionToShow), platformIcons[optionToShow], groupMountEnabled, MountOption)
            end

            -- Report--
            local function ReportCallback()
                local nameToReport = IsInGamepadPreferredMode() and currentTargetDisplayName or primaryName
                ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(nameToReport)
            end
            self:AddMenuEntry(GetString(SI_CHAT_PLAYER_CONTEXT_REPORT), platformIcons[SI_CHAT_PLAYER_CONTEXT_REPORT], ENABLED, ReportCallback)

            -- Duel--
            local duelStateI, partnerCharacterName, partnerDisplayName = GetDuelInfo()
            if duelStateI ~= DUEL_STATE_IDLE then
                local function AlreadyDuelingWarning(duelState, characterName, displayName)
                    return function ()
                        local userFacingPartnerName = ZO_GetPrimaryPlayerNameWithSecondary(displayName, characterName)
                        local statusString = GetString("SI_DUELSTATE", duelState)
                        statusString = zo_strformat(statusString, userFacingPartnerName)
                        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, statusString)
                    end
                end
                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_DUEL), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_DUEL], DISABLED, AlreadyDuelingWarning(duelStateI, partnerCharacterName, partnerDisplayName))
            else
                local function DuelInviteOption()
                    ChallengeTargetToDuel(currentTargetCharacterName)
                end
                local function DuelIgnore()
                    AlertIgnored(LUIE_STRING_IGNORE_ERROR_DUEL)
                end
                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_DUEL), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_DUEL], ENABLED_IF_NOT_IGNORED, ENABLED_IF_NOT_IGNORED and DuelInviteOption or DuelIgnore)
            end

            -- Play Tribute --
            local tributeInviteStateI, partnerCharacterNameI, partnerDisplayNameI = GetTributeInviteInfo()
            if tributeInviteStateI ~= TRIBUTE_INVITE_STATE_NONE then
                local function TributeInviteFailWarning(tributeInviteState, characterName, displayName)
                    return function ()
                        local userFacingPartnerName = ZO_GetPrimaryPlayerNameWithSecondary(displayName, characterName)
                        local statusString = GetString("SI_TRIBUTEINVITESTATE", tributeInviteState)
                        statusString = zo_strformat(statusString, userFacingPartnerName)
                        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, statusString)
                    end
                end
                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE], DISABLED, TributeInviteFailWarning(tributeInviteStateI, partnerCharacterNameI, partnerDisplayNameI))
            else
                local function TributeInviteOption()
                    ChallengeTargetToTribute(currentTargetCharacterName)
                end
                local isEnabled = ENABLED_IF_NOT_IGNORED and not ZO_IsTributeLocked()
                local function TributeIgnore()
                    AlertIgnored(LUIE_STRING_IGNORE_ERROR_TRIBUTE)
                end
                self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE], isEnabled, ENABLED_IF_NOT_IGNORED and TributeInviteOption or TributeIgnore)
            end

            -- Trade--
            local function TradeInviteOption()
                TRADE_WINDOW:InitiateTrade(primaryNameInternal)
            end
            local function TradeIgnore()
                AlertIgnored(LUIE_STRING_IGNORE_ERROR_TRADE)
            end
            local tradeInviteFunction = ENABLED_IF_NOT_IGNORED and TradeInviteOption or TradeIgnore
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_TRADE), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_TRADE], ENABLED_IF_NOT_IGNORED, tradeInviteFunction)

            -- Cancel--
            self:AddMenuEntry(GetString(SI_RADIAL_MENU_CANCEL_BUTTON), platformIcons[SI_RADIAL_MENU_CANCEL_BUTTON], ENABLED)

            self:GetRadialMenu():Show()
            self.showingPlayerInteractMenu = true
            self.isLastRadialMenuGamepad = IsInGamepadPreferredMode()
        end
    end


    -- Required when hooking ZO_MailSend_Gamepad:IsValid()
    -- Returns whether there is any item attached.
    local function IsAnyItemAttached(bagId, slotIndex)
        for i = 1, MAIL_MAX_ATTACHED_ITEMS do
            local queuedFromBag = GetQueuedItemAttachmentInfo(i)
            if queuedFromBag ~= 0 then -- Slot is filled.
                return true
            end
        end
        return false
    end

    -- Hook Gamepad mail name function
    local orgIsMailValid = ZO_MailSend_Gamepad.IsMailValid
    function ZO_MailSend_Gamepad:IsMailValid(...)
        orgIsMailValid(self, ...)
        local to = self.mailView:GetAddress()
        if (not to) or (to == "") then
            return false
        end

        local nameLink
        if zo_strmatch(to, "@") == "@" then
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(to, nil, DISPLAY_NAME_LINK_TYPE, to)
            else
                nameLink = ZO_LinkHandler_CreateLink(to, nil, DISPLAY_NAME_LINK_TYPE, to)
            end
        else
            if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(to, nil, CHARACTER_LINK_TYPE, to)
            else
                nameLink = ZO_LinkHandler_CreateLink(to, nil, CHARACTER_LINK_TYPE, to)
            end
        end
        g_mailTarget = ZO_SELECTED_TEXT:Colorize(nameLink)

        local subject = self.mailView:GetSubject()
        local hasSubject = subject and (subject ~= "")
        local body = self.mailView:GetBody()
        local hasBody = body and (body ~= "")
        return hasSubject or hasBody or (GetQueuedMoneyAttachment() > 0) or IsAnyItemAttached()
    end

    -- Hook MAIL_SEND.Send to get name of player we send to.
    do
        local originalSend = MAIL_SEND.Send
        function MAIL_SEND:Send(...)
            -- if LUIE.IsDevDebugEnabled() then
            --     LUIE.Debug("MAIL_SEND:Send has been hooked!")
            -- end
            windowManager:SetFocusByName("")

            if not self.sendMoneyMode and GetQueuedCOD() == 0 then
                if ChatAnnouncements.SV.Notify.NotificationMailSendCA then
                    printToChat(GetString(LUIE_STRING_CA_MAIL_ERROR_NO_COD_VALUE), true)
                end
                if ChatAnnouncements.SV.Notify.NotificationMailSendAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(LUIE_STRING_CA_MAIL_ERROR_NO_COD_VALUE))
                end
                PlaySound(SOUNDS.NEGATIVE_CLICK)
            else
                SendMail(self.to:GetText(), self.subject:GetText(), self.body:GetText())

                local mailTarget = self.to:GetText()
                local nameLink
                -- Here we look for @ character in the sent mail, if the player send to an account then we want the link to be an account name link, otherwise, it's a character name link.
                if zo_strmatch(mailTarget, "@") == "@" then
                    if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                        nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(mailTarget, nil, DISPLAY_NAME_LINK_TYPE, mailTarget)
                    else
                        nameLink = ZO_LinkHandler_CreateLink(mailTarget, nil, DISPLAY_NAME_LINK_TYPE, mailTarget)
                    end
                else
                    if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                        nameLink = ZO_LinkHandler_CreateLinkWithoutBrackets(mailTarget, nil, CHARACTER_LINK_TYPE, mailTarget)
                    else
                        nameLink = ZO_LinkHandler_CreateLink(mailTarget, nil, CHARACTER_LINK_TYPE, mailTarget)
                    end
                end
                g_mailTarget = ZO_SELECTED_TEXT:Colorize(nameLink)
            end
            originalSend(self, ...)
        end
    end
    ---
    --- @param self ZO_InventoryManager
    --- @param questItem questItem
    --- @param searchType any
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_InventoryManager:AddQuestItem(questItem, searchType)
        local inventory = self.inventories[INVENTORY_QUEST_ITEM]

        questItem.inventory = inventory
        -- store all tools and items in a subtable under the questIndex for faster access
        local questIndex = questItem.questIndex
        if not inventory.slots[questIndex] then
            inventory.slots[questIndex] = {}
        end
        questItem.slotIndex = questIndex
        table_insert(inventory.slots[questIndex], questItem)

        -- Display Item if set to display
        if ChatAnnouncements.SV.Inventory.LootQuestAdd or ChatAnnouncements.SV.Inventory.LootQuestRemove then
            DisplayQuestItem(questItem.questItemId, questItem.stackCount, questItem.iconFile, false)
        end
    end

    ---
    --- @param self ZO_InventoryManager
    --- @param questIndex integer
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_InventoryManager:ResetQuest(questIndex)
        local inventory = self.inventories[INVENTORY_QUEST_ITEM]
        local itemTable = inventory.slots[questIndex]
        --- @cast itemTable questItem_itemTable
        if itemTable then
            -- remove all quest items from search
            for i = 1, #itemTable do
                -- Display Item if set to display
                if ChatAnnouncements.SV.Inventory.LootQuestAdd or ChatAnnouncements.SV.Inventory.LootQuestRemove then
                    local itemId = itemTable[i].questItemId
                    local stackCount = itemTable[i].stackCount
                    local icon = itemTable[i].iconFile
                    DisplayQuestItem(itemId, stackCount, icon, true)
                end
            end
        end
        inventory.slots[questIndex] = nil
    end

    -- Called by hooked TryGroupInviteByName function
    -- TODO: Maybe see about links for names here for non-menu
    local function CompleteGroupInvite(characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
        local isLeader = IsUnitGroupLeader("player")
        local groupSize = GetGroupSize()

        if isLeader and groupSize == SMALL_GROUP_SIZE_THRESHOLD then
            ZO_Dialogs_ShowPlatformDialog("LARGE_GROUP_INVITE_WARNING", characterOrDisplayName, { mainTextParams = { SMALL_GROUP_SIZE_THRESHOLD } })
        else
            GroupInviteByName(characterOrDisplayName)

            ZO_Menu_SetLastCommandWasFromMenu(not sentFromChat)
            if isMenu then
                local link
                if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                    link = ZO_LinkHandler_CreateLinkWithoutBrackets(characterOrDisplayName, nil, CHARACTER_LINK_TYPE, characterOrDisplayName)
                else
                    link = ZO_LinkHandler_CreateLink(characterOrDisplayName, nil, CHARACTER_LINK_TYPE, characterOrDisplayName)
                end
                printToChat(zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MENU), link), true)
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MENU), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)))
                end
            else
                printToChat(zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_INVITED), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)), true)
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_INVITED), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)))
                end
            end
        end
    end

    -- HOOK Group Invite function so we can modify CA/Alert here
    TryGroupInviteByName = function (characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
        if IsPlayerInGroup(characterOrDisplayName) then
            printToChat(GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER), true)
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        end

        local isLeader = IsUnitGroupLeader("player")
        local groupSize = GetGroupSize()

        if not isLeader and groupSize > 0 then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE))
            return
        end

        if IsConsoleUI() then
            local displayName = characterOrDisplayName

            local function GroupInviteCallback(success)
                if success then
                    CompleteGroupInvite(displayName, sentFromChat, displayInvitedMessage, isMenu)
                end
            end

            ZO_ConsoleAttemptInteractOrError(GroupInviteCallback, displayName, ZO_PLAYER_CONSOLE_INFO_REQUEST_DONT_BLOCK, ZO_CONSOLE_CAN_COMMUNICATE_ERROR_ALERT, ZO_ID_REQUEST_TYPE_DISPLAY_NAME, displayName)
        else
            if IsIgnored(characterOrDisplayName) then
                printToChat(GetString(LUIE_STRING_IGNORE_ERROR_GROUP), true)
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, LUIE_STRING_IGNORE_ERROR_GROUP)
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                return
            end

            CompleteGroupInvite(characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
        end
    end

    ChatAnnouncements.GuildHooks()

    -- Replace the default DeclineLFGReadyCheckNotification function to display the message that we are not in queue any longer + LFG activity join event.
    local zos_DeclineLFGReadyCheckNotification = DeclineLFGReadyCheckNotification
    DeclineLFGReadyCheckNotification = function (self)
        zos_DeclineLFGReadyCheckNotification()

        local message = (GetString(SI_LFGREADYCHECKCANCELREASON3))
        g_showRCUpdates = true
        g_weDeclinedTheQueue = true
        LUIE_CallLater(function ()
            g_weDeclinedTheQueue = false
        end, 1000)

        if ChatAnnouncements.SV.Group.GroupLFGQueueCA then
            printToChat(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGQueueAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, message)
        end
    end
end

function ChatAnnouncements.GuildHooks()
    -- Hook for EVENT_GUILD_MEMBER_ADDED
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_GuildRosterManager:OnGuildMemberAdded(guildId, displayName)
        self:RefreshData()

        local data = self:FindDataByDisplayName(displayName)
        if data and data.rankId ~= DEFAULT_INVITED_RANK then
            local hasCharacter, rawCharacterName, zone, class, alliance, level, championPoints = GetGuildMemberCharacterInfo(self.guildId, data.index)
            local displayNameLink = ChatAnnouncements.ResolveNameLink(rawCharacterName, displayName)
            local guildName = self.guildName
            local guildAlliance = GetGuildAlliance(guildId)
            local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
            local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
            local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

            if ChatAnnouncements.SV.Social.GuildCA then
                printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_ADDED), displayNameLink, guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_ADDED), displayName, guildNameAllianceAlert))
            end
            PlaySound(SOUNDS.GUILD_ROSTER_ADDED)
        end
    end

    -- Hook for EVENT_GUILD_MEMBER_REMOVED
    --- @diagnostic disable-next-line: duplicate-set-field
    function ZO_GuildRosterManager:OnGuildMemberRemoved(guildId, rawCharacterName, displayName)
        local displayNameLink = ChatAnnouncements.ResolveNameLink(rawCharacterName, displayName)
        local guildName = self.guildName
        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if ChatAnnouncements.SV.Social.GuildCA then
            printToChat(zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_LEFT), displayNameLink, guildNameAlliance), true)
        end
        if ChatAnnouncements.SV.Social.GuildAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GUILD_ROSTER_LEFT), displayName, guildNameAllianceAlert))
        end
        PlaySound(SOUNDS.GUILD_ROSTER_REMOVED)

        self:RefreshData()
    end

    local EVENT_NAMESPACE = "GuildRoster"
    -- Unregister ZOS Guild Roster events and replace with our own.
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_PLAYER_RANK_CHANGED)
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL)
    eventManager:UnregisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_PLAYER_RANK_CHANGED, ChatAnnouncements.GuildPlayerRankChanged)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_PROMOTE_SUCCESSFUL, ChatAnnouncements.GuildMemberPromoteSuccessful)
    eventManager:RegisterForEvent(EVENT_NAMESPACE, EVENT_GUILD_MEMBER_DEMOTE_SUCCESSFUL, ChatAnnouncements.GuildMemberDemoteSuccessful)

    -- Hook for Guild Invite function used from Guild Menu
    function ZO_TryGuildInvite(guildId, displayName)
        -- TODO: Update when more alerts are added to CA
        if not DoesPlayerHaveGuildPermission(guildId, GUILD_PERMISSION_INVITE) then
            ZO_AlertEvent(EVENT_SOCIAL_ERROR, SOCIAL_RESULT_NO_INVITE_PERMISSION)
            return
        end

        -- TODO: Update when more alerts are added to CA
        if GetNumGuildMembers(guildId) == MAX_GUILD_MEMBERS then
            ZO_AlertEvent(EVENT_SOCIAL_ERROR, SOCIAL_RESULT_NO_ROOM)
            return
        end

        local guildName = GetGuildName(guildId)
        local guildAlliance = GetGuildAlliance(guildId)
        local guildColor = ChatAnnouncements.SV.Social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
        local guildNameAlliance = ChatAnnouncements.SV.Social.GuildIcon and guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName)) or (guildColor:Colorize(guildName))
        local guildNameAllianceAlert = ChatAnnouncements.SV.Social.GuildIcon and zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName) or guildName

        if IsConsoleUI() then
            local function GuildInviteCallback(success)
                if success then
                    GuildInvite(guildId, displayName)
                    if ChatAnnouncements.SV.Social.GuildCA then
                        printToChat(zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, UndecorateDisplayName(displayName), guildNameAlliance), true)
                    end
                    if ChatAnnouncements.SV.Social.GuildAlert then
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, UndecorateDisplayName(displayName), guildNameAllianceAlert))
                    end
                end
            end

            ZO_ConsoleAttemptInteractOrError(GuildInviteCallback, displayName, ZO_PLAYER_CONSOLE_INFO_REQUEST_DONT_BLOCK, ZO_CONSOLE_CAN_COMMUNICATE_ERROR_ALERT, ZO_ID_REQUEST_TYPE_DISPLAY_NAME, displayName)
        else
            -- TODO: This needs fixed in the API so that character names are also factored in here. This check here is just about pointless as it stands.
            if IsIgnored(displayName) then
                if ChatAnnouncements.SV.Social.GuildCA then
                    printToChat(GetString(LUIE_STRING_IGNORE_ERROR_GUILD), true)
                end
                if ChatAnnouncements.SV.Social.GuildAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_IGNORE_ERROR_GUILD))
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                return
            end

            GuildInvite(guildId, displayName)
            if ChatAnnouncements.SV.Social.GuildCA then
                printToChat(zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, displayName, guildNameAlliance), true)
            end
            if ChatAnnouncements.SV.Social.GuildAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(LUIE_STRING_CA_GUILD_ROSTER_INVITED_MESSAGE, displayName, guildNameAllianceAlert))
            end
        end
    end

    -- Called when changing guilds in the Guild tab
    local originalSetGuildId = GUILD_SHARED_INFO.SetGuildId
    function GUILD_SHARED_INFO:SetGuildId(guildId)
        self.guildId = guildId
        self:Refresh(guildId)
        -- Set selected guild for use when resolving Rank/Heraldry updates
        g_selectedGuild = guildId
    end

    -- Called when changing guilds in the Guild tab or leaving/joining a guild
    local originalRefresh = GUILD_SHARED_INFO.Refresh
    function GUILD_SHARED_INFO:Refresh(guildId)
        if self.guildId and self.guildId == guildId then
            local count = GetControl(self.control, "Count")
            local numGuildMembers, numOnline = GetGuildInfo(guildId)

            --- @diagnostic disable-next-line: need-check-nil
            count:SetText(zo_strformat(SI_GUILD_NUM_MEMBERS_ONLINE_FORMAT, numOnline, numGuildMembers))

            self.canDepositToBank = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_BANK_DEPOSIT)
            if self.canDepositToBank then
                self.bankIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.bankIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end

            self.canUseTradingHouse = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_TRADING_HOUSE)
            if self.canUseTradingHouse then
                self.tradingHouseIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.tradingHouseIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end

            self.canUseHeraldry = DoesGuildHavePrivilege(guildId, GUILD_PRIVILEGE_HERALDRY)
            if self.canUseHeraldry then
                self.heraldryIcon:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
            else
                self.heraldryIcon:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
            end
        end
        -- Set selected guild for use when resolving Rank/Heraldry updates
        g_selectedGuild = guildId
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
        g_inventoryStacks = {}
        ChatAnnouncements.IndexInventory() -- Index Inventory
    end
    g_inTrade = true
end

--- Adds items to index if they are added in a trade.
--- @param eventCode number The event code that triggered this function
--- @param who TradeParticipant The name of the trading partner
--- @param tradeIndex luaindex The trade slot index
--- @param itemSoundCategory ItemUISoundCategory The item sound category
function ChatAnnouncements.OnTradeAdded(eventCode, who, tradeIndex, itemSoundCategory)
    local index = tradeIndex
    local name, icon, stack = GetTradeItemInfo(who, tradeIndex)
    local itemLink = GetTradeItemLink(who, tradeIndex, linkBrackets[ChatAnnouncements.SV.BracketOptionItem])
    local itemId = GetItemLinkItemId(itemLink)
    local itemType = GetItemLinkItemType(itemLink)

    if who == 0 then
        g_tradeStacksOut[index] = { icon = icon, stack = stack, itemId = itemId, itemLink = itemLink, itemType = itemType }
    else
        g_tradeStacksIn[index] = { icon = icon, stack = stack, itemId = itemId, itemLink = itemLink, itemType = itemType }
    end
end

--- Removes items from index if they are removed from the trade.
--- @param eventCode integer The event code that triggered this function
--- @param who TradeParticipant The name of the trading partner
--- @param tradeIndex luaindex The trade slot index
--- @param itemSoundCategory ItemUISoundCategory The item sound category
function ChatAnnouncements.OnTradeRemoved(eventCode, who, tradeIndex, itemSoundCategory)
    local indexOut = tradeIndex
    if who == 0 then
        g_tradeStacksOut[indexOut] = nil
    else
        g_tradeStacksIn[indexOut] = nil
    end
end

-- Called on player joining a group to determine if message syntax should show group or LFG group.
function ChatAnnouncements.CheckLFGStatusJoin()
    if not g_stopGroupLeaveQueue then
        if not g_lfgDisableGroupEvents then
            if IsInLFGGroup() and not g_joinLFGOverride then
                if ChatAnnouncements.SV.Group.GroupCA then
                    printToChat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF_LFG), true)
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN_SELF_LFG))
                end
            elseif not IsInLFGGroup() and not g_joinLFGOverride then
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
                    local groupSize = GetGroupSize()
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
        g_joinLFGOverride = false
    end
end

--- Called when another player joins the group.
--- @param SendMessage boolean Whether to send a chat message
--- @param SendAlert boolean Whether to send an alert
function ChatAnnouncements.PrintJoinStatusNotSelf(SendMessage, SendAlert)
    -- Bail out if we're hiding events from LFG.
    if g_stopGroupLeaveQueue or g_lfgDisableGroupEvents then
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
    if g_stopGroupLeaveQueue or g_lfgDisableGroupEvents then
        g_leaveLFGOverride = false
        return
    end
    if g_leaveLFGOverride and GetGroupSize() == 0 then
        if ChatAnnouncements.SV.Group.GroupCA then
            printToChat(GetString(LUIE_STRING_CA_GROUP_QUIT_LFG), true)
        end
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_CA_GROUP_QUIT_LFG))
        end
    end
    g_leaveLFGOverride = false
end

--- Handles group invite received events. Runs on the `EVENT_GROUP_INVITE_RECEIVED` event.
--- @param eventCode number The event code that triggered this function
--- @param inviterName string The name of the inviter
--- @param inviterDisplayName string The display name of the inviter
function ChatAnnouncements.OnGroupInviteReceived(eventCode, inviterName, inviterDisplayName)
    if ChatAnnouncements.SV.Group.GroupCA then
        local finalName = ChatAnnouncements.ResolveNameLink(inviterName, inviterDisplayName)
        local message = zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MESSAGE), finalName)
        printToChat(message, true)
    end
    if ChatAnnouncements.SV.Group.GroupAlert then
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(inviterName, inviterDisplayName)
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
        g_groupLootIndex[characterName] = { characterName = characterName, displayName = displayName }
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
    g_leaveLFGOverride = true
end

--- Handles marriage offer events. Runs on the `EVENT_PLEDGE_OF_MARA_OFFER` event.
--- @param eventCode number The event code that triggered this function
--- @param characterName string The character name of the player
--- @param isSender boolean Whether the local player is the sender
--- @param displayName string The display name of the player
function ChatAnnouncements.MaraOffer(eventCode, characterName, isSender, displayName)
    -- Display CA
    if ChatAnnouncements.SV.Social.PledgeOfMaraCA then
        local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
        if isSender then
            printToChat(zo_strformat(GetString(SI_PLEDGE_OF_MARA_SENDER_MESSAGE), finalName), true)
        else
            printToChat(zo_strformat(GetString(SI_PLEDGE_OF_MARA_MESSAGE), finalName), true)
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
    g_stackSplit = false
    eventManager:UnregisterForUpdate(moduleName .. "StackTracker")
end

--- Prints queued messages
function ChatAnnouncements.PrintQueuedMessages()
    -- messageType processing order
    local messageTypeOrder =
    {
        "NOTIFICATION",
        "QUEST_POI",
        "QUEST",
        "EXPERIENCE",
        "EXPERIENCE_LEVEL",
        "SKILL_GAIN",
        "SKILL_MORPH",
        "SKILL_LINE",
        "SKILL",
        "CURRENCY_POSTAGE",
        "QUEST_LOOT_REMOVE",
        "CONTAINER",
        "CURRENCY",
        "QUEST_LOOT_ADD",
        "LOOT",
        "ANTIQUITY",
        "COLLECTIBLE",
        "ACHIEVEMENT",
        "MESSAGE"
    }

    -- Helper function to process a single message
    local function processMessage(message, messageType)
        if not message or message == "" then return end

        -- Special handling for different message types
        if messageType == "CONTAINER" or messageType == "LOOT" then
            ChatAnnouncements.ResolveItemMessage(
                message.message,
                message.formattedRecipient,
                message.color,
                message.logPrefix,
                message.totalString,
                message.groupLoot
            )
            return
        end

        -- Quest item handling
        if messageType == "QUEST_LOOT_REMOVE" and g_questItemAdded[message.itemId] then return end
        if messageType == "QUEST_LOOT_ADD" and g_questItemRemoved[message.itemId] then return end

        -- Default message handling
        local isSystem = message.isSystem or false
        printToChat(message.message, isSystem)
    end

    -- Process messages in defined order
    for _, messageType in pairs(messageTypeOrder) do
        for i = 1, #ChatAnnouncements.QueuedMessages do
            local message = ChatAnnouncements.QueuedMessages[i]
            if message and message.messageType == messageType then
                processMessage(message, messageType)
            end
        end
    end

    -- Reset queue state
    ChatAnnouncements.QueuedMessages = {}
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
    local link = GetCollectibleLink(collectibleId, linkBrackets[ChatAnnouncements.SV.BracketOptionCollectibleUse])

    local formattedIcon = ChatAnnouncements.SV.Collectibles.CollectibleUseIcon and ("|t16:16:" .. icon .. "|t ") or ""

    local message = zo_strformat(messageString, link, formattedIcon)
    local alert = zo_strformat(messageString, name, "")

    if message and ChatAnnouncements.SV.Collectibles.CollectibleUseCA or collectibleId > 0 then
        message = ColorizeColors.CollectibleUseColorize:Colorize(message)
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
    LUIE_CallLater(ChatAnnouncements.CollectibleResult, latency)
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

    if newAssistant ~= currentAssistant then
        if newAssistant == 0 then
            lastCollectibleUsed = currentAssistant
        else
            lastCollectibleUsed = newAssistant
            -- currentCompanion = newAssistant -- fixes summoning assistant, if companion already summoned, from using sys message/icon of old companion instead of new assistant
        end
    end
    if newCompanion ~= currentCompanion then
        if newCompanion == 0 then
            lastCollectibleUsed = currentCompanion
        else
            lastCollectibleUsed = newCompanion
        end
    end
    if newVanity ~= currentVanity then
        if newVanity == 0 then
            lastCollectibleUsed = currentVanity
        else
            lastCollectibleUsed = newVanity
        end
    end
    if newSpecial ~= currentSpecial then
        if newSpecial == 0 then
            lastCollectibleUsed = currentSpecial
        else
            lastCollectibleUsed = newSpecial
        end
    end
    if newHat ~= currentHat then
        if newHat == 0 then
            lastCollectibleUsed = currentHat
        else
            lastCollectibleUsed = newHat
        end
    end
    if newHair ~= currentHair then
        if newHair == 0 then
            lastCollectibleUsed = currentHair
        else
            lastCollectibleUsed = newHair
        end
    end
    if newHeadMark ~= currentHeadMark then
        if newHeadMark == 0 then
            lastCollectibleUsed = currentHeadMark
        else
            lastCollectibleUsed = newHeadMark
        end
    end
    if newFacialHair ~= currentFacialHair then
        if newFacialHair == 0 then
            lastCollectibleUsed = currentFacialHair
        else
            lastCollectibleUsed = newFacialHair
        end
    end
    if newMajorAdorn ~= currentMajorAdorn then
        if newMajorAdorn == 0 then
            lastCollectibleUsed = currentMajorAdorn
        else
            lastCollectibleUsed = newMajorAdorn
        end
    end
    if newMinorAdorn ~= currentMinorAdorn then
        if newMinorAdorn == 0 then
            lastCollectibleUsed = currentMinorAdorn
        else
            lastCollectibleUsed = newMinorAdorn
        end
    end
    if newCostume ~= currentCostume then
        if newCostume == 0 then
            lastCollectibleUsed = currentCostume
        else
            lastCollectibleUsed = newCostume
        end
    end
    if newBodyMarking ~= currentBodyMarking then
        if newBodyMarking == 0 then
            lastCollectibleUsed = currentBodyMarking
        else
            lastCollectibleUsed = newBodyMarking
        end
    end
    if newSkin ~= currentSkin then
        if newSkin == 0 then
            lastCollectibleUsed = currentSkin
        else
            lastCollectibleUsed = newSkin
        end
    end
    if newPersonality ~= currentPersonality then
        if newPersonality == 0 then
            lastCollectibleUsed = currentPersonality
        else
            lastCollectibleUsed = newPersonality
        end
    end
    if newPolymorph ~= currentPolymorph then
        if newPolymorph == 0 then
            lastCollectibleUsed = currentPolymorph
        else
            lastCollectibleUsed = newPolymorph
        end
    end

    currentAssistant = newAssistant
    currentCompanion = newCompanion
    currentVanity = newVanity
    currentSpecial = newSpecial
    currentHat = newHat
    currentHair = newHair
    currentHeadMark = newHeadMark
    currentFacialHair = newFacialHair
    currentMajorAdorn = newMajorAdorn
    currentMinorAdorn = newMinorAdorn
    currentCostume = newCostume
    currentBodyMarking = newBodyMarking
    currentSkin = newSkin
    currentPersonality = newPersonality
    currentPolymorph = newPolymorph

    -- If neither menu option is enabled, then bail out here
    if not (ChatAnnouncements.SV.Collectibles.CollectibleUseCA or ChatAnnouncements.SV.Collectibles.CollectibleUseAlert) then
        if not LUIE.SlashCollectibleOverride then
            lastCollectibleUsed = 0
            return
        end
    end

    if lastCollectibleUsed == 0 then
        LUIE.SlashCollectibleOverride = false
        return
    end
    local collectibleType = GetCollectibleCategoryType(lastCollectibleUsed)

    local message = ""
    local alert = ""
    local link = GetCollectibleLink(lastCollectibleUsed, linkBrackets[ChatAnnouncements.SV.BracketOptionCollectibleUse])
    local name = GetCollectibleName(lastCollectibleUsed)
    local nickname = GetCollectibleNickname(lastCollectibleUsed)
    local icon = GetCollectibleIcon(lastCollectibleUsed)
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
            if GetActiveCollectibleByType(GetCollectibleCategoryType(lastCollectibleUsed), GAMEPLAY_ACTOR_CATEGORY_PLAYER) > 0 then
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
        printToChat(message)
    end
    if alert and ChatAnnouncements.SV.Collectibles.CollectibleUseAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alert)
    end

    lastCollectibleUsed = 0
    LUIE.SlashCollectibleOverride = false
end

-- EVENT_EXPERIENCE_GAIN HANDLER
function ChatAnnouncements.OnExperienceGain(eventCode, reason, level, previousExperience, currentExperience, championPoints)
    -- d("Experience Gain) previousExperience: " .. previousExperience .. " --- " .. "currentExperience: " .. currentExperience)
    if ChatAnnouncements.SV.XP.Experience and (not (ChatAnnouncements.SV.XP.ExperienceHideCombat and reason == PROGRESS_REASON_KILL) or not reason == PROGRESS_REASON_KILL) then
        local change = currentExperience - previousExperience -- Change in Experience Points on gaining them

        -- If throttle is enabled, save value and end function here
        if ChatAnnouncements.SV.XP.ExperienceThrottle > 0 and reason == PROGRESS_REASON_KILL then
            g_xpCombatBufferValue = g_xpCombatBufferValue + change
            -- We unregister the event, then re-register it, this keeps the buffer at a constant X throttle after XP is gained.
            eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
            eventManager:RegisterForUpdate(moduleName .. "BufferedXP", ChatAnnouncements.SV.XP.ExperienceThrottle, ChatAnnouncements.PrintBufferedXP)
            return
        end

        -- If filter is enabled and value is below filter then end function here
        if ChatAnnouncements.SV.XP.ExperienceFilter > 0 and reason == PROGRESS_REASON_KILL then
            if change < ChatAnnouncements.SV.XP.ExperienceFilter then
                return
            end
        end

        -- If we gain experience from a non combat source, and our buffer function holds a value, then we need to immediately dump this value before the next XP update is processed.
        if ChatAnnouncements.SV.XP.ExperienceThrottle > 0 and g_xpCombatBufferValue > 0 and (reason ~= PROGRESS_REASON_KILL and reason ~= 99) then
            eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
            ChatAnnouncements.PrintBufferedXP()
        end

        ChatAnnouncements.PrintExperienceGain(change)
    end
end

-- Print Experience Gain
function ChatAnnouncements.PrintExperienceGain(change)
    local icon = ChatAnnouncements.SV.XP.ExperienceIcon and "|t16:16:/esoui/art/icons/icon_experience.dds|t " or ""
    local xpName = zo_strformat(ChatAnnouncements.SV.XP.ExperienceName, change)
    local messageP1 = ("|r|c" .. ColorizeColors.ExperienceNameColorize .. icon .. ZO_CommaDelimitDecimalNumber(change) .. " " .. xpName .. "|r|c" .. ColorizeColors.ExperienceMessageColorize)
    local formattedMessageP1 = (string_format(ChatAnnouncements.SV.XP.ExperienceMessage, messageP1))
    local finalMessage = string_format("|c%s%s|r", ColorizeColors.ExperienceMessageColorize, formattedMessageP1)

    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = "EXPERIENCE" }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

-- Print Buffered Experience Gain
function ChatAnnouncements.PrintBufferedXP()
    if g_xpCombatBufferValue > 0 and g_xpCombatBufferValue > ChatAnnouncements.SV.XP.ExperienceFilter then
        local change = g_xpCombatBufferValue
        ChatAnnouncements.PrintExperienceGain(change)
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
    g_xpCombatBufferValue = 0
end

-- EVENT_SKILL_XP_UPDATE HANDLER
function ChatAnnouncements.SkillXPUpdate(eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP)
    if skillType == SKILL_TYPE_GUILD then
        local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillIndex)
        local lineName, lineId = skillLineData:GetName(), skillLineData:GetId()
        local formattedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, lineName)

        -- Bail out early if a certain type is not set to be displayed
        if lineId == 45 and not ChatAnnouncements.SV.Skills.SkillGuildFighters then
            return
        elseif lineId == 44 and not ChatAnnouncements.SV.Skills.SkillGuildMages then
            return
        elseif lineId == 55 and not ChatAnnouncements.SV.Skills.SkillGuildUndaunted then
            return
        elseif lineId == 117 and not ChatAnnouncements.SV.Skills.SkillGuildThieves then
            return
        elseif lineId == 118 and not ChatAnnouncements.SV.Skills.SkillGuildDarkBrotherhood then
            return
        elseif lineId == 130 and not ChatAnnouncements.SV.Skills.SkillGuildPsijicOrder then
            return
        end

        local change = currentXP - previousXP
        local priority

        if ChatAnnouncements.SV.Skills.SkillGuildAlert then
            local text = zo_strformat(GetString(LUIE_STRING_CA_SKILL_GUILD_ALERT), formattedName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
        end

        -- Bail out or save value if Throttle/Threshold conditions are met
        if lineId == 45 then
            priority = "EXPERIENCE_LEVEL"
            -- FG rep is either a quest reward (10) or kills (1 & 5)
            -- Only throttle values 5 or lower (FG Dailies give +10 skill)
            if ChatAnnouncements.SV.Skills.SkillGuildThrottle > 0 and change <= 5 then
                g_guildSkillThrottle = g_guildSkillThrottle + change
                g_guildSkillThrottleLine = formattedName
                eventManager:UnregisterForUpdate(moduleName .. "BufferedRep")
                eventManager:RegisterForUpdate(moduleName .. "BufferedRep", ChatAnnouncements.SV.Skills.SkillGuildThrottle, ChatAnnouncements.PrintBufferedGuildRep)
                return
            end

            -- If throttle wasn't triggered and the value was below threshold then bail out.
            if change <= ChatAnnouncements.SV.Skills.SkillGuildThreshold then
                return
            end
        end

        if lineId == 44 then
            -- Mages Guild rep is either a quest reward (10), book discovered (5), collection discovered (20)
            if change == 10 then
                priority = "EXPERIENCE_LEVEL"
            else
                priority = "MESSAGE"
            end
        end

        if lineId == 55 or lineId == 117 or lineId == 118 or lineId == 130 then
            -- Other guilds are usually either a quest reward or achievement reward
            priority = "EXPERIENCE_LEVEL"
        end
        ChatAnnouncements.PrintGuildRep(change, formattedName, lineId, priority)
    end
end

-- Helper function to get the color for the Guild
local function GetGuildColor(lineId)
    local GUILD_SKILL_COLOR_TABLE =
    {
        [45] = ColorizeColors.SkillGuildColorizeFG,
        [44] = ColorizeColors.SkillGuildColorizeMG,
        [55] = ColorizeColors.SkillGuildColorizeUD,
        [117] = ColorizeColors.SkillGuildColorizeTG,
        [118] = ColorizeColors.SkillGuildColorizeDB,
        [130] = ColorizeColors.SkillGuildColorizePO,
    }
    return GUILD_SKILL_COLOR_TABLE[lineId]
end

-- TODO: Check if there is an equivalency in one of the handlers for this
local GUILD_SKILL_ICONS =
{
    [45] = "/esoui/art/icons/mapkey/mapkey_fightersguild.dds",
    [44] = "/esoui/art/icons/mapkey/mapkey_magesguild.dds",
    [55] = "/esoui/art/icons/mapkey/mapkey_undaunted.dds",
    [117] = "/esoui/art/icons/mapkey/mapkey_thievesguild.dds",
    [118] = "/esoui/art/icons/mapkey/mapkey_darkbrotherhood.dds",
    [130] = "LuiExtended/media/unitframes/mapkey_psijicorder.dds",
}

-- Print Guild Rep Gain
function ChatAnnouncements.PrintGuildRep(change, lineName, lineId, priority)
    local icon = zo_iconFormatInheritColor(GUILD_SKILL_ICONS[lineId], 16, 16)
    local formattedIcon = ChatAnnouncements.SV.Skills.SkillGuildIcon and (icon .. " ") or ""

    local guildString = zo_strformat(ChatAnnouncements.SV.Skills.SkillGuildRepName, change)
    local colorize = GetGuildColor(lineId)
    local messageP1 = ("|r|c" .. colorize .. formattedIcon .. change .. " " .. lineName .. " " .. guildString .. "|r|c" .. ColorizeColors.SkillGuildColorize)
    local formattedMessageP1 = (string_format(ChatAnnouncements.SV.Skills.SkillGuildMsg, messageP1))
    local finalMessage = string_format("|c%s%s|r", ColorizeColors.SkillGuildColorize, formattedMessageP1)

    -- We set this to skill gain, so as to avoid creating an entire additional chat message category (we want it to show after XP but before any other skill gains or level up so we place it on top of the level up priority).
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, messageType = priority }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

-- Print Buffered Guild Rep Gain
function ChatAnnouncements.PrintBufferedGuildRep()
    if g_guildSkillThrottle > 0 and g_guildSkillThrottle > ChatAnnouncements.SV.Skills.SkillGuildThreshold then
        local lineId = 45
        local lineName = g_guildSkillThrottleLine
        ChatAnnouncements.PrintGuildRep(g_guildSkillThrottle, lineName, lineId, "EXPERIENCE_LEVEL")
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedRep")
    g_guildSkillThrottle = 0
    g_guildSkillThrottleLine = ""
end

--- @class (partial) ChatAnnouncements
LUIE.ChatAnnouncements = ChatAnnouncements
