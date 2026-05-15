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

function CombatTextPointsChampionEventListener:Initialize()
    LUIE.CombatTextEventListener.Initialize(self)
    self:RegisterForEvent(EVENT_CHAMPION_POINT_UPDATE, function (unitTag, oldChampionPoints, currentChampionPoints) self:OnEvent(unitTag, oldChampionPoints, currentChampionPoints) end, REGISTER_FILTER_UNIT_TAG, "player")
    self.gain = 0
    self.timeoutActive = false
    self.previousCP = GetUnitChampionPoints("player")
    self.hasMaxCP = not CanUnitGainChampionPoints("player")
end

--- @param unitTag string
--- @param oldChampionPoints integer
--- @param currentChampionPoints integer
function CombatTextPointsChampionEventListener:OnEvent(unitTag, oldChampionPoints, currentChampionPoints)
    if LUIE.CombatText.SV.toggles.showPointsChampion and not self.hasMaxCP then
        local currentCP = GetUnitChampionPoints(unitTag)
        local gainDelta
        if currentCP == self.previousCP then
            gainDelta = currentChampionPoints - oldChampionPoints
        elseif currentCP > self.previousCP then
            local maxForOldRank = GetNumChampionXPInChampionPoint(self.previousCP)
            gainDelta = (maxForOldRank - oldChampionPoints) + currentChampionPoints
        else
            gainDelta = currentChampionPoints - oldChampionPoints
        end

        if gainDelta > 0 then
            self.gain = self.gain + gainDelta
        end

        self.previousCP = currentCP
        self.hasMaxCP = self.hasMaxCP or not CanUnitGainChampionPoints(unitTag)

        -- Trigger custom event (500ms buffer)
        if self.gain > 0 and not self.timeoutActive then
            self.timeoutActive = true
            zo_callLater(function ()
                             self:TriggerEvent(eventType.POINT, pointType.CHAMPION_POINTS, self.gain)
                             self.gain = 0
                             self.timeoutActive = false
                         end, 500)
        end
    end
end
