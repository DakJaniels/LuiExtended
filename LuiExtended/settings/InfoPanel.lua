-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.InfoPanel
local InfoPanel = LUIE.InfoPanel

local zo_strformat = zo_strformat

-- Setup font list
local FontsList = {}
local LMP = LibMediaProvider
if LMP then
    -- Add LUIE fonts first
    for f, _ in pairs(LUIE.Fonts) do
        table.insert(FontsList, f)
    end
    -- Add LMP fonts
    for _, font in ipairs(LMP:List(LMP.MediaType.FONT)) do
        -- Only add if not already in list
        if not LUIE.Fonts[font] then
            table.insert(FontsList, font)
        end
    end
end

-- Load LibAddonMenu
local LAM = LUIE.LAM

-- Create Settings Menu
function InfoPanel.CreateSettings()
    local Defaults = InfoPanel.Defaults
    local Settings = InfoPanel.SV

    local panelDataInfoPanel =
    {
        type = "panel",
        name = zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_PNL)),
        displayName = zo_strformat("<<1>> <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_PNL)),
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
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] =
    {
        type = "description",
        text = GetString(LUIE_STRING_LAM_PNL_DESCRIPTION),
    }

    -- ReloadUI Button
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        func = function ()
            ReloadUI("ingame")
        end,
        width = "full",
    }

    -- Unlock InfoPanel
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_PNL_UNLOCKPANEL),
        tooltip = GetString(LUIE_STRING_LAM_PNL_UNLOCKPANEL_TP),
        getFunc = function ()
            return InfoPanel.panelUnlocked
        end,
        setFunc = InfoPanel.SetMovingState,
        width = "half",
        default = false,
        disabled = function ()
            return not LUIE.SV.InfoPanel_Enabled
        end,
        resetFunc = InfoPanel.ResetPosition,
    }

    -- InfoPanel scale
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] =
    {
        type = "slider",
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
        width = "full",
        default = 100,
        disabled = function ()
            return not LUIE.SV.InfoPanel_Enabled
        end,
    }

    -- Reset InfoPanel position
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RESETPOSITION),
        tooltip = GetString(LUIE_STRING_LAM_PNL_RESETPOSITION_TP),
        func = InfoPanel.ResetPosition,
        width = "half",
    }

    -- Font Options Submenu
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_FONT),
        controls =
        {
            {
                type = "dropdown",
                scrollable = 7,
                name = GetString(LUIE_STRING_LAM_FONT),
                tooltip = GetString(LUIE_STRING_LAM_FONT),
                choices = FontsList,
                sort = "name-up",
                getFunc = function ()
                    return Settings.FontFace
                end,
                setFunc = function (var)
                    Settings.FontFace = var
                    InfoPanel.ApplyFont()
                end,
                width = "full",
                default = Defaults.FontFace,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "slider",
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
                width = "full",
                default = Defaults.FontSize,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_FONT_STYLE),
                tooltip = GetString(LUIE_STRING_LAM_CT_FONT_STYLE_TP),
                choices =
                {
                    "|cFFFFFF" .. GetString(LUIE_FONT_STYLE_NORMAL) .. "|r",
                    "|c888888" .. GetString(LUIE_FONT_STYLE_SHADOW) .. "|r",
                    "|cEEEEEE" .. GetString(LUIE_FONT_STYLE_OUTLINE) .. "|r",
                    "|cFFFFFF" .. GetString(LUIE_FONT_STYLE_THICK_OUTLINE) .. "|r",
                    "|c777777" .. GetString(LUIE_FONT_STYLE_SOFT_SHADOW_THIN) .. "|r",
                    "|c666666" .. GetString(LUIE_FONT_STYLE_SOFT_SHADOW_THICK) .. "|r",
                },
                choicesValues =
                {
                    GetString(LUIE_FONT_STYLE_VALUE_NORMAL),
                    GetString(LUIE_FONT_STYLE_VALUE_SHADOW),
                    GetString(LUIE_FONT_STYLE_VALUE_OUTLINE),
                    GetString(LUIE_FONT_STYLE_VALUE_THICK_OUTLINE),
                    GetString(LUIE_FONT_STYLE_VALUE_SOFT_SHADOW_THIN),
                    GetString(LUIE_FONT_STYLE_VALUE_SOFT_SHADOW_THICK),
                },
                sort = "name-up",
                getFunc = function ()
                    return Settings.FontStyle
                end,
                setFunc = function (var)
                    Settings.FontStyle = var
                    InfoPanel.ApplyFont()
                end,
                width = "full",
                default = Defaults.FontStyle,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
        },
    }

    -- Info Panel Options Submenu
    optionsDataInfoPanel[#optionsDataInfoPanel + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_PNL_HEADER),
        controls =
        {
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_PNL_ELEMENTS_HEADER),
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_SHOWLATENCY),
                getFunc = function ()
                    return not Settings.HideLatency
                end,
                setFunc = function (value)
                    Settings.HideLatency = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_SHOWCLOCK),
                getFunc = function ()
                    return not Settings.HideClock
                end,
                setFunc = function (value)
                    Settings.HideClock = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                -- Timestamp Format
                type = "editbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_PNL_CLOCKFORMAT)),
                tooltip = GetString(LUIE_STRING_LAM_CA_TIMESTAMPFORMAT_TP),
                getFunc = function ()
                    return Settings.ClockFormat
                end,
                setFunc = function (value)
                    Settings.ClockFormat = value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = Defaults.ClockFormat,
                disabled = function ()
                    return not (LUIE.SV.InfoPanel_Enabled and not Settings.HideClock)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_SHOWFPS),
                getFunc = function ()
                    return not Settings.HideFPS
                end,
                setFunc = function (value)
                    Settings.HideFPS = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER),
                tooltip = GetString(LUIE_STRING_LAM_PNL_SHOWMOUNTTIMER_TP),
                getFunc = function ()
                    return not Settings.HideMountFeed
                end,
                setFunc = function (value)
                    Settings.HideMountFeed = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_SHOWARMORDURABILITY),
                getFunc = function ()
                    return not Settings.HideArmour
                end,
                setFunc = function (value)
                    Settings.HideArmour = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_SHOWEAPONCHARGES),
                getFunc = function ()
                    return not Settings.HideWeapons
                end,
                setFunc = function (value)
                    Settings.HideWeapons = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_SHOWBAGSPACE),
                getFunc = function ()
                    return not Settings.HideBags
                end,
                setFunc = function (value)
                    Settings.HideBags = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_SHOWSOULGEMS),
                getFunc = function ()
                    return not Settings.HideGems
                end,
                setFunc = function (value)
                    Settings.HideGems = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_PNL_SHOWGOLD),
                getFunc = function ()
                    return not Settings.HideGold
                end,
                setFunc = function (value)
                    Settings.HideGold = not value
                    InfoPanel.RearrangePanel()
                end,
                width = "full",
                default = true,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "header",
                name = GetString(SI_PLAYER_MENU_MISC),
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP),
                tooltip = GetString(LUIE_STRING_LAM_PNL_DISPLAYONWORLDMAP_TP),
                getFunc = function ()
                    return Settings.DisplayOnWorldMap
                end,
                setFunc = function (value)
                    Settings.DisplayOnWorldMap = value
                    InfoPanel.SetDisplayOnMap()
                end,
                width = "full",
                default = false,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_PNL_DISABLECOLORSRO),
                tooltip = GetString(LUIE_STRING_LAM_PNL_DISABLECOLORSRO_TP),
                getFunc = function ()
                    return Settings.DisableInfoColours
                end,
                setFunc = function (value)
                    Settings.DisableInfoColours = value
                end,
                width = "full",
                default = false,
                disabled = function ()
                    return not LUIE.SV.InfoPanel_Enabled
                end,
            },
        },
    }

    -- Register the settings panel
    if LUIE.SV.InfoPanel_Enabled then
        LAM:RegisterAddonPanel(LUIE.name .. "InfoPanelOptions", panelDataInfoPanel)
        LAM:RegisterOptionControls(LUIE.name .. "InfoPanelOptions", optionsDataInfoPanel)
    end
end
