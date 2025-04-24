-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

local ACTION_RESULT_BLOCKED_DAMAGE = ACTION_RESULT_BLOCKED_DAMAGE
local ACTION_RESULT_CHARMED = ACTION_RESULT_CHARMED
local ACTION_RESULT_CRITICAL_DAMAGE = ACTION_RESULT_CRITICAL_DAMAGE
local ACTION_RESULT_CRITICAL_HEAL = ACTION_RESULT_CRITICAL_HEAL
local ACTION_RESULT_DAMAGE = ACTION_RESULT_DAMAGE
local ACTION_RESULT_DAMAGE_SHIELDED = ACTION_RESULT_DAMAGE_SHIELDED
local ACTION_RESULT_DISORIENTED = ACTION_RESULT_DISORIENTED
local ACTION_RESULT_DODGED = ACTION_RESULT_DODGED
local ACTION_RESULT_DOT_TICK = ACTION_RESULT_DOT_TICK
local ACTION_RESULT_DOT_TICK_CRITICAL = ACTION_RESULT_DOT_TICK_CRITICAL
local ACTION_RESULT_FALL_DAMAGE = ACTION_RESULT_FALL_DAMAGE
local ACTION_RESULT_FEARED = ACTION_RESULT_FEARED
local ACTION_RESULT_HEAL = ACTION_RESULT_HEAL
local ACTION_RESULT_HOT_TICK = ACTION_RESULT_HOT_TICK
local ACTION_RESULT_HOT_TICK_CRITICAL = ACTION_RESULT_HOT_TICK_CRITICAL
local ACTION_RESULT_IMMUNE = ACTION_RESULT_IMMUNE
local ACTION_RESULT_INTERRUPT = ACTION_RESULT_INTERRUPT
local ACTION_RESULT_MISS = ACTION_RESULT_MISS
local ACTION_RESULT_OFFBALANCE = ACTION_RESULT_OFFBALANCE
local ACTION_RESULT_PARRIED = ACTION_RESULT_PARRIED
local ACTION_RESULT_POWER_DRAIN = ACTION_RESULT_POWER_DRAIN
local ACTION_RESULT_POWER_ENERGIZE = ACTION_RESULT_POWER_ENERGIZE
local ACTION_RESULT_REFLECTED = ACTION_RESULT_REFLECTED
local ACTION_RESULT_SILENCED = ACTION_RESULT_SILENCED
local ACTION_RESULT_STUNNED = ACTION_RESULT_STUNNED
local COMBAT_UNIT_TYPE_PLAYER = COMBAT_UNIT_TYPE_PLAYER
local COMBAT_UNIT_TYPE_PLAYER_PET = COMBAT_UNIT_TYPE_PLAYER_PET
local DAMAGE_TYPE_BLEED = DAMAGE_TYPE_BLEED
local DAMAGE_TYPE_COLD = DAMAGE_TYPE_COLD
local DAMAGE_TYPE_DISEASE = DAMAGE_TYPE_DISEASE
local DAMAGE_TYPE_DROWN = DAMAGE_TYPE_DROWN
local DAMAGE_TYPE_EARTH = DAMAGE_TYPE_EARTH
local DAMAGE_TYPE_FIRE = DAMAGE_TYPE_FIRE
local DAMAGE_TYPE_GENERIC = DAMAGE_TYPE_GENERIC
local DAMAGE_TYPE_MAGIC = DAMAGE_TYPE_MAGIC
local DAMAGE_TYPE_NONE = DAMAGE_TYPE_NONE
local DAMAGE_TYPE_OBLIVION = DAMAGE_TYPE_OBLIVION
local DAMAGE_TYPE_PHYSICAL = DAMAGE_TYPE_PHYSICAL
local DAMAGE_TYPE_POISON = DAMAGE_TYPE_POISON
local DAMAGE_TYPE_SHOCK = DAMAGE_TYPE_SHOCK

--- @class (partial) CombatTextConstants
local combatTextConstants =
{
    -- Damage & Healing
    isDamage =
    {
        [ACTION_RESULT_DAMAGE] = true,
        [ACTION_RESULT_FALL_DAMAGE] = true,
    },
    isDamageCritical =
    {
        [ACTION_RESULT_CRITICAL_DAMAGE] = true,
    },
    isHealing =
    {
        [ACTION_RESULT_HEAL] = true,
    },
    isHealingCritical =
    {
        [ACTION_RESULT_CRITICAL_HEAL] = true,
    },
    isEnergize =
    {
        [ACTION_RESULT_POWER_ENERGIZE] = true,
    },
    isDrain =
    {
        [ACTION_RESULT_POWER_DRAIN] = true,
    },
    isDot =
    {
        [ACTION_RESULT_DOT_TICK] = true,
    },
    isDotCritical =
    {
        [ACTION_RESULT_DOT_TICK_CRITICAL] = true,
    },
    isHot =
    {
        [ACTION_RESULT_HOT_TICK] = true,
    },
    isHotCritical =
    {
        [ACTION_RESULT_HOT_TICK_CRITICAL] = true,
    },
    damageType =
    {
        [DAMAGE_TYPE_NONE] = true,
        [DAMAGE_TYPE_GENERIC] = true,
        [DAMAGE_TYPE_PHYSICAL] = true,
        [DAMAGE_TYPE_FIRE] = true,
        [DAMAGE_TYPE_SHOCK] = true,
        [DAMAGE_TYPE_OBLIVION] = true,
        [DAMAGE_TYPE_COLD] = true,
        [DAMAGE_TYPE_EARTH] = true,
        [DAMAGE_TYPE_MAGIC] = true,
        [DAMAGE_TYPE_DROWN] = true,
        [DAMAGE_TYPE_DISEASE] = true,
        [DAMAGE_TYPE_POISON] = true,
        [DAMAGE_TYPE_BLEED] = true,
    },
    -- Mitigation
    isMiss =
    {
        [ACTION_RESULT_MISS] = true,
    },
    isImmune =
    {
        [ACTION_RESULT_IMMUNE] = true,
    },
    isParried =
    {
        [ACTION_RESULT_PARRIED] = true,
    },
    isReflected =
    {
        [ACTION_RESULT_REFLECTED] = true,
    },
    isDamageShield =
    {
        [ACTION_RESULT_DAMAGE_SHIELDED] = true,
    },
    isDodged =
    {
        [ACTION_RESULT_DODGED] = true,
    },
    isBlocked =
    {
        [ACTION_RESULT_BLOCKED_DAMAGE] = true,
    },
    isInterrupted =
    {
        [ACTION_RESULT_INTERRUPT] = true,
    },
    -- Crowd Control
    isDisoriented =
    {
        [ACTION_RESULT_DISORIENTED] = true,
    },
    isFeared =
    {
        [ACTION_RESULT_FEARED] = true,
    },
    isOffBalanced =
    {
        [ACTION_RESULT_OFFBALANCE] = true,
    },
    isSilenced =
    {
        [ACTION_RESULT_SILENCED] = true,
    },
    isStunned =
    {
        [ACTION_RESULT_STUNNED] = true,
    },
    isCharmed =
    {
        [ACTION_RESULT_CHARMED] = true,
    },
    -- Player Checks
    isPlayer =
    {
        [COMBAT_UNIT_TYPE_PLAYER] = true,
        [COMBAT_UNIT_TYPE_PLAYER_PET] = true,
    },
    -- Event Types
    eventType =
    {
        ALERT = "LUIE_CombatText_EVENT_ALERT",
        COMBAT = "LUIE_CombatText_EVENT_COMBAT",
        POINT = "LUIE_CombatText_EVENT_POINT",
        CROWDCONTROL = "LUIE_CombatText_EVENT_CROWDCONTROL",
        RESOURCE = "LUIE_CombatText_EVENT_RESOURCE",
        DEATH = "LUIE_CombatText_EVENT_DEATH",
    },
    combatType =
    {
        INCOMING = "LUIE_CombatText_COMBAT_TYPE_INCOMING",
        OUTGOING = "LUIE_CombatText_COMBAT_TYPE_OUTGOING",
    },
    crowdControlType =
    {
        DISORIENTED = "LUIE_CombatText_CROWDCONTROL_TYPE_DISORIENTED",
        FEARED = "LUIE_CombatText_CROWDCONTROL_TYPE_FEARED",
        OFFBALANCED = "LUIE_CombatText_CROWDCONTROL_TYPE_OFFBALANCED",
        SILENCED = "LUIE_CombatText_CROWDCONTROL_TYPE_SILENCED",
        STUNNED = "LUIE_CombatText_CROWDCONTROL_TYPE_STUNNED",
        CHARMED = "LUIE_CombatText_CROWDCONTROL_TYPE_CHARMED",
    },
    pointType =
    {
        ALLIANCE_POINTS = "LUIE_CombatText_Point_TYPE_ALLIANCE_POINTS",
        EXPERIENCE_POINTS = "LUIE_CombatText_Point_TYPE_EXPERIENCE_POINTS",
        CHAMPION_POINTS = "LUIE_CombatText_Point_TYPE_CHAMPION_POINTS",
        IN_COMBAT = "LUIE_CombatText_Point_TYPE_IN_COMBAT",
        OUT_COMBAT = "LUIE_CombatText_Point_TYPE_OUT_COMBAT",
    },
    resourceType =
    {
        LOW_HEALTH = "LUIE_CombatText_Resource_TYPE_LOW_HEALTH",
        LOW_MAGICKA = "LUIE_CombatText_Resource_TYPE_LOW_MAGICKA",
        LOW_STAMINA = "LUIE_CombatText_Resource_TYPE_LOW_STAMINA",
        ULTIMATE = "LUIE_CombatText_Resource_TYPE_ULTIMATE",
        POTION = "LUIE_CombatText_Resource_TYPE_POTION",
    },
    poolType =
    {
        CONTROL = "LUIE_CombatText_POOL_TYPE_CONTROL",
        ANIMATION_CLOUD = "LUIE_CombatText_POOL_TYPE_ANIMATION_CLOUD",
        ANIMATION_CLOUD_CRITICAL = "LUIE_CombatText_POOL_TYPE_ANIMATION_CLOUD_CRITICAL",
        ANIMATION_CLOUD_FIREWORKS = "LUIE_CombatText_POOL_TYPE_ANIMATION_CLOUD_FIREWORKS",
        ANIMATION_SCROLL = "LUIE_CombatText_POOL_TYPE_ANIMATION_SCROLL",
        ANIMATION_SCROLL_CRITICAL = "LUIE_CombatText_POOL_TYPE_ANIMATION_SCROLL_CRITICAL",
        ANIMATION_ELLIPSE_X = "LUIE_CombatText_POOL_TYPE_ANIMATION_ELLIPSE_X",
        ANIMATION_ELLIPSE_Y = "LUIE_CombatText_POOL_TYPE_ANIMATION_ELLIPSE_Y",
        ANIMATION_ELLIPSE_X_CRIT = "LUIE_CombatText_POOL_TYPE_ANIMATION_ELLIPSE_X_CRITICAL",
        ANIMATION_ELLIPSE_Y_CRIT = "LUIE_CombatText_POOL_TYPE_ANIMATION_ELLIPSE_Y_CRITICAL",
        ANIMATION_ALERT = "LUIE_CombatText_POOL_TYPE_ANIMATION_ALERT",
        ANIMATION_COMBATSTATE = "LUIE_CombatText_POOL_TYPE_ANIMATION_COMBATSTATE",
        ANIMATION_POINT = "LUIE_CombatText_POOL_TYPE_ANIMATION_POINT",
        ANIMATION_RESOURCE = "LUIE_CombatText_POOL_TYPE_ANIMATION_RESOURCE",
        ANIMATION_DEATH = "LUIE_CombatText_POOL_TYPE_ANIMATION_DEATH",
    },

    -- Animation & Fonts
    outlineType =
    {
        "none",
        "outline",
        "thin-outline",
        "thick-outline",
        "shadow",
        "soft-shadow-thin",
        "soft-shadow-thick",
    },
    animationType = { "cloud", "hybrid", "scroll", "ellipse" },
    directionType = { "up", "down" },
    iconSide = { "none", "left", "right" },
}
--- @class (partial) CombatTextConstants
Data.CombatTextConstants = combatTextConstants
