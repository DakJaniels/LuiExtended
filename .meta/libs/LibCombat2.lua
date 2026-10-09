---@meta LibCombat2
-- Optional dependency. Console and gamecore LibCombat2, version 8.
-- PC uses LibCombat. The APIs are not the same.
--
-- Current registration is a dot call: `LibCombat2.RegisterForCombatEvent`.
-- Legacy wrappers are colon calls and drop the boolean.
-- At runtime, init.lua sets `LibCombat = LibCombat2` when `LibCombat` is nil.
-- This file does not copy that alias.
--
-- `LIBCOMBAT_EVENT_MIN`, `FIGHTRECAP`, `FIGHTSUMMARY`, `DEATHRECAP`, `UNITS`, and `MAX`
-- are declared in LibCombat.lua as platform unions.
-- Callbacks receive the event id first, then the payload.

---@alias LC2_HitCallback fun(eventType: integer, timeMs: integer, result: integer, sourceUnitId: integer, targetUnitId: integer, abilityId: integer, hitValue: number, damageType: integer, overflow: number)
---@alias LC2_SkillCastCallback fun(eventType: 8, timeMs: integer, reducedSlot: integer, abilityId: integer, skillStatus: integer, skillDelay: number, skillDuration: number)

---@type 1
LIBCOMBAT_LOG_EVENT_MIN = 1
--- `timeMs`, `combatMessage`, `value`.
---@type 1
LIBCOMBAT_LOG_EVENT_COMBATSTATE = 1
--- `timeMs`, `result`, `sourceUnitId`, `targetUnitId`, `abilityId`, `hitValue`, `damageType`, `overflow`.
---@type 2
LIBCOMBAT_LOG_EVENT_DAMAGE = 2
--- Same hit fields as `LIBCOMBAT_LOG_EVENT_DAMAGE`.
---@type 3
LIBCOMBAT_LOG_EVENT_HEAL = 3
--- `timeMs`, `unitId`, `abilityId`, `changeType`, `effectType`, `stacks`, `sourceType`, `effectSlot`.
---@type 4
LIBCOMBAT_LOG_EVENT_EFFECT = 4
--- `timeMs`, `statChange`, `newValue`, `statId`.
---@type 5
LIBCOMBAT_LOG_EVENT_STATS = 5
--- `timeMs`, `abilityId`, `powerValueChange`, `powerType`, `powerValue`.
---@type 6
LIBCOMBAT_LOG_EVENT_RESOURCE = 6
--- `timeMs`, `state`, `unitId`, `abilityId` or unit id.
---@type 7
LIBCOMBAT_LOG_EVENT_DEATH = 7
--- `timeMs`, `reducedSlot`, `abilityId`, `skillStatus`, `skillDelay`, `skillDuration`.
---@type 8
LIBCOMBAT_LOG_EVENT_SKILL_CAST = 8
--- `timeMs`, `avg`, `min`, `max`, `ping`.
---@type 9
LIBCOMBAT_LOG_EVENT_PERFORMANCE = 9
--- `timeMs`, `itemLink`.
---@type 10
LIBCOMBAT_LOG_EVENT_QUICKSLOT = 10
--- Same value as `QUICKSLOT`. The source alias names `LIBCOMBAT_LOG_EVENT_SYNERGY`, but that constant is not assigned.
---@type 10
LIBCOMBAT_LOG_EVENT_MAX = 10

---@type 1
LIBCOMBAT_UNIT_STATE_DEAD = 1
---@type 2
LIBCOMBAT_UNIT_STATE_ALIVE = 2
---@type 3
LIBCOMBAT_UNIT_STATE_RESURRECTING = 3
---@type 4
LIBCOMBAT_UNIT_STATE_RESURRECTED = 4

--- Same value as `LIBCOMBAT_SKILLSTATUS_QUEUE`.
---@type 6
LIBCOMBAT_SKILLSTATUS_CANCELLED = 6

--- Console combat event library. Version 8.
--- Fight events are `50`–`52`. Log lines are `LIBCOMBAT_LOG_EVENT_*`.
---@class LibCombat2
---@field version 8
---@field name "LibCombat2"
LibCombat2 = {}

--- Ends the current fight and starts a new one.
function LibCombat2.ResetFight() end

--- Unit id of the local player.
---@return integer unitId
function LibCombat2.GetPlayerUnitId() end

--- True when `unitId` is the local player.
---@param unitId integer
---@return boolean isPlayer
function LibCombat2.IsPlayerUnitId(unitId) end

--- True when the current fight is a boss fight.
---@return boolean isBossFight
function LibCombat2.IsCurrentFightBossFight() end

--- Seconds since the player entered combat.
---@return number combatDuration
function LibCombat2.GetCurrentFightDuration() end

--- Player and total damage to the main target, plus the time those numbers cover.
--- In a boss fight the main target is the bosses. Otherwise it is the unit with the most health or damage taken.
---@return number playerTime
---@return integer playerDamage
---@return number totalTime
---@return integer totalDamage
function LibCombat2.GetCurrentMainTargetDamageDone() end

--- Player and total damage to every non-friendly unit, plus the time those numbers cover.
---@return number playerTime
---@return integer playerDamage
---@return number totalTime
---@return integer totalDamage
function LibCombat2.GetCurrentTotalDamageDone() end

--- Player and group damage received, plus the time those numbers cover.
---@return number playerTime
---@return integer playerDamage
---@return number totalTime
---@return integer totalDamage
function LibCombat2.GetCurrentTotalDamageReceived() end

--- Registers every log event from `LIBCOMBAT_LOG_EVENT_MIN` through `MAX`.
--- Does not return the per-event boolean.
---@param name string Subscriber id. One callback per name and event type.
---@param callback fun(eventType: integer, ...)
function LibCombat2.RegisterForLogableCombatEvents(name, callback) end

--- Removes every log-event registration for `name`.
---@param name string
function LibCombat2.UnregisterForLogableCombatEvents(name) end

--- Listen for one log event or one fight event (`50`–`52`).
--- The callback is `fun(eventType, ...)`.
---@overload fun(name: string, callbacktype: 1, callback: fun(eventType: 1, timeMs: integer, combatMessage: integer, value: integer))
---@overload fun(name: string, callbacktype: 2, callback: LC2_HitCallback)
---@overload fun(name: string, callbacktype: 3, callback: LC2_HitCallback)
---@overload fun(name: string, callbacktype: 4, callback: fun(eventType: 4, timeMs: integer, unitId: integer, abilityId: integer, changeType: integer, effectType: integer, stacks: integer, sourceType: integer, effectSlot: integer))
---@overload fun(name: string, callbacktype: 5, callback: fun(eventType: 5, timeMs: integer, statChange: number, newValue: number, statId: integer))
---@overload fun(name: string, callbacktype: 6, callback: fun(eventType: 6, timeMs: integer, abilityId: integer, powerValueChange: number, powerType: integer, powerValue: number))
---@overload fun(name: string, callbacktype: 7, callback: fun(eventType: 7, timeMs: integer, state: integer, unitId: integer, abilityIdOrUnitId: integer))
---@overload fun(name: string, callbacktype: 8, callback: LC2_SkillCastCallback)
---@overload fun(name: string, callbacktype: 9, callback: fun(eventType: 9, timeMs: integer, avg: number, min: number, max: number, ping: number))
---@overload fun(name: string, callbacktype: 10, callback: fun(eventType: 10, timeMs: integer, itemLink: string))
---@overload fun(name: string, callbacktype: 50, callback: fun(eventType: 50, data: table))
---@overload fun(name: string, callbacktype: 51, callback: fun(eventType: 51, fight: table))
---@overload fun(name: string, callbacktype: 52, callback: fun(eventType: 52, timeMs: integer, data: table))
---@param name string Subscriber id.
---@param callbacktype integer `LIBCOMBAT_LOG_EVENT_*`, or a fight event `50`–`52`.
---@param callback fun(eventType: integer, ...)
---@return boolean registered False when this name is already registered for the type.
function LibCombat2.RegisterForCombatEvent(name, callbacktype, callback) end

--- Removes the subscriber for `name` and `callbacktype`.
---@param name string
---@param callbacktype integer
---@return boolean unregistered
function LibCombat2.UnregisterForCombatEvent(name, callbacktype) end

---@deprecated Use `RegisterForLogableCombatEvents`.
--- Forwards to `RegisterForLogableCombatEvents`. The return value is dropped.
---@param callback fun(eventType: integer, ...)
---@param name string
function LibCombat2:RegisterAllLogCallbacks(callback, name) end

---@deprecated Use `RegisterForCombatEvent`.
--- Forwards to `RegisterForCombatEvent`. The return value is dropped.
---@param callbacktype integer
---@param callback fun(eventType: integer, ...)
---@param name string
function LibCombat2:RegisterCallbackType(callbacktype, callback, name) end

---@deprecated Use `UnregisterForCombatEvent`.
--- Forwards to `UnregisterForCombatEvent`. `callback` is ignored. The return value is dropped.
---@param callbacktype integer
---@param callback function
---@param name string
function LibCombat2:UnregisterCallbackType(callbacktype, callback, name) end

--- Item link for a mapped food or drink buff. Nil when the ability id is not mapped.
---@param abilityId integer
---@return string? itemLink
function LibCombat2.GetFoodDrinkItemLinkFromAbilityId(abilityId) end

--- True when `abilityId` is a mundus stone buff.
---@param abilityId integer
---@return boolean isMundus
function LibCombat2.IsMundusBuff(abilityId) end

--- Cached formatted ability or scribed-script name. Empty string when `id` is nil.
---@param id integer|string|nil
---@param isScript? boolean
---@return string name
function LibCombat2.GetFormattedAbilityName(id, isScript) end

--- Cached formatted ability or scribed-script icon.
--- A string `id` is returned as-is. Nil uses the missing-icon path.
---@param id integer|string|nil
---@param isScript? boolean
---@return string texturePath
function LibCombat2.GetFormattedAbilityIcon(id, isScript) end

--- Adds custom ability names and icons.
--- Both arguments are generic-for iterators (`for id, value in names do`), not tables passed to `pairs`.
---@param names fun(): integer?, string?
---@param icons fun(): integer?, string?
function LibCombat2.AddCustomAbilityData(names, icons) end

--- Damage-type color prefix, such as `|cffff66`. Nil when `damageType` is not mapped.
--- The string keys `"heal"`, `"buff"`, `"debuff"`, and `"resource"` are also accepted.
---@param damageType integer|string
---@return string? colorPrefix
function LibCombat2.GetDamageColor(damageType) end

--- Formatted combat-log line. `logline[1]` is a `LIBCOMBAT_LOG_EVENT_*` value.
--- Nil `fight` uses the current fight. Some rows return nothing.
--- The damage and heal branches in the library test the same log type more than once.
---@param fight table?
---@param logline table
---@param fontsize number
---@param showIds boolean
---@return string? text
---@return number[]? color RGB multipliers.
function LibCombat2:GetCombatLogString(fight, logline, fontsize, showIds) end


