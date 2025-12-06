-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

---@class LuiExtended
local LUIE = LUIE
--- @class (partial) LuiExtended.CombatTextDeathListener : LuiExtended.CombatTextEventListener
LUIE.CombatTextDeathListener = LUIE.CombatTextEventListener:Subclass()
--- @class (partial) LuiExtended.CombatTextDeathListener
local CombatTextDeathListener = LUIE.CombatTextDeathListener

local eventType = LuiData.Data.CombatTextConstants.eventType

function CombatTextDeathListener:New()
    local obj = LUIE.CombatTextEventListener:New()
    obj:RegisterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED, function (...)
                             self:OnEvent(...)
                         end, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
    return obj
end

function CombatTextDeathListener:OnEvent(unitTag, isDead)
    if LUIE.CombatText.SV.toggles.showDeath then
        if isDead and "group" == zo_strsub(unitTag, 0, 5) then -- when group member dies
            if GetUnitName(unitTag) ~= GetUnitName("player") then
                self:TriggerEvent(eventType.DEATH, unitTag)
            end
        end
    end
end
