-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

---
--- Determines the container context for prominent effects based on the current context, ability, and caster.
--- @param context SpellCastBuffsContext The current context identifier (e.g., "player1", "reticleover2").
--- @param abilityId number|nil The ability ID to check for prominence (can be nil).
--- @param abilityName string|nil The ability name to check for prominence (can be nil).
--- @param castByPlayer number|nil The unit type of the caster (e.g., COMBAT_UNIT_TYPE_PLAYER, can be nil).
--- @return string context The resolved context string (e.g., "promd_player", "promb_target", or original context).
function SpellCastBuffs.DetermineContext(context, abilityId, abilityName, castByPlayer)
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
