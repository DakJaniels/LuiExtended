-- -----------------------------------------------------------------------------
--  LuiExtended — Chat Announcements CSA / progress bar helpers
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.ChatAnnouncements
local ChatAnnouncements = LUIE.ChatAnnouncements

local Internal = ChatAnnouncements.Internal

local string_format = string.format

-- EVENT_SKILL_XP CSA hooks
--- @type table<integer, boolean>
ChatAnnouncements.GUILD_SKILL_SHOW_REASONS =
{
    [PROGRESS_REASON_DARK_ANCHOR_CLOSED] = true,
    [PROGRESS_REASON_DARK_FISSURE_CLOSED] = true,
    [PROGRESS_REASON_BOSS_KILL] = true,
}

--- @type table<integer, integer>
ChatAnnouncements.GUILD_SKILL_SHOW_SOUNDS =
{
    [PROGRESS_REASON_DARK_ANCHOR_CLOSED] = SOUNDS.SKILL_XP_DARK_ANCHOR_CLOSED,
    [PROGRESS_REASON_DARK_FISSURE_CLOSED] = SOUNDS.SKILL_XP_DARK_FISSURE_CLOSED,
    [PROGRESS_REASON_BOSS_KILL] = SOUNDS.SKILL_XP_BOSS_KILLED,
}

-- EVENT_SKILL_POINTS_CHANGED (CSA Handler)
--- @type table<integer, boolean>
ChatAnnouncements.SUPPRESS_SKILL_POINT_CSA_REASONS =
{
    [SKILL_POINT_CHANGE_REASON_IGNORE] = true,
    [SKILL_POINT_CHANGE_REASON_SKILL_RESPEC] = true,
    [SKILL_POINT_CHANGE_REASON_SKILL_RESET] = true,
}

--- @param barParams CenterScreenPlayerProgressBarParams
--- @return nil
function Internal.ValidateProgressBarParams(barParams)
    local barType = barParams:GetParams()
    if not (barType and PLAYER_PROGRESS_BAR:GetBarTypeInfoByBarType(barType)) then
        local INVALID_VALUE = -1
        assert(false, string_format("CSAH Bad Bar Params; barType: %d. Triggering Event: %d.", barType or INVALID_VALUE, barParams:GetTriggeringEvent() or INVALID_VALUE))
    end
end

--- @param level integer
--- @param previousExperience integer
--- @param currentExperience integer
--- @param championPoints integer
--- @param triggeringEvent integer
--- @return CenterScreenPlayerProgressBarParams|nil
function Internal.GetRelevantBarParams(level, previousExperience, currentExperience, championPoints, triggeringEvent)
    local championXpToNextPoint
    if CanUnitGainChampionPoints("player") then
        championXpToNextPoint = GetNumChampionXPInChampionPoint(championPoints)
    end
    if championXpToNextPoint ~= nil and currentExperience > previousExperience then
        local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, previousExperience, currentExperience)
        barParams:SetTriggeringEvent(triggeringEvent)
        return barParams
    else
        local levelSize = GetNumExperiencePointsInLevel(level)
        if levelSize ~= nil and currentExperience > previousExperience then
            local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_XP, level, previousExperience, currentExperience)
            barParams:SetTriggeringEvent(triggeringEvent)
            return barParams
        end
    end
end

--- @param triggeringEvent integer
--- @return CenterScreenPlayerProgressBarParams
function Internal.GetCurrentChampionPointsBarParams(triggeringEvent)
    local championPoints = GetPlayerChampionPointsEarned()
    local currentChampionXP = GetPlayerChampionXP()
    local barParams = CENTER_SCREEN_ANNOUNCE:CreateBarParams(PPB_CP, championPoints, currentChampionXP, currentChampionXP)
    barParams:SetShowNoGain(true)
    barParams:SetTriggeringEvent(triggeringEvent)
    return barParams
end
