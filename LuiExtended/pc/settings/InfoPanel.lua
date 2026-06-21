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
local SettingsAPI = LUIE.SettingsAPI

-- Load LibAddonMenu
local LAM = LUIE.LAM

-- Create Settings Menu
function InfoPanel.CreateSettings()
    local Defaults = InfoPanel.Defaults
    local Settings = InfoPanel.SV


    if not LUIE.SV.InfoPanel_Enabled then
        return
    end

    local panelDataInfoPanel =
    {
        type = "panel",
        name = LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_PNL),
        displayName = LUIE.FormatAddonSettingsPanelDisplayName(LUIE_STRING_LAM_PNL),
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luiip",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsDataInfoPanel = {}

    -- Info Panel description
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_PNL_DESCRIPTION)
    )

    -- ReloadUI Button
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function () ReloadUI("ingame") end
    )

    -- Unlock InfoPanel
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_UNLOCKPANEL),
        GetString(LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP),
        function () return InfoPanel.panelUnlocked end,
        InfoPanel.SetMovingState,
        "half",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        false,
        nil,
        nil,
        InfoPanel.ResetPosition
    )

    -- InfoPanel scale
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_PNL_PANELSCALE),
        GetString(LUIE_STRING_LAM_PNL_PANELSCALE_TP),
        100,
        300,
        10,
        function () return Settings.panelScale end,
        function (value)
            Settings.panelScale = value
            InfoPanel.SetScale()
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        100
    )

    -- InfoPanel transparency
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_PNL_TRANSPARENCY),
        GetString(LUIE_STRING_LAM_PNL_TRANSPARENCY_TP),
        0,
        100,
        5,
        function () return Settings.transparency end,
        function (value)
            Settings.transparency = value
            InfoPanel.ApplyTransparency()
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        100
    )

    -- Reset InfoPanel position
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RESETPOSITION),
        GetString(LUIE_STRING_LAM_PNL_RESETPOSITION_TP),
        InfoPanel.ResetPosition,
        "half"
    )

    -- Font Options Submenu
    local fontSubmenuControls = {}

    -- Font Face Dropdown
    fontSubmenuControls[#fontSubmenuControls + 1] = SettingsAPI.CreateFontDropdown(
        GetString(LUIE_STRING_LAM_FONT),
        GetString(LUIE_STRING_LAM_FONT),
        function () return Settings.FontFace end,
        function (var)
            Settings.FontFace = var
            InfoPanel.ApplyFont()
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        Defaults.FontFace,
        nil,
        "name-up",
        function () return Settings.FontSize end,
        function () return Settings.FontStyle end
    )

    -- Font Size Slider
    fontSubmenuControls[#fontSubmenuControls + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        10,
        30,
        1,
        function () return Settings.FontSize end,
        function (value)
            Settings.FontSize = value
            InfoPanel.ApplyFont()
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        Defaults.FontSize
    )

    -- Font Style Dropdown
    fontSubmenuControls[#fontSubmenuControls + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_FONT_STYLE),
        GetString(LUIE_STRING_LAM_CT_FONT_STYLE_TP),
        function () return Settings.FontStyle end,
        function (var)
            Settings.FontStyle = var
            InfoPanel.ApplyFont()
        end,
        function () return Settings.FontFace end,
        function () return Settings.FontSize end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        Defaults.FontStyle
    )

    optionsDataInfoPanel[#optionsDataInfoPanel + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_FONT),
        fontSubmenuControls
    )

    -- Info Panel Options Submenu
    local panelSubmenuControls = {}

    -- Elements Header
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_PNL_ELEMENTS_HEADER)
    )

    -- Show Latency
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWLATENCY),
        nil,
        function () return not Settings.HideLatency end,
        function (value)
            Settings.HideLatency = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Show Clock
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWCLOCK),
        nil,
        function () return not Settings.HideClock end,
        function (value)
            Settings.HideClock = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Clock Format (indented)
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateIndentedEditbox(
        GetString(LUIE_STRING_LAM_PNL_CLOCKFORMAT),
        GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP),
        function () return Settings.ClockFormat end,
        function (value)
            Settings.ClockFormat = value
            InfoPanel.RefreshClockMeterUpdateInterval()
            InfoPanel.RearrangePanel(true)
        end,
        1,
        "full",
        function () return not (LUIE.SV.InfoPanel_Enabled and not Settings.HideClock) end,
        Defaults.ClockFormat
    )

    -- Show FPS
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWFPS),
        nil,
        function () return not Settings.HideFPS end,
        function (value)
            Settings.HideFPS = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Show Memory
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWMEMORY),
        GetString(LUIE_STRING_LAM_PNL_SHOWMEMORY_TP),
        function () return not Settings.HideMemory end,
        function (value)
            Settings.HideMemory = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Show Mount Timer
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER),
        GetString(LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP),
        function () return not Settings.HideMountFeed end,
        function (value)
            Settings.HideMountFeed = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Show Armor Durability
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY),
        nil,
        function () return not Settings.HideArmour end,
        function (value)
            Settings.HideArmour = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Show Weapon Charges
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES),
        nil,
        function () return not Settings.HideWeapons end,
        function (value)
            Settings.HideWeapons = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Show Bag Space
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWBAGSPACE),
        nil,
        function () return not Settings.HideBags end,
        function (value)
            Settings.HideBags = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Show Soul Gems
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_SHOWSOULGEMS),
        nil,
        function () return not Settings.HideGems end,
        function (value)
            Settings.HideGems = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Show Gold
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_PNL_SHOWGOLD),
        nil,
        function () return not Settings.HideGold end,
        function (value)
            Settings.HideGold = not value
            InfoPanel.RearrangePanel(true)
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        true
    )

    -- Misc Header
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateHeaderOption(
        GetString(SI_PLAYER_MENU_MISC)
    )

    -- Display on World Map
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP),
        GetString(LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP),
        function () return Settings.DisplayOnWorldMap end,
        function (value)
            Settings.DisplayOnWorldMap = value
            InfoPanel.SetDisplayOnMap()
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        false
    )

    -- Hide Info Panel in combat
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_HIDEINCOMBAT),
        GetString(LUIE_STRING_LAM_PNL_HIDEINCOMBAT_TP),
        function () return Settings.HideInCombat end,
        function (value)
            Settings.HideInCombat = value
            if not value then
                InfoPanel.CancelCombatHideAndShow()
            else
                InfoPanel.OnPlayerCombatState(IsUnitInCombat("player"))
            end
        end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        Defaults.HideInCombat
    )

    -- Disable Info Colors
    panelSubmenuControls[#panelSubmenuControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_DISABLECOLORSRO),
        GetString(LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP),
        function () return Settings.DisableInfoColours end,
        function (value) Settings.DisableInfoColours = value end,
        "full",
        function () return not LUIE.SV.InfoPanel_Enabled end,
        false
    )

    optionsDataInfoPanel[#optionsDataInfoPanel + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_PNL_HEADER),
        panelSubmenuControls
    )

    -- Register the settings panel
    LAM:RegisterAddonPanel(LUIE.name .. "InfoPanelOptions", panelDataInfoPanel)
    LAM:RegisterOptionControls(LUIE.name .. "InfoPanelOptions", optionsDataInfoPanel)
end
