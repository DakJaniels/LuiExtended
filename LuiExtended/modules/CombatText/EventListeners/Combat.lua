-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextCombatEventListener : LuiExtended.CombatTextEventListener
local CombatTextCombatEventListener = LUIE.CombatTextEventListener:Subclass()

--- @class (partial) LuiExtended.CombatTextCombatEventListener
LUIE.CombatTextCombatEventListener = CombatTextCombatEventListener

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

-- Memory optimization: Cache formatted ability names to avoid repeated string allocations
local abilityNameCache = setmetatable({},
                                      {
                                          __index = function (t, abilityId)
                                              local name = zo_strformat("<<C:1>>", GetAbilityName(abilityId))
                                              t[abilityId] = name
                                              return name
                                          end
                                      })

-- Memory optimization: Cache formatted source names
local sourceNameCache = setmetatable({},
                                     {
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

--- @param zoneName string|nil
--- @param zoneId integer|nil
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

function CombatTextCombatEventListener:OnPlayerActivated()
    updateZoneCache() -- Initialize zone cache
    if IsUnitInCombat("player") then
        isWarned.combat = true
    end
end

--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function CombatTextCombatEventListener:OnCombatIn(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local Settings = LUIE.CombatText.SV
    local settingsCommon, settingsToggles = Settings.common, Settings.toggles
    local combatType, togglesInOut = CombatType.INCOMING, settingsToggles.incoming
    abilityName = abilityNameCache[abilityId]

    -- Memory optimization: Cache Effects table lookups
    local effectOverrideByName = EffectOverrideByName[abilityId]
    local effectZoneOverride = ZoneDataOverride[abilityId]
    local effectMapOverride = MapDataOverride[abilityId]
    local effectHideSCT = EffectHideSCT[abilityId]

    local sourceNameCheck = sourceNameCache[sourceName]

    -- Handle effects that override by UnitName
    if effectOverrideByName then
        if effectOverrideByName[sourceNameCheck] then
            if effectOverrideByName[sourceNameCheck].name then
                abilityName = effectOverrideByName[sourceNameCheck].name
            end
        end
    end

    -- Handle effects that override by ZoneId (using cached zone data)
    if effectZoneOverride then
        if effectZoneOverride[cachedZoneData.zoneId] then
            if effectZoneOverride[cachedZoneData.zoneId].name then
                abilityName = effectZoneOverride[cachedZoneData.zoneId].name
            end
        end
        if effectZoneOverride[cachedZoneData.zoneName] then
            if effectZoneOverride[cachedZoneData.zoneName].name then
                abilityName = effectZoneOverride[cachedZoneData.zoneName].name
            end
        end
    end

    -- Override name, icon, or hide based on Map Name (using cached map data)
    if effectMapOverride then
        if effectMapOverride[cachedZoneData.mapName] then
            if effectMapOverride[cachedZoneData.mapName].name then
                abilityName = effectMapOverride[cachedZoneData.mapName].name
            end
        end
    end

    -- Bail out if the abilityId is on the Blacklist Table
    if Settings.blacklist[abilityId] or Settings.blacklist[abilityName] then
        return
    end

    ---------------------------------------------------------------------------------------------------------------------------------------
    -- //RESULTS//--
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- Memory optimization: Use pre-computed cache instead of 24+ table lookups
    local rt = resultTypeCache[result]
    local isDamage, isDamageCritical, isDot, isDotCritical = rt.isDamage, rt.isDamageCritical, rt.isDot, rt.isDotCritical
    local isHealing, isHealingCritical, isHot, isHotCritical = rt.isHealing, rt.isHealingCritical, rt.isHot, rt.isHotCritical
    local isEnergize, isDrain = rt.isEnergize, rt.isDrain
    local isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted = rt.isMiss, rt.isImmune, rt.isParried, rt.isReflected, rt.isDamageShield, rt.isDodged, rt.isBlocked, rt.isInterrupted
    local isDisoriented, isFeared, isOffBalanced, isSilenced, isStunned, isCharmed = rt.isDisoriented, rt.isFeared, rt.isOffBalanced, rt.isSilenced, rt.isStunned, rt.isCharmed
    -- Overflow
    local overkill, overheal = (settingsCommon.overkill and overflow > 0 and (isDamage or isDamageCritical or isDot or isDotCritical)), (settingsCommon.overheal and overflow > 0 and (isHealing or isHealingCritical or isHot or isHotCritical))
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- //COMBAT TRIGGERS//--
    ---------------------------------------------------------------------------------------------------------------------------------------
    if
       (isDodged and togglesInOut.showDodged)
    or (isMiss and togglesInOut.showMiss)
    or (isImmune and togglesInOut.showImmune)
    or (isReflected and togglesInOut.showReflected)
    or (isDamageShield and togglesInOut.showDamageShield)
    or (isParried and togglesInOut.showParried)
    or (isBlocked and togglesInOut.showBlocked)
    or (isInterrupted and togglesInOut.showInterrupted)
    or (isDot and togglesInOut.showDot and (hitValue > 0 or overkill))
    or (isDotCritical and togglesInOut.showDot and (hitValue > 0 or overkill))
    or (isHot and togglesInOut.showHot and (hitValue > 0 or overheal))
    or (isHotCritical and togglesInOut.showHot and (hitValue > 0 or overheal))
    or (isHealing and togglesInOut.showHealing and (hitValue > 0 or overheal))
    or (isHealingCritical and togglesInOut.showHealing and (hitValue > 0 or overheal))
    or (isDamage and togglesInOut.showDamage and (hitValue > 0 or overkill))
    or (isDamageCritical and togglesInOut.showDamage and (hitValue > 0 or overkill))
    or (isEnergize and togglesInOut.showEnergize and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA))
    or (isEnergize and togglesInOut.showUltimateEnergize and powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE)
    or (isDrain and togglesInOut.showDrain and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA))
    then
        if overkill or overheal then
            hitValue = hitValue + overflow
        end
        if not effectHideSCT then                                                                          -- Check if ability is on the hide list
            if (settingsToggles.inCombatOnly and isWarned.combat) or not settingsToggles.inCombatOnly then -- Check if 'in combat only' is ticked
                self:TriggerEvent(EventType.COMBAT, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
            end
        end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- //CROWD CONTROL TRIGGERS//--
    ---------------------------------------------------------------------------------------------------------------------------------------
    if isWarned.combat then -- Only show CC/Debuff events when in combat
        -- Disoriented
        if isDisoriented and togglesInOut.showDisoriented then
            if isWarned.disoriented then
                PlaySound(SOUND_ABILITY_FAILED) -- will play a sound every disoriented event afterwards, as any failed action during a CC retriggers the event, causing text flood if buttons are spammed
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.DISORIENTED, combatType)
                isWarned.disoriented = true
                LUIE_callLater(function () resetCCWarning("disoriented") end, 1000)
            end -- 1 second buffer
        end
        -- Feared
        if isFeared and togglesInOut.showFeared then
            if isWarned.feared then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.FEARED, combatType)
                isWarned.feared = true
                LUIE_callLater(function () resetCCWarning("feared") end, 1000)
            end -- 1 second buffer
        end
        -- OffBalanced
        if isOffBalanced and togglesInOut.showOffBalanced then
            if isWarned.offBalanced then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.OFFBALANCED, combatType)
                isWarned.offBalanced = true
                LUIE_callLater(function () resetCCWarning("offBalanced") end, 1000)
            end -- 1 second buffer
        end
        -- Silenced
        if isSilenced and togglesInOut.showSilenced then
            if isWarned.silenced then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.SILENCED, combatType)
                isWarned.silenced = true
                LUIE_callLater(function () resetCCWarning("silenced") end, 1000)
            end -- 1 second buffer
        end
        -- Stunned
        if isStunned and togglesInOut.showStunned then
            if isWarned.stunned then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.STUNNED, combatType)
                isWarned.stunned = true
                LUIE_callLater(function () resetCCWarning("stunned") end, 1000)
            end -- 1 second buffer
        end
        -- Charmed
        if isCharmed and togglesInOut.showCharmed then
            if isWarned.charmed then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.CHARMED, combatType)
                isWarned.charmed = true
                LUIE_callLater(function () resetCCWarning("charmed") end, 1000)
            end -- 1 second buffer
        end
    end
end

--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function CombatTextCombatEventListener:OnCombatOut(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Don't display duplicate messages for events sourced from the player that target the player
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    local Settings = LUIE.CombatText.SV
    local settingsCommon, settingsToggles = Settings.common, Settings.toggles
    local combatType, togglesInOut = CombatType.OUTGOING, settingsToggles.outgoing
    abilityName = abilityNameCache[abilityId]

    -- Memory optimization: Cache Effects table lookup
    local effectHideSCT = EffectHideSCT[abilityId]

    -- Bail out if the abilityId is on the Blacklist Table
    if Settings.blacklist[abilityId] or Settings.blacklist[abilityName] then
        return
    end

    ---------------------------------------------------------------------------------------------------------------------------------------
    --- *RESULTS*
    ---------------------------------------------------------------------------------------------------------------------------------------
    local rt = resultTypeCache[result]
    local isDamage, isDamageCritical, isDot, isDotCritical = rt.isDamage, rt.isDamageCritical, rt.isDot, rt.isDotCritical
    local isHealing, isHealingCritical, isHot, isHotCritical = rt.isHealing, rt.isHealingCritical, rt.isHot, rt.isHotCritical
    local isEnergize, isDrain = rt.isEnergize, rt.isDrain
    local isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted = rt.isMiss, rt.isImmune, rt.isParried, rt.isReflected, rt.isDamageShield, rt.isDodged, rt.isBlocked, rt.isInterrupted
    local isDisoriented, isFeared, isOffBalanced, isSilenced, isStunned, isCharmed = rt.isDisoriented, rt.isFeared, rt.isOffBalanced, rt.isSilenced, rt.isStunned, rt.isCharmed
    -- Overflow
    local overkill, overheal = (settingsCommon.overkill and overflow > 0 and (isDamage or isDamageCritical or isDot or isDotCritical)), (settingsCommon.overheal and overflow > 0 and (isHealing or isHealingCritical or isHot or isHotCritical))

    ---------------------------------------------------------------------------------------------------------------------------------------
    --- *COMBAT TRIGGERS*
    ---------------------------------------------------------------------------------------------------------------------------------------
    if
       (isDodged and togglesInOut.showDodged)
    or (isMiss and togglesInOut.showMiss)
    or (isImmune and togglesInOut.showImmune)
    or (isReflected and togglesInOut.showReflected)
    or (isDamageShield and togglesInOut.showDamageShield)
    or (isParried and togglesInOut.showParried)
    or (isBlocked and togglesInOut.showBlocked)
    or (isInterrupted and togglesInOut.showInterrupted)
    or (isDot and togglesInOut.showDot and (hitValue > 0 or overkill))
    or (isDotCritical and togglesInOut.showDot and (hitValue > 0 or overkill))
    or (isHot and togglesInOut.showHot and (hitValue > 0 or overheal))
    or (isHotCritical and togglesInOut.showHot and (hitValue > 0 or overheal))
    or (isHealing and togglesInOut.showHealing and (hitValue > 0 or overheal))
    or (isHealingCritical and togglesInOut.showHealing and (hitValue > 0 or overheal))
    or (isDamage and togglesInOut.showDamage and (hitValue > 0 or overkill))
    or (isDamageCritical and togglesInOut.showDamage and (hitValue > 0 or overkill))
    or (isEnergize and togglesInOut.showEnergize and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA))
    or (isEnergize and togglesInOut.showUltimateEnergize and powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE)
    or (isDrain and togglesInOut.showDrain and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA))
    then
        if overkill or overheal then
            hitValue = hitValue + overflow
        end
        if not effectHideSCT then                                                                          -- Check if ability is on the hide list
            if (settingsToggles.inCombatOnly and isWarned.combat) or not settingsToggles.inCombatOnly then -- Check if 'in combat only' is ticked
                self:TriggerEvent(EventType.COMBAT, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
            end
        end
    end
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- //CROWD CONTROL TRIGGERS//--
    ---------------------------------------------------------------------------------------------------------------------------------------
    if isWarned.combat then -- Only show CC/Debuff events when in combat
        -- Disoriented
        if isDisoriented and togglesInOut.showDisoriented then
            if isWarned.disoriented then
                PlaySound(SOUND_ABILITY_FAILED) -- will play a sound every disoriented event afterwards, as any failed action during a CC retriggers the event, causing text flood if buttons are spammed
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.DISORIENTED, combatType)
                isWarned.disoriented = true
                LUIE_callLater(function () resetCCWarning("disoriented") end, 1000)
            end -- 1 second buffer
        end
        -- Feared
        if isFeared and togglesInOut.showFeared then
            if isWarned.feared then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.FEARED, combatType)
                isWarned.feared = true
                LUIE_callLater(function () resetCCWarning("feared") end, 1000)
            end -- 1 second buffer
        end
        -- OffBalanced
        if isOffBalanced and togglesInOut.showOffBalanced then
            if isWarned.offBalanced then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.OFFBALANCED, combatType)
                isWarned.offBalanced = true
                LUIE_callLater(function () resetCCWarning("offBalanced") end, 1000)
            end -- 1 second buffer
        end
        -- Silenced
        if isSilenced and togglesInOut.showSilenced then
            if isWarned.silenced then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.SILENCED, combatType)
                isWarned.silenced = true
                LUIE_callLater(function () resetCCWarning("silenced") end, 1000)
            end -- 1 second buffer
        end
        -- Stunned
        if isStunned and togglesInOut.showStunned then
            if isWarned.stunned then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.STUNNED, combatType)
                isWarned.stunned = true
                LUIE_callLater(function () resetCCWarning("stunned") end, 1000)
            end -- 1 second buffer
        end
        -- Charmed
        if isCharmed and togglesInOut.showCharmed then
            if isWarned.charmed then
                PlaySound(SOUND_ABILITY_FAILED)
            else
                self:TriggerEvent(EventType.CROWDCONTROL, CrowdControlType.CHARMED, combatType)
                isWarned.charmed = true
                LUIE_callLater(function () resetCCWarning("charmed") end, 1000)
            end -- 1 second buffer
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------
--- - COMBAT STATE EVENTS & TRIGGERS
---------------------------------------------------------------------------------------------------------------------------------------
---
--- @param inCombat boolean
function CombatTextCombatEventListener:CombatState(inCombat)
    local Settings = LUIE.CombatText.SV
    local settingsToggles = Settings.toggles

    if not isWarned.combat then
        isWarned.combat = true
        if settingsToggles.showInCombat then
            self:TriggerEvent(EventType.POINT, PointType.IN_COMBAT, nil)
        end
    else
        isWarned.combat = false
        if settingsToggles.showOutCombat then
            self:TriggerEvent(EventType.POINT, PointType.OUT_COMBAT, nil)
        end
    end
end
