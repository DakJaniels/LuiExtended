-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local Abilities = Data.Abilities

--- @class (partial) KeepUpgradeAlliance
local keepUpgradeAlliance =
{
    [Abilities.Keep_Upgrade_Food_Honor_Guard_Abilities] =
    {
        [1] = "LuiExtended/media/icons/keepupgrade/upgrade_food_honor_guard_ad.dds",
        [2] = "LuiExtended/media/icons/keepupgrade/upgrade_food_honor_guard_ep.dds",
        [3] = "LuiExtended/media/icons/keepupgrade/upgrade_food_honor_guard_dc.dds",
    },
}


--- @class (partial) KeepUpgradeAlliance
Effects.KeepUpgradeAlliance = keepUpgradeAlliance
