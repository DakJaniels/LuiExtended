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

--- @class (partial) KeepUpgradeOverride
local keepUpgradeOverride =
{
    [Abilities.Keep_Upgrade_Food_Guard_Range] = "LuiExtended/media/icons/keepupgrade/upgrade_food_guard_range.dds",
    [Abilities.Keep_Upgrade_Food_Heartier_Guards] = "LuiExtended/media/icons/keepupgrade/upgrade_food_heartier_guards.dds",
    [Abilities.Keep_Upgrade_Food_Resistant_Guards] = "LuiExtended/media/icons/keepupgrade/upgrade_food_resistant_guards.dds",
    [Abilities.Keep_Upgrade_Food_Stronger_Guards] = "LuiExtended/media/icons/keepupgrade/upgrade_food_stronger_guards.dds",
    [Abilities.Keep_Upgrade_Ore_Armored_Guards] = "LuiExtended/media/icons/keepupgrade/upgrade_ore_armored_guards.dds",
    [Abilities.Keep_Upgrade_Ore_Corner_Build] = "LuiExtended/media/icons/keepupgrade/upgrade_ore_corner_build.dds",
    [Abilities.Keep_Upgrade_Ore_Siege_Platform] = "LuiExtended/media/icons/keepupgrade/upgrade_ore_siege_platform.dds",
    [Abilities.Keep_Upgrade_Ore_Stronger_Walls] = "LuiExtended/media/icons/keepupgrade/upgrade_ore_stronger_walls.dds",
    [Abilities.Keep_Upgrade_Ore_Wall_Regeneration] = "LuiExtended/media/icons/keepupgrade/upgrade_ore_wall_regeneration.dds",
    [Abilities.Keep_Upgrade_Wood_Archer_Guard] = "LuiExtended/media/icons/keepupgrade/upgrade_wood_archer_guard.dds",
    [Abilities.Keep_Upgrade_Wood_Door_Regeneration] = "LuiExtended/media/icons/keepupgrade/upgrade_wood_door_regeneration.dds",
    [Abilities.Keep_Upgrade_Wood_Siege_Cap] = "LuiExtended/media/icons/keepupgrade/upgrade_wood_siege_cap.dds",
    [Abilities.Keep_Upgrade_Wood_Stronger_Doors] = "LuiExtended/media/icons/keepupgrade/upgrade_wood_stronger_doors.dds",
    [Abilities.Keep_Upgrade_Food_Mender_Abilities] = "LuiExtended/media/icons/keepupgrade/upgrade_food_mender.dds",
    [Abilities.Keep_Upgrade_Food_Mage_Abilities] = "LuiExtended/media/icons/keepupgrade/upgrade_food_mage.dds",
    [Abilities.Keep_Upgrade_Food_Guard_Abilities] = "LuiExtended/media/icons/keepupgrade/upgrade_food_guard.dds",
}

--- @class (partial) KeepUpgradeOverride
Effects.KeepUpgradeOverride = keepUpgradeOverride
