--- @diagnostic disable: undefined-field, missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
--  LuaLS: canonical UnitFrames types/API in modules/UnitFrames/_annotations/*.meta.lua
-- -----------------------------------------------------------------------------

local GetString = GetString

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
--- @field VisualizerModules UnitFrames.VisualizerModules
--- @field VisualizerModuleClasses UnitFrames.VisualizerModuleClasses
--- @field defaultVisualizers table<string, LUIE_UnitAttributeVisualizer>
--- @field CustomFramesManager LUIE_CustomFrames_Manager
--- @field Visualizers table<string, LUIE_UnitAttributeVisualizer>
local UnitFrames = ZO_Object:Subclass()
--- @class (partial) UnitFrames
LUIE.UnitFrames = UnitFrames

UnitFrames.moduleName = LUIE.name .. "UnitFrames"

--- Module classes (use :New() per frame visualizer).
--- @class UnitFrames.VisualizerModuleClasses
--- @field PossessionModule LUIE_PossessionModule
--- @field PowerShieldModule LUIE_PowerShieldModule
--- @field RegenerationModule LUIE_RegenerationModule
--- @field StatChangeModule LUIE_StatChangeModule
--- @field UnwaveringModule LUIE_UnwaveringModule
UnitFrames.VisualizerModuleClasses =
{
    PossessionModule = nil,
    PowerShieldModule = nil,
    RegenerationModule = nil,
    StatChangeModule = nil,
    UnwaveringModule = nil,
}

--- @deprecated Use VisualizerModuleClasses.* :New() instead of singleton instances.
--- @class UnitFrames.VisualizerModules
UnitFrames.VisualizerModules = UnitFrames.VisualizerModuleClasses

--- Default-frame visualizers keyed by game unitTag.
--- @type table<string, LUIE_UnitAttributeVisualizer>
UnitFrames.defaultVisualizers = {}

--- Per game unitTag attribute visualizer (custom frame or default).
--- @type table<string, LUIE_UnitAttributeVisualizer>
UnitFrames.Visualizers = {}
--- @type UnitFrames.CustomFramesTable
UnitFrames.AvaCustFrames = {}

--- Regen/degen strip control created by CreateRegenAnimation (texture + looping translate timeline).
--- @class UnitFrames.RegenStripControl : TextureControl
--- @field animation AnimationObjectTranslate
--- @field timeline AnimationTimeline
--- @field regenDistanceMult number translate distance as a fraction of the bar width (Shared.ResizeRegenAnimation)
--- @field regenOffsetXMult number translate start X as a fraction of the bar width (Shared.ResizeRegenAnimation)
--- @field regenOffsetY number anchor Y offset reused when the translate offsets are recomputed

--- Default frame power entry (label + color, optional threshold for target).
--- @class UnitFrames.DefaultFramePowerEntry
--- @field label Control
--- @field color table
--- @field threshold number|nil
--- @field regen1 UnitFrames.RegenStripControl|nil
--- @field regen2 UnitFrames.RegenStripControl|nil
--- @field degen1 UnitFrames.RegenStripControl|nil
--- @field degen2 UnitFrames.RegenStripControl|nil

--- Per-unit default frame entry (unitTag + optional power-type entries, classIcon, friendIcon).
--- @class UnitFrames.DefaultFrameUnitEntry
--- @field unitTag string
--- @field [number] UnitFrames.DefaultFramePowerEntry
--- @field classIcon Control|nil
--- @field friendIcon Control|nil

--- Default frames table: unitTag -> unit entry, plus optional SmallGroup flag.
--- @class UnitFrames.DefaultFramesTable
--- @field [string] UnitFrames.DefaultFrameUnitEntry
--- @field SmallGroup boolean|nil

--- @type UnitFrames.DefaultFramesTable
UnitFrames.DefaultFrames = {}
UnitFrames.MaxChampionPoint = 3600
UnitFrames.defaultTargetNameLabel = nil
UnitFrames.defaultThreshold = 25
UnitFrames.isRaid = false
UnitFrames.powerError = {}
UnitFrames.savedHealth = {}
UnitFrames.statFull = {}
UnitFrames.activeElection = false
UnitFrames.groupSize = GetGroupSize()
UnitFrames.companionGroupSize = GetNumCompanionsInGroup()
UnitFrames.targetThreshold = 20
UnitFrames.healthThreshold = 25
UnitFrames.magickaThreshold = 25
UnitFrames.staminaThreshold = 25
UnitFrames.activeBossThresholds = nil
UnitFrames.bossThresholdMechanicPadding = 0
UnitFrames.bossThresholdStack = nil
UnitFrames.lastBossThresholdColumnSig = nil
UnitFrames.bossThresholdStageState = nil
UnitFrames.bossThresholdMechanicBottomAnimByIdx = nil
UnitFrames.debugBossThresholdPreviewActive = nil
UnitFrames.targetUnitFrame = nil -- Reference to default UI target unit frame
UnitFrames.playerDisplayName = GetUnitDisplayName("player")
UnitFrames.Enabled = false
UnitFrames.RAID_LEVEL_DISPLAY_NONE = 1
UnitFrames.RAID_LEVEL_DISPLAY_NUMBER = 2
UnitFrames.RAID_LEVEL_DISPLAY_ICON = 3
-- LibCustomIcons portrait placement. Beside the class icon is the default so an existing layout does not move.
UnitFrames.CUSTOM_ICON_POSITION_BESIDE_CLASS = 1
UnitFrames.CUSTOM_ICON_POSITION_LEFT_OF_NAME = 2
UnitFrames.CUSTOM_ICON_POSITION_REPLACE_CLASS = 3
-- Raid member XML template (chosen at build time in LUIE.CustomFramesBuildRaidGroup; requires /reloadui to switch).
UnitFrames.RAID_FRAME_TEMPLATE_COMPACT = "Compact"
UnitFrames.RAID_FRAME_TEMPLATE_EXPANDED = "Expanded"
-- RaidLayoutBattleground shapes (Big Team Battles 6v6v6 / 9v9): the slot count N follows GetBattlegroundTeamSize,
-- so one setting gives 1x9 / 3x3 / 9x1 in a 9v9 and 1x6 / 3x2 / 6x1 in a 6v6v6 (UnitFrames.GetActiveRaidLayout).
UnitFrames.RAID_LAYOUT_BATTLEGROUND_COLUMN = "column" -- 1 x N
UnitFrames.RAID_LAYOUT_BATTLEGROUND_GRID = "grid"     -- 3 x ceil(N / 3)
UnitFrames.RAID_LAYOUT_BATTLEGROUND_ROW = "row"       -- N x 1

--- True when the raid frames use the expanded (two-row) member template.
--- @return boolean
function UnitFrames.IsRaidExpandedTemplate()
    local sv = UnitFrames.SV
    return sv ~= nil and sv.RaidFrameTemplate == UnitFrames.RAID_FRAME_TEMPLATE_EXPANDED
end

UnitFrames.Defaults =
{
    QuickHideDead = false,
    HidePlayerFrameOnDeath = false,
    TargetLingerInCursorMode = false,
    TargetLingerDuration = 10,
    ShortenNumbers = false,
    RepositionFrames = true,
    DefaultOocTransparency = 85,
    DefaultIncTransparency = 85,
    DefaultFramesNewPlayer = 1,
    DefaultFramesNewTarget = 1,
    DefaultFramesNewGroup = 1,
    DefaultFramesNewBoss = 3,
    Format = "Current + Shield - Trauma (Percentage%)",
    DefaultFontFace = "LUIE Default Font",
    DefaultFontStyle = FONT_STYLE_SOFT_SHADOW_THICK,
    DefaultFontSize = 16,
    DefaultTextColour = { 1, 1, 1, 1 },
    TargetShowClass = true,
    TargetShowFriend = true,
    TargetColourByReaction = false,
    CustomFormatOnePlayer = "Current + Shield - Trauma / Max",
    CustomFormatTwoPlayer = "Percentage%",
    CustomFormatOneTarget = "Current + Shield - Trauma / Max",
    CustomFormatTwoTarget = "Percentage%",
    CustomFormatOneGroup = "Current + Shield - Trauma / Max",
    CustomFormatTwoGroup = "Percentage%",
    CustomFormatRaid = "Current (Percentage%)",
    CustomFormatBoss = "Percentage%",
    CustomFrameAppearance =
    {
        player =
        {
            fontFace = "LUIE Default Font",
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 20,
            nameMinFont = 14,
            texture = "Minimalistic",
        },
        target =
        {
            fontFace = "LUIE Default Font",
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 20,
            nameMinFont = 14,
            texture = "Minimalistic",
        },
        group =
        {
            fontFace = "LUIE Default Font",
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 20,
            nameMinFont = 14,
            texture = "Minimalistic",
        },
        raid =
        {
            fontFace = "LUIE Default Font",
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 16,
            nameMinFont = 10,
            texture = "Minimalistic",
        },
        companion =
        {
            fontFace = "LUIE Default Font",
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 16,
            nameMinFont = 10,
            texture = "Minimalistic",
        },
        pet =
        {
            fontFace = "LUIE Default Font",
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 16,
            nameMinFont = 10,
            texture = "Minimalistic",
        },
        boss =
        {
            fontFace = "LUIE Default Font",
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 16,
            nameMinFont = 10,
            texture = "Minimalistic",
        },
        ava =
        {
            fontFace = "LUIE Default Font",
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 20,
            nameMinFont = 14,
            texture = "Minimalistic",
        },
    },
    HideBuffsPlayerOoc = false,
    HideBuffsTargetOoc = false,
    PlayerOocAlpha = 85,
    PlayerIncAlpha = 85,
    TargetOocAlpha = 85,
    TargetIncAlpha = 85,
    GroupAlpha = 85,
    BossOocAlpha = 85,
    BossIncAlpha = 85,
    PlayerOocAlphaPower = true,
    TargetOocAlphaPower = true,
    CustomColourHealth = { 0.79, 0.08, 0, 1 },
    CustomColourShield = { 1, 0.75, 0, 1 },
    CustomColourTrauma = { 0.35, 0, 0.39, 1 },
    CustomColourMagicka = { 0, 0.33, 0.82, 1 },
    CustomColourStamina = { 0.11, 0.69, 0, 1 },
    CustomColourInvulnerable = { 0.37, 0.27, 0.24, 1 },
    CustomColourDPS = { 0.51, 0.39, 0.25, 1 },
    CustomColourHealer = { 0.46, 0.30, 0.53, 1 },
    CustomColourTank = { 0.52, 0.07, 0.05, 1 },
    CustomColourDragonknight = { 1.00, 0.49, 0.14, 1 },
    CustomColourNightblade = { 1.00, 0.20, 0.19, 1 },
    CustomColourSorcerer = { 0.29, 0.33, 0.97, 1 },
    CustomColourTemplar = { 1.00, 0.94, 0.37, 1 },
    CustomColourWarden = { 0.53, 0.96, 0.49, 1 },
    CustomColourNecromancer = { 0.38, 0.15, 0.79, 1 },
    CustomColourArcanist = { 0.35, 0.94, 0.31, 1 },
    CustomShieldBarSeparate = false,
    CustomShieldBarHeight = 8,
    CustomShieldBarFull = false,
    CustomSmoothBar = true,
    CustomFramesPlayer = true,
    CustomFramesTarget = true,
    PlayerBarWidth = 300,
    TargetBarWidth = 300,
    PlayerBarHeightHealth = 30,
    PlayerBarHeightMagicka = 28,
    PlayerBarHeightStamina = 28,
    BossBarWidth = 300,
    BossBarHeight = 36,
    BossBarSpacing = 2,
    HideBarMagicka = false,
    HideLabelMagicka = false,
    HideBarStamina = false,
    HideLabelStamina = false,
    HideLabelHealth = false,
    HideBarHealth = false,
    PlayerBarSpacing = 0,
    TargetBarHeight = 36,
    PlayerEnableYourname = true,
    PlayerEnableAltbarMSW = true,
    PlayerEnableAltbarXP = true,
    PlayerChampionColour = true,
    PlayerEnableArmor = true,
    PlayerEnablePower = false,
    PlayerEnableRegen = true,
    TargetEnableArmor = true,
    TargetEnablePower = false,
    TargetEnableRegen = true,
    GroupEnableArmor = false,
    GroupEnablePower = false,
    GroupEnableRegen = true,
    GroupCombatGlow = false,
    GroupCombatGlowColor = { 1, 0, 0, 1 }, -- Default red glow
    RaidEnableArmor = false,
    RaidEnablePower = false,
    RaidEnableRegen = false,
    RaidCombatGlow = false,
    RaidCombatGlowColor = { 1, 0, 0, 1 }, -- Default red glow
    BossEnableArmor = false,
    BossEnablePower = false,
    BossEnableRegen = false,
    BossShowThresholdMarkers = true,
    BossThresholdLabelAnchor = "BOTTOM",
    BossThresholdLabelRelativeAnchor = "TOP",
    BossThresholdLabelOffsetX = 0,
    BossThresholdLabelOffsetY = -2,
    TargetEnableClass = false,
    TargetEnableRank = true,
    TargetEnableRankIcon = true,
    TargetTitlePriority = "Title",
    TargetEnableTitle = true,
    TargetEnableSkull = true,
    PlayerShowVeterancyRank = false,
    PlayerShowOverlandDifficulty = false,
    TargetShowVeterancyRank = false,
    TargetShowOverlandDifficulty = false,
    CustomTargetShowFriendIcon = true,
    CustomTargetShowGuildIcon = true,
    CustomTargetShowIgnoredIcon = true,
    GroupShowFriendIcon = false,
    GroupShowGuildIcon = false,
    GroupShowIgnoredIcon = false,
    TargetMonsterOverlandDifficulty = false,
    TargetHighlightMonsterUnits = true,
    QuickHideDeadUseUnitMonster = true,
    GroupShowVeterancyRank = false,
    GroupShowOverlandDifficulty = false,
    RaidShowVeterancyRank = false,
    RaidShowOverlandDifficulty = false,
    RaidLevelDisplay = UnitFrames.RAID_LEVEL_DISPLAY_NONE,
    CustomFramesGroup = true,
    GroupExcludePlayer = false,
    GroupBarWidth = 260,
    GroupBarHeight = 36,
    GroupBarSpacing = 40,
    CustomFramesRaid = true,
    RaidNameClip = 94,
    RaidBarWidth = 220,
    RaidBarHeight = 30,
    RaidLayout = "1 x 12",
    -- Used instead of RaidLayout while in a Big Team Battles battleground (6v6v6 / 9v9); a RAID_LAYOUT_BATTLEGROUND_*
    -- shape. Pre-U51 "1 x 9" / "3 x 3" / "9 x 1" values are migrated by UnitFrames.GetBattlegroundRaidLayoutShape.
    RaidLayoutBattleground = UnitFrames.RAID_LAYOUT_BATTLEGROUND_GRID,
    RaidFrameTemplate = UnitFrames.RAID_FRAME_TEMPLATE_COMPACT,
    RoleIconSmallGroup = true,
    ColorRoleGroup = true,
    ColorRoleRaid = true,
    SortRoleGroup = false,
    SortRoleRaid = true,
    ColorClassGroup = false,
    ColorClassRaid = false,
    RaidSpacers = false,
    CustomFramesBosses = true,
    AvaCustFramesTarget = false,
    AvaTargetBarWidth = 450,
    AvaTargetBarHeight = 36,
    Target_FontColour = { 1, 1, 1, 1 },
    Target_FontColour_FriendlyNPC = { 0, 1, 0, 1 },
    Target_FontColour_FriendlyPlayer = { 0.7, 0.7, 1, 1 },
    Target_FontColour_Hostile = { 1, 0, 0, 1 },
    Target_FontColour_Neutral = { 1, 1, 0, 1 },
    Target_Neutral_UseDefaultColour = true,
    ReticleColour_Interact = { 1, 1, 0, 1 },
    ReticleColourByReaction = false,
    DisplayOptionsPlayer = 2,
    DisplayOptionsTarget = 2,
    DisplayOptionsGroupRaid = 2,
    CustomNames = false,
    CustomNameOutline = false,
    CustomIcons = false,
    CustomIconAnimations = false,
    CustomIconPosition = UnitFrames.CUSTOM_ICON_POSITION_BESIDE_CLASS,
    ExecutePercentage = 20,
    RaidIconOptions = 2,
    RepositionFramesAdjust = 0,
    PlayerFrameOptions = 1,
    AdjustStaminaHPos = 200,
    AdjustStaminaVPos = 0,
    AdjustMagickaHPos = 200,
    AdjustMagickaVPos = 0,
    FrameColorReaction = false,
    FrameColorClass = false,
    CustomColourPlayer = { 0.70, 0.70, 1, 1 },
    CustomColourFriendly = { 0, 1, 0, 1 },
    CustomColourHostile = { 1, 0, 0, 1 },
    CustomColourNeutral = { 0.59, 0.59, 0.59, 1 },
    CustomColourGuard = { 0.37, 0.27, 0.24, 1 },
    CustomColourCompanionFrame = { 0, 1, 0, 1 },
    LowResourceHealth = 25,
    LowResourceStamina = 25,
    LowResourceMagicka = 25,
    ShowPlayerDodgePrediction = false,
    PlayerDodgePredictionColor = { 1, 0.92, 0.2, 0.95 },
    ShieldAlpha = 50,
    ReverseResourceBars = false,
    CustomFramesPet = true,
    CustomFormatPet = "Current (Percentage%)",
    CustomColourPet = { 0.79, 0.08, 0, 1 },
    PetHeight = 30,
    PetWidth = 220,
    PetUseClassColor = false,
    PetIncAlpha = 85,
    PetOocAlpha = 85,
    PetEnableRegen = false,
    PetEnableArmor = false,
    PetEnablePower = false,
    PetCombatGlow = false,
    PetCombatGlowColor = { 1, 0, 0, 1 },
    whitelist = {}, -- Whitelist for pet names
    PetNameClip = 88,
    CustomFramesCompanion = true,
    CustomFormatCompanion = "Current (Percentage%)",
    CustomColourCompanion = { 0.79, 0.08, 0, 1 },
    CompanionHeight = 30,
    CompanionWidth = 220,
    CompanionUseClassColor = false,
    CompanionIncAlpha = 85,
    CompanionOocAlpha = 85,
    CompanionNameClip = 88,
    CompanionEnableRegen = false,
    CompanionEnableArmor = false,
    CompanionEnablePower = false,
    CompanionCombatGlow = false,
    CompanionCombatGlowColor = { 1, 0, 0, 1 },
    CompanionAbilityTrack =
    {
        enabled = false,
        iconSize = 24,
        iconSpacing = 2,
        showEffectTimer = true,
        showStacks = true,
        showBuiltinInterrupt = true,
    },
    CompanionRapportFlourish =
    {
        enabled = false,
    },
    BarAlignPlayerHealth = 1,
    BarAlignPlayerMagicka = 1,
    BarAlignPlayerStamina = 1,
    BarAlignTarget = 1,
    BarAlignCenterLabelPlayer = false,
    BarAlignCenterLabelTarget = false,
    CustomFormatCenterLabel = "Current + Shield - Trauma / Max (Percentage%)",
    CustomTargetMarker = false,

    -- Group Resources (LibGroupBroadcast Integration)
    GroupResources =
    {
        enabled = false,
        showOnRaidFrames = true, -- false keeps the bars on the 4 player group frames only (compact and Expanded raid frames)
        staminaFirst = false,
        hideResourceBarsToggle = true,
        hideResourceBarsTimeout = 120,
        enableFadeEffect = true,
        groupBarWidth = 150,
        groupBarHeight = 6,
        raidBarWidth = 90,
        raidBarHeight = 6,
        colors =
        {
            [COMBAT_MECHANIC_FLAGS_MAGICKA] =
            {
                gradientStart = { GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_START, COMBAT_MECHANIC_FLAGS_MAGICKA) },
                gradientEnd = { GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_END, COMBAT_MECHANIC_FLAGS_MAGICKA) },
            },
            [COMBAT_MECHANIC_FLAGS_STAMINA] =
            {
                gradientStart = { GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_START, COMBAT_MECHANIC_FLAGS_STAMINA) },
                gradientEnd = { GetInterfaceColor(INTERFACE_COLOR_TYPE_POWER_END, COMBAT_MECHANIC_FLAGS_STAMINA) },
            },
        },
    },

    -- Group Combat Stats (LibGroupCombatStats Integration)
    GroupCombatStats =
    {
        enabled = false,
        showOnRaidFrames = true, -- false keeps ultimates / DPS / HPS on the 4 player group frames only
        showUltimate = true,
        showDPS = true,
        showHPS = true,
        -- Group (4 player) settings
        ultIconGroupSize = 28,
        ultIconGroupOffsetX = 4,
        ultIconGroupOffsetY = 0,
        -- Raid (12 player) settings (only used by the Expanded raid frame template)
        ultIconRaidSize = 16,
        ultIconRaidOffsetX = 3,
        ultIconRaidOffsetY = 0,
    },

    -- Group Potion Cooldowns (LibGroupPotionCooldowns Integration)
    GroupPotionCooldowns =
    {
        enabled = false,
        showOnRaidFrames = true, -- false keeps the potion slot on the 4 player group frames only
        showRemainingTime = true,
        -- Group (4 player) settings
        potionIconGroupSize = 24,
        potionIconGroupOffsetX = 4,
        potionIconGroupOffsetY = 0,
        -- Raid (12 player) settings (only used by the Expanded raid frame template)
        potionIconRaidSize = 16,
        potionIconRaidOffsetX = 3,
        potionIconRaidOffsetY = 0,
    },

    -- Group Food & Drink Buffs (LibFoodDrinkBuff Integration)
    GroupFoodDrinkBuff =
    {
        enabled = false,
        showOnRaidFrames = true, -- false keeps the food/drink slot on the 4 player group frames only
        showNoBuff = false,
        showRemainingTime = true,
        useCustomIcons = false,
        iconSizeGroup = 24,
        iconOffsetXGroup = 4,
        iconOffsetYGroup = 0,
        iconSizeRaid = 16, -- Expanded raid template bottom-row slot (matches ultIconRaidSize / potionIconRaidSize)
    },
}

UnitFrames.SV = {}

--- Forward declarations for visualizer module classes (defined in UnitAttributeVisuals/*.lua).
--- @class LUIE_RegenerationModule : LUIE_UnitAttributeVisualizerModuleBase
--- @field New fun(self, ...): LUIE_RegenerationModule
--- @class LUIE_StatChangeModule : LUIE_UnitAttributeVisualizerModuleBase
--- @field New fun(self, ...): LUIE_StatChangeModule
--- @class LUIE_PowerShieldModule : LUIE_UnitAttributeVisualizerModuleBase
--- @field New fun(self, ...): LUIE_PowerShieldModule
--- @class LUIE_UnwaveringModule : LUIE_UnitAttributeVisualizerModuleBase
--- @field New fun(self, ...): LUIE_UnwaveringModule
--- @class LUIE_PossessionModule : LUIE_UnitAttributeVisualizerModuleBase
--- @field New fun(self, ...): LUIE_PossessionModule

--- @class LUIE_CustomFrames_Manager : ZO_InitializingObject
--- @class LUIE_CustomFrameObject : LUIE_CustomFrameData_Base
--- @class LUIE_CustomFrameData_Base : LUIE_PooledCustomFrameDataObject
--- @class LUIE_PooledCustomFrameDataObject : ZO_InitializingObject

--- Power row on a custom frame (health/magicka/stamina bar aggregate); includes regen strips when enabled.
--- @class UnitFrames.CustomFramePowerEntry
--- @field backdrop BackdropControl|Control|nil
--- @field bar StatusBarControl|nil
--- @field label Control|nil
--- @field labelOne Control|nil
--- @field labelTwo Control|nil
--- @field shield StatusBarControl|nil
--- @field shieldbackdrop BackdropControl|nil
--- @field shieldLayers StatusBarControl[]|nil
--- @field trauma StatusBarControl|nil
--- @field invulnerable Control|nil
--- @field invulnerableInlay Control|nil
--- @field enlightenment StatusBarControl|nil
--- @field noHealingOverlay StatusBarControl|nil
--- @field noHealingStripe StatusBarControl|nil
--- @field noHealingFadeAnimation AnimationTimeline|nil
--- @field possessionOverlay Control|nil
--- @field possessionGlowLeft Control|nil
--- @field possessionGlowRight Control|nil
--- @field possessionGlowCenter Control|nil
--- @field possessionHalo table|nil
--- @field glowFadeAnimation AnimationTimeline|nil
--- @field combatGlow Control|nil
--- @field regen1 UnitFrames.RegenStripControl|nil
--- @field regen2 UnitFrames.RegenStripControl|nil
--- @field degen1 UnitFrames.RegenStripControl|nil
--- @field degen2 UnitFrames.RegenStripControl|nil
--- @field stat table|nil
--- @field format string|nil

--- @class UnitFrames.CustomFrameResourceRow : UnitFrames.CustomFramePowerEntry
--- @alias LUIE_PositionableTopLevelWindow LUIE_UF_PlayerFrame_Template

--- Per-unit custom frame root (TLW, buff anchors, and numeric COMBAT_MECHANIC_FLAGS_* power rows).
--- @class UnitFrames.CustomFrameUnitEntry : LUIE_CustomFrameObject
--- @field __index table|nil
--- @field __parentClasses table[]|nil
--- @field __isAbstractClass boolean|nil
--- @field unitTag string|nil
--- @field attributeVisualizer LUIE_UnitAttributeVisualizer|nil
--- @field hudSceneFragment ZO_HUDFadeSceneFragment|nil
--- @field frameRegistryKey string|nil Registry key in UnitFrames.CustomFrames (e.g. SmallGroup1).
--- @field visualizerUnitTag string|nil Game unitTag for UnitFrames.GetVisualizerForUnit when registry key differs (group alias).
--- @field frameCategory string|nil
--- @field control Control|nil
--- @field roleIcon Control|nil
--- @field resourceMagicka UnitFrames.CustomFrameResourceRow|nil
--- @field resourceStamina UnitFrames.CustomFrameResourceRow|nil
--- @field buffs Control|nil
--- @field debuffs Control|nil
--- @field tlw LUIE_PositionableTopLevelWindow|nil
--- @field [number] UnitFrames.CustomFramePowerEntry
--- @field [string] UnitFrames.CustomFramePowerEntry|Control|TopLevelWindow|nil

--- Frame data objects are built by modules/UnitFrames/CustomFrames/* (XML virtual templates; runtime CreateControlFromVirtual).
--- @class UnitFrames.CustomFramesTable
--- @field [string] UnitFrames.CustomFrameUnitEntry|LUIE_CustomFrameObject

--- @type UnitFrames.CustomFramesTable
UnitFrames.CustomFrames =
{
}

--[[ CustomFrames registry keys vs UAV visualizer unitTags:
  player, reticleover, companion, bossN, controlledsiege - 1:1 with visualizers.
  SmallGroupN / RaidGroupN / PetGroupN - registry slots; alias to groupN / playerpetN via same frame object (visualizerUnitTag on frame data).
]]
UnitFrames.CustomFramesMovingState = false
UnitFrames.reticleoverHostile = false  -- boolean: hostile target and TargetEnableSkull (avoids assign-type-mismatch on frame.hostile)
UnitFrames.targetFrameLingered = false -- true after we have shown a valid target; prevents blank frame/icons on load when TargetLingerInCursorMode is on
UnitFrames.targetLingerTimeoutName = UnitFrames.moduleName .. "TargetLingerTimeout"
UnitFrames.targetLingerTimerActive = false
