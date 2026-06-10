-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local ACTION_RESULT_AREA_EFFECT = 669966

-- CombatInfo namespace
--- @class (partial) LUIE.CombatInfo
local CombatInfo = {}
CombatInfo.__index = CombatInfo
LUIE.CombatInfo = CombatInfo

--- @class (partial) CrowdControlTracker
CombatInfo.CrowdControlTracker =
{
    name = LUIE.name .. "CombatInfo" .. "CrowdControlTracker",
}

--- @class (partial) Block
CombatInfo.Block =
{
    name = LUIE.name .. "CombatInfo" .. "Block",
}

-- Module state
CombatInfo.Enabled = false
CombatInfo.SV = {}
CombatInfo.AlertFrameUnlocked = false

-- Module defaults
CombatInfo.Defaults =
{
    showMarker = false,
    markerSize = 26,
    alerts =
    {
        toggles =
        {
            alertEnable = true,
            alertFontFace = "LUIE Default Font",
            alertFontStyle = FONT_STYLE_SOFT_SHADOW_THICK,
            alertFontSize = 32,
            alertTimer = true,
            showMitigation = true,
            mitigationAbilityName = "%t",
            mitigationEnemyName = "%n -",
            modifierEnable = true,
            mitigationModifierOnYou = GetString(LUIE_STRING_CI_MITIGATION_MODIFIER_ON_YOU),
            mitigationModifierSpreadOut = GetString(LUIE_STRING_CI_MITIGATION_MODIFIER_SPREAD_OUT),
            showCrowdControlBorder = true,
            ccLabelColor = false,
            useDefaultIcon = false,
            mitigationPowerPrefix2 = "%t",
            mitigationPowerPrefixN2 = GetString(LUIE_STRING_CI_MITIGATION_FORMAT_POWER_N),
            mitigationDestroyPrefix2 = "%t",
            mitigationDestroyPrefixN2 = "%t",
            mitigationSummonPrefix2 = "%t",
            mitigationSummonPrefixN2 = "%t",
            mitigationAura = false,
            mitigationRank3 = true,
            mitigationRank2 = true,
            mitigationRank1 = true,
            mitigationDungeon = true,
            showAlertMitigate = true,
            showAlertUnmit = true,
            showAlertPower = true,
            showAlertDestroy = true,
            showAlertSummon = true,
            alertOptions = 1,

            soundVolume = 2,
            sound_stEnable = false,
            sound_st_ccEnable = true,
            sound_aoeEnable = false,
            sound_aoe_ccEnable = true,
            sound_powerattackEnable = true,
            sound_radialEnable = true,
            sound_travelEnable = false,
            sound_travel_ccEnable = true,
            sound_groundEnable = false,
            sound_meteorEnable = true,
            sound_unmit_stEnable = true,
            sound_unmit_aoeEnable = true,
            sound_power_damageEnable = true,
            sound_power_buffEnable = true,
            sound_summonEnable = false,
            sound_destroyEnable = true,
            sound_healEnable = false,
        },
        colors =
        {
            alertShared = { 1, 1, 1, 1 },
            alertTimer = { 1, 1, 1, 1 },
            alertBlockA = { 1, 0, 0, 1 },
            alertInterruptC = { 0, 127 / 255, 1, 1 },
            alertUnmit = { 1, 0, 0, 1 },
            alertDodgeA = { 1, 1, 50 / 255, 1 },
            alertAvoidB = { 1, 127 / 255, 0, 1 },
            alertPower = { 1, 1, 1, 1 },
            alertDestroy = { 1, 1, 1, 1 },
            alertSummon = { 1, 1, 1, 1 },
            stunColor = { 1, 0, 0, 1 },
            knockbackColor = { 1, 0, 0, 1 },
            levitateColor = { 1, 0, 0, 1 },
            disorientColor = { 0, 127 / 255, 1, 1 },
            fearColor = { 143 / 255, 9 / 255, 236 / 255, 1 },
            charmColor = { 64 / 255, 255 / 255, 32 / 255, 1 },
            silenceColor = { 0, 1, 1, 1 },
            staggerColor = { 1, 127 / 255, 0, 1 },
            unbreakableColor = { 224 / 255, 224 / 255, 1, 1 },
            snareColor = { 1, 242 / 255, 32 / 255, 1 },
            rootColor = { 1, 165 / 255, 0, 1 },
        },
        formats =
        {
            alertBlock = GetString(LUIE_STRING_CI_BLOCK_DEFAULT),
            alertBlockStagger = GetString(LUIE_STRING_CI_BLOCKSTAGGER_DEFAULT),
            alertInterrupt = GetString(LUIE_STRING_CI_INTERRUPT_DEFAULT),
            alertShouldUseCC = GetString(LUIE_STRING_CI_SHOULDUSECC_DEFAULT),
            alertUnmit = GetString(LUIE_STRING_CI_UNMIT_DEFAULT),
            alertDodge = GetString(LUIE_STRING_CI_DODGE_DEFAULT),
            alertAvoid = GetString(LUIE_STRING_CI_AVOID_DEFAULT),
            alertPower = GetString(LUIE_STRING_CI_POWER_DEFAULT),
            alertDestroy = GetString(LUIE_STRING_CI_DESTROY_DEFAULT),
            alertSummon = GetString(LUIE_STRING_CI_SUMMON_DEFAULT),
        },
        sounds =
        {
            sound_st = "Champion Respec Accept",
            sound_st_cc = "Champion Points Committed",
            sound_aoe = "Champion Respec Accept",
            sound_aoe_cc = "Champion Points Committed",
            sound_powerattack = "Trial - Scored Added Normal",
            sound_radial = "Duel Accepted",
            sound_travel = "Champion Respec Accept",
            sound_travel_cc = "Console Game Enter",
            sound_ground = "Champion Respec Accept",
            sound_meteor = "LFG Find Replacement",
            sound_unmit_st = "Duel Start",
            sound_unmit_aoe = "Duel Start",
            sound_power_damage = "Book Collection Completed",
            sound_power_buff = "Book Collection Completed",
            sound_summon = "Duel Invite Received",
            sound_destroy = "Duel Invite Received",
            sound_heal = "Console Game Enter",
        },
    },
    cct =
    {
        enabled = false,
        enabledOnlyInCyro = false,
        unlock = false,
        controlScale = 1.0,
        useDefaultIcon = false,
        defaultIconOptions = 1,
        playAnimation = true,
        playSound = true,
        playSoundOption = "Death Recap Killing Blow",
        useAbilityName = true,
        showStaggered = true,
        showImmune = true,
        showAoe = true,
        aoePlayerUltimate = true,
        aoePlayerNormal = true,
        aoePlayerSet = true,
        aoeTraps = true,
        aoeNPCBoss = true,
        aoeNPCElite = true,
        aoeNPCNormal = true,
        showRoot = false,
        showSnare = false,

        aoePlayerUltimateSoundToggle = true,
        aoePlayerNormalSoundToggle = true,
        aoePlayerSetSoundToggle = true,
        aoeTrapsSoundToggle = true,
        aoeNPCBossSoundToggle = true,
        aoeNPCEliteSoundToggle = true,
        aoeNPCNormalSoundToggle = true,

        aoePlayerUltimateSound = "Death Recap Killing Blow",
        aoePlayerNormalSound = "Death Recap Killing Blow",
        aoePlayerSetSound = "Death Recap Killing Blow",
        aoeTrapsSound = "Death Recap Killing Blow",
        aoeNPCBossSound = "Death Recap Killing Blow",
        aoeNPCEliteSound = "Death Recap Killing Blow",
        aoeNPCNormalSound = "Death Recap Killing Blow",

        showGCD = false,
        showImmuneOnlyInCyro = true,
        immuneDisplayTime = 750,
        showOptions = "all",
        offsetX = 0,
        offsetY = 0,
        colors =
        {
            [ACTION_RESULT_AREA_EFFECT] = { 1, 242 / 255, 32 / 255, 1 },
            [ACTION_RESULT_BLOCKED_DAMAGE] = { 1, 1, 1, 1 },
            [ACTION_RESULT_BLOCKED] = { 1, 1, 1, 1 },
            [ACTION_RESULT_CHARMED] = { 64 / 255, 255 / 255, 32 / 255, 1 },
            [ACTION_RESULT_DISORIENTED] = { 0, 127 / 255, 1, 1 },
            [ACTION_RESULT_DODGED] = { 1, 1, 1, 1 },
            [ACTION_RESULT_EFFECT_GAINED_DURATION] = { 0.5, 0.5, 0.5, 1 },
            [ACTION_RESULT_FEARED] = { 143 / 255, 9 / 255, 236 / 255, 1 },
            [ACTION_RESULT_IMMUNE] = { 1, 1, 1, 1 },
            [ACTION_RESULT_KNOCKBACK] = { 1, 0, 0, 1 },
            [ACTION_RESULT_LEVITATED] = { 1, 0, 0, 1 },
            [ACTION_RESULT_ROOTED] = { 1, 150 / 255, 32 / 255, 1 },
            [ACTION_RESULT_SILENCED] = { 0, 1, 1, 1 },
            [ACTION_RESULT_SNARED] = { 1, 242 / 255, 32 / 255, 1 },
            [ACTION_RESULT_STAGGERED] = { 1, 127 / 255, 0, 1 },
            [ACTION_RESULT_STUNNED] = { 1, 0, 0, 1 },
            unbreakable = { 224 / 255, 224 / 255, 1, 1 },
        },
        RemainingTextColoured = { 1, 1, 1, 1 }
    },
    block =
    {
        enabled = false,
        updateIntervalMs = 10,
        showRemainingBlocks = false,
        colorShieldByResource = false,
        blockIndicatorFontFace = "LUIE Default Font",
        blockIndicatorFontStyle = FONT_STYLE_SOFT_SHADOW_THICK,
        blockIndicatorFontSize = 18,
        bloodlordEmbracePosition = { left = 1165, top = 275 },
        bloodlordEmbraceFontFace = "LUIE Default Font",
        bloodlordEmbraceFontStyle = FONT_STYLE_SOFT_SHADOW_THICK,
        bloodlordEmbraceTitleSize = 12,
        bloodlordEmbraceValueSize = 14,
    },
}
