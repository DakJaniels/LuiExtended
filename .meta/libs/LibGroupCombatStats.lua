---@meta LibGroupCombatStats
-- Optional dependency (LibGroupCombatStats.lua, version 2026-10-04).
-- Types for LuiExtended IDE checks only. Public surface is the doc.lua blocks
-- in the live library. Return types follow the implementations.

---@alias LGCS_StatName
---| "DPS" # Outgoing damage. Enables the DPS broadcast.
---| "HPS" # Healing. Enables the HPS broadcast.
---| "ULT" # Ultimate type, cost, value, and ult-activated set. Enables the ULT broadcast.
---| "SKILLLINES" # Equipped class skill lines. Enables the skill line broadcast.

---@alias LGCS_DamageType
---| 0 # DAMAGE_UNKNOWN. No outgoing damage in the current recap.
---| 1 # DAMAGE_TOTAL. `dmg` is total damage / 10000.
---| 2 # DAMAGE_BOSS. `dmg` is boss damage / boss time / 100.

---@alias LGCS_EventName
---| "EVENT_GROUP_DPS_UPDATE"
---| "EVENT_GROUP_HPS_UPDATE"
---| "EVENT_GROUP_ULT_UPDATE"
---| "EVENT_GROUP_SKILLLINES_UPDATE"
---| "EVENT_PLAYER_DPS_UPDATE"
---| "EVENT_PLAYER_HPS_UPDATE"
---| "EVENT_PLAYER_ULT_UPDATE"
---| "EVENT_PLAYER_SKILLLINES_UPDATE"
---| "EVENT_PLAYER_ULT_VALUE_UPDATE"
---| "EVENT_PLAYER_ULT_TYPE_UPDATE"

---@alias LGCS_UltCallback fun(unitTag: string, data: LGCS_UltStats)
---@alias LGCS_DpsCallback fun(unitTag: string, data: LGCS_DpsStats)
---@alias LGCS_HpsCallback fun(unitTag: string, data: LGCS_HpsStats)
---@alias LGCS_SkillLinesCallback fun(unitTag: string, data: LGCS_SkillLinesStats)

--- Source class `ult`.
--- Values consumers read are raw ultimate points (0-500). The library halves them only on the wire.
---@class LGCS_UltStats
---@field ultValue number Raw ultimate points.
---@field ult1ID integer Front bar ultimate ability id. Base ability id, not the morph.
---@field ult2ID integer Back bar ultimate ability id. Base ability id, not the morph.
---@field ult1Cost number Front bar ultimate cost.
---@field ult2Cost number Back bar ultimate cost.
---@field ultActivatedSetID integer Index into `LibGroupCombatStats.ULT_ACTIVATED_SET_LIST`. 0 when none is equipped.
---@field _lastUpdated number Timestamp of the last write, in game milliseconds.
---@field _lastChanged number Timestamp of the last value change, in game milliseconds.

--- Source class `dps`.
---@class LGCS_DpsStats
---@field dmgType LGCS_DamageType
---@field dps number Single-target DPS in thousands (`DPSOut / 1000`).
---@field dmg number Boss fight: `bossDamageTotal / bossTime / 100`. Otherwise `damageOutTotal / 10000`.
---@field _lastUpdated number Timestamp of the last write, in game milliseconds.
---@field _lastChanged number Timestamp of the last value change, in game milliseconds.

--- Source class `hps`.
---@class LGCS_HpsStats
---@field hps number Healing the group is consuming, in thousands (`HPSOut / 1000`).
---@field overheal number Raw healing pushed out, in thousands (`OHPSOut / 1000`).
---@field _lastUpdated number Timestamp of the last write, in game milliseconds.
---@field _lastChanged number Timestamp of the last value change, in game milliseconds.

--- Source class `skillLines`.
--- Until a group skill-line message arrives, other members are initialized with `GetUnitClassId`, not a skill line id.
---@class LGCS_SkillLinesStats
---@field first integer First equipped class skill line id.
---@field second integer Second equipped class skill line id.
---@field third integer Third equipped class skill line id.
---@field _lastUpdated number Timestamp of the last write, in game milliseconds.
---@field _lastChanged number Timestamp of the last value change, in game milliseconds.

--- Snapshot of one group member. Returned by `GetUnitStats`, `GetGroupStats`, and `Iterate`.
---@class LGCS_UnitStats
---@field tag string Unit tag, such as `"group1"` or `"player"`.
---@field name string Character name. This is the internal storage key.
---@field displayName string Account name, including the `@`.
---@field isPlayer boolean True for the local player.
---@field ult LGCS_UltStats
---@field dps LGCS_DpsStats
---@field hps LGCS_HpsStats
---@field skillLines LGCS_SkillLinesStats

--- One entry of `ULT_ACTIVATED_SET_LIST`.
--- Current order: 1 saxhleel, 2 pillager, 3 cryptcanon, 4 MA (Master Architect), 5 WM (War Machine).
---@class LGCS_UltActivatedSet
---@field name string Short set name.
---@field link string Item link passed to `GetItemLinkSetInfo`.
---@field minEquipped integer Equipped count treated as a full set. Two pieces can sit on the back bar.

--- Which stat broadcasts are currently enabled.
--- `GetStatsShared` returns this table. The live comment that says it returns three strings is wrong.
---@class LGCS_StatsShared
---@field ULT boolean
---@field DPS boolean
---@field HPS boolean
---@field SKILLLINES boolean

--- Source class `CombatStatsObject`.
--- Returned by `LibGroupCombatStats.RegisterAddon`. There is no unregister.
---
--- Callbacks are `fun(unitTag: string, data)`. Group events fire for other members.
--- Player events fire with `unitTag == "player"`.
--- `#object` and `GetGroupSize` use the length operator on a character-name map, so they do not count members.
---@class LGCS_CombatStats
---@operator len: integer
local LGCS_CombatStats = {}

--- Copy of the flags for broadcasts this library session has enabled.
---@return LGCS_StatsShared statsShared
function LGCS_CombatStats:GetStatsShared() end

--- Iterator used as `for tag, stats in object:Iterate() do`.
--- Each step returns the unit tag and a snapshot of that member.
---@return fun(): string?, LGCS_UnitStats? iterator
function LGCS_CombatStats:Iterate() end

--- `pairs(object)` calls this. Same iterator as `Iterate`.
---@return fun(): string?, LGCS_UnitStats? iterator
function LGCS_CombatStats:__pairs() end

--- Length of the internal character-name map.
--- The map uses string keys, so this does not count group members.
---@return integer groupSize
function LGCS_CombatStats:GetGroupSize() end

--- `#object` calls this. Same result as `GetGroupSize`.
---@return integer groupSize
function LGCS_CombatStats:__len() end

--- Snapshot of every member, keyed by unit tag.
---@return table<string, LGCS_UnitStats> groupStats
function LGCS_CombatStats:GetGroupStats() end

--- Snapshot of one member, or nil when that unit is not in the group table.
---@param unitTag string Unit tag, such as `"group1"`.
---@return LGCS_UnitStats? unitStats
function LGCS_CombatStats:GetUnitStats(unitTag) end

--- Live DPS table for one member, or nil when that unit is not in the group table.
--- This is the same object the DPS callbacks receive, not a copy.
---@param unitTag string Unit tag, such as `"group1"`.
---@return LGCS_DpsStats? dps
function LGCS_CombatStats:GetUnitDPS(unitTag) end

--- Live HPS table for one member, or nil when that unit is not in the group table.
--- This is the same object the HPS callbacks receive, not a copy.
---@param unitTag string Unit tag, such as `"group1"`.
---@return LGCS_HpsStats? hps
function LGCS_CombatStats:GetUnitHPS(unitTag) end

--- Live ultimate table for one member, or nil when that unit is not in the group table.
--- This is the same object the ultimate callbacks receive, not a copy.
---@param unitTag string Unit tag, such as `"group1"`.
---@return LGCS_UltStats? ult
function LGCS_CombatStats:GetUnitULT(unitTag) end

--- Live skill-line table for one member, or nil when that unit is not in the group table.
--- This is the same object the skill-line callbacks receive, not a copy.
---@param unitTag string Unit tag, such as `"group1"`.
---@return LGCS_SkillLinesStats? skillLines
function LGCS_CombatStats:GetUnitSkillLines(unitTag) end

--- True when either slotted ultimate is one of the given ability ids.
---@param unitTag string Unit tag, such as `"group1"`.
---@param listOfAbilityIDs integer[] Ability ids to test, `{ id1, id2, id3 }`.
---@return boolean hasEquipped
function LGCS_CombatStats:HasUnitUltimatesSlotted(unitTag, listOfAbilityIDs) end

--- True when the member's ult-activated set index matches.
--- Unstable. The library author says this will change and points consumers at LibSetDetection v4.
---@param unitTag string Unit tag, such as `"group1"`.
---@param ultActivatedSetID integer Index into `ULT_ACTIVATED_SET_LIST`.
---@return boolean hasEquipped
function LGCS_CombatStats:HasUnitUltActivatedSetSlotted(unitTag, ultActivatedSetID) end

--- Listen for a library event.
--- The callback is `fun(unitTag: string, data)`. Group events pass another member's tag.
--- Player events pass `"player"`.
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_GROUP_DPS_UPDATE", callback: LGCS_DpsCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_GROUP_HPS_UPDATE", callback: LGCS_HpsCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_GROUP_ULT_UPDATE", callback: LGCS_UltCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_GROUP_SKILLLINES_UPDATE", callback: LGCS_SkillLinesCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_DPS_UPDATE", callback: LGCS_DpsCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_HPS_UPDATE", callback: LGCS_HpsCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_ULT_UPDATE", callback: LGCS_UltCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_SKILLLINES_UPDATE", callback: LGCS_SkillLinesCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_ULT_VALUE_UPDATE", callback: LGCS_UltCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_ULT_TYPE_UPDATE", callback: LGCS_UltCallback)
---@param eventName LGCS_EventName
---@param callback LGCS_UltCallback|LGCS_DpsCallback|LGCS_HpsCallback|LGCS_SkillLinesCallback
function LGCS_CombatStats:RegisterForEvent(eventName, callback) end

--- Remove a callback previously passed to `RegisterForEvent`.
--- The callback must be the same function reference.
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_GROUP_DPS_UPDATE", callback: LGCS_DpsCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_GROUP_HPS_UPDATE", callback: LGCS_HpsCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_GROUP_ULT_UPDATE", callback: LGCS_UltCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_GROUP_SKILLLINES_UPDATE", callback: LGCS_SkillLinesCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_DPS_UPDATE", callback: LGCS_DpsCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_HPS_UPDATE", callback: LGCS_HpsCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_ULT_UPDATE", callback: LGCS_UltCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_SKILLLINES_UPDATE", callback: LGCS_SkillLinesCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_ULT_VALUE_UPDATE", callback: LGCS_UltCallback)
---@overload fun(self: LGCS_CombatStats, eventName: "EVENT_PLAYER_ULT_TYPE_UPDATE", callback: LGCS_UltCallback)
---@param eventName LGCS_EventName
---@param callback LGCS_UltCallback|LGCS_DpsCallback|LGCS_HpsCallback|LGCS_SkillLinesCallback
function LGCS_CombatStats:UnregisterForEvent(eventName, callback) end

--- Group combat stats shared through LibGroupBroadcast.
---@class LibGroupCombatStats
---@field name "LibGroupCombatStats"
---@field version string Library version. The 2026-10-04 build uses `"2026-10-04"`.
---@field DAMAGE_UNKNOWN 0
---@field DAMAGE_TOTAL 1
---@field DAMAGE_BOSS 2
--- 1-based index is `ultActivatedSetID`.
---@field ULT_ACTIVATED_SET_LIST LGCS_UltActivatedSet[]
---@field EVENT_GROUP_DPS_UPDATE "EVENT_GROUP_DPS_UPDATE"
---@field EVENT_GROUP_HPS_UPDATE "EVENT_GROUP_HPS_UPDATE"
---@field EVENT_GROUP_ULT_UPDATE "EVENT_GROUP_ULT_UPDATE"
---@field EVENT_GROUP_SKILLLINES_UPDATE "EVENT_GROUP_SKILLLINES_UPDATE"
---@field EVENT_PLAYER_DPS_UPDATE "EVENT_PLAYER_DPS_UPDATE"
---@field EVENT_PLAYER_HPS_UPDATE "EVENT_PLAYER_HPS_UPDATE"
---@field EVENT_PLAYER_ULT_UPDATE "EVENT_PLAYER_ULT_UPDATE"
---@field EVENT_PLAYER_SKILLLINES_UPDATE "EVENT_PLAYER_SKILLLINES_UPDATE"
--- Usually not needed. Fires when the local player's ultimate points change.
---@field EVENT_PLAYER_ULT_VALUE_UPDATE "EVENT_PLAYER_ULT_VALUE_UPDATE"
--- Usually not needed. Fires when the local player's slotted ultimates, costs, or ult-activated set change.
---@field EVENT_PLAYER_ULT_TYPE_UPDATE "EVENT_PLAYER_ULT_TYPE_UPDATE"
LibGroupCombatStats = {}

--- Class id of the class that owns `skillLineId`.
--- Calls `GetSkillLineClassId(GetSkillLineIndicesFromSkillLineId(skillLineId))`.
---@param skillLineId integer
---@return integer classId
function LibGroupCombatStats.GetClassIdFromSkillLineId(skillLineId) end

--- Platform class icon for the class that owns `skillLineId`.
--- Calls `ZO_GetPlatformClassIcon`.
---@param skillLineId integer
---@return string texturePath
function LibGroupCombatStats.GetClassIconFromSkillLineId(skillLineId) end

--- Class mastery collectible icon for the class that owns `skillLineId`.
--- Calls `GetCollectibleIcon(GetSkillLineMasteryCollectibleId(skillLineId))`.
---@param skillLineId integer
---@return string texturePath
function LibGroupCombatStats.GetFancyClassIconFromSkillLineId(skillLineId) end

--- Register an addon and start the broadcasts it asks for.
--- Returns nil when either argument is missing, or when `addonName` was already registered.
--- Unknown stat names are stored and do not enable a broadcast. There is no unregister.
---@param addonName string Addon name. Must be unique for this session.
---@param neededStats LGCS_StatName[] Stats to share, for example `{ "ULT", "DPS", "HPS" }`.
---@return LGCS_CombatStats? combatStats
function LibGroupCombatStats.RegisterAddon(addonName, neededStats) end

