-- -----------------------------------------------------------------------------
--  LuiExtended — Chat output settings (LUIE.SV.ChatOutput) for PC + console menus
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local zo_strformat = zo_strformat
local wm = WINDOW_MANAGER

local LAM_TAB_ROW_HEIGHT = 26
local LAM_TAB_HEADER_HEIGHT = LAM_TAB_ROW_HEIGHT
local LAM_NO_DELIVERABLE_WARNING_HEIGHT = 52
local LAM_TOGGLE_ON_TEXT = GetString(SI_CHECK_BUTTON_ON):upper()
local LAM_TOGGLE_OFF_TEXT = GetString(SI_CHECK_BUTTON_OFF):upper()

--- LHAS console dropdown equality uses `item.data`; getFunction and default must return `{ data = value }`.
--- @param storedValue any
--- @return table
local function ConsoleLHASDropdownGetData(storedValue)
    return { data = storedValue }
end

local CHAT_TAB_TOGGLE_COL_WIDTH = 48
local CHAT_TAB_COL_SYSTEM_WIDTH = 56
local CHAT_TAB_COL_GAP = 8
local CHAT_TAB_COL_SYSTEM_RIGHT = 0
local CHAT_TAB_COL_LUIE_RIGHT = CHAT_TAB_COL_SYSTEM_WIDTH + CHAT_TAB_COL_GAP
local CHAT_TAB_COL_LABEL_GAP = 8

--- @param toggleControl table
--- @param parent table
--- @param rowHeight number
--- @param rightOffset number
--- @param colWidth number|nil
local function AnchorChatTabRoutingToggleSlot(toggleControl, parent, rowHeight, rightOffset, colWidth)
    colWidth = colWidth or CHAT_TAB_TOGGLE_COL_WIDTH
    toggleControl:SetDimensions(colWidth, rowHeight)
    toggleControl:ClearAnchors()
    toggleControl:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -rightOffset, 0)
    toggleControl.checkbox:ClearAnchors()
    toggleControl.checkbox:SetAnchor(CENTER, toggleControl, CENTER, 0, 0)
end

--- @param parent table
--- @param rowLabel table
--- @param luiToggle table
--- @param systemToggle table
--- @param rowHeight number
local function ApplyChatTabRoutingColumnLayout(parent, rowLabel, luiToggle, systemToggle, rowHeight)
    AnchorChatTabRoutingToggleSlot(systemToggle, parent, rowHeight, CHAT_TAB_COL_SYSTEM_RIGHT, CHAT_TAB_COL_SYSTEM_WIDTH)
    AnchorChatTabRoutingToggleSlot(luiToggle, parent, rowHeight, CHAT_TAB_COL_LUIE_RIGHT, CHAT_TAB_TOGGLE_COL_WIDTH)

    rowLabel:ClearAnchors()
    rowLabel:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    rowLabel:SetAnchor(TOPRIGHT, luiToggle, TOPLEFT, -CHAT_TAB_COL_LABEL_GAP, 0)
end

--- @param parent table
--- @param text string
--- @param rightOffset number
--- @param rowHeight number
--- @param colWidth number|nil
--- @return table
local function CreateChatTabRoutingColumnHeaderLabel(parent, text, rightOffset, rowHeight, colWidth)
    colWidth = colWidth or CHAT_TAB_TOGGLE_COL_WIDTH
    local label = wm:CreateControl(nil, parent, CT_LABEL)
    label:SetFont("ZoFontWinT1")
    label:SetDimensions(colWidth, rowHeight)
    label:SetText(text)
    label:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -rightOffset, 0)
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    return label
end

local function WireChatTabRoutingHeaderLabelTooltip(label, tooltipText)
    label.data = { tooltipText = tooltipText or "" }
    label:SetMouseEnabled(true)
    label:SetHandler("OnMouseEnter", function (self)
        ZO_Options_OnMouseEnter(self)
    end)
    label:SetHandler("OnMouseExit", function (self)
        ZO_Options_OnMouseExit(self)
    end)
end

local function ApplyChatTabRoutingToggleVisual(toggleControl, value, disabled)
    local checkbox = toggleControl.checkbox
    checkbox:SetText(value and LAM_TOGGLE_ON_TEXT or LAM_TOGGLE_OFF_TEXT)
    if disabled then
        checkbox:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
    elseif value then
        checkbox:SetColor(ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA())
    else
        checkbox:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
    end
    toggleControl.isDisabled = disabled
end

local function WireChatTabRoutingInlineToggle(toggleControl, getFunc, setFunc, tooltipText)
    toggleControl.data = { tooltipText = tooltipText or "" }
    toggleControl:SetMouseEnabled(true)
    toggleControl:SetHandler("OnMouseEnter", function (self)
        ZO_Options_OnMouseEnter(self)
        if not self.isDisabled then
            self.checkbox:SetColor(ZO_HIGHLIGHT_TEXT:UnpackRGBA())
        end
    end)
    toggleControl:SetHandler("OnMouseExit", function (self)
        ZO_Options_OnMouseExit(self)
        ApplyChatTabRoutingToggleVisual(self, getFunc(), self.isDisabled)
    end)
    toggleControl:SetHandler("OnMouseUp", function (self, button, upInside)
        if not upInside or self.isDisabled or button ~= MOUSE_BUTTON_INDEX_LEFT then
            return
        end
        PlaySound(SOUNDS.DEFAULT_CLICK)
        setFunc(not getFunc())
        ApplyChatTabRoutingToggleVisual(self, getFunc(), self.isDisabled)
        local LAM = LibAddonMenu2
        if LAM and LAM.util then
            LAM.util.RequestRefreshIfNeeded(self:GetParent())
        end
    end)
end

--- @return table LAM custom control data
local function CreateChatTabRoutingColumnHeaderLAMOption()
    return
    {
        type = "custom",
        reference = "LUIE_ChatOutputTabRowHeader",
        width = "full",
        minHeight = LAM_TAB_HEADER_HEIGHT,
        createFunc = function (control)
            control.headerTabLabel = wm:CreateControl(nil, control, CT_LABEL)
            control.headerTabLabel:SetFont("ZoFontWinH4")
            control.headerTabLabel:SetHeight(LAM_TAB_HEADER_HEIGHT)
            control.headerTabLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
            control.headerTabLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            control.headerTabLabel:SetText(GetString(LUIE_STRING_LAM_CA_CHATTAB_ROUTING_HEADER_TAB))

            local headerLuiLabel = CreateChatTabRoutingColumnHeaderLabel(
                control,
                GetString(LUIE_STRING_LAM_CA_CHATTAB_ROUTING_HEADER_LUIE),
                CHAT_TAB_COL_LUIE_RIGHT,
                LAM_TAB_HEADER_HEIGHT,
                CHAT_TAB_TOGGLE_COL_WIDTH
            )
            WireChatTabRoutingHeaderLabelTooltip(headerLuiLabel, GetString(LUIE_STRING_LAM_CA_CHATTAB_ROUTING_HEADER_LUIE_TP))

            local headerSystemLabel = CreateChatTabRoutingColumnHeaderLabel(
                control,
                GetString(LUIE_STRING_LAM_CA_CHATTAB_ROUTING_HEADER_SYSTEM),
                CHAT_TAB_COL_SYSTEM_RIGHT,
                LAM_TAB_HEADER_HEIGHT,
                CHAT_TAB_COL_SYSTEM_WIDTH
            )
            WireChatTabRoutingHeaderLabelTooltip(headerSystemLabel, GetString(LUIE_STRING_LAM_CA_CHATTAB_ROUTING_HEADER_SYSTEM_TP))
        end,
    }
end

--- @class LUIE_ChatOutputSettingsUI : ZO_InitializingObject
--- @field chatOutput LUIE_ChatOutput|nil
--- @field chatTabLAMRefreshRegistered boolean
local LUIE_ChatOutputSettingsUI = ZO_InitializingObject:Subclass()

--- @param chatOutput LUIE_ChatOutput|nil
function LUIE_ChatOutputSettingsUI:Initialize(chatOutput)
    self.chatOutput = chatOutput
    self.chatTabLAMRefreshRegistered = false
end

--- @return LUIE_ChatOutputSettingsUI
local function GetChatOutputSettingsUI()
    if not LUIE.chatOutputSettingsUI then
        local chatOutput = LUIE.ChatOutput
        LUIE.chatOutputSettingsUI = LUIE_ChatOutputSettingsUI:New(chatOutput)
    end
    return LUIE.chatOutputSettingsUI
end

function LUIE_ChatOutputSettingsUI:GetChatOutputSettings()
    return LUIE.SV and LUIE.SV.ChatOutput
end

function LUIE_ChatOutputSettingsUI:GetChatOutputDefaults()
    return LUIE.Defaults.ChatOutput
end

local function GetChatOutputSettings()
    return GetChatOutputSettingsUI():GetChatOutputSettings()
end

local function GetChatOutputDefaults()
    return GetChatOutputSettingsUI():GetChatOutputDefaults()
end

local function GetChatTabCheckboxValue(tabIndex, settings)
    settings = settings or GetChatOutputSettings()
    if not settings or not settings.ChatTab then
        return false
    end
    return settings.ChatTab[tabIndex] == true
end

local function SetChatTabCheckboxValue(tabIndex, value, settings)
    settings = settings or GetChatOutputSettings()
    if not settings then
        return
    end
    if not settings.ChatTab then
        settings.ChatTab = {}
    end
    settings.ChatTab[tabIndex] = value
end

--- LAM tab rows are created for all slots at addon load; refresh enables/disables rows by live tab count (never hide — avoids LAM gaps).
local function RefreshChatTabLAMControlLabels()
    if ZO_IsConsoleOrGameCoreUI() then
        return
    end
    local chatOutput = LUIE.ChatOutput
    if not chatOutput then
        return
    end
    if chatOutput:UsesPrintToAllTabsMethod() then
        chatOutput:SyncChatTabRoutingForAllTabsMethod()
    end
    local warningControl = _G["LUIE_ChatOutputNoDeliverableWarning"]
    if warningControl and warningControl.RefreshNoDeliverableWarning then
        warningControl:RefreshNoDeliverableWarning()
    end
    local slotCount = chatOutput:GetChatTabSettingsSlotCount()
    for tabIndex = 1, slotCount do
        local rowControl = _G["LUIE_ChatOutputTabRow_" .. tabIndex]
        if rowControl then
            if rowControl.RefreshChatTabRoutingRow then
                rowControl:RefreshChatTabRoutingRow()
            elseif rowControl.UpdateValue then
                rowControl:UpdateValue()
            end
        end
    end
end

local function RegisterChatTabLAMRefreshCallback()
    if LUIE_ChatOutputSettingsUI.chatTabLAMRefreshRegistered or ZO_IsConsoleOrGameCoreUI() then
        return
    end
    LUIE_ChatOutputSettingsUI.chatTabLAMRefreshRegistered = true
    CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", RefreshChatTabLAMControlLabels)
    local eventManager = GetEventManager()
    eventManager:RegisterForEvent(LUIE.name .. "ChatOutputSettingsTabs", EVENT_PLAYER_ACTIVATED, function ()
        zo_callLater(RefreshChatTabLAMControlLabels, 0)
    end)
end

--- Called after chat containers load (player activation) so LAM tab rows match live tab count.
function LUIE_ChatOutputSettingsUI:RefreshChatTabRoutingRows()
    RefreshChatTabLAMControlLabels()
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
    local chatOutput = LUIE.ChatOutput
    return chatOutput and chatOutput:ShouldUseExternalFormatting()
end

local function IsLuiExtendedTimestampSettingsDisabled()
    return UsesExternalChatFormatting()
end

local function ApplyChatOutputTimePrefixSettingsFromSavedVars()
    local chatOutput = LUIE.ChatOutput
    if chatOutput then
        chatOutput:ApplyLibChatMessageTimePrefixSettings()
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
local LCM_TIME_FORMAT_FALLBACK = LCM_TIME_FORMAT_VALUES[1]
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
        return LCM_TIME_FORMAT_FALLBACK
    end
    return LibChatMessage:GetTimePrefixFormat()
end

--- LibChatMessage os.date format for LAM/edit display (single %, e.g. [%H:%M:%S] — not Lua-escaped %%).
--- @param format string
--- @return string
local function FormatLibChatMessageOsDateForSettingsDisplay(format)
    if type(format) ~= "string" then
        return format
    end
    return (string.gsub(format, "%%%%", "%%"))
end

local function GetChatOutputForSettings()
    return LUIE.ChatOutput
end

--- Convert LUIE Timestamp Format tokens to LibChatMessage os.date for display/storage.
--- @param luiFormat string|nil
--- @return string
local function ConvertLuiExtendedTimestampFormatForLibChatMessageDisplay(luiFormat)
    local chatOutput = GetChatOutputForSettings()
    if not chatOutput then
        return "[%X]"
    end
    return FormatLibChatMessageOsDateForSettingsDisplay(chatOutput:LuiExtendedFormatToLibChatMessageOsDate(luiFormat))
end

--- Value shown in LibChatMessage os.date editbox (read-only): converted when Custom is selected, else current LCM format.
local function GetLibChatMessageTimePrefixFormatForSettingsDisplay()
    if not LibChatMessage then
        return LCM_TIME_FORMAT_FALLBACK
    end
    if UsesLuiExtendedTimestampFormatForLibChatMessage() then
        local settings = GetChatOutputSettings()
        if settings and settings.TimeStamp then
            local chatOutput = GetChatOutputForSettings()
            local formatString
            if chatOutput then
                formatString = chatOutput:GetTimestampFormatStringForLibChatMessageSync()
            else
                formatString = settings.TimeStampFormat
            end
            if formatString then
                return ConvertLuiExtendedTimestampFormatForLibChatMessageDisplay(formatString)
            end
        end
    end
    local display = FormatLibChatMessageOsDateForSettingsDisplay(GetLibChatMessageTimePrefixFormat())
    if type(display) == "string" and display ~= "" then
        return display
    end
    return LCM_TIME_FORMAT_FALLBACK
end

--- LAM editbox calls getFunc at control creation; must always return a string (never nil).
local function GetLibChatMessageTimePrefixFormatForSettingsDisplayLAM()
    local ok, result = pcall(GetLibChatMessageTimePrefixFormatForSettingsDisplay)
    if ok and type(result) == "string" and result ~= "" then
        return result
    end
    return LCM_TIME_FORMAT_FALLBACK
end

local function SetLibChatMessageTimePrefixFormat(format)
    if not LibChatMessage or type(format) ~= "string" or format == "" then
        return
    end
    LibChatMessage:SetTimePrefixFormat(format)
end

local function SetLibChatMessageTimePrefixFormatFromOsDateField(_format)
    -- Read-only preview; use the preset dropdown or Timestamp Format (Custom), not this field.
end

local function IsLibChatMessageTimeFormatOptionDisabled()
    local settings = GetChatOutputSettings()
    return not (settings and settings.TimeStamp)
end

local function IsLibChatMessageTimeFormatLockedByPChat()
    if ZO_IsConsoleOrGameCoreUI() then
        return false
    end
    local chatOutput = GetChatOutputForSettings()
    return chatOutput ~= nil and chatOutput:IsLibChatMessageTimeFormatLockedByPChat()
end

local function IsLibChatMessageOsDateFormatFieldDisabled()
    return true
end

local function SetLibChatMessageTimeFormatPresetDropdownValue(value)
    local chatOutput = GetChatOutputForSettings()
    if chatOutput and chatOutput:IsLibChatMessageTimeFormatLockedByPChat() then
        return
    end
    if value == LCM_TIME_FORMAT_LUIE_SYNC then
        SetLibChatMessageUseLuiExtendedTimestampFormat(true)
        ApplyChatOutputTimePrefixSettingsFromSavedVars()
        return
    end
    SetLibChatMessageUseLuiExtendedTimestampFormat(false)
    SetLibChatMessageTimePrefixFormat(value)
    ApplyChatOutputTimePrefixSettingsFromSavedVars()
end

local function GetLibChatMessageTimeFormatPresetDropdownValue()
    if IsLibChatMessageTimeFormatLockedByPChat() or UsesLuiExtendedTimestampFormatForLibChatMessage() then
        return LCM_TIME_FORMAT_LUIE_SYNC
    end
    local format = GetLibChatMessageTimePrefixFormat()
    if IsLibChatMessageTimeFormatPresetValue(format) then
        return format
    end
    return LCM_TIME_FORMAT_LUIE_SYNC
end

local function IsLibChatMessageTimeFormatPresetDropdownDisabled()
    if IsLibChatMessageTimeFormatOptionDisabled() then
        return true
    end
    return IsLibChatMessageTimeFormatLockedByPChat()
end

local function IsPChatTimestampFormattingLibChatMessageProxy()
    return IsLibChatMessageTimeFormatLockedByPChat()
end

local function AppendLibChatMessageTimeFormatTooltip(baseTooltip)
    if IsPChatTimestampFormattingLibChatMessageProxy() then
        return zo_strformat("<<1>>\n\n<<2>>", baseTooltip, GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_PCHAT_NOTE_TP))
    end
    return baseTooltip
end

local function GetLibChatMessageTimeFormatPresetTooltip()
    return AppendLibChatMessageTimeFormatTooltip(GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_TP))
end

local function GetLibChatMessageTimeFormatCustomTooltip()
    local tooltip = GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_CUSTOM_TP)
    if IsPChatTimestampFormattingLibChatMessageProxy() then
        tooltip = zo_strformat("<<1>>\n\n<<2>>", tooltip, GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_PCHAT_NOTE_TP))
    end
    return tooltip
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

local LCM_TAG_PREFIX_DEFAULT = 1

local function GetLibChatMessageTagPrefixMode()
    if not LibChatMessage then
        return LCM_TAG_PREFIX_DEFAULT
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
        LibChatMessage and LibChatMessage.TAG_PREFIX_OFF or LCM_TAG_PREFIX_DEFAULT,
        nil,
        "name-up",
        nil,
        GetLibChatMessageTagPrefixValues()
    )

    controls[#controls + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT),
        function ()
            return GetLibChatMessageTimeFormatPresetTooltip()
        end,
        GetLcmTimeFormatDropdownLabels(),
        GetLibChatMessageTimeFormatPresetDropdownValue,
        SetLibChatMessageTimeFormatPresetDropdownValue,
        "full",
        IsLibChatMessageTimeFormatPresetDropdownDisabled,
        LCM_TIME_FORMAT_FALLBACK,
        nil,
        "name-up",
        nil,
        GetLcmTimeFormatDropdownValues()
    )

    controls[#controls + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_CUSTOM),
        function ()
            return GetLibChatMessageTimeFormatCustomTooltip()
        end,
        GetLibChatMessageTimePrefixFormatForSettingsDisplayLAM,
        SetLibChatMessageTimePrefixFormatFromOsDateField,
        "full",
        IsLibChatMessageOsDateFormatFieldDisabled,
        LCM_TIME_FORMAT_FALLBACK
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
        getFunction = function ()
            return ConsoleLHASDropdownGetData(GetLibChatMessageTagPrefixMode())
        end,
        setFunction = function (_combobox, _value, item)
            SetLibChatMessageTagPrefixMode(item.data or _value)
        end,
        default = ConsoleLHASDropdownGetData(LibChatMessage and LibChatMessage.TAG_PREFIX_OFF or LCM_TAG_PREFIX_DEFAULT),
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT),
        tooltip = GetLibChatMessageTimeFormatPresetTooltip(),
        items = function ()
            local labels = GetLcmTimeFormatDropdownLabels()
            local values = GetLcmTimeFormatDropdownValues()
            local items = {}
            for i, label in ipairs(labels) do
                items[#items + 1] = { name = label, data = values[i] }
            end
            return items
        end,
        getFunction = function ()
            return ConsoleLHASDropdownGetData(GetLibChatMessageTimeFormatPresetDropdownValue())
        end,
        setFunction = function (_combobox, _value, item)
            SetLibChatMessageTimeFormatPresetDropdownValue(item.data or _value)
        end,
        default = ConsoleLHASDropdownGetData(LCM_TIME_FORMAT_FALLBACK),
        disable = IsLibChatMessageTimeFormatPresetDropdownDisabled,
    }

    settings[#settings + 1] =
    {
        type = LHAS.ST_EDIT,
        label = GetString(LUIE_STRING_LAM_CA_LCM_TIMEFORMAT_CUSTOM),
        tooltip = GetLibChatMessageTimeFormatCustomTooltip(),
        getFunction = GetLibChatMessageTimePrefixFormatForSettingsDisplayLAM,
        setFunction = function (value)
            SetLibChatMessageTimePrefixFormatFromOsDateField(value)
        end,
        default = LCM_TIME_FORMAT_FALLBACK,
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
            ApplyChatOutputTimePrefixSettingsFromSavedVars()
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
            ApplyChatOutputTimePrefixSettingsFromSavedVars()
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
            LUIE.ChatOutput:UpdateTimeStampColor()
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
            ApplyChatOutputTimePrefixSettingsFromSavedVars()
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
            ApplyChatOutputTimePrefixSettingsFromSavedVars()
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
            LUIE.ChatOutput:UpdateTimeStampColor()
        end,
        default = Settings.TimeStampColor,
        disable = function ()
            return IsLuiExtendedTimestampFormatFieldDisabled(Settings)
        end,
    }
end

local CHAT_METHOD_SV_ALL_TABS = "Print to All Tabs"
local CHAT_METHOD_SV_SPECIFIC_TABS = "Print to Specific Tabs"

local function GetChatMethodDropdownChoices()
    return
    {
        GetString(LUIE_STRING_LAM_CA_CHATMETHOD_ALL_TABS),
        GetString(LUIE_STRING_LAM_CA_CHATMETHOD_SPECIFIC_TABS),
    }
end

local function GetChatMethodDropdownValues()
    return { CHAT_METHOD_SV_ALL_TABS, CHAT_METHOD_SV_SPECIFIC_TABS }
end

local function GetChatOutputIntegrationNote()
    if ZO_IsConsoleOrGameCoreUI() then
        return GetString(LUIE_STRING_LAM_CA_CHATOUTPUT_NOTE_CONSOLE)
    end
    return GetString(LUIE_STRING_LAM_CA_CHATOUTPUT_NOTE_PC)
end

local LCM_HISTORY_DEFAULT_MAX_AGE = 3600

local function IsPChatChatRestoreEnabled()
    local chatOutput = LUIE.ChatOutput
    return chatOutput and chatOutput:IsPChatChatRestoreEnabled()
end

local function IsLibChatMessageHistoryOptionDisabled()
    return IsPChatChatRestoreEnabled()
end

local function GetLibChatMessageHistoryEnabled()
    if not LibChatMessage or IsPChatChatRestoreEnabled() then
        return false
    end
    return LibChatMessage:IsChatHistoryEnabled()
end

local function SetLibChatMessageHistoryEnabled(enabled)
    if not LibChatMessage then
        return
    end
    if enabled and IsPChatChatRestoreEnabled() then
        return
    end
    LibChatMessage:SetChatHistoryEnabled(enabled)
    if IsPChatChatRestoreEnabled() then
        LibChatMessage:SetChatHistoryEnabled(false)
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
    if IsPChatChatRestoreEnabled() then
        tooltip = zo_strformat("<<1>>\n\n<<2>>", tooltip, GetString(LUIE_STRING_LAM_CA_LCM_HISTORY_PCHAT_ACTIVE_TP))
    elseif LibChatMessage then
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
        IsLibChatMessageHistoryOptionDisabled,
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
            return IsLibChatMessageHistoryOptionDisabled() or not GetLibChatMessageHistoryEnabled()
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
        disable = IsLibChatMessageHistoryOptionDisabled,
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
            return IsLibChatMessageHistoryOptionDisabled() or not GetLibChatMessageHistoryEnabled()
        end,
    }
end

--- @param SettingsAPI table
--- @return table LAM controls for nested LibChatMessage submenu (PC only)
function LUIE_ChatOutputSettingsUI:BuildLibChatMessageLAMControls(SettingsAPI)
    local controls = {}

    controls[#controls + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CA_LCM_SUBMENU_NOTE),
        "full",
        GetString(LUIE_STRING_LAM_CA_LCM_SUBMENU_NOTE_TITLE)
    )

    AppendLibChatMessageHistoryLAMControls(controls, SettingsAPI)
    AppendLibChatMessageTimeLAMControls(controls, SettingsAPI)

    return controls
end

--- @param chatOutput LUIE_ChatOutput|nil
--- @return table LAM custom control data
local function CreateChatTabRoutingNoDeliverableWarningLAMOption(chatOutput)
    return
    {
        type = "custom",
        reference = "LUIE_ChatOutputNoDeliverableWarning",
        width = "full",
        minHeight = 0,
        refreshFunc = function (control)
            if control.RefreshNoDeliverableWarning then
                control:RefreshNoDeliverableWarning()
            end
        end,
        createFunc = function (control)
            control.warningLabel = wm:CreateControl(nil, control, CT_LABEL)
            control.warningLabel:SetFont("ZoFontGame")
            control.warningLabel:SetColor(ZO_ERROR_COLOR:UnpackRGBA())
            control.warningLabel:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
            control.warningLabel:SetAnchor(BOTTOMRIGHT, control, BOTTOMRIGHT, 0, 0)
            control.warningLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
            control.warningLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
            control.warningLabel:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            control.warningLabel:SetMaxLineCount(0)

            function control:RefreshNoDeliverableWarning()
                local showWarning = chatOutput and not chatOutput:HasDeliverableTab()
                if showWarning then
                    self:SetHidden(false)
                    self.warningLabel:SetHidden(false)
                    self.warningLabel:SetText(GetString(LUIE_STRING_LAM_CA_CHATOUTPUT_NO_DELIVERABLE_TAB_LAM))
                    self.warningLabel:SetHeight(LAM_NO_DELIVERABLE_WARNING_HEIGHT)
                    self:SetHeight(LAM_NO_DELIVERABLE_WARNING_HEIGHT)
                else
                    self.warningLabel:SetText("")
                    self.warningLabel:SetHidden(true)
                    self:SetHidden(true)
                    self:SetHeight(0)
                end
            end

            control:RefreshNoDeliverableWarning()
        end,
    }
end

--- @param tabIndex integer
--- @param chatOutput LUIE_ChatOutput|nil
--- @return table LAM custom control data
local function CreateChatTabRoutingRowLAMOption(tabIndex, chatOutput)
    local tabIndexCapture = tabIndex

    local function GetTabRowLabel()
        if chatOutput then
            return chatOutput:GetChatTabSettingsShortLabel(tabIndexCapture)
        end
        return zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_ROW_NONAME), tostring(tabIndexCapture))
    end

    return
    {
        type = "custom",
        reference = "LUIE_ChatOutputTabRow_" .. tabIndexCapture,
        width = "full",
        minHeight = LAM_TAB_ROW_HEIGHT,
        refreshFunc = function (control)
            if control.RefreshChatTabRoutingRow then
                control:RefreshChatTabRoutingRow()
            end
        end,
        createFunc = function (control)
            control.tabIndex = tabIndexCapture

            control.systemToggle = wm:CreateControl(nil, control, CT_CONTROL)
            control.systemToggle.checkbox = wm:CreateControl(nil, control.systemToggle, CT_LABEL)
            control.systemToggle.checkbox:SetFont("ZoFontGameBold")

            control.luiToggle = wm:CreateControl(nil, control, CT_CONTROL)
            control.luiToggle.checkbox = wm:CreateControl(nil, control.luiToggle, CT_LABEL)
            control.luiToggle.checkbox:SetFont("ZoFontGameBold")

            control.rowLabel = wm:CreateControl(nil, control, CT_LABEL)
            control.rowLabel:SetFont("ZoFontWinH4")
            control.rowLabel:SetHeight(LAM_TAB_ROW_HEIGHT)
            control.rowLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)

            ApplyChatTabRoutingColumnLayout(control, control.rowLabel, control.luiToggle, control.systemToggle, LAM_TAB_ROW_HEIGHT)

            WireChatTabRoutingInlineToggle(
                control.luiToggle,
                function ()
                    return GetChatTabCheckboxValue(tabIndexCapture)
                end,
                function (value)
                    if chatOutput and chatOutput:UsesPrintToAllTabsMethod() then
                        return
                    end
                    SetChatTabCheckboxValue(tabIndexCapture, value)
                    if value and chatOutput then
                        chatOutput:SetSystemCategoryEnabledOnTabForSettings(tabIndexCapture, true)
                    end
                    control:RefreshChatTabRoutingRow()
                    local warningControl = _G["LUIE_ChatOutputNoDeliverableWarning"]
                    if warningControl and warningControl.RefreshNoDeliverableWarning then
                        warningControl:RefreshNoDeliverableWarning()
                    end
                end,
                zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), tostring(tabIndexCapture))
            )
            WireChatTabRoutingInlineToggle(
                control.systemToggle,
                function ()
                    if chatOutput then
                        return chatOutput:IsSystemCategoryEnabledOnTabForSettings(tabIndexCapture)
                    end
                    return false
                end,
                function (value)
                    if chatOutput and chatOutput:UsesPrintToAllTabsMethod() then
                        return
                    end
                    if chatOutput then
                        chatOutput:SetSystemCategoryEnabledOnTabForSettings(tabIndexCapture, value)
                    end
                    control:RefreshChatTabRoutingRow()
                    local warningControl = _G["LUIE_ChatOutputNoDeliverableWarning"]
                    if warningControl and warningControl.RefreshNoDeliverableWarning then
                        warningControl:RefreshNoDeliverableWarning()
                    end
                end,
                GetString(LUIE_STRING_LAM_CA_CHATTAB_SYSTEMFILTER_TP)
            )

            local rowTooltip = zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_TP), tostring(tabIndexCapture))
            if control.data then
                control.data.tooltipText = rowTooltip
            end

            control.rowLabel:SetHandler("OnMouseEnter", function (self)
                ZO_Options_OnMouseEnter(self:GetParent())
            end)
            control.rowLabel:SetHandler("OnMouseExit", function (self)
                ZO_Options_OnMouseExit(self:GetParent())
            end)

            function control:RefreshChatTabRoutingRow()
                local tabActive = chatOutput and chatOutput:IsChatTabIndexActiveForSettings(tabIndexCapture)
                local rowDisabled = not tabActive
                local allTabsMethod = chatOutput and chatOutput:UsesPrintToAllTabsMethod()
                local luiToggleDisabled = rowDisabled or allTabsMethod
                if tabActive then
                    self.rowLabel:SetText(GetTabRowLabel())
                    self.rowLabel:SetColor(ZO_NORMAL_TEXT:UnpackRGBA())
                else
                    self.rowLabel:SetText(zo_strformat(GetString(LUIE_STRING_LAM_CA_CHATTAB_ROW_NONAME), tostring(tabIndexCapture)))
                    self.rowLabel:SetColor(ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA())
                end
                self.luiToggle:SetMouseEnabled(tabActive and not allTabsMethod)
                self.systemToggle:SetMouseEnabled(tabActive and not allTabsMethod)
                ApplyChatTabRoutingToggleVisual(
                    self.luiToggle,
                    GetChatTabCheckboxValue(tabIndexCapture),
                    luiToggleDisabled
                )
                local systemEnabled = tabActive and chatOutput and chatOutput:IsSystemCategoryEnabledOnTabForSettings(tabIndexCapture) or false
                ApplyChatTabRoutingToggleVisual(self.systemToggle, systemEnabled, luiToggleDisabled)
            end

            control:RefreshChatTabRoutingRow()
        end,
    }
end

--- @param controls table
--- @param SettingsAPI table
--- @param Defaults LUIE_ChatOutputDefaults
local function AppendChatTabRoutingLAMControls(controls, SettingsAPI, Defaults)
    local chatOutput = LUIE.ChatOutput
    local slotCount = chatOutput and chatOutput:GetChatTabSettingsSlotCount() or 20

    controls[#controls + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CA_CHATTAB_ROUTING_SECTION),
        "full",
        GetString(LUIE_STRING_LAM_CA_CHATTAB_ROUTING_TITLE)
    )
    controls[#controls + 1] = CreateChatTabRoutingColumnHeaderLAMOption()
    controls[#controls + 1] = CreateChatTabRoutingNoDeliverableWarningLAMOption(chatOutput)

    for tabIndex = 1, slotCount do
        controls[#controls + 1] = CreateChatTabRoutingRowLAMOption(tabIndex, chatOutput)
    end
    RegisterChatTabLAMRefreshCallback()
    zo_callLater(RefreshChatTabLAMControlLabels, 0)
end

--- @param SettingsAPI table
--- @return table LAM controls for Chat Output settings (PC)
function LUIE_ChatOutputSettingsUI:BuildChatOutputLAMControls(SettingsAPI)
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
            ApplyChatOutputTimePrefixSettingsFromSavedVars()
        end,
        "full",
        nil,
        Defaults.ChatBypassFormat
    )

    if IsLibChatMessageLoaded() then
        controls[#controls + 1] = SettingsAPI.CreateSubmenuOption(
            GetString(LUIE_STRING_LAM_CA_LCM_SUBMENU),
            self:BuildLibChatMessageLAMControls(SettingsAPI),
            "LUIE_ChatOutput_LibChatMessage"
        )
    end

    controls[#controls + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CA_CHATMETHOD),
        GetString(LUIE_STRING_LAM_CA_CHATMETHOD_TP),
        GetChatMethodDropdownChoices(),
        function ()
            return Settings.ChatMethod
        end,
        function (value)
            Settings.ChatMethod = value
            local chatOutput = LUIE.ChatOutput
            if chatOutput and value == CHAT_METHOD_SV_ALL_TABS then
                chatOutput:SyncChatTabRoutingForAllTabsMethod()
            end
            RefreshChatTabLAMControlLabels()
        end,
        "full",
        nil,
        Defaults.ChatMethod,
        nil,
        "name-up",
        nil,
        GetChatMethodDropdownValues()
    )

    controls[#controls + 1] = SettingsAPI.CreateDividerOption()

    AppendChatTabRoutingLAMControls(controls, SettingsAPI, Defaults)

    AppendLuiExtendedTimestampLAMControls(controls, SettingsAPI, Settings, Defaults)

    return controls
end

--- @param settings table LHAS settings array to append to
--- @param LHAS table LibHarvensAddonSettings
--- @param options table|nil `{ omitSectionHeader = true }` when rows live under an ST_SECTION titled Chat Output
function LUIE_ChatOutputSettingsUI:AppendChatOutputConsoleControls(settings, LHAS, options)
    local Settings = GetChatOutputSettings()
    local Defaults = GetChatOutputDefaults()
    options = options or {}

    if not options.omitSectionHeader then
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CHATOUTPUT_HEADER),
        }
    end

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
            ApplyChatOutputTimePrefixSettingsFromSavedVars()
        end,
        default = Defaults.ChatBypassFormat,
    }

    AppendLibChatMessageHistoryConsoleControls(settings, LHAS)

    if IsLibChatMessageLoaded() then
        AppendLibChatMessageTimeConsoleControls(settings, LHAS)
    end

    AppendLuiExtendedTimestampConsoleControls(settings, LHAS, Settings, Defaults)
end

--- @param SettingsAPI table
--- @return table
function LUIE.BuildLibChatMessageLAMControls(SettingsAPI)
    return GetChatOutputSettingsUI():BuildLibChatMessageLAMControls(SettingsAPI)
end

--- @param SettingsAPI table
--- @return table
function LUIE.BuildChatOutputLAMControls(SettingsAPI)
    return GetChatOutputSettingsUI():BuildChatOutputLAMControls(SettingsAPI)
end

--- @param settings table
--- @param LHAS table
--- @param options table|nil
function LUIE.AppendChatOutputConsoleControls(settings, LHAS, options)
    GetChatOutputSettingsUI():AppendChatOutputConsoleControls(settings, LHAS, options)
end
