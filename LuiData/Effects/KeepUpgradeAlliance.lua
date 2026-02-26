-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects
local Abilities = Data.Abilities

--- @class (partial) KeepUpgradeAlliance
local keepUpgradeAlliance =
{
    [Abilities.Keep_Upgrade_Food_Honor_Guard_Abilities] =
    {
        [1] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_HONOR_GUARD_AD_DDS,
        [2] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_HONOR_GUARD_EP_DDS,
        [3] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_HONOR_GUARD_DC_DDS,
    },
}


--- @class (partial) KeepUpgradeAlliance
Effects.KeepUpgradeAlliance = keepUpgradeAlliance
