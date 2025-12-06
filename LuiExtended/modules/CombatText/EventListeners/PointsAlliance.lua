-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextPointsAllianceEventListener : LuiExtended.CombatTextEventListener
local CombatTextPointsAllianceEventListener = LUIE.CombatTextEventListener:Subclass()

--- @class (partial) LuiExtended.CombatTextPointsAllianceEventListener
LUIE.CombatTextPointsAllianceEventListener = CombatTextPointsAllianceEventListener

local eventType = LuiData.Data.CombatTextConstants.eventType
local pointType = LuiData.Data.CombatTextConstants.pointType

function CombatTextPointsAllianceEventListener:Initialize()
    LUIE.CombatTextEventListener.Initialize(self)
    self:RegisterForEvent(EVENT_ALLIANCE_POINT_UPDATE, function (...) self:OnEvent(...) end)
end

function CombatTextPointsAllianceEventListener:OnEvent(alliancePoints, playSound, difference)
    if LUIE.CombatText.SV.toggles.showPointsAlliance then
        self:TriggerEvent(eventType.POINT, pointType.ALLIANCE_POINTS, difference)
    end
end
