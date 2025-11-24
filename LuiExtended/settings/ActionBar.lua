-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Load Settings API
local SettingsAPI = LUIE.SettingsAPI

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

--- @class (partial) CastBar
local CastBar = ActionBar.CastBar

local zo_strformat = zo_strformat
local string_format = string.format
local type, pairs = type, pairs

local globalMethodOptions = { "Radial", "Vertical Reveal" }
local globalMethodOptionsKeys = { ["Radial"] = 1, ["Vertical Reveal"] = 2 }

local function SetAbilityBarTimersEnabled()
    if tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS)) == 0 then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS, "true", SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA)
    end
end

local castBarMovingEnabled = false -- Helper local flag
local Blacklist, BlacklistValues = {}, {}
local DurationOverridesList, DurationOverridesListValues = {}, {}

-- Create a list of abilityId's / abilityName's to use for Blacklist
local function GenerateCustomList(input)
    local options, values = {}, {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        -- If the input is a numeric value then we can pull this abilityId's info.
        if type(id) == "number" then
            options[counter] = zo_iconTextFormat(GetAbilityIcon(id), 16, 16, " [" .. id .. "] " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id)), true, true)
            -- If the input is not numeric then add this as a name only.
        else
            options[counter] = id
        end
        values[counter] = id
    end
    return options, values
end

local dialogs =
{
    [1] =
    { -- Clear Blacklist
        identifier = "LUIE_CLEAR_CASTBAR_BLACKLIST",
        title = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG), GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST)),
        callback = function (dialog)
            ActionBar.ClearCustomList(ActionBar.SV.blacklist)
            LUIE_BlacklistCastbar:UpdateChoices(GenerateCustomList(ActionBar.SV.blacklist))
        end,
    },
}

local function loadDialogButtons()
    for i = 1, #dialogs do
        local dialog = dialogs[i]
        LUIE.RegisterDialogueButton(dialog.identifier, dialog.title, dialog.text, dialog.callback)
    end
end

-- Load LibAddonMenu
local LAM = LUIE.LAM

function ActionBar.CreateSettings()
    local Defaults = ActionBar.Defaults
    local Settings = ActionBar.SV

    -- Load Dialog Buttons
    loadDialogButtons()

    -- Sync castBarMovingEnabled with ActionBar.CastBarUnlocked
    castBarMovingEnabled = ActionBar.CastBarUnlocked or false

    local panelDataActionBar =
    {
        type = "panel",
        name = zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_AB)),
        displayName = zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_AB)),
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luiab",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsDataActionBar = {}

    -- Action Bar Description
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "description",
        text = GetString(LUIE_STRING_LAM_AB_DESCRIPTION),
    }

    -- ReloadUI Button
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        func = function ()
            ReloadUI("ingame")
        end,
        width = "full",
    }

    -- Action Bar - Global Cooldown Options Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_GCD),
        {
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_GCD_SHOW),
                GetString(LUIE_STRING_LAM_AB_GCD_SHOW_TP),
                function () return Settings.GlobalShowGCD end,
                function (value)
                    Settings.GlobalShowGCD = value
                    ActionBar.HookGCD()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.GlobalShowGCD,
                GetString(LUIE_STRING_LAM_AB_GCD_SHOW_WARN)
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_GCD_QUICK),
                GetString(LUIE_STRING_LAM_AB_GCD_QUICK_TP),
                function () return Settings.GlobalPotion end,
                function (value) Settings.GlobalPotion = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                Defaults.GlobalPotion
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_GCD_FLASH),
                GetString(LUIE_STRING_LAM_AB_GCD_FLASH_TP),
                function () return Settings.GlobalFlash end,
                function (value) Settings.GlobalFlash = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                Defaults.GlobalFlash
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_GCD_DESAT),
                GetString(LUIE_STRING_LAM_AB_GCD_DESAT_TP),
                function () return Settings.GlobalDesat end,
                function (value) Settings.GlobalDesat = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                Defaults.GlobalDesat
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_GCD_COLOR),
                GetString(LUIE_STRING_LAM_AB_GCD_COLOR_TP),
                function () return Settings.GlobalLabelColor end,
                function (value) Settings.GlobalLabelColor = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                Defaults.GlobalLabelColor
            ),
            SettingsAPI.CreateIndentedDropdown(
                GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION),
                GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION_TP),
                globalMethodOptions,
                function () return globalMethodOptions[Settings.GlobalMethod] end,
                function (value) Settings.GlobalMethod = globalMethodOptionsKeys[value] end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                globalMethodOptions[Defaults.GlobalMethod]
            ),
        }
    )

    -- Action Bar - Ultimate Tracking Options Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_ULTIMATE),
        {
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_VAL),
                GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_VAL_TP),
                function () return Settings.UltimateLabelEnabled end,
                function (value)
                    Settings.UltimateLabelEnabled = value
                    ActionBar.RegisterEvents()
                    ActionBar.UpdateUltimateLabel()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.UltimateLabelEnabled
            ),
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_PCT),
                GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_PCT_TP),
                function () return Settings.UltimatePctEnabled end,
                function (value)
                    Settings.UltimatePctEnabled = value
                    ActionBar.RegisterEvents()
                    ActionBar.UpdateUltimateLabel()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.UltimatePctEnabled
            ),
            SettingsAPI.CreateIndentedSlider(
                GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
                GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
                -72, 40, 2,
                function () return Settings.UltimateLabelPosition end,
                function (value)
                    Settings.UltimateLabelPosition = value
                    ActionBar.ResetUltimateLabel()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                Defaults.UltimateLabelPosition
            ),
            SettingsAPI.CreateIndentedDropdown(
                GetString(LUIE_STRING_LAM_FONT),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                SettingsAPI.GetFontsList(),
                function () return Settings.UltimateFontFace end,
                function (var)
                    Settings.UltimateFontFace = var
                    ActionBar.ApplyFont()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                Defaults.UltimateFontFace,
                nil,
                "name-up"
            ),
            SettingsAPI.CreateIndentedSlider(
                GetString(LUIE_STRING_LAM_FONT_SIZE),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
                10, 30, 1,
                function () return Settings.UltimateFontSize end,
                function (value)
                    Settings.UltimateFontSize = value
                    ActionBar.ApplyFont()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                Defaults.UltimateFontSize
            ),
            {
                type = "dropdown",
                name = zo_strformat("\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
                choices = LUIE.FONT_STYLE_CHOICES,
                choicesValues = LUIE.FONT_STYLE_CHOICES_VALUES,
                sort = "name-up",
                getFunc = function () return Settings.UltimateFontStyle end,
                setFunc = function (var)
                    Settings.UltimateFontStyle = var
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                default = Defaults.UltimateFontStyle,
            },
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_ULTIMATE_HIDEFULL),
                GetString(LUIE_STRING_LAM_AB_ULTIMATE_HIDEFULL_TP),
                function () return Settings.UltimateHideFull end,
                function (value)
                    Settings.UltimateHideFull = value
                    ActionBar.UpdateUltimateLabel()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                Defaults.UltimateHideFull
            ),
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_ULTIMATE_TEXTURE),
                GetString(LUIE_STRING_LAM_AB_ULTIMATE_TEXTURE_TP),
                function () return Settings.UltimateGeneration end,
                function (value) Settings.UltimateGeneration = value end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.UltimateGeneration
            ),
        }
    )

    -- Action Bar - Bar Ability Highlight Options Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_BAR),
        {
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_BAR_PROC),
                GetString(LUIE_STRING_LAM_AB_BAR_PROC_TP),
                function () return Settings.ShowTriggered end,
                function (value)
                    Settings.ShowTriggered = value
                    ActionBar.UpdateBarHighlightTables()
                    ActionBar.OnSlotsFullUpdate()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.ShowTriggered
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND),
                GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND_TP),
                function () return Settings.ProcEnableSound end,
                function (value) Settings.ProcEnableSound = value end,
                1,
                "half",
                function () return not (Settings.ShowTriggered and LUIE.SV.ActionBar_Enabled) end,
                Defaults.ProcEnableSound
            ),
            SettingsAPI.CreateIndentedDropdown(
                GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUNDCHOICE),
                GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUNDCHOICE_TP),
                SettingsAPI.GetSoundsList(),
                function () return Settings.ProcSoundName end,
                function (value)
                    Settings.ProcSoundName = value
                    ActionBar.ApplyProcSound(true)
                end,
                1,
                "half",
                function () return not (Settings.ShowTriggered and Settings.ProcEnableSound and LUIE.SV.ActionBar_Enabled) end,
                Defaults.ProcSoundName,
                nil,
                "name-up"
            ),
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_BAR_EFFECT),
                GetString(LUIE_STRING_LAM_AB_BAR_EFFECT_TP),
                function () return Settings.ShowToggled end,
                function (value)
                    Settings.ShowToggled = value
                    ActionBar.UpdateBarHighlightTables()
                    ActionBar.OnSlotsFullUpdate()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.ShowToggled
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_BAR_ULTIMATE),
                GetString(LUIE_STRING_LAM_AB_BAR_ULTIMATE_TP),
                function () return Settings.ShowToggledUltimate end,
                function (value)
                    Settings.ShowToggledUltimate = value
                    ActionBar.UpdateBarHighlightTables()
                    ActionBar.OnSlotsFullUpdate()
                end,
                1,
                "full",
                function () return not (Settings.ShowToggled and LUIE.SV.ActionBar_Enabled) end,
                Defaults.ShowToggledUltimate
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_BAR_LABEL),
                GetString(LUIE_STRING_LAM_AB_BAR_LABEL_TP),
                function () return Settings.BarShowLabel end,
                function (value)
                    Settings.BarShowLabel = value
                    SetAbilityBarTimersEnabled()
                    ActionBar.ResetBarLabel()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarShowLabel
            ),
            SettingsAPI.CreateIndentedSlider(
                GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
                GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
                -72, 40, 2,
                function () return Settings.BarLabelPosition end,
                function (value)
                    Settings.BarLabelPosition = value
                    ActionBar.ResetBarLabel()
                end,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarLabelPosition
            ),
            SettingsAPI.CreateIndentedDropdown(
                GetString(LUIE_STRING_LAM_FONT),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                SettingsAPI.GetFontsList(),
                function () return Settings.BarFontFace end,
                function (var)
                    Settings.BarFontFace = var
                    ActionBar.ApplyFont()
                end,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarFontFace,
                nil,
                "name-up"
            ),
            SettingsAPI.CreateIndentedSlider(
                GetString(LUIE_STRING_LAM_FONT_SIZE),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
                10, 30, 1,
                function () return Settings.BarFontSize end,
                function (value)
                    Settings.BarFontSize = value
                    ActionBar.ApplyFont()
                end,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarFontSize
            ),
            {
                type = "dropdown",
                name = zo_strformat("\t\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
                choices = LUIE.FONT_STYLE_CHOICES,
                choicesValues = LUIE.FONT_STYLE_CHOICES_VALUES,
                sort = "name-up",
                getFunc = function () return Settings.BarFontStyle end,
                setFunc = function (var)
                    Settings.BarFontStyle = var
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                default = Defaults.BarFontStyle,
            },
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
                GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
                function () return Settings.BarMillis end,
                function (value) Settings.BarMillis = value end,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarMillis
            ),
            SettingsAPI.CreateIndentedSlider(
                GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSTHRESHOLDVALUE),
                GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSTHRESHOLDVALUE_TP),
                1, 30, 1,
                function () return Settings.BarMillisThreshold end,
                function (value)
                    Settings.BarMillisThreshold = value
                    ActionBar.ApplyFont()
                end,
                3,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarMillisThreshold
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD),
                GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD_TP),
                function () return Settings.BarMillisAboveTen end,
                function (value) Settings.BarMillisAboveTen = value end,
                3,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarMillisAboveTen
            ),
            SettingsAPI.CreateIndentedCheckbox(
                "Colored Remaining Text",
                "Enable colored text for remaining duration labels on ability highlights",
                function () return Settings.RemainingTextColoured end,
                function (value)
                    Settings.RemainingTextColoured = value
                    -- Colors are updated dynamically in OnUpdate
                end,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.RemainingTextColoured
            ),
            SettingsAPI.CreateIndentedColorpickerFromTable(
                "Remaining Text Color (High)",
                "Color when duration is above mid threshold (high time remaining)",
                function () return unpack(Settings.RemainingTextColorHigh) end,
                function (r, g, b, a)
                    Settings.RemainingTextColorHigh = { r, g, b, a }
                end,
                Defaults.RemainingTextColorHigh,
                3,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end
            ),
            SettingsAPI.CreateIndentedColorpickerFromTable(
                "Remaining Text Color (Mid)",
                "Color when duration is between low and mid thresholds",
                function () return unpack(Settings.RemainingTextColorMid) end,
                function (r, g, b, a)
                    Settings.RemainingTextColorMid = { r, g, b, a }
                end,
                Defaults.RemainingTextColorMid,
                3,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end
            ),
            SettingsAPI.CreateIndentedColorpickerFromTable(
                "Remaining Text Color (Low)",
                "Color when duration is below low threshold (low time remaining)",
                function () return unpack(Settings.RemainingTextColorLow) end,
                function (r, g, b, a)
                    Settings.RemainingTextColorLow = { r, g, b, a }
                end,
                Defaults.RemainingTextColorLow,
                3,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end
            ),
            SettingsAPI.CreateIndentedSlider(
                "Mid Threshold (%)",
                "Percentage of duration remaining to switch from high to mid color (0.0-1.0)",
                0, 100, 1,
                function () return Settings.RemainingTextColorThresholdMid * 100 end,
                function (value)
                    Settings.RemainingTextColorThresholdMid = value / 100
                end,
                3,
                "half",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.RemainingTextColorThresholdMid * 100
            ),
            SettingsAPI.CreateIndentedSlider(
                "Low Threshold (%)",
                "Percentage of duration remaining to switch from mid to low color (0.0-1.0)",
                0, 100, 1,
                function () return Settings.RemainingTextColorThresholdLow * 100 end,
                function (value)
                    Settings.RemainingTextColorThresholdLow = value / 100
                end,
                3,
                "half",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.RemainingTextColorThresholdLow * 100
            ),
            SettingsAPI.CreateDividerOption("full"),
            SettingsAPI.CreateHeaderOption(GetString(LUIE_STRING_LAM_AB_BACKBAR_HEADER)),
            SettingsAPI.CreateDescriptionOption(GetString(LUIE_STRING_LAM_AB_BACKBAR_NOTE)),
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_BACKBAR_ENABLE),
                GetString(LUIE_STRING_LAM_AB_BACKBAR_ENABLE_TP),
                function () return Settings.BarShowBack end,
                function (value)
                    Settings.BarShowBack = value
                    ActionBar.OnSlotsFullUpdate()
                    ActionBar.BackbarToggleSettings()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.BarShowBack
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_BACKBAR_DARK),
                GetString(LUIE_STRING_LAM_AB_BACKBAR_DARK_TP),
                function () return Settings.BarDarkUnused end,
                function (value)
                    Settings.BarDarkUnused = value
                    ActionBar.OnSlotsFullUpdate()
                    ActionBar.BackbarToggleSettings()
                end,
                1,
                "full",
                function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end,
                Defaults.BarDarkUnused
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_BACKBAR_DESATURATE),
                GetString(LUIE_STRING_LAM_AB_BACKBAR_DESATURATE_TP),
                function () return Settings.BarDesaturateUnused end,
                function (value)
                    Settings.BarDesaturateUnused = value
                    ActionBar.OnSlotsFullUpdate()
                    ActionBar.BackbarToggleSettings()
                end,
                1,
                "full",
                function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end,
                Defaults.BarDesaturateUnused
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_BACKBAR_HIDE_UNUSED),
                GetString(LUIE_STRING_LAM_AB_BACKBAR_HIDE_UNUSED_TP),
                function () return Settings.BarHideUnused end,
                function (value)
                    Settings.BarHideUnused = value
                    ActionBar.OnSlotsFullUpdate()
                    ActionBar.BackbarToggleSettings()
                end,
                1,
                "full",
                function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end,
                Defaults.BarHideUnused
            ),
        }
    )

    -- Action Bar - Quickslot Cooldown Timer Option Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_POTION),
        {
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_POTION),
                GetString(LUIE_STRING_LAM_AB_POTION_TP),
                function () return Settings.PotionTimerShow end,
                function (value) Settings.PotionTimerShow = value end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.PotionTimerShow
            ),
            SettingsAPI.CreateIndentedSlider(
                GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
                GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
                -72, 40, 2,
                function () return Settings.PotionTimerLabelPosition end,
                function (value)
                    Settings.PotionTimerLabelPosition = value
                    ActionBar.ResetPotionTimerLabel()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                Defaults.PotionTimerLabelPosition
            ),
            SettingsAPI.CreateIndentedDropdown(
                GetString(LUIE_STRING_LAM_FONT),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                SettingsAPI.GetFontsList(),
                function () return Settings.PotionTimerFontFace end,
                function (var)
                    Settings.PotionTimerFontFace = var
                    ActionBar.ApplyFont()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                Defaults.PotionTimerFontFace,
                nil,
                "name-up"
            ),
            SettingsAPI.CreateIndentedSlider(
                GetString(LUIE_STRING_LAM_FONT_SIZE),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
                10, 30, 1,
                function () return Settings.PotionTimerFontSize end,
                function (value)
                    Settings.PotionTimerFontSize = value
                    ActionBar.ApplyFont()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                Defaults.PotionTimerFontSize
            ),
            {
                type = "dropdown",
                name = zo_strformat("\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
                choices = LUIE.FONT_STYLE_CHOICES,
                choicesValues = LUIE.FONT_STYLE_CHOICES_VALUES,
                sort = "name-up",
                getFunc = function () return Settings.PotionTimerFontStyle end,
                setFunc = function (var)
                    Settings.PotionTimerFontStyle = var
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                default = Defaults.PotionTimerFontStyle,
            },
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_POTION_COLOR),
                GetString(LUIE_STRING_LAM_AB_POTION_COLOR_TP),
                function () return Settings.PotionTimerColor end,
                function (value) Settings.PotionTimerColor = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                Defaults.PotionTimerColor
            ),
            SettingsAPI.CreateIndentedColorpickerFromTable(
                "Quickslot Timer Color (High)",
                "Color when remaining time is above mid threshold",
                function () return unpack(Settings.PotionTimerTextColorHigh) end,
                function (r, g, b, a)
                    Settings.PotionTimerTextColorHigh = { r, g, b, a }
                end,
                Defaults.PotionTimerTextColorHigh,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end
            ),
            SettingsAPI.CreateIndentedColorpickerFromTable(
                "Quickslot Timer Color (Mid)",
                "Color when remaining time is between low and mid thresholds",
                function () return unpack(Settings.PotionTimerTextColorMid) end,
                function (r, g, b, a)
                    Settings.PotionTimerTextColorMid = { r, g, b, a }
                end,
                Defaults.PotionTimerTextColorMid,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end
            ),
            SettingsAPI.CreateIndentedColorpickerFromTable(
                "Quickslot Timer Color (Low)",
                "Color when remaining time is below low threshold",
                function () return unpack(Settings.PotionTimerTextColorLow) end,
                function (r, g, b, a)
                    Settings.PotionTimerTextColorLow = { r, g, b, a }
                end,
                Defaults.PotionTimerTextColorLow,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end
            ),
            SettingsAPI.CreateIndentedSlider(
                "Mid Threshold (ms)",
                "Remaining time in milliseconds to switch from high to mid color",
                1000, 60000, 1000,
                function () return Settings.PotionTimerTextColorThresholdMid end,
                function (value)
                    Settings.PotionTimerTextColorThresholdMid = value
                end,
                2,
                "half",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end,
                Defaults.PotionTimerTextColorThresholdMid
            ),
            SettingsAPI.CreateIndentedSlider(
                "Low Threshold (ms)",
                "Remaining time in milliseconds to switch from mid to low color",
                500, 30000, 500,
                function () return Settings.PotionTimerTextColorThresholdLow end,
                function (value)
                    Settings.PotionTimerTextColorThresholdLow = value
                end,
                2,
                "half",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end,
                Defaults.PotionTimerTextColorThresholdLow
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
                GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
                function () return Settings.PotionTimerMillis end,
                function (value) Settings.PotionTimerMillis = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                Defaults.PotionTimerMillis
            ),
        }
    )

    -- Action Bar -- Cast Bar Option Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_CASTBAR),
        {
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE_TP),
                function () return castBarMovingEnabled end,
                function (value)
                    castBarMovingEnabled = value
                    CastBar.SetMovingState(value)
                end,
                "half",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                false,
                nil,
                nil,
                CastBar.ResetCastBarPosition
            ),
            SettingsAPI.CreateButtonOption(
                GetString(LUIE_STRING_LAM_RESETPOSITION),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_RESET_TP),
                CastBar.ResetCastBarPosition,
                "half",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
            ),
            SettingsAPI.CreateCheckboxOption(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_ENABLE),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_ENABLE_TP),
                function () return Settings.CastBarEnable end,
                function (value)
                    Settings.CastBarEnable = value
                    ActionBar.RegisterEvents()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.CastBarEnable
            ),
            SettingsAPI.CreateSliderOption(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_SIZEW),
                nil,
                100, 500, 5,
                function () return Settings.CastBarSizeW end,
                function (value)
                    Settings.CastBarSizeW = value
                    CastBar.ResizeCastBar()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.CastBarSizeW
            ),
            SettingsAPI.CreateSliderOption(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_SIZEH),
                nil,
                16, 64, 2,
                function () return Settings.CastBarSizeH end,
                function (value)
                    Settings.CastBarSizeH = value
                    CastBar.ResizeCastBar()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.CastBarSizeH
            ),
            SettingsAPI.CreateSliderOption(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_ICONSIZE),
                nil,
                16, 64, 2,
                function () return Settings.CastBarIconSize end,
                function (value)
                    Settings.CastBarIconSize = value
                    CastBar.ResizeCastBar()
                end,
                "full",
                function () return not LUIE.SV.ActionBar_Enabled end,
                Defaults.CastBarIconSize
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL_TP),
                function () return Settings.CastBarLabel end,
                function (value) Settings.CastBarLabel = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                Defaults.CastBarLabel
            ),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_TP),
                function () return Settings.CastBarTimer end,
                function (value) Settings.CastBarTimer = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                Defaults.CastBarTimer
            ),
            SettingsAPI.CreateIndentedDropdown(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE_TP),
                SettingsAPI.GetFontsList(),
                function () return Settings.CastBarFontFace end,
                function (var)
                    Settings.CastBarFontFace = var
                    ActionBar.ApplyFont()
                    CastBar.UpdateCastBar()
                end,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                Defaults.CastBarFontFace,
                nil,
                "name-up"
            ),
            SettingsAPI.CreateIndentedSlider(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSIZE),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSIZE_TP),
                10, 30, 1,
                function () return Settings.CastBarFontSize end,
                function (value)
                    Settings.CastBarFontSize = value
                    ActionBar.ApplyFont()
                    CastBar.UpdateCastBar()
                end,
                2,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                Defaults.CastBarFontSize
            ),
            {
                type = "dropdown",
                name = zo_strformat("\t\t<<1>>", GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE)),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE_TP),
                choices = LUIE.FONT_STYLE_CHOICES,
                choicesValues = LUIE.FONT_STYLE_CHOICES_VALUES,
                sort = "name-up",
                getFunc = function () return Settings.CastBarFontStyle end,
                setFunc = function (var)
                    Settings.CastBarFontStyle = var
                    ActionBar.ApplyFont()
                    CastBar.UpdateCastBar()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                default = Defaults.CastBarFontStyle,
            },
            SettingsAPI.CreateIndentedDropdown(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE_TP),
                SettingsAPI.GetStatusbarTexturesList(),
                function () return Settings.CastBarTexture end,
                function (value)
                    Settings.CastBarTexture = value
                    CastBar.UpdateCastBar()
                end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                Defaults.CastBarTexture,
                nil,
                "name-up"
            ),
            SettingsAPI.CreateIndentedColorpickerFromTable(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1_TP),
                function () return unpack(Settings.CastBarGradientC1) end,
                function (r, g, b, a)
                    Settings.CastBarGradientC1 = { r, g, b, a }
                    CastBar.UpdateCastBar()
                end,
                Defaults.CastBarGradientC1,
                1,
                "half",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
            ),
            SettingsAPI.CreateIndentedColorpickerFromTable(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC2),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC2_TP),
                function () return unpack(Settings.CastBarGradientC2) end,
                function (r, g, b, a)
                    Settings.CastBarGradientC2 = { r, g, b, a }
                    CastBar.UpdateCastBar()
                end,
                Defaults.CastBarGradientC2,
                1,
                "half",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
            ),
            SettingsAPI.CreateHeaderOption(GetString(LUIE_STRING_LAM_AB_CASTBAR_FILTERS_HEADER)),
            SettingsAPI.CreateIndentedCheckbox(
                GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS_TP),
                function () return Settings.CastBarHeavy end,
                function (value) Settings.CastBarHeavy = value end,
                1,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                Defaults.CastBarHeavy
            ),
            SettingsAPI.CreateHeaderOption(GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST)),
            SettingsAPI.CreateDescriptionOption(GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT)),
            SettingsAPI.CreateButtonOption(
                GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
                GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
                function () ZO_Dialogs_ShowDialog("LUIE_CLEAR_CASTBAR_BLACKLIST") end,
                "half"
            ),
            SettingsAPI.CreateEditboxOption(
                GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
                GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
                function () end,
                function (value)
                    ActionBar.AddToCustomList(Settings.blacklist, value)
                    LUIE_BlacklistCastbar:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                "half"
            ),
            {
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
                choices = Blacklist,
                choicesValues = BlacklistValues,
                scrollable = 7,
                sort = "name-up",
                getFunc = function ()
                    LUIE_BlacklistCastbar:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                setFunc = function (value)
                    ActionBar.RemoveFromCustomList(Settings.blacklist, value)
                    LUIE_BlacklistCastbar:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                reference = "LUIE_BlacklistCastbar",
                width = "full",
            },
        }
    )

    -- Action Bar - Duration Override Options Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "submenu",
        name = "Ability Duration Overrides",
        controls =
        {
            {
                type = "description",
                text = "Override ability durations. Useful when the game API reports the wrong duration for abilities with multiple effects.",
            },
            {
                -- Select Ability to Override
                type = "dropdown",
                name = "Select Ability",
                tooltip = "Select an ability from your currently tracked abilities to override its duration",
                choices = DurationOverridesList,
                choicesValues = DurationOverridesListValues,
                scrollable = 10,
                sort = "name-up",
                getFunc = function ()
                    local choices, choicesValues = ActionBar.GetTrackedAbilitiesForOverride()
                    LUIE_DurationOverrideSelect:UpdateChoices(choices, choicesValues)
                    return Settings.selectedAbilityForDurationOverride or 0
                end,
                setFunc = function (value)
                    Settings.selectedAbilityForDurationOverride = value
                    -- Update the duration field to show current duration
                    if Settings.durationOverrides[value] then
                        Settings.tempDurationOverrideValue = tostring(Settings.durationOverrides[value])
                    else
                        local duration = GetAbilityDuration(value)
                        Settings.tempDurationOverrideValue = duration > 0 and tostring(duration) or ""
                    end
                    LUIE_DurationOverrideEditbox:UpdateValue()
                end,
                reference = "LUIE_DurationOverrideSelect",
            },
            {
                -- Duration Override Value
                type = "editbox",
                name = "Duration (milliseconds)",
                tooltip = "Set the duration for the selected ability in milliseconds\nExample: 15000 for 15 seconds",
                getFunc = function ()
                    return Settings.tempDurationOverrideValue or ""
                end,
                setFunc = function (value)
                    Settings.tempDurationOverrideValue = value
                end,
                isMultiline = false,
                width = "half",
                reference = "LUIE_DurationOverrideEditbox",
                disabled = function ()
                    return not Settings.selectedAbilityForDurationOverride or Settings.selectedAbilityForDurationOverride == 0
                end,
            },
            {
                -- Apply Duration Override
                type = "button",
                name = "Apply Override",
                tooltip = "Apply the duration override for the selected ability",
                func = function ()
                    local abilityId = Settings.selectedAbilityForDurationOverride
                    local durationStr = Settings.tempDurationOverrideValue

                    if not abilityId or abilityId == 0 then
                        LUIE.PrintToChat("ActionBar: Please select an ability first", true)
                        return
                    end

                    local duration = tonumber(durationStr)
                    if not duration or duration <= 0 then
                        LUIE.PrintToChat("ActionBar: Invalid duration. Must be a positive number", true)
                        return
                    end

                    -- Use the module function to add the override
                    ActionBar.AddDurationOverride(string_format("%d %d", abilityId, duration))

                    -- Update the remove dropdown
                    LUIE_DurationOverrideRemove:UpdateChoices(GenerateCustomList(Settings.durationOverrides))
                end,
                width = "half",
                disabled = function ()
                    return not Settings.selectedAbilityForDurationOverride or Settings.selectedAbilityForDurationOverride == 0
                end,
            },
            {
                -- Duration Override List (Remove)
                type = "dropdown",
                name = "Remove Override",
                tooltip = "Select an override to remove",
                choices = {},
                choicesValues = {},
                scrollable = 7,
                sort = "name-up",
                getFunc = function ()
                    LUIE_DurationOverrideRemove:UpdateChoices(GenerateCustomList(Settings.durationOverrides))
                end,
                setFunc = function (value)
                    ActionBar.RemoveDurationOverride(value)
                    LUIE_DurationOverrideRemove:UpdateChoices(GenerateCustomList(Settings.durationOverrides))
                    local choices, choicesValues = ActionBar.GetTrackedAbilitiesForOverride()
                    LUIE_DurationOverrideSelect:UpdateChoices(choices, choicesValues)
                end,
                reference = "LUIE_DurationOverrideRemove",
            },
            {
                -- Clear All Duration Overrides
                type = "button",
                name = "Clear All Overrides",
                tooltip = "Remove all custom duration overrides",
                func = function ()
                    ActionBar.ClearDurationOverrides()
                    LUIE_DurationOverrideRemove:UpdateChoices(GenerateCustomList(Settings.durationOverrides))
                    local choices, choicesValues = ActionBar.GetTrackedAbilitiesForOverride()
                    LUIE_DurationOverrideSelect:UpdateChoices(choices, choicesValues)
                end,
                width = "half",
                warning = "This will remove ALL duration overrides!",
            },
        },
    }

    -- Register the settings panel
    if LUIE.SV.ActionBar_Enabled then
        LAM:RegisterAddonPanel(LUIE.name .. "ActionBarOptions", panelDataActionBar)
        LAM:RegisterOptionControls(LUIE.name .. "ActionBarOptions", optionsDataActionBar)
    end
end

