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
local Block = CombatInfo.Block


local type, pairs = type, pairs
local zo_strformat = zo_strformat
local string_format = string.format

local ACTION_RESULT_AREA_EFFECT = 669966

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

function CombatInfo.CreateConsoleSettings()
    local Defaults = CombatInfo.Defaults
    local Settings = CombatInfo.SV

    -- Register the settings panel
    if not LUIE.SV.CombatInfo_Enabled then
        return
    end

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_CI),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset all CombatInfo settings to defaults
                                        CombatInfo:ResetToDefaults()
                                    end
                                })

    -- Get media lists from SettingsAPI
    local fontItems = SettingsAPI:GetFontsList()
    local soundItems = SettingsAPI:GetSoundsList()

    -- Build font style list once for reuse
    local fontStyleItems = {}
    for i, styleName in ipairs(LUIE.FONT_STYLE_CHOICES) do
        fontStyleItems[i] = { name = styleName, data = LUIE.FONT_STYLE_CHOICES_VALUES[i] }
    end

    -- Collect initial settings for main menu
    local initialSettings = {}

    -- Combat Info Description
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_CI_DESCRIPTION)
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

    local sectionGroups = {}

    -- Helper function to build section settings
    local function buildSectionSettings(sectionName, settingsBuilder)
        local sectionSettings = {}
        settingsBuilder(sectionSettings)
        sectionGroups[sectionName] = sectionSettings
    end

    -- Build Floating Markers Section
    buildSectionSettings("FloatingMarkers", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_FLOATING_MARKERS_DESC),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER),
            tooltip = GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER_TP),
            getFunction = function ()
                return Settings.showMarker
            end,
            setFunction = function (value)
                Settings.showMarker = value
                CombatInfo.SetMarker(true)
            end,
            default = Settings.showMarker
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER_SIZE),
            min = 10,
            max = 90,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.markerSize or 26
            end,
            setFunction = function (value)
                Settings.markerSize = value
                CombatInfo.SetMarker()
            end,
            default = 26
        }
    end)

    -- Build Active Combat Alerts Section
    buildSectionSettings("ActiveCombatAlerts", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_HEADER_ACTIVE_COMBAT_ALERT),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_DESCRIPTION)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_UNLOCK),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_UNLOCK_TP),
            getFunction = function ()
                return CombatInfo.AbilityAlerts.AlertFrameUnlocked
            end,
            setFunction = AbilityAlerts.SetMovingStateAlert,
            disable = function ()
                return not LUIE.SV.CombatInfo_Enabled
            end,
            default = false
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_RESET_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = AbilityAlerts.ResetAlertFramePosition,
            disable = function ()
                return not LUIE.SV.CombatInfo_Enabled
            end
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
                if CombatInfo.SV.AlertFrameOffsetX ~= nil then
                    return CombatInfo.SV.AlertFrameOffsetX
                end
                local f = CombatInfo.AbilityAlerts and CombatInfo.AbilityAlerts.uiTlw and CombatInfo.AbilityAlerts.uiTlw.alertFrame
                return (f and f.GetLeft) and f:GetLeft() or 0
            end,
            setFunction = function (value)
                CombatInfo.SV.AlertFrameOffsetX = value
                if CombatInfo.SV.AlertFrameOffsetY == nil then
                    local f = CombatInfo.AbilityAlerts and CombatInfo.AbilityAlerts.uiTlw and CombatInfo.AbilityAlerts.uiTlw.alertFrame
                    CombatInfo.SV.AlertFrameOffsetY = (f and f.GetTop) and f:GetTop() or 0
                end
                AbilityAlerts.SetAlertFramePosition()
            end,
            disable = function () return not LUIE.SV.CombatInfo_Enabled end,
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
                if CombatInfo.SV.AlertFrameOffsetY ~= nil then
                    return CombatInfo.SV.AlertFrameOffsetY
                end
                local f = CombatInfo.AbilityAlerts and CombatInfo.AbilityAlerts.uiTlw and CombatInfo.AbilityAlerts.uiTlw.alertFrame
                return (f and f.GetTop) and f:GetTop() or 0
            end,
            setFunction = function (value)
                if CombatInfo.SV.AlertFrameOffsetX == nil then
                    local f = CombatInfo.AbilityAlerts and CombatInfo.AbilityAlerts.uiTlw and CombatInfo.AbilityAlerts.uiTlw.alertFrame
                    CombatInfo.SV.AlertFrameOffsetX = (f and f.GetLeft) and f:GetLeft() or 0
                end
                CombatInfo.SV.AlertFrameOffsetY = value
                AbilityAlerts.SetAlertFramePosition()
            end,
            disable = function () return not LUIE.SV.CombatInfo_Enabled end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_TOGGLE_TP),
            getFunction = function ()
                return Settings.alerts.toggles.alertEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.alertEnable = v
            end,
            default = Defaults.alerts.toggles.alertEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_FONTFACE_TP),
            items = fontItems,
            getFunction = function ()
                return Settings.alerts.toggles.alertFontFace
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.toggles.alertFontFace = item.data
                SettingsAPI:MarkFontDeferred("combatInfo")
                AbilityAlerts.ResetAlertSize()
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.alertFontFace
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_FONTSIZE_TP),
            min = 16,
            max = 64,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.alerts.toggles.alertFontSize
            end,
            setFunction = function (value)
                Settings.alerts.toggles.alertFontSize = value
                SettingsAPI:MarkFontDeferred("combatInfo")
                AbilityAlerts.ResetAlertSize()
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.alertFontSize
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_FONTSTYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                local value = Settings.alerts.toggles.alertFontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.toggles.alertFontStyle = item.data
                SettingsAPI:MarkFontDeferred("combatInfo")
                AbilityAlerts.ResetAlertSize()
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.alertFontStyle
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_TIMER_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_TIMER_TOGGLE_TP),
            getFunction = function ()
                return Settings.alerts.toggles.alertTimer
            end,
            setFunction = function (v)
                Settings.alerts.toggles.alertTimer = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.alertTimer
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_TIMER_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_TIMER_COLOR_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertTimer[1], Settings.alerts.colors.alertTimer[2], Settings.alerts.colors.alertTimer[3], Settings.alerts.colors.alertTimer[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertTimer = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertTimer,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.alertTimer)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_COLOR_BASE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_COLOR_BASE_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertShared[1], Settings.alerts.colors.alertShared[2], Settings.alerts.colors.alertShared[3], Settings.alerts.colors.alertShared[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertShared = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertShared,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        -- Shared Options Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_HEADER_SHARED)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_RANK3),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_RANK3_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationRank3
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationRank3 = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.mitigationRank3
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_RANK2),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_RANK2_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationRank2
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationRank2 = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.mitigationRank2
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_RANK1),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_RANK1_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationRank1
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationRank1 = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.mitigationRank1
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_AURA),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_AURA_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationAura
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationAura = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable or not (Settings.alerts.toggles.mitigationRank1 or Settings.alerts.toggles.mitigationRank2 or Settings.alerts.toggles.mitigationRank3)
            end,
            default = Defaults.alerts.toggles.mitigationAura
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_DUNGEON),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_DUNGEON_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationDungeon
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationDungeon = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable or not (Settings.alerts.toggles.mitigationRank1 or Settings.alerts.toggles.mitigationRank2 or Settings.alerts.toggles.mitigationRank3)
            end,
            default = Defaults.alerts.toggles.mitigationDungeon
        }

        -- Mitigation Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_DESCRIPTION)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_ENABLE_TP),
            getFunction = function ()
                return Settings.alerts.toggles.showAlertMitigate
            end,
            setFunction = function (v)
                Settings.alerts.toggles.showAlertMitigate = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.showAlertMitigate
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FILTER),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FILTER_TP),
            items = SettingsAPI:GetGlobalAlertOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeGlobalAlertOptionIndex(Settings.alerts.toggles.alertOptions, Defaults.alerts.toggles.alertOptions))
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.toggles.alertOptions = item.data
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.alerts.toggles.alertOptions)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_SUFFIX),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_SUFFIX_TP),
            getFunction = function ()
                return Settings.alerts.toggles.showMitigation
            end,
            setFunction = function (v)
                Settings.alerts.toggles.showMitigation = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
            end,
            default = Defaults.alerts.toggles.showMitigation
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_ABILITY),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_ABILITY_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationAbilityName
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationAbilityName = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
            end,
            default = Defaults.alerts.toggles.mitigationAbilityName
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_NAME),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_NAME_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationEnemyName
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationEnemyName = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
            end,
            default = Defaults.alerts.toggles.mitigationEnemyName
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_BORDER),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_BORDER_TP),
            getFunction = function ()
                return Settings.alerts.toggles.showCrowdControlBorder
            end,
            setFunction = function (v)
                Settings.alerts.toggles.showCrowdControlBorder = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
            end,
            default = Defaults.alerts.toggles.showCrowdControlBorder
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_LABEL_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_LABEL_COLOR_TP),
            getFunction = function ()
                return Settings.alerts.toggles.ccLabelColor
            end,
            setFunction = function (v)
                Settings.alerts.toggles.ccLabelColor = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
            end,
            default = Defaults.alerts.toggles.ccLabelColor
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_ALERT_TP),
            getFunction = function ()
                return Settings.alerts.toggles.useDefaultIcon
            end,
            setFunction = function (newValue)
                Settings.alerts.toggles.useDefaultIcon = newValue
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
            end,
            default = Defaults.alerts.toggles.useDefaultIcon
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_ALLOW_MODIFIER),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_ALLOW_MODIFIER_TP),
            getFunction = function ()
                return Settings.alerts.toggles.modifierEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.modifierEnable = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable)
            end,
            default = Defaults.alerts.toggles.modifierEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MODIFIER_DIRECT),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MODIFIER_DIRECT_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationModifierOnYou
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationModifierOnYou = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.modifierEnable)
            end,
            default = Defaults.alerts.toggles.mitigationModifierOnYou
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_MODIFIER_SPREAD),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_MODIFIER_SPREAD_TP),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationModifierSpreadOut
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationModifierSpreadOut = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.showAlertMitigate and Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.modifierEnable)
            end,
            default = Defaults.alerts.toggles.mitigationModifierSpreadOut
        }

        -- Block Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_BLOCK)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_BLOCK)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_BLOCK_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertBlock
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertBlock = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.formats.alertBlock
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_BLOCK_S)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_BLOCK_S_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertBlockStagger
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertBlockStagger = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.formats.alertBlockStagger
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_BLOCK_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertBlockA[1], Settings.alerts.colors.alertBlockA[2], Settings.alerts.colors.alertBlockA[3], Settings.alerts.colors.alertBlockA[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertBlockA = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertBlockA,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        -- Dodge Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_DODGE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_DODGE_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertDodge
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertDodge = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.formats.alertDodge
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_DODGE_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertDodgeA[1], Settings.alerts.colors.alertDodgeA[2], Settings.alerts.colors.alertDodgeA[3], Settings.alerts.colors.alertDodgeA[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertDodgeA = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertDodgeA,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        -- Avoid Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_AVOID)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_AVOID_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertAvoid
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertAvoid = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.formats.alertAvoid
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_AVOID_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertAvoidB[1], Settings.alerts.colors.alertAvoidB[2], Settings.alerts.colors.alertAvoidB[3], Settings.alerts.colors.alertAvoidB[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertAvoidB = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertAvoidB,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        -- Interrupt Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_INTERRUPT)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_INTERRUPT_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertInterrupt
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertInterrupt = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.formats.alertInterrupt
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_SHOULDUSECC),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_SHOULDUSECC_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertShouldUseCC
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertShouldUseCC = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.formats.alertShouldUseCC
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_INTERRUPT_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertInterruptC[1], Settings.alerts.colors.alertInterruptC[2], Settings.alerts.colors.alertInterruptC[3], Settings.alerts.colors.alertInterruptC[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertInterruptC = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertInterruptC,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        -- Unmit Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_UNMIT)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_UNMIT)),
            tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ALERT_UNMIT_TP),
            getFunction = function ()
                return Settings.alerts.toggles.showAlertUnmit
            end,
            setFunction = function (v)
                Settings.alerts.toggles.showAlertUnmit = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.showAlertUnmit
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_UNMIT_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertUnmit
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertUnmit = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertUnmit)
            end,
            default = Defaults.alerts.formats.alertUnmit
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_UNMIT_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertUnmit[1], Settings.alerts.colors.alertUnmit[2], Settings.alerts.colors.alertUnmit[3], Settings.alerts.colors.alertUnmit[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertUnmit = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertUnmit,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertUnmit)
            end
        }

        -- Power Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_POWER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_POWER)),
            tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ALERT_POWER_TP),
            getFunction = function ()
                return Settings.alerts.toggles.showAlertPower
            end,
            setFunction = function (v)
                Settings.alerts.toggles.showAlertPower = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.showAlertPower
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_POWER_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertPower
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertPower = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertPower)
            end,
            default = Defaults.alerts.formats.alertPower
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_P), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME)),
            tooltip = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_P_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME_TP)),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationPowerPrefix2
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationPowerPrefix2 = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertPower)
            end,
            default = Defaults.alerts.toggles.mitigationPowerPrefix2
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_P), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME)),
            tooltip = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_P_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME_TP)),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationPowerPrefixN2
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationPowerPrefixN2 = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertPower)
            end,
            default = Defaults.alerts.toggles.mitigationPowerPrefixN2
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_POWER_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertPower[1], Settings.alerts.colors.alertPower[2], Settings.alerts.colors.alertPower[3], Settings.alerts.colors.alertPower[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertPower = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertPower,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertPower)
            end
        }

        -- Destroy Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_DESTROY)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_DESTROY)),
            tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ALERT_DESTROY_TP),
            getFunction = function ()
                return Settings.alerts.toggles.showAlertDestroy
            end,
            setFunction = function (v)
                Settings.alerts.toggles.showAlertDestroy = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.showAlertDestroy
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_DESTROY_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertDestroy
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertDestroy = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertDestroy)
            end,
            default = Defaults.alerts.formats.alertDestroy
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_D), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME)),
            tooltip = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_D_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME_TP)),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationDestroyPrefix2
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationDestroyPrefix2 = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertDestroy)
            end,
            default = Defaults.alerts.toggles.mitigationDestroyPrefix2
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_D), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME)),
            tooltip = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_D_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME_TP)),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationDestroyPrefixN2
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationDestroyPrefixN2 = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertDestroy)
            end,
            default = Defaults.alerts.toggles.mitigationDestroyPrefixN2
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_DESTROY_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertDestroy[1], Settings.alerts.colors.alertDestroy[2], Settings.alerts.colors.alertDestroy[3], Settings.alerts.colors.alertDestroy[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertDestroy = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertDestroy,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertDestroy)
            end
        }

        -- Summon Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_SUMMON)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ALERT_SUMMON)),
            tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ALERT_SUMMON_TP),
            getFunction = function ()
                return Settings.alerts.toggles.showAlertSummon
            end,
            setFunction = function (v)
                Settings.alerts.toggles.showAlertSummon = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.showAlertSummon
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_SUMMON_TP),
            getFunction = function ()
                return Settings.alerts.formats.alertSummon
            end,
            setFunction = function (v)
                Settings.alerts.formats.alertSummon = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertSummon)
            end,
            default = Defaults.alerts.formats.alertSummon
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_S), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME)),
            tooltip = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_S_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NO_NAME_TP)),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationSummonPrefix2
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationSummonPrefix2 = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertSummon)
            end,
            default = Defaults.alerts.toggles.mitigationSummonPrefix2
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_S), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME)),
            tooltip = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_FORMAT_S_TP), GetString(LUIE_STRING_LAM_CI_ALERT_MITIGATION_NAME_TP)),
            getFunction = function ()
                return Settings.alerts.toggles.mitigationSummonPrefixN2
            end,
            setFunction = function (v)
                Settings.alerts.toggles.mitigationSummonPrefixN2 = v
            end,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertSummon)
            end,
            default = Defaults.alerts.toggles.mitigationSummonPrefixN2
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_SUMMON_TP),
            getFunction = function ()
                return Settings.alerts.colors.alertSummon[1], Settings.alerts.colors.alertSummon[2], Settings.alerts.colors.alertSummon[3], Settings.alerts.colors.alertSummon[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.alertSummon = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.alertSummon,
            disable = function ()
                return not (Settings.alerts.toggles.alertEnable and Settings.alerts.toggles.showAlertSummon)
            end
        }

        -- CC Colors Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_HEADER_CC_COLOR)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STUN),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STUN_TP),
            getFunction = function ()
                return Settings.alerts.colors.stunColor[1], Settings.alerts.colors.stunColor[2], Settings.alerts.colors.stunColor[3], Settings.alerts.colors.stunColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.stunColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.stunColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_KNOCKBACK),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_KNOCKBACK_TP),
            getFunction = function ()
                return Settings.alerts.colors.knockbackColor[1], Settings.alerts.colors.knockbackColor[2], Settings.alerts.colors.knockbackColor[3], Settings.alerts.colors.knockbackColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.knockbackColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.knockbackColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_LEVITATE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_LEVITATE_TP),
            getFunction = function ()
                return Settings.alerts.colors.levitateColor[1], Settings.alerts.colors.levitateColor[2], Settings.alerts.colors.levitateColor[3], Settings.alerts.colors.levitateColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.levitateColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.levitateColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_DISORIENT),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_DISORIENT_TP),
            getFunction = function ()
                return Settings.alerts.colors.disorientColor[1], Settings.alerts.colors.disorientColor[2], Settings.alerts.colors.disorientColor[3], Settings.alerts.colors.disorientColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.disorientColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.disorientColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_FEAR),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_FEAR_TP),
            getFunction = function ()
                return Settings.alerts.colors.fearColor[1], Settings.alerts.colors.fearColor[2], Settings.alerts.colors.fearColor[3], Settings.alerts.colors.fearColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.fearColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.fearColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_CHARM),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_CHARM_TP),
            getFunction = function ()
                return Settings.alerts.colors.charmColor[1], Settings.alerts.colors.charmColor[2], Settings.alerts.colors.charmColor[3], Settings.alerts.colors.charmColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.charmColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.charmColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SILENCE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SILENCE_TP),
            getFunction = function ()
                return Settings.alerts.colors.silenceColor[1], Settings.alerts.colors.silenceColor[2], Settings.alerts.colors.silenceColor[3], Settings.alerts.colors.silenceColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.silenceColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.silenceColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STAGGER),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STAGGER_TP),
            getFunction = function ()
                return Settings.alerts.colors.staggerColor[1], Settings.alerts.colors.staggerColor[2], Settings.alerts.colors.staggerColor[3], Settings.alerts.colors.staggerColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.staggerColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.staggerColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_UNBREAKABLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_UNBREAKABLE_TP),
            getFunction = function ()
                return Settings.alerts.colors.unbreakableColor[1], Settings.alerts.colors.unbreakableColor[2], Settings.alerts.colors.unbreakableColor[3], Settings.alerts.colors.unbreakableColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.unbreakableColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.unbreakableColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SNARE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SNARE_TP),
            getFunction = function ()
                return Settings.alerts.colors.snareColor[1], Settings.alerts.colors.snareColor[2], Settings.alerts.colors.snareColor[3], Settings.alerts.colors.snareColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.snareColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.snareColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_ROOT),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_ROOT_TP),
            getFunction = function ()
                return Settings.alerts.colors.rootColor[1], Settings.alerts.colors.rootColor[2], Settings.alerts.colors.rootColor[3], Settings.alerts.colors.rootColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.alerts.colors.rootColor = { r, g, b, a }
                AbilityAlerts.SetAlertColors()
            end,
            default = Defaults.alerts.colors.rootColor,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end
        }

        -- Sounds Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_VOLUME),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_VOLUME_TP),
            min = 1,
            max = 5,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.alerts.toggles.soundVolume
            end,
            setFunction = function (value)
                Settings.alerts.toggles.soundVolume = value
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.soundVolume
        }

        -- Sound Options - Single Target
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_stEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_stEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_stEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_st
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_st = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_stEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - Single Target CC
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_CC),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_CC_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_st_ccEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_st_ccEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_st_ccEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_st_cc
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_st_cc = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_st_ccEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - AOE
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_AOE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_AOE_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_aoeEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_aoeEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_aoeEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_aoe
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_aoe = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_aoeEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - AOE CC
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_AOE_CC),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_AOE_CC_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_aoe_ccEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_aoe_ccEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_aoe_ccEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_aoe_cc
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_aoe_cc = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_aoe_ccEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - POWER ATTACK
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_POWER_ATTACK),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_POWER_ATTACK_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_powerattackEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_powerattackEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_powerattackEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_powerattack
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_powerattack = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_powerattackEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - RADIAL AVOID
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_RADIAL_AVOID),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_ST_RADIAL_AVOID_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_radialEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_radialEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_radialEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_radial
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_radial = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_radialEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - GROUND TRAVEL
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TRAVEL),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TRAVEL_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_travelEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_travelEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_travelEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_travel
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_travel = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_travelEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - GROUND TRAVEL CC
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TRAVEL_CC),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TRAVEL_CC_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_travel_ccEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_travel_ccEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_travel_ccEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_travel_cc
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_travel_cc = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_travel_ccEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - GROUND
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_GROUND_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_groundEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_groundEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_groundEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_ground
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_ground = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_groundEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - METEOR
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_METEOR),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_METEOR_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_meteorEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_meteorEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_meteorEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_meteor
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_meteor = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_meteorEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - UNMIT ST
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_UNMIT),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_UNMIT_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_unmit_stEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_unmit_stEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_unmit_stEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_unmit_st
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_unmit_st = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_unmit_stEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - UNMIT AOE
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_UNMIT_AOE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_UNMIT_AOE_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_unmit_aoeEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_unmit_aoeEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_unmit_aoeEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_unmit_aoe
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_unmit_aoe = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_unmit_aoeEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - POWER DAMAGE
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_POWER_DAMAGE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_POWER_DAMAGE_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_power_damageEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_power_damageEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_power_damageEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_power_damage
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_power_damage = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_power_damageEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - POWER DEFENSE
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_POWER_DEFENSE),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_POWER_DEFENSE_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_power_buffEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_power_buffEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_power_buffEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_power_buff
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_power_buff = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_power_buffEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - SUMMON
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_SUMMON),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_SUMMON_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_summonEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_summonEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_summonEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_summon
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_summon = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_summonEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - DESTROY
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_DESTROY),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_DESTROY_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_destroyEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_destroyEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_destroyEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_destroy
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_destroy = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_destroyEnable and Settings.alerts.toggles.alertEnable)
            end
        }

        -- Sound Options - HEAL
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_HEAL),
            tooltip = GetString(LUIE_STRING_LAM_CI_ALERT_SOUND_HEAL_TP),
            getFunction = function ()
                return Settings.alerts.toggles.sound_healEnable
            end,
            setFunction = function (v)
                Settings.alerts.toggles.sound_healEnable = v
            end,
            disable = function ()
                return not Settings.alerts.toggles.alertEnable
            end,
            default = Defaults.alerts.toggles.sound_healEnable
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.alerts.sounds.sound_heal
            end,
            setFunction = function (combobox, value, item)
                Settings.alerts.sounds.sound_heal = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.alerts.toggles.sound_healEnable and Settings.alerts.toggles.alertEnable)
            end
        }
    end)

    -- Build Crowd Control Tracker Section
    buildSectionSettings("CrowdControlTracker", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_CCT_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DESCRIPTION)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_UNLOCK),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_UNLOCK_TP),
            getFunction = function ()
                return Settings.cct.unlock
            end,
            setFunction = function (v)
                Settings.cct.unlock = v
                if v then
                    CrowdControlTracker:SetupDisplay("draw")
                end
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.unlock
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_RESET_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = CrowdControlTracker.ResetPosition
        }

        local gwCct = GuiRoot:GetWidth()
        local ghCct = GuiRoot:GetHeight()
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X_TP),
            min = -gwCct,
            max = gwCct,
            step = 10,
            getFunction = function ()
                return Settings.cct.offsetX or 0
            end,
            setFunction = function (value)
                Settings.cct.offsetX = value
                if Settings.cct.offsetY == nil then
                    Settings.cct.offsetY = 0
                end
                CrowdControlTracker.ApplyPosition()
            end,
            disable = function () return not Settings.cct.enabled end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y_TP),
            min = -ghCct,
            max = ghCct,
            step = 10,
            getFunction = function ()
                return Settings.cct.offsetY or 0
            end,
            setFunction = function (value)
                if Settings.cct.offsetX == nil then
                    Settings.cct.offsetX = 0
                end
                Settings.cct.offsetY = value
                CrowdControlTracker.ApplyPosition()
            end,
            disable = function () return not Settings.cct.enabled end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_TOGGLE_TP),
            getFunction = function ()
                return Settings.cct.enabled
            end,
            setFunction = function (v)
                Settings.cct.enabled = v
                CrowdControlTracker:OnOff()
            end,
            default = Defaults.cct.enabled
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_PVP_ONLY),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_PVP_ONLY_TP),
            getFunction = function ()
                return Settings.cct.enabledOnlyInCyro
            end,
            setFunction = function (v)
                Settings.cct.enabledOnlyInCyro = v
                CrowdControlTracker:OnOff()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = Defaults.cct.enabledOnlyInCyro
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_HEADER)
        }

        -- Build display style items
        local displayStyleItems =
        {
            { name = GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_ICON_AND_TEXT), data = "all"  },
            { name = GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_ICON_ONLY),     data = "icon" },
            { name = GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_TEXT_ONLY),     data = "text" }
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_STYLE_TP),
            items = displayStyleItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.cct.showOptions)
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.showOptions = item.data
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.cct.showOptions)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_NAME),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DISPLAY_NAME_TP),
            getFunction = function ()
                return Settings.cct.useAbilityName
            end,
            setFunction = function (v)
                Settings.cct.useAbilityName = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return (not Settings.cct.enabled) or (Settings.cct.showOptions == "icon")
            end,
            default = Defaults.cct.useAbilityName
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_TP),
            getFunction = function ()
                return Settings.cct.useDefaultIcon
            end,
            setFunction = function (v)
                Settings.cct.useDefaultIcon = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return (not Settings.cct.enabled) or (Settings.cct.showOptions == "icon")
            end,
            default = Defaults.cct.useDefaultIcon
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS_TP),
            items = SettingsAPI:GetGlobalIconOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeGlobalIconOptionIndex(Settings.cct.defaultIconOptions, Defaults.cct.defaultIconOptions))
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.defaultIconOptions = item.data
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.useDefaultIcon
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.cct.defaultIconOptions)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_CCT_SCALE),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_SCALE_TP),
            min = 20,
            max = 200,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return tonumber(string_format("%.0f", 100 * Settings.cct.controlScale))
            end,
            setFunction = function (v)
                Settings.cct.controlScale = v / 100
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = tonumber(string_format("%.0f", 100 * Defaults.cct.controlScale))
        }

        -- CCT Misc Options Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_CCT_MISC_OPTIONS_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_SOUND),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_SOUND_TP),
            getFunction = function ()
                return Settings.cct.playSound
            end,
            setFunction = function (v)
                Settings.cct.playSound = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = Defaults.cct.playSound
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.cct.playSoundOption
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.playSoundOption = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.cct.playSound and Settings.cct.enabled)
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_STAGGER),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_STAGGER_TP),
            getFunction = function ()
                return Settings.cct.showStaggered
            end,
            setFunction = function (v)
                Settings.cct.showStaggered = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = Defaults.cct.showStaggered
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_GCD_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_GCD_TOGGLE_TP),
            getFunction = function ()
                return Settings.cct.showGCD
            end,
            setFunction = function (v)
                Settings.cct.showGCD = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = Defaults.cct.showGCD
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_TOGGLE_TP),
            getFunction = function ()
                return Settings.cct.showImmune
            end,
            setFunction = function (v)
                Settings.cct.showImmune = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = Defaults.cct.showImmune
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_CYRODIIL),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_CYRODIIL_TP),
            getFunction = function ()
                return Settings.cct.showImmuneOnlyInCyro
            end,
            setFunction = function (v)
                Settings.cct.showImmuneOnlyInCyro = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not (Settings.cct.showImmune and Settings.cct.enabled)
            end,
            default = Defaults.cct.showImmuneOnlyInCyro
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_TIME),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE_TIME_TP),
            min = 100,
            max = 1500,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.cct.immuneDisplayTime
            end,
            setFunction = function (v)
                Settings.cct.immuneDisplayTime = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not (Settings.cct.showImmune and Settings.cct.enabled)
            end,
            default = Defaults.cct.immuneDisplayTime
        }

        -- CCT CC Colors Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_HEADER_CC_COLOR)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STUN),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STUN)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_STUNNED][1], Settings.cct.colors[ACTION_RESULT_STUNNED][2], Settings.cct.colors[ACTION_RESULT_STUNNED][3], Settings.cct.colors[ACTION_RESULT_STUNNED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_STUNNED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_STUNNED],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_KNOCKBACK),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_KNOCKBACK)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_KNOCKBACK][1], Settings.cct.colors[ACTION_RESULT_KNOCKBACK][2], Settings.cct.colors[ACTION_RESULT_KNOCKBACK][3], Settings.cct.colors[ACTION_RESULT_KNOCKBACK][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_KNOCKBACK] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_KNOCKBACK],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_LEVITATE),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_LEVITATE)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_LEVITATED][1], Settings.cct.colors[ACTION_RESULT_LEVITATED][2], Settings.cct.colors[ACTION_RESULT_LEVITATED][3], Settings.cct.colors[ACTION_RESULT_LEVITATED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_LEVITATED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_LEVITATED],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_DISORIENT),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_DISORIENT)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_DISORIENTED][1], Settings.cct.colors[ACTION_RESULT_DISORIENTED][2], Settings.cct.colors[ACTION_RESULT_DISORIENTED][3], Settings.cct.colors[ACTION_RESULT_DISORIENTED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_DISORIENTED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_DISORIENTED],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SILENCE),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SILENCE)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_SILENCED][1], Settings.cct.colors[ACTION_RESULT_SILENCED][2], Settings.cct.colors[ACTION_RESULT_SILENCED][3], Settings.cct.colors[ACTION_RESULT_SILENCED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_SILENCED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_SILENCED],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_FEAR),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_FEAR)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_FEARED][1], Settings.cct.colors[ACTION_RESULT_FEARED][2], Settings.cct.colors[ACTION_RESULT_FEARED][3], Settings.cct.colors[ACTION_RESULT_FEARED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_FEARED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_FEARED],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_CHARM),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_CHARM)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_CHARMED][1], Settings.cct.colors[ACTION_RESULT_CHARMED][2], Settings.cct.colors[ACTION_RESULT_CHARMED][3], Settings.cct.colors[ACTION_RESULT_CHARMED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_CHARMED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_CHARMED],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STAGGER),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_STAGGER)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_STAGGERED][1], Settings.cct.colors[ACTION_RESULT_STAGGERED][2], Settings.cct.colors[ACTION_RESULT_STAGGERED][3], Settings.cct.colors[ACTION_RESULT_STAGGERED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_STAGGERED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_STAGGERED],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_UNBREAKABLE),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_UNBREAKABLE)),
            getFunction = function ()
                return Settings.cct.colors.unbreakable[1], Settings.cct.colors.unbreakable[2], Settings.cct.colors.unbreakable[3], Settings.cct.colors.unbreakable[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors.unbreakable = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors.unbreakable,
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_CCT_IMMUNE)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_IMMUNE][1], Settings.cct.colors[ACTION_RESULT_IMMUNE][2], Settings.cct.colors[ACTION_RESULT_IMMUNE][3], Settings.cct.colors[ACTION_RESULT_IMMUNE][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_IMMUNE] = { r, g, b, a }
                Settings.cct.colors[ACTION_RESULT_DODGED] = { r, g, b, a }
                Settings.cct.colors[ACTION_RESULT_BLOCKED] = { r, g, b, a }
                Settings.cct.colors[ACTION_RESULT_BLOCKED_DAMAGE] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_IMMUNE],
            disable = function ()
                return not Settings.cct.enabled
            end
        }

        -- CCT Root Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_CCT_ROOT_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_ROOT_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_ROOT_TOGGLE_TP),
            getFunction = function ()
                return Settings.cct.showRoot
            end,
            setFunction = function (v)
                Settings.cct.showRoot = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = Defaults.cct.showRoot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_CCT_ROOT_COLOR),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_ROOT)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_ROOTED][1], Settings.cct.colors[ACTION_RESULT_ROOTED][2], Settings.cct.colors[ACTION_RESULT_ROOTED][3], Settings.cct.colors[ACTION_RESULT_ROOTED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_ROOTED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_ROOTED],
            disable = function ()
                return not (Settings.cct.showRoot and Settings.cct.enabled)
            end
        }

        -- CCT AOE Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_CCT_AOE_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_AOE_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_AOE_TOGGLE_TP),
            getFunction = function ()
                return Settings.cct.showAoe
            end,
            setFunction = function (v)
                Settings.cct.showAoe = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = Defaults.cct.showAoe
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_CCT_AOE_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_CCT_AOE_COLOR_TP),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_AREA_EFFECT][1], Settings.cct.colors[ACTION_RESULT_AREA_EFFECT][2], Settings.cct.colors[ACTION_RESULT_AREA_EFFECT][3], Settings.cct.colors[ACTION_RESULT_AREA_EFFECT][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_AREA_EFFECT] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_AREA_EFFECT],
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.enabled)
            end
        }

        -- CCT Snare Header
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_CCT_SNARE_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_SNARE_TOGGLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_SNARE_TOGGLE_TP),
            getFunction = function ()
                return Settings.cct.showSnare
            end,
            setFunction = function (v)
                Settings.cct.showSnare = v
                CrowdControlTracker:InitControls()
            end,
            disable = function ()
                return not Settings.cct.enabled
            end,
            default = Defaults.cct.showSnare
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CI_CCT_SNARE_COLOR),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_COLOR_TP), GetString(LUIE_STRING_LAM_CI_ALERT_CC_COLOR_SNARE)),
            getFunction = function ()
                return Settings.cct.colors[ACTION_RESULT_SNARED][1], Settings.cct.colors[ACTION_RESULT_SNARED][2], Settings.cct.colors[ACTION_RESULT_SNARED][3], Settings.cct.colors[ACTION_RESULT_SNARED][4]
            end,
            setFunction = function (r, g, b, a)
                Settings.cct.colors[ACTION_RESULT_SNARED] = { r, g, b, a }
                CrowdControlTracker:InitControls()
            end,
            default = Defaults.cct.colors[ACTION_RESULT_SNARED],
            disable = function ()
                return not (Settings.cct.showSnare and Settings.cct.enabled)
            end
        }

        -- CCT Shared Options Header (AOE Display Options)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_ALERT_HEADER_SHARED)
        }

        -- AOE Display Options - Player Ultimate
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_ULT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_ULT)),
            getFunction = function ()
                return Settings.cct.aoePlayerUltimate
            end,
            setFunction = function (v)
                Settings.cct.aoePlayerUltimate = v
                CrowdControlTracker.UpdateAOEList()
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoePlayerUltimate
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_ULT)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_ULT)),
            getFunction = function ()
                return Settings.cct.aoePlayerUltimateSoundToggle
            end,
            setFunction = function (v)
                Settings.cct.aoePlayerUltimateSoundToggle = v
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoePlayerUltimate and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoePlayerUltimateSoundToggle
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.cct.aoePlayerUltimateSound
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.aoePlayerUltimateSound = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoePlayerUltimate and Settings.cct.aoePlayerUltimateSoundToggle and Settings.cct.enabled)
            end
        }

        -- AOE Display Options - Player Normal
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_NORM)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_NORM)),
            getFunction = function ()
                return Settings.cct.aoePlayerNormal
            end,
            setFunction = function (v)
                Settings.cct.aoePlayerNormal = v
                CrowdControlTracker.UpdateAOEList()
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoePlayerNormal
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_NORM)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_NORM)),
            getFunction = function ()
                return Settings.cct.aoePlayerNormalSoundToggle
            end,
            setFunction = function (v)
                Settings.cct.aoePlayerNormalSoundToggle = v
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoePlayerNormal and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoePlayerNormalSoundToggle
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.cct.aoePlayerNormalSound
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.aoePlayerNormalSound = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoePlayerNormal and Settings.cct.aoePlayerNormalSoundToggle and Settings.cct.enabled)
            end
        }

        -- AOE Display Options - Player Set
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_SET)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_SET)),
            getFunction = function ()
                return Settings.cct.aoePlayerSet
            end,
            setFunction = function (v)
                Settings.cct.aoePlayerSet = v
                CrowdControlTracker.UpdateAOEList()
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoePlayerSet
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_SET)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_PLAYER_SET)),
            getFunction = function ()
                return Settings.cct.aoePlayerSetSoundToggle
            end,
            setFunction = function (v)
                Settings.cct.aoePlayerSetSoundToggle = v
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoePlayerSet and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoePlayerSetSoundToggle
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.cct.aoePlayerSetSound
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.aoePlayerSetSound = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoePlayerSet and Settings.cct.aoePlayerSetSoundToggle and Settings.cct.enabled)
            end
        }

        -- AOE Display Options - Trap
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_TRAP)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_TRAP)),
            getFunction = function ()
                return Settings.cct.aoeTraps
            end,
            setFunction = function (v)
                Settings.cct.aoeTraps = v
                CrowdControlTracker.UpdateAOEList()
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoeTraps
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_TRAP)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_TRAP)),
            getFunction = function ()
                return Settings.cct.aoeTrapsSoundToggle
            end,
            setFunction = function (v)
                Settings.cct.aoeTrapsSoundToggle = v
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoeTraps and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoeTrapsSoundToggle
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.cct.aoeTrapsSound
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.aoeTrapsSound = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoeTraps and Settings.cct.aoeTrapsSoundToggle and Settings.cct.enabled)
            end
        }

        -- AOE Display Options - NPC Boss
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_BOSS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_BOSS)),
            getFunction = function ()
                return Settings.cct.aoeNPCBoss
            end,
            setFunction = function (v)
                Settings.cct.aoeNPCBoss = v
                CrowdControlTracker.UpdateAOEList()
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoeNPCBoss
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_BOSS)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_BOSS)),
            getFunction = function ()
                return Settings.cct.aoeNPCBossSoundToggle
            end,
            setFunction = function (v)
                Settings.cct.aoeNPCBossSoundToggle = v
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoeNPCBoss and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoeNPCBossSoundToggle
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.cct.aoeNPCBossSound
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.aoeNPCBossSound = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoeNPCBoss and Settings.cct.aoeNPCBossSoundToggle and Settings.cct.enabled)
            end
        }

        -- AOE Display Options - NPC Elite
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_ELITE)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_ELITE)),
            getFunction = function ()
                return Settings.cct.aoeNPCElite
            end,
            setFunction = function (v)
                Settings.cct.aoeNPCElite = v
                CrowdControlTracker.UpdateAOEList()
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoeNPCElite
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_ELITE)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_ELITE)),
            getFunction = function ()
                return Settings.cct.aoeNPCEliteSoundToggle
            end,
            setFunction = function (v)
                Settings.cct.aoeNPCEliteSoundToggle = v
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoeNPCElite and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoeNPCEliteSoundToggle
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.cct.aoeNPCEliteSound
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.aoeNPCEliteSound = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoeNPCElite and Settings.cct.aoeNPCEliteSoundToggle and Settings.cct.enabled)
            end
        }

        -- AOE Display Options - NPC Normal
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_NORMAL)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SHOW_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_NORMAL)),
            getFunction = function ()
                return Settings.cct.aoeNPCNormal
            end,
            setFunction = function (v)
                Settings.cct.aoeNPCNormal = v
                CrowdControlTracker.UpdateAOEList()
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoeNPCNormal
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_NORMAL)),
            tooltip = zo_strformat(GetString(LUIE_STRING_LAM_CI_CCT_AOE_SOUND_TP), GetString(LUIE_STRING_LAM_CI_CCT_AOE_TIER_NPC_NORMAL)),
            getFunction = function ()
                return Settings.cct.aoeNPCNormalSoundToggle
            end,
            setFunction = function (v)
                Settings.cct.aoeNPCNormalSoundToggle = v
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoeNPCNormal and Settings.cct.enabled)
            end,
            default = Defaults.cct.aoeNPCNormalSoundToggle
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = "  ",
            items = soundItems,
            getFunction = function ()
                return Settings.cct.aoeNPCNormalSound
            end,
            setFunction = function (combobox, value, item)
                Settings.cct.aoeNPCNormalSound = item.data
                AbilityAlerts.PreviewAlertSound(item.data)
            end,
            disable = function ()
                return not (Settings.cct.showAoe and Settings.cct.aoeNPCNormal and Settings.cct.aoeNPCNormalSoundToggle and Settings.cct.enabled)
            end
        }
    end)

    -- Build Block Indicator Section
    buildSectionSettings("Block", function (settings)
        settings[#settings + 1] = { type = LHAS.ST_LABEL, label = GetString(LUIE_STRING_LAM_CI_BLOCK_INDICATOR_HEADER) }
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CI_BLOCK_INDICATOR_DESC),
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_BLOCK_ENABLE_CONSOLE),
            tooltip = GetString(LUIE_STRING_LAM_CI_BLOCK_INDICATOR_ENABLE_TP),
            getFunction = function ()
                return Settings.block.enabled
            end,
            setFunction = function (value)
                Settings.block.enabled = value
            end,
            default = Defaults.block.enabled,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_BLOCK_INDICATOR_INTERVAL),
            min = 0,
            max = 100,
            step = 5,
            format = "%.0f",
            getFunction = function ()
                return Settings.block.updateIntervalMs
            end,
            setFunction = function (value)
                Settings.block.updateIntervalMs = value
                Block.RegisterUpdateLoop()
            end,
            default = Defaults.block.updateIntervalMs,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_BLOCK_INDICATOR_REMAINING),
            getFunction = function ()
                return Settings.block.showRemainingBlocks
            end,
            setFunction = function (value)
                Settings.block.showRemainingBlocks = value
                Block.RefreshBlockCost()
            end,
            default = Defaults.block.showRemainingBlocks,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_BLOCK_FONT_FACE),
            items = fontItems,
            getFunction = function ()
                return Settings.block.blockIndicatorFontFace
            end,
            setFunction = function (combobox, value, item)
                Settings.block.blockIndicatorFontFace = value
                SettingsAPI:MarkFontDeferred("combatInfo")
            end,
            default = Defaults.block.blockIndicatorFontFace,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_BLOCK_FONT_STYLE),
            items = fontStyleItems,
            getFunction = function ()
                local value = Settings.block.blockIndicatorFontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.block.blockIndicatorFontStyle = item.data
                SettingsAPI:MarkFontDeferred("combatInfo")
            end,
            default = Defaults.block.blockIndicatorFontStyle,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_BLOCK_INDICATOR_FONT_SIZE),
            min = 10,
            max = 32,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.block.blockIndicatorFontSize
            end,
            setFunction = function (value)
                Settings.block.blockIndicatorFontSize = value
                SettingsAPI:MarkFontDeferred("combatInfo")
            end,
            default = Defaults.block.blockIndicatorFontSize,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_BLOCK_INDICATOR_COLOR_RESOURCE),
            getFunction = function ()
                return Settings.block.colorShieldByResource
            end,
            setFunction = function (value)
                Settings.block.colorShieldByResource = value
                Block.ApplyBlockShieldTexture()
            end,
            default = Defaults.block.colorShieldByResource,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        local gwBlock = GuiRoot:GetWidth()
        local ghBlock = GuiRoot:GetHeight()
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X_TP),
            min = -gwBlock,
            max = gwBlock,
            step = 10,
            format = "%.0f",
            getFunction = function ()
                return (Settings.block.bloodlordEmbracePosition or Defaults.block.bloodlordEmbracePosition).left
            end,
            setFunction = function (value)
                Settings.block.bloodlordEmbracePosition = Settings.block.bloodlordEmbracePosition or { left = Defaults.block.bloodlordEmbracePosition.left, top = Defaults.block.bloodlordEmbracePosition.top }
                Settings.block.bloodlordEmbracePosition.left = value
                Block.ApplyBloodlordEmbracePosition()
            end,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y_TP),
            min = -ghBlock,
            max = ghBlock,
            step = 10,
            format = "%.0f",
            getFunction = function ()
                return (Settings.block.bloodlordEmbracePosition or Defaults.block.bloodlordEmbracePosition).top
            end,
            setFunction = function (value)
                Settings.block.bloodlordEmbracePosition = Settings.block.bloodlordEmbracePosition or
                    {
                        left = Defaults.block.bloodlordEmbracePosition.left,
                        top = Defaults.block.bloodlordEmbracePosition.top
                    }
                Settings.block.bloodlordEmbracePosition.top = value
                Block.ApplyBloodlordEmbracePosition()
            end,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_BLOODLORD_FONT_FACE),
            items = fontItems,
            getFunction = function ()
                return Settings.block.bloodlordEmbraceFontFace
            end,
            setFunction = function (combobox, value, item)
                Settings.block.bloodlordEmbraceFontFace = value
                SettingsAPI:MarkFontDeferred("combatInfo")
            end,
            default = Defaults.block.bloodlordEmbraceFontFace,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_BLOODLORD_FONT_STYLE),
            items = fontStyleItems,
            getFunction = function ()
                local value = Settings.block.bloodlordEmbraceFontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.block.bloodlordEmbraceFontStyle = item.data
                SettingsAPI:MarkFontDeferred("combatInfo")
            end,
            default = Defaults.block.bloodlordEmbraceFontStyle,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_BLOODLORD_TITLE_FONT),
            min = 8,
            max = 24,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.block.bloodlordEmbraceTitleSize
            end,
            setFunction = function (value)
                Settings.block.bloodlordEmbraceTitleSize = value
                SettingsAPI:MarkFontDeferred("combatInfo")
            end,
            default = Defaults.block.bloodlordEmbraceTitleSize,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CI_BLOODLORD_VALUE_FONT),
            min = 8,
            max = 24,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.block.bloodlordEmbraceValueSize
            end,
            setFunction = function (value)
                Settings.block.bloodlordEmbraceValueSize = value
                SettingsAPI:MarkFontDeferred("combatInfo")
            end,
            default = Defaults.block.bloodlordEmbraceValueSize,
            disable = function ()
                return not Settings.block.enabled
            end,
        }
    end)

    local allSettings = {}
    SettingsAPI:AppendSettingsList(allSettings, initialSettings)
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CI_ENEMY_MARKER_HEADER), sectionGroups["FloatingMarkers"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CI_HEADER_ACTIVE_COMBAT_ALERT), sectionGroups["ActiveCombatAlerts"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CI_CCT_HEADER), sectionGroups["CrowdControlTracker"])
    SettingsAPI:AppendSection(allSettings, "Block Indicator", sectionGroups["Block"])
    panel:AddSettings(allSettings)
end
