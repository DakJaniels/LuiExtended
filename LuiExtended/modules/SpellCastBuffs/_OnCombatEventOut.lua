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

-- Combat Event (Source = Player)
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
function SpellCastBuffs.OnCombatEventOut(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    SpellCastBuffs.RecordCombatDamageType(abilityId, result, damageType)

    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    if SpellCastBuffs.SV.BlacklistTable[abilityId] or SpellCastBuffs.SV.BlacklistTable[abilityName] then
        return
    end

    -- Player damage spends one hit-counted charge (Crystal Weapon first hit 143804, later hits 181056).
    -- These ids are not fake auras, so this runs before that return. A critical hit is still a spent charge.
    if not isError
    and sourceType == COMBAT_UNIT_TYPE_PLAYER
    and (result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE) then
        SpellCastBuffs.SpendChargeStackOnDamage(abilityId)
    end

    if not (Effects.FakePlayerOfflineAura[abilityId] or Effects.FakePlayerDebuffs[abilityId] or Effects.FakeStagger[abilityId] or Effects.IsGroundMineDamage[abilityId]) then
        return
    end

    SpellCastBuffs.HandleOutgoingGroundMineTrapBeast(result, abilityId, sourceType)

    if not SpellCastBuffs.IsAuraLifecycleCombatResult(result) then
        return
    end

    local unbreakable
    local stack
    local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false

    if Effects.EffectOverride[abilityId] then
        if Effects.EffectOverride[abilityId].hideReduce and SpellCastBuffs.SV.HideReduce then
            return
        end
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stack = Effects.EffectOverride[abilityId].stack or 0
    else
        unbreakable = 0
        stack = 0
    end

    SpellCastBuffs.HandleOutgoingFakePlayerOfflineAura(result, abilityId, sourceType, sourceName, unbreakable, stack, groundLabel)
    SpellCastBuffs.HandleOutgoingFakePlayerDebuff(result, abilityId, sourceType, targetType, sourceName, targetName, unbreakable, groundLabel)
    SpellCastBuffs.HandleOutgoingFakeStagger(result, abilityId, sourceName, targetName, unbreakable, groundLabel)
end
