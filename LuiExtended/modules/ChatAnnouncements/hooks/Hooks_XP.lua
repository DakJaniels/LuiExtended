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

-- CenterScreenAnnounceHandlers.lua file locals (not game globals)
local CHAMPION_UNLOCKED_LIFESPAN_MS = 12000
local EMERGENCY_BACKGROUND = "EsoUI/Art/Guild/guildRanks_iconFrame_selected.dds"

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterXP(ctx)
    local alertHandlers = ctx.alertHandlers
    local csaHandlers = ctx.csaHandlers
    local csaCallbackHandlers = ctx.csaCallbackHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName
    local FindCsaCallbackHandler = ctx.FindCsaCallbackHandler
    -- EVENT_DISCOVERY_EXPERIENCE (Alert Handler)
    local function DiscoveryExperienceAlert(subzoneName, level, previousExperience, currentExperience, rank, previousPoints, currentPoints)
        -- Note: We let the CSA Handler take care of this.
        return true
    end
    -- EVENT_DISCOVERY_EXPERIENCE (CSA Handler)
    local function DiscoveryExperienceHook(subzoneName, level, previousExperience, currentExperience, championPoints)
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        if ChatAnnouncements.SV.Quests.QuestLocDiscoveryCA then
            local nameFormatted = (zo_strformat("|c<<1>><<2>>|r", ColorizeColors.QuestColorLocNameColorize, subzoneName))
            local formattedString = zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, nameFormatted)
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "QUEST" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        if ChatAnnouncements.SV.Quests.QuestLocDiscoveryCSA and not INTERACT_WINDOW:IsShowingInteraction() then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_DISCOVERED)
            if currentExperience > previousExperience then
                if not LUIE.SV.HideXPBar then
                    messageParams:SetBarParams(I.GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, EVENT_DISCOVERY_EXPERIENCE))
                end
            end
            messageParams:SetText(zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, subzoneName))
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISCOVERY_EXPERIENCE)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestLocDiscoveryAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(LUIE_STRING_CA_QUEST_DISCOVER, subzoneName))
        end

        if not ChatAnnouncements.SV.Quests.QuestLocDiscoveryCSA then
            PlaySound(SOUNDS.OBJECTIVE_DISCOVERED)
        end
        return true
    end

    -- EVENT_POI_DISCOVERED (CSA Handler)
    local function PoiDiscoveredHook(zoneIndex, poiIndex)
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        local name, _, startDescription = GetPOIInfo(zoneIndex, poiIndex)

        if ChatAnnouncements.SV.Quests.QuestLocObjectiveCA then
            local formattedString = (zo_strformat("|c<<1>><<2>>:|r |c<<3>><<4>>|r", ColorizeColors.QuestColorLocNameColorize, name, ColorizeColors.QuestColorLocDescriptionColorize, startDescription))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "QUEST_POI" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        if ChatAnnouncements.SV.Quests.QuestLocObjectiveCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_ACCEPTED)
            messageParams:SetText(zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_DISCOVERED, name), startDescription)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_POI_DISCOVERED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.Quests.QuestLocObjectiveAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, zo_strformat(SI_NOTIFYTEXT_OBJECTIVE_DISCOVERED, name), startDescription)
        end
        return true
    end

    local XP_GAIN_SHOW_REASONS =
    {
        [PROGRESS_REASON_PVP_EMPEROR] = true,
        [PROGRESS_REASON_DUNGEON_CHALLENGE] = true,
        [PROGRESS_REASON_OVERLAND_BOSS_KILL] = true,
        [PROGRESS_REASON_SCRIPTED_EVENT] = true,
        [PROGRESS_REASON_LOCK_PICK] = true,
        [PROGRESS_REASON_LFG_REWARD] = true,
    }

    local XP_GAIN_SHOW_SOUNDS =
    {
        [PROGRESS_REASON_OVERLAND_BOSS_KILL] = SOUNDS.OVERLAND_BOSS_KILL,
        [PROGRESS_REASON_LOCK_PICK] = SOUNDS.LOCKPICKING_SUCCESS_CELEBRATION,
    }

    -- EVENT_EXPERIENCE_GAIN (CSA Handler)
    -- Note: This function is prehooked in order to allow the XP bar popup to be hidden. In addition we shift the sound over
    local function ExperienceGainHook(reason, level, previousExperience, currentExperience, championPoints)
        local sound = XP_GAIN_SHOW_SOUNDS[reason]

        if XP_GAIN_SHOW_REASONS[reason] and not LUIE.SV.HideXPBar then
            local barParams = I.GetRelevantBarParams(level, previousExperience, currentExperience, championPoints)
            if barParams then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_NO_TEXT)
                barParams:SetSound(sound)
                I.ValidateProgressBarParams(barParams)
                messageParams:SetBarParams(barParams)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_EXPERIENCE_GAIN)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
        end

        -- We want to play a sound still even if the bar popup is hidden, but the delay needs to remain intact so we add a blank CSA with sound.
        if XP_GAIN_SHOW_REASONS[reason] and LUIE.SV.HideXPBar and sound ~= nil then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
            messageParams:SetSound(sound)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_EXPERIENCE_GAIN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        -- Level up notification
        local levelSize = GetNumExperiencePointsInLevel(level)
        if levelSize ~= nil and currentExperience >= levelSize then
            eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
            ChatAnnouncements.PrintBufferedXP()

            local CurrentLevel = level + 1
            if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
                local icon
                if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                    icon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and ZO_XP_BAR_GRADIENT_COLORS[2]:Colorize(" " .. zo_iconFormatInheritColor(LUIE_MEDIA_UNITFRAMES_UNITFRAMES_LEVEL_NORMAL_DDS, 16, 16)) or ""
                else
                    icon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and (" " .. zo_iconFormat(LUIE_MEDIA_UNITFRAMES_UNITFRAMES_LEVEL_NORMAL_DDS, 16, 16)) or ""
                end

                local CurrentLevelFormatted = ""
                if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                    CurrentLevelFormatted = ZO_XP_BAR_GRADIENT_COLORS[2]:Colorize(GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL) .. " " .. CurrentLevel)
                else
                    CurrentLevelFormatted = ColorizeColors.ExperienceLevelUpColorize:Colorize(GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL) .. " " .. CurrentLevel)
                end

                local formattedString
                if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                    formattedString = zo_strformat("<<1>><<2>> <<3>><<4>>", ColorizeColors.ExperienceLevelUpColorize:Colorize(GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP)), icon, CurrentLevelFormatted, ColorizeColors.ExperienceLevelUpColorize:Colorize("!"))
                else
                    formattedString = zo_strformat("<<1>><<2>> <<3>><<4>>", ColorizeColors.ExperienceLevelUpColorize:Colorize(GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP)), icon, CurrentLevelFormatted, ColorizeColors.ExperienceLevelUpColorize:Colorize("!"))
                end
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "EXPERIENCE LEVEL" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                local iconCSA = (" " .. zo_iconFormat(LUIE_MEDIA_UNITFRAMES_UNITFRAMES_LEVEL_UP_DDS, "100%", "100%")) or ""
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)
                if ChatAnnouncements.SV.XP.ExperienceLevelUpCSAExpand then
                    local levelUpExpanded = zo_strformat("<<1>><<2>> <<3>> <<4>>", GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP), iconCSA, GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL), CurrentLevel)
                    messageParams:SetText(zo_strformat(SI_LEVEL_UP_NOTIFICATION), levelUpExpanded)
                else
                    messageParams:SetText(GetString(SI_LEVEL_UP_NOTIFICATION))
                end
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LEVEL_GAIN)
                if not LUIE.SV.HideXPBar then
                    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_XP, level + 1, currentExperience - levelSize, currentExperience - levelSize)
                    barParams:SetShowNoGain(true)
                    barParams:SetTriggeringEvent(EVENT_EXPERIENCE_GAIN)
                    I.ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                end
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
                local iconAlert = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and (" " .. zo_iconFormat(LUIE_MEDIA_UNITFRAMES_UNITFRAMES_LEVEL_UP_DDS, "75%", "75%")) or ""
                local text = zo_strformat("<<1>><<2>> <<3>> <<4>>!", GetString(LUIE_STRING_CA_LVL_ANNOUNCE_XP), iconAlert, GetString(SI_GAMEPAD_QUEST_JOURNAL_QUEST_LEVEL), CurrentLevel)
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
            end

            -- Play Sound even if CSA is disabled
            if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                PlaySound(SOUNDS.LEVEL_UP)
            end
        end

        return true
    end

    -- Called by EnlightenGainHook()
    local function GetEnlightenedGainedAnnouncement(triggeringEvent)
        local formattedString = zo_strformat("<<1>>! <<2>>", GetString(SI_ENLIGHTENED_STATE_GAINED_HEADER), GetString(SI_ENLIGHTENED_STATE_GAINED_DESCRIPTION))
        if ChatAnnouncements.SV.XP.ExperienceEnlightenedCA then
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "EXPERIENCE" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        if ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ENLIGHTENED_STATE_GAINED)
            messageParams:SetText(zo_strformat(SI_ENLIGHTENED_STATE_GAINED_HEADER), zo_strformat(SI_ENLIGHTENED_STATE_GAINED_DESCRIPTION))
            if not LUIE.SV.HideXPBar then
                local barParams = I.GetCurrentChampionPointsBarParams(triggeringEvent)
                I.ValidateProgressBarParams(barParams)
                messageParams:SetBarParams(barParams)
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENLIGHTENMENT_GAINED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.XP.ExperienceEnlightenedAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedString)
        end

        if not ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
            PlaySound(SOUNDS.ENLIGHTENED_STATE_GAINED)
        end

        return true
    end

    -- EVENT_ENLIGHTENED_STATE_GAINED (CSA Handler)
    local function EnlightenGainHook()
        if IsEnlightenedAvailableForCharacter() then
            return GetEnlightenedGainedAnnouncement(EVENT_ENLIGHTENED_STATE_GAINED)
        end
    end

    -- EVENT_ENLIGHTENED_STATE_LOST (CSA Handler)
    local function EnlightenLostHook()
        if IsEnlightenedAvailableForCharacter() then
            local formattedString = zo_strformat("<<1>>!", GetString(SI_ENLIGHTENED_STATE_LOST_HEADER))

            if ChatAnnouncements.SV.XP.ExperienceEnlightenedCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "EXPERIENCE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end

            if ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
                local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.ENLIGHTENED_STATE_LOST)
                if not LUIE.SV.HideXPBar then
                    local barParams = I.GetCurrentChampionPointsBarParams(EVENT_ENLIGHTENED_STATE_LOST)
                    I.ValidateProgressBarParams(barParams)
                    messageParams:SetBarParams(barParams)
                end
                messageParams:SetText(zo_strformat(SI_ENLIGHTENED_STATE_LOST_HEADER))
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_ENLIGHTENMENT_LOST)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end

            if ChatAnnouncements.SV.XP.ExperienceEnlightenedAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedString)
            end

            if not ChatAnnouncements.SV.XP.ExperienceEnlightenedCSA then
                PlaySound(SOUNDS.ENLIGHTENED_STATE_LOST)
            end
        end

        return true
    end

    local firstActivation = true
    -- EVENT_PLAYER_ACTIVATED (CSA Handler)
    local function PlayerActivatedHook()
        if firstActivation then
            firstActivation = false

            if IsEnlightenedAvailableForCharacter() and GetEnlightenedPool() > 0 then
                return GetEnlightenedGainedAnnouncement(EVENT_PLAYER_ACTIVATED)
            end
        end
        return true
    end
    -- EVENT_CHAMPION_LEVEL_ACHIEVED (CSA Handler)
    local function ChampionLevelAchievedHook(wasChampionSystemUnlocked)
        local icon = ZO_GetChampionPointsIcon()

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
            local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat("<<1>> ", zo_iconFormatInheritColor(icon, 16, 16)) or ""
            local formattedString = ColorizeColors.ExperienceLevelUpColorize:Colorize(zo_strformat(GetString(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED), formattedIcon))
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "EXPERIENCE LEVEL" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINT_GAINED)
            local formattedIcon = zo_strformat("<<1>> ", zo_iconFormat(icon, "100%", "100%"))
            messageParams:SetText(zo_strformat(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED, formattedIcon))
            if not LUIE.SV.HideXPBar then
                if wasChampionSystemUnlocked then
                    local championPoints = GetPlayerChampionPointsEarned()
                    local currentChampionXP = GetPlayerChampionXP()
                    if not LUIE.SV.HideXPBar then
                        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, currentChampionXP, currentChampionXP)
                        barParams:SetTriggeringEvent(EVENT_CHAMPION_LEVEL_ACHIEVED)
                        barParams:SetShowNoGain(true)
                        I.ValidateProgressBarParams(barParams)
                        messageParams:SetBarParams(barParams)
                    end
                else
                    local totalChampionPoints = GetPlayerChampionPointsEarned()
                    local championXPGained = 0
                    for i = 0, (totalChampionPoints - 1) do
                        championXPGained = championXPGained + GetNumChampionXPInChampionPoint(i)
                    end
                    if not LUIE.SV.HideXPBar then
                        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, 0, 0, championXPGained)
                        barParams:SetTriggeringEvent(EVENT_CHAMPION_LEVEL_ACHIEVED)
                        I.ValidateProgressBarParams(barParams)
                        messageParams:SetBarParams(barParams)
                    end
                    messageParams:SetLifespanMS(CHAMPION_UNLOCKED_LIFESPAN_MS)
                end
            end
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_LEVEL_ACHIEVED)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
            local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat("<<1>> ", zo_iconFormat(icon, "75%", "75%")) or ""
            local text = zo_strformat(GetString(SI_CHAMPION_ANNOUNCEMENT_UNLOCKED), formattedIcon)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
        end

        if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            PlaySound(SOUNDS.CHAMPION_POINT_GAINED)
        end

        return true
    end

    local savedEndingPoints = 0 -- We reset this value after the throttled function sends info to the chat printer
    local savedPointDelta = 0   -- We reset this value after the throttled function sends info to the chat printer

    local function ChampionPointGainedPrinter()
        -- adding one so that we are starting from the first gained point instead of the starting champion points
        local startingPoints = savedEndingPoints - savedPointDelta + 1
        local championPointsByType =
        {
            [CHAMPION_DISCIPLINE_TYPE_WORLD] = 0,
            [CHAMPION_DISCIPLINE_TYPE_COMBAT] = 0,
            [CHAMPION_DISCIPLINE_TYPE_CONDITIONING] = 0,
        }

        while startingPoints <= savedEndingPoints do
            local pointType = GetChampionPointPoolForRank(startingPoints)
            championPointsByType[pointType] = championPointsByType[pointType] + 1
            startingPoints = startingPoints + 1
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
            local formattedString = ColorizeColors.ExperienceLevelUpColorize:Colorize(zo_strformat(SI_CHAMPION_POINT_EARNED, savedPointDelta) .. ": ")
            ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "EXPERIENCE LEVEL" }
            ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
            eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages, true)
        end

        local secondLine = ""
        if ChatAnnouncements.SV.XP.ExperienceLevelUpCA or ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            for pointType, amount in pairs(championPointsByType) do
                if amount > 0 then
                    local disciplineData = CHAMPION_DATA_MANAGER:FindChampionDisciplineDataByType(pointType)
                    if disciplineData == nil then
                        return
                    end
                    local icon = disciplineData:GetHUDIcon()
                    local formattedIcon = ChatAnnouncements.SV.XP.ExperienceLevelUpIcon and zo_strformat(" <<1>>", zo_iconFormat(icon, 16, 16)) or ""
                    local disciplineName = disciplineData:GetRawName()

                    local formattedString
                    if ChatAnnouncements.SV.XP.ExperienceLevelColorByLevel then
                        formattedString = ZO_CP_BAR_GRADIENT_COLORS[pointType][2]:Colorize(zo_strformat(LUIE_STRING_CHAMPION_POINT_TYPE, amount, formattedIcon, disciplineName))
                    else
                        formattedString = ColorizeColors.ExperienceLevelUpColorize:Colorize(zo_strformat(LUIE_STRING_CHAMPION_POINT_TYPE, amount, formattedIcon, disciplineName))
                    end
                    if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
                        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedString, type = "EXPERIENCE LEVEL" }
                        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                        eventManager:RegisterForUpdate(moduleName .. "Printer", 25, ChatAnnouncements.PrintQueuedMessages, true)
                    end
                    if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                        secondLine = secondLine .. zo_strformat(SI_CHAMPION_POINT_TYPE, amount, icon, disciplineName) .. "\n"
                    end
                end
            end
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.CHAMPION_POINT_GAINED)
            messageParams:SetText(zo_strformat(SI_CHAMPION_POINT_EARNED, savedPointDelta), secondLine)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
            messageParams:MarkSuppressIconFrame()
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end

        if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
            local text = zo_strformat("<<1>>!", GetString(SI_CHAMPION_POINT_EARNED, savedPointDelta))
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
        end

        if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
            PlaySound(SOUNDS.CHAMPION_POINT_GAINED)
        end

        savedEndingPoints = 0
        savedPointDelta = 0
    end

    -- EVENT_CHAMPION_POINT_GAINED (CSA Handler)
    local function ChampionPointGainedHook(pointDelta)
        -- Print throttled XP value
        eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
        ChatAnnouncements.PrintBufferedXP()

        savedEndingPoints = GetPlayerChampionPointsEarned()
        savedPointDelta = savedPointDelta + pointDelta

        eventManager:RegisterForUpdate(moduleName .. "ChampionPointThrottle", 25, ChampionPointGainedPrinter, true)

        return true
    end

    ZO_PreHook(alertHandlers, EVENT_DISCOVERY_EXPERIENCE, DiscoveryExperienceAlert)
    ZO_PreHook(csaHandlers, EVENT_DISCOVERY_EXPERIENCE, DiscoveryExperienceHook)
    ZO_PreHook(csaHandlers, EVENT_POI_DISCOVERED, PoiDiscoveredHook)
    ZO_PreHook(csaHandlers, EVENT_EXPERIENCE_GAIN, ExperienceGainHook)
    ZO_PreHook(csaHandlers, EVENT_ENLIGHTENED_STATE_GAINED, EnlightenGainHook)
    ZO_PreHook(csaHandlers, EVENT_ENLIGHTENED_STATE_LOST, EnlightenLostHook)
    ZO_PreHook(csaHandlers, EVENT_PLAYER_ACTIVATED, PlayerActivatedHook)
    ZO_PreHook(csaHandlers, EVENT_CHAMPION_LEVEL_ACHIEVED, ChampionLevelAchievedHook)
    ZO_PreHook(csaHandlers, EVENT_CHAMPION_POINT_GAINED, ChampionPointGainedHook)

    if CENTER_SCREEN_ANNOUNCE_TYPE_VETERANCY_RANK_UP then
        local VETERANCY_RANK_BACKGROUND = "EsoUI/Art/Veterancy/veterancy_rank_bg.dds"
        local function VeterancyRankUpHook(rankIndex)
            if not I.AnyExperienceLevelUpAnnouncementEnabled() then
                return
            end
            if not ZO_VETERANCY_MANAGER then
                return true
            end
            local currentRankData = ZO_VETERANCY_MANAGER:GetRankDataByIndex(rankIndex)
            if not currentRankData then
                return true
            end
            local headerText = GetString(SI_VETERANCY_RANK_UP_ANNOUNCEMENT_HEADER)
            local rankName = currentRankData:GetName()
            local formattedMessage = zo_strformat("<<1>>: <<2>>", headerText, rankName)
            if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, type = "EXPERIENCE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end
            local soundId
            if rankIndex < ZO_VETERANCY_RANK_GROUP_INDEX_UPPER_BOUND_LOW then
                soundId = SOUNDS.VETERANCY_RANK_UP_LOW
            elseif rankIndex < ZO_VETERANCY_RANK_GROUP_INDEX_UPPER_BOUND_HIGH then
                soundId = SOUNDS.VETERANCY_RANK_UP_HIGH
            elseif rankIndex == ZO_VETERANCY_RANK_GROUP_INDEX_UPPER_BOUND_HIGH then
                soundId = SOUNDS.VETERANCY_RANK_UP_MAX
            else
                soundId = SOUNDS.VETERANCY_RANK_UP_REPEATABLE
            end
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
            if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                messageParams:SetText(headerText, rankName)
                messageParams:SetIconData(currentRankData:GetIcon(), VETERANCY_RANK_BACKGROUND)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_VETERANCY_RANK_UP)
                messageParams:SetSound(soundId)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedMessage)
            end
            if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                PlaySound(soundId)
            end
            return true
        end
        local function VeterancyRepeatableRankClaimedHook(claimedCount)
            if not I.AnyExperienceLevelUpAnnouncementEnabled() then
                return
            end
            if not ZO_VETERANCY_MANAGER then
                return true
            end
            local currentRankData = ZO_VETERANCY_MANAGER:GetCurrentRankData()
            if not currentRankData then
                return true
            end
            local rankRewardData = currentRankData:GetRankRewardDataByIndex(1)
            if not rankRewardData then
                return true
            end
            local rewardData = rankRewardData:GetRewardData()
            local rewardText = rewardData:GetQuantity() > 1 and rewardData:GetFormattedNameWithStack() or rewardData:GetFormattedName()
            local secondaryText = claimedCount > 1 and zo_strformat(SI_VETERANCY_MAX_RANK_CLAIMED_COUNT_FORMATTER, claimedCount, rewardText) or rewardText
            local headerText = GetString(SI_VETERANCY_MAX_RANK_CLAIMED_ANNOUNCEMENT_HEADER)
            local formattedMessage = zo_strformat("<<1>>: <<2>>", headerText, secondaryText)
            if ChatAnnouncements.SV.XP.ExperienceLevelUpCA then
                ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = formattedMessage, type = "EXPERIENCE" }
                ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
                eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
            end
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.VETERANCY_RANK_UP_REPEATABLE)
            if ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                messageParams:SetText(headerText, secondaryText)
                messageParams:SetIconData(rewardData:GetPlatformLootIcon(), EMERGENCY_BACKGROUND)
                messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_VETERANCY_MAX_REWARD_CLAIMED)
                CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
            end
            if ChatAnnouncements.SV.XP.ExperienceLevelUpAlert then
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, formattedMessage)
            end
            if not ChatAnnouncements.SV.XP.ExperienceLevelUpCSA then
                PlaySound(SOUNDS.VETERANCY_RANK_UP_REPEATABLE)
            end
            return true
        end
        local veterancyRankUpHandler = FindCsaCallbackHandler("OnVeterancyRankUp")
        if veterancyRankUpHandler then
            ZO_PreHook(veterancyRankUpHandler, "callbackFunction", VeterancyRankUpHook)
        end
        local veterancyClaimHandler = FindCsaCallbackHandler("OnVeterancyRepeatableRankClaimed")
        if veterancyClaimHandler then
            ZO_PreHook(veterancyClaimHandler, "callbackFunction", VeterancyRepeatableRankClaimedHook)
        end
    end
end
