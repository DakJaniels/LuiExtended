-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local UI = LUIE.UI
local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Effects_AddNoDurationBarHighlight = Effects.AddNoDurationBarHighlight
local Effects_BarHighlightCheckOnFade = Effects.BarHighlightCheckOnFade
local Effects_BarHighlightCruxMap = Effects.BarHighlightCruxMap
local Effects_BarHighlightDestroFix = Effects.BarHighlightDestroFix
local Effects_BarHighlightExtraId = Effects.BarHighlightExtraId
local Effects_BarHighlightOverride = Effects.BarHighlightOverride
local Effects_BarHighlightStack = Effects.BarHighlightStack
local Effects_EffectGroundDisplay = Effects.EffectGroundDisplay
local Effects_EffectOverride = Effects.EffectOverride
local Effects_HasAbilityProc = Effects.HasAbilityProc
local Effects_HideGroundMineStacks = Effects.HideGroundMineStacks
local Effects_IsBloodFrenzy = Effects.IsBloodFrenzy
local Effects_IsBoundArmaments = Effects.IsBoundArmaments
local Effects_IsGrimFocus = Effects.IsGrimFocus
local Effects_IsGroundMineAura = Effects.IsGroundMineAura
local Effects_IsGroundMineDamage = Effects.IsGroundMineDamage
local Effects_IsGroundMineStack = Effects.IsGroundMineStack
local Effects_IsVamp = Effects.IsVamp
local Effects_IsWeaponAttack = Effects.IsWeaponAttack
local Effects_LinkedGroundMine = Effects.LinkedGroundMine
local Effects_MajorMinor = Effects.MajorMinor
local Castbar = Data.CastBarTable
local OtherAddonCompatability = LUIE.OtherAddonCompatability

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

-- ============================================================================
-- LOCAL REFERENCES
-- ============================================================================

local pairs = pairs
local printToChat = LUIE.PrintToChat
local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local GetAbilityDuration = GetAbilityDuration
local timeMs = GetFrameTimeMilliseconds
local zo_strformat = zo_strformat
local string_format = string.format
local zo_floor = zo_floor
local eventManager = GetEventManager()
local animationManager = GetAnimationManager()
local GetActionSlotEffectDuration = GetActionSlotEffectDuration
local GetActionSlotEffectTimeRemaining = GetActionSlotEffectTimeRemaining

local moduleName = LUIE.name .. "ActionBar"

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local ACTION_BAR_META = ZO_ActionBar1
local ACTION_BAR = ACTION_BAR_META
local BAR_INDEX_START = 3
local BAR_INDEX_END = 8
local BACKBAR_INDEX_OFFSET = 50
local BACKBAR_INDEX_END = 7


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
    weaponSwapOffsetX = 59,
    weaponSwapOffsetY = -4,
}

--- @return LUIE_ACTIONBAR_GAMEPAD_CONSTANTS | LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
local function GetPlatformConstants()
    return IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
end

local PLAYER_HOTBAR_CATEGORIES =
{
    [HOTBAR_CATEGORY_PRIMARY] = true,
    [HOTBAR_CATEGORY_BACKUP] = true,
    [HOTBAR_CATEGORY_OVERLOAD] = true,
    [HOTBAR_CATEGORY_DAEDRIC_ARTIFACT] = true,
    [HOTBAR_CATEGORY_WEREWOLF] = true,
    [HOTBAR_CATEGORY_TEMPORARY] = true,
}

local WEAPON_SWAP_HOTBAR_CATEGORIES =
{
    [HOTBAR_CATEGORY_PRIMARY] = true,
    [HOTBAR_CATEGORY_BACKUP] = true,
}

local UNIQUE_OVERRIDE_HOTBAR_CATEGORIES =
{
    [HOTBAR_CATEGORY_OVERLOAD] = true,
    [HOTBAR_CATEGORY_DAEDRIC_ARTIFACT] = true,
    [HOTBAR_CATEGORY_WEREWOLF] = true,
    [HOTBAR_CATEGORY_TEMPORARY] = true,
}

function ActionBar.IsPlayerHotbarCategory(hotbarCategory)
    return hotbarCategory ~= nil and PLAYER_HOTBAR_CATEGORIES[hotbarCategory] == true
end

local function IsWeaponSwapHotbarCategory(hotbarCategory)
    return WEAPON_SWAP_HOTBAR_CATEGORIES[hotbarCategory] == true
end

function ActionBar.IsUniqueOverrideHotbarCategory(hotbarCategory)
    return UNIQUE_OVERRIDE_HOTBAR_CATEGORIES[hotbarCategory] == true
end

-- Cooldown Animation Types for GCD Tracking
local CooldownMethod =
{
    [1] = CD_TYPE_RADIAL,
    [2] = CD_TYPE_VERTICAL_REVEAL,
}

-- Quickslot anchor constant
local IS_QUICKSLOT_ANCHORED_LEFT = true

-- ============================================================================
-- MODULE-LOCAL STATE
-- ============================================================================

-- Compatibility check (checked once at load, never changes)
local isFancyActionBarEnabled = OtherAddonCompatability.isFancyActionBarPlusEnabled or LUIE.IsItEnabled("FancyActionBar\43") or LUIE.IsItEnabled("FancyActionBar")

-- Core state variables
local g_cruxAbilityLookup = nil
local g_ultimateCost = 0
local g_ultimateCurrent = 0
local g_ultimateSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local g_companionUltimateCost = 0
local g_companionUltimateCurrent = 0
local g_hotbarCategory = GetActiveHotbarCategory()
local g_actionBarActiveWeaponPair = GetHeldWeaponPair()
local g_activeWeaponSwapInProgress = false
local g_potionUsed = false
local g_backbarUniqueHidden = false
local g_platformStyle

-- Table state
local g_uiProcAnimation = {}
local g_uiCustomToggle = {}
local g_triggeredSlotsFront = {}
local g_triggeredSlotsBack = {}
local g_triggeredSlotsRemain = {}
local g_toggledSlotsBack = {}
local g_toggledSlotsFront = {}
local g_toggledSlotsRemain = {}
local g_toggledSlotsStack = {}
local g_toggledSlotsPlayer = {}
local g_barOverrideCI = {}
local g_barFakeAura = {}
local g_barDurationOverride = {}
local g_barNoRemove = {}
local g_protectAbilityRemoval = {}
local g_mineStacks = {}
local g_mineNoTurnOff = {}
local g_boundArmamentsPlayed = {}
local g_disableProcSound = {}

-- Font and sound variables
local g_barFont
local g_potionFont
local g_ultimateFont
local g_ProcSound

-- UI references
--- @type {[integer]:ActionButton}
local g_backbarButtons = {}
local g_companionUltimateButton = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
local g_quickslotButton = ZO_ActionBar_GetButton(QuickslotActionButton:GetSlot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
local g_keybindBG = ACTION_BAR:GetNamedChild("KeybindBG")

-- Validation references
local abilityDropValidators = ZO_ABILITY_DROP_CALLOUT_VALIDITY_FUNCTION_BY_ACTION_TYPE
local MOUSE_CONTENT_ACTION = MOUSE_CONTENT_ACTION

-- QuickSlot UI configuration
local uiQuickSlot =
{
    color = { 0.941, 0.565, 0.251, 1 },
    timeColors =
    {
        [1] = { remain = 15000, color = { 0.878, 0.941, 0.251, 1 } },
        [2] = { remain = 5000, color = { 0.251, 0.941, 0.125, 1 } },
    },
}

-- Ultimate slot UI configuration
local uiUltimate =
{
    color = { 0.941, 0.973, 0.957, 1 },
    pctColors =
    {
        [1] = { pct = 100, color = { 0.878, 0.941, 0.251, 1 } },
        [2] = { pct = 80, color = { 0.941, 0.565, 0.251, 1 } },
        [3] = { pct = 50, color = { 0.941, 0.251, 0.125, 1 } },
    },
    FadeTime = 0,
    NotFull = false,
}

-- Companion Ultimate slot UI configuration
local uiCompanionUltimate =
{
    color = { 0.941, 0.973, 0.957, 1 },
    pctColors =
    {
        [1] = { pct = 100, color = { 0.878, 0.941, 0.251, 1 } },
        [2] = { pct = 80, color = { 0.941, 0.565, 0.251, 1 } },
        [3] = { pct = 50, color = { 0.941, 0.251, 0.125, 1 } },
    },
    FadeTime = 0,
    NotFull = false,
}

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Helper to setup fonts (used by both ApplyFont and Initialize)
local function setupFont(fontNameKey, fontStyleKey, fontSizeKey, defaultFontStyle, defaultFontSize)
    local fontName = LUIE.Fonts[ActionBar.SV[fontNameKey]]
    if not fontName or fontName == "" then
        LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        fontName = "LUIE Default Font"
    end
    local fontStyle = ActionBar.SV[fontStyleKey] or defaultFontStyle
    local fontSize = (ActionBar.SV[fontSizeKey] and ActionBar.SV[fontSizeKey] > 0) and ActionBar.SV[fontSizeKey] or defaultFontSize
    return ZO_CreateFontString(fontName, fontSize, fontStyle)
end

-- Helper to get override ability duration
local function GetUpdatedAbilityDuration(abilityId, overrideRank, casterUnitTag)
    local duration = g_barDurationOverride[abilityId] or GetAbilityDuration(abilityId, overrideRank, casterUnitTag) or 0
    return duration
end

--- Formats duration in seconds for display
--- @param remain number Remaining time in milliseconds
--- @return string Formatted duration
local function FormatDurationSeconds(remain)
    return string_format((ActionBar.SV.BarMillis and ((remain < ActionBar.SV.BarMillisThreshold * 1000) or ActionBar.SV.BarMillisAboveTen)) and "%.1f" or "%.1d", remain / 1000)
end

--- Gets gradient color for ActionBar labels based on remaining time percentage
--- @param remain number Remaining time in milliseconds
--- @param duration number Total duration in milliseconds
--- @return table Color table {r, g, b, a}
local function GetActionBarGradientColor(remain, duration)
    if not ActionBar.SV.RemainingTextColoured or duration <= 0 then
        return { 1, 1, 1, 1 }
    end

    local pct = remain / duration
    if pct <= ActionBar.SV.RemainingTextColorThresholdLow then
        return ActionBar.SV.RemainingTextColorLow
    elseif pct <= ActionBar.SV.RemainingTextColorThresholdMid then
        return ActionBar.SV.RemainingTextColorMid
    else
        return ActionBar.SV.RemainingTextColorHigh
    end
end

--- Gets gradient color for quickslot timer based on remaining time
--- @param remain number Remaining time in milliseconds
--- @return table Color table {r, g, b, a}
local function GetQuickslotGradientColor(remain)
    if not ActionBar.SV.PotionTimerColor then
        return { 1, 1, 1, 1 }
    end

    -- Check thresholds from low to high (most restrictive first)
    if remain <= ActionBar.SV.PotionTimerTextColorThresholdLow then
        return ActionBar.SV.PotionTimerTextColorLow
    elseif remain <= ActionBar.SV.PotionTimerTextColorThresholdMid then
        return ActionBar.SV.PotionTimerTextColorMid
    else
        return ActionBar.SV.PotionTimerTextColorHigh
    end
end

--- Sets bar remain label based on ability type
--- @param remain number Remaining time in milliseconds
--- @param abilityId number Ability ID
--- @return string Formatted label text
local function SetBarRemainLabel(remain, abilityId)
    if Effects_IsGrimFocus[abilityId] or Effects_IsBloodFrenzy[abilityId] then
        return ""
    end

    -- Check if this ability should show Crux stacks (hide timer, show only stack count)
    if not g_cruxAbilityLookup then
        g_cruxAbilityLookup = {}
        if Effects_BarHighlightCruxMap then
            for cruxEffectId, cruxAbilities in pairs(Effects_BarHighlightCruxMap) do
                for _, cruxAbilityId in ipairs(cruxAbilities) do
                    g_cruxAbilityLookup[cruxAbilityId] = true
                end
            end
        end
    end

    if g_cruxAbilityLookup[abilityId] then
        return ""
    end

    return FormatDurationSeconds(remain)
end

--- Gets corrected ability ID based on weapon type and special cases
--- @param abilityId integer Original ability ID
--- @param hotbarCategory number Hotbar category
--- @return integer Corrected ability ID
local function GetCorrectedAbilityId(abilityId, hotbarCategory)
    local correctedAbilityId = abilityId
    local BarHighlightDestroFix = Effects_BarHighlightDestroFix

    if not BarHighlightDestroFix[abilityId] then
        return abilityId
    end

    local weaponSlot = (hotbarCategory == HOTBAR_CATEGORY_PRIMARY) and EQUIP_SLOT_MAIN_HAND or EQUIP_SLOT_BACKUP_MAIN
    local weaponType = GetItemWeaponType(BAG_WORN, weaponSlot)

    if weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF or weaponType == WEAPONTYPE_NONE then
        if BarHighlightDestroFix[abilityId] and BarHighlightDestroFix[abilityId][weaponType] then
            correctedAbilityId = BarHighlightDestroFix[abilityId][weaponType]
        end
    end

    return correctedAbilityId
end

-- Helper to clear a table while maintaining the reference
local function ClearTable(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

-- Helper to clear multiple tables at once
local function ClearTables(tables)
    for _, tbl in ipairs(tables) do
        ClearTable(tbl)
    end
end

local function ShouldAnimateWeaponSwap(previousCategory, newCategory)
    return previousCategory ~= newCategory
        and IsWeaponSwapHotbarCategory(previousCategory)
        and IsWeaponSwapHotbarCategory(newCategory)
end

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

-- Helper to hide slots for both front and back positions
local function HideSlotsForAbility(abilityId)
    if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
        local slotNum = g_toggledSlotsFront[abilityId]
        ActionBar.HideSlot(slotNum, abilityId)
    end
    if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
        local slotNum = g_toggledSlotsBack[abilityId]
        ActionBar.HideSlot(slotNum, abilityId)
    end
end

-- Helper to show slots for both front and back positions
local function ShowSlotsForAbility(abilityId, currentTimeMs, isBackBar)
    if g_toggledSlotsFront[abilityId] then
        local slotNum = g_toggledSlotsFront[abilityId]
        ActionBar.ShowSlot(slotNum, abilityId, currentTimeMs, isBackBar)
    end
    if g_toggledSlotsBack[abilityId] then
        local slotNum = g_toggledSlotsBack[abilityId]
        ActionBar.ShowSlot(slotNum, abilityId, currentTimeMs, isBackBar)
    end
end

-- Helper to update stack count display on UI elements
local function UpdateStackDisplay(abilityId, stackCount)
    if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
        local slotNum = g_toggledSlotsFront[abilityId]
        if g_uiCustomToggle[slotNum] then
            g_uiCustomToggle[slotNum].stack:SetText(stackCount > 0 and stackCount or "")
        end
    end
    if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
        local slotNum = g_toggledSlotsBack[abilityId]
        if g_uiCustomToggle[slotNum] then
            g_uiCustomToggle[slotNum].stack:SetText(stackCount > 0 and stackCount or "")
        end
    end
end

-- Helper to clear toggled slots data
local function ClearToggledSlotsData(abilityId)
    g_toggledSlotsRemain[abilityId] = nil
    g_toggledSlotsStack[abilityId] = nil
end

-- Helper to handle ground mine stack changes and slot management
local function HandleGroundMineStackChange(abilityId, stackChange)
    if not g_mineStacks[abilityId] then
        g_mineStacks[abilityId] = 0
    end

    g_mineStacks[abilityId] = g_mineStacks[abilityId] + stackChange

    -- Clamp stack count to valid range
    if Effects_EffectGroundDisplay[abilityId] and Effects_EffectGroundDisplay[abilityId].stackReset then
        local maxStacks = Effects_EffectGroundDisplay[abilityId].stackReset
        if g_mineStacks[abilityId] > maxStacks then
            g_mineStacks[abilityId] = maxStacks
        elseif g_mineStacks[abilityId] < 0 then
            g_mineStacks[abilityId] = 0
        end
    end

    -- Update UI if showing labels
    if ActionBar.SV.BarShowLabel then
        UpdateStackDisplay(abilityId, g_mineStacks[abilityId])
    end

    -- Hide slots if stack reaches 0 and not prevented from turning off
    if g_mineStacks[abilityId] == 0 and not g_mineNoTurnOff[abilityId] then
        if g_toggledSlotsRemain[abilityId] then
            HideSlotsForAbility(abilityId)
            ClearToggledSlotsData(abilityId)
        end
    end
end

-- Generic helper to reset label anchors
local function ResetLabelAnchors(label, parent, positionOffset)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, parent)
    label:SetAnchor(BOTTOMRIGHT, parent, nil, 0, -positionOffset)
end

-- Helper to setup label anchors for a button
local function SetupLabelAnchors(label, buttonSlot)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, buttonSlot)
    label:SetAnchor(BOTTOMRIGHT, buttonSlot, nil, 0, -ActionBar.SV.BarLabelPosition)
end

-- ============================================================================
-- CORE PUBLIC FUNCTIONS
-- ============================================================================

function ActionBar.ShouldShowCompanionUltimateButton()
    return DoesUnitExist("companion") and HasActiveCompanion()
end

-- Sets companion ultimate button and quickslot positioning based on companion state
function ActionBar.SetCompanionAnchors()
    local constants = GetPlatformConstants()

    if ActionBar.ShouldShowCompanionUltimateButton() then
        g_companionUltimateButton:SetEnabled(true)
        g_keybindBG:SetDimensions(constants.keybindBGWidth, constants.keybindBGHeight)
        g_keybindBG:SetAnchor(BOTTOM, nil, nil, constants.keybindBGAnchorOffsetX, 0, ANCHOR_CONSTRAINS_XY)
        local xOffset = constants.quickslotOffsetXFromCompanionUltimate
        g_quickslotButton:ApplyAnchor(ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION).slot, xOffset, IS_QUICKSLOT_ANCHORED_LEFT)
    else
        g_companionUltimateButton:SetEnabled(false)
        g_keybindBG:SetDimensions(constants.keybindBGWidthWithoutCompanion, constants.keybindBGHeight)
        g_keybindBG:SetAnchor(BOTTOM, nil, nil, constants.keybindBGAnchorOffsetXWithoutCompanion, 0, ANCHOR_CONSTRAINS_XY)
        local xOffset = constants.quickslotOffsetXFromFirstSlot
        g_quickslotButton:ApplyAnchor(ZO_ActionBar1WeaponSwap, xOffset, IS_QUICKSLOT_ANCHORED_LEFT)
    end
end

function ActionBar.ApplyBackbarUniqueHiddenState(hidden)
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")
    local needsUpdate = hidden ~= g_backbarUniqueHidden

    if weaponSwapControl and weaponSwapControl.permanentlyHidden ~= hidden then
        needsUpdate = true
        ZO_WeaponSwap_SetPermanentlyHidden(weaponSwapControl, hidden)
    end

    if not needsUpdate then
        return
    end

    g_backbarUniqueHidden = hidden

    if hidden then
        for slotNum = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
            local button = g_backbarButtons[slotNum]
            if button then
                button.slot:SetHidden(true)
            end
        end
        for slotNum, control in pairs(g_uiCustomToggle) do
            if slotNum > BACKBAR_INDEX_OFFSET then
                control:SetHidden(true)
            end
        end
    else
        ActionBar.BackbarToggleSettings()
    end
end

function ActionBar.UpdateBackbarUniqueState(activeHotbarCategory)
    ActionBar.ApplyBackbarUniqueHiddenState(ActionBar.IsUniqueOverrideHotbarCategory(activeHotbarCategory))
end

function ActionBar.HideAbilityDropCallouts()
    for slotNum = BAR_INDEX_START, BAR_INDEX_END do
        local actionButton = ZO_ActionBar_GetButton(slotNum)
        if actionButton and actionButton.slot then
            local callout = actionButton.slot:GetNamedChild("DropCallout")
            if callout then
                callout:SetHidden(true)
            end
        end
    end
end

function ActionBar.ShowAbilityDropCallouts(actionType, actionValue)
    if not abilityDropValidators then
        return
    end

    local validator = abilityDropValidators[actionType]
    if not validator then
        return
    end

    ActionBar.HideAbilityDropCallouts()

    for slotNum = BAR_INDEX_START, BAR_INDEX_END do
        local actionButton = ZO_ActionBar_GetButton(slotNum)
        if actionButton and actionButton.slot then
            local callout = actionButton.slot:GetNamedChild("DropCallout")
            if callout then
                if validator(actionValue, slotNum) then
                    callout:SetColor(1, 1, 1, 1)
                else
                    callout:SetColor(1, 0, 0, 1)
                end
                callout:SetHidden(false)
            end
        end
    end
end

function ActionBar.RefreshVisibleCooldowns()
    for slotNum = BAR_INDEX_START, BAR_INDEX_END do
        local button = ZO_ActionBar_GetButton(slotNum, g_hotbarCategory)
        if button and button.UpdateCooldown then
            button:UpdateCooldown()
        end
    end

    for slotNum = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = g_backbarButtons[slotNum]
        if button and button.UpdateCooldown then
            button:UpdateCooldown()
        end
    end

    g_quickslotButton = ZO_ActionBar_GetButton(QuickslotActionButton:GetSlot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    if g_quickslotButton and g_quickslotButton.UpdateCooldown then
        g_quickslotButton:UpdateCooldown()
    end

    g_companionUltimateButton = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
    if g_companionUltimateButton and g_companionUltimateButton.UpdateCooldown then
        g_companionUltimateButton:UpdateCooldown()
    end
end

-- Force enable default action bar timers to get EVENT_ACTION_SLOT_EFFECT_UPDATE data
function ActionBar.SetActionBarTimersEnabled()
    if tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS)) == 0 then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS, "true", SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA)
    end
end

-- Disable default timer display on all action buttons to prevent double timers
function ActionBar.DisableZOSTimerDisplay()
    for slotNum = BAR_INDEX_START, BAR_INDEX_END do
        local actionButton = ZO_ActionBar_GetButton(slotNum)
        if actionButton then
            actionButton.showTimer = false
            actionButton.timerText:SetHidden(true)
            actionButton.timerOverlay:SetHidden(true)
        end
    end

    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = g_backbarButtons[i]
        if button then
            button.showTimer = false
            button.timerText:SetHidden(true)
            button.timerOverlay:SetHidden(true)
        end
    end
end

-- ============================================================================
-- DURATION OVERRIDE MANAGEMENT
-- ============================================================================

function ActionBar.GetTrackedAbilitiesForOverride()
    local abilities = {}
    local choices = {}
    local choicesValues = {}

    -- Add abilities that already have overrides
    for abilityId, duration in pairs(ActionBar.SV.durationOverrides) do
        if not abilities[abilityId] then
            abilities[abilityId] = true
        end
    end

    -- Add abilities from current action bar slots
    local hotbarCategory = GetActiveHotbarCategory()
    if ActionBar.IsPlayerHotbarCategory(hotbarCategory) then
        -- Front bar slots
        for slotNum = BAR_INDEX_START, BAR_INDEX_END do
            local abilityId = ActionBar.GetSlotAbilityId(slotNum, hotbarCategory)
            if abilityId and abilityId > 0 then
                if not abilities[abilityId] then
                    abilities[abilityId] = true
                end
            end
        end
        -- Back bar slots
        for slotNum = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
            local abilityId = ActionBar.GetSlotAbilityId(slotNum, HOTBAR_CATEGORY_BACKUP)
            if abilityId and abilityId > 0 then
                if not abilities[abilityId] then
                    abilities[abilityId] = true
                end
            end
        end
    end

    local counter = 0
    for abilityId, _ in pairs(abilities) do
        counter = counter + 1
        local abilityName = GetAbilityName(abilityId) or "Unknown Ability"
        local icon = GetAbilityIcon(abilityId)
        local currentDuration = ActionBar.SV.durationOverrides[abilityId] or GetAbilityDuration(abilityId) or 0

        choices[counter] = zo_iconTextFormat(icon, 16, 16, " [" .. abilityId .. "] " .. abilityName .. string_format(" (%d ms)", currentDuration), true, true)
        choicesValues[counter] = abilityId
    end

    return choices, choicesValues
end

function ActionBar.ClearDurationOverrides()
    for k, v in pairs(ActionBar.SV.durationOverrides) do
        ActionBar.SV.durationOverrides[k] = nil
    end
    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat("ActionBar: Cleared all custom duration overrides", true)
end

function ActionBar.AddDurationOverride(input)
    local parts = {}
    for part in string.gmatch(input, "%S+") do
        table.insert(parts, part)
    end

    if #parts ~= 2 then
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat("ActionBar: Invalid format. Use: <abilityId> <durationMs>", true)
        return
    end

    local abilityId = tonumber(parts[1])
    local duration = tonumber(parts[2])

    if not abilityId or not duration or abilityId <= 0 or duration <= 0 then
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat("ActionBar: Invalid ability ID or duration. Both must be positive numbers.", true)
        return
    end

    local abilityName = GetAbilityName(abilityId) or "Unknown Ability"
    ActionBar.SV.durationOverrides[abilityId] = duration

    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat(string_format("ActionBar: Added duration override for %s (%d): %d ms", abilityName, abilityId, duration), true)
end

function ActionBar.RemoveDurationOverride(input)
    local abilityId = tonumber(input)
    if not abilityId or abilityId <= 0 then
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat("ActionBar: Invalid ability ID. Must be a positive number.", true)
        return
    end

    if not ActionBar.SV.durationOverrides[abilityId] then
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat(string_format("ActionBar: No duration override found for ability ID %d", abilityId), true)
        return
    end

    local abilityName = GetAbilityName(abilityId) or "Unknown Ability"
    local duration = ActionBar.SV.durationOverrides[abilityId]
    ActionBar.SV.durationOverrides[abilityId] = nil

    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat(string_format("ActionBar: Removed duration override for %s (%d): %d ms", abilityName, abilityId, duration), true)
end

function ActionBar.ListDurationOverrides()
    local count = 0
    for abilityId, duration in pairs(ActionBar.SV.durationOverrides) do
        count = count + 1
        local abilityName = GetAbilityName(abilityId) or "Unknown Ability"
        printToChat(string_format("ActionBar: %s (%d): %d ms", abilityName, abilityId, duration), true)
    end

    if count == 0 then
        printToChat("ActionBar: No duration overrides configured", true)
    else
        printToChat(string_format("ActionBar: Total duration overrides: %d", count), true)
    end
end

-- ============================================================================
-- CUSTOM LIST MANAGEMENT (for CastBar blacklist)
-- ============================================================================

function ActionBar.ClearCustomList(list)
    local listRef = GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST)
    for k, v in pairs(list) do
        list[k] = nil
    end
    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    LUIE.PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
end

function ActionBar.AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef = GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST)
    if id and id > 0 then
        local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(id))
        local name = cachedName
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormatInheritColor(GetAbilityIcon(id), 16, 16)
            list[id] = true
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            LUIE.PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            LUIE.PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            LUIE.PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
end

function ActionBar.RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef = GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST)
    if id and id > 0 then
        local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(id))
        local name = cachedName
        local icon = zo_iconFormatInheritColor(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        LUIE.PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            LUIE.PrintToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
end

-- ============================================================================
-- BACKBAR ICON MANAGEMENT
-- ============================================================================

-- Called on initialization and on full update to swap icons on backbar
function ActionBar.SetupBackBarIcons(button, flip)
    local inactiveHotbarCategory = GetInactiveHotbarCategory(g_hotbarCategory)
    local slotNum = button.slot.slotNum

    local slotId = GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, inactiveHotbarCategory)
    slotId = GetCorrectedAbilityId(slotId, inactiveHotbarCategory)

    local specialCases =
    {
        [114716] = 46324,
        [20824] = 20816,
        [35445] = 35441,
        [126659] = 38910,
    }

    if specialCases[slotId] then
        slotId = specialCases[slotId]
    end

    if slotId > 0 then
        button.icon:SetTexture(GetAbilityIcon(slotId))
        button.icon:SetHidden(false)
    else
        button.icon:SetHidden(true)
    end

    if flip then
        ActionBar.handleFlip(slotNum)
    end
end

function ActionBar.handleFlip(slotNum)
    local desaturate = true

    if g_uiCustomToggle and g_uiCustomToggle[slotNum] then
        desaturate = false

        if g_uiCustomToggle[slotNum]:IsHidden() then
            ActionBar.BackbarHideSlot(slotNum)
            desaturate = true
        end
    end

    ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
end

-- Update actionId for backbar buttons
function ActionBar.UpdateBackbarButtonActionIds()
    local inactiveHotbarCategory = GetInactiveHotbarCategory(g_hotbarCategory)
    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = g_backbarButtons[i]
        if button and button.button then
            button.button.actionId = GetSlotTrueBoundId(i - BACKBAR_INDEX_OFFSET, inactiveHotbarCategory)
        end
    end
end

-- ============================================================================
-- BAR HIGHLIGHT TABLE MANAGEMENT
-- ============================================================================

-- Process a single bar highlight override entry
local function ProcessBarHighlightOverride(abilityId, value)
    local targetId = value.newId or abilityId

    if value.showFakeAura then
        g_barOverrideCI[targetId] = true
        if value.duration and not g_barDurationOverride[targetId] then
            g_barDurationOverride[targetId] = value.duration
        end
        if value.noRemove then
            g_barNoRemove[targetId] = true
        end
        g_barFakeAura[targetId] = true
    elseif value.noRemove then
        g_barNoRemove[targetId] = true
    end
end

-- Register combat events for bar override abilities
local function RegisterBarCombatEvents()
    local nextEventHandleNr = 0
    for abilityId, _ in pairs(g_barOverrideCI) do
        local eventName = moduleName .. "CombatEventBar" .. tostring(nextEventHandleNr)
        nextEventHandleNr = nextEventHandleNr + 1
        eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, ActionBar.OnCombatEventBar)
        eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_IS_ERROR, false)
    end
end

-- Called on initialization and menu changes
function ActionBar.UpdateBarHighlightTables()
    -- Clear all highlight tables
    ClearTables(
        {
            g_uiProcAnimation,
            g_uiCustomToggle,
            g_triggeredSlotsFront,
            g_triggeredSlotsBack,
            g_triggeredSlotsRemain,
            g_toggledSlotsFront,
            g_toggledSlotsBack,
            g_toggledSlotsRemain,
            g_toggledSlotsStack,
            g_toggledSlotsPlayer,
            g_barOverrideCI,
            g_barFakeAura,
            g_barNoRemove,
        })

    -- Setup duration overrides
    g_barDurationOverride = ActionBar.SV.durationOverrides or {}
    ActionBar.SV.durationOverrides = g_barDurationOverride

    -- Process bar highlight overrides if enabled
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        for abilityId, value in pairs(Effects_BarHighlightOverride) do
            ProcessBarHighlightOverride(abilityId, value)
        end
        RegisterBarCombatEvents()
    end
end

-- ============================================================================
-- LABEL MANAGEMENT
-- ============================================================================

-- Helper to reset labels for a button index and type
local function ResetButtonLabel(index, buttonSlot)
    if g_uiCustomToggle[index] then
        SetupLabelAnchors(g_uiCustomToggle[index].label, buttonSlot)
    elseif g_uiProcAnimation[index] then
        SetupLabelAnchors(g_uiProcAnimation[index].procLoopTexture.label, buttonSlot)
    end
end

-- Resets bar labels on menu option change
function ActionBar.ResetBarLabel()
    -- Clear all label text
    for _, entry in pairs(g_uiProcAnimation) do
        entry.procLoopTexture.label:SetText("")
    end
    for _, entry in pairs(g_uiCustomToggle) do
        entry.label:SetText("")
    end

    -- Setup anchors for front bar
    for i = BAR_INDEX_START, BAR_INDEX_END do
        local actionButton = ZO_ActionBar_GetButton(i)
        ResetButtonLabel(i, actionButton.slot)
    end

    -- Setup anchors for back bar
    for i = BAR_INDEX_START, BAR_INDEX_END do
        local backIndex = i + BACKBAR_INDEX_OFFSET
        local actionButtonBB = g_backbarButtons[backIndex]
        if actionButtonBB and actionButtonBB.slot then
            ResetButtonLabel(backIndex, actionButtonBB.slot)
        end
    end
end

-- Resets Potion Timer label
function ActionBar.ResetPotionTimerLabel()
    g_quickslotButton = ZO_ActionBar_GetButton(QuickslotActionButton:GetSlot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    ResetLabelAnchors(uiQuickSlot.label, g_quickslotButton.button, ActionBar.SV.PotionTimerLabelPosition)
end

-- Resets the ultimate labels on menu option change
function ActionBar.ResetUltimateLabel()
    local actionButton = ZO_ActionBar_GetButton(8)
    ResetLabelAnchors(uiUltimate.LabelPct, actionButton.slot, ActionBar.SV.UltimateLabelPosition)

    g_companionUltimateButton = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
    if g_companionUltimateButton then
        ResetLabelAnchors(uiCompanionUltimate.LabelPct, g_companionUltimateButton.slot, ActionBar.SV.UltimateLabelPosition)
    end
end

-- ============================================================================
-- SLOT UPDATE FUNCTIONS
-- ============================================================================

-- Helper to check if slot update should be skipped
local function ShouldSkipSlotUpdate(slotNum)
    if not ActionBar.IsPlayerHotbarCategory(g_hotbarCategory) then
        return true
    end
    if not slotNum or not BACKBAR_INDEX_OFFSET then
        return true
    end

    if slotNum < BACKBAR_INDEX_OFFSET then
        local maxSlot = ActionBar.SV.ShowToggledUltimate and BAR_INDEX_END or (BAR_INDEX_END - 1)
        if slotNum < BAR_INDEX_START or slotNum > maxSlot then
            return true
        end
    end

    if slotNum < BACKBAR_INDEX_OFFSET and not IsSlotUsed(slotNum, g_hotbarCategory) then
        return true
    end

    return false
end

-- Helper to clear slot entries from tables
local function ClearSlotFromTables(slotNum, onlyProc)
    -- Clear triggered slots
    for abilityId, slot in pairs(g_triggeredSlotsFront) do
        if slot == slotNum then
            g_triggeredSlotsFront[abilityId] = nil
        end
    end
    for abilityId, slot in pairs(g_triggeredSlotsBack) do
        if slot == slotNum then
            g_triggeredSlotsBack[abilityId] = nil
        end
    end

    -- Stop proc animations
    if g_uiProcAnimation[slotNum] and g_uiProcAnimation[slotNum]:IsPlaying() then
        g_uiProcAnimation[slotNum]:Stop()
    end

    if onlyProc == false then
        -- Clear toggled slots
        for abilityId, slot in pairs(g_toggledSlotsFront) do
            if slot == slotNum then
                g_toggledSlotsFront[abilityId] = nil
            end
        end
        for abilityId, slot in pairs(g_toggledSlotsBack) do
            if slot == slotNum then
                g_toggledSlotsBack[abilityId] = nil
            end
        end

        if g_uiCustomToggle[slotNum] then
            g_uiCustomToggle[slotNum]:SetHidden(true)
        end
    end
end

-- Helper to get the correct ability ID for a slot
function ActionBar.GetSlotAbilityId(slotNum, hotbarCategory)
    -- Use provided hotbarCategory or fall back to global
    local category = hotbarCategory or g_hotbarCategory

    local ability_id = GetSlotTrueBoundId(slotNum, category)

    if slotNum > BACKBAR_INDEX_OFFSET then
        local inactiveHotbarCategory = GetInactiveHotbarCategory(category)
        ability_id = GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, inactiveHotbarCategory)

        local weaponSlot = inactiveHotbarCategory == HOTBAR_CATEGORY_BACKUP and EQUIP_SLOT_BACKUP_MAIN or EQUIP_SLOT_MAIN_HAND
        local weaponType = GetItemWeaponType(BAG_WORN, weaponSlot)

        if weaponType == WEAPONTYPE_FIRE_STAFF or weaponType == WEAPONTYPE_FROST_STAFF or weaponType == WEAPONTYPE_LIGHTNING_STAFF or weaponType == WEAPONTYPE_NONE then
            if Effects_BarHighlightDestroFix[ability_id] and Effects_BarHighlightDestroFix[ability_id][weaponType] then
                ability_id = Effects_BarHighlightDestroFix[ability_id][weaponType]
            end
        end
    end

    -- Apply overrides
    if Effects_BarHighlightOverride[ability_id] then
        if Effects_BarHighlightOverride[ability_id].hide then
            return nil
        end
        if Effects_BarHighlightOverride[ability_id].newId then
            ability_id = Effects_BarHighlightOverride[ability_id].newId
        end
    end

    return ability_id
end

-- Helper to setup fake aura for ability
local function SetupFakeAura(ability_id)
    if not g_barFakeAura[ability_id] then
        g_barFakeAura[ability_id] = true
        g_barOverrideCI[ability_id] = true

        -- Only set hardcoded duration if not already overridden
        if Effects_BarHighlightOverride[ability_id] and Effects_BarHighlightOverride[ability_id].duration and not g_barDurationOverride[ability_id] then
            g_barDurationOverride[ability_id] = Effects_BarHighlightOverride[ability_id].duration
        end
    end
end

-- Helper to process proc effects for a slot
local function ProcessProcEffects(slotNum, ability_id, abilityName, currentTimeMs)
    local triggeredSlots = slotNum > BACKBAR_INDEX_OFFSET and g_triggeredSlotsBack or g_triggeredSlotsFront
    local proc = Effects_HasAbilityProc[abilityName]

    if proc and g_triggeredSlotsRemain[proc] then
        triggeredSlots[proc] = slotNum
        if ActionBar.SV.ShowTriggered then
            ActionBar.PlayProcAnimations(slotNum)
            if ActionBar.SV.BarShowLabel then
                if not g_uiProcAnimation[slotNum] then
                    return
                end
                local remain = g_triggeredSlotsRemain[proc] - currentTimeMs
                g_uiProcAnimation[slotNum].procLoopTexture.label:SetText(SetBarRemainLabel(remain, ability_id))
            end
        end
    end
end

-- Helper to process toggled effects for a slot
local function ProcessToggledEffects(slotNum, ability_id, duration, currentTimeMs)
    local toggledSlots = slotNum > BACKBAR_INDEX_OFFSET and g_toggledSlotsBack or g_toggledSlotsFront

    if duration > 0 or Effects_AddNoDurationBarHighlight[ability_id] or Effects_IsGrimFocus[ability_id] or Effects_IsBloodFrenzy[ability_id] or Effects_MajorMinor[ability_id] then
        toggledSlots[ability_id] = slotNum
        if g_toggledSlotsRemain[ability_id] and ActionBar.SV.ShowToggled then
            local slotNumST = toggledSlots[ability_id]
            local desaturate
            local mainBarSlotIndex = slotNumST > BACKBAR_INDEX_OFFSET and slotNumST - BACKBAR_INDEX_OFFSET or nil
            if mainBarSlotIndex and g_uiCustomToggle[mainBarSlotIndex] then
                desaturate = false
                if g_uiCustomToggle[mainBarSlotIndex]:IsHidden() then
                    ActionBar.BackbarHideSlot(slotNumST)
                    desaturate = true
                end
            end
            ActionBar.ShowSlot(slotNumST, ability_id, currentTimeMs, desaturate)
        end
    end
end

--- Handles slot updated event
--- @param slotNum integer
--- @param wasfullUpdate boolean
--- @param onlyProc boolean
function ActionBar.BarSlotUpdate(slotNum, wasfullUpdate, onlyProc)
    if ShouldSkipSlotUpdate(slotNum) then
        return
    end

    ClearSlotFromTables(slotNum, onlyProc)

    local ability_id = ActionBar.GetSlotAbilityId(slotNum)
    if not ability_id then
        return
    end

    local showFakeAura = (Effects_BarHighlightOverride[ability_id] and Effects_BarHighlightOverride[ability_id].showFakeAura)
    if showFakeAura then
        SetupFakeAura(ability_id)
    end

    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(ability_id))
    local abilityName = Effects_EffectOverride[ability_id] and Effects_EffectOverride[ability_id].name or cachedName
    local duration = GetUpdatedAbilityDuration(ability_id) or 0
    local currentTimeMs = timeMs()

    ProcessProcEffects(slotNum, ability_id, abilityName, currentTimeMs)

    if onlyProc == false then
        ProcessToggledEffects(slotNum, ability_id, duration, currentTimeMs)
    end
end

-- ============================================================================
-- GCD HOOK FUNCTIONS
-- ============================================================================

do
    local FORCE_SUPPRESS_COOLDOWN_SOUND = true
    function ActionBar.HookGCD()
        --- @diagnostic disable-next-line: duplicate-set-field
        function ActionButton:UpdateUsable()
            local isGamepad = IsInGamepadPreferredMode()
            local isShowingCooldown = self.showingCooldown
            local slotNum = self:GetSlot()
            local hotbarCategory = self:GetHotbarCategory()
            local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotNum, hotbarCategory)
            local isKeyboardUltimateSlot = not isGamepad and ZO_ActionBar_IsUltimateSlot(slotNum, hotbarCategory)
            local usable = false
            if not self.useFailure and not isShowingCooldown then
                usable = true
            elseif isKeyboardUltimateSlot and self.costFailureOnly then
                usable = true
            elseif IsSlotItemConsumable(slotNum, hotbarCategory) and duration <= 1000 and not self.useFailure then
                usable = true
            end

            local slotType = GetSlotType(slotNum, hotbarCategory)
            local stackEmpty = false
            if slotType == ACTION_TYPE_ITEM then
                local stackCount = GetSlotItemCount(slotNum, hotbarCategory)
                if stackCount <= 0 then
                    stackEmpty = true
                    usable = false
                end
            end

            local useDesaturation = (isShowingCooldown and ActionBar.SV.GlobalDesat) or stackEmpty
            if usable ~= self.usable or useDesaturation ~= self.useDesaturation then
                self.usable = usable
                self.useDesaturation = useDesaturation
                ZO_ActionSlot_SetUnusable(self.icon, not usable, useDesaturation)
            end
        end

        -- Helper: Determine if cooldown should be shown
        local function ShouldShowCooldown(duration, isGlobal, slotType, globalSlotType)
            local isInCooldown = duration > 0
            local showGlobalCooldownForCollectible = isGlobal and slotType == ACTION_TYPE_COLLECTIBLE and globalSlotType == ACTION_TYPE_COLLECTIBLE
            return isInCooldown and (ActionBar.SV.GlobalShowGCD or not isGlobal or showGlobalCooldownForCollectible)
        end

        -- Helper: Check if cooldown should be shown for consumables
        local function ShouldShowCooldownForConsumable(slotNum, hotbarCategory, duration, showCooldown)
            if not showCooldown then
                return false
            end
            return not IsSlotItemConsumable(slotNum, hotbarCategory) or duration > 1000 or ActionBar.SV.GlobalPotion
        end

        -- Helper: Start cooldown animation with proper settings
        local function StartCooldownAnimation(button, remain, duration, shouldShowCooldown)
            local cooldownType = CooldownMethod[ActionBar.SV.GlobalMethod] or CD_TYPE_RADIAL

            -- Reset cooldown before starting to ensure clean state
            if not button.showingCooldown then
                button.cooldown:ResetCooldown()
            end

            if cooldownType == CD_TYPE_VERTICAL_REVEAL then
                -- CD_TYPE_VERTICAL_REVEAL requires leading edge setup (matching ZOS implementation)
                button.cooldown:SetVerticalCooldownLeadingEdgeHeight(4)
                button.cooldown:StartCooldown(remain, duration, cooldownType, nil, true)
            else
                -- CD_TYPE_RADIAL uses drawLeadingEdge = false
                button.cooldown:StartCooldown(remain, duration, cooldownType, nil, false)
            end

            if button.cooldownCompleteAnim.animation then
                button.cooldownCompleteAnim.animation:GetTimeline():PlayInstantlyToStart()
            end

            if IsInGamepadPreferredMode() then
                button.cooldown:SetHidden(true)
                if not button.showingCooldown then
                    button:SetNeedsAnimationParameterUpdate(true)
                    button:PlayAbilityUsedBounce()
                end
            else
                button.cooldown:SetHidden(not shouldShowCooldown)
            end

            button.slot:SetHandler("OnUpdate", function () button:RefreshCooldown() end, "CooldownUpdate")
        end

        -- Helper: Handle cooldown complete animation
        local function HandleCooldownComplete(button, slotNum, hotbarCategory, duration, options, updateChromaQuickslot)
            if not ActionBar.SV.GlobalFlash or not button.showingCooldown then
                return
            end

            local shouldPlayAnimation = not IsSlotItemConsumable(slotNum, hotbarCategory) or duration > 1000 or ActionBar.SV.GlobalPotion
            if shouldPlayAnimation then
                if options ~= FORCE_SUPPRESS_COOLDOWN_SOUND then
                    PlaySound(SOUNDS.ABILITY_READY)
                end

                button.cooldownCompleteAnim.animation = button.cooldownCompleteAnim.animation or CreateSimpleAnimation(ANIMATION_TEXTURE, button.cooldownCompleteAnim)
                local anim = button.cooldownCompleteAnim.animation

                button.cooldownCompleteAnim:SetHidden(false)
                button.cooldown:SetHidden(false)

                anim:SetImageData(16, 1)
                anim:SetFramerate(30)
                anim:GetTimeline():PlayFromStart()

                if updateChromaQuickslot then
                    ZO_RZCHROMA_EFFECTS:AddKeybindActionEffect("ACTION_BUTTON_9")
                end
            end

            button.icon.percentComplete = 1
            button.slot:SetHandler("OnUpdate", nil, "CooldownUpdate")
            button.cooldown:ResetCooldown()
        end

        --- @diagnostic disable-next-line: duplicate-set-field
        function ActionButton:UpdateCooldown(options)
            local slotNum = self:GetSlot()
            local hotbarCategory = self:GetHotbarCategory()
            local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotNum, hotbarCategory)
            local slotType = GetSlotType(slotNum, hotbarCategory)
            local updateChromaQuickslot = (slotType ~= ACTION_TYPE_ABILITY and slotType ~= ACTION_TYPE_CRAFTED_ABILITY) and ZO_RZCHROMA_EFFECTS

            -- Determine if cooldown should be shown using helper functions
            local showCooldown = ShouldShowCooldown(duration, global, slotType, globalSlotType)
            local shouldShowCooldown = ShouldShowCooldownForConsumable(slotNum, hotbarCategory, duration, showCooldown)

            if showCooldown then
                StartCooldownAnimation(self, remain, duration, shouldShowCooldown)

                if updateChromaQuickslot then
                    ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect("ACTION_BUTTON_9")
                end
            else
                HandleCooldownComplete(self, slotNum, hotbarCategory, duration, options, updateChromaQuickslot)

                if showCooldown ~= self.showingCooldown then
                    self:SetShowCooldown(showCooldown)
                    self:UpdateActivationHighlight()

                    if IsInGamepadPreferredMode() then
                        self:SetCooldownPercentComplete(self.icon.percentComplete)
                    end
                end
            end

            -- Update desaturation state
            local shouldDesaturate = showCooldown or self.itemQtyFailure
            -- For backbar buttons, don't override desaturation if BarDesaturateUnused is enabled
            if not (hotbarCategory == HOTBAR_CATEGORY_BACKUP and ActionBar.SV.BarDesaturateUnused) then
                self.icon:SetDesaturation(shouldDesaturate and 1 or 0)
            end

            -- Update button text color
            local textColor = showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED
            self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))

            self.isGlobalCooldown = global
            self:UpdateUsable()
        end
    end
end

-- ============================================================================
-- ULTIMATE LABEL FUNCTIONS
-- ============================================================================

-- Helper to calculate ultimate percentage
function ActionBar.CalculateUltimatePercentage(powerValue)
    local pct = (g_ultimateCost > 0) and zo_floor((powerValue / g_ultimateCost) * 100) or 0
    return pct > 100 and 100 or pct
end

-- Helper to update label text content
function ActionBar.UpdateUltimateLabelText(pct, powerValue)
    if ActionBar.SV.UltimatePctEnabled then
        uiUltimate.LabelPct:SetText(pct .. "%")
    end
    if ActionBar.SV.UltimateLabelEnabled then
        uiUltimate.LabelVal:SetText(powerValue .. "/" .. g_ultimateCost)
    end
end

-- Helper to determine if percentage label should be hidden
local function ShouldHidePercentageLabel(pct)
    if not ActionBar.SV.UltimatePctEnabled then
        return true
    end
    if ActionBar.SV.ShowToggledUltimate and g_uiCustomToggle[8] and not g_uiCustomToggle[8]:IsHidden() then
        return true
    end
    if pct == 100 and ActionBar.SV.UltimateHideFull then
        return true
    end
    return false
end

-- Helper to apply color coding to ultimate label
function ActionBar.ApplyUltimateLabelColor(pct)
    if not ActionBar.SV.UltimateLabelEnabled then
        return
    end

    if pct < 100 then
        -- Apply percentage-based color coding
        for i = #uiUltimate.pctColors, 1, -1 do
            if pct < uiUltimate.pctColors[i].pct then
                uiUltimate.LabelVal:SetColor(unpack(uiUltimate.pctColors[i].color))
                return
            end
        end
    else
        -- Full ultimate - use default color
        uiUltimate.LabelVal:SetColor(unpack(uiUltimate.color))
    end
end

-- Helper to update ultimate label visibility
function ActionBar.UpdateUltimateLabelVisibility(pct)
    local hidePctLabel = ShouldHidePercentageLabel(pct)
    local hideValLabel = not ActionBar.SV.UltimateLabelEnabled

    uiUltimate.LabelPct:SetHidden(hidePctLabel)
    uiUltimate.LabelVal:SetHidden(hideValLabel)
end

function ActionBar.UpdateUltimateLabel()
    if not ActionBar.IsPlayerHotbarCategory(g_hotbarCategory) then
        return
    end
    local bar = g_hotbarCategory
    g_ultimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, bar) or 0

    -- Use cached ultimate value instead of calling GetUnitPower again
    local current = g_ultimateCurrent

    if not IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
        return
    end

    local pct = ActionBar.CalculateUltimatePercentage(current)

    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        ActionBar.UpdateUltimateLabelText(pct, current)
        ActionBar.ApplyUltimateLabelColor(pct)
        ActionBar.UpdateUltimateLabelVisibility(pct)
    else
        -- Hide labels when both settings are disabled
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
    end
end

function ActionBar.UpdateCompanionUltimateLabel()
    if not ActionBar.ShouldShowCompanionUltimateButton() then
        return
    end
    g_companionUltimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, HOTBAR_CATEGORY_COMPANION) or 0

    -- Use cached ultimate value instead of calling GetUnitPower again
    local current = g_companionUltimateCurrent

    if not ActionBar.ShouldShowCompanionUltimateButton() then
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
        return
    end

    g_companionUltimateButton = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
    if not g_companionUltimateButton or not IsSlotUsed(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION) then
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
        return
    end

    local pct = (g_companionUltimateCost > 0) and zo_floor((current / g_companionUltimateCost) * 100) or 0
    pct = pct > 100 and 100 or pct

    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        if ActionBar.SV.UltimatePctEnabled then
            uiCompanionUltimate.LabelPct:SetText(pct .. "%")
        end
        if ActionBar.SV.UltimateLabelEnabled then
            uiCompanionUltimate.LabelVal:SetText(current .. "/" .. g_companionUltimateCost)
        end

        -- Apply color coding
        if ActionBar.SV.UltimateLabelEnabled then
            if pct < 100 then
                for i = #uiCompanionUltimate.pctColors, 1, -1 do
                    if pct < uiCompanionUltimate.pctColors[i].pct then
                        uiCompanionUltimate.LabelVal:SetColor(unpack(uiCompanionUltimate.pctColors[i].color))
                        break
                    end
                end
            else
                uiCompanionUltimate.LabelVal:SetColor(unpack(uiCompanionUltimate.color))
            end
        end

        -- Update visibility
        local hidePctLabel = not ActionBar.SV.UltimatePctEnabled
        if ActionBar.SV.UltimatePctEnabled and pct == 100 and ActionBar.SV.UltimateHideFull then
            hidePctLabel = true
        end
        local hideValLabel = not ActionBar.SV.UltimateLabelEnabled

        uiCompanionUltimate.LabelPct:SetHidden(hidePctLabel)
        uiCompanionUltimate.LabelVal:SetHidden(hideValLabel)
    else
        -- Hide labels when both settings are disabled
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
    end
end

-- ============================================================================
-- SLOT VISIBILITY FUNCTIONS
-- ============================================================================

-- Helper to handle backbar operations for a slot
local function HandleBackbarSlot(slotNum, showSlot, desaturate)
    if slotNum <= BACKBAR_INDEX_OFFSET or slotNum == BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
        return
    end

    if showSlot then
        ActionBar.BackbarShowSlot(slotNum)
        -- desaturate parameter: false = don't desaturate (active toggle), true/nil = use default/base state
        ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
    else
        ActionBar.BackbarHideSlot(slotNum)
        -- When hiding, use default behavior (nil) which respects BarDesaturateUnused setting
        ActionBar.ToggleBackbarSaturation(slotNum, nil)
    end
end

-- Helper to handle ultimate slot label visibility
local function HandleUltimateLabelVisibility(slotNum, hideLabel)
    if slotNum ~= 8 and slotNum ~= g_ultimateSlot then
        return
    end

    if slotNum == 8 and ActionBar.SV.UltimatePctEnabled then
        uiUltimate.LabelPct:SetHidden(hideLabel)
    elseif slotNum == g_ultimateSlot and ActionBar.SV.UltimatePctEnabled and IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        uiUltimate.LabelPct:SetHidden(false)
    end
end

-- Helper to calculate stack count for an ability
local function GetAbilityStackCount(abilityId)
    if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
        return g_toggledSlotsStack[abilityId]
    elseif g_mineStacks[abilityId] and g_mineStacks[abilityId] > 0 and not Effects_HideGroundMineStacks[abilityId] then
        return g_mineStacks[abilityId]
    end
    return nil
end

-- Helper to update slot labels and stack display
local function UpdateSlotLabels(slotNum, abilityId, currentTimeMs)
    if not ActionBar.SV.BarShowLabel or not g_uiCustomToggle[slotNum] then
        return
    end

    local remain = g_toggledSlotsRemain[abilityId] - currentTimeMs
    g_uiCustomToggle[slotNum].label:SetText(SetBarRemainLabel(remain, abilityId))

    -- Update gradient color based on remaining time
    if ActionBar.SV.RemainingTextColoured then
        local duration = GetUpdatedAbilityDuration(abilityId) or 0
        local color = GetActionBarGradientColor(remain, duration)
        g_uiCustomToggle[slotNum].label:SetColor(unpack(color))
        g_uiCustomToggle[slotNum].stack:SetColor(unpack(color))
    end

    local stackCount = GetAbilityStackCount(abilityId)
    g_uiCustomToggle[slotNum].stack:SetText(stackCount and stackCount > 0 and stackCount or "")
end

--- Hides slot
--- @param slotNum integer Slot number
--- @param abilityId integer Ability ID
function ActionBar.HideSlot(slotNum, abilityId)
    g_uiCustomToggle[slotNum]:SetHidden(true)
    HandleBackbarSlot(slotNum, false)
    HandleUltimateLabelVisibility(slotNum, false)
end

--- Shows slot
--- @param slotNum number
--- @param abilityId number
--- @param currentTimeMs number
--- @param desaturate boolean
function ActionBar.ShowSlot(slotNum, abilityId, currentTimeMs, desaturate)
    ActionBar.ShowCustomToggle(slotNum)
    HandleBackbarSlot(slotNum, true, desaturate)
    HandleUltimateLabelVisibility(slotNum, true)
    UpdateSlotLabels(slotNum, abilityId, currentTimeMs)
end

--- Handles backbar hide slot event
--- @param slotNum number
function ActionBar.BackbarHideSlot(slotNum)
    if ActionBar.SV.BarHideUnused or g_backbarUniqueHidden then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(true)
        end
    end
end

--- Handles backbar show slot event
--- @param slotNum number
function ActionBar.BackbarShowSlot(slotNum)
    if g_backbarUniqueHidden then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(true)
        end
        return
    end
    if ActionBar.SV.BarShowBack then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(false)
        end
    end
end

--- Handles backbar saturation toggle event
--- @param slotNum number
--- @param desaturate boolean? Optional: force desaturation state. false = no desaturation (active toggle), true = desaturate, nil = use BarDesaturateUnused setting
function ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
    local button = g_backbarButtons[slotNum]
    if not button then
        return
    end

    -- Handle darkening (BarDarkUnused) - this uses ZO_ActionSlot_SetUnusable
    if ActionBar.SV.BarDarkUnused then
        -- Darken all backbar buttons when BarDarkUnused is enabled
        ZO_ActionSlot_SetUnusable(button.icon, true, false)
    else
        -- Clear darkening if BarDarkUnused is disabled
        ZO_ActionSlot_SetUnusable(button.icon, false, false)
    end

    -- Handle desaturation
    if desaturate == false then
        -- Explicitly don't desaturate (e.g., for active toggle effects)
        button.icon:SetDesaturation(0)
    elseif ActionBar.SV.BarDesaturateUnused then
        -- Always desaturate backbar buttons when the setting is enabled
        button.icon:SetDesaturation(1)
    elseif desaturate == true then
        -- Explicitly desaturate (e.g., for cooldowns)
        button.icon:SetDesaturation(1)
    else
        -- Default (nil): desaturate backbar buttons (inactive bar)
        button.icon:SetDesaturation(1)
    end
end

-- Called from the menu and on init
function ActionBar.BackbarToggleSettings()
    for i = BAR_INDEX_START, BACKBAR_INDEX_END do
        local slotNum = i + BACKBAR_INDEX_OFFSET
        local targetButton = g_backbarButtons[slotNum]

        if ActionBar.SV.BarShowBack and not ActionBar.SV.BarHideUnused then
            targetButton.slot:SetHidden(g_backbarUniqueHidden)
        end

        -- Check if this slot has an active toggle effect (should not be desaturated)
        local hasActiveToggle = false
        if g_uiCustomToggle[slotNum] and not g_uiCustomToggle[slotNum]:IsHidden() then
            hasActiveToggle = true
        end

        -- Apply darkening and desaturation for backbar buttons
        ActionBar.ToggleBackbarSaturation(slotNum, hasActiveToggle and false or nil)

        if ActionBar.SV.BarHideUnused or not ActionBar.SV.BarShowBack or g_backbarUniqueHidden then
            targetButton.slot:SetHidden(true)
        end
    end
end

-- ============================================================================
-- ANIMATION FUNCTIONS (PROC AND TOGGLE)
-- ============================================================================

-- Helper to get the appropriate action button for a slot
local function GetActionButtonForSlot(slotNum)
    if slotNum < BACKBAR_INDEX_OFFSET then
        return ZO_ActionBar_GetButton(slotNum)
    else
        return g_backbarButtons[slotNum]
    end
end

-- Helper to create the proc loop texture
local function CreateProcLoopTexture(actionButton)
    local procLoopTexture = UI:ControlWithType(actionButton.slot, "fill", nil, false, "$(parent)Loop_LUIE", CT_TEXTURE)
    --- @cast procLoopTexture TextureControl
    procLoopTexture:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
    procLoopTexture:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
    procLoopTexture:SetTexture("/esoui/art/actionbar/abilityhighlight_mage_med.dds")
    procLoopTexture:SetBlendMode(TEX_BLEND_MODE_ADD)
    procLoopTexture:SetDrawLayer(DL_TEXT)
    procLoopTexture:SetHidden(true)
    return procLoopTexture
end

-- Helper to create and setup the proc animation label
local function CreateProcAnimationLabel(procLoopTexture, actionButton)
    local label = UI:Label(procLoopTexture, nil, nil, nil, g_barFont, nil, false)
    ResetLabelAnchors(label, actionButton.slot, ActionBar.SV.BarLabelPosition)
    label:SetDrawLayer(DL_CONTROLS)
    label:SetDrawLevel(DL_OVERLAY)
    label:SetDrawTier(DT_HIGH)
    -- Default to high color on creation, will be updated in OnUpdate
    label:SetColor(unpack(ActionBar.SV.RemainingTextColoured and ActionBar.SV.RemainingTextColorHigh or { 1, 1, 1, 1 }))
    label:SetHidden(false)
    procLoopTexture.label = label
end

-- Helper to create the animation timeline with handlers
local function CreateProcAnimationTimeline(procLoopTexture)
    local procLoopTimeline = animationManager:CreateTimelineFromVirtual("UltimateReadyLoop", procLoopTexture)
    procLoopTimeline.procLoopTexture = procLoopTexture

    local onPlay = function (self)
        self.procLoopTexture:SetHidden(false)
    end
    local onStop = function (self)
        self.procLoopTexture:SetHidden(true)
    end

    procLoopTimeline:SetHandler("OnPlay", onPlay, "OnPlay")
    procLoopTimeline:SetHandler("OnStop", onStop, "OnStop")

    return procLoopTimeline
end

-- Helper to initialize proc animation UI elements
local function InitializeProcAnimation(slotNum)
    if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
        return nil
    end

    local actionButton = GetActionButtonForSlot(slotNum)
    if not actionButton then
        return nil
    end

    local procLoopTexture = CreateProcLoopTexture(actionButton)
    CreateProcAnimationLabel(procLoopTexture, actionButton)
    local procLoopTimeline = CreateProcAnimationTimeline(procLoopTexture)

    return procLoopTimeline
end

--- @param slotNum integer
function ActionBar.PlayProcAnimations(slotNum)
    -- Initialize animation if it doesn't exist
    if not g_uiProcAnimation[slotNum] then
        g_uiProcAnimation[slotNum] = InitializeProcAnimation(slotNum)
    end

    -- Play animation if it exists and isn't already playing
    if g_uiProcAnimation[slotNum] and not g_uiProcAnimation[slotNum]:IsPlaying() then
        g_uiProcAnimation[slotNum]:PlayFromStart()
    end
end

-- Helper to create the toggle texture frame
local function CreateToggleTexture(actionButton)
    local toggleFrame = UI:ControlWithType(actionButton.slot, "fill", nil, false, "$(parent)Toggle_LUIE", CT_TEXTURE)
    --- @cast toggleFrame TextureControl
    toggleFrame:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
    toggleFrame:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
    toggleFrame:SetTexture("EsoUI/Art/ActionBar/ActionSlot_toggledon.dds")
    toggleFrame:SetBlendMode(TEX_BLEND_MODE_ADD)
    toggleFrame:SetDrawLayer(DL_BACKGROUND)
    toggleFrame:SetDrawLevel(DL_BACKGROUND)
    toggleFrame:SetDrawTier(DT_HIGH)
    toggleFrame:SetColor(0.5, 1, 0.5, 1)
    toggleFrame:SetHidden(false)
    return toggleFrame
end

-- Helper to create the main toggle label
local function CreateToggleLabel(toggleFrame, actionButton)
    local label = UI:Label(toggleFrame, nil, nil, nil, g_barFont, nil, false)
    ResetLabelAnchors(label, actionButton.slot, ActionBar.SV.BarLabelPosition)
    label:SetDrawLayer(DL_CONTROLS)
    label:SetDrawLevel(DL_CONTROLS)
    label:SetDrawTier(DT_HIGH)
    -- Default to high color on creation, will be updated in OnUpdate
    label:SetColor(unpack(ActionBar.SV.RemainingTextColoured and ActionBar.SV.RemainingTextColorHigh or { 1, 1, 1, 1 }))
    label:SetHidden(false)
    toggleFrame.label = label
end

-- Helper to create the stack label
local function CreateToggleStackLabel(toggleFrame, actionButton)
    local stack = UI:Label(toggleFrame, nil, nil, nil, g_barFont, nil, false)
    stack:SetAnchor(CENTER, actionButton.slot, BOTTOMLEFT)
    stack:SetAnchor(CENTER, actionButton.slot, TOPRIGHT, -12, 14)
    stack:SetDrawLayer(DL_CONTROLS)
    stack:SetDrawLevel(DL_CONTROLS)
    stack:SetDrawTier(DT_HIGH)
    -- Default to high color on creation, will be updated in OnUpdate
    stack:SetColor(unpack(ActionBar.SV.RemainingTextColoured and ActionBar.SV.RemainingTextColorHigh or { 1, 1, 1, 1 }))
    stack:SetHidden(false)
    toggleFrame.stack = stack
end

-- Helper to initialize custom toggle UI elements
local function InitializeCustomToggle(slotNum)
    if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
        return nil
    end

    local actionButton = GetActionButtonForSlot(slotNum)
    if not actionButton or not actionButton.slot then
        return nil
    end

    -- Check if already exists
    local name = "ActionButton" .. slotNum
    local window = GetWindowManager():GetControlByName(name, "Toggle_LUIE")
    if window then
        return nil
    end

    local toggleFrame = CreateToggleTexture(actionButton)
    CreateToggleLabel(toggleFrame, actionButton)
    CreateToggleStackLabel(toggleFrame, actionButton)

    return toggleFrame
end

-- Displays custom toggle texture
--- @param slotNum integer
function ActionBar.ShowCustomToggle(slotNum)
    -- Initialize toggle if it doesn't exist
    if not g_uiCustomToggle[slotNum] then
        g_uiCustomToggle[slotNum] = InitializeCustomToggle(slotNum)
    end

    -- Show toggle if it exists
    if g_uiCustomToggle[slotNum] then
        g_uiCustomToggle[slotNum]:SetHidden(false)
    end
end

-- ============================================================================
-- UPDATE FUNCTIONS (for OnUpdate ticker)
-- ============================================================================

-- Helper: Update proc animation label with text and color
local function UpdateProcAnimationLabel(procAnim, slotNum, remain, abilityId)
    if not (procAnim and procAnim.procLoopTexture and procAnim.procLoopTexture.label) then
        return
    end

    procAnim.procLoopTexture.label:SetText(SetBarRemainLabel(remain, abilityId))

    if ActionBar.SV.RemainingTextColoured then
        local duration = abilityId and GetUpdatedAbilityDuration(abilityId) or 0
        local color = GetActionBarGradientColor(remain, duration)
        procAnim.procLoopTexture.label:SetColor(unpack(color))
    end
end

-- Helper: Update toggle label with text and color
local function UpdateToggleLabel(toggle, remain, abilityId)
    if not toggle then
        return
    end

    toggle.label:SetText(SetBarRemainLabel(remain, abilityId))

    if ActionBar.SV.RemainingTextColoured then
        local duration = GetUpdatedAbilityDuration(abilityId) or 0
        local color = GetActionBarGradientColor(remain, duration)
        toggle.label:SetColor(unpack(color))
        toggle.stack:SetColor(unpack(color))
    end
end

-- Helper: Update proc animations for frontbar and backbar slots
function ActionBar.UpdateProcSlot(abilityId, expireTime, currentTimeMs)
    local remain = expireTime - currentTimeMs
    local front = g_triggeredSlotsFront[abilityId]
    local back = g_triggeredSlotsBack[abilityId]
    local frontAnim = front and g_uiProcAnimation[front]
    local backAnim = back and g_uiProcAnimation[back]

    -- Stop animations if expired
    if expireTime < currentTimeMs then
        if frontAnim then
            frontAnim:Stop()
        end
        if backAnim then
            backAnim:Stop()
        end
        g_triggeredSlotsRemain[abilityId] = nil
        return
    end

    -- Update labels if showing
    if ActionBar.SV.BarShowLabel and remain then
        if frontAnim then
            local frontAbilityId = ActionBar.GetSlotAbilityId(front)
            UpdateProcAnimationLabel(frontAnim, front, remain, frontAbilityId)
        end
        if backAnim then
            local backAbilityId = ActionBar.GetSlotAbilityId(back)
            UpdateProcAnimationLabel(backAnim, back, remain, backAbilityId)
        end
    end
end

-- Helper: Update toggle highlights for frontbar and backbar slots
function ActionBar.UpdateToggleSlot(abilityId, expireTime, currentTimeMs)
    local remain = expireTime - currentTimeMs
    local front = g_toggledSlotsFront[abilityId]
    local back = g_toggledSlotsBack[abilityId]
    local frontToggle = front and g_uiCustomToggle[front]
    local backToggle = back and g_uiCustomToggle[back]

    -- Hide toggles if expired
    if expireTime < currentTimeMs then
        if frontToggle then
            ActionBar.HideSlot(front, abilityId)
        end
        if backToggle then
            ActionBar.HideSlot(back, abilityId)
        end
        g_toggledSlotsRemain[abilityId] = nil
        g_toggledSlotsStack[abilityId] = nil
        return
    end

    -- Update labels if showing
    if ActionBar.SV.BarShowLabel and remain then
        if frontToggle then
            UpdateToggleLabel(frontToggle, remain, abilityId)
        end
        if backToggle then
            UpdateToggleLabel(backToggle, remain, abilityId)
        end
    end
end

-- Helper: Update quickslot cooldown timer
function ActionBar.UpdateQuickslotCooldown(currentTimeMs)
    if not ActionBar.SV.PotionTimerShow then
        return
    end

    local slotIndex = GetCurrentQuickslot()
    local remain, duration = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    local label = uiQuickSlot.label

    if duration > 1000 then
        label:SetHidden(false)

        -- Use gradient colors based on remaining time
        local color = GetQuickslotGradientColor(remain)
        label:SetColor(unpack(color))

        -- Format time text
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

-- Helper to update proc animation label colors
function ActionBar.UpdateProcLabelColors()
    -- Colors are updated dynamically in OnUpdate based on remaining time
    for slotNum, procAnim in pairs(g_uiProcAnimation) do
        if procAnim and procAnim.procLoopTexture and procAnim.procLoopTexture.label then
            local color = ActionBar.SV.RemainingTextColoured and ActionBar.SV.RemainingTextColorHigh or { 1, 1, 1, 1 }
            procAnim.procLoopTexture.label:SetColor(unpack(color))
        end
    end
end

-- ============================================================================
-- HOTBAR UPDATE FUNCTIONS
-- ============================================================================

-- Local helper to perform full slot update
local function DoSlotsFullUpdate()
    g_activeWeaponSwapInProgress = false
    ActionBar.UpdateBackbarUniqueState(g_hotbarCategory)
    if not ActionBar.IsPlayerHotbarCategory(g_hotbarCategory) then
        return
    end
    if g_potionUsed == true then
        return
    end

    ActionBar.UpdateUltimateLabel()

    for i = BAR_INDEX_START, BAR_INDEX_END do
        ActionBar.BarSlotUpdate(i, true, false)
    end

    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        local button = g_backbarButtons[i]
        ActionBar.SetupBackBarIcons(button, true)
        ActionBar.BarSlotUpdate(i, true, false)
    end

    -- Ensure backbar desaturation is applied after slot updates
    ActionBar.BackbarToggleSettings()
end

--- @param didActiveHotbarChange boolean
function ActionBar.UpdateAllSlotsForActiveHotbar(didActiveHotbarChange)
    local previousCategory = g_hotbarCategory
    local activeHotbarCategory = GetActiveHotbarCategory()

    if not ActionBar.IsPlayerHotbarCategory(activeHotbarCategory) then
        ActionBar.ApplyBackbarUniqueHiddenState(true)
        return
    end

    g_hotbarCategory = activeHotbarCategory
    ActionBar.UpdateBackbarUniqueState(activeHotbarCategory)

    local shouldAnimate = didActiveHotbarChange and (g_activeWeaponSwapInProgress or ShouldAnimateWeaponSwap(previousCategory, activeHotbarCategory))
    if shouldAnimate then
        for _, physicalSlot in pairs(g_backbarButtons) do
            if physicalSlot.hotbarSwapAnimation then
                physicalSlot.noUpdates = true
                physicalSlot.hotbarSwapAnimation:PlayFromStart()
            end
        end
        return
    end

    if g_activeWeaponSwapInProgress then
        return
    end

    if not shouldAnimate then
        DoSlotsFullUpdate()
    end
end

-- Public function to trigger full slot update (called from settings)
function ActionBar.OnSlotsFullUpdate()
    DoSlotsFullUpdate()
end

-- Public handlers for event registration
function ActionBar.HandleActionUpdateCooldowns()
    ActionBar.RefreshVisibleCooldowns()
end

-- ============================================================================
-- BACKBAR SETUP FUNCTIONS
-- ============================================================================

-- Helper to setup weapon swap control positioning
function ActionBar.SetupWeaponSwapControl(style)
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")
    if not weaponSwapControl then
        return
    end

    weaponSwapControl:ClearAnchors()
    weaponSwapControl:SetAnchor(TOPLEFT, ZO_ActionBar1, TOPLEFT, style.weaponSwapOffsetX, style.weaponSwapOffsetY, ANCHOR_CONSTRAINS_XY)
end

-- Helper to determine if a button index should be styled
local function ShouldStyleBackbarButton(index)
    return index > 2 and index < 8
end

-- Helper to get the appropriate anchor target for a backbar button
local function GetBackbarButtonAnchorTarget(index, lastButton, weaponSwapControl)
    if lastButton then
        return lastButton.slot
    end
    return weaponSwapControl
end

-- Helper to setup backbar button anchors and styles
function ActionBar.SetupBackbarButtons(style)
    local lastButton
    local buttonTemplate = ZO_GetPlatformTemplate("ZO_ActionButton")

    for i = BAR_INDEX_START, BAR_INDEX_END do
        local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]
        if targetButton then
            if ShouldStyleBackbarButton(i) then
                local anchorTarget = GetBackbarButtonAnchorTarget(i, lastButton, ACTION_BAR:GetNamedChild("WeaponSwap"))
                targetButton:ApplyAnchor(anchorTarget, style.abilitySlotOffsetX)
                targetButton:ApplyStyle(buttonTemplate)
            end
            lastButton = targetButton
        end
    end
end

-- Helper to position the ultimate backbar button
function ActionBar.PositionUltimateBackbarButton(style)
    local offsetY = ACTION_BAR:GetHeight() * style.backbarHeightMultiplier
    local finalOffset = -(offsetY * style.backbarOffsetMultiplier)

    local ActionButton53 = GetControl("ActionButton53")
    local AB3 = _G["ActionButton3"]

    ActionButton53:ClearAnchors()
    ActionButton53:SetAnchor(CENTER, AB3, CENTER, 0, finalOffset, ANCHOR_CONSTRAINS_XY)
end

function ActionBar.BackbarSetupTemplate(style)
    -- Validate that style is a valid constants table
    if not style or type(style) ~= "table" or not style.weaponSwapOffsetX then
        style = GetPlatformConstants()
    end

    ActionBar.SetupWeaponSwapControl(style)
    ActionBar.UpdateBackbarUniqueState(g_hotbarCategory)
    ActionBar.SetupBackbarButtons(style)
    ActionBar.PositionUltimateBackbarButton(style)
end

-- ============================================================================
-- FONT SETUP FUNCTIONS
-- ============================================================================

-- Setup fonts for action bar UI elements
function ActionBar.SetupFonts(barFont, potionFont, ultimateFont, procSound)
    g_barFont = barFont
    g_potionFont = potionFont
    g_ultimateFont = ultimateFont
    g_ProcSound = procSound

    -- Apply to existing UI elements
    for k, _ in pairs(g_uiProcAnimation) do
        g_uiProcAnimation[k].procLoopTexture.label:SetFont(g_barFont)
    end
    for k, _ in pairs(g_uiCustomToggle) do
        g_uiCustomToggle[k].label:SetFont(g_barFont)
        g_uiCustomToggle[k].stack:SetFont(g_barFont)
    end

    if uiQuickSlot.label then
        uiQuickSlot.label:SetFont(g_potionFont)
    end

    if uiUltimate.LabelPct then
        uiUltimate.LabelPct:SetFont(g_ultimateFont)
    end
    if uiCompanionUltimate.LabelPct then
        uiCompanionUltimate.LabelPct:SetFont(g_ultimateFont)
    end
    if uiCompanionUltimate.LabelVal then
        uiCompanionUltimate.LabelVal:SetFont(g_ultimateFont)
    end
end

-- Updates Proc Sound
function ActionBar.ApplyProcSound(menu)
    local barProcSound = LUIE.Sounds[ActionBar.SV.ProcSoundName]
    if not barProcSound or barProcSound == "" then
        printToChat(GetString(LUIE_STRING_ERROR_SOUND), true)
        barProcSound = "DeathRecap_KillingBlowShown"
    end

    g_ProcSound = barProcSound

    ActionBar.SetupFonts(g_barFont, g_potionFont, g_ultimateFont, g_ProcSound)

    if menu then
        PlaySound(g_ProcSound)
    end
end

-- Applies font changes to all ActionBar elements
function ActionBar.ApplyFont()
    -- Update all fonts
    g_barFont = setupFont("BarFontFace", "BarFontStyle", "BarFontSize", FONT_STYLE_OUTLINE, 17)
    g_potionFont = setupFont("PotionTimerFontFace", "PotionTimerFontStyle", "PotionTimerFontSize", FONT_STYLE_OUTLINE, 17)
    g_ultimateFont = setupFont("UltimateFontFace", "UltimateFontStyle", "UltimateFontSize", FONT_STYLE_OUTLINE, 17)
    local castbarFont = setupFont("CastBarFontFace", "CastBarFontStyle", "CastBarFontSize", FONT_STYLE_SOFT_SHADOW_THICK, 16)

    -- Update fonts for all ActionBar UI elements
    ActionBar.SetupFonts(g_barFont, g_potionFont, g_ultimateFont, g_ProcSound)

    -- Update CastBar font if CastBar module is loaded
    if ActionBar.CastBar and ActionBar.CastBar.SetupFont then
        ActionBar.CastBar.SetupFont(castbarFont)
        -- Update the cast bar display with new font
        if ActionBar.CastBar.UpdateCastBar then
            ActionBar.CastBar.UpdateCastBar()
        end
    end
end

-- ============================================================================
-- EVENT HANDLER FUNCTIONS
-- ============================================================================

-- Forward declarations for functions used before they're defined
local HandleBarHighlightSwap
local OnEffectChanged
local OnReticleTargetChanged

-- Handles bar highlight swap event
local function BarHighlightSwap(abilityId)
    local effect = Effects_BarHighlightCheckOnFade[abilityId]
    local ids = { effect.id1 or 0, effect.id2 or 0, effect.id3 or 0 }
    local tags = { effect.unitTag, effect.id2Tag, effect.id3Tag }
    local duration = effect.duration or 0
    local durationMod = effect.durationMod or 0

    for i, id in pairs(ids) do
        local unitTag = tags[i]
        if not DoesUnitExist(unitTag) then
            return
        end

        if duration > 0 then
            duration = GetUpdatedAbilityDuration(duration) - GetUpdatedAbilityDuration(durationMod)
            local timeStarted = timeMs() / 1000
            local timeEnding = timeStarted + (duration / 1000)
            OnEffectChanged(nil, EFFECT_RESULT_GAINED, nil, nil, unitTag, timeStarted, timeEnding, 0, nil, nil, 1, ABILITY_TYPE_BONUS, 0, nil, nil, abilityId, 1, true, abilityId)
            return
        end

        if id ~= 0 then
            for j = 1, GetNumBuffs(unitTag) do
                local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityIdNew, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, j)
                if id == abilityIdNew and castByPlayer then
                    OnEffectChanged(nil, EFFECT_RESULT_GAINED, nil, nil, unitTag, timeStarted, timeEnding, stackCount, nil, buffType, effectType, abilityType, statusEffectType, nil, nil, abilityId, 1, true, abilityIdNew)
                    return
                end
            end
        end
    end
end

-- Helper to handle BarHighlightSwap calls with null checks
HandleBarHighlightSwap = function (abilityId)
    if Effects_BarHighlightCheckOnFade[abilityId] then
        BarHighlightSwap(abilityId)
    end
end

-- Runs on the EVENT_TARGET_CHANGE listener
local function OnTargetChange(eventCode, unitTag)
    OnReticleTargetChanged(eventCode)
end

-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener
OnReticleTargetChanged = function (eventCode)
    for k, _ in pairs(g_toggledSlotsRemain) do
        local frontSlot = g_toggledSlotsFront[k]
        local backSlot = g_toggledSlotsBack[k]

        if  ((frontSlot and g_uiCustomToggle[frontSlot]) or (backSlot and g_uiCustomToggle[backSlot]))
        and not (g_toggledSlotsPlayer[k] or g_barNoRemove[k]) then
            HideSlotsForAbility(k)
            ClearToggledSlotsData(k)
            HandleBarHighlightSwap(k)
        end
    end

    local unitTag = "reticleover"
    if DoesUnitExist(unitTag) then
        local numBuffs = GetNumBuffs(unitTag)
        for i = 1, numBuffs do
            local unitName = GetRawUnitName(unitTag)
            local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, i)

            local castByPlayerNumeric = castByPlayer and 1 or 5

            if not IsUnitDead(unitTag) then
                OnEffectChanged(
                    0,
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
                    castByPlayerNumeric,
                    false,
                    0
                )
            end
        end
    end
end

-- Handles effect changed event (MASSIVE 285-line handler)
OnEffectChanged = function (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer, passThrough, savedId)
    if g_barFakeAura[abilityId] and not passThrough then
        return
    end
    if castByPlayer ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if Effects_IsVamp[abilityId] and changeType == EFFECT_RESULT_GAINED then
        ActionBar.UpdateUltimateLabel()
    end

    if Castbar.CastBreakOnRemoveEffect[abilityId] and changeType == EFFECT_RESULT_FADED then
        local CastBar = ActionBar.CastBar
        if CastBar then
            CastBar.StopCastBar()
        end
        if abilityId == 33208 then
            return
        end
    end

    if unitTag == "player" then
        if changeType ~= EFFECT_RESULT_FADED then
            g_toggledSlotsPlayer[abilityId] = true
        else
            g_toggledSlotsPlayer[abilityId] = nil
        end
    end

    if (Effects_EffectGroundDisplay[abilityId] or Effects_LinkedGroundMine[abilityId]) and not passThrough then
        if Effects_LinkedGroundMine[abilityId] then
            abilityId = Effects_LinkedGroundMine[abilityId]
        end

        if changeType == EFFECT_RESULT_FADED then
            if abilityId == 32958 then
                return
            end
            local currentTimeMs = timeMs()
            if not g_protectAbilityRemoval[abilityId] or g_protectAbilityRemoval[abilityId] < currentTimeMs then
                if Effects_IsGroundMineAura[abilityId] or Effects_IsGroundMineStack[abilityId] then
                    if g_mineStacks[abilityId] then
                        HandleGroundMineStackChange(abilityId, -Effects_EffectGroundDisplay[abilityId].stackRemove)
                    end
                else
                    if g_barNoRemove[abilityId] then
                        return
                    end
                    if g_toggledSlotsRemain[abilityId] then
                        HideSlotsForAbility(abilityId)
                    end
                    ClearToggledSlotsData(abilityId)
                end
            end
        elseif changeType == EFFECT_RESULT_GAINED then
            if g_mineNoTurnOff[abilityId] then
                g_mineNoTurnOff[abilityId] = nil
            end

            local currentTimeMs = timeMs()
            g_protectAbilityRemoval[abilityId] = currentTimeMs + 150

            if Effects_IsGroundMineAura[abilityId] then
                g_mineStacks[abilityId] = Effects_EffectGroundDisplay[abilityId].stackReset
            elseif Effects_IsGroundMineStack[abilityId] then
                if g_mineStacks[abilityId] then
                    g_mineStacks[abilityId] = g_mineStacks[abilityId] + Effects_EffectGroundDisplay[abilityId].stackRemove
                else
                    g_mineStacks[abilityId] = 1
                end
                if g_mineStacks[abilityId] > Effects_EffectGroundDisplay[abilityId].stackReset then
                    g_mineStacks[abilityId] = Effects_EffectGroundDisplay[abilityId].stackReset
                end
            end

            if ActionBar.SV.ShowToggled then
                g_toggledSlotsPlayer[abilityId] = true
                local currentTimeST = timeMs()
                if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
                    if g_barDurationOverride[abilityId] then
                        g_toggledSlotsRemain[abilityId] = currentTimeST + g_barDurationOverride[abilityId]
                    else
                        g_toggledSlotsRemain[abilityId] = 1000 * endTime
                    end
                    g_toggledSlotsStack[abilityId] = stackCount
                    if g_toggledSlotsFront[abilityId] then
                        local slotNum = g_toggledSlotsFront[abilityId]
                        ActionBar.ShowSlot(slotNum, abilityId, currentTimeST, false)
                    end
                    if g_toggledSlotsBack[abilityId] then
                        local slotNum = g_toggledSlotsBack[abilityId]
                        ActionBar.ShowSlot(slotNum, abilityId, currentTimeST, false)
                    end
                end
            end
        end
    end

    if savedId and Effects_BarHighlightStack[savedId] then
        stackCount = Effects_BarHighlightStack[savedId]
    elseif Effects_BarHighlightStack[abilityId] then
        stackCount = Effects_BarHighlightStack[abilityId]
    end

    -- Handle Crux stack mapping
    if Effects_BarHighlightCruxMap[abilityId] then
        local cruxAbilities = Effects_BarHighlightCruxMap[abilityId]
        local cruxAbilitySet = {}
        for _, cruxAbilityId in ipairs(cruxAbilities) do
            cruxAbilitySet[cruxAbilityId] = true
        end

        if ActionBar.IsPlayerHotbarCategory(g_hotbarCategory) and ActionBar.SV.ShowToggled then
            local currentTimeMs = timeMs()

            -- Check front bar slots
            for slotNum = BAR_INDEX_START, BAR_INDEX_END do
                local slotAbilityId = ActionBar.GetSlotAbilityId(slotNum)
                if slotAbilityId and cruxAbilitySet[slotAbilityId] then
                    if not g_toggledSlotsFront[slotAbilityId] then
                        g_toggledSlotsFront[slotAbilityId] = slotNum
                    end
                    if not g_toggledSlotsRemain[slotAbilityId] then
                        g_toggledSlotsRemain[slotAbilityId] = currentTimeMs + 90000000
                    end
                    g_toggledSlotsStack[slotAbilityId] = stackCount
                    ActionBar.ShowSlot(slotNum, slotAbilityId, currentTimeMs, false)
                    if g_uiCustomToggle[slotNum] and g_uiCustomToggle[slotNum].label then
                        g_uiCustomToggle[slotNum].label:SetText("")
                    end
                end
            end

            -- Check back bar slots
            for slotNum = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
                local slotAbilityId = ActionBar.GetSlotAbilityId(slotNum)
                if slotAbilityId and cruxAbilitySet[slotAbilityId] then
                    if not g_toggledSlotsBack[slotAbilityId] then
                        g_toggledSlotsBack[slotAbilityId] = slotNum
                    end
                    if not g_toggledSlotsRemain[slotAbilityId] then
                        g_toggledSlotsRemain[slotAbilityId] = currentTimeMs + 90000000
                    end
                    g_toggledSlotsStack[slotAbilityId] = stackCount
                    ActionBar.ShowSlot(slotNum, slotAbilityId, currentTimeMs, false)
                    if g_uiCustomToggle[slotNum] and g_uiCustomToggle[slotNum].label then
                        g_uiCustomToggle[slotNum].label:SetText("")
                    end
                end
            end
        end
    end

    if not isFancyActionBarEnabled then
        if Effects_BarHighlightExtraId[abilityId] then
            for k, v in pairs(Effects_BarHighlightExtraId) do
                if k == abilityId then
                    abilityId = v
                    if Effects_IsGroundMineAura[abilityId] then
                        g_toggledSlotsPlayer[abilityId] = nil
                        if unitTag == "reticleover" then
                            g_mineNoTurnOff[abilityId] = true
                        end
                    end
                    break
                end
            end
        end
    end

    if unitTag ~= "player" and unitTag ~= "reticleover" then
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        if g_barNoRemove[abilityId] then
            if Effects_BarHighlightCheckOnFade[abilityId] then
                BarHighlightSwap(abilityId)
            end
            return
        end

        if g_triggeredSlotsRemain[abilityId] then
            HideSlotsForAbility(abilityId)
            ClearToggledSlotsData(abilityId)
        end

        HandleBarHighlightSwap(abilityId)
    else
        if Effects_IsGrimFocus[abilityId] then
            if ActionBar.SV.ShowTriggered and ActionBar.SV.ProcEnableSound then
                if not g_boundArmamentsPlayed[abilityId] then
                    g_boundArmamentsPlayed[abilityId] = {}
                end

                if (stackCount == 5 or stackCount == 10) and not g_boundArmamentsPlayed[abilityId][stackCount] then
                    if not g_disableProcSound[abilityId] then
                        PlaySound(g_ProcSound)
                        PlaySound(g_ProcSound)
                    end
                    g_boundArmamentsPlayed[abilityId][stackCount] = true
                end

                if stackCount < 5 then
                    g_boundArmamentsPlayed[abilityId][5] = false
                    g_boundArmamentsPlayed[abilityId][10] = false
                elseif stackCount < 10 and stackCount > 5 then
                    g_boundArmamentsPlayed[abilityId][10] = false
                end
            end
        elseif Effects_IsBoundArmaments[abilityId] then
            if ActionBar.SV.ShowTriggered and ActionBar.SV.ProcEnableSound then
                if not g_boundArmamentsPlayed[abilityId] then
                    g_boundArmamentsPlayed[abilityId] = {}
                end

                if (stackCount == 4 or stackCount == 8) and not g_boundArmamentsPlayed[abilityId][stackCount] then
                    if not g_disableProcSound[abilityId] then
                        PlaySound(g_ProcSound)
                        PlaySound(g_ProcSound)
                    end
                    g_boundArmamentsPlayed[abilityId][stackCount] = true
                end

                if stackCount < 4 then
                    g_boundArmamentsPlayed[abilityId][4] = false
                    g_boundArmamentsPlayed[abilityId][8] = false
                elseif stackCount < 8 and stackCount > 4 then
                    g_boundArmamentsPlayed[abilityId][8] = false
                end
            end
        end

        if g_triggeredSlotsFront[abilityId] or g_triggeredSlotsBack[abilityId] then
            local currentTimeMs = timeMs()
            if ActionBar.SV.ShowTriggered then
                if ActionBar.SV.ProcEnableSound and unitTag == "player" and g_triggeredSlotsFront[abilityId] then
                    if not g_disableProcSound[abilityId] then
                        if abilityId == 46327 then
                            if changeType == EFFECT_RESULT_GAINED then
                                PlaySound(g_ProcSound)
                                PlaySound(g_ProcSound)
                            end
                        else
                            PlaySound(g_ProcSound)
                            PlaySound(g_ProcSound)
                        end
                    end
                end
                g_triggeredSlotsRemain[abilityId] = 1000 * endTime

                if g_triggeredSlotsFront[abilityId] then
                    ActionBar.PlayProcAnimations(g_triggeredSlotsFront[abilityId])
                end
                if g_triggeredSlotsBack[abilityId] then
                    ActionBar.PlayProcAnimations(g_triggeredSlotsBack[abilityId])
                end
            end
        end

        if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
            local currentTimeMs = timeMs()
            if ActionBar.SV.ShowToggled then
                if Effects_IsGrimFocus[abilityId] or Effects_IsBloodFrenzy[abilityId] then
                    g_toggledSlotsRemain[abilityId] = currentTimeMs + 90000000
                else
                    if g_barDurationOverride[abilityId] then
                        g_toggledSlotsRemain[abilityId] = currentTimeMs + g_barDurationOverride[abilityId]
                    else
                        g_toggledSlotsRemain[abilityId] = 1000 * endTime
                    end
                end
                g_toggledSlotsStack[abilityId] = stackCount
                ShowSlotsForAbility(abilityId, currentTimeMs, false)
            end
        end
    end
end

-- Listens to EVENT_COMBAT_EVENT for ultimate generation and ground mines
local function OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if ActionBar.SV.UltimateGeneration and uiUltimate.NotFull and ((result == ACTION_RESULT_BLOCKED_DAMAGE and targetType == COMBAT_UNIT_TYPE_PLAYER) or (Effects_IsWeaponAttack[abilityName] and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetName ~= "")) then
        uiUltimate.Texture:SetHidden(false)
        uiUltimate.FadeTime = timeMs() + 8000
    end

    -- Helper for damage result validation
    local function isValidDamageResult(res)
        return res == ACTION_RESULT_BLOCKED or res == ACTION_RESULT_BLOCKED_DAMAGE or res == ACTION_RESULT_CRITICAL_DAMAGE or res == ACTION_RESULT_DAMAGE or res == ACTION_RESULT_DAMAGE_SHIELDED or res == ACTION_RESULT_IMMUNE or res == ACTION_RESULT_MISS or res == ACTION_RESULT_PARTIAL_RESIST or res == ACTION_RESULT_REFLECTED or res == ACTION_RESULT_RESIST or res == ACTION_RESULT_WRECKING_DAMAGE or res == ACTION_RESULT_DODGED
    end

    if Effects_IsGroundMineDamage[abilityId] then
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
                    HandleBarHighlightSwap(compareId)
                    return
                end
            end
        end
    end

    -- Delegate cast bar handling to CastBar module
    local CastBar = ActionBar.CastBar
    if CastBar and ActionBar.SV.CastBarEnable then
        CastBar.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    end
end

-- Handles combat event for ability bar UI updates
local function OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if sourceType ~= COMBAT_UNIT_TYPE_PLAYER and targetType ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if sourceType == COMBAT_UNIT_TYPE_PLAYER and targetType == COMBAT_UNIT_TYPE_PLAYER then
        g_toggledSlotsPlayer[abilityId] = true
    end

    if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
        if result == ACTION_RESULT_DAMAGE_SHIELDED and targetType == COMBAT_UNIT_TYPE_PLAYER then
            if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
                if g_toggledSlotsStack[abilityId] then
                    g_toggledSlotsStack[abilityId] = g_toggledSlotsStack[abilityId] - 1
                end
                UpdateStackDisplay(abilityId, g_toggledSlotsStack[abilityId] or 0)
            end
        end
    end

    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        local currentTimeMs = timeMs()
        if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
            if ActionBar.SV.ShowToggled then
                local duration = GetUpdatedAbilityDuration(abilityId)
                local endTime = currentTimeMs + duration
                g_toggledSlotsRemain[abilityId] = endTime
                if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
                    g_toggledSlotsStack[abilityId] = 3
                end
                if abilityId == 35750 or abilityId == 40382 or abilityId == 40372 then
                    g_toggledSlotsStack[abilityId] = 1
                end
                ShowSlotsForAbility(abilityId, currentTimeMs, false)
            end
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        if g_barNoRemove[abilityId] then
            HandleBarHighlightSwap(abilityId)
            return
        end

        if g_toggledSlotsRemain[abilityId] then
            HideSlotsForAbility(abilityId)
            ClearToggledSlotsData(abilityId)
        end
        if Effects_BarHighlightCheckOnFade[abilityId] and targetType == COMBAT_UNIT_TYPE_PLAYER then
            BarHighlightSwap(abilityId)
        end
    end
end

-- Public function to handle bar combat events (exposed for RegisterBarCombatEvents)
function ActionBar.OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
end

-- Runs on EVENT_ACTION_SLOT_EFFECT_UPDATE
local function OnActionSlotEffectUpdated(eventCode, hotbarCategory, actionSlotIndex)
    if not ActionBar.IsPlayerHotbarCategory(hotbarCategory) then
        ActionBar.ApplyBackbarUniqueHiddenState(ActionBar.IsUniqueOverrideHotbarCategory(hotbarCategory))
        return
    end

    local abilityId = GetSlotTrueBoundId(actionSlotIndex, hotbarCategory)
    if not abilityId or abilityId == 0 then
        return
    end

    local duration = GetActionSlotEffectDuration(actionSlotIndex, hotbarCategory)

    if duration > 1 and duration < 1000000 then
        if g_barDurationOverride[abilityId] then
            return
        end

        local remain = GetActionSlotEffectTimeRemaining(actionSlotIndex, hotbarCategory) / 1000
        local internalSlotNum = actionSlotIndex
        if hotbarCategory == HOTBAR_CATEGORY_BACKUP then
            internalSlotNum = internalSlotNum + BACKBAR_INDEX_OFFSET
        end

        if g_toggledSlotsRemain[abilityId] then
            g_toggledSlotsRemain[abilityId] = timeMs() + (remain * 1000)

            -- Only show the slot that corresponds to the hotbar category that triggered this event
            if hotbarCategory == HOTBAR_CATEGORY_BACKUP then
                local backSlot = g_toggledSlotsBack[abilityId]
                if backSlot and g_uiCustomToggle[backSlot] then
                    ActionBar.ShowSlot(backSlot, abilityId, timeMs(), false)
                end
            else
                local frontSlot = g_toggledSlotsFront[abilityId]
                if frontSlot and g_uiCustomToggle[frontSlot] then
                    ActionBar.ShowSlot(frontSlot, abilityId, timeMs(), false)
                end
            end
        else
            if ActionBar.SV.ShowToggled then
                local duration_ms = GetUpdatedAbilityDuration(abilityId)
                if duration_ms > 0 then
                    if hotbarCategory == HOTBAR_CATEGORY_BACKUP then
                        g_toggledSlotsBack[abilityId] = internalSlotNum
                    else
                        g_toggledSlotsFront[abilityId] = internalSlotNum
                    end

                    g_toggledSlotsRemain[abilityId] = timeMs() + (remain * 1000)
                    ActionBar.ShowSlot(internalSlotNum, abilityId, timeMs(), false)
                end
            end

            -- Only learn duration from game API if not already overridden
            if  not g_barDurationOverride[abilityId]
            and not (Effects_BarHighlightOverride[abilityId] and Effects_BarHighlightOverride[abilityId].duration) then
                local existingDuration = GetUpdatedAbilityDuration(abilityId)
                if existingDuration == 0 then
                    g_barDurationOverride[abilityId] = duration
                end
            end
        end
    end
end

-- Runs on EVENT_ACTIVE_WEAPON_PAIR_CHANGED and EVENT_WEAPON_PAIR_LOCK_CHANGED
local function OnActiveWeaponPairChanged(eventCode, activeWeaponPair)
    if activeWeaponPair ~= g_actionBarActiveWeaponPair then
        g_activeWeaponSwapInProgress = true
        local currentHotbarCategory = GetActiveHotbarCategory()
        ActionBar.UpdateBackbarUniqueState(currentHotbarCategory)
        g_actionBarActiveWeaponPair = GetHeldWeaponPair()
        ActionBar.UpdateBackbarButtonActionIds()
    end
end

-- Runs on EVENT_ACTION_BAR_LOCKED_REASON_CHANGED
local function OnActionBarLockedReasonChanged(eventCode, actionBarLockedReason)
    local currentHotbarCategory = GetActiveHotbarCategory()
    if ActionBar.IsPlayerHotbarCategory(currentHotbarCategory) then
        ActionBar.UpdateBackbarUniqueState(currentHotbarCategory)
        if g_activeWeaponSwapInProgress then
            return
        end
        ActionBar.UpdateAllSlotsForActiveHotbar(false)
    else
        ActionBar.ApplyBackbarUniqueHiddenState(ActionBar.IsUniqueOverrideHotbarCategory(currentHotbarCategory))
    end
end

-- Runs on EVENT_ACTION_BAR_IS_RESPECCABLE_BAR_STATE_CHANGED
local function OnActionBarIsRespeccableBarStateChanged(eventCode, isRepeccableBarState)
    local currentHotbarCategory = GetActiveHotbarCategory()
    if ActionBar.IsPlayerHotbarCategory(currentHotbarCategory) then
        ActionBar.UpdateBackbarUniqueState(currentHotbarCategory)
        if g_activeWeaponSwapInProgress then
            return
        end
        ActionBar.UpdateAllSlotsForActiveHotbar(false)
    else
        ActionBar.ApplyBackbarUniqueHiddenState(ActionBar.IsUniqueOverrideHotbarCategory(currentHotbarCategory))
    end
end

-- Runs on EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED
local function OnActiveDaedricArtifactChanged(eventCode, artifactId)
    if artifactId ~= nil then
        ActionBar.ApplyBackbarUniqueHiddenState(true)
    else
        ActionBar.ApplyBackbarUniqueHiddenState(false)
    end

    local currentHotbarCategory = GetActiveHotbarCategory()
    if ActionBar.IsPlayerHotbarCategory(currentHotbarCategory) then
        ActionBar.UpdateBackbarUniqueState(currentHotbarCategory)
        if g_activeWeaponSwapInProgress and not ActionBar.IsUniqueOverrideHotbarCategory(currentHotbarCategory) then
            return
        end
        ActionBar.UpdateAllSlotsForActiveHotbar(true)
    else
        ActionBar.ApplyBackbarUniqueHiddenState(ActionBar.IsUniqueOverrideHotbarCategory(currentHotbarCategory))
    end
end

-- Runs on EVENT_ACTION_SLOT_UPDATED
local function OnSlotUpdated(eventCode, slotNum)
    if slotNum == 8 then
        ActionBar.UpdateUltimateLabel()
        ActionBar.UpdateCompanionUltimateLabel()
    end
end

-- Runs on EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, EVENT_ACTION_SLOT_EFFECTS_CLEARED, EVENT_INVENTORY_FULL_UPDATE
local function OnSlotsFullUpdate()
    DoSlotsFullUpdate()
end

-- Runs on EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(eventCode)
    -- Initialize ultimate power caches from actual current values
    g_ultimateCurrent = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    if DoesUnitExist("companion") and HasActiveCompanion() then
        g_companionUltimateCurrent = GetUnitPower("companion", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    else
        g_companionUltimateCurrent = 0
    end

    -- Enable action bar timers if needed
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        if not IsConsoleUI() then
            ActionBar.SetActionBarTimersEnabled()
        end
    end

    -- Update all slots
    OnSlotsFullUpdate()

    -- Update backbar slots
    for i = 53, 57 do
        ActionBar.BarSlotUpdate(i, true, false)
    end

    -- Update ultimate labels
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        ActionBar.UpdateUltimateLabel()
        ActionBar.UpdateCompanionUltimateLabel()
    end

    -- Update companion button visibility and quickslot anchors
    ActionBar.SetCompanionAnchors()
end

-- Runs on EVENT_UNIT_DEATH_STATE_CHANGED
local function OnDeath(eventCode, unitTag, isDead)
    for slotNum = BAR_INDEX_START, BAR_INDEX_END do
        if g_uiCustomToggle[slotNum] then
            g_uiCustomToggle[slotNum]:SetHidden(true)
        end
    end
    for slotNum = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        if g_uiCustomToggle[slotNum] then
            g_uiCustomToggle[slotNum]:SetHidden(true)
        end
    end
end

-- Runs on EVENT_POWER_UPDATE (player ultimate)
local function OnPowerUpdatePlayer(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    uiUltimate.NotFull = (powerValue < powerMax)

    if not IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
        g_ultimateCurrent = powerValue
        return
    end

    local pct = ActionBar.CalculateUltimatePercentage(powerValue)

    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        ActionBar.UpdateUltimateLabelText(pct, powerValue)
        ActionBar.ApplyUltimateLabelColor(pct)
        ActionBar.UpdateUltimateLabelVisibility(pct)
    else
        -- Hide labels when both settings are disabled
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
    end

    g_ultimateCurrent = powerValue
end

-- Runs on EVENT_POWER_UPDATE (companion ultimate)
local function OnPowerUpdateCompanion(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    uiCompanionUltimate.NotFull = (powerValue < powerMax)

    if not ActionBar.ShouldShowCompanionUltimateButton() then
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
        g_companionUltimateCurrent = powerValue
        return
    end

    g_companionUltimateButton = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
    if not g_companionUltimateButton or not IsSlotUsed(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION) then
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
        g_companionUltimateCurrent = powerValue
        return
    end

    -- Refresh companion ultimate cost before calculating percentage
    g_companionUltimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, HOTBAR_CATEGORY_COMPANION) or 0

    local pct = (g_companionUltimateCost > 0) and zo_floor((powerValue / g_companionUltimateCost) * 100) or 0
    pct = pct > 100 and 100 or pct

    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        if ActionBar.SV.UltimatePctEnabled then
            uiCompanionUltimate.LabelPct:SetText(pct .. "%")
        end
        if ActionBar.SV.UltimateLabelEnabled then
            uiCompanionUltimate.LabelVal:SetText(powerValue .. "/" .. g_companionUltimateCost)
        end

        -- Apply color coding
        if ActionBar.SV.UltimateLabelEnabled then
            if pct < 100 then
                for i = #uiCompanionUltimate.pctColors, 1, -1 do
                    if pct < uiCompanionUltimate.pctColors[i].pct then
                        uiCompanionUltimate.LabelVal:SetColor(unpack(uiCompanionUltimate.pctColors[i].color))
                        break
                    end
                end
            else
                uiCompanionUltimate.LabelVal:SetColor(unpack(uiCompanionUltimate.color))
            end
        end

        -- Update visibility
        local hidePctLabel = not ActionBar.SV.UltimatePctEnabled
        if ActionBar.SV.UltimatePctEnabled and pct == 100 and ActionBar.SV.UltimateHideFull then
            hidePctLabel = true
        end
        local hideValLabel = not ActionBar.SV.UltimateLabelEnabled

        uiCompanionUltimate.LabelPct:SetHidden(hidePctLabel)
        uiCompanionUltimate.LabelVal:SetHidden(hideValLabel)
    else
        -- Hide labels when both settings are disabled
        if uiCompanionUltimate.LabelPct then
            uiCompanionUltimate.LabelPct:SetHidden(true)
        end
        if uiCompanionUltimate.LabelVal then
            uiCompanionUltimate.LabelVal:SetHidden(true)
        end
    end

    g_companionUltimateCurrent = powerValue
end

-- Runs on EVENT_INVENTORY_SINGLE_SLOT_UPDATE
local function OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    if stackCountChange >= 0 then
        ActionBar.UpdateUltimateLabel()
        if ActionBar.ShouldShowCompanionUltimateButton() then
            ActionBar.UpdateCompanionUltimateLabel()
        end
    end
end

-- Runs on EVENT_INVENTORY_ITEM_USED
local function InventoryItemUsed()
    g_potionUsed = true
    LUIE_callLater(function ()
                     g_potionUsed = false
                 end, 200)
end

-- Runs on EVENT_GAMEPAD_PREFERRED_MODE_CHANGED
local function BackbarSetupTemplate(style)
    -- Validate that style is a valid constants table
    if not style or type(style) ~= "table" or not style.weaponSwapOffsetX then
        style = GetPlatformConstants()
    end

    ActionBar.SetupWeaponSwapControl(style)
    ActionBar.UpdateBackbarUniqueState(g_hotbarCategory)
    ActionBar.SetupBackbarButtons(style)
    ActionBar.PositionUltimateBackbarButton(style)
end

-- Runs on EVENT_ACTION_UPDATE_COOLDOWNS
local function HandleActionUpdateCooldowns()
    ActionBar.HandleActionUpdateCooldowns()
end

-- Runs on EVENT_CURSOR_PICKUP
local function HandleCursorPickup(_, cursorType, actionType, _, slotIndex)
    if cursorType == MOUSE_CONTENT_ACTION and abilityDropValidators and abilityDropValidators[actionType] then
        ActionBar.ShowAbilityDropCallouts(actionType, slotIndex)
    end
end

-- Runs on EVENT_CURSOR_DROPPED
local function HandleCursorDropped(_, cursorType)
    if cursorType == MOUSE_CONTENT_ACTION then
        ActionBar.HideAbilityDropCallouts()
    end
end

-- Main ticker update for action bar (RegisterForUpdate)
local function OnUpdate(currentTimeMs)
    -- Update proc animations
    for abilityId, expireTime in pairs(g_triggeredSlotsRemain) do
        ActionBar.UpdateProcSlot(abilityId, expireTime, currentTimeMs)
    end

    -- Update ability highlight toggles
    for abilityId, expireTime in pairs(g_toggledSlotsRemain) do
        ActionBar.UpdateToggleSlot(abilityId, expireTime, currentTimeMs)
    end

    -- Update quickslot cooldown timer
    ActionBar.UpdateQuickslotCooldown(currentTimeMs)

    -- Hide Ultimate generation texture if it is time to do so
    if ActionBar.SV.UltimateGeneration then
        if not uiUltimate.Texture:IsHidden() and uiUltimate.FadeTime < currentTimeMs then
            uiUltimate.Texture:SetHidden(true)
        end
    end

    -- Update cast bar
    if ActionBar.SV.CastBarEnable and ActionBar.CastBar and ActionBar.CastBar.OnUpdate then
        ActionBar.CastBar.OnUpdate(currentTimeMs)
    end
end

-- ============================================================================
-- COMPANION EVENT HANDLERS
-- ============================================================================

-- Runs on EVENT_POWER_UPDATE (companion - filters ultimate)
local function HandleCompanionPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE then
        OnPowerUpdateCompanion(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    end
end

-- Runs on EVENT_ACTIVE_COMPANION_STATE_CHANGED
local function HandleActiveCompanionStateChanged(eventCode, newState, oldState)
    ActionBar.UpdateCompanionUltimateLabel()
    ActionBar.SetCompanionAnchors()
end

-- Runs on EVENT_COMPANION_ACTIVATED
local function HandleCompanionActivated(eventCode, companionId)
    ActionBar.UpdateCompanionUltimateLabel()
    ActionBar.SetCompanionAnchors()
end

-- Runs on EVENT_COMPANION_DEACTIVATED
local function HandleCompanionDeactivated(eventCode)
    ActionBar.UpdateCompanionUltimateLabel()
    ActionBar.SetCompanionAnchors()
end

-- Runs on EVENT_ULTIMATE_ABILITY_COST_CHANGED (companion)
local function HandleUltimateAbilityCostChanged()
    ActionBar.UpdateCompanionUltimateLabel()
end

-- ============================================================================
-- EVENT REGISTRATION FUNCTION
-- ============================================================================

-- Clear and then (maybe) re-register event listeners
function ActionBar.RegisterEvents()
    if not ActionBar.Enabled then
        return
    end

    -- === UNREGISTER ALL EVENTS ===
    eventManager:UnregisterForEvent(moduleName, EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_BAR_LOCKED_REASON_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_BAR_IS_RESPECCABLE_BAR_STATE_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_TARGET_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "Companion", EVENT_EFFECT_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName .. "PowerUpdatePlayer", EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "PowerUpdate2", EVENT_ULTIMATE_ABILITY_COST_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_EFFECT_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ARMORY_BUILD_RESTORE_RESPONSE)
    eventManager:UnregisterForEvent(moduleName, EVENT_WEAPON_PAIR_LOCK_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "ActionCooldowns", EVENT_ACTION_UPDATE_COOLDOWNS)
    eventManager:UnregisterForEvent(moduleName .. "ActionEffectsCleared", EVENT_ACTION_SLOT_EFFECTS_CLEARED)
    eventManager:UnregisterForEvent(moduleName .. "InventoryFullUpdate", EVENT_INVENTORY_FULL_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "CursorPickup", EVENT_CURSOR_PICKUP)
    eventManager:UnregisterForEvent(moduleName .. "CursorDropped", EVENT_CURSOR_DROPPED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "ActiveCompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionActivated", EVENT_COMPANION_ACTIVATED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionDeactivated", EVENT_COMPANION_DEACTIVATED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionUltimateCost", EVENT_ULTIMATE_ABILITY_COST_CHANGED)
    eventManager:UnregisterForUpdate(moduleName .. "OnUpdate")
    eventManager:UnregisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED)

    -- Unregister CastBar events
    local counter = 0
    for result, _ in pairs(Castbar.CastBreakingStatus) do
        local eventName = moduleName .. "CombatEventCC" .. tostring(counter)
        eventManager:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
        counter = counter + 1
    end
    eventManager:UnregisterForEvent(moduleName .. "CastBarSoulGemStart", EVENT_START_SOUL_GEM_RESURRECTION)
    eventManager:UnregisterForEvent(moduleName .. "CastBarSoulGemEnd", EVENT_END_SOUL_GEM_RESURRECTION)
    eventManager:UnregisterForEvent(moduleName .. "CastBarCameraUI", EVENT_GAME_CAMERA_UI_MODE_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CastBarSiegeEnd", EVENT_END_SIEGE_CONTROL)
    eventManager:UnregisterForEvent(moduleName .. "CastBarAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED)
    eventManager:UnregisterForEvent(moduleName .. "CastBarCombatEvent", EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName .. "CastBarWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)

    -- === REGISTER ULTIMATE TRACKING EVENTS ===
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BLOCKED_DAMAGE)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdatePlayer", EVENT_POWER_UPDATE, OnPowerUpdatePlayer)
        eventManager:AddFilterForEvent(moduleName .. "PowerUpdatePlayer", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
        eventManager:AddFilterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT, REGISTER_FILTER_IS_NEW_ITEM, false)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdate2", EVENT_ULTIMATE_ABILITY_COST_CHANGED, ActionBar.UpdateUltimateLabel)
    end

    -- === REGISTER EVENTS FOR ULTIMATE OR CASTBAR ===
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled or ActionBar.SV.CastBarEnable then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
    end

    -- === REGISTER CASTBAR EVENTS ===
    if ActionBar.SV.CastBarEnable and ActionBar.CastBar then
        counter = 0
        for result, _ in pairs(Castbar.CastBreakingStatus) do
            local eventName = moduleName .. "CombatEventCC" .. tostring(counter)
            counter = counter + 1
            eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, ActionBar.CastBar.OnCombatEventBreakCast)
            eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, result)
        end
        eventManager:RegisterForEvent(moduleName .. "CastBarSoulGemStart", EVENT_START_SOUL_GEM_RESURRECTION, ActionBar.CastBar.SoulGemResurrectionStart)
        eventManager:RegisterForEvent(moduleName .. "CastBarSoulGemEnd", EVENT_END_SOUL_GEM_RESURRECTION, ActionBar.CastBar.SoulGemResurrectionEnd)
        eventManager:RegisterForEvent(moduleName .. "CastBarCameraUI", EVENT_GAME_CAMERA_UI_MODE_CHANGED, ActionBar.CastBar.OnGameCameraUIModeChanged)
        eventManager:RegisterForEvent(moduleName .. "CastBarSiegeEnd", EVENT_END_SIEGE_CONTROL, ActionBar.CastBar.OnSiegeEnd)
        eventManager:RegisterForEvent(moduleName .. "CastBarAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED, ActionBar.CastBar.OnAbilityUsed)
        eventManager:RegisterForEvent(moduleName .. "CastBarCombatEvent", EVENT_COMBAT_EVENT, ActionBar.CastBar.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CastBarCombatEvent", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
        eventManager:RegisterForEvent(moduleName .. "CastBarWeaponSwap", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ActionBar.CastBar.OnActiveWeaponPairChanged)
    end

    -- === REGISTER ACTION BAR SLOT EVENTS ===
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled or ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        local function OnActiveHotbarUpdated(event, didActiveHotbarChange)
            ActionBar.UpdateAllSlotsForActiveHotbar(didActiveHotbarChange)
        end
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnActiveHotbarUpdated)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, OnSlotsFullUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, OnSlotsFullUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED, OnSlotUpdated)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, OnActiveWeaponPairChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_WEAPON_PAIR_LOCK_CHANGED, OnActiveWeaponPairChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_BAR_LOCKED_REASON_CHANGED, OnActionBarLockedReasonChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_BAR_IS_RESPECCABLE_BAR_STATE_CHANGED, OnActionBarIsRespeccableBarStateChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED, OnActiveDaedricArtifactChanged)

        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_EFFECT_UPDATE, OnActionSlotEffectUpdated)
    end

    -- === REGISTER TRIGGERED/TOGGLED ABILITY EVENTS ===
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, OnDeath)
        eventManager:AddFilterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, OnTargetChange)
        eventManager:AddFilterForEvent(moduleName, EVENT_TARGET_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
        eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, BackbarSetupTemplate)

        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED, InventoryItemUsed)

        ActionBar.UpdateBarHighlightTables()
    end

    -- === REGISTER EFFECT CHANGED EVENTS ===
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled or ActionBar.SV.CastBarEnable or ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED, OnEffectChanged)
        eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)
        eventManager:RegisterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED, OnEffectChanged)
        eventManager:AddFilterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)
        eventManager:RegisterForEvent(moduleName .. "Companion", EVENT_EFFECT_CHANGED, OnEffectChanged)
        eventManager:AddFilterForEvent(moduleName .. "Companion", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_COMPANION)
    end

    -- === HIDE DEFAULT ULTIMATE NUMBER IF OUR LABELS ARE ENABLED ===
    if not IsConsoleUI() and (ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled) then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, 0, SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA)
    end

    -- === REGISTER ALWAYS-ON EVENTS ===
    eventManager:RegisterForEvent(moduleName .. "ActionCooldowns", EVENT_ACTION_UPDATE_COOLDOWNS, HandleActionUpdateCooldowns)
    eventManager:RegisterForEvent(moduleName .. "ActionEffectsCleared", EVENT_ACTION_SLOT_EFFECTS_CLEARED, OnSlotsFullUpdate)
    eventManager:RegisterForEvent(moduleName .. "InventoryFullUpdate", EVENT_INVENTORY_FULL_UPDATE, OnSlotsFullUpdate)
    eventManager:RegisterForEvent(moduleName .. "CursorPickup", EVENT_CURSOR_PICKUP, HandleCursorPickup)
    eventManager:RegisterForEvent(moduleName .. "CursorDropped", EVENT_CURSOR_DROPPED, HandleCursorDropped)

    -- === REGISTER COMPANION EVENTS ===
    eventManager:RegisterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE, HandleCompanionPowerUpdate)
    eventManager:AddFilterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "companion")

    eventManager:RegisterForEvent(moduleName .. "ActiveCompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED, HandleActiveCompanionStateChanged)
    eventManager:RegisterForEvent(moduleName .. "CompanionActivated", EVENT_COMPANION_ACTIVATED, HandleCompanionActivated)
    eventManager:RegisterForEvent(moduleName .. "CompanionDeactivated", EVENT_COMPANION_DEACTIVATED, HandleCompanionDeactivated)
    eventManager:RegisterForEvent(moduleName .. "CompanionUltimateCost", EVENT_ULTIMATE_ABILITY_COST_CHANGED, HandleUltimateAbilityCostChanged)

    -- === REGISTER UPDATE TICKER AND PLAYER ACTIVATED EVENT ===
    eventManager:RegisterForUpdate(moduleName .. "OnUpdate", 0, OnUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

-- ============================================================================
-- INITIALIZE FUNCTION
-- ============================================================================

-- Initialize action bar module
function ActionBar.Initialize(enabled)
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        ActionBar.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "ActionBar", ActionBar.Defaults)
    else
        ActionBar.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "ActionBar", ActionBar.Defaults)
    end

    -- Migrate font styles if needed
    if not LUIE.IsMigrationDone("actionbar_fontstyles") then
        ActionBar.SV.UltimateFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.UltimateFontStyle)
        ActionBar.SV.BarFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.BarFontStyle)
        ActionBar.SV.PotionTimerFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.PotionTimerFontStyle)
        ActionBar.SV.CastBarFontStyle = LUIE.MigrateFontStyle(ActionBar.SV.CastBarFontStyle)
        LUIE.MarkMigrationDone("actionbar_fontstyles")
    end

    if not enabled then
        return
    end
    ActionBar.Enabled = true

    -- Setup fonts from ActionBar.SV
    g_barFont = setupFont("BarFontFace", "BarFontStyle", "BarFontSize", FONT_STYLE_OUTLINE, 17)
    g_potionFont = setupFont("PotionTimerFontFace", "PotionTimerFontStyle", "PotionTimerFontSize", FONT_STYLE_OUTLINE, 17)
    g_ultimateFont = setupFont("UltimateFontFace", "UltimateFontStyle", "UltimateFontSize", FONT_STYLE_OUTLINE, 17)
    local g_castbarFont = setupFont("CastBarFontFace", "CastBarFontStyle", "CastBarFontSize", FONT_STYLE_SOFT_SHADOW_THICK, 16)

    -- Setup proc sound
    ActionBar.ApplyProcSound()

    -- Setup CastBar font (CastBar module should be loaded by now)
    if ActionBar.CastBar and ActionBar.CastBar.SetupFont then
        ActionBar.CastBar.SetupFont(g_castbarFont)
    end

    -- Initialize CastBar module
    if ActionBar.SV.CastBarEnable and ActionBar.CastBar and ActionBar.CastBar.Initialize then
        ActionBar.CastBar.Initialize()
    end

    g_quickslotButton = ZO_ActionBar_GetButton(QuickslotActionButton:GetSlot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    uiQuickSlot.label = UI:Label(g_quickslotButton.button, { CENTER, CENTER }, nil, nil, g_potionFont, nil, true)
    uiQuickSlot.label:SetFont(g_potionFont)
    -- Default to high color, will be updated in OnUpdate
    uiQuickSlot.label:SetColor(unpack(ActionBar.SV.PotionTimerColor and ActionBar.SV.PotionTimerTextColorHigh or { 1, 1, 1, 1 }))
    uiQuickSlot.label:SetDrawLayer(DL_OVERLAY)
    uiQuickSlot.label:SetDrawTier(DT_HIGH)

    ActionBar.ResetPotionTimerLabel()

    local actionButton = ZO_ActionBar_GetButton(g_ultimateSlot, g_hotbarCategory)

    local AB8 = _G["ActionButton8"]
    uiUltimate.LabelVal = UI:Label(AB8, { BOTTOM, TOP, 0, -3 }, nil, { 1, 2 }, ZO_CreateFontString("$(BOLD_FONT)", 16, FONT_STYLE_SOFT_SHADOW_THICK), nil, true)
    uiUltimate.LabelPct = UI:Label(AB8, nil, nil, nil, g_ultimateFont, nil, true)
    uiUltimate.LabelPct:SetAnchor(TOPLEFT, actionButton.slot, nil, 0, 0)
    uiUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -ActionBar.SV.UltimateLabelPosition)

    uiUltimate.LabelPct:SetColor(unpack(uiUltimate.color))
    uiUltimate.Texture = UI:Texture(AB8, { CENTER, CENTER }, { 160, 160 }, "/esoui/art/crafting/white_burst.dds", DL_BACKGROUND, true)

    -- Initialize companion ultimate labels
    g_companionUltimateButton = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
    if g_companionUltimateButton then
        local CompanionAB8 = g_companionUltimateButton.slot
        uiCompanionUltimate.LabelVal = UI:Label(CompanionAB8, { BOTTOM, TOP, 0, -3 }, nil, { 1, 2 }, ZO_CreateFontString("$(BOLD_FONT)", 16, FONT_STYLE_SOFT_SHADOW_THICK), nil, true)
        uiCompanionUltimate.LabelPct = UI:Label(CompanionAB8, nil, nil, nil, g_ultimateFont, nil, true)
        uiCompanionUltimate.LabelPct:SetAnchor(TOPLEFT, CompanionAB8, nil, 0, 0)
        uiCompanionUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, CompanionAB8, nil, 0, -ActionBar.SV.UltimateLabelPosition)
        uiCompanionUltimate.LabelPct:SetColor(unpack(uiCompanionUltimate.color))
        uiCompanionUltimate.Texture = UI:Texture(CompanionAB8, { CENTER, CENTER }, { 160, 160 }, "/esoui/art/crafting/white_burst.dds", DL_BACKGROUND, true)
    end

    -- Create backbar buttons
    local slotsUpdated = {}
    local settingsReapplied = false

    local function OnSwapAnimationHalfDone(animation, button, isBackBarSlot)
        -- Reset flag at start of new swap animation
        if not next(slotsUpdated) then
            settingsReapplied = false
        end

        for i = BAR_INDEX_START, BAR_INDEX_END do
            if not slotsUpdated[i] then
                local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]
                ActionBar.BarSlotUpdate(i, false, false)
                ActionBar.BarSlotUpdate(i + BACKBAR_INDEX_OFFSET, false, false)
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

    local function OnSwapAnimationDone(animation, button)
        button.noUpdates = false

        if ZO_ActionBar_IsUltimateSlot(button:GetSlot(), button:GetHotbarCategory()) then
            g_activeWeaponSwapInProgress = false
        end

        -- Reapply darken/desaturate settings once after swap animation completes
        if ZO_ActionBar_IsUltimateSlot(button:GetSlot(), button:GetHotbarCategory()) and not settingsReapplied then
            settingsReapplied = true
            ActionBar.BackbarToggleSettings()
        end

        slotsUpdated = {}
    end

    local function SetupSwapAnimation(button)
        button:SetupSwapAnimation(OnSwapAnimationHalfDone, OnSwapAnimationDone)
    end

    local LUIE_Backbar = UI:ControlWithType(ACTION_BAR, nil, nil, false, "LUIE_Backbar", CT_CONTROL)
    LUIE_Backbar:SetParent(ACTION_BAR)

    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = ActionButton:New(i, ACTION_BUTTON_TYPE_VISIBLE, LUIE_Backbar, "ZO_ActionButton", HOTBAR_CATEGORY_BACKUP)
        SetupSwapAnimation(button)
        button:SetupBounceAnimation()
        if button.SetupTimerSwapAnimation then
            button:SetupTimerSwapAnimation()
        end
        if button.SetupKeySlideAnimation and ZO_ActionBar_IsUltimateSlot(button:GetSlot(), button:GetHotbarCategory()) then
            button:SetupKeySlideAnimation()
        end
        button:UpdateState()
        button.button.actionId = GetSlotTrueBoundId(i - 50, HOTBAR_CATEGORY_BACKUP)
        g_backbarButtons[i] = button
    end

    ActionBar.BackbarSetupTemplate()
    ActionBar.BackbarToggleSettings()
    ActionBar.SetCompanionAnchors()
    if not g_platformStyle then
        g_platformStyle = ZO_PlatformStyle:New(ActionBar.BackbarSetupTemplate, KEYBOARD_CONSTANTS, GAMEPAD_CONSTANTS)
    else
        g_platformStyle:Apply()
    end
    ActionBar.UpdateBackbarUniqueState(g_hotbarCategory)
    if g_hotbarCategory == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT then
        ActionBar.ApplyBackbarUniqueHiddenState(true)
    end

    if ActionBar.SV.GlobalShowGCD or ActionBar.SV.BarDesaturateUnused or ActionBar.SV.BarDarkUnused then
        ActionBar.HookGCD()
    end

    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        ActionBar.DisableZOSTimerDisplay()
    end

    ActionBar.HideAbilityDropCallouts()

    -- Register all events based on settings
    ActionBar.RegisterEvents()
end
