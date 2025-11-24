-- -----------------------------------------------------------------------------
--  LuiExtended Console Settings API                                          --
--  Common utility functions for console settings modules using LHAS          --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Settings API namespace
local SettingsAPI = {}
LUIE.ConsoleSettingsAPI = SettingsAPI

-- Local references
local LHAS = LibHarvensAddonSettings
local LMP = LibMediaProvider
local table_insert = table.insert
local pairs = pairs
local ipairs = ipairs
local zo_strformat = zo_strformat
local string = string
local string_rep = string.rep
local unpack = unpack

-- Cache for media lists to avoid regenerating them
local mediaCache =
{
    fonts = nil,
    sounds = nil,
    statusbarTextures = nil
}

-- -----------------------------------------------------------------------------
-- Media Registration Functions (same as PC)
-- -----------------------------------------------------------------------------

--- Register LUIE's own media with LibMediaProvider
--- @param mediaType string The media type to register
--- @param mediaTable table The media table to register
local function RegisterLUIEMedia(mediaType, mediaTable)
    for mediaName, mediaPath in pairs(mediaTable) do
        LMP:Register(mediaType, mediaName, mediaPath)
    end
end

--- Fetch additional media from other addons via LibMediaProvider
--- @param mediaType string The media type to fetch
--- @param mediaTable table The media table to update
local function FetchExternalMedia(mediaType, mediaTable)
    for _, mediaName in ipairs(LMP:List(mediaType)) do
        if not mediaTable[mediaName] then
            mediaTable[mediaName] = LMP:Fetch(mediaType, mediaName)
        end
    end
end

--- Register all LUIE media with LibMediaProvider
function SettingsAPI.RegisterLUIEMedia()
    RegisterLUIEMedia(LMP.MediaType.FONT, LUIE.Fonts)
    RegisterLUIEMedia(LMP.MediaType.SOUND, LUIE.Sounds)
    RegisterLUIEMedia(LMP.MediaType.STATUSBAR, LUIE.StatusbarTextures)
end

--- Fetch additional media from other addons
function SettingsAPI.FetchExternalMedia()
    FetchExternalMedia(LMP.MediaType.FONT, LUIE.Fonts)
    FetchExternalMedia(LMP.MediaType.SOUND, LUIE.Sounds)
    FetchExternalMedia(LMP.MediaType.STATUSBAR, LUIE.StatusbarTextures)
end

--- Load all media (register LUIE + fetch external)
function SettingsAPI.LoadAllMedia()
    SettingsAPI.RegisterLUIEMedia()
    SettingsAPI.FetchExternalMedia()
    SettingsAPI.ClearMediaCache()
end

-- -----------------------------------------------------------------------------
-- Media List Generation Functions (same as PC)
-- -----------------------------------------------------------------------------

--- Get combined list of LUIE and LibMediaProvider fonts
--- @return table fontsList
function SettingsAPI.GetFontsList()
    if mediaCache.fonts then
        return mediaCache.fonts
    end

    local fontsList = {}

    -- Add LUIE fonts first
    for font, _ in pairs(LUIE.Fonts) do
        table_insert(fontsList, font)
    end
    -- Add LMP fonts
    for _, font in ipairs(LMP:List(LMP.MediaType.FONT)) do
        if not LUIE.Fonts[font] then
            table_insert(fontsList, font)
        end
    end

    mediaCache.fonts = fontsList
    return fontsList
end

--- Get combined list of LUIE and LibMediaProvider sounds
--- @return table soundsList
function SettingsAPI.GetSoundsList()
    if mediaCache.sounds then
        return mediaCache.sounds
    end

    local soundsList = {}

    -- Add LUIE sounds first
    for sound, _ in pairs(LUIE.Sounds) do
        table_insert(soundsList, sound)
    end
    -- Add LMP sounds
    for _, sound in ipairs(LMP:List(LMP.MediaType.SOUND)) do
        if not LUIE.Sounds[sound] then
            table_insert(soundsList, sound)
        end
    end

    mediaCache.sounds = soundsList
    return soundsList
end

--- Get combined list of LUIE and LibMediaProvider statusbar textures
--- @return table statusbarTexturesList
function SettingsAPI.GetStatusbarTexturesList()
    if mediaCache.statusbarTextures then
        return mediaCache.statusbarTextures
    end

    local statusbarTexturesList = {}

    -- Add LUIE textures first
    for key, _ in pairs(LUIE.StatusbarTextures) do
        table_insert(statusbarTexturesList, key)
    end
    -- Add LMP statusbar textures
    for _, texture in ipairs(LMP:List(LMP.MediaType.STATUSBAR)) do
        if not LUIE.StatusbarTextures[texture] then
            table_insert(statusbarTexturesList, texture)
        end
    end

    mediaCache.statusbarTextures = statusbarTexturesList
    return statusbarTexturesList
end

-- -----------------------------------------------------------------------------
-- Common Option Creation Helpers (LHAS version)
-- -----------------------------------------------------------------------------

--- Create a standard checkbox option
--- @param name string|table (if table, expects {name = string, tooltip = string, getFunc = function, setFunc = function, default = any, disabled = function})
--- @param tooltip string|nil
--- @param getFunc function|nil
--- @param setFunc function|nil
--- @param width string|nil (not used in LHAS, kept for compatibility)
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil (not used in LHAS, kept for compatibility)
--- @param requiresReload boolean|nil (not used in LHAS, kept for compatibility)
--- @param resetFunc function|nil (not used in LHAS, kept for compatibility)
--- @return table option
function SettingsAPI.CreateCheckboxOption(name, tooltip, getFunc, setFunc, width, disabled, default, warning, requiresReload, resetFunc)
    -- Handle both calling patterns: table or individual parameters
    local labelText = name
    local tooltipText = tooltip
    local getFuncFunc = getFunc
    local setFuncFunc = setFunc
    local defaultVal = default
    local disabledFunc = disabled

    if type(name) == "table" then
        labelText = name.name or ""
        tooltipText = name.tooltip
        getFuncFunc = name.getFunc
        setFuncFunc = name.setFunc
        defaultVal = name.default
        disabledFunc = name.disabled
    end

    -- Ensure labelText is always a string
    if type(labelText) ~= "string" then
        labelText = tostring(labelText or "")
    end

    return
    {
        type = LHAS.ST_CHECKBOX,
        label = labelText,
        tooltip = tooltipText,
        getFunction = getFuncFunc,
        setFunction = setFuncFunc,
        default = defaultVal,
        disable = disabledFunc
    }
end

--- Create a standard dropdown option
--- @param name string|table (if table, expects {name = string, tooltip = string, choices = table, getFunc = function, setFunc = function, default = any, disabled = function})
--- @param tooltip string|nil
--- @param choices table Array of strings or {name, data} tables
--- @param getFunc function Returns selected value (display name)
--- @param setFunc function Receives value (display name) - may need to map to key
--- @param width string|nil (not used in LHAS)
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil (not used in LHAS)
--- @param sort string|nil (not used in LHAS)
--- @param requiresReload boolean|nil (not used in LHAS)
--- @param choicesValues table|nil (not used in LHAS - items should be {name, data} format)
--- @param scrollable boolean|number|nil (not used in LHAS)
--- @return table option
function SettingsAPI.CreateDropdownOption(name, tooltip, choices, getFunc, setFunc, width, disabled, default, warning, sort, requiresReload, choicesValues, scrollable)
    -- Handle both calling patterns: table or individual parameters
    local labelText = name
    local tooltipText = tooltip
    local choicesData = choices
    local getFuncFunc = getFunc
    local setFuncFunc = setFunc
    local defaultVal = default
    local disabledFunc = disabled

    if type(name) == "table" then
        labelText = name.name or ""
        tooltipText = name.tooltip
        choicesData = name.choices or name.items -- Support both 'choices' and 'items' keys
        getFuncFunc = name.getFunc
        setFuncFunc = name.setFunc
        defaultVal = name.default
        disabledFunc = name.disabled
        sort = name.sort or sort -- Extract sort from table if provided
    end

    -- Ensure labelText is always a string
    if type(labelText) ~= "string" then
        labelText = tostring(labelText or "")
    end

    -- Handle choices: can be a function (for dynamic dropdowns) or a table
    local items = choicesData

    if type(choicesData) == "function" then
        -- If choices is a function, use it directly as items function
        -- Don't sort function-based items as they're dynamic and sorting breaks index matching
        items = choicesData
    elseif choicesData and type(choicesData) == "table" then
        -- Convert string array to {name, data} format if needed
        if #choicesData > 0 and type(choicesData[1]) == "string" then
            items = {}
            for i, choice in ipairs(choicesData) do
                items[i] = { name = choice, data = choice }
            end
        else
            -- Already in {name, data} format or empty table
            items = choicesData
        end

        -- Sort items alphabetically by name if sort is enabled (default to true)
        -- Only sort static tables, not function-based dynamic lists
        if (sort == nil or sort == true) and type(items) == "table" and #items > 0 then
            table.sort(items, function (a, b)
                local nameA = type(a) == "table" and a.name or tostring(a)
                local nameB = type(b) == "table" and b.name or tostring(b)
                return nameA < nameB
            end)
        end
    else
        -- Default to empty table if choicesData is nil or invalid
        items = {}
    end

    -- Wrap setFunc to handle LHAS format (combobox, value, item)
    -- LHAS passes: combobox (control), value (display name string), item ({name, data})
    -- Always pass all 3 arguments - functions should be written to accept (combobox, value, item)
    -- and use value (the string choice name) as needed
    -- Functions originally written for LAM2 as function(value) need to be updated to
    -- function(combobox, value, item) but can ignore combobox and item
    local wrappedSetFunc = function (combobox, value, item)
        setFuncFunc(combobox, value, item)
    end

    -- Convert string default to index if items is a table
    -- LHAS expects default to be an index (number) or nil
    -- Note: LHAS uses FindIndexFromData which returns 0-based index, but SetSelectedIndex also accepts 0-based
    -- For function-based items (dynamic lists), always use nil as default to avoid index matching issues
    -- IMPORTANT: If default is 0, use nil instead to avoid type mismatch errors (LHAS compares numbers with tables)
    local defaultIndex = defaultVal
    if type(items) == "function" then
        -- For function-based items, use nil as default to avoid index matching issues
        -- The function will be called later by LHAS, and we can't predict the index
        defaultIndex = nil
    elseif defaultVal == 0 then
        -- If default is 0, use nil instead to avoid type mismatch errors
        -- LHAS will select the first item (index 0) by default when nil is used
        defaultIndex = nil
    elseif defaultVal and type(defaultVal) == "string" and type(items) == "table" and #items > 0 then
        -- Find the index of the item matching the default string
        local found = false
        for i, item in ipairs(items) do
            if type(item) == "table" then
                if item.name == defaultVal or item.data == defaultVal then
                    defaultIndex = i - 1 -- Convert to 0-based index
                    found = true
                    break
                end
            elseif item == defaultVal then
                defaultIndex = i - 1
                found = true
                break
            end
        end
        -- If not found, set to nil (will use 0 as fallback in LHAS)
        if not found then
            defaultIndex = nil
        end
    elseif type(defaultVal) == "number" and defaultVal > 0 then
        -- Already an index - assume it's already in the correct format
        -- Only accept positive numbers (0 is handled above)
        defaultIndex = defaultVal
    elseif type(defaultVal) == "number" and defaultVal < 0 then
        -- Negative numbers are invalid, use nil
        defaultIndex = nil
    end

    return
    {
        type = LHAS.ST_DROPDOWN,
        label = labelText,
        tooltip = tooltipText,
        items = items,
        getFunction = getFuncFunc,
        setFunction = wrappedSetFunc,
        default = defaultIndex,
        disable = disabledFunc
    }
end

--- Create a standard slider option
--- @param name string|table (if table, expects {name = string, tooltip = string, min = number, max = number, step = number, getFunc = function, setFunc = function, default = any, disabled = function, decimals = number})
--- @param tooltip string|nil
--- @param min number|nil
--- @param max number|nil
--- @param step number|nil
--- @param getFunc function|nil
--- @param setFunc function|nil
--- @param width string|nil (not used in LHAS)
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil (not used in LHAS)
--- @param decimals number|nil
--- @param requiresReload boolean|nil (not used in LHAS)
--- @return table option
function SettingsAPI.CreateSliderOption(name, tooltip, min, max, step, getFunc, setFunc, width, disabled, default, warning, decimals, requiresReload)
    -- Handle both calling patterns: table or individual parameters
    local labelText = name
    local tooltipText = tooltip
    local minVal = min
    local maxVal = max
    local stepVal = step
    local getFuncFunc = getFunc
    local setFuncFunc = setFunc
    local defaultVal = default
    local disabledFunc = disabled
    local decimalsVal = decimals

    if type(name) == "table" then
        labelText = name.name or ""
        tooltipText = name.tooltip
        minVal = name.min
        maxVal = name.max
        stepVal = name.step
        getFuncFunc = name.getFunc
        setFuncFunc = name.setFunc
        defaultVal = name.default
        disabledFunc = name.disabled
        decimalsVal = name.decimals
    end

    -- Ensure labelText is always a string
    if type(labelText) ~= "string" then
        labelText = tostring(labelText or "")
    end

    local format = decimalsVal and string.format("%%.%df", decimalsVal) or "%.0f"
    return
    {
        type = LHAS.ST_SLIDER,
        label = labelText,
        tooltip = tooltipText,
        min = minVal,
        max = maxVal,
        step = stepVal,
        format = format,
        getFunction = getFuncFunc,
        setFunction = setFuncFunc,
        default = defaultVal,
        disable = disabledFunc
    }
end

--- Create a standard editbox option
--- @param name string|table (if table, expects {name = string, tooltip = string, getFunc = function, setFunc = function, default = any, disabled = function, textType = number, maxInputChars = number})
--- @param tooltip string|nil
--- @param getFunc function|nil
--- @param setFunc function|nil
--- @param width string|nil (not used in LHAS)
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil (not used in LHAS)
--- @param isMultiline boolean|nil (not used in LHAS)
--- @param isExtraWide boolean|nil (not used in LHAS)
--- @param requiresReload boolean|nil (not used in LHAS)
--- @return table option
function SettingsAPI.CreateEditboxOption(name, tooltip, getFunc, setFunc, width, disabled, default, warning, isMultiline, isExtraWide, requiresReload)
    -- Handle both calling patterns: table or individual parameters
    local labelText = name
    local tooltipText = tooltip
    local getFuncFunc = getFunc
    local setFuncFunc = setFunc
    local defaultVal = default
    local disabledFunc = disabled

    if type(name) == "table" then
        labelText = name.name or ""
        tooltipText = name.tooltip
        getFuncFunc = name.getFunc
        setFuncFunc = name.setFunc
        defaultVal = name.default
        disabledFunc = name.disabled
    end

    -- Ensure labelText is always a string
    if type(labelText) ~= "string" then
        labelText = tostring(labelText or "")
    end

    return
    {
        type = LHAS.ST_EDIT,
        label = labelText,
        tooltip = tooltipText,
        getFunction = getFuncFunc,
        setFunction = setFuncFunc,
        default = defaultVal,
        disable = disabledFunc
    }
end

--- Create a standard colorpicker option
--- @param name string
--- @param tooltip string|nil
--- @param getFunc function Returns r, g, b, a (use unpack for table)
--- @param setFunc function Receives r, g, b, a
--- @param width string|nil (not used in LHAS)
--- @param disabled function|nil
--- @param defaultR number|nil
--- @param defaultG number|nil
--- @param defaultB number|nil
--- @param defaultA number|nil
--- @param warning string|nil (not used in LHAS)
--- @param requiresReload boolean|nil (not used in LHAS)
--- @return table option
function SettingsAPI.CreateColorpickerOption(name, tooltip, getFunc, setFunc, width, disabled, defaultR, defaultG, defaultB, defaultA, warning, requiresReload)
    local default = nil
    if defaultR and defaultG and defaultB then
        default = { defaultR, defaultG, defaultB, defaultA or 1 }
    end

    return
    {
        type = LHAS.ST_COLOR,
        label = name,
        tooltip = tooltip,
        getFunction = getFunc,
        setFunction = setFunc,
        default = default,
        disable = disabled
    }
end

--- Create a standard button option
--- @param name string|table (if table, expects {name = string, tooltip = string, clickHandler = function, buttonText = string, disabled = function})
--- @param tooltip string|nil
--- @param func function|nil
--- @param width string|nil (not used in LHAS)
--- @param disabled function|nil
--- @param warning string|nil (not used in LHAS)
--- @param requiresReload boolean|nil (not used in LHAS)
--- @return table option
function SettingsAPI.CreateButtonOption(name, tooltip, func, width, disabled, warning, requiresReload)
    -- Handle both calling patterns: table or individual parameters
    local labelText = name
    local tooltipText = tooltip
    local clickHandlerFunc = func
    local buttonTextStr = name
    local disabledFunc = disabled

    if type(name) == "table" then
        labelText = name.name or name.buttonText or ""
        tooltipText = name.tooltip
        clickHandlerFunc = name.clickHandler or name.func
        buttonTextStr = name.buttonText or name.name or ""
        disabledFunc = name.disabled
    end

    -- Ensure labelText and buttonTextStr are always strings
    if type(labelText) ~= "string" then
        labelText = tostring(labelText or "")
    end
    if type(buttonTextStr) ~= "string" then
        buttonTextStr = tostring(buttonTextStr or labelText or "")
    end

    return
    {
        type = LHAS.ST_BUTTON,
        label = labelText,
        tooltip = tooltipText,
        buttonText = buttonTextStr,
        clickHandler = clickHandlerFunc,
        disable = disabledFunc
    }
end

--- Create a standard description option (label in LHAS)
--- @param text string|table (if table, expects {text = string})
--- @param width string|nil (not used in LHAS)
--- @param title string|nil (not used in LHAS)
--- @return table option
function SettingsAPI.CreateDescriptionOption(text, width, title)
    -- Handle both calling patterns: string or table with text field
    local labelText = text
    if type(text) == "table" and text.text then
        labelText = text.text
    end

    -- Ensure labelText is always a string
    if type(labelText) ~= "string" then
        labelText = tostring(labelText or "")
    end

    return
    {
        type = LHAS.ST_LABEL,
        label = labelText
    }
end

--- Create a standard header option (section in LHAS)
--- @param name string|table (if table, expects {name = "..."})
--- @param width string|nil (not used in LHAS)
--- @return table option
function SettingsAPI.CreateHeaderOption(name, width)
    -- Handle both calling patterns: string or table with name field
    local labelText = name
    if type(name) == "table" and name.name then
        labelText = name.name
    end

    -- Ensure labelText is always a string
    if type(labelText) ~= "string" then
        labelText = tostring(labelText or "")
    end

    return
    {
        type = LHAS.ST_SECTION,
        label = labelText
    }
end

--- Create a standard divider option (label with empty text in LHAS)
--- @param width string|nil (not used in LHAS)
--- @param height number|nil (not used in LHAS)
--- @param alpha number|nil (not used in LHAS)
--- @return table option
function SettingsAPI.CreateDividerOption(width, height, alpha)
    return
    {
        type = LHAS.ST_LABEL,
        label = ""
    }
end

--- Create a standard submenu option (not supported in LHAS - returns section header)
--- Note: LHAS doesn't support submenus, so this creates a section header instead
--- @param name string
--- @param controls table (not used - submenus not supported)
--- @param reference string|nil (not used)
--- @return table option
function SettingsAPI.CreateSubmenuOption(name, controls, reference)
    -- LHAS doesn't support submenus, so we return a section header
    -- The controls will need to be added directly to the parent panel
    return
    {
        type = LHAS.ST_SECTION,
        label = name
    }
end

-- -----------------------------------------------------------------------------
-- Common Option Patterns
-- -----------------------------------------------------------------------------

--- Create a font selection dropdown
--- @param name string
--- @param tooltip string
--- @param getFunc function
--- @param setFunc function
--- @param width string|nil
--- @param disabled function|nil
--- @param default string|nil
--- @param warning string|nil
--- @param sort string|nil
--- @return table option
function SettingsAPI.CreateFontDropdown(name, tooltip, getFunc, setFunc, width, disabled, default, warning, sort)
    return SettingsAPI.CreateDropdownOption(
        name,
        tooltip,
        SettingsAPI.GetFontsList(),
        getFunc,
        setFunc,
        width,
        disabled,
        default,
        warning,
        sort
    )
end

--- Create a sound selection dropdown
--- @param name string
--- @param tooltip string
--- @param getFunc function
--- @param setFunc function
--- @param width string|nil
--- @param disabled function|nil
--- @param default string|nil
--- @param warning string|nil
--- @param sort string|nil
--- @return table option
function SettingsAPI.CreateSoundDropdown(name, tooltip, getFunc, setFunc, width, disabled, default, warning, sort)
    return SettingsAPI.CreateDropdownOption(
        name,
        tooltip,
        SettingsAPI.GetSoundsList(),
        getFunc,
        setFunc,
        width,
        disabled,
        default,
        warning,
        sort
    )
end

--- Create a statusbar texture selection dropdown
--- @param name string
--- @param tooltip string
--- @param getFunc function
--- @param setFunc function
--- @param width string|nil
--- @param disabled function|nil
--- @param default string|nil
--- @param warning string|nil
--- @param sort string|nil
--- @return table option
function SettingsAPI.CreateStatusbarTextureDropdown(name, tooltip, getFunc, setFunc, width, disabled, default, warning, sort)
    return SettingsAPI.CreateDropdownOption(
        name,
        tooltip,
        SettingsAPI.GetStatusbarTexturesList(),
        getFunc,
        setFunc,
        width,
        disabled,
        default,
        warning,
        sort
    )
end

--- Create a font style dropdown (handles choicesValues mapping)
--- @param name string|table (if table, expects {name = string, tooltip = string, getFunc = function, setFunc = function, indentLevel = number, width = string, disabled = function, default = any, sort = boolean})
--- @param tooltip string|nil
--- @param getFunc function|nil Returns value from choicesValues
--- @param setFunc function|nil Receives value from choicesValues
--- @param indentLevel number|nil
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param sort boolean|nil
--- @return table option
function SettingsAPI.CreateFontStyleDropdown(name, tooltip, getFunc, setFunc, indentLevel, width, disabled, default, sort)
    -- Handle both calling patterns: table or individual parameters
    local labelText = name
    local tooltipText = tooltip
    local getFuncFunc = getFunc
    local setFuncFunc = setFunc
    local indentLevelVal = indentLevel
    local widthVal = width
    local disabledFunc = disabled
    local defaultVal = default

    local sortVal = sort
    if type(name) == "table" then
        labelText = name.name or ""
        tooltipText = name.tooltip
        getFuncFunc = name.getFunc
        setFuncFunc = name.setFunc
        indentLevelVal = name.indentLevel
        widthVal = name.width
        disabledFunc = name.disabled
        defaultVal = name.default
        sortVal = name.sort or sort
    end

    -- Ensure labelText is always a string
    if type(labelText) ~= "string" then
        labelText = tostring(labelText or "")
    end

    -- Ensure getFunc and setFunc are provided, provide defaults if missing
    if not getFuncFunc or type(getFuncFunc) ~= "function" then
        getFuncFunc = function () return LUIE.FONT_STYLE_CHOICES_VALUES[1] end
    end
    if not setFuncFunc or type(setFuncFunc) ~= "function" then
        setFuncFunc = function () end -- no-op if not provided
    end

    local indentedName = SettingsAPI.AddIndent(labelText, indentLevelVal)
    -- Convert choices/choicesValues to {name, data} format
    local items = {}
    for i, choice in ipairs(LUIE.FONT_STYLE_CHOICES) do
        items[i] = { name = choice, data = LUIE.FONT_STYLE_CHOICES_VALUES[i] }
    end

    -- Sort items alphabetically by name if sort is enabled (default to true)
    if (sortVal == nil or sortVal == true) and type(items) == "table" and #items > 0 then
        table.sort(items, function (a, b)
            return a.name < b.name
        end)
    end

    -- Wrap getFunc to return display name
    local wrappedGetFunc = function ()
        local value = getFuncFunc()
        for i, choiceValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
            if choiceValue == value then
                return LUIE.FONT_STYLE_CHOICES[i]
            end
        end
        return LUIE.FONT_STYLE_CHOICES[1] -- fallback
    end

    -- Wrap setFunc to convert display name to value
    local wrappedSetFunc = function (combobox, value, item)
        if item and item.data then
            setFuncFunc(item.data)
        end
    end

    return
    {
        type = LHAS.ST_DROPDOWN,
        label = indentedName,
        tooltip = tooltipText,
        items = items,
        getFunction = wrappedGetFunc,
        setFunction = wrappedSetFunc,
        default = defaultVal,
        disable = disabledFunc
    }
end

-- -----------------------------------------------------------------------------
-- Utility Functions
-- -----------------------------------------------------------------------------

--- Add indentation to an option name (for visual hierarchy since no submenus)
--- @param name string
--- @param level number Number of indent levels (default 1)
--- @return string indentedName
function SettingsAPI.AddIndent(name, level)
    level = level or 1
    local indent = string.rep("  ", level) -- Use 2 spaces per level
    return zo_strformat("<<1>><<2>>", indent, name)
end

--- Create an indented checkbox option
--- @param name string
--- @param tooltip string
--- @param getFunc function
--- @param setFunc function
--- @param indentLevel number|nil|string (if string, treated as width and indentLevel defaults to 1)
--- @param width string|nil|function (if function, treated as disabled)
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedCheckbox(name, tooltip, getFunc, setFunc, indentLevel, width, disabled, default, warning, requiresReload)
    -- Handle parameter mismatch: if indentLevel is a string, it's actually width
    -- and the parameters are shifted
    local actualIndentLevel = 1
    local actualWidth = width
    local actualDisabled = disabled
    local actualDefault = default

    if type(indentLevel) == "string" then
        -- indentLevel is actually width, shift parameters
        actualIndentLevel = 1 -- default indent level
        actualWidth = indentLevel
        actualDisabled = width
        actualDefault = disabled
    elseif type(indentLevel) == "number" then
        actualIndentLevel = indentLevel
    end

    local indentedName = SettingsAPI.AddIndent(name, actualIndentLevel)
    return SettingsAPI.CreateCheckboxOption(
        indentedName,
        tooltip,
        getFunc,
        setFunc,
        actualWidth,
        actualDisabled,
        actualDefault,
        warning,
        requiresReload
    )
end

--- Create an indented slider option
--- @param name string
--- @param tooltip string
--- @param min number
--- @param max number
--- @param step number
--- @param getFunc function
--- @param setFunc function
--- @param indentLevel number|nil|string (if string, treated as width and indentLevel defaults to 1)
--- @param width string|nil|function (if function, treated as disabled)
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param decimals number|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedSlider(name, tooltip, min, max, step, getFunc, setFunc, indentLevel, width, disabled, default, warning, decimals, requiresReload)
    -- Handle parameter mismatch: if indentLevel is a string, it's actually width
    local actualIndentLevel = 1
    local actualWidth = width
    local actualDisabled = disabled
    local actualDefault = default

    if type(indentLevel) == "string" then
        actualIndentLevel = 1
        actualWidth = indentLevel
        actualDisabled = width
        actualDefault = disabled
    elseif type(indentLevel) == "number" then
        actualIndentLevel = indentLevel
    end

    local indentedName = SettingsAPI.AddIndent(name, actualIndentLevel)
    return SettingsAPI.CreateSliderOption(
        indentedName,
        tooltip,
        min,
        max,
        step,
        getFunc,
        setFunc,
        actualWidth,
        actualDisabled,
        actualDefault,
        warning,
        decimals,
        requiresReload
    )
end

--- Create an indented editbox option
--- @param name string
--- @param tooltip string
--- @param getFunc function
--- @param setFunc function
--- @param indentLevel number|nil|string (if string, treated as width and indentLevel defaults to 1)
--- @param width string|nil|function (if function, treated as disabled)
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param isMultiline boolean|nil
--- @param isExtraWide boolean|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedEditbox(name, tooltip, getFunc, setFunc, indentLevel, width, disabled, default, warning, isMultiline, isExtraWide, requiresReload)
    -- Handle parameter mismatch: if indentLevel is a string, it's actually width
    local actualIndentLevel = 1
    local actualWidth = width
    local actualDisabled = disabled
    local actualDefault = default

    if type(indentLevel) == "string" then
        actualIndentLevel = 1
        actualWidth = indentLevel
        actualDisabled = width
        actualDefault = disabled
    elseif type(indentLevel) == "number" then
        actualIndentLevel = indentLevel
    end

    local indentedName = SettingsAPI.AddIndent(name, actualIndentLevel)
    return SettingsAPI.CreateEditboxOption(
        indentedName,
        tooltip,
        getFunc,
        setFunc,
        actualWidth,
        actualDisabled,
        actualDefault,
        warning,
        isMultiline,
        isExtraWide,
        requiresReload
    )
end

--- Create an indented colorpicker option
--- @param name string
--- @param tooltip string
--- @param getFunc function Returns r, g, b, a (use unpack for table)
--- @param setFunc function Receives r, g, b, a
--- @param indentLevel number|nil|string (if string, treated as width and indentLevel defaults to 1)
--- @param width string|nil|function (if function, treated as disabled)
--- @param disabled function|nil
--- @param defaultR number|nil
--- @param defaultG number|nil
--- @param defaultB number|nil
--- @param defaultA number|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedColorpicker(name, tooltip, getFunc, setFunc, indentLevel, width, disabled, defaultR, defaultG, defaultB, defaultA, warning, requiresReload)
    -- Handle parameter mismatch: if indentLevel is a string, it's actually width
    local actualIndentLevel = 1
    local actualWidth = width
    local actualDisabled = disabled

    if type(indentLevel) == "string" then
        actualIndentLevel = 1
        actualWidth = indentLevel
        actualDisabled = width
    elseif type(indentLevel) == "number" then
        actualIndentLevel = indentLevel
    end

    local indentedName = SettingsAPI.AddIndent(name, actualIndentLevel)
    return SettingsAPI.CreateColorpickerOption(
        indentedName,
        tooltip,
        getFunc,
        setFunc,
        actualWidth,
        actualDisabled,
        defaultR,
        defaultG,
        defaultB,
        defaultA,
        warning,
        requiresReload
    )
end

--- Create an indented dropdown option
--- @param name string
--- @param tooltip string
--- @param choices table
--- @param getFunc function
--- @param setFunc function
--- @param indentLevel number|nil|string (if string, treated as width and indentLevel defaults to 1)
--- @param width string|nil|function (if function, treated as disabled)
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param sort string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedDropdown(name, tooltip, choices, getFunc, setFunc, indentLevel, width, disabled, default, warning, sort, requiresReload)
    -- Handle parameter mismatch: if indentLevel is a string, it's actually width
    local actualIndentLevel = 1
    local actualWidth = width
    local actualDisabled = disabled
    local actualDefault = default

    if type(indentLevel) == "string" then
        actualIndentLevel = 1
        actualWidth = indentLevel
        actualDisabled = width
        actualDefault = disabled
    elseif type(indentLevel) == "number" then
        actualIndentLevel = indentLevel
    end

    local indentedName = SettingsAPI.AddIndent(name, actualIndentLevel)
    return SettingsAPI.CreateDropdownOption(
        indentedName,
        tooltip,
        choices,
        getFunc,
        setFunc,
        actualWidth,
        actualDisabled,
        actualDefault,
        warning,
        sort,
        requiresReload
    )
end

--- Extract colorpicker default values from a settings table
--- @param colorTable table Table containing color values [1]=r, [2]=g, [3]=b, [4]=a
--- @return number r
--- @return number g
--- @return number b
--- @return number|nil a
function SettingsAPI.UnpackColorDefaults(colorTable)
    if colorTable then
        return colorTable[1], colorTable[2], colorTable[3], colorTable[4]
    end
    return nil, nil, nil, nil
end

--- Create a colorpicker option with simplified default handling from color table
--- @param name string
--- @param tooltip string
--- @param getFunc function Returns r, g, b, a (use unpack for table)
--- @param setFunc function Receives r, g, b, a
--- @param defaultColorTable table Table containing [1]=r, [2]=g, [3]=b, [4]=a (optional)
--- @param width string|nil
--- @param disabled function|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateColorpickerFromTable(name, tooltip, getFunc, setFunc, defaultColorTable, width, disabled, warning, requiresReload)
    local r, g, b, a = SettingsAPI.UnpackColorDefaults(defaultColorTable)
    return SettingsAPI.CreateColorpickerOption(
        name,
        tooltip,
        getFunc,
        setFunc,
        width,
        disabled,
        r,
        g,
        b,
        a,
        warning,
        requiresReload
    )
end

--- Create an indented colorpicker option with simplified default handling from color table
--- @param name string
--- @param tooltip string
--- @param getFunc function Returns r, g, b, a (use unpack for table)
--- @param setFunc function Receives r, g, b, a
--- @param defaultColorTable table Table containing [1]=r, [2]=g, [3]=b, [4]=a (optional)
--- @param indentLevel number|nil
--- @param width string|nil
--- @param disabled function|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedColorpickerFromTable(name, tooltip, getFunc, setFunc, defaultColorTable, indentLevel, width, disabled, warning, requiresReload)
    local indentedName = SettingsAPI.AddIndent(name, indentLevel)
    local r, g, b, a = SettingsAPI.UnpackColorDefaults(defaultColorTable)
    return SettingsAPI.CreateColorpickerOption(
        indentedName,
        tooltip,
        getFunc,
        setFunc,
        width,
        disabled,
        r, g, b, a,
        warning,
        requiresReload
    )
end

-- -----------------------------------------------------------------------------
-- Aliases for "Option" suffix variants (for compatibility with existing code)
-- -----------------------------------------------------------------------------

--- Alias for CreateIndentedCheckbox
SettingsAPI.CreateIndentedCheckboxOption = SettingsAPI.CreateIndentedCheckbox

--- Alias for CreateIndentedSlider
SettingsAPI.CreateIndentedSliderOption = SettingsAPI.CreateIndentedSlider

--- Alias for CreateIndentedEditbox
SettingsAPI.CreateIndentedEditboxOption = SettingsAPI.CreateIndentedEditbox

--- Alias for CreateIndentedDropdown
SettingsAPI.CreateIndentedDropdownOption = SettingsAPI.CreateIndentedDropdown

--- Alias for CreateIndentedColorpicker
SettingsAPI.CreateIndentedColorpickerOption = SettingsAPI.CreateIndentedColorpicker

-- -----------------------------------------------------------------------------
-- Cache Management
-- -----------------------------------------------------------------------------

--- Clear media cache (useful for when LMP is loaded after initial load)
function SettingsAPI.ClearMediaCache()
    mediaCache.fonts = nil
    mediaCache.sounds = nil
    mediaCache.statusbarTextures = nil
end

--- Force refresh of all media lists
function SettingsAPI.RefreshMediaLists()
    SettingsAPI.ClearMediaCache()
    SettingsAPI.GetFontsList()
    SettingsAPI.GetSoundsList()
    SettingsAPI.GetStatusbarTexturesList()
end

--- Handle dynamic media registration from other addons
--- @param mediaType string The media type that was registered
--- @param mediaName string The name of the media that was registered
function SettingsAPI.HandleMediaRegistration(mediaType, mediaName)
    if mediaType == LMP.MediaType.FONT then
        LUIE.Fonts[mediaName] = LMP:Fetch(mediaType, mediaName)
    elseif mediaType == LMP.MediaType.SOUND then
        LUIE.Sounds[mediaName] = LMP:Fetch(mediaType, mediaName)
    elseif mediaType == LMP.MediaType.STATUSBAR then
        LUIE.StatusbarTextures[mediaName] = LMP:Fetch(mediaType, mediaName)
    end

    SettingsAPI.ClearMediaCache()
end

--- Get media path for a specific media name and type
--- @param mediaType string The media type
--- @param mediaName string The media name
--- @return string|nil The media path or nil if not found
function SettingsAPI.GetMediaPath(mediaType, mediaName)
    return LMP:Fetch(mediaType, mediaName)
end

--- Check if a media item exists
--- @param mediaType string The media type
--- @param mediaName string The media name
--- @return boolean True if the media exists
function SettingsAPI.IsMediaValid(mediaType, mediaName)
    return LMP:IsValid(mediaType, mediaName)
end

--- Get the LibMediaProvider instance
--- @return table The LibMediaProvider instance
function SettingsAPI.GetLibMediaProvider()
    return LMP
end

--- Get the LibMediaProvider MediaType constants
--- @return table The MediaType constants
function SettingsAPI.GetMediaTypes()
    return LMP.MediaType
end

return SettingsAPI
