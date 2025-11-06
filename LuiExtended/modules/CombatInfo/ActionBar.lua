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

--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo

--- @class (partial) ActionBar
local ActionBar = {}
ActionBar.__index = ActionBar
CombatInfo.ActionBar = ActionBar

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

local moduleName = LUIE.name .. "CombatInfo"

-- Action Bar Constants
local ACTION_BAR_META = ZO_ActionBar1
local ACTION_BAR = ACTION_BAR_META
local BAR_INDEX_START = ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + 1
local BAR_INDEX_END = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
local BACKBAR_INDEX_END = ACTION_BAR_ULTIMATE_SLOT_INDEX
local BACKBAR_INDEX_OFFSET = 50

local GAMEPAD_CONSTANTS =
{
    abilitySlotOffsetX = 10,
    ultimateSlotOffsetX = 65,
}
local KEYBOARD_CONSTANTS =
{
    abilitySlotOffsetX = 2,
    ultimateSlotOffsetX = 62,
}

-- Module-local state
local isFancyActionBarEnabled = OtherAddonCompatability.isFancyActionBarPlusEnabled or LUIE.IsItEnabled("FancyActionBar\43") or LUIE.IsItEnabled("FancyActionBar")
local g_ultimateCost = 0
local g_ultimateCurrent = 0
local g_ultimateSlot = ACTION_BAR_ULTIMATE_SLOT_INDEX + 1
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

-- Cooldown Animation Types for GCD Tracking
local CooldownMethod =
{
    [1] = CD_TYPE_VERTICAL,
    [2] = CD_TYPE_RADIAL,
    [3] = CD_TYPE_VERTICAL_REVEAL,
}

-- ===== HELPER FUNCTIONS =====

-- Update actionId for backbar buttons
local function UpdateBackbarButtonActionIds()
    for i = BAR_INDEX_START + BACKBAR_INDEX_OFFSET, BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET do
        local button = g_backbarButtons[i]
        if button and button.button then
            button.button.actionId = GetSlotTrueBoundId(i - BACKBAR_INDEX_OFFSET, HOTBAR_CATEGORY_BACKUP)
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
    return string_format((CombatInfo.SV.BarMillis and ((remain < CombatInfo.SV.BarMillisThreshold * 1000) or CombatInfo.SV.BarMillisAboveTen)) and "%.1f" or "%.1d", remain / 1000)
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
    if hotbarCategory ~= HOTBAR_CATEGORY_PRIMARY and hotbarCategory ~= HOTBAR_CATEGORY_BACKUP then
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
            if CombatInfo.SV.ShowToggled then
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

            if not g_barDurationOverride[abilityId] then
                g_barDurationOverride[abilityId] = duration
                local abilityName = GetAbilityName(abilityId) or "Unknown"
                LUIE.Debug(string_format("CombatInfo: Learned duration %d ms for ability %d (%s)", duration, abilityId, abilityName))
            end
        end
    end
end

-- Duration Override Management Functions

function ActionBar.GetTrackedAbilitiesForOverride()
    local abilities = {}
    local choices = {}
    local choicesValues = {}

    for abilityId, duration in pairs(CombatInfo.SV.durationOverrides) do
        if not abilities[abilityId] then
            abilities[abilityId] = true
        end
    end

    local counter = 0
    for abilityId, _ in pairs(abilities) do
        counter = counter + 1
        local abilityName = GetAbilityName(abilityId) or "Unknown Ability"
        local icon = GetAbilityIcon(abilityId)
        local currentDuration = CombatInfo.SV.durationOverrides[abilityId] or GetAbilityDuration(abilityId) or 0

        choices[counter] = zo_iconFormat(icon, 16, 16) .. " [" .. abilityId .. "] " .. abilityName .. string_format(" (%d ms)", currentDuration)
        choicesValues[counter] = abilityId
    end

    return choices, choicesValues
end

function ActionBar.ClearDurationOverrides()
    for k, v in pairs(CombatInfo.SV.durationOverrides) do
        CombatInfo.SV.durationOverrides[k] = nil
    end
    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat("CombatInfo: Cleared all custom duration overrides", true)
end

function ActionBar.AddDurationOverride(input)
    local parts = {}
    for part in string.gmatch(input, "%S+") do
        table.insert(parts, part)
    end

    if #parts ~= 2 then
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat("CombatInfo: Invalid format. Use: <abilityId> <durationMs>", true)
        return
    end

    local abilityId = tonumber(parts[1])
    local duration = tonumber(parts[2])

    if not abilityId or not duration or abilityId <= 0 or duration <= 0 then
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat("CombatInfo: Invalid ability ID or duration. Both must be positive numbers.", true)
        return
    end

    local abilityName = GetAbilityName(abilityId) or "Unknown Ability"
    CombatInfo.SV.durationOverrides[abilityId] = duration

    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat(string_format("CombatInfo: Added duration override for %s (%d): %d ms", abilityName, abilityId, duration), true)
end

function ActionBar.RemoveDurationOverride(input)
    local abilityId = tonumber(input)
    if not abilityId or abilityId <= 0 then
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat("CombatInfo: Invalid ability ID. Must be a positive number.", true)
        return
    end

    if not CombatInfo.SV.durationOverrides[abilityId] then
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat(string_format("CombatInfo: No duration override found for ability ID %d", abilityId), true)
        return
    end

    local abilityName = GetAbilityName(abilityId) or "Unknown Ability"
    local duration = CombatInfo.SV.durationOverrides[abilityId]
    CombatInfo.SV.durationOverrides[abilityId] = nil

    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat(string_format("CombatInfo: Removed duration override for %s (%d): %d ms", abilityName, abilityId, duration), true)
end

function ActionBar.ListDurationOverrides()
    local count = 0
    for abilityId, duration in pairs(CombatInfo.SV.durationOverrides) do
        count = count + 1
        local abilityName = GetAbilityName(abilityId) or "Unknown Ability"
        printToChat(string_format("CombatInfo: %s (%d): %d ms", abilityName, abilityId, duration), true)
    end

    if count == 0 then
        printToChat("CombatInfo: No duration overrides configured", true)
    else
        printToChat(string_format("CombatInfo: Total duration overrides: %d", count), true)
    end
end

-- Called on initialization and on full update to swap icons on backbar
function ActionBar.SetupBackBarIcons(button, flip)
    local inactiveHotbarCategory = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
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
        g_hotbarCategory = GetActiveHotbarCategory()
        g_actionBarActiveWeaponPair = GetHeldWeaponPair()
        UpdateBackbarButtonActionIds()
    end
end

do
    local NO_LEADING_EDGE = false
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

            local useDesaturation = (isShowingCooldown and CombatInfo.SV.GlobalDesat) or stackEmpty
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
            local showCooldown = isInCooldown and (CombatInfo.SV.GlobalShowGCD or not global or showGlobalCooldownForCollectible)
            local updateChromaQuickslot = (slotType ~= ACTION_TYPE_ABILITY or slotType ~= ACTION_TYPE_CRAFTED_ABILITY) and ZO_RZCHROMA_EFFECTS
            self.cooldown:SetHidden(not showCooldown)

            if showCooldown then
                if not IsSlotItemConsumable(slotNum, hotbarCategory) or duration > 1000 or CombatInfo.SV.GlobalPotion then
                    self.cooldown:StartCooldown(remain, duration, CooldownMethod[CombatInfo.SV.GlobalMethod], nil, NO_LEADING_EDGE)

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
                                         end, "CooldownUpdate")

                    if updateChromaQuickslot then
                        ZO_RZCHROMA_EFFECTS:RemoveKeybindActionEffect("ACTION_BUTTON_9")
                    end
                end
            else
                if CombatInfo.SV.GlobalFlash then
                    if self.showingCooldown then
                        if not IsSlotItemConsumable(slotNum, hotbarCategory) or duration > 1000 or CombatInfo.SV.GlobalPotion then
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

                if showCooldown or self.itemQtyFailure then
                    self.icon:SetDesaturation(1)
                else
                    self.icon:SetDesaturation(0)
                end

                local textColor = showCooldown and INTERFACE_TEXT_COLOR_FAILED or INTERFACE_TEXT_COLOR_SELECTED
                self.buttonText:SetColor(GetInterfaceColor(INTERFACE_COLOR_TYPE_TEXT_COLORS, textColor))

                self.isGlobalCooldown = global
                self:UpdateUsable()
            end
        end
    end
end

-- Helper to clear a table while maintaining the reference
local function ClearTable(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

-- Called on initialization and menu changes
function ActionBar.UpdateBarHighlightTables()
    ClearTable(g_uiProcAnimation)
    ClearTable(g_uiCustomToggle)
    ClearTable(g_triggeredSlotsFront)
    ClearTable(g_triggeredSlotsBack)
    ClearTable(g_triggeredSlotsRemain)
    ClearTable(g_toggledSlotsFront)
    ClearTable(g_toggledSlotsBack)
    ClearTable(g_toggledSlotsRemain)
    ClearTable(g_toggledSlotsStack)
    ClearTable(g_toggledSlotsPlayer)
    ClearTable(g_barOverrideCI)
    ClearTable(g_barFakeAura)
    ClearTable(g_barNoRemove)

    g_barDurationOverride = CombatInfo.SV.durationOverrides or {}
    CombatInfo.SV.durationOverrides = g_barDurationOverride

    -- Notify EventHandlers to refresh their cached reference to g_barDurationOverride
    if CombatInfo.EventHandlers and CombatInfo.EventHandlers.RefreshCachedReferences then
        CombatInfo.EventHandlers.RefreshCachedReferences()
    end

    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled then
        for abilityId, value in pairs(Effects.BarHighlightOverride) do
            if value.showFakeAura == true then
                if value.newId then
                    g_barOverrideCI[value.newId] = true
                    if value.duration and not g_barDurationOverride[value.newId] then
                        g_barDurationOverride[value.newId] = value.duration
                    end
                    if value.noRemove then
                        g_barNoRemove[value.newId] = true
                    end
                    g_barFakeAura[value.newId] = true
                else
                    g_barOverrideCI[abilityId] = true
                    if value.duration and not g_barDurationOverride[abilityId] then
                        g_barDurationOverride[abilityId] = value.duration
                    end
                    if value.noRemove then
                        g_barNoRemove[abilityId] = true
                    end
                    g_barFakeAura[abilityId] = true
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
        local nextEventHandleNr = 0
        for abilityId, _ in pairs(g_barOverrideCI) do
            local eventName = moduleName .. "CombatEventBar" .. tostring(nextEventHandleNr)
            nextEventHandleNr = nextEventHandleNr + 1
            eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, CombatInfo.OnCombatEventBar)
            eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, abilityId, REGISTER_FILTER_IS_ERROR, false)
        end
    end
end

-- Resets bar labels on menu option change
function ActionBar.ResetBarLabel()
    for k, _ in pairs(g_uiProcAnimation) do
        g_uiProcAnimation[k].procLoopTexture.label:SetText("")
    end

    for k, _ in pairs(g_uiCustomToggle) do
        g_uiCustomToggle[k].label:SetText("")
    end

    for i = BAR_INDEX_START, BAR_INDEX_END do
        local actionButton = ZO_ActionBar_GetButton(i)
        if g_uiCustomToggle[i] then
            g_uiCustomToggle[i].label:ClearAnchors()
            g_uiCustomToggle[i].label:SetAnchor(TOPLEFT, actionButton.slot)
            g_uiCustomToggle[i].label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        elseif g_uiProcAnimation[i] then
            g_uiProcAnimation[i].procLoopTexture.label:ClearAnchors()
            g_uiProcAnimation[i].procLoopTexture.label:SetAnchor(TOPLEFT, actionButton.slot)
            g_uiProcAnimation[i].procLoopTexture.label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        end

        local backIndex = i + BACKBAR_INDEX_OFFSET
        local actionButtonBB = g_backbarButtons[backIndex]
        if g_uiCustomToggle[backIndex] then
            g_uiCustomToggle[backIndex].label:ClearAnchors()
            g_uiCustomToggle[backIndex].label:SetAnchor(TOPLEFT, actionButtonBB.slot)
            g_uiCustomToggle[backIndex].label:SetAnchor(BOTTOMRIGHT, actionButtonBB.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        elseif g_uiProcAnimation[backIndex] then
            g_uiProcAnimation[backIndex].procLoopTexture.label:ClearAnchors()
            g_uiProcAnimation[backIndex].procLoopTexture.label:SetAnchor(TOPLEFT, actionButtonBB.slot)
            g_uiProcAnimation[backIndex].procLoopTexture.label:SetAnchor(BOTTOMRIGHT, actionButtonBB.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        end
    end
end

-- Resets Potion Timer label
function ActionBar.ResetPotionTimerLabel()
    local QSB = _G["QuickslotButton"]
    uiQuickSlot.label:ClearAnchors()
    uiQuickSlot.label:SetAnchor(TOPLEFT, QSB, nil, 0, 0)
    uiQuickSlot.label:SetAnchor(BOTTOMRIGHT, QSB, nil, 0, -CombatInfo.SV.PotionTimerLabelPosition)
end

-- Resets the ultimate labels on menu option change
function ActionBar.ResetUltimateLabel()
    uiUltimate.LabelPct:ClearAnchors()
    local actionButton = ZO_ActionBar_GetButton(8)
    uiUltimate.LabelPct:SetAnchor(TOPLEFT, actionButton.slot)
    uiUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.UltimateLabelPosition)
end

--- Handles slot updated event
--- @param eventCode integer
--- @param slotNum integer
function ActionBar.OnSlotUpdated(eventCode, slotNum)
    if slotNum == 8 then
        ActionBar.UpdateUltimateLabel()
    end
end

---
--- @param slotNum integer
--- @param wasfullUpdate boolean
--- @param onlyProc boolean
function ActionBar.BarSlotUpdate(slotNum, wasfullUpdate, onlyProc)
    if not slotNum or not BACKBAR_INDEX_OFFSET then
        return
    end

    if slotNum < BACKBAR_INDEX_OFFSET then
        if CombatInfo.SV.ShowToggledUltimate then
            if slotNum < BAR_INDEX_START or slotNum > BAR_INDEX_END then
                return
            end
        else
            if slotNum < BAR_INDEX_START or slotNum > (BAR_INDEX_END - 1) then
                return
            end
        end
    end

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

    if g_uiProcAnimation[slotNum] and g_uiProcAnimation[slotNum]:IsPlaying() then
        g_uiProcAnimation[slotNum]:Stop()
    end

    if onlyProc == false then
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

        if g_uiCustomToggle[slotNum] then
            g_uiCustomToggle[slotNum]:SetHidden(true)
        end
    end

    if slotNum < BACKBAR_INDEX_OFFSET and not IsSlotUsed(slotNum, g_hotbarCategory) then
        return
    end

    local ability_id = GetSlotTrueBoundId(slotNum, g_hotbarCategory)
    if slotNum > BACKBAR_INDEX_OFFSET then
        local hotbarCategory = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and HOTBAR_CATEGORY_PRIMARY or HOTBAR_CATEGORY_BACKUP
        ability_id = GetSlotTrueBoundId(slotNum - BACKBAR_INDEX_OFFSET, hotbarCategory)

        local weaponSlot = g_hotbarCategory == HOTBAR_CATEGORY_BACKUP and 4 or 20
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

    if showFakeAura then
        if not g_barFakeAura[ability_id] then
            g_barFakeAura[ability_id] = true
            g_barOverrideCI[ability_id] = true

            if Effects.BarHighlightOverride[ability_id] and Effects.BarHighlightOverride[ability_id].duration then
                g_barDurationOverride[ability_id] = Effects.BarHighlightOverride[ability_id].duration
            end
        end
    end

    local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, GetAbilityName(ability_id))
    local abilityName = Effects.EffectOverride[ability_id] and Effects.EffectOverride[ability_id].name or cachedName
    local duration = GetUpdatedAbilityDuration(ability_id) or 0

    local currentTimeMs = timeMs()

    local triggeredSlots = slotNum > BACKBAR_INDEX_OFFSET and g_triggeredSlotsBack or g_triggeredSlotsFront
    local proc = Effects.HasAbilityProc[abilityName]

    if proc then
        triggeredSlots[proc] = slotNum
        if g_triggeredSlotsRemain[proc] then
            if CombatInfo.SV.ShowTriggered then
                ActionBar.PlayProcAnimations(slotNum)
                if CombatInfo.SV.BarShowLabel then
                    if not g_uiProcAnimation[slotNum] then
                        return
                    end
                    local remain = g_triggeredSlotsRemain[proc] - currentTimeMs
                    g_uiProcAnimation[slotNum].procLoopTexture.label:SetText(SetBarRemainLabel(remain, ability_id))
                end
            end
        end
    end

    local toggledSlots = slotNum > BACKBAR_INDEX_OFFSET and g_toggledSlotsBack or g_toggledSlotsFront

    if onlyProc == false then
        if duration > 0 or Effects.AddNoDurationBarHighlight[ability_id] or Effects.IsGrimFocus[ability_id] or Effects.IsBloodFrenzy[ability_id] or Effects.MajorMinor[ability_id] then
            toggledSlots[ability_id] = slotNum
            if g_toggledSlotsRemain[ability_id] then
                if CombatInfo.SV.ShowToggled then
                    local slotNumST = toggledSlots[ability_id]
                    local desaturate
                    local mainBarSlotIndex = slotNumST > BACKBAR_INDEX_OFFSET and slotNumST - BACKBAR_INDEX_OFFSET or nil
                    if mainBarSlotIndex then
                        if g_uiCustomToggle[mainBarSlotIndex] then
                            desaturate = false
                            if g_uiCustomToggle[mainBarSlotIndex]:IsHidden() then
                                ActionBar.BackbarHideSlot(slotNumST)
                                desaturate = true
                            end
                        end
                    end
                    ActionBar.ShowSlot(slotNumST, ability_id, currentTimeMs, desaturate)
                end
            end
        end
    end
end

---
function ActionBar.UpdateUltimateLabel()
    local bar = g_hotbarCategory
    g_ultimateCost = GetSlotAbilityCost(g_ultimateSlot, COMBAT_MECHANIC_FLAGS_ULTIMATE, bar) or 0

    ActionBar.OnPowerUpdatePlayer(EVENT_POWER_UPDATE, "player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, g_ultimateCurrent, 0, 0)
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
    g_hotbarCategory = GetActiveHotbarCategory()
    if didActiveHotbarChange then
        for _, physicalSlot in pairs(g_backbarButtons) do
            if physicalSlot.hotbarSwapAnimation then
                physicalSlot.noUpdates = true
                physicalSlot.hotbarSwapAnimation:PlayFromStart()
            end
        end
    else
        ActionBar.OnSlotsFullUpdate()
    end
end

---
function ActionBar.OnSlotsFullUpdate()
    g_activeWeaponSwapInProgress = false
    if g_potionUsed == true then
        return
    end

    ActionBar.UpdateUltimateLabel()

    for i = BAR_INDEX_START, BAR_INDEX_END do
        ActionBar.BarSlotUpdate(i, true, false)
    end

    for i = (BAR_INDEX_START + BACKBAR_INDEX_OFFSET), (BACKBAR_INDEX_END + BACKBAR_INDEX_OFFSET) do
        local button = g_backbarButtons[i]
        ActionBar.SetupBackBarIcons(button)
        ActionBar.BarSlotUpdate(i, true, false)
    end
end

---
--- @param slotNum integer
function ActionBar.PlayProcAnimations(slotNum)
    if not g_uiProcAnimation[slotNum] then
        local color = uiQuickSlot.color
        if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
            return
        end
        local actionButton
        if slotNum < BACKBAR_INDEX_OFFSET then
            actionButton = ZO_ActionBar_GetButton(slotNum)
        else
            actionButton = g_backbarButtons[slotNum]
        end
        local procLoopTexture = UI:ControlWithType(actionButton.slot, "fill", nil, false, "$(parent)Loop_LUIE", CT_TEXTURE)
        procLoopTexture:SetAnchor(TOPLEFT, actionButton.slot:GetNamedChild("FlipCard"))
        procLoopTexture:SetAnchor(BOTTOMRIGHT, actionButton.slot:GetNamedChild("FlipCard"))
        procLoopTexture:SetTexture("/esoui/art/actionbar/abilityhighlight_mage_med.dds")
        procLoopTexture:SetBlendMode(TEX_BLEND_MODE_ADD)
        procLoopTexture:SetDrawLayer(DL_TEXT)
        procLoopTexture:SetHidden(true)

        local label = UI:Label(procLoopTexture, nil, nil, nil, g_barFont, nil, false)
        label:SetAnchor(TOPLEFT, actionButton.slot)
        label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
        label:SetDrawLayer(DL_CONTROLS)
        label:SetDrawLevel(DL_OVERLAY)
        label:SetDrawTier(DT_HIGH)
        label:SetColor(unpack(color or { 1, 1, 1, 1 }))
        label:SetHidden(false)
        procLoopTexture.label = label

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

        g_uiProcAnimation[slotNum] = procLoopTimeline
    end
    if g_uiProcAnimation[slotNum] then
        if not g_uiProcAnimation[slotNum]:IsPlaying() then
            g_uiProcAnimation[slotNum]:PlayFromStart()
        end
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

-- Displays custom toggle texture
---
--- @param slotNum integer
function ActionBar.ShowCustomToggle(slotNum)
    if not g_uiCustomToggle[slotNum] then
        local color = uiQuickSlot.color
        if slotNum == (BAR_INDEX_END + BACKBAR_INDEX_OFFSET) then
            return
        end
        local actionButton
        if slotNum < BACKBAR_INDEX_OFFSET then
            actionButton = ZO_ActionBar_GetButton(slotNum)
        else
            actionButton = g_backbarButtons[slotNum]
        end

        if not actionButton or not actionButton.slot then
            return
        end

        local name = "ActionButton" .. slotNum
        local window = GetWindowManager():GetControlByName(name, "Toggle_LUIE")
        if window == nil then
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

            toggleFrame.label = UI:Label(toggleFrame, nil, nil, nil, g_barFont, nil, false)
            toggleFrame.label:SetAnchor(TOPLEFT, actionButton.slot)
            toggleFrame.label:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.BarLabelPosition)
            toggleFrame.label:SetDrawLayer(DL_CONTROLS)
            toggleFrame.label:SetDrawLevel(DL_CONTROLS)
            toggleFrame.label:SetDrawTier(DT_HIGH)
            toggleFrame.label:SetColor(unpack(CombatInfo.SV.RemainingTextColoured and color or { 1, 1, 1, 1 }))
            toggleFrame.label:SetHidden(false)

            toggleFrame.stack = UI:Label(toggleFrame, nil, nil, nil, g_barFont, nil, false)
            toggleFrame.stack:SetAnchor(CENTER, actionButton.slot, BOTTOMLEFT)
            toggleFrame.stack:SetAnchor(CENTER, actionButton.slot, TOPRIGHT, -12, 14)

            toggleFrame.stack:SetDrawLayer(DL_CONTROLS)
            toggleFrame.stack:SetDrawLevel(DL_CONTROLS)
            toggleFrame.stack:SetDrawTier(DT_HIGH)
            toggleFrame.stack:SetColor(unpack(CombatInfo.SV.RemainingTextColoured and color or { 1, 1, 1, 1 }))
            toggleFrame.stack:SetHidden(false)

            g_uiCustomToggle[slotNum] = toggleFrame
        end
    end
    if g_uiCustomToggle[slotNum] then
        g_uiCustomToggle[slotNum]:SetHidden(false)
    end
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
    local pct = (g_ultimateCost > 0) and zo_floor((powerValue / g_ultimateCost) * 100) or 0
    if pct > 100 then
        pct = 100
    end
    if IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        if CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
            if CombatInfo.SV.UltimatePctEnabled then
                uiUltimate.LabelPct:SetText(pct .. "%")
            end
            if CombatInfo.SV.UltimateLabelEnabled then
                uiUltimate.LabelVal:SetText(powerValue .. "/" .. g_ultimateCost)
            end
            if pct < 100 then
                local setHiddenPct = not CombatInfo.SV.UltimatePctEnabled
                if CombatInfo.SV.ShowToggledUltimate and g_uiCustomToggle[8] and not g_uiCustomToggle[8]:IsHidden() then
                    setHiddenPct = true
                end
                uiUltimate.LabelPct:SetHidden(setHiddenPct)
                if CombatInfo.SV.UltimateLabelEnabled then
                    for i = #uiUltimate.pctColors, 1, -1 do
                        if pct < uiUltimate.pctColors[i].pct then
                            uiUltimate.LabelVal:SetColor(unpack(uiUltimate.pctColors[i].color))
                            break
                        end
                    end
                end
            else
                local setHiddenPct = not CombatInfo.SV.UltimatePctEnabled
                if (CombatInfo.SV.ShowToggledUltimate and g_uiCustomToggle[8] and not g_uiCustomToggle[8]:IsHidden()) or CombatInfo.SV.UltimateHideFull then
                    setHiddenPct = true
                end
                uiUltimate.LabelPct:SetHidden(setHiddenPct)
                if CombatInfo.SV.UltimateLabelEnabled then
                    uiUltimate.LabelVal:SetColor(unpack(uiUltimate.color))
                end
            end
            local setHiddenLabel = not CombatInfo.SV.UltimateLabelEnabled
            uiUltimate.LabelVal:SetHidden(setHiddenLabel)
        else
            -- Hide labels when both settings are disabled
            uiUltimate.LabelPct:SetHidden(true)
            uiUltimate.LabelVal:SetHidden(true)
        end
    else
        uiUltimate.LabelPct:SetHidden(true)
        uiUltimate.LabelVal:SetHidden(true)
    end
    g_ultimateCurrent = powerValue
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
    end
end

--- Hides slot
--- @param slotNum integer Slot number
--- @param abilityId integer Ability ID
function ActionBar.HideSlot(slotNum, abilityId)
    g_uiCustomToggle[slotNum]:SetHidden(true)
    if slotNum > BACKBAR_INDEX_OFFSET then
        if slotNum ~= BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
            ActionBar.BackbarHideSlot(slotNum)
            ActionBar.ToggleBackbarSaturation(slotNum, CombatInfo.SV.BarDarkUnused)
        end
    end
    if slotNum == g_ultimateSlot and CombatInfo.SV.UltimatePctEnabled and IsSlotUsed(g_ultimateSlot, g_hotbarCategory) then
        uiUltimate.LabelPct:SetHidden(false)
    end
end

--- Shows slot
--- @param slotNum number
--- @param abilityId number
--- @param currentTimeMs number
--- @param desaturate boolean
function ActionBar.ShowSlot(slotNum, abilityId, currentTimeMs, desaturate)
    ActionBar.ShowCustomToggle(slotNum)
    if slotNum > BACKBAR_INDEX_OFFSET then
        if slotNum ~= BAR_INDEX_END + BACKBAR_INDEX_OFFSET then
            ActionBar.BackbarShowSlot(slotNum)
            ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
        end
    end
    if slotNum == 8 and CombatInfo.SV.UltimatePctEnabled then
        uiUltimate.LabelPct:SetHidden(true)
    end
    if CombatInfo.SV.BarShowLabel then
        if not g_uiCustomToggle[slotNum] then
            return
        end
        local remain = g_toggledSlotsRemain[abilityId] - currentTimeMs
        g_uiCustomToggle[slotNum].label:SetText(SetBarRemainLabel(remain, abilityId))

        local stackCount = nil
        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
            stackCount = g_toggledSlotsStack[abilityId]
        elseif g_mineStacks[abilityId] and g_mineStacks[abilityId] > 0 and not Effects.HideGroundMineStacks[abilityId] then
            stackCount = g_mineStacks[abilityId]
        end

        if g_uiCustomToggle[slotNum] then
            if stackCount and stackCount > 0 then
                g_uiCustomToggle[slotNum].stack:SetText(stackCount)
            else
                g_uiCustomToggle[slotNum].stack:SetText("")
            end
        end
    end
end

--- Handles backbar hide slot event
--- @param slotNum number
function ActionBar.BackbarHideSlot(slotNum)
    if CombatInfo.SV.BarHideUnused then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(true)
        end
    end
end

--- Handles backbar show slot event
--- @param slotNum number
function ActionBar.BackbarShowSlot(slotNum)
    if CombatInfo.SV.BarShowBack then
        if g_backbarButtons[slotNum] then
            g_backbarButtons[slotNum].slot:SetHidden(false)
        end
    end
end

--- Handles backbar saturation toggle event
--- @param slotNum number
--- @param desaturate boolean
function ActionBar.ToggleBackbarSaturation(slotNum, desaturate)
    local button = g_backbarButtons[slotNum]
    if CombatInfo.SV.BarDarkUnused then
        ZO_ActionSlot_SetUnusable(button.icon, desaturate, false)
    end
    if CombatInfo.SV.BarDesaturateUnused then
        local saturation = desaturate and 1 or 0
        button.icon:SetDesaturation(saturation)
    end
end

-- Called on initialization and when swapping in and out of Gamepad mode
function ActionBar.BackbarSetupTemplate()
    local style = IsInGamepadPreferredMode() and GAMEPAD_CONSTANTS or KEYBOARD_CONSTANTS
    local weaponSwapControl = ACTION_BAR:GetNamedChild("WeaponSwap")

    local lastButton
    local buttonTemplate = ZO_GetPlatformTemplate("ZO_ActionButton")
    for i = BAR_INDEX_START, BAR_INDEX_END do
        local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]

        if i > 2 and i < 8 then
            local anchorTarget = lastButton and lastButton.slot
            if not lastButton then
                anchorTarget = weaponSwapControl
            end
            targetButton:ApplyAnchor(anchorTarget, style.abilitySlotOffsetX)
            targetButton:ApplyStyle(buttonTemplate)
        end

        lastButton = targetButton
    end

    local offsetY = IsInGamepadPreferredMode() and ACTION_BAR:GetHeight() * 1.6 or ACTION_BAR:GetHeight()
    local ActionButton53 = GetControl("ActionButton53")
    local AB3 = _G["ActionButton3"]
    ActionButton53:ClearAnchors()
    ActionButton53:SetAnchor(CENTER, AB3, CENTER, 0, -(offsetY * 0.8))
end

-- Called from the menu and on init
function ActionBar.BackbarToggleSettings()
    for i = BAR_INDEX_START, BACKBAR_INDEX_END do
        local targetButton = g_backbarButtons[i + BACKBAR_INDEX_OFFSET]

        if CombatInfo.SV.BarShowBack and not CombatInfo.SV.BarHideUnused then
            targetButton.slot:SetHidden(false)
        end
        ZO_ActionSlot_SetUnusable(targetButton.icon, CombatInfo.SV.BarDarkUnused, false)
        local saturation = CombatInfo.SV.BarDesaturateUnused and 1 or 0
        targetButton.icon:SetDesaturation(saturation)

        if CombatInfo.SV.BarHideUnused or not CombatInfo.SV.BarShowBack then
            targetButton.slot:SetHidden(true)
        end
    end
end

-- Main ticker update for action bar (called from CombatInfo.OnUpdate)
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
        if CombatInfo.SV.BarShowLabel and remain then
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
        if CombatInfo.SV.BarShowLabel and remain then
            if frontToggle then
                frontToggle.label:SetText(SetBarRemainLabel(remain, k))
            end
            if backToggle then
                backToggle.label:SetText(SetBarRemainLabel(remain, k))
            end
        end
    end

    -- Quickslot cooldown
    if CombatInfo.SV.PotionTimerShow then
        local slotIndex = GetCurrentQuickslot()
        local remain, duration, global, globalSlotType = GetSlotCooldownInfo(slotIndex, HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
        local label = uiQuickSlot.label
        local timeColors = uiQuickSlot.timeColors
        if duration > 1000 then
            label:SetHidden(false)
            if not CombatInfo.SV.PotionTimerColor then
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
                text = string_format(CombatInfo.SV.PotionTimerMillis and "%.1f" or "%.1d", 0.001 * remain)
            end
            label:SetText(text)
        else
            label:SetHidden(true)
        end
    end

    -- Hide Ultimate generation texture if it is time to do so
    if CombatInfo.SV.UltimateGeneration then
        if not uiUltimate.Texture:IsHidden() and uiUltimate.FadeTime < currentTimeMs then
            uiUltimate.Texture:SetHidden(true)
        end
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
end

-- Initialize action bar module
function ActionBar.Initialize()
    local QSB = _G["QuickslotButton"]
    uiQuickSlot.label = UI:Label(QSB, { CENTER, CENTER }, nil, nil, g_potionFont, nil, true)
    uiQuickSlot.label:SetFont(g_potionFont)
    if CombatInfo.SV.PotionTimerColor then
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
    uiUltimate.LabelPct:SetAnchor(BOTTOMRIGHT, actionButton.slot, nil, 0, -CombatInfo.SV.UltimateLabelPosition)

    uiUltimate.LabelPct:SetColor(unpack(uiUltimate.color))
    uiUltimate.Texture = UI:Texture(AB8, { CENTER, CENTER }, { 160, 160 }, "/esoui/art/crafting/white_burst.dds", DL_BACKGROUND, true)

    -- Create backbar buttons
    do
        local slotsUpdated = {}

        local function OnSwapAnimationHalfDone(animation, button, isBackBarSlot)
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
            button:UpdateState()
            button.button.actionId = GetSlotTrueBoundId(i - 50, HOTBAR_CATEGORY_BACKUP)
            g_backbarButtons[i] = button
        end
    end

    ActionBar.BackbarSetupTemplate()
    ActionBar.BackbarToggleSettings()

    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled then
        ActionBar.DisableZOSTimerDisplay()
    end
end

-- Export state for CombatInfo main module to access
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
ActionBar.GetProcSound = function () return g_ProcSound end
ActionBar.GetBoundArmamentsPlayed = function () return g_boundArmamentsPlayed end
ActionBar.SetBoundArmamentsPlayed = function (value) g_boundArmamentsPlayed = value end
