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
