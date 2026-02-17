-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local UI = LUIE.UI
local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type Effects
local Effects = Data.Effects
local Abilities = Data.Abilities
local Tooltips = Data.Tooltips
local string_format = string.format
local printToChat = LUIE.PrintToChat
local zo_strformat = zo_strformat
local table_insert = table.insert
local table_sort = table.sort
-- local displayName = GetDisplayName()
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()

local moduleName = SpellCastBuffs.moduleName

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

-- Runs on the EVENT_EFFECT_CHANGED listener.
-- This handler fires every long-term effect added or removed
--- @param eventId integer
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
function SpellCastBuffs.OnEffectChanged(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
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
    if not (SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[effectName] or SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName]) then
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

    -- Override name, icon, or hide based on MapZoneIndex
    if Effects.ZoneDataOverride[abilityId] then
        local index = GetZoneId(GetCurrentMapZoneIndex())
        local zoneName = GetPlayerLocationName()
        if Effects.ZoneDataOverride[abilityId][index] then
            if Effects.ZoneDataOverride[abilityId][index].icon then
                iconName = Effects.ZoneDataOverride[abilityId][index].icon
            end
            if Effects.ZoneDataOverride[abilityId][index].name then
                effectName = Effects.ZoneDataOverride[abilityId][index].name
            end
            if Effects.ZoneDataOverride[abilityId][index].hide then
                return
            end
        end
        if Effects.ZoneDataOverride[abilityId][zoneName] then
            if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                iconName = Effects.ZoneDataOverride[abilityId][zoneName].icon
            end
            if Effects.ZoneDataOverride[abilityId][zoneName].name then
                effectName = Effects.ZoneDataOverride[abilityId][zoneName].name
            end
            if Effects.ZoneDataOverride[abilityId][zoneName].hide then
                return
            end
        end
    end

    -- Override name, icon, or hide based on Map Name
    if Effects.MapDataOverride[abilityId] then
        local mapName = GetMapName()
        if Effects.MapDataOverride[abilityId][mapName] then
            if Effects.MapDataOverride[abilityId][mapName].icon then
                iconName = Effects.MapDataOverride[abilityId][mapName].icon
            end
            if Effects.MapDataOverride[abilityId][mapName].name then
                effectName = Effects.MapDataOverride[abilityId][mapName].name
            end
            if Effects.MapDataOverride[abilityId][mapName].hide then
                return
            end
        end
    end

    -- Override name or icon based off unitName
    if Effects.EffectOverrideByName[abilityId] then
        unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, unitName)
        if Effects.EffectOverrideByName[abilityId][unitName] then
            if Effects.EffectOverrideByName[abilityId][unitName].hide then
                return
            end
            iconName = Effects.EffectOverrideByName[abilityId][unitName].icon or iconName
            effectName = Effects.EffectOverrideByName[abilityId][unitName].name or effectName
        end
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

    -- Override for Off-Balance Immunity to show it as a prominent debuff for tracking.
    if abilityId == 134599 or abilityId == 120014 then
        if context == "reticleover1" or context == "reticleover2" then
            if SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[effectName] then
                context = "promd_target"
            end
        elseif context == "player1" then
            if SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName] then
                context = "promb_player"
            end
        end
    else
        -- Special handling for Bound Armaments - only show in prominent buffs if stack count >= 4
        if abilityId == 203447 and stackCount < 4 then
            -- Force context to be non-prominent if stacks are too low
            if context == "promb_player" then
                context = "player1"
            end
        end
        context = SpellCastBuffs.DetermineContext(context, abilityId, effectName, sourceType)
    end

    -- Exit here if there is no container to hold this effect
    if not SpellCastBuffs.containerRouting[context] then
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        -- delete Effect
        SpellCastBuffs.EffectsList[context][effectSlot] = nil
        if Effects.EffectCreateSkillAura[abilityId] and Effects.EffectCreateSkillAura[abilityId].removeOnEnd then
            local id = Effects.EffectCreateSkillAura[abilityId].abilityId

            local name = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
            local fakeEffectType = Effects.EffectOverride[id] and Effects.EffectOverride[id].type or effectType
            if not (SpellCastBuffs.SV.BlacklistTable[name] or SpellCastBuffs.SV.BlacklistTable[id]) then
                local simulatedContext = unitTag .. fakeEffectType
                simulatedContext = SpellCastBuffs.DetermineContext(simulatedContext, id, name, sourceType)
                SpellCastBuffs.EffectsList[simulatedContext][Effects.EffectCreateSkillAura[abilityId].abilityId] = nil
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
                local name = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetAbilityName(id))
                local fakeEffectType = Effects.EffectOverride[id] and Effects.EffectOverride[id].type or effectType
                local fakeUnbreakable = Effects.EffectOverride[id] and Effects.EffectOverride[id].unbreakable or 0
                if not (SpellCastBuffs.SV.BlacklistTable[name] or SpellCastBuffs.SV.BlacklistTable[id]) then
                    local simulatedContext = unitTag .. fakeEffectType
                    simulatedContext = SpellCastBuffs.DetermineContext(simulatedContext, id, name, sourceType)

                    -- Create Buff
                    local icon = Effects.EffectCreateSkillAura[abilityId].icon or GetAbilityIcon(id)
                    SpellCastBuffs.EffectsList[simulatedContext][Effects.EffectCreateSkillAura[abilityId].abilityId] =
                    {
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
        SpellCastBuffs.EffectsList[context][effectSlot] =
        {
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
        }
    end
end
