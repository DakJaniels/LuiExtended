-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local separateCaptionFontCategories = UnitFrames.APPEARANCE_SEPARATE_CAPTION_FONT_CATEGORIES

--- @param category string
--- @return boolean
local function categoryUsesSeparateCaptionFont(category)
    return separateCaptionFontCategories[category] == true
end

local function __applyFont(unitTag)
    -- First try selecting font face
    local fontName = LUIE.Fonts[UnitFrames.SV.DefaultFontFace]
    if not fontName or fontName == "" then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE:Log("Debug",GetString(LUIE_STRING_ERROR_FONT))
        -- end
        fontName = "LUIE Default Font"
    end

    local fontStyle = UnitFrames.SV.DefaultFontStyle
    local fontSize = (UnitFrames.SV.DefaultFontSize and UnitFrames.SV.DefaultFontSize > 0) and UnitFrames.SV.DefaultFontSize or 16


    if UnitFrames.DefaultFrames[unitTag] then
        local unitFrame = UnitFrames.DefaultFrames[unitTag]
        local fontString = LUIE.CreateFontString(fontName, fontSize, fontStyle)
        for _, powerType in pairs({ COMBAT_MECHANIC_FLAGS_HEALTH, COMBAT_MECHANIC_FLAGS_MAGICKA, COMBAT_MECHANIC_FLAGS_STAMINA }) do
            if unitFrame[powerType] then
                unitFrame[powerType].label:SetFont(fontString)
            end
        end
    end
end

--- Apply default text colour to a single default frame's power labels (module-scope helper).
local function ApplyDefaultFrameColor(unitTag)
    if UnitFrames.DefaultFrames[unitTag] then
        local unitFrame = UnitFrames.DefaultFrames[unitTag]
        for _, powerType in pairs({ COMBAT_MECHANIC_FLAGS_HEALTH, COMBAT_MECHANIC_FLAGS_MAGICKA, COMBAT_MECHANIC_FLAGS_STAMINA }) do
            if unitFrame[powerType] then
                unitFrame[powerType].color = UnitFrames.SV.DefaultTextColour
                unitFrame[powerType].label:SetColor(UnitFrames.SV.DefaultTextColour[1], UnitFrames.SV.DefaultTextColour[2], UnitFrames.SV.DefaultTextColour[3])
            end
        end
    end
end

--- Create a font string for custom frames (module-scope helper to avoid closure in CustomFramesApplyFont).
local function CustomFramesMakeFont(fontName, fontStyle, size)
    return LUIE.CreateFontString(fontName, size, fontStyle)
end

local function ResolveCustomFrameFont(appearance)
    local fontName = LUIE.Fonts[appearance.fontFace]
    if not fontName or fontName == "" then
        fontName = "LUIE Default Font"
    end
    local fontStyle = appearance.fontStyle
    local sizeCaption = (appearance.fontOther and appearance.fontOther > 0) and appearance.fontOther or 16
    local sizeBars = (appearance.fontBars and appearance.fontBars > 0) and appearance.fontBars or 14
    return fontName, fontStyle, sizeCaption, sizeBars
end

local function ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
    if unitFrame.name then
        unitFrame.name:SetFont(fontCaption)
    end
    if unitFrame.level then
        unitFrame.level:SetFont(fontCaption)
    end
    if unitFrame.className then
        unitFrame.className:SetFont(fontCaption)
    end
    if unitFrame.title then
        unitFrame.title:SetFont(fontCaption)
    end
    if unitFrame.avaRank then
        unitFrame.avaRank:SetFont(fontCaption)
    end
    if unitFrame.dead then
        unitFrame.dead:SetFont(fontBars)
    end
    local health = unitFrame[COMBAT_MECHANIC_FLAGS_HEALTH]
    if health then
        if health.label then
            health.label:SetFont(fontBars)
        end
        if health.labelOne then
            health.labelOne:SetFont(fontBars)
        end
        if health.labelTwo then
            health.labelTwo:SetFont(fontBars)
        end
    end
    local magicka = unitFrame[COMBAT_MECHANIC_FLAGS_MAGICKA]
    if magicka then
        if magicka.label then
            magicka.label:SetFont(fontBars)
        end
        if magicka.labelOne then
            magicka.labelOne:SetFont(fontBars)
        end
        if magicka.labelTwo then
            magicka.labelTwo:SetFont(fontBars)
        end
    end
    local stamina = unitFrame[COMBAT_MECHANIC_FLAGS_STAMINA]
    if stamina then
        if stamina.label then
            stamina.label:SetFont(fontBars)
        end
        if stamina.labelOne then
            stamina.labelOne:SetFont(fontBars)
        end
        if stamina.labelTwo then
            stamina.labelTwo:SetFont(fontBars)
        end
    end
end

local function ApplyCustomFrameNameLabelHeights(unitFrame, sizeCaption)
    if not unitFrame or not unitFrame.tlw then
        return
    end
    unitFrame.name:SetHeight(2 * sizeCaption)
    local nameHeight = unitFrame.name:GetTextHeight()
    unitFrame.topInfo:SetHeight(nameHeight)
    if unitFrame.levelIcon then
        unitFrame.levelIcon:SetDimensions(nameHeight, nameHeight)
        unitFrame.levelIcon:ClearAnchors()
        unitFrame.levelIcon:SetAnchor(LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth() + 1, 0)
    end
    unitFrame.classIcon:SetDimensions(nameHeight + 2, nameHeight + 2)
    if unitFrame.friendIcon then
        unitFrame.friendIcon:SetDimensions(nameHeight + 2, nameHeight + 2)
        unitFrame.friendIcon:ClearAnchors()
        unitFrame.friendIcon:SetAnchor(RIGHT, unitFrame.classIcon, LEFT, nameHeight / 6, 0)
    end
    if unitFrame.botInfo then
        unitFrame.botInfo:SetHeight(nameHeight)
        if unitFrame.alternative then
            unitFrame.alternative.backdrop:SetHeight(zo_ceil(nameHeight / 3) + 2)
            unitFrame.alternative.icon:SetDimensions(nameHeight, nameHeight)
        end
        if unitFrame.title then
            unitFrame.title:SetHeight(2 * sizeCaption)
        end
    end
    if unitFrame.buffAnchor then
        unitFrame.buffAnchor:SetHeight(nameHeight)
    end
end

local function MakeCustomFrameFontStrings(category)
    local appearance = UnitFrames.GetCustomFrameAppearance(category)
    local fontName, fontStyle, sizeCaption, sizeBars = ResolveCustomFrameFont(appearance)
    if not categoryUsesSeparateCaptionFont(category) then
        sizeCaption = sizeBars
    end
    return CustomFramesMakeFont(fontName, fontStyle, sizeCaption), CustomFramesMakeFont(fontName, fontStyle, sizeBars), sizeCaption
end

function UnitFrames.CustomFramesApplyFontPlayer()
    local unitFrame = UnitFrames.CustomFrames["player"]
    if not unitFrame or not unitFrame.tlw then
        return
    end
    local fontCaption, fontBars, sizeCaption = MakeCustomFrameFontStrings("player")
    ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
    ApplyCustomFrameNameLabelHeights(unitFrame, sizeCaption)
end

function UnitFrames.CustomFramesApplyFontTarget()
    local unitFrame = UnitFrames.CustomFrames["reticleover"]
    if not unitFrame or not unitFrame.tlw then
        return
    end
    local fontCaption, fontBars, sizeCaption = MakeCustomFrameFontStrings("target")
    ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
    ApplyCustomFrameNameLabelHeights(unitFrame, sizeCaption)
end

function UnitFrames.CustomFramesApplyFontAva()
    local unitFrame = UnitFrames.CustomFrames["AvaPlayerTarget"]
    if not unitFrame or not unitFrame.tlw then
        return
    end
    local fontCaption, fontBars, sizeCaption = MakeCustomFrameFontStrings("ava")
    ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
    ApplyCustomFrameNameLabelHeights(unitFrame, sizeCaption)
end

function UnitFrames.CustomFramesApplyFontCompanion()
    local unitFrame = UnitFrames.CustomFrames["companion"]
    if not unitFrame or not unitFrame.tlw then
        return
    end
    local fontCaption, fontBars = MakeCustomFrameFontStrings("companion")
    ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
end

function UnitFrames.CustomFramesApplyFontGroup()
    if not (UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["SmallGroup1"].tlw) then
        return
    end
    local fontCaption, fontBars, sizeCaption = MakeCustomFrameFontStrings("group")
    for i = 1, 4 do
        local unitFrame = UnitFrames.CustomFrames["SmallGroup" .. i]
        if unitFrame then
            ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
            ApplyCustomFrameNameLabelHeights(unitFrame, sizeCaption)
        end
    end
end

function UnitFrames.CustomFramesApplyFontRaid()
    if not (UnitFrames.CustomFrames["RaidGroup1"] and UnitFrames.CustomFrames["RaidGroup1"].tlw) then
        return
    end
    local fontCaption, fontBars = MakeCustomFrameFontStrings("raid")
    for i = 1, 12 do
        local unitFrame = UnitFrames.CustomFrames["RaidGroup" .. i]
        if unitFrame then
            ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
        end
    end
end

function UnitFrames.CustomFramesApplyFontPet()
    if not (UnitFrames.CustomFrames["PetGroup1"] and UnitFrames.CustomFrames["PetGroup1"].tlw) then
        return
    end
    local fontCaption, fontBars = MakeCustomFrameFontStrings("pet")
    for i = 1, 7 do
        local unitFrame = UnitFrames.CustomFrames["PetGroup" .. i]
        if unitFrame then
            ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
        end
    end
end

function UnitFrames.CustomFramesApplyFontBoss()
    if not (UnitFrames.CustomFrames["boss1"] and UnitFrames.CustomFrames["boss1"].tlw) then
        return
    end
    local fontCaption, fontBars = MakeCustomFrameFontStrings("boss")
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitFrame = UnitFrames.CustomFrames["boss" .. i]
        if unitFrame then
            ApplyCustomFrameFontToUnitFrame(unitFrame, fontCaption, fontBars)
        end
    end
end

--- Apply fonts for one appearance profile (player, target, group, raid, companion, pet, boss, ava).
--- @param category string
function UnitFrames.CustomFramesApplyFontForCategory(category)
    if category == "player" then
        UnitFrames.CustomFramesApplyFontPlayer()
    elseif category == "target" then
        UnitFrames.CustomFramesApplyFontTarget()
    elseif category == "group" then
        UnitFrames.CustomFramesApplyFontGroup()
    elseif category == "raid" then
        UnitFrames.CustomFramesApplyFontRaid()
    elseif category == "companion" then
        UnitFrames.CustomFramesApplyFontCompanion()
    elseif category == "pet" then
        UnitFrames.CustomFramesApplyFontPet()
    elseif category == "boss" then
        UnitFrames.CustomFramesApplyFontBoss()
    elseif category == "ava" then
        UnitFrames.CustomFramesApplyFontAva()
    end
end

-- Apply selected font for all known label on default unit frames
function UnitFrames.DefaultFramesApplyFont(unitTag)
    -- Apply setting only for one requested unitTag
    if unitTag then
        __applyFont(unitTag)

        -- Otherwise do it for all possible unitTags
    else
        __applyFont("player")
        __applyFont("reticleover")
        for i = 0, 12 do
            __applyFont("group" .. i)
        end
    end
end

-- Reapplies color for default unit frames extender module labels
function UnitFrames.DefaultFramesApplyColor()
    ApplyDefaultFrameColor("player")
    ApplyDefaultFrameColor("reticleover")
    for i = 0, 12 do
        ApplyDefaultFrameColor("group" .. i)
    end
end

-- Apply selected font for all custom frame appearance profiles (init / full refresh).
function UnitFrames.CustomFramesApplyFont()
    UnitFrames.CustomFramesApplyFontPlayer()
    UnitFrames.CustomFramesApplyFontTarget()
    UnitFrames.CustomFramesApplyFontAva()
    UnitFrames.CustomFramesApplyFontCompanion()
    UnitFrames.CustomFramesApplyFontGroup()
    UnitFrames.CustomFramesApplyFontRaid()
    UnitFrames.CustomFramesApplyFontPet()
    UnitFrames.CustomFramesApplyFontBoss()
end
