--- @diagnostic disable: duplicate-index
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
-- For debug function - convert statusEffectType codes to string value
--- @class DebugStatus
local DebugStatus =
{
    [0] = "NONE",
    [1] = "ROOT",
    [2] = "SNARE",
    [3] = "BLEED",
    [4] = "POISON",
    [5] = "WEAKNESS",
    [6] = "BLIND",
    [7] = "NEARSIGHT",
    [8] = "DISEASE",
    [9] = "TRAUMA",
    [10] = "PUNCTURE",
    [11] = "WOUND",
    [12] = "DAZED",
    [13] = "SILENCE",
    [14] = "PACIFY",
    [15] = "FEAR",
    [16] = "MESMERIZE",
    [17] = "CHARM",
    [18] = "LEVITATE",
    [19] = "STUN",
    [20] = "ENVIRONMENT",
    [21] = "MAGIC",
}

--- @type DebugStatus
Data.DebugStatus = DebugStatus
