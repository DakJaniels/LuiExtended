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

-- Runs on the EVENT_EFFECT_CHANGED listener.
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
SpellCastBuffs.OnEffectChangedGround = function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if SpellCastBuffs.SV.HideGroundEffects then
        return
    end

    -- Ensure all necessary contexts are initialized
    for context, _ in pairs(SpellCastBuffs.containerRouting) do
        if not SpellCastBuffs.EffectsList[context] then
            SpellCastBuffs.EffectsList[context] = {}
        end
    end

    -- Mines with multiple auras have to be linked into one id for the purpose of tracking stacks
    if Effects.LinkedGroundMine[abilityId] then
        abilityId = Effects.LinkedGroundMine[abilityId]
    end

    -- Bail out if this ability is blacklisted
    if SpellCastBuffs.SV.BlacklistTable[abilityId] or SpellCastBuffs.SV.BlacklistTable[effectName] then
        return
    end

    -- Create fake ground aura
    local groundType = {}
    groundType[1] =
    {
        info = Effects.EffectGroundDisplay[abilityId].buff,
        context = "player1",
        promB = "promb_player",
        promD = "promd_player",
        type = BUFF_EFFECT_TYPE_BUFF,
    }
    groundType[2] =
    {
        info = Effects.EffectGroundDisplay[abilityId].debuff,
        context = "player2",
        promB = "promb_target",
        promD = "promd_target",
        type = BUFF_EFFECT_TYPE_DEBUFF,
    }
    groundType[3] =
    {
        info = Effects.EffectGroundDisplay[abilityId].ground,
        context = "ground",
        promB = "promb_ground",
        promD = "promd_ground",
        type = BUFF_EFFECT_TYPE_DEBUFF,
    }

    if changeType == EFFECT_RESULT_FADED then
        if Effects.EffectGroundDisplay[abilityId] and Effects.EffectGroundDisplay[abilityId].noRemove then
            return
        end -- Ignore some abilities
        local currentTimeMs = GetFrameTimeMilliseconds()
        if not SpellCastBuffs.protectAbilityRemoval[abilityId] or SpellCastBuffs.protectAbilityRemoval[abilityId] < currentTimeMs then
            for i = 1, 3 do
                if groundType[i].info == true then
                    -- Set container context
                    local context
                    if SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[effectName] then
                        context = groundType[i].promD
                    elseif SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName] then
                        context = groundType[i].promB
                    else
                        context = groundType[i].context
                    end
                    if Effects.IsGroundMineAura[abilityId] or Effects.IsGroundMineStack[abilityId] then
                        -- Check to make sure aura exists in case of reloadUI
                        if SpellCastBuffs.EffectsList[context][abilityId] then
                            SpellCastBuffs.EffectsList[context][abilityId].stack = SpellCastBuffs.EffectsList[context][abilityId].stack - Effects.EffectGroundDisplay[abilityId].stackRemove
                            if SpellCastBuffs.EffectsList[context][abilityId].stack == 0 then
                                SpellCastBuffs.EffectsList[context][abilityId] = nil
                            end
                        end
                    else
                        SpellCastBuffs.EffectsList[context][abilityId] = nil
                    end
                end
            end
        end
    elseif changeType == EFFECT_RESULT_GAINED then
        local currentTimeMs = GetFrameTimeMilliseconds()
        SpellCastBuffs.protectAbilityRemoval[abilityId] = currentTimeMs + 150

        local duration = endTime - beginTime
        local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false
        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false
        iconName = Effects.EffectGroundDisplay[abilityId].icon or iconName
        effectName = Effects.EffectGroundDisplay[abilityId].name or effectName

        for i = 1, 3 do
            if groundType[i].info == true then
                -- Set container context
                local context
                if SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[effectName] then
                    context = groundType[i].promD
                elseif SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName] then
                    context = groundType[i].promB
                else
                    context = groundType[i].context
                end
                if Effects.IsGroundMineAura[abilityId] then
                    stackCount = Effects.EffectGroundDisplay[abilityId].stackReset
                    if Effects.HideGroundMineStacks[abilityId] then
                        stackCount = 0
                    end
                elseif Effects.IsGroundMineStack[abilityId] then
                    if SpellCastBuffs.EffectsList[context][abilityId] then
                        stackCount = SpellCastBuffs.EffectsList[context][abilityId].stack + Effects.EffectGroundDisplay[abilityId].stackRemove
                    else
                        stackCount = 1
                    end
                    if stackCount > Effects.EffectGroundDisplay[abilityId].stackReset then
                        stackCount = Effects.EffectGroundDisplay[abilityId].stackReset
                    end
                end

                SpellCastBuffs.EffectsList[context][abilityId] =
                {
                    target = SpellCastBuffs.DetermineTarget(context),
                    type = groundType[i].type,
                    id = abilityId,
                    name = effectName,
                    icon = iconName,
                    dur = 1000 * duration,
                    starts = 1000 * beginTime,
                    ends = (duration > 0) and (1000 * endTime) or nil,
                    forced = nil,
                    restart = true,
                    iconNum = 0,
                    unbreakable = 0,
                    stack = stackCount,
                    buffSlot = effectSlot,
                    groundLabel = groundLabel,
                    toggle = toggle,
                }
            end
        end
    end
end
