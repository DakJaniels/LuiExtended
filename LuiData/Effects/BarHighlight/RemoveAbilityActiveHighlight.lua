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
--- @class (partial) RemoveAbilityActiveHighlight
local removeAbilityActiveHighlight =
{
    -- Vampire
    [132141] = true, -- Blood Frenzy
    [134160] = true, -- Simmering Frenzy
    [135841] = true, -- Sated Fury
}

--- @class (partial) RemoveAbilityActiveHighlight
Effects.RemoveAbilityActiveHighlight = removeAbilityActiveHighlight
