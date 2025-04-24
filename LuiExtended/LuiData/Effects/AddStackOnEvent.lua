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
-- Supports the above table by determining stack counts if needed.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) AddStackOnEvent
local addStackOnEvent =
{

    [28759] = 0, -- Essence Siphon (Keeper Voranil) -- Note: Set to 0 here due to this event firing twice.
}

--- @class (partial) AddStackOnEvent
Effects.AddStackOnEvent = addStackOnEvent
