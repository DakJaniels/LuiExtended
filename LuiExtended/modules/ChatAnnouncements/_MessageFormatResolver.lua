-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- ChatAnnouncements user-editable format strings (ContextMessages, currency totals, loot total, XP/Skills/etc.).
--- Saved vars keep English default.lua text when the player has not customized; runtime resolves via GetString.
--- Custom text in SV is preserved across client languages.

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local LOOT_TOTAL_STRING_ID = LUIE_STRING_CA_LOOT_MESSAGE_TOTAL

--- @type table<string, integer|string>
ChatAnnouncements.CurrencyMessageFormatStringIds =
{
    CurrencyMessageTotalAP = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALAP,
    CurrencyMessageTotalGold = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALGOLD,
    CurrencyMessageTotalTV = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTV,
    CurrencyMessageTotalWV = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALWV,
    CurrencyMessageTotalTransmute = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTRANSMUTE,
    CurrencyMessageTotalCrowns = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALCROWNS,
    CurrencyMessageTotalCrownGems = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALGEMS,
    CurrencyMessageTotalSeals = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALSEALS,
    CurrencyMessageTotalTradeBars = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTRADEBARS,
    CurrencyMessageTotalTomePoints = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTOMEPOINTS,
    CurrencyMessageTotalTomePointCaches = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTOMEPOINTCACHES,
    CurrencyMessageTotalTomeTokens = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTOMETOKENS,
    CurrencyMessageTotalTomeChallengeRerolls = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALTOMECHALLENGEREROLLS,
    CurrencyMessageTotalOutfitToken = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALOUTFITTOKENS,
    CurrencyMessageTotalUndaunted = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALUNDAUNTED,
    CurrencyMessageTotalEndless = LUIE_STRING_CA_CURRENCY_MESSAGE_TOTALENDLESS,
}

--- Maps ChatAnnouncements.SV.Currency *Name keys to LUIE_STRING_CA_CURRENCY_* plural format ids.
--- @type table<string, integer|string>
ChatAnnouncements.CurrencyDisplayNameStringIds =
{
    CurrencyGoldName = LUIE_STRING_CA_CURRENCY_GOLD,
    CurrencyAPName = LUIE_STRING_CA_CURRENCY_ALLIANCE_POINT,
    CurrencyTVName = LUIE_STRING_CA_CURRENCY_TELVAR_STONE,
    CurrencyWVName = LUIE_STRING_CA_CURRENCY_WRIT_VOUCHER,
    CurrencyTransmuteName = LUIE_STRING_CA_CURRENCY_TRANSMUTE_CRYSTAL,
    CurrencyCrownsName = LUIE_STRING_CA_CURRENCY_CROWN,
    CurrencyCrownGemsName = LUIE_STRING_CA_CURRENCY_CROWN_GEM,
    CurrencySealsName = LUIE_STRING_CA_CURRENCY_SEALS,
    CurrencyTradeBarsName = LUIE_STRING_CA_CURRENCY_TRADE_BARS,
    CurrencyTomePointsName = LUIE_STRING_CA_CURRENCY_TOME_POINTS,
    CurrencyTomePointCachesName = LUIE_STRING_CA_CURRENCY_TOME_POINT_CACHES,
    CurrencyTomeTokensName = LUIE_STRING_CA_CURRENCY_TOME_TOKENS,
    CurrencyTomeChallengeRerollsName = LUIE_STRING_CA_CURRENCY_TOME_CHALLENGE_REROLLS,
    CurrencyOutfitTokenName = LUIE_STRING_CA_CURRENCY_OUTFIT_TOKENS,
    CurrencyUndauntedName = LUIE_STRING_CA_CURRENCY_UNDAUNTED,
    CurrencyEndlessName = LUIE_STRING_CA_CURRENCY_ENDLESS,
}

--- Nested SV sections (XP, Skills, …) with LUIE_STRING_CA_* format fields.
--- @type table<string, table<string, integer|string>>
ChatAnnouncements.ModuleMessageFormatStringIds =
{
    XP =
    {
        ExperienceMessage = LUIE_STRING_CA_EXPERIENCE_MESSAGE,
        ExperienceName = LUIE_STRING_CA_EXPERIENCE_NAME,
    },
    Skills =
    {
        SkillGuildMsg = LUIE_STRING_CA_SKILL_GUILD_MSG,
        SkillGuildRepName = LUIE_STRING_CA_SKILL_GUILD_REPUTATION,
        SkillPointSkyshard = LUIE_STRING_CA_SKILL_POINT_SKYSHARD,
    },
    Achievement =
    {
        AchievementProgressMsg = LUIE_STRING_CA_ACHIEVEMENT_PROGRESS_MSG,
        AchievementCompleteMsg = LUIE_STRING_CA_ACHIEVEMENT_COMPLETE_MSG,
    },
    Collectibles =
    {
        CollectiblePrefix = LUIE_STRING_CA_COLLECTIBLE,
    },
    Lorebooks =
    {
        LorebookPrefix1 = LUIE_STRING_CA_LOREBOOK_PREFIX1,
        LorebookPrefix2 = LUIE_STRING_CA_LOREBOOK_BOOK,
        LorebookCollectionPrefix = LUIE_STRING_CA_LOREBOOK_COLLECTION_PREFIX,
    },
    Antiquities =
    {
        AntiquityPrefix = LUIE_STRING_CA_ANTIQUITY_PREFIX,
        AntiquitySuffix = LUIE_STRING_CA_ANTIQUITY_SUFFIX,
    },
}

--- Pre-LUIE_STRING defaults that used game SI_* strings (still treated as non-customized SV).
--- @type table<string, table<string, integer>>
ChatAnnouncements.ModuleMessageFormatLegacySiStringIds =
{
    Achievement = { AchievementCompleteMsg = SI_ACHIEVEMENT_AWARDED_CENTER_SCREEN },
    Lorebooks =
    {
        LorebookPrefix1 = SI_LORE_LIBRARY_ANNOUNCE_BOOK_LEARNED,
        LorebookCollectionPrefix = SI_LORE_LIBRARY_COLLECTION_COMPLETED_LARGE,
    },
    Skills = { SkillPointSkyshard = SI_SKYSHARD_GAINED },
}

--- @param stored string|nil
--- @param stringId integer|string
--- @return boolean
local function isLegacyContextFormat(stored, stringId)
    if not stored or stored == "" then
        return false
    end
    local legacyByStringId = ChatAnnouncements.ContextMessageLegacyFormatByStringId
    if not legacyByStringId then
        return false
    end
    local legacyList = legacyByStringId[stringId]
    if not legacyList then
        return false
    end
    for _, legacy in ipairs(legacyList) do
        if stored == legacy then
            return true
        end
    end
    return false
end

--- @param stored string|nil
--- @param stringId integer|string
--- @return boolean
local function isDefaultStoredFormat(stored, stringId)
    if stored == nil or stored == "" then
        return true
    end
    local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
    if canonicalEnglish and stored == canonicalEnglish then
        return true
    end
    -- Legacy: localized default was written into SV (migration / old Defaults using GetString).
    local localized = GetString(stringId)
    if localized and stored == localized then
        return true
    end
    if isLegacyContextFormat(stored, stringId) then
        return true
    end
    return false
end

--- @param sectionDefaults table|nil
--- @param fieldKey string
--- @param stringId integer|string
local function applyCanonicalDefaultToSectionField(sectionDefaults, fieldKey, stringId)
    if not sectionDefaults then
        return
    end
    local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
    if canonicalEnglish ~= nil then
        sectionDefaults[fieldKey] = canonicalEnglish
    end
end

--- @param stored string|nil
--- @param stringId integer|string
--- @param legacySiStringId integer|nil
--- @return boolean
local function isDefaultStoredModuleFormat(stored, stringId, legacySiStringId)
    if isDefaultStoredFormat(stored, stringId) then
        return true
    end
    if legacySiStringId and stored and stored == GetString(legacySiStringId) then
        return true
    end
    return false
end

--- @param svSection table|nil
--- @param fieldKey string
--- @param stringId integer|string
--- @param legacySiStringId integer|nil
local function normalizeSectionFormatField(svSection, fieldKey, stringId, legacySiStringId)
    if not svSection then
        return
    end
    local stored = svSection[fieldKey]
    local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
    if  canonicalEnglish ~= nil
    and isDefaultStoredModuleFormat(stored, stringId, legacySiStringId)
    and stored ~= canonicalEnglish then
        svSection[fieldKey] = canonicalEnglish
    end
end

--- @param stored string|nil
--- @param stringId integer|string
--- @return string
local function resolveStoredFormat(stored, stringId)
    if isDefaultStoredFormat(stored, stringId) then
        return GetString(stringId)
    end
    return stored or GetString(stringId)
end

--- Sets ChatAnnouncements.Defaults template fields to English canonical (ZO_SavedVars merge sentinel).
function ChatAnnouncements.RefreshMessageFormatDefaultsTable()
    local defaults = ChatAnnouncements.Defaults
    if not defaults then
        return
    end

    local contextIds = ChatAnnouncements.ContextMessageDefaultStringIds
    if contextIds and defaults.ContextMessages then
        for key, stringId in pairs(contextIds) do
            local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
            if canonicalEnglish then
                defaults.ContextMessages[key] = canonicalEnglish
            end
        end
    end

    local currencyIds = ChatAnnouncements.CurrencyMessageFormatStringIds
    if currencyIds and defaults.Currency then
        for key, stringId in pairs(currencyIds) do
            local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
            if canonicalEnglish then
                defaults.Currency[key] = canonicalEnglish
            end
        end
    end

    local currencyNameIds = ChatAnnouncements.CurrencyDisplayNameStringIds
    if currencyNameIds and defaults.Currency then
        for key, stringId in pairs(currencyNameIds) do
            local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
            if canonicalEnglish then
                defaults.Currency[key] = canonicalEnglish
            end
        end
    end

    if defaults.Inventory then
        local canonicalLootTotal = LUIE_GetRegisteredDefaultString(LOOT_TOTAL_STRING_ID)
        if canonicalLootTotal then
            defaults.Inventory.LootTotalString = canonicalLootTotal
        end
    end

    local moduleIds = ChatAnnouncements.ModuleMessageFormatStringIds
    if moduleIds then
        for sectionKey, fieldMap in pairs(moduleIds) do
            local sectionDefaults = defaults[sectionKey]
            for fieldKey, stringId in pairs(fieldMap) do
                applyCanonicalDefaultToSectionField(sectionDefaults, fieldKey, stringId)
            end
        end
    end
end

--- Rewrites legacy localized defaults in SV back to English canonical (not customized).
function ChatAnnouncements.NormalizeStoredMessageFormats()
    local sv = ChatAnnouncements.SV
    if not sv then
        return
    end

    local contextIds = ChatAnnouncements.ContextMessageDefaultStringIds
    if contextIds and sv.ContextMessages then
        for key, stringId in pairs(contextIds) do
            local stored = sv.ContextMessages[key]
            local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
            if canonicalEnglish and isDefaultStoredFormat(stored, stringId) and stored ~= canonicalEnglish then
                sv.ContextMessages[key] = canonicalEnglish
            elseif canonicalEnglish and isLegacyContextFormat(stored, stringId) then
                sv.ContextMessages[key] = canonicalEnglish
            end
        end
    end

    local currencyIds = ChatAnnouncements.CurrencyMessageFormatStringIds
    if currencyIds and sv.Currency then
        for key, stringId in pairs(currencyIds) do
            local stored = sv.Currency[key]
            local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
            if canonicalEnglish and isDefaultStoredFormat(stored, stringId) and stored ~= canonicalEnglish then
                sv.Currency[key] = canonicalEnglish
            end
        end
    end

    local currencyNameIds = ChatAnnouncements.CurrencyDisplayNameStringIds
    if currencyNameIds and sv.Currency then
        for key, stringId in pairs(currencyNameIds) do
            local stored = sv.Currency[key]
            local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
            if canonicalEnglish and isDefaultStoredFormat(stored, stringId) and stored ~= canonicalEnglish then
                sv.Currency[key] = canonicalEnglish
            end
        end
    end

    if sv.Inventory then
        local stored = sv.Inventory.LootTotalString
        local canonicalEnglish = LUIE_GetRegisteredDefaultString(LOOT_TOTAL_STRING_ID)
        if canonicalEnglish and isDefaultStoredFormat(stored, LOOT_TOTAL_STRING_ID) and stored ~= canonicalEnglish then
            sv.Inventory.LootTotalString = canonicalEnglish
        end
    end

    local moduleIds = ChatAnnouncements.ModuleMessageFormatStringIds
    local legacySiIds = ChatAnnouncements.ModuleMessageFormatLegacySiStringIds
    if moduleIds then
        for sectionKey, fieldMap in pairs(moduleIds) do
            local svSection = sv[sectionKey]
            local sectionLegacy = legacySiIds and legacySiIds[sectionKey]
            for fieldKey, stringId in pairs(fieldMap) do
                local legacySiStringId = sectionLegacy and sectionLegacy[fieldKey]
                normalizeSectionFormatField(svSection, fieldKey, stringId, legacySiStringId)
            end
        end
    end
end

--- @param contextMessageKey string
--- @return string
function ChatAnnouncements.GetContextMessage(contextMessageKey)
    local sv = ChatAnnouncements.SV
    if not sv or not sv.ContextMessages then
        return ""
    end
    local stringId = ChatAnnouncements.ContextMessageDefaultStringIds
        and ChatAnnouncements.ContextMessageDefaultStringIds[contextMessageKey]
    if not stringId then
        return sv.ContextMessages[contextMessageKey] or ""
    end
    return resolveStoredFormat(sv.ContextMessages[contextMessageKey], stringId)
end

--- @param currencyMessageKey string
--- @return string
function ChatAnnouncements.GetCurrencyMessageFormat(currencyMessageKey)
    local sv = ChatAnnouncements.SV
    if not sv or not sv.Currency then
        return ""
    end
    local stringId = ChatAnnouncements.CurrencyMessageFormatStringIds
        and ChatAnnouncements.CurrencyMessageFormatStringIds[currencyMessageKey]
    if not stringId then
        return sv.Currency[currencyMessageKey] or ""
    end
    return resolveStoredFormat(sv.Currency[currencyMessageKey], stringId)
end

--- @param currencyNameKey string
--- @return string
function ChatAnnouncements.GetCurrencyDisplayNameFormat(currencyNameKey)
    local sv = ChatAnnouncements.SV
    if not sv or not sv.Currency then
        return ""
    end
    local stringId = ChatAnnouncements.CurrencyDisplayNameStringIds
        and ChatAnnouncements.CurrencyDisplayNameStringIds[currencyNameKey]
    if not stringId then
        return sv.Currency[currencyNameKey] or ""
    end
    return resolveStoredFormat(sv.Currency[currencyNameKey], stringId)
end

--- @param sectionKey string
--- @param fieldKey string
--- @return string
function ChatAnnouncements.GetModuleMessageFormat(sectionKey, fieldKey)
    local sv = ChatAnnouncements.SV
    if not sv or not sv[sectionKey] then
        return ""
    end
    local fieldMap = ChatAnnouncements.ModuleMessageFormatStringIds
        and ChatAnnouncements.ModuleMessageFormatStringIds[sectionKey]
    local stringId = fieldMap and fieldMap[fieldKey]
    if not stringId then
        return sv[sectionKey][fieldKey] or ""
    end
    local stored = sv[sectionKey][fieldKey]
    local legacySiStringId = ChatAnnouncements.ModuleMessageFormatLegacySiStringIds
        and ChatAnnouncements.ModuleMessageFormatLegacySiStringIds[sectionKey]
        and ChatAnnouncements.ModuleMessageFormatLegacySiStringIds[sectionKey][fieldKey]
    if isDefaultStoredModuleFormat(stored, stringId, legacySiStringId) then
        return GetString(stringId)
    end
    return stored or GetString(stringId)
end

--- @return string
function ChatAnnouncements.GetLootTotalString()
    local sv = ChatAnnouncements.SV
    if not sv or not sv.Inventory then
        return GetString(LOOT_TOTAL_STRING_ID)
    end
    return resolveStoredFormat(sv.Inventory.LootTotalString, LOOT_TOTAL_STRING_ID)
end

--- @param logPrefix string
--- @param contextMessageKey string
--- @return boolean
function ChatAnnouncements.ContextMessageMatches(logPrefix, contextMessageKey)
    if not logPrefix or logPrefix == "" then
        return false
    end
    if logPrefix == ChatAnnouncements.GetContextMessage(contextMessageKey) then
        return true
    end
    local sv = ChatAnnouncements.SV
    if sv and sv.ContextMessages and logPrefix == sv.ContextMessages[contextMessageKey] then
        return true
    end
    local stringId = ChatAnnouncements.ContextMessageDefaultStringIds
        and ChatAnnouncements.ContextMessageDefaultStringIds[contextMessageKey]
    if stringId then
        local canonicalEnglish = LUIE_GetRegisteredDefaultString(stringId)
        if canonicalEnglish and logPrefix == canonicalEnglish then
            return true
        end
        if isLegacyContextFormat(logPrefix, stringId) then
            return true
        end
    end
    return false
end

--- @param logPrefix string
--- @return string
function ChatAnnouncements.ResolveLogPrefix(logPrefix)
    if not logPrefix or logPrefix == "" then
        return logPrefix
    end
    local stringIds = ChatAnnouncements.ContextMessageDefaultStringIds
    if not stringIds then
        return logPrefix
    end
    for key in pairs(stringIds) do
        if ChatAnnouncements.ContextMessageMatches(logPrefix, key) then
            return ChatAnnouncements.GetContextMessage(key)
        end
    end
    return logPrefix
end

local string_format_resolver = string.format

--- @param guildId integer|nil
--- @return string
function ChatAnnouncements.FormatGuildLabelForChat(guildId)
    if not guildId or guildId == 0 then
        return ""
    end
    local guildName = GetGuildName(guildId)
    if not guildName or guildName == "" then
        return ""
    end
    local social = ChatAnnouncements.SV and ChatAnnouncements.SV.Social
    local guildAlliance = GetGuildAlliance(guildId)
    local ColorizeColors = ChatAnnouncements.Colors
    local guildColor = social and social.GuildAllianceColor and GetAllianceColor(guildAlliance) or ColorizeColors.GuildColorize
    if social and social.GuildIcon then
        return guildColor:Colorize(zo_strformat("<<1>> <<2>>", zo_iconFormatInheritColor(ZO_GetAllianceSymbolIcon(guildAlliance), 16, 16), guildName))
    end
    return guildColor:Colorize(guildName)
end

--- @param guildId integer|nil
--- @return string
function ChatAnnouncements.FormatGuildLabelForAlert(guildId)
    if not guildId or guildId == 0 then
        return ""
    end
    local guildName = GetGuildName(guildId)
    if not guildName or guildName == "" then
        return ""
    end
    local social = ChatAnnouncements.SV and ChatAnnouncements.SV.Social
    local guildAlliance = GetGuildAlliance(guildId)
    if social and social.GuildIcon then
        return zo_iconTextFormat(ZO_GetAllianceSymbolIcon(guildAlliance), "100%", "100%", guildName)
    end
    return guildName
end

--- @param template string
--- @param formattedPrimary string
--- @param guildLabel string
--- @return string
function ChatAnnouncements.FormatGuildBankContextMessage(template, formattedPrimary, guildLabel)
    if not template or template == "" then
        return formattedPrimary or ""
    end
    local placeholderCount = 0
    for _ in template:gmatch("%%s") do
        placeholderCount = placeholderCount + 1
    end
    if placeholderCount >= 2 then
        return string_format_resolver(template, formattedPrimary, guildLabel or "")
    end
    if placeholderCount == 1 then
        return string_format_resolver(template, formattedPrimary)
    end
    return formattedPrimary or ""
end

ChatAnnouncements.RefreshMessageFormatDefaultsTable()
