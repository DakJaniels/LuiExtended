-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects
local Abilities = Data.Abilities

--------------------------------------------------------------------------------------------------------------------------------
-- Synergy Icon Overrides - When a synergy with a matching ability name appears, change the icon or name.
--------------------------------------------------------------------------------------------------------------------------------

--- @class SynergyNameOverrideEntry
--- @field icon? string
--- @field name? string

--- @type table<string, SynergyNameOverrideEntry>
local synergyNameOverride =
{
    ["Tonal Inverter"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_QUEST_TONAL_INVERTER_DDS },                                                 -- Tonal Inverter (Divine Intervention)
    [Abilities.Skill_Blade_of_Woe] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DARKBROTHERHOOD_BLADE_OF_WOE_DDS },                             -- Blade of Woe (Dark Brotherhood)
    [Abilities.Skill_Black_Widow] = { icon = "/esoui/art/icons/ability_undaunted_003_a.dds" },                                                   -- Black Widow (Undaunted)
    [Abilities.Skill_Arachnophobia] = { icon = "/esoui/art/icons/ability_undaunted_003_b.dds" },                                                 -- Arachnophobia (Undaunted)
    [Abilities.Skill_Devour] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_WEREWOLF_DEVOUR_DDS },                                                -- Devour (Werewolf)
    [Abilities.Set_Shield_of_Ursus] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SET_HAVEN_OF_URSUS_DDS, name = Abilities.Set_Ursus_Blessing }, -- Ursus's Blessing (Haven of Ursus)
    -- World Bosses
    [Abilities.Skill_Remove_Bolt] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_TRAPPING_BOLT_DDS },                                       -- Remove Bolt (Trapjaw)
    -- Dungeons
    [Abilities.Skill_Free_Ally] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_FREE_ALLY_DDS },                                            -- Free Ally (Selene) -- Selene's Web
    [Abilities.Skill_Resist_Necrosis] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_RESIST_NECROSIS_DDS },                                 -- Resist Necrosis (Nerien'eth) -- Crypt of Hearts II
    -- Sets
    [Abilities.Set_Sanguine_Burst] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SET_HOLLOWFANG_DDS },                                           -- Sanguine Burst (Lady Thorn)
}

--- @type table<string, SynergyNameOverrideEntry>
Effects.SynergyNameOverride = synergyNameOverride
