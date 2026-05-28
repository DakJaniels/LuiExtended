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

local function IsLibChatMessageActive()
    local chatOutput = LUIE.ChatAnnouncements and LUIE.ChatAnnouncements.ChatOutput
    return chatOutput and chatOutput.IsLibChatMessageActive()
end

local function UsesExternalChatFormatting()
    local chatOutput = LUIE.ChatAnnouncements and LUIE.ChatAnnouncements.ChatOutput
    return chatOutput and chatOutput.ShouldUseExternalFormatting()
end

local function GetChatOutputIntegrationNote()
    if ZO_IsConsoleOrGameCoreUI() then
        return GetString(LUIE_STRING_LAM_CA_CHATOUTPUT_NOTE_CONSOLE)
    end
    return GetString(LUIE_STRING_LAM_CA_CHATOUTPUT_NOTE_PC)
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
        GetString(LUIE_STRING_LAM_CA_CHATBYPASS_TP),
        function ()
            return Settings.ChatBypassFormat
        end,
        function (value)
            Settings.ChatBypassFormat = value
        end,
        "full",
        nil,
        Defaults.ChatBypassFormat
    )

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
                return Settings.ChatTab[tabIndex]
            end,
            function (value)
                Settings.ChatTab[tabIndex] = value
            end,
            "full",
            function ()
                return Settings.ChatMethod == "Print to All Tabs"
            end,
            Defaults.ChatTab[tabIndex]
        )
    end

    controls[#controls + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_CA_CHATTABSYSTEMALL)),
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
        Defaults.ChatSystemAll
    )

    controls[#controls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_TIMESTAMP),
        GetString(LUIE_STRING_LAM_CA_TIMESTAMP_TP),
        function ()
            return Settings.TimeStamp
        end,
        function (value)
            Settings.TimeStamp = value
        end,
        "full",
        function ()
            return UsesExternalChatFormatting()
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
        end,
        "full",
        function ()
            return UsesExternalChatFormatting() or not Settings.TimeStamp
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
            return UsesExternalChatFormatting() or not Settings.TimeStamp
        end
    )

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
        tooltip = GetString(LUIE_STRING_LAM_CA_CHATBYPASS_TP_CONSOLE),
        getFunction = function ()
            return Settings.ChatBypassFormat
        end,
        setFunction = function (value)
            Settings.ChatBypassFormat = value
        end,
        default = Defaults.ChatBypassFormat,
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_CA_CHATMETHOD),
        tooltip = GetString(LUIE_STRING_LAM_CA_CHATMETHOD_TP),
        items = function ()
            return
            {
                { name = "Print to All Tabs",      data = "Print to All Tabs"      },
                { name = "Print to Specific Tabs", data = "Print to Specific Tabs" },
            }
        end,
        getFunction = function ()
            return Settings.ChatMethod
        end,
        setFunction = function (combobox, value, item)
            Settings.ChatMethod = item.data or item.name or value
        end,
        default = Defaults.ChatMethod,
    }

    for tabIndex = 1, 5 do
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB), tostring(tabIndex)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), tostring(tabIndex)),
            getFunction = function ()
                return Settings.ChatTab[tabIndex]
            end,
            setFunction = function (value)
                Settings.ChatTab[tabIndex] = value
            end,
            default = Defaults.ChatTab[tabIndex],
            disable = function ()
                return Settings.ChatMethod == "Print to All Tabs"
            end,
        }
    end

    settings[#settings + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CA_CHATTABSYSTEMALL),
        tooltip = GetString(LUIE_STRING_LAM_CA_CHATTABSYSTEMALL_TP),
        getFunction = function ()
            return Settings.ChatSystemAll
        end,
        setFunction = function (value)
            Settings.ChatSystemAll = value
        end,
        default = Defaults.ChatSystemAll,
        disable = function ()
            return Settings.ChatMethod == "Print to All Tabs"
        end,
    }

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
        end,
        default = Defaults.TimeStamp,
        disable = function ()
            return UsesExternalChatFormatting()
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
        end,
        default = Defaults.TimeStampFormat,
        disable = function ()
            return UsesExternalChatFormatting() or not Settings.TimeStamp
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
            return UsesExternalChatFormatting() or not Settings.TimeStamp
        end,
    }
end
