-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

local GetString = GetString

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) SpellCastBuffs : ZO_Object
--- @field moduleName string
--- @field Enabled boolean
--- @field SV SCBDefaults
--- @field EffectsList table<SpellCastBuffsContext, table>
--- @field hidePlayerEffects table
--- @field hideTargetEffects table
--- @field debuffDisplayOverrideId table
--- @field offBalanceDebuffById table<integer, true>
--- @field windowTitles table<string, string>
--- @field containerRouting table<string, string>
--- @field alignmentDirection table<string, string>
--- @field sortDirection table<string, string>
--- @field playerActive boolean
--- @field playerDead boolean
--- @field playerResurrectStage number?
--- @field buffsFont string
--- @field abilityIdFonts string[]
--- @field prominentFont string
--- @field padding number
--- @field protectAbilityRemoval table
--- @field ignoreAbilityId table
--- @field BuffContainers table<string, any>
--- @field currentDisguise number
--- @field werewolfName string
--- @field werewolfIcon string
--- @field werewolfId number
--- @field werewolfCounter number
--- @field werewolfQuest number
--- @field InternalStackCounter table
--- @field CombatCcByAbilityId table<integer, { ccType: integer, expires: number, targetUnitTag?: string }>
--- @field CombatCcByTargetAbilityId table<string, integer>
--- @field combatDamageTypeByAbilityId table<integer, { damageType: integer, expires: number }>
local SpellCastBuffs = ZO_Object:Subclass()

------------------------------------------------
-- DEFAULT VARIABLE TYPES (SV / Defaults) ------
------------------------------------------------

--- RGBA color tuple (0-1). Used for buff/debuff/CC colors.
--- @alias SCB_Color number[]

--- Nested color table for buff, debuff, priority, CC, etc.
--- @class SCBColors
--- @field buff SCB_Color
--- @field debuff SCB_Color
--- @field prioritybuff SCB_Color
--- @field prioritydebuff SCB_Color
--- @field unbreakable SCB_Color
--- @field cosmetic SCB_Color
--- @field nocc SCB_Color
--- @field stun SCB_Color
--- @field knockback SCB_Color
--- @field levitate SCB_Color
--- @field disorient SCB_Color
--- @field fear SCB_Color
--- @field charm SCB_Color
--- @field silence SCB_Color
--- @field stagger SCB_Color
--- @field snare SCB_Color
--- @field root SCB_Color
--- @field damage table<integer, SCB_Color> Damage-type colors keyed by DAMAGE_TYPE_* (SpellCastBuffs-owned palette)

--- Root default settings for SpellCastBuffs (SV and Defaults share this shape).
--- @class SCBDefaults
--- @field ColorCosmetic boolean
--- @field ColorUnbreakable boolean
--- @field ColorCC boolean
--- @field DamageTypeFallback boolean
--- @field colors SCBColors
--- @field IconSize number
--- @field LabelPosition number
--- @field BuffFontFace string
--- @field BuffFontStyle FontStyle
--- @field BuffFontSize number
--- @field BuffShowLabel boolean
--- @field AlignmentBuffsPlayer string
--- @field SortBuffsPlayer string
--- @field AlignmentDebuffsPlayer string
--- @field SortDebuffsPlayer string
--- @field AlignmentBuffsTarget string
--- @field SortBuffsTarget string
--- @field AlignmentDebuffsTarget string
--- @field SortDebuffsTarget string
--- @field AlignmentLongHorz string
--- @field SortLongHorz string
--- @field AlignmentLongVert string
--- @field SortLongVert string
--- @field AlignmentPromBuffsHorz string
--- @field SortPromBuffsHorz string
--- @field AlignmentPromBuffsVert string
--- @field SortPromBuffsVert string
--- @field AlignmentPromDebuffsHorz string
--- @field SortPromDebuffsHorz string
--- @field AlignmentPromDebuffsVert string
--- @field SortPromDebuffsVert string
--- @field StackPlayerBuffs string
--- @field StackPlayerDebuffs string
--- @field StackTargetBuffs string
--- @field StackTargetDebuffs string
--- @field WidthPlayerBuffs number
--- @field WidthPlayerDebuffs number
--- @field WidthTargetBuffs number
--- @field WidthTargetDebuffs number
--- @field GlowIcons boolean
--- @field RemainingText boolean
--- @field RemainingTextColoured boolean
--- @field RemainingTextMillis boolean
--- @field RemainingCooldown boolean
--- @field FadeOutIcons boolean
--- @field lockPositionToUnitFrames boolean
--- @field LongTermEffects_Player boolean
--- @field LongTermEffects_Target boolean
--- @field ShortTermEffects_Player boolean
--- @field ShortTermEffects_Target boolean
--- @field IgnoreMundusPlayer boolean
--- @field IgnoreMundusTarget boolean
--- @field IgnoreVampPlayer boolean
--- @field IgnoreVampTarget boolean
--- @field IgnoreLycanPlayer boolean
--- @field IgnoreLycanTarget boolean
--- @field IgnoreDiseasePlayer boolean
--- @field IgnoreDiseaseTarget boolean
--- @field IgnoreBitePlayer boolean
--- @field IgnoreBiteTarget boolean
--- @field IgnoreCyrodiilPlayer boolean
--- @field IgnoreCyrodiilTarget boolean
--- @field IgnoreBattleSpiritPlayer boolean
--- @field IgnoreBattleSpiritTarget boolean
--- @field IgnoreEsoPlusPlayer boolean
--- @field IgnoreEsoPlusTarget boolean
--- @field IgnoreSoulSummonsPlayer boolean
--- @field IgnoreSoulSummonsTarget boolean
--- @field IgnoreSetICDPlayer boolean
--- @field IgnoreAbilityICDPlayer boolean
--- @field IgnoreFoodPlayer boolean
--- @field IgnoreFoodTarget boolean
--- @field IgnoreExperiencePlayer boolean
--- @field IgnoreExperienceTarget boolean
--- @field IgnoreAllianceXPPlayer boolean
--- @field IgnoreAllianceXPTarget boolean
--- @field IgnoreDisguise boolean
--- @field IgnoreCostume boolean
--- @field IgnoreHat boolean
--- @field IgnoreSkin boolean
--- @field IgnorePolymorph boolean
--- @field IgnoreAssistant boolean
--- @field IgnorePet boolean
--- @field PetDetail boolean
--- @field IgnoreMountPlayer boolean
--- @field IgnoreMountTarget boolean
--- @field MountDetail boolean
--- @field LongTermEffectsSeparate boolean
--- @field LongTermEffectsSeparateAlignment number
--- @field ShowBlockPlayer boolean
--- @field ShowBlockTarget boolean
--- @field StealthStatePlayer boolean
--- @field StealthStateTarget boolean
--- @field DisguiseStatePlayer boolean
--- @field DisguiseStateTarget boolean
--- @field ShowResurrectionImmunity boolean
--- @field ShowRecall boolean
--- @field ShowWerewolf boolean
--- @field HideOakenSoul boolean
--- @field HidePlayerBuffs boolean
--- @field HidePlayerDebuffs boolean
--- @field HideTargetBuffs boolean
--- @field HideTargetDebuffs boolean
--- @field HideGroundEffects boolean
--- @field ExtraBuffs boolean
--- @field ExtraExpanded boolean
--- @field ShowDebugCombat boolean
--- @field ShowDebugEffect boolean
--- @field ShowDebugFilter boolean
--- @field ShowDebugAbilityId boolean
--- @field HideReduce boolean
--- @field GroundDamageAura boolean
--- @field ProminentLabel boolean
--- @field ProminentLabelFontFace string
--- @field ProminentLabelFontStyle FontStyle
--- @field ProminentLabelFontSize number
--- @field ProminentProgress boolean
--- @field ProminentProgressTexture string
--- @field ProminentProgressBuffC1 SCB_Color
--- @field ProminentProgressBuffC2 SCB_Color
--- @field ProminentProgressDebuffC1 SCB_Color
--- @field ProminentProgressDebuffC2 SCB_Color
--- @field ProminentProgressBuffPriorityC1 SCB_Color
--- @field ProminentProgressBuffPriorityC2 SCB_Color
--- @field ProminentProgressDebuffPriorityC1 SCB_Color
--- @field ProminentProgressDebuffPriorityC2 SCB_Color
--- @field ProminentBuffContainerAlignment number
--- @field ProminentDebuffContainerAlignment number
--- @field ProminentBuffLabelDirection string
--- @field ProminentDebuffLabelDirection string
--- @field PriorityBuffTable table
--- @field PriorityDebuffTable table
--- @field PromBuffTable table
--- @field PromDebuffTable table
--- @field BlacklistTable table
--- @field WhitelistTable table
--- @field ListMode string
--- @field TooltipEnable boolean
--- @field TooltipCustom boolean
--- @field TooltipSticky number
--- @field TooltipAbilityId boolean
--- @field TooltipBuffType boolean
--- @field TooltipDebugMeta boolean
--- @field UseDefaultIcon boolean
--- @field DefaultIconOptions number
--- @field ShowSharedEffects boolean
--- @field ShowSharedMajorMinor boolean
--- @field playerbOffsetX number|nil
--- @field playerbOffsetY number|nil
--- @field playerdOffsetX number|nil
--- @field playerdOffsetY number|nil
--- @field targetbOffsetX number|nil
--- @field targetbOffsetY number|nil
--- @field targetdOffsetX number|nil
--- @field targetdOffsetY number|nil
--- @field playerVOffsetX number|nil
--- @field playerVOffsetY number|nil
--- @field playerHOffsetX number|nil
--- @field playerHOffsetY number|nil
--- @field prominentbVOffsetX number|nil
--- @field prominentbVOffsetY number|nil
--- @field prominentbHOffsetX number|nil
--- @field prominentbHOffsetY number|nil
--- @field prominentdVOffsetX number|nil
--- @field prominentdVOffsetY number|nil
--- @field prominentdHOffsetX number|nil
--- @field prominentdHOffsetY number|nil
--- @field oocAlpha number
--- @field incAlpha number

SpellCastBuffs.moduleName = LUIE.name .. "SpellCastBuffs"

SpellCastBuffs.Enabled = false
SpellCastBuffs.devDebugEnabled = false
--- @type SCBDefaults
SpellCastBuffs.Defaults =
{
    ColorCosmetic = true,
    ColorUnbreakable = true,
    ColorCC = false,
    DamageTypeFallback = false,
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
        -- DamageType fallback palette (cooldown fill only; NONE/GENERIC are treated as no override)
        damage =
        {
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
    TooltipDebugMeta = false,
    UseDefaultIcon = false,
    DefaultIconOptions = 1,
    ShowSharedEffects = true,
    ShowSharedMajorMinor = true,
    oocAlpha = 100,
    incAlpha = 100,
    playerbOffsetX = nil,
    playerbOffsetY = nil,
    playerdOffsetX = nil,
    playerdOffsetY = nil,
    targetbOffsetX = nil,
    targetbOffsetY = nil,
    targetdOffsetX = nil,
    targetdOffsetY = nil,
    playerVOffsetX = nil,
    playerVOffsetY = nil,
    playerHOffsetX = nil,
    playerHOffsetY = nil,
    prominentbVOffsetX = nil,
    prominentbVOffsetY = nil,
    prominentbHOffsetX = nil,
    prominentbHOffsetY = nil,
    prominentdVOffsetX = nil,
    prominentdVOffsetY = nil,
    prominentdHOffsetX = nil,
    prominentdHOffsetY = nil,
}
--- @type SCBDefaults
SpellCastBuffs.SV = ...

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
--- @type table<SpellCastBuffsContext, table>
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

--- Short-lived cache for damageType derived from EVENT_COMBAT_EVENT, keyed by abilityId.
--- Used as a fallback to color debuff cooldown fill when debuff has no CC classification.
--- @type table<integer, { damageType: integer, expires: number }>
SpellCastBuffs.combatDamageTypeByAbilityId = {}


SpellCastBuffs.hidePlayerEffects = {}       --- @type table Table of Effects to hide on Player - generated on load or updated from Menu
SpellCastBuffs.hideTargetEffects = {}       --- @type table Table of Effects to hide on Target - generated on load or updated from Menu
SpellCastBuffs.debuffDisplayOverrideId = {} --- @type table Table of Effects (by id) that should show on the target regardless of who applied them.
SpellCastBuffs.offBalanceDebuffById = {}    --- @type table<integer, true> Effect ids that LuiData identifies as the shared Off Balance debuff; populated on init.

--- @type table<string, string>
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

--- @generic K, V
--- Buff icon control (single aura icon); extends virtual template with runtime refs and effect data.
--- @class SpellCastBuffs_BuffIcon_Control : LUIE_SpellCastBuffIcon
--- @field back TextureControl
--- @field frame TextureControl
--- @field iconbg TextureControl
--- @field drop TextureControl
--- @field icon TextureControl
--- @field label LabelControl
--- @field abilityId LabelControl
--- @field stack LabelControl
--- @field cd CooldownControl
--- @field name LabelControl
--- @field bar { backdrop: BackdropControl, bar: StatusBarControl }
--- @field effectId number?
--- @field effectName string?
--- @field buffSlot number?
--- @field [any] any

--- Container control or table: TopLevel/Control with optional iconHolder, icons, preview, alignVertical, etc.
--- Used for both SpellCastBuffs-created containers and UnitFrames-provided controls (player1, player2, target1, target2).
--- @class SpellCastBuffs_EffectsList_Control : Control
--- @field icons table<number, SpellCastBuffs_BuffIcon_Control>?
--- @field iconHolder Control?
--- @field preview Control?
--- @field alignVertical boolean?
--- @field previewLabel Control?
--- @field skipUpdate number?
--- @field [any] any

--- BuffContainers value: our container Control, UnitFrames Control, or table. Accepts any so assignment from
--- LUIE.UnitFrames.CustomFrames.player.buffs (Control) and field access (.iconHolder, .preview, etc.) both type-check.
--- @type table<string, any>
local uiTlw = {} -- GUI

-- Routing for Auras
--- @type table<string, string>
SpellCastBuffs.containerRouting = {}

SpellCastBuffs.alignmentDirection = {}         --- @type table<string, string> Holds alignment direction for all containers
SpellCastBuffs.sortDirection = {}              --- @type table<string, string> Holds sorting direction for all containers

SpellCastBuffs.playerActive = false            -- Player Active State
SpellCastBuffs.playerDead = false              -- Player Dead State
SpellCastBuffs.playerResurrectStage = nil      -- Player resurrection sequence state
SpellCastBuffs.blockPlayerEffectActive = false -- Show Block Player synthetic brace icon is in EffectsList / display cache

SpellCastBuffs.buffsFont = ""                  -- Buff font
SpellCastBuffs.prominentFont = ""              -- Prominent buffs label font
SpellCastBuffs.padding = 0                     -- Padding between icons
SpellCastBuffs.protectAbilityRemoval = {}      -- AbilityId's set to a timestamp here to prevent removal of ground effects when refreshing ground auras from causing the aura to fade.
SpellCastBuffs.ignoreAbilityId = {}            -- Ignored abilityId's on EVENT_COMBAT_EVENT, some events fire twice and we need to ignore every other one.

-- Add buff containers into LUIE namespace
SpellCastBuffs.BuffContainers = uiTlw

-- Stealth Variables
SpellCastBuffs.currentDisguise = 0

-- Werewolf Variables
SpellCastBuffs.werewolfName = ""   --- @type string
SpellCastBuffs.werewolfIcon = ""   --- @type string
SpellCastBuffs.werewolfId = 0      --- @type number
SpellCastBuffs.werewolfCounter = 0 --- @type number
SpellCastBuffs.werewolfQuest = 0   --- @type number

-- Counter variable for ACTION_RESULT_EFFECT_GAINED / ACTION_RESULT_EFFECT_FADED tracking for some buffs that are broken
--- @type table
SpellCastBuffs.InternalStackCounter = {}

--- @class (partial) LUIE.SpellCastBuffs : SpellCastBuffs
LUIE.SpellCastBuffs = SpellCastBuffs:New()
