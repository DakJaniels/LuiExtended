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

local DEBUG_OVERFLOW_TOOLTIP_DEFAULT_WIDTH = 416
local DEBUG_OVERFLOW_TOOLTIP_MIN_WIDTH = 384
local DEBUG_LINE_HEIGHT = 20
local SCREEN_MARGIN = 24
local BETWEEN_TOOLTIP_OFFSET_X = 20
--- Soft cap so debug meta splits to the overflow column before the primary tooltip grows off the top of the screen.
--- (ZO_Tooltip dimensionConstraints.maxHeight clamps a section but does not spawn a second tooltip; see ZO_Tooltip.lua GetDimensionWithContraints.)
local PRIMARY_DEBUG_LINE_CAP = 14

local debugMetaOverflowTooltip
local debugMetaOverflowContentKey
local debugMetaOverflowAnchorSide

--- @type ZO_ControlPool|nil
local debugMetaRemainingValueLabelPool

--- @class SCBBuffDebugMetaLiveRemaining
--- @field tooltip TooltipControl
--- @field headerRow integer
--- @field timeEnding number
--- @field lastText string
--- @field control Control
--- @field unitTag string
--- @field valueLabel LabelControl
--- @field valueLabelPoolKey integer

--- @type SCBBuffDebugMetaLiveRemaining|nil
local debugMetaLiveRemaining

--- @class SCBBuffDebugMetaLiveRemainingCtx
--- @field timeEnding number
--- @field control Control
--- @field unitTag string

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
if ABILITY_TYPE_SPECIALMOVEREPLACEMENT then
    abilityTypeNames[ABILITY_TYPE_SPECIALMOVEREPLACEMENT] = "SPECIALMOVEREPLACEMENT"
end

--- AbilityType value → label (API order 0..119). Fills gaps without pairs(_G) — insecure scan hits protected globals.
local ABILITY_TYPE_VALUE_LABELS =
{
    "NONE", "DAMAGE", "HEAL", "RESURRECT", "BLINK", "BONUS", "REGISTERTRIGGER", "SETTARGET", "THREAT", "STUN",
    "SNARE", "SILENCE", "REMOVETYPE", "SETCOOLDOWN", "COMBATRESOURCE", "DAMAGESHIELD", "MOVEPOSITION", "KNOCKBACK", "CHARGE", "IMMUNITY",
    "INTERCEPT", "REFLECTION", "AREAEFFECT", "PHASETHROUGH", "CREATEINVENTORYITEM", "DAMAGELIMIT", "AREATELEPORT", "FEAR", "TRAUMA", "STEALTH",
    "SEESTEALTH", "FLIGHT", "DISORIENT", "STAGGER", "SLOWFALL", "JUMP", "SIEGECLUSTERAREAEFFECT", "SUMMON", "MOUNT", "INTERACTREFUSALOVERRIDE",
    "BLADETURN", "NONEXISTENT", "NOKILL", "NOAGGRO", "DISPEL", "VAMPIRE", "CREATEINTERACTABLE", "MODIFYCOOLDOWN", "LEVITATE", "PACIFY",
    "ACTIONLIST", "INTERRUPT", "BLOCK", "OFFBALANCE", "EXHAUSTED", "MODIFYDURATION", "DODGE", "SHOWNON", "MISDIRECT", "FREECAST",
    "SIEGECREATE", "SIEGEAREAEFFECT", "DEFEND", "FREEINTERACT", "CHANGEAPPEARANCE", "ATTACKERREFLECT", "ATTACKERINTERCEPT", "DISARM", "PARRY", "PATHLINE",
    "DEPRECATED_0", "FIRETRIGGER", "LEAP", "REVEAL", "SIEGEPACKUP", "RECALL", "GRANTABILITY", "HIDE", "SETHOTBAR", "NOLOCKPICK",
    "FILLSOULGEM", "SOULGEMRESURRECT", "DESPAWNOVERRIDE", "UPDATEDEATHDIALOG", "COSTMECHANICOVERRIDE", "CLIENTFX", "AVOIDDEATH", "NONCOMBATBONUS", "NOSEETARGET", "DIRECTEDMOVEMENTABILITY",
    "SETPERSONALITY", "BASIC", "REWINDTIME", "LIGHTHEAVYATTACKOVERRIDE", "DERIVEDSTATCACHE", "AVAREACH", "RANDOMBRANCH", "MOUNTBLOCK", "PERSISTENTRADIUS", "HARDDISMOUNT",
    "LINKTARGET", "CUSTOMTARGETAREA", "DAMAGETRANSFER", "DISABLEITEMSETS", "FOLLOWWAYPOINTPATH", "SETAIMATTARGET", "FACETARGET", "LOSMOVEPOSITION", "DISABLECLIENTTURNING", "DAMAGEIMMUNE",
    "STOPMOVING", "RESOURCETAP", "HOTBARSLOTOVERRIDE", "REPAIR", "PREVENTHEALING", "PLAYERFLIGHT", "PAUSECOOLDOWN", "DISABLEGAMEPLAYMECHANICS", "MODIFYSTACKCOUNT", "SPECIALMOVEREPLACEMENT",
}

local function mergeAbilityTypeNamesFromGlobals()
    for value = 0, #ABILITY_TYPE_VALUE_LABELS - 1 do
        if not abilityTypeNames[value] then
            abilityTypeNames[value] = ABILITY_TYPE_VALUE_LABELS[value + 1]
        end
    end
end

mergeAbilityTypeNamesFromGlobals()

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

--- @param statusEffectType StatusEffectType|integer|nil
--- @return string
function SpellCastBuffs.FormatStatusEffectTypeLabel(statusEffectType)
    return formatEnumLabel(statusEffectTypeNames, statusEffectType)
end

--- @param abilityType AbilityType|integer|nil
--- @return string
function SpellCastBuffs.FormatAbilityTypeLabel(abilityType)
    return formatEnumLabel(abilityTypeNames, abilityType)
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

--- Coarser format for live countdown fields so tiny time deltas do not force tooltip rebuilds.
local function formatRemainingSeconds(value)
    if value == nil then
        return "—"
    end
    return string.format("%.1fs", value)
end

--- @param displayFormat AdvancedStatDisplayFormat|integer
--- @param effectValue integer|nil
--- @return string
local function formatAbilityAdvancedEffectValue(displayFormat, effectValue)
    local value = effectValue or 0
    if displayFormat == ADVANCED_STAT_DISPLAY_FORMAT_PERCENT
    or displayFormat == ADVANCED_STAT_DISPLAY_FORMAT_FLAT_OR_PERCENT then
        return zo_strformat(SI_STAT_VALUE_PERCENT, value)
    end
    if displayFormat == ADVANCED_STAT_DISPLAY_FORMAT_FLAT then
        return tostring(value)
    end
    return tostring(value)
end

--- @param derivedStat DerivedStats|integer
--- @param effectValue integer|nil
--- @return string
local function formatAbilityDerivedEffectValue(derivedStat, effectValue)
    local value = effectValue or 0
    if derivedStat == STAT_CRITICAL_STRIKE or derivedStat == STAT_SPELL_CRITICAL then
        return zo_strformat(SI_STAT_VALUE_PERCENT, GetCriticalStrikeChance(value))
    end
    return tostring(value)
end

--- @type table<integer, { displayName: string, description: string }>|nil
local advancedStatInfoByType

local advancedStatInfoCacheBuilt = false

local function buildAdvancedStatInfoCache()
    if advancedStatInfoCacheBuilt then
        return
    end
    advancedStatInfoCacheBuilt = true
    advancedStatInfoByType = {}

    local numCategories = GetNumAdvancedStatCategories()
    for categoryIndex = 1, numCategories do
        local categoryId = GetAdvancedStatsCategoryId(categoryIndex)
        local _, numStats = GetAdvancedStatCategoryInfo(categoryId)
        if numStats and numStats > 0 then
            for statIndex = 1, numStats do
                local statType, displayName, description = GetAdvancedStatInfo(categoryId, statIndex)
                if statType then
                    advancedStatInfoByType[statType] =
                    {
                        displayName = displayName,
                        description = description,
                    }
                end
            end
        end
    end
end

--- @param statType AdvancedStatDisplayType|integer
--- @return string
local function formatAdvancedStatTypeLabel(statType)
    buildAdvancedStatInfoCache()
    local info = advancedStatInfoByType and advancedStatInfoByType[statType]
    if info and info.displayName and info.displayName ~= "" then
        return string.format("%s (%s)", info.displayName, tostring(statType))
    end
    return formatStatWithId(advancedStatDisplayTypeNames, statType)
end

--- @param text string
--- @param maxLen integer
--- @return string
local function truncateDebugMetaSingleLine(text, maxLen)
    local normalized = text:gsub("[\r\n]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if #normalized <= maxLen then
        return normalized
    end
    return string.sub(normalized, 1, maxLen - 3) .. "..."
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

    for index = 1, numDerived do
        local derivedStat, effect = GetAbilityDerivedStatAndEffectByIndex(abilityId, index)
        if derivedStat ~= nil then
            addLine(
                string.format("derived[%d]", index),
                string.format(
                    "%s --> %s",
                    formatStatWithId(derivedStatNames, derivedStat),
                    formatAbilityDerivedEffectValue(derivedStat, effect)
                )
            )
        end
    end
end

--- @param abilityId integer
--- @param addLine fun(label: string, value: string)
local function addAdvancedStatDebugLines(abilityId, addLine)
    local numAdvanced = GetAbilityNumAdvancedStats(abilityId)
    if not numAdvanced or numAdvanced < 1 then
        return
    end

    buildAdvancedStatInfoCache()

    addLine("Advanced #", tostring(numAdvanced))

    local entries = {}
    for index = 1, numAdvanced do
        local statType, displayFormat, effectValue = GetAbilityAdvancedStatAndEffectByIndex(abilityId, index)
        if statType ~= nil then
            entries[#entries + 1] =
            {
                index = index,
                statType = statType,
                displayFormat = displayFormat,
                formattedEffect = formatAbilityAdvancedEffectValue(displayFormat, effectValue),
            }
        end
    end

    local groups = {}
    local groupOrder = {}
    for _, entry in ipairs(entries) do
        local groupKey = string.format("%s|%s", tostring(entry.displayFormat), entry.formattedEffect)
        local group = groups[groupKey]
        if not group then
            group =
            {
                displayFormat = entry.displayFormat,
                formattedEffect = entry.formattedEffect,
                items = {},
            }
            groups[groupKey] = group
            groupOrder[#groupOrder + 1] = groupKey
        end
        group.items[#group.items + 1] = entry
    end

    for _, groupKey in ipairs(groupOrder) do
        local group = groups[groupKey]
        local items = group.items
        if #items > 1 then
            local minStat = items[1].statType
            local maxStat = items[1].statType
            for itemIndex = 2, #items do
                minStat = zo_min(minStat, items[itemIndex].statType)
                maxStat = zo_max(maxStat, items[itemIndex].statType)
            end
            local statRange = minStat == maxStat and tostring(minStat) or string.format("%s–%s", minStat, maxStat)
            local valueStr = string.format(
                "%d stats (%s) | %s --> %s",
                #items,
                statRange,
                formatEnumLabel(advancedStatDisplayFormatNames, group.displayFormat),
                group.formattedEffect
            )
            addLine(string.format("adv (×%d)", #items), valueStr)
        else
            local entry = items[1]
            addLine(
                string.format("adv[%d]", entry.index),
                string.format(
                    "%s | %s --> %s",
                    formatAdvancedStatTypeLabel(entry.statType),
                    formatEnumLabel(advancedStatDisplayFormatNames, entry.displayFormat),
                    entry.formattedEffect
                )
            )
        end
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

    local statusFx = meta and meta.statusEffectType or nil
    local abiType = meta and meta.abilityType or nil
    local resolvedCc = (type(abilityId) == "number") and SpellCastBuffs.ResolveEffectCcType(abilityId, statusFx, abiType) or nil

    if override then
        if override.cc then
            addLine("LUIE cc (override)", SpellCastBuffs.GetLuiCcTypeLabel(override.cc))
        end
        if override.ccMergedType then
            addLine("LUIE cc (merged)", SpellCastBuffs.GetLuiCcTypeLabel(override.ccMergedType))
        end
    end

    if resolvedCc then
        addLine("LUIE cc (resolved)", SpellCastBuffs.GetLuiCcTypeLabel(resolvedCc))
    elseif override and not override.cc and not override.ccMergedType then
        addLine("LUIE cc (resolved)", GetString(LUIE_STRING_BUFF_TOOLTIP_DEBUG_META_NO_CC))
    elseif type(abilityId) == "number" and not override then
        addLine("LUIE cc (resolved)", GetString(LUIE_STRING_BUFF_TOOLTIP_DEBUG_META_NO_OVERRIDE))
    end

    if SpellCastBuffs.SV.ColorCC then
        if resolvedCc then
            addLine("CC Color", GetString(LUIE_STRING_BUFF_TOOLTIP_DEBUG_META_CC_COLOR_ON))
        else
            addLine("CC Color", GetString(LUIE_STRING_BUFF_TOOLTIP_DEBUG_META_CC_COLOR_OFF))
        end
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
--- @param preferredBuffListIndex integer|nil
--- @return SCBBuffDebugMeta|nil
local function lookupDebugMetaFromUnitBuffs(unitTag, abilityId, preferredBuffSlot, preferredBuffListIndex)
    local matches = {}
    for i = 1, GetNumBuffs(unitTag) do
        local _, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, deprecatedBuffType, effectType, abilityType, statusEffectType, buffAbilityId, rowCanClickOff, rowCastByPlayer = GetUnitBuffInfo(unitTag, i)
        if buffAbilityId == abilityId then
            local row = buildMetaFromUnitBuffRow(unitTag, timeStarted, timeEnding, buffSlot, stackCount, deprecatedBuffType, effectType, abilityType, statusEffectType, nil)
            row.canClickOff = rowCanClickOff
            row.castByPlayer = rowCastByPlayer
            row.buffListIndex = i
            row.iconFilename = iconFilename
            matches[#matches + 1] = row
        end
    end

    if #matches == 0 then
        return nil
    end
    if #matches == 1 then
        return matches[1]
    end

    if preferredBuffListIndex then
        for _, row in ipairs(matches) do
            if row.buffListIndex == preferredBuffListIndex then
                return row
            end
        end
    end

    if preferredBuffSlot then
        for _, row in ipairs(matches) do
            if row.apiBuffSlot == preferredBuffSlot then
                return row
            end
        end
    end

    return matches[1]
end

--- Snapshot list index + API timings from GetUnitBuffInfo while the effect row is live.
--- @param unitTag string
--- @param abilityId integer
--- @param effectSlot integer
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param effectType BuffEffectType
--- @param iconFilename string
--- @return SCBBuffDebugMetaOverlay
function SpellCastBuffs.SnapshotLiveBuffDebugOverlay(unitTag, abilityId, effectSlot, beginTime, endTime, stackCount, effectType, iconFilename)
    for i = 1, GetNumBuffs(unitTag) do
        local _, timeStarted, timeEnding, buffSlot, stacks, icon, _, rowEffectType, _, _, buffAbilityId = GetUnitBuffInfo(unitTag, i)
        if buffAbilityId == abilityId and buffSlot == effectSlot then
            return
            {
                buffListIndex = i,
                timeStarted = timeStarted,
                timeEnding = timeEnding,
                stackCount = stacks,
                effectType = rowEffectType,
                iconFilename = icon,
            }
        end
    end

    return
    {
        timeStarted = beginTime,
        timeEnding = endTime,
        stackCount = stackCount,
        effectType = effectType,
        iconFilename = iconFilename,
    }
end

--- @param control table
--- @param unitTag string
--- @return SCBBuffDebugMeta|nil
function SpellCastBuffs.ResolveEffectDebugMetaForTooltip(control, unitTag)
    local abilityId = control.effectId
    local preferredBuffSlot = control.buffSlot or (control.debugMeta and control.debugMeta.apiBuffSlot)
    local preferredBuffListIndex = control.debugMeta and control.debugMeta.buffListIndex
    local live

    if type(abilityId) == "number" and unitTag and unitTag ~= "" then
        live = lookupDebugMetaFromUnitBuffs(unitTag, abilityId, preferredBuffSlot, preferredBuffListIndex)
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
            addLine("API Remaining", formatRemainingSeconds(remain))
        end
    elseif meta and meta.timeEnding == 0 then
        addLine("API Duration", "infinite")
    end

    if control.duration and control.duration > 0 then
        addLine("LUIE Duration (internal)", formatSeconds(control.duration / 1000))
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
        addLine("GetAbilityDuration (def)", string.format("%s ms (%.2fs)", tostring(durationMs), durationMs / 1000))
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

local function releaseLiveRemainingPoolLabel(state)
    if state and state.valueLabelPoolKey and debugMetaRemainingValueLabelPool then
        debugMetaRemainingValueLabelPool:ReleaseObject(state.valueLabelPoolKey)
    end
end

local function clearDebugMetaLiveRemaining()
    if debugMetaLiveRemaining then
        releaseLiveRemainingPoolLabel(debugMetaLiveRemaining)
    end
    debugMetaLiveRemaining = nil
end

--- Same virtual template as ZO_TooltipSection.labelPool (ZO_Tooltip.lua).
--- @return ZO_ControlPool
local function GetDebugMetaRemainingValueLabelPool()
    if not debugMetaRemainingValueLabelPool then
        local pool = ZO_ControlPool:New("ZO_TooltipLabel", GuiRoot, "LUIE_SCB_DebugMetaRemaining")
        pool:SetCustomFactoryBehavior(function (label)
            label:SetFont("ZoFontWinT1")
            label:SetColor(1, 1, 1, 1)
            label:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
            label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
        end)
        pool:SetCustomResetBehavior(function (label)
            label:SetText("")
            label:SetHidden(true)
            label:ClearAnchors()
            label:SetParent(GuiRoot)
        end)
        debugMetaRemainingValueLabelPool = pool
    end
    return debugMetaRemainingValueLabelPool
end

--- AddHeaderLine on the same row stacks labels; use a header control for live countdown updates.
--- @return LabelControl label
--- @return integer poolKey
local function acquireLiveRemainingValueLabel()
    return GetDebugMetaRemainingValueLabelPool():AcquireObject()
end

--- @param tooltip TooltipControl
--- @param label string
--- @param value string
--- @param headerLineIndex integer
--- @param liveRemainingCtx SCBBuffDebugMetaLiveRemainingCtx|nil
--- @return integer nextHeaderLineIndex
local function appendDebugMetaLineToTooltip(tooltip, label, value, headerLineIndex, liveRemainingCtx)
    tooltip:AddHeaderLine(label, "ZoFontWinT1", headerLineIndex, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
    local valueText = tostring(value)
    if label == "API Remaining" and liveRemainingCtx then
        local valueLabel, poolKey = acquireLiveRemainingValueLabel()
        valueLabel:SetText(valueText)
        tooltip:AddHeaderControl(valueLabel, headerLineIndex, TOOLTIP_HEADER_SIDE_RIGHT)
        debugMetaLiveRemaining =
        {
            tooltip = tooltip,
            headerRow = headerLineIndex,
            timeEnding = liveRemainingCtx.timeEnding,
            lastText = valueText,
            control = liveRemainingCtx.control,
            unitTag = liveRemainingCtx.unitTag,
            valueLabel = valueLabel,
            valueLabelPoolKey = poolKey,
        }
    else
        tooltip:AddHeaderLine(valueText, "ZoFontWinT1", headerLineIndex, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
    end
    return headerLineIndex + 1
end

--- @param tooltip TooltipControl
--- @param debugLines { label: string, value: string }[]
--- @param startIndex integer
--- @param endIndex integer
--- @param headerLineIndex integer
--- @param liveRemainingCtx SCBBuffDebugMetaLiveRemainingCtx|nil
--- @return integer nextHeaderLineIndex
local function appendDebugMetaLineRangeToTooltip(tooltip, debugLines, startIndex, endIndex, headerLineIndex, liveRemainingCtx)
    for i = startIndex, endIndex do
        local row = debugLines[i]
        headerLineIndex = appendDebugMetaLineToTooltip(tooltip, row.label, row.value, headerLineIndex, liveRemainingCtx)
    end
    if endIndex >= startIndex then
        tooltip:SetVerticalPadding(2)
    end
    return headerLineIndex
end

--- Stable key for overflow rebuild; API Remaining is omitted so sub-second drift does not clear the column.
--- @param debugLines { label: string, value: string }[]
--- @return string
local function buildDebugMetaOverflowContentKey(debugLines)
    local parts = {}
    for i = 1, #debugLines do
        local row = debugLines[i]
        if row.label == "API Remaining" then
            parts[i] = row.label
        else
            parts[i] = string.format("%s=%s", row.label, tostring(row.value))
        end
    end
    return table.concat(parts, "\n")
end

--- @return TooltipControl
local function GetDebugMetaOverflowTooltip()
    if not debugMetaOverflowTooltip then
        debugMetaOverflowTooltip = LUIE_SCB_DebugOverflowTooltip
        debugMetaOverflowTooltip:SetDimensionConstraints(DEBUG_OVERFLOW_TOOLTIP_DEFAULT_WIDTH, 0, DEBUG_OVERFLOW_TOOLTIP_DEFAULT_WIDTH, 0)
        debugMetaOverflowTooltip:SetResizeToFitPadding(32, 40)
        debugMetaOverflowTooltip:SetHeaderVerticalOffset(11)
    end
    return debugMetaOverflowTooltip
end

--- Match primary tooltip width so long API header labels (e.g. IsAbilityDurationToggled) do not wrap mid-word.
--- @param overflow TooltipControl
--- @param primary TooltipControl
local function applyDebugOverflowTooltipWidth(overflow, primary)
    local width = DEBUG_OVERFLOW_TOOLTIP_DEFAULT_WIDTH
    if primary then
        local primaryLeft, _, primaryRight, _ = primary:GetScreenRect()
        local primaryWidth = primaryRight - primaryLeft
        if primaryWidth >= DEBUG_OVERFLOW_TOOLTIP_MIN_WIDTH then
            width = zo_floor(primaryWidth)
        end
    end
    overflow:SetDimensionConstraints(width, 0, width, 0)
end

--- @param numLines integer
--- @return integer
local function computePrimaryDebugLineCount(numLines)
    if numLines <= 1 then
        return numLines
    end

    local screenHeight = select(2, GuiRoot:GetDimensions())
    local maxByScreen = zo_floor((screenHeight - (2 * SCREEN_MARGIN)) / DEBUG_LINE_HEIGHT)

    -- Do not use InformationTooltip:GetScreenRect() here: primary height changes as lines are added,
    -- which makes the split cap unstable and forces overflow re-layout flicker.
    local cap = zo_min(PRIMARY_DEBUG_LINE_CAP, maxByScreen)
    cap = zo_max(1, cap)

    if numLines <= cap then
        return numLines
    end
    return cap
end

--- @param debugLines { label: string, value: string }[]
--- @param cap integer
--- @return integer
local function resolvePrimarySplitCount(debugLines, cap)
    local numLines = #debugLines
    if numLines <= cap then
        return numLines
    end
    for i = 1, numLines do
        local label = debugLines[i].label
        if label == "Derived #" or label == "Advanced #" then
            if i > 1 then
                return zo_min(i - 1, cap)
            end
        end
    end
    return cap
end

-- Matches Tooltip.lua quadrant ids (CalculateQuandrant / DynamicAnchorLayout).
local QUAD_TOPLEFT = 1
local QUAD_TOPRIGHT = 2
local QUAD_BOTTOMRIGHT = 3
local QUAD_BOTTOMLEFT = 4

--- @param control Control
--- @return integer quadrant
local function calculateBuffIconQuadrant(control)
    local left, top, right, bottom = control:GetScreenRect()
    local scale = control:GetScale()
    if scale == 0 then
        scale = 1
    end
    local middleX = (left + right) / (2 * scale)
    local middleY = (top + bottom) / (2 * scale)
    local screenWidth, screenHeight = GuiRoot:GetDimensions()
    local screenMidX = screenWidth / 2
    local screenMidY = screenHeight / 2

    if middleX >= screenMidX and middleY < screenMidY then
        return QUAD_TOPRIGHT
    elseif middleX >= screenMidX and middleY >= screenMidY then
        return QUAD_BOTTOMRIGHT
    elseif middleX < screenMidX and middleY >= screenMidY then
        return QUAD_BOTTOMLEFT
    end
    return QUAD_TOPLEFT
end

--- @param overflow TooltipControl
--- @param primary TooltipControl
--- @param buffControl Control|nil
local function anchorDebugOverflowBesidePrimary(overflow, primary, buffControl)
    overflow:SetHidden(false)
    overflow:SetAlpha(1)
    applyDebugOverflowTooltipWidth(overflow, primary)

    local screenWidth = select(1, GuiRoot:GetDimensions())
    local primaryLeft, _, primaryRight, _ = primary:GetScreenRect()
    local overflowLeft, _, overflowRight, _ = overflow:GetScreenRect()
    local overflowWidth = overflowRight - overflowLeft
    if overflowWidth <= 0 then
        overflowWidth = primaryRight - primaryLeft
    end
    if overflowWidth <= 0 then
        overflowWidth = 280
    end

    local gap = BETWEEN_TOOLTIP_OFFSET_X
    local roomRight = screenWidth - SCREEN_MARGIN - primaryRight
    local roomLeft = primaryLeft - SCREEN_MARGIN
    local fitsRight = roomRight >= overflowWidth + gap
    local fitsLeft = roomLeft >= overflowWidth + gap

    -- Tooltip.lua: left-half screen --> comparative on primary's right; right-half --> comparative on left.
    local preferRightByQuadrant = false
    if buffControl then
        local quadrant = calculateBuffIconQuadrant(buffControl)
        preferRightByQuadrant = quadrant == QUAD_TOPLEFT or quadrant == QUAD_BOTTOMLEFT
    end

    local anchorOnPrimaryRight
    if fitsRight and (not fitsLeft or preferRightByQuadrant) then
        anchorOnPrimaryRight = true
    elseif fitsLeft then
        anchorOnPrimaryRight = false
    elseif roomRight >= roomLeft then
        anchorOnPrimaryRight = true
    else
        anchorOnPrimaryRight = false
    end

    local sideKey = anchorOnPrimaryRight and "right" or "left"
    if debugMetaOverflowAnchorSide == sideKey and not overflow:IsHidden() then
        return
    end
    debugMetaOverflowAnchorSide = sideKey

    if anchorOnPrimaryRight then
        overflow:SetOwner(primary, TOPLEFT, gap, 0, TOPRIGHT)
    else
        overflow:SetOwner(primary, TOPRIGHT, -gap, 0, TOPLEFT)
    end
end

--- @param debugLines { label: string, value: string }[]
--- @param buffControl Control|nil
--- @param detailsLine integer
--- @param liveRemainingCtx SCBBuffDebugMetaLiveRemainingCtx|nil
--- @return integer detailsLine
local function flushDebugMetaTooltips(debugLines, buffControl, detailsLine, liveRemainingCtx)
    local numLines = #debugLines
    if numLines == 0 then
        SpellCastBuffs.ClearDebugMetaOverflowTooltip()
        return detailsLine
    end

    local primaryCount = resolvePrimarySplitCount(debugLines, computePrimaryDebugLineCount(numLines))

    detailsLine = appendDebugMetaLineRangeToTooltip(InformationTooltip, debugLines, 1, primaryCount, detailsLine, liveRemainingCtx)

    if numLines <= primaryCount then
        SpellCastBuffs.ClearDebugMetaOverflowTooltip()
        return detailsLine
    end

    local overflow = GetDebugMetaOverflowTooltip()
    local overflowKey = buildDebugMetaOverflowContentKey(debugLines)
    local overflowLinesStart = primaryCount + 1

    applyDebugOverflowTooltipWidth(overflow, InformationTooltip)

    if overflowKey == debugMetaOverflowContentKey and not overflow:IsHidden() then
        anchorDebugOverflowBesidePrimary(overflow, InformationTooltip, buffControl)
        return detailsLine
    end

    debugMetaOverflowContentKey = overflowKey
    debugMetaOverflowAnchorSide = nil

    if overflow.ClearLines then
        overflow:ClearLines()
    end
    overflow:AddLine("Debug meta (continued)", "ZoFontWinT1", ZO_NORMAL_TEXT:UnpackRGB())
    overflow:SetVerticalPadding(2)

    appendDebugMetaLineRangeToTooltip(overflow, debugLines, overflowLinesStart, numLines, 1, liveRemainingCtx)

    anchorDebugOverflowBesidePrimary(overflow, InformationTooltip, buffControl)
    return detailsLine
end

function SpellCastBuffs.ClearDebugMetaOverflowTooltip()
    debugMetaOverflowContentKey = nil
    debugMetaOverflowAnchorSide = nil
    if debugMetaOverflowTooltip then
        ClearTooltipImmediately(debugMetaOverflowTooltip)
    end
end

function SpellCastBuffs.ClearDebugMetaTooltipLiveUpdate()
    clearDebugMetaLiveRemaining()
end

function SpellCastBuffs.TickDebugMetaTooltipLiveUpdate()
    if not SpellCastBuffs.SV.TooltipDebugMeta then
        return
    end

    local state = debugMetaLiveRemaining
    if not state then
        return
    end

    if InformationTooltip:IsHidden() then
        clearDebugMetaLiveRemaining()
        return
    end

    local hover = SpellCastBuffs.tooltipHoverState
    if not hover or hover.control ~= state.control then
        clearDebugMetaLiveRemaining()
        return
    end

    if state.tooltip:IsHidden() then
        clearDebugMetaLiveRemaining()
        return
    end

    local timeEnding = state.timeEnding
    local meta = SpellCastBuffs.ResolveEffectDebugMetaForTooltip(state.control, state.unitTag)
    if meta and meta.timeEnding and meta.timeEnding > 0 then
        timeEnding = meta.timeEnding
        state.timeEnding = timeEnding
    end

    if not timeEnding or timeEnding <= 0 then
        clearDebugMetaLiveRemaining()
        return
    end

    local remain = timeEnding - GetGameTimeSeconds()
    if remain < 0 then
        clearDebugMetaLiveRemaining()
        return
    end

    local text = formatRemainingSeconds(remain)
    if text == state.lastText then
        return
    end

    state.lastText = text
    if state.valueLabel then
        state.valueLabel:SetText(text)
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

    local debugLines = {}
    local function addLine(label, value)
        debugLines[#debugLines + 1] = { label = label, value = value }
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
            local effectDesc = GetAbilityEffectDescription(meta.apiBuffSlot)
            if effectDesc and effectDesc ~= "" then
                addLine("API Effect Desc", truncateDebugMetaSingleLine(effectDesc, 80))
            end
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
        if override and override.dynamicTooltip then
            local morphId = override.tooltipMorphId or abilityId
            if morphId ~= abilityId then
                addLine("Tooltip description id", tostring(morphId))
            end
        end
        addBuffAbilityApiDebugLines(abilityId, ttUnit, addLine)
    end

    addCcTooltipDebugLines(override, meta, abilityId, addLine)

    clearDebugMetaLiveRemaining()

    local liveRemainingCtx
    if meta and meta.timeStarted and meta.timeEnding and meta.timeEnding > 0 then
        liveRemainingCtx =
        {
            timeEnding = meta.timeEnding,
            control = control,
            unitTag = ttUnit,
        }
    end

    detailsLine = flushDebugMetaTooltips(debugLines, control, detailsLine, liveRemainingCtx)

    return detailsLine
end
