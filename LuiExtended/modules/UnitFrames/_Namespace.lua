--- @diagnostic disable: undefined-field, missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

local GetString = GetString

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
--- @field VisualizerModules UnitFrames.VisualizerModules
--- @field Visualizers table<string, LUIE_UnitAttributeVisualizer>
local UnitFrames = ZO_Object:Subclass()
--- @class (partial) UnitFrames
LUIE.UnitFrames = UnitFrames

UnitFrames.moduleName = LUIE.name .. "UnitFrames"

--- Table holding singleton module instances shared across all unit frames
--- @class UnitFrames.VisualizerModules
--- @field PowerShieldModule LUIE_PowerShieldModule
--- @field RegenerationModule LUIE_RegenerationModule
--- @field StatChangeModule LUIE_StatChangeModule
--- @field UnwaveringModule LUIE_UnwaveringModule
--- @field PossessionModule LUIE_PossessionModule
UnitFrames.VisualizerModules =
{
    PossessionModule = {},
    PowerShieldModule = {},
    RegenerationModule = {},
    StatChangeModule = {},
    UnwaveringModule = {},
}

--- Table holding per-unitTag visualizer coordinator instances
--- @type table<string, LUIE_UnitAttributeVisualizer>
UnitFrames.Visualizers = {}
--- Cyrodiil / alternate target mirror of CustomFrames (same per-unit shape when populated).
--- @type UnitFrames.CustomFramesTable
UnitFrames.AvaCustFrames = {}

--- Regen/degen strip control created by CreateRegenAnimation (texture + looping translate timeline).
--- @class UnitFrames.RegenStripControl : Control
--- @field animation AnimationObject
--- @field timeline AnimationTimeline

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
UnitFrames.targetUnitFrame = nil -- Reference to default UI target unit frame
UnitFrames.playerDisplayName = GetUnitDisplayName("player")
UnitFrames.Enabled = false
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
    DefaultFramesNewBoss = 2,
    Format = GetString(LUIE_STRING_UF_FORMAT_DEFAULT),
    DefaultFontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
    DefaultFontStyle = FONT_STYLE_SOFT_SHADOW_THICK,
    DefaultFontSize = 16,
    DefaultTextColour = { 1, 1, 1, 1 },
    TargetShowClass = true,
    TargetShowFriend = true,
    TargetColourByReaction = false,
    CustomFormatOnePlayer = GetString(LUIE_STRING_UF_FORMAT_PT_ONE),
    CustomFormatTwoPlayer = GetString(LUIE_STRING_UF_FORMAT_PT_TWO),
    CustomFormatOneTarget = GetString(LUIE_STRING_UF_FORMAT_PT_ONE),
    CustomFormatTwoTarget = GetString(LUIE_STRING_UF_FORMAT_PT_TWO),
    CustomFormatOneGroup = GetString(LUIE_STRING_UF_FORMAT_GROUP_ONE),
    CustomFormatTwoGroup = GetString(LUIE_STRING_UF_FORMAT_GROUP_TWO),
    CustomFormatRaid = GetString(LUIE_STRING_UF_FORMAT_RAID),
    CustomFormatBoss = GetString(LUIE_STRING_UF_FORMAT_BOSS),
    CustomFrameAppearance =
    {
        player =
        {
            fontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 20,
            texture = GetString(LUIE_STRING_UF_TEXTURE_DEFAULT),
        },
        target =
        {
            fontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 20,
            texture = GetString(LUIE_STRING_UF_TEXTURE_DEFAULT),
        },
        group =
        {
            fontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 20,
            texture = GetString(LUIE_STRING_UF_TEXTURE_DEFAULT),
        },
        raid =
        {
            fontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 16,
            texture = GetString(LUIE_STRING_UF_TEXTURE_DEFAULT),
        },
        companion =
        {
            fontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 16,
            texture = GetString(LUIE_STRING_UF_TEXTURE_DEFAULT),
        },
        pet =
        {
            fontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 16,
            texture = GetString(LUIE_STRING_UF_TEXTURE_DEFAULT),
        },
        boss =
        {
            fontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 16,
            texture = GetString(LUIE_STRING_UF_TEXTURE_DEFAULT),
        },
        ava =
        {
            fontFace = GetString(LUIE_STRING_UF_FONT_DEFAULT),
            fontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
            fontBars = 16,
            fontOther = 20,
            texture = GetString(LUIE_STRING_UF_TEXTURE_DEFAULT),
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
    CustomColourHealth = { 202 / 255, 20 / 255, 0, 1 },
    CustomColourShield = { 1, 192 / 255, 0, 1 },
    CustomColourTrauma = { 90 / 255, 0, 99 / 255, 1 },
    CustomColourMagicka = { 0, 83 / 255, 209 / 255, 1 },
    CustomColourStamina = { 28 / 255, 177 / 255, 0, 1 },
    CustomColourInvulnerable = { 95 / 255, 70 / 255, 60 / 255, 1 },
    CustomColourDPS = { 130 / 255, 99 / 255, 65 / 255, 1 },
    CustomColourHealer = { 117 / 255, 077 / 255, 135 / 255, 1 },
    CustomColourTank = { 133 / 255, 018 / 255, 013 / 255, 1 },
    CustomColourDragonknight = { 255 / 255, 125 / 255, 35 / 255, 1 },
    CustomColourNightblade = { 255 / 255, 51 / 255, 49 / 255, 1 },
    CustomColourSorcerer = { 75 / 255, 83 / 255, 247 / 255, 1 },
    CustomColourTemplar = { 255 / 255, 240 / 255, 95 / 255, 1 },
    CustomColourWarden = { 136 / 255, 245 / 255, 125 / 255, 1 },
    CustomColourNecromancer = { 97 / 255, 37 / 255, 201 / 255, 1 },
    CustomColourArcanist = { 90 / 255, 240 / 255, 80 / 255, 1 },
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
    TargetTitlePriority = GetString(LUIE_STRING_UF_TITLE_PRIORITY),
    TargetEnableTitle = true,
    TargetEnableSkull = true,
    CustomFramesGroup = true,
    GroupExcludePlayer = false,
    GroupBarWidth = 260,
    GroupBarHeight = 36,
    GroupBarSpacing = 40,
    CustomFramesRaid = true,
    RaidNameClip = 94,
    RaidBarWidth = 220,
    RaidBarHeight = 30,
    RaidLayout = GetString(LUIE_STRING_UF_RAID_LAYOUT),
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
    CustomColourPlayer = { 178 / 255, 178 / 255, 1, 1 },
    CustomColourFriendly = { 0, 1, 0, 1 },
    CustomColourHostile = { 1, 0, 0, 1 },
    CustomColourNeutral = { 150 / 255, 150 / 255, 150 / 255, 1 },
    CustomColourGuard = { 95 / 255, 70 / 255, 60 / 255, 1 },
    CustomColourCompanionFrame = { 0, 1, 0, 1 },
    LowResourceHealth = 25,
    LowResourceStamina = 25,
    LowResourceMagicka = 25,
    ShowPlayerDodgePrediction = false,
    PlayerDodgePredictionColor = { 1, 0.92, 0.2, 0.95 },
    ShieldAlpha = 50,
    ReverseResourceBars = false,
    CustomFramesPet = true,
    CustomFormatPet = GetString(LUIE_STRING_UF_FORMAT_PET),
    CustomColourPet = { 202 / 255, 20 / 255, 0, 1 },
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
    CustomFormatCompanion = GetString(LUIE_STRING_UF_FORMAT_COMPANION),
    CustomColourCompanion = { 202 / 255, 20 / 255, 0, 1 },
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
    BarAlignPlayerHealth = 1,
    BarAlignPlayerMagicka = 1,
    BarAlignPlayerStamina = 1,
    BarAlignTarget = 1,
    BarAlignCenterLabelPlayer = false,
    BarAlignCenterLabelTarget = false,
    CustomFormatCenterLabel = GetString(LUIE_STRING_UF_FORMAT_CENTER_LABEL),
    CustomTargetMarker = false,

    -- Group Resources (LibGroupBroadcast Integration)
    GroupResources =
    {
        enabled = false,
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
        showUltimate = true,
        showDPS = true,
        showHPS = true,
        -- Group (4 player) settings
        ultIconGroupSize = 28,
        ultIconGroupOffsetX = 4,
        ultIconGroupOffsetY = 0,
        -- Raid (12 player) settings
        ultIconRaidSize = 22,
        ultIconRaidOffsetX = 3,
        ultIconRaidOffsetY = 0,
    },

    -- Group Potion Cooldowns (LibGroupPotionCooldowns Integration)
    GroupPotionCooldowns =
    {
        enabled = false,
        showRemainingTime = true,
        -- Group (4 player) settings
        potionIconGroupSize = 24,
        potionIconGroupOffsetX = 4,
        potionIconGroupOffsetY = 0,
        -- Raid (12 player) settings
        potionIconRaidSize = 20,
        potionIconRaidOffsetX = 3,
        potionIconRaidOffsetY = 0,
    },

    -- Group Food & Drink Buffs (LibFoodDrinkBuff Integration)
    GroupFoodDrinkBuff =
    {
        enabled = false,
        showNoBuff = false,
        showRemainingTime = true,
        useCustomIcons = false,
        iconSizeGroup = 24,
        iconOffsetXGroup = 4,
        iconOffsetYGroup = 0,
    },
}

UnitFrames.SV = {}

--- Power row on a custom frame (health/magicka/stamina bar aggregate); includes regen strips when enabled.
--- @class UnitFrames.CustomFramePowerEntry
--- @field regen1 UnitFrames.RegenStripControl|nil
--- @field regen2 UnitFrames.RegenStripControl|nil
--- @field degen1 UnitFrames.RegenStripControl|nil
--- @field degen2 UnitFrames.RegenStripControl|nil
--- @field stat table|nil

--- Per-unit custom frame root (TLW, buff anchors, and numeric COMBAT_MECHANIC_FLAGS_* power rows).
--- @class UnitFrames.CustomFrameUnitEntry
--- @field buffs Control|nil
--- @field debuffs Control|nil
--- @field tlw LUIE_PositionableTopLevelWindow|nil
--- @field [number] UnitFrames.CustomFramePowerEntry

--- Frame data tables are added by _CreateCustomFrames when each frame is created (virtual templates load from XML; instances created at runtime).
--- @class UnitFrames.CustomFramesTable
--- @field [string] UnitFrames.CustomFrameUnitEntry

--- @type UnitFrames.CustomFramesTable
UnitFrames.CustomFrames =
{
}
UnitFrames.CustomFramesMovingState = false
UnitFrames.reticleoverHostile = false  -- boolean: hostile target and TargetEnableSkull (avoids assign-type-mismatch on frame.hostile)
UnitFrames.targetFrameLingered = false -- true after we have shown a valid target; prevents blank frame/icons on load when TargetLingerInCursorMode is on
UnitFrames.targetLingerTimeoutName = UnitFrames.moduleName .. "TargetLingerTimeout"
UnitFrames.targetLingerTimerActive = false
