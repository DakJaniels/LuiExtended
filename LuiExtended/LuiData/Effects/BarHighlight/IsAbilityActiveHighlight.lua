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
--- @class (partial) IsAbilityActiveHighlight
local isAbilityActiveHighlight =
{
    -- Support
    [78338] = true, -- Guard (Guard)
    [81415] = true, -- Mystic Guard (Mystic Guard)
    [81420] = true, -- Stalwart Guard (Stalwart Guard)
}

--- @class (partial) IsAbilityActiveHighlight
Effects.IsAbilityActiveHighlight = isAbilityActiveHighlight
