-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements hook shared context (CSA / alerts)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local S = ChatAnnouncements.State
local I = ChatAnnouncements.Internal
local B = ChatAnnouncements.Brackets
local ColorizeColors = ChatAnnouncements.Colors
local Data = LuiData.Data
local Quests = Data.Quests
local ChatOutput = LUIE.ChatOutput
local string_format = string.format
local table_insert = table.insert
local windowManager = GetWindowManager()

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterGroup(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler

    local function GroupInviteResponseAlert(characterName, response, displayName)
        local finalName
        local finalAlertName

        if response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED_CANT_JOIN then
            -- characterName is the inviter, not the invitee (ZOS AlertHandlers EVENT_GROUP_INVITE_RESPONSE)
            finalName = ChatAnnouncements.ResolveNameLink(characterName, "")
            finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, "")
            if characterName ~= "" then
                finalAlertName = ZO_FormatUserFacingCharacterName(characterName)
            end
        else
            local nameCheck1 = ZO_GetPrimaryPlayerName(displayName, characterName)
            local nameCheck2 = ZO_GetSecondaryPlayerName(displayName, characterName)

            if nameCheck1 == "" then
                finalName = displayName
                finalAlertName = displayName
            elseif nameCheck2 == "" then
                finalName = characterName
                finalAlertName = characterName
            elseif nameCheck1 ~= "" and nameCheck2 ~= "" then
                finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
                finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
            else
                finalName = ""
                finalAlertName = ""
            end
        end

        if response ~= GROUP_INVITE_RESPONSE_ACCEPTED and response ~= GROUP_INVITE_RESPONSE_CONSIDERING_OTHER then
            local message
            local alertMessage

            if response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED and (LUIE.PlayerNameFormatted == characterName or LUIE.PlayerDisplayName == displayName) then
                message = zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_SELF_INVITE))
                alertMessage = zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_SELF_INVITE))
            elseif response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED and (IsPlayerInGroup(characterName) or IsPlayerInGroup(displayName)) then
                message = GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
                alertMessage = GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
            elseif response == GROUP_INVITE_RESPONSE_IGNORED then
                message = finalName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalName) or GetString(SI_PLAYER_BUSY)
                alertMessage = finalAlertName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalAlertName) or GetString(SI_PLAYER_BUSY)
            else
                message = finalName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalName) or characterName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), characterName) or GetString(SI_PLAYER_BUSY)
                alertMessage = finalAlertName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), finalAlertName) or characterName ~= "" and zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", response), characterName) or GetString(SI_PLAYER_BUSY)
            end

            if ChatAnnouncements.SV.Group.GroupCA or response == GROUP_INVITE_RESPONSE_ALREADY_GROUPED or response == GROUP_INVITE_RESPONSE_IGNORED or response == GROUP_INVITE_RESPONSE_PLAYER_NOT_FOUND then
                ChatOutput:Print(message, true)
            end
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertMessage)
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        return true
    end

    -- EVENT_GROUP_INVITE_ACCEPT_RESPONSE_TIMEOUT (Alert Handler)
    local function GroupInviteTimeoutAlert()
        ChatOutput:Print(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_GENERIC_JOIN_FAILURE), true)
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_GENERIC_JOIN_FAILURE))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        return true
    end

    -- EVENT_GROUP_NOTIFICATION_MESSAGE (Alert Handler)
    local function GroupNotificationMessageAlert(groupMessageCode)
        local message = GetString("SI_GROUPNOTIFICATIONMESSAGE", groupMessageCode)
        if message ~= "" then
            ChatOutput:Print(message, true)
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, message)
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        return true
    end

    -- EVENT_GROUP_UPDATE (Alert Handler)
    local function GroupUpdateAlert()
        S.g_currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
        S.g_currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
    end

    -- EVENT_GROUP_MEMBER_LEFT (Alert Handler)
    local function GroupMemberLeftAlert(characterName, reason, isLocalPlayer, isLeader, displayName, actionRequiredVote)
        ChatAnnouncements.IndexGroupLoot()

        local message = nil
        local alert = nil
        local message2 = nil
        local alert2 = nil
        local sound = nil

        local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)

        -- Used to check for valid links
        local characterNameLink = ZO_LinkHandler_CreateCharacterLink(characterName)
        local displayNameLink = ZO_LinkHandler_CreateDisplayNameLink(displayName)

        local hasValidNames = characterNameLink ~= "" and displayNameLink ~= ""
        local useDefaultReasonText = false
        if reason == GROUP_LEAVE_REASON_DISBAND then
            if isLeader and not isLocalPlayer then
                useDefaultReasonText = true
            elseif isLeader and isLocalPlayer then
                message = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                alert = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(false)
                             end, 100)
            elseif isLocalPlayer then
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(false)
                             end, 100)
            end
            sound = SOUNDS.GROUP_DISBAND
        elseif reason == GROUP_LEAVE_REASON_KICKED then
            if actionRequiredVote then
                if isLocalPlayer then
                    zo_callLater(function ()
                                     ChatAnnouncements.CheckLFGStatusLeave(true)
                                 end, 100)
                    message = zo_strformat(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
                    alert = zo_strformat(SI_GROUP_ELECTION_KICK_PLAYER_PASSED)
                elseif hasValidNames then
                    zo_callLater(function ()
                                     ChatAnnouncements.CheckLFGStatusLeave(false)
                                 end, 100)
                    message = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_PASSED, finalName)
                    alert = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_PASSED, finalAlertName)
                    message2 = zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_KICKED), finalName)
                    alert2 = zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_KICKED), finalAlertName)
                end
                sound = SOUNDS.GROUP_KICK
            else
                if isLeader and isLocalPlayer then
                    message = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                    alert = zo_strformat(LUIE_STRING_GROUPDISBANDLEADER)
                    zo_callLater(function ()
                                     ChatAnnouncements.CheckLFGStatusLeave(false)
                                 end, 100)
                    sound = SOUNDS.GROUP_DISBAND
                elseif isLocalPlayer then
                    zo_callLater(function ()
                                     ChatAnnouncements.CheckLFGStatusLeave(true)
                                 end, 100)
                    message = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_SELF_KICKED)
                    alert = zo_strformat(SI_GROUP_NOTIFICATION_GROUP_SELF_KICKED)
                    sound = SOUNDS.GROUP_KICK
                else
                    zo_callLater(function ()
                                     ChatAnnouncements.CheckLFGStatusLeave(false)
                                 end, 100)
                    useDefaultReasonText = true
                    sound = SOUNDS.GROUP_KICK
                end
            end
        elseif reason == GROUP_LEAVE_REASON_VOLUNTARY or reason == GROUP_LEAVE_REASON_LEFT_BATTLEGROUND then
            if not isLocalPlayer then
                useDefaultReasonText = true
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(false)
                             end, 100)
            else
                message = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_LEAVE_SELF), finalName))
                alert = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_LEAVE_SELF), finalAlertName))
                zo_callLater(function ()
                                 ChatAnnouncements.CheckLFGStatusLeave(false)
                             end, 100)
            end

            sound = SOUNDS.GROUP_LEAVE
        elseif reason == GROUP_LEAVE_REASON_DESTROYED then
            -- do nothing, we don't want to show additional alerts for this case
        end

        if useDefaultReasonText and hasValidNames then
            message = zo_strformat(GetString("LUIE_STRING_GROUPLEAVEREASON", reason), finalName)
            alert = zo_strformat(GetString("LUIE_STRING_GROUPLEAVEREASON", reason), finalAlertName)
        end

        if isLocalPlayer then
            S.g_currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
            S.g_currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())
        end

        -- Only print this out if we didn't JUST join an LFG group.
        if S.g_stopGroupLeaveQueue or S.g_lfgDisableGroupEvents then
            return true
        else
            if message ~= nil then
                if ChatAnnouncements.SV.Group.GroupCA then
                    ChatOutput:Print(message, true)
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alert)
                end
                if sound ~= nil then
                    PlaySound(sound)
                end
            end

            if message2 ~= nil then
                if ChatAnnouncements.SV.Group.GroupCA then
                    ChatOutput:Print(message2, true)
                end
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alert2)
                end
            end
        end

        return true
    end

    -- EVENT_GROUP_MEMBER_JOINED (Alert Handler)
    local function OnGroupMemberJoined(characterName, displayName, isLocalPlayer)
        -- Update index for Group Loot
        ChatAnnouncements.IndexGroupLoot()
        S.g_currentGroupLeaderRawName = GetRawUnitName(GetGroupLeaderUnitTag())
        S.g_currentGroupLeaderDisplayName = GetUnitDisplayName(GetGroupLeaderUnitTag())

        -- Determine if the member that joined a group is the player or another member.
        if isLocalPlayer then
            zo_callLater(ChatAnnouncements.CheckLFGStatusJoin, 100)
        else
            local finalName = ChatAnnouncements.ResolveNameLink(characterName, displayName)
            local finalAlertName = ChatAnnouncements.ResolveNameNoLink(characterName, displayName)
            -- Set final messages to send
            local SendMessage = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalName))
            local SendAlert = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_MEMBER_JOIN), finalAlertName))
            zo_callLater(function ()
                             ChatAnnouncements.PrintJoinStatusNotSelf(SendMessage, SendAlert)
                         end, 100)
        end

        return true
    end

    -- EVENT_LEADER_UPDATE (Alert Handler)
    -- Note: This event only fires if the characterId of the leader has changed (it's a new leader)
    local function LeaderUpdateAlert(leaderTag)
        local leaderRawName = GetRawUnitName(leaderTag)
        local showAlert = leaderRawName ~= "" and (S.g_currentGroupLeaderRawName ~= "" and S.g_currentGroupLeaderRawName ~= nil)
        S.g_currentGroupLeaderRawName = leaderRawName
        S.g_currentGroupLeaderDisplayName = GetUnitDisplayName(leaderTag)

        -- If for some reason we don't have a valid leader name, bail out now.
        if S.g_currentGroupLeaderRawName == "" or S.g_currentGroupLeaderRawName == nil or S.g_currentGroupLeaderDisplayName == "" or S.g_currentGroupLeaderDisplayName == nil then
            return true
        end

        local displayString
        local alertString
        local finalName = ChatAnnouncements.ResolveNameLink(S.g_currentGroupLeaderRawName, S.g_currentGroupLeaderDisplayName)
        local finalAlertName = ChatAnnouncements.ResolveNameNoLink(S.g_currentGroupLeaderRawName, S.g_currentGroupLeaderDisplayName)

        if LUIE.PlayerNameRaw ~= S.g_currentGroupLeaderRawName then -- If another player became the leader
            displayString = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED), finalName))
            alertString = (zo_strformat(GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED), finalAlertName))
        elseif LUIE.PlayerNameRaw == S.g_currentGroupLeaderRawName then -- If the player character became the leader
            displayString = (GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED_SELF))
            alertString = (GetString(LUIE_STRING_CA_GROUP_LEADER_CHANGED_SELF))
        end

        -- Don't show leader updates when joining LFG.
        if S.g_stopGroupLeaveQueue or S.g_lfgDisableGroupEvents then
            return true
        end

        if showAlert then
            if ChatAnnouncements.SV.Group.GroupCA then
                ChatOutput:Print(displayString, true)
            end
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertString)
            end
            PlaySound(SOUNDS.GROUP_PROMOTE)
        end
        return true
    end

    -- EVENT_ACTIVITY_QUEUE_RESULT (Alert Handler)
    local function ActivityQueueResultAlert(result)
        if result ~= ACTIVITY_QUEUE_RESULT_SUCCESS then
            if ChatAnnouncements.SV.Group.GroupLFGCA then
                ChatOutput:Print(GetString("SI_ACTIVITYQUEUERESULT", result), true)
            end
            if ChatAnnouncements.SV.Group.GroupLFGAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString("SI_ACTIVITYQUEUERESULT", result))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        S.g_showRCUpdates = true

        return true
    end

    -- EVENT_GROUP_ELECTION_FAILED (Alert Handler)
    local function GroupElectionFailedAlert(failureType, descriptor)
        if failureType ~= GROUP_ELECTION_FAILURE_NONE then
            if ChatAnnouncements.SV.Group.GroupVoteCA then
                ChatOutput:Print(GetString("SI_GROUPELECTIONFAILURE", failureType), true)
            end
            if ChatAnnouncements.SV.Group.GroupVoteAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ERROR, nil, GetString("SI_GROUPELECTIONFAILURE", failureType))
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
        end
        return true
    end

    -- Variables for EVENT_GROUP_ELECTION_RESULT
    local GroupElectionResultToSoundId =
    {
        [GROUP_ELECTION_RESULT_ELECTION_WON] = SOUNDS.GROUP_ELECTION_RESULT_WON,
        [GROUP_ELECTION_RESULT_ELECTION_LOST] = SOUNDS.GROUP_ELECTION_RESULT_LOST,
        [GROUP_ELECTION_RESULT_ABANDONED] = SOUNDS.GROUP_ELECTION_RESULT_LOST,
    }

    -- EVENT_GROUP_ELECTION_RESULT (Alert Handler)
    local function GroupElectionResultAlert(resultType, descriptor)
        if resultType ~= GROUP_ELECTION_RESULT_IN_PROGRESS and resultType ~= GROUP_ELECTION_RESULT_NOT_APPLICABLE then
            resultType = ZO_GetSimplifiedGroupElectionResultType(resultType)
            local alertText
            local message

            -- Try to find override messages based on the descriptor
            local alertTextOverrideLookup = ZO_GroupElectionResultToAlertTextOverrides[resultType]
            if alertTextOverrideLookup then
                message = alertTextOverrideLookup[descriptor]
                alertText = alertTextOverrideLookup[descriptor]
            end

            -- No override found
            if not alertText then
                local electionType, _, _, targetUnitTag = GetGroupElectionInfo()
                if not targetUnitTag then
                    return
                end
                if electionType == GROUP_ELECTION_TYPE_KICK_MEMBER then
                    if resultType == GROUP_ELECTION_RESULT_ELECTION_LOST then
                        local kickMemberName = GetUnitName(targetUnitTag)
                        local kickMemberAccountName = GetUnitDisplayName(targetUnitTag)

                        local kickFinalName = ChatAnnouncements.ResolveNameLink(kickMemberName, kickMemberAccountName)
                        local kickfinalAlertName = ChatAnnouncements.ResolveNameNoLink(kickMemberName, kickMemberAccountName)

                        message = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_FAIL, kickFinalName)
                        alertText = zo_strformat(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_FAIL, kickfinalAlertName)
                    else
                        -- Successful kicks are handled in the GROUP_MEMBER_LEFT alert
                        return true
                    end
                end
            end

            -- No specific behavior found, so just do the generic alert for the result
            if not alertText then
                message = GetString("SI_GROUPELECTIONRESULT", resultType)
                alertText = GetString("SI_GROUPELECTIONRESULT", resultType)
            end

            if alertText ~= "" then
                if type(alertText) == "function" then
                    alertText = alertText()
                    message = message()
                end

                if ChatAnnouncements.SV.Group.GroupVoteCA then
                    ChatOutput:Print(message, true)
                end
                if ChatAnnouncements.SV.Group.GroupVoteAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertText)
                end
                PlaySound(GroupElectionResultToSoundId[resultType])
            end
        end
        return true
    end

    -- EVENT_GROUP_ELECTION_REQUESTED (Alert Handler)
    local function GroupElectionRequestedAlert(descriptor)
        local alertText
        local messageText
        if descriptor then
            messageText = ZO_GroupElectionDescriptorToRequestAlertText[descriptor]
            alertText = ZO_GroupElectionDescriptorToRequestAlertText[descriptor]
        end

        if not alertText then
            messageText = ZO_GroupElectionDescriptorToRequestAlertText[ZO_GROUP_ELECTION_DESCRIPTORS.NONE]
            alertText = ZO_GroupElectionDescriptorToRequestAlertText[ZO_GROUP_ELECTION_DESCRIPTORS.NONE]
        end

        -- If this is a votekick then change the message.
        -- TODO: GetGroupElectionInfo() doesn't update with EVENT_GROUP_ELECTION_REQUESTED
        --[[
        local electionType, _, _, targetUnitTag = GetGroupElectionInfo()
        if electionType == GROUP_ELECTION_TYPE_KICK_MEMBER then -- Vote Kick
            local kickMemberName = GetUnitName(targetUnitTag)
            local kickMemberAccountName = GetUnitDisplayName(targetUnitTag)
            if kickMemberName ~= nil and kickMemberName ~= "" and kickMemberAccountName ~= nil and kickMemberAccountName ~= "" then
                local finalNameCA = ChatAnnouncements.ResolveNameLink(kickMemberName, kickMemberAccountName)
                messageText = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_START_SELF), finalNameCA)
                local finalNameAlert = ChatAnnouncements.ResolveNameNoLink(kickMemberName, kickMemberAccountName)
                alertText = zo_strformat(GetString(LUIE_STRING_CA_GROUPFINDER_VOTEKICK_START_SELF), finalNameAlert)
            end
        end
        ]]
        --

        if ChatAnnouncements.SV.Group.GroupVoteCA then
            ChatOutput:Print(messageText, true)
        end
        if ChatAnnouncements.SV.Group.GroupVoteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertText)
        end
        PlaySound(SOUNDS.GROUP_ELECTION_REQUESTED)
        return true
    end

    -- EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED (Alert Handler)
    local function GroupReadyCheckCancelAlert(reason)
        local message

        if reason ~= LFG_READY_CHECK_CANCEL_REASON_NOT_IN_READY_CHECK and reason ~= LFG_READY_CHECK_CANCEL_REASON_GROUP_FORMED_SUCCESSFULLY then
            message = GetString("SI_LFGREADYCHECKCANCELREASON", reason)
            if ChatAnnouncements.SV.Group.GroupLFGCA then
                ChatOutput:Print(message, true)
            end
            if ChatAnnouncements.SV.Group.GroupLFGAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
            end
        end

        -- Stop the cancel message from status update from triggering when any other result here happens.
        S.g_lfgHideStatusCancel = true
        zo_callLater(function ()
                         S.g_lfgHideStatusCancel = false
                     end, 1000)

        -- Sometimes if another player cancels slightly before a player in your group cancels, the "you have been placed in the front of the queue message displays. If this is the case, we want to show queue left for that event."
        if reason ~= LFG_READY_CHECK_CANCEL_REASON_GROUP_REPLACED_IN_QUEUE then
            S.g_showActivityStatus = false
            zo_callLater(function ()
                             S.g_showActivityStatus = true
                         end, 1000)
        end

        S.g_showRCUpdates = true
    end

    -- EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED (Alert Handler)
    local function GroupDifficultyChangeAlert(isVeteranDifficulty)
        local message
        local sound
        if isVeteranDifficulty then
            message = GetString(SI_DUNGEON_DIFFICULTY_CHANGED_TO_VETERAN)
            sound = SOUNDS.DUNGEON_DIFFICULTY_VETERAN
        else
            message = GetString(SI_DUNGEON_DIFFICULTY_CHANGED_TO_NORMAL)
            sound = SOUNDS.DUNGEON_DIFFICULTY_NORMAL
        end

        if ChatAnnouncements.SV.Group.GroupCA then
            ChatOutput:Print(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
        PlaySound(sound)

        return true
    end

    ZO_PreHook(alertHandlers, EVENT_GROUP_INVITE_RESPONSE, GroupInviteResponseAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_INVITE_ACCEPT_RESPONSE_TIMEOUT, GroupInviteTimeoutAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_NOTIFICATION_MESSAGE, GroupNotificationMessageAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_UPDATE, GroupUpdateAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_MEMBER_LEFT, GroupMemberLeftAlert)
    ZO_PreHook(alertHandlers, EVENT_LEADER_UPDATE, LeaderUpdateAlert)
    ZO_PreHook(alertHandlers, EVENT_ACTIVITY_QUEUE_RESULT, ActivityQueueResultAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_FAILED, GroupElectionFailedAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_RESULT, GroupElectionResultAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_ELECTION_REQUESTED, GroupElectionRequestedAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUPING_TOOLS_READY_CHECK_CANCELLED, GroupReadyCheckCancelAlert)
    ZO_PreHook(alertHandlers, EVENT_GROUP_VETERAN_DIFFICULTY_CHANGED, GroupDifficultyChangeAlert)

    ZO_PreHook(alertHandlers, EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    -- This function isn't needed if CA isn't enabled so only load it if CA is enabled
    if ChatAnnouncements.Enabled then
        eventManager:RegisterForEvent(moduleName, EVENT_GROUP_TYPE_CHANGED, ChatAnnouncements.OnGroupTypeChanged)
    end
    eventManager:RegisterForEvent(moduleName, EVENT_GROUP_INVITE_RECEIVED, ChatAnnouncements.OnGroupInviteReceived)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUP_ELECTION_NOTIFICATION_ADDED, ChatAnnouncements.VoteNotify)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_NO_LONGER_LFG, ChatAnnouncements.LFGLeft)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_LFG_JOINED, ChatAnnouncements.GroupingToolsLFGJoined)
    eventManager:RegisterForEvent(moduleName, EVENT_ACTIVITY_FINDER_STATUS_UPDATE, ChatAnnouncements.ActivityStatusUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_GROUPING_TOOLS_READY_CHECK_UPDATED, ChatAnnouncements.ReadyCheckUpdate)
    -- EVENT_RAID_TRIAL_STARTED (CSA Handler)
    local function RaidStartedHook(raidName, isWeekly)
        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidCA then
            local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
            ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, formattedName), true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_STARTED)
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, raidName))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_STARTED, raidName))
        end

        -- Play sound if CSA is not enabled
        if not ChatAnnouncements.SV.Group.GroupRaidCSA then
            PlaySound(SOUNDS.RAID_TRIAL_STARTED)
        end
        return true
    end

    local TRIAL_COMPLETE_LIFESPAN_MS = 10000
    -- EVENT_RAID_TRIAL_COMPLETE (CSA Handler)
    local function RaidCompleteHook(raidName, score, totalTime)
        local wasUnderTargetTime = GetRaidDuration() <= GetRaidTargetTime()
        local formattedTime = ZO_FormatTimeMilliseconds(totalTime, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS)
        local vitalityBonus = GetCurrentRaidLifeScoreBonus()
        local currentCount = GetRaidReviveCountersRemaining()
        local maxCount = GetCurrentRaidStartingReviveCounters()

        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidCA then
            local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
            local vitalityCounterString = zo_strformat("<<1>> <<2>>/<<3>>", zo_iconFormatInheritColor("esoui/art/trials/vitalitydepletion.dds", 16, 16), currentCount, maxCount)
            local finalScore = ZO_DEFAULT_ENABLED_COLOR:Colorize(score)
            vitalityBonus = ZO_DEFAULT_ENABLED_COLOR:Colorize(vitalityBonus)
            if currentCount == 0 then
                vitalityCounterString = ZO_DISABLED_TEXT:Colorize(vitalityCounterString)
            else
                vitalityCounterString = ZO_DEFAULT_ENABLED_COLOR:Colorize(vitalityCounterString)
            end
            if wasUnderTargetTime then
                formattedTime = ZO_DEFAULT_ENABLED_COLOR:Colorize(formattedTime)
            else
                formattedTime = ZO_ERROR_COLOR:Colorize(formattedTime)
            end

            ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_COMPLETED_LARGE, formattedName), true)
            ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORETALLY, finalScore, formattedTime, vitalityBonus, vitalityCounterString), true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_RAID_COMPLETE_TEXT, SOUNDS.RAID_TRIAL_COMPLETED)
            messageParams:SetEndOfRaidData(
                {
                    score,
                    formattedTime,
                    wasUnderTargetTime,
                    vitalityBonus,
                    zo_strformat(SI_REVIVE_COUNTER_REVIVES_USED, currentCount, maxCount),
                })
            messageParams:SetText(zo_strformat(SI_TRIAL_COMPLETED_LARGE, raidName))
            messageParams:SetLifespanMS(TRIAL_COMPLETE_LIFESPAN_MS)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(SI_TRIAL_COMPLETED_LARGE, raidName))
        end

        -- Play sound if CSA is not enabled
        if not ChatAnnouncements.SV.Group.GroupRaidCSA then
            PlaySound(SOUNDS.RAID_TRIAL_COMPLETED)
        end
        return true
    end

    -- EVENT_RAID_TRIAL_FAILED (CSA Handler)
    local function RaidFailedHook(raidName, score)
        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidCA then
            local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
            ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, formattedName), true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_FAILED)
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, raidName))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_FAILED, raidName))
        end

        -- Play sound if CSA is not enabled
        if not ChatAnnouncements.SV.Group.GroupRaidCSA then
            PlaySound(SOUNDS.RAID_TRIAL_FAILED)
        end
        return true
    end

    -- EVENT_RAID_TRIAL_NEW_BEST_SCORE (CSA Handler)
    local function RaidBestScoreHook(raidName, score, isWeekly)
        -- Display CA
        if ChatAnnouncements.SV.Group.GroupRaidBestScoreCA then
            local formattedName = zo_strformat("|cFFFFFF<<1>>|r", raidName)
            local formattedString = isWeekly and zo_strformat(SI_TRIAL_NEW_BEST_SCORE_WEEKLY, formattedName) or zo_strformat(SI_TRIAL_NEW_BEST_SCORE_LIFETIME, formattedName)
            ChatOutput:Print(formattedString, true)
        end

        -- Display CSA
        if ChatAnnouncements.SV.Group.GroupRaidBestScoreCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.RAID_TRIAL_NEW_BEST)
            messageParams:SetText(zo_strformat(isWeekly and SI_TRIAL_NEW_BEST_SCORE_WEEKLY or SI_TRIAL_NEW_BEST_SCORE_LIFETIME, raidName))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Display Alert
        if ChatAnnouncements.SV.Group.GroupRaidBestScoreAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(isWeekly and SI_TRIAL_NEW_BEST_SCORE_WEEKLY or SI_TRIAL_NEW_BEST_SCORE_LIFETIME, raidName))
        end

        -- Play sound ONLY if normal score is not set to display, otherwise the audio will overlap
        if not ChatAnnouncements.SV.Group.GroupRaidBestScoreCSA and not (ChatAnnouncements.SV.Group.GroupRaidScoreCA and ChatAnnouncements.SV.Group.GroupRaidScoreCSA and ChatAnnouncements.SV.Group.GroupRaidScoreAlert) then
            PlaySound(SOUNDS.RAID_TRIAL_NEW_BEST)
        end
        return true
    end

    -- EVENT_RAID_REVIVE_COUNTER_UPDATE (CSA Handler)
    local function RaidReviveCounterHook(currentCount, countDelta)
        if not IsRaidInProgress() then
            return
        end
        if countDelta < 0 then
            if ChatAnnouncements.SV.Group.GroupRaidReviveCA then
                local iconCA = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", 16, 16)
                ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconCA), true)
            end

            if ChatAnnouncements.SV.Group.GroupRaidReviveCSA then
                local iconCSA = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", "100%", "100%")
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.RAID_TRIAL_COUNTER_UPDATE)
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconCSA))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Group.GroupRaidReviveAlert then
                local iconAlert = zo_iconFormat("EsoUI/Art/Trials/VitalityDepletion.dds", "75%", "75%")
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_GROUP_REVIVE_COUNTER_UPDATED, iconAlert))
            end

            -- Play Sound if CSA is not enabled
            if not ChatAnnouncements.SV.Group.GroupRaidReviveCSA then
                PlaySound(SOUNDS.RAID_TRIAL_COUNTER_UPDATE)
            end
        end
        return true
    end

    local TRIAL_SCORE_REASON_TO_ASSETS =
    {
        [RAID_POINT_REASON_KILL_MINIBOSS] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_normal.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_NORMAL,
        },
        [RAID_POINT_REASON_KILL_BOSS] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_veryHigh.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH,
        },

        [RAID_POINT_REASON_BONUS_ACTIVITY_LOW] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_veryLow.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_LOW,
        },
        [RAID_POINT_REASON_BONUS_ACTIVITY_MEDIUM] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_low.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_LOW,
        },
        [RAID_POINT_REASON_BONUS_ACTIVITY_HIGH] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_high.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH,
        },

        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_ONE] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_veryLow.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_LOW,
        },
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_TWO] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_low.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_LOW,
        },
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_THREE] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_normal.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_NORMAL,
        },
        [RAID_POINT_REASON_SOLO_ARENA_PICKUP_FOUR] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_high.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_HIGH,
        },
        [RAID_POINT_REASON_SOLO_ARENA_COMPLETE] =
        {
            icon = "EsoUI/Art/Trials/trialPoints_veryHigh.dds",
            soundId = SOUNDS.RAID_TRIAL_SCORE_ADDED_VERY_HIGH,
        },
    }

    -- EVENT_RAID_TRIAL_SCORE_UPDATE (CSA Handler)
    local function RaidScoreUpdateHook(scoreUpdateReason, scoreAmount, totalScore)
        local reasonAssets = TRIAL_SCORE_REASON_TO_ASSETS[scoreUpdateReason]
        if reasonAssets then
            -- Display CA
            if ChatAnnouncements.SV.Group.GroupRaidScoreCA then
                local iconCA = zo_iconFormat(reasonAssets.icon, 16, 16)
                ChatOutput:Print(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconCA, scoreAmount), true)
            end

            -- Display CSA
            if ChatAnnouncements.SV.Group.GroupRaidScoreCSA then
                local iconCSA = zo_iconFormat(reasonAssets.icon, "100%", "100%")
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, reasonAssets.soundId)
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconCSA, scoreAmount))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_RAID_TRIAL)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            -- Display Alert
            if ChatAnnouncements.SV.Group.GroupRaidScoreAlert then
                local iconAlert = zo_iconFormat(reasonAssets.icon, "75%", "75%")
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_GROUP_TRIAL_SCORE_UPDATED, iconAlert, scoreAmount))
            end

            -- Play Sound if CSA is not enabled
            if not ChatAnnouncements.SV.Group.GroupRaidScoreCSA then
                PlaySound(reasonAssets.soundId)
            end
        end
        return true
    end

    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_STARTED, RaidStartedHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_COMPLETE, RaidCompleteHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_FAILED, RaidFailedHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_NEW_BEST_SCORE, RaidBestScoreHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_REVIVE_COUNTER_UPDATE, RaidReviveCounterHook)
    ZO_PreHook(csaHandlers, EVENT_RAID_TRIAL_SCORE_UPDATE, RaidScoreUpdateHook)

    -- Custom CompleteGroupInvite with enhanced chat announcements
    local function CompleteGroupInvite(characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
        local isLeader = IsUnitGroupLeader("player")
        local groupSize = GetGroupSize()

        if isLeader and groupSize == SMALL_GROUP_SIZE_THRESHOLD then
            ZO_Dialogs_ShowPlatformDialog("LARGE_GROUP_INVITE_WARNING", characterOrDisplayName, { mainTextParams = { SMALL_GROUP_SIZE_THRESHOLD } })
        else
            GroupInviteByName(characterOrDisplayName)

            ZO_Menu_SetLastCommandWasFromMenu(not sentFromChat)
            if isMenu then
                local link
                if ChatAnnouncements.SV.BracketOptionCharacter == 1 then
                    link = ZO_LinkHandler_CreateLinkWithoutBrackets(characterOrDisplayName, nil, CHARACTER_LINK_TYPE, characterOrDisplayName)
                else
                    link = ZO_LinkHandler_CreateLink(characterOrDisplayName, nil, CHARACTER_LINK_TYPE, characterOrDisplayName)
                end
                ChatOutput:PrintAnnouncementOrSystemFallback(zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MENU), link))
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString(LUIE_STRING_CA_GROUP_INVITE_MENU), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)))
                end
            else
                ChatOutput:PrintAnnouncementOrSystemFallback(zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_INVITED), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)))
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, zo_strformat(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_INVITED), ZO_FormatUserFacingCharacterOrDisplayName(characterOrDisplayName)))
                end
            end
        end
    end

    -- Hook TryGroupInviteByName to add custom chat announcements and handle isMenu parameter
    ZO_PreHook("TryGroupInviteByName", function (characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
        if IsPlayerInGroup(characterOrDisplayName) then
            ChatOutput:PrintAnnouncementOrSystemFallback(GetString(SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER))
            if ChatAnnouncements.SV.Group.GroupAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, SI_GROUP_ALERT_INVITE_PLAYER_ALREADY_MEMBER)
            end
            PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            return true -- Prevent original from running
        end

        local isLeader = IsUnitGroupLeader("player")
        local groupSize = GetGroupSize()

        if not isLeader and groupSize > 0 then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE))
            return true -- Prevent original from running
        end

        if ZO_IsConsoleOrGameCoreUI() then
            local displayName = characterOrDisplayName

            local function GroupInviteCallback(success)
                if success then
                    CompleteGroupInvite(displayName, sentFromChat, displayInvitedMessage, isMenu)
                end
            end

            ZO_ConsoleAttemptInteractOrError(GroupInviteCallback, displayName, ZO_PLAYER_CONSOLE_INFO_REQUEST_DONT_BLOCK, ZO_CONSOLE_CAN_COMMUNICATE_ERROR_ALERT, ZO_ID_REQUEST_TYPE_DISPLAY_NAME, displayName)
            return true -- Prevent original from running
        else
            if IsIgnored(characterOrDisplayName) then
                ChatOutput:PrintAnnouncementOrSystemFallback(GetString(LUIE_STRING_IGNORE_ERROR_GROUP))
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, LUIE_STRING_IGNORE_ERROR_GROUP)
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                return true -- Prevent original from running
            end

            CompleteGroupInvite(characterOrDisplayName, sentFromChat, displayInvitedMessage, isMenu)
            return true -- Prevent original from running
        end
    end)
    -- Replace the default DeclineLFGReadyCheckNotification function to display the message that we are not in queue any longer + LFG activity join event.
    local zos_DeclineLFGReadyCheckNotification = DeclineLFGReadyCheckNotification
    DeclineLFGReadyCheckNotification = function (self)
        zos_DeclineLFGReadyCheckNotification()

        local message = (GetString(SI_LFGREADYCHECKCANCELREASON3))
        S.g_showRCUpdates = true
        S.g_weDeclinedTheQueue = true
        zo_callLater(function ()
                         S.g_weDeclinedTheQueue = false
                     end, 1000)

        if ChatAnnouncements.SV.Group.GroupLFGQueueCA then
            ChatOutput:Print(message, true)
        end
        if ChatAnnouncements.SV.Group.GroupLFGQueueAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, message)
        end
    end
end
