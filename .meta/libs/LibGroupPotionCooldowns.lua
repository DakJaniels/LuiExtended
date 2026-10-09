---@meta LibGroupPotionCooldowns
-- Optional dependency (LibGroupPotionCooldowns.lua, version 2026-01-11).
-- Types for LuiExtended IDE checks only. Public surface is the annotated
-- library API. Return types follow the implementations.

---@alias LGPC_EventName
---| "EVENT_GROUP_COOLDOWN_UPDATE" # Another group member drank a potion.
---| "EVENT_PLAYER_COOLDOWN_UPDATE" # The message unit tag is the local player.

---@alias LGPC_CooldownCallback fun(unitTag: string, data: LGPC_PotionData)

--- Source class `PotionData`.
--- After a broadcast, durations are milliseconds. The local player's initial `cooldownDurationMS` is `45.0`. Other members start at `45000`.
---@class LGPC_PotionData
---@field lastUpdated number Game milliseconds when the last message was applied. `0` until then.
---@field isOnCooldown boolean Set true when a cooldown message arrives. Set false when `hasCooldownUntil` is reached.
---@field cooldownDurationMS number Potion cooldown from the message (`duration * 1000`).
---@field hasCooldownUntil number Game milliseconds when the cooldown ends. `now + (remain * 1000) + minDelay`.

--- Source class `UnitPotionStats`.
--- `Iterate`, `GetGroupStats`, and `GetUnitPotionData` return this shape.
--- Those copies omit `isOnline`. `potionData` is the live table, not a copy.
---@class LGPC_UnitPotionStats
---@field tag string Unit tag, such as `"group1"` or `"player"`.
---@field name string Character name. This is the internal storage key.
---@field displayName string Account name, including the `@`.
---@field isPlayer boolean True for the local player.
---@field isOnline boolean? Set on the stored record when the member is added. Query copies omit it, and it is not refreshed.
---@field potionData LGPC_PotionData Live cooldown table.

--- Source class `_PotionStatsObject`.
--- Returned by `LibGroupPotionCooldowns.RegisterAddon`. There is no unregister.
---
--- Callbacks are `fun(unitTag: string, data: LGPC_PotionData)`.
--- `EVENT_PLAYER_COOLDOWN_UPDATE` fires when the message unit tag is the local player.
--- `EVENT_GROUP_COOLDOWN_UPDATE` fires for everyone else.
--- A second callback fires when the cooldown ends, with `isOnCooldown == false`.
--- `#object` and `GetGroupSize` use the length operator on a character-name map, so they do not count members.
---@class LGPC_PotionStats
---@operator len: integer
local LGPC_PotionStats = {}

--- Iterator used as `for tag, stats in object:Iterate() do`.
--- Each step returns the unit tag and a snapshot whose `potionData` is the live table.
---@return fun(): string?, LGPC_UnitPotionStats? iterator
function LGPC_PotionStats:Iterate() end

--- `pairs(object)` calls this. Same iterator as `Iterate`.
---@return fun(): string?, LGPC_UnitPotionStats? iterator
function LGPC_PotionStats:__pairs() end

--- Length of the internal character-name map.
--- The map uses string keys, so this does not count group members.
---@return integer groupSize
function LGPC_PotionStats:GetGroupSize() end

--- `#object` calls this. Same result as `GetGroupSize`.
---@return integer groupSize
function LGPC_PotionStats:__len() end

--- Snapshot of every member, keyed by unit tag.
--- Each `potionData` is the live table.
---@return table<string, LGPC_UnitPotionStats> groupStats
function LGPC_PotionStats:GetGroupStats() end

--- Wrapper for one member, or nil when that unit is not in the group table.
--- `potionData` is the live table. `tag` is the unit tag that was passed in.
---@param unitTag string Unit tag, such as `"group1"`.
---@return LGPC_UnitPotionStats? unitStats
function LGPC_PotionStats:GetUnitPotionData(unitTag) end

--- Annotated as the remaining cooldown in milliseconds.
--- Returns nil when the unit is not in the group table.
--- When the unit exists, the body reads `unit.hasCooldownUntil`. That field lives on `potionData`, so this call errors.
--- The arithmetic is `now - hasCooldownUntil`, clamped at 0.
---@param unitTag string Unit tag, such as `"group1"`.
---@return number? remainingMS
function LGPC_PotionStats:GetUnitRemainingCooldownMS(unitTag) end

--- True while the stored cooldown flag is set.
--- Returns nil when the unit is not in the group table.
---@param unitTag string Unit tag, such as `"group1"`.
---@return boolean? isOnCooldown
function LGPC_PotionStats:IsUnitOnCooldown(unitTag) end

--- Listen for a library event.
--- The callback is `fun(unitTag: string, data: LGPC_PotionData)`.
---@overload fun(self: LGPC_PotionStats, eventName: "EVENT_GROUP_COOLDOWN_UPDATE", callback: LGPC_CooldownCallback)
---@overload fun(self: LGPC_PotionStats, eventName: "EVENT_PLAYER_COOLDOWN_UPDATE", callback: LGPC_CooldownCallback)
---@param eventName LGPC_EventName
---@param callback LGPC_CooldownCallback
function LGPC_PotionStats:RegisterForEvent(eventName, callback) end

--- Remove a callback previously passed to `RegisterForEvent`.
--- The callback must be the same function reference.
---@overload fun(self: LGPC_PotionStats, eventName: "EVENT_GROUP_COOLDOWN_UPDATE", callback: LGPC_CooldownCallback)
---@overload fun(self: LGPC_PotionStats, eventName: "EVENT_PLAYER_COOLDOWN_UPDATE", callback: LGPC_CooldownCallback)
---@param eventName LGPC_EventName
---@param callback LGPC_CooldownCallback
function LGPC_PotionStats:UnregisterForEvent(eventName, callback) end

--- Group potion cooldowns shared through LibGroupBroadcast.
---@class LibGroupPotionCooldowns
---@field name "LibGroupPotionCooldowns"
---@field version string Library version. The 2026-01-11 build uses `"2026-01-11"`.
---@field EVENT_GROUP_COOLDOWN_UPDATE "EVENT_GROUP_COOLDOWN_UPDATE"
---@field EVENT_PLAYER_COOLDOWN_UPDATE "EVENT_PLAYER_COOLDOWN_UPDATE"
LibGroupPotionCooldowns = {}

--- Register an addon and start the potion-use broadcast.
--- Raises when `addonName` is missing or was already registered. The `return nil` lines after `error()` are not reached.
--- There is no unregister.
---@param addonName string Addon name. Must be unique for this session.
---@return LGPC_PotionStats? potionStats
function LibGroupPotionCooldowns.RegisterAddon(addonName) end



