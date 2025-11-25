-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) LUIE.CombatText
local CombatText = LUIE.CombatText
local CombatTextConstants = LuiData.Data.CombatTextConstants
local BlacklistPresets = LuiData.Data.CombatTextBlacklistPresets

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

local type, pairs = type, pairs
local table_insert = table.insert
local zo_strformat = zo_strformat

local globalIconOptions = { "All Crowd Control", "NPC CC Only", "Player CC Only" }
local globalIconOptionsKeys = { ["All Crowd Control"] = 1, ["NPC CC Only"] = 2, ["Player CC Only"] = 3 }

-- Create a list of abilityId's / abilityName's to use for Blacklist
local function GenerateCustomList(input)
    local options, values = {}, {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        -- If the input is a numeric value then we can pull this abilityId's info.
        if type(id) == "number" then
            options[counter] = zo_iconFormat(GetAbilityIcon(id), 16, 16) .. " [" .. id .. "] " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
            -- If the input is not numeric then add this as a name only.
        else
            options[counter] = id
        end
        values[counter] = id
    end
    return options, values
end

-- Convert to LHAS format {name, data}
local function GenerateCustomListLHAS(input)
    local items = {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        local displayName
        if type(id) == "number" then
            displayName = zo_iconFormat(GetAbilityIcon(id), 16, 16) .. " [" .. id .. "] " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
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
        identifier = "LUIE_CLEAR_CT_BLACKLIST",
        title = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG), GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER)),
        callback = function (dialog)
            CombatText.ClearCustomList(CombatText.SV.blacklist)
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

function CombatText.CreateConsoleSettings()
    local Defaults = CombatText.Defaults
    local Settings = CombatText.SV

    -- Register the settings panel
    if not LUIE.SV.CombatText_Enabled then
        return
    end

    -- Load Dialog Buttons
    loadDialogButtons()

    -- Register custom blacklist management dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_CT_BLACKLIST",
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER),
        function ()
            return GenerateCustomListLHAS(Settings.blacklist)
        end,
        function (itemData)
            CombatText.RemoveFromCustomList(Settings.blacklist, itemData)
        end,
        function (text)
            CombatText.AddToCustomList(Settings.blacklist, text)
        end,
        function ()
            CombatText.ClearCustomList(Settings.blacklist)
        end
    )

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_CT)),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset to defaults if needed
                                    end,
                                    allowRefresh = true
                                })

    local settingsData = {}

    -- Combat Text Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_DESCRIPTION)
    )

    -- ReloadUI Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function ()
            -- Lock all panels before reloading
            for k, _ in pairs(Settings.panels) do
                _G[k]:SetMouseEnabled(false)
                _G[k]:SetMovable(false)
                _G[k .. "_Backdrop"]:SetHidden(true)
                _G[k .. "_Label"]:SetHidden(true)
            end
            -- Reset the unlocked state
            Settings.unlocked = false
            -- Reload the UI
            ReloadUI("ingame")
        end
    )

    -- Unlock Panels
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_UNLOCK),
        GetString(LUIE_STRING_LAM_CT_UNLOCK_TP),
        function () return Settings.unlocked end,
        function (value)
            CombatText.SetMovingState(value)
        end,
        "half",
        nil,
        Defaults.unlocked
    )

    -- Combat Text - Common Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_COMMON_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_IC_ONLY),
        GetString(LUIE_STRING_LAM_CT_IC_ONLY_TP),
        function () return Settings.toggles.inCombatOnly end,
        function (v) Settings.toggles.inCombatOnly = v end,
        "full",
        nil,
        Defaults.toggles.inCombatOnly
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CT_TRANSPARENCY),
        GetString(LUIE_STRING_LAM_CT_TRANSPARENCY_TP),
        0, 100, 1,
        function () return Settings.common.transparencyValue end,
        function (v) Settings.common.transparencyValue = v end,
        "full",
        nil,
        Defaults.common.transparencyValue
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_OVERKILL),
        GetString(LUIE_STRING_LAM_CT_OVERKILL_TP),
        function () return Settings.common.overkill end,
        function (v) Settings.common.overkill = v end,
        "full",
        nil,
        Defaults.common.overkill
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_OVERHEAL),
        GetString(LUIE_STRING_LAM_CT_OVERHEAL_TP),
        function () return Settings.common.overheal end,
        function (v) Settings.common.overheal = v end,
        "full",
        nil,
        Defaults.common.overheal
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_ABBREVIATE),
        GetString(LUIE_STRING_LAM_CT_ABBREVIATE_TP),
        function () return Settings.common.abbreviateNumbers end,
        function (v) Settings.common.abbreviateNumbers = v end,
        "full",
        nil,
        Defaults.common.abbreviateNumbers
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_TP),
        function () return Settings.common.useDefaultIcon end,
        function (newValue) Settings.common.useDefaultIcon = newValue end,
        "full",
        nil,
        Defaults.common.useDefaultIcon
    )

    -- Generic Icon Options dropdown
    local globalIconItems = {}
    for i, option in ipairs(globalIconOptions) do
        globalIconItems[i] = { name = option, data = option }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS),
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS_TP),
        globalIconItems,
        function () return globalIconOptions[Settings.common.defaultIconOptions] end,
        function (combobox, value, item)
            Settings.common.defaultIconOptions = globalIconOptionsKeys[value]
        end,
        5,
        "full",
        function () return not Settings.common.useDefaultIcon end,
        globalIconOptions[Defaults.common.defaultIconOptions]
    )

    -- Combat Text - Blacklist Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT)
    )

    -- Blacklist preset buttons
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SETS),
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SETS_TP),
        function ()
            CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Sets)
            if LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
            -- Refresh dialog if open
            LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
        end,
        "half"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SORCERER),
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SORCERER_TP),
        function ()
            CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Sorcerer)
            if LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
            -- Refresh dialog if open
            LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
        end,
        "half"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_TEMPLAR),
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_TEMPLAR_TP),
        function ()
            CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Templar)
            if LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
            -- Refresh dialog if open
            LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
        end,
        "half"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_WARDEN),
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_WARDEN_TP),
        function ()
            CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Warden)
            if LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
            -- Refresh dialog if open
            LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
        end,
        "half"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NECROMANCER),
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NECROMANCER_TP),
        function ()
            CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Necromancer)
            if LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
            -- Refresh dialog if open
            LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
        end,
        "half"
    )

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
        "full"
    )

    -- Add Item button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
        function ()
            local text = Settings.tempBlacklistText or ""
            if text and text ~= "" then
                CombatText.AddToCustomList(Settings.blacklist, text)
                Settings.tempBlacklistText = ""
                -- Refresh the blacklist dialog if it's open
                if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_CT_BLACKLIST"] then
                    LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
                end
                -- Refresh settings to clear the edit box
                if LHAS and LHAS.RefreshAddonSettings then
                    LHAS:RefreshAddonSettings()
                end
            end
        end,
        "half"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
        GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
        function () ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_CT_BLACKLIST") end,
        "half"
    )

    -- Manage Blacklist
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER),
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
        function ()
            if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_CT_BLACKLIST"] then
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        end,
        "full"
    )

    -- Combat Text - Damage & Healing Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_DAMAGE_AND_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS))
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
        GetString(LUIE_STRING_LAM_CT_INCOMING_DAMAGE_TP),
        function () return Settings.toggles.incoming.showDamage end,
        function (v) Settings.toggles.incoming.showDamage = v end,
        "half",
        nil,
        Defaults.toggles.incoming.showDamage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
        GetString(LUIE_STRING_LAM_CT_OUTGOING_DAMAGE_TP),
        function () return Settings.toggles.outgoing.showDamage end,
        function (v) Settings.toggles.outgoing.showDamage = v end,
        "half",
        nil,
        Defaults.toggles.outgoing.showDamage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DAMAGE_TP),
        function () return Settings.formats.damage end,
        function (v) Settings.formats.damage = v end,
        "half",
        nil,
        Defaults.formats.damage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DAMAGE_CRITICAL_TP),
        function () return Settings.formats.damagecritical end,
        function (v) Settings.formats.damagecritical = v end,
        "half",
        nil,
        Defaults.formats.damagecritical
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DAMAGE_TP),
        8, 72, 1,
        function () return Settings.fontSizes.damage end,
        function (size) Settings.fontSizes.damage = size end,
        "half",
        nil,
        Defaults.fontSizes.damage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DAMAGE_CRITICAL_TP),
        8, 72, 1,
        function () return Settings.fontSizes.damagecritical end,
        function (size) Settings.fontSizes.damagecritical = size end,
        "half",
        nil,
        Defaults.fontSizes.damagecritical
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_DOT)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
        GetString(LUIE_STRING_LAM_CT_INCOMING_DOT_TP),
        function () return Settings.toggles.incoming.showDot end,
        function (v) Settings.toggles.incoming.showDot = v end,
        "half",
        nil,
        Defaults.toggles.incoming.showDot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
        GetString(LUIE_STRING_LAM_CT_OUTGOING_DOT_TP),
        function () return Settings.toggles.outgoing.showDot end,
        function (v) Settings.toggles.outgoing.showDot = v end,
        "half",
        nil,
        Defaults.toggles.outgoing.showDot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DOT_TP),
        function () return Settings.formats.dot end,
        function (v) Settings.formats.dot = v end,
        "half",
        nil,
        Defaults.formats.dot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DOT_CRITICAL_TP),
        function () return Settings.formats.dotcritical end,
        function (v) Settings.formats.dotcritical = v end,
        "half",
        nil,
        Defaults.formats.dotcritical
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DOT_TP),
        8, 72, 1,
        function () return Settings.fontSizes.dot end,
        function (size) Settings.fontSizes.dot = size end,
        "half",
        nil,
        Defaults.fontSizes.dot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DOT_CRITICAL_TP),
        8, 72, 1,
        function () return Settings.fontSizes.dotcritical end,
        function (size) Settings.fontSizes.dotcritical = size end,
        "half",
        nil,
        Defaults.fontSizes.dotcritical
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_HEADER_DAMAGE_COLOR)
    )

    -- Damage color pickers
    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_NONE),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_NONE_TP),
        function () return unpack(Settings.colors.damage[0]) end,
        function (r, g, b, a) Settings.colors.damage[0] = { r, g, b, a } end,
        Defaults.colors.damage[0]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_GENERIC),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_GENERIC_TP),
        function () return unpack(Settings.colors.damage[1]) end,
        function (r, g, b, a) Settings.colors.damage[1] = { r, g, b, a } end,
        Defaults.colors.damage[1]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_PHYSICAL),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_PHYSICAL_TP),
        function () return unpack(Settings.colors.damage[2]) end,
        function (r, g, b, a) Settings.colors.damage[2] = { r, g, b, a } end,
        Defaults.colors.damage[2]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_BLEED),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_BLEED_TP),
        function () return unpack(Settings.colors.damage[12]) end,
        function (r, g, b, a) Settings.colors.damage[12] = { r, g, b, a } end,
        Defaults.colors.damage[12]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_FIRE),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_FIRE_TP),
        function () return unpack(Settings.colors.damage[3]) end,
        function (r, g, b, a) Settings.colors.damage[3] = { r, g, b, a } end,
        Defaults.colors.damage[3]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_SHOCK),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_SHOCK_TP),
        function () return unpack(Settings.colors.damage[4]) end,
        function (r, g, b, a) Settings.colors.damage[4] = { r, g, b, a } end,
        Defaults.colors.damage[4]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OBLIVION),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OBLIVION_TP),
        function () return unpack(Settings.colors.damage[5]) end,
        function (r, g, b, a) Settings.colors.damage[5] = { r, g, b, a } end,
        Defaults.colors.damage[5]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_COLD),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_COLD_TP),
        function () return unpack(Settings.colors.damage[6]) end,
        function (r, g, b, a) Settings.colors.damage[6] = { r, g, b, a } end,
        Defaults.colors.damage[6]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_EARTH),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_EARTH_TP),
        function () return unpack(Settings.colors.damage[7]) end,
        function (r, g, b, a) Settings.colors.damage[7] = { r, g, b, a } end,
        Defaults.colors.damage[7]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_MAGIC),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_MAGIC_TP),
        function () return unpack(Settings.colors.damage[8]) end,
        function (r, g, b, a) Settings.colors.damage[8] = { r, g, b, a } end,
        Defaults.colors.damage[8]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DROWN),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DROWN_TP),
        function () return unpack(Settings.colors.damage[9]) end,
        function (r, g, b, a) Settings.colors.damage[9] = { r, g, b, a } end,
        Defaults.colors.damage[9]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DISEASE),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DISEASE_TP),
        function () return unpack(Settings.colors.damage[10]) end,
        function (r, g, b, a) Settings.colors.damage[10] = { r, g, b, a } end,
        Defaults.colors.damage[10]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_POISON),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_POISON_TP),
        function () return unpack(Settings.colors.damage[11]) end,
        function (r, g, b, a) Settings.colors.damage[11] = { r, g, b, a } end,
        Defaults.colors.damage[11]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OVERRIDE),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OVERRIDE_TP),
        function () return Settings.toggles.criticalDamageOverride end,
        function (v) Settings.toggles.criticalDamageOverride = v end,
        "full",
        nil,
        Defaults.toggles.criticalDamageOverride
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_DAMAGE_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_DAMAGE_COLOR_TP),
        function () return unpack(Settings.colors.criticalDamageOverride) end,
        function (r, g, b, a) Settings.colors.criticalDamageOverride = { r, g, b, a } end,
        Defaults.colors.criticalDamageOverride,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_OVERRIDE),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_OVERRIDE_TP),
        function () return Settings.toggles.incomingDamageOverride end,
        function (v) Settings.toggles.incomingDamageOverride = v end,
        "full",
        nil,
        Defaults.toggles.incomingDamageOverride
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_COLOR_TP),
        function () return unpack(Settings.colors.incomingDamageOverride) end,
        function (r, g, b, a) Settings.colors.incomingDamageOverride = { r, g, b, a } end,
        Defaults.colors.incomingDamageOverride,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_HEALING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
        GetString(LUIE_STRING_LAM_CT_INCOMING_HEALING_TP),
        function () return Settings.toggles.incoming.showHealing end,
        function (v) Settings.toggles.incoming.showHealing = v end,
        "half",
        nil,
        Defaults.toggles.incoming.showHealing
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
        GetString(LUIE_STRING_LAM_CT_OUTGOING_HEALING_TP),
        function () return Settings.toggles.outgoing.showHealing end,
        function (v) Settings.toggles.outgoing.showHealing = v end,
        "half",
        nil,
        Defaults.toggles.outgoing.showHealing
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HEALING_TP),
        function () return Settings.formats.healing end,
        function (v) Settings.formats.healing = v end,
        "half",
        nil,
        Defaults.formats.healing
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HEALING_CRITICAL_TP),
        function () return Settings.formats.healingcritical end,
        function (v) Settings.formats.healingcritical = v end,
        "half",
        nil,
        Defaults.formats.healingcritical
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HEALING_TP),
        8, 72, 1,
        function () return Settings.fontSizes.healing end,
        function (size) Settings.fontSizes.healing = size end,
        "half",
        nil,
        Defaults.fontSizes.healing
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HEALING_CRITICAL_TP),
        8, 72, 1,
        function () return Settings.fontSizes.healingcritical end,
        function (size) Settings.fontSizes.healingcritical = size end,
        "half",
        nil,
        Defaults.fontSizes.healingcritical
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_HOT)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
        GetString(LUIE_STRING_LAM_CT_INCOMING_HOT_TP),
        function () return Settings.toggles.incoming.showHot end,
        function (v) Settings.toggles.incoming.showHot = v end,
        "half",
        nil,
        Defaults.toggles.incoming.showHot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
        GetString(LUIE_STRING_LAM_CT_OUTGOING_HOT_TP),
        function () return Settings.toggles.outgoing.showHot end,
        function (v) Settings.toggles.outgoing.showHot = v end,
        "half",
        nil,
        Defaults.toggles.outgoing.showHot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HOT_TP),
        function () return Settings.formats.hot end,
        function (v) Settings.formats.hot = v end,
        "half",
        nil,
        Defaults.formats.hot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HOT_CRITICAL_TP),
        function () return Settings.formats.hotcritical end,
        function (v) Settings.formats.hotcritical = v end,
        "half",
        nil,
        Defaults.formats.hotcritical
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HOT_TP),
        8, 72, 1,
        function () return Settings.fontSizes.hot end,
        function (size) Settings.fontSizes.hot = size end,
        "half",
        nil,
        Defaults.fontSizes.hot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HOT_CRITICAL_TP),
        8, 72, 1,
        function () return Settings.fontSizes.hotcritical end,
        function (size) Settings.fontSizes.hotcritical = size end,
        "half",
        nil,
        Defaults.fontSizes.hotcritical
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_HEADER_HEALING_COLOR)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_TP),
        function () return unpack(Settings.colors.healing) end,
        function (r, g, b, a) Settings.colors.healing = { r, g, b, a } end,
        Defaults.colors.healing
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_OVERRIDE),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_OVERRIDE_TP),
        function () return Settings.toggles.criticalHealingOverride end,
        function (v) Settings.toggles.criticalHealingOverride = v end,
        "full",
        nil,
        Defaults.toggles.criticalHealingOverride
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_HEALING_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_HEALING_COLOR_TP),
        function () return unpack(Settings.colors.criticalHealingOverride) end,
        function (r, g, b, a) Settings.colors.criticalHealingOverride = { r, g, b, a } end,
        Defaults.colors.criticalHealingOverride,
        5
    )

    -- Combat Text - Resource Gain & Drain Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_RESOURCE_GAIN_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS))
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_GAIN_LOSS_TP),
        8, 72, 1,
        function () return Settings.fontSizes.gainLoss end,
        function (size) Settings.fontSizes.gainLoss = size end,
        "full",
        nil,
        Defaults.fontSizes.gainLoss
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
        GetString(LUIE_STRING_LAM_CT_INCOMING_ENERGIZE_TP),
        function () return Settings.toggles.incoming.showEnergize end,
        function (v) Settings.toggles.incoming.showEnergize = v end,
        "half",
        nil,
        Defaults.toggles.incoming.showEnergize
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
        GetString(LUIE_STRING_LAM_CT_OUTGOING_ENERGIZE_TP),
        function () return Settings.toggles.outgoing.showEnergize end,
        function (v) Settings.toggles.outgoing.showEnergize = v end,
        "half",
        nil,
        Defaults.toggles.outgoing.showEnergize
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_ENERGIZE_TP),
        function () return Settings.formats.energize end,
        function (v) Settings.formats.energize = v end,
        "full",
        nil,
        Defaults.formats.energize
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_MAGICKA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_MAGICKA_TP),
        function () return unpack(Settings.colors.energizeMagicka) end,
        function (r, g, b, a) Settings.colors.energizeMagicka = { r, g, b, a } end,
        Defaults.colors.energizeMagicka
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_STAMINA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_STAMINA_TP),
        function () return unpack(Settings.colors.energizeStamina) end,
        function (r, g, b, a) Settings.colors.energizeStamina = { r, g, b, a } end,
        Defaults.colors.energizeStamina
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
        GetString(LUIE_STRING_LAM_CT_INCOMING_ENERGIZE_ULTIMATE_TP),
        function () return Settings.toggles.incoming.showUltimateEnergize end,
        function (v) Settings.toggles.incoming.showUltimateEnergize = v end,
        "half",
        nil,
        Defaults.toggles.incoming.showUltimateEnergize
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
        GetString(LUIE_STRING_LAM_CT_OUTGOING_ENERGIZE_ULTIMATE_TP),
        function () return Settings.toggles.outgoing.showUltimateEnergize end,
        function (v) Settings.toggles.outgoing.showUltimateEnergize = v end,
        "half",
        nil,
        Defaults.toggles.outgoing.showUltimateEnergize
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_ENERGIZE_ULTIMATE_TP),
        function () return Settings.formats.ultimateEnergize end,
        function (v) Settings.formats.ultimateEnergize = v end,
        "full",
        nil,
        Defaults.formats.ultimateEnergize
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_ULTIMATE_TP),
        function () return unpack(Settings.colors.energizeUltimate) end,
        function (r, g, b, a) Settings.colors.energizeUltimate = { r, g, b, a } end,
        Defaults.colors.energizeUltimate
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
        GetString(LUIE_STRING_LAM_CT_INCOMING_DRAIN_TP),
        function () return Settings.toggles.incoming.showDrain end,
        function (v) Settings.toggles.incoming.showDrain = v end,
        "half",
        nil,
        Defaults.toggles.incoming.showDrain
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
        GetString(LUIE_STRING_LAM_CT_OUTGOING_DRAIN_TP),
        function () return Settings.toggles.outgoing.showDrain end,
        function (v) Settings.toggles.outgoing.showDrain = v end,
        "half",
        nil,
        Defaults.toggles.outgoing.showDrain
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DRAIN_TP),
        function () return Settings.formats.drain end,
        function (v) Settings.formats.drain = v end,
        "full",
        nil,
        Defaults.formats.drain
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_MAGICKA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DRAIN_MAGICKA_TP),
        function () return unpack(Settings.colors.drainMagicka) end,
        function (r, g, b, a) Settings.colors.drainMagicka = { r, g, b, a } end,
        Defaults.colors.drainMagicka
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_STAMINA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
        GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DRAIN_STAMINA_TP),
        function () return unpack(Settings.colors.drainStamina) end,
        function (r, g, b, a) Settings.colors.drainStamina = { r, g, b, a } end,
        Defaults.colors.drainStamina
    )

    -- Combat Text - Mitigation Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_MITIGATION), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS))
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_MITIGATION_TP),
        8, 72, 1,
        function () return Settings.fontSizes.mitigation end,
        function (size) Settings.fontSizes.mitigation = size end,
        "full",
        nil,
        Defaults.fontSizes.mitigation
    )

    -- Mitigation types (Miss, Immune, Parried, Reflected, Damage Shielded, Dodged, Blocked, Interrupted)
    local mitigationTypes =
    {
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_MISS),          incoming = "showMiss",         outgoing = "showMiss",         format = "miss",         color = "miss"         },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_IMMUNE),        incoming = "showImmune",       outgoing = "showImmune",       format = "immune",       color = "immune"       },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_PARRIED),       incoming = "showParried",      outgoing = "showParried",      format = "parried",      color = "parried"      },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_REFLECTED),     incoming = "showReflected",    outgoing = "showReflected",    format = "reflected",    color = "reflected"    },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE_SHIELD), incoming = "showDamageShield", outgoing = "showDamageShield", format = "damageShield", color = "damageShield" },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_DODGED),        incoming = "showDodged",       outgoing = "showDodged",       format = "dodged",       color = "dodged"       },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_BLOCKED),       incoming = "showBlocked",      outgoing = "showBlocked",      format = "blocked",      color = "blocked"      },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_INTERRUPTED),   incoming = "showInterrupted",  outgoing = "showInterrupted",  format = "interrupted",  color = "interrupted"  },
    }

    for _, mitType in ipairs(mitigationTypes) do
        settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(mitType.header)

        settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
            zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), mitType.header, GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            GetString("LUIE_STRING_LAM_CT_INCOMING_" .. mitType.header:upper() .. "_TP"),
            function () return Settings.toggles.incoming[mitType.incoming] end,
            function (v) Settings.toggles.incoming[mitType.incoming] = v end,
            "half",
            nil,
            Defaults.toggles.incoming[mitType.incoming]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
            zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), mitType.header, GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            GetString("LUIE_STRING_LAM_CT_OUTGOING_" .. mitType.header:upper() .. "_TP"),
            function () return Settings.toggles.outgoing[mitType.outgoing] end,
            function (v) Settings.toggles.outgoing[mitType.outgoing] = v end,
            "half",
            nil,
            Defaults.toggles.outgoing[mitType.outgoing]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
            GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            GetString("LUIE_STRING_LAM_CT_FORMAT_COMBAT_" .. mitType.format:upper() .. "_TP"),
            function () return Settings.formats[mitType.format] end,
            function (v) Settings.formats[mitType.format] = v end,
            "full",
            nil,
            Defaults.formats[mitType.format]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
            GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            GetString("LUIE_STRING_LAM_CT_COLOR_COMBAT_" .. mitType.color:upper() .. "_TP"),
            function () return unpack(Settings.colors[mitType.color]) end,
            function (r, g, b, a) Settings.colors[mitType.color] = { r, g, b, a } end,
            Defaults.colors[mitType.color]
        )
    end

    -- Combat Text - Crowd Control Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_CROWD_CONTROL), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS))
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_CROWD_CONTROL_TP),
        8, 72, 1,
        function () return Settings.fontSizes.crowdControl end,
        function (size) Settings.fontSizes.crowdControl = size end,
        "full",
        nil,
        Defaults.fontSizes.crowdControl
    )

    -- Crowd Control types (Disoriented, Feared, Off-Balance, Silenced, Stunned, Charmed)
    local ccTypes =
    {
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_DISORIENTED), incoming = "showDisoriented", outgoing = "showDisoriented", format = "disoriented", color = "disoriented" },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_FEARED),      incoming = "showFeared",      outgoing = "showFeared",      format = "feared",      color = "feared"      },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_OFF_BALANCE), incoming = "showOffBalanced", outgoing = "showOffBalanced", format = "offBalanced", color = "offBalanced" },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_SILENCED),    incoming = "showSilenced",    outgoing = "showSilenced",    format = "silenced",    color = "silenced"    },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_STUNNED),     incoming = "showStunned",     outgoing = "showStunned",     format = "stunned",     color = "stunned"     },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_CHARMED),     incoming = "showCharmed",     outgoing = "showCharmed",     format = "charmed",     color = "charmed"     },
    }

    for _, ccType in ipairs(ccTypes) do
        settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(ccType.header)

        settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
            zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), ccType.header, GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            GetString("LUIE_STRING_LAM_CT_INCOMING_" .. ccType.header:upper() .. "_TP"),
            function () return Settings.toggles.incoming[ccType.incoming] end,
            function (v) Settings.toggles.incoming[ccType.incoming] = v end,
            "half",
            nil,
            Defaults.toggles.incoming[ccType.incoming]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
            zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), ccType.header, GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            GetString("LUIE_STRING_LAM_CT_OUTGOING_" .. ccType.header:upper() .. "_TP"),
            function () return Settings.toggles.outgoing[ccType.outgoing] end,
            function (v) Settings.toggles.outgoing[ccType.outgoing] = v end,
            "half",
            nil,
            Defaults.toggles.outgoing[ccType.outgoing]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
            GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            GetString("LUIE_STRING_LAM_CT_FORMAT_COMBAT_" .. ccType.format:upper() .. "_TP"),
            function () return Settings.formats[ccType.format] end,
            function (v) Settings.formats[ccType.format] = v end,
            "full",
            nil,
            Defaults.formats[ccType.format]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
            GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            GetString("LUIE_STRING_LAM_CT_COLOR_COMBAT_" .. ccType.color:upper() .. "_TP"),
            function () return unpack(Settings.colors[ccType.color]) end,
            function (r, g, b, a) Settings.colors[ccType.color] = { r, g, b, a } end,
            Defaults.colors[ccType.color]
        )
    end

    -- Combat Text - Notification Options Section (includes Combat State, Death, Point Gain)
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_NOTIFICATION), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS))
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_STATE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_IN_TP),
        function () return Settings.toggles.showInCombat end,
        function (v) Settings.toggles.showInCombat = v end,
        "half",
        nil,
        Defaults.toggles.showInCombat
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_OUT_TP),
        function () return Settings.toggles.showOutCombat end,
        function (v) Settings.toggles.showOutCombat = v end,
        "half",
        nil,
        Defaults.toggles.showOutCombat
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_COMBAT_IN_TP),
        function () return Settings.formats.inCombat end,
        function (v) Settings.formats.inCombat = v end,
        "half",
        nil,
        Defaults.formats.inCombat
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_COMBAT_OUT_TP),
        function () return Settings.formats.outCombat end,
        function (v) Settings.formats.outCombat = v end,
        "half",
        nil,
        Defaults.formats.outCombat
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_COMBAT_STATE_TP),
        8, 72, 1,
        function () return Settings.fontSizes.combatState end,
        function (size) Settings.fontSizes.combatState = size end,
        "full",
        nil,
        Defaults.fontSizes.combatState
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_COMBAT_IN_TP),
        function () return unpack(Settings.colors.inCombat) end,
        function (r, g, b, a) Settings.colors.inCombat = { r, g, b, a } end,
        Defaults.colors.inCombat
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_COMBAT_OUT_TP),
        function () return unpack(Settings.colors.outCombat) end,
        function (r, g, b, a) Settings.colors.outCombat = { r, g, b, a } end,
        Defaults.colors.outCombat
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_DEATH_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_DEATH_NOTIFICATION),
        GetString(LUIE_STRING_LAM_CT_DEATH_NOTIFICATION_TP),
        function () return Settings.toggles.showDeath end,
        function (v) Settings.toggles.showDeath = v end,
        "full",
        nil,
        Defaults.toggles.showDeath
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_DEATH_USE_ACCOUNT_NAME),
        GetString(LUIE_STRING_LAM_CT_DEATH_USE_ACCOUNT_NAME_TP),
        function () return Settings.toggles.useAccountNameForDeath end,
        function (v) Settings.toggles.useAccountNameForDeath = v end,
        "full",
        function () return not Settings.toggles.showDeath end,
        Defaults.toggles.useAccountNameForDeath
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_DEATH_FORMAT_TP),
        function () return Settings.formats.death end,
        function (v) Settings.formats.death = v end,
        "full",
        nil,
        Defaults.formats.death
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_DEATH_FONT_SIZE_TP),
        8, 72, 1,
        function () return Settings.fontSizes.death end,
        function (size) Settings.fontSizes.death = size end,
        "full",
        nil,
        Defaults.fontSizes.death
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_DEATH_COLOR_TP),
        function () return unpack(Settings.colors.death) end,
        function (r, g, b, a) Settings.colors.death = { r, g, b, a } end,
        Defaults.colors.death
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_POINTS_TP),
        8, 72, 1,
        function () return Settings.fontSizes.point end,
        function (size) Settings.fontSizes.point = size end,
        "full",
        nil,
        Defaults.fontSizes.point
    )

    -- Point Gain types (Alliance, Experience, Champion)
    local pointTypes =
    {
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_ALLIANCE),   toggle = "showPointsAlliance",   format = "pointsAlliance",   color = "pointsAlliance"   },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_EXPERIENCE), toggle = "showPointsExperience", format = "pointsExperience", color = "pointsExperience" },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_CHAMPION),   toggle = "showPointsChampion",   format = "pointsChampion",   color = "pointsChampion"   },
    }

    for _, pointType in ipairs(pointTypes) do
        settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(pointType.header)

        settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
            zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), pointType.header),
            GetString("LUIE_STRING_LAM_CT_NOTIFICATION_" .. pointType.header:upper() .. "_TP"),
            function () return Settings.toggles[pointType.toggle] end,
            function (v) Settings.toggles[pointType.toggle] = v end,
            "full",
            nil,
            Defaults.toggles[pointType.toggle]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
            GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            GetString("LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_" .. pointType.format:upper() .. "_TP"),
            function () return Settings.formats[pointType.format] end,
            function (v) Settings.formats[pointType.format] = v end,
            "full",
            nil,
            Defaults.formats[pointType.format]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
            GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            GetString("LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_" .. pointType.color:upper() .. "_TP"),
            function () return unpack(Settings.colors[pointType.color]) end,
            function (r, g, b, a) Settings.colors[pointType.color] = { r, g, b, a } end,
            Defaults.colors[pointType.color]
        )
    end

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_AND_POTION_READY)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_RESOURCE_TP),
        8, 72, 1,
        function () return Settings.fontSizes.readylabel end,
        function (size) Settings.fontSizes.readylabel = size end,
        "full",
        nil,
        Defaults.fontSizes.readylabel
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ULTIMATE_READY_TP),
        function () return Settings.toggles.showUltimate end,
        function (v) Settings.toggles.showUltimate = v end,
        "half",
        nil,
        Defaults.toggles.showUltimate
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_POTION_READY_TP),
        function () return Settings.toggles.showPotionReady end,
        function (v) Settings.toggles.showPotionReady = v end,
        "half",
        nil,
        Defaults.toggles.showPotionReady
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_ULTIMATE_TP),
        function () return Settings.formats.ultimateReady end,
        function (v) Settings.formats.ultimateReady = v end,
        "half",
        nil,
        Defaults.formats.ultimateReady
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_POTION_TP),
        function () return Settings.formats.potionReady end,
        function (v) Settings.formats.potionReady = v end,
        "half",
        nil,
        Defaults.formats.potionReady
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_ULTIMATE_TP),
        function () return unpack(Settings.colors.ultimateReady) end,
        function (r, g, b, a) Settings.colors.ultimateReady = { r, g, b, a } end,
        Defaults.colors.ultimateReady
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_POTION_TP),
        function () return unpack(Settings.colors.potionReady) end,
        function (r, g, b, a) Settings.colors.potionReady = { r, g, b, a } end,
        Defaults.colors.potionReady
    )

    -- Combat Text - Low Resource Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_LOW_RESOURCE), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS))
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_RESOURCE_OPTIONS)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_RESOURCE_TP),
        8, 72, 1,
        function () return Settings.fontSizes.resource end,
        function (size) Settings.fontSizes.resource = size end,
        "full",
        nil,
        Defaults.fontSizes.resource
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_SOUND),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_SOUND_TP),
        function () return Settings.toggles.warningSound end,
        function (v) Settings.toggles.warningSound = v end,
        "full",
        function () return not (Settings.toggles.showLowHealth or Settings.toggles.showLowMagicka or Settings.toggles.showLowStamina) end,
        Defaults.toggles.warningSound
    )

    -- Low Resource types (Health, Magicka, Stamina)
    local resourceTypes =
    {
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_HEALTH),  toggle = "showLowHealth",  threshold = "healthThreshold",  format = "resourceHealth",  color = "lowHealth"  },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_MAGICKA), toggle = "showLowMagicka", threshold = "magickaThreshold", format = "resourceMagicka", color = "lowMagicka" },
        { header = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_STAMINA), toggle = "showLowStamina", threshold = "staminaThreshold", format = "resourceStamina", color = "lowStamina" },
    }

    for _, resType in ipairs(resourceTypes) do
        settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(resType.header)

        settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
            zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), resType.header),
            GetString("LUIE_STRING_LAM_CT_NOTIFICATION_" .. resType.header:upper() .. "_TP"),
            function () return Settings.toggles[resType.toggle] end,
            function (v) Settings.toggles[resType.toggle] = v end,
            "full",
            nil,
            Defaults.toggles[resType.toggle]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
            GetString("LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_" .. resType.header:upper()),
            GetString("LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_" .. resType.header:upper() .. "_TP"),
            15, 50, 1,
            function () return Settings[resType.threshold] end,
            function (threshold) Settings[resType.threshold] = threshold end,
            5,
            "full",
            function () return not Settings.toggles[resType.toggle] end,
            Defaults[resType.threshold]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
            GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_RESOURCE_TP),
            function () return Settings.formats[resType.format] end,
            function (v) Settings.formats[resType.format] = v end,
            "full",
            nil,
            Defaults.formats[resType.format]
        )

        settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
            GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            GetString("LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_" .. resType.color:upper() .. "_TP"),
            function () return unpack(Settings.colors[resType.color]) end,
            function (r, g, b, a) Settings.colors[resType.color] = { r, g, b, a } end,
            Defaults.colors[resType.color]
        )
    end

    -- Combat Text - Font Format Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_FONT_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_FONT),
        GetString(LUIE_STRING_LAM_CT_FONT_FACE_TP),
        SettingsAPI.GetFontsList(),
        function () return Settings.fontFace end,
        function (var)
            Settings.fontFace = var
            CombatText.ApplyFont()
        end,
        5,
        "full",
        nil,
        Defaults.fontFace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSlider(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CT_FONT_SIZE_TP),
        8, 72, 1,
        function () return Settings.fontSize end,
        function (value)
            Settings.fontSize = value
            -- Update all font sizes proportionally
            Settings.fontSizes.damage = value
            Settings.fontSizes.damagecritical = value
            Settings.fontSizes.healing = value
            Settings.fontSizes.healingcritical = value
            Settings.fontSizes.dot = math.floor(value * 0.8)
            Settings.fontSizes.dotcritical = math.floor(value * 0.8)
            Settings.fontSizes.hot = math.floor(value * 0.8)
            Settings.fontSizes.hotcritical = math.floor(value * 0.8)
            Settings.fontSizes.gainLoss = value
            Settings.fontSizes.mitigation = value
            Settings.fontSizes.crowdControl = math.floor(value * 0.8)
            Settings.fontSizes.combatState = math.floor(value * 0.75)
            Settings.fontSizes.death = value
            Settings.fontSizes.point = math.floor(value * 0.75)
            Settings.fontSizes.resource = value
            Settings.fontSizes.readylabel = value
            CombatText.ApplyFont()
        end,
        5,
        "full",
        nil,
        Defaults.fontSize
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_FONT_STYLE),
        GetString(LUIE_STRING_LAM_CT_FONT_STYLE_TP),
        function () return Settings.fontStyle end,
        function (var)
            Settings.fontStyle = var
            CombatText.ApplyFont()
        end,
        5,
        "full",
        nil,
        Defaults.fontStyle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CT_FONT_TEST),
        GetString(LUIE_STRING_LAM_CT_FONT_TEST_TP),
        function ()
            LUIE:FireCallbacks(CombatTextConstants.eventType.COMBAT, CombatTextConstants.combatType.INCOMING, COMBAT_MECHANIC_FLAGS_STAMINA, zo_random(7, 777), GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST), 41567, DAMAGE_TYPE_PHYSICAL, "Test", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
        end
    )

    -- Combat Text - Animation Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_ANIMATION_HEADER)
    )

    -- Animation Type dropdown
    local animationTypeItems = {}
    for i, animType in ipairs(CombatTextConstants.animationType) do
        animationTypeItems[i] = { name = animType, data = animType }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CT_ANIMATION_TYPE),
        GetString(LUIE_STRING_LAM_CT_ANIMATION_TYPE_TP),
        animationTypeItems,
        function () return Settings.animation.animationType end,
        function (combobox, value, item)
            Settings.animation.animationType = value
        end,
        "full",
        nil,
        Defaults.animation.animationType
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CT_ANIMATION_DURATION),
        GetString(LUIE_STRING_LAM_CT_ANIMATION_DURATION_TP),
        5, 300, 5,
        function () return Settings.animation.animationDuration end,
        function (v) Settings.animation.animationDuration = v end,
        "full",
        nil,
        100
    )

    -- Direction Type dropdowns
    local directionTypeItems = {}
    for i, dirType in ipairs(CombatTextConstants.directionType) do
        directionTypeItems[i] = { name = dirType, data = dirType }
    end

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_IN),
        GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_IN_TP),
        directionTypeItems,
        function () return Settings.animation.incoming.directionType end,
        function (combobox, value, item)
            Settings.animation.incoming.directionType = value
        end,
        "full",
        nil,
        Defaults.animation.incoming.directionType
    )

    -- Icon Side dropdowns
    local iconSideItems = {}
    for i, iconSide in ipairs(CombatTextConstants.iconSide) do
        iconSideItems[i] = { name = iconSide, data = iconSide }
    end

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_IN),
        GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_IN_TP),
        iconSideItems,
        function () return Settings.animation.incomingIcon end,
        function (combobox, value, item)
            Settings.animation.incomingIcon = value
        end,
        "full",
        nil,
        Defaults.animation.incomingIcon
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_OUT),
        GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_OUT_TP),
        directionTypeItems,
        function () return Settings.animation.outgoing.directionType end,
        function (combobox, value, item)
            Settings.animation.outgoing.directionType = value
        end,
        "full",
        nil,
        Defaults.animation.outgoing.directionType
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_OUT),
        GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_OUT_TP),
        iconSideItems,
        function () return Settings.animation.outgoingIcon end,
        function (combobox, value, item)
            Settings.animation.outgoingIcon = value
        end,
        "full",
        nil,
        Defaults.animation.outgoingIcon
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST),
        GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST_TP),
        function ()
            LUIE:FireCallbacks(CombatTextConstants.eventType.COMBAT, CombatTextConstants.combatType.INCOMING, COMBAT_MECHANIC_FLAGS_STAMINA, zo_random(7, 777), GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST), 41567, DAMAGE_TYPE_PHYSICAL, "Test", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
            LUIE:FireCallbacks(CombatTextConstants.eventType.COMBAT, CombatTextConstants.combatType.OUTGOING, COMBAT_MECHANIC_FLAGS_STAMINA, zo_random(7, 777), GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST), 41567, DAMAGE_TYPE_PHYSICAL, "Test", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
        end
    )

    -- Combat Text - Throttle Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_THROTTLE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_THROTTLE_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE),
        GetString(LUIE_STRING_LAM_CT_THROTTLE_DAMAGE_TP),
        0, 500, 50,
        function () return Settings.throttles.damage end,
        function (v) Settings.throttles.damage = v end,
        "full",
        nil,
        Defaults.throttles.damage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_DOT),
        GetString(LUIE_STRING_LAM_CT_THROTTLE_DOT_TP),
        0, 500, 50,
        function () return Settings.throttles.dot end,
        function (v) Settings.throttles.dot = v end,
        "full",
        nil,
        Defaults.throttles.dot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_HEALING),
        GetString(LUIE_STRING_LAM_CT_THROTTLE_HEALING_TP),
        0, 500, 50,
        function () return Settings.throttles.healing end,
        function (v) Settings.throttles.healing = v end,
        "full",
        nil,
        Defaults.throttles.healing
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_HOT),
        GetString(LUIE_STRING_LAM_CT_THROTTLE_HOT_TP),
        0, 500, 50,
        function () return Settings.throttles.hot end,
        function (v) Settings.throttles.hot = v end,
        "full",
        nil,
        Defaults.throttles.hot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_THROTTLE_TRAILER),
        GetString(LUIE_STRING_LAM_CT_THROTTLE_TRAILER_TP),
        function () return Settings.toggles.showThrottleTrailer end,
        function (v) Settings.toggles.showThrottleTrailer = v end,
        "full",
        nil,
        Defaults.toggles.showThrottleTrailer
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckbox(
        GetString(LUIE_STRING_LAM_CT_THROTTLE_CRITICAL),
        GetString(LUIE_STRING_LAM_CT_THROTTLE_CRITICAL_TP),
        function () return Settings.toggles.throttleCriticals end,
        function (v) Settings.toggles.throttleCriticals = v end,
        5,
        "full",
        function () return not Settings.toggles.showThrottleTrailer end,
        Defaults.toggles.throttleCriticals
    )

    -- Register the settings panel
    if LUIE.SV.CombatText_Enabled then
        panel:AddSettings(settingsData)
    end
end
