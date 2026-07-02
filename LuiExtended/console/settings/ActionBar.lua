-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar
local CastBar = ActionBar.CastBar
local Backbar = ActionBar.Backbar

local zo_strformat = zo_strformat
local string_format = string.format
local string_rep = string.rep
local type, pairs, ipairs = type, pairs, ipairs
local GetString = GetString
local unpack = unpack
local table_insert = table.insert

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

local Blacklist, BlacklistValues = {}, {}

-- Convert to LHAS format {name, data}
local function GenerateCustomListLHAS(input)
    local items = {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        local displayName
        if type(id) == "number" then
            displayName = zo_iconTextFormat(GetAbilityIcon(id), 16, 16, " [" .. id .. "] " .. zo_strformat("<<C:1>>", GetAbilityName(id)), true, true)
        else
            displayName = id
        end
        items[counter] = { name = displayName, data = id }
    end
    return items
end

function ActionBar.CreateConsoleSettings()
    local Defaults = ActionBar.Defaults
    local Settings = ActionBar.SV

    -- Register the settings panel
    if not LUIE.SV.ActionBar_Enabled then
        return
    end

    -- Register custom blacklist management dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_CASTBAR_BLACKLIST",
        GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST),
        function ()
            return GenerateCustomListLHAS(Settings.blacklist)
        end,
        function (itemData)
            ActionBar.RemoveFromCustomList(Settings.blacklist, itemData)
        end,
        function (text)
            ActionBar.AddToCustomList(Settings.blacklist, text)
        end,
        function ()
            ActionBar.ClearCustomList(Settings.blacklist)
        end
    )

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_AB),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset to defaults if needed
                                    end,
                                })
    ActionBar.consoleSettingsPanel = panel

    LUIE.RegisterDialogueButton(
        "LUIE_CLEAR_CASTBAR_BLACKLIST",
        GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
        zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG), GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST)),
        function ()
            ActionBar.ClearCustomList(ActionBar.SV.blacklist)
            SettingsAPI:RefreshPanel(panel)
        end
    )

    -- Get media lists from SettingsAPI
    local fontItems = SettingsAPI:GetFontsList()
    local soundItems = SettingsAPI:GetSoundsList()
    local statusbarItems = SettingsAPI:GetStatusbarTexturesList()

    -- Build font style items once
    local fontStyleItems = {}
    for i, choice in ipairs(LUIE.FONT_STYLE_CHOICES) do
        fontStyleItems[i] = { name = choice, data = LUIE.FONT_STYLE_CHOICES_VALUES[i] }
    end
    table.sort(fontStyleItems, function (a, b) return a.name < b.name end)

    -- Collect initial settings for main menu
    local initialSettings = {}

    -- Action Bar Description
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_AB_DESCRIPTION)
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

    initialSettings[#initialSettings + 1] = SettingsAPI:ConsoleFontDeferLabelSetting()

    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_AB_DISPLAY_OPTIONS_HEADER),
        canSelect = false,
    }

    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_SLIDER,
        label = GetString(LUIE_STRING_SHARED_OOC_OPACITY),
        tooltip = GetString(LUIE_STRING_LAM_AB_OOC_OPACITY_TP),
        min = 0,
        max = 100,
        step = 5,
        format = "%.0f",
        getFunction = function ()
            return Settings.oocAlpha
        end,
        setFunction = function (v)
            Settings.oocAlpha = v
            ActionBar.ApplyDisplayAlpha()
        end,
        default = Defaults.oocAlpha,
        disable = function () return not LUIE.SV.ActionBar_Enabled end,
    }

    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_SLIDER,
        label = GetString(LUIE_STRING_SHARED_IC_OPACITY),
        tooltip = GetString(LUIE_STRING_LAM_AB_IC_OPACITY_TP),
        min = 0,
        max = 100,
        step = 5,
        format = "%.0f",
        getFunction = function ()
            return Settings.incAlpha
        end,
        setFunction = function (v)
            Settings.incAlpha = v
            ActionBar.ApplyDisplayAlpha()
        end,
        default = Defaults.incAlpha,
        disable = function () return not LUIE.SV.ActionBar_Enabled end,
    }

    local sectionGroups = {}

    -- Helper function to build section settings
    local function buildSectionSettings(sectionName, settingsBuilder)
        local sectionSettings = {}
        settingsBuilder(sectionSettings)
        sectionGroups[sectionName] = sectionSettings
    end

    -- Build Global Cooldown Options Section
    buildSectionSettings("GlobalCooldown", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_GCD),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_AB_GCD),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_GCD_SHOW),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_SHOW_TP),
            getFunction = function () return Settings.GlobalShowGCD end,
            setFunction = function (value)
                Settings.GlobalShowGCD = value
                ActionBar.HookGCD()
            end,
            default = Defaults.GlobalShowGCD,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_GCD_QUICK),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_QUICK_TP),
            getFunction = function () return Settings.GlobalPotion end,
            setFunction = function (value) Settings.GlobalPotion = value end,
            default = Defaults.GlobalPotion,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_GCD_FLASH),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_FLASH_TP),
            getFunction = function () return Settings.GlobalFlash end,
            setFunction = function (value) Settings.GlobalFlash = value end,
            default = Defaults.GlobalFlash,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_GCD_DESAT),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_DESAT_TP),
            getFunction = function () return Settings.GlobalDesat end,
            setFunction = function (value) Settings.GlobalDesat = value end,
            default = Defaults.GlobalDesat,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_GCD_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_COLOR_TP),
            getFunction = function () return Settings.GlobalLabelColor end,
            setFunction = function (value) Settings.GlobalLabelColor = value end,
            default = Defaults.GlobalLabelColor,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION_TP),
            items = SettingsAPI:GetGlobalMethodOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeGcdMethodIndex(Settings.GlobalMethod, Defaults.GlobalMethod))
            end,
            setFunction = function (combobox, value, item)
                Settings.GlobalMethod = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.GlobalMethod),
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }
    end)

    -- Build Ultimate Tracking Options Section
    buildSectionSettings("UltimateTracking", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_ULTIMATE),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_AB_ULTIMATE),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_VAL),
            tooltip = GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_VAL_TP),
            getFunction = function () return Settings.UltimateLabelEnabled end,
            setFunction = function (value)
                Settings.UltimateLabelEnabled = value
                ActionBar.RegisterEvents()
                ActionBar.UpdateUltimateLabel()
            end,
            default = Defaults.UltimateLabelEnabled,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_PCT),
            tooltip = GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_PCT_TP),
            getFunction = function () return Settings.UltimatePctEnabled end,
            setFunction = function (value)
                Settings.UltimatePctEnabled = value
                ActionBar.RegisterEvents()
                ActionBar.UpdateUltimateLabel()
            end,
            default = Defaults.UltimatePctEnabled,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
            min = -72,
            max = 40,
            step = 2,
            format = "%.0f",
            getFunction = function () return Settings.UltimateLabelPosition end,
            setFunction = function (value)
                Settings.UltimateLabelPosition = value
                ActionBar.ResetUltimateLabel()
            end,
            default = Defaults.UltimateLabelPosition,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
            items = fontItems,
            getFunction = function () return Settings.UltimateFontFace end,
            setFunction = function (combobox, value, item)
                Settings.UltimateFontFace = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.UltimateFontFace,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.UltimateFontSize end,
            setFunction = function (value)
                Settings.UltimateFontSize = value
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.UltimateFontSize,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                local value = Settings.UltimateFontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.UltimateFontStyle = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.UltimateFontStyle,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_ULTIMATE_HIDEFULL),
            tooltip = GetString(LUIE_STRING_LAM_AB_ULTIMATE_HIDEFULL_TP),
            getFunction = function () return Settings.UltimateHideFull end,
            setFunction = function (value)
                Settings.UltimateHideFull = value
                ActionBar.UpdateUltimateLabel()
            end,
            default = Defaults.UltimateHideFull,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_ULTIMATE_TEXTURE),
            tooltip = GetString(LUIE_STRING_LAM_AB_ULTIMATE_TEXTURE_TP),
            getFunction = function () return Settings.UltimateGeneration end,
            setFunction = function (value) Settings.UltimateGeneration = value end,
            default = Defaults.UltimateGeneration,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }
    end)

    -- Build Companion Ultimate Options Section
    buildSectionSettings("CompanionUltimate", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_COMPANION_ULTIMATE),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_COMPANION_NOTE),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_COMPANION_SHOW_VAL),
            tooltip = GetString(LUIE_STRING_LAM_AB_COMPANION_SHOW_VAL_TP),
            getFunction = function () return Settings.CompanionUltimateLabelEnabled end,
            setFunction = function (value)
                Settings.CompanionUltimateLabelEnabled = value
                ActionBar.RegisterEvents()
                ActionBar.UpdateCompanionUltimateLabel()
                ActionBar.RefreshCompanionQuickslotAnchors()
            end,
            default = Defaults.CompanionUltimateLabelEnabled,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_COMPANION_SHOW_PCT),
            tooltip = GetString(LUIE_STRING_LAM_AB_COMPANION_SHOW_PCT_TP),
            getFunction = function () return Settings.CompanionUltimatePctEnabled end,
            setFunction = function (value)
                Settings.CompanionUltimatePctEnabled = value
                ActionBar.RegisterEvents()
                ActionBar.UpdateCompanionUltimateLabel()
                ActionBar.RefreshCompanionQuickslotAnchors()
            end,
            default = Defaults.CompanionUltimatePctEnabled,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
            min = -72,
            max = 40,
            step = 2,
            format = "%.0f",
            getFunction = function () return Settings.CompanionUltimateLabelPosition end,
            setFunction = function (value)
                Settings.CompanionUltimateLabelPosition = value
                ActionBar.ResetCompanionUltimateLabel()
            end,
            default = Defaults.CompanionUltimateLabelPosition,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
            items = fontItems,
            getFunction = function () return Settings.CompanionUltimateFontFace end,
            setFunction = function (combobox, value, item)
                Settings.CompanionUltimateFontFace = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.CompanionUltimateFontFace,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.CompanionUltimateFontSize end,
            setFunction = function (value)
                Settings.CompanionUltimateFontSize = value
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.CompanionUltimateFontSize,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                local value = Settings.CompanionUltimateFontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.CompanionUltimateFontStyle = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.CompanionUltimateFontStyle,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_COMPANION_HIDEFULL),
            tooltip = GetString(LUIE_STRING_LAM_AB_COMPANION_HIDEFULL_TP),
            getFunction = function () return Settings.CompanionUltimateHideFull end,
            setFunction = function (value)
                Settings.CompanionUltimateHideFull = value
                ActionBar.UpdateCompanionUltimateLabel()
            end,
            default = Defaults.CompanionUltimateHideFull,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end
        }
    end)

    -- Build Bar Ability Highlight Options Section
    buildSectionSettings("BarAbilityHighlight", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_BAR),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_AB_HIGHLIGHT),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BAR_PROC),
            tooltip = GetString(LUIE_STRING_LAM_AB_BAR_PROC_TP),
            getFunction = function () return Settings.ShowTriggered end,
            setFunction = function (value)
                Settings.ShowTriggered = value
                ActionBar.UpdateBarHighlightTables()
                ActionBar.OnSlotsFullUpdate()
            end,
            default = Defaults.ShowTriggered,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND),
            tooltip = GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND_TP),
            getFunction = function () return Settings.ProcEnableSound end,
            setFunction = function (value) Settings.ProcEnableSound = value end,
            default = Defaults.ProcEnableSound,
            disable = function () return not (Settings.ShowTriggered and LUIE.SV.ActionBar_Enabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUNDCHOICE),
            tooltip = GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUNDCHOICE_TP),
            items = soundItems,
            getFunction = function () return Settings.ProcSoundName end,
            setFunction = function (combobox, value, item)
                Settings.ProcSoundName = item.data
                ActionBar.ApplyProcSound(true)
            end,
            default = Defaults.ProcSoundName,
            disable = function () return not (Settings.ShowTriggered and Settings.ProcEnableSound and LUIE.SV.ActionBar_Enabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BAR_EFFECT),
            tooltip = GetString(LUIE_STRING_LAM_AB_BAR_EFFECT_TP),
            getFunction = function () return Settings.ShowToggled end,
            setFunction = function (value)
                Settings.ShowToggled = value
                ActionBar.UpdateBarHighlightTables()
                ActionBar.OnSlotsFullUpdate()
            end,
            default = Defaults.ShowToggled,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BAR_ULTIMATE),
            tooltip = GetString(LUIE_STRING_LAM_AB_BAR_ULTIMATE_TP),
            getFunction = function () return Settings.ShowToggledUltimate end,
            setFunction = function (value)
                Settings.ShowToggledUltimate = value
                ActionBar.UpdateBarHighlightTables()
                ActionBar.OnSlotsFullUpdate()
            end,
            default = Defaults.ShowToggledUltimate,
            disable = function () return not (Settings.ShowToggled and LUIE.SV.ActionBar_Enabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BAR_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_AB_BAR_LABEL_TP),
            getFunction = function () return Settings.BarShowLabel end,
            setFunction = function (value)
                Settings.BarShowLabel = value
                ActionBar.ResetBarLabel()
            end,
            default = Defaults.BarShowLabel,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
            min = -72,
            max = 40,
            step = 2,
            format = "%.0f",
            getFunction = function () return Settings.BarLabelPosition end,
            setFunction = function (value)
                Settings.BarLabelPosition = value
                ActionBar.ResetBarLabel()
            end,
            default = Defaults.BarLabelPosition,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
            items = fontItems,
            getFunction = function () return Settings.BarFontFace end,
            setFunction = function (combobox, value, item)
                Settings.BarFontFace = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.BarFontFace,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.BarFontSize end,
            setFunction = function (value)
                Settings.BarFontSize = value
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.BarFontSize,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                local value = Settings.BarFontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.BarFontStyle = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.BarFontStyle,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
            getFunction = function () return Settings.BarMillis end,
            setFunction = function (value) Settings.BarMillis = value end,
            default = Defaults.BarMillis,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSTHRESHOLDVALUE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSTHRESHOLDVALUE_TP),
            min = 1,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.BarMillisThreshold end,
            setFunction = function (value)
                Settings.BarMillisThreshold = value
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.BarMillisThreshold,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD_TP),
            getFunction = function () return Settings.BarMillisAboveTen end,
            setFunction = function (value) Settings.BarMillisAboveTen = value end,
            default = Defaults.BarMillisAboveTen,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        -- Backbar subsection
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_BACKBAR_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_BACKBAR_NOTE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BACKBAR_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_ENABLE_TP),
            getFunction = function () return Settings.BarShowBack end,
            setFunction = function (value)
                Settings.BarShowBack = value
                ActionBar.OnSlotsFullUpdate()
                Backbar.BackbarToggleSettings()
            end,
            default = Defaults.BarShowBack,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BACKBAR_DARK),
            tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_DARK_TP),
            getFunction = function () return Settings.BarDarkUnused end,
            setFunction = function (value)
                Settings.BarDarkUnused = value
                ActionBar.OnSlotsFullUpdate()
                Backbar.BackbarToggleSettings()
            end,
            default = Defaults.BarDarkUnused,
            disable = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BACKBAR_DESATURATE),
            tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_DESATURATE_TP),
            getFunction = function () return Settings.BarDesaturateUnused end,
            setFunction = function (value)
                Settings.BarDesaturateUnused = value
                ActionBar.OnSlotsFullUpdate()
                Backbar.BackbarToggleSettings()
            end,
            default = Defaults.BarDesaturateUnused,
            disable = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_BACKBAR_HIDE_UNUSED),
            tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_HIDE_UNUSED_TP),
            getFunction = function () return Settings.BarHideUnused end,
            setFunction = function (value)
                Settings.BarHideUnused = value
                ActionBar.OnSlotsFullUpdate()
                Backbar.BackbarToggleSettings()
            end,
            default = Defaults.BarHideUnused,
            disable = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end
        }
    end)

    -- Build Quickslot Cooldown Timer Option Section
    buildSectionSettings("QuickslotCooldown", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_POTION),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_AB_QUICKSLOT),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_POTION),
            tooltip = GetString(LUIE_STRING_LAM_AB_POTION_TP),
            getFunction = function () return Settings.PotionTimerShow end,
            setFunction = function (value) Settings.PotionTimerShow = value end,
            default = Defaults.PotionTimerShow,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
            min = -72,
            max = 40,
            step = 2,
            format = "%.0f",
            getFunction = function () return Settings.PotionTimerLabelPosition end,
            setFunction = function (value)
                Settings.PotionTimerLabelPosition = value
                ActionBar.ResetPotionTimerLabel()
            end,
            default = Defaults.PotionTimerLabelPosition,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
            items = fontItems,
            getFunction = function () return Settings.PotionTimerFontFace end,
            setFunction = function (combobox, value, item)
                Settings.PotionTimerFontFace = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.PotionTimerFontFace,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.PotionTimerFontSize end,
            setFunction = function (value)
                Settings.PotionTimerFontSize = value
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.PotionTimerFontSize,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                local value = Settings.PotionTimerFontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.PotionTimerFontStyle = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
            end,
            default = Defaults.PotionTimerFontStyle,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_POTION_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_AB_POTION_COLOR_TP),
            getFunction = function () return Settings.PotionTimerColor end,
            setFunction = function (value) Settings.PotionTimerColor = value end,
            default = Defaults.PotionTimerColor,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
            getFunction = function () return Settings.PotionTimerMillis end,
            setFunction = function (value) Settings.PotionTimerMillis = value end,
            default = Defaults.PotionTimerMillis,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }
    end)

    -- Build Cast Bar Option Section
    buildSectionSettings("CastBar", function (settings)
        local function castBarOptionDisabled()
            return not LUIE.SV.ActionBar_Enabled or not Settings.CastBarEnable
        end

        local function castBarFontDisabled()
            return castBarOptionDisabled() or not (Settings.CastBarTimer or Settings.CastBarLabel)
        end

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_CASTBAR),
            canSelect = false,
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_AB_CASTBAR),
            canSelect = false,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_ENABLE_TP),
            getFunction = function () return Settings.CastBarEnable end,
            setFunction = function (value)
                Settings.CastBarEnable = value
                ActionBar.RegisterEvents()
                if ActionBar.consoleSettingsPanel then
                    SettingsAPI:RefreshPanel(ActionBar.consoleSettingsPanel)
                end
            end,
            default = Defaults.CastBarEnable,
            disable = function () return not LUIE.SV.ActionBar_Enabled end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE_TP),
            getFunction = function () return ActionBar.CastBarUnlocked end,
            setFunction = function (value)
                CastBar.SetMovingState(value)
            end,
            default = false,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_RESET_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = function ()
                CastBar.ResetCastBarPosition()
                if ActionBar.consoleSettingsPanel then
                    SettingsAPI:RefreshPanel(ActionBar.consoleSettingsPanel)
                end
            end,
            disable = castBarOptionDisabled,
        }

        local gw = GuiRoot:GetWidth()
        local gh = GuiRoot:GetHeight()
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X_TP),
            min = -gw,
            max = gw,
            step = 10,
            getFunction = function ()
                return CastBar.GetCastBarOffsetX()
            end,
            setFunction = function (value)
                ActionBar.SV.CastbarOffsetX = value
                if ActionBar.SV.CastbarOffsetY == nil then
                    ActionBar.SV.CastbarOffsetY = CastBar.GetCastBarOffsetY()
                end
                CastBar.SetCastBarPosition()
            end,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y_TP),
            min = -gh,
            max = gh,
            step = 10,
            getFunction = function ()
                return CastBar.GetCastBarOffsetY()
            end,
            setFunction = function (value)
                if ActionBar.SV.CastbarOffsetX == nil then
                    ActionBar.SV.CastbarOffsetX = CastBar.GetCastBarOffsetX()
                end
                ActionBar.SV.CastbarOffsetY = value
                CastBar.SetCastBarPosition()
            end,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_SIZEW),
            min = 100,
            max = 500,
            step = 5,
            format = "%.0f",
            getFunction = function () return Settings.CastBarSizeW end,
            setFunction = function (value)
                Settings.CastBarSizeW = value
                CastBar.ResizeCastBar()
            end,
            default = Defaults.CastBarSizeW,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_SIZEH),
            min = 16,
            max = 64,
            step = 2,
            format = "%.0f",
            getFunction = function () return Settings.CastBarSizeH end,
            setFunction = function (value)
                Settings.CastBarSizeH = value
                CastBar.ResizeCastBar()
            end,
            default = Defaults.CastBarSizeH,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_ICONSIZE),
            min = 16,
            max = 64,
            step = 2,
            format = "%.0f",
            getFunction = function () return Settings.CastBarIconSize end,
            setFunction = function (value)
                Settings.CastBarIconSize = value
                CastBar.ResizeCastBar()
            end,
            default = Defaults.CastBarIconSize,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL_TP),
            getFunction = function () return Settings.CastBarLabel end,
            setFunction = function (value)
                Settings.CastBarLabel = value
                ActionBar.CastBar.RefreshCastBarLabelVisibility()
                if ActionBar.consoleSettingsPanel then
                    SettingsAPI:RefreshPanel(ActionBar.consoleSettingsPanel)
                end
            end,
            default = Defaults.CastBarLabel,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_TP),
            getFunction = function () return Settings.CastBarTimer end,
            setFunction = function (value)
                Settings.CastBarTimer = value
                if ActionBar.consoleSettingsPanel then
                    SettingsAPI:RefreshPanel(ActionBar.consoleSettingsPanel)
                end
            end,
            default = Defaults.CastBarTimer,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT_TP),
            items =
            {
                { name = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT_MS),      data = 1 },
                { name = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT_SEC_01),  data = 2 },
                { name = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT_SEC_001), data = 3 },
            },
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(
                    SettingsAPI:NormalizeNumericIndexDropdown(
                        Settings.CastBarTimerFormat, nil, Defaults.CastBarTimerFormat, 3))
            end,
            setFunction = function (combobox, value, item)
                Settings.CastBarTimerFormat = item.data
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CastBarTimerFormat),
            disable = function ()
                return castBarOptionDisabled() or not Settings.CastBarTimer
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE_TP),
            items = fontItems,
            getFunction = function () return Settings.CastBarFontFace end,
            setFunction = function (combobox, value, item)
                Settings.CastBarFontFace = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarFontFace,
            disable = castBarFontDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.CastBarFontSize end,
            setFunction = function (value)
                Settings.CastBarFontSize = value
                SettingsAPI:MarkFontDeferred("actionBar")
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarFontSize,
            disable = castBarFontDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                local value = Settings.CastBarFontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.CastBarFontStyle = item.data
                SettingsAPI:MarkFontDeferred("actionBar")
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarFontStyle,
            disable = castBarFontDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE_TP),
            items = statusbarItems,
            getFunction = function () return Settings.CastBarTexture end,
            setFunction = function (combobox, value, item)
                Settings.CastBarTexture = item.data
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarTexture,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1_TP),
            getFunction = function () return Settings.CastBarGradientC1[1], Settings.CastBarGradientC1[2], Settings.CastBarGradientC1[3], Settings.CastBarGradientC1[4] end,
            setFunction = function (r, g, b, a)
                Settings.CastBarGradientC1 = { r, g, b, a }
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarGradientC1,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC2),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC2_TP),
            getFunction = function () return Settings.CastBarGradientC2[1], Settings.CastBarGradientC2[2], Settings.CastBarGradientC2[3], Settings.CastBarGradientC2[4] end,
            setFunction = function (r, g, b, a)
                Settings.CastBarGradientC2 = { r, g, b, a }
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarGradientC2,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_ICON_FRAME_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_ICON_FRAME_COLOR_TP),
            getFunction = function () return Settings.CastBarIconFrameColor[1], Settings.CastBarIconFrameColor[2], Settings.CastBarIconFrameColor[3], Settings.CastBarIconFrameColor[4] end,
            setFunction = function (r, g, b, a)
                Settings.CastBarIconFrameColor = { r, g, b, a }
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarIconFrameColor,
            disable = castBarOptionDisabled,
        }

        -- Filters subsection
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_FILTERS_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS_TP),
            getFunction = function () return Settings.CastBarHeavy end,
            setFunction = function (value) Settings.CastBarHeavy = value end,
            default = Defaults.CastBarHeavy,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_WEAVE_HELPER),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_WEAVE_HELPER_TP),
            getFunction = function () return Settings.CastBarWeaveHelper end,
            setFunction = function (value)
                Settings.CastBarWeaveHelper = value
                if ActionBar.CastBar and ActionBar.CastBar.OnWeaveHelperSettingChanged then
                    ActionBar.CastBar.OnWeaveHelperSettingChanged()
                end
            end,
            default = Defaults.CastBarWeaveHelper,
            disable = function ()
                return castBarOptionDisabled() or not LUIE.OtherAddonCompatability.isLibCombatEnabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_WEAVE_THRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_WEAVE_THRESHOLD_TP),
            min = 0,
            max = 200,
            step = 10,
            getFunction = function () return Settings.CastBarWeaveThresholdMs end,
            setFunction = function (value) Settings.CastBarWeaveThresholdMs = value end,
            default = Defaults.CastBarWeaveThresholdMs,
            disable = function ()
                return castBarOptionDisabled() or not Settings.CastBarWeaveHelper or not LUIE.OtherAddonCompatability.isLibCombatEnabled
            end,
        }

        -- Blacklist subsection
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT)
        }

        -- Store temp text for adding items
        if not Settings.tempBlacklistText then
            Settings.tempBlacklistText = ""
        end

        -- Add Item edit box
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunction = function ()
                return Settings.tempBlacklistText or ""
            end,
            setFunction = function (value)
                Settings.tempBlacklistText = value
            end,
            disable = castBarOptionDisabled,
        }

        -- Add Item button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            clickHandler = function ()
                local text = Settings.tempBlacklistText or ""
                if text and text ~= "" then
                    ActionBar.AddToCustomList(Settings.blacklist, text)
                    Settings.tempBlacklistText = ""
                    -- Refresh the blacklist dialog if it's open
                    if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_CASTBAR_BLACKLIST"] then
                        LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CASTBAR_BLACKLIST")
                    end
                    -- Refresh settings to clear the edit box
                    SettingsAPI:RefreshPanel(panel)
                end
            end,
            disable = castBarOptionDisabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
            buttonText = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            clickHandler = function () ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_CASTBAR_BLACKLIST") end,
            disable = castBarOptionDisabled,
        }

        -- Manage Blacklist
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
            buttonText = GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST),
            clickHandler = function ()
                if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_CASTBAR_BLACKLIST"] then
                    LUIE.ShowBlacklistDialog("LUIE_MANAGE_CASTBAR_BLACKLIST")
                end
            end,
            disable = castBarOptionDisabled,
        }
    end)

    local allSettings = {}
    SettingsAPI:AppendSettingsList(allSettings, initialSettings)
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_AB_HEADER_GCD), sectionGroups["GlobalCooldown"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_AB_HEADER_ULTIMATE), sectionGroups["UltimateTracking"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_AB_HEADER_COMPANION_ULTIMATE), sectionGroups["CompanionUltimate"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_AB_HEADER_BAR), sectionGroups["BarAbilityHighlight"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_AB_HEADER_POTION), sectionGroups["QuickslotCooldown"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_AB_HEADER_CASTBAR), sectionGroups["CastBar"])
    panel:AddSettings(allSettings)
end
