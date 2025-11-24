-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) ChatAnnouncements
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

local chatNameDisplayOptions = { "@UserID", "Character Name", "Character Name @UserID" }
local chatNameDisplayOptionsKeys = { ["@UserID"] = 1, ["Character Name"] = 2, ["Character Name @UserID"] = 3 }
local linkBracketDisplayOptions = { "No Brackets", "Display Brackets" }
local linkBracketDisplayOptionsKeys = { ["No Brackets"] = 1, ["Display Brackets"] = 2 }
local bracketOptions4 = { "[]", "()", "-", "No Brackets" }
local bracketOptions4Keys = { ["[]"] = 1, ["()"] = 2, ["-"] = 3, ["No Brackets"] = 4 }
local bracketOptions5 = { "[]", "()", "-", ":", "No Brackets" }
local bracketOptions5Keys = { ["[]"] = 1, ["()"] = 2, ["-"] = 3, [":"] = 4, ["No Brackets"] = 5 }
local guildRankDisplayOptions = { "Self Only", "All w/ Permissions", "All Rank Changes" }
local guildRankDisplayOptionsKeys = { ["Self Only"] = 1, ["All w/ Permissions"] = 2, ["All Rank Changes"] = 3 }
local duelStartOptions = { "Message + Icon", "Message Only", "Icon Only" }
local duelStartOptionsKeys = { ["Message + Icon"] = 1, ["Message Only"] = 2, ["Icon Only"] = 3 }

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

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_CA)),
                                {
                                    allowDefaults = true,
                                    allowRefresh = true
                                })

    local settingsData = {}

    -- Chat Announcements Module Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CA_DESCRIPTION)
    )

    -- ReloadUI Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function ()
            ReloadUI("ingame")
        end,
        "full",
        nil,
        GetString(LUIE_STRING_LAM_RELOADUI)
    )

    -- Chat Message Settings Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_CHATHEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_NAMEDISPLAYMETHOD),
        GetString(LUIE_STRING_LAM_CA_NAMEDISPLAYMETHOD_TP),
        function ()
            local items = {}
            for i, option in ipairs(chatNameDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return chatNameDisplayOptions[Settings.ChatPlayerDisplayOptions]
        end,
        function (combobox, value, item)
            Settings.ChatPlayerDisplayOptions = chatNameDisplayOptionsKeys[value]
            ChatAnnouncements.IndexGroupLoot()
        end,
        chatNameDisplayOptions[2],
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_CHARACTER),
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_CHARACTER_TP),
        function ()
            local items = {}
            for i, option in ipairs(linkBracketDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return linkBracketDisplayOptions[Settings.BracketOptionCharacter]
        end,
        function (combobox, value, item)
            Settings.BracketOptionCharacter = linkBracketDisplayOptionsKeys[value]
            ChatAnnouncements.IndexGroupLoot()
        end,
        linkBracketDisplayOptions[Defaults.BracketOptionCharacter],
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        "NOTE: A significant amount of changes were made to the API for chat in the Harrowstorm Update, chat addons may be in limbo for a bit. It's possible some of the functionality here in relation to other addons may encounter issues in the future and it's likely I will end up adopting LibChatMessage."
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CHATBYPASS),
        GetString(LUIE_STRING_LAM_CA_CHATBYPASS_TP),
        function ()
            return Settings.ChatBypassFormat
        end,
        function (value)
            Settings.ChatBypassFormat = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ChatBypassFormat
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_CHATMETHOD),
        GetString(LUIE_STRING_LAM_CA_CHATMETHOD_TP),
        function ()
            return
            {
                { name = "Print to All Tabs",      data = "Print to All Tabs"      },
                { name = "Print to Specific Tabs", data = "Print to Specific Tabs" }
            }
        end,
        function ()
            return Settings.ChatMethod
        end,
        function (combobox, value, item)
            Settings.ChatMethod = value
        end,
        Defaults.ChatMethod,
        nil
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB), "1"),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), "1"),
        function ()
            return Settings.ChatTab[1]
        end,
        function (value)
            Settings.ChatTab[1] = value
        end,
        "full",
        function ()
            return Settings.ChatMethod == "Print to All Tabs"
        end,
        Defaults.ChatTab[1]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB), "2"),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), "2"),
        function ()
            return Settings.ChatTab[2]
        end,
        function (value)
            Settings.ChatTab[2] = value
        end,
        "full",
        function ()
            return Settings.ChatMethod == "Print to All Tabs"
        end,
        Defaults.ChatTab[2]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB), "3"),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), "3"),
        function ()
            return Settings.ChatTab[3]
        end,
        function (value)
            Settings.ChatTab[3] = value
        end,
        "full",
        function ()
            return Settings.ChatMethod == "Print to All Tabs"
        end,
        Defaults.ChatTab[3]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB), "4"),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), "4"),
        function ()
            return Settings.ChatTab[4]
        end,
        function (value)
            Settings.ChatTab[4] = value
        end,
        "full",
        function ()
            return Settings.ChatMethod == "Print to All Tabs"
        end,
        Defaults.ChatTab[4]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB), "5"),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), "5"),
        function ()
            return Settings.ChatTab[5]
        end,
        function (value)
            Settings.ChatTab[5] = value
        end,
        "full",
        function ()
            return Settings.ChatMethod == "Print to All Tabs"
        end,
        Defaults.ChatTab[5]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CHATTABSYSTEMALL),
        GetString(LUIE_STRING_LAM_CA_CHATTABSYSTEMALL_TP),
        function ()
            return Settings.ChatSystemAll
        end,
        function (value)
            Settings.ChatSystemAll = value
        end,
        "full",
        function ()
            return Settings.ChatMethod == "Print to All Tabs"
        end,
        Defaults.ChatSystemAll,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_TIMESTAMP),
        GetString(LUIE_STRING_LAM_CA_TIMESTAMP_TP),
        function ()
            return Settings.TimeStamp
        end,
        function (value)
            Settings.TimeStamp = value
        end,
        "full",
        nil,
        Defaults.TimeStamp
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT),
        GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP),
        function ()
            return Settings.TimeStampFormat
        end,
        function (value)
            Settings.TimeStampFormat = value
        end,
        "full",
        function ()
            return not Settings.TimeStamp
        end,
        Defaults.TimeStampFormat,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_TIMESTAMPCOLOR),
        GetString(LUIE_STRING_LAM_CA_TIMESTAMPCOLOR_TP),
        function ()
            return unpack(Settings.TimeStampColor)
        end,
        function (r, g, b, a)
            Settings.TimeStampColor = { r, g, b, a }
            LUIE.UpdateTimeStampColor()
        end,
        Settings.TimeStampColor,
        5,
        function ()
            return not Settings.TimeStamp
        end
    )

    -- Currency Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWICONS),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWICONS_TP),
        function ()
            return Settings.Currency.CurrencyIcon
        end,
        function (value)
            Settings.Currency.CurrencyIcon = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyIcon
    )

    -- Gold
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLD),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLD_TP),
        function ()
            return Settings.Currency.CurrencyGoldChange
        end,
        function (value)
            Settings.Currency.CurrencyGoldChange = value
            ChatAnnouncements.RegisterGoldEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyGoldChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyGoldColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyGoldColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyGoldColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDNAME_TP),
        function ()
            return Settings.Currency.CurrencyGoldName
        end,
        function (value)
            Settings.Currency.CurrencyGoldName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyGoldName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyGoldShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyGoldShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyGoldShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalGold
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalGold = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyGoldChange and Settings.Currency.CurrencyGoldShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalGold,
        10
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTHRESHOLD),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTHRESHOLD_TP),
        0, 10000, 50,
        function ()
            return Settings.Currency.CurrencyGoldFilter
        end,
        function (value)
            Settings.Currency.CurrencyGoldFilter = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyGoldFilter,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTHROTTLE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_GOLDTHROTTLE_TP),
        function ()
            return Settings.Currency.CurrencyGoldThrottle
        end,
        function (value)
            Settings.Currency.CurrencyGoldThrottle = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyGoldThrottle,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_HIDEGOLDAHLIST),
        zo_strformat("<<1>>", GetString(LUIE_STRING_LAM_CA_CURRENCY_HIDEGOLDAHLIST_TP)),
        function ()
            return Settings.Currency.CurrencyGoldHideListingAH
        end,
        function (value)
            Settings.Currency.CurrencyGoldHideListingAH = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyGoldHideListingAH,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_HIDEGOLDAHSPENT),
        zo_strformat("<<1>>", GetString(LUIE_STRING_LAM_CA_CURRENCY_HIDEGOLDAHSPENT_TP)),
        function ()
            return Settings.Currency.CurrencyGoldHideAH
        end,
        function (value)
            Settings.Currency.CurrencyGoldHideAH = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyGoldChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyGoldHideAH,
        5
    )

    -- Alliance Points
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAP),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAP_TP),
        function ()
            return Settings.Currency.CurrencyAPShowChange
        end,
        function (value)
            Settings.Currency.CurrencyAPShowChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyAPShowChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyAPColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyAPColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyAPColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPNAME_TP),
        function ()
            return Settings.Currency.CurrencyAPName
        end,
        function (value)
            Settings.Currency.CurrencyAPName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.TotalCurrencyAPName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyAPShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyAPShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyAPShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_APTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_APTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalAP
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalAP = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyAPShowChange and Settings.Currency.CurrencyAPShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalAP,
        10
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTHRESHOLD),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTHRESHOLD_TP),
        0, 10000, 50,
        function ()
            return Settings.Currency.CurrencyAPFilter
        end,
        function (value)
            Settings.Currency.CurrencyAPFilter = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyAPFilter,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTHROTTLE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWAPTHROTTLE_TP),
        0, 5000, 50,
        function ()
            return Settings.Currency.CurrencyAPThrottle
        end,
        function (value)
            Settings.Currency.CurrencyAPThrottle = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyAPShowChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyAPThrottle,
        5
    )

    -- Tel Var Stones
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTV),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTV_TP),
        function ()
            return Settings.Currency.CurrencyTVChange
        end,
        function (value)
            Settings.Currency.CurrencyTVChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyTVChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyTVColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyTVColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyTVColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVNAME_TP),
        function ()
            return Settings.Currency.CurrencyTVName
        end,
        function (value)
            Settings.Currency.CurrencyTVName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyTVName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyTVShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyTVShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyTVShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_TVTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_TVTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalTV
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalTV = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyAPShowChange and Settings.Currency.CurrencyTVShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalTV,
        10
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTHRESHOLD),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTHRESHOLD_TP),
        0, 10000, 50,
        function ()
            return Settings.Currency.CurrencyTVFilter
        end,
        function (value)
            Settings.Currency.CurrencyTVFilter = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyTVFilter,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTHROTTLE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTVTHROTTLE_TP),
        0, 5000, 50,
        function ()
            return Settings.Currency.CurrencyTVThrottle
        end,
        function (value)
            Settings.Currency.CurrencyTVThrottle = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyTVChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyTVThrottle,
        5
    )

    -- Writ Vouchers
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHER),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHER_TP),
        function ()
            return Settings.Currency.CurrencyWVChange
        end,
        function (value)
            Settings.Currency.CurrencyWVChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyWVChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyWVColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyWVColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyWVColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyWVChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERNAME_TP),
        function ()
            return Settings.Currency.CurrencyWVName
        end,
        function (value)
            Settings.Currency.CurrencyWVName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyWVChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyWVName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWVOUCHERTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyWVShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyWVShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyWVChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyWVShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_WVTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_WVTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalWV
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalWV = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyWVChange and Settings.Currency.CurrencyWVShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalWV,
        10
    )

    -- Undaunted Keys
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTED),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTED_TP),
        function ()
            return Settings.Currency.CurrencyUndauntedChange
        end,
        function (value)
            Settings.Currency.CurrencyUndauntedChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyUndauntedChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyUndauntedColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyUndauntedColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyUndauntedColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyUndauntedChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDNAME_TP),
        function ()
            return Settings.Currency.CurrencyUndauntedName
        end,
        function (value)
            Settings.Currency.CurrencyUndauntedName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyUndauntedChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyUndauntedName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWUNDAUNTEDTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyUndauntedShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyUndauntedShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyUndauntedChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyUndauntedShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_UNDAUNTEDTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_UNDAUNTEDTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalUndaunted
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalUndaunted = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyUndauntedChange and Settings.Currency.CurrencyUndauntedShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalUndaunted,
        10
    )

    -- Endless Keys
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESS),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESS_TP),
        function ()
            return Settings.Currency.CurrencyEndlessChange
        end,
        function (value)
            Settings.Currency.CurrencyEndlessChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyEndlessChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyEndlessColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyEndlessColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyEndlessColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyEndlessChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSNAME_TP),
        function ()
            return Settings.Currency.CurrencyEndlessName
        end,
        function (value)
            Settings.Currency.CurrencyEndlessName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyEndlessChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyEndlessName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDLESSTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyEndlessShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyEndlessShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyEndlessChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyEndlessShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_ENDLESSTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_ENDLESSTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalEndless
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalEndless = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyEndlessChange and Settings.Currency.CurrencyEndlessShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalEndless,
        10
    )

    -- Outfit Tokens
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENS),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENS_TP),
        function ()
            return Settings.Currency.CurrencyOutfitTokenChange
        end,
        function (value)
            Settings.Currency.CurrencyOutfitTokenChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyOutfitTokenChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyOutfitTokenColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyOutfitTokenColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyOutfitTokenColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyOutfitTokenChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSNAME_TP),
        function ()
            return Settings.Currency.CurrencyOutfitTokenName
        end,
        function (value)
            Settings.Currency.CurrencyOutfitTokenName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyOutfitTokenChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyOutfitTokenName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTOKENSTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyOutfitTokenShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyOutfitTokenShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyOutfitTokenChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyOutfitTokenShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_TOKENSTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_TOKENSTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalOutfitToken
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalOutfitToken = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyOutfitTokenChange and Settings.Currency.CurrencyOutfitTokenShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalOutfitToken,
        10
    )

    -- Transmute Crystals
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTE_TP),
        function ()
            return Settings.Currency.CurrencyTransmuteChange
        end,
        function (value)
            Settings.Currency.CurrencyTransmuteChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyTransmuteChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTECOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyTransmuteColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyTransmuteColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyTransmuteColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyTransmuteChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTENAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTENAME_TP),
        function ()
            return Settings.Currency.CurrencyTransmuteName
        end,
        function (value)
            Settings.Currency.CurrencyTransmuteName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyTransmuteChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyTransmuteName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTETOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWTRANSMUTETOTAL_TP),
        function ()
            return Settings.Currency.CurrencyTransmuteShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyTransmuteShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyTransmuteChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyTransmuteShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_TRANSMUTETOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_TRANSMUTETOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalTransmute
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalTransmute = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyTransmuteChange and Settings.Currency.CurrencyTransmuteShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalTransmute,
        10
    )

    -- Event Tickets
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWEVENT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWEVENT_TP),
        function ()
            return Settings.Currency.CurrencyEventChange
        end,
        function (value)
            Settings.Currency.CurrencyEventChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyEventChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWEVENTCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyEventColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyEventColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyEventColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyEventChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWEVENTNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWEVENTNAME_TP),
        function ()
            return Settings.Currency.CurrencyEventName
        end,
        function (value)
            Settings.Currency.CurrencyEventName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyEventChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyEventName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWEVENTTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWEVENTTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyEventShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyEventShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyEventChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyEventShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_EVENTTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_EVENTTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalEvent
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalEvent = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyEventChange and Settings.Currency.CurrencyEventShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalEvent,
        10
    )

    -- Crowns
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNS),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNS_TP),
        function ()
            return Settings.Currency.CurrencyCrownsChange
        end,
        function (value)
            Settings.Currency.CurrencyCrownsChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyCrownsChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyCrownsColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyCrownsColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyCrownsColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyCrownsChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSNAME_TP),
        function ()
            return Settings.Currency.CurrencyCrownsName
        end,
        function (value)
            Settings.Currency.CurrencyCrownsName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyCrownsChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyCrownsName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNSTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyCrownsShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyCrownsShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyCrownsChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyCrownsShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_CROWNSTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_CROWNSTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalCrowns
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalCrowns = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyCrownsChange and Settings.Currency.CurrencyCrownsShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalCrowns,
        10
    )

    -- Crown Gems
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMS),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMS_TP),
        function ()
            return Settings.Currency.CurrencyCrownGemsChange
        end,
        function (value)
            Settings.Currency.CurrencyCrownGemsChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyCrownGemsChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyCrownGemsColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyCrownGemsColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyCrownGemsColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyCrownGemsChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSNAME_TP),
        function ()
            return Settings.Currency.CurrencyCrownGemsName
        end,
        function (value)
            Settings.Currency.CurrencyCrownGemsName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyCrownGemsChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyCrownGemsName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWCROWNGEMSTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyCrownGemsShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyCrownGemsShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyCrownGemsChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyCrownGemsShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_CROWNGEMSTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_CROWNGEMSTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalCrownGems
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalCrownGems = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyCrownGemsChange and Settings.Currency.CurrencyCrownGemsShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalCrownGems,
        10
    )

    -- Endeavors
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDEAVORS),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDEAVORS_TP),
        function ()
            return Settings.Currency.CurrencyEndeavorsChange
        end,
        function (value)
            Settings.Currency.CurrencyEndeavorsChange = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyEndeavorsChange
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDEAVORSCOLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyEndeavorsColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyEndeavorsColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyEndeavorsColor,
        5,
        function ()
            return not (Settings.Currency.CurrencyEndeavorsChange and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDEAVORSNAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDEAVORSNAME_TP),
        function ()
            return Settings.Currency.CurrencyEndeavorsName
        end,
        function (value)
            Settings.Currency.CurrencyEndeavorsName = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyEndeavorsChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyEndeavorsName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDEAVORSTOTAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_SHOWENDEAVORSTOTAL_TP),
        function ()
            return Settings.Currency.CurrencyEndeavorsShowTotal
        end,
        function (value)
            Settings.Currency.CurrencyEndeavorsShowTotal = value
        end,
        "full",
        function ()
            return not (Settings.Currency.CurrencyEndeavorsChange and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Currency.CurrencyEndeavorsShowTotal,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_ENDEAVORSTOTAL_MSG),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_ENDEAVORSTOTAL_MSG_TP),
        function ()
            return Settings.Currency.CurrencyMessageTotalEndeavors
        end,
        function (value)
            Settings.Currency.CurrencyMessageTotalEndeavors = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Currency.CurrencyEndeavorsChange and Settings.Currency.CurrencyEndeavorsShowTotal)
        end,
        Defaults.Currency.CurrencyMessageTotalEndeavors,
        10
    )

    -- Loot Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_ITEM),
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_ITEM_TP),
        function ()
            local items = {}
            for i, option in ipairs(linkBracketDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return linkBracketDisplayOptions[Settings.BracketOptionItem]
        end,
        function (combobox, value, item)
            Settings.BracketOptionItem = linkBracketDisplayOptionsKeys[value]
        end,
        linkBracketDisplayOptions[Defaults.BracketOptionItem],
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWICONS),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWICONS_TP),
        function ()
            return Settings.Inventory.LootIcons
        end,
        function (value)
            Settings.Inventory.LootIcons = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootIcons
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWARMORTYPE),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWARMORTYPE_TP),
        function ()
            return Settings.Inventory.LootShowArmorType
        end,
        function (value)
            Settings.Inventory.LootShowArmorType = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootShowArmorType
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMSTYLE),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMSTYLE_TP),
        function ()
            return Settings.Inventory.LootShowStyle
        end,
        function (value)
            Settings.Inventory.LootShowStyle = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootShowStyle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMTRAIT),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMTRAIT_TP),
        function ()
            return Settings.Inventory.LootShowTrait
        end,
        function (value)
            Settings.Inventory.LootShowTrait = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootShowTrait
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_TOTAL),
        GetString(LUIE_STRING_LAM_CA_LOOT_TOTAL_TP),
        function ()
            return Settings.Inventory.LootTotal
        end,
        function (value)
            Settings.Inventory.LootTotal = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootTotal
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_TOTALSTRING),
        GetString(LUIE_STRING_LAM_CA_LOOT_TOTALSTRING_TP),
        function ()
            return Settings.Inventory.LootTotalString
        end,
        function (value)
            Settings.Inventory.LootTotalString = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.LootTotal and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootTotalString,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMS),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWITEMS_TP),
        function ()
            return Settings.Inventory.Loot
        end,
        function (value)
            Settings.Inventory.Loot = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.Loot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTLOGDISABLE),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTLOGDISABLE_TP),
        function ()
            return Settings.Inventory.LootLogOverride
        end,
        function (value)
            Settings.Inventory.LootLogOverride = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootLogOverride,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWNOTABLE),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWNOTABLE_TP),
        function ()
            return Settings.Inventory.LootOnlyNotable
        end,
        function (value)
            Settings.Inventory.LootOnlyNotable = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootOnlyNotable,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWGRPLOOT),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWGRPLOOT_TP),
        function ()
            return Settings.Inventory.LootGroup
        end,
        function (value)
            Settings.Inventory.LootGroup = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootGroup,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_HIDEANNOYINGITEMS),
        GetString(LUIE_STRING_LAM_CA_LOOT_HIDEANNOYINGITEMS_TP),
        function ()
            return Settings.Inventory.LootBlacklist
        end,
        function (value)
            Settings.Inventory.LootBlacklist = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootBlacklist,
        5,
        GetString(LUIE_STRING_LAM_CA_LOOT_HIDEANNOYINGITEMS_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_HIDETRASH),
        GetString(LUIE_STRING_LAM_CA_LOOT_HIDETRASH_TP),
        function ()
            return Settings.Inventory.LootNotTrash
        end,
        function (value)
            Settings.Inventory.LootNotTrash = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootNotTrash,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTCONFISCATED),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTCONFISCATED_TP),
        function ()
            return Settings.Inventory.LootConfiscate
        end,
        function (value)
            Settings.Inventory.LootConfiscate = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootConfiscate,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWCONTAINER),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWCONTAINER_TP),
        function ()
            return Settings.Inventory.LootShowContainer
        end,
        function (value)
            Settings.Inventory.LootShowContainer = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowContainer,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWDESTROYED),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWDESTROYED_TP),
        function ()
            return Settings.Inventory.LootShowDestroy
        end,
        function (value)
            Settings.Inventory.LootShowDestroy = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowDestroy,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWREMOVED),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWREMOVED_TP),
        function ()
            return Settings.Inventory.LootShowRemove
        end,
        function (value)
            Settings.Inventory.LootShowRemove = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowRemove,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWLIST),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWLIST_TP),
        function ()
            return Settings.Inventory.LootShowList
        end,
        function (value)
            Settings.Inventory.LootShowList = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowList,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWTURNIN),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWTURNIN_TP),
        function ()
            return Settings.Inventory.LootShowTurnIn
        end,
        function (value)
            Settings.Inventory.LootShowTurnIn = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowTurnIn,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_POTION),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_POTION_TP),
        function ()
            return Settings.Inventory.LootShowUsePotion
        end,
        function (value)
            Settings.Inventory.LootShowUsePotion = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowUsePotion,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_FOOD),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_FOOD_TP),
        function ()
            return Settings.Inventory.LootShowUseFood
        end,
        function (value)
            Settings.Inventory.LootShowUseFood = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowUseFood,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_DRINK),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_DRINK_TP),
        function ()
            return Settings.Inventory.LootShowUseDrink
        end,
        function (value)
            Settings.Inventory.LootShowUseDrink = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowUseDrink,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_REPAIR_KIT),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_REPAIR_KIT_TP),
        function ()
            return Settings.Inventory.LootShowUseRepairKit
        end,
        function (value)
            Settings.Inventory.LootShowUseRepairKit = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowUseRepairKit,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_SOUL_GEM),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_SOUL_GEM_TP),
        function ()
            return Settings.Inventory.LootShowUseSoulGem
        end,
        function (value)
            Settings.Inventory.LootShowUseSoulGem = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowUseSoulGem,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_SIEGE),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_SIEGE_TP),
        function ()
            return Settings.Inventory.LootShowUseSiege
        end,
        function (value)
            Settings.Inventory.LootShowUseSiege = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowUseSiege,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_FISH),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_FISH_TP),
        function ()
            return Settings.Inventory.LootShowUseFish
        end,
        function (value)
            Settings.Inventory.LootShowUseFish = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowUseFish,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_MISC),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWUSE_MISC_TP),
        function ()
            return Settings.Inventory.LootShowUseMisc
        end,
        function (value)
            Settings.Inventory.LootShowUseMisc = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowUseMisc,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWLOCKPICK),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWLOCKPICK_TP),
        function ()
            return Settings.Inventory.LootShowLockpick
        end,
        function (value)
            Settings.Inventory.LootShowLockpick = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowLockpick,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTRECIPE),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTRECIPE_TP),
        function ()
            return Settings.Inventory.LootShowRecipe
        end,
        function (value)
            Settings.Inventory.LootShowRecipe = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowRecipe,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTMOTIF),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTMOTIF_TP),
        function ()
            return Settings.Inventory.LootShowMotif
        end,
        function (value)
            Settings.Inventory.LootShowMotif = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowMotif,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSTYLE),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSTYLE_TP),
        function ()
            return Settings.Inventory.LootShowStylePage
        end,
        function (value)
            Settings.Inventory.LootShowStylePage = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowStylePage,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_HIDE_RECIPE_ALERT),
        GetString(LUIE_STRING_LAM_CA_LOOT_HIDE_RECIPE_ALERT_TP),
        function ()
            return Settings.Inventory.LootRecipeHideAlert
        end,
        function (value)
            Settings.Inventory.LootRecipeHideAlert = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not (Settings.Inventory.Loot and (Settings.Inventory.LootShowRecipe or Settings.Inventory.LootShowMotif or Settings.Inventory.LootShowStylePage) and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootRecipeHideAlert,
        10
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWQUESTADD),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWQUESTADD_TP),
        function ()
            return Settings.Inventory.LootQuestAdd
        end,
        function (value)
            Settings.Inventory.LootQuestAdd = value
            ChatAnnouncements.RegisterLootEvents()
            ChatAnnouncements.AddQuestItemsToIndex()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootQuestAdd
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWQUESTREM),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWQUESTREM_TP),
        function ()
            return Settings.Inventory.LootQuestRemove
        end,
        function (value)
            Settings.Inventory.LootQuestRemove = value
            ChatAnnouncements.RegisterLootEvents()
            ChatAnnouncements.AddQuestItemsToIndex()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootQuestRemove
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWVENDOR),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWVENDOR_TP),
        function ()
            return Settings.Inventory.LootVendor
        end,
        function (value)
            Settings.Inventory.LootVendor = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootVendor
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_MERGE),
        GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_MERGE_TP),
        function ()
            return Settings.Inventory.LootVendorCurrency
        end,
        function (value)
            Settings.Inventory.LootVendorCurrency = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.LootVendor and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootVendorCurrency,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_TOTALITEMS),
        GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_TOTALITEMS_TP),
        function ()
            return Settings.Inventory.LootVendorTotalItems
        end,
        function (value)
            Settings.Inventory.LootVendorTotalItems = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.LootVendor and Settings.Inventory.LootVendorCurrency and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootVendorTotalItems,
        10
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_TOTALCURRENCY),
        GetString(LUIE_STRING_LAM_CA_LOOT_VENDOR_TOTALCURRENCY_TP),
        function ()
            return Settings.Inventory.LootVendorTotalCurrency
        end,
        function (value)
            Settings.Inventory.LootVendorTotalCurrency = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.LootVendor and Settings.Inventory.LootVendorCurrency and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootVendorTotalCurrency,
        10
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWBANK),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWBANK_TP),
        function ()
            return Settings.Inventory.LootBank
        end,
        function (value)
            Settings.Inventory.LootBank = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootBank
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCRAFT),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCRAFT_TP),
        function ()
            return Settings.Inventory.LootCraft
        end,
        function (value)
            Settings.Inventory.LootCraft = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootCraft
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCRAFT_MATERIALS),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWCRAFT_MATERIALS_TP),
        function ()
            return Settings.Inventory.LootShowCraftUse
        end,
        function (value)
            Settings.Inventory.LootShowCraftUse = value
        end,
        "full",
        function ()
            return not (Settings.Inventory.LootCraft and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Inventory.LootShowCraftUse,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWMAIL),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWMAIL_TP),
        function ()
            return Settings.Inventory.LootMail
        end,
        function (value)
            Settings.Inventory.LootMail = value
            ChatAnnouncements.RegisterMailEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootMail
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWTRADE),
        GetString(LUIE_STRING_LAM_CA_LOOT_SHOWTRADE_TP),
        function ()
            return Settings.Inventory.LootTrade
        end,
        function (value)
            Settings.Inventory.LootTrade = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootTrade
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWDISGUISE),
        GetString(LUIE_STRING_LAM_CA_LOOT_LOOTSHOWDISGUISE_TP),
        function ()
            return Settings.Inventory.LootShowDisguise
        end,
        function (value)
            Settings.Inventory.LootShowDisguise = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Inventory.LootShowDisguise
    )

    -- Shared Currency/Loot Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_CONTEXT_MENU)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyColor)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyColor,
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR_CONTEXT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR_CONTEXT_TP),
        function ()
            return Settings.Currency.CurrencyContextColor
        end,
        function (value)
            Settings.Currency.CurrencyContextColor = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyContextColor
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_COLORUP),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyColorUp)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyColorUp = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyColorUp,
        5,
        function ()
            return not (Settings.Currency.CurrencyContextColor and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_COLORDOWN),
        nil,
        function ()
            return unpack(Settings.Currency.CurrencyColorDown)
        end,
        function (r, g, b, a)
            Settings.Currency.CurrencyColorDown = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Currency.CurrencyColorDown,
        5,
        function ()
            return not (Settings.Currency.CurrencyContextColor and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR_CONTEXT_MERGED),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_COLOR_CONTEXT_MERGED_TP),
        function ()
            return Settings.Currency.CurrencyContextMergedColor
        end,
        function (value)
            Settings.Currency.CurrencyContextMergedColor = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Currency.CurrencyContextMergedColor
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_CONTEXT_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOOT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOOT_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageLoot
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageLoot = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageLoot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_RECEIVE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_RECEIVE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageReceive
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageReceive = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageReceive
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EARN),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EARN_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageEarn
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageEarn = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageEarn
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STEAL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STEAL_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageSteal
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageSteal = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageSteal
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_PICKPOCKET),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_PICKPOCKET_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessagePickpocket
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessagePickpocket = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessagePickpocket
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CONFISCATE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CONFISCATE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageConfiscate
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageConfiscate = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageConfiscate
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SPEND),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SPEND_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageSpend
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageSpend = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageSpend
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_PAY),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_PAY_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessagePay
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessagePay = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessagePay
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_USEKIT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_USEKIT_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageUseKit
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageUseKit = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageUseKit
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_POTION),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_POTION_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessagePotion
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessagePotion = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessagePotion
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FOOD),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FOOD_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageFood
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageFood = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageFood
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DRINK),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DRINK_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDrink
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDrink = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDrink
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPLOY),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPLOY_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDeploy
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDeploy = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDeploy
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STOW),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STOW_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageStow
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageStow = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageStow
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FILLET),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FILLET_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageFillet
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageFillet = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageFillet
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_RECIPE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_RECIPE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageLearnRecipe
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageLearnRecipe = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageLearnRecipe
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_MOTIF),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_MOTIF_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageLearnMotif
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageLearnMotif = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageLearnMotif
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_STYLE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LEARN_STYLE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageLearnStyle
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageLearnStyle = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageLearnStyle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXCAVATE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXCAVATE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageExcavate
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageExcavate = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageExcavate
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEIN),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEIN_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageTradeIn
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageTradeIn = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageTradeIn
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEIN_NO_NAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEIN_NO_NAME_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageTradeInNoName
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageTradeInNoName = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageTradeInNoName
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEOUT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEOUT_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageTradeOut
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageTradeOut = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageTradeOut
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEOUT_NO_NAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADEOUT_NO_NAME_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageTradeOutNoName
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageTradeOutNoName = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageTradeOutNoName
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILIN),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILIN_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageMailIn
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageMailIn = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageMailIn
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILIN_NO_NAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILIN_NO_NAME_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageMailInNoName
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageMailInNoName = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageMailInNoName
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILOUT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILOUT_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageMailOut
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageMailOut = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageMailOut
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILOUT_NO_NAME),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MAILOUT_NO_NAME_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageMailOutNoName
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageMailOutNoName = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageMailOutNoName
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSIT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSIT_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDeposit
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDeposit = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDeposit
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAW),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAW_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageWithdraw
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageWithdraw = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageWithdraw
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSITGUILD),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSITGUILD_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDepositGuild
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDepositGuild = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDepositGuild
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAWGUILD),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAWGUILD_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageWithdrawGuild
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageWithdrawGuild = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageWithdrawGuild
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSITSTORAGE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DEPOSITSTORAGE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDepositStorage
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDepositStorage = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDepositStorage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAWSTORAGE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WITHDRAWSTORAGE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageWithdrawStorage
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageWithdrawStorage = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageWithdrawStorage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOST),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOST_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageLost
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageLost = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageLost
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BOUNTY),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BOUNTY_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageBounty
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageBounty = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageBounty
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REPAIR),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REPAIR_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageRepair
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageRepair = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageRepair
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADER),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TRADER_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageTrader
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageTrader = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageTrader
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LISTING),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LISTING_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageListing
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageListing = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageListing
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LIST),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LIST_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageList
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageList = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageList
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LISTING_VALUE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LISTING_VALUE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageListingValue
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageListingValue = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageListingValue
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUY_VALUE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUY_VALUE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageBuy
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageBuy = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageBuy
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUY),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUY_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageBuyNoV
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageBuyNoV = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageBuyNoV
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUYBACK_VALUE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUYBACK_VALUE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageBuyback
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageBuyback = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageBuyback
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUYBACK),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUYBACK_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageBuybackNoV
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageBuybackNoV = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageBuybackNoV
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SELL_VALUE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SELL_VALUE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageSell
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageSell = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageSell
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SELL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SELL_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageSellNoV
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageSellNoV = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageSellNoV
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FENCE_VALUE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FENCE_VALUE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageFence
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageFence = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageFence
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FENCE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_FENCE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageFenceNoV
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageFenceNoV = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageFenceNoV
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LAUNDER_VALUE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LAUNDER_VALUE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageLaunder
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageLaunder = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageLaunder
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LAUNDER),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LAUNDER_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageLaunderNoV
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageLaunderNoV = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageLaunderNoV
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STABLE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STABLE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageStable
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageStable = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageStable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STORAGE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_STORAGE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageStorage
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageStorage = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageStorage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WAYSHRINE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_WAYSHRINE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageWayshrine
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageWayshrine = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageWayshrine
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UNSTUCK),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UNSTUCK_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageUnstuck
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageUnstuck = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageUnstuck
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_ATTRIBUTES),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_ATTRIBUTES_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageAttributes
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageAttributes = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageAttributes
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CHAMPION),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CHAMPION_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageChampion
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageChampion = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageChampion
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MORPHS),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MORPHS_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageMorphs
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageMorphs = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageMorphs
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SKILLS),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_SKILLS_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageSkills
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageSkills = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageSkills
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CAMPAIGN),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CAMPAIGN_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageCampaign
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageCampaign = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageCampaign
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_USE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_USE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageUse
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageUse = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageUse
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CRAFT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CRAFT_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageCraft
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageCraft = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageCraft
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXTRACT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXTRACT_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageExtract
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageExtract = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageExtract
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UPGRADE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UPGRADE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageUpgrade
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageUpgrade = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageUpgrade
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UPGRADE_FAIL),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_UPGRADE_FAIL_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageUpgradeFail
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageUpgradeFail = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageUpgradeFail
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REFINE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REFINE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageRefine
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageRefine = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageRefine
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DECONSTRUCT),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DECONSTRUCT_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDeconstruct
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDeconstruct = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDeconstruct
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_RESEARCH),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_RESEARCH_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageResearch
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageResearch = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageResearch
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DESTROY),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DESTROY_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDestroy
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDestroy = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDestroy
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CONTAINER),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_CONTAINER_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageContainer
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageContainer = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageContainer
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOCKPICK),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_LOCKPICK_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageLockpick
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageLockpick = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageLockpick
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REMOVE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_REMOVE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageRemove
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageRemove = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageRemove
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TURNIN),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_TURNIN_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestTurnIn
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestTurnIn = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestTurnIn
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTUSE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTUSE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestUse
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestUse = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestUse
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXHAUST),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_EXHAUST_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestExhaust
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestExhaust = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestExhaust
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_OFFER),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_OFFER_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestOffer
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestOffer = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestOffer
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISCARD),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISCARD_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestDiscard
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestDiscard = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestDiscard
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTOPEN),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTOPEN_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestOpen
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestOpen = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestOpen
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTCONFISCATE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTCONFISCATE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestConfiscate
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestConfiscate = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestConfiscate
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTADMINISTER),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTADMINISTER_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestAdminister
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestAdminister = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestAdminister
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTPLACE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_QUESTPLACE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestPlace
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestPlace = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestPlace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_COMBINE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_COMBINE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestCombine
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestCombine = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestCombine
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MIX),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_MIX_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestMix
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestMix = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestMix
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUNDLE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_BUNDLE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageQuestBundle
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageQuestBundle = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageQuestBundle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_GROUP),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_GROUP_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageGroup
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageGroup = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageGroup
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_EQUIP),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_EQUIP_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDisguiseEquip
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDisguiseEquip = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDisguiseEquip
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_REMOVE),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_REMOVE_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDisguiseRemove
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDisguiseRemove = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDisguiseRemove
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_DESTROY),
        GetString(LUIE_STRING_LAM_CA_CURRENCY_MESSAGE_DISGUISE_DESTROY_TP),
        function ()
            return Settings.ContextMessages.CurrencyMessageDisguiseDestroy
        end,
        function (value)
            Settings.ContextMessages.CurrencyMessageDisguiseDestroy = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.ContextMessages.CurrencyMessageDisguiseDestroy
    )

    -- Experience Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_HEADER_ENLIGHTENED)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.XP.ExperienceEnlightenedCA
        end,
        function (value)
            Settings.XP.ExperienceEnlightenedCA = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.XP.ExperienceEnlightenedCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.XP.ExperienceEnlightenedCSA
        end,
        function (value)
            Settings.XP.ExperienceEnlightenedCSA = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.XP.ExperienceEnlightenedCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_ENLIGHTENED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.XP.ExperienceEnlightenedAlert
        end,
        function (value)
            Settings.XP.ExperienceEnlightenedAlert = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.XP.ExperienceEnlightenedAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_HEADER_LEVELUP)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.XP.ExperienceLevelUpCA
        end,
        function (value)
            Settings.XP.ExperienceLevelUpCA = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.XP.ExperienceLevelUpCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.XP.ExperienceLevelUpCSA
        end,
        function (value)
            Settings.XP.ExperienceLevelUpCSA = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.XP.ExperienceLevelUpCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_CSAEXPAND),
        GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_CSAEXPAND_TP),
        function ()
            return Settings.XP.ExperienceLevelUpCSAExpand
        end,
        function (value)
            Settings.XP.ExperienceLevelUpCSAExpand = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not (Settings.XP.ExperienceLevelUpCSA and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceLevelUpCSAExpand,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_EXP_LEVELUP_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.XP.ExperienceLevelUpAlert
        end,
        function (value)
            Settings.XP.ExperienceLevelUpAlert = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.XP.ExperienceLevelUpAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_EXP_LVLUPICON),
        GetString(LUIE_STRING_LAM_CA_EXP_LVLUPICON_TP),
        function ()
            return Settings.XP.ExperienceLevelUpIcon
        end,
        function (value)
            Settings.XP.ExperienceLevelUpIcon = value
        end,
        "full",
        function ()
            return not (Settings.XP.ExperienceLevelUpCA or Settings.XP.ExperienceLevelUpCSA or Settings.XP.ExperienceLevelUpAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceExperienceLevelUpIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_EXPERIENCE_LEVELUP_COLOR),
        nil,
        function ()
            return unpack(Settings.XP.ExperienceLevelUpColor)
        end,
        function (r, g, b, a)
            Settings.XP.ExperienceLevelUpColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.XP.ExperienceLevelUpColor,
        5,
        function ()
            return not (Settings.XP.ExperienceLevelUpCA or Settings.XP.ExperienceLevelUpCSA or Settings.XP.ExperienceLevelUpAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_EXP_COLORLVLBYCONTEXT),
        GetString(LUIE_STRING_LAM_CA_EXP_COLORLVLBYCONTEXT_TP),
        function ()
            return Settings.XP.ExperienceLevelColorByLevel
        end,
        function (value)
            Settings.XP.ExperienceLevelColorByLevel = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not (Settings.XP.ExperienceLevelUpCA or Settings.XP.ExperienceLevelUpCSA or Settings.XP.ExperienceLevelUpAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceLevelColorByLevel,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_HEADER_EXPERIENCEGAIN)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_EXP_SHOWEXPGAIN),
        GetString(LUIE_STRING_LAM_CA_EXP_SHOWEXPGAIN_TP),
        function ()
            return Settings.XP.Experience
        end,
        function (value)
            Settings.XP.Experience = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.XP.Experience
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_EXP_SHOWEXPICON),
        GetString(LUIE_STRING_LAM_CA_EXP_SHOWEXPICON_TP),
        function ()
            return Settings.XP.ExperienceIcon
        end,
        function (value)
            Settings.XP.ExperienceIcon = value
        end,
        "full",
        function ()
            return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_EXPERIENCE_COLORMESSAGE),
        nil,
        function ()
            return unpack(Settings.XP.ExperienceColorMessage)
        end,
        function (r, g, b, a)
            Settings.XP.ExperienceColorMessage = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.XP.ExperienceColorMessage,
        5,
        function ()
            return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_EXPERIENCE_COLORNAME),
        nil,
        function ()
            return unpack(Settings.XP.ExperienceColorName)
        end,
        function (r, g, b, a)
            Settings.XP.ExperienceColorName = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.XP.ExperienceColorName,
        5,
        function ()
            return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_EXP_MESSAGE),
        GetString(LUIE_STRING_LAM_CA_EXP_MESSAGE_TP),
        function ()
            return Settings.XP.ExperienceMessage
        end,
        function (value)
            Settings.XP.ExperienceMessage = value
        end,
        "full",
        function ()
            return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceMessage,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_EXP_NAME),
        GetString(LUIE_STRING_LAM_CA_EXP_NAME_TP),
        function ()
            return Settings.XP.ExperienceName
        end,
        function (value)
            Settings.XP.ExperienceName = value
        end,
        "full",
        function ()
            return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_EXP_HIDEEXPKILLS),
        GetString(LUIE_STRING_LAM_CA_EXP_HIDEEXPKILLS_TP),
        function ()
            return Settings.XP.ExperienceHideCombat
        end,
        function (value)
            Settings.XP.ExperienceHideCombat = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceHideCombat,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_EXPGAINTHRESHOLD),
        GetString(LUIE_STRING_LAM_CA_EXP_EXPGAINTHRESHOLD_TP),
        0, 10000, 100,
        function ()
            return Settings.XP.ExperienceFilter
        end,
        function (value)
            Settings.XP.ExperienceFilter = value
        end,
        "full",
        function ()
            return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceFilter,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_THROTTLEEXPINCOMBAT),
        GetString(LUIE_STRING_LAM_CA_EXP_THROTTLEEXPINCOMBAT_TP),
        0, 5000, 50,
        function ()
            return Settings.XP.ExperienceThrottle
        end,
        function (value)
            Settings.XP.ExperienceThrottle = value
        end,
        "full",
        function ()
            return not (Settings.XP.Experience and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.XP.ExperienceThrottle,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_HEADER_SKILL_POINTS)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Skills.SkillPointCA
        end,
        function (value)
            Settings.Skills.SkillPointCA = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillPointCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Skills.SkillPointCSA
        end,
        function (value)
            Settings.Skills.SkillPointCSA = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillPointCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Skills.SkillPointAlert
        end,
        function (value)
            Settings.Skills.SkillPointAlert = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillPointAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_SKILLPOINT_COLOR1),
        nil,
        function ()
            return unpack(Settings.Skills.SkillPointColor1)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillPointColor1 = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillPointColor1,
        5,
        function ()
            return not (Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_SKILLPOINT_COLOR2),
        nil,
        function ()
            return unpack(Settings.Skills.SkillPointColor2)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillPointColor2 = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillPointColor2,
        5,
        function ()
            return not (Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_SKILLPOINT_PARTIALPREFIX),
        GetString(LUIE_STRING_LAM_CA_SKILLPOINT_PARTIALPREFIX_TP),
        function ()
            return Settings.Skills.SkillPointSkyshard
        end,
        function (value)
            Settings.Skills.SkillPointSkyshard = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not (Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Skills.SkillPointSkyshard,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_SKILLPOINT_PARTIALBRACKET),
        GetString(LUIE_STRING_LAM_CA_SKILLPOINT_PARTIALBRACKET_TP),
        function ()
            local items = {}
            for i, option in ipairs(bracketOptions5) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return bracketOptions5[Settings.Skills.SkillPointBracket]
        end,
        function (combobox, value, item)
            Settings.Skills.SkillPointBracket = bracketOptions5Keys[value]
        end,
        bracketOptions5[Defaults.Skills.SkillPointBracket],
        function ()
            return not (Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATEDPARTIAL),
        GetString(LUIE_STRING_LAM_CA_SKILLPOINT_UPDATEDPARTIAL_TP),
        function ()
            return Settings.Skills.SkillPointsPartial
        end,
        function (value)
            Settings.Skills.SkillPointsPartial = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not (Settings.Skills.SkillPointCA or Settings.Skills.SkillPointCSA or Settings.Skills.SkillPointAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Skills.SkillPointsPartial,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_HEADER_SKILL_LINES)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Skills.SkillLineUnlockCA
        end,
        function (value)
            Settings.Skills.SkillLineUnlockCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillLineUnlockCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Skills.SkillLineUnlockCSA
        end,
        function (value)
            Settings.Skills.SkillLineUnlockCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillLineUnlockCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_UNLOCKED_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Skills.SkillLineUnlockAlert
        end,
        function (value)
            Settings.Skills.SkillLineUnlockAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillLineUnlockAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ICON),
        GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ICON_TP),
        function ()
            return Settings.Skills.SkillLineIcon
        end,
        function (value)
            Settings.Skills.SkillLineIcon = value
        end,
        "full",
        function ()
            return not (Settings.Skills.SkillLineUnlockCA or Settings.Skills.SkillLineUnlockCSA or Settings.Skills.SkillLineUnlockAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Skills.SkillLineIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Skills.SkillLineCA
        end,
        function (value)
            Settings.Skills.SkillLineCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillLineCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Skills.SkillLineCSA
        end,
        function (value)
            Settings.Skills.SkillLineCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillLineCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Skills.SkillLineAlert
        end,
        function (value)
            Settings.Skills.SkillLineAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillLineAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Skills.SkillAbilityCA
        end,
        function (value)
            Settings.Skills.SkillAbilityCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillAbilityCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Skills.SkillAbilityCSA
        end,
        function (value)
            Settings.Skills.SkillAbilityCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillAbilityCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SKILL_LINE_ABILITY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Skills.SkillAbilityAlert
        end,
        function (value)
            Settings.Skills.SkillAbilityAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillAbilityAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_SKILL_LINE_COLOR),
        nil,
        function ()
            return unpack(Settings.Skills.SkillLineColor)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillLineColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillLineColor,
        5,
        function ()
            return not (Settings.Skills.SkillLineUnlockCA or Settings.Skills.SkillLineUnlockCSA or Settings.Skills.SkillLineUnlockAlert or Settings.Skills.SkillLineAlertCA or Settings.Skills.SkillLineAlertCSA or Settings.Skills.SkillLineAlertAlert or Settings.Skills.SkillAbilityCA or Settings.Skills.SkillAbilityCSA or Settings.Skills.SkillAbilityAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_EXP_HEADER_GUILDREP)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_ICON),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_ICON_TP),
        function ()
            return Settings.Skills.SkillGuildIcon
        end,
        function (value)
            Settings.Skills.SkillGuildIcon = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildIcon
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGECOLOR),
        nil,
        function ()
            return unpack(Settings.Skills.SkillGuildColor)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillGuildColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillGuildColor,
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGEFORMAT),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGEFORMAT_TP),
        function ()
            return Settings.Skills.SkillGuildMsg
        end,
        function (value)
            Settings.Skills.SkillGuildMsg = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildMsg
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGENAME),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_MESSAGENAME_TP),
        function ()
            return Settings.Skills.SkillGuildRepName
        end,
        function (value)
            Settings.Skills.SkillGuildRepName = value
            ChatAnnouncements.RegisterXPEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildRepName
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_FG),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_FG_TP),
        function ()
            return Settings.Skills.SkillGuildFighters
        end,
        function (value)
            Settings.Skills.SkillGuildFighters = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildFighters
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_FG_COLOR),
        nil,
        function ()
            return unpack(Settings.Skills.SkillGuildColorFG)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillGuildColorFG = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillGuildColorFG,
        5,
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildFighters)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_THRESHOLD),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_THRESHOLD_TP),
        0, 5, 1,
        function ()
            return Settings.Skills.SkillGuildThreshold
        end,
        function (value)
            Settings.Skills.SkillGuildThreshold = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildFighters)
        end,
        Defaults.Skills.SkillGuildThreshold,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_THROTTLE),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_THROTTLE_TP),
        0, 5000, 50,
        function ()
            return Settings.Skills.SkillGuildThrottle
        end,
        function (value)
            Settings.Skills.SkillGuildThrottle = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildFighters)
        end,
        Defaults.Skills.SkillGuildThrottle,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_MG),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_MG_TP),
        function ()
            return Settings.Skills.SkillGuildMages
        end,
        function (value)
            Settings.Skills.SkillGuildMages = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildMages
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_MG_COLOR),
        nil,
        function ()
            return unpack(Settings.Skills.SkillGuildColorMG)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillGuildColorMG = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillGuildColorMG,
        5,
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildMages)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_UD),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_UD_TP),
        function ()
            return Settings.Skills.SkillGuildUndaunted
        end,
        function (value)
            Settings.Skills.SkillGuildUndaunted = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildUndaunted
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_UD_COLOR),
        nil,
        function ()
            return unpack(Settings.Skills.SkillGuildColorUD)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillGuildColorUD = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillGuildColorUD,
        5,
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildUndaunted)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_TG),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_TG_TP),
        function ()
            return Settings.Skills.SkillGuildThieves
        end,
        function (value)
            Settings.Skills.SkillGuildThieves = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildThieves
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_TG_COLOR),
        nil,
        function ()
            return unpack(Settings.Skills.SkillGuildColorTG)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillGuildColorTG = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillGuildColorTG,
        5,
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildThieves)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_DB),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_DB_TP),
        function ()
            return Settings.Skills.SkillGuildDarkBrotherhood
        end,
        function (value)
            Settings.Skills.SkillGuildDarkBrotherhood = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildDarkBrotherhood
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_DB_COLOR),
        nil,
        function ()
            return unpack(Settings.Skills.SkillGuildColorDB)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillGuildColorDB = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillGuildColorDB,
        5,
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildDarkBrotherhood)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_PO),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_PO_TP),
        function ()
            return Settings.Skills.SkillGuildPsijicOrder
        end,
        function (value)
            Settings.Skills.SkillGuildPsijicOrder = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildPsijicOrder
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_PO_COLOR),
        nil,
        function ()
            return unpack(Settings.Skills.SkillGuildColorPO)
        end,
        function (r, g, b, a)
            Settings.Skills.SkillGuildColorPO = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Skills.SkillGuildColorPO,
        5,
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Skills.SkillGuildDarkBrotherhood)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_GUILDREP_ALERT),
        GetString(LUIE_STRING_LAM_CA_GUILDREP_ALERT_TP),
        function ()
            return Settings.Skills.SkillGuildAlert
        end,
        function (value)
            Settings.Skills.SkillGuildAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Skills.SkillGuildAlert
    )

    -- Collectible/Lorebooks Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_COL_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Collectibles.CollectibleCA
        end,
        function (value)
            Settings.Collectibles.CollectibleCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Collectibles.CollectibleCSA
        end,
        function (value)
            Settings.Collectibles.CollectibleCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Collectibles.CollectibleAlert
        end,
        function (value)
            Settings.Collectibles.CollectibleAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ICON),
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ICON_TP),
        function ()
            return Settings.Collectibles.CollectibleIcon
        end,
        function (value)
            Settings.Collectibles.CollectibleIcon = value
        end,
        "full",
        function ()
            return not (Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Collectibles.CollectibleIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_COLLECTIBLE),
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_COLLECTIBLE_TP),
        function ()
            local items = {}
            for i, option in ipairs(linkBracketDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return linkBracketDisplayOptions[Settings.BracketOptionCollectible]
        end,
        function (combobox, value, item)
            Settings.BracketOptionCollectible = linkBracketDisplayOptionsKeys[value]
        end,
        linkBracketDisplayOptions[Defaults.BracketOptionCollectible],
        function ()
            return not (Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_COLOR_ONE),
        nil,
        function ()
            return unpack(Settings.Collectibles.CollectibleColor1)
        end,
        function (r, g, b, a)
            Settings.Collectibles.CollectibleColor1 = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Collectibles.CollectibleColor1,
        5,
        function ()
            return not (Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_COLOR_TWO),
        nil,
        function ()
            return unpack(Settings.Collectibles.CollectibleColor2)
        end,
        function (r, g, b, a)
            Settings.Collectibles.CollectibleColor2 = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Collectibles.CollectibleColor2,
        5,
        function ()
            return not (Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_MESSAGEPREFIX),
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_MESSAGEPREFIX_TP),
        function ()
            return Settings.Collectibles.CollectiblePrefix
        end,
        function (value)
            Settings.Collectibles.CollectiblePrefix = value
        end,
        "full",
        function ()
            return not (Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Collectibles.CollectiblePrefix,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_BRACKET),
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_BRACKET_TP),
        function ()
            local items = {}
            for i, option in ipairs(bracketOptions5) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return bracketOptions5[Settings.Collectibles.CollectibleBracket]
        end,
        function (combobox, value, item)
            Settings.Collectibles.CollectibleBracket = bracketOptions5Keys[value]
        end,
        bracketOptions5[Defaults.Collectibles.CollectibleBracket],
        function ()
            return not (Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_CATEGORY),
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_CATEGORY_TP),
        function ()
            return Settings.Collectibles.CollectibleCategory
        end,
        function (value)
            Settings.Collectibles.CollectibleCategory = value
        end,
        "full",
        function ()
            return not (Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Collectibles.CollectibleCategory,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_SUBCATEGORY),
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_SUBCATEGORY_TP),
        function ()
            return Settings.Collectibles.CollectibleSubcategory
        end,
        function (value)
            Settings.Collectibles.CollectibleSubcategory = value
        end,
        "full",
        function ()
            return not (Settings.Collectibles.CollectibleCA or Settings.Collectibles.CollectibleCSA or Settings.Collectibles.CollectibleAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Collectibles.CollectibleSubcategory,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Collectibles.CollectibleUseCA
        end,
        function (value)
            Settings.Collectibles.CollectibleUseCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleUseCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Collectibles.CollectibleUseAlert
        end,
        function (value)
            Settings.Collectibles.CollectibleUseAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleUseAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_PET_NICKNAME),
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_PET_NICKNAME_TP),
        function ()
            return Settings.Collectibles.CollectibleUsePetNickname
        end,
        function (value)
            Settings.Collectibles.CollectibleUsePetNickname = value
        end,
        "full",
        function ()
            return not (Settings.Collectibles.CollectibleUseCA or Settings.Collectibles.CollectibleUseAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Collectibles.CollectibleUsePetNickname,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_ICON),
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_ICON_TP),
        function ()
            return Settings.Collectibles.CollectibleUseIcon
        end,
        function (value)
            Settings.Collectibles.CollectibleUseIcon = value
        end,
        "full",
        function ()
            return not (Settings.Collectibles.CollectibleUseCA or Settings.Collectibles.CollectibleUseAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Collectibles.CollectibleUseIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_COLLECTIBLE),
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_COLLECTIBLE_TP),
        function ()
            local items = {}
            for i, option in ipairs(linkBracketDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return linkBracketDisplayOptions[Settings.BracketOptionCollectibleUse]
        end,
        function (combobox, value, item)
            Settings.BracketOptionCollectibleUse = linkBracketDisplayOptionsKeys[value]
        end,
        linkBracketDisplayOptions[Defaults.BracketOptionCollectibleUse],
        function ()
            return not (Settings.Collectibles.CollectibleUseCA or Settings.Collectibles.CollectibleUseAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_COLOR_ONE),
        nil,
        function ()
            return unpack(Settings.Collectibles.CollectibleUseColor)
        end,
        function (r, g, b, a)
            Settings.Collectibles.CollectibleUseColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Collectibles.CollectibleUseColor,
        5,
        function ()
            return not (Settings.Collectibles.CollectibleUseCA or Settings.Collectibles.CollectibleUseAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY), GetCollectibleCategoryInfoName(3)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY_TP), GetCollectibleCategoryInfoName(3)),
        function ()
            return Settings.Collectibles.CollectibleUseCategory3
        end,
        function (value)
            Settings.Collectibles.CollectibleUseCategory3 = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleUseCategory3
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY), GetCollectibleCategoryInfoName(7)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY_TP), GetCollectibleCategoryInfoName(7)),
        function ()
            return Settings.Collectibles.CollectibleUseCategory7
        end,
        function (value)
            Settings.Collectibles.CollectibleUseCategory7 = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleUseCategory7
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY), GetCollectibleCategoryInfoName(10)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY_TP), GetCollectibleCategoryInfoName(10)),
        function ()
            return Settings.Collectibles.CollectibleUseCategory10
        end,
        function (value)
            Settings.Collectibles.CollectibleUseCategory10 = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleUseCategory10
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY), GetCollectibleCategoryInfoName(12)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_USE_CATEGORY_TP), GetCollectibleCategoryInfoName(12)),
        function ()
            return Settings.Collectibles.CollectibleUseCategory12
        end,
        function (value)
            Settings.Collectibles.CollectibleUseCategory12 = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Collectibles.CollectibleUseCategory12
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_COLLECTIBLE_LORE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_LOREBOOK),
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_LOREBOOK_TP),
        function ()
            local items = {}
            for i, option in ipairs(linkBracketDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return linkBracketDisplayOptions[Settings.BracketOptionLorebook]
        end,
        function (combobox, value, item)
            Settings.BracketOptionLorebook = linkBracketDisplayOptionsKeys[value]
        end,
        linkBracketDisplayOptions[Defaults.BracketOptionLorebook],
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Lorebooks.LorebookCA
        end,
        function (value)
            Settings.Lorebooks.LorebookCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Lorebooks.LorebookCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Lorebooks.LorebookCSA
        end,
        function (value)
            Settings.Lorebooks.LorebookCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Lorebooks.LorebookCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_CSA_LOREONLY),
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_CSA_LOREONLY_TP),
        function ()
            return Settings.Lorebooks.LorebookCSALoreOnly
        end,
        function (value)
            Settings.Lorebooks.LorebookCSALoreOnly = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Lorebooks.LorebookCSA)
        end,
        Defaults.Lorebooks.LorebookCSALoreOnly,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Lorebooks.LorebookAlert
        end,
        function (value)
            Settings.Lorebooks.LorebookAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Lorebooks.LorebookAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Lorebooks.LorebookCollectionCA
        end,
        function (value)
            Settings.Lorebooks.LorebookCollectionCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Lorebooks.LorebookCollectionCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Lorebooks.LorebookCollectionCSA
        end,
        function (value)
            Settings.Lorebooks.LorebookCollectionCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Lorebooks.LorebookCollectionCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLLECTION_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Lorebooks.LorebookCollectionAlert
        end,
        function (value)
            Settings.Lorebooks.LorebookCollectionAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Lorebooks.LorebookCollectionAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_ICON),
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_ICON_TP),
        function ()
            return Settings.Lorebooks.LorebookIcon
        end,
        function (value)
            Settings.Lorebooks.LorebookIcon = value
        end,
        "full",
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Lorebooks.LorebookIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLOR1),
        nil,
        function ()
            return unpack(Settings.Lorebooks.LorebookColor1)
        end,
        function (r, g, b, a)
            Settings.Lorebooks.LorebookColor1 = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Lorebooks.LorebookColor1,
        5,
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_COLOR2),
        nil,
        function ()
            return unpack(Settings.Lorebooks.LorebookColor2)
        end,
        function (r, g, b, a)
            Settings.Lorebooks.LorebookColor2 = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Lorebooks.LorebookColor2,
        5,
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX1),
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX1_TP),
        function ()
            return Settings.Lorebooks.LorebookPrefix1
        end,
        function (value)
            Settings.Lorebooks.LorebookPrefix1 = value
        end,
        "full",
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Lorebooks.LorebookPrefix1,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX2),
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX2_TP),
        function ()
            return Settings.Lorebooks.LorebookPrefix2
        end,
        function (value)
            Settings.Lorebooks.LorebookPrefix2 = value
        end,
        "full",
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Lorebooks.LorebookPrefix2,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX_COLLECTION),
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_PREFIX_COLLECTION_TP),
        function ()
            return Settings.Lorebooks.LorebookCollectionPrefix
        end,
        function (value)
            Settings.Lorebooks.LorebookCollectionPrefix = value
        end,
        "full",
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Lorebooks.LorebookCollectionPrefix,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_CATEGORY_BRACKET),
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_CATEGORY_BRACKET_TP),
        function ()
            local items = {}
            for i, option in ipairs(bracketOptions5) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return bracketOptions5[Settings.Lorebooks.LorebookBracket]
        end,
        function (combobox, value, item)
            Settings.Lorebooks.LorebookBracket = bracketOptions5Keys[value]
        end,
        bracketOptions5[Defaults.Lorebooks.LorebookBracket],
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_CATEGORY),
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_CATEGORY_TP),
        function ()
            return Settings.Lorebooks.LorebookCategory
        end,
        function (value)
            Settings.Lorebooks.LorebookCategory = value
        end,
        "full",
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Lorebooks.LorebookCategory,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_NOSHOWHIDE),
        GetString(LUIE_STRING_LAM_CA_LOREBOOK_NOSHOWHIDE_TP),
        function ()
            return Settings.Lorebooks.LorebookShowHidden
        end,
        function (value)
            Settings.Lorebooks.LorebookShowHidden = value
        end,
        "full",
        function ()
            return not (Settings.Lorebooks.LorebookCA or Settings.Lorebooks.LorebookCSA or Settings.Lorebooks.LorebookAlert or Settings.Lorebooks.LorebookCollectionCA or Settings.Lorebooks.LorebookCollectionCSA or Settings.Lorebooks.LorebookCollectionAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Lorebooks.LorebookShowHidden,
        5
    )

    -- Antiquities Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_LEAD_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Antiquities.AntiquityCA
        end,
        function (value)
            Settings.Antiquities.AntiquityCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Antiquities.AntiquityCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Antiquities.AntiquityCSA
        end,
        function (value)
            Settings.Antiquities.AntiquityCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Antiquities.AntiquityCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ENABLE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Antiquities.AntiquityAlert
        end,
        function (value)
            Settings.Antiquities.AntiquityAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Antiquities.AntiquityAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_BRACKET),
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_BRACKET_TP),
        function ()
            local items = {}
            for i, option in ipairs(linkBracketDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return linkBracketDisplayOptions[Settings.Antiquities.AntiquityBracket]
        end,
        function (combobox, value, item)
            Settings.Antiquities.AntiquityBracket = linkBracketDisplayOptionsKeys[value]
        end,
        linkBracketDisplayOptions[Defaults.Antiquities.AntiquityBracket],
        function ()
            return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ICON),
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_ICON_TP),
        function ()
            return Settings.Antiquities.AntiquityIcon
        end,
        function (value)
            Settings.Antiquities.AntiquityIcon = value
        end,
        "full",
        function ()
            return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Antiquities.AntiquityIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_COLOR),
        nil,
        function ()
            return unpack(Settings.Antiquities.AntiquityColor)
        end,
        function (r, g, b, a)
            Settings.Antiquities.AntiquityColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Antiquities.AntiquityColor,
        5,
        function ()
            return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_PREFIX),
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_PREFIX_TP),
        function ()
            return Settings.Antiquities.AntiquityPrefix
        end,
        function (value)
            Settings.Antiquities.AntiquityPrefix = value
        end,
        "full",
        function ()
            return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Antiquities.AntiquityPrefix,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_PREFIX_BRACKET),
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_PREFIX_BRACKET_TP),
        function ()
            local items = {}
            for i, option in ipairs(bracketOptions5) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return bracketOptions5[Settings.Antiquities.AntiquityPrefixBracket]
        end,
        function (combobox, value, item)
            Settings.Antiquities.AntiquityPrefixBracket = bracketOptions5Keys[value]
        end,
        bracketOptions5[Defaults.Antiquities.AntiquityPrefixBracket],
        function ()
            return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_SUFFIX),
        GetString(LUIE_STRING_LAM_CA_ANTIQUITY_SUFFIX_TP),
        function ()
            return Settings.Antiquities.AntiquitySuffix
        end,
        function (value)
            Settings.Antiquities.AntiquitySuffix = value
        end,
        "full",
        function ()
            return not (Settings.Antiquities.AntiquityCA or Settings.Antiquities.AntiquityCSA or Settings.Antiquities.AntiquityAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Antiquities.AntiquitySuffix,
        5
    )

    -- Achievements Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Achievement.AchievementUpdateCA
        end,
        function (value)
            Settings.Achievement.AchievementUpdateCA = value
            ChatAnnouncements.RegisterAchievementsEvent()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Achievement.AchievementUpdateCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Achievement.AchievementUpdateAlert
        end,
        function (value)
            Settings.Achievement.AchievementUpdateAlert = value
            ChatAnnouncements.RegisterAchievementsEvent()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Achievement.AchievementUpdateAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_DETAILINFO),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_DETAILINFO_TP),
        function ()
            return Settings.Achievement.AchievementDetails
        end,
        function (value)
            Settings.Achievement.AchievementDetails = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementDetails,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_STEPSIZE),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_STEPSIZE_TP),
        0, 50, 1,
        function ()
            return Settings.Achievement.AchievementStep
        end,
        function (value)
            Settings.Achievement.AchievementStep = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementStep,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Achievement.AchievementCompleteCA
        end,
        function (value)
            Settings.Achievement.AchievementCompleteCA = value
            ChatAnnouncements.RegisterAchievementsEvent()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Achievement.AchievementCompleteCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Achievement.AchievementCompleteCSA
        end,
        function (value)
            Settings.Achievement.AchievementCompleteCSA = value
            ChatAnnouncements.RegisterAchievementsEvent()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Achievement.AchievementCompleteCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_CSA_ALWAYS),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_CSA_ALWAYS_TP),
        function ()
            return Settings.Achievement.AchievementCompleteAlwaysCSA
        end,
        function (value)
            Settings.Achievement.AchievementCompleteAlwaysCSA = value
            ChatAnnouncements.RegisterAchievementsEvent()
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and Settings.Achievement.AchievementCompleteCSA)
        end,
        Defaults.Achievement.AchievementCompleteAlwaysCSA,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Achievement.AchievementCompleteAlert
        end,
        function (value)
            Settings.Achievement.AchievementCompleteAlert = value
            ChatAnnouncements.RegisterAchievementsEvent()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Achievement.AchievementCompleteAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETEPERCENT),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETEPERCENT_TP),
        function ()
            return Settings.Achievement.AchievementCompPercentage
        end,
        function (value)
            Settings.Achievement.AchievementCompPercentage = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementCompPercentage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_ICON),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_ICON_TP),
        function ()
            return Settings.Achievement.AchievementIcon
        end,
        function (value)
            Settings.Achievement.AchievementIcon = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementIcon
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_ACHIEVEMENT),
        GetString(LUIE_STRING_LAM_CA_BRACKET_OPTION_ACHIEVEMENT_TP),
        function ()
            local items = {}
            for i, option in ipairs(linkBracketDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return linkBracketDisplayOptions[Settings.BracketOptionAchievement]
        end,
        function (combobox, value, item)
            Settings.BracketOptionAchievement = linkBracketDisplayOptionsKeys[value]
        end,
        Defaults.BracketOptionAchievement,
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COLOR1),
        nil,
        function ()
            return unpack(Settings.Achievement.AchievementColor1)
        end,
        function (r, g, b, a)
            Settings.Achievement.AchievementColor1 = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Achievement.AchievementColor1,
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COLOR2),
        nil,
        function ()
            return unpack(Settings.Achievement.AchievementColor2)
        end,
        function (r, g, b, a)
            Settings.Achievement.AchievementColor2 = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Achievement.AchievementColor2,
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_PROGMSG),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_PROGMSG_TP),
        function ()
            return Settings.Achievement.AchievementProgressMsg
        end,
        function (value)
            Settings.Achievement.AchievementProgressMsg = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementProgressMsg
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETEMSG),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COMPLETEMSG_TP),
        function ()
            return Settings.Achievement.AchievementCompleteMsg
        end,
        function (value)
            Settings.Achievement.AchievementCompleteMsg = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementCompleteMsg
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_SHOWCATEGORY),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_SHOWCATEGORY_TP),
        function ()
            return Settings.Achievement.AchievementCategory
        end,
        function (value)
            Settings.Achievement.AchievementCategory = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementCategory
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_SHOWSUBCATEGORY),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_SHOWSUBCATEGORY_TP),
        function ()
            return Settings.Achievement.AchievementSubcategory
        end,
        function (value)
            Settings.Achievement.AchievementSubcategory = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementSubcategory
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_BRACKET),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_BRACKET_TP),
        function ()
            local items = {}
            for i, option in ipairs(bracketOptions5) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return bracketOptions5[Settings.Achievement.AchievementBracketOptions]
        end,
        function (combobox, value, item)
            Settings.Achievement.AchievementBracketOptions = bracketOptions5Keys[value]
        end,
        bracketOptions5[Defaults.Achievement.AchievementBracketOptions],
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORYBRACKET),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORYBRACKET_TP),
        function ()
            local items = {}
            for i, option in ipairs(bracketOptions4) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return bracketOptions4[Settings.Achievement.AchievementCatBracketOptions]
        end,
        function (combobox, value, item)
            Settings.Achievement.AchievementCatBracketOptions = bracketOptions4Keys[value]
        end,
        bracketOptions4[Defaults.Achievement.AchievementCatBracketOptions],
        function ()
            return not (Settings.Achievement.AchievementCategory or Settings.Achievement.AchievementSubcategory) or not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COLORPROGRESS),
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_COLORPROGRESS_TP),
        function ()
            return Settings.Achievement.AchievementColorProgress
        end,
        function (value)
            Settings.Achievement.AchievementColorProgress = value
        end,
        "full",
        function ()
            return not (Settings.Achievement.AchievementCompleteCA or Settings.Achievement.AchievementCompleteCSA or Settings.Achievement.AchievementCompleteAlert or Settings.Achievement.AchievementUpdateCA or Settings.Achievement.AchievementUpdateAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Achievement.AchievementColorProgress
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORY_HEADER)
    )

    -- Dynamic Achievement Categories
    for i = 1, GetNumAchievementCategories() do
        local name = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORY), GetAchievementCategoryInfoName(i))
        local tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_ACHIEVE_CATEGORY_TP), GetAchievementCategoryInfoName(i))
        settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
            name,
            tooltip,
            function ()
                return not Settings.Achievement.AchievementCategoryIgnore[i]
            end,
            function (value)
                if value then
                    Settings.Achievement.AchievementCategoryIgnore[i] = nil
                else
                    Settings.Achievement.AchievementCategoryIgnore[i] = true
                end
            end,
            "full",
            function ()
                return not LUIE.SV.ChatAnnouncements_Enable
            end,
            not Defaults.Achievement.AchievementCategoryIgnore[i]
        )
    end

    -- Quest Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_QUEST_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTSHARE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTSHARE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Quests.QuestShareCA
        end,
        function (value)
            Settings.Quests.QuestShareCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestShareCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTSHARE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTSHARE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Quests.QuestShareAlert
        end,
        function (value)
            Settings.Quests.QuestShareAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestShareAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Quests.QuestLocDiscoveryCA
        end,
        function (value)
            Settings.Quests.QuestLocDiscoveryCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocDiscoveryCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Quests.QuestLocDiscoveryCSA
        end,
        function (value)
            Settings.Quests.QuestLocDiscoveryCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocDiscoveryCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_LOCATION_DISCOVERY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Quests.QuestLocDiscoveryAlert
        end,
        function (value)
            Settings.Quests.QuestLocDiscoveryAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocDiscoveryAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Quests.QuestLocObjectiveCA
        end,
        function (value)
            Settings.Quests.QuestLocObjectiveCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocObjectiveCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Quests.QuestLocObjectiveCSA
        end,
        function (value)
            Settings.Quests.QuestLocObjectiveCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocObjectiveCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_OBJECTIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Quests.QuestLocObjectiveAlert
        end,
        function (value)
            Settings.Quests.QuestLocObjectiveAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocObjectiveAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Quests.QuestLocCompleteCA
        end,
        function (value)
            Settings.Quests.QuestLocCompleteCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocCompleteCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Quests.QuestLocCompleteCSA
        end,
        function (value)
            Settings.Quests.QuestLocCompleteCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocCompleteCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_POI_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Quests.QuestLocCompleteAlert
        end,
        function (value)
            Settings.Quests.QuestLocCompleteAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocCompleteAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Quests.QuestFailCA
        end,
        function (value)
            Settings.Quests.QuestFailCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestFailCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Quests.QuestFailCSA
        end,
        function (value)
            Settings.Quests.QuestFailCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestFailCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_FAILURE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Quests.QuestFailAlert
        end,
        function (value)
            Settings.Quests.QuestFailAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestFailAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Quests.QuestObjUpdateCA
        end,
        function (value)
            Settings.Quests.QuestObjUpdateCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestObjUpdateCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Quests.QuestObjUpdateCSA
        end,
        function (value)
            Settings.Quests.QuestObjUpdateCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestObjUpdateCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_UPDATE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Quests.QuestObjUpdateAlert
        end,
        function (value)
            Settings.Quests.QuestObjUpdateAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestObjUpdateAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Quests.QuestObjCompleteCA
        end,
        function (value)
            Settings.Quests.QuestObjCompleteCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestObjCompleteCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Quests.QuestObjCompleteCSA
        end,
        function (value)
            Settings.Quests.QuestObjCompleteCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestObjCompleteCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_QUEST_OBJECTIVE_COMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Quests.QuestObjCompleteAlert
        end,
        function (value)
            Settings.Quests.QuestObjCompleteAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestObjCompleteAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTICON),
        GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTICON_TP),
        function ()
            return Settings.Quests.QuestIcon
        end,
        function (value)
            Settings.Quests.QuestIcon = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_QUEST_COLOR1),
        nil,
        function ()
            return unpack(Settings.Quests.QuestColorLocName)
        end,
        function (r, g, b, a)
            Settings.Quests.QuestColorLocName = { r, g, b }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Quests.QuestColorLocName,
        5,
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_QUEST_COLOR2),
        nil,
        function ()
            return unpack(Settings.Quests.QuestColorLocDescription)
        end,
        function (r, g, b, a)
            Settings.Quests.QuestColorLocDescription = { r, g, b }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Quests.QuestColorLocDescription,
        5,
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_QUEST_COLOR3),
        nil,
        function ()
            return unpack(Settings.Quests.QuestColorName)
        end,
        function (r, g, b, a)
            Settings.Quests.QuestColorName = { r, g, b }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Quests.QuestColorName,
        5,
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_QUEST_COLOR4),
        nil,
        function ()
            return unpack(Settings.Quests.QuestColorDescription)
        end,
        function (r, g, b, a)
            Settings.Quests.QuestColorDescription = { r, g, b }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Quests.QuestColorDescription,
        5,
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTLONG),
        GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTLONG_TP),
        function ()
            return Settings.Quests.QuestLong
        end,
        function (value)
            Settings.Quests.QuestLong = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLong,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTOBJECTIVELONG),
        GetString(LUIE_STRING_LAM_CA_QUEST_SHOWQUESTOBJECTIVELONG_TP),
        function ()
            return Settings.Quests.QuestLocLong
        end,
        function (value)
            Settings.Quests.QuestLocLong = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Quests.QuestLocLong,
        5
    )

    -- Social Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.FriendIgnoreCA
        end,
        function (value)
            Settings.Social.FriendIgnoreCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.FriendIgnoreCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.FriendIgnoreAlert
        end,
        function (value)
            Settings.Social.FriendIgnoreAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.FriendIgnoreAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.FriendStatusCA
        end,
        function (value)
            Settings.Social.FriendStatusCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.FriendStatusCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_FRIENDS_ONOFF_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.FriendStatusAlert
        end,
        function (value)
            Settings.Social.FriendStatusAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.FriendStatusAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.GuildCA
        end,
        function (value)
            Settings.Social.GuildCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.GuildCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.GuildAlert
        end,
        function (value)
            Settings.Social.GuildAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.GuildAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANK), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANK_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.GuildRankCA
        end,
        function (value)
            Settings.Social.GuildRankCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.GuildRankCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANK), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANK_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.GuildRankAlert
        end,
        function (value)
            Settings.Social.GuildRankAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.GuildRankAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANKOPTIONS),
        GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_RANKOPTIONS_TP),
        function ()
            local items = {}
            for i, option in ipairs(guildRankDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return guildRankDisplayOptions[Settings.Social.GuildRankDisplayOptions]
        end,
        function (combobox, value, item)
            Settings.Social.GuildRankDisplayOptions = guildRankDisplayOptionsKeys[value]
        end,
        guildRankDisplayOptions[Defaults.Social.GuildRankDisplayOptions],
        function ()
            return not (Settings.Social.GuildRankCA or Settings.Social.GuildRankAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ADMIN), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ADMIN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.GuildManageCA
        end,
        function (value)
            Settings.Social.GuildManageCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.GuildManageCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ADMIN), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ADMIN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.GuildManageAlert
        end,
        function (value)
            Settings.Social.GuildManageAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.GuildManageAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ICONS),
        GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_ICONS_TP),
        function ()
            return Settings.Social.GuildIcon
        end,
        function (value)
            Settings.Social.GuildIcon = value
        end,
        "full",
        function ()
            return not (Settings.Social.GuildCA or Settings.Social.GuildAlert or Settings.Social.GuildRankCA or Settings.Social.GuildRankAlert or Settings.Social.GuildManageCA or Settings.Social.GuildManageAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Social.GuildIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_COLOR),
        nil,
        function ()
            return unpack(Settings.Social.GuildColor)
        end,
        function (r, g, b, a)
            Settings.Social.GuildColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Social.GuildColor,
        5,
        function ()
            return not (Settings.Social.GuildCA or Settings.Social.GuildAlert or Settings.Social.GuildRankCA or Settings.Social.GuildRankAlert or Settings.Social.GuildManageCA or Settings.Social.GuildManageAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_COLOR_ALLIANCE),
        GetString(LUIE_STRING_LAM_CA_SOCIAL_GUILD_COLOR_ALLIANCE_TP),
        function ()
            return Settings.Social.GuildAllianceColor
        end,
        function (value)
            Settings.Social.GuildAllianceColor = value
        end,
        "full",
        function ()
            return not (Settings.Social.GuildCA or Settings.Social.GuildAlert or Settings.Social.GuildRankCA or Settings.Social.GuildRankAlert or Settings.Social.GuildManageCA or Settings.Social.GuildManageAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Social.GuildAllianceColor,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.NotificationTradeCA
        end,
        function (value)
            Settings.Notify.NotificationTradeCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationTradeCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_TRADE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.NotificationTradeAlert
        end,
        function (value)
            Settings.Notify.NotificationTradeAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationTradeAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.DuelCA
        end,
        function (value)
            Settings.Social.DuelCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUEL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.DuelAlert
        end,
        function (value)
            Settings.Social.DuelAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.DuelStartCA
        end,
        function (value)
            Settings.Social.DuelStartCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelStartCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_TPCSA), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Social.DuelStartCSA
        end,
        function (value)
            Settings.Social.DuelStartCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelStartCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.DuelStartAlert
        end,
        function (value)
            Settings.Social.DuelStartAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelStartAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_OPTION),
        GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELSTART_OPTION_TP),
        function ()
            local items = {}
            for i, option in ipairs(duelStartOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return duelStartOptions[Settings.Social.DuelStartOptions]
        end,
        function (combobox, value, item)
            Settings.Social.DuelStartOptions = duelStartOptionsKeys[value]
        end,
        duelStartOptions[1],
        function ()
            return not (Settings.Social.DuelStartCA or Settings.Social.DuelStartCSA or Settings.Social.DuelStartAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.DuelWonCA
        end,
        function (value)
            Settings.Social.DuelWonCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelWonCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Social.DuelWonCSA
        end,
        function (value)
            Settings.Social.DuelWonCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelWonCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.DuelWonAlert
        end,
        function (value)
            Settings.Social.DuelWonAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelWonAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.DuelBoundaryCA
        end,
        function (value)
            Settings.Social.DuelBoundaryCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelBoundaryCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Social.DuelBoundaryCSA
        end,
        function (value)
            Settings.Social.DuelBoundaryCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelBoundaryCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_SOCIAL_DUELBOUNDARY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.DuelBoundaryAlert
        end,
        function (value)
            Settings.Social.DuelBoundaryAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.DuelBoundaryAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_SOCIAL_MARA_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Social.PledgeOfMaraCA
        end,
        function (value)
            Settings.Social.PledgeOfMaraCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.PledgeOfMaraCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Social.PledgeOfMaraCSA
        end,
        function (value)
            Settings.Social.PledgeOfMaraCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.PledgeOfMaraCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_MARA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Social.PledgeOfMaraAlert
        end,
        function (value)
            Settings.Social.PledgeOfMaraAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Social.PledgeOfMaraAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_MISC_MARA_ALERT),
        GetString(LUIE_STRING_LAM_CA_MISC_MARA_ALERT_TP),
        function ()
            return Settings.Social.PledgeOfMaraAlertOnlyFail
        end,
        function (value)
            Settings.Social.PledgeOfMaraAlertOnlyFail = value
        end,
        "full",
        function ()
            return not (Settings.Social.PledgeOfMaraAlert and LUIE.SV.ChatAnnouncements_Enable)
        end,
        Defaults.Social.PledgeOfMaraAlertOnlyFail,
        5
    )

    -- Group Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_GROUP_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_GROUP_BASE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupCA
        end,
        function (value)
            Settings.Group.GroupCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupAlert
        end,
        function (value)
            Settings.Group.GroupAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_GROUP_LFG_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGREADY), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGREADY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupLFGCA
        end,
        function (value)
            Settings.Group.GroupLFGCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupLFGCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGREADY), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGREADY_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupLFGAlert
        end,
        function (value)
            Settings.Group.GroupLFGAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupLFGAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGQUEUE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGQUEUE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupLFGQueueCA
        end,
        function (value)
            Settings.Group.GroupLFGQueueCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupLFGQueueCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGQUEUE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGQUEUE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupLFGQueueAlert
        end,
        function (value)
            Settings.Group.GroupLFGQueueAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupLFGQueueAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGVOTE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGVOTE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupVoteCA
        end,
        function (value)
            Settings.Group.GroupVoteCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupVoteCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGVOTE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGVOTE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupVoteAlert
        end,
        function (value)
            Settings.Group.GroupVoteAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupVoteAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupLFGCompleteCA
        end,
        function (value)
            Settings.Group.GroupLFGCompleteCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupLFGCompleteCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Group.GroupLFGCompleteCSA
        end,
        function (value)
            Settings.Group.GroupLFGCompleteCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupLFGCompleteCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_LFGCOMPLETE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupLFGCompleteAlert
        end,
        function (value)
            Settings.Group.GroupLFGCompleteAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupLFGCompleteAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_GROUP_RAID_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupRaidCA
        end,
        function (value)
            Settings.Group.GroupRaidCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Group.GroupRaidCSA
        end,
        function (value)
            Settings.Group.GroupRaidCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BASE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupRaidAlert
        end,
        function (value)
            Settings.Group.GroupRaidAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupRaidScoreCA
        end,
        function (value)
            Settings.Group.GroupRaidScoreCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidScoreCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Group.GroupRaidScoreCSA
        end,
        function (value)
            Settings.Group.GroupRaidScoreCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidScoreCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_SCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupRaidScoreAlert
        end,
        function (value)
            Settings.Group.GroupRaidScoreAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidScoreAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupRaidBestScoreCA
        end,
        function (value)
            Settings.Group.GroupRaidBestScoreCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidBestScoreCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Group.GroupRaidBestScoreCSA
        end,
        function (value)
            Settings.Group.GroupRaidBestScoreCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidBestScoreCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_BESTSCORE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupRaidBestScoreAlert
        end,
        function (value)
            Settings.Group.GroupRaidBestScoreAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidBestScoreAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Group.GroupRaidReviveCA
        end,
        function (value)
            Settings.Group.GroupRaidReviveCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidReviveCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Group.GroupRaidReviveCSA
        end,
        function (value)
            Settings.Group.GroupRaidReviveCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidReviveCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_GROUP_RAID_REVIVE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Group.GroupRaidReviveAlert
        end,
        function (value)
            Settings.Group.GroupRaidReviveAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Group.GroupRaidReviveAlert
    )

    -- Display Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CA_DISPLAY_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "* Show Display Announcement Debug Message *",
        "Display a debug message when a Display Announcement that has not yet been added to LUIE is triggered. Enable this option if you'd like to help out with the addon by posting the messages you receive from this event. Do not enable if you are not using the English client.",
        function ()
            return Settings.DisplayAnnouncements.Debug
        end,
        function (value)
            Settings.DisplayAnnouncements.Debug = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.Debug
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.DisplayAnnouncements.General.CA
        end,
        function (value)
            Settings.DisplayAnnouncements.General.CA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.General.CA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.DisplayAnnouncements.General.CSA
        end,
        function (value)
            Settings.DisplayAnnouncements.General.CSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.General.CSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GENERAL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.DisplayAnnouncements.General.Alert
        end,
        function (value)
            Settings.DisplayAnnouncements.General.Alert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.General.Alert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_MISC)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.DisplayAnnouncements.Respec.CA
        end,
        function (value)
            Settings.DisplayAnnouncements.Respec.CA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.Respec.CA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.DisplayAnnouncements.Respec.CSA
        end,
        function (value)
            Settings.DisplayAnnouncements.Respec.CSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.Respec.CSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_RESPEC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.DisplayAnnouncements.Respec.Alert
        end,
        function (value)
            Settings.DisplayAnnouncements.Respec.Alert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.Respec.Alert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.DisplayAnnouncements.GroupArea.CA
        end,
        function (value)
            Settings.DisplayAnnouncements.GroupArea.CA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.GroupArea.CA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.DisplayAnnouncements.GroupArea.CSA
        end,
        function (value)
            Settings.DisplayAnnouncements.GroupArea.CSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.GroupArea.CSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_MISC_GROUPAREA_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.DisplayAnnouncements.GroupArea.Alert
        end,
        function (value)
            Settings.DisplayAnnouncements.GroupArea.Alert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.GroupArea.Alert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_ZONE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.DisplayAnnouncements.ZoneCraglorn.CA
        end,
        function (value)
            Settings.DisplayAnnouncements.ZoneCraglorn.CA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ZoneCraglorn.CA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.DisplayAnnouncements.ZoneCraglorn.CSA
        end,
        function (value)
            Settings.DisplayAnnouncements.ZoneCraglorn.CSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ZoneCraglorn.CSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_CRAGLORN_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.DisplayAnnouncements.ZoneCraglorn.Alert
        end,
        function (value)
            Settings.DisplayAnnouncements.ZoneCraglorn.Alert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ZoneCraglorn.Alert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.DisplayAnnouncements.ZoneIC.CA
        end,
        function (value)
            Settings.DisplayAnnouncements.ZoneIC.CA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ZoneIC.CA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_DESCRIPTION),
        GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_DESCRIPTION_TP),
        function ()
            return Settings.DisplayAnnouncements.ZoneIC.Description
        end,
        function (value)
            Settings.DisplayAnnouncements.ZoneIC.Description = value
        end,
        "full",
        function ()
            return not (LUIE.SV.ChatAnnouncements_Enable and (Settings.DisplayAnnouncements.ZoneIC.CA or Settings.DisplayAnnouncements.ZoneIC.CSA or Settings.DisplayAnnouncements.ZoneIC.Alert))
        end,
        Defaults.DisplayAnnouncements.ZoneIC.Description,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.DisplayAnnouncements.ZoneIC.CSA
        end,
        function (value)
            Settings.DisplayAnnouncements.ZoneIC.CSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ZoneIC.CSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ZONE_IC_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.DisplayAnnouncements.ZoneIC.Alert
        end,
        function (value)
            Settings.DisplayAnnouncements.ZoneIC.Alert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ZoneIC.Alert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_ARENA)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.DisplayAnnouncements.ArenaMaelstrom.CA
        end,
        function (value)
            Settings.DisplayAnnouncements.ArenaMaelstrom.CA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ArenaMaelstrom.CA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.DisplayAnnouncements.ArenaMaelstrom.CSA
        end,
        function (value)
            Settings.DisplayAnnouncements.ArenaMaelstrom.CSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ArenaMaelstrom.CSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_ARENA_MAELSTROM_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.DisplayAnnouncements.ArenaMaelstrom.Alert
        end,
        function (value)
            Settings.DisplayAnnouncements.ArenaMaelstrom.Alert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.ArenaMaelstrom.Alert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_DISPLAY_HEADER_DUNGEON)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.DisplayAnnouncements.DungeonEndlessArchive.CA
        end,
        function (value)
            Settings.DisplayAnnouncements.DungeonEndlessArchive.CA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.DungeonEndlessArchive.CA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.DisplayAnnouncements.DungeonEndlessArchive.CSA
        end,
        function (value)
            Settings.DisplayAnnouncements.DungeonEndlessArchive.CSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.DungeonEndlessArchive.CSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_DISPLAY_DUNGEON_ENDLESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.DisplayAnnouncements.DungeonEndlessArchive.Alert
        end,
        function (value)
            Settings.DisplayAnnouncements.DungeonEndlessArchive.Alert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.DisplayAnnouncements.DungeonEndlessArchive.Alert
    )

    -- Miscellaneous Announcements Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CA_MISC_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAIL), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAIL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.NotificationMailSendCA
        end,
        function (value)
            Settings.Notify.NotificationMailSendCA = value
            ChatAnnouncements.RegisterMailEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationMailSendCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAIL), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAIL_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.NotificationMailSendAlert
        end,
        function (value)
            Settings.Notify.NotificationMailSendAlert = value
            ChatAnnouncements.RegisterMailEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationMailSendAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAILERROR), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAILERROR_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.NotificationMailErrorCA
        end,
        function (value)
            Settings.Notify.NotificationMailErrorCA = value
            ChatAnnouncements.RegisterMailEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationMailErrorCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAILERROR), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWMAILERROR_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.NotificationMailErrorAlert
        end,
        function (value)
            Settings.Notify.NotificationMailErrorAlert = value
            ChatAnnouncements.RegisterMailEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationMailErrorAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWLOCKPICK), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWLOCKPICK_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.NotificationLockpickCA
        end,
        function (value)
            Settings.Notify.NotificationLockpickCA = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationLockpickCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWLOCKPICK), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWLOCKPICK_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.NotificationLockpickAlert
        end,
        function (value)
            Settings.Notify.NotificationLockpickAlert = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationLockpickAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWJUSTICE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWJUSTICE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.NotificationConfiscateCA
        end,
        function (value)
            Settings.Notify.NotificationConfiscateCA = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationConfiscateCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWJUSTICE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWJUSTICE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.NotificationConfiscateAlert
        end,
        function (value)
            Settings.Notify.NotificationConfiscateAlert = value
            ChatAnnouncements.RegisterLootEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.NotificationConfiscateAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.StorageBagCA
        end,
        function (value)
            Settings.Notify.StorageBagCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.StorageBagCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Notify.StorageBagCSA
        end,
        function (value)
            Settings.Notify.StorageBagCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.StorageBagCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.StorageBagAlert
        end,
        function (value)
            Settings.Notify.StorageBagAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.StorageBagAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_MISC_SHOWBANKBAG_COLOR),
        nil,
        function ()
            return unpack(Settings.Notify.StorageBagColor)
        end,
        function (r, g, b, a)
            Settings.Notify.StorageBagColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Notify.StorageBagColor,
        5,
        function ()
            return not (Settings.Notify.StorageBagCA or Settings.Notify.StorageBagCSA or Settings.Notify.StorageBagAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.StorageRidingCA
        end,
        function (value)
            Settings.Notify.StorageRidingCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.StorageRidingCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Notify.StorageRidingCSA
        end,
        function (value)
            Settings.Notify.StorageRidingCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.StorageRidingCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.StorageRidingAlert
        end,
        function (value)
            Settings.Notify.StorageRidingAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.StorageRidingAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_COLOR),
        nil,
        function ()
            return unpack(Settings.Notify.StorageRidingColor)
        end,
        function (r, g, b, a)
            Settings.Notify.StorageRidingColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Notify.StorageRidingColor,
        5,
        function ()
            return not (Settings.Notify.StorageRidingCA or Settings.Notify.StorageRidingCSA or Settings.Notify.StorageRidingAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_MISC_SHOWRIDING_COLOR_BOOK),
        nil,
        function ()
            return unpack(Settings.Notify.StorageRidingBookColor)
        end,
        function (r, g, b, a)
            Settings.Notify.StorageRidingBookColor = { r, g, b, a }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Notify.StorageRidingBookColor,
        5,
        function ()
            return not (Settings.Notify.StorageRidingCA or Settings.Notify.StorageRidingCSA or Settings.Notify.StorageRidingAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.DisguiseCA
        end,
        function (value)
            Settings.Notify.DisguiseCA = value
            ChatAnnouncements.RegisterDisguiseEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.DisguiseCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Notify.DisguiseCSA
        end,
        function (value)
            Settings.Notify.DisguiseCSA = value
            ChatAnnouncements.RegisterDisguiseEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.DisguiseCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISE_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.DisguiseAlert
        end,
        function (value)
            Settings.Notify.DisguiseAlert = value
            ChatAnnouncements.RegisterDisguiseEvents()
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.DisguiseAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA)),
        function ()
            return Settings.Notify.DisguiseWarnCA
        end,
        function (value)
            Settings.Notify.DisguiseWarnCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.DisguiseWarnCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT), GetString(LUIE_STRING_LAM_CA_SHARED_CSA_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CSA)),
        function ()
            return Settings.Notify.DisguiseWarnCSA
        end,
        function (value)
            Settings.Notify.DisguiseWarnCSA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.DisguiseWarnCSA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERT_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT)),
        function ()
            return Settings.Notify.DisguiseWarnAlert
        end,
        function (value)
            Settings.Notify.DisguiseWarnAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.DisguiseWarnAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERTCOLOR),
        GetString(LUIE_STRING_LAM_CA_MISC_LOOTSHOWDISGUISEALERTCOLOR_TP),
        function ()
            return unpack(Settings.Notify.DisguiseAlertColor)
        end,
        function (r, g, b, a)
            Settings.Notify.DisguiseAlertColor = { r, g, b }
            ChatAnnouncements.RegisterColorEvents()
        end,
        Defaults.Notify.DisguiseAlertColor,
        5,
        function ()
            return not (Settings.Notify.DisguiseWarnCA or Settings.Notify.DisguiseWarnCSA or Settings.Notify.DisguiseWarnAlert and LUIE.SV.ChatAnnouncements_Enable)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), GetString(SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), GetString(SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES)),
        function ()
            return Settings.Notify.TimedActivityCA
        end,
        function (value)
            Settings.Notify.TimedActivityCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.TimedActivityCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), GetString(SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), GetString(SI_ACTIVITY_FINDER_CATEGORY_TIMED_ACTIVITIES)),
        function ()
            return Settings.Notify.TimedActivityAlert
        end,
        function (value)
            Settings.Notify.TimedActivityAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.TimedActivityAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)),
        function ()
            return Settings.Notify.PromotionalEventsActivityCA
        end,
        function (value)
            Settings.Notify.PromotionalEventsActivityCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.PromotionalEventsActivityCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), GetString(SI_PROMOTIONAL_EVENT_TRACKER_HEADER)),
        function ()
            return Settings.Notify.PromotionalEventsActivityAlert
        end,
        function (value)
            Settings.Notify.PromotionalEventsActivityAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.PromotionalEventsActivityAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), GetString(SI_CRAFTED_ABILITY_SUBTITLE)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), GetString(SI_CRAFTED_ABILITY_SUBTITLE)),
        function ()
            return Settings.Notify.CraftedAbilityCA
        end,
        function (value)
            Settings.Notify.CraftedAbilityCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.CraftedAbilityCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), GetString(SI_CRAFTED_ABILITY_SUBTITLE)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), GetString(SI_CRAFTED_ABILITY_SUBTITLE)),
        function ()
            return Settings.Notify.CraftedAbilityAlert
        end,
        function (value)
            Settings.Notify.CraftedAbilityAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.CraftedAbilityAlert
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_CA_SHORT), GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_CA), GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE)),
        function ()
            return Settings.Notify.CraftedAbilityScriptCA
        end,
        function (value)
            Settings.Notify.CraftedAbilityScriptCA = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.CraftedAbilityScriptCA
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT_SHORT), GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE)),
        zo_strformat(GetString(LUIE_STRING_LAM_CA_MISC_PROGRESS_TP), GetString(LUIE_STRING_LAM_CA_SHARED_ALERT), GetString(SI_CRAFTED_ABILITY_SCRIPT_UNLOCKED_ANNOUNCE_TITLE)),
        function ()
            return Settings.Notify.CraftedAbilityScriptAlert
        end,
        function (value)
            Settings.Notify.CraftedAbilityScriptAlert = value
        end,
        "full",
        function ()
            return not LUIE.SV.ChatAnnouncements_Enable
        end,
        Defaults.Notify.CraftedAbilityScriptAlert
    )

    -- Add all settings to the panel
    panel:AddSettings(settingsData)
end
