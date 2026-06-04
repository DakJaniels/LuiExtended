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
--- @class ActionButtonCooldownCompleteAnim
--- @field animation? table

--- RGBA color tuple (0-1). Used for cast bar gradient, etc.
--- @alias AB_Color number[]

--- Custom list table (ability blacklist, etc.): keys integer or string, value true.
--- @alias AB_CustomList table<integer|string, boolean>

--- @class (partial) LUIE.ActionBar
--- @field Enabled boolean
--- @field Defaults ActionBarDefaults
--- @field CastBarUnlocked boolean
--- @field ModuleName string
--- @field BAR_INDEX_START integer
--- @field BAR_INDEX_END integer
--- @field BACKBAR_INDEX_END integer
--- @field BACKBAR_INDEX_OFFSET integer
--- @field OAKENSOUL_RING_ITEM_ID integer
--- @field CooldownMethod table<integer, integer>
--- @field DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE table<integer, function>
--- @field ULTIMATE_SLOT_INDEX integer
--- @field uiQuickSlot table
--- @field uiUltimate table
--- @field uiCompanionUltimate table
--- @field GAMEPAD_CONSTANTS LUIE_ACTIONBAR_GAMEPAD_CONSTANTS
--- @field KEYBOARD_CONSTANTS LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
--- @field AttachPlatformWeaponSwap fun(actionBar: table)
--- @field isStackCounter table<integer, true>
--- @field isStackBaseAbility table<integer, true>
--- @field PROC_SOUND_THRESHOLDS table<integer, integer[]>
--- @field ACTION_BUTTON_BGS table<string, string>
--- @field ACTION_BUTTON_BORDERS table<string, string>
--- @field FORCE_SUPPRESS_COOLDOWN_SOUND boolean
--- @field BOUNCE_DURATION_MS integer
--- @field RegisterBarCombatEvent fun(eventManager: table, eventNamesList: string[], eventName: string, ...)
--- @field Initialize fun(enabled: boolean)
--- @field SetupBackBarIcons fun(button: ActionButton, flip: boolean)
--- @field OnActiveWeaponPairChanged fun(activeWeaponPair: ActiveWeaponPair, locked: boolean)
--- @field HookGCD fun()
--- @field UpdateBarHighlightTables fun()
--- @field RegisterEvents fun()
--- @field ClearCustomList fun(list: AB_CustomList)
--- @field AddToCustomList fun(list: AB_CustomList, input: any)
--- @field RemoveFromCustomList fun(list: AB_CustomList, input: any)
--- @field OnPlayerActivated fun()
--- @field OnUpdate fun(currentTimeMS: number)
--- @field OnGameCameraUIModeChanged fun()
--- @field OnSiegeEnd fun()
--- @field OnAbilityUsed fun(actionSlotIndex: number)
--- @field StopCastBar fun()
--- @field OnUpdateCastbar fun(currentTimeMS: number)
--- @field ApplyDisplayAlpha fun()
--- @field ApplyFont fun()
--- @field CastBar LUIE.ActionBar.CastBar
--- @field Backbar LUIE.ActionBar.Backbar
--- @field GetHotbarCategory fun(): integer
--- @field SetHotbarCategory fun(category: integer)
--- @field GetHeldWeaponPair fun(): ActiveWeaponPair
--- @field GetCustomToggleControl fun(slotNum: number): table?
--- @field ApplyProcSound fun(previewMenuContext: table?)
--- @field ResetUltimateLabel fun()
--- @field ResetBarLabel fun()
--- @field ResetPotionTimerLabel fun()
--- @field OnTargetChange fun(unitTag: string)
--- @field OnReticleHiddenUpdate fun(hidden: boolean)
--- @field OnReticleTargetChanged fun()
--- @field BarHighlightSwap fun(abilityId: number)
--- @field OnEffectChanged fun(changeType: number, effectSlot: number, effectName: string, unitTag: string, beginTime: number, endTime: number, stackCount: number, iconName: string, deprecatedBuffType: number, effectType: number, abilityType: number, statusEffectType: number, unitName: string, unitId: number, abilityId: number, sourceType: number, passThrough: table?, savedId: number?)
--- @field HideSlot fun(slotNum: number, abilityId: number)
--- @field ShowSlot fun(slotNum: number, abilityId: number, currentTimeMS: number?, desaturate: boolean?)
--- @field BackbarHideSlot fun(slotNum: number)
--- @field BackbarShowSlot fun(slotNum: number)
--- @field ToggleBackbarSaturation fun(slotNum: number, desaturate: boolean)
--- @field BackbarSetupTemplate fun()
--- @field BackbarToggleSettings fun()
--- @field CreateCastBar fun()
--- @field ResizeCastBar fun()
--- @field UpdateCastBar fun()
--- @field ResetCastBarPosition fun()
--- @field GetCastBarOffsetX fun(): number
--- @field GetCastBarOffsetY fun(): number
--- @field SetCastBarPosition fun()
--- @field SetMovingState fun(state: boolean)
--- @field GenerateCastbarPreview fun(state: boolean)
--- @field ClientInteractResult fun(eventCode: number, result: number, interactTargetName: string)
--- @field SoulGemResurrectionStart fun(durationMs: number)
--- @field SoulGemResurrectionEnd fun()
--- @field OnCombatEventBreakCast fun(result: number, isError: boolean, abilityName: string, abilityGraphic: number, abilityActionSlotType: number, sourceName: string, sourceType: number, targetName: string, targetType: number, hitValue: number, powerType: number, damageType: number, log: string, sourceUnitId: number, targetUnitId: number, abilityId: number, overflow: number)
--- @field OnCombatEvent fun(result: number, isError: boolean, abilityName: string, abilityGraphic: number, abilityActionSlotType: number, sourceName: string, sourceType: number, targetName: string, targetType: number, hitValue: number, powerType: number, damageType: number, log: string, sourceUnitId: number, targetUnitId: number, abilityId: number, overflow: number)
--- @field OnCombatEventSpecialFilters fun(eventCode: number, result: number, isError: boolean, abilityName: string, abilityGraphic: number, abilityActionSlotType: number, sourceName: string, sourceType: number, targetName: string, targetType: number, hitValue: number, powerType: number, damageType: number, log: string, sourceUnitId: number, targetUnitId: number, abilityId: number)
--- @field OnCombatEventBar fun(result: number, isError: boolean, abilityName: string, abilityGraphic: number, abilityActionSlotType: number, sourceName: string, sourceType: number, targetName: string, targetType: number, hitValue: number, powerType: number, damageType: number, log: string, sourceUnitId: number, targetUnitId: number, abilityId: number, overflow: number)
--- @field OnSlotUpdated fun(actionSlotIndex: number)
--- @field BarSlotUpdate fun(slotNum: number, wasFullUpdate: boolean, onlyProc: boolean)
--- @field UpdateUltimateLabel fun()
--- @field UpdateCompanionUltimateLabel fun(optionalCurrentPower: number?)
--- @field ResetCompanionUltimateLabel fun()
--- @field RefreshCompanionQuickslotAnchors fun()
--- @field CreateCompanionUltimateLabels fun()
--- @field OnPowerUpdateCompanion fun(unitTag: string, powerIndex: luaindex?, powerType: CombatMechanicFlags, powerValue: integer, powerMax: integer, powerEffectiveMax: integer)
--- @field InventoryItemUsed fun()
--- @field OnActiveHotbarUpdate fun(didActiveHotbarChange: boolean, shouldUpdateAbilityAssignments: boolean, activeHotbarCategory: number)
--- @field OnSlotsFullUpdate fun()
--- @field PlayProcAnimations fun(slotNum: number)
--- @field OnDeath fun(unitTag: string, isDead: boolean)
--- @field ShowCustomToggle fun(slotNum: number)
--- @field OnPowerUpdatePlayer fun(unitTag: string, powerIndex: number?, powerType: number, powerValue: number, powerMax: number, powerEffectiveMax: number)
--- @field OnInventorySlotUpdate fun(bagId: Bag, slotIndex: number, isNewItem: boolean, itemSoundCategory: ItemUISoundCategory, inventoryUpdateReason: number, stackCountChange: number, triggeredByCharacterName: string?, triggeredByDisplayName: string?, isLastUpdateForMessage: boolean, bonusDropSource: BonusDropSource)
local ActionBar = {}
ActionBar.__index = ActionBar
--- @class (partial) LUIE.ActionBar
LUIE.ActionBar = ActionBar

ActionBar.ModuleName = LUIE.name .. "ActionBar"

--- @class (partial) LUIE.ActionBar.CastBar
--- @field name string
--- @field g_castCombatEventNames string[]
--- @field RegisterEvents fun()
--- @field UnregisterEvents fun()
--- @field Initialize fun()
--- @field ApplyDisplayAlpha fun(alpha: number)
--- @field ApplyFont fun(fontString: string)
--- @field TickInterruptChecks fun()
--- @field StopForAbilitySlot fun(actionSlotIndex: number)
--- @field OnActionSlotAbilityUsed fun(actionSlotIndex: number)
--- @field OnEffectChanged fun(changeType: number, effectSlot: integer, effectName: string, unitTag: string, beginTime: number, endTime: number, stackCount: integer, iconName: string, deprecatedBuffType: integer, effectType: integer, abilityType: integer, statusEffectType: integer, unitName: string, unitId: integer, abilityId: integer, sourceType: integer, passThrough: boolean, savedId: integer)
--- @field HandleCombatEvent fun(result: number, isError: boolean, abilityName: string, abilityGraphic: number, abilityActionSlotType: number, sourceName: string, sourceType: number, targetName: string, targetType: number, hitValue: number, powerType: number, damageType: number, log: string, sourceUnitId: number, targetUnitId: number, abilityId: number, overflow: number)
--- @field OnEffectCastBreak fun(abilityId: number, changeType: number): boolean
--- @field OnLibCombatSkillTimings fun(eventCode: integer, timems: number, reducedSlot: integer, abilityId: integer, skillStatus: integer, skillDelay: number, skillDuration: number)
--- @field usesLibCombatSkillTimings boolean
--- @field RegisterLibCombatEvents fun()
--- @field UnregisterLibCombatEvents fun()
--- @field ShouldShowOnCastBar fun(abilityId: integer, castAbilityName: string|nil): boolean
--- @field HideWeaveLines fun()
--- @field GetWeaveLineWidth fun(): string
--- @field UpdateWeaveLineDimensions fun()
--- @field ResetWeaveBackdropEdge fun()
--- @field Private table
--- @field ComputeCastDurationMs fun(abilityId: integer, result: number, hitValue: integer, channeled: boolean, castTime: integer): integer
--- @field ShowCast fun(abilityId: integer, startTimeMs: number, durationMs: integer, channeled: boolean, castAbilityIcon: string|nil, castAbilityName: string|nil, startedFromLibCombat: boolean|nil)
ActionBar.CastBar =
{
    name = LUIE.name .. "ActionBar" .. "CastBar",
}

--- @class (partial) LUIE.ActionBar.Backbar
--- @field CreateUI fun()
--- @field RegisterPlatformStyle fun()
--- @field RegisterEvents fun()
--- @field GetButton fun(slotNum: number): ActionButton?
--- @field GetButtons fun(): table
--- @field UpdateButtonActionIds fun()
--- @field HideAllAbilityActionButtonDropCallouts fun()
--- @field ShowAppropriateAbilityActionButtonDropCallouts fun(actionType: integer, actionValue: integer)
--- @field OnPlayerActivatedScan fun()
--- @field OnSetHotbarEffect fun(changeType: number): boolean
--- @field GetInactiveHotbarCategory fun(): HotBarCategory
--- @field UpdateActivationHighlight fun(luiSlotNum: number)
--- @field RefreshAllActivationHighlights fun()
--- @field OnPhysicalSlotVisualSync fun(physicalSlotIndex: number)
ActionBar.Backbar =
{
    name = LUIE.name .. "ActionBar" .. "Backbar",
}

--- Default settings for ActionBar module (saved vars shape).
--- @class ActionBarDefaults
--- @field blacklist AB_CustomList
--- @field GlobalShowGCD boolean
--- @field GlobalPotion boolean
--- @field GlobalFlash boolean
--- @field GlobalDesat boolean
--- @field GlobalLabelColor boolean
--- @field GlobalMethod integer
--- @field UltimateLabelEnabled boolean
--- @field UltimatePctEnabled boolean
--- @field UltimateHideFull boolean
--- @field UltimateGeneration boolean
--- @field UltimateLabelPosition integer
--- @field UltimateFontFace string
--- @field UltimateFontStyle FontStyle
--- @field UltimateFontSize integer
--- @field ShowTriggered boolean
--- @field ProcEnableSound boolean
--- @field ProcSoundName string
--- @field ShowToggled boolean
--- @field ShowToggledUltimate boolean
--- @field BarShowLabel boolean
--- @field BarLabelPosition integer
--- @field BarFontFace string
--- @field BarFontStyle FontStyle
--- @field BarFontSize integer
--- @field BarMillis boolean
--- @field BarMillisAboveTen boolean
--- @field BarMillisThreshold integer
--- @field BarShowBack boolean
--- @field BarDarkUnused boolean
--- @field BarDesaturateUnused boolean
--- @field BarHideUnused boolean
--- @field PotionTimerShow boolean
--- @field PotionTimerLabelPosition integer
--- @field PotionTimerFontFace string
--- @field PotionTimerFontStyle FontStyle
--- @field PotionTimerFontSize integer
--- @field PotionTimerColor boolean
--- @field PotionTimerMillis boolean
--- @field CastBarEnable boolean
--- @field CastBarSizeW number
--- @field CastBarSizeH number
--- @field CastBarIconSize number
--- @field CastBarTexture string
--- @field CastBarLabel boolean
--- @field CastBarTimer boolean
--- @field CastBarFontFace string
--- @field CastBarFontStyle FontStyle
--- @field CastBarFontSize integer
--- @field CastBarGradientC1 AB_Color
--- @field CastBarGradientC2 AB_Color
--- @field CastBarHeavy boolean
--- @field CastBarTimerFormat integer
--- @field CastBarWeaveHelper boolean
--- @field CastBarWeaveThresholdMs integer
--- @field CastbarOffsetX number | nil
--- @field CastbarOffsetY number | nil
--- @field CastBarCustomPosition table | nil
--- @field CompanionUltimateLabelEnabled boolean
--- @field CompanionUltimatePctEnabled boolean
--- @field CompanionUltimateHideFull boolean
--- @field CompanionUltimateLabelPosition integer
--- @field CompanionUltimateFontFace string
--- @field CompanionUltimateFontStyle FontStyle
--- @field CompanionUltimateFontSize integer
--- @field CompanionUltimateColorDefault AB_Color
--- @field CompanionUltimateColor100 AB_Color
--- @field CompanionUltimateColor80 AB_Color
--- @field CompanionUltimateColor50 AB_Color
--- @field oocAlpha number
--- @field incAlpha number

ActionBar.Enabled = false
--- @type ActionBarDefaults
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

--- @type ActionBarDefaults
ActionBar.SV = ...
ActionBar.CastBarUnlocked = false

-- Slot / backbar indices (match ZOS action bar layout used throughout this module)
ActionBar.BAR_INDEX_START = 3
ActionBar.BAR_INDEX_END = 8
ActionBar.BACKBAR_INDEX_END = 7
ActionBar.BACKBAR_INDEX_OFFSET = 50
ActionBar.OAKENSOUL_RING_ITEM_ID = 187658

--- Drop callout validity (mirrors ZOS ZO_ABILITY_DROP_CALLOUT_VALIDITY_FUNCTION_BY_ACTION_TYPE)
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
    LabelVal = nil,
    LabelPct = nil,
    FadeTime = 0,
    NotFull = false,
}

--- @class LUIE_ACTIONBAR_GAMEPAD_CONSTANTS
--- @field abilitySlotOffsetX number
--- @field ultimateSlotOffsetX number
--- @field quickslotOffsetXFromCompanionUltimate number
--- @field quickslotOffsetXFromFirstSlot number
--- @field backbarHeightMultiplier number
--- @field backbarOffsetMultiplier number
--- @field keybindBGWidth number
--- @field keybindBGWidthWithoutCompanion number
--- @field keybindBGHeight number
--- @field keybindBGAnchorOffsetX number
--- @field keybindBGAnchorOffsetXWithoutCompanion number
--- @field weaponSwapControl table?
--- @field weaponSwapOffsetX number
--- @field weaponSwapOffsetY number

--- @class LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
--- @field abilitySlotOffsetX number
--- @field ultimateSlotOffsetX number
--- @field quickslotOffsetXFromCompanionUltimate number
--- @field quickslotOffsetXFromFirstSlot number
--- @field backbarHeightMultiplier number
--- @field backbarOffsetMultiplier number
--- @field keybindBGWidth number
--- @field keybindBGWidthWithoutCompanion number
--- @field keybindBGHeight number
--- @field keybindBGAnchorOffsetX number
--- @field keybindBGAnchorOffsetXWithoutCompanion number
--- @field weaponSwapControl table?
--- @field weaponSwapOffsetX number
--- @field weaponSwapOffsetY number

--- @type LUIE_ACTIONBAR_GAMEPAD_CONSTANTS
ActionBar.GAMEPAD_CONSTANTS =
{
    abilitySlotOffsetX = 10,
    ultimateSlotOffsetX = 65,
    quickslotOffsetXFromCompanionUltimate = 45,
    quickslotOffsetXFromFirstSlot = 5,
    backbarHeightMultiplier = 1.6,
    backbarOffsetMultiplier = 0.8,
    keybindBGWidth = 580,
    keybindBGWidthWithoutCompanion = 512,
    keybindBGHeight = 64,
    keybindBGAnchorOffsetX = -34,
    keybindBGAnchorOffsetXWithoutCompanion = 0,
    weaponSwapOffsetX = 61,
    weaponSwapOffsetY = 4,
}

--- @type LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
ActionBar.KEYBOARD_CONSTANTS =
{
    abilitySlotOffsetX = 2,
    ultimateSlotOffsetX = 62,
    quickslotOffsetXFromCompanionUltimate = 18,
    quickslotOffsetXFromFirstSlot = 5,
    backbarHeightMultiplier = 1.0,
    backbarOffsetMultiplier = 0.8,
    keybindBGWidth = 580,
    keybindBGWidthWithoutCompanion = 512,
    keybindBGHeight = 64,
    keybindBGAnchorOffsetX = -34,
    keybindBGAnchorOffsetXWithoutCompanion = 0,
    weaponSwapOffsetX = 59,
    weaponSwapOffsetY = -4,
}

--- ZO_ActionBar1 must exist; call once from ActionBar.lua after resolving the action bar control.
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
    [122587] = { 5, 10 },
    [122586] = { 5, 10 },
    [203447] = { 4, 8 },
}

ActionBar.ACTION_BUTTON_BGS = { ability = "EsoUI/Art/ActionBar/abilityInset.dds", item = "EsoUI/Art/ActionBar/quickslotBG.dds" }
ActionBar.ACTION_BUTTON_BORDERS = { normal = "EsoUI/Art/ActionBar/abilityFrame64_up.dds", mouseDown = "EsoUI/Art/ActionBar/abilityFrame64_down.dds" }
ActionBar.FORCE_SUPPRESS_COOLDOWN_SOUND = true
ActionBar.BOUNCE_DURATION_MS = 500
