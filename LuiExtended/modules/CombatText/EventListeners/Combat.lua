-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) CombatTextCombatEventListener : LuiExtended.CombatTextEventListener
local CombatTextCombatEventListener = LUIE.CombatTextEventListener:Subclass()

local Effects = LuiData.Data.Effects
local CombatTextConstants = LuiData.Data.CombatTextConstants

-- Memory optimization: Cache Effects sub-tables to avoid repeated table lookups
local EffectOverrideByName = Effects.EffectOverrideByName
local ZoneDataOverride = Effects.ZoneDataOverride
local MapDataOverride = Effects.MapDataOverride
local EffectHideSCT = Effects.EffectHideSCT

-- Memory optimization: Cache CombatTextConstants sub-tables to avoid repeated table lookups
local IsDamageTable = CombatTextConstants.isDamage
local IsDamageCriticalTable = CombatTextConstants.isDamageCritical
local IsDotTable = CombatTextConstants.isDot
local IsDotCriticalTable = CombatTextConstants.isDotCritical
local IsHealingTable = CombatTextConstants.isHealing
local IsHealingCriticalTable = CombatTextConstants.isHealingCritical
local IsHotTable = CombatTextConstants.isHot
local IsHotCriticalTable = CombatTextConstants.isHotCritical
local IsEnergizeTable = CombatTextConstants.isEnergize
local IsDrainTable = CombatTextConstants.isDrain
local IsMissTable = CombatTextConstants.isMiss
local IsImmuneTable = CombatTextConstants.isImmune
local IsParriedTable = CombatTextConstants.isParried
local IsReflectedTable = CombatTextConstants.isReflected
local IsDamageShieldTable = CombatTextConstants.isDamageShield
local IsDodgedTable = CombatTextConstants.isDodged
local IsBlockedTable = CombatTextConstants.isBlocked
local IsInterruptedTable = CombatTextConstants.isInterrupted
local IsDisorientedTable = CombatTextConstants.isDisoriented
local IsFearedTable = CombatTextConstants.isFeared
local IsOffBalancedTable = CombatTextConstants.isOffBalanced
local IsSilencedTable = CombatTextConstants.isSilenced
local IsStunnedTable = CombatTextConstants.isStunned
local IsCharmedTable = CombatTextConstants.isCharmed
local CombatType = CombatTextConstants.combatType
local EventType = CombatTextConstants.eventType
local CrowdControlType = CombatTextConstants.crowdControlType
local PointType = CombatTextConstants.pointType

-- Table pool: LUIE.GetCachedTable() / LUIE.RecycleTable() in LuiExtended.lua (RecycleTable clears keys).

-- Memory optimization: Cache formatted ability names to avoid repeated string allocations
-- Uses weak values (__mode='v') to allow garbage collection of unused entries
local abilityNameCache = setmetatable({},
                                      {
                                          __mode = "v", -- Weak values: entries can be GC'd when no longer referenced
                                          __index = function (t, abilityId)
                                              local name = zo_strformat("<<C:1>>", GetAbilityName(abilityId))
                                              t[abilityId] = name
                                              return name
                                          end
                                      })

-- Memory optimization: Cache formatted source names
-- Uses weak values (__mode='v') to allow garbage collection of unused entries
local sourceNameCache = setmetatable({},
                                     {
                                         __mode = "v", -- Weak values: entries can be GC'd when no longer referenced
                                         __index = function (t, sourceName)
                                             local formatted = zo_strformat("<<C:1>>", sourceName)
                                             t[sourceName] = formatted
                                             return formatted
                                         end
                                     })

local isWarned =
{
    combat = false,
    disoriented = false,
    feared = false,
    offBalanced = false,
    silenced = false,
    stunned = false,
    charmed = false,
}

-- Memory optimization: Reusable function for CC debounce instead of creating closures
local function resetCCWarning(ccType)
    isWarned[ccType] = false
end

-- Crowd control configuration: ordered by type for data-driven processing
local CC_CONFIG =
{
    {
        flag = "isDisoriented",
        toggleKey = "showDisoriented",
        warnKey = "disoriented",
        ccType = "DISORIENTED",
    },
    {
        flag = "isFeared",
        toggleKey = "showFeared",
        warnKey = "feared",
        ccType = "FEARED",
    },
    {
        flag = "isOffBalanced",
        toggleKey = "showOffBalanced",
        warnKey = "offBalanced",
        ccType = "OFFBALANCED",
    },
    {
        flag = "isSilenced",
        toggleKey = "showSilenced",
        warnKey = "silenced",
        ccType = "SILENCED",
    },
    {
        flag = "isStunned",
        toggleKey = "showStunned",
        warnKey = "stunned",
        ccType = "STUNNED",
    },
    {
        flag = "isCharmed",
        toggleKey = "showCharmed",
        warnKey = "charmed",
        ccType = "CHARMED",
    },
}

-- Memory optimization: Pre-compute boolean lookups to avoid repeated table access
local resultTypeCache = setmetatable({},
                                     {
                                         __index = function (t, result)
                                             t[result] =
                                             {
                                                 isDamage = IsDamageTable[result],
                                                 isDamageCritical = IsDamageCriticalTable[result],
                                                 isDot = IsDotTable[result],
                                                 isDotCritical = IsDotCriticalTable[result],
                                                 isHealing = IsHealingTable[result],
                                                 isHealingCritical = IsHealingCriticalTable[result],
                                                 isHot = IsHotTable[result],
                                                 isHotCritical = IsHotCriticalTable[result],
                                                 isEnergize = IsEnergizeTable[result],
                                                 isDrain = IsDrainTable[result],
                                                 isMiss = IsMissTable[result],
                                                 isImmune = IsImmuneTable[result],
                                                 isParried = IsParriedTable[result],
                                                 isReflected = IsReflectedTable[result],
                                                 isDamageShield = IsDamageShieldTable[result],
                                                 isDodged = IsDodgedTable[result],
                                                 isBlocked = IsBlockedTable[result],
                                                 isInterrupted = IsInterruptedTable[result],
                                                 isDisoriented = IsDisorientedTable[result],
                                                 isFeared = IsFearedTable[result],
                                                 isOffBalanced = IsOffBalancedTable[result],
                                                 isSilenced = IsSilencedTable[result],
                                                 isStunned = IsStunnedTable[result],
                                                 isCharmed = IsCharmedTable[result],
                                             }
                                             return t[result]
                                         end
                                     })

-- Inferred ability resource cost (live client often omits ACTION_RESULT_POWER_DRAIN on EVENT_COMBAT_EVENT).
-- Correlate slot use with the next matching player resource decrease within a short window.
local lastPlayerPowerByCombatMechanicFlags =
{
    [COMBAT_MECHANIC_FLAGS_MAGICKA] = nil,
    [COMBAT_MECHANIC_FLAGS_STAMINA] = nil,
    [COMBAT_MECHANIC_FLAGS_ULTIMATE] = nil,
    [COMBAT_MECHANIC_FLAGS_HEALTH] = nil,
}
local pendingSlotAbilityCost =
{
    abilityId = 0,
    expireGameTimeMs = 0,
    consumedMagicka = false,
    consumedStamina = false,
    consumedUltimate = false,
    consumedHealth = false,
    expectedMagickaCost = 0,
    expectedStaminaCost = 0,
    expectedUltimateCost = 0,
    expectedHealthCost = 0,
    spentMagicka = 0,
    spentStamina = 0,
    spentUltimate = 0,
    spentHealth = 0,
}
local lastDrainDedupe =
{
    timeMs = 0,
    abilityId = 0,
    combatMechanicFlags = 0,
    amount = 0,
}

local MITIGATION_DEDUPE_WINDOW_MS = 250

local lastMitigationDedupe =
{
    timeMs = 0,
    combatType = 0,
    result = 0,
    abilityId = 0,
    targetUnitId = 0,
}

--- @param flags table Event flags from resultTypeCache
--- @return boolean
local function IsMitigationCombatResult(flags)
    return flags.isMiss or flags.isImmune or flags.isParried or flags.isReflected
        or flags.isDamageShield or flags.isDodged or flags.isBlocked or flags.isInterrupted
end

--- Suppress duplicate mitigation lines when the client fires the same result twice per cast (e.g. IMMUNE bash).
--- @param combatType integer CombatTextConstants.combatType INCOMING or OUTGOING
--- @param result ActionResult
--- @param abilityId integer
--- @param targetUnitId integer
--- @return boolean true if this is a duplicate of a line we already showed (caller must skip)
local function IsRecentDuplicateMitigation(combatType, result, abilityId, targetUnitId)
    local now = GetGameTimeMilliseconds()
    if  now - lastMitigationDedupe.timeMs < MITIGATION_DEDUPE_WINDOW_MS
    and lastMitigationDedupe.combatType == combatType
    and lastMitigationDedupe.result == result
    and lastMitigationDedupe.abilityId == abilityId
    and lastMitigationDedupe.targetUnitId == targetUnitId then
        return true
    end
    lastMitigationDedupe.timeMs = now
    lastMitigationDedupe.combatType = combatType
    lastMitigationDedupe.result = result
    lastMitigationDedupe.abilityId = abilityId
    lastMitigationDedupe.targetUnitId = targetUnitId
    return false
end

--- @param combatMechanicFlags integer COMBAT_MECHANIC_FLAGS_* (EVENT_POWER_UPDATE / GetUnitPower pool key)
--- @return boolean
local function IsTrackedResourceCombatMechanicFlags(combatMechanicFlags)
    return combatMechanicFlags == COMBAT_MECHANIC_FLAGS_MAGICKA
        or combatMechanicFlags == COMBAT_MECHANIC_FLAGS_STAMINA
        or combatMechanicFlags == COMBAT_MECHANIC_FLAGS_ULTIMATE
        or combatMechanicFlags == COMBAT_MECHANIC_FLAGS_HEALTH
end

--- Accept full upfront cost or partial ticks (channel / multi-tick costs) toward expected slotted cost.
--- @param delta integer
--- @param expectedCost integer
--- @param spentSoFar integer
--- @return boolean allowShow
--- @return boolean poolFullyPaid
local function EvaluateInferredPoolDrain(delta, expectedCost, spentSoFar)
    if expectedCost <= 0 or delta < 1 or delta > expectedCost then
        return false, false
    end
    local totalSpent = spentSoFar + delta
    local tolerance = math.max(1, zo_floor(expectedCost * 0.01))
    if totalSpent > expectedCost + tolerance then
        return false, true
    end
    return true, totalSpent >= expectedCost - tolerance
end

--- Suppress duplicate drain lines when both inferred and native POWER_DRAIN fire close together.
--- @param abilityId integer
--- @param combatMechanicFlags CombatMechanicFlags
--- @param amount integer
--- @return boolean true if this is a duplicate of a line we already showed (caller must skip)
local function IsRecentDuplicateDrain(abilityId, combatMechanicFlags, amount)
    local now = GetGameTimeMilliseconds()
    if  now - lastDrainDedupe.timeMs < 220
    and lastDrainDedupe.abilityId == abilityId
    and lastDrainDedupe.combatMechanicFlags == combatMechanicFlags
    and lastDrainDedupe.amount == amount then
        return true
    end
    lastDrainDedupe.timeMs = now
    lastDrainDedupe.abilityId = abilityId
    lastDrainDedupe.combatMechanicFlags = combatMechanicFlags
    lastDrainDedupe.amount = amount
    return false
end

--- Clear pending slot --> cost correlation (also used before a new slot attempt).
local function ClearPendingAbilityCost()
    pendingSlotAbilityCost.abilityId = 0
    pendingSlotAbilityCost.expireGameTimeMs = 0
    pendingSlotAbilityCost.consumedMagicka = false
    pendingSlotAbilityCost.consumedStamina = false
    pendingSlotAbilityCost.consumedUltimate = false
    pendingSlotAbilityCost.consumedHealth = false
    pendingSlotAbilityCost.expectedMagickaCost = 0
    pendingSlotAbilityCost.expectedStaminaCost = 0
    pendingSlotAbilityCost.expectedUltimateCost = 0
    pendingSlotAbilityCost.expectedHealthCost = 0
    pendingSlotAbilityCost.spentMagicka = 0
    pendingSlotAbilityCost.spentStamina = 0
    pendingSlotAbilityCost.spentUltimate = 0
    pendingSlotAbilityCost.spentHealth = 0
end

--- @param costAbility integer ability id for tooltip/cost APIs (often chained)
--- @param combatMechanicFlags integer COMBAT_MECHANIC_FLAGS_*
--- @return integer non-negative whole cost, or 0 if none / invalid
local function GetPositiveAbilityResourceCost(costAbility, combatMechanicFlags)
    local c = GetAbilityCost(costAbility, combatMechanicFlags, nil, "player")
    if type(c) ~= "number" or c <= 0 then
        return 0
    end
    return c
end

--- Remember which ability was just activated from the bar (for cost inference).
--- @param actionSlotIndex integer
local function SetPendingAbilityCostFromSlot(actionSlotIndex)
    ClearPendingAbilityCost()

    local hotbarCategory = GetActiveHotbarCategory()
    local slotType = GetSlotType(actionSlotIndex, hotbarCategory)
    if slotType ~= ACTION_TYPE_ABILITY and slotType ~= ACTION_TYPE_CRAFTED_ABILITY then
        return
    end
    local abilityId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
    if slotType == ACTION_TYPE_CRAFTED_ABILITY then
        abilityId = GetAbilityIdForCraftedAbilityId(abilityId)
    end
    if not abilityId or abilityId <= 0 then
        return
    end

    local costAbility = GetCurrentChainedAbility(abilityId)
    local expectedMagicka = GetPositiveAbilityResourceCost(costAbility, COMBAT_MECHANIC_FLAGS_MAGICKA)
    local expectedStamina = GetPositiveAbilityResourceCost(costAbility, COMBAT_MECHANIC_FLAGS_STAMINA)
    local expectedUltimate = GetPositiveAbilityResourceCost(costAbility, COMBAT_MECHANIC_FLAGS_ULTIMATE)
    local expectedHealth = GetPositiveAbilityResourceCost(costAbility, COMBAT_MECHANIC_FLAGS_HEALTH)
    if expectedMagicka == 0 and expectedStamina == 0 and expectedUltimate == 0 and expectedHealth == 0 then
        return
    end

    pendingSlotAbilityCost.abilityId = abilityId
    pendingSlotAbilityCost.expireGameTimeMs = GetGameTimeMilliseconds() + 900
    pendingSlotAbilityCost.expectedMagickaCost = expectedMagicka
    pendingSlotAbilityCost.expectedStaminaCost = expectedStamina
    pendingSlotAbilityCost.expectedUltimateCost = expectedUltimate
    pendingSlotAbilityCost.expectedHealthCost = expectedHealth
end

-- Memory optimization: Cache zone/map data to avoid repeated API calls
local cachedZoneData =
{
    zoneId = 0,
    zoneName = "",
    mapName = ""
}

--- Update the cached zone and map data<br>
--- Minimizes repeated API calls for location information
--- @param zoneName string? Optional zone name (fetched if not provided)
--- @param zoneId integer? Optional zone ID (fetched if not provided)
local function updateZoneCache(zoneName, zoneId)
    if zoneId then
        cachedZoneData.zoneId = zoneId
    else
        cachedZoneData.zoneId = GetZoneId(GetCurrentMapZoneIndex())
    end
    if zoneName then
        cachedZoneData.zoneName = zoneName
    else
        cachedZoneData.zoneName = GetPlayerLocationName()
    end
    cachedZoneData.mapName = GetMapName()
end

-- Memory optimization: Cache PlaySound string constant
local SOUND_ABILITY_FAILED = "Ability_Failed"

--- Resolve ability name with contextual overrides<br>
--- Applies overrides based on source name, zone, and map in priority order
--- @param abilityId integer The base ability ID
--- @param sourceName string The source/caster name
--- @return string abilityName The resolved ability name
local function ResolveAbilityName(abilityId, sourceName)
    local abilityName = abilityNameCache[abilityId]

    -- Override by source name
    local effectOverrideByName = EffectOverrideByName[abilityId]
    if effectOverrideByName then
        local sourceNameCheck = sourceNameCache[sourceName]
        local nameOverride = effectOverrideByName[sourceNameCheck]
        if nameOverride and nameOverride.name then
            abilityName = nameOverride.name
        end
    end

    -- Override by zone
    local effectZoneOverride = ZoneDataOverride[abilityId]
    if effectZoneOverride then
        local zoneOverride = effectZoneOverride[cachedZoneData.zoneId]
            or effectZoneOverride[cachedZoneData.zoneName]
        if zoneOverride and zoneOverride.name then
            abilityName = zoneOverride.name
        end
    end

    -- Override by map
    local effectMapOverride = MapDataOverride[abilityId]
    if effectMapOverride then
        local mapOverride = effectMapOverride[cachedZoneData.mapName]
        if mapOverride and mapOverride.name then
            abilityName = mapOverride.name
        end
    end

    return abilityName
end

--- Check if a combat event should be displayed based on flags and settings<br>
--- Evaluates all combat event types against their respective toggle settings
--- @param flags table Event flags (isDamage, isHealing, etc.)
--- @param toggles table Settings toggles for this combat direction
--- @param combatMechanicFlags integer COMBAT_MECHANIC_FLAGS_* from combat / power events
--- @param hitValue integer The damage/healing value
--- @param overkill boolean If this is overkill damage
--- @param overheal boolean If this is overheal
--- @return boolean shouldShow True if event should be displayed
local function ShouldShowCombatEvent(flags, toggles, combatMechanicFlags, hitValue, overkill, overheal)
    return (flags.isDodged and toggles.showDodged)
        or (flags.isMiss and toggles.showMiss)
        or (flags.isImmune and toggles.showImmune)
        or (flags.isReflected and toggles.showReflected)
        or (flags.isDamageShield and toggles.showDamageShield)
        or (flags.isParried and toggles.showParried)
        or (flags.isBlocked and toggles.showBlocked)
        or (flags.isInterrupted and toggles.showInterrupted)
        or (flags.isDot and toggles.showDot and (hitValue > 0 or overkill))
        or (flags.isDotCritical and toggles.showDot and (hitValue > 0 or overkill))
        or (flags.isHot and toggles.showHot and (hitValue > 0 or overheal))
        or (flags.isHotCritical and toggles.showHot and (hitValue > 0 or overheal))
        or (flags.isHealing and toggles.showHealing and (hitValue > 0 or overheal))
        or (flags.isHealingCritical and toggles.showHealing and (hitValue > 0 or overheal))
        or (flags.isDamage and toggles.showDamage and (hitValue > 0 or overkill))
        or (flags.isDamageCritical and toggles.showDamage and (hitValue > 0 or overkill))
        or (flags.isEnergize and toggles.showEnergize and (combatMechanicFlags == COMBAT_MECHANIC_FLAGS_MAGICKA or combatMechanicFlags == COMBAT_MECHANIC_FLAGS_STAMINA))
        or (flags.isEnergize and toggles.showUltimateEnergize and combatMechanicFlags == COMBAT_MECHANIC_FLAGS_ULTIMATE)
        -- POWER_DRAIN: do not gate on combatMechanicFlags; the client can report costs with flags we do not enumerate
        or (flags.isDrain and toggles.showDrain)
end

--- Process crowd control events in a data-driven manner<br>
--- Handles CC debouncing and event triggering for all CC types
--- @param self LuiExtended.CombatTextCombatEventListener The event listener instance
--- @param flags table Event flags containing CC state
--- @param toggles table Settings toggles for this combat direction
--- @param combatType integer Combat direction (INCOMING or OUTGOING)
--- @note Caller MUST check isWarned.combat before calling this function
local function ProcessCrowdControlEvents(self, flags, toggles, combatType)
    for _, config in ipairs(CC_CONFIG) do
        if flags[config.flag] and toggles[config.toggleKey] then
            if isWarned[config.warnKey] then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType[config.ccType], combatType)
                isWarned[config.warnKey] = true
                zo_callLater(function () resetCCWarning(config.warnKey) end, 1000)
            end
        end
    end
end

--- Initialize combat event listener<br>
--- Registers for incoming/outgoing combat events, combat state changes, and zone changes
function CombatTextCombatEventListener:Initialize()
    LUIE.CombatTextEventListener.Initialize(self)
    self:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function ()
        self:OnPlayerActivated()
    end)
    self:RegisterForEvent(EVENT_COMBAT_EVENT, function (result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, combatMechanicFlags, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                              self:OnCombatIn(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, combatMechanicFlags, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                          end, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Target -> Player
    self:RegisterForEvent(EVENT_COMBAT_EVENT, function (result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, combatMechanicFlags, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                              self:OnCombatOut(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, combatMechanicFlags, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                          end, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Player -> Target
    self:RegisterForEvent(EVENT_COMBAT_EVENT, function (result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, combatMechanicFlags, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                              self:OnCombatOut(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, combatMechanicFlags, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                          end, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET) -- Player Pet -> Target
    self:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function (inCombat)
        self:CombatState(inCombat)
    end)
    -- Memory optimization: Update zone cache on zone changes
    self:RegisterForEvent(EVENT_ZONE_CHANGED, function (zoneName, subZoneName, newSubzone, zoneId, subZoneId)
        updateZoneCache(zoneName, zoneId)
    end)
    self:RegisterForEvent(EVENT_ACTION_SLOT_ABILITY_USED, function (actionSlotIndex)
        self:OnActionSlotAbilityUsed(actionSlotIndex)
    end)
    self:RegisterForEvent(EVENT_POWER_UPDATE, function (_unitTag, _powerIndex, combatMechanicFlags, powerValue, powerMax, powerEffectiveMax)
                              self:OnPlayerPowerUpdate(combatMechanicFlags, powerValue, powerMax, powerEffectiveMax)
                          end, REGISTER_FILTER_UNIT_TAG, "player")
end

--- Handle player activation event<br>
--- Initializes zone cache and sets combat state if player is already in combat
function CombatTextCombatEventListener:OnPlayerActivated()
    updateZoneCache() -- Initialize zone cache
    lastPlayerPowerByCombatMechanicFlags[COMBAT_MECHANIC_FLAGS_MAGICKA] = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_MAGICKA)
    lastPlayerPowerByCombatMechanicFlags[COMBAT_MECHANIC_FLAGS_STAMINA] = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
    lastPlayerPowerByCombatMechanicFlags[COMBAT_MECHANIC_FLAGS_ULTIMATE] = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    lastPlayerPowerByCombatMechanicFlags[COMBAT_MECHANIC_FLAGS_HEALTH] = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_HEALTH)
    ClearPendingAbilityCost()
    if IsUnitInCombat("player") then
        isWarned.combat = true
    end
end

--- Remember bar ability activation for inferred resource cost display.
--- @param actionSlotIndex integer
function CombatTextCombatEventListener:OnActionSlotAbilityUsed(actionSlotIndex)
    if LUIE.CombatText.SV.common.inferResourceDrainOnCast then
        SetPendingAbilityCostFromSlot(actionSlotIndex)
    end
end

--- When native POWER_DRAIN combat events are missing, infer costs from player power drops after a bar use.
--- @param combatMechanicFlags integer COMBAT_MECHANIC_FLAGS_* (REGISTER_FILTER_POWER_TYPE / GetUnitPower second argument)
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
function CombatTextCombatEventListener:OnPlayerPowerUpdate(combatMechanicFlags, powerValue, powerMax, powerEffectiveMax)
    if not LUIE.CombatText.SV.common.inferResourceDrainOnCast then
        return
    end
    if not IsTrackedResourceCombatMechanicFlags(combatMechanicFlags) then
        return
    end

    local prev = lastPlayerPowerByCombatMechanicFlags[combatMechanicFlags]
    lastPlayerPowerByCombatMechanicFlags[combatMechanicFlags] = powerValue
    if prev == nil then
        return
    end
    if powerValue >= prev then
        return
    end

    local delta = prev - powerValue
    if delta < 1 then
        return
    end

    local now = GetGameTimeMilliseconds()
    if pendingSlotAbilityCost.abilityId == 0 or now > pendingSlotAbilityCost.expireGameTimeMs then
        return
    end

    local expectedCost = 0
    local spentSoFar = 0
    if combatMechanicFlags == COMBAT_MECHANIC_FLAGS_MAGICKA then
        if pendingSlotAbilityCost.consumedMagicka then
            return
        end
        expectedCost = pendingSlotAbilityCost.expectedMagickaCost
        spentSoFar = pendingSlotAbilityCost.spentMagicka
    elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_STAMINA then
        if pendingSlotAbilityCost.consumedStamina then
            return
        end
        expectedCost = pendingSlotAbilityCost.expectedStaminaCost
        spentSoFar = pendingSlotAbilityCost.spentStamina
    elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_ULTIMATE then
        if pendingSlotAbilityCost.consumedUltimate then
            return
        end
        expectedCost = pendingSlotAbilityCost.expectedUltimateCost
        spentSoFar = pendingSlotAbilityCost.spentUltimate
    elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_HEALTH then
        if pendingSlotAbilityCost.consumedHealth then
            return
        end
        expectedCost = pendingSlotAbilityCost.expectedHealthCost
        spentSoFar = pendingSlotAbilityCost.spentHealth
    else
        return
    end

    local allowShow, poolFullyPaid = EvaluateInferredPoolDrain(delta, expectedCost, spentSoFar)
    if not allowShow then
        if poolFullyPaid then
            if combatMechanicFlags == COMBAT_MECHANIC_FLAGS_MAGICKA then
                pendingSlotAbilityCost.consumedMagicka = true
            elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_STAMINA then
                pendingSlotAbilityCost.consumedStamina = true
            elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_ULTIMATE then
                pendingSlotAbilityCost.consumedUltimate = true
            elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_HEALTH then
                pendingSlotAbilityCost.consumedHealth = true
            end
        end
        return
    end

    if combatMechanicFlags == COMBAT_MECHANIC_FLAGS_MAGICKA then
        pendingSlotAbilityCost.spentMagicka = spentSoFar + delta
    elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_STAMINA then
        pendingSlotAbilityCost.spentStamina = spentSoFar + delta
    elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_ULTIMATE then
        pendingSlotAbilityCost.spentUltimate = spentSoFar + delta
    elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_HEALTH then
        pendingSlotAbilityCost.spentHealth = spentSoFar + delta
    end

    local Settings = LUIE.CombatText.SV
    local settingsToggles = Settings.toggles
    local flags = resultTypeCache[ACTION_RESULT_POWER_DRAIN]
    if not ShouldShowCombatEvent(flags, settingsToggles.incoming, combatMechanicFlags, delta, false, false) then
        return
    end

    local abilityId = pendingSlotAbilityCost.abilityId
    local sourceName = GetUnitName("player")
    local abilityName = ResolveAbilityName(abilityId, sourceName)

    if Settings.blacklist[abilityId] or Settings.blacklist[abilityName] then
        return
    end

    if EffectHideSCT[abilityId] then
        return
    end

    if settingsToggles.inCombatOnly and not isWarned.combat then
        return
    end

    if IsRecentDuplicateDrain(abilityId, combatMechanicFlags, delta) then
        return
    end

    self:TriggerEvent(EventType.COMBAT, CombatType.INCOMING, combatMechanicFlags, delta, abilityName, abilityId, DAMAGE_TYPE_NONE, sourceName,
                      false, false, false, false, false, true,
                      false, false, false, false, false, false, false, false, false, false, false)

    if poolFullyPaid then
        if combatMechanicFlags == COMBAT_MECHANIC_FLAGS_MAGICKA then
            pendingSlotAbilityCost.consumedMagicka = true
        elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_STAMINA then
            pendingSlotAbilityCost.consumedStamina = true
        elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_ULTIMATE then
            pendingSlotAbilityCost.consumedUltimate = true
        elseif combatMechanicFlags == COMBAT_MECHANIC_FLAGS_HEALTH then
            pendingSlotAbilityCost.consumedHealth = true
        end
    end
end

--- Handle incoming combat events (player as target)<br>
--- Processes damage, healing, mitigation, and crowd control events targeting the player<br>
--- Applies ability name overrides, checks blacklist, and triggers appropriate combat text events
--- @param result ActionResult The combat result type (damage, heal, miss, etc.)
--- @param isError boolean If the combat event represents an error
--- @param abilityName string Base ability name from game API
--- @param abilityGraphic integer Ability visual effect ID
--- @param abilityActionSlotType ActionSlotType The action slot type
--- @param sourceName string Name of the source unit (attacker/healer)
--- @param sourceType CombatUnitType Type of source unit
--- @param targetName string Name of target unit (player)
--- @param targetType CombatUnitType Type of target unit
--- @param hitValue integer Amount of damage/healing
--- @param combatMechanicFlags integer COMBAT_MECHANIC_FLAGS_* (resource pool for energize/drain, etc.)
--- @param damageType DamageType Type of damage (physical, magic, etc.)
--- @param log boolean If this should be logged
--- @param sourceUnitId integer Unit ID of source
--- @param targetUnitId integer Unit ID of target
--- @param abilityId integer The ability ID
--- @param overflow integer Overkill/overheal amount
function CombatTextCombatEventListener:OnCombatIn(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, combatMechanicFlags, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local Settings = LUIE.CombatText.SV
    local settingsCommon, settingsToggles = Settings.common, Settings.toggles
    local combatType, togglesInOut = CombatType.INCOMING, settingsToggles.incoming

    -- Resolve ability name with all contextual overrides
    abilityName = ResolveAbilityName(abilityId, sourceName)

    -- Bail out if the abilityId is on the Blacklist Table
    if Settings.blacklist[abilityId] or Settings.blacklist[abilityName] then
        return
    end

    -- Check if ability should be hidden from SCT
    local effectHideSCT = EffectHideSCT[abilityId]

    -- Memory optimization: Use pre-computed cache to get all event flags
    local flags = resultTypeCache[result]

    -- Calculate overflow conditions
    local overkill = settingsCommon.overkill and overflow > 0 and
        (flags.isDamage or flags.isDamageCritical or flags.isDot or flags.isDotCritical)
    local overheal = settingsCommon.overheal and overflow > 0 and
        (flags.isHealing or flags.isHealingCritical or flags.isHot or flags.isHotCritical)

    -- Combat event processing
    if ShouldShowCombatEvent(flags, togglesInOut, combatMechanicFlags, hitValue, overkill, overheal) then
        if overkill or overheal then
            hitValue = hitValue + overflow
        end
        if flags.isDrain then
            hitValue = math.abs(hitValue)
        end
        if not effectHideSCT then
            if (settingsToggles.inCombatOnly and isWarned.combat) or not settingsToggles.inCombatOnly then
                local suppressMitigationDuplicate = IsMitigationCombatResult(flags)
                    and IsRecentDuplicateMitigation(combatType, result, abilityId, targetUnitId)
                if not suppressMitigationDuplicate then
                    self:TriggerEvent(EventType.COMBAT, combatType, combatMechanicFlags, hitValue, abilityName, abilityId, damageType, sourceName,
                                      flags.isDamage, flags.isDamageCritical, flags.isHealing, flags.isHealingCritical, flags.isEnergize, flags.isDrain,
                                      flags.isDot, flags.isDotCritical, flags.isHot, flags.isHotCritical, flags.isMiss, flags.isImmune, flags.isParried,
                                      flags.isReflected, flags.isDamageShield, flags.isDodged, flags.isBlocked, flags.isInterrupted)
                end
            end
        end
    end

    -- Crowd control event processing - ONLY call if in combat and ANY CC flag is set
    -- This guard eliminates ~99% of ProcessCrowdControlEvents calls since most combat events have no CC
    if isWarned.combat and (flags.isDisoriented or flags.isFeared or flags.isOffBalanced or flags.isSilenced or flags.isStunned or flags.isCharmed) then
        ProcessCrowdControlEvents(self, flags, togglesInOut, combatType)
    end
end

--- Handle outgoing combat events (player as source)<br>
--- Processes damage, healing, mitigation from player or player pet to other targets<br>
--- Filters duplicate player-to-player events, checks blacklist, triggers combat text
--- @param result ActionResult The combat result type (damage, heal, miss, etc.)
--- @param isError boolean If the combat event represents an error
--- @param abilityName string Base ability name from game API
--- @param abilityGraphic integer Ability visual effect ID
--- @param abilityActionSlotType ActionSlotType The action slot type
--- @param sourceName string Name of the source unit (player/pet)
--- @param sourceType CombatUnitType Type of source unit
--- @param targetName string Name of target unit
--- @param targetType CombatUnitType Type of target unit
--- @param hitValue integer Amount of damage/healing
--- @param combatMechanicFlags integer COMBAT_MECHANIC_FLAGS_* (resource pool for energize/drain, etc.)
--- @param damageType DamageType Type of damage (physical, magic, etc.)
--- @param log boolean If this should be logged
--- @param sourceUnitId integer Unit ID of source
--- @param targetUnitId integer Unit ID of target
--- @param abilityId integer The ability ID
--- @param overflow integer Overkill/overheal amount
function CombatTextCombatEventListener:OnCombatOut(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, combatMechanicFlags, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Don't display duplicate messages for events sourced from the player that target the player
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    local Settings = LUIE.CombatText.SV
    local settingsCommon, settingsToggles = Settings.common, Settings.toggles
    local flags = resultTypeCache[result]
    -- Resource costs are usually reported with the ability's combat target (enemy), so they only hit OnCombatOut.
    -- Route them to the incoming combat-text panel and incoming toggles (self resource feedback).
    local combatType, togglesInOut
    if flags.isDrain then
        combatType = CombatType.INCOMING
        togglesInOut = settingsToggles.incoming
        abilityName = ResolveAbilityName(abilityId, sourceName)
    else
        combatType = CombatType.OUTGOING
        togglesInOut = settingsToggles.outgoing
        abilityName = abilityNameCache[abilityId]
    end

    -- Bail out if the abilityId is on the Blacklist Table
    if Settings.blacklist[abilityId] or Settings.blacklist[abilityName] then
        return
    end

    -- Check if ability should be hidden from SCT
    local effectHideSCT = EffectHideSCT[abilityId]

    -- Calculate overflow conditions
    local overkill = settingsCommon.overkill and overflow > 0 and
        (flags.isDamage or flags.isDamageCritical or flags.isDot or flags.isDotCritical)
    local overheal = settingsCommon.overheal and overflow > 0 and
        (flags.isHealing or flags.isHealingCritical or flags.isHot or flags.isHotCritical)

    -- Combat event processing
    if ShouldShowCombatEvent(flags, togglesInOut, combatMechanicFlags, hitValue, overkill, overheal) then
        if overkill or overheal then
            hitValue = hitValue + overflow
        end
        if flags.isDrain then
            hitValue = math.abs(hitValue)
        end
        if not effectHideSCT then
            if (settingsToggles.inCombatOnly and isWarned.combat) or not settingsToggles.inCombatOnly then
                local suppressDrainDuplicate = flags.isDrain and IsRecentDuplicateDrain(abilityId, combatMechanicFlags, hitValue)
                local suppressMitigationDuplicate = IsMitigationCombatResult(flags)
                    and IsRecentDuplicateMitigation(combatType, result, abilityId, targetUnitId)
                if not suppressDrainDuplicate and not suppressMitigationDuplicate then
                    self:TriggerEvent(EventType.COMBAT, combatType, combatMechanicFlags, hitValue, abilityName, abilityId, damageType, sourceName,
                                      flags.isDamage, flags.isDamageCritical, flags.isHealing, flags.isHealingCritical, flags.isEnergize, flags.isDrain,
                                      flags.isDot, flags.isDotCritical, flags.isHot, flags.isHotCritical, flags.isMiss, flags.isImmune, flags.isParried,
                                      flags.isReflected, flags.isDamageShield, flags.isDodged, flags.isBlocked, flags.isInterrupted)
                end
            end
        end
    end

    -- Crowd control event processing - ONLY call if in combat and ANY CC flag is set
    -- This guard eliminates ~99% of ProcessCrowdControlEvents calls since most combat events have no CC
    if isWarned.combat and (flags.isDisoriented or flags.isFeared or flags.isOffBalanced or flags.isSilenced or flags.isStunned or flags.isCharmed) then
        ProcessCrowdControlEvents(self, flags, togglesInOut, combatType)
    end
end

--- Handle player combat state changes<br>
--- Triggers "In Combat" and "Out of Combat" text notifications based on settings<br>
--- Manages combat state tracking for event filtering
--- @param inCombat boolean True if entering combat, false if leaving combat
function CombatTextCombatEventListener:CombatState(inCombat)
    local Settings = LUIE.CombatText.SV
    local settingsToggles = Settings.toggles

    -- Use the actual inCombat parameter from the game event instead of toggling blindly
    if inCombat and not isWarned.combat then
        -- Entering combat
        isWarned.combat = true
        if settingsToggles.showInCombat then
            self:TriggerEvent(EventType.POINT, PointType.IN_COMBAT, nil)
        end
    elseif not inCombat and isWarned.combat then
        -- Leaving combat
        isWarned.combat = false
        if settingsToggles.showOutCombat then
            self:TriggerEvent(EventType.POINT, PointType.OUT_COMBAT, nil)
        end
    end
    -- else: State hasn't changed (duplicate event or already in correct state) - do nothing
end

--- @class (partial) LuiExtended.CombatTextCombatEventListener : CombatTextCombatEventListener
LUIE.CombatTextCombatEventListener = CombatTextCombatEventListener:Subclass()
