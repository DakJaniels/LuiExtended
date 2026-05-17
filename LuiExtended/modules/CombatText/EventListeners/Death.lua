-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) CombatTextDeathListener : LuiExtended.CombatTextEventListener
local CombatTextDeathListener = LUIE.CombatTextEventListener:Subclass()

local CombatText = LUIE.CombatText
local eventType = LuiData.Data.CombatTextConstants.eventType

function CombatTextDeathListener:Initialize()
    LUIE.CombatTextEventListener.Initialize(self)
    self:RegisterForEvent(EVENT_UNIT_DEATH_STATE_CHANGED, function (unitTag, isDead) self:OnEvent(unitTag, isDead) end, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end

--- @param unitTag string
--- @param isDead boolean
function CombatTextDeathListener:OnEvent(unitTag, isDead)
    if not LUIE.CombatText.SV.toggles.showDeath or not isDead then
        return
    end
    if AreUnitsEqual(unitTag, "player") then
        return
    end
    local toggles = LUIE.CombatText.SV.toggles
    if not CombatText.ResolveGroupDeathName(unitTag, toggles.useAccountNameForDeath) then
        return
    end
    self:TriggerEvent(eventType.DEATH, unitTag)
end

--- @class (partial) LuiExtended.CombatTextDeathListener : CombatTextDeathListener
LUIE.CombatTextDeathListener = CombatTextDeathListener:Subclass()
