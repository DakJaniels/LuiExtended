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
--- @class (partial) IsGrimFocus
local isGrimFocus =
{
    [122585] = true, -- Grim Focus
    [122587] = true, -- Relentless Focus
    [122586] = true, -- Merciless Resolve
}

--- @class (partial) IsGrimFocus
Effects.IsGrimFocus = isGrimFocus


Effects.IsBoundArmaments =
{
    [203447] = true, -- Bound Armaments IV
}
