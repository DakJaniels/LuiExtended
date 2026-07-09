-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local GetAchievementCategoryInfo = GetAchievementCategoryInfo
local GetCollectibleCategoryInfo = GetCollectibleCategoryInfo
local GetNumAchievementCategories = GetNumAchievementCategories
local GetString = GetString
local ReloadUI = ReloadUI
local zo_strformat = zo_strformat
local table = table
local table_insert = table.insert
local unpack = unpack


---
--- @param topLevelIndex integer
--- @return string name
local function GetCollectibleCategoryInfoName(topLevelIndex)
    local CollectibleCategoryInfo = { GetCollectibleCategoryInfo(topLevelIndex) }
    local name = CollectibleCategoryInfo[1]
    return name
end

---
--- @param topLevelIndex integer
--- @return string name
local function GetAchievementCategoryInfoName(topLevelIndex)
    local AchievementCategoryInfo = { GetAchievementCategoryInfo(topLevelIndex) }
    local name = AchievementCategoryInfo[1]
    return name
end

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

function ChatAnnouncements.CreateConsoleSettings()
    local Defaults = ChatAnnouncements.Defaults
    local Settings = ChatAnnouncements.SV

    ChatAnnouncements.RegisterQuestCounterFilterDialogs()
    ChatAnnouncements.RegisterQuestCounterFilterClearDialog()

    -- Register the settings panel
    if not LUIE.SV.ChatAnnouncements_Enable then
        return
    end

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_CA),
                                {
                                    allowDefaults = true
                                })

    -- Collect initial settings for main menu
    local initialSettings = {}

    -- Chat Announcements Module Description
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_CA_DESCRIPTION)
    }

    -- ReloadUI Button
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        clickHandler = function ()
            SettingsAPI:ReloadUIWithPendingClear()
        end
    }

    local sectionGroups = {}

    -- Helper function to build section settings
    local function buildSectionSettings(sectionName, settingsBuilder)
        local sectionSettings = {}
        settingsBuilder(sectionSettings)
        sectionGroups[sectionName] = sectionSettings
    end

    -- Build Chat Message Settings Section
    buildSectionSettings("ChatMessage", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_CHATHEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_CHAT),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_NAMEDISPLAYMETHOD),
            tooltip = GetString(LUIE_STRING_LAM_CA_NAMEDISPLAYMETHOD_TP),
            items = SettingsAPI:GetChatNameDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeChatNameDisplayIndex(Settings.ChatPlayerDisplayOptions, Defaults.ChatPlayerDisplayOptions))
            end,
            setFunction = function (combobox, value, item)
                Settings.ChatPlayerDisplayOptions = item.data
                ChatAnnouncements.IndexGroupLoot()
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.ChatPlayerDisplayOptions),
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_CHARACTER),
            tooltip = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_CHARACTER_TP),
            items = SettingsAPI:GetLinkBracketDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeLinkBracketDisplayIndex(Settings.BracketOptionCharacter, 1))
            end,
            setFunction = function (combobox, value, item)
                Settings.BracketOptionCharacter = item.data
                ChatAnnouncements.IndexGroupLoot()
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BracketOptionCharacter),
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_CONSOLE_OPEN_CHATOUTPUT_SETTINGS),
            tooltip = GetString(LUIE_STRING_CONSOLE_OPEN_CHATOUTPUT_SETTINGS_TP),
            buttonText = GetString(LUIE_STRING_CONSOLE_OPEN_CHATOUTPUT_SETTINGS),
            clickHandler = function ()
                SettingsAPI:OpenConsoleChatOutputSettings()
            end,
        }
    end)

    -- Build Currency Announcements Section
    buildSectionSettings("Currency", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_CURRENCY),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWICONS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWICONS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyIcon
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyIcon = value
            end,
            default = Defaults.Currency.CurrencyIcon,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        -- Gold
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLD),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLD_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyGoldChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyGoldChange = value
                ChatAnnouncements.RegisterGoldEvents()
            end,
            default = Defaults.Currency.CurrencyGoldChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyGoldColor[1], Settings.Currency.CurrencyGoldColor[2], Settings.Currency.CurrencyGoldColor[3], Settings.Currency.CurrencyGoldColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyGoldColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyGoldColor,
            disable = function ()
                return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyGoldName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyGoldName = value
            end,
            default = Defaults.Currency.CurrencyGoldName,
            disable = function ()
                return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyGoldShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyGoldShowTotal = value
            end,
            default = Defaults.Currency.CurrencyGoldShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalGold
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalGold = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalGold,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyGoldChange and Settings.Currency.CurrencyGoldShowTotal)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTHRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTHRESHOLD_TP),
            min = 0,
            max = 10000,
            step = 50,
            getFunction = function ()
                return Settings.Currency.CurrencyGoldFilter
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyGoldFilter = value
            end,
            default = Defaults.Currency.CurrencyGoldFilter,
            disable = function ()
                return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTHROTTLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTHROTTLE_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyGoldThrottle
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyGoldThrottle = value
            end,
            default = Defaults.Currency.CurrencyGoldThrottle,
            disable = function ()
                return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_HIDEGOLDAHLIST),
            tooltip = zo_strformat("<<1>>", GetString(LUIE_STRING_LAM_CA_CURRENCY_HIDEGOLDAHLIST_TP)),
            getFunction = function ()
                return Settings.Currency.CurrencyGoldHideListingAH
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyGoldHideListingAH = value
            end,
            default = Defaults.Currency.CurrencyGoldHideListingAH,
            disable = function ()
                return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_HIDEGOLDAHSPENT),
            tooltip = zo_strformat("<<1>>", GetString(LUIE_STRING_LAM_CA_CURRENCY_HIDEGOLDAHSPENT_TP)),
            getFunction = function ()
                return Settings.Currency.CurrencyGoldHideAH
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyGoldHideAH = value
            end,
            default = Defaults.Currency.CurrencyGoldHideAH,
            disable = function ()
                return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        -- Alliance Points
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAP),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAP_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyAPShowChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyAPShowChange = value
            end,
            default = Defaults.Currency.CurrencyAPShowChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyAPColor[1], Settings.Currency.CurrencyAPColor[2], Settings.Currency.CurrencyAPColor[3], Settings.Currency.CurrencyAPColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyAPColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyAPColor,
            disable = function ()
                return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyAPName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyAPName = value
            end,
            default = Defaults.Currency.CurrencyAPName,
            disable = function ()
                return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyAPShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyAPShowTotal = value
            end,
            default = Defaults.Currency.CurrencyAPShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_APTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_APTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalAP
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalAP = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalAP,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyAPShowChange and Settings.Currency.CurrencyAPShowTotal)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTHRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTHRESHOLD_TP),
            min = 0,
            max = 10000,
            step = 50,
            getFunction = function ()
                return Settings.Currency.CurrencyAPFilter
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyAPFilter = value
            end,
            default = Defaults.Currency.CurrencyAPFilter,
            disable = function ()
                return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTHROTTLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTHROTTLE_TP),
            min = 0,
            max = 5000,
            step = 50,
            getFunction = function ()
                return Settings.Currency.CurrencyAPThrottle
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyAPThrottle = value
            end,
            default = Defaults.Currency.CurrencyAPThrottle,
            disable = function ()
                return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        -- Tel Var Stones
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTV),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTV_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTVChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTVChange = value
            end,
            default = Defaults.Currency.CurrencyTVChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyTVColor[1], Settings.Currency.CurrencyTVColor[2], Settings.Currency.CurrencyTVColor[3], Settings.Currency.CurrencyTVColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyTVColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyTVColor,
            disable = function ()
                return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTVName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTVName = value
            end,
            default = Defaults.Currency.CurrencyTVName,
            disable = function ()
                return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTVShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTVShowTotal = value
            end,
            default = Defaults.Currency.CurrencyTVShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_TVTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_TVTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalTV
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalTV = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalTV,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyTVChange and Settings.Currency.CurrencyTVShowTotal)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTHRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTHRESHOLD_TP),
            min = 0,
            max = 10000,
            step = 50,
            getFunction = function ()
                return Settings.Currency.CurrencyTVFilter
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTVFilter = value
            end,
            default = Defaults.Currency.CurrencyTVFilter,
            disable = function ()
                return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTHROTTLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTHROTTLE_TP),
            min = 0,
            max = 5000,
            step = 50,
            getFunction = function ()
                return Settings.Currency.CurrencyTVThrottle
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTVThrottle = value
            end,
            default = Defaults.Currency.CurrencyTVThrottle,
            disable = function ()
                return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        -- Writ Vouchers
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHER),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHER_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyWVChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyWVChange = value
            end,
            default = Defaults.Currency.CurrencyWVChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyWVColor[1], Settings.Currency.CurrencyWVColor[2], Settings.Currency.CurrencyWVColor[3], Settings.Currency.CurrencyWVColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyWVColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyWVColor,
            disable = function ()
                return not (Settings.Currency.CurrencyWVChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyWVName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyWVName = value
            end,
            default = Defaults.Currency.CurrencyWVName,
            disable = function ()
                return not (Settings.Currency.CurrencyWVChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyWVShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyWVShowTotal = value
            end,
            default = Defaults.Currency.CurrencyWVShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyWVChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_WVTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_WVTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalWV
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalWV = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalWV,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyWVChange and Settings.Currency.CurrencyWVShowTotal)
            end
        }

        -- Undaunted Keys
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTED),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTED_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyUndauntedChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyUndauntedChange = value
            end,
            default = Defaults.Currency.CurrencyUndauntedChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyUndauntedColor[1], Settings.Currency.CurrencyUndauntedColor[2], Settings.Currency.CurrencyUndauntedColor[3], Settings.Currency.CurrencyUndauntedColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyUndauntedColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyUndauntedColor,
            disable = function ()
                return not (Settings.Currency.CurrencyUndauntedChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyUndauntedName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyUndauntedName = value
            end,
            default = Defaults.Currency.CurrencyUndauntedName,
            disable = function ()
                return not (Settings.Currency.CurrencyUndauntedChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyUndauntedShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyUndauntedShowTotal = value
            end,
            default = Defaults.Currency.CurrencyUndauntedShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyUndauntedChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_UNDAUNTEDTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_UNDAUNTEDTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalUndaunted
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalUndaunted = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalUndaunted,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyUndauntedChange and Settings.Currency.CurrencyUndauntedShowTotal)
            end
        }

        -- Endless Keys
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyEndlessChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyEndlessChange = value
            end,
            default = Defaults.Currency.CurrencyEndlessChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyEndlessColor[1], Settings.Currency.CurrencyEndlessColor[2], Settings.Currency.CurrencyEndlessColor[3], Settings.Currency.CurrencyEndlessColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyEndlessColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyEndlessColor,
            disable = function ()
                return not (Settings.Currency.CurrencyEndlessChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyEndlessName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyEndlessName = value
            end,
            default = Defaults.Currency.CurrencyEndlessName,
            disable = function ()
                return not (Settings.Currency.CurrencyEndlessChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyEndlessShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyEndlessShowTotal = value
            end,
            default = Defaults.Currency.CurrencyEndlessShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyEndlessChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_ENDLESSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_ENDLESSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalEndless
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalEndless = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalEndless,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyEndlessChange and Settings.Currency.CurrencyEndlessShowTotal)
            end
        }

        -- Outfit Tokens
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyOutfitTokenChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyOutfitTokenChange = value
            end,
            default = Defaults.Currency.CurrencyOutfitTokenChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyOutfitTokenColor[1], Settings.Currency.CurrencyOutfitTokenColor[2], Settings.Currency.CurrencyOutfitTokenColor[3], Settings.Currency.CurrencyOutfitTokenColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyOutfitTokenColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyOutfitTokenColor,
            disable = function ()
                return not (Settings.Currency.CurrencyOutfitTokenChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyOutfitTokenName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyOutfitTokenName = value
            end,
            default = Defaults.Currency.CurrencyOutfitTokenName,
            disable = function ()
                return not (Settings.Currency.CurrencyOutfitTokenChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyOutfitTokenShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyOutfitTokenShowTotal = value
            end,
            default = Defaults.Currency.CurrencyOutfitTokenShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyOutfitTokenChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOKENSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOKENSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalOutfitToken
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalOutfitToken = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalOutfitToken,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyOutfitTokenChange and Settings.Currency.CurrencyOutfitTokenShowTotal)
            end
        }

        -- Transmute Crystals
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTE_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTransmuteChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTransmuteChange = value
            end,
            default = Defaults.Currency.CurrencyTransmuteChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTECOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyTransmuteColor[1], Settings.Currency.CurrencyTransmuteColor[2], Settings.Currency.CurrencyTransmuteColor[3], Settings.Currency.CurrencyTransmuteColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyTransmuteColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyTransmuteColor,
            disable = function ()
                return not (Settings.Currency.CurrencyTransmuteChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTENAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTENAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTransmuteName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTransmuteName = value
            end,
            default = Defaults.Currency.CurrencyTransmuteName,
            disable = function ()
                return not (Settings.Currency.CurrencyTransmuteChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTETOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTETOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTransmuteShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTransmuteShowTotal = value
            end,
            default = Defaults.Currency.CurrencyTransmuteShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyTransmuteChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_TRANSMUTETOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_TRANSMUTETOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalTransmute
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalTransmute = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalTransmute,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyTransmuteChange and Settings.Currency.CurrencyTransmuteShowTotal)
            end
        }

        -- Event Tickets
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWSEALS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWSEALS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencySealsChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencySealsChange = value
            end,
            default = Defaults.Currency.CurrencySealsChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWSEALSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencySealsColor[1], Settings.Currency.CurrencySealsColor[2], Settings.Currency.CurrencySealsColor[3], Settings.Currency.CurrencySealsColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencySealsColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencySealsColor,
            disable = function ()
                return not (Settings.Currency.CurrencySealsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWSEALSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWSEALSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencySealsName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencySealsName = value
            end,
            default = Defaults.Currency.CurrencySealsName,
            disable = function ()
                return not (Settings.Currency.CurrencySealsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWSEALSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWSEALSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencySealsShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencySealsShowTotal = value
            end,
            default = Defaults.Currency.CurrencySealsShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencySealsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SEALSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SEALSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalSeals
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalSeals = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalSeals,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencySealsChange and Settings.Currency.CurrencySealsShowTotal)
            end
        }

        -- Crowns
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyCrownsChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyCrownsChange = value
            end,
            default = Defaults.Currency.CurrencyCrownsChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyCrownsColor[1], Settings.Currency.CurrencyCrownsColor[2], Settings.Currency.CurrencyCrownsColor[3], Settings.Currency.CurrencyCrownsColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyCrownsColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyCrownsColor,
            disable = function ()
                return not (Settings.Currency.CurrencyCrownsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyCrownsName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyCrownsName = value
            end,
            default = Defaults.Currency.CurrencyCrownsName,
            disable = function ()
                return not (Settings.Currency.CurrencyCrownsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyCrownsShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyCrownsShowTotal = value
            end,
            default = Defaults.Currency.CurrencyCrownsShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyCrownsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_CROWNSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_CROWNSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalCrowns
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalCrowns = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalCrowns,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyCrownsChange and Settings.Currency.CurrencyCrownsShowTotal)
            end
        }

        -- Crown Gems
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyCrownGemsChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyCrownGemsChange = value
            end,
            default = Defaults.Currency.CurrencyCrownGemsChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyCrownGemsColor[1], Settings.Currency.CurrencyCrownGemsColor[2], Settings.Currency.CurrencyCrownGemsColor[3], Settings.Currency.CurrencyCrownGemsColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyCrownGemsColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyCrownGemsColor,
            disable = function ()
                return not (Settings.Currency.CurrencyCrownGemsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyCrownGemsName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyCrownGemsName = value
            end,
            default = Defaults.Currency.CurrencyCrownGemsName,
            disable = function ()
                return not (Settings.Currency.CurrencyCrownGemsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyCrownGemsShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyCrownGemsShowTotal = value
            end,
            default = Defaults.Currency.CurrencyCrownGemsShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyCrownGemsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_CROWNGEMSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_CROWNGEMSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalCrownGems
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalCrownGems = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalCrownGems,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyCrownGemsChange and Settings.Currency.CurrencyCrownGemsShowTotal)
            end
        }

        -- Trade Bars
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRADEBARS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRADEBARS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTradeBarsChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTradeBarsChange = value
            end,
            default = Defaults.Currency.CurrencyTradeBarsChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRADEBARSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyTradeBarsColor[1], Settings.Currency.CurrencyTradeBarsColor[2], Settings.Currency.CurrencyTradeBarsColor[3], Settings.Currency.CurrencyTradeBarsColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyTradeBarsColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyTradeBarsColor,
            disable = function ()
                return not (Settings.Currency.CurrencyTradeBarsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRADEBARSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRADEBARSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTradeBarsName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTradeBarsName = value
            end,
            default = Defaults.Currency.CurrencyTradeBarsName,
            disable = function ()
                return not (Settings.Currency.CurrencyTradeBarsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRADEBARSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRADEBARSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTradeBarsShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTradeBarsShowTotal = value
            end,
            default = Defaults.Currency.CurrencyTradeBarsShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyTradeBarsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_TRADEBARSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_TRADEBARSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalTradeBars
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalTradeBars = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalTradeBars,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyTradeBarsChange and Settings.Currency.CurrencyTradeBarsShowTotal)
            end
        }

        -- Tome Points
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomePointsChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomePointsChange = value
            end,
            default = Defaults.Currency.CurrencyTomePointsChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyTomePointsColor[1], Settings.Currency.CurrencyTomePointsColor[2], Settings.Currency.CurrencyTomePointsColor[3], Settings.Currency.CurrencyTomePointsColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyTomePointsColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyTomePointsColor,
            disable = function ()
                return not (Settings.Currency.CurrencyTomePointsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomePointsName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomePointsName = value
            end,
            default = Defaults.Currency.CurrencyTomePointsName,
            disable = function ()
                return not (Settings.Currency.CurrencyTomePointsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomePointsShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomePointsShowTotal = value
            end,
            default = Defaults.Currency.CurrencyTomePointsShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyTomePointsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOMEPOINTSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOMEPOINTSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalTomePoints
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalTomePoints = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalTomePoints,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyTomePointsChange and Settings.Currency.CurrencyTomePointsShowTotal)
            end
        }

        -- Tome Point Caches
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTCACHES),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTCACHES_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomePointCachesChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomePointCachesChange = value
            end,
            default = Defaults.Currency.CurrencyTomePointCachesChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTCACHESCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyTomePointCachesColor[1], Settings.Currency.CurrencyTomePointCachesColor[2], Settings.Currency.CurrencyTomePointCachesColor[3], Settings.Currency.CurrencyTomePointCachesColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyTomePointCachesColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyTomePointCachesColor,
            disable = function ()
                return not (Settings.Currency.CurrencyTomePointCachesChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTCACHESNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTCACHESNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomePointCachesName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomePointCachesName = value
            end,
            default = Defaults.Currency.CurrencyTomePointCachesName,
            disable = function ()
                return not (Settings.Currency.CurrencyTomePointCachesChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTCACHESTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMEPOINTCACHESTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomePointCachesShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomePointCachesShowTotal = value
            end,
            default = Defaults.Currency.CurrencyTomePointCachesShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyTomePointCachesChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOMEPOINTCACHESTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOMEPOINTCACHESTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalTomePointCaches
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalTomePointCaches = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalTomePointCaches,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyTomePointCachesChange and Settings.Currency.CurrencyTomePointCachesShowTotal)
            end
        }

        -- Tome Tokens
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMETOKENS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMETOKENS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomeTokensChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomeTokensChange = value
            end,
            default = Defaults.Currency.CurrencyTomeTokensChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMETOKENSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyTomeTokensColor[1], Settings.Currency.CurrencyTomeTokensColor[2], Settings.Currency.CurrencyTomeTokensColor[3], Settings.Currency.CurrencyTomeTokensColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyTomeTokensColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyTomeTokensColor,
            disable = function ()
                return not (Settings.Currency.CurrencyTomeTokensChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMETOKENSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMETOKENSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomeTokensName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomeTokensName = value
            end,
            default = Defaults.Currency.CurrencyTomeTokensName,
            disable = function ()
                return not (Settings.Currency.CurrencyTomeTokensChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMETOKENSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMETOKENSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomeTokensShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomeTokensShowTotal = value
            end,
            default = Defaults.Currency.CurrencyTomeTokensShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyTomeTokensChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOMETOKENSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOMETOKENSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalTomeTokens
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalTomeTokens = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalTomeTokens,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyTomeTokensChange and Settings.Currency.CurrencyTomeTokensShowTotal)
            end
        }

        -- Tome Challenge Rerolls
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMECHALLENGEREROLLS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMECHALLENGEREROLLS_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomeChallengeRerollsChange
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomeChallengeRerollsChange = value
            end,
            default = Defaults.Currency.CurrencyTomeChallengeRerollsChange,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMECHALLENGEREROLLSCOLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyTomeChallengeRerollsColor[1], Settings.Currency.CurrencyTomeChallengeRerollsColor[2], Settings.Currency.CurrencyTomeChallengeRerollsColor[3], Settings.Currency.CurrencyTomeChallengeRerollsColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyTomeChallengeRerollsColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyTomeChallengeRerollsColor,
            disable = function ()
                return not (Settings.Currency.CurrencyTomeChallengeRerollsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMECHALLENGEREROLLSNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMECHALLENGEREROLLSNAME_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomeChallengeRerollsName
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomeChallengeRerollsName = value
            end,
            default = Defaults.Currency.CurrencyTomeChallengeRerollsName,
            disable = function ()
                return not (Settings.Currency.CurrencyTomeChallengeRerollsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMECHALLENGEREROLLSTOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOMECHALLENGEREROLLSTOTAL_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyTomeChallengeRerollsShowTotal
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyTomeChallengeRerollsShowTotal = value
            end,
            default = Defaults.Currency.CurrencyTomeChallengeRerollsShowTotal,
            disable = function ()
                return not (Settings.Currency.CurrencyTomeChallengeRerollsChange and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOMECHALLENGEREROLLSTOTAL_MSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_TOMECHALLENGEREROLLSTOTAL_MSG_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyMessageTotalTomeChallengeRerolls
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyMessageTotalTomeChallengeRerolls = value
            end,
            default = Defaults.Currency.CurrencyMessageTotalTomeChallengeRerolls,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyTomeChallengeRerollsChange and Settings.Currency.CurrencyTomeChallengeRerollsShowTotal)
            end
        }
    end)

    -- Build Loot Announcements Section
    buildSectionSettings("Loot", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_LOOT),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_ITEM),
            tooltip = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_ITEM_TP),
            items = SettingsAPI:GetLinkBracketDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeLinkBracketDisplayIndex(Settings.BracketOptionItem, 1))
            end,
            setFunction = function (combobox, value, item)
                Settings.BracketOptionItem = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BracketOptionItem),
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWICONS),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWICONS_TP),
            getFunction = function ()
                return Settings.Inventory.LootIcons
            end,
            setFunction = function (value)
                Settings.Inventory.LootIcons = value
            end,
            default = Defaults.Inventory.LootIcons,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCOLLECTIONSTATUS),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCOLLECTIONSTATUS_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowCollectionStatus
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowCollectionStatus = value
            end,
            default = Defaults.Inventory.LootShowCollectionStatus,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWARMORTYPE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWARMORTYPE_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowArmorType
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowArmorType = value
            end,
            default = Defaults.Inventory.LootShowArmorType,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMSTYLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMSTYLE_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowStyle
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowStyle = value
            end,
            default = Defaults.Inventory.LootShowStyle,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMTRAIT),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMTRAIT_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowTrait
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowTrait = value
            end,
            default = Defaults.Inventory.LootShowTrait,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMTYPE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMTYPE_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowItemType
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowItemType = value
            end,
            default = Defaults.Inventory.LootShowItemType,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_TOTAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_TOTAL_TP),
            getFunction = function ()
                return Settings.Inventory.LootTotal
            end,
            setFunction = function (value)
                Settings.Inventory.LootTotal = value
            end,
            default = Defaults.Inventory.LootTotal,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_TOTALSTRING),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_TOTALSTRING_TP),
            getFunction = function ()
                return Settings.Inventory.LootTotalString
            end,
            setFunction = function (value)
                Settings.Inventory.LootTotalString = value
            end,
            default = Defaults.Inventory.LootTotalString,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Inventory.LootTotal)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMS),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMS_TP),
            getFunction = function ()
                return Settings.Inventory.Loot
            end,
            setFunction = function (value)
                Settings.Inventory.Loot = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.Loot,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTLOGDISABLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTLOGDISABLE_TP),
            getFunction = function ()
                return Settings.Inventory.LootLogOverride
            end,
            setFunction = function (value)
                Settings.Inventory.LootLogOverride = value
            end,
            default = Defaults.Inventory.LootLogOverride,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWNOTABLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWNOTABLE_TP),
            getFunction = function ()
                return Settings.Inventory.LootOnlyNotable
            end,
            setFunction = function (value)
                Settings.Inventory.LootOnlyNotable = value
            end,
            default = Defaults.Inventory.LootOnlyNotable,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWGRPLOOT),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWGRPLOOT_TP),
            getFunction = function ()
                return Settings.Inventory.LootGroup
            end,
            setFunction = function (value)
                Settings.Inventory.LootGroup = value
            end,
            default = Defaults.Inventory.LootGroup,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_HIDEANNOYINGITEMS),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_HIDEANNOYINGITEMS_TP),
            getFunction = function ()
                return Settings.Inventory.LootBlacklist
            end,
            setFunction = function (value)
                Settings.Inventory.LootBlacklist = value
            end,
            default = Defaults.Inventory.LootBlacklist,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end,
            warning = GetString(LUIE_STRING_LAM_CA_LOOT_HIDEANNOYINGITEMS_WARNING)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_HIDETRASH),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_HIDETRASH_TP),
            getFunction = function ()
                return Settings.Inventory.LootNotTrash
            end,
            setFunction = function (value)
                Settings.Inventory.LootNotTrash = value
            end,
            default = Defaults.Inventory.LootNotTrash,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTCONFISCATED),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTCONFISCATED_TP),
            getFunction = function ()
                return Settings.Inventory.LootConfiscate
            end,
            setFunction = function (value)
                Settings.Inventory.LootConfiscate = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootConfiscate,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWCONTAINER),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWCONTAINER_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowContainer
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowContainer = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowContainer,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWDESTROYED),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWDESTROYED_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowDestroy
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowDestroy = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowDestroy,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWREMOVED),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWREMOVED_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowRemove
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowRemove = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowRemove,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWLIST),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWLIST_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowList
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowList = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowList,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWTURNIN),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWTURNIN_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowTurnIn
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowTurnIn = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowTurnIn,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_POTION),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_POTION_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowUsePotion
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowUsePotion = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowUsePotion,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_FOOD),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_FOOD_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowUseFood
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowUseFood = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowUseFood,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_DRINK),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_DRINK_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowUseDrink
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowUseDrink = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowUseDrink,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_REPAIR_KIT),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_REPAIR_KIT_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowUseRepairKit
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowUseRepairKit = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowUseRepairKit,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_SOUL_GEM),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_SOUL_GEM_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowUseSoulGem
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowUseSoulGem = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowUseSoulGem,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_SIEGE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_SIEGE_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowUseSiege
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowUseSiege = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowUseSiege,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_FISH),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_FISH_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowUseFish
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowUseFish = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowUseFish,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_MISC),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_MISC_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowUseMisc
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowUseMisc = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowUseMisc,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWLOCKPICK),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWLOCKPICK_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowLockpick
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowLockpick = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowLockpick,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTRECIPE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTRECIPE_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowRecipe
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowRecipe = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowRecipe,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTMOTIF),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTMOTIF_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowMotif
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowMotif = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowMotif,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSTYLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSTYLE_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowStylePage
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowStylePage = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowStylePage,
            disable = function ()
                return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_HIDE_RECIPE_ALERT),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_HIDE_RECIPE_ALERT_TP),
            getFunction = function ()
                return Settings.Inventory.LootRecipeHideAlert
            end,
            setFunction = function (value)
                Settings.Inventory.LootRecipeHideAlert = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootRecipeHideAlert,
            disable = function ()
                return not (Settings.Inventory.Loot and (Settings.Inventory.LootShowRecipe or Settings.Inventory.LootShowMotif or Settings.Inventory.LootShowStylePage) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWQUESTADD),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWQUESTADD_TP),
            getFunction = function ()
                return Settings.Inventory.LootQuestAdd
            end,
            setFunction = function (value)
                Settings.Inventory.LootQuestAdd = value
                ChatAnnouncements.RegisterLootEvents()
                ChatAnnouncements.AddQuestItemsToIndex()
            end,
            default = Defaults.Inventory.LootQuestAdd,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWQUESTREM),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWQUESTREM_TP),
            getFunction = function ()
                return Settings.Inventory.LootQuestRemove
            end,
            setFunction = function (value)
                Settings.Inventory.LootQuestRemove = value
                ChatAnnouncements.RegisterLootEvents()
                ChatAnnouncements.AddQuestItemsToIndex()
            end,
            default = Defaults.Inventory.LootQuestRemove,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWVENDOR),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWVENDOR_TP),
            getFunction = function ()
                return Settings.Inventory.LootVendor
            end,
            setFunction = function (value)
                Settings.Inventory.LootVendor = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootVendor,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_MERGE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_MERGE_TP),
            getFunction = function ()
                return Settings.Inventory.LootVendorCurrency
            end,
            setFunction = function (value)
                Settings.Inventory.LootVendorCurrency = value
            end,
            default = Defaults.Inventory.LootVendorCurrency,
            disable = function ()
                return not (Settings.Inventory.LootVendor and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_TOTALITEMS),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_TOTALITEMS_TP),
            getFunction = function ()
                return Settings.Inventory.LootVendorTotalItems
            end,
            setFunction = function (value)
                Settings.Inventory.LootVendorTotalItems = value
            end,
            default = Defaults.Inventory.LootVendorTotalItems,
            disable = function ()
                return not (Settings.Inventory.LootVendor and Settings.Inventory.LootVendorCurrency and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_TOTALCURRENCY),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_TOTALCURRENCY_TP),
            getFunction = function ()
                return Settings.Inventory.LootVendorTotalCurrency
            end,
            setFunction = function (value)
                Settings.Inventory.LootVendorTotalCurrency = value
            end,
            default = Defaults.Inventory.LootVendorTotalCurrency,
            disable = function ()
                return not (Settings.Inventory.LootVendor and Settings.Inventory.LootVendorCurrency and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWBANK),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWBANK_TP),
            getFunction = function ()
                return Settings.Inventory.LootBank
            end,
            setFunction = function (value)
                Settings.Inventory.LootBank = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootBank,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCRAFT),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCRAFT_TP),
            getFunction = function ()
                return Settings.Inventory.LootCraft
            end,
            setFunction = function (value)
                Settings.Inventory.LootCraft = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootCraft,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCRAFT_MATERIALS),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCRAFT_MATERIALS_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowCraftUse
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowCraftUse = value
            end,
            default = Defaults.Inventory.LootShowCraftUse,
            disable = function ()
                return not (Settings.Inventory.LootCraft and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWMAIL),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWMAIL_TP),
            getFunction = function ()
                return Settings.Inventory.LootMail
            end,
            setFunction = function (value)
                Settings.Inventory.LootMail = value
                ChatAnnouncements.RegisterMailEvents()
            end,
            default = Defaults.Inventory.LootMail,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWTRADE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_SHOWTRADE_TP),
            getFunction = function ()
                return Settings.Inventory.LootTrade
            end,
            setFunction = function (value)
                Settings.Inventory.LootTrade = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootTrade,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWDISGUISE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWDISGUISE_TP),
            getFunction = function ()
                return Settings.Inventory.LootShowDisguise
            end,
            setFunction = function (value)
                Settings.Inventory.LootShowDisguise = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Inventory.LootShowDisguise,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_ATTUNABLE_STATION_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ATTUNABLE_STATION_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ATTUNABLE_STATION_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Inventory.AttunableStationCA
            end,
            setFunction = function (value)
                Settings.Inventory.AttunableStationCA = value
            end,
            default = Defaults.Inventory.AttunableStationCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ATTUNABLE_STATION_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ATTUNABLE_STATION_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Inventory.AttunableStationCSA
            end,
            setFunction = function (value)
                Settings.Inventory.AttunableStationCSA = value
            end,
            default = Defaults.Inventory.AttunableStationCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ATTUNABLE_STATION_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ATTUNABLE_STATION_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Inventory.AttunableStationAlert
            end,
            setFunction = function (value)
                Settings.Inventory.AttunableStationAlert = value
            end,
            default = Defaults.Inventory.AttunableStationAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }
    end)

    -- Build Shared Currency/Loot Options Section
    buildSectionSettings("SharedCurrencyLoot", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_CONTEXT_MENU),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_SHARED),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR),
            getFunction = function ()
                return Settings.Currency.CurrencyColor[1], Settings.Currency.CurrencyColor[2], Settings.Currency.CurrencyColor[3], Settings.Currency.CurrencyColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyColor,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR_CONTEXT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR_CONTEXT_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyContextColor
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyContextColor = value
            end,
            default = Defaults.Currency.CurrencyContextColor,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_COLORUP),
            getFunction = function ()
                return Settings.Currency.CurrencyColorUp[1], Settings.Currency.CurrencyColorUp[2], Settings.Currency.CurrencyColorUp[3], Settings.Currency.CurrencyColorUp[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyColorUp = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyColorUp,
            disable = function ()
                return not (Settings.Currency.CurrencyContextColor and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_COLORDOWN),
            getFunction = function ()
                return Settings.Currency.CurrencyColorDown[1], Settings.Currency.CurrencyColorDown[2], Settings.Currency.CurrencyColorDown[3], Settings.Currency.CurrencyColorDown[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Currency.CurrencyColorDown = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Currency.CurrencyColorDown,
            disable = function ()
                return not (Settings.Currency.CurrencyContextColor and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR_CONTEXT_MERGED),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR_CONTEXT_MERGED_TP),
            getFunction = function ()
                return Settings.Currency.CurrencyContextMergedColor
            end,
            setFunction = function (value)
                Settings.Currency.CurrencyContextMergedColor = value
            end,
            default = Defaults.Currency.CurrencyContextMergedColor,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_CONTEXT_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOOT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOOT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageLoot
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageLoot = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageLoot,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_RECEIVE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_RECEIVE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageReceive
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageReceive = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageReceive,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EARN),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EARN_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageEarn
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageEarn = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageEarn,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STEAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STEAL_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageSteal
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageSteal = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageSteal,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_PICKPOCKET),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_PICKPOCKET_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessagePickpocket
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessagePickpocket = value
            end,
            default = Defaults.ContextMessages.CurrencyMessagePickpocket,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CONFISCATE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CONFISCATE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageConfiscate
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageConfiscate = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageConfiscate,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SPEND),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SPEND_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageSpend
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageSpend = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageSpend,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_PAY),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_PAY_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessagePay
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessagePay = value
            end,
            default = Defaults.ContextMessages.CurrencyMessagePay,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_USEKIT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_USEKIT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageUseKit
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageUseKit = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageUseKit,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_POTION),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_POTION_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessagePotion
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessagePotion = value
            end,
            default = Defaults.ContextMessages.CurrencyMessagePotion,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FOOD),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FOOD_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageFood
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageFood = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageFood,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DRINK),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DRINK_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDrink
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDrink = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDrink,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPLOY),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPLOY_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDeploy
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDeploy = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDeploy,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STOW),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STOW_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageStow
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageStow = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageStow,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FILLET),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FILLET_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageFillet
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageFillet = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageFillet,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_RECIPE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_RECIPE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageLearnRecipe
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageLearnRecipe = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageLearnRecipe,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_MOTIF),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_MOTIF_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageLearnMotif
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageLearnMotif = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageLearnMotif,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_STYLE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageLearnStyle
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageLearnStyle = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageLearnStyle,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXCAVATE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXCAVATE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageExcavate
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageExcavate = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageExcavate,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEIN),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEIN_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageTradeIn
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageTradeIn = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageTradeIn,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEIN_NO_NAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEIN_NO_NAME_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageTradeInNoName
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageTradeInNoName = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageTradeInNoName,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEOUT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEOUT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageTradeOut
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageTradeOut = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageTradeOut,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEOUT_NO_NAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEOUT_NO_NAME_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageTradeOutNoName
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageTradeOutNoName = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageTradeOutNoName,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILIN),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILIN_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageMailIn
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageMailIn = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageMailIn,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILIN_NO_NAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILIN_NO_NAME_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageMailInNoName
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageMailInNoName = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageMailInNoName,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILOUT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILOUT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageMailOut
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageMailOut = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageMailOut,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILOUT_NO_NAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILOUT_NO_NAME_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageMailOutNoName
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageMailOutNoName = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageMailOutNoName,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSIT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSIT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDeposit
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDeposit = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDeposit,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAW),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAW_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageWithdraw
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageWithdraw = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageWithdraw,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSITGUILD),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSITGUILD_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDepositGuild
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDepositGuild = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDepositGuild,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAWGUILD),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAWGUILD_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageWithdrawGuild
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageWithdrawGuild = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageWithdrawGuild,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSITSTORAGE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSITSTORAGE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDepositStorage
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDepositStorage = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDepositStorage,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAWSTORAGE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAWSTORAGE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageWithdrawStorage
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageWithdrawStorage = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageWithdrawStorage,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSIT_FURNITURE_VAULT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSIT_FURNITURE_VAULT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDepositFurnitureVault
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDepositFurnitureVault = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDepositFurnitureVault,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAW_FURNITURE_VAULT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAW_FURNITURE_VAULT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageWithdrawFurnitureVault
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageWithdrawFurnitureVault = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageWithdrawFurnitureVault,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOST),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOST_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageLost
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageLost = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageLost,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BOUNTY),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BOUNTY_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageBounty
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageBounty = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageBounty,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REPAIR),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REPAIR_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageRepair
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageRepair = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageRepair,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADER),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADER_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageTrader
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageTrader = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageTrader,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LISTING),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LISTING_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageListing
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageListing = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageListing,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LIST),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LIST_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageList
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageList = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageList,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LISTING_VALUE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LISTING_VALUE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageListingValue
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageListingValue = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageListingValue,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUY_VALUE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUY_VALUE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageBuy
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageBuy = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageBuy,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUY),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUY_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageBuyNoV
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageBuyNoV = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageBuyNoV,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUYBACK_VALUE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUYBACK_VALUE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageBuyback
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageBuyback = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageBuyback,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUYBACK),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUYBACK_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageBuybackNoV
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageBuybackNoV = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageBuybackNoV,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SELL_VALUE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SELL_VALUE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageSell
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageSell = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageSell,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SELL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SELL_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageSellNoV
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageSellNoV = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageSellNoV,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FENCE_VALUE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FENCE_VALUE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageFence
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageFence = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageFence,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FENCE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FENCE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageFenceNoV
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageFenceNoV = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageFenceNoV,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LAUNDER_VALUE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LAUNDER_VALUE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageLaunder
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageLaunder = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageLaunder,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LAUNDER),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LAUNDER_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageLaunderNoV
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageLaunderNoV = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageLaunderNoV,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STABLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STABLE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageStable
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageStable = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageStable,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STORAGE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STORAGE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageStorage
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageStorage = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageStorage,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WAYSHRINE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WAYSHRINE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageWayshrine
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageWayshrine = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageWayshrine,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UNSTUCK),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UNSTUCK_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageUnstuck
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageUnstuck = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageUnstuck,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_ATTRIBUTES),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_ATTRIBUTES_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageAttributes
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageAttributes = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageAttributes,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CHAMPION),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CHAMPION_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageChampion
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageChampion = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageChampion,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MORPHS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MORPHS_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageMorphs
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageMorphs = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageMorphs,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SKILLS),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SKILLS_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageSkills
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageSkills = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageSkills,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CAMPAIGN),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CAMPAIGN_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageCampaign
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageCampaign = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageCampaign,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_USE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_USE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageUse
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageUse = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageUse,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CRAFT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CRAFT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageCraft
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageCraft = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageCraft,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXTRACT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXTRACT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageExtract
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageExtract = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageExtract,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UPGRADE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UPGRADE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageUpgrade
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageUpgrade = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageUpgrade,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UPGRADE_FAIL),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UPGRADE_FAIL_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageUpgradeFail
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageUpgradeFail = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageUpgradeFail,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REFINE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REFINE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageRefine
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageRefine = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageRefine,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DECONSTRUCT),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DECONSTRUCT_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDeconstruct
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDeconstruct = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDeconstruct,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_RESEARCH),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_RESEARCH_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageResearch
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageResearch = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageResearch,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DESTROY),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DESTROY_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDestroy
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDestroy = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDestroy,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CONTAINER),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CONTAINER_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageContainer
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageContainer = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageContainer,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOCKPICK),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOCKPICK_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageLockpick
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageLockpick = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageLockpick,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REMOVE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REMOVE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageRemove
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageRemove = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageRemove,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TURNIN),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TURNIN_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestTurnIn
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestTurnIn = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestTurnIn,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTUSE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTUSE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestUse
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestUse = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestUse,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXHAUST),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXHAUST_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestExhaust
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestExhaust = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestExhaust,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_OFFER),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_OFFER_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestOffer
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestOffer = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestOffer,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISCARD),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISCARD_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestDiscard
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestDiscard = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestDiscard,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTOPEN),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTOPEN_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestOpen
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestOpen = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestOpen,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTCONFISCATE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTCONFISCATE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestConfiscate
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestConfiscate = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestConfiscate,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTADMINISTER),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTADMINISTER_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestAdminister
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestAdminister = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestAdminister,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTPLACE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTPLACE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestPlace
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestPlace = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestPlace,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_COMBINE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_COMBINE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestCombine
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestCombine = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestCombine,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MIX),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MIX_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestMix
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestMix = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestMix,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUNDLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUNDLE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageQuestBundle
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageQuestBundle = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageQuestBundle,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_GROUP),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_GROUP_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageGroup
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageGroup = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageGroup,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_EQUIP),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_EQUIP_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDisguiseEquip
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDisguiseEquip = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDisguiseEquip,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_REMOVE),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_REMOVE_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDisguiseRemove
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDisguiseRemove = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDisguiseRemove,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_DESTROY),
            tooltip = GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_DESTROY_TP),
            getFunction = function ()
                return Settings.ContextMessages.CurrencyMessageDisguiseDestroy
            end,
            setFunction = function (value)
                Settings.ContextMessages.CurrencyMessageDisguiseDestroy = value
            end,
            default = Defaults.ContextMessages.CurrencyMessageDisguiseDestroy,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }
    end)

    -- Build Experience Announcements Section
    buildSectionSettings("Experience", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_EXP_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_EXP_HEADER_ENLIGHTENED)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.XP.ExperienceEnlightenedCA
            end,
            setFunction = function (value)
                Settings.XP.ExperienceEnlightenedCA = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceEnlightenedCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.XP.ExperienceEnlightenedCSA
            end,
            setFunction = function (value)
                Settings.XP.ExperienceEnlightenedCSA = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceEnlightenedCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.XP.ExperienceEnlightenedAlert
            end,
            setFunction = function (value)
                Settings.XP.ExperienceEnlightenedAlert = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceEnlightenedAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_EXP_HEADER_LEVELUP)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.XP.ExperienceLevelUpCA
            end,
            setFunction = function (value)
                Settings.XP.ExperienceLevelUpCA = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceLevelUpCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.XP.ExperienceLevelUpCSA
            end,
            setFunction = function (value)
                Settings.XP.ExperienceLevelUpCSA = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceLevelUpCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_CSAEXPAND),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_CSAEXPAND_TP),
            getFunction = function ()
                return Settings.XP.ExperienceLevelUpCSAExpand
            end,
            setFunction = function (value)
                Settings.XP.ExperienceLevelUpCSAExpand = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceLevelUpCSAExpand,
            disable = function ()
                return not (Settings.XP.ExperienceLevelUpCSA and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.XP.ExperienceLevelUpAlert
            end,
            setFunction = function (value)
                Settings.XP.ExperienceLevelUpAlert = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceLevelUpAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_EXP_LVLUPICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_LVLUPICON_TP),
            getFunction = function ()
                return Settings.XP.ExperienceLevelUpIcon
            end,
            setFunction = function (value)
                Settings.XP.ExperienceLevelUpIcon = value
            end,
            default = Defaults.XP.ExperienceLevelUpIcon,
            disable = function ()
                return not ((Settings.XP.ExperienceLevelUpCA or Settings.XP.ExperienceLevelUpCSA or Settings.XP.ExperienceLevelUpAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_EXPERIENCE_LEVELUP_COLOR),
            getFunction = function ()
                return Settings.XP.ExperienceLevelUpColor[1], Settings.XP.ExperienceLevelUpColor[2], Settings.XP.ExperienceLevelUpColor[3], Settings.XP.ExperienceLevelUpColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.XP.ExperienceLevelUpColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.XP.ExperienceLevelUpColor,
            disable = function ()
                return not ((Settings.XP.ExperienceLevelUpCA or Settings.XP.ExperienceLevelUpCSA or Settings.XP.ExperienceLevelUpAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_EXP_COLORLVLBYCONTEXT),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_COLORLVLBYCONTEXT_TP),
            getFunction = function ()
                return Settings.XP.ExperienceLevelColorByLevel
            end,
            setFunction = function (value)
                Settings.XP.ExperienceLevelColorByLevel = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceLevelColorByLevel,
            disable = function ()
                return not ((Settings.XP.ExperienceLevelUpCA or Settings.XP.ExperienceLevelUpCSA or Settings.XP.ExperienceLevelUpAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_EXP_HEADER_EXPERIENCEGAIN)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_EXP_SHOWEXPGAIN),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_SHOWEXPGAIN_TP),
            getFunction = function ()
                return Settings.XP.Experience
            end,
            setFunction = function (value)
                Settings.XP.Experience = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.Experience,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_EXP_SHOWEXPICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_SHOWEXPICON_TP),
            getFunction = function ()
                return Settings.XP.ExperienceIcon
            end,
            setFunction = function (value)
                Settings.XP.ExperienceIcon = value
            end,
            default = Defaults.XP.ExperienceIcon,
            disable = function ()
                return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_EXPERIENCE_COLORMESSAGE),
            getFunction = function ()
                return Settings.XP.ExperienceColorMessage[1], Settings.XP.ExperienceColorMessage[2], Settings.XP.ExperienceColorMessage[3], Settings.XP.ExperienceColorMessage[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.XP.ExperienceColorMessage = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.XP.ExperienceColorMessage,
            disable = function ()
                return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_EXPERIENCE_COLORNAME),
            getFunction = function ()
                return Settings.XP.ExperienceColorName[1], Settings.XP.ExperienceColorName[2], Settings.XP.ExperienceColorName[3], Settings.XP.ExperienceColorName[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.XP.ExperienceColorName = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.XP.ExperienceColorName,
            disable = function ()
                return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_EXP_MESSAGE),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_MESSAGE_TP),
            getFunction = function ()
                return Settings.XP.ExperienceMessage
            end,
            setFunction = function (value)
                Settings.XP.ExperienceMessage = value
            end,
            default = Defaults.XP.ExperienceMessage,
            disable = function ()
                return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_EXP_NAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_NAME_TP),
            getFunction = function ()
                return Settings.XP.ExperienceName
            end,
            setFunction = function (value)
                Settings.XP.ExperienceName = value
            end,
            default = Defaults.XP.ExperienceName,
            disable = function ()
                return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_EXP_HIDEEXPKILLS),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_HIDEEXPKILLS_TP),
            getFunction = function ()
                return Settings.XP.ExperienceHideCombat
            end,
            setFunction = function (value)
                Settings.XP.ExperienceHideCombat = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.XP.ExperienceHideCombat,
            disable = function ()
                return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_EXP_EXPGAINTHRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_EXPGAINTHRESHOLD_TP),
            min = 0,
            max = 10000,
            step = 100,
            getFunction = function ()
                return Settings.XP.ExperienceFilter
            end,
            setFunction = function (value)
                Settings.XP.ExperienceFilter = value
            end,
            default = Defaults.XP.ExperienceFilter,
            disable = function ()
                return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_EXP_THROTTLEEXPINCOMBAT),
            tooltip = GetString(LUIE_STRING_LAM_CA_EXP_THROTTLEEXPINCOMBAT_TP),
            min = 0,
            max = 5000,
            step = 50,
            getFunction = function ()
                return Settings.XP.ExperienceThrottle
            end,
            setFunction = function (value)
                Settings.XP.ExperienceThrottle = value
            end,
            default = Defaults.XP.ExperienceThrottle,
            disable = function ()
                return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_EXP_HEADER_SKILL_POINTS)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Skills.SkillPointCA
            end,
            setFunction = function (value)
                Settings.Skills.SkillPointCA = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.Skills.SkillPointCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Skills.SkillPointCSA
            end,
            setFunction = function (value)
                Settings.Skills.SkillPointCSA = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.Skills.SkillPointCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Skills.SkillPointAlert
            end,
            setFunction = function (value)
                Settings.Skills.SkillPointAlert = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.Skills.SkillPointAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_SKILLPOINT_COLOR1),
            getFunction = function ()
                return Settings.Skills.SkillPointColor1[1], Settings.Skills.SkillPointColor1[2], Settings.Skills.SkillPointColor1[3], Settings.Skills.SkillPointColor1[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillPointColor1 = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillPointColor1,
            disable = function ()
                return not ((Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_SKILLPOINT_COLOR2),
            getFunction = function ()
                return Settings.Skills.SkillPointColor2[1], Settings.Skills.SkillPointColor2[2], Settings.Skills.SkillPointColor2[3], Settings.Skills.SkillPointColor2[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillPointColor2 = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillPointColor2,
            disable = function ()
                return not ((Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_SKILLPOINT_PARTIALPREFIX),
            tooltip = GetString(LUIE_STRING_LAM_CA_SKILLPOINT_PARTIALPREFIX_TP),
            getFunction = function ()
                return Settings.Skills.SkillPointSkyshard
            end,
            setFunction = function (value)
                Settings.Skills.SkillPointSkyshard = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.Skills.SkillPointSkyshard,
            disable = function ()
                return not ((Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_SKILLPOINT_PARTIALBRACKET),
            tooltip = GetString(LUIE_STRING_LAM_CA_SKILLPOINT_PARTIALBRACKET_TP),
            items = SettingsAPI:GetBracketStyleOptions5List(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeBracketStyleIndex(Settings.Skills.SkillPointBracket, Defaults.Skills.SkillPointBracket, 5))
            end,
            setFunction = function (combobox, value, item)
                Settings.Skills.SkillPointBracket = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Skills.SkillPointBracket),
            disable = function ()
                return not ((Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATEDPARTIAL),
            tooltip = GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATEDPARTIAL_TP),
            getFunction = function ()
                return Settings.Skills.SkillPointsPartial
            end,
            setFunction = function (value)
                Settings.Skills.SkillPointsPartial = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.Skills.SkillPointsPartial,
            disable = function ()
                return not ((Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_EXP_HEADER_SKILL_LINES)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Skills.SkillLineUnlockCA
            end,
            setFunction = function (value)
                Settings.Skills.SkillLineUnlockCA = value
            end,
            default = Defaults.Skills.SkillLineUnlockCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Skills.SkillLineUnlockCSA
            end,
            setFunction = function (value)
                Settings.Skills.SkillLineUnlockCSA = value
            end,
            default = Defaults.Skills.SkillLineUnlockCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Skills.SkillLineUnlockAlert
            end,
            setFunction = function (value)
                Settings.Skills.SkillLineUnlockAlert = value
            end,
            default = Defaults.Skills.SkillLineUnlockAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ICON_TP),
            getFunction = function ()
                return Settings.Skills.SkillLineIcon
            end,
            setFunction = function (value)
                Settings.Skills.SkillLineIcon = value
            end,
            default = Defaults.Skills.SkillLineIcon,
            disable = function ()
                return not ((Settings.Skills.SkillLineUnlockCA or Settings.Skills.SkillLineUnlockCSA or Settings.Skills.SkillLineUnlockAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Skills.SkillLineCA
            end,
            setFunction = function (value)
                Settings.Skills.SkillLineCA = value
            end,
            default = Defaults.Skills.SkillLineCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Skills.SkillLineCSA
            end,
            setFunction = function (value)
                Settings.Skills.SkillLineCSA = value
            end,
            default = Defaults.Skills.SkillLineCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Skills.SkillLineAlert
            end,
            setFunction = function (value)
                Settings.Skills.SkillLineAlert = value
            end,
            default = Defaults.Skills.SkillLineAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Skills.SkillAbilityCA
            end,
            setFunction = function (value)
                Settings.Skills.SkillAbilityCA = value
            end,
            default = Defaults.Skills.SkillAbilityCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Skills.SkillAbilityCSA
            end,
            setFunction = function (value)
                Settings.Skills.SkillAbilityCSA = value
            end,
            default = Defaults.Skills.SkillAbilityCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Skills.SkillAbilityAlert
            end,
            setFunction = function (value)
                Settings.Skills.SkillAbilityAlert = value
            end,
            default = Defaults.Skills.SkillAbilityAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Skills.SkillAbilityXpCA
            end,
            setFunction = function (value)
                Settings.Skills.SkillAbilityXpCA = value
                ChatAnnouncements.RegisterAbilityProgressionXpEvents()
            end,
            default = Defaults.Skills.SkillAbilityXpCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Skills.SkillAbilityXpAlert
            end,
            setFunction = function (value)
                Settings.Skills.SkillAbilityXpAlert = value
                ChatAnnouncements.RegisterAbilityProgressionXpEvents()
            end,
            default = Defaults.Skills.SkillAbilityXpAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP_ICON_TP),
            getFunction = function ()
                return Settings.Skills.SkillAbilityXpIcon
            end,
            setFunction = function (value)
                Settings.Skills.SkillAbilityXpIcon = value
            end,
            default = Defaults.Skills.SkillAbilityXpIcon,
            disable = function ()
                return not (Settings.Skills.SkillAbilityXpCA and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP_PROGRESS),
            tooltip = GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP_PROGRESS_TP),
            getFunction = function ()
                return Settings.Skills.SkillAbilityXpProgress
            end,
            setFunction = function (value)
                Settings.Skills.SkillAbilityXpProgress = value
            end,
            default = Defaults.Skills.SkillAbilityXpProgress,
            disable = function ()
                return not ((Settings.Skills.SkillAbilityXpCA or Settings.Skills.SkillAbilityXpAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP_FILTER),
            tooltip = GetString(LUIE_STRING_LAM_CA_SKILL_ABILITY_XP_FILTER_TP),
            min = 0,
            max = 5000,
            step = 50,
            getFunction = function ()
                return Settings.Skills.SkillAbilityXpFilter
            end,
            setFunction = function (value)
                Settings.Skills.SkillAbilityXpFilter = value
            end,
            default = Defaults.Skills.SkillAbilityXpFilter,
            disable = function ()
                return not ((Settings.Skills.SkillAbilityXpCA or Settings.Skills.SkillAbilityXpAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_SKILL_LINE_COLOR),
            getFunction = function ()
                return Settings.Skills.SkillLineColor[1], Settings.Skills.SkillLineColor[2], Settings.Skills.SkillLineColor[3], Settings.Skills.SkillLineColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillLineColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillLineColor,
            disable = function ()
                return not ((Settings.Skills.SkillLineUnlockCA or Settings.Skills.SkillLineUnlockCSA or Settings.Skills.SkillLineUnlockAlert or Settings.Skills.SkillLineCA or Settings.Skills.SkillLineCSA or Settings.Skills.SkillLineAlert or Settings.Skills.SkillAbilityCA or Settings.Skills.SkillAbilityCSA or Settings.Skills.SkillAbilityAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_EXP_HEADER_GUILDREP)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_ICON_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildIcon
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildIcon = value
            end,
            default = Defaults.Skills.SkillGuildIcon,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGECOLOR),
            getFunction = function ()
                return Settings.Skills.SkillGuildColor[1], Settings.Skills.SkillGuildColor[2], Settings.Skills.SkillGuildColor[3], Settings.Skills.SkillGuildColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillGuildColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillGuildColor,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGEFORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGEFORMAT_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildMsg
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildMsg = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.Skills.SkillGuildMsg,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGENAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGENAME_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildRepName
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildRepName = value
                ChatAnnouncements.RegisterXPEvents()
            end,
            default = Defaults.Skills.SkillGuildRepName,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_FG),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_FG_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildFighters
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildFighters = value
            end,
            default = Defaults.Skills.SkillGuildFighters,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_FG_COLOR),
            getFunction = function ()
                return Settings.Skills.SkillGuildColorFG[1], Settings.Skills.SkillGuildColorFG[2], Settings.Skills.SkillGuildColorFG[3], Settings.Skills.SkillGuildColorFG[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillGuildColorFG = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillGuildColorFG,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildFighters)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_THRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_THRESHOLD_TP),
            min = 0,
            max = 5,
            step = 1,
            getFunction = function ()
                return Settings.Skills.SkillGuildThreshold
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildThreshold = value
            end,
            default = Defaults.Skills.SkillGuildThreshold,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildFighters)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_THROTTLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_THROTTLE_TP),
            min = 0,
            max = 5000,
            step = 50,
            getFunction = function ()
                return Settings.Skills.SkillGuildThrottle
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildThrottle = value
            end,
            default = Defaults.Skills.SkillGuildThrottle,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildFighters)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_MG),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_MG_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildMages
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildMages = value
            end,
            default = Defaults.Skills.SkillGuildMages,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_MG_COLOR),
            getFunction = function ()
                return Settings.Skills.SkillGuildColorMG[1], Settings.Skills.SkillGuildColorMG[2], Settings.Skills.SkillGuildColorMG[3], Settings.Skills.SkillGuildColorMG[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillGuildColorMG = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillGuildColorMG,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildMages)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_UD),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_UD_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildUndaunted
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildUndaunted = value
            end,
            default = Defaults.Skills.SkillGuildUndaunted,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_UD_COLOR),
            getFunction = function ()
                return Settings.Skills.SkillGuildColorUD[1], Settings.Skills.SkillGuildColorUD[2], Settings.Skills.SkillGuildColorUD[3], Settings.Skills.SkillGuildColorUD[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillGuildColorUD = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillGuildColorUD,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildUndaunted)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_TG),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_TG_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildThieves
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildThieves = value
            end,
            default = Defaults.Skills.SkillGuildThieves,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_TG_COLOR),
            getFunction = function ()
                return Settings.Skills.SkillGuildColorTG[1], Settings.Skills.SkillGuildColorTG[2], Settings.Skills.SkillGuildColorTG[3], Settings.Skills.SkillGuildColorTG[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillGuildColorTG = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillGuildColorTG,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildThieves)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_DB),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_DB_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildDarkBrotherhood
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildDarkBrotherhood = value
            end,
            default = Defaults.Skills.SkillGuildDarkBrotherhood,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_DB_COLOR),
            getFunction = function ()
                return Settings.Skills.SkillGuildColorDB[1], Settings.Skills.SkillGuildColorDB[2], Settings.Skills.SkillGuildColorDB[3], Settings.Skills.SkillGuildColorDB[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillGuildColorDB = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillGuildColorDB,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildDarkBrotherhood)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_PO),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_PO_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildPsijicOrder
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildPsijicOrder = value
            end,
            default = Defaults.Skills.SkillGuildPsijicOrder,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_PO_COLOR),
            getFunction = function ()
                return Settings.Skills.SkillGuildColorPO[1], Settings.Skills.SkillGuildColorPO[2], Settings.Skills.SkillGuildColorPO[3], Settings.Skills.SkillGuildColorPO[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Skills.SkillGuildColorPO = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Skills.SkillGuildColorPO,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildPsijicOrder)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_GUILDREP_ALERT),
            tooltip = GetString(LUIE_STRING_LAM_CA_GUILDREP_ALERT_TP),
            getFunction = function ()
                return Settings.Skills.SkillGuildAlert
            end,
            setFunction = function (value)
                Settings.Skills.SkillGuildAlert = value
            end,
            default = Defaults.Skills.SkillGuildAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_COMPANION_LEVEL_HEADER)
        }
    end)

    -- Build Collectible/Lorebooks Announcements Section
    buildSectionSettings("Collectible", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_COLLECTIBLE),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_COL_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleCA
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleCA = value
            end,
            default = Defaults.Collectibles.CollectibleCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleCSA
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleCSA = value
            end,
            default = Defaults.Collectibles.CollectibleCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleAlert
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleAlert = value
            end,
            default = Defaults.Collectibles.CollectibleAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ICON_TP),
            getFunction = function ()
                return Settings.Collectibles.CollectibleIcon
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleIcon = value
            end,
            default = Defaults.Collectibles.CollectibleIcon,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_COLLECTIBLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_COLLECTIBLE_TP),
            items = SettingsAPI:GetLinkBracketDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeLinkBracketDisplayIndex(Settings.BracketOptionCollectible, 1))
            end,
            setFunction = function (combobox, value, item)
                Settings.BracketOptionCollectible = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BracketOptionCollectible),
            disable = function ()
                return not ((Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_COLOR_ONE),
            getFunction = function ()
                return Settings.Collectibles.CollectibleColor1[1], Settings.Collectibles.CollectibleColor1[2], Settings.Collectibles.CollectibleColor1[3], Settings.Collectibles.CollectibleColor1[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Collectibles.CollectibleColor1 = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Collectibles.CollectibleColor1,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_COLOR_TWO),
            getFunction = function ()
                return Settings.Collectibles.CollectibleColor2[1], Settings.Collectibles.CollectibleColor2[2], Settings.Collectibles.CollectibleColor2[3], Settings.Collectibles.CollectibleColor2[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Collectibles.CollectibleColor2 = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Collectibles.CollectibleColor2,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_MESSAGEPREFIX),
            tooltip = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_MESSAGEPREFIX_TP),
            getFunction = function ()
                return Settings.Collectibles.CollectiblePrefix
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectiblePrefix = value
            end,
            default = Defaults.Collectibles.CollectiblePrefix,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_BRACKET),
            tooltip = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_BRACKET_TP),
            items = SettingsAPI:GetBracketStyleOptions5List(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeBracketStyleIndex(Settings.Collectibles.CollectibleBracket, Defaults.Collectibles.CollectibleBracket, 5))
            end,
            setFunction = function (combobox, value, item)
                Settings.Collectibles.CollectibleBracket = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Collectibles.CollectibleBracket),
            disable = function ()
                return not ((Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_CATEGORY),
            tooltip = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_CATEGORY_TP),
            getFunction = function ()
                return Settings.Collectibles.CollectibleCategory
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleCategory = value
            end,
            default = Defaults.Collectibles.CollectibleCategory,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_SUBCATEGORY),
            tooltip = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_SUBCATEGORY_TP),
            getFunction = function ()
                return Settings.Collectibles.CollectibleSubcategory
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleSubcategory = value
            end,
            default = Defaults.Collectibles.CollectibleSubcategory,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUseCA
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleUseCA = value
            end,
            default = Defaults.Collectibles.CollectibleUseCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUseAlert
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleUseAlert = value
            end,
            default = Defaults.Collectibles.CollectibleUseAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_PET_NICKNAME),
            tooltip = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_PET_NICKNAME_TP),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUsePetNickname
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleUsePetNickname = value
            end,
            default = Defaults.Collectibles.CollectibleUsePetNickname,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleUseCA or Settings.Collectibles.CollectibleUseAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ICON_TP),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUseIcon
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleUseIcon = value
            end,
            default = Defaults.Collectibles.CollectibleUseIcon,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleUseCA or Settings.Collectibles.CollectibleUseAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_COLLECTIBLE),
            tooltip = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_COLLECTIBLE_TP),
            items = SettingsAPI:GetLinkBracketDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeLinkBracketDisplayIndex(Settings.BracketOptionCollectibleUse, 1))
            end,
            setFunction = function (combobox, value, item)
                Settings.BracketOptionCollectibleUse = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BracketOptionCollectibleUse),
            disable = function ()
                return not ((Settings.Collectibles.CollectibleUseCA or Settings.Collectibles.CollectibleUseAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_COLOR_ONE),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUseColor[1], Settings.Collectibles.CollectibleUseColor[2], Settings.Collectibles.CollectibleUseColor[3], Settings.Collectibles.CollectibleUseColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Collectibles.CollectibleUseColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Collectibles.CollectibleUseColor,
            disable = function ()
                return not ((Settings.Collectibles.CollectibleUseCA or Settings.Collectibles.CollectibleUseAlert) and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY), GetCollectibleCategoryInfoName(3)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY_TP), GetCollectibleCategoryInfoName(3)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUseCategory3
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleUseCategory3 = value
            end,
            default = Defaults.Collectibles.CollectibleUseCategory3,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY), GetCollectibleCategoryInfoName(7)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY_TP), GetCollectibleCategoryInfoName(7)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUseCategory7
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleUseCategory7 = value
            end,
            default = Defaults.Collectibles.CollectibleUseCategory7,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY), GetCollectibleCategoryInfoName(10)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY_TP), GetCollectibleCategoryInfoName(10)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUseCategory10
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleUseCategory10 = value
            end,
            default = Defaults.Collectibles.CollectibleUseCategory10,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY), GetCollectibleCategoryInfoName(12)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY_TP), GetCollectibleCategoryInfoName(12)),
            getFunction = function ()
                return Settings.Collectibles.CollectibleUseCategory12
            end,
            setFunction = function (value)
                Settings.Collectibles.CollectibleUseCategory12 = value
            end,
            default = Defaults.Collectibles.CollectibleUseCategory12,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_LORE_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_LOREBOOK),
            tooltip = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_LOREBOOK_TP),
            items = SettingsAPI:GetLinkBracketDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeLinkBracketDisplayIndex(Settings.BracketOptionLorebook, 1))
            end,
            setFunction = function (combobox, value, item)
                Settings.BracketOptionLorebook = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BracketOptionLorebook),
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Lorebooks.LorebookCA
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookCA = value
            end,
            default = Defaults.Lorebooks.LorebookCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Lorebooks.LorebookCSA
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookCSA = value
            end,
            default = Defaults.Lorebooks.LorebookCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_CSA_LOREONLY),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOREBOOK_CSA_LOREONLY_TP),
            getFunction = function ()
                return Settings.Lorebooks.LorebookCSALoreOnly
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookCSALoreOnly = value
            end,
            default = Defaults.Lorebooks.LorebookCSALoreOnly,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Lorebooks.LorebookCSA)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Lorebooks.LorebookAlert
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookAlert = value
            end,
            default = Defaults.Lorebooks.LorebookAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Lorebooks.LorebookCollectionCA
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookCollectionCA = value
            end,
            default = Defaults.Lorebooks.LorebookCollectionCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Lorebooks.LorebookCollectionCSA
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookCollectionCSA = value
            end,
            default = Defaults.Lorebooks.LorebookCollectionCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Lorebooks.LorebookCollectionAlert
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookCollectionAlert = value
            end,
            default = Defaults.Lorebooks.LorebookCollectionAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOREBOOK_ICON_TP),
            getFunction = function ()
                return Settings.Lorebooks.LorebookIcon
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookIcon = value
            end,
            default = Defaults.Lorebooks.LorebookIcon,
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLOR1),
            getFunction = function ()
                return Settings.Lorebooks.LorebookColor1[1], Settings.Lorebooks.LorebookColor1[2], Settings.Lorebooks.LorebookColor1[3], Settings.Lorebooks.LorebookColor1[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Lorebooks.LorebookColor1 = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Lorebooks.LorebookColor1,
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLOR2),
            getFunction = function ()
                return Settings.Lorebooks.LorebookColor2[1], Settings.Lorebooks.LorebookColor2[2], Settings.Lorebooks.LorebookColor2[3], Settings.Lorebooks.LorebookColor2[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Lorebooks.LorebookColor2 = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Lorebooks.LorebookColor2,
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX1),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX1_TP),
            getFunction = function ()
                return Settings.Lorebooks.LorebookPrefix1
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookPrefix1 = value
            end,
            default = Defaults.Lorebooks.LorebookPrefix1,
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX2),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX2_TP),
            getFunction = function ()
                return Settings.Lorebooks.LorebookPrefix2
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookPrefix2 = value
            end,
            default = Defaults.Lorebooks.LorebookPrefix2,
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX_COLLECTION),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX_COLLECTION_TP),
            getFunction = function ()
                return Settings.Lorebooks.LorebookCollectionPrefix
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookCollectionPrefix = value
            end,
            default = Defaults.Lorebooks.LorebookCollectionPrefix,
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_CATEGORY_BRACKET),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOREBOOK_CATEGORY_BRACKET_TP),
            items = SettingsAPI:GetBracketStyleOptions5List(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeBracketStyleIndex(Settings.Lorebooks.LorebookBracket, Defaults.Lorebooks.LorebookBracket, 5))
            end,
            setFunction = function (combobox, value, item)
                Settings.Lorebooks.LorebookBracket = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Lorebooks.LorebookBracket),
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_CATEGORY),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOREBOOK_CATEGORY_TP),
            getFunction = function ()
                return Settings.Lorebooks.LorebookCategory
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookCategory = value
            end,
            default = Defaults.Lorebooks.LorebookCategory,
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_LOREBOOK_NOSHOWHIDE),
            tooltip = GetString(LUIE_STRING_LAM_CA_LOREBOOK_NOSHOWHIDE_TP),
            getFunction = function ()
                return Settings.Lorebooks.LorebookShowHidden
            end,
            setFunction = function (value)
                Settings.Lorebooks.LorebookShowHidden = value
            end,
            default = Defaults.Lorebooks.LorebookShowHidden,
            disable = function ()
                return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }
    end)

    -- Build Antiquities Announcements Section
    buildSectionSettings("Antiquities", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_ANTIQUITY),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_LEAD_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Antiquities.AntiquityCA
            end,
            setFunction = function (value)
                Settings.Antiquities.AntiquityCA = value
            end,
            default = Defaults.Antiquities.AntiquityCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Antiquities.AntiquityCSA
            end,
            setFunction = function (value)
                Settings.Antiquities.AntiquityCSA = value
            end,
            default = Defaults.Antiquities.AntiquityCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Antiquities.AntiquityAlert
            end,
            setFunction = function (value)
                Settings.Antiquities.AntiquityAlert = value
            end,
            default = Defaults.Antiquities.AntiquityAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_BRACKET),
            tooltip = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_BRACKET_TP),
            items = SettingsAPI:GetLinkBracketDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeLinkBracketDisplayIndex(Settings.Antiquities.AntiquityBracket, 1))
            end,
            setFunction = function (combobox, value, item)
                Settings.Antiquities.AntiquityBracket = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Antiquities.AntiquityBracket),
            disable = function ()
                return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ICON_TP),
            getFunction = function ()
                return Settings.Antiquities.AntiquityIcon
            end,
            setFunction = function (value)
                Settings.Antiquities.AntiquityIcon = value
            end,
            default = Defaults.Antiquities.AntiquityIcon,
            disable = function ()
                return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_COLOR),
            getFunction = function ()
                return Settings.Antiquities.AntiquityColor[1], Settings.Antiquities.AntiquityColor[2], Settings.Antiquities.AntiquityColor[3], Settings.Antiquities.AntiquityColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Antiquities.AntiquityColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Antiquities.AntiquityColor,
            disable = function ()
                return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_PREFIX),
            tooltip = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_PREFIX_TP),
            getFunction = function ()
                return Settings.Antiquities.AntiquityPrefix
            end,
            setFunction = function (value)
                Settings.Antiquities.AntiquityPrefix = value
            end,
            default = Defaults.Antiquities.AntiquityPrefix,
            disable = function ()
                return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_PREFIX_BRACKET),
            tooltip = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_PREFIX_BRACKET_TP),
            items = SettingsAPI:GetBracketStyleOptions5List(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeBracketStyleIndex(Settings.Antiquities.AntiquityPrefixBracket, Defaults.Antiquities.AntiquityPrefixBracket, 5))
            end,
            setFunction = function (combobox, value, item)
                Settings.Antiquities.AntiquityPrefixBracket = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Antiquities.AntiquityPrefixBracket),
            disable = function ()
                return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_SUFFIX),
            tooltip = GetString(LUIE_STRING_LAM_CA_ANTIQUITY_SUFFIX_TP),
            getFunction = function ()
                return Settings.Antiquities.AntiquitySuffix
            end,
            setFunction = function (value)
                Settings.Antiquities.AntiquitySuffix = value
            end,
            default = Defaults.Antiquities.AntiquitySuffix,
            disable = function ()
                return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }
    end)

    -- Build Achievements Announcements Section
    buildSectionSettings("Achievements", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_ACHIEVEMENT),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Achievement.AchievementUpdateCA
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementUpdateCA = value
                ChatAnnouncements.RegisterAchievementsEvent()
            end,
            default = Defaults.Achievement.AchievementUpdateCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Achievement.AchievementUpdateAlert
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementUpdateAlert = value
                ChatAnnouncements.RegisterAchievementsEvent()
            end,
            default = Defaults.Achievement.AchievementUpdateAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_DETAILINFO),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_DETAILINFO_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementDetails
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementDetails = value
            end,
            default = Defaults.Achievement.AchievementDetails,
            disable = function ()
                return not (Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_STEPSIZE),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_STEPSIZE_TP),
            min = 0,
            max = 50,
            step = 1,
            getFunction = function ()
                return Settings.Achievement.AchievementStep
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementStep = value
            end,
            default = Defaults.Achievement.AchievementStep,
            disable = function ()
                return not (Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Achievement.AchievementCompleteCA
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementCompleteCA = value
                ChatAnnouncements.RegisterAchievementsEvent()
            end,
            default = Defaults.Achievement.AchievementCompleteCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Achievement.AchievementCompleteCSA
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementCompleteCSA = value
                ChatAnnouncements.RegisterAchievementsEvent()
            end,
            default = Defaults.Achievement.AchievementCompleteCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_CSA_ALWAYS),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_CSA_ALWAYS_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementCompleteAlwaysCSA
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementCompleteAlwaysCSA = value
                ChatAnnouncements.RegisterAchievementsEvent()
            end,
            default = Defaults.Achievement.AchievementCompleteAlwaysCSA,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Achievement.AchievementCompleteCSA)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Achievement.AchievementCompleteAlert
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementCompleteAlert = value
                ChatAnnouncements.RegisterAchievementsEvent()
            end,
            default = Defaults.Achievement.AchievementCompleteAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETEPERCENT),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETEPERCENT_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementCompPercentage
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementCompPercentage = value
            end,
            default = Defaults.Achievement.AchievementCompPercentage,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_ICON_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementIcon
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementIcon = value
            end,
            default = Defaults.Achievement.AchievementIcon,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_ACHIEVEMENT),
            tooltip = GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_ACHIEVEMENT_TP),
            items = SettingsAPI:GetLinkBracketDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeLinkBracketDisplayIndex(Settings.BracketOptionAchievement, 1))
            end,
            setFunction = function (combobox, value, item)
                Settings.BracketOptionAchievement = item.data
            end,
            default = Defaults.BracketOptionAchievement,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COLOR1),
            getFunction = function ()
                return Settings.Achievement.AchievementColor1[1], Settings.Achievement.AchievementColor1[2], Settings.Achievement.AchievementColor1[3], Settings.Achievement.AchievementColor1[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Achievement.AchievementColor1 = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Achievement.AchievementColor1,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COLOR2),
            getFunction = function ()
                return Settings.Achievement.AchievementColor2[1], Settings.Achievement.AchievementColor2[2], Settings.Achievement.AchievementColor2[3], Settings.Achievement.AchievementColor2[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Achievement.AchievementColor2 = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Achievement.AchievementColor2,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_PROGMSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_PROGMSG_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementProgressMsg
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementProgressMsg = value
            end,
            default = Defaults.Achievement.AchievementProgressMsg,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETEMSG),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETEMSG_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementCompleteMsg
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementCompleteMsg = value
            end,
            default = Defaults.Achievement.AchievementCompleteMsg,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_SHOWCATEGORY),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_SHOWCATEGORY_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementCategory
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementCategory = value
            end,
            default = Defaults.Achievement.AchievementCategory,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_SHOWSUBCATEGORY),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_SHOWSUBCATEGORY_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementSubcategory
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementSubcategory = value
            end,
            default = Defaults.Achievement.AchievementSubcategory,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_BRACKET),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_BRACKET_TP),
            items = SettingsAPI:GetBracketStyleOptions5List(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeBracketStyleIndex(Settings.Achievement.AchievementBracketOptions, Defaults.Achievement.AchievementBracketOptions, 5))
            end,
            setFunction = function (combobox, value, item)
                Settings.Achievement.AchievementBracketOptions = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Achievement.AchievementBracketOptions),
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORYBRACKET),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORYBRACKET_TP),
            items = SettingsAPI:GetBracketStyleOptions4List(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeBracketStyleIndex(Settings.Achievement.AchievementCatBracketOptions, Defaults.Achievement.AchievementCatBracketOptions, 4))
            end,
            setFunction = function (combobox, value, item)
                Settings.Achievement.AchievementCatBracketOptions = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Achievement.AchievementCatBracketOptions),
            disable = function ()
                return not (Settings.Achievement.AchievementCategory or Settings.Achievement.AchievementSubcategory) or not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COLORPROGRESS),
            tooltip = GetString(LUIE_STRING_LAM_CA_ACHIEVE_COLORPROGRESS_TP),
            getFunction = function ()
                return Settings.Achievement.AchievementColorProgress
            end,
            setFunction = function (value)
                Settings.Achievement.AchievementColorProgress = value
            end,
            default = Defaults.Achievement.AchievementColorProgress,
            disable = function ()
                return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORY_HEADER)
        }

        -- Dynamic Achievement Categories
        for i = 1, GetNumAchievementCategories() do
            local name = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORY), GetAchievementCategoryInfoName(i))
            local tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORY_TP), GetAchievementCategoryInfoName(i))
            settings[#settings + 1] =
            {
                type = LHAS.ST_CHECKBOX,
                label = name,
                tooltip = tooltip,
                getFunction = function ()
                    return not Settings.Achievement.AchievementCategoryIgnore[i]
                end,
                setFunction = function (value)
                    if value then
                        Settings.Achievement.AchievementCategoryIgnore[i] = nil
                    else
                        Settings.Achievement.AchievementCategoryIgnore[i] = true
                    end
                end,
                default = (Defaults.Achievement.AchievementCategoryIgnore[i] == nil),
                disable = function ()
                    return not LUIE.SV.ChatAnnouncements_Enable
                end
            }
        end
    end)

    -- Build Quest Announcements Section
    buildSectionSettings("Quest", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTSHARE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTSHARE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Quests.QuestShareCA
            end,
            setFunction = function (value)
                Settings.Quests.QuestShareCA = value
            end,
            default = Defaults.Quests.QuestShareCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTSHARE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTSHARE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Quests.QuestShareAlert
            end,
            setFunction = function (value)
                Settings.Quests.QuestShareAlert = value
            end,
            default = Defaults.Quests.QuestShareAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Quests.QuestLocDiscoveryCA
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocDiscoveryCA = value
            end,
            default = Defaults.Quests.QuestLocDiscoveryCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Quests.QuestLocDiscoveryCSA
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocDiscoveryCSA = value
            end,
            default = Defaults.Quests.QuestLocDiscoveryCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Quests.QuestLocDiscoveryAlert
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocDiscoveryAlert = value
            end,
            default = Defaults.Quests.QuestLocDiscoveryAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Quests.QuestLocObjectiveCA
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocObjectiveCA = value
            end,
            default = Defaults.Quests.QuestLocObjectiveCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Quests.QuestLocObjectiveCSA
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocObjectiveCSA = value
            end,
            default = Defaults.Quests.QuestLocObjectiveCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Quests.QuestLocObjectiveAlert
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocObjectiveAlert = value
            end,
            default = Defaults.Quests.QuestLocObjectiveAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Quests.QuestLocCompleteCA
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocCompleteCA = value
            end,
            default = Defaults.Quests.QuestLocCompleteCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Quests.QuestLocCompleteCSA
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocCompleteCSA = value
            end,
            default = Defaults.Quests.QuestLocCompleteCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Quests.QuestLocCompleteAlert
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocCompleteAlert = value
            end,
            default = Defaults.Quests.QuestLocCompleteAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Quests.QuestFailCA
            end,
            setFunction = function (value)
                Settings.Quests.QuestFailCA = value
            end,
            default = Defaults.Quests.QuestFailCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Quests.QuestFailCSA
            end,
            setFunction = function (value)
                Settings.Quests.QuestFailCSA = value
            end,
            default = Defaults.Quests.QuestFailCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Quests.QuestFailAlert
            end,
            setFunction = function (value)
                Settings.Quests.QuestFailAlert = value
            end,
            default = Defaults.Quests.QuestFailAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Quests.QuestObjUpdateCA
            end,
            setFunction = function (value)
                Settings.Quests.QuestObjUpdateCA = value
            end,
            default = Defaults.Quests.QuestObjUpdateCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Quests.QuestObjUpdateCSA
            end,
            setFunction = function (value)
                Settings.Quests.QuestObjUpdateCSA = value
            end,
            default = Defaults.Quests.QuestObjUpdateCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Quests.QuestObjUpdateAlert
            end,
            setFunction = function (value)
                Settings.Quests.QuestObjUpdateAlert = value
            end,
            default = Defaults.Quests.QuestObjUpdateAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Quests.QuestObjCompleteCA
            end,
            setFunction = function (value)
                Settings.Quests.QuestObjCompleteCA = value
            end,
            default = Defaults.Quests.QuestObjCompleteCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Quests.QuestObjCompleteCSA
            end,
            setFunction = function (value)
                Settings.Quests.QuestObjCompleteCSA = value
            end,
            default = Defaults.Quests.QuestObjCompleteCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Quests.QuestObjCompleteAlert
            end,
            setFunction = function (value)
                Settings.Quests.QuestObjCompleteAlert = value
            end,
            default = Defaults.Quests.QuestObjCompleteAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTICON),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTICON_TP),
            getFunction = function ()
                return Settings.Quests.QuestIcon
            end,
            setFunction = function (value)
                Settings.Quests.QuestIcon = value
            end,
            default = Defaults.Quests.QuestIcon,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COLOR1),
            getFunction = function ()
                return Settings.Quests.QuestColorLocName[1], Settings.Quests.QuestColorLocName[2], Settings.Quests.QuestColorLocName[3], Settings.Quests.QuestColorLocName[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Quests.QuestColorLocName = { r, g, b }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Quests.QuestColorLocName,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COLOR2),
            getFunction = function ()
                return Settings.Quests.QuestColorLocDescription[1], Settings.Quests.QuestColorLocDescription[2], Settings.Quests.QuestColorLocDescription[3], Settings.Quests.QuestColorLocDescription[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Quests.QuestColorLocDescription = { r, g, b }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Quests.QuestColorLocDescription,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COLOR3),
            getFunction = function ()
                return Settings.Quests.QuestColorName[1], Settings.Quests.QuestColorName[2], Settings.Quests.QuestColorName[3], Settings.Quests.QuestColorName[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Quests.QuestColorName = { r, g, b }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Quests.QuestColorName,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_COLOR4),
            getFunction = function ()
                return Settings.Quests.QuestColorDescription[1], Settings.Quests.QuestColorDescription[2], Settings.Quests.QuestColorDescription[3], Settings.Quests.QuestColorDescription[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Quests.QuestColorDescription = { r, g, b }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Quests.QuestColorDescription,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTLONG),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTLONG_TP),
            getFunction = function ()
                return Settings.Quests.QuestLong
            end,
            setFunction = function (value)
                Settings.Quests.QuestLong = value
            end,
            default = Defaults.Quests.QuestLong,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTOBJECTIVELONG),
            tooltip = GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTOBJECTIVELONG_TP),
            getFunction = function ()
                return Settings.Quests.QuestLocLong
            end,
            setFunction = function (value)
                Settings.Quests.QuestLocLong = value
            end,
            default = Defaults.Quests.QuestLocLong,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }
    end)

    buildSectionSettings("QuestCounterFilters", function (settings)
        ChatAnnouncements.AppendQuestCounterFilterSettings(settings, Settings, Defaults, panel, SettingsAPI)
    end)

    -- Build Social Announcements Section
    buildSectionSettings("Social", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_SOCIAL),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                local social = LUIE.SV.ChatOutput and LUIE.SV.ChatOutput.Social
                return social and social.FriendIgnoreCA
            end,
            setFunction = function (value)
                LUIE.SV.ChatOutput = LUIE.SV.ChatOutput or {}
                LUIE.SV.ChatOutput.Social = LUIE.SV.ChatOutput.Social or {}
                LUIE.SV.ChatOutput.Social.FriendIgnoreCA = value
                LUIE.ChatAnnouncements.ChainChatRouterSocialSuppressions()
            end,
            default = LUIE.Defaults.ChatOutput.Social.FriendIgnoreCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.FriendIgnoreAlert
            end,
            setFunction = function (value)
                Settings.Social.FriendIgnoreAlert = value
            end,
            default = Defaults.Social.FriendIgnoreAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                local social = LUIE.SV.ChatOutput and LUIE.SV.ChatOutput.Social
                return social and social.FriendStatusCA
            end,
            setFunction = function (value)
                LUIE.SV.ChatOutput = LUIE.SV.ChatOutput or {}
                LUIE.SV.ChatOutput.Social = LUIE.SV.ChatOutput.Social or {}
                LUIE.SV.ChatOutput.Social.FriendStatusCA = value
                LUIE.ChatAnnouncements.ChainChatRouterSocialSuppressions()
            end,
            default = LUIE.Defaults.ChatOutput.Social.FriendStatusCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.FriendStatusAlert
            end,
            setFunction = function (value)
                Settings.Social.FriendStatusAlert = value
            end,
            default = Defaults.Social.FriendStatusAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF_FORMAT_TP),
            items = SettingsAPI:GetFriendStatusNameFormatOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeFriendStatusNameFormatIndex(Settings.Social.FriendStatusNameFormat, Defaults.Social.FriendStatusNameFormat))
            end,
            setFunction = function (combobox, value, item)
                Settings.Social.FriendStatusNameFormat = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Social.FriendStatusNameFormat),
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Social.GuildCA
            end,
            setFunction = function (value)
                Settings.Social.GuildCA = value
            end,
            default = Defaults.Social.GuildCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.GuildAlert
            end,
            setFunction = function (value)
                Settings.Social.GuildAlert = value
            end,
            default = Defaults.Social.GuildAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANK), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANK_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Social.GuildRankCA
            end,
            setFunction = function (value)
                Settings.Social.GuildRankCA = value
            end,
            default = Defaults.Social.GuildRankCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANK), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANK_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.GuildRankAlert
            end,
            setFunction = function (value)
                Settings.Social.GuildRankAlert = value
            end,
            default = Defaults.Social.GuildRankAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANKOPTIONS),
            tooltip = GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANKOPTIONS_TP),
            items = SettingsAPI:GetGuildRankDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeGuildRankDisplayIndex(Settings.Social.GuildRankDisplayOptions, Defaults.Social.GuildRankDisplayOptions))
            end,
            setFunction = function (combobox, value, item)
                Settings.Social.GuildRankDisplayOptions = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Social.GuildRankDisplayOptions),
            disable = function ()
                return not (Settings.Social.GuildRankCA or Settings.Social.GuildRankAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ADMIN), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ADMIN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Social.GuildManageCA
            end,
            setFunction = function (value)
                Settings.Social.GuildManageCA = value
            end,
            default = Defaults.Social.GuildManageCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ADMIN), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ADMIN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.GuildManageAlert
            end,
            setFunction = function (value)
                Settings.Social.GuildManageAlert = value
            end,
            default = Defaults.Social.GuildManageAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ICONS),
            tooltip = GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ICONS_TP),
            getFunction = function ()
                return Settings.Social.GuildIcon
            end,
            setFunction = function (value)
                Settings.Social.GuildIcon = value
            end,
            default = Defaults.Social.GuildIcon,
            disable = function ()
                return not (Settings.Social.GuildCA or Settings.Social.GuildAlert or Settings.Social.GuildRankCA or Settings.Social.GuildRankAlert or Settings.Social.GuildManageCA or Settings.Social.GuildManageAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_COLOR),
            getFunction = function ()
                return Settings.Social.GuildColor[1], Settings.Social.GuildColor[2], Settings.Social.GuildColor[3], Settings.Social.GuildColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Social.GuildColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Social.GuildColor,
            disable = function ()
                return not (Settings.Social.GuildCA or Settings.Social.GuildAlert or Settings.Social.GuildRankCA or Settings.Social.GuildRankAlert or Settings.Social.GuildManageCA or Settings.Social.GuildManageAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_COLOR_ALLIANCE),
            tooltip = GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_COLOR_ALLIANCE_TP),
            getFunction = function ()
                return Settings.Social.GuildAllianceColor
            end,
            setFunction = function (value)
                Settings.Social.GuildAllianceColor = value
            end,
            default = Defaults.Social.GuildAllianceColor,
            disable = function ()
                return not (Settings.Social.GuildCA or Settings.Social.GuildAlert or Settings.Social.GuildRankCA or Settings.Social.GuildRankAlert or Settings.Social.GuildManageCA or Settings.Social.GuildManageAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.NotificationTradeCA
            end,
            setFunction = function (value)
                Settings.Notify.NotificationTradeCA = value
            end,
            default = Defaults.Notify.NotificationTradeCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.NotificationTradeAlert
            end,
            setFunction = function (value)
                Settings.Notify.NotificationTradeAlert = value
            end,
            default = Defaults.Notify.NotificationTradeAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Social.DuelCA
            end,
            setFunction = function (value)
                Settings.Social.DuelCA = value
            end,
            default = Defaults.Social.DuelCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.DuelAlert
            end,
            setFunction = function (value)
                Settings.Social.DuelAlert = value
            end,
            default = Defaults.Social.DuelAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Social.DuelStartCA
            end,
            setFunction = function (value)
                Settings.Social.DuelStartCA = value
            end,
            default = Defaults.Social.DuelStartCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_TPCSA), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Social.DuelStartCSA
            end,
            setFunction = function (value)
                Settings.Social.DuelStartCSA = value
            end,
            default = Defaults.Social.DuelStartCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.DuelStartAlert
            end,
            setFunction = function (value)
                Settings.Social.DuelStartAlert = value
            end,
            default = Defaults.Social.DuelStartAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_OPTION),
            tooltip = GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_OPTION_TP),
            items = SettingsAPI:GetDuelStartOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeDuelStartDisplayIndex(Settings.Social.DuelStartOptions, 1))
            end,
            setFunction = function (combobox, value, item)
                Settings.Social.DuelStartOptions = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(1),
            disable = function ()
                return not (Settings.Social.DuelStartCA or Settings.Social.DuelStartCSA or Settings.Social.DuelStartAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Social.DuelWonCA
            end,
            setFunction = function (value)
                Settings.Social.DuelWonCA = value
            end,
            default = Defaults.Social.DuelWonCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Social.DuelWonCSA
            end,
            setFunction = function (value)
                Settings.Social.DuelWonCSA = value
            end,
            default = Defaults.Social.DuelWonCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.DuelWonAlert
            end,
            setFunction = function (value)
                Settings.Social.DuelWonAlert = value
            end,
            default = Defaults.Social.DuelWonAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Social.DuelBoundaryCA
            end,
            setFunction = function (value)
                Settings.Social.DuelBoundaryCA = value
            end,
            default = Defaults.Social.DuelBoundaryCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Social.DuelBoundaryCSA
            end,
            setFunction = function (value)
                Settings.Social.DuelBoundaryCSA = value
            end,
            default = Defaults.Social.DuelBoundaryCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.DuelBoundaryAlert
            end,
            setFunction = function (value)
                Settings.Social.DuelBoundaryAlert = value
            end,
            default = Defaults.Social.DuelBoundaryAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_SOCIAL_MARA_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Social.PledgeOfMaraCA
            end,
            setFunction = function (value)
                Settings.Social.PledgeOfMaraCA = value
            end,
            default = Defaults.Social.PledgeOfMaraCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Social.PledgeOfMaraCSA
            end,
            setFunction = function (value)
                Settings.Social.PledgeOfMaraCSA = value
            end,
            default = Defaults.Social.PledgeOfMaraCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Social.PledgeOfMaraAlert
            end,
            setFunction = function (value)
                Settings.Social.PledgeOfMaraAlert = value
            end,
            default = Defaults.Social.PledgeOfMaraAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_MISC_MARA_ALERT),
            tooltip = GetString(LUIE_STRING_LAM_CA_MISC_MARA_ALERT_TP),
            getFunction = function ()
                return Settings.Social.PledgeOfMaraAlertOnlyFail
            end,
            setFunction = function (value)
                Settings.Social.PledgeOfMaraAlertOnlyFail = value
            end,
            default = Defaults.Social.PledgeOfMaraAlertOnlyFail,
            disable = function ()
                return not (Settings.Social.PledgeOfMaraAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }
    end)

    -- Build Group Announcements Section
    buildSectionSettings("Group", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_GROUP_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_GROUP),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_GROUP_BASE_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupCA
            end,
            setFunction = function (value)
                Settings.Group.GroupCA = value
            end,
            default = Defaults.Group.GroupCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupAlert = value
            end,
            default = Defaults.Group.GroupAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_GROUP_LFG_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGREADY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGREADY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupLFGCA
            end,
            setFunction = function (value)
                Settings.Group.GroupLFGCA = value
            end,
            default = Defaults.Group.GroupLFGCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGREADY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGREADY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupLFGAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupLFGAlert = value
            end,
            default = Defaults.Group.GroupLFGAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGQUEUE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGQUEUE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupLFGQueueCA
            end,
            setFunction = function (value)
                Settings.Group.GroupLFGQueueCA = value
            end,
            default = Defaults.Group.GroupLFGQueueCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGQUEUE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGQUEUE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupLFGQueueAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupLFGQueueAlert = value
            end,
            default = Defaults.Group.GroupLFGQueueAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGVOTE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGVOTE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupVoteCA
            end,
            setFunction = function (value)
                Settings.Group.GroupVoteCA = value
            end,
            default = Defaults.Group.GroupVoteCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGVOTE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGVOTE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupVoteAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupVoteAlert = value
            end,
            default = Defaults.Group.GroupVoteAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupLFGCompleteCA
            end,
            setFunction = function (value)
                Settings.Group.GroupLFGCompleteCA = value
            end,
            default = Defaults.Group.GroupLFGCompleteCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Group.GroupLFGCompleteCSA
            end,
            setFunction = function (value)
                Settings.Group.GroupLFGCompleteCSA = value
            end,
            default = Defaults.Group.GroupLFGCompleteCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupLFGCompleteAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupLFGCompleteAlert = value
            end,
            default = Defaults.Group.GroupLFGCompleteAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_GROUP_RAID_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupRaidCA
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidCA = value
            end,
            default = Defaults.Group.GroupRaidCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Group.GroupRaidCSA
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidCSA = value
            end,
            default = Defaults.Group.GroupRaidCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupRaidAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidAlert = value
            end,
            default = Defaults.Group.GroupRaidAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupRaidScoreCA
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidScoreCA = value
            end,
            default = Defaults.Group.GroupRaidScoreCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Group.GroupRaidScoreCSA
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidScoreCSA = value
            end,
            default = Defaults.Group.GroupRaidScoreCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupRaidScoreAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidScoreAlert = value
            end,
            default = Defaults.Group.GroupRaidScoreAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupRaidBestScoreCA
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidBestScoreCA = value
            end,
            default = Defaults.Group.GroupRaidBestScoreCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Group.GroupRaidBestScoreCSA
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidBestScoreCSA = value
            end,
            default = Defaults.Group.GroupRaidBestScoreCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupRaidBestScoreAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidBestScoreAlert = value
            end,
            default = Defaults.Group.GroupRaidBestScoreAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Group.GroupRaidReviveCA
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidReviveCA = value
            end,
            default = Defaults.Group.GroupRaidReviveCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Group.GroupRaidReviveCSA
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidReviveCSA = value
            end,
            default = Defaults.Group.GroupRaidReviveCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Group.GroupRaidReviveAlert
            end,
            setFunction = function (value)
                Settings.Group.GroupRaidReviveAlert = value
            end,
            default = Defaults.Group.GroupRaidReviveAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }
    end)

    -- Build Display Announcements Section
    buildSectionSettings("Display", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_DISPLAY),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            text = GetString(LUIE_STRING_LAM_CA_DISPLAY_DESCRIPTION)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_DISPLAY_DEBUG_MESSAGE),
            tooltip = "Display a debug message when a Display Announcement that has not yet been added to LUIE is triggered. Enable this option if you'd like to help out with the addon by posting the messages you receive from this event. Do not enable if you are not using the English client.",
            getFunction = function ()
                return Settings.DisplayAnnouncements.Debug
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.Debug = value
            end,
            default = Defaults.DisplayAnnouncements.Debug,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.General.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.General.CA = value
            end,
            default = Defaults.DisplayAnnouncements.General.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.General.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.General.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.General.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.General.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.General.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.General.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_MISC)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.Respec.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.Respec.CA = value
            end,
            default = Defaults.DisplayAnnouncements.Respec.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.Respec.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.Respec.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.Respec.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.Respec.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.Respec.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.Respec.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.GroupArea.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.GroupArea.CA = value
            end,
            default = Defaults.DisplayAnnouncements.GroupArea.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.GroupArea.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.GroupArea.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.GroupArea.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.GroupArea.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.GroupArea.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.GroupArea.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_EVENT_ZONE_NIGHT_MARKET)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_DARING_RACE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_DARING_RACE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarket.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarket.CA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarket.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_DARING_RACE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_DARING_RACE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarket.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarket.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarket.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_DARING_RACE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_DARING_RACE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarket.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarket.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarket.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ARACHNID), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ARACHNID_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarketArachnid.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarketArachnid.CA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarketArachnid.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ARACHNID), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ARACHNID_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarketArachnid.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarketArachnid.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarketArachnid.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ARACHNID), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ARACHNID_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarketArachnid.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarketArachnid.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarketArachnid.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_GUIDING_LIGHT), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_GUIDING_LIGHT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarketGuidingLight.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarketGuidingLight.CA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarketGuidingLight.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_GUIDING_LIGHT), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_GUIDING_LIGHT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarketGuidingLight.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarketGuidingLight.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarketGuidingLight.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_GUIDING_LIGHT), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_GUIDING_LIGHT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneNightMarketGuidingLight.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneNightMarketGuidingLight.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneNightMarketGuidingLight.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        local function AddNightMarketDisplayCheckbox(svKey, labelStringId, tooltipStringId, channel)
            local channelShort = channel == "CA" and LUIE_STRING_LAM_CA_SHARED_CA_SHORT
                or channel == "CSA" and LUIE_STRING_LAM_CA_SHARED_CSA_SHORT
                or LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT
            local channelFull = channel == "CA" and LUIE_STRING_LAM_CA_SHARED_CA
                or channel == "CSA" and LUIE_STRING_LAM_CA_SHARED_CSA
                or LUIE_STRING_LAM_CA_SHARED_ALERT
            settings[#settings + 1] =
            {
                type = LHAS.ST_CHECKBOX,
                label = zo_strformat(GetString(labelStringId), GetString(channelShort)),
                tooltip = zo_strformat(GetString(tooltipStringId), GetString(channelFull)),
                getFunction = function ()
                    return Settings.DisplayAnnouncements[svKey][channel]
                end,
                setFunction = function (value)
                    Settings.DisplayAnnouncements[svKey][channel] = value
                end,
                default = Defaults.DisplayAnnouncements[svKey][channel],
                disable = function ()
                    return not LUIE.SV.ChatAnnouncements_Enable
                end
            }
        end

        local nightMarketDisplaySections =
        {
            { svKey = "ZoneNightMarketBoulderDash",   label = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_BOULDER_DASH,   tooltip = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_BOULDER_DASH_TP   },
            { svKey = "ZoneNightMarketRewards",       label = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_REWARDS,        tooltip = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_REWARDS_TP        },
            { svKey = "ZoneNightMarketScavengingMaw", label = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_SCAVENGING_MAW, tooltip = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_SCAVENGING_MAW_TP },
            { svKey = "ZoneNightMarketZoneHunt",      label = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ZONE_HUNT,      tooltip = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ZONE_HUNT_TP      },
            { svKey = "ZoneNightMarketEssence",       label = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ESSENCE,        tooltip = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_ESSENCE_TP        },
            { svKey = "ZoneNightMarketMisc",          label = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_MISC,           tooltip = LUIE_STRING_LAM_CA_DISPLAY_NIGHT_MARKET_MISC_TP           },
        }
        for _, section in ipairs(nightMarketDisplaySections) do
            AddNightMarketDisplayCheckbox(section.svKey, section.label, section.tooltip, "CA")
            AddNightMarketDisplayCheckbox(section.svKey, section.label, section.tooltip, "CSA")
            AddNightMarketDisplayCheckbox(section.svKey, section.label, section.tooltip, "Alert")
        end

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_ZONE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneCraglorn.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneCraglorn.CA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneCraglorn.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneCraglorn.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneCraglorn.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneCraglorn.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneCraglorn.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneCraglorn.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneCraglorn.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneIC.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneIC.CA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneIC.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_DESCRIPTION),
            tooltip = GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_DESCRIPTION_TP),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneIC.Description
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneIC.Description = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneIC.Description,
            disable = function ()
                return not (LUIE.SV.ChatAnnouncements_Enable and (Settings.DisplayAnnouncements.ZoneIC.CA or Settings.DisplayAnnouncements.ZoneIC.CSA or Settings.DisplayAnnouncements.ZoneIC.Alert))
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneIC.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneIC.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneIC.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ZoneIC.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ZoneIC.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.ZoneIC.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_ARENA)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ArenaMaelstrom.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ArenaMaelstrom.CA = value
            end,
            default = Defaults.DisplayAnnouncements.ArenaMaelstrom.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ArenaMaelstrom.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ArenaMaelstrom.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.ArenaMaelstrom.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.ArenaMaelstrom.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.ArenaMaelstrom.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.ArenaMaelstrom.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_DUNGEON)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_TRIAL), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_TRIAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.DungeonTrial.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.DungeonTrial.CA = value
            end,
            default = Defaults.DisplayAnnouncements.DungeonTrial.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_TRIAL), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_TRIAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.DungeonTrial.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.DungeonTrial.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.DungeonTrial.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_TRIAL), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_TRIAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.DungeonTrial.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.DungeonTrial.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.DungeonTrial.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.DungeonEndlessArchive.CA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.DungeonEndlessArchive.CA = value
            end,
            default = Defaults.DisplayAnnouncements.DungeonEndlessArchive.CA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.DungeonEndlessArchive.CSA
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.DungeonEndlessArchive.CSA = value
            end,
            default = Defaults.DisplayAnnouncements.DungeonEndlessArchive.CSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.DisplayAnnouncements.DungeonEndlessArchive.Alert
            end,
            setFunction = function (value)
                Settings.DisplayAnnouncements.DungeonEndlessArchive.Alert = value
            end,
            default = Defaults.DisplayAnnouncements.DungeonEndlessArchive.Alert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }
    end)

    -- Build Miscellaneous Announcements Section
    buildSectionSettings("Miscellaneous", function (settings)
        local timedActivitiesTrackingLabel = GetString(LUIE_STRING_CA_TIMED_ACTIVITIES_TRACKING)
        local timedActivitiesProgressLabel = GetString(LUIE_STRING_CA_TIMED_ACTIVITIES_PROGRESS)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_MISC_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CA_MISC),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAIL), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAIL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.NotificationMailSendCA
            end,
            setFunction = function (value)
                Settings.Notify.NotificationMailSendCA = value
                ChatAnnouncements.RegisterMailEvents()
            end,
            default = Defaults.Notify.NotificationMailSendCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAIL), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAIL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.NotificationMailSendAlert
            end,
            setFunction = function (value)
                Settings.Notify.NotificationMailSendAlert = value
                ChatAnnouncements.RegisterMailEvents()
            end,
            default = Defaults.Notify.NotificationMailSendAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAILERROR), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAILERROR_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.NotificationMailErrorCA
            end,
            setFunction = function (value)
                Settings.Notify.NotificationMailErrorCA = value
                ChatAnnouncements.RegisterMailEvents()
            end,
            default = Defaults.Notify.NotificationMailErrorCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAILERROR), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAILERROR_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.NotificationMailErrorAlert
            end,
            setFunction = function (value)
                Settings.Notify.NotificationMailErrorAlert = value
                ChatAnnouncements.RegisterMailEvents()
            end,
            default = Defaults.Notify.NotificationMailErrorAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWLOCKPICK), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWLOCKPICK_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.NotificationLockpickCA
            end,
            setFunction = function (value)
                Settings.Notify.NotificationLockpickCA = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Notify.NotificationLockpickCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWLOCKPICK), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWLOCKPICK_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.NotificationLockpickAlert
            end,
            setFunction = function (value)
                Settings.Notify.NotificationLockpickAlert = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Notify.NotificationLockpickAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWJUSTICE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWJUSTICE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.NotificationConfiscateCA
            end,
            setFunction = function (value)
                Settings.Notify.NotificationConfiscateCA = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Notify.NotificationConfiscateCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWJUSTICE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWJUSTICE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.NotificationConfiscateAlert
            end,
            setFunction = function (value)
                Settings.Notify.NotificationConfiscateAlert = value
                ChatAnnouncements.RegisterLootEvents()
            end,
            default = Defaults.Notify.NotificationConfiscateAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.StorageBagCA
            end,
            setFunction = function (value)
                Settings.Notify.StorageBagCA = value
            end,
            default = Defaults.Notify.StorageBagCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Notify.StorageBagCSA
            end,
            setFunction = function (value)
                Settings.Notify.StorageBagCSA = value
            end,
            default = Defaults.Notify.StorageBagCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.StorageBagAlert
            end,
            setFunction = function (value)
                Settings.Notify.StorageBagAlert = value
            end,
            default = Defaults.Notify.StorageBagAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG_COLOR),
            getFunction = function ()
                return Settings.Notify.StorageBagColor[1], Settings.Notify.StorageBagColor[2], Settings.Notify.StorageBagColor[3], Settings.Notify.StorageBagColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Notify.StorageBagColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Notify.StorageBagColor,
            disable = function ()
                return not (Settings.Notify.StorageBagCA or Settings.Notify.StorageBagCSA or Settings.Notify.StorageBagAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.StorageRidingCA
            end,
            setFunction = function (value)
                Settings.Notify.StorageRidingCA = value
            end,
            default = Defaults.Notify.StorageRidingCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Notify.StorageRidingCSA
            end,
            setFunction = function (value)
                Settings.Notify.StorageRidingCSA = value
            end,
            default = Defaults.Notify.StorageRidingCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.StorageRidingAlert
            end,
            setFunction = function (value)
                Settings.Notify.StorageRidingAlert = value
            end,
            default = Defaults.Notify.StorageRidingAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_COLOR),
            getFunction = function ()
                return Settings.Notify.StorageRidingColor[1], Settings.Notify.StorageRidingColor[2], Settings.Notify.StorageRidingColor[3], Settings.Notify.StorageRidingColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Notify.StorageRidingColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Notify.StorageRidingColor,
            disable = function ()
                return not (Settings.Notify.StorageRidingCA or Settings.Notify.StorageRidingCSA or Settings.Notify.StorageRidingAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_COLOR_BOOK),
            getFunction = function ()
                return Settings.Notify.StorageRidingBookColor[1], Settings.Notify.StorageRidingBookColor[2], Settings.Notify.StorageRidingBookColor[3], Settings.Notify.StorageRidingBookColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Notify.StorageRidingBookColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Notify.StorageRidingBookColor,
            disable = function ()
                return not (Settings.Notify.StorageRidingCA or Settings.Notify.StorageRidingCSA or Settings.Notify.StorageRidingAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.DisguiseCA
            end,
            setFunction = function (value)
                Settings.Notify.DisguiseCA = value
                ChatAnnouncements.RegisterDisguiseEvents()
            end,
            default = Defaults.Notify.DisguiseCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Notify.DisguiseCSA
            end,
            setFunction = function (value)
                Settings.Notify.DisguiseCSA = value
                ChatAnnouncements.RegisterDisguiseEvents()
            end,
            default = Defaults.Notify.DisguiseCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.DisguiseAlert
            end,
            setFunction = function (value)
                Settings.Notify.DisguiseAlert = value
                ChatAnnouncements.RegisterDisguiseEvents()
            end,
            default = Defaults.Notify.DisguiseAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.DisguiseWarnCA
            end,
            setFunction = function (value)
                Settings.Notify.DisguiseWarnCA = value
            end,
            default = Defaults.Notify.DisguiseWarnCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Notify.DisguiseWarnCSA
            end,
            setFunction = function (value)
                Settings.Notify.DisguiseWarnCSA = value
            end,
            default = Defaults.Notify.DisguiseWarnCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.DisguiseWarnAlert
            end,
            setFunction = function (value)
                Settings.Notify.DisguiseWarnAlert = value
            end,
            default = Defaults.Notify.DisguiseWarnAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERTCOLOR),
            tooltip = GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERTCOLOR_TP),
            getFunction = function ()
                return Settings.Notify.DisguiseAlertColor[1], Settings.Notify.DisguiseAlertColor[2], Settings.Notify.DisguiseAlertColor[3], Settings.Notify.DisguiseAlertColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Notify.DisguiseAlertColor = { r, g, b }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Notify.DisguiseAlertColor,
            disable = function ()
                return not (Settings.Notify.DisguiseWarnCA or Settings.Notify.DisguiseWarnCSA or Settings.Notify.DisguiseWarnAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CA_NOTIFY_ARMORY_BUILD_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_ARMORY_BUILD), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_ARMORY_BUILD_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.ArmoryBuildCA
            end,
            setFunction = function (value)
                Settings.Notify.ArmoryBuildCA = value
            end,
            default = Defaults.Notify.ArmoryBuildCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_ARMORY_BUILD), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_ARMORY_BUILD_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
            getFunction = function ()
                return Settings.Notify.ArmoryBuildCSA
            end,
            setFunction = function (value)
                Settings.Notify.ArmoryBuildCSA = value
            end,
            default = Defaults.Notify.ArmoryBuildCSA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_ARMORY_BUILD), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_ARMORY_BUILD_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.ArmoryBuildAlert
            end,
            setFunction = function (value)
                Settings.Notify.ArmoryBuildAlert = value
            end,
            default = Defaults.Notify.ArmoryBuildAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CA_MISC_SHOW_ARMORY_BUILD_COLOR),
            getFunction = function ()
                return Settings.Notify.ArmoryBuildColor[1], Settings.Notify.ArmoryBuildColor[2], Settings.Notify.ArmoryBuildColor[3], Settings.Notify.ArmoryBuildColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Notify.ArmoryBuildColor = { r, g, b, a }
                ChatAnnouncements.RegisterColorEvents()
            end,
            default = Defaults.Notify.ArmoryBuildColor,
            disable = function ()
                return not (Settings.Notify.ArmoryBuildCA or Settings.Notify.ArmoryBuildCSA or Settings.Notify.ArmoryBuildAlert and LUIE.SV.ChatAnnouncements_Enable)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_CHALLENGE_DIFFICULTY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_CHALLENGE_DIFFICULTY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
            getFunction = function ()
                return Settings.Notify.ChallengeDifficultyCA
            end,
            setFunction = function (value)
                Settings.Notify.ChallengeDifficultyCA = value
            end,
            default = Defaults.Notify.ChallengeDifficultyCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_CHALLENGE_DIFFICULTY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_NOTIFY_CHALLENGE_DIFFICULTY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
            getFunction = function ()
                return Settings.Notify.ChallengeDifficultyAlert
            end,
            setFunction = function (value)
                Settings.Notify.ChallengeDifficultyAlert = value
            end,
            default = Defaults.Notify.ChallengeDifficultyAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), timedActivitiesTrackingLabel),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), timedActivitiesTrackingLabel),
            getFunction = function ()
                return Settings.Notify.TimedActivityCA
            end,
            setFunction = function (value)
                Settings.Notify.TimedActivityCA = value
            end,
            default = Defaults.Notify.TimedActivityCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable or not IsTimedActivitySystemAvailable()
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), timedActivitiesTrackingLabel),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), timedActivitiesTrackingLabel),
            getFunction = function ()
                return Settings.Notify.TimedActivityAlert
            end,
            setFunction = function (value)
                Settings.Notify.TimedActivityAlert = value
            end,
            default = Defaults.Notify.TimedActivityAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable or not IsTimedActivitySystemAvailable()
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), timedActivitiesProgressLabel),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), timedActivitiesProgressLabel),
            getFunction = function ()
                return Settings.Notify.TimedActivityProgressCA
            end,
            setFunction = function (value)
                Settings.Notify.TimedActivityProgressCA = value
            end,
            default = Defaults.Notify.TimedActivityProgressCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable or not IsTimedActivitySystemAvailable()
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), timedActivitiesProgressLabel),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), timedActivitiesProgressLabel),
            getFunction = function ()
                return Settings.Notify.TimedActivityProgressAlert
            end,
            setFunction = function (value)
                Settings.Notify.TimedActivityProgressAlert = value
            end,
            default = Defaults.Notify.TimedActivityProgressAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable or not IsTimedActivitySystemAvailable()
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_TIMED_ACTIVITY_SCOPE),
            tooltip = GetString(LUIE_STRING_LAM_CA_TIMED_ACTIVITY_SCOPE_TP),
            items = function ()
                return
                {
                    { name = GetString(LUIE_STRING_CA_TIMED_ACTIVITY_SCOPE_ALL),     data = "all"     },
                    { name = GetString(LUIE_STRING_CA_TIMED_ACTIVITY_SCOPE_TRACKED), data = "tracked" },
                }
            end,
            getFunction = function ()
                return Settings.Notify.TimedActivityProgressScope or Defaults.Notify.TimedActivityProgressScope
            end,
            setFunction = function (combobox, value, item)
                Settings.Notify.TimedActivityProgressScope = item.data
            end,
            default = Defaults.Notify.TimedActivityProgressScope,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable or not IsTimedActivitySystemAvailable()
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CA_TIMED_ACTIVITY_FREQ),
            tooltip = GetString(LUIE_STRING_LAM_CA_TIMED_ACTIVITY_FREQ_TP),
            items = function ()
                return
                {
                    { name = GetString(LUIE_STRING_CA_TIMED_ACTIVITY_FREQ_ALWAYS),    data = "always"    },
                    { name = GetString(LUIE_STRING_CA_TIMED_ACTIVITY_FREQ_MILESTONE), data = "milestone" },
                    { name = GetString(LUIE_STRING_CA_TIMED_ACTIVITY_FREQ_COMPLETE),  data = "complete"  },
                }
            end,
            getFunction = function ()
                return Settings.Notify.TimedActivityProgressFrequency or Defaults.Notify.TimedActivityProgressFrequency
            end,
            setFunction = function (combobox, value, item)
                Settings.Notify.TimedActivityProgressFrequency = item.data
            end,
            default = Defaults.Notify.TimedActivityProgressFrequency,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable or not IsTimedActivitySystemAvailable()
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)),
            getFunction = function ()
                return Settings.Notify.PromotionalEventsActivityCA
            end,
            setFunction = function (value)
                Settings.Notify.PromotionalEventsActivityCA = value
            end,
            default = Defaults.Notify.PromotionalEventsActivityCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)),
            getFunction = function ()
                return Settings.Notify.PromotionalEventsActivityAlert
            end,
            setFunction = function (value)
                Settings.Notify.PromotionalEventsActivityAlert = value
            end,
            default = Defaults.Notify.PromotionalEventsActivityAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), GetString(SI_CRAFTED_ABILITY_SUBTITLE)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), GetString(SI_CRAFTED_ABILITY_SUBTITLE)),
            getFunction = function ()
                return Settings.Notify.CraftedAbilityCA
            end,
            setFunction = function (value)
                Settings.Notify.CraftedAbilityCA = value
            end,
            default = Defaults.Notify.CraftedAbilityCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), GetString(SI_CRAFTED_ABILITY_SUBTITLE)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), GetString(SI_CRAFTED_ABILITY_SUBTITLE)),
            getFunction = function ()
                return Settings.Notify.CraftedAbilityAlert
            end,
            setFunction = function (value)
                Settings.Notify.CraftedAbilityAlert = value
            end,
            default = Defaults.Notify.CraftedAbilityAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE)),
            getFunction = function ()
                return Settings.Notify.CraftedAbilityScriptCA
            end,
            setFunction = function (value)
                Settings.Notify.CraftedAbilityScriptCA = value
            end,
            default = Defaults.Notify.CraftedAbilityScriptCA,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE)),
            getFunction = function ()
                return Settings.Notify.CraftedAbilityScriptAlert
            end,
            setFunction = function (value)
                Settings.Notify.CraftedAbilityScriptAlert = value
            end,
            default = Defaults.Notify.CraftedAbilityScriptAlert,
            disable = function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end
        }
    end)

    local allSettings = {}
    SettingsAPI:AppendSettingsList(allSettings, initialSettings)
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_CHATHEADER), sectionGroups["ChatMessage"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_CURRENCY_HEADER), sectionGroups["Currency"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_LOOT_HEADER), sectionGroups["Loot"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_CURRENCY_CONTEXT_MENU), sectionGroups["SharedCurrencyLoot"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_EXP_HEADER), sectionGroups["Experience"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_HEADER), sectionGroups["Collectible"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_ANTIQUITY_HEADER), sectionGroups["Antiquities"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_ACHIEVE_HEADER), sectionGroups["Achievements"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_QUEST_HEADER), sectionGroups["Quest"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_QUEST_COUNTER_FILTER_HEADER), sectionGroups["QuestCounterFilters"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_SOCIAL_HEADER), sectionGroups["Social"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_GROUP_HEADER), sectionGroups["Group"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER), sectionGroups["Display"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CA_MISC_HEADER), sectionGroups["Miscellaneous"])
    panel:AddSettings(allSettings)
end
