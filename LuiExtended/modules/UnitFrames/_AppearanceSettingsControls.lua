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

local FONT_SIZE_MIN = 10
local FONT_SIZE_MAX = 30
local FONT_SIZE_STEP = 1

local separateCaptionFontCategories = UnitFrames.APPEARANCE_SEPARATE_CAPTION_FONT_CATEGORIES

--- @param category string
--- @return boolean
local function categoryUsesSeparateCaptionFont(category)
    return separateCaptionFontCategories[category] == true
end

--- @param category string
--- @return number
local function getAppearanceFontSizeForPreview(category)
    local appearance = UnitFrames.GetCustomFrameAppearance(category)
    if categoryUsesSeparateCaptionFont(category) then
        return appearance.fontOther
    end
    return appearance.fontBars
end

--- @param entry table
--- @param value number
local function syncUnifiedAppearanceFontSize(entry, value)
    entry.fontOther = value
    entry.fontBars = value
end

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

--- @param controls table
--- @param category string
--- @param settings table
--- @param defaults table
--- @param defaultEntry table|nil
--- @param disabledFunc function
local function AppendLAMFontSizeControls(controls, category, settings, defaults, defaultEntry, disabledFunc)
    local function applyFont()
        UnitFrames.CustomFramesApplyFontForCategory(category)
    end

    if categoryUsesSeparateCaptionFont(category) then
        controls[#controls + 1] =
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS_TP),
            min = FONT_SIZE_MIN,
            max = FONT_SIZE_MAX,
            step = FONT_SIZE_STEP,
            getFunc = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontOther
            end,
            setFunc = function (value)
                GetAppearanceEntry(settings, category).fontOther = value
                applyFont()
            end,
            width = "half",
            disabled = disabledFunc,
            default = defaultEntry.fontOther,
        }
        controls[#controls + 1] =
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS_TP),
            min = FONT_SIZE_MIN,
            max = FONT_SIZE_MAX,
            step = FONT_SIZE_STEP,
            getFunc = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontBars
            end,
            setFunc = function (value)
                GetAppearanceEntry(settings, category).fontBars = value
                applyFont()
            end,
            width = "half",
            disabled = disabledFunc,
            default = defaultEntry.fontBars,
        }
    else
        controls[#controls + 1] =
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_COMPACT_TP),
            min = FONT_SIZE_MIN,
            max = FONT_SIZE_MAX,
            step = FONT_SIZE_STEP,
            getFunc = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontBars
            end,
            setFunc = function (value)
                syncUnifiedAppearanceFontSize(GetAppearanceEntry(settings, category), value)
                applyFont()
            end,
            width = "full",
            disabled = disabledFunc,
            default = defaultEntry.fontBars,
        }
    end
end

--- @param rows table
--- @param category string
--- @param settings table
--- @param defaults table
--- @param defaultEntry table|nil
--- @param disabledFunc function
--- @param markFontDeferred function
local function AppendLHASFontSizeRows(rows, category, settings, defaults, defaultEntry, disabledFunc, markFontDeferred)
    local LHAS = LibHarvensAddonSettings

    if categoryUsesSeparateCaptionFont(category) then
        rows[#rows + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS_TP),
            min = FONT_SIZE_MIN,
            max = FONT_SIZE_MAX,
            step = FONT_SIZE_STEP,
            getFunction = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontOther
            end,
            setFunction = function (value)
                GetAppearanceEntry(settings, category).fontOther = value
                markFontDeferred()
            end,
            disable = disabledFunc,
            default = defaultEntry.fontOther,
        }
        rows[#rows + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS_TP),
            min = FONT_SIZE_MIN,
            max = FONT_SIZE_MAX,
            step = FONT_SIZE_STEP,
            getFunction = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontBars
            end,
            setFunction = function (value)
                GetAppearanceEntry(settings, category).fontBars = value
                markFontDeferred()
            end,
            disable = disabledFunc,
            default = defaultEntry.fontBars,
        }
    else
        rows[#rows + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_COMPACT_TP),
            min = FONT_SIZE_MIN,
            max = FONT_SIZE_MAX,
            step = FONT_SIZE_STEP,
            getFunction = function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontBars
            end,
            setFunction = function (value)
                syncUnifiedAppearanceFontSize(GetAppearanceEntry(settings, category), value)
                markFontDeferred()
            end,
            disable = disabledFunc,
            default = defaultEntry.fontBars,
        }
    end
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

    local controls =
    {
        settingsAPI.CreateFontDropdown(
            GetString(LUIE_STRING_LAM_FONT),
            GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TP),
            function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontFace
            end,
            function (var)
                GetAppearanceEntry(settings, category).fontFace = var
                UnitFrames.CustomFramesApplyFontForCategory(category)
            end,
            "full",
            disabledFunc,
            defaultEntry.fontFace,
            nil,
            "name-up",
            function () return getAppearanceFontSizeForPreview(category) end,
            function () return UnitFrames.GetCustomFrameAppearance(category).fontStyle end
        ),
        settingsAPI.CreateFontStyleDropdown(
            GetString(LUIE_STRING_LAM_FONT_STYLE),
            GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_STYLE_TP),
            function ()
                return UnitFrames.GetCustomFrameAppearance(category).fontStyle
            end,
            function (var)
                GetAppearanceEntry(settings, category).fontStyle = var
                UnitFrames.CustomFramesApplyFontForCategory(category)
            end,
            function () return UnitFrames.GetCustomFrameAppearance(category).fontFace end,
            function () return getAppearanceFontSizeForPreview(category) end,
            "full",
            disabledFunc,
            defaultEntry.fontStyle
        ),
    }

    AppendLAMFontSizeControls(controls, category, settings, defaults, defaultEntry, disabledFunc)

    controls[#controls + 1] = settingsAPI.CreateStatusbarTextureDropdown(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE_TP),
        function ()
            return UnitFrames.GetCustomFrameAppearance(category).texture
        end,
        function (var)
            GetAppearanceEntry(settings, category).texture = var
            UnitFrames.CustomFramesApplyTextureForCategory(category)
        end,
        "full",
        disabledFunc,
        defaultEntry.texture
    )

    return controls
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
        default = settingsAPI:LHASDropdownGetData(defaultEntry.fontFace),
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
        default = settingsAPI:LHASDropdownGetData(defaultEntry.fontStyle),
        disable = disabledFunc,
    }

    AppendLHASFontSizeRows(rows, category, settings, defaults, defaultEntry, disabledFunc, markFontDeferred)

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
            UnitFrames.CustomFramesApplyTextureForCategory(category)
        end,
        default = settingsAPI:LHASDropdownGetData(defaultEntry.texture),
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
    local controls =
    {
        {
            type = "description",
            text = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TEXTURE_NOTE),
            width = "full",
        },
    }
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
    rows[#rows + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TEXTURE_NOTE),
        canSelect = false,
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
