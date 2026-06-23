-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements hook shared context (CSA / alerts)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local Internal = ChatAnnouncements.Internal
local ColorizeColors = ChatAnnouncements.Colors

local MAX_INDIVIDUAL_CSAS = 4

local function AnySkillLineUnlockEnabled()
    local skills = ChatAnnouncements.SV.Skills
    return skills.SkillLineUnlockCA or skills.SkillLineUnlockCSA or skills.SkillLineUnlockAlert
end

local function AnySkillAbilityEnabled()
    local skills = ChatAnnouncements.SV.Skills
    return skills.SkillAbilityCA or skills.SkillAbilityCSA or skills.SkillAbilityAlert
end

local function AnyAchievementAnnouncementEnabled()
    local achievement = ChatAnnouncements.SV.Achievement
    return achievement.AchievementCompleteCA or achievement.AchievementCompleteCSA or achievement.AchievementCompleteAlert
end

local function PreHookCsaCallback(ctx, registrationName, callbackManager, hookFn)
    local handler = ctx.FindCsaCallbackHandler(registrationName, callbackManager)
    if handler then
        ZO_PreHook(handler, "callbackFunction", hookFn)
    end
end

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterCsaCallbacks(ctx)
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName

    PreHookCsaCallback(ctx, "SkillLineAdded", COMPANION_SKILLS_DATA_MANAGER, function (skillLineData)
        if not skillLineData:IsAvailable() or not AnySkillLineUnlockEnabled() then
            return
        end
        local skillTypeData = skillLineData:GetSkillTypeData()
        local lineName = skillLineData:GetName()
        local icon = skillTypeData:GetAnnounceIcon()

        if ChatAnnouncements.SV.Skills.SkillLineUnlockCA then
            local formattedIcon = ChatAnnouncements.SV.Skills.SkillLineIcon and zo_strformat("<<1>> ", zo_iconFormatInheritColor(icon, 16, 16)) or ""
            local formattedString = ColorizeColors.SkillLineColorize:Colorize(zo_strformat(LUIE_STRING_CA_SKILL_LINE_ADDED, formattedIcon, lineName))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "SKILL GAIN" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end
        if ChatAnnouncements.SV.Skills.SkillLineUnlockCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.SKILL_LINE_ADDED)
            local formattedIcon = zo_iconFormat(icon, 32, 32)
            if CENTER_SCREEN_ANNOUNCE_TYPE_COMPANION_SKILL_LINE_ADDED then
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COMPANION_SKILL_LINE_ADDED)
            else
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_PARTIAL_GAINED)
            end
            messageParams:SetText(zo_strformat(SI_COMPANION_SKILL_LINE_ADDED, formattedIcon, lineName))
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Skills.SkillLineUnlockAlert then
            local text = zo_strformat(SI_COMPANION_SKILL_LINE_ADDED, "", lineName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
        end
        if not ChatAnnouncements.SV.Skills.SkillLineUnlockCSA then
            PlaySound(SOUNDS.SKILL_LINE_ADDED)
        end
        return true
    end)

    PreHookCsaCallback(ctx, "CompanionSkillUpdateStatusChanged", COMPANION_SKILLS_DATA_MANAGER, function (companionSkillData)
        if not AnySkillAbilityEnabled() then
            return
        end
        if not (companionSkillData:HasUpdatedStatus() and companionSkillData:IsPurchased() and companionSkillData:IsActive()) then
            return
        end
        local progressionData = companionSkillData:GetPointAllocatorProgressionData()
        local primaryText = GetString(SI_COMPANION_ACTIVE_SKILL_UNLOCKED_CSA)
        local secondaryText = progressionData:GetFormattedName()
        local formattedMessage = zo_strformat("<<1>>: <<2>>", primaryText, secondaryText)

        if ChatAnnouncements.SV.Skills.SkillAbilityCA then
            local formattedString = ColorizeColors.SkillLineColorize:Colorize(formattedMessage)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "SKILL" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end
        if ChatAnnouncements.SV.Skills.SkillAbilityCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.COMPANION_ACTIVE_SKILL_UNLOCKED)
            messageParams:SetText(primaryText, secondaryText)
            if CENTER_SCREEN_ANNOUNCE_TYPE_COMPANION_ACTIVE_SKILL_UNLOCKED then
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_COMPANION_ACTIVE_SKILL_UNLOCKED)
            end
            messageParams:SetIconData(progressionData:GetIcon())
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if ChatAnnouncements.SV.Skills.SkillAbilityAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedMessage)
        end
        if not ChatAnnouncements.SV.Skills.SkillAbilityCSA then
            PlaySound(SOUNDS.COMPANION_ACTIVE_SKILL_UNLOCKED)
        end
        return true
    end)

    if PROMOTIONAL_EVENT_MANAGER then
        PreHookCsaCallback(ctx, "RewardsClaimed", PROMOTIONAL_EVENT_MANAGER, function (_campaignData, rewards, hasCapstoneReward)
            if not Internal.AnyDisplayGeneralAnnouncementEnabled() then
                return
            end
            if hasCapstoneReward then
                return true
            end
            if PROMOTIONAL_EVENT_MANAGER:IsShowingCapstoneDialog() or (PROMOTIONAL_EVENTS_CLAIM_CHOICE_DIALOG_GAMEPAD and PROMOTIONAL_EVENTS_CLAIM_CHOICE_DIALOG_GAMEPAD:ShouldShowCapstoneDialogOnClose()) then
                return true
            end

            local general = ChatAnnouncements.SV.DisplayAnnouncements.General
            if #rewards > MAX_INDIVIDUAL_CSAS then
                local primaryText = zo_strformat(SI_PROMOTIONAL_EVENT_REWARDS_CLAIMED_ANNOUNCEMENT, #rewards)
                if general.CA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = primaryText, type = "DISPLAY" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                end
                if general.CSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
                    messageParams:SetText(primaryText)
                    if CENTER_SCREEN_ANNOUNCE_TYPE_PROMOTIONAL_EVENT_REWARD_CLAIMED then
                        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_PROMOTIONAL_EVENT_REWARD_CLAIMED)
                    end
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
                if general.Alert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, primaryText)
                end
                return true
            end

            for _, reward in ipairs(rewards) do
                local claimedReward = reward.rewardableEventData:GetRewardData()
                local _, wasFallbackClaimed = reward.rewardableEventData:IsRewardClaimed()
                if wasFallbackClaimed then
                    claimedReward = claimedReward:GetFallbackRewardData()
                end
                local headerText = GetString(SI_PROMOTIONAL_EVENT_REWARD_CLAIMED_ANNOUNCEMENT)
                local secondaryText = claimedReward:GetQuantity() > 1 and claimedReward:GetFormattedNameWithStack() or claimedReward:GetFormattedName()
                local formattedMessage = zo_strformat("<<1>>: <<2>>", headerText, secondaryText)

                if general.CA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, type = "DISPLAY" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                end
                if general.CSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
                    messageParams:SetText(headerText, secondaryText)
                    messageParams:SetIconData(claimedReward:GetPlatformLootIcon())
                    if CENTER_SCREEN_ANNOUNCE_TYPE_PROMOTIONAL_EVENT_REWARD_CLAIMED then
                        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_PROMOTIONAL_EVENT_REWARD_CLAIMED)
                    end
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
                if general.Alert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedMessage)
                end
            end
            return true
        end)
    end

    if SPECTACLE_EVENTS_MANAGER then
        local function SpectaclePhaseHook(getAnnouncementInfo, spectacleEventId, spectacleEventPhaseId, isInitialUpdate)
            if not Internal.AnyDisplayGeneralAnnouncementEnabled() then
                return
            end
            if isInitialUpdate then
                return true
            end
            local broadcastMessage, soundId = getAnnouncementInfo(spectacleEventId, spectacleEventPhaseId)
            if broadcastMessage == "" then
                return true
            end
            local displayText = string.format("|cffff00%s|r", broadcastMessage)
            local general = ChatAnnouncements.SV.DisplayAnnouncements.General
            if general.CA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = broadcastMessage, type = "DISPLAY" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end
            if general.CSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
                messageParams:SetText(displayText)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST)
                messageParams:SetSound(soundId)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            elseif soundId then
                PlaySound(soundId)
            end
            if general.Alert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, broadcastMessage)
            end
            return true
        end

        PreHookCsaCallback(ctx, "ActiveSpectacleEventPhaseComplete", SPECTACLE_EVENTS_MANAGER, function (spectacleEventId, spectacleEventPhaseId, isInitialUpdate)
            return SpectaclePhaseHook(GetSpectacleEventPhaseCompleteAnnouncementInfo, spectacleEventId, spectacleEventPhaseId, isInitialUpdate)
        end)
        PreHookCsaCallback(ctx, "ActiveSpectacleEventPhaseStarted", SPECTACLE_EVENTS_MANAGER, function (spectacleEventId, spectacleEventPhaseId, isInitialUpdate)
            return SpectaclePhaseHook(GetSpectacleEventPhaseStartedAnnouncementInfo, spectacleEventId, spectacleEventPhaseId, isInitialUpdate)
        end)
    end

    if TITLE_MANAGER then
        PreHookCsaCallback(ctx, "UpdateTitlesData", TITLE_MANAGER, function (newUnlockedTitles)
            if not AnyAchievementAnnouncementEnabled() or not newUnlockedTitles then
                return
            end
            for _, newUnlockedTitle in ipairs(newUnlockedTitles) do
                local formattedMessage = zo_strformat(SI_TITLE_UNLOCKED_ANNOUNCE_TITLE, 1) .. ": " .. newUnlockedTitle.name
                if ChatAnnouncements.SV.Achievement.AchievementCompleteCA then
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, type = "ACHIEVEMENT" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                end
                if ChatAnnouncements.SV.Achievement.AchievementCompleteCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ACHIEVEMENT_AWARDED)
                    messageParams:SetText(zo_strformat(SI_TITLE_UNLOCKED_ANNOUNCE_TITLE, 1), newUnlockedTitle.name)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end
                if ChatAnnouncements.SV.Achievement.AchievementCompleteAlert then
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedMessage)
                end
            end
            return true
        end)
    end
end
