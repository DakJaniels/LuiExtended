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

-- Table cache moved to CombatText.lua for shared access across all viewers
-- Use LUIE.GetCachedTable() and LUIE.RecycleTable() instead

-- Memory optimization: Cache formatted ability names to avoid repeated string allocations
-- Uses weak values (__mode='v') to allow garbage collection of unused entries
local abilityNameCache = setmetatable({},
                                      {
                                          __mode = "v", -- Weak values: entries can be GC'd when no longer referenced
                                          __index = function (t, abilityId)
                                              local name = ZO_CachedStrFormat("<<C:1>>", GetAbilityName(abilityId))
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
                                             local formatted = ZO_CachedStrFormat("<<C:1>>", sourceName)
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
--- @param powerType integer Combat mechanic flags
--- @param hitValue integer The damage/healing value
--- @param overkill boolean If this is overkill damage
--- @param overheal boolean If this is overheal
--- @return boolean shouldShow True if event should be displayed
local function ShouldShowCombatEvent(flags, toggles, powerType, hitValue, overkill, overheal)
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
        or (flags.isEnergize and toggles.showEnergize and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA))
        or (flags.isEnergize and toggles.showUltimateEnergize and powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE)
        or (flags.isDrain and toggles.showDrain and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA))
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
                LUIE_callLater(function () resetCCWarning(config.warnKey) end, 1000)
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
    self:RegisterForEvent(EVENT_COMBAT_EVENT, function (result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                              self:OnCombatIn(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                          end, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Target -> Player
    self:RegisterForEvent(EVENT_COMBAT_EVENT, function (result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                              self:OnCombatOut(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                          end, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Player -> Target
    self:RegisterForEvent(EVENT_COMBAT_EVENT, function (result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                              self:OnCombatOut(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                          end, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET) -- Player Pet -> Target
    self:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function (inCombat)
        self:CombatState(inCombat)
    end)
    -- Memory optimization: Update zone cache on zone changes
    self:RegisterForEvent(EVENT_ZONE_CHANGED, function (zoneName, subZoneName, newSubzone, zoneId, subZoneId)
        updateZoneCache(zoneName, zoneId)
    end)
end

--- Handle player activation event<br>
--- Initializes zone cache and sets combat state if player is already in combat
function CombatTextCombatEventListener:OnPlayerActivated()
    updateZoneCache() -- Initialize zone cache
    if IsUnitInCombat("player") then
        isWarned.combat = true
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
--- @param powerType CombatMechanicFlags Resource type (health, magicka, stamina, ultimate)
--- @param damageType DamageType Type of damage (physical, magic, etc.)
--- @param log boolean If this should be logged
--- @param sourceUnitId integer Unit ID of source
--- @param targetUnitId integer Unit ID of target
--- @param abilityId integer The ability ID
--- @param overflow integer Overkill/overheal amount
function CombatTextCombatEventListener:OnCombatIn(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
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
    if ShouldShowCombatEvent(flags, togglesInOut, powerType, hitValue, overkill, overheal) then
        if overkill or overheal then
            hitValue = hitValue + overflow
        end
        if not effectHideSCT then
            if (settingsToggles.inCombatOnly and isWarned.combat) or not settingsToggles.inCombatOnly then
                self:TriggerEvent(EventType.COMBAT, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName,
                                  flags.isDamage, flags.isDamageCritical, flags.isHealing, flags.isHealingCritical, flags.isEnergize, flags.isDrain,
                                  flags.isDot, flags.isDotCritical, flags.isHot, flags.isHotCritical, flags.isMiss, flags.isImmune, flags.isParried,
                                  flags.isReflected, flags.isDamageShield, flags.isDodged, flags.isBlocked, flags.isInterrupted)
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
--- @param powerType CombatMechanicFlags Resource type (health, magicka, stamina, ultimate)
--- @param damageType DamageType Type of damage (physical, magic, etc.)
--- @param log boolean If this should be logged
--- @param sourceUnitId integer Unit ID of source
--- @param targetUnitId integer Unit ID of target
--- @param abilityId integer The ability ID
--- @param overflow integer Overkill/overheal amount
function CombatTextCombatEventListener:OnCombatOut(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Don't display duplicate messages for events sourced from the player that target the player
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    local Settings = LUIE.CombatText.SV
    local settingsCommon, settingsToggles = Settings.common, Settings.toggles
    local combatType, togglesInOut = CombatType.OUTGOING, settingsToggles.outgoing

    -- Use cached ability name (no overrides needed for outgoing - player abilities)
    abilityName = abilityNameCache[abilityId]

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
    if ShouldShowCombatEvent(flags, togglesInOut, powerType, hitValue, overkill, overheal) then
        if overkill or overheal then
            hitValue = hitValue + overflow
        end
        if not effectHideSCT then
            if (settingsToggles.inCombatOnly and isWarned.combat) or not settingsToggles.inCombatOnly then
                self:TriggerEvent(EventType.COMBAT, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName,
                                  flags.isDamage, flags.isDamageCritical, flags.isHealing, flags.isHealingCritical, flags.isEnergize, flags.isDrain,
                                  flags.isDot, flags.isDotCritical, flags.isHot, flags.isHotCritical, flags.isMiss, flags.isImmune, flags.isParried,
                                  flags.isReflected, flags.isDamageShield, flags.isDodged, flags.isBlocked, flags.isInterrupted)
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
