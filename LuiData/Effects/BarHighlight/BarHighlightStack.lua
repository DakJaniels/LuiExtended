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
}

--- Slotted bound id consumes one stack on this track buff id when cast (combat may not emit per-stack GAIN).
--- @type table<integer, integer>
local barHighlightStackConsume =
{
    [20824] = 34117,  -- Power Lash
    [256798] = 23808, -- Volcanic Whip
    [24165] = 203447, -- Bound Armaments
}

--- When EVENT_EFFECT_CHANGED reports stackCount 0 on the track buff id.
--- @type table<integer, "keep"|"clear">
local barHighlightStackZeroEffect =
{
    [34117] = "keep",  -- timer/stacks from combatTrack or slot use; ignore empty stack tick
    [23808] = "clear", -- hide when API reports 0 stacks
}

--- @class (partial) BarHighlightStack
Effects.BarHighlightStack = barHighlightStack

--- @class (partial) BarHighlightStackConsume
Effects.BarHighlightStackConsume = barHighlightStackConsume

--- @class (partial) BarHighlightStackZeroEffect
Effects.BarHighlightStackZeroEffect = barHighlightStackZeroEffect
