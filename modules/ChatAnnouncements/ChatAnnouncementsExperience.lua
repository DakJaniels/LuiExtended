-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- ChatAnnouncements namespace
--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

--- @type Data
local Data = LUIE.Data
--- @type Effects
local Effects = Data.Effects
--- @type Quests
local Quests = Data.Quests

local ColorizeColors = ChatAnnouncements.Colors

local printToChat = LUIE.PrintToChat
local string_format = string.format
local table_insert = table.insert
local table_concat = table.concat

local eventManager = GetEventManager()
local windowManager = GetWindowManager()

local moduleName = LUIE.name .. "ChatAnnouncements"

------------------------------------------------
-- LOCAL (GLOBAL) VARIABLE SETUP ---------------
------------------------------------------------

-- Experience
local g_xpCombatBufferValue = 0      -- Buffered XP Value
local g_guildSkillThrottle = 0       -- Buffered Fighter's Guild Reputation Value
local g_guildSkillThrottleLine = nil -- Grab the name for Fighter's Guild reputation (since index isn't always the same) to pass over to Buffered Printer Function

------------------------------------------------
-- FUNCTIONS -----------------------------------
------------------------------------------------

-- EVENT_EXPERIENCE_GAIN HANDLER
function ChatAnnouncements.OnExperienceGain(eventCode, reason, level, previousExperience, currentExperience, championPoints)
    -- d("Experience Gain) previousExperience: " .. previousExperience .. " --- " .. "currentExperience: " .. currentExperience)
    if ChatAnnouncements.SV.XP.Experience and (not (ChatAnnouncements.SV.XP.ExperienceHideCombat and reason == PROGRESS_REASON_KILL) or not reason == PROGRESS_REASON_KILL) then
        local change = currentExperience - previousExperience -- Change in Experience Points on gaining them

        -- If throttle is enabled, save value and end function here
        if ChatAnnouncements.SV.XP.ExperienceThrottle > 0 and reason == PROGRESS_REASON_KILL then
            g_xpCombatBufferValue = g_xpCombatBufferValue + change
            -- We unregister the event, then re-register it, this keeps the buffer at a constant X throttle after XP is gained.
            eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
            eventManager:RegisterForUpdate(moduleName .. "BufferedXP", ChatAnnouncements.SV.XP.ExperienceThrottle, ChatAnnouncements.PrintBufferedXP)
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
function ChatAnnouncements.PrintExperienceGain(change)
    local icon = ChatAnnouncements.SV.XP.ExperienceIcon and "|t16:16:/esoui/art/icons/icon_experience.dds|t " or ""
    local xpName = zo_strformat(ChatAnnouncements.SV.XP.ExperienceName, change)
    local messageP1 = ("|r|c" .. ColorizeColors.ExperienceNameColorize .. icon .. ZO_CommaDelimitDecimalNumber(change) .. " " .. xpName .. "|r|c" .. ColorizeColors.ExperienceMessageColorize)
    local formattedMessageP1 = (string_format(ChatAnnouncements.SV.XP.ExperienceMessage, messageP1))
    local finalMessage = string_format("|c%s%s|r", ColorizeColors.ExperienceMessageColorize, formattedMessageP1)

    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = "EXPERIENCE" }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

-- Print Buffered Experience Gain
function ChatAnnouncements.PrintBufferedXP()
    if g_xpCombatBufferValue > 0 and g_xpCombatBufferValue > ChatAnnouncements.SV.XP.ExperienceFilter then
        local change = g_xpCombatBufferValue
        ChatAnnouncements.PrintExperienceGain(change)
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
    g_xpCombatBufferValue = 0
end

-- EVENT_SKILL_XP_UPDATE HANDLER
function ChatAnnouncements.SkillXPUpdate(eventCode, skillType, skillIndex, reason, rank, previousXP, currentXP)
    if skillType == SKILL_TYPE_GUILD then
        local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillIndex)
        local lineName, lineId = skillLineData:GetName(), skillLineData:GetId()
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
                eventManager:UnregisterForUpdate(moduleName .. "BufferedRep")
                eventManager:RegisterForUpdate(moduleName .. "BufferedRep", ChatAnnouncements.SV.Skills.SkillGuildThrottle, ChatAnnouncements.PrintBufferedGuildRep)
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
    [130] = "LuiExtended/media/unitframes/mapkey_psijicorder.dds",
}

-- Print Guild Rep Gain
function ChatAnnouncements.PrintGuildRep(change, lineName, lineId, priority)
    local icon = zo_iconFormatInheritColor(GUILD_SKILL_ICONS[lineId], 16, 16)
    local formattedIcon = ChatAnnouncements.SV.Skills.SkillGuildIcon and (icon .. " ") or ""

    local guildString = zo_strformat(ChatAnnouncements.SV.Skills.SkillGuildRepName, change)
    local colorize = GetGuildColor(lineId)
    local messageP1 = ("|r|c" .. colorize .. formattedIcon .. change .. " " .. lineName .. " " .. guildString .. "|r|c" .. ColorizeColors.SkillGuildColorize)
    local formattedMessageP1 = (string_format(ChatAnnouncements.SV.Skills.SkillGuildMsg, messageP1))
    local finalMessage = string_format("|c%s%s|r", ColorizeColors.SkillGuildColorize, formattedMessageP1)

    -- We set this to skill gain, so as to avoid creating an entire additional chat message category (we want it to show after XP but before any other skill gains or level up so we place it on top of the level up priority).
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] = { message = finalMessage, type = priority }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

-- Print Buffered Guild Rep Gain
function ChatAnnouncements.PrintBufferedGuildRep()
    if g_guildSkillThrottle > 0 and g_guildSkillThrottle > ChatAnnouncements.SV.Skills.SkillGuildThreshold then
        local lineId = 45
        local lineName = g_guildSkillThrottleLine
        ChatAnnouncements.PrintGuildRep(g_guildSkillThrottle, lineName, lineId, "EXPERIENCE LEVEL")
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedRep")
    g_guildSkillThrottle = 0
    g_guildSkillThrottleLine = ""
end
