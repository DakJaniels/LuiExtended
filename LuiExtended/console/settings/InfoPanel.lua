--- @diagnostic disable: missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) LUIE.InfoPanel
local InfoPanel = LUIE.InfoPanel

local zo_strformat = zo_strformat
local GetString = GetString
local ipairs = ipairs

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

    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_PNL),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset InfoPanel settings to defaults
                                        InfoPanel.ResetPosition()
                                    end
                                })

    -- Info Panel description
    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_PNL_DESCRIPTION)
        })

    -- ReloadUI Button
    panel:AddSetting(
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RELOADUI),
            tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
            buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
            clickHandler = function ()
                SettingsAPI:ReloadUIWithPendingClear()
            end
        })

    panel:AddSetting(SettingsAPI:ConsoleFontDeferLabelSetting())

    -- Unlock InfoPanel
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_UNLOCKPANEL),
            tooltip = GetString(LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP),
            getFunction = function ()
                return InfoPanel.panelUnlocked
            end,
            setFunction = function (value)
                InfoPanel.SetMovingState(value)
            end,
            default = false,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Reset panel position
    panel:AddSetting(
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_PNL_RESETPOSITION_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = InfoPanel.ResetPosition,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Position X (center) — bounds from GuiRoot for 4K support
    local gw = GuiRoot:GetWidth()
    local gh = GuiRoot:GetHeight()
    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X_TP),
            min = -gw,
            max = gw,
            step = 10,
            getFunction = function ()
                local x, _ = InfoPanel.GetPanelPosition()
                return x
            end,
            setFunction = function (value)
                local pos = InfoPanel.SV.position or { 0, 0 }
                InfoPanel.SV.position = { value, pos[2] }
                InfoPanel.ApplyPanelPosition()
            end,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Position Y (center)
    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y_TP),
            min = -gh,
            max = gh,
            step = 10,
            getFunction = function ()
                local _, y = InfoPanel.GetPanelPosition()
                return y
            end,
            setFunction = function (value)
                local pos = InfoPanel.SV.position or { 0, 0 }
                InfoPanel.SV.position = { pos[1], value }
                InfoPanel.ApplyPanelPosition()
            end,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- InfoPanel scale
    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_PNL_PANELSCALE),
            tooltip = GetString(LUIE_STRING_LAM_PNL_PANELSCALE_TP),
            min = 100,
            max = 300,
            step = 10,
            format = "%.0f",
            getFunction = function ()
                return Settings.panelScale
            end,
            setFunction = function (value)
                Settings.panelScale = value
                InfoPanel.SetScale()
            end,
            default = 100,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- InfoPanel transparency
    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_PNL_TRANSPARENCY),
            tooltip = GetString(LUIE_STRING_LAM_PNL_TRANSPARENCY_TP),
            min = 0,
            max = 100,
            step = 5,
            format = "%.0f",
            getFunction = function ()
                return Settings.transparency
            end,
            setFunction = function (value)
                Settings.transparency = value
                InfoPanel.ApplyTransparency()
            end,
            default = 100,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Reset InfoPanel position
    panel:AddSetting(
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_PNL_RESETPOSITION_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = InfoPanel.ResetPosition
        })

    -- Font Options Header
    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_FONT)
        })

    -- Font Face Dropdown - Get items list from SettingsAPI
    local fontItems = SettingsAPI:GetFontsList()

    panel:AddSetting(SettingsAPI:ConsoleFontDeferLabelSetting())

    panel:AddSetting(
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_FONT),
            items = fontItems,
            getFunction = function ()
                return Settings.FontFace
            end,
            setFunction = function (combobox, value, item)
                Settings.FontFace = item.data
                SettingsAPI:MarkFontDeferred("infoPanel")
            end,
            default = Defaults.FontFace,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Font Size Slider
    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_FONT_SIZE),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.FontSize
            end,
            setFunction = function (value)
                Settings.FontSize = value
                SettingsAPI:MarkFontDeferred("infoPanel")
            end,
            default = Defaults.FontSize,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Font Style Dropdown - Build items from LUIE.FONT_STYLE_CHOICES
    local fontStyleItems = {}
    for i, choice in ipairs(LUIE.FONT_STYLE_CHOICES) do
        fontStyleItems[i] = { name = choice, data = LUIE.FONT_STYLE_CHOICES_VALUES[i] }
    end
    table.sort(fontStyleItems, function (a, b) return a.name < b.name end)

    panel:AddSetting(
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_STYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                -- Convert value to display name
                local value = Settings.FontStyle
                for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
                    if choiceValue == value then
                        return LUIE.FONT_STYLE_CHOICES[i]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (combobox, value, item)
                Settings.FontStyle = item.data
                SettingsAPI:MarkFontDeferred("infoPanel")
            end,
            default = Defaults.FontStyle,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Info Panel Options Header
    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_PNL_HEADER)
        })

    -- Elements Header
    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_PNL_ELEMENTS_HEADER)
        })

    -- Show Latency
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWLATENCY),
            getFunction = function ()
                return not Settings.HideLatency
            end,
            setFunction = function (value)
                Settings.HideLatency = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Show Clock
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWCLOCK),
            getFunction = function ()
                return not Settings.HideClock
            end,
            setFunction = function (value)
                Settings.HideClock = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Clock Format (indented)
    panel:AddSetting(
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_PNL_CLOCKFORMAT), -- Add indent with spaces
            tooltip = GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP),
            getFunction = function ()
                return Settings.ClockFormat
            end,
            setFunction = function (value)
                Settings.ClockFormat = value
                InfoPanel.RefreshClockMeterUpdateInterval()
                InfoPanel.RearrangePanel(true)
            end,
            default = Defaults.ClockFormat,
            disable = function ()
                return not (LUIE.SV.InfoPanel_Enabled and not Settings.HideClock)
            end
        })

    -- Show FPS
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWFPS),
            getFunction = function ()
                return not Settings.HideFPS
            end,
            setFunction = function (value)
                Settings.HideFPS = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Show Memory
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWMEMORY),
            tooltip = GetString(LUIE_STRING_LAM_PNL_SHOWMEMORY_TP),
            getFunction = function ()
                return not Settings.HideMemory
            end,
            setFunction = function (value)
                Settings.HideMemory = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Show Mount Timer
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER),
            tooltip = GetString(LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP),
            getFunction = function ()
                return not Settings.HideMountFeed
            end,
            setFunction = function (value)
                Settings.HideMountFeed = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Show Armor Durability
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY),
            getFunction = function ()
                return not Settings.HideArmour
            end,
            setFunction = function (value)
                Settings.HideArmour = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Show Weapon Charges
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES),
            getFunction = function ()
                return not Settings.HideWeapons
            end,
            setFunction = function (value)
                Settings.HideWeapons = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Show Bag Space
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWBAGSPACE),
            getFunction = function ()
                return not Settings.HideBags
            end,
            setFunction = function (value)
                Settings.HideBags = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Show Soul Gems
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_SHOWSOULGEMS),
            getFunction = function ()
                return not Settings.HideGems
            end,
            setFunction = function (value)
                Settings.HideGems = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Show Gold
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_PNL_SHOWGOLD),
            getFunction = function ()
                return not Settings.HideGold
            end,
            setFunction = function (value)
                Settings.HideGold = not value
                InfoPanel.RearrangePanel(true)
            end,
            default = true,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Misc Header
    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(SI_PLAYER_MENU_MISC)
        })

    -- Display on World Map
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP),
            tooltip = GetString(LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP),
            getFunction = function ()
                return Settings.DisplayOnWorldMap
            end,
            setFunction = function (value)
                Settings.DisplayOnWorldMap = value
                InfoPanel.SetDisplayOnMap()
            end,
            default = false,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })

    -- Hide Info Panel in combat
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_HIDEINCOMBAT),
            tooltip = GetString(LUIE_STRING_LAM_PNL_HIDEINCOMBAT_TP),
            getFunction = function ()
                return Settings.HideInCombat
            end,
            setFunction = function (value)
                Settings.HideInCombat = value
                if not value then
                    InfoPanel.CancelCombatHideAndShow()
                else
                    InfoPanel.OnPlayerCombatState(IsUnitInCombat("player"))
                end
            end,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end,
            default = Defaults.HideInCombat,
        })

    -- Disable Info Colors
    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_PNL_DISABLECOLORSRO),
            tooltip = GetString(LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP),
            getFunction = function ()
                return Settings.DisableInfoColours
            end,
            setFunction = function (value)
                Settings.DisableInfoColours = value
            end,
            default = false,
            disable = function ()
                return not LUIE.SV.InfoPanel_Enabled
            end
        })
end
