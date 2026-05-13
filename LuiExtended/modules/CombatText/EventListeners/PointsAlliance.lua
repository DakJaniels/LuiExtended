-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) CombatTextPointsAllianceEventListener : LuiExtended.CombatTextEventListener
local CombatTextPointsAllianceEventListener = LUIE.CombatTextEventListener:Subclass()

local eventType = LuiData.Data.CombatTextConstants.eventType
local pointType = LuiData.Data.CombatTextConstants.pointType

function CombatTextPointsAllianceEventListener:Initialize()
    LUIE.CombatTextEventListener.Initialize(self)
    self:RegisterForEvent(EVENT_ALLIANCE_POINT_UPDATE, function (alliancePoints, playSound, difference, reason, reasonSupplementaryInfo) self:OnEvent(alliancePoints, playSound, difference, reason, reasonSupplementaryInfo) end)
end

--- @param alliancePoints integer
--- @param playSound boolean
--- @param difference integer
--- @param reason CurrencyChangeReason
--- @param reasonSupplementaryInfo integer
function CombatTextPointsAllianceEventListener:OnEvent(alliancePoints, playSound, difference, reason, reasonSupplementaryInfo)
    if LUIE.CombatText.SV.toggles.showPointsAlliance then
        self:TriggerEvent(eventType.POINT, pointType.ALLIANCE_POINTS, difference)
    end
end

--- @class (partial) LuiExtended.CombatTextPointsAllianceEventListener : CombatTextPointsAllianceEventListener
LUIE.CombatTextPointsAllianceEventListener = CombatTextPointsAllianceEventListener:Subclass()
