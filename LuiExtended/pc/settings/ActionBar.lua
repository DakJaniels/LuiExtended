-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

local zo_strformat = zo_strformat
local string_format = string.format
local string_rep = string.rep
local type, pairs = type, pairs
local table_insert = table.insert

local globalMethodOptions = { "Radial", "Vertical Reveal" }
local globalMethodOptionsKeys = { ["Radial"] = 1, ["Vertical Reveal"] = 2 }

-- Helper function to get fonts list
local function GetFontsList()
    local fontsList = {}
    for font, _ in pairs(LUIE.Fonts) do
        table_insert(fontsList, font)
    end
    return fontsList
end

-- Helper function to get sounds list
local function GetSoundsList()
    local soundsList = {}
    for sound, _ in pairs(LUIE.Sounds) do
        table_insert(soundsList, sound)
    end
    return soundsList
end

-- Helper function to get statusbar textures list
local function GetStatusbarTexturesList()
    local texturesList = {}
    for texture, _ in pairs(LUIE.StatusbarTextures) do
        table_insert(texturesList, texture)
    end
    return texturesList
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
                getFunc = function () return globalMethodOptions[Settings.GlobalMethod] end,
                setFunc = function (value) Settings.GlobalMethod = globalMethodOptionsKeys[value] end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
                default = globalMethodOptions[Defaults.GlobalMethod],
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
            {
                type = "dropdown",
                name = AddIndent(GetString(LUIE_STRING_LAM_FONT), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                choices = GetFontsList(),
                getFunc = function () return Settings.UltimateFontFace end,
                setFunc = function (var)
                    Settings.UltimateFontFace = var
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
                default = Defaults.UltimateFontFace,
                sort = "name-up",
            },
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
            {
                type = "dropdown",
                name = AddIndent(GetString(LUIE_STRING_LAM_FONT), 2),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                choices = GetFontsList(),
                getFunc = function () return Settings.BarFontFace end,
                setFunc = function (var)
                    Settings.BarFontFace = var
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
                default = Defaults.BarFontFace,
                sort = "name-up",
            },
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
                    ActionBar.BackbarToggleSettings()
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
                    ActionBar.BackbarToggleSettings()
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
                    ActionBar.BackbarToggleSettings()
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
                    ActionBar.BackbarToggleSettings()
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
            {
                type = "dropdown",
                name = AddIndent(GetString(LUIE_STRING_LAM_FONT), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
                choices = GetFontsList(),
                getFunc = function () return Settings.PotionTimerFontFace end,
                setFunc = function (var)
                    Settings.PotionTimerFontFace = var
                    ActionBar.ApplyFont()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
                default = Defaults.PotionTimerFontFace,
                sort = "name-up",
            },
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
                    ActionBar.SetMovingState(value)
                end,
                width = "half",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = false,
                resetFunc = ActionBar.ResetCastBarPosition,
            },
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_RESETPOSITION),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_RESET_TP),
                func = ActionBar.ResetCastBarPosition,
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
                    ActionBar.ResizeCastBar()
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
                    ActionBar.ResizeCastBar()
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
                    ActionBar.ResizeCastBar()
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
                setFunc = function (value) Settings.CastBarLabel = value end,
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
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE), 2),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE_TP),
                choices = GetFontsList(),
                getFunc = function () return Settings.CastBarFontFace end,
                setFunc = function (var)
                    Settings.CastBarFontFace = var
                    ActionBar.ApplyFont()
                    ActionBar.UpdateCastBar()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                default = Defaults.CastBarFontFace,
                sort = "name-up",
            },
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
                    ActionBar.UpdateCastBar()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                default = Defaults.CastBarFontSize,
            },
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
                    ActionBar.UpdateCastBar()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
                default = Defaults.CastBarFontStyle,
            },
            {
                type = "dropdown",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE_TP),
                choices = GetStatusbarTexturesList(),
                getFunc = function () return Settings.CastBarTexture end,
                setFunc = function (value)
                    Settings.CastBarTexture = value
                    ActionBar.UpdateCastBar()
                end,
                width = "full",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = Defaults.CastBarTexture,
                sort = "name-up",
            },
            {
                type = "colorpicker",
                name = AddIndent(GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1), 1),
                tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1_TP),
                getFunc = function () return unpack(Settings.CastBarGradientC1) end,
                setFunc = function (r, g, b, a)
                    Settings.CastBarGradientC1 = { r, g, b, a }
                    ActionBar.UpdateCastBar()
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
                    ActionBar.UpdateCastBar()
                end,
                width = "half",
                disabled = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
                default = Defaults.CastBarGradientC2 and { r = Defaults.CastBarGradientC2[1], g = Defaults.CastBarGradientC2[2], b = Defaults.CastBarGradientC2[3], a = Defaults.CastBarGradientC2[4] } or nil,
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
    if LUIE.SV.ActionBar_Enabled then
        LAM:RegisterAddonPanel(LUIE.name .. "ActionBarOptions", panelDataActionBar)
        LAM:RegisterOptionControls(LUIE.name .. "ActionBarOptions", optionsDataActionBar)
    end
end
