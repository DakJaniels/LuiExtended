-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) CombatTextDeathListener : LuiExtended.CombatTextEventListener
local CombatTextDeathListener = LUIE.CombatTextEventListener:Subclass()

local eventType = LuiData.Data.CombatTextConstants.eventType

function CombatTextDeathListener:Initialize()
    LUIE.CombatTextEventListener.Initialize(self)
    self:RegisterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED, function (unitTag, isDead) self:OnEvent(unitTag, isDead) end, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

--- @param unitTag string
--- @param isDead boolean
function CombatTextDeathListener:OnEvent(unitTag, isDead)
    if LUIE.CombatText.SV.toggles.showDeath then
        if isDead and "group" == zo_strsub(unitTag, 0, 5) then -- when group member dies
            if GetUnitName(unitTag) ~= GetUnitName("player") then
                self:TriggerEvent(eventType.DEATH, unitTag)
            end
        end
    end
end

--- @class (partial) LuiExtended.CombatTextDeathListener : CombatTextDeathListener
LUIE.CombatTextDeathListener = CombatTextDeathListener:Subclass()
