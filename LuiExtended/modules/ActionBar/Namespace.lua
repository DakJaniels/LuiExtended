-- -----------------------------------------------------------------------------
--  LuiExtended — ActionBar namespace, defaults, and module constants
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
--- @field ActionBar LUIE.ActionBar
--- @field GetSlotTrueBoundId fun(actionSlotIndex: integer, hotbarCategory: integer): integer
--- @field GetPositionLabelFont fun(): string
--- @field StatusbarTextures table<string, string>
local LUIE = LUIE

-- ActionBar namespace
--- @class ActionButton
--- @field slot table
--- @field button table
--- @field flipCard table
--- @field icon table
--- @field glow table
--- @field slotNum number
--- @field cooldownCompleteAnim ActionButtonCooldownCompleteAnim

--- Control for cooldown-complete animation; holds optional animation object (see ESO ActionButton.lua).
--- @class ActionButtonCooldownCompleteAnim : Control
--- @field animation? table

--- RGBA color tuple (0-1). Used for cast bar gradient, etc.
--- @alias AB_Color number[]

--- Custom list table (ability blacklist, etc.): keys integer or string, value true.
--- @alias AB_CustomList table<integer|string, boolean>

--- @class (partial) LUIE.ActionBar
local ActionBar = {}
ActionBar.__index = ActionBar
--- @class (partial) LUIE.ActionBar
LUIE.ActionBar = ActionBar

ActionBar.ModuleName = LUIE.name .. "ActionBar"

--- @class (partial) LUIE.ActionBar.CastBar
ActionBar.CastBar =
{
    name = LUIE.name .. "ActionBar" .. "CastBar",
}

--- @class (partial) LUIE.ActionBar.Backbar
ActionBar.Backbar =
{
    name = LUIE.name .. "ActionBar" .. "Backbar",
}

ActionBar.Enabled = false

ActionBar.Defaults =
{
    blacklist = {},
    GlobalShowGCD = false,
    GlobalPotion = false,
    GlobalFlash = true,
    GlobalDesat = false,
    GlobalLabelColor = false,
    GlobalMethod = 2,
    UltimateLabelEnabled = true,
    UltimatePctEnabled = true,
    UltimateHideFull = true,
    UltimateGeneration = true,
    UltimateLabelPosition = -20,
    UltimateFontFace = "LUIE Default Font",
    UltimateFontStyle = FONT_STYLE_OUTLINE,
    UltimateFontSize = 18,
    ShowTriggered = true,
    ProcEnableSound = true,
    ProcSoundName = "Death Recap Killing Blow",
    ShowToggled = true,
    ShowToggledUltimate = true,
    BarShowLabel = true,
    BarLabelPosition = -20,
    BarFontFace = "LUIE Default Font",
    BarFontStyle = FONT_STYLE_OUTLINE,
    BarFontSize = 18,
    BarMillis = true,
    BarMillisAboveTen = true,
    BarMillisThreshold = 10,
    BarShowBack = false,
    BarDarkUnused = false,
    BarDesaturateUnused = false,
    BarHideUnused = false,
    PotionTimerShow = true,
    PotionTimerLabelPosition = 0,
    PotionTimerFontFace = "LUIE Default Font",
    PotionTimerFontStyle = FONT_STYLE_OUTLINE,
    PotionTimerFontSize = 18,
    PotionTimerColor = true,
    PotionTimerMillis = true,
    CastBarEnable = false,
    CastBarSizeW = 300,
    CastBarSizeH = 22,
    CastBarIconSize = 32,
    CastBarTexture = "Plain",
    CastBarLabel = true,
    CastBarTimer = true,
    CastBarFontFace = "LUIE Default Font",
    CastBarFontStyle = FONT_STYLE_SOFT_SHADOW_THICK,
    CastBarFontSize = 16,
    CastBarGradientC1 = { 0, 47 / 255, 130 / 255, 1 },
    CastBarGradientC2 = { 82 / 255, 215 / 255, 1, 1 },
    CastBarIconFrameColor = { 0, 0, 0, 1 },
    CastBarHeavy = false,
    CastBarTimerFormat = 1,
    CastBarWeaveHelper = false,
    CastBarWeaveThresholdMs = 80,
    CastbarOffsetX = nil,
    CastbarOffsetY = nil,
    CastBarCustomPosition = nil,
    CompanionUltimateLabelEnabled = true,
    CompanionUltimatePctEnabled = true,
    CompanionUltimateHideFull = true,
    CompanionUltimateLabelPosition = -20,
    CompanionUltimateFontFace = "LUIE Default Font",
    CompanionUltimateFontStyle = FONT_STYLE_OUTLINE,
    CompanionUltimateFontSize = 18,
    CompanionUltimateColorDefault = { 0.941, 0.973, 0.957, 1 },
    CompanionUltimateColor100 = { 0.878, 0.941, 0.251, 1 },
    CompanionUltimateColor80 = { 0.941, 0.565, 0.251, 1 },
    CompanionUltimateColor50 = { 0.941, 0.251, 0.125, 1 },
    oocAlpha = 100,
    incAlpha = 100,
}

ActionBar.SV = ...
ActionBar.CastBarUnlocked = false

ActionBar.BAR_INDEX_START = 3
ActionBar.BAR_INDEX_END = 8
ActionBar.BACKBAR_INDEX_END = 7
ActionBar.BACKBAR_INDEX_OFFSET = 50
ActionBar.OAKENSOUL_RING_ITEM_ID = 187658

ActionBar.DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE =
{
    [ACTION_TYPE_ABILITY] = IsValidAbilityForSlot,
    [ACTION_TYPE_CRAFTED_ABILITY] = IsValidCraftedAbilityForSlot,
}

--- Cooldown animation types for GCD tracking (keys match ActionBar.SV.GlobalMethod).
--- @enum AB_CooldownMethod
ActionBar.CooldownMethod =
{
    [1] = CD_TYPE_RADIAL,
    [2] = CD_TYPE_VERTICAL_REVEAL,
}

ActionBar.ULTIMATE_SLOT_INDEX = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1

-- Runtime label/UI state (colour thresholds are static; controls attached in ActionBar.lua)
ActionBar.uiQuickSlot =
{
    colour = { 0.941, 0.565, 0.251, 1 },
    timeColours =
    {
        [1] = { remain = 15000, colour = { 0.878, 0.941, 0.251, 1 } },
        [2] = { remain = 5000, colour = { 0.251, 0.941, 0.125, 1 } },
    },
}

ActionBar.uiUltimate =
{
    colour = { 0.941, 0.973, 0.957, 1 },
    pctColours =
    {
        [1] = { pct = 100, colour = { 0.878, 0.941, 0.251, 1 } },
        [2] = { pct = 80, colour = { 0.941, 0.565, 0.251, 1 } },
        [3] = { pct = 50, colour = { 0.941, 0.251, 0.125, 1 } },
    },
    FadeTime = 0,
    NotFull = false,
}

ActionBar.uiCompanionUltimate =
{
    LabelVal = nil, --- @type LabelControl
    LabelPct = nil, --- @type LabelControl
    FadeTime = 0,
    NotFull = false,
}

--- @class LUIE_ACTIONBAR_GAMEPAD_CONSTANTS
ActionBar.GAMEPAD_CONSTANTS =
{
    abilitySlotOffsetX = 10,
    ultimateSlotOffsetX = 65,
    quickslotOffsetXFromCompanionUltimate = 45,
    quickslotOffsetXFromFirstSlot = 5,
    backbarHeightMultiplier = 1.6,
    backbarOffsetMultiplier = 0.8,
    backbarRowGap = -4,
    backRowSlotOffsetY = -17,
    backRowUltimateSlotOffsetY = -30,
    keybindBGWidth = 580,
    keybindBGWidthWithoutCompanion = 512,
    keybindBGHeight = 64,
    keybindBGAnchorOffsetX = -34,
    keybindBGAnchorOffsetXWithoutCompanion = 0,
    weaponSwapOffsetX = 61,
    weaponSwapOffsetY = 4,
}

--- @class LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
ActionBar.KEYBOARD_CONSTANTS =
{
    abilitySlotOffsetX = 2,
    ultimateSlotOffsetX = 62,
    quickslotOffsetXFromCompanionUltimate = 18,
    quickslotOffsetXFromFirstSlot = 5,
    backbarHeightMultiplier = 1.0,
    backbarOffsetMultiplier = 0.8,
    backbarRowGap = 0,
    backRowSlotOffsetY = -17,
    backRowUltimateSlotOffsetY = -20,
    keybindBGWidth = 580,
    keybindBGWidthWithoutCompanion = 512,
    keybindBGHeight = 64,
    keybindBGAnchorOffsetX = -34,
    keybindBGAnchorOffsetXWithoutCompanion = 0,
    weaponSwapOffsetX = 59,
    weaponSwapOffsetY = -4,
}

function ActionBar.AttachPlatformWeaponSwap(actionBar)
    local weaponSwap = actionBar:GetNamedChild("WeaponSwap")
    ActionBar.GAMEPAD_CONSTANTS.weaponSwapControl = weaponSwap
    ActionBar.KEYBOARD_CONSTANTS.weaponSwapControl = weaponSwap
end

ActionBar.isStackCounter =
{
    [61905] = true,
    [61928] = true,
    [61920] = true,
    [107054] = true,
    [107055] = true,
    [130293] = true,
}

ActionBar.isStackBaseAbility =
{
    [61902] = true,
    [61927] = true,
    [61919] = true,
    [24165] = true,
}

ActionBar.PROC_SOUND_THRESHOLDS =
{
    [122585] = { 5, 10 },
    [122587] = { 4, 10 },
    [122586] = { 5, 10 },
    [203447] = { 4, 8 },
}

ActionBar.ACTION_BUTTON_BGS = { ability = "EsoUI/Art/ActionBar/abilityInset.dds", item = "EsoUI/Art/ActionBar/quickslotBG.dds" }
ActionBar.ACTION_BUTTON_BORDERS = { normal = "EsoUI/Art/ActionBar/abilityFrame64_up.dds", mouseDown = "EsoUI/Art/ActionBar/abilityFrame64_down.dds" }
ActionBar.FORCE_SUPPRESS_COOLDOWN_SOUND = true
ActionBar.BOUNCE_DURATION_MS = 500
