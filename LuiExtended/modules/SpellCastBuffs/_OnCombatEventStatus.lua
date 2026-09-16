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

local STATUS_EFFECT_PLAYER_CONTEXTS =
{
    "player2",
    "promd_player",
}

local STATUS_EFFECT_RETICLE_CONTEXTS =
{
    "ground",
    "promd_ground",
    "saved",
}

--- @param abilityId integer|nil
--- @return boolean
function SpellCastBuffs.IsCombatEventStatusEffect(abilityId)
    local statusEffects = Effects.CombatEventStatusEffects
    return abilityId ~= nil and statusEffects ~= nil and statusEffects[abilityId] ~= nil
end

--- @param unitId integer|nil
function SpellCastBuffs.CacheReticleCombatUnitId(unitId)
    if not unitId or unitId == 0 then
        return
    end
    if SpellCastBuffs.reticleCombatUnitId == unitId then
        return
    end
    SpellCastBuffs.reticleCombatUnitId = unitId
    SpellCastBuffs.RestoreSavedFakeEffects()
end

--- @param formattedTargetName string|nil
--- @param targetUnitId integer|nil
function SpellCastBuffs.TryCacheReticleCombatUnitIdFromName(formattedTargetName, targetUnitId)
    if not targetUnitId or targetUnitId == 0 then
        return
    end
    if not formattedTargetName or formattedTargetName == "" then
        return
    end
    if not DoesUnitExist("reticleover") then
        return
    end
    local reticleName = zo_strformat("<<C:1>>", GetUnitName("reticleover"))
    if reticleName == formattedTargetName then
        SpellCastBuffs.CacheReticleCombatUnitId(targetUnitId)
    end
end

--- @param formattedTargetName string|nil
--- @param targetUnitId integer|nil
--- @return boolean
function SpellCastBuffs.StatusEffectMatchesReticle(formattedTargetName, targetUnitId)
    if targetUnitId and targetUnitId ~= 0 and SpellCastBuffs.reticleCombatUnitId and SpellCastBuffs.reticleCombatUnitId ~= 0 then
        return targetUnitId == SpellCastBuffs.reticleCombatUnitId
    end
    if not DoesUnitExist("reticleover") then
        return false
    end
    if not formattedTargetName or formattedTargetName == "" then
        return false
    end
    local reticleName = zo_strformat("<<C:1>>", GetUnitName("reticleover"))
    return reticleName == formattedTargetName
end

--- @param entry table|nil
--- @param formattedTargetName string|nil
--- @param targetUnitId integer|nil
--- @return boolean
local function statusFakeMatchesCombatTarget(entry, formattedTargetName, targetUnitId)
    if not entry then
        return false
    end
    if entry.savedUnitId and entry.savedUnitId ~= 0 and targetUnitId and targetUnitId ~= 0 then
        return entry.savedUnitId == targetUnitId
    end
    if entry.savedName and formattedTargetName and formattedTargetName ~= "" then
        return entry.savedName == formattedTargetName
    end
    return false
end

--- @param abilityId integer
--- @param contextList string[]
local function clearStatusFakeInContexts(abilityId, contextList)
    for i = 1, #contextList do
        SpellCastBuffs.ClearFakeEffectEntry(contextList[i], abilityId)
    end
end

--- Clear player-side combat-event status fakes.
--- @param abilityId integer
function SpellCastBuffs.ClearCombatEventStatusEffectFakePlayer(abilityId)
    clearStatusFakeInContexts(abilityId, STATUS_EFFECT_PLAYER_CONTEXTS)
end

--- Clear reticle/saved combat-event status fakes. When formattedTargetName/targetUnitId
--- are provided, only matching rows are removed.
--- @param abilityId integer
--- @param formattedTargetName string|nil
--- @param targetUnitId integer|nil
function SpellCastBuffs.ClearCombatEventStatusEffectFakeReticle(abilityId, formattedTargetName, targetUnitId)
    local filterByTarget = (formattedTargetName ~= nil and formattedTargetName ~= "") or (targetUnitId ~= nil and targetUnitId ~= 0)
    for i = 1, #STATUS_EFFECT_RETICLE_CONTEXTS do
        local context = STATUS_EFFECT_RETICLE_CONTEXTS[i]
        if filterByTarget then
            local existing = SpellCastBuffs.GetFakeEffectEntry(context, abilityId)
            if existing and statusFakeMatchesCombatTarget(existing, formattedTargetName, targetUnitId) then
                SpellCastBuffs.ClearFakeEffectEntry(context, abilityId)
            end
        else
            SpellCastBuffs.ClearFakeEffectEntry(context, abilityId)
        end
    end
end

--- @param abilityId integer
--- @param unitTag string
function SpellCastBuffs.ClearCombatEventStatusEffectFakeForUnit(abilityId, unitTag)
    if unitTag == "player" then
        SpellCastBuffs.ClearCombatEventStatusEffectFakePlayer(abilityId)
        return
    end
    if unitTag == "reticleover" then
        local reticleName = zo_strformat("<<C:1>>", GetUnitName("reticleover"))
        SpellCastBuffs.ClearCombatEventStatusEffectFakeReticle(abilityId, reticleName, SpellCastBuffs.reticleCombatUnitId)
    end
end

--- @param config CombatEventStatusEffectConfig
--- @param abilityId integer
--- @param result ActionResult
--- @param hitValue integer
--- @return integer
local function resolveStatusEffectDuration(config, abilityId, result, hitValue)
    local duration = config.duration
    if duration == "GET" then
        duration = GetAbilityDuration(abilityId) or 0
    end
    if result == ACTION_RESULT_EFFECT_GAINED_DURATION and hitValue and hitValue > 0 then
        duration = hitValue
    end
    return duration
end

--- @param abilityId integer
--- @param config CombatEventStatusEffectConfig
--- @return string iconName
--- @return string effectName
--- @return integer unbreakable
local function resolveStatusEffectDisplay(abilityId, config)
    local override = Effects.EffectOverride[abilityId]
    local iconName = config.icon or (override and override.icon) or GetAbilityIcon(abilityId)
    local effectName = config.name or (override and override.name) or GetAbilityName(abilityId)
    local unbreakable = (override and override.unbreakable) or 0
    return iconName, effectName, unbreakable
end

--- @param abilityId integer
--- @param effectName string
--- @param iconName string
--- @param duration integer
--- @param unbreakable integer
local function placeIncomingStatusEffectFake(abilityId, effectName, iconName, duration, unbreakable)
    if SpellCastBuffs.hidePlayerEffects[abilityId] then
        return
    end
    if SpellCastBuffs.SV.HidePlayerDebuffs and not SpellCastBuffs.WantsProminentDebuff(abilityId, effectName) then
        return
    end
    if SpellCastBuffs.UnitHasBuffAbilityId("player", abilityId) then
        SpellCastBuffs.ClearCombatEventStatusEffectFakePlayer(abilityId)
        return
    end

    local context = SpellCastBuffs.DetermineContext("player2", abilityId, effectName)
    SpellCastBuffs.ClearCombatEventStatusEffectFakePlayer(abilityId)
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
            unbreakable
        )
    )
end

--- @param abilityId integer
--- @param effectName string
--- @param iconName string
--- @param duration integer
--- @param unbreakable integer
--- @param formattedTargetName string
--- @param targetUnitId integer
local function placeOutgoingStatusEffectFake(abilityId, effectName, iconName, duration, unbreakable, formattedTargetName, targetUnitId)
    if SpellCastBuffs.hideTargetEffects[abilityId] then
        return
    end
    if SpellCastBuffs.SV.HideTargetDebuffs and not SpellCastBuffs.WantsProminentDebuff(abilityId, effectName) then
        return
    end

    local matchesReticle = SpellCastBuffs.StatusEffectMatchesReticle(formattedTargetName, targetUnitId)
    if matchesReticle and SpellCastBuffs.UnitHasBuffAbilityId("reticleover", abilityId) then
        SpellCastBuffs.ClearCombatEventStatusEffectFakeReticle(abilityId, formattedTargetName, targetUnitId)
        return
    end

    local wantsProminent = SpellCastBuffs.WantsProminentDebuff(abilityId, effectName)
    local activeContext
    local entryContext
    if wantsProminent then
        activeContext = "promd_ground"
        entryContext = "promd_target"
    else
        activeContext = "ground"
        entryContext = "reticleover2"
    end
    local destContext = matchesReticle and activeContext or "saved"

    SpellCastBuffs.ClearCombatEventStatusEffectFakeReticle(abilityId, nil, nil)
    SpellCastBuffs.SetFakeCombatEffect(
        destContext,
        abilityId,
        SpellCastBuffs.BuildFakeCombatEffectEntry(
            entryContext,
            BUFF_EFFECT_TYPE_DEBUFF,
            abilityId,
            effectName,
            iconName,
            duration,
            unbreakable,
            {
                savedName = formattedTargetName,
                savedUnitId = (targetUnitId and targetUnitId ~= 0) and targetUnitId or nil,
            }
        )
    )
end

--- Ability-id-filtered EVENT_COMBAT_EVENT for Effects.CombatEventStatusEffects.
--- @param eventCode integer
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
function SpellCastBuffs.OnCombatEventStatus(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local config = Effects.CombatEventStatusEffects[abilityId]
    if not config then
        return
    end
    if SpellCastBuffs.SV.BlacklistTable[abilityId] or SpellCastBuffs.SV.BlacklistTable[abilityName] then
        return
    end
    if not SpellCastBuffs.IsAuraLifecycleCombatResult(result) then
        return
    end
    if SpellCastBuffs.ShouldIgnoreFakeCombatEvent(config, result) then
        return
    end

    local formattedTargetName = zo_strformat("<<C:1>>", targetName)
    local isPlayerTarget = targetType == COMBAT_UNIT_TYPE_PLAYER or formattedTargetName == LUIE.PlayerNameFormatted

    if not isPlayerTarget then
        SpellCastBuffs.TryCacheReticleCombatUnitIdFromName(formattedTargetName, targetUnitId)
    end

    if result == ACTION_RESULT_EFFECT_FADED then
        if isPlayerTarget then
            SpellCastBuffs.ClearCombatEventStatusEffectFakePlayer(abilityId)
        else
            SpellCastBuffs.ClearCombatEventStatusEffectFakeReticle(abilityId, formattedTargetName, targetUnitId)
        end
        return
    end

    local iconName, effectName, unbreakable = resolveStatusEffectDisplay(abilityId, config)
    local duration = resolveStatusEffectDuration(config, abilityId, result, hitValue)

    if isPlayerTarget then
        placeIncomingStatusEffectFake(abilityId, effectName, iconName, duration, unbreakable)
        return
    end

    if formattedTargetName == "" and (not targetUnitId or targetUnitId == 0) then
        return
    end

    placeOutgoingStatusEffectFake(abilityId, effectName, iconName, duration, unbreakable, formattedTargetName, targetUnitId)
end
