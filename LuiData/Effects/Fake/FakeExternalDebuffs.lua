-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR FAKE EFFECTS
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Fake Buffs & Debuffs - Fake auras created by EVENT_COMBAT_EVENT for abilities that lack proper auras. Note tooltips & unbreakable status are determined in Effects.EffectOverride

-- icon = '' -- Set an icon to use
-- name = '' -- Set a name to use
-- duration = # -- Set the duration of the effect (Note "GET" will pull the value from the API)
-- ignoreFade = true -- Ignore ACTION_RESULT_EFFECT_FADED
-- ignoreBegin = true -- Ignore ACTION_RESULT_BEGIN - Emulates the same functionality as refreshOnly in Effects.EffectOverride. For stopping auras from being created for travel times.
-- refreshOnly = -- Ignore ACTION_RESULT_BEGIN & ACTION_RESULT_EFFECT_GAINED
-- shiftId = # -- Shift the ability id displayed to use this id instead, for tooltip compatibility in some cases.
-- overrideDuration = true -- Set duration to display as 0, but preserve the correct duration so this effect doesn't fade improperly.
-- debuff = true -- Set this to display as a debuff
-- long = Force buff to display in the "long" container if it exists (only compatible with BUFFS)

--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- Fake Debuffs applied onto the player by NPCs or Events (Hostile)
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) FakeExternalDebuffs
local fakeExternalDebuffs =
{

    -- Necromancer
    [118242] = { duration = 1000 }, -- Beckoning Armor (Beckoning Armor)

    -- Destruction Staff
    [38946] = { duration = 1800 }, -- Stun After Knockback Movement (Destructive Reach) -- Fire

    -- Vampire
    [40349] = { duration = 23000 }, -- Feed (Blood Ritual - Rank 1)

    -- Werewolf
    [40520] = { duration = 7000 }, -- Q3047 - Knockdown (Blood Moon - Rank 1)

    -- Item Sets
    [75706] = { duration = 0 }, -- Bahraha's Curse

    -- Traps
    [27479] = { duration = 2000 }, -- Falling Rocks (Falling Rocks)
    [29602] = { duration = 2000 }, -- Falling Rocks (Cave-In)

    [31606] = { duration = 0 },    -- Fire Trap (Player)
    [72890] = { duration = 0 },    -- Laser Snare (Fire)

    [32246] = { duration = 0 },    -- Searing Steam (Steam Trap) -- Stros M'Kai

    -- [66153] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Trial of Flame', duration = 1500}, -- Trial of Flame (Wrothgar - Old Orsinium)
    -- [32246] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Steam Trap', duration = 2000}, -- Laser Snare (Steam Trap)

    -- Quest Traps
    -- TODO: Orsinium
    -- [64535] = {icon = 'esoui/art/icons/ability_wrothgar_chillingwind.dds', name = 'Chilling Wind', duration = 2000}, -- Chilling Wind (Orsinium - Sorrow's Kiss)
    -- [67586] = {icon = 'esoui/art/icons/ability_wrothgar_avalanche.dds', name = 'Avalanche', duration = 2500}, -- Avalanche (Orsinium - Sorrow's Kiss)

    -- Justice NPC's
    [63160] = { duration = 2000 },                     -- Heavy Blow Knockdown (Justice Guard)
    [63263] = { duration = 2000 },                     -- Heavy Blow Knockdown (Justice Guard)
    [63094] = { duration = 1500 },                     -- Shield Charge (Justice Guard 1H)
    [63260] = { duration = 1500 },                     -- Shield Charge (Justice Guard 2H)
    [63194] = { duration = 6000 },                     -- Flame Shard (Justice Guard 2H)
    [63168] = { duration = 3500, ignoreBegin = true }, -- Cage Talons (Justice Guard 1H + 2H)

    -- Standard NPC Abilities
    [29401] = { duration = 3000 }, -- Power Bash (NPC Disorient)
    [14926] = { duration = 2000 }, -- Charge (Human NPC)
    [10650] = { duration = 0 },    -- Oil Drenched
    [79930] = { duration = 2500 }, -- Lunge (Tracker) (Morrowind)

    -- Animals
    [69073] = { duration = 2000 },                     -- Knockdown (Bear Orsinium)
    [74336] = { duration = 2000 },                     -- Bog Burst (Haj Mota)
    [14523] = { duration = 6000, ignoreBegin = true }, -- Helljoint (Wolf)
    [85394] = { duration = 8000 },                     -- Slash (Cliff Strider Matriach)
    [55862] = { duration = 8000 },                     -- Storm Bound (Wamasu - Boss) (DOT)
    [55863] = { duration = 8000 },                     -- Storm Bound (Wamasu - Boss) (SNARE)

    -- Daedra
    [50023] = { duration = 4000, ignoreBegin = true }, -- Lightning Rod (Air Atronach)
    [51646] = { duration = 0 },                        -- Frozen Ground (Frost Atronach)
    [24700] = { duration = 2000 },                     -- Body Slam (Ogrim)
    [91851] = { duration = 2000 },                     -- Stomp (Ogrim)
    [6412] = { duration = 2000, ignoreBegin = true },  -- Dusk's Howl (Winged Twilight)

    -- Insects
    [9237] = { duration = 10000 },                    -- Larva Gestation (Giant Wasp)
    [6795] = { duration = 7500 },                     -- Latch On (Hoarvor)
    [61372] = { duration = 4000 },                    -- Infectious Swarm (Necrotic Hoarvor)
    [8429] = { duration = 4000, ignoreBegin = true }, -- Zap (Thunderbug)

    -- Monsters
    [51354] = { duration = 500 },                      -- Petrify (Gargoyle)
    [17703] = { duration = 4000, ignoreBegin = true }, -- Flame Ray (Imp - Fire)
    [8884] = { duration = 4000, ignoreBegin = true },  -- Zap (Imp - Lightning)
    [81794] = { duration = 4000, ignoreBegin = true }, -- Frost Ray (Imp - Frost)
    [95288] = { duration = 0 },                        -- Hurricane (Nereid)
    [48287] = { duration = 1500 },                     -- Consuming Omen (Troll - Ranged) (Fake aura to replace bugged aura)

    -- Undead
    [38834] = { duration = 0 },    -- Desecrated Ground Snare (Desecrated Ground)
    [22525] = { duration = 0 },    -- Defiled Ground (Lich)
    [43146] = { duration = 4000 }, -- Winter's Reach (Wraith)

    -- Traps
    [49897] = { duration = 0 }, -- Fire (Fire) -- Throne of the Wilderking
    [11338] = { duration = 0 }, -- Lava -- In Lava
    [55925] = { duration = 0 }, -- Lava (City of Ash II)

    ------------------------------
    -- Quests --------------------
    ------------------------------

    -- Main Story
    [14972] = { duration = 2000 }, -- CON_Knockback&Knockdown (Castle of the Worm)
    [44561] = { duration = 3000 }, -- FGQ4 RGT Event Knockback (Lyris Doppleganger - Halls of Torment)
    [38741] = { duration = 4000 }, -- Royal Snare (Duchess of Anguish - Halls of Torment)
    [40429] = { duration = 2000 }, -- IntroKB (Mannimarco - Shadow of Sancre Tor)
    [41198] = { duration = 2000 }, -- IntroKB (Mannimarco - Shadow of Sancre Tor)

    -- Fighter's Guild
    [39579] = { duration = 2000 }, -- CON_Knockback&Knockdown (The Prismatic Core)
    [25979] = { duration = 1000 }, -- FG4 RGT Event Knockback

    -- Mages Guild
    [31502] = { duration = 4000 }, -- MGQ2 Asakala Sahdina Barrier
    [31503] = { duration = 4000 }, -- MGQ2 Asakala Rashomta Barrier

    -- Aldmeri Dominion
    [21876] = { duration = 4500 }, -- Q4260 West Barrier Teleport (Breaking the Barrier)
    [21878] = { duration = 4500 }, -- Q4260 East Barrier Teleport (Breaking the Barrier)
    [22395] = { duration = 4000 }, -- Q4261 ROD Barrier Teleport (Sever All Ties)
    [28771] = { duration = 2000 }, -- Q4220 Thirster Stun (The Mallari-Mora)
    [23606] = { duration = 2000 }, -- Q4326 Crystal Backfire (Preventative Measure)
    [43823] = { duration = 2150 }, -- IntroKB (Prince Naemon)
    [36766] = { duration = 5000 }, -- Q4842 Stun Headgrab Knockback (The Unquiet Dead)
    [33384] = { duration = 4000 }, -- Q4586 Aranias Vine Stun

    -- Elsweyr
    [121645] = { duration = 8000 }, -- Defiled Ground (Euraxian Necromancer) (Bright Moons, Warm Sands)
    [125268] = { duration = 2500 }, -- Headbutt (Bahlokdaan)

    ----------------------------------------------------------------
    -- ORSINIUM EVENTS ---------------------------------------------
    ----------------------------------------------------------------

    --[[
    [69794] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Frozen Ground', duration = 2000}, -- Frozen Ground (Invitation to Orsinium - Olarz the Cunning)
    [53272] = {icon = 'esoui/art/icons/ability_destructionstaff_005.dds', name = 'Frost Clench', duration = 500}, -- Frost Clench (The Anger of a King - Talviah Aliaria)
    [66875] = {icon = 'esoui/art/icons/ability_debuff_stun.dds', name = 'Royal Strike', duration = 1500}, -- Royal Strike (Blood on a King's Hands)
    [65186] = {icon = 'esoui/art/icons/ability_debuff_stun.dds', name = 'The King\'s Chains', duration = 4000}, -- The King's Chains (Blood on a King's Hands)
    [67014] = {icon = 'esoui/art/icons/ability_debuff_stun.dds', name = 'Tear Down the Mountain', duration = 2000}, -- Tear Down the Mountain (Blood on a King's Hands)
    [73861] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Murky Water', duration = 0}, -- Murky Water (Blood and the Sacred Words)
    [73864] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Murky Water', duration = 3000}, -- Murky Water (Blood and the Sacred Words)
    [72128] = {icon = 'esoui/art/icons/ability_debuff_knockback.dds', name = 'Harmonic Wave Impact', duration = 2000}, -- Harmonic Wave Impact (Rkindaleft - Resonant Centurion)
    [25265] = {icon = 'esoui/art/icons/ability_debuff_knockback.dds', name = 'Decapitation Function', duration = 2000}, -- Decapitation Function (Rkindaleft - Vessel of the Auditor)
    [70316] = {icon = 'esoui/art/icons/ability_debuff_knockback.dds', name = 'Vessel Knockback', duration = 2000}, -- Q5321 Centurian Knockback (Rkindaleft - Vessel of the Auditor)
    ]]
    --

    ----------------------------------------------------------------
    -- VVARDENFELL -------------------------------------------------
    ----------------------------------------------------------------

    -- The Forgotten Wastes (Public Dungeon)
    [88030] = { duration = 1500 }, -- Falling Rocks -- Deadfall
    [87348] = { duration = 1500 }, -- Water Geyser Burst (Vvardenfell -- A Hireling of House Telvanni)
    [87350] = { duration = 2000 }, -- Water Geyser Burst (Vvardenfell -- A Hireling of House Telvanni)
    [89756] = { duration = 2000 }, -- Guardian Shockwave (Mzanchend Guardian -- Vvardenfell -- The Magister Makes a Move)

    ----------------------------------------------------------------
    -- ARENAS ----------------------------------------------------
    ----------------------------------------------------------------

    -- Dragonstar Arena
    [27920] = { duration = 1800 },  -- Generic Knockback Stun (House Dres Templar)
    [54068] = { duration = 500 },   -- Fossilize (Earthen Heart Knight)
    [54405] = { duration = 4000 },  -- Celestial Blast (Anka-Ra Shadowcaster)
    [52910] = { duration = 6000 },  -- Dark Flare Trauma (Shadow Knight)
    [56065] = { duration = 12000 }, -- Ice Charge (Dwarven Ice Centurion)
    [83477] = { duration = 4000 },  -- Volcanic Rune (Mavus Talnarith)

    -- Maelstrom Arena
    [73877] = { duration = 2000 },  -- Piercing Shriek (Lamia Queen)
    [72705] = { duration = 10000 }, -- Cold Snap (Leimenid Oracle)
    [71997] = { duration = 10000 }, -- Cold Snap (Leimenid Oracle)
    [71940] = { duration = 8000 },  -- Frost Breath (Huntsman Chillbane)
    [71720] = { duration = 2000 },  -- Stun (Matriarch Runa)

    ----------------------------------------------------------------
    -- DUNGEONS ----------------------------------------------------
    ----------------------------------------------------------------

    -- Banished Cells II
    [35680] = { duration = 2250 }, -- Immolating Bite (Maw of the Infernal)
    [27828] = { duration = 2500 }, -- Crushing Blow (Keeper Voranil)
    [28570] = { duration = 5000 }, -- Levitate (High Kinlord Rilis)
    [28462] = { duration = 5000 }, -- Levitate (High Kinlord Rilis)

    -- Elden Hollow I
    [25310] = { duration = 2500 },                     -- Executioners Strike (Akash gra-Mal)
    [25348] = { duration = 6000, refreshOnly = true }, -- Necrotic Circle (Canonreeve Oraneth)
    [46800] = { duration = 1200 },                     -- Necrotic Circle (Canonreeve Oraneth)

    -- Elden Hollow II
    [33334] = { ignoreBegin = true, duration = 7500 }, -- Latch On Stamina (Frenzied Guardian)
    [33337] = { ignoreBegin = true, duration = 7500 }, -- Latch On Magicka (Mystic Guardian)
    [33164] = { duration = 4000, ignoreBegin = true }, -- Incite Fear (Shadow Tendril)
    [35372] = { duration = 3500 },                     -- Emerge (Bogdan the Nightflame)

    -- City of Ash I
    [25036] = { duration = 2000 },  -- Crushing Blow (Golor the Banekin Handler)
    [34948] = { duration = 25000 }, -- Burning Embers (Razor Master Erthas)
    [49138] = { duration = 1500 },  -- Oblivion Portal

    -- City of Ash II
    [54139] = { duration = 3000 }, -- Blazing Embers (Marruz)
    [53978] = { duration = 3000 }, -- Blazing Arrow (Marruz)
    [54145] = { duration = 1000 }, -- Fire Chain (Rukhan)
    [54098] = { duration = 2000 }, -- CON_Knockback&Knockdown (Rukhan)
    [56813] = { duration = 2000 }, -- CON_Knockback&Knockdown (Xivilai Ravager)

    [56307] = { duration = 3000 }, -- Fiery Jaws (Horvantud the Fire Maw)
    [54873] = { duration = 2000 }, -- Heavy Slash
    [56357] = { duration = 2000 }, -- Fire Swarm (Ash Titan)
    [55502] = { duration = 1500 }, -- Meteor (Valkyn Skoria)
    [55383] = { duration = 2000 }, -- Flame Strike (Valkyn Skoria)
    [55756] = { duration = 7500 }, -- Burning (Fire Stab)

    -- Tempest Island
    [26676] = { duration = 2000 }, -- IntroKB (Valaran Stormcaller)
    [28391] = { duration = 2500 }, -- Q4538 Stoen Explosion (Conduit Stone)
    [26716] = { duration = 2800 }, -- Skyward Slam (Stormfist)
    [26938] = { duration = 0 },    -- Enervating Stone (Stormfist)

    -- Selene's Web
    [31247] = { duration = 4000 }, -- Ensnare
    [31248] = { duration = 8000 }, -- Ensnare
    [30905] = { duration = 2000 }, -- IntroKB (Spectral Senche-Tiger)

    -- Spindleclutch I
    [18116] = { duration = 3500 }, -- Arachnophobia (The Whisperer)
    [46219] = { duration = 2500 }, -- Web Blast (The Whisperer)

    -- Spindleclutch II
    [18054] = { duration = 8000 }, -- Entangled (The Whisperer Nightmare)
    [18051] = { duration = 2000 }, -- Encased (The Whisperer Nightmare)
    [43176] = { duration = 1200 }, -- Shocked (Blood Essence)
    [61444] = { duration = 1200 }, -- Shocked (Blood Essence)
    [32100] = { duration = 3500 }, -- Arachnophobia (Vorenor Winterbourne)

    -- Wayrest Sewers I
    [34848] = { duration = 2000 }, -- Primal Sweep (Slimecraw)
    [25531] = { duration = 2000 }, -- Tidal Slash (Varaine Pellingare)

    -- Wayrest Sewers II
    [36431] = { duration = 10000 }, -- Rend Soul (Malubeth the Scourger)
    [36870] = { duration = 5000 },  -- Scorching Flames (Uulgarg the Risen)
    [36900] = { duration = 35000 }, -- Haunting Spectre (The Forgotten One)
    [36535] = { duration = 2000 },  -- Spinning Cleave (Varaine Pellingare)
    [36398] = { duration = 2500 },  -- Bludgeon (Varaine Pellingare)
    [35839] = { duration = 12000 }, -- Necrotic Arrow (Allene Pellingare)

    -- Crypt of Hearts I
    [46692] = { duration = 2500 }, -- CON_Knockback&Knockdown (Ilambris-Athor)
    [44088] = { duration = 2000 }, -- CON_Knockback&Knockdown (Ilambris-Zaven)

    -- Crypt of Hearts II
    [53598] = { duration = 2000 }, -- Shock Form (Ilambris Amalgam)
    [53591] = { duration = 2000 }, -- CON_Knockback&Knockdown (Ilambris Amalgam)
    [51111] = { duration = 5000 }, -- Rise and Fall (Mezeluth)
    [51824] = { duration = 2500 }, -- Fulminating Void (Mezeluth)
    [53442] = { duration = 6000 }, -- Lethal Stab (Nerien'eth)
    [51995] = { duration = 2250 }, -- Heavy Slash (Nerien'eth)

    -- Volenfell
    [25649] = { duration = 4000, ignoreBegin = true }, -- Debilitating Roar (Desert Lion)
    [46314] = { duration = 2500 },                     -- CON_Knockback&Knockdown (Monstrous Gargoyle)
    [42930] = { duration = 6000 },                     -- Petrifying Bellow (Monstrous Gargoyle)
    [29166] = { duration = 2000 },                     -- CON_Knockback&Knockdown (Tremorscale)
    [25265] = { duration = 2000 },                     -- Decapitation Function (The Guardian's Soul)

    -- Frostvault
    [117486] = { duration = 18000 }, -- Bleed (Coldsnap Goblin - Shared)
    [109808] = { duration = 0 },     -- Frostbite (Icestalker)
}

--- @class (partial) FakeExternalDebuffs
Effects.FakeExternalDebuffs = fakeExternalDebuffs
