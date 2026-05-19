-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects

--- @class SCBBuffDebugMeta
--- @field abilityType AbilityType|integer
--- @field statusEffectType StatusEffectType|integer
--- @field apiBuffSlot integer
--- @field unitTag string
--- @field sourceType CombatUnitType|integer?
--- @field effectType BuffEffectType|integer?
--- @field stackCount integer?
--- @field deprecatedBuffType string?
--- @field canClickOff boolean?
--- @field castByPlayer boolean?
--- @field timeStarted number?
--- @field timeEnding number?
--- @field buffListIndex integer?
--- @field iconFilename string?

--- @class SCBBuffDebugMetaOverlay
--- @field effectType BuffEffectType|integer?
--- @field stackCount integer?
--- @field deprecatedBuffType string?
--- @field canClickOff boolean?
--- @field castByPlayer boolean?
--- @field timeStarted number?
--- @field timeEnding number?
--- @field buffListIndex integer?
--- @field iconFilename string?
--- @field sourceType CombatUnitType|integer?

local MAX_STAT_DEBUG_ROWS = 8

local advancedStatDisplayFormatNames =
{
    [0] = "NONE",
    [1] = "FLAT",
    [2] = "PERCENT",
    [3] = "FLAT_AND_PERCENT",
    [4] = "FLAT_OR_PERCENT",
}

-- luaindex values from AdvancedStatDisplayType (numeric keys — some _G names are not in all clients)
local advancedStatDisplayTypeNames =
{
    [0] = "NONE",
    [1] = "BLOCK_COST",
    [2] = "BASH_COST",
    [3] = "BASH_DAMAGE",
    [4] = "DODGE_COST",
    [5] = "SNEAK_COST",
    [6] = "SNEAK_SPEED_REDUCTION",
    [7] = "BLOCK_MITIGATION",
    [8] = "CC_BREAK_COST",
    [9] = "SPRINT_SPEED",
    [10] = "COLD_DAMAGE",
    [11] = "DISEASE_DAMAGE",
    [12] = "EARTH_DAMAGE",
    [13] = "FIRE_DAMAGE",
    [14] = "MAGIC_DAMAGE",
    [15] = "OBLIVION_DAMAGE",
    [16] = "PHYSICAL_DAMAGE",
    [17] = "POISON_DAMAGE",
    [18] = "SHOCK_DAMAGE",
    [19] = "BLEED_DAMAGE",
    [20] = "GENERIC_DAMAGE",
    [21] = "CRITICAL_PERCENT",
    [22] = "CRITICAL_HEALING",
    [23] = "CRITICAL_DAMAGE",
    [24] = "SPRINT_COST",
    [25] = "CRITICAL_CHANCE",
    [26] = "SPELL_PENETRATION",
    [27] = "BLEED_RESIST",
    [28] = "PHYSICAL_PENETRATION",
    [29] = "ARMOR",
    [30] = "SPELL_RESIST",
    [31] = "FIRE_RESIST",
    [32] = "SHOCK_RESIST",
    [33] = "DISEASE_RESIST",
    [34] = "CRITICAL_RESIST",
    [35] = "PHYSICAL_RESIST",
    [36] = "FROST_RESIST",
    [37] = "POISON_RESIST",
    [38] = "OBLIVION_RESIST",
    [39] = "EARTH_RESIST",
    [40] = "COLD_RESIST",
    [41] = "MAGIC_RESIST",
    [42] = "GENERIC_RESIST",
    [43] = "HEALING_DONE",
    [44] = "HEALING_TAKEN",
    [45] = "BLOCK_SPEED",
    [46] = "ULTIMATE_REGEN_COMBAT",
    [47] = "MONSTER_KILL_XP",
    [48] = "PLAYER_KILL_XP",
    [49] = "ALL_XP",
    [50] = "HEALING_TAKEN_BONUSES",
    [51] = "HEALING_DONE_BONUSES",
    [52] = "COIN_BONUS",
    [53] = "INSPIRATION_BONUS",
    [54] = "ALLIANCE_POINTS_BONUS",
    [55] = "TELVAR_BONUS",
    [56] = "SUBSCRIBER_ALL_XP",
    [57] = "SUBSCRIBER_COIN_BONUS",
    [58] = "SUBSCRIBER_INSPIRATION_BONUS",
    [59] = "SUBSCRIBER_ALLIANCE_POINTS_BONUS",
    [60] = "SUBSCRIBER_TELVAR_BONUS",
    [61] = "CRITICAL_PERCENT_CAP",
    [62] = "ARMOR_CAP",
}

local statusEffectTypeNames =
{
    [STATUS_EFFECT_TYPE_NONE] = "NONE",
    [STATUS_EFFECT_TYPE_ROOT] = "ROOT",
    [STATUS_EFFECT_TYPE_SNARE] = "SNARE",
    [STATUS_EFFECT_TYPE_BLEED] = "BLEED",
    [STATUS_EFFECT_TYPE_POISON] = "POISON",
    [STATUS_EFFECT_TYPE_WEAKNESS] = "WEAKNESS",
    [STATUS_EFFECT_TYPE_BLIND] = "BLIND",
    [STATUS_EFFECT_TYPE_NEARSIGHT] = "NEARSIGHT",
    [STATUS_EFFECT_TYPE_DISEASE] = "DISEASE",
    [STATUS_EFFECT_TYPE_TRAUMA] = "TRAUMA",
    [STATUS_EFFECT_TYPE_PUNCTURE] = "PUNCTURE",
    [STATUS_EFFECT_TYPE_WOUND] = "WOUND",
    [STATUS_EFFECT_TYPE_DAZED] = "DAZED",
    [STATUS_EFFECT_TYPE_SILENCE] = "SILENCE",
    [STATUS_EFFECT_TYPE_PACIFY] = "PACIFY",
    [STATUS_EFFECT_TYPE_FEAR] = "FEAR",
    [STATUS_EFFECT_TYPE_MESMERIZE] = "MESMERIZE",
    [STATUS_EFFECT_TYPE_CHARM] = "CHARM",
    [STATUS_EFFECT_TYPE_LEVITATE] = "LEVITATE",
    [STATUS_EFFECT_TYPE_STUN] = "STUN",
    [STATUS_EFFECT_TYPE_ENVIRONMENT] = "ENVIRONMENT",
    [STATUS_EFFECT_TYPE_MAGIC] = "MAGIC",
}

local abilityTypeNames =
{
    [ABILITY_TYPE_NONE] = "NONE",
    [ABILITY_TYPE_DAMAGE] = "DAMAGE",
    [ABILITY_TYPE_HEAL] = "HEAL",
    [ABILITY_TYPE_STUN] = "STUN",
    [ABILITY_TYPE_SNARE] = "SNARE",
    [ABILITY_TYPE_SILENCE] = "SILENCE",
    [ABILITY_TYPE_KNOCKBACK] = "KNOCKBACK",
    [ABILITY_TYPE_FEAR] = "FEAR",
    [ABILITY_TYPE_DISORIENT] = "DISORIENT",
    [ABILITY_TYPE_STAGGER] = "STAGGER",
    [ABILITY_TYPE_LEVITATE] = "LEVITATE",
    [ABILITY_TYPE_PACIFY] = "PACIFY",
    [ABILITY_TYPE_OFFBALANCE] = "OFFBALANCE",
}

local buffEffectTypeNames =
{
    [BUFF_EFFECT_TYPE_NOT_AN_EFFECT] = "NOT_AN_EFFECT",
    [BUFF_EFFECT_TYPE_BUFF] = "BUFF",
    [BUFF_EFFECT_TYPE_DEBUFF] = "DEBUFF",
}

local buffTypeNames =
{
    [BUFF_TYPE_NONE] = "NONE",
    [BUFF_TYPE_MINOR_BRUTALITY] = "MINOR_BRUTALITY",
    [BUFF_TYPE_MAJOR_BRUTALITY] = "MAJOR_BRUTALITY",
    [BUFF_TYPE_MINOR_SAVAGERY] = "MINOR_SAVAGERY",
    [BUFF_TYPE_MAJOR_SAVAGERY] = "MAJOR_SAVAGERY",
    [BUFF_TYPE_MINOR_SORCERY] = "MINOR_SORCERY",
    [BUFF_TYPE_MAJOR_SORCERY] = "MAJOR_SORCERY",
    [BUFF_TYPE_MINOR_PROPHECY] = "MINOR_PROPHECY",
    [BUFF_TYPE_MAJOR_PROPHECY] = "MAJOR_PROPHECY",
    [BUFF_TYPE_MINOR_RESOLVE] = "MINOR_RESOLVE",
    [BUFF_TYPE_MAJOR_RESOLVE] = "MAJOR_RESOLVE",
    [BUFF_TYPE_MINOR_BRITTLE] = "MINOR_BRITTLE",
    [BUFF_TYPE_MAJOR_BRITTLE] = "MAJOR_BRITTLE",
    [BUFF_TYPE_MINOR_FORTITUDE] = "MINOR_FORTITUDE",
    [BUFF_TYPE_MAJOR_FORTITUDE] = "MAJOR_FORTITUDE",
    [BUFF_TYPE_MINOR_ENDURANCE] = "MINOR_ENDURANCE",
    [BUFF_TYPE_MAJOR_ENDURANCE] = "MAJOR_ENDURANCE",
    [BUFF_TYPE_MINOR_INTELLECT] = "MINOR_INTELLECT",
    [BUFF_TYPE_MAJOR_INTELLECT] = "MAJOR_INTELLECT",
    [BUFF_TYPE_MINOR_HEROISM] = "MINOR_HEROISM",
    [BUFF_TYPE_MAJOR_HEROISM] = "MAJOR_HEROISM",
    [BUFF_TYPE_MINOR_MENDING] = "MINOR_MENDING",
    [BUFF_TYPE_MAJOR_MENDING] = "MAJOR_MENDING",
    [BUFF_TYPE_MINOR_VITALITY] = "MINOR_VITALITY",
    [BUFF_TYPE_MAJOR_VITALITY] = "MAJOR_VITALITY",
    [BUFF_TYPE_MINOR_EVASION] = "MINOR_EVASION",
    [BUFF_TYPE_MAJOR_EVASION] = "MAJOR_EVASION",
    [BUFF_TYPE_MINOR_PROTECTION] = "MINOR_PROTECTION",
    [BUFF_TYPE_MAJOR_PROTECTION] = "MAJOR_PROTECTION",
    [BUFF_TYPE_MINOR_MAIM] = "MINOR_MAIM",
    [BUFF_TYPE_MAJOR_MAIM] = "MAJOR_MAIM",
    [BUFF_TYPE_MINOR_DEFILE] = "MINOR_DEFILE",
    [BUFF_TYPE_MAJOR_DEFILE] = "MAJOR_DEFILE",
    [BUFF_TYPE_MINOR_MANGLE] = "MINOR_MANGLE",
    [BUFF_TYPE_MAJOR_MANGLE] = "MAJOR_MANGLE",
    [BUFF_TYPE_MINOR_EXPEDITION] = "MINOR_EXPEDITION",
    [BUFF_TYPE_MAJOR_EXPEDITION] = "MAJOR_EXPEDITION",
    [BUFF_TYPE_EMPOWER] = "EMPOWER",
    [BUFF_TYPE_MINOR_COWARDICE] = "MINOR_COWARDICE",
    [BUFF_TYPE_MAJOR_COWARDICE] = "MAJOR_COWARDICE",
    [BUFF_TYPE_MINOR_BREACH] = "MINOR_BREACH",
    [BUFF_TYPE_MAJOR_BREACH] = "MAJOR_BREACH",
    [BUFF_TYPE_MINOR_BERSERK] = "MINOR_BERSERK",
    [BUFF_TYPE_MAJOR_BERSERK] = "MAJOR_BERSERK",
    [BUFF_TYPE_MINOR_FORCE] = "MINOR_FORCE",
    [BUFF_TYPE_MAJOR_FORCE] = "MAJOR_FORCE",
    [BUFF_TYPE_MINOR_SLAYER] = "MINOR_SLAYER",
    [BUFF_TYPE_MAJOR_SLAYER] = "MAJOR_SLAYER",
    [BUFF_TYPE_MINOR_COURAGE] = "MINOR_COURAGE",
    [BUFF_TYPE_MAJOR_COURAGE] = "MAJOR_COURAGE",
    [BUFF_TYPE_MINOR_TOUGHNESS] = "MINOR_TOUGHNESS",
    [BUFF_TYPE_MINOR_AEGIS] = "MINOR_AEGIS",
    [BUFF_TYPE_MAJOR_AEGIS] = "MAJOR_AEGIS",
    [BUFF_TYPE_DEPRECATED_0] = "DEPRECATED_0",
    [BUFF_TYPE_GALLOP] = "GALLOP",
    [BUFF_TYPE_MINOR_ENERVATION] = "MINOR_ENERVATION",
    [BUFF_TYPE_MINOR_UNCERTAINTY] = "MINOR_UNCERTAINTY",
    [BUFF_TYPE_MINOR_LIFESTEAL] = "MINOR_LIFESTEAL",
    [BUFF_TYPE_MINOR_MAGICKASTEAL] = "MINOR_MAGICKASTEAL",
    [BUFF_TYPE_DEPRECATED_INCREASE_ULT_COST] = "DEPRECATED_INCREASE_ULT_COST",
    [BUFF_TYPE_MINOR_VULNERABILITY] = "MINOR_VULNERABILITY",
    [BUFF_TYPE_MAJOR_VULNERABILITY] = "MAJOR_VULNERABILITY",
    [BUFF_TYPE_MINOR_TIMIDITY] = "MINOR_TIMIDITY",
    [BUFF_TYPE_MAJOR_TIMIDITY] = "MAJOR_TIMIDITY",
}

local mundusStoneTypeNames =
{
    [MUNDUS_STONE_INVALID] = "INVALID",
    [MUNDUS_STONE_LADY] = "LADY",
    [MUNDUS_STONE_LOVER] = "LOVER",
    [MUNDUS_STONE_LORD] = "LORD",
    [MUNDUS_STONE_MAGE] = "MAGE",
    [MUNDUS_STONE_TOWER] = "TOWER",
    [MUNDUS_STONE_ATRONACH] = "ATRONACH",
    [MUNDUS_STONE_SERPENT] = "SERPENT",
    [MUNDUS_STONE_SHADOW] = "SHADOW",
    [MUNDUS_STONE_RITUAL] = "RITUAL",
    [MUNDUS_STONE_THIEF] = "THIEF",
    [MUNDUS_STONE_WARRIOR] = "WARRIOR",
    [MUNDUS_STONE_APPRENTICE] = "APPRENTICE",
    [MUNDUS_STONE_STEED] = "STEED",
}

-- DerivedStats / STAT_* — numeric effect magnitudes from GetAbilityDerivedStatAndEffectByIndex
local derivedStatNames =
{
    [STAT_ATTACK_POWER] = "ATTACK_POWER",
    [STAT_WEAPON_AND_SPELL_DAMAGE] = "WEAPON_AND_SPELL_DAMAGE",
    [STAT_ARMOR_RATING] = "ARMOR_RATING",
    [STAT_MAGICKA_MAX] = "MAGICKA_MAX",
    [STAT_MAGICKA_REGEN_COMBAT] = "MAGICKA_REGEN_COMBAT",
    [STAT_MAGICKA_REGEN_IDLE] = "MAGICKA_REGEN_IDLE",
    [STAT_HEALTH_MAX] = "HEALTH_MAX",
    [STAT_HEALTH_REGEN_COMBAT] = "HEALTH_REGEN_COMBAT",
    [STAT_HEALTH_REGEN_IDLE] = "HEALTH_REGEN_IDLE",
    [STAT_HEALING_TAKEN] = "HEALING_TAKEN",
    [STAT_HEALING_DONE] = "HEALING_DONE",
    [STAT_SPELL_RESIST] = "SPELL_RESIST",
    [STAT_CRITICAL_STRIKE] = "CRITICAL_STRIKE",
    [STAT_PHYSICAL_RESIST] = "PHYSICAL_RESIST",
    [STAT_SPELL_CRITICAL] = "SPELL_CRITICAL",
    [STAT_CRITICAL_RESISTANCE] = "CRITICAL_RESISTANCE",
    [STAT_SPELL_POWER] = "SPELL_POWER",
    [STAT_CRITICAL_CHANCE] = "CRITICAL_CHANCE",
    [STAT_STAMINA_MAX] = "STAMINA_MAX",
    [STAT_STAMINA_REGEN_COMBAT] = "STAMINA_REGEN_COMBAT",
    [STAT_STAMINA_REGEN_IDLE] = "STAMINA_REGEN_IDLE",
    [STAT_POWER] = "POWER",
}

local luiCcTypeNames =
{
    [LUIE_CC_TYPE_STUN] = "STUN",
    [LUIE_CC_TYPE_KNOCKDOWN] = "KNOCKDOWN",
    [LUIE_CC_TYPE_KNOCKBACK] = "KNOCKBACK",
    [LUIE_CC_TYPE_PULL] = "PULL",
    [LUIE_CC_TYPE_DISORIENT] = "DISORIENT",
    [LUIE_CC_TYPE_FEAR] = "FEAR",
    [LUIE_CC_TYPE_STAGGER] = "STAGGER",
    [LUIE_CC_TYPE_SILENCE] = "SILENCE",
    [LUIE_CC_TYPE_SNARE] = "SNARE",
    [LUIE_CC_TYPE_ROOT] = "ROOT",
    [LUIE_CC_TYPE_UNBREAKABLE] = "UNBREAKABLE",
    [LUIE_CC_TYPE_TRAP] = "TRAP",
    [LUIE_CC_TYPE_ENVIRONMENTAL] = "ENVIRONMENTAL",
    [LUIE_CC_TYPE_CHARM] = "CHARM",
}

local combatUnitTypeNames =
{
    [COMBAT_UNIT_TYPE_NONE] = "NONE",
    [COMBAT_UNIT_TYPE_PLAYER] = "PLAYER",
    [COMBAT_UNIT_TYPE_PLAYER_PET] = "PLAYER_PET",
    [COMBAT_UNIT_TYPE_GROUP] = "GROUP",
    [COMBAT_UNIT_TYPE_TARGET_DUMMY] = "TARGET_DUMMY",
    [COMBAT_UNIT_TYPE_OTHER] = "OTHER",
    [COMBAT_UNIT_TYPE_PLAYER_COMPANION] = "PLAYER_COMPANION",
}

local function formatEnumLabel(nameTable, value)
    if value == nil then
        return "—"
    end
    local label = nameTable[value]
    if label then
        return string.format("%s (%s)", label, tostring(value))
    end
    return tostring(value)
end

local function formatStatWithId(nameTable, statId)
    if statId == nil then
        return "—"
    end
    local label = nameTable[statId]
    if label then
        return string.format("%s (%s)", label, tostring(statId))
    end
    return tostring(statId)
end

local function formatBool(value)
    if value == nil then
        return "—"
    end
    return value and "yes" or "no"
end

local function formatSeconds(value)
    if value == nil then
        return "—"
    end
    return string.format("%.2fs", value)
end

local function isMundusStoneBuffIndex(unitTag, buffListIndex)
    if not buffListIndex then
        return false
    end
    local activeIndices = { GetUnitActiveMundusStoneBuffIndices(unitTag) }
    for _, mundusIndex in ipairs(activeIndices) do
        if mundusIndex == buffListIndex then
            return true
        end
    end
    return false
end

--- @param abilityId integer
--- @param addLine fun(label: string, value: string)
local function addDerivedStatDebugLines(abilityId, addLine)
    local numDerived = GetAbilityNumDerivedStats(abilityId)
    if not numDerived or numDerived < 1 then
        return
    end

    addLine("Derived #", tostring(numDerived))

    local limit = zo_min(numDerived, MAX_STAT_DEBUG_ROWS)
    for index = 1, limit do
        local derivedStat, effect = GetAbilityDerivedStatAndEffectByIndex(abilityId, index)
        if derivedStat ~= nil then
            addLine(
                string.format("derived[%d]", index),
                string.format("%s → %s", formatStatWithId(derivedStatNames, derivedStat), tostring(effect or 0))
            )
        end
    end

    if numDerived > limit then
        addLine("derived", string.format("… +%d more row(s)", numDerived - limit))
    end
end

--- @param abilityId integer
--- @param addLine fun(label: string, value: string)
local function addAdvancedStatDebugLines(abilityId, addLine)
    local numAdvanced = GetAbilityNumAdvancedStats(abilityId)
    if not numAdvanced or numAdvanced < 1 then
        return
    end

    addLine("Advanced #", tostring(numAdvanced))

    local limit = zo_min(numAdvanced, MAX_STAT_DEBUG_ROWS)
    for index = 1, limit do
        local statType, displayFormat, effectValue = GetAbilityAdvancedStatAndEffectByIndex(abilityId, index)
        if statType ~= nil then
            addLine(
                string.format("adv[%d]", index),
                string.format(
                    "%s | %s → %s",
                    formatStatWithId(advancedStatDisplayTypeNames, statType),
                    formatEnumLabel(advancedStatDisplayFormatNames, displayFormat),
                    tostring(effectValue or 0)
                )
            )
        end
    end

    if numAdvanced > limit then
        addLine("advanced", string.format("… +%d more row(s)", numAdvanced - limit))
    end
end

--- @param meta SCBBuffDebugMeta|nil
--- @param override table|nil
--- @return boolean
local function shouldShowCcTooltipDebug(meta, override)
    if override and (override.cc or override.ccMergedType) then
        return true
    end
    if not meta then
        return false
    end
    if meta.statusEffectType and meta.statusEffectType ~= STATUS_EFFECT_TYPE_NONE then
        return true
    end
    local abilityType = meta.abilityType
    if abilityType and abilityType ~= ABILITY_TYPE_NONE and abilityType ~= ABILITY_TYPE_DAMAGE and abilityType ~= ABILITY_TYPE_HEAL then
        if abilityTypeNames[abilityType] then
            return true
        end
    end
    return false
end

--- @param override table|nil
--- @param meta SCBBuffDebugMeta|nil
--- @param abilityId integer|string|nil
--- @param addLine fun(label: string, value: string)
local function addCcTooltipDebugLines(override, meta, abilityId, addLine)
    if not shouldShowCcTooltipDebug(meta, override) then
        return
    end

    if override then
        if override.cc then
            addLine("LUIE cc", SpellCastBuffs.GetLuiCcTypeLabel(override.cc))
        end
        if override.ccMergedType then
            addLine("LUIE cc (merged)", SpellCastBuffs.GetLuiCcTypeLabel(override.ccMergedType))
        end
        if not override.cc and not override.ccMergedType then
            addLine("LUIE cc", GetString(LUIE_STRING_BUFF_TOOLTIP_DEBUG_META_NO_CC))
        end
    elseif type(abilityId) == "number" then
        addLine("LUIE cc", GetString(LUIE_STRING_BUFF_TOOLTIP_DEBUG_META_NO_OVERRIDE))
    end

    if SpellCastBuffs.SV.ColorCC and override and override.cc then
        addLine("CC Color", GetString(LUIE_STRING_BUFF_TOOLTIP_DEBUG_META_CC_COLOR_ON))
    end
end

--- @param ccType integer|nil
--- @return string
function SpellCastBuffs.GetLuiCcTypeLabel(ccType)
    if not ccType then
        return "—"
    end
    local label = luiCcTypeNames[ccType]
    if label then
        return string.format("%s (%s)", label, tostring(ccType))
    end
    return tostring(ccType)
end

--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param apiBuffSlot integer
--- @param sourceType CombatUnitType
--- @param unitTag string
--- @param extra SCBBuffDebugMetaOverlay|nil
--- @return SCBBuffDebugMeta
function SpellCastBuffs.BuildEffectDebugMeta(abilityType, statusEffectType, apiBuffSlot, sourceType, unitTag, extra)
    local meta =
    {
        abilityType = abilityType,
        statusEffectType = statusEffectType,
        apiBuffSlot = apiBuffSlot,
        sourceType = sourceType,
        unitTag = unitTag,
    }
    if extra then
        for key, value in pairs(extra) do
            meta[key] = value
        end
    end
    return meta
end

--- @param unitTag string
--- @param timeStarted number
--- @param timeEnding number
--- @param buffSlot integer
--- @param stackCount integer
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param sourceType CombatUnitType|nil
--- @return SCBBuffDebugMeta
local function buildMetaFromUnitBuffRow(unitTag, timeStarted, timeEnding, buffSlot, stackCount, deprecatedBuffType, effectType, abilityType, statusEffectType, sourceType)
    return SpellCastBuffs.BuildEffectDebugMeta(abilityType, statusEffectType, buffSlot, sourceType, unitTag,
                                               {
                                                   effectType = effectType,
                                                   stackCount = stackCount,
                                                   deprecatedBuffType = deprecatedBuffType,
                                                   timeStarted = timeStarted,
                                                   timeEnding = timeEnding,
                                               })
end

--- @param unitTag string
--- @param abilityId integer
--- @param preferredBuffSlot integer|nil
--- @return SCBBuffDebugMeta|nil
local function lookupDebugMetaFromUnitBuffs(unitTag, abilityId, preferredBuffSlot)
    local fallback
    for i = 1, GetNumBuffs(unitTag) do
        local _, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType, effectType, abilityType, statusEffectType, buffAbilityId, rowCanClickOff, rowCastByPlayer = GetUnitBuffInfo(unitTag, i)
        if buffAbilityId == abilityId then
            local row = buildMetaFromUnitBuffRow(unitTag, timeStarted, timeEnding, buffSlot, stackCount, deprecatedBuffType, effectType, abilityType, statusEffectType, nil)
            row.canClickOff = rowCanClickOff
            row.castByPlayer = rowCastByPlayer
            row.buffListIndex = i
            row.iconFilename = iconFilename
            if preferredBuffSlot and buffSlot == preferredBuffSlot then
                return row
            end
            fallback = fallback or row
        end
    end
    return fallback
end

--- @param control table
--- @param unitTag string
--- @return SCBBuffDebugMeta|nil
function SpellCastBuffs.ResolveEffectDebugMetaForTooltip(control, unitTag)
    local abilityId = control.effectId
    local preferredBuffSlot = control.buffSlot or (control.debugMeta and control.debugMeta.apiBuffSlot)
    local live

    if type(abilityId) == "number" and unitTag and unitTag ~= "" then
        live = lookupDebugMetaFromUnitBuffs(unitTag, abilityId, preferredBuffSlot)
    end

    if live then
        if control.debugMeta then
            if control.debugMeta.sourceType ~= nil then
                live.sourceType = control.debugMeta.sourceType
            end
            if live.stackCount == nil and control.debugMeta.stackCount ~= nil then
                live.stackCount = control.debugMeta.stackCount
            end
            if live.effectType == nil and control.debugMeta.effectType ~= nil then
                live.effectType = control.debugMeta.effectType
            end
        end
        return live
    end

    return control.debugMeta
end

--- @param meta SCBBuffDebugMeta|nil
--- @param control table
--- @param unitTag string
--- @param addLine fun(label: string, value: string)
local function addUnitBuffTimingLines(meta, control, unitTag, addLine)
    if meta and meta.timeStarted and meta.timeEnding and meta.timeEnding > 0 then
        local apiDuration = meta.timeEnding - meta.timeStarted
        addLine("API Duration", formatSeconds(apiDuration))
        local remain = meta.timeEnding - GetGameTimeSeconds()
        if remain >= 0 then
            addLine("API Remaining", formatSeconds(remain))
        end
    elseif meta and meta.timeEnding == 0 then
        addLine("API Duration", "infinite")
    end

    if control.duration and control.duration > 0 then
        addLine("LUIE Duration", string.format("%s ms", tostring(control.duration)))
    end

    if meta and meta.buffListIndex and isMundusStoneBuffIndex(unitTag, meta.buffListIndex) then
        addLine("Mundus Slot", "yes")
    end
end

--- @param abilityId integer
--- @param unitTag string
--- @param addLine fun(label: string, value: string)
local function addBuffAbilityApiDebugLines(abilityId, unitTag, addLine)
    if not DoesAbilityExist(abilityId) then
        addLine("Ability", "missing")
        return
    end

    addLine("GetAbilityBuffType", formatEnumLabel(buffTypeNames, GetAbilityBuffType(abilityId, unitTag)))

    addLine("IsAbilityPermanent", formatBool(IsAbilityPermanent(abilityId)))
    addLine("IsAbilityPassive", formatBool(IsAbilityPassive(abilityId)))
    addLine("IsAbilityDurationToggled", formatBool(IsAbilityDurationToggled(abilityId, unitTag)))
    addLine("ShouldAbilityShowStacks", formatBool(ShouldAbilityShowStacks(abilityId)))
    addLine("ShowAsUsable+Duration", formatBool(ShouldAbilityShowAsUsableWithDuration(abilityId)))

    local mundusType = GetAbilityMundusStoneType(abilityId)
    if mundusType and mundusType ~= MUNDUS_STONE_INVALID then
        addLine("Mundus Stone", formatEnumLabel(mundusStoneTypeNames, mundusType))
    end

    addDerivedStatDebugLines(abilityId, addLine)
    addAdvancedStatDebugLines(abilityId, addLine)

    local durationMs = GetAbilityDuration(abilityId, nil, unitTag)
    if durationMs and durationMs > 0 then
        addLine("GetAbilityDuration", string.format("%s ms", tostring(durationMs)))
    end

    local cooldownMs = GetAbilityCooldown(abilityId, unitTag)
    if cooldownMs and cooldownMs > 0 then
        addLine("GetAbilityCooldown", string.format("%s ms", tostring(cooldownMs)))
    end

    local channeled, castDurationMs = GetAbilityCastInfo(abilityId, nil, unitTag)
    if channeled or (castDurationMs and castDurationMs > 0) then
        addLine("GetAbilityCastInfo", string.format("channeled=%s, %s ms", formatBool(channeled), castDurationMs ~= nil and tostring(castDurationMs) or "—"))
    end

    local edBuffType, isAvatarVision = GetAbilityEndlessDungeonBuffType(abilityId)
    if edBuffType and edBuffType ~= ENDLESS_DUNGEON_BUFF_TYPE_NONE then
        addLine("Endless Dungeon", string.format("type=%s avatar=%s", tostring(edBuffType), formatBool(isAvatarVision)))
    end
end

--- @param control table
--- @param detailsLine integer
--- @param unitTag string
--- @return integer detailsLine
function SpellCastBuffs.AddTooltipDebugMetaLines(control, detailsLine, unitTag)
    if not SpellCastBuffs.SV.TooltipDebugMeta then
        return detailsLine
    end

    local meta = SpellCastBuffs.ResolveEffectDebugMetaForTooltip(control, unitTag)
    local abilityId = control.effectId
    local override = type(abilityId) == "number" and Effects.EffectOverride[abilityId] or nil
    local ttUnit = (unitTag and unitTag ~= "") and unitTag or "player"

    local function addLine(label, value)
        InformationTooltip:AddHeaderLine(label, "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
        InformationTooltip:AddHeaderLine(value, "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
        detailsLine = detailsLine + 1
    end

    if meta then
        if meta.buffListIndex then
            addLine("Buff List Index", tostring(meta.buffListIndex))
        end
        if meta.effectType ~= nil then
            addLine("Buff/Debuff", formatEnumLabel(buffEffectTypeNames, meta.effectType))
        end
        if meta.stackCount ~= nil then
            addLine("Stacks (API)", tostring(meta.stackCount))
        end
        addLine("Status FX", formatEnumLabel(statusEffectTypeNames, meta.statusEffectType))
        if meta.abilityType and meta.abilityType ~= ABILITY_TYPE_NONE then
            addLine("Ability Type", formatEnumLabel(abilityTypeNames, meta.abilityType))
        end
        if meta.apiBuffSlot then
            addLine("API Buff Slot", tostring(meta.apiBuffSlot))
        end
        if meta.deprecatedBuffType and meta.deprecatedBuffType ~= "" then
            addLine("Deprecated BuffType", meta.deprecatedBuffType)
        end
        if meta.canClickOff ~= nil then
            addLine("Can Click Off", formatBool(meta.canClickOff))
        end
        if meta.castByPlayer ~= nil then
            addLine("Cast By Player", formatBool(meta.castByPlayer))
        end
        if meta.sourceType ~= nil then
            addLine("Event Source Type", formatEnumLabel(combatUnitTypeNames, meta.sourceType))
        end
        if meta.iconFilename and meta.iconFilename ~= "" then
            addLine("Icon", meta.iconFilename)
        end
        addUnitBuffTimingLines(meta, control, ttUnit, addLine)
    else
        addLine("API Meta", GetString(LUIE_STRING_BUFF_TOOLTIP_DEBUG_META_UNAVAILABLE))
    end

    if type(abilityId) == "number" then
        addBuffAbilityApiDebugLines(abilityId, ttUnit, addLine)
    end

    addCcTooltipDebugLines(override, meta, abilityId, addLine)

    return detailsLine
end
