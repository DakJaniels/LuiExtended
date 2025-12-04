-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- ActionBar namespace
--- @class (partial) LUIE.ActionBar
local ActionBar = {}
ActionBar.__index = ActionBar
--- @class (partial) LUIE.ActionBar
LUIE.ActionBar = ActionBar

-- Module state
ActionBar.Enabled = false
ActionBar.SV = {}
ActionBar.CastBarUnlocked = false

-- Module defaults
ActionBar.Defaults =
{
    GlobalShowGCD = false,
    GlobalPotion = false,
    GlobalFlash = true,
    GlobalDesat = false,
    GlobalLabelColor = false,
    GlobalMethod = 2, -- Vertical Reveal (was 3, now 2 after removing non-working "Vertical" option)
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
    RemainingTextColoured = false,
    RemainingTextColorHigh = { 0.878, 0.941, 0.251, 1 },
    RemainingTextColorMid = { 0.941, 0.565, 0.251, 1 },
    RemainingTextColorLow = { 0.941, 0.251, 0.125, 1 },
    RemainingTextColorThresholdMid = 0.5,
    RemainingTextColorThresholdLow = 0.25,
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
    PotionTimerTextColorHigh = { 0.878, 0.941, 0.251, 1 },
    PotionTimerTextColorMid = { 0.941, 0.565, 0.251, 1 },
    PotionTimerTextColorLow = { 0.251, 0.941, 0.125, 1 },
    PotionTimerTextColorThresholdMid = 15000,
    PotionTimerTextColorThresholdLow = 5000,
    PotionTimerMillis = true,
    durationOverrides = {},
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
    CastBarHeavy = false,
    blacklist = {},
}
