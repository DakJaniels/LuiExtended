-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextPointsExperienceEventListener : LuiExtended.CombatTextEventListener
local CombatTextPointsExperienceEventListener = LUIE.CombatTextEventListener:Subclass()

--- @class (partial) LuiExtended.CombatTextPointsExperienceEventListener
LUIE.CombatTextPointsExperienceEventListener = CombatTextPointsExperienceEventListener

local eventType = LuiData.Data.CombatTextConstants.eventType
local pointType = LuiData.Data.CombatTextConstants.pointType

local POINT_GAIN_MERGE_MS = 500

--- @param listener LuiExtended.CombatTextPointsExperienceEventListener
local function RefreshChampionRankSize(listener)
    local earnedChampionPoints = GetPlayerChampionPointsEarned()
    listener.previousRankSize = GetNumChampionXPInChampionPoint(earnedChampionPoints)
end

--- Same-bar delta from `EVENT_EXPERIENCE_GAIN`. Wrap only when current drops below previous.
--- Character levels use `GetNumExperiencePointsInLevel`. Champion ranks use the size stored
--- before this event. Do not add the bar size when current is already past the old value.
--- @param previousExperience integer
--- @param currentExperience integer
--- @param rankSize integer|nil
--- @return integer
local function GetExperienceGain(previousExperience, currentExperience, rankSize)
    if currentExperience >= previousExperience then
        return currentExperience - previousExperience
    end
    if rankSize == nil then
        return 0
    end
    return (rankSize - previousExperience) + currentExperience
end

--- Champion experience uses the same gate as the player progress bar:
--- `CanUnitGainChampionPoints` and a non-nil `GetNumChampionXPInChampionPoint`.
--- @param championPoints integer
--- @return boolean
local function IsChampionExperienceGain(championPoints)
    if not CanUnitGainChampionPoints("player") then
        return false
    end
    return GetNumChampionXPInChampionPoint(championPoints) ~= nil
end

--- @param listener LuiExtended.CombatTextPointsExperienceEventListener
local function SchedulePointGain(listener)
    if listener.gain > 0 and not listener.timeoutActive then
        listener.timeoutActive = true
        zo_callLater(function ()
                         listener:TriggerEvent(eventType.POINT, pointType.EXPERIENCE_POINTS, listener.gain)
                         listener.gain = 0
                         listener.timeoutActive = false
                     end, POINT_GAIN_MERGE_MS)
    end
end

function CombatTextPointsExperienceEventListener:Initialize()
    LUIE.CombatTextEventListener.Initialize(self)
    self:RegisterForEvent(EVENT_EXPERIENCE_GAIN, function (reason, level, previousExperience, currentExperience, championPoints)
        self:OnExperienceGain(reason, level, previousExperience, currentExperience, championPoints)
    end)
    self:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function ()
        RefreshChampionRankSize(self)
    end)
    self.gain = 0
    self.timeoutActive = false
    self.previousRankSize = nil
    RefreshChampionRankSize(self)
end

--- @param reason ProgressReason
--- @param level integer
--- @param previousExperience integer
--- @param currentExperience integer
--- @param championPoints integer
function CombatTextPointsExperienceEventListener:OnExperienceGain(reason, level, previousExperience, currentExperience, championPoints)
    local gainDelta
    if IsChampionExperienceGain(championPoints) then
        gainDelta = GetExperienceGain(previousExperience, currentExperience, self.previousRankSize)
        RefreshChampionRankSize(self)
        -- Champion toggle owns this gain so both toggles do not print the same award.
        if LUIE.CombatText.SV.toggles.showPointsChampion or not LUIE.CombatText.SV.toggles.showPointsExperience then
            return
        end
    else
        if not LUIE.CombatText.SV.toggles.showPointsExperience then
            return
        end
        local levelSize = nil
        if currentExperience < previousExperience then
            levelSize = GetNumExperiencePointsInLevel(level)
        end
        gainDelta = GetExperienceGain(previousExperience, currentExperience, levelSize)
    end

    if gainDelta > 0 then
        self.gain = self.gain + gainDelta
    end

    SchedulePointGain(self)
end
