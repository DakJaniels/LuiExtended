-- -----------------------------------------------------------------------------
--  LuiExtended — Chat output settings (LUIE.SV.ChatOutput) for PC + console menus
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local zo_strformat = zo_strformat

local function GetChatOutputSettings()
    return LUIE.SV and LUIE.SV.ChatOutput
end

local function GetChatOutputDefaults()
    return LUIE.Defaults.ChatOutput
end

local CHAT_METHOD_ALL_TABS = "Print to All Tabs"
local CHAT_METHOD_SPECIFIC_TABS = "Print to Specific Tabs"

local function UsesPrintToSpecificChatTabs(settings)
    settings = settings or GetChatOutputSettings()
    return settings and settings.ChatMethod == CHAT_METHOD_SPECIFIC_TABS
end

local function GetChatTabCheckboxValue(tabIndex, settings)
    settings = settings or GetChatOutputSettings()
    if not UsesPrintToSpecificChatTabs(settings) then
        return false
    end
    return settings.ChatTab[tabIndex]
end

local function SetChatTabCheckboxValue(tabIndex, value, settings)
    settings = settings or GetChatOutputSettings()
    if not UsesPrintToSpecificChatTabs(settings) then
        return
    end
    settings.ChatTab[tabIndex] = value
end

local function GetChatSystemAllCheckboxValue(settings)
    settings = settings or GetChatOutputSettings()
    if not UsesPrintToSpecificChatTabs(settings) then
        return false
    end
    return settings.ChatSystemAll
end

local function SetChatSystemAllCheckboxValue(value, settings)
    settings = settings or GetChatOutputSettings()
    if not UsesPrintToSpecificChatTabs(settings) then
        return
    end
    settings.ChatSystemAll = value
end

local function IsChatTabRoutingOptionDisabled(settings)
    settings = settings or GetChatOutputSettings()
    return not UsesPrintToSpecificChatTabs(settings)
end

local function IsLibChatMessageLoaded()
    return LibChatMessage ~= nil
end

local function GetChatBypassTooltip()
    local tooltip
    if ZO_IsConsoleOrGameCoreUI() then
        tooltip = GetString(LUIE_STRING_LAM_CA_CHATBYPASS_TP_CONSOLE)
    else
        tooltip = GetString(LUIE_STRING_LAM_CA_CHATBYPASS_TP)
    end
    if IsLibChatMessageLoaded() then
        tooltip = zo_strformat("<<1>>\n\n<<2>>", tooltip, GetString(LUIE_STRING_LAM_CA_CHATBYPASS_LCM_ACTIVE_TP))
    end
    return tooltip
end

local function UsesExternalChatFormatting()
    local chatOutput = LUIE.ChatAnnouncements and LUIE.ChatAnnouncements.ChatOutput
    return chatOutput and chatOutput.ShouldUseExternalFormatting()
end

local function IsLuiExtendedTimestampSettingsDisabled()
    return UsesExternalChatFormatting()
end

local function SyncLuiExtendedTimestampToLibChatMessage()
    local chatOutput = LUIE.ChatAnnouncements and LUIE.ChatAnnouncements.ChatOutput
    if chatOutput and chatOutput.ApplyLibChatMessageTimePrefixSettings then
        chatOutput.ApplyLibChatMessageTimePrefixSettings()
    end
end

local function UsesLuiExtendedTimestampFormatForLibChatMessage(settings)
    settings = settings or GetChatOutputSettings()
    if not settings then
        return true
    end
    if settings.LcmUseLuiExtendedTimestampFormat == nil then
        return true
    end
    return settings.LcmUseLuiExtendedTimestampFormat == true
end

local function SetLibChatMessageUseLuiExtendedTimestampFormat(useLuiExtended)
    local settings = GetChatOutputSettings()
    if settings then
        settings.LcmUseLuiExtendedTimestampFormat = useLuiExtended
    end
end

local LCM_TIME_FORMAT_LABELS =
{
    "Auto (locale)",
    "12-hour",
    "24-hour (ISO)",
}
local LCM_TIME_FORMAT_VALUES =
{
    "[%X]",
    "[%I:%M:%S %p]",
    "[%T]",
}
local LCM_TIME_FORMAT_PRESET_COUNT = #LCM_TIME_FORMAT_VALUES
--- LAM/LHAS dropdown value when LibChatMessage format is not one of the three presets (e.g. synced from Timestamp Format below).
local LCM_TIME_FORMAT_LUIE_SYNC = "__LUIE_TIMESTAMP_FORMAT__"

local function GetLcmTimeFormatDropdownLabels()
    return
    {
        LCM_TIME_FORMAT_LABELS[1],
        LCM_TIME_FORMAT_LABELS[2],
        LCM_TIME_FORMAT_LABELS[3],
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_LUIE_SYNC),
    }
end

local function GetLcmTimeFormatDropdownValues()
    return
    {
        LCM_TIME_FORMAT_VALUES[1],
        LCM_TIME_FORMAT_VALUES[2],
        LCM_TIME_FORMAT_VALUES[3],
        LCM_TIME_FORMAT_LUIE_SYNC,
    }
end

local function IsLibChatMessageTimeFormatPresetValue(format)
    if type(format) ~= "string" then
        return false
    end
    for i = 1, LCM_TIME_FORMAT_PRESET_COUNT do
        if format == LCM_TIME_FORMAT_VALUES[i] then
            return true
        end
    end
    return false
end

local function GetLibChatMessageTimePrefixFormat()
    if not LibChatMessage then
        return LCM_TIME_FORMAT_VALUES[1]
    end
    return LibChatMessage:GetTimePrefixFormat()
end

local function SetLibChatMessageTimePrefixFormat(format)
    if not LibChatMessage or type(format) ~= "string" or format == "" then
        return
    end
    LibChatMessage:SetTimePrefixFormat(format)
end

local function SetLibChatMessageTimePrefixFormatFromOsDateField(format)
    SetLibChatMessageUseLuiExtendedTimestampFormat(false)
    SetLibChatMessageTimePrefixFormat(format)
    SyncLuiExtendedTimestampToLibChatMessage()
end

local function IsLibChatMessageTimeFormatOptionDisabled()
    local settings = GetChatOutputSettings()
    return not (settings and settings.TimeStamp)
end

local function GetLibChatMessageTimeFormatPresetDropdownValue()
    if UsesLuiExtendedTimestampFormatForLibChatMessage() then
        return LCM_TIME_FORMAT_LUIE_SYNC
    end
    local format = GetLibChatMessageTimePrefixFormat()
    if IsLibChatMessageTimeFormatPresetValue(format) then
        return format
    end
    return LCM_TIME_FORMAT_LUIE_SYNC
end

local function SetLibChatMessageTimeFormatPresetDropdownValue(value)
    if value == LCM_TIME_FORMAT_LUIE_SYNC then
        SetLibChatMessageUseLuiExtendedTimestampFormat(true)
        SyncLuiExtendedTimestampToLibChatMessage()
        return
    end
    SetLibChatMessageUseLuiExtendedTimestampFormat(false)
    SetLibChatMessageTimePrefixFormat(value)
    SyncLuiExtendedTimestampToLibChatMessage()
end

local function IsLibChatMessageOsDateFormatFieldDisabled()
    if IsLibChatMessageTimeFormatOptionDisabled() then
        return true
    end
    return UsesLuiExtendedTimestampFormatForLibChatMessage()
end

local function IsLibChatMessageTimeFormatPresetDropdownDisabled()
    return IsLibChatMessageTimeFormatOptionDisabled()
end

local function GetLibChatMessageTimePrefixOnPlayerChat()
    if not LibChatMessage then
        return true
    end
    return LibChatMessage:IsRegularChatMessageTimePrefixEnabled()
end

local function SetLibChatMessageTimePrefixOnPlayerChat(enabled)
    if LibChatMessage then
        LibChatMessage:SetRegularChatMessageTimePrefixEnabled(enabled)
    end
end

local LCM_TAG_PREFIX_LABELS =
{
    "Off",
    "Long tag",
    "Short tag",
}

local function GetLibChatMessageTagPrefixValues()
    if LibChatMessage then
        return
        {
            LibChatMessage.TAG_PREFIX_OFF,
            LibChatMessage.TAG_PREFIX_LONG,
            LibChatMessage.TAG_PREFIX_SHORT,
        }
    end
    return { 1, 2, 3 }
end

local function GetLibChatMessageTagPrefixMode()
    if not LibChatMessage then
        return 2
    end
    return LibChatMessage:GetTagPrefixMode()
end

local function SetLibChatMessageTagPrefixMode(mode)
    if LibChatMessage and type(mode) == "number" then
        LibChatMessage:SetTagPrefixMode(mode)
    end
end

local function AppendLibChatMessageTimeLAMControls(controls, SettingsAPI)
    if not IsLibChatMessageLoaded() then
        return
    end

    controls[#controls + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_LCM_TAGPREFIX),
        GetString(LUIE_STRING_LAM_CA_LCM_TAGPREFIX_TP),
        LCM_TAG_PREFIX_LABELS,
        GetLibChatMessageTagPrefixMode,
        SetLibChatMessageTagPrefixMode,
        "full",
        nil,
        LibChatMessage and LibChatMessage.TAG_PREFIX_LONG or 2,
        nil,
        "name-up",
        nil,
        GetLibChatMessageTagPrefixValues()
    )

    controls[#controls + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT),
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_TP),
        GetLcmTimeFormatDropdownLabels(),
        GetLibChatMessageTimeFormatPresetDropdownValue,
        SetLibChatMessageTimeFormatPresetDropdownValue,
        "full",
        IsLibChatMessageTimeFormatPresetDropdownDisabled,
        LCM_TIME_FORMAT_VALUES[1],
        nil,
        "name-up",
        nil,
        GetLcmTimeFormatDropdownValues()
    )

    controls[#controls + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_CUSTOM),
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_CUSTOM_TP),
        GetLibChatMessageTimePrefixFormat,
        SetLibChatMessageTimePrefixFormatFromOsDateField,
        "full",
        IsLibChatMessageOsDateFormatFieldDisabled,
        LCM_TIME_FORMAT_VALUES[1]
    )

    controls[#controls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEPLAYERCHAT),
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEPLAYERCHAT_TP),
        GetLibChatMessageTimePrefixOnPlayerChat,
        SetLibChatMessageTimePrefixOnPlayerChat,
        "full",
        function ()
            return IsLibChatMessageTimeFormatOptionDisabled()
        end,
        true
    )
end

local function AppendLibChatMessageTimeConsoleControls(settings, LHAS)
    if not IsLibChatMessageLoaded() then
        return
    end

    settings[#settings + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_CA_LCM_TAGPREFIX),
        tooltip = GetString(LUIE_STRING_LAM_CA_LCM_TAGPREFIX_TP),
        items = function ()
            local tagValues = GetLibChatMessageTagPrefixValues()
            local items = {}
            for i, label in ipairs(LCM_TAG_PREFIX_LABELS) do
                items[#items + 1] = { name = label, data = tagValues[i] }
            end
            return items
        end,
        getFunction = GetLibChatMessageTagPrefixMode,
        setFunction = function (_combobox, _value, item)
            SetLibChatMessageTagPrefixMode(item.data or _value)
        end,
        default = 2,
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT),
        tooltip = GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_TP),
        items = function ()
            local labels = GetLcmTimeFormatDropdownLabels()
            local values = GetLcmTimeFormatDropdownValues()
            local items = {}
            for i, label in ipairs(labels) do
                items[#items + 1] = { name = label, data = values[i] }
            end
            return items
        end,
        getFunction = GetLibChatMessageTimeFormatPresetDropdownValue,
        setFunction = function (_combobox, _value, item)
            SetLibChatMessageTimeFormatPresetDropdownValue(item.data or _value)
        end,
        default = LCM_TIME_FORMAT_VALUES[1],
        disable = IsLibChatMessageTimeFormatPresetDropdownDisabled,
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_EDIT,
        label = GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_CUSTOM),
        tooltip = GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_CUSTOM_TP),
        getFunction = GetLibChatMessageTimePrefixFormat,
        setFunction = function (value)
            SetLibChatMessageTimePrefixFormatFromOsDateField(value)
        end,
        default = LCM_TIME_FORMAT_VALUES[1],
        disable = IsLibChatMessageOsDateFormatFieldDisabled,
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CA_LCM_TIMEPLAYERCHAT),
        tooltip = GetString(LUIE_STRING_LAM_CA_LCM_TIMEPLAYERCHAT_TP),
        getFunction = GetLibChatMessageTimePrefixOnPlayerChat,
        setFunction = SetLibChatMessageTimePrefixOnPlayerChat,
        default = true,
        disable = function ()
            return IsLibChatMessageTimeFormatOptionDisabled()
        end,
    }
end

local function IsLuiExtendedTimestampFormatFieldDisabled(settings)
    settings = settings or GetChatOutputSettings()
    if IsLuiExtendedTimestampSettingsDisabled() then
        return true
    end
    if not settings or not settings.TimeStamp then
        return true
    end
    if IsLibChatMessageLoaded() and not UsesLuiExtendedTimestampFormatForLibChatMessage(settings) then
        return true
    end
    return false
end

local function AppendLuiExtendedTimestampLAMControls(controls, SettingsAPI, Settings, Defaults)
    controls[#controls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_TIMESTAMP),
        GetString(LUIE_STRING_LAM_CA_TIMESTAMP_TP),
        function ()
            return Settings.TimeStamp
        end,
        function (value)
            Settings.TimeStamp = value
            SyncLuiExtendedTimestampToLibChatMessage()
        end,
        "full",
        function ()
            return IsLuiExtendedTimestampSettingsDisabled()
        end,
        Defaults.TimeStamp
    )

    controls[#controls + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT)),
        GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP),
        function ()
            return Settings.TimeStampFormat
        end,
        function (value)
            Settings.TimeStampFormat = value
            SetLibChatMessageUseLuiExtendedTimestampFormat(true)
            SyncLuiExtendedTimestampToLibChatMessage()
        end,
        "full",
        function ()
            return IsLuiExtendedTimestampFormatFieldDisabled(Settings)
        end,
        Defaults.TimeStampFormat
    )

    controls[#controls + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CA_TIMESTAMPCOLOR)),
        GetString(LUIE_STRING_LAM_CA_TIMESTAMPCOLOR_TP),
        function ()
            return unpack(Settings.TimeStampColor)
        end,
        function (r, g, b, a)
            Settings.TimeStampColor = { r, g, b, a }
            LUIE.UpdateTimeStampColor()
        end,
        Defaults.TimeStampColor,
        "full",
        function ()
            return IsLuiExtendedTimestampFormatFieldDisabled(Settings)
        end
    )
end

local function AppendLuiExtendedTimestampConsoleControls(settings, LHAS, Settings, Defaults)
    settings[#settings + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CA_TIMESTAMP),
        tooltip = GetString(LUIE_STRING_LAM_CA_TIMESTAMP_TP),
        getFunction = function ()
            return Settings.TimeStamp
        end,
        setFunction = function (value)
            Settings.TimeStamp = value
            SyncLuiExtendedTimestampToLibChatMessage()
        end,
        default = Defaults.TimeStamp,
        disable = function ()
            return IsLuiExtendedTimestampSettingsDisabled()
        end,
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_EDIT,
        label = GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT),
        tooltip = GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP),
        getFunction = function ()
            return Settings.TimeStampFormat
        end,
        setFunction = function (value)
            Settings.TimeStampFormat = value
            SetLibChatMessageUseLuiExtendedTimestampFormat(true)
            SyncLuiExtendedTimestampToLibChatMessage()
        end,
        default = Defaults.TimeStampFormat,
        disable = function ()
            return IsLuiExtendedTimestampFormatFieldDisabled(Settings)
        end,
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_COLOR,
        label = GetString(LUIE_STRING_LAM_CA_TIMESTAMPCOLOR),
        tooltip = GetString(LUIE_STRING_LAM_CA_TIMESTAMPCOLOR_TP),
        getFunction = function ()
            return Settings.TimeStampColor[1], Settings.TimeStampColor[2], Settings.TimeStampColor[3], Settings.TimeStampColor[4]
        end,
        setFunction = function (r, g, b, a)
            Settings.TimeStampColor = { r, g, b, a }
            LUIE.UpdateTimeStampColor()
        end,
        default = Settings.TimeStampColor,
        disable = function ()
            return IsLuiExtendedTimestampFormatFieldDisabled(Settings)
        end,
    }
end

local function GetChatOutputIntegrationNote()
    if ZO_IsConsoleOrGameCoreUI() then
        return GetString(LUIE_STRING_LAM_CA_CHATOUTPUT_NOTE_CONSOLE)
    end
    return GetString(LUIE_STRING_LAM_CA_CHATOUTPUT_NOTE_PC)
end

local LCM_HISTORY_DEFAULT_MAX_AGE = 3600

local function GetLibChatMessageHistoryEnabled()
    if not LibChatMessage then
        return false
    end
    return LibChatMessage:IsChatHistoryEnabled()
end

local function SetLibChatMessageHistoryEnabled(enabled)
    if LibChatMessage then
        LibChatMessage:SetChatHistoryEnabled(enabled)
    end
end

local function GetLibChatMessageHistoryMaxAge()
    if not LibChatMessage then
        return LCM_HISTORY_DEFAULT_MAX_AGE
    end
    return LibChatMessage:GetChatHistoryMaxAge()
end

local function SetLibChatMessageHistoryMaxAgeFromString(value)
    if not LibChatMessage then
        return
    end
    local maxAge = tonumber(value)
    if maxAge and maxAge > 0 then
        LibChatMessage:SetChatHistoryMaxAge(maxAge)
    end
end

local function GetLibChatMessageHistoryTooltip()
    local tooltip = GetString(LUIE_STRING_LAM_CA_LCM_HISTORY_TP)
    if LibChatMessage then
        local activeText = LibChatMessage:IsChatHistoryActive() and "active" or "inactive"
        local enabledText = LibChatMessage:IsChatHistoryEnabled() and "enabled" or "disabled"
        tooltip = zo_strformat(
            "<<1>>\n\n<<2>>",
            tooltip,
            zo_strformat(GetString(LUIE_STRING_LAM_CA_LCM_HISTORY_STATUS_TP), activeText, enabledText)
        )
    end
    return tooltip
end

local function AppendLibChatMessageHistoryLAMControls(controls, SettingsAPI)
    if not IsLibChatMessageLoaded() then
        return
    end

    controls[#controls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_LCM_HISTORY),
        GetLibChatMessageHistoryTooltip(),
        GetLibChatMessageHistoryEnabled,
        SetLibChatMessageHistoryEnabled,
        "full",
        nil,
        false,
        nil,
        true
    )

    controls[#controls + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_LCM_HISTORY_MAXAGE),
        GetString(LUIE_STRING_LAM_CA_LCM_HISTORY_MAXAGE_TP),
        function ()
            return tostring(GetLibChatMessageHistoryMaxAge())
        end,
        SetLibChatMessageHistoryMaxAgeFromString,
        "full",
        function ()
            return not GetLibChatMessageHistoryEnabled()
        end,
        tostring(LCM_HISTORY_DEFAULT_MAX_AGE),
        nil,
        false,
        false,
        true
    )
end

local function AppendLibChatMessageHistoryConsoleControls(settings, LHAS)
    if not IsLibChatMessageLoaded() then
        return
    end

    settings[#settings + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CA_LCM_HISTORY),
        tooltip = GetLibChatMessageHistoryTooltip(),
        getFunction = GetLibChatMessageHistoryEnabled,
        setFunction = SetLibChatMessageHistoryEnabled,
        default = false,
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_EDIT,
        label = GetString(LUIE_STRING_LAM_CA_LCM_HISTORY_MAXAGE),
        tooltip = GetString(LUIE_STRING_LAM_CA_LCM_HISTORY_MAXAGE_TP),
        getFunction = function ()
            return tostring(GetLibChatMessageHistoryMaxAge())
        end,
        setFunction = function (value)
            SetLibChatMessageHistoryMaxAgeFromString(value)
        end,
        default = tostring(LCM_HISTORY_DEFAULT_MAX_AGE),
        disable = function ()
            return not GetLibChatMessageHistoryEnabled()
        end,
    }
end

--- @param SettingsAPI table
--- @return table LAM controls for nested LibChatMessage submenu (PC only)
function LUIE.BuildLibChatMessageLAMControls(SettingsAPI)
    local controls = {}

    controls[#controls + 1] = SettingsAPI.CreateDescriptionOption(GetString(LUIE_STRING_LAM_CA_LCM_SUBMENU_NOTE))

    AppendLibChatMessageHistoryLAMControls(controls, SettingsAPI)
    AppendLibChatMessageTimeLAMControls(controls, SettingsAPI)

    return controls
end

--- @param SettingsAPI table
--- @return table LAM submenu controls
function LUIE.BuildChatOutputLAMControls(SettingsAPI)
    local Settings = GetChatOutputSettings()
    local Defaults = GetChatOutputDefaults()
    local controls = {}

    controls[#controls + 1] = SettingsAPI.CreateDescriptionOption(GetChatOutputIntegrationNote())

    controls[#controls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_CHATBYPASS),
        GetChatBypassTooltip(),
        function ()
            return Settings.ChatBypassFormat
        end,
        function (value)
            Settings.ChatBypassFormat = value
            SyncLuiExtendedTimestampToLibChatMessage()
        end,
        "full",
        nil,
        Defaults.ChatBypassFormat
    )

    if IsLibChatMessageLoaded() then
        controls[#controls + 1] = SettingsAPI.CreateSubmenuOption(
            GetString(LUIE_STRING_LAM_CA_LCM_SUBMENU),
            LUIE.BuildLibChatMessageLAMControls(SettingsAPI),
            "LUIE_ChatOutput_LibChatMessage"
        )
    end

    controls[#controls + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_CHATMETHOD),
        GetString(LUIE_STRING_LAM_CA_CHATMETHOD_TP),
        { "Print to All Tabs", "Print to Specific Tabs" },
        function ()
            return Settings.ChatMethod
        end,
        function (value)
            Settings.ChatMethod = value
        end,
        "full",
        nil,
        Defaults.ChatMethod,
        nil,
        "name-up"
    )

    for tabIndex = 1, 5 do
        controls[#controls + 1] = SettingsAPI.CreateCheckboxOption(
            zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB), tostring(tabIndex)),
            zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), tostring(tabIndex)),
            function ()
                return GetChatTabCheckboxValue(tabIndex)
            end,
            function (value)
                SetChatTabCheckboxValue(tabIndex, value)
            end,
            "full",
            function ()
                return IsChatTabRoutingOptionDisabled()
            end,
            Defaults.ChatTab[tabIndex]
        )
    end

    controls[#controls + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CA_CHATTABSYSTEMALL)),
        GetString(LUIE_STRING_LAM_CA_CHATTABSYSTEMALL_TP),
        function ()
            return GetChatSystemAllCheckboxValue()
        end,
        function (value)
            SetChatSystemAllCheckboxValue(value)
        end,
        "full",
        function ()
            return IsChatTabRoutingOptionDisabled()
        end,
        Defaults.ChatSystemAll
    )

    AppendLuiExtendedTimestampLAMControls(controls, SettingsAPI, Settings, Defaults)

    return controls
end

--- @param settings table LHAS settings array to append to
--- @param LHAS table LibHarvensAddonSettings
function LUIE.AppendChatOutputConsoleControls(settings, LHAS)
    local Settings = GetChatOutputSettings()
    local Defaults = GetChatOutputDefaults()

    settings[#settings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_CHATOUTPUT_HEADER),
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetChatOutputIntegrationNote(),
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CA_CHATBYPASS),
        tooltip = GetChatBypassTooltip(),
        getFunction = function ()
            return Settings.ChatBypassFormat
        end,
        setFunction = function (value)
            Settings.ChatBypassFormat = value
            SyncLuiExtendedTimestampToLibChatMessage()
        end,
        default = Defaults.ChatBypassFormat,
    }

    AppendLibChatMessageHistoryConsoleControls(settings, LHAS)

    if IsLibChatMessageLoaded() then
        AppendLibChatMessageTimeConsoleControls(settings, LHAS)
    end

    AppendLuiExtendedTimestampConsoleControls(settings, LHAS, Settings, Defaults)
end
