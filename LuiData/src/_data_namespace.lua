-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class CrowdControl
--- @field aoeNPCBoss table
--- @field aoeNPCElite table
--- @field aoeNPCNormal table
--- @field aoePlayerNormal table
--- @field aoePlayerSet table
--- @field aoePlayerUltimate table
--- @field aoeTraps table
--- @field IgnoreList table
--- @field LavaAlerts table
--- @field ReversedLogic table
--- @field SpecialCC table



--- @class (partial) Data
--- @field IconFrameColorSamples table<string, number[]>
--- @field Abilities AbilityTables
--- @field AbilityBlacklistPresets BlacklistPresets
--- @field AlertBossNameConvert AlertBossNameConvert
--- @field AlertMapOverride AlertMapOverride
--- @field AlertTable AlertTable
--- @field AlertZoneOverride AlertZoneOverride
--- @field CastBarTable CastBarTable
--- @field CollectibleTables CollectibleTables
--- @field CombatTextBlacklistPresets CombatTextBlacklistPresets
--- @field CombatTextConstants CombatTextConstants
--- @field CrowdControl CrowdControl
--- @field DebugResults DebugResults
--- @field DebugAuras DebugAuras
--- @field DebugStatus DebugStatus
--- @field Effects Effects
--- @field PetNames PetNames
--- @field Quests Quests
--- @field Tooltips Tooltips
--- @field UnitNames UnitNames
--- @field ZoneNames ZoneNames
--- @field ZoneTable ZoneTable

-- Define all the tables individually first
local Abilities = {}

local IconFrameColorSamples = {}

local AbilityBlacklistPresets =
{
    MajorBuffs = {},
    MajorDebuffs = {},
    MinorBuffs = {},
    MinorDebuffs = {},
}

local AlertBossNameConvert = {}
local AlertMapOverride = {}
local AlertTable = {}
local AlertZoneOverride = {}
local CastBarTable = {}
local CollectibleTables = {}

local CombatTextBlacklistPresets =
{
    Arcanist = {},
    Dragonknight = {},
    Necromancer = {},
    Nightblade = {},
    Sets = {},
    Sorcerer = {},
    Templar = {},
    Warden = {},
}

local CombatTextConstants = {}

local CrowdControl =
{
    IgnoreList = {},
    LavaAlerts = {},
    ReversedLogic = {},
    SpecialCC = {},
    aoeNPCBoss = {},
    aoeNPCElite = {},
    aoeNPCNormal = {},
    aoePlayerNormal = {},
    aoePlayerSet = {},
    aoePlayerUltimate = {},
    aoeTraps = {},
}

local DebugResults = {}
local DebugAuras = {}
local DebugStatus = {}

--- @class (partial) Effects
--- @field AddNameAura AddNameAura
--- @field AddGroundDamageAura AddGroundDamageAura Table of fake ground damage aura definitions
--- @field AddNameOnBossEngaged AddNameOnBossEngaged Table of effects that add names when boss is engaged
--- @field AddNameOnEvent AddNameOnEvent Table of effects that add names on specific events
--- @field AddNoDurationBarHighlight table<integer, boolean> Table of effects that should highlight without duration
--- @field BarHighlightHideDurationLabel table<integer, boolean> Track ids: bar stack highlight without countdown label
--- @field AddStackOnEvent AddStackOnEvent Table of effects that add stacks on specific events
--- @field ArtificialEffectOverride ArtificialEffectOverride Table of artificial effect overrides
--- @field AssistantIcons AssistantIcons Table of assistant icon definitions
--- @field BarHighlightCheckOnFade table<integer, BarHighlightOverrideEntry> Table of effects to check highlight on fade
--- @field BarHighlightCruxMap BarHighlightCruxMap Table mapping Crux effect to abilities that show Crux stacks
--- @field BarHighlightDestroFix BarHighlightDestroFix Table of destruction staff highlight fixes
--- @field BarHighlightExtraId BarHighlightExtraId Table of additional effect IDs for highlighting
--- @field BarHighlightOverride table<integer, BarHighlightOverrideOptions> Table of highlight override definitions
--- @field BarHighlightStack BarHighlightStack Table of stack-based highlight effects
--- @field BarHighlightStackFromCast table<integer, integer> Cast ability id -> charge stack when combat GAIN hitValue is missing
--- @field BarHighlightSkullChargeTrack table<integer, integer> Skull track buff id -> max bar stack label (Flame/Ricochet 2, Venom 3)
--- @field BarHighlightSkullEmpoweredCast table<integer, integer> Third-cast ability id -> skull track buff id (reset charges)
--- @field BarHighlightSkullChargeSource table<integer, string> Skull track buff id -> skullCastCombat | trackBuff
--- @field BarHighlightSkullSlottedDisplay table<integer, integer> Slotted bound id -> raw charge for bar (0 = none; Venom up to 3)
--- @field BarHighlightSlottedMajorCap table<integer, table<integer, integer>> Display id -> slotted ability id -> max duration (ms) this slotted row should accept from the player buff
--- @field BarHighlightStackConsume table<integer, integer> Bound ability id -> combatTrack stack buff id (consume one stack on cast)
--- @field BarHighlightStackSpendAllOnCast table<integer, integer> Slotted ability id -> track buff id (clear all stacks on cast)
--- @field BarHighlightReloadStackFromBuff table<integer, boolean> Track buff id: reload bar stacks from GetUnitBuffInfo on slot update
--- @field BarHighlightStackZeroEffect table<integer, "keep"|"clear"> Track buff id behavior when effect stack count is 0
--- @field BarHighlightStackBuffOnly table<integer, boolean> Track buff id: stacks only from player buff row (not event stackCount)
--- @field BarHighlightIgnoreBarStackEvent table<integer, boolean> Effect id: ignore non-FADE EVENT_EFFECT_CHANGED for bar stacks
--- @field BarHighlightStackCounter table<integer, boolean> Counter buff id: fade updates slotted bar stack (Grim Focus, Bound Armaments)
--- @field BarHighlightStackBaseAbility table<integer, boolean> Slotted ability ids that display stack count on the bar
--- @field BarHighlightTauntDebuffId integer Shared innate Taunt debuff id on reticleover (38254)
--- @field BarHighlightTauntSlotted table<integer, boolean> Slotted bound ids that taunt (ActionBar per-slot timer keys)
--- @field BarHighlightProcSoundThresholds table<integer, integer[]> Track buff id -> stack thresholds for proc sound
--- @field CompanionAbilityTrack CompanionAbilityTrack Slotted companion ability id -> UF icon track data
--- @field BarIdOverride BarIdOverride Table of bar ID overrides
--- @field DisguiseIcons EffectsDisguiseIcons Table of disguise icon definitions
--- @field GetDisguiseDisplayData fun(itemId: integer): DisguiseIcons Resolve disguise display data (table entry or item-icon fallback)
--- @field EffectCreateSkillAura EffectCreateSkillAura Table of skill aura creation definitions
--- @field EffectGroundDisplay EffectGroundDisplay Table of fake ground effect display definitions
--- @field EffectHideSCT EffectHideSCT Table of effects to hide from SCT
--- @field EffectMergeId EffectMergeId Table of effect ID merge definitions
--- @field EffectMergeName EffectMergeName Table of effect name merge definitions
--- @field EffectOverride EffectOverride Table of general effect overrides
--- @field EffectOverrideByName EffectOverrideByName Table of name-based effect overrides
--- @field EffectPullDuration EffectPullDuration Table of duration pull definitions
--- @field EffectPullStacks table<integer, integer> Visible buff id --> stack buff id (SpellCastBuffs)
--- @field EffectPushStacksFromHidden table<integer, integer> Hidden stack buff id --> visible buff id
--- @field EffectSourceOverride EffectSourceOverride Table of effect source overrides
--- @field FakeExternalBuffs FakeExternalBuffs Table of fake external buff definitions
--- @field FakeExternalDebuffs FakeExternalDebuffs Table of fake player debuff definitions
--- @field FakePlayerBuffs FakePlayerBuffs Table of fake external debuff definitions
--- @field FakePlayerDebuffs FakePlayerDebuffs Table of fake player buff definitions
--- @field FakePlayerOfflineAura FakePlayerOfflineAura Table of fake offline aura definitions
--- @field FakeStagger FakeStagger Table of fake stagger effect definitions
--- @field HasAbilityProc HasAbilityProc Table of ability proc definitions
--- @field IsAbilityProc IsAbilityProc
--- @field BaseForAbilityProc BaseForAbilityProc
--- @field IsAbilityActiveGlow IsAbilityActiveGlow Table of ability active glow effects
--- @field IsAbilityActiveHighlight IsAbilityActiveHighlight Table of ability active highlight effects
--- @field IsBloodFrenzy IsBloodFrenzy Table of blood frenzy effect definitions
--- @field IsGrimFocus IsGrimFocus Table of grim focus effect definitions
--- @field IsOakenSoul EffectIsOakenSoul table of Oakensoul localized buff names
--- @field KeepUpgradeAlliance KeepUpgradeAlliance Table of keep upgrade alliance definitions
--- @field KeepUpgradeNameFix KeepUpgradeNameFix Table of keep upgrade name fixes
--- @field KeepUpgradeOverride KeepUpgradeOverride Table of keep upgrade overrides
--- @field KeepUpgrade_Tooltip KeepUpgrade_Tooltip Table of keep upgrade tooltip definitions
--- @field MajorMinor MajorMinor Table of major/minor effect definitions
--- @field OffBalanceAbilityRegistry OffBalanceRegistryEntry[] Registry of Off Balance-related ability ids (English raw names)
--- @field OffBalanceImmunityAbilityId integer Ability id for Off Balance Immunity
--- @field MapDataOverride MapDataOverride Table of map data overrides
--- @field RemoveAbilityActiveHighlight RemoveAbilityActiveHighlight Table of effects to remove active highlight
--- @field SynergyNameOverride table<string, SynergyNameOverrideEntry> Table of synergy name overrides
--- @field TooltipUseDefault TooltipUseDefault Table of effects using default tooltips
--- @field ZoneBuffs ZoneBuffs Table of zone-specific buff definitions
--- @field ZoneDataOverride ZoneDataOverride Table of zone data overrides
local Effects =
{
    AddGroundDamageAura = {},
    AddNameAura = {},
    AddNameOnBossEngaged = {},
    AddNameOnEvent = {},
    AddNoDurationBarHighlight = {},
    BarHighlightHideDurationLabel = {},
    AddStackOnEvent = {},
    ArtificialEffectOverride = {},
    AssistantIcons = {},
    BarHighlightCheckOnFade = {},
    BarHighlightCruxMap = {},
    BarHighlightDestroFix = {},
    BarHighlightExtraId = {},
    BarHighlightOverride = {},
    BarHighlightStack = {},
    BarHighlightStackFromCast = {},
    BarHighlightSkullChargeTrack = {},
    BarHighlightSkullEmpoweredCast = {},
    BarHighlightSkullChargeSource = {},
    BarHighlightSkullSlottedDisplay = {},
    BarHighlightStackConsume = {},
    BarHighlightStackSpendAllOnCast = {},
    BarHighlightReloadStackFromBuff = {},
    BarHighlightStackZeroEffect = {},
    BarHighlightStackBuffOnly = {},
    BarHighlightIgnoreBarStackEvent = {},
    BarHighlightStackCounter = {},
    BarHighlightStackBaseAbility = {},
    BarHighlightTauntDebuffId = 38254,
    BarHighlightTauntSlotted = {},
    BarHighlightProcSoundThresholds = {},
    CompanionAbilityTrack = {},
    BarIdOverride = {},
    BlockAndBashCC = {},
    DebuffDisplayOverrideId = {},
    DebuffDisplayOverrideIdAlways = {},
    DebuffDisplayOverrideMajorMinor = {},
    DebuffDisplayOverrideName = {},
    DisguiseIcons = {},
    EffectCreateSkillAura = {},
    EffectGroundDisplay = {},
    EffectHideSCT = {},
    EffectMergeId = {},
    EffectMergeName = {},
    EffectOverride = {},
    EffectOverrideByName = {},
    EffectPullDuration = {},
    EffectPullStacks = {},
    EffectPushStacksFromHidden = {},
    EffectSourceOverride = {},
    FakeExternalBuffs = {},
    FakeExternalDebuffs = {},
    FakePlayerBuffs = {},
    FakePlayerDebuffs = {},
    FakePlayerOfflineAura = {},
    FakeStagger = {},
    HasAbilityProc = {},
    BaseForAbilityProc = {},
    IsAbilityProc = {},
    HideGroundMineStacks = {},
    IsAbilityActiveGlow = {},
    IsAbilityActiveHighlight = {},
    IsAbilityICD = {},
    IsAllianceXPBuff = {},
    IsBlock = {},
    IsBloodFrenzy = {},
    IsBoon = {},
    IsCyrodiil = {},
    IsExperienceBuff = {},
    IsFoodBuff = {},
    IsDrinkBuff = {},
    IsGrimFocus = {},
    IsBoundArmaments = {},
    IsGroundMineAura = {},
    IsGroundMineDamage = {},
    IsGroundMineStack = {},
    IsLycan = {},
    IsOakenSoul = {},
    IsSetICD = {},
    IsSoulSummons = {},
    IsVamp = {},
    IsVampLycanBite = {},
    IsVampLycanDisease = {},
    IsWeaponAttack = {},
    KeepUpgradeAlliance = {},
    KeepUpgradeNameFix = {},
    KeepUpgradeOverride = {},
    KeepUpgrade_Tooltip = {},
    LinkedGroundMine = {},
    MajorMinor = {},
    MapDataOverride = {},
    RemoveAbilityActiveHighlight = {},
    SynergyNameOverride = {},
    TooltipUseDefault = {},
    ZoneBuffs = {},
    ZoneDataOverride = {},
}

--- @class (partial) CrownStoreCollectibles
--- @field [string] integer
local CrownStoreCollectibles = {}

local PetNames =
{
    Assistants = {},
    Necromancer = {},
    Sets = {},
    Sorcerer = {},
    Warden = {},
}

--- @class (partial) Quests
local Quests = {}

--- @class (partial) Tooltips
local Tooltips = {}

--- @class (partial) UnitNames
local UnitNames = {}

--- @class (partial) ZoneNames
local ZoneNames = {}

--- @class (partial) ZoneTable
local ZoneTable = {}

--- @class (partial) LuiData
LuiData = {}
LuiData.name = "LuiData"
LuiData.version = 7226
LuiData.addonVersion = "7.2.2.6"

--- @class (partial) Data
LuiData.Data =
{
    Abilities = Abilities,
    IconFrameColorSamples = IconFrameColorSamples,
    AbilityBlacklistPresets = AbilityBlacklistPresets,
    AlertBossNameConvert = AlertBossNameConvert,
    AlertMapOverride = AlertMapOverride,
    AlertTable = AlertTable,
    AlertZoneOverride = AlertZoneOverride,
    CastBarTable = CastBarTable,
    CollectibleTables = CollectibleTables,
    CombatTextBlacklistPresets = CombatTextBlacklistPresets,
    CombatTextConstants = CombatTextConstants,
    CrownStoreCollectibles = CrownStoreCollectibles,
    CrowdControl = CrowdControl,
    DebugResults = DebugResults,
    DebugAuras = DebugAuras,
    DebugStatus = DebugStatus,
    Effects = Effects,
    PetNames = PetNames,
    Quests = Quests,
    Tooltips = Tooltips,
    UnitNames = UnitNames,
    ZoneNames = ZoneNames,
    ZoneTable = ZoneTable,
}
