-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo
local CrowdControlTracker = CombatInfo.CrowdControlTracker
local AbilityAlerts = CombatInfo.AbilityAlerts
local SynergyTracker = CombatInfo.SynergyTracker

local type, pairs = type, pairs
local table_insert = table.insert
local zo_strformat = zo_strformat
local string_format = string.format
local alertFrameMovingEnabled = false -- Helper local flag

local globalAlertOptions = { "Show All Incoming Abilities", "Only Show Hard CC Effects", "Only Show Unbreakable CC Effects" }
local globalAlertOptionsKeys = { ["Show All Incoming Abilities"] = 1, ["Only Show Hard CC Effects"] = 2, ["Only Show Unbreakable CC Effects"] = 3 }
local globalIconOptions = { "All Crowd Control", "NPC CC Only", "Player CC Only" }
local globalIconOptionsKeys = { ["All Crowd Control"] = 1, ["NPC CC Only"] = 2, ["Player CC Only"] = 3 }

local DurationOverridesList, DurationOverridesListValues = {}, {}

local ACTION_RESULT_AREA_EFFECT = 669966

-- Create a list of abilityId's / abilityName's to use for Blacklist (LHAS format)
local function GenerateCustomListLHAS(input)
    local items = {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        -- If the input is a numeric value then we can pull this abilityId's info.
        if type(id) == "number" then
            items[counter] =
            {
                name = zo_iconTextFormat(GetAbilityIcon(id), 16, 16, " [" .. id .. "] " .. zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id)), true, true),
                data = id
            }
            -- If the input is not numeric then add this as a name only.
        else
            items[counter] =
            {
                name = id,
                data = id
            }
        end
    end
    return items
end

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

function CombatInfo.CreateConsoleSettings()
    local Defaults = CombatInfo.Defaults
    local Settings = CombatInfo.SV

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_CI)),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset all CombatInfo settings to defaults
                                        CombatInfo:ResetToDefaults()
                                    end,
                                    allowRefresh = true
                                })

    local settingsData = {}

    -- Combat Info Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CI_DESCRIPTION)
    )

    -- ReloadUI Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function ()
            ReloadUI("ingame")
        end,
        "full",
        nil,
        GetString(LUIE_STRING_LAM_RELOADUI)
    )

    -- Combat Info - Floating Markers Option Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER),
        GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER_TP),
        function ()
            return Settings.showMarker
        end,
        function (value)
            Settings.showMarker = value
            CombatInfo.SetMarker(true)
        end,
        "half",
        nil,
        Settings.showMarker
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER_SIZE),
        nil,
        10, 90, 1,
        function ()
            return Settings.markerSize or 26
        end,
        function (value)
            Settings.markerSize = value
            CombatInfo.SetMarker()
        end,
        "half",
        nil,
        26
    )

    -- Active Combat Alerts Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_HEADER_ACTIVE_COMBAT_ALERT)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_UNLOCK),
        GetString(LUIE_STRING_LAM_CI_ALERT_UNLOCK_TP),
        function ()
            return alertFrameMovingEnabled
        end,
        AbilityAlerts.SetMovingStateAlert,
        "half",
        function ()
            return not LUIE.SV.CombatInfo_Enabled
        end,
        false
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RESETPOSITION),
        GetString(LUIE_STRING_LAM_CI_ALERT_RESET_TP),
        AbilityAlerts.ResetAlertFramePosition,
        "half",
        function ()
            return not LUIE.SV.CombatInfo_Enabled
        end,
        GetString(LUIE_STRING_LAM_RESETPOSITION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_TOGGLE),
        GetString(LUIE_STRING_LAM_CI_ALERT_TOGGLE_TP),
        function ()
            return Settings.alerts.toggles.alertEnable
        end,
        function (v)
            Settings.alerts.toggles.alertEnable = v
        end,
        "full",
        nil,
        Defaults.alerts.toggles.alertEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        GetString(LUIE_STRING_LAM_FONT),
        GetString(LUIE_STRING_LAM_CI_ALERT_FONTFACE_TP),
        SettingsAPI.GetFontsList(),
        function ()
            return Settings.alerts.toggles.alertFontFace
        end,
        function (var)
            Settings.alerts.toggles.alertFontFace = var
            AbilityAlerts.ApplyFontAlert()
            AbilityAlerts.ResetAlertSize()
        end,
        5,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.alertFontFace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_CI_ALERT_FONTSIZE_TP),
        16, 64, 1,
        function ()
            return Settings.alerts.toggles.alertFontSize
        end,
        function (value)
            Settings.alerts.toggles.alertFontSize = value
            AbilityAlerts.ApplyFontAlert()
            AbilityAlerts.ResetAlertSize()
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.alertFontSize,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_FONT_STYLE),
        GetString(LUIE_STRING_LAM_CI_ALERT_FONTSTYLE_TP),
        function ()
            return Settings.alerts.toggles.alertFontStyle
        end,
        function (var)
            Settings.alerts.toggles.alertFontStyle = var
            AbilityAlerts.ApplyFontAlert()
            AbilityAlerts.ResetAlertSize()
        end,
        5,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.alertFontStyle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_TIMER_TOGGLE),
        GetString(LUIE_STRING_LAM_CI_ALERT_TIMER_TOGGLE_TP),
        function ()
            return Settings.alerts.toggles.alertTimer
        end,
        function (v)
            Settings.alerts.toggles.alertTimer = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.alertTimer,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_TIMER_COLOR),
        GetString(LUIE_STRING_LAM_CI_ALERT_TIMER_COLOR_TP),
        function ()
            return unpack(Settings.alerts.colors.alertTimer)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertTimer = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertTimer,
        10,
        nil,
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.alertTimer)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_COLOR_BASE),
        GetString(LUIE_STRING_LAM_CI_ALERT_COLOR_BASE_TP),
        function ()
            return unpack(Settings.alerts.colors.alertShared)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertShared = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertShared,
        5,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    -- Shared Options Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_HEADER_SHARED)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_RANK3),
        GetString(LUIE_STRING_LAM_CI_ALERT_RANK3_TP),
        function ()
            return Settings.alerts.toggles.mitigationRank3
        end,
        function (v)
            Settings.alerts.toggles.mitigationRank3 = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.mitigationRank3
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_RANK2),
        GetString(LUIE_STRING_LAM_CI_ALERT_RANK2_TP),
        function ()
            return Settings.alerts.toggles.mitigationRank2
        end,
        function (v)
            Settings.alerts.toggles.mitigationRank2 = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.mitigationRank2
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_RANK1),
        GetString(LUIE_STRING_LAM_CI_ALERT_RANK1_TP),
        function ()
            return Settings.alerts.toggles.mitigationRank1
        end,
        function (v)
            Settings.alerts.toggles.mitigationRank1 = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.mitigationRank1
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_AURA),
        GetString(LUIE_STRING_LAM_CI_ALERT_AURA_TP),
        function ()
            return Settings.alerts.toggles.mitigationAura
        end,
        function (v)
            Settings.alerts.toggles.mitigationAura = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable or not (Settings.alerts.toggles.mitigationRank1 or Settings.alerts.toggles.mitigationRank2 or Settings.alerts.toggles.mitigationRank3)
        end,
        Defaults.alerts.toggles.mitigationAura,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_DUNGEON),
        GetString(LUIE_STRING_LAM_CI_ALERT_DUNGEON_TP),
        function ()
            return Settings.alerts.toggles.mitigationDungeon
        end,
        function (v)
            Settings.alerts.toggles.mitigationDungeon = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable or not (Settings.alerts.toggles.mitigationRank1 or Settings.alerts.toggles.mitigationRank2 or Settings.alerts.toggles.mitigationRank3)
        end,
        Defaults.alerts.toggles.mitigationDungeon,
        5
    )

    -- Mitigation Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_ENABLE),
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_ENABLE_TP),
        function ()
            return Settings.alerts.toggles.showAlertMitigate
        end,
        function (v)
            Settings.alerts.toggles.showAlertMitigate = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.showAlertMitigate
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FILTER),
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FILTER_TP),
        function ()
            local items = {}
            for i, option in ipairs(globalAlertOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return globalAlertOptions[Settings.alerts.toggles.alertOptions]
        end,
        function (combobox, value, item)
            Settings.alerts.toggles.alertOptions = globalAlertOptionsKeys[value]
        end,
        5,
        nil,
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
        end,
        globalAlertOptions[Defaults.alerts.toggles.alertOptions]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_SUFFIX),
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_SUFFIX_TP),
        function ()
            return Settings.alerts.toggles.showMitigation
        end,
        function (v)
            Settings.alerts.toggles.showMitigation = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
        end,
        Defaults.alerts.toggles.showMitigation,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_ABILITY),
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_ABILITY_TP),
        function ()
            return Settings.alerts.toggles.mitigationAbilityName
        end,
        function (v)
            Settings.alerts.toggles.mitigationAbilityName = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
        end,
        Defaults.alerts.toggles.mitigationAbilityName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_NAME),
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_NAME_TP),
        function ()
            return Settings.alerts.toggles.mitigationEnemyName
        end,
        function (v)
            Settings.alerts.toggles.mitigationEnemyName = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
        end,
        Defaults.alerts.toggles.mitigationEnemyName,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_BORDER),
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_BORDER_TP),
        function ()
            return Settings.alerts.toggles.showCrowdControlBorder
        end,
        function (v)
            Settings.alerts.toggles.showCrowdControlBorder = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
        end,
        Defaults.alerts.toggles.showCrowdControlBorder,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_LABEL_COLOR),
        GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_LABEL_COLOR_TP),
        function ()
            return Settings.alerts.toggles.ccLabelColor
        end,
        function (v)
            Settings.alerts.toggles.ccLabelColor = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
        end,
        Defaults.alerts.toggles.ccLabelColor,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_ALERT_TP),
        function ()
            return Settings.alerts.toggles.useDefaultIcon
        end,
        function (newValue)
            Settings.alerts.toggles.useDefaultIcon = newValue
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
        end,
        Defaults.alerts.toggles.useDefaultIcon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_ALLOW_MODIFIER),
        GetString(LUIE_STRING_LAM_CI_ALERT_ALLOW_MODIFIER_TP),
        function ()
            return Settings.alerts.toggles.modifierEnable
        end,
        function (v)
            Settings.alerts.toggles.modifierEnable = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
        end,
        Defaults.alerts.toggles.modifierEnable,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MODIFIER_DIRECT),
        GetString(LUIE_STRING_LAM_CI_ALERT_MODIFIER_DIRECT_TP),
        function ()
            return Settings.alerts.toggles.mitigationModifierOnYou
        end,
        function (v)
            Settings.alerts.toggles.mitigationModifierOnYou = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.modifierEnable)
        end,
        Defaults.alerts.toggles.mitigationModifierOnYou,
        10
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_MODIFIER_SPREAD),
        GetString(LUIE_STRING_LAM_CI_ALERT_MODIFIER_SPREAD_TP),
        function ()
            return Settings.alerts.toggles.mitigationModifierSpreadOut
        end,
        function (v)
            Settings.alerts.toggles.mitigationModifierSpreadOut = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.modifierEnable)
        end,
        Defaults.alerts.toggles.mitigationModifierSpreadOut,
        10
    )

    -- Block Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_BLOCK)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_BLOCK)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_BLOCK_TP),
        function ()
            return Settings.alerts.formats.alertBlock
        end,
        function (v)
            Settings.alerts.formats.alertBlock = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.formats.alertBlock
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_BLOCK_S)),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_BLOCK_S_TP),
        function ()
            return Settings.alerts.formats.alertBlockStagger
        end,
        function (v)
            Settings.alerts.formats.alertBlockStagger = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.formats.alertBlockStagger
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_BLOCK_TP),
        function ()
            return unpack(Settings.alerts.colors.alertBlockA)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertBlockA = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertBlockA,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    -- Dodge Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_DODGE)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_DODGE_TP),
        function ()
            return Settings.alerts.formats.alertDodge
        end,
        function (v)
            Settings.alerts.formats.alertDodge = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.formats.alertDodge
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_DODGE_TP),
        function ()
            return unpack(Settings.alerts.colors.alertDodgeA)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertDodgeA = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertDodgeA,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    -- Avoid Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_AVOID)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_AVOID_TP),
        function ()
            return Settings.alerts.formats.alertAvoid
        end,
        function (v)
            Settings.alerts.formats.alertAvoid = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.formats.alertAvoid
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_AVOID_TP),
        function ()
            return unpack(Settings.alerts.colors.alertAvoidB)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertAvoidB = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertAvoidB,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    -- Interrupt Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_INTERRUPT)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_INTERRUPT_TP),
        function ()
            return Settings.alerts.formats.alertInterrupt
        end,
        function (v)
            Settings.alerts.formats.alertInterrupt = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.formats.alertInterrupt
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_SHOULDUSECC),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_SHOULDUSECC_TP),
        function ()
            return Settings.alerts.formats.alertShouldUseCC
        end,
        function (v)
            Settings.alerts.formats.alertShouldUseCC = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.formats.alertShouldUseCC
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_INTERRUPT_TP),
        function ()
            return unpack(Settings.alerts.colors.alertInterruptC)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertInterruptC = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertInterruptC,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    -- Unmit Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_UNMIT)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_UNMIT)),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ALERT_UNMIT_TP),
        function ()
            return Settings.alerts.toggles.showAlertUnmit
        end,
        function (v)
            Settings.alerts.toggles.showAlertUnmit = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.showAlertUnmit
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_UNMIT_TP),
        function ()
            return Settings.alerts.formats.alertUnmit
        end,
        function (v)
            Settings.alerts.formats.alertUnmit = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertUnmit)
        end,
        Defaults.alerts.formats.alertUnmit,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_UNMIT_TP),
        function ()
            return unpack(Settings.alerts.colors.alertUnmit)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertUnmit = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertUnmit,
        5,
        nil,
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertUnmit)
        end
    )

    -- Power Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_POWER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_POWER)),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ALERT_POWER_TP),
        function ()
            return Settings.alerts.toggles.showAlertPower
        end,
        function (v)
            Settings.alerts.toggles.showAlertPower = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.showAlertPower
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_POWER_TP),
        function ()
            return Settings.alerts.formats.alertPower
        end,
        function (v)
            Settings.alerts.formats.alertPower = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertPower)
        end,
        Defaults.alerts.formats.alertPower,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_P), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME)),
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_P_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME_TP)),
        function ()
            return Settings.alerts.toggles.mitigationPowerPrefix2
        end,
        function (v)
            Settings.alerts.toggles.mitigationPowerPrefix2 = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertPower)
        end,
        Defaults.alerts.toggles.mitigationPowerPrefix2,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_P), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME)),
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_P_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME_TP)),
        function ()
            return Settings.alerts.toggles.mitigationPowerPrefixN2
        end,
        function (v)
            Settings.alerts.toggles.mitigationPowerPrefixN2 = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertPower)
        end,
        Defaults.alerts.toggles.mitigationPowerPrefixN2,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_POWER_TP),
        function ()
            return unpack(Settings.alerts.colors.alertPower)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertPower = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertPower,
        5,
        nil,
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertPower)
        end
    )

    -- Destroy Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_DESTROY)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_DESTROY)),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ALERT_DESTROY_TP),
        function ()
            return Settings.alerts.toggles.showAlertDestroy
        end,
        function (v)
            Settings.alerts.toggles.showAlertDestroy = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.showAlertDestroy
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_DESTROY_TP),
        function ()
            return Settings.alerts.formats.alertDestroy
        end,
        function (v)
            Settings.alerts.formats.alertDestroy = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertDestroy)
        end,
        Defaults.alerts.formats.alertDestroy,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_D), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME)),
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_D_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME_TP)),
        function ()
            return Settings.alerts.toggles.mitigationDestroyPrefix2
        end,
        function (v)
            Settings.alerts.toggles.mitigationDestroyPrefix2 = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertDestroy)
        end,
        Defaults.alerts.toggles.mitigationDestroyPrefix2,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_D), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME)),
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_D_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME_TP)),
        function ()
            return Settings.alerts.toggles.mitigationDestroyPrefixN2
        end,
        function (v)
            Settings.alerts.toggles.mitigationDestroyPrefixN2 = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertDestroy)
        end,
        Defaults.alerts.toggles.mitigationDestroyPrefixN2,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_DESTROY_TP),
        function ()
            return unpack(Settings.alerts.colors.alertDestroy)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertDestroy = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertDestroy,
        5,
        nil,
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertDestroy)
        end
    )

    -- Summon Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_SUMMON)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_SUMMON)),
        GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ALERT_SUMMON_TP),
        function ()
            return Settings.alerts.toggles.showAlertSummon
        end,
        function (v)
            Settings.alerts.toggles.showAlertSummon = v
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.showAlertSummon
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
        GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_SUMMON_TP),
        function ()
            return Settings.alerts.formats.alertSummon
        end,
        function (v)
            Settings.alerts.formats.alertSummon = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertSummon)
        end,
        Defaults.alerts.formats.alertSummon,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_S), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME)),
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_S_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME_TP)),
        function ()
            return Settings.alerts.toggles.mitigationSummonPrefix2
        end,
        function (v)
            Settings.alerts.toggles.mitigationSummonPrefix2 = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertSummon)
        end,
        Defaults.alerts.toggles.mitigationSummonPrefix2,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedEditboxOption(
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_S), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME)),
        zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_S_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME_TP)),
        function ()
            return Settings.alerts.toggles.mitigationSummonPrefixN2
        end,
        function (v)
            Settings.alerts.toggles.mitigationSummonPrefixN2 = v
        end,
        "full",
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertSummon)
        end,
        Defaults.alerts.toggles.mitigationSummonPrefixN2,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
        GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_SUMMON_TP),
        function ()
            return unpack(Settings.alerts.colors.alertSummon)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.alertSummon = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.alertSummon,
        5,
        nil,
        function ()
            return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertSummon)
        end
    )

    -- CC Colors Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_HEADER_CC_COLOR)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STUN),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STUN_TP),
        function ()
            return unpack(Settings.alerts.colors.stunColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.stunColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.stunColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_KNOCKBACK),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_KNOCKBACK_TP),
        function ()
            return unpack(Settings.alerts.colors.knockbackColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.knockbackColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.knockbackColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_LEVITATE),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_LEVITATE_TP),
        function ()
            return unpack(Settings.alerts.colors.levitateColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.levitateColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.levitateColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_DISORIENT),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_DISORIENT_TP),
        function ()
            return unpack(Settings.alerts.colors.disorientColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.disorientColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.disorientColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_FEAR),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_FEAR_TP),
        function ()
            return unpack(Settings.alerts.colors.fearColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.fearColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.fearColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_CHARM),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_CHARM_TP),
        function ()
            return unpack(Settings.alerts.colors.charmColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.charmColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.charmColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SILENCE),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SILENCE_TP),
        function ()
            return unpack(Settings.alerts.colors.silenceColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.silenceColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.silenceColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STAGGER),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STAGGER_TP),
        function ()
            return unpack(Settings.alerts.colors.staggerColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.staggerColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.staggerColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_UNBREAKABLE),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_UNBREAKABLE_TP),
        function ()
            return unpack(Settings.alerts.colors.unbreakableColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.unbreakableColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.unbreakableColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SNARE),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SNARE_TP),
        function ()
            return unpack(Settings.alerts.colors.snareColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.snareColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.snareColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_ROOT),
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_ROOT_TP),
        function ()
            return unpack(Settings.alerts.colors.rootColor)
        end,
        function (r, g, b, a)
            Settings.alerts.colors.rootColor = { r, g, b, a }
            AbilityAlerts.SetAlertColors()
        end,
        Defaults.alerts.colors.rootColor,
        nil,
        function ()
            return not Settings.alerts.toggles.alertEnable
        end
    )

    -- Sounds Header
    -- NOTE: Sounds section has many options (AOE, POWER ATTACK, RADIAL AVOID, GROUND TRAVEL, etc.)
    -- Due to file size, adding key sound options. Full conversion can be completed if needed.
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_VOLUME),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_VOLUME_TP),
        1, 5, 1,
        function ()
            return Settings.alerts.toggles.soundVolume
        end,
        function (value)
            Settings.alerts.toggles.soundVolume = value
        end,
        "full",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.soundVolume
    )

    -- Sound Options - Single Target
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_TP),
        function ()
            return Settings.alerts.toggles.sound_stEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_stEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_stEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_st
        end,
        function (value)
            Settings.alerts.sounds.sound_st = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_stEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - Single Target CC
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_CC),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_CC_TP),
        function ()
            return Settings.alerts.toggles.sound_st_ccEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_st_ccEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_st_ccEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_st_cc
        end,
        function (value)
            Settings.alerts.sounds.sound_st_cc = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_st_ccEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - AOE
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_AOE),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_AOE_TP),
        function ()
            return Settings.alerts.toggles.sound_aoeEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_aoeEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_aoeEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_aoe
        end,
        function (value)
            Settings.alerts.sounds.sound_aoe = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_aoeEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - AOE CC
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_AOE_CC),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_AOE_CC_TP),
        function ()
            return Settings.alerts.toggles.sound_aoe_ccEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_aoe_ccEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_aoe_ccEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_aoe_cc
        end,
        function (value)
            Settings.alerts.sounds.sound_aoe_cc = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_aoe_ccEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - POWER ATTACK
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_POWER_ATTACK),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_POWER_ATTACK_TP),
        function ()
            return Settings.alerts.toggles.sound_powerattackEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_powerattackEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_powerattackEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_powerattack
        end,
        function (value)
            Settings.alerts.sounds.sound_powerattack = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_powerattackEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - RADIAL AVOID
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_RADIAL_AVOID),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_RADIAL_AVOID_TP),
        function ()
            return Settings.alerts.toggles.sound_radialEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_radialEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_radialEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_radial
        end,
        function (value)
            Settings.alerts.sounds.sound_radial = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_radialEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - GROUND TRAVEL
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TRAVEL),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TRAVEL_TP),
        function ()
            return Settings.alerts.toggles.sound_travelEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_travelEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_travelEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_travel
        end,
        function (value)
            Settings.alerts.sounds.sound_travel = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_travelEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - GROUND TRAVEL CC
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TRAVEL_CC),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TRAVEL_CC_TP),
        function ()
            return Settings.alerts.toggles.sound_travel_ccEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_travel_ccEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_travel_ccEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_travel_cc
        end,
        function (value)
            Settings.alerts.sounds.sound_travel_cc = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_travel_ccEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - GROUND
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TP),
        function ()
            return Settings.alerts.toggles.sound_groundEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_groundEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_groundEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_ground
        end,
        function (value)
            Settings.alerts.sounds.sound_ground = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_groundEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - METEOR
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_METEOR),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_METEOR_TP),
        function ()
            return Settings.alerts.toggles.sound_meteorEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_meteorEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_meteorEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_meteor
        end,
        function (value)
            Settings.alerts.sounds.sound_meteor = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_meteorEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - UNMIT ST
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_UNMIT),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_UNMIT_TP),
        function ()
            return Settings.alerts.toggles.sound_unmit_stEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_unmit_stEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_unmit_stEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_unmit_st
        end,
        function (value)
            Settings.alerts.sounds.sound_unmit_st = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_unmit_stEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - UNMIT AOE
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_UNMIT_AOE),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_UNMIT_AOE_TP),
        function ()
            return Settings.alerts.toggles.sound_unmit_aoeEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_unmit_aoeEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_unmit_aoeEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_unmit_aoe
        end,
        function (value)
            Settings.alerts.sounds.sound_unmit_aoe = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_unmit_aoeEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - POWER DAMAGE
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_POWER_DAMAGE),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_POWER_DAMAGE_TP),
        function ()
            return Settings.alerts.toggles.sound_power_damageEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_power_damageEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_power_damageEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_power_damage
        end,
        function (value)
            Settings.alerts.sounds.sound_power_damage = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_power_damageEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - POWER DEFENSE
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_POWER_DEFENSE),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_POWER_DEFENSE_TP),
        function ()
            return Settings.alerts.toggles.sound_power_buffEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_power_buffEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_power_buffEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_power_buff
        end,
        function (value)
            Settings.alerts.sounds.sound_power_buff = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_power_buffEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - SUMMON
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_SUMMON),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_SUMMON_TP),
        function ()
            return Settings.alerts.toggles.sound_summonEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_summonEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_summonEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_summon
        end,
        function (value)
            Settings.alerts.sounds.sound_summon = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_summonEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - DESTROY
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_DESTROY),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_DESTROY_TP),
        function ()
            return Settings.alerts.toggles.sound_destroyEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_destroyEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_destroyEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_destroy
        end,
        function (value)
            Settings.alerts.sounds.sound_destroy = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_destroyEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Sound Options - HEAL
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_HEAL),
        GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_HEAL_TP),
        function ()
            return Settings.alerts.toggles.sound_healEnable
        end,
        function (v)
            Settings.alerts.toggles.sound_healEnable = v
        end,
        "half",
        function ()
            return not Settings.alerts.toggles.alertEnable
        end,
        Defaults.alerts.toggles.sound_healEnable
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.alerts.sounds.sound_heal
        end,
        function (value)
            Settings.alerts.sounds.sound_heal = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        "full",
        function ()
            return not (Settings.alerts.toggles.sound_healEnable and Settings.alerts.toggles.alertEnable)
        end
    )

    -- Crowd Control Tracker Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_CCT_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CI_CCT_DESCRIPTION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_UNLOCK),
        GetString(LUIE_STRING_LAM_CI_CCT_UNLOCK_TP),
        function ()
            return Settings.cct.unlock
        end,
        function (newValue)
            Settings.cct.unlock = newValue
            if newValue then
                CrowdControlTracker:SetupDisplay("draw")
            end
            CrowdControlTracker:InitControls()
        end,
        "half",
        nil,
        Defaults.cct.unlock
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RESETPOSITION),
        GetString(LUIE_STRING_LAM_CI_CCT_RESET_TP),
        CrowdControlTracker.ResetPosition,
        "half",
        nil,
        GetString(LUIE_STRING_LAM_RESETPOSITION)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_TOGGLE),
        GetString(LUIE_STRING_LAM_CI_CCT_TOGGLE_TP),
        function ()
            return Settings.cct.enabled
        end,
        function (newValue)
            Settings.cct.enabled = newValue
            CrowdControlTracker:OnOff()
        end,
        "full",
        nil,
        Defaults.cct.enabled
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_PVP_ONLY),
        GetString(LUIE_STRING_LAM_CI_CCT_PVP_ONLY_TP),
        function ()
            return Settings.cct.enabledOnlyInCyro
        end,
        function (newValue)
            Settings.cct.enabledOnlyInCyro = newValue
            CrowdControlTracker:OnOff()
        end,
        "full",
        function ()
            return not Settings.cct.enabled
        end,
        Defaults.cct.enabledOnlyInCyro,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_STYLE),
        GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_STYLE_TP),
        function ()
            local items =
            {
                { name = "Display: Icon & Text", data = "Display: Icon & Text" },
                { name = "Display: Icon",        data = "Display: Icon"        },
                { name = "Display: Text",        data = "Display: Text"        }
            }
            return items
        end,
        function ()
            if Settings.cct.showOptions == "all" then
                return "Display: Icon & Text"
            elseif Settings.cct.showOptions == "icon" then
                return "Display: Icon"
            elseif Settings.cct.showOptions == "text" then
                return "Display: Text"
            end
        end,
        function (combobox, value, item)
            if value == "Display: Icon & Text" then
                Settings.cct.showOptions = "all"
            elseif value == "Display: Icon" then
                Settings.cct.showOptions = "icon"
            elseif value == "Display: Text" then
                Settings.cct.showOptions = "text"
            end
            CrowdControlTracker:InitControls()
        end,
        "Display: Icon & Text",
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_NAME),
        GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_NAME_TP),
        function ()
            return Settings.cct.useAbilityName
        end,
        function (newValue)
            Settings.cct.useAbilityName = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return (not Settings.cct.enabled) or (Settings.cct.showOptions == "icon")
        end,
        Defaults.cct.useAbilityName
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_TP),
        function ()
            return Settings.cct.useDefaultIcon
        end,
        function (newValue)
            Settings.cct.useDefaultIcon = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return (not Settings.cct.enabled) or (Settings.cct.showOptions == "icon")
        end,
        Defaults.cct.useDefaultIcon
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS),
        GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS_TP),
        function ()
            local items = {}
            for i, option in ipairs(globalIconOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return globalIconOptions[Settings.cct.defaultIconOptions]
        end,
        function (combobox, value, item)
            Settings.cct.defaultIconOptions = globalIconOptionsKeys[value]
            CrowdControlTracker:InitControls()
        end,
        5,
        nil,
        function ()
            return not Settings.cct.useDefaultIcon
        end,
        globalIconOptions[Defaults.cct.defaultIconOptions]
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_CI_CCT_SCALE),
        GetString(LUIE_STRING_LAM_CI_CCT_SCALE_TP),
        20, 200, 1,
        function ()
            return tonumber(string_format("%.0f", 100 * Settings.cct.controlScale))
        end,
        function (newValue)
            Settings.cct.controlScale = newValue / 100
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not Settings.cct.enabled
        end,
        tonumber(string_format("%.0f", 100 * Defaults.cct.controlScale))
    )

    -- CCT Misc Options Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_CCT_MISC_OPTIONS_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_SOUND),
        GetString(LUIE_STRING_LAM_CI_CCT_SOUND_TP),
        function ()
            return Settings.cct.playSound
        end,
        function (newValue)
            Settings.cct.playSound = newValue
            CrowdControlTracker:InitControls()
        end,
        "half",
        function ()
            return not Settings.cct.enabled
        end,
        Defaults.cct.playSound
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.cct.playSoundOption
        end,
        function (value)
            Settings.cct.playSoundOption = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        nil,
        function ()
            return not (Settings.cct.playSound and Settings.cct.enabled)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_STAGGER),
        GetString(LUIE_STRING_LAM_CI_CCT_STAGGER_TP),
        function ()
            return Settings.cct.showStaggered
        end,
        function (newValue)
            Settings.cct.showStaggered = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not Settings.cct.enabled
        end,
        Defaults.cct.showStaggered
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_GCD_TOGGLE),
        GetString(LUIE_STRING_LAM_CI_CCT_GCD_TOGGLE_TP),
        function ()
            return Settings.cct.showGCD
        end,
        function (newValue)
            Settings.cct.showGCD = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not Settings.cct.enabled
        end,
        Defaults.cct.showGCD
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_TOGGLE),
        GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_TOGGLE_TP),
        function ()
            return Settings.cct.showImmune
        end,
        function (newValue)
            Settings.cct.showImmune = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not Settings.cct.enabled
        end,
        Defaults.cct.showImmune
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_CYRODIIL),
        GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_CYRODIIL_TP),
        function ()
            return Settings.cct.showImmuneOnlyInCyro
        end,
        function (newValue)
            Settings.cct.showImmuneOnlyInCyro = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not (Settings.cct.showImmune and Settings.cct.enabled)
        end,
        Defaults.cct.showImmuneOnlyInCyro,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_TIME),
        GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_TIME_TP),
        100, 1500, 1,
        function ()
            return Settings.cct.immuneDisplayTime
        end,
        function (newValue)
            Settings.cct.immuneDisplayTime = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not (Settings.cct.showImmune and Settings.cct.enabled)
        end,
        Defaults.cct.immuneDisplayTime,
        5
    )

    -- CCT CC Colors Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_HEADER_CC_COLOR)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STUN),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STUN)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_STUNNED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_STUNNED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_STUNNED],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_KNOCKBACK),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_KNOCKBACK)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_KNOCKBACK])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_KNOCKBACK] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_KNOCKBACK],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_LEVITATE),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_LEVITATE)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_LEVITATED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_LEVITATED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_LEVITATED],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_DISORIENT),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_DISORIENT)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_DISORIENTED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_DISORIENTED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_DISORIENTED],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SILENCE),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SILENCE)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_SILENCED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_SILENCED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_SILENCED],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_FEAR),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_FEAR)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_FEARED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_FEARED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_FEARED],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_CHARM),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_CHARM)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_CHARMED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_CHARMED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_CHARMED],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STAGGER),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STAGGER)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_STAGGERED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_STAGGERED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_STAGGERED],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_UNBREAKABLE),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_UNBREAKABLE)),
        function ()
            return unpack(Settings.cct.colors.unbreakable)
        end,
        function (r, g, b, a)
            Settings.cct.colors.unbreakable = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors.unbreakable,
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_IMMUNE])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_IMMUNE] = { r, g, b, a }
            Settings.cct.colors[ACTION_RESULT_DODGED] = { r, g, b, a }
            Settings.cct.colors[ACTION_RESULT_BLOCKED] = { r, g, b, a }
            Settings.cct.colors[ACTION_RESULT_BLOCKED_DAMAGE] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_IMMUNE],
        nil,
        function ()
            return not Settings.cct.enabled
        end
    )

    -- CCT Root Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_CCT_ROOT_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_ROOT_TOGGLE),
        GetString(LUIE_STRING_LAM_CI_CCT_ROOT_TOGGLE_TP),
        function ()
            return Settings.cct.showRoot
        end,
        function (newValue)
            Settings.cct.showRoot = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not Settings.cct.enabled
        end,
        Defaults.cct.showRoot
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_CCT_ROOT_COLOR),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_ROOT)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_ROOTED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_ROOTED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_ROOTED],
        5,
        nil,
        function ()
            return not (Settings.cct.showRoot and Settings.cct.enabled)
        end
    )

    -- CCT AOE Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_CCT_AOE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_AOE_TOGGLE),
        GetString(LUIE_STRING_LAM_CI_CCT_AOE_TOGGLE_TP),
        function ()
            return Settings.cct.showAoe
        end,
        function (newValue)
            Settings.cct.showAoe = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not Settings.cct.enabled
        end,
        Defaults.cct.showAoe
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CT_CCT_AOE_COLOR),
        GetString(LUIE_STRING_LAM_CT_CCT_AOE_COLOR_TP),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_AREA_EFFECT])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_AREA_EFFECT] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_AREA_EFFECT],
        5,
        nil,
        function ()
            return not (Settings.cct.showAoe and Settings.cct.enabled)
        end
    )

    -- CCT Snare Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_CCT_SNARE_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_CCT_SNARE_TOGGLE),
        GetString(LUIE_STRING_LAM_CI_CCT_SNARE_TOGGLE_TP),
        function ()
            return Settings.cct.showSnare
        end,
        function (newValue)
            Settings.cct.showSnare = newValue
            CrowdControlTracker:InitControls()
        end,
        "full",
        function ()
            return not Settings.cct.enabled
        end,
        Defaults.cct.showSnare
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        GetString(LUIE_STRING_LAM_CI_CCT_SNARE_COLOR),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SNARE)),
        function ()
            return unpack(Settings.cct.colors[ACTION_RESULT_SNARED])
        end,
        function (r, g, b, a)
            Settings.cct.colors[ACTION_RESULT_SNARED] = { r, g, b, a }
            CrowdControlTracker:InitControls()
        end,
        Defaults.cct.colors[ACTION_RESULT_SNARED],
        5,
        nil,
        function ()
            return not (Settings.cct.showSnare and Settings.cct.enabled)
        end
    )

    -- CCT Shared Options Header (AOE Display Options)
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_CI_ALERT_HEADER_SHARED)
    )

    -- AOE Display Options - Player Ultimate
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_ULT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_ULT)),
        function ()
            return Settings.cct.aoePlayerUltimate
        end,
        function (newValue)
            Settings.cct.aoePlayerUltimate = newValue
            CrowdControlTracker.UpdateAOEList()
        end,
        "full",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.enabled)
        end,
        Defaults.cct.aoePlayerUltimate
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_ULT)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_ULT)),
        function ()
            return Settings.cct.aoePlayerUltimateSoundToggle
        end,
        function (newValue)
            Settings.cct.aoePlayerUltimateSoundToggle = newValue
        end,
        "half",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoePlayerUltimate and Settings.cct.enabled)
        end,
        Defaults.cct.aoePlayerUltimateSoundToggle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.cct.aoePlayerUltimateSound
        end,
        function (value)
            Settings.cct.aoePlayerUltimateSound = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        nil,
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoePlayerUltimate and Settings.cct.aoePlayerUltimateSoundToggle and Settings.cct.enabled)
        end
    )

    -- AOE Display Options - Player Normal
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_NORM)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_NORM)),
        function ()
            return Settings.cct.aoePlayerNormal
        end,
        function (newValue)
            Settings.cct.aoePlayerNormal = newValue
            CrowdControlTracker.UpdateAOEList()
        end,
        "full",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.enabled)
        end,
        Defaults.cct.aoePlayerNormal
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_NORM)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_NORM)),
        function ()
            return Settings.cct.aoePlayerNormalSoundToggle
        end,
        function (newValue)
            Settings.cct.aoePlayerNormalSoundToggle = newValue
        end,
        "half",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoePlayerNormal and Settings.cct.enabled)
        end,
        Defaults.cct.aoePlayerNormalSoundToggle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.cct.aoePlayerNormalSound
        end,
        function (value)
            Settings.cct.aoePlayerNormalSound = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        nil,
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoePlayerNormal and Settings.cct.aoePlayerNormalSoundToggle and Settings.cct.enabled)
        end
    )

    -- AOE Display Options - Player Set
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_SET)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_SET)),
        function ()
            return Settings.cct.aoePlayerSet
        end,
        function (newValue)
            Settings.cct.aoePlayerSet = newValue
            CrowdControlTracker.UpdateAOEList()
        end,
        "full",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.enabled)
        end,
        Defaults.cct.aoePlayerSet
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_SET)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_SET)),
        function ()
            return Settings.cct.aoePlayerSetSoundToggle
        end,
        function (newValue)
            Settings.cct.aoePlayerSetSoundToggle = newValue
        end,
        "half",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoePlayerSet and Settings.cct.enabled)
        end,
        Defaults.cct.aoePlayerSetSoundToggle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.cct.aoePlayerSetSound
        end,
        function (value)
            Settings.cct.aoePlayerSetSound = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        nil,
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoePlayerSet and Settings.cct.aoePlayerSetSoundToggle and Settings.cct.enabled)
        end
    )

    -- AOE Display Options - Trap
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_TRAP)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_TRAP)),
        function ()
            return Settings.cct.aoeTraps
        end,
        function (newValue)
            Settings.cct.aoeTraps = newValue
            CrowdControlTracker.UpdateAOEList()
        end,
        "full",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.enabled)
        end,
        Defaults.cct.aoeTraps
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_TRAP)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_TRAP)),
        function ()
            return Settings.cct.aoeTrapsSoundToggle
        end,
        function (newValue)
            Settings.cct.aoeTrapsSoundToggle = newValue
        end,
        "half",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoeTraps and Settings.cct.enabled)
        end,
        Defaults.cct.aoeTrapsSoundToggle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.cct.aoeTrapsSound
        end,
        function (value)
            Settings.cct.aoeTrapsSound = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        nil,
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoeTraps and Settings.cct.aoeTrapsSoundToggle and Settings.cct.enabled)
        end
    )

    -- AOE Display Options - NPC Boss
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_BOSS)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_BOSS)),
        function ()
            return Settings.cct.aoeNPCBoss
        end,
        function (newValue)
            Settings.cct.aoeNPCBoss = newValue
            CrowdControlTracker.UpdateAOEList()
        end,
        "full",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.enabled)
        end,
        Defaults.cct.aoeNPCBoss
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_BOSS)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_BOSS)),
        function ()
            return Settings.cct.aoeNPCBossSoundToggle
        end,
        function (newValue)
            Settings.cct.aoeNPCBossSoundToggle = newValue
        end,
        "half",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoeNPCBoss and Settings.cct.enabled)
        end,
        Defaults.cct.aoeNPCBossSoundToggle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.cct.aoeNPCBossSound
        end,
        function (value)
            Settings.cct.aoeNPCBossSound = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        nil,
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoeNPCBoss and Settings.cct.aoeNPCBossSoundToggle and Settings.cct.enabled)
        end
    )

    -- AOE Display Options - NPC Elite
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_ELITE)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_ELITE)),
        function ()
            return Settings.cct.aoeNPCElite
        end,
        function (newValue)
            Settings.cct.aoeNPCElite = newValue
            CrowdControlTracker.UpdateAOEList()
        end,
        "full",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.enabled)
        end,
        Defaults.cct.aoeNPCElite
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_ELITE)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_ELITE)),
        function ()
            return Settings.cct.aoeNPCEliteSoundToggle
        end,
        function (newValue)
            Settings.cct.aoeNPCEliteSoundToggle = newValue
        end,
        "half",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoeNPCElite and Settings.cct.enabled)
        end,
        Defaults.cct.aoeNPCEliteSoundToggle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.cct.aoeNPCEliteSound
        end,
        function (value)
            Settings.cct.aoeNPCEliteSound = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        nil,
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoeNPCElite and Settings.cct.aoeNPCEliteSoundToggle and Settings.cct.enabled)
        end
    )

    -- AOE Display Options - NPC Normal
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_NORMAL)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_NORMAL)),
        function ()
            return Settings.cct.aoeNPCNormal
        end,
        function (newValue)
            Settings.cct.aoeNPCNormal = newValue
            CrowdControlTracker.UpdateAOEList()
        end,
        "full",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.enabled)
        end,
        Defaults.cct.aoeNPCNormal
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_NORMAL)),
        zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_NORMAL)),
        function ()
            return Settings.cct.aoeNPCNormalSoundToggle
        end,
        function (newValue)
            Settings.cct.aoeNPCNormalSoundToggle = newValue
        end,
        "half",
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoeNPCNormal and Settings.cct.enabled)
        end,
        Defaults.cct.aoeNPCNormalSoundToggle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdown(
        "",
        nil,
        SettingsAPI.GetSoundsList(),
        function ()
            return Settings.cct.aoeNPCNormalSound
        end,
        function (value)
            Settings.cct.aoeNPCNormalSound = value
            AbilityAlerts.PreviewAlertSound(value)
        end,
        5,
        nil,
        function ()
            return not (Settings.cct.showAoe and Settings.cct.aoeNPCNormal and Settings.cct.aoeNPCNormalSoundToggle and Settings.cct.enabled)
        end
    )

    -- Synergy Tracker Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Synergy Tracker"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        "Track and display multiple available synergies simultaneously. Set custom priorities and manage synergy preferences."
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Unlock Synergy Display",
        "Unlock the synergy display to reposition it. Preview synergies will be shown while unlocked.",
        function ()
            return Settings.synergy.unlocked
        end,
        function (value)
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                tracker:SetUnlocked(value)
            end
        end,
        "half",
        function ()
            return not Settings.synergy.enabled
        end,
        false
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        "Reset Position",
        "Reset the synergy display to default position.",
        function ()
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                tracker:ResetPosition()
            end
        end,
        "half",
        function ()
            return not Settings.synergy.enabled
        end,
        "Reset Position"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Enable Synergy Tracker",
        "Enable the synergy tracking system. This will monitor available synergies and allow you to set priority overrides. Changes require a UI reload (/reloadui).",
        function ()
            return Settings.synergy.enabled
        end,
        function (value)
            Settings.synergy.enabled = value
        end,
        "full",
        nil,
        Defaults.synergy.enabled
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Display Options"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        "Display Mode",
        "Single: Show only highest priority synergy (like default UI)\nMulti: Show all available synergies\nCompact: Show all synergies with short names",
        function ()
            return
            {
                { name = "Single Synergy",        data = "Single Synergy"        },
                { name = "Multi-Synergy",         data = "Multi-Synergy"         },
                { name = "Compact Multi-Synergy", data = "Compact Multi-Synergy" }
            }
        end,
        function ()
            if Settings.synergy.displayMode == "single" then
                return "Single Synergy"
            elseif Settings.synergy.displayMode == "compact" then
                return "Compact Multi-Synergy"
            else
                return "Multi-Synergy"
            end
        end,
        function (combobox, value, item)
            if value == "Single Synergy" then
                Settings.synergy.displayMode = "single"
            elseif value == "Compact Multi-Synergy" then
                Settings.synergy.displayMode = "compact"
            else
                Settings.synergy.displayMode = "multi"
            end
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                tracker:UpdateDisplay()
            end
        end,
        "Multi-Synergy",
        function ()
            return not Settings.synergy.enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        "Maximum Synergies to Display",
        "Maximum number of synergies to show simultaneously (1-10). Includes both active and cooldown synergies.",
        1, 10, 1,
        function ()
            return Settings.synergy.maxDisplay
        end,
        function (value)
            Settings.synergy.maxDisplay = value
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                tracker:UpdateDisplay()
            end
        end,
        "full",
        function ()
            return not Settings.synergy.enabled or Settings.synergy.displayMode == "single"
        end,
        Defaults.synergy.maxDisplay,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        "Show Priority Numbers",
        "Display priority numbers next to each synergy.",
        function ()
            return Settings.synergy.showPriority
        end,
        function (value)
            Settings.synergy.showPriority = value
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                tracker:UpdateDisplayOptions()
            end
        end,
        "full",
        function ()
            return not Settings.synergy.enabled
        end,
        Defaults.synergy.showPriority,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        "Show Position Numbers",
        "Display position numbers (1-5) next to each synergy to show its order in the list.",
        function ()
            return Settings.synergy.showKeybinds
        end,
        function (value)
            Settings.synergy.showKeybinds = value
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                tracker:UpdateDisplayOptions()
            end
        end,
        "full",
        function ()
            return not Settings.synergy.enabled
        end,
        Defaults.synergy.showKeybinds,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        "Play Sound on New Synergy",
        "Play a sound notification when a new synergy becomes available.",
        function ()
            return Settings.synergy.playSound
        end,
        function (value)
            Settings.synergy.playSound = value
        end,
        "full",
        function ()
            return not Settings.synergy.enabled
        end,
        Defaults.synergy.playSound,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        "Show Synergies on Cooldown",
        "Display synergies that are currently on cooldown. The tracker automatically learns which synergies share cooldowns by detecting when multiple synergies go on cooldown together.",
        function ()
            return Settings.synergy.showCooldowns
        end,
        function (value)
            Settings.synergy.showCooldowns = value
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                if not value then
                    tracker.synergyCooldowns = {}
                end
                tracker:UpdateDisplay()
            end
        end,
        "full",
        function ()
            return not Settings.synergy.enabled or Settings.synergy.displayMode == "single"
        end,
        Defaults.synergy.showCooldowns,
        5
    )

    -- Detected Synergies & Priority Overrides Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Detected Synergies & Priority Overrides"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        "Synergies detected during gameplay will appear below. Each synergy has a checkbox to blacklist (hide) it and a slider to set custom priority (0 = game default, 1-10 = higher priority)."
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        "Clear All Priority Overrides",
        "Remove all custom priority overrides and reset to game defaults.",
        function ()
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                tracker:ClearAllPriorityOverrides()
            end
        end,
        "half",
        function ()
            return not Settings.synergy.enabled
        end,
        "Clear All Priority Overrides"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        "Clear Blacklist",
        "Remove all synergies from the blacklist.",
        function ()
            Settings.synergy.blacklist = {}
            local tracker = CombatInfo.SynergyTrackerInstance
            if tracker then
                tracker:RefreshActiveSynergies()
            end
            LUIE.PrintToChat("Blacklist cleared. Refresh settings to see changes.", true)
        end,
        "half",
        function ()
            return not Settings.synergy.enabled
        end,
        "Clear Blacklist"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        "Refresh List",
        "Refresh the list of detected synergies. Close and reopen settings to see updated list.",
        function ()
            LUIE.PrintToChat("Refresh settings menu to see updated synergy list.", true)
        end,
        "half",
        function ()
            return not Settings.synergy.enabled
        end,
        "Refresh List"
    )

    -- NOTE: Dynamic synergy list generation (detected synergies) is handled after panel registration in PC version
    -- This would need to be implemented separately if needed, as it dynamically adds options based on detected synergies

    -- Add all settings to the panel
    panel:AddSettings(settingsData)

    -- Dynamically add detected synergies to the settings menu (if tracker exists)
    local tracker = CombatInfo.SynergyTrackerInstance
    local detectedList = tracker and tracker:GetDetectedSynergiesSorted() or {}
    if #detectedList > 0 then
        local dynamicSettings = {}
        for _, synergyData in ipairs(detectedList) do
            local abilityId = synergyData.abilityId
            local name = synergyData.name
            local icon = synergyData.icon
            local timesSeen = synergyData.timesSeen

            -- Synergy description with icon and name
            dynamicSettings[#dynamicSettings + 1] = SettingsAPI.CreateDescriptionOption(
                zo_iconTextFormat(icon, 32, 32, " " .. zo_strformat("<<C:1>>", name) .. string_format(" |cAAAAAA(Seen: %d times)|r", timesSeen), true, true)
            )

            -- Blacklist toggle
            dynamicSettings[#dynamicSettings + 1] = SettingsAPI.CreateIndentedCheckboxOption(
                "Blacklist (Hide)",
                string_format("Hide this synergy from the tracker. Ability ID: [%d]", abilityId),
                function ()
                    return Settings.synergy.blacklist[abilityId] or false
                end,
                function (value)
                    Settings.synergy.blacklist[abilityId] = value or nil
                    if tracker then
                        tracker:RefreshActiveSynergies()
                    end
                end,
                "full",
                function ()
                    return not Settings.synergy.enabled
                end,
                false,
                5
            )

            -- Priority slider
            dynamicSettings[#dynamicSettings + 1] = SettingsAPI.CreateIndentedSliderOption(
                "Priority Override",
                string_format("Set priority for %s. Higher values = higher priority. 0 = game default.", name),
                0, 10, 1,
                function ()
                    return Settings.synergy.priorityOverrides[abilityId] or 0
                end,
                function (value)
                    if value > 0 then
                        Settings.synergy.priorityOverrides[abilityId] = value
                        SetSynergyPriorityOverride(abilityId, value)
                    else
                        Settings.synergy.priorityOverrides[abilityId] = nil
                        ClearSynergyPriorityOverride(abilityId)
                    end
                end,
                "full",
                function ()
                    return not Settings.synergy.enabled or (Settings.synergy.blacklist[abilityId] == true)
                end,
                0,
                5
            )
        end

        -- Add dynamic settings to panel
        if #dynamicSettings > 0 then
            panel:AddSettings(dynamicSettings)
        end
    end
end
