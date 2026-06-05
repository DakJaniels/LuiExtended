-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Visible buff id --> hidden/stack buff id: read stackCount from GetUnitBuffInfo on the source row (SpellCastBuffs).
--------------------------------------------------------------------------------------------------------------------------------
--- @type table<integer, integer>
local effectPullStacks =
{
    [36908] = 215672, -- Leeching Strikes (20s long buff) <-- cost-reduction stacks on 215672
}

Effects.EffectPullStacks = effectPullStacks

--------------------------------------------------------------------------------------------------------------------------------
-- Hidden buff id --> visible buff id: when the hidden aura updates, push stacks onto the displayed entry (SpellCastBuffs).
--------------------------------------------------------------------------------------------------------------------------------
--- @type table<integer, integer>
local effectPushStacksFromHidden =
{
}

Effects.EffectPushStacksFromHidden = effectPushStacksFromHidden
