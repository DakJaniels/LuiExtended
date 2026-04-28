--- @diagnostic disable: duplicate-doc-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- ActionBar namespace
--- ZOS action button (ZO_ActionBar); minimal stub for type references in this module.
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
--- @field ApplyFont fun()
--- @field ApplyProcSound fun(menu: table?)
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
--- @field BarSlotUpdate fun(slotNum: number, wasfullUpdate: boolean, onlyProc: boolean)
--- @field UpdateUltimateLabel fun()
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
LUIE.ActionBar = ActionBar

local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Abilities = Data.Abilities
local Castbar = Data.CastBarTable
local OtherAddonCompatability = LUIE.OtherAddonCompatability

local pairs = pairs
local printToChat = LUIE.PrintToChat
local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local GetAbilityDuration = GetAbilityDuration
local zo_strformat = zo_strformat
local string_format = string.format

local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()
local animationManager = GetAnimationManager()
local chatSystem = ZO_GetChatSystem()

local moduleName = LUIE.name .. "ActionBar"

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
--- @field CastbarOffsetX number | nil
--- @field CastbarOffsetY number | nil
--- @field CastBarCustomPosition table | nil

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
    CastbarOffsetX = nil,
    CastbarOffsetY = nil,
    CastBarCustomPosition = nil,
}

--- @type ActionBarDefaults
ActionBar.SV = ...
ActionBar.CastBarUnlocked = false

local isFancyActionBarEnabled = OtherAddonCompatability.isFancyActionBarPlusEnabled or LUIE.IsItEnabled("FancyActionBar\43") or LUIE.IsItEnabled("FancyActionBar")
local uiTlw = {}                                          -- GUI
local castbar = {}                                        -- castbar
local g_casting = false                                   -- Toggled when casting - prevents additional events from creating a cast bar until finished
local g_ultimateCost = 0                                  -- Cost of ultimate Ability in Slot
local g_ultimateCurrent = 0                               -- Current ultimate value
local g_ultimateSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 -- Ultimate slot number
local g_uiProcAnimation = {}                              -- Animation for bar slots
--- @type table<number, any>
local g_uiCustomToggle = {}                               -- Toggle slots for bar Slots (value: control or true placeholder)
--- Returns the custom toggle control for slotNum, or nil if missing or still a placeholder.
local function GetCustomToggleControl(slotNum)
    local t = g_uiCustomToggle[slotNum]
    return (t and t ~= true) and t or nil
end
local g_triggeredSlotsFront = {}                   -- Triggered bar highlight slots
local g_triggeredSlotsBack = {}                    -- Triggered bar highlight slots
--- @type table<number, number>
local g_triggeredSlotsRemain = {}                  -- Table of remaining durations on proc abilities
local g_toggledSlotsBack = {}                      -- Toggled bar highlight slots
local g_toggledSlotsFront = {}                     -- Toggled bar highlight slots
--- @type table<number, number>
local g_toggledSlotsRemain = {}                    -- Table of remaining durations on active abilities
--- @type table<number, number>
local g_toggledSlotsStack = {}                     -- Table of stacks for active abilities
--- @type table<number, boolean>
local g_toggledSlotsPlayer = {}                    -- Table of abilities that target the player (bar highlight doesn't fade on reticleover change)
local g_potionUsed = false                         -- Toggled on when a potion is used to prevent OnSlotsFullUpdate from updating timers.
--- @type {[integer]:boolean}
local g_barOverrideCI = {}                         -- Table for storing abilityId's from Effects.BarHighlightOverride that should show as an aura
--- @type {[integer]:boolean}
local g_barFakeAura = {}                           -- Table for storing abilityId's that only display a fakeaura
--- @type {[integer]:number}
local g_barDurationOverride = {}                   -- Table for storing abilitiyId's that ignore ending event
--- @type {[integer]:boolean}
local g_barNoRemove = {}                           -- Table of abilities we don't remove from bar highlight
--- @type {[integer]:number}
local g_protectAbilityRemoval = {}                 -- AbilityId's set to a timestamp here to prevent removal of bar highlight when refreshing ground auras from causing the highlight to fade.
--- @type {[integer]:number}
local g_mineStacks = {}                            -- Individual AbilityId ground mine stack information
--- @type {[integer]:boolean}
local g_mineNoTurnOff = {}                         -- When this variable is true for an abilityId - don't remove the bar highlight for a mine (We we have reticleover target and the mine effect applies on the enemy)
local g_reticleHidden = false                      -- Track if reticle is hidden to skip unnecessary processing
local g_barFont                                    -- Font for Ability Highlight Label
local g_potionFont                                 -- Font for Potion Timer Label
local g_ultimateFont                               -- Font for Ultimate Percentage Label
local g_castbarFont                                -- Font for Castbar Label & Timer
local g_ProcSound                                  -- Proc Sound
local g_boundArmamentsPlayed = {}                  -- Specific variable to lockout Bound Armaments/Grim Focus from playing a proc sound at 5 stacks to only once per 5 seconds.
--- @type {[integer]:boolean}
local g_disableProcSound = {}                      -- When we play a proc sound from a bar ability changing (like power lash) we put a 3 sec ICD on it so it doesn't spam when mousing on/off a target, etc
local g_hotbarCategory = GetActiveHotbarCategory() -- Set on initialization and when we swap weapons to determine the current hotbar category
--- @type {[integer]:ActionButton}
local g_backbarButtons = {}                        -- Table to hold backbar buttons
local g_backbarContainer                           -- Parent control for backbar (used for SETHOTBAR auto-hide)
local g_activeWeaponSwapInProgress = false         -- Toggled on when weapon swapping, TODO: maybe not needed
local g_castbarWorldMapFix = false                 -- Fix for viewing the World Map changing the player coordinates for some reason
local g_actionBarActiveWeaponPair = GetHeldWeaponPair()
local ACTION_BAR = ZO_ActionBar1
local BAR_INDEX_START = 3
local BAR_INDEX_END = 8
local BACKBAR_INDEX_END = 7           -- Separate index for backbar as long as we're not using an ultimate button.
local BACKBAR_INDEX_OFFSET = 50
local OAKENSOUL_RING_ITEM_ID = 187658 -- Oaken soul Ring: disables bar swap

-- Drop callout validity functions (mirrors ZOS ZO_ABILITY_DROP_CALLOUT_VALIDITY_FUNCTION_BY_ACTION_TYPE)
local DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE =
{
    [ACTION_TYPE_ABILITY] = IsValidAbilityForSlot,
    [ACTION_TYPE_CRAFTED_ABILITY] = IsValidCraftedAbilityForSlot,
}

-- -----------------------------------------------------------------------------
-- Quickslot
local uiQuickSlot =
{
    colour = { 0.941, 0.565, 0.251, 1 },
    timeColours =
    {
        [1] = { remain = 15000, colour = { 0.878, 0.941, 0.251, 1 } },
        [2] = { remain = 5000, colour = { 0.251, 0.941, 0.125, 1 } },
    },
}

-- -----------------------------------------------------------------------------
-- Ultimate slot
local uiUltimate =
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

-- -----------------------------------------------------------------------------
-- Cooldown Animation Types for GCD Tracking
--- @enum AB_CooldownMethod
local CooldownMethod =
{
    [1] = CD_TYPE_RADIAL,
    [2] = CD_TYPE_VERTICAL_REVEAL,
}

-- -----------------------------------------------------------------------------

--- @class LUIE_ACTIONBAR_GAMEPAD_CONSTANTS
local GAMEPAD_CONSTANTS =
{
    -- Button spacing
    abilitySlotOffsetX = 10,
    ultimateSlotOffsetX = 65,

    -- Quickslot positioning
    quickslotOffsetXFromCompanionUltimate = 45,
    quickslotOffsetXFromFirstSlot = 5,

    -- Backbar row positioning (dynamic calculation multipliers)
    backbarHeightMultiplier = 1.6, -- ACTION_BAR:GetHeight() * this
    backbarOffsetMultiplier = 0.8, -- Final offset = height * this

    -- KeybindBG dimensions
    keybindBGWidth = 580,
    keybindBGWidthWithoutCompanion = 512,
    keybindBGHeight = 64,
    keybindBGAnchorOffsetX = -34,
    keybindBGAnchorOffsetXWithoutCompanion = 0,

    -- Weapon swap button
    weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap"),
    weaponSwapOffsetX = 61,
    weaponSwapOffsetY = 4,
}

--- @class LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
local KEYBOARD_CONSTANTS =
{
    -- Button spacing
    abilitySlotOffsetX = 2,
    ultimateSlotOffsetX = 62,

    -- Quickslot positioning
    quickslotOffsetXFromCompanionUltimate = 18,
    quickslotOffsetXFromFirstSlot = 5,

    -- Backbar row positioning (dynamic calculation multipliers)
    backbarHeightMultiplier = 1.0, -- ACTION_BAR:GetHeight() * this
    backbarOffsetMultiplier = 0.8, -- Final offset = height * this

    -- KeybindBG dimensions
    keybindBGWidth = 580,
    keybindBGWidthWithoutCompanion = 512,
    keybindBGHeight = 64,
    keybindBGAnchorOffsetX = -34,
    keybindBGAnchorOffsetXWithoutCompanion = 0,

    -- Weapon swap button
    weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap"),
    weaponSwapOffsetX = 59,
    weaponSwapOffsetY = -4,
}

--- @return LUIE_ACTIONBAR_GAMEPAD_CONSTANTS | LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
local function GetPlatformConstants()
    return IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
end

-- -----------------------------------------------------------------------------

local slotsUpdated = {}

---
--- @param animation AnimationTimeline
--- @param button ActionButton
--- @param isBackBarSlot boolean
local function OnSwapAnimationHalfDone(animation, button, isBackBarSlot)
    for i = BAR_INDEX_START, BAR_INDEX_END do
        if not slotsUpdated[i] then
            local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]
            ActionBar.BarSlotUpdate(i, false, false)
            ActionBar.BarSlotUpdate(i + BACKBAR_INDEX_OFFSET, false, false)
            -- Don't try to setup back bar ultimate
            if i < 8 then
                ActionBar.SetupBackBarIcons(targetButton, true)
            end
            if i == 8 then
                ActionBar.UpdateUltimateLabel()
            end
            slotsUpdated[i] = true
        end
    end
end

---
--- @param animation AnimationTimeline
--- @param button ActionButton
local function OnSwapAnimationDone(animation, button)
    button.noUpdates = false
    if button:GetSlot() == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 then
        g_activeWeaponSwapInProgress = false
    end
    slotsUpdated = {}
end

--- @param button ActionButton
local function SetupBounceAnimation(button)
    local mainTimeline = animationManager:CreateTimelineFromVirtual("ActionSlotBounceAnimation", button.flipCard)
    local iconTimeline = animationManager:CreateTimelineFromVirtual("ActionSlotBounceAnimation", button.icon)

    button.bounceAnimation = mainTimeline
    button.iconBounceAnimation = iconTimeline

    button.glowAnimation = ZO_AlphaAnimation:New(button.glow)
    button.glowAnimation:SetMinMaxAlpha(0, 1)

    button.needsAnimationParameterUpdate = true
end

---
--- @param button ActionButton
local function SetupSwapAnimation(button)
    button:SetupSwapAnimation(OnSwapAnimationHalfDone, OnSwapAnimationDone)
end

--- Create a single backbar ActionButton (mirrors ESO ActionBar.lua MakeActionButton pattern).
--- @param slotNum integer
--- @param parent Control
--- @param template string
--- @param hotbarCategory number
--- @return integer|ZO_InitializingObject|ActionButton
local function MakeActionButton(slotNum, parent, template, hotbarCategory)
    local button = ActionButton:New(slotNum, ACTION_BUTTON_TYPE_VISIBLE, parent, template, hotbarCategory)
    return button
end

---
--- @param activeHotbarCategory HotBarCategory
--- @return integer
local function GetInactiveHotbarCategory(activeHotbarCategory)
    if activeHotbarCategory == HOTBAR_CATEGORY_PRIMARY then
        return HOTBAR_CATEGORY_BACKUP
    end
    if activeHotbarCategory == HOTBAR_CATEGORY_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end
    if g_actionBarActiveWeaponPair == ACTIVE_WEAPON_PAIR_BACKUP then
        return HOTBAR_CATEGORY_PRIMARY
    end
    return HOTBAR_CATEGORY_BACKUP
end

--- @return boolean
local function OakensoulEquipped()
    return GetItemLinkItemId(GetItemLink(BAG_WORN, EQUIP_SLOT_RING1, LINK_STYLE_DEFAULT)) == OAKENSOUL_RING_ITEM_ID
        or GetItemLinkItemId(GetItemLink(BAG_WORN, EQUIP_SLOT_RING2, LINK_STYLE_DEFAULT)) == OAKENSOUL_RING_ITEM_ID
end

--- Hide drop callouts on main bar and backbar (mirrors ZOS ActionBar drop callout behavior)
local function HideAllAbilityActionButtonDropCallouts()
    for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
        local btn = ZO_ActionBar_GetButton(i)
        if btn and btn.slot then
            local callout = btn.slot:GetNamedChild("DropCallout")
            if callout then
                callout:SetHidden(true)
            end
        end
    end
    if ActionBar.SV.BarShowBack and g_backbarContainer and not g_backbarContainer:IsHidden() then
        for i = BAR_INDEX_START, BACKBAR_INDEX_END do
            local btn = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]
            if btn and btn.slot then
                local callout = btn.slot:GetNamedChild("DropCallout")
                if callout then
                    callout:SetHidden(true)
                end
            end
        end
    end
end

--- Show drop callouts with validity coloring when dragging ability (white=valid, red=invalid)
--- @param actionType number
--- @param actionValue number abilityId or craftedAbilityId
local function ShowAppropriateAbilityActionButtonDropCallouts(actionType, actionValue)
    local validityFunction = DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE[actionType]
    if not validityFunction then
        return
    end

    HideAllAbilityActionButtonDropCallouts()

    -- Main bar
    for i = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1, ACTION_BAR_ULTIMATE_SLOT_INDEX + 1 do
        local btn = ZO_ActionBar_GetButton(i)
        if btn and btn.slot then
            local callout = btn.slot:GetNamedChild("DropCallout")
            if callout then
                local isValid = validityFunction(actionValue, i)
                callout:SetColor(1, isValid and 1 or 0, isValid and 1 or 0, 1)
                callout:SetHidden(false)
            end
        end
    end

    if ActionBar.SV.BarShowBack and g_backbarContainer and not g_backbarContainer:IsHidden() then
        for i = BAR_INDEX_START, BACKBAR_INDEX_END do
            local esoSlotIndex = i - 1
            local btn = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]
            if btn and btn.slot then
                local callout = btn.slot:GetNamedChild("DropCallout")
                if callout then
                    local isValid = validityFunction(actionValue, esoSlotIndex)
                    callout:SetColor(1, isValid and 1 or 0, isValid and 1 or 0, 1)
                    callout:SetHidden(false)
                end
            end
        end
    end
end

local function AttemptPlacement(slotNum, hotbarCategory)
    CallSecureProtected("PlaceInActionBar", slotNum, hotbarCategory)
end

local function AttemptPickup(slotNum, hotbarCategory)
    if ZO_ActionBar_AreActionBarsLocked() then
        return
    end
    CallSecureProtected("PickupAction", slotNum, hotbarCategory)
    ClearTooltip(AbilityTooltip)
end

--- Setup drag/drop handlers for backbar
--- @param button ActionButton
local function SetupBackbarDragDropHandlers(button)
    local btn = button.button
    if not btn then return end

    local function getActionBarSlotAndCategory()
        local slotNum = button.slot.slotNum
        local actionBarSlotIndex = slotNum - BACKBAR_INDEX_OFFSET
        local hotbarCategory = GetInactiveHotbarCategory(g_hotbarCategory)
        return actionBarSlotIndex, hotbarCategory
    end

    btn:SetHandler("OnReceiveDrag", function (control, mouseButton)
        if GetCursorContentType() == MOUSE_CONTENT_EMPTY then return end
        local actionBarSlotIndex, hotbarCategory = getActionBarSlotAndCategory()
        AttemptPlacement(actionBarSlotIndex, hotbarCategory)
    end)

    btn:SetHandler("OnDragStart", function (control, mouseButton)
        if GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then return false end
        if ZO_ActionBar_AreActionBarsLocked() then return false end
        local actionBarSlotIndex, hotbarCategory = getActionBarSlotAndCategory()
        AttemptPickup(actionBarSlotIndex, hotbarCategory)
        ClearTooltip(AbilityTooltip)
        return true
    end)

    -- Tooltip on hover
    btn:SetHandler("OnMouseEnter", function ()
        if IsInGamepadPreferredMode() then return end
        local actionBarSlotIndex, hotbarCategory = getActionBarSlotAndCategory()
        if GetSlotType(actionBarSlotIndex, hotbarCategory) ~= ACTION_TYPE_NOTHING then
            InitializeTooltip(AbilityTooltip, btn, BOTTOM, 0, -5, TOP)
            AbilityTooltip:SetAbilityId(GetSlotTrueBoundId(actionBarSlotIndex, hotbarCategory))
        end
    end)

    btn:SetHandler("OnMouseExit", function ()
        ClearTooltip(AbilityTooltip)
    end)

    -- Right-click context menu (Clear Slot)
    btn:SetHandler("OnClicked", function (control, mouseButton)
        local actionBarSlotIndex, hotbarCategory = getActionBarSlotAndCategory()
        if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
            if IsSlotUsed(actionBarSlotIndex, hotbarCategory) and not IsActionSlotRestricted(actionBarSlotIndex, hotbarCategory) then
                ClearMenu()
                AddMenuItem(GetString(SI_ABILITY_ACTION_CLEAR_SLOT), function ()
                    local slotType = GetSlotType(actionBarSlotIndex, hotbarCategory)
                    if slotType == ACTION_TYPE_ITEM then
                        local soundCategory = GetSlotItemSound(actionBarSlotIndex, hotbarCategory)
                        if soundCategory ~= ITEM_SOUND_CATEGORY_NONE then
                            PlayItemSound(soundCategory, ITEM_SOUND_ACTION_UNEQUIP)
                        end
                    end
                    CallSecureProtected("ClearSlot", actionBarSlotIndex, hotbarCategory)
                end)
                ShowMenu(control)
            end
        elseif mouseButton == MOUSE_BUTTON_INDEX_LEFT and GetCursorContentType() ~= MOUSE_CONTENT_EMPTY then
            AttemptPlacement(actionBarSlotIndex, hotbarCategory)
        end
    end)
end

-- Update actionId for backbar buttons
local function UpdateBackbarButtonActionIds()
    local inactiveHotbarCategory = GetInactiveHotbarCategory(g_hotbarCategory)
    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = g_backbarButtons[i]
        if button and button.button then
            button.button.actionId = GetSlotTrueBoundId(i - BACKBAR_INDEX_OFFSET, inactiveHotbarCategory)
            button.button.hotbarCategory = inactiveHotbarCategory
        end
    end
end

---
--- @param remain number
--- @return string
local function FormatDurationSeconds(remain)
    return string_format((ActionBar.SV.BarMillis and ((remain < ActionBar.SV.BarMillisThreshold * 1000) or ActionBar.SV.BarMillisAboveTen)) and "%.1f" or "%.1d", remain / 1000)
end

-- Module initialization
--- Load saved vars, run migrations, create UI (quickslot/ultimate/backbar/castbar), register events.
--- @param enabled boolean
function ActionBar.Initialize(enabled)
    -- -----------------------------------------------------------------------------
    -- Load settings
    local isCharacterSpecific = LUIESV.Default[GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        ActionBar.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "ActionBar", ActionBar.Defaults)
    else
        ActionBar.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "ActionBar", ActionBar.Defaults)
    end

    -- -----------------------------------------------------------------------------
    -- Migrate from CombatInfo module (one-time migration)
    if not LUIE.IsMigrationDone("actionbar_from_combatinfo") then
        -- Access raw SV table directly
        local rawSV = isCharacterSpecific
            and LUIESV["Default"][GetDisplayName()][GetUnitName("player")]
            or LUIESV["Default"][GetDisplayName()]["$AccountWide"]

        if rawSV and rawSV.CombatInfo then
            local combatInfoTable = rawSV.CombatInfo

            -- List of fields that moved from CombatInfo to ActionBar
            local migrateFields =
            {
                "blacklist", "durationOverrides", "GlobalShowGCD", "GlobalPotion", "GlobalFlash",
                "GlobalDesat", "GlobalLabelColor", "GlobalMethod", "UltimateLabelEnabled",
                "UltimatePctEnabled", "UltimateHideFull", "UltimateGeneration", "UltimateLabelPosition",
                "UltimateFontFace", "UltimateFontStyle", "UltimateFontSize", "ShowTriggered",
                "ProcEnableSound", "ProcSoundName", "showMarker", "markerSize", "ShowToggled",
                "ShowToggledUltimate", "BarShowLabel", "BarLabelPosition", "BarFontFace",
                "BarFontStyle", "BarFontSize", "BarMillis", "BarMillisAboveTen", "BarMillisThreshold",
                "BarShowBack", "BarDarkUnused", "BarDesaturateUnused", "BarHideUnused",
                "PotionTimerShow", "PotionTimerLabelPosition", "PotionTimerFontFace",
                "PotionTimerFontStyle", "PotionTimerFontSize", "PotionTimerColor", "PotionTimerMillis",
                "CastBarEnable", "CastBarSizeW", "CastBarSizeH", "CastBarIconSize", "CastBarTexture",
                "CastBarLabel", "CastBarTimer", "CastBarFontFace", "CastBarFontStyle", "CastBarFontSize",
                "CastBarGradientC1", "CastBarGradientC2", "CastBarHeavy"
            }

            for _, field in ipairs(migrateFields) do
                if combatInfoTable[field] ~= nil then
                    ActionBar.SV[field] = combatInfoTable[field]
                    combatInfoTable[field] = nil
                end
            end
        end

        LUIE.MarkMigrationDone("actionbar_from_combatinfo")
    end

    -- -----------------------------------------------------------------------------
    -- Migrate font styles if needed
    -- Migrate font styles (string/display/nil -> valid 0-7); run once per account
    if not LUIE.IsMigrationDone("actionbar_fontstyles_v2") then
        ActionBar.SV.UltimateFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.UltimateFontStyle)
        ActionBar.SV.BarFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.BarFontStyle)
        ActionBar.SV.PotionTimerFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.PotionTimerFontStyle)
        ActionBar.SV.CastBarFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.CastBarFontStyle)
        LUIE.MarkMigrationDone("actionbar_fontstyles_v2")
    end

    -- -----------------------------------------------------------------------------
    -- Migrate GlobalMethod if it's set to invalid value 3 (removed "Vertical" option)
    if not LUIE.IsMigrationDone("actionbar_globalmethod") then
        if ActionBar.SV.GlobalMethod == 3 then
            ActionBar.SV.GlobalMethod = 2 -- "Vertical Reveal"
        end
        LUIE.MarkMigrationDone("actionbar_globalmethod")
    end

    -- -----------------------------------------------------------------------------
    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    ActionBar.Enabled = true

    -- -----------------------------------------------------------------------------
    ActionBar.ApplyFont()
    ActionBar.ApplyProcSound()

    -- -----------------------------------------------------------------------------
    -- Create Quickslot (Potion) Timer Label
    -- ZO_ActionBar_GetButton always returns the quickslot button when the category is HOTBAR_CATEGORY_QUICKSLOT_WHEEL, so there is no reason to pass in a slot
    local UNUSED = nil
    local quickslotButton = ZO_ActionBar_GetButton(UNUSED, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    local quickslotButtonButton = quickslotButton and quickslotButton.button

    local quickslotLabel = windowManager:CreateControl("$(parent)Label", quickslotButtonButton, CT_LABEL)
    quickslotLabel:SetAnchor(CENTER, quickslotButtonButton, CENTER, 0, 0)
    quickslotLabel:SetFont(g_potionFont or "LUIE Default Font")
    quickslotLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    quickslotLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    quickslotLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    quickslotLabel:SetDrawLayer(DL_OVERLAY)
    quickslotLabel:SetDrawTier(DT_HIGH)
    quickslotLabel:SetHidden(true)
    uiQuickSlot.label = quickslotLabel

    if ActionBar.SV.PotionTimerColor then
        quickslotLabel:SetColor(unpack(uiQuickSlot.colour))
    else
        quickslotLabel:SetColor(1, 1, 1, 1)
    end
    ActionBar.ResetPotionTimerLabel() -- Set the label position

    -- Create Ultimate Overlay Labels
    local ActionButton8 = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
    local ActionButton8_button = ActionButton8 and ActionButton8.button
    -- Ultimate value label (numeric display above slot)
    local ultimateValueLabel = windowManager:CreateControl("$(parent)LabelVal", ActionButton8_button, CT_LABEL)
    ultimateValueLabel:SetAnchor(BOTTOM, ActionButton8_button, TOP, 0, -3)
    ultimateValueLabel:SetFont("$(BOLD_FONT)|16|soft-shadow-thick")
    ultimateValueLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    ultimateValueLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ultimateValueLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ultimateValueLabel:SetHidden(true)
    uiUltimate.LabelVal = ultimateValueLabel

    -- Ultimate percentage label (overlay on slot)
    local ultimatePctLabel = windowManager:CreateControl("$(parent)LabelPct", ActionButton8_button, CT_LABEL)
    ultimatePctLabel:SetFont(g_ultimateFont or "LUIE Default Font")
    ultimatePctLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    ultimatePctLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    ultimatePctLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    ultimatePctLabel:SetAnchor(TOPLEFT, ActionButton8_button)
    ultimatePctLabel:SetAnchor(BOTTOMRIGHT, ActionButton8_button, nil, 0, -ActionBar.SV.UltimateLabelPosition)
    ultimatePctLabel:SetColor(unpack(uiUltimate.colour))
    ultimatePctLabel:SetHidden(true)
    uiUltimate.LabelPct = ultimatePctLabel

    -- Ultimate ready burst texture
    local ultimateTexture = windowManager:CreateControl("$(parent)Texture", ActionButton8_button, CT_TEXTURE)
    ultimateTexture:SetAnchor(CENTER, ActionButton8_button, CENTER, 0, 0)
    ultimateTexture:SetDimensions(160, 160)
    ultimateTexture:SetTexture("/esoui/art/crafting/white_burst.dds")
    ultimateTexture:SetDrawLayer(DL_BACKGROUND)
    ultimateTexture:SetBlendMode(TEX_BLEND_MODE_ADD)
    ultimateTexture:SetHidden(true)
    uiUltimate.Texture = ultimateTexture

    -- -----------------------------------------------------------------------------
    -- Create a top level window for backbar butons
    local tlw = windowManager:CreateControl("LUIE_Backbar", ACTION_BAR, CT_CONTROL)
    tlw:SetParent(ACTION_BAR)
    g_backbarContainer = tlw

    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = MakeActionButton(i, tlw, "ZO_ActionButton", HOTBAR_CATEGORY_BACKUP)
        SetupSwapAnimation(button)
        SetupBounceAnimation(button)
        SetupBackbarDragDropHandlers(button)
        UpdateBackbarButtonActionIds()
        g_backbarButtons[i] = button
    end

    ActionBar.BackbarSetupTemplate()
    ActionBar.BackbarToggleSettings()

    -- -----------------------------------------------------------------------------
    ActionBar.RegisterEvents()
    ZO_PlatformStyle:New(ActionBar.BackbarSetupTemplate, KEYBOARD_CONSTANTS, GAMEPAD_CONSTANTS)
    -- -----------------------------------------------------------------------------
    if ActionBar.SV.GlobalShowGCD then
        ActionBar.HookGCD()
    end

    -- -----------------------------------------------------------------------------
    -- Create and update Cast Bar
    ActionBar.CreateCastBar()
    ActionBar.UpdateCastBar()
    ActionBar.SetCastBarPosition()
end

-- -----------------------------------------------------------------------------
-- Called on initialization and on full update to swap icons on backbar
---
--- @param button ActionButton
--- @param flip boolean
function ActionBar.SetupBackBarIcons(button, flip)
    -- Setup icons for backbar
    local hotbarCategory = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
    local slotNum = button.slot.slotNum
    local slotId = GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, hotbarCategory)

    -- Check backbar weapon type
    local weaponSlot = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and 4 or 20
    local weaponType = GetItemWeaponType(BAG_WORN, weaponSlot)

    -- Fix tracking for Staff Backbar
    if weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF then
        if Effects.BarHighlightDestroFix[slotId] and Effects.BarHighlightDestroFix[slotId][weaponType] then
            slotId = Effects.BarHighlightDestroFix[slotId][weaponType]
        end
    end

    -- Special case for certain skills, so the proc icon doesn't get stuck.
    local specialCases =
    {
        [114716] = 46324, -- Crystal Fragments --> Crystal Fragments
        [20824] = 20816,  -- Power Lash --> Flame Lash
        [35445] = 35441,  -- Shadow Image Teleport --> Shadow Image
        [126659] = 38910, -- Flying Blade --> Flying Blade
    }

    if specialCases[slotId] then
        slotId = specialCases[slotId]
    end

    -- Check if something is in this action bar slot and if not hide the slot
    if slotId > 0 then
        button.icon:SetTexture(GetAbilityIcon(slotId))
        button.icon:SetHidden(false)
    else
        button.icon:SetHidden(true)
    end

    if flip then
        local desaturate = true

        local customToggle = GetCustomToggleControl(slotNum)
        if customToggle then
            desaturate = false

            if customToggle:IsHidden() then
                ActionBar.BackbarHideSlot(slotNum)
                desaturate = true
            end
        end

        ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
    end
end

-- -----------------------------------------------------------------------------
--- Called when active weapon pair changes; updates hotbar category and backbar.
--- @param activeWeaponPair ActiveWeaponPair
--- @param locked boolean
function ActionBar.OnActiveWeaponPairChanged(activeWeaponPair, locked)
    g_hotbarCategory = GetActiveHotbarCategory()
    g_activeWeaponSwapInProgress = true
    UpdateBackbarButtonActionIds()
end

local function CastBarOnActiveWeaponPairChanged(activeWeaponPair, locked)
    if not ActionBar.SV.CastBarEnable then
        return
    end
    ActionBar.StopCastBar()
end

-- -----------------------------------------------------------------------------
-- Hook to update GCD support
--- Hooks ActionButton UpdateUsable/UpdateCooldown for global GCD display.
function ActionBar.HookGCD()
    ---
    --- @param self ActionButton
    --- @diagnostic disable-next-line: duplicate-set-field
    function ActionButton:UpdateUsable()
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or g_hotbarCategory
        local isGamepad = IsInGamepadPreferredMode()
        local _, duration, _, _ = GetSlotCooldownInfo(slotnum, hotbarCategory)
        local isShowingCooldown = self.showingCooldown
        local isKeyboardUltimateSlot = not isGamepad and self.slot.slotNum == ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
        local usable = false
        if not self.useFailure and not isShowingCooldown then
            usable = true
        elseif isKeyboardUltimateSlot and self.costFailureOnly and not isShowingCooldown then
            usable = true
            -- Fix to grey out potions
        elseif IsSlotItemConsumable(slotnum, hotbarCategory) and duration <= 1000 and not self.useFailure then
            usable = true
        end

        if usable ~= self.usable or isGamepad ~= self.isGamepad then
            self.usable = usable
            self.isGamepad = isGamepad
        end
        -- Have to move this out of conditional to fix desaturation from getting stuck on icons.
        local useDesaturation = (isShowingCooldown and ActionBar.SV.GlobalDesat)
        ZO_ActionSlot_SetUnusable(self.icon, not usable, useDesaturation)
    end

    -- Hook to update GCD support
    ---
    --- @param self ActionButton
    --- @param options table
    --- @diagnostic disable-next-line: duplicate-set-field
    function ActionButton:UpdateCooldown(options)
        local slotnum = self:GetSlot()
        local hotbarCategory = self.slot.slotNum == 1 and HOTBAR_CATEGORY_QUICKSLOT_WHEEL or g_hotbarCategory
        local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotnum, hotbarCategory)
        local isInCooldown = duration > 0
        local slotType = GetSlotType(slotnum, hotbarCategory)
        local showGlobalCooldownForCollectible = global and slotType == ACTION_TYPE_COLLECTIBLE and globalSlotType == ACTION_TYPE_COLLECTIBLE
        local showCooldown = isInCooldown and (ActionBar.SV.GlobalShowGCD or not global or showGlobalCooldownForCollectible)
        local updateChromaQuickslot = ((slotType ~= ACTION_TYPE_ABILITY) or (slotType ~= ACTION_TYPE_CRAFTED_ABILITY)) and ZO_RZCHROMA_EFFECTS
        local NO_LEADING_EDGE = false
        self.cooldown:SetHidden(not showCooldown)

        if showCooldown then
            -- For items with a long CD we need to be sure not to hide the countdown radial timer, so if the duration is the 1 sec GCD, then we don't turn off the cooldown animation.
            if not IsSlotItemConsumable(slotnum, hotbarCategory) or duration > 1000 or ActionBar.SV.GlobalPotion then
                self.cooldown:StartCooldown(remain, duration, CooldownMethod[ActionBar.SV.GlobalMethod], nil, NO_LEADING_EDGE)
                if self.cooldownCompleteAnim.animation then
                    self.cooldownCompleteAnim.animation:GetTimeline():PlayInstantlyToStart()
                end

                if IsInGamepadPreferredMode() then
                    self.cooldown:SetHidden(true)
                    if not self.showingCooldown then
                        self:SetNeedsAnimationParameterUpdate(true)
                        self:PlayAbilityUsedBounce()
                    end
                else
                    self.cooldown:SetHidden(false)
                end

                self.slot:SetHandler("OnUpdate", function ()
                    self:RefreshCooldown()
                end)
                if updateChromaQuickslot then
                    ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect("ACTION_BUTTON_9")
                end
            end
        else
            if ActionBar.SV.GlobalFlash then
                if self.showingCooldown then
                    -- Stop flash from appearing on potion/ultimate if toggled off.
                    if not IsSlotItemConsumable(slotnum, hotbarCategory) or duration > 1000 or ActionBar.SV.GlobalPotion then
                        if self.cooldownCompleteAnim.animation == nil then
                            self.cooldownCompleteAnim.animation = CreateSimpleAnimation(ANIMATION_TEXTURE, self.cooldownCompleteAnim)
                        end
                        local anim = self.cooldownCompleteAnim.animation
                        if anim then
                            self.cooldownCompleteAnim:SetHidden(false)
                            self.cooldown:SetHidden(false)

                            anim:SetImageData(16, 1)
                            anim:SetFramerate(zo_round(GetFramerate()))
                            anim:GetTimeline():PlayFromStart()

                            if updateChromaQuickslot then
                                ZO_RZCHROMA_EFFECTS:AddKeybindActionEffect("ACTION_BUTTON_9")
                            end
                        end
                    end
                end
            end
            self.icon.percentComplete = 1
            self.slot:SetHandler("OnUpdate", nil)
            self.cooldown:ResetCooldown()
        end

        if showCooldown ~= self.showingCooldown then
            self:SetShowCooldown(showCooldown)
            self:UpdateActivationHighlight()

            if IsInGamepadPreferredMode() then
                self:SetCooldownPercentComplete(self.icon.percentComplete)
            end
        end

        if showCooldown or self.itemQtyFailure then
            self.icon:SetDesaturation(1)
        else
            self.icon:SetDesaturation(0)
        end

        local textColor
        if ActionBar.SV.GlobalLabelColor then
            textColor = showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED
        else
            textColor = INTERFACE_TEXT_COLOR_SELECTED
        end
        self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))

        self.isGlobalCooldown = global
        self:UpdateUsable()
    end
end

-- -----------------------------------------------------------------------------
-- Resolve ability rank for GetAbilityDuration/GetAbilityCastInfo (overrideRank).
-- Prefer GetAbilityProgressionRankFromAbilityId (correct for morphs, e.g. rank 4); fallback to progression chain then API 5th return.
---
--- @param abilityId integer
--- @return integer|nil rank 1-based rank, or nil to let API use default
local function GetAbilityRankForDuration(abilityId)
    local resolvedRank = GetAbilityProgressionRankFromAbilityId(abilityId)
    if resolvedRank == nil then
        local skillType, skillLineIndex, skillIndex, morphChoice, rankFromApi = GetSpecificSkillAbilityKeysByAbilityId(abilityId)
        resolvedRank = rankFromApi
        if skillType and skillLineIndex then
            local progressionId = GetProgressionSkillProgressionId(skillType, skillLineIndex, skillIndex)
            local morphSlot = (morphChoice == 0 and MORPH_SLOT_BASE) or (morphChoice == 1 and MORPH_SLOT_MORPH_1 or MORPH_SLOT_MORPH_2)
            if progressionId and morphSlot then
                local abilityIds = { GetProgressionSkillMorphSlotChainedAbilityIds(progressionId, morphSlot) }
                for rankIndex, chainAbilityId in ipairs(abilityIds) do
                    if chainAbilityId == abilityId then
                        resolvedRank = rankIndex
                        break
                    end
                end
            end
        end
    end

    return resolvedRank
end

-- -----------------------------------------------------------------------------
-- Helper function to get override ability duration.
---
--- @param abilityId integer
--- @return integer duration
local function GetUpdatedAbilityDuration(abilityId)
    local overrideCasterUnitTag = "player"
    local overrideActiveRank = GetAbilityRankForDuration(abilityId)
    local duration

    -- Prefer hardcoded override; otherwise use game API (ZOS tooltip order)
    duration = g_barDurationOverride[abilityId]
    if duration == nil then
        local isToggled = IsAbilityDurationToggled(abilityId, overrideCasterUnitTag)
        if isToggled then
            duration = 0 -- ZOS: toggles have no numeric duration
        else
            duration = GetAbilityDuration(abilityId, overrideActiveRank, overrideCasterUnitTag)
        end
    end

    -- If duration is 0, may be cast/channel — use cast time (ZOS: GetAbilityCastInfo 2nd return)
    if duration == 0 then
        local _, castTime = GetAbilityCastInfo(abilityId, overrideActiveRank, overrideCasterUnitTag)
        duration = castTime
    end

    return duration or 0
end

-- -----------------------------------------------------------------------------
-- Called on initialization and menu changes
-- Pull data from Effects.BarHighlightOverride Tables to filter the display of Bar Highlight abilities based off menu settings.
--- Rebuilds bar highlight override/fake-aura tables and (re)registers combat event filters.
function ActionBar.UpdateBarHighlightTables()
    g_uiProcAnimation = {}
    g_uiCustomToggle = {}
    g_triggeredSlotsFront = {}
    g_triggeredSlotsBack = {}
    g_triggeredSlotsRemain = {}
    g_toggledSlotsFront = {}
    g_toggledSlotsBack = {}
    g_toggledSlotsRemain = {}
    g_toggledSlotsStack = {}
    g_toggledSlotsPlayer = {}
    g_barOverrideCI = {}
    g_barFakeAura = {}
    g_barDurationOverride = {}
    g_barNoRemove = {}

    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        -- Grab any aura's from the list that have on EVENT_COMBAT_EVENT AURA support
        for abilityId, value in pairs(Effects.BarHighlightOverride) do
            if value.showFakeAura == true then
                if value.newId then
                    g_barOverrideCI[value.newId] = true
                    if value.duration then
                        g_barDurationOverride[value.newId] = value.duration
                    end
                    if value.noRemove then
                        g_barNoRemove[value.newId] = true
                    end
                    g_barFakeAura[value.newId] = true
                else
                    g_barOverrideCI[abilityId] = true
                    if value.duration then
                        g_barDurationOverride[abilityId] = value.duration
                    end
                    if value.noRemove then
                        g_barNoRemove[abilityId] = true
                    end
                    g_barFakeAura[abilityId] = true
                end
            elseif value.combatTrack == true and value.newId then
                g_barOverrideCI[value.newId] = true
                if value.duration then
                    g_barDurationOverride[value.newId] = value.duration
                end
            else
                if value.noRemove then
                    if value.newId then
                        g_barNoRemove[value.newId] = true
                    else
                        g_barNoRemove[abilityId] = true
                    end
                end
            end
        end
        local counter = 0
        for ability_Id, _ in pairs(g_barOverrideCI) do
            counter = counter + 1
            local eventName = (moduleName .. "CombatEventBar" .. counter)
            eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function (_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                ActionBar.OnCombatEventBar(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            end)
            -- Register filter for specific abilityId's in table only, and filter for source = player, no errors
            eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, ability_Id, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Clear and then (maybe) re-register event listeners for Combat/Power/Slot Updates
--- Registers update loop and all ActionBar event handlers (player activated, combat, power, slots, etc.).
function ActionBar.RegisterEvents()
    eventManager:RegisterForUpdate(moduleName .. "OnUpdate", 100, ActionBar.OnUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, function (eventId, initial)
        ActionBar.OnPlayerActivated()
    end)

    eventManager:UnregisterForEvent(moduleName, EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED)
    eventManager:UnregisterForEvent(moduleName .. "OakensoulBackbar", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "CursorPickup", EVENT_CURSOR_PICKUP)
    eventManager:UnregisterForEvent(moduleName .. "CursorDropped", EVENT_CURSOR_DROPPED)
    eventManager:UnregisterForEvent(moduleName .. "CastBar", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_RETICLE_HIDDEN_UPDATE)
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, function (_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            ActionBar.OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        end)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BLOCKED_DAMAGE)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdate", EVENT_POWER_UPDATE, function (_, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
            ActionBar.OnPowerUpdatePlayer(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
        end)
        eventManager:AddFilterForEvent(moduleName .. "PowerUpdate", EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (_, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
            ActionBar.OnInventorySlotUpdate(bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
        end)
        eventManager:AddFilterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT, REGISTER_FILTER_IS_NEW_ITEM, false)
    end
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled or ActionBar.SV.CastBarEnable then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, function (_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            ActionBar.OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        end)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
    end
    if ActionBar.SV.CastBarEnable then
        local counter = 0
        for result, _ in pairs(Castbar.CastBreakingStatus) do
            counter = counter + 1
            local eventName = (moduleName .. "CombatEventCC" .. counter)
            eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function (_, actionResult, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
                ActionBar.OnCombatEventBreakCast(actionResult, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            end)
            eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, result)
        end
        eventManager:RegisterForEvent(moduleName, EVENT_START_SOUL_GEM_RESURRECTION, function (_, durationMs)
            ActionBar.SoulGemResurrectionStart(durationMs)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_END_SOUL_GEM_RESURRECTION, function (_)
            ActionBar.SoulGemResurrectionEnd()
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_GAME_CAMERA_UI_MODE_CHANGED, function (_)
            ActionBar.OnGameCameraUIModeChanged()
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_END_SIEGE_CONTROL, function (_)
            ActionBar.OnSiegeEnd()
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED, function (_, actionSlotIndex)
            ActionBar.OnAbilityUsed(actionSlotIndex)
        end)
        eventManager:RegisterForEvent(moduleName .. "CastBar", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function (_, activeWeaponPair, locked)
            CastBarOnActiveWeaponPairChanged(activeWeaponPair, locked)
        end)
        -- eventManager:RegisterForEvent(moduleName, EVENT_CLIENT_INTERACT_RESULT, ActionBar.ClientInteractResult)
        -- counter = 0
        -- for id, _ in pairs(Effects.CastBreakOnRemoveEvent) do
        --     counter = counter + 1
        --     local eventName = (moduleName .. "LUIE_CI_CombatEventCastBreak" .. counter)
        --     eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, ActionBar.OnCombatEventSpecialFilters)
        --     eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, id, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_EFFECT_FADED)
        -- end
    end
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled or ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, function (_, didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
            ActionBar.OnActiveHotbarUpdate(didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, function (_)
            ActionBar.OnSlotsFullUpdate()
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED, function (_, actionSlotIndex)
            ActionBar.OnSlotUpdated(actionSlotIndex)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function (_, activeWeaponPair, locked)
            ActionBar.OnActiveWeaponPairChanged(activeWeaponPair, locked)
        end)
    end
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, function (_, unitTag, isDead)
            ActionBar.OnDeath(unitTag, isDead)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, function (_, unitTag)
            ActionBar.OnTargetChange(unitTag)
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, function (_)
            ActionBar.OnReticleTargetChanged()
        end)
        eventManager:RegisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, function (_, gamepadPreferred)
            ActionBar.BackbarSetupTemplate()
        end)

        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED, function (_, itemSoundCategory)
            ActionBar.InventoryItemUsed()
        end)

        -- Setup bar highlight
        ActionBar.UpdateBarHighlightTables()
    end
    -- Have to register EVENT_EFFECT_CHANGED for werewolf as well - Stop devour cast bar when devour fades / also handles updating Vampire Ultimate cost on stage change
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled or ActionBar.SV.CastBarEnable or ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName, EVENT_EFFECT_CHANGED, function (_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
            ActionBar.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
        end)
    end
    -- Register for ring slot changes - Oaken soul Ring (187658) equip/unequip toggles backbar visibility when BarShowBack
    eventManager:RegisterForEvent(moduleName .. "OakensoulBackbar", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (_, bagId, slotIndex)
        if ActionBar.SV.BarShowBack and bagId == BAG_WORN and (slotIndex == EQUIP_SLOT_RING1 or slotIndex == EQUIP_SLOT_RING2) then
            ActionBar.BackbarToggleSettings()
        end
    end)
    eventManager:AddFilterForEvent(moduleName .. "OakensoulBackbar", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)
    eventManager:RegisterForEvent(moduleName .. "wolf", EVENT_WEREWOLF_STATE_CHANGED, function (_, werewolf)
        g_backbarContainer:SetHidden(werewolf)
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, ActionBar.BackbarToggleSettings)
    -- Drop callout handlers (mirrors ZOS: show valid/invalid slot highlight when dragging abilities)
    eventManager:RegisterForEvent(moduleName .. "CursorPickup", EVENT_CURSOR_PICKUP, function (_, cursorType, param1, param2, param3)
        if cursorType == MOUSE_CONTENT_ACTION and DROP_CALLOUT_VALIDITY_BY_ACTION_TYPE[param1] then
            ShowAppropriateAbilityActionButtonDropCallouts(param1, param3)
        end
    end)
    eventManager:RegisterForEvent(moduleName .. "CursorDropped", EVENT_CURSOR_DROPPED, function (_, cursorType)
        if cursorType == MOUSE_CONTENT_ACTION then
            HideAllAbilityActionButtonDropCallouts()
        end
    end)
    -- Display default UI ultimate text if the LUIE option is enabled.
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        if not IsConsoleUI() then
            SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, 0)
        end
    end

    eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_HIDDEN_UPDATE, function (_, hidden)
        ActionBar.OnReticleHiddenUpdate(hidden)
    end)
end

-- -----------------------------------------------------------------------------
--- Clears all entries from a custom list (e.g. blacklist); prints to chat.
--- @param list AB_CustomList
function ActionBar.ClearCustomList(list)
    local listRef = list == ActionBar.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    for k, v in pairs(list) do
        list[k] = nil
    end
    chatSystem:Maximize()
    chatSystem.primaryContainer:FadeIn()
    printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
end

-- -----------------------------------------------------------------------------
-- List Handling (Add) for Prominent Auras & Blacklist
--- Adds an ability id or name to a custom list (e.g. blacklist); prints to chat.
--- @param list AB_CustomList
--- @param input any Ability id (number string) or name string
function ActionBar.AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == ActionBar.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    if id and id > 0 then
        local name = zo_strformat("<<C:1>>", GetAbilityName(id))
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
            list[id] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
end

-- -----------------------------------------------------------------------------
-- List Handling (Remove) for Prominent Auras & Blacklist
--- Removes an ability id or name from a custom list (e.g. blacklist); prints to chat.
--- @param list AB_CustomList
--- @param input any Ability id (number string) or name string
function ActionBar.RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == ActionBar.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    if id and id > 0 then
        local name = zo_strformat("<<C:1>>", GetAbilityName(id))
        local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        chatSystem:Maximize()
        chatSystem.primaryContainer:FadeIn()
        printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Used to populate abilities icons after the user has logged on
--- Runs on EVENT_PLAYER_ACTIVATED: full slot update, ultimate label, backbar visibility, drop callouts.
function ActionBar.OnPlayerActivated()
    -- Manually trigger event to update stats
    g_hotbarCategory = GetActiveHotbarCategory()
    ActionBar.OnSlotsFullUpdate()
    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        -- Update Bar Slots on initial load (don't want to do it normally when we do a slot update)
        ActionBar.BarSlotUpdate(i, true, false)
    end
    ActionBar.OnPowerUpdatePlayer("player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE))

    HideAllAbilityActionButtonDropCallouts()

    -- Scan for bar-swap disablers on load/zone - hide back bar if active
    if ActionBar.SV.BarShowBack and g_backbarContainer then
        if GetUnitLevel("player") < GetWeaponSwapUnlockedLevel() then
            g_backbarContainer:SetHidden(true)
        elseif OakensoulEquipped() then
            g_backbarContainer:SetHidden(true)
        else
            for i = 1, GetNumBuffs("player") do
                local _, _, _, _, _, _, _, _, abilityType = GetUnitBuffInfo("player", i)
                if abilityType == ABILITY_TYPE_SETHOTBAR then
                    g_backbarContainer:SetHidden(true)
                    break
                end
            end
        end
    end
end

local savedPlayerX = 0.000000000000000
local savedPlayerZ = 0.000000000000000
local playerX = 0.000000000000000
local playerZ = 0.000000000000000

-- -----------------------------------------------------------------------------
-- Hide duration label if the ability is Grim Focus or one of its morphs
--- @param remain integer
--- @param abilityId integer
--- @return string
local function SetBarRemainLabel(remain, abilityId)
    if Effects.IsGrimFocus[abilityId] or Effects.IsBloodFrenzy[abilityId] then
        return ""
    else
        return FormatDurationSeconds(remain)
    end
end

-- -----------------------------------------------------------------------------
-- Updates all floating labels. Called every 100ms
---
--- @param currentTimeMS integer
function ActionBar.OnUpdate(currentTimeMS)
    -- Procs
    for k, v in pairs(g_triggeredSlotsRemain) do
        local remain = v - currentTimeMS
        local front = g_triggeredSlotsFront[k]
        local back = g_triggeredSlotsBack[k]
        local frontAnim = front and g_uiProcAnimation[front]
        local backAnim = back and g_uiProcAnimation[back]
        -- If duration reaches 0 then remove effect
        if v < currentTimeMS then
            if frontAnim then
                frontAnim:Stop()
            end
            if backAnim then
                backAnim:Stop()
            end
            g_triggeredSlotsRemain[k] = nil
        end
        -- Update Label (FRONT)(BACK)
        if ActionBar.SV.BarShowLabel and remain then
            if frontAnim then
                frontAnim.procLoopTexture.label:SetText(SetBarRemainLabel(remain, k))
            end
            if backAnim then
                backAnim.procLoopTexture.label:SetText(SetBarRemainLabel(remain, k))
            end
        end
    end
    -- Ability Highlight
    for k, v in pairs(g_toggledSlotsRemain) do
        local remain = v - currentTimeMS
        local front = g_toggledSlotsFront[k]
        local back = g_toggledSlotsBack[k]
        local frontToggle = front and g_uiCustomToggle[front]
        local backToggle = back and g_uiCustomToggle[back]
        -- Update Label (FRONT)
        if v < currentTimeMS then
            if frontToggle then
                ActionBar.HideSlot(front, k)
            end
            if backToggle then
                ActionBar.HideSlot(back, k)
            end
            g_toggledSlotsRemain[k] = nil
            g_toggledSlotsStack[k] = nil
        end
        -- Update Label (BACK)
        if ActionBar.SV.BarShowLabel and remain then
            if frontToggle then
                frontToggle.label:SetText(SetBarRemainLabel(remain, k))
            end
            if backToggle then
                backToggle.label:SetText(SetBarRemainLabel(remain, k))
            end
        end
    end

    -- Quickslot cooldown
    if ActionBar.SV.PotionTimerShow then
        local slotIndex = GetCurrentQuickslot()
        local remain, duration, _ = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local label = uiQuickSlot.label
        local timeColours = uiQuickSlot.timeColours
        if duration > 5000 then
            label:SetHidden(false)
            if not ActionBar.SV.PotionTimerColor then
                label:SetColor(1, 1, 1, 1)
            else
                local color = uiQuickSlot.colour
                local r, g, b, a = color[1], color[2], color[3], color[4]
                for i = #timeColours, 1, -1 do
                    if remain < timeColours[i].remain then
                        color = timeColours[i].colour
                        break
                    end
                end
                label:SetColor(r, g, b, a)
            end
            local text
            if remain > 86400000 then
                text = zo_floor(remain / 86400000) .. " d"
            elseif remain > 6000000 then
                text = zo_floor(remain / 3600000) .. "h"
            elseif remain > 600000 then
                text = zo_floor(remain / 60000) .. "m"
            elseif remain > 60000 then
                local m = zo_floor(remain / 60000)
                local s = remain / 1000 - 60 * m
                text = m .. ":" .. string_format("%.2d", s)
            else
                text = string_format(ActionBar.SV.PotionTimerMillis and "%.1f" or "%.1d", 0.001 * remain)
            end
            label:SetText(text)
        else
            label:SetHidden(true)
        end
    end

    -- Hide Ultimate generation texture if it is time to do so
    if ActionBar.SV.UltimateGeneration then
        if not uiUltimate.Texture:IsHidden() and uiUltimate.FadeTime < currentTimeMS then
            uiUltimate.Texture:SetHidden(true)
        end
    end

    -- Break castbar when block is used for certain effects.
    if not Castbar.IgnoreCastBreakingActions[castbar.id] then
        if IsBlockActive() then
            if not IsPlayerStunned() then
                -- Is Block Active returns true when the player is stunned currently.
                ActionBar.StopCastBar()
            end
        end
    end

    -- Break castbar when movement interrupt is detected for certain effects.
    savedPlayerX = playerX
    savedPlayerZ = playerZ
    playerX, playerZ = GetMapPlayerPosition("player")
    if savedPlayerX == playerX and savedPlayerZ == playerZ then
        return
    else
        -- Fix if the player clicks on a Wayshrine in the World Map
        if g_castbarWorldMapFix == false then
            if Castbar.BreakCastOnMove[castbar.id] then
                ActionBar.StopCastBar()
                -- TODO: Note probably should make StopCastBar event clear the id on it too. Not doing this right now due to not wanting to troubleshoot possible issues before update release.
            end
        end
        -- Only have this enabled for 1 tick max (the players coordinates only update 1 time after the World Map is closed so if the player moves before 500 ms we want to cancel the cast bar still)
        if g_castbarWorldMapFix == true then
            g_castbarWorldMapFix = false
        end
    end
end

-- -----------------------------------------------------------------------------
local function CastBarWorldMapFix()
    g_castbarWorldMapFix = false
    eventManager:UnregisterForUpdate(moduleName .. "CastBarFix")
end

-- -----------------------------------------------------------------------------
-- Run on the EVENT_GAME_CAMERA_UI_MODE_CHANGED handler
--- Sets world-map castbar fix buffer; breaks siege cast on window open if applicable.
function ActionBar.OnGameCameraUIModeChanged()
    -- Changing zones in the World Map for some reason changes the player coordinates so when the player clicks on a Wayshrine to teleport the cast gets interrupted
    -- This buffer fixes this issue
    g_castbarWorldMapFix = true
    eventManager:RegisterForUpdate(moduleName .. "CastBarFix", 500, CastBarWorldMapFix)
    -- Break Siege Deployment casts when opening UI windows
    if Castbar.BreakSiegeOnWindowOpen[castbar.id] then
        ActionBar.StopCastBar()
    end
end

-- -----------------------------------------------------------------------------
-- Run on the EVENT_END_SIEGE_CONTROL handler
-- Used to break the cast for Stow Siege Weapon if the player exits siege control.
--- Stops cast bar when siege control ends (e.g. Stow Siege Weapon 12256).
function ActionBar.OnSiegeEnd()
    if castbar.id == 12256 then
        ActionBar.StopCastBar()
    end
end

-- -----------------------------------------------------------------------------
-- Stops Attack Cast when releasing heavy attacks
--- Stops cast bar when quickslot (slot 2) ability is used (e.g. heavy attack release).
--- @param actionSlotIndex number
function ActionBar.OnAbilityUsed(actionSlotIndex)
    if actionSlotIndex == 2 then
        ActionBar.StopCastBar()
    end

    -- Power Lash consumes a stack per cast; combat often does not emit EFFECT_GAINED per stack, so sync from slot use (bound 20824 / 23105).
    local POWER_LASH_STACK_TRACK = 34117
    if not ActionBar.SV.ShowToggled then
        return
    end
    if not (g_toggledSlotsFront[POWER_LASH_STACK_TRACK] or g_toggledSlotsBack[POWER_LASH_STACK_TRACK]) or not g_toggledSlotsRemain[POWER_LASH_STACK_TRACK] then
        return
    end

    local bound = GetSlotTrueBoundId(actionSlotIndex, g_hotbarCategory)
    if bound ~= 20824 and bound ~= 23105 then
        return
    end

    local stacks = g_toggledSlotsStack[POWER_LASH_STACK_TRACK]
    if not stacks or stacks <= 0 then
        return
    end

    stacks = stacks - 1
    g_toggledSlotsStack[POWER_LASH_STACK_TRACK] = stacks > 0 and stacks or nil

    local now = GetGameTimeMilliseconds()
    if not g_toggledSlotsStack[POWER_LASH_STACK_TRACK] then
        g_toggledSlotsRemain[POWER_LASH_STACK_TRACK] = nil
        if g_toggledSlotsFront[POWER_LASH_STACK_TRACK] then
            ActionBar.HideSlot(g_toggledSlotsFront[POWER_LASH_STACK_TRACK], POWER_LASH_STACK_TRACK)
        end
        if g_toggledSlotsBack[POWER_LASH_STACK_TRACK] then
            ActionBar.HideSlot(g_toggledSlotsBack[POWER_LASH_STACK_TRACK], POWER_LASH_STACK_TRACK)
        end
    else
        if g_toggledSlotsFront[POWER_LASH_STACK_TRACK] then
            ActionBar.ShowSlot(g_toggledSlotsFront[POWER_LASH_STACK_TRACK], POWER_LASH_STACK_TRACK, now, false)
        end
        if g_toggledSlotsBack[POWER_LASH_STACK_TRACK] then
            ActionBar.ShowSlot(g_toggledSlotsBack[POWER_LASH_STACK_TRACK], POWER_LASH_STACK_TRACK, now, false)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Hides and stops the cast bar; unregisters cast bar update. If cast bar is unlocked, shows preview.
function ActionBar.StopCastBar()
    local state = ActionBar.CastBarUnlocked
    -- Don't hide the cast bar if we have it unlocked to move.
    castbar.bar.name:SetHidden(true)
    castbar.bar.timer:SetHidden(true)
    castbar:SetHidden(true)
    castbar.remain = nil
    castbar.starts = nil
    castbar.ends = nil
    g_casting = false
    eventManager:UnregisterForUpdate(moduleName .. "CastBar")

    if state then
        ActionBar.GenerateCastbarPreview(state)
    end
end

-- -----------------------------------------------------------------------------
-- Updates Cast Bar - only enabled when Cast Bar is unhidden
--- Update tick: refreshes cast bar progress and timer label; stops when remain <= 0.
--- @param currentTimeMS number
function ActionBar.OnUpdateCastbar(currentTimeMS)
    -- Update castbar
    local castStarts = castbar.starts
    local castEnds = castbar.ends
    local remain = castbar.remain - currentTimeMS
    if remain <= 0 then
        ActionBar.StopCastBar()
    else
        if ActionBar.SV.CastBarTimer then
            castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
        end
        if castbar.type == 1 then
            castbar.bar.bar:SetValue((currentTimeMS - castStarts) / (castEnds - castStarts))
        else
            castbar.bar.bar:SetValue(1 - ((currentTimeMS - castStarts) / (castEnds - castStarts)))
        end
    end
end

-- -----------------------------------------------------------------------------
---
--- @param fontNameKey string
--- @param fontStyleKey string
--- @param fontSizeKey string
--- @param defaultFontStyle integer
--- @param defaultFontSize integer
--- @return string
local setupFont = function (fontNameKey, fontStyleKey, fontSizeKey, defaultFontStyle, defaultFontSize)
    local fontName = LUIE.Fonts[ActionBar.SV[fontNameKey]]
    if not fontName or fontName == "" then
        LUIE:Log("Debug", GetString(LUIE_STRING_ERROR_FONT))
        fontName = "LUIE Default Font"
    end
    local fontStyle = ActionBar.SV[fontStyleKey] or defaultFontStyle
    local fontSize = (ActionBar.SV[fontSizeKey] and ActionBar.SV[fontSizeKey] > 0) and ActionBar.SV[fontSizeKey] or defaultFontSize
    return LUIE.CreateFontString(fontName, fontSize, fontStyle)
end

-- -----------------------------------------------------------------------------
-- Updates local variables with new font.
--- Applies SV font settings to bar, quickslot, ultimate, and castbar labels.
function ActionBar.ApplyFont()
    if not ActionBar.Enabled then
        return
    end

    g_barFont = setupFont("BarFontFace", "BarFontStyle", "BarFontSize", FONT_STYLE_OUTLINE, 17)
    for k, _ in pairs(g_uiProcAnimation) do
        g_uiProcAnimation[k].procLoopTexture.label:SetFont(g_barFont)
    end
    for k, _ in pairs(g_uiCustomToggle) do
        if g_uiCustomToggle[k] ~= true then
            g_uiCustomToggle[k].label:SetFont(g_barFont)
            g_uiCustomToggle[k].stack:SetFont(g_barFont)
        end
    end

    g_potionFont = setupFont("PotionTimerFontFace", "PotionTimerFontStyle", "PotionTimerFontSize", FONT_STYLE_OUTLINE, 17)
    if uiQuickSlot.label then
        uiQuickSlot.label:SetFont(g_potionFont)
    end

    g_ultimateFont = setupFont("UltimateFontFace", "UltimateFontStyle", "UltimateFontSize", FONT_STYLE_OUTLINE, 17)
    if uiUltimate.LabelPct then
        uiUltimate.LabelPct:SetFont(g_ultimateFont)
    end

    g_castbarFont = setupFont("CastBarFontFace", "CastBarFontStyle", "CastBarFontSize", FONT_STYLE_SOFT_SHADOW_THIN, 16)
end

-- -----------------------------------------------------------------------------
-- Updates Proc Sound - called on initialization and menu changes
--- Sets proc sound from SV; optionally plays it if menu is provided.
--- @param menu table? If set, plays the sound for preview.
function ActionBar.ApplyProcSound(menu)
    local barProcSound = LUIE.Sounds[ActionBar.SV.ProcSoundName]
    if not barProcSound or barProcSound == "" then
        printToChat(GetString(LUIE_STRING_ERROR_SOUND), true)
        barProcSound = "DeathRecap_KillingBlowShown"
    end

    g_ProcSound = barProcSound

    if menu then
        PlaySound(g_ProcSound)
    end
end

-- -----------------------------------------------------------------------------
-- Resets the ultimate labels on menu option change
--- Re-anchors ultimate percent label using SV UltimateLabelPosition.
function ActionBar.ResetUltimateLabel()
    uiUltimate.LabelPct:ClearAnchors()
    local ActionButton8 = ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1)
    local ActionButton8_slot = ActionButton8 and ActionButton8.slot
    uiUltimate.LabelPct:SetAnchor(TOPLEFT, ActionButton8_slot)
    uiUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, ActionButton8_slot, nil, 0, -ActionBar.SV.UltimateLabelPosition)
end

-- -----------------------------------------------------------------------------
-- Resets bar labels on menu option change
--- Clears and re-anchors all bar highlight labels (proc + toggle) per SV BarLabelPosition.
function ActionBar.ResetBarLabel()
    for k, _ in pairs(g_uiProcAnimation) do
        g_uiProcAnimation[k].procLoopTexture.label:SetText("")
    end

    for k, _ in pairs(g_uiCustomToggle) do
        if g_uiCustomToggle[k] ~= true then
            g_uiCustomToggle[k].label:SetText("")
        end
    end

    for i = BAR_INDEX_START, BAR_INDEX_END do
        -- Clear base action bars
        local actionButton = ZO_ActionBar_GetButton(i)
        local actionButton_slot = actionButton and actionButton.slot
        local c = GetCustomToggleControl(i)
        if c then
            c.label:ClearAnchors()
            c.label:SetAnchor(TOPLEFT, actionButton_slot)
            c.label:SetAnchor(BOTTOMRIGHT, actionButton_slot, nil, 0, -ActionBar.SV.BarLabelPosition)
        elseif g_uiProcAnimation[i] then
            g_uiProcAnimation[i].procLoopTexture.label:ClearAnchors()
            g_uiProcAnimation[i].procLoopTexture.label:SetAnchor(TOPLEFT, actionButton_slot)
            g_uiProcAnimation[i].procLoopTexture.label:SetAnchor(BOTTOMRIGHT, actionButton_slot, nil, 0, -ActionBar.SV.BarLabelPosition)
        end

        local backIndex = i + BACKBAR_INDEX_OFFSET
        local actionButtonBB = g_backbarButtons[backIndex]
        local cBack = GetCustomToggleControl(backIndex)
        if cBack then
            cBack.label:ClearAnchors()
            cBack.label:SetAnchor(TOPLEFT, actionButtonBB.slot)
            cBack.label:SetAnchor(BOTTOMRIGHT, actionButtonBB.slot, nil, 0, -ActionBar.SV.BarLabelPosition)
        elseif g_uiProcAnimation[backIndex] then
            g_uiProcAnimation[backIndex].procLoopTexture.label:ClearAnchors()
            g_uiProcAnimation[backIndex].procLoopTexture.label:SetAnchor(TOPLEFT, actionButtonBB.slot)
            g_uiProcAnimation[backIndex].procLoopTexture.label:SetAnchor(BOTTOMRIGHT, actionButtonBB.slot, nil, 0, -ActionBar.SV.BarLabelPosition)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Resets Potion Timer label - called on initialization and menu changes
--- Re-anchors quickslot timer label using SV PotionTimerLabelPosition.
function ActionBar.ResetPotionTimerLabel()
    local QSB = ACTION_BAR:GetNamedChild("QuickslotButtonButton")
    uiQuickSlot.label:ClearAnchors()
    uiQuickSlot.label:SetAnchor(TOPLEFT, QSB)
    uiQuickSlot.label:SetAnchor(BOTTOMRIGHT, QSB, nil, 0, -ActionBar.SV.PotionTimerLabelPosition)
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_TARGET_CHANGE listener.
-- This handler fires every time the someone target changes.
-- This function is needed in case the player teleports via Way Shrine
--- Refreshes bar highlight on reticle target when player becomes the target (e.g. wayshrine).
--- @param unitTag string
function ActionBar.OnTargetChange(unitTag)
    if unitTag ~= "player" then
        return
    end
    ActionBar.OnReticleTargetChanged()
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_RETICLE_HIDDEN_UPDATE listener.
-- This handler fires when the reticle visibility changes
--- Stores reticle hidden state for skipping bar highlight updates.
--- @param hidden boolean
function ActionBar.OnReticleHiddenUpdate(hidden)
    g_reticleHidden = hidden
end

-- -----------------------------------------------------------------------------
-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
-- This handler fires every time the player's reticle target changes
--- Updates bar highlights when reticle target changes; hides/shows toggled slots and re-scans buffs.
function ActionBar.OnReticleTargetChanged()
    -- Skip processing if reticle is hidden
    if g_reticleHidden then
        return
    end

    local unitTag = "reticleover"

    for k, v in pairs(g_toggledSlotsRemain) do
        if ((g_toggledSlotsFront[k] and g_uiCustomToggle[g_toggledSlotsFront[k]]) or (g_toggledSlotsBack[k] and g_uiCustomToggle[g_toggledSlotsBack[k]])) and not (g_toggledSlotsPlayer[k] or g_barNoRemove[k]) then
            if g_toggledSlotsFront[k] and g_uiCustomToggle[g_toggledSlotsFront[k]] then
                local slotNum = g_toggledSlotsFront[k]
                ActionBar.HideSlot(slotNum, k)
            end
            if g_toggledSlotsBack[k] and g_uiCustomToggle[g_toggledSlotsBack[k]] then
                local slotNum = g_toggledSlotsBack[k]
                ActionBar.HideSlot(slotNum, k)
            end
            g_toggledSlotsRemain[k] = nil
            g_toggledSlotsStack[k] = nil
            if Effects.BarHighlightCheckOnFade[k] then
                ActionBar.BarHighlightSwap(k)
            end
        end
    end

    if DoesUnitExist("reticleover") then
        -- Fill it again
        for i = 1, GetNumBuffs(unitTag) do
            local unitName = GetRawUnitName(unitTag)
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer
            buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)
            -- Convert boolean to number value if cast by player
            if castByPlayer == true then
                castByPlayer = 1
            else
                castByPlayer = 5
            end
            if not IsUnitDead(unitTag) then
                ActionBar.OnEffectChanged(
                    EFFECT_RESULT_UPDATED,
                    buffSlot,
                    buffName,
                    unitTag,
                    timeStarted,
                    timeEnding,
                    stackCount,
                    iconFilename,
                    buffType,
                    effectType,
                    abilityType,
                    statusEffectType,
                    unitName,
                    0,
                    abilityId,
                    castByPlayer,
                    false,
                    nil)
            end
        end
    end
end

-- -----------------------------------------------------------------------------
---
-- When the primary tracked effect fades, iterate over unit buffs to see if another buff is present.
-- If found, send a dummy EFFECT_RESULT_GAINED event using that buff's duration/stack info but the original ability's id.
-- This allows bar highlights to "swap" to an alternative buff (e.g. Minor Maim from Grave Grasp vs Ghostly Embrace).
--
--- @param abilityId integer The original ability id (key into BarHighlightCheckOnFade).
--
-- Priority system: id1 > id2 > id3. First match wins. Each id may use a different unitTag via id2Tag/id3Tag.
-- castByPlayer must be true: when two instances of the same buff exist (one player-cast, one not), we only highlight our own.
--
-- Paths:
--   1. duration > 0: duration and durationMod are ability IDs. GetUpdatedAbilityDuration(id) returns ms; we use duration_ms - durationMod_ms for the synthetic aura.
--   2. id1/id2/id3: Scan buffs on unitTag (or id2Tag/id3Tag overrides), find first match, fire event.
function ActionBar.BarHighlightSwap(abilityId)
    local cfg = Effects.BarHighlightCheckOnFade[abilityId]
    if not cfg then return end

    local unitTag = cfg.unitTag
    if not DoesUnitExist(unitTag) then return end

    -- Path 1: Fake duration. duration and durationMod are ability IDs; GetUpdatedAbilityDuration returns ms. Result: duration_ms - durationMod_ms.
    local duration = cfg.duration or 0
    local durationMod = cfg.durationMod or 0
    if duration > 0 then
        local fakeDuration = GetUpdatedAbilityDuration(duration) - GetUpdatedAbilityDuration(durationMod)
        local timeStarted = GetGameTimeSeconds()
        local timeEnding = timeStarted + (fakeDuration / 1000)
        ActionBar.OnEffectChanged(EFFECT_RESULT_GAINED, nil, nil, unitTag, timeStarted, timeEnding, 0, nil, nil, 1, ABILITY_TYPE_BONUS, 0, nil, nil, abilityId, 1, true, nil)
        return
    end

    -- Path 2: Buff scan. Build priority-ordered checks: { id, tag } per fallback.
    -- id1 uses unitTag; id2 uses id2Tag if set, else unitTag; id3 uses id3Tag if set, else current tag.
    local checks = {}
    local id1, id2, id3 = cfg.id1 or 0, cfg.id2 or 0, cfg.id3 or 0
    if id1 ~= 0 then checks[#checks + 1] = { id = id1, tag = unitTag } end
    if id2 ~= 0 then
        unitTag = cfg.id2Tag or unitTag
        checks[#checks + 1] = { id = id2, tag = unitTag }
    end
    if id3 ~= 0 then
        unitTag = cfg.id3Tag or unitTag
        checks[#checks + 1] = { id = id3, tag = unitTag }
    end

    for _, c in ipairs(checks) do
        for i = 1, GetNumBuffs(c.tag) do
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityIdNew, canClickOff, castByPlayer = GetUnitBuffInfo(c.tag, i)
            if c.id == abilityIdNew and castByPlayer then
                ActionBar.OnEffectChanged(EFFECT_RESULT_GAINED, nil, nil, c.tag, timeStarted, timeEnding, stackCount, nil, buffType, effectType, abilityType, statusEffectType, nil, nil, abilityId, COMBAT_UNIT_TYPE_PLAYER, true, nil)
                return
            end
        end
    end
end

local isStackCounter =
{
    [61905] = true,  -- Grim Focus
    [61928] = true,  -- Relentless Focus
    [61920] = true,  -- Merciless Resolve
    [130293] = true, -- Bound Armaments
}

local isStackBaseAbility =
{
    [61902] = true, -- Grim Focus
    [61927] = true, -- Relentless Focus
    [61919] = true, -- Merciless Resolve
    [24165] = true, -- Bound Armaments
}

-- Proc sound thresholds: abilityId -> { threshold1, threshold2 }. Used by IsGrimFocus and IsBoundArmaments.
local PROC_SOUND_THRESHOLDS =
{
    [122585] = { 5, 10 }, -- Grim Focus
    [122587] = { 5, 10 }, -- Relentless Focus
    [122586] = { 5, 10 }, -- Merciless Resolve
    [203447] = { 4, 8 },  -- Bound Armaments
}

--- Iterate over front and back toggled slots for abilityId; call fn(slotNum) for each valid slot.
local function ForEachToggledSlot(abilityId, fn)
    local front = g_toggledSlotsFront[abilityId]
    local back = g_toggledSlotsBack[abilityId]
    if front and GetCustomToggleControl(front) then fn(front) end
    if back and GetCustomToggleControl(back) then fn(back) end
end

--- Set stack label on all toggled slots for abilityId. textOrNil: number to display, or nil/0 for empty.
local function SetToggledStackLabels(abilityId, textOrNil)
    local text = (textOrNil and textOrNil > 0) and tostring(textOrNil) or ""
    ForEachToggledSlot(abilityId, function (slotNum)
        g_uiCustomToggle[slotNum].stack:SetText(text)
    end)
end

--- Hide all toggled slots for abilityId.
local function HideToggledSlots(abilityId)
    ForEachToggledSlot(abilityId, function (slotNum)
        ActionBar.HideSlot(slotNum, abilityId)
    end)
end

--- Show all toggled slots for abilityId.
local function ShowToggledSlots(abilityId, currentTime)
    if g_toggledSlotsFront[abilityId] then
        ActionBar.ShowSlot(g_toggledSlotsFront[abilityId], abilityId, currentTime, false)
    end
    if g_toggledSlotsBack[abilityId] then
        ActionBar.ShowSlot(g_toggledSlotsBack[abilityId], abilityId, currentTime, false)
    end
end

--- Play proc sound at stack thresholds. Used by Grim Focus and Bound Armaments.
local function PlayProcSoundAtStacks(abilityId, stackCount)
    local thresholds = PROC_SOUND_THRESHOLDS[abilityId]
    if not thresholds or not ActionBar.SV.ShowTriggered or not ActionBar.SV.ProcEnableSound then return end
    if not g_boundArmamentsPlayed[abilityId] then
        g_boundArmamentsPlayed[abilityId] = {}
    end
    local t1, t2 = thresholds[1], thresholds[2]
    if (stackCount == t1 or stackCount == t2) and not g_boundArmamentsPlayed[abilityId][stackCount] then
        PlaySound(g_ProcSound)
        PlaySound(g_ProcSound)
        g_boundArmamentsPlayed[abilityId][stackCount] = true
    end
    if stackCount < t1 then
        g_boundArmamentsPlayed[abilityId][t1] = false
        g_boundArmamentsPlayed[abilityId][t2] = false
    elseif stackCount < t2 and stackCount > t1 then
        g_boundArmamentsPlayed[abilityId][t2] = false
    end
end

--- Try BarHighlightSwap if abilityId has a CheckOnFade config.
local function TryBarHighlightSwap(abilityId)
    if Effects.BarHighlightCheckOnFade[abilityId] then
        ActionBar.BarHighlightSwap(abilityId)
    end
end

--- Handle ground effect FADED: mine stack decrement, stack labels, HideSlot when stacks reach 0, or non-mine fade.
local function OnGroundEffectFaded(abilityId)
    if abilityId == 32958 then return end -- Ignore Shifting Standard
    local currentTime = GetGameTimeMilliseconds()
    if g_protectAbilityRemoval[abilityId] and g_protectAbilityRemoval[abilityId] >= currentTime then return end

    if Effects.IsGroundMineAura[abilityId] or Effects.IsGroundMineStack[abilityId] then
        if not g_mineStacks[abilityId] then return end
        g_mineStacks[abilityId] = g_mineStacks[abilityId] - Effects.EffectGroundDisplay[abilityId].stackRemove

        if ActionBar.SV.BarShowLabel and not Effects.HideGroundMineStacks[abilityId] then
            SetToggledStackLabels(abilityId, g_mineStacks[abilityId] > 0 and g_mineStacks[abilityId] or nil)
        end

        if g_mineStacks[abilityId] == 0 and not g_mineNoTurnOff[abilityId] then
            if g_toggledSlotsRemain[abilityId] then HideToggledSlots(abilityId) end
            g_toggledSlotsRemain[abilityId] = nil
            g_toggledSlotsStack[abilityId] = nil
            TryBarHighlightSwap(abilityId)
        end
    else
        if g_barNoRemove[abilityId] then return end
        if g_toggledSlotsRemain[abilityId] then HideToggledSlots(abilityId) end
        g_toggledSlotsRemain[abilityId] = nil
        g_toggledSlotsStack[abilityId] = nil
    end
end

--- Handle ground effect GAINED: mine stack init, ShowSlot.
local function OnGroundEffectGained(abilityId, endTime, stackCount)
    if g_mineNoTurnOff[abilityId] then g_mineNoTurnOff[abilityId] = nil end
    local currentTime = GetGameTimeMilliseconds()
    g_protectAbilityRemoval[abilityId] = currentTime + 150

    if Effects.IsGroundMineAura[abilityId] then
        g_mineStacks[abilityId] = Effects.EffectGroundDisplay[abilityId].stackReset
    elseif Effects.IsGroundMineStack[abilityId] then
        g_mineStacks[abilityId] = g_mineStacks[abilityId] and (g_mineStacks[abilityId] + Effects.EffectGroundDisplay[abilityId].stackRemove) or 1
        if g_mineStacks[abilityId] > Effects.EffectGroundDisplay[abilityId].stackReset then
            g_mineStacks[abilityId] = Effects.EffectGroundDisplay[abilityId].stackReset
        end
    end

    if ActionBar.SV.ShowToggled and (g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId]) then
        g_toggledSlotsPlayer[abilityId] = true
        g_toggledSlotsRemain[abilityId] = 1000 * endTime
        g_toggledSlotsStack[abilityId] = stackCount
        ShowToggledSlots(abilityId, currentTime)
    end
end

--- Handle non-ground effect FADED: Grim Focus stack clear, proc stop, toggle hide, BarHighlightSwap.
local function OnEffectFaded(abilityId)
    if isStackCounter[abilityId] then
        for k in pairs(isStackBaseAbility) do
            g_toggledSlotsStack[k] = nil
            if ActionBar.SV.ShowToggled and ActionBar.SV.BarShowLabel and (g_toggledSlotsFront[k] or g_toggledSlotsBack[k]) then
                SetToggledStackLabels(k, nil)
            end
        end
    end

    if g_barNoRemove[abilityId] then
        TryBarHighlightSwap(abilityId)
        return
    end

    if g_triggeredSlotsRemain[abilityId] then
        if g_triggeredSlotsFront[abilityId] and g_uiProcAnimation[g_triggeredSlotsFront[abilityId]] then
            g_uiProcAnimation[g_triggeredSlotsFront[abilityId]]:Stop()
        end
        if g_triggeredSlotsBack[abilityId] and g_uiProcAnimation[g_triggeredSlotsBack[abilityId]] then
            g_uiProcAnimation[g_triggeredSlotsBack[abilityId]]:Stop()
        end
        g_triggeredSlotsRemain[abilityId] = nil
    end

    if g_toggledSlotsRemain[abilityId] then
        HideToggledSlots(abilityId)
        g_toggledSlotsRemain[abilityId] = nil
        if not isStackBaseAbility[abilityId] then g_toggledSlotsStack[abilityId] = nil end
    end

    TryBarHighlightSwap(abilityId)
end

--- Handle non-ground effect GAINED: proc sound, proc animation, ShowSlot, Grim Focus stack labels.
local function OnEffectGained(abilityId, unitTag, endTime, stackCount, changeType)
    PlayProcSoundAtStacks(abilityId, stackCount)

    if g_triggeredSlotsFront[abilityId] or g_triggeredSlotsBack[abilityId] then
        if ActionBar.SV.ShowTriggered then
            local currentTime = GetGameTimeMilliseconds()
            if ActionBar.SV.ProcEnableSound and unitTag == "player" and g_triggeredSlotsFront[abilityId] then
                if abilityId == 46327 and changeType == EFFECT_RESULT_GAINED then
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
                else
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
                end
            end
            g_triggeredSlotsRemain[abilityId] = 1000 * endTime
            local remain = g_triggeredSlotsRemain[abilityId] - currentTime
            if g_triggeredSlotsFront[abilityId] then
                ActionBar.PlayProcAnimations(g_triggeredSlotsFront[abilityId])
                if ActionBar.SV.BarShowLabel and g_uiProcAnimation[g_triggeredSlotsFront[abilityId]] then
                    g_uiProcAnimation[g_triggeredSlotsFront[abilityId]].procLoopTexture.label:SetText(FormatDurationSeconds(remain))
                end
            end
            if g_triggeredSlotsBack[abilityId] then
                ActionBar.PlayProcAnimations(g_triggeredSlotsBack[abilityId])
                if ActionBar.SV.BarShowLabel and g_uiProcAnimation[g_triggeredSlotsBack[abilityId]] then
                    g_uiProcAnimation[g_triggeredSlotsBack[abilityId]].procLoopTexture.label:SetText(FormatDurationSeconds(remain))
                end
            end
        end
    end

    if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
        if ActionBar.SV.ShowToggled then
            if abilityId == 34117 and stackCount == 0 then
                HideToggledSlots(abilityId)
                g_toggledSlotsRemain[abilityId] = nil
                g_toggledSlotsStack[abilityId] = nil
            else
                local currentTime = GetGameTimeMilliseconds()
                g_toggledSlotsRemain[abilityId] = 1000 * endTime
                if not isStackBaseAbility[abilityId] then g_toggledSlotsStack[abilityId] = stackCount end
                ShowToggledSlots(abilityId, currentTime)
            end
        end
    end

    if isStackCounter[abilityId] then
        for i = 1, GetNumBuffs(unitTag) do
            local baseId = select(11, GetUnitBuffInfo(unitTag, i))
            if isStackBaseAbility[baseId] then
                g_toggledSlotsStack[baseId] = stackCount
                if ActionBar.SV.ShowToggled and ActionBar.SV.BarShowLabel and (g_toggledSlotsFront[baseId] or g_toggledSlotsBack[baseId]) then
                    SetToggledStackLabels(baseId, g_toggledSlotsStack[baseId] and g_toggledSlotsStack[baseId] > 0 and g_toggledSlotsStack[baseId] or nil)
                end
            end
        end
    end
end

-- Extra returns here - passThrough & savedId
--- Handles EVENT_EFFECT_CHANGED: bar highlights, cast bar break, SETHOTBAR backbar hide, BarHighlightSwap, etc.
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
--- @param passThrough any
--- @param savedId integer
function ActionBar.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
    -- If we're displaying a fake bar highlight then bail out here (sometimes we need a fake aura that doesn't end to simulate effects that can be overwritten, such as Major/Minor buffs.
    -- Technically we don't want to stop the highlight of the original ability since we can only track one buff per slot and overwriting the buff with a longer duration buff shouldn't throw the player off by making the glow disappear earlier.
    if g_barFakeAura[abilityId] and not passThrough then
        return
    end
    -- Bail out if this effect wasn't cast by the player.
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    -- Auto-hide back bar when abilityType is SETHOTBAR (e.g. Volendrung mythic forces weapon bar swap)
    if ActionBar.SV.BarShowBack and unitTag == "player" and abilityType == ABILITY_TYPE_SETHOTBAR then
        if changeType == EFFECT_RESULT_GAINED then
            if g_backbarContainer then
                g_backbarContainer:SetHidden(true)
            end
        elseif changeType == EFFECT_RESULT_FADED then
            if g_backbarContainer then
                g_backbarContainer:SetHidden(false)
            end
            ActionBar.BackbarToggleSettings()
        end
        return
    end

    -- Update ultimate label on vampire stage change.
    if Effects.IsVamp[abilityId] and changeType == EFFECT_RESULT_GAINED then
        ActionBar.UpdateUltimateLabel()
    end

    if Castbar.CastBreakOnRemoveEffect[abilityId] and changeType == EFFECT_RESULT_FADED then
        ActionBar.StopCastBar()
        if abilityId == 33208 then -- Devour (Werewolf)
            return
        end
    end

    -- If this effect is on the player than as long as it remains it won't fade when we mouseover another target.
    if unitTag == "player" then
        if changeType ~= EFFECT_RESULT_FADED then
            g_toggledSlotsPlayer[abilityId] = true
        else
            g_toggledSlotsPlayer[abilityId] = nil
        end
    end

    if (Effects.EffectGroundDisplay[abilityId] or Effects.LinkedGroundMine[abilityId]) and not passThrough then
        if Effects.LinkedGroundMine[abilityId] then abilityId = Effects.LinkedGroundMine[abilityId] end
        if changeType == EFFECT_RESULT_FADED then
            OnGroundEffectFaded(abilityId)
        else
            OnGroundEffectGained(abilityId, endTime, stackCount)
        end
        return
    end

    -- Hijack abilityId for extra bar highlights (skip if FancyActionBar active)
    if not isFancyActionBarEnabled then
        local extraId = Effects.BarHighlightExtraId[abilityId]
        if extraId then
            abilityId = extraId
            if Effects.IsGroundMineAura[abilityId] then
                g_toggledSlotsPlayer[abilityId] = nil
                if unitTag == "reticleover" then g_mineNoTurnOff[abilityId] = true end
            end
        end
    end

    if unitTag ~= "player" and unitTag ~= "reticleover" then return end

    if changeType == EFFECT_RESULT_FADED then
        OnEffectFaded(abilityId)
    else
        OnEffectGained(abilityId, unitTag, endTime, stackCount, changeType)
    end
end

-- -----------------------------------------------------------------------------
--- Hides the custom toggle control for a slot; updates backbar/saturation/ultimate pct as needed.
--- @param slotNum integer
--- @param abilityId integer
function ActionBar.HideSlot(slotNum, abilityId)
    local c = GetCustomToggleControl(slotNum)
    if c then
        c:SetHidden(true)
    end
    if slotNum > BACKBAR_INDEX_OFFSET then
        if slotNum ~= BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
            ActionBar.BackbarHideSlot(slotNum)
            ActionBar.ToggleBackbarSaturation(slotNum, ActionBar.SV.BarDarkUnused)
        end
    end
    if slotNum == g_ultimateSlot and ActionBar.SV.UltimatePctEnabled and IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        uiUltimate.LabelPct:SetHidden(false)
    end
end

-- -----------------------------------------------------------------------------
--- Shows the custom toggle for a slot, updates backbar/saturation, and sets duration/stack labels.
--- @param slotNum integer
--- @param abilityId integer
--- @param currentTimeMS integer
--- @param desaturate boolean
function ActionBar.ShowSlot(slotNum, abilityId, currentTimeMS, desaturate)
    ActionBar.ShowCustomToggle(slotNum)
    if slotNum > BACKBAR_INDEX_OFFSET then
        if slotNum ~= BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
            ActionBar.BackbarShowSlot(slotNum)
            ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
        end
    end
    if slotNum == 8 and ActionBar.SV.UltimatePctEnabled then
        uiUltimate.LabelPct:SetHidden(true)
    end
    if ActionBar.SV.BarShowLabel then
        local c = GetCustomToggleControl(slotNum)
        if not c then
            return
        end
        local remain = g_toggledSlotsRemain[abilityId] - currentTimeMS
        c.label:SetText(SetBarRemainLabel(remain, abilityId))
        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
            c.stack:SetText(g_toggledSlotsStack[abilityId])
        elseif g_mineStacks[abilityId] and g_mineStacks[abilityId] > 0 then
            -- No stack for Time Freeze
            if not Effects.HideGroundMineStacks[abilityId] then
                c.stack:SetText(g_mineStacks[abilityId])
            end
        else
            c.stack:SetText("")
        end
    end
end

-- -----------------------------------------------------------------------------
--- Hides the backbar slot control when BarHideUnused is enabled.
--- @param slotNum integer
function ActionBar.BackbarHideSlot(slotNum)
    if ActionBar.SV.BarHideUnused then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(true)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Shows the backbar slot control when BarShowBack is enabled.
--- @param slotNum integer
function ActionBar.BackbarShowSlot(slotNum)
    -- Unhide the slot
    if ActionBar.SV.BarShowBack then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(false)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Sets backbar slot icon desaturation/dark unused state per SV.
--- @param slotNum integer
--- @param desaturate boolean
function ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
    local button = g_backbarButtons[slotNum]
    if ActionBar.SV.BarDarkUnused then
        ZO_ActionSlot_SetUnusable(button.icon, desaturate, false)
    end
    if ActionBar.SV.BarDesaturateUnused then
        local saturation = desaturate and 1 or 0
        button.icon:SetDesaturation(saturation)
    end
end

-- -----------------------------------------------------------------------------
local ACTION_BUTTON_BGS = { ability = "EsoUI/Art/ActionBar/abilityInset.dds", item = "EsoUI/Art/ActionBar/quickslotBG.dds" }
local ACTION_BUTTON_BORDERS = { normal = "EsoUI/Art/ActionBar/abilityFrame64_up.dds", mouseDown = "EsoUI/Art/ActionBar/abilityFrame64_down.dds" }
local FORCE_SUPPRESS_COOLDOWN_SOUND = true
local BOUNCE_DURATION_MS = 500

local ApplyStyle = function (self, template)
    WINDOW_MANAGER:ApplyTemplateToControl(self.slot, template)

    local isGamepad = IsInGamepadPreferredMode()
    self.button:SetNormalTexture(isGamepad and "" or ACTION_BUTTON_BORDERS.normal)
    self.button:SetPressedTexture(isGamepad and "" or ACTION_BUTTON_BORDERS.mouseDown)
    self.countText:SetFont(isGamepad and "ZoFontGamepadBold27" or "ZoFontGameShadow")
    self:ApplySwapAnimationStyle()

    if ZO_ActionBar_IsUltimateSlot(self:GetSlot(), self:GetHotbarCategory()) then
        local decoration = self.slot:GetNamedChild("Decoration")
        if decoration then
            decoration:SetHidden(isGamepad)
        end
    end

    if self.showingCooldown then
        self.cooldown:SetHidden(isGamepad)

        if isGamepad then
            local slotNum = self:GetSlot()
            local hotbarCategory = self:GetHotbarCategory()
            local remain = GetSlotCooldownInfo(slotNum, hotbarCategory)
            self:PlayAbilityUsedBounce(BOUNCE_DURATION_MS + remain)

            if not self.itemQtyFailure then
                self.icon:SetDesaturation(0)
            end
        else
            self:ResetBounceAnimation()
        end
    else
        self:ResetBounceAnimation()
    end

    self:SetCooldownEdgeState(self.showingCooldown)
    self:UpdateUsable()
end

-- Called on initialization and when swapping in and out of Gamepad mode
--- Applies platform style (keyboard/gamepad) to backbar button layout and anchors.
function ActionBar.BackbarSetupTemplate()
    local style = GetPlatformConstants()
    local weaponSwapControl = style.weaponSwapControl

    -- Set positions for new buttons, modified from actionbar.lua - function ApplyStyle(style) )
    local lastButton
    local buttonTemplate = ZO_GetPlatformTemplate("ZO_ActionButton")
    for i = BAR_INDEX_START, BAR_INDEX_END do
        -- Get our backbar button
        local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]

        -- Normal slots
        if i > 2 and i < 8 then
            local anchorTarget = lastButton and lastButton.slot
            if not lastButton then
                anchorTarget = weaponSwapControl
            end
            targetButton:ApplyAnchor(anchorTarget, style.abilitySlotOffsetX)
            ApplyStyle(targetButton, buttonTemplate)
        end

        lastButton = targetButton
    end

    -- Anchor the backbar to the normal action bar with spacing
    local offsetY = ACTION_BAR:GetHeight() * style.backbarHeightMultiplier
    local finalOffset = -(offsetY * style.backbarOffsetMultiplier)
    local ActionButton3 = GetControl("ActionButton3")
    local ActionButton53 = GetControl("ActionButton53")
    if ActionButton53 then
        ActionButton53:ClearAnchors()
        ActionButton53:SetAnchor(CENTER, ActionButton3, CENTER, 0, finalOffset)
    end
end

-- -----------------------------------------------------------------------------
-- Called from the menu and on init
--- Shows/hides backbar container and slots per SV (BarShowBack, BarHideUnused, BarDarkUnused, etc.).
function ActionBar.BackbarToggleSettings()
    -- If BarShowBack is on, check for bar-swap disablers - keep backbar hidden while active
    if ActionBar.SV.BarShowBack and g_backbarContainer then
        if GetUnitLevel("player") < GetWeaponSwapUnlockedLevel() then
            g_backbarContainer:SetHidden(true)
            return
        elseif OakensoulEquipped() then
            g_backbarContainer:SetHidden(true)
            return
        end
        for i = 1, GetNumBuffs("player") do
            local _, _, _, _, _, _, _, _, abilityType = GetUnitBuffInfo("player", i)
            if abilityType == ABILITY_TYPE_SETHOTBAR then
                g_backbarContainer:SetHidden(true)
                return
            end
        end
    end

    if g_backbarContainer then
        g_backbarContainer:SetHidden(false)
    end

    for i = BAR_INDEX_START, BACKBAR_INDEX_END do
        -- Get our backbar button
        local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]

        if ActionBar.SV.BarShowBack and not ActionBar.SV.BarHideUnused then
            targetButton.slot:SetHidden(false)
        end
        ZO_ActionSlot_SetUnusable(targetButton.icon, ActionBar.SV.BarDarkUnused, false)
        local saturation = ActionBar.SV.BarDesaturateUnused and 1 or 0
        targetButton.icon:SetDesaturation(saturation)

        if ActionBar.SV.BarHideUnused or not ActionBar.SV.BarShowBack then
            targetButton.slot:SetHidden(true)
        end
    end
end

-- -----------------------------------------------------------------------------
--- Creates the cast bar TLW, preview, backdrop, icon, bar, and registers it with HUD scenes.
function ActionBar.CreateCastBar()
    local fontString
    if IsConsoleUI() then
        fontString = "ZoFontGamepad18"
    else
        fontString = "ZoFontGameMedium"
    end
    uiTlw.castBar = windowManager:CreateTopLevelWindow("LUIE_ACTIONBAR_CASTBAR_TLC")
    uiTlw.castBar:SetClampedToScreen(true)
    uiTlw.castBar:SetMouseEnabled(false)
    uiTlw.castBar:SetMovable(false)
    uiTlw.castBar:SetHidden(true)

    uiTlw.castBar:SetDimensions(ActionBar.SV.CastBarSizeW + ActionBar.SV.CastBarIconSize + 4, ActionBar.SV.CastBarSizeH)

    -- Setup Preview
    uiTlw.castBar.preview = windowManager:CreateControl("$(parent)Preview", uiTlw.castBar, CT_BACKDROP)
    uiTlw.castBar.preview:SetCenterColor(0, 0, 0, 0.4)
    uiTlw.castBar.preview:SetEdgeColor(0, 0, 0, 0.6)
    uiTlw.castBar.preview:SetEdgeTexture("", 8, 1, 1, 1)
    uiTlw.castBar.preview:SetDrawLayer(DL_BACKGROUND)
    uiTlw.castBar.preview:SetAnchorFill(uiTlw.castBar)
    uiTlw.castBar.preview:SetHidden(true)
    uiTlw.castBar.previewLabel = windowManager:CreateControl("$(parent)Label", uiTlw.castBar.preview, CT_LABEL)
    uiTlw.castBar.previewLabel:SetFont(fontString)
    uiTlw.castBar.previewLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    uiTlw.castBar.previewLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    uiTlw.castBar.previewLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    uiTlw.castBar.previewLabel:SetAnchor(CENTER, uiTlw.castBar.preview, CENTER)
    uiTlw.castBar.previewLabel:SetText("Cast Bar")

    -- Callback used to hide anchor coords preview label on movement start
    uiTlw.castBar:SetHandler("OnMoveStart", function ()
        eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
            uiTlw.castBar.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", uiTlw.castBar:GetLeft(), uiTlw.castBar:GetTop()))
        end)
    end)

    -- Callback used to save new position of frames
    uiTlw.castBar:SetHandler("OnMoveStop", function ()
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
        ActionBar.SV.CastbarOffsetX = uiTlw.castBar:GetLeft()
        ActionBar.SV.CastbarOffsetY = uiTlw.castBar:GetTop()
        ActionBar.SV.CastBarCustomPosition = { uiTlw.castBar:GetLeft(), uiTlw.castBar:GetTop() }
    end)

    uiTlw.castBar.preview.anchorTexture = windowManager:CreateControl("$(parent)AnchorTexture", uiTlw.castBar.preview, CT_TEXTURE)
    uiTlw.castBar.preview.anchorTexture:SetAnchor(TOPLEFT, uiTlw.castBar.preview, TOPLEFT)
    uiTlw.castBar.preview.anchorTexture:SetDimensions(16, 16)
    uiTlw.castBar.preview.anchorTexture:SetTexture("/esoui/art/reticle/border_topleft.dds")
    uiTlw.castBar.preview.anchorTexture:SetDrawLayer(DL_OVERLAY)
    uiTlw.castBar.preview.anchorTexture:SetColor(1, 1, 0, 0.9)

    uiTlw.castBar.preview.anchorLabel = windowManager:CreateControl("$(parent)AnchorLabel", uiTlw.castBar.preview, CT_LABEL)
    uiTlw.castBar.preview.anchorLabel:SetFont(fontString)
    uiTlw.castBar.preview.anchorLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    uiTlw.castBar.preview.anchorLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    uiTlw.castBar.preview.anchorLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    uiTlw.castBar.preview.anchorLabel:SetAnchor(BOTTOMLEFT, uiTlw.castBar.preview, TOPLEFT, 0, -1)
    uiTlw.castBar.preview.anchorLabel:SetText("xxx, yyy")
    uiTlw.castBar.preview.anchorLabel:SetColor(1, 1, 0, 1)
    uiTlw.castBar.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
    uiTlw.castBar.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
    uiTlw.castBar.preview.anchorLabelBg = windowManager:CreateControl("$(parent)Bg", uiTlw.castBar.preview.anchorLabel, CT_BACKDROP)
    uiTlw.castBar.preview.anchorLabelBg:SetCenterColor(0, 0, 0, 1)
    uiTlw.castBar.preview.anchorLabelBg:SetEdgeColor(0, 0, 0, 1)
    uiTlw.castBar.preview.anchorLabelBg:SetEdgeTexture("", 8, 1, 1, 1)
    uiTlw.castBar.preview.anchorLabelBg:SetDrawLayer(DL_BACKGROUND)
    uiTlw.castBar.preview.anchorLabelBg:SetAnchorFill(uiTlw.castBar.preview.anchorLabel)
    uiTlw.castBar.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
    uiTlw.castBar.preview.anchorLabelBg:SetDrawTier(DT_LOW)

    local fragment = ZO_HUDFadeSceneFragment:New(uiTlw.castBar, 0, 0)

    sceneManager:GetScene("hud"):AddFragment(fragment)
    sceneManager:GetScene("hudui"):AddFragment(fragment)
    sceneManager:GetScene("siegeBar"):AddFragment(fragment)
    sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

    castbar = windowManager:CreateControl("$(parent)Backdrop", uiTlw.castBar, CT_BACKDROP)
    castbar:SetCenterColor(0, 0, 0, 0.5)
    castbar:SetEdgeColor(0, 0, 0, 1)
    castbar:SetEdgeTexture("", 8, 1, 1, 1)
    castbar:SetDrawLayer(DL_BACKGROUND)
    castbar:SetAnchor(LEFT, uiTlw.castBar, LEFT)

    castbar.starts = 0
    castbar.ends = 0
    castbar.remain = 0

    castbar:SetDimensions(ActionBar.SV.CastBarIconSize, ActionBar.SV.CastBarIconSize)

    castbar.back = windowManager:CreateControl("$(parent)Back", castbar, CT_TEXTURE)
    castbar.back:SetTexture(LUIE_MEDIA_ICONS_ICON_BORDER_ICON_BORDER_DDS)
    castbar.back:SetAnchor(TOPLEFT, castbar, TOPLEFT)
    castbar.back:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT)

    castbar.iconbg = windowManager:CreateControl("$(parent)IconBg", castbar, CT_BACKDROP)
    castbar.iconbg:SetCenterColor(0, 0, 0, 0.9)
    castbar.iconbg:SetEdgeColor(0, 0, 0, 0.9)
    castbar.iconbg:SetEdgeTexture("", 8, 1, 1, 1)
    castbar.iconbg:SetDrawLayer(DL_BACKGROUND)
    castbar.iconbg:SetDrawLevel(castbar:GetDrawLevel() + 1)
    castbar.iconbg:SetAnchor(TOPLEFT, castbar, TOPLEFT, 3, 3)
    castbar.iconbg:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT, -3, -3)

    castbar.icon = windowManager:CreateControl("$(parent)Icon", castbar, CT_TEXTURE)
    castbar.icon:SetTexture("/esoui/art/icons/icon_missing.dds")
    castbar.icon:SetDrawLayer(DL_CONTROLS)
    castbar.icon:SetAnchor(TOPLEFT, castbar, TOPLEFT, 3, 3)
    castbar.icon:SetAnchor(BOTTOMRIGHT, castbar, BOTTOMRIGHT, -3, -3)

    castbar.bar =
    {
        ["backdrop"] = windowManager:CreateControl("$(parent)Backdrop", castbar, CT_BACKDROP),
        ["bar"] = windowManager:CreateControl("$(parent)Bar", castbar, CT_STATUSBAR),
        ["name"] = windowManager:CreateControl("$(parent)Name", castbar, CT_LABEL),
        ["timer"] = windowManager:CreateControl("$(parent)Time", castbar, CT_LABEL),
    }
    castbar.bar.backdrop:SetCenterColor(0, 0, 0, 0.4)
    castbar.bar.backdrop:SetEdgeColor(0, 0, 0, 0.6)
    castbar.bar.backdrop:SetEdgeTexture("", 8, 1, 1, 1)
    castbar.bar.backdrop:SetDrawLayer(DL_BACKGROUND)
    castbar.bar.backdrop:SetDimensions(ActionBar.SV.CastBarSizeW, ActionBar.SV.CastBarSizeH)
    castbar.bar.bar:SetDimensions(ActionBar.SV.CastBarSizeW - 4, ActionBar.SV.CastBarSizeH - 4)
    castbar.bar.name:SetFont(g_castbarFont or fontString)
    castbar.bar.name:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    castbar.bar.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    castbar.bar.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    castbar.bar.timer:SetFont(g_castbarFont or fontString)
    castbar.bar.timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    castbar.bar.timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    castbar.bar.timer:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    castbar.id = 0

    castbar.bar.backdrop:SetEdgeTexture("", 8, 2, 2, 1)
    castbar.bar.backdrop:SetDrawLayer(DL_BACKGROUND)
    castbar.bar.backdrop:SetDrawLevel(castbar:GetDrawLevel() + 1)
    castbar.bar.bar:SetMinMax(0, 1)
    castbar.bar.backdrop:SetCenterColor((0.1 * 0.50), (0.1 * 0.50), (0.1 * 0.50), 0.75)
    local startR, startG, startB, startA = 0, 47 / 255, 130 / 255, 1
    local endR, endG, endB, endA = 82 / 255, 215 / 255, 1, 1
    castbar.bar.bar:SetGradientColors(startR, startG, startB, startA, endR, endG, endB, endA)
    castbar.bar.backdrop:SetCenterColor((0.1 * ActionBar.SV.CastBarGradientC1[1]), (0.1 * ActionBar.SV.CastBarGradientC1[2]), (0.1 * ActionBar.SV.CastBarGradientC1[3]), 0.75)
    startR, startG, startB, startA = ActionBar.SV.CastBarGradientC1[1], ActionBar.SV.CastBarGradientC1[2], ActionBar.SV.CastBarGradientC1[3], ActionBar.SV.CastBarGradientC1[4]
    endR, endG, endB, endA = ActionBar.SV.CastBarGradientC2[1], ActionBar.SV.CastBarGradientC2[2], ActionBar.SV.CastBarGradientC2[3], ActionBar.SV.CastBarGradientC2[4]
    castbar.bar.bar:SetGradientColors(startR, startG, startB, startA, endR, endG, endB, endA)

    castbar.bar.backdrop:ClearAnchors()
    castbar.bar.backdrop:SetAnchor(LEFT, castbar, RIGHT, 4, 0)

    castbar.bar.timer:ClearAnchors()
    castbar.bar.timer:SetAnchor(RIGHT, castbar.bar.backdrop, RIGHT, -4, 0)
    castbar.bar.timer:SetHidden(true)

    castbar.bar.name:ClearAnchors()
    castbar.bar.name:SetAnchor(LEFT, castbar.bar.backdrop, LEFT, 4, 0)
    castbar.bar.name:SetHidden(true)

    castbar.bar.bar:SetTexture(LUIE.StatusbarTextures[ActionBar.SV.CastBarTexture])
    castbar.bar.bar:ClearAnchors()
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)

    castbar.bar.timer:SetText("Timer")
    castbar.bar.name:SetText("Name")

    castbar:SetHidden(true)
end

-- -----------------------------------------------------------------------------
--- Resizes cast bar and icon to SV dimensions (CastBarSizeW, CastBarSizeH, CastBarIconSize).
function ActionBar.ResizeCastBar()
    uiTlw.castBar:SetDimensions(ActionBar.SV.CastBarSizeW + ActionBar.SV.CastBarIconSize + 4, ActionBar.SV.CastBarSizeH)
    castbar:ClearAnchors()
    castbar:SetAnchor(LEFT, uiTlw.castBar, LEFT)

    castbar:SetDimensions(ActionBar.SV.CastBarIconSize, ActionBar.SV.CastBarIconSize)
    castbar.bar.backdrop:SetDimensions(ActionBar.SV.CastBarSizeW, ActionBar.SV.CastBarSizeH)
    castbar.bar.bar:SetDimensions(ActionBar.SV.CastBarSizeW - 4, ActionBar.SV.CastBarSizeH - 4)

    castbar.bar.backdrop:ClearAnchors()
    castbar.bar.backdrop:SetAnchor(LEFT, castbar, RIGHT, 4, 0)

    castbar.bar.timer:ClearAnchors()
    castbar.bar.timer:SetAnchor(RIGHT, castbar.bar.backdrop, RIGHT, -4, 0)

    castbar.bar.name:ClearAnchors()
    castbar.bar.name:SetAnchor(LEFT, castbar.bar.backdrop, LEFT, 4, 0)

    castbar.bar.bar:ClearAnchors()
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)
    castbar.bar.bar:SetAnchor(CENTER, castbar.bar.backdrop, CENTER, 0, 0)

    ActionBar.SetCastBarPosition()
end

-- -----------------------------------------------------------------------------
--- Applies cast bar texture, gradient, font, and visibility from SV; called on init and settings change.
function ActionBar.UpdateCastBar()
    if not ActionBar.SV.CastBarEnable then
        return
    end
    castbar.bar.name:SetFont(g_castbarFont)
    castbar.bar.timer:SetFont(g_castbarFont)
    castbar.bar.bar:SetTexture(LUIE.StatusbarTextures[ActionBar.SV.CastBarTexture])
    castbar.bar.backdrop:SetCenterColor((0.1 * ActionBar.SV.CastBarGradientC1[1]), (0.1 * ActionBar.SV.CastBarGradientC1[2]), (0.1 * ActionBar.SV.CastBarGradientC1[3]), 0.75 * ActionBar.SV.CastBarGradientC1[4])
    local startR, startG, startB, startA = ActionBar.SV.CastBarGradientC1[1], ActionBar.SV.CastBarGradientC1[2], ActionBar.SV.CastBarGradientC1[3], ActionBar.SV.CastBarGradientC1[4]
    local endR, endG, endB, endA = ActionBar.SV.CastBarGradientC2[1], ActionBar.SV.CastBarGradientC2[2], ActionBar.SV.CastBarGradientC2[3], ActionBar.SV.CastBarGradientC2[4]
    castbar.bar.bar:SetGradientColors(startR, startG, startB, startA, endR, endG, endB, endA)
end

-- -----------------------------------------------------------------------------
--- Resets cast bar position to default (center screen).
function ActionBar.ResetCastBarPosition()
    if not ActionBar.SV.CastBarEnable then
        return
    end
    ActionBar.SV.CastbarOffsetX = nil
    ActionBar.SV.CastbarOffsetY = nil
    ActionBar.SV.CastBarCustomPosition = nil
    ActionBar.SetCastBarPosition()
    ActionBar.SetMovingState(false)
end

-- -----------------------------------------------------------------------------
--- Positions cast bar from SV (custom or default); called on load and when unlocking movement.
function ActionBar.SetCastBarPosition()
    if uiTlw.castBar and uiTlw.castBar:GetType() == CT_TOPLEVELCONTROL then
        uiTlw.castBar:ClearAnchors()

        if ActionBar.SV.CastbarOffsetX ~= nil and ActionBar.SV.CastbarOffsetY ~= nil then
            uiTlw.castBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ActionBar.SV.CastbarOffsetX, ActionBar.SV.CastbarOffsetY)
        else
            uiTlw.castBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, 320)
        end
    end

    local savedPos = ActionBar.SV.CastBarCustomPosition
    uiTlw.castBar.preview.anchorLabel:SetText((savedPos ~= nil and #savedPos == 2) and zo_strformat("<<1>>, <<2>>", savedPos[1], savedPos[2]) or "default")
end

-- -----------------------------------------------------------------------------
---
--- @param state boolean
function ActionBar.SetMovingState(state)
    if not ActionBar.Enabled then
        return
    end
    ActionBar.CastBarUnlocked = state
    if uiTlw.castBar and uiTlw.castBar:GetType() == CT_TOPLEVELCONTROL then
        ActionBar.GenerateCastbarPreview(state)
        uiTlw.castBar:SetMouseEnabled(state)
        uiTlw.castBar:SetMovable(state)
    end
end

-- -----------------------------------------------------------------------------
-- Called by ActionBar.SetMovingState from the menu as well as by ActionBar.OnUpdateCastbar when preview is enabled
---
--- @param state boolean
function ActionBar.GenerateCastbarPreview(state)
    local previewIcon = "esoui/art/icons/icon_missing.dds"
    castbar.icon:SetTexture(previewIcon)
    if ActionBar.SV.CastBarLabel then
        local previewName = "Test"
        castbar.bar.name:SetText(previewName)
        castbar.bar.name:SetHidden(not state)
    end
    if ActionBar.SV.CastBarTimer then
        castbar.bar.timer:SetText(string_format("1.0"))
        castbar.bar.timer:SetHidden(not state)
    end
    castbar.bar.bar:SetValue(1)

    uiTlw.castBar.preview:SetHidden(not state)
    uiTlw.castBar:SetHidden(not state)
    castbar:SetHidden(not state)
end

--[[
function ActionBar.ClientInteractResult(eventCode, result, interactTargetName)

    local function DisplayInteractCast(icon, name, duration)
        local currentTimeMS = GetGameTimeMilliseconds()
        local endTime = currentTimeMS + duration
        local remain = endTime - currentTimeMS

        castbar.remain = endTime
        castbar.starts = currentTimeMS
        castbar.ends = endTime
        castbar.icon:SetTexture(icon)
        castbar.type = 1 -- CAST
        castbar.bar.bar:SetValue(0)
        castbar.id = 999999

        if ActionBar.SV.CastBarLabel then
            castbar.bar.name:SetText(name)
            castbar.bar.name:SetHidden(false)
        end
        if ActionBar.SV.CastBarTimer then
            castbar.bar.timer:SetText(string_format("%.1f", remain/1000))
            castbar.bar.timer:SetHidden(false)
        end

        castbar:SetHidden(false)
        g_casting = true
        eventManager:RegisterForUpdate(moduleName .. "CastBar", 20, ActionBar.OnUpdateCastbar)
    end

    -- If we succesfully interact then...
    if result == CLIENT_INTERACT_RESULT_SUCCESS then
        -- Check if the interact object name is in our table
        if Castbar.InteractCast[interactTargetName] then
            -- Get the map id and check if there is an entry for this id
            index = GetZoneId(GetCurrentMapZoneIndex())
            if Castbar.InteractCast[interactTargetName][index] then
                local data = Castbar.InteractCast[interactTargetName][index]
                local icon = data.icon
                local name = data.name
                local duration = data.duration
                local delay = data.delay
                zo_callLater(function() DisplayInteractCast(icon, name, duration) end, delay)
            end
        end
    end

end
]]
--

-- -----------------------------------------------------------------------------
---
--- @param durationMs integer
function ActionBar.SoulGemResurrectionStart(durationMs)
    -- Just in case any other casts are present - stop them first
    ActionBar.StopCastBar()

    -- Set all parameters and start cast bar
    local icon = "esoui/art/icons/achievement_frostvault_death_challenge.dds"
    local name = Abilities.Innate_Soul_Gem_Resurrection
    local duration = durationMs

    local currentTimeMS = GetFrameTimeMilliseconds()
    local endTime = currentTimeMS + duration
    local remain = endTime - currentTimeMS

    castbar.remain = endTime
    castbar.starts = currentTimeMS
    castbar.ends = endTime
    castbar.icon:SetTexture(icon)
    castbar.type = 1 -- CAST
    castbar.bar.bar:SetValue(0)

    if ActionBar.SV.CastBarLabel then
        castbar.bar.name:SetText(name)
        castbar.bar.name:SetHidden(false)
    end
    if ActionBar.SV.CastBarTimer then
        castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
        castbar.bar.timer:SetHidden(false)
    end

    castbar:SetHidden(false)
    g_casting = true
    eventManager:RegisterForUpdate(moduleName .. "CastBar", 20, ActionBar.OnUpdateCastbar)
end

-- -----------------------------------------------------------------------------
--- Stops cast bar and clears resurrection state.
function ActionBar.SoulGemResurrectionEnd()
    ActionBar.StopCastBar()
end

-- Very basic handler registered to only read CC events on the player
--- - **EVENT_COMBAT_EVENT **
---
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function ActionBar.OnCombatEventBreakCast(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Some cast/channel abilities (or effects we use to simulate this) stun the player - ignore the effects of these ids when this happens.
    if Castbar.IgnoreCastBarStun[abilityId] or Castbar.IgnoreCastBreakingActions[castbar.id] then
        return
    end

    if not Castbar.IsCast[abilityId] then
        ActionBar.StopCastBar()
    end
end

local function isValidDamageResult(result)
    if result == ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DAMAGE_SHIELDED or result == ACTION_RESULT_IMMUNE or result == ACTION_RESULT_MISS or result == ACTION_RESULT_PARTIAL_RESIST or result == ACTION_RESULT_REFLECTED or result == ACTION_RESULT_RESIST or result == ACTION_RESULT_WRECKING_DAMAGE or result == ACTION_RESULT_DODGED then
        return true
    end
end

--- - **EVENT_COMBAT_EVENT **
---
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function ActionBar.OnCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Track ultimate generation when we block an attack or hit a target with a light/medium/heavy attack.
    if ActionBar.SV.UltimateGeneration and uiUltimate.NotFull and ((result == ACTION_RESULT_BLOCKED_DAMAGE and targetType == COMBAT_UNIT_TYPE_PLAYER) or (Effects.IsWeaponAttack[abilityName] and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetName ~= "")) then
        uiUltimate.Texture:SetHidden(false)
        uiUltimate.FadeTime = GetGameTimeMilliseconds() + 8000
    end

    -- Trap Beast aura removal helper function since there is no aura for it
    if Effects.IsGroundMineDamage[abilityId] then
        if isValidDamageResult(result) then
            local compareId
            if abilityId == 35754 then
                compareId = 35750
            elseif abilityId == 40389 then
                compareId = 40382
            elseif abilityId == 40376 then
                compareId = 40372
            end
            if compareId then
                if g_barNoRemove[compareId] then
                    if Effects.BarHighlightCheckOnFade[compareId] then
                        ActionBar.BarHighlightSwap(compareId)
                    end
                    return
                end
            end
        end
    end

    -- Bail out past here if the cast bar is disabled or
    if
    not ActionBar.SV.CastBarEnable or (
        (sourceType ~= COMBAT_UNIT_TYPE_PLAYER and not Castbar.CastOverride[abilityId]) -- source isn't the player and the ability is not on the list of abilities to show the cast bar for
        and (targetType ~= COMBAT_UNIT_TYPE_PLAYER or result ~= ACTION_RESULT_EFFECT_FADED)
    )                                                                                   -- target isn't the player with effect faded
    then
        return
    end

    -- Stop when a cast breaking action is detected
    if Castbar.CastBreakingActions[abilityId] then
        if not Castbar.IgnoreCastBreakingActions[castbar.id] then
            ActionBar.StopCastBar()
        end
    end

    local icon = GetAbilityIcon(abilityId)
    local name = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    -- Return if ability not marked as cast or ability is blacklisted
    if not Castbar.IsCast[abilityId] or ActionBar.SV.blacklist[abilityId] or ActionBar.SV.blacklist[name] then
        return
    end

    -- Don't show heavy attacks if the option is disabled
    if Castbar.IsHeavy[abilityId] and not ActionBar.SV.CastBarHeavy then
        return
    end

    local duration
    local channeled, castTime = GetAbilityCastInfo(abilityId)
    local forceChanneled = false

    -- Override certain things to display as a channel rather than cast.
    -- Note only works for events where we override the duration.
    if Castbar.CastChannelOverride[abilityId] then
        channeled = true
    end

    if channeled then
        duration = Castbar.CastDurationFix[abilityId] or result == ACTION_RESULT_EFFECT_GAINED_DURATION and hitValue or 0
    else
        duration = Castbar.CastDurationFix[abilityId] or castTime
    end

    -- End the cast bar and restart if a new begin event is detected and the effect isn't a channel or fake cast
    if result == ACTION_RESULT_BEGIN and not channeled and not Castbar.CastDurationFix[abilityId] then
        ActionBar.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION and channeled then
        ActionBar.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_GAINED and channeled then
        ActionBar.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_FADED and channeled then
        ActionBar.StopCastBar()
    end

    if Castbar.CastChannelConvert[abilityId] then
        channeled = true
        forceChanneled = true
        duration = Castbar.CastDurationFix[abilityId] or castTime
    end

    -- Some abilities cast into a channeled stun effect - we want these abilities to display the cast and channel if flagged.
    -- Only flags on ACTION_RESULT_BEGIN so this won't interfere with the stun result that is converted to dissplay a channeled cast.
    if Castbar.MultiCast[abilityId] then
        if result == 2200 then
            channeled = false
            duration = castTime or 0
        elseif result == 2240 then
            ActionBar.StopCastBar() -- Stop the cast bar when the GAINED event happens so that we can display the channel when the cast ends
        end
    end

    -- Special handling for werewolf transform and transform back
    if abilityId == 39033 or abilityId == 39477 then
        local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(32455)
        name, icon = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
        if abilityId == 39477 then
            name = zo_strformat("<<1>> <<2>>", Abilities.Skill_Remove, name)
        end
    end

    if duration > 0 and not g_casting then
        -- If action result is BEGIN and not channeled then start, otherwise only use GAINED
        if (not forceChanneled and (((result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL) and not channeled) or (result == ACTION_RESULT_EFFECT_GAINED and (Castbar.CastDurationFix[abilityId] or channeled)) or (result == ACTION_RESULT_EFFECT_GAINED_DURATION and (Castbar.CastDurationFix[abilityId] or channeled)))) or (forceChanneled and result == ACTION_RESULT_BEGIN) then
            local currentTimeMS = GetFrameTimeMilliseconds()
            local endTime = currentTimeMS + duration
            local remain = endTime - currentTimeMS

            castbar.remain = endTime
            castbar.starts = currentTimeMS
            castbar.ends = endTime
            castbar.icon:SetTexture(icon)
            castbar.id = abilityId

            if channeled then
                castbar.type = 2 -- CHANNEL
                castbar.bar.bar:SetValue(1)
            else
                castbar.type = 1 -- CAST
                castbar.bar.bar:SetValue(0)
            end
            if ActionBar.SV.CastBarLabel then
                castbar.bar.name:SetText(name)
                castbar.bar.name:SetHidden(false)
            end
            if ActionBar.SV.CastBarTimer then
                castbar.bar.timer:SetText(string_format("%.1f", remain / 1000))
                castbar.bar.timer:SetHidden(false)
            end

            castbar:SetHidden(false)
            g_casting = true
            eventManager:RegisterForUpdate(moduleName .. "CastBar", 20, ActionBar.OnUpdateCastbar)
        end
    end

    -- Fix to lower the duration of the next cast of Profane Symbol quest ability for Scion of the Blood Matron (Vampire)
    if abilityId == 39507 then
        zo_callLater(function ()
                           Castbar.CastDurationFix[39507] = 19500
                       end, 5000)
    end
end

--[[
function ActionBar.OnCombatEventSpecialFilters(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId)
    ActionBar.StopCastBar()
end
]]
--

--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function ActionBar.OnCombatEventBar(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- If the source/target isn't the player then bail out now.
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and targetType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_PLAYER then
        g_toggledSlotsPlayer[abilityId] = true
    end

    -- Special handling for Crystallized Shield + Morphs
    if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
        -- Make sure this event occured on the player only. If we hit another Warden's shield we don't want to change stack count.
        if result == ACTION_RESULT_DAMAGE_SHIELDED and targetType == COMBAT_UNIT_TYPE_PLAYER then
            if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
                -- Reduce stack by one
                if g_toggledSlotsStack[abilityId] then
                    g_toggledSlotsStack[abilityId] = g_toggledSlotsStack[abilityId] - 1
                end
                if g_toggledSlotsFront[abilityId] then
                    local slotNum = g_toggledSlotsFront[abilityId]
                    local c = GetCustomToggleControl(slotNum)
                    if c then
                        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
                            c.stack:SetText(g_toggledSlotsStack[abilityId])
                        else
                            c.stack:SetText("")
                        end
                    end
                end
                if g_toggledSlotsBack[abilityId] then
                    local slotNum = g_toggledSlotsBack[abilityId]
                    local c = GetCustomToggleControl(slotNum)
                    if c then
                        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
                            c.stack:SetText(g_toggledSlotsStack[abilityId])
                        else
                            c.stack:SetText("")
                        end
                    end
                end
            end
        end
    end

    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        local currentTimeMS = GetFrameTimeMilliseconds()
        if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
            if ActionBar.SV.ShowToggled then
                local skipToggleShow = false
                -- Power Lash stacks (34117): combat hitValue = stack count (EFFECT_GAINED) or duration ms (EFFECT_GAINED_DURATION); see EVENT_COMBAT_EVENT logs.
                if abilityId == 34117 then
                    if result == ACTION_RESULT_EFFECT_GAINED and type(hitValue) == "number" and hitValue <= 0 then
                        g_toggledSlotsRemain[abilityId] = nil
                        g_toggledSlotsStack[abilityId] = nil
                        if g_toggledSlotsFront[abilityId] then
                            ActionBar.HideSlot(g_toggledSlotsFront[abilityId], abilityId)
                        end
                        if g_toggledSlotsBack[abilityId] then
                            ActionBar.HideSlot(g_toggledSlotsBack[abilityId], abilityId)
                        end
                        skipToggleShow = true
                    else
                        if result == ACTION_RESULT_EFFECT_GAINED_DURATION and type(hitValue) == "number" and hitValue >= 500 then
                            g_toggledSlotsRemain[abilityId] = currentTimeMS + hitValue
                        else
                            local duration = GetUpdatedAbilityDuration(abilityId)
                            g_toggledSlotsRemain[abilityId] = currentTimeMS + duration
                        end
                        if result == ACTION_RESULT_EFFECT_GAINED and type(hitValue) == "number" and hitValue > 0 and hitValue <= 20 then
                            g_toggledSlotsStack[abilityId] = hitValue
                            if ActionBar.SV.BarShowLabel then
                                SetToggledStackLabels(abilityId, hitValue)
                            end
                        end
                    end
                else
                    local duration = GetUpdatedAbilityDuration(abilityId)
                    local endTime = currentTimeMS + duration
                    g_toggledSlotsRemain[abilityId] = endTime
                end
                -- Handling for Crystallized Shield + Morphs
                if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
                    g_toggledSlotsStack[abilityId] = 3
                end
                -- Handling for Trap Beast
                if abilityId == 35750 or abilityId == 40382 or abilityId == 40372 then
                    g_toggledSlotsStack[abilityId] = 1
                end
                -- Toggle highlight on
                if not skipToggleShow then
                    if g_toggledSlotsFront[abilityId] then
                        local slotNum = g_toggledSlotsFront[abilityId]
                        ActionBar.ShowSlot(slotNum, abilityId, currentTimeMS, false)
                    end
                    if g_toggledSlotsBack[abilityId] then
                        local slotNum = g_toggledSlotsBack[abilityId]
                        ActionBar.ShowSlot(slotNum, abilityId, currentTimeMS, false)
                    end
                end
            end
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        -- Ignore fading event if override is true
        if g_barNoRemove[abilityId] then
            if Effects.BarHighlightCheckOnFade[abilityId] then
                ActionBar.BarHighlightSwap(abilityId)
            end
            return
        end

        if g_toggledSlotsRemain[abilityId] then
            if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                local slotNum = g_toggledSlotsFront[abilityId]
                ActionBar.HideSlot(slotNum, abilityId)
            end
            if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                local slotNum = g_toggledSlotsBack[abilityId]
                ActionBar.HideSlot(slotNum, abilityId)
            end
            g_toggledSlotsRemain[abilityId] = nil
            g_toggledSlotsStack[abilityId] = nil
        end
        if Effects.BarHighlightCheckOnFade[abilityId] and targetType == COMBAT_UNIT_TYPE_PLAYER then
            ActionBar.BarHighlightSwap(abilityId)
        end
    end
end

--- @param actionSlotIndex luaindex
function ActionBar.OnSlotUpdated(actionSlotIndex)
    -- Update ultimate label
    if actionSlotIndex == 8 then
        ActionBar.UpdateUltimateLabel()
    end
    -- Update the slot if the bound id has a proc
    if actionSlotIndex >= BAR_INDEX_START and actionSlotIndex <= BAR_INDEX_END then
        local abilityId = GetSlotTrueBoundId(actionSlotIndex, g_hotbarCategory)
        if Effects.IsAbilityProc[abilityId] or Effects.BaseForAbilityProc[abilityId] then
            ActionBar.BarSlotUpdate(actionSlotIndex, false, true)
        end
    end
end

-- Handle slot update for action bars
---
--- @param slotNum integer
--- @param wasfullUpdate boolean
--- @param onlyProc boolean
function ActionBar.BarSlotUpdate(slotNum, wasfullUpdate, onlyProc)
    -- Look only for action bar slots
    if slotNum < BACKBAR_INDEX_OFFSET then
        if ActionBar.SV.ShowToggledUltimate then
            if slotNum < BAR_INDEX_START or slotNum > BAR_INDEX_END then
                return
            end
        else
            if slotNum < BAR_INDEX_START or slotNum > (BAR_INDEX_END - 1) then
                return
            end
        end
    end

    -- Remove saved triggered proc information
    for abilityId, slot in pairs(g_triggeredSlotsFront) do
        if (slot == slotNum) then
            g_triggeredSlotsFront[abilityId] = nil
        end
    end
    for abilityId, slot in pairs(g_triggeredSlotsBack) do
        if (slot == slotNum) then
            g_triggeredSlotsBack[abilityId] = nil
        end
    end

    -- Stop possible proc animation
    if g_uiProcAnimation[slotNum] and g_uiProcAnimation[slotNum]:IsPlaying() then
        -- g_uiProcAnimation[slotNum].procLoopTexture.label:SetText("")
        g_uiProcAnimation[slotNum]:Stop()
    end

    if onlyProc == false then
        -- Remove custom toggle information and custom highlight
        for abilityId, slot in pairs(g_toggledSlotsFront) do
            if (slot == slotNum) then
                g_toggledSlotsFront[abilityId] = nil
            end
        end
        for abilityId, slot in pairs(g_toggledSlotsBack) do
            if (slot == slotNum) then
                g_toggledSlotsBack[abilityId] = nil
            end
        end

        local c = GetCustomToggleControl(slotNum)
        if c then
            c:SetHidden(true)
        end
    end

    -- Bail out if slot is not used and we're not referencing a fake backbar slot.
    if slotNum < BACKBAR_INDEX_OFFSET and not IsSlotUsed(slotNum, g_hotbarCategory) then
        return
    end

    local ability_id = GetSlotTrueBoundId(slotNum, g_hotbarCategory)
    if slotNum > BACKBAR_INDEX_OFFSET then
        local inactiveHotbarCategory = GetInactiveHotbarCategory(g_hotbarCategory)
        ability_id = GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, inactiveHotbarCategory)

        local weaponSlot = inactiveHotbarCategory == HOTBAR_CATEGORY_BACKUP and EQUIP_SLOT_BACKUP_MAIN or EQUIP_SLOT_MAIN_HAND
        local weaponType = GetItemWeaponType(BAG_WORN, weaponSlot)

        if weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF or weaponType == WEAPONTYPE_NONE then
            if Effects.BarHighlightDestroFix[ability_id] and Effects.BarHighlightDestroFix[ability_id][weaponType] then
                ability_id = Effects.BarHighlightDestroFix[ability_id][weaponType]
            end
        end
    end

    local showFakeAura = (Effects.BarHighlightOverride[ability_id] and Effects.BarHighlightOverride[ability_id].showFakeAura)

    if Effects.BarHighlightOverride[ability_id] then
        if Effects.BarHighlightOverride[ability_id].hide then
            return
        end
        if Effects.BarHighlightOverride[ability_id].newId then
            ability_id = Effects.BarHighlightOverride[ability_id].newId
        end
    end

    if showFakeAura and ability_id then
        if not g_barFakeAura[ability_id] then
            g_barFakeAura[ability_id] = true
            g_barOverrideCI[ability_id] = true

            local override = Effects.BarHighlightOverride[ability_id]
            if override and override.duration then
                g_barDurationOverride[ability_id] = override.duration
            end
        end
    end

    local abilityName = Effects.EffectOverride[ability_id] and Effects.EffectOverride[ability_id].name or GetAbilityName(ability_id, "player") -- GetSlotName(slotNum)
    -- local _, _, channel = GetAbilityCastInfo(ability_id)
    local duration = GetUpdatedAbilityDuration(ability_id)
    local currentTime = GetGameTimeMilliseconds()

    local triggeredSlots
    if slotNum > BACKBAR_INDEX_OFFSET then
        triggeredSlots = g_triggeredSlotsBack
    else
        triggeredSlots = g_triggeredSlotsFront
    end

    -- Check if currently this ability is in proc state
    local proc = Effects.HasAbilityProc[abilityName]
    if Effects.IsAbilityProc[GetSlotTrueBoundId(slotNum, g_hotbarCategory)] then
        if ActionBar.SV.ShowTriggered then
            ActionBar.PlayProcAnimations(slotNum)
            if ActionBar.SV.ProcEnableSound then
                if not wasfullUpdate and not g_disableProcSound[slotNum] then
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
                    -- Only play a proc sound every 3 seconds (matches Power Lash cd)
                    g_disableProcSound[slotNum] = true
                    zo_callLater(function ()
                                       g_disableProcSound[slotNum] = false
                                   end, 3000)
                end
            end
        end
    elseif proc then
        triggeredSlots[proc] = slotNum
        if g_triggeredSlotsRemain[proc] then
            if ActionBar.SV.ShowTriggered then
                ActionBar.PlayProcAnimations(slotNum)
                if ActionBar.SV.BarShowLabel then
                    if not g_uiProcAnimation[slotNum] then return end
                    local remain = g_triggeredSlotsRemain[proc] - currentTime
                    g_uiProcAnimation[slotNum].procLoopTexture.label:SetText(FormatDurationSeconds(remain))
                end
            end
        end
    end

    local toggledSlots
    if slotNum > BACKBAR_INDEX_OFFSET then
        toggledSlots = g_toggledSlotsBack
    else
        toggledSlots = g_toggledSlotsFront
    end

    -- Check for active duration to display highlight for abilities on bar swap
    if onlyProc == false and toggledSlots and ability_id then
        if duration > 0 or Effects.AddNoDurationBarHighlight[ability_id] or Effects.MajorMinor[ability_id] then
            toggledSlots[ability_id] = slotNum
            if g_toggledSlotsRemain[ability_id] then
                if ActionBar.SV.ShowToggled then
                    slotNum = toggledSlots[ability_id]
                    -- Check the other slot here to determine if we desaturate (in case effects are running in both slots)
                    local desaturate
                    local slotIndex = slotNum > BACKBAR_INDEX_OFFSET and slotNum - BACKBAR_INDEX_OFFSET or nil
                    if slotIndex then
                        local c = GetCustomToggleControl(slotIndex)
                        if c then
                            desaturate = false
                            if c:IsHidden() then
                                ActionBar.BackbarHideSlot(slotNum)
                                desaturate = true
                            end
                        end
                    end
                    ActionBar.ShowSlot(slotNum, ability_id, currentTime, desaturate)
                end
            end
        end
    end
end

--- -----------------------------------------------------------------------------
--- Refreshes ultimate slot label (cost, percentage) from current power and slot ability.
function ActionBar.UpdateUltimateLabel()
    -- Get the currently slotted ultimate cost
    local bar = g_hotbarCategory
    g_ultimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, bar) or 0

    -- Update ultimate label
    ActionBar.OnPowerUpdatePlayer("player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_ultimateCurrent, 0, 0)
end

--- -----------------------------------------------------------------------------
--- Called when an inventory item is used; refreshes ultimate label.
function ActionBar.InventoryItemUsed()
    g_potionUsed = true
    zo_callLater(function ()
                       g_potionUsed = false
                   end, 200)
end

--- - **EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED **
---
-- -----------------------------------------------------------------------------
--- Handles EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED: updates hotbar category, backbar icons, ultimate.
--- @param didActiveHotbarChange boolean
--- @param shouldUpdateAbilityAssignments boolean
--- @param activeHotbarCategory HotBarCategory
function ActionBar.OnActiveHotbarUpdate(didActiveHotbarChange, shouldUpdateAbilityAssignments, activeHotbarCategory)
    if didActiveHotbarChange == true or shouldUpdateAbilityAssignments == true then
        for _, physicalSlot in pairs(g_backbarButtons) do
            if physicalSlot.hotbarSwapAnimation then
                physicalSlot.noUpdates = true
                physicalSlot.hotbarSwapAnimation:PlayFromStart()
            end
        end
    else
        g_activeWeaponSwapInProgress = false
    end
end

--- - **EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED**
--- Full refresh of all bar slots (main + backbar), potion timer, and backbar visibility.
function ActionBar.OnSlotsFullUpdate()
    -- Don't update bars if this full update event was from using an inventory item
    if g_potionUsed == true then
        return
    end

    -- Handle ultimate label first
    ActionBar.UpdateUltimateLabel()

    -- Update action bar skills
    for i = BAR_INDEX_START, BAR_INDEX_END do
        ActionBar.BarSlotUpdate(i, true, false)
    end

    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        local button = g_backbarButtons[i]
        ActionBar.SetupBackBarIcons(button, nil)
        ActionBar.BarSlotUpdate(i, true, false)
    end
end

--- Play proc/ready animation for an action slot<br>
--- Creates animation controls on first call, then plays the timeline
--- @param slotNum integer The action slot index
function ActionBar.PlayProcAnimations(slotNum)
    -- Early return if animation exists and is playing
    local existingAnimation = g_uiProcAnimation[slotNum]
    if existingAnimation then
        if not existingAnimation:IsPlaying() then
            existingAnimation:PlayFromStart()
        end
        return
    end

    -- Don't create for backbar ultimate slot
    if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
        return
    end

    -- Set placeholder immediately to prevent race condition
    g_uiProcAnimation[slotNum] = true

    -- Get action button
    local actionButton = slotNum < BACKBAR_INDEX_OFFSET
        and ZO_ActionBar_GetButton(slotNum)
        or g_backbarButtons[slotNum]

    -- Create proc loop texture from virtual template
    local procLoopTexture = windowManager:CreateControlFromVirtual("$(parent)Loop_LUIE", actionButton.slot, "ZO_PendingLoop_Glow")
    procLoopTexture:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
    procLoopTexture:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
    procLoopTexture:SetDrawLayer(DL_TEXT)
    procLoopTexture:SetHidden(true)

    -- Create label control
    local label = windowManager:CreateControl("$(parent)Label", procLoopTexture, CT_LABEL)
    label:SetFont(g_barFont or "LUIE Default Font")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetAnchor(TOPLEFT, actionButton.slot)
    label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -ActionBar.SV.BarLabelPosition)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    label:SetColor(1, 1, 1, 1)
    label:SetHidden(false)
    procLoopTexture.label = label

    -- Create timeline animation
    local procLoopTimeline = animationManager:CreateTimelineFromVirtual("UltimateReadyLoop", procLoopTexture)
    procLoopTimeline.procLoopTexture = procLoopTexture
    procLoopTimeline:SetHandler("OnPlay", function ()
        procLoopTexture:SetHidden(false)
    end)
    procLoopTimeline:SetHandler("OnStop", function ()
        procLoopTexture:SetHidden(true)
    end)

    -- Replace placeholder with actual timeline and start playing
    g_uiProcAnimation[slotNum] = procLoopTimeline
    procLoopTimeline:PlayFromStart()
end

--- - **EVENT_UNIT_DEATH_STATE_CHANGED **
---
--- @param unitTag string
--- @param isDead boolean
function ActionBar.OnDeath(unitTag, isDead)
    -- And toggle buttons
    if unitTag == "player" then
        for slotNum = BAR_INDEX_START, BAR_INDEX_END do
            local c = GetCustomToggleControl(slotNum)
            if c then
                c:SetHidden(true)
                --[[if slotNum == 8 and ActionBar.SV.UltimatePctEnabled and IsSlotUsed(g_ultimateSlot) then
                    uiUltimate.LabelPct:SetHidden(false)
                end]]
                --
            end
        end
        for slotNum = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
            local c = GetCustomToggleControl(slotNum)
            if c then
                c:SetHidden(true)
            end
        end
    end
end

--- Display custom toggle texture for an action slot<br>
--- Creates toggle controls on first call, then shows the cached control<br>
--- Uses placeholder pattern to prevent race condition during control creation
--- @param slotNum integer The action slot index
function ActionBar.ShowCustomToggle(slotNum)
    if isFancyActionBarEnabled then
        return
    end

    -- Early return if already exists and is a control (not placeholder)
    local existingToggle = g_uiCustomToggle[slotNum]
    if existingToggle and existingToggle ~= true then
        existingToggle:SetHidden(false)
        return
    end

    -- Don't create for backbar ultimate slot
    if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
        return
    end

    -- If placeholder exists, skip (creation already in progress)
    if existingToggle == true then
        return
    end

    -- Set placeholder immediately to prevent race condition
    g_uiCustomToggle[slotNum] = true

    -- Get action button
    local actionButton = slotNum < BACKBAR_INDEX_OFFSET
        and ZO_ActionBar_GetButton(slotNum)
        or g_backbarButtons[slotNum]

    -- Create toggle frame
    local toggleFrame = windowManager:CreateControl("$(parent)Toggle_LUIE", actionButton.slot, CT_TEXTURE)
    toggleFrame:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
    toggleFrame:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
    toggleFrame:SetTexture("/esoui/art/actionbar/actionslot_toggledon.dds")
    toggleFrame:SetBlendMode(TEX_BLEND_MODE_ADD)
    toggleFrame:SetDrawLayer(DL_BACKGROUND)
    toggleFrame:SetDrawLevel(actionButton.slot:GetDrawLevel() + 1)
    toggleFrame:SetDrawTier(DT_HIGH)
    toggleFrame:SetColor(0.5, 1, 0.5, 1)

    -- Create label control
    local label = windowManager:CreateControl("$(parent)Label", toggleFrame, CT_LABEL)
    label:SetFont(g_barFont or "LUIE Default Font")
    label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetAnchor(TOPLEFT, actionButton.slot)
    label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -ActionBar.SV.BarLabelPosition)
    label:SetDrawLayer(DL_CONTROLS)
    label:SetDrawLevel(toggleFrame:GetDrawLevel() + 1)
    label:SetDrawTier(DT_HIGH)
    label:SetColor(1, 1, 1, 1)
    label:SetHidden(false)
    toggleFrame.label = label

    -- Create stack label control
    local stack = windowManager:CreateControl("$(parent)Stack", toggleFrame, CT_LABEL)
    stack:SetFont(g_barFont or "LUIE Default Font")
    stack:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    stack:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    stack:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    stack:SetAnchor(CENTER, actionButton.slot, BOTTOMLEFT)
    stack:SetAnchor(CENTER, actionButton.slot, TOPRIGHT, -12, 14)
    stack:SetDrawLayer(DL_CONTROLS)
    stack:SetDrawLevel(toggleFrame:GetDrawLevel() + 1)
    stack:SetDrawTier(DT_HIGH)
    stack:SetColor(1, 1, 1, 1)
    stack:SetHidden(false)
    toggleFrame.stack = stack

    -- Replace placeholder with actual frame and show it
    g_uiCustomToggle[slotNum] = toggleFrame
    toggleFrame:SetHidden(false)
end

--- - **EVENT_POWER_UPDATE **
---
--- @param unitTag string
--- @param powerIndex luaindex
--- @param powerType CombatMechanicFlags
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
function ActionBar.OnPowerUpdatePlayer(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if unitTag ~= "player" then
        return
    end
    if powerType ~= COMBAT_MECHANIC_FLAGS_ULTIMATE then
        return
    end

    -- flag if ultimate is full - we"ll need it for ultimate generation texture
    uiUltimate.NotFull = (powerValue < powerMax)
    -- Calculate the percentage to activation old one and current
    local pct = (g_ultimateCost > 0) and zo_floor((powerValue / g_ultimateCost) * 100) or 0
    -- Set max percentage label to 100%.
    if pct > 100 then
        pct = 100
    end
    -- Update the tooltip only when the slot is used and percentage is enabled
    if IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
            -- Set % value
            if ActionBar.SV.UltimatePctEnabled then
                uiUltimate.LabelPct:SetText(pct .. "%")
            end
            -- Set label value
            if ActionBar.SV.UltimateLabelEnabled then
                uiUltimate.LabelVal:SetText(powerValue .. "/" .. g_ultimateCost)
            end
            -- Pct label: show always when less then 100% and possibly if UltimateHideFull is false
            if pct < 100 then
                -- Check Ultimate Percent Setting & if slot is used then check if the slot is currently showing a toggle
                local setHiddenPct = not ActionBar.SV.UltimatePctEnabled
                local c8 = GetCustomToggleControl(8)
                if ActionBar.SV.ShowToggledUltimate and c8 and not c8:IsHidden() then
                    setHiddenPct = true
                end
                uiUltimate.LabelPct:SetHidden(setHiddenPct)
                -- Update Label Color
                if ActionBar.SV.UltimateLabelEnabled then
                    for i = #uiUltimate.pctColours, 1, -1 do
                        if pct < uiUltimate.pctColours[i].pct then
                            local color = uiUltimate.pctColours[i].colour
                            local r, g, b, a = color[1], color[2], color[3], color[4]
                            uiUltimate.LabelVal:SetColor(r, g, b, a)
                            break
                        end
                    end
                end
            else
                -- Check Ultimate Percent Setting & if slot is used then check if the slot is currently showing a toggle
                local setHiddenPct = not ActionBar.SV.UltimatePctEnabled
                local c8 = GetCustomToggleControl(8)
                if (ActionBar.SV.ShowToggledUltimate and c8 and not c8:IsHidden()) or ActionBar.SV.UltimateHideFull then
                    setHiddenPct = true
                end
                uiUltimate.LabelPct:SetHidden(setHiddenPct)
                -- Update Label Color
                if ActionBar.SV.UltimateLabelEnabled then
                    local color = uiUltimate.colour
                    local r, g, b, a = color[1], color[2], color[3], color[4]
                    uiUltimate.LabelVal:SetColor(r, g, b, a)
                end
            end
            -- Set label hidden or showing
            local setHiddenLabel = not ActionBar.SV.UltimateLabelEnabled
            uiUltimate.LabelVal:SetHidden(setHiddenLabel)
        end
    else
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
    end
    -- Update stored value
    g_ultimateCurrent = powerValue
end

-- -----------------------------------------------------------------------------
--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function ActionBar.OnInventorySlotUpdate(bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    if stackCountChange >= 0 then
        ActionBar.UpdateUltimateLabel()
    end
end
