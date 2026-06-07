-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

--- @class (partial) BarHighlightStack
local barHighlightStack =
{

    -- Sorcerer
    [24330] = 2,  -- Haunting Curse (Haunting Curse)
    [89491] = 1,  -- Haunting Curse (Haunting Curse)
    [203447] = 4, -- Bound Armaments (Bound Armaments)

    -- Warden
    [86009] = 2,  -- Scorch (Scorch)
    [178020] = 1, -- Scorch (Scorch)
    [86019] = 2,  -- Subterranean Assault
    [146919] = 1, -- Subterranean Assault
    [86015] = 2,  -- Deep Fissure
    [178028] = 1, -- Deep Fissure

    -- Dragonknight (combatTrack stack buff ids; max stacks for bar highlight + combat GAIN hitValue)
    [34117] = 5, -- Power Lash stacks (Flame Lash line)
    [23808] = 5, -- Lava Slam / Volcanic Whip stacks (Lava Whip line)

    -- Nightblade
    [215672] = 10, -- Leeching Strikes (cost-reduction stacks)

    -- Necromancer (skull charge tracks; combat hitValue may be 3 internally, bar label max 2)
    [114131] = 3, -- Flame Skull charges (display capped in ActionBar)
    [117625] = 3, -- Venom Skull charges
    [117638] = 3, -- Ricochet Skull charges

    -- Alliance War — Vengeance Scout
    [256560] = 3, -- Blade Bite bleed stacks on target
}

--- Slotted bound id consumes one stack on this track buff id when cast (combat may not emit per-stack GAIN).
--- @type table<integer, integer>
local barHighlightStackConsume =
{
    [20824] = 34117,  -- Power Lash
    [256798] = 23808, -- Volcanic Whip
    [24165] = 203447, -- Bound Armaments
    -- Leeching Strikes: spend-all on cast (BarHighlightStackSpendAllOnCast), not -1 per press.
    -- Necromancer skulls: charge counter builds on cast; do not consume here (unlike Power Lash).
}

--- Slotted ability use clears all stacks on the track buff (Leeching Strikes activate spends built stacks).
--- @type table<integer, integer>
local barHighlightStackSpendAllOnCast =
{
    [36908] = 215672, -- Leeching Strikes
}

Effects.BarHighlightStackSpendAllOnCast = barHighlightStackSpendAllOnCast

--- When EVENT_EFFECT_CHANGED reports stackCount 0 on the track buff id.
--- @type table<integer, "keep"|"clear">
local barHighlightStackZeroEffect =
{
    [34117] = "keep",  -- timer/stacks from combatTrack or slot use; ignore empty stack tick
    [23808] = "clear", -- hide when API reports 0 stacks
    [114131] = "keep",
    [117625] = "keep",
    [117638] = "keep",
    [215672] = "clear", -- stacks spent on activate; hide bar when API reports 0
}

--- @class (partial) BarHighlightStack
Effects.BarHighlightStack = barHighlightStack

--- @class (partial) BarHighlightStackConsume
Effects.BarHighlightStackConsume = barHighlightStackConsume

--- @class (partial) BarHighlightStackZeroEffect
Effects.BarHighlightStackZeroEffect = barHighlightStackZeroEffect

--- Track buff ids: bar stack count only from GetUnitBuffInfo on this id (ignore EVENT/COMBAT stackCount).
--- @type table<integer, boolean>
Effects.BarHighlightStackBuffOnly =
{
    [215672] = true, -- Leeching Strikes (cost-reduction stacks; not while-slotted ping 215669)
}

--- Effect ids that must not drive bar highlight GAIN/UPDATE (while-slotted ping, etc.).
--- @type table<integer, boolean>
Effects.BarHighlightIgnoreBarStackEvent =
{
    [215669] = true, -- Leeching Strikes while-slotted ping
}
