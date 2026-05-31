-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
local Abilities = Data.Abilities
local Effects = Data.Effects

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

---
--- True when the user has opted this ability into Prominent Debuffs, either by
--- id, by ability name, or by the canonical Off Balance name (so a single
--- "Off Balance" entry covers every renamed OB variant).
--- @param abilityId number|nil
--- @param abilityName string|nil
--- @return boolean
function SpellCastBuffs.WantsProminentDebuff(abilityId, abilityName)
    local promTable = SpellCastBuffs.SV.PromDebuffTable
    if abilityId and promTable[abilityId] then
        return true
    end
    if abilityName and promTable[abilityName] then
        return true
    end
    local obName = Abilities.Skill_Off_Balance
    if obName and promTable[obName] then
        if abilityId and SpellCastBuffs.offBalanceDebuffById[abilityId] then
            return true
        end
        if abilityId == Effects.OffBalanceImmunityAbilityId then
            return true
        end
    end
    return false
end

---
--- Off Balance is special: unlike other prominent debuffs it must promote on
--- the target even when an ally applied it, and the Immunity buff must promote
--- from the target *buff* context. Returns the promoted context string, or nil
--- when the ability is not OB-related / not opted in (caller falls back to the
--- normal DetermineContext rules).
--- @param context SpellCastBuffsContext
--- @param abilityId number|nil
--- @param abilityName string|nil
--- @return string|nil context
function SpellCastBuffs.ResolveProminentDebuffContext(context, abilityId, abilityName)
    if not SpellCastBuffs.WantsProminentDebuff(abilityId, abilityName) then
        return nil
    end

    if abilityId and SpellCastBuffs.offBalanceDebuffById[abilityId] then
        if context == "reticleover2" then
            return "promd_target"
        elseif context == "player2" then
            return "promd_player"
        end
    elseif abilityId == Effects.OffBalanceImmunityAbilityId then
        if context == "reticleover1" or context == "reticleover2" then
            return "promd_target"
        elseif context == "player1" or context == "player2" then
            return "promd_player"
        end
    end
    return nil
end

---
--- Determines the container context for prominent effects based on the current context, ability, and caster.
--- @param context SpellCastBuffsContext The current context identifier (e.g., "player1", "reticleover2").
--- @param abilityId number|nil The ability ID to check for prominence (can be nil).
--- @param abilityName string|nil The ability name to check for prominence (can be nil).
--- @param castByPlayer number|nil The unit type of the caster (e.g., COMBAT_UNIT_TYPE_PLAYER, can be nil).
--- @return string context The resolved context string (e.g., "promd_player", "promb_target", or original context).
function SpellCastBuffs.DetermineContext(context, abilityId, abilityName, castByPlayer)
    local obContext = SpellCastBuffs.ResolveProminentDebuffContext(context, abilityId, abilityName)
    if obContext then
        return obContext
    end

    if SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[abilityName] then
        if context == "player1" then
            context = "promd_player"
        elseif context == "reticleover2" and castByPlayer == COMBAT_UNIT_TYPE_PLAYER then
            context = "promd_target"
        end
    elseif SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[abilityName] then
        if context == "player1" then
            context = "promb_player"
        elseif context == "reticleover2" and castByPlayer == COMBAT_UNIT_TYPE_PLAYER then
            context = "promb_target"
        end
    end
    return context
end

---
--- Determines the container context for prominent effects for player-only effects.
--- Used for effects that will never be a debuff cast by the player (e.g., disguise/stealth state, collectible buffs).
--- @param context SpellCastBuffsContext The current context identifier (should be "player1").
--- @param abilityId number|nil The ability ID to check for prominence (can be nil).
--- @param abilityName string|nil The ability name to check for prominence (can be nil).
--- @return string context The resolved context string (e.g., "promd_player", "promb_player", or original context).
function SpellCastBuffs.DetermineContextSimple(context, abilityId, abilityName)
    if context == "player1" then
        if SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[abilityName] then
            context = "promd_player"
        elseif SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[abilityName] then
            context = "promb_player"
        end
    end
    return context
end

---
--- Determines the target type for buff sorting based on the context string.
--- @param context SpellCastBuffsContext The context identifier (e.g., "player1", "reticleover1", "ground").
--- @return string|"player"|"reticleover"|"prominent" target The resolved target type: "player", "reticleover", or "prominent".
function SpellCastBuffs.DetermineTarget(context)
    if context == "player1" or context == "player2" then
        return "player"
    elseif context == "reticleover1" or context == "reticleover2" or context == "ground" or context == "saved" then
        return "reticleover"
    else
        return "prominent"
    end
end
