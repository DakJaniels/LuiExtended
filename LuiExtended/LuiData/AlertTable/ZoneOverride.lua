-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
local UnitNames = Data.UnitNames
local Zonenames = Data.ZoneNames

--- @class (partial) AlertZoneOverride
local alertZoneOverride =
{

    [7835] =
    {                                                                 -- Convalescence (Lamia)
        [131] = UnitNames.NPC_Lamia_Curare,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Lamia_Curare, -- Tempest Island
    },
    [9680] =
    {                                                                 -- Summon Spectral Lamia
        [131] = UnitNames.NPC_Lamia_Curare,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Lamia_Curare, -- Tempest Island
    },

    [35220] =
    { -- Impending Storm (Storm Atronach)

        -- DUNGEONS
        [681] = UnitNames.NPC_Storm_Atronach,                           -- City of Ash II
        [131] = UnitNames.NPC_Storm_Atronach,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Storm_Atronach, -- Tempest Island
    },

    [54021] =
    { -- Release Flame (Marruz)

        -- DUNGEONS
        [681] = UnitNames.NPC_Xivilai_Immolator, -- City of Ash II
    },

    [4591] =
    { -- Sweep (Crocodile)

        -- DUNGEONS
        [681] = UnitNames.NPC_Crocodile, -- City of Ash II
    },

    [34742] =
    { -- Fiery Breath (Dragonknight)

        -- DUNGEONS
        [176] = UnitNames.NPC_Dremora_Kynval,   -- City of Ash I
        [681] = UnitNames.NPC_Dremora_Kynval,   -- City of Ash 2
        [22] = UnitNames.NPC_Imperial_Overseer, -- Volenfell
    },

    [57534] =
    { -- Focused Healing (Healer)

        -- DUNGEONS
        -- [126] = UnitNames.NPC_Darkfern_Healer, -- Elden Hollow I -- Can't add because of Thalmor healers at the beginning of the dungeon.
        [931] = UnitNames.NPC_Dremora_Invoker,                            -- Elden Hollow II
        [681] = UnitNames.NPC_Dremora_Gandrakyn,                          -- City of Ash II
        [131] = UnitNames.NPC_Sea_Viper_Healer,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Healer, -- Tempest Island
        [932] = UnitNames.NPC_Spiderkith_Cauterizer,                      -- Crypt of Hearts II
        [22] = UnitNames.NPC_Treasure_Hunter_Healer,                      -- Volenfell
    },

    [35151] =
    { -- Spell Absorption (Spirit Mage)

        -- DUNGEONS
        [931] = UnitNames.NPC_Dremora_Invoker, -- Elden Hollow II
    },
    [14472] =
    { -- Burdening Eye (Spirit Mage)

        -- DUNGEONS
        [931] = UnitNames.NPC_Dremora_Invoker, -- Elden Hollow II
    },

    [12459] =
    {                                                -- Winter's Reach (Frost Mage)
        -- QUESTS
        [1160] = UnitNames.NPC_Icereach_Chillrender, -- Deepwood Vale (Greymoor)
        -- DUNGEONS
        [380] = UnitNames.NPC_Banished_Mage,         -- Banished Cells I
    },
    [14194] =
    {                                                -- Ice Barrier (Frost Mage)
        -- QUESTS
        [1160] = UnitNames.NPC_Icereach_Chillrender, -- Deepwood Vale (Greymoor)
        -- DUNGEONS
        [380] = UnitNames.NPC_Banished_Mage,         -- Banished Cells I
    },

    [4337] =
    {                                        -- Winter's Reach (Wraith)
        -- DUNGEONS
        [380] = UnitNames.Boss_Cell_Haunter, -- Banished Cells I
        [935] = UnitNames.NPC_Wraith,        -- Banished Cells II (Summon Only)
        [130] = UnitNames.NPC_Wraith,        -- Crypt of Hearts I
    },

    [36985] =
    {                                             -- Void (Time Bomb Mage)
        [555] = UnitNames.Boss_Vicereeve_Pelidil, -- Abecean Sea

        -- DUNGEONS
        [130] = UnitNames.NPC_Skeletal_Runecaster, -- Crypt of Hearts I
        [932] = UnitNames.Boss_Mezeluth,           -- Crypt of Hearts II
    },

    [29471] =
    {                                                                 -- Thunder Thrall (Storm Mage)
        [Zonenames.Zone_Tanzelwil] = UnitNames.NPC_Ancestral_Tempest, -- Tanzelwil
        [416] = UnitNames.NPC_Ancestral_Tempest,                      -- Inner Tanzelwil
        [810] = UnitNames.Elite_Canonreeve_Malanie,                   -- Smuggler's Tunnel (Auridon)
        -- [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Skeletal_Tempest, -- Castle Rilis (Auridon) -- Can't, elite here stops this from working
        [392] = UnitNames.NPC_Skeletal_Tempest,                       -- The Vault of Exile (Auridon)
        [394] = UnitNames.Elite_Uricantar,                            -- Ezduiin Undercroft (Auridon)

        -- DC Zones
        [534] = UnitNames.Elite_King_Demog,        -- King Demog (Stros M'Kai)

        [389] = UnitNames.NPC_Spectral_Storm_Mage, -- Reliquary Ruins
        [555] = UnitNames.NPC_Sea_Viper_Tempest,   -- Abecean Sea

        -- DUNGEONS
        [681] = UnitNames.NPC_Urata_Elementalist,   -- City of Ash II
        [932] = UnitNames.NPC_Spiderkith_Enervator, -- Crypt of Hearts II
    },
    [29510] =
    {                                                                    -- Thunder Hammer (Thundermaul)
        [Zonenames.Zone_Maormer_Invasion_Camp] = UnitNames.Elite_Arstul, -- Maormer Invasion Camp (Auridon)
        [394] = UnitNames.NPC_Thundermaul,                               -- Ezduiin Undercroft (Auridon)
        [399] = UnitNames.NPC_Skeletal_Thundermaul,                      -- Wansalen (Auridon - Delve)

        [435] = UnitNames.NPC_Sainted_Charger,                           -- Cathedral of the Golden Path
        [555] = UnitNames.NPC_Sea_Viper_Charger,                         -- Abecean Sea

        -- Greymoor
        [1160] = UnitNames.NPC_Icereach_Charger, -- Deepwood Vale (Greymoor)

        -- DUNGEONS
        [131] = UnitNames.NPC_Sea_Viper_Charger,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Charger, -- Tempest Island
    },
    [17867] =
    {                                                                    -- Shock Aura (Thundermaul)
        [Zonenames.Zone_Maormer_Invasion_Camp] = UnitNames.Elite_Arstul, -- Maormer Invasion Camp (Auridon)
        [394] = UnitNames.NPC_Thundermaul,                               -- Ezduiin Undercroft (Auridon)
        [399] = UnitNames.NPC_Skeletal_Thundermaul,                      -- Wansalen (Auridon - Delve)

        [435] = UnitNames.NPC_Sainted_Charger,                           -- Cathedral of the Golden Path
        [555] = UnitNames.NPC_Sea_Viper_Charger,                         -- Abecean Sea

        -- Greymoor
        [1160] = UnitNames.NPC_Icereach_Charger, -- Deepwood Vale (Greymoor)

        -- DUNGEONS
        [126] = UnitNames.Boss_Nenesh_gro_Mal,                             -- Elden Hollow I
        [131] = UnitNames.NPC_Sea_Viper_Charger,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Charger, -- Tempest Island
    },
    [29520] =
    { -- Aura of Protection (Shaman)

        -- DUNGEONS
        [931] = UnitNames.Boss_The_Shadow_Guard, -- Elden Hollow II
        -- [176] = UnitNames.NPC_Dremora_Hauzkyn, -- City of Ash I -- Can't use due to Dremora Shaman
    },
    [28408] =
    { -- Whirlwind (Skirmisher)

        -- QUESTS
        [968] = UnitNames.NPC_Slaver_Cutthroat,                                        -- Firemoth Island (Vvardenfell)

        [Zonenames.Zone_Mathiisen] = UnitNames.NPC_Heritance_Cutthroat,                -- Mathiisen (Auridon)
        [810] = UnitNames.NPC_Heritance_Cutthroat,                                     -- Smuggler's Tunnel (Auridon)
        -- [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Skeletal_Striker, -- Castle Rilis (Auridon) -- Can't, elite here stops this from working
        [392] = UnitNames.NPC_Skeletal_Striker,                                        -- The Vault of Exile (Auridon)
        [Zonenames.Zone_Soulfire_Plateau] = UnitNames.NPC_Skeletal_Slayer,             -- Soulfire Plateau (Auridon)
        [Zonenames.Zone_Silsailen] = UnitNames.NPC_Heritance_Cutthroat,                -- Silsailen (Auridon)
        [Zonenames.Zone_Errinorne_Isle] = UnitNames.NPC_Heritance_Cutthroat,           -- Errinorne Isle (Auridon)
        [Zonenames.Zone_Quendeluun] = UnitNames.NPC_Heritance_Cutthroat,               -- Quendeluun (Auridon)
        [Zonenames.Zone_Wansalen] = UnitNames.NPC_Heritance_Cutthroat,                 -- Quendeluun (Auridon) - For a little section with npcs outside of the delv near Quendeluun.
        [393] = UnitNames.NPC_Heritance_Cutthroat,                                     -- Saltspray Cave (Auridon)
        [390] = UnitNames.NPC_Heritance_Cutthroat,                                     -- The Veiled Keep
        [Zonenames.Zone_Heritance_Proving_Ground] = UnitNames.NPC_Heritance_Cutthroat, -- Heritance Proving Ground (Auridon)
        [Zonenames.Zone_Isle_of_Contemplation] = UnitNames.Elite_Karulae,              -- Isle of Contemplation (Auridon)

        [548] = UnitNames.NPC_Bandit_Rogue,                                            -- Silatar

        -- DUNGEONS
        [126] = UnitNames.NPC_Darkfern_Stalker,                                 -- Elden Hollow I
        -- [176] = UnitNames.NPC_Dagonite_Assassin, -- City of Ash I -- Can't use due to Assassin Exemplar
        [681] = UnitNames.NPC_Urata_Militant,                                   -- City of Ash II
        [Zonenames.Zone_Tempest_Island] = UnitNames.Boss_Yalorasse_the_Speaker, -- Tempest Island
    },
    [37108] =
    {                                                                                 -- Arrow Spray (Archer)
        -- QUESTS
        [0] = UnitNames.NPC_Skeletal_Archer,                                          -- The Wailing Prison (Soul Shriven in Coldharbour)
        [968] = UnitNames.NPC_Slaver_Archer,                                          -- Firemoth Island (Vvardenfell)
        [1013] = UnitNames.NPC_Dessicated_Archer,                                     -- Summerset (The Mind Trap)

        [Zonenames.Zone_Maormer_Invasion_Camp] = UnitNames.NPC_Sea_Viper_Deadeye,     -- Maormer Invasion Camp (Auridon)
        [Zonenames.Zone_South_Beacon] = UnitNames.NPC_Sea_Viper_Deadeye,              -- South Beacon (Auridon)
        [Zonenames.Zone_Mathiisen] = UnitNames.NPC_Heritance_Deadeye,                 -- Mathiisen (Auridon)
        [810] = UnitNames.NPC_Heritance_Deadeye,                                      -- Smuggler's Tunnel (Auridon)
        -- [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Skeletal_Archer, -- Castle Rilis (Auridon) -- Can't, elite here stops this from working
        [392] = UnitNames.NPC_Skeletal_Archer,                                        -- The Vault of Exile (Auridon)
        [Zonenames.Zone_Soulfire_Plateau] = UnitNames.NPC_Skeletal_Archer,            -- Soulfire Plateau (Auridon)
        [Zonenames.Zone_Hightide_Keep] = UnitNames.NPC_Skeletal_Archer,               -- Hightide Keep (Auridon)
        [Zonenames.Zone_Errinorne_Isle] = UnitNames.NPC_Heritance_Deadeye,            -- Errinorne Isle (Auridon)
        [Zonenames.Zone_Captain_Blanchetes_Ship] = UnitNames.NPC_Ghost_Viper_Deadeye, -- Captain Blanchete's Ship (Auridon)
        [Zonenames.Zone_Ezduiin] = UnitNames.NPC_Spirit_Deadeye,                      -- Ezduiin (Auridon)
        [Zonenames.Zone_Quendeluun] = UnitNames.Elite_Centurion_Earran,               -- Quendeluun (Auridon)
        [393] = UnitNames.Elite_Malangwe,                                             -- Saltspray Cave (Auridon)
        [390] = UnitNames.NPC_Heritance_Deadeye,                                      -- The Veiled Keep
        [Zonenames.Zone_Heritance_Proving_Ground] = UnitNames.NPC_Heritance_Deadeye,  -- Heritance Proving Ground (Auridon)

        -- Daggerfall Covenant
        [Zonenames.Zone_The_Grave] = UnitNames.NPC_Grave_Archer, -- Stros M'Kai

        --
        [435] = UnitNames.NPC_Sainted_Archer, -- Cathedral of the Golden Path

        -- Greymoor
        [1160] = UnitNames.NPC_Icereach_Thornslinger, -- Deepwood Vale (Greymoor)

        -- DUNGEONS
        [130] = UnitNames.NPC_Skeletal_Archer,                             -- Crypt of Hearts I
        [380] = UnitNames.NPC_Banished_Archer,                             -- Banished Cells I
        [935] = UnitNames.NPC_Banished_Archer,                             -- Banished Cells II
        [126] = UnitNames.NPC_Darkfern_Archer,                             -- Elden Hollow I
        [681] = UnitNames.NPC_Xivilai_Immolator,                           -- City of Ash II
        [131] = UnitNames.NPC_Sea_Viper_Deadeye,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Deadeye, -- Tempest Island
        [932] = UnitNames.NPC_Spiderkith_Wefter,                           -- Crypt of Hearts II
    },
    [28628] =
    {                                                                                 -- Volley (Archer)
        -- QUESTS
        [968] = UnitNames.NPC_Slaver_Archer,                                          -- Firemoth Island (Vvardenfell)
        [1013] = UnitNames.NPC_Dessicated_Archer,                                     -- Summerset (The Mind Trap)

        [Zonenames.Zone_Maormer_Invasion_Camp] = UnitNames.NPC_Sea_Viper_Deadeye,     -- Maormer Invasion Camp (Auridon)
        [Zonenames.Zone_South_Beacon] = UnitNames.NPC_Sea_Viper_Deadeye,              -- South Beacon (Auridon)
        [Zonenames.Zone_Mathiisen] = UnitNames.NPC_Heritance_Deadeye,                 -- Mathiisen (Auridon)
        [810] = UnitNames.NPC_Heritance_Deadeye,                                      -- Smuggler's Tunnel (Auridon)
        -- [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Skeletal_Archer, -- Castle Rilis (Auridon) -- Can't, elite here stops this from working
        [392] = UnitNames.NPC_Skeletal_Archer,                                        -- The Vault of Exile (Auridon)
        [Zonenames.Zone_Soulfire_Plateau] = UnitNames.NPC_Skeletal_Archer,            -- Soulfire Plateau (Auridon)
        [Zonenames.Zone_Hightide_Keep] = UnitNames.NPC_Skeletal_Archer,               -- Hightide Keep (Auridon)
        [Zonenames.Zone_Errinorne_Isle] = UnitNames.NPC_Heritance_Deadeye,            -- Errinorne Isle (Auridon)
        [Zonenames.Zone_Captain_Blanchetes_Ship] = UnitNames.NPC_Ghost_Viper_Deadeye, -- Captain Blanchete's Ship (Auridon)
        [Zonenames.Zone_Ezduiin] = UnitNames.NPC_Spirit_Deadeye,                      -- Ezduiin (Auridon)
        [Zonenames.Zone_Quendeluun] = UnitNames.Elite_Centurion_Earran,               -- Quendeluun (Auridon)
        [393] = UnitNames.Elite_Malangwe,                                             -- Saltspray Cave (Auridon)
        [390] = UnitNames.NPC_Heritance_Deadeye,                                      -- The Veiled Keep
        [Zonenames.Zone_Heritance_Proving_Ground] = UnitNames.NPC_Heritance_Deadeye,  -- Heritance Proving Ground (Auridon)

        -- Daggerfall Covenant
        [Zonenames.Zone_The_Grave] = UnitNames.NPC_Grave_Archer, -- Stros M'Kai

        --
        [435] = UnitNames.NPC_Sainted_Archer, -- Cathedral of the Golden Path

        -- Greymoor
        [1160] = UnitNames.NPC_Icereach_Thornslinger, -- Deepwood Vale (Greymoor)

        -- DUNGEONS
        [130] = UnitNames.NPC_Skeletal_Archer,                             -- Crypt of Hearts I
        [380] = UnitNames.NPC_Banished_Archer,                             -- Banished Cells I
        [935] = UnitNames.NPC_Banished_Archer,                             -- Banished Cells II
        [126] = UnitNames.NPC_Darkfern_Archer,                             -- Elden Hollow I
        [681] = UnitNames.NPC_Xivilai_Immolator,                           -- City of Ash II
        [131] = UnitNames.NPC_Sea_Viper_Deadeye,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Deadeye, -- Tempest Island
        [932] = UnitNames.NPC_Spiderkith_Wefter,                           -- Crypt of Hearts II
    },
    [12439] =
    {                                                                                 -- Burning Arrow (Synergy)
        -- QUESTS
        [968] = UnitNames.NPC_Slaver_Archer,                                          -- Firemoth Island (Vvardenfell)
        [1013] = UnitNames.NPC_Dessicated_Archer,                                     -- Summerset (The Mind Trap)

        [Zonenames.Zone_Maormer_Invasion_Camp] = UnitNames.NPC_Sea_Viper_Deadeye,     -- South Beacon (Auridon)
        [Zonenames.Zone_South_Beacon] = UnitNames.NPC_Sea_Viper_Deadeye,              -- South Beacon (Auridon)
        [Zonenames.Zone_Mathiisen] = UnitNames.NPC_Heritance_Deadeye,                 -- Mathiisen (Auridon)
        [810] = UnitNames.NPC_Heritance_Deadeye,                                      -- Smuggler's Tunnel (Auridon)
        -- [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Skeletal_Archer, -- Castle Rilis (Auridon) -- Can't, elite here stops this from working
        [392] = UnitNames.NPC_Skeletal_Archer,                                        -- The Vault of Exile (Auridon)
        [Zonenames.Zone_Soulfire_Plateau] = UnitNames.NPC_Skeletal_Archer,            -- Soulfire Plateau (Auridon)
        [Zonenames.Zone_Hightide_Keep] = UnitNames.NPC_Skeletal_Archer,               -- Hightide Keep (Auridon)
        [Zonenames.Zone_Errinorne_Isle] = UnitNames.NPC_Heritance_Deadeye,            -- Errinorne Isle (Auridon)
        [Zonenames.Zone_Captain_Blanchetes_Ship] = UnitNames.NPC_Ghost_Viper_Deadeye, -- Captain Blanchete's Ship (Auridon)
        [Zonenames.Zone_Ezduiin] = UnitNames.NPC_Spirit_Deadeye,                      -- Ezduiin (Auridon)
        [Zonenames.Zone_Quendeluun] = UnitNames.Elite_Centurion_Earran,               -- Quendeluun (Auridon)
        [393] = UnitNames.Elite_Malangwe,                                             -- Saltspray Cave (Auridon)
        [390] = UnitNames.NPC_Heritance_Deadeye,                                      -- The Veiled Keep
        [Zonenames.Zone_Heritance_Proving_Ground] = UnitNames.NPC_Heritance_Deadeye,  -- Heritance Proving Ground (Auridon)

        -- Daggerfall Covenant
        [534] = UnitNames.NPC_Grave_Archer, -- Stros M'Kai

        --
        [435] = UnitNames.NPC_Sainted_Archer, -- Cathedral of the Golden Path

        -- DUNGEONS
        [130] = UnitNames.NPC_Skeletal_Archer, -- Crypt of Hearts I
        [380] = UnitNames.NPC_Banished_Archer, -- Banished Cells I
        [935] = UnitNames.NPC_Banished_Archer, -- Banished Cells II
        [126] = UnitNames.NPC_Darkfern_Archer, -- Elden Hollow I
        [176] = UnitNames.NPC_Dagonite_Archer, -- City of Ash I
    },

    [26324] =
    { -- Lava Geyser (Flame Atronach)

        -- DUNGEONS
        [935] = UnitNames.NPC_Flame_Atronach, -- Banished Cells II
        [176] = UnitNames.NPC_Flame_Atronach, -- City of Ash I
        [681] = UnitNames.NPC_Flame_Atronach, -- City of Ash II
    },

    -- [88554] = { -- Summon the Dead (Necromancer)
    --
    -- },
    [88555] =
    {                                                                                 -- Summon the Dead (Necromancer)
        [Zonenames.Zone_Tower_of_the_Vale] = UnitNames.Elite_Sanessalmo,              -- Tower of the Vale (Auridon)
        [Zonenames.Zone_Quendeluun] = UnitNames.NPC_Pact_Necromancer,                 -- Quendeluun (Auridon)
        [Zonenames.Zone_Wansalen] = UnitNames.NPC_Pact_Necromancer,                   -- Quendeluun (Auridon) - For a little section with npcs outside of the delv near Quendeluun.
        [Zonenames.Zone_Torinaan] = UnitNames.Elite_Vregas,                           -- Torinaan (Auridon)

        [395] = UnitNames.NPC_Dremora_Narkynaz,                                       -- The Refuge of Dread
        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Necromancer,                -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Necromancer,         -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Necromancer,      -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Necromancer, -- Hectahame Ritual Chamber
    },
    -- [88556] = { -- Summon the Dead (Necromancer)
    --

    [13397] =
    {                                                -- Empower Undead (Necromancer)
        -- DUNGEONS
        [932] = UnitNames.NPC_Spiderkith_Broodnurse, -- Crypt of Hearts II
    },

    -- },
    [10805] =
    {                                                                          -- Ignite (Synergy)
        -- QUESTS
        [1013] = UnitNames.NPC_Dessicated_Fire_Mage,                           -- Summerset (The Mind Trap)
        -- Auridon
        [Zonenames.Zone_Silsailen] = UnitNames.NPC_Heritance_Incendiary,       -- Silsailen (Auridon)
        [Zonenames.Zone_Tower_of_the_Vale] = UnitNames.Elite_Minantilles_Rage, -- Tower of the Vale (Auridon)
        [Zonenames.Zone_Quendeluun] = UnitNames.NPC_Pact_Pyromancer,           -- Quendeluun (Auridon)
        [Zonenames.Zone_Wansalen] = UnitNames.NPC_Pact_Pyromancer,             -- Quendeluun (Auridon) - For a little section with npcs outside of the delv near Quendeluun.

        --
        [389] = UnitNames.NPC_Skeletal_Infernal,                                   -- Reliquary Ruins
        [548] = UnitNames.NPC_Bandit_Incendiary,                                   -- Silitar
        [555] = UnitNames.Boss_Vicereeve_Pelidil,                                  -- Abecean Sea
        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Infernal,                -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Infernal,         -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Infernal,      -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Infernal, -- Hectahame Ritual Chamber

        -- Daggerfall Covenant
        [534] = UnitNames.NPC_Dogeater_Witch, -- Stros M'Kai

        -- DUNGEONS
        -- [130] = UnitNames.NPC_Skeletal_Pyromancer, -- Crypt of Hearts I -- Can't use because The Mage Master's Slave(s) also use these spells
        [380] = UnitNames.NPC_Scamp,                     -- Banished Cells I
        [935] = UnitNames.NPC_Dremora_Kyngald,           -- Banished Cells II
        [126] = UnitNames.NPC_Darkfern_Flamerender,      -- Elden Hollow I
        [176] = UnitNames.NPC_Scamp,                     -- City of Ash I
        [22] = UnitNames.NPC_Treasure_Hunter_Incendiary, -- Volenfell
    },
    [15164] =
    { -- Heat Wave (Fire Mage)

        -- QUESTS
        [0] = UnitNames.NPC_Skeletal_Pyromancer,                               -- The Wailing Prison (Soul Shriven in Coldharbour)
        [1013] = UnitNames.NPC_Dessicated_Fire_Mage,                           -- Summerset (The Mind Trap)

        [Zonenames.Zone_Silsailen] = UnitNames.NPC_Heritance_Incendiary,       -- Silsailen (Auridon)
        [Zonenames.Zone_Tower_of_the_Vale] = UnitNames.Elite_Minantilles_Rage, -- Tower of the Vale (Auridon)
        [Zonenames.Zone_Quendeluun] = UnitNames.NPC_Pact_Pyromancer,           -- Quendeluun (Auridon)
        [Zonenames.Zone_Wansalen] = UnitNames.NPC_Pact_Pyromancer,             -- Quendeluun (Auridon) - For a little section with npcs outside of the delv near Quendeluun.

        --
        [389] = UnitNames.NPC_Skeletal_Infernal,                                   -- Reliquary Ruins
        [548] = UnitNames.NPC_Bandit_Incendiary,                                   -- Silitar
        [555] = UnitNames.Boss_Vicereeve_Pelidil,                                  -- Abecean Sea
        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Infernal,                -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Infernal,         -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Infernal,      -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Infernal, -- Hectahame Ritual Chamber

        -- Daggerfall Covenant
        [534] = UnitNames.NPC_Dogeater_Witch, -- Stros M'Kai

        -- DUNGEONS
        -- [130] = UnitNames.NPC_Skeletal_Pyromancer, -- Crypt of Hearts I -- Can't use because The Mage Master's Slave(s) also use these spells
        [380] = UnitNames.Boss_Angata_the_Clannfear_Handler, -- Banished Cells I
        [935] = UnitNames.NPC_Dremora_Kyngald,               -- Banished Cells II
        [126] = UnitNames.NPC_Darkfern_Flamerender,          -- Elden Hollow I
        [681] = UnitNames.NPC_Dremora_Kyngald,               -- City of Ash II
        [932] = UnitNames.NPC_Spiderkith_Cauterizer,         -- Crypt of Hearts II
        [22] = UnitNames.NPC_Treasure_Hunter_Incendiary,     -- Volenfell
    },
    [47095] =
    {                                                                          -- Fire Rune (Fire Mage)
        -- QUESTS
        [1013] = UnitNames.NPC_Dessicated_Fire_Mage,                           -- Summerset (The Mind Trap)
        -- Auridon
        [Zonenames.Zone_Silsailen] = UnitNames.NPC_Heritance_Incendiary,       -- Silsailen (Auridon)
        [Zonenames.Zone_Tower_of_the_Vale] = UnitNames.Elite_Minantilles_Rage, -- Tower of the Vale (Auridon)
        [Zonenames.Zone_Quendeluun] = UnitNames.NPC_Pact_Pyromancer,           -- Quendeluun (Auridon)
        [Zonenames.Zone_Wansalen] = UnitNames.NPC_Pact_Pyromancer,             -- Quendeluun (Auridon) - For a little section with npcs outside of the delv near Quendeluun.

        --
        [389] = UnitNames.NPC_Skeletal_Infernal,                                   -- Reliquary Ruins
        [548] = UnitNames.NPC_Bandit_Incendiary,                                   -- Silitar
        [555] = UnitNames.Boss_Vicereeve_Pelidil,                                  -- Abecean Sea
        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Infernal,                -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Infernal,         -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Infernal,      -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Infernal, -- Hectahame Ritual Chamber

        -- Daggerfall Covenant
        [534] = UnitNames.NPC_Dogeater_Witch, -- Stros M'Kai

        -- DUNGEONS
        -- [130] = UnitNames.NPC_Skeletal_Pyromancer, -- Crypt of Hearts I -- Can't use because The Mage Master's Slave(s) also use these spells
        [380] = UnitNames.Boss_Angata_the_Clannfear_Handler, -- Banished Cells I
        [935] = UnitNames.NPC_Dremora_Kyngald,               -- Banished Cells II
        [126] = UnitNames.NPC_Darkfern_Flamerender,          -- Elden Hollow I
        [681] = UnitNames.NPC_Dremora_Kyngald,               -- City of Ash II
        [932] = UnitNames.NPC_Spiderkith_Cauterizer,         -- Crypt of Hearts II
        [22] = UnitNames.NPC_Treasure_Hunter_Incendiary,     -- Volenfell
    },

    [8779] =
    {                                          -- Lightning Onslaught (Spider Daedra)
        [395] = UnitNames.Elite_Mezelukhebruz, -- The Refuge of Dread

        -- DUNGEONS
        [935] = UnitNames.NPC_Spider_Daedra, -- Banished Cells II (Summon Only)
    },
    [8782] =
    {                                          -- Lightning Storm (Spider Daedra)
        [395] = UnitNames.Elite_Mezelukhebruz, -- The Refuge of Dread

        -- DUNGEONS
        [935] = UnitNames.NPC_Spider_Daedra, -- Banished Cells II (Summon Only)
    },
    [8773] =
    {                                          -- Summon Spiderling (Spider Daedra)
        [395] = UnitNames.Elite_Mezelukhebruz, -- The Refuge of Dread
    },
    [4799] =
    {                                                        -- Tail Spike (Clannfear)
        [395] = UnitNames.Elite_Marrow,                      -- The Refuge of Dread
        [Zonenames.Zone_Torinaan] = UnitNames.NPC_Clannfear, -- Torinaan (Auridon)

        -- QUESTS
        [0] = UnitNames.NPC_Clannfear, -- The Wailing Prison (Soul Shriven in Coldharbour)

        -- DUNGEONS
        [380] = UnitNames.NPC_Clannfear, -- Banished Cells I
        [935] = UnitNames.NPC_Clannfear, -- Banished Cells II
        [681] = UnitNames.NPC_Clannfear, -- City of Ash II
    },
    [93745] =
    {                                                        -- Rending Leap (Clannfear)
        [395] = UnitNames.Elite_Marrow,                      -- The Refuge of Dread
        [Zonenames.Zone_Torinaan] = UnitNames.NPC_Clannfear, -- Torinaan (Auridon)

        -- DUNGEONS
        [380] = UnitNames.NPC_Clannfear, -- Banished Cells I
        [935] = UnitNames.NPC_Clannfear, -- Banished Cells II
        [681] = UnitNames.NPC_Clannfear, -- City of Ash II
    },

    [4653] =
    {                                  -- Shockwave (Watcher)
        [389] = UnitNames.NPC_Watcher, -- Reliquary Ruins
    },
    [9219] =
    {                                  -- Doom-Truth's Gaze (Watcher)
        [389] = UnitNames.NPC_Watcher, -- Reliquary Ruins
    },
    [14425] =
    {                                  -- Doom-Truth's Gaze (Watcher)
        [389] = UnitNames.NPC_Watcher, -- Reliquary Ruins
    },

    [4771] =
    {                                      -- Fiery Breath (Daedroth)
        [435] = UnitNames.Elite_Free_Will, -- Cathedral of the Golden Path
        [935] = UnitNames.NPC_Daedroth,    -- Banished Cells II
    },
    [91946] =
    {                                      -- Ground Tremor (Daedroth)
        [435] = UnitNames.Elite_Free_Will, -- Cathedral of the Golden Path
        [935] = UnitNames.NPC_Daedroth,    -- Banished Cells II
    },

    [50182] =
    {                                   -- Consuming Energy (Spellfiend)
        [932] = UnitNames.NPC_Skeleton, -- Crypt of Hearts II
    },

    [10270] =
    {                                   -- Quake (Gargoyle)
        [383] = UnitNames.NPC_Gargoyle, -- Grahtwood (for Nairume's Prison)
    },
    [13701] =
    {                                        -- Focused Charge (Brute)
        [548] = UnitNames.NPC_Bandit_Savage, -- Silatar

        -- DUNGEONS
        [131] = UnitNames.NPC_Sea_Viper_Strongarm,                           -- Tempest Island
        [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Strongarm, -- Tempest Island
    },

    [37087] =
    {                                  -- Lightning Onslaught (Battlemage)
        [548] = UnitNames.Elite_Baham, -- Silatar

        -- DUNGEONS
        [935] = UnitNames.NPC_Dremora_Clasher, -- Banished Cells II
    },
    [37129] =
    {                                  -- Ice Cage (Battlemage)
        [548] = UnitNames.Elite_Baham, -- Silatar

        -- DUNGEONS
        [130] = UnitNames.Boss_The_Mage_Master, -- Crypt of Hearts I
        [935] = UnitNames.NPC_Dremora_Clasher,  -- Banished Cells II
        [932] = UnitNames.Boss_Ibelgast,        -- Crypt of Hearts II
    },
    [44216] =
    {                                  -- Negate Magic (Battlemage - Elite)
        [548] = UnitNames.Elite_Baham, -- Silatar

        -- DUNGEONS
        [130] = UnitNames.Boss_The_Mage_Master, -- Crypt of Hearts I
        [932] = UnitNames.Boss_Ibelgast,        -- Crypt of Hearts II
    },

    [3767] =
    {                                                                              -- Choking Pollen (Lurcher)
        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Corrupt_Lurcher,                -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Corrupt_Lurcher,         -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Corrupt_Lurcher,      -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Corrupt_Lurcher, -- Hectahame Ritual Chamber
        [559] = UnitNames.NPC_Corrupt_Lurcher,                                     -- Valenheart

        -- DUNGEONS
        [931] = UnitNames.NPC_Daedric_Lurcher, -- Elden Hollow II
    },
    [21582] =
    {                                                                              -- Nature's Swarm (Spriggan)
        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Corrupt_Spriggan,               -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Corrupt_Spriggan,        -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Corrupt_Spriggan,     -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Corrupt_Lurcher, -- Hectahame Ritual Chamber
    },
    [13477] =
    {                                                                              -- Control Beast (Spriggan)
        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Corrupt_Spriggan,               -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Corrupt_Spriggan,        -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Corrupt_Spriggan,     -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Corrupt_Lurcher, -- Hectahame Ritual Chamber
    },
    [89102] =
    {                                                                              -- Summon Beast (Spriggan)
        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Corrupt_Spriggan,               -- Hectaham
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Corrupt_Spriggan,        -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Corrupt_Spriggan,     -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Corrupt_Lurcher, -- Hectahame Ritual Chamber
    },

    [35387] =
    {                                                                              -- Defiled Grave (Bonelord)
        [399] = UnitNames.Elite_Nolonir,                                           -- Wansalen (Auridon - Delve)

        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Bonelord,                -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Bonelord,         -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Bonelord,      -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Bonelord, -- Hectahame Ritual Chamber

        -- DUNGEONS
        [935] = UnitNames.NPC_Dremora_Hauzkyn, -- Banished Cells II
    },
    [88507] =
    {                                                                              -- Summon Abomination (Bonelord)
        [399] = UnitNames.Elite_Nolonir,                                           -- Wansalen (Auridon - Delve)

        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Bonelord,                -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Bonelord,         -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Bonelord,      -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Bonelord, -- Hectahame Ritual Chamber

        -- DUNGEONS
        [935] = UnitNames.NPC_Dremora_Hauzkyn, -- Banished Cells II
    },
    [5050] =
    {                                                                            -- Bone Saw (Bone Colossus)
        [Zonenames.Zone_Hightide_Keep] = UnitNames.Elite_Garggeel,               -- Hightide Keep (Auridon)
        [399] = UnitNames.NPC_Bone_Colossus,                                     -- Wansalen (Auridon - Delve)

        [Zonenames.Zone_Hectahame] = UnitNames.NPC_Bone_Colossus,                -- Hectahame
        [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Bone_Colossus,         -- Hectahame Armory
        [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Bone_Colossus,      -- Hectahame Arboretum
        [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Bone_Colossus, -- Hectahame Ritual Chamber

        -- DUNGEONS
        [130] = UnitNames.NPC_Bone_Colossus,       -- Crypt of Hearts I
        [380] = UnitNames.Boss_Skeletal_Destroyer, -- Banished Cells I
        [935] = UnitNames.NPC_Bone_Colossus,       -- Banished Cells II (Summon Only)
        [681] = UnitNames.NPC_Flame_Colossus,      -- City of Ash II
    },
    [5030] =
    {                                                              -- Voice to Wake the Dead (Bone Colossus)
        [Zonenames.Zone_Hightide_Keep] = UnitNames.Elite_Garggeel, -- Hightide Keep (Auridon)
        [399] = UnitNames.NPC_Bone_Colossus,                       -- Wansalen (Auridon - Delve) -- TODO: Is this needed?

        -- DUNGEONS
        [130] = UnitNames.NPC_Bone_Colossus,       -- Crypt of Hearts I
        [380] = UnitNames.Boss_Skeletal_Destroyer, -- Banished Cells I
    },

    [22521] =
    {                                           -- Defiled Ground (Lich)
        [559] = UnitNames.Boss_Shade_of_Naemon, -- Valenheart

        -- DUNGEONS
        [130] = UnitNames.Boss_Uulkar_Bonehand, -- Crypt of Hearts I
    },
    [19137] =
    { -- Haunting Spectre (Ghost)

        -- DUNGEONS
        [935] = UnitNames.NPC_Ghost, -- Banished Cells II (Summon Only)
        [130] = UnitNames.NPC_Ghost, -- Crypt of Hearts I
    },
    [73925] =
    {                                           -- Soul Cage (Lich)
        [559] = UnitNames.Boss_Shade_of_Naemon, -- Valenheart

        -- DUNGEONS
        [130] = UnitNames.Boss_Uulkar_Bonehand, -- Crypt of Hearts I
    },

    [44736] =
    {                                                             -- Swinging Cleave (Troll)
        [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Troll,      -- Castle Rilis (Auridon) -- TODO: Probably can do all of Auridon
        [Zonenames.Zone_Nine_Prow_Landing] = UnitNames.NPC_Troll, -- Nine-Prow Landing (Auridon) -- TODO: Probably can do all of Auridon
    },
    [9009] =
    {                                                             -- Tremor (Troll)
        [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Troll,      -- Castle Rilis (Auridon) -- TODO: Probably can do all of Auridon
        [Zonenames.Zone_Nine_Prow_Landing] = UnitNames.NPC_Troll, -- Nine-Prow Landing (Auridon) -- TODO: Probably can do all of Auridon
    },
    [3415] =
    {                                     -- Flurry (Werewolf)
        [392] = UnitNames.Elite_Sorondil, -- The Vault of Exile (Auridon)
    },

    [4415] =
    {                               -- Crushing Swipe (Bear)
        [381] = UnitNames.NPC_Bear, -- Auridon
    },

    [5789] =
    {                                            -- Fire Runes (Giant Spider)
        -- QUESTS
        [393] = UnitNames.NPC_Spider,            -- Saltspray Cave (Auridon)
        [1160] = UnitNames.NPC_Frostbite_Spider, -- Deepwood Vale (Greymoor)

        -- DUNGEONS
        [932] = UnitNames.NPC_Spider, -- Crypt of Hearts II
    },
    [8087] =
    {                                 -- Poison Spray (Giant Spider)
        -- QUESTS
        [393] = UnitNames.NPC_Spider, -- Saltspray Cave (Auridon)
    },
    [4737] =
    {                                 -- Encase (Giant Spider)
        -- QUESTS
        [393] = UnitNames.NPC_Spider, -- Saltspray Cave (Auridon)
    },
    [13382] =
    {                                 -- Devour (Giant Spider)
        -- QUESTS
        [393] = UnitNames.NPC_Spider, -- Saltspray Cave (Auridon)

        -- DUNGEONS
        [932] = UnitNames.NPC_Spider, -- Crypt of Hearts II
    },

    [6166] =
    {                                -- Heat Wave (Scamp)
        [381] = UnitNames.NPC_Scamp, -- Auridon

        -- DUNGEONS
        [380] = UnitNames.NPC_Scamp, -- Banished Cells I
        [935] = UnitNames.NPC_Scamp, -- Banished Cells II (Summon Only)
        [931] = UnitNames.NPC_Scamp, -- Elden Hollow II
        [176] = UnitNames.NPC_Scamp, -- City of Ash I
        [681] = UnitNames.NPC_Scamp, -- City of Ash II
    },
    [6160] =
    {                                -- Rain of Fire (Scamp)
        [381] = UnitNames.NPC_Scamp, -- Auridon

        -- DUNGEONS
        [380] = UnitNames.NPC_Scamp, -- Banished Cells I
        [935] = UnitNames.NPC_Scamp, -- Banished Cells II (Summon Only)
        [931] = UnitNames.NPC_Scamp, -- Elden Hollow II
        [176] = UnitNames.NPC_Scamp, -- City of Ash I
        [681] = UnitNames.NPC_Scamp, -- City of Ash II
    },

    [88947] =
    { -- Lightning Grasp (Xivilai)

        -- DUNGEONS
        [935] = UnitNames.NPC_Xivilai, -- Banished Cells I
    },
    [7100] =
    { -- Hand of Flame (Xivilai)

        -- DUNGEONS
        [935] = UnitNames.NPC_Xivilai, -- Banished Cells I
    },
    [25726] =
    { -- Summon Daedra (Xivilai)

        -- DUNGEONS
        [935] = UnitNames.NPC_Xivilai, -- Banished Cells I
    },
    [4829] =
    { -- Fire Brand (Flesh Atronach)

        -- DUNGEONS
        [935] = UnitNames.NPC_Flesh_Atronach, -- Banished Cells I (Summon Only)
        [932] = UnitNames.NPC_Flesh_Atronach, -- Crypt of Hearts II
    },
    [6412] =
    { -- Dusk's Howl (Winged Twilight)

        -- DUNGEONS
        [935] = UnitNames.NPC_Winged_Twilight,       -- Banished Cells I
        [931] = UnitNames.Boss_Azara_the_Frightener, -- Elden Hollow II
    },

    [24690] =
    { -- Focused Charge (Ogrim)

        -- DUNGEONS
        [935] = UnitNames.NPC_Flame_Ogrim, -- Banished Cells II (Summon Only)
        [932] = UnitNames.NPC_Ogrim,       -- Crypt of Hearts II
    },
    [91848] =
    { -- Stomp (Ogrim)

        -- DUNGEONS
        [935] = UnitNames.NPC_Flame_Ogrim, -- Banished Cells II (Summon Only)
        [932] = UnitNames.NPC_Ogrim,       -- Crypt of Hearts II
    },
    [91855] =
    { -- Boulder Toss (Ogrim)

        -- DUNGEONS
        [935] = UnitNames.NPC_Flame_Ogrim, -- Banished Cells II (Summon Only)
        [932] = UnitNames.NPC_Ogrim,       -- Crypt of Hearts II
    },

    [28939] =
    { -- Heat Wave (Sees-All-Colors)

        -- DUNGEONS
        [935] = UnitNames.Boss_Keeper_Areldur, -- Banished Cells II
    },

    [5452] =
    {                               -- Lacerate (Alit)
        -- QUESTS
        [968] = UnitNames.NPC_Alit, -- Firemoth Island (Vvardenfell)

        -- DUNGEONS
        -- [126] = UnitNames.NPC_Alit, -- Elden Hollow I (Can't use because Alit's are right next to Leafseether and can easily also be casting this)
    },

    [5441] =
    {                               -- Dive (Guar)
        -- QUESTS
        [968] = UnitNames.NPC_Guar, -- Firemoth Island (Vvardenfell)
    },

    [85395] =
    {                                        -- Dive (Cliff Strider)
        -- QUESTS
        [968] = UnitNames.NPC_Cliff_Strider, -- Firemoth Island (Vvardenfell)
    },
    [85399] =
    {                                        -- Retch (Cliff Strider)
        -- QUESTS
        [968] = UnitNames.NPC_Cliff_Strider, -- Firemoth Island (Vvardenfell)
    },

    [26412] =
    {                                          -- Thunderstrikes (Thunderbug)
        [126] = UnitNames.NPC_Thunderbug_Lord, -- Elden Hollow I
    },
    [9322] =
    {                                    -- Poisoned Ground (Strangler)
        [126] = UnitNames.NPC_Strangler, -- Elden Hollow I
        [681] = UnitNames.NPC_Strangler, -- City of Ash II
    },
    [14272] =
    {                               -- Call of the Pack (Wolf)
        [534] = UnitNames.NPC_Wolf, -- Stros M'Kai
    },

    [16031] =
    {                                            -- Steam Wall (Dwemer Sphere)
        -- QUESTS
        [534] = UnitNames.Elite_Tempered_Sphere, -- Stros M'Kai

        -- DUNGEONS
        [22] = UnitNames.NPC_Dwarven_Sphere, -- Volenfell
    },
    [7544] =
    {                                            -- Quake (Dwemer Sphere)
        -- QUESTS
        [534] = UnitNames.Elite_Tempered_Sphere, -- Stros M'Kai

        -- DUNGEONS
        [22] = UnitNames.NPC_Dwarven_Sphere, -- Volenfell
    },

    [11247] =
    {                                           -- Sweeping Spin (Dwemer Centurion)
        -- DUNGEONS
        [22] = UnitNames.NPC_Dwarven_Centurion, -- Volenfell
    },
    [11246] =
    {                                           -- Steam Breath (Dwemer Centurion)
        -- DUNGEONS
        [22] = UnitNames.NPC_Dwarven_Centurion, -- Volenfell
    },

    [135612] =
    {                                           -- Frost Wave (Matron Urgala)
        -- QUESTS
        [1160] = UnitNames.Elite_Matron_Urgala, -- Deepwood Vale (Greymoor Tutorial)
    },

    [70366] =
    {                                                                  -- Slam (Great Bear)
        -- QUESTS
        [Zonenames.Zone_Deepwood_Vale] = UnitNames.NPC_Feral_Guardian, -- Deepwood Vale (Greymoor Tutorial)
    },

    [88371] =
    {                                                -- Dive (Beastcaller) (Morrowind)
        [1160] = UnitNames.NPC_Icereach_Beastcaller, -- Deepwood Vale (Greymoor)
    },
    [88394] =
    {                                                -- Gore (Beastcaller) (Morrowind)
        [1160] = UnitNames.NPC_Icereach_Beastcaller, -- Deepwood Vale (Greymoor)
    },
    [88409] =
    {                                                -- Raise the Earth (Beastcaller)
        [1160] = UnitNames.NPC_Icereach_Beastcaller, -- Deepwood Vale (Greymoor)
    },
    [8977] =
    {                                    -- Sweep (Duneripper)
        -- DUNGEONS
        [22] = UnitNames.NPC_Duneripper, -- Volenfell
    },

    [25211] =
    {                                                 -- Whirlwind Function (The Guardian's Strength)
        -- DUNGEONS
        [22] = UnitNames.Boss_The_Guardians_Strength, -- Volenfell
    },
    [25262] =
    {                                                 -- Hammer Strike (The Guardian's Soul)
        -- DUNGEONS
        [22] = UnitNames.Boss_The_Guardians_Strength, -- Volenfell
    },

    [63752] =
    {                                           -- Vomit (Tutorial)
        [0] = UnitNames.NPC_Feral_Soul_Shriven, -- The Wailing Prison (Soul Shriven in Coldharbour)
    },
    [63521] =
    {                                         -- Bone Crush (Tutorial)
        [0] = UnitNames.Elite_Child_of_Bones, -- The Wailing Prison (Soul Shriven in Coldharbour)
    },
    [107282] =
    {                                              -- Impale (Yaghra Nightmare)
        [1013] = UnitNames.Elite_Yaghra_Nightmare, -- Summerset (The Mind Trap)
    },
    [105867] =
    {                                              -- Pustulant Explosion (Yaghra Nightmare)
        [1013] = UnitNames.Elite_Yaghra_Nightmare, -- Summerset (The Mind Trap)
    },

    [121643] =
    {                                                -- Defiled Ground (Euraxian Necromancer)
        [1106] = UnitNames.NPC_Euraxian_Necromancer, -- Elsweyr (Bright Moons, Warm Sands)
    },

    [5240] =
    {                                      -- Lash (Giant Snake)
        [534] = UnitNames.Elite_Deathfang, -- Deathfang (Stros M'Kai)
    },
}

--- @class (partial) AlertZoneOverride
Data.AlertZoneOverride = alertZoneOverride
