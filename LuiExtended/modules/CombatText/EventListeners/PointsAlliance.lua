-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

---@class LuiExtended
local LUIE = LUIE
--- @class (partial) LuiExtended.CombatTextPointsAllianceEventListener : LuiExtended.CombatTextEventListener
LUIE.CombatTextPointsAllianceEventListener = LUIE.CombatTextEventListener:Subclass()
--- @class (partial) LuiExtended.CombatTextPointsAllianceEventListener
local CombatTextPointsAllianceEventListener = LUIE.CombatTextPointsAllianceEventListener

local eventType = LuiData.Data.CombatTextConstants.eventType
local pointType = LuiData.Data.CombatTextConstants.pointType

function CombatTextPointsAllianceEventListener:New()
    local obj = LUIE.CombatTextEventListener:New()
    obj:RegisterForEvent(EVENT_ALLIANCE_POINT_UPDATE, function (...)
        self:OnEvent(...)
    end)
    return obj
end

function CombatTextPointsAllianceEventListener:OnEvent(alliancePoints, playSound, difference)
    if LUIE.CombatText.SV.toggles.showPointsAlliance then
        self:TriggerEvent(eventType.POINT, pointType.ALLIANCE_POINTS, difference)
    end
end
