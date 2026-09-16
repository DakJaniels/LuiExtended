-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Status effects that often never arrive as player-sourced EVENT_EFFECT_CHANGED auras.
-- SpellCastBuffs registers ability-id-filtered EVENT_COMBAT_EVENT for these ids and
-- creates 4s fake debuffs on the player / current reticle (see _OnCombatEventStatus.lua).
-- ignoreBegin skips ACTION_RESULT_BEGIN so travel/cast start does not spawn a fake.
-- Duration is 4000 ms (standard ESO status duration); GAINED_DURATION hitValue can override.
--------------------------------------------------------------------------------------------------------------------------------

--- @class CombatEventStatusEffectConfig
--- @field duration integer|string
--- @field ignoreBegin boolean
--- @field icon? string
--- @field name? string

--- @class (partial) CombatEventStatusEffects
--- @field [integer] CombatEventStatusEffectConfig

local combatEventStatusEffects =
{
    -- Chill (Frost Status Effect)
    [95136] = { duration = 4000, ignoreBegin = true },
    [21481] = { duration = 4000, ignoreBegin = true },
    [130814] = { duration = 4000, ignoreBegin = true },
    [130816] = { duration = 4000, ignoreBegin = true },

    -- Concussion (Shock Status Effect)
    [95134] = { duration = 4000, ignoreBegin = true },
    [21487] = { duration = 4000, ignoreBegin = true },
    [130808] = { duration = 4000, ignoreBegin = true },
    [130810] = { duration = 4000, ignoreBegin = true },

    -- Overcharged (Magic Status Effect)
    [178118] = { duration = 4000, ignoreBegin = true },
    [148797] = { duration = 4000, ignoreBegin = true },

    -- Diseased (Disease Status Effect)
    [178127] = { duration = 4000, ignoreBegin = true },
    [21925] = { duration = 4000, ignoreBegin = true },

    -- Sundered (Physical Status Effect)
    [178123] = { duration = 4000, ignoreBegin = true },
    [148800] = { duration = 4000, ignoreBegin = true },
    [149573] = { duration = 4000, ignoreBegin = true },
}

--- @class (partial) CombatEventStatusEffects
Effects.CombatEventStatusEffects = combatEventStatusEffects
