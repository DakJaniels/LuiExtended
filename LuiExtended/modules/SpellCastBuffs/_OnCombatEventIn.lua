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

-- Combat Event (Target = Player)
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
function SpellCastBuffs.OnCombatEventIn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    SpellCastBuffs.RecordCombatDamageType(abilityId, result, damageType)

    if not (Effects.FakeExternalBuffs[abilityId] or Effects.FakeExternalDebuffs[abilityId] or Effects.FakePlayerBuffs[abilityId] or Effects.FakeStagger[abilityId] or Effects.AddGroundDamageAura[abilityId]) then
        return
    end

    if SpellCastBuffs.SV.BlacklistTable[abilityId] or SpellCastBuffs.SV.BlacklistTable[abilityName] then
        return
    end

    SpellCastBuffs.HandleIncomingGroundDamageAura(result, abilityId, abilityName, sourceName)
    SpellCastBuffs.HandleIncomingCrystallizedShield(result, abilityId)

    if not SpellCastBuffs.IsAuraLifecycleCombatResult(result) then
        return
    end

    if SpellCastBuffs.ignoreAbilityId[abilityId] then
        SpellCastBuffs.ignoreAbilityId[abilityId] = nil
        return
    end

    local unbreakable
    local stack
    local internalStack
    local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false

    if Effects.EffectOverride[abilityId] then
        if Effects.EffectOverride[abilityId].hideReduce and SpellCastBuffs.SV.HideReduce then
            return
        end
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stack = Effects.EffectOverride[abilityId].stack or 0
        internalStack = Effects.EffectOverride[abilityId].internalStack or nil
    else
        unbreakable = 0
        stack = 0
        internalStack = nil
    end

    SpellCastBuffs.HandleIncomingFakeExternalBuff(result, abilityId, sourceName, sourceType, targetName, targetType, unbreakable, groundLabel)
    SpellCastBuffs.HandleIncomingFakeExternalDebuff(result, abilityId, sourceName, sourceType, targetName, targetType, unbreakable, stack, internalStack, groundLabel)
    SpellCastBuffs.HandleIncomingFakePlayerBuff(result, abilityId, sourceName, sourceType, targetName, targetType, unbreakable, stack, groundLabel)
    SpellCastBuffs.HandleIncomingFakeStagger(result, abilityId, sourceName, targetName, unbreakable, groundLabel)
end
