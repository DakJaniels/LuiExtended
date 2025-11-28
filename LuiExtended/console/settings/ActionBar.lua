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

--- @class (partial) CastBar
local CastBar = ActionBar.CastBar

local zo_strformat = zo_strformat
local string_format = string.format
local type, pairs, ipairs = type, pairs, ipairs
local GetString = GetString
local unpack = unpack

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

local globalMethodOptions = { "Radial", "Vertical Reveal" }
local globalMethodOptionsKeys = { ["Radial"] = 1, ["Vertical Reveal"] = 2 }

local castBarMovingEnabled = false -- Helper local flag

-- Convert to LHAS format {name, data}
local function GenerateCustomListLHAS(input)
    local items = {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        local displayName
        if type(id) == "number" then
            displayName = zo_iconTextFormat(GetAbilityIcon(id), 16, 16, " [" .. id .. "] " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id)), true, true)
        else
            displayName = id
        end
        items[counter] = { name = displayName, data = id }
    end
    return items
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
            -- Refresh settings panel if needed
            if LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
        end,
    },
}

local function loadDialogButtons()
    for i = 1, #dialogs do
        local dialog = dialogs[i]
        LUIE.RegisterDialogueButton(dialog.identifier, dialog.title, dialog.text, dialog.callback)
    end
end

function ActionBar.CreateConsoleSettings()
    local Defaults = ActionBar.Defaults
    local Settings = ActionBar.SV

    -- Register the settings panel
    if not LUIE.SV.ActionBar_Enabled then
        return
    end

    -- Load Dialog Buttons
    loadDialogButtons()

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

    -- Register duration override management dialog
    -- Dialog for managing duration overrides (remove/clear)
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_DURATION_OVERRIDES",
        "Duration Overrides",
        function ()
            return GenerateCustomListLHAS(Settings.durationOverrides)
        end,
        function (itemData)
            ActionBar.RemoveDurationOverride(itemData)
            -- Refresh the dialog
            LUIE.RefreshBlacklistDialog("LUIE_MANAGE_DURATION_OVERRIDES")
        end,
        nil, -- No add callback for this dialog
        function ()
            ActionBar.ClearDurationOverrides()
        end
    )

    -- Store state for add override dialog in Settings (persists between dialog opens)
    if not Settings.selectedAbilityForDurationOverride then
        Settings.selectedAbilityForDurationOverride = 0
    end
    if not Settings.tempDurationOverrideValue then
        Settings.tempDurationOverrideValue = ""
    end

    -- Dialog for adding duration overrides - create function to rebuild dialog with fresh state
    local function CreateAddOverrideDialog()
        local dialog = LibConsoleDialogs:Create("Add Duration Override")

        -- Ability selection dropdown
        dialog:AddSetting(
            {
                type = LHAS.ST_DROPDOWN,
                label = "Select Ability",
                tooltip = "Select an ability from your currently tracked abilities to override its duration",
                items = function ()
                    local choices, choicesValues = ActionBar.GetTrackedAbilitiesForOverride()
                    local items = {}
                    for i, choice in ipairs(choices) do
                        items[i] = { name = choice, data = choicesValues[i] }
                    end
                    return items
                end,
                getFunction = function ()
                    local selectedAbilityId = Settings.selectedAbilityForDurationOverride or 0
                    if selectedAbilityId == 0 then
                        return nil
                    end
                    -- Find the matching item name for the selected ability ID
                    local choices, choicesValues = ActionBar.GetTrackedAbilitiesForOverride()
                    for i, abilityId in ipairs(choicesValues) do
                        if abilityId == selectedAbilityId then
                            return choices[i]
                        end
                    end
                    return nil
                end,
                setFunction = function (combobox, value, item)
                    if item and item.data then
                        Settings.selectedAbilityForDurationOverride = item.data
                        -- Update duration field to show current duration
                        if Settings.durationOverrides[item.data] then
                            Settings.tempDurationOverrideValue = tostring(Settings.durationOverrides[item.data])
                        else
                            local duration = GetAbilityDuration(item.data)
                            Settings.tempDurationOverrideValue = duration > 0 and tostring(duration) or ""
                        end
                        -- Refresh the dialog to update the duration field
                        LibConsoleDialogs:Close()
                        zo_callLater(function ()
                                         -- Recreate and show dialog with updated values
                                         local newDialog = CreateAddOverrideDialog()
                                         if not LUIE.DurationOverrideDialogs then
                                             LUIE.DurationOverrideDialogs = {}
                                         end
                                         LUIE.DurationOverrideDialogs["LUIE_ADD_DURATION_OVERRIDE"] = newDialog
                                         newDialog:Show()
                                     end, 100)
                    end
                end,
            })

        -- Duration input field
        dialog:AddSetting(
            {
                type = LHAS.ST_EDIT,
                label = "Duration (milliseconds)",
                tooltip = "Set the duration for the selected ability in milliseconds\nExample: 15000 for 15 seconds",
                default = "",
                setFunction = function (value)
                    Settings.tempDurationOverrideValue = value
                end,
                getFunction = function ()
                    return Settings.tempDurationOverrideValue or ""
                end,
                disable = function ()
                    return (Settings.selectedAbilityForDurationOverride or 0) == 0
                end,
            })

        -- Apply button
        dialog:AddSetting(
            {
                type = LHAS.ST_BUTTON,
                label = "Apply Override",
                tooltip = "Apply the duration override for the selected ability",
                buttonText = "Apply",
                clickHandler = function (control, button)
                    local abilityId = Settings.selectedAbilityForDurationOverride or 0
                    if abilityId == 0 then
                        LUIE.PrintToChat("ActionBar: Please select an ability first", true)
                        return
                    end

                    local duration = tonumber(Settings.tempDurationOverrideValue or "")
                    if not duration or duration <= 0 then
                        LUIE.PrintToChat("ActionBar: Invalid duration. Must be a positive number", true)
                        return
                    end

                    -- Add the override
                    ActionBar.AddDurationOverride(string_format("%d %d", abilityId, duration))

                    -- Reset values
                    Settings.selectedAbilityForDurationOverride = 0
                    Settings.tempDurationOverrideValue = ""

                    -- Close dialog
                    LibConsoleDialogs:Close()
                end,
                disable = function ()
                    return (Settings.selectedAbilityForDurationOverride or 0) == 0
                end,
            })

        return dialog
    end

    -- Create initial dialog
    local addOverrideDialog = CreateAddOverrideDialog()

    -- Store dialog reference
    if not LUIE.DurationOverrideDialogs then
        LUIE.DurationOverrideDialogs = {}
    end
    LUIE.DurationOverrideDialogs["LUIE_ADD_DURATION_OVERRIDE"] = addOverrideDialog

    -- Sync castBarMovingEnabled with ActionBar.CastBarUnlocked
    castBarMovingEnabled = ActionBar.CastBarUnlocked or false

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_AB)),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset to defaults if needed
                                    end,
                                    allowRefresh = true
                                })

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
            ReloadUI("ingame")
        end
    }

    -- Initialize all settings and menu buttons for submenus
    local backButton = nil
    local menuButtons = {}
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
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_GCD),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure global cooldown (GCD) display options including visual effects, animations, and color settings.",
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
            label = "  " .. GetString(LUIE_STRING_LAM_AB_GCD_QUICK),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_QUICK_TP),
            getFunction = function () return Settings.GlobalPotion end,
            setFunction = function (value) Settings.GlobalPotion = value end,
            default = Defaults.GlobalPotion,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_GCD_FLASH),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_FLASH_TP),
            getFunction = function () return Settings.GlobalFlash end,
            setFunction = function (value) Settings.GlobalFlash = value end,
            default = Defaults.GlobalFlash,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_GCD_DESAT),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_DESAT_TP),
            getFunction = function () return Settings.GlobalDesat end,
            setFunction = function (value) Settings.GlobalDesat = value end,
            default = Defaults.GlobalDesat,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_GCD_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_COLOR_TP),
            getFunction = function () return Settings.GlobalLabelColor end,
            setFunction = function (value) Settings.GlobalLabelColor = value end,
            default = Defaults.GlobalLabelColor,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION),
            tooltip = GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION_TP),
            items = SettingsAPI:GetGlobalMethodOptionsList(),
            getFunction = function ()
                local index = Settings.GlobalMethod
                if type(index) == "string" then
                    index = globalMethodOptionsKeys[index] or 1
                end
                return globalMethodOptions[index] or globalMethodOptions[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.GlobalMethod = item.data
            end,
            default = globalMethodOptions[Defaults.GlobalMethod],
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end
        }
    end)

    -- Build Ultimate Tracking Options Section
    buildSectionSettings("UltimateTracking", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_ULTIMATE),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure ultimate ability tracking display including value, percentage, font settings, and visual indicators.",
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
            label = "  " .. GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
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
            label = "  " .. GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
            items = fontItems,
            getFunction = function () return Settings.UltimateFontFace end,
            setFunction = function (combobox, value, item)
                Settings.UltimateFontFace = item.data
                ActionBar.ApplyFont()
            end,
            default = Defaults.UltimateFontFace,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "  " .. GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.UltimateFontSize end,
            setFunction = function (value)
                Settings.UltimateFontSize = value
                ActionBar.ApplyFont()
            end,
            default = Defaults.UltimateFontSize,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  " .. GetString(LUIE_STRING_LAM_FONT_STYLE),
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
                ActionBar.ApplyFont()
            end,
            default = Defaults.UltimateFontStyle,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_ULTIMATE_HIDEFULL),
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

    -- Build Bar Ability Highlight Options Section
    buildSectionSettings("BarAbilityHighlight", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_BAR),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure ability highlight options including proc effects, toggled abilities, labels, colors, and backbar display settings.",
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
            label = "  " .. GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND),
            tooltip = GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND_TP),
            getFunction = function () return Settings.ProcEnableSound end,
            setFunction = function (value) Settings.ProcEnableSound = value end,
            default = Defaults.ProcEnableSound,
            disable = function () return not (Settings.ShowTriggered and LUIE.SV.ActionBar_Enabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUNDCHOICE),
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
            label = "  " .. GetString(LUIE_STRING_LAM_AB_BAR_ULTIMATE),
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
            label = "  " .. GetString(LUIE_STRING_LAM_AB_BAR_LABEL),
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
            label = "    " .. GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
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
            label = "    " .. GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
            items = fontItems,
            getFunction = function () return Settings.BarFontFace end,
            setFunction = function (combobox, value, item)
                Settings.BarFontFace = item.data
                ActionBar.ApplyFont()
            end,
            default = Defaults.BarFontFace,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "    " .. GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.BarFontSize end,
            setFunction = function (value)
                Settings.BarFontSize = value
                ActionBar.ApplyFont()
            end,
            default = Defaults.BarFontSize,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "    " .. GetString(LUIE_STRING_LAM_FONT_STYLE),
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
                ActionBar.ApplyFont()
            end,
            default = Defaults.BarFontStyle,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "    " .. GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
            getFunction = function () return Settings.BarMillis end,
            setFunction = function (value) Settings.BarMillis = value end,
            default = Defaults.BarMillis,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "      " .. GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSTHRESHOLDVALUE),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSTHRESHOLDVALUE_TP),
            min = 1,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.BarMillisThreshold end,
            setFunction = function (value)
                Settings.BarMillisThreshold = value
                ActionBar.ApplyFont()
            end,
            default = Defaults.BarMillisThreshold,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "      " .. GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD_TP),
            getFunction = function () return Settings.BarMillisAboveTen end,
            setFunction = function (value) Settings.BarMillisAboveTen = value end,
            default = Defaults.BarMillisAboveTen,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "    Colored Remaining Text",
            tooltip = "Enable colored text for remaining duration labels on ability highlights",
            getFunction = function () return Settings.RemainingTextColoured end,
            setFunction = function (value)
                Settings.RemainingTextColoured = value
            end,
            default = Defaults.RemainingTextColoured,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "      Remaining Text Color (High)",
            tooltip = "Color when duration is above mid threshold (high time remaining)",
            getFunction = function () return Settings.RemainingTextColorHigh[1], Settings.RemainingTextColorHigh[2], Settings.RemainingTextColorHigh[3], Settings.RemainingTextColorHigh[4] end,
            setFunction = function (r, g, b, a)
                Settings.RemainingTextColorHigh = { r, g, b, a }
            end,
            default = Defaults.RemainingTextColorHigh,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "      Remaining Text Color (Mid)",
            tooltip = "Color when duration is between low and mid thresholds",
            getFunction = function () return Settings.RemainingTextColorMid[1], Settings.RemainingTextColorMid[2], Settings.RemainingTextColorMid[3], Settings.RemainingTextColorMid[4] end,
            setFunction = function (r, g, b, a)
                Settings.RemainingTextColorMid = { r, g, b, a }
            end,
            default = Defaults.RemainingTextColorMid,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "      Remaining Text Color (Low)",
            tooltip = "Color when duration is below low threshold (low time remaining)",
            getFunction = function () return Settings.RemainingTextColorLow[1], Settings.RemainingTextColorLow[2], Settings.RemainingTextColorLow[3], Settings.RemainingTextColorLow[4] end,
            setFunction = function (r, g, b, a)
                Settings.RemainingTextColorLow = { r, g, b, a }
            end,
            default = Defaults.RemainingTextColorLow,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "      Mid Threshold (%)",
            tooltip = "Percentage of duration remaining to switch from high to mid color (0.0-1.0)",
            min = 0,
            max = 100,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.RemainingTextColorThresholdMid * 100 end,
            setFunction = function (value)
                Settings.RemainingTextColorThresholdMid = value / 100
            end,
            default = Defaults.RemainingTextColorThresholdMid * 100,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "      Low Threshold (%)",
            tooltip = "Percentage of duration remaining to switch from mid to low color (0.0-1.0)",
            min = 0,
            max = 100,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.RemainingTextColorThresholdLow * 100 end,
            setFunction = function (value)
                Settings.RemainingTextColorThresholdLow = value / 100
            end,
            default = Defaults.RemainingTextColorThresholdLow * 100,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.RemainingTextColoured and (Settings.ShowTriggered or Settings.ShowToggled)) end
        }

        -- Backbar subsection
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
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
                ActionBar.BackbarToggleSettings()
            end,
            default = Defaults.BarShowBack,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_BACKBAR_DARK),
            tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_DARK_TP),
            getFunction = function () return Settings.BarDarkUnused end,
            setFunction = function (value)
                Settings.BarDarkUnused = value
                ActionBar.OnSlotsFullUpdate()
                ActionBar.BackbarToggleSettings()
            end,
            default = Defaults.BarDarkUnused,
            disable = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_BACKBAR_DESATURATE),
            tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_DESATURATE_TP),
            getFunction = function () return Settings.BarDesaturateUnused end,
            setFunction = function (value)
                Settings.BarDesaturateUnused = value
                ActionBar.OnSlotsFullUpdate()
                ActionBar.BackbarToggleSettings()
            end,
            default = Defaults.BarDesaturateUnused,
            disable = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_BACKBAR_HIDE_UNUSED),
            tooltip = GetString(LUIE_STRING_LAM_AB_BACKBAR_HIDE_UNUSED_TP),
            getFunction = function () return Settings.BarHideUnused end,
            setFunction = function (value)
                Settings.BarHideUnused = value
                ActionBar.OnSlotsFullUpdate()
                ActionBar.BackbarToggleSettings()
            end,
            default = Defaults.BarHideUnused,
            disable = function () return not (Settings.BarShowBack and LUIE.SV.ActionBar_Enabled) end
        }
    end)

    -- Build Quickslot Cooldown Timer Option Section
    buildSectionSettings("QuickslotCooldown", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_POTION),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure quickslot (potion) cooldown timer display including position, font settings, color thresholds, and millisecond display options.",
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
            label = "  " .. GetString(LUIE_STRING_LAM_AB_SHARED_POSITION),
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
            label = "  " .. GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONT_TP),
            items = fontItems,
            getFunction = function () return Settings.PotionTimerFontFace end,
            setFunction = function (combobox, value, item)
                Settings.PotionTimerFontFace = item.data
                ActionBar.ApplyFont()
            end,
            default = Defaults.PotionTimerFontFace,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "  " .. GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHARED_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.PotionTimerFontSize end,
            setFunction = function (value)
                Settings.PotionTimerFontSize = value
                ActionBar.ApplyFont()
            end,
            default = Defaults.PotionTimerFontSize,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  " .. GetString(LUIE_STRING_LAM_FONT_STYLE),
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
                ActionBar.ApplyFont()
            end,
            default = Defaults.PotionTimerFontStyle,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_POTION_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_AB_POTION_COLOR_TP),
            getFunction = function () return Settings.PotionTimerColor end,
            setFunction = function (value) Settings.PotionTimerColor = value end,
            default = Defaults.PotionTimerColor,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Quickslot Timer Color (High)",
            tooltip = "Color when remaining time is above mid threshold",
            getFunction = function () return Settings.PotionTimerTextColorHigh[1], Settings.PotionTimerTextColorHigh[2], Settings.PotionTimerTextColorHigh[3], Settings.PotionTimerTextColorHigh[4] end,
            setFunction = function (r, g, b, a)
                Settings.PotionTimerTextColorHigh = { r, g, b, a }
            end,
            default = Defaults.PotionTimerTextColorHigh,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Quickslot Timer Color (Mid)",
            tooltip = "Color when remaining time is between low and mid thresholds",
            getFunction = function () return Settings.PotionTimerTextColorMid[1], Settings.PotionTimerTextColorMid[2], Settings.PotionTimerTextColorMid[3], Settings.PotionTimerTextColorMid[4] end,
            setFunction = function (r, g, b, a)
                Settings.PotionTimerTextColorMid = { r, g, b, a }
            end,
            default = Defaults.PotionTimerTextColorMid,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Quickslot Timer Color (Low)",
            tooltip = "Color when remaining time is below low threshold",
            getFunction = function () return Settings.PotionTimerTextColorLow[1], Settings.PotionTimerTextColorLow[2], Settings.PotionTimerTextColorLow[3], Settings.PotionTimerTextColorLow[4] end,
            setFunction = function (r, g, b, a)
                Settings.PotionTimerTextColorLow = { r, g, b, a }
            end,
            default = Defaults.PotionTimerTextColorLow,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "    Mid Threshold (ms)",
            tooltip = "Remaining time in milliseconds to switch from high to mid color",
            min = 1000,
            max = 60000,
            step = 1000,
            format = "%.0f",
            getFunction = function () return Settings.PotionTimerTextColorThresholdMid end,
            setFunction = function (value)
                Settings.PotionTimerTextColorThresholdMid = value
            end,
            default = Defaults.PotionTimerTextColorThresholdMid,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "    Low Threshold (ms)",
            tooltip = "Remaining time in milliseconds to switch from mid to low color",
            min = 500,
            max = 30000,
            step = 500,
            format = "%.0f",
            getFunction = function () return Settings.PotionTimerTextColorThresholdLow end,
            setFunction = function (value)
                Settings.PotionTimerTextColorThresholdLow = value
            end,
            default = Defaults.PotionTimerTextColorThresholdLow,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow and Settings.PotionTimerColor) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
            getFunction = function () return Settings.PotionTimerMillis end,
            setFunction = function (value) Settings.PotionTimerMillis = value end,
            default = Defaults.PotionTimerMillis,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end
        }
    end)

    -- Build Cast Bar Option Section
    buildSectionSettings("CastBar", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_AB_HEADER_CASTBAR),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure cast bar display including size, position, fonts, textures, colors, filters, and blacklist management.",
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE_TP),
            getFunction = function () return castBarMovingEnabled end,
            setFunction = function (value)
                castBarMovingEnabled = value
                CastBar.SetMovingState(value)
            end,
            default = false,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_RESET_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = CastBar.ResetCastBarPosition,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
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
            end,
            default = Defaults.CastBarEnable,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
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
            disable = function () return not LUIE.SV.ActionBar_Enabled end
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
            disable = function () return not LUIE.SV.ActionBar_Enabled end
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
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL_TP),
            getFunction = function () return Settings.CastBarLabel end,
            setFunction = function (value) Settings.CastBarLabel = value end,
            default = Defaults.CastBarLabel,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_TP),
            getFunction = function () return Settings.CastBarTimer end,
            setFunction = function (value) Settings.CastBarTimer = value end,
            default = Defaults.CastBarTimer,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "    " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTFACE_TP),
            items = fontItems,
            getFunction = function () return Settings.CastBarFontFace end,
            setFunction = function (combobox, value, item)
                Settings.CastBarFontFace = item.data
                ActionBar.ApplyFont()
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarFontFace,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "    " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSIZE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.CastBarFontSize end,
            setFunction = function (value)
                Settings.CastBarFontSize = value
                ActionBar.ApplyFont()
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarFontSize,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "    " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE),
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
                ActionBar.ApplyFont()
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarFontStyle,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_TEXTURE_TP),
            items = statusbarItems,
            getFunction = function () return Settings.CastBarTexture end,
            setFunction = function (combobox, value, item)
                Settings.CastBarTexture = item.data
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarTexture,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC1_TP),
            getFunction = function () return Settings.CastBarGradientC1[1], Settings.CastBarGradientC1[2], Settings.CastBarGradientC1[3], Settings.CastBarGradientC1[4] end,
            setFunction = function (r, g, b, a)
                Settings.CastBarGradientC1 = { r, g, b, a }
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarGradientC1,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC2),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_GRADIENTC2_TP),
            getFunction = function () return Settings.CastBarGradientC2[1], Settings.CastBarGradientC2[2], Settings.CastBarGradientC2[3], Settings.CastBarGradientC2[4] end,
            setFunction = function (r, g, b, a)
                Settings.CastBarGradientC2 = { r, g, b, a }
                CastBar.UpdateCastBar()
            end,
            default = Defaults.CastBarGradientC2,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
        }

        -- Filters subsection
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = GetString(LUIE_STRING_LAM_AB_CASTBAR_FILTERS_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "  " .. GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS),
            tooltip = GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS_TP),
            getFunction = function () return Settings.CastBarHeavy end,
            setFunction = function (value) Settings.CastBarHeavy = value end,
            default = Defaults.CastBarHeavy,
            disable = function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
        }

        -- Blacklist subsection
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
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
            disable = function () return not LUIE.SV.ActionBar_Enabled end
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
                    if LHAS and LHAS.RefreshAddonSettings then
                        LHAS:RefreshAddonSettings()
                    end
                end
            end,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
            buttonText = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            clickHandler = function () ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_CASTBAR_BLACKLIST") end,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
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
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }
    end)

    -- Build Duration Override Options Section
    buildSectionSettings("DurationOverride", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_SECTION,
            label = "Ability Duration Overrides",
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Override ability durations. Useful when the game API reports the wrong duration for abilities with multiple effects.",
        }

        -- Add Duration Override button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = "Add Duration Override",
            tooltip = "Add a new duration override for an ability",
            buttonText = "Add Duration Override",
            clickHandler = function ()
                if LUIE.DurationOverrideDialogs and LUIE.DurationOverrideDialogs["LUIE_ADD_DURATION_OVERRIDE"] then
                    LUIE.DurationOverrideDialogs["LUIE_ADD_DURATION_OVERRIDE"]:Show()
                end
            end,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }

        -- Manage Duration Overrides button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = "Manage Duration Overrides",
            tooltip = "View and remove existing duration overrides",
            buttonText = "Manage Duration Overrides",
            clickHandler = function ()
                if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_DURATION_OVERRIDES"] then
                    LUIE.ShowBlacklistDialog("LUIE_MANAGE_DURATION_OVERRIDES")
                end
            end,
            disable = function () return not LUIE.SV.ActionBar_Enabled end
        }
    end)

    -- Create back button
    backButton =
    {
        type = LHAS.ST_BUTTON,
        label = "BACK",
        buttonText = "BACK",
        tooltip = "",
        clickHandler = function (control)
            panel:RemoveAllSettings()
            local mainMenuSettings = {}
            for i = 1, #initialSettings do
                mainMenuSettings[i] = initialSettings[i]
            end
            for i = 1, #menuButtons do
                mainMenuSettings[#mainMenuSettings + 1] = menuButtons[i]
            end
            panel:AddSettings(mainMenuSettings)
            if IsConsoleUI() then
                LibHarvensAddonSettings.list:SetSelectedIndexWithoutAnimation(1)
            end
        end
    }

    -- Create menu buttons for each section
    local function createMenuButton(sectionName, sectionLabel, sectionSettings)
        return
        {
            type = LHAS.ST_BUTTON,
            label = sectionLabel,
            buttonText = sectionLabel,
            tooltip = "",
            clickHandler = function (control)
                panel:RemoveAllSettings()
                local settingsWithBack = {}
                for i = 1, #sectionSettings do
                    settingsWithBack[i] = sectionSettings[i]
                end
                settingsWithBack[#settingsWithBack + 1] = backButton
                panel:AddSettings(settingsWithBack)
                if IsConsoleUI() then
                    LibHarvensAddonSettings.list:SetSelectedIndexWithoutAnimation(2)
                end
            end
        }
    end

    -- Add all submenu buttons
    menuButtons[#menuButtons + 1] = createMenuButton("GlobalCooldown", GetString(LUIE_STRING_LAM_AB_HEADER_GCD), sectionGroups["GlobalCooldown"])
    menuButtons[#menuButtons + 1] = createMenuButton("UltimateTracking", GetString(LUIE_STRING_LAM_AB_HEADER_ULTIMATE), sectionGroups["UltimateTracking"])
    menuButtons[#menuButtons + 1] = createMenuButton("BarAbilityHighlight", GetString(LUIE_STRING_LAM_AB_HEADER_BAR), sectionGroups["BarAbilityHighlight"])
    menuButtons[#menuButtons + 1] = createMenuButton("QuickslotCooldown", GetString(LUIE_STRING_LAM_AB_HEADER_POTION), sectionGroups["QuickslotCooldown"])
    menuButtons[#menuButtons + 1] = createMenuButton("CastBar", GetString(LUIE_STRING_LAM_AB_HEADER_CASTBAR), sectionGroups["CastBar"])
    menuButtons[#menuButtons + 1] = createMenuButton("DurationOverride", "Ability Duration Overrides", sectionGroups["DurationOverride"])

    -- Initialize main menu with initial settings and menu buttons
    local mainMenuSettings = {}
    for i = 1, #initialSettings do
        mainMenuSettings[i] = initialSettings[i]
    end
    for i = 1, #menuButtons do
        mainMenuSettings[#mainMenuSettings + 1] = menuButtons[i]
    end
    panel:AddSettings(mainMenuSettings)
end
