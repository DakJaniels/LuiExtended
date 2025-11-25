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
local type, pairs = type, pairs

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

    local settingsData = {}

    -- Action Bar Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_AB_DESCRIPTION)
    )

    -- ReloadUI Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function ()
            ReloadUI("ingame")
        end
    )

    -- Action Bar - Global Cooldown Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_GCD)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_AB_GCD_SHOW),
        GetString(LUIE_STRING_LAM_AB_GCD_SHOW_TP),
        function () return Settings.GlobalShowGCD end,
        function (value)
            Settings.GlobalShowGCD = value
            ActionBar.HookGCD()
        end,
        "full",
        function () return not LUIE.SV.ActionBar_Enabled end,
        Defaults.GlobalShowGCD
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_GCD_QUICK),
        GetString(LUIE_STRING_LAM_AB_GCD_QUICK_TP),
        function () return Settings.GlobalPotion end,
        function (value) Settings.GlobalPotion = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
        Defaults.GlobalPotion
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_GCD_FLASH),
        GetString(LUIE_STRING_LAM_AB_GCD_FLASH_TP),
        function () return Settings.GlobalFlash end,
        function (value) Settings.GlobalFlash = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
        Defaults.GlobalFlash
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_GCD_DESAT),
        GetString(LUIE_STRING_LAM_AB_GCD_DESAT_TP),
        function () return Settings.GlobalDesat end,
        function (value) Settings.GlobalDesat = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
        Defaults.GlobalDesat
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_GCD_COLOR),
        GetString(LUIE_STRING_LAM_AB_GCD_COLOR_TP),
        function () return Settings.GlobalLabelColor end,
        function (value) Settings.GlobalLabelColor = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
        Defaults.GlobalLabelColor
    )

    -- Animation dropdown - convert to use keys mapping
    local globalMethodItems = {}
    for i, option in ipairs(globalMethodOptions) do
        globalMethodItems[i] = { name = option, data = option }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION),
        GetString(LUIE_STRING_LAM_AB_GCD_ANIMATION_TP),
        globalMethodItems,
        function () return globalMethodOptions[Settings.GlobalMethod] end,
        function (combobox, value, item)
            Settings.GlobalMethod = globalMethodOptionsKeys[value]
        end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.GlobalShowGCD) end,
        globalMethodOptions[Defaults.GlobalMethod]
    )

    -- Action Bar - Ultimate Tracking Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_ULTIMATE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
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
        Defaults.UltimateFontFace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_FONT_STYLE),
        GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
        function () return Settings.UltimateFontStyle end,
        function (var)
            Settings.UltimateFontStyle = var
            ActionBar.ApplyFont()
        end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.UltimatePctEnabled) end,
        Defaults.UltimateFontStyle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_AB_ULTIMATE_TEXTURE),
        GetString(LUIE_STRING_LAM_AB_ULTIMATE_TEXTURE_TP),
        function () return Settings.UltimateGeneration end,
        function (value) Settings.UltimateGeneration = value end,
        "full",
        function () return not LUIE.SV.ActionBar_Enabled end,
        Defaults.UltimateGeneration
    )

    -- Action Bar - Bar Ability Highlight Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_BAR)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND),
        GetString(LUIE_STRING_LAM_AB_BAR_PROCSOUND_TP),
        function () return Settings.ProcEnableSound end,
        function (value) Settings.ProcEnableSound = value end,
        1,
        "half",
        function () return not (Settings.ShowTriggered and LUIE.SV.ActionBar_Enabled) end,
        Defaults.ProcEnableSound
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
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
        Defaults.ProcSoundName
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_BAR_LABEL),
        GetString(LUIE_STRING_LAM_AB_BAR_LABEL_TP),
        function () return Settings.BarShowLabel end,
        function (value)
            Settings.BarShowLabel = value
            ActionBar.ResetBarLabel()
        end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and (Settings.ShowTriggered or Settings.ShowToggled)) end,
        Defaults.BarShowLabel
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
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
        Defaults.BarFontFace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_FONT_STYLE),
        GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
        function () return Settings.BarFontStyle end,
        function (var)
            Settings.BarFontStyle = var
            ActionBar.ApplyFont()
        end,
        2,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
        Defaults.BarFontStyle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
        GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
        function () return Settings.BarMillis end,
        function (value) Settings.BarMillis = value end,
        2,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and (Settings.ShowTriggered or Settings.ShowToggled)) end,
        Defaults.BarMillis
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD),
        GetString(LUIE_STRING_LAM_BUFF_SHOWFRACTIONSABOVETHRESHOLD_TP),
        function () return Settings.BarMillisAboveTen end,
        function (value) Settings.BarMillisAboveTen = value end,
        3,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.BarShowLabel and Settings.BarMillis and (Settings.ShowTriggered or Settings.ShowToggled)) end,
        Defaults.BarMillisAboveTen
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDividerOption("full")
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(GetString(LUIE_STRING_LAM_AB_BACKBAR_HEADER))
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(GetString(LUIE_STRING_LAM_AB_BACKBAR_NOTE))

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
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
    )

    -- Action Bar - Quickslot Cooldown Timer Option Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_POTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_AB_POTION),
        GetString(LUIE_STRING_LAM_AB_POTION_TP),
        function () return Settings.PotionTimerShow end,
        function (value) Settings.PotionTimerShow = value end,
        "full",
        function () return not LUIE.SV.ActionBar_Enabled end,
        Defaults.PotionTimerShow
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
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
        Defaults.PotionTimerFontFace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_FONT_STYLE),
        GetString(LUIE_STRING_LAM_AB_SHARED_FONTSTYLE_TP),
        function () return Settings.PotionTimerFontStyle end,
        function (var)
            Settings.PotionTimerFontStyle = var
            ActionBar.ApplyFont()
        end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
        Defaults.PotionTimerFontStyle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_POTION_COLOR),
        GetString(LUIE_STRING_LAM_AB_POTION_COLOR_TP),
        function () return Settings.PotionTimerColor end,
        function (value) Settings.PotionTimerColor = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
        Defaults.PotionTimerColor
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS),
        GetString(LUIE_STRING_LAM_BUFF_SHOWSECONDFRACTIONS_TP),
        function () return Settings.PotionTimerMillis end,
        function (value) Settings.PotionTimerMillis = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.PotionTimerShow) end,
        Defaults.PotionTimerMillis
    )

    -- Action Bar -- Cast Bar Option Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_AB_HEADER_CASTBAR)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE),
        GetString(LUIE_STRING_LAM_AB_CASTBAR_MOVE_TP),
        function () return castBarMovingEnabled end,
        function (value)
            castBarMovingEnabled = value
            CastBar.SetMovingState(value)
        end,
        "half",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
        false
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RESETPOSITION),
        GetString(LUIE_STRING_LAM_AB_CASTBAR_RESET_TP),
        CastBar.ResetCastBarPosition,
        "half",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL),
        GetString(LUIE_STRING_LAM_AB_CASTBAR_LABEL_TP),
        function () return Settings.CastBarLabel end,
        function (value) Settings.CastBarLabel = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
        Defaults.CastBarLabel
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER),
        GetString(LUIE_STRING_LAM_AB_CASTBAR_TIMER_TP),
        function () return Settings.CastBarTimer end,
        function (value) Settings.CastBarTimer = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
        Defaults.CastBarTimer
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
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
        Defaults.CastBarFontFace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE),
        GetString(LUIE_STRING_LAM_AB_CASTBAR_FONTSTYLE_TP),
        function () return Settings.CastBarFontStyle end,
        function (var)
            Settings.CastBarFontStyle = var
            ActionBar.ApplyFont()
            CastBar.UpdateCastBar()
        end,
        2,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable and (Settings.CastBarTimer or Settings.CastBarLabel)) end,
        Defaults.CastBarFontStyle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
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
        Defaults.CastBarTexture
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
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
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(GetString(LUIE_STRING_LAM_AB_CASTBAR_FILTERS_HEADER))

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS),
        GetString(LUIE_STRING_LAM_AB_CASTBAR_HEAVY_ATTACKS_TP),
        function () return Settings.CastBarHeavy end,
        function (value) Settings.CastBarHeavy = value end,
        1,
        "full",
        function () return not (LUIE.SV.ActionBar_Enabled and Settings.CastBarEnable) end,
        Defaults.CastBarHeavy
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST))
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT))

    -- Store temp text for adding items
    if not Settings.tempBlacklistText then
        Settings.tempBlacklistText = ""
    end

    -- Add Item edit box
    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
        function ()
            return Settings.tempBlacklistText or ""
        end,
        function (value)
            Settings.tempBlacklistText = value
        end,
        nil,
        "full",
        function () return not LUIE.SV.ActionBar_Enabled end
    )

    -- Add Item button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
        function ()
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
        "half",
        function () return not LUIE.SV.ActionBar_Enabled end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
        GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
        function () ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_CASTBAR_BLACKLIST") end,
        "half",
        function () return not LUIE.SV.ActionBar_Enabled end
    )

    -- Manage Blacklist
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST),
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
        function ()
            if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_CASTBAR_BLACKLIST"] then
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_CASTBAR_BLACKLIST")
            end
        end,
        "full",
        function () return not LUIE.SV.ActionBar_Enabled end
    )

    -- Action Bar - Duration Override Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Ability Duration Overrides"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        "Override ability durations. Useful when the game API reports the wrong duration for abilities with multiple effects."
    )

    -- Add Duration Override button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        "Add Duration Override",
        "Add a new duration override for an ability",
        function ()
            if LUIE.DurationOverrideDialogs and LUIE.DurationOverrideDialogs["LUIE_ADD_DURATION_OVERRIDE"] then
                LUIE.DurationOverrideDialogs["LUIE_ADD_DURATION_OVERRIDE"]:Show()
            end
        end,
        "half",
        function () return not LUIE.SV.ActionBar_Enabled end
    )

    -- Manage Duration Overrides button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        "Manage Duration Overrides",
        "View and remove existing duration overrides",
        function ()
            if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_DURATION_OVERRIDES"] then
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_DURATION_OVERRIDES")
            end
        end,
        "half",
        function () return not LUIE.SV.ActionBar_Enabled end
    )

    -- Register the settings panel
    if LUIE.SV.ActionBar_Enabled then
        panel:AddSettings(settingsData)
    end
end
