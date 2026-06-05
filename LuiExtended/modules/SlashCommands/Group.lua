-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.SlashCommands
local SlashCommands = LUIE.SlashCommands

local ChatOutput = LUIE.ChatOutput
local zo_strformat = zo_strformat

-- Slash Command to perform a group regroup
local g_regroupStacks = {}     -- Character stack for Regroup reinvites
local g_pendingRegroup = false -- Toggled when a regroup is in progress to prevent additional regroup attempts from firing
function SlashCommands.SlashRegroup()
    local function RegroupInvite()
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_REGROUP_REINVITE_MSG), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_SLASHCMDS_REGROUP_REINVITE_MSG))
        end
        for i = 1, #g_regroupStacks do
            local member = g_regroupStacks[i]
            -- Don't invite self and offline members
            if member.memberName ~= LUIE.PlayerNameFormatted then
                GroupInviteByName(member.memberName)
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_REGROUP_REINVITE_SENT_MSG), member.memberLink), true)
                if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_SLASHCMDS_REGROUP_REINVITE_SENT_MSG), member.memberNoLink))
                end
            end
        end
        g_pendingRegroup = false -- Allow Regroup command to be used again
        g_regroupStacks = {}     -- Allow index to be used again.
    end

    local groupSize = GetGroupSize()
    -- Check for pending regroup
    if g_pendingRegroup then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_PENDING), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_PENDING)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure player is in a group
    if groupSize <= 1 then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_NOTINGRP), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_NOTINGRP)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in a battleground
    if IsActiveWorldBattleground() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_BG), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_BG)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in LFG
    if IsInLFGGroup() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_LFGACTIVITY), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_LFGACTIVITY)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure player is the leader
    if not IsUnitGroupLeader("player") then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_NOTLEADER), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_REGROUP_FAILED_NOTLEADER)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    g_pendingRegroup = true

    local flagOffline = 0
    local index = 1
    for i = 1, groupSize do
        -- We need to index player here as well
        local memberTag = GetGroupUnitTagByIndex(i)
        if IsUnitOnline(memberTag) then
            local groupMemberString
            local groupMemberName = GetUnitName(memberTag)
            local groupMemberAccountName = GetUnitDisplayName(memberTag)
            local memberLink = LUIE.ChatAnnouncements.ResolveNameLink(groupMemberName, groupMemberAccountName)
            local memberNoLink = LUIE.ChatAnnouncements.ResolveNameNoLink(groupMemberName, groupMemberAccountName)

            -- Place inside counter incremented index, this way if we have offline members in the group we still index everything in an ordered integer list.
            g_regroupStacks[index] = { memberLink = memberLink, memberName = groupMemberName }
            index = index + 1
        else
            flagOffline = flagOffline + 1
        end
    end

    -- Reinvite the group after 5 seconds (give the group interface time to update on server and client end for all group members)
    -- If the stack counter was less than 1 (just the player eligible for reinvite then regroup won't invite any members.)
    if flagOffline > 0 then
        if #g_regroupStacks > 1 then
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SLASHCMDS_REGROUP_SAVED_SOME_OFF_MSG), flagOffline, flagOffline, flagOffline), true)
            if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_SLASHCMDS_REGROUP_SAVED_SOME_OFF_MSG), flagOffline, flagOffline, flagOffline))
            end
            GroupDisband()
            zo_callLater(RegroupInvite, 5000)
        else
            ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_REGROUP_SAVED_ALL_OFF_MSG), true)
            if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_SLASHCMDS_REGROUP_SAVED_ALL_OFF_MSG))
            end
            g_pendingRegroup = false -- Allow Regroup command to be used again
            g_regroupStacks = {}     -- Allow index to be used again.
        end
    else
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_REGROUP_SAVED_MSG), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString(LUIE_STRING_SLASHCMDS_REGROUP_SAVED_MSG))
        end
        GroupDisband()
        zo_callLater(RegroupInvite, 5000)
    end
end

-- Slash Command to disband the current group
function SlashCommands.SlashDisband()
    local groupSize = GetGroupSize()
    -- Check to make sure player is in a group
    if groupSize <= 1 then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_DISBAND_FAILED_NOGROUP), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_DISBAND_FAILED_NOGROUP)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure player is the leader
    if not IsUnitGroupLeader("player") then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_DISBAND_FAILED_NOTLEADER), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_DISBAND_FAILED_NOTLEADER)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure player is not in a BG
    if IsActiveWorldBattleground() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_DISBAND_FAILED_BG), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_DISBAND_FAILED_BG)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're not in LFG
    local isLFG = IsInLFGGroup()
    if isLFG then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_DISBAND_FAILED_LFG_ACTIVITY), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_DISBAND_FAILED_LFG_ACTIVITY)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    GroupDisband()
end

-- Slash Command to leave a group
function SlashCommands.SlashGroupLeave()
    if IsInGamepadPreferredMode() then
        -- Show confirmation dialog like the normal party menu does
        ZO_Dialogs_ShowDialog("GROUP_LEAVE_DIALOG")
    else
        -- EVENT_GROUP_NOTIFICATION_MESSAGE hook handles response to this.
        GroupLeave()
    end
end

function SlashCommands.SlashGroupRole(option)
    if option == "tank" then
        UpdateSelectedLFGRole(LFG_ROLE_TANK)
    elseif option == "heal" then
        UpdateSelectedLFGRole(LFG_ROLE_HEAL)
    elseif option == "dps" then
        UpdateSelectedLFGRole(LFG_ROLE_DPS)
    end
end

-- Slash Command to kick someone from a group
function SlashCommands.SlashGroupKick(option)
    local groupSize = GetGroupSize()
    -- Rather then error out, let the player use /kick and /remove as a substitute for /votekick and /voteremove in LFG
    if IsInLFGGroup() then
        if option == "" or option == nil then
            ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NONAME), true)
            if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NONAME)))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return
        else
            if SlashCommands.SV.SlashVoteKick then
                SlashCommands.SlashVoteKick(option)
            else
                ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_LFG), true)
                if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_LFG)))
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            end
            return
        end
    end

    -- Check to make sure player is in a group
    if groupSize <= 1 then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOGROUP), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOGROUP)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure player is the leader
    if not IsUnitGroupLeader("player") then
        ChatOutput:Print(GetString(LUIE_STRING_CA_GROUP_LEADERKICK_ERROR), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_CA_GROUP_LEADERKICK_ERROR)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NONAME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local g_partyKick = {}
    local kickedMemberName
    local kickedAccountName
    local compareName = zo_strlower(option)
    local comparePlayerName = zo_strlower(LUIE.PlayerNameFormatted)
    local comparePlayerAccount = zo_strlower(LUIE.PlayerDisplayName)
    local unitToKick

    for i = 1, 24 do
        local memberTag = GetGroupUnitTagByIndex(i)
        -- Once we reach a nil value (aka no party member there, stop the loop)
        if memberTag == nil then
            break
        end
        kickedMemberName = zo_strlower(GetUnitName(memberTag))
        kickedAccountName = zo_strlower(GetUnitDisplayName(memberTag))
        g_partyKick[i] = { memberTag = memberTag, kickedMemberName = kickedMemberName, kickedAccountName = kickedAccountName }
    end

    -- Iterate through UnitTags to get the member who just joined
    for i = 1, #g_partyKick do
        local kickcompare = g_partyKick[i]
        if kickcompare.kickedMemberName == compareName or kickcompare.kickedAccountName == compareName then
            if kickcompare.kickedMemberName == comparePlayerName or kickcompare.kickedAccountName == comparePlayerAccount then
                GroupLeave()
            else
                unitToKick = kickcompare.memberTag
                GroupKick(unitToKick)
            end
            return
        end
    end

    ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDNAME), true)
    if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_NOVALIDNAME)))
    end
    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
end

-- If the player uses /kick with no option then we need to play the kick emote, otherwise handle everything with the SlashGroupKick function.
function SlashCommands.SlashKick(option)
    if option == "" or option == nil or not SlashCommands.SV.SlashGroupKick then
        PlayEmoteByIndex(109)
    else
        SlashCommands.SlashGroupKick(option)
    end
end

-- Slash Command to initiate a votekick
function SlashCommands.SlashVoteKick(option)
    local groupSize = GetGroupSize()
    -- Check to make sure player is in a group
    if groupSize <= 1 then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_VOTEKICK_FAILED_NOTLFGKICK), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_VOTEKICK_FAILED_NOTLFGKICK)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    -- Check to make sure we're not in a battleground
    if IsActiveWorldBattleground() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_VOTEKICK_FAILED_BG), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_VOTEKICK_FAILED_BG)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Check to make sure we're in LFG
    if not IsInLFGGroup() then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_VOTEKICK_FAILED_NOTLFGKICK), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_VOTEKICK_FAILED_NOTLFGKICK)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_VOTEKICK_FAILED_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_VOTEKICK_FAILED_NONAME)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local g_partyKick = {}
    local kickedMemberName
    local kickedAccountName
    local compareName = zo_strlower(option)
    local comparePlayerName = zo_strlower(LUIE.PlayerNameFormatted)
    local comparePlayerAccount = zo_strlower(LUIE.PlayerDisplayName)
    local unitToKick = ""

    for i = 1, 24 do
        local memberTag = GetGroupUnitTagByIndex(i)
        -- Once we reach a nil value (aka no party member there, stop the loop)
        if memberTag == nil then
            break
        end
        kickedMemberName = zo_strlower(GetUnitName(memberTag))
        kickedAccountName = zo_strlower(GetUnitDisplayName(memberTag))
        g_partyKick[i] = { memberTag = memberTag, kickedMemberName = kickedMemberName, kickedAccountName = kickedAccountName }
    end

    -- Iterate through UnitTags to get the member who just joined
    for i = 1, #g_partyKick do
        local kickcompare = g_partyKick[i]
        if kickcompare.kickedMemberName == compareName or kickcompare.kickedAccountName == compareName then
            if kickcompare.kickedMemberName == comparePlayerName or kickcompare.kickedAccountName == comparePlayerAccount then
                unitToKick = kickcompare.memberTag
                break
            else
                unitToKick = kickcompare.memberTag
                break
            end
        end
    end

    -- If we try to kick ourself then display an error message.
    if GetUnitName(unitToKick) == LUIE.PlayerNameFormatted then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_SELF), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupLFGAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_KICK_FAILED_SELF)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    local flags = GROUP_ELECTION_FLAGS_REQUIRE_ALL_VOTES + GROUP_ELECTION_FLAGS_IGNORE_OFFLINE_MEMBERS
    BeginGroupElection(GROUP_ELECTION_TYPE_KICK_MEMBER, ZO_GROUP_ELECTION_DESCRIPTORS.NONE, unitToKick, flags)
    -- EVENT HANDLER takes care of the error messages here.
end

-- Slash Command to initiate a group ready check
function SlashCommands.SlashReadyCheck()
    local groupSize = GetGroupSize()
    -- Check to make sure player is in a group
    if groupSize <= 1 then
        ChatOutput:Print(GetString(LUIE_STRING_SLASHCMDS_READYCHECK_FAILED_NOTINGRP), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, (GetString(LUIE_STRING_SLASHCMDS_READYCHECK_FAILED_NOTINGRP)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end
    -- Send a ready check to group members
    ZO_SendReadyCheck()
end

-- Slash Command to send a group invite to a player
function SlashCommands.SlashInvite(option)
    local groupSize = GetGroupSize()

    if groupSize > 1 and not IsUnitGroupLeader("player") then
        ChatOutput:Print(zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE)), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE)))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    if option == "" or option == nil then
        ChatOutput:Print(GetString(LUIE_STRING_CA_GROUP_INVITE_NONAME), true)
        if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NONE, GetString(LUIE_STRING_CA_GROUP_INVITE_NONAME))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return
    end

    GroupInviteByName(option)
    ChatOutput:Print(zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_INVITED), option), true)
    if LUIE.ChatAnnouncements.SV.Group.GroupAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_INVITED), option))
    end
end
