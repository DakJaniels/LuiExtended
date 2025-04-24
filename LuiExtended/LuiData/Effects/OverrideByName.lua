-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local Unitnames = Data.UnitNames
local Abilities = Data.Abilities

--------------------------------------------------------------------------------------------------------------------------------
-- Table of effects to adjust only based off a specific target - this allows us to override the name/icon or hide an effect only when the source is a specific NPC. Used to change icons for attacks with the same id coming from different types of animals, etc...
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) EffectOverrideByName
local effectOverrideByName =
{
    [10618] =
    {                                                                                                                 -- Quick Strike (Shared)
        [Unitnames.NPC_Xivilai] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_xivilai_light.dds" }, -- Xivilai

        -- QUESTS
        [Unitnames.Elite_Vaekar_the_Forgemaster] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_1h_light.dds" }, -- Vaekar the Forgemaster (Soul Shriven in Coldharbour)
        [Unitnames.NPC_Dremora_Caitiff] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_2h_light.dds" },         -- Dremora Caitiff (Soul Shriven in Coldharbour)
        [Unitnames.NPC_Skeletal_Ravager] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_light.dds" },          -- Skeletal Ravager (Soul Shriven in Coldharbour)
        [Unitnames.NPC_Dremora_Baunekyn] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_light.dds" },         -- Dremora Baunekyn (Soul Shriven in Coldharbour)ability_spell_mace_2h_light.dds

        -- Vvardenfell
        [Unitnames.Elite_First_Mate_Ulveni] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_1h_light.dds" },   -- First Mate Ulveni (Broken Bonds)

        [Unitnames.Elite_Amuur] = { icon = "LuiExtended/media/icons/abilities/ability_weapon_melee_cleaver_attack_light.dds" }, -- Amuur (Auridon - The First Patient)

        -- Daggerfall Covenant
        [Unitnames.Elite_Gornog] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_2h_light.dds" },    -- Gornog (Stros M'Kai - Innocent Scoundrel)
        [Unitnames.NPC_Drake_Brigand] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_light.dds" }, -- Drake Brigand (Stros M'Kai)

        -- Elsweyr
        [Unitnames.Elite_Captain_Carvain] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_1h_light.dds" }, -- Captain Carvain (Elsweyr - Bright Moons, Warm Sands)

        -- Greymoor
        [Unitnames.Elite_Vitrus_the_Bloody] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_light.dds" }, -- Vitrus the Bloody (Greymoor - Bound in Blood)
        [Unitnames.NPC_Icereach_Brute] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_light.dds" },      -- Icereach Brute (Greymoor - Bound in Blood)
        [Unitnames.NPC_Icereach_Charger] = { icon = "LuiExtended/media/icons/abilities/ability_spell_hammer_2h_light.dds" }, -- Icereach Charger (Greymoor - Bound in Blood)

        -- DUNGEONS
        [Unitnames.NPC_Darkfern_Mauler] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_light_reach.dds" },  -- Darkfern Mauler (Elden Hollow I)
        [Unitnames.Boss_Nenesh_gro_Mal] = { icon = "LuiExtended/media/icons/abilities/ability_spell_club2h_light_attack.dds" }, -- Nenesh gro Mal (Elden Hollow I)
        [Unitnames.NPC_Dremora_Berserker] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_light.dds" },      -- Dremora Berserker (City of Ash I)
        [Unitnames.Boss_The_Mage_Master] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_2h_light.dds" },     -- The Mage Master (Crypt of Hearts I)
        [Unitnames.Boss_Dogas_the_Berserker] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_light.dds" },   -- Dogas the Berserker (Crypt of Hearts I)
        [Unitnames.NPC_Dremora_Kynval] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_1h_light.dds" },        -- Dremora Kynval (City of Ash I)
        [Unitnames.Boss_Rukhan] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_light.dds" },               -- Rukhan (City of Ash I)
        [Unitnames.NPC_Xivilai_Ravager] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_light.dds" },       -- Xivilai Ravager (City of Ash I)
        [Unitnames.NPC_Fire_Ravager] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_light.dds" },          -- Fire Ravager (City of Ash I)
        [Unitnames.NPC_Xivilai_Boltaic] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_light.dds" },       -- Fire Ravager (City of Ash I)
        [Unitnames.NPC_Sea_Viper_Strongarm] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_light.dds" },    -- Sea Viper Strongarm (Tempest Island)
        [Unitnames.NPC_Sea_Viper_Berserker] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_light.dds" },    -- Sea Viper Berserker (Tempest Island)
        [Unitnames.NPC_Sea_Viper_Charger] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_light.dds" },     -- Sea Viper Charger (Tempest Island)
        [Unitnames.Boss_Commodore_Ohmanil] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_light.dds" },     -- Commodore Ohmanil (Tempest Island)
        [Unitnames.Boss_Ibelgast] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_2h_light.dds" },            -- Ibelgast (Crypt of Hearts II)
        [Unitnames.NPC_Spiderkith_Venifex] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_2h_light.dds" },   -- Spiderkith Venifex (Crypt of Hearts II)
        [Unitnames.NPC_Spiderkith_Warper] = { icon = "LuiExtended/media/icons/abilities/ability_spell_dagger_1h_light.dds" },   -- Spiderkith Warper (Crypt of Hearts II)
        [Unitnames.Boss_Chamber_Guardian] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_light.dds" },      -- Chamber Guardian (Crypt of Hearts II)
    },
    -- Quick Strike (Rogue/Skirmisher)
    [29035] =
    {
        -- QUESTS
        [Unitnames.NPC_Slaver_Cutthroat] = { con = "LuiExtended/media/icons/abilities/ability_spell_dagger_1h_light.dds", }, -- Firemoth Island (Vvardenfell - Broken Bonds) -- Slaver Cutthroat

        -- Daggerfall Covenant
        [Unitnames.NPC_Dogeater_Skirmisher] = { icon = "LuiExtended/media/icons/abilities/ability_spell_dagger_1h_light.dds", }, -- Dogeater Skirmisher (Stros M'Kai)
        [Unitnames.NPC_Drake_Cutthroat] = { icon = "LuiExtended/media/icons/abilities/ability_spell_dagger_1h_light.dds", },     -- Drake Cutthroat (Stros M'Kai)
    },
    -- Slash (Valaran Stormcaller)
    [26332] =
    {
        [Unitnames.NPC_Lightning_Avatar] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_1h_light_ethereal.dds", }, -- Lightning Avatar (Tempest Island)
    },
    [14096] =
    {                                                                                                                            -- Heavy Attack (Footsoldier)
        [Unitnames.Elite_Amuur] = { icon = "LuiExtended/media/icons/abilities/ability_weapon_melee_cleaver_attack_heavy.dds", }, -- Amuur (The First Patient)
    },

    -- HUMAN NPCS
    [29521] =
    {                                                         -- Aura of Protection (Shaman)
        [Unitnames.NPC_Aura_of_Protection] = { hide = true }, -- Aura of Protection (Aura of Protection) -- Hides this buff only on the Goblin Aura of Protection to prevent duplicate display
    },
    [86704] =
    {                                                                                                                           -- Chop (Peasant)
        [Unitnames.NPC_Hleran_Noble] = { icon = "LuiExtended/media/icons/abilities/ability_weapon_peasant_dagger_light.dds", }, -- Chop (Hleran Noble)
    },
    [86705] =
    {                                                                                                                           -- Lop (Peasant)
        [Unitnames.NPC_Hleran_Noble] = { icon = "LuiExtended/media/icons/abilities/ability_weapon_peasant_dagger_light.dds", }, -- Lop (Hleran Noble)
    },

    [88251] =
    {
        [Unitnames.NPC_Great_Bear] = { icon = "LuiExtended/media/icons/abilities/ability_summon_call_ally_bear.dds" },    -- Call Ally (Pet Ranger)
        [Unitnames.NPC_Spider] = { icon = "LuiExtended/media/icons/abilities/ability_summon_call_ally_spider.dds" },      -- Call Ally (Pet Ranger)
        [Unitnames.NPC_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_summon_call_ally_tiger.dds" }, -- Call Ally (Pet Ranger)
    },

    [88248] =
    {
        [Unitnames.NPC_Spider] = { icon = "LuiExtended/media/icons/abilities/ability_summon_call_ally_spider.dds" },            -- Call Ally (Pet Ranger)
        [Unitnames.NPC_Venomspit_Spider] = { icon = "LuiExtended/media/icons/abilities/ability_summon_call_ally_spider.dds", }, -- Call Ally (Pet Ranger)
        [Unitnames.NPC_Websnare_Spider] = { icon = "LuiExtended/media/icons/abilities/ability_summon_call_ally_spider.dds", },  -- Call Ally (Pet Ranger)
    },

    -- ANIMALS
    -- Rend (Lion)
    [7170] =
    {
        [Unitnames.NPC_Lion] = { icon = "LuiExtended/media/icons/abilities/ability_lion_rend.dds" },                            -- Rend (Lion)
        [Unitnames.Boss_Desert_Lion] = { icon = "LuiExtended/media/icons/abilities/ability_lion_rend.dds" },                    -- Rend (Lion)
        [Unitnames.NPC_Lioness] = { icon = "LuiExtended/media/icons/abilities/ability_lioness_rend.dds" },                      -- Rend (Lion)
        [Unitnames.Boss_Desert_Lioness] = { icon = "LuiExtended/media/icons/abilities/ability_lioness_rend.dds" },              -- Rend (Lion)
        [Unitnames.NPC_Sabre_Cat] = { icon = "LuiExtended/media/icons/abilities/ability_sabrecat_rend.dds" },                   -- Rend (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                  -- Rend (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend_white.dds", }, -- Rend (Senche-Tiger)
        ["The Tiger"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                                 -- Rend (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },         -- Rend (Senche-Tiger)
        ["Esh'tabe"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                                  -- Rend (Senche-Tiger)
        ["Raakhet"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                                   -- Rend (Senche-Tiger)
        ["Razorclaw"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                                 -- Rend (Senche-Tiger)
        [Unitnames.NPC_Senche_Panther] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },         -- Rend (Senche-Panther)
        [Unitnames.Boss_Silentpaw] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },             -- Rend (Senche-Panther)
        [Unitnames.Boss_Heartstalker] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },          -- Rend (Senche-Panther)
        [Unitnames.Boss_Nighteyes] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },             -- Rend (Senche-Panther)
        [Unitnames.Boss_Shadowhiskers] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },         -- Rend (Senche-Panther)
        [Abilities.Skill_Senche_Spirit] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend_ghost.dds", }, -- Rend (Senche Spirit)
    },
    -- Rend (Lion)
    [60630] =
    {
        [Unitnames.NPC_Lion] = { icon = "LuiExtended/media/icons/abilities/ability_lion_rend.dds" },                            -- Rend (Lion)
        [Unitnames.Boss_Desert_Lion] = { icon = "LuiExtended/media/icons/abilities/ability_lion_rend.dds" },                    -- Rend (Lion)
        [Unitnames.NPC_Lioness] = { icon = "LuiExtended/media/icons/abilities/ability_lioness_rend.dds" },                      -- Rend (Lion)
        [Unitnames.Boss_Desert_Lioness] = { icon = "LuiExtended/media/icons/abilities/ability_lioness_rend.dds" },              -- Rend (Lion)
        [Unitnames.NPC_Sabre_Cat] = { icon = "LuiExtended/media/icons/abilities/ability_sabrecat_rend.dds" },                   -- Rend (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                  -- Rend (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend_white.dds", }, -- Rend (Senche-Tiger)
        ["The Tiger"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                                 -- Rend (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },         -- Rend (Senche-Tiger)
        ["Esh'tabe"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                                  -- Rend (Senche-Tiger)
        ["Raakhet"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                                   -- Rend (Senche-Tiger)
        ["Razorclaw"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_rend.dds" },                                 -- Rend (Senche-Tiger)
        [Unitnames.NPC_Senche_Panther] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },         -- Rend (Senche-Panther)
        [Unitnames.Boss_Silentpaw] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },             -- Rend (Senche-Panther)
        [Unitnames.Boss_Heartstalker] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },          -- Rend (Senche-Panther)
        [Unitnames.Boss_Nighteyes] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },             -- Rend (Senche-Panther)
        [Unitnames.Boss_Shadowhiskers] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend.dds" },         -- Rend (Senche-Panther)
        [Abilities.Skill_Senche_Spirit] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_rend_ghost.dds", }, -- Rend (Senche Spirit)
    },
    -- Claw (Lion)
    [60641] =
    {
        [Unitnames.NPC_Sabre_Cat] = { icon = "LuiExtended/media/icons/abilities/ability_sabrecat_claw.dds" },                   -- Claw (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_claw.dds" },                  -- Claw (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = "LuiExtended/media/icons/abilities/ability_senche_claw_white.dds", }, -- Claw (Senche-Tiger)
        ["The Tiger"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_claw.dds" },                                 -- Claw (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_claw.dds" },         -- Claw (Senche-Tiger)
        ["Esh'tabe"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_claw.dds" },                                  -- Claw (Senche-Tiger)
        ["Raakhet"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_claw.dds" },                                   -- Claw (Senche-Tiger)
        ["Razorclaw"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_claw.dds" },                                 -- Claw (Senche-Tiger)
    },
    -- Bite (Lion)
    [7158] =
    {
        [Unitnames.NPC_Lion] = { icon = "LuiExtended/media/icons/abilities/ability_lion_bite.dds" },                            -- Bite (Lion)
        [Unitnames.NPC_Lioness] = { icon = "LuiExtended/media/icons/abilities/ability_lioness_bite.dds" },                      -- Bite (Lion)
        [Unitnames.Boss_Desert_Lioness] = { icon = "LuiExtended/media/icons/abilities/ability_lioness_bite.dds" },              -- Bite (Lion)
        [Unitnames.NPC_Sabre_Cat] = { icon = "LuiExtended/media/icons/abilities/ability_sabrecat_bite.dds" },                   -- Bite (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_bite.dds" },                  -- Bite (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = "LuiExtended/media/icons/abilities/ability_senche_bite_white.dds", }, -- Bite (Senche-Tiger)
        ["The Tiger"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_bite.dds" },                                 -- Bite (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_bite.dds" },         -- Bite (Senche-Tiger)
        ["Esh'tabe"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_bite.dds" },                                  -- Bite (Senche-Tiger)
        ["Raakhet"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_bite.dds" },                                   -- Bite (Senche-Tiger)
        ["Razorclaw"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_bite.dds" },                                 -- Bite (Senche-Tiger)
        [Unitnames.NPC_Senche_Panther] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_bite.dds" },         -- Bite (Senche-Panther)
        [Unitnames.Boss_Silentpaw] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_bite.dds" },             -- Bite (Senche-Panther)
        [Unitnames.Boss_Heartstalker] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_bite.dds" },          -- Bite (Senche-Panther)
        [Unitnames.Boss_Nighteyes] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_bite.dds" },             -- Bite (Senche-Panther)
        [Unitnames.Boss_Shadowhiskers] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_bite.dds" },         -- Bite (Senche-Panther)
        [Abilities.Skill_Senche_Spirit] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_bite_ghost.dds", }, -- Bite (Senche Spirit)
    },
    -- Double Strike (Lion)
    [7161] =
    {
        [Unitnames.NPC_Sabre_Cat] = { icon = "LuiExtended/media/icons/abilities/ability_sabrecat_double_strike.dds" },                   -- Double Strike (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_double_strike.dds" },                  -- Double Strike (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = "LuiExtended/media/icons/abilities/ability_senche_double_strike_white.dds", }, -- Double Strike (Senche-Tiger)
        ["The Tiger"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_double_strike.dds" },                                 -- Double Strike (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = "LuiExtended/media/icons/abilities/ability_senche_double_strike.dds", },        -- Double Strike (Senche-Tiger)
        ["Esh'tabe"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_double_strike.dds" },                                  -- Double Strike (Senche-Tiger)
        ["Raakhet"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_double_strike.dds" },                                   -- Double Strike (Senche-Tiger)
        ["Razorclaw"] = { icon = "LuiExtended/media/icons/abilities/ability_senche_double_strike.dds" },                                 -- Double Strike (Senche-Tiger)
        [Unitnames.NPC_Senche_Panther] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_double_strike.dds", },        -- Double Strike (Senche-Panther)
        [Unitnames.Boss_Silentpaw] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_double_strike.dds", },            -- Double Strike (Senche-Panther)
        [Unitnames.Boss_Heartstalker] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_double_strike.dds", },         -- Double Strike (Senche-Panther)
        [Unitnames.Boss_Nighteyes] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_double_strike.dds", },            -- Double Strike (Senche-Panther)
        [Unitnames.Boss_Shadowhiskers] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_double_strike.dds", },        -- Double Strike (Senche-Panther)
        [Abilities.Skill_Senche_Spirit] = { icon = "LuiExtended/media/icons/abilities/ability_senchepanther_double_strike_ghost.dds", }, -- Double Strike (Senche Spirit)
    },
    -- Slam (Skeever / Kagouti)
    [5362] =
    {
        [Unitnames.NPC_Kagouti] = { icon = "LuiExtended/media/icons/abilities/ability_kagouti_slam.dds" },      -- Slam (Kagouti)
        [Unitnames.NPC_Bull_Kagouti] = { icon = "LuiExtended/media/icons/abilities/ability_kagouti_slam.dds" }, -- Slam (Kagouti)
        [Unitnames.NPC_Daedrat] = { icon = "LuiExtended/media/icons/abilities/ability_daedrat_slam.dds" },      -- Slam (Daedrat)
    },
    -- Rend (Skeever)
    [21904] =
    {
        [Unitnames.NPC_Daedrat] = { icon = "LuiExtended/media/icons/abilities/ability_daedrat_rend.dds" }, -- Rend (Daedrat)
    },
    -- Bite (Wolf)
    [4022] =
    {
        [Unitnames.NPC_Jackal] = { icon = "LuiExtended/media/icons/abilities/ability_jackal_bite.dds" }, -- Bite (Jackal)
    },
    -- Rotbone (Wolf)
    [42844] =
    {
        [Unitnames.NPC_Jackal] = { icon = "LuiExtended/media/icons/abilities/ability_jackal_rotbone.dds" }, -- Rotbone (Wolf)
    },
    -- Helljoint (Wolf)
    [14523] =
    {
        [Unitnames.NPC_Jackal] = { icon = "LuiExtended/media/icons/abilities/ability_jackal_helljoint.dds" }, -- Helljoint (Wolf)
    },
    -- Helljoint (Wolf)
    [75818] =
    {
        [Unitnames.NPC_Jackal] = { icon = "LuiExtended/media/icons/abilities/ability_jackal_helljoint.dds" }, -- Helljoint (Wolf)
    },
    -- Devastating Leap (Bloodfiend)
    [8569] =
    {
        [Unitnames.NPC_Skeleton] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_devastating_leap.dds", },          -- Devastating Leap (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_devastating_leap.dds", },       -- Devastating Leap (Skeleton)
        [Unitnames.NPC_Bone_Reaver] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_devastating_leap.dds", },       -- Devastating Leap (Skeleton)
        [Unitnames.NPC_Risen_Dead] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_devastating_leap.dds", },        -- Devastating Leap (Skeleton)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_devastating_leap.dds", }, -- Devastating Leap (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_devastating_leap.dds", },       -- Devastating Leap (Skaafin Miscreal)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_devastating_leap.dds", },     -- Devastating Leap (Skaafin Miscreal)
    },
    -- Slash (Bloodfiend)
    [8550] =
    {
        [Unitnames.NPC_Venomous_Skeleton] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" }, -- Slash (Venomous Skeleton) -- City of Ash II
        [Unitnames.NPC_Skeleton] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" },          -- Slash (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" },       -- Slash (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" },       -- Slash (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" },        -- Slash (Risen Dead)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" }, -- Slash (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_slash.dds" },       -- Slash (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_slash.dds" },     -- Slash (Skaafin Miscreal)
    },
    -- Slash (Bloodfiend)
    [8551] =
    {
        [Unitnames.NPC_Venomous_Skeleton] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" }, -- Slash (Venomous Skeleton) -- City of Ash II
        [Unitnames.NPC_Skeleton] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" },          -- Slash (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" },       -- Slash (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" },       -- Slash (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" },        -- Slash (Risen Dead)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_slash.dds" }, -- Slash (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_slash.dds" },       -- Slash (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_slash.dds" },     -- Slash (Skaafin Miscreal)
    },
    -- Rending Slash (Bloodfiend)
    [8564] =
    {
        [Unitnames.NPC_Skeleton] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_rending_slash.dds" },           -- Rending Slash (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_rending_slash.dds", },       -- Rending Slash (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_rending_slash.dds", },       -- Rending Slash (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_rending_slash.dds" },         -- Rending Slash (Bone Flayer)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_rending_slash.dds", }, -- Rending Slash (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_rending_slash.dds", },       -- Rending Slash (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_rending_slash.dds", },     -- Rending Slash (Skaafin Miscreal)
    },
    -- Flurry (Bloodfiend)
    [8554] =
    {
        [Unitnames.NPC_Skeleton] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" },          -- Flurry (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" },       -- Flurry (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" },       -- Flurry (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" },        -- Flurry (Bone Flayer)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" }, -- Flurry (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_flurry.dds" },       -- Flurry (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_flurry.dds" },     -- Flurry (Skaafin Miscreal)
    },
    -- Flurry (Bloodfiend)
    [9194] =
    {
        [Unitnames.NPC_Skeleton] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" },          -- Flurry (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" },       -- Flurry (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" },       -- Flurry (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" },        -- Flurry (Bone Flayer)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = "LuiExtended/media/icons/abilities/ability_boneflayer_flurry.dds" }, -- Flurry (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_flurry.dds" },       -- Flurry (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = "LuiExtended/media/icons/abilities/ability_skaafin_flurry.dds" },     -- Flurry (Skaafin Miscreal)
    },

    -- MONSTERS
    [9670] =
    {
        [Unitnames.NPC_Spectral_Lamia] = { icon = "LuiExtended/media/icons/abilities/ability_lamia_strike_spectral.dds", }, -- Strike (Lamia)
    },
    -- Base = Bear
    [89119] =
    {
        [Unitnames.NPC_Dire_Wolf] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_wolf.dds" },           -- Summon Beast (Spriggan)
        [Unitnames.NPC_Websnare_Spider] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_spider.dds" },   -- Summon Beast (Spriggan)
        [Unitnames.NPC_Spider] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_spider.dds" },            -- Summon Beast (Spriggan)
        [Unitnames.NPC_Venomspit_Spider] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_spider.dds", }, -- Summon Beast (Spriggan)
    },
    -- Base = Senche-Tiger
    [89102] =
    {
        [Unitnames.NPC_Thunderbug] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_thunderbug.dds" },       -- Summon Beast (Spriggan)
        [Unitnames.NPC_Thunderbug_Lord] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_thunderbug.dds", }, -- Summon Beast (Spriggan)
        [Unitnames.NPC_Hoarvor] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_hoarvor.dds" },             -- Summon Beast (Spriggan)
        [Unitnames.NPC_Lion] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_lion.dds" },                   -- Summon Beast (Spriggan)
        [Unitnames.NPC_Lioness] = { icon = "LuiExtended/media/icons/abilities/ability_summon_beast_lioness.dds" },             -- Summon Beast (Spriggan)
    },
    -- Claw (Lurcher)
    [3757] =
    {
        [Unitnames.Boss_Limbscather] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_red.dds" }, -- Limbscather (Glenumbra)
    },
    -- Pulverize (Lurcher)
    [3860] =
    {
        [Unitnames.Boss_Limbscather] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_pulverize_red.dds" }, -- Limbscather (Glenumbra)
    },
    -- Crushing Limbs (Lurcher)
    [3855] =
    {
        [Unitnames.Boss_Limbscather] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds", }, -- Limbscather (Glenumbra)
    },
    -- Crushing Limbs (Lurcher)
    [38554] =
    {
        [Unitnames.Boss_Limbscather] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds", }, -- Limbscather (Glenumbra)
    },
    -- Choking Pollen (Lurcher)
    [3767] =
    {
        [Unitnames.Boss_Limbscather] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds", }, -- Limbscather (Glenumbra)
    },
    -- Choking Pollen (Lurcher)
    [4769] =
    {
        [Unitnames.Boss_Limbscather] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds", }, -- Limbscather (Glenumbra)
    },
    -- Bite (Assassin Beetle)
    [5278] =
    {
        [Unitnames.Boss_Boilbite] = { icon = "LuiExtended/media/icons/abilities/ability_shalk_bite.dds" }, -- Boilbite (Volenfell)
    },
    -- Feast (Assassin Beetle)
    [91791] =
    {
        [Unitnames.Boss_Boilbite] = { icon = "LuiExtended/media/icons/abilities/ability_shalk_feast.dds" }, -- Boilbite (Volenfell)
    },

    -- CYRODIIL
    -- Cyrodiil Guard See Stealth
    [64674] =
    {
        [Unitnames.NPC_Guard_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ad.dds" },              -- Dominion Guard
        [Unitnames.NPC_Honor_Guard_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_honor_ad.dds", }, -- Dominion Honor Guard
        [Unitnames.NPC_Temple_Guard_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ad.dds" },       -- Dominion Temple Guard
        [Unitnames.NPC_Mender_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ad.dds" },             -- Dominion Mender
        [Unitnames.NPC_Mage_Guard_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ad.dds" },         -- Dominion Mage Guard
        [Unitnames.NPC_Skirmisher_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ad.dds" },         -- Dominion Skirmisher
        [Unitnames.NPC_Archer_Guard_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ad.dds" },       -- Dominion Archer Guard
        [Unitnames.NPC_Guard_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_dc.dds" },              -- Covenant Guard
        [Unitnames.NPC_Honor_Guard_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_honor_dc.dds", }, -- Covenant Honor Guard
        [Unitnames.NPC_Temple_Guard_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_dc.dds" },       -- Covenant Temple Guard
        [Unitnames.NPC_Mender_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_dc.dds" },             -- Covenant Mender
        [Unitnames.NPC_Mage_Guard_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_dc.dds" },         -- Covenant Mage Guard
        [Unitnames.NPC_Skirmisher_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_dc.dds" },         -- Covenant Skirmisher
        [Unitnames.NPC_Archer_Guard_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_dc.dds" },       -- Covenant Archer Guard
        [Unitnames.NPC_Guard_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ep.dds" },              -- Pact Guard
        [Unitnames.NPC_Honor_Guard_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_honor_ep.dds", }, -- Pact Honor Guard
        [Unitnames.NPC_Temple_Guard_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ep.dds" },       -- Pact Temple Guard
        [Unitnames.NPC_Mender_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ep.dds" },             -- Pact Mender
        [Unitnames.NPC_Mage_Guard_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ep.dds" },         -- Pact Mage Guard
        [Unitnames.NPC_Skirmisher_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ep.dds" },         -- Pact Skirmisher
        [Unitnames.NPC_Archer_Guard_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_vigilance_ep.dds" },       -- Pact Archer Guard
    },
    -- Honor Guard Rage (Cyrodiil Honor Guard T1)
    [15780] =
    {
        [Unitnames.NPC_Honor_Guard_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_honor_guard_rage_ad.dds", }, -- Dominion Honor Guard
        [Unitnames.NPC_Honor_Guard_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_honor_guard_rage_dc.dds", }, -- Covenant Honor Guard
        [Unitnames.NPC_Honor_Guard_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_honor_guard_rage_ep.dds", }, -- Pact Honor Guard
    },
    -- Crippling Rage (Cyrodiil Honor Guard T2)
    [46992] =
    {
        [Unitnames.NPC_Honor_Guard_AD] = { icon = "LuiExtended/media/icons/abilities/ability_spell_honor_guard_rage_ad.dds", }, -- Dominion Honor Guard
        [Unitnames.NPC_Honor_Guard_DC] = { icon = "LuiExtended/media/icons/abilities/ability_spell_honor_guard_rage_dc.dds", }, -- Covenant Honor Gaurd
        [Unitnames.NPC_Honor_Guard_EP] = { icon = "LuiExtended/media/icons/abilities/ability_spell_honor_guard_rage_ep.dds", }, -- Pact Honor Guard
    },
    -- Wall of Souls
    [21677] =
    {
        [Unitnames.NPC_Burdening_Eye] = { hide = true }, -- Burdening Eye
        [Unitnames.NPC_Daedroth] = { hide = true },      -- Daedroth
        [Unitnames.NPC_Daedric_Titan] = { hide = true }, -- Daedric Titan
    },

    -- QUESTS
    [37028] =
    {
        [Unitnames.NPC_Auroran_Battlemage] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_1h_light.dds", name = Abilities.Skill_Quick_Strike, }, -- Quick Strike (Auroran Battlemage)
    },
    [37029] =
    {
        [Unitnames.NPC_Auroran_Battlemage] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_1h_light.dds", name = Abilities.Skill_Quick_Strike, }, -- Quick Strike (Auroran Battlemage)
    },
    [37030] =
    {
        [Unitnames.NPC_Auroran_Battlemage] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_1h_light.dds", name = Abilities.Skill_Quick_Strike, }, -- Quick Strike (Auroran Battlemage)
    },

    -- GENERIC
    [44176] =
    {                                                                       -- Flying Immunities
        [Unitnames.Boss_Cell_Haunter] = { hide = true },                    -- Cell Haunter (Banished Cells I)
        [Unitnames.NPC_The_Feast] = { hide = true },                        -- The Feast
        [Unitnames.Boss_Azara_the_Frightener] = { hide = true },            -- Azara the Frightener (Elden Hollow II)
        [Unitnames.Boss_Dark_Ember] = { hide = true },                      -- Dark Ember (City of Ash I)
        [Unitnames.Boss_Lady_Solace] = { hide = true },                     -- Grahtwood (Lady Solace's Fen)
        [Unitnames.Boss_Valanir_the_Restless] = { hide = true },            -- Grahtwood (Valanir's Rest)
        [Unitnames.Boss_Shade_of_Naemon] = { hide = true },                 -- Greenshade (Striking at the Heart)
        [Unitnames.Boss_Tallatta_the_Lustrous] = { hide = true },           -- Malabal Tor (Vulkwasten)
        [Unitnames.Boss_Queen_of_Three_Mercies] = { hide = true },          -- Reaper's March (Waterdancer Falls)
        [Unitnames.NPC_Watcher] = { hide = true },                          -- Watcher
        [Unitnames.Boss_Magdelena] = { hide = true },                       -- Magdelena (Magdelena's Haunt)
        [Unitnames.Boss_Desuuga_the_Siren] = { hide = true },               -- Desuuga the Siren (Siren's Cove)
        [Unitnames.Boss_Uulkar_Bonehand] = { hide = true },                 -- Uulkar Bonehand (Crypt of Hearts I)
        [Unitnames.NPC_Wraith] = { hide = true, zone = { [932] = true } },  -- Wraith (Crypt of Hearts II)
        [Unitnames.NPC_Student] = { hide = true, zone = { [932] = true } }, -- Wraith (Crypt of Hearts II)
    },
}

--- @class (partial) EffectOverrideByName
Effects.EffectOverrideByName = effectOverrideByName
