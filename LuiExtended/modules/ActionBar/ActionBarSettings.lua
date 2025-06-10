-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

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
table.sort(FontsList)

-- Get sounds from LibMediaProvider
local SoundsList = {}
if LMP then
    -- Add LUIE sounds first
    for sound, _ in pairs(LUIE.Sounds) do
        table.insert(SoundsList, sound)
    end
    -- Add LMP sounds
    for _, sound in ipairs(LMP:List(LMP.MediaType.SOUND)) do
        -- Only add if not already in list
        if not LUIE.Sounds[sound] then
            table.insert(SoundsList, sound)
        end
    end
end

-- Get statusbar textures from LibMediaProvider
local StatusbarTexturesList = {}
if LMP then
    -- Add LUIE textures first
    for key, _ in pairs(LUIE.StatusbarTextures) do
        table.insert(StatusbarTexturesList, key)
    end
    -- Add LMP statusbar textures
    for _, texture in ipairs(LMP:List(LMP.MediaType.STATUSBAR)) do
        -- Only add if not already in list
        if not LUIE.StatusbarTextures[texture] then
            table.insert(StatusbarTexturesList, texture)
        end
    end
end

--- @class (partial) LUIE_ActionBar
local AB = LUIE.ActionBar

-- Load LibAddonMenu
local LAM = LibAddonMenu2
if LAM == nil then
    return
end

function AB:CreateSettings()
    local defaults = LUIE.ActionBar.Defaults
    local SV = LUIE.ActionBar.SV

    local panel =
    {
        type = "panel",
        name = zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_AB_TITLE)),
        displayName = zo_strformat("<<1>> <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_AB_TITLE)),
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

    local options =
    {
        {
            type = "header",
            name = "|cFFFACD" .. GetString(LUIE_STRING_LAM_AB_HEADER_GENERAL) .. "|r",
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_AB_STATICBARS),
            tooltip = GetString(LUIE_STRING_LAM_AB_STATICBARS_TP),
            default = defaults.staticBars,
            getFunc = function () return SV.staticBars end,
            setFunc = function (value)
                SV.staticBars = value or false
            end,
            requiresReload = true,
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_AB_SHOWHOTKEYS),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHOWHOTKEYS_TP),
            default = defaults.showHotkeys,
            getFunc = function () return SV.showHotkeys end,
            setFunc = function (value)
                SV.showHotkeys = value or false
                AB:ToggleHotkeys()
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_AB_SHOWHIGHLIGHT),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHOWHIGHLIGHT_TP),
            default = defaults.showHighlight,
            getFunc = function () return SV.showHighlight end,
            setFunc = function (value)
                SV.showHighlight = value or false
            end,
            width = "half",
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_AB_SHOWARROW),
            tooltip = GetString(LUIE_STRING_LAM_AB_SHOWARROW_TP),
            default = defaults.showArrow,
            getFunc = function () return SV.showArrow end,
            setFunc = function (value)
                SV.showArrow = value or false
                _G["LUIE_ActionBarArrow"]:SetHidden(not SV.showArrow)
            end,
            width = "half",
            disabled = function () return not SV.staticBars end,
        },
        {
            type = "colorpicker",
            name = GetString(LUIE_STRING_LAM_AB_ARROWCOLOR),
            default = ZO_ColorDef:New(unpack(defaults.arrowColor)),
            getFunc = function () return unpack(SV.arrowColor) end,
            setFunc = function (r, g, b, a)
                SV.arrowColor = { r, g, b, a }
                _G["LUIE_ActionBarArrow"]:SetColor(unpack(SV.arrowColor))
            end,
            width = "half",
            disabled = function () return not SV.staticBars end,
        },
        {
            type = "header",
            name = "|cFFFACD" .. GetString(LUIE_STRING_LAM_AB_HEADER_BACKBAR) .. "|r",
        },
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_AB_BUTTONALPHA),
            tooltip = GetString(LUIE_STRING_LAM_AB_BUTTONALPHA_TP),
            min = 0.2,
            max = 1,
            step = 0.01,
            decimals = 2,
            clampInput = true,
            default = defaults.backBarAlpha,
            getFunc = function () return SV.backBarAlpha end,
            setFunc = function (value)
                AB:SetBackBarAlphaAndDesaturation(value, SV.backBarDesaturation)
            end,
            width = "half",
        },
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_AB_BUTTONDESATURATION),
            tooltip = GetString(LUIE_STRING_LAM_AB_BUTTONDESATURATION_TP),
            min = 0,
            max = 1,
            step = 0.01,
            decimals = 2,
            clampInput = true,
            default = defaults.backBarDesaturation,
            getFunc = function () return SV.backBarDesaturation end,
            setFunc = function (value)
                AB:SetBackBarAlphaAndDesaturation(SV.backBarAlpha, value)
            end,
            width = "half",
        },
        {
            type = "header",
            name = "|cFFFACD" .. GetString(LUIE_STRING_LAM_AB_HEADER_NUMBERS) .. "|r",
        },
        {
            type = "colorpicker",
            name = GetString(LUIE_STRING_LAM_AB_DEFAULTCOLOR),
            tooltip = GetString(LUIE_STRING_LAM_AB_DEFAULTCOLOR_TP),
            default = ZO_ColorDef:New(unpack(defaults.timerColor)),
            getFunc = function () return unpack(SV.timerColor) end,
            setFunc = function (r, g, b, a)
                SV.timerColor = { r, g, b, a }
            end,
            width = "half",
        },
        {
            type = "colorpicker",
            name = GetString(LUIE_STRING_LAM_AB_ZEROCOLOR),
            tooltip = GetString(LUIE_STRING_LAM_AB_ZEROCOLOR_TP),
            default = ZO_ColorDef:New(unpack(defaults.zeroColor)),
            getFunc = function () return unpack(SV.zeroColor) end,
            setFunc = function (r, g, b, a)
                SV.zeroColor = { r, g, b, a }
            end,
            width = "half",
        },
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_AB_DECIMALTHRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_AB_DECIMALTHRESHOLD_TP),
            min = 0,
            max = 10,
            step = 0.1,
            decimals = 1,
            clampInput = true,
            default = defaults.decimalThreshold,
            getFunc = function () return SV.decimalThreshold end,
            setFunc = function (value)
                SV.decimalThreshold = value
            end,
            width = "half",
        },
        {
            type = "colorpicker",
            name = GetString(LUIE_STRING_LAM_AB_DECIMALCOLOR),
            tooltip = GetString(LUIE_STRING_LAM_AB_DECIMALCOLOR_TP),
            default = ZO_ColorDef:New(unpack(defaults.decimalColor)),
            getFunc = function () return unpack(SV.decimalColor) end,
            setFunc = function (r, g, b, a)
                SV.decimalColor = { r, g, b, a }
            end,
            width = "half",
        },

        {
            type = "header",
            name = "|cFFFACD" .. GetString(LUIE_STRING_LAM_AB_HEADER_MISC) .. "|r",
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_AB_DEBUGMODE),
            tooltip = GetString(LUIE_STRING_LAM_AB_DEBUGMODE_TP),
            default = false,
            getFunc = function () return AB:IsDebugMode() end,
            setFunc = function (value)
                AB:SetDebugMode(value or false)
            end,
        },
    }

    -- Register the settings panel
    if LUIE.SV.ActionBar_Enabled then
        local name = AB:GetName() .. "Options"
        LAM:RegisterAddonPanel(name, panel)
        LAM:RegisterOptionControls(name, options)
    end
end
