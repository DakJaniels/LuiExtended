-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type Effects
local Effects = Data.Effects
local zo_strformat = zo_strformat

--- @type table<number, string>
local oakensoul = Effects.IsOakenSoul

--- @return boolean
local function OakensoulEquipped()
    if GetItemLinkItemId(GetItemLink(BAG_WORN, 11, LINK_STYLE_DEFAULT)) == 187658 or GetItemLinkItemId(GetItemLink(BAG_WORN, 12, LINK_STYLE_DEFAULT)) == 187658 then
        return true
    end
    return false
end

--- @param buffId number
--- @return boolean
local function IsOakensoul(buffId)
    if OakensoulEquipped() then
        for id in pairs(oakensoul) do
            if buffId == id then
                return true
            end
        end
    end
    return false
end

--- @param unitTag string
--- @param stackBuffId integer
--- @return integer|nil
local function ReadPlayerBuffStacks(unitTag, stackBuffId)
    if unitTag ~= "player" or not DoesUnitExist(unitTag) then
        return nil
    end
    for i = 1, GetNumBuffs(unitTag) do
        local _, _, _, _, buffStacks, _, _, _, _, _, abilityIdNew, _, castByPlayer = GetUnitBuffInfo(unitTag, i)
        if abilityIdNew == stackBuffId and castByPlayer and buffStacks and buffStacks > 0 then
            local maxStack = Effects.BarHighlightStack and Effects.BarHighlightStack[stackBuffId]
            if maxStack and buffStacks > maxStack then
                return maxStack
            end
            return buffStacks
        end
    end
    return nil
end

--- @param unitTag string
--- @param displayAbilityId integer
--- @param stackCount integer|nil
local function PushStacksToDisplayedBuff(unitTag, displayAbilityId, stackCount)
    if unitTag ~= "player" then
        return
    end
    local stacks = stackCount
    if stacks == nil or stacks <= 0 then
        stacks = nil
    end
    for _, effectsList in pairs(SpellCastBuffs.EffectsList) do
        for _, v in pairs(effectsList) do
            if v.id == displayAbilityId then
                v.stack = stacks
            end
        end
    end
    SpellCastBuffs.MarkDisplayDirty()
end

-- Runs on the EVENT_EFFECT_CHANGED listener.
-- This handler fires every long-term effect added or removed
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
function SpellCastBuffs.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    -- Change the effect type / name before we determine if we want to filter anything else.
    if Effects.EffectOverride[abilityId] then
        effectName = Effects.EffectOverride[abilityId].name or effectName
        effectType = Effects.EffectOverride[abilityId].type or effectType
        -- Bail out now if we hide ground snares and other effects because we are showing Damaging Auras (Only do this for the player, we don't want effects on targets to stop showing up).
        if Effects.EffectOverride[abilityId].hideGround and SpellCastBuffs.SV.GroundDamageAura and unitTag == "player" then
            return
        end
    end

    -- Bail out if the abilityId is on the Blacklist Table
    if SpellCastBuffs.SV.BlacklistTable[abilityId] then
        return
    end

    -- Bail out if this is an effect from Oakensoul
    if (SpellCastBuffs.SV.HideOakenSoul == true) and IsOakensoul(abilityId) and unitTag == "player" then
        return
    end

    -- Sneak / stealth unit buffs use live ids 20299 or 20309; synthetic rows from EVENT_STEALTH_STATE_CHANGED use 20309 — skip duplicate slot-keyed buff
    local stealthEffectsTracked = (unitTag == "player" and SpellCastBuffs.SV.StealthStatePlayer)
        or (unitTag == "reticleover" and SpellCastBuffs.SV.StealthStateTarget)
    if stealthEffectsTracked and (abilityId == 20299 or abilityId == 20309) then
        return
    end

    -- Hide effects if chosen in the options menu
    if SpellCastBuffs.hidePlayerEffects[abilityId] and unitTag == "player" then
        return
    end

    if SpellCastBuffs.hideTargetEffects[abilityId] and unitTag == "reticleover" then
        return
    end

    -- If the source of the buff isn't the player or the buff is not on the AbilityId or AbilityName override list then we don't display it
    if unitTag ~= "player" then
        if effectType == BUFF_EFFECT_TYPE_DEBUFF and not (sourceType == COMBAT_UNIT_TYPE_PLAYER) and not (SpellCastBuffs.debuffDisplayOverrideId[abilityId] or Effects.DebuffDisplayOverrideName[effectName]) then
            return
        end
    end

    -- Ignore Siphoner on non-player targets
    if abilityId == 92428 and unitTag == "reticleover" and not IsUnitPlayer("reticleover") then
        return
    end

    -- If this effect isn't a prominent buff or debuff and we have certain buffs set to hidden - then hide those.
    if not (SpellCastBuffs.WantsProminentDebuff(abilityId, effectName) or SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName]) then
        if SpellCastBuffs.SV.HidePlayerBuffs and effectType == BUFF_EFFECT_TYPE_BUFF and unitTag == "player" then
            return
        end
        if SpellCastBuffs.SV.HidePlayerDebuffs and effectType == BUFF_EFFECT_TYPE_DEBUFF and unitTag == "player" then
            return
        end
        if SpellCastBuffs.SV.HideTargetBuffs and effectType == BUFF_EFFECT_TYPE_BUFF and unitTag ~= "player" then
            return
        end
        if SpellCastBuffs.SV.HideTargetDebuffs and effectType == BUFF_EFFECT_TYPE_DEBUFF and unitTag ~= "player" then
            return
        end
    end

    -- If this is a set ICD then don't display if we have Set ICD's disabled.
    if Effects.IsSetICD[abilityId] and SpellCastBuffs.SV.IgnoreSetICDPlayer then
        return
    end
    -- If this is an ability ICD then don't display if we have Ability ICD's disabled.
    if Effects.IsAbilityICD[abilityId] and SpellCastBuffs.SV.IgnoreAbilityICDPlayer then
        return
    end

    local unbreakable = 0

    -- Set Override data from Effects.lua
    if Effects.EffectOverride[abilityId] then
        if Effects.EffectOverride[abilityId].hide == true then
            local displayId = Effects.EffectPushStacksFromHidden and Effects.EffectPushStacksFromHidden[abilityId]
            if displayId then
                if changeType == EFFECT_RESULT_FADED then
                    PushStacksToDisplayedBuff(unitTag, displayId, nil)
                else
                    local pulled = ReadPlayerBuffStacks(unitTag, abilityId) or stackCount
                    PushStacksToDisplayedBuff(unitTag, displayId, pulled)
                end
            end
            return
        end
        if Effects.EffectOverride[abilityId].hideReduce == true and SpellCastBuffs.SV.HideReduce then
            return
        end
        if Effects.EffectOverride[abilityId].isDisguise and SpellCastBuffs.SV.IgnoreDisguise then
            -- For Monk's Disguise / other buff based Disguise hiding.
            return
        end
        iconName = Effects.EffectOverride[abilityId].icon or iconName
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stackCount = Effects.EffectOverride[abilityId].stack or stackCount
        local stackSourceId = Effects.EffectPullStacks and Effects.EffectPullStacks[abilityId]
        if stackSourceId then
            local pulledStacks = ReadPlayerBuffStacks(unitTag, stackSourceId)
            if pulledStacks then
                stackCount = pulledStacks
            end
        end
        -- Destroy other effects of the same type if we don't want to show duplicates at all.
        if Effects.EffectOverride[abilityId].noDuplicate then
            for context, effectsList in pairs(SpellCastBuffs.EffectsList) do
                for k, v in pairs(effectsList) do
                    -- Only remove the lower duration effects that were cast previously or simultaneously.
                    if v.id == abilityId and v.ends <= (1000 * endTime) then
                        SpellCastBuffs.EffectsList[context][k] = nil
                    end
                end
            end
        end
        -- Bail out if this effect should only appear on Refresh
        if Effects.EffectOverride[abilityId].refreshOnly then
            if changeType ~= EFFECT_RESULT_UPDATED and changeType ~= EFFECT_RESULT_FULL_REFRESH and changeType ~= EFFECT_RESULT_FADED then
                return
            end
        end
    end

    -- Bail out if the effectName is hidden in the Blacklist Table
    if SpellCastBuffs.SV.BlacklistTable[effectName] then
        return
    end

    -- Override name, icon, or hide based on MapZoneIndex / map name
    local hide
    iconName, effectName, hide = SpellCastBuffs.ApplyZoneAndMapEffectOverrides(abilityId, iconName, effectName)
    if hide then
        return
    end

    iconName, effectName, hide = SpellCastBuffs.ApplyEffectOverrideByNameForUnit(abilityId, unitName, iconName, effectName)
    if hide then
        return
    end

    -- Override icon with default if enabled
    if SpellCastBuffs.SV.UseDefaultIcon and SpellCastBuffs.ShouldUseDefaultIcon(abilityId) == true then
        iconName = SpellCastBuffs.GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
    end

    local forcedType = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].forcedContainer or nil
    local savedEffectSlot = effectSlot
    effectSlot = Effects.EffectMergeId[abilityId] or Effects.EffectMergeName[effectName] or effectSlot

    -- Where the new icon will go into
    local context = unitTag .. effectType

    -- Special handling for Bound Armaments - only show in prominent buffs if stack count >= 4
    if abilityId == 203447 and stackCount < 4 then
        -- Force context to be non-prominent if stacks are too low
        if context == "promb_player" then
            context = "player1"
        end
    end

    -- DetermineContext routes prominent buffs/debuffs and uses the OB-aware
    -- helper so Off Balance debuffs (and the Immunity buff) promote to the
    -- target prominent container regardless of who applied them.
    context = SpellCastBuffs.DetermineContext(context, abilityId, effectName, sourceType)

    -- Exit here if there is no container to hold this effect
    if not SpellCastBuffs.containerRouting[context] then
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        -- delete Effect
        local nativeUid = SpellCastBuffs.GetEffectUidNative(effectSlot)
        SpellCastBuffs.EffectsList[context][nativeUid] = nil
        if Effects.EffectCreateSkillAura[abilityId] and Effects.EffectCreateSkillAura[abilityId].removeOnEnd then
            local id = Effects.EffectCreateSkillAura[abilityId].abilityId

            local name = zo_strformat("<<C:1>>", GetAbilityName(id))
            local fakeEffectType = Effects.EffectOverride[id] and Effects.EffectOverride[id].type or effectType
            if not (SpellCastBuffs.SV.BlacklistTable[name] or SpellCastBuffs.SV.BlacklistTable[id]) then
                local simulatedContext = unitTag .. fakeEffectType
                simulatedContext = SpellCastBuffs.DetermineContext(simulatedContext, id, name, sourceType)
                SpellCastBuffs.ClearFakeEffectEntry(simulatedContext, id)
            end
        end

        -- Create Effect
    else
        local duration = endTime - beginTime
        local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false
        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

        if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].duration then
            if Effects.EffectOverride[abilityId].duration == 0 then
                duration = 0
            else
                duration = duration - Effects.EffectOverride[abilityId].duration
            end
            endTime = endTime - Effects.EffectOverride[abilityId].duration
        end

        if Effects.EffectPullDuration[abilityId] then
            local matchId = Effects.EffectPullDuration[abilityId]
            for i = 1, GetNumBuffs(unitTag) do
                local unitBuffInfo = { GetUnitBuffInfo(unitTag, i) }
                local timeStarted = unitBuffInfo[2]
                local timeEnding = unitBuffInfo[3]
                abilityId = unitBuffInfo[11]
                if abilityId == matchId then
                    duration = timeEnding - timeStarted
                    beginTime = timeStarted
                    endTime = timeEnding
                end
            end
        end

        -- EffectCreateSkillAura
        if Effects.EffectCreateSkillAura[abilityId] then
            if not Effects.EffectCreateSkillAura[abilityId].requiredStack or (Effects.EffectCreateSkillAura[abilityId].requiredStack and stackCount == Effects.EffectCreateSkillAura[abilityId].requiredStack) then
                local id = Effects.EffectCreateSkillAura[abilityId].abilityId
                local name = zo_strformat("<<C:1>>", GetAbilityName(id))
                local fakeEffectType = Effects.EffectOverride[id] and Effects.EffectOverride[id].type or effectType
                local fakeUnbreakable = Effects.EffectOverride[id] and Effects.EffectOverride[id].unbreakable or 0
                if not (SpellCastBuffs.SV.BlacklistTable[name] or SpellCastBuffs.SV.BlacklistTable[id]) then
                    local simulatedContext = unitTag .. fakeEffectType
                    simulatedContext = SpellCastBuffs.DetermineContext(simulatedContext, id, name, sourceType)

                    -- Create Buff
                    if not SpellCastBuffs.UnitHasBuffAbilityId(unitTag, id) then
                        local icon = Effects.EffectCreateSkillAura[abilityId].icon or GetAbilityIcon(id)
                        local auraUid = SpellCastBuffs.GetEffectUidFake(id)
                        SpellCastBuffs.EffectsList[simulatedContext][auraUid] =
                        {
                            uid = auraUid,
                            target = SpellCastBuffs.DetermineTarget(simulatedContext),
                            type = fakeEffectType,
                            id = id,
                            name = name,
                            icon = icon,
                            dur = 1000 * duration,
                            starts = 1000 * beginTime,
                            ends = (duration > 0) and (1000 * endTime) or nil,
                            forced = forcedType,
                            restart = true,
                            iconNum = 0,
                            stack = 0,
                            unbreakable = fakeUnbreakable,
                            groundLabel = groundLabel,
                            toggle = toggle,
                        }
                    end
                end
            end
        end

        -- If this effect doesn't properly display stacks - then add them.
        if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].displayStacks then
            for _, effectsList in pairs(SpellCastBuffs.EffectsList) do
                for _, v in pairs(effectsList) do
                    -- Add stacks
                    if v.id == abilityId then
                        stackCount = v.stack + 1
                        -- Stop stacks from going over a certain amount.
                        if stackCount > Effects.EffectOverride[abilityId].maxStacks then
                            stackCount = Effects.EffectOverride[abilityId].maxStacks
                        end
                    end
                end
            end
        end

        -- Limit stacks for certain abilities.
        if Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackMax then
            if stackCount > Effects.EffectOverride[abilityId].stackMax then
                stackCount = Effects.EffectOverride[abilityId].stackMax
            end
        end

        -- Buffs are created based on their effectSlot, this allows multiple buffs/debuffs of the same type to appear.
        local nativeUid = SpellCastBuffs.GetEffectUidNative(effectSlot)
        SpellCastBuffs.EffectsList[context][nativeUid] =
        {
            uid = nativeUid,
            target = SpellCastBuffs.DetermineTarget(context),
            type = effectType,
            id = abilityId,
            name = effectName,
            icon = iconName,
            dur = 1000 * duration,
            starts = 1000 * beginTime,
            ends = (duration > 0) and (1000 * endTime) or nil,
            forced = forcedType,
            restart = true,
            iconNum = 0,
            stack = stackCount,
            unbreakable = unbreakable,
            buffSlot = savedEffectSlot,
            groundLabel = groundLabel,
            toggle = toggle,
            debugMeta = SpellCastBuffs.BuildEffectDebugMeta(abilityType, statusEffectType, savedEffectSlot, sourceType, unitTag,
                                                            SpellCastBuffs.SnapshotLiveBuffDebugOverlay(
                                                                unitTag, abilityId, savedEffectSlot, beginTime, endTime, stackCount, effectType, iconName)),
        }
        SpellCastBuffs.RemoveSyntheticEffectsForAbilityId(context, abilityId, nativeUid)
        if unitTag == "reticleover" or unitTag == "player" then
            SpellCastBuffs.RemoveDuplicateEffectsInSharedContainer(context, abilityId, nativeUid)
        end
    end
    SpellCastBuffs.MarkDisplayDirty()
end
