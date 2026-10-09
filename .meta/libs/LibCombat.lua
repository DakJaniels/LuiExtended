---@meta LibCombat
-- Optional dependency. PC LibCombat.lua, version 89.
-- Console uses LibCombat2. The APIs are not the same.
--
-- Shared event names that differ by platform are unions here.
-- LibCombat2.lua does not assign them again.
-- Callbacks receive the event id first, then the payload.

---@alias LC_HitCallback fun(eventType: integer, timems: integer, result: integer, sourceUnitId: integer, targetUnitId: integer, abilityId: integer, hitValue: number, damageType: integer, overflow: number)
---@alias LC_EffectCallback fun(eventType: integer, timems: integer, unitId: integer, abilityId: integer, changeType: integer, effectType: integer, stacks: integer, sourceType: integer, effectSlot: integer)
---@alias LC_StatCallback fun(eventType: integer, timems: integer, statChange: number, newValue: number, statId: integer)
---@alias LC_SkillTimingsCallback fun(eventType: 19, timems: integer, reducedSlot: integer, abilityId: integer, skillStatus: integer, skillDelay: number, skillDuration: number)

--- PC 0. Console 50.
---@type 0|50
LIBCOMBAT_EVENT_MIN = 0
--- Both platforms use 0. Console marks this deprecated.
---@type 0
LIBCOMBAT_EVENT_UNITS = 0
--- PC 1, payload `{ data }`. Console 50, same payload.
---@type 1|50
LIBCOMBAT_EVENT_FIGHTRECAP = 1
--- PC 2, payload `{ fight }`. Console 51, same payload.
---@type 2|51
LIBCOMBAT_EVENT_FIGHTSUMMARY = 2
--- PC only. `groupDPSOut`, `groupDPSIn`, `groupHPS`, `dpstime`, `hpstime`.
---@type 3
LIBCOMBAT_EVENT_GROUPRECAP = 3
---@type 4
LIBCOMBAT_EVENT_DAMAGE_OUT = 4
---@type 5
LIBCOMBAT_EVENT_DAMAGE_IN = 5
---@type 6
LIBCOMBAT_EVENT_DAMAGE_SELF = 6
---@type 7
LIBCOMBAT_EVENT_HEAL_OUT = 7
---@type 8
LIBCOMBAT_EVENT_HEAL_IN = 8
---@type 9
LIBCOMBAT_EVENT_HEAL_SELF = 9
---@type 10
LIBCOMBAT_EVENT_EFFECTS_IN = 10
---@type 11
LIBCOMBAT_EVENT_EFFECTS_OUT = 11
---@type 12
LIBCOMBAT_EVENT_GROUPEFFECTS_IN = 12
---@type 13
LIBCOMBAT_EVENT_GROUPEFFECTS_OUT = 13
---@type 14
LIBCOMBAT_EVENT_PLAYERSTATS = 14
---@type 15
LIBCOMBAT_EVENT_RESOURCES = 15
---@type 16
LIBCOMBAT_EVENT_MESSAGES = 16
---@type 17
LIBCOMBAT_EVENT_DEATH = 17
---@type 18
LIBCOMBAT_EVENT_PLAYERSTATS_ADVANCED = 18
---@type 19
LIBCOMBAT_EVENT_SKILL_TIMINGS = 19
---@type 20
LIBCOMBAT_EVENT_BOSSHP = 20
---@type 21
LIBCOMBAT_EVENT_PERFORMANCE = 21
--- PC 22, payload `timems, { data }`. Console 52, same payload.
---@type 22|52
LIBCOMBAT_EVENT_DEATHRECAP = 22
---@type 23
LIBCOMBAT_EVENT_QUICKSLOT = 23
---@type 24
LIBCOMBAT_EVENT_SYNERGY = 24
--- PC 24. Console 52.
---@type 24|52
LIBCOMBAT_EVENT_MAX = 24

---@type 1
LIBCOMBAT_STATE_DEAD = 1
---@type 2
LIBCOMBAT_STATE_ALIVE = 2
---@type 3
LIBCOMBAT_STATE_RESURRECTING = 3
---@type 4
LIBCOMBAT_STATE_RESURRECTED = 4

---@type 1
LIBCOMBAT_MESSAGE_COMBATSTART = 1
---@type 2
LIBCOMBAT_MESSAGE_COMBATEND = 2
---@type 3
LIBCOMBAT_MESSAGE_WEAPONSWAP = 3

---@type 1
LIBCOMBAT_SKILLSTATUS_INSTANT = 1
---@type 2
LIBCOMBAT_SKILLSTATUS_BEGIN_DURATION = 2
---@type 3
LIBCOMBAT_SKILLSTATUS_BEGIN_CHANNEL = 3
---@type 4
LIBCOMBAT_SKILLSTATUS_SUCCESS = 4
---@type 5
LIBCOMBAT_SKILLSTATUS_REGISTERED = 5
---@type 6
LIBCOMBAT_SKILLSTATUS_QUEUE = 6

---@type 1
LIBCOMBAT_STAT_MAXMAGICKA = 1
---@type 2
LIBCOMBAT_STAT_SPELLPOWER = 2
---@type 3
LIBCOMBAT_STAT_SPELLCRIT = 3
---@type 4
LIBCOMBAT_STAT_SPELLCRITBONUS = 4
---@type 5
LIBCOMBAT_STAT_SPELLPENETRATION = 5
---@type 11
LIBCOMBAT_STAT_MAXSTAMINA = 11
---@type 12
LIBCOMBAT_STAT_WEAPONPOWER = 12
---@type 13
LIBCOMBAT_STAT_WEAPONCRIT = 13
---@type 14
LIBCOMBAT_STAT_WEAPONCRITBONUS = 14
---@type 15
LIBCOMBAT_STAT_WEAPONPENETRATION = 15
---@type 21
LIBCOMBAT_STAT_MAXHEALTH = 21
---@type 22
LIBCOMBAT_STAT_PHYSICALRESISTANCE = 22
---@type 23
LIBCOMBAT_STAT_SPELLRESISTANCE = 23
---@type 24
LIBCOMBAT_STAT_CRITICALRESISTANCE = 24
---@type 25
LIBCOMBAT_STAT_STATUS_EFFECT_CHANCE = 25

---@type 0
LIBCOMBAT_CPTYPE_PASSIVE = 0
---@type 1
LIBCOMBAT_CPTYPE_UNSLOTTED = 1
---@type 2
LIBCOMBAT_CPTYPE_SLOTTED = 2

--- UI line width scale from `GuiRoot` and the `WindowedWidth` cvar. PC only.
---@type number
LIBCOMBAT_LINE_SIZE = 0

--- Initial fields are `skillBars` and `scribedSkills`. Load adds more tracking fields.
---@class LC_LibraryData
---@field skillBars table
---@field scribedSkills table

--- PC combat event library. Methods that use `:` take `self`.
--- `RegisterForCombatEvent` returns false when `name` is already registered for that type.
---@class LibCombat
---@field version 89
---@field name "LibCombat"
---@field data LC_LibraryData
---@field cm ZO_CallbackObject
---@field debug boolean
---@field ActiveCallbackTypes table<integer, table<string, function>>
---@field registeredSkills table
---@field MundusStones table<integer, boolean> Ability ids flagged as mundus stones.
LibCombat = {}

--- Registers `DAMAGE_OUT` through `MAX`. Does not return the per-event boolean.
---@param name string Subscriber id. One callback per name and event type.
---@param callback fun(eventType: integer, ...)
function LibCombat:RegisterForLogableCombatEvents(name, callback) end

--- Listen for one `LIBCOMBAT_EVENT_*` type.
--- The callback is `fun(eventType, ...)`.
---@overload fun(self: LibCombat, name: string, callbacktype: 0, callback: fun(eventType: 0, units: table))
---@overload fun(self: LibCombat, name: string, callbacktype: 1, callback: fun(eventType: 1, data: table))
---@overload fun(self: LibCombat, name: string, callbacktype: 2, callback: fun(eventType: 2, fight: table))
---@overload fun(self: LibCombat, name: string, callbacktype: 3, callback: fun(eventType: 3, groupDPSOut: number, groupDPSIn: number, groupHPS: number, dpstime: number, hpstime: number))
---@overload fun(self: LibCombat, name: string, callbacktype: 4, callback: LC_HitCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 5, callback: LC_HitCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 6, callback: LC_HitCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 7, callback: LC_HitCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 8, callback: LC_HitCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 9, callback: LC_HitCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 10, callback: LC_EffectCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 11, callback: LC_EffectCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 12, callback: LC_EffectCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 13, callback: LC_EffectCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 14, callback: LC_StatCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 15, callback: fun(eventType: 15, timems: integer, abilityId: integer, powerValueChange: number, powerType: integer, powerValue: number))
---@overload fun(self: LibCombat, name: string, callbacktype: 16, callback: fun(eventType: 16, timems: integer, combatMessage: integer, value: integer))
---@overload fun(self: LibCombat, name: string, callbacktype: 17, callback: fun(eventType: 17, timems: integer, state: integer, unitId: integer, abilityIdOrUnitId: integer))
---@overload fun(self: LibCombat, name: string, callbacktype: 18, callback: LC_StatCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 19, callback: LC_SkillTimingsCallback)
---@overload fun(self: LibCombat, name: string, callbacktype: 20, callback: fun(eventType: 20, timems: integer, bossId: integer, currentHp: number, maxHp: number))
---@overload fun(self: LibCombat, name: string, callbacktype: 21, callback: fun(eventType: 21, timems: integer, avg: number, min: number, max: number, ping: number))
---@overload fun(self: LibCombat, name: string, callbacktype: 22, callback: fun(eventType: 22, timems: integer, data: table))
---@overload fun(self: LibCombat, name: string, callbacktype: 23, callback: fun(eventType: 23, timems: integer, itemLink: string))
---@overload fun(self: LibCombat, name: string, callbacktype: 24, callback: fun(eventType: 24, timems: integer, abilityId: integer, status: integer))
---@param name string Subscriber id.
---@param callbacktype integer One of `LIBCOMBAT_EVENT_*`.
---@param callback fun(eventType: integer, ...)
---@return boolean registered False when this name is already registered for the type.
function LibCombat:RegisterForCombatEvent(name, callbacktype, callback) end

--- Removes the subscriber for `name` and `callbacktype`.
---@param name string Subscriber id passed to `RegisterForCombatEvent`.
---@param callbacktype integer
---@return boolean unregistered
function LibCombat:UnregisterForCombatEvent(name, callbacktype) end

---@deprecated Use `RegisterForLogableCombatEvents`.
--- Forwards to `RegisterForLogableCombatEvents`. The return value is dropped.
---@param callback fun(eventType: integer, ...)
---@param name string
function LibCombat:RegisterAllLogCallbacks(callback, name) end

---@deprecated Use `RegisterForCombatEvent`.
--- Forwards to `RegisterForCombatEvent`. The return value is dropped.
---@param callbacktype integer
---@param callback fun(eventType: integer, ...)
---@param name string
function LibCombat:RegisterCallbackType(callbacktype, callback, name) end

---@deprecated Use `UnregisterForCombatEvent`.
--- Forwards to `UnregisterForCombatEvent`. `callback` is ignored. The return value is dropped.
---@param callbacktype integer
---@param callback function
---@param name string
function LibCombat:UnregisterCallbackType(callbacktype, callback, name) end

--- Deep copy of the current fight when `dpsstart` is set.
---@return table? fight
function LibCombat:GetCurrentFight() end

--- Ends the current fight and starts a new one.
function LibCombat.ResetFight() end

--- Cached formatted ability or scribed-script name. Empty string when `id` is nil.
---@param id integer|string|nil
---@param isScript? boolean
---@return string name
function LibCombat.GetFormattedAbilityName(id, isScript) end

--- Cached formatted ability or scribed-script icon.
--- A string `id` is returned as-is. Nil uses the missing-icon path.
---@param id integer|string|nil
---@param isScript? boolean
---@return string texturePath
function LibCombat.GetFormattedAbilityIcon(id, isScript) end

--- Damage-type color prefix, such as `|cffff66`. Nil when `damageType` is not mapped.
--- The string keys `"heal"`, `"buff"`, `"debuff"`, and `"resource"` are also accepted.
---@param damageType integer|string
---@return string? colorPrefix
function LibCombat.GetDamageColor(damageType) end

--- Formatted combat-log line. `logline[1]` is the event type.
--- Some event types return nothing when the row is incomplete.
---@param fight table? Fight from `FIGHTSUMMARY` or `GetCurrentFight`. Nil uses the current fight.
---@param logline table Log row. Index 1 is the event type. Combat-log rows start at 4.
---@param fontsize number
---@param showIds boolean
---@return string? text
---@return number[]? color RGB multipliers, for example `{ 0.7, 0.7, 0.7 }`.
function LibCombat:GetCombatLogString(fight, logline, fontsize, showIds) end

--- Item link for a mapped food or drink buff. Nil when the ability id is not mapped.
---@param abilityId integer
---@return string? itemLink
function LibCombat.GetFoodDrinkItemLinkFromAbilityId(abilityId) end

--- Ability id to buff or debuff type, filled from combat events.
---@return table<integer, integer> abilityTypes
function LibCombat.GetCustomAbilityList() end


