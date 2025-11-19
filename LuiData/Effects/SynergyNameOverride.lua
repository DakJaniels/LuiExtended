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

--------------------------------------------------------------------------------------------------------------------------------
-- Synergy Icon Overrides - When a synergy with a matching ability name appears, change the icon or name.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) SynergyNameOverride
local synergyNameOverride =
{
    ["Tonal Inverter"] = { icon = "LuiExtended/media/icons/abilities/ability_quest_tonal_inverter.dds" },                                                 -- Tonal Inverter (Divine Intervention)
    [Abilities.Skill_Blade_of_Woe] = { icon = "LuiExtended/media/icons/abilities/ability_darkbrotherhood_blade_of_woe.dds" },                             -- Blade of Woe (Dark Brotherhood)
    [Abilities.Skill_Black_Widow] = { icon = "/esoui/art/icons/ability_undaunted_003_a.dds" },                                                            -- Black Widow (Undaunted)
    [Abilities.Skill_Arachnophobia] = { icon = "/esoui/art/icons/ability_undaunted_003_b.dds" },                                                          -- Arachnophobia (Undaunted)
    [Abilities.Skill_Devour] = { icon = "LuiExtended/media/icons/abilities/ability_werewolf_devour.dds" },                                                -- Devour (Werewolf)
    [Abilities.Set_Shield_of_Ursus] = { icon = "LuiExtended/media/icons/abilities/ability_set_haven_of_ursus.dds", name = Abilities.Set_Ursus_Blessing }, -- Ursus's Blessing (Haven of Ursus)
    -- World Bosses
    [Abilities.Skill_Remove_Bolt] = { icon = "LuiExtended/media/icons/abilities/ability_spell_trapping_bolt.dds" },                                       -- Remove Bolt (Trapjaw)
    -- Dungeons
    [Abilities.Skill_Free_Ally] = { icon = "LuiExtended/media/icons/abilities/ability_innate_free_ally.dds" },                                            -- Free Ally (Selene) -- Selene's Web
    [Abilities.Skill_Resist_Necrosis] = { icon = "LuiExtended/media/icons/abilities/ability_spell_resist_necrosis.dds" },                                 -- Resist Necrosis (Nerien'eth) -- Crypt of Hearts II
    -- Sets
    [Abilities.Set_Sanguine_Burst] = { icon = "LuiExtended/media/icons/abilities/ability_set_hollowfang.dds" },                                           -- Sanguine Burst (Lady Thorn)
}

--- @class (partial) SynergyNameOverride
Effects.SynergyNameOverride = synergyNameOverride
