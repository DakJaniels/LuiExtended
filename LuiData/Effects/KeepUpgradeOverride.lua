-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects
local Abilities = Data.Abilities

--- @class (partial) KeepUpgradeOverride
local keepUpgradeOverride =
{
    [Abilities.Keep_Upgrade_Food_Guard_Range] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_GUARD_RANGE_DDS,
    [Abilities.Keep_Upgrade_Food_Heartier_Guards] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_HEARTIER_GUARDS_DDS,
    [Abilities.Keep_Upgrade_Food_Resistant_Guards] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_RESISTANT_GUARDS_DDS,
    [Abilities.Keep_Upgrade_Food_Stronger_Guards] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_STRONGER_GUARDS_DDS,
    [Abilities.Keep_Upgrade_Ore_Armored_Guards] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_ORE_ARMORED_GUARDS_DDS,
    [Abilities.Keep_Upgrade_Ore_Corner_Build] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_ORE_CORNER_BUILD_DDS,
    [Abilities.Keep_Upgrade_Ore_Siege_Platform] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_ORE_SIEGE_PLATFORM_DDS,
    [Abilities.Keep_Upgrade_Ore_Stronger_Walls] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_ORE_STRONGER_WALLS_DDS,
    [Abilities.Keep_Upgrade_Ore_Wall_Regeneration] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_ORE_WALL_REGENERATION_DDS,
    [Abilities.Keep_Upgrade_Wood_Archer_Guard] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_WOOD_ARCHER_GUARD_DDS,
    [Abilities.Keep_Upgrade_Wood_Door_Regeneration] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_WOOD_DOOR_REGENERATION_DDS,
    [Abilities.Keep_Upgrade_Wood_Siege_Cap] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_WOOD_SIEGE_CAP_DDS,
    [Abilities.Keep_Upgrade_Wood_Stronger_Doors] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_WOOD_STRONGER_DOORS_DDS,
    [Abilities.Keep_Upgrade_Food_Mender_Abilities] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_MENDER_DDS,
    [Abilities.Keep_Upgrade_Food_Mage_Abilities] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_MAGE_DDS,
    [Abilities.Keep_Upgrade_Food_Guard_Abilities] = LUIE_MEDIA_ICONS_KEEPUPGRADE_UPGRADE_FOOD_GUARD_DDS,
}

--- @class (partial) KeepUpgradeOverride
Effects.KeepUpgradeOverride = keepUpgradeOverride
