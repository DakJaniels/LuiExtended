-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) CombatTextCombatEventListener : CombatTextEventListener
LUIE.CombatTextCombatEventListener = LUIE.CombatTextEventListener:Subclass()
--- @class (partial) CombatTextCombatEventListener
local CombatTextCombatEventListener = LUIE.CombatTextCombatEventListener

local Effects = LuiData.Data.Effects
local CombatTextConstants = LuiData.Data.CombatTextConstants
local IsCharmAbility = IsCharmAbility

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

--- @diagnostic disable-next-line: duplicate-set-field
function CombatTextCombatEventListener:New()
    local obj = LUIE.CombatTextEventListener:New()
    obj:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function ()
        self:OnPlayerActivated()
    end)
    obj:RegisterForEvent(EVENT_COMBAT_EVENT, function (...)
                             self:OnCombatIn(...)
                         end, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Target -> Player
    obj:RegisterForEvent(EVENT_COMBAT_EVENT, function (...)
                             self:OnCombatOut(...)
                         end, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER) -- Player -> Target
    obj:RegisterForEvent(EVENT_COMBAT_EVENT, function (...)
                             self:OnCombatOut(...)
                         end, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET) -- Player Pet -> Target
    obj:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function ()
        self:CombatState()
    end)

    return obj
end

function CombatTextCombatEventListener:OnPlayerActivated()
    if IsUnitInCombat("player") then
        isWarned.combat = true
    end
end

function CombatTextCombatEventListener:OnCombatIn(...)
    local resultType, isError, abilityName, abilityGraphic, abilityAction_slotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow = ...

    local Settings = LUIE.CombatText.SV
    local combatType, togglesInOut = CombatTextConstants.combatType.INCOMING, Settings.toggles.incoming
    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(abilityId))
    abilityName = cachedName -- zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    local sourceNameCheck = ZO_CachedStrFormat("<<C:1>>", sourceName)

    -- Handle effects that override by UnitName
    if Effects.EffectOverrideByName[abilityId] then
        if Effects.EffectOverrideByName[abilityId][sourceNameCheck] then
            if Effects.EffectOverrideByName[abilityId][sourceNameCheck].name then
                abilityName = Effects.EffectOverrideByName[abilityId][sourceNameCheck].name
            end
        end
    end

    -- Handle effects that override by ZoneId
    if Effects.ZoneDataOverride[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if Effects.ZoneDataOverride[abilityId][index] then
            if Effects.ZoneDataOverride[abilityId][index].name then
                abilityName = Effects.ZoneDataOverride[abilityId][index].name
            end
        end
        if Effects.ZoneDataOverride[abilityId][zoneName] then
            if Effects.ZoneDataOverride[abilityId][zoneName].name then
                abilityName = Effects.ZoneDataOverride[abilityId][zoneName].name
            end
        end
    end

    -- Override name, icon, or hide based on Map Name
    if Effects.MapDataOverride[abilityId] then
        local mapName = GetMapName()
        if Effects.MapDataOverride[abilityId][mapName] then
            if Effects.MapDataOverride[abilityId][mapName].name then
                abilityName = Effects.MapDataOverride[abilityId][mapName].name
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
    -- Damage
    local isDamage, isDamageCritical, isDot, isDotCritical = CombatTextConstants.isDamage[resultType], CombatTextConstants.isDamageCritical[resultType], CombatTextConstants.isDot[resultType], CombatTextConstants.isDotCritical[resultType]
    -- Healing
    local isHealing, isHealingCritical, isHot, isHotCritical = CombatTextConstants.isHealing[resultType], CombatTextConstants.isHealingCritical[resultType], CombatTextConstants.isHot[resultType], CombatTextConstants.isHotCritical[resultType]
    -- Energize & Drain
    local isEnergize, isDrain = CombatTextConstants.isEnergize[resultType], CombatTextConstants.isDrain[resultType]
    -- Mitigation
    local isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted = CombatTextConstants.isMiss[resultType], CombatTextConstants.isImmune[resultType], CombatTextConstants.isParried[resultType], CombatTextConstants.isReflected[resultType], CombatTextConstants.isDamageShield[resultType], CombatTextConstants.isDodged[resultType], CombatTextConstants.isBlocked[resultType], CombatTextConstants.isInterrupted[resultType]
    -- Crowd Control
    local isDisoriented, isFeared, isOffBalanced, isSilenced, isStunned, isCharmed = CombatTextConstants.isDisoriented[resultType], CombatTextConstants.isFeared[resultType], CombatTextConstants.isOffBalanced[resultType], CombatTextConstants.isSilenced[resultType], CombatTextConstants.isStunned[resultType], CombatTextConstants.isCharmed[resultType]
    if not isCharmed and isFeared and IsCharmAbility(abilityId) then
        isFeared = false
        isCharmed = true
    end
    -- Overflow
    local overkill, overheal = (Settings.common.overkill and overflow > 0 and (isDamage or isDamageCritical or isDot or isDotCritical)), (Settings.common.overheal and overflow > 0 and (isHealing or isHealingCritical or isHot or isHotCritical))
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- //COMBAT TRIGGERS//--
    ---------------------------------------------------------------------------------------------------------------------------------------
    if (isDodged and togglesInOut.showDodged) or (isMiss and togglesInOut.showMiss) or (isImmune and togglesInOut.showImmune) or (isReflected and togglesInOut.showReflected) or (isDamageShield and togglesInOut.showDamageShield) or (isParried and togglesInOut.showParried) or (isBlocked and togglesInOut.showBlocked) or (isInterrupted and togglesInOut.showInterrupted) or (isDot and togglesInOut.showDot and (hitValue > 0 or overkill)) or (isDotCritical and togglesInOut.showDot and (hitValue > 0 or overkill)) or (isHot and togglesInOut.showHot and (hitValue > 0 or overheal)) or (isHotCritical and togglesInOut.showHot and (hitValue > 0 or overheal)) or (isHealing and togglesInOut.showHealing and (hitValue > 0 or overheal)) or (isHealingCritical and togglesInOut.showHealing and (hitValue > 0 or overheal)) or (isDamage and togglesInOut.showDamage and (hitValue > 0 or overkill)) or (isDamageCritical and togglesInOut.showDamage and (hitValue > 0 or overkill)) or (isEnergize and togglesInOut.showEnergize and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA)) or (isEnergize and togglesInOut.showUltimateEnergize and powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE) or (isDrain and togglesInOut.showDrain and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA)) then
        if overkill or overheal then
            hitValue = hitValue + overflow
        end
        if not Effects.EffectHideSCT[abilityId] then                                                         -- Check if ability is on the hide list
            if (Settings.toggles.inCombatOnly and isWarned.combat) or not Settings.toggles.inCombatOnly then -- Check if 'in combat only' is ticked
                self:TriggerEvent(CombatTextConstants.eventType.COMBAT, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
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
                PlaySound("Ability_Failed") -- will play a sound every disoriented event afterwards, as any failed action during a CC retriggers the event, causing text flood if buttons are spammed
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.DISORIENTED, combatType)
                isWarned.disoriented = true
                zo_callLater(function ()
                                 isWarned.disoriented = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- Feared
        if isFeared and togglesInOut.showFeared then
            if isWarned.feared then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.FEARED, combatType)
                isWarned.feared = true
                zo_callLater(function ()
                                 isWarned.feared = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- OffBalanced
        if isOffBalanced and togglesInOut.showOffBalanced then
            if isWarned.offBalanced then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.OFFBALANCED, combatType)
                isWarned.offBalanced = true
                zo_callLater(function ()
                                 isWarned.offBalanced = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- Silenced
        if isSilenced and togglesInOut.showSilenced then
            if isWarned.silenced then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.SILENCED, combatType)
                isWarned.silenced = true
                zo_callLater(function ()
                                 isWarned.silenced = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- Stunned
        if isStunned and togglesInOut.showStunned then
            if isWarned.stunned then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.STUNNED, combatType)
                isWarned.stunned = true
                zo_callLater(function ()
                                 isWarned.stunned = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- Charmed
        if isCharmed and togglesInOut.showCharmed then
            if isWarned.charmed then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.CHARMED, combatType)
                isWarned.charmed = true
                zo_callLater(function ()
                                 isWarned.charmed = false
                             end, 1000)
            end -- 1 second buffer
        end
    end
end

function CombatTextCombatEventListener:OnCombatOut(...)
    local resultType, isError, abilityName, abilityGraphic, abilityAction_slotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow = ...

    -- Don't display duplicate messages for events sourced from the player that target the player
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    local Settings = LUIE.CombatText.SV
    local combatType, togglesInOut = CombatTextConstants.combatType.OUTGOING, Settings.toggles.outgoing
    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(abilityId))
    abilityName = cachedName -- zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    -- Bail out if the abilityId is on the Blacklist Table
    if Settings.blacklist[abilityId] or Settings.blacklist[abilityName] then
        return
    end

    ---------------------------------------------------------------------------------------------------------------------------------------
    -- //RESULTS//--
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- Damage
    local isDamage, isDamageCritical, isDot, isDotCritical = CombatTextConstants.isDamage[resultType], CombatTextConstants.isDamageCritical[resultType], CombatTextConstants.isDot[resultType], CombatTextConstants.isDotCritical[resultType]
    -- Healing
    local isHealing, isHealingCritical, isHot, isHotCritical = CombatTextConstants.isHealing[resultType], CombatTextConstants.isHealingCritical[resultType], CombatTextConstants.isHot[resultType], CombatTextConstants.isHotCritical[resultType]
    -- Energize & Drain
    local isEnergize, isDrain = CombatTextConstants.isEnergize[resultType], CombatTextConstants.isDrain[resultType]
    -- Mitigation
    local isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted = CombatTextConstants.isMiss[resultType], CombatTextConstants.isImmune[resultType], CombatTextConstants.isParried[resultType], CombatTextConstants.isReflected[resultType], CombatTextConstants.isDamageShield[resultType], CombatTextConstants.isDodged[resultType], CombatTextConstants.isBlocked[resultType], CombatTextConstants.isInterrupted[resultType]
    -- Crowd Control
    local isDisoriented, isFeared, isOffBalanced, isSilenced, isStunned, isCharmed = CombatTextConstants.isDisoriented[resultType], CombatTextConstants.isFeared[resultType], CombatTextConstants.isOffBalanced[resultType], CombatTextConstants.isSilenced[resultType], CombatTextConstants.isStunned[resultType], CombatTextConstants.isCharmed[resultType]
    if not isCharmed and isFeared and IsCharmAbility(abilityId) then
        isFeared = false
        isCharmed = true
    end
    -- Overflow
    local overkill, overheal = (Settings.common.overkill and overflow > 0 and (isDamage or isDamageCritical or isDot or isDotCritical)), (Settings.common.overheal and overflow > 0 and (isHealing or isHealingCritical or isHot or isHotCritical))
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- //COMBAT TRIGGERS//--
    ---------------------------------------------------------------------------------------------------------------------------------------

    if (isDodged and togglesInOut.showDodged) or (isMiss and togglesInOut.showMiss) or (isImmune and togglesInOut.showImmune) or (isReflected and togglesInOut.showReflected) or (isDamageShield and togglesInOut.showDamageShield) or (isParried and togglesInOut.showParried) or (isBlocked and togglesInOut.showBlocked) or (isInterrupted and togglesInOut.showInterrupted) or (isDot and togglesInOut.showDot and (hitValue > 0 or overkill)) or (isDotCritical and togglesInOut.showDot and (hitValue > 0 or overkill)) or (isHot and togglesInOut.showHot and (hitValue > 0 or overheal)) or (isHotCritical and togglesInOut.showHot and (hitValue > 0 or overheal)) or (isHealing and togglesInOut.showHealing and (hitValue > 0 or overheal)) or (isHealingCritical and togglesInOut.showHealing and (hitValue > 0 or overheal)) or (isDamage and togglesInOut.showDamage and (hitValue > 0 or overkill)) or (isDamageCritical and togglesInOut.showDamage and (hitValue > 0 or overkill)) or (isEnergize and togglesInOut.showEnergize and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA)) or (isEnergize and togglesInOut.showUltimateEnergize and powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE) or (isDrain and togglesInOut.showDrain and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA)) then
        if overkill or overheal then
            hitValue = hitValue + overflow
        end
        if not Effects.EffectHideSCT[abilityId] then                                                         -- Check if ability is on the hide list
            if (Settings.toggles.inCombatOnly and isWarned.combat) or not Settings.toggles.inCombatOnly then -- Check if 'in combat only' is ticked
                self:TriggerEvent(CombatTextConstants.eventType.COMBAT, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
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
                PlaySound("Ability_Failed") -- will play a sound every disoriented event afterwards, as any failed action during a CC retriggers the event, causing text flood if buttons are spammed
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.DISORIENTED, combatType)
                isWarned.disoriented = true
                zo_callLater(function ()
                                 isWarned.disoriented = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- Feared
        if isFeared and togglesInOut.showFeared then
            if isWarned.feared then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.FEARED, combatType)
                isWarned.feared = true
                zo_callLater(function ()
                                 isWarned.feared = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- OffBalanced
        if isOffBalanced and togglesInOut.showOffBalanced then
            if isWarned.offBalanced then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.OFFBALANCED, combatType)
                isWarned.offBalanced = true
                zo_callLater(function ()
                                 isWarned.offBalanced = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- Silenced
        if isSilenced and togglesInOut.showSilenced then
            if isWarned.silenced then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.SILENCED, combatType)
                isWarned.silenced = true
                zo_callLater(function ()
                                 isWarned.silenced = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- Stunned
        if isStunned and togglesInOut.showStunned then
            if isWarned.stunned then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.STUNNED, combatType)
                isWarned.stunned = true
                zo_callLater(function ()
                                 isWarned.stunned = false
                             end, 1000)
            end -- 1 second buffer
        end
        -- Charmed
        if isCharmed and togglesInOut.showCharmed then
            if isWarned.charmed then
                PlaySound("Ability_Failed")
            else
                self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, CombatTextConstants.crowdControlType.CHARMED, combatType)
                isWarned.charmed = true
                zo_callLater(function ()
                                 isWarned.charmed = false
                             end, 1000)
            end -- 1 second buffer
        end
    end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- //COMBAT STATE EVENTS & TRIGGERS//--
---------------------------------------------------------------------------------------------------------------------------------------
function CombatTextCombatEventListener:CombatState(inCombat)
    local Settings = LUIE.CombatText.SV

    if not isWarned.combat then
        isWarned.combat = true
        if Settings.toggles.showInCombat then
            self:TriggerEvent(CombatTextConstants.eventType.POINT, CombatTextConstants.pointType.IN_COMBAT, nil)
        end
    else
        isWarned.combat = false
        if Settings.toggles.showOutCombat then
            self:TriggerEvent(CombatTextConstants.eventType.POINT, CombatTextConstants.pointType.OUT_COMBAT, nil)
        end
    end
end
