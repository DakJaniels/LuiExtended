-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Necromancer skull charges: bar label cap per track buff (Flame/Ricochet 2, Venom 3). Proc at that cap.
-- Third-cast ability ids reset charges on the track buff.
--------------------------------------------------------------------------------------------------------------------------------

--- @type table<integer, integer>
local barHighlightSkullChargeTrack =
{
    [114131] = 2, -- Flame Skull
    [117625] = 3, -- Venom Skull (game buff stacks 1-3; third cast ready at 3)
    [117638] = 2, -- Ricochet Skull
}

--- @type table<integer, integer>
local barHighlightSkullEmpoweredCast =
{
    [123685] = 114131, -- Flame Skull 3rd cast
    [123704] = 117625, -- Venom Skull 3rd cast
    [123719] = 117638, -- Ricochet Skull 3rd cast
}

--- Track buff id -> how ActionBar derives charge count.
--- skullCastCombat: remapped skull cast combat + BarHighlightStackFromCast (Flame, Ricochet).
--- trackBuff: combat/effect on track buff id only (Venom; any Necro ability in combat).
--- @type table<integer, string>
local barHighlightSkullChargeSource =
{
    [114131] = "skullCastCombat",
    [117625] = "trackBuff",
    [117638] = "skullCastCombat",
}

--- Slotted bound ability id -> raw charge for bar display when the game swaps the bar icon. 0 = no stack label.
--- @type table<integer, integer>
local barHighlightSkullSlottedDisplay =
{
    -- Flame Skull
    [114108] = 0,
    [123683] = 1,
    [123685] = 2,
    -- Venom Skull
    [117624] = 0,
    [123699] = 1,
    [123704] = 3,
    -- Ricochet Skull
    [117637] = 0,
    [123718] = 1,
    [123719] = 2,
}

Effects.BarHighlightSkullChargeTrack = barHighlightSkullChargeTrack
Effects.BarHighlightSkullEmpoweredCast = barHighlightSkullEmpoweredCast
Effects.BarHighlightSkullChargeSource = barHighlightSkullChargeSource
Effects.BarHighlightSkullSlottedDisplay = barHighlightSkullSlottedDisplay