-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

local GetString = GetString

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = ZO_Object:Subclass()
--- @class (partial) LUIE.SpellCastBuffs
LUIE.SpellCastBuffs = SpellCastBuffs

SpellCastBuffs.moduleName = LUIE.name .. "SpellCastBuffs"

SpellCastBuffs.Enabled = false
SpellCastBuffs.Defaults =
{
    ColorCosmetic = true,
    ColorUnbreakable = true,
    ColorCC = false,
    colors =
    {
        buff = { 0, 1, 0, 1 },
        debuff = { 1, 0, 0, 1 },
        prioritybuff = { 1, 1, 0, 1 },
        prioritydebuff = { 1, 1, 0, 1 },
        unbreakable = { 224 / 255, 224 / 255, 1, 1 },
        cosmetic = { 0, 100 / 255, 0, 1 },
        nocc = { 0, 0, 0, 1 },
        stun = { 1, 0, 0, 1 },
        knockback = { 1, 0, 0, 1 },
        levitate = { 1, 0, 0, 1 },
        disorient = { 0, 127 / 255, 1, 1 },
        fear = { 143 / 255, 9 / 255, 236 / 255, 1 },
        charm = { 64 / 255, 255 / 255, 32 / 255, 1 },
        silence = { 0, 1, 1, 1 },
        stagger = { 1, 127 / 255, 0, 1 },
        snare = { 1, 242 / 255, 32 / 255, 1 },
        root = { 1, 165 / 255, 0, 1 },
    },
    IconSize = 40,
    LabelPosition = 0,
    BuffFontFace = "LUIE Default Font",
    BuffFontStyle = FONT_STYLE_OUTLINE,
    BuffFontSize = 16,
    BuffShowLabel = true,
    AlignmentBuffsPlayer = "Centered",
    SortBuffsPlayer = "Left to Right",
    AlignmentDebuffsPlayer = "Centered",
    SortDebuffsPlayer = "Left to Right",
    AlignmentBuffsTarget = "Centered",
    SortBuffsTarget = "Left to Right",
    AlignmentDebuffsTarget = "Centered",
    SortDebuffsTarget = "Left to Right",
    AlignmentLongHorz = "Centered",
    SortLongHorz = "Left to Right",
    AlignmentLongVert = "Top",
    SortLongVert = "Top to Bottom",
    AlignmentPromBuffsHorz = "Centered",
    SortPromBuffsHorz = "Left to Right",
    AlignmentPromBuffsVert = "Bottom",
    SortPromBuffsVert = "Bottom to Top",
    AlignmentPromDebuffsHorz = "Centered",
    SortPromDebuffsHorz = "Left to Right",
    AlignmentPromDebuffsVert = "Bottom",
    SortPromDebuffsVert = "Bottom to Top",
    StackPlayerBuffs = "Down",
    StackPlayerDebuffs = "Up",
    StackTargetBuffs = "Down",
    StackTargetDebuffs = "Up",
    WidthPlayerBuffs = 1920,
    WidthPlayerDebuffs = 1920,
    WidthTargetBuffs = 1920,
    WidthTargetDebuffs = 1920,
    GlowIcons = false,
    RemainingText = true,
    RemainingTextColoured = false,
    RemainingTextMillis = true,
    RemainingCooldown = true,
    FadeOutIcons = false,
    lockPositionToUnitFrames = true,
    LongTermEffects_Player = true,
    LongTermEffects_Target = true,
    ShortTermEffects_Player = true,
    ShortTermEffects_Target = true,
    IgnoreMundusPlayer = false,
    IgnoreMundusTarget = false,
    IgnoreVampPlayer = false,
    IgnoreVampTarget = false,
    IgnoreLycanPlayer = false,
    IgnoreLycanTarget = false,
    IgnoreDiseasePlayer = false,
    IgnoreDiseaseTarget = false,
    IgnoreBitePlayer = false,
    IgnoreBiteTarget = false,
    IgnoreCyrodiilPlayer = false,
    IgnoreCyrodiilTarget = false,
    IgnoreBattleSpiritPlayer = false,
    IgnoreBattleSpiritTarget = false,
    IgnoreEsoPlusPlayer = true,
    IgnoreEsoPlusTarget = true,
    IgnoreSoulSummonsPlayer = false,
    IgnoreSoulSummonsTarget = false,
    IgnoreSetICDPlayer = false,
    IgnoreAbilityICDPlayer = false,
    IgnoreFoodPlayer = false,
    IgnoreFoodTarget = false,
    IgnoreExperiencePlayer = false,
    IgnoreExperienceTarget = false,
    IgnoreAllianceXPPlayer = false,
    IgnoreAllianceXPTarget = false,
    IgnoreDisguise = false,
    IgnoreCostume = true,
    IgnoreHat = true,
    IgnoreSkin = true,
    IgnorePolymorph = true,
    IgnoreAssistant = true,
    IgnorePet = true,
    PetDetail = true,
    IgnoreMountPlayer = false,
    IgnoreMountTarget = false,
    MountDetail = true,
    LongTermEffectsSeparate = true,
    LongTermEffectsSeparateAlignment = 2,
    ShowBlockPlayer = true,
    ShowBlockTarget = true,
    StealthStatePlayer = true,
    StealthStateTarget = true,
    DisguiseStatePlayer = true,
    DisguiseStateTarget = true,
    -- ShowSprint                          = true,
    -- ShowGallop                          = true,
    ShowResurrectionImmunity = true,
    ShowRecall = true,
    ShowWerewolf = true,
    HideOakenSoul = false,
    HidePlayerBuffs = false,
    HidePlayerDebuffs = false,
    HideTargetBuffs = false,
    HideTargetDebuffs = false,
    HideGroundEffects = false,
    ExtraBuffs = true,
    ExtraExpanded = false,
    ShowDebugCombat = false,
    ShowDebugEffect = false,
    ShowDebugFilter = false,
    ShowDebugAbilityId = false,
    HideReduce = true,
    GroundDamageAura = true,
    ProminentLabel = true,
    ProminentLabelFontFace = "LUIE Default Font",
    ProminentLabelFontStyle = FONT_STYLE_OUTLINE,
    ProminentLabelFontSize = 16,
    ProminentProgress = true,
    ProminentProgressTexture = "Plain",
    ProminentProgressBuffC1 = { 0, 1, 0, 1 },
    ProminentProgressBuffC2 = { 0, 0.4, 0, 1 },
    ProminentProgressDebuffC1 = { 1, 0, 0, 1 },
    ProminentProgressDebuffC2 = { 0.4, 0, 0, 1 },
    ProminentProgressBuffPriorityC1 = { 1, 1, 0, 1 },
    ProminentProgressBuffPriorityC2 = { 0.6, 0.6, 0, 1 },
    ProminentProgressDebuffPriorityC1 = { 1, 1, 0, 1 },
    ProminentProgressDebuffPriorityC2 = { 0.6, 0.6, 0, 1 },
    ProminentBuffContainerAlignment = 2,
    ProminentDebuffContainerAlignment = 2,
    ProminentBuffLabelDirection = "Left",
    ProminentDebuffLabelDirection = "Right",
    PriorityBuffTable = {},
    PriorityDebuffTable = {},
    PromBuffTable = {},
    PromDebuffTable = {},
    BlacklistTable = {},
    WhitelistTable = {},
    ListMode = "blacklist", -- or "whitelist"
    TooltipEnable = true,
    TooltipCustom = false,
    TooltipSticky = 0,
    TooltipAbilityId = false,
    TooltipBuffType = false,
    UseDefaultIcon = false,
    DefaultIconOptions = 1,
    ShowSharedEffects = true,
    ShowSharedMajorMinor = true,
}
SpellCastBuffs.SV = {}

--- @alias SpellCastBuffsContext string
--- | `"player1"`
--- | `"player2"`
--- | `"reticleover1"`
--- | `"reticleover2"`
--- | `"ground"`
--- | `"saved"`
--- | `"promd_player"`
--- | `"promb_player"`
--- | `"promd_target"`
--- | `"promb_target"`
--- | `"target1"`
--- | `"target2"`
--- | `"targetb"`
--- | `"targetd"`

-- Saved Effects
SpellCastBuffs.EffectsList =
{
    player1 = {},
    player2 = {},
    reticleover1 = {},
    reticleover2 = {},
    ground = {},
    saved = {},
    promb_ground = {},
    promb_target = {},
    promb_player = {},
    promd_ground = {},
    promd_target = {},
    promd_player = {}
}


SpellCastBuffs.hidePlayerEffects = {}       -- Table of Effects to hide on Player - generated on load or updated from Menu
SpellCastBuffs.hideTargetEffects = {}       -- Table of Effects to hide on Target - generated on load or updated from Menu
SpellCastBuffs.debuffDisplayOverrideId = {} -- Table of Effects (by id) that should show on the target regardless of who applied them.

SpellCastBuffs.windowTitles =
{
    playerb = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS),
    playerd = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS),
    player1 = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERBUFFS),
    player2 = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERDEBUFFS),
    player_long = GetString(LUIE_STRING_SCB_WINDOWTITLE_PLAYERLONGTERMEFFECTS),
    targetb = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS),
    targetd = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS),
    target1 = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETBUFFS),
    target2 = GetString(LUIE_STRING_SCB_WINDOWTITLE_TARGETDEBUFFS),
    prominentbuffs = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTBUFFS),
    prominentdebuffs = GetString(LUIE_STRING_SCB_WINDOWTITLE_PROMINENTDEBUFFS),
}

local uiTlw = {} -- GUI

-- Routing for Auras
SpellCastBuffs.containerRouting = {}

SpellCastBuffs.alignmentDirection = {}    -- Holds alignment direction for all containers
SpellCastBuffs.sortDirection = {}         -- Holds sorting direction for all containers

SpellCastBuffs.playerActive = false       -- Player Active State
SpellCastBuffs.playerDead = false         -- Player Dead State
SpellCastBuffs.playerResurrectStage = nil -- Player resurrection sequence state

SpellCastBuffs.buffsFont = ""             -- Buff font
SpellCastBuffs.prominentFont = ""         -- Prominent buffs label font
SpellCastBuffs.padding = 0                -- Padding between icons
SpellCastBuffs.protectAbilityRemoval = {} -- AbilityId's set to a timestamp here to prevent removal of ground effects when refreshing ground auras from causing the aura to fade.
SpellCastBuffs.ignoreAbilityId = {}       -- Ignored abilityId's on EVENT_COMBAT_EVENT, some events fire twice and we need to ignore every other one.

-- Add buff containers into LUIE namespace
SpellCastBuffs.BuffContainers = uiTlw

-- Stealth Varaiables
-- Handles long term Disguise Item Icon (appears when wearing a disguise even if not in a disguised state)
SpellCastBuffs.currentDisguise = 0

-- Werewolf Varaiables
SpellCastBuffs.werewolfName = ""   -- Name for current Werewolf Transformation morph
SpellCastBuffs.werewolfIcon = ""   -- Icon for current Werewolf Transformation morph
SpellCastBuffs.werewolfId = 0      -- AbilityId for Werewolf Transformation morph
SpellCastBuffs.werewolfCounter = 0 -- Counter for Werewolf transformation events
SpellCastBuffs.werewolfQuest = 0   -- Counter for Werewolf transformation events (Quest)

-- Counter variable for ACTION_RESULT_EFFECT_GAINED / ACTION_RESULT_EFFECT_FADED tracking for some buffs that are broken
-- Handles buffs that rather than refreshing on reapplication create an individual instance and therefore have GAINED/FADED events every single time the effect ticks.
SpellCastBuffs.InternalStackCounter = {}
