-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextPointsChampionEventListener : LuiExtended.CombatTextEventListener
local CombatTextPointsChampionEventListener = LUIE.CombatTextEventListener:Subclass()

--- @class (partial) LuiExtended.CombatTextPointsChampionEventListener
LUIE.CombatTextPointsChampionEventListener = CombatTextPointsChampionEventListener

local eventType = LuiData.Data.CombatTextConstants.eventType
local pointType = LuiData.Data.CombatTextConstants.pointType

local POINT_GAIN_MERGE_MS = 500

--- Champion bar size for the rank the player was filling before the latest gain.
--- `GetNumChampionXPInChampionPoint` is nil at the progression cap (`CPBarType:GetLevelSize`).
--- @param listener LuiExtended.CombatTextPointsChampionEventListener
local function RefreshChampionRankSize(listener)
    local earnedChampionPoints = GetPlayerChampionPointsEarned()
    listener.previousRankSize = GetNumChampionXPInChampionPoint(earnedChampionPoints)
end

--- `EVENT_EXPERIENCE_GAIN` reports previous and current experience on the same bar.
--- A rank-up can wrap so current is lower than previous. The filled bar is the size
--- stored before this event, not the rank integers from `EVENT_CHAMPION_POINT_UPDATE`.
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

--- @param listener LuiExtended.CombatTextPointsChampionEventListener
local function SchedulePointGain(listener)
    if listener.gain > 0 and not listener.timeoutActive then
        listener.timeoutActive = true
        zo_callLater(function ()
                         listener:TriggerEvent(eventType.POINT, pointType.CHAMPION_POINTS, listener.gain)
                         listener.gain = 0
                         listener.timeoutActive = false
                     end, POINT_GAIN_MERGE_MS)
    end
end

function CombatTextPointsChampionEventListener:Initialize()
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
function CombatTextPointsChampionEventListener:OnExperienceGain(reason, level, previousExperience, currentExperience, championPoints)
    if not CanUnitGainChampionPoints("player") then
        return
    end
    -- Nil means this rank has no champion bar (progression cap), same as CPBarType:GetLevelSize.
    if GetNumChampionXPInChampionPoint(championPoints) == nil then
        return
    end

    local gainDelta = GetExperienceGain(previousExperience, currentExperience, self.previousRankSize)
    RefreshChampionRankSize(self)

    if not LUIE.CombatText.SV.toggles.showPointsChampion then
        return
    end

    if gainDelta > 0 then
        self.gain = self.gain + gainDelta
    end

    SchedulePointGain(self)
end
