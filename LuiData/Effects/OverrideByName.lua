-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

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
    {                                                                                                        -- Quick Strike (Shared)
        [Unitnames.NPC_Xivilai] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_XIVILAI_LIGHT_DDS }, -- Xivilai

        -- QUESTS
        [Unitnames.Elite_Vaekar_the_Forgemaster] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_1H_LIGHT_DDS }, -- Vaekar the Forgemaster (Soul Shriven in Coldharbour)
        [Unitnames.NPC_Dremora_Caitiff] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_2H_LIGHT_DDS },         -- Dremora Caitiff (Soul Shriven in Coldharbour)
        [Unitnames.NPC_Skeletal_Ravager] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_LIGHT_DDS },          -- Skeletal Ravager (Soul Shriven in Coldharbour)
        [Unitnames.NPC_Dremora_Baunekyn] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_LIGHT_DDS },         -- Dremora Baunekyn (Soul Shriven in Coldharbour)ability_spell_mace_2h_light.dds

        -- Vvardenfell
        [Unitnames.Elite_First_Mate_Ulveni] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_1H_LIGHT_DDS },   -- First Mate Ulveni (Broken Bonds)

        [Unitnames.Elite_Amuur] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_WEAPON_MELEE_CLEAVER_ATTACK_LIGHT_DDS }, -- Amuur (Auridon - The First Patient)

        -- Daggerfall Covenant
        [Unitnames.Elite_Gornog] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_2H_LIGHT_DDS },    -- Gornog (Stros M'Kai - Innocent Scoundrel)
        [Unitnames.NPC_Drake_Brigand] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_LIGHT_DDS }, -- Drake Brigand (Stros M'Kai)

        -- Elsweyr
        [Unitnames.Elite_Captain_Carvain] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_1H_LIGHT_DDS }, -- Captain Carvain (Elsweyr - Bright Moons, Warm Sands)

        -- Greymoor
        [Unitnames.Elite_Vitrus_the_Bloody] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_LIGHT_DDS }, -- Vitrus the Bloody (Greymoor - Bound in Blood)
        [Unitnames.NPC_Icereach_Brute] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_1H_LIGHT_DDS },      -- Icereach Brute (Greymoor - Bound in Blood)
        [Unitnames.NPC_Icereach_Charger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HAMMER_2H_LIGHT_DDS }, -- Icereach Charger (Greymoor - Bound in Blood)

        -- DUNGEONS
        [Unitnames.NPC_Darkfern_Mauler] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_light_reach.dds" }, -- Darkfern Mauler (Elden Hollow I)
        [Unitnames.Boss_Nenesh_gro_Mal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_CLUB2H_LIGHT_ATTACK_DDS },         -- Nenesh gro Mal (Elden Hollow I)
        [Unitnames.NPC_Dremora_Berserker] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_1H_LIGHT_DDS },              -- Dremora Berserker (City of Ash I)
        [Unitnames.Boss_The_Mage_Master] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_2H_LIGHT_DDS },             -- The Mage Master (Crypt of Hearts I)
        [Unitnames.Boss_Dogas_the_Berserker] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_1H_LIGHT_DDS },           -- Dogas the Berserker (Crypt of Hearts I)
        [Unitnames.NPC_Dremora_Kynval] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_1H_LIGHT_DDS },                -- Dremora Kynval (City of Ash I)
        [Unitnames.Boss_Rukhan] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_LIGHT_DDS },                       -- Rukhan (City of Ash I)
        [Unitnames.NPC_Xivilai_Ravager] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_LIGHT_DDS },               -- Xivilai Ravager (City of Ash I)
        [Unitnames.NPC_Fire_Ravager] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_LIGHT_DDS },                  -- Fire Ravager (City of Ash I)
        [Unitnames.NPC_Xivilai_Boltaic] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_LIGHT_DDS },               -- Fire Ravager (City of Ash I)
        [Unitnames.NPC_Sea_Viper_Strongarm] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_1H_LIGHT_DDS },            -- Sea Viper Strongarm (Tempest Island)
        [Unitnames.NPC_Sea_Viper_Berserker] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_1H_LIGHT_DDS },            -- Sea Viper Berserker (Tempest Island)
        [Unitnames.NPC_Sea_Viper_Charger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_LIGHT_DDS },             -- Sea Viper Charger (Tempest Island)
        [Unitnames.Boss_Commodore_Ohmanil] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_LIGHT_DDS },             -- Commodore Ohmanil (Tempest Island)
        [Unitnames.Boss_Ibelgast] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_2H_LIGHT_DDS },                    -- Ibelgast (Crypt of Hearts II)
        [Unitnames.NPC_Spiderkith_Venifex] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_2H_LIGHT_DDS },           -- Spiderkith Venifex (Crypt of Hearts II)
        [Unitnames.NPC_Spiderkith_Warper] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_DAGGER_1H_LIGHT_DDS },           -- Spiderkith Warper (Crypt of Hearts II)
        [Unitnames.Boss_Chamber_Guardian] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_LIGHT_DDS },              -- Chamber Guardian (Crypt of Hearts II)
    },
    -- Quick Strike (Rogue/Skirmisher)
    [29035] =
    {
        -- QUESTS
        [Unitnames.NPC_Slaver_Cutthroat] = { con = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_DAGGER_1H_LIGHT_DDS, }, -- Firemoth Island (Vvardenfell - Broken Bonds) -- Slaver Cutthroat

        -- Daggerfall Covenant
        [Unitnames.NPC_Dogeater_Skirmisher] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_DAGGER_1H_LIGHT_DDS, }, -- Dogeater Skirmisher (Stros M'Kai)
        [Unitnames.NPC_Drake_Cutthroat] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_DAGGER_1H_LIGHT_DDS, },     -- Drake Cutthroat (Stros M'Kai)
    },
    -- Slash (Valaran Stormcaller)
    [26332] =
    {
        [Unitnames.NPC_Lightning_Avatar] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_1H_LIGHT_ETHEREAL_DDS, }, -- Lightning Avatar (Tempest Island)
    },
    [14096] =
    {                                                                                                                   -- Heavy Attack (Footsoldier)
        [Unitnames.Elite_Amuur] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_WEAPON_MELEE_CLEAVER_ATTACK_HEAVY_DDS, }, -- Amuur (The First Patient)
    },

    -- HUMAN NPCS
    [29521] =
    {                                                         -- Aura of Protection (Shaman)
        [Unitnames.NPC_Aura_of_Protection] = { hide = true }, -- Aura of Protection (Aura of Protection) -- Hides this buff only on the Goblin Aura of Protection to prevent duplicate display
    },
    [86704] =
    {                                                                                                                  -- Chop (Peasant)
        [Unitnames.NPC_Hleran_Noble] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_WEAPON_PEASANT_DAGGER_LIGHT_DDS, }, -- Chop (Hleran Noble)
    },
    [86705] =
    {                                                                                                                  -- Lop (Peasant)
        [Unitnames.NPC_Hleran_Noble] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_WEAPON_PEASANT_DAGGER_LIGHT_DDS, }, -- Lop (Hleran Noble)
    },

    [88251] =
    {
        [Unitnames.NPC_Great_Bear] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_CALL_ALLY_BEAR_DDS },    -- Call Ally (Pet Ranger)
        [Unitnames.NPC_Spider] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_CALL_ALLY_SPIDER_DDS },      -- Call Ally (Pet Ranger)
        [Unitnames.NPC_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_CALL_ALLY_TIGER_DDS }, -- Call Ally (Pet Ranger)
    },

    [88248] =
    {
        [Unitnames.NPC_Spider] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_CALL_ALLY_SPIDER_DDS },            -- Call Ally (Pet Ranger)
        [Unitnames.NPC_Venomspit_Spider] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_CALL_ALLY_SPIDER_DDS, }, -- Call Ally (Pet Ranger)
        [Unitnames.NPC_Websnare_Spider] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_CALL_ALLY_SPIDER_DDS, },  -- Call Ally (Pet Ranger)
    },

    -- ANIMALS
    -- Rend (Lion)
    [7170] =
    {
        [Unitnames.NPC_Lion] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LION_REND_DDS },                            -- Rend (Lion)
        [Unitnames.Boss_Desert_Lion] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LION_REND_DDS },                    -- Rend (Lion)
        [Unitnames.NPC_Lioness] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LIONESS_REND_DDS },                      -- Rend (Lion)
        [Unitnames.Boss_Desert_Lioness] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LIONESS_REND_DDS },              -- Rend (Lion)
        [Unitnames.NPC_Sabre_Cat] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SABRECAT_REND_DDS },                   -- Rend (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                  -- Rend (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_WHITE_DDS, }, -- Rend (Senche-Tiger)
        ["The Tiger"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                                 -- Rend (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },         -- Rend (Senche-Tiger)
        ["Esh'tabe"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                                  -- Rend (Senche-Tiger)
        ["Raakhet"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                                   -- Rend (Senche-Tiger)
        ["Razorclaw"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                                 -- Rend (Senche-Tiger)
        [Unitnames.NPC_Senche_Panther] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },         -- Rend (Senche-Panther)
        [Unitnames.Boss_Silentpaw] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },             -- Rend (Senche-Panther)
        [Unitnames.Boss_Heartstalker] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },          -- Rend (Senche-Panther)
        [Unitnames.Boss_Nighteyes] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },             -- Rend (Senche-Panther)
        [Unitnames.Boss_Shadowhiskers] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },         -- Rend (Senche-Panther)
        [Abilities.Skill_Senche_Spirit] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_GHOST_DDS, }, -- Rend (Senche Spirit)
    },
    -- Rend (Lion)
    [60630] =
    {
        [Unitnames.NPC_Lion] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LION_REND_DDS },                            -- Rend (Lion)
        [Unitnames.Boss_Desert_Lion] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LION_REND_DDS },                    -- Rend (Lion)
        [Unitnames.NPC_Lioness] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LIONESS_REND_DDS },                      -- Rend (Lion)
        [Unitnames.Boss_Desert_Lioness] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LIONESS_REND_DDS },              -- Rend (Lion)
        [Unitnames.NPC_Sabre_Cat] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SABRECAT_REND_DDS },                   -- Rend (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                  -- Rend (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_WHITE_DDS, }, -- Rend (Senche-Tiger)
        ["The Tiger"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                                 -- Rend (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },         -- Rend (Senche-Tiger)
        ["Esh'tabe"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                                  -- Rend (Senche-Tiger)
        ["Raakhet"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                                   -- Rend (Senche-Tiger)
        ["Razorclaw"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_REND_DDS },                                 -- Rend (Senche-Tiger)
        [Unitnames.NPC_Senche_Panther] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },         -- Rend (Senche-Panther)
        [Unitnames.Boss_Silentpaw] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },             -- Rend (Senche-Panther)
        [Unitnames.Boss_Heartstalker] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },          -- Rend (Senche-Panther)
        [Unitnames.Boss_Nighteyes] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },             -- Rend (Senche-Panther)
        [Unitnames.Boss_Shadowhiskers] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_DDS },         -- Rend (Senche-Panther)
        [Abilities.Skill_Senche_Spirit] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_REND_GHOST_DDS, }, -- Rend (Senche Spirit)
    },
    -- Claw (Lion)
    [60641] =
    {
        [Unitnames.NPC_Sabre_Cat] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SABRECAT_CLAW_DDS },                   -- Claw (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_CLAW_DDS },                  -- Claw (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_CLAW_WHITE_DDS, }, -- Claw (Senche-Tiger)
        ["The Tiger"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_CLAW_DDS },                                 -- Claw (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_CLAW_DDS },         -- Claw (Senche-Tiger)
        ["Esh'tabe"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_CLAW_DDS },                                  -- Claw (Senche-Tiger)
        ["Raakhet"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_CLAW_DDS },                                   -- Claw (Senche-Tiger)
        ["Razorclaw"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_CLAW_DDS },                                 -- Claw (Senche-Tiger)
    },
    -- Bite (Lion)
    [7158] =
    {
        [Unitnames.NPC_Lion] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LION_BITE_DDS },                            -- Bite (Lion)
        [Unitnames.NPC_Lioness] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LIONESS_BITE_DDS },                      -- Bite (Lion)
        [Unitnames.Boss_Desert_Lioness] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LIONESS_BITE_DDS },              -- Bite (Lion)
        [Unitnames.NPC_Sabre_Cat] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SABRECAT_BITE_DDS },                   -- Bite (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_BITE_DDS },                  -- Bite (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_BITE_WHITE_DDS, }, -- Bite (Senche-Tiger)
        ["The Tiger"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_BITE_DDS },                                 -- Bite (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_BITE_DDS },         -- Bite (Senche-Tiger)
        ["Esh'tabe"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_BITE_DDS },                                  -- Bite (Senche-Tiger)
        ["Raakhet"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_BITE_DDS },                                   -- Bite (Senche-Tiger)
        ["Razorclaw"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_BITE_DDS },                                 -- Bite (Senche-Tiger)
        [Unitnames.NPC_Senche_Panther] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_BITE_DDS },         -- Bite (Senche-Panther)
        [Unitnames.Boss_Silentpaw] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_BITE_DDS },             -- Bite (Senche-Panther)
        [Unitnames.Boss_Heartstalker] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_BITE_DDS },          -- Bite (Senche-Panther)
        [Unitnames.Boss_Nighteyes] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_BITE_DDS },             -- Bite (Senche-Panther)
        [Unitnames.Boss_Shadowhiskers] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_BITE_DDS },         -- Bite (Senche-Panther)
        [Abilities.Skill_Senche_Spirit] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_BITE_GHOST_DDS, }, -- Bite (Senche Spirit)
    },
    -- Double Strike (Lion)
    [7161] =
    {
        [Unitnames.NPC_Sabre_Cat] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SABRECAT_DOUBLE_STRIKE_DDS },                   -- Double Strike (Sabre Cat)
        [Unitnames.NPC_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_DOUBLE_STRIKE_DDS },                  -- Double Strike (Senche-Tiger)
        [Unitnames.Boss_Nindaeril_the_Monsoon] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_DOUBLE_STRIKE_WHITE_DDS, }, -- Double Strike (Senche-Tiger)
        ["The Tiger"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_DOUBLE_STRIKE_DDS },                                 -- Double Strike (Senche-Tiger)
        [Unitnames.NPC_Spectral_Senche_Tiger] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_DOUBLE_STRIKE_DDS, },        -- Double Strike (Senche-Tiger)
        ["Esh'tabe"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_DOUBLE_STRIKE_DDS },                                  -- Double Strike (Senche-Tiger)
        ["Raakhet"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_DOUBLE_STRIKE_DDS },                                   -- Double Strike (Senche-Tiger)
        ["Razorclaw"] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHE_DOUBLE_STRIKE_DDS },                                 -- Double Strike (Senche-Tiger)
        [Unitnames.NPC_Senche_Panther] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_DOUBLE_STRIKE_DDS, },        -- Double Strike (Senche-Panther)
        [Unitnames.Boss_Silentpaw] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_DOUBLE_STRIKE_DDS, },            -- Double Strike (Senche-Panther)
        [Unitnames.Boss_Heartstalker] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_DOUBLE_STRIKE_DDS, },         -- Double Strike (Senche-Panther)
        [Unitnames.Boss_Nighteyes] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_DOUBLE_STRIKE_DDS, },            -- Double Strike (Senche-Panther)
        [Unitnames.Boss_Shadowhiskers] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_DOUBLE_STRIKE_DDS, },        -- Double Strike (Senche-Panther)
        [Abilities.Skill_Senche_Spirit] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SENCHEPANTHER_DOUBLE_STRIKE_GHOST_DDS, }, -- Double Strike (Senche Spirit)
    },
    -- Slam (Skeever / Kagouti)
    [5362] =
    {
        [Unitnames.NPC_Kagouti] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_KAGOUTI_SLAM_DDS },      -- Slam (Kagouti)
        [Unitnames.NPC_Bull_Kagouti] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_KAGOUTI_SLAM_DDS }, -- Slam (Kagouti)
        [Unitnames.NPC_Daedrat] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DAEDRAT_SLAM_DDS },      -- Slam (Daedrat)
    },
    -- Rend (Skeever)
    [21904] =
    {
        [Unitnames.NPC_Daedrat] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DAEDRAT_REND_DDS }, -- Rend (Daedrat)
    },
    -- Bite (Wolf)
    [4022] =
    {
        [Unitnames.NPC_Jackal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_JACKAL_BITE_DDS }, -- Bite (Jackal)
    },
    -- Rotbone (Wolf)
    [42844] =
    {
        [Unitnames.NPC_Jackal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_JACKAL_ROTBONE_DDS }, -- Rotbone (Wolf)
    },
    -- Helljoint (Wolf)
    [14523] =
    {
        [Unitnames.NPC_Jackal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_JACKAL_HELLJOINT_DDS }, -- Helljoint (Wolf)
    },
    -- Helljoint (Wolf)
    [75818] =
    {
        [Unitnames.NPC_Jackal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_JACKAL_HELLJOINT_DDS }, -- Helljoint (Wolf)
    },
    -- Devastating Leap (Bloodfiend)
    [8569] =
    {
        [Unitnames.NPC_Skeleton] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_DEVASTATING_LEAP_DDS, },          -- Devastating Leap (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_DEVASTATING_LEAP_DDS, },       -- Devastating Leap (Skeleton)
        [Unitnames.NPC_Bone_Reaver] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_DEVASTATING_LEAP_DDS, },       -- Devastating Leap (Skeleton)
        [Unitnames.NPC_Risen_Dead] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_DEVASTATING_LEAP_DDS, },        -- Devastating Leap (Skeleton)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_DEVASTATING_LEAP_DDS, }, -- Devastating Leap (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_DEVASTATING_LEAP_DDS, },       -- Devastating Leap (Skaafin Miscreal)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_DEVASTATING_LEAP_DDS, },     -- Devastating Leap (Skaafin Miscreal)
    },
    -- Slash (Bloodfiend)
    [8550] =
    {
        [Unitnames.NPC_Venomous_Skeleton] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS }, -- Slash (Venomous Skeleton) -- City of Ash II
        [Unitnames.NPC_Skeleton] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS },          -- Slash (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS },       -- Slash (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS },       -- Slash (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS },        -- Slash (Risen Dead)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS }, -- Slash (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_SLASH_DDS },       -- Slash (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_SLASH_DDS },     -- Slash (Skaafin Miscreal)
    },
    -- Slash (Bloodfiend)
    [8551] =
    {
        [Unitnames.NPC_Venomous_Skeleton] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS }, -- Slash (Venomous Skeleton) -- City of Ash II
        [Unitnames.NPC_Skeleton] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS },          -- Slash (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS },       -- Slash (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS },       -- Slash (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS },        -- Slash (Risen Dead)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_SLASH_DDS }, -- Slash (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_SLASH_DDS },       -- Slash (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_SLASH_DDS },     -- Slash (Skaafin Miscreal)
    },
    -- Rending Slash (Bloodfiend)
    [8564] =
    {
        [Unitnames.NPC_Skeleton] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_RENDING_SLASH_DDS },           -- Rending Slash (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_RENDING_SLASH_DDS, },       -- Rending Slash (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_RENDING_SLASH_DDS, },       -- Rending Slash (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_RENDING_SLASH_DDS },         -- Rending Slash (Bone Flayer)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_RENDING_SLASH_DDS, }, -- Rending Slash (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_RENDING_SLASH_DDS, },       -- Rending Slash (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_RENDING_SLASH_DDS, },     -- Rending Slash (Skaafin Miscreal)
    },
    -- Flurry (Bloodfiend)
    [8554] =
    {
        [Unitnames.NPC_Skeleton] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS },          -- Flurry (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS },       -- Flurry (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS },       -- Flurry (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS },        -- Flurry (Bone Flayer)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS }, -- Flurry (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_FLURRY_DDS },       -- Flurry (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_FLURRY_DDS },     -- Flurry (Skaafin Miscreal)
    },
    -- Flurry (Bloodfiend)
    [9194] =
    {
        [Unitnames.NPC_Skeleton] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS },          -- Flurry (Skeleton)
        [Unitnames.NPC_Bone_Flayer] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS },       -- Flurry (Bone Flayer)
        [Unitnames.NPC_Bone_Reaver] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS },       -- Flurry (Bone Flayer)
        [Unitnames.NPC_Risen_Dead] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS },        -- Flurry (Bone Flayer)
        [Unitnames.NPC_Graveoath_Ravener] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BONEFLAYER_FLURRY_DDS }, -- Flurry (Graveoath Ravener)
        [Unitnames.NPC_Skaafin_Wretch] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_FLURRY_DDS },       -- Flurry (Skaafin Wretch)
        [Unitnames.NPC_Skaafin_Miscreal] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SKAAFIN_FLURRY_DDS },     -- Flurry (Skaafin Miscreal)
    },

    -- MONSTERS
    [9670] =
    {
        [Unitnames.NPC_Spectral_Lamia] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LAMIA_STRIKE_SPECTRAL_DDS, }, -- Strike (Lamia)
    },
    -- Base = Bear
    [89119] =
    {
        [Unitnames.NPC_Dire_Wolf] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_WOLF_DDS },           -- Summon Beast (Spriggan)
        [Unitnames.NPC_Websnare_Spider] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_SPIDER_DDS },   -- Summon Beast (Spriggan)
        [Unitnames.NPC_Spider] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_SPIDER_DDS },            -- Summon Beast (Spriggan)
        [Unitnames.NPC_Venomspit_Spider] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_SPIDER_DDS, }, -- Summon Beast (Spriggan)
    },
    -- Base = Senche-Tiger
    [89102] =
    {
        [Unitnames.NPC_Thunderbug] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_THUNDERBUG_DDS },       -- Summon Beast (Spriggan)
        [Unitnames.NPC_Thunderbug_Lord] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_THUNDERBUG_DDS, }, -- Summon Beast (Spriggan)
        [Unitnames.NPC_Hoarvor] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_HOARVOR_DDS },             -- Summon Beast (Spriggan)
        [Unitnames.NPC_Lion] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_LION_DDS },                   -- Summon Beast (Spriggan)
        [Unitnames.NPC_Lioness] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SUMMON_BEAST_LIONESS_DDS },             -- Summon Beast (Spriggan)
    },
    -- Claw (Lurcher)
    [3757] =
    {
        [Unitnames.Boss_Limbscather] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_RED_DDS }, -- Limbscather (Glenumbra)
    },
    -- Pulverize (Lurcher)
    [3860] =
    {
        [Unitnames.Boss_Limbscather] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_PULVERIZE_RED_DDS }, -- Limbscather (Glenumbra)
    },
    -- Crushing Limbs (Lurcher)
    [3855] =
    {
        [Unitnames.Boss_Limbscather] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS, }, -- Limbscather (Glenumbra)
    },
    -- Crushing Limbs (Lurcher)
    [38554] =
    {
        [Unitnames.Boss_Limbscather] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS, }, -- Limbscather (Glenumbra)
    },
    -- Choking Pollen (Lurcher)
    [3767] =
    {
        [Unitnames.Boss_Limbscather] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS, }, -- Limbscather (Glenumbra)
    },
    -- Choking Pollen (Lurcher)
    [4769] =
    {
        [Unitnames.Boss_Limbscather] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS, }, -- Limbscather (Glenumbra)
    },
    -- Bite (Assassin Beetle)
    [5278] =
    {
        [Unitnames.Boss_Boilbite] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SHALK_BITE_DDS }, -- Boilbite (Volenfell)
    },
    -- Feast (Assassin Beetle)
    [91791] =
    {
        [Unitnames.Boss_Boilbite] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SHALK_FEAST_DDS }, -- Boilbite (Volenfell)
    },

    -- CYRODIIL
    -- Cyrodiil Guard See Stealth
    [64674] =
    {
        [Unitnames.NPC_Guard_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_AD_DDS },              -- Dominion Guard
        [Unitnames.NPC_Honor_Guard_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_HONOR_AD_DDS, }, -- Dominion Honor Guard
        [Unitnames.NPC_Temple_Guard_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_AD_DDS },       -- Dominion Temple Guard
        [Unitnames.NPC_Mender_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_AD_DDS },             -- Dominion Mender
        [Unitnames.NPC_Mage_Guard_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_AD_DDS },         -- Dominion Mage Guard
        [Unitnames.NPC_Skirmisher_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_AD_DDS },         -- Dominion Skirmisher
        [Unitnames.NPC_Archer_Guard_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_AD_DDS },       -- Dominion Archer Guard
        [Unitnames.NPC_Guard_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_DC_DDS },              -- Covenant Guard
        [Unitnames.NPC_Honor_Guard_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_HONOR_DC_DDS, }, -- Covenant Honor Guard
        [Unitnames.NPC_Temple_Guard_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_DC_DDS },       -- Covenant Temple Guard
        [Unitnames.NPC_Mender_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_DC_DDS },             -- Covenant Mender
        [Unitnames.NPC_Mage_Guard_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_DC_DDS },         -- Covenant Mage Guard
        [Unitnames.NPC_Skirmisher_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_DC_DDS },         -- Covenant Skirmisher
        [Unitnames.NPC_Archer_Guard_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_DC_DDS },       -- Covenant Archer Guard
        [Unitnames.NPC_Guard_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_EP_DDS },              -- Pact Guard
        [Unitnames.NPC_Honor_Guard_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_HONOR_EP_DDS, }, -- Pact Honor Guard
        [Unitnames.NPC_Temple_Guard_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_EP_DDS },       -- Pact Temple Guard
        [Unitnames.NPC_Mender_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_EP_DDS },             -- Pact Mender
        [Unitnames.NPC_Mage_Guard_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_EP_DDS },         -- Pact Mage Guard
        [Unitnames.NPC_Skirmisher_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_EP_DDS },         -- Pact Skirmisher
        [Unitnames.NPC_Archer_Guard_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_VIGILANCE_EP_DDS },       -- Pact Archer Guard
    },
    -- Honor Guard Rage (Cyrodiil Honor Guard T1)
    [15780] =
    {
        [Unitnames.NPC_Honor_Guard_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HONOR_GUARD_RAGE_AD_DDS, }, -- Dominion Honor Guard
        [Unitnames.NPC_Honor_Guard_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HONOR_GUARD_RAGE_DC_DDS, }, -- Covenant Honor Guard
        [Unitnames.NPC_Honor_Guard_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HONOR_GUARD_RAGE_EP_DDS, }, -- Pact Honor Guard
    },
    -- Crippling Rage (Cyrodiil Honor Guard T2)
    [46992] =
    {
        [Unitnames.NPC_Honor_Guard_AD] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HONOR_GUARD_RAGE_AD_DDS, }, -- Dominion Honor Guard
        [Unitnames.NPC_Honor_Guard_DC] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HONOR_GUARD_RAGE_DC_DDS, }, -- Covenant Honor Gaurd
        [Unitnames.NPC_Honor_Guard_EP] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HONOR_GUARD_RAGE_EP_DDS, }, -- Pact Honor Guard
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
        [Unitnames.NPC_Auroran_Battlemage] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_1H_LIGHT_DDS, name = Abilities.Skill_Quick_Strike, }, -- Quick Strike (Auroran Battlemage)
    },
    [37029] =
    {
        [Unitnames.NPC_Auroran_Battlemage] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_1H_LIGHT_DDS, name = Abilities.Skill_Quick_Strike, }, -- Quick Strike (Auroran Battlemage)
    },
    [37030] =
    {
        [Unitnames.NPC_Auroran_Battlemage] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_1H_LIGHT_DDS, name = Abilities.Skill_Quick_Strike, }, -- Quick Strike (Auroran Battlemage)
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
