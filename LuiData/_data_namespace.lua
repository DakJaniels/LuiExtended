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

--- @class Effects
--- @field AddGroundDamageAura AddGroundDamageAura Table of fake ground damage aura definitions
--- @field AddNameAura AddNameAura Table of effects that need name auras added
--- @field AddNameOnBossEngaged AddNameOnBossEngaged Table of effects that add names when boss is engaged
--- @field AddNameOnEvent AddNameOnEvent Table of effects that add names on specific events
--- @field AddNoDurationBarHighlight table<integer, boolean> Table of effects that should highlight without duration
--- @field AddStackOnEvent AddStackOnEvent Table of effects that add stacks on specific events
--- @field ArtificialEffectOverride ArtificialEffectOverride Table of artificial effect overrides
--- @field AssistantIcons AssistantIcons Table of assistant icon definitions
--- @field BarHighlightCheckOnFade table<integer, BarHighlightOverrideEntry> Table of effects to check highlight on fade
--- @field BarHighlightDestroFix BarHighlightDestroFix Table of destruction staff highlight fixes
--- @field BarHighlightExtraId BarHighlightExtraId Table of additional effect IDs for highlighting
--- @field BarHighlightOverride table<integer, BarHighlightOverrideOptions> Table of highlight override definitions
--- @field BarHighlightStack BarHighlightStack Table of stack-based highlight effects
--- @field BarIdOverride BarIdOverride Table of bar ID overrides
--- @field DisguiseIcons DisguiseIcons Table of disguise icon definitions
--- @field EffectCreateSkillAura EffectCreateSkillAura Table of skill aura creation definitions
--- @field EffectGroundDisplay EffectGroundDisplay Table of fake ground effect display definitions
--- @field EffectHideSCT EffectHideSCT Table of effects to hide from SCT
--- @field EffectMergeId EffectMergeId Table of effect ID merge definitions
--- @field EffectMergeName EffectMergeName Table of effect name merge definitions
--- @field EffectOverride EffectOverride Table of general effect overrides
--- @field EffectOverrideByName EffectOverrideByName Table of name-based effect overrides
--- @field EffectPullDuration EffectPullDuration Table of duration pull definitions
--- @field EffectSourceOverride EffectSourceOverride Table of effect source overrides
--- @field FakeExternalBuffs FakeExternalBuffs Table of fake external buff definitions
--- @field FakeExternalDebuffs FakeExternalDebuffs Table of fake player debuff definitions
--- @field FakePlayerBuffs FakePlayerBuffs Table of fake external debuff definitions
--- @field FakePlayerDebuffs FakePlayerDebuffs Table of fake player buff definitions
--- @field FakePlayerOfflineAura FakePlayerOfflineAura Table of fake offline aura definitions
--- @field FakeStagger FakeStagger Table of fake stagger effect definitions
--- @field HasAbilityProc HasAbilityProc Table of ability proc definitions
--- @field IsAbilityActiveGlow IsAbilityActiveGlow Table of ability active glow effects
--- @field IsAbilityActiveHighlight IsAbilityActiveHighlight Table of ability active highlight effects
--- @field IsBloodFrenzy IsBloodFrenzy Table of blood frenzy effect definitions
--- @field IsGrimFocus IsGrimFocus Table of grim focus effect definitions
--- @field KeepUpgradeAlliance KeepUpgradeAlliance Table of keep upgrade alliance definitions
--- @field KeepUpgradeNameFix KeepUpgradeNameFix Table of keep upgrade name fixes
--- @field KeepUpgradeOverride KeepUpgradeOverride Table of keep upgrade overrides
--- @field KeepUpgradeTooltip KeepUpgradeTooltip Table of keep upgrade tooltip definitions
--- @field MajorMinor MajorMinor Table of major/minor effect definitions
--- @field MapDataOverride MapDataOverride Table of map data overrides
--- @field RemoveAbilityActiveHighlight RemoveAbilityActiveHighlight Table of effects to remove active highlight
--- @field SynergyNameOverride SynergyNameOverride Table of synergy name overrides
--- @field TooltipUseDefault TooltipUseDefault Table of effects using default tooltips
--- @field ZoneBuffs ZoneBuffs Table of zone-specific buff definitions
--- @field ZoneDataOverride ZoneDataOverride Table of zone data overrides

--- @class (partial) Data
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
--- @field Effects Effects
--- @field PetNames PetNames
--- @field Quests Quests
--- @field Tooltips Tooltips
--- @field UnitNames UnitNames
--- @field ZoneNames ZoneNames
--- @field ZoneTable ZoneTable


--- @class (partial) LuiData
LuiData =
{
    __name = "LuiData",
    version = "6.8.7",
    Data = --- @class (partial) Data
    {
        Abilities = {},
        AbilityBlacklistPresets =
        {
            MajorBuffs = {},
            MajorDebuffs = {},
            MinorBuffs = {},
            MinorDebuffs = {},
        },
        AlertBossNameConvert = {},
        AlertMapOverride = {},
        AlertTable = {},
        AlertZoneOverride = {},
        CastBarTable = {},
        CollectibleTables = {},
        CombatTextBlacklistPresets =
        {
            Necromancer = {},
            Sets = {},
            Sorcerer = {},
            Templar = {},
            Warden = {},
        },
        CombatTextConstants = {},
        CrowdControl =
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
        },
        DebugResults = {},
        DebugAuras = {},
        Effects =
        {
            AddNameAura = {},
            AddNameOnBossEngaged = {},
            AddNameOnEvent = {},
            AddNoDurationBarHighlight = {},
            AddStackOnEvent = {},
            ArtificialEffectOverride = {},
            AssistantIcons = {},
            BarHighlightCheckOnFade = {},
            BarHighlightDestroFix = {},
            BarHighlightExtraId = {},
            BarHighlightOverride = {},
            BarHighlightStack = {},
            BarIdOverride = {},
            BlockAndBashCC = {},
            DebuffDisplayOverrideId = {},
            DebuffDisplayOverrideIdAlways = {},
            DebuffDisplayOverrideMajorMinor = {},
            DebuffDisplayOverrideName = {},
            DisguiseIcons = {},
            EffectHideSCT = {},
            EffectMergeId = {},
            EffectMergeName = {},
            EffectOverride = {},
            EffectOverrideByName = {},
            EffectPullDuration = {},
            EffectSourceOverride = {},
            FakeExternalBuffs = {},
            FakeExternalDebuffs = {},
            FakePlayerBuffs = {},
            FakePlayerDebuffs = {},
            FakePlayerOfflineAura = {},
            FakeStagger = {},
            HasAbilityProc = {},
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
            IsGrimFocus = {},
            IsGroundMineAura = {},
            IsGroundMineDamage = {},
            IsGroundMineStack = {},
            IsLycan = {},
            IsSetICD = {},
            IsSoulSummons = {},
            IsVamp = {},
            IsVampLycanBite = {},
            IsVampLycanDisease = {},
            IsWeaponAttack = {},
            KeepUpgradeAlliance = {},
            KeepUpgradeNameFix = {},
            KeepUpgradeOverride = {},
            KeepUpgradeTooltip = {},
            LinkedGroundMine = {},
            MajorMinor = {},
            MapDataOverride = {},
            RemoveAbilityActiveHighlight = {},
            SynergyNameOverride = {},
            TooltipUseDefault = {},
            ZoneBuffs = {},
            ZoneDataOverride = {},
        },
        PetNames =
        {
            Assistants = {},
            Necromancer = {},
            Sets = {},
            Sorcerer = {},
            Warden = {},
        },
        --- @class (partial) Quests
        Quests = {},
        --- @class (partial) Tooltips
        Tooltips = {},
        --- @class (partial) UnitNames
        UnitNames = {},
        --- @class (partial) ZoneNames
        ZoneNames = {},
        --- @class (partial) ZoneTable
        ZoneTable = {},
    }
}
