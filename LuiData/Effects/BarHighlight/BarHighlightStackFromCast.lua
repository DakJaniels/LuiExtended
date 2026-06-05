-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Cast ability id -> charge stack count when combat EFFECT_GAINED hitValue does not carry stacks (Necromancer skulls).
--------------------------------------------------------------------------------------------------------------------------------

--- @type table<integer, integer>
local barHighlightStackFromCast =
{
    -- Flame Skull
    [114108] = 1,
    [123683] = 2,
    -- 123685 empowered cast clears via BarHighlightSkullEmpoweredCast (not a stack count)
    -- Venom Skull: BarHighlightSkullChargeSource trackBuff on 117625 (not cast fallback)
    -- Ricochet Skull
    [117637] = 1,
    [123718] = 1,
    [123719] = 2,
}

Effects.BarHighlightStackFromCast = barHighlightStackFromCast
