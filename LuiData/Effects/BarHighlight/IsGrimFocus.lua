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
--- @class (partial) IsGrimFocus
Effects.IsGrimFocus =
{
    [122585] = true, -- Grim Focus
    [122587] = true, -- Relentless Focus
    [122586] = true, -- Merciless Resolve
}

Effects.IsSimmeringFrenzy =
{
    [134166] = true, -- Simmering Frenzy
}

Effects.IsBoundArmaments =
{
    [203447] = true, -- Bound Armaments IV
}

--------------------------------------------------------------------------------------------------------------------------------
-- Grim Focus Override Id's - Used by SpellCastBuffs to track the id's for Grim Focus & its morphs - These id's are merged with the base buff for stack tracking
--------------------------------------------------------------------------------------------------------------------------------
Effects.IsGrimFocusOverride =
{
    [61902] = true, -- Grim Focus
    [61927] = true, -- Relentless Focus
    [61919] = true, -- Merciless Resolve
}

Effects.IsSimmeringFrenzyOverride =
{
    [134160] = true, -- Simmering Frenzy
}

--------------------------------------------------------------------------------------------------------------------------------
-- ActionBar stack tracking: counter buff id fades update slotted/base bar stack labels (Grim Focus line, Bound Armaments)
--------------------------------------------------------------------------------------------------------------------------------

--- @class (partial) BarHighlightStackCounter
--- @type table<integer, boolean>
Effects.BarHighlightStackCounter =
{
    [61905] = true,  -- Grim Focus (counter)
    [61928] = true,  -- Relentless Focus (counter)
    [61920] = true,  -- Merciless Resolve (counter)
    [130293] = true, -- Bound Armaments (counter)
}

--- @class (partial) BarHighlightStackBaseAbility
--- @type table<integer, boolean>
Effects.BarHighlightStackBaseAbility =
{
    [61902] = true, -- Grim Focus (slotted)
    [61927] = true, -- Relentless Focus (slotted)
    [61919] = true, -- Merciless Resolve (slotted)
    [24165] = true, -- Bound Armaments (slotted)
}

--- Proc sound at stack thresholds on track buff ids (pairs with IsGrimFocus / IsBoundArmaments).
--- @class (partial) BarHighlightProcSoundThresholds
--- @type table<integer, integer[]>
Effects.BarHighlightProcSoundThresholds =
{
    [122585] = { 5, 10 }, -- Grim Focus
    [122587] = { 5, 10 }, -- Relentless Focus
    [122586] = { 5, 10 }, -- Merciless Resolve
    [203447] = { 4, 8 },  -- Bound Armaments
}
