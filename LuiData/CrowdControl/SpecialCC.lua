-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
local CrowdControl = Data.CrowdControl
-- Use on ACTION_RESULT_EFFECT_GAINED
--- @class (partial) SpecialCC
local specialCC =
{
    [55756] = true, -- Burning (Valkyn Skoria)
}

--- @class (partial) SpecialCC
CrowdControl.SpecialCC = specialCC
