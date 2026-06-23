-- -----------------------------------------------------------------------------
--  LuiExtended — ActionBar combat event registration (loaded after ActionBar.lua)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

--- Register one filtered EVENT_COMBAT_EVENT handler for bar highlights; tracks name for unregister.
--- Remaining arguments after eventName are passed to AddFilterForEvent (filter type/value pairs).
--- @param eventManager EventManager 
--- @param eventNamesList string[]
--- @param eventName string
--- @param ... RegisterForEventFilterVararg varargs passed to AddFilterForEvent
function ActionBar.RegisterBarCombatEvent(eventManager, eventNamesList, eventName, ...)
    eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function (_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, combatAbilityId, overflow)
        ActionBar.OnCombatEventBar(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, combatAbilityId, overflow)
    end)
    eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, ...)
    eventNamesList[#eventNamesList + 1] = eventName
end
