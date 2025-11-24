-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.InfoPanel
local InfoPanel = LUIE.InfoPanel

local zo_strformat = zo_strformat

-- Load Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

-- Create Settings Menu
function InfoPanel.CreateConsoleSettings()
    local Defaults = InfoPanel.Defaults
    local Settings = InfoPanel.SV

    -- Register the settings panel
    if not LUIE.SV.InfoPanel_Enabled then
        return
    end

    local panel = LHAS:AddAddon(zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_PNL)),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset InfoPanel settings to defaults
                                        InfoPanel.ResetPosition()
                                    end,
                                    allowRefresh = true
                                })

    -- Info Panel description
    panel:AddSetting(SettingsAPI.CreateDescriptionOption(
        {
            text = GetString(LUIE_STRING_LAM_PNL_DESCRIPTION),
        }))

    -- ReloadUI Button
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_RELOADUI),
            tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
            clickHandler = function ()
                ReloadUI("ingame")
            end,
            buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        }))

    -- Unlock InfoPanel
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_UNLOCKPANEL),
            tooltip = GetString(LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP),
            getFunc = function ()
                return InfoPanel.panelUnlocked
            end,
            setFunc = function (value)
                InfoPanel.SetMovingState(value)
            end,
            default = false,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- InfoPanel scale
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_PANELSCALE),
            tooltip = GetString(LUIE_STRING_LAM_PNL_PANELSCALE_TP),
            min = 100,
            max = 300,
            step = 10,
            getFunc = function ()
                return Settings.panelScale
            end,
            setFunc = function (value)
                Settings.panelScale = value
                InfoPanel.SetScale()
            end,
            default = 100,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- InfoPanel transparency
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_TRANSPARENCY),
            tooltip = GetString(LUIE_STRING_LAM_PNL_TRANSPARENCY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunc = function ()
                return Settings.transparency
            end,
            setFunc = function (value)
                Settings.transparency = value
                InfoPanel.ApplyTransparency()
            end,
            default = 100,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Reset InfoPanel position
    panel:AddSetting(SettingsAPI.CreateButtonOption(
        {
            name = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_PNL_RESETPOSITION_TP),
            clickHandler = InfoPanel.ResetPosition,
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
        }))

    -- Font Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_FONT),
        }))

    -- Font Face Dropdown
    panel:AddSetting(SettingsAPI.CreateDropdownOption(
        {
            name = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_FONT),
            choices = SettingsAPI.GetFontsList(),
            getFunc = function ()
                return Settings.FontFace
            end,
            setFunc = function (value)
                Settings.FontFace = value
                InfoPanel.ApplyFont()
            end,
            default = Defaults.FontFace,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Font Size Slider
    panel:AddSetting(SettingsAPI.CreateSliderOption(
        {
            name = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_FONT_SIZE),
            min = 10,
            max = 30,
            step = 1,
            getFunc = function ()
                return Settings.FontSize
            end,
            setFunc = function (value)
                Settings.FontSize = value
                InfoPanel.ApplyFont()
            end,
            default = Defaults.FontSize,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Font Style Dropdown
    panel:AddSetting(SettingsAPI.CreateFontStyleDropdown(
        {
            name = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_STYLE_TP),
            getFunc = function ()
                return Settings.FontStyle
            end,
            setFunc = function (value)
                Settings.FontStyle = value
                InfoPanel.ApplyFont()
            end,
            default = Defaults.FontStyle,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Info Panel Options Submenu
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_HEADER),
        }))

    -- Elements Header
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_ELEMENTS_HEADER),
        }))

    -- Show Latency
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_SHOWLATENCY),
            getFunc = function ()
                return not Settings.HideLatency
            end,
            setFunc = function (value)
                Settings.HideLatency = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Show Clock
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_SHOWCLOCK),
            getFunc = function ()
                return not Settings.HideClock
            end,
            setFunc = function (value)
                Settings.HideClock = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Clock Format (indented)
    panel:AddSetting(SettingsAPI.CreateEditboxOption(
        {
            name = SettingsAPI.AddIndent(GetString(LUIE_STRING_LAM_PNL_CLOCKFORMAT)),
            tooltip = GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP),
            getFunc = function ()
                return Settings.ClockFormat
            end,
            setFunc = function (value)
                Settings.ClockFormat = value
                InfoPanel.RearrangePanel()
            end,
            default = Defaults.ClockFormat,
            disabled = function ()
                return not (LUIE.SV.InfoPanel_Enabled and not Settings.HideClock)
            end,
        }))

    -- Show FPS
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_SHOWFPS),
            getFunc = function ()
                return not Settings.HideFPS
            end,
            setFunc = function (value)
                Settings.HideFPS = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Show Mount Timer
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER),
            tooltip = GetString(LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP),
            getFunc = function ()
                return not Settings.HideMountFeed
            end,
            setFunc = function (value)
                Settings.HideMountFeed = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Show Armor Durability
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY),
            getFunc = function ()
                return not Settings.HideArmour
            end,
            setFunc = function (value)
                Settings.HideArmour = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Show Weapon Charges
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES),
            getFunc = function ()
                return not Settings.HideWeapons
            end,
            setFunc = function (value)
                Settings.HideWeapons = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Show Bag Space
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_SHOWBAGSPACE),
            getFunc = function ()
                return not Settings.HideBags
            end,
            setFunc = function (value)
                Settings.HideBags = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Show Soul Gems
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_SHOWSOULGEMS),
            getFunc = function ()
                return not Settings.HideGems
            end,
            setFunc = function (value)
                Settings.HideGems = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Show Gold
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_PNL_SHOWGOLD),
            getFunc = function ()
                return not Settings.HideGold
            end,
            setFunc = function (value)
                Settings.HideGold = not value
                InfoPanel.RearrangePanel()
            end,
            default = true,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Misc Header
    panel:AddSetting(SettingsAPI.CreateHeaderOption(
        {
            name = GetString(SI_PLAYER_MENU_MISC),
        }))

    -- Display on World Map
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP),
            tooltip = GetString(LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP),
            getFunc = function ()
                return Settings.DisplayOnWorldMap
            end,
            setFunc = function (value)
                Settings.DisplayOnWorldMap = value
                InfoPanel.SetDisplayOnMap()
            end,
            default = false,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))

    -- Disable Info Colors
    panel:AddSetting(SettingsAPI.CreateCheckboxOption(
        {
            name = GetString(LUIE_STRING_LAM_PNL_DISABLECOLORSRO),
            tooltip = GetString(LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP),
            getFunc = function ()
                return Settings.DisableInfoColours
            end,
            setFunc = function (value)
                Settings.DisableInfoColours = value
            end,
            default = false,
            disabled = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
        }))
end
