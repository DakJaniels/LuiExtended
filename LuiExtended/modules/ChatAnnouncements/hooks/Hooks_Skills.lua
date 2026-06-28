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
function ChatAnnouncements.Hooks.RegisterSkills(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
    -- EVENT_SKILL_POINTS_CHANGED (CSA Handler)
    local function SkillPointsChangedHook(oldPoints, newPoints, oldPartialPoints, newPartialPoints, changeReason)
        local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
        local numSkillPointsGained = newPoints - oldPoints
        local stringPrefix = ChatAnnouncements.GetModuleMessageFormat("Skills", "SkillPointSkyshard")
        local csaPrefix = stringPrefix ~= "" and stringPrefix or GetString(SI_SKYSHARD_GAINED)
        local hasStringPrefix = stringPrefix ~= ""
        local flagDisplay, sound, finalMessage, finalText

        -- check if the skill point change was due to skyshards
        if oldPartialPoints ~= newPartialPoints or changeReason == SKILL_POINT_CHANGE_REASON_SKYSHARD_INSTANT_UNLOCK then
            flagDisplay = true
            sound = SOUNDS.SKYSHARD_GAINED
            if numSkillPointsGained < 0 then
                return
            end
            local numSkyshardsGained = (newPoints * NUM_PARTIAL_SKILL_POINTS_FOR_FULL + newPartialPoints) - (oldPoints * NUM_PARTIAL_SKILL_POINTS_FOR_FULL + oldPartialPoints)
            local largeText = zo_strformat(csaPrefix, numSkyshardsGained)
            local stringPart1, stringPart2

            -- if only the partial points changed, message out the new count of skyshard pieces
            if newPoints == oldPoints then
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_PARTIAL_GAINED)
                local skyshardGainedPoints = zo_strformat(SI_SKYSHARD_GAINED_POINTS, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
                messageParams:SetText(largeText, skyshardGainedPoints)
                finalText = zo_strformat("<<1>> (<<2>>/<<3>>)", largeText, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
                if hasStringPrefix then
                    if ChatAnnouncements.SV.Skills.SkillPointsPartial then
                        stringPart1 = ColorizeColors.SkillPointColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", B.bracket1[ChatAnnouncements.SV.Skills.SkillPointBracket], largeText, B.bracket2[ChatAnnouncements.SV.Skills.SkillPointBracket]))
                    else
                        stringPart1 = ColorizeColors.SkillPointColorize1:Colorize(zo_strformat("<<1>>!", largeText))
                    end
                else
                    stringPart1 = ""
                end
                if ChatAnnouncements.SV.Skills.SkillPointsPartial then
                    stringPart2 = ColorizeColors.SkillPointColorize2:Colorize(skyshardGainedPoints)
                else
                    stringPart2 = ""
                end
                finalMessage = zo_strformat("<<1>><<2>>", stringPart1, stringPart2)
            else
                local messageText
                -- if there are no leftover skyshard pieces, don't include them in the message
                if newPartialPoints == 0 then
                    messageText = zo_strformat(SI_SKILL_POINT_GAINED, numSkillPointsGained)
                else
                    messageText = zo_strformat(SI_SKILL_POINT_AND_SKYSHARD_PIECES_GAINED, numSkillPointsGained, newPartialPoints, NUM_PARTIAL_SKILL_POINTS_FOR_FULL)
                end
                messageParams:SetText(largeText, messageText)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_GAINED)
                finalText = messageText
                if hasStringPrefix then
                    stringPart1 = ColorizeColors.SkillPointColorize1:Colorize(zo_strformat("<<1>><<2>><<3>> ", B.bracket1[ChatAnnouncements.SV.Skills.SkillPointBracket], largeText, B.bracket2[ChatAnnouncements.SV.Skills.SkillPointBracket]))
                else
                    stringPart1 = ""
                end
                stringPart2 = ColorizeColors.SkillPointColorize2:Colorize(messageText)
                finalMessage = zo_strformat("<<1>><<2>>.", stringPart1, stringPart2)
            end
        elseif numSkillPointsGained > 0 then
            if not ChatAnnouncements.SUPPRESS_SKILL_POINT_CSA_REASONS[changeReason] then
                flagDisplay = true
                sound = SOUNDS.SKILL_POINT_GAINED
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_GAINED)
                local skillPointGained = zo_strformat(SI_SKILL_POINT_GAINED, numSkillPointsGained)
                messageParams:SetText(skillPointGained)
                finalMessage = ColorizeColors.SkillPointColorize2:Colorize(skillPointGained .. ".")
                finalText = skillPointGained .. "."
            end
        end
        if flagDisplay then
            if ChatAnnouncements.SV.Skills.SkillPointCA and finalMessage ~= "" then
                table_insert(ChatAnnouncements.QueuedMessages, { message = finalMessage, type = "SKILL" })
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end
            if ChatAnnouncements.SV.Skills.SkillPointCSA then
                messageParams:SetSound(sound)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Skills.SkillPointAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, finalText)
            end
            if not ChatAnnouncements.SV.Skills.SkillPointCSA then
                PlaySound(sound)
            end
        end
        return true
    end

    -- EVENT_SKILL_LINE_ADDED (CSA callback on SKILLS_DATA_MANAGER)
    local function SkillLineAddedHook(skillLineData)
        if skillLineData:IsAvailable() then
            if not (ChatAnnouncements.SV.Skills.SkillLineUnlockCA or ChatAnnouncements.SV.Skills.SkillLineUnlockCSA or ChatAnnouncements.SV.Skills.SkillLineUnlockAlert) then
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
                -- Note: We set the CSA type to SKILL_POINTS_PARTIAL_GAINED instead of SKILL_LINE_ADDED so this orders itself BEFORE some other events.
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_POINTS_PARTIAL_GAINED)
                messageParams:SetText(zo_strformat(SI_SKILL_LINE_ADDED, formattedIcon, lineName))
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.Skills.SkillLineUnlockAlert then
                local formattedIcon = ""
                local text = zo_strformat(SI_SKILL_LINE_ADDED, formattedIcon, lineName)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
            end
            if not ChatAnnouncements.SV.Skills.SkillLineUnlockCSA then
                PlaySound(SOUNDS.SKILL_LINE_ADDED)
            end
            return true
        end
    end

    -- EVENT_ABILITY_PROGRESSION_RANK_UPDATE (CSA Handler)
    local function AbilityProgressionRankHook(progressionIndex, rank, maxRank, morph)
        ChatAnnouncements.RefreshAbilityProgressionXpCacheForProgression(progressionIndex)

        local _, _, _, atMorph = GetAbilityProgressionXPInfo(progressionIndex)
        local name = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)

        if atMorph then
            if ChatAnnouncements.SV.Skills.SkillAbilityCA then
                local formattedString = ColorizeColors.SkillLineColorize:Colorize(zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name) .. ".")
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "SKILL MORPH" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            if ChatAnnouncements.SV.Skills.SkillAbilityCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ABILITY_MORPH_AVAILABLE)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ABILITY_PROGRESSION_RANK_MORPH)
                messageParams:SetText(zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name))
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Skills.SkillAbilityAlert then
                local text = zo_strformat(SI_MORPH_AVAILABLE_ANNOUNCEMENT, name) .. "."
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
            end

            if not ChatAnnouncements.SV.Skills.SkillAbilityCSA then
                PlaySound(SOUNDS.ABILITY_MORPH_AVAILABLE)
            end
        else
            if ChatAnnouncements.SV.Skills.SkillAbilityCA then
                local formattedString = ColorizeColors.SkillLineColorize:Colorize(zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank) .. ".")
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "SKILL" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            if ChatAnnouncements.SV.Skills.SkillAbilityCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.ABILITY_RANK_UP)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ABILITY_PROGRESSION_RANK_UPDATE)
                messageParams:SetText(zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank))
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.Skills.SkillAbilityAlert then
                local text = zo_strformat(LUIE_STRING_CA_ABILITY_RANK_UP, name, rank) .. "."
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
            end

            if not ChatAnnouncements.SV.Skills.SkillAbilityCSA then
                PlaySound(SOUNDS.ABILITY_RANK_UP)
            end
        end
        return true
    end

    -- EVENT_SKILL_RANK_UPDATE (CSA Handler)
    local function SkillRankUpdateHook(skillType, skillLineIndex, rank)
        -- crafting skill updates get deferred if they're increased while crafting animations are in progress
        -- ZO_Skills_TieSkillInfoHeaderToCraftingSkill handles triggering the deferred center screen announce in that case
        if skillType ~= SKILL_TYPE_RACIAL and (skillType ~= SKILL_TYPE_TRADESKILL or not ZO_CraftingUtils_IsPerformingCraftProcess()) then
            local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillLineIndex)
            if skillLineData and skillLineData:IsAvailable() then
                local lineName = skillLineData:GetName()

                if ChatAnnouncements.SV.Skills.SkillLineCA then
                    local formattedString = ColorizeColors.SkillLineColorize:Colorize(zo_strformat(SI_SKILL_RANK_UP, lineName, rank) .. ".")
                    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "SKILL LINE" }
                    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
                end

                if ChatAnnouncements.SV.Skills.SkillLineCSA then
                    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.SKILL_LINE_LEVELED_UP)
                    messageParams:SetText(zo_strformat(SI_SKILL_RANK_UP, lineName, rank))
                    messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_RANK_UPDATE)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                end

                if ChatAnnouncements.SV.Skills.SkillLineAlert then
                    local formattedText = zo_strformat(SI_SKILL_RANK_UP, lineName, rank) .. "."
                    ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedText)
                end

                if not ChatAnnouncements.SV.Skills.SkillLineCSA then
                    PlaySound(SOUNDS.SKILL_LINE_LEVELED_UP)
                end
            end
        end
        return true
    end

    -- EVENT_SKILL_XP_UPDATE (CSA Handler)
    local function SkillXPUpdateHook(skillType, skillLineIndex, reason, rank, previousXP, currentXP)
        if (skillType == SKILL_TYPE_GUILD and ChatAnnouncements.GUILD_SKILL_SHOW_REASONS[reason]) or reason == PROGRESS_REASON_JUSTICE_SKILL_EVENT then
            if not LUIE.SV.HideXPBar then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_NO_TEXT)
                local barType = PLAYER_PROGRESS_BAR:GetBarType(PPB_CLASS_SKILL, skillType, skillLineIndex)
                local rankStartXP, nextRankStartXP = GetSkillLineRankXPExtents(skillType, skillLineIndex, rank)
                local sound = ChatAnnouncements.GUILD_SKILL_SHOW_SOUNDS[reason]
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SKILL_XP_UPDATE)
                if rankStartXP ~= nil then
                    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(barType, rank, previousXP - rankStartXP, currentXP - rankStartXP)
                    barParams:SetTriggeringEvent(EVENT_SKILL_XP_UPDATE)
                    I.ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
                else
                    assert(false, string_format("No Rank Start XP %d %d %d %d %d %d", skillType, skillLineIndex, reason, rank, previousXP, currentXP))
                end
            end
        end
        return true
    end
    ZO_PreHook(csaHandlers, EVENT_SKILL_POINTS_CHANGED, SkillPointsChangedHook)
    local playerSkillLineHandler = I.FindCsaCallbackHandler(csaCallbackHandlers, "SkillLineAdded", SKILLS_DATA_MANAGER)
    if playerSkillLineHandler then
        ZO_PreHook(playerSkillLineHandler, "callbackFunction", SkillLineAddedHook)
    end
    ZO_PreHook(csaHandlers, EVENT_ABILITY_PROGRESSION_RANK_UPDATE, AbilityProgressionRankHook)
    ZO_PreHook(csaHandlers, EVENT_SKILL_RANK_UPDATE, SkillRankUpdateHook)
    ZO_PreHook(csaHandlers, EVENT_SKILL_XP_UPDATE, SkillXPUpdateHook)
end
