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
function ChatAnnouncements.Hooks.RegisterQuests(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
    local function ResetQuestRewardStatus()
        S.g_itemReceivedIsQuestReward = false
    end

    local function ResetQuestAbandonStatus()
        S.g_itemReceivedIsQuestAbandon = false
    end

    -- EVENT_QUEST_ADDED (CSA Handler)
    local function QuestAddedHook(journalIndex, questName, objectiveName)
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        local questType = GetJournalQuestType(journalIndex)
        local zoneDisplayType = GetJournalQuestZoneDisplayType(journalIndex)
        local questJournalObject = SYSTEMS:GetObject("questJournal")
        local iconTexture = questJournalObject:GetIconTexture(questType, zoneDisplayType)

        -- Add quest to index
        S.g_questIndex[questName] =
        {
            questType = questType,
            zoneDisplayType = zoneDisplayType,
        }

        if ChatAnnouncements.SV.Quests.QuestAcceptCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_ACCEPTED)
            if iconTexture then
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_ACCEPT_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName))
            else
                messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_ACCEPT, questName))
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestAcceptAlert then
            local alertString
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                alertString = zo_strformat(LUIE_STRING_CA_QUEST_ACCEPT_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
            else
                alertString = zo_strformat(SI_NOTIFYTEXT_QUEST_ACCEPT, questName)
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertString)
        end

        -- If we don't have either CSA or Alert on (then we want to play a sound here)
        if not ChatAnnouncements.SV.Quests.QuestAcceptCSA then
            PlaySound(SOUNDS.QUEST_ACCEPTED)
        end

        if ChatAnnouncements.SV.Quests.QuestAcceptCA then
            local questNameFormatted
            local stepText = GetJournalQuestStepInfo(journalIndex, 1)
            local formattedString

            if ChatAnnouncements.SV.Quests.QuestLong then
                questNameFormatted = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ColorizeColors.QuestColorQuestNameColorize:ToHex(), questName, ColorizeColors.QuestColorQuestDescriptionColorize, stepText))
            else
                questNameFormatted = (zo_strformat("|c<<1>><<2>>|r", ColorizeColors.QuestColorQuestNameColorize:ToHex(), questName))
            end
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                formattedString = string_format(GetString(LUIE_STRING_CA_QUEST_ACCEPT) .. zo_iconFormat(iconTexture, 16, 16) .. " " .. questNameFormatted)
            else
                formattedString = string_format("%s%s", GetString(LUIE_STRING_CA_QUEST_ACCEPT), questNameFormatted)
            end

            -- If this message is duplicated by another addon then don't display twice.
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].message == formattedString then
                    return true
                end
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "QUEST" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        return true
    end

    -- EVENT_QUEST_COMPLETE (CSA Handler)
    local function QuestCompleteHook(questName, level, previousExperience, currentExperience, championPoints, questType, zoneDisplayType)
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        local questJournalObject = SYSTEMS:GetObject("questJournal")
        local iconTexture = questJournalObject:GetIconTexture(questType, zoneDisplayType)

        if ChatAnnouncements.SV.Quests.QuestCompleteCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_COMPLETED)
            if iconTexture then
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName))
            else
                messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questName))
            end
            if not LUIE.SV.HideXPBar then
                messageParams:SetBarParams(I.GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_QUEST_COMPLETE))
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_COMPLETED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestCompleteAlert then
            local alertString
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                alertString = zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
            else
                alertString = zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questName)
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertString)
        end

        if ChatAnnouncements.SV.Quests.QuestCompleteCA then
            local questNameFormatted = (zo_strformat("|cFFA500<<1>>|r", questName))
            local formattedString
            if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                formattedString = zo_strformat(LUIE_STRING_CA_QUEST_COMPLETE_WITH_ICON, zo_iconFormat(iconTexture, 16, 16), questNameFormatted)
            else
                formattedString = zo_strformat(SI_NOTIFYTEXT_QUEST_COMPLETE, questNameFormatted)
            end
            -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].message == formattedString then
                    return true
                end
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "QUEST" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        -- If we don't have either CSA or Alert on (then we want to play a sound here)
        if not ChatAnnouncements.SV.Quests.QuestCompleteCSA then
            PlaySound(SOUNDS.QUEST_COMPLETED)
        end

        -- We set this variable to true in order to override the [Looted] message syntax that would be applied to a quest reward normally.
        if ChatAnnouncements.SV.Inventory.Loot then
            S.g_itemReceivedIsQuestReward = true
            zo_callLater(ResetQuestRewardStatus, 500)
        end

        return true
    end

    -- EVENT_OBJECTIVE_COMPLETED (CSA Handler)
    -- Note we don't play a sound if the CSA is disabled here because the Quest complete message will already do this.
    local function ObjectiveCompletedHook(zoneIndex, poiIndex, level, previousExperience, currentExperience, championPoints)
        local name, _, _, finishedDescription = GetPOIInfo(zoneIndex, poiIndex)
        local nameFormatted
        local formattedText

        if ChatAnnouncements.SV.Quests.QuestLocLong and finishedDescription ~= "" then
            nameFormatted = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ColorizeColors.QuestColorLocNameColorize, name, ColorizeColors.QuestColorLocDescriptionColorize, finishedDescription))
        else
            nameFormatted = (zo_strformat("|c<<1>><<2>>|r", ColorizeColors.QuestColorLocNameColorize, name))
        end
        formattedText = zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, nameFormatted)

        if ChatAnnouncements.SV.Quests.QuestCompleteAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, name))
        end

        if ChatAnnouncements.SV.Quests.QuestCompleteCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_COMPLETED)
            if not LUIE.SV.HideXPBar then
                messageParams:SetBarParams(I.GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_OBJECTIVE_COMPLETED))
            end
            messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_COMPLETE, name), finishedDescription)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_OBJECTIVE_COMPLETED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestCompleteCA then
            -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
            for i = 1, #ChatAnnouncements.QueuedMessages do
                if ChatAnnouncements.QueuedMessages[i].message == formattedText then
                    return true
                end
            end
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedText, type = "QUEST" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        return true
    end

    -- EVENT_QUEST_CONDITION_COUNTER_CHANGED (CSA Handler)
    -- Note: Used for quest failure and updates
    local function ConditionCounterHook(journalIndex, questName, conditionText, conditionType, currConditionVal, newConditionVal, conditionMax, isFailCondition, stepOverrideText, isPushed, isComplete, isConditionComplete, isStepHidden, isConditionCompleteChanged)
        if isStepHidden or (isPushed and isComplete) or (currConditionVal >= newConditionVal) then
            return true
        end

        -- Check WritCreater settings first
        if WritCreater and WritCreater:GetSettings().suppressQuestAnnouncements and I.isQuestWritQuest(journalIndex) then
            --             if LUIE.IsDevDebugEnabled() then
            --                 LUIE:Log("Debug", string.format([[Writ Quest Condition Suppressed:
            -- --> Quest: %s
            -- --> Index: %d
            -- --> Condition: %s]],
            --                                                 questName,
            --                                                 journalIndex,
            --                                                 conditionText
            --                 ))
            --             end
            return true
        end

        if not ChatAnnouncements.ShouldAllowQuestConditionCounter(journalIndex, questName, conditionText, newConditionVal, isConditionComplete, conditionMax) then
            return true
        end

        local type             -- This variable represents whether this message is an objective update or failure state message (1 = update, 2 = failure) There are too many conditionals to resolve what we need to print inside them so we do it after setting the formatting.
        local alertMessage     -- Variable for alert message
        local formattedMessage -- Variable for CA Message
        local sound            -- Set correct sound based off context
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)

        if newConditionVal ~= currConditionVal and not isFailCondition then
            sound = isConditionComplete and SOUNDS.QUEST_OBJECTIVE_COMPLETE or SOUNDS.QUEST_OBJECTIVE_INCREMENT
            messageParams:SetSound(sound)
        end

        if isConditionComplete and conditionType == QUEST_CONDITION_TYPE_GIVE_ITEM or conditionType == QUEST_CONDITION_TYPE_TALK_TO then
            -- We set this variable to true in order to override the [Looted] message syntax that would be applied to a quest reward normally.
            if ChatAnnouncements.SV.Inventory.Loot then
                S.g_itemReceivedIsQuestReward = true
                zo_callLater(ResetQuestRewardStatus, 500)
            end
        end

        if isConditionComplete and conditionType == QUEST_CONDITION_TYPE_GIVE_ITEM then
            messageParams:SetText(zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText))
            alertMessage = zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText)
            formattedMessage = zo_strformat(SI_TRACKED_QUEST_STEP_DONE, conditionText)
            type = 1
        elseif stepOverrideText == "" then
            if isFailCondition then
                if conditionMax > 1 then
                    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax))
                    alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax)
                    formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL, conditionText, newConditionVal, conditionMax)
                else
                    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText))
                    alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText)
                    formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, conditionText)
                end
                type = 2
            else
                if conditionMax > 1 and newConditionVal < conditionMax then
                    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax))
                    alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax)
                    formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE, conditionText, newConditionVal, conditionMax)
                else
                    messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText))
                    alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText)
                    formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, conditionText)
                end
                type = 1
            end
        else
            if isFailCondition then
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText))
                alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText)
                formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_FAIL_NO_COUNT, stepOverrideText)
                type = 2
            else
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText))
                alertMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText)
                formattedMessage = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, stepOverrideText)
                type = 1
            end
        end

        -- Override text if its listed in the override table.
        if Quests.QuestObjectiveCompleteOverride[formattedMessage] then
            messageParams:SetText(Quests.QuestObjectiveCompleteOverride[formattedMessage])
            alertMessage = Quests.QuestObjectiveCompleteOverride[formattedMessage]
            formattedMessage = Quests.QuestObjectiveCompleteOverride[formattedMessage]
        end

        if isConditionComplete then
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_CONDITION_COMPLETED)
        else
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
        end

        if type == 1 then
            if ChatAnnouncements.SV.Quests.QuestObjCompleteCA then
                -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
                for i = 1, #ChatAnnouncements.QueuedMessages do
                    if ChatAnnouncements.QueuedMessages[i].message == formattedMessage then
                        return true
                    end
                end
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, type = "MESSAGE" } -- We set the message type to MESSAGE so if we loot a quest item that progresses the quest this comes after.
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end
            if ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Quests.QuestObjCompleteAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertMessage)
            end
            if not ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
                PlaySound(sound)
            end
        end

        if type == 2 then
            if ChatAnnouncements.SV.Quests.QuestFailCA then
                -- This event double fires on quest completion, if an equivalent message is already detected in queue, then abort!
                for i = 1, #ChatAnnouncements.QueuedMessages do
                    if ChatAnnouncements.QueuedMessages[i].message == formattedMessage then
                        return true
                    end
                end
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, type = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end
            if ChatAnnouncements.SV.Quests.QuestFailCSA then
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Quests.QuestFailAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, alertMessage)
            end
            if not ChatAnnouncements.SV.Quests.QuestFailCSA then
                PlaySound(sound)
            end
        end

        return true
    end

    -- EVENT_QUEST_OPTIONAL_STEP_ADVANCED (CSA Handler)
    local function OptionalStepHook(text)
        if text ~= "" then
            local message = zo_strformat("|c<<1>><<2>>|r", ColorizeColors.QuestColorQuestDescriptionColorize, text)
            local formattedString = zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, message)

            if ChatAnnouncements.SV.Quests.QuestObjCompleteCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            if ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.QUEST_OBJECTIVE_COMPLETE)
                messageParams:SetText(zo_strformat(SI_ALERTTEXT_QUEST_CONDITION_UPDATE_NO_COUNT, text))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Quests.QuestObjCompleteAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedString)
            end
            if not ChatAnnouncements.SV.Quests.QuestObjCompleteCSA then
                PlaySound(SOUNDS.QUEST_OBJECTIVE_COMPLETE)
            end
        end
        return true
    end

    -- EVENT_QUEST_REMOVED (Registered through CSA_MiscellaneousHandlers)
    local function OnQuestRemoved(eventId, isCompleted, journalIndex, questName, zoneIndex, poiIndex, questID)
        if isCompleted then
            return
        end

        if ChatAnnouncements.SV.Quests.QuestAbandonCA or ChatAnnouncements.SV.Quests.QuestAbandonCSA or ChatAnnouncements.SV.Quests.QuestAbandonAlert then
            local iconTexture

            if S.g_questIndex[questName] then
                local questJournalObject = SYSTEMS:GetObject("questJournal")
                local questType = S.g_questIndex[questName].questType
                local zoneDisplayType = S.g_questIndex[questName].zoneDisplayType
                iconTexture = questJournalObject:GetIconTexture(questType, zoneDisplayType)
            end

            if ChatAnnouncements.SV.Quests.QuestAbandonCA then
                local questNameFormatted = (zo_strformat("|cFFA500<<1>>|r", questName))
                local formattedString
                if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, 16, 16), questNameFormatted)
                else
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questNameFormatted)
                end
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "MESSAGE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            if ChatAnnouncements.SV.Quests.QuestAbandonCSA then
                local formattedString
                if iconTexture then
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
                else
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questName)
                end
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.QUEST_ABANDONED)
                messageParams:SetText(formattedString)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_ADDED)
                -- CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Quests.QuestAbandonAlert then
                local formattedString
                if iconTexture and ChatAnnouncements.SV.Quests.QuestIcon then
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED_WITH_ICON, zo_iconFormat(iconTexture, "75%", "75%"), questName)
                else
                    formattedString = zo_strformat(LUIE_STRING_CA_QUEST_ABANDONED, questName)
                end
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedString)
            end
        end
        if not ChatAnnouncements.SV.Quests.QuestAbandonCSA then
            PlaySound(SOUNDS.QUEST_ABANDONED)
        end

        -- We set this variable to true in order to override the message syntax that would be applied to a quest reward normally with [Removed] instead.
        if ChatAnnouncements.SV.Inventory.Loot then
            S.g_itemReceivedIsQuestAbandon = true
            zo_callLater(ResetQuestAbandonStatus, 500)
        end

        S.g_questIndex[questName] = nil
    end

    -- EVENT_QUEST_ADVANCED (Registered through CSA_MiscellaneousHandlers)
    -- Note: Quest Advancement displays all the "appropriate" conditions that the player needs to do to advance the current step
    local function OnQuestAdvanced(eventId, questIndex, questName, isPushed, isComplete, mainStepChanged, soundOverride)
        -- Check if WritCreater is enabled & then call a copy of a local function from WritCreater to check if this is a Writ Quest
        if WritCreater and WritCreater:GetSettings().suppressQuestAnnouncements and I.isQuestWritQuest(questIndex) then
            --             if LUIE.IsDevDebugEnabled() then
            --                 LUIE:Log("Debug", string.format([[Writ Quest Condition Suppressed:
            -- --> Quest: %s
            -- --> Index: %d
            -- --> Condition: %s]],
            --                                                 questName,
            --                                                 questIndex,
            --                                                 isComplete and "Complete" or "Not Complete"
            --                 ))
            --             end
            return true
        end

        if not mainStepChanged then
            return
        end

        local sound = SOUNDS.QUEST_OBJECTIVE_STARTED

        for stepIndex = QUEST_MAIN_STEP_INDEX, GetJournalQuestNumSteps(questIndex) do
            local _, visibility, stepType, stepOverrideText, conditionCount = GetJournalQuestStepInfo(questIndex, stepIndex)

            -- Override text if its listed in the override table.
            if Quests.QuestAdvancedOverride[stepOverrideText] then
                stepOverrideText = Quests.QuestAdvancedOverride[stepOverrideText]
            end

            if visibility == nil or visibility == QUEST_STEP_VISIBILITY_OPTIONAL then
                if stepOverrideText ~= "" then
                    if ChatAnnouncements.SV.Quests.QuestObjUpdateCA then
                        -- This event sometimes results in duplicate messages - if an equivalent message is already detected in queue, then abort!
                        for i = 1, #ChatAnnouncements.QueuedMessages do
                            if ChatAnnouncements.QueuedMessages[i].message == stepOverrideText then
                                -- Set the old message to blank so it gets skipped by the printer
                                ChatAnnouncements.QueuedMessages[i].message = ""
                            end
                        end
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = stepOverrideText, type = "MESSAGE" }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                    end
                    if ChatAnnouncements.SV.Quests.QuestObjUpdateCSA then
                        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, sound)
                        messageParams:SetText(stepOverrideText)
                        messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
                        CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                        sound = nil -- no longer needed, we played it once
                    end
                    if ChatAnnouncements.SV.Quests.QuestObjUpdateAlert then
                        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, stepOverrideText)
                    end
                else
                    for conditionIndex = 1, conditionCount do
                        local conditionText, curCount, maxCount, isFailCondition, isConditionComplete, _, isVisible = GetJournalQuestConditionInfo(questIndex, stepIndex, conditionIndex, false)

                        if not (isFailCondition or isConditionComplete) and isVisible then
                            if ChatAnnouncements.SV.Quests.QuestObjUpdateCA then
                                -- This event sometimes results in duplicate messages - if an equivalent message is already detected in queue, then abort!
                                for i = 1, #ChatAnnouncements.QueuedMessages do
                                    if ChatAnnouncements.QueuedMessages[i].message == conditionText then
                                        -- Set the old message to blank so it gets skipped by the printer
                                        ChatAnnouncements.QueuedMessages[i].message = ""
                                    end
                                end
                                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = conditionText, type = "MESSAGE" }
                                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                            end
                            if ChatAnnouncements.SV.Quests.QuestObjUpdateCSA then
                                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, sound)
                                messageParams:SetText(conditionText)
                                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_QUEST_PROGRESSION_CHANGED)
                                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                                sound = nil -- no longer needed, we played it once
                            end
                            if ChatAnnouncements.SV.Quests.QuestObjUpdateAlert then
                                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, conditionText)
                            end
                        end
                    end
                end
                -- We send soundOverride = true from OnQuestAdded in order to stop the sound from spamming if CSA isn't on and a quest is accepted.
                if not ChatAnnouncements.SV.Quests.QuestObjUpdateCSA and not soundOverride then
                    PlaySound(SOUNDS.QUEST_OBJECTIVE_STARTED)
                end
            end
        end
    end

    -- EVENT_QUEST_ADDED (Registered through CSA_MiscellaneousHandlers)
    local function OnQuestAdded(eventId, questIndex)
        -- Handle WritCrafter integration
        if WritCreater then
            -- Auto-abandon quests with disallowed materials
            local rejectedMat = I.rejectQuest(questIndex)
            if rejectedMat then
                local questName = GetJournalQuestName(questIndex)
                ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CA_WRIT_CRAFTER_QUEST_ABANDONED), questName, rejectedMat), true)
                zo_callLater(function ()
                                 AbandonQuest(questIndex)
                             end, 500)
                return
            end
            -- Suppress announcements for writ quests if configured
            if WritCreater:GetSettings().suppressQuestAnnouncements and I.isQuestWritQuest(questIndex) then
                return true
            end
        end

        OnQuestAdvanced(EVENT_QUEST_ADVANCED, questIndex, nil, nil, nil, true, true)
    end
    ZO_PreHook(csaHandlers, EVENT_QUEST_ADDED, QuestAddedHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_COMPLETE, QuestCompleteHook)
    ZO_PreHook(csaHandlers, EVENT_OBJECTIVE_COMPLETED, ObjectiveCompletedHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_CONDITION_COUNTER_CHANGED, ConditionCounterHook)
    ZO_PreHook(csaHandlers, EVENT_QUEST_OPTIONAL_STEP_ADVANCED, OptionalStepHook)

    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_REMOVED)
    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADVANCED)
    eventManager:UnregisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADDED)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_REMOVED, OnQuestRemoved)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADVANCED, OnQuestAdvanced)
    eventManager:RegisterForEvent("CSA_MiscellaneousHandlers", EVENT_QUEST_ADDED, OnQuestAdded)
end
