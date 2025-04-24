-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) IsBloodFrenzy
local isBloodFrenzy =
{
    [172418] = true, -- Blood Frenzy
    [134166] = true, -- Simmering Frenzy
    [172648] = true, -- Sated Fury
}

--- @class (partial) IsBloodFrenzy
Effects.IsBloodFrenzy = isBloodFrenzy
