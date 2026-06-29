-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- -----------------------------------------------------------------------------
-- Font resolution core.
--
-- ESO loads UI fonts two ways:
--   * Named fonts  - <Font name="ZoFontGame" .../> (ZOS fontdefs) or LUIE_Font_*
--                    (LUIE fontdefs). These are passed to Control:SetFont as-is and
--                    reuse the engine font the base UI already loaded - no per-call
--                    string composition, no extra font instances.
--   * Face fonts   - a face slug / macro (e.g. a LuiMedia custom slug, "$(BOLD_FONT)")
--                    that must be composed into "face|size|style" with
--                    ZO_CreateFontString before SetFont. This is the dynamic path and
--                    is required for user-sized custom faces.
--
-- LUIE.Font routes every runtime font through this distinction so stock/default UI
-- uses named fonts while custom LuiMedia faces keep their size/style sliders.
-- -----------------------------------------------------------------------------

local LMP = LibMediaProvider

local IsInGamepadPreferredMode = IsInGamepadPreferredMode
local ZO_IsConsoleOrGameCoreUI = ZO_IsConsoleOrGameCoreUI
local string_sub = string.sub

-- Media key for the sized default face. Registered by LuiMedia from an existing
-- ZoFont's face (no addon-created font object).
local LUIE_DEFAULT_FONT_KEY = "LUIE Default Font"

-- Platform default named fonts. Valid SetFont tokens with no runtime composition.
-- ZoFontHeader is $(BOLD_FONT)|18|soft-shadow-thick, matching the descriptor LUIE
-- previously built with CreateFont("LUIE_SystemFont", ...).
local KEYBOARD_DEFAULT_FONT = "ZoFontHeader"
local GAMEPAD_DEFAULT_FONT = "ZoFontGamepadBold18"

-- Role -> platform named font, mirroring the ZOS pattern of swapping fonts by
-- platform (see GetPlatformBarFont in esoui unitframes.lua).
local KEYBOARD_ROLE_FONTS =
{
    default = KEYBOARD_DEFAULT_FONT,
    unitFrameBars = "ZoFontGameOutline",
}
local GAMEPAD_ROLE_FONTS =
{
    default = GAMEPAD_DEFAULT_FONT,
    unitFrameBars = "ZoFontGamepad18",
}

local Font = {}
LUIE.Font = Font

Font.DEFAULT_FONT_KEY = LUIE_DEFAULT_FONT_KEY

--- Whether the active UI prefers gamepad/console fonts.
--- @return boolean
local function UseGamepadFonts()
    return IsInGamepadPreferredMode() or ZO_IsConsoleOrGameCoreUI()
end

--- Platform default font as a valid SetFont named token.
--- @return string
function Font.GetDefaultFont()
    if UseGamepadFonts() then
        return GAMEPAD_DEFAULT_FONT
    end
    return KEYBOARD_DEFAULT_FONT
end

--- Named ZoFont token for a built-in UI role (platform-aware).
--- @param role string
--- @return string
function Font.GetPlatformRoleFont(role)
    local roleFonts = UseGamepadFonts() and GAMEPAD_ROLE_FONTS or KEYBOARD_ROLE_FONTS
    return roleFonts[role] or Font.GetDefaultFont()
end

--- Fetch registered media data for a font key (LMP first, LuiMedia mirror fallback).
--- @param mediaKey string|nil
--- @return string|nil data
function Font.FetchMedia(mediaKey)
    if not mediaKey or mediaKey == "" then
        return nil
    end
    local data
    if LMP then
        data = LMP:Fetch(LMP.MediaType.FONT, mediaKey)
    end
    if data == nil then
        data = LUIE.Fonts and LUIE.Fonts[mediaKey]
    end
    return data
end

--- True when font data is a pre-defined UI font name usable directly by SetFont
--- (ZoFont* from ZOS fontdefs or LUIE_Font_* from LUIE fontdefs) rather than a face
--- slug / macro that must be composed with ZO_CreateFontString.
--- @param data string|nil
--- @return boolean
function Font.IsNamedData(data)
    if type(data) ~= "string" then
        return false
    end
    if string_sub(data, 1, 6) == "ZoFont" then
        return true
    end
    if string_sub(data, 1, 10) == "LUIE_Font_" then
        return true
    end
    return false
end

--- Media kind for a font key.
--- @param mediaKey string|nil
--- @return string kind "named" | "face"
function Font.GetMediaKind(mediaKey)
    return Font.IsNamedData(Font.FetchMedia(mediaKey)) and "named" or "face"
end

--- Settings helper: face media needs size/style sliders; named media is fully defined.
--- @param mediaKey string|nil
--- @return boolean
function Font.IsDynamicFaceMedia(mediaKey)
    return not Font.IsNamedData(Font.FetchMedia(mediaKey))
end

--- Resolve a font media key + size + style to a final SetFont argument.
--- Named media returns the named token (zero string composition); face media returns
--- ZO_CreateFontString(face, size, style) (the dynamic custom path).
--- @param mediaKey string|nil
--- @param size number|nil
--- @param style string|number|nil
--- @return string font Valid argument for Control:SetFont
function Font.Resolve(mediaKey, size, style)
    local data = Font.FetchMedia(mediaKey)
    if data == nil or data == "" then
        -- Fall back to the sized default face so user size/style is preserved.
        data = Font.FetchMedia(LUIE_DEFAULT_FONT_KEY)
    end
    if data == nil or data == "" then
        -- Last resort: a guaranteed-valid named token.
        return Font.GetDefaultFont()
    end
    if Font.IsNamedData(data) then
        return data
    end
    return LUIE.CreateFontString(data, size, style)
end

--- Resolve and apply a font to a label.
--- @param label table
--- @param mediaKey string|nil
--- @param size number|nil
--- @param style string|number|nil
function Font.ApplyToLabel(label, mediaKey, size, style)
    label:SetFont(Font.Resolve(mediaKey, size, style))
end
