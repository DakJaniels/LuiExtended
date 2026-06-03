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

    [7835] = { [131] = UnitNames.NPC_Lamia_Curare, [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Lamia_Curare }, -- Convalescence (Lamia)
    [9680] = { [131] = UnitNames.NPC_Lamia_Curare, [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Lamia_Curare }, -- Summon Spectral Lamia

    [35220] = { [681] = UnitNames.NPC_Storm_Atronach, [131] = UnitNames.NPC_Storm_Atronach, [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Storm_Atronach }, -- Impending Storm (Storm Atronach)

    [54021] = { [681] = UnitNames.NPC_Xivilai_Immolator }, -- Release Flame (Marruz)

    [4591] = { [681] = UnitNames.NPC_Crocodile }, -- Sweep (Crocodile)

    [34742] = { [176] = UnitNames.NPC_Dremora_Kynval, [681] = UnitNames.NPC_Dremora_Kynval, [22] = UnitNames.NPC_Imperial_Overseer }, -- Fiery Breath (Dragonknight)

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

    [35151] = { [931] = UnitNames.NPC_Dremora_Invoker }, -- Spell Absorption (Spirit Mage)
    [14472] = { [931] = UnitNames.NPC_Dremora_Invoker }, -- Burdening Eye (Spirit Mage)

    [12459] = { [1160] = UnitNames.NPC_Icereach_Chillrender, [380] = UnitNames.NPC_Banished_Mage }, -- Winter's Reach (Frost Mage)
    [14194] = { [1160] = UnitNames.NPC_Icereach_Chillrender, [380] = UnitNames.NPC_Banished_Mage }, -- Ice Barrier (Frost Mage)

    [4337] = { [380] = UnitNames.Boss_Cell_Haunter, [935] = UnitNames.NPC_Wraith, [130] = UnitNames.NPC_Wraith }, -- Winter's Reach (Wraith)

    [36985] = { [555] = UnitNames.Boss_Vicereeve_Pelidil, [130] = UnitNames.NPC_Skeletal_Runecaster, [932] = UnitNames.Boss_Mezeluth }, -- Void (Time Bomb Mage)

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
    [29510] = { [Zonenames.Zone_Maormer_Invasion_Camp] = UnitNames.Elite_Arstul, [394] = UnitNames.NPC_Thundermaul, [399] = UnitNames.NPC_Skeletal_Thundermaul, [435] = UnitNames.NPC_Sainted_Charger, [555] = UnitNames.NPC_Sea_Viper_Charger, [1160] = UnitNames.NPC_Icereach_Charger, [131] = UnitNames.NPC_Sea_Viper_Charger, [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Charger }, -- Thunder Hammer (Thundermaul)
    [17867] = { [Zonenames.Zone_Maormer_Invasion_Camp] = UnitNames.Elite_Arstul, [394] = UnitNames.NPC_Thundermaul, [399] = UnitNames.NPC_Skeletal_Thundermaul, [435] = UnitNames.NPC_Sainted_Charger, [555] = UnitNames.NPC_Sea_Viper_Charger, [1160] = UnitNames.NPC_Icereach_Charger, [126] = UnitNames.Boss_Nenesh_gro_Mal, [131] = UnitNames.NPC_Sea_Viper_Charger, [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Charger }, -- Shock Aura (Thundermaul)
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

    [26324] = { [935] = UnitNames.NPC_Flame_Atronach, [176] = UnitNames.NPC_Flame_Atronach, [681] = UnitNames.NPC_Flame_Atronach }, -- Lava Geyser (Flame Atronach)

    -- [88554] = { -- Summon the Dead (Necromancer)
    --
    -- },
    [88555] = { [Zonenames.Zone_Tower_of_the_Vale] = UnitNames.Elite_Sanessalmo, [Zonenames.Zone_Quendeluun] = UnitNames.NPC_Pact_Necromancer, [Zonenames.Zone_Wansalen] = UnitNames.NPC_Pact_Necromancer, [Zonenames.Zone_Torinaan] = UnitNames.Elite_Vregas, [395] = UnitNames.NPC_Dremora_Narkynaz, [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Necromancer, [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Necromancer, [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Necromancer, [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Necromancer }, -- Summon the Dead (Necromancer)
    -- [88556] = { -- Summon the Dead (Necromancer)
    --

    [13397] = { [932] = UnitNames.NPC_Spiderkith_Broodnurse }, -- Empower Undead (Necromancer)

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

    [8779] = { [395] = UnitNames.Elite_Mezelukhebruz, [935] = UnitNames.NPC_Spider_Daedra }, -- Lightning Onslaught (Spider Daedra)
    [8782] = { [395] = UnitNames.Elite_Mezelukhebruz, [935] = UnitNames.NPC_Spider_Daedra }, -- Lightning Storm (Spider Daedra)
    [8773] = { [395] = UnitNames.Elite_Mezelukhebruz }, -- Summon Spiderling (Spider Daedra)
    [4799] = { [395] = UnitNames.Elite_Marrow, [Zonenames.Zone_Torinaan] = UnitNames.NPC_Clannfear, [0] = UnitNames.NPC_Clannfear, [380] = UnitNames.NPC_Clannfear, [935] = UnitNames.NPC_Clannfear, [681] = UnitNames.NPC_Clannfear }, -- Tail Spike (Clannfear)
    [93745] = { [395] = UnitNames.Elite_Marrow, [Zonenames.Zone_Torinaan] = UnitNames.NPC_Clannfear, [380] = UnitNames.NPC_Clannfear, [935] = UnitNames.NPC_Clannfear, [681] = UnitNames.NPC_Clannfear }, -- Rending Leap (Clannfear)

    [4653] = { [389] = UnitNames.NPC_Watcher }, -- Shockwave (Watcher)
    [9219] = { [389] = UnitNames.NPC_Watcher }, -- Doom-Truth's Gaze (Watcher)
    [14425] = { [389] = UnitNames.NPC_Watcher }, -- Doom-Truth's Gaze (Watcher)

    [4771] = { [435] = UnitNames.Elite_Free_Will, [935] = UnitNames.NPC_Daedroth }, -- Fiery Breath (Daedroth)
    [91946] = { [435] = UnitNames.Elite_Free_Will, [935] = UnitNames.NPC_Daedroth }, -- Ground Tremor (Daedroth)

    [50182] = { [932] = UnitNames.NPC_Skeleton }, -- Consuming Energy (Spellfiend)

    [10270] = { [383] = UnitNames.NPC_Gargoyle }, -- Quake (Gargoyle)
    [13701] = { [548] = UnitNames.NPC_Bandit_Savage, [131] = UnitNames.NPC_Sea_Viper_Strongarm, [Zonenames.Zone_Tempest_Island] = UnitNames.NPC_Sea_Viper_Strongarm }, -- Focused Charge (Brute)

    [37087] = { [548] = UnitNames.Elite_Baham, [935] = UnitNames.NPC_Dremora_Clasher }, -- Lightning Onslaught (Battlemage)
    [37129] = { [548] = UnitNames.Elite_Baham, [130] = UnitNames.Boss_The_Mage_Master, [935] = UnitNames.NPC_Dremora_Clasher, [932] = UnitNames.Boss_Ibelgast }, -- Ice Cage (Battlemage)
    [44216] = { [548] = UnitNames.Elite_Baham, [130] = UnitNames.Boss_The_Mage_Master, [932] = UnitNames.Boss_Ibelgast }, -- Negate Magic (Battlemage - Elite)

    [3767] = { [Zonenames.Zone_Hectahame] = UnitNames.NPC_Corrupt_Lurcher, [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Corrupt_Lurcher, [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Corrupt_Lurcher, [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Corrupt_Lurcher, [559] = UnitNames.NPC_Corrupt_Lurcher, [931] = UnitNames.NPC_Daedric_Lurcher }, -- Choking Pollen (Lurcher)
    [21582] = { [Zonenames.Zone_Hectahame] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Corrupt_Lurcher }, -- Nature's Swarm (Spriggan)
    [13477] = { [Zonenames.Zone_Hectahame] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Corrupt_Lurcher }, -- Control Beast (Spriggan)
    [89102] = { [Zonenames.Zone_Hectahame] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Corrupt_Spriggan, [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Corrupt_Lurcher }, -- Summon Beast (Spriggan)

    [35387] = { [399] = UnitNames.Elite_Nolonir, [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Bonelord, [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Bonelord, [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Bonelord, [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Bonelord, [935] = UnitNames.NPC_Dremora_Hauzkyn }, -- Defiled Grave (Bonelord)
    [88507] = { [399] = UnitNames.Elite_Nolonir, [Zonenames.Zone_Hectahame] = UnitNames.NPC_Veiled_Bonelord, [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Veiled_Bonelord, [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Veiled_Bonelord, [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Veiled_Bonelord, [935] = UnitNames.NPC_Dremora_Hauzkyn }, -- Summon Abomination (Bonelord)
    [5050] = { [Zonenames.Zone_Hightide_Keep] = UnitNames.Elite_Garggeel, [399] = UnitNames.NPC_Bone_Colossus, [Zonenames.Zone_Hectahame] = UnitNames.NPC_Bone_Colossus, [Zonenames.Zone_Hectahame_Armory] = UnitNames.NPC_Bone_Colossus, [Zonenames.Zone_Hectahame_Arboretum] = UnitNames.NPC_Bone_Colossus, [Zonenames.Zone_Hectahame_Ritual_Chamber] = UnitNames.NPC_Bone_Colossus, [130] = UnitNames.NPC_Bone_Colossus, [380] = UnitNames.Boss_Skeletal_Destroyer, [935] = UnitNames.NPC_Bone_Colossus, [681] = UnitNames.NPC_Flame_Colossus }, -- Bone Saw (Bone Colossus)
    [5030] = { [Zonenames.Zone_Hightide_Keep] = UnitNames.Elite_Garggeel, [399] = UnitNames.NPC_Bone_Colossus, [130] = UnitNames.NPC_Bone_Colossus, [380] = UnitNames.Boss_Skeletal_Destroyer }, -- Voice to Wake the Dead (Bone Colossus)

    [22521] = { [559] = UnitNames.Boss_Shade_of_Naemon, [130] = UnitNames.Boss_Uulkar_Bonehand }, -- Defiled Ground (Lich)
    [19137] = { [935] = UnitNames.NPC_Ghost, [130] = UnitNames.NPC_Ghost }, -- Haunting Spectre (Ghost)
    [73925] = { [559] = UnitNames.Boss_Shade_of_Naemon, [130] = UnitNames.Boss_Uulkar_Bonehand }, -- Soul Cage (Lich)

    [44736] = { [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Troll, [Zonenames.Zone_Nine_Prow_Landing] = UnitNames.NPC_Troll }, -- Swinging Cleave (Troll)
    [9009] = { [Zonenames.Zone_Castle_Rilis] = UnitNames.NPC_Troll, [Zonenames.Zone_Nine_Prow_Landing] = UnitNames.NPC_Troll }, -- Tremor (Troll)
    [3415] = { [392] = UnitNames.Elite_Sorondil }, -- Flurry (Werewolf)

    [4415] = { [381] = UnitNames.NPC_Bear }, -- Crushing Swipe (Bear)

    [5789] = { [393] = UnitNames.NPC_Spider, [1160] = UnitNames.NPC_Frostbite_Spider, [932] = UnitNames.NPC_Spider }, -- Fire Runes (Giant Spider)
    [8087] = { [393] = UnitNames.NPC_Spider }, -- Poison Spray (Giant Spider)
    [4737] = { [393] = UnitNames.NPC_Spider }, -- Encase (Giant Spider)
    [13382] = { [393] = UnitNames.NPC_Spider, [932] = UnitNames.NPC_Spider }, -- Devour (Giant Spider)

    [6166] = { [381] = UnitNames.NPC_Scamp, [380] = UnitNames.NPC_Scamp, [935] = UnitNames.NPC_Scamp, [931] = UnitNames.NPC_Scamp, [176] = UnitNames.NPC_Scamp, [681] = UnitNames.NPC_Scamp }, -- Heat Wave (Scamp)
    [6160] = { [381] = UnitNames.NPC_Scamp, [380] = UnitNames.NPC_Scamp, [935] = UnitNames.NPC_Scamp, [931] = UnitNames.NPC_Scamp, [176] = UnitNames.NPC_Scamp, [681] = UnitNames.NPC_Scamp }, -- Rain of Fire (Scamp)

    [88947] = { [935] = UnitNames.NPC_Xivilai }, -- Lightning Grasp (Xivilai)
    [7100] = { [935] = UnitNames.NPC_Xivilai }, -- Hand of Flame (Xivilai)
    [25726] = { [935] = UnitNames.NPC_Xivilai }, -- Summon Daedra (Xivilai)
    [4829] = { [935] = UnitNames.NPC_Flesh_Atronach, [932] = UnitNames.NPC_Flesh_Atronach }, -- Fire Brand (Flesh Atronach)
    [6412] = { [935] = UnitNames.NPC_Winged_Twilight, [931] = UnitNames.Boss_Azara_the_Frightener }, -- Dusk's Howl (Winged Twilight)

    [24690] = { [935] = UnitNames.NPC_Flame_Ogrim, [932] = UnitNames.NPC_Ogrim }, -- Focused Charge (Ogrim)
    [91848] = { [935] = UnitNames.NPC_Flame_Ogrim, [932] = UnitNames.NPC_Ogrim }, -- Stomp (Ogrim)
    [91855] = { [935] = UnitNames.NPC_Flame_Ogrim, [932] = UnitNames.NPC_Ogrim }, -- Boulder Toss (Ogrim)

    [28939] = { [935] = UnitNames.Boss_Keeper_Areldur }, -- Heat Wave (Sees-All-Colors)

    [5452] =
    {                               -- Lacerate (Alit)
        -- QUESTS
        [968] = UnitNames.NPC_Alit, -- Firemoth Island (Vvardenfell)

        -- DUNGEONS
        -- [126] = UnitNames.NPC_Alit, -- Elden Hollow I (Can't use because Alit's are right next to Leafseether and can easily also be casting this)
    },

    [5441] = { [968] = UnitNames.NPC_Guar }, -- Dive (Guar)

    [85395] = { [968] = UnitNames.NPC_Cliff_Strider }, -- Dive (Cliff Strider)
    [85399] = { [968] = UnitNames.NPC_Cliff_Strider }, -- Retch (Cliff Strider)

    [26412] = { [126] = UnitNames.NPC_Thunderbug_Lord }, -- Thunderstrikes (Thunderbug)
    [9322] = { [126] = UnitNames.NPC_Strangler, [681] = UnitNames.NPC_Strangler }, -- Poisoned Ground (Strangler)
    [14272] = { [534] = UnitNames.NPC_Wolf }, -- Call of the Pack (Wolf)

    [16031] = { [534] = UnitNames.Elite_Tempered_Sphere, [22] = UnitNames.NPC_Dwarven_Sphere }, -- Steam Wall (Dwemer Sphere)
    [7544] = { [534] = UnitNames.Elite_Tempered_Sphere, [22] = UnitNames.NPC_Dwarven_Sphere }, -- Quake (Dwemer Sphere)

    [11247] = { [22] = UnitNames.NPC_Dwarven_Centurion }, -- Sweeping Spin (Dwemer Centurion)
    [11246] = { [22] = UnitNames.NPC_Dwarven_Centurion }, -- Steam Breath (Dwemer Centurion)

    [135612] = { [1160] = UnitNames.Elite_Matron_Urgala }, -- Frost Wave (Matron Urgala)

    [70366] = { [Zonenames.Zone_Deepwood_Vale] = UnitNames.NPC_Feral_Guardian }, -- Slam (Great Bear)

    [88371] = { [1160] = UnitNames.NPC_Icereach_Beastcaller }, -- Dive (Beastcaller) (Morrowind)
    [88394] = { [1160] = UnitNames.NPC_Icereach_Beastcaller }, -- Gore (Beastcaller) (Morrowind)
    [88409] = { [1160] = UnitNames.NPC_Icereach_Beastcaller }, -- Raise the Earth (Beastcaller)
    [8977] = { [22] = UnitNames.NPC_Duneripper }, -- Sweep (Duneripper)

    [25211] = { [22] = UnitNames.Boss_The_Guardians_Strength }, -- Whirlwind Function (The Guardian's Strength)
    [25262] = { [22] = UnitNames.Boss_The_Guardians_Strength }, -- Hammer Strike (The Guardian's Soul)

    [63752] = { [0] = UnitNames.NPC_Feral_Soul_Shriven }, -- Vomit (Tutorial)
    [63521] = { [0] = UnitNames.Elite_Child_of_Bones }, -- Bone Crush (Tutorial)
    [107282] = { [1013] = UnitNames.Elite_Yaghra_Nightmare }, -- Impale (Yaghra Nightmare)
    [105867] = { [1013] = UnitNames.Elite_Yaghra_Nightmare }, -- Pustulant Explosion (Yaghra Nightmare)

    [121643] = { [1106] = UnitNames.NPC_Euraxian_Necromancer }, -- Defiled Ground (Euraxian Necromancer)

    [5240] = { [534] = UnitNames.Elite_Deathfang }, -- Lash (Giant Snake)
}

--- @class (partial) AlertZoneOverride
Data.AlertZoneOverride = alertZoneOverride
