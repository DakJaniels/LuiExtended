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
    [107054] = true, -- Relentless Focus (counter; combat log)
    [61928] = true,  -- Relentless Focus (counter; legacy)
    [107055] = true, -- Merciless Resolve (counter; combat log)
    [61920] = true,  -- Merciless Resolve (counter; legacy)
    [130293] = true, -- Bound Armaments (counter)
    [215672] = true, -- Leeching Strikes (cost-reduction stacks)
}

--- @class (partial) BarHighlightStackBaseAbility
--- @type table<integer, boolean>
Effects.BarHighlightStackBaseAbility =
{
    [61902] = true, -- Grim Focus (slotted)
    [61927] = true, -- Relentless Focus (slotted)
    [61919] = true, -- Merciless Resolve (slotted)
    [24165] = true, -- Bound Armaments (slotted)
    [36908] = true, -- Leeching Strikes (slotted)
}

--- Track buff ids: on /reloadui BarSlotUpdate reads stack count from player buff (GetUnitBuffInfo).
--- @type table<integer, boolean>
Effects.BarHighlightReloadStackFromBuff =
{
    [122585] = true, -- Grim Focus
    [122586] = true, -- Merciless Resolve
    [122587] = true, -- Relentless Focus
    [215672] = true, -- Leeching Strikes (cost-reduction stacks)
}

--- Proc sound at stack thresholds on track buff ids (pairs with IsGrimFocus / IsBoundArmaments).
--- @class (partial) BarHighlightProcSoundThresholds
--- @type table<integer, integer[]>
Effects.BarHighlightProcSoundThresholds =
{
    [122585] = { 5, 10 }, -- Grim Focus
    [122587] = { 4, 10 }, -- Relentless Focus (spend at 4 stacks)
    [122586] = { 5, 10 }, -- Merciless Resolve
    [203447] = { 4, 8 },  -- Bound Armaments
}

