-- -----------------------------------------------------------------------------
--  LuiExtended - Custom frame TopInfo layout (veterancy / overland / level row)
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

local TOPINFO_OVERLAND_ICON_SIZE = 20
local TOPINFO_LEVEL_ICON_SIZE = 18
local TOPINFO_NAME_LEVEL_GAP = 4
local TOPINFO_ROW_ICON_GAP = 2
-- Fallback CP/level text width (about four digits) used only before the label can be measured.
local TOPINFO_LEVEL_TEXT_FALLBACK_WIDTH = 36
local SMALL_GROUP_NAME_ROW_OFFSET_Y = 0
local SMALL_GROUP_LEADER_NAME_OFFSET = 22
local SMALL_GROUP_RIGHT_PADDING = 6
local TARGET_STAR_GAP = 1

--- @param text string|nil
--- @return string
local function StripMarkupForStringWidth(text)
    if text == nil or text == "" then
        return ""
    end
    return (zo_strgsub(text, "%^%a+", "")) or text
end

--- @param self LUIE_CustomFrameObject
--- @return string|nil
local function ResolveTopInfoUnitTag(self)
    local unitTag = self.unitTag
    if unitTag == nil or not DoesUnitExist(unitTag) then
        unitTag = self.visualizerUnitTag
    end
    if unitTag == nil or not DoesUnitExist(unitTag) then
        if self.GetVisualizerUnitTag then
            unitTag = FrameObject.GetVisualizerUnitTag(self)
        end
    end
    return unitTag
end

--- @param self LUIE_CustomFrameObject
function FrameObject.UpdateTopInfoOverlandIcon(self)
    local overlandIcon = self.overlandDifficultyIcon
    if overlandIcon == nil then
        return
    end
    local difficulty = FrameObject.ResolveTopInfoOverlandDifficulty(self)
    if difficulty == nil then
        overlandIcon:SetHidden(true)
        return
    end
    local iconPath = FrameObject.GetOverlandChallengeDifficultyIconPath(difficulty)
    if iconPath then
        overlandIcon:SetTexture(iconPath)
        overlandIcon:SetDimensions(TOPINFO_OVERLAND_ICON_SIZE, TOPINFO_OVERLAND_ICON_SIZE)
        overlandIcon:SetHidden(false)
    else
        overlandIcon:SetHidden(true)
    end
end

--- @param self LUIE_CustomFrameObject
function FrameObject.RefreshTopInfoForLayout(self)
    if not FrameObject.HasCustomTopInfoFrameCategory(self) then
        return
    end
    if self.unitTag and DoesUnitExist(self.unitTag) then
        FrameObject.ApplyStaticControlUnitFields(self)
    end
    FrameObject.UpdateTopInfoOverlandIcon(self)
    FrameObject.UpdateTopInfoLevelRow(self)
end

--- @param self LUIE_CustomFrameObject
local function HideTopInfoLevelClusterWhenInactive(self)
    if self.levelIcon then
        self.levelIcon:SetHidden(true)
    end
    if self.veterancyRankIcon then
        self.veterancyRankIcon:SetHidden(true)
    end
    if self.level then
        self.level:SetHidden(true)
    end
end

--- @param self LUIE_CustomFrameObject
--- @param rowOffsetY number
--- @param baseStartX number|nil
--- @return number rowStartX
--- @return number overlandWidth
local function GetTopInfoLeftRowStartX(self, rowOffsetY, baseStartX)
    baseStartX = baseStartX or 0
    local overlandWidth = 0
    local rowStartX = baseStartX
    local overlandIcon = self.overlandDifficultyIcon
    if overlandIcon == nil then
        return rowStartX, overlandWidth
    end
    if FrameObject.ShouldShowTopInfoOverlandIcon(self) then
        local difficulty = FrameObject.ResolveTopInfoOverlandDifficulty(self)
        local iconPath = FrameObject.GetOverlandChallengeDifficultyIconPath(difficulty)
        overlandIcon:ClearAnchors()
        overlandIcon:SetDimensions(TOPINFO_OVERLAND_ICON_SIZE, TOPINFO_OVERLAND_ICON_SIZE)
        if iconPath then
            overlandIcon:SetTexture(iconPath)
        end
        overlandIcon:SetAnchor(TOPLEFT, self.topInfo, TOPLEFT, rowStartX, rowOffsetY)
        overlandIcon:SetHidden(false)
        overlandWidth = overlandIcon:GetWidth() + TOPINFO_ROW_ICON_GAP
        rowStartX = rowStartX + overlandWidth
    else
        overlandIcon:SetHidden(true)
    end
    return rowStartX, overlandWidth
end

--- Champion points for level row; reticleover matches vanilla target frame (effective CP).
--- @param unitTag string
--- @return integer
local function ResolveTopInfoChampionPoints(unitTag)
    if unitTag == "reticleover" then
        local effectiveChampionPoints = GetUnitEffectiveChampionPoints(unitTag)
        if effectiveChampionPoints and effectiveChampionPoints > 0 then
            return effectiveChampionPoints
        end
    end
    return GetUnitChampionPoints(unitTag)
end

--- @param self LUIE_CustomFrameObject
function FrameObject.UpdateTopInfoLevelRow(self)
    if not FrameObject.HasCustomTopInfoFrameCategory(self) then
        return
    end
    local unitTag = ResolveTopInfoUnitTag(self)
    if unitTag == nil and self.unitTag and DoesUnitExist(self.unitTag) then
        unitTag = self.unitTag
    end
    local showLevel = self.isPlayer
    local shouldShowVeterancyInfo = FrameObject.ShouldShowVeterancyRankOnFrame(self)

    if not showLevel or unitTag == nil then
        self.levelIcon:SetHidden(true)
        self.veterancyRankIcon:SetHidden(true)
        self.level:SetHidden(true)
        return
    end

    -- Reticle player targets exist before they report online; do not blank the level row for them.
    local skipOnlineGateForReticlePlayer = unitTag == "reticleover" and IsUnitPlayer(unitTag) and DoesUnitExist(unitTag)
    if not skipOnlineGateForReticlePlayer and not IsUnitOnline(unitTag) then
        self.levelIcon:SetHidden(true)
        self.veterancyRankIcon:SetHidden(true)
        self.level:SetHidden(true)
        return
    end

    local levelText
    local showVeterancyIcon = shouldShowVeterancyInfo
    local veterancyRank

    if showVeterancyIcon then
        veterancyRank = GetUnitVeterancyRank(unitTag)
        levelText = tostring(veterancyRank)
    elseif self.isChampion then
        levelText = tostring(ResolveTopInfoChampionPoints(unitTag))
    else
        levelText = tostring(GetUnitLevel(unitTag))
    end

    self.level:SetText(levelText)
    self.level:SetHidden(false)

    self.levelIcon:SetResizeToFitFile(false)
    self.levelIcon:SetColor(1, 1, 1, 1)
    self.levelIcon:SetDimensions(TOPINFO_LEVEL_ICON_SIZE, TOPINFO_LEVEL_ICON_SIZE)
    self.veterancyRankIcon:SetResizeToFitFile(false)
    self.veterancyRankIcon:SetColor(1, 1, 1, 1)
    self.veterancyRankIcon:SetDimensions(TOPINFO_LEVEL_ICON_SIZE, TOPINFO_LEVEL_ICON_SIZE)

    if showVeterancyIcon then
        local rankForIcon = veterancyRank
        if veterancyRank >= ZO_VETERANCY_MANAGER:GetNumRanks() then
            rankForIcon = ZO_VETERANCY_MANAGER:GetNumRanks()
        end
        local rankData = ZO_VeterancyRankData:New(rankForIcon)
        self.veterancyRankIcon:SetTexture(rankData:GetIcon())
        self.veterancyRankIcon:SetHidden(false)
        self.levelIcon:SetHidden(true)
    else
        local iconPath
        if self.isChampion then
            if IsInGamepadPreferredMode() then
                iconPath = ZO_GetGamepadChampionPointsIcon()
            else
                iconPath = ZO_GetChampionPointsIconSmall()
            end
        else
            if IsInGamepadPreferredMode() then
                iconPath = ZO_GetGamepadDungeonDifficultyIcon(DUNGEON_DIFFICULTY_NORMAL)
            else
                iconPath = ZO_GetKeyboardDungeonDifficultyIcon(DUNGEON_DIFFICULTY_NORMAL)
            end
        end
        if iconPath then
            self.levelIcon:SetTexture(iconPath)
        end
        self.levelIcon:SetHidden(false)
        self.veterancyRankIcon:SetHidden(true)
    end

    if self.unitTag == "player" then
        local showYourName = UnitFrames.SV.PlayerEnableYourname
        if not showYourName then
            self.levelIcon:SetHidden(true)
            self.veterancyRankIcon:SetHidden(true)
            self.level:SetHidden(true)
        end
    else
        if not showVeterancyIcon then
            self.levelIcon:SetHidden(not showLevel)
        end
        if showVeterancyIcon then
            self.veterancyRankIcon:SetHidden(not showLevel)
        end
        self.level:SetHidden(not showLevel)
    end
end

--- @param label LabelControl
local function ApplyTopInfoSingleLineLabel(label)
    if label == nil then
        return
    end
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetMaxLineCount(1)
end

--- @param label LabelControl
local function ApplyTopInfoLevelNumericLabel(label)
    if label == nil then
        return
    end
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    label:SetMaxLineCount(1)
end

--- @param label LabelControl
--- @param maxWidth number|nil
--- @return number
local function GetTopInfoNameRowUsedWidth(label, maxWidth)
    if label == nil then
        return 0
    end
    local textWidth = label:GetTextWidth()
    if textWidth and textWidth > 0 then
        if maxWidth and maxWidth > 0 then
            return zo_min(textWidth, maxWidth)
        end
        return textWidth
    end
    local plainText = StripMarkupForStringWidth(label:GetText())
    if plainText == "" then
        return 0
    end
    local stringWidth = label:GetStringWidth(plainText)
    if maxWidth and maxWidth > 0 then
        return zo_min(stringWidth, maxWidth)
    end
    return stringWidth
end

--- @param self LUIE_CustomFrameObject
--- @return TextureControl|nil
local function GetTopInfoActiveLevelIcon(self)
    if self.veterancyRankIcon and not self.veterancyRankIcon:IsHidden() then
        return self.veterancyRankIcon
    end
    if self.levelIcon and not self.levelIcon:IsHidden() then
        return self.levelIcon
    end
    return nil
end

--- Width of CP/level icon plus numeric text for TopInfo row layout.
--- Call after ApplyTopInfoRowHeight so icon dimensions are final.
--- @param self LUIE_CustomFrameObject
--- @param showLevelRow boolean
--- @return number
local function GetTopInfoLevelClusterRequiredWidth(self, showLevelRow)
    if not showLevelRow or self.level == nil or self.level:IsHidden() then
        return 0
    end
    local iconWidth = TOPINFO_LEVEL_ICON_SIZE
    local activeIcon = GetTopInfoActiveLevelIcon(self)
    if activeIcon then
        local measuredIconWidth = activeIcon:GetWidth()
        if measuredIconWidth and measuredIconWidth > 0 then
            iconWidth = measuredIconWidth
        end
    end
    local plainText = StripMarkupForStringWidth(self.level:GetText())
    local textWidth = 0
    if plainText ~= "" then
        textWidth = self.level:GetStringWidth(plainText)
    end
    if textWidth <= 0 then
        textWidth = TOPINFO_LEVEL_TEXT_FALLBACK_WIDTH
    end
    return iconWidth + 1 + textWidth
end

--- @param self LUIE_CustomFrameObject
--- @param rowOffsetY number
local function ApplyTopInfoRowHeight(self, rowOffsetY)
    local rowHeight = self.name:GetTextHeight()
    if rowHeight <= 0 then
        rowHeight = self.name:GetHeight()
    end
    if rowHeight > 0 then
        self.topInfo:SetHeight(rowHeight)
        self.name:SetHeight(rowHeight)
        if self.level and not self.level:IsHidden() then
            self.level:SetHeight(rowHeight)
        end
    end
    local iconSize = rowHeight > 0 and rowHeight or TOPINFO_LEVEL_ICON_SIZE
    if self.levelIcon and not self.levelIcon:IsHidden() then
        self.levelIcon:SetDimensions(iconSize, iconSize)
    end
    if self.veterancyRankIcon and not self.veterancyRankIcon:IsHidden() then
        self.veterancyRankIcon:SetDimensions(iconSize, iconSize)
    end
    if self.overlandDifficultyIcon and not self.overlandDifficultyIcon:IsHidden() then
        self.overlandDifficultyIcon:SetDimensions(TOPINFO_OVERLAND_ICON_SIZE, TOPINFO_OVERLAND_ICON_SIZE)
    end
end

--- @param self LUIE_CustomFrameObject
--- @param rowOffsetY number
--- @param rowStartX number
--- @param showLevelRow boolean
--- @param rightReserved number
local function LayoutTopInfoLevelCluster(self, rowOffsetY, rowStartX, showLevelRow, rightReserved)
    if not showLevelRow then
        HideTopInfoLevelClusterWhenInactive(self)
        return
    end
    local topInfoWidth = self.topInfo:GetWidth()
    local levelIconControl = self.levelIcon
    local veterancyIconControl = self.veterancyRankIcon
    local levelStart = rowStartX

    if levelIconControl then
        levelIconControl:ClearAnchors()
        levelIconControl:SetAnchor(TOPLEFT, self.topInfo, TOPLEFT, levelStart, rowOffsetY)
    end
    if veterancyIconControl then
        veterancyIconControl:ClearAnchors()
        veterancyIconControl:SetAnchor(TOPLEFT, self.topInfo, TOPLEFT, levelStart, rowOffsetY)
    end

    local activeIcon = GetTopInfoActiveLevelIcon(self)
    if self.level then
        self.level:ClearAnchors()
        if activeIcon then
            self.level:SetAnchor(TOPLEFT, activeIcon, TOPRIGHT, 1, 0)
        else
            self.level:SetAnchor(TOPLEFT, self.topInfo, TOPLEFT, levelStart, rowOffsetY)
        end
        ApplyTopInfoLevelNumericLabel(self.level)
        if showLevelRow then
            local iconWidth = activeIcon and activeIcon:GetWidth() or 0
            if iconWidth <= 0 then
                iconWidth = TOPINFO_LEVEL_ICON_SIZE
            end
            -- Clamp digits to the space between the icon and the reserved right chrome so they
            -- never expand under the class icon / stars. The upstream name budget guarantees the
            -- full digits fit when the bar is wide enough.
            local available = topInfoWidth - levelStart - rightReserved - iconWidth - 1
            if available < 0 then
                available = 0
            end
            local needed = available
            local plainText = StripMarkupForStringWidth(self.level:GetText())
            if plainText ~= "" then
                needed = self.level:GetStringWidth(plainText)
            end
            self.level:SetWidth(zo_min(needed, available)+10)
        end
    end
end

-- -----------------------------------------------------------------------------
--  Per-category right-edge reserved width (TOPRIGHT chrome the inline caption row
--  must not overlap). Computed before the shared engine runs.
-- -----------------------------------------------------------------------------

--- @param self LUIE_CustomFrameObject
--- @return number
local function ComputeTopInfoPlayerRightReserved(self)
    local rightReserved = 0
    if self.classIcon and not self.classIcon:IsHidden() then
        rightReserved = rightReserved + self.classIcon:GetWidth() + 1
    end
    return rightReserved
end

--- @param self LUIE_CustomFrameObject
--- @return number
local function ComputeTopInfoTargetRightReserved(self)
    local rightReserved = 1
    if self.classIcon and not self.classIcon:IsHidden() then
        rightReserved = rightReserved + self.classIcon:GetWidth()
    end
    if self.star3 and not self.star3:IsHidden() then
        rightReserved = rightReserved + self.star3:GetWidth() + TARGET_STAR_GAP
    end
    if self.star2 and not self.star2:IsHidden() then
        rightReserved = rightReserved + self.star2:GetWidth() + TARGET_STAR_GAP
    end
    if self.star1 and not self.star1:IsHidden() then
        rightReserved = rightReserved + self.star1:GetWidth() + TARGET_STAR_GAP
    end
    if self.friendIcon and not self.friendIcon:IsHidden() then
        rightReserved = rightReserved + self.friendIcon:GetWidth() + TOPINFO_ROW_ICON_GAP
    end
    return rightReserved
end

--- @param self LUIE_CustomFrameObject
--- @return number
local function ComputeTopInfoSmallGroupRightReserved(self)
    local rightReserved = SMALL_GROUP_RIGHT_PADDING
    if self.classIcon and not self.classIcon:IsHidden() then
        rightReserved = rightReserved + self.classIcon:GetWidth()
    end
    if self.friendIcon and not self.friendIcon:IsHidden() then
        rightReserved = rightReserved + self.friendIcon:GetWidth() + TOPINFO_ROW_ICON_GAP
    end
    return rightReserved
end

--- @param self LUIE_CustomFrameObject
--- @return number
local function ComputeTopInfoAvaTargetRightReserved(self)
    local rightReserved = 0
    if self.avaRankIcon and not self.avaRankIcon:IsHidden() then
        rightReserved = rightReserved + self.avaRankIcon:GetWidth() + 1
    end
    return rightReserved
end

--- Shared inline caption-row engine for every TopInfo frame category.
--- Lays out [name (capped, ellipsized)] [gap] [level icon + digits], hugging the
--- visible end of the name, while reserving `rightReserved` for the TOPRIGHT chrome
--- that the caller anchors afterwards. Assumes UpdateTopInfoLevelRow already set the
--- level text and icon visibility (via RefreshTopInfoForLayout).
--- @param self LUIE_CustomFrameObject
--- @param rowOffsetY number
--- @param rowStartX number x after overland (and small group leader gutter)
--- @param rightReserved number
--- @param showLevelRow boolean
local function LayoutTopInfoCaptionRow(self, rowOffsetY, rowStartX, rightReserved, showLevelRow)
    local topInfoWidth = self.topInfo:GetWidth()

    self.name:ClearAnchors()
    self.name:SetAnchor(TOPLEFT, self.topInfo, TOPLEFT, rowStartX, rowOffsetY)
    ApplyTopInfoSingleLineLabel(self.name)

    -- Scale the level / veterancy icons to the caption height before measuring the block.
    ApplyTopInfoRowHeight(self, rowOffsetY)

    local levelBlockWidth = GetTopInfoLevelClusterRequiredWidth(self, showLevelRow)
    local levelGap = (levelBlockWidth > 0) and TOPINFO_NAME_LEVEL_GAP or 0

    -- Name cap reserves the full level block so the digits never collapse to "...".
    -- On ultra-narrow bars the name keeps shrinking so the CP/level digits stay readable.
    local nameMaxWidth = topInfoWidth - rowStartX - rightReserved - levelBlockWidth - levelGap
    if nameMaxWidth < 0 then
        nameMaxWidth = 0
    end
    self.name:SetWidth(nameMaxWidth)

    if not showLevelRow or levelBlockWidth == 0 then
        LayoutTopInfoLevelCluster(self, rowOffsetY, rowStartX, showLevelRow, rightReserved)
        return
    end

    -- Inline: the level cluster starts right after the visible name text.
    local nameUsedWidth = GetTopInfoNameRowUsedWidth(self.name, nameMaxWidth)
    local levelStart = rowStartX + nameUsedWidth + levelGap
    LayoutTopInfoLevelCluster(self, rowOffsetY, levelStart, showLevelRow, rightReserved)
end

--- @param self LUIE_CustomFrameObject
function FrameObject.LayoutTopInfoSmallGroup(self)
    if self.frameCategory ~= "smallGroup" then
        return
    end
    FrameObject.RefreshTopInfoForLayout(self)

    local unitTag = ResolveTopInfoUnitTag(self)
    local isLeader = unitTag and IsUnitGroupLeader(unitTag)
    local rowOffsetY = SMALL_GROUP_NAME_ROW_OFFSET_Y
    local leaderNameOffset = isLeader and SMALL_GROUP_LEADER_NAME_OFFSET or 0

    if self.leader then
        self.leader:SetHidden(not isLeader)
    end

    local showLevelRow = self.level and not self.level:IsHidden()
    if not showLevelRow then
        HideTopInfoLevelClusterWhenInactive(self)
    end

    local rowStartX = GetTopInfoLeftRowStartX(self, rowOffsetY, leaderNameOffset)
    LayoutTopInfoCaptionRow(self, rowOffsetY, rowStartX, ComputeTopInfoSmallGroupRightReserved(self), showLevelRow)

    if self.classIcon then
        self.classIcon:ClearAnchors()
        self.classIcon:SetAnchor(RIGHT, self.topInfo, RIGHT, -1, 0)
    end
    if self.friendIcon and not self.friendIcon:IsHidden() then
        self.friendIcon:ClearAnchors()
        local friendAnchor = self.classIcon or self.topInfo
        self.friendIcon:SetAnchor(RIGHT, friendAnchor, LEFT, -TOPINFO_ROW_ICON_GAP, 0)
    end
end

--- @param self LUIE_CustomFrameObject
function FrameObject.LayoutTopInfoPlayer(self)
    if self.frameCategory ~= "player" then
        return
    end
    FrameObject.RefreshTopInfoForLayout(self)

    local rowOffsetY = 0
    local showLevelRow = self.level and not self.level:IsHidden()
    if not showLevelRow then
        HideTopInfoLevelClusterWhenInactive(self)
    end

    local rowStartX = GetTopInfoLeftRowStartX(self, rowOffsetY, 0)
    LayoutTopInfoCaptionRow(self, rowOffsetY, rowStartX, ComputeTopInfoPlayerRightReserved(self), showLevelRow)
end

--- @param self LUIE_CustomFrameObject
function FrameObject.LayoutTopInfoTarget(self)
    if self.frameCategory ~= "target" then
        return
    end
    FrameObject.RefreshTopInfoForLayout(self)
    -- Resolve difficulty-star visibility here so every layout path (including the
    -- layout-only reticleover refresh) anchors the stars from the same state and they
    -- never fall back to their static XML anchors.
    FrameObject.UpdateStaticControlDifficultyStars(self)

    local rowOffsetY = 0
    local showLevelRow = self.level and not self.level:IsHidden()
    if not showLevelRow then
        HideTopInfoLevelClusterWhenInactive(self)
    end

    local rowStartX = GetTopInfoLeftRowStartX(self, rowOffsetY, 0)
    LayoutTopInfoCaptionRow(self, rowOffsetY, rowStartX, ComputeTopInfoTargetRightReserved(self), showLevelRow)

    -- Right-edge chrome: class icon, then friend icon, then difficulty stars (right to left).
    -- Anchored RIGHT/LEFT (vertically centered) to match the static XML grouping so the
    -- icons stay tight and never drift to the top edge on a re-layout.
    if self.classIcon then
        self.classIcon:ClearAnchors()
        self.classIcon:SetAnchor(RIGHT, self.topInfo, RIGHT, -1, 0)
    end
    if self.friendIcon and not self.friendIcon:IsHidden() then
        self.friendIcon:ClearAnchors()
        local friendAnchor = self.classIcon or self.topInfo
        self.friendIcon:SetAnchor(RIGHT, friendAnchor, LEFT, -TOPINFO_ROW_ICON_GAP, 0)
    end
    local starAnchor = self.topInfo
    if self.friendIcon and not self.friendIcon:IsHidden() then
        starAnchor = self.friendIcon
    elseif self.classIcon and not self.classIcon:IsHidden() then
        starAnchor = self.classIcon
    end
    if self.star1 and not self.star1:IsHidden() then
        self.star1:ClearAnchors()
        self.star1:SetAnchor(RIGHT, starAnchor, LEFT, -TARGET_STAR_GAP, 0)
        starAnchor = self.star1
    end
    if self.star2 and not self.star2:IsHidden() then
        self.star2:ClearAnchors()
        self.star2:SetAnchor(RIGHT, starAnchor, LEFT, -TARGET_STAR_GAP, 0)
        starAnchor = self.star2
    end
    if self.star3 and not self.star3:IsHidden() then
        self.star3:ClearAnchors()
        self.star3:SetAnchor(RIGHT, starAnchor, LEFT, -TARGET_STAR_GAP, 0)
    end
end

--- @param self LUIE_CustomFrameObject
function FrameObject.LayoutTopInfoAvaTarget(self)
    if self.frameCategory ~= "avaTarget" then
        return
    end
    FrameObject.RefreshTopInfoForLayout(self)

    local rowOffsetY = 0
    local showLevelRow = self.level and not self.level:IsHidden()
    if not showLevelRow then
        HideTopInfoLevelClusterWhenInactive(self)
    end

    -- AvA target keeps the class icon on the LEFT, before overland + name.
    local classWidth = 0
    if self.classIcon and not self.classIcon:IsHidden() then
        self.classIcon:ClearAnchors()
        self.classIcon:SetAnchor(TOPLEFT, self.topInfo, TOPLEFT, 0, rowOffsetY)
        classWidth = self.classIcon:GetWidth() + TOPINFO_ROW_ICON_GAP
    end

    local rowStartX = GetTopInfoLeftRowStartX(self, rowOffsetY, classWidth)
    LayoutTopInfoCaptionRow(self, rowOffsetY, rowStartX, ComputeTopInfoAvaTargetRightReserved(self), showLevelRow)

    if self.avaRankIcon and not self.avaRankIcon:IsHidden() then
        self.avaRankIcon:ClearAnchors()
        self.avaRankIcon:SetAnchor(TOPRIGHT, self.topInfo, TOPRIGHT, -1, rowOffsetY)
    end
end

--- @param self LUIE_CustomFrameObject
function FrameObject.LayoutTopInfoForFrame(self)
    if not FrameObject.HasCustomTopInfoFrameCategory(self) then
        return
    end
    if self.frameCategory == "smallGroup" then
        FrameObject.LayoutTopInfoSmallGroup(self)
    elseif self.frameCategory == "player" then
        FrameObject.LayoutTopInfoPlayer(self)
    elseif self.frameCategory == "target" then
        FrameObject.LayoutTopInfoTarget(self)
    elseif self.frameCategory == "avaTarget" then
        FrameObject.LayoutTopInfoAvaTarget(self)
    end
end
