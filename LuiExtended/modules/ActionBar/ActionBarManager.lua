-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------
--
-- Consolidated event handler registration for ActionBar module
-- Following ZOS pattern: all event handlers defined and registered in one file
--

--- @class (partial) LuiExtended
local LUIE = LUIE
local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Castbar = Data.CastBarTable
local OtherAddonCompatability = LUIE.OtherAddonCompatability

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo

local eventManager = GetEventManager()
local pairs = pairs
local timeMs = GetFrameTimeMilliseconds
local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local GetAbilityDuration = GetAbilityDuration
local zo_floor = zo_floor
local string_format = string.format
local GetActionSlotEffectDuration = GetActionSlotEffectDuration
local GetActionSlotEffectTimeRemaining = GetActionSlotEffectTimeRemaining

local moduleName = LUIE.name .. "ActionBar"

-- ============================================================================
-- MODULE-LEVEL CACHED REFERENCES
-- ============================================================================
-- Cache ActionBar table references at module level to avoid repeated getter calls

local g_barFakeAura
local g_toggledSlotsPlayer
local g_toggledSlotsRemain
local g_toggledSlotsFront
local g_toggledSlotsBack
local g_toggledSlotsStack
local g_uiCustomToggle
local g_barNoRemove
local g_protectAbilityRemoval
local g_mineStacks
local g_mineNoTurnOff
local g_ProcSound
local g_boundArmamentsPlayed
local g_triggeredSlotsRemain
local g_triggeredSlotsFront
local g_triggeredSlotsBack
local g_barDurationOverride
local uiUltimate
local uiCompanionUltimate
local g_hotbarCategory
local g_ultimateSlot
local g_ultimateCost
local g_ultimateCurrent
local g_companionUltimateCost
local g_companionUltimateCurrent
local g_companionUltimateButton
local g_backbarButtons
local g_uiProcAnimation
local g_potionUsed
local g_activeWeaponSwapInProgress
local g_actionBarActiveWeaponPair
local uiQuickSlot
local g_backbarUniqueHidden

-- Cache addon compatibility check (checked once at load, never changes)
local isFancyActionBarEnabled = OtherAddonCompatability.isFancyActionBarPlusEnabled or LUIE.IsItEnabled("FancyActionBar\43") or LUIE.IsItEnabled("FancyActionBar")

-- Function to initialize cached references (called once during ActionBar initialization)
local function InitializeCachedReferences()
    g_barFakeAura = ActionBar.GetBarFakeAura()
    g_toggledSlotsPlayer = ActionBar.GetToggledSlotsPlayer()
    g_toggledSlotsRemain = ActionBar.GetToggledSlotsRemain()
    g_toggledSlotsFront = ActionBar.GetToggledSlotsFront()
    g_toggledSlotsBack = ActionBar.GetToggledSlotsBack()
    g_toggledSlotsStack = ActionBar.GetToggledSlotsStack()
    g_uiCustomToggle = ActionBar.GetUiCustomToggle()
    g_barNoRemove = ActionBar.GetBarNoRemove()
    g_protectAbilityRemoval = ActionBar.GetProtectAbilityRemoval()
    g_mineStacks = ActionBar.GetMineStacks()
    g_mineNoTurnOff = ActionBar.GetMineNoTurnOff()
    g_ProcSound = ActionBar.GetProcSound()
    g_boundArmamentsPlayed = ActionBar.GetBoundArmamentsPlayed()
    g_triggeredSlotsRemain = ActionBar.GetTriggeredSlotsRemain()
    g_triggeredSlotsFront = ActionBar.GetTriggeredSlotsFront()
    g_triggeredSlotsBack = ActionBar.GetTriggeredSlotsBack()
    g_barDurationOverride = ActionBar.GetBarDurationOverride()
    uiUltimate = ActionBar.GetUltimateState()
    uiCompanionUltimate = ActionBar.GetCompanionUltimateState()
end

-- Public function to refresh cached references (called when ActionBar reinitializes tables)
function ActionBar.RefreshCachedReferences()
    g_barDurationOverride = ActionBar.GetBarDurationOverride()
end

-- ============================================================================
-- FORWARD DECLARATIONS
-- ============================================================================

-- Forward declarations for functions used before they're defined
local HandleBarHighlightSwap
local OnEffectChanged
local OnReticleTargetChanged

-- ============================================================================
-- HELPER FUNCTIONS (from EventHandlers.lua)
-- ============================================================================

-- Helper to get override ability duration
local function GetUpdatedAbilityDuration(abilityId)
    local dur = g_barDurationOverride[abilityId] or GetAbilityDuration(abilityId) or 0
    return dur
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
    if Effects.EffectGroundDisplay[abilityId] and Effects.EffectGroundDisplay[abilityId].stackReset then
        local maxStacks = Effects.EffectGroundDisplay[abilityId].stackReset
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
            HandleBarHighlightSwap(abilityId)
        end
    end
end

-- ============================================================================
-- EVENT HANDLER FUNCTIONS (Local Functions)
-- ============================================================================

-- Handles bar highlight swap event
local function BarHighlightSwap(abilityId)
    local effect = Effects.BarHighlightCheckOnFade[abilityId]
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
    if Effects.BarHighlightCheckOnFade[abilityId] then
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

-- Handles effect changed event (MASSIVE 225-line handler)
OnEffectChanged = function (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer, passThrough, savedId)
    if g_barFakeAura[abilityId] and not passThrough then
        return
    end
    if castByPlayer ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if Effects.IsVamp[abilityId] and changeType == EFFECT_RESULT_GAINED then
        ActionBar.UpdateUltimateLabel()
    end

    if Castbar.CastBreakOnRemoveEffect[abilityId] and changeType == EFFECT_RESULT_FADED then
        local CastBar = CombatInfo.CastBar
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

    if (Effects.EffectGroundDisplay[abilityId] or Effects.LinkedGroundMine[abilityId]) and not passThrough then
        if Effects.LinkedGroundMine[abilityId] then
            abilityId = Effects.LinkedGroundMine[abilityId]
        end

        if changeType == EFFECT_RESULT_FADED then
            if abilityId == 32958 then
                return
            end
            local currentTimeMs = timeMs()
            if not g_protectAbilityRemoval[abilityId] or g_protectAbilityRemoval[abilityId] < currentTimeMs then
                if Effects.IsGroundMineAura[abilityId] or Effects.IsGroundMineStack[abilityId] then
                    if g_mineStacks[abilityId] then
                        HandleGroundMineStackChange(abilityId, -Effects.EffectGroundDisplay[abilityId].stackRemove)
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

            if Effects.IsGroundMineAura[abilityId] then
                g_mineStacks[abilityId] = Effects.EffectGroundDisplay[abilityId].stackReset
            elseif Effects.IsGroundMineStack[abilityId] then
                if g_mineStacks[abilityId] then
                    g_mineStacks[abilityId] = g_mineStacks[abilityId] + Effects.EffectGroundDisplay[abilityId].stackRemove
                else
                    g_mineStacks[abilityId] = 1
                end
                if g_mineStacks[abilityId] > Effects.EffectGroundDisplay[abilityId].stackReset then
                    g_mineStacks[abilityId] = Effects.EffectGroundDisplay[abilityId].stackReset
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

    if savedId and Effects.BarHighlightStack[savedId] then
        stackCount = Effects.BarHighlightStack[savedId]
    elseif Effects.BarHighlightStack[abilityId] then
        stackCount = Effects.BarHighlightStack[abilityId]
    end

    -- Handle Crux stack mapping: when Crux effect (184220) is detected, update stack counts for all Crux-related abilities
    if Effects.BarHighlightCruxMap[abilityId] then
        local cruxAbilities = Effects.BarHighlightCruxMap[abilityId]
        local cruxAbilitySet = {}
        for _, cruxAbilityId in ipairs(cruxAbilities) do
            cruxAbilitySet[cruxAbilityId] = true
        end

        -- Check all action bar slots (front and back) for Crux-related abilities
        if ActionBar.IsPlayerHotbarCategory(g_hotbarCategory) and ActionBar.SV.ShowToggled then
            local currentTimeMs = timeMs()
            
            -- Check front bar slots
            for slotNum = ActionBar.GetBarIndexStart(), ActionBar.GetBarIndexEnd() do
                local slotAbilityId = ActionBar.GetSlotAbilityId(slotNum)
                if slotAbilityId and cruxAbilitySet[slotAbilityId] then
                    -- Found a Crux ability on the action bar
                    if not g_toggledSlotsFront[slotAbilityId] then
                        g_toggledSlotsFront[slotAbilityId] = slotNum
                    end
                    -- Set a long duration so the slot stays visible
                    if not g_toggledSlotsRemain[slotAbilityId] then
                        g_toggledSlotsRemain[slotAbilityId] = currentTimeMs + 90000000
                    end
                    -- Update stack count
                    g_toggledSlotsStack[slotAbilityId] = stackCount
                    -- Show the slot (creates toggle UI if needed)
                    ActionBar.ShowSlot(slotNum, slotAbilityId, currentTimeMs, false)
                    -- Clear the label text for Crux abilities (only show stack count, not timer)
                    if g_uiCustomToggle[slotNum] and g_uiCustomToggle[slotNum].label then
                        g_uiCustomToggle[slotNum].label:SetText("")
                    end
                end
            end

            -- Check back bar slots
            for slotNum = ActionBar.GetBarIndexStart() + ActionBar.GetBackbarIndexOffset(), ActionBar.GetBackbarIndexEnd() + ActionBar.GetBackbarIndexOffset() do
                local slotAbilityId = ActionBar.GetSlotAbilityId(slotNum)
                if slotAbilityId and cruxAbilitySet[slotAbilityId] then
                    -- Found a Crux ability on the back bar
                    if not g_toggledSlotsBack[slotAbilityId] then
                        g_toggledSlotsBack[slotAbilityId] = slotNum
                    end
                    -- Set a long duration so the slot stays visible
                    if not g_toggledSlotsRemain[slotAbilityId] then
                        g_toggledSlotsRemain[slotAbilityId] = currentTimeMs + 90000000
                    end
                    -- Update stack count
                    g_toggledSlotsStack[slotAbilityId] = stackCount
                    -- Show the slot (creates toggle UI if needed)
                    ActionBar.ShowSlot(slotNum, slotAbilityId, currentTimeMs, false)
                    -- Clear the label text for Crux abilities (only show stack count, not timer)
                    if g_uiCustomToggle[slotNum] and g_uiCustomToggle[slotNum].label then
                        g_uiCustomToggle[slotNum].label:SetText("")
                    end
                end
            end
        end
    end

    if not isFancyActionBarEnabled then
        if Effects.BarHighlightExtraId[abilityId] then
            for k, v in pairs(Effects.BarHighlightExtraId) do
                if k == abilityId then
                    abilityId = v
                    if Effects.IsGroundMineAura[abilityId] then
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
            if Effects.BarHighlightCheckOnFade[abilityId] then
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
        if Effects.IsGrimFocus[abilityId] then
            if ActionBar.SV.ShowTriggered and ActionBar.SV.ProcEnableSound then
                if not g_boundArmamentsPlayed[abilityId] then
                    g_boundArmamentsPlayed[abilityId] = {}
                end

                if (stackCount == 5 or stackCount == 10) and not g_boundArmamentsPlayed[abilityId][stackCount] then
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
                    g_boundArmamentsPlayed[abilityId][stackCount] = true
                end

                if stackCount < 5 then
                    g_boundArmamentsPlayed[abilityId][5] = false
                    g_boundArmamentsPlayed[abilityId][10] = false
                elseif stackCount < 10 and stackCount > 5 then
                    g_boundArmamentsPlayed[abilityId][10] = false
                end
            end
        elseif Effects.IsBoundArmaments[abilityId] then
            if ActionBar.SV.ShowTriggered and ActionBar.SV.ProcEnableSound then
                if not g_boundArmamentsPlayed[abilityId] then
                    g_boundArmamentsPlayed[abilityId] = {}
                end

                if (stackCount == 4 or stackCount == 8) and not g_boundArmamentsPlayed[abilityId][stackCount] then
                    PlaySound(g_ProcSound)
                    PlaySound(g_ProcSound)
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
                g_triggeredSlotsRemain[abilityId] = 1000 * endTime
                local remain = g_triggeredSlotsRemain[abilityId] - currentTimeMs

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
                if Effects.IsGrimFocus[abilityId] or Effects.IsBloodFrenzy[abilityId] then
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
    if ActionBar.SV.UltimateGeneration and uiUltimate.NotFull and ((result == ACTION_RESULT_BLOCKED_DAMAGE and targetType == COMBAT_UNIT_TYPE_PLAYER) or (Effects.IsWeaponAttack[abilityName] and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetName ~= "")) then
        uiUltimate.Texture:SetHidden(false)
        uiUltimate.FadeTime = timeMs() + 8000
    end

    -- Helper for damage result validation
    local function isValidDamageResult(res)
        return res == ACTION_RESULT_BLOCKED or res == ACTION_RESULT_BLOCKED_DAMAGE or res == ACTION_RESULT_CRITICAL_DAMAGE or res == ACTION_RESULT_DAMAGE or res == ACTION_RESULT_DAMAGE_SHIELDED or res == ACTION_RESULT_IMMUNE or res == ACTION_RESULT_MISS or res == ACTION_RESULT_PARTIAL_RESIST or res == ACTION_RESULT_REFLECTED or res == ACTION_RESULT_RESIST or res == ACTION_RESULT_WRECKING_DAMAGE or res == ACTION_RESULT_DODGED
    end

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
        if Effects.BarHighlightCheckOnFade[abilityId] and targetType == COMBAT_UNIT_TYPE_PLAYER then
            BarHighlightSwap(abilityId)
        end
    end
end

-- Public function to handle bar combat events (exposed for RegisterBarCombatEvents in ActionBar.lua)
function ActionBar.OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
end

-- ============================================================================
-- ACTION BAR EVENT HANDLERS (from ActionBar.lua)
-- ============================================================================

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
            internalSlotNum = internalSlotNum + ActionBar.GetBackbarIndexOffset()
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

            -- Only learn duration from game API if:
            -- 1. Not already in override table
            -- 2. Not hardcoded in BarHighlightOverride
            -- 3. GetUpdatedAbilityDuration() doesn't already have a valid hardcoded duration from ZOS API (prefer ZOS API over game slot API)
            if not g_barDurationOverride[abilityId] 
                and not (Effects.BarHighlightOverride[abilityId] and Effects.BarHighlightOverride[abilityId].duration) then
                local existingDuration = GetUpdatedAbilityDuration(abilityId)
                -- If existingDuration > 0 and not from override, it came from GetAbilityDuration - don't learn from game API
                -- Only learn if ZOS API doesn't have a hardcoded duration (existingDuration == 0)
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
    g_activeWeaponSwapInProgress = false
    ActionBar.UpdateBackbarUniqueState(g_hotbarCategory)
    if not ActionBar.IsPlayerHotbarCategory(g_hotbarCategory) then
        return
    end
    if g_potionUsed == true then
        return
    end

    ActionBar.UpdateUltimateLabel()

    for i = ActionBar.GetBarIndexStart(), ActionBar.GetBarIndexEnd() do
        ActionBar.BarSlotUpdate(i, true, false)
    end

    for i = (ActionBar.GetBarIndexStart() + ActionBar.GetBackbarIndexOffset()), (ActionBar.GetBackbarIndexEnd() + ActionBar.GetBackbarIndexOffset()) do
        local button = g_backbarButtons[i]
        ActionBar.SetupBackBarIcons(button, true)
        ActionBar.BarSlotUpdate(i, true, false)
    end

    -- Ensure backbar desaturation is applied after slot updates
    ActionBar.BackbarToggleSettings()
end

-- Runs on EVENT_PLAYER_ACTIVATED
local function OnPlayerActivated(eventCode)
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
    for slotNum = ActionBar.GetBarIndexStart(), ActionBar.GetBarIndexEnd() do
        if g_uiCustomToggle[slotNum] then
            g_uiCustomToggle[slotNum]:SetHidden(true)
        end
    end
    for slotNum = ActionBar.GetBarIndexStart() + ActionBar.GetBackbarIndexOffset(), ActionBar.GetBackbarIndexEnd() + ActionBar.GetBackbarIndexOffset() do
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
    zo_callLater(function ()
                     g_potionUsed = false
                 end, 200)
end

-- Runs on EVENT_GAMEPAD_PREFERRED_MODE_CHANGED
local function BackbarSetupTemplate(style)
    -- Validate that style is a valid constants table, not a number or other invalid type
    if not style or type(style) ~= "table" or not style.weaponSwapOffsetX then
        style = ActionBar.GetPlatformConstants()
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
    if cursorType == MOUSE_CONTENT_ACTION and ActionBar.GetAbilityDropValidators() and ActionBar.GetAbilityDropValidators()[actionType] then
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
-- EVENT REGISTRATION FUNCTION (ZOS Pattern)
-- ============================================================================

-- Clear and then (maybe) re-register event listeners
function ActionBar.RegisterEvents()
    if not ActionBar.Enabled then
        return
    end

    -- Initialize cached references on first call
    if not g_barFakeAura then
        InitializeCachedReferences()
    end

    -- Update module-level references that may have changed
    g_hotbarCategory = ActionBar.GetHotbarCategory()
    g_ultimateSlot = ActionBar.GetUltimateSlot()
    g_ultimateCost = ActionBar.GetUltimateCost()
    g_ultimateCurrent = ActionBar.GetUltimateCurrent()
    g_companionUltimateCost = ActionBar.GetCompanionUltimateCost()
    g_companionUltimateCurrent = ActionBar.GetCompanionUltimateCurrent()
    g_companionUltimateButton = ActionBar.GetCompanionUltimateButton()
    g_backbarButtons = ActionBar.GetBackbarButtons()
    g_uiProcAnimation = ActionBar.GetUiProcAnimation()
    g_potionUsed = ActionBar.GetPotionUsed()
    g_activeWeaponSwapInProgress = ActionBar.GetActiveWeaponSwapInProgress()
    g_actionBarActiveWeaponPair = ActionBar.GetActionBarActiveWeaponPair()
    uiQuickSlot = ActionBar.GetQuickSlotState()
    g_backbarUniqueHidden = ActionBar.GetBackbarUniqueHidden()

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
