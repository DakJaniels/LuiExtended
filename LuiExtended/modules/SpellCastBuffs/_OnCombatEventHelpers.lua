-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type Effects
local Effects = Data.Effects
local zo_strformat = zo_strformat

--- Maps EVENT_COMBAT_EVENT result -> LUIE_CC_TYPE (client DebugResults labels).
local ACTION_RESULT_TO_LUIE_CC =
{
    [ACTION_RESULT_STUNNED] = LUIE_CC_TYPE_STUN,
    [ACTION_RESULT_KNOCKBACK] = LUIE_CC_TYPE_KNOCKBACK,
    [ACTION_RESULT_LEVITATED] = LUIE_CC_TYPE_PULL,
    [ACTION_RESULT_DISORIENTED] = LUIE_CC_TYPE_DISORIENT,
    [ACTION_RESULT_FEARED] = LUIE_CC_TYPE_FEAR,
    [ACTION_RESULT_CHARMED] = LUIE_CC_TYPE_CHARM,
    [ACTION_RESULT_SILENCED] = LUIE_CC_TYPE_SILENCE,
    [ACTION_RESULT_STAGGERED] = LUIE_CC_TYPE_STAGGER,
    [ACTION_RESULT_SNARED] = LUIE_CC_TYPE_SNARE,
    [ACTION_RESULT_ROOTED] = LUIE_CC_TYPE_ROOT,
}

local groundDamageAuraCombatResults =
{
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
    [ACTION_RESULT_DODGED] = true,
    [ACTION_RESULT_BLOCKED] = true,
    [ACTION_RESULT_BLOCKED_DAMAGE] = true,
    [ACTION_RESULT_HEAL] = true,
    [ACTION_RESULT_CRITICAL_HEAL] = true,
    [ACTION_RESULT_HOT_TICK] = true,
    [ACTION_RESULT_HOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
}

local auraLifecycleCombatResults =
{
    [ACTION_RESULT_BEGIN] = true,
    [ACTION_RESULT_EFFECT_GAINED] = true,
    [ACTION_RESULT_EFFECT_GAINED_DURATION] = true,
    [ACTION_RESULT_EFFECT_FADED] = true,
}

--- Routed buff container keys that only display debuffs (default debuff border on pool acquire).
local debuffAuraContainerKeys =
{
    player2 = true,
    playerd = true,
    target2 = true,
    targetd = true,
    prominentdebuffs = true,
}

--- @param containerKey string
--- @return boolean
function SpellCastBuffs.IsDebuffAuraContainer(containerKey)
    return debuffAuraContainerKeys[containerKey] == true
end

--- @param result ActionResult
--- @return boolean
function SpellCastBuffs.IsGroundDamageAuraCombatResult(result)
    return groundDamageAuraCombatResults[result] == true
end

--- @param result ActionResult
--- @return boolean
function SpellCastBuffs.IsAuraLifecycleCombatResult(result)
    return auraLifecycleCombatResults[result] == true
end

local damageTypeCombatResults =
{
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_PRECISE_DAMAGE] = true,
    [ACTION_RESULT_WRECKING_DAMAGE] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
}

--- @param result ActionResult
--- @return boolean
function SpellCastBuffs.IsDamageTypeCombatResult(result)
    return damageTypeCombatResults[result] == true
end

--- Cache combat damageType for an abilityId (short TTL).
--- @param abilityId integer
--- @param result ActionResult
--- @param damageType DamageType|integer|nil
function SpellCastBuffs.RecordCombatDamageType(abilityId, result, damageType)
    if not SpellCastBuffs.SV.DamageTypeFallback or not SpellCastBuffs.SV.ColorCC then
        return
    end
    if not abilityId or abilityId == 0 then
        return
    end
    if not damageType or damageType == DAMAGE_TYPE_NONE or damageType == DAMAGE_TYPE_GENERIC then
        return
    end
    if not SpellCastBuffs.IsDamageTypeCombatResult(result) then
        return
    end
    local now = GetFrameTimeMilliseconds()
    local expires = now + 5000
    SpellCastBuffs.combatDamageTypeByAbilityId[abilityId] = { damageType = damageType, expires = expires }

    -- Some effects show on frames under a remapped id (e.g. BarHighlightOverride.newId).
    -- Mirror damageType onto the remapped id so the displayed aura can pick it up.
    local override = Effects.BarHighlightOverride and Effects.BarHighlightOverride[abilityId] or nil
    local remapId = override and override.newId or nil
    if remapId and remapId ~= abilityId then
        SpellCastBuffs.combatDamageTypeByAbilityId[remapId] = { damageType = damageType, expires = expires }
    end
end

--- @param config table
--- @param result ActionResult
--- @return boolean
function SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result)
    if config.ignoreBegin and result == ACTION_RESULT_BEGIN then
        return true
    end
    if config.refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
        return true
    end
    if config.ignoreFade and result == ACTION_RESULT_EFFECT_FADED then
        return true
    end
    return false
end

--- @param overrideData table|nil
--- @param iconName string
--- @param effectName string
--- @return string iconName
--- @return string effectName
--- @return boolean hide
local function applyLocationOverrideData(overrideData, iconName, effectName)
    if not overrideData then
        return iconName, effectName, false
    end
    if overrideData.icon then
        iconName = overrideData.icon
    end
    if overrideData.name then
        effectName = overrideData.name
    end
    if overrideData.hide then
        return iconName, effectName, true
    end
    return iconName, effectName, false
end

--- @param abilityId integer
--- @param iconName string
--- @param effectName string
--- @return string iconName
--- @return string effectName
--- @return boolean hide
function SpellCastBuffs.ApplyZoneAndMapEffectOverrides(abilityId, iconName, effectName)
    if Effects.ZoneDataOverride[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        local hide
        iconName, effectName, hide = applyLocationOverrideData(Effects.ZoneDataOverride[abilityId][index], iconName, effectName)
        if hide then
            return iconName, effectName, true
        end
        iconName, effectName, hide = applyLocationOverrideData(Effects.ZoneDataOverride[abilityId][zoneName], iconName, effectName)
        if hide then
            return iconName, effectName, true
        end
    end

    if Effects.MapDataOverride[abilityId] then
        local mapName = GetMapName()
        local hide
        iconName, effectName, hide = applyLocationOverrideData(Effects.MapDataOverride[abilityId][mapName], iconName, effectName)
        if hide then
            return iconName, effectName, true
        end
    end

    return iconName, effectName, false
end

--- @param abilityId integer
--- @param sourceName string
--- @param iconName string
--- @param effectName string
--- @return string iconName
--- @return string effectName
--- @return boolean hide
function SpellCastBuffs.ApplyGroundDamageEffectOverrideByName(abilityId, sourceName, iconName, effectName)
    if not Effects.EffectOverrideByName[abilityId] then
        return iconName, effectName, false
    end

    local unitName = zo_strformat("<<C:1>>", sourceName)
    local byName = Effects.EffectOverrideByName[abilityId][unitName]
    if not byName then
        return iconName, effectName, false
    end

    if byName.hide then
        if byName.zone then
            local index = GetZoneId(GetCurrentMapZoneIndex())
            for zoneId in pairs(byName.zone) do
                if zoneId == index then
                    return iconName, effectName, true
                end
            end
        else
            return iconName, effectName, true
        end
    end

    iconName = byName.icon or iconName
    effectName = byName.name or effectName
    return iconName, effectName, false
end

--- @param abilityId integer
--- @param unitName string
--- @param iconName string
--- @param effectName string
--- @return string iconName
--- @return string effectName
--- @return boolean hide
function SpellCastBuffs.ApplyEffectOverrideByNameForUnit(abilityId, unitName, iconName, effectName)
    if not Effects.EffectOverrideByName[abilityId] then
        return iconName, effectName, false
    end

    unitName = zo_strformat("<<C:1>>", unitName)
    local byName = Effects.EffectOverrideByName[abilityId][unitName]
    if not byName then
        return iconName, effectName, false
    end
    if byName.hide then
        return iconName, effectName, true
    end
    iconName = byName.icon or iconName
    effectName = byName.name or effectName
    return iconName, effectName, false
end

--- @param context string
--- @param slotKey integer|string
--- @param abilityId integer
--- @param stack integer
--- @return integer
function SpellCastBuffs.IncrementCombatEffectStack(context, slotKey, abilityId, stack)
    local existing = SpellCastBuffs.EffectsList[context][slotKey] or SpellCastBuffs.GetFakeEffectEntry(context, abilityId)
    local override = Effects.EffectOverride[abilityId]
    if not (existing and override and override.stackAdd) then
        return stack
    end
    if override.stackMax then
        if existing.stack == override.stackMax then
            return existing.stack
        end
        return existing.stack + override.stackAdd
    end
    return existing.stack + override.stackAdd
end

--- @class SCBFakeCombatEffectOpts
--- @field forced? string
--- @field groundLabel? boolean
--- @field combatCcType? integer LUIE_CC_TYPE_* derived from EVENT_COMBAT_EVENT result (for fake combat auras)
--- @field stack? integer
--- @field toggle? boolean
--- @field fakeDuration? boolean
--- @field savedName? string

--- @param context string
--- @param effectType integer
--- @param id integer
--- @param name string
--- @param icon string
--- @param duration integer
--- @param unbreakable integer
--- @param opts? SCBFakeCombatEffectOpts
--- @return table
function SpellCastBuffs.BuildFakeCombatEffectEntry(context, effectType, id, name, icon, duration, unbreakable, opts)
    opts = opts or {}
    local beginTime = GetFrameTimeMilliseconds()
    local endTime = beginTime + duration
    local entry =
    {
        target = SpellCastBuffs.DetermineTarget(context),
        type = effectType,
        id = id,
        name = name,
        icon = icon,
        dur = duration,
        starts = beginTime,
        ends = (duration > 0) and endTime or nil,
        forced = opts.forced or "short",
        restart = true,
        iconNum = 0,
        unbreakable = unbreakable,
        combatCcType = opts.combatCcType,
    }
    if opts.groundLabel ~= nil then
        entry.groundLabel = opts.groundLabel
    end
    if opts.stack ~= nil then
        entry.stack = opts.stack
    end
    if opts.toggle ~= nil then
        entry.toggle = opts.toggle
    end
    if opts.fakeDuration ~= nil then
        entry.fakeDuration = opts.fakeDuration
    end
    if opts.savedName ~= nil then
        entry.savedName = opts.savedName
    end
    return entry
end

--- @param result ActionResult
--- @param abilityId integer
--- @param abilityName string
--- @param sourceName string
function SpellCastBuffs.HandleIncomingGroundDamageAura(result, abilityId, abilityName, sourceName)
    if not (SpellCastBuffs.SV.GroundDamageAura and Effects.AddGroundDamageAura[abilityId]) then
        return
    end

    local groundConfig = Effects.AddGroundDamageAura[abilityId]
    if not SpellCastBuffs.IsGroundDamageAuraCombatResult(result) and not groundConfig.exception then
        return
    end
    if groundConfig.exception and result ~= groundConfig.exception then
        return
    end

    local stack
    local iconName = GetAbilityIcon(abilityId)
    local effectName
    local unbreakable
    local duration = groundConfig.duration
    local effectType = groundConfig.type
    local buffSlot
    local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false
    local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

    if Effects.EffectOverride[abilityId] then
        effectName = Effects.EffectOverride[abilityId].name or abilityName
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stack = Effects.EffectOverride[abilityId].stack or 0
    else
        effectName = abilityName
        unbreakable = 0
        stack = 0
    end

    local hide
    iconName, effectName, hide = SpellCastBuffs.ApplyZoneAndMapEffectOverrides(abilityId, iconName, effectName)
    if hide then
        return
    end

    iconName, effectName, hide = SpellCastBuffs.ApplyGroundDamageEffectOverrideByName(abilityId, sourceName, iconName, effectName)
    if hide then
        return
    end

    if groundConfig.merge then
        buffSlot = "GroundDamageAura" .. tostring(groundConfig.merge)
    else
        buffSlot = abilityId
    end

    local context = "player" .. effectType
    stack = SpellCastBuffs.IncrementCombatEffectStack(context, buffSlot, abilityId, stack)

    SpellCastBuffs.EffectsList[context][buffSlot] = SpellCastBuffs.BuildFakeCombatEffectEntry(
        context,
        effectType,
        abilityId,
        effectName,
        iconName,
        duration,
        unbreakable,
        {
            forced = "short",
            groundLabel = groundLabel,
            toggle = toggle,
            stack = stack,
            fakeDuration = true,
        }
    )
    SpellCastBuffs.MarkDisplayDirty()
end

--- @param result ActionResult
--- @param abilityId integer
function SpellCastBuffs.HandleIncomingCrystallizedShield(result, abilityId)
    if abilityId ~= 86135 and abilityId ~= 86139 and abilityId ~= 86143 then
        return
    end
    if result ~= ACTION_RESULT_DAMAGE_SHIELDED then
        return
    end

    local context = "player1"
    local effectName = Effects.EffectOverrideByName[abilityId]
    context = SpellCastBuffs.DetermineContext(context, abilityId, effectName)

    local existing = SpellCastBuffs.GetFakeEffectEntry(context, abilityId)
    if existing then
        existing.stack = existing.stack - 1
        if existing.stack == 0 then
            SpellCastBuffs.ClearFakeEffectEntry(context, abilityId)
        end
    end
end

--- @param result ActionResult
--- @param abilityId integer
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param unbreakable integer
--- @param groundLabel boolean
function SpellCastBuffs.HandleIncomingFakeExternalBuff(result, abilityId, sourceName, sourceType, targetName, targetType, unbreakable, groundLabel)
    local config = Effects.FakeExternalBuffs[abilityId]
    if not (config and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER)) then
        return
    end
    if SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result) then
        return
    end
    if SpellCastBuffs.SV.HidePlayerBuffs then
        return
    end

    local iconName = config.icon or GetAbilityIcon(abilityId)
    local effectName = config.name or GetAbilityName(abilityId)
    local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, effectName)
    SpellCastBuffs.ClearFakeEffectEntry(context, abilityId)
    if SpellCastBuffs.UnitHasBuffAbilityId("player", abilityId) then
        return
    end
    local duration = config.duration
    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)
    if source ~= "" and target == LUIE.PlayerNameFormatted then
        SpellCastBuffs.SetFakeCombatEffect(
            context,
            abilityId,
            SpellCastBuffs.BuildFakeCombatEffectEntry(
                context,
                1,
                abilityId,
                effectName,
                iconName,
                duration,
                unbreakable,
                {
                    groundLabel = groundLabel,
                    fakeDuration = config.overrideDuration,
                }
            )
        )
    end
end

--- @param result ActionResult
--- @param abilityId integer
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param unbreakable integer
--- @param stack integer
--- @param internalStack boolean|nil
--- @param groundLabel boolean
function SpellCastBuffs.HandleIncomingFakeExternalDebuff(result, abilityId, sourceName, sourceType, targetName, targetType, unbreakable, stack, internalStack, groundLabel)
    local config = Effects.FakeExternalDebuffs[abilityId]
    if not (config and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER)) then
        return
    end
    if SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result) then
        return
    end
    if SpellCastBuffs.SV.HidePlayerDebuffs then
        return
    end
    if SpellCastBuffs.SV.GroundDamageAura and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].hideGround then
        return
    end

    local context = "player2"
    local fakeUid = SpellCastBuffs.GetEffectUidFake(abilityId)
    stack = SpellCastBuffs.IncrementCombatEffectStack(context, fakeUid, abilityId, stack)

    if internalStack then
        if not SpellCastBuffs.InternalStackCounter[abilityId] then
            SpellCastBuffs.InternalStackCounter[abilityId] = 0
        end
        if result == ACTION_RESULT_EFFECT_FADED then
            SpellCastBuffs.InternalStackCounter[abilityId] = SpellCastBuffs.InternalStackCounter[abilityId] - 1
        elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION then
            SpellCastBuffs.InternalStackCounter[abilityId] = SpellCastBuffs.InternalStackCounter[abilityId] + 1
        end
        if SpellCastBuffs.GetFakeEffectEntry(context, abilityId) then
            if SpellCastBuffs.InternalStackCounter[abilityId] <= 0 then
                SpellCastBuffs.ClearFakeEffectEntry(context, abilityId)
                SpellCastBuffs.InternalStackCounter[abilityId] = nil
            end
        end
    else
        SpellCastBuffs.ClearFakeEffectEntry(context, abilityId)
    end

    local iconName = config.icon or GetAbilityIcon(abilityId)
    local effectName = config.name or GetAbilityName(abilityId)
    local duration = config.duration

    local hide
    iconName, effectName, hide = SpellCastBuffs.ApplyZoneAndMapEffectOverrides(abilityId, iconName, effectName)
    if hide then
        return
    end

    if SpellCastBuffs.SV.UseDefaultIcon and SpellCastBuffs.ShouldUseDefaultIcon(abilityId) == true then
        iconName = SpellCastBuffs.GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
    end

    if abilityId == 14523 then
        local source = zo_strformat("<<C:1>>", sourceName)
        if source == "Jackal" then
            iconName = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_JACKAL_HELLJOINT_DDS
        end
    end

    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)
    if source ~= "" and target == LUIE.PlayerNameFormatted then
        if SpellCastBuffs.UnitHasBuffAbilityId("player", abilityId) then
            return
        end
        SpellCastBuffs.SetFakeCombatEffect(
            context,
            abilityId,
            SpellCastBuffs.BuildFakeCombatEffectEntry(
                context,
                BUFF_EFFECT_TYPE_DEBUFF,
                abilityId,
                effectName,
                iconName,
                duration,
                unbreakable,
                {
                    groundLabel = groundLabel,
                    stack = stack,
                }
            )
        )
    end
end

--- @param result ActionResult
--- @param abilityId integer
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param unbreakable integer
--- @param stack integer
--- @param groundLabel boolean
function SpellCastBuffs.HandleIncomingFakePlayerBuff(result, abilityId, sourceName, sourceType, targetName, targetType, unbreakable, stack, groundLabel)
    local config = Effects.FakePlayerBuffs[abilityId]
    if not (config and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER)) then
        return
    end
    if SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result) then
        return
    end

    local effectName = config.name or GetAbilityName(abilityId)
    if SpellCastBuffs.SV.HidePlayerBuffs and not (SpellCastBuffs.WantsProminentDebuff(abilityId, effectName) or SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName]) then
        return
    end
    if config.onlyExtra and not SpellCastBuffs.SV.ExtraBuffs then
        return
    end
    if config.onlyExtended and not (SpellCastBuffs.SV.ExtraBuffs and SpellCastBuffs.SV.ExtraExpanded) then
        return
    end
    if Effects.IsSetICD[abilityId] and SpellCastBuffs.SV.IgnoreSetICDPlayer then
        return
    end
    if Effects.IsAbilityICD[abilityId] and SpellCastBuffs.SV.IgnoreAbilityICDPlayer then
        return
    end

    local effectType = config.debuff and BUFF_EFFECT_TYPE_DEBUFF or BUFF_EFFECT_TYPE_BUFF
    local context = "player" .. effectType

    local existingFake = SpellCastBuffs.GetFakeEffectEntry(context, abilityId)
    if existingFake and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
        stack = existingFake.stack + Effects.EffectOverride[abilityId].stackAdd
    end
    if abilityId == 26406 then
        SpellCastBuffs.ignoreAbilityId[abilityId] = true
    end

    local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false
    local iconName = config.icon or GetAbilityIcon(abilityId)
    local duration = config.duration
    if duration == "GET" then
        duration = GetAbilityDuration(abilityId) or 0
    end
    local finalId = config.shiftId or abilityId
    if config.shiftId then
        iconName = Effects.FakePlayerBuffs[finalId] and Effects.FakePlayerBuffs[finalId].icon or GetAbilityIcon(finalId)
        effectName = Effects.FakePlayerBuffs[finalId] and Effects.FakePlayerBuffs[finalId].name or GetAbilityName(finalId)
    end
    context = SpellCastBuffs.DetermineContextSimple(context, finalId, effectName)
    SpellCastBuffs.ClearFakeEffectEntry(context, finalId)
    if SpellCastBuffs.UnitHasBuffAbilityId("player", finalId) or SpellCastBuffs.UnitHasBuffAbilityId("reticleover", finalId) then
        return
    end
    local forcedType = config.long and "long" or "short"
    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)
    unbreakable = (Effects.EffectOverride[finalId] and Effects.EffectOverride[finalId].unbreakable) or unbreakable
    if source == LUIE.PlayerNameFormatted and target == LUIE.PlayerNameFormatted then
        SpellCastBuffs.SetFakeCombatEffect(
            context,
            finalId,
            SpellCastBuffs.BuildFakeCombatEffectEntry(
                context,
                effectType,
                finalId,
                effectName,
                iconName,
                duration,
                unbreakable,
                {
                    forced = forcedType,
                    groundLabel = groundLabel,
                    stack = stack,
                    toggle = toggle,
                }
            )
        )
    end
end

--- @param result ActionResult
--- @param abilityId integer
--- @param sourceName string
--- @param targetName string
--- @param unbreakable integer
--- @param groundLabel boolean
function SpellCastBuffs.HandleIncomingFakeStagger(result, abilityId, sourceName, targetName, unbreakable, groundLabel)
    local config = Effects.FakeStagger[abilityId]
    if not config then
        return
    end
    if SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result) then
        return
    end
    if SpellCastBuffs.SV.HidePlayerDebuffs then
        return
    end

    local iconName = config.icon or GetAbilityIcon(abilityId)
    local effectName = config.name or GetAbilityName(abilityId)
    local duration = config.duration
    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)
    local context = "player2"
    if source ~= "" and target == LUIE.PlayerNameFormatted and not SpellCastBuffs.UnitHasBuffAbilityId("player", abilityId) then
        local ccType = ACTION_RESULT_TO_LUIE_CC[result]
        SpellCastBuffs.SetFakeCombatEffect(
            context,
            abilityId,
            SpellCastBuffs.BuildFakeCombatEffectEntry(
                context,
                BUFF_EFFECT_TYPE_DEBUFF,
                abilityId,
                effectName,
                iconName,
                duration,
                unbreakable,
                {
                    groundLabel = groundLabel,
                    combatCcType = ccType,
                }
            )
        )
    end
end

local groundMineDamageCombatResults =
{
    [ACTION_RESULT_DAMAGE] = true,
    [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    [ACTION_RESULT_PRECISE_DAMAGE] = true,
    [ACTION_RESULT_WRECKING_DAMAGE] = true,
    [ACTION_RESULT_DOT_TICK] = true,
    [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    [ACTION_RESULT_IMMUNE] = true,
    [ACTION_RESULT_REFLECTED] = true,
    [ACTION_RESULT_ABSORBED] = true,
    [ACTION_RESULT_PARRIED] = true,
    [ACTION_RESULT_DODGED] = true,
    [ACTION_RESULT_BLOCKED] = true,
    [ACTION_RESULT_BLOCKED_DAMAGE] = true,
    [ACTION_RESULT_RESIST] = true,
    [ACTION_RESULT_PARTIAL_RESIST] = true,
    [ACTION_RESULT_MISS] = true,
    [ACTION_RESULT_DEFENDED] = true,
    [ACTION_RESULT_INTERCEPTED] = true,
    [ACTION_RESULT_FALL_DAMAGE] = true,
    [ACTION_RESULT_DAMAGE_SHIELDED] = true,
}

local groundMineTrapBeastCompareIds =
{
    [35754] = 35750,
    [40389] = 40382,
    [40376] = 40372,
}

--- @param result ActionResult
--- @return boolean
function SpellCastBuffs.IsGroundMineDamageCombatResult(result)
    return groundMineDamageCombatResults[result] == true
end

--- @param compareId integer
--- @return string
local function resolveGroundMineEffectContext(compareId)
    local context = "player1"
    if Effects.FakePlayerOfflineAura[compareId] and Effects.FakePlayerOfflineAura[compareId].ground then
        context = "ground"
    end
    if SpellCastBuffs.WantsProminentDebuff(compareId, nil) then
        context = "promd_player"
    elseif SpellCastBuffs.SV.PromBuffTable[compareId] then
        context = "promb_player"
    end
    return context
end

--- @param result ActionResult
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SpellCastBuffs.HandleOutgoingGroundMineTrapBeast(result, abilityId, sourceType)
    if not (Effects.IsGroundMineDamage[abilityId] and sourceType == COMBAT_UNIT_TYPE_PLAYER) then
        return
    end
    if not SpellCastBuffs.IsGroundMineDamageCombatResult(result) then
        return
    end

    local compareId = groundMineTrapBeastCompareIds[abilityId]
    if not compareId then
        return
    end

    local context = resolveGroundMineEffectContext(compareId)
    SpellCastBuffs.EffectsList[context][compareId] = nil
    SpellCastBuffs.MarkDisplayDirty()
end

--- @param config table
--- @param abilityId integer
--- @param effectName string
--- @return string
local function resolveFakePlayerOfflineAuraContext(config, abilityId, effectName)
    local context
    if config.ground then
        context = "ground"
    else
        context = "player1"
    end
    if SpellCastBuffs.WantsProminentDebuff(abilityId, effectName) then
        context = "promd_player"
    elseif SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName] then
        context = "promb_player"
    end
    return context
end

--- @param result ActionResult
--- @param abilityId integer
--- @param sourceType CombatUnitType
--- @param sourceName string
--- @param unbreakable integer
--- @param stack integer
--- @param groundLabel boolean
function SpellCastBuffs.HandleOutgoingFakePlayerOfflineAura(result, abilityId, sourceType, sourceName, unbreakable, stack, groundLabel)
    local config = Effects.FakePlayerOfflineAura[abilityId]
    if not (config and sourceType == COMBAT_UNIT_TYPE_PLAYER) then
        return
    end
    if SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result) then
        return
    end

    local effectName = config.name or GetAbilityName(abilityId)
    if SpellCastBuffs.SV.HidePlayerBuffs and not (SpellCastBuffs.WantsProminentDebuff(abilityId, effectName) or SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName] or config.ground) then
        return
    end

    local context = resolveFakePlayerOfflineAuraContext(config, abilityId, effectName)
    local existingOffline = SpellCastBuffs.GetFakeEffectEntry(context, abilityId)
    if existingOffline and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
        stack = existingOffline.stack + Effects.EffectOverride[abilityId].stackAdd
    end

    SpellCastBuffs.ClearFakeEffectEntry(context, abilityId)

    local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false
    local iconName = config.icon or GetAbilityIcon(abilityId)
    local duration = config.duration
    if duration == "GET" then
        duration = GetAbilityDuration(abilityId) or 0
    end
    local finalId = config.shiftId or abilityId
    if config.shiftId then
        iconName = Effects.FakePlayerOfflineAura and Effects.FakePlayerOfflineAura[finalId].icon or GetAbilityIcon(finalId)
        effectName = Effects.FakePlayerOfflineAura and Effects.FakePlayerOfflineAura[finalId].name or GetAbilityName(finalId)
    end
    local forcedType = config.long and "long" or "short"
    local source = zo_strformat("<<C:1>>", sourceName)
    unbreakable = Effects.EffectOverride[finalId].unbreakable or unbreakable
    if source ~= LUIE.PlayerNameFormatted then
        return
    end

    if SpellCastBuffs.UnitHasBuffAbilityId("player", finalId) then
        return
    end
    local effectType = config.ground == true and BUFF_EFFECT_TYPE_DEBUFF or 1
    local forced = config.ground == true and "short" or forcedType
    SpellCastBuffs.SetFakeCombatEffect(
        context,
        finalId,
        SpellCastBuffs.BuildFakeCombatEffectEntry(
            context,
            effectType,
            finalId,
            effectName,
            iconName,
            duration,
            unbreakable,
            {
                forced = forced,
                groundLabel = groundLabel,
                stack = stack,
                toggle = toggle,
            }
        )
    )
end

--- @param abilityId integer
--- @param targetName string
--- @param sourceName string
--- @param iconName string
--- @param effectName string
--- @param duration integer
--- @param unbreakable integer
--- @param groundLabel boolean
--- @param opts? SCBFakeCombatEffectOpts
local function placeOutgoingReticleTargetFakeEffect(abilityId, targetName, sourceName, iconName, effectName, duration, unbreakable, groundLabel, opts)
    local context = "reticleover2"
    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)
    if source ~= LUIE.PlayerNameFormatted or target == nil then
        return
    end
    if SpellCastBuffs.SV.HideTargetDebuffs then
        return
    end

    local unitName = zo_strformat("<<C:1>>", GetUnitName("reticleover"))
    local listKey = unitName == target and "ground" or "saved"
    opts = opts or {}
    opts.groundLabel = groundLabel
    opts.savedName = zo_strformat("<<C:1>>", targetName)

    SpellCastBuffs.EffectsList[listKey][abilityId] = SpellCastBuffs.BuildFakeCombatEffectEntry(
        context,
        BUFF_EFFECT_TYPE_DEBUFF,
        abilityId,
        effectName,
        iconName,
        duration,
        unbreakable,
        opts
    )
    SpellCastBuffs.MarkDisplayDirty()
end

--- @param result ActionResult
--- @param abilityId integer
--- @param sourceType CombatUnitType
--- @param targetType CombatUnitType
--- @param sourceName string
--- @param targetName string
--- @param unbreakable integer
--- @param groundLabel boolean
function SpellCastBuffs.HandleOutgoingFakePlayerDebuff(result, abilityId, sourceType, targetType, sourceName, targetName, unbreakable, groundLabel)
    local config = Effects.FakePlayerDebuffs[abilityId]
    if not (config and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER)) then
        return
    end
    if SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result) then
        return
    end
    if SpellCastBuffs.SV.HideTargetDebuffs then
        return
    end
    if not DoesUnitExist("reticleover") then
        return
    end
    if IsUnitDead(GetDisplayName()) then
        return
    end

    local iconName = config.icon or GetAbilityIcon(abilityId)
    if SpellCastBuffs.SV.UseDefaultIcon and SpellCastBuffs.ShouldUseDefaultIcon(abilityId) == true then
        iconName = SpellCastBuffs.GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
    end

    placeOutgoingReticleTargetFakeEffect(
        abilityId,
        targetName,
        sourceName,
        iconName,
        config.name or GetAbilityName(abilityId),
        config.duration,
        unbreakable,
        groundLabel,
        { fakeDuration = config.overrideDuration }
    )
end

--- @param result ActionResult
--- @param abilityId integer
--- @param sourceName string
--- @param targetName string
--- @param unbreakable integer
--- @param groundLabel boolean
function SpellCastBuffs.HandleOutgoingFakeStagger(result, abilityId, sourceName, targetName, unbreakable, groundLabel)
    local config = Effects.FakeStagger[abilityId]
    if not config then
        return
    end
    if SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result) then
        return
    end
    if SpellCastBuffs.SV.HideTargetDebuffs then
        return
    end

    placeOutgoingReticleTargetFakeEffect(
        abilityId,
        targetName,
        sourceName,
        config.icon or GetAbilityIcon(abilityId),
        config.name or GetAbilityName(abilityId),
        config.duration,
        unbreakable,
        groundLabel,
        nil
    )
end
