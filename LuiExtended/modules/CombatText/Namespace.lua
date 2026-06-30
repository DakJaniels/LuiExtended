-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE
-- CombatText namespace
--- @class (partial) LuiExtended.CombatText
LUIE.CombatText = {}
--- @class (partial) LuiExtended.CombatText
local CombatText = LUIE.CombatText

CombatText.Enabled = false

--- @param unitTag string
--- @param useAccountName boolean
--- @return string? formattedName
function CombatText.ResolveGroupDeathName(unitTag, useAccountName)
    local raw
    if useAccountName then
        raw = GetUnitDisplayName(unitTag)
        if raw == nil or raw == "" then
            raw = GetUnitName(unitTag)
        end
    else
        raw = GetUnitName(unitTag)
        if raw == nil or raw == "" then
            raw = GetUnitDisplayName(unitTag)
        end
    end
    if raw == nil or raw == "" then
        return nil
    end
    return zo_strformat("<<1>>", raw)
end

CombatText.Defaults =
{
    unlocked = false,
    blacklist = {},
    -- Panel Defaults
    panels =
    {
        -- Outgoing
        LUIE_CombatText_Outgoing =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = 450,
            offsetY = -220,
            dimensions = { 400, 100 },
        },
        -- Incoming
        LUIE_CombatText_Incoming =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = -450,
            offsetY = -220,
            dimensions = { 400, 100 },
        },
        -- Alerts
        LUIE_CombatText_Alert =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = 0,
            offsetY = 250,
            dimensions = { 400, 100 },
        },
        -- Points
        LUIE_CombatText_Point =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = 0,
            offsetY = -300,
            dimensions = { 400, 100 },
        },
        -- Resources
        LUIE_CombatText_Resource =
        {
            point = CENTER,
            relativePoint = CENTER,
            offsetX = 0,
            offsetY = 375,
            dimensions = { 400, 100 },
        },
    },
    common =
    {
        oocAlpha = 100,
        incAlpha = 100,
        overkill = true,
        overheal = true,
        abbreviateNumbers = false,
        useDefaultIcon = false,
        defaultIconOptions = 1,
        -- Infer incoming drain from bar ability use + power drop (combat log often omits POWER_DRAIN)
        inferResourceDrainOnCast = false,
    },
    -- Toggle Defaults
    toggles =
    {
        -- General
        inCombatOnly = false,
        showThrottleTrailer = true,
        throttleCriticals = false,

        -- Incoming
        incoming =
        {
            -- Damage & Healing
            showDamage = true,
            showHealing = true,
            showEnergize = true,
            showUltimateEnergize = true,
            showDrain = true,
            showDot = true,
            showHot = true,

            -- Mitigation
            showMiss = true,
            showImmune = true,
            showParried = true,
            showReflected = true,
            showDamageShield = true,
            showDodged = true,
            showBlocked = true,
            showInterrupted = true,

            -- Crowd Control
            showDisoriented = true,
            showFeared = true,
            showOffBalanced = true,
            showSilenced = true,
            showStunned = true,
            showCharmed = true,
        },

        -- Outgoing
        outgoing =
        {
            -- Damage & Healing
            showDamage = true,
            showHealing = true,
            showEnergize = true,
            showUltimateEnergize = true,
            showDrain = true,
            showDot = true,
            showHot = true,

            -- Mitigation
            showMiss = true,
            showImmune = true,
            showParried = true,
            showReflected = true,
            showDamageShield = true,
            showDodged = true,
            showBlocked = true,
            showInterrupted = true,

            -- Crowd Control
            showDisoriented = true,
            showFeared = true,
            showOffBalanced = true,
            showSilenced = true,
            showStunned = true,
            showCharmed = true,
        },

        -- Combat State
        showInCombat = true,
        showOutCombat = true,
        showDeath = true,
        useAccountNameForDeath = false,

        -- Points
        showPointsAlliance = false,
        showPointsExperience = false,
        showPointsChampion = false,

        -- Resources
        showLowHealth = false,
        showLowStamina = false,
        showLowMagicka = false,
        showUltimate = true,
        showPotionReady = true,
        warningSound = false,

        -- Colors
        criticalDamageOverride = false,
        criticalHealingOverride = false,
        incomingDamageOverride = false,
    },

    -- Other defaults
    healthThreshold = 35,
    magickaThreshold = 35,
    staminaThreshold = 35,

    -- Font defaults
    fontFace = [[LUIE Default Font]],
    fontStyle = FONT_STYLE_SOFT_SHADOW_THICK,
    fontSizes =
    {
        -- Combat
        damage = 32,
        damagecritical = 32,
        healing = 32,
        healingcritical = 32,
        dot = 26,
        dotcritical = 26,
        hot = 26,
        hotcritical = 26,
        gainLoss = 32,
        mitigation = 32,
        crowdControl = 26,

        -- Combat State, Points & Resources
        combatState = 24,
        death = 32,
        point = 24,
        resource = 32,
        readylabel = 32,
    },

    -- Color defaults
    colors =
    {
        -- Damage & Healing
        damage =
        {
            [DAMAGE_TYPE_NONE] = { 1, 1, 1, 1 },
            [DAMAGE_TYPE_GENERIC] = { 1, 1, 1, 1 },
            [DAMAGE_TYPE_PHYSICAL] = { 200 / 255, 200 / 255, 160 / 255, 1 },
            [DAMAGE_TYPE_FIRE] = { 1, 100 / 255, 20 / 255, 1 },
            [DAMAGE_TYPE_SHOCK] = { 0, 1, 1, 1 },
            [DAMAGE_TYPE_OBLIVION] = { 75 / 255, 0, 150 / 255, 1 },
            [DAMAGE_TYPE_COLD] = { 35 / 255, 70 / 255, 1, 1 },
            [DAMAGE_TYPE_EARTH] = { 100 / 255, 75 / 255, 50 / 255, 1 },
            [DAMAGE_TYPE_MAGIC] = { 1, 1, 0, 1 },
            [DAMAGE_TYPE_DROWN] = { 35 / 255, 70 / 255, 255 / 255, 1 },
            [DAMAGE_TYPE_DISEASE] = { 25 / 255, 85 / 255, 0, 1 },
            [DAMAGE_TYPE_POISON] = { 0, 1, 127 / 255, 1 },
            [DAMAGE_TYPE_BLEED] = { 1, 45 / 255, 45 / 255, 1 },
        },
        healing = { 0, 192 / 255, 0, 1 },
        energizeMagicka = { 0, 192 / 255, 1, 1 },
        energizeStamina = { 192 / 255, 1, 0, 1 },
        energizeUltimate = { 1, 1, 0, 1 },
        drainMagicka = { 0, 192 / 255, 1, 1 },
        drainStamina = { 192 / 255, 1, 0, 1 },
        criticalDamageOverride = { 247 / 255, 244 / 255, 153 / 255, 1 },
        criticalHealingOverride = { 0, 192 / 255, 0, 1 },
        incomingDamageOverride = { 1, 0, 0, 1 },

        -- Mitigation
        miss = { 1, 1, 1, 1 },
        immune = { 1, 0, 0, 1 },
        parried = { 1, 1, 1, 1 },
        reflected = { 1, 160 / 255, 0, 1 },
        damageShield = { 1, 160 / 255, 0, 1 },
        dodged = { 1, 1, 50 / 255, 1 },
        blocked = { 1, 1, 1, 1 },
        interrupted = { 1, 1, 1, 1 },

        -- Crowd Control
        disoriented = { 1, 1, 1, 1 },
        feared = { 1, 1, 1, 1 },
        offBalanced = { 1, 1, 1, 1 },
        silenced = { 1, 1, 1, 1 },
        stunned = { 1, 1, 1, 1 },
        charmed = { 1, 1, 1, 1 },

        -- Combat State
        inCombat = { 1, 1, 1, 1 },
        outCombat = { 1, 1, 1, 1 },
        death = { 1, 0, 0, 1 },

        -- Points
        pointsAlliance = { 0.235294, 0.784314, 0.313725, 1 },   -- RGB(60, 200, 80)
        pointsExperience = { 0.588235, 0.705882, 0.862745, 1 }, -- RGB(150, 180, 220)
        pointsChampion = { 0.784314, 0.784314, 0.627451, 1 },   -- RGB(200, 200, 160)

        -- Resources
        lowHealth = { 0.901961, 0.196078, 0.098039, 1 },   -- RGB(230, 50, 25)
        lowMagicka = { 0.137255, 0.588235, 0.784314, 1 },  -- RGB(35, 150, 200)
        lowStamina = { 0.235294, 0.784314, 0.313725, 1 },  -- RGB(60, 200, 80)
        ultimateReady = { 0.862745, 1, 0.313725, 1 },      -- RGB(220, 255, 80)
        potionReady = { 0.470588, 0.156863, 0.745098, 1 }, -- RGB(120, 40, 190)
    },
    -- Format defaults
    formats =
    {
        -- Damage & Healing
        damage = "%t %a",
        damagecritical = "%t %a!",
        healing = "%t %a",
        healingcritical = "%t %a!",
        energize = "+%a %t",
        ultimateEnergize = "+%a %t",
        drain = "-%a %t",
        dot = "%t %a",
        dotcritical = "%t %a!",
        hot = "%t %a",
        hotcritical = "%t %a!",

        -- Mitigation
        miss = "Missed %t",
        immune = "Immune %t",
        parried = "Parried %t",
        reflected = "Reflected %t",
        damageShield = "(%a) %t",
        dodged = "Dodged %t",
        blocked = "*%t %a",
        interrupted = "Interrupted",

        -- Crowd Control
        disoriented = "Disoriented",
        feared = "Feared",
        offBalanced = "Off-Balance",
        silenced = "Silenced",
        stunned = "Stunned",
        charmed = "Charmed",

        -- Combat State
        inCombat = "Entered Combat",
        outCombat = "Left Combat",
        death = "%t died!",

        -- Points
        pointsAlliance = "%a AP",
        pointsExperience = "%a XP",
        pointsChampion = "%a XP",

        -- Resources
        resourceHealth = "%t! (%a)",
        resourceMagicka = "%t! (%a)",
        resourceStamina = "%t! (%a)",
        ultimateReady = "Ultimate Ready",
        potionReady = "Potion Ready",
    },

    -- Animation defaults
    animation =
    {
        animationType = "ellipse",
        animationDuration = 100,
        outgoingIcon = "left",
        incomingIcon = "right",
        showIconFrame = false,
        colorIconFrame = false,
        outgoing =
        {
            directionType = "down",
            speed = 4000,
        },
        incoming =
        {
            directionType = "down",
            speed = 4000,
        },
    },

    -- Throttle defaults
    throttles =
    {
        damage = 200,
        damagecritical = 200,
        healing = 200,
        healingcritical = 200,
        dot = 200,
        dotcritical = 200,
        hot = 200,
        hotcritical = 200,
    },
}
CombatText.SV = nil
