-- -----------------------------------------------------------------------------
--  LuiExtended — dev-only localization coverage (not loaded in release builds)
-- -----------------------------------------------------------------------------
-- Enable in LuiExtended.addon immediately after lang/_RegisterStrings.lua:
--   lang/_LocalizationCoverage_Dev.lua
-- Optionally call LUIE_ScheduleLocalizationCoverageReport() from pc/console init when auditing.

local pairs = pairs
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local GetCVar = GetCVar

local LOG_PREFIX = "[LUIE Localization]"

--- @class LUIE_LocalizationModuleState
--- @field defaultStringIds table<string, boolean>
--- @field clientLocaleFileLoaded boolean

--- @type table<string, LUIE_LocalizationModuleState>
local localizationByModule = {}
local registeredDefaultStringIds = {}
local clientTranslatedDefaultStringIds = {}
local obsoleteTranslationStringIds = {}

local LOCALIZATION_MODULE_ORDER =
{
    "Core", "Shared", "ActionBar", "ChatAnnouncements", "CombatInfo", "CombatText",
    "InfoPanel", "SlashCommands", "SpellCastBuffs", "UnitFrames",
}

local registerStringsCore = LUIE_RegisterStrings

local function getOrCreateLocalizationModuleState(moduleName)
    local moduleState = localizationByModule[moduleName]
    if not moduleState then
        moduleState =
        {
            defaultStringIds = {},
            clientLocaleFileLoaded = false,
        }
        localizationByModule[moduleName] = moduleState
    end
    return moduleState
end

--- @param stringId string
--- @return string
local function getLocalizationModuleForStringId(stringId)
    if stringId:match("^SI_BINDING_NAME_LUIE_") then return "SlashCommands" end
    if stringId:match("^LUIE_STRING_ERROR_") or stringId:match("^LUIE_STRING_CONSOLE_") then return "Core" end
    if stringId:match("^LUIE_STRING_DEBUG_ENV_") then return "Core" end
    if stringId:match("^LUIE_STRING_SV_STATUS_") then return "Core" end
    if stringId:match("^LUIE_STRING_CORE_") then return "Core" end
    if stringId == "LUIE_STRING_LAM_PROFILE_COPY_ERROR" then return "Core" end
    if stringId:match("^LUIE_FONT_STYLE_") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_MISSING") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_FONT") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_COMPATIBILITY") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_RELOAD") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_RESETPOSITION") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_HIDE_EXPERIENCE") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_CHANGELOG") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_STARTUP") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_SVPROFILE") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_MODULE") then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_MISC") then return "Core" end
    if stringId == "LUIE_STRING_LAM_UF" or stringId == "LUIE_STRING_LAM_CA" or stringId == "LUIE_STRING_LAM_CI" then return "Core" end
    if stringId == "LUIE_STRING_LAM_SLASHCMDS" or stringId == "LUIE_STRING_LAM_AB" or stringId == "LUIE_STRING_LAM_BUFFSDEBUFFS" then return "Core" end
    if stringId:match("^LUIE_STRING_LAM_BUFFS_DESCRIPTION") or stringId:match("^LUIE_STRING_LAM_AB_DESCRIPTION") then return "Core" end
    if stringId == "LUIE_STRING_LAM_PNL" then return "Core" end
    if stringId:match("^LUIE_STRING_CUSTOM_LIST_") then return "Shared" end
    if stringId:match("^LUIE_STRING_DEFAULT_FRAME_") then return "Shared" end
    if stringId == "LUIE_STRING_DISMISS_PET" then return "Shared" end
    if stringId:match("^LUIE_STRING_SHARED_") then return "Shared" end
    if stringId:match("^LUIE_STRING_SLASHCMDS_") then return "SlashCommands" end
    if stringId:match("^LUIE_STRING_LAM_SLASHCMDS") then return "SlashCommands" end
    if stringId:match("^LUIE_STRING_LSC_") then return "SlashCommands" end
    if stringId:match("^LUIE_STRING_PNL_") then return "InfoPanel" end
    if stringId:match("^LUIE_STRING_LAM_PNL") then return "InfoPanel" end
    if stringId:match("^LUIE_STRING_SCB_") then return "SpellCastBuffs" end
    if stringId:match("^LUIE_STRING_BUFF_TYPE_") then return "SpellCastBuffs" end
    if stringId:match("^LUIE_STRING_BUFF_TOOLTIP_") then return "SpellCastBuffs" end
    if stringId:match("^LUIE_STRING_LAM_SCB_") then return "SpellCastBuffs" end
    if stringId:match("^LUIE_STRING_LAM_BUFF") then return "SpellCastBuffs" end
    if stringId:match("^LUIE_STRING_CA_") then return "ChatAnnouncements" end
    if stringId:match("^LUIE_STRING_LAM_CA") then return "ChatAnnouncements" end
    if stringId:match("^LUIE_STRING_LAM_AB") then return "ActionBar" end
    if stringId:match("^LUIE_STRING_CT_") then return "CombatText" end
    if stringId:match("^LUIE_STRING_LAM_CT") then return "CombatText" end
    if stringId:match("^LUIE_STRING_CI_") then return "CombatInfo" end
    if stringId:match("^LUIE_STRING_LAM_CI") then return "CombatInfo" end
    if stringId:match("^LUIE_STRING_LAM_ALERT") then return "CombatInfo" end
    if stringId:match("^LUIE_STRING_UF_") then return "UnitFrames" end
    if stringId:match("^LUIE_STRING_LAM_UF") then return "UnitFrames" end
    return "Core"
end

--- Dev-only wrapper; same signature as lang/_RegisterStrings.lua.
--- @param strings table<string, string>
--- @param isTranslation boolean|nil
function LUIE_RegisterStrings(strings, isTranslation)
    for stringId, _ in pairs(strings) do
        local moduleName = getLocalizationModuleForStringId(stringId)
        local moduleState = getOrCreateLocalizationModuleState(moduleName)

        if isTranslation then
            moduleState.clientLocaleFileLoaded = true
            if registeredDefaultStringIds[stringId] then
                clientTranslatedDefaultStringIds[stringId] = true
            end
            if _G[stringId] == nil and not registeredDefaultStringIds[stringId] then
                obsoleteTranslationStringIds[stringId] = moduleName
            end
        else
            registeredDefaultStringIds[stringId] = true
            moduleState.defaultStringIds[stringId] = true
        end
    end
    registerStringsCore(strings, isTranslation)
end

local function collectSortedStringIds(stringIdMap)
    local stringIds = {}
    for stringId in pairs(stringIdMap) do
        table_insert(stringIds, stringId)
    end
    table_sort(stringIds)
    return stringIds
end

--- Logs localization coverage to LibDebugLogger via LUIE:Log("Verbose", ...) when dev debug logging is enabled.
function LUIE_ReportLocalizationCoverage()
    if not LUIE or not LUIE.Log or not LUIE.show_log then
        return
    end

    local clientLanguage = GetCVar("Language.2") or "en"
    local totalDefault = 0
    for _ in pairs(registeredDefaultStringIds) do
        totalDefault = totalDefault + 1
    end

    LUIE:Log("Verbose", string_format("%s Coverage report (client Language.2=%s)", LOG_PREFIX, clientLanguage))
    LUIE:Log("Verbose", string_format("%s Default string ids registered: %d", LOG_PREFIX, totalDefault))

    local totalMissing = 0
    local modulesWithTranslationFile = 0

    for moduleIndex = 1, #LOCALIZATION_MODULE_ORDER do
        local moduleName = LOCALIZATION_MODULE_ORDER[moduleIndex]
        local moduleState = localizationByModule[moduleName]
        if moduleState then
            local defaultCount = 0
            for _ in pairs(moduleState.defaultStringIds) do
                defaultCount = defaultCount + 1
            end
            if defaultCount > 0 and moduleState.clientLocaleFileLoaded then
                modulesWithTranslationFile = modulesWithTranslationFile + 1
                local missingStringIds = {}
                local translatedCount = 0
                for stringId in pairs(moduleState.defaultStringIds) do
                    if clientTranslatedDefaultStringIds[stringId] then
                        translatedCount = translatedCount + 1
                    else
                        table_insert(missingStringIds, stringId)
                    end
                end
                table_sort(missingStringIds)

                LUIE:Log("Verbose", string_format("%s Module %s: %d of %d string ids translated", LOG_PREFIX, moduleName, translatedCount, defaultCount))

                if #missingStringIds == 0 then
                    LUIE:Log("Verbose", string_format("%s Module %s: complete", LOG_PREFIX, moduleName))
                else
                    totalMissing = totalMissing + #missingStringIds
                    LUIE:Log("Verbose", string_format("%s Module %s: %d missing translation(s)", LOG_PREFIX, moduleName, #missingStringIds))
                    for missingIndex = 1, #missingStringIds do
                        LUIE:Log("Verbose", string_format("%s Missing string id: %s", LOG_PREFIX, missingStringIds[missingIndex]))
                    end
                end
            end
        end
    end

    local obsoleteStringIds = collectSortedStringIds(obsoleteTranslationStringIds)
    if #obsoleteStringIds > 0 then
        LUIE:Log("Verbose", string_format("%s %d obsolete locale key(s) (no default.lua entry; safe to remove or rename in locale files)", LOG_PREFIX, #obsoleteStringIds))
        for index = 1, #obsoleteStringIds do
            LUIE:Log("Verbose", string_format("%s Obsolete locale key: %s", LOG_PREFIX, obsoleteStringIds[index]))
        end
    end

    LUIE:Log("Verbose", string_format("%s Summary: %d module translation file(s), %d missing string id(s)", LOG_PREFIX, modulesWithTranslationFile, totalMissing))
end

--- Runs coverage after addon init so the report does not interleave with early LibDebugLogger startup lines.
function LUIE_ScheduleLocalizationCoverageReport()
    if not LUIE or not LUIE.show_log then
        return
    end
    zo_callLater(LUIE_ReportLocalizationCoverage, 0)
end
