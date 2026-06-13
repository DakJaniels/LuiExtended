-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- ChatAnnouncements namespace (see ChatAnnouncementsTypes.lua for full partial class fields)
--- @class (partial) ChatAnnouncements
--- @type ChatAnnouncements
local ChatAnnouncements = {}

LUIE.ChatAnnouncements = ChatAnnouncements

--- @class QueuedMessage
--- @field message string
--- @field type string
--- @field isSystem? boolean
--- @field itemId? integer
--- @field formattedRecipient? string
--- @field color? string
--- @field logPrefix? string
--- @field totalString? string
--- @field groupLoot? boolean
--- @field guildAnnounceGuildId? integer Guild id for guild-bank LOOT/CONTAINER context (see ResolveItemMessage)
--- @field timedActivityAnnounceKey? string Dedupe key from GetTimedActivityProgressAnnounceKey (MESSAGE rows only)

-- Queued Messages Storage for CA Modules
ChatAnnouncements.QueuedMessages = {} --- @type table<integer,QueuedMessage>
ChatAnnouncements.QueuedMessagesCounter = 1

-- Setup Color Table
local caColors = {}
--- @cast caColors CAColors
ChatAnnouncements.Colors = caColors

-- Runtime flags, indexes, and session state (see ChatAnnouncements.lua init).
local caState = {}
--- @cast caState CAState
ChatAnnouncements.State = caState

-- File-scope helpers (Lua 5.1 local limit); defined in ChatAnnouncements.lua / ChatAnnouncementsCSA.lua.
local caInternal = {}
--- @cast caInternal CAInternal
ChatAnnouncements.Internal = caInternal

-- Bracket / link-style options for formatted CA strings (read-only).
--- @type CABrackets
ChatAnnouncements.Brackets =
{
    bracket1 =
    {
        [1] = "[",
        [2] = "(",
        [3] = "",
        [4] = "",
        [5] = "",
    },
    bracket2 =
    {
        [1] = "]",
        [2] = ")",
        [3] = " -",
        [4] = ":",
        [5] = "",
    },
    bracket3 =
    {
        [1] = "[",
        [2] = "(",
        [3] = "- ",
        [4] = "",
    },
    bracket4 =
    {
        [1] = "]",
        [2] = ")",
        [3] = "",
        [4] = "",
    },
    linkBrackets =
    {
        [1] = LINK_STYLE_DEFAULT,
        [2] = LINK_STYLE_BRACKETS,
    },
    linkBracket1 =
    {
        [1] = "",
        [2] = "[",
    },
    linkBracket2 =
    {
        [1] = "",
        [2] = "]",
    },
}

------------------------------------------------
-- DEFAULT VARIABLE SETUP ----------------------
------------------------------------------------

--- RGBA color tuple (0-1). Some entries use 3 components (RGB).
--- @alias CA_Color number[]

--- Chat tab index to enabled state (1-5).
--- @alias CA_ChatTab table<integer, boolean>

--- Display announcement sub-section (CA / CSA / Alert toggles).
--- @class CADisplayAnnouncementSection
--- @field CA boolean
--- @field CSA boolean
--- @field Alert boolean

--- Display announcement section with optional Description (e.g. ZoneIC).
--- @class CADisplayAnnouncementSectionWithDesc
--- @field CA boolean
--- @field CSA boolean
--- @field Alert boolean
--- @field Description? boolean

--- Achievement default settings.
--- @class CAAchievementDefaults
--- @field AchievementCategoryIgnore table<integer, boolean> Inverted list of achievements to be tracked
--- @field AchievementProgressMsg string
--- @field AchievementCompleteMsg string
--- @field AchievementColorProgress boolean
--- @field AchievementColor1 CA_Color
--- @field AchievementColor2 CA_Color
--- @field AchievementCompPercentage boolean
--- @field AchievementUpdateCA boolean
--- @field AchievementUpdateAlert boolean
--- @field AchievementCompleteCA boolean
--- @field AchievementCompleteCSA boolean
--- @field AchievementCompleteAlwaysCSA boolean
--- @field AchievementCompleteAlert boolean
--- @field AchievementIcon boolean
--- @field AchievementCategory boolean
--- @field AchievementSubcategory boolean
--- @field AchievementDetails boolean
--- @field AchievementBracketOptions integer
--- @field AchievementCatBracketOptions integer
--- @field AchievementStep integer

--- Group default settings.
--- @class CAGroupDefaults
--- @field GroupCA boolean
--- @field GroupAlert boolean
--- @field GroupLFGCA boolean
--- @field GroupLFGAlert boolean
--- @field GroupLFGQueueCA boolean
--- @field GroupLFGQueueAlert boolean
--- @field GroupLFGCompleteCA boolean
--- @field GroupLFGCompleteCSA boolean
--- @field GroupLFGCompleteAlert boolean
--- @field GroupVoteCA boolean
--- @field GroupVoteAlert boolean
--- @field GroupRaidCA boolean
--- @field GroupRaidCSA boolean
--- @field GroupRaidAlert boolean
--- @field GroupRaidScoreCA boolean
--- @field GroupRaidScoreCSA boolean
--- @field GroupRaidScoreAlert boolean
--- @field GroupRaidBestScoreCA boolean
--- @field GroupRaidBestScoreCSA boolean
--- @field GroupRaidBestScoreAlert boolean
--- @field GroupRaidReviveCA boolean
--- @field GroupRaidReviveCSA boolean
--- @field GroupRaidReviveAlert boolean

--- Social default settings (Guild, Friend, Duel, Pledge of Mara).
--- @class CASocialDefaults
--- @field GuildCA boolean
--- @field GuildAlert boolean
--- @field GuildRankCA boolean
--- @field GuildRankAlert boolean
--- @field GuildManageCA boolean
--- @field GuildManageAlert boolean
--- @field GuildIcon boolean
--- @field GuildAllianceColor boolean
--- @field GuildColor CA_Color
--- @field GuildRankDisplayOptions integer
--- @field FriendIgnoreCA boolean
--- @field FriendIgnoreAlert boolean
--- @field FriendStatusCA boolean
--- @field FriendStatusAlert boolean
--- @field FriendStatusNameFormat integer
--- @field DuelCA boolean
--- @field DuelAlert boolean
--- @field DuelBoundaryCA boolean
--- @field DuelBoundaryCSA boolean
--- @field DuelBoundaryAlert boolean
--- @field DuelWonCA boolean
--- @field DuelWonCSA boolean
--- @field DuelWonAlert boolean
--- @field DuelStartCA boolean
--- @field DuelStartCSA boolean
--- @field DuelStartAlert boolean
--- @field DuelStartOptions integer
--- @field PledgeOfMaraCA boolean
--- @field PledgeOfMaraCSA boolean
--- @field PledgeOfMaraAlert boolean
--- @field PledgeOfMaraAlertOnlyFail boolean

--- Notify default settings (notifications, disguise, storage, etc.).
--- @class CANotifyDefaults
--- @field NotificationConfiscateCA boolean
--- @field NotificationConfiscateAlert boolean
--- @field NotificationLockpickCA boolean
--- @field NotificationLockpickAlert boolean
--- @field NotificationMailSendCA boolean
--- @field NotificationMailSendAlert boolean
--- @field NotificationMailErrorCA boolean
--- @field NotificationMailErrorAlert boolean
--- @field NotificationTradeCA boolean
--- @field NotificationTradeAlert boolean
--- @field SlashHomeCA boolean
--- @field SlashHomeAlert boolean
--- @field SlashCampaignCA boolean
--- @field SlashCampaignAlert boolean
--- @field CampaignQueueCA boolean
--- @field CampaignQueueAlert boolean
--- @field OutfitEquipCA boolean
--- @field OutfitEquipAlert boolean
--- @field ChallengeDifficultyCA boolean
--- @field ChallengeDifficultyAlert boolean
--- @field SocialErrorCA boolean
--- @field SocialErrorAlert boolean
--- @field DisguiseCA boolean
--- @field DisguiseCSA boolean
--- @field DisguiseAlert boolean
--- @field DisguiseWarnCA boolean
--- @field DisguiseWarnCSA boolean
--- @field DisguiseWarnAlert boolean
--- @field DisguiseAlertColor CA_Color
--- @field StorageRidingColor CA_Color
--- @field StorageRidingBookColor CA_Color
--- @field StorageRidingCA boolean
--- @field StorageRidingCSA boolean
--- @field StorageRidingAlert boolean
--- @field StorageBagColor CA_Color
--- @field StorageBagCA boolean
--- @field StorageBagCSA boolean
--- @field StorageBagAlert boolean
--- @field TimedActivityCA boolean
--- @field TimedActivityAlert boolean
--- @field TimedActivityProgressCA boolean
--- @field TimedActivityProgressAlert boolean
--- @field TimedActivityProgressScope string
--- @field TimedActivityProgressFrequency string
--- @field PromotionalEventsActivityCA boolean
--- @field PromotionalEventsActivityAlert boolean
--- @field CraftedAbilityCA boolean
--- @field CraftedAbilityAlert boolean
--- @field CraftedAbilityScriptCA boolean
--- @field CraftedAbilityScriptAlert boolean

--- Collectibles default settings.
--- @class CACollectiblesDefaults
--- @field CollectibleCA boolean
--- @field CollectibleCSA boolean
--- @field CollectibleAlert boolean
--- @field CollectibleBracket integer
--- @field CollectiblePrefix string
--- @field CollectibleIcon boolean
--- @field CollectibleColor1 CA_Color
--- @field CollectibleColor2 CA_Color
--- @field CollectibleCategory boolean
--- @field CollectibleSubcategory boolean
--- @field CollectibleUseCA boolean
--- @field CollectibleUseAlert boolean
--- @field CollectibleUsePetNickname boolean
--- @field CollectibleUseIcon boolean
--- @field CollectibleUseColor CA_Color
--- @field CollectibleUseCategory3 boolean
--- @field CollectibleUseCategory7 boolean
--- @field CollectibleUseCategory10 boolean
--- @field CollectibleUseCategory12 boolean

--- Lorebooks default settings.
--- @class CALorebooksDefaults
--- @field LorebookCA boolean
--- @field LorebookCSA boolean
--- @field LorebookCSALoreOnly boolean
--- @field LorebookAlert boolean
--- @field LorebookCollectionCA boolean
--- @field LorebookCollectionCSA boolean
--- @field LorebookCollectionAlert boolean
--- @field LorebookCollectionPrefix string
--- @field LorebookPrefix1 string
--- @field LorebookPrefix2 string
--- @field LorebookBracket integer
--- @field LorebookColor1 CA_Color
--- @field LorebookColor2 CA_Color
--- @field LorebookIcon boolean
--- @field LorebookShowHidden boolean
--- @field LorebookCategory boolean

--- Antiquities default settings.
--- @class CAAntiquitiesDefaults
--- @field AntiquityCA boolean
--- @field AntiquityCSA boolean
--- @field AntiquityAlert boolean
--- @field AntiquityBracket integer
--- @field AntiquityPrefix string
--- @field AntiquityPrefixBracket integer
--- @field AntiquitySuffix string
--- @field AntiquityColor CA_Color
--- @field AntiquityIcon boolean

--- Quests default settings.
--- @class CAQuestsDefaults
--- @field QuestShareCA boolean
--- @field QuestShareAlert boolean
--- @field QuestColorLocName CA_Color
--- @field QuestColorLocDescription CA_Color
--- @field QuestColorName CA_Color
--- @field QuestColorDescription CA_Color
--- @field QuestLocLong boolean
--- @field QuestIcon boolean
--- @field QuestLong boolean
--- @field QuestLocDiscoveryCA boolean
--- @field QuestLocDiscoveryCSA boolean
--- @field QuestLocDiscoveryAlert boolean
--- @field QuestLocObjectiveCA boolean
--- @field QuestLocObjectiveCSA boolean
--- @field QuestLocObjectiveAlert boolean
--- @field QuestLocCompleteCA boolean
--- @field QuestLocCompleteCSA boolean
--- @field QuestLocCompleteAlert boolean
--- @field QuestAcceptCA boolean
--- @field QuestAcceptCSA boolean
--- @field QuestAcceptAlert boolean
--- @field QuestCompleteCA boolean
--- @field QuestCompleteCSA boolean
--- @field QuestCompleteAlert boolean
--- @field QuestAbandonCA boolean
--- @field QuestAbandonCSA boolean
--- @field QuestAbandonAlert boolean
--- @field QuestFailCA boolean
--- @field QuestFailCSA boolean
--- @field QuestFailAlert boolean
--- @field QuestObjCompleteCA boolean
--- @field QuestObjCompleteCSA boolean
--- @field QuestObjCompleteAlert boolean
--- @field QuestObjUpdateCA boolean
--- @field QuestObjUpdateCSA boolean
--- @field QuestObjUpdateAlert boolean
--- @field QuestCounterFilterEnable boolean
--- @field QuestCounterFilterKeys table<string, boolean>

--- Experience (XP) default settings.
--- @class CAXPDefaults
--- @field ExperienceEnlightenedCA boolean
--- @field ExperienceEnlightenedCSA boolean
--- @field ExperienceEnlightenedAlert boolean
--- @field ExperienceLevelUpCA boolean
--- @field ExperienceLevelUpCSA boolean
--- @field ExperienceLevelUpAlert boolean
--- @field ExperienceLevelUpCSAExpand boolean
--- @field ExperienceLevelUpIcon boolean
--- @field ExperienceLevelColorByLevel boolean
--- @field ExperienceLevelUpColor CA_Color
--- @field Experience boolean
--- @field ExperienceIcon boolean
--- @field ExperienceMessage string
--- @field ExperienceName string
--- @field ExperienceHideCombat boolean
--- @field ExperienceFilter integer
--- @field ExperienceThrottle integer
--- @field ExperienceColorMessage CA_Color
--- @field ExperienceColorName CA_Color

--- Skills default settings.
--- @class CASkillsDefaults
--- @field SkillPointCA boolean
--- @field SkillPointCSA boolean
--- @field SkillPointAlert boolean
--- @field SkillPointSkyshard string
--- @field SkillPointBracket integer
--- @field SkillPointsPartial boolean
--- @field SkillPointColor1 CA_Color
--- @field SkillPointColor2 CA_Color
--- @field SkillLineUnlockCA boolean
--- @field SkillLineUnlockCSA boolean
--- @field SkillLineUnlockAlert boolean
--- @field SkillLineCA boolean
--- @field SkillLineCSA boolean
--- @field SkillLineAlert boolean
--- @field SkillAbilityCA boolean
--- @field SkillAbilityCSA boolean
--- @field SkillAbilityAlert boolean
--- @field SkillLineIcon boolean
--- @field SkillLineColor CA_Color
--- @field SkillGuildFighters boolean
--- @field SkillGuildMages boolean
--- @field SkillGuildUndaunted boolean
--- @field SkillGuildThieves boolean
--- @field SkillGuildDarkBrotherhood boolean
--- @field SkillGuildPsijicOrder boolean
--- @field SkillGuildIcon boolean
--- @field SkillGuildMsg string
--- @field SkillGuildRepName string
--- @field SkillGuildColor CA_Color
--- @field SkillGuildColorFG CA_Color
--- @field SkillGuildColorMG CA_Color
--- @field SkillGuildColorUD CA_Color
--- @field SkillGuildColorTG CA_Color
--- @field SkillGuildColorDB CA_Color
--- @field SkillGuildColorPO CA_Color
--- @field SkillGuildThrottle integer
--- @field SkillGuildThreshold integer
--- @field SkillGuildAlert boolean

--- Currency default settings.
--- @class CACurrencyDefaults
--- @field CurrencyAPColor CA_Color
--- @field CurrencyAPFilter integer
--- @field CurrencyAPName string
--- @field CurrencyIcon boolean
--- @field CurrencyAPShowChange boolean
--- @field CurrencyAPShowTotal boolean
--- @field CurrencyAPThrottle integer
--- @field CurrencyColor CA_Color
--- @field CurrencyColorDown CA_Color
--- @field CurrencyColorUp CA_Color
--- @field CurrencyContextColor boolean
--- @field CurrencyContextMergedColor boolean
--- @field CurrencyGoldChange boolean
--- @field CurrencyGoldColor CA_Color
--- @field CurrencyGoldFilter integer
--- @field CurrencyGoldHideAH boolean
--- @field CurrencyGoldHideListingAH boolean
--- @field CurrencyGoldName string
--- @field CurrencyGoldShowTotal boolean
--- @field CurrencyGoldThrottle boolean
--- @field CurrencyTVChange boolean
--- @field CurrencyTVColor CA_Color
--- @field CurrencyTVFilter integer
--- @field CurrencyTVName string
--- @field CurrencyTVShowTotal boolean
--- @field CurrencyTVThrottle integer
--- @field CurrencyWVChange boolean
--- @field CurrencyWVColor CA_Color
--- @field CurrencyWVName string
--- @field CurrencyWVShowTotal boolean
--- @field CurrencyTransmuteChange boolean
--- @field CurrencyTransmuteColor CA_Color
--- @field CurrencyTransmuteName string
--- @field CurrencyTransmuteShowTotal boolean
--- @field CurrencyCrownsChange boolean
--- @field CurrencyCrownsColor CA_Color
--- @field CurrencyCrownsName string
--- @field CurrencyCrownsShowTotal boolean
--- @field CurrencyCrownGemsChange boolean
--- @field CurrencyCrownGemsColor CA_Color
--- @field CurrencyCrownGemsName string
--- @field CurrencyCrownGemsShowTotal boolean
--- @field CurrencySealsChange boolean
--- @field CurrencySealsColor CA_Color
--- @field CurrencySealsName string
--- @field CurrencySealsShowTotal boolean
--- @field CurrencyTradeBarsChange boolean
--- @field CurrencyTradeBarsColor CA_Color
--- @field CurrencyTradeBarsName string
--- @field CurrencyTradeBarsShowTotal boolean
--- @field CurrencyTomePointsChange boolean
--- @field CurrencyTomePointsColor CA_Color
--- @field CurrencyTomePointsName string
--- @field CurrencyTomePointsShowTotal boolean
--- @field CurrencyTomePointCachesChange boolean
--- @field CurrencyTomePointCachesColor CA_Color
--- @field CurrencyTomePointCachesName string
--- @field CurrencyTomePointCachesShowTotal boolean
--- @field CurrencyTomeTokensChange boolean
--- @field CurrencyTomeTokensColor CA_Color
--- @field CurrencyTomeTokensName string
--- @field CurrencyTomeTokensShowTotal boolean
--- @field CurrencyTomeChallengeRerollsChange boolean
--- @field CurrencyTomeChallengeRerollsColor CA_Color
--- @field CurrencyTomeChallengeRerollsName string
--- @field CurrencyTomeChallengeRerollsShowTotal boolean
--- @field CurrencyOutfitTokenChange boolean
--- @field CurrencyOutfitTokenColor CA_Color
--- @field CurrencyOutfitTokenName string
--- @field CurrencyOutfitTokenShowTotal boolean
--- @field CurrencyUndauntedChange boolean
--- @field CurrencyUndauntedColor CA_Color
--- @field CurrencyUndauntedName string
--- @field CurrencyUndauntedShowTotal boolean
--- @field CurrencyEndlessChange boolean
--- @field CurrencyEndlessColor CA_Color
--- @field CurrencyEndlessName string
--- @field CurrencyEndlessShowTotal boolean
--- @field CurrencyMessageTotalAP string
--- @field CurrencyMessageTotalGold string
--- @field CurrencyMessageTotalTV string
--- @field CurrencyMessageTotalWV string
--- @field CurrencyMessageTotalTransmute string
--- @field CurrencyMessageTotalCrowns string
--- @field CurrencyMessageTotalCrownGems string
--- @field CurrencyMessageTotalSeals string
--- @field CurrencyMessageTotalTradeBars string
--- @field CurrencyMessageTotalTomePoints string
--- @field CurrencyMessageTotalTomePointCaches string
--- @field CurrencyMessageTotalTomeTokens string
--- @field CurrencyMessageTotalTomeChallengeRerolls string
--- @field CurrencyMessageTotalOutfitToken string
--- @field CurrencyMessageTotalUndaunted string
--- @field CurrencyMessageTotalEndless string

--- Inventory/Loot default settings.
--- @class CAInventoryDefaults
--- @field Loot boolean
--- @field LootLogOverride boolean
--- @field LootBank boolean
--- @field LootBlacklist boolean
--- @field LootTotal boolean
--- @field LootTotalString string
--- @field LootCraft boolean
--- @field LootGroup boolean
--- @field LootIcons boolean
--- @field LootShowCollectionStatus boolean
--- @field LootMail boolean
--- @field LootNotTrash boolean
--- @field LootOnlyNotable boolean
--- @field LootShowArmorType boolean
--- @field LootShowStyle boolean
--- @field LootShowTrait boolean
--- @field LootShowItemType boolean
--- @field LootConfiscate boolean
--- @field LootTrade boolean
--- @field LootVendor boolean
--- @field LootVendorCurrency boolean
--- @field LootVendorTotalCurrency boolean
--- @field LootVendorTotalItems boolean
--- @field LootShowCraftUse boolean
--- @field LootShowDestroy boolean
--- @field LootShowRemove boolean
--- @field LootShowTurnIn boolean
--- @field LootShowList boolean
--- @field LootShowUsePotion boolean
--- @field LootShowUseFood boolean
--- @field LootShowUseDrink boolean
--- @field LootShowUseRepairKit boolean
--- @field LootShowUseSoulGem boolean
--- @field LootShowUseSiege boolean
--- @field LootShowUseFish boolean
--- @field LootShowUseMisc boolean
--- @field LootShowContainer boolean
--- @field LootShowDisguise boolean
--- @field LootShowLockpick boolean
--- @field LootShowRecipe boolean
--- @field LootShowMotif boolean
--- @field LootShowStylePage boolean
--- @field LootRecipeHideAlert boolean
--- @field LootQuestAdd boolean
--- @field LootQuestRemove boolean
--- @field AttunableStationCA boolean
--- @field AttunableStationCSA boolean
--- @field AttunableStationAlert boolean

--- Context message strings (loot/currency action labels).
--- @class CAContextMessagesDefaults
--- @field CurrencyMessageConfiscate string
--- @field CurrencyMessageDeposit string
--- @field CurrencyMessageDepositStorage string
--- @field CurrencyMessageDepositFurnitureVault string
--- @field CurrencyMessageDepositGuild string
--- @field CurrencyMessageEarn string
--- @field CurrencyMessageLoot string
--- @field CurrencyMessageContainer string
--- @field CurrencyMessageSteal string
--- @field CurrencyMessageLost string
--- @field CurrencyMessagePickpocket string
--- @field CurrencyMessageReceive string
--- @field CurrencyMessageSpend string
--- @field CurrencyMessagePay string
--- @field CurrencyMessageUseKit string
--- @field CurrencyMessagePotion string
--- @field CurrencyMessageFood string
--- @field CurrencyMessageDrink string
--- @field CurrencyMessageDeploy string
--- @field CurrencyMessageStow string
--- @field CurrencyMessageFillet string
--- @field CurrencyMessageLearnRecipe string
--- @field CurrencyMessageLearnMotif string
--- @field CurrencyMessageLearnStyle string
--- @field CurrencyMessageExcavate string
--- @field CurrencyMessageTradeIn string
--- @field CurrencyMessageTradeInNoName string
--- @field CurrencyMessageTradeOut string
--- @field CurrencyMessageTradeOutNoName string
--- @field CurrencyMessageMailIn string
--- @field CurrencyMessageMailInNoName string
--- @field CurrencyMessageMailOut string
--- @field CurrencyMessageMailOutNoName string
--- @field CurrencyMessageMailCOD string
--- @field CurrencyMessagePostage string
--- @field CurrencyMessageWithdraw string
--- @field CurrencyMessageWithdrawStorage string
--- @field CurrencyMessageWithdrawFurnitureVault string
--- @field CurrencyMessageWithdrawGuild string
--- @field CurrencyMessageStable string
--- @field CurrencyMessageStorage string
--- @field CurrencyMessageWayshrine string
--- @field CurrencyMessageUnstuck string
--- @field CurrencyMessageChampion string
--- @field CurrencyMessageAttributes string
--- @field CurrencyMessageSkills string
--- @field CurrencyMessageMorphs string
--- @field CurrencyMessageSkillLine string
--- @field CurrencyMessageBounty string
--- @field CurrencyMessageTrader string
--- @field CurrencyMessageRepair string
--- @field CurrencyMessageListing string
--- @field CurrencyMessageListingValue string
--- @field CurrencyMessageList string
--- @field CurrencyMessageCampaign string
--- @field CurrencyMessageFence string
--- @field CurrencyMessageFenceNoV string
--- @field CurrencyMessageSellNoV string
--- @field CurrencyMessageBuyNoV string
--- @field CurrencyMessageBuybackNoV string
--- @field CurrencyMessageSell string
--- @field CurrencyMessageBuy string
--- @field CurrencyMessageBuyback string
--- @field CurrencyMessageLaunder string
--- @field CurrencyMessageLaunderNoV string
--- @field CurrencyMessageUse string
--- @field CurrencyMessageCraft string
--- @field CurrencyMessageExtract string
--- @field CurrencyMessageUpgrade string
--- @field CurrencyMessageUpgradeFail string
--- @field CurrencyMessageRefine string
--- @field CurrencyMessageDeconstruct string
--- @field CurrencyMessageResearch string
--- @field CurrencyMessageDestroy string
--- @field CurrencyMessageLockpick string
--- @field CurrencyMessageRemove string
--- @field CurrencyMessageQuestTurnIn string
--- @field CurrencyMessageQuestUse string
--- @field CurrencyMessageQuestExhaust string
--- @field CurrencyMessageQuestOffer string
--- @field CurrencyMessageQuestDiscard string
--- @field CurrencyMessageQuestConfiscate string
--- @field CurrencyMessageQuestOpen string
--- @field CurrencyMessageQuestAdminister string
--- @field CurrencyMessageQuestPlace string
--- @field CurrencyMessageQuestCombine string
--- @field CurrencyMessageQuestMix string
--- @field CurrencyMessageQuestBundle string
--- @field CurrencyMessageGroup string
--- @field CurrencyMessageDisguiseEquip string
--- @field CurrencyMessageDisguiseRemove string
--- @field CurrencyMessageDisguiseDestroy string

--- Display announcements defaults (Debug + named sections).
--- @class CADisplayAnnouncementsDefaults
--- @field Debug boolean
--- @field General CADisplayAnnouncementSection
--- @field GroupArea CADisplayAnnouncementSection
--- @field Respec CADisplayAnnouncementSection
--- @field ZoneIC CADisplayAnnouncementSectionWithDesc
--- @field ZoneCraglorn CADisplayAnnouncementSection
--- @field ArenaMaelstrom CADisplayAnnouncementSection
--- @field ArenaDragonstar CADisplayAnnouncementSection
--- @field DungeonEndlessArchive CADisplayAnnouncementSection
--- @field DungeonTrial CADisplayAnnouncementSection
--- @field ZoneNightMarket CADisplayAnnouncementSection
--- @field ZoneNightMarketBoulderDash CADisplayAnnouncementSection
--- @field ZoneNightMarketArachnid CADisplayAnnouncementSection
--- @field ZoneNightMarketGuidingLight CADisplayAnnouncementSection
--- @field ZoneNightMarketRewards CADisplayAnnouncementSection
--- @field ZoneNightMarketScavengingMaw CADisplayAnnouncementSection
--- @field ZoneNightMarketZoneHunt CADisplayAnnouncementSection
--- @field ZoneNightMarketEssence CADisplayAnnouncementSection
--- @field ZoneNightMarketMisc CADisplayAnnouncementSection

--- Root default settings for ChatAnnouncements.
--- @class CADefaults
--- @field ChatPlayerDisplayOptions integer
--- @field BracketOptionCharacter integer
--- @field BracketOptionItem integer
--- @field BracketOptionLorebook integer
--- @field BracketOptionCollectible integer
--- @field BracketOptionCollectibleUse integer
--- @field BracketOptionAchievement integer
--- @field Achievement CAAchievementDefaults
--- @field Group CAGroupDefaults
--- @field Social CASocialDefaults
--- @field Notify CANotifyDefaults
--- @field Collectibles CACollectiblesDefaults
--- @field Lorebooks CALorebooksDefaults
--- @field Antiquities CAAntiquitiesDefaults
--- @field Quests CAQuestsDefaults
--- @field XP CAXPDefaults
--- @field Skills CASkillsDefaults
--- @field Currency CACurrencyDefaults
--- @field Inventory CAInventoryDefaults
--- @field ContextMessages CAContextMessagesDefaults
--- @field DisplayAnnouncements CADisplayAnnouncementsDefaults

ChatAnnouncements.Enabled = false
--- @type CADefaults
ChatAnnouncements.Defaults =
{
    -- Chat Message Settings
    ChatPlayerDisplayOptions = 2,
    BracketOptionCharacter = 2,
    BracketOptionItem = 2,
    BracketOptionLorebook = 2,
    BracketOptionCollectible = 2,
    BracketOptionCollectibleUse = 2,
    BracketOptionAchievement = 2,

    -- Achievements
    Achievement =
    {
        AchievementCategoryIgnore = {}, -- Inverted list of achievements to be tracked
        AchievementProgressMsg = GetString(LUIE_STRING_CA_ACHIEVEMENT_PROGRESS_MSG),
        AchievementCompleteMsg = GetString(LUIE_STRING_CA_ACHIEVEMENT_COMPLETE_MSG),
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
        FriendStatusNameFormat = 1,

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

        SlashHomeCA = true,
        SlashHomeAlert = false,
        SlashCampaignCA = true,
        SlashCampaignAlert = false,
        CampaignQueueCA = true,
        CampaignQueueAlert = false,
        OutfitEquipCA = true,
        OutfitEquipAlert = false,
        ChallengeDifficultyCA = true,
        ChallengeDifficultyAlert = false,
        SocialErrorCA = true,
        SocialErrorAlert = false,

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
        TimedActivityProgressCA = false,
        TimedActivityProgressAlert = false,
        TimedActivityProgressScope = "all",
        TimedActivityProgressFrequency = "complete",
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
        LorebookCollectionPrefix = GetString(LUIE_STRING_CA_LOREBOOK_COLLECTION_PREFIX),
        LorebookPrefix1 = GetString(LUIE_STRING_CA_LOREBOOK_PREFIX1),
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
        AntiquitySuffix = GetString(LUIE_STRING_CA_ANTIQUITY_SUFFIX),
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
        QuestCounterFilterEnable = true,
        QuestCounterFilterKeys = {},
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
        SkillPointSkyshard = GetString(LUIE_STRING_CA_SKILL_POINT_SKYSHARD),
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
        CurrencyCrownsChange = false,
        CurrencyCrownsColor = { 1, 1, 1, 1 },
        CurrencyCrownsName = GetString(LUIE_STRING_CA_CURRENCY_CROWN),
        CurrencyCrownsShowTotal = false,
        CurrencyCrownGemsChange = false,
        CurrencyCrownGemsColor = { 244 / 255, 56 / 255, 247 / 255, 1 },
        CurrencyCrownGemsName = GetString(LUIE_STRING_CA_CURRENCY_CROWN_GEM),
        CurrencyCrownGemsShowTotal = false,
        CurrencySealsChange = true,
        CurrencySealsColor = { 1, 1, 1, 1 },
        CurrencySealsName = GetString(LUIE_STRING_CA_CURRENCY_SEALS),
        CurrencySealsShowTotal = false,
        CurrencyTradeBarsChange = true,
        CurrencyTradeBarsColor = { 1, 1, 1, 1 },
        CurrencyTradeBarsName = GetString(LUIE_STRING_CA_CURRENCY_TRADE_BARS),
        CurrencyTradeBarsShowTotal = false,
        CurrencyTomePointsChange = true,
        CurrencyTomePointsColor = { 1, 1, 1, 1 },
        CurrencyTomePointsName = GetString(LUIE_STRING_CA_CURRENCY_TOME_POINTS),
        CurrencyTomePointsShowTotal = false,
        CurrencyTomePointCachesChange = true,
        CurrencyTomePointCachesColor = { 1, 1, 1, 1 },
        CurrencyTomePointCachesName = GetString(LUIE_STRING_CA_CURRENCY_TOME_POINT_CACHES),
        CurrencyTomePointCachesShowTotal = false,
        CurrencyTomeTokensChange = true,
        CurrencyTomeTokensColor = { 1, 1, 1, 1 },
        CurrencyTomeTokensName = GetString(LUIE_STRING_CA_CURRENCY_TOME_TOKENS),
        CurrencyTomeTokensShowTotal = false,
        CurrencyTomeChallengeRerollsChange = true,
        CurrencyTomeChallengeRerollsColor = { 1, 1, 1, 1 },
        CurrencyTomeChallengeRerollsName = GetString(LUIE_STRING_CA_CURRENCY_TOME_CHALLENGE_REROLLS),
        CurrencyTomeChallengeRerollsShowTotal = false,
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
        CurrencyEndlessShowTotal = false,
        CurrencyMessageTotalAP = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALAP),
        CurrencyMessageTotalGold = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALGOLD),
        CurrencyMessageTotalTV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTV),
        CurrencyMessageTotalWV = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALWV),
        CurrencyMessageTotalTransmute = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTRANSMUTE),
        CurrencyMessageTotalCrowns = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALCROWNS),
        CurrencyMessageTotalCrownGems = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALGEMS),
        CurrencyMessageTotalSeals = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALSEALS),
        CurrencyMessageTotalTradeBars = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTRADEBARS),
        CurrencyMessageTotalTomePoints = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTOMEPOINTS),
        CurrencyMessageTotalTomePointCaches = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTOMEPOINTCACHES),
        CurrencyMessageTotalTomeTokens = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTOMETOKENS),
        CurrencyMessageTotalTomeChallengeRerolls = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTOMECHALLENGEREROLLS),
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
        LootShowCollectionStatus = false,
        LootMail = true,
        LootNotTrash = true,
        LootOnlyNotable = false,
        LootShowArmorType = false,
        LootShowStyle = false,
        LootShowTrait = false,
        LootShowItemType = false,
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
        AttunableStationCA = false,
        AttunableStationCSA = true,
        AttunableStationAlert = false,
    },

    ContextMessages =
    {
        CurrencyMessageConfiscate = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_CONFISCATE),
        CurrencyMessageDeposit = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSIT),
        CurrencyMessageDepositStorage = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSITSTORAGE),
        CurrencyMessageDepositFurnitureVault = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSIT_FURNITURE_VAULT),
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
        CurrencyMessageWithdrawFurnitureVault = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAW_FURNITURE_VAULT),
        CurrencyMessageWithdrawGuild = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAWGUILD),
        CurrencyMessageStable = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_STABLE),
        CurrencyMessageStorage = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_STORAGE),
        CurrencyMessageWayshrine = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_WAYSHRINE),
        CurrencyMessageUnstuck = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_UNSTUCK),
        CurrencyMessageChampion = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_CHAMPION),
        CurrencyMessageAttributes = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_ATTRIBUTES),
        CurrencyMessageSkills = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_SKILLS),
        CurrencyMessageMorphs = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_MORPHS),
        CurrencyMessageSkillLine = GetString(LUIE_STRING_CA_CURRENCY_MESSAGE_SKILL_LINE),
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
        DungeonTrial =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarket =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarketBoulderDash =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarketArachnid =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarketGuidingLight =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarketRewards =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarketScavengingMaw =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarketZoneHunt =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarketEssence =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
        ZoneNightMarketMisc =
        {
            CA = false,
            CSA = true,
            Alert = false,
        },
    },
}

--- Maps ChatAnnouncements.SV.ContextMessages keys to LUIE_STRING_CA_* ids (runtime resolution via _MessageFormatResolver.lua).
--- @type CAContextMessageDefaultStringIds
ChatAnnouncements.ContextMessageDefaultStringIds =
{
    CurrencyMessageConfiscate = LUIE_STRING_CA_CURRENCY_MESSAGE_CONFISCATE,
    CurrencyMessageDeposit = LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSIT,
    CurrencyMessageDepositStorage = LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSITSTORAGE,
    CurrencyMessageDepositFurnitureVault = LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSIT_FURNITURE_VAULT,
    CurrencyMessageDepositGuild = LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSITGUILD,
    CurrencyMessageEarn = LUIE_STRING_CA_CURRENCY_MESSAGE_EARN,
    CurrencyMessageLoot = LUIE_STRING_CA_CURRENCY_MESSAGE_LOOT,
    CurrencyMessageContainer = LUIE_STRING_CA_CURRENCY_MESSAGE_CONTAINER,
    CurrencyMessageSteal = LUIE_STRING_CA_CURRENCY_MESSAGE_STEAL,
    CurrencyMessageLost = LUIE_STRING_CA_CURRENCY_MESSAGE_LOST,
    CurrencyMessagePickpocket = LUIE_STRING_CA_CURRENCY_MESSAGE_PICKPOCKET,
    CurrencyMessageReceive = LUIE_STRING_CA_CURRENCY_MESSAGE_RECEIVE,
    CurrencyMessageSpend = LUIE_STRING_CA_CURRENCY_MESSAGE_SPEND,
    CurrencyMessagePay = LUIE_STRING_CA_CURRENCY_MESSAGE_PAY,
    CurrencyMessageUseKit = LUIE_STRING_CA_CURRENCY_MESSAGE_USEKIT,
    CurrencyMessagePotion = LUIE_STRING_CA_CURRENCY_MESSAGE_POTION,
    CurrencyMessageFood = LUIE_STRING_CA_CURRENCY_MESSAGE_EAT,
    CurrencyMessageDrink = LUIE_STRING_CA_CURRENCY_MESSAGE_DRINK,
    CurrencyMessageDeploy = LUIE_STRING_CA_CURRENCY_MESSAGE_DEPLOY,
    CurrencyMessageStow = LUIE_STRING_CA_CURRENCY_MESSAGE_STOW,
    CurrencyMessageFillet = LUIE_STRING_CA_CURRENCY_MESSAGE_FILLET,
    CurrencyMessageLearnRecipe = LUIE_STRING_CA_CURRENCY_MESSAGE_LEARN_RECIPE,
    CurrencyMessageLearnMotif = LUIE_STRING_CA_CURRENCY_MESSAGE_LEARN_MOTIF,
    CurrencyMessageLearnStyle = LUIE_STRING_CA_CURRENCY_MESSAGE_LEARN_STYLE,
    CurrencyMessageExcavate = LUIE_STRING_CA_CURRENCY_MESSAGE_EXCAVATE,
    CurrencyMessageTradeIn = LUIE_STRING_CA_CURRENCY_MESSAGE_TRADEIN,
    CurrencyMessageTradeInNoName = LUIE_STRING_CA_CURRENCY_MESSAGE_TRADEIN_NO_NAME,
    CurrencyMessageTradeOut = LUIE_STRING_CA_CURRENCY_MESSAGE_TRADEOUT,
    CurrencyMessageTradeOutNoName = LUIE_STRING_CA_CURRENCY_MESSAGE_TRADEOUT_NO_NAME,
    CurrencyMessageMailIn = LUIE_STRING_CA_CURRENCY_MESSAGE_MAILIN,
    CurrencyMessageMailInNoName = LUIE_STRING_CA_CURRENCY_MESSAGE_MAILIN_NO_NAME,
    CurrencyMessageMailOut = LUIE_STRING_CA_CURRENCY_MESSAGE_MAILOUT,
    CurrencyMessageMailOutNoName = LUIE_STRING_CA_CURRENCY_MESSAGE_MAILOUT_NO_NAME,
    CurrencyMessageMailCOD = LUIE_STRING_CA_CURRENCY_MESSAGE_MAILCOD,
    CurrencyMessagePostage = LUIE_STRING_CA_CURRENCY_MESSAGE_POSTAGE,
    CurrencyMessageWithdraw = LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAW,
    CurrencyMessageWithdrawStorage = LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAWSTORAGE,
    CurrencyMessageWithdrawFurnitureVault = LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAW_FURNITURE_VAULT,
    CurrencyMessageWithdrawGuild = LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAWGUILD,
    CurrencyMessageStable = LUIE_STRING_CA_CURRENCY_MESSAGE_STABLE,
    CurrencyMessageStorage = LUIE_STRING_CA_CURRENCY_MESSAGE_STORAGE,
    CurrencyMessageWayshrine = LUIE_STRING_CA_CURRENCY_MESSAGE_WAYSHRINE,
    CurrencyMessageUnstuck = LUIE_STRING_CA_CURRENCY_MESSAGE_UNSTUCK,
    CurrencyMessageChampion = LUIE_STRING_CA_CURRENCY_MESSAGE_CHAMPION,
    CurrencyMessageAttributes = LUIE_STRING_CA_CURRENCY_MESSAGE_ATTRIBUTES,
    CurrencyMessageSkills = LUIE_STRING_CA_CURRENCY_MESSAGE_SKILLS,
    CurrencyMessageMorphs = LUIE_STRING_CA_CURRENCY_MESSAGE_MORPHS,
    CurrencyMessageSkillLine = LUIE_STRING_CA_CURRENCY_MESSAGE_SKILL_LINE,
    CurrencyMessageBounty = LUIE_STRING_CA_CURRENCY_MESSAGE_BOUNTY,
    CurrencyMessageTrader = LUIE_STRING_CA_CURRENCY_MESSAGE_TRADER,
    CurrencyMessageRepair = LUIE_STRING_CA_CURRENCY_MESSAGE_REPAIR,
    CurrencyMessageListing = LUIE_STRING_CA_CURRENCY_MESSAGE_LISTING,
    CurrencyMessageListingValue = LUIE_STRING_CA_CURRENCY_MESSAGE_LISTING_VALUE,
    CurrencyMessageList = LUIE_STRING_CA_CURRENCY_MESSAGE_LIST,
    CurrencyMessageCampaign = LUIE_STRING_CA_CURRENCY_MESSAGE_CAMPAIGN,
    CurrencyMessageFence = LUIE_STRING_CA_CURRENCY_MESSAGE_FENCE_VALUE,
    CurrencyMessageFenceNoV = LUIE_STRING_CA_CURRENCY_MESSAGE_FENCE,
    CurrencyMessageSellNoV = LUIE_STRING_CA_CURRENCY_MESSAGE_SELL,
    CurrencyMessageBuyNoV = LUIE_STRING_CA_CURRENCY_MESSAGE_BUY,
    CurrencyMessageBuybackNoV = LUIE_STRING_CA_CURRENCY_MESSAGE_BUYBACK,
    CurrencyMessageSell = LUIE_STRING_CA_CURRENCY_MESSAGE_SELL_VALUE,
    CurrencyMessageBuy = LUIE_STRING_CA_CURRENCY_MESSAGE_BUY_VALUE,
    CurrencyMessageBuyback = LUIE_STRING_CA_CURRENCY_MESSAGE_BUYBACK_VALUE,
    CurrencyMessageLaunder = LUIE_STRING_CA_CURRENCY_MESSAGE_LAUNDER_VALUE,
    CurrencyMessageLaunderNoV = LUIE_STRING_CA_CURRENCY_MESSAGE_LAUNDER,
    CurrencyMessageUse = LUIE_STRING_CA_CURRENCY_MESSAGE_USE,
    CurrencyMessageCraft = LUIE_STRING_CA_CURRENCY_MESSAGE_CRAFT,
    CurrencyMessageExtract = LUIE_STRING_CA_CURRENCY_MESSAGE_EXTRACT,
    CurrencyMessageUpgrade = LUIE_STRING_CA_CURRENCY_MESSAGE_UPGRADE,
    CurrencyMessageUpgradeFail = LUIE_STRING_CA_CURRENCY_MESSAGE_UPGRADE_FAIL,
    CurrencyMessageRefine = LUIE_STRING_CA_CURRENCY_MESSAGE_REFINE,
    CurrencyMessageDeconstruct = LUIE_STRING_CA_CURRENCY_MESSAGE_DECONSTRUCT,
    CurrencyMessageResearch = LUIE_STRING_CA_CURRENCY_MESSAGE_RESEARCH,
    CurrencyMessageDestroy = LUIE_STRING_CA_CURRENCY_MESSAGE_DESTROY,
    CurrencyMessageLockpick = LUIE_STRING_CA_CURRENCY_MESSAGE_LOCKPICK,
    CurrencyMessageRemove = LUIE_STRING_CA_CURRENCY_MESSAGE_REMOVE,
    CurrencyMessageQuestTurnIn = LUIE_STRING_CA_CURRENCY_MESSAGE_TURNIN,
    CurrencyMessageQuestUse = LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTUSE,
    CurrencyMessageQuestExhaust = LUIE_STRING_CA_CURRENCY_MESSAGE_EXHAUST,
    CurrencyMessageQuestOffer = LUIE_STRING_CA_CURRENCY_MESSAGE_OFFER,
    CurrencyMessageQuestDiscard = LUIE_STRING_CA_CURRENCY_MESSAGE_DISCARD,
    CurrencyMessageQuestConfiscate = LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTCONFISCATE,
    CurrencyMessageQuestOpen = LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTOPEN,
    CurrencyMessageQuestAdminister = LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTADMINISTER,
    CurrencyMessageQuestPlace = LUIE_STRING_CA_CURRENCY_MESSAGE_QUESTPLACE,
    CurrencyMessageQuestCombine = LUIE_STRING_CA_CURRENCY_MESSAGE_COMBINE,
    CurrencyMessageQuestMix = LUIE_STRING_CA_CURRENCY_MESSAGE_MIX,
    CurrencyMessageQuestBundle = LUIE_STRING_CA_CURRENCY_MESSAGE_BUNDLE,
    CurrencyMessageGroup = LUIE_STRING_CA_CURRENCY_MESSAGE_GROUP,
    CurrencyMessageDisguiseEquip = LUIE_STRING_CA_CURRENCY_MESSAGE_DISGUISE_EQUIP,
    CurrencyMessageDisguiseRemove = LUIE_STRING_CA_CURRENCY_MESSAGE_DISGUISE_REMOVE,
    CurrencyMessageDisguiseDestroy = LUIE_STRING_CA_CURRENCY_MESSAGE_DISGUISE_DESTROY,
}

--- Pre–guild-name context strings still present in saved vars (treat as default, not custom).
--- @type table<integer|string, string[]>
ChatAnnouncements.ContextMessageLegacyFormatByStringId =
{
    [LUIE_STRING_CA_CURRENCY_MESSAGE_DEPOSITGUILD] =
    {
        "You deposit %s in the guild bank.",
        "Du hinterlegst %s in der Gildenbank.",
        "Vous avez déposé %s dans la banque de guilde.",
        "Вы вложили %s в гильдейский банк.",
        "您在公会银行存入 %s。",
    },
    [LUIE_STRING_CA_CURRENCY_MESSAGE_WITHDRAWGUILD] =
    {
        "You withdraw %s from the guild bank.",
        "Du holst %s aus der Gildenbank.",
        "Vous récupérez %s de votre banque de guilde.",
        "Вы изъяли %s из гильдейского банка.",
        "您从公会银行取出 %s。",
    },
}
