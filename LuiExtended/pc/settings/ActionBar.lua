-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local SettingsAPI = LUIE.SettingsAPI

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar
local CastBar = ActionBar.CastBar
local Backbar = ActionBar.Backbar

local zo_strformat = zo_strformat
local string_format = string.format
local string_rep = string.rep
local type, pairs = type, pairs
local table_insert = table.insert

local globalMethodOptions =
{
    GetString(LUIE_STRING_LAM_AB_GCD_ANIM_RADIAL),
    GetString(LUIE_STRING_LAM_AB_GCD_ANIM_VERTICAL_REVEAL),
}
local globalMethodOptionValues = { 1, 2 }

-- Helper function to get sounds list
local function GetSoundsList()
    local soundsList = {}
    for sound, _ in pairs(LUIE.Sounds) do
        table_insert(soundsList, sound)
    end
    return soundsList
end

-- Helper function to add indentation to names
local function AddIndent(name, level)
    level = level or 1
    local tabs = string_rep("\t", level)
    return zo_strformat("<<1>><<2>>", tabs, name)
end

local function SetAbilityBarTimersEnabled()
    if tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS)) == 0 then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS, "true", SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA)
    end
end

local castBarMovingEnabled = false -- Helper local flag
local Blacklist, BlacklistValues = {}, {}

-- Create a list of abilityId's / abilityName's to use for Blacklist
local function GenerateCustomList(input)
    local options, values = {}, {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        -- If the input is a numeric value then we can pull this abilityId's info.
        if type(id) == "number" then
            options[counter] = zo_iconTextFormat(GetAbilityIcon(id), 16, 16, " [" .. id .. "] " .. zo_strformat("<<C:1>>", GetAbilityName(id)), true, true)
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

    if not LUIE.SV.ActionBar_Enabled then
        return
    end

    -- Load Dialog Buttons
    loadDialogButtons()

    -- Sync castBarMovingEnabled with ActionBar.CastBarUnlocked
    castBarMovingEnabled = ActionBar.CastBarUnlocked or false

    local panelDataActionBar =
    {
        type = "panel",
        name = LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_AB),
        displayName = LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_AB),
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

    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_AB_DISPLAY_OPTIONS_HEADER),
    }
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "slider",
        name = zo_strformat("<<1>>", GetString(LUIE_STRING_SHARED_OOC_OPACITY)),
        tooltip = GetString(LUIE_STRING_LAM_AB_OOC_OPACITY_TP),
        min = 0,
        max = 100,
        step = 5,
        getFunc = function ()
            return Settings.oocAlpha
        end,
        setFunc = function (value)
            Settings.oocAlpha = value
            ActionBar.ApplyDisplayAlpha()
        end,
        width = "full",
        default = Defaults.oocAlpha,
        disabled = function () return not LUIE.SV.ActionBar_Enabled end,
    }
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "slider",
        name = zo_strformat("<<1>>", GetString(LUIE_STRING_SHARED_IC_OPACITY)),
        tooltip = GetString(LUIE_STRING_LAM_AB_IC_OPACITY_TP),
        min = 0,
        max = 100,
        step = 5,
        getFunc = function ()
            return Settings.incAlpha
        end,
        setFunc = function (value)
            Settings.incAlpha = value
            ActionBar.ApplyDisplayAlpha()
        end,
        width = "full",
        default = Defaults.incAlpha,
        disabled = function () return not LUIE.SV.ActionBar_Enabled end,
    }

    -- Action Bar - Global Cooldown Options Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_AB_HEADER_GCD),
        controls =
        {
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_GCD_SHOW),
                tooltip = GetString(LUIE_STRING_LAM_AB_GCD_SHOW_TP),
                getFunc = function () return Settings.GlobalShowGCD end,
                setFunc = function (value)
                    Settings.GlobalShowGCD = value
                    ActionBar.HookGCD()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.GlobalShowGCD,
                warning = GetString(LUIE_STRING_LAM_AB_GCD_SHOW_WARN),
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_GCD_QUICK), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_GCD_QUICK_TP),
                getFunc = function () return Settings.GlobalPotion end,
                setFunc = function (value) Settings.GlobalPotion = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                default = Defaults.GlobalPotion,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_GCD_FLASH), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_GCD_FLASH_TP),
                getFunc = function () return Settings.GlobalFlash end,
                setFunc = function (value) Settings.GlobalFlash = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                default = Defaults.GlobalFlash,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_GCD_DESAT), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_GCD_DESAT_TP),
                getFunc = function () return Settings.GlobalDesat end,
                setFunc = function (value) Settings.GlobalDesat = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                default = Defaults.GlobalDesat,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_GCD_COLOR), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_GCD_COLOR_TP),
                getFunc = function () return Settings.GlobalLabelColor end,
                setFunc = function (value) Settings.GlobalLabelColor = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                default = Defaults.GlobalLabelColor,
            },
            {
                type = "dropdown",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION_TP),
                choices = globalMethodOptions,
                choicesValues = globalMethodOptionValues,
                getFunc = function () return Settings.GlobalMethod end,
                setFunc = function (value) Settings.GlobalMethod = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                default = Defaults.GlobalMethod,
            },
        },
    }

    -- Action Bar - Ultimate Tracking Options Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_AB_HEADER_ULTIMATE),
        controls =
        {
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_VAL),
                tooltip = GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_VAL_TP),
                getFunc = function () return Settings.UltimateLabelEnabled end,
                setFunc = function (value)
                    Settings.UltimateLabelEnabled = value
                    ActionBar.RegisterEvents()
                    ActionBar.UpdateUltimateLabel()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.UltimateLabelEnabled,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_PCT),
                tooltip = GetString(LUIE_STRING_LAM_AB_ULTIMATE_SHOW_PCT_TP),
                getFunc = function () return Settings.UltimatePctEnabled end,
                setFunc = function (value)
                    Settings.UltimatePctEnabled = value
                    ActionBar.RegisterEvents()
                    ActionBar.UpdateUltimateLabel()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.UltimatePctEnabled,
            },
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_SHARED_POSITION), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
                min = -72,
                max = 40,
                step = 2,
                getFunc = function () return Settings.UltimateLabelPosition end,
                setFunc = function (value)
                    Settings.UltimateLabelPosition = value
                    ActionBar.ResetUltimateLabel()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                default = Defaults.UltimateLabelPosition,
            },
            SettingsAPI.CreateFontDropdown(
                AddIndent(GetString(LUIE_STRING_LAM_FONT), 1),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                function () return Settings.UltimateFontFace end,
                function (var)
                    Settings.UltimateFontFace = var
                    ActionBar.ApplyFont()
                end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                Defaults.UltimateFontFace,
                nil,
                "name-up",
                function () return Settings.UltimateFontSize end,
                function () return Settings.UltimateFontStyle end
            ),
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_FONT_SIZE), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function () return Settings.UltimateFontSize end,
                setFunc = function (value)
                    Settings.UltimateFontSize = value
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                default = Defaults.UltimateFontSize,
            },
            SettingsAPI.CreateFontStyleDropdown(
                zo_strformat("\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
                function () return Settings.UltimateFontStyle end,
                function (var)
                    Settings.UltimateFontStyle = var
                    ActionBar.ApplyFont()
                end,
                function () return Settings.UltimateFontFace end,
                function () return Settings.UltimateFontSize end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                Defaults.UltimateFontStyle
            ),
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_ULTIMATE_HIDEFULL), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_ULTIMATE_HIDEFULL_TP),
                getFunc = function () return Settings.UltimateHideFull end,
                setFunc = function (value)
                    Settings.UltimateHideFull = value
                    ActionBar.UpdateUltimateLabel()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                default = Defaults.UltimateHideFull,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_ULTIMATE_TEXTURE),
                tooltip = GetString(LUIE_STRING_LAM_AB_ULTIMATE_TEXTURE_TP),
                getFunc = function () return Settings.UltimateGeneration end,
                setFunc = function (value) Settings.UltimateGeneration = value end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.UltimateGeneration,
            },
        },
    }

    -- Action Bar - Companion Ultimate Options Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_AB_HEADER_COMPANION_ULTIMATE),
        controls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_AB_COMPANION_NOTE),
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_COMPANION_SHOW_VAL),
                tooltip = GetString(LUIE_STRING_LAM_AB_COMPANION_SHOW_VAL_TP),
                getFunc = function () return Settings.CompanionUltimateLabelEnabled end,
                setFunc = function (value)
                    Settings.CompanionUltimateLabelEnabled = value
                    ActionBar.RegisterEvents()
                    ActionBar.UpdateCompanionUltimateLabel()
                    ActionBar.RefreshCompanionQuickslotAnchors()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.CompanionUltimateLabelEnabled,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_COMPANION_SHOW_PCT),
                tooltip = GetString(LUIE_STRING_LAM_AB_COMPANION_SHOW_PCT_TP),
                getFunc = function () return Settings.CompanionUltimatePctEnabled end,
                setFunc = function (value)
                    Settings.CompanionUltimatePctEnabled = value
                    ActionBar.RegisterEvents()
                    ActionBar.UpdateCompanionUltimateLabel()
                    ActionBar.RefreshCompanionQuickslotAnchors()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.CompanionUltimatePctEnabled,
            },
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_SHARED_POSITION), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
                min = -72,
                max = 40,
                step = 2,
                getFunc = function () return Settings.CompanionUltimateLabelPosition end,
                setFunc = function (value)
                    Settings.CompanionUltimateLabelPosition = value
                    ActionBar.ResetCompanionUltimateLabel()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end,
                default = Defaults.CompanionUltimateLabelPosition,
            },
            SettingsAPI.CreateFontDropdown(
                AddIndent(GetString(LUIE_STRING_LAM_FONT), 1),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                function () return Settings.CompanionUltimateFontFace end,
                function (var)
                    Settings.CompanionUltimateFontFace = var
                    ActionBar.ApplyFont()
                end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end,
                Defaults.CompanionUltimateFontFace,
                nil,
                "name-up",
                function () return Settings.CompanionUltimateFontSize end,
                function () return Settings.CompanionUltimateFontStyle end
            ),
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_FONT_SIZE), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function () return Settings.CompanionUltimateFontSize end,
                setFunc = function (value)
                    Settings.CompanionUltimateFontSize = value
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end,
                default = Defaults.CompanionUltimateFontSize,
            },
            SettingsAPI.CreateFontStyleDropdown(
                zo_strformat("\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
                function () return Settings.CompanionUltimateFontStyle end,
                function (var)
                    Settings.CompanionUltimateFontStyle = var
                    ActionBar.ApplyFont()
                end,
                function () return Settings.CompanionUltimateFontFace end,
                function () return Settings.CompanionUltimateFontSize end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end,
                Defaults.CompanionUltimateFontStyle
            ),
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_COMPANION_HIDEFULL), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_COMPANION_HIDEFULL_TP),
                getFunc = function () return Settings.CompanionUltimateHideFull end,
                setFunc = function (value)
                    Settings.CompanionUltimateHideFull = value
                    ActionBar.UpdateCompanionUltimateLabel()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CompanionUltimatePctEnabled) end,
                default = Defaults.CompanionUltimateHideFull,
            },
        },
    }

    -- Action Bar - Bar Ability Highlight Options Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_AB_HEADER_BAR),
        controls =
        {
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_BAR_PROC),
                tooltip = GetString(LUIE_STRING_LAM_AB_BAR_PROC_TP),
                getFunc = function () return Settings.ShowTriggered end,
                setFunc = function (value)
                    Settings.ShowTriggered = value
                    ActionBar.UpdateBarHighlightTables()
                    ActionBar.OnSlotsFullUpdate()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.ShowTriggered,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND_TP),
                getFunc = function () return Settings.ProcEnableSound end,
                setFunc = function (value) Settings.ProcEnableSound = value end,
                width = "half",
                disabled = function () return not (Settings.ShowTriggered and LUIE.SV.ActionBar_Enabled) end,
                default = Defaults.ProcEnableSound,
            },
            {
                type = "dropdown",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUNDCHOICE), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUNDCHOICE_TP),
                choices = GetSoundsList(),
                getFunc = function () return Settings.ProcSoundName end,
                setFunc = function (value)
                    Settings.ProcSoundName = value
                    ActionBar.ApplyProcSound(true)
                end,
                width = "half",
                disabled = function () return not (Settings.ShowTriggered and Settings.ProcEnableSound and LUIE.SV.ActionBar_Enabled) end,
                default = Defaults.ProcSoundName,
                sort = "name-up",
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_BAR_EFFECT),
                tooltip = GetString(LUIE_STRING_LAM_AB_BAR_EFFECT_TP),
                getFunc = function () return Settings.ShowToggled end,
                setFunc = function (value)
                    Settings.ShowToggled = value
                    ActionBar.UpdateBarHighlightTables()
                    ActionBar.OnSlotsFullUpdate()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.ShowToggled,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_BAR_ULTIMATE), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_BAR_ULTIMATE_TP),
                getFunc = function () return Settings.ShowToggledUltimate end,
                setFunc = function (value)
                    Settings.ShowToggledUltimate = value
                    ActionBar.UpdateBarHighlightTables()
                    ActionBar.OnSlotsFullUpdate()
                end,
                width = "full",
                disabled = function () return not (Settings.ShowToggled and LUIE.SV.ActionBar_Enabled) end,
                default = Defaults.ShowToggledUltimate,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_BAR_LABEL), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_BAR_LABEL_TP),
                getFunc = function () return Settings.BarShowLabel end,
                setFunc = function (value)
                    Settings.BarShowLabel = value
                    SetAbilityBarTimersEnabled()
                    ActionBar.ResetBarLabel()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                default = Defaults.BarShowLabel,
            },
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_SHARED_POSITION), 2),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
                min = -72,
                max = 40,
                step = 2,
                getFunc = function () return Settings.BarLabelPosition end,
                setFunc = function (value)
                    Settings.BarLabelPosition = value
                    ActionBar.ResetBarLabel()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                default = Defaults.BarLabelPosition,
            },
            SettingsAPI.CreateFontDropdown(
                AddIndent(GetString(LUIE_STRING_LAM_FONT), 2),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                function () return Settings.BarFontFace end,
                function (var)
                    Settings.BarFontFace = var
                    ActionBar.ApplyFont()
                end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarFontFace,
                nil,
                "name-up",
                function () return Settings.BarFontSize end,
                function () return Settings.BarFontStyle end
            ),
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_FONT_SIZE), 2),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function () return Settings.BarFontSize end,
                setFunc = function (value)
                    Settings.BarFontSize = value
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                default = Defaults.BarFontSize,
            },
            SettingsAPI.CreateFontStyleDropdown(
                zo_strformat("\t\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
                function () return Settings.BarFontStyle end,
                function (var)
                    Settings.BarFontStyle = var
                    ActionBar.ApplyFont()
                end,
                function () return Settings.BarFontFace end,
                function () return Settings.BarFontSize end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                Defaults.BarFontStyle
            ),
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS), 2),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
                getFunc = function () return Settings.BarMillis end,
                setFunc = function (value) Settings.BarMillis = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                default = Defaults.BarMillis,
            },
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSTHRESHOLDVALUE), 3),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSTHRESHOLDVALUE_TP),
                min = 1,
                max = 30,
                step = 1,
                getFunc = function () return Settings.BarMillisThreshold end,
                setFunc = function (value)
                    Settings.BarMillisThreshold = value
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                default = Defaults.BarMillisThreshold,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD), 3),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD_TP),
                getFunc = function () return Settings.BarMillisAboveTen end,
                setFunc = function (value) Settings.BarMillisAboveTen = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                default = Defaults.BarMillisAboveTen,
            },
            {
                type = "divider",
                width = "full",
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_AB_BACKBAR_HEADER),
                width = "full",
            },
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_AB_BACKBAR_NOTE),
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_BACKBAR_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_ENABLE_TP),
                getFunc = function () return Settings.BarShowBack end,
                setFunc = function (value)
                    Settings.BarShowBack = value
                    ActionBar.OnSlotsFullUpdate()
                    Backbar.BackbarToggleSettings()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.BarShowBack,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_BACKBAR_DARK), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_DARK_TP),
                getFunc = function () return Settings.BarDarkUnused end,
                setFunc = function (value)
                    Settings.BarDarkUnused = value
                    ActionBar.OnSlotsFullUpdate()
                    Backbar.BackbarToggleSettings()
                end,
                width = "full",
                disabled = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end,
                default = Defaults.BarDarkUnused,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_BACKBAR_DESATURATE), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_DESATURATE_TP),
                getFunc = function () return Settings.BarDesaturateUnused end,
                setFunc = function (value)
                    Settings.BarDesaturateUnused = value
                    ActionBar.OnSlotsFullUpdate()
                    Backbar.BackbarToggleSettings()
                end,
                width = "full",
                disabled = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end,
                default = Defaults.BarDesaturateUnused,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_BACKBAR_HIDE_UNUSED), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_HIDE_UNUSED_TP),
                getFunc = function () return Settings.BarHideUnused end,
                setFunc = function (value)
                    Settings.BarHideUnused = value
                    ActionBar.OnSlotsFullUpdate()
                    Backbar.BackbarToggleSettings()
                end,
                width = "full",
                disabled = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end,
                default = Defaults.BarHideUnused,
            },
        },
    }

    -- Action Bar - Quickslot Cooldown Timer Option Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_AB_HEADER_POTION),
        controls =
        {
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_POTION),
                tooltip = GetString(LUIE_STRING_LAM_AB_POTION_TP),
                getFunc = function () return Settings.PotionTimerShow end,
                setFunc = function (value) Settings.PotionTimerShow = value end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.PotionTimerShow,
            },
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_SHARED_POSITION), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_POSITION_TP),
                min = -72,
                max = 40,
                step = 2,
                getFunc = function () return Settings.PotionTimerLabelPosition end,
                setFunc = function (value)
                    Settings.PotionTimerLabelPosition = value
                    ActionBar.ResetPotionTimerLabel()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                default = Defaults.PotionTimerLabelPosition,
            },
            SettingsAPI.CreateFontDropdown(
                AddIndent(GetString(LUIE_STRING_LAM_FONT), 1),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                function () return Settings.PotionTimerFontFace end,
                function (var)
                    Settings.PotionTimerFontFace = var
                    ActionBar.ApplyFont()
                end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                Defaults.PotionTimerFontFace,
                nil,
                "name-up",
                function () return Settings.PotionTimerFontSize end,
                function () return Settings.PotionTimerFontStyle end
            ),
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_FONT_SIZE), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function () return Settings.PotionTimerFontSize end,
                setFunc = function (value)
                    Settings.PotionTimerFontSize = value
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                default = Defaults.PotionTimerFontSize,
            },
            SettingsAPI.CreateFontStyleDropdown(
                zo_strformat("\t<<1>>", GetString(LUIE_STRING_LAM_FONT_STYLE)),
                GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
                function () return Settings.PotionTimerFontStyle end,
                function (var)
                    Settings.PotionTimerFontStyle = var
                    ActionBar.ApplyFont()
                end,
                function () return Settings.PotionTimerFontFace end,
                function () return Settings.PotionTimerFontSize end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                Defaults.PotionTimerFontStyle
            ),
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_POTION_COLOR), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_POTION_COLOR_TP),
                getFunc = function () return Settings.PotionTimerColor end,
                setFunc = function (value) Settings.PotionTimerColor = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                default = Defaults.PotionTimerColor,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS), 1),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
                getFunc = function () return Settings.PotionTimerMillis end,
                setFunc = function (value) Settings.PotionTimerMillis = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                default = Defaults.PotionTimerMillis,
            },
        },
    }

    -- Action Bar -- Cast Bar Option Submenu
    optionsDataActionBar[#optionsDataActionBar + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_AB_HEADER_CASTBAR),
        controls =
        {
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE_TP),
                getFunc = function () return castBarMovingEnabled end,
                setFunc = function (value)
                    castBarMovingEnabled = value
                    CastBar.SetMovingState(value)
                end,
                width = "half",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = false,
                resetFunc = CastBar.ResetCastBarPosition,
            },
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_RESETPOSITION),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_RESET_TP),
                func = CastBar.ResetCastBarPosition,
                width = "half",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_AB_CASTBAR_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_ENABLE_TP),
                getFunc = function () return Settings.CastBarEnable end,
                setFunc = function (value)
                    Settings.CastBarEnable = value
                    ActionBar.RegisterEvents()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.CastBarEnable,
            },
            {
                type = "slider",
                name = GetString(LUIE_STRING_LAM_AB_CASTBAR_SIZEW),
                min = 100,
                max = 500,
                step = 5,
                getFunc = function () return Settings.CastBarSizeW end,
                setFunc = function (value)
                    Settings.CastBarSizeW = value
                    CastBar.ResizeCastBar()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.CastBarSizeW,
            },
            {
                type = "slider",
                name = GetString(LUIE_STRING_LAM_AB_CASTBAR_SIZEH),
                min = 16,
                max = 64,
                step = 2,
                getFunc = function () return Settings.CastBarSizeH end,
                setFunc = function (value)
                    Settings.CastBarSizeH = value
                    CastBar.ResizeCastBar()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.CastBarSizeH,
            },
            {
                type = "slider",
                name = GetString(LUIE_STRING_LAM_AB_CASTBAR_ICONSIZE),
                min = 16,
                max = 64,
                step = 2,
                getFunc = function () return Settings.CastBarIconSize end,
                setFunc = function (value)
                    Settings.CastBarIconSize = value
                    CastBar.ResizeCastBar()
                end,
                width = "full",
                disabled = function () return not LUIE.SV.ActionBar_Enabled end,
                default = Defaults.CastBarIconSize,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL_TP),
                getFunc = function () return Settings.CastBarLabel end,
                setFunc = function (value)
                    Settings.CastBarLabel = value
                    ActionBar.CastBar.RefreshCastBarLabelVisibility()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = Defaults.CastBarLabel,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_TP),
                getFunc = function () return Settings.CastBarTimer end,
                setFunc = function (value) Settings.CastBarTimer = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = Defaults.CastBarTimer,
            },
            {
                type = "dropdown",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT_TP),
                choices =
                {
                    GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT_MS),
                    GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT_SEC_01),
                    GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_FORMAT_SEC_001),
                },
                choicesValues = { 1, 2, 3 },
                getFunc = function () return Settings.CastBarTimerFormat end,
                setFunc = function (value) Settings.CastBarTimerFormat = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and Settings.CastBarTimer) end,
                default = Defaults.CastBarTimerFormat,
            },
            SettingsAPI.CreateFontDropdown(
                AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE), 2),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE_TP),
                function () return Settings.CastBarFontFace end,
                function (var)
                    Settings.CastBarFontFace = var
                    ActionBar.ApplyFont()
                    CastBar.UpdateCastBar()
                end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                Defaults.CastBarFontFace,
                nil,
                "name-up",
                function () return Settings.CastBarFontSize end,
                function () return Settings.CastBarFontStyle end
            ),
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSIZE), 2),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSIZE_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function () return Settings.CastBarFontSize end,
                setFunc = function (value)
                    Settings.CastBarFontSize = value
                    ActionBar.ApplyFont()
                    CastBar.UpdateCastBar()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                default = Defaults.CastBarFontSize,
            },
            SettingsAPI.CreateFontStyleDropdown(
                zo_strformat("\t\t<<1>>", GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE)),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE_TP),
                function () return Settings.CastBarFontStyle end,
                function (var)
                    Settings.CastBarFontStyle = var
                    ActionBar.ApplyFont()
                    CastBar.UpdateCastBar()
                end,
                function () return Settings.CastBarFontFace end,
                function () return Settings.CastBarFontSize end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                Defaults.CastBarFontStyle
            ),
            SettingsAPI.CreateStatusbarTextureDropdown(
                AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE), 1),
                GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE_TP),
                function () return Settings.CastBarTexture end,
                function (value)
                    Settings.CastBarTexture = value
                    CastBar.UpdateCastBar()
                end,
                "full",
                function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                Defaults.CastBarTexture
            ),
            {
                type = "colorpicker",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1_TP),
                getFunc = function () return unpack(Settings.CastBarGradientC1) end,
                setFunc = function (r, g, b, a)
                    Settings.CastBarGradientC1 = { r, g, b, a }
                    CastBar.UpdateCastBar()
                end,
                width = "half",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = Defaults.CastBarGradientC1 and { r = Defaults.CastBarGradientC1[1], g = Defaults.CastBarGradientC1[2], b = Defaults.CastBarGradientC1[3], a = Defaults.CastBarGradientC1[4] } or nil,
            },
            {
                type = "colorpicker",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC2), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC2_TP),
                getFunc = function () return unpack(Settings.CastBarGradientC2) end,
                setFunc = function (r, g, b, a)
                    Settings.CastBarGradientC2 = { r, g, b, a }
                    CastBar.UpdateCastBar()
                end,
                width = "half",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = Defaults.CastBarGradientC2 and { r = Defaults.CastBarGradientC2[1], g = Defaults.CastBarGradientC2[2], b = Defaults.CastBarGradientC2[3], a = Defaults.CastBarGradientC2[4] } or nil,
            },
            {
                type = "colorpicker",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_ICON_FRAME_COLOR), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_ICON_FRAME_COLOR_TP),
                getFunc = function () return unpack(Settings.CastBarIconFrameColor) end,
                setFunc = function (r, g, b, a)
                    Settings.CastBarIconFrameColor = { r, g, b, a }
                    CastBar.UpdateCastBar()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = Defaults.CastBarIconFrameColor and { r = Defaults.CastBarIconFrameColor[1], g = Defaults.CastBarIconFrameColor[2], b = Defaults.CastBarIconFrameColor[3], a = Defaults.CastBarIconFrameColor[4] } or nil,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_AB_CASTBAR_FILTERS_HEADER),
                width = "full",
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS_TP),
                getFunc = function () return Settings.CastBarHeavy end,
                setFunc = function (value) Settings.CastBarHeavy = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = Defaults.CastBarHeavy,
            },
            {
                type = "checkbox",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_WEAVE_HELPER), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_WEAVE_HELPER_TP),
                getFunc = function () return Settings.CastBarWeaveHelper end,
                setFunc = function (value)
                    Settings.CastBarWeaveHelper = value
                    if ActionBar.CastBar and ActionBar.CastBar.OnWeaveHelperSettingChanged then
                        ActionBar.CastBar.OnWeaveHelperSettingChanged()
                    end
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and LUIE.OtherAddonCompatability.isLibCombatEnabled) end,
                default = Defaults.CastBarWeaveHelper,
            },
            {
                type = "slider",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_WEAVE_THRESHOLD), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_WEAVE_THRESHOLD_TP),
                min = 0,
                max = 200,
                step = 10,
                getFunc = function () return Settings.CastBarWeaveThresholdMs end,
                setFunc = function (value) Settings.CastBarWeaveThresholdMs = value end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and Settings.CastBarWeaveHelper and LUIE.OtherAddonCompatability.isLibCombatEnabled) end,
                default = Defaults.CastBarWeaveThresholdMs,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST),
                width = "full",
            },
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT),
                width = "full",
            },
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
                tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
                func = function () ZO_Dialogs_ShowDialog("LUIE_CLEAR_CASTBAR_BLACKLIST") end,
                width = "half",
            },
            {
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
                tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
                getFunc = function () end,
                setFunc = function (value)
                    ActionBar.AddToCustomList(Settings.blacklist, value)
                    LUIE_BlacklistCastbar:UpdateChoices(GenerateCustomList(Settings.blacklist))
                end,
                width = "half",
            },
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
        },
    }

    -- Register the settings panel
    LAM:RegisterAddonPanel(LUIE.name .. "ActionBarOptions", panelDataActionBar)
    LAM:RegisterOptionControls(LUIE.name .. "ActionBarOptions", optionsDataActionBar)
end
