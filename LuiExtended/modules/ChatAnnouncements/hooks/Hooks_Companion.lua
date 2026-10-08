-- -----------------------------------------------------------------------------
--  LuiExtended - Chat Announcements companion level, rapport, and skill XP  --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local ColorizeColors = ChatAnnouncements.Colors
local COMPANION_NAME_COLOR = ZO_ColorDef:New(GetInterfaceColor(INTERFACE_COLOR_TYPE_UNIT_REACTION_COLOR, UNIT_REACTION_COLOR_COMPANION))

local function QueueCompanionChatAnnouncement(eventManager, moduleName, message, messageType)
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = message, type = messageType }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
end

--- @param ctx CAHookContext
function ChatAnnouncements.Hooks.RegisterCompanion(ctx)
    local csaHandlers = ctx.csaHandlers
    local eventManager = ctx.eventManager
    local moduleName = ctx.moduleName

    -- EVENT_COMPANION_EXPERIENCE_GAIN (CSA Handler)
    -- Signature: companionId, previousLevel, previousExperience, currentExperience
    -- CenterScreenAnnounceHandlers.lua treats the second argument as the previous level.
    local function CompanionExperienceGainHook(companionId, previousLevel, previousExperience, currentExperience)
        local currentLevel = GetActiveCompanionLevelForExperiencePoints(currentExperience, previousLevel)
        if not currentLevel or currentLevel <= previousLevel then
            return
        end

        local companionSettings = ChatAnnouncements.SV.Companion
        if not companionSettings or not (companionSettings.LevelUpCA or companionSettings.LevelUpCSA or companionSettings.LevelUpAlert) then
            return
        end

        local companionName = COMPANION_NAME_COLOR:Colorize(GetCompanionName(companionId))
        local collectibleIcon = GetCollectibleIcon(GetCompanionCollectibleId(companionId))
        local showIcon = companionSettings.LevelUpIcon and collectibleIcon and collectibleIcon ~= ""
        local chatIcon = showIcon and (zo_iconFormatInheritColor(collectibleIcon, 16, 16) .. " ") or ""
        local csaIcon = showIcon and zo_iconFormat(collectibleIcon, "100%", "100%") or ""
        local nameLine = zo_strformat(SI_COMPANION_LEVEL_UP_NAME_CSA, csaIcon, companionName)
        local levelUpText = GetString(SI_COMPANION_LEVEL_UP_NOTIFICATION)
        local slotUnlockText
        local previousNumSlots = GetCompanionNumSlotsUnlockedForLevel(previousLevel)
        local currentNumSlots = GetCompanionNumSlotsUnlockedForLevel(currentLevel)
        if currentNumSlots > previousNumSlots then
            slotUnlockText = GetString(SI_COMPANION_ACTION_SLOT_UNLOCKED_NOTIFICATION)
        end

        if companionSettings.LevelUpCA then
            local chatMessage = zo_strformat("<<1>><<2>> <<3>>", chatIcon, levelUpText, companionName)
            if slotUnlockText then
                chatMessage = zo_strformat("<<1>> <<2>>", chatMessage, slotUnlockText)
            end
            QueueCompanionChatAnnouncement(eventManager, moduleName, chatMessage, "EXPERIENCE LEVEL")
        end

        if companionSettings.LevelUpCSA then
            local secondaryText = nameLine
            if slotUnlockText then
                secondaryText = zo_strformat("<<1>>\n<<2>>", nameLine, slotUnlockText)
            end
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.LEVEL_UP)
            messageParams:SetText(levelUpText, secondaryText)
            messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_LEVEL_GAIN)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        elseif companionSettings.LevelUpCA or companionSettings.LevelUpAlert then
            PlaySound(SOUNDS.LEVEL_UP)
        end

        if companionSettings.LevelUpAlert then
            local alertMessage = zo_strformat("<<1>> <<2>>", levelUpText, companionName)
            if slotUnlockText then
                alertMessage = zo_strformat("<<1>> <<2>>", alertMessage, slotUnlockText)
            end
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, alertMessage)
        end

        return true
    end

    -- EVENT_COMPANION_RAPPORT_UPDATE
    -- Loot history still records this in ZO_LootHistory_Shared:AddCompanionRapportEntry.
    local function OnCompanionRapportUpdate(eventId, companionId, previousRapport, currentRapport, adjustmentAmountType)
        if currentRapport == previousRapport or adjustmentAmountType == RAPPORT_ADJUSTMENT_AMOUNT_NONE then
            return
        end

        local companionSettings = ChatAnnouncements.SV.Companion
        if not companionSettings or not (companionSettings.RapportCA or companionSettings.RapportCSA or companionSettings.RapportAlert) then
            return
        end

        local rapportFormatter = currentRapport > previousRapport and SI_LOOT_HISTORY_COMPANION_RAPPORT_GAIN_FORMATTER or SI_LOOT_HISTORY_COMPANION_RAPPORT_LOSS_FORMATTER
        local rapportMessage = zo_strformat(rapportFormatter, COMPANION_NAME_COLOR:Colorize(GetCompanionName(companionId)))
        local rapportLevelName = GetString("SI_COMPANIONRAPPORTLEVEL", GetActiveCompanionRapportLevel())
        if rapportLevelName and rapportLevelName ~= "" then
            rapportMessage = zo_strformat("<<1>> (<<2>>)", rapportMessage, rapportLevelName)
        end

        if companionSettings.RapportCA then
            QueueCompanionChatAnnouncement(eventManager, moduleName, rapportMessage, "MESSAGE")
        end
        if companionSettings.RapportCSA then
            local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT)
            messageParams:SetText(rapportMessage)
            CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
        end
        if companionSettings.RapportAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, rapportMessage)
        end
    end

    -- EVENT_COMPANION_SKILL_XP_UPDATE (skillLineId, reason, rank, previousXP, currentXP)
    local function OnCompanionSkillXpUpdate(eventId, skillLineId, skillXpReason, skillRank, previousXP, currentXP)
        local experienceGained = currentXP - previousXP
        if experienceGained <= 0 then
            return
        end

        local companionSettings = ChatAnnouncements.SV.Companion
        if not companionSettings or not (companionSettings.SkillXpCA or companionSettings.SkillXpAlert) then
            return
        end
        if companionSettings.SkillXpFilter > 0 and experienceGained < companionSettings.SkillXpFilter then
            return
        end

        local lineName = zo_strformat("<<C:1>>", GetCompanionSkillLineNameById(skillLineId))
        local lastRankXP, nextRankXP, reportedCurrentXP = GetCompanionSkillLineXPInfo(skillLineId)
        local rankProgress = 0
        local rankXpWindow = 0
        if lastRankXP and nextRankXP and reportedCurrentXP then
            rankProgress = reportedCurrentXP - lastRankXP
            rankXpWindow = nextRankXP - lastRankXP
        end

        local announceIcon = ""
        if companionSettings.SkillXpIcon and COMPANION_SKILLS_DATA_MANAGER then
            local skillLineData = COMPANION_SKILLS_DATA_MANAGER:GetSkillLineDataById(skillLineId)
            local skillTypeData = skillLineData and skillLineData:GetSkillTypeData()
            local iconTexture = skillTypeData and skillTypeData:GetAnnounceIcon()
            if iconTexture and iconTexture ~= "" then
                announceIcon = zo_iconFormat(iconTexture, 16, 16) .. " "
            end
        end

        local plainText
        if companionSettings.SkillXpProgress and rankXpWindow > 0 then
            local percentLeft = string.format("%.1f", ((rankXpWindow - rankProgress) / rankXpWindow) * 100)
            plainText = zo_strformat(LUIE_STRING_CA_ABILITY_XP_GAIN_PROGRESS, lineName, ZO_CommaDelimitDecimalNumber(experienceGained), ZO_CommaDelimitDecimalNumber(rankProgress), ZO_CommaDelimitDecimalNumber(rankXpWindow), percentLeft)
        else
            plainText = zo_strformat(LUIE_STRING_CA_ABILITY_XP_GAIN, lineName, ZO_CommaDelimitDecimalNumber(experienceGained))
        end

        if companionSettings.SkillXpCA then
            QueueCompanionChatAnnouncement(eventManager, moduleName, ColorizeColors.SkillLineColorize:Colorize(announceIcon .. plainText), "SKILL")
        end
        if companionSettings.SkillXpAlert then
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, plainText)
        end
    end

    ZO_PreHook(csaHandlers, EVENT_COMPANION_EXPERIENCE_GAIN, CompanionExperienceGainHook)
    eventManager:RegisterForEvent(moduleName, EVENT_COMPANION_RAPPORT_UPDATE, OnCompanionRapportUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_COMPANION_SKILL_XP_UPDATE, OnCompanionSkillXpUpdate)
end
