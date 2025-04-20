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

local Effects = LUIE.Data.Effects
local CombatTextConstants = LUIE.Data.CombatTextConstants

-- Local state for CC rate limiting (keeps track of recent warnings)
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

-- Map CC type constants to the keys used in the isWarned table
local CROWD_CONTROL_TYPE_TO_KEY =
{
    [CombatTextConstants.crowdControlType.DISORIENTED] = "disoriented",
    [CombatTextConstants.crowdControlType.FEARED] = "feared",
    [CombatTextConstants.crowdControlType.OFFBALANCED] = "offBalanced",
    [CombatTextConstants.crowdControlType.SILENCED] = "silenced",
    [CombatTextConstants.crowdControlType.STUNNED] = "stunned",
    [CombatTextConstants.crowdControlType.CHARMED] = "charmed",
}

-- =============================================================================
-- Helper Functions (Stateless)
-- =============================================================================

--- Parses the combat event result type into a table of boolean flags.
--- @param resultType number The combat event result type.
--- @return table A table containing boolean flags for different event categories.
local function ParseCombatResult(resultType)
    local results = {}
    -- Damage
    results.isDamage, results.isDamageCritical = CombatTextConstants.isDamage[resultType], CombatTextConstants.isDamageCritical[resultType]
    results.isDot, results.isDotCritical = CombatTextConstants.isDot[resultType], CombatTextConstants.isDotCritical[resultType]
    -- Healing
    results.isHealing, results.isHealingCritical = CombatTextConstants.isHealing[resultType], CombatTextConstants.isHealingCritical[resultType]
    results.isHot, results.isHotCritical = CombatTextConstants.isHot[resultType], CombatTextConstants.isHotCritical[resultType]
    -- Energize & Drain
    results.isEnergize, results.isDrain = CombatTextConstants.isEnergize[resultType], CombatTextConstants.isDrain[resultType]
    -- Mitigation
    results.isMiss, results.isImmune = CombatTextConstants.isMiss[resultType], CombatTextConstants.isImmune[resultType]
    results.isParried, results.isReflected = CombatTextConstants.isParried[resultType], CombatTextConstants.isReflected[resultType]
    results.isDamageShield, results.isDodged = CombatTextConstants.isDamageShield[resultType], CombatTextConstants.isDodged[resultType]
    results.isBlocked, results.isInterrupted = CombatTextConstants.isBlocked[resultType], CombatTextConstants.isInterrupted[resultType]
    -- Crowd Control
    results.isDisoriented, results.isFeared = CombatTextConstants.isDisoriented[resultType], CombatTextConstants.isFeared[resultType]
    results.isOffBalanced, results.isSilenced = CombatTextConstants.isOffBalanced[resultType], CombatTextConstants.isSilenced[resultType]
    results.isStunned, results.isCharmed = CombatTextConstants.isStunned[resultType], CombatTextConstants.isCharmed[resultType]
    return results
end

--- Gets the potentially overridden ability name based on various context factors (Unit Name, Zone, Map).
--- Note: This currently only seems to be used for incoming events based on original code.
--- @param abilityId number The ability ID.
--- @param originalAbilityName string The default ability name.
--- @param sourceName string The source unit's name.
--- @return string The effective ability name after applying overrides.
local function GetOverriddenAbilityName(abilityId, originalAbilityName, sourceName)
    local name = originalAbilityName

    -- Check for UnitName override
    if Effects.EffectOverrideByName and Effects.EffectOverrideByName[abilityId] then
        local sourceNameCheck = zo_strformat("<<C:1>>", sourceName)
        if Effects.EffectOverrideByName[abilityId][sourceNameCheck] and Effects.EffectOverrideByName[abilityId][sourceNameCheck].name then
            name = Effects.EffectOverrideByName[abilityId][sourceNameCheck].name
        end
    end

    -- Check for Zone override
    if Effects.ZoneDataOverride and Effects.ZoneDataOverride[abilityId] then
        local zoneId = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if Effects.ZoneDataOverride[abilityId][zoneId] and Effects.ZoneDataOverride[abilityId][zoneId].name then
            name = Effects.ZoneDataOverride[abilityId][zoneId].name
        elseif Effects.ZoneDataOverride[abilityId][zoneName] and Effects.ZoneDataOverride[abilityId][zoneName].name then
            name = Effects.ZoneDataOverride[abilityId][zoneName].name
        end
    end

    -- Check for Map override
    if Effects.MapDataOverride and Effects.MapDataOverride[abilityId] then
        local mapName = GetMapName()
        if Effects.MapDataOverride[abilityId][mapName] and Effects.MapDataOverride[abilityId][mapName].name then
            name = Effects.MapDataOverride[abilityId][mapName].name
        end
    end

    return name
end

--- Checks if an ability is blacklisted in the settings.
--- @param Settings table The CombatText settings table.
--- @param abilityId number The ability ID.
--- @param abilityName string The ability name.
--- @return boolean True if the ability is blacklisted, false otherwise.
local function IsAbilityBlacklisted(Settings, abilityId, abilityName)
    -- Using explicit nil checks just to be safe with potential table lookups
    if Settings.blacklist and (Settings.blacklist[abilityId] ~= nil or Settings.blacklist[abilityName] ~= nil) then
        return true
    end
    return false
end

-- =============================================================================
-- CombatTextCombatEventListener Class Methods
-- =============================================================================

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

--- Handles incoming combat events (Target == Player).
function CombatTextCombatEventListener:OnCombatIn(...)
    local resultType, isError, _, abilityGraphic, abilityAction_slotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow = ... -- Renamed abilityName locally

    local Settings = LUIE.CombatText.SV
    if not Settings or not Settings.toggles or not Settings.common or not Settings.blacklist then
        -- d("CombatText Settings not fully loaded for OnCombatIn") -- Optional debug
        return -- Bail out if settings aren't ready
    end

    local combatType = CombatTextConstants.combatType.INCOMING
    local togglesInOut = Settings.toggles.incoming

    -- Get base and potentially overridden ability name
    local baseAbilityName = GetAbilityName(abilityId)
    local abilityName = GetOverriddenAbilityName(abilityId, baseAbilityName, sourceName)
    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, abilityName) -- Use overridden name for caching/display
    abilityName = cachedName                                            -- Assign cached/overridden name

    -- Bail out if the abilityId is on the Blacklist Table
    if IsAbilityBlacklisted(Settings, abilityId, abilityName) then
        return
    end

    -- Parse the result type into boolean flags
    local parsedResults = ParseCombatResult(resultType)

    -- Process the main combat event trigger (damage, healing, mitigation, etc.)
    self:ProcessCombatEventTrigger(parsedResults, togglesInOut, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName, overflow)

    -- Process Crowd Control triggers if applicable
    if isWarned.combat then -- Only show CC/Debuff events when in combat
        self:ProcessCrowdControlTriggers(parsedResults, togglesInOut, combatType)
    end
end

--- Handles outgoing combat events (Source == Player or Player Pet).
function CombatTextCombatEventListener:OnCombatOut(...)
    local resultType, isError, _, abilityGraphic, abilityAction_slotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow = ... -- Renamed abilityName locally

    -- Don't display duplicate messages for events sourced from the player/pet that target the player/pet
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    local Settings = LUIE.CombatText.SV
    if not Settings or not Settings.toggles or not Settings.common or not Settings.blacklist then
        -- d("CombatText Settings not fully loaded for OnCombatOut") -- Optional debug
        return -- Bail out if settings aren't ready
    end

    local combatType = CombatTextConstants.combatType.OUTGOING
    local togglesInOut = Settings.toggles.outgoing

    -- Get base ability name (Overrides not applied here in original code)
    local abilityName = GetAbilityName(abilityId)
    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, abilityName)
    abilityName = cachedName

    -- Bail out if the abilityId is on the Blacklist Table
    if IsAbilityBlacklisted(Settings, abilityId, abilityName) then
        return
    end

    -- Parse the result type into boolean flags
    local parsedResults = ParseCombatResult(resultType)

    -- Process the main combat event trigger (damage, healing, mitigation, etc.)
    self:ProcessCombatEventTrigger(parsedResults, togglesInOut, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName, overflow)

    -- Process Crowd Control triggers if applicable
    if isWarned.combat then -- Only show CC/Debuff events when in combat
        self:ProcessCrowdControlTriggers(parsedResults, togglesInOut, combatType)
    end
end

--- Processes the main combat event trigger based on parsed results and settings.
--- @param parsedResults table Table of boolean flags from ParseCombatResult.
--- @param toggles table The relevant settings toggle table (incoming or outgoing).
--- @param combatType number The combat type (INCOMING or OUTGOING).
--- @param powerType number The power type involved (Magicka, Stamina, Ultimate, etc.).
--- @param hitValue number The base value of the hit/heal/etc.
--- @param abilityName string The effective ability name.
--- @param abilityId number The ability ID.
--- @param damageType number The type of damage, if applicable.
--- @param sourceName string The name of the source unit.
--- @param overflow number The amount of overkill or overheal.
function CombatTextCombatEventListener:ProcessCombatEventTrigger(parsedResults, toggles, combatType, powerType, hitValue, abilityName, abilityId, damageType, sourceName, overflow)
    local Settings = LUIE.CombatText.SV -- Access settings directly

    -- Deconstruct parsedResults for slightly easier reading (optional, but can help)
    local isDamage, isDamageCritical, isDot, isDotCritical = parsedResults.isDamage, parsedResults.isDamageCritical, parsedResults.isDot, parsedResults.isDotCritical
    local isHealing, isHealingCritical, isHot, isHotCritical = parsedResults.isHealing, parsedResults.isHealingCritical, parsedResults.isHot, parsedResults.isHotCritical
    local isEnergize, isDrain = parsedResults.isEnergize, parsedResults.isDrain
    local isMiss, isImmune, isParried, isReflected = parsedResults.isMiss, parsedResults.isImmune, parsedResults.isParried, parsedResults.isReflected
    local isDamageShield, isDodged, isBlocked, isInterrupted = parsedResults.isDamageShield, parsedResults.isDodged, parsedResults.isBlocked, parsedResults.isInterrupted

    -- Calculate Overkill/Overheal flags based on settings
    local overkill = (Settings.common.overkill and overflow > 0 and (isDamage or isDamageCritical or isDot or isDotCritical))
    local overheal = (Settings.common.overheal and overflow > 0 and (isHealing or isHealingCritical or isHot or isHotCritical))

    -- Calculate the effective value including overflow if applicable
    local effectiveHitValue = hitValue
    if overkill or overheal then
        effectiveHitValue = hitValue + overflow
    end

    -- Determine if the event should be shown based on type and toggles
    local shouldShow = false
    if (isDodged and toggles.showDodged) then
        shouldShow = true
    elseif (isMiss and toggles.showMiss) then
        shouldShow = true
    elseif (isImmune and toggles.showImmune) then
        shouldShow = true
    elseif (isReflected and toggles.showReflected) then
        shouldShow = true
    elseif (isDamageShield and toggles.showDamageShield) then
        shouldShow = true
    elseif (isParried and toggles.showParried) then
        shouldShow = true
    elseif (isBlocked and toggles.showBlocked) then
        shouldShow = true
    elseif (isInterrupted and toggles.showInterrupted) then
        shouldShow = true
        -- Conditions with hitValue/overkill/overheal checks (using original logic structure)
    elseif (isDot and toggles.showDot and (hitValue > 0 or overkill)) then
        shouldShow = true
    elseif (isDotCritical and toggles.showDot and (hitValue > 0 or overkill)) then
        shouldShow = true
    elseif (isHot and toggles.showHot and (hitValue > 0 or overheal)) then
        shouldShow = true
    elseif (isHotCritical and toggles.showHot and (hitValue > 0 or overheal)) then
        shouldShow = true
    elseif (isHealing and toggles.showHealing and (hitValue > 0 or overheal)) then
        shouldShow = true
    elseif (isHealingCritical and toggles.showHealing and (hitValue > 0 or overheal)) then
        shouldShow = true
    elseif (isDamage and toggles.showDamage and (hitValue > 0 or overkill)) then
        shouldShow = true
    elseif (isDamageCritical and toggles.showDamage and (hitValue > 0 or overkill)) then
        shouldShow = true
        -- Energize/Drain checks
    elseif (isEnergize and toggles.showEnergize and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA)) then
        shouldShow = true
    elseif (isEnergize and toggles.showUltimateEnergize and powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE) then
        shouldShow = true
    elseif (isDrain and toggles.showDrain and (powerType == COMBAT_MECHANIC_FLAGS_MAGICKA or powerType == COMBAT_MECHANIC_FLAGS_STAMINA)) then
        shouldShow = true
    end

    -- Trigger the event if it passed the checks and isn't hidden/filtered
    if shouldShow then
        if not Effects.EffectHideSCT or Effects.EffectHideSCT[abilityId] == nil then                         -- Check if ability is NOT on the hide list
            if (Settings.toggles.inCombatOnly and isWarned.combat) or not Settings.toggles.inCombatOnly then -- Check if 'in combat only' is ticked
                -- Trigger the event using the effectiveHitValue
                self:TriggerEvent(CombatTextConstants.eventType.COMBAT, combatType, powerType, effectiveHitValue, abilityName, abilityId, damageType, sourceName,
                    isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain,
                    isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried,
                    isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
            end
        end
    end
end

--- Processes crowd control event triggers based on parsed results and settings.
--- @param parsedResults table Table of boolean flags from ParseCombatResult.
--- @param toggles table The relevant settings toggle table (incoming or outgoing).
--- @param combatType number The combat type (INCOMING or OUTGOING).
function CombatTextCombatEventListener:ProcessCrowdControlTriggers(parsedResults, toggles, combatType)
    -- Disoriented
    if parsedResults.isDisoriented then
        self:HandleCrowdControlTrigger(CombatTextConstants.crowdControlType.DISORIENTED, toggles.showDisoriented, combatType)
    end
    -- Feared
    if parsedResults.isFeared then
        self:HandleCrowdControlTrigger(CombatTextConstants.crowdControlType.FEARED, toggles.showFeared, combatType)
    end
    -- OffBalanced
    if parsedResults.isOffBalanced then
        self:HandleCrowdControlTrigger(CombatTextConstants.crowdControlType.OFFBALANCED, toggles.showOffBalanced, combatType)
    end
    -- Silenced
    if parsedResults.isSilenced then
        self:HandleCrowdControlTrigger(CombatTextConstants.crowdControlType.SILENCED, toggles.showSilenced, combatType)
    end
    -- Stunned
    if parsedResults.isStunned then
        self:HandleCrowdControlTrigger(CombatTextConstants.crowdControlType.STUNNED, toggles.showStunned, combatType)
    end
    -- Charmed
    if parsedResults.isCharmed then
        self:HandleCrowdControlTrigger(CombatTextConstants.crowdControlType.CHARMED, toggles.showCharmed, combatType)
    end
end

--- Handles the logic for a single crowd control type, including rate limiting.
--- @param ccType number The crowd control type constant (e.g., CombatTextConstants.crowdControlType.STUNNED).
--- @param toggleSetting boolean The corresponding toggle setting value (e.g., toggles.showStunned).
--- @param combatType number The combat type (INCOMING or OUTGOING).
function CombatTextCombatEventListener:HandleCrowdControlTrigger(ccType, toggleSetting, combatType)
    if not toggleSetting then return end -- Bail if this CC type is disabled in settings

    local ccKey = CROWD_CONTROL_TYPE_TO_KEY[ccType]
    if not ccKey then
        -- d("Warning: Unknown CC Type constant:", ccType) -- Optional debug
        return -- Safety check for unknown mapping
    end

    if isWarned[ccKey] then
        -- Already warned recently, play fail sound (as per original logic)
        PlaySound("Ability_Failed")
    else
        -- Trigger the event and set the warning flag with a timeout
        self:TriggerEvent(CombatTextConstants.eventType.CROWDCONTROL, ccType, combatType)
        isWarned[ccKey] = true
        LUIE_CallLater(function ()
            -- Ensure the key still exists before trying to reset it (paranoid check)
            if isWarned[ccKey] ~= nil then
                isWarned[ccKey] = false
            end
        end, 1000) -- 1 second buffer (same as original)
    end
end

---------------------------------------------------------------------------------------------------------------------------------------
-- //COMBAT STATE EVENTS & TRIGGERS//--
---------------------------------------------------------------------------------------------------------------------------------------
function CombatTextCombatEventListener:CombatState(inCombat) -- Argument 'inCombat' wasn't actually used in original, uses IsUnitInCombat directly
    local Settings = LUIE.CombatText.SV
    if not Settings or not Settings.toggles then
        -- d("CombatText Settings not loaded for CombatState") -- Optional debug
        return -- Bail out if settings aren't ready
    end

    local currentlyInCombat = IsUnitInCombat("player") -- Check current state directly

    if currentlyInCombat and not isWarned.combat then
        -- Entering combat
        isWarned.combat = true
        if Settings.toggles.showInCombat then
            self:TriggerEvent(CombatTextConstants.eventType.POINT, CombatTextConstants.pointType.IN_COMBAT, nil)
        end
    elseif not currentlyInCombat and isWarned.combat then
        -- Leaving combat
        isWarned.combat = false
        if Settings.toggles.showOutCombat then
            self:TriggerEvent(CombatTextConstants.eventType.POINT, CombatTextConstants.pointType.OUT_COMBAT, nil)
        end
    end
    -- If state hasn't changed (e.g., already in combat and event fires again), do nothing
end
