-- -----------------------------------------------------------------------------
--  LuiExtended Settings API                                                    --
--  Common utility functions for settings modules                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Settings API namespace
local SettingsAPI = {}
LUIE.SettingsAPI = SettingsAPI

-- Local references.
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
-- Media Registration Functions
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
    -- Register LUIE's own media
    RegisterLUIEMedia(LMP.MediaType.FONT, LUIE.Fonts)
    RegisterLUIEMedia(LMP.MediaType.SOUND, LUIE.Sounds)
    RegisterLUIEMedia(LMP.MediaType.STATUSBAR, LUIE.StatusbarTextures)
end

--- Fetch additional media from other addons
function SettingsAPI.FetchExternalMedia()
    -- Fetch additional media from other addons
    FetchExternalMedia(LMP.MediaType.FONT, LUIE.Fonts)
    FetchExternalMedia(LMP.MediaType.SOUND, LUIE.Sounds)
    FetchExternalMedia(LMP.MediaType.STATUSBAR, LUIE.StatusbarTextures)
end

-- Create platform-appropriate system font (only created once at load time)
function SettingsAPI.CreateSystemFont()
    if not LUIE.Fonts["LUIE Default Font"] then
        local systemFont = CreateFont("LUIE_SystemFont")
        if IsInGamepadPreferredMode() or IsConsoleUI() then
            systemFont:SetFont("$(GAMEPAD_BOLD_FONT)|$(GP_18)|soft-shadow-thick")
        else
            systemFont:SetFont("$(BOLD_FONT)|$(KB_18)|soft-shadow-thick")
        end
        LUIE.Fonts["LUIE Default Font"] = systemFont:GetFontInfo()
    end
end

--- Load all media (register LUIE + fetch external)
function SettingsAPI.LoadAllMedia()
    SettingsAPI.CreateSystemFont()
    SettingsAPI.RegisterLUIEMedia()
    SettingsAPI.FetchExternalMedia()
    SettingsAPI.ClearMediaCache() -- Clear cache after loading new media
end

-- -----------------------------------------------------------------------------
-- Media List Generation Functions
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
        -- Only add if not already in list
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
        -- Only add if not already in list
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
        -- Only add if not already in list
        if not LUIE.StatusbarTextures[texture] then
            table_insert(statusbarTexturesList, texture)
        end
    end

    mediaCache.statusbarTextures = statusbarTexturesList
    return statusbarTexturesList
end

-- -----------------------------------------------------------------------------
-- Common Option Creation Helpers
-- -----------------------------------------------------------------------------

--- Create a standard checkbox option
--- @param name string
--- @param tooltip string|nil
--- @param getFunc function
--- @param setFunc function
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @param resetFunc function|nil
--- @return table option
function SettingsAPI.CreateCheckboxOption(name, tooltip, getFunc, setFunc, width, disabled, default, warning, requiresReload, resetFunc)
    local option =
    {
        type = "checkbox",
        name = name,
        getFunc = getFunc,
        setFunc = setFunc,
        width = width or "full"
    }

    if tooltip then
        option.tooltip = tooltip
    end

    if disabled then
        option.disabled = disabled
    end

    if default ~= nil then
        option.default = default
    end

    if warning then
        option.warning = warning
    end

    if requiresReload then
        option.requiresReload = true
    end

    if resetFunc then
        option.resetFunc = resetFunc
    end

    return option
end

--- Create a standard dropdown option
--- @param name string
--- @param tooltip string|nil
--- @param choices table
--- @param getFunc function
--- @param setFunc function
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param sort string|nil
--- @param requiresReload boolean|nil
--- @param choicesValues table|nil
--- @param scrollable boolean|number|nil
--- @return table option
function SettingsAPI.CreateDropdownOption(name, tooltip, choices, getFunc, setFunc, width, disabled, default, warning, sort, requiresReload, choicesValues, scrollable)
    local option =
    {
        type = "dropdown",
        name = name,
        choices = choices,
        getFunc = getFunc,
        setFunc = setFunc,
        width = width or "full"
    }

    if tooltip then
        option.tooltip = tooltip
    end

    if disabled then
        option.disabled = disabled
    end

    if default ~= nil then
        option.default = default
    end

    if warning then
        option.warning = warning
    end

    if sort then
        option.sort = sort
    end

    if requiresReload then
        option.requiresReload = true
    end

    if choicesValues then
        option.choicesValues = choicesValues
    end

    if scrollable then
        option.scrollable = scrollable
    end

    return option
end

--- Create a standard slider option
--- @param name string
--- @param tooltip string|nil
--- @param min number
--- @param max number
--- @param step number
--- @param getFunc function
--- @param setFunc function
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param decimals number|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateSliderOption(name, tooltip, min, max, step, getFunc, setFunc, width, disabled, default, warning, decimals, requiresReload)
    local option =
    {
        type = "slider",
        name = name,
        min = min,
        max = max,
        step = step,
        getFunc = getFunc,
        setFunc = setFunc,
        width = width or "full"
    }

    if tooltip then
        option.tooltip = tooltip
    end

    if disabled then
        option.disabled = disabled
    end

    if default ~= nil then
        option.default = default
    end

    if warning then
        option.warning = warning
    end

    if decimals then
        option.decimals = decimals
    end

    if requiresReload then
        option.requiresReload = true
    end

    return option
end

--- Create a standard editbox option
--- @param name string
--- @param tooltip string|nil
--- @param getFunc function
--- @param setFunc function
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param isMultiline boolean|nil
--- @param isExtraWide boolean|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateEditboxOption(name, tooltip, getFunc, setFunc, width, disabled, default, warning, isMultiline, isExtraWide, requiresReload)
    local option =
    {
        type = "editbox",
        name = name,
        getFunc = getFunc,
        setFunc = setFunc,
        width = width or "full"
    }

    if tooltip then
        option.tooltip = tooltip
    end

    if disabled then
        option.disabled = disabled
    end

    if default ~= nil then
        option.default = default
    end

    if warning then
        option.warning = warning
    end

    if isMultiline then
        option.isMultiline = true
    end

    if isExtraWide then
        option.isExtraWide = true
    end

    if requiresReload then
        option.requiresReload = true
    end

    return option
end

--- Create a standard colorpicker option
--- @param name string
--- @param tooltip string|nil
--- @param getFunc function Returns r, g, b, a (use unpack for table)
--- @param setFunc function Receives r, g, b, a
--- @param width string|nil
--- @param disabled function|nil
--- @param defaultR number|nil
--- @param defaultG number|nil
--- @param defaultB number|nil
--- @param defaultA number|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateColorpickerOption(name, tooltip, getFunc, setFunc, width, disabled, defaultR, defaultG, defaultB, defaultA, warning, requiresReload)
    local option =
    {
        type = "colorpicker",
        name = name,
        getFunc = getFunc,
        setFunc = setFunc,
        width = width or "full"
    }

    if tooltip then
        option.tooltip = tooltip
    end

    if disabled then
        option.disabled = disabled
    end

    if defaultR and defaultG and defaultB then
        option.default =
        {
            r = defaultR,
            g = defaultG,
            b = defaultB,
        }
        if defaultA then
            option.default.a = defaultA
        end
    end

    if warning then
        option.warning = warning
    end

    if requiresReload then
        option.requiresReload = true
    end

    return option
end

--- Create a standard button option
--- @param name string
--- @param tooltip string|nil
--- @param func function
--- @param width string|nil
--- @param disabled function|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateButtonOption(name, tooltip, func, width, disabled, warning, requiresReload)
    local option =
    {
        type = "button",
        name = name,
        func = func,
        width = width or "full"
    }

    if tooltip then
        option.tooltip = tooltip
    end

    if disabled then
        option.disabled = disabled
    end

    if warning then
        option.warning = warning
    end

    if requiresReload then
        option.requiresReload = true
    end

    return option
end

--- Create a standard description option
--- @param text string
--- @param width string|nil
--- @param title string|nil
--- @return table option
function SettingsAPI.CreateDescriptionOption(text, width, title)
    local option =
    {
        type = "description",
        text = text,
        width = width or "full"
    }

    if title then
        option.title = title
    end

    return option
end

--- Create a standard header option
--- @param name string
--- @param width string|nil
--- @return table option
function SettingsAPI.CreateHeaderOption(name, width)
    return
    {
        type = "header",
        name = name,
        width = width or "full"
    }
end

--- Create a standard divider option
--- @param width string|nil
--- @param height number|nil
--- @param alpha number|nil
--- @return table option
function SettingsAPI.CreateDividerOption(width, height, alpha)
    local option =
    {
        type = "divider",
        width = width or "full"
    }

    if height then
        option.height = height
    end

    if alpha then
        option.alpha = alpha
    end

    return option
end

--- Create a standard submenu option
--- @param name string
--- @param controls table
--- @param reference string|nil
--- @return table option
function SettingsAPI.CreateSubmenuOption(name, controls, reference)
    local option =
    {
        type = "submenu",
        name = name,
        controls = controls
    }

    if reference then
        option.reference = reference
    end

    return option
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

-- -----------------------------------------------------------------------------
-- Utility Functions
-- -----------------------------------------------------------------------------

--- Add indentation to an option name
--- @param name string
--- @param level number Number of tab indents (default 1 = 5 tabs)
--- @return string indentedName
function SettingsAPI.AddIndent(name, level)
    level = level or 1
    local tabs = string.rep("\t\t\t\t\t", level)
    return zo_strformat("<<1>><<2>>", tabs, name)
end

--- Create an indented checkbox option (common pattern for nested settings)
--- @param name string
--- @param tooltip string
--- @param getFunc function
--- @param setFunc function
--- @param indentLevel number|nil
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedCheckbox(name, tooltip, getFunc, setFunc, indentLevel, width, disabled, default, warning, requiresReload)
    local indentedName = SettingsAPI.AddIndent(name, indentLevel)
    return SettingsAPI.CreateCheckboxOption(
        indentedName,
        tooltip,
        getFunc,
        setFunc,
        width,
        disabled,
        default,
        warning,
        requiresReload
    )
end

--- Create an indented slider option (common pattern for nested settings)
--- @param name string
--- @param tooltip string
--- @param min number
--- @param max number
--- @param step number
--- @param getFunc function
--- @param setFunc function
--- @param indentLevel number|nil
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param decimals number|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedSlider(name, tooltip, min, max, step, getFunc, setFunc, indentLevel, width, disabled, default, warning, decimals, requiresReload)
    local indentedName = SettingsAPI.AddIndent(name, indentLevel)
    return SettingsAPI.CreateSliderOption(
        indentedName,
        tooltip,
        min,
        max,
        step,
        getFunc,
        setFunc,
        width,
        disabled,
        default,
        warning,
        decimals,
        requiresReload
    )
end

--- Create an indented editbox option (common pattern for nested settings)
--- @param name string
--- @param tooltip string
--- @param getFunc function
--- @param setFunc function
--- @param indentLevel number|nil
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param isMultiline boolean|nil
--- @param isExtraWide boolean|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedEditbox(name, tooltip, getFunc, setFunc, indentLevel, width, disabled, default, warning, isMultiline, isExtraWide, requiresReload)
    local indentedName = SettingsAPI.AddIndent(name, indentLevel)
    return SettingsAPI.CreateEditboxOption(
        indentedName,
        tooltip,
        getFunc,
        setFunc,
        width,
        disabled,
        default,
        warning,
        isMultiline,
        isExtraWide,
        requiresReload
    )
end

--- Create an indented colorpicker option (common pattern for nested settings)
--- @param name string
--- @param tooltip string
--- @param getFunc function Returns r, g, b, a (use unpack for table)
--- @param setFunc function Receives r, g, b, a
--- @param indentLevel number|nil
--- @param width string|nil
--- @param disabled function|nil
--- @param defaultR number|nil
--- @param defaultG number|nil
--- @param defaultB number|nil
--- @param defaultA number|nil
--- @param warning string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedColorpicker(name, tooltip, getFunc, setFunc, indentLevel, width, disabled, defaultR, defaultG, defaultB, defaultA, warning, requiresReload)
    local indentedName = SettingsAPI.AddIndent(name, indentLevel)
    return SettingsAPI.CreateColorpickerOption(
        indentedName,
        tooltip,
        getFunc,
        setFunc,
        width,
        disabled,
        defaultR,
        defaultG,
        defaultB,
        defaultA,
        warning,
        requiresReload
    )
end

--- Create an indented dropdown option (common pattern for nested settings)
--- @param name string
--- @param tooltip string
--- @param choices table
--- @param getFunc function
--- @param setFunc function
--- @param indentLevel number|nil
--- @param width string|nil
--- @param disabled function|nil
--- @param default any|nil
--- @param warning string|nil
--- @param sort string|nil
--- @param requiresReload boolean|nil
--- @return table option
function SettingsAPI.CreateIndentedDropdown(name, tooltip, choices, getFunc, setFunc, indentLevel, width, disabled, default, warning, sort, requiresReload)
    local indentedName = SettingsAPI.AddIndent(name, indentLevel)
    return SettingsAPI.CreateDropdownOption(
        indentedName,
        tooltip,
        choices,
        getFunc,
        setFunc,
        width,
        disabled,
        default,
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
        r, g, b, a,
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
    -- Update the appropriate LUIE media table
    if mediaType == LMP.MediaType.FONT then
        LUIE.Fonts[mediaName] = LMP:Fetch(mediaType, mediaName)
    elseif mediaType == LMP.MediaType.SOUND then
        LUIE.Sounds[mediaName] = LMP:Fetch(mediaType, mediaName)
    elseif mediaType == LMP.MediaType.STATUSBAR then
        LUIE.StatusbarTextures[mediaName] = LMP:Fetch(mediaType, mediaName)
    end

    -- Clear cache to force regeneration with new media
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
