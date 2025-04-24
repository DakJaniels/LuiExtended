-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local UnitNames = Data.UnitNames


--------------------------------------------------------------------------------------------------------------------------------
-- When a target name matches a string here, add id's in the table with the name and icon specified. We use this primarily to add CC Immunity buffs for bosses.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) AddNameAura
local addNameAura =
{

    -- Target Dummy
    [UnitNames.Dummy_Robust_Target_Dromathra] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Robust_Target_Minotaur_Handler] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Soul_Sworn_Thrall] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Bloodknight] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Bone_Goliath_Reanimated] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Centurion_Dwarf_Brass] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Centurion_Lambent] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Centurion_Robust_Lambent] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Centurion_Robust_Refabricated] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Frost_Atronach] = { [1] = { id = 33097 } },
    [UnitNames.Target_Harrowing_Reaper_Trial] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Iron_Atronach] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Iron_Atronach_Trial] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Mournful_Aegis] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Skeleton_Humanoid] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Skeleton_Khajiit] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Skeleton_Argonian] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Skeleton_Robust_Humanoid] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Skeleton_Robust_Khajiit] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Skeleton_Robust_Argonian] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Stone_Atronach] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Stone_Husk] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Voriplasm] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_Wraith_of_Crows] = { [1] = { id = 33097 } },
    [UnitNames.Dummy_Target_The_Precursor] = { [1] = { id = 33097 } },

    -- Various Mobs
    [UnitNames.NPC_Daedroth] = { [1] = { id = 999013, zone = { [935] = true } } }, -- Daedroth

    -- World Bosses

    -- Auridon
    [UnitNames.Boss_Norendo] = { [1] = { id = 33097 } },           -- Auridon (Soulfire Plateau)
    [UnitNames.Boss_Eraman] = { [1] = { id = 33097 } },            -- Auridon (Soulfire Plateau)
    [UnitNames.Boss_Quendia] = { [1] = { id = 33097 } },           -- Auridon (Soulfire Plateau)
    [UnitNames.Boss_Quenyas] = { [1] = { id = 33097 } },           -- Auridon (Seaside Scarp Camp)
    [UnitNames.Boss_Captain_Blanchete] = { [1] = { id = 33097 } }, -- Auridon (Wreck of the Raptor)
    [UnitNames.Boss_Snapjaw] = { [1] = { id = 33097 } },           -- Auridon (Heretic's Summons)
    [UnitNames.Boss_The_Nestmother] = { [1] = { id = 33097 } },    -- Auridon (Nestmothers Den)
    [UnitNames.Boss_Anarume] = { [1] = { id = 33097 } },           -- Auridon (Heritance Proving Ground)

    -- Grahtwood
    [UnitNames.Boss_Bavura_the_Blizzard] = { [1] = { id = 33097 } },   -- Grahtwood (Nindaeril's Perch)
    [UnitNames.Boss_Nindaeril_the_Monsoon] = { [1] = { id = 33097 } }, -- Grahtwood (Nindaeril's Perch)
    [UnitNames.Boss_Shagura] = { [1] = { id = 33097 } },               -- Grahtwood (Hircine's Henge)
    [UnitNames.Boss_Gurgozu] = { [1] = { id = 33097 } },               -- Grahtwood (Hircine's Henge)
    [UnitNames.Boss_Valanirs_Shield] = { [1] = { id = 33097 } },       -- Grahtwood (Valanir's Rest)
    [UnitNames.Boss_Lady_Solace] = { [1] = { id = 33097 } },           -- Grahtwood (Lady Solace's Fen)
    [UnitNames.Boss_Otho_Rufinus] = { [1] = { id = 33097 } },          -- Grahtwood (Poacher Camp)
    [UnitNames.Boss_Thugrub_the_Reformed] = { [1] = { id = 33097 } },  -- Grahtwood (Thugrub's Cave)

    -- Greenshade
    [UnitNames.Boss_Gathongor_the_Mauler] = { [1] = { id = 33097 } },  -- Greenshade (Gathongor's Mine)
    [UnitNames.Boss_Smiles_With_Knife] = { [1] = { id = 33097 } },     -- Greenshade (Reconnaissance Camp)
    [UnitNames.Boss_Maheelius] = { [1] = { id = 33097 } },             -- Greenshade (Reconnaissance Camp)
    [UnitNames.Boss_Navlos] = { [1] = { id = 33097 } },                -- Greenshade (Reconnaissance Camp)
    [UnitNames.Boss_Heart_of_Rootwater] = { [1] = { id = 33097 } },    -- Greenshade (Rootwater Spring)
    [UnitNames.Boss_Thodundor_of_the_Hill] = { [1] = { id = 33097 } }, -- Greenshade (Thodundor's View)
    [UnitNames.Boss_Neiral] = { [1] = { id = 33097 } },                -- Greenshade (Maormer Camp View)
    [UnitNames.Boss_Hetsha] = { [1] = { id = 33097 } },                -- Greenshade (Maormer Camp View)
    [UnitNames.Boss_Jahlasri] = { [1] = { id = 33097 } },              -- Greenshade (Maormer Camp View)

    -- Malabal Tor
    [UnitNames.Boss_Thjormar_the_Drowned] = { [1] = { id = 33097 } },  -- Malabal Tor (Bitterpoint Strand)
    [UnitNames.Boss_Drowned_First_Mate] = { [1] = { id = 33097 } },    -- Malabal Tor (Bitterpoint Strand)
    [UnitNames.Boss_Dugan_the_Red] = { [1] = { id = 33097 } },         -- Malabal Tor (Dugan's Knoll)
    [UnitNames.Boss_Bagul] = { [1] = { id = 33097 } },                 -- Malabal Tor (Dugan's Knoll)
    [UnitNames.Boss_Fangoz] = { [1] = { id = 33097 } },                -- Malabal Tor (Dugan's Knoll)
    [UnitNames.Boss_Bone_Grappler] = { [1] = { id = 33097 } },         -- Malabal Tor (Bone Grappler's Nest)
    [UnitNames.Boss_Tallatta_the_Lustrous] = { [1] = { id = 33097 } }, -- Malabal Tor (Jagged Grotto)
    [UnitNames.Boss_Commander_Faldethil] = { [1] = { id = 33097 } },   -- Malabal Tor (River Edge)

    -- Reaper's March
    [UnitNames.Boss_Gravecaller_Niramo] = { [1] = { id = 33097 } },     -- Reaper's March (Reaper's Henge)
    [UnitNames.Boss_Varien] = { [1] = { id = 33097 } },                 -- Reaper's March (Reaper's Henge)
    [UnitNames.Boss_Dirge_of_Thorns] = { [1] = { id = 33097 } },        -- Reaper's March (Deathsong Cleft)
    [UnitNames.Boss_Ravenous_Loam] = { [1] = { id = 33097 } },          -- Reaper's March (Deathsong Cleft)
    [UnitNames.Boss_Queen_of_Three_Mercies] = { [1] = { id = 33097 } }, -- Reaper's March (Waterdancer Falls)
    [UnitNames.Boss_Overlord_Nur_dro] = { [1] = { id = 33097 } },       -- Reaper's March (Ushmal's Rest)
    [UnitNames.Boss_Big_Ozur] = { [1] = { id = 33097 } },               -- Reaper's March (Big Ozur's Valley)

    -- Glenumbra
    [UnitNames.Boss_Limbscather] = { [1] = { id = 33097 } },         -- Western Overlook (Glenumbra)
    [UnitNames.Boss_Salazar_the_Wolf] = { [1] = { id = 33097 } },    -- The Wolf's Camp (Glenumbra)
    [UnitNames.Boss_Lieutenant_Bran] = { [1] = { id = 33097 } },     -- The Wolf's Camp (Glenumbra)
    [UnitNames.Boss_Annyce] = { [1] = { id = 33097 } },              -- The Wolf's Camp (Glenumbra)
    [UnitNames.Boss_Asard_the_Putrid] = { [1] = { id = 33097 } },    -- The Wolf's Camp (Glenumbra)
    [UnitNames.Boss_Graufang] = { [1] = { id = 33097 } },            -- Seaview Point (Glenumbra)
    [UnitNames.Boss_Grivier_Bloodcaller] = { [1] = { id = 33097 } }, -- Balefire Island (Glenumbra)

    -- Stormhaven
    [UnitNames.Boss_Old_Widow_Silk] = { [1] = { id = 33097 } }, -- Spider Nest (Stormhaven)
    [UnitNames.Boss_Titanclaw] = { [1] = { id = 33097 } },      -- Mudcrab Beach (Stormhaven)
    [UnitNames.Boss_Brood_Queen] = { [1] = { id = 33097 } },    -- Dreugh Waters (Stormhaven)
    -- [UnitNames.Boss_Cousin_Scrag] = { [1] = { id = 33097 } }, -- Scrag's Larder (Stormhaven)

    -- Rivenspire
    [UnitNames.Boss_Aesar_the_Hatespinner] = { [1] = { id = 33097 } }, -- Aesar's Web (Rivenspire)
    [UnitNames.Boss_Magdelena] = { [1] = { id = 33097 } },             -- Magdelena's Haunt (Rivenspire)
    [UnitNames.Boss_Calixte_Darkblood] = { [1] = { id = 33097 } },     -- Old Kalgon's Keep (Rivenspire)
    [UnitNames.Boss_Louna_Darkblood] = { [1] = { id = 33097 } },       -- Old Kalgon's Keep (Rivenspire)
    [UnitNames.Boss_Lyse_Darkblood] = { [1] = { id = 33097 } },        -- Old Kalgon's Keep (Rivenspire)
    [UnitNames.Boss_Stroda_gra_Drom] = { [1] = { id = 33097 } },       -- East-Rock Landing (Rivenspire)
    [UnitNames.Boss_Desuuga_the_Siren] = { [1] = { id = 33097 } },     -- Siren's Cove (Rivenspire)

    -- Public Dungeon
    [UnitNames.Boss_Nitch] = { [1] = { id = 33097 } },                   -- Auridon (Toothmaul Gully)
    [UnitNames.Boss_Thek_Elf_Stabber] = { [1] = { id = 33097 } },        -- Auridon (Toothmaul Gully)
    [UnitNames.Boss_Black_Bessie] = { [1] = { id = 33097 } },            -- Auridon (Toothmaul Gully)
    [UnitNames.Boss_Bloodroot] = { [1] = { id = 33097 } },               -- Auridon (Toothmaul Gully)
    [UnitNames.Boss_Togga_the_Skewerer] = { [1] = { id = 33097 } },      -- Auridon (Toothmaul Gully)
    [UnitNames.Boss_Dzeizik] = { [1] = { id = 33097 } },                 -- Auridon (Toothmaul Gully)
    [UnitNames.Boss_Slakkith] = { [1] = { id = 33097 } },                -- Auridon (Toothmaul Gully)
    [UnitNames.Boss_Gorg] = { [1] = { id = 33097 } },                    -- Auridon (Toothmaul Gully)

    [UnitNames.Boss_Great_Thorn] = { [1] = { id = 33097 } },             -- Grahtwood (Root Sunder Ruins)
    [UnitNames.Boss_The_Devil_Wrathmaw] = { [1] = { id = 33097 } },      -- Grahtwood (Root Sunder Ruins)
    [UnitNames.Boss_Rootbiter] = { [1] = { id = 33097 } },               -- Grahtwood (Root Sunder Ruins)
    [UnitNames.Boss_Silent_Claw] = { [1] = { id = 33097 } },             -- Grahtwood (Root Sunder Ruins)
    [UnitNames.Boss_Thick_Bark] = { [1] = { id = 33097 } },              -- Grahtwood (Root Sunder Ruins)
    [UnitNames.Boss_Guardian_of_Root_Sunder] = { [1] = { id = 33097 } }, -- Grahtwood (Root Sunder Ruins)

    [UnitNames.Boss_Lost_Master] = { [1] = { id = 33097 } },             -- Greenshade (Rulanyil's Fall)
    [UnitNames.Boss_Utiasl] = { [1] = { id = 33097 } },                  -- Greenshade (Rulanyil's Fall)
    [UnitNames.Boss_Skirar_the_Decaying] = { [1] = { id = 33097 } },     -- Greenshade (Rulanyil's Fall)
    [UnitNames.Boss_Magna_Tharn] = { [1] = { id = 33097 } },             -- Greenshade (Rulanyil's Fall)
    [UnitNames.Boss_Hannat_the_Bonebringer] = { [1] = { id = 33097 } },  -- Greenshade (Rulanyil's Fall)

    -- MSQ
    [UnitNames.Boss_Ragjar] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Manifestation_of_Regret] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Ancient_Clannfear] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Manifestation_of_Terror] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Mannimarco] = { [1] = { id = 33097 } },

    -- Mages Guild
    [UnitNames.Boss_Uncle_Leo] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Haskill] = { [1] = { id = 33097 } },

    -- Aldmeri Dominion
    [UnitNames.Boss_High_Kinlady_Estre] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Mayor_Aulus] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Prince_Naemon] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Vicereeve_Pelidil] = { [1] = { id = 33097 } },

    -- Elsweyr Quests
    [UnitNames.Boss_Bahlokdaan] = { [1] = { id = 33097 } },

    -- Dolmen Bosses
    [UnitNames.NPC_Dread_Xivkyn_Cauterizer] = { [1] = { id = 33097 } },
    [UnitNames.NPC_Dread_Xivkyn_Dreadweaver] = { [1] = { id = 33097 } },
    [UnitNames.NPC_Dread_Xivkyn_Voidstalker] = { [1] = { id = 33097 } },
    [UnitNames.NPC_Dread_Xivkyn_Chillfiend] = { [1] = { id = 33097 } },
    [UnitNames.NPC_Dread_Xivkyn_Banelord] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Vika] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Dylora] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Jansa] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Medrike] = { [1] = { id = 33097 } },
    [UnitNames.Boss_Anaxes] = { [1] = { id = 33097 } },

    -- NPC's
    [UnitNames.NPC_Ice_Barrier] = { [1] = { id = 33097 } },
    -- [UnitNames.NPC_Aura_of_Protection] = { [1] = { id = 33097 } }, -- TODO: Not actually CC immune despite CC not doing anything (maybe switch to knockback immunity eventually)
    -- ['Ice Pillar'] = { [1] = { id = 33097 } }, -- TODO: Not actually CC immune despite CC not doing anything (maybe switch to knockback immunity eventually)

    -- Bosses
    ["War Chief Ozozai"] = { [1] = { id = 33097 } },
    ["Broodbirther"] = { [1] = { id = 33097 } },

    ["Mad Griskild"] = { [1] = { id = 33097 } },            -- Quest -- Vvardenfell -- A Web of Troubles
    ["Veya Releth"] = { [1] = { id = 33097 } },             -- Quest -- Vvardenfell - Family Reunion
    ["Old Rust-Eye"] = { [1] = { id = 33097 } },            -- Delve -- Vvardenfell - Khartag Point
    ["Cliff Strider Matriarch"] = { [1] = { id = 33097 } }, -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Beckoner Morvayn"] = { [1] = { id = 33097 } },        -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Confessor Dradas"] = { [1] = { id = 33097 } },        -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Coaxer Veran"] = { [1] = { id = 33097 } },            -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Castigator Athin"] = { [1] = { id = 33097 } },        -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Stone-Boiler Omalas"] = { [1] = { id = 33097 } },     -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Brander Releth"] = { [1] = { id = 33097 } },          -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Mountain-Caller Hlaren"] = { [1] = { id = 33097 } },  -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Wakener Maras"] = { [1] = { id = 33097 } },           -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Nevena Nirith"] = { [1] = { id = 33097 } },           -- PUBLIC DUNGEON - Vvardenfell - The Forgotten Wastes
    ["Mud-Tusk"] = { [1] = { id = 33097 } },                -- PUBLIC DUNGEON -- Vvardenfell - Nchuleftingth
    ["Guardian of Bthark"] = { [1] = { id = 33097 } },      -- PUBLIC DUNGEON -- Vvardenfell - Nchuleftingth
    ["Renduril the Hammer"] = { [1] = { id = 33097 } },     -- PUBLIC DUNGEON -- Vvardenfell - Nchuleftingth
    ["Friar Hadelar"] = { [1] = { id = 33097 } },           -- PUBLIC DUNGEON -- Vvardenfell - Nchuleftingth
    ["Steamreaver"] = { [1] = { id = 33097 } },             -- PUBLIC DUNGEON -- Vvardenfell - Nchuleftingth
    ["Artisan Lenarmen"] = { [1] = { id = 33097 } },        -- PUBLIC DUNGEON -- Vvardenfell - Nchuleftingth
    ["Nchulaeon the Eternal"] = { [1] = { id = 33097 } },   -- PUBLIC DUNGEON -- Vvardenfell - Nchuleftingth
    ["Nilarion the Cavalier"] = { [1] = { id = 33097 } },   -- PUBLIC DUNGEON -- Vvardenfell - Nchuleftingth
    ["Curate Erydno"] = { [1] = { id = 33097 } },           -- Quest -- Vvardenfell -- Divine Inquires
    ["Savarak Fels"] = { [1] = { id = 33097 } },            -- Quest -- Vvardenfell -- Reclamining Vos
    ["Th'krak the Tunnel-King"] = { [1] = { id = 33097 } }, -- Delve -- Vvardenfell -- Matus-Akin Egg Mine
    ["Slavemaster Arenim"] = { [1] = { id = 33097 } },      -- Quest -- Vvardenfell -- The Heart of a Telvanni
    ["Chodala"] = { [1] = { id = 33097 } },                 -- Quest -- Vvardenfell -- Divine Intervention
    ["Clockwork Guardian"] = { [1] = { id = 33097 } },      -- Quest -- Vvardenfell -- Divine Restoration
    ["Jovval Mortal-Bane"] = { [1] = { id = 33097 } },      -- Quest -- Vvardenfell -- Divine Restoration
    ["Clockwork Defense Core"] = { [1] = { id = 33097 } },  -- Quest -- Vvardenfell -- Divine Restoration
    ["Clockwork Mediator"] = { [1] = { id = 33097 } },      -- Quest -- Vvardenfell -- Divine Restoration
    ["Clockwork Mediator Core"] = { [1] = { id = 33097 } }, -- Quest -- Vvardenfell -- Divine Restoration
    ["Clockwork Assembly Core"] = { [1] = { id = 33097 } }, -- Quest -- Vvardenfell -- Divine Restoration
    ["Barbas"] = { [1] = { id = 33097 } },                  -- Quest -- Vvardenfell -- Divine Restoration

    --------------------------------------------
    -- ARENAS ----------------------------------
    --------------------------------------------

    -- Dragonstar Arena
    [UnitNames.Boss_Champion_Marcauld] = { [1] = { id = 33097 } },                              -- Champion Marcauld
    [UnitNames.Boss_Yavni_Frost_Skin] = { [1] = { id = 33097 } },                               -- Yavni Frost-Skin
    [UnitNames.Boss_Katti_Ice_Turner] = { [1] = { id = 33097 } },                               -- Katti Ice-Turner
    [UnitNames.Boss_Shilia] = { [1] = { id = 33097 } },                                         -- Shilia
    [UnitNames.Boss_Nak_tah] = { [1] = { id = 33097 } },                                        -- Nak'tah
    [UnitNames.Boss_Earthen_Heart_Knight] = { [1] = { id = 33097 } },                           -- Earthen Heart Knight
    [UnitNames.NPC_Anka_Ra_Shadowcaster] = { [1] = { id = 33097 } },                            -- Anka-Ra Shadowcaster
    [UnitNames.Boss_Anala_tuwha] = { [1] = { id = 33097 } },                                    -- Anal'a Tu'wha
    [UnitNames.NPC_Pacthunter_Ranger] = { [1] = { id = 33097 } },                               -- Pacthunter Ranger
    [UnitNames.Boss_Pishna_Longshot] = { [1] = { id = 33097 } },                                -- Pishna Longshot
    [UnitNames.Boss_Shadow_Knight] = { [1] = { id = 33097, zone = { [635] = true } } },         -- Shadow Knight (Dragonstar Arena)
    [UnitNames.Boss_Dark_Mage] = { [1] = { id = 33097, zone = { [635] = true } } },             -- Dark Mage (Dragonstar Arena)
    [UnitNames.NPC_Dwarven_Fire_Centurion] = { [1] = { id = 33097, zone = { [635] = true } } }, -- Dwarven Fire Centurion (Dragonstar Arena)
    [UnitNames.Boss_Mavus_Talnarith] = { [1] = { id = 33097 } },                                -- Mavus Talnarith
    [UnitNames.Boss_Zackael_Jonnicent] = { [1] = { id = 33097 } },                              -- Zackael Jonnicent
    [UnitNames.Boss_Rubyn_Jonnicent] = { [1] = { id = 33097 } },                                -- Rubyn Jonnicent
    [UnitNames.Boss_Vampire_Lord_Thisa] = { [1] = { id = 33097 } },                             -- Vampire Lord Thisa
    [UnitNames.Boss_Hiath_the_Battlemaster] = { [1] = { id = 33097 } },                         -- Hiath the Battlemaster

    -- Maelstrom Arena
    [UnitNames.Boss_Maxus_the_Many] = { [1] = { id = 33097 } },                           -- Maxus the Many
    [UnitNames.NPC_Clockwork_Sentry] = { [1] = { id = 33097, zone = { [677] = true } } }, -- Clockwork Sentry (Maelstrom Arena)
    [UnitNames.NPC_Queens_Pet] = { [1] = { id = 33097, zone = { [677] = true } } },       -- Queen's Pet (Maelstrom Arena)
    [UnitNames.NPC_Queens_Champion] = { [1] = { id = 33097, zone = { [677] = true } } },  -- Queen's Champion (Maelstrom Arena)
    [UnitNames.NPC_Queens_Advisor] = { [1] = { id = 33097, zone = { [677] = true } } },   -- Queen's Advisor (Maelstrom Arena)
    [UnitNames.Boss_Lamia_Queen] = { [1] = { id = 33097, zone = { [677] = true } } },     -- Lamia Queen (Maelstrom Arena)
    [UnitNames.Boss_The_Control_Guardian] = { [1] = { id = 33097 } },                     -- The Control Guardian
    [UnitNames.NPC_Troll_Breaker] = { [1] = { id = 33097 } },                             -- Troll Breaker
    [UnitNames.NPC_Ogre_Elder] = { [1] = { id = 33097, zone = { [677] = true } } },       -- Ogre Elder (Maelstrom Arena)
    [UnitNames.Boss_Matriarch_Runa] = { [1] = { id = 33097 } },                           -- Matriarch Runa

    --------------------------------------------
    -- DUNGEONS --------------------------------
    --------------------------------------------

    -- Banished Cells I
    [UnitNames.Boss_Cell_Haunter] = { [1] = { id = 33097 } },                 -- Cell Haunter
    [UnitNames.Boss_Shadowrend] = { [1] = { id = 33097 } },                   -- Shadowrend
    [UnitNames.Boss_Angata_the_Clannfear_Handler] = { [1] = { id = 33097 } }, -- Angata the Clannfear Handler
    [UnitNames.Boss_High_Kinlord_Rilis] = { [1] = { id = 33097 } },           -- High Kinlord Rilis

    -- Banished Cells II
    [UnitNames.Boss_Keeper_Areldur] = { [1] = { id = 33097 } },      -- Keeper Areldur
    [UnitNames.Boss_Maw_of_the_Infernal] = { [1] = { id = 33097 } }, -- Maw of the Infernal
    [UnitNames.Boss_Keeper_Voranil] = { [1] = { id = 33097 } },      -- Keeper Voranil
    [UnitNames.Boss_Keeper_Imiril] = { [1] = { id = 33097 } },       -- Keeper Imiril

    -- Elden Hollow I
    [UnitNames.Boss_Ancient_Spriggan] = { [1] = { id = 33097 } },   -- Ancient Spriggan
    [UnitNames.Boss_Akash_gra_Mal] = { [1] = { id = 33097 } },      -- Akash gra-Mal
    [UnitNames.Boss_Chokethorn] = { [1] = { id = 33097 } },         -- Chokethorn
    [UnitNames.Boss_Nenesh_gro_Mal] = { [1] = { id = 33097 } },     -- Nenesh gro-Mal
    [UnitNames.Boss_Leafseether] = { [1] = { id = 33097 } },        -- Leafseether
    [UnitNames.Boss_Canonreeve_Oraneth] = { [1] = { id = 33097 } }, -- Canonreeve Oraneth

    -- Elden Hollow II
    [UnitNames.Boss_Dubroze_the_Infestor] = { [1] = { id = 33097 } },  -- Dubroze the Infestor
    [UnitNames.Boss_Dark_Root] = { [1] = { id = 33097 } },             -- Dark Root
    [UnitNames.Boss_Azara_the_Frightener] = { [1] = { id = 33097 } },  -- Azara the Frightener
    [UnitNames.Boss_Shadow_Tendril] = { [1] = { id = 33097 } },        -- Shadow Tendril
    [UnitNames.Boss_Murklight] = { [1] = { id = 33097 } },             -- Murklight
    [UnitNames.Boss_The_Shadow_Guard] = { [1] = { id = 33097 } },      -- The Shadow Guard
    [UnitNames.Boss_Bogdan_the_Nightflame] = { [1] = { id = 33097 } }, -- Bogdan the Nightflame
    [UnitNames.Boss_Nova_Tendril] = { [1] = { id = 33097 } },          -- Nova Tendril

    -- City of Ash I
    [UnitNames.Boss_Golor_the_Banekin_Handler] = { [1] = { id = 33097 } }, -- Golor the Banekin Handler
    [UnitNames.Boss_Warden_of_the_Shrine] = { [1] = { id = 33097 } },      -- Warden of the Shrine
    [UnitNames.Boss_Infernal_Guardian] = { [1] = { id = 33097 } },         -- Infernal Guardian
    [UnitNames.Boss_Dark_Ember] = { [1] = { id = 33097 } },                -- Dark Ember
    [UnitNames.Boss_Rothariel_Flameheart] = { [1] = { id = 33097 } },      -- Rothariel Flameheart
    [UnitNames.Boss_Razor_Master_Erthas] = { [1] = { id = 33097 } },       -- Razor Master Erthas

    -- City of Ash II
    [UnitNames.Boss_Akezel] = { [1] = { id = 33097 } },                                  -- Akezel
    [UnitNames.Boss_Rukhan] = { [1] = { id = 33097 } },                                  -- Rukhan
    [UnitNames.Boss_Marruz] = { [1] = { id = 33097 } },                                  -- Marruz
    [UnitNames.NPC_Xivilai_Immolator] = { [1] = { id = 33097 } },                        -- Xivilai Immolator
    [UnitNames.NPC_Xivilai_Ravager] = { [1] = { id = 33097 } },                          -- Xivilai Ravager
    [UnitNames.Boss_Urata_the_Legion] = { [1] = { id = 33097 } },                        -- Urata the Legion
    [UnitNames.NPC_Flame_Colossus] = { [1] = { id = 33097 } },                           -- Flame Colossus
    [UnitNames.Boss_Horvantud_the_Fire_Maw] = { [1] = { id = 33097 } },                  -- Horvantud the Fire Maw
    [UnitNames.Boss_Ash_Titan] = { [1] = { id = 33097 } },                               -- Ash Titan
    [UnitNames.NPC_Air_Atronach] = { [1] = { id = 33097, zone = { [681] = true } } },    -- Air Atronach (City of Ash II)
    [UnitNames.NPC_Dremora_Hauzkyn] = { [1] = { id = 33097, zone = { [681] = true } } }, -- Dremora Hauzkyn (City of Ash II)
    [UnitNames.NPC_Fire_Ravager] = { [1] = { id = 33097 } },                             -- Fire Ravager
    [UnitNames.NPC_Xivilai_Fulminator] = { [1] = { id = 33097 } },                       -- Xivilai Fulminator
    [UnitNames.NPC_Xivilai_Boltaic] = { [1] = { id = 33097 } },                          -- Xivilai Fulminator
    [UnitNames.Boss_Valkyn_Skoria] = { [1] = { id = 33097 } },                           -- Valkyn Skoria

    -- Tempest Island
    [UnitNames.Boss_Sonolia_the_Matriarch] = { [1] = { id = 33097 } }, -- Sonolia the Matriarch
    [UnitNames.Boss_Valaran_Stormcaller] = { [1] = { id = 33097 } },   -- Valaran Stormcaller
    [UnitNames.NPC_Lightning_Avatar] = { [1] = { id = 33097 } },       -- Lightning Avatar
    [UnitNames.Boss_Yalorasse_the_Speaker] = { [1] = { id = 33097 } }, -- Yalorasse the Speaker
    [UnitNames.Boss_Stormfist] = { [1] = { id = 33097 } },             -- Stormfist
    [UnitNames.Boss_Commodore_Ohmanil] = { [1] = { id = 33097 } },     -- Commodore Ohmanil
    [UnitNames.Boss_Stormreeve_Neidir] = { [1] = { id = 33097 } },     -- Stormreeve Neidir

    -- Selene's Web
    [UnitNames.Boss_Treethane_Kerninn] = { [1] = { id = 33097 } }, -- Treethane Kerninn
    [UnitNames.Boss_Longclaw] = { [1] = { id = 33097 } },          -- Longclaw
    [UnitNames.Boss_Queen_Aklayah] = { [1] = { id = 33097 } },     -- Queen Aklayah
    [UnitNames.Boss_Foulhide] = { [1] = { id = 33097 } },          -- Foulhide
    [UnitNames.Boss_Mennir_Many_Legs] = { [1] = { id = 33097 } },  -- Mennir Many-Legs
    [UnitNames.Boss_Selene] = { [1] = { id = 33097 } },            -- Selene

    -- Spindleclutch I
    [UnitNames.Boss_Spindlekin] = { [1] = { id = 33097 } },             -- Spindlekin
    [UnitNames.Boss_Swarm_Mother] = { [1] = { id = 33097 } },           -- Swarm Mother
    [UnitNames.Boss_Cerise_the_Widow_Maker] = { [1] = { id = 33097 } }, -- Cerise the Widow-Maker
    [UnitNames.Boss_Big_Rabbu] = { [1] = { id = 33097 } },              -- Big Rabbu
    [UnitNames.Boss_The_Whisperer] = { [1] = { id = 33097 } },          -- The Whisperer
    [UnitNames.Boss_Praxin_Douare] = { [1] = { id = 33097 } },          -- Praxin Douare

    -- Spindleclutch II
    [UnitNames.Boss_Mad_Mortine] = { [1] = { id = 33097 } },                                          -- Mad Mortine
    [UnitNames.Boss_Blood_Spawn] = { [1] = { id = 33097 } },                                          -- Blood Spawn
    [UnitNames.NPC_Flesh_Atronach] = { [1] = { id = 33097, zone = { [936] = true, [932] = true } } }, -- Flesh Atronach
    [UnitNames.Boss_Urvan_Veleth] = { [1] = { id = 33097 } },                                         -- Urvan Veleth
    [UnitNames.Boss_Vorenor_Winterbourne] = { [1] = { id = 33097 } },                                 -- Vorenor Winterborne

    -- Wayrest Sewers I
    [UnitNames.Boss_Slimecraw] = { [1] = { id = 33097 } },           -- Slimecraw
    [UnitNames.Boss_Investigator_Garron] = { [1] = { id = 33097 } }, -- Investigator Garron
    [UnitNames.Boss_Uulgarg_the_Hungry] = { [1] = { id = 33097 } },  -- Uulgarg the Hungry
    [UnitNames.Boss_the_Rat_Whisperer] = { [1] = { id = 33097 } },   -- The Rat Whisperer
    [UnitNames.Boss_Varaine_Pellingare] = { [1] = { id = 33097 } },  -- Varaine Pellingare
    [UnitNames.Boss_Allene_Pellingare] = { [1] = { id = 33097 } },   -- Allene Pellingare

    -- Wayrest Sewers II
    [UnitNames.Boss_Malubeth_the_Scourger] = { [1] = { id = 33097 } }, -- Malubeth the Scourger
    [UnitNames.Boss_Skull_Reaper] = { [1] = { id = 33097 } },          -- Skull Reaper
    [UnitNames.Boss_Uulgarg_the_Risen] = { [1] = { id = 33097 } },     -- Uulgarg the Risen
    [UnitNames.Boss_Garron_the_Returned] = { [1] = { id = 33097 } },   -- Garron the Returned
    [UnitNames.Boss_The_Forgotten_One] = { [1] = { id = 33097 } },     -- The Forgotten One

    -- Crypt of Hearts I
    [UnitNames.Boss_The_Mage_Master] = { [1] = { id = 33097 } },     -- The Mage Master
    [UnitNames.Boss_Archmaster_Siniel] = { [1] = { id = 33097 } },   -- Archmaster Siniel
    [UnitNames.Boss_Deaths_Leviathan] = { [1] = { id = 33097 } },    -- Death's Leviathan
    [UnitNames.Boss_Dogas_the_Berserker] = { [1] = { id = 33097 } }, -- Dogas the Berserker
    [UnitNames.Boss_Ilambris_Athor] = { [1] = { id = 33097 } },      -- Ilambris-Athor
    [UnitNames.Boss_Ilambris_Zaven] = { [1] = { id = 33097 } },      -- Ilambris-Zaven

    -- Crypt of Hearts II
    [UnitNames.Boss_Ibelgast] = { [1] = { id = 33097 } },                                  -- Ibelgast
    [UnitNames.Boss_Ruzozuzalpamaz] = { [1] = { id = 33097 } },                            -- Ruzozuzalpamaz
    [UnitNames.NPC_Ibelgasts_Flesh_Atronach] = { [1] = { id = 33097 } },                   -- Ibelgasts Flesh Atronach
    [UnitNames.NPC_Ogrim] = { [1] = { id = 33097, zone = { [932] = true } } },             -- Ogrim
    [UnitNames.Boss_Chamber_Guardian] = { [1] = { id = 33097, zone = { [932] = true } } }, -- Chamber Guardian
    [UnitNames.Boss_Ilambris_Amalgam] = { [1] = { id = 33097 } },                          -- Ilambris Amalgam
    [UnitNames.Boss_Mezeluth] = { [1] = { id = 33097 } },                                  -- Mezeluth
    [UnitNames.Boss_Nerieneth] = { [1] = { id = 33097 } },                                 -- Nerien'eth
    [UnitNames.NPC_Wraith] = { [1] = { id = 33097, zone = { [932] = true } } },            -- Wraith
    [UnitNames.NPC_Student] = { [1] = { id = 33097, zone = { [932] = true } } },           -- Student

    -- Volenfell
    [UnitNames.Boss_Desert_Lioness] = { [1] = { id = 33097, zone = { [22] = true } } },          -- Desert Lioness
    [UnitNames.Boss_Desert_Lion] = { [1] = { id = 33097, zone = { [22] = true } } },             -- Desert Lion
    [UnitNames.Boss_Quintus_Verres] = { [1] = { id = 33097 } },                                  -- Quintus Verres
    [UnitNames.Boss_Monstrous_Gargoyle] = { [1] = { id = 33097 } },                              -- Monstrous Gargoyle
    [UnitNames.Boss_Boilbite] = { [1] = { id = 33097 } },                                        -- Boilbite
    [UnitNames.Boss_Boilbites_Assassin_Beetle] = { [1] = { id = 33097 } },                       -- Boilbite's Assassin Beetle
    [UnitNames.Boss_Unstable_Construct] = { [1] = { id = 33097 } },                              -- Unstable Construct
    [UnitNames.Boss_Unstable_Dwarven_Spider] = { [1] = { id = 33097, zone = { [22] = true } } }, -- Unstable Dwarven Spider
    [UnitNames.Boss_Tremorscale] = { [1] = { id = 33097 } },                                     -- Tremorscale
    [UnitNames.Boss_The_Guardians_Strength] = { [1] = { id = 33097 } },                          -- The Guardian's Strength
    [UnitNames.Boss_The_Guardians_Spark] = { [1] = { id = 33097 } },                             -- The Guardian's Spark
    [UnitNames.Boss_The_Guardians_Soul] = { [1] = { id = 33097 } },                              -- The Guardian's Soul

    -- Frostvault
    [UnitNames.NPC_Coldsnap_Ogre] = { [1] = { id = 33097 } }, -- Coldsnap Ogre
    [UnitNames.Boss_Icestalker] = { [1] = { id = 33097 } },   -- Icestalker
}

--- @class (partial) AddNameAura
Effects.AddNameAura = addNameAura
