-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames


local function __applyFont(unitTag)
    -- First try selecting font face
    local fontName = LUIE.Fonts[UnitFrames.SV.DefaultFontFace]
    if not fontName or fontName == "" then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        -- end
        fontName = "LUIE Default Font"
    end

    local fontStyle = (UnitFrames.SV.DefaultFontStyle and UnitFrames.SV.DefaultFontStyle ~= "") and UnitFrames.SV.DefaultFontStyle or "soft-shadow-thick"
    local fontSize = (UnitFrames.SV.DefaultFontSize and UnitFrames.SV.DefaultFontSize > 0) and UnitFrames.SV.DefaultFontSize or 16


    if UnitFrames.DefaultFrames[unitTag] then
        local unitFrame = UnitFrames.DefaultFrames[unitTag]
        for _, powerType in pairs({ COMBAT_MECHANIC_FLAGS_HEALTH, COMBAT_MECHANIC_FLAGS_MAGICKA, COMBAT_MECHANIC_FLAGS_STAMINA }) do
            if unitFrame[powerType] then
                unitFrame[powerType].label:SetFont(zo_strformat("<<1>>|<<2>>|<<3>>", fontName, fontSize, fontStyle))
            end
        end
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
    -- Helper function
    local applyDefaultColor = function (unitTag)
        if UnitFrames.DefaultFrames[unitTag] then
            local unitFrame = UnitFrames.DefaultFrames[unitTag]
            for _, powerType in pairs(
                {
                    COMBAT_MECHANIC_FLAGS_HEALTH,
                    COMBAT_MECHANIC_FLAGS_MAGICKA,
                    COMBAT_MECHANIC_FLAGS_STAMINA,
                }) do
                if unitFrame[powerType] then
                    unitFrame[powerType].color = UnitFrames.SV.DefaultTextColour
                    unitFrame[powerType].label:SetColor(UnitFrames.SV.DefaultTextColour[1], UnitFrames.SV.DefaultTextColour[2], UnitFrames.SV.DefaultTextColour[3])
                end
            end
        end
    end

    -- Apply setting for all possible unitTags
    applyDefaultColor("player")
    applyDefaultColor("reticleover")
    for i = 0, 12 do
        applyDefaultColor("group" .. i)
    end
end

-- Apply selected font for all known label on custom unit frames
function UnitFrames.CustomFramesApplyFont()
    -- First try selecting font face
    local fontName = LUIE.Fonts[UnitFrames.SV.CustomFontFace]
    if not fontName or fontName == "" then
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        -- end
        fontName = "LUIE Default Font"
    end

    local fontStyle = (UnitFrames.SV.CustomFontStyle and UnitFrames.SV.CustomFontStyle ~= "") and UnitFrames.SV.CustomFontStyle or "soft-shadow-thin"
    local sizeCaption = (UnitFrames.SV.CustomFontOther and UnitFrames.SV.CustomFontOther > 0) and UnitFrames.SV.CustomFontOther or 16
    local sizeBars = (UnitFrames.SV.CustomFontBars and UnitFrames.SV.CustomFontBars > 0) and UnitFrames.SV.CustomFontBars or 14

    local __mkFont = function (size) return zo_strformat("<<1>>|<<2>>|<<3>>", fontName, size, fontStyle) end

    -- After fonts is applied unhide frames, so player can see changes even from menu
    for _, baseName in pairs({ "player", "reticleover", "companion", "SmallGroup", "RaidGroup", "boss", "AvaPlayerTarget", "PetGroup" }) do
        for i = 0, 12 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            if UnitFrames.CustomFrames[unitTag] then
                local unitFrame = UnitFrames.CustomFrames[unitTag]
                if unitFrame.name then
                    unitFrame.name:SetFont(__mkFont((unitFrame.name:GetParent() == unitFrame.topInfo) and sizeCaption or sizeBars))
                end
                if unitFrame.level then
                    unitFrame.level:SetFont(__mkFont(sizeCaption))
                end
                if unitFrame.className then
                    unitFrame.className:SetFont(__mkFont(sizeCaption))
                end
                if unitFrame.title then
                    unitFrame.title:SetFont(__mkFont(sizeCaption))
                end
                if unitFrame.avaRank then
                    unitFrame.avaRank:SetFont(__mkFont(sizeCaption))
                end
                if unitFrame.dead then
                    unitFrame.dead:SetFont(__mkFont(sizeBars))
                end
                for _, powerType in pairs({ COMBAT_MECHANIC_FLAGS_HEALTH, COMBAT_MECHANIC_FLAGS_MAGICKA, COMBAT_MECHANIC_FLAGS_STAMINA }) do
                    if unitFrame[powerType] then
                        if unitFrame[powerType].label then
                            unitFrame[powerType].label:SetFont(__mkFont(sizeBars))
                        end
                        if unitFrame[powerType].labelOne then
                            unitFrame[powerType].labelOne:SetFont(__mkFont(sizeBars))
                        end
                        if unitFrame[powerType].labelTwo then
                            unitFrame[powerType].labelTwo:SetFont(__mkFont(sizeBars))
                        end
                    end
                end
                if unitFrame.tlw and (i == 0 or i == 1) then
                    unitFrame.tlw:SetHidden(false)
                end
            end
        end
    end

    -- Adjust height of Name and Title labels on Player, Target and SmallGroup frames
    for _, baseName in pairs({ "player", "reticleover", "SmallGroup", "AvaPlayerTarget" }) do
        for i = 0, 4 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            if UnitFrames.CustomFrames[unitTag] and UnitFrames.CustomFrames[unitTag].tlw then
                local unitFrame = UnitFrames.CustomFrames[unitTag]
                -- Name should always be present
                unitFrame.name:SetHeight(2 * sizeCaption)
                local nameHeight = unitFrame.name:GetTextHeight()
                -- Update height of name container (topInfo)
                unitFrame.topInfo:SetHeight(nameHeight)
                -- LevelIcon also should exit
                if unitFrame.levelIcon then
                    unitFrame.levelIcon:SetDimensions(nameHeight, nameHeight)
                    unitFrame.levelIcon:ClearAnchors()
                    unitFrame.levelIcon:SetAnchor(LEFT, unitFrame.topInfo, LEFT, unitFrame.name:GetTextWidth() + 1, 0)
                end
                -- ClassIcon too - it looks better if a little bigger
                unitFrame.classIcon:SetDimensions(nameHeight + 2, nameHeight + 2)
                -- FriendIcon if exist - same idea
                if unitFrame.friendIcon then
                    unitFrame.friendIcon:SetDimensions(nameHeight + 2, nameHeight + 2)
                    unitFrame.friendIcon:ClearAnchors()
                    unitFrame.friendIcon:SetAnchor(RIGHT, unitFrame.classIcon, LEFT, nameHeight / 6, 0)
                end
                -- botInfo contain alt bar or title/ava
                if unitFrame.botInfo then
                    unitFrame.botInfo:SetHeight(nameHeight)
                    -- Alternative bar present on Player
                    if unitFrame.alternative then
                        unitFrame.alternative.backdrop:SetHeight(math.ceil(nameHeight / 3) + 2)
                        unitFrame.alternative.icon:SetDimensions(nameHeight, nameHeight)
                    end
                    -- Title present only on Target
                    if unitFrame.title then
                        unitFrame.title:SetHeight(2 * sizeCaption)
                    end
                end
                if unitFrame.buffAnchor then
                    unitFrame.buffAnchor:SetHeight(nameHeight)
                end
            end
        end
    end
end
