-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
LUIE.CombatTextResourcesPowerEventListener = LUIE.CombatTextEventListener:Subclass()
local CombatTextResourcesPowerEventListener = LUIE.CombatTextResourcesPowerEventListener

local eventType = LuiData.Data.CombatTextConstants.eventType
local resourceType = LuiData.Data.CombatTextConstants.resourceType
--- @diagnostic disable-next-line: duplicate-set-field
function CombatTextResourcesPowerEventListener:New()
    local obj = LUIE.CombatTextEventListener:New()
    obj:RegisterForEvent(EVENT_POWER_UPDATE, function (...)
        self:OnEvent(...)
    end)
    self.powerInfo =
    {
        [COMBAT_MECHANIC_FLAGS_HEALTH] = { wasWarned = false, resourceType = resourceType.LOW_HEALTH },
        [COMBAT_MECHANIC_FLAGS_STAMINA] = { wasWarned = false, resourceType = resourceType.LOW_STAMINA },
        [COMBAT_MECHANIC_FLAGS_MAGICKA] = { wasWarned = false, resourceType = resourceType.LOW_MAGICKA },
    }
    return obj
end

function CombatTextResourcesPowerEventListener:OnEvent(unit, powerPoolIndex, powerType, power, powerMax)
    if unit == "player" and self.powerInfo[powerType] ~= nil then
        local Settings = LUIE.CombatText.SV
        local threshold

        if power <= 0 then
            return
        elseif powerType == COMBAT_MECHANIC_FLAGS_HEALTH then
            if not Settings.toggles.showLowHealth then
                return
            end
            threshold = Settings.healthThreshold or 35
        elseif powerType == COMBAT_MECHANIC_FLAGS_STAMINA then
            if not Settings.toggles.showLowStamina then
                return
            end
            threshold = Settings.staminaThreshold or 35
        elseif powerType == COMBAT_MECHANIC_FLAGS_MAGICKA then
            if not Settings.toggles.showLowMagicka then
                return
            end
            threshold = Settings.magickaThreshold or 35
        end

        local percent = power / powerMax * 100

        -- Check if we need to show the warning, else clear the warning
        if percent < threshold and not self.powerInfo[powerType].wasWarned then
            self:TriggerEvent(eventType.RESOURCE, self.powerInfo[powerType].resourceType, power)
            self.powerInfo[powerType].wasWarned = true
        elseif percent > threshold + 10 then -- Add 10 to create some sort of buffer, else the warning can fire more than once depending on the power regen of the player
            self.powerInfo[powerType].wasWarned = false
        end
    end
end
