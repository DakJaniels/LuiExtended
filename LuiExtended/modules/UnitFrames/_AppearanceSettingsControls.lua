-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local GetString = GetString
local ipairs = ipairs

UnitFrames.APPEARANCE_CATEGORY_TITLE_STRINGS =
{
    player = LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PLAYER,
    target = LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_TARGET,
    group = LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_GROUP,
    raid = LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_RAID,
    companion = LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_COMPANION,
    pet = LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PET,
    boss = LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_BOSS,
    ava = LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_AVA,
}

local function GetAppearanceEntry(settings, category)
    if not settings.CustomFrameAppearance then
        settings.CustomFrameAppearance = {}
    end
    if not settings.CustomFrameAppearance[category] then
        settings.CustomFrameAppearance[category] = {}
    end
    return settings.CustomFrameAppearance[category]
end

local function GetDefaultAppearanceEntry(defaults, category)
    return defaults.CustomFrameAppearance and defaults.CustomFrameAppearance[category]
end

--- @param category string
--- @param settings table
--- @param defaults table
--- @param settingsAPI table
--- @param disabledFunc function|nil
--- @return table[]
function UnitFrames.BuildLAMAppearanceCategoryControls(category, settings, defaults, settingsAPI, disabledFunc)
    local defaultEntry = GetDefaultAppearanceEntry(defaults, category)
    disabledFunc = disabledFunc or function ()
        return not LUIE.SV.UnitFrames_Enabled
    end

    return
    {
        {
            type = "dropdown",
            scrollable = 7,
            name = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TP),
            choices = settingsAPI.GetFontsList(),
            sort = "name-up",
            getFunc = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontFace
            end,
            setFunc = function (var)
                GetAppearanceEntry(settings, category).fontFace = var
                UnitFrames.CustomFramesApplyFont()
            end,
            width = "full",
            disabled = disabledFunc,
            default = defaultEntry and defaultEntry.fontFace or defaults.CustomFontFace,
        },
        {
            type = "dropdown",
            name = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_STYLE_TP),
            choices = LUIE.FONT_STYLE_CHOICES,
            choicesValues = LUIE.FONT_STYLE_CHOICES_VALUES,
            sort = "name-up",
            getFunc = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontStyle
            end,
            setFunc = function (var)
                GetAppearanceEntry(settings, category).fontStyle = var
                UnitFrames.CustomFramesApplyFont()
            end,
            width = "full",
            disabled = disabledFunc,
            default = defaultEntry and defaultEntry.fontStyle or defaults.CustomFontStyle,
        },
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS_TP),
            min = 10,
            max = 30,
            step = 1,
            getFunc = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontOther
            end,
            setFunc = function (value)
                GetAppearanceEntry(settings, category).fontOther = value
                UnitFrames.CustomFramesApplyFont()
            end,
            width = "half",
            disabled = disabledFunc,
            default = defaultEntry and defaultEntry.fontOther or defaults.CustomFontOther,
        },
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS_TP),
            min = 10,
            max = 30,
            step = 1,
            getFunc = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontBars
            end,
            setFunc = function (value)
                GetAppearanceEntry(settings, category).fontBars = value
                UnitFrames.CustomFramesApplyFont()
            end,
            width = "half",
            disabled = disabledFunc,
            default = defaultEntry and defaultEntry.fontBars or defaults.CustomFontBars,
        },
        {
            type = "dropdown",
            scrollable = 7,
            name = GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE_TP),
            choices = settingsAPI.GetStatusbarTexturesList(),
            sort = "name-up",
            getFunc = function ()
                return UnitFrames.GetCustomFrameAppearance(category).texture
            end,
            setFunc = function (var)
                GetAppearanceEntry(settings, category).texture = var
                UnitFrames.CustomFramesApplyTexture()
            end,
            width = "full",
            disabled = disabledFunc,
            default = defaultEntry and defaultEntry.texture or defaults.CustomTexture,
        },
    }
end

--- @param category string
--- @param settings table
--- @param defaults table
--- @param settingsAPI table
--- @param disabledFunc function|nil
--- @return table[]
function UnitFrames.BuildLHASAppearanceCategoryRows(category, settings, defaults, settingsAPI, disabledFunc)
    local LHAS = LibHarvensAddonSettings
    local defaultEntry = GetDefaultAppearanceEntry(defaults, category)
    disabledFunc = disabledFunc or function ()
        return not LUIE.SV.UnitFrames_Enabled
    end
    local rows = {}

    local function markFontDeferred()
        settingsAPI:MarkUnitFramesFontDeferred("custom")
    end

    rows[#rows + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_FONT),
        tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TP),
        items = settingsAPI:GetFontsList(),
        getFunction = function ()
            return { data = UnitFrames.GetCustomFrameAppearance(category).fontFace }
        end,
        setFunction = function (combobox, value, item)
            GetAppearanceEntry(settings, category).fontFace = item.data or item.name or value
            markFontDeferred()
        end,
        disable = disabledFunc,
        default = defaultEntry and defaultEntry.fontFace or defaults.CustomFontFace,
    }

    rows[#rows + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_FONT_STYLE),
        tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_STYLE_TP),
        items = function ()
            local fontStyleItems = {}
            for i, styleName in ipairs(LUIE.FONT_STYLE_CHOICES) do
                fontStyleItems[i] = { name = styleName, data = LUIE.FONT_STYLE_CHOICES_VALUES[i] }
            end
            return fontStyleItems
        end,
        getFunction = function ()
            return { data = UnitFrames.GetCustomFrameAppearance(category).fontStyle }
        end,
        setFunction = function (combobox, value, item)
            GetAppearanceEntry(settings, category).fontStyle = item.data or item.name or value
            markFontDeferred()
        end,
        default = defaultEntry and defaultEntry.fontStyle or defaults.CustomFontStyle,
        disable = disabledFunc,
    }

    rows[#rows + 1] =
    {
        type = LHAS.ST_SLIDER,
        label = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS),
        tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS_TP),
        min = 10,
        max = 30,
        step = 1,
        getFunction = function ()
            return UnitFrames.GetCustomFrameAppearance(category).fontOther
        end,
        setFunction = function (value)
            GetAppearanceEntry(settings, category).fontOther = value
            markFontDeferred()
        end,
        disable = disabledFunc,
        default = defaultEntry and defaultEntry.fontOther or defaults.CustomFontOther,
    }

    rows[#rows + 1] =
    {
        type = LHAS.ST_SLIDER,
        label = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS),
        tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS_TP),
        min = 10,
        max = 30,
        step = 1,
        getFunction = function ()
            return UnitFrames.GetCustomFrameAppearance(category).fontBars
        end,
        setFunction = function (value)
            GetAppearanceEntry(settings, category).fontBars = value
            markFontDeferred()
        end,
        disable = disabledFunc,
        default = defaultEntry and defaultEntry.fontBars or defaults.CustomFontBars,
    }

    rows[#rows + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE),
        tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE_TP),
        items = settingsAPI:GetStatusbarTexturesList(),
        getFunction = function ()
            return { data = UnitFrames.GetCustomFrameAppearance(category).texture }
        end,
        setFunction = function (combobox, value, item)
            GetAppearanceEntry(settings, category).texture = item.data or item.name or value
            UnitFrames.CustomFramesApplyTexture()
        end,
        default = defaultEntry and defaultEntry.texture or defaults.CustomTexture,
        disable = disabledFunc,
    }

    return rows
end

--- @param settings table
--- @param defaults table
--- @param settingsAPI table
--- @param disabledFunc function|nil
--- @return table[]
function UnitFrames.BuildLAMFontTextureSettingsSubmenu(settings, defaults, settingsAPI, disabledFunc)
    local controls = {}
    for _, category in ipairs(UnitFrames.APPEARANCE_CATEGORY_IDS) do
        local titleId = UnitFrames.APPEARANCE_CATEGORY_TITLE_STRINGS[category]
        controls[#controls + 1] =
        {
            type = "submenu",
            name = GetString(titleId),
            controls = UnitFrames.BuildLAMAppearanceCategoryControls(category, settings, defaults, settingsAPI, disabledFunc),
        }
    end
    return controls
end

--- @param settings table
--- @param defaults table
--- @param settingsAPI table
--- @param disabledFunc function|nil
--- @return table[]
function UnitFrames.BuildLHASFontTextureSettingsSection(settings, defaults, settingsAPI, disabledFunc)
    local LHAS = LibHarvensAddonSettings
    local rows = {}
    rows[#rows + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TEXTURE_HEADER),
    }
    rows[#rows + 1] = settingsAPI:ConsoleFontDeferLabelSetting()

    for _, category in ipairs(UnitFrames.APPEARANCE_CATEGORY_IDS) do
        local titleId = UnitFrames.APPEARANCE_CATEGORY_TITLE_STRINGS[category]
        rows[#rows + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(titleId),
            canSelect = false,
        }
        local categoryRows = UnitFrames.BuildLHASAppearanceCategoryRows(category, settings, defaults, settingsAPI, disabledFunc)
        for i = 1, #categoryRows do
            rows[#rows + 1] = categoryRows[i]
        end
    end
    return rows
end
