-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- ChatAnnouncements namespace
--- @class (partial) ChatAnnouncements
local ChatAnnouncements = {}

--- @class (partial) ChatAnnouncements
LUIE.ChatAnnouncements = ChatAnnouncements

-- Queued Messages Storage for CA Modules
ChatAnnouncements.QueuedMessages = {}
ChatAnnouncements.QueuedMessagesCounter = 1

-- Setup Color Table
ChatAnnouncements.Colors = {}

------------------------------------------------
-- DEFAULT VARIABLE SETUP ----------------------
------------------------------------------------
ChatAnnouncements.Enabled = false
ChatAnnouncements.Defaults =
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
}
