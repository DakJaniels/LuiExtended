-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local eventManager = GetEventManager()

local GROUP_ELECTION_ICON_INFO =
{
    [GROUP_VOTE_CHOICE_ABSTAIN] =
    {
        icon = LUIE_MEDIA_UNITFRAMES_ELECTIONINFO_VOTEDICON_NOTYET_DDS,
        color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED)),
    },
    [GROUP_VOTE_CHOICE_FOR] =
    {
        icon = LUIE_MEDIA_UNITFRAMES_ELECTIONINFO_VOTEDICON_YES_DDS,
        color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_SUCCEEDED)),
    },
    [GROUP_VOTE_CHOICE_AGAINST] =
    {
        icon = LUIE_MEDIA_UNITFRAMES_ELECTIONINFO_VOTEDICON_NO_DDS,
        color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_FAILED)),
    },
    [GROUP_VOTE_CHOICE_INVALID] =
    {
        icon = LUIE_MEDIA_UNITFRAMES_ELECTIONINFO_VOTEDICON_NOTYET_DDS,
        color = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, INTERFACE_TEXT_COLOR_DISABLED)),
    },
}

-- -----------------------------------------------------------------------------
local function CreateElectionIcons()
    -- Small Group
    for i = 1, 4 do
        local unitTag = "SmallGroup" .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame and not frame.electionIcon then
            local parent = frame.topInfo or frame.control or frame[COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
            local icon = parent:CreateControl("$(parent)ElectionIcon", CT_TEXTURE)
            icon:SetDrawTier(DT_HIGH)
            icon:SetDrawLayer(DL_OVERLAY)
            icon:SetDimensions(20, 20)
            if frame.classIcon then
                icon:SetAnchor(LEFT, frame.classIcon, RIGHT, 4, 0)
            else
                icon:SetAnchor(RIGHT, parent, RIGHT, -2, 0)
            end
            icon:SetHidden(true)
            frame.electionIcon = icon
        end
    end
    -- Raid Group
    for i = 1, 12 do
        local unitTag = "RaidGroup" .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame and not frame.electionIcon then
            local parent = frame.control or frame[COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
            local icon = parent:CreateControl("$(parent)ElectionIcon", CT_TEXTURE)
            icon:SetDrawTier(DT_HIGH)
            icon:SetDrawLayer(DL_OVERLAY)
            icon:SetDimensions(18, 18)
            icon:SetAnchor(CENTER, parent, CENTER, 0, 0)
            icon:SetHidden(true)
            frame.electionIcon = icon
        end
    end
end

-- -----------------------------------------------------------------------------
---
--- @return integer companionGroupSize
function UnitFrames:GetCompanionGroupSize()
    return self.companionGroupSize
end

-- -----------------------------------------------------------------------------
---
--- @return integer combinedGroupSize
function UnitFrames:GetCombinedGroupSize()
    return self.groupSize + self:GetCompanionGroupSize()
end

-- -----------------------------------------------------------------------------
---
--- @param control table|{electionIcon:TextureControl}
--- @param unitTag string
function UnitFrames.RefreshElectionIcon(control, unitTag)
    local icon = control.electionIcon
    if not icon then
        CreateElectionIcons()
        icon = control.electionIcon
        if not icon then
            -- Still nil? Bail out, nothing to do
            LUIE:Log("Debug", "electionIcon was NIL!")
            return
        end
    end

    if IsUnitOnline(unitTag) then
        if not UnitFrames.activeElection and not UnitFrames.endElectionCallback then
            icon:SetHidden(true)
        else
            -- Use GROUP_ELECTION_ICON_INFO for both small and large groups
            local iconInfo = GROUP_ELECTION_ICON_INFO
            local vote = GetGroupElectionVoteByUnitTag(unitTag)
            if vote ~= GROUP_VOTE_CHOICE_FOR and not UnitFrames.activeElection then
                vote = GROUP_VOTE_CHOICE_AGAINST
            end
            local voteIconInfo = iconInfo[vote] or iconInfo[GROUP_VOTE_CHOICE_INVALID]
            icon:SetTexture(voteIconInfo.icon)
            icon:SetColor(voteIconInfo.color:UnpackRGBA())
            icon:SetHidden(false)
        end
    else
        icon:SetHidden(true)
    end
end

-- -----------------------------------------------------------------------------
---
function UnitFrames.UpdateElectionIcons()
    for i = 1, GetGroupSize() do
        local realUnitTag = GetGroupUnitTagByIndex(i)
        local frame = UnitFrames.CustomFrames[realUnitTag]
        if frame then
            UnitFrames.RefreshElectionIcon(frame, realUnitTag)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Begin a group election (called when an election starts)
---
function UnitFrames.BeginGroupElection()
    local electionType, _, descriptor = GetGroupElectionInfo()
    if ZO_IsGroupElectionTypeCustom and ZO_IsGroupElectionTypeCustom(electionType) and descriptor == ZO_GROUP_ELECTION_DESCRIPTORS.READY_CHECK then
        UnitFrames.activeElection = true
        if UnitFrames.endElectionCallback then
            zo_removeCallLater(UnitFrames.endElectionCallback)
            UnitFrames.endElectionCallback = nil
        end
        UnitFrames.UpdateElectionIcons()
    end
end

-- -----------------------------------------------------------------------------
--- Update election info (called when election progresses or ends)
---
--- @param resultType GroupElectionType
function UnitFrames.UpdateElectionInfo(resultType)
    local electionType, timeRemainingSeconds, descriptor = GetGroupElectionInfo()
    UnitFrames.activeElection = timeRemainingSeconds and timeRemainingSeconds > 0
    if UnitFrames.activeElection and ZO_IsGroupElectionTypeCustom and ZO_IsGroupElectionTypeCustom(electionType) then
        if descriptor == ZO_GROUP_ELECTION_DESCRIPTORS.READY_CHECK then
            UnitFrames.UpdateElectionIcons()
        end
    elseif ZO_IsGroupElectionTypeCustom and ZO_IsGroupElectionTypeCustom(electionType) then
        -- Time remaining <= 0
        resultType = resultType or GROUP_ELECTION_RESULT_NOT_APPLICABLE
        UnitFrames.EndGroupElection(resultType)
    end
end

-- -----------------------------------------------------------------------------
--- End a group election (called when election ends)
---
--- @param resultType GroupElectionType
function UnitFrames.EndGroupElection(resultType)
    UnitFrames.activeElection = false
    if resultType ~= GROUP_ELECTION_RESULT_ABANDONED and resultType ~= GROUP_ELECTION_RESULT_NOT_APPLICABLE then
        local ELECTION_WON_DELAY_MS = 3000
        local ELECTION_LOST_DELAY_MS = 5000
        local postElectionDelayMS = resultType == GROUP_ELECTION_RESULT_ELECTION_WON and ELECTION_WON_DELAY_MS or ELECTION_LOST_DELAY_MS
        local function OnEndElection()
            UnitFrames.HideElectionIcons()
            UnitFrames.endElectionCallback = nil
        end
        UnitFrames.endElectionCallback = zo_callLater(OnEndElection, postElectionDelayMS)
    end
    UnitFrames.UpdateElectionIcons()
end

-- -----------------------------------------------------------------------------
--- Hide all election icons for group/raid frames
---
function UnitFrames.HideElectionIcons()
    for i = 1, 4 do
        local unitTag = "SmallGroup" .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame and frame.electionIcon then
            frame.electionIcon:SetHidden(true)
        end
    end
    for i = 1, 12 do
        local unitTag = "RaidGroup" .. i
        local frame = UnitFrames.CustomFrames[unitTag]
        if frame and frame.electionIcon then
            frame.electionIcon:SetHidden(true)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Register for group election events
---
function UnitFrames.RegisterForGroupElectionEvents()
    eventManager:RegisterForEvent("LUIE_GroupElectionFailed", EVENT_GROUP_ELECTION_FAILED, UnitFrames.HideElectionIcons)
    eventManager:RegisterForEvent("LUIE_GroupElectionRequested", EVENT_GROUP_ELECTION_REQUESTED, UnitFrames.BeginGroupElection)
    eventManager:RegisterForEvent("LUIE_GroupElectionNotificationAdded", EVENT_GROUP_ELECTION_NOTIFICATION_ADDED, UnitFrames.BeginGroupElection)
    eventManager:RegisterForEvent("LUIE_GroupElectionProgressUpdated", EVENT_GROUP_ELECTION_PROGRESS_UPDATED, UnitFrames.UpdateElectionInfo)
    eventManager:RegisterForEvent("LUIE_GroupElectionResult", EVENT_GROUP_ELECTION_RESULT, UnitFrames.UpdateElectionInfo)
    eventManager:RegisterForEvent("LUIE_GroupMemberConnectedStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS, UnitFrames.UpdateElectionIcons)
    eventManager:RegisterForEvent("LUIE_GroupUpdate", EVENT_GROUP_UPDATE, UnitFrames.UpdateElectionIcons)
    eventManager:RegisterForEvent("LUIE_GroupMemberJoined", EVENT_GROUP_MEMBER_JOINED, UnitFrames.UpdateElectionIcons)
    eventManager:RegisterForEvent("LUIE_GroupMemberLeft", EVENT_GROUP_MEMBER_LEFT, UnitFrames.UpdateElectionIcons)
end

-- -----------------------------------------------------------------------------
