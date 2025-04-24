-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

local ACTION_RESULT_STAGGERED = ACTION_RESULT_STAGGERED
local ACTION_RESULT_STUNNED = ACTION_RESULT_STUNNED
local ACTION_RESULT_KNOCKBACK = ACTION_RESULT_KNOCKBACK
local ACTION_RESULT_LEVITATED = ACTION_RESULT_LEVITATED
local ACTION_RESULT_FEARED = ACTION_RESULT_FEARED
local ACTION_RESULT_DISORIENTED = ACTION_RESULT_DISORIENTED
local ACTION_RESULT_CHARMED = ACTION_RESULT_CHARMED

--- @class (partial) CastBarTable
local castBarTable =
{
    --------------------------------------------------------------------------------------------------------------------------------
    -- Id's for Heavy Attacks to ignore if the menu setting is off
    --------------------------------------------------------------------------------------------------------------------------------
    IsHeavy =
    {
        -- Weapon Attacks
        [15279] = true, -- One Handed
        [16420] = true, -- Dual Wield
        [16041] = true, -- Two Handed
        [16691] = true, -- Bow
        [16212] = true, -- Restoration
        [15383] = true, -- Inferno
        [16261] = true, -- Ice
        [18396] = true, -- Lightning
        [18429] = true, -- Unarmed
    },

    --------------------------------------------------------------------------------------------------------------------------------
    -- When a hard CC effect is successfully applied to the player, instantly stop any in progress Casts
    --------------------------------------------------------------------------------------------------------------------------------
    CastBreakingStatus =
    {
        [ACTION_RESULT_STAGGERED] = true,
        [ACTION_RESULT_STUNNED] = true,
        [ACTION_RESULT_KNOCKBACK] = true,
        [ACTION_RESULT_LEVITATED] = true,
        [ACTION_RESULT_FEARED] = true,
        [ACTION_RESULT_DISORIENTED] = true,
        [ACTION_RESULT_CHARMED] = true,
    },

    --------------------------------------------------------------------------------------------------------------------------------
    -- List of abilityId's that should immediately cancel the Cast Bar if detected
    --------------------------------------------------------------------------------------------------------------------------------
    CastBreakingActions =
    {
        [28549] = true, -- Roll Dodge
        [55146] = true, -- Interrupt Bonus (when player bashes it can interrupt a channel - note that it won't successfully go off until after the cast if it can't be stopped by bashing so this is safe to apply to everything)
    },

    -- Used to break Siege Weapon deployment/stoy when the player opens their inventory or another window or tabs out of the game.
    BreakSiegeOnWindowOpen =
    {

        [29673] = true,  -- Create Ballista Bolt... (Ballista)
        [29672] = true,  -- Create Ballista Bolt... (Ballista)
        [29671] = true,  -- Create Ballista Bolt... (Ballista)

        [30611] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)
        [30607] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)
        [16751] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)

        [30612] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)
        [30608] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)
        [16752] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)

        [39914] = true,  -- Create Trebuchet... (Stone Trebuchet)
        [39917] = true,  -- Create Trebuchet... (Stone Trebuchet)
        [39910] = true,  -- Create Trebuchet... (Stone Trebuchet)

        [39913] = true,  -- Create Trebuchet... (Iceball Trebuchet)
        [39916] = true,  -- Create Trebuchet... (Iceball Trebuchet)
        [39909] = true,  -- Create Trebuchet... (Iceball Trebuchet)

        [13665] = true,  -- Create Trebuchet... (Firepot Trebuchet)
        [13664] = true,  -- Create Trebuchet... (Firepot Trebuchet)
        [13663] = true,  -- Create Trebuchet... (Firepot Trebuchet)

        [30613] = true,  -- Create Catapult Meatbag (Meatbag Catapult)
        [30609] = true,  -- Create Catapult Meatbag (Meatbag Catapult)
        [16755] = true,  -- Create Catapult Meatbag (Meatbag Catapult)

        [30614] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
        [30610] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
        [16754] = true,  -- Create Catapult Oil Jar... (Oil Catapult)

        [39915] = true,  -- Create Catapult Meatbag (Scattershot Catapult)
        [39918] = true,  -- Create Catapult Oil Jar... (Scattershot Catapult)
        [39911] = true,  -- Create Trebuchet... (Scattershot Catapult)

        [66438] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
        [66439] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
        [66440] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)

        [66434] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
        [66388] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
        [66387] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)

        [66437] = true,  -- Create Ballista... (Cold Fire Ballista)
        [66436] = true,  -- Create Ballista... (Cold Fire Ballista)
        [66435] = true,  -- Create Ballista... (Cold Fire Ballista)

        [135862] = true, -- Create Lance Cannon... (Shock Lancer)
        [135861] = true, -- Create Lance Cannon... (Shock Lancer)
        [135860] = true, -- Create Lance Cannon... (Shock Lancer)

        [135859] = true, -- Create Lance Cannon... (Fire Lancer)
        [135858] = true, -- Create Lance Cannon... (Fire Lancer)
        [135836] = true, -- Create Lance Cannon... (Fire Lancer)

        [135868] = true, -- Create Lance Cannon... (Frost Lancer)
        [135867] = true, -- Create Lance Cannon... (Frost Lancer)
        [135866] = true, -- Create Lance Cannon... (Frost Lancer)

        [22570] = true,  -- Create Boiling Oil... (Flaming Oil)
        [15876] = true,  -- Create Large Ram... (Battering Ram)
        [16171] = true,  -- Create Large Ram... (Battering Ram)
        [16170] = true,  -- Create Large Ram... (Battering Ram)

        [19039] = true,  -- Ebonheart Forward Camp
        [19040] = true,  -- Aldmeri Forward Camp
        [19041] = true,  -- Daggerfall Forward Camp
    },

    BreakCastOnMove =
    {
        -- Fake
        -- [999999] = true, -- Used for any interact based casts

        -- Innate
        [6811] = true,  -- Recall
        [69293] = true, -- Sigil of Imperial Retreat

        -- Customized Actions - Recalling
        [209299] = true, -- Accursed Recall
        [187552] = true, -- Bitter Coast Recall
        [215092] = true, -- Coldharbour Recall
        [200161] = true, -- Frostfall Recall
        [215089] = true, -- Gold Road Recall
        [191859] = true, -- Legionnaire's Recall
        [199791] = true, -- Recall of the Crusader
        [181388] = true, -- Recall of the Galen Wilds
        [221093] = true, -- Recall of the Outer Darkness

        -- Misc Items
        [63427] = true, -- Clean Fish (Filet Fish)
        [78052] = true, -- Minor Pardon (Counterfeit Pardon Edict)
        [76350] = true, -- Moderate Pardon (Leniency Edict)
        [76349] = true, -- Full Pardon (Grand Amnesty Edict)

        -- Mementos
        [42008] = true, -- Blessing of Root Sunder (Token of Root Sunder)
        [42053] = true, -- Yokudan Salute (Yokudan Totem)
        [42105] = true, -- Nanwen's Sword (Nanwen's Sword)
        [42076] = true, -- Tear (Mezha-dro's Sealing Amulet)
        [41988] = true, -- Bonesnap Binding Stone (Bonesnap Binding Stone)
        [41948] = true, -- Glanir's Smoke Bomb (Glanir's Smoke Bomb)
        [25369] = true, -- Sanguine's Goblet (Sanguine's Goblet)

        -- Werewolf
        [40515] = true, -- Devour (Werewolf - Bite Player)

        ----------------------------------------------------------------
        -- CYRODIIL ----------------------------------------------------
        ----------------------------------------------------------------

        [12256] = true,  -- Pack Siege (Siege Weapons)

        [29673] = true,  -- Create Ballista Bolt... (Ballista)
        [29672] = true,  -- Create Ballista Bolt... (Ballista)
        [29671] = true,  -- Create Ballista Bolt... (Ballista)

        [30611] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)
        [30607] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)
        [16751] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)

        [30612] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)
        [30608] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)
        [16752] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)

        [39914] = true,  -- Create Trebuchet... (Stone Trebuchet)
        [39917] = true,  -- Create Trebuchet... (Stone Trebuchet)
        [39910] = true,  -- Create Trebuchet... (Stone Trebuchet)

        [39913] = true,  -- Create Trebuchet... (Iceball Trebuchet)
        [39916] = true,  -- Create Trebuchet... (Iceball Trebuchet)
        [39909] = true,  -- Create Trebuchet... (Iceball Trebuchet)

        [13665] = true,  -- Create Trebuchet... (Firepot Trebuchet)
        [13664] = true,  -- Create Trebuchet... (Firepot Trebuchet)
        [13663] = true,  -- Create Trebuchet... (Firepot Trebuchet)

        [30613] = true,  -- Create Catapult Meatbag (Meatbag Catapult)
        [30609] = true,  -- Create Catapult Meatbag (Meatbag Catapult)
        [16755] = true,  -- Create Catapult Meatbag (Meatbag Catapult)

        [30614] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
        [30610] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
        [16754] = true,  -- Create Catapult Oil Jar... (Oil Catapult)

        [39915] = true,  -- Create Catapult Meatbag (Scattershot Catapult)
        [39918] = true,  -- Create Catapult Oil Jar... (Scattershot Catapult)
        [39911] = true,  -- Create Trebuchet... (Scattershot Catapult)

        [66438] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
        [66439] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
        [66440] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)

        [66434] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
        [66388] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
        [66387] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)

        [66437] = true,  -- Create Ballista... (Cold Fire Ballista)
        [66436] = true,  -- Create Ballista... (Cold Fire Ballista)
        [66435] = true,  -- Create Ballista... (Cold Fire Ballista)

        [135862] = true, -- Create Lance Cannon... (Shock Lancer)
        [135861] = true, -- Create Lance Cannon... (Shock Lancer)
        [135860] = true, -- Create Lance Cannon... (Shock Lancer)

        [135859] = true, -- Create Lance Cannon... (Fire Lancer)
        [135858] = true, -- Create Lance Cannon... (Fire Lancer)
        [135836] = true, -- Create Lance Cannon... (Fire Lancer)

        [135868] = true, -- Create Lance Cannon... (Frost Lancer)
        [135867] = true, -- Create Lance Cannon... (Frost Lancer)
        [135866] = true, -- Create Lance Cannon... (Frost Lancer)

        [22570] = true,  -- Create Boiling Oil... (Flaming Oil)
        [15876] = true,  -- Create Large Ram... (Battering Ram)
        [16171] = true,  -- Create Large Ram... (Battering Ram)
        [16170] = true,  -- Create Large Ram... (Battering Ram)

        [13853] = true,  -- Wall Repair Kit
        [16723] = true,  -- Door Repair Kit
        [13601] = true,  -- Advanced Siege Repair Kit
        [112975] = true, -- Wall Repair Kit (Bridge and Milegate Repair Kit)

        [19039] = true,  -- Ebonheart Forward Camp
        [19040] = true,  -- Aldmeri Forward Camp
        [19041] = true,  -- Daggerfall Forward Camp

        -- [12355] = true, -- Destroy Siege Weapon (Doesn't show up due to Cyrodiil Limitations)

        -- Siege Warfare
        [33348] = true, -- Practice Siege Repair Kit (Practice Siege Repair Kit)

        ----------------------------------------------------------------
        -- QUESTS ------------------------------------------------------
        ----------------------------------------------------------------

        -- Aldmeri Quests
        [21364] = true, -- Casting... (The Serpent's Beacon)
        [21409] = true, -- Reading... (The Serpent's Beacon)
        [21393] = true, -- Q4220 PC Chooses to Rescue
        [22931] = true, -- Freeing Spirit... (An Act of Kindness)
        [21968] = true, -- Binding Bear... (Silent Village)
    },

    IgnoreCastBreakingActions =
    {
        [86792] = true, -- Eating (High Hrothgar Festival Mints)
        [43700] = true, -- Wand of Finding (Lena's Wand of Finding)
        [81575] = true, -- Event - WitchFest Cauldron (Witchmother's Whistle)
        -- [21112] = true, -- Q4220 PC Forced to L0

        [113432] = true, -- 68235 Stun (Nascent Indrik)
        [148079] = true, -- 68235 Stun (Unstable Morpholith)
    },

    --------------------------------------------------------------------------------------------------------------------------------
    --  List of abilities flagged for CombatInfo to show as a Channel on the Cast Bar
    --------------------------------------------------------------------------------------------------------------------------------
    CastChannelOverride =
    {
        ----------------------------------------------------------------
        -- PLAYER ABILITIES --------------------------------------------
        ----------------------------------------------------------------

        -- Innate
        [32346] = true,  -- Skyshard Collect
        [151928] = true, -- Aetherial Well (Aetherial Well)
        [47270] = true,  -- Ritual of Mara
        [14031] = true,  -- Mundus Use
        [4197] = true,   -- Recovering (NPC Duel)

        -- Seasonal Mementos & Items
        [85355] = true,  -- Flame Juggling (Consumable Version)
        [85354] = true,  -- Dagger Juggling (Consumable Verison)
        [85353] = true,  -- Sword Swallowing (Consumable Version)
        [146657] = true, -- Memento Cliff Racer (Thetys Ramary's Bait Kit)

        [115681] = true, -- Party Noise Maker (Festive Noise Maker)
        [129550] = true, -- Stunned (Jester's Festival Joke Popper)
        [149874] = true, -- Playful Prankster's Surprise Box (Playful Prankster's Surprise Box)
        [102077] = true, -- Jester's Festival Scintillator (Jester's Scintillator)
        [111458] = true, -- Apple-Bobbing Cauldron (Apple-Bobbing Cauldron)
        [111459] = true, -- Apple-Bobbing Cauldron (Apple-Bobbing Cauldron)
        [125820] = true, -- Witches Festival 2019 Marionette (Skeletal Marionette)
        [144790] = true, -- Throw Bones (Throwing Bones)
        [144791] = true, -- Throw Bones (Throwing Bones)

        -- Memento (Crown)
        [85347] = true,  -- Storm Orb Juggle (Atronach Juggling)
        [97273] = true,  -- TROPHY Death Crate Mem 1 (Crow's Calling)
        [99318] = true,  -- TROPHY Flame Crate Mem 1 (Fiery Orb)
        [99319] = true,  -- Flame Crate Memento 2 (Flame Pixie)
        [101874] = true, -- _CRWN Dragon Priest Mem2 Ice T (Scalecaller Frost Shard)
        [101877] = true, -- _CRWN Dragon Priest Mem1 Fl/St (Scalecaller Rune of Levitation)
        [101872] = true, -- _CRWN Dragon Priest Memento3 (Bone Dragon Summons Focus)
        [104324] = true, -- Psijic Pearl Summon (Psijic Celestial Orb)
        [104323] = true, -- Psijic Hourglass (Psijic Tautology Glass)
        [104325] = true, -- Psijic Disintegrate (Sapiarchic Discorporation Lens)
        [110482] = true, -- Rind-Renewing Pumpkin (Rind-Renewing Pumpkin)
        [116543] = true, -- Gourd-Gallows Stump (Gourd-Gallows Stump)
        [110481] = true, -- Gourd-Gallows Stump (Gourd-Gallows Stump)
        [113288] = true, -- U20 Crown Memento 1 (Mire Drum)
        [113291] = true, --  U20 Crown Memento 2 (Vossa-satl)
        [151489] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [151490] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [151491] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [146752] = true, -- Phial of Clockwork Lubricant (Phial of Clockwork Lubricant)

        -- Memento (Base)
        [43700] = true, -- Wand of Finding (Lena's Wand of Finding)
        [42076] = true, -- Tear (Mezha-dro's Sealing Amulet)
        [34578] = true, -- Nirnroot Wine (Nirnroot Wine)
        [42053] = true, -- Yokudan Salute (Yokudan Totem)

        -- Memento (DLC)
        [143495] = true, -- Reliquary of Dark Designs (Reliquary of Dark Designs)
        [89550] = true,  -- TROPHY Azura's Light (Twilight Shard)
        [79510] = true,  -- TROPHY Blood Oath (Blade of the Blood Oath)
        [119099] = true, -- Brittle Burial Urn (Brittle Burial Urn)
        [125816] = true, -- Maarselok Corruption Memento (Corruption of Maarselok)
        [137919] = true, -- Juggling Potion Bottles (Mostly Stable Juggling Potions)
        [147598] = true, --  Void Shard (Void Shard)
        [149881] = true, -- Illusory Salamander Stone (Illusory Salamander Stone)
        [153758] = true, -- Golden Anvil Replica (Full-Scale Golden Anvil Replica)
        [146744] = true, -- Temperamental Grimoire (Temperamental Grimoire)
        [153760] = true, -- Wilting Weed Killer Phial (Wilting Weed Killer Phial)
        [125817] = true, -- U24 Teaser Dragon Horn (Dragonhorn Curio)

        -- Vampire
        [40350] = true, -- Feed (Vampire - Bite Player)

        -- Werewolf
        [40515] = true, -- Devour (Werewolf - Bite Player)

        ----------------------------------------------------------------
        -- QUEST ABILITIES ---------------------------------------------
        ----------------------------------------------------------------

        -- Vampire Quest
        [39507] = true, -- VampInitStun_Profane (Scion of the Blood Matron)

        -- MSQ
        [39367] = true, -- Altar Use (Shadow of Sancre Tor)
        [36421] = true, -- Drink with Lyris (Council of the Five Companions)

        -- Aldmeri Dominion Quests
        [35192] = true, -- Q4620 Use Lodestone (Cast Adrift)
        [34567] = true, -- Q4621 PC Storm Drain (The Tempest Unleashed)
        [34701] = true, -- Q4621 Destory Horn (The Tempest Unleashed)
        [23540] = true, -- Teleport (Lifting the Veil)
        [46762] = true, -- Drinking Contest (The Great Tree)
        [21364] = true, -- Casting... (The Serpent's Beacon)
        [22889] = true, -- Purifying... (Corruption Stones)
        [21968] = true, -- Binding Bear... (Silent Village)
        [22931] = true, -- Freeing Spirit... (An Act of Kindness)
        [23187] = true, -- Q4236 PC Untie Palith (The Veiled Choice)
        [47301] = true, -- Stunned (Passage Denied)
        [36710] = true, -- Q4833 Apply Snake Buff (Bosmer Insight)
        [36841] = true, -- Q4833 Apply Wolf Buff (Bosmer Insight)
        [36824] = true, -- Q4833 Apply Tiger Buff (Bosmer Insight)
        [37062] = true, -- Exorcise (The Unquiet Dead)
        [36996] = true, -- Bind Spirit (The Unquiet Dead)
        [37205] = true, -- Animus Geode (Eyes of Azura)
        [37211] = true, -- Q4854 Empower Heart (Eyes of Azura)
        [38246] = true, -- Animus Geode (Eyes of Azura)
        [34499] = true, -- Corruption Beam (The Blight of the Bosmer)

        -- Daggerfall Covenant Quests
        [79989] = true, -- Mercy Kill (Like Moths to a Candle)

        ----------------------------------------------------------------
        -- SEASONAL QUEST ----------------------------------------------
        ----------------------------------------------------------------

        -- New Life Festival
        [84847] = true, -- Celebratory Belch (Stonetooth Bash)
        [84125] = true, -- Breton Male Dance (Lava Foot Stomp)
        [84126] = true, -- Breton Female Dance (Lava Foot Stomp)
        [84127] = true, -- Dunmer Male Dance (Lava Foot Stomp)
        [84128] = true, -- Dunmer Female Dance (Lava Foot Stomp)
        [84130] = true, -- Altmer Male Dance (Lava Foot Stomp)
        [84131] = true, -- Altmer Female Dance (Lava Foot Stomp)
        [84133] = true, -- Nord Dance (Lava Foot Stomp)
        [84528] = true, -- Flame Juggling (Castle Charm Challenge)
        [84506] = true, -- Dagger Juggling (Castle Charm Challenge)
        [84533] = true, -- Sword Swallowing (Castle Charm Challenge)
    },

    --------------------------------------------------------------------------------------------------------------------------------
    --  Duration update for any effects that are converted to casts (A lot of stun effects in PVE Quests with casting animations)
    --------------------------------------------------------------------------------------------------------------------------------
    CastDurationFix =
    {
        ----------------------------------------------------------------
        -- PLAYER ABILITIES --------------------------------------------
        ----------------------------------------------------------------

        -- Necromancer
        [115478] = 1200, -- Bone Goliath Self Snare (Bone Goliath Transformation)
        [118673] = 1200, -- Pummeling Goliath Self Snare (Pummeling Goliath)
        [118287] = 1200, -- Ravenous Goliath Self Snare (Ravenous Goliath)

        -- Innate
        [37059] = 1165,  -- Mount Up (Mount)
        [141013] = 1165, -- Mount Up (Passenger Mount)
        [14644] = 4000,  -- Revive (Death Dialogue)
        [32346] = 5800,  -- Skyshard Collect
        [151928] = 3000, -- Aetherial Well (Aetherial Well)
        [47270] = 5600,  -- Ritual of Mara
        [14031] = 5000,  -- Mundus Use
        [4197] = 4000,   -- Recovering (NPC Duel)

        -- Misc Items
        [206063] = 11000, -- CreateAttunableStation (Attunable Crafting Station)
        [113432] = 8000,  -- 68235 Stun (Nascent Indrik)
        [130394] = 5000,  -- 68235 Stun (Spectral Indrik)
        [131536] = 5000,  -- Generic Stun & Combine (Sovereign Sow)
        [151843] = 5000,  -- 68235 Stun (Deadlands Firewalker)
        [148079] = 8000,  -- 68235 Stun (Unstable Morpholith)

        [68259] = 5000,   -- 68235 Stun (Psijic Ambrosia Recipe, Fragment I)
        [68263] = 5000,   -- 68235 Stun (Psijic Ambrosia Recipe, Fragment II)
        [68267] = 5000,   -- 68235 Stun (Psijic Ambrosia Recipe, Fragment III)
        [68271] = 5000,   -- 68235 Stun (Psijic Ambrosia Recipe, Fragment IV)
        [68275] = 5000,   -- 68235 Stun (Psijic Ambrosia Recipe, Fragment V)
        [68279] = 5000,   -- 68235 Stun (Psijic Ambrosia Recipe, Fragment VI)
        [68283] = 5000,   -- 68235 Stun (Psijic Ambrosia Recipe, Fragment VII)
        [70584] = 5000,   -- 68235 Stun (Merethic Restorative Resin)
        [88451] = 5000,   -- 88449 Stun (Aetheric Cipher)
        [110890] = 5000,  -- 68235 Stun (Welkynar Binding)

        [147795] = 5000,  -- 88449 Stun (Chef Arquitius's Torte Dissertation)
        [147850] = 5000,  -- 88449 Stun (Chef Arquitius's Lost Thesis)
        [148052] = 5000,  -- 68235 Stun (Breton Terrier Mammoth Bone)
        [123110] = 5000,  -- 68235 Stun (Mummified Alfiq Parts)
        [123115] = 5000,  -- 68235 Stun (Plague-Drenched Fabric)
        [140544] = 5000,  -- 68235 Stun (Stone Husk Fragment)

        [111141] = 5000,  -- 68235 Stun (Swamp Jelly Carrying Jar)
        [111129] = 5000,  -- 68235 Stun (Swamp Jelly Fine-Mesh Net)
        [111153] = 5000,  -- 68235 Stun (Swamp Jelly Hunter's Lense)
        [111133] = 5000,  -- 68235 Stun (Swamp Jelly Luminous Fishmeal)
        [111137] = 5000,  -- 68235 Stun (Swamp Jelly Luring Flute)
        [111149] = 5000,  -- 68235 Stun (Swamp Jelly Moss Bedding)
        [111145] = 5000,  -- 68235 Stun (Swamp Jelly Spawning Mud)

        [117532] = 5000,  -- 68235 Stun (Guar Stomp Elucidating Hand-Sculpture)
        [117558] = 5000,  -- 68235 Stun (Guar Stomp History in Street Theatre)
        [117554] = 5000,  -- 68235 Stun (Guar Stomp Illustrated Reports)
        [117550] = 5000,  -- 68235 Stun (Guar Stomp Noise Reports)
        [117545] = 5000,  -- 68235 Stun (Guar Stomp Rehearsal Tuning Fork)
        [117562] = 5000,  -- 68235 Stun (Guar Stomp Skeletal Reconstruction)
        [117541] = 5000,  -- 68235 Stun (Guar Stomp Steps-Practice Rug)

        -- TODO: Big-Eared Ginger Kitten Casts replaced - check later

        -- TODO: Psijic Glowglobe Casts replaced - check later

        -- TODO: Sixth House Robe Casts replaced - check later

        -- TODO: Dwarven Theodolite Casts replaced - check later

        [111190] = 5000, -- 68235 Stun (Arena Gladiator's Exultation)
        [115064] = 5000, -- 68235 Stun (Arena Gladiator's Mockery)
        [106174] = 5000, -- 68235 Stun (Arena Gladiator's Recognition)
        [116416] = 5000, -- 68235 Stun (Arena Gladiator's Roar)
        [134883] = 5000, -- 68235 Stun (Knight's Rebuke)
        [134851] = 5000, -- 68235 Stun (Knight's Resolve)
        [140622] = 5000, -- 68235 Stun (Reach-Mage's Ferocity)
        [145216] = true, -- 68235 Stun (Siege of Cyrodiil Distinction)
        [124789] = 5000, -- 68235 Stun (Siege of Cyrodiil Recognition)
        [126710] = 5000, -- 68235 Stun (Siege of Cyrodiil Recommendation)
        [124624] = 5000, -- 68235 Stun (Alliance Standard-Bearer's License)
        [148421] = 5000, -- 68235 Stun (Siege of Cyrodiil Commendation)

        -- Seasonal Mementos and Items
        [86792] = 3000,   -- Eating (High Hrothgar Festival Mints)
        [86739] = 3000,   -- Drinking (Sailor's Warning Festival Grog)
        [85355] = 12000,  -- Flame Juggling (Consumable Version)
        [85354] = 12000,  -- Dagger Juggling (Consumable Verison)
        [85353] = 12000,  -- Sword Swallowing (Consumable Version)
        [146657] = 19000, -- Memento Cliff Racer (Thetys Ramary's Bait Kit)

        [115681] = 3250,  -- Party Noise Maker (Festive Noise Maker)
        [129550] = 6540,  -- Stunned (Jester's Festival Joke Popper)
        [149874] = 10000, -- Playful Prankster's Surprise Box (Playful Prankster's Surprise Box)
        [102077] = 2000,  -- Jester's Festival Scintillator (Jester's Scintillator)
        [81575] = 2000,   -- Event - WitchFest Cauldron (Witchmother's Whistle)
        [111458] = 9000,  -- Apple-Bobbing Cauldron (Apple-Bobbing Cauldron)
        [111459] = 9000,  -- Apple-Bobbing Cauldron (Apple-Bobbing Cauldron)
        [125820] = 7500,  -- Witches Festival 2019 Marionette (Skeletal Marionette)
        [144790] = 13000, -- Throw Bones (Throwing Bones)
        [144791] = 13000, -- Throw Bones (Throwing Bones)

        -- Memento (Crown)
        [85347] = 12000,  -- Storm Orb Juggle (Atronach Juggling)
        [97273] = 9000,   -- TROPHY Death Crate Mem 1 (Crow's Calling)
        [99318] = 9000,   -- TROPHY Flame Crate Mem 1 (Fiery Orb)
        [99319] = 8000,   -- Flame Crate Memento 2 (Flame Pixie)
        [99320] = 2000,   -- TROPHY Flame Crate Mem 3 (Flame Eruption)
        [101874] = 10000, -- _CRWN Dragon Priest Mem2 Ice T (Scalecaller Frost Shard)
        [101877] = 9000,  -- _CRWN Dragon Priest Mem1 Fl/St (Scalecaller Rune of Levitation)
        [101872] = 5000,  -- _CRWN Dragon Priest Memento3 (Bone Dragon Summons Focus)
        [104324] = 7500,  -- Psijic Pearl Summon (Psijic Celestial Orb)
        [104323] = 6000,  -- Psijic Hourglass (Psijic Tautology Glass)
        [104325] = 6500,  -- Psijic Disintegrate (Sapiarchic Discorporation Lens)
        [110482] = 9000,  -- Rind-Renewing Pumpkin (Rind-Renewing Pumpkin)
        [116543] = 1500,  -- Gourd-Gallows Stump (Gourd-Gallows Stump)
        [110481] = 1500,  -- Gourd-Gallows Stump (Gourd-Gallows Stump)
        [113288] = 10000, -- U20 Crown Memento 1 (Mire Drum)
        [113291] = 13000, --  U20 Crown Memento 2 (Vossa-satl)
        [151489] = 21000, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [151490] = 21000, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [151491] = 21000, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [146752] = 15000, -- Phial of Clockwork Lubricant (Phial of Clockwork Lubricant)

        -- Memento (Base)
        [42076] = 8000,  -- Tear (Mezha-dro's Sealing Amulet)
        [34578] = 8000,  -- Nirnroot Wine (Nirnroot Wine)
        [42053] = 10000, -- Yokudan Salute (Yokudan Totem)

        -- Memento (DLC)
        [143495] = 7000,  -- Reliquary of Dark Designs (Reliquary of Dark Designs)
        [89550] = 9000,   -- TROPHY Azura's Light (Twilight Shard)
        [79510] = 6500,   -- TROPHY Blood Oath (Blade of the Blood Oath)
        [74151] = 2500,   -- Stun (Hidden Pressure Vent)
        [92862] = 4500,   -- Ringing Bell (Dreamer's Chime)
        [119099] = 4000,  -- Brittle Burial Urn (Brittle Burial Urn)
        [125816] = 10000, -- Maarselok Corruption Memento (Corruption of Maarselok)
        [136120] = 4000,  -- Ritual Circle Totem (Ritual Circle Totem)
        [137919] = 8000,  -- Juggling Potion Bottles (Mostly Stable Juggling Potions)
        [147598] = 15250, --  Void Shard (Void Shard)
        [149881] = 8000,  -- Illusory Salamander Stone (Illusory Salamander Stone)
        [153758] = 11500, -- Golden Anvil Replica (Full-Scale Golden Anvil Replica)
        [146744] = 12000, -- Temperamental Grimoire (Temperamental Grimoire)
        [153760] = 10000, -- Wilting Weed Killer Phial (Wilting Weed Killer Phial)
        [149879] = 3500,  -- Daedric Unwarding Amulet (Daedric Unwarding Amulet)
        [125817] = 5000,  -- U24 Teaser Dragon Horn (Dragonhorn Curio)

        -- Vampire
        [40350] = 22500, -- Feed (Vampire - Bite Player)

        [138565] = 1200, -- Blood Scion (Vampire)
        [138568] = 1200, -- Blood Scion (Vampire)
        [138614] = 1200, -- Swarming Scion (Vampire)
        [138615] = 1200, -- Swarming Scion (Vampire)
        [138618] = 1200, -- Perfect Scion (Vampire)
        [138619] = 1200, -- Perfect Scion (Vampire)

        -- Werewolf
        [33208] = 3000, -- Devour (Werewolf)
        [39033] = 1100, -- Werewolf Transform Setup (Werewolf)
        [39477] = 1500, -- De-Werewolf (Werewolf)
        [75008] = 6500, -- Werewolf Transformation (Werewolf - Quest Transformation)

        ----------------------------------------------------------------
        -- QUEST ABILITIES ---------------------------------------------
        ----------------------------------------------------------------

        -- Vampire Quest
        [39507] = 23000, -- VampInitStun_Profane (Scion of the Blood Matron)

        -- Main Story Quest
        [39367] = 10000, -- Altar Use (Shadow of Sancre Tor)
        [36421] = 3000,  -- Drink with Lyris (Council of the Five Companions)

        -- Aldmeri Dominion Quests
        [33233] = 2000, -- 4625 Stun for Beckon 1.5s (Tears of the Two Moons)
        [34701] = 1950, -- Q4621 Destory Horn (The Tempest Unleashed)
        [23540] = 3000, -- Teleport (Lifting the Veil)
        [46762] = 4500, -- Drinking Contest (The Great Tree)
        [22448] = 3000, -- Q4266 Tie up Hendil (The First Patient)
        [21393] = 2500, -- Q4220 PC Chooses to Rescue (The Mallari-Mora)
        -- [21112] = 1500, -- Q4220 PC Forced to L0
        [22271] = 3000, -- Teleport Scroll AB (Depths of Madness)
        [23187] = 2000, -- Q4236 PC Untie Palith (The Veiled Choice)
        [47301] = 3000, -- Stunned (Passage Denied)
        [40504] = 3500, -- Q4922 Use Mantle on Device (The Orrery of Elden Root)
        [40557] = 3500, -- (12127) CFX_4922 Mantle Cast S (The Orrery of Elden Root)
        [36710] = 4000, -- Q4833 Apply Snake Buff (Bosmer Insight)
        [36841] = 4000, -- Q4833 Apply Wolf Buff (Bosmer Insight)
        [36824] = 4000, -- Q4833 Apply Tiger Buff (Bosmer Insight)
        [33701] = 1000, -- BurrowEND (Throne of the Wilderking)
        [33727] = 500,  -- BurrowEND (Throne of the Wilderking)
        [34499] = 3000, -- Corruption Beam (The Blight of the Bosmer)

        -- Daggerfall Covenant Quests
        [79989] = 3000, -- Mercy Kill (Like Moths to a Candle)

        -- Elsweyr Quests
        [119292] = 2000, -- Stun (Bright Moons, Warm Sands)

        ----------------------------------------------------------------
        -- SEASONAL QUEST ----------------------------------------------
        ----------------------------------------------------------------

        -- New Life Festival
        [84847] = 5000,  -- Celebratory Belch (Stonetooth Bash)
        [84125] = 10000, -- Breton Male Dance (Lava Foot Stomp)
        [84126] = 10000, -- Breton Female Dance (Lava Foot Stomp)
        [84127] = 10000, -- Dunmer Male Dance (Lava Foot Stomp)
        [84128] = 10000, -- Dunmer Female Dance (Lava Foot Stomp)
        [84130] = 10000, -- Altmer Male Dance (Lava Foot Stomp)
        [84131] = 10000, -- Altmer Female Dance (Lava Foot Stomp)
        [84133] = 10000, -- Nord Dance (Lava Foot Stomp)
        [84528] = 12000, -- Flame Juggling (Castle Charm Challenge)
        [84506] = 12000, -- Dagger Juggling (Castle Charm Challenge)
        [84533] = 12000, -- Sword Swallowing (Castle Charm Challenge)
        [83775] = 2000,  -- Event - Q5742 WitchFest Intro (The Witchmother's Bargain)
    },

    --------------------------------------------------------------------------------------------------------------------------------
    --  List of abilities flagged for CombatInfo to show on the Cast Bar
    --------------------------------------------------------------------------------------------------------------------------------
    IsCast =
    {
        ----------------------------------------------------------------
        -- PLAYER ABILITIES --------------------------------------------
        ----------------------------------------------------------------

        -- Innate
        [6811] = true,   -- Recall
        [69293] = true,  -- Sigil of Imperial Retreat
        [37059] = true,  -- Mount Up (Mount)
        [141013] = true, -- Mount Up (Passenger Mount)
        [14031] = true,  -- Mundus Use
        [14644] = true,  -- Revive (Death Dialogue)
        [32346] = true,  -- Skyshard Collect
        [151928] = true, -- Aetherial Well (Aetherial Well)
        [47270] = true,  -- Ritual of Mara

        -- Weapon Attacks
        [15279] = true, -- One Handed
        [16420] = true, -- Dual Wield
        [16041] = true, -- Two Handed
        [16691] = true, -- Bow
        [16212] = true, -- Restoration
        [15383] = true, -- Inferno
        [16261] = true, -- Ice
        [18396] = true, -- Lightning
        [18429] = true, -- Unarmed

        -- Customized Actions - Recalling
        [209299] = true, -- Accursed Recall
        [187552] = true, -- Bitter Coast Recall
        [215092] = true, -- Coldharbour Recall
        [200161] = true, -- Frostfall Recall
        [215089] = true, -- Gold Road Recall
        [191859] = true, -- Legionnaire's Recall
        [199791] = true, -- Recall of the Crusader
        [181388] = true, -- Recall of the Galen Wilds
        [221093] = true, -- Recall of the Outer Darkness

        -- Misc Items
        [206063] = true, -- CreateAttunableStation (Attunable Crafting Station)
        [113432] = true, -- 68235 Stun (Nascent Indrik)
        [130394] = true, -- 68235 Stun (Spectral Indrik)
        [131536] = true, -- Generic Stun & Combine (Sovereign Sow)
        [151843] = true, -- 68235 Stun (Deadlands Firewalker)
        [148079] = true, -- 68235 Stun (Unstable Morpholith)

        [68259] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment I)
        [68263] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment II)
        [68267] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment III)
        [68271] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment IV)
        [68275] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment V)
        [68279] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment VI)
        [68283] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment VII)
        [70584] = true,  -- 68235 Stun (Merethic Restorative Resin)
        [88451] = true,  -- 88449 Stun (Aetheric Cipher)
        [110890] = true, -- 68235 Stun (Welkynar Binding)

        [63427] = true,  -- Clean Fish (Filet Fish)
        [78052] = true,  -- Minor Pardon (Counterfeit Pardon Edict)
        [76350] = true,  -- Moderate Pardon (Leniency Edict)
        [76349] = true,  -- Full Pardon (Grand Amnesty Edict)

        [147795] = true, -- 88449 Stun (Chef Arquitius's Torte Dissertation)
        [147850] = true, -- 88449 Stun (Chef Arquitius's Lost Thesis)
        [148052] = true, -- 68235 Stun (Breton Terrier Mammoth Bone)
        [123110] = true, -- 68235 Stun (Mummified Alfiq Parts)
        [123115] = true, -- 68235 Stun (Plague-Drenched Fabric)
        [140544] = true, -- 68235 Stun (Stone Husk Fragment)

        [111141] = true, -- 68235 Stun (Swamp Jelly Carrying Jar)
        [111129] = true, -- 68235 Stun (Swamp Jelly Fine-Mesh Net)
        [111153] = true, -- 68235 Stun (Swamp Jelly Hunter's Lense)
        [111133] = true, -- 68235 Stun (Swamp Jelly Luminous Fishmeal)
        [111137] = true, -- 68235 Stun (Swamp Jelly Luring Flute)
        [111149] = true, -- 68235 Stun (Swamp Jelly Moss Bedding)
        [111145] = true, -- 68235 Stun (Swamp Jelly Spawning Mud)

        [117532] = true, -- 68235 Stun (Guar Stomp Elucidating Hand-Sculpture)
        [117558] = true, -- 68235 Stun (Guar Stomp History in Street Theatre)
        [117554] = true, -- 68235 Stun (Guar Stomp Illustrated Reports)
        [117550] = true, -- 68235 Stun (Guar Stomp Noise Reports)
        [117545] = true, -- 68235 Stun (Guar Stomp Rehearsal Tuning Fork)
        [117562] = true, -- 68235 Stun (Guar Stomp Skeletal Reconstruction)
        [117541] = true, -- 68235 Stun (Guar Stomp Steps-Practice Rug)

        -- TODO: Big-Eared Ginger Kitten Casts replaced - check later

        -- TODO: Psijic Glowglobe Casts replaced - check later

        -- TODO: Sixth House Robe Casts replaced - check later

        -- TODO: Dwarven Theodolite Casts replaced - check later

        [111190] = true, -- 68235 Stun (Arena Gladiator's Exultation)
        [115064] = true, -- 68235 Stun (Arena Gladiator's Mockery)
        [106174] = true, -- 68235 Stun (Arena Gladiator's Recognition)
        [116416] = true, -- 68235 Stun (Arena Gladiator's Roar)
        [134883] = true, -- 68235 Stun (Knight's Rebuke)
        [134851] = true, -- 68235 Stun (Knight's Resolve)
        [140622] = true, -- 68235 Stun (Reach-Mage's Ferocity)
        [145216] = true, -- 68235 Stun (Siege of Cyrodiil Distinction)
        [124789] = true, -- 68235 Stun (Siege of Cyrodiil Recognition)
        [126710] = true, -- 68235 Stun (Siege of Cyrodiil Recommendation)
        [124624] = true, -- 68235 Stun (Alliance Standard-Bearer's License)
        [148421] = true, -- 68235 Stun (Siege of Cyrodiil Commendation)

        -- Seasonal Mementos and Items
        [86792] = true, -- Eating (High Hrothgar Festival Mints)
        [86739] = true, -- Drinking (Sailor's Warning Festival Grog)

        -- Memento (Seasonal)
        [85355] = true,  -- Flame Juggling (Consumable Version)
        [85354] = true,  -- Dagger Juggling (Consumable Verison)
        [85353] = true,  -- Sword Swallowing (Consumable Version)
        [146657] = true, -- Memento Cliff Racer (Thetys Ramary's Bait Kit)
        [87964] = true,  -- Jester's Festival Illusion Daz (Sparkwreath Dazzler)
        [87965] = true,  -- Jester's Festival Illusion Daz (Plume Dazzler)
        [87966] = true,  -- Jester's Festival Illusion Daz (Spiral Dazzler)
        [88374] = true,  -- Jester's Festival Illusion Daz (Sparkly Hat Dazzler)
        [86774] = true,  -- Mudball (Mud Ball Pouch)
        [84330] = true,  -- Mudball (Mud Ball Merriment)
        [116879] = true, -- Alliance Pie (Revelry Pie)
        [87963] = true,  -- Bestowed Cherry Blossoms (Cherry Blossom Branch)

        [115681] = true, -- Party Noise Maker (Festive Noise Maker)
        [129550] = true, -- Stunned (Jester's Festival Joke Popper)
        [149874] = true, -- Playful Prankster's Surprise Box (Playful Prankster's Surprise Box)
        [102077] = true, -- Jester's Festival Scintillator (Jester's Scintillator)
        [81575] = true,  -- Event - WitchFest Cauldron (Witchmother's Whistle)
        [104324] = true, -- Psijic Pearl Summon (Psijic Celestial Orb)
        [104323] = true, -- Psijic Hourglass (Psijic Tautology Glass)
        [104325] = true, -- Psijic Disintegrate (Sapiarchic Discorporation Lens)
        [110482] = true, -- Rind-Renewing Pumpkin (Rind-Renewing Pumpkin)
        [116543] = true, -- Gourd-Gallows Stump (Gourd-Gallows Stump)
        [110481] = true, -- Gourd-Gallows Stump (Gourd-Gallows Stump)
        [113288] = true, -- U20 Crown Memento 1 (Mire Drum)
        [113291] = true, --  U20 Crown Memento 2 (Vossa-satl)
        [151489] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [151490] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [151491] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
        [146752] = true, -- Phial of Clockwork Lubricant (Phial of Clockwork Lubricant)
        [111458] = true, -- Apple-Bobbing Cauldron (Apple-Bobbing Cauldron)
        [111459] = true, -- Apple-Bobbing Cauldron (Apple-Bobbing Cauldron)
        [125820] = true, -- Witches Festival 2019 Marionette (Skeletal Marionette)
        [144790] = true, -- Throw Bones (Throwing Bones)
        [144791] = true, -- Throw Bones (Throwing Bones)

        -- Memento (Crown)
        [85347] = true,  -- Storm Orb Juggle (Atronach Juggling)
        [97273] = true,  -- TROPHY Death Crate Mem 1 (Crow's Calling)
        [99318] = true,  -- TROPHY Flame Crate Mem 1 (Fiery Orb)
        [99319] = true,  -- Flame Crate Memento 2 (Flame Pixie)
        [99320] = true,  -- TROPHY Flame Crate Mem 3 (Flame Eruption)
        [101874] = true, -- _CRWN Dragon Priest Mem2 Ice T (Scalecaller Frost Shard)
        [101877] = true, -- _CRWN Dragon Priest Mem1 Fl/St (Scalecaller Rune of Levitation)
        [101872] = true, -- _CRWN Dragon Priest Memento3 (Bone Dragon Summons Focus)

        -- Memento (Base)
        [16846] = true, -- Blackfeather Court Whistle (Blackfeather Court Whistle)
        [41988] = true, -- Bonesnap Binding Stone (Bonesnap Binding Stone)
        [41948] = true, -- Glanir's Smoke Bomb (Glanir's Smoke Bomb)
        [43700] = true, -- Wand of Finding (Lena's Wand of Finding)
        [42076] = true, -- Tear (Mezha-dro's Sealing Amulet)
        [42105] = true, -- Nanwen's Sword (Nanwen's Sword)
        [34578] = true, -- Nirnroot Wine (Nirnroot Wine)
        [25369] = true, -- Sanguine's Goblet (Sanguine's Goblet)
        [42008] = true, -- Blessing of Root Sunder (Token of Root Sunder)
        [42053] = true, -- Yokudan Salute (Yokudan Totem)

        -- Memento (DLC)
        [143495] = true, -- Reliquary of Dark Designs (Reliquary of Dark Designs)
        [89550] = true,  -- TROPHY Azura's Light (Twilight Shard)
        [79510] = true,  -- TROPHY Blood Oath (Blade of the Blood Oath)
        [73686] = true,  -- Old Orsinium Trophy (Malacath's Wrathful Flame)
        [74151] = true,  -- Stun (Hidden Pressure Vent)
        [92862] = true,  -- Ringing Bell (Dreamer's Chime)
        [119099] = true, -- Brittle Burial Urn (Brittle Burial Urn)
        [125816] = true, -- Maarselok Corruption Memento (Corruption of Maarselok)
        [136120] = true, -- Ritual Circle Totem (Ritual Circle Totem)
        [137919] = true, -- Juggling Potion Bottles (Mostly Stable Juggling Potions)
        [147598] = true, --  Void Shard (Void Shard)
        [149881] = true, -- Illusory Salamander Stone (Illusory Salamander Stone)
        [153758] = true, -- Golden Anvil Replica (Full-Scale Golden Anvil Replica)
        [146744] = true, -- Temperamental Grimoire (Temperamental Grimoire)
        [153760] = true, -- Wilting Weed Killer Phial (Wilting Weed Killer Phial)
        [149879] = true, -- Daedric Unwarding Amulet (Daedric Unwarding Amulet)
        [125817] = true, -- U24 Teaser Dragon Horn (Dragonhorn Curio)
        [119107] = true, -- NAME ME Infect Brew (Winnowing Plague Decoction)

        -- Dragonknight
        [29032] = true, -- Stonefist (Stonefist)
        [31816] = true, -- Stone Giant (Stone Giant)

        -- Nightblade
        [33398] = true,  -- Death Stroke (Nightblade)
        [36508] = true,  -- Incapacitating Strike (Nightblade)
        [113105] = true, -- Incapacitating Strike (Nightblade)
        [36514] = true,  -- Soul Harvest (Nightblade)

        -- Sorcerer
        [43714] = true, -- Crystal Shard (Sorcerer)
        [46324] = true, -- Crystal Fragments (Sorcerer)
        [24584] = true, -- Dark Exchange (Sorcerer)
        [24595] = true, -- Dark Deal (Sorcerer)
        [24589] = true, -- Dark Conversion (Sorcerer)
        [23304] = true, -- Summon Unstable Familiar (Sorcerer)
        [23319] = true, -- Summon Unstable Clannfear (Sorcerer)
        [23316] = true, -- Summon Volatile Familiar (Sorcerer)
        [24613] = true, -- Summon Winged Twilight (Sorcerer)
        [24636] = true, -- Summon Twilight Tormentor (Sorcerer)
        [24639] = true, -- Summon Twilight Matriarch (Sorcerer)

        -- Templar
        [26114] = true, -- Puncturing Strikes (Templar)
        [26792] = true, -- Biting Jabs (Templar)
        [26797] = true, -- Puncturing Sweep (Templar)
        [22138] = true, -- Radial Sweep (Templar)
        [22144] = true, -- Empowering Sweep (Templar)
        [22139] = true, -- Crescent Sweep (Templar)
        [22057] = true, -- Solar Flare (Templar)
        [22110] = true, -- Dark Flare (Templar)
        [63029] = true, -- Radiant Destruction (Templar)
        [63044] = true, -- Radiant Glory (Templar)
        [63046] = true, -- Radiant Oppression (Templar)
        [22223] = true, -- Rite of Passage (Templar)
        [22229] = true, -- Remembrance (Templar)
        [22226] = true, -- Practiced Incantation (Templar)

        -- Warden
        [85982] = true, -- Feral Guardian (Warden)
        [85986] = true, -- Eternal Guardian (Warden)
        [85990] = true, -- Wild Guardian (Warden)

        -- Necromancer
        [115478] = true, -- Bone Goliath Self Snare (Bone Goliath Transformation)
        [118673] = true, -- Pummeling Goliath Self Snare (Pummeling Goliath)
        [118287] = true, -- Ravenous Goliath Self Snare (Ravenous Goliath)

        -- Arcanist
        [193331] = true, -- Fatecarver (Arcanist)
        [193397] = true, -- Exhausting Fatecarver (Arcanist)
        [193398] = true, -- Pragmatic Fatecarver (Arcanist)
        [198309] = true, -- Remedy Cascade (Arcanist)
        [198330] = true, -- Cascading Fortune (Arcanist)
        [198537] = true, -- Curative Surge (Arcanist)

        -- Two Handed
        [28279] = true, -- Uppercut (Two Handed)
        [38814] = true, -- Dizzying Swing (Two Handed)
        [38807] = true, -- Wrecking Blow (Two Handed)

        [83216] = true, -- Berserker Strike (Two Handed)
        [83229] = true, -- Onslaught (Two Handed)
        [83238] = true, -- Berserker Rage (Two Handed)

        -- Dual Wield
        [28607] = true, -- Flurry (Dual Wield)
        [38857] = true, -- Rapid Strikes (Dual Wield)
        [38846] = true, -- Bloodthirst (Duel Wield)

        -- Bow
        [28882] = true, -- Snipe (Bow)
        [38685] = true, -- Lethal Arrow (Bow)
        [38687] = true, -- Focused Aim (Bow)
        [83465] = true, -- Rapid Fire (Bow)
        [85257] = true, -- Toxic Barrage (Bow)

        -- Soul Magic
        [39270] = true, -- Soul Strike (Soul Magic)
        [40420] = true, -- Soul Assault (Soul Magic)
        [40414] = true, -- Shatter Soul (Soul Magic)

        -- Vampire
        [40350] = true,  -- Feed (Vampire - Bite Player)

        [134583] = true, -- Vampiric Drain (Vampire)
        [135905] = true, -- Drain Vigor (Vampire)
        [137259] = true, -- Exhilarating Drain (Vampire)

        [138565] = true, -- Blood Scion (Vampire)
        [138568] = true, -- Blood Scion (Vampire)
        [138614] = true, -- Swarming Scion (Vampire)
        [138615] = true, -- Swarming Scion (Vampire)
        [138618] = true, -- Perfect Scion (Vampire)
        [138619] = true, -- Perfect Scion (Vampire)

        -- Werewolf
        [33208] = true, -- Devour (Werewolf)
        [39033] = true, -- Werewolf Transform Setup (Werewolf)
        [39477] = true, -- De-Werewolf (Werewolf)
        [40515] = true, -- Devour (Werewolf - Bite Player)
        [75008] = true, -- Werewolf Transformation (Werewolf - Quest Transformation)
        [40124] = true, -- Devour (Werewolf - Quest)

        -- Guild
        [35713] = true,  -- Dawnbreaker (Fighter's Guild)
        [40161] = true,  -- Flawless Dawnbreaker (Fighter's Guild)
        [40158] = true,  -- Dawnbreaker of Smiting (Fighter's Guild)
        [103488] = true, -- Time Stop (Psijic Order)
        [104059] = true, -- Borrowed Time (Psijic Order)
        [103706] = true, -- Channeled Acceleration (Psijic Order)

        -- Alliance War
        [61487] = true, -- Magicka Detonation (Assault)
        [61491] = true, -- Inevitable Detonation (Assault)

        -- Scribing
        [217228] = true, -- Elemental Explosion
        [222313] = true, -- Elemental Explosion
        [217178] = true, -- Smash
        [217179] = true, -- Smash
        [217184] = true, -- Smash
        [217820] = true, -- Smash
        [219972] = true, -- Smash
        [217607] = true, -- Torchbearer
        [217630] = true, -- Torchbearer
        [217633] = true, -- Torchbearer
        [217637] = true, -- Torchbearer
        [223292] = true, -- Torchbearer
        [217663] = true, -- Trample
        [220541] = true, -- Trample
        [220542] = true, -- Trample
        [220545] = true, -- Trample

        ----------------------------------------------------------------
        -- NPC ABILITIES -----------------------------------------------
        ----------------------------------------------------------------

        -- Shared/Innate
        [4197] = true, -- Recovering (NPC Duel)

        ----------------------------------------------------------------
        -- CYRODIIL ----------------------------------------------------
        ----------------------------------------------------------------

        [12256] = true,  -- Pack Siege (Siege Weapons)

        [29673] = true,  -- Create Ballista Bolt... (Ballista)
        [29672] = true,  -- Create Ballista Bolt... (Ballista)
        [29671] = true,  -- Create Ballista Bolt... (Ballista)

        [30611] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)
        [30607] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)
        [16751] = true,  -- Create Ballista Fire Bolt... (Fire Ballista)

        [30612] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)
        [30608] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)
        [16752] = true,  -- Create Ballista Lightning Bolt ... (Lightning Ballista)

        [39914] = true,  -- Create Trebuchet... (Stone Trebuchet)
        [39917] = true,  -- Create Trebuchet... (Stone Trebuchet)
        [39910] = true,  -- Create Trebuchet... (Stone Trebuchet)

        [39913] = true,  -- Create Trebuchet... (Iceball Trebuchet)
        [39916] = true,  -- Create Trebuchet... (Iceball Trebuchet)
        [39909] = true,  -- Create Trebuchet... (Iceball Trebuchet)

        [13665] = true,  -- Create Trebuchet... (Firepot Trebuchet)
        [13664] = true,  -- Create Trebuchet... (Firepot Trebuchet)
        [13663] = true,  -- Create Trebuchet... (Firepot Trebuchet)

        [30613] = true,  -- Create Catapult Meatbag (Meatbag Catapult)
        [30609] = true,  -- Create Catapult Meatbag (Meatbag Catapult)
        [16755] = true,  -- Create Catapult Meatbag (Meatbag Catapult)

        [30614] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
        [30610] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
        [16754] = true,  -- Create Catapult Oil Jar... (Oil Catapult)

        [39915] = true,  -- Create Catapult Meatbag (Scattershot Catapult)
        [39918] = true,  -- Create Catapult Oil Jar... (Scattershot Catapult)
        [39911] = true,  -- Create Trebuchet... (Scattershot Catapult)

        [66438] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
        [66439] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
        [66440] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)

        [66434] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
        [66388] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
        [66387] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)

        [66437] = true,  -- Create Ballista... (Cold Fire Ballista)
        [66436] = true,  -- Create Ballista... (Cold Fire Ballista)
        [66435] = true,  -- Create Ballista... (Cold Fire Ballista)

        [135862] = true, -- Create Lance Cannon... (Shock Lancer)
        [135861] = true, -- Create Lance Cannon... (Shock Lancer)
        [135860] = true, -- Create Lance Cannon... (Shock Lancer)

        [135859] = true, -- Create Lance Cannon... (Fire Lancer)
        [135858] = true, -- Create Lance Cannon... (Fire Lancer)
        [135836] = true, -- Create Lance Cannon... (Fire Lancer)

        [135868] = true, -- Create Lance Cannon... (Frost Lancer)
        [135867] = true, -- Create Lance Cannon... (Frost Lancer)
        [135866] = true, -- Create Lance Cannon... (Frost Lancer)

        [22570] = true,  -- Create Boiling Oil... (Flaming Oil)
        [15876] = true,  -- Create Large Ram... (Battering Ram)
        [16171] = true,  -- Create Large Ram... (Battering Ram)
        [16170] = true,  -- Create Large Ram... (Battering Ram)

        [13853] = true,  -- Wall Repair Kit
        [16723] = true,  -- Door Repair Kit
        [13601] = true,  -- Advanced Siege Repair Kit
        [112975] = true, -- Wall Repair Kit (Bridge and Milegate Repair Kit)

        [19039] = true,  -- Ebonheart Forward Camp
        [19040] = true,  -- Aldmeri Forward Camp
        [19041] = true,  -- Daggerfall Forward Camp

        -- [12355] = true, -- Destroy Siege Weapon (Doesn't show up due to Cyrodiil Limitations)

        -- Siege Warfare
        [33348] = true, -- Practice Siege Repair Kit (Practice Siege Repair Kit)

        ----------------------------------------------------------------
        -- QUEST ABILITIES ---------------------------------------------
        ----------------------------------------------------------------

        -- Vampire Quest
        [39507] = true, -- VampInitStun_Profane (Scion of the Blood Matron)

        -- Main Story Quest
        [39367] = true, -- Altar Use (Shadow of Sancre Tor)
        [37827] = true, -- Stendarr's Protection (Shadow of Sancre Tor)
        [36421] = true, -- Drink with Lyris (Council of the Five Companions)
        [47186] = true, -- CHT Portal Killer (The Weight of Three Crown)

        -- Aldmeri Dominion Quests
        [35192] = true, -- Q4620 Use Lodestone (Cast Adrift)
        [33233] = true, -- 4625 Stun for Beckon 1.5s (Tears of the Two Moons)
        [34567] = true, -- Q4621 PC Storm Drain (The Tempest Unleashed)
        [34701] = true, -- Q4621 Destory Horn (The Tempest Unleashed)
        [23540] = true, -- Teleport (Lifting the Veil)
        [46762] = true, -- Drinking Contest (The Great Tree)
        [21364] = true, -- Casting... (The Serpent's Beacon)
        [21409] = true, -- Reading... (The Serpent's Beacon)
        [22889] = true, -- Purifying... (Corruption Stones)
        [22448] = true, -- Q4266 Tie up Hendil (The First Patient)
        [22271] = true, -- Teleport Scroll AB (Depths of Madness)
        [21968] = true, -- Binding Bear... (Silent Village)
        [21393] = true, -- Q4220 PC Chooses to Rescue (The Mallari-Mora)
        -- [21112] = true, -- Q4220 PC Forced to L0
        [22931] = true, -- Freeing Spirit... (An Act of Kindness)
        [23187] = true, -- Q4236 PC Untie Palith (The Veiled Choice)
        [47301] = true, -- Stunned (Passage Denied)
        [37463] = true, -- The Grips of Madness
        [37583] = true, -- Q4868 Unlock Chapel
        [39956] = true, -- Heart of Anumaril
        [40504] = true, -- Q4922 Use Mantle on Device (The Orrery of Elden Root)
        [40557] = true, -- (12127) CFX_4922 Mantle Cast S (The Orrery of Elden Root)
        [35984] = true, -- Q4436 Summon Pirate (Luck of the Albatross)
        [43151] = true, -- Q4768 Use Bucket
        [36710] = true, -- Q4833 Apply Snake Buff (Bosmer Insight)
        [36841] = true, -- Q4833 Apply Wolf Buff (Bosmer Insight)
        [36824] = true, -- Q4833 Apply Tiger Buff (Bosmer Insight)
        [37062] = true, -- Exorcise (The Unquiet Dead)
        [36996] = true, -- Bind Spirit (The Unquiet Dead)
        [37205] = true, -- Animus Geode (Eyes of Azura)
        [37211] = true, -- Q4854 Empower Heart (Eyes of Azura)
        [38246] = true, -- Animus Geode (Eyes of Azura)
        [41325] = true, -- Blacksap's Brew (The Blacksap's Hold)
        [33066] = true, -- Q4586_ChangeClothes (The Witcher of Silatar)
        [34842] = true, -- Q4586_ChangeClothesFEMALE (The Witcher of Silatar)
        [33701] = true, -- BurrowEND (Throne of the Wilderking)
        [33727] = true, -- BurrowEND (Throne of the Wilderking)
        [34499] = true, -- Corruption Beam (The Blight of the Bosmer)

        -- Daggerfall Covenant Quests
        [26535] = true, -- Control Rod (Buried Secrets)
        [79989] = true, -- Mercy Kill (Like Moths to a Candle)

        -- Elsweyr Quests
        [119292] = true, -- Stun (Bright Moons, Warm Sands)

        ----------------------------------------------------------------
        -- SEASONAL QUEST ----------------------------------------------
        ----------------------------------------------------------------

        -- Jester's Festival
        [87474] = true, -- Flower Garland (Springtime Flair)
        [88095] = true, -- Illusion Dazzler (Royal Revelry)
        [88123] = true, -- Illusion Dazzler (Royal Revelry)
        [88124] = true, -- Illusion Dazzler (Royal Revelry)

        -- New Life Festival
        [84847] = true, -- Celebratory Belch (Stonetooth Bash)
        [84125] = true, -- Breton Male Dance (Lava Foot Stomp)
        [84126] = true, -- Breton Female Dance (Lava Foot Stomp)
        [84127] = true, -- Dunmer Male Dance (Lava Foot Stomp)
        [84128] = true, -- Dunmer Female Dance (Lava Foot Stomp)
        [84130] = true, -- Altmer Male Dance (Lava Foot Stomp)
        [84131] = true, -- Altmer Female Dance (Lava Foot Stomp)
        [84133] = true, -- Nord Dance (Lava Foot Stomp)
        [84528] = true, -- Flame Juggling (Castle Charm Challenge)
        [84506] = true, -- Dagger Juggling (Castle Charm Challenge)
        [84533] = true, -- Sword Swallowing (Castle Charm Challenge)

        -- Witches Festival
        [83775] = true, -- Event - Q5742 WitchFest Intro (The Witchmother's Bargain)

        ----------------------------------------------------------------
        -- WORLD BOSSES ------------------------------------------------
        ----------------------------------------------------------------

        [25763] = true, -- Remove Bolt (Trapjaw)

        ----------------------------------------------------------------
        -- DUNGEONS ----------------------------------------------------
        ----------------------------------------------------------------

        [31180] = true, -- Free Ally (Selene - Selene's Web)
        [51389] = true, -- Free Ally (Ruzozuzalpamaz - Crypt of Hearts II)
        [53185] = true, -- Resist Necrosis (Nerien'eth - Crypt of Hearts II)
    },

    --------------------------------------------------------------------------------------------------------------------------------
    -- Fix for a few goofy events that channel onto the player (or just where we need it)
    --------------------------------------------------------------------------------------------------------------------------------
    CastOverride =
    {
        [4197] = true,  -- Recovering (NPC Duel)
        [47186] = true, -- CHT Portal Killer (The Weight of Three Crown)
        [34499] = true, -- Corruption Beam (The Blight of the Bosmer)
    },

    --------------------------------------------------------------------------------------------------------------------------------
    -- Some abilities cast into a channeled stun effect - we want these abilities to display the cast and channel if flagged.
    --------------------------------------------------------------------------------------------------------------------------------
    MultiCast =
    {
        [42076] = true,  -- Tear (Mezha-dro's Sealing Amulet)
        [42053] = true,  -- Yokudan Salute (Yokudan Totem)
        [115681] = true, -- Party Noise Maker (Festive Noise Maker)
    },

    --------------------------------------------------------------------------------------------------------------------------------
    -- If one of these abilities stuns the player - we ignore the standard effect of breaking the cast bar. In some cases a cast event is also applied with a stun for certain quest events, etc.
    --------------------------------------------------------------------------------------------------------------------------------
    IgnoreCastBarStun =
    {
        -- Player
        [36434] = true,  -- Mount Up (Mount)
        [141001] = true, -- Mount Up (Passenger Mount)
        [74232] = true,  -- Stun (Malacath's Wrathful Flame)
        [92863] = true,  -- Stun (Dreamer's Chime)
        [115046] = true, -- 68235 Stun (Nascent Indrik)

        -- Quests
    },

    --------------------------------------------------------------------------------------------------------------------------------
    -- Abilities flagged to break when EFFECT_RESULT_FADED is detected with the source as the player
    --------------------------------------------------------------------------------------------------------------------------------
    CastBreakOnRemoveEffect =
    {
        -- Werewolf
        [33208] = true, -- Devour (Werewolf)

        -- Vampire
        [134583] = true, -- Vampiric Drain (Vampire)
        [135905] = true, -- Drain Vigor (Vampire)
        [137259] = true, -- Exhilarating Drain (Vampire)
    },

    --[[
-- Possibly use later if any cast removal events need to rely on EVENT_COMBAT_EVENT
CastBreakOnRemoveEvent = {
},
]]
    --

    --------------------------------------------------------------------------------------------------------------------------------
    -- Convert a cast time ability to channeled, since our function detects Casts/Channels automatically and tries to sort them, we need to add a forced override for certain things we want to show as a channel when it makes sense
    --------------------------------------------------------------------------------------------------------------------------------
    CastChannelConvert =
    {
        -- Cyrodiil
        [12256] = true, -- Pack Siege (Siege Weapons)

        -- Memementos
        [73686] = true, -- Old Orsinium Trophy (Malacath's Wrathful Flame)
        [92862] = true, -- Ringing Bell (Dreamer's Chime)
    },

    --[[
CastBarTable.InteractCast = {

    ['Aetherial Gateway'] = {
        [394] = { icon = 'LuiExtended/media/icons/abilities/ability_quest_atherial_shift.dds', name = Abilities.Skill_Aetherial_Shift, duration = 2000, delay = 750 }, -- Ezduiin Undercroft
    }

}
]]
    --
}

--- @class (partial) CastBarTable
Data.CastBarTable = castBarTable
