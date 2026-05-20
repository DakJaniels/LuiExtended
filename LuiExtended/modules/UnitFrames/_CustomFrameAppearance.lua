-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local ipairs = ipairs
local pairs = pairs

--- @type string[]
UnitFrames.APPEARANCE_CATEGORY_IDS =
{
    "player",
    "target",
    "group",
    "raid",
    "companion",
    "pet",
    "boss",
    "ava",
}

local BASE_NAME_TO_CATEGORY =
{
    ["player"] = "player",
    ["reticleover"] = "target",
    ["SmallGroup"] = "group",
    ["RaidGroup"] = "raid",
    ["companion"] = "companion",
    ["PetGroup"] = "pet",
    ["boss"] = "boss",
    ["AvaPlayerTarget"] = "ava",
}

local function LegacyAppearanceFromSV(sv)
    return
    {
        fontFace = sv.CustomFontFace,
        fontStyle = sv.CustomFontStyle,
        fontBars = sv.CustomFontBars,
        fontOther = sv.CustomFontOther,
        texture = sv.CustomTexture,
    }
end

local function NormalizeAppearanceEntry(entry, legacy)
    entry = entry or {}
    legacy = legacy or {}
    return
    {
        fontFace = entry.fontFace or legacy.fontFace,
        fontStyle = entry.fontStyle or legacy.fontStyle,
        fontBars = (entry.fontBars and entry.fontBars > 0) and entry.fontBars or legacy.fontBars,
        fontOther = (entry.fontOther and entry.fontOther > 0) and entry.fontOther or legacy.fontOther,
        texture = entry.texture or legacy.texture,
    }
end

--- @param baseName string
--- @return string|nil
function UnitFrames.GetAppearanceCategoryForBaseName(baseName)
    return BASE_NAME_TO_CATEGORY[baseName]
end

--- Ensures SV table exists for a category (mutates SV).
--- @param category string
--- @return table
function UnitFrames.EnsureCustomFrameAppearance(category)
    local sv = UnitFrames.SV
    if not sv.CustomFrameAppearance then
        sv.CustomFrameAppearance = {}
    end
    if not sv.CustomFrameAppearance[category] then
        sv.CustomFrameAppearance[category] = {}
    end
    return sv.CustomFrameAppearance[category]
end

--- @param category string
--- @return table fontFace, fontStyle, fontBars, fontOther, texture
function UnitFrames.GetCustomFrameAppearance(category)
    local sv = UnitFrames.SV
    local defaults = UnitFrames.Defaults
    local legacy = LegacyAppearanceFromSV(sv)
    local defaultEntry = defaults.CustomFrameAppearance and defaults.CustomFrameAppearance[category]
    local defaultLegacy = defaultEntry and NormalizeAppearanceEntry(defaultEntry, LegacyAppearanceFromSV(defaults)) or LegacyAppearanceFromSV(defaults)
    local entry = sv.CustomFrameAppearance and sv.CustomFrameAppearance[category]
    local normalized = NormalizeAppearanceEntry(entry, legacy)
    if not normalized.fontBars or normalized.fontBars <= 0 then
        normalized.fontBars = defaultLegacy.fontBars or 14
    end
    if not normalized.fontOther or normalized.fontOther <= 0 then
        normalized.fontOther = defaultLegacy.fontOther or 16
    end
    if not normalized.fontFace or normalized.fontFace == "" then
        normalized.fontFace = defaultLegacy.fontFace
    end
    if normalized.fontStyle == nil then
        normalized.fontStyle = defaultLegacy.fontStyle
    end
    if not normalized.texture or normalized.texture == "" then
        normalized.texture = defaultLegacy.texture
    end
    return normalized
end

--- One-time migration from global custom font/texture keys.
function UnitFrames.MigrateCustomFrameAppearance()
    if LUIE.IsMigrationDone("unitframes_custom_appearance_v1") then
        return
    end
    local sv = UnitFrames.SV
    local legacy =
    {
        fontFace = sv.CustomFontFace,
        fontStyle = LUIE.MigrateFontStyle(sv.CustomFontStyle),
        fontBars = sv.CustomFontBars,
        fontOther = sv.CustomFontOther,
        texture = sv.CustomTexture,
    }
    if not sv.CustomFrameAppearance then
        sv.CustomFrameAppearance = {}
    end
    for _, category in ipairs(UnitFrames.APPEARANCE_CATEGORY_IDS) do
        if not sv.CustomFrameAppearance[category] then
            sv.CustomFrameAppearance[category] =
            {
                fontFace = legacy.fontFace,
                fontStyle = legacy.fontStyle,
                fontBars = legacy.fontBars,
                fontOther = legacy.fontOther,
                texture = legacy.texture,
            }
        else
            local entry = sv.CustomFrameAppearance[category]
            entry.fontFace = entry.fontFace or legacy.fontFace
            entry.fontStyle = LUIE.MigrateFontStyle(entry.fontStyle or legacy.fontStyle)
            entry.fontBars = entry.fontBars or legacy.fontBars
            entry.fontOther = entry.fontOther or legacy.fontOther
            entry.texture = entry.texture or legacy.texture
        end
    end
    LUIE.MarkMigrationDone("unitframes_custom_appearance_v1")
end
