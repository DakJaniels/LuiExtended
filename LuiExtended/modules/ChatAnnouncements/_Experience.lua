-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

local eventManager = GetEventManager()

--- @class (partial) LuiExtended
local LUIE = LUIE
-- ChatAnnouncements namespace
--- @class (partial) ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local moduleName = ChatAnnouncements.moduleName

---------------------------------------------
-- FUNCTIONS -----------------------------------
------------------------------------------------

--- - **EVENT_EXPERIENCE_GAIN **
---
--- @param eventId integer
--- @param reason ProgressReason
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
            ChatAnnouncements.xpCombatBufferValue = ChatAnnouncements.xpCombatBufferValue + change
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
        if ChatAnnouncements.SV.XP.ExperienceThrottle > 0 and ChatAnnouncements.xpCombatBufferValue > 0 and (reason ~= PROGRESS_REASON_KILL and reason ~= 99) then
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
    local messageP1 = ("|r|c" .. ChatAnnouncements.Colors.ExperienceNameColorize .. icon .. ZO_CommaDelimitDecimalNumber(change) .. " " .. xpName .. "|r|c" .. ChatAnnouncements.Colors.ExperienceMessageColorize)
    local formattedMessageP1 = (string.format(ChatAnnouncements.SV.XP.ExperienceMessage, messageP1))
    local finalMessage = string.format("|c%s%s|r", ChatAnnouncements.Colors.ExperienceMessageColorize, formattedMessageP1)

    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
    {
        message = finalMessage,
        messageType = "EXPERIENCE"
    }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

-- Print Buffered Experience Gain
function ChatAnnouncements.PrintBufferedXP()
    if ChatAnnouncements.xpCombatBufferValue > 0 and ChatAnnouncements.xpCombatBufferValue > ChatAnnouncements.SV.XP.ExperienceFilter then
        local change = ChatAnnouncements.xpCombatBufferValue
        ChatAnnouncements.PrintExperienceGain(change)
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedXP")
    ChatAnnouncements.xpCombatBufferValue = 0
end

--- - **EVENT_SKILL_XP_UPDATE **
---
--- @param eventId integer
--- @param skillType SkillType
--- @param skillLineIndex luaindex
--- @param reason integer
--- @param rank luaindex
--- @param previousXP integer
--- @param currentXP integer
function ChatAnnouncements.SkillXPUpdate(eventId, skillType, skillLineIndex, reason, rank, previousXP, currentXP)
    if skillType == SKILL_TYPE_GUILD then
        local skillLineData = SKILLS_DATA_MANAGER:GetSkillLineDataByIndices(skillType, skillLineIndex)
        if skillLineData then
            local lineName, lineId = skillLineData:GetName(), skillLineData:GetId()
            local formattedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, lineName)

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
                ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, text)
            end

            -- Bail out or save value if Throttle/Threshold conditions are met
            if lineId == 45 then
                priority = "EXPERIENCE_LEVEL"
                -- FG rep is either a quest reward (10) or kills (1 & 5)
                -- Only throttle values 5 or lower (FG Dailies give +10 skill)
                if ChatAnnouncements.SV.Skills.SkillGuildThrottle > 0 and change <= 5 then
                    ChatAnnouncements.guildSkillThrottle = ChatAnnouncements.guildSkillThrottle + change
                    ChatAnnouncements.guildSkillThrottleLine = formattedName
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
                    priority = "EXPERIENCE_LEVEL"
                else
                    priority = "MESSAGE"
                end
            end

            if lineId == 55 or lineId == 117 or lineId == 118 or lineId == 130 then
                -- Other guilds are usually either a quest reward or achievement reward
                priority = "EXPERIENCE_LEVEL"
            end
            ChatAnnouncements.PrintGuildRep(change, formattedName, lineId, priority)
        end
    end
end

-- Helper function to get the color for the Guild
local function GetGuildColor(lineId)
    local GUILD_SKILL_COLOR_TABLE =
    {
        [45] = ChatAnnouncements.Colors.SkillGuildColorizeFG,
        [44] = ChatAnnouncements.Colors.SkillGuildColorizeMG,
        [55] = ChatAnnouncements.Colors.SkillGuildColorizeUD,
        [117] = ChatAnnouncements.Colors.SkillGuildColorizeTG,
        [118] = ChatAnnouncements.Colors.SkillGuildColorizeDB,
        [130] = ChatAnnouncements.Colors.SkillGuildColorizePO,
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
function ChatAnnouncements.PrintGuildRep(change, lineName, lineId, priority)
    local icon = zo_iconFormatInheritColor(GUILD_SKILL_ICONS[lineId], 16, 16)
    local formattedIcon = ChatAnnouncements.SV.Skills.SkillGuildIcon and (icon .. " ") or ""

    local guildString = zo_strformat(ChatAnnouncements.SV.Skills.SkillGuildRepName, change)
    local colorize = GetGuildColor(lineId)
    local messageP1 = ("|r|c" .. colorize .. formattedIcon .. change .. " " .. lineName .. " " .. guildString .. "|r|c" .. ChatAnnouncements.Colors.SkillGuildColorize)
    local formattedMessageP1 = (string.format(ChatAnnouncements.SV.Skills.SkillGuildMsg, messageP1))
    local finalMessage = string.format("|c%s%s|r", ChatAnnouncements.Colors.SkillGuildColorize, formattedMessageP1)

    -- We set this to skill gain, so as to avoid creating an entire additional chat message category (we want it to show after XP but before any other skill gains or level up so we place it on top of the level up priority).
    ChatAnnouncements.QueuedMessages[ChatAnnouncements.QueuedMessagesCounter] =
    {
        message = finalMessage,
        messageType = priority
    }
    ChatAnnouncements.QueuedMessagesCounter = ChatAnnouncements.QueuedMessagesCounter + 1
    eventManager:RegisterForUpdate(moduleName .. "Printer", 50, ChatAnnouncements.PrintQueuedMessages)
end

-- Print Buffered Guild Rep Gain
function ChatAnnouncements.PrintBufferedGuildRep()
    if ChatAnnouncements.guildSkillThrottle > 0 and ChatAnnouncements.guildSkillThrottle > ChatAnnouncements.SV.Skills.SkillGuildThreshold then
        local lineId = 45
        local lineName = ChatAnnouncements.guildSkillThrottleLine
        ChatAnnouncements.PrintGuildRep(ChatAnnouncements.guildSkillThrottle, lineName, lineId, "EXPERIENCE_LEVEL")
    end
    eventManager:UnregisterForUpdate(moduleName .. "BufferedRep")
    ChatAnnouncements.guildSkillThrottle = 0
    ChatAnnouncements.guildSkillThrottleLine = ""
end

function ChatAnnouncements.RegisterXPEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_EXPERIENCE_GAIN)
    if ChatAnnouncements.SV.XP.Experience or ChatAnnouncements.SV.XP.ExperienceLevelUp then
        eventManager:RegisterForEvent(moduleName, EVENT_EXPERIENCE_GAIN, ChatAnnouncements.OnExperienceGain)
    end
end
