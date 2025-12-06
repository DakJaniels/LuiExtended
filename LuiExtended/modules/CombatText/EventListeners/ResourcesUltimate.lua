-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextResourcesUltimateEventListener : LuiExtended.CombatTextEventListener
local CombatTextResourcesUltimateEventListener = LUIE.CombatTextEventListener:Subclass()

--- @class (partial) LuiExtended.CombatTextResourcesUltimateEventListener
LUIE.CombatTextResourcesUltimateEventListener = CombatTextResourcesUltimateEventListener

local eventType = LuiData.Data.CombatTextConstants.eventType
local resourceType = LuiData.Data.CombatTextConstants.resourceType

function CombatTextResourcesUltimateEventListener:Initialize()
    LUIE.CombatTextEventListener.Initialize(self)
    self:RegisterForEvent(EVENT_POWER_UPDATE, function (...) self:OnEvent(...) end, REGISTER_FILTER_UNIT_TAG, "player", REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE)
    self:RegisterForEvent(EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function () self:UpdateMaximum() end)
    self:RegisterForEvent(EVENT_ACTION_SLOT_STATE_UPDATED, function () self:UpdateMaximum() end)
    self.powerInfo = { maximum = 0, wasNotified = false }
    self:UpdateMaximum()
end

function CombatTextResourcesUltimateEventListener:OnEvent(unit, powerPoolIndex, powerType, power, powerMax)
    local Settings = LUIE.CombatText.SV
    if power <= 0 or not Settings.toggles.showUltimate or self.powerInfo.maximum == 0 then
        return
    end

    -- Check if we need to show the notification
    if power >= self.powerInfo.maximum then
        if not self.powerInfo.wasNotified then
            self:TriggerEvent(eventType.RESOURCE, resourceType.ULTIMATE, power)
            self.powerInfo.wasNotified = true
        end
    else
        self.powerInfo.wasNotified = false
    end
end

function CombatTextResourcesUltimateEventListener:UpdateMaximum()
    self.powerInfo.maximum = GetSlotAbilityCost(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, COMBAT_MECHANIC_FLAGS_ULTIMATE, ZO_UtilityWheel_Shared:GetHotbarCategory())
end
