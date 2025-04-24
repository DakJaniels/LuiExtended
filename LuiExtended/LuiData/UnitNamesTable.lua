-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

local zo_strformat = zo_strformat
local GetItemLinkName = GetItemLinkName

--- @class (partial) UnitNames
local unitNames =
{

    ----------------------------------------------------------------
    -- TARGET DUMMY NAMES ------------------------------------------
    ----------------------------------------------------------------

    Dummy_Robust_Target_Dromathra = zo_strformat("<<1>>", GetItemLinkName("|H0:item:151906:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Dummy_Robust_Target_Minotaur_Handler = zo_strformat("<<1>>", GetItemLinkName("|H0:item:130193:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Dummy_Soul_Sworn_Thrall = GetItemLinkName("|H0:item:165569:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Dummy_Target_Bloodknight = zo_strformat("<<1>>", GetItemLinkName("|H0:item:169117:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Dummy_Bone_Goliath_Reanimated = GetItemLinkName("|H0:item:153563:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),              -- Verified
    Dummy_Target_Centurion_Dwarf_Brass = GetItemLinkName("|H0:item:126035:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),         -- Verified
    Dummy_Target_Centurion_Lambent = GetItemLinkName("|H0:item:126037:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),             -- Verified
    Dummy_Target_Centurion_Robust_Lambent = GetItemLinkName("|H0:item:126038:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- Verified
    Dummy_Target_Centurion_Robust_Refabricated = GetItemLinkName("|H0:item:126036:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), -- Verified
    Dummy_Target_Frost_Atronach = GetItemLinkName("|H0:item:156669:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Target_Harrowing_Reaper_Trial = GetItemLinkName("|H0:item:171875:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Dummy_Target_Iron_Atronach = zo_strformat("<<1>>", GetItemLinkName("|H0:item:130195:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Dummy_Target_Iron_Atronach_Trial = GetItemLinkName("|H0:item:147926:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),               -- Verified
    Dummy_Target_Mournful_Aegis = GetItemLinkName("|H0:item:134823:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Dummy_Target_Skeleton_Argonian = GetItemLinkName("|H0:item:120427:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),                 -- Verified
    Dummy_Target_Skeleton_Humanoid = GetItemLinkName("|H0:item:118553:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),                 -- Verified
    Dummy_Target_Skeleton_Khajiit = GetItemLinkName("|H0:item:120426:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),                  -- Verified
    Dummy_Target_Skeleton_Robust_Argonian = GetItemLinkName("|H0:item:121400:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),          -- Verified
    Dummy_Target_Skeleton_Robust_Humanoid = GetItemLinkName("|H0:item:121314:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),          -- Verified
    Dummy_Target_Skeleton_Robust_Khajiit = GetItemLinkName("|H0:item:121399:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),           -- Verified
    Dummy_Target_Stone_Atronach = zo_strformat("<<1>>", GetItemLinkName("|H0:item:130194:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Dummy_Target_Stone_Husk = zo_strformat("<<1>>", GetItemLinkName("|H0:item:166960:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")), -- Verified
    Dummy_Target_Voriplasm = GetItemLinkName("|H0:item:146069:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Dummy_Target_Wraith_of_Crows = GetItemLinkName("|H0:item:141778:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Dummy_Target_The_Precursor = GetItemLinkName("|H0:item:132348:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    ----------------------------------------------------------------
    -- CYORDIIL GUARD NAMES ----------------------------------------
    ----------------------------------------------------------------

    NPC_Guard_AD = "Dominion Guard",
    NPC_Honor_Guard_AD = "Dominion Honor Guard",
    NPC_Temple_Guard_AD = "Dominion Temple Guard",
    NPC_Mender_AD = "Dominion Mender",
    NPC_Mage_Guard_AD = "Dominion Mage Guard",
    NPC_Skirmisher_AD = "Dominion Skirmisher",
    NPC_Archer_Guard_AD = "Dominion Archer Guard",
    NPC_Guard_DC = "Covenant Guard",
    NPC_Honor_Guard_DC = "Covenant Honor Guard",
    NPC_Temple_Guard_DC = "Covenant Temple Guard",
    NPC_Mender_DC = "Covenant Mender",
    NPC_Mage_Guard_DC = "Covenant Mage Guard",
    NPC_Skirmisher_DC = "Covenant Skirmisher",
    NPC_Archer_Guard_DC = "Covenant Archer Guard",
    NPC_Guard_EP = "Pact Guard",
    NPC_Honor_Guard_EP = "Pact Honor Guard",
    NPC_Temple_Guard_EP = "Pact Temple Guard",
    NPC_Mender_EP = "Pact Mender",
    NPC_Mage_Guard_EP = "Pact Mage Guard",
    NPC_Skirmisher_EP = "Pact Skirmisher",
    NPC_Archer_Guard_EP = "Pact Archer Guard",

    ----------------------------------------------------------------
    -- TRAPS -------------------------------------------------------
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    -- NORMAL NPC NAMES --------------------------------------------
    ----------------------------------------------------------------

    NPC_The_Feast = "The Feast",           -- GENERIC NPC
    NPC_Ice_Barrier = "Ice Barrier",
    NPC_Clannfear = "Clannfear",           -- GENERIC NPC
    NPC_Lion = "Lion",                     -- GENERIC NPC
    NPC_Lioness = "Lioness",               -- GENERIC NPC
    NPC_Sabre_Cat = "Sabre Cat",           -- GENERIC NPC
    NPC_Senche_Tiger = "Senche-Tiger",     -- GENERIC NPC
    NPC_Spectral_Senche_Tiger = "Spectral Senche-Tiger",
    NPC_Senche_Panther = "Senche-Panther", -- GENERIC NPC
    NPC_Spider = "Spider",
    NPC_Venomspit_Spider = "Venomspit Spider",
    NPC_Websnare_Spider = "Websnare Spider",
    NPC_Great_Bear = "Great Bear",
    NPC_Hleran_Noble = "Hleran Noble",
    NPC_Kagouti = "Kagouti",
    NPC_Bull_Kagouti = "Bull Kagouti",
    NPC_Daedrat = "Daedrat",
    NPC_Jackal = "Jackal",
    NPC_Skaafin_Miscreal = "Skaafin Miscreal",
    NPC_Skaafin_Wretch = "Skaafin Wretch",
    NPC_Skeleton = "Skeleton", -- Generic Mob (and Crypt of Hearts II)
    NPC_Bone_Flayer = "Bone Flayer",
    NPC_Bone_Reaver = "Bone Reaver",
    NPC_Risen_Dead = "Risen Dead",
    NPC_Spectral_Lamia = "Spectral Lamia",
    NPC_Dire_Wolf = "Dire Wolf",
    NPC_Thunderbug = "Thunderbug",
    NPC_Thunderbug_Lord = "Thunderbug Lord", -- VERIFIED - SPRIGGAN SUMMON
    NPC_Hoarvor = "Hoarvor",
    NPC_Auroran_Battlemage = "Auroran Battlemage",
    NPC_Watcher = "Watcher",
    NPC_Dremora_Narkynaz = "Dremora Narkynaz",
    NPC_Dremora_Kyngald = "Dremora Kyngald",         -- VERIFIED - BANISHED CELLS I
    NPC_Flame_Atronach = "Flame Atronach",           -- GENERIC NPC
    NPC_Skeletal_Infernal = "Skeletal Infernal",
    NPC_Skeletal_Archer = "Skeletal Archer",         -- VERIFIED - DUNGEON - CRYPT OF HEARTS I
    NPC_Skeletal_Pyromancer = "Skeletal Pyromancer", -- VERIFIED - DUNGEON - CRYPT OF HEARTS I
    NPC_Skeletal_Runecaster = "Skeletal Runecaster", -- VERIFIED - DUNGEON - CRYPT OF HEARTS I
    NPC_Ghost = "Ghost",                             -- GENERIC NPC
    NPC_Skeletal_Tempest = "Skeletal Tempest",
    NPC_Skeletal_Striker = "Skeletal Striker",
    NPC_Skeletal_Slayer = "Skeletal Slayer",
    NPC_Skeletal_Thundermaul = "Skeletal Thundermaul",
    NPC_Spectral_Storm_Mage = "Spectral Storm Mage",
    NPC_Sainted_Archer = "Sainted Archer",
    NPC_Sainted_Charger = "Sainted Charger",
    NPC_Gargoyle = "Gargoyle",               -- GENERIC NPC
    NPC_Xivilai = "Xivilai",                 -- GENERIC NPC
    NPC_Wraith = "Wraith",                   -- GENERIC NPC
    NPC_Daedroth = "Daedroth",               -- GENERIC NPC
    NPC_Daedric_Titan = "Daedric Titan",     -- GENERIC NPC
    NPC_Spider_Daedra = "Spider Daedra",     -- GENERIC NPC
    NPC_Spiderling = "Spiderling",           -- GENERIC NPC
    NPC_Flame_Ogrim = "Flame Ogrim",         -- GENERIC NPC (SUMMON)
    NPC_Winged_Twilight = "Winged Twilight", -- GENERIC NPC
    NPC_Alit = "Alit",                       -- GENERIC NPC
    NPC_Guar = "Guar",                       -- GENERIC NPC
    NPC_Cliff_Strider = "Cliff Strider",     -- GENERIC NPC
    NPC_Strangler = "Strangler",             -- GENERIC NPC
    NPC_Crocodile = "Crocodile",             -- GENERIC NPC
    NPC_Feral_Guardian = "Feral Guardian",   -- GENERIC NPC (SUMMON)

    NPC_Aura_of_Protection = "Aura of Protection",

    NPC_Heritance_Cutthroat = "Heritance Cutthroat",
    NPC_Heritance_Deadeye = "Heritance Deadeye",
    NPC_Heritance_Incendiary = "Heritance Incendiary",
    NPC_Bandit_Incendiary = "Bandit Incendiary",
    NPC_Bandit_Rogue = "Bandit Rogue",
    NPC_Bandit_Savage = "Bandit Savage",
    NPC_Sea_Viper_Tempest = "Sea Viper Tempest",
    NPC_Corrupt_Spriggan = "Corrupt Spriggan",
    NPC_Corrupt_Lurcher = "Corrupt Lurcher",

    NPC_Veiled_Infernal = "Veiled Infernal",
    NPC_Veiled_Bonelord = "Veiled Bonelord",
    NPC_Veiled_Necromancer = "Veiled Necromancer",
    NPC_Bone_Colossus = "Bone Colossus",

    NPC_Ancestral_Tempest = "Ancestral Tempest",
    NPC_Troll = "Troll",
    NPC_Bear = "Bear",

    NPC_Ghost_Viper_Deadeye = "Ghost Viper Deadeye",
    NPC_Spirit_Deadeye = "Spirit Deadeye",
    NPC_Thundermaul = "Thundermaul",
    NPC_Pact_Pyromancer = "Pact Pyromancer",
    NPC_Pact_Necromancer = "Pact Necromancer",
    NPC_Scamp = "Scamp",                             -- GENERIC NPC
    NPC_Dremora_Kynval = "Dremora Kynval",           -- GENERIC NPC
    NPC_Dremora_Hauzkyn = "Dremora Hauzkyn",         -- GENERIC NPC
    NPC_Dremora_Gandrakyn = "Dremora Gandrakyn",     -- GENERIC NPC
    NPC_Storm_Atronach = "Storm Atronach",           -- GENERIC NPC
    NPC_Lamia_Curare = "Lamia Curare",               -- GENERIC NPC

    NPC_Sea_Viper_Strongarm = "Sea Viper Strongarm", -- GENERIC NPC
    NPC_Sea_Viper_Berserker = "Sea Viper Berserker", -- GENERIC NPC
    NPC_Sea_Viper_Charger = "Sea Viper Charger",     -- GENERIC NPC
    NPC_Sea_Viper_Deadeye = "Sea Viper Deadeye",     -- GENERIC NPC
    NPC_Sea_Viper_Healer = "Sea Viper Healer",       -- GENERIC NPC

    NPC_Wolf = "Wolf",                               -- GENERIC NPC

    NPC_Grave_Archer = "Grave Archer",               -- GENERIC NPC (Stros M'Kai)
    NPC_Dogeater_Skirmisher = "Dogeater Skirmisher", -- GENERIC NPC (Stros M'Kai)
    NPC_Dogeater_Witch = "Dogeater Witch",           -- GENERIC NPC (Stros M'Kai)
    NPC_Drake_Cutthroat = "Drake Cutthroat",         -- GENERIC NPC (Stros M'Kai)
    NPC_Drake_Brigand = "Drake Brigand",             -- GENERIC NPC (Stros M'Kai)

    NPC_Ogrim = "Ogrim",                             -- GENERIC NPC

    NPC_Duneripper = "Duneripper",                   -- GENERIC NPC

    NPC_Dremora_Channeler = "Dremora Channeler",     -- Cyrodiil IC Bridges
    NPC_Burdening_Eye = "Burdening Eye",             -- Summoned NPC

    NPC_Dremora_Caitiff = "Dremora Caitiff",         -- Dremora Caitiff

    -- DWEMER
    NPC_Dwarven_Sphere = "Dwarven Sphere",
    NPC_Dwarven_Spider = "Dwarven Spider",
    NPC_Dwarven_Centurion = "Dwarven Centurion",

    ----------------------------------------------------------------
    -- QUESTS ------------------------------------------------------
    ----------------------------------------------------------------

    -- MSQ
    Elite_Vaekar_the_Forgemaster = "Vaekar the Forgemaster",
    NPC_Feral_Soul_Shriven = "Feral Soul Shriven",
    NPC_Dremora_Baunekyn = "Dremora Baunekyn",
    NPC_Skeletal_Ravager = "Skeletal Ravager",
    Elite_Child_of_Bones = "Child of Bones",

    Boss_Ragjar = "Ragjar",
    Boss_Manifestation_of_Regret = "Manifestation of Regret",
    Boss_Ancient_Clannfear = "Ancient Clannfear",
    Boss_Manifestation_of_Terror = "Manifestation of Terror",
    Boss_Mannimarco = "Mannimarco",

    -- Mages Guild
    Boss_Uncle_Leo = "Uncle Leo",
    Boss_Haskill = "Haskill",

    -- Aldmeri Dominion

    -- AQ Overland
    Elite_Arstul = "Arstul",
    Elite_Garggeel = "Garggeel",

    -- AD Quests
    Elite_Sorondil = "Sorondil",
    Elite_Amuur = "Amuur",
    Elite_Minantilles_Rage = "Minantille's Rage",
    Elite_Sanessalmo = "Sanessalmo",
    Elite_Uricantar = "Uricantar",
    Elite_Centurion_Earran = "Centurion Earran",
    Elite_Nolonir = "Nolonir",
    Elite_Malangwe = "Malangwe",
    Elite_Karulae = "Karulae",
    Elite_Vregas = "Vregas",
    Boss_Norion = "Norion",
    Elite_Canonreeve_Malanie = "Canonreeve Malanie",
    Elite_Mezelukhebruz = "Mezelukhebruz",
    Elite_Marrow = "Marrow",
    Boss_High_Kinlady_Estre = "High Kinlady Estre",
    Elite_Free_Will = "Free Will",
    Boss_Mayor_Aulus = "Mayor Aulus",
    Elite_General_Endare = "General Endare",
    Boss_Prince_Naemon = "Prince Naemon",
    Elite_Baham = "Baham",
    Boss_Vicereeve_Pelidil = "Vicereeve Pelidil",
    Boss_Shade_of_Naemon = "Shade of Naemon",

    -- DC Quests
    Elite_Deathfang = "Deathfang",
    Elite_King_Demog = "King Demog",
    Elite_Gornog = "Gornog",
    Elite_Tempered_Sphere = "Tempered Sphere",

    -- Vvardenfell
    NPC_Slaver_Cutthroat = "Slaver Cutthroat",
    NPC_Slaver_Archer = "Slaver Archer",
    Elite_First_Mate_Ulveni = "First Mate Ulveni",

    -- Summerset Quests
    Elite_Yaghra_Nightmare = "Yaghra Nightmare",
    NPC_Dessicated_Archer = "Dessicated Archer",
    NPC_Dessicated_Fire_Mage = "Dessicated Fire Mage",

    -- Elsweyr Quests
    NPC_Euraxian_Necromancer = "Euraxian Necromancer",
    Elite_Captain_Carvain = "Captain Carvain",
    Boss_Bahlokdaan = "Bahlokdaan",

    -- Greymoor Quests
    Elite_Vitrus_the_Bloody = "Vitrus the Bloody",
    Elite_Matron_Urgala = "Matron Urgala",
    NPC_Frostbite_Spider = "Frostbite Spider",
    NPC_Icereach_Chillrender = "Icereach Chillrender",
    NPC_Icereach_Brute = "Icereach Brute",
    NPC_Icereach_Thornslinger = "Icereach Thornslinger",
    NPC_Icereach_Charger = "Icereach Charger",
    NPC_Icereach_Beastcaller = "Icereach Beastcaller",

    ----------------------------------------------------------------
    -- WORLD BOSSES ------------------------------------------------
    ----------------------------------------------------------------

    -- Auridon
    Boss_Norendo = "Norendo",                     -- Auridon (Soulfire Plateau)
    Boss_Eraman = "Eraman",                       -- Auridon (Soulfire Plateau)
    Boss_Quendia = "Quendia",                     -- Auridon (Soulfire Plateau)
    Boss_Quenyas = "Quenyas",                     -- Auridon (Seaside Scarp Camp)
    Boss_Oskana = "Oskana",                       -- Auridon (Seaside Scarp Camp)
    Boss_Captain_Blanchete = "Captain Blanchete", -- Auridon (Wreck of the Raptor)
    Boss_Snapjaw = "Snapjaw",                     -- Auridon (Heretic's Summons)
    Boss_The_Nestmother = "The Nestmother",       -- Auridon (Nestmothers Den)
    Boss_Anarume = "Anarume",                     -- Auridon (Heritance Proving Ground)

    -- Grahtwood
    Boss_Bavura_the_Blizzard = "Bavura the Blizzard",     -- Grahtwood (Nindaeril's Perch)
    Boss_Nindaeril_the_Monsoon = "Nindaeril the Monsoon", -- Grahtwood (Nindaeril's Perch)
    Boss_Shagura = "Shagura",                             -- Grahtwood (Hircine's Henge)
    Boss_Gurgozu = "Gurgozu",                             -- Grahtwood (Hircine's Henge)
    Boss_Valanir_the_Restless = "Valanir the Restless",   -- Grahtwood (Valanir's Rest)
    Boss_Valanirs_Shield = "Valanir's Shield",            -- Grahtwood (Valanir's Rest)
    Boss_Lady_Solace = "Lady Solace",                     -- Grahtwood (Lady Solace's Fen)
    Boss_Otho_Rufinus = "Otho Rufinus",                   -- Grahtwood (Poacher Camp)
    Boss_Thugrub_the_Reformed = "Thugrub the Reformed",   -- Grahtwood (Thugrub's Cave)

    -- Greenshade
    Boss_Zymel_Etitan = "Zymel Etitan",                   -- Greenshade (Pelda Tarn)
    Boss_Gathongor_the_Mauler = "Gathongor the Mauler",   -- Greenshade (Gathongor's Mine)
    Boss_Smiles_With_Knife = "Smiles-With-Knife",         -- Greenshade (Reconnaissance Camp)
    Boss_Maheelius = "Maheelius",                         -- Greenshade (Reconnaissance Camp)
    Boss_Navlos = "Navlos",                               -- Greenshade (Reconnaissance Camp)
    Boss_Heart_of_Rootwater = "Heart of Rootwater",       -- Greenshade (Rootwater Spring)
    Boss_Thodundor_of_the_Hill = "Thodundor of the Hill", -- Greenshade (Thodundor's View)
    Boss_Neiral = "Neiral",                               -- Greenshade (Maormer Camp View)
    Boss_Hetsha = "Hetsha",                               -- Greenshade (Maormer Camp View)
    Boss_Jahlasri = "Jahlasri",                           -- Greenshade (Maormer Camp View)

    -- Malabal Tor
    Boss_Thjormar_the_Drowned = "Thjormar the Drowned",   -- Malabal Tor (Bitterpoint Strand)
    Boss_Drowned_First_Mate = "Drowned First Mate",       -- Malabal Tor (Bitterpoint Strand)
    Boss_Dugan_the_Red = "Dugan the Red",                 -- Malabal Tor (Dugan's Knoll)
    Boss_Bagul = "Bagul",                                 -- Malabal Tor (Dugan's Knoll)
    Boss_Fangoz = "Fangoz",                               -- Malabal Tor (Dugan's Knoll)
    Boss_Bone_Grappler = "Bone Grappler",                 -- Malabal Tor (Bone Grappler's Nest)
    Boss_Tallatta_the_Lustrous = "Tallatta the Lustrous", -- Malabal Tor (Jagged Grotto)
    Boss_Commander_Faldethil = "Commander Faldethil",     -- Malabal Tor (River Edge)

    -- Reaper's March
    Boss_Gravecaller_Niramo = "Gravecaller Niramo",             -- Reaper's March (Reaper's Henge)
    Boss_Varien = "Varien",                                     -- Reaper's March (Reaper's Henge)
    Boss_Dirge_of_Thorns = "Dirge of Thorns",                   -- Reaper's March (Deathsong Cleft)
    Boss_Ravenous_Loam = "Ravenous Loam",                       -- Reaper's March (Deathsong Cleft)
    Boss_Queen_of_Three_Mercies = "Queen of Three Mercies",     -- Reaper's March (Waterdancer Falls)
    Boss_Overlord_Nur_dro = "Overlord Nur-dro",                 -- Reaper's March (Ushmal's Rest)
    Boss_Big_Ozur = "Big Ozur",                                 -- Reaper's March (Big Ozur's Valley)
    Boss_Ysolmarr_the_Roving_Pyre = "Ysolmarr the Roving Pyre", -- Reaper's March (Old S'ren-ja Docks)

    -- Glenumbra
    Boss_Limbscather = "Limbscather",                    -- Western Overlook (Glenumbra)
    Boss_Salazar_the_Wolf = "Salazar the Wolf",          -- The Wolf's Camp (Glenumbra)
    Boss_Lieutenant_Bran = "Lieutenant Bran",            -- The Wolf's Camp (Glenumbra)
    Boss_Annyce = "Annyce",                              -- The Wolf's Camp (Glenumbra)
    Boss_Asard_the_Putrid = "Asard the Putrid",          -- North Shore Point (Glenumbra)
    Boss_Graufang = "Graufang",                          -- Seaview Point (Glenumbra)
    Boss_Grivier_Bloodcaller = "Grivier Bloodcaller",    -- Balefire Island (Glenumbra)
    Boss_Griviers_Monstrosity = "Grivier's Monstrosity", -- Balefire Island (Glenumbra)

    -- Stormhaven
    Boss_Old_Widow_Silk = "Old Widow Silk", -- Spider Nest (Stormhaven)
    Boss_Titanclaw = "Titanclaw",           -- Mudcrab Beach (Stormhaven)
    Boss_Brood_Queen = "Brood Queen",       -- Dreugh Waters (Stormhaven)
    Boss_Gar_Xuu_Gar = "Gar Xuu Gar",       -- Abandoned Farm (Stormhaven)
    Boss_Cousin_Scrag = "Cousin Scrag",     -- Scrag's Larder (Stormhaven)
    Boss_Zymel_Kruz = "Zymel Kruz",         -- Ancient Altar (Stormhaven)

    -- Rivenspire
    Boss_Aesar_the_Hatespinner = "Aesar the Hatespinner", -- Aesar's Web (Rivenspire)
    Boss_Magdelena = "Magdelena",                         -- Magdelena's Haunt (Rivenspire)
    Boss_Calixte_Darkblood = "Calixte Darkblood",         -- Old Kalgon's Keep (Rivenspire)
    Boss_Louna_Darkblood = "Louna Darkblood",             -- Old Kalgon's Keep (Rivenspire)
    Boss_Lyse_Darkblood = "Lyse Darkblood",               -- Old Kalgon's Keep (Rivenspire)
    Boss_Stroda_gra_Drom = "Stroda gra-Drom",             -- East-Rock Landing (Rivenspire)
    Boss_Desuuga_the_Siren = "Desuuga the Siren",         -- Siren's Cove (Rivenspire)

    -- Dolmen Bosses
    NPC_Dread_Xivkyn_Cauterizer = "Dread Xivkyn Cauterizer",
    NPC_Dread_Xivkyn_Dreadweaver = "Dread Xivkyn Dreadweaver",
    NPC_Dread_Xivkyn_Voidstalker = "Dread Xivkyn Voidstalker",
    NPC_Dread_Xivkyn_Chillfiend = "Dread Xivkyn Chillfiend",
    NPC_Dread_Xivkyn_Banelord = "Dread Xivkyn Banelord",
    Boss_Vika = "Vika",
    Boss_Dylora = "Dylora",
    Boss_Jansa = "Jansa",
    Boss_Medrike = "Medrike",
    Boss_Anaxes = "Anaxes",

    ----------------------------------------------------------------
    -- PUBLIC DUNGEONS ---------------------------------------------
    ----------------------------------------------------------------

    Boss_Nitch = "Nitch",                                     -- Auridon (Toothmaul Gully)
    Boss_Thek_Elf_Stabber = "Thek Elf-Stabber",               -- Auridon (Toothmaul Gully)
    Boss_Black_Bessie = "Black Bessie",                       -- Auridon (Toothmaul Gully)
    Boss_Bloodroot = "Bloodroot",                             -- Auridon (Toothmaul Gully)
    Boss_Togga_the_Skewerer = "Togga the Skewerer",           -- Auridon (Toothmaul Gully)
    Boss_Dzeizik = "Dzeizik",                                 -- Auridon (Toothmaul Gully)
    Boss_Slakkith = "Slakkith",                               -- Auridon (Toothmaul Gully)
    Boss_Gorg = "Gorg",                                       -- Auridon (Toothmaul Gully)

    Boss_Great_Thorn = "Great Thorn",                         -- Grahtwood (Root Sunder Ruins)
    Boss_The_Devil_Wrathmaw = "The Devil Wrathmaw",           -- Grahtwood (Root Sunder Ruins)
    Boss_Rootbiter = "Rootbiter",                             -- Grahtwood (Root Sunder Ruins)
    Boss_Silent_Claw = "Silent Claw",                         -- Grahtwood (Root Sunder Ruins)
    Boss_Thick_Bark = "Thick-Bark",                           -- Grahtwood (Root Sunder Ruins)
    Boss_Guardian_of_Root_Sunder = "Guardian of Root Sunder", -- Grahtwood (Root Sunder Ruins)

    Boss_Lost_Master = "Lost Master",                         -- Greenshade (Rulanyil's Fall)
    Boss_Utiasl = "Utiasl",                                   -- Greenshade (Rulanyil's Fall)
    Boss_Skirar_the_Decaying = "Skirar the Decaying",         -- Greenshade (Rulanyil's Fall)
    Boss_Magna_Tharn = "Magna Tharn",                         -- Greenshade (Rulanyil's Fall)
    Boss_Hannat_the_Bonebringer = "Hannat the Bonebringer",   -- Greenshade (Rulanyil's Fall)

    ----------------------------------------------------------------
    -- ARENAS ------------------------------------------------------
    ----------------------------------------------------------------

    -- Dragonstar Arena
    NPC_Fighters_Guild_Gladiator = "Fighters Guild Gladiator",
    Boss_Champion_Marcauld = "Champion Marcauld",
    NPC_Sovngarde_Slayer = "Sovngarde Slayer",
    NPC_Sovngarde_Icemage = "Sovngarde Icemage",
    NPC_Sovngarde_Ranger = "Sovngarde Ranger",
    Boss_Yavni_Frost_Skin = "Yavni Frost-Skin",
    Boss_Katti_Ice_Turner = "Katti Ice-Turner",
    Boss_Shilia = "Shilia",
    Boss_Nak_tah = "Nak'tah",
    NPC_House_Dres_Slaver = "House Dres Slaver",
    Boss_Earthen_Heart_Knight = "Earthen Heart Knight",
    NPC_Anka_Ra_Shadowcaster = "Anka-Ra Shadowcaster",
    Boss_Anala_tuwha = "Anal'a Tu'wha",
    NPC_Pacthunter_Ranger = "Pacthunter Ranger",
    Boss_Pishna_Longshot = "Pishna Longshot",
    NPC_Daedric_Sacrifice = "Daedric Sacrifice",
    Boss_Shadow_Knight = "Shadow Knight",
    Boss_Dark_Mage = "Dark Mage",
    NPC_Dwarven_Fire_Centurion = "Dwarven Fire Centurion",
    Boss_Mavus_Talnarith = "Mavus Talnarith",
    NPC_Graveoath_Ravener = "Graveoath Ravener",
    Boss_Zackael_Jonnicent = "Zackael Jonnicent",
    Boss_Rubyn_Jonnicent = "Rubyn Jonnicent",
    Boss_Vampire_Lord_Thisa = "Vampire Lord Thisa",
    Boss_Hiath_the_Battlemaster = "Hiath the Battlemaster",

    -- Maelstrom Arena
    Boss_Maxus_the_Many = "Maxus the Many",
    NPC_Clockwork_Sentry = "Clockwork Sentry",
    NPC_Queens_Pet = "Queen's Pet",
    NPC_Queens_Champion = "Queen's Champion",
    NPC_Queens_Advisor = "Queen's Advisor",
    Boss_Lamia_Queen = "Lamia Queen",
    Boss_The_Control_Guardian = "The Control Guardian",
    NPC_Scavenger_Thunder_Smith = "Scavenger Thunder-Smith",
    NPC_Troll_Breaker = "Troll Breaker",
    NPC_Ogre_Elder = "Ogre Elder",
    Boss_Matriarch_Runa = "Matriarch Runa",

    ----------------------------------------------------------------
    -- DUNGEONS ----------------------------------------------------
    ----------------------------------------------------------------

    -- Banished Cells I
    Boss_Cell_Haunter = "Cell Haunter",
    Boss_Shadowrend = "Shadowrend",
    Boss_Angata_the_Clannfear_Handler = "Angata the Clannfear Handler",
    Boss_Skeletal_Destroyer = "Skeletal Destroyer",
    Boss_High_Kinlord_Rilis = "High Kinlord Rilis",
    NPC_Banished_Archer = "Banished Archer",
    NPC_Banished_Mage = "Banished Mage",

    -- Banished Cells II
    Boss_Keeper_Areldur = "Keeper Areldur",
    Boss_Maw_of_the_Infernal = "Maw of the Infernal",
    Boss_Keeper_Voranil = "Keeper Voranil",
    Boss_Keeper_Imiril = "Keeper Imiril",
    NPC_Dremora_Clasher = "Dremora Clasher",
    NPC_Dark_Twilight = "Dark Twilight",
    NPC_Dark_Clannfear = "Dark Clannfear",

    -- Elden Hollow I
    Boss_Ancient_Spriggan = "Ancient Spriggan",
    Boss_Akash_gra_Mal = "Akash gra-Mal",
    Boss_Chokethorn = "Chokethorn",
    NPC_Strangler_Saplings = "Strangler Saplings",
    Boss_Nenesh_gro_Mal = "Nenesh gro-Mal",
    Boss_Leafseether = "Leafseether",
    Boss_Canonreeve_Oraneth = "Canonreeve Oraneth",
    NPC_Darkfern_Archer = "Darkfern Archer",
    NPC_Darkfern_Flamerender = "Darkfern Flamerender",
    NPC_Darkfern_Stalker = "Darkfern Stalker",
    NPC_Darkfern_Mauler = "Darkfern Mauler",

    -- Elden Hollow II
    Boss_Dubroze_the_Infestor = "Dubroze the Infestor",
    Boss_Dark_Root = "Dark Root",
    NPC_Frenzied_Guardian = "Frenzied Guardian",
    NPC_Mystic_Guardian = "Mystic Guardian",
    NPC_Dremora_Invoker = "Dremora Invoker",
    NPC_Daedric_Lurcher = "Daedric Lurcher",
    NPC_Infested_Invoker = "Infested Invoker",
    Boss_Azara_the_Frightener = "Azara the Frightener",
    Boss_Shadow_Tendril = "Shadow Tendril",
    Boss_Murklight = "Murklight",
    Boss_The_Shadow_Guard = "The Shadow Guard",
    Boss_Bogdan_the_Nightflame = "Bogdan the Nightflame",
    Boss_Nova_Tendril = "Nova Tendril",

    -- City of Ash I
    Boss_Golor_the_Banekin_Handler = "Golor the Banekin Handler",
    Boss_Warden_of_the_Shrine = "Warden of the Shrine",
    Boss_Infernal_Guardian = "Infernal Guardian",
    Boss_Dark_Ember = "Dark Ember",
    Boss_Rothariel_Flameheart = "Rothariel Flameheart",
    Boss_Razor_Master_Erthas = "Razor Master Erthas",
    NPC_Dagonite_Archer = "Dagonite Archer",
    NPC_Dagonite_Assassin = "Dagonite Assassin",
    NPC_Dremora_Berserker = "Dremora Berserker",

    -- City of Ash II
    Boss_Akezel = "Akezel",
    Boss_Rukhan = "Rukhan",
    Boss_Marruz = "Marruz",
    NPC_Xivilai_Immolator = "Xivilai Immolator",
    NPC_Xivilai_Ravager = "Xivilai Ravager",
    NPC_Venomous_Skeleton = "Venomous Skeleton",
    Boss_Urata_the_Legion = "Urata the Legion",
    NPC_Flame_Colossus = "Flame Colossus",
    Boss_Horvantud_the_Fire_Maw = "Horvantud the Fire Maw",
    Boss_Ash_Titan = "Ash Titan",
    NPC_Air_Atronach = "Air Atronach",
    NPC_Fire_Ravager = "Fire Ravager",
    NPC_Xivilai_Fulminator = "Xivilai Fulminator",
    NPC_Xivilai_Boltaic = "Xivilai Boltaic",
    Boss_Valkyn_Skoria = "Valkyn Skoria",
    NPC_Urata_Militant = "Urata Militant",
    NPC_Urata_Elementalist = "Urara Elementalist",

    -- Tempest Island
    Boss_Sonolia_the_Matriarch = "Sonolia the Matriarch",
    Boss_Valaran_Stormcaller = "Valaran Stormcaller",
    NPC_Lightning_Avatar = "Lightning Avatar",
    Boss_Yalorasse_the_Speaker = "Yalorasse the Speaker",
    Boss_Stormfist = "Stormfist",
    Boss_Commodore_Ohmanil = "Commodore Ohmanil",
    Boss_Stormreeve_Neidir = "Stormreeve Neidir",

    -- Selene's Web
    Boss_Treethane_Kerninn = "Treethane Kerninn",
    Boss_Longclaw = "Longclaw",
    Boss_Silentpaw = "Silentpaw",
    Boss_Heartstalker = "Heartstalker",
    Boss_Nighteyes = "Nighteyes",
    Boss_Shadowhiskers = "Shadowhiskers",
    Boss_Queen_Aklayah = "Queen Aklayah",
    Boss_Foulhide = "Foulhide",
    Boss_Mennir_Many_Legs = "Mennir Many-Legs",
    Boss_Selene = "Selene",

    -- Spindleclutch I
    Boss_Spindlekin = "Spindlekin",
    Boss_Swarm_Mother = "Swarm Mother",
    Boss_Cerise_the_Widow_Maker = "Cerise the Widow-Maker",
    Boss_Big_Rabbu = "Big Rabbu",
    Boss_The_Whisperer = "The Whisperer",
    Boss_Praxin_Douare = "Praxin Douare",

    -- Spindleclutch II
    Boss_Mad_Mortine = "Mad Mortine",
    Boss_Blood_Spawn = "Blood Spawn",
    NPC_The_Whisperer_Nightmare = "The Whisperer Nightmare",
    NPC_Flesh_Atronach = "Flesh Atronach", -- Generic NPC
    Boss_Urvan_Veleth = "Urvan Veleth",
    Boss_Vorenor_Winterbourne = "Vorenor Winterbourne",

    -- Wayrest Sewers I
    Boss_Slimecraw = "Slimecraw",
    Boss_Investigator_Garron = "Investigator Garron",
    Boss_Uulgarg_the_Hungry = "Uulgarg the Hungry",
    Boss_the_Rat_Whisperer = "The Rat Whisperer",
    Boss_Varaine_Pellingare = "Varaine Pellingare",
    Boss_Allene_Pellingare = "Allene Pellingare",

    -- Wayrest Sewers II
    Boss_Malubeth_the_Scourger = "Malubeth the Scourger",
    Boss_Skull_Reaper = "Skull Reaper",
    Boss_Uulgarg_the_Risen = "Uulgarg the Risen",
    Boss_Garron_the_Returned = "Garron the Returned",
    Boss_The_Forgotten_One = "The Forgotten One",

    -- Crypt of Hearts I
    Boss_The_Mage_Master = "The Mage Master",
    Boss_Archmaster_Siniel = "Archmaster Siniel",
    Boss_Deaths_Leviathan = "Death's Leviathan",
    Boss_Uulkar_Bonehand = "Uulkar Bonehand",
    Boss_Dogas_the_Berserker = "Dogas the Berserker",
    Boss_Ilambris_Athor = "Ilambris-Athor",
    Boss_Ilambris_Zaven = "Ilambris-Zaven",

    -- Crypt of Hearts II
    NPC_Spiderkith_Cauterizer = "Spiderkith Cauterizer",
    NPC_Spiderkith_Wefter = "Spiderkith Wefter",
    NPC_Spiderkith_Venifex = "Spiderkith Venifex",
    NPC_Spiderkith_Warper = "Spiderkith Warper",
    NPC_Spiderkith_Broodnurse = "Spiderkith Broodnurse",
    NPC_Spiderkith_Enervator = "Spiderkith Enervator",
    Boss_Ibelgast = "Ibelgast",
    NPC_Ibelgasts_Flesh_Atronach = "Ibelgast's Flesh Atronach",
    NPC_Ibelgasts_Cauterizer = "Ibelgast's Cauterizer",
    NPC_Ibelgasts_Wefter = "Ibelgast's Wefter",
    NPC_Ibelgasts_Broodnurse = "Ibelgast's Broodnurse",
    Boss_Ruzozuzalpamaz = "Ruzozuzalpamaz",
    Boss_Chamber_Guardian = "Chamber Guardian",
    Boss_Ilambris_Amalgam = "Ilambris Amalgam",
    Boss_Mezeluth = "Mezeluth",
    Boss_Nerieneth = "Nerien'eth",
    NPC_Student = "Student",

    -- Volenfell
    Boss_Desert_Lioness = "Desert Lioness",
    Boss_Desert_Lion = "Desert Lion",
    Boss_Quintus_Verres = "Quintus Verres",
    Boss_Monstrous_Gargoyle = "Monstrous Gargoyle",
    Boss_Boilbite = "Boilbite",
    Boss_Boilbites_Assassin_Beetle = "Boilbite's Assassin Beetle",
    Boss_Unstable_Construct = "Unstable Construct",
    Boss_Unstable_Dwarven_Spider = "Unstable Dwarven Spider",
    NPC_Treasure_Hunter_Healer = "Treasure Hunter Healer",
    NPC_Treasure_Hunter_Incendiary = "Treasure Hunter Incendiary",
    NPC_Imperial_Overseer = "Imperial Overseer",
    Boss_Tremorscale = "Tremorscale",
    Boss_The_Guardians_Strength = "The Guardian's Strength",
    Boss_The_Guardians_Spark = "The Guardian's Spark",
    Boss_The_Guardians_Soul = "The Guardian's Soul",

    -- Frostvault
    NPC_Coldsnap_Ogre = "Coldsnap Ogre",
    Boss_Icestalker = "Icestalker",
}

--- @class (partial) UnitNames
Data.UnitNames = unitNames
