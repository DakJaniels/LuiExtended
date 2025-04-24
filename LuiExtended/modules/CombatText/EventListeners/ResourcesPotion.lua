-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
LUIE.CombatTextResourcesPotionEventListener = LUIE.CombatTextEventListener:Subclass()
local CombatTextResourcesPotionEventListener = LUIE.CombatTextResourcesPotionEventListener

local eventType = LuiData.Data.CombatTextConstants.eventType
local resourceType = LuiData.Data.CombatTextConstants.resourceType

local inCooldown = false
--- @diagnostic disable-next-line: duplicate-set-field
function CombatTextResourcesPotionEventListener:New()
    local obj = LUIE.CombatTextEventListener:New()
    obj:RegisterForUpdate("PotionCooldown", 100, function ()
        self:PotionCooldown()
    end)
    return obj
end

function CombatTextResourcesPotionEventListener:PotionCooldown(slotNum)
    local Settings = LUIE.CombatText.SV
    if not Settings.toggles.showPotionReady then
        return
    end

    local slotIndex = GetCurrentQuickslot()
    if GetSlotItemSound(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL) == ITEM_SOUND_CATEGORY_POTION then
        local _, duration = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local isInCooldown = duration > 0

        if isInCooldown then
            if inCooldown == false and duration > 5000 then
                inCooldown = true
            end
        else
            if inCooldown == true then
                local slotName = zo_strformat(SI_LINK_FORMAT_ITEM_NAME, GetSlotName(slotNum, HOTBAR_CATEGORY_QUICKSLOT_WHEEL))
                self:TriggerEvent(eventType.RESOURCE, resourceType.POTION, slotName)
                inCooldown = false
            end
        end
    end
end
