--- @diagnostic disable: unused-function, duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local ChatOutput = LUIE.ChatOutput
-- -----------------------------------------------------------------------------
-- ESO API Locals.
-- -----------------------------------------------------------------------------

local GetString = GetString
local zo_strformat = zo_strformat

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

-- HOOK PLAYER_TO_PLAYER Group Notifications to edit Ignore alert
function ChatAnnouncements.PlayerToPlayerHook()
    local KEYBOARD_INTERACT_ICONS =
    {
        [SI_PLAYER_TO_PLAYER_WHISPER] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_whisper_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_whisper_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_whisper_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_whisper_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_ADD_GROUP] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_inviteGroup_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_inviteGroup_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_inviteGroup_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_inviteGroup_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_REMOVE_GROUP] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_removeFromGroup_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_removeFromGroup_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_removeFromGroup_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_removeFromGroup_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_ADD_FRIEND] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_addFriend_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_addFriend_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_addFriend_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_addFriend_disabled.dds",
        },
        [SI_CHAT_PLAYER_CONTEXT_REPORT] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_reportPlayer_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_reportPlayer_over.dds",
        },
        [SI_PLAYER_TO_PLAYER_INVITE_DUEL] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_duel_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_duel_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_duel_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_duel_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_tribute_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_tribute_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_tribute_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_tribute_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_INVITE_TRADE] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_trade_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_trade_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_trade_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_trade_disabled.dds",
        },
        [SI_RADIAL_MENU_CANCEL_BUTTON] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_cancel_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_cancel_over.dds",
        },
        [SI_PLAYER_TO_PLAYER_RIDE_MOUNT] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_joinMount_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_joinMount_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_joinMount_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_joinMount_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_DISMOUNT] =
        {
            enabledNormal = "EsoUI/Art/HUD/radialIcon_dismount_up.dds",
            enabledSelected = "EsoUI/Art/HUD/radialIcon_dismount_over.dds",
            disabledNormal = "EsoUI/Art/HUD/radialIcon_dismount_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/radialIcon_dismount_disabled.dds",
        },
    }

    local GAMEPAD_INTERACT_ICONS =
    {
        [SI_PLAYER_TO_PLAYER_WHISPER] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_whisper_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_whisper_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_whisper_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_whisper_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_ADD_GROUP] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_inviteGroup_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_inviteGroup_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_inviteGroup_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_inviteGroup_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_REMOVE_GROUP] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_removeFromGroup_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_removeFromGroup_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_removeFromGroup_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_removeFromGroup_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_ADD_FRIEND] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_addFriend_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_addFriend_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_addFriend_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_addFriend_disabled.dds",
        },
        [SI_CHAT_PLAYER_CONTEXT_REPORT] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_reportPlayer_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_reportPlayer_down.dds",
        },
        [SI_PLAYER_TO_PLAYER_INVITE_DUEL] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_duel_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_tribute_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_tribute_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_tribute_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_tribute_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_INVITE_TRADE] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_trade_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_trade_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_trade_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_trade_disabled.dds",
        },
        [SI_RADIAL_MENU_CANCEL_BUTTON] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_cancel_down.dds",
        },
        [SI_PLAYER_TO_PLAYER_RIDE_MOUNT] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_joinMount_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_joinMount_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_joinMount_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_joinMount_disabled.dds",
        },
        [SI_PLAYER_TO_PLAYER_DISMOUNT] =
        {
            enabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_dismount_down.dds",
            enabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_dismount_down.dds",
            disabledNormal = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_dismount_disabled.dds",
            disabledSelected = "EsoUI/Art/HUD/Gamepad/gp_radialIcon_dismount_disabled.dds",
        },
    }

    local ALERT_IGNORED_STRING = ZO_IsConsoleOrGameCoreUI() and SI_PLAYER_TO_PLAYER_BLOCKED or SI_PLAYER_TO_PLAYER_IGNORED

    -- Custom alert helpers
    local function AlertIgnored(customStringId)
        local stringId = customStringId or ALERT_IGNORED_STRING
        ChatOutput:Print(GetString(stringId), true)
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, stringId)
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end

    local function AlertRestrictedCommunication()
        ChatOutput:Print(GetString(SI_PLAYER_TO_PLAYER_RESTRICTED_COMMUNICATION), true)
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, SI_PLAYER_TO_PLAYER_RESTRICTED_COMMUNICATION)
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end

    local function AlertGroupDisabled()
        ChatOutput:Print(GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE), true)
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, GetString("LUIE_STRING_CA_GROUPINVITERESPONSE", GROUP_INVITE_RESPONSE_ONLY_LEADER_CAN_INVITE))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end

    local function AlertGroupKickDisabled()
        ChatOutput:Print(GetString(LUIE_STRING_CA_GROUP_LEADERKICK_ERROR), true)
        if ChatAnnouncements.SV.Group.GroupAlert then
            ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, GetString(LUIE_STRING_CA_GROUP_LEADERKICK_ERROR))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end

    local function AlreadyFriendsWarning()
        ChatOutput:Print(GetString("SI_SOCIALACTIONRESULT", SOCIAL_RESULT_ACCOUNT_ALREADY_FRIENDS), true)
        if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
            ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, GetString("SI_SOCIALACTIONRESULT", SOCIAL_RESULT_ACCOUNT_ALREADY_FRIENDS))
        end
        PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
    end


    local originalShowPlayerInteractMenu = ZO_PlayerToPlayer.ShowPlayerInteractMenu
    local originalAddMenuEntry = ZO_PlayerToPlayer.AddMenuEntry
    function ZO_PlayerToPlayer:AddMenuEntry(text, icons, enabled, selectedFunction, errorReason)
        if ZO_IsConsoleOrGameCoreUI() then
            return originalAddMenuEntry(self, text, icons, enabled, selectedFunction, errorReason)
        end
        local normalIcon = enabled and icons.enabledNormal or icons.disabledNormal
        local selectedIcon = enabled and icons.enabledSelected or icons.disabledSelected
        self:GetRadialMenu():AddEntry(text, normalIcon, selectedIcon, selectedFunction, errorReason)
    end

    function ZO_PlayerToPlayer:ShowPlayerInteractMenu(isIgnored)
        if ZO_IsConsoleOrGameCoreUI() then
            return originalShowPlayerInteractMenu(self, isIgnored)
        end

        local currentTargetCharacterName = self.currentTargetCharacterName
        local currentTargetCharacterNameRaw = self.currentTargetCharacterNameRaw
        local currentTargetDisplayName = self.currentTargetDisplayName
        local primaryName = ZO_GetPrimaryPlayerName(currentTargetDisplayName, currentTargetCharacterName)
        local primaryNameInternal = ZO_GetPrimaryPlayerName(currentTargetDisplayName, currentTargetCharacterName, USE_INTERNAL_FORMAT)
        local platformIcons = IsInGamepadPreferredMode() and GAMEPAD_INTERACT_ICONS or KEYBOARD_INTERACT_ICONS
        local ENABLED = true
        local DISABLED = false
        local ENABLED_IF_NOT_IGNORED = not isIgnored
        local isInGroup = IsPlayerInGroup(currentTargetCharacterNameRaw)
        local disabledOption = ENABLED_IF_NOT_IGNORED and AlertRestrictedCommunication or AlertIgnored
        local isRestrictedCommunicationPermitted = CanCommunicateWith(currentTargetCharacterNameRaw)

        self:GetRadialMenu():Clear()

        -- Whisper
        if IsChatSystemAvailableForCurrentPlatform() then
            local nameToUse = primaryNameInternal
            local function WhisperOption()
                StartChatInput(nil, CHAT_CHANNEL_WHISPER, nameToUse)
            end
            local isEnabled = ENABLED_IF_NOT_IGNORED and isRestrictedCommunicationPermitted
            local whisperFunction = isEnabled and WhisperOption or disabledOption
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_WHISPER), platformIcons[SI_PLAYER_TO_PLAYER_WHISPER], isEnabled, whisperFunction)
        end

        -- Group
        local isGroupModificationAvailable = IsGroupModificationAvailable()
        local groupModicationRequiresVoting = DoesGroupModificationRequireVote()
        local isSoloOrLeader = IsUnitSoloOrGroupLeader("player")

        if isInGroup then
            local groupKickEnabled = isGroupModificationAvailable and isSoloOrLeader and not groupModicationRequiresVoting
            local groupKickFunction
            if groupKickEnabled then
                groupKickFunction = function () GroupKickByName(currentTargetCharacterNameRaw) end
            else
                groupKickFunction = AlertGroupKickDisabled
            end
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_REMOVE_GROUP), platformIcons[SI_PLAYER_TO_PLAYER_REMOVE_GROUP], groupKickEnabled, groupKickFunction)
        else
            local groupInviteEnabled = ENABLED_IF_NOT_IGNORED and isGroupModificationAvailable and isSoloOrLeader
            local groupInviteFunction
            if groupInviteEnabled then
                groupInviteFunction = function ()
                    local NOT_SENT_FROM_CHAT = false
                    local DISPLAY_INVITED_MESSAGE = true
                    TryGroupInviteByName(primaryNameInternal, NOT_SENT_FROM_CHAT, DISPLAY_INVITED_MESSAGE)
                end
            else
                if ENABLED_IF_NOT_IGNORED then
                    groupInviteFunction = AlertGroupDisabled
                else
                    groupInviteFunction = AlertIgnored
                end
            end
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_ADD_GROUP), platformIcons[SI_PLAYER_TO_PLAYER_ADD_GROUP], groupInviteEnabled, groupInviteFunction)
        end

        -- Friend
        if IsFriend(currentTargetCharacterNameRaw) then
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_ADD_FRIEND), platformIcons[SI_PLAYER_TO_PLAYER_ADD_FRIEND], DISABLED, AlreadyFriendsWarning)
        else
            local function RequestFriendOption()
                RequestFriend(currentTargetDisplayName)

                local displayNameLink = ChatAnnouncements.CreateDisplayNameLink(currentTargetDisplayName, currentTargetDisplayName)

                local formattedMessage = zo_strformat(LUIE_STRING_SLASHCMDS_FRIEND_INVITE_MSG_LINK, displayNameLink)

                if ChatAnnouncements.SV.Social.FriendIgnoreAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, formattedMessage)
                end
            end
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_ADD_FRIEND), platformIcons[SI_PLAYER_TO_PLAYER_ADD_FRIEND], ENABLED_IF_NOT_IGNORED, ENABLED_IF_NOT_IGNORED and RequestFriendOption or AlertIgnored)
        end

        -- Passenger Mount
        if isInGroup then
            local mountedState, isRidingGroupMount = GetTargetMountedStateInfo(currentTargetCharacterNameRaw)
            local isPassengerForTarget = IsGroupMountPassengerForTarget(currentTargetCharacterNameRaw)
            local groupMountEnabled = (mountedState == MOUNTED_STATE_MOUNT_RIDER and isRidingGroupMount and (not IsMounted() or isPassengerForTarget))
            local function MountOption()
                UseMountAsPassenger(currentTargetCharacterNameRaw)
            end
            local optionToShow = isPassengerForTarget and SI_PLAYER_TO_PLAYER_DISMOUNT or SI_PLAYER_TO_PLAYER_RIDE_MOUNT
            self:AddMenuEntry(GetString(optionToShow), platformIcons[optionToShow], groupMountEnabled, MountOption)
        end

        -- Report
        local function ReportCallback()
            local nameToReport = IsInGamepadPreferredMode() and currentTargetDisplayName or primaryName
            ZO_HELP_GENERIC_TICKET_SUBMISSION_MANAGER:OpenReportPlayerTicketScene(nameToReport)
        end
        self:AddMenuEntry(GetString(SI_CHAT_PLAYER_CONTEXT_REPORT), platformIcons[SI_CHAT_PLAYER_CONTEXT_REPORT], ENABLED, ReportCallback)

        -- Duel
        local duelState, partnerCharacterName, partnerDisplayName = GetDuelInfo()
        if duelState ~= DUEL_STATE_IDLE then
            local function AlreadyDuelingWarning(state, characterName, displayName)
                return function ()
                    local userFacingPartnerName = ZO_GetPrimaryPlayerNameWithSecondary(displayName, characterName)
                    local statusString = GetString("SI_DUELSTATE", state)
                    statusString = zo_strformat(statusString, userFacingPartnerName)
                    ChatOutput:Print(statusString, true)
                    if ChatAnnouncements.SV.Group.GroupAlert then
                        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, statusString)
                    end
                    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                end
            end
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_DUEL), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_DUEL], DISABLED, AlreadyDuelingWarning(duelState, partnerCharacterName, partnerDisplayName))
        else
            local function DuelInviteOption()
                ChallengeTargetToDuel(currentTargetCharacterName)
            end
            local isEnabled = ENABLED_IF_NOT_IGNORED and isRestrictedCommunicationPermitted
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_DUEL), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_DUEL], isEnabled, isEnabled and DuelInviteOption or disabledOption)
        end

        -- Play Tribute
        local tributeInviteState, tributePartnerCharacterName, tributePartnerDisplayName = GetTributeInviteInfo()
        if tributeInviteState ~= TRIBUTE_INVITE_STATE_NONE then
            local function TributeInviteFailWarning(inviteState, characterName, displayName)
                return function ()
                    local userFacingPartnerName = ZO_GetPrimaryPlayerNameWithSecondary(displayName, characterName)
                    local statusString = GetString("SI_TRIBUTEINVITESTATE", inviteState)
                    statusString = zo_strformat(statusString, userFacingPartnerName)
                    ChatOutput:Print(statusString, true)
                    if ChatAnnouncements.SV.Group.GroupAlert then
                        ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, statusString)
                    end
                    PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
                end
            end
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE], DISABLED, TributeInviteFailWarning(tributeInviteState, tributePartnerCharacterName, tributePartnerDisplayName))
        else
            local function TributeInviteOption()
                ChallengeTargetToTribute(currentTargetCharacterName)
            end
            local function TributeLockedAlert()
                ChatOutput:Print(GetString(SI_PLAYER_TO_PLAYER_TRIBUTE_LOCKED), true)
                if ChatAnnouncements.SV.Group.GroupAlert then
                    ZO_AlertNoSuppression(UI_ALERT_CATEGORY_ALERT, nil, SI_PLAYER_TO_PLAYER_TRIBUTE_LOCKED)
                end
                PlaySound(SOUNDS.GENERAL_ALERT_ERROR)
            end
            local isEnabled = ENABLED_IF_NOT_IGNORED and not ZO_IsTributeLocked() and isRestrictedCommunicationPermitted
            local entryFunction
            if isEnabled then
                entryFunction = TributeInviteOption
            elseif ZO_IsTributeLocked() then
                entryFunction = TributeLockedAlert
            else
                entryFunction = disabledOption
            end
            self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_TRIBUTE], isEnabled, entryFunction)
        end

        -- Trade
        local function TradeInviteOption()
            TRADE_WINDOW:InitiateTrade(primaryNameInternal)
        end
        local isEnabled = ENABLED_IF_NOT_IGNORED and isRestrictedCommunicationPermitted
        local tradeInviteFunction = isEnabled and TradeInviteOption or disabledOption
        self:AddMenuEntry(GetString(SI_PLAYER_TO_PLAYER_INVITE_TRADE), platformIcons[SI_PLAYER_TO_PLAYER_INVITE_TRADE], isEnabled, tradeInviteFunction)

        -- Cancel
        self:AddMenuEntry(GetString(SI_RADIAL_MENU_CANCEL_BUTTON), platformIcons[SI_RADIAL_MENU_CANCEL_BUTTON], ENABLED)

        self:GetRadialMenu():Show()
        self.showingPlayerInteractMenu = true
        self.isLastRadialMenuGamepad = IsInGamepadPreferredMode()
        if self.isLastRadialMenuGamepad then
            local NARRATE_HEADER = true
            SCREEN_NARRATION_MANAGER:QueueCustomEntry("PlayerToPlayerWheel", NARRATE_HEADER)
        end
    end
end
