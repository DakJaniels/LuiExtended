---@meta LibCombatAlerts
-- Optional dependency. LibCombatAlerts 0.8.5.2 (AddOnVersion 8052).
-- After load, InternalCleanup.lua freezes the table with `ReadOnlyTable`.
-- Color helpers below are assigned from LibCodesCommonCode.
-- Any other function on LibCodesCommonCode is copied onto this table the first time it is read.

---@class LibCombatAlerts
---@field INTERRUPT_EVENTS table<integer, integer>
---@field DEATH_EVENTS table<integer, boolean>
---@field DAMAGE_EVENTS table<integer, boolean>
---@field IDS { TAUNT: 38254, MAJ_VULN: 106754 }
---@field isDamage boolean
---@field isHealer boolean
---@field isTank boolean
---@field isVet boolean
LibCombatAlerts = {}

---@type 1
LibCombatAlerts.TIME_FORMAT_LONG = 1
---@type 2
LibCombatAlerts.TIME_FORMAT_SHORT = 2
---@type 3
LibCombatAlerts.TIME_FORMAT_COUNTDOWN = 3
---@type 4
LibCombatAlerts.TIME_FORMAT_COMPACT = 4

---@param abilityId integer
---@return string
function LibCombatAlerts.GetAbilityName(abilityId) end

--- `soundId` is a key of `SOUNDS`. Extra arguments are another `PlaySounds` call after `delayForNext` milliseconds.
---@param soundId string|nil
---@param amplification integer|nil
---@param delayForNext number|nil
---@param ... any
function LibCombatAlerts.PlaySounds(soundId, amplification, delayForNext, ...) end

--- A table texture also returns left, right, top, bottom coords. A plain path returns only the path.
---@param textureId string
---@return string path
---@return number|nil left
---@return number|nil right
---@return number|nil top
---@return number|nil bottom
function LibCombatAlerts.GetTexture(textureId) end

---@param control any
---@param textureId string
function LibCombatAlerts.SetTexture(control, textureId) end

---@param isFriendly boolean
---@return integer
function LibCombatAlerts.GetTelegraphColor(isFriendly) end

--- `TIME_FORMAT_SHORT` is used when `format` is omitted or is not long or countdown.
---@param ms number
---@param format integer|nil
---@return string
function LibCombatAlerts.FormatTime(ms, format) end

--- Nil when the effect is not on the unit.
---@param unitTag string
---@param effectAbilityId integer
---@return number|nil timeStarted
---@return number|nil timeEnding
---@return integer|nil stackCount
---@return boolean|nil castByPlayer
function LibCombatAlerts.CheckUnitForEffect(unitTag, effectAbilityId) end

--- Nil only when `invalidReturnsNil` is true and max health is 0. Otherwise 0.
---@param unitTag string
---@param invalidReturnsNil boolean|nil
---@return number|nil
function LibCombatAlerts.GetUnitHealthPercent(unitTag, invalidReturnsNil) end

--- `...` is forwarded to `AddFilterForEvent`.
---@param name string
---@param event integer
---@param callback function
---@param ... any
function LibCombatAlerts.RegisterForFilteredEvent(name, event, callback, ...) end

---@param fragment any
---@param enable boolean
---@param additionalSceneNames string[]|nil
function LibCombatAlerts.ToggleUIFragment(fragment, enable, additionalSceneNames) end

---@param identifier string
---@param delay integer
---@param func function
function LibCombatAlerts.CoalescedDelayedCall(identifier, delay, func) end

---@param x1 number
---@param y1 number
---@param z1 number
---@param x2 number
---@param y2 number
---@param z2 number
---@return number
function LibCombatAlerts.GetDistanceSquared(x1, y1, z1, x2, y2, z2) end

--- `unitTag2` may be a unit tag or `{ x, y, z }`. Validate returns -1 when the zones differ or zone is 0.
--- Result is meters (`zo_sqrt` of the squared distance, divided by 100).
---@param unitTag1 string
---@param unitTag2 string|{ [1]: number, [2]: number, [3]: number }
---@param useHeight boolean|nil
---@param validate boolean|nil
---@param useMapPositionInsteadOfRawPosition boolean|nil
---@return number
function LibCombatAlerts.GetDistance(unitTag1, unitTag2, useHeight, validate, useMapPositionInsteadOfRawPosition) end

--- `overwrite` 1 fills existing subtables. Forwards to `MergeTables`.
---@param options table
---@param defaults table
---@param populateExistingSubtables boolean|nil
---@return table
function LibCombatAlerts.PopulateOptions(options, defaults, populateExistingSubtables) end

--- Either `changes` is a table, or the remaining arguments are key, value pairs.
---@param options table
---@param ... any
---@return table
function LibCombatAlerts.UpdateOptions(options, ...) end

---@return boolean
function LibCombatAlerts.DoesPlayerHaveTauntSlotted() end

---@return boolean
function LibCombatAlerts.DoesPlayerHaveSingleTargetPullSlotted() end

---@return boolean
function LibCombatAlerts.DoesPlayerHaveTauntOrPullSlotted() end

---@return boolean
function LibCombatAlerts.DoesPlayerHaveAoePurgeSlotted() end

---@return boolean
function LibCombatAlerts.IsNightbladeCutthroatPassiveActive() end

---@param name string
---@param enable boolean
function LibCombatAlerts.ToggleUnitIdTracking(name, enable) end

function LibCombatAlerts.ResetUnitIdTracking() end

--- 0 until a player unit id has been seen.
---@return integer
function LibCombatAlerts.GetPlayerUnitId() end

---@param unitId integer|nil
---@return boolean
function LibCombatAlerts.IsUnitIdValid(unitId) end

---@param unitTag string
---@return integer|nil
function LibCombatAlerts.IdentifyGroupUnitTag(unitTag) end

--- Without a fallback, returns nil when the id is unknown.
--- With a fallback, unknown ids return `""` and `"unit<id>"`, or `"player"` and the display name for the player.
---@param unitId integer
---@param useFallback boolean|nil
---@return string|nil unitTag
---@return string|nil name
function LibCombatAlerts.IdentifyGroupUnitId(unitId, useFallback) end

---@param unitId integer
---@param useFallback boolean|nil
---@return string|nil unitTag
---@return string|nil name
function LibCombatAlerts.IdentifyBossUnitId(unitId, useFallback) end

--- Same arguments as `IdentifyGroupUnitId`. The name is prefixed with a role icon when one is known.
---@param ... integer|boolean|nil
---@return string|nil unitTag
---@return string|nil name
function LibCombatAlerts.IdentifyGroupUnitIdWithRole(...) end

--- Omit `name` and `callback` to unregister `id`.
---@param id any
---@param action any
---@param name string|nil
---@param callback function|nil
function LibCombatAlerts.RegisterInteractionBlock(id, action, name, callback) end

function LibCombatAlerts.UnregisterAllInteractionBlocks() end

--- A non-function `callback` unregisters `name`.
---@param name string
---@param callback function|nil
function LibCombatAlerts.RegisterInCombatSkillBlock(name, callback) end

--- Assigned from `LibCodesCommonCode.Int32ToRGBA`.
---@param rgba integer
---@return number r
---@return number g
---@return number b
---@return number a
function LibCombatAlerts.UnpackRGBA(rgba) end

---@param rgb integer
---@return number r
---@return number g
---@return number b
function LibCombatAlerts.UnpackRGB(rgb) end

---@param r number
---@param g number
---@param b number
---@param a number
---@return integer
function LibCombatAlerts.PackRGBA(r, g, b, a) end

---@param r number
---@param g number
---@param b number
---@return integer
function LibCombatAlerts.PackRGB(r, g, b) end

---@param rgb integer
---@param a number|nil
---@return integer
function LibCombatAlerts.AddAlpha(rgb, a) end

---@param rgba integer
---@return integer
function LibCombatAlerts.RemoveAlpha(rgba) end

---@param h number
---@param s number
---@param l number
---@param a number|nil
---@return number r
---@return number g
---@return number b
---@return number|nil a
function LibCombatAlerts.HSLToRGB(h, s, l, a) end

---@param rgb integer
---@return number h
---@return number s
---@return number l
function LibCombatAlerts.UnpackHSL(rgb) end

---@param rgba integer
---@return number h
---@return number s
---@return number l
---@return number a
function LibCombatAlerts.UnpackHSLA(rgba) end

--- Copied from LibCodesCommonCode on first access. `overwrite` 2 replaces existing keys. Nested tables are merged.
---@param dest table|nil
---@param src table
---@param overwrite integer|nil
---@return table
function LibCombatAlerts.MergeTables(dest, src, overwrite) end

---@param func fun(eventCode: integer, initial: boolean)
function LibCombatAlerts.RunAfterInitialLoadscreen(func) end

--- Omit `callback` to unregister `id`.
---@param id string
---@param callback fun(currentZoneId: integer, previousZoneId: integer)|nil
function LibCombatAlerts.MonitorZoneChanges(id, callback) end


