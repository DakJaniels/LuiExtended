-- -----------------------------------------------------------------------------
--  LuiExtended - Shared static control helpers and LUIE_CustomFrameObject methods
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local zo_strformat = zo_strformat

local COMPACT_NAME_ICON_SIZE = 18
local TARGET_OVERLAND_ICON_SIZE = 23

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

---
--- @param iconPath string
--- @param text string
--- @param iconSize number?
--- @return string
function UnitFrames.FormatTextWithIcon(iconPath, text, iconSize)
    iconSize = iconSize or 20
    return zo_iconFormat(iconPath, iconSize, iconSize) .. " " .. text
end

--- Target and raid names use TEXT_WRAP_MODE_TRUNCATE; suffix icons clip off the end.
--- @param iconPath string
--- @param nameText string
--- @param frameCategory string
--- @return string
function UnitFrames.FormatNameWithOverlandDifficultyIcon(iconPath, nameText, frameCategory)
    if frameCategory == "target" then
        return zo_iconFormat(iconPath, TARGET_OVERLAND_ICON_SIZE, TARGET_OVERLAND_ICON_SIZE) .. " " .. nameText
    end
    if frameCategory == "raid" then
        return zo_iconFormat(iconPath, COMPACT_NAME_ICON_SIZE, COMPACT_NAME_ICON_SIZE) .. " " .. nameText
    end
    return zo_iconTextFormatNoSpaceAlignedRight(iconPath, "115%", "115%", nameText)
end

--- @param iconPath string
--- @param nameText string
--- @param alignIconRight boolean|nil
--- @return string
function UnitFrames.FormatNameWithTargetMarkerIcon(iconPath, nameText, alignIconRight)
    if alignIconRight then
        return zo_iconTextFormatNoSpaceAlignedRight(iconPath, "100%", "100%", nameText)
    end
    return UnitFrames.FormatTextWithIcon(iconPath, nameText)
end

--- @return "player"|"target"|"group"|"raid"|nil
function FrameObject:GetStaticControlDisplayCategory()
    local unitTag = self.unitTag
    if unitTag == "player" then
        return "player"
    end
    if unitTag == "reticleover" then
        return "target"
    end
    if unitTag and ZO_Group_IsGroupUnitTag(unitTag) then
        return UnitFrames.isRaid and "raid" or "group"
    end
    local registryKey = self.frameRegistryKey
    if registryKey == nil and unitTag then
        if string.sub(unitTag, 1, 10) == "SmallGroup" then
            registryKey = unitTag
        elseif string.sub(unitTag, 1, 9) == "RaidGroup" then
            registryKey = unitTag
        end
    end
    if registryKey then
        if string.sub(registryKey, 1, 10) == "SmallGroup" then
            return "group"
        end
        if string.sub(registryKey, 1, 9) == "RaidGroup" then
            return "raid"
        end
    end
    local frameCategory = self.frameCategory
    if frameCategory == "smallGroup" then
        return "group"
    end
    if frameCategory == "raid" then
        return "raid"
    end
    if frameCategory == "avaTarget" then
        return "target"
    end
    return nil
end

local function IsOverlandGameUnitTag(unitTag)
    if unitTag == nil or unitTag == "" then
        return false
    end
    if unitTag == "player" or unitTag == "reticleover" then
        return true
    end
    return ZO_Group_IsGroupUnitTag(unitTag)
end

--- @return string|nil
function FrameObject:ResolveOverlandGameUnitTag()
    if self.unitTag and DoesUnitExist(self.unitTag) and IsOverlandGameUnitTag(self.unitTag) then
        return self.unitTag
    end
    if self.visualizerUnitTag and DoesUnitExist(self.visualizerUnitTag) and IsOverlandGameUnitTag(self.visualizerUnitTag) then
        return self.visualizerUnitTag
    end
    if self.GetVisualizerUnitTag then
        local tag = FrameObject.GetVisualizerUnitTag(self)
        if tag and DoesUnitExist(tag) and IsOverlandGameUnitTag(tag) then
            return tag
        end
    end
    return nil
end

local function IsOverlandDifficultyGloballyAvailable()
    return GetOverlandDifficultyDisabledReason() == OVERLAND_DIFFICULTY_DISABLED_REASON_NONE
end

local function IsOverlandDifficultyEnabledForCategory(frameCategory)
    if not IsOverlandDifficultyGloballyAvailable() or frameCategory == nil then
        return false
    end
    local sv = UnitFrames.SV
    if frameCategory == "player" then
        return sv.PlayerShowOverlandDifficulty
    end
    if frameCategory == "target" then
        return sv.TargetShowOverlandDifficulty
    end
    if frameCategory == "group" then
        return sv.GroupShowOverlandDifficulty
    end
    if frameCategory == "raid" then
        return sv.RaidShowOverlandDifficulty
    end
    return false
end

--- @param self LUIE_CustomFrameObject
--- @return boolean
function FrameObject.IsOverlandDifficultyEnabledOnFrame(self)
    local frameCategory = FrameObject.GetStaticControlDisplayCategory(self)
    return IsOverlandDifficultyEnabledForCategory(frameCategory)
end

---
---@param difficulty OverlandDifficultyType
---@return string iconPath
function FrameObject.GetOverlandChallengeDifficultyIconPath(difficulty)
    if difficulty ~= nil then
        local iconPath = ZO_CHALLENGE_DIFFICULTY_ICONS_GAMEPAD[difficulty]
        if iconPath then
            return iconPath
        end
    end
    return ZO_CHALLENGE_DIFFICULTY_ICONS_GAMEPAD[OVERLAND_DIFFICULTY_TYPE_BASEGAME]
end

--- LUIE custom frames with dedicated TopInfo level row controls.
--- @param self LUIE_CustomFrameObject
--- @return boolean
function FrameObject.HasCustomTopInfoFrameCategory(self)
    local frameCategory = self.frameCategory
    return frameCategory == "player" or frameCategory == "target" or frameCategory == "smallGroup" or frameCategory == "avaTarget"
end

local function IsOverlandDifficultyPlayerUnit(unitTag)
    if unitTag == nil or not DoesUnitExist(unitTag) then
        return false
    end
    if IsUnitPlayer(unitTag) then
        return true
    end
    return GetUnitReaction(unitTag) == UNIT_REACTION_PLAYER_ALLY
end

--- Display overland difficulty for unit frames; nil when hidden (matches vanilla: base game is not shown).
--- @param unitTag string|nil
--- @param frameCategory "player"|"target"|"group"|"raid"|nil
--- @return number|nil
function FrameObject.ResolveOverlandDifficultyForUnitTag(unitTag, frameCategory)
    if not IsOverlandDifficultyEnabledForCategory(frameCategory) or unitTag == nil then
        return nil
    end
    local difficulty = nil
    if frameCategory == "target" and UnitFrames.SV.TargetMonsterOverlandDifficulty then
        if not IsUnitMonster(unitTag) or not IsUnitAttackable(unitTag) then
            return nil
        end
        difficulty = GetOverlandDifficulty()
    elseif IsOverlandDifficultyPlayerUnit(unitTag) then
        difficulty = GetUnitOverlandDifficulty(unitTag)
    elseif frameCategory == "target" then
        if not IsUnitMonster(unitTag) or not IsUnitAttackable(unitTag) then
            return nil
        end
        difficulty = GetOverlandDifficulty()
    elseif frameCategory == "group" or frameCategory == "player" then
        if IsOverlandDifficultyPlayerUnit(unitTag) then
            difficulty = GetUnitOverlandDifficulty(unitTag)
        end
    end
    if difficulty ~= nil and difficulty > OVERLAND_DIFFICULTY_TYPE_BASEGAME then
        return difficulty
    end
    return nil
end

--- @param self LUIE_CustomFrameObject
--- @return number|nil
function FrameObject.ResolveTopInfoOverlandDifficulty(self)
    local overlandUnitTag = FrameObject.ResolveOverlandGameUnitTag(self)
    if overlandUnitTag == nil then
        return nil
    end
    local frameCategory = FrameObject.GetStaticControlDisplayCategory(self)
    return FrameObject.ResolveOverlandDifficultyForUnitTag(overlandUnitTag, frameCategory)
end

--- @param self LUIE_CustomFrameObject
--- @return boolean
function FrameObject.ShouldShowTopInfoOverlandIcon(self)
    return FrameObject.ResolveTopInfoOverlandDifficulty(self) ~= nil
end

--- @param unitTag string
--- @param nameText string
--- @param frameCategory "group"|"player"|"raid"|"target"|nil
--- @return string
function UnitFrames.ApplyOverlandDifficultyNameIcon(unitTag, nameText, frameCategory)
    if nameText == nil or nameText == "" or unitTag == nil then
        return nameText
    end
    local difficulty = FrameObject.ResolveOverlandDifficultyForUnitTag(unitTag, frameCategory)
    if difficulty == nil then
        return nameText
    end
    local iconPath = FrameObject.GetOverlandChallengeDifficultyIconPath(difficulty)
    if iconPath then
        return UnitFrames.FormatNameWithOverlandDifficultyIcon(iconPath, nameText, frameCategory)
    end
    return nameText
end

function FrameObject:ShouldShowVeterancyRankOnFrame()
    if not self.isPlayer or not IsVeterancySeasonActive() or not IsInVeterancyProgressionZone() then
        return false
    end
    local frameCategory = FrameObject.GetStaticControlDisplayCategory(self)
    local sv = UnitFrames.SV
    if frameCategory == "player" then
        return sv.PlayerShowVeterancyRank
    end
    if frameCategory == "target" then
        return sv.TargetShowVeterancyRank
    end
    if frameCategory == "group" then
        return sv.GroupShowVeterancyRank
    end
    if frameCategory == "raid" then
        return sv.RaidShowVeterancyRank
    end
    return false
end

--- @param nameText string
--- @return string
function FrameObject:ApplyVeterancyRankNameIconForRaid(nameText)
    if nameText == nil or nameText == "" or not FrameObject.ShouldShowVeterancyRankOnFrame(self) then
        return nameText
    end
    if not GetVeterancyRankIcon then
        return nameText
    end
    local veterancyRank = GetUnitVeterancyRank(self.unitTag)
    local seasonId = GetCurrentVeterancySeasonId and GetCurrentVeterancySeasonId() or nil
    local iconPath = GetVeterancyRankIcon(veterancyRank, seasonId)
    if not iconPath then
        return nameText
    end
    return zo_iconFormat(iconPath, COMPACT_NAME_ICON_SIZE, COMPACT_NAME_ICON_SIZE) .. " " .. tostring(veterancyRank) .. " " .. nameText
end

function UnitFrames.ScheduleReticleoverOverlandStaticRefresh()
    if not UnitFrames.SV.TargetShowOverlandDifficulty or not UnitFrames.CustomFrames["reticleover"] then
        return
    end
    local function refreshIfPlayerTarget()
        if not DoesUnitExist("reticleover") or not IsOverlandDifficultyPlayerUnit("reticleover") then
            return
        end
        local frame = UnitFrames.CustomFrames["reticleover"]
        FrameObject.UpdateStaticControls(frame)
    end
    zo_callLater(refreshIfPlayerTarget, 0)
    zo_callLater(refreshIfPlayerTarget, 100)
end

function FrameObject:ApplyStaticControlUnitFields()
    self.isPlayer = IsUnitPlayer(self.unitTag)
    self.isChampion = IsUnitChampion(self.unitTag)
    self.isLevelCap = (GetUnitChampionPoints(self.unitTag) == UnitFrames.MaxChampionPoint)
    self.avaRankValue = GetUnitAvARank(self.unitTag)
end

--- @return integer
function FrameObject:GetStaticControlDisplayOption()
    if self.unitTag == "player" then
        return UnitFrames.SV.DisplayOptionsPlayer
    end
    if self.unitTag == "reticleover" then
        return UnitFrames.SV.DisplayOptionsTarget
    end
    return UnitFrames.SV.DisplayOptionsGroupRaid
end

--- @param displayOption integer
--- @return string
function FrameObject:BuildBaseStaticControlNameText(displayOption)
    if self.isPlayer then
        if displayOption == 3 then
            return GetUnitName(self.unitTag) .. " " .. GetUnitDisplayName(self.unitTag)
        elseif displayOption == 1 then
            return GetUnitDisplayName(self.unitTag)
        end
        return GetUnitName(self.unitTag)
    end
    return GetUnitName(self.unitTag)
end

--- @param nameText string
--- @param frameCategory "player"|"target"|"group"|"raid"|nil
--- @return string
function FrameObject:ApplyStaticControlTargetMarkerToName(nameText, frameCategory)
    if not UnitFrames.SV.CustomTargetMarker then
        return nameText
    end
    local targetMarkerType = GetUnitTargetMarkerType(self.unitTag)
    if targetMarkerType == TARGET_MARKER_TYPE_NONE then
        return nameText
    end
    local iconPath = ZO_GetPlatformTargetMarkerIcon(targetMarkerType)
    if not iconPath then
        return nameText
    end
    local alignTargetMarkerIconRight = self.unitTag == "reticleover" or frameCategory == "target"
    return UnitFrames.FormatNameWithTargetMarkerIcon(iconPath, nameText, alignTargetMarkerIconRight)
end

--- @param nameText string
--- @param frameCategory "player"|"target"|"group"|"raid"|nil
--- @return string
function FrameObject:ApplyStaticControlOverlandToName(nameText, frameCategory)
    if not frameCategory then
        return nameText
    end
    -- Custom player/target/group/AvA frames use _OverlandDifficultyIcon in TopInfo, not name markup.
    if FrameObject.HasCustomTopInfoFrameCategory(self) then
        return nameText
    end
    local applyOverlandToThisName = true
    if self.unitTag == "reticleover" and UnitFrames.SV.CustomFramesTarget then
        local customReticle = UnitFrames.CustomFrames["reticleover"]
        if customReticle and self.name ~= customReticle.name then
            applyOverlandToThisName = false
        end
    end
    if not applyOverlandToThisName then
        return nameText
    end
    local overlandUnitTag = FrameObject.ResolveOverlandGameUnitTag(self)
    if overlandUnitTag then
        return UnitFrames.ApplyOverlandDifficultyNameIcon(overlandUnitTag, nameText, frameCategory)
    end
    return nameText
end

function FrameObject:UpdateStaticControlRoleIcon()
    if self.roleIcon == nil then
        return
    end
    local role = GetGroupMemberSelectedRole(self.unitTag)
    local unitRole = LUIE.GetRoleIcon(role)
    self.roleIcon:SetTexture(unitRole)
end

function FrameObject:UpdateStaticControlDifficultyStars()
    if self.star1 == nil or self.star2 == nil or self.star3 == nil then
        return
    end
    local unitDifficulty = GetUnitDifficulty(self.unitTag)
    self.star1:SetHidden(unitDifficulty < 2)
    self.star2:SetHidden(unitDifficulty < 3)
    self.star3:SetHidden(unitDifficulty < 4)
end

function FrameObject:UpdateStaticControlClassIcon()
    if self.classIcon == nil then
        return
    end
    local unitDifficulty = GetUnitDifficulty(self.unitTag)
    local classIcon = LUIE.GetClassIcon(GetUnitClassId(self.unitTag))
    local isMonsterUnit = IsUnitMonster(self.unitTag)
    local showMonsterClassIcon = not self.isPlayer and UnitFrames.SV.TargetHighlightMonsterUnits and isMonsterUnit and IsUnitAttackable(self.unitTag)
    local showClass = (self.isPlayer and classIcon ~= nil) or (unitDifficulty > 1) or showMonsterClassIcon
    local eliteIconPath
    if ZO_IsConsoleOrGameCoreUI() then
        eliteIconPath = [[/esoui/art/icons/poi/poi_groupboss_complete.dds]]
    else
        eliteIconPath = LUIE_MEDIA_UNITFRAMES_UNITFRAMES_LEVEL_ELITE_DDS
    end
    if self.isPlayer then
        self.classIcon:SetTexture(classIcon)
    elseif unitDifficulty == 2 or showMonsterClassIcon then
        self.classIcon:SetTexture(eliteIconPath)
    elseif unitDifficulty >= 3 then
        self.classIcon:SetTexture(eliteIconPath)
    end
    if self.unitTag == "player" then
        self.classIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
    else
        self.classIcon:SetHidden(not showClass)
    end
end

function FrameObject:UpdateStaticControlClassName()
    if not self.className then
        return
    end
    local classId = GetUnitClassId(self.unitTag)
    local className = zo_strformat(GetString(SI_CLASS_NAME), GetClassName(GENDER_MALE, classId))
    local showClass = self.isPlayer and className ~= nil and UnitFrames.SV.TargetEnableClass
    if showClass then
        local classNameText = StringOnlyGSUB(className, "%^%a+", "")
        self.className:SetText(classNameText)
    end
    if self.unitTag == "player" then
        self.className:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
    else
        self.className:SetHidden(not showClass)
    end
end

--- LUIE guild check by unit tag (not the ESO `IsGuildMate` display-name API).
--- @param unitTag string
--- @return boolean
local function IsGuildMateUnitTag(unitTag)
    local displayName = GetUnitDisplayName(unitTag)
    if displayName == UnitFrames.playerDisplayName then
        return false
    end
    for guildIndex = 1, GetNumGuilds() do
        local guildId = GetGuildId(guildIndex)
        if GetGuildMemberIndexFromDisplayName(guildId, displayName) ~= nil then
            return true
        end
    end
    return false
end

--- @param frameCategory string|nil
--- @return boolean showFriend
--- @return boolean showGuild
--- @return boolean showIgnored
local function GetCustomFrameSocialIconShowFlags(frameCategory)
    local sv = UnitFrames.SV
    if frameCategory == "target" then
        return sv.CustomTargetShowFriendIcon, sv.CustomTargetShowGuildIcon, sv.CustomTargetShowIgnoredIcon
    end
    if frameCategory == "smallGroup" then
        return sv.GroupShowFriendIcon, sv.GroupShowGuildIcon, sv.GroupShowIgnoredIcon
    end
    return true, true, true
end

function FrameObject:UpdateStaticControlFriendIcon()
    if self.friendIcon == nil then
        return
    end
    local frameCategory = self.frameCategory
    local showFriendIcon, showGuildIcon, showIgnoredIcon = GetCustomFrameSocialIconShowFlags(frameCategory)
    if frameCategory == "target" or frameCategory == "smallGroup" then
        if not showFriendIcon and not showGuildIcon and not showIgnoredIcon then
            self.friendIcon:SetHidden(true)
            return
        end
    end
    local isIgnored = self.isPlayer and IsUnitIgnored(self.unitTag)
    local isFriend = self.isPlayer and IsUnitFriend(self.unitTag)
    local isGuild = self.isPlayer and not isFriend and not isIgnored and IsGuildMateUnitTag(self.unitTag)
    local ignoredIconPath
    if ZO_IsConsoleOrGameCoreUI() then
        ignoredIconPath = [[EsoUI/Art/Contacts/tabIcon_ignored_up.dds]]
    else
        ignoredIconPath = LUIE_MEDIA_UNITFRAMES_UNITFRAMES_SOCIAL_IGNORE_DDS
    end
    local shouldShowIcon = false
    local iconPath
    if isIgnored and showIgnoredIcon then
        shouldShowIcon = true
        iconPath = ignoredIconPath
    elseif isFriend and showFriendIcon then
        shouldShowIcon = true
        iconPath = "/esoui/art/campaign/campaignbrowser_friends.dds"
    elseif isGuild and showGuildIcon then
        shouldShowIcon = true
        iconPath = "/esoui/art/campaign/campaignbrowser_guild.dds"
    end
    if shouldShowIcon then
        self.friendIcon:SetTexture(iconPath)
        self.friendIcon:SetHidden(false)
    else
        self.friendIcon:SetHidden(true)
    end
end

function FrameObject:UpdateStaticControlReticleNameWidth()
    if self.name == nil or self.topInfo == nil then
        return
    end
    if FrameObject.HasCustomTopInfoFrameCategory(self) then
        return
    end
    if self.name:GetParent() == self.topInfo and self.unitTag == "reticleover" then
        local width = self.topInfo:GetWidth()
        if self.classIcon then
            width = width - self.classIcon:GetWidth()
        end
        if self.isPlayer then
            if self.friendIcon then
                width = width - self.friendIcon:GetWidth()
            end
            if self.level then
                width = width - 2.3 * self.levelIcon:GetWidth()
            end
        end
        self.name:SetWidth(width)
    end
end

function FrameObject:UpdateStaticControlLevelRow()
    if self.level == nil then
        return
    end
    if FrameObject.HasCustomTopInfoFrameCategory(self) then
        FrameObject.UpdateTopInfoLevelRow(self)
        return
    end
    local shouldShowVeterancyInfo = FrameObject.ShouldShowVeterancyRankOnFrame(self)
    local showLevel = self.isPlayer
    if showLevel then
        if self.unitTag == "player" or self.unitTag == "reticleover" then
            self.levelIcon:ClearAnchors()
            self.levelIcon:SetAnchor(LEFT, self.topInfo, LEFT, self.name:GetTextWidth() + 1, 0)
        end
        local iconPath
        local levelText
        if shouldShowVeterancyInfo then
            local veterancyRank = GetUnitVeterancyRank(self.unitTag)
            if GetVeterancyRankTitle and SI_VETERANCY_RANK_AND_TITLE_FORMATTER then
                local seasonId = GetCurrentVeterancySeasonId and GetCurrentVeterancySeasonId() or nil
                levelText = zo_strformat(SI_VETERANCY_RANK_AND_TITLE_FORMATTER, veterancyRank, GetVeterancyRankTitle(veterancyRank, seasonId))
            else
                levelText = tostring(veterancyRank)
            end
            if GetVeterancyRankIcon then
                local seasonId = GetCurrentVeterancySeasonId and GetCurrentVeterancySeasonId() or nil
                iconPath = GetVeterancyRankIcon(veterancyRank, seasonId)
            end
        elseif self.isChampion then
            if IsInGamepadPreferredMode() then
                iconPath = ZO_GetGamepadChampionPointsIcon()
            else
                iconPath = ZO_GetChampionPointsIconSmall()
            end
            levelText = tostring(GetUnitChampionPoints(self.unitTag))
        else
            if IsInGamepadPreferredMode() then
                iconPath = ZO_GetGamepadDungeonDifficultyIcon(DUNGEON_DIFFICULTY_NORMAL)
            else
                iconPath = ZO_GetKeyboardDungeonDifficultyIcon(DUNGEON_DIFFICULTY_NORMAL)
            end
            levelText = tostring(GetUnitLevel(self.unitTag))
        end
        if iconPath then
            self.levelIcon:SetTexture(iconPath)
        end
        self.levelIcon:SetResizeToFitFile(false)
        self.levelIcon:SetColor(1, 1, 1, 1)
        self.levelIcon:SetWidth(18)
        self.levelIcon:SetHeight(18)
        self.level:SetText(levelText)
    end
    if self.unitTag == "player" then
        self.levelIcon:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
        self.level:SetHidden(not UnitFrames.SV.PlayerEnableYourname)
    else
        self.levelIcon:SetHidden(not showLevel)
        self.level:SetHidden(not showLevel)
    end
end

--- @return string|nil savedTitle empty string when title cleared
function FrameObject:UpdateStaticControlTitleAndAva()
    local savedTitle
    if self.title ~= nil then
        local title
        local ava = ""
        if self.isPlayer then
            title = GetUnitTitle(self.unitTag)
            ava = GetAvARankName(GetUnitGender(self.unitTag), self.avaRankValue)
            if UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableTitle then
                title = (ava ~= "") and ava or ""
            elseif UnitFrames.SV.TargetEnableTitle and not UnitFrames.SV.TargetEnableRank then
                title = (title ~= "") and title or ""
            elseif UnitFrames.SV.TargetEnableTitle and UnitFrames.SV.TargetEnableRank then
                if UnitFrames.SV.TargetTitlePriority == "Title" then
                    title = (title ~= "") and title or (ava ~= "") and ava or ""
                else
                    title = (ava ~= "") and ava or (title ~= "") and title or ""
                end
            end
            title = title or ""
        else
            local unitCaption = GetUnitCaption(self.unitTag)
            title = unitCaption and zo_strformat(SI_TOOLTIP_UNIT_CAPTION, unitCaption) or ""
        end
        local titletext = StringOnlyGSUB(title, "%^%a+", "")
        self.title:SetText(titletext)
        self.title:SetWidth(self.title:GetStringWidth(titletext))
        if self.unitTag == "reticleover" then
            self.title:SetHidden(not UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableTitle)
        end
        if title == "" then
            savedTitle = ""
        end
    end
    if self.avaRank ~= nil then
        if self.isPlayer then
            self.avaRankIcon:SetTexture(GetAvARankIcon(self.avaRankValue))
            local alliance = GetUnitAlliance(self.unitTag)
            self.avaRankIcon:SetColor(GetAllianceColor(alliance):UnpackRGBA())
            if self.unitTag == "reticleover" and UnitFrames.SV.TargetEnableRankIcon then
                self.avaRank:SetText(tostring(self.avaRankValue))
                if self.avaRankValue > 0 then
                    self.avaRank:SetHidden(false)
                    self.avaRankIcon:SetHidden(false)
                else
                    self.avaRank:SetHidden(true)
                    self.avaRankIcon:SetHidden(true)
                end
            else
                self.avaRank:SetHidden(true)
                self.avaRankIcon:SetHidden(true)
            end
        else
            self.avaRank:SetHidden(true)
            self.avaRankIcon:SetHidden(true)
        end
    end
    return savedTitle
end

--- @param savedTitle string|nil
function FrameObject:UpdateStaticControlReticleBuffAnchors(savedTitle)
    if not self.buffs or self.unitTag ~= "reticleover" then
        return
    end
    if UnitFrames.SV.PlayerFrameOptions ~= 1 then
        if (not UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableTitle and not UnitFrames.SV.TargetEnableRankIcon) or (savedTitle == "" and not UnitFrames.SV.TargetEnableRankIcon and self.isPlayer) or (savedTitle == "" and not self.isPlayer) then
            self.debuffs:ClearAnchors()
            self.debuffs:SetAnchor(TOP, self.control, BOTTOM, 0, 5)
        else
            self.debuffs:ClearAnchors()
            self.debuffs:SetAnchor(TOP, self.buffAnchor, BOTTOM, 0, 5)
        end
    else
        if (not UnitFrames.SV.TargetEnableRank and not UnitFrames.SV.TargetEnableTitle and not UnitFrames.SV.TargetEnableRankIcon) or (savedTitle == "" and not UnitFrames.SV.TargetEnableRankIcon and self.isPlayer) or (savedTitle == "" and not self.isPlayer) then
            self.buffs:ClearAnchors()
            self.buffs:SetAnchor(TOP, self.control, BOTTOM, 0, 5)
        else
            self.buffs:ClearAnchors()
            self.buffs:SetAnchor(TOP, self.buffAnchor, BOTTOM, 0, 5)
        end
    end
end

function FrameObject:UpdateStaticControlDeadAndGroupAlpha()
    if self.dead ~= nil then
        if not IsUnitOnline(self.unitTag) then
            UnitFrames.OnGroupMemberConnectedStatus(nil, self.unitTag, false)
        elseif IsUnitDead(self.unitTag) then
            UnitFrames.OnDeath(nil, self.unitTag, true)
        else
            UnitFrames.CustomFramesSetDeadLabel(self, nil)
        end
    end
    if self.unitTag and "group" == (zo_strsub(self.unitTag, 0, 5)) and self.control then
        self.control:SetAlpha(IsUnitInGroupSupportRange(self.unitTag) and (UnitFrames.SV.GroupAlpha * 0.01) or (UnitFrames.SV.GroupAlpha * 0.01) / 2)
    end
end

--- @param frameCategory "player"|"target"|"group"|"raid"|nil
function FrameObject:UpdateStaticControlNameLabel(frameCategory)
    if self.name == nil then
        return
    end
    local displayOption = FrameObject.GetStaticControlDisplayOption(self)
    local nameText = FrameObject.BuildBaseStaticControlNameText(self, displayOption)
    nameText = FrameObject.ApplyStaticControlTargetMarkerToName(self, nameText, frameCategory)
    if frameCategory == "raid" then
        nameText = FrameObject.ApplyVeterancyRankNameIconForRaid(self, nameText)
        nameText = FrameObject.ApplyStaticControlOverlandToName(self, nameText, frameCategory)
    else
        nameText = FrameObject.ApplyStaticControlOverlandToName(self, nameText, frameCategory)
    end
    self.name:SetText(nameText)
end
