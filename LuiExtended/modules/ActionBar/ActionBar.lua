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
local OtherAddonCompatability = LUIE.OtherAddonCompatability

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

local pairs = pairs
local printToChat = LUIE.PrintToChat
local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local GetAbilityDuration = GetAbilityDuration
local timeMs = GetFrameTimeMilliseconds
local zo_strformat = zo_strformat
local string_format = string.format
local eventManager = GetEventManager()
local animationManager = GetAnimationManager()
local GetActionSlotEffectDuration = GetActionSlotEffectDuration
local GetActionSlotEffectTimeRemaining = GetActionSlotEffectTimeRemaining

local moduleName = LUIE.name .. "ActionBar"

-- Action Bar Constants
local ACTION_BAR_META = ZO_ActionBar1
local ACTION_BAR = ACTION_BAR_META
local BAR_INDEX_START = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
local BAR_INDEX_END = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local BACKBAR_INDEX_END = ACTION_BAR_ULTIMATE_SLOT_INDEX
local BACKBAR_INDEX_OFFSET = 50

--- @class LUIE_ACTIONBAR_GAMEPAD_CONSTANTS
local GAMEPAD_CONSTANTS =
{
    abilitySlotOffsetX = 10,
    ultimateSlotOffsetX = 65,
    quickslotOffsetXFromCompanionUltimate = 45,
    quickslotOffsetXFromFirstSlot = 5,
    weaponSwapOffsetX = 61,
    weaponSwapOffsetY = 4,
}

--- @class LUIE_ACTIONBAR_KEYBOARD_CONSTANTS
local KEYBOARD_CONSTANTS =
{
    abilitySlotOffsetX = 2,
    ultimateSlotOffsetX = 62,
    quickslotOffsetXFromCompanionUltimate = 18,
    quickslotOffsetXFromFirstSlot = 5,
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

local function IsPlayerHotbarCategory(hotbarCategory)
    return hotbarCategory ~= nil and PLAYER_HOTBAR_CATEGORIES[hotbarCategory] == true
end

local function IsWeaponSwapHotbarCategory(hotbarCategory)
    return hotbarCategory == HOTBAR_CATEGORY_PRIMARY or hotbarCategory == HOTBAR_CATEGORY_BACKUP
end

local function IsUniqueOverrideHotbarCategory(hotbarCategory)
    return hotbarCategory == HOTBAR_CATEGORY_OVERLOAD
        or hotbarCategory == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT
        or hotbarCategory == HOTBAR_CATEGORY_WEREWOLF
        or hotbarCategory == HOTBAR_CATEGORY_TEMPORARY
end

-- Module-local state
local isFancyActionBarEnabled = OtherAddonCompatability.isFancyActionBarPlusEnabled or LUIE.IsItEnabled("FancyActionBar\43") or LUIE.IsItEnabled("FancyActionBar")
local g_ultimateCost = 0
local g_ultimateCurrent = 0
local g_ultimateSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local g_companionUltimateCost = 0
local g_companionUltimateCurrent = 0
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
local g_barFont
local g_potionFont
local g_ultimateFont
local g_ProcSound
local g_boundArmamentsPlayed = {}
local g_disableProcSound = {}
local g_hotbarCategory = GetActiveHotbarCategory()
local g_actionBarActiveWeaponPair = GetHeldWeaponPair()
--- @type {[integer]:ActionButton}
local g_backbarButtons = {}
local g_activeWeaponSwapInProgress = false
local g_potionUsed = false
local g_backbarUniqueHidden = false
local g_platformStyle
local abilityDropValidators = ZO_ABILITY_DROP_CALLOUT_VALIDITY_FUNCTION_BY_ACTION_TYPE
local MOUSE_CONTENT_ACTION = MOUSE_CONTENT_ACTION
local g_companionUltimateButton = ZO_ActionBar_GetButton(g_ultimateSlot, HOTBAR_CATEGORY_COMPANION)
local g_quickslotButton = ZO_ActionBar_GetButton(QuickslotActionButton:GetSlot(), HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
local g_keybindBG = ACTION_BAR:GetNamedChild("KeybindBG")

local function HideAbilityDropCallouts()
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

local function ShowAbilityDropCallouts(actionType, actionValue)
    if not abilityDropValidators then
        return
    end

    local validator = abilityDropValidators[actionType]
    if not validator then
        return
    end

    HideAbilityDropCallouts()

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

local function RefreshVisibleCooldowns()
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

local function ShouldAnimateWeaponSwap(previousCategory, newCategory)
    return previousCategory ~= newCategory
        and IsWeaponSwapHotbarCategory(previousCategory)
        and IsWeaponSwapHotbarCategory(newCategory)
end

local function ShouldShowCompanionUltimateButton()
    return DoesUnitExist("companion") and HasActiveCompanion()
end

-- Sets companion ultimate button and quickslot positioning based on companion state
function ActionBar.SetCompanionAnchors()
    local IS_QUICKSLOT_ANCHORED_LEFT = true
    if ShouldShowCompanionUltimateButton() then
        g_companionUltimateButton:SetEnabled(true)
        g_keybindBG:SetDimensions(580, 64)
        g_keybindBG:SetAnchor(BOTTOM, nil, nil, -34, 0)
        local xOffset = GetPlatformConstants().quickslotOffsetXFromCompanionUltimate
        g_quickslotButton:ApplyAnchor(ZO_ActionBar_GetButton(ACTION_BAR_ULTIMATE_SLOT_INDEX + 1, HOTBAR_CATEGORY_COMPANION).slot, xOffset, IS_QUICKSLOT_ANCHORED_LEFT)
    else
        g_companionUltimateButton:SetEnabled(false)
        g_keybindBG:SetDimensions(512, 64)
        g_keybindBG:SetAnchor(BOTTOM, nil, nil, 0, 0)
        local xOffset = GetPlatformConstants().quickslotOffsetXFromFirstSlot
        g_quickslotButton:ApplyAnchor(ZO_ActionBar1WeaponSwap, xOffset, IS_QUICKSLOT_ANCHORED_LEFT)
    end
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

local function ApplyBackbarUniqueHiddenState(hidden)
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")
    local needsUpdate = hidden ~= g_backbarUniqueHidden

    if weaponSwapControl and weaponSwapControl.permanentlyHidden ~= hidden then
        needsUpdate = true
        ZO_WeaponSwap_SetPermanentlyHidden(weaponSwapControl, hidden)
        -- LUIE.Debug("ActionBar: WeaponSwap permanent hidden -> " .. tostring(hidden))
    end

    if not needsUpdate then
        return
    end

    g_backbarUniqueHidden = hidden
    -- LUIE.Debug(string_format("ActionBar: ApplyBackbarUniqueHiddenState hidden=%s", tostring(hidden)))

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

local function UpdateBackbarUniqueState(activeHotbarCategory)
    -- LUIE.Debug(string_format("ActionBar: UpdateBackbarUniqueState category=%s unique=%s", tostring(activeHotbarCategory), tostring(IsUniqueOverrideHotbarCategory(activeHotbarCategory))))
    ApplyBackbarUniqueHiddenState(IsUniqueOverrideHotbarCategory(activeHotbarCategory))
end

-- QuickSlot
local uiQuickSlot =
{
    color = { 0.941, 0.565, 0.251, 1 },
    timeColors =
    {
        [1] = { remain = 15000, color = { 0.878, 0.941, 0.251, 1 } },
        [2] = { remain = 5000, color = { 0.251, 0.941, 0.125, 1 } },
    },
}

-- Ultimate slot
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

-- Companion Ultimate slot
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

-- Cooldown Animation Types for GCD Tracking
local CooldownMethod =
{
    [1] = CD_TYPE_RADIAL,
    [2] = CD_TYPE_VERTICAL_REVEAL,
}

-- ===== HELPER FUNCTIONS =====

-- Update actionId for backbar buttons
local function UpdateBackbarButtonActionIds()
    local inactiveHotbarCategory = GetInactiveHotbarCategory(g_hotbarCategory)
    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = g_backbarButtons[i]
        if button and button.button then
            button.button.actionId = GetSlotTrueBoundId(i - BACKBAR_INDEX_OFFSET, inactiveHotbarCategory)
        end
    end
end

-- Helper function to get override ability duration
---
--- @param abilityId number
--- @param overrideRank number?
--- @param casterUnitTag string?
--- @return integer duration
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

--- Sets bar remain label based on ability type
--- @param remain number Remaining time in milliseconds
--- @param abilityId number Ability ID
--- @return string Formatted label text
local function SetBarRemainLabel(remain, abilityId)
    if Effects.IsGrimFocus[abilityId] or Effects.IsBloodFrenzy[abilityId] then
        return ""
    else
        return FormatDurationSeconds(remain)
    end
end

--- Gets corrected ability ID based on weapon type and special cases
--- @param abilityId integer Original ability ID
--- @param hotbarCategory number Hotbar category
--- @return integer Corrected ability ID
local function GetCorrectedAbilityId(abilityId, hotbarCategory)
    local correctedAbilityId = abilityId
    local BarHighlightDestroFix = Effects.BarHighlightDestroFix

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

-- ===== PUBLIC FUNCTIONS =====

-- Force enable default action bar timers to get EVENT_ACTION_SLOT_EFFECT_UPDATE data
function ActionBar.SetActionBarTimersEnabled()
    if tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS)) == 0 then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_SHOW_ACTION_BAR_TIMERS, "true")
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

-- Handle default action slot effect updates to get duration data
function ActionBar.OnActionSlotEffectUpdated(eventCode, hotbarCategory, actionSlotIndex)
    if not IsPlayerHotbarCategory(hotbarCategory) then
        -- LUIE.Debug(string_format("ActionBar: OnActionSlotEffectUpdated ignored hotbar=%s slot=%s", tostring(hotbarCategory), tostring(actionSlotIndex)))
        ApplyBackbarUniqueHiddenState(IsUniqueOverrideHotbarCategory(hotbarCategory))
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

            local frontSlot = g_toggledSlotsFront[abilityId]
            local backSlot = g_toggledSlotsBack[abilityId]

            if frontSlot and g_uiCustomToggle[frontSlot] then
                ActionBar.ShowSlot(frontSlot, abilityId, timeMs(), false)
            end
            if backSlot and g_uiCustomToggle[backSlot] then
                ActionBar.ShowSlot(backSlot, abilityId, timeMs(), false)
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

            -- Only learn duration if not already overridden and not hardcoded in database
            if not g_barDurationOverride[abilityId] and not (Effects.BarHighlightOverride[abilityId] and Effects.BarHighlightOverride[abilityId].duration) then
                g_barDurationOverride[abilityId] = duration
                -- LUIE.Debug(string_format("ActionBar: Learned duration %d ms for ability %d (%s)", duration, abilityId, abilityName))
            end
        end
    end
end

-- Duration Override Management Functions

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
    if IsPlayerHotbarCategory(hotbarCategory) then
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

--- Handles active weapon pair changes
--- @param eventCode integer
--- @param activeWeaponPair ActiveWeaponPair
function ActionBar.OnActiveWeaponPairChanged(eventCode, activeWeaponPair)
    if activeWeaponPair ~= g_actionBarActiveWeaponPair then
        g_activeWeaponSwapInProgress = true
        -- LUIE.Debug(string_format("ActionBar: OnActiveWeaponPairChanged event=%s pair=%s", tostring(eventCode), tostring(activeWeaponPair)))
        local currentHotbarCategory = GetActiveHotbarCategory()
        UpdateBackbarUniqueState(currentHotbarCategory)
        g_actionBarActiveWeaponPair = GetHeldWeaponPair()
        UpdateBackbarButtonActionIds()
    end
end

--- @param eventCode integer
--- @param actionBarLockedReason ActionBarLockedReason
function ActionBar.OnActionBarLockedReasonChanged(eventCode, actionBarLockedReason)
    -- LUIE.Debug(string_format("ActionBar: OnActionBarLockedReasonChanged reason=%s", tostring(actionBarLockedReason)))
    local currentHotbarCategory = GetActiveHotbarCategory()
    if IsPlayerHotbarCategory(currentHotbarCategory) then
        UpdateBackbarUniqueState(currentHotbarCategory)
        if g_activeWeaponSwapInProgress then
            return
        end
        ActionBar.UpdateAllSlotsForActiveHotbar(false)
    else
        ApplyBackbarUniqueHiddenState(IsUniqueOverrideHotbarCategory(currentHotbarCategory))
    end
end

--- @param eventCode integer
--- @param isRepeccableBarState boolean
function ActionBar.OnActionBarIsRespeccableBarStateChanged(eventCode, isRepeccableBarState)
    -- LUIE.Debug(string_format("ActionBar: OnActionBarIsRespeccableBarStateChanged isRepeccable=%s", tostring(isRepeccableBarState)))
    local currentHotbarCategory = GetActiveHotbarCategory()
    if IsPlayerHotbarCategory(currentHotbarCategory) then
        UpdateBackbarUniqueState(currentHotbarCategory)
        if g_activeWeaponSwapInProgress then
            return
        end
        ActionBar.UpdateAllSlotsForActiveHotbar(false)
    else
        ApplyBackbarUniqueHiddenState(IsUniqueOverrideHotbarCategory(currentHotbarCategory))
    end
end

--- @param eventCode integer
--- @param artifactId integer?
function ActionBar.OnActiveDaedricArtifactChanged(eventCode, artifactId)
    -- LUIE.Debug(string_format("ActionBar: OnActiveDaedricArtifactChanged artifactId=%s", tostring(artifactId)))
    if artifactId ~= nil then
        ApplyBackbarUniqueHiddenState(true)
    else
        ApplyBackbarUniqueHiddenState(false)
    end

    local currentHotbarCategory = GetActiveHotbarCategory()
    if IsPlayerHotbarCategory(currentHotbarCategory) then
        UpdateBackbarUniqueState(currentHotbarCategory)
        if g_activeWeaponSwapInProgress and not IsUniqueOverrideHotbarCategory(currentHotbarCategory) then
            return
        end
        ActionBar.UpdateAllSlotsForActiveHotbar(true)
    else
        ApplyBackbarUniqueHiddenState(IsUniqueOverrideHotbarCategory(currentHotbarCategory))
    end
end

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

        --- @diagnostic disable-next-line: duplicate-set-field
        function ActionButton:UpdateCooldown(options)
            local slotNum = self:GetSlot()
            local hotbarCategory = self:GetHotbarCategory()
            local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotNum, hotbarCategory)
            local isInCooldown = duration > 0
            local slotType = GetSlotType(slotNum, hotbarCategory)
            local showGlobalCooldownForCollectible = global and slotType == ACTION_TYPE_COLLECTIBLE and globalSlotType == ACTION_TYPE_COLLECTIBLE
            local showCooldown = isInCooldown and (ActionBar.SV.GlobalShowGCD or not global or showGlobalCooldownForCollectible)
            local updateChromaQuickslot = (slotType ~= ACTION_TYPE_ABILITY and slotType ~= ACTION_TYPE_CRAFTED_ABILITY) and ZO_RZCHROMA_EFFECTS
            -- Only show cooldown for non-consumables, or consumables with duration > 1s, or if GlobalPotion is enabled
            local shouldShowCooldown = showCooldown and (not IsSlotItemConsumable(slotNum, hotbarCategory) or duration > 1000 or ActionBar.SV.GlobalPotion)

            if showCooldown then
                local cooldownType = CooldownMethod[ActionBar.SV.GlobalMethod] or CD_TYPE_RADIAL
                -- Reset cooldown before starting to ensure clean state
                if not self.showingCooldown then
                    self.cooldown:ResetCooldown()
                end
                if cooldownType == CD_TYPE_VERTICAL_REVEAL then
                    -- CD_TYPE_VERTICAL_REVEAL requires leading edge setup (matching ZOS implementation)
                    self.cooldown:SetVerticalCooldownLeadingEdgeHeight(4)
                    self.cooldown:StartCooldown(remain, duration, cooldownType, nil, true)
                else
                    -- CD_TYPE_RADIAL uses drawLeadingEdge = false
                    self.cooldown:StartCooldown(remain, duration, cooldownType, nil, false)
                end

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
                    self.cooldown:SetHidden(not shouldShowCooldown)
                end

                self.slot:SetHandler("OnUpdate", function () self:RefreshCooldown() end, "CooldownUpdate")

                if updateChromaQuickslot then
                    ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect("ACTION_BUTTON_9")
                end
            else
                if ActionBar.SV.GlobalFlash then
                    if self.showingCooldown then
                        if not IsSlotItemConsumable(slotNum, hotbarCategory) or duration > 1000 or ActionBar.SV.GlobalPotion then
                            if options ~= FORCE_SUPPRESS_COOLDOWN_SOUND then
                                PlaySound(SOUNDS.ABILITY_READY)
                            end

                            self.cooldownCompleteAnim.animation = self.cooldownCompleteAnim.animation or CreateSimpleAnimation(ANIMATION_TEXTURE, self.cooldownCompleteAnim)
                            local anim = self.cooldownCompleteAnim.animation

                            self.cooldownCompleteAnim:SetHidden(false)
                            self.cooldown:SetHidden(false)

                            anim:SetImageData(16, 1)
                            anim:SetFramerate(30)
                            anim:GetTimeline():PlayFromStart()

                            if updateChromaQuickslot then
                                ZO_RZCHROMA_EFFECTS:AddKeybindActionEffect("ACTION_BUTTON_9")
                            end
                        end
                    end

                    self.icon.percentComplete = 1
                    self.slot:SetHandler("OnUpdate", nil, "CooldownUpdate")
                    self.cooldown:ResetCooldown()
                end

                if showCooldown ~= self.showingCooldown then
                    self:SetShowCooldown(showCooldown)
                    self:UpdateActivationHighlight()

                    if IsInGamepadPreferredMode() then
                        self:SetCooldownPercentComplete(self.icon.percentComplete)
                    end
                end
            end

            local shouldDesaturate = showCooldown or self.itemQtyFailure
            -- For backbar buttons, don't override desaturation if BarDesaturateUnused is enabled
            -- The desaturation is handled by ToggleBackbarSaturation instead
            if not (self:GetHotbarCategory() == HOTBAR_CATEGORY_BACKUP and ActionBar.SV.BarDesaturateUnused) then
                self.icon:SetDesaturation(shouldDesaturate and 1 or 0)
            end

            local textColor = showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED
            self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))

            self.isGlobalCooldown = global
            self:UpdateUsable()
        end
    end
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
        eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, ActionBar.EventHandlers.OnCombatEventBar)
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

    -- Notify EventHandlers to refresh their cached reference
    if ActionBar.EventHandlers and ActionBar.EventHandlers.RefreshCachedReferences then
        ActionBar.EventHandlers.RefreshCachedReferences()
    end

    -- Process bar highlight overrides if enabled
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        for abilityId, value in pairs(Effects.BarHighlightOverride) do
            ProcessBarHighlightOverride(abilityId, value)
        end
        RegisterBarCombatEvents()
    end
end

-- Helper to setup label anchors for a button
local function SetupLabelAnchors(label, buttonSlot)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, buttonSlot)
    label:SetAnchor(BOTTOMRIGHT, buttonSlot, nil, 0, -ActionBar.SV.BarLabelPosition)
end

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
        ResetButtonLabel(backIndex, actionButtonBB.slot)
    end
end

-- Generic helper to reset label anchors
local function ResetLabelAnchors(label, parent, positionOffset)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, parent)
    label:SetAnchor(BOTTOMRIGHT, parent, nil, 0, -positionOffset)
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

--- Handles slot updated event
--- @param eventCode integer
--- @param slotNum integer
function ActionBar.OnSlotUpdated(eventCode, slotNum)
    if slotNum == 8 then
        ActionBar.UpdateUltimateLabel()
        ActionBar.UpdateCompanionUltimateLabel()
    end
end

-- Helper to check if slot update should be skipped
local function ShouldSkipSlotUpdate(slotNum)
    if not IsPlayerHotbarCategory(g_hotbarCategory) then
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
function ActionBar.GetSlotAbilityId(slotNum)
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

    -- Apply overrides
    if Effects.BarHighlightOverride[ability_id] then
        if Effects.BarHighlightOverride[ability_id].hide then
            return nil
        end
        if Effects.BarHighlightOverride[ability_id].newId then
            ability_id = Effects.BarHighlightOverride[ability_id].newId
        end
    end

    return ability_id
end

-- Helper to setup fake aura for ability
local function SetupFakeAura(ability_id)
    if not g_barFakeAura[ability_id] then
        g_barFakeAura[ability_id] = true
        g_barOverrideCI[ability_id] = true

        -- Only set hardcoded duration if not already overridden (by user custom override or learned duration)
        if Effects.BarHighlightOverride[ability_id] and Effects.BarHighlightOverride[ability_id].duration and not g_barDurationOverride[ability_id] then
            g_barDurationOverride[ability_id] = Effects.BarHighlightOverride[ability_id].duration
        end
    end
end

-- Helper to process proc effects for a slot
local function ProcessProcEffects(slotNum, ability_id, abilityName, currentTimeMs)
    local triggeredSlots = slotNum > BACKBAR_INDEX_OFFSET and g_triggeredSlotsBack or g_triggeredSlotsFront
    local proc = Effects.HasAbilityProc[abilityName]

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

    if duration > 0 or Effects.AddNoDurationBarHighlight[ability_id] or Effects.IsGrimFocus[ability_id] or Effects.IsBloodFrenzy[ability_id] or Effects.MajorMinor[ability_id] then
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

---
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

    local showFakeAura = (Effects.BarHighlightOverride[ability_id] and Effects.BarHighlightOverride[ability_id].showFakeAura)
    if showFakeAura then
        SetupFakeAura(ability_id)
    end

    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(ability_id))
    local abilityName = Effects.EffectOverride[ability_id] and Effects.EffectOverride[ability_id].name or cachedName
    local duration = GetUpdatedAbilityDuration(ability_id) or 0
    local currentTimeMs = timeMs()

    ProcessProcEffects(slotNum, ability_id, abilityName, currentTimeMs)

    if onlyProc == false then
        ProcessToggledEffects(slotNum, ability_id, duration, currentTimeMs)
    end
end

---
function ActionBar.UpdateUltimateLabel()
    if not IsPlayerHotbarCategory(g_hotbarCategory) then
        return
    end
    local bar = g_hotbarCategory
    g_ultimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, bar) or 0

    local current, max, effectiveMax = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    g_ultimateCurrent = current or 0

    ActionBar.OnPowerUpdatePlayer(EVENT_POWER_UPDATE, "player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_ultimateCurrent, max or 0, effectiveMax or 0)
end

---
function ActionBar.UpdateCompanionUltimateLabel()
    if not ShouldShowCompanionUltimateButton() then
        return
    end
    g_companionUltimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, HOTBAR_CATEGORY_COMPANION) or 0

    local current, max, effectiveMax = GetUnitPower("companion", COMBAT_MECHANIC_FLAGS_ULTIMATE)
    g_companionUltimateCurrent = current or 0

    ActionBar.OnPowerUpdateCompanion(EVENT_POWER_UPDATE, "companion", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_companionUltimateCurrent, max or 0, effectiveMax or 0)
end

---
function ActionBar.InventoryItemUsed()
    g_potionUsed = true
    zo_callLater(function ()
                     g_potionUsed = false
                 end, 200)
end

---
--- @param didActiveHotbarChange boolean
function ActionBar.UpdateAllSlotsForActiveHotbar(didActiveHotbarChange)
    local previousCategory = g_hotbarCategory
    local activeHotbarCategory = GetActiveHotbarCategory()
    -- LUIE.Debug(string_format("ActionBar: UpdateAllSlotsForActiveHotbar prev=%s current=%s didChange=%s", tostring(previousCategory), tostring(activeHotbarCategory), tostring(didActiveHotbarChange)))

    if not IsPlayerHotbarCategory(activeHotbarCategory) then
        ApplyBackbarUniqueHiddenState(true)
        return
    end

    g_hotbarCategory = activeHotbarCategory
    UpdateBackbarUniqueState(activeHotbarCategory)

    local shouldAnimate = didActiveHotbarChange and (g_activeWeaponSwapInProgress or ShouldAnimateWeaponSwap(previousCategory, activeHotbarCategory))
    -- LUIE.Debug(string_format("ActionBar: UpdateAllSlotsForActiveHotbar shouldAnimate=%s g_activeWeaponSwapInProgress=%s", tostring(shouldAnimate), tostring(g_activeWeaponSwapInProgress)))
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
        -- LUIE.Debug("ActionBar: Swap in progress, skipping redundant full update")
        return
    end

    if not shouldAnimate then
        if g_activeWeaponSwapInProgress then
            -- LUIE.Debug("ActionBar: Swap flagged but not animating, forcing full update")
        end
        ActionBar.OnSlotsFullUpdate()
    end
end

-- Used to populate abilities icons after the user has logged on
function ActionBar.OnPlayerActivated(eventCode)
    -- Enable action bar timers if needed
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        if not IsConsoleUI() then
            ActionBar.SetActionBarTimersEnabled()
        end
    end

    -- Update all slots
    ActionBar.OnSlotsFullUpdate()

    -- Update backbar slots
    for i = 53, 57 do
        ActionBar.BarSlotUpdate(i, true, false)
    end

    -- Update ultimate labels
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        ActionBar.UpdateUltimateLabel()
        ActionBar.UpdateCompanionUltimateLabel()
    end

    eventManager:UnregisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED)
end

---
function ActionBar.OnSlotsFullUpdate()
    g_activeWeaponSwapInProgress = false
    -- LUIE.Debug("ActionBar: OnSlotsFullUpdate")
    UpdateBackbarUniqueState(g_hotbarCategory)
    if not IsPlayerHotbarCategory(g_hotbarCategory) then
        return
    end
    if g_potionUsed == true then
        return
    end

    ActionBar.UpdateUltimateLabel()

    for i = BAR_INDEX_START, BAR_INDEX_END do
        -- LUIE.Debug(string_format("ActionBar: OnSlotsFullUpdate main slot %d", i))
        ActionBar.BarSlotUpdate(i, true, false)
    end

    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        local button = g_backbarButtons[i]
        ActionBar.SetupBackBarIcons(button, true)
        -- LUIE.Debug(string_format("ActionBar: OnSlotsFullUpdate back slot %d", i))
        ActionBar.BarSlotUpdate(i, true, false)
    end

    -- Ensure backbar desaturation is applied after slot updates
    ActionBar.BackbarToggleSettings()
end

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
    label:SetColor(unpack(uiQuickSlot.color or { 1, 1, 1, 1 }))
    label:SetHidden(false)
    procLoopTexture.label = label
end

-- Helper to create the animation timeline with handlers
local function CreateProcAnimationTimeline(procLoopTexture)
    local procLoopTimeline = animationManager:CreateTimelineFromVirtual("UltimateReadyLoop", procLoopTexture)
    procLoopTimeline.procLoopTexture = procLoopTexture

    procLoopTimeline.onPlay = function (self)
        self.procLoopTexture:SetHidden(false)
    end
    procLoopTimeline.onStop = function (self)
        self.procLoopTexture:SetHidden(true)
    end

    procLoopTimeline:SetHandler("OnPlay", procLoopTimeline.onPlay)
    procLoopTimeline:SetHandler("OnStop", procLoopTimeline.onStop)

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

---
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

---
--- @param eventCode integer
--- @param unitTag string
--- @param isDead boolean
function ActionBar.OnDeath(eventCode, unitTag, isDead)
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

-- Helper to create the toggle texture frame
local function CreateToggleTexture(actionButton)
    local toggleFrame = UI:ControlWithType(actionButton.slot, "fill", nil, false, "$(parent)Toggle_LUIE", CT_TEXTURE)
    toggleFrame:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
    toggleFrame:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
    toggleFrame:SetTexture("/esoui/art/actionbar/actionslot_toggledon.dds")
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
    label:SetColor(unpack(ActionBar.SV.RemainingTextColoured and uiQuickSlot.color or { 1, 1, 1, 1 }))
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
    stack:SetColor(unpack(ActionBar.SV.RemainingTextColoured and uiQuickSlot.color or { 1, 1, 1, 1 }))
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
---
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

-- Helper to calculate ultimate percentage
local function CalculateUltimatePercentage(powerValue)
    local pct = (g_ultimateCost > 0) and zo_floor((powerValue / g_ultimateCost) * 100) or 0
    return pct > 100 and 100 or pct
end

-- Helper to update label text content
local function UpdateUltimateLabelText(pct, powerValue)
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
local function ApplyUltimateLabelColor(pct)
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
local function UpdateUltimateLabelVisibility(pct)
    local hidePctLabel = ShouldHidePercentageLabel(pct)
    local hideValLabel = not ActionBar.SV.UltimateLabelEnabled

    uiUltimate.LabelPct:SetHidden(hidePctLabel)
    uiUltimate.LabelVal:SetHidden(hideValLabel)
end

--- Runs on the `EVENT_POWER_UPDATE` handler
--- @param eventCode integer
--- @param unitTag string
--- @param powerIndex luaindex
--- @param powerType CombatMechanicFlags
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
function ActionBar.OnPowerUpdatePlayer(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    uiUltimate.NotFull = (powerValue < powerMax)

    if not IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
        g_ultimateCurrent = powerValue
        return
    end

    local pct = CalculateUltimatePercentage(powerValue)

    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        UpdateUltimateLabelText(pct, powerValue)
        ApplyUltimateLabelColor(pct)
        UpdateUltimateLabelVisibility(pct)
    else
        -- Hide labels when both settings are disabled
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
    end

    g_ultimateCurrent = powerValue
end

--- Runs on the `EVENT_POWER_UPDATE` handler for companion
--- @param eventCode integer
--- @param unitTag string
--- @param powerIndex luaindex
--- @param powerType CombatMechanicFlags
--- @param powerValue integer
--- @param powerMax integer
--- @param powerEffectiveMax integer
function ActionBar.OnPowerUpdateCompanion(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    uiCompanionUltimate.NotFull = (powerValue < powerMax)

    if not ShouldShowCompanionUltimateButton() then
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

--- Runs on the `EVENT_INVENTORY_SINGLE_SLOT_UPDATE` handler
--- @param eventCode integer
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
function ActionBar.OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    if stackCountChange >= 0 then
        ActionBar.UpdateUltimateLabel()
        if ShouldShowCompanionUltimateButton() then
            ActionBar.UpdateCompanionUltimateLabel()
        end
    end
end

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
    elseif g_mineStacks[abilityId] and g_mineStacks[abilityId] > 0 and not Effects.HideGroundMineStacks[abilityId] then
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
    -- The second parameter controls darkening (unusable state), third parameter controls desaturation via this function
    if ActionBar.SV.BarDarkUnused then
        -- Darken all backbar buttons when BarDarkUnused is enabled
        -- Don't let ZO_ActionSlot_SetUnusable handle desaturation (third param = false)
        -- We handle desaturation separately below
        ZO_ActionSlot_SetUnusable(button.icon, true, false)
    else
        -- Clear darkening if BarDarkUnused is disabled
        ZO_ActionSlot_SetUnusable(button.icon, false, false)
    end

    -- Handle desaturation
    -- Explicit desaturate parameter (false) can override BarDesaturateUnused to show active toggles normally
    if desaturate == false then
        -- Explicitly don't desaturate (e.g., for active toggle effects)
        button.icon:SetDesaturation(0)
    elseif ActionBar.SV.BarDesaturateUnused then
        -- Always desaturate backbar buttons when the setting is enabled (unless explicitly overridden above)
        button.icon:SetDesaturation(1)
    elseif desaturate == true then
        -- Explicitly desaturate (e.g., for cooldowns)
        button.icon:SetDesaturation(1)
    else
        -- Default (nil): desaturate backbar buttons (inactive bar)
        button.icon:SetDesaturation(1)
    end
end

-- Helper to setup weapon swap control positioning
local function SetupWeaponSwapControl(style)
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")
    if not weaponSwapControl then
        return
    end

    weaponSwapControl:ClearAnchors()
    weaponSwapControl:SetAnchor(TOPLEFT, nil, TOPLEFT, style.weaponSwapOffsetX, style.weaponSwapOffsetY)
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
local function SetupBackbarButtons(style)
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
local function PositionUltimateBackbarButton(style)
    local isGamepadStyle = style == GAMEPAD_CONSTANTS
    local offsetY = isGamepadStyle and (ACTION_BAR:GetHeight() * 1.6) or ACTION_BAR:GetHeight()

    local ActionButton53 = GetControl("ActionButton53")
    local AB3 = _G["ActionButton3"]

    ActionButton53:ClearAnchors()
    ActionButton53:SetAnchor(CENTER, AB3, CENTER, 0, -(offsetY * 0.8))
end

function ActionBar.BackbarSetupTemplate(style)
    -- Validate that style is a valid constants table, not a number or other invalid type
    if not style or type(style) ~= "table" or not style.weaponSwapOffsetX then
        style = GetPlatformConstants()
    end

    SetupWeaponSwapControl(style)
    UpdateBackbarUniqueState(g_hotbarCategory)
    SetupBackbarButtons(style)
    PositionUltimateBackbarButton(style)
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
        -- ToggleBackbarSaturation handles both BarDarkUnused and BarDesaturateUnused
        -- If slot has active toggle, preserve its non-desaturated state (desaturate = false)
        -- Otherwise apply base settings (desaturate = nil)
        ActionBar.ToggleBackbarSaturation(slotNum, hasActiveToggle and false or nil)

        if ActionBar.SV.BarHideUnused or not ActionBar.SV.BarShowBack or g_backbarUniqueHidden then
            targetButton.slot:SetHidden(true)
        end
    end
end

-- Public handlers for event registration
function ActionBar.HandleActionUpdateCooldowns()
    RefreshVisibleCooldowns()
end

function ActionBar.HandleCursorPickup(_, cursorType, actionType, _, slotIndex)
    if cursorType == MOUSE_CONTENT_ACTION and abilityDropValidators and abilityDropValidators[actionType] then
        ShowAbilityDropCallouts(actionType, slotIndex)
    end
end

function ActionBar.HandleCursorDropped(_, cursorType)
    if cursorType == MOUSE_CONTENT_ACTION then
        HideAbilityDropCallouts()
    end
end

-- Main ticker update for action bar
function ActionBar.OnUpdate(currentTimeMs)
    -- Procs
    for k, v in pairs(g_triggeredSlotsRemain) do
        local remain = v - currentTimeMs
        local front = g_triggeredSlotsFront[k]
        local back = g_triggeredSlotsBack[k]
        local frontAnim = front and g_uiProcAnimation[front]
        local backAnim = back and g_uiProcAnimation[back]
        if v < currentTimeMs then
            if frontAnim then
                frontAnim:Stop()
            end
            if backAnim then
                backAnim:Stop()
            end
            g_triggeredSlotsRemain[k] = nil
        end
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
        local remain = v - currentTimeMs
        local front = g_toggledSlotsFront[k]
        local back = g_toggledSlotsBack[k]
        local frontToggle = front and g_uiCustomToggle[front]
        local backToggle = back and g_uiCustomToggle[back]
        if v < currentTimeMs then
            if frontToggle then
                ActionBar.HideSlot(front, k)
            end
            if backToggle then
                ActionBar.HideSlot(back, k)
            end
            g_toggledSlotsRemain[k] = nil
            g_toggledSlotsStack[k] = nil
        end
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
        local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local label = uiQuickSlot.label
        local timeColors = uiQuickSlot.timeColors
        if duration > 1000 then
            label:SetHidden(false)
            if not ActionBar.SV.PotionTimerColor then
                label:SetColor(1, 1, 1, 1)
            else
                local color = uiQuickSlot.color
                for i = #timeColors, 1, -1 do
                    if remain < timeColors[i].remain then
                        color = timeColors[i].color
                        break
                    end
                end
                label:SetColor(unpack(color))
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
        if not uiUltimate.Texture:IsHidden() and uiUltimate.FadeTime < currentTimeMs then
            uiUltimate.Texture:SetHidden(true)
        end
    end

    -- Update cast bar
    if ActionBar.SV.CastBarEnable and ActionBar.CastBar and ActionBar.CastBar.OnUpdate then
        ActionBar.CastBar.OnUpdate(currentTimeMs)
    end
end

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

    if ActionBar.SV.GlobalShowGCD or ActionBar.SV.BarDesaturateUnused or ActionBar.SV.BarDarkUnused then
        ActionBar.HookGCD()
    end
    -- Setup fonts from ActionBar.SV
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
    if ActionBar.SV.PotionTimerColor then
        uiQuickSlot.label:SetColor(unpack(uiQuickSlot.color))
    else
        uiQuickSlot.label:SetColor(1, 1, 1, 1)
    end
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
    do
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
                    -- LUIE.Debug(string_format("ActionBar: OnSwapAnimationHalfDone updating slot %d", i))
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
            -- LUIE.Debug("ActionBar: OnSwapAnimationDone for slot " .. tostring(button:GetSlot()))

            if ZO_ActionBar_IsUltimateSlot(button:GetSlot(), button:GetHotbarCategory()) then
                g_activeWeaponSwapInProgress = false
                -- LUIE.Debug("ActionBar: Swap animation complete, clearing g_activeWeaponSwapInProgress")
            end

            -- Reapply darken/desaturate settings once after swap animation completes
            -- Use ultimate slot completion as the trigger since it's typically the last to animate
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
    end

    -- Migrate old GlobalMethod values (1=Vertical, 2=Radial, 3=Vertical Reveal) to new values (1=Radial, 2=Vertical Reveal)
    if ActionBar.SV.GlobalMethod == 1 then
        -- Old "Vertical" option -> migrate to "Vertical Reveal" (2)
        ActionBar.SV.GlobalMethod = 2
    elseif ActionBar.SV.GlobalMethod == 2 then
        -- Old "Radial" option -> stays as "Radial" (1)
        ActionBar.SV.GlobalMethod = 1
    elseif ActionBar.SV.GlobalMethod == 3 then
        -- Old "Vertical Reveal" option -> becomes "Vertical Reveal" (2)
        ActionBar.SV.GlobalMethod = 2
    end

    ActionBar.BackbarSetupTemplate()
    ActionBar.BackbarToggleSettings()
    ActionBar.SetCompanionAnchors()
    if not g_platformStyle then
        g_platformStyle = ZO_PlatformStyle:New(ActionBar.BackbarSetupTemplate, KEYBOARD_CONSTANTS, GAMEPAD_CONSTANTS)
    else
        g_platformStyle:Apply()
    end
    UpdateBackbarUniqueState(g_hotbarCategory)
    if g_hotbarCategory == HOTBAR_CATEGORY_DAEDRIC_ARTIFACT then
        ApplyBackbarUniqueHiddenState(true)
    end

    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        ActionBar.DisableZOSTimerDisplay()
    end

    HideAbilityDropCallouts()

    -- Register all events based on settings (handled in ActionBarManager.lua)
    ActionBar.RegisterEvents()
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

-- Export state for ActionBar main module to access
ActionBar.GetTriggeredSlotsRemain = function () return g_triggeredSlotsRemain end
ActionBar.GetTriggeredSlotsFront = function () return g_triggeredSlotsFront end
ActionBar.GetTriggeredSlotsBack = function () return g_triggeredSlotsBack end
ActionBar.GetToggledSlotsRemain = function () return g_toggledSlotsRemain end
ActionBar.GetToggledSlotsPlayer = function () return g_toggledSlotsPlayer end
ActionBar.GetToggledSlotsFront = function () return g_toggledSlotsFront end
ActionBar.GetToggledSlotsBack = function () return g_toggledSlotsBack end
ActionBar.GetToggledSlotsStack = function () return g_toggledSlotsStack end
ActionBar.GetBarNoRemove = function () return g_barNoRemove end
ActionBar.GetBarDurationOverride = function () return g_barDurationOverride end
ActionBar.GetBarFakeAura = function () return g_barFakeAura end
ActionBar.GetProtectAbilityRemoval = function () return g_protectAbilityRemoval end
ActionBar.GetMineStacks = function () return g_mineStacks end
ActionBar.GetMineNoTurnOff = function () return g_mineNoTurnOff end
ActionBar.GetUiCustomToggle = function () return g_uiCustomToggle end
ActionBar.GetUltimateState = function () return uiUltimate end
ActionBar.GetCompanionUltimateState = function () return uiCompanionUltimate end
ActionBar.GetProcSound = function () return g_ProcSound end
ActionBar.GetBoundArmamentsPlayed = function () return g_boundArmamentsPlayed end
ActionBar.SetBoundArmamentsPlayed = function (value) g_boundArmamentsPlayed = value end

-- Custom list management functions (for CastBar blacklist)
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
