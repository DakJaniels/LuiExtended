-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements


local ColorizeColors = ChatAnnouncements.Colors

local string_format = string.format

local eventManager = GetEventManager()

local moduleName = LUIE.name .. "ChatAnnouncements"

------------------------------------------------
-- LOCAL (GLOBAL) VARIABLE SETUP ---------------
------------------------------------------------

-- Experience
local g_xpCombatBufferValue = 0      -- Buffered XP Value
local g_guildSkillThrottle = 0       -- Buffered Fighter's Guild Reputation Value
local g_guildSkillThrottleLine = nil -- Grab the name for Fighter's Guild reputation (since index isn't always the same) to pass over to Buffered Printer Function

-- Ability Progression XP cache, keyed by progressionIndex, storing the prior XP window to derive the gain.
local g_abilityProgressionXpCache = {}

------------------------------------------------
-- FUNCTIONS -----------------------------------
------------------------------------------------
--- @param skillType SkillType
--- @param skillLineIndex integer
--- @return string name
--- @return integer currentRank
--- @return boolean isAvailable
--- @return integer id
--- @return boolean isAdvised
--- @return string unlockText
--- @return boolean isActive
--- @return boolean isDiscovered
local function GetSkillLineInfo(skillType, skillLineIndex)
    local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillLineIndex)
    if skillLineData then
        return skillLineData:GetName(), skillLineData:GetCurrentRank(), skillLineData:IsAvailable(), skillLineData:GetId(), skillLineData:IsAdvised(), skillLineData:GetUnlockText(), skillLineData:IsActive(), skillLineData:IsDiscovered()
    end
    return "", 1, false, 0, false, "", false, false
end

-- EVENT_EXPERIENCE_GAIN HANDLER
--- @param eventId integer
--- @param reason integer
--- @param level integer
--- @param previousExperience integer
--- @param currentExperience integer
--- @param championPoints integer
function ChatAnnouncements.OnExperienceGain(eventId, reason, level, previousExperience, currentExperience, championPoints)
    -- d("Experience Gain) previousExperience: " .. previousExperience .. " --- " .. "currentExperience: " .. currentExperience)
    if ChatAnnouncements.SV.XP.Experience and (not (ChatAnnouncements.SV.XP.ExperienceHideCombat and reason == PROGRESS_REASON_KILL) or not reason == PROGRESS_REASON_KILL) then
        local change = currentExperience - previousExperience -- Change in Experience Points on gaining them

        -- If throttle is enabled, save value and end function here
        if ChatAnnouncements.SV.XP.ExperienceThrottle > 0 and reason == PROGRESS_REASON_KILL then
            g_xpCombatBufferValue = g_xpCombatBufferValue + change
            eventManager:RegisterForUpdate(moduleName .. "BufferedXP", ChatAnnouncements.SV.XP.ExperienceThrottle, ChatAnnouncements.PrintBufferedXP, true)
            return
        end

        -- If filter is enabled and value is below filter then end function here
        if ChatAnnouncements.SV.XP.ExperienceFilter > 0 and reason == PROGRESS_REASON_KILL then
            if change < ChatAnnouncements.SV.XP.ExperienceFilter then
                return
            end
        end

        -- If we gain experience from a non combat source, and our buffer function holds a value, then we need to immediately dump this value before the next XP update is processed.
        if ChatAnnouncements.SV.XP.ExperienceThrottle > 0 and g_xpCombatBufferValue > 0 and (reason ~= PROGRESS_REASON_KILL and reason ~= 99) then
            eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
            ChatAnnouncements.PrintBufferedXP()
        end

        ChatAnnouncements.PrintExperienceGain(change)
    end
end

-- Print Experience Gain
--- @param change integer
function ChatAnnouncements.PrintExperienceGain(change)
    local icon = ChatAnnouncements.SV.XP.ExperienceIcon and "|t16:16:/esoui/art/icons/icon_experience.dds|t " or ""
    local xpName = zo_strformat(ChatAnnouncements.GetModuleMessageFormat("XP", "ExperienceName"), change)
    local messageP1 = ("|r|c" .. ColorizeColors.ExperienceNameColorize .. icon .. ZO_CommaDelimitDecimalNumber(change) .. " " .. xpName .. "|r|c" .. ColorizeColors.ExperienceMessageColorize)
    local formattedMessageP1 = (string_format(ChatAnnouncements.GetModuleMessageFormat("XP", "ExperienceMessage"), messageP1))
    local finalMessage = string_format("|c%s%s|r", ColorizeColors.ExperienceMessageColorize, formattedMessageP1)

    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "EXPERIENCE" }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
end

-- Print Buffered Experience Gain
function ChatAnnouncements.PrintBufferedXP()
    if g_xpCombatBufferValue > 0 and g_xpCombatBufferValue > ChatAnnouncements.SV.XP.ExperienceFilter then
        local change = g_xpCombatBufferValue
        ChatAnnouncements.PrintExperienceGain(change)
    end
    g_xpCombatBufferValue = 0
end

-- EVENT_SKILL_XP_UPDATE HANDLER
--- @param eventId integer
--- @param skillType SkillType
--- @param skillIndex integer
--- @param reason integer
--- @param rank integer
--- @param previousXP integer
--- @param currentXP integer
function ChatAnnouncements.SkillXPUpdate(eventId, skillType, skillIndex, reason, rank, previousXP, currentXP)
    if skillType == SKILL_TYPE_GUILD then
        local lineName, _, _, lineId = GetSkillLineInfo(skillType, skillIndex)
        local formattedName = zo_strformat("<<C:1>>", lineName)

        -- Bail out early if a certain type is not set to be displayed
        if lineId == 45 and not ChatAnnouncements.SV.Skills.SkillGuildFighters then
            return
        elseif lineId == 44 and not ChatAnnouncements.SV.Skills.SkillGuildMages then
            return
        elseif lineId == 55 and not ChatAnnouncements.SV.Skills.SkillGuildUndaunted then
            return
        elseif lineId == 117 and not ChatAnnouncements.SV.Skills.SkillGuildThieves then
            return
        elseif lineId == 118 and not ChatAnnouncements.SV.Skills.SkillGuildDarkBrotherhood then
            return
        elseif lineId == 130 and not ChatAnnouncements.SV.Skills.SkillGuildPsijicOrder then
            return
        end

        local change = currentXP - previousXP
        local priority

        if ChatAnnouncements.SV.Skills.SkillGuildAlert then
            local text = zo_strformat(GetString(LUIE_STRING_CA_SKILL_GUILD_ALERT), formattedName)
            ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, text)
        end

        -- Bail out or save value if Throttle/Threshold conditions are met
        if lineId == 45 then
            priority = "EXPERIENCE LEVEL"
            -- FG rep is either a quest reward (10) or kills (1 & 5)
            -- Only throttle values 5 or lower (FG Dailies give +10 skill)
            if ChatAnnouncements.SV.Skills.SkillGuildThrottle > 0 and change <= 5 then
                g_guildSkillThrottle = g_guildSkillThrottle + change
                g_guildSkillThrottleLine = formattedName
                eventManager:RegisterForUpdate(moduleName .. "BufferedRep", ChatAnnouncements.SV.Skills.SkillGuildThrottle, ChatAnnouncements.PrintBufferedGuildRep, true)
                return
            end

            -- If throttle wasn't triggered and the value was below threshold then bail out.
            if change <= ChatAnnouncements.SV.Skills.SkillGuildThreshold then
                return
            end
        end

        if lineId == 44 then
            -- Mages Guild rep is either a quest reward (10), book discovered (5), collection discovered (20)
            if change == 10 then
                priority = "EXPERIENCE LEVEL"
            else
                priority = "MESSAGE"
            end
        end

        if lineId == 55 or lineId == 117 or lineId == 118 or lineId == 130 then
            -- Other guilds are usually either a quest reward or achievement reward
            priority = "EXPERIENCE LEVEL"
        end
        ChatAnnouncements.PrintGuildRep(change, formattedName, lineId, priority)
    end
end

-- Helper function to get the color for the Guild
local function GetGuildColor(lineId)
    local GUILD_SKILL_COLOR_TABLE =
    {
        [45] = ColorizeColors.SkillGuildColorizeFG,
        [44] = ColorizeColors.SkillGuildColorizeMG,
        [55] = ColorizeColors.SkillGuildColorizeUD,
        [117] = ColorizeColors.SkillGuildColorizeTG,
        [118] = ColorizeColors.SkillGuildColorizeDB,
        [130] = ColorizeColors.SkillGuildColorizePO,
    }
    return GUILD_SKILL_COLOR_TABLE[lineId]
end

-- TODO: Check if there is an equivalency in one of the handlers for this
local GUILD_SKILL_ICONS =
{
    [45] = "/esoui/art/icons/mapkey/mapkey_fightersguild.dds",
    [44] = "/esoui/art/icons/mapkey/mapkey_magesguild.dds",
    [55] = "/esoui/art/icons/mapkey/mapkey_undaunted.dds",
    [117] = "/esoui/art/icons/mapkey/mapkey_thievesguild.dds",
    [118] = "/esoui/art/icons/mapkey/mapkey_darkbrotherhood.dds",
    [130] = LUIE_MEDIA_UNITFRAMES_MAPKEY_PSIJICORDER_DDS,
}

-- Print Guild Rep Gain
--- @param change integer
--- @param lineName string
--- @param lineId integer
--- @param priority integer
function ChatAnnouncements.PrintGuildRep(change, lineName, lineId, priority)
    local icon = zo_iconFormatInheritColor(GUILD_SKILL_ICONS[lineId], 16, 16)
    local formattedIcon = ChatAnnouncements.SV.Skills.SkillGuildIcon and (icon .. " ") or ""

    local guildString = zo_strformat(ChatAnnouncements.GetModuleMessageFormat("Skills", "SkillGuildRepName"), change)
    local colorize = GetGuildColor(lineId)
    local messageP1 = ("|r|c" .. colorize .. formattedIcon .. change .. " " .. lineName .. " " .. guildString .. "|r|c" .. ColorizeColors.SkillGuildColorize)
    local formattedMessageP1 = (string_format(ChatAnnouncements.GetModuleMessageFormat("Skills", "SkillGuildMsg"), messageP1))
    local finalMessage = string_format("|c%s%s|r", ColorizeColors.SkillGuildColorize, formattedMessageP1)

    -- We set this to skill gain, so as to avoid creating an entire additional chat message category (we want it to show after XP but before any other skill gains or level up so we place it on top of the level up priority).
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = priority }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
end

-- Print Buffered Guild Rep Gain
function ChatAnnouncements.PrintBufferedGuildRep()
    if g_guildSkillThrottle > 0 and g_guildSkillThrottle > ChatAnnouncements.SV.Skills.SkillGuildThreshold then
        local lineId = 45
        local lineName = g_guildSkillThrottleLine
        ChatAnnouncements.PrintGuildRep(g_guildSkillThrottle, lineName, lineId, "EXPERIENCE LEVEL")
    end
    g_guildSkillThrottle = 0
    g_guildSkillThrottleLine = ""
end

function ChatAnnouncements.RefreshAbilityProgressionXpCache()
    g_abilityProgressionXpCache = {}

    if not (ChatAnnouncements.SV.Skills.SkillAbilityXpCA or ChatAnnouncements.SV.Skills.SkillAbilityXpAlert) then
        return
    end

    local numSkillTypes = GetNumSkillTypes()
    for skillType = 1, numSkillTypes do
        local numSkillLines = GetNumSkillLines(skillType)
        for skillLineIndex = 1, numSkillLines do
            local numAbilities = GetNumSkillAbilities(skillType, skillLineIndex)
            for abilityIndex = 1, numAbilities do
                local _, _, _, _, _, _, progressionIndex = GetSkillAbilityInfo(skillType, skillLineIndex, abilityIndex)
                if progressionIndex and progressionIndex > 0 then
                    local lastRankXP, nextRankXP, currentXP = GetAbilityProgressionXPInfo(progressionIndex)
                    g_abilityProgressionXpCache[progressionIndex] = { lastRankXP = lastRankXP, nextRankXP = nextRankXP, currentXP = currentXP }
                end
            end
        end
    end
end

--- @param progressionIndex integer
function ChatAnnouncements.RefreshAbilityProgressionXpCacheForProgression(progressionIndex)
    if not (ChatAnnouncements.SV.Skills.SkillAbilityXpCA or ChatAnnouncements.SV.Skills.SkillAbilityXpAlert) then
        return
    end
    local lastRankXP, nextRankXP, currentXP = GetAbilityProgressionXPInfo(progressionIndex)
    g_abilityProgressionXpCache[progressionIndex] = { lastRankXP = lastRankXP, nextRankXP = nextRankXP, currentXP = currentXP }
end

-- Print Ability Progression XP Gain
--- @param abilityNameAndRank string
--- @param change integer the XP gained this update
--- @param rankProgress integer XP earned into the current rank (currentXP - lastRankXP)
--- @param rankXpWindow integer total XP span of the current rank (nextRankXP - lastRankXP)
--- @param texture string|nil
function ChatAnnouncements.PrintAbilityProgressionXpGain(abilityNameAndRank, change, rankProgress, rankXpWindow, texture)
    local showIcon = ChatAnnouncements.SV.Skills.SkillAbilityXpIcon and texture and texture ~= ""
    local formattedIcon = showIcon and (zo_iconFormat(texture, 16, 16) .. " ") or ""

    local plainText
    if ChatAnnouncements.SV.Skills.SkillAbilityXpProgress and rankXpWindow and rankXpWindow > 0 then
        local percentLeft = string.format("%.1f", ((rankXpWindow - rankProgress) / rankXpWindow) * 100)
        plainText = zo_strformat(LUIE_STRING_CA_ABILITY_XP_GAIN_PROGRESS, abilityNameAndRank, ZO_CommaDelimitDecimalNumber(change), ZO_CommaDelimitDecimalNumber(rankProgress), ZO_CommaDelimitDecimalNumber(rankXpWindow), percentLeft)
    else
        plainText = zo_strformat(LUIE_STRING_CA_ABILITY_XP_GAIN, abilityNameAndRank, ZO_CommaDelimitDecimalNumber(change))
    end

    if ChatAnnouncements.SV.Skills.SkillAbilityXpCA then
        local finalMessage = ColorizeColors.SkillLineColorize:Colorize(formattedIcon .. plainText)
        ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "SKILL" }
        ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
        eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages, true)
    end

    if ChatAnnouncements.SV.Skills.SkillAbilityXpAlert then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, plainText)
    end
end

-- Returns true when an ability can no longer gain progression XP: a base (unmorphed)
-- ability that has reached its morph point, or a morphed ability that has reached max rank.
-- At max rank the progression XP window stops representing real progress, so we skip it.
--- @param skillData table
--- @param progressionIndex integer
--- @param nextRankXP integer
--- @return boolean
local function GetAbilityProgressionAtMaxRank(skillData, progressionIndex, nextRankXP)
    if skillData:IsPassive() or skillData:IsCraftedAbility() then
        return nextRankXP == 0
    end

    local _, morph = GetAbilityProgressionInfo(progressionIndex)
    local progressionData = skillData:GetProgressionData(morph)
    if not progressionData then
        return nextRankXP == 0
    end

    if progressionData:IsBase() then
        return skillData:IsAtMorph()
    end

    if progressionData:GetCurrentRank() ~= MAX_RANKS_PER_ABILITY then
        return false
    end

    local _, maxRankEndXP = progressionData:GetRankXPExtents(MAX_RANKS_PER_ABILITY)
    return progressionData:GetCurrentXP() >= maxRankEndXP
end

-- EVENT_ABILITY_PROGRESSION_XP_UPDATE HANDLER
--- @param eventId integer
--- @param progressionIndex integer
--- @param lastRankXP integer
--- @param nextRankXP integer
--- @param currentXP integer
--- @param atMorph boolean
function ChatAnnouncements.OnAbilityProgressionXpUpdate(eventId, progressionIndex, lastRankXP, nextRankXP, currentXP, atMorph)
    local skillType, skillLineIndex, skillIndex = GetSkillAbilityIndicesFromProgressionIndex(progressionIndex)
    local skillData = SKILLS_DATA_MANAGER:GetSkillDataByIndices(skillType, skillLineIndex, skillIndex)
    if not skillData then
        return
    end

    local cached = g_abilityProgressionXpCache[progressionIndex]
    g_abilityProgressionXpCache[progressionIndex] = { lastRankXP = lastRankXP, nextRankXP = nextRankXP, currentXP = currentXP }

    if GetAbilityProgressionAtMaxRank(skillData, progressionIndex, nextRankXP) then
        return
    end

    if not cached then
        return
    end

    local change
    if lastRankXP > cached.lastRankXP then
        change = (cached.nextRankXP - cached.currentXP) + (currentXP - lastRankXP)
    else
        change = currentXP - cached.currentXP
    end

    if change <= 0 then
        return
    end

    if ChatAnnouncements.SV.Skills.SkillAbilityXpFilter > 0 and change < ChatAnnouncements.SV.Skills.SkillAbilityXpFilter then
        return
    end

    if not (ChatAnnouncements.SV.Skills.SkillAbilityXpCA or ChatAnnouncements.SV.Skills.SkillAbilityXpAlert) then
        return
    end

    local _, morph, rank = GetAbilityProgressionInfo(progressionIndex)
    local abilityName, texture = GetAbilityProgressionAbilityInfo(progressionIndex, morph, rank)
    local abilityNameAndRank = zo_strformat(SI_ABILITY_NAME_AND_RANK, abilityName, rank)

    local rankProgress = currentXP - lastRankXP
    local rankXpWindow = nextRankXP - lastRankXP
    ChatAnnouncements.PrintAbilityProgressionXpGain(abilityNameAndRank, change, rankProgress, rankXpWindow, texture)
end
