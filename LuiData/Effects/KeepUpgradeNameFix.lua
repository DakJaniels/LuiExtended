-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects
local Abilities = Data.Abilities

--- @class (partial) KeepUpgradeNameFix
local keepUpgradeNameFix =
{
    [Abilities.Keep_Upgrade_Food_Mage_Abilities] = Abilities.Keep_Upgrade_Food_Mage_Abilities_Fix,
}


--- @class (partial) KeepUpgradeNameFix
Effects.KeepUpgradeNameFix = keepUpgradeNameFix
