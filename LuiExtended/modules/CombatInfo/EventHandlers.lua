-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Castbar = Data.CastBarTable
local OtherAddonCompatability = LUIE.OtherAddonCompatability

--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo

--- @class (partial) EventHandlers
local EventHandlers = {}
EventHandlers.__index = EventHandlers
CombatInfo.EventHandlers = EventHandlers

local pairs = pairs
local timeMs = GetFrameTimeMilliseconds

--- @class (partial) ActionBar
local ActionBar = CombatInfo.ActionBar

-- Cache ActionBar table references at module level to avoid repeated getter calls
local g_barFakeAura = ActionBar.GetBarFakeAura()
local g_toggledSlotsPlayer = ActionBar.GetToggledSlotsPlayer()
local g_toggledSlotsRemain = ActionBar.GetToggledSlotsRemain()
local g_toggledSlotsFront = ActionBar.GetToggledSlotsFront()
local g_toggledSlotsBack = ActionBar.GetToggledSlotsBack()
local g_toggledSlotsStack = ActionBar.GetToggledSlotsStack()
local g_uiCustomToggle = ActionBar.GetUiCustomToggle()
local g_barNoRemove = ActionBar.GetBarNoRemove()
local g_protectAbilityRemoval = ActionBar.GetProtectAbilityRemoval()
local g_mineStacks = ActionBar.GetMineStacks()
local g_mineNoTurnOff = ActionBar.GetMineNoTurnOff()
local g_ProcSound = ActionBar.GetProcSound()
local g_boundArmamentsPlayed = ActionBar.GetBoundArmamentsPlayed()
local g_triggeredSlotsRemain = ActionBar.GetTriggeredSlotsRemain()
local g_triggeredSlotsFront = ActionBar.GetTriggeredSlotsFront()
local g_triggeredSlotsBack = ActionBar.GetTriggeredSlotsBack()
local g_barDurationOverride = ActionBar.GetBarDurationOverride()
local uiUltimate = ActionBar.GetUltimateState()

-- Cache addon compatibility check (checked once at load, never changes)
local isFancyActionBarEnabled = OtherAddonCompatability.isFancyActionBarPlusEnabled or LUIE.IsItEnabled("FancyActionBar\43") or LUIE.IsItEnabled("FancyActionBar")

-- Function to refresh cached references (called when ActionBar reinitializes tables)
function EventHandlers.RefreshCachedReferences()
    g_barDurationOverride = ActionBar.GetBarDurationOverride()
end

-- ===== EVENT HANDLERS =====

-- Runs on the `EVENT_TARGET_CHANGE` listener
--- @param eventCode integer
--- @param unitTag string
function EventHandlers.OnTargetChange(eventCode, unitTag)
    EventHandlers.OnReticleTargetChanged(eventCode)
end

-- Runs on the `EVENT_RETICLE_TARGET_CHANGED` listener
--- @param eventCode integer
function EventHandlers.OnReticleTargetChanged(eventCode)
    for k, _ in pairs(g_toggledSlotsRemain) do
        local frontSlot = g_toggledSlotsFront[k]
        local backSlot = g_toggledSlotsBack[k]

        if  ((frontSlot and g_uiCustomToggle[frontSlot]) or (backSlot and g_uiCustomToggle[backSlot]))
        and not (g_toggledSlotsPlayer[k] or g_barNoRemove[k]) then
            if frontSlot and g_uiCustomToggle[frontSlot] then
                CombatInfo.HideSlot(frontSlot, k)
            end

            if backSlot and g_uiCustomToggle[backSlot] then
                CombatInfo.HideSlot(backSlot, k)
            end

            g_toggledSlotsRemain[k] = nil

            if Effects.BarHighlightCheckOnFade[k] then
                EventHandlers.BarHighlightSwap(k)
            end
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
                EventHandlers.OnEffectChanged(
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

-- Helper to get override ability duration
local function GetUpdatedAbilityDuration(abilityId)
    local dur = g_barDurationOverride[abilityId] or GetAbilityDuration(abilityId) or 0
    return dur
end

-- Handles bar highlight swap event
--- @param abilityId integer Ability ID
function EventHandlers.BarHighlightSwap(abilityId)
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
            EventHandlers.OnEffectChanged(nil, EFFECT_RESULT_GAINED, nil, nil, unitTag, timeStarted, timeEnding, 0, nil, nil, 1, ABILITY_TYPE_BONUS, 0, nil, nil, abilityId, 1, true, abilityId)
            return
        end

        if id ~= 0 then
            for j = 1, GetNumBuffs(unitTag) do
                local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityIdNew, canClickOff, castByPlayer = GetUnitBuffInfo(unitTag, j)
                if id == abilityIdNew and castByPlayer then
                    EventHandlers.OnEffectChanged(nil, EFFECT_RESULT_GAINED, nil, nil, unitTag, timeStarted, timeEnding, stackCount, nil, buffType, effectType, abilityType, statusEffectType, nil, nil, abilityId, 1, true, abilityIdNew)
                    return
                end
            end
        end
    end
end

-- Extra returns here - passThrough & savedId
--- Handles effect changed event
--- @param eventCode integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param buffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param castByPlayer CombatUnitType
--- @param passThrough boolean
--- @param savedId integer
function EventHandlers.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer, passThrough, savedId)
    if g_barFakeAura[abilityId] and not passThrough then
        return
    end
    if castByPlayer ~= COMBAT_UNIT_TYPE_PLAYER then
        return
    end

    if Effects.IsVamp[abilityId] and changeType == EFFECT_RESULT_GAINED then
        CombatInfo.UpdateUltimateLabel()
    end

    if Castbar.CastBreakOnRemoveEffect[abilityId] and changeType == EFFECT_RESULT_FADED then
        CombatInfo.StopCastBar()
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
                        g_mineStacks[abilityId] = g_mineStacks[abilityId] - Effects.EffectGroundDisplay[abilityId].stackRemove

                        if CombatInfo.SV.BarShowLabel then
                            if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                                if not Effects.HideGroundMineStacks[abilityId] then
                                    local slotNum = g_toggledSlotsFront[abilityId]
                                    if g_uiCustomToggle[slotNum] then
                                        if g_mineStacks[abilityId] > 0 then
                                            g_uiCustomToggle[slotNum].stack:SetText(g_mineStacks[abilityId])
                                        else
                                            g_uiCustomToggle[slotNum].stack:SetText("")
                                        end
                                    end
                                end
                            end
                            if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                                if not Effects.HideGroundMineStacks[abilityId] then
                                    local slotNum = g_toggledSlotsBack[abilityId]
                                    if g_uiCustomToggle[slotNum] then
                                        if g_mineStacks[abilityId] > 0 then
                                            g_uiCustomToggle[slotNum].stack:SetText(g_mineStacks[abilityId])
                                        else
                                            g_uiCustomToggle[slotNum].stack:SetText("")
                                        end
                                    end
                                end
                            end
                        end

                        if g_mineStacks[abilityId] == 0 and not g_mineNoTurnOff[abilityId] then
                            if g_toggledSlotsRemain[abilityId] then
                                if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                                    local slotNum = g_toggledSlotsFront[abilityId]
                                    CombatInfo.HideSlot(slotNum, abilityId)
                                end
                                if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                                    local slotNum = g_toggledSlotsBack[abilityId]
                                    CombatInfo.HideSlot(slotNum, abilityId)
                                end
                            end
                            g_toggledSlotsRemain[abilityId] = nil
                            g_toggledSlotsStack[abilityId] = nil
                            if Effects.BarHighlightCheckOnFade[abilityId] then
                                EventHandlers.BarHighlightSwap(abilityId)
                            end
                        end
                    end
                else
                    if g_barNoRemove[abilityId] then
                        return
                    end
                    if g_toggledSlotsRemain[abilityId] then
                        if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                            local slotNum = g_toggledSlotsFront[abilityId]
                            CombatInfo.HideSlot(slotNum, abilityId)
                        end
                        if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                            local slotNum = g_toggledSlotsBack[abilityId]
                            CombatInfo.HideSlot(slotNum, abilityId)
                        end
                    end
                    g_toggledSlotsRemain[abilityId] = nil
                    g_toggledSlotsStack[abilityId] = nil
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

            if CombatInfo.SV.ShowToggled then
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
                        CombatInfo.ShowSlot(slotNum, abilityId, currentTimeST, false)
                    end
                    if g_toggledSlotsBack[abilityId] then
                        local slotNum = g_toggledSlotsBack[abilityId]
                        CombatInfo.ShowSlot(slotNum, abilityId, currentTimeST, false)
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
                EventHandlers.BarHighlightSwap(abilityId)
            end
            return
        end

        if g_triggeredSlotsRemain[abilityId] then
            if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                local slotNum = g_toggledSlotsFront[abilityId]
                CombatInfo.HideSlot(slotNum, abilityId)
            end
            if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                local slotNum = g_toggledSlotsBack[abilityId]
                CombatInfo.HideSlot(slotNum, abilityId)
            end
            g_toggledSlotsRemain[abilityId] = nil
            g_toggledSlotsStack[abilityId] = nil
        end

        if Effects.BarHighlightCheckOnFade[abilityId] then
            EventHandlers.BarHighlightSwap(abilityId)
        end
    else
        if Effects.IsGrimFocus[abilityId] then
            if CombatInfo.SV.ShowTriggered and CombatInfo.SV.ProcEnableSound then
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
            if CombatInfo.SV.ShowTriggered and CombatInfo.SV.ProcEnableSound then
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
            if CombatInfo.SV.ShowTriggered then
                if CombatInfo.SV.ProcEnableSound and unitTag == "player" and g_triggeredSlotsFront[abilityId] then
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
            if CombatInfo.SV.ShowToggled then
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
                if g_toggledSlotsFront[abilityId] then
                    local slotNum = g_toggledSlotsFront[abilityId]
                    CombatInfo.ShowSlot(slotNum, abilityId, currentTimeMs, false)
                end
                if g_toggledSlotsBack[abilityId] then
                    local slotNum = g_toggledSlotsBack[abilityId]
                    CombatInfo.ShowSlot(slotNum, abilityId, currentTimeMs, false)
                end
            end
        end
    end
end

-- Listens to EVENT_COMBAT_EVENT
--- @param eventCode integer
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
function EventHandlers.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if CombatInfo.SV.UltimateGeneration and uiUltimate.NotFull and ((result == ACTION_RESULT_BLOCKED_DAMAGE and targetType == COMBAT_UNIT_TYPE_PLAYER) or (Effects.IsWeaponAttack[abilityName] and sourceType == COMBAT_UNIT_TYPE_PLAYER and targetName ~= "")) then
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
                    if Effects.BarHighlightCheckOnFade[compareId] then
                        EventHandlers.BarHighlightSwap(compareId)
                    end
                    return
                end
            end
        end
    end

    -- Delegate cast bar handling to CastBar module
    local CastBar = CombatInfo.CastBar
    if CastBar and CombatInfo.SV.CastBarEnable then
        CastBar.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    end
end

--- Handles combat event for ability bar UI updates
--- @param eventCode integer
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
function EventHandlers.OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
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
                if g_toggledSlotsFront[abilityId] then
                    local slotNum = g_toggledSlotsFront[abilityId]
                    if g_uiCustomToggle[slotNum] then
                        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
                            g_uiCustomToggle[slotNum].stack:SetText(g_toggledSlotsStack[abilityId])
                        else
                            g_uiCustomToggle[slotNum].stack:SetText("")
                        end
                    end
                end
                if g_toggledSlotsBack[abilityId] then
                    local slotNum = g_toggledSlotsBack[abilityId]
                    if g_uiCustomToggle[slotNum] then
                        if g_toggledSlotsStack[abilityId] and g_toggledSlotsStack[abilityId] > 0 then
                            g_uiCustomToggle[slotNum].stack:SetText(g_toggledSlotsStack[abilityId])
                        else
                            g_uiCustomToggle[slotNum].stack:SetText("")
                        end
                    end
                end
            end
        end
    end

    if result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
        local currentTimeMs = timeMs()
        if g_toggledSlotsFront[abilityId] or g_toggledSlotsBack[abilityId] then
            if CombatInfo.SV.ShowToggled then
                local duration = GetUpdatedAbilityDuration(abilityId)
                local endTime = currentTimeMs + duration
                g_toggledSlotsRemain[abilityId] = endTime
                if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
                    g_toggledSlotsStack[abilityId] = 3
                end
                if abilityId == 35750 or abilityId == 40382 or abilityId == 40372 then
                    g_toggledSlotsStack[abilityId] = 1
                end
                if g_toggledSlotsFront[abilityId] then
                    local slotNum = g_toggledSlotsFront[abilityId]
                    CombatInfo.ShowSlot(slotNum, abilityId, currentTimeMs, false)
                end
                if g_toggledSlotsBack[abilityId] then
                    local slotNum = g_toggledSlotsBack[abilityId]
                    CombatInfo.ShowSlot(slotNum, abilityId, currentTimeMs, false)
                end
            end
        end
    elseif result == ACTION_RESULT_EFFECT_FADED then
        if g_barNoRemove[abilityId] then
            if Effects.BarHighlightCheckOnFade[abilityId] then
                EventHandlers.BarHighlightSwap(abilityId)
            end
            return
        end

        if g_toggledSlotsRemain[abilityId] then
            if g_toggledSlotsFront[abilityId] and g_uiCustomToggle[g_toggledSlotsFront[abilityId]] then
                local slotNum = g_toggledSlotsFront[abilityId]
                CombatInfo.HideSlot(slotNum, abilityId)
            end
            if g_toggledSlotsBack[abilityId] and g_uiCustomToggle[g_toggledSlotsBack[abilityId]] then
                local slotNum = g_toggledSlotsBack[abilityId]
                CombatInfo.HideSlot(slotNum, abilityId)
            end
            g_toggledSlotsRemain[abilityId] = nil
            g_toggledSlotsStack[abilityId] = nil
        end
        if Effects.BarHighlightCheckOnFade[abilityId] and targetType == COMBAT_UNIT_TYPE_PLAYER then
            EventHandlers.BarHighlightSwap(abilityId)
        end
    end
end
