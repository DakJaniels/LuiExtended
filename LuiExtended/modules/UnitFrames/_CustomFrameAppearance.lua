-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local ipairs = ipairs

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

--- Categories whose custom frames use a separate `_TopInfo` caption row (see CustomFrames/*CustomFrameData.lua).
UnitFrames.APPEARANCE_SEPARATE_CAPTION_FONT_CATEGORIES =
{
    player = true,
    target = true,
    group = true,
    ava = true,
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

local function NormalizeAppearanceEntry(entry, fallback)
    entry = entry or {}
    fallback = fallback or {}
    return
    {
        fontFace = entry.fontFace or fallback.fontFace,
        fontStyle = entry.fontStyle or fallback.fontStyle,
        fontBars = (entry.fontBars and entry.fontBars > 0) and entry.fontBars or fallback.fontBars,
        fontOther = (entry.fontOther and entry.fontOther > 0) and entry.fontOther or fallback.fontOther,
        texture = entry.texture or fallback.texture,
    }
end

--- @param baseName string
--- @return string|nil
function UnitFrames.GetAppearanceCategoryForBaseName(baseName)
    return BASE_NAME_TO_CATEGORY[baseName]
end

--- @param category string
--- @return {
---    fontBars: integer,
---    fontFace: string,
---    fontOther: integer,
---    fontStyle: integer,
---    texture: string,
--- }
function UnitFrames.GetCustomFrameAppearance(category)
    local sv = UnitFrames.SV
    local defaults = UnitFrames.Defaults
    local defaultEntry = defaults.CustomFrameAppearance and defaults.CustomFrameAppearance[category]
    local defaultAppearance = NormalizeAppearanceEntry(defaultEntry, {})
    local entry = sv.CustomFrameAppearance and sv.CustomFrameAppearance[category]
    local normalized = NormalizeAppearanceEntry(entry, defaultAppearance)
    if not normalized.fontBars or normalized.fontBars <= 0 then
        normalized.fontBars = defaultAppearance.fontBars or 14
    end
    if not normalized.fontOther or normalized.fontOther <= 0 then
        normalized.fontOther = defaultAppearance.fontOther or 16
    end
    if not normalized.fontFace or normalized.fontFace == "" then
        normalized.fontFace = defaultAppearance.fontFace
    end
    if normalized.fontStyle == nil then
        normalized.fontStyle = defaultAppearance.fontStyle
    end
    if not normalized.texture or normalized.texture == "" then
        normalized.texture = defaultAppearance.texture
    end
    -- Single Font Size slider categories: keep fontOther aligned with fontBars at read time.
    if not UnitFrames.APPEARANCE_SEPARATE_CAPTION_FONT_CATEGORIES[category] then
        normalized.fontOther = normalized.fontBars
    end
    return normalized
end

--- One-time migration from global custom font/texture keys.
--- Seeds each per-category entry from the legacy `Custom*` SV keys, then deletes
--- those legacy keys so subsequent reads have no cross-category fallback path.
--- Treats both `nil` and `<= 0` per-category fields as needing fill. Marks both
--- the v1 and v2 migration keys done in a single pass (v2 was previously a
--- separate, redundant fill of `<= 0` values).
function UnitFrames.MigrateCustomFrameAppearance()
    if LUIE.IsMigrationDone("unitframes_custom_appearance_v1") and LUIE.IsMigrationDone("unitframes_custom_appearance_v2") then
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
        local entry = sv.CustomFrameAppearance[category]
        if not entry then
            entry = {}
            sv.CustomFrameAppearance[category] = entry
        end
        if not entry.fontFace or entry.fontFace == "" then
            entry.fontFace = legacy.fontFace
        end
        entry.fontStyle = LUIE.MigrateFontStyle(entry.fontStyle or legacy.fontStyle)
        if not entry.fontBars or entry.fontBars <= 0 then
            entry.fontBars = legacy.fontBars
        end
        if not entry.fontOther or entry.fontOther <= 0 then
            entry.fontOther = legacy.fontOther
        end
        if not entry.texture or entry.texture == "" then
            entry.texture = legacy.texture
        end
    end
    sv.CustomFontFace = nil
    sv.CustomFontStyle = nil
    sv.CustomFontBars = nil
    sv.CustomFontOther = nil
    sv.CustomTexture = nil
    LUIE.MarkMigrationDone("unitframes_custom_appearance_v1")
    LUIE.MarkMigrationDone("unitframes_custom_appearance_v2")
end

--- One-time sync of fontOther to fontBars for compact appearance categories (raid, companion, pet, boss).
function UnitFrames.MigrateCustomFrameAppearanceCompactFontSync()
    if LUIE.IsMigrationDone("unitframes_custom_appearance_v3") then
        return
    end
    local sv = UnitFrames.SV
    if not sv.CustomFrameAppearance then
        sv.CustomFrameAppearance = {}
    end
    for _, category in ipairs(UnitFrames.APPEARANCE_CATEGORY_IDS) do
        if not UnitFrames.APPEARANCE_SEPARATE_CAPTION_FONT_CATEGORIES[category] then
            local entry = sv.CustomFrameAppearance[category]
            if not entry then
                entry = {}
                sv.CustomFrameAppearance[category] = entry
            end
            if entry.fontBars and entry.fontBars > 0 then
                entry.fontOther = entry.fontBars
            elseif entry.fontOther and entry.fontOther > 0 then
                entry.fontBars = entry.fontOther
            end
        end
    end
    LUIE.MarkMigrationDone("unitframes_custom_appearance_v3")
end

local LUIE_DEFAULT_FONT_FACE = "LUIE Default Font"
local LUIE_DEFAULT_TEXTURE = "Minimalistic"

local FONT_FACE_ALIASES =
{
    ["LUIE-Standardschrift"] = LUIE_DEFAULT_FONT_FACE,
}

local TEXTURE_ALIASES =
{
    ["Minimalistisch"] = LUIE_DEFAULT_TEXTURE,
}

local function NormalizeLuiMediaFontFaceKey(fontFace)
    if not fontFace or fontFace == "" then
        return fontFace
    end
    if LUIE.Fonts[fontFace] then
        return fontFace
    end
    return FONT_FACE_ALIASES[fontFace] or fontFace
end

local function NormalizeLuiMediaTextureKey(texture)
    if not texture or texture == "" then
        return texture
    end
    return TEXTURE_ALIASES[texture] or texture
end

--- Fixes saved font/texture keys that were localized (must match LuiMedia registry names).
function UnitFrames.MigrateLuiMediaAppearanceKeys()
    if LUIE.IsMigrationDone("unitframes_luimedia_registry_keys") then
        return
    end
    local sv = UnitFrames.SV
    if sv.DefaultFontFace then
        sv.DefaultFontFace = NormalizeLuiMediaFontFaceKey(sv.DefaultFontFace)
    end
    if sv.CustomFrameAppearance then
        for _, category in ipairs(UnitFrames.APPEARANCE_CATEGORY_IDS) do
            local entry = sv.CustomFrameAppearance[category]
            if entry then
                if entry.fontFace then
                    entry.fontFace = NormalizeLuiMediaFontFaceKey(entry.fontFace)
                end
                if entry.texture then
                    entry.texture = NormalizeLuiMediaTextureKey(entry.texture)
                end
            end
        end
    end
    LUIE.MarkMigrationDone("unitframes_luimedia_registry_keys")
end

--- @param backdrop BackdropControl
--- @param texture string
--- @param isRoundTexture boolean
function UnitFrames.ApplyCustomFrameTextureToBackdrop(backdrop, texture, isRoundTexture)
    backdrop:SetCenterTexture(texture)
    backdrop:SetBlendMode(TEX_BLEND_MODE_ALPHA)
    backdrop:SetPixelRoundingEnabled(true)
    if isRoundTexture then
        backdrop:SetEdgeColor(0, 0, 0, 0)
    else
        backdrop:SetEdgeColor(0, 0, 0, 0.5)
    end
end

local function ApplyCustomFrameHealthTextures(healthFrame, texture, isRoundTexture)
    if not healthFrame then return end
    UnitFrames.ApplyCustomFrameTextureToBackdrop(healthFrame.backdrop, texture, isRoundTexture)
    healthFrame.bar:SetTexture(texture)
    local powerHaloTrack = healthFrame.backdrop:GetNamedChild("_PowerHaloTrack")
    if powerHaloTrack then
        powerHaloTrack:SetTexture(texture)
    end
    if healthFrame.shieldbackdrop then
        UnitFrames.ApplyCustomFrameTextureToBackdrop(healthFrame.shieldbackdrop, texture, isRoundTexture)
    end
    healthFrame.shield:SetTexture(texture)
    healthFrame.trauma:SetTexture(texture)
    if healthFrame.invulnerable then
        healthFrame.invulnerable:SetTexture(texture)
    end
    if healthFrame.invulnerableInlay then
        local invulnerableInlayPath = ZO_IsConsoleOrGameCoreUI() and [[EsoUI/Art/UnitAttributeVisualizer/Gamepad/gp_attributeBar_dynamic_invulnerable_munge.dds]] or LUIE_MEDIA_UNITFRAMES_INVULNERABLE_MUNGE_DDS
        healthFrame.invulnerableInlay:SetTexture(invulnerableInlayPath)
    end
end

local function ApplyCustomFrameResourceTextures(resourceFrame, texture, isRoundTexture)
    if not resourceFrame then return end
    UnitFrames.ApplyCustomFrameTextureToBackdrop(resourceFrame.backdrop, texture, isRoundTexture)
    resourceFrame.bar:SetTexture(texture)
end

local function GetStatusbarTextureForCategory(category)
    local appearance = UnitFrames.GetCustomFrameAppearance(category)
    local textureKey = appearance.texture
    local texture = LUIE.StatusbarTextures[textureKey]
    local isRoundTexture = textureKey == "Tube" or textureKey == "Steel"
    return texture, isRoundTexture
end

function UnitFrames.CustomFramesApplyTexturePlayer()
    local texture, isRoundTexture = GetStatusbarTextureForCategory("player")
    local playerFrame = UnitFrames.CustomFrames["player"]
    if not playerFrame or not playerFrame.tlw then
        return
    end
    ApplyCustomFrameHealthTextures(playerFrame[COMBAT_MECHANIC_FLAGS_HEALTH], texture, isRoundTexture)
    ApplyCustomFrameResourceTextures(playerFrame[COMBAT_MECHANIC_FLAGS_MAGICKA], texture, isRoundTexture)
    ApplyCustomFrameResourceTextures(playerFrame[COMBAT_MECHANIC_FLAGS_STAMINA], texture, isRoundTexture)
    UnitFrames.AlternativeBarApplyTextures(playerFrame.alternative, texture, isRoundTexture)
end

function UnitFrames.CustomFramesApplyTextureTarget()
    local texture, isRoundTexture = GetStatusbarTextureForCategory("target")
    local reticleFrame = UnitFrames.CustomFrames["reticleover"]
    if not reticleFrame or not reticleFrame.tlw then
        return
    end
    ApplyCustomFrameHealthTextures(reticleFrame[COMBAT_MECHANIC_FLAGS_HEALTH], texture, isRoundTexture)
end

function UnitFrames.CustomFramesApplyTextureAva()
    local texture, isRoundTexture = GetStatusbarTextureForCategory("ava")
    local avaFrame = UnitFrames.CustomFrames["AvaPlayerTarget"]
    if not avaFrame or not avaFrame.tlw then
        return
    end
    ApplyCustomFrameHealthTextures(avaFrame[COMBAT_MECHANIC_FLAGS_HEALTH], texture, isRoundTexture)
end

function UnitFrames.CustomFramesApplyTextureCompanion()
    local texture, isRoundTexture = GetStatusbarTextureForCategory("companion")
    local companionFrame = UnitFrames.CustomFrames["companion"]
    if not companionFrame or not companionFrame.tlw then
        return
    end
    ApplyCustomFrameHealthTextures(companionFrame[COMBAT_MECHANIC_FLAGS_HEALTH], texture, isRoundTexture)
end

function UnitFrames.CustomFramesApplyTextureGroup()
    if not (UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["SmallGroup1"].tlw) then
        return
    end
    local texture, isRoundTexture = GetStatusbarTextureForCategory("group")
    for i = 1, 4 do
        ApplyCustomFrameHealthTextures(UnitFrames.CustomFrames["SmallGroup" .. i][COMBAT_MECHANIC_FLAGS_HEALTH], texture, isRoundTexture)
    end
end

function UnitFrames.CustomFramesApplyTextureRaid()
    if not (UnitFrames.CustomFrames["RaidGroup1"] and UnitFrames.CustomFrames["RaidGroup1"].tlw) then
        return
    end
    local texture, isRoundTexture = GetStatusbarTextureForCategory("raid")
    for i = 1, 12 do
        ApplyCustomFrameHealthTextures(UnitFrames.CustomFrames["RaidGroup" .. i][COMBAT_MECHANIC_FLAGS_HEALTH], texture, isRoundTexture)
    end
end

function UnitFrames.CustomFramesApplyTexturePet()
    if not (UnitFrames.CustomFrames["PetGroup1"] and UnitFrames.CustomFrames["PetGroup1"].tlw) then
        return
    end
    local texture, isRoundTexture = GetStatusbarTextureForCategory("pet")
    for i = 1, 7 do
        ApplyCustomFrameHealthTextures(UnitFrames.CustomFrames["PetGroup" .. i][COMBAT_MECHANIC_FLAGS_HEALTH], texture, isRoundTexture)
    end
end

function UnitFrames.CustomFramesApplyTextureBoss()
    if not (UnitFrames.CustomFrames["boss1"] and UnitFrames.CustomFrames["boss1"].tlw) then
        return
    end
    local texture, isRoundTexture = GetStatusbarTextureForCategory("boss")
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        ApplyCustomFrameHealthTextures(UnitFrames.CustomFrames["boss" .. i][COMBAT_MECHANIC_FLAGS_HEALTH], texture, isRoundTexture)
    end
end

--- Apply bar textures for one appearance profile (player, target, group, raid, companion, pet, boss, ava).
--- @param category string
function UnitFrames.CustomFramesApplyTextureForCategory(category)
    if category == "player" then
        UnitFrames.CustomFramesApplyTexturePlayer()
    elseif category == "target" then
        UnitFrames.CustomFramesApplyTextureTarget()
    elseif category == "group" then
        UnitFrames.CustomFramesApplyTextureGroup()
    elseif category == "raid" then
        UnitFrames.CustomFramesApplyTextureRaid()
    elseif category == "companion" then
        UnitFrames.CustomFramesApplyTextureCompanion()
    elseif category == "pet" then
        UnitFrames.CustomFramesApplyTexturePet()
    elseif category == "boss" then
        UnitFrames.CustomFramesApplyTextureBoss()
    elseif category == "ava" then
        UnitFrames.CustomFramesApplyTextureAva()
    end
    if (category == "group" or category == "raid") and UnitFrames.GroupResources then
        UnitFrames.GroupResources.UpdateAllLayouts()
    end
end

-- Apply selected texture for all custom frame appearance profiles (init / full refresh).
function UnitFrames.CustomFramesApplyTexture()
    UnitFrames.CustomFramesApplyTexturePlayer()
    UnitFrames.CustomFramesApplyTextureTarget()
    UnitFrames.CustomFramesApplyTextureAva()
    UnitFrames.CustomFramesApplyTextureCompanion()
    UnitFrames.CustomFramesApplyTextureGroup()
    UnitFrames.CustomFramesApplyTextureRaid()
    UnitFrames.CustomFramesApplyTexturePet()
    UnitFrames.CustomFramesApplyTextureBoss()
    if UnitFrames.GroupResources then
        UnitFrames.GroupResources.UpdateAllLayouts()
    end
end
