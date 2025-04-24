--- @diagnostic disable: duplicate-index
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
-- List of all abilityId's that have been processed so far
-- These id's don't show up on the debug event for EVENT_COMBAT_EVENT or EVENT_EFFECT_CHANGED
--- @class DebugAuras
local debugAuras =
{

    -------------------------------------
    -- PLAYER ABILITIES -----------------
    -------------------------------------

    -------------------------------------
    -- MAJOR / MINOR BUFFS & DEBUFFS
    -------------------------------------

    -- Major / Minor Buffs
    [61693] = true,  -- Minor Resolve
    [61694] = true,  -- Major Resolve
    [61697] = true,  -- Minor Fortitude
    [61698] = true,  -- Major Fortitude
    [61704] = true,  -- Minor Endurance
    [61705] = true,  -- Major Endurance
    [61706] = true,  -- Minor Intellect
    [61707] = true,  -- Major Intellect
    [61685] = true,  -- Minor Sorcery
    [61687] = true,  -- Major Sorcery
    [61691] = true,  -- Minor Prophecy
    [61689] = true,  -- Major Prophecy
    [61662] = true,  -- Minor Brutality
    [61665] = true,  -- Major Brutality
    [61666] = true,  -- Minor Savagery
    [61667] = true,  -- Major Savagery
    [61744] = true,  -- Minor Berserk
    [61745] = true,  -- Major Berserk
    [61746] = true,  -- Minor Force
    [61747] = true,  -- Major Force
    [61549] = true,  -- Minor Vitality
    [61713] = true,  -- Major Vitality
    [61710] = true,  -- Minor Mending
    [61711] = true,  -- Major Mending
    [61721] = true,  -- Minor Protection
    [61722] = true,  -- Major Protection
    [61715] = true,  -- Minor Evasion
    [61716] = true,  -- Major Evasion
    [61735] = true,  -- Minor Expedition
    [61736] = true,  -- Major Expedition
    [63569] = true,  -- Major Gallop
    [61708] = true,  -- Minor Heroism
    [61709] = true,  -- Major Heroism
    [88490] = true,  -- Minor Toughness
    [147417] = true, -- Minor Courage
    [109966] = true, -- Major Courage

    -- Major / Minor Debuffs
    [61742] = true,  -- Minor Breach
    [61743] = true,  -- Major Breach
    [79717] = true,  -- Minor Vulnerability
    [106754] = true, -- Major Vulnerability
    [61723] = true,  -- Minor Maim
    [61725] = true,  -- Major Maim
    [61726] = true,  -- Minor Defile
    [61727] = true,  -- Major Defile
    [88401] = true,  -- Minor Magickasteal
    -- [88402] = true, -- Minor Magickasteal
    [86304] = true,  -- Minor Lifesteal
    -- [86305] = true, -- Minor Lifesteal
    [79907] = true,  -- Minor Enervation
    [79895] = true,  -- Minor Uncertainty
    [79867] = true,  -- Minor Cowardice
    [147643] = true, -- Major Cowardice
    [61733] = true,  -- Minor Mangle
    [140699] = true, -- Minor Timidity
    [145975] = true, -- Minor Brittle
    [145977] = true, -- Major Brittle

    -- Major / Minor Aegis & Slayer
    [76618] = true,  -- Minor Aegis
    [147225] = true, -- Minor Aegis
    [93123] = true,  -- Major Aegis
    [76617] = true,  -- Minor Slayer
    [147226] = true, -- Minor Slayer
    [93109] = true,  -- Major Slayer

    -- Empower
    [61737] = true, -- Empower

    -------------------------------------
    -- STATUS EFFECT PROCS
    -------------------------------------

    -- Magic Status Effects
    [18084] = true,  -- Burning (Fire Status Effect)
    [130804] = true, -- Burning (Fire Status Effect - Siege)
    [21481] = true,  -- Chill (Frost Status Effect)
    [68368] = true,  -- Minor Maim (Frost Status Effect)
    [95136] = true,  -- Chill (Frost Status Effect)
    [130814] = true, -- Chill (Frost Status Effect - Siege)
    [130815] = true, -- Minor Maim (Frost Status Effect - Siege)
    [130816] = true, -- Chill (Frost Status Effect - Siege)
    [21487] = true,  -- Concussion (Shock Status Effect)
    [68359] = true,  -- Minor Maim (Shock Status Effect)
    [95134] = true,  -- Concussion (Shock Status Effect)
    [130808] = true, -- Concussion (Shock Status Effect - Siege)
    [130809] = true, -- Minor Maim (Shock Status Effect - Siege)
    [130810] = true, -- Concussion (Shock Status Effect - Siege)
    [148797] = true, -- Overcharged (Magic Status Effect)
    [148798] = true, -- Minor Magickasteal (Magic Status Effect)
    [178118] = true, -- Overcharged (Magic Status Effect)

    -- Martial Status Effects
    [21925] = true,  -- Diseased (Disease Status Effect)
    [21927] = true,  -- Major Defile (Disease Status Effect)
    [178127] = true, -- Diseased (Disease Status Effect)
    [148801] = true, -- Hemorrhaging (Bleed Status Effect)
    [148808] = true, -- Minor Mangle (Bleed Status Effect)
    [21929] = true,  -- Poisoned (Poison Status Effect)
    [148800] = true, -- Sundered (Physical Status Effect)
    [148803] = true, -- Minor Breach (Physical Status Effect)
    [178123] = true, -- Sundered (Physical Status Effect)
    [149573] = true, -- Sundered (Physical Status Effect - Siege)
    [149576] = true, -- Minor Breach (Physical Status Effect - Siege)

    -------------------------------------
    -- MUNDUS STONE
    -------------------------------------

    -- Mundus Stone Interaction
    [14031] = true, -- Mundus Use

    -- Boons
    [13940] = true, -- Boon: The Warrior
    [13943] = true, -- Boon: The Mage
    [13974] = true, -- Boon: The Serpent
    [13975] = true, -- Boon: The Thief
    [13976] = true, -- Boon: The Lady
    [13977] = true, -- Boon: The Steed
    [13978] = true, -- Boon: The Lord
    [13979] = true, -- Boon: The Apprentice
    [13980] = true, -- Boon: The Ritual
    [13981] = true, -- Boon: The Lover
    [13982] = true, -- Boon: The Atronach
    [13984] = true, -- Boon: The Shadow
    [13985] = true, -- Boon: The Tower

    -------------------------------------
    -- INNATE ABILITIES
    -------------------------------------

    -- Roll Dodge
    [28549] = true,  -- Roll Dodge
    [29721] = true,  -- Immobilize Immunity
    [119068] = true, -- Immobilize Immunity
    [69143] = true,  -- Dodge Fatigue

    -- Crouch
    [20299] = true, -- Sneak
    -- [20304] = true, -- Crouch Slow
    [76463] = true, -- Clairvoyance Fx
    [20307] = true, -- Trying to Hide
    [20309] = true, -- Hidden
    -- [20301] = true, -- Crouch Drain
    [38127] = true, -- Remove Sprint
    [29177] = true, -- Flee
    -- [64420] = true, -- Remove Pet Stealth
    [49547] = true, -- Bonus limiter
    [26245] = true, -- Slam Stun

    -- Mount
    [36010] = true,  -- Mount Up
    [37059] = true,  -- Mount Up
    [37139] = true,  -- Mount Up
    [36434] = true,  -- Mount Up
    [42399] = true,  -- Remove on Dismount
    [36432] = true,  -- Dismount
    [36417] = true,  -- Dismount
    [36419] = true,  -- Dismount
    [46697] = true,  -- Pause Mount Stamina Regen
    [115607] = true, -- Hard Dismount

    -- Passenger Mount
    -- [140996] = true, -- Mount Up Passenger
    -- [141013] = true, -- Mount Up
    -- [141012] = true, -- Mount Up
    -- [141001] = true, -- Mount Up
    -- [141011] = true, -- Remove on Dismount
    -- [141008] = true, -- Dismount
    -- [141002] = true, -- Dismount
    -- [140998] = true, -- Dismount
    -- [141003] = true, -- Pause Mount Stamina Regen
    -- [141004] = true, -- Hard Dismount

    -- Block
    -- [86311] = true, -- Block FX
    [86310] = true, -- Stagger
    [86309] = true, -- Stun
    [86312] = true, -- Stun
    [45902] = true, -- Off-Balance

    -- Bash
    [55146] = true, -- Interrupt Bonus
    [21970] = true, -- Bash
    [21973] = true, -- Bash
    [21972] = true, -- Stagger
    [21971] = true, -- Bash Stun
    -- [48416] = true, -- Uber Attack
    -- [45982] = true, -- Bash Stun

    -- Off-Balance Exploit
    [18793] = true, -- Off-Balance Exploit
    [16825] = true, -- Off-Balance Exploit

    -- Break Free
    [16565] = true, -- Break Free
    [46330] = true, -- Brace Cooldown

    -- Death/Resurrection
    [14644] = true, -- Revive (Death Dialog)
    [14646] = true, -- Recently Revived
    [26770] = true, -- Resurrect
    [55406] = true, -- Resurrect Trigger
    -- [123969] = true, -- Lesser Reincarnate
    -- [123970] = true, -- Lesser Reincarnate

    -- Basic Attacks
    -- [16593] = true, -- Melee Snare
    -- [48532] = true, -- Charge Snare
    -- [41952] = true, -- Cower
    -- [20299] = true, -- Pet Hidden
    [16566] = true, -- CC Immunity
    [28301] = true, -- Crowd Control Immunity
    [38117] = true, -- Crowd Control Immunity

    -- Taunt Effects
    [38254] = true, -- Taunt
    [52790] = true, -- Taunt Counter
    [38541] = true, -- Taunt
    [38542] = true, -- Update

    -- Disguise Effects
    [25602] = true, -- Suspicious
    [26237] = true, -- Disguise Warning Area
    [50602] = true, -- Disguised
    [26238] = true, -- Disguise Warning Area
    [25584] = true, -- Discovered
    [25582] = true, -- Remove Disguise
    [26472] = true, -- Remove Disguise
    [25603] = true, -- Begin
    [25604] = true, -- Interact Complete
    [26223] = true, -- Remove Suspicious
    [13371] = true, -- Acting Suspicious
    [13372] = true, -- Spotted

    -- Pet Effects
    [28609] = true,  -- Dummy Target Setter
    [43958] = true,  -- Player Pet Defenses
    [70116] = true,  -- Player Pet Battle Spirit
    [126366] = true, -- Pet Battle Spirit
    [71904] = true,  -- Player Pet Speed
    [62197] = true,  -- Player Pet Critical Chance
    [43963] = true,  -- Player Pet Threat
    [62201] = true,  -- Taunt
    [63795] = true,  -- Taunt
    [63794] = true,  -- Taunt

    -- Death Achieve Check (Veteran Dungeons)
    [55883] = true, -- Death Achieve Check
    [55884] = true, -- Death Achieve Check
    [58955] = true, -- Death Achieve Check
    [58963] = true, -- Death Achieve Check
    [66271] = true, -- Death Achieve Check
    [66272] = true, -- Death Achieve Check
    [75612] = true, -- Death Achieve Check
    [75615] = true, -- Death Achieve Check
    [76264] = true, -- Death Achieve Check
    [76265] = true, -- Death Achieve Check

    -- Misc Effects
    [15594] = true,  -- Bonus vs off Balance
    -- [28541] = true, -- Swap Weapons
    [25166] = true,  -- Clumsy
    [10950] = true,  -- Fall Snare
    [6811] = true,   -- Recall
    [31221] = true,  -- Skyshard Collect
    [32346] = true,  -- Skyshard Collect
    -- [63601] = true, -- ESO Plus Member
    [2727] = true,   -- Off-Balance
    [134599] = true, -- Off Balance Immunity
    -- [132831] = true, -- Major Vulnerability Invulnerability
    [85701] = true,  -- Dueling Flag
    [21263] = true,  -- Ayleid Health Bonus
    [100862] = true, -- Fortified Ayleid Health Bonus

    [151940] = true, -- Aetherial Well (Aetherial Well)
    [151928] = true, -- Aetherial Well (Aetherial Well)
    [151935] = true, -- Aetherial Well Restore (Aetherial Well)
    [151942] = true, -- Aetherial Well Restore (Aetherial Well)
    [151931] = true, -- Aetherial Well Restore (Aetherial Well)
    [151934] = true, -- Aetherial Well Restore (Aetherial Well)

    [45819] = true,  -- Remove Werevamp
    -- [51064] = true, -- Weakness
    -- [39405] = true, -- Weakness

    -- Dummy Effects
    -- [37079] = true, -- remove
    -- [20311] = true, -- Remove Sprint
    [20303] = true, -- Remove Sprint
    -- [70379] = true, -- Remove
    -- [70385] = true, -- Remove
    -- [38519] = true, -- Hiding
    -- [39046] = true, -- Add Guild Rep
    [62797] = true, -- Weapon Swap Cooldown Timer
    [62798] = true, -- Weapon Swap Cooldown Timer
    -- [61874] = true, -- Swap to Weapon Set 1
    -- [61875] = true, -- Swap to Weapon Set 2

    -------------------------------------
    -- CHAMPION POINTS ------------------
    -------------------------------------

    -------------------------------------
    -- CRAFT
    -------------------------------------

    -- Passives
    -- [142205] = true, -- Breakfall
    -- [142232] = true, -- Soul Reservoir
    -- [142206] = true, -- Wanderer
    -- [142206] = true, -- Wanderer
    -- [142207] = true, -- Fortune's Favor
    -- [152371] = true, -- Fortune's Favor
    [142210] = true, -- Gilded Fingers
    -- [142204] = true, -- Out of Sight
    -- [142203] = true, -- Fleet Phantom
    -- [142211] = true, -- Steadfast Enchantment
    -- [152367] = true, -- Steadfast Enchantment
    -- [142208] = true, -- Inspiration Boost

    -- Slottables
    [142213] = true, -- Friends in Low Places
    [152360] = true, -- Friends in Low Places
    -- [142215] = true, -- Infamous
    [142219] = true, -- Shadowstrike
    [151862] = true, -- Shadowstrike
    [151861] = true, -- Shadowstrike
    [151860] = true, -- Shadowstrike
    [151859] = true, -- Clairvoyance Fx
    [142235] = true, -- Cutpurse's Art
    [142228] = true, -- Fade Away
    -- [152310] = true, -- Fade Away
    -- [142224] = true, -- Meticulous Disassembly
    -- [142225] = true, -- Meticulous Disassembly
    -- [142226] = true, -- Meticulous Disassembly
    -- [142227] = true, -- Meticulous Disassembly
    [142218] = true, -- Treasure Hunter
    -- [142217] = true, -- Master Gatherer
    -- [152372] = true, -- Master Gatherer
    -- [149286] = true, -- Gifted Rider
    -- [142223] = true, -- War Mount
    [142220] = true, -- Plentiful Harvest
    -- [142236] = true, -- Homemaker
    -- [142233] = true, -- Reel Technique
    [142234] = true, -- Angler's Instincts
    -- [142231] = true, -- Liquid Efficiency
    -- [142230] = true, -- Rationer
    -- [152373] = true, -- Rationer
    -- [142125] = true, -- Steed's Blessing
    -- [142123] = true, -- Sustaining Shadows
    -- [142121] = true, -- Professional Upkeep

    -------------------------------------
    -- WARFARE
    -------------------------------------

    -- Passive
    -- [149305] = true, -- Eldritch Insight
    -- [141898] = true, -- Precision
    -- [147888] = true, -- Tireless Discipline
    -- [149439] = true, -- Blessed
    -- [141928] = true, -- Blessed
    -- [141929] = true, -- Quick Recovery
    -- [141901] = true, -- Preparation
    -- [149273] = true, -- Elemental Aegis
    -- [149274] = true, -- Hardy
    -- [141895] = true, -- Piercing
    -- [141931] = true, -- War Mage
    -- [149276] = true, -- Battle Mastery
    -- [141930] = true, -- Mighty
    -- [149275] = true, -- Flawless Ritual

    -- Slottable
    [155992] = true, -- Hope Infusion
    [155993] = true, -- Minor Heroism
    [155996] = true, -- Hope Infusion
    [155978] = true, -- Salve of Renewal
    [155981] = true, -- Salve of Renewal
    [156017] = true, -- From the Brink
    [156020] = true, -- From the Brink
    [156019] = true, -- From the Brink
    [156008] = true, -- Enlivening Overflow
    [156012] = true, -- Enlivening Overflow
    [156011] = true, -- Enlivening Overflow
    -- [141998] = true, -- Soothing Tide
    -- [142000] = true, -- Focused Mending
    -- [142002] = true, -- Swift Renewal
    -- [141942] = true, -- Rejuvenator
    [59526] = true,  -- Foresight
    [59530] = true,  -- Foresight
    [142003] = true, -- Cleansing Revival
    -- [142005] = true, -- Cleansing Revival
    -- [141900] = true, -- Resilience
    -- [159972] = true, -- Ironclad
    -- [151749] = true, -- Duelist's Rebuff
    -- [151748] = true, -- Unassailable
    -- [151750] = true, -- Enduring Resolve
    [60229] = true,  -- Riposte
    [60230] = true,  -- Riposte
    [64067] = true,  -- Reinforced
    [135653] = true, -- Reinforced
    [64079] = true,  -- Bulwark
    [60413] = true,  -- Last Stand
    [65133] = true,  -- Major Heroism
    [142012] = true, -- Cutting Defense
    [142013] = true, -- Cutting Defense
    -- [155859] = true, -- Weapons Expert
    [174250] = true, -- Force of Nature
    [63880] = true,  -- Exploiter
    -- [141999] = true, -- Deadly Aim
    -- [141997] = true, -- Biting Aura
    -- [142001] = true, -- Thaumaturge
    -- [92134] = true, -- Master-at-Arms
    -- [141899] = true, -- Fighting Finesse
    -- [142006] = true, -- Backstabber
    -- [141941] = true, -- Wrathful Strikes
    [142007] = true, -- Reaving Blows
    [142008] = true, -- Reaving Blows
    [142010] = true, -- Occult Overload
    [142011] = true, -- Occult Overload
    -- [141744] = true, -- Arcane Supremacy
    -- [146960] = true, -- Untamed Aggression
    -- [141773] = true, -- Endless Endurance

    -------------------------------------
    -- FITNESS
    -------------------------------------

    -- Passive
    [142079] = true, -- Sprinter
    -- [142083] = true, -- Hasty
    -- [147889] = true, -- Hero's Vigor
    -- [149311] = true, -- Hero's Vigor
    -- [142096] = true, -- Mystic Tenacity
    -- [142077] = true, -- Tumbling
    -- [149624] = true, -- Defiance
    -- [142089] = true, -- Piercing Gaze
    -- [142080] = true, -- Tireless Guardian
    -- [142081] = true, -- Savage Defense
    -- [142088] = true, -- Nimble Protector
    -- [142086] = true, -- Fortification
    -- [142109] = true, -- Tempered Soul
    -- [142091] = true, -- Bashing Brutality

    -- Slottable
    -- [142111] = true, -- On Guard
    -- [142115] = true, -- Rousing Speed
    [142092] = true, -- Expert Evasion
    -- [142093] = true, -- Expert Evasion
    [151113] = true, -- Expert Evasion
    -- [142110] = true, -- Juggernaut
    [141993] = true, -- Bloody Renewal
    [141994] = true, -- Bloody Renewal
    [141991] = true, -- Siphoning Spells
    [141992] = true, -- Siphoning Spells
    [141995] = true, -- Stategic Reserve
    -- [149283] = true, -- Shield Master
    -- [142100] = true, -- Spirit Mastery
    -- [142102] = true, -- Survival Instincts
    -- [142090] = true, -- Bastion
    -- [142113] = true, -- Arcane Alacrity
    -- [142099] = true, -- Hardened
    -- [142097] = true, -- Peace of Mind
    [142094] = true, -- Slippery
    [145804] = true, -- Slippery
    [142095] = true, -- Slippery
    [134254] = true, -- Winded
    -- [149282] = true, -- Unchained
    [98316] = true,  -- Unchained
    -- [142034] = true, -- Boundless Vitality
    -- [142035] = true, -- Ironclad
    -- [142074] = true, -- Rejuvenation
    -- [142111] = true, -- On Guard
    [160199] = true, -- Soothing Shield
    -- [160200] = true, -- Soothing Shield
    [160201] = true, -- Soothing Shield
    -- [160190] = true, -- Ward Master
    -- [160197] = true, -- Ward Master
    -- [160198] = true, -- Ward Master
    -- [160162] = true, -- Bracing Anchor
    -- [160163] = true, -- Bracing Anchor
    -- [160164] = true, -- Bracing Anchor
    -- [160165] = true, -- Bracing Anchor
    -- [160166] = true, -- Bracing Anchor
    -- [160044] = true, -- Celerity
    -- [160048] = true, -- Refreshing Stride
    -- [160052] = true, -- Refreshing Stride
    -- [160053] = true, -- Refreshing Stride
    -- [160054] = true, -- Refreshing Stride
    [160045] = true, -- Thrill of the Hunt
    [160047] = true, -- Major Expedition
    [160072] = true, -- Relentlessness
    [160074] = true, -- Major Protection
    -- [160057] = true, -- Sustained by Suffering
    -- [160065] = true, -- Pain's Refuge

    ---- OLD CHAMPION POINTS           ----
    ---- TODO: REMOVE AT SOME PT       ----
    ---- KEEP FOR NOW TO TRACK REMOVAL ----

    -- The Steed
    -- [59120] = true, -- Medium Armor Focus (The Steed)
    -- [92423] = true, -- Ironclad (The Steed)
    -- [62760] = true, -- Spell Shield (The Steed)
    -- [60384] = true, -- Resistant (The Steed)
    -- [60407] = true, -- Invigorating Bash (The Steed 10 - Invigorating Bash)
    -- [63852] = true, -- Phase (The Steed 30 - Phase)
    -- [61660] = true, -- Resilient (The Steed 75 - Resilient)
    -- [61661] = true, -- Resilient (The Steed 75 - Resilient)

    -- The Lady
    -- [60502] = true, -- Light Armor Focus (The Lady)
    -- [63850] = true, -- Thick Skinned (The Lady)
    -- [63844] = true, -- Hardy (The Lady)
    -- [63843] = true, -- Elemental Defender (The Lady)
    -- [63109] = true, -- Spell Absorption (The Lady 10 - Spell Absorption)
    -- [63110] = true,  -- Spell Absorption (The Lady 10 - Spell Absorption)
    -- [60370] = true, -- Critical Leech (The Lady 75 - Critical Leech)
    -- [60371] = true, -- Critical Leech (The Lady 75 - Critical Leech)
    -- [59286] = true, -- Unchained (The Lady 120 - Unchained)

    -- The Lord
    -- [60624] = true, -- Heavy Armor Focus (The Lord)
    -- [59948] = true, -- Bastion (The Lord)
    -- [59953] = true, -- Expert Defender (The Lord)
    -- [63851] = true, -- Quick Recovery (The Lord)
    -- [59300] = true, -- Field Physician (The Lord 10 - Field Physician)
    -- [59582] = true, -- Infusion (The Lord 30 - Infusion)
    -- [60427] = true, -- Revival (The Lord 75 - Revival)
    -- [59893] = true, -- Determination (The Lord 120 - Determination)
    -- [61015] = true, -- Determination (The Lord 120 - Determination)

    -- The Tower
    -- [58899] = true, -- Bashing Focus (The Tower)
    -- [64077] = true, -- Sprinter (The Tower)
    -- [92425] = true, -- Siphoner (The Tower)
    -- [92428] = true, -- Siphoner (The Tower)
    -- [92431] = true, -- Warlord (The Tower)
    -- [60398] = true, -- Ensnare (The Tower 10 - Ensnare)
    -- [60494] = true, -- Inspiration Boost (The Tower 30 - Inspiration Boost)
    -- [62516] = true, -- Mara's Gift (The Tower 75 - Mara's Gift)
    -- [62518] = true, -- Mara's Gift (The Tower 75 - Mara's Gift)
    -- [62274] = true, -- War Mount (The Tower 120 - War Mount)

    -- The Lover
    -- [59346] = true, -- Mooncalf (The Lover)
    -- [59577] = true, -- Arcanist (The Lover)
    -- [60374] = true, -- Healthy (The Lover)
    -- [63854] = true, -- Tenacity (The Lover)
    -- [63663] = true, -- Plentiful Harvest (The Lover 10 - Plentiful Harvest)
    -- [63875] = true, -- Synergizer (The Lover 30 - Synergizer)
    -- [63878] = true, -- Synergizer (The Lover 30 - Synergizer)
    -- [60555] = true, -- Master Gatherer (The Lover 75 - Master Gatherer)
    -- [60560] = true, -- Windrunning (The Lover 125 - Windrunning)

    -- The Shadow
    -- [59298] = true, -- Befoul (The Shadow)
    -- [61548] = true, -- Shade (The Shadow)
    -- [60649] = true, -- Shadow Ward (The Shadow)
    -- [63863] = true, -- Tumbling (The Shadow)
    -- [56630] = true, -- Fortune Seeker (The Shadow 10 - Fortune Seeker)
    -- [60501] = true, -- Merchant Favored (The Shadow 30 - Merchant Favored)
    -- [60566] = true, -- Treasure Hunter (The Shadow 75 - Treasure Hunter)
    -- [61426] = true, -- Shadowstrike (The Shadow 120 - Shadowstrike)
    -- [64244] = true, -- Shadowstrike (The Shadow 120 - Shadowstrike)
    -- [64245] = true, -- Shadowstrike (The Shadow 120 - Shadowstrike)
    -- [140520] = true, -- Shadowstrike (The Shadow 120 - Shadowstrike)
    -- [77773] = true, -- Clairvoyance Fx (The Shadow 120 - Shadowstrike)

    -- The Apprentice
    -- [63848] = true, -- Elemental Expert (The Apprentice)
    -- [61555] = true, -- Spell Erosion (The Apprentice)
    -- [61680] = true, -- Elfborn (The Apprentice)
    -- [59630] = true, -- Blessed (The Apprentice)
    -- [63150] = true, -- Vengeance (The Apprentice 10 - Vengeance)
    -- [63152] = true, -- Vengeance Count (The Apprentice 10 - Vengeance)
    -- [63151] = true, -- Vengeance (The Apprentice 10 - Vengeance)
    -- [59626] = true, -- Spell Precision (The Apprentice 30 - Spell Precision)
    -- [63111] = true, -- Arcane Well (The Apprentice 120 - Arcane Well)
    -- [63114] = true, -- Arcane Well (The Apprentice 120 - Arcane Well)
    -- [88784] = true, -- Arcane Well (The Apprentice 120 - Arcane Well)

    -- The Atronach
    -- [92424] = true, -- Physical Weapon Expert (The Atronach)
    -- [60662] = true, -- Shattering Blows (The Atronach)
    -- [60503] = true, -- Staff Expert (The Atronach)
    -- [63104] = true, -- Retaliation (The Atronach 10 - Retaliation)
    -- [63106] = true, -- Retaliation (The Atronach 10 - Retaliation)
    -- [63879] = true, -- Butcher (The Atronach 75 - Butcher)
    -- [60486] = true, -- Tactician (The Atronach 120 - Tactician)
    -- [63108] = true, -- Off-Balance (The Atronach 120 - Tactician)

    -- The Ritual
    -- [63847] = true, -- Thaumaturge (The Ritual)
    -- [59105] = true, -- Precise Strikes (The Ritual)
    -- [61546] = true, -- Piercing (The Ritual)
    -- [63868] = true, -- Mighty (The Ritual)
    -- [63099] = true, -- Opportunist (The Ritual 10 - Opportunist)
    -- [100408] = true, -- Opportunist (The Ritual 10 - Opportunist)
    -- [59418] = true, -- Perfect Strike (The Ritual 30 - Perfect Strike)

    -------------------------------------
    -- ITEMS ----------------------------
    -------------------------------------

    -------------------------------------
    -- GLYPHS
    -------------------------------------

    -- Jewelry Glyphs
    [46751] = true,  -- Increase Bash Damage (Glyph of Bashing)
    [46741] = true,  -- Increase Potion Effect (Glyph of Potion Boost)
    [46742] = true,  -- Reduce Potion Cooldown (Glyph of Potion Speed)
    [46733] = true,  -- Reduce Stamina Cost (Glyph of Reduce Feat Cost)
    [26750] = true,  -- Reduce Magicka Cost (Glyph of Reduce Spell Cost)
    [46739] = true,  -- Bracing Enchant (Glyph of Bracing)
    [140300] = true, -- Prismatic Reduced Cost (Glyph of Reduced Skill Cost)

    -- Weapon Glyphs
    [28919] = true, -- Life Drain (Glyph of Absorb Health)
    [28921] = true, -- Life Drain (Glyph of Absorb Health)
    [46743] = true, -- Absorb Magicka (Glyph of Absorb Magicka)
    [46744] = true, -- Absorb Magicka (Glyph of Absorb Magicka)
    [46746] = true, -- Absorb Stamina (Glyph of Asborb Stamina)
    [46747] = true, -- Absorb Stamina (Glyph of Asborb Stamina)
    [17906] = true, -- Crusher (Glyph of Crushing)
    [46749] = true, -- Decrease Health (Glyph of Decrease Health)
    [17895] = true, -- Fiery Weapon (Glyph of Flame)
    [17904] = true, -- Befouled Weapon (Glyph of Foulness)
    [17897] = true, -- Frozen Weapon (Glyph of Frost)
    -- [17947] = true, -- Hardening (Glyph of Hardening)
    [21578] = true, -- Hardening (Glyph of Hardening)
    [17902] = true, -- Poisoned Weapon (Glyph of Poison)
    [40337] = true, -- Prismatic Weapon (Glyph of Prismatic Onslaught)
    [17899] = true, -- Charged Weapon (Glyph of Shock)
    [17945] = true, -- Weakening (Glyph of Weakening)
    -- [17910] = true, -- Weapon Damage (Glyph of Weapon Damage)
    [21230] = true, -- Berserker (Glyph of Weapon Damage)

    -------------------------------------
    -- POTIONS
    -------------------------------------

    -- Crafted Potions (2 Traits)
    ----[64564] = true, -- Physical Resistance Potion (... of Armor)
    [79709] = true,  -- Creeping Ravage Health (... of Creeping Ravage Health)
    [79857] = true,  -- Minor Defile (... of Defile)
    [45236] = true,  -- Increase Detection (... of Detection)
    [45221] = true,  -- Restore Health (... of Health)
    [45222] = true,  -- Major Fortitude (... of Health)
    [45239] = true,  -- Unstoppable (... or Immovability)
    [45237] = true,  -- Vanish (... of Invisiblity)
    [77767] = true,  -- Clairvoyance Fx (... of Invisibility)
    [79705] = true,  -- Lingering Restore Health (... of Lingering Health)
    [45223] = true,  -- Restore Magicka (... of Magicka)
    [45224] = true,  -- Major Intellect (... of Magicka)
    [79712] = true,  -- of Protection (... of Protection)
    ----[46208] = true, -- Physical Resistance Reduction (... of Ravage Armor)
    [46111] = true,  -- Ravage Health (... of Ravage Health)
    [46113] = true,  -- Health Potion Poison (... of Ravage Health)
    [46193] = true,  -- Ravage Magicka (... of Ravage Magicka)
    [47204] = true,  -- Minor Uncertainty (... of Ravage Spell Critical)
    [46202] = true,  -- Minor Cowardice (... of Ravage Spell Power)
    ----[46206] = true, -- Spell Resistance Reduction (... of Ravage Spell Protection)
    [46199] = true,  -- Ravage Stamina (... of Ravage Stamina)
    [47203] = true,  -- Minor Enervation (... of Ravage Weapon Critical)
    [46204] = true,  -- Minor Maim (... of Ravage Weapon Power)
    [46210] = true,  -- Hindrance (... of Hindering)
    [64566] = true,  -- Major Expedtion (... of Speed)
    [64570] = true,  -- Major Prophecy (... of Spell Critical)
    [64558] = true,  -- Major Sorcery (... of Spell Power)
    ----[64562] = true, -- Spell Resistance Potion (... of Spell Protection)
    [45225] = true,  -- Restore Stamina (... of Stamina)
    [45226] = true,  -- Major Endurance (... of Stamina)
    [68565] = true,  -- Stun (... of Entrapment)
    [79848] = true,  -- Major Vitality (... of Major Vitality)
    [79844] = true,  -- Minor Vulnerability (... of Minor Vulnerability)
    [64568] = true,  -- Major Savagery (... of Weapon Critical)
    [64555] = true,  -- Major Brutality (... of Weapon Power)
    [125027] = true, -- Minor Heroism (... of Heroism)
    [140700] = true, -- of Timidity (Minor Timidity)

    -- Crafted Potions (3 Traits)
    ----[64565] = true, -- Physical Resistance Potion (... of Armor)
    [79710] = true,  -- Creeping Ravage Health (... of Creeping Ravage Health)
    [79860] = true,  -- Minor Defile (... of Defile)
    ----[45458] = true, -- Increase Detection (... of Detection)
    [45382] = true,  -- Restore Health (... of Health)
    [63670] = true,  -- Major Fortitude (... of Health)
    [45463] = true,  -- Unstoppable (... of Immovability)
    [45460] = true,  -- Vanish (... of Invisibility)
    [77766] = true,  -- Clairvoyance Fx (... of Invisibility)
    [79706] = true,  -- Lingering Restore Health (... of Linger Health)
    [45385] = true,  -- Restore Magicka (... of Magicka)
    [63676] = true,  -- Major Intellect (... of Magicka)
    [79714] = true,  -- Minor Protection (... of Protection)
    ----[46250] = true, -- Physical Resistance Reduction (... of Ravage Armor)
    [46215] = true,  -- Damage Health (... of Ravage Health)
    [46217] = true,  -- Health Potion Lingering Effect (... of Ravage Health)
    [46237] = true,  -- Ravage Magicka (... of Ravage Magicka)
    -- (no ... of Ravage Spell Critical)
    [46244] = true,  -- Minor Cowardice (... of Ravage Spell Power)
    ----[46248] = true, -- Spell Resistance Reduction (... of Ravage Spell Protection)
    [46240] = true,  -- Ravage Stamina (... of Ravage Stamina)
    [47202] = true,  -- Reduce Weapon Critical (... of Ravage Weapon Critical)
    [46246] = true,  -- Minor Maim (... of Ravage Weapon Power)
    [46252] = true,  -- Hindrance (... of Hindering)
    [64567] = true,  -- Major Expedition (... of Speed)
    [64572] = true,  -- Major Prophecy (... of Spell Critical)
    [64561] = true,  -- Major Sorcery (... of Spell Power)
    ----[64563] = true, -- Spell Resistance Potion (... of Spell Protection)
    [45388] = true,  -- Restore Stamina (... of Stamina)
    [63681] = true,  -- Major Endurance (... of Stamina)
    -- (no... of Stun)
    [79850] = true,  -- Major Vitality (... of Vitality)
    [79846] = true,  -- Minor Vulnerability (... of Minor Vulnerability)
    [64569] = true,  -- Major Savagery (... of Weapon Critical)
    [64554] = true,  -- Major Brutality (... of Weapon Power)
    [125041] = true, -- Minor Heroism (... of Heroism)
    [140701] = true, -- of Timidity (Minor Timidity)

    -- Vendor Potions + AVA Potions + Roguish Draughts
    [17302] = true,  -- Restore Health (... of Health)
    [63672] = true,  -- Major Fortitude (... of Health)
    [17323] = true,  -- Restore Magicka (... of Magicka)
    [63678] = true,  -- Major Intellect (... of Magicka)
    [17328] = true,  -- Restore Stamina (... of Stamina)
    [63683] = true,  -- Major Endurance (... of Stamina)
    [72934] = true,  -- Restore Stamina (Alliance Battle Draught)
    [72935] = true,  -- Major Endurance (Alliance Battle Draught)
    [72936] = true,  -- Major Brutality (Alliance Battle Draught)
    [137007] = true, -- Major Savagery (Alliance Battle Draugh)
    [72927] = true,  -- Restore Health (Alliance Health Draught)
    [72928] = true,  -- Major Fortitude (Alliance Health Draught)
    [72930] = true,  -- Unstoppable (Alliance Health Draught)
    [137002] = true, -- Invisibility (Alliance Health Draught)
    [137000] = true, -- Clairvoyance Fx (Alliance Health Draught)
    [72931] = true,  -- Restore Magicka (Alliance Spell Draught)
    [72932] = true,  -- Major Intellect (Alliance Spell Draught)
    [72933] = true,  -- Major Sorcery (Alliance Spell Draught)
    [137006] = true, -- Major Prophecy (Alliance Spell Draught)
    [78053] = true,  -- Restore Stamina (Roguish Stealth Draught)
    [78054] = true,  -- Major Endurance (Roguish Stealth Draught)
    [78058] = true,  -- Vanish (Roguish Stealth Draught)
    [78057] = true,  -- Clairvoyance Fx (Roguish Escape Draught)
    [78079] = true,  -- Restore Stamina (Roguish Escape Draught)
    [78080] = true,  -- Major Endurance (Roguish Escape Draught)
    [78081] = true,  -- Major Expedition (Roguish Escape Draught)

    -- Crown Store Potions
    [68401] = true, -- Restore All Resources (Crown Tri-Restoration Potion)
    [68405] = true, -- Major Fortitude (Crown Tri-Restoration Potion)
    [68407] = true, -- Restore Magicka (Crown Tri-Restoration Potion)
    [68406] = true, -- Major Intellect (Crown Tri-Restoration Potion)
    [68409] = true, -- Restore Stamina (Crown Tri-Restoration Potion)
    [68408] = true, -- Major Endurance (Crown Tri-Restoration Potion)
    [86780] = true, -- Invisibility (Crown Invisibility Potion)
    [86782] = true, -- Clairvoyance Fx (Crown Invisibility Potion)
    [86682] = true, -- Gold Coast Spellcaster Elixir (Gold Coast Spellcaster Elixir)
    [86683] = true, -- Major Intellect (Gold Coast Spellcaster Elixir)
    [86684] = true, -- Major Prophecy (Gold Coast Spellcaster Elixir)
    [86685] = true, -- Major Sorcery (Gold Coast Spellcaster Elixir)
    [86696] = true, -- Gold Coast Survivor Elixir (Gold Coast Survivor Elixir)
    [86697] = true, -- Major Fortitude (Gold Coast Survivor Elixir)
    [86698] = true, -- Unstoppable (Gold Coast Survivor Elixir)
    [86699] = true, -- Invisiblity (Gold Coast Survivor Elixir)
    [86702] = true, -- Clairvoyance Fx (Gold Coast Survivor Elixir)
    [86692] = true, -- Gold Coast Warrior Elixir (Gold Coast Warrior Elixir)
    [86693] = true, -- Major Endurance (Gold Coast Warrior Elixir)
    [86694] = true, -- Major Savagery (Gold Coast Warrior Elixir)
    [86695] = true, -- Major Brutality (Gold Coast Warrior Elixir)
    [92414] = true, -- Gold Coast Survivor Elixir (Gold Coast Swift Survivor Elixir)
    [92415] = true, -- Major Fortitude (Gold Coast Swift Survivor Elixir)
    [92418] = true, -- Major Expedition (Gold Coast Swift Survivor Elixir)
    [92416] = true, -- Unstoppable (Gold Coast Swift Survivor Elixir)

    -------------------------------------
    -- POISONS
    -------------------------------------

    -- Crafted Poisons (2 Traits)
    [79133] = true, -- Drain Health (Drain Health Poison)
    [79134] = true, -- Restore Health (Drain Health Poison)
    [79025] = true, -- Ravage Health (Damage Health Poison)
    [79137] = true, -- Drain Magicka (Drain Magicka Poison)
    [79138] = true, -- Restore Magicka (Drain Magicka Poison)
    [79037] = true, -- Ravage Magicka (Damage Magicka Poison)
    [79141] = true, -- Drain Stamina (Drain Stamina Poison)
    [79142] = true, -- Restore Stamina (Drain Stamina Poison)
    [79045] = true, -- Ravage Stamina (Damage Stamina Poison)
    ----[79284] = true, -- Spell Resistance Reduction (Ward-Draining Poison)
    ----[79285] = true, -- Spell Resistance (Ward-Draining Poison)
    ----[79087] = true, -- Spell Resistance Reduction (Breaching Poison)
    ----[79309] = true, -- Physical Resistance Reduction (Resolve-Draining Poison)
    ----[79310] = true, -- Physical Resistance (Resolve-Draining Poison)
    ----[79090] = true, -- Physical Resistance Reduction (Fracturing Poison)
    [79193] = true, -- Minor Cowardice (Sorcery-Draining Poison)
    [79221] = true, -- Minor Sorcery (Sorcery-Draining Poison)
    [79069] = true, -- Minor Cowardice (Cowardice Poison)
    [79280] = true, -- Minor Maim (Brutality-Draining Poison)
    [79281] = true, -- Minor Brutality (Brutality-Draining Poison)
    [79083] = true, -- Minor Maim (Maiming Poison)
    [79446] = true, -- Minor Uncertainty (Prophecy-Draining Poison)
    [79447] = true, -- Minor Prophecy (Prophecy-Draining Poison)
    [79117] = true, -- Minor Uncertainty (Uncertainty Poison)
    [79450] = true, -- Minor Enervation (Savagery-Draining Poison)
    [79453] = true, -- Minor Savagery (Savagery-Draining Poison)
    [79113] = true, -- Minor Enervation (Enervating Poison)
    [79457] = true, -- Immobilize (Escapist's Poison)
    [79458] = true, -- Unstoppable (Escapist's Poison)
    [79122] = true, -- Immobilize (Entrapping Poison)
    ----[79996] = true, -- Revealing Poison (Stealth-Draining Poison)
    ----[80003] = true, -- Marking Poison (Conspicuous Poison)
    [79367] = true,  -- Minor Hindrance (Speed-Draining Poison)
    [79368] = true,  -- Major Expedition (Speed-Draining Poison)
    [79094] = true,  -- Hindrance (Hindering Poison)
    [79699] = true,  -- Drain Health (Gradual Health Drain Poison)
    [79700] = true,  -- Restore Health (Gradual Health Drain Poison)
    [79707] = true,  -- Creeping Ravage Health (Gradual Ravage Health Poison)
    [79723] = true,  -- Minor Vulnerability (Protection-Reversing Poison)
    [79725] = true,  -- Minor Protection (Protection-Reversing Poison)
    [79715] = true,  -- Minor Vulnerability (Vulnerability Poison)
    [79851] = true,  -- Minor Defile (Vitality-Draining Poison)
    [79852] = true,  -- Minor Vitality (Vitality-Draining Poison)
    [79861] = true,  -- Minor Defile (Defiling Poison)
    [125203] = true, -- Trauma (Traumatic Poison)
    [125204] = true, -- Minor Heroism (Traumatic Poison)
    [134149] = true, -- Minor Timidity (Timidity Poison) DEBUFF

    -- Crafted Poisons (3 Traits)
    [79135] = true, -- Drain Health (Drain Health Poison)
    [79136] = true, -- Restore Health (Drain Health Poison)
    [78922] = true, -- Ravage Health (Damage Health Poison)
    [82668] = true, -- Ravage Health (Damage Health Poison)
    [79139] = true, -- Drain Magicka (Drain Magicka Poison)
    [79140] = true, -- Restore Magicka (Drain Magicka Poison)
    [79044] = true, -- Ravage Magicka (Damage Magicka Poison)
    [79143] = true, -- Drain Stamina (Drain Stamina Poison)
    [79144] = true, -- Restore Stamina (Drain Stamina Poison)
    [79046] = true, -- Ravage Stamina (Damage Stamina Poison)
    ----[79306] = true, -- Spell Resistance Reduction (Ward-Draining Poison)
    ----[79307] = true, -- Spell Resistance (Ward-Draining Poison)
    ----[79086] = true, -- Spell Resistance Reduction (Breaching Poison)
    ----[79311] = true, -- Physical Resistance Reduction (Resolve-Draining Poison)
    ----[79312] = true, -- Physical Resistance (Resolve-Draining Poison)
    ----[79091] = true, -- Physical Resistance Reduction (Fracturing Poison)
    [79278] = true, -- Drain Spell Power (Sorcery-Draining Poison)
    [79279] = true, -- Minor Sorcery (Sorcery-Draining Poison)
    [79082] = true, -- Minor Cowardice (Cowardice Poison)
    [79282] = true, -- Minor Maim (Brutality-Draining Poison)
    [79283] = true, -- Minor Brutality (Brutality-Draining Poison)
    [79085] = true, -- Minor Maim (Maiming Poison)
    [79448] = true, -- Drain Spell Crit (Prophecy-Draining Poison)
    [79449] = true, -- Minor Prophecy (Prophecy-Draining Poison)
    -- (no Uncertainty Poison)
    [79454] = true, -- Minor Enervation (Savagery-Draining Poison)
    [79455] = true, -- Minor Savagery (Savagery-Draining Poison)
    [79116] = true, -- Minor Enervation (Enervating Poison)
    [79459] = true, -- Immobilize (Escapist's Poison)
    [79460] = true, -- Unstoppable (Escapist's Poison)
    -- (no Entrapping Poison)
    ----[80002] = true, -- Revealing Poison (Stealth-Draining Poison)
    ----[80004] = true, -- Marking Poison (Conspicuous Poison)
    [79369] = true,  -- Minor Hindrance (Speed-Draining Poison)
    [79370] = true,  -- Major Expedition (Speed-Draining Poison)
    [79102] = true,  -- Minor Hindrance (Hindering Poison)
    [79701] = true,  --  Creeping Drain Health (Gradual Health Drain Poison)
    [79702] = true,  -- Lingering Restore Health (Gradual Health Drain Poison)
    [79708] = true,  -- Creeping Ravage Health (Gradual Ravage Health Poison)
    [79726] = true,  -- Minor Vulnerability (Protection-Reversing Poison)
    [79727] = true,  -- Minor Protection (Protection-Reversing Poison)
    [79720] = true,  -- Minor Vulnerability (Vulnerability Poison)
    [79854] = true,  -- Minor Defile (Vitality-Draining Poison)
    [79855] = true,  -- Minor Vitality (Vitality-Draining Poison)
    [79862] = true,  -- Minor Defile (Defiling Poison)
    [125205] = true, -- Trauma (Traumatic Poison)
    [125206] = true, -- Minor Heroism (Traumatic Poison)
    [134150] = true, -- Minor Timidity (Timidity Poison) DEBUFF

    -- Vendor Poisons
    [81553] = true, -- Ravage Health (Cloudy Damage Health Poison)
    [81551] = true, -- Creeping Ravage Health (Cloudy Gradual Ravage Health Poison)
    [81552] = true, -- Creeping Ravage Health (Cloudy Gradual Ravage Health Poison)
    [81554] = true, -- Hindrance (Cloudy Hindering Poison)

    -- Crown Poisons
    [88476] = true, -- Creeping Ravage Health (Gold Coast Debilitating Poison)
    [88477] = true, -- Hindrance (Gold Coast Debilitating Poison)
    [88471] = true, -- Drain Magicka (Gold Coast Draining Poison)
    [88475] = true, -- Drain Stamina (Gold Coast Draining Poison)
    [88473] = true, -- Restore Magicka (Gold Coast Draining Poison)
    [88474] = true, -- Restore Stamina (Gold Coast Draining Poison)
    [88469] = true, -- Minor Maim (Gold Coast Enfeebling Poison)
    [88470] = true, -- Minor Defile (Gold Coast Enfeebling Poison)
    [81274] = true, -- Ravage Health (Crown Lethal Poison)
    [81275] = true, -- Creeping Ravage Health (Crown Lethal Poison)
    [88462] = true, -- Immobilize (Gold Coast Trapping Poison)
    [88463] = true, -- Hindrance (Gold Coast Trapping Poison)

    -------------------------------------
    -- FOOD & DRINK
    -------------------------------------

    -- General Events
    [47983] = true, -- Drink Bonus Duration
    [47984] = true, -- Food Bonus Duration
    [60315] = true, -- Eating Meal

    -- Crafted Food
    [61259] = true,  -- Health Food (Green)
    [61260] = true,  -- Magicka Food (Green)
    [61261] = true,  -- Stamina Food (Green)
    [61294] = true,  -- Magicka + Stamina Food (Blue)
    [61295] = true,  -- Magicka Consumable
    [61255] = true,  -- Health + Stamina Food (Blue)
    [61256] = true,  -- Magicka Consumable
    [61257] = true,  -- Health + Magicka Food (Blue)
    [61258] = true,  -- Magicka Consumable
    [61218] = true,  -- Triple Food (Purple)
    [61219] = true,  -- Magicka Consumable
    [61220] = true,  -- Magicka Consumable
    [73540] = true,  -- Unique Food: H, S Reg, Small B
    [72819] = true,  -- Orzorga's Tripe Trifle Pocket (Blue)
    [72820] = true,  -- Magicka Consumable
    [73551] = true,  -- Unique Food: H, H Reg Pie
    [72822] = true,  -- Orzorga's Blood Price Pie (Blue)
    [72823] = true,  -- Magicka Consumable
    [73553] = true,  -- Unique Food: H, All Reg, Meal
    [72824] = true,  -- Orzorga's Smoked Bear Haunch (Gold)
    [72825] = true,  -- Magicka Consumable
    [72826] = true,  -- Magicka Consumable
    [72827] = true,  -- Magicka Consumable
    [100485] = true, -- Unique Food: Reg H/S, Stew
    [100502] = true, -- Deregulated Mushroom Stew
    [100503] = true, -- Magicka Consumable
    [100487] = true, -- Unique Food: Reg H/M, Max H/M
    [100498] = true, -- Clockwork Citrus Filet
    [100499] = true, -- Magicka Consumable
    [100500] = true, -- Magicka Consumable
    [100501] = true, -- Magicka Consumable
    [107793] = true, -- Unique Food: Reg H/M, Max H/M
    [107789] = true, -- Artaeum Takeaway Broth
    [107790] = true, -- Magicka Consumable
    [107791] = true, -- Magicka Consumable
    [107792] = true, -- Magicka Consumable
    [107794] = true, -- Unique Food: Max H/M, Fish Lur
    [107748] = true, -- Lure Allure
    [107749] = true, -- Increase Magicka

    -- Crafted Drink
    [61365] = true,  -- Drink: H, Flagon
    [61322] = true,  -- Health Drink (Green)
    [61323] = true,  -- Well Fed
    [61367] = true,  -- Drink: M, Flagon
    [61325] = true,  -- Magicka Drink (Green)
    [61326] = true,  -- Well Fed
    [61368] = true,  -- Drink: S, Flagon
    [61328] = true,  -- Stamina Drink (Green)
    [61329] = true,  -- Well Fed
    [61361] = true,  -- Drink: MS, Flagon
    [61345] = true,  -- Magicka + Stamina Drink (Blue)
    [61346] = true,  -- Well Fed
    [61348] = true,  -- Well Fed
    [61358] = true,  -- Drink: HS, Flagon
    [61340] = true,  -- Health + Stamina Drink (Blue)
    [61341] = true,  -- Well Fed
    [61344] = true,  -- Well Fed
    [61359] = true,  -- Drink: HM, Flagon
    [61335] = true,  -- Health + Magicka Drink (Blue)
    [61336] = true,  -- Well Fed
    [61339] = true,  -- Well Fed
    [61357] = true,  -- Drink: HSM, Flagon
    [61350] = true,  -- Triple Drink (Purple)
    [61351] = true,  -- Well Fed: Health Regen
    [61354] = true,  -- Well Fed: Magicka Regen
    [61355] = true,  -- Well Fed: Stamina Regen
    [73539] = true,  -- Unique Drink: Max H, M, Flagon
    [72816] = true,  -- Orzorga's Red Frothgar (Blue)
    [72817] = true,  -- Magicka Consumable
    [100483] = true, -- Unique Drink: All Max & Detect
    [100488] = true, -- Spring-Loaded Infusion
    [100490] = true, -- Magicka Consumable
    [100489] = true, -- Stamina Consumable

    -- Crafted Seasonal Food
    [84681] = true,  -- Crisp and Crunchy Pumpkin Skewer (Blue)
    [84682] = true,  -- Increase Stamina
    [84683] = true,  -- Witchfest Food: M, S, Meal
    [84709] = true,  -- Crunchy Spider Skewer (Blue)
    [84710] = true,  -- Increase Stamina Regen
    [84711] = true,  -- Witchfest Food: Max M, Reg S,
    [84725] = true,  -- Frosted Brains (Blue)
    [84728] = true,  -- Increase Health Regen
    [84729] = true,  -- Witchfest Food: M, H Reg Meal
    [84679] = true,  -- Witchfest Food: M, Meal
    [84678] = true,  -- Sweet Sanguine Apples (Green)
    [86788] = true,  -- New Life Food: H, Pie
    [86789] = true,  -- Alcaire Festival Sword-Pie (Green)
    [86749] = true,  -- Jagga-Drenched "Mud Ball" (Blue)
    [86750] = true,  -- Increase Stamina
    [86748] = true,  -- New Life Food: Max M, S
    [86673] = true,  -- Lava Foot Soup-and-Saltrice (Blue)
    [86674] = true,  -- Increase Stamina Recovery
    [86669] = true,  -- Newlife Food: Reg S, Max S, So
    [86785] = true,  -- New Life Food: M, Soup
    [86786] = true,  -- New Life Food: S, Sm Bread
    [86787] = true,  -- Rajhin's Sugar Claws (Green)
    [89955] = true,  -- Candied Jester's Coins (Blue)
    [89954] = true,  -- Jesters Food: Max S, Reg M
    [89956] = true,  -- Increase Max Magicka
    [89971] = true,  -- Jewels of Misrule (Purple)
    [89953] = true,  -- Jesters Food: Max H, Reg MS
    [89972] = true,  -- Increase Magicka Recovery
    [88973] = true,  -- Increase Health
    -- [89956] = true,  -- Princess' Delight (Green)
    [89921] = true,  -- Jesters Food: Butterflies
    [89919] = true,  -- Jesters Food: Max M
    [127596] = true, -- Bewitched Sugar Skulls
    [127595] = true, -- Witchfest Food: Max All, H Reg
    [127709] = true, -- Magicka Consumable
    [127602] = true, -- Increase Health
    [127708] = true, -- Magicka Consumable

    -- Crafted Seasonal Drink
    [84700] = true,  -- Bowl of "Peeled Eyeballs" (Blue)
    [84701] = true,  -- Increase Health Regen
    [84702] = true,  -- Witchfest Drink: M, H, Flagon
    [84735] = true,  -- Purifying Bloody Mara (Gold)
    [84736] = true,  -- Increase Health
    [84737] = true,  -- Witchfest Drink: Max MH, Flago
    [84720] = true,  -- Ghastly Eye Bowl (Blue)
    [84722] = true,  -- Increase Magicka Regen
    [84723] = true,  -- Witchfest Food: Max M, Reg M,
    [84707] = true,  -- Witchfest Drink: HMS, Flagon
    [84704] = true,  -- Witchmother's Party Punch (Purple)
    [84705] = true,  -- Increase Health Regen
    [84706] = true,  -- Increase Health Regen
    [84731] = true,  -- Witchmother's Potent Brew (Purple)
    [84734] = true,  -- Witchfest Food: Max HM, Reg M,
    [84732] = true,  -- Increase Health Regen
    [84733] = true,  -- Increase Health Regen
    [86677] = true,  -- Bergama Warning Fire (Blue)
    [86676] = true,  -- Newlife Drink: Reg H, Max S, F
    [86678] = true,  -- Increase Health Recovery
    [86746] = true,  -- Betnikh Twice-Spiked Ale (Blue)
    [86745] = true,  -- Newlife Drink: Reg H, M, Belch
    [86747] = true,  -- Increase Health Recovery
    [86559] = true,  -- Hissmir Fish-Eye Rye (Gold)
    [86558] = true,  -- Newlife Drink: Reg MS, Flagon
    [86560] = true,  -- Increase Stamina Recovery
    [86790] = true,  -- New Life Drink: S, Flagon
    [86791] = true,  -- Snow Bear Glow-Wine (Green)
    [89957] = true,  -- Dubious Camoran Throne (Purple)
    [89939] = true,  -- Jesters Food: Max HS, Reg S
    [89958] = true,  -- Increase Stamina
    [89959] = true,  -- Increase Health
    [127531] = true, -- Corrupting Bloody Mara
    [127530] = true, -- Witchfest Drink: Max MH, Flago
    [127537] = true, -- Increase Health
    [127619] = true, -- Increase Health
    [127572] = true, -- Pack Leader's Bone Broth
    [127571] = true, -- Witchfest Drink: Max SH, Wolf Time
    [127736] = true, -- Increase Health
    [127578] = true, -- Increase Health

    -- Vendor Food & Drink
    [66551] = true, -- Vendor Health Food (White)
    [66568] = true, -- Vendor Magicka Food (White)
    [66576] = true, -- Vendor Stamina Food (White)
    [66589] = true, -- Drink: H, Flagon
    [66586] = true, -- Vendor Health Drink (White)
    [66588] = true, -- Well Fed
    [66593] = true, -- Drink: M, Flagon
    [66590] = true, -- Vendor Magicka Drink (White)
    [66592] = true, -- Well Fed
    [66597] = true, -- Drink: S, Flagon
    [66594] = true, -- Vendor Stamina Drink (White)
    [66596] = true, -- Well Fed

    -- AVA Food & Drink
    [72963] = true, -- Alli-Food: S, M, SmBread
    [72961] = true, -- Cyrodilic Field Bar (White)
    [72962] = true, -- Increase Max Health
    [72952] = true, -- Alli-Food: H, S, SmBread
    [72956] = true, -- Cyrodilic Field Tack (White)
    [72957] = true, -- Increase Max Health
    [72958] = true, -- Alli-Food: H, M, SmBread
    [72959] = true, -- Cyrodilic Field Treat (White)
    [72960] = true, -- Increase Max Health
    [72975] = true, -- Alli-Drink: M S, Flagon
    [72971] = true, -- Cyrodilic Field Tonic (White)
    [72972] = true, -- Well Fed
    [72973] = true, -- Well Fed
    [72964] = true, -- Alli-Drink: H S, Flagon
    [72965] = true, -- Cyrodilic Field Brew (White)
    [72966] = true, -- Well Fed
    [72967] = true, -- Well Fed
    [72974] = true, -- Alli-Drink: H M, Flagon
    [72968] = true, -- Cyrodilic Field Tea (White)
    [72969] = true, -- Well Fed
    [72970] = true, -- Well Fed

    -- Crown Food & Drink
    [85487] = true, -- _CRWN LC FOOD: HSM
    [85484] = true, -- Crown Crate Fortifying Meal
    [85485] = true, -- Increase Max Stamina
    [85486] = true, -- Increase Max Magicka
    [68414] = true, -- _CRWN Food: HSM, Meal
    [68411] = true, -- Crown Fortifying Meal
    [68412] = true, -- Increase Max Stamina
    [68413] = true, -- Increase Max Magicka
    [85497] = true, -- Crown Crate Refreshing Drink
    [85498] = true, -- Well Fed
    [85499] = true, -- Well Fed
    [85500] = true, -- Well Fed
    [68416] = true, -- Crown Refreshing Drink
    [68418] = true, -- Well Fed
    [68420] = true, -- Well Fed
    [68422] = true, -- Well Fed
    [92435] = true, -- Crown Combat Mystic's Stew
    [92434] = true, -- Increase Maximum Health and Ma
    [92437] = true, -- Increase Health
    [92474] = true, -- Crown Vigorous Ragout
    [92473] = true, -- Increase Maximum Health and St
    [92477] = true, -- Increase Health
    [92433] = true, -- Crown Stout Magic Liqueur
    [92432] = true, -- Crown Drink: M, H, Flagon
    [92436] = true, -- Increase Health Regen
    [92476] = true, -- Crown Vigorous Tincture
    [92475] = true, -- Crown Drink: M, H, Flagon
    [92478] = true, -- Increase Health Regen

    -- Food Eating Animations
    [61221] = true, -- Food: HSM, Meal
    [61246] = true, -- Food: HSM, Soupl
    [61252] = true, -- Food: HSM, Small Bread
    [61253] = true, -- Food: HSM, Meat
    [61264] = true, -- Food: HS, Meal
    [61265] = true, -- Food: HS, Soupl
    [61276] = true, -- Food: HS, Bread
    [61277] = true, -- Food: HS, SmBread
    [61278] = true, -- Food: HS, Meat
    [61287] = true, -- Food: HM, Meal
    [61288] = true, -- Food: HM, Soup
    [61290] = true, -- Food: HM, SmBread
    [61291] = true, -- Food: HM, Meat
    [61293] = true, -- Food: MS, Meal
    [61296] = true, -- Food: MS, Soup
    [61297] = true, -- Food: MS, Bread
    [61298] = true, -- Food: MS, SmBread
    [61301] = true, -- Food: H, Meal
    [61302] = true, -- Food: H, Soup
    -- [61303] = true, -- Food: H, Bread -- Probably Unused
    [61304] = true, -- Food: H, SmBread
    [61305] = true, -- Food: H, Meat
    [61307] = true, -- Food: M, Meal
    [61308] = true, -- FooD: M, Soup
    [61309] = true, -- Food: M, Bread
    [61310] = true, -- Food: M, SmBread
    [61313] = true, -- Food: S, Meal
    [61314] = true, -- Food: S, Soup
    [61315] = true, -- Food: S, Bread
    [61316] = true, -- Food: S, SmBread
    [65523] = true, -- Food: M, Pie
    [65528] = true, -- Food: H, Pie
    [65534] = true, -- Food: HM, Pie
    [65535] = true, -- Food: HS, Pie
    [65536] = true, -- Food: HSM, Pie
    [66550] = true, -- Food: H, Meal
    [66565] = true, -- Food: H, SmBread
    -- [66566] = true, -- Food: H, Meat -- Probably Unused
    [66569] = true, -- Food: M, Meal
    [66570] = true, -- Food: M, Soup
    -- [66572] = true, -- Food: M, SmBread -- Probably Unused
    [66577] = true, -- Food: S, Meal
    [66578] = true, -- Food: S, Soup
    -- [66580] = true, -- Food: S, SmBread -- Probably Unused
    -- [66584] = true, -- Food: M, Pie -- Probably Unused
    -- [66585] = true, -- Food: H, Pie -- Probably Unused

    -------------------------------------
    -- Experience Consumables
    -------------------------------------

    -- Experience Bonuses
    [64210] = true, -- Increased Experience (Psijic Ambrosia)
    [89683] = true, -- Increased Experience (Aetherial Ambrosia)
    [88445] = true, -- Increasde Experience (Mythic Aetherial Ambrosia)
    [66776] = true, -- Increased Experience (Crown Experience Scroll)
    [85501] = true, -- Increased Experience (Crown Crate Experience Scroll)
    [85502] = true, -- Increased Experience (Major Crown Crate Experience Scroll)
    [85503] = true, -- Increased Experience (Grand Crown Crate Experience Scroll)

    -- Alliance War Bonuses
    [147466] = true, -- Alliance Skill Gain (Alliance War Skill Line Scroll)
    [137733] = true, -- Alliance Skill Gain (Alliance War Skill Line Scroll, Major)
    [147467] = true, -- Alliance Skill Gain (Alliance War Skill Line Scroll, Grand)
    [147687] = true, -- Alliance Skill Gain 50% Boost (Colovian War Torte)
    [147733] = true, -- Alliance Skill Gain 100% Boost (Molten War Torte)
    [147734] = true, -- Alliance Skill Gain 100% Boost (White-Gold War Torte)

    -------------------------------------
    -- Research Scrolls
    -------------------------------------

    -- Vendor
    [95149] = true,  -- Research Scroll Blacksmithing (Research Scroll, Blacksmithing, 1 Day)
    [95147] = true,  -- Research Scroll Clothing 1day (Research Scroll, Clothing, 1 Day)
    [106557] = true, -- Research Scroll Jewelry Crafti (Research Scroll, Jewelry Crafting, 1 Day)
    [95148] = true,  -- Research Scroll Woodworking 1d (Research Scroll, Woodworking, 1 Day)

    -- Crown
    [92871] = true,  -- Instant Blacksmithing Research (Research Scroll Blacksmithing)
    [92938] = true,  -- Instant Blacksmithing Research, Grand (Research Scroll Blacksmithing)
    [92940] = true,  -- Instant Blacksmithing Research, Major (Research Scroll Blacksmithing)
    [92942] = true,  -- Instant Clothing Research (Research Scroll 1 Day)
    [92944] = true,  -- Instant Clothing Research , Grand (Research Scroll Clothing 15day)
    [92947] = true,  -- Instant Clothing Research , Major (Research Scroll Clothing 7day)
    [107848] = true, -- Instant Jewelry Crafting Research (Research Scroll Jewelry Crafti)
    [107853] = true, -- Instant Jewelry Crafting Research, Grand (Research Scroll Jewelry Crafti)
    [107851] = true, -- Instant Jewelry Crafting Research, Major (Research Scroll Jewelry Crafti)
    [92950] = true,  -- Instant Woodworking Research (Research Scroll Woodworking 1)
    [92952] = true,  -- Instant Woodworking Research, Grand (Research Scroll Woodworking 15)
    [92954] = true,  -- Instant Woodworking Research, Major (Research Scroll Woodworking 7d)
    [92960] = true,  -- Research Scroll All 1 Day (Instant All Research)

    -------------------------------------
    -- HOUSING ITEMS
    -------------------------------------

    -- Target Dummy
    [89978] = true, -- Target Skeleton (Target Dummy)
    [89977] = true, -- Target Skeleton (Target Dummy)
    -- [10298] = true, -- Boss (Target Dummy)
    -- [15954] = true, -- Boss (Target Dummy)

    -- Attunable Crafting Station
    [206063] = true, -- CreateAttunableStation (Attunable Crafting Station)

    -------------------------------------
    -- TARGET IRON ATRONACH, TRIAL
    -------------------------------------

    -- Debuffs
    [120010] = true, -- Major Breach (Target Iron Atronach, Trial)
    [120019] = true, -- Minor Breach (Target Iron Atronach, Trial)
    [148976] = true, -- Major Vulnerability (Target Iron Atronach, Trial)
    [120030] = true, -- Minor Vulnerability (Target Iron Atronach, Trial)
    [148977] = true, -- Minor Brittle (Target Iron Atronach, Trial)
    [149012] = true, -- Minor Magickasteal (Target Iron Atronach, Trial)
    [120016] = true, -- Joe Buff Granter (Target Iron Atronach, Trial)
    [120007] = true, -- Crusher (Target Iron Atronach, Trial)
    [120011] = true, -- Engulfing Flames (Target Iron Atronach, Trial)
    [120018] = true, -- Roar of Alkosh (Target Iron Atronach, Trial)
    [120014] = true, -- Off Balance (Target Iron Atronach, Trial)

    -- Buffs
    [120017] = true, -- Minor Sorcery (Target Iron Atronach, Trial)
    [120023] = true, -- Minor Brutality (Target Iron Atronach, Trial)
    [120028] = true, -- Minor Prophecy (Target Iron Atronach, Trial)
    [120029] = true, -- Minor Savagery (Target Iron Atronach, Trial)
    [120008] = true, -- Minor Berserk (Target Iron Atronach, Trial)
    [120015] = true, -- Major Courage (Target Iron Atronach, Trial)
    [120020] = true, -- Minor Toughness (Target Iron Atronach, Trial)
    [120021] = true, -- Aggressive Horn (Target Iron Atronach, Trial)
    [120025] = true, -- Aggressive Horn (Target Iron Atronach, Trial)
    [120013] = true, -- Major Force (Target Iron Atronach, Trial)
    [120024] = true, -- Worm's Raiment (Target Iron Atronach, Trial)
    [120026] = true, -- Hircine's Veneer (Target Iron Atronach, Trial)

    -- Synergy
    [121572] = true, -- Spear Shards (Target Iron Atronach, Trial)
    [121628] = true, -- Spear Shards (Target Iron Atronach, Trial)
    [121629] = true, -- Spear Shards (Target Iron Atronach, Trial)
    [121630] = true, -- Spear Shards (Target Iron Atronach, Trial)

    -------------------------------------
    -- MISC ITEMS
    -------------------------------------

    -- Item Combination
    [88449] = true,  -- Create Super Psijic Ambrosia (Aetheric Cipher)
    [88451] = true,  -- 88449 Stun (Aetheric Cipher)

    [148050] = true, -- Alliance Breton Terrier (Breton Terrier Mammoth Bone)
    [148052] = true, -- 68235 Stun (Breton Terrier Mammoth Bone)

    [147793] = true, -- Create 100% AvA Skill Boost R (Chef Arquitius's Torte Dissertation)
    [147795] = true, -- 88449 Stun (Chef Arquitius's Torte Dissertation)
    [147841] = true, -- Create 150% AvA Skill Boost R (Chef Arquitius's Lost Thesis)
    [147850] = true, -- 88449 Stun (Chef Arquitius's Lost Thesis)

    [117532] = 5000, -- 68235 Stun (Guar Stomp Elucidating Hand-Sculpture)
    [117558] = 5000, -- 68235 Stun (Guar Stomp History in Street Theatre)
    [117554] = 5000, -- 68235 Stun (Guar Stomp Illustrated Reports)
    [117550] = 5000, -- 68235 Stun (Guar Stomp Noise Reports)
    [117545] = 5000, -- 68235 Stun (Guar Stomp Rehearsal Tuning Fork)
    [117562] = 5000, -- 68235 Stun (Guar Stomp Skeletal Reconstruction)
    [117541] = 5000, -- 68235 Stun (Guar Stomp Steps-Practice Rug)

    [70582] = true,  -- Roll 1d1000 (Merethic Resorative Resin)
    [70584] = true,  -- 68235 Stun (Merethic Restorative Resin)

    [123110] = true, -- 68235 Stun (Mummified Alfiq Parts)

    [123115] = true, -- 68235 Stun (Plague-Drenched Fabric)

    [68259] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment I)
    [68263] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment II)
    [68267] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment III)
    [68271] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment IV)
    [68275] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment V)
    [68279] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment VI)
    [68283] = true,  -- 68235 Stun (Psijic Ambrosia Recipe, Fragment VII)

    [140542] = true, -- Stone Warrior Target Dummy (Stone Husk Fragment)
    [140544] = true, -- 68235 Stun (Stone Husk Fragment)

    [111141] = true, -- 68235 Stun (Swamp Jelly Carrying Jar)
    [111129] = true, -- 68235 Stun (Swamp Jelly Fine-Mesh Net)
    [111153] = true, -- 68235 Stun (Swamp Jelly Hunter's Lense)
    [111133] = true, -- 68235 Stun (Swamp Jelly Luminous Fishmeal)
    [111137] = true, -- 68235 Stun (Swamp Jelly Luring Flute)
    [111149] = true, -- 68235 Stun (Swamp Jelly Moss Bedding)
    [111145] = true, -- 68235 Stun (Swamp Jelly Spawning Mud)

    [110871] = true, -- Roll 1d10000 (Welkynar Binding)
    [110890] = true, -- 68235 Stun (Welkynar Binding)

    -- Collectible Fragment Combination
    [151843] = true, -- 68235 Stun (Deadlands Firewalker)

    [113432] = true, -- 68235 Stun (Nascent Indrik)
    [115046] = true, -- 68235 Stun (Nascent Indrik)

    [131536] = true, -- Generic Stun & Combine (Sovereign Sow)

    [130394] = true, -- 68235 Stun (Spectral Indrik)

    [148079] = true, -- 68235 Stun (Unstable Morpholith)
    [148080] = true, -- 68235 Stun (Unstable Morpholith)

    -- Item Combination - Arena Gladiator's Proofs
    [111188] = true, -- Arena Gladiator Costume (Arena Gladiator's Exultation)
    [111190] = true, -- 68235 Stun (Arena Gladiator's Exultation)

    [115062] = true, -- Arena Gladiator Emote (Arena Gladiator's Mockery)
    [115064] = true, -- 68235 Stun (Arena Gladiator's Mockery)

    [106173] = true, -- Arena Gladiator Helm (Arena Gladiator's Recognition)
    [106174] = true, -- 68235 Stun (Arena Gladiator's Recognition)

    [116414] = true, -- Arena Gladiator Pet (Arena Gladiator's Roar)
    [116416] = true, -- 68235 Stun (Arena Gladiator's Roar)

    [134882] = true, -- Knights of the Circle Weapon Style Page (Knight's Rebuke)
    [134883] = true, -- 68235 Stun (Knight's Rebuke)

    [134850] = true, -- Knights of the Circle Armor Style Page (Knight's Resolve)
    [134851] = true, -- 68235 Stun (Knight's Resolve)

    [140620] = true, -- Reach-Mage Ceremonial Skullcap (Reach-Mage's Ferocity)
    [140622] = true, -- 68235 Stun (Reach-Mage's Ferocity)

    [124622] = true, -- Alliance Standard-Bearer Emote (Alliance Standard-Bearer's License)
    [124624] = true, -- 68235 Stun (Alliance Standard-Bearer's License)

    -- Item Combination - Siege of Cyrodiil Merits
    -- [148419] = true, -- Reachman Emote (Siege of Cyrodiil Commendation)
    -- [148421] = true, -- 68235 Stun (Siege of Cyrodiil Commendation)

    -- [145214] = true, -- Siegemaster Costume (Siege of Cyrodiil Distinction)
    -- [145216] = true, -- 68235 Stun (Siege of Cyrodiil Distinction)

    -- [124788] = true, -- Arena Gladiator Helm (Siege of Cyrodiil Recognition)
    -- [124789] = true, -- 68235 Stun (Siege of Cyrodiil Recognition)

    -- [126708] = true, -- Siegemaster Costume (Siege of Cyrodiil Recommendation)
    -- [126710] = true, -- 68235 Stun (Siege of Cyrodiil Recommendation)

    -- Crown Respec Scrolls
    [67049] = true, -- _CRWN Respec Attriutes (Attribute Respecification Scroll)

    -- Glenmoril Wyrd Treasure Maps
    [128186] = true, -- Glenmoril Wyrd Treasure Map: Alik'r
    [128258] = true, -- Glenmoril Wyrd Treasure Map: Auridon
    [128264] = true, -- Glenmoril Wyrd Treasure Map: Bangkorai
    [128274] = true, -- Glenmoril Wyrd Treasure Map: Eastmarch
    [128266] = true, -- Glenmoril Wyrd Treasure Map: Glenumbra
    [128351] = true, -- Glenmoril Wyrd Treasure Map: Malabal Tor
    [128356] = true, -- Glenmoril Wyrd Treasure Map: Reaper's March
    [128362] = true, -- Glenmoril Wyrd Treasure Map: Rivenspire
    [128367] = true, -- Glenmoril Wyrd Treasure Map: Shadowfen
    [128373] = true, -- Glenmoril Wyrd Treasure Map: Stonefalls

    -- Key Fragments
    [65704] = true, -- Take key (Bone Shard Trophy Vault)
    [65947] = true, -- Tooth Key (Bone Shard Trophy Vault)
    [67824] = true, -- Take teeth (Monstrous Tooth Trophy Vault)
    [67825] = true, -- Tooth key (Monstrous Tooth Trophy Vault)
    [67018] = true, -- Take key (Clawed Trophy Vault)
    [67019] = true, -- Tiny Claw Key (Clawed Trophy Vault)
    [67033] = true, -- Take dark ether (Ethereal Trophy Vault)
    [67034] = true, -- Dark Ether Key (Ethereal Trophy Vault)
    [67798] = true, -- Take key (Planar Armor Trophy Vault)
    [67799] = true, -- Tiny Claw Key (Planar Armor Trophy Vault)
    [67709] = true, -- Take marks (Legionary Trophy Vault)
    [67713] = true, -- Mark Key (Legionary Trophy Vault)
    [70300] = true, -- Create Key (Daedric Embers Trophy Vault)
    [70301] = true, -- Create Key (Daedric Embers Trophy Vault)
    [70281] = true, -- Create Key (Daedric Shackle Vault)
    [70283] = true, -- Create Key (Daedric Shackle Vault)

    -- PTS Items
    [81736] = true,  -- Donolon's Blue Recipe Book (Recipe: Donolon's Blue Recipe Book)
    [81735] = true,  -- Donolon's Green Recipe Book (Recipe: Donolon's Green Recipe Book)
    [95397] = true,  -- Donolon's Holiday Recipe Book (Recipe: Donolon's Holiday Recipe Book)
    [81737] = true,  -- Donolon's Rare Recipe Book (Recipe: Donolon's Rare Recipe Book)
    [89338] = true,  -- Exquisite Furniture Tome (ALL Furniture Plan Book)
    [115175] = true, -- Murkmire Furniture Tome (Murkmire Furniture Plan Book)
    [157127] = true, -- Companion Maxer (Companion Booster)
    [87282] = true,  -- Vampire Maxer (Vampire Maxer)
    [87286] = true,  -- Werewolf Maxer (Werewolf Maxer)
    [66704] = true,  -- _CRWN Remove Vamp/Werewolf (Cleansing Ritual)
    [66705] = true,  -- _CRWN Remove Vamp/Werewolf (Cleansing Ritual)
    [66706] = true,  -- _CRWN Remove Vamp/Werewolf (Cleansing Ritual)

    -- Other Items
    [59581] = true, -- Clickable Eat Food (Spoiled Food)
    [63427] = true, -- Clean Fish (Fish - Any Type)
    [78052] = true, -- Minor Pardon (Counterfeit Pardon Edict)
    [76350] = true, -- Moderate Pardon (Leniency Edict)
    [76349] = true, -- Full Pardon (Grand Amnesty Edict)
    [68203] = true, -- Riding Lesson: Carry Capacity (Crown Lesson: Riding Capacity)
    [68356] = true, -- Riding Carry Track (Crown Lesson: Riding Capacity)
    [68533] = true, -- Carry Capacity Announcement Tr (Crown Lesson: Riding Capacity)
    [68201] = true, -- Riding Lesson: Speed (Crown Lesson: Riding Speed)
    [68472] = true, -- Riding Speed Tracking (Crown Lesson: Riding Speed)
    [68485] = true, -- Speed Announcement Tracker (Crown Lesson: Riding Speed)
    [68202] = true, -- Riding Lesson: Stamina(Crown Lesson: Riding Stamina)
    [68321] = true, -- Riding Stamina Tracking(Crown Lesson: Riding Stamina)
    [68528] = true, -- Stamina Announcement Tracker (Crown Lesson: Riding Stamina)
    [69293] = true, -- Sigil of Imperial Retreat (Sigil of Imperial Retreat)
    [47270] = true, -- Ritual of Mara (Pledge of Mara)

    -- Seasonal Event Items
    [86792] = true,  -- Eating (High Hrothgar Festival Mints)
    [86794] = true,  -- Very Cold (High Hrothgar Festival Mints)

    [86739] = true,  -- Drinking (Sailor's Warning Festival Grog)
    [86740] = true,  -- Very Drunk (Sailor's Warning Festival Grog)

    [87964] = true,  -- Jester's Festival Illusion Daz (Sparkwreath Dazzler)
    [87965] = true,  -- Jester's Festival Illusion Daz (Plume Dazzler)
    [87966] = true,  -- Jester's Festival Illusion Daz (Spiral Dazzler)
    [88374] = true,  -- Jester's Festival Illusion Daz (Sparkly Hat Dazzler)

    [116879] = true, -- Alliance Pie (Revelry Pie)
    [118833] = true, -- Piessive (Revelry Pie)
    [116933] = true, -- Covered in Pie (Revelry Pie)
    [116935] = true, -- Pie (Revelry Pie)
    [118837] = true, -- PiedFX (Revelry Pie)
    [116987] = true, -- Covered in Pie (Revelry Pie)
    [116989] = true, -- Covered in Pie (Revelry Pie)
    [116988] = true, -- Covered in Pie (Revelry Pie)
    [116942] = true, -- Covered in Pie (Revelry Pie)
    [116944] = true, -- Covered in Pie (Revelry Pie)
    [116943] = true, -- Covered in Pie (Revelry Pie)

    -------------------------------------
    -- MEMENTOS -------------------------
    -------------------------------------

    -------------------------------------
    -- EVENTS
    -------------------------------------

    -- Annual Jubilee
    [77027] = true,  -- Anniversary Cake - Forreals (Jubilee Cake)
    [87998] = true,  -- Anniversary Cake (2nd Annual Jubilee Cake)
    [102009] = true, -- Anniversary Cake (3rd Annual Jubilee Cake)
    [77123] = true,  -- Anniversary EXP Buff (Any Jubilee Cake except 2019 / 2020)
    [115688] = true, -- Anniversary Cake (Jubilee Cake 2019)
    [118985] = true, -- Anniversary EXP Buff (Jubilee Cake 2019)
    [132097] = true, -- 6 Year Cake (Jubilee Cake 2020)
    [136348] = true, -- Anniversary EXP Buff (Jubilee Cake 2020)
    [149946] = true, -- Jubilee Cake 2021 (Jubilee Cake 2021)
    [152514] = true, -- Anniversary EXP Buff (Jubilee Cake 2021)

    -- Jester's Festival
    [87963] = true,  -- Bestowed Cherry Blossoms (Cherry Blossom Branch)
    [89372] = true,  -- Pelted! (Cherry Blossom Branch)

    [115681] = true, -- Party Noise Maker (Festive Noise Maker)
    [115682] = true, -- Mount Block (Festive Noise Maker)

    [115683] = true, -- Jester Fest Memento (Jester's Festival Joke Popper)
    [115684] = true, -- Mount Block (Jester's Festival Joke Popper)
    [129550] = true, -- Stunned (Jester's Festival Joke Popper)

    [102077] = true, -- Jester's Festival Scintillator (Jester's Scintillator)

    [149874] = true, -- Playful Prankster's Surprise Box (Playful Prankster's Surprise Box)

    [91368] = true,  -- Jester's Experience Boost Pie (The Pie of Misrule)
    [91369] = true,  -- Jester's Experience Boost Pie (The Pie of Misrule)

    -- New Life Festival
    [91446] = true, -- Breda's Magnificent Mead (Breda's Bottomless Mead Mug)
    [91450] = true, -- Breda's Magnificent Mead (Breda's Bottomless Mead Mug)
    [91451] = true, -- Breda's Magnificent Mead (Breda's Bottomless Mead Mug)
    [91453] = true, -- Breda's Magnificent Mead (Breda's Bottomless Mead Mug)

    [85355] = true, -- Flame Juggling (Fire-Breather's Torches)

    [85354] = true, -- Dagger Juggling (Juggler's Knives)

    [86774] = true, -- Mudball (Mud Ball)
    [86777] = true, -- Mudball (Mud Ball)
    [86775] = true, -- Covered in Mud (Mud Ball)
    [86779] = true, -- Covered in Mud (Mud Ball)

    [85353] = true, -- Sword Swallowing (Sword-Swallower's Blade)

    -- Tribunal Celebration Event
    [146657] = true, -- Memento Cliff Racer (Thetys Ramary's Bait Kit)
    [147635] = true, -- Anchor (Thetys Ramary's Bait Kit)
    [147634] = true, -- Anchor (Thetys Ramary's Bait Kit)

    -- Witches Festival
    [110495] = true, -- Apple Bobbing (Apple-Bobbing Cauldron)
    [111458] = true, -- Apple-Bobbing Cauldron (Apple-Bobbing Cauldron)
    [111459] = true, -- Apple-Bobbing Cauldron (Apple-Bobbing Cauldron)

    [126689] = true, -- Grant Ach Progress: Skel Merionette (Skeletal Marionette)
    [125820] = true, -- Witches Festival 2019 Marionette (Skeletal Marionette)
    [125832] = true, -- Marionette Summon (Skeletal Marionette)

    [138404] = true, -- Throw Bones (Throwing Bones)
    -- [138405] = true, -- Throw Bones (Throwing Bones)
    [144790] = true, -- Throw Bones (Throwing Bones)
    [144791] = true, -- Throw Bones (Throwing Bones)

    [81575] = true,  -- Event - WitchFest Cauldron (Witchmother's Whistle)
    [96118] = true,  -- Witchmother's Boon (Witchmother's Whistle)
    [84361] = true,  -- Witchmother's Brew (Witchmother's Whistle)
    [84364] = true,  -- Witchmother's Brew (Witchmother's Whistle)
    [84365] = true,  -- Witchmother's Brew (Witchmother's Whistle)
    [84366] = true,  -- Witchmother's Brew (Witchmother's Whistle)
    [84367] = true,  -- Witchmother's Brew (Witchmother's Whistle)
    [84368] = true,  -- Witchmother's Brew (Witchmother's Whistle)
    [84369] = true,  -- Witchmother's Brew (Witchmother's Whistle)

    -------------------------------------
    -- FACTION & PROLOGUE QUESTS
    -------------------------------------

    -- Aldmeri Dominion
    [26736] = true, -- Bear Trap (Battered Bear Trap)
    [51555] = true, -- Bear Trap (Battered Bear Trap)
    [39245] = true, -- Glimpse of the Forbidden (Discourse Amaranthine)
    [41948] = true, -- Glanir's Smoke Bomb (Glanir's Smoke Bomb)
    [42105] = true, -- Nanwen's Sword (Nanwen's Sword)
    [42008] = true, -- Blessing of Root Sunder (Token of Root Sunder)

    -- Daggerfall Covenant
    [41988] = true, -- Bonesnap Binding Stone (Bonesnap Binding Stone)
    [41950] = true, -- Fetish of Anger (Fetish of Anger)
    [21226] = true, -- Finvir's Trinket (Finvir's Trinket)
    [42053] = true, -- Yokudan Salute (Yokudan Totem)
    [42067] = true, -- Explosion (Yokudan Totem)

    -- Ebonheart Pact
    [26829] = true, -- Light of the Tribunal (Almalexia's Enchanted Lantern)
    [16846] = true, -- Blackfeather Court Whistle (Blackfeather Court Whistle)
    [25696] = true, -- Falcon Takeoff (Justal's Falcon)
    [25699] = true, -- Falcon Timer (Justal's Falcon)
    [25703] = true, -- Justal's Falcon (Justal's Falcon)
    [25701] = true, -- Q4333 Falcon land now (Justal's Falcon)
    [43700] = true, -- Wand of Finding (Lena's Wand of Finding)
    [43702] = true, -- Invis Chicken Delay (Lena's Wand of Finding)
    [43703] = true, -- Extracting... (Lena's Wand of Finding)
    [43704] = true, -- Extracting... (Lena's Wand of Finding)
    [43701] = true, -- Extracting... (Lena's Wand of Finding)
    -- [8825] = true, -- Generic Crouch Fiddle Animatio (Questionable Meat Sack)
    [26339] = true, -- Eating (Questionable Meat Sack)
    [25369] = true, -- Sanguine's Goblet (Sanguine's Goblet)

    -- Coldharbour
    [42076] = true, -- Tear (Mezha-dro's Sealing Amulet)
    [42080] = true, -- Tear (Mezha-dro's Sealing Amulet)

    -- Cyrodiil
    [34578] = true, -- Nirnroot Wine (Nirnroot Wine)

    -- Prologue Quests
    [149879] = true, -- Daedric Unwarding Amulet (Daedric Unwarding Amulet)
    [125817] = true, -- U24 Teaser Dragon Horn (Dragonhorn Curio)
    [89550] = true,  -- TROPHY Azura's Light (Twilight Shard)
    [143495] = true, -- Reliquary of Dark Designs (Reliquary of Dark Designs)
    [144418] = true, -- Reliquary of Dark Designs (Reliquary of Dark Designs)
    [144417] = true, -- Reliquary of Dark Designs (Reliquary of Dark Designs)

    -------------------------------------
    -- DLC & CHAPTERS
    -------------------------------------

    -- Orsinium
    [73685] = true, -- Rkindaleft Trophy (Hidden Pressure Vent)
    [74151] = true, -- Stun (Hidden Pressure Vent)
    [73686] = true, -- Old Orsinium Trophy (Malacath's Wrathful Flame)
    [74232] = true, -- Stun (Malacath's Wrathful Flame)

    -- Thieves Guild
    -- [77785] = true, -- Rain of Coins (Coin of Illusory Riches)
    -- [77786] = true, -- Stun (Coin of Illusory Riches)

    -- Dark Brotherhood
    [79510] = true, -- TROPHY Blood Oath (Blade of the Blood Oath)

    -- Morrowind
    [92862] = true, -- Ringing Bell (Dreamer's Chime)
    [92863] = true, -- Stun (Dreamer's Chime)

    -- Elsweyr
    [119099] = true, -- Brittle Burial Urn (Brittle Burial Urn)
    [125053] = true, -- Brittle Burial Urn (Brittle Burial Urn)
    [119107] = true, -- Stun (Winnowing Plague Decoction)
    [119108] = true, -- NAME ME Infect Brew (Winnowing Plague Decoction)

    -- Scalebreaker
    [125816] = true, -- Maarselok Corruption Memento (Corruption of Maarselok)
    [125822] = true, -- Mount Block (Corruption of Maarselok)

    -- Greymoor
    [136120] = true, -- Ritual Circle Totem (Ritual Circle Totem)

    -- Stonethorn
    [137919] = true, -- Juggling Potion Bottles (Mostly Stable Juggling Potions)

    -- Markarth
    [147598] = true, -- Void Shard (Void Shard)
    [147689] = true, -- Void Shard (Void Shard)
    [147688] = true, -- Void Shard (Void Shard)

    -- Flames of Ambition
    [149881] = true, -- Illusory Salamander Stone (Illusory Salamander Stone)
    [151257] = true, -- Illusory Salamander Stone (Illusory Salamander Stone)
    [151256] = true, -- Illusory Salamander Stone (Illusory Salamander Stone)

    -- Blackwood
    [153758] = true, -- Golden Anvil Replica (Full-Scale Golden Anvil Replica)
    [146744] = true, -- Temperamental Grimoire (Temperamental Grimoire)
    [153760] = true, -- Wilting Weed Killer Phial (Wilting Weed Killer Phial)

    -------------------------------------
    -- CROWN CRATES
    -------------------------------------

    -- Crown Crates - Storm Atronach Crate
    [85344] = true, -- Atronach Aura (Storm Atronach Aura)
    [85349] = true, -- Atronach Transformation (Storm Atronach Transform)
    [85347] = true, -- Atronach Juggling (Storm Orb Juggle)

    -- Crown Crates - Wild Hunt Crate
    [86976] = true, -- Spriggan Aura (Wild Hunt Leaf-Dance Aura)
    [86977] = true, -- Spriggan Transformation (Wild Hunt Transform)
    [86978] = true, -- Grand Spriggan Aura (Floral Swirl Aura)

    -- Crown Crates - Dwarven Crate
    [92866] = true, -- Dwarven Globe (Dwarven Puzzle Orb)
    [92867] = true, -- Dwarven Tuning Forks (Dwaven Tonal Forks)
    [92868] = true, -- Dwarven Transformation (Dwemervamidium Mirage)

    -- Crown Crates - Reaper's Harvest Crate
    [97273] = true, -- TROPHY Death Crate Mem 1 (Crow's Calling)
    [97275] = true, -- TROPHY Death Crate Mem 3 (Murderous Strike)
    [98378] = true, -- Murderous Strike (Murderous Strike)
    [97274] = true, -- Swarm of Crows (Swarm of Crows)

    -- Crown Crates - Flame Atronach Crate
    [99318] = true, -- TROPHY Flame Crate Mem 1 (Fiery Orb)
    [99319] = true, -- Flame Crate Memento 2 (Flame Pixie)
    [99320] = true, -- TROPHY Flame Crate Mem 3 (Flame Eruption)

    -- Crown Crates - Scalecaller Crate
    [101874] = true, -- _CRWN Dragon Priest Mem2 Ice T (Scalecaller Frost Shard)
    [101877] = true, -- _CRWN Dragon Priest Mem1 Fl/St (Scalecaller Rune of Levitation)
    [101872] = true, -- _CRWN Dragon Priest Memento 3 (Bone Dragon Summons Focus)

    -- Crown Crates - Psijic Vault Crate
    [104324] = true, -- Psijic Pearl Summon (Psijic Celestial Orb)
    [104323] = true, -- Psijic Hourglass (Psijic Tautology Glass)
    [104325] = true, -- Psijic Disintegrate (Sapiarchic Discorporation Lens)

    -- Crown Crates - Hollowjack Crate
    [110482] = true, -- Rind-Renewing Pumpkin (Rind-Renewing Pumpkin)
    [116543] = true, -- Gourd-Gallows Stump (Gourd-Gallows Stump)
    -- [110481] = true, -- Gourd-Gallows Stump (Gourd-Gallows Stump)
    -- [113697] = true, -- Gourd-Gallows Stump (Gourd-Gallows Stump)
    -- [113696] = true, -- Gourd-Gallows Stump (Gourd-Gallows Stump)
    [110483] = true, -- Ghost Lantern (Ghost Lantern)

    -- Crown Crates - Xanmeer Crate
    [113288] = true, -- UC Crown Memento 1 (Mire Drum)
    [113291] = true, -- UC Crown Memento 2 (Vossa-satl)

    -- Crown Crates - Ayleid Crate
    [149872] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
    [151489] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
    [151490] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
    [151491] = true, -- Painter's Easel and Canvas (Painter's Easel and Canvas)
    [146752] = true, -- Phial of Clockwork Lubricant (Phial of Clockwork Lubricant)

    -------------------------------------
    -- NON-COMBAT PETS
    -------------------------------------

    [76364] = true, -- _CRWN_5s
    [76365] = true, -- _CRWN_Echalette_Buck
    [76367] = true, -- _CRWN_ResetPosture
    [76368] = true, -- _CRWN_1s
    [78642] = true, -- _CRWN_Jackal_Mouse
    [78643] = true, -- _CRWN_Jackal_Digging
    -- [81301] = true, -- _CRWN_Badger_EatCritter
    [72955] = true, -- _CROWN Pet Goat,Black
    [81352] = true, -- _CRWN_12.5s (Spotted Snow Senche-Leopard)
    -- [127179] = true, -- _Crwn Pet Doom Spawn (Mudcrab of Eternal Doom)
    [60665] = true, -- Vanity Pet Sphere Stun
    -- [79693] = true, -- _CRWN_ChubLoon_Bellyflop (Chub Loon)

    -------------------------------------
    -- OTHER COLLECTIBLES
    -------------------------------------

    [77645] = true, -- Stealth (Pirharri the Smuggler)
    [77629] = true, -- Stun For Costumes, 3s (Various Polymorphs)
    [77630] = true, -- Stun For Costumes, 4s (Various Polymorphs)

    -------------------------------------
    -- ITEM SETS ------------------------
    -------------------------------------
    [187839] = true, -- Runecarver's Blaze
    -------------------------------------
    -- Ability Altering Weapons
    -------------------------------------

    -- Asylum Weapons
    [100473] = true, -- Chaotic Whirlwind (Asylum)
    [100474] = true, -- Chaotic Whirlwind (Asylum)
    [140223] = true, -- Chaotic Whirlwind (Asylum)
    [100301] = true, -- Piercing Spray (Asylum)
    [100302] = true, -- Piercing Spray (Asylum)
    [100293] = true, -- Disciplined Slash (Asylum)
    [100294] = true, -- Disciplined Slash (Asylum)
    [100461] = true, -- Defensive Position (Asylum)
    [100463] = true, -- Defensive Position (Asylum)
    [100465] = true, -- Defensive Position (Perfected) (Asylum)
    [100462] = true, -- Defensive Position (Asylum)
    [100464] = true, -- Defensive Position (Asylum)
    [100303] = true, -- Concentrated Force (Asylum)
    [100304] = true, -- Concentrated Force (Asylum)
    [100306] = true, -- Concentrated Force (Asylum)
    [140282] = true, -- Concentrated Force (Asylum)
    [100307] = true, -- Timeless Blessing (Asylum)
    [100308] = true, -- Timeless Blessing (Asylum)

    -- Maelstrom Weapons
    [99805] = true,  -- Cruel Flurry (Maelstrom)
    [99806] = true,  -- Cruel Flurry (Maelstrom)
    [99851] = true,  -- Thunderous Volley (Maelstrom)
    [99852] = true,  -- Thunderous Volley (Maelstrom)
    [99854] = true,  -- Thunderous Volley (Maelstrom)
    [99853] = true,  -- Thunderous Volley (Maelstrom)
    [99787] = true,  -- Merciless Charge (Maelstrom)
    [141877] = true, -- Merciless Charge (Maelstrom)
    [99789] = true,  -- Merciless Charge (Maelstrom)
    [99801] = true,  -- Rampaging Slash (Maelstrom)
    [100588] = true, -- Rampaging Slash (Maelstrom)
    [100587] = true, -- Rampaging Slash (Maelstrom)
    [100589] = true, -- Rampaging Slash (Maelstrom)
    [99875] = true,  -- Crushing Wall (Maelstrom)
    [100155] = true, -- Crushing Wall (Maelstrom)
    [114887] = true, -- Summon Shade (Maelstrom)
    [114879] = true, -- Summon Shade (Maelstrom)
    [114882] = true, -- Summon Shade (Maelstrom)
    [99876] = true,  -- Crushing Wall (Maelstrom)
    [99886] = true,  -- Precise Regeneration (Maelstrom)
    [100161] = true, -- Precise Regeneration (Maelstrom)
    [99887] = true,  -- Precise Regeneration (Maelstrom)

    -- Master Weapons
    [99762] = true,  -- Stinging Slashes (Master)
    [100070] = true, -- Stinging Slashes (Master)
    [99766] = true,  -- Caustic Arrow (Master)
    [100105] = true, -- Caustic Arrow (Master)
    [99742] = true,  -- Titanic Cleave (Master)
    [101798] = true, -- Titanic Cleave (Master)
    [99759] = true,  -- Puncturing Remedy (Master)
    [99761] = true,  -- Puncturing Remedy (Master)
    [100575] = true, -- Puncturing Remedy (Master)
    [99774] = true,  -- Destructive Impact (Master)
    [140334] = true, -- Destructive Impact (Master)
    [99780] = true,  -- Grand Rejuvenation (Master)
    [99781] = true,  -- Grand Rejuvenation (Master)
    [131489] = true, -- Grand Rejuvenation (Master)

    -- Blackrose Weapons
    [113616] = true, -- Spectral Cloak (Blackrose DW)
    [141875] = true, -- Spectral Cloak (Blackrose DW)
    [113617] = true, -- Spectral Cloak (Blackrose DW)
    [113619] = true, -- Virulent Shot (Blackrose Bow)
    [113628] = true, -- Virulent Shot (Blackrose Bow)
    [113627] = true, -- Virulent Shot (Blackrose Bow)
    [113551] = true, -- Radial Uppercut (Blackrose 2H)
    [113554] = true, -- Radial Uppercut (Blackrose 2H)
    [113553] = true, -- Radial Uppercut (Blackrose 2H)
    [113574] = true, -- Gallant Charge (Blackrose 1H)
    [113608] = true, -- Gallant Charge (Blackrose 1H)
    [113687] = true, -- Wild Impulse (Blackrose Destruction Staff)
    [115003] = true, -- Wild Impulse (Blackrose Destruction Staff)
    [114988] = true, -- Wild Impulse (Blackrose Destruction Staff)
    [115005] = true, -- Wild Impulse (Blackrose Destruction Staff)
    [115006] = true, -- Wild Impulse (Blackrose Destruction Staff)
    [113651] = true, -- Mender's Ward (Blackrose Restoration Staff)
    [113654] = true, -- Razor Shot (Blackrose Restoration Staff)
    [113653] = true, -- Major Vitality (Blackrose Restoration Staff)

    -- Vateshran Weapons
    [147791] = true, -- Executioner's Blade (Vateshran Dual Wield)
    [147798] = true, -- Executioner's Blade (Vateshran Dual Wield)
    [149423] = true, -- Executioner's Blade (Vateshran Dual Wield)
    [147786] = true, -- Point-Blank Snipe (Vateshran Bow)
    [147792] = true, -- Point-Blank Snipe (Vateshran Bow)
    [147698] = true, -- Frenzied Momentum (Vateshran 2H)
    [147700] = true, -- Frenzied Momentum (Vateshran 2H)
    [147701] = true, -- Frenzied Momentum (Vateshran 2H)
    [147704] = true, -- Frenzied Momentum (Vateshran 2H)
    [147703] = true, -- Frenzied Momentum (Vateshran 2H)
    [147719] = true, -- Void Bash (Vateshran 1H)
    [147747] = true, -- Call of the Void (Vateshran 1H)
    [147744] = true, -- Void Bash (Vateshran 1H)
    [147743] = true, -- Void Bash (Vateshran 1H)
    [147746] = true, -- Major Maim (Vateshran 1H)
    [147828] = true, -- Wrath of Elements (Vateshran Destruction Staff)
    [147843] = true, -- Wrath of Elements (Vateshran Destruction Staff)
    [149413] = true, -- Wrath of Elements (Vateshran Destruction Staff)
    [147847] = true, -- Wrath of Elements (Vateshran Destruction Staff)
    [147844] = true, -- Wrath of Elements (Vateshran Destruction Staff)
    [147846] = true, -- Wrath of Elements (Vateshran Destruction Staff)
    -- [149416] = true, -- Wrath of Elements (Vateshran Destruction Staff)
    [147871] = true, -- Force Overflow (Vateshran Restoration Staff)
    [147872] = true, -- Force Overflow (Vateshran Restoration Staff)
    [147875] = true, -- Force Overflow (Vateshran Restoration Staff)
    [149878] = true, -- Force Overflow (Vateshran Restoration Staff)
    [149877] = true, -- Force Overflow (Vateshran Restoration Staff)
    [147873] = true, -- Force Overflow (Vateshran Restoration Staff)
    [147879] = true, -- Force Overflow (Vateshran Restoration Staff)

    -------------------------------------
    -- MONSTER HELMS
    -------------------------------------

    -- Balorgh
    [111504] = true, -- Balorgh
    [111505] = true, -- Balorgh

    -- Blood Spawn
    [59516] = true, -- Blood Spawn
    [59517] = true, -- Blood Spawn
    [61274] = true, -- Blood Spawn

    -- Bogdan the Nightflame
    [59589] = true, -- Nightflame
    [59590] = true, -- Imperial Prison Item Set
    [59591] = true, -- Bogdan Totem
    [61381] = true, -- Imperial Prison Item Set

    -- Chokethorn
    [81068] = true, -- Chokethorn
    [81069] = true, -- Chokethorn
    [81077] = true, -- Chokethorn

    -- Domihaus
    [97879] = true, -- Domihaus
    [97882] = true, -- Domihaus
    [97896] = true, -- Domihaus
    [97883] = true, -- Domihaus
    [97899] = true, -- Domihaus

    -- Earthgore
    [97854] = true, -- Earthgore
    [97855] = true, -- Earthgore
    [97857] = true, -- Earthgore

    -- Grothdarr
    [84492] = true, -- Grothdarr
    [84504] = true, -- Grothdarr
    [84502] = true, -- Grothdarr

    -- Grundwulf
    [126513] = true, -- Grundwulf
    [126529] = true, -- Grundwulf
    [126687] = true, -- Grundwulf
    [126688] = true, -- Grundwulf
    [126528] = true, -- Grundwulf

    -- Iceheart
    [80560] = true, -- Iceheart
    [80561] = true, -- Iceheart
    [80562] = true, -- Iceheart
    [80563] = true, -- Iceheart

    -- Ilambris
    [80524] = true, -- Ilambris
    [80527] = true, -- Ilambris
    [80526] = true, -- Ilambris
    [80525] = true, -- Ilambris

    -- Infernal Guardian
    [81687] = true, -- Infernal Guardian
    [83405] = true, -- Infernal Guardian
    [83390] = true, -- Infernal Guardian
    [83393] = true, -- Infernal Guardian
    [83391] = true, -- Infernal Guardian
    [83409] = true, -- Infernal Guardian

    -- Kjalnar's Nightmare
    [133499] = true, -- Kjalnar's Nightmare (Kjalnar's Nightmare)
    [133505] = true, -- Bone (Kjalnar's Nightmare)
    [135094] = true, -- Warning (Kjalnar's Nightmare)
    [135088] = true, -- Kjalnar's Nightmare (Kjalnar's Nightmare)
    [133538] = true, -- Kjalnar's Nightmare
    [134908] = true, -- Kjalnar's Nightmare
    [133506] = true, -- Kjalnar's Nightmare
    [133542] = true, -- Bone Colossus

    -- Kra'gh
    [80564] = true, -- Kra'gh
    [80566] = true, -- Kra'gh
    [80565] = true, -- Kra'gh

    -- Lady Thorn
    [141897] = true, -- Lady Thorn (Lady Thorn)
    [141905] = true, -- Corrupted Blood (Lady Thorn)
    [141972] = true, -- Lady Thorn (Lady Thorn)
    [142318] = true, -- Synergy Damage Bonus (Lady Thorn)
    [141971] = true, -- Lady Thorn CD (Lady Thorn)
    [142307] = true, -- Sanguine Burst Area (Lady Thorn)
    [142305] = true, -- Sanguine Burst (Lady Thorn)
    [141927] = true, -- Major Maim (Lady Thorn)
    [143335] = true, -- Sanguine Burst Immunity (Lady Thorn)

    -- Lord Warden
    [59585] = true, -- Lord Warden
    [59586] = true, -- Lord Warden
    [59587] = true, -- Lord Warden

    -- Malubeth
    [59564] = true, -- Scourge Harvester (Malubeth)
    [59568] = true, -- Scourge Harvest (Malubeth)
    [61275] = true, -- Major Vitality (Malubeth)
    [59573] = true, -- Scourge Harvest (Malubeth)

    -- Maarselok
    [126940] = true, -- Maarselok (Maarselok)
    [126941] = true, -- Maarselok (Maarselok)

    -- Maw of the Infernal
    [59507] = true, -- Maw of the Infernal (Maw of the Infernal)
    [48796] = true, -- DUMMY (Maw of the Infernal)
    [59508] = true, -- Banished Cells Item Set (Maw of the Infernal)
    [60974] = true, -- Jagged Claw (Maw of the Infernal)
    [60971] = true, -- Fiery Breath (Maw of the Infernal)
    [60972] = true, -- Fiery Breath (Maw of the Infernal)
    [60973] = true, -- Fiery Jaws (Maw of the Infernal)

    -- Mighty Chudan
    [80482] = true, -- Mighty Chudan (Mighty Chudan)

    -- Molag Kena
    [66792] = true, -- Molag Kena (Molag Kena)
    [66808] = true, -- Molag Kena (Molag Kena)
    [66812] = true, -- Overkill (Molag Kena)

    -- Mother Ciannait
    [133378] = true, -- Mother Ciannait (Mother Ciannait)
    [133381] = true, -- Mother Ciannait (Mother Ciannait)
    [137313] = true, -- Mother Ciannait (Mother Ciannait)

    -- Nerien'eth
    [59592] = true, -- Nerien'eth
    [59594] = true, -- Crpyt of Hearts Item Set
    [59593] = true, -- Lich Crystal

    -- Pirate Skeleton
    [80501] = true, -- Pirate Skeleton
    [98421] = true, -- Pirate Skeleton
    [98419] = true, -- Pirate Skeleton
    [98420] = true, -- Pirate Skeleton
    [81675] = true, -- Pirate Skeleton
    [83288] = true, -- Pirate Skeleton
    [83287] = true, -- Pirate Skeleton
    [80853] = true, -- Major Protection (Pirate Skeleton)
    [85637] = true, -- Minor Defile (Pirate Skeleton)

    -- Selene
    [80599] = true, -- Selene
    [11317] = true, -- Generic Self PermaStun
    [80607] = true, -- Dummy
    [80600] = true, -- Selene
    [80604] = true, -- Selene
    [80609] = true, -- Dummy
    [80606] = true, -- Selene

    -- Sellistrix
    [80542] = true, -- Sellistrix
    [80545] = true, -- Sellistrix
    [80544] = true, -- Sellistrix
    [80549] = true, -- Sellistrix

    -- Sentinel of Rkugamz
    [81035] = true,  -- Sentinel of Rkugamz
    [81036] = true,  -- Sentinel of Rkugamz
    [81037] = true,  -- Sentinel of Rkugamz
    [81038] = true,  -- Sentinel of Rkugamz
    [81041] = true,  -- Sentinel of Rkugamz
    [133239] = true, -- Sentinel of Rkugamz

    -- Shadowrend
    [80951] = true, -- Shadowrend
    [80955] = true, -- Forward Charge
    [80954] = true, -- Shadowrend Summon
    [80980] = true, -- Shadowrend
    [80990] = true, -- Shadowrend
    [80989] = true, -- Shadowrend
    [81034] = true, -- Shadowrend

    -- Slimecraw
    [80481] = true, -- Minor Berserk (Slimecraw)

    -- Spawn of Mephala
    [59489] = true, -- Spawn of Mephala
    [59497] = true, -- Spawn of Mephala
    [59498] = true, -- Mephala's Web
    [59499] = true, -- Mephala's Web

    -- Stonekeeper
    [116838] = true, -- Stonekeeper (Stonekeeper)
    [116839] = true, -- Charging (Stonekeeper)
    [116846] = true, -- Stonekeeper (Stonekeeper)
    [116847] = true, -- Stonekeeper (Stonekeeper)
    [116877] = true, -- Stonekeeper (Stonekeeper)
    [116878] = true, -- Stonekeeper (Stonekeeper)
    [116876] = true, -- Stonekeeper (Stonekeeper)
    [116880] = true, -- Stonekeeper (Stonekeeper)
    [116881] = true, -- Stonekeeper (Stonekeeper)

    -- Stone Husk
    [142977] = true, -- Stone Husk (Stone Husk)
    [143032] = true, -- Stone Husk (Stone Husk)
    [143077] = true, -- Stone Husk (Stone Husk)
    [145199] = true, -- Husk Drain (Stone Husk)
    [144908] = true, -- Stone Husk (Stone Husk)

    -- Stormfist
    [80520] = true, -- Stormfist
    [80523] = true, -- Stormfist
    [80522] = true, -- Stormfist
    [80521] = true, -- Stormfist

    -- Swarm Mother
    [80592] = true, -- Swarm Mother
    [84419] = true, -- Swarm Mother Mask
    [80593] = true, -- Swarm Mother Mask

    -- Symphony of Blades
    [117110] = true, -- Symphony of Blades (Symphony of Blades)
    [117111] = true, -- Meridia's Favor (Symphony of Blades)
    [117118] = true, -- Meridia's Favor (Symphony of Blades)
    [117119] = true, -- Meridia's Favor (Symphony of Blades)
    [140092] = true, -- Meridia's No More Favor (Symphony of Blades)

    -- The Engine Guardian
    [59521] = true, -- Engine Guardian
    [60484] = true, -- Sphere Groundrise
    [59522] = true, -- Engine Guardian
    [59539] = true, -- Robust Engine Guardian
    [59540] = true, -- Robust Engine Guardian
    [59525] = true, -- Arcane Engine Guardian
    [59533] = true, -- Arcane Engine Guardian
    [59541] = true, -- Healthy Engine Guardian
    [59543] = true, -- Healthy Engine Guardian

    -- The Troll King
    [80503] = true, -- The Troll King
    [80504] = true, -- The Troll King

    -- Thurvokun
    [102089] = true, -- Thurvokun
    [102094] = true, -- Thurvokun
    [102097] = true, -- Thurvokun
    [102093] = true, -- Thurvokun
    [102095] = true, -- Thurvokun

    -- Tremorscale
    [80513] = true, -- Tremorscale
    [80517] = true, -- Tremorscale
    [80865] = true, -- Tremorscale
    [80866] = true, -- Tremorscale

    -- Valkyn Skoria
    [59595] = true,  -- Valkyn Skoria
    [137979] = true, -- Valkyn Skoria
    [59596] = true,  -- Valkyn Skoria
    [61273] = true,  -- Valkyn Skoria

    -- Velidreth
    [80483] = true, -- Velidreth
    [80487] = true, -- Hoarvor Mask
    [80488] = true, -- Hoarvor Mask
    [80856] = true, -- Hoarvor Mask
    [80864] = true, -- Hoarvor Mask
    [80490] = true, -- Velidreth
    [80859] = true, -- Hoarvor Mask

    -- Vykosa
    [111352] = true, -- Vykosa
    [111354] = true, -- Major Cowardice

    -- Zaan
    [102125] = true, -- Zaan
    [102136] = true, -- Zaan
    [102142] = true, -- Zaan
    [110997] = true, -- Zaan Buffer

    -------------------------------------
    -- Mythic Items
    -------------------------------------

    [136347] = true, -- Malacath's Band of Brutality (Malacath's Band of Brutality)
    [139526] = true, -- Snow Treaders (Snow Treaders)
    [139552] = true, -- Snow Treaders (Snow Treaders)
    [139902] = true, -- Bloodlord's Embrace (Bloodlord's Embrace)
    [139903] = true, -- Blood Curse (Bloodlord's Embrace)
    [140200] = true, -- Only 1 Curse (Bloodlord's Embrace)
    [139914] = true, -- Bloodlord's Embrace (Bloodlord's Embrace)
    [136116] = true, -- Thrassian Stranglers (Thrassian Stranglers)
    [136123] = true, -- Sload's Call (Thrassian Stranglers)
    [136479] = true, -- Thrassian Stranglers (Thrassian Stranglers)

    -------------------------------------
    -- Armor Sets
    -------------------------------------

    -- Crafted Sets
    [29124] = true,  -- Ashen Grip
    [34502] = true,  -- Ashen Grip

    [32799] = true,  -- Alessia's Bulwark
    [34592] = true,  -- Alessia's Bulwark

    [92768] = true,  -- Assassin's Guile (Assassin's)

    [75745] = true,  -- Clever Alchemist
    [75746] = true,  -- Clever Alchemist

    [92769] = true,  -- of Daedric Trickery (of Daedric Trickery)
    [92774] = true,  -- Major Mending (of Daedric Trickery)
    [92771] = true,  -- Major Expedition (of Daedric Trickery)
    [92775] = true,  -- Major Heroism (of Daedric Trickery)
    [92776] = true,  -- Major Vitality (of Daedric Trickery)
    [92773] = true,  -- Major Protection (of Daedric Trickery)

    [29097] = true,  -- Death's Wind
    [33764] = true,  -- Death's Wind
    [52289] = true,  -- Death's Wind

    [75927] = true,  -- Eternal Hunt
    [75930] = true,  -- Daedric Mines
    [75929] = true,  -- Eternal Hunt
    [76533] = true,  -- Eternal Hunt

    [79008] = true,  -- Gladiator

    [32781] = true,  -- Hist Bark
    [86555] = true,  -- Hist Bark

    [99199] = true,  -- Innate Axiom

    [32810] = true,  -- Kagrenac's Hope
    [57207] = true,  -- Kagrenac's Hope

    [29102] = true,  -- Magnus' Gift (Magnus)
    [34381] = true,  -- Magnus' Gift (Magnus)
    [147890] = true, -- Magnus' Gift (Magnus)

    [99202] = true,  -- Mechanical Acuity (of Mechanical Acuity)
    [99204] = true,  -- Mechanical Acuity (of Mechanical Acuity)

    [71670] = true,  -- Morkuldin (Morkuldin)
    [71671] = true,  -- Morkuldin (Morkuldin)
    [71678] = true,  -- Morkuldin (Morkuldin)
    [71679] = true,  -- Morkuldin Cleave (Morkuldin)

    [79103] = true,  -- Pelinal's Aptitude (Pelinal's)

    [32756] = true,  -- Oblivion's Foe (of Oblivion's Foe)
    [148882] = true, -- Oblivion's Foe (of Oblivion's Foe)

    [32801] = true,  -- Orgnum's Scales (Orgnum's Scales)

    [61783] = true,  -- Redistributor (Redistribution)
    [61784] = true,  -- Redistributor (Redistribution)

    [32816] = true,  -- Shalidor's Curse
    [49126] = true,  -- Shalidor's Curse

    [75724] = true,  -- Tava's Favor
    [75726] = true,  -- Tava's Favor

    [61851] = true,  -- Armor Master (the Armor Master)
    [61870] = true,  -- Armor Master (the Armor Master)

    [52712] = true,  -- Way of the Arena (the Arena)

    [32804] = true,  -- Eyes of Mara (the Eyes of Mara)

    [29113] = true,  -- Night Mother's Gaze (the Night Mother's Gaze)
    [34386] = true,  -- Major Breach (the Night Mother's Gaze)

    [29108] = true,  -- Night's Silence (the Night's Silence)

    [61780] = true,  -- Noble's Conquest (Nobles Conquest)
    [61781] = true,  -- Noble's Conquest (Nobles Conquest)
    [61782] = true,  -- Minor Vulnerability

    [29119] = true,  -- Armor of the Seducer (the Seducer)

    [32784] = true,  -- Song of Lamae (the Song of Lamae)
    [34587] = true,  -- Song of Lamae (the Song of Lamae)
    [34588] = true,  -- Song of Lamae (the Song of Lamae)

    [32757] = true,  -- Spectre's Eye (of the Spectre's Eye)
    [69685] = true,  -- Major Evasion (of the Spectre's Eye)

    [60457] = true,  -- Twice-Born Star (the Twice-Born Star)

    [32782] = true,  -- Willow's Path (the Willow's Path)

    [32759] = true,  -- Torug's Pact (Torug's Pact)

    [71018] = true,  -- Trial by Fire (Trials)

    [29098] = true,  -- Twilight's Embrace

    [79029] = true,  -- Varen's Legacy
    [79089] = true,  -- Varen's Wall
    [79093] = true,  -- Remove Trigger

    [29120] = true,  -- Vampire's Kiss
    [57170] = true,  -- Vampire's Kiss

    [29109] = true,  -- Whitestrake's Retribution (Whitestrake's)
    [49236] = true,  -- Whitestrake's Retribution (Whitestrake's)

    [106775] = true, -- Adept Rider (Adept Rider's)
    -- [106776] = true, -- Major Expedition (Adept Rider's)

    [106803] = true, -- Nocturnal's Favor (Nocturnal's Favored)
    [106804] = true, -- Nocturnal's Heal (Nocturnal's Favored)

    [106797] = true, -- Sload's Semblance (Sload's)
    [106798] = true, -- Sload's Semblance (Sload's)
    [113092] = true, -- Sload's Projectile (Sload's)

    [113180] = true, -- Grave-Stake Collector (Grave-Stake Collector)
    [113181] = true, -- Grave-Stake Collector (Grave-Stake Collector)
    [113259] = true, -- Grave-Stake Collector (Grave-Stake Collector)
    [113185] = true, -- Grave-Stake Collector (Grave-Stake Collector)
    [113237] = true, -- Grave-Stake Collector (Grave-Stake Collector)

    [113311] = true, -- Might of the Lost Legion (Might of the Lost Legion)
    [113312] = true, -- Empower (Might of the Lost Legion)

    [113287] = true, -- Naga Shaman (Naga Shaman)
    [113306] = true, -- Minor Vitality (Naga Shaman)
    [113307] = true, -- Minor Mending (Naga Shaman)

    [121638] = true, -- Senche-Raht's Grit (Senche-Raht's)
    [124303] = true, -- Senche-Raht's Grit (Senche-Raht's)

    [121911] = true, -- Coldharbour's Favorite (Coldharbour's Favorite)
    [121914] = true, -- Coldharbour's Favorite (Coldharbour's Favorite)
    [121915] = true, -- Coldharbour's Favorite (Coldharbour's Favorite)
    [121917] = true, -- Honor's Scorn (Coldharbour's Favorite)
    [121912] = true, -- Coldharbour's Favorite (Coldharbour's Favorite)
    [121913] = true, -- Honor's Love (Coldharbour's Favorite)

    [121729] = true, -- Vastarie's Tutelage (Vastarie's Tutelage)
    [123717] = true, -- Vastarie's Tutelage (Vastarie's Tutelage)
    [124242] = true, -- Vastarie's Tutelage (Vastarie's Tutelage)
    [123715] = true, -- Vastarie's Tutelage (Vastarie's Tutelage)
    [124574] = true, -- Vastarie's Tutelage (Vastarie's Tutelage)

    [129582] = true, -- New Moon Acolyte (New Moon Acolyte's)

    [129534] = true, -- Daring Corsair (Daring Corsair's)
    [129536] = true, -- Minor Heroism (Daring Corsair's)

    [134103] = true, -- Dauntless Combatant (Dauntless Combatant's)
    [134104] = true, -- Dauntless Combatant (Dauntless Combatant's)
    [134119] = true, -- Dauntless Combatant (Dauntless Combatant's)

    [134090] = true, -- Unchained Aggressor (Unchained Aggressor's)
    [134094] = true, -- Major Berserk (Unchained Aggressor's)

    [134017] = true, -- Critical Riposte (of Critical Riposte)
    [134034] = true, -- Minor Uncertainty (of Critical Riposte)
    [134040] = true, -- Minor Enervation (of Critical Riposte)
    [134280] = true, -- Critical Riposte Immunity (of Critical Riposte)

    [135874] = true, -- Stuhn's Favor (Stuhn's)
    [141916] = true, -- Stuhn's Favor (Stuhn's)

    [135886] = true, -- Spell Parasite (Spell Parasites's)
    [135919] = true, -- Spell Parasite (Spell Parasites's)

    [135876] = true, -- Dragon's Appetite (of Dragon's Appetite)
    [137126] = true, -- Dragon's Appetite (of Dragon's Appetite)
    [135878] = true, -- Dragon's Appetite (of Dragon's Appetite)

    [147321] = true, -- Aetherial Ascension (of Aetherial Ascension)
    [147300] = true, -- Red Eagle's Fury (of Red Eagle's Fury)
    [147388] = true, -- Legacy of Karth (Karth's)
    [147389] = true, -- Legacy of Karth (Karth's)
    [147390] = true, -- Karth's Rot (Karth's)

    -- Overland Sets (All Types)
    [85541] = true, -- Armor of the Trainee (of the Trainee)

    -- Overland Sets (Light)
    [77888] = true,  -- Bahraha's Curse (of Bahraha's Curse)
    [75673] = true,  -- Bahraha's Curse (of Bahraha's Curse)
    [75691] = true,  -- Bahraha's Curse (of Bahraha's Curse)
    [75707] = true,  -- Bahraha's Curse (of Bahraha's Curse)
    [75692] = true,  -- Bahraha's Curse (of Bahraha's Curse)
    [75706] = true,  -- Bahraha's Curse (of Bahraha's Curse)

    [32742] = true,  -- Bloodthorn's Touch (Bloodthorn)
    [34522] = true,  -- Bloodthorn's Touch (Bloodthorn)
    [57177] = true,  -- Bloodthorn's Touch (Bloodthorn)

    [29092] = true,  -- Dreamer's Mantle (Dreamer's)
    [31213] = true,  -- Dreamer's Mantle (Dreamer's)
    [48913] = true,  -- Dreamer's Mantle (Dreamer's)
    [57133] = true,  -- Dreamer's Mantle (Dreamer's)

    [32803] = true,  -- Queen's Elegance (Elegant)
    [135938] = true, -- Queen's Elegance (Elegant)
    [135939] = true, -- Queen's Elegance (Elegant)

    [32743] = true,  -- Robes of the Hist (of Hist Sap)
    [85776] = true,  -- Robes of the Hist (of Hist Sap)

    [52704] = true,  -- Way of Martial Knowledge (of Martial Knowledge)
    [127070] = true, -- Way of Martial Knowledge (of Martial Knowledge)

    [32820] = true,  -- Necropotence (of Necropotence)

    [29094] = true,  -- Prisoner's Rags (Prisoner's)
    [85825] = true,  -- Prisoner's Rags (Prisoner's)

    [79192] = true,  -- Sithis' Touch (Sithis)
    [79200] = true,  -- Major Berserk (Sithis)

    [85591] = true,  -- Skooma Smuggler (Smuggler's)
    [85592] = true,  -- Major Expedition (Smuggler's)

    [32725] = true,  -- Stendarr's Embrace (of Stendarr)
    [85812] = true,  -- Stendarr's Embrace (of Stendarr)

    [32728] = true,  -- Syrabane's Grip (of Syrabane)
    [34506] = true,  -- Syrabane's Grip (of Syrabane)

    [32741] = true,  -- Shadow Dancer's Raiment (of the Shadow Dancer)

    [29095] = true,  -- Silks of the Sun (of the Sun)

    [29101] = true,  -- Robes of the Withered Hand (of the Withered Hand)
    [122755] = true, -- Robes of the Withered Hand (of the Withered Hand)
    [122756] = true, -- Robes of the Withered Hand (of the Withered Hand)

    [71656] = true,  -- Trinimac's Valor (of Trinimac's Valor)
    [71664] = true,  -- Trinimac's Valor (of Trinimac's Valor)
    [71657] = true,  -- Trinimac's Valor (of Trinimac's Valor)
    [71658] = true,  -- Trinimac's Valor (of Trinimac's Valor)

    [85567] = true,  -- Vampire Lord (Vampire Lord's)

    [92761] = true,  -- War Maiden (War Maiden's)

    [85596] = true,  -- Ysgramor's Birthright (Ysgramor's)

    [92981] = true,  -- Mad Tinkerer (Mad Tinkerer's)
    [93026] = true,  -- Mad Tinkerer (Mad Tinkerer's)
    [92982] = true,  -- Mad Tinkerer (Mad Tinkerer's)
    [92986] = true,  -- Mad Tinkerer (Mad Tinkerer's)
    [93001] = true,  -- Mad Tinkerer (Mad Tinkerer's)
    [93002] = true,  -- Mad Tinkerer (Mad Tinkerer's)
    [93003] = true,  -- Mad Tinkerer (Mad Tinkerer's)
    [92998] = true,  -- Mad Tinkerer (Mad Tinkerer's)
    [93000] = true,  -- Mad Tinkerer (Mad Tinkerer's)

    [106805] = true, -- Wisdom of Vanus (Vanus's)
    [106806] = true, -- Major Mending (Vanus's)

    [113139] = true, -- Bright-Throat's Boast (Bright-Throat's Boast)

    [129388] = true, -- Marauder's Haste (Marauder's Haste)
    [129389] = true, -- Marauder's Haste (Marauder's Haste)

    [135652] = true, -- Winter's Respite (of Winter's Respite)
    [135659] = true, -- Winter's Respite (of Winter's Respite)
    [135658] = true, -- Winter's Respite (of Winter's Respite)

    [147138] = true, -- Voidcaller (of the Voidcaller)
    [147141] = true, -- Voidcaller (of the Voidcaller)
    [147140] = true, -- Voidcaller (of the Voidcaller)

    -- Overland Sets (Medium)
    [71102] = true,  -- Briarheart
    [71106] = true,  -- Briarheart
    [71107] = true,  -- Briarheart

    [32734] = true,  -- Darkstride (Darkstride)

    [93300] = true,  -- Defiler (Defiler's)
    [93308] = true,  -- Defiler (Defiler's)
    [93304] = true,  -- Defiler (Defiler's)
    [93307] = true,  -- Defiler (Defiler's)
    [93305] = true,  -- Defiler (Defiler's)

    [29104] = true,  -- Fiord's Legacy (Fiord's)

    [79181] = true,  -- Flanking Strategist (of Flanking)

    [19165] = true,  -- Night Terror (of Night Terror)
    [32836] = true,  -- Night Terror (of Night Terror)
    [34875] = true,  -- Night Terror (of Night Terror)

    [32822] = true,  -- Salvation (of Salvation)

    [32808] = true,  -- Senche's Bite (Senche's)
    [127192] = true, -- Senche's Bite (Senche's)

    [32750] = true,  -- Stygian (Stygian)
    [144480] = true, -- Stygian (Stygian)

    [67099] = true,  -- Swamp Raider

    [85557] = true,  -- Sword-Singer (Sword-Singer's)

    [76573] = true,  -- Syvarra's Scales (of Syvarra's Scales)
    [75717] = true,  -- Syvarra's Scales (of Syvarra's Scales)
    [76344] = true,  -- Serpent's Spirit (of Syvarra's Scales)
    [75718] = true,  -- Serpent's Spirit (of Syvarra's Scales)

    [51504] = true,  -- Yokudan Air Stealth Detection (of the Air)
    [52708] = true,  -- Way of Air (of the Air)
    [52709] = true,  -- Way of Air (of the Air)

    [29107] = true,  -- Night Mother's Embrace (of the Night Mother)

    [32751] = true,  -- Ranger's Gait (of the Ranger)

    [29111] = true,  -- Shadow of the Red Mountain (of the Red Mountain)
    [97806] = true,  -- Shadow of the Red Mountain (of the Red Mountain)
    [34383] = true,  -- Shadow of the Red Mountain (of the Red Mountain)

    [32828] = true,  -- Twin Sisters (of the Twin Sisters)
    [34817] = true,  -- Twin Sisters Bleed (of the Twin Sisters)

    [32829] = true,  -- Wilderqueen's Arch (of the Wilderqueen)
    [34870] = true,  -- Wilderqueen's Arch (of the Wilderqueen)
    [141867] = true, -- Marauder's Haste (of the Wilderqueen)

    [99266] = true,  -- Unfathomable Darkness (of Unfathomable Darkness)
    [99267] = true,  -- Unfathomable Darkness (of Unfathomable Darkness)
    [99268] = true,  -- Unfathomable Darkness (of Unfathomable Darkness)

    [32729] = true,  -- Hide of the Werewolf (Werewolf Hide)
    [34508] = true,  -- Hide of the Werewolf (Werewolf Hide)

    [18991] = true,  -- Witchman Armor (Witchman's)
    [18993] = true,  -- Witchman Armor (Witchman's)
    [85818] = true,  -- Witchman Armor (Witchman's)
    [141869] = true, -- Witchman Armor (Witchman's)

    [106858] = true, -- Gryphon's Ferocity (Gryphon's)
    [106860] = true, -- Minor Expedition (Gryphon's)
    [106861] = true, -- Minor Force (Gryphon's)

    [113165] = true, -- Dead-Water's Guile (Dead-Water's Guile)
    [114977] = true, -- Dead-Water's Guile (Dead-Water's Guile)

    [121596] = true, -- Vesture of Darloc Brae (Darloc Brae's)
    [121615] = true, -- Vesture of Darloc Brae (Darloc Brae's)
    [121602] = true, -- Vesture of Darloc Brae (Darloc Brae's)
    [121618] = true, -- Vesture of Darloc Brae (Darloc Brae's)

    [129405] = true, -- Dragonguard Elite (Dragonguard Elite's)
    [129407] = true, -- Dragonguard Tactics (Dragonguard Elite's)

    [135687] = true, -- Venomous Smite (Venomous)
    [135690] = true, -- Hunter's Venom (Venomous)
    [137526] = true, -- Hunter's Venom (Venomous)

    [147145] = true, -- Witch-Knight's Defiance (Witch-Knight's)

    -- Overland Sets (Heavy)
    [32815] = true,  -- Meridia's Blessed Armor (Blessed)
    [34711] = true,  -- Meridia's Blessed Armor (Blessed)

    [57295] = true,  -- Draugr's Heritage (of Draugr Heritage)
    [57298] = true,  -- Draugr's Heritage (of Draugr Heritage)
    [57296] = true,  -- Draugr's Heritage (of Draugr Heritage)
    [57297] = true,  -- Draugr's Heritage (of Draugr Heritage)

    [99281] = true,  -- Livewire
    [99282] = true,  -- Livewire
    [99285] = true,  -- Livewire
    [99286] = true,  -- Livewire
    [99461] = true,  -- Livewire

    [79110] = true,  -- Hide of Morihaus (of Morihaus)
    [79506] = true,  -- Hide of Morihaus (of Morihaus)
    [79123] = true,  -- Hide of Morihaus (of Morihaus)
    [79507] = true,  -- Hide of Morihaus (of Morihaus)
    [79112] = true,  -- Hide of Morihaus (of Morihaus)

    [32752] = true,  -- Seventh Legion Brute (Seventh Legion's)
    [127270] = true, -- Seventh Legion Brute (Seventh Legion's)
    [127271] = true, -- Seventh Legion Brute (Seventh Legion's)

    [85593] = true,  -- Minor Heroism (Shalk's)

    [32838] = true,  -- Soulshine (of Soulshine)
    [144478] = true, -- Soulshine (of Soulshine)

    [18996] = true,  -- Akaviri Dragonguard (of the Dragon)

    [52710] = true,  -- Way of Fire (of the Fire)
    [52711] = true,  -- Way of Fire (of the Fire)

    [85570] = true,  -- Green Pact (of the Green Pact)

    [32736] = true,  -- Hatchling's Shell (of the Hatchling's Shell)
    [112523] = true, -- Hatchling's Shell (of the Hatchling's Shell)

    [85565] = true,  -- Minor Vitality (of the Order of Diagna)

    [71077] = true,  -- Mark of the Pariah (of the Pariah)

    [32814] = true,  -- Storm Knight's Plate (of the Storm Knight)
    [57210] = true,  -- Storm Knight's Plate (of the Storm Knight)
    [57209] = true,  -- Storm Knight's Plate (of the Storm Knight)

    [85551] = true,  -- Minor Protection (of the Vampire's Cloak)

    [29118] = true,  -- Armor of the Veiled Heritance (of the Veiled Heritance)
    [127275] = true, -- Armor of the Veiled Heritance (of the Veiled Heritance)

    [32830] = true,  -- Wyrd Tree's Blessing (of the Wyrd Tree)

    [29116] = true,  -- Thunderbug's Carapace (Thunderbug's)
    [33497] = true,  -- Thunderbug's Carapace (Thunderbug's)

    [92762] = true,  -- Minor Toughness (Warrior-Poet's)

    [106865] = true, -- Grace of Gloom (Gloom-Graced)
    [106867] = true, -- Major Evasion (Gloom-Graced)
    [106868] = true, -- Grace of Gloom (Gloom-Graced)

    [113284] = true, -- Champion of the Hist (Champion of the Hist)

    [121633] = true, -- Call of the Undertaker (Undertaker's)
    [121634] = true, -- Lifesteal (Undertaker's)

    [129438] = true, -- Senchal Defender (Senchal Defender's)
    [129442] = true, -- Senchal's Duty (Senchal Defender's)
    [129616] = true, -- FX Holder (Senchal Defender's)
    [129509] = true, -- Senchal Defender (Senchal Defender's)
    [129523] = true, -- Senchal Defender (Senchal Defender's)

    [147220] = true, -- Radiant Bastion (of the Radiant Bastion)
    [147221] = true, -- Radiant Bastion (of the Radiant Bastion)

    -- Dungeon Sets (Light)
    [60418] = true,  -- Burning Spellweave
    [61459] = true,  -- Burning Spellweave
    [60419] = true,  -- Burning Spellweave

    [102026] = true, -- Caluurion's Legacy
    [102027] = true, -- Caluurion's Legacy (Fire)
    [102032] = true, -- Caluurion's Legacy (Ice)
    [102033] = true, -- Caluurion's Legacy (Disease)
    [102034] = true, -- Caluurion's Legacy (Shock)

    [97532] = true,  -- Draugr's Rest
    [97538] = true,  -- Draugr's Rest
    [97539] = true,  -- Draugr's Rest

    [97572] = true,  -- Flame Blossom
    [99144] = true,  -- Flame Blossom
    [97573] = true,  -- Flame Blossom
    [97574] = true,  -- Flame Blossom

    [84340] = true,  -- Gossamer (Gossamer)
    [84341] = true,  -- Major Evasion (Gossamer)

    [101978] = true, -- Jorvuld's Guidance
    [110030] = true, -- Jorvuld's Guidance FX

    [85609] = true,  -- Lamia's Song (Lamia's)
    [85610] = true,  -- Lamia's Song (Lamia's)
    [85636] = true,  -- Lamia's Song (Lamia's)
    [143097] = true, -- Lamia's Song (Lamia's)
    [143098] = true, -- Lamia's Song (Lamia's)

    [85604] = true,  -- Light Speaker (Light Speaker's)

    [67093] = true,  -- Overwhelming Surge (Overwhelming)
    [67129] = true,  -- Overwhelming Surge (Overwhelming)
    [67136] = true,  -- Overwhelming Surge (Overwhelming)
    [127131] = true, -- Overwhelming Surge (Overwhelming)

    [29099] = true,  -- Prayer Shawl (of Prayer)
    [34504] = true,  -- Prayer Shawl (of Prayer)

    [88764] = true,  -- Sanctuary (of Sanctuary)
    [32834] = true,  -- Sanctuary (of Sanctuary)

    [85603] = true,  -- Spider Cultist Cowl (Spider Cultist's)

    [66899] = true,  -- Spell Power Cure (Spell Power Cure)
    [66902] = true,  -- Spell Power Cure (Spell Power Cure)

    [67096] = true,  -- Combat Physician (of the Combat Physician)
    [67098] = true,  -- Combat Physician (of the Combat Physician)
    [69291] = true,  -- ICP Light Heal Set (of the Combat Physician)

    [18987] = true,  -- Shroud of the Lich (of the Lich)
    [57164] = true,  -- Shroud of the Lich (of the Lich)

    [32826] = true,  -- Magicka Furnace (of the Magicka Furnace)
    [34813] = true,  -- Magicka Furnace (of the Magicka Furnace)

    [29100] = true,  -- Noble Duelist's Silks (of the Noble Duelist)
    [34373] = true,  -- Noble Duelist's Silks (of the Noble Duelist)

    [85606] = true,  -- Netch's Touch (of the Netch's Touch)

    [67287] = true,  -- Scathing Mage (of the Scathing Mage)
    [67288] = true,  -- Scathing Mage (of the Scathing Mage)

    [59675] = true,  -- Undaunted Unweaver (of the Undaunted Unweaver)
    [59676] = true,  -- Undaunted Unweaver (of the Undaunted Unweaver)

    [57162] = true,  -- Robes of the Warlock (of the Warlock)
    [57163] = true,  -- Robes of the Warlock (of the Warlock)

    [88763] = true,  -- Worm's Raiment (of the Worm Cult)
    [47367] = true,  -- Worm's Raiment (of the Worm Cult)

    [85613] = true,  -- Major Prophecy (Treasure Hunter's)

    [111376] = true, -- Hanu's Compassion (Hanu's Compassion)
    [111377] = true, -- Major Heroism (Hanu's Compassion)
    [111380] = true, -- Major Heroism (Hanu's Compassion)

    [111200] = true, -- Moon Hunter (Moon Hunter)
    [111204] = true, -- Moon Hunter (Moon Hunter)

    [116726] = true, -- Icy Conjuror
    [117666] = true, -- Icy Conjuror
    [116727] = true, -- Icy Conjuror

    [116882] = true, -- Auroran's Thunder (Auroran's Thunder)
    [116884] = true, -- Auroran's Thunder (Auroran's Thunder)
    [116920] = true, -- Auroran's Thunder (Auroran's Thunder)

    [126921] = true, -- Hollowfang Thirst (Hollowfang)
    [126924] = true, -- Hollowfang Thirst (Hollowfang)
    [126925] = true, -- Minor Vitality (Hollowfang)
    [126938] = true, -- Hollowfang Thirst (Hollowfang)

    [126593] = true, -- Z'en's Redress (Z'en's)
    [126597] = true, -- Touch of Z'en (Z'en's)

    [133209] = true, -- Hiti's Hearth (Hiti)
    [133210] = true, -- Warming Aura (Hiti)
    [133211] = true, -- Hiti's Hearth (Hiti)
    [133212] = true, -- Hiti's Hearth (Hiti)
    [133217] = true, -- Hiti's Hearth (Hiti)
    [135130] = true, -- Hiti's Hearth (Hiti)

    [133387] = true, -- Draugrkin's Grip (Draugrkin)
    [133406] = true, -- Draugrkin's Grip (Draugrkin)

    [142596] = true, -- Elemental Catalyst (Elemental Catalyst)
    [142610] = true, -- Flame Weakness (Elemental Catalyst)
    [142652] = true, -- Frost Weakness (Elemental Catalyst)
    [142653] = true, -- Shock Weakness (Elemental Catalyst)

    -- Dungeon Sets (Medium)
    [85607] = true,  -- Strength of the Automaton (Automaton's)

    [29105] = true,  -- Barkskin
    [85977] = true,  -- Barkskin
    [85978] = true,  -- Barkskin

    [97567] = true,  -- Blooddrinker

    [85617] = true,  -- Bone Pirate's Tatters (Bone Pirate's)

    [84305] = true,  -- Heem-Jas' Retribution (Heem-Jas')
    [84310] = true,  -- Heem-Jas' Retribution (Heem-Jas')

    [88760] = true,  -- Hircine's Veneer (Hircine's)
    [47365] = true,  -- Hircine's Veneer (Hircine's)

    [85602] = true,  -- Minor Expedition (Jailbreaker)

    [32809] = true,  -- Oblivion's Edge
    [34612] = true,  -- Oblivion's Edge
    [57206] = true,  -- Oblivion's Edge

    [97712] = true,  -- Pillar of Nirn
    [97714] = true,  -- Pillar of Nirn
    [97716] = true,  -- Pillar of Nirn
    [97743] = true,  -- Pillar of Nirn

    [102104] = true, -- Plague Slinger
    [102106] = true, -- Skeever Corpse
    [102113] = true, -- Plague Slinger

    [67140] = true,  -- Sheer Venom (of Sheer Venom)
    [67141] = true,  -- Sheer Venom (of Sheer Venom)

    [85624] = true,  -- Spelunker (Spelunker's)
    [85626] = true,  -- Spelunker (Spelunker's)
    [85635] = true,  -- Spelunker (Spelunker's)
    [143136] = true, -- Spelunker (Spelunker's)

    [66939] = true,  -- Storm Master (Storm Master's)
    [70298] = true,  -- Storm Master (Storm Master's)

    [85622] = true,  -- Sword Dancer (Sword Dancer's)

    [60059] = true,  -- Sunderflame (Sunderflame)
    [60060] = true,  -- Sunderflame (Sunderflame)
    [108825] = true, -- Minor Breach (Sunderflame)

    [32780] = true,  -- Crusader (of the Crusader)
    [49220] = true,  -- Extra dodge (of the Crusader)

    [85605] = true,  -- Major Savagery (Toothrow)

    [67296] = true,  -- Essence Thief (of the Essence Thief)
    [67324] = true,  -- WGT Medium Set 1 (of the Essence Thief)
    [67298] = true,  -- Essence Thief (of the Essence Thief)
    [67308] = true,  -- Essence Thief (of the Essence Thief)
    [67326] = true,  -- Essence Thief (of the Essence Thief)
    [67330] = true,  -- Essence Thief (of the Essence Thief)
    [67334] = true,  -- Essence Thief (of the Essence Thief)
    [70284] = true,  -- Essence Thief (of the Essence Thief)
    [70290] = true,  -- Essence Thief (of the Essence Thief)

    [59666] = true,  -- Undaunted Infiltrator (of the Undaunted Infiltrator)
    [59667] = true,  -- Undaunted Infiltrator (of the Undaunted Infiltrator)

    [29106] = true,  -- Viper's Sting (of the Viper)
    [33691] = true,  -- Viper's Sting (of the Viper)

    [101969] = true, -- Trappings of Invigoration
    [101970] = true, -- Trappings of Invigoration

    [84349] = true,  -- Widowmaker
    [97851] = true,  -- Widowmaker
    [84350] = true,  -- Widowmaker

    [111385] = true, -- Blood Moon (Blood Moon)
    [111387] = true, -- Blood Scent (Blood Moon)
    [111399] = true, -- Counter Buffer (Blood Moon)
    [111386] = true, -- Frenzied (Blood Moon)

    [111213] = true, -- Savage Werewolf (Savage Werewolf)
    [112368] = true, -- Impact (Savage Werewolf)
    [111216] = true, -- Savage Werewolf (Savage Werewolf)

    [116734] = true, -- Tzogvin's Warband (Tzogvin's Warband)
    [116742] = true, -- Precision (Tzogvin's Warband)
    [116775] = true, -- Minor Force (Tzogvin's Warband)

    [116947] = true, -- Scavenging Demise (Scavenging Demise)
    [116954] = true, -- Stalked (Scavenging Demise)
    [116991] = true, -- Scavenging Maw (Scavenging Demise)
    [117025] = true, -- Minor Vulnerability (Scavenging Demise)

    [126575] = true, -- Dro'Zakar's Claws (Dro'Zakar's)
    [126584] = true, -- Dro'Zakar FX (Dro'Zakar's)

    [126629] = true, -- Azureblight Reaper (Azureblight)
    [126631] = true, -- Blight Seed (Azureblight)
    [126633] = true, -- Blight Seed (Azureblight)

    [133490] = true, -- Aegis Caller (Aegis Caller's)
    [133493] = true, -- Lesser Aegis (Aegis Caller's)
    [133494] = true, -- Aegis Caller (Aegis Caller's)

    [133281] = true, -- Titanborn Strength (Titanborn's)

    [141203] = true, -- Unleashed Terror (Unleashed)
    [141204] = true, -- Unleashed Terror (Unleashed)

    [142686] = true, -- Kraglen's Howl (Kraglen's)
    [142687] = true, -- Kraglen's Howl (Kraglen's)
    [142705] = true, -- Kraglen's Howl (Kraglen's)
    [142775] = true, -- Heed the Call (Kraglen's)
    [142817] = true, -- Kraglen's Howl (Kraglen's)
    [142816] = true, -- Kraglen's Howl (Kraglen's)
    [143536] = true, -- Synergy Bonus (Kraglen's)
    [142780] = true, -- Heed the Call (Kraglen's)
    [142713] = true, -- Kraglen CD (Kraglen's)

    -- Dungeon Sets (Heavy)
    [102008] = true, -- Curse of Doylemish
    [102023] = true, -- Curse of Doylemish

    [32825] = true,  -- Duneripper's Scales (Duneripper)
    [134930] = true, -- Duneripper's Scales (Duneripper)

    [32754] = true,  -- Durok's Bane (of Durok's Bane)
    [34527] = true,  -- Durok's Bane Major Defile (of Durok's Bane)
    [113456] = true, -- Durok's Bane (of Durok's Bane)

    [82890] = true,  -- Ebon Armory (Ebon)
    [47362] = true,  -- Ebon Armory (Ebon)

    [59694] = true,  -- Embershield
    [59695] = true,  -- Embershield
    [59696] = true,  -- Embershield

    [97907] = true,  -- Hagraven's Garden (Hagraven's)
    [97908] = true,  -- Hagraven's Garden (Hagraven's)
    [97910] = true,  -- Hagraven's Garden (Hagraven's)

    [29123] = true,  -- The Ice Furnace (Ice Furnace)
    [34404] = true,  -- Frostfire (Ice Furnace)

    [97616] = true,  -- Ironblood (Ironblood)
    [97626] = true,  -- Ironblood (Ironblood)
    [97627] = true,  -- Ironblood (Ironblood)

    [67077] = true,  -- Jolting Arms (Jolting)
    [67079] = true,  -- WGT Heavy Set 2 (Jolting)
    [67078] = true,  -- Jolting Arms (Jolting)

    [85619] = true,  -- Knight-Errant's Mail (Knight-Errant's)
    [85620] = true,  -- Knight-Errant's Mail (Knight-Errant's)

    [67202] = true,  -- Leeching Plate (of Leeching)
    [67205] = true,  -- Leeching Plate (of Leeching)
    [69345] = true,  -- Leeching Plate (of Leeching)
    [67204] = true,  -- Leeching Plate (of Leeching)

    [84275] = true,  -- Aspect of Mazzatun (of Mazzatun)
    [84277] = true,  -- Aspect of Mazzatun (of Mazzatun)
    [84278] = true,  -- Aspect of Mazzatun (of Mazzatun)
    [84279] = true,  -- Aspect of Mazzatun (of Mazzatun)

    [85611] = true,  -- Minor Force (of Medusa)

    [84353] = true,  -- Hand of Mephala (of Mephala's Hand)
    [84354] = true,  -- Hand of Mephala (of Mephala's Hand)
    [84357] = true,  -- Hand of Mephala Webbing (of Mephala's Hand)
    [84355] = true,  -- Hand of Mephala (of Mephala's Hand)
    [84358] = true,  -- Minor Breach (of Mephala's Hand)

    [32755] = true,  -- Nikulas' Heavy Armor (of Nikulas)

    [85623] = true,  -- Major Sorcery (Rattlecage)

    [32735] = true,  -- Major Brutality (of the Dreugh King Slayer)
    [34511] = true,  -- Major Expedition (of the Dreugh King Slayer)

    [66882] = true,  -- Brands of the Imperium (of the Imperium)
    [66887] = true,  -- Brands of the Imperium (of the Imperium)

    [29117] = true,  -- Knightmare (of the Knightmare)
    [33512] = true,  -- Minor Maim (of the Knightmare)

    [29115] = true,  -- Sargeant's Mail (of the Sargeant)

    [67280] = true,  -- Tormentor (of the Tormentor)
    [67283] = true,  -- Tormentor Resistance (of the Tormentor)

    [59663] = true,  -- Undaunted Bastion (of the Undaunted Bastion)
    [61200] = true,  -- Undaunted Bastion (of the Undaunted Bastion)

    [32818] = true,  -- Armor of Truth (of Truth)
    [86070] = true,  -- Armor of Truth (of Truth)

    [101974] = true, -- Ulfnor's Favor

    [111432] = true, -- Haven of Ursus (Haven of Ursus)
    [111442] = true, -- Haven of Ursus (Haven of Ursus)
    [111443] = true, -- Haven of Ursus (Haven of Ursus)
    [112414] = true, -- Ursus's Blessing (Haven of Ursus)
    [111440] = true, -- Ursus CD (Haven of Ursus)
    -- [113423] = true, -- Checker (Haven of Ursus)

    [111220] = true, -- Jailer's Tenacity (Jailer's Tenacity)
    [111221] = true, -- Major Vitality (Jailer's Tenacity)

    [116798] = true, -- Mighty Glacier (Mighty Glacier)
    [117670] = true, -- Mighty Glacier (Mighty Glacier)
    [116805] = true, -- Major Resolve (Mighty Glacier)

    [117059] = true, -- Frozen Watcher (Frozen Watcher)
    [117082] = true, -- Frozen Watcher (Frozen Watcher)
    [117060] = true, -- Frozen Watcher (Frozen Watcher)

    [126531] = true, -- Renald's Resolve (Renald's)
    [126535] = true, -- Resolve (Renald's)

    [126680] = true, -- Dragon's Defilement (Defiled Dragon's)
    [126682] = true, -- Dragon's Defilement (Defiled Dragon's)
    [126685] = true, -- Minor Breach (Defiled Dragon's)

    [133290] = true, -- Bani's Torment (Bani's)
    [133292] = true, -- Major Maim (Bani's)
    [133318] = true, -- Major Vitality (Bani's)

    [133430] = true, -- Grave Guardian (Grave Guardian's)
    [135554] = true, -- Grave Guardian (Grave Guardian's)
    [133451] = true, -- Grave Guardian (Grave Guardian's)

    [141636] = true, -- Crimson Twilight (Crimson)
    [141638] = true, -- Crimson Twilight (Crimson)
    [141642] = true, -- Crimson Twilight (Crimson)
    [141865] = true, -- Crimson Twilight (Crimson)
    [145415] = true, -- Crimson Twilight (Crimson)

    [142654] = true, -- Arkasis's Genius (Arkasis)
    [142660] = true, -- Arkasis's Genius (Arkasis)

    -- Trial Sets (Hel Ra Citadel)
    [50971] = true,  -- Berserking Warrior (Advancing Yokeda)
    [50978] = true,  -- Berserking Warrior (Advancing Yokeda)

    [51300] = true,  -- Immortal Warrior (Immortal Yokeda)
    [129477] = true, -- Major Protection (Immortal Yokeda)

    [50990] = true,  -- Defending Warrior (Resilient Yokeda)
    [86907] = true,  -- Defending Warrior (Resilient Yokeda)
    [50992] = true,  -- Defending Warrior (Resilient Yokeda)

    [61436] = true,  -- Eternal Warrior (Eternal Yokeda)
    [127235] = true, -- Eternal Warrior (Eternal Yokeda)
    [127236] = true, -- Eternal Warrior (Eternal Yokeda)

    -- Trial Sets (Aetherian Archive)
    [51314] = true,  -- Destructive Mage (Aether ... of Destruction)
    [51315] = true,  -- Destructive Mage (Aether ... of Destruction)
    [51320] = true,  -- Mage Destruction Bomb (Aether ... of Destruction)
    [137519] = true, -- Destructive Mage (Aether ... of Destruction)

    [51442] = true,  -- Healing Mage (of Mending)
    [51443] = true,  -- Minor Cowardice (of Mending)

    [51432] = true,  -- Wise Mage (Aether ... of Strategy)
    [51434] = true,  -- Minor Vulnerability (Aether ... of Strategy)

    [61438] = true,  -- Infallible Mage (of the Infallible Aether)
    [81519] = true,  -- Minor Vulnerability (of the Infallible Aether)

    -- Trial Sets (Sanctum Ophidia)
    [51132] = true, -- Poisonous Serpent (Ophidian ... of Venom)
    [51241] = true, -- Poisonous Serpent (Ophidian ... of Venom)

    [51170] = true, -- Twice-Fanged Serpent (of the Two-Fanged Snake)
    [51176] = true, -- Twice-Fanged Serpent (of the Two-Fanged Snake)

    [50995] = true, -- Quick Serpent (Ophidian... of Celerity)
    [50997] = true, -- Major Expedition (Ophidian... of Celerity)
    [57159] = true, -- Quick Serpent (Ophidian... of Celerity)

    [61440] = true, -- Vicious Serpent (of the Vicious Ophidian)
    [81524] = true, -- Quick Serpent (of the Vicious Ophidian)
    [81522] = true, -- Serpent Stamina (of the Vicious Ophidian)

    -- Trial Sets (Maw of Lorkhaj)
    [75797] = true,  -- Moondancer (Moondancer)
    [75801] = true,  -- Lunar Blessing (Moondancer)
    [75804] = true,  -- Shadow Blessing (Moondancer)

    [75751] = true,  -- Roar of Alkosh (of Alkosh)
    [78835] = true,  -- Roar of Alkosh Miss (of Alkosh)
    [75752] = true,  -- Roar of Alkosh (of Alkosh)
    [75753] = true,  -- Line Breaker (of Alkosh)
    [76667] = true,  -- Roar of Alkosh (of Alkosh)

    [75813] = true,  -- Lunar Bastion (of the Lunar Bastion)
    [75814] = true,  -- Lunar Baston (of the Lunar Bastion)
    [75815] = true,  -- Lunar Bastion (of the Lunar Bastion)
    [142804] = true, -- Lunar Bastion (of the Lunar Bastion)
    [142808] = true, -- Lunar Bastion (of the Lunar Bastion)

    [75766] = true,  -- Twilight Remedy (of Twilight Remedy)
    [75768] = true,  -- Primal Heal (of Twilight Remedy)
    [75770] = true,  -- Twilight Remedy (of Twilight Remedy)
    [76564] = true,  -- Minor Force (of Twilight Remedy)

    -- Trial Sets (Halls of Fabrication)
    [93443] = true, -- Automated Defense (Automated Defense)
    [93444] = true, -- Major Aegis (Automated Defense)

    [93124] = true, -- Inventor's Guard (Inventor's Guard)
    [93125] = true, -- Major Aegis (Inventor's Guard)

    [93119] = true, -- Master Architect (Master Architect)
    [93120] = true, -- Major Slayer (Master Architect)

    [93441] = true, -- War Machine (War Machine)
    [93442] = true, -- Major Slayer (War Machine)

    -- Trial Sets (Cloudrest)
    [107117] = true, -- Vestment of Olirime (Olorime's)
    [107141] = true, -- Vestment of Olirime (Olorime's)
    [109994] = true, -- Major Courage (Olorime's)

    [109082] = true, -- Ideal Vestment of Olorime (Olorime's Perfect)
    [109084] = true, -- Ideal Vestment of Olorime (Olorime's Perfect)
    [110020] = true, -- Major Courage (Olorime's Perfect)

    [107093] = true, -- Mantle of Siroria (Siroria's)
    [107095] = true, -- Mantle of Siroria (Siroria's)
    [110118] = true, -- Siroria's Boon (Siroria's)

    [109079] = true, -- Ideal Mantle of Siroria (Perfect Siroria's)
    [109081] = true, -- Ideal Mantle of Siroria (Perfect Siroria's)
    [110142] = true, -- Siroria's Boon (Siroria's)
    [110143] = true, -- Siroria's Boon (Siroria's)

    [107202] = true, -- Arms of Relequen (Relequen's)
    [110504] = true, -- Arms of Relequen (Relequen's)
    [107203] = true, -- Arms of Relequen (Relequen's)

    [109085] = true, -- Ideal Arms of Relequen (Perfect Relequen's)
    [110512] = true, -- Ideal Arms of Relequen (Perfect Relequen's)
    [109086] = true, -- Ideal Arms of Relequen (Perfect Relequen's)

    [107268] = true, -- Aegis of Galenwe (Galenwe's)
    [109976] = true, -- Empower (Galenwe's)

    [109088] = true, -- Ideal Aegis of Galenwe (Galenwe's)
    [109989] = true, -- Empower (Galenwe's)

    -- Trial Sets (Sunspire)
    [121823] = true, -- False God's Devotion (False God's Devotion)
    [121827] = true, -- Major Expedition (False God's Devotion)
    [121829] = true, -- False God's Devotion (False God's Devotion)

    [124799] = true, -- Perfected False God's Devotion (Perfected False God's Devotion)
    [124801] = true, -- Major Expedition (Perfected False God's Devotion)
    [124800] = true, -- Perfected False God's Devotion (Perfected False God's Devotion)

    [121894] = true, -- Eye of Nahviintaas (Nahviintaas')
    [121895] = true, -- Eye of Nahviintaas (Nahviintaas')
    [121898] = true, -- Eye of Nahviintaas (Nahviintaas')
    [124795] = true, -- Tracking Buff (Nahviintaas')
    [122812] = true, -- Eye of Nahviintaas (Nahviintaas')

    [121867] = true, -- Tooth of Lokkestiiz (Lokkestiiz's)
    [121871] = true, -- Major Slayer (Lokkestiiz's)

    [121875] = true, -- Claw of Yolnakhriin (Yolnakriin's)
    [121878] = true, -- Minor Courage (Yolnakriin's)

    -- Trial Sets (Kyne's Aegis)
    [135920] = true, -- Roaring Opportunist (Roaring Opportunist's)
    [135924] = true, -- Roaring Opportunist Cooldown (Roaring Opportunist's)
    [135923] = true, -- Major Slayer (Roaring Opportunist's)
    [137984] = true, -- Roaring Opportunist (Roaring Opportunist's Perfected)
    [137985] = true, -- Roaring Opportunist Cooldown (Roaring Opportunist's Perfected)
    [137986] = true, -- Major Slayer (Roaring Opportunist's Perfected)

    [136045] = true, -- Kyne's Wind (of Kyne's Wind)
    [136098] = true, -- Kyne's Blessing (of Kyne's Wind)
    [136101] = true, -- Kyne's Wind (of Kyne's Wind)
    [136099] = true, -- Kyne's Wind (of Kyne's Wind)
    [137992] = true, -- Kyne's Wind (of Kyne's Wind (Perfect))
    [137995] = true, -- Kyne's Blessing (of Kyne's Wind (Perfect))
    [137996] = true, -- Kyne's Wind (of Kyne's Wind (Perfect))
    [137993] = true, -- Kyne's Wind (of Kyne's Wind (Perfect))

    [135944] = true, -- Yandir's Might (Yandir's)
    [135950] = true, -- Giant's Endurance (Yandir's)
    [135951] = true, -- Giant's Might (Yandir's)
    [138012] = true, -- Yandir's Might (Yandir's Perfect)
    [138013] = true, -- Giant's Endurance (Yandir's Perfect)
    [138019] = true, -- Giant's Might (Yandir's Perfect)

    [135925] = true, -- Vrol's Command (Vrol's)
    [135926] = true, -- Major Aegis (Vrol's)
    [137988] = true, -- Vrol's Command (Vrol's Perfect)
    [137989] = true, -- Major Aegis (Vrol's Perfect)

    -- Battleground Sets
    [92908] = true,  -- Coward's Gear (Coward's Gear)
    [92909] = true,  -- Major Protection (Coward's Gear)
    [144708] = true, -- Major Expedition (Coward's Gear)

    [93099] = true,  -- Knight Slayer
    [93104] = true,  -- Knight Slayer

    [92914] = true,  -- Vanguard's Challenge
    [92916] = true,  -- Vanguard's Challenge

    [92920] = true,  -- Wizard's Riposte (Wizard's Riposte)
    [92921] = true,  -- Minor Maim (Wizard's Riposte)

    -- Imperial City Sets
    [61761] = true,  -- Black Rose (of the Black Rose)

    [79419] = true,  -- Galerion's Revenge (Galerion's)
    [79421] = true,  -- Mark of Revenge (Galerion's)
    -- [79771] = true, -- U10 AVA MA/LA 1 (Galerion's)
    [79420] = true,  -- Galerion's Revenge (Galerion's)

    [79405] = true,  -- Imperial Physique (Imperial Physique)
    [79411] = true,  -- 4x Bonus (Imperial Physique)

    [61775] = true,  -- Supporting Soldier Trigger (of Meritorious Service)
    [65706] = true,  -- Meritorious Service (of Meritorious Service)

    [68933] = true,  -- Phoenix (of the Phoenix)
    [127032] = true, -- Phoenix (of the Phoenix)
    [127036] = true, -- Phoenix's Flame (of the Phoenix)

    [61763] = true,  -- Powerful Assault Trigger (of the Powerful Assault)
    [61771] = true,  -- Powerful Assault (of the Powerful Assault)

    [68947] = true,  -- Reactive Armor (Reactive)
    [69567] = true,  -- Reactive Armor Effects (Reactive)

    [68973] = true,  -- Shield Breaker (of the Shield Breaker)

    [79362] = true,  -- Thews of the Harbinger (of the Harbinger)
    [79363] = true,  -- Thews of the Harbinger (of the Harbinger)

    [79464] = true,  -- Vicecanon of Venom
    [79469] = true,  -- Deadly Venom
    [79471] = true,  -- Venom Heal

    -- Cyrodiil Sets (Light)
    [32802] = true,  -- Almalexia's Mercy (of Almalexia's Mercy)
    [34605] = true,  -- Almalexia's Mercy (of Almalexia's Mercy)

    [32779] = true,  -- Robes of Alteration Mastery (of Alteration Mastery)

    [32819] = true,  -- The Arch-Mage (of the Arch-Mage)
    [70392] = true,  -- The Arch-Mage (of the Arch-Mage)

    [32827] = true,  -- Curse Eater (Curse-Eating)
    [117359] = true, -- Curse Eater (Curse-Eating)
    [117360] = true, -- Curse Eater (Curse-Eating)

    [32833] = true,  -- Light of Cyrodiil (of Cyrodiil's Light)
    [111550] = true, -- Light of Cyrodiil (of Cyrodiil's Light)

    [129374] = true, -- Wrath of Imperium (of Imperial Wrath)

    [29093] = true,  -- Desert Rose (of the Desert Rose)
    [33498] = true,  -- Desert Rose (of the Desert Rose)

    [47351] = true,  -- Buffer of the Swift (of the Swift)

    -- Cyrodiil Sets (Medium)
    [32835] = true,  -- Crest of Cyrodiil (of Cyrodiil's Ward)
    [34876] = true,  -- Major Defile (of Cyrodiil's Ward)

    [117402] = true, -- Deadly Strike (Deadly)

    [47361] = true,  -- Eagle Eye (Eagle-Eyed)

    [32823] = true,  -- Hawk's Eye (of Hawk's Eye)

    [32731] = true,  -- Kyne's Kiss (of Kyne's Kiss)
    [34509] = true,  -- Kyne's Kiss (of Kyne's Kiss)
    [70492] = true,  -- Kyne's Kiss (of Kyne's Kiss)

    [29112] = true,  -- The Morag Tong (of the Morag Tong)
    [34384] = true,  -- The Morag Tong (of the Morag Tong)

    [32807] = true,  -- Sentry (of the Sentry)
    [117391] = true, -- Sentry (of the Sentry)
    [117397] = true, -- Exhausted Sentry (of the Sentry)

    [32747] = true,  -- Shadow Walker (of the Shadow Walker)
    [57180] = true,  -- Shadow Walker (of the Shadow Walker)
    [57181] = true,  -- Shadow Walker (of the Shadow Walker)

    [47353] = true,  -- Shield of the Valiant (of the Valiant)

    [47357] = true,  -- Vengeance Leech (of Vengeance Leech)
    [47358] = true,  -- Vengeance Leech (of Vengeance Leech)
    [47359] = true,  -- Vengeance Leech (of Vengeance Leech)
    [47360] = true,  -- Vengeance Leech (of Vengeance Leech)

    -- Cyrodiil Sets (Heavy)
    [32824] = true,  -- Affliction (Afflicted)
    [34787] = true,  -- Affliction (Afflicted)

    [117344] = true, -- Beckoning Steel (of Beckoning Steel)
    [29122] = true,  -- Beckoning Steel (of Beckoning Steel)

    [32837] = true,  -- Ward of Cyrodiil (of Cyrodiil's Crest)
    [111575] = true, -- Crest of Cyrodiil (of Cyrodiil's Crest)

    [32800] = true,  -- Elf Bane (of Elf Bane)

    [32831] = true,  -- Ravager (Ravaging)
    [127280] = true, -- Ravager (Ravaging)
    [127284] = true, -- Ravager (Ravaging)

    [29121] = true,  -- Armor of the Alessian Order (of the Alessian Order)

    [47348] = true,  -- Bastion of the Heartland (of the Heartland)
    [47350] = true,  -- Bastion of the Heartland (of the Heartland)

    [32737] = true,  -- The Juggernaut (of the Juggernaut)
    [34512] = true,  -- The Juggernaut (of the Juggernaut)
    [142401] = true, -- The Juggernaut (of the Juggernaut)

    [129364] = true, -- Battle Hardened (of the Potentates)
    [47356] = true,  -- Blessing of the Potentates (of the Potentates)

    -- Rewards for the Worthy Sets
    [113522] = true, -- Battalion Defender (Battalion Defender)
    [113523] = true, -- Battalion Defender (Battalion Defender)

    [113419] = true, -- Battlefield Acrobat (Battlefield Acrobat)

    [113324] = true, -- Indomitable Fury (Indomitable Fury)
    [113355] = true, -- Minor Heroism (Indomitable Fury)
    [113356] = true, -- Minor Protection (Indomitable Fury)

    [113460] = true, -- Soldier of Anguish (Soldier of Anguish)
    [115771] = true, -- Soldier of Anguish (Soldier of Anguish)
    [113461] = true, -- Heal Absorption (Soldier of Anguish)

    [113378] = true, -- Spell Strategist (Spell Strategist)
    [113382] = true, -- Spell Strategist (Spell Strategist)
    [113417] = true, -- Spell Strategist (Spell Strategist)

    [113508] = true, -- Steadfast Hero (Steadfast Hero)
    [113509] = true, -- Major Protection (Steadfast Hero)

    [76946] = true,  -- Fasalla's Guile (of Fasalla's Guile)
    [146041] = true, -- Fasalla's Guile (of Fasalla's Guile)
    [76947] = true,  -- Fasalla's Guile (of Fasalla's Guile)

    [76949] = true,  -- Warrior's Fury (of Fury)
    [76950] = true,  -- Warrior's Fury (of Fury)
    [128494] = true, -- Warrior's Fury (of Fury)

    [76940] = true,  -- Leki's Focus (Leki's)

    [76932] = true,  -- Marksman's Crest (Markman's)

    [76934] = true,  -- Robes of Transmutation (Transmutation)
    [76936] = true,  -- Robes of Transmutation (Transmutation)

    [76937] = true,  -- Vicious Death (of Vicious Death)
    [82987] = true,  -- Vicious Death (of Vicious Death)
    [76938] = true,  -- Vicious Death (of Vicious Death)

    -- Maelstrom Arena Sets
    [71248] = true,  -- Elemental Succession (of Succession)
    [127081] = true, -- Flame Succession (of Succession)
    [127084] = true, -- Shock Succession (of Succession)
    [127088] = true, -- Frost Succession (of Succession)

    [71644] = true,  -- Winterborn (Winterborn)
    [71647] = true,  -- Winterborn (Winterborn)
    [73296] = true,  -- Winterborn Snare (Winterborn)
    [71646] = true,  -- Winterborn (Winterborn)

    [71603] = true,  -- Hunt Leader (of the Hunt)
    [71604] = true,  -- Mark of the Hunt Leader (of the Hunt)
    [71605] = true,  -- Hunt Leader (of the Hunt)
    [74106] = true,  -- Hunt Leader (of the Hunt)
    [71191] = true,  -- Para Bellum (Para Bellum)
    [71193] = true,  -- Para Bellum Shield (Para Bellum)

    [71180] = true,  -- Glorious Defender (of Glory)
    [71188] = true,  -- Glorious Defense (of Glory)
    [71186] = true,  -- Dodge Trigger (of Glory)
    [71101] = true,  -- Permafrost (of Permafrost)

    -- Dragonstar Arena Sets
    [29103] = true, -- Archer's Mind (of the Archer's Mind)
    [57167] = true, -- Archer's Mind (of the Archer's Mind)
    [32806] = true, -- Robes of Destruction Mastery (of Destruction Mastery)
    [29114] = true, -- Footman's Fortune (of the Footman)
    [29096] = true, -- Minor Mending (of the Healer)

    -- Vatesharn Hollows Sets
    [147668] = true, -- Hex Siphon (Hex Siphoner's)
    [147676] = true, -- Hex Siphon (Hex Siphoner's)
    [147675] = true, -- Hex Siphon (Hex Siphoner's)
    [147677] = true, -- Hex Siphon (Hex Siphoner's)

    [147681] = true, -- Pestilent Host (of the Pestilent Host)
    [147683] = true, -- Pestilent Host (of the Pestilent Host)
    [147682] = true, -- Pestilent Host (of the Pestilent Host)
    [147686] = true, -- Pestilent Host (of the Pestilent Host)

    [147690] = true, -- Explosive Rebuke (of Explosive Rebuke)
    [147692] = true, -- Explosive Rebuke (of Explosive Rebuke)
    [147694] = true, -- Explosive Rebuke (of Explosive Rebuke)
    [147693] = true, -- Explosive Rebuke (of Explosive Rebuke)

    [147414] = true, -- Ring of the Pale Order (Ring of the Pale Order)
    [147415] = true, -- Ring of the Pale Order (Ring of the Pale Order)

    [147459] = true, -- Pearls of Ehlnofey (Pearls of Ehlnofey)
    [147462] = true, -- Pearls of Ehlnofey (Pearls of Ehlnofey)

    -- Disguises
    [46281] = true, -- Necromancer Disguise (Bloodthorn Disguse)
    [31766] = true, -- Disguised (Colovian Uniform)
    [48429] = true, -- Gold Coast Courier Uniform (Courier Uniform)
    [33221] = true, -- Crown Disguise (Crown Dishdasha)
    [20175] = true, -- Dunmer Cultural Garb (Dunmer Cultural Garb)
    [33220] = true, -- Forebear Disguise (Forebear Dishdasha)
    [47574] = true, -- Fort Amol Guard Disguise (Fort Amol Guard Disguise)
    [38167] = true, -- Bleakrock Bandit Disguise (Frostedge Bandit Disguise)
    [39295] = true, -- Hallin's Stand Seventh Legion (Hallin's Stand Seventh Legion Disguise)
    [34267] = true, -- Imperial Disguise (Imperial Disguise)
    [31268] = true, -- Q4606 Disguise Watcher (Keeper's Gard)
    [31118] = true, -- Keeper's Garb (Keeper's Garb)
    [30879] = true, -- Shimmering Glow (Kollopi Essence)
    [35607] = true, -- Midnight Union Disguise (Midnight Union Disguise)
    [38878] = true, -- Northwind Disguise (Northwind Disguise)
    [43716] = true, -- Phaer Mercenary Disguise (Phaer Mercenary Disguise)
    [29986] = true, -- Disguise (Pirate Disguise)
    [43719] = true, -- Quendeluun Pact Disguise (Quendeluun Veiled Heritance Disguise)
    [28076] = true, -- Red Rook Disguise (Red Rook Disguise)
    [85204] = true, -- Scarlet Judge's Regalia (Scarlet Judge's Regalia)
    [33534] = true, -- Seaside Disguise (Sea Viper Armor)
    [27457] = true, -- Seadrake Disguise (Seadrake Disguise)
    [32045] = true, -- Servant Costume (Servant's Robes)
    [51906] = true, -- Q3854 Goblin Disguise (Shadowsilk Gem)
    [19013] = true, -- Steel Shrike Uniform (Steel Shrike Uniform)
    [19086] = true, -- Stormfist Disguise (Stormfist Disguise)
    [50177] = true, -- Vanguard Uniform (Vanguard Uniform)
    [43722] = true, -- First Auridon Marine Disguise (Vulkhel Guard Marine Disguise)

    -- [80204] = true, -- Monk's Disguise (Monk's Disguise)
    -- [82631] = true, -- Monk's Disguise Timer (Monk's Disguise)

    -------------------------------------
    -- WORLD EVENTS ---------------------
    -------------------------------------

    -- Dark Anchor
    [13603] = true, -- CON_Destealth
    [44045] = true, -- Summon Victim
    [44056] = true, -- Summon Victim Spawn
    [48272] = true, -- Pester Victim
    [44058] = true, -- Draw the Blood
    [43982] = true, -- Sacrifice

    [46804] = true, -- Unexpected Sacrifice
    [46870] = true, -- Unexpected Sacrifice
    [46871] = true, -- Unexpected Sacrifice
    [46872] = true, -- Unexpected Sacrifice

    [43974] = true, -- Daedric Arrival
    [43972] = true, -- Daedric Arrival
    [86717] = true, -- Drop Anchor

    [46690] = true, -- Power of the Daedra
    [46689] = true, -- Vitality of the Daedra
    [51632] = true, -- Vitality of the Daedra
    [51633] = true, -- Vitality of the Daedra

    [44526] = true, -- Daedric Souls Basic
    [44635] = true, -- Daedric Souls Average
    [44636] = true, -- Daedric Souls Scary

    [95805] = true, -- Static Charge
    [95806] = true, -- Static Charge
    [95821] = true, -- Static Charge
    [95820] = true, -- Static Charge
    [95810] = true, -- Static Charge
    [95841] = true, -- Static Charge
    [95813] = true, -- Static Charge
    [96267] = true, -- Static Charge

    [56385] = true, -- DA Music Delay
    [46293] = true, -- Stun
    [46291] = true, -- Rain of Doom
    [46292] = true, -- Become Visible
    [46294] = true, -- Become Visible

    -- Daedric World Drop
    [51509] = true, -- Stun
    [51506] = true, -- Targetable Off
    [51505] = true, -- Portal Spawn
    [51507] = true, -- Targetable On

    -- Dark Anchor Bosses
    -- [89249] = true, -- Summon Daedra (Ozozzachar)
    -- [89251] = true, -- Summon Daedra (Ozozzachar)

    -- Misc World + Theater
    [16553] = true, -- CON_Ritual_Daedric
    [25706] = true, -- CON_GoodAura
    [22207] = true, -- CTY-Beam,Capture
    [48911] = true, -- CTY-Flavor-Scamp
    [822] = true,   -- Ward
    [1406] = true,  -- Ward Snare
    [26391] = true, -- Quick Strike
    [48483] = true, -- W20-CMP-PutOutFire
    [48484] = true, -- City - Putting out Fire 1
    [49287] = true, -- RDS Hunter BowFire

    [49106] = true, -- V11860 Mage Duel
    [49147] = true, -- RDS Chest
    [48318] = true, -- CON_Bamf In
    [21811] = true, -- RDS M'aiq Tracker
    [43617] = true, -- CON_Destealth
    [43223] = true, -- Attack
    [48899] = true, -- Firelight
    [48920] = true, -- V11849 Firelight Tracker
    [48712] = true, -- V1422 Beggar Event Buff
    [48647] = true, -- V1472 Rob Event Buff
    [39972] = true, -- CON_Small Dust 3 Sec

    -------------------------------------
    -- DRAGONKNIGHT PASSIVES ------------
    -------------------------------------

    -- Ardent Flame
    [29424] = true,  -- Combustion (Rank 1)
    [108806] = true, -- Combustion
    [108809] = true, -- Combustion
    [45011] = true,  -- Combustion (Rank 2)
    [108816] = true, -- Combustion
    [108815] = true, -- Combustion
    [29430] = true,  -- Warmth (Rank 1)
    [45012] = true,  -- Warmth (Rank 2)
    [160949] = true, -- Warmth
    [29439] = true,  -- Searing Heat (Rank 1)
    [45023] = true,  -- Searing Heat (Rank 2)
    [29451] = true,  -- World in Ruin (Rank 1)
    [45029] = true,  -- World in Ruin (Rank 2)

    -- Draconic Power
    [29455] = true, -- Iron Skin (Rank 1)
    [44922] = true, -- Iron Skin (Rank 2)
    [29457] = true, -- Burning Heart (Rank 1)
    [44933] = true, -- Burning Heart (Rank 2)
    [29460] = true, -- Elder Dragon (Rank 1)
    [44951] = true, -- Elder Dragon (Rank 2)
    [29462] = true, -- Scaled Armor (Rank 1)
    [44953] = true, -- Scaled Armor (Rank 2)

    -- Earthen Heart
    [29468] = true, -- Eternal Mountain (Rank 1)
    [44996] = true, -- Eternal Mountain (Rank 2)
    [29463] = true, -- Battle Roar (Rank 1)
    [29465] = true, -- Battle Roar
    [29466] = true, -- Battle Roar
    [29467] = true, -- Battle Roar
    [44984] = true, -- Battle Roar (Rank 2)
    [44986] = true, -- Battle Roar
    [44987] = true, -- Battle Roar
    [44988] = true, -- Battle Roar
    [29473] = true, -- Mountain's Blessing (Rank 1)
    [61798] = true, -- Minor Brutality
    [29474] = true, -- Mountain's Blessing
    [45001] = true, -- Mountain's Blessing (Rank 2)
    [61799] = true, -- Minor Brutality
    [45005] = true, -- Mountain's Blessing
    [29475] = true, -- Helping Hands (Rank 1)
    [29476] = true, -- Helping Hands
    [45009] = true, -- Helping Hands (Rank 2)
    [45010] = true, -- Helping Hands

    -------------------------------------
    -- DRAGONKNIGHT ACTIVES -------------
    -------------------------------------

    [23806] = true,  -- Lava Whip (Lava Whip)
    [23808] = true,  -- Off Balance (Lava Whip)

    [32842] = true,  -- Seething Fury (Molten Whip)
    [20805] = true,  -- Molten Whip (Molten Whip)
    [122658] = true, -- Seething Fury (Molten Whip)
    [122729] = true, -- Seething Fury (Molten Whip)
    [20806] = true,  -- Off Balance (Molten Whip)

    [20816] = true,  -- Flame Lash (Flame Lash)
    [34117] = true,  -- Off Balance (Flame Lash)
    [20824] = true,  -- Power Lash (Flame Lash)
    [23105] = true,  -- Power Lash (Flame Lash)

    [20657] = true,  -- Searing Strike (Searing Strike)
    [44363] = true,  -- Searing Strike (Searing Strike)

    [20668] = true,  -- Venomous Claw (Venomous Claw)
    [44369] = true,  -- Venomous Claw (Venomous Claw)
    [31810] = true,  -- Venomous Claw (Venomous Claw)

    [20660] = true,  -- Burning Embers (Burning Embers)
    [44373] = true,  -- Burning Embers (Burning Embers)
    [31815] = true,  -- Burning Embers (Burning Embers)

    [20917] = true,  -- Fiery Breath (Fiery Breath)
    [31102] = true,  -- Fiery Breath (Fiery Breath)

    [20944] = true,  -- Noxious Breath (Noxious Breath)
    [31103] = true,  -- Noxious Breath (Noxious Breath)
    [48946] = true,  -- Major Breach (Noxious Breath)

    [20930] = true,  -- Engulfing Flames (Engulfing Flames)
    [31104] = true,  -- Engulfing Flames (Engulfing Flames)
    [32821] = true,  -- Engulfing Flames (Engulfing Flames)

    [31290] = true,  -- Fiery Reach taunt (Fiery Grip - All Morphs)
    [20492] = true,  -- Fiery Grip (Fiery Grip)
    [20493] = true,  -- Fiery Grip (Fiery Grip)
    [20494] = true,  -- Fiery Grip (Fiery Grip)
    [76498] = true,  -- Major Expedition (Fiery Grip)

    [20499] = true,  -- Empowering Chains (Empowering Chains)
    [62023] = true,  -- Fiery Grip (Empowering Chains)
    [147421] = true, -- Empower (Empowering Chains)
    [76506] = true,  -- Major Expedition (Empowering Chains)

    [20496] = true,  -- Unrelenting Grip (Unrelenting Grip)
    [62004] = true,  -- Unrelenting Grip (Unrelenting Grip)
    [62001] = true,  -- Unrelenting Grip (Unrelenting Grip)
    [76502] = true,  -- Major Expedition (Unrelenting Grip)
    [77105] = true,  -- Unrelenting Grip (Unrelenting Grip)

    [75088] = true,  -- Major Prophecy (Inferno)
    [28967] = true,  -- Inferno (Inferno)
    [28969] = true,  -- Inferno (Inferno)

    [76433] = true,  -- Major Prophecy (Cauterize)
    [32881] = true,  -- Cauterize (Cauterize)
    [76429] = true,  -- Cauterize (Cauterize)

    [76420] = true,  -- Major Prophecy (Flames of Oblivion)
    [76426] = true,  -- Major Savagery (Flames of Oblivion)
    [32853] = true,  -- Flames of Oblivion (Flames of Oblivion)
    [61945] = true,  -- Flames of Oblivion (Flames of Oblivion)

    [67717] = true,  -- Shackle Synergy Cooldown (Dragonknight Standard - Shackle Synergy)
    [98438] = true,  -- Shackle Damage (Dragonknight Standard - Shackle Synergy)
    [98447] = true,  -- Shackle Snare (Dragonknight Standard - Shackle Synergy)
    [98437] = true,  -- Shackle Area Effect (Dragonknight Standard - Shackle Synergy)
    [98448] = true,  -- Shackle Immune FX (Dragonknight Standard - Shackle Synergy)

    [28988] = true,  -- Dragonknight Standard (Dragonknight Standard)
    [28995] = true,  -- Dragonknight Standard (Dragonknight Standard)
    [29230] = true,  -- Major Defile (Dragonknight Standard)
    [32905] = true,  -- Shackle (Dragonknight Standard)

    [32967] = true,  -- Shifting Standard (Shifting Standard)
    [32958] = true,  -- Shifting Standard (Shifting Standard)
    [70735] = true,  -- Shifting Standard (Shifting Standard)
    [32960] = true,  -- Shifting Standard (Shifting Standard)
    [32961] = true,  -- Major Defile (Shifting Standard)
    [32962] = true,  -- Shifting Standard (Shifting Standard)
    [32963] = true,  -- Shift Standard (Shifting Standard)
    [100100] = true, -- Shift Standard (Shifting Standard)
    [32966] = true,  -- Shifting Standard (Shifting Standard)
    [32964] = true,  -- Shifting Standard (Shifting Standard)
    [32965] = true,  -- Major Deflie (Shifting Standard)

    [32956] = true,  -- Standard of Might (Standard of Might)
    [32957] = true,  -- Standard of Might (Standard of Might)
    [32947] = true,  -- Standard of Might (Standard of Might)
    [32948] = true,  -- Standard of Might (Standard of Might)
    [32949] = true,  -- Major Defile (Standard of Might)
    [32950] = true,  -- Standard of Might (Standard of Might)

    [20319] = true,  -- Spiked Armor (Spiked Armor)
    [61815] = true,  -- Major Resolve (Spiked Armor)
    [20320] = true,  -- Spiked Armor (Spiked Armor)

    [20328] = true,  -- Hardened Armor (Hardened Armor)
    [61827] = true,  -- Major Resolve (Hardened Armor)
    [31808] = true,  -- Hardened Armor (Hardened Armor)
    [20329] = true,  -- Hardened Armor Damage Return (Hardened Armor)

    [20323] = true,  -- Volatile Armor (Volatile Armor)
    [61836] = true,  -- Major Resolve (Volatile Armor)
    [20324] = true,  -- Volatle Armor (Volatile Armor)
    [20326] = true,  -- Volatile Armor (Volatile Armor)

    [32974] = true,  -- Ignite (Dark Talons - Synergy)
    [48040] = true,  -- Synergy Dummy (Dark Talons - Ignite Synergy)

    [20245] = true,  -- Dark Talons (Dark Talons)
    [20527] = true,  -- Dark Talons (Dark Talons)
    [102690] = true, -- Ignite Synergy Ticker (Dark Talons)
    [32976] = true,  -- Ignite Grant Ability (Dark Talons)
    [95174] = true,  -- Dark Talons FX (Dark Talons)

    [20252] = true,  -- Burning Talons (Impale Grant Ability)
    [31898] = true,  -- Burning Talons (Burning Talons)
    [20253] = true,  -- Burning Talons (Burning Talons)
    [102716] = true, -- Ignite Synergy Ticker (Burning Talons)
    [33244] = true,  -- Ignite Grant Ability (Burning Talons)
    [95178] = true,  -- Dark Talons FX (Burning Talons)

    [20251] = true,  -- Choking Talons (Choking Talons)
    [31899] = true,  -- Minor Maim (Choking Talons)
    [20528] = true,  -- Choking Talons (Choking Talons)
    [102720] = true, -- Ignite Synergy Ticker (Choking Talons)
    [33252] = true,  -- Ignite Grant Ability (Choking Talons)
    [95182] = true,  -- Dark Talons FX (Choking Talons)

    [29004] = true,  -- Dragon Blood (Dragon Blood)
    [29010] = true,  -- Dragon Blood (Dragon Blood)
    [29011] = true,  -- Major Fortitude (Dragon Blood)

    [32744] = true,  -- Green Dragon Blood (Dragon Blood)
    [32745] = true,  -- Green Dragon Blood (Dragon Blood)
    [32748] = true,  -- Major Endurance (Dragon Blood)
    [61884] = true,  -- Major Fortitude (Dragon Blood)
    [91670] = true,  -- Minor Vitality (Dragon Blood)

    [32722] = true,  -- Coagulating Blood (Coagulating Blood)
    [32723] = true,  -- Coagulating Blood (Coagulating Blood)
    [91674] = true,  -- Major Fortitude (Coagulating Blood)

    [21007] = true,  -- Reflective Scale (Reflective Scale)

    [21014] = true,  -- Protective Plate (Protective Plate)
    [108798] = true, -- Protective Plate (Protective Plate)

    [21017] = true,  -- Dragon Fire Scale (Dragon Fire Scale)
    [32753] = true,  -- Dragon Fire Scale (Dragon Fire Scale)

    [31837] = true,  -- Inhale (Inhale)
    [31859] = true,  -- Inhale Heal (Inhale)
    [31841] = true,  -- Inhale (Inhale)
    [31842] = true,  -- Inhale (Inhale)

    [32792] = true,  -- Deep Breath (Deep Breath)
    [32795] = true,  -- Deep Breath (Deep Breath)
    [32796] = true,  -- Deep Breath (Deep Breath)
    [32794] = true,  -- Deep Breath (Deep Breath)
    [32797] = true,  -- Deep Breath (Deep Breath)
    [32805] = true,  -- Deep Breath (Deep Breath)

    [32785] = true,  -- Draw Essence (Draw Essence)
    [32786] = true,  -- Draw Essence (Draw Essence)
    [32788] = true,  -- Draw Essence (Draw Essence)
    [32787] = true,  -- Draw Essence (Draw Essence)
    [32789] = true,  -- Draw Essence (Draw Essence)

    [48744] = true,  -- CC Immunity (Dragon Leap)
    [29012] = true,  -- Dragon Leap (Dragon Leap)
    [29014] = true,  -- Dragon Leap (Dragon Leap)
    [29016] = true,  -- Dragon Leap (Dragon Leap)
    [114590] = true, -- Stun (Dragon Leap)
    [118928] = true, -- Dragon Leap (Dragon Leap)

    [48753] = true,  -- CC Immunity (Take Flight)
    [32719] = true,  -- Take Flight (Take Flight)
    [32720] = true,  -- Take Flight (Take Flight)
    [32721] = true,  -- Take Flight (Take Flight)
    [114600] = true, -- Stun (Take Flight)
    [118936] = true, -- Take Flight (Take Flight)

    [48760] = true,  -- CC Immunity (Ferocious Leap)
    [32715] = true,  -- Ferocious Leap (Ferocious Leap)
    [32716] = true,  -- Ferocious Leap (Ferocious Leap)
    [32717] = true,  -- Ferocious Leap (Ferocious Leap)
    [61814] = true,  -- Ferocious Leap (Ferocious Leap)
    [114601] = true, -- Stun (Ferocious Leap)
    [118938] = true, -- Ferocious Leap (Ferocious Leap)

    [29032] = true,  -- Stonefist (Stonefist)
    [134310] = true, -- Stonefist (Stonefist)
    [133037] = true, -- Stonefist (Stonefist)
    [134009] = true, -- Stonefist (Stonefist)

    [31820] = true,  -- Obsidian Shard (Obsidian Shard)
    [68763] = true,  -- Obsidian Shard (Obsidian Shard)

    [31816] = true,  -- Stone Giant (Stone Giant)
    [134340] = true, -- Stone Giant (Stone Giant)
    [133027] = true, -- Stone Giant (Stone Giant)
    [134336] = true, -- Stone Giant (Stone Giant)
    [134355] = true, -- Stone Giant (Stone Giant)

    [29043] = true,  -- Molten Weapons (Molten Weapons)
    [131340] = true, -- Major Brutality (Molten Weapons)
    [92507] = true,  -- Major Sorcery (Molten Weapons)

    [31874] = true,  -- Igneous Weapons (Igneous Weapons)
    [76518] = true,  -- Major Brutality (Igneous Weapons)
    [92503] = true,  -- Major Sorcery (Igneous Weapons)

    [31888] = true,  -- Molten Armaments (Molten Armaments)
    [76537] = true,  -- Molten Armaments (Molten Armaments)
    [131341] = true, -- Major Brutality (Molten Armaments)
    [92512] = true,  -- Major Sorcery (Molten Armaments)

    [29071] = true,  -- Obsidian Shield (Obsidian Shield)
    [108675] = true, -- Major Mending (Obsidian Shield)

    [29224] = true,  -- Igneous Shield (Igneous Shield)
    [29225] = true,  -- Obsidian Shield (Igneous Shield)
    [55033] = true,  -- Major Mending (Igneous Shield)

    [32673] = true,  -- Fragmented Shield (Fragmented Shield)
    [108676] = true, -- Major Mending (Fragmented Shield)

    [29037] = true,  -- Petrify (Petrify)
    [54918] = true,  -- Petrify (Petrify)

    [32685] = true,  -- Fossilize (Fossilize)
    [54931] = true,  -- Fossilize (Fossilize)
    [61785] = true,  -- Fossilize (Fossilize)

    [32678] = true,  -- Shattering Rocks (Shattering Rocks)
    [32684] = true,  -- Shattering Rocks (Shattering Rocks)
    [108811] = true, -- Shattering Rocks (Shattering Rocks)

    [29059] = true,  -- Ash Cloud (Ash Cloud)
    [33142] = true,  -- Ash Cloud (Ash Cloud)
    [61772] = true,  -- Ash Cloud (Ash Cloud)
    [29126] = true,  -- Ash Cloud (Ash Cloud)

    [20779] = true,  -- Cinder Storm (Cinder Storm)
    [21435] = true,  -- Ash Storm Remover (Cinder Storm)
    [34791] = true,  -- Cinder Storm (Cinder Storm)
    [20780] = true,  -- Cinder Storm (Cinder Storm)

    [32710] = true,  -- Eruption (Eruption)
    [33099] = true,  -- Ash Storm Remover (Eruption)
    [32714] = true,  -- Eruption (Eruption)
    [32711] = true,  -- Eruption (Eruption)
    [32712] = true,  -- Eruption (Eruption)

    [15957] = true,  -- Magma Armor (Magma Armor)
    [15959] = true,  -- Magma Armor (Magma Armor)

    [17874] = true,  -- Magma Shell (Magma Shell)
    [17875] = true,  -- Magma Shell (Magma Shell)
    [76483] = true,  -- Magma Shell (Magma Shell)

    [17878] = true,  -- Corrosive Armor (Corrosive Armor)
    [17879] = true,  -- Corrosive Armor (Corrosive Armor)

    -------------------------------------
    -- NIGHTBLADE PASSIVES --------------
    -------------------------------------

    -- Assassination
    [36616] = true,  -- Master Assassin (Rank 1)
    [45038] = true,  -- Master Assassin (Rank 2)
    [36630] = true,  -- Executioner (Rank 1)
    [101435] = true, -- Executioner
    [36633] = true,  -- Executioner
    [45048] = true,  -- Executioner (Rank 2)
    [101436] = true, -- Executioner
    [45050] = true,  -- Executioner
    [36636] = true,  -- Pressure Points (Rank 1)
    [45053] = true,  -- Pressure Points (Rank 2)
    [36641] = true,  -- Hemorrhage (Rank 1)
    [61882] = true,  -- Minor Savagery
    [45060] = true,  -- Hemorrhage (Rank 2)
    [61898] = true,  -- Minor Savagery

    -- Shadow
    [36549] = true, -- Refreshing Shadows (Rank 1)
    [45103] = true, -- Refreshing Shadows (Rank 2)
    [18866] = true, -- Shadow Barrier (Rank 1)
    [66075] = true, -- Major Resolve
    [45071] = true, -- Shadow Barrier (Rank 2)
    [66083] = true, -- Major Resolve
    [36532] = true, -- Dark Vigor (Rank 1)
    [45084] = true, -- Dark Vigor (Rank 2)
    [36552] = true, -- Dark Veil (Rank 1)
    [45115] = true, -- Dark Veil (Rank 2)

    -- Siphoning
    [36560] = true, -- Catalyst (Rank 1)
    [63705] = true, -- Catalyst
    [45135] = true, -- Catalyst (Rank 2)
    [63707] = true, -- Catalyst
    [36595] = true, -- Magicka Flood (Rank 1)
    [45150] = true, -- Magicka Flood (Rank 2)
    [36603] = true, -- Soul Siphoner (Rank 1)
    [45155] = true, -- Soul Siphoner (Rank 2)
    [36587] = true, -- Transfer (Rank 1)
    [36589] = true, -- Transfer
    [45145] = true, -- Transfer (Rank 2)
    [45146] = true, -- Transfer

    -------------------------------------
    -- NIGHTBLADE ACTIVES ---------------
    -------------------------------------

    [43706] = true,  -- Sense Weakness (Assassin's Blade - All Morphs)
    [33386] = true,  -- Assassin's Blade (Assassin's Blade)

    [61788] = true,  -- Killer's Blade (Killer's Blade)
    [34843] = true,  -- Killer's Blade (Killer's Blade)
    [61787] = true,  -- Killer's Blade (Killer's Blade)

    [34851] = true,  -- Impale (Impale)

    [18342] = true,  -- Teleport Strike (Teleport Strike)
    [18346] = true,  -- Teleport Strike (Teleport Strike)
    [124803] = true, -- Minor Vulnerability (Teleport Strike)

    [25484] = true,  -- Ambush (Ambush)
    [25485] = true,  -- Ambush (Ambush)
    [147422] = true, -- Empower (Ambush)
    [124804] = true, -- Minor Vulnerability (Lotus Fan)

    [25493] = true,  -- Lotus Fan (Lotus Fan)
    [25494] = true,  -- Lotus Fan (Lotus Fan)
    [35336] = true,  -- Lotus Fan (Lotus Fan)
    [124806] = true, -- Minor Vulnerability (Lotus Fan)

    [33375] = true,  -- Blur (Blur)
    [90587] = true,  -- Major Evasion (Blur)

    [35414] = true,  -- Mirage (Mirage)
    [90593] = true,  -- Major Evasion (Mirage)
    [61817] = true,  -- Minor Resolve (Mirage)

    [35419] = true,  -- Phantasmal Escape (Phantasmal Escape)
    [90620] = true,  -- Major Evasion (Double Take)
    [125314] = true, -- Phantasmal Escape (Phantasmal Escape)

    [33357] = true,  -- Mark Target (Mark Target)
    [33363] = true,  -- Major Breach (Mark Target)
    [33408] = true,  -- Summon Shade (Mark Target)
    [33373] = true,  -- Mark Target (Mark Target)

    [36968] = true,  -- Piercing Mark (Piercing Mark)
    [36980] = true,  -- Major Breach (Piercing Mark)
    [36994] = true,  -- Piercing Mark (Piercing Mark)
    [36982] = true,  -- Piercing Mark (Piercing Mark)
    [36983] = true,  -- Piercing Mark (Piercing Mark)

    [36967] = true,  -- Reaper's Mark (Reaper's Mark)
    [36972] = true,  -- Major Breach (Reaper's Mark)
    [36974] = true,  -- Reaper's Mark (Reaper's Mark)
    [36975] = true,  -- Reaper's Mark (Reaper's Mark)
    [36973] = true,  -- Major Berserk (Reaper's Mark)

    [61907] = true,  -- Grim Focus (Grim Focus)
    [122585] = true, -- Grim Focus (Grim Focus)
    [61902] = true,  -- Grim Focus (Grim Focus)
    [61905] = true,  -- Grim Focus (Grim Focus)

    [61932] = true,  -- Relentless Focus (Relentless Focus)
    [122587] = true, -- Relentless Focus (Relentless Focus)
    [61927] = true,  -- Relentless Focus (Relentless Focus)
    -- [61928] = true, -- Relentless Focus (Relentless Focus)
    [107054] = true, -- Relentless Focus (Relentless Focus)

    [61930] = true,  -- Merciless Resolve (Merciless Resolve)
    [122586] = true, -- Merciless Resolve (Merciless Resolve)
    [61919] = true,  -- Merciless Resolve (Merciless Resolve)
    -- [61920] = true, -- Merciless Resolve (Merciless Resolve)
    [107055] = true, -- Merciless Resolve (Merciless Resolve)

    [33398] = true,  -- Death Stroke (Death Stroke)
    [61389] = true,  -- Damage Taken Increased (Death Stroke)

    [125921] = true, -- Reave (Incapacitating Strike)
    [125922] = true, -- Reave (Incapacitating Strike)
    [125923] = true, -- Reave (Incapacitating Strike)
    [36508] = true,  -- Incapacitating Strike (Incapacitating Strike)
    [61393] = true,  -- Damage Taken Increased (Incapacitating Strike)
    [113105] = true, -- Incapacitating Strike (Incapacitating Strike)
    [113107] = true, -- Damage Taken Increased (Incapacitating Strike)
    [126444] = true, -- Incapacitating Strike (Incapacitating Strike)

    [36518] = true,  -- Soul Harvest Passive (Soul Harvest)
    [36514] = true,  -- Soul Harvest (Soul Harvest)
    [36515] = true,  -- Major Defile (Soul Harvest)
    [61400] = true,  -- Damage Taken Increased (Soul Harvest)
    [36519] = true,  -- Rapid Stroke Passive (Soul Harvest)

    [25255] = true,  -- Veiled Strike (Veiled Strike)
    [25256] = true,  -- Off Balance (Veiled Strike)

    [25260] = true,  -- Surprise Attack (Surprise Attack)
    [34733] = true,  -- Off Balance (Surprise Attack)

    [34738] = true,  -- Concealed Weapon Passive (Concealed Weapon)
    [34739] = true,  -- Concealed Weapon (Concealed Weapon)
    [25267] = true,  -- Concealed Weapon (Concealed Weapon)
    [34737] = true,  -- Off Balance (Concealed Weapon)
    [34736] = true,  -- Concealed Weapon (Concealed Weapon)

    [25375] = true,  -- Shadow Cloak (Shadow Cloak)
    [25376] = true,  -- Shadow Cloak (Shadow Cloak)
    [77756] = true,  -- Clairvoyance Fx (Shadow Cloak)

    [25380] = true,  -- Shadowy Disguise (Shadowy Disguise)
    [25381] = true,  -- Shadowy Disguise (Shadowy Disguise)
    [62141] = true,  -- Shadowy Disguise (Shadowy Disguise)
    [77757] = true,  -- Clairvoyance Fx (Shadowy Disguise)

    [25377] = true,  -- Dark Cloak (Dark Cloak)
    [108913] = true, -- Minor Protection (Dark Cloak)

    [33195] = true,  -- Path of Darkness (Path of Darkness)
    [37380] = true,  -- Summon Shade (Path of Darkness)
    [63982] = true,  -- Path of Darkness (Path of Darkness)
    [33198] = true,  -- Path of Darkness (Path of Darkness)
    [33197] = true,  -- Path of Darkness (Path of Darkness)

    [36049] = true,  -- Twisting Path (Twisting Path)
    [37381] = true,  -- Summon Shade (Twisting Path)
    [36050] = true,  -- Major Expedition (Twisting Path)
    [36052] = true,  -- Twisting Path (Twisting Path)

    [36028] = true,  -- Refreshing Path (Refreshing Path)
    [64003] = true,  -- Refreshing Path (Refreshing Path)
    [64007] = true,  -- Path of Darkness (Refreshing Path)
    [64004] = true,  -- Path of Darkness (Refreshing Path)
    [64002] = true,  -- Refreshing Path (Refreshing Path)
    [64005] = true,  -- Major Expedition (Refreshing Path)
    [64006] = true,  -- Refreshing Path (Refreshing Path)

    [25352] = true,  -- Aspect of Terror (Aspect of Terror)
    [125025] = true, -- Aspect of Terror (Aspect of Terror)

    [37470] = true,  -- Mass Hysteria (Mass Hysteria)
    [125024] = true, -- Mass Hysteria (Mass Hysteria)

    [37475] = true,  -- Manifestation of Terror (Manifestation of Terror)
    [76628] = true,  -- Manifestation of Terror (Manifestation of Terror)
    [76630] = true,  -- Deadric Mines (Manifestation of Terror)
    [76635] = true,  -- Remove Trap (Manifestation of Terror)
    [76634] = true,  -- Manifestation of Terror (Manifestation of Terror)
    [76637] = true,  -- Manifestation of Terror (Manifestation of Terror)
    [76639] = true,  -- Manifestation of Terror (Manifestation of Terror)
    [38208] = true,  -- Birth Manifestation of Terror (Manifestation of Terror)
    [76632] = true,  -- Manifestation of Terror (Manifestation of Terror)

    [65269] = true,  -- Shade Initialize (Summon Shade - All Morphs)
    -- [85086] = true, -- Boss (Summon Shade - All Morphs)
    -- [85087] = true, -- Boss (Summon Shade - All Morphs)

    [33211] = true,  -- Summon Shade (Summon Shade)
    [38517] = true,  -- Summon Shade (Summon Shade)
    [88662] = true,  -- Summon Shade (Summon Shade) -- Khajiit
    [88663] = true,  -- Summon Shade (Summon Shade) -- Argonian
    [33290] = true,  -- Summon Shade (Summon Shade)
    [33219] = true,  -- Corrosive Strike (Shade) (Summon Shade)
    [33228] = true,  -- Minor Maim (Summon Shade)

    [35434] = true,  -- Dark Shade (Dark Shade)
    [35438] = true,  -- Summon Shade (Dark Shade)
    [88677] = true,  -- Summon Shade (Dark Shade) -- Khajiit
    [88678] = true,  -- Summon Shade (Dark Shade) -- Argonian
    [108940] = true, -- Summon Shade (Dark Shade)
    [123945] = true, -- Corrosive Flurry (Dark Shade)
    [123946] = true, -- Minor Maim (Dark Shade)
    [108936] = true, -- Corrosive Slash (Dark Shade)
    [108939] = true, -- Minor Maim (Dark Shade)

    [35441] = true,  -- Shadow Image (Shadow Image)
    [38528] = true,  -- Shadow (Shadow Image)
    [88696] = true,  -- Shadow (Shadow Image) -- Khajiit
    [88697] = true,  -- Shadow (Shadow Image) -- Argonian
    [35442] = true,  -- Summon Shade (Shadow Image)
    [35451] = true,  -- Shadow (Shadow Image)
    [51556] = true,  -- Corrosive Arrow (Shadow Image)
    [51558] = true,  -- Shade Corrode (Shadow Image)
    [35445] = true,  -- Shadow Image Teleport (Shadow Image)

    [37729] = true,  -- Hidden Refresh (Consuming Darkness - Hidden Refresh Synergy)
    [37730] = true,  -- Hidden Refresh (Consuming Darkness - Hidden Refresh Synergy)
    [37733] = true,  -- Hidden Refresh Cooldown (Consuming Darkness - Hidden Refresh Synergy)
    [37732] = true,  -- Hidden Refresh (Consuming Darkness - Hidden Refresh Synergy)
    [77769] = true,  -- Clairvoyance Fx (Consuming Darkness - Hidden Refresh Synergy)

    [25411] = true,  -- Consuming Darkness (Consuming Darkness)
    [44871] = true,  -- Major Protection (Consuming Darkness)
    [25412] = true,  -- Consuming Darkness (Consuming Darkness)
    [25444] = true,  -- Consuming Darkness (Consuming Darkness)

    [36493] = true,  -- Bolstering Darkness (Bolstering Darkness)
    [44862] = true,  -- Major Protection (Bolstering Darkness)
    [36495] = true,  -- Bolstering Darkness (Bolstering Darkness)
    [36496] = true,  -- Bolstering Darkness (Bolstering Darkness)

    [36485] = true,  -- Veil of Blades (Veil of Blades)
    [44854] = true,  -- Major Protection (Veil of Blades)
    [36490] = true,  -- Veil of Blades (Veil of Blades)
    [36487] = true,  -- Veil of Blades (Veil of Blades)
    [36488] = true,  -- Veil of Blades (Veil of Blades)

    [60400] = true,  -- Caused Damage with Strife (Strife -- All Morphs)
    [60401] = true,  -- Strife Saved Damage (Strife -- All Morphs)
    [33291] = true,  -- Strife (Strife)
    [33292] = true,  -- Strife (Strife)
    [115037] = true, -- Funnel Health (Strife)

    [34838] = true,  -- Funnel Health (Funnel Health)
    [35469] = true,  -- Funnel Health (Funnel Health)
    [34841] = true,  -- Funnel Health (Funnel Health)

    [34835] = true,  -- Swallow Soul (Swallow Soul)
    [34836] = true,  -- Swallow Soul (Swallow Soul)

    [33308] = true,  -- Malevolent Offering (Malevolent Offering)
    [108925] = true, -- Malevolent Offering (Malevolent Offering)

    [34721] = true,  -- Shrewd Offering (Shrewd Offering)
    [108927] = true, -- Shrewd Offering (Shrewd Offering)

    [34727] = true,  -- Healthy Offering (Healthy Offering)
    [108932] = true, -- Healthy Offering (Healthy Offering)
    [108934] = true, -- Minor Mending (Healthy Offering)

    [33326] = true,  -- Cripple (Cripple)
    [33333] = true,  -- Cripple (Cripple)
    [33327] = true,  -- Cripple (Cripple)

    [36943] = true,  -- Debilitate (Debilitate)
    [36947] = true,  -- Debilitate (Debilitate)
    [36945] = true,  -- Debilitate (Debilitate)

    [36957] = true,  -- Crippling Grasp (Crippling Grasp)
    [36960] = true,  -- Crippling Grasp (Crippling Grasp)
    [36958] = true,  -- Crippling Grasp (Crippling Grasp)
    [36963] = true,  -- Crippling Grasp (Crippling Grasp)
    [36964] = true,  -- Crippling Grasp (Crippling Grasp)

    [33319] = true,  -- Siphoning Strikes (Siphoning Strikes)
    [33321] = true,  -- Siphoning Strikes (Siphoning Strikes)
    [114957] = true, -- Siphoning Strikes (Siphoning Strikes)

    [36908] = true,  -- Leeching Strikes (Leeching Strikes)
    [96689] = true,  -- Leeching Strikes (Leeching Strikes)
    [96696] = true,  -- Leeching Strikes (Leeching Strikes)
    [95895] = true,  -- Leeching Strikes (Leeching Strikes)
    [36911] = true,  -- Leeching Strikes (Leeching Strikes)
    [36912] = true,  -- Leeching Strikes (Leeching Strikes)
    [114964] = true, -- Leeching Strikes (Leeching Strikes)
    [114963] = true, -- Leeching Strikes (Leeching Strikes)

    [36935] = true,  -- Siphoning Attacks (Siphoning Attacks)
    [96713] = true,  -- Siphoning Strikes (Siphoning Attacks)
    [96714] = true,  -- Siphoning Strikes (Siphoning Attacks)
    [95908] = true,  -- Siphoning Attacks (Siphoning Attacks)
    [36937] = true,  -- Siphoning Attacks (Siphoning Attacks)
    [36938] = true,  -- Siphoning Attacks (Siphoning Attacks)
    [114969] = true, -- Siphoning Attacks (Siphoning Attacks)
    [114968] = true, -- Siphoning Attacks (Siphoning Attacks)

    [33316] = true,  -- Drain Power (Drain Power)
    [131342] = true, -- Major Brutality (Drain Power)
    [33317] = true,  -- Major Sorcery (Drain Power)

    [36901] = true,  -- Power Extraction (Power Extraction)
    [36903] = true,  -- Major Brutality (Power Extraction)
    [131344] = true, -- Major Sorcery (Power Extraction)
    [126675] = true, -- Minor Cowardice (Power Extraction)

    [36891] = true,  -- Sap Essence (Sap Essence)
    [45655] = true,  -- Sap Essence (Sap Essence)
    [131343] = true, -- Major Brutality (Sap Essence)
    [62240] = true,  -- Major Sorcery (Sap Essence)
    [36898] = true,  -- Sap Will (Sap Essence)
    [36899] = true,  -- Sap Will (Sap Essence)

    [25170] = true,  -- Soul Leech (Synergy - Soul Leech)
    [25172] = true,  -- Soul Leech (Synergy - Soul Leech)
    [25171] = true,  -- Soul Leech (Synergy - Soul Leech)

    [25091] = true,  -- Soul Shred (Soul Shred)
    [25093] = true,  -- Soul Shred (Soul Shred)
    [25168] = true,  -- Soul Shred (Soul Shred)
    [25169] = true,  -- Soul Leech (Soul Shred)

    [35508] = true,  -- Soul Siphon (Soul Siphon)
    [35615] = true,  -- Soul Siphon (Soul Siphon)
    [63533] = true,  -- Major Vitality (Soul Siphon)
    [106133] = true, -- Soul Siphon (Soul Siphon)
    [35614] = true,  -- Soul Tether (Soul Siphon)
    [35613] = true,  -- Soul Leech (Soul Siphon)

    [35460] = true,  -- Soul Tether (Soul Tether)
    [35466] = true,  -- Soul Tether (Soul Tether)
    [129384] = true, -- Soul Tether (Soul Tether)
    [36606] = true,  -- Soul Tether (Soul Tether)
    [35462] = true,  -- Soul Tether (Soul Tether)
    [35463] = true,  -- Soul Tether (Soul Tether)
    [35461] = true,  -- Soul Leech (Soul Tether)

    -------------------------------------
    -- SORCERER PASSIVES ----------------
    -------------------------------------

    -- Dark Magic
    [31386] = true,  -- Unholy Knowledge (Rank 1)
    [45176] = true,  -- Unholy Knowledge (Rank 2)
    [31383] = true,  -- Blood Magic (Rank 1)
    [31384] = true,  -- Blood Magic
    [45172] = true,  -- Blood Magic (Rank 2)
    [45173] = true,  -- Blood Magic
    [31378] = true,  -- Persistance (Rank 1)
    [108858] = true, -- Persistance Cost Reduction
    [45165] = true,  -- Persistance (Rank 2)
    [108862] = true, -- Persistance Cost Reduction
    [31389] = true,  -- Exploitation (Rank 1)
    [62319] = true,  -- Minor Prophecy
    [45181] = true,  -- Exploitation (Rank 2)
    [62320] = true,  -- Minor Prophecy

    -- Daedric Summoning
    [31398] = true,  -- Rebate (Rank 1)
    [45198] = true,  -- Rebate (Rank 2)
    [64849] = true,  -- Rebate
    [143500] = true, -- Rebate
    [31396] = true,  -- Power Stone (Rank 1)
    [45196] = true,  -- Power Stone (Rank 2)
    [31417] = true,  -- Daedric Protection (Rank 1)
    [45200] = true,  -- Daedric Protection (Rank 2)
    [31412] = true,  -- Expert Summoner (Rank 1)
    [31415] = true,  -- Expert Summoner
    [45199] = true,  -- Expert Summoner (Rank 2)
    [46198] = true,  -- Expert Summoner

    -- Storm Calling
    [31419] = true, -- Capacitor (Rank 1)
    [45188] = true, -- Capacitor (Rank 2)
    [31421] = true, -- Energized (Rank 1)
    [45190] = true, -- Energized (Rank 2)
    [31422] = true, -- Amplitude (Rank 1)
    [45192] = true, -- Amplitude (Rank 2)
    [31425] = true, -- Expert Mage (Rank 1)
    [45195] = true, -- Expert Mage (Rank 2)

    -------------------------------------
    -- SORCERER ACTIVES -----------------
    -------------------------------------

    [43714] = true,  -- Crystal Shard (Crystal Shard)
    [143744] = true, -- Crystal Weaver (Crystal Shard)

    [46331] = true,  -- Crystal Weapon (Crystal Weapon)
    [143804] = true, -- Crystal Weapon (Crystal Weapon)
    [143808] = true, -- Crystal Weapon (Crystal Weapon)

    [46326] = true,  -- Crystal Fragments Passive (Crystal Fragments)
    [46324] = true,  -- Crystal Fragments (Crystal Fragments)
    [46327] = true,  -- Crystal Fragments Proc (Crystal Fragments)
    [114716] = true, -- Crystal Fragments (Crystal Fragments)

    [28025] = true,  -- Encase (Encase)
    [43759] = true,  -- Encase (Encase)
    [43761] = true,  -- Encase (Encase)
    [43760] = true,  -- Encase (Encase)
    [143659] = true, -- Encase (Encase)

    [28308] = true,  -- Shattering Prison (Shattering Prison)
    [43781] = true,  -- Encase (Shattering Prison)
    [43782] = true,  -- Encase (Shattering Prison)
    [43780] = true,  -- Encase (Shattering Prison)
    [28309] = true,  -- Shattering Prison (Shattering Prison)
    [143663] = true, -- Shattering Prison (Shattering Prison)

    [28311] = true,  -- Restraining Prison (Restraining Prison)
    [43793] = true,  -- Encase (Restraining Prison)
    [43794] = true,  -- Encase (Restraining Prison)
    [43792] = true,  -- Encase (Restraining Prison)
    [108833] = true, -- Restraining Stack Count (Restraining Prison)
    [108832] = true, -- Major Vitality (Restraining Prison)
    [143668] = true, -- Restraining Prison (Restraining Prison)

    [24371] = true,  -- Rune Prison (Rune Prison)
    [24559] = true,  -- Rune Prison (Rune Prison)

    [24578] = true,  -- Rune Cage (Rune Cage)
    [24581] = true,  -- Rune Cage (Rune Cage)
    [100118] = true, -- Rune Cage (Rune Cage)

    [24574] = true,  -- Defensive Rune (Defensive Rune)
    [114602] = true, -- Defensive Rune Constrict (Defensive Rune)
    [24576] = true,  -- Defensive Rune (Defensive Rune)

    [24584] = true,  -- Dark Exchange (Dark Exchange)
    [24585] = true,  -- Dark Exchange (Dark Exchange)
    [114903] = true, -- Dark Exchange (Dark Exchange)

    [24595] = true,  -- Dark Deal (Dark Deal)
    [24596] = true,  -- Dark Deal (Dark Deal)
    [114908] = true, -- Dark Deal (Dark Deal)

    [24589] = true,  -- Dark Conversion (Dark Conversion)
    [24591] = true,  -- Dark Conversion (Dark Conversion)
    [114909] = true, -- Dark Conversion (Dark Conversion)

    [24828] = true,  -- Daedric Mines (Daedric Mines)
    [24830] = true,  -- Daedric Mines (Daedric Mines)
    [24832] = true,  -- Daedric Mines (Daedric Mines)
    [24833] = true,  -- Daedric Mines (Daedric Mines)
    [25144] = true,  -- Daedric Mines (Daedric Mines)
    [24829] = true,  -- Daedric Mines (Daedric Mines)
    [27935] = true,  -- Daedric Mines (Daedric Mines)

    [24842] = true,  -- Daedric Tomb (Daedric Tomb)
    [77437] = true,  -- Summon Shade (Daedric Tomb)
    [24847] = true,  -- Daedric Mines (Daedric Tomb)
    [24846] = true,  -- Daedric Mines (Daedric Tomb)
    [24844] = true,  -- Daedric Mines (Daedric Tomb)
    [28466] = true,  -- Daedric Mines (Daedric Tomb)
    [24843] = true,  -- Daedric Tomb (Daedric Tomb)
    [28452] = true,  -- Daedric Tomb (Daedric Tomb)

    [24834] = true,  -- Daedric Minefield (Daedric Minefield)
    [25158] = true,  -- Daedric Mines (Daedric Minefield)
    [25157] = true,  -- Daedric Mines (Daedric Minefield)
    [25159] = true,  -- Daedric Mines (Daedric Minefield)
    [25160] = true,  -- Daedric Mines (Daedric Minefield)
    [25162] = true,  -- Daedric Mines (Daedric Minefield)
    [25155] = true,  -- Daedric Mines (Daedric Minefield)
    [25161] = true,  -- Daedric Minefield (Daedric Minefield)
    [28454] = true,  -- Daedric Minefield (Daedric Minefield)

    [27706] = true,  -- Negate Magic (Negate Magic)
    [29824] = true,  -- Negate Magic (Negate Magic)
    [47147] = true,  -- Negate Magic (Negate Magic)

    [28341] = true,  -- Suppression Field (Suppression Field)
    [28343] = true,  -- Suppression Field (Suppression Field)
    [47160] = true,  -- Suppression Field (Suppression Field)
    [47159] = true,  -- Suppression Field (Suppression Field)
    [80435] = true,  -- Suppression Field (Suppression Field)

    [28348] = true,  -- Absorption Field (Absorption Field)
    [47168] = true,  -- Absorption Field (Absorption Field)
    [47167] = true,  -- Absorption Field (Absorption Field)
    [80405] = true,  -- Absorption Field (Absorption Field)

    [27287] = true,  -- Birth Unstable Familiar (Summon Unstable Familiar - All Ranks)
    [29536] = true,  -- Familiar Set Target (Summon Unstable Familiar - All Ranks)
    [27850] = true,  -- Familiar Melee (Summon Unstable Familiar + Summon Volatile Familiar)

    [23304] = true,  -- Summon Unstable Familiar (Summon Unstable Familiar)
    [23617] = true,  -- Unstable Familiar (Summon Unstable Familiar)
    [108840] = true, -- Summon Unstable Familiar (Summon Unstable Familiar)
    [108842] = true, -- Volatile Familiar Damage Pulsi (Summon Unstable Familiar)
    [108843] = true, -- Volatile Familiar (Summon Unstable Familiar)
    [108841] = true, -- Volatile Familiar FX (Summon Unstable Familiar)
    [108844] = true, -- Familiar Damage Pulse (Summon Unstable Familiar)

    [23319] = true,  -- Summon Unstable Clannfear (Summon Unstable Clannfear)
    [23644] = true,  -- Unstable Clannfear (Summon Unstable Clannfear)
    [29528] = true,  -- Claw (Summon Unstable Clannfear)
    [29529] = true,  -- Tail Spike (Summon Unstable Clannfear)
    [76076] = true,  -- Summon Unstable Clannfear (Summon Unstable Clannfear)
    [76078] = true,  -- Clannfear Heal (Summon Unstable Clannfear)
    [77175] = true,  -- Clannfear Heal (Summon Unstable Clannfear)

    [23316] = true,  -- Summon Volatile Familiar (Summon Volatile Familiar)
    [23641] = true,  -- Volatile Familiar (Summon Volatile Familiar)
    [77182] = true,  -- Summon Volatile Familiar (Summon Volatile Familiar)
    [77187] = true,  -- Volatile Familiar Damage Pulsi (Summon Volatile Familiar)
    [88933] = true,  -- Volatile Familiar (Summon Volatile Familiar)
    [77246] = true,  -- Volatile Familiar FX (Summon Volatile Familiar)
    [77186] = true,  -- Familiar Damage Pulse (Summon Volatile Familiar)
    [77243] = true,  -- Volatile Familiar Stun (Summon Volatile Familiar)
    [117255] = true, -- Volatile Familiar Melee (Summon Volatile Familiar)

    [24326] = true,  -- Daedric Curse (Daedric Curse)
    [28169] = true,  -- Daedric Curse (Daedric Curse)
    [24327] = true,  -- Daedric Curse (Daedric Curse)
    [44507] = true,  -- Daedric Curse (Daedric Curse)

    [24328] = true,  -- Daedric Prey (Daedric Prey)
    [28175] = true,  -- Daedric Prey (Daedric Prey)
    [24329] = true,  -- Daedric Prey (Daedric Prey)
    [44511] = true,  -- Daedric Prey (Daedric Prey)

    [24330] = true,  -- Haunting Curse (Haunting Curse)
    [28176] = true,  -- Haunting Curse (Haunting Curse)
    [24331] = true,  -- Haunting Curse (Haunting Curse)
    [44515] = true,  -- Haunting Curse (Haunting Curse)
    [89491] = true,  -- Haunting Curse (Haunting Curse)
    [89492] = true,  -- Haunting Curse (Haunting Curse)

    [25599] = true,  -- Lightning Prey (Summon Winged Twilight + Summon Twilight Matriarch)
    [25686] = true,  -- Summon Storm Atronach Death Ov (Summon Winged Twilight + Summon Twilight Matriarch)
    [24617] = true,  -- Zap (Summon Winged Twilight - All Morphs)
    [28027] = true,  -- Kick (Summon Winged Twilight - All Morphs)

    [24613] = true,  -- Summon Winged Twilight (Summon Winged Twilight)
    [24739] = true,  -- Summon Winged Twilight (Summon Winged Twilight)
    [108845] = true, -- Winged Twilight Restore (Summon Winged Twilight)
    [108847] = true, -- Summon Twilight Matriarch (Summon Winged Twilight)
    [108846] = true, -- Summon Twilight Matriarch (Summon Winged Twilight)

    [24639] = true,  -- Summon Twilight Matriarch (Summon Twilight Matriarch)
    [24742] = true,  -- Twilight Matriarch (Summon Twilight Matriarch)
    [77369] = true,  -- Twilight Matriarch Restore (Summon Twilight Matriarch)
    [77407] = true,  -- Twilight Matriarch Restore (Summon Twilight Matriarch)
    [77371] = true,  -- Twilight Matriarch Restore (Summon Twilight Matriarch)
    [117320] = true, -- Twilight Matriarch Kick (Summon Twilight Matriarch)
    [117321] = true, -- Twilight Matriarch Zap (Summon Twilight Matriarch)

    [24636] = true,  -- Summon Twilight Tormentor (Summon Twilight Tormentor)
    [24741] = true,  -- Twilight Tormentor (Summon Twilight Tormentor)
    [36735] = true,  -- Resto Twilight (Summon Twilight Tormentor)
    [77140] = true,  -- Summon Twilight Tormentor (Summon Twilight Tormentor)
    [77354] = true,  -- Twilight Tormentor Enrage (Summon Twilight Tormentor)
    [88937] = true,  -- Twilight Tormentor Enrage (Summon Twilight Tormentor)
    [117273] = true, -- Twilight Tormentor Kick (Summon Twilight Tormentor)
    [117274] = true, -- Twilight Tormentor Zap (Summon Twilight Tormentor)

    [28418] = true,  -- Conjured Ward (Conjured Ward)
    [28421] = true,  -- Conjured Ward (Conjured Ward)
    [28832] = true,  -- Conjured Ward (Conjured Ward)

    [29489] = true,  -- Hardened Ward (Hardened Ward)
    [29490] = true,  -- Hardened Ward (Hardened Ward)
    [29491] = true,  -- Hardened Ward (Hardened Ward)

    [29482] = true,  -- Empowered Ward (Empowered Ward)
    [29483] = true,  -- Empowered Ward (Empowered Ward)
    [29484] = true,  -- Empowered Ward (Empowered Ward)
    [77418] = true,  -- Minor Intellect (Empowered Ward)

    [108849] = true, -- Bound Armor Passive (Bound Armor)
    [24158] = true,  -- Bound Armor (Bound Armor)

    [24165] = true,  -- Bound Armaments (Bound Armaments)
    -- [108853] = true, -- Bound Armaments (Bound Armaments)
    [203447] = true, -- Bound Armaments (Bound Armaments)
    [130293] = true, -- Bound Armaments (Bound Armaments)
    -- [130291] = true, -- Bound Armaments (Bound Armaments)
    -- [130318] = true, -- Bound Armaments (Bound Armaments)

    [108855] = true, -- Bound Aegis Passive (Bound Aegis)
    [24163] = true,  -- Bound Aegis (Bound Aegis)

    [62195] = true,  -- Major Berserk (Summon Storm Atronach - Charged Lightning Synergy)
    [48076] = true,  -- Charged Lightning (Summon Storm Atronach - Charged Lightning Synergy)
    [48085] = true,  -- Charged Lightning Cooldown (Summon Storm Atronach - Charged Lightning Synergy)

    [25312] = true,  -- Storm Atronach (Summon Storm Atronach - All Morphs)
    [77454] = true,  -- Break Free (Atronach) (Summon Storm Atronach - All Morphs)
    [70122] = true,  -- Change Target (Summon Storm Atronach - All Morphs)
    [77456] = true,  -- Guard CC Break Timer (Summon Storm Atronach - All Morphs)
    [77457] = true,  -- Guard CC Break Anim (Summon Storm Atronach - All Morphs)
    [77455] = true,  -- Guard CC Immunity (Summon Storm Atronach - All Morphs)
    [23428] = true,  -- Atronach Zap (Summon Storm Atronach - All Morphs)

    [23634] = true,  -- Summon Storm Atronach (Summon Storm Atronach)
    [23639] = true,  -- Summon Storm Atronach (Summon Storm Atronach)
    [23636] = true,  -- Summon Storm Atronach (Summon Storm Atronach)
    [80459] = true,  -- Summon Storm Atronach (Summon Storm Atronach)
    [102309] = true, -- Atronach Synergy Anchor (Summon Storm Atronach)
    [102310] = true, -- Charged Lightning (Summon Storm Atronach)
    [23659] = true,  -- Storm Atronach Impact (Summon Storm Atronach)
    [23658] = true,  -- Summon Storm Atronach (Summon Storm Atronach)

    [23492] = true,  -- Greater Storm Atronach (Greater Storm Atronach)
    [23663] = true,  -- Greater Storm Atronach (Greater Storm Atronach)
    [23665] = true,  -- Greater Storm Atronach (Greater Storm Atronach)
    [80463] = true,  -- Greater Storm Atronach (Greater Storm Atronach)
    [102322] = true, -- Atronach Synergy Anchor (Greater Storm Atronach)
    [102321] = true, -- Charged Lightning (Greater Storm Atronach)
    [23664] = true,  -- Greater Storm Atronach Impact (Greater Storm Atronach)
    [23662] = true,  -- Greater Storm Atronach (Greater Storm Atronach)

    [23495] = true,  -- Summon Charged Atronach (Summon Charged Atronach)
    [23669] = true,  -- Summon Charged Atronach (Summon Charged Atronach)
    [23668] = true,  -- Summon Charged Atronach (Summon Charged Atronach)
    [80468] = true,  -- Summon Charged Atronach (Summon Charged Atronach)
    [102330] = true, -- Atronach Synergy Anchor (Summon Charged Atronach)
    [102329] = true, -- Charged Lightning (Summon Charged Atronach)
    [23667] = true,  -- Charged Atronach Impact (Summon Charged Atronach)
    [23666] = true,  -- Summon Charged Atronach (Summon Charged Atronach)

    [29806] = true,  -- Lightning Strike (Summon Charged Atronach)
    [43764] = true,  -- Lightning Strike (Summon Charged Atronach)
    [43767] = true,  -- Lightning Strike (Summon Charged Atronach)
    [43765] = true,  -- Lightning Strike (Summon Charged Atronach)
    [43766] = true,  -- Lightning Strike (Summon Charged Atronach)
    [29807] = true,  -- AoE (Summon Charged Atronach)
    [29809] = true,  -- Lightning Strike (Summon Charged Atronach)
    [29808] = true,  -- AoE (Summon Charged Atronach)
    [29811] = true,  -- AoE (Summon Charged Atronach)
    [29812] = true,  -- AoE (Summon Charged Atronach)
    [29810] = true,  -- AoE (Summon Charged Atronach)

    [18718] = true,  -- Mages' Fury (Mages' Fury)
    [18746] = true,  -- Mages' Fury (Mages' Fury)
    [18719] = true,  -- Mages' Fury (Mages' Fury)
    [44483] = true,  -- Mages' Fury (Mages' Fury)

    [19123] = true,  -- Mages' Wrath (Mages' Wrath)
    [19125] = true,  -- Mages' Wrath (Mages' Wrath)
    [19128] = true,  -- Mages' Wrath (Mages' Wrath)
    [44487] = true,  -- Mages' Wrath (Mages' Wrath)

    [19109] = true,  -- Endless Fury (Endless Fury)
    [19118] = true,  -- Endless Fury (Endless Fury)
    [114764] = true, -- Endless Fury (Endless Fury)
    [114763] = true, -- Endless Fury (Endless Fury)
    [19120] = true,  -- Endless Fury (Endless Fury)
    [44491] = true,  -- Endless Fury (Endless Fury)

    [23210] = true,  -- Lightning Form (Lightning Form)
    [62159] = true,  -- Major Resolve (Lightning Form)
    [23211] = true,  -- Lightning Form (Lightning Form)

    [23231] = true,  -- Hurricane (Hurricane)
    [62168] = true,  -- Major Resolve (Hurricane)
    [82797] = true,  -- Minor Expedition (Hurricane)
    [80485] = true,  -- Hurricane Bonus Damage Stacks (Hurricane)
    [80484] = true,  -- Hurricane Bonus Radius Stacks (Hurricane)
    [23232] = true,  -- Hurricane (Hurricane)

    [23213] = true,  -- Boundless Storm (Boundless Storm)
    [23216] = true,  -- Major Expedition (Boundless Storm)
    [62175] = true,  -- Major Resolve (Boundless Storm)
    [23214] = true,  -- Boundless Storm (Boundless Storm)

    [23196] = true,  -- Conduit (Lightning Splash - Conduit Synergy)
    [43769] = true,  -- Conduit Synergy Cooldown (Lightning Splash - Conduit Synergy)
    [65711] = true,  -- Only 1 Lightning Splash (Lightning Splash - All Morphs)

    [23182] = true,  -- Lightning Splash (Lightning Splash)
    [23194] = true,  -- Lightning Splash (Lightning Splash)
    [23189] = true,  -- Lightning Splash (Lightning Splash)

    [23200] = true,  -- Liquid Lightning (Liquid Lightning)
    [23203] = true,  -- Lightning Splash (Liquid Lightning)
    [23202] = true,  -- Liquid Lightning (Liquid Lightning)

    [23205] = true,  -- Lightning Flood (Lightning Flood)
    [23206] = true,  -- Lightning Splash (Lightning Flood)
    [23208] = true,  -- Lightning Flood (Lightning Flood)

    [23670] = true,  -- Surge (Surge)
    [131310] = true, -- Major Sorcery (Surge)
    [23673] = true,  -- Major Brutality (Surge)
    [64492] = true,  -- Surge (Surge)

    [23674] = true,  -- Power Surge (Power Surge)
    [62062] = true,  -- Major Sorcery (Power Surge)
    [62060] = true,  -- Major Brutality (Power Surge)
    [64500] = true,  -- Power Surge (Power Surge)

    [23678] = true,  -- Critical Surge (Critical Surge)
    [131311] = true, -- Major Sorcery (Critical Surge)
    [62147] = true,  -- Major Brutality (Critical Surge)
    [23682] = true,  -- Critical Surge (Critical Surge)

    [51392] = true,  -- Bolt Escape Fatigue (Bolt Escape - All Morphs)
    [23234] = true,  -- Bolt Escape (Bolt Escape)
    [23235] = true,  -- Bolt Escape (Bolt Escape)

    [23236] = true,  -- Streak (Streak)
    [23239] = true,  -- Streak (Streak)
    [28482] = true,  -- Streak (Streak)
    [132946] = true, -- Streak (Streak)

    [23277] = true,  -- Ball of Lightning (Ball of Lightning)
    [131383] = true, -- Ball of Lightning (Ball of Lightning)
    [23283] = true,  -- Summoned Ball of Lightning (Ball of Lightning)
    [23284] = true,  -- Intercept (Ball of Lightning)
    [23279] = true,  -- Ball of Lightning (Ball of Lightning)
    [70518] = true,  -- 1 Orb up (Ball of Lightning)

    [24785] = true,  -- Overload (Overload)
    [24799] = true,  -- Overload End (Overload)
    [26111] = true,  -- Shock Dummy (Overload - Light Attack)
    [24792] = true,  -- Overload Light Attack (Overload - Light Attack)
    [24794] = true,  -- Overload Heavy Attack (Overload - Heavy Attack)
    [24798] = true,  -- Overload Heavy Attack (Overload - Heavy Attack)
    [119624] = true, -- Remove Overload (Overload - Heavy Attack)
    [132865] = true, -- Remove Overload (Overload - Heavy Attack)

    [24806] = true,  -- Power Overload (Power Overload)
    [24808] = true,  -- Overload End (Power Overload)
    [114770] = true, -- Shock Dummy (Power Overload - Light Attack)
    [114769] = true, -- Power Overload Light Attack (Power Overload - Light Attack)
    [24810] = true,  -- Power Overload Heavy Attack (Power Overload - Heavy Attack)
    [24811] = true,  -- Power Overload Heavy Attack (Power Overload - Heavy Attack)
    [28434] = true,  -- Remove Overload (Power Overload - Heavy Attack)
    [132866] = true, -- Remove Overload (Power Overload - Heavy Attack)

    [24804] = true,  -- Energy Overload (Energy Overload)
    [24805] = true,  -- Overload End (Energy Overload)
    [114774] = true, -- Shock Dummy (Energy Overload - Light Attack)
    [114773] = true, -- Energy Overload Light Attack (Energy Overload - Light Attack)
    [114797] = true, -- Energy Overload Heavy Attack (Energy Overload - Heavy Attack)
    [114798] = true, -- Energy Overload Heavy Attack (Energy Overload - Heavy Attack)
    [29740] = true,  -- Energy Overload (Energy Overload)
    [114800] = true, -- Remove Overload (Energy Overload - Heavy Attack)
    [132867] = true, -- Remove Overload (Energy Overload - Heavy Attack)

    -------------------------------------
    -- TEMPLAR PASSIVES -----------------
    -------------------------------------

    -- Aedric Spear
    [31698] = true,  -- Piercing Spear (Rank 1)
    [44046] = true,  -- Piercing Spear (Rank 2)
    [31708] = true,  -- Spear Wall (Rank 1)
    [114838] = true, -- Minor Protection (Spear Wall)
    [44721] = true,  -- Spear Wall (Rank 2)
    [114841] = true, -- Minor Protetion (Spear Wall)
    [31718] = true,  -- Burning Light (Rank 1)
    [144021] = true, -- Burning Light
    [80153] = true,  -- Burning Light
    [44730] = true,  -- Burning Light (Rank 2)
    [144028] = true, -- Burning Light
    [80170] = true,  -- Burning Light
    [31565] = true,  -- Balanced Warrior (Rank 1)
    [44732] = true,  -- Balanced Warrior (Rank 2)

    -- Dawn's Wrath
    [31739] = true, -- Enduring Rays (Rank 1)
    [45214] = true, -- Enduring Rays (Rank 2)
    [31744] = true, -- Prism (Rank 1)
    [31746] = true, -- Prism
    [45216] = true, -- Prism (Rank 2)
    [45217] = true, -- Prism
    [31743] = true, -- Illuminate (Rank 1)
    [62799] = true, -- Minor Sorcery
    [45215] = true, -- Illuminate (Rank 2)
    [62800] = true, -- Minor Sorcery
    [31721] = true, -- Restoring Spirit (Rank 1)
    [45212] = true, -- Restoring Spirit (Rank 2)

    -- Restoring Light
    [31751] = true,  -- Mending (Rank 1)
    [45206] = true,  -- Mending (Rank 2)
    [31757] = true,  -- Sacred Ground (Rank 1)
    [45207] = true,  -- Sacred Ground (Rank 2)
    [31759] = true,  -- Sacred Ground
    [134627] = true, -- Minor Mending

    [31760] = true,  -- Light Weaver (Rank 1)
    [45208] = true,  -- Light Weaver (Rank 2)
    [52703] = true,  -- Light Weaver Ultimate
    [31747] = true,  -- Master Ritualist (Rank 1)
    [31748] = true,  -- Soul Trap
    [45202] = true,  -- Master Ritualist (Rank 2)
    [45203] = true,  -- Soul Trap

    -------------------------------------
    -- TEMPLAR ACTIVES ------------------
    -------------------------------------

    [26114] = true,  -- Puncturing Strikes (Puncturing Strikes)
    [26116] = true,  -- Puncturing Strikes (Puncturing Strikes)
    [44426] = true,  -- Puncturing Strikes (Puncturing Strikes)
    [76908] = true,  -- Puncturing Strikes (Puncturing Strikes)

    [26792] = true,  -- Biting Jabs (Biting Jabs)
    [26795] = true,  -- Major Savagery (Biting Jabs)
    [26794] = true,  -- Biting Jabs (Biting Jabs)
    [44432] = true,  -- Biting Jabs (Biting Jabs)
    [76912] = true,  -- Biting Jabs (Biting Jabs)

    [26797] = true,  -- Puncturing Sweep (Puncturing Sweep)
    -- [55183] = true, -- Puncturing Sweep Healing (Puncturing Sweep)
    [144127] = true, -- Puncturing Sweep Healing (Puncturing Sweep)
    [26799] = true,  -- Puncturing Sweep (Puncturing Sweep)
    [44436] = true,  -- Puncturing Sweep (Puncturing Sweep)
    [76916] = true,  -- Puncturing Sweep (Puncturing Sweep)

    [26158] = true,  -- Piercing Javelin (Piercing Javelin)
    [37409] = true,  -- Piercing Javelin (Piercing Javelin)
    [26162] = true,  -- Piercing Javelin (Piercing Javelin)

    [26802] = true,  -- Aurora Javelin Damage Bonus (Aurora Javelin)
    [26800] = true,  -- Aurora Javelin (Aurora Javelin)
    [37414] = true,  -- Piercing Javelin (Aurora Javelin)
    [26801] = true,  -- Aurora Javelin (Aurora Javelin)

    [26804] = true,  -- Binding Javelin (Binding Javelin)
    [32099] = true,  -- Binding Javelin (Binding Javelin)

    [22149] = true,  -- Focused Charge (Focused Charge)
    [22155] = true,  -- Focused Charge (Focused Charge)
    [26508] = true,  -- Charge (Focused Charge)
    [49204] = true,  -- Focused Charge (Focused Charge)
    [49205] = true,  -- Focused Charge (Focused Charge)

    [22161] = true,  -- Explosive Charge (Explosive Charge)
    [43585] = true,  -- Explosive Charge AoE Dummy (Explosive Charge
    [22165] = true,  -- Explosive Charge (Explosive Charge)
    [26522] = true,  -- Charge (Explosive Charge)
    [49212] = true,  -- Explosive Charge (Explosive Charge)
    [49213] = true,  -- Explosive Charge (Explosive Charge)

    [15540] = true,  -- Toppling Charge (Toppling Charge)
    [15544] = true,  -- Toppling Charge (Toppling Charge)
    [15546] = true,  -- Toppling Charge (Toppling Charge)
    [26518] = true,  -- Charge (Toppling Charge)

    [94973] = true,  -- Blessed Shards (Spear Shards - All Ranks)
    [94974] = true,  -- Blessed Shards (Spear Shards - All Ranks)
    [48052] = true,  -- Spear Shards / Necrotic Orb CD (Spear Shards - All Ranks)
    [26832] = true,  -- Blessed Shrads (Spear Shards - All Ranks)
    [26188] = true,  -- Spear Shards (Spear Shards)
    [26190] = true,  -- Spear Shards (Spear Shards)
    [95932] = true,  -- Spear Shards (Spear Shards)
    [95933] = true,  -- Spear Shards (Spear Shards)
    [26827] = true,  -- Spear Shards (Spear Shards)
    [26192] = true,  -- Spear Shards (Spear Shards)
    [95931] = true,  -- Spear Shards (Spear Shards)

    [95926] = true,  -- Holy Shards (Luminous Shards - All Ranks)
    [95925] = true,  -- Holy Shards (Luminous Shards - All Ranks)
    [95924] = true,  -- Spear Shards / Necrotic Orb CD (Luminous Shards - All Ranks)
    [26858] = true,  -- Luminous Shards (Luminous Shards)
    [26860] = true,  -- Luminous Shards (Luminous Shards)
    [95956] = true,  -- Luminous Shards (Luminous Shards)
    [95957] = true,  -- Luminous Shards (Luminous Shards)
    [26863] = true,  -- Luminous Shards (Luminous Shards)
    [26859] = true,  -- Luminous Shards (Luminous Shards)
    [95955] = true,  -- Luminous Shards (Luminous Shards)

    [26869] = true,  -- Blazing Spear (Blazing Spear)
    [26878] = true,  -- Blazing Spear (Blazing Spear)
    [44445] = true,  -- Blazing Spear (Blazing Spear)
    [26880] = true,  -- Blazing Spear (Blazing Spear)
    [26874] = true,  -- Blazing Spear (Blazing Spear)
    [26871] = true,  -- Blazing Spear (Blazing Spear)
    [26879] = true,  -- Blazing Spear (Blazing Spear)

    [22178] = true,  -- Sun Shield (Sun Shield)
    [22179] = true,  -- Sun Shield (Sun Shield)
    [26724] = true,  -- Sun Shield Hit Bonus (Sun Shield)

    [22182] = true,  -- Radiant Ward (Radiant Ward)
    [22183] = true,  -- Radiant Ward (Radiant Ward)
    [26732] = true,  -- Sun Shield Hit Bonus (Radiant Ward)

    [22180] = true,  -- Blazing Shield (Blazing Shield)
    [49091] = true,  -- Blazing Shield (Blazing Shield)
    [49090] = true,  -- Sun Shield Hit Bonus (Blazing Shield)
    [22184] = true,  -- Blazing Shield (Blazing Shield)
    [22181] = true,  -- Blazing Shield (Blazing Shield)

    [22138] = true,  -- Radial Sweep (Radial Sweep)
    [62593] = true,  -- Radial Sweep (Radial Sweep)
    [62550] = true,  -- Radial Sweep (Radial Sweep)

    [22144] = true,  -- Empowering Sweep (Empowering Sweep)
    [122288] = true, -- Empowering Sweep (Empowering Sweep)
    [62599] = true,  -- Empowering Sweep (Empowering Sweep)
    [62598] = true,  -- Empowering Sweep (Empowering Sweep)

    [22139] = true,  -- Crescent Sweep (Crescent Sweep)
    [22143] = true,  -- Crescent Sweep (Crescent Sweep)
    [62607] = true,  -- Crescent Sweep (Crescent Sweep)
    [62606] = true,  -- Radial Sweep (Crescent Sweep)
    [115476] = true, -- Crescent Sweep (Crescent Sweep)

    [21726] = true,  -- Sun Fire (Sun Fire)
    [21728] = true,  -- Sun Fire (Sun Fire)
    [62747] = true,  -- Major Prophecy (Sun Fire)

    [21729] = true,  -- Vampire's Bane (Vampire's Bane)
    [21731] = true,  -- Vampire's Bane (Vampire's Bane)
    [62751] = true,  -- Major Prophecy (Vampire's Bane)

    [21732] = true,  -- Reflective Light (Reflective Light)
    [21733] = true,  -- Reflective Light (Reflective Light)
    [21734] = true,  -- Reflective Light (Reflective Light)
    [62755] = true,  -- Major Prophecy (Reflective Light)

    [22057] = true,  -- Solar Flare (Solar Flare)
    [109418] = true, -- Empower (Solar Flare)

    [22110] = true,  -- Dark Flare (Dark Flare)
    [63008] = true,  -- Dark Flare Trauma (Dark Flare)
    [24686] = true,  -- Major Defile (Dark Flare)
    [109419] = true, -- Empower (Dark Flare)

    [22095] = true,  -- Solar Barrage (Solar Barrage)
    [109420] = true, -- Empower (Solar Barrage)
    [100223] = true, -- Solar Barrage (Solar Barrage)
    [100218] = true, -- Solar Barrage (Solar Barrage)

    [21761] = true,  -- Backlash (Backlash)
    [22643] = true,  -- Backlash D (Backlash)
    [89821] = true,  -- Backlash (Backlash)
    [22645] = true,  -- Backlash (Backlash)
    [26411] = true,  -- Backlash (Backlash)

    [21765] = true,  -- Purifying Light (Purifying Light)
    [25802] = true,  -- Purifying Light (Purifying Light)
    [89825] = true,  -- Purifying Light (Purifying Light)
    [25800] = true,  -- Purifying Light (Purifying Light)
    [27544] = true,  -- Purifying Light (Purifying Light)
    [68581] = true,  -- Purifying Light (Purifying Light)
    [69168] = true,  -- Purifying Light Heal FX (Purifying Light)
    [21908] = true,  -- Purifying Light (Purifying Light)

    [21763] = true,  -- Power of the Light (Power of the Light)
    [68588] = true,  -- Minor Breach (Power of the Light)
    [25799] = true,  -- Power of the Light (Power of the Light)
    [89828] = true,  -- Power of the Light (Power of the Light)
    [25797] = true,  -- Power of the Light (Power of the Light)
    [27567] = true,  -- Power of the Light (Power of the Light)

    [21776] = true,  -- Eclipse (Eclipse)
    [129880] = true, -- Eclipse (Eclipse)
    [127770] = true, -- Eclipse (Eclipse)
    [127769] = true, -- Eclipse (Eclipse)
    [127771] = true, -- Eclipse (Eclipse)
    [127772] = true, -- Eclipse (Eclipse)

    [22006] = true,  -- Living Dark (Living Dark)
    [63083] = true,  -- Living Dark (Living Dark)
    [127795] = true, -- Living Dark (Living Dark)

    [22004] = true,  -- Unstable Core (Unstable Core)
    [129879] = true, -- Unstable Core (Unstable Core)
    [127786] = true, -- Unstable Core (Unstable Core)
    [127791] = true, -- Unstable Core (Unstable Core)
    [127787] = true, -- Unstable Core (Unstable Core)
    [127792] = true, -- Unstable Core (Unstable Core)
    [127790] = true, -- Unstable Core (Unstable Core)
    [127793] = true, -- Unstable Core (Unstable Core)
    [127788] = true, -- Unstable Core (Unstable Core)

    [63029] = true,  -- Radiant Destruction (Radiant Destruction)
    [63952] = true,  -- Radiant Destruction (Radiant Destruction)

    [63044] = true,  -- Radiant Glory (Radiant Glory)
    [69118] = true,  -- Radiant Glory Heal (Radiant Glory)
    [63956] = true,  -- Radiant Glory (Radiant Glory)

    [63046] = true,  -- Radiant Oppression (Radiant Oppression)
    [63961] = true,  -- Radiant Oppression (Radiant Oppression)

    [48939] = true,  -- Supernova (Nova - Supernova Synergy)
    [31540] = true,  -- Supernova (Nova - Supernova Synergy)
    [31562] = true,  -- Supernova (Nova - Supernova Synergy)
    [102770] = true, -- Supernova Area Effect (Nova - Supernova Synergy)

    [21752] = true,  -- Nova (Nova)
    [21995] = true,  -- Nova (Nova)
    [21976] = true,  -- Nova (Nova)
    [21753] = true,  -- Nova (Nova)
    [21754] = true,  -- Nova (Nova)
    [31537] = true,  -- Super Nova (Nova)

    [48938] = true,  -- Gravity Crush (Solar Prison - All Ranks)
    [31603] = true,  -- Gravity Crush (Solar Prison - All Ranks)
    [31604] = true,  -- Gravity Crush (Solar Prison - All Ranks)
    [34443] = true,  -- Gravity Crush (Solar Prison - All Ranks)
    [102782] = true, -- Gravity Crush (Solar Prison - All Ranks)

    [21755] = true,  -- Solar Prison (Solar Prison)
    [22002] = true,  -- Solar Prison (Solar Prison)
    [22003] = true,  -- Solar Prison (Solar Prison)
    [21756] = true,  -- Solar Prison (Solar Prison)
    [21757] = true,  -- Solar Prison (Solar Prison)
    [31598] = true,  -- Super Nova (Solar Prison)

    [21758] = true,  -- Solar Disturbance (Solar Disturbance)
    [22000] = true,  -- Solar Disturbance (Solar Disturbance)
    [22001] = true,  -- Solar Disturbance (Solar Disturbance)
    [21759] = true,  -- Solar Disturbance (Solar Disturbance)
    [21760] = true,  -- Solar Disturbance (Solar Disturbance)
    [31597] = true,  -- Super Nova (Solar Disturbance)

    [22250] = true,  -- Rushed Ceremony (Rushed Ceremony)

    [22253] = true,  -- Honor the Dead (Honor the Dead)
    [35632] = true,  -- Honor the Dead (Honor the Dead)

    [22256] = true,  -- Breath of Life (Breath of Life)
    [44391] = true,  -- Breath of Life (Breath of Life)

    [22304] = true,  -- Healing Ritual (Healing Ritual)

    [22327] = true,  -- Ritual of Rebirth (Ritual of Rebirth)
    [88456] = true,  -- Ritual of Rebirth (Ritual of Rebirth)

    [22314] = true,  -- Hasty Prayer (Hasty Prayer)
    [108935] = true, -- Minor Expedition (Hasty Prayer)

    [26207] = true,  -- Restoring Aura Passive (Restoring Aura - All Morphs)
    [26213] = true,  -- Minor Fortitude (Restoring Aura - All Morphs)
    [26216] = true,  -- Minor Intellect (Restoring Aura - All Morphs)
    [26215] = true,  -- Minor Endurance (Restoring Aura - All Morphs)
    [26209] = true,  -- Restoring Aura (Restoring Aura)
    [26220] = true,  -- Minor Magickasteal (Restoring Aura)

    [26807] = true,  -- Radiant Aura (Radiant Aura)
    [26809] = true,  -- Minor Magickasteal (Radiant Aura)

    [26821] = true,  -- Repentance (Repentance)
    [26823] = true,  -- Repentance (Repentance)
    [26824] = true,  -- Repentance (Repentance)
    [124700] = true, -- Repentance (Repentance)
    [124701] = true, -- Minor Fortitude (Repentance)
    [124702] = true, -- Minor Intellect (Repentance)
    [124703] = true, -- Minor Endurance (Repentance)

    [22270] = true,  -- Purify (Cleansing Ritual - Purify Synergy)
    [44013] = true,  -- Purify (Cleansing Ritual - Purify Synergy)
    [22269] = true,  -- Purify (Cleansing Ritual - Purify Synergy)
    [22265] = true,  -- Cleansing Ritual (Cleansing Ritual)
    [26286] = true,  -- Healing Ritual (Cleansing Ritual)
    [26290] = true,  -- Clensing Ritual Dummy (Cleansing Ritual)
    [26295] = true,  -- Purify (Cleansing Ritual)

    [22259] = true,  -- Ritual of Retribution (Ritual of Retribution)
    [143432] = true, -- Ritual of Retribution (Ritual of Retribution)
    [80172] = true,  -- Ritual of Retribution (Ritual of Retribution)
    [26299] = true,  -- Ritual of Retribution (Ritual of Retribution)
    [26300] = true,  -- Purify (Ritual of Retribution)

    [22262] = true,  -- Extended Ritual (Extended Ritual)
    [26303] = true,  -- Extended Ritual (Extended Ritual)
    [26304] = true,  -- Clensing Ritual Dummy (Extended Ritual)
    [26305] = true,  -- Purify (Extended Ritual)

    [22236] = true,  -- Major Resolve (Rune Focus)
    [22234] = true,  -- Rune Focus (Rune Focus)
    [33516] = true,  -- Summon Shade (Rune Focus)
    [112145] = true, -- Rune Focus Circle Bonus (Rune Focus)

    [44828] = true,  -- Major Resolve (Channeled Focus)
    [22240] = true,  -- Channeled Focus (Channeled Focus)
    [33524] = true,  -- Summon Shade (Channeled Focus)
    [37009] = true,  -- Channeled Focus (Channeled Focus)
    [112166] = true, -- Rune Focus Circle Bonus (Channeled Focus)

    [44836] = true,  -- Major Resolve (Restoring Focus)
    [22237] = true,  -- Restoring Focus (Restoring Focus)
    [33528] = true,  -- Restoring Focus (Restoring Focus)
    [114842] = true, -- Restoring Focus (Restoring Focus)
    [112167] = true, -- Rune Focus Circle Bonus (Restoring Focus)

    [22223] = true,  -- Rite of Passage (Rite of Passage)
    [22225] = true,  -- Rite of Passage (Rite of Passage)
    [26380] = true,  -- Rite of Passage Self Snare (Rite of Passage)

    [22229] = true,  -- Remembrance (Remembrance)
    [22231] = true,  -- Remembrance (Remembrance)
    [26381] = true,  -- Rite of Passage Self Snare (Remembrance)
    [22233] = true,  -- Major Protection (Remembrance)

    [22226] = true,  -- Practiced Incantation (Practiced Incantation)
    [22228] = true,  -- Practiced Incantation (Practiced Incantation)
    [26383] = true,  -- Practiced Incantation (Practiced Incantation)

    -------------------------------------
    -- WARDEN PASSIVES ------------------
    -------------------------------------

    -- Animal Companions
    [86064] = true, -- Bond With Nature (Rank 1)
    [86065] = true, -- Bond With Nature (Rank 2)
    -- [88988] = true, -- Bond With Nature
    [88515] = true, -- Bond With Nature Trigger (Bond With Nature)
    [86062] = true, -- Savage Beast (Rank 1)
    [88512] = true, -- Savage Beast Ultimate
    [86063] = true, -- Savage Beast (Rank 2)
    [88513] = true, -- Transfer
    [86066] = true, -- Flourish (Rank 1)
    [86067] = true, -- Flourish (Rank 2)
    [86068] = true, -- Advanced Species (Rank 1)
    [86069] = true, -- Advanced Species (Rank 2)

    -- Green Balance
    [85882] = true, -- Accelerated Growth (Rank 1)
    [88525] = true, -- Major Mending
    [85883] = true, -- Accelerated Growth (Rank 2)
    [88528] = true, -- Major Mending
    [85878] = true, -- Nature's Gift (Rank 1)
    [88483] = true, -- Nature's Give
    [93054] = true, -- Nature's Gift
    [85879] = true, -- Nature's Gift (Rank 2)
    [93072] = true, -- Nature's Give
    [93073] = true, -- Nature's Gift
    [85876] = true, -- Emerald Moss (Rank 1)
    [85877] = true, -- Emerald Moss (Rank 2)
    [85880] = true, -- Maturation (Rank 1)
    [88492] = true, -- Minor Toughness
    [85881] = true, -- Maturation (Rank 2)
    [88509] = true, -- Minor Toughness

    -- Winter's Embrace
    [86191] = true, -- Glacial Presence (Rank 1)
    [86192] = true, -- Glacial Presence (Rank 2)
    [86189] = true, -- Frozen Armor (Rank 1)
    [86190] = true, -- Frozen Armor (Rank 2)
    [86193] = true, -- Icy Aura (Rank 1)
    [86194] = true, -- Icy Aura (Rank 2)
    [86195] = true, -- Piercing Cold (Rank 1)
    [86196] = true, -- Piercing Cold (Rank 2)

    -------------------------------------
    -- WARDEN ACTIVES -------------------
    -------------------------------------

    [85995] = true,  -- Dive (Dive)
    [130129] = true, -- Off-Balance (Dive)

    [85999] = true,  -- Cutting Dive (Cutting Dive)
    [130139] = true, -- Off-Balance (Cutting Dive)
    [131441] = true, -- Arms of Relequen (Cutting Dive)
    [130140] = true, -- Cutting Dive (Cutting Dive)

    [87663] = true,  -- Screaming Cliff Racer (Screaming Cliff Racer)
    [86003] = true,  -- Screaming Cliff Racer (Screaming Cliff Racer)
    [130145] = true, -- Off-Balance (Screaming Cliff Racer)

    [86009] = true,  -- Scorch (Scorch)
    [94412] = true,  -- Scorch (Scorch)
    [94409] = true,  -- Scorch (Scorch)
    [94410] = true,  -- Scorch (Scorch)
    [94411] = true,  -- Scorch (Scorch)

    [86019] = true,  -- Subterranean Assault (Subterranean Assault)
    [94440] = true,  -- Subterranean Assault (Subterranean Assault)
    [94441] = true,  -- Subterranean Assault (Subterranean Assault)
    [94442] = true,  -- Subterranean Assault (Subterranean Assault)
    [94445] = true,  -- Subterranean Assault (Subterranean Assault)
    [146919] = true, -- Subterranean Assault (Subterranean Assault)

    [86015] = true,  -- Deep Fissure (Deep Fissure)
    [94421] = true,  -- Deep Fissure (Deep Fissure)
    [94422] = true,  -- Deep Fissure (Deep Fissure)
    [94423] = true,  -- Deep Fissure (Deep Fissure)
    [94424] = true,  -- Deep Fissure (Deep Fissure)
    [108951] = true, -- Major Breach (Deep Fissure)

    [86023] = true,  -- Swarm (Swarm)
    [101703] = true, -- Swarm (Swarm)
    [130155] = true, -- Minor Vulnerability (Swarm)

    [86027] = true,  -- Fetcher Infection (Fetcher Infection)
    [91416] = true,  -- Fetcher Infection Bonus Damage (Fetcher Infection)
    [101904] = true, -- Fetcher Infection (Fetcher Infection)
    [130168] = true, -- Minor Vulnerability (Fetcher Infection)
    [87687] = true,  -- Bonus Damage Fetcher Infection (Fetcher Infection)

    [86031] = true,  -- Growing Swarm (Growing Swarm)
    [101944] = true, -- Growing Swarm (Growing Swarm)
    [130173] = true, -- Minor Vulnerability (Growing Swarm)
    [130170] = true, -- Growing Swarm (Growing Swarm)

    [89103] = true,  -- Betty Netch Summon (Betty Netch - All Morphs)
    [87875] = true,  -- Betty Netch (Betty Netch)
    [86050] = true,  -- Betty Netch (Betty Netch)
    [131346] = true, -- Major Brutality (Betty Netch)
    [87929] = true,  -- Major Sorcery (Betty Netch)
    [86106] = true,  -- Betty Netch (Betty Netch)
    [131345] = true, -- Blue Betty (Betty Netch)

    [86054] = true,  -- Blue Betty (Blue Betty)
    [131350] = true, -- Major Brutality (Blue Betty)
    [89107] = true,  -- Major Sorcery (Blue Betty)
    [89106] = true,  -- Blue Betty (Blue Betty)
    [87933] = true,  -- Blue Betty (Blue Betty)
    [114854] = true, -- Betty Netch (Blue Betty)

    [86058] = true,  -- Bull Netch (Bull Netch)
    [89110] = true,  -- Major Brutality (Bull Netch)
    [95125] = true,  -- Major Sorcery (Bull Netch)
    [89109] = true,  -- Bull Netch (Bull Netch)
    [86103] = true,  -- Bull Netch (Bull Netch)
    [131351] = true, -- Blue Betty (Bull Netch)
    [114853] = true, -- Bull Netch (Bull Netch)

    [86037] = true,  -- Falcon's Swiftness (Falcon's Swiftness)
    [86267] = true,  -- Major Expedition (Falcon's Swiftness)

    [86041] = true,  -- Deceptive Predator (Deceptive Predator)
    [89076] = true,  -- Major Expedition (Deceptive Predator)
    [114858] = true, -- Minor Evasion (Deceptive Predator)

    [86045] = true,  -- Bird of Prey (Bird of Prey)
    [89078] = true,  -- Major Expedition (Bird of Prey)
    [114862] = true, -- Minor Berserk (Bird of Prey)

    [89363] = true,  -- Feral Guardian Summon (Feral Guardian - All Morphs)
    [93134] = true,  -- Guardian's Wrath Trigger (Feral Guardian + Eternal Guardian)
    [101438] = true, -- Bear Immunity (Feral Guardian - All Morphs)

    [85982] = true,  -- Feral Guardian (Feral Guardian)
    [86074] = true,  -- Feral Guardian (Feral Guardian)
    [89135] = true,  -- Swipe (Feral Guardian)
    [89128] = true,  -- Crushing Swipe (Feral Guardian)
    [89129] = true,  -- Crushing Swipe (Feral Guardian)
    [90284] = true,  -- Guardian's Wrath (Feral Guardian)
    [93144] = true,  -- Guardian's Wrath Trigger (Feral Guardian)
    [91974] = true,  -- Guardian's Wrath (Feral Guardian)

    [85986] = true,  -- Eternal Guardian (Eternal Guardian)
    [109982] = true, -- Eternal Guardian (Eternal Guardian)
    [89166] = true,  -- Eternal Guardian (Eternal Guardian)
    [105924] = true, -- Guardian's Wrath Trigger (Eternal Guardian)
    [105906] = true, -- Swipe (Eternal Guardian)
    [105907] = true, -- Crushing Swipe (Eternal Guardian)
    [105908] = true, -- Crushing Swipe (Eternal Guardian)
    [94625] = true,  -- Guardian's Wrath (Eternal Guardian)
    [94626] = true,  -- Guardian's Wrath Trigger (Eternal Guardian)
    [105921] = true, -- Guardian's Wrath (Eternal Guardian)
    [109983] = true, -- Eternal Guardian Revive (Eternal Guardian)
    [109990] = true, -- Eternal Guardian (Eternal Guardian)
    [110384] = true, -- Eternal Guardian (Eternal Guardian)
    [110401] = true, -- Eternal Guardian Respawning (Eternal Guardian)
    [110006] = true, -- Eternal Guardian (Eternal Guardian)

    [85990] = true,  -- Wild Guardian (Wild Guardian)
    [89207] = true,  -- Wild Guardian (Wild Guardian)
    [95104] = true,  -- Guardian's Savagery Trigger (Wild Guardian)
    [89219] = true,  -- Swipe (Wild Guardian)
    [89220] = true,  -- Crushing Swipe (Wild Guardian)
    [92666] = true,  -- Crushing Swipe (Wild Guardian)
    [92163] = true,  -- Guardian's Savagery (Wild Guardian)
    [93233] = true,  -- Guardian's Savagery Trigger (Wild Guardian)
    [92160] = true,  -- Guardian's Savagery (Wild Guardian)

    [85536] = true,  -- Fungal Growth (Fungal Growth)

    [85862] = true,  -- Enchanted Growth (Enchanted Growth)
    [86300] = true,  -- Minor Intellect (Enchanted Growth)
    [87019] = true,  -- Minor Endurance (Enchanted Growth)

    [85863] = true,  -- Soothing Spores (Soothing Spores)
    [87938] = true,  -- Soothing Spores Healing Bonus (Soothing Spores)

    [85572] = true,  -- Harvest (Healing Seed - Harvest Synergy)
    [85577] = true,  -- Harvest (Healing Seed - Harvest Synergy)
    [85578] = true,  -- Healing Seed (Healing Seed)
    [85585] = true,  -- Healing Seed Dummy (Healing Seed)
    [85583] = true,  -- Harvest (Healing Seed)
    [85582] = true,  -- Healing Seed (Healing Seed)

    [85840] = true,  -- Budding Seeds (Budding Seeds)
    [85842] = true,  -- Budding Seeds Dummy (Budding Seeds)
    [85843] = true,  -- Harvest (Budding Seeds)
    [85841] = true,  -- Budding Seeds (Budding Seeds)
    [85922] = true,  -- Budding Seeds (Budding Seeds)
    [129434] = true, -- Budding Seeds (Budding Seeds)

    [85845] = true,  -- Corrupting Pollen (Corrupting Pollen)
    [85847] = true,  -- Corrupting Pollen Dummy (Corrupting Pollen)
    [85848] = true,  -- Harvest (Corrupting Pollen)
    [85846] = true,  -- Corrupting Pollen (Corrupting Pollen)
    [85944] = true,  -- Major Defile (Corrupting Pollen)

    [85552] = true,  -- Living Vines (Living Vines)
    [85559] = true,  -- Living Vines Heal (Living Vines)

    [85850] = true,  -- Leeching Vines (Leeching Vines)
    [88712] = true,  -- Leeching Vines (Leeching Vines)
    [86307] = true,  -- Minor Lifesteal (Leeching Vines)

    [85851] = true,  -- Living Trellis (Living Trellis)
    [88721] = true,  -- Living Trellis Heal (Living Trellis)
    [88723] = true,  -- Living Trellis Heal Burst (Living Trellis)

    [85539] = true,  -- Lotus Flower (Lotus Flower)
    [85550] = true,  -- Lotus Flower (Lotus Flower)
    [94558] = true,  -- Lotus Flower (Lotus Flower)

    [85854] = true,  -- Green Lotus (Green Lotus)
    [87061] = true,  -- Major Savagery (Green Lotus)
    [87058] = true,  -- Green Lotus (Green Lotus)
    [94571] = true,  -- Green Lotus (Green Lotus)

    [85855] = true,  -- Lotus Blossom (Lotus Blossom)
    [86303] = true,  -- Major Prophecy (Lotus Blossom)
    [88695] = true,  -- Lotus Blossom Heal (Lotus Blossom)
    [94590] = true,  -- Lotus Blossum Heal (Lotus Blossom)

    [85564] = true,  -- Nature's Grasp (Nature's Grasp)
    [90266] = true,  -- Nature's Grasp (Nature's Grasp)
    [108943] = true, -- Nature's Grasp Ultimate Restor (Nature's Grasp)
    [86356] = true,  -- Nature's Grasp (Nature's Grasp)

    [85859] = true,  -- Bursting Vines (Bursting Vines)
    [88739] = true,  -- Bursting Vines (Bursting Vines)
    [108947] = true, -- Bursting Vines Ultimate Rest (Bursting Vines)
    [85860] = true,  -- Bursting Vines (Bursting Vines)

    [85858] = true,  -- Nature's Embrace (Nature's Embrace)
    [88726] = true,  -- Nature's Embrace (Nature's Embrace)
    [87074] = true,  -- Nature's Embrace (Nature's Embrace)
    [108945] = true, -- Nature's Embrace Ultimate Rest (Nature's Embrace)
    [88729] = true,  -- Nature's Embrace (Nature's Embrace)

    [85532] = true,  -- Secluded Grove (Secluded Grove)
    [85533] = true,  -- Secluded Grove (Secluded Grove)
    [85534] = true,  -- Secluded Grove (Secluded Grove)

    [85804] = true,  -- Enchanted Forest (Enchanted Forest)
    [88748] = true,  -- Enchanted Forest (Enchanted Forest)
    [86357] = true,  -- Enchanted Forest (Enchanted Forest)
    [88747] = true,  -- Enchanted Forest (Enchanted Forest)

    [85807] = true,  -- Healing Thicket (Healing Thicket)
    [88750] = true,  -- Healing Thicket (Healing Thicket)
    [91819] = true,  -- Healing Thicket (Healing Thicket)

    [86122] = true,  -- Frost Cloak (Frost Cloak)
    [86224] = true,  -- Major Resolve (Frost Cloak)

    [86126] = true,  -- Expansive Frost Cloak (Expansive Frost Cloak)
    [88758] = true,  -- Major Resolve (Expansive Frost Cloak)

    [86130] = true,  -- Ice Fortress (Ice Fortress)
    [88761] = true,  -- Major Resolve (Ice Fortress)
    [87194] = true,  -- Minor Protection (Ice Fortress)

    [86161] = true,  -- Impaling Shards (Impaling Shards)
    [88920] = true,  -- Impaling Shards Dummy (Impaling Shards)
    [88783] = true,  -- Impaling Shards (Impaling Shards)
    [86238] = true,  -- Impaling Shards (Impaling Shards)

    [86165] = true,  -- Gripping Shards (Gripping Shards)
    [88993] = true,  -- Impaling Shards Dummy (Gripping Shards)
    [87443] = true,  -- Gripping Shards (Gripping Shards)
    [88791] = true,  -- Gripping Shards (Gripping Shards)
    [87448] = true,  -- Gripping Shards (Gripping Shards)

    [86169] = true,  -- Winter's Revenge (Winter's Revenge)
    [88994] = true,  -- Impaling Shards Dummy (Winter's Revenge)
    [88802] = true,  -- Winter's Revenge (Winter's Revenge)
    [88801] = true,  -- Winter's Revenge (Winter's Revenge)

    [86148] = true,  -- Arctic Wind (Arctic Wind)
    [90833] = true,  -- Arctic Wind (Arctic Wind)

    [86152] = true,  -- Polar Wind (Polar Wind)
    [90835] = true,  -- Polar Wind (Polar Wind)
    [88776] = true,  -- Polar Wind (Polar Wind)
    [176422] = true, -- Polar Wind (Polar Wind)

    [86156] = true,  -- Arctic Blast (Arctic Blast)
    [90834] = true,  -- Arctic Blast (Arctic Blast)
    [130406] = true, -- Arctic Blast (Arctic Blast)
    [130409] = true, -- Arctic Blast (Arctic Blast)

    [86135] = true,  -- Crystallized Shield (Crystallized Shield)
    [87227] = true,  -- Crystallized Shield (Crystallized Shield)
    [87224] = true,  -- Crystallized Shield (Crystallized Shield)
    [87226] = true,  -- Crystallized Shield (Crystallized Shield)

    [86139] = true,  -- Crystallized Slab (Crystallized Slab)
    [88769] = true,  -- Crystalized Slab Stack Counter (Crystallized Slab)
    [88768] = true,  -- Crystalized Slab (Crystallized Slab)
    [93175] = true,  -- Crystallized Slab (Crystallized Slab)

    [86143] = true,  -- Shimmering Shield (Shimmering Shield)
    [88774] = true,  -- Shimmering Shield Stack Count (Shimmering Shield)
    [88771] = true,  -- Shimmering Shield Restore (Shimmering Shield)
    [87234] = true,  -- Major Herosim (Shimmering Shield)
    [88773] = true,  -- Shimmering Shield Remover (Shimmering Shield)

    [86175] = true,  -- Frozen Gate (Frozen Gate)
    [86256] = true,  -- Frozen Gate (Frozen Gate)
    [86264] = true,  -- Frozen Gate (Frozen Gate)
    [108948] = true, -- Frozen Gate (Frozen Gate)
    [89812] = true,  -- Frozen Gate (Frozen Gate)
    [87560] = true,  -- Frozen Gate (Frozen Gate)

    [86179] = true,  -- Frozen Device (Frozen Device)
    [92031] = true,  -- Frozen Gate Dummy (Frozen Device)
    [92032] = true,  -- Frozen Gate Move Position (Frozen Device)
    [108949] = true, -- Frozen Device (Frozen Device)
    [92038] = true,  -- Frozen Gate Root (Frozen Device)
    [92039] = true,  -- Frozen Gate Root (Frozen Device)
    [92041] = true,  -- Major Maim (Frozen Device)

    [88887] = true,  -- Icy Escape Move Position (Frozen Retreat - Icy Escape Synergy
    [88892] = true,  -- Icy Escape Cooldown (Frozen Retreat - Icy Escape Synergy
    [103321] = true, -- Major Expedition (Frozen Retreat - Icy Escape Synergy

    [86183] = true,  -- Frozen Retreat (Frozen Retreat)
    [92052] = true,  -- Frozen Retreat (Frozen Retreat)
    [92062] = true,  -- Frozen Retreat (Frozen Retreat)
    [92053] = true,  -- Frozen Retreat (Frozen Retreat)
    [108950] = true, -- Frozen Retreat (Frozen Retreat)
    [92058] = true,  -- Frozen Retreat (Frozen Retreat)
    [92060] = true,  -- Frozen Retreat (Frozen Retreat)
    [92061] = true,  -- Frozen Retreat (Frozen Retreat)

    [86109] = true,  -- Sleet Storm (Sleet Storm)
    [86249] = true,  -- Major Protection (Sleet Storm)
    [86247] = true,  -- Sleet Storm (Sleet Storm)
    [86250] = true,  -- Sleet Storm (Sleet Storm)

    [86113] = true,  -- Northern Storm (Northern Storm)
    [132429] = true, -- Northern Storm (Northern Storm)
    [88859] = true,  -- Major Protection (Northern Storm)
    [88860] = true,  -- Northern Storm (Northern Storm)
    [88858] = true,  -- Northern Storm (Northern Storm)

    [86117] = true,  -- Permafrost (Permafrost)
    [88862] = true,  -- Major Protection (Permafrost)
    [88863] = true,  -- Permafrost (Permafrost)
    [88861] = true,  -- Permafrost (Permafrost)

    -------------------------------------
    -- NECROMANCER PASSIVES -------------
    -------------------------------------

    -- Grave Lord Passives
    [116186] = true, -- Reusable Parts (Rank 1)
    [116187] = true, -- Reusable Parts (Rank 1)
    [116188] = true, -- Reusable Parts (Rank 2)
    [116189] = true, -- Reusable Parts (Rank 2)

    [116197] = true, -- Death Knell (Rank 1)
    [116198] = true, -- Death Knell (Rank 2)

    [116192] = true, -- Dismember (Rank 1)
    [116194] = true, -- Dismember (Rank 2)

    [116199] = true, -- Rapid Rot (Rank 1)
    [116201] = true, -- Rapid Rot (Rank 2)

    -- Bone Tyrant Passives
    [116230] = true, -- Death Gleaning (Rank 1)
    [119156] = true, -- Death Gleaning (Rank 1)
    [119158] = true, -- Death Gleaning (Rank 1)
    [116235] = true, -- Death Gleaning (Rank 2)
    [119164] = true, -- Death Gleaning (Rank 2)
    [119165] = true, -- Death Gleaning (Rank 2)

    [116239] = true, -- Disdain Harm (Rank 1)
    [116240] = true, -- Disdain Harm (Rank 2)

    [116269] = true, -- Health Avarice (Rank 1)
    [116270] = true, -- Health Avarice (Rank 2)

    [116271] = true, -- Last Gasp (Rank 1)
    [116272] = true, -- Last Gasp (Rank 2)

    -- Living Death Passives
    [116286] = true, -- Curative Curse (Rank 1)
    [116287] = true, -- Curative Curse (Rank 1)

    [116273] = true, -- Near-Death Experience (Rank 1)
    [116275] = true, -- Near-Death Experience (Rank 2)

    [116282] = true, -- Undead Confederate (Rank 1)
    [116283] = true, -- Undead Confederate (Rank 2)

    [116284] = true, -- Corpse Consumption (Rank 1)
    [120611] = true, -- Corpse Consumption (Rank 1)
    [116285] = true, -- Corpse Consumption (Rank 2)
    [120612] = true, -- Corpse Consumption (Rank 2)

    -------------------------------------
    -- NECROMANCER ACTIVES --------------
    -------------------------------------

    [114108] = true, -- Flame Skull (Flame Skull)
    [114131] = true, -- Flame Skull (Flame Skull)
    [123683] = true, -- Flame Skull (Flame Skull)
    [123685] = true, -- Flame Skull (Flame Skull)

    [117629] = true, -- Venom Skull (Venom Skull)
    [117624] = true, -- Venom Skull (Venom Skull)
    [117625] = true, -- Venom Skull (Venom Skull)
    [123699] = true, -- Venom Skull (Venom Skull)
    [123704] = true, -- Venom Skull (Venom Skull)

    [117637] = true, -- Ricochet Skull (Ricochet Skull)
    [117638] = true, -- Ricochet Skull (Ricochet Skull)
    [123718] = true, -- Ricochet Skull (Ricochet Skull)
    [123719] = true, -- Ricochet Skull (Ricochet Skull)
    [123728] = true, -- Ricochet Skull (Ricochet Skull)
    [123725] = true, -- Ricochet Skull (Ricochet Skull)

    [123729] = true, -- Ricochet Skull (Ricochet Skull)
    [123727] = true, -- Ricochet Skull (Ricochet Skull)
    [123722] = true, -- Ricochet Skull (Ricochet Skull)

    [114860] = true, -- Blastbones (Blastbones)
    [117330] = true, -- Blastbones (Blastbones)
    [114873] = true, -- Blastbones Spawn Stun (Blastbones)
    [116149] = true, -- Blastbones Model FX (Blastbones)
    [114861] = true, -- Blastbones (Blastbones)
    [114863] = true, -- Blastbones (Blastbones)
    [115608] = true, -- Blastbones (Blastbones)
    [115605] = true, -- Blastbones (Blastbones)
    [124849] = true, -- Blastbones ActionList (Blastbones)

    [117690] = true, -- Blighted Blastbones (Blighted Blastones)
    [117693] = true, -- Blighted Blastbones (Blighted Blastones)
    [117717] = true, -- Blighted Blastbones Spawn Stun (Blighted Blastbones)
    [117718] = true, -- Blighted Blastbones Model FX (Blighted Blastbones)
    [117692] = true, -- Blighted Blastbones (Blighted Blastones)
    [117691] = true, -- Blighted Blastbones (Blighted Blastones)
    [117715] = true, -- Blighted Blastbones (Blighted Blastones)
    [117714] = true, -- Blighted Blastbones (Blighted Blastones)
    [117727] = true, -- Major Defile (Blighted Blastbones)
    [124851] = true, -- Blighted Blastbones ActionList (Blighted Blastbones)
    [117719] = true, -- Blighted Blastbones Leap (Blighted Blastbones)

    [117749] = true, -- Stalking Blastbones (Stalking Blastbones)
    [117773] = true, -- Relentless Blastbones (Stalking Blastbones)
    [117758] = true, -- Stalking Blastbones Spawn St (Stalking Blastbones)
    [117759] = true, -- Stalking Blastbones Model FX (Stalking Blastbones)
    [117751] = true, -- Stalking Blastbones (Stalking Blastbones)
    [117750] = true, -- Stalking Blastbones (Stalking Blastbones)
    [124626] = true, -- Stalking Blastbones (Stalking Blastbones)
    [124627] = true, -- Stalking Blastbones (Stalking Blastbones)
    [117757] = true, -- Stalking Blastbones (Stalking Blastbones)
    [117756] = true, -- Stalking Blastbones (Stalking Blastbones)
    [124853] = true, -- Stalking Blastbones ActionList (Stalking Blastbones)
    [117760] = true, -- Stalking Blastbones Leap (Stalking Blastbones)

    [115567] = true, -- Grave Robber (Boneyard - Grave Robber Synergy)
    [115571] = true, -- Grave Robber (Boneyard - Grave Robber Synergy)
    [115572] = true, -- Grave Robber (Boneyard - Grave Robber Synergy)
    [115573] = true, -- Grave Robber (Boneyard - Grave Robber Synergy)
    [115548] = true, -- Grave Robber (Boneyard - Grave Robber Synergy)

    [115252] = true, -- Boneyard (Boneyard)
    [115255] = true, -- Boneyard (Boneyard)
    [115279] = true, -- Boneyard (Boneyard)
    [117089] = true, -- Boneyard (Boneyard)
    [115254] = true, -- Boneyard (Boneyard)
    [115544] = true, -- Boneyard (Boneyard)

    [117805] = true, -- Unnerving Boneyard (Unnerving Boneyard)
    [117807] = true, -- Unnerving Boneyard (Unnerving Boneyard)
    [117808] = true, -- Unnerving Boneyard (Unnerving Boneyard)
    [117810] = true, -- Unnerving Boneyard (Unnerving Boneyard)
    [117809] = true, -- Unnerving Boneyard (Unnerving Boneyard)
    [117818] = true, -- Major Breach (Unnerving Boneyard)
    [117815] = true, -- Unnerving Boneyard (Unnerving Boneyard)

    [117850] = true, -- Avid Boneyard (Avid Boneyard)
    [117852] = true, -- Avid Boneyard (Avid Boneyard)
    [117853] = true, -- Avid Boneyard (Avid Boneyard)
    [117855] = true, -- Avid Boneyard (Avid Boneyard)
    [117854] = true, -- Avid Boneyard (Avid Boneyard)
    [117860] = true, -- Avid Boneyard (Avid Boneyard)

    [122377] = true, -- Necromancer Pet 12s Tracker (Skeletal Mage - All Morphs)
    [114317] = true, -- Skeletal Mage (Skeletal Mage)
    [114395] = true, -- Skeletal Mage Spawn Stun (Skeletal Mage)
    [114322] = true, -- Skeletal Mage Summon (Skeletal Mage)
    [114461] = true, -- Deathbolt (Skeletal Mage)

    [118680] = true, -- Skeletal Archer (Skeletal Archer)
    [122773] = true, -- Skeletal Archer Spawn Stun (Skeletal Archer)
    [118681] = true, -- Skeletal Archer (Skeletal Archer)
    [122774] = true, -- Deathbolt (Skeletal Archer)
    [122775] = true, -- Skeletal Archer (Skeletal Archer)

    [118726] = true, -- Skeletal Arcanist (Skeletal Arcanist)
    [118744] = true, -- Skeletal Arcanist Spawn Stun (Skeletal Arcanist)
    [118738] = true, -- Exploding Mage (Skeletal Arcanist)
    [118746] = true, -- Deathbolt (Skeletal Arcanist)
    [124468] = true, -- Deathbolt (Skeletal Arcanist)

    [124003] = true, -- Shocking Siphon (Shocking Siphon - All Morphs)
    [115924] = true, -- Shocking Siphon (Shocking Siphon)
    [116445] = true, -- Shocking Siphon (Shocking Siphon)
    [116410] = true, -- Shocking Siphon (Shocking Siphon)

    [118763] = true, -- Detonating Siphon (Detonating Siphon)
    [118764] = true, -- Detonating Siphon (Detonating Siphon)
    [118766] = true, -- Detonating Siphon (Detonating Siphon)
    [123088] = true, -- Detonating Siphon (Detonating Siphon)
    [123082] = true, -- Detonating Siphon (Detonating Siphon)

    [118008] = true, -- Mystic Siphon (Mystic Siphon)
    [118009] = true, -- Mystic Siphon (Mystic Siphon)
    [118011] = true, -- Mystic Siphon (Mystic Siphon)

    [122174] = true, -- Frozen Colossus (Frozen Colossus)
    [122380] = true, -- Frozen Colossus (Frozen Colossus)
    [122184] = true, -- Frozen Colossus (Frozen Colossus)
    [122178] = true, -- Frozen Colossus (Frozen Colossus)
    [122177] = true, -- Major Vulnerability (Frozen Colossus)

    [122395] = true, -- Pestilent Colossus (Pestilent Colossus)
    [122398] = true, -- Pestilent Colossus (Pestilent Colossus)
    [122396] = true, -- Pestilent Colossus (Pestilent Colossus)
    [122399] = true, -- Pestilent Colossus (Pestilent Colossus)
    [122400] = true, -- Pestilent Colossus (Pestilent Colossus)
    [122401] = true, -- Pestilent Colossus (Pestilent Colossus)
    [122397] = true, -- Major Vulnerability (Pestilent Colossus)

    [122388] = true, -- Glacial Colossus (Glacial Colossus)
    [122391] = true, -- Glacial Colossus (Glacial Colossus)
    [122390] = true, -- Glacial Colossus (Glacial Colossus)
    [122392] = true, -- Glacial Colossus (Glacial Colossus)
    [122389] = true, -- Major Vulnerability (Glacial Colossus)
    [122394] = true, -- Glacial Colossus (Glacial Colossus)

    [115115] = true, -- Death Scythe (Death Scythe)
    [122595] = true, -- Death Scythe (Death Scythe)
    [115130] = true, -- Death Scythe (Death Scythe)

    [118226] = true, -- Ruinous Scythe (Ruinous Scythe)
    [122651] = true, -- Ruinous Scythe (Ruinous Scythe)
    [118227] = true, -- Ruinous Scythe (Ruinous Scythe)
    [125750] = true, -- Off Balance (Ruinous Scythe)

    [118223] = true, -- Hungry Scythe (Hungry Scythe)
    [122615] = true, -- Hungry Scythe (Hungry Scythe)
    [118224] = true, -- Hungry Scythe (Hungry Scythe)
    [122625] = true, -- Hungry Scythe (Hungry Scythe)

    [115206] = true, -- Bone Armor (Bone Armor)
    [123903] = true, -- Bone Armor (Bone Armor)
    [115211] = true, -- Major Resolve (Bone Armor)
    [122661] = true, -- Corpse Spawn (Bone Armor)
    [123911] = true, -- Bone Armor (Bone Armor)

    [118237] = true, -- Beckoning Armor (Beckoning Armor)
    [123927] = true, -- Beckoning Armor (Beckoning Armor)
    [118239] = true, -- Major Resolve (Beckoning Armor)
    [122679] = true, -- Corpse Spawn (Beckoning Armor)
    [123929] = true, -- Bone Armor (Beckoning Armor)
    [118241] = true, -- Beckoning Armor (Beckoning Armor)
    [118238] = true, -- Beckoning Armor (Beckoning Armor)
    [118242] = true, -- Beckoning Armor (Beckoning Armor)

    [118244] = true, -- Summoner's Armor (Summoner's Armor)
    [123964] = true, -- Summoner's Armor (Summoner's Armor)
    [118246] = true, -- Major Resolve (Summoner's Armor)
    [122680] = true, -- Corpse Spawn (Summoner's Armor)
    [123965] = true, -- Bone Armor (Summoner's Armor)

    [124006] = true, -- Bitter Harvest (Bitter Harvest - All Morphs)
    [115238] = true, -- Bitter Harvest (Bitter Harvest)
    [119372] = true, -- Bitter Harvest (Bitter Harvest)
    [115244] = true, -- Bitter Harvest (Bitter Harvest)
    [124136] = true, -- Necrotic Potency (Bitter Harvest)
    [115240] = true, -- Bitter Harvest (Bitter Harvest)

    [118623] = true, -- Dead Pain (Deaden Pain)
    [121796] = true, -- Dead Pain (Deaden Pain)
    [118624] = true, -- Dead Pain (Deaden Pain)
    [124166] = true, -- Necrotic Potency (Deaden Pain)
    [124165] = true, -- Dead Pain (Deaden Pain)
    [118629] = true, -- Major Protection (Deaden Pain)

    [118639] = true, -- Necrotic Potency (Necrotic Potency)
    [121797] = true, -- Necrotic Potency (Necrotic Potency)
    [118640] = true, -- Necrotic Potency (Necrotic Potency)
    [124192] = true, -- Necrotic Potency (Necrotic Potency)
    [124193] = true, -- Necrotic Potency (Necrotic Potency)

    [115093] = true, -- Bone Totem (Bone Totem)
    [115095] = true, -- Bone Totem (Bone Totem)
    [115097] = true, -- Minor Protection (Bone Totem)
    [115107] = true, -- Bone Totem (Bone Totem)
    [115106] = true, -- Bone Totem (Bone Totem)

    [118380] = true, -- Remote Totem (Remote Totem)
    [118381] = true, -- Remote Totem (Remote Totem)
    [118385] = true, -- Minor Protection (Remote Totem)
    [118383] = true, -- Remote Totem (Remote Totem)
    [118386] = true, -- Remote Totem (Remote Totem)

    [118610] = true, -- Pure Agony (Agony Totem - Pure Agony Synergy)
    [118606] = true, -- Pure Agony (Agony Totem - Pure Agony Synergy)
    [118613] = true, -- Minor Vulnerability (Agony Totem - Pure Agony Synergy)
    [118618] = true, -- Pure Agony (Agony Totem - Pure Agony Synergy)

    [118404] = true, -- Agony Totem (Agony Totem)
    [118405] = true, -- Agony Totem (Agony Totem)
    [118409] = true, -- Minor Protection (Agony Totem)
    [118407] = true, -- Agony Totem (Agony Totem)
    [118411] = true, -- Agony Totem (Agony Totem)
    [118614] = true, -- Agony Totem (Agony Totem)

    [115177] = true, -- Grave Grasp (Grave Grasp)
    [121515] = true, -- Grave Grasp (Grave Grasp)
    [121514] = true, -- Grave Grasp (Grave Grasp)
    [121516] = true, -- Grave Grasp (Grave Grasp)
    [121518] = true, -- Grave Grasp (Grave Grasp)
    [121513] = true, -- Grave Grasp (Grave Grasp)
    [121517] = true, -- Minor Maim (Grave Grasp)
    [143916] = true, -- Grave Grasp (Grave Grasp)
    [143915] = true, -- Grave Grasp (Grave Grasp)
    [143918] = true, -- Grave Grasp (Grave Grasp)
    [143917] = true, -- Grave Grasp (Grave Grasp)

    [118308] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118311] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118310] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118312] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118314] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118309] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118313] = true, -- Minor Maim (Ghostly Embrace)
    [143944] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118325] = true, -- Ghostly Embrace (Ghostly Embrace)
    [143946] = true, -- Ghostly Embrace (Ghostly Embrace)
    [143945] = true, -- Ghostly Embrace (Ghostly Embrace)

    [118352] = true, -- Empowering Grasp (Empowering Grasp)
    [118356] = true, -- Empowering Grasp (Empowering Grasp)
    [118355] = true, -- Empowering Grasp (Empowering Grasp)
    [118357] = true, -- Empowering Grasp (Empowering Grasp)
    [118359] = true, -- Empowering Grasp (Empowering Grasp)
    [118366] = true, -- Empower (Empowering Grasp)
    [118369] = true, -- Empowering Grasp (Empowering Grasp)
    [124816] = true, -- Empowering Grasp (Empowering Grasp)
    [118354] = true, -- Empowering Grasp (Empowering Grasp)
    [118358] = true, -- Minor Maim (Empowering Grasp)
    [143950] = true, -- Empowering Grasp (Empowering Grasp)
    [143948] = true, -- Empowering Grasp (Empowering Grasp)
    [143951] = true, -- Empowering Grasp (Empowering Grasp)
    [143949] = true, -- Empowering Grasp (Empowering Grasp)

    [118802] = true, -- Bone Goliath Transform Setup (Bone Goliath Transformation - All Morphs)
    [123228] = true, -- De-Bone (Bone Goliath Transformation - All Morphs)
    [115001] = true, -- Bone Goliath Transformation (Bone Goliath Transformation)
    [115286] = true, -- Bone Goliath (Bone Goliath Transformation)
    [115478] = true, -- Bone Goliath Self Snare (Bone Goliath Transformation)
    [115257] = true, -- Bone Goliath (Bone Goliath Transformation)
    [115281] = true, -- Bone Goliath (Bone Goliath Transformation)
    [115282] = true, -- Bone Goliath (Bone Goliath Transformation)

    [118664] = true, -- Pummeling Goliath (Pummeling Goliath)
    [118665] = true, -- Pummeling Goliath (Pummeling Goliath)
    [118673] = true, -- Pummeling Goliath Self Snare (Pummeling Goliath)
    [118672] = true, -- Pummeling Goliath (Pummeling Goliath)
    [118666] = true, -- Pummeling Goliath (Pummeling Goliath)
    [118667] = true, -- Pummeling Goliath (Pummeling Goliath)
    [118720] = true, -- Pummeling Goliath Bash (Pummeling Goliath)

    [118279] = true, -- Ravenous Goliath (Ravenous Goliath)
    [118280] = true, -- Ravenous Goliath (Ravenous Goliath)
    [118287] = true, -- Ravenous Goliath Self Snare (Ravenous Goliath)
    [118288] = true, -- Ravenous Goliath (Ravenous Goliath)
    [118290] = true, -- Ravenous Goliath (Ravenous Goliath)
    [118281] = true, -- Ravenous Goliath (Ravenous Goliath)
    [118282] = true, -- Ravenous Goliath (Ravenous Goliath)
    [118289] = true, -- Ravenous Goliath (Ravenous Goliath)
    [118292] = true, -- Ravenous Goliath (Ravenous Goliath)

    [114196] = true, -- Render Flesh (Render Flesh)
    [114206] = true, -- Minor Defile (Render Flesh)

    [117883] = true, -- Resistant Flesh (Resistant Flesh)
    [117885] = true, -- Minor Defile (Resistant Flesh)
    [117886] = true, -- Resistant Flesh (Resistant Flesh)

    [117888] = true, -- Blood Sacrifice (Blood Sacrifice)
    [117890] = true, -- Minor Defile (Blood Sacrifice)
    [117897] = true, -- Blood Sacrifice (Blood Sacrifice)
    [117894] = true, -- Blood Sacrifice (Blood Sacrifice)

    [124005] = true, -- Expunge (Expunge - All Morphs)
    [115307] = true, -- Expunge (Expunge)

    [117940] = true, -- Expunge and Modify (Expunge and Modify)
    [117947] = true, -- Expunge and Modify (Expunge and Modify)
    [117941] = true, -- Expunge and Modify (Expunge and Modify)
    [117942] = true, -- Expunge and Modify (Expunge and Modify)

    [117919] = true, -- Hexproof (Hexproof)

    [115315] = true, -- Life amid Death (Life amid Death)
    [115318] = true, -- Life amid Death (Life amid Death)
    [115326] = true, -- Life amid Death (Life amid Death)
    [115532] = true, -- Life amid Death (Life amid Death)
    [115385] = true, -- Life amid Death (Life amid Death)

    [118017] = true, -- Renewing Undeath (Renewing Undeath)
    [118019] = true, -- Renewing Undeath (Renewing Undeath)
    [118022] = true, -- Renewing Undeath (Renewing Undeath)
    [118018] = true, -- Renewing Undeath (Renewing Undeath)
    [118021] = true, -- Renewing Undeath (Renewing Undeath)

    [118809] = true, -- Enduring Undeath (Enduring Undeath)
    [118811] = true, -- Enduring Undeath (Enduring Undeath)
    [118817] = true, -- Enduring Undeath (Enduring Undeath)
    [118814] = true, -- Enduring Undeath (Enduring Undeath)
    [118810] = true, -- Enduring Undeath (Enduring Undeath)
    [118813] = true, -- Enduring Undeath (Enduring Undeath)

    [115710] = true, -- Spirit Mender (Spirit Mender)
    [115720] = true, -- Spirit Mender Spawn Stun (Spirit Mender)
    [115732] = true, -- Spirit Mender (Spirit Mender)
    [115721] = true, -- Reconstitute (Spirit Mender)

    [118912] = true, -- Spirit Guardian (Spirit Guardian)
    [118915] = true, -- Spirit Guardian Spawn Stun (Spirit Guardian)
    [118916] = true, -- Spirit Guardian (Spirit Guardian)
    [118913] = true, -- Spirit Guardian (Spirit Guardian)
    [118914] = true, -- Reconstitute (Spirit Guardian)

    [118840] = true, -- Intensive Mender (Intensive Mender)
    [118852] = true, -- Intensive Mender Spawn Stun (Intensive Mender)
    [122379] = true, -- Necromancer Pet 6s Tracker (Intensive Mender)
    [118843] = true, -- Intensive Mender (Intensive Mender)
    [118851] = true, -- Reconstitute (Intensive Mender)

    [124004] = true, -- Restoring Tether (Restoring Tether - All Morphs)

    [115926] = true, -- Restoring Tether (Restoring Tether)
    [116450] = true, -- Restoring Tether (Restoring Tether)
    [116442] = true, -- Restoring Tether (Restoring Tether)
    [117871] = true, -- Restoring Tether (Restoring Tether)

    [118070] = true, -- Braided Tether (Braided Tether)
    [118071] = true, -- Braided Tether (Braided Tether)
    [118073] = true, -- Braided Tether (Braided Tether)

    [118122] = true, -- Mortal Coil (Mortal Coil)
    [118123] = true, -- Mortal Coil (Mortal Coil)
    [118125] = true, -- Mortal Coil (Mortal Coil)
    [118126] = true, -- Mortal Coil (Mortal Coil)
    [123233] = true, -- Mortal Coil (Mortal Coil)

    [115410] = true, -- Reanimate (Reanimate)
    [115429] = true, -- Reanimate (Reanimate)

    [118367] = true, -- Renewing Animation (Renewing Animation)
    [118378] = true, -- Renewing Animation (Renewing Animation)
    [118376] = true, -- Renewing Animation (Renewing Animation)
    [118377] = true, -- Renewing Animation (Renewing Animation)

    [118379] = true, -- Animate Blastbones (Animate Blastbones)
    [118391] = true, -- Animate Blastbones (Animate Blastbones)
    [118447] = true, -- Animate Blastbones (Animate Blastbones)
    [118397] = true, -- Animate Blastbones (Animate Blastbones)
    [118448] = true, -- Animate Blastbones (Animate Blastbones)
    [118450] = true, -- Animate Blastbones (Animate Blastbones)
    [124999] = true, -- Undead Confederate Tracker (Animate Blastbones)

    -------------------------------------
    -- UNARMED PASSIVES -----------------
    -------------------------------------

    [23604] = true, -- Light Attack (Unarmed)
    [18429] = true, -- Heavy Attack (Unarmed)
    [18430] = true, -- Heavy Attack (Unarmed)
    [21991] = true, -- Heavy Attack Damage Bonus
    [18431] = true, -- Heavy Attack (Unarmed)
    [60772] = true, -- Heavy Attack (Unarmed)

    -------------------------------------
    -- TWO HANDED PASSIVES --------------
    -------------------------------------

    [16037] = true, -- Light Attack (Two Handed)
    [16041] = true, -- Heavy Attack (Two Handed)
    [17162] = true, -- Heavy Attack (Two Handed)
    [17699] = true, -- Heavy Attack Damage Bonus
    [17163] = true, -- Heavy Attack (Two Handed)
    [60757] = true, -- Heavy Attack (Two Handed)

    [29387] = true, -- Forceful (Rank 1)
    [30821] = true, -- Forceful
    [45444] = true, -- Forceful (Rank 2)
    [45445] = true, -- Forceful

    [29375] = true, -- Heavy Weapons (Rank 1)
    [45430] = true, -- Heavy Weapons (Rank 2)

    [29388] = true, -- Balanced Blade (Rank 1)
    [45443] = true, -- Balanced Blade (Rank 2)

    [29389] = true, -- Follow Up (Rank 1)
    [60860] = true, -- Bonus Damage
    [45446] = true, -- Follow Up (Rank 2)
    [60888] = true, -- Bonus Damage

    [29391] = true, -- Battle Rush (Rank 1)
    [29392] = true, -- Battle Rush
    [45448] = true, -- Battle Rush (Rank 2)
    [45450] = true, -- Battle Rush

    -------------------------------------
    -- TWO HANDED ACTIVES ---------------
    -------------------------------------

    [28279] = true,  -- Uppercut (Uppercut)

    [38814] = true,  -- Dizzying Swing (Dizzying Swing)
    [131562] = true, -- Off Balance (Dizzying Swing)
    [137807] = true, -- Dizzying Swing (Dizzying Swing)

    [38807] = true,  -- Wrecking Blow (Wrecking Blow)
    [147423] = true, -- Empower (Wrecking Blow)

    [28448] = true,  -- Critical Charge (Critical Charge)
    [28450] = true,  -- Critical Strike (Critical Charge)
    [28449] = true,  -- Critical Charge (Critical Charge)

    [38788] = true,  -- Stampede (Stampede)
    [38789] = true,  -- Critical Strike (Stampede)
    [38792] = true,  -- Stampede (Stampede)
    [38791] = true,  -- Stampede (Stampede)
    [126475] = true, -- Stampede (Stampede)
    [126474] = true, -- Stampede (Stampede)

    [38778] = true,  -- Critical Rush (Critical Rush)
    [38781] = true,  -- Critical Strike (Critical Rush)
    [38783] = true,  -- Damage Bonus (Critical Rush)
    [38782] = true,  -- Critical Rush (Critical Rush)

    [20919] = true,  -- Cleave (Cleave)

    [38745] = true,  -- Carve (Carve)
    [38747] = true,  -- Carve Bleed (Carve)

    [38754] = true,  -- Brawler (Brawler)
    [38773] = true,  -- Brawler (Brawler)
    [38774] = true,  -- Brawler (Brawler)
    [38763] = true,  -- Brawler (Brawler)

    [28302] = true,  -- Reverse Slash (Reverse Slash)

    [38823] = true,  -- Reverse Slice (Reverse Slice)
    [38827] = true,  -- Reverse Slice (Reverse Slice)

    [38819] = true,  -- Executioner (Executioner)

    [28297] = true,  -- Momentum (Momentum)
    [61670] = true,  -- Major Brutality (Momentum)
    [126527] = true, -- Minor Endurance (Momentum)

    [38794] = true,  -- Forward Momentum (Forward Momentum)
    [62387] = true,  -- Major Brutality (Forward Momentum)
    [126534] = true, -- Minor Endurance (Forward Momentum)
    [38797] = true,  -- Forward Momentum (Forward Momentum)

    [38802] = true,  -- Rally (Rally)
    [62415] = true,  -- Major Brutality (Rally)
    [126537] = true, -- Minor Endurance (Rally)
    [60895] = true,  -- Heal Buff (Rally)
    [38805] = true,  -- Rally (Rally)
    [157657] = true, -- Rally (Rally)

    [83216] = true,  -- Berserker Strike (Berserker Strike)
    [126489] = true, -- Berserker Strike (Berserker Strike)
    [83217] = true,  -- Berserker Strike (Berserker Strike)
    [83221] = true,  -- Berserker Strike (Berserker Strike)

    [83229] = true,  -- Onslaught (Onslaught)
    [126497] = true, -- Onslaught (Onslaught)
    [83230] = true,  -- Onslaught (Onslaught)
    [83231] = true,  -- Onslaught (Onslaught)

    [83238] = true,  -- Berserker Rage (Berserker Rage)
    [126492] = true, -- Berserker Rage (Berserker Rage)
    [83239] = true,  -- Berserker Rage (Berserker Rage)
    [83240] = true,  -- Berserker Rage (Berserker Rage)
    [83241] = true,  -- Berserker Rage (Berserker Rage)

    -------------------------------------
    -- ONE HAND AND SHIELD PASSIVES -----
    -------------------------------------

    [15435] = true, -- Light Attack (One Handed)
    [15279] = true, -- Heavy Attack (One Handed)
    [15282] = true, -- Heavy Attack (One Handed)
    [17694] = true, -- Heavy Attack Damage Bonus
    [15829] = true, -- Heavy Attack (One Handed)
    [60759] = true, -- Heavy Attack (One Handed)

    [29420] = true, -- Fortress (Rank 1)
    [45471] = true, -- Fortress (Rank 2)

    [29397] = true, -- Sword and Board (Rank 1)
    [45452] = true, -- Sword and Board (Rank 2)

    [29415] = true, -- Deadly Bash (Rank 1)
    [45469] = true, -- Deadly Bash (Rank 2)

    [29399] = true, -- Deflect Bolts (Rank 1)
    [45472] = true, -- Deflect Bolts (Rank 2)

    [29422] = true, -- Battlefield Mobility (Rank 1)
    [45473] = true, -- Battlefield Mobility (Rank 2)

    -------------------------------------
    -- ONE HAND AND SHIELD ACTIVES ------
    -------------------------------------

    [28306] = true,  -- Puncture (Puncture)
    [28307] = true,  -- Major Breach (Puncture)

    [38256] = true,  -- Ransack (Ransack)
    [62474] = true,  -- Major Breach (Ransack)
    [62475] = true,  -- Minor Protection (Ransack)

    [38250] = true,  -- Pierce Armor (Pierce Armor)
    [62485] = true,  -- Major Breach (Pierce Armor)
    [146908] = true, -- Minor Breach (Pierce Armor)

    [28304] = true,  -- Low Slash (Low Slash)
    [29308] = true,  -- Minor Maim (Low Slash)

    [38268] = true,  -- Deep Slash (Deep Slash)
    [62495] = true,  -- Minor Maim (Deep Slash)
    [38271] = true,  -- Deep Slash (Deep Slash)

    [38264] = true,  -- Heroic Slash (Heroic Slash)
    [62504] = true,  -- Minor Maim (Heroic Slash)
    [62505] = true,  -- Minor Heroism (Heroic Slash)

    [28727] = true,  -- Defensive Posture (Defensive Posture)
    [126604] = true, -- Defensive Posture (Defensive Posture)

    [41347] = true,  -- Defensive Stance (Defensive Stance)
    [38312] = true,  -- Defensive Stance (Defensive Stance)
    [126608] = true, -- Defensive Stance (Defensive Stance)

    [38317] = true,  -- Absorb Missile (Absorb Missile)
    [38324] = true,  -- Absorb Missile (Absorb Missile)
    [38398] = true,  -- Absorb Missile (Absorb Missile)

    [28719] = true,  -- Shield Charge (Shield Charge)
    [28721] = true,  -- Shield Charge (Shield Charge)
    [28720] = true,  -- Shield Charge (Shield Charge)

    [38401] = true,  -- Shielded Assault (Shielded Assault)
    [38404] = true,  -- Shielded Assault (Shielded Assault)
    [38402] = true,  -- Shielded Assault (Shielded Assault)
    [38403] = true,  -- Shielded Assault (Shielded Assault)

    [38405] = true,  -- Invasion (Invasion)
    [38408] = true,  -- Invasion (Invasion)
    [38406] = true,  -- Invasion (Invasion)
    [38407] = true,  -- Invasion Stun (Invasion)

    [28365] = true,  -- Power Bash (Power Bash)

    [38455] = true,  -- Reverberating Bash (Reverberating Bash)
    [83446] = true,  -- Reverberating Bash (Reverberating Bash)
    [125947] = true, -- Reverberating Bash (Reverberating Bash)

    [80624] = true,  -- Resentment (Power Slam)
    [80625] = true,  -- Resentment (Power Slam)
    [38452] = true,  -- Power Slam (Power Slam)

    [83272] = true,  -- Shield Wall (Shield Wall)

    [83292] = true,  -- Spell Wall (Spell Wall)
    [83301] = true,  -- Spell Wall (Spell Wall)

    [83310] = true,  -- Shield Discipline (Shield Discipline)

    -------------------------------------
    -- DUAL WIELD PASSIVES --------------
    -------------------------------------

    [16499] = true, -- Light Attack (Dual Wield)
    [16420] = true, -- Heavy Attack (Dual Wield)
    [17170] = true, -- Heavy Attack (Dual Wield)
    [17700] = true, -- Heavy Attack Damage Bonus
    [17169] = true, -- Heavy Attack (Dual Wield)
    [18622] = true, -- Heavy Attack (Dual Wield)
    [60758] = true, -- Heavy Attack (Dual Wield)
    [64546] = true, -- Heavy Attack Damage Bonus

    [18929] = true, -- Slaughter (Rank 1)
    [45476] = true, -- Slaughter (Rank 2)

    [30873] = true, -- Dual Wield Expert (Rank 1)
    [45477] = true, -- Dual Wield Expert (Rank 2)

    [30872] = true, -- Controlled Fury (Rank 1)
    [45478] = true, -- Controlled Fury (Rank 2)

    [21114] = true, -- Ruffian (Rank 1)
    [45481] = true, -- Ruffian (Rank 2)

    [30893] = true, -- Twin Blade and Blunt (Rank 1)
    [45482] = true, -- Twin Blade and Blunt (Rank 2)

    -------------------------------------
    -- DUAL WIELD ACTIVES ---------------
    -------------------------------------

    [28607] = true,  -- Flurry (Flurry)
    [81355] = true,  -- Flurry (Flurry)
    [29227] = true,  -- Flurry (Flurry)

    [38857] = true,  -- Rapid Strikes (Rapid Strikes)
    [38860] = true,  -- Rapid Strikes (Rapid Strikes)
    [81368] = true,  -- Rapid Strikes (Rapid Strikes)
    [38859] = true,  -- Rapid Strikes (Rapid Strikes)

    [38846] = true,  -- Bloodthirst (Bloodthirst)
    [81378] = true,  -- Bloodthirst (Bloodthirst)
    [38853] = true,  -- Bloodthirst (Bloodthirst)
    [81381] = true,  -- Bloodthirst (Bloodthirst)

    [28379] = true,  -- Twin Slashes (Twin Slashes)
    [35312] = true,  -- Twin Slashes (Twin Slashes)
    [29293] = true,  -- Twin Slashes (Twin Slashes)

    [38839] = true,  -- Rending Slashes (Rending Slashes)
    [38840] = true,  -- Rending Slashes (Rending Slashes)
    [38841] = true,  -- Rending Slashes (Rending Slashes)
    [38842] = true,  -- Rending Slashes (Rending Slashes)

    [38845] = true,  -- Blood Craze (Blood Craze)
    [38847] = true,  -- Blood Craze (Blood Craze)
    [38848] = true,  -- Blood Craze (Blood Craze)
    [38852] = true,  -- Blood Craze (Blood Craze)

    [28591] = true,  -- Whirlwind (Whirlwind)
    [39620] = true,  -- Whirlwind (Whirlwind)

    [38891] = true,  -- Whirling Blades (Whirling Blades)
    [39666] = true,  -- Whirlwind (Whirling Blades)

    [38861] = true,  -- Steel Tornado (Steel Tornado)
    [39665] = true,  -- Whirlwind (Steel Tornado)

    [64746] = true,  -- Blade Cloak AoE Fx (Blade Cloak)
    [28613] = true,  -- Blade Cloak (Blade Cloak)
    [62522] = true,  -- Blade Cloak (Blade Cloak)
    [123651] = true, -- Major Evasion (Blade Cloak)

    [38901] = true,  -- Quick Cloak (Quick Cloak)
    [62531] = true,  -- Major Expedition (Quick Cloak)
    [62529] = true,  -- Blade Cloak (Quick Cloak)
    [123652] = true, -- Major Evasion (Quick Cloak)

    [38906] = true,  -- Deadly Cloak (Deadly Cloak)
    [62547] = true,  -- Blade Cloak (Deadly Cloak)
    [123653] = true, -- Major Evasion (Deadly Cloak)

    [21157] = true,  -- Hidden Blade (Hidden Blade)
    [68807] = true,  -- Major Brutality (Hidden Blade)
    [126641] = true, -- Hidden Blade (Hidden Blade)
    [126640] = true, -- Stagger (Hidden Blade)
    [126639] = true, -- Hidden Blade (Hidden Blade)

    [38914] = true,  -- Shrouded Daggers (Shrouded Daggers)
    [126647] = true, -- Major Brutality (Shrouded Daggers)
    [68858] = true,  -- Hit Dummy (Shrouded Daggers)
    [68860] = true,  -- Bounce 1 (Shrouded Daggers)
    [68862] = true,  -- Shrouded Daggers (Shrouded Daggers)
    [68863] = true,  -- Bounce 2 (Shrouded Daggers)
    [68864] = true,  -- Shrouded Daggers (Shrouded Daggers)
    [126649] = true, -- Shrouded Dagger (Shrouded Daggers)
    [126650] = true, -- Stagger (Shrouded Daggers)
    [126651] = true, -- Shrouded Dagger (Shrouded Daggers)

    [38910] = true,  -- Flying Blade (Flying Blade)
    [126667] = true, -- Flying Blade (Flying Blade)
    [126659] = true, -- Flying Blade (Flying Blade)
    [126666] = true, -- Flying Blade (Flying Blade)
    [126670] = true, -- Major Brutality (Flying Blade)
    [126658] = true, -- Flying Blade (Flying Blade)
    [126655] = true, -- Stagger (Flying Blade)
    [126654] = true, -- Flying Blade (Flying Blade)

    [83600] = true,  -- Lacerate (Lacerate)
    [85156] = true,  -- Lacerate (Lacerate)
    [85171] = true,  -- Lacerate (Lacerate)

    [85187] = true,  -- Rend (Rend)
    [85192] = true,  -- Rend (Rend)
    [85190] = true,  -- Rend (Rend)

    [85179] = true,  -- Thrive in Chaos (Thrive in Chaos)
    [85182] = true,  -- Thrive in Chaos (Thrive in Chaos)
    [85184] = true,  -- Thrive in Chaos (Thrive in Chaos)
    [85180] = true,  -- Thrive in Chaos (Thrive in Chaos)

    -------------------------------------
    -- BOW PASSIVES ---------------------
    -------------------------------------

    [16688] = true, -- Light Attack (Bow)
    [16691] = true, -- Heavy Attack (Bow)
    [17174] = true, -- Heavy Attack (Bow)
    [17701] = true, -- Heavy Attack Damage Bonus
    [17173] = true, -- Heavy Attack (Bow)
    [60761] = true, -- Heavy Attack (Bow)

    [30937] = true, -- Long Shots (Rank 1)
    [45494] = true, -- Long Shots (Rank 2)

    [30930] = true, -- Accuracy (Rank 1)
    [45492] = true, -- Accuracy (Rank 2)

    [30942] = true, -- Ranger (Rank 1)
    [45493] = true, -- Ranger (Rank 2)

    [30936] = true, -- Hawk Eye (Rank 1)
    [78854] = true, -- Hawk Eye
    [45497] = true, -- Hawk Eye (Rank 2)
    [78855] = true, -- Hawk Eye

    [30923] = true, -- Hasty Retreat (Rank 1)
    [98489] = true, -- Major Expedition
    [45498] = true, -- Hasty Retreat (Rank 2)
    [98490] = true, -- Major Expedition

    -------------------------------------
    -- BOW ACTIVES ----------------------
    -------------------------------------

    [28882] = true,  -- Snipe (Snipe)

    [38685] = true,  -- Lethal Arrow (Lethal Arrow)
    [38686] = true,  -- Major Defile (Lethal Arrow)

    [38687] = true,  -- Focused Aim (Focused Aim)
    [38688] = true,  -- Minor Breach (Focused Aim)

    [28876] = true,  -- Volley (Volley)
    [38424] = true,  -- Summon Shade (Volley)
    [28877] = true,  -- Volley (Volley)

    [38689] = true,  -- Endless Hail (Endless Hail)
    [38691] = true,  -- Summon Shade (Endless Hail)
    [38690] = true,  -- Endless Hail (Endless Hail)

    [38695] = true,  -- Arrow Barrage (Arrow Barrage)
    [38697] = true,  -- Summon Shade (Arrow Barrage)
    [38696] = true,  -- Arrow Barrage (Arrow Barrage)

    [28879] = true,  -- Scatter Shot (Scatter Shot)
    [28888] = true,  -- Scatter Shot (Scatter Shot)
    [28887] = true,  -- Scatter Shot (Scatter Shot)

    [38672] = true,  -- Magnum Shot (Magnum Shot)
    [38675] = true,  -- Scatter Shot (Magnum Shot)
    [38674] = true,  -- Scatter Shot (Magnum Shot)

    [38669] = true,  -- Draining Shot (Draining Shot)
    [131688] = true, -- Draining Shot (Draining Shot)
    [80767] = true,  -- Draining Shot (Draining Shot)
    [80764] = true,  -- Draining Shot Heal (Draining Shot)

    [31271] = true,  -- Arrow Spray (Arrow Spray)
    [38722] = true,  -- Arrow Spray (Arrow Spray)

    [38705] = true,  -- Bombard (Bombard)
    [38723] = true,  -- Bombard (Bombard)
    [38707] = true,  -- Bombard (Bombard)

    [38701] = true,  -- Acid Spray (Acid Spray)
    [38724] = true,  -- Acid Spray (Acid Spray)
    [38703] = true,  -- Acid Spray (Acid Spray)

    [28869] = true,  -- Poison Arrow (Poison Arrow)
    [44540] = true,  -- Poison Arrow (Poison Arrow)

    [38645] = true,  -- Venom Arrow (Venom Arrow)
    [44545] = true,  -- Venom Arrow (Venom Arrow)
    [38648] = true,  -- Poison Arrow (Venom Arrow)
    [38649] = true,  -- Poison Arrow (Venom Arrow)
    [38650] = true,  -- Poison Arrow (Venom Arrow)

    [38660] = true,  -- Poison Injection (Poison Injection)
    [44549] = true,  -- Poison Injection (Poison Injection)

    [55131] = true,  -- Rapid Fire (Rapid Fire - All Morphs)
    [83465] = true,  -- Rapid Fire (Rapid Fire)
    [86563] = true,  -- Rapid Fire (Rapid Fire)

    [85257] = true,  -- Toxic Barrage (Toxic Barrage)
    [85260] = true,  -- Toxic Barrage (Toxic Barrage)
    [85261] = true,  -- Toxic Barrage (Toxic Barrage)

    [85451] = true,  -- Ballista (Ballista)
    [85458] = true,  -- Ballista (Ballista)
    [85462] = true,  -- Ballista (Ballista)

    -------------------------------------
    -- DESTRUCTION STAFF PASSIVES -------
    -------------------------------------

    [16277] = true,  -- Light Attack (Ice)
    [16261] = true,  -- Heavy Attack (Ice)
    [18405] = true,  -- Heavy Attack (Ice)
    [18404] = true,  -- Heavy Attack Damage Bonus
    [18406] = true,  -- Heavy Attack (Ice)
    [60762] = true,  -- Heavy Attack (Ice)

    [16165] = true,  -- Light Attack (Inferno)
    [15383] = true,  -- Heavy Attack (Inferno)
    [15385] = true,  -- Heavy Attack (Inferno)
    [23429] = true,  -- Heavy Attack Damage Bonus
    [16321] = true,  -- Heavy Attack (Inferno)
    [60763] = true,  -- Heavy Attack (Inferno)

    [18350] = true,  -- Light Attack (Lightning)
    [18396] = true,  -- Heavy Attack (Lightning)
    [19277] = true,  -- Heavy Attack (Lightning)
    [60764] = true,  -- Heavy Attack (Lightning)

    [30948] = true,  -- Tri Focus -- Rank 1
    [69774] = true,  -- Tri Focus
    [30951] = true,  -- Tri Focus
    [45500] = true,  -- Tri Focus -- Rank 2
    [69773] = true,  -- Tri Focus
    [45505] = true,  -- Tri Focus

    [30957] = true,  -- Penetrating Magic -- Rank 1
    [45509] = true,  -- Penetrating Magic -- Rank 2

    [30962] = true,  -- Elemental Force -- Rank 1
    [45512] = true,  -- Elemental Force -- Rank 2

    [30959] = true,  -- Ancient Knowledge -- Rank 1
    [45513] = true,  -- Ancient Knowledge -- Rank 2

    [30965] = true,  -- Destruction Expert -- Rank 1
    [30966] = true,  -- Destruction Expert
    [146324] = true, -- Magicka Restore
    [45514] = true,  -- Destruction Expert -- Rank 1
    [45515] = true,  -- Magicka Restore
    [146323] = true, -- Magicka Restore

    -------------------------------------
    -- DESTRUCTION STAFF ACTIVES --------
    -------------------------------------

    [46340] = true,  -- Force Shock (Force Shock)
    [46341] = true,  -- Force Shock (Force Shock)
    [46343] = true,  -- Force Shock (Force Shock)

    [46348] = true,  -- Crushing Shock (Crushing Shock)
    [46350] = true,  -- Crushing Shock (Crushing Shock)
    [46351] = true,  -- Crushing Shock (Crushing Shock)
    [48010] = true,  -- Force Shock (Destruction) (Crushing Shock)
    [48009] = true,  -- Stagger(Crushing Shock)
    [48011] = true,  -- Uber Attack (Crushing Shock)

    [46356] = true,  -- Force Pulse (Force Pulse)
    [46357] = true,  -- Force Pulse (Force Pulse)
    [46358] = true,  -- Force Pulse (Force Pulse)
    [48019] = true,  -- Hit Dummy (Force Pulse)
    [48017] = true,  -- Bounce 1 (Force Pulse)
    [48023] = true,  -- Bounce 2 (Force Pulse)
    [48016] = true,  -- Force Pulse (Force Pulse)
    [48022] = true,  -- Force Pulse (Force Pulse)

    [68719] = true,  -- Frozen (Wall of Elements) -- Frost
    [43192] = true,  -- Fire Wall Damage Bonus (Wall of Elements - All Morphs) -- Fire
    [146697] = true, -- Minor Brittle (Wall of Elements) -- Frost

    [28858] = true,  -- Wall of Elements (Wall of Elements)
    [28807] = true,  -- Wall of Fire (Wall of Elements) -- Fire
    [62897] = true,  -- Unstable Wall of Fire (Wall of Elements) -- Fire
    [62895] = true,  -- Unstable Wall of Fire (Wall of Elements) -- Fire
    [62896] = true,  -- Wall of Fire (Wall of Elements) -- Fire
    [28854] = true,  -- Wall of Storms (Wall of Elements) -- Storm
    [62970] = true,  -- Wall of Storms (Wall of Elements) -- Storm
    [62967] = true,  -- Wall of Storms (Wall of Elements) -- Storm
    [62971] = true,  -- Wall of Storms (Wall of Elements) -- Storm
    [62968] = true,  -- Off Balance (Wall of Elements) -- Storm
    [28849] = true,  -- Wall of Frost (Wall of Elements) -- Frost
    [62929] = true,  -- Unstable Wall of Frost (Wall of Elements) -- Frost
    [146029] = true, -- Unstable Wall of Frost (Wall of Elements) -- Frost
    [146169] = true, -- Frost Shield (Wall of Elements) -- Frost
    [62931] = true,  -- Wall of Frost (Wall of Elements) -- Frost

    [39052] = true,  -- Unstable Wall of Elements (Unstable Wall of Elements)
    [39053] = true,  -- Unstable Wall of Fire (Unstable Wall of Elements) -- Fire
    [39057] = true,  -- Unstable Wall of Fire (Unstable Wall of Elements) -- Fire
    [39055] = true,  -- Unstable Wall of Fire (Unstable Wall of Elements) -- Fire
    [114880] = true, -- Summon Shade
    [39054] = true,  -- Unstable Wall of Fire (Unstable Wall of Elements) -- Fire
    [39056] = true,  -- Unstable Wall of Fire (Unstable Wall of Elements) -- Fire
    [39073] = true,  -- Unstable Wall of Storms (Unstable Wall of Elements) -- Shock
    [39081] = true,  -- Unstable Wall of Storms (Unstable Wall of Elements) -- Shock
    [39078] = true,  -- Unstable Wall of Storms (Unstable Wall of Elements) -- Shock
    [114883] = true, -- Summon Shade
    [39079] = true,  -- Unstable Wall of Storms (Unstable Wall of Elements) -- Shock
    [39080] = true,  -- Unstable Wall of Storms (Unstable Wall of Elements) -- Shock
    [39077] = true,  -- Off Balance (Unstable Wall of Elements) -- Shock
    [39067] = true,  -- Unstable Wall of Frost (Unstable Wall of Elements) -- Frost
    [39069] = true,  -- Unstable Wall of Frost (Unstable Wall of Elements) -- Frost
    [39070] = true,  -- Unstable Wall of Frost (Unstable Wall of Elements) -- Frost
    [114886] = true, -- Summon Shade (Unstable Wall of Elements) -- Frost
    [146276] = true, -- Unstable Frost Shield (Unstable Wall of Elements) -- Frost
    [146279] = true, -- Unstable Frost Shield (Unstable Wall of Elements) -- Frost
    [39071] = true,  -- Unstable Wall of Frost (Unstable Wall of Elements) -- Frost
    [39072] = true,  -- Unstable Wall of Frost (Unstable Wall of Elements) -- Frost

    [39011] = true,  -- Elemental Blockade (Elemental Blockade)
    [39012] = true,  -- Blockade of Fire (Elemental Blockade) -- Fire
    [62913] = true,  -- Unstable Wall of Fire (Elemental Blockade) -- Fire
    [62911] = true,  -- Unstable Wall of Fire (Elemental Blockade) -- Fire
    [114881] = true, -- Summon Shade
    [62912] = true,  -- Blockade of Fire (Elemental Blockade) -- Fire
    [39018] = true,  -- Blockade of Storms (Elemental Blockade) -- Storm
    [62989] = true,  -- Blockade of Storms (Elemental Blockade) -- Storm
    [62987] = true,  -- Blockade of Storms (Elemental Blockade) -- Storm
    [114884] = true, -- Summon Shade
    [62990] = true,  -- Blockade of Storms (Elemental Blockade) -- Storm
    [62988] = true,  -- Blockade of Storms (Elemental Blockade) -- Storm
    [39028] = true,  -- Blockade of Frost (Elemental Blockade) -- Frost
    [62949] = true,  -- Unstable Wall of Frost (Elemental Blockade) -- Frost
    [62947] = true,  -- Unstable Wall of Frost (Elemental Blockade) -- Frost
    [114885] = true, -- Summon Shade
    [146311] = true, -- Frost Safeguard (Elemental Blockade) -- Frost
    [62951] = true,  -- Blockade of Frost (Elemental Blockade) -- Frost

    [29091] = true,  -- Destructive Touch (Destructive Touch)
    [29073] = true,  -- Flame Touch (Destructive Touch) -- Fire
    [62648] = true,  -- Fire Touch (Destructive Touch) -- Fire
    [29089] = true,  -- Shock Touch (Destructive Touch) -- Shock
    [62722] = true,  -- Shock Touch (Destructive Touch) -- Shock
    [29078] = true,  -- Frost Touch (Destructive Touch) -- Frost
    [62692] = true,  -- Frost Touch (Destructive Touch) -- Frost

    [38984] = true,  -- Destructive Clench (Destructive Clench)
    [38985] = true,  -- Flame Clench (Destructive Clench) -- Fire
    [38987] = true,  -- Stun After Knockback Movement (Destructive Clench) -- Fire
    [38986] = true,  -- Fire Touch (destruction) (Destructive Clench) -- Fire
    [38993] = true,  -- Shock Clench (Destructive Clench) -- Shock
    [62734] = true,  -- Shock Clench Explosion (Destructive Clench) -- Shock
    [38989] = true,  -- Frost Clench (Destructive Clench) -- Frost
    [38990] = true,  -- Deep Freeze (Destructive Clench) -- Frost

    [38937] = true,  -- Destructive Reach (Destructive Reach)
    [38944] = true,  -- Flame Reach (Destructive Reach) -- Fire
    [62682] = true,  -- Flame Reach (Destructive Reach) -- Fire
    [38978] = true,  -- Shock Reach (Destructive Reach) -- Shock
    [62745] = true,  -- Shock Reach (Destructive Reach) -- Shock
    [38970] = true,  -- Frost Reach (Destructive Reach) -- Frost
    [62712] = true,  -- Frost Reach (Destructive Reach) -- Frost

    [29173] = true,  -- Weakness to Elements (Weakness to Elements)
    [53881] = true,  -- Major Spell Shatter (Weakness to Elements)

    [39089] = true,  -- Elemental Susceptibility (Elemental Susceptibility)
    [62775] = true,  -- Major Breach (Elemental Susceptibility)

    [39095] = true,  -- Elemental Drain (Elemental Drain)
    [39100] = true,  -- Minor Magickasteal (Elemental Drain)
    [62787] = true,  -- Major Breach (Elemental Drain)

    [28800] = true,  -- Impulse (Impulse)
    [28794] = true,  -- Fire Impulse (Impulse)
    [146531] = true, -- Impulse Afterburn (Impulse)
    [28799] = true,  -- Shock Impulse (Impulse)
    [146557] = true, -- Shock Impulse (Impulse)
    [146556] = true, -- Shock Impulse (Impulse)
    [146553] = true, -- Shock Impulse (Impulse)
    [28798] = true,  -- Frost Impulse (Impulse)
    [146795] = true, -- Minor Protection (Impulse)

    [39143] = true,  -- Elemental Ring (Elemental Ring)
    [39145] = true,  -- Elemental Ring (Fire Ring)
    [39149] = true,  -- Elemental Ring (Fire Ring)
    [146586] = true, -- Ring Afterburn (Fire Ring)
    [39147] = true,  -- Elemental Ring (Shock Ring)
    [146610] = true, -- Shock Impulse (Shock Ring)
    [146609] = true, -- Shock Impulse (Shock Ring)
    [39153] = true,  -- Elemental Ring (Shock Ring)
    [39146] = true,  -- Elemental Ring (Frost Ring)
    [39151] = true,  -- Elemental Ring (Frost Ring)
    [146796] = true, -- Minor Protection (Frost Ring)

    [39161] = true,  -- Pulsar (Pulsar)
    [39162] = true,  -- Flame Pulsar (Pulsar)
    [146585] = true, -- Pulsar Afterburn (Pulsar)
    [39168] = true,  -- Minor Mangle (Pulsar)

    [39167] = true,  -- Storm Pulsar (Pulsar)
    [146596] = true, -- Shock Impulse (Pulsar)
    [146603] = true, -- Shock Impulse (Pulsar)
    [146593] = true, -- Storm Pulsar (Pulsar)
    [39181] = true,  -- Minor Mangle (Pulsar)

    [39163] = true,  -- Frost Pulsar (Pulsar)
    [39180] = true,  -- Minor Mangle (Pulsar)
    [146797] = true, -- Minor Protection (Pulsar)

    [83619] = true,  -- Elemental Storm (Elemental Storm)
    [83625] = true,  -- Fire Storm (Elemental Storm)
    [83626] = true,  -- Fire Storm (Elemental Storm)
    [83630] = true,  -- Thunder Storm (Elemental Storm)
    [83631] = true,  -- Thunder Storm (Elemental Storm)
    [83628] = true,  -- Ice Storm (Elemental Storm)
    [83629] = true,  -- Ice Storm (Elemental Storm)

    [84434] = true,  -- Elemental Rage (Elemental Rage)
    [85126] = true,  -- Fiery Rage (Elemental Rage)
    [85127] = true,  -- Fiery Rage (Elemental Rage)
    [85130] = true,  -- Thunderous Rage (Elemental Rage)
    [85131] = true,  -- Thunderous Rage (Elemental Rage)
    [85128] = true,  -- Icy Rage (Elemental Rage)
    [85129] = true,  -- Icy Rage (Elemental Rage)
    [104825] = true, -- Icy Rage (Elemental Rage)

    [83642] = true,  -- Eye of the Storm (Eye of the Storm)
    [83682] = true,  -- Eye of Flame (Eye of the Storm)
    [83683] = true,  -- Eye of Flame (Eye of the Storm)
    [83686] = true,  -- Eye of Lightning (Eye of the Storm)
    [83687] = true,  -- Eye of Lightning (Eye of the Storm)
    [83684] = true,  -- Eye of Frost (Eye of the Storm)
    [83685] = true,  -- Eye of Frost (Eye of the Storm)

    -------------------------------------
    -- RESTORATION STAFF PASSIVES -------
    -------------------------------------

    [16145] = true, -- Light Attack (Restoration)
    [16212] = true, -- Heavy Attack (Restoration)
    [67022] = true, -- Heavy Attack (Restoration)
    [32760] = true, -- Heavy Attack (Restoration)

    [30973] = true, -- Essence Drain (Rank 1)
    [77918] = true, -- Major Mending
    [30978] = true, -- Essence Drain
    [45517] = true, -- Essence Drain (Rank 2)
    [77922] = true, -- Major Mending
    [45518] = true, -- Essence Drain

    [30980] = true, -- Restoration Expert (Rank 1)
    [45519] = true, -- Restoration Expert (Rank 2)

    [30972] = true, -- Cycle of Life (Rank 1)
    [45520] = true, -- Cycle of Life (Rank 2)

    [30869] = true, -- Absorb (Rank 1)
    [30971] = true, -- Absorb
    [45521] = true, -- Absorb (Rank 2)
    [45522] = true, -- Absorb

    [30981] = true, -- Restoration Master (Rank 1)
    [45524] = true, -- Restoration Master (Rank 2)

    -------------------------------------
    -- RESTORATION STAFF ACTIVES --------
    -------------------------------------

    [52515] = true,  -- Grand Healing Fx (Grand Healing - All Morphs)
    [28385] = true,  -- Grand Healing (Grand Healing)
    [28386] = true,  -- Grand Healing (Grand Healing)
    [125846] = true, -- Grand Healing (Grand Healing)

    [40058] = true,  -- Illustrious Healing (Illustrious Healing)
    [40059] = true,  -- Illustrious Healing (Illustrious Healing)
    [125848] = true, -- Illustrious Healing (Illustrious Healing)

    [40060] = true,  -- Healing Springs (Healing Springs)
    [40061] = true,  -- Healing Springs (Healing Springs)
    [40062] = true,  -- Healing Springs (Healing Springs)
    [125851] = true, -- Healing Springs (Healing Springs)

    [46257] = true,  -- Regeneration (Regeneration)
    [28536] = true,  -- Regeneration (Regeneration)
    [57452] = true,  -- Regeneration Dummy (Regeneration)

    [46262] = true,  -- Regeneration (Rapid Regeneration)
    [40076] = true,  -- Rapid Regeneration (Rapid Regeneration)
    [57466] = true,  -- Rapid Regeneration Dummy (Rapid Regeneration)

    [46266] = true,  -- Radiating Regeneration (Radiating Regeneration)
    [40079] = true,  -- Radiating Regeneration (Radiating Regeneration)
    [57468] = true,  -- Medicament (Radiating Regeneration)

    [37243] = true,  -- Blessing of Protection (Blessing of Protection)
    [37247] = true,  -- Minor Resolve (Blessing of Protection)
    [38300] = true,  -- Blessing of Protection (Blessing of Protection)
    [38299] = true,  -- Blessing of Protection (Blessing of Protection)
    [38298] = true,  -- Blessing of Protection (Blessing of Protection)

    [40103] = true,  -- Blessing of Restoration (Blessing of Restoration)
    [62626] = true,  -- Minor Resolve (Blessing of Restoration)
    [40106] = true,  -- Blessing of Restoration (Blessing of Restoration)
    [40108] = true,  -- Blessing of Restoration (Blessing of Restoration)
    [40105] = true,  -- Blessing of Restoration (Blessing of Restoration)

    [40094] = true,  -- Combat Prayer (Combat Prayer)
    [62634] = true,  -- Minor Resolve (Combat Prayer)
    [62636] = true,  -- Minor Berserk (Combat Prayer)
    [40097] = true,  -- Combat Prayer (Combat Prayer)
    [40096] = true,  -- Combat Prayer (Combat Prayer)
    [40099] = true,  -- Combat Prayer (Combat Prayer)

    [37232] = true,  -- Steadfast Ward (Steadfast Ward)

    [40130] = true,  -- Ward Ally (Ward Ally)
    [40132] = true,  -- Ward Ally (Ward Ally)

    [40126] = true,  -- Healing Ward (Healing Ward)
    [40128] = true,  -- Healing Ward (Healing Ward)

    [31531] = true,  -- Force Siphon (Force Siphon)
    [88565] = true,  -- Minor Lifesteal (Force Siphon)

    [40109] = true,  -- Siphon Spirit (Siphon Spirit)
    [88575] = true,  -- Minor Lifesteal (Siphon Spirit)
    [88576] = true,  -- Minor Lifesteal (Siphon Spirit)

    [40116] = true,  -- Quick Siphon (Quick Siphon)
    [88606] = true,  -- Minor Lifesteal (Quick Siphon)
    [125901] = true, -- Minor Expedition (Quick Siphon)

    [83552] = true,  -- Panacea (Panacea)
    [83844] = true,  -- Panacea (Panacea)

    [83850] = true,  -- Life Giver (Life Giver)
    [83851] = true,  -- Life Giver (Life Giver)
    [83867] = true,  -- Life Giver (Life Giver)
    [83876] = true,  -- Life Giver (Life Giver)

    [85132] = true,  -- Light's Champion (Light's Champion)
    [85133] = true,  -- Light's Champion (Light's Champion)
    [85154] = true,  -- Major Force (Light's Champion)

    -------------------------------------
    -- ARMOR PASSIVES -------------------
    -------------------------------------

    -- LIGHT ARMOR
    [29639] = true, -- Evocation (Rank 1)
    [45548] = true, -- Evocation (Rank 2)
    [45549] = true, -- Evocation (Rank 3)
    [29665] = true, -- Recovery (Rank 1)
    [45557] = true, -- Recovery (Rank 2)
    [29663] = true, -- Spell Warding (Rank 1)
    [45559] = true, -- Spell Warding (Rank 2)
    [29668] = true, -- Prodigy (Rank 1)
    [45561] = true, -- Prodigy (Rank 2)
    [29667] = true, -- Concentration (Rank 1)
    [45562] = true, -- Concentration (Rank 2)

    -- MEDIUM ARMOR
    [150054] = true, -- Medium Armor Evasion (Medium Armor Bonuses)
    [150057] = true, -- Medium Armor Evasion (Medium Armor Bonuses)
    [29743] = true,  -- Dexterity (Rank 1)
    [45563] = true,  -- Dexterity (Rank 2)
    [45564] = true,  -- Dexterity (Rank 3)
    [29687] = true,  -- Wind Walker (Rank 1)
    [45565] = true,  -- Wind Walker (Rank 2)
    [29738] = true,  -- Improved Sneak (Rank 1)
    [45567] = true,  -- Improved Sneak (Rank 2)
    [29686] = true,  -- Agility (Rank 1)
    [45572] = true,  -- Agility (Rank 2)
    [29742] = true,  -- Athletics (Rank 1)
    [45574] = true,  -- Athletics (Rank 2)

    -- HEAVY ARMOR
    [29825] = true, -- Resolve (Rank 1)
    [45531] = true, -- Resolve (Rank 2)
    [45533] = true, -- Resolve (Rank 3)
    [29769] = true, -- Constitution (Rank 1)
    [58428] = true, -- Constitution
    [58503] = true, -- Constitution
    [45526] = true, -- Constitution (Rank 2)
    [58430] = true, -- Constitution
    [58431] = true, -- Constitution
    [29804] = true, -- Juggernaught (Rank 1)
    [45546] = true, -- Juggernaught (Rank 2)
    [29773] = true, -- Revitalize (Rank 1)
    [45528] = true, -- Revitalize (Rank 2)
    [29791] = true, -- Rapid Mending (Rank 1)
    [45529] = true, -- Rapid Mending (Rank 2)

    -------------------------------------
    -- ARMOR ACTIVES --------------------
    -------------------------------------

    -- LIGHT ARMOR
    [29338] = true, -- Annulment (Annulment)

    [39188] = true, -- Dampen Magic (Dampen Magic)
    [39186] = true, -- Dampen Magic (Dampen Magic)

    [39182] = true, -- Harness Magicka (Harness Magicka)
    [39184] = true, -- Harness Magicka (Harness Magicka)
    [60968] = true, -- Harness Magicka Counter (Harness Magicka)

    -- MEDIUM ARMOR
    [29556] = true,  -- Evasion (Evasion)
    [63015] = true,  -- Major Evasion (Evasion)

    [39195] = true,  -- Shuffle (Shuffle)
    [63019] = true,  -- Major Evasion (Shuffle)
    [39196] = true,  -- Shuffle (Shuffle)

    [39192] = true,  -- Elude (Elude)
    [126958] = true, -- Elude (Elude)
    [63030] = true,  -- Major Evasion (Elude)
    [126957] = true, -- Major Expedition (Elude)

    -- HEAVY ARMOR
    [29552] = true,  -- Unstoppable (Unstoppable)
    [63084] = true,  -- Major Resolve (Unstoppable)
    [29553] = true,  -- Unstoppable (Unstoppable)
    [126581] = true, -- Unstoppable (Unstoppable)

    [39205] = true,  -- Unstoppable Brute (Unstoppable Brute)
    [63134] = true,  -- Major Resolve (Unstoppable Brute)
    [63133] = true,  -- Unstoppable Brute (Unstoppable Brute)
    [126582] = true, -- Unstoppable (Unstoppable Brute)

    [39197] = true,  -- Immovable (Immovable)
    [63119] = true,  -- Major Resolve (Immovable)
    [63118] = true,  -- Immovable (Immovable)
    [126583] = true, -- Immovable (Immovable)

    -------------------------------------
    -- LEGERDEMAIN PASSIVES -------------
    -------------------------------------

    [63799] = true, -- Improved Hiding (Rank 1)
    [63800] = true, -- Improved Hiding (Rank 2)
    [63801] = true, -- Improved Hiding (Rank 3)
    [63802] = true, -- Improved Hiding (Rank 4)

    [63803] = true, -- Light Fingers (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63804] = true, -- Light Fingers (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63805] = true, -- Light Fingers (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63806] = true, -- Light Fingers (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [63807] = true, -- Trafficker (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63808] = true, -- Trafficker (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63809] = true, -- Trafficker (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63810] = true, -- Trafficker (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [63811] = true, -- Locksmith (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63812] = true, -- Locksmith (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63813] = true, -- Locksmith (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63814] = true, -- Locksmith (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [63815] = true, -- Kickback (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63816] = true, -- Kickback (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63817] = true, -- Kickback (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [63818] = true, -- Kickback (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    -------------------------------------
    -- SOUL MAGIC PASSIVES --------------
    -------------------------------------

    [39266] = true, -- Soul Shatter (Rank 1)
    [39267] = true, -- Soul Shatter
    [45583] = true, -- Soul Shatter (Rank 2)
    [45584] = true, -- Soul Shatter

    [39269] = true, -- Soul Summons (Rank 1)
    [45590] = true, -- Soul Summons (Rank 2)
    [43752] = true, -- Soul Summons

    [39263] = true, -- Soul Lock (Rank 1)
    [39264] = true, -- Soul Trap
    [45580] = true, -- Soul Lock (Rank 2)
    [45582] = true, -- Soul Trap

    -------------------------------------
    -- SOUL MAGIC ACTIVES ---------------
    -------------------------------------

    [26768] = true,  -- Soul Trap (Soul Trap)
    [126890] = true, -- Soul Trap (Soul Trap)
    [26769] = true,  -- Soul Trap (Soul Trap)

    [40328] = true,  -- Soul Splitting Trap (Soul Splitting Trap)
    [126895] = true, -- Soul Splitting Trap (Soul Splitting Trap)
    [40329] = true,  -- Soul Splitting Trap (Soul Splitting Trap)

    [40317] = true,  -- Consuming Trap (Consuming Trap)
    [126897] = true, -- Consuming Trap (Consuming Trap)
    [40319] = true,  -- Consuming Trap (Consuming Trap)
    [40323] = true,  -- Consuming Trap (Consuming Trap)
    [40321] = true,  -- Consuming Trap (Consuming Trap)
    [40326] = true,  -- Consuming Trap (Consuming Trap)

    [87321] = true,  -- Soul Strike Reveal (Soul Strike - All Morphs)
    [39270] = true,  -- Soul Strike (Soul Strike)

    [40420] = true,  -- Soul Assault (Soul Assault)

    [40414] = true,  -- Shatter Soul (Shatter Soul)
    [40416] = true,  -- Shatter Soul (Shatter Soul)

    -------------------------------------
    -- VAMPIRE PASSIVES -----------------
    -------------------------------------

    -- Vampire Precursor Disease
    -- [39472] = true, -- Noxiphilic Sanguivoria
    [40360] = true, -- Noxiphilic Sanguivoria

    -- Base Vampirism
    [135397] = true, -- Vampire Stage 1
    [135399] = true, -- Vampire Stage 2
    [135400] = true, -- Vampire Stage 3
    [135402] = true, -- Vampire Stage 4
    [135412] = true, -- Vampire Stage 5

    -- Feed
    [35770] = true,  -- Feed (P2M Grant Ability)
    [33152] = true,  -- Feed
    [33182] = true,  -- Feed
    [33175] = true,  -- Feed
    [138780] = true, -- Feed

    -- Dark Stalker
    [33095] = true, -- Dark Stalker (Rank 1)
    [46041] = true, -- Dark Stalker (Rank 2)

    -- Strike from the Shadows
    [33096] = true,  -- Strike from the Shadows (Rank 1)
    [135189] = true, -- Strike from the Shadows
    [46040] = true,  -- Strike from the Shadows (Rank 2)
    [135190] = true, -- Strike from the Shadows

    -- Blood Ritual
    [33091] = true, -- Blood Ritual (Rank 1)
    [40355] = true, -- Feed
    [40349] = true, -- Feed
    [40350] = true, -- Feed
    [40359] = true, -- Feed Cooldown

    -- Undeath
    [33093] = true, -- Undeath (Undeath Rank 1)
    [33090] = true, -- Undeath (Undeath Rank 2)

    -- Unnatural Movement
    [132844] = true, -- Unnatural Movement (Rank 1)
    [135208] = true, -- Unnatural Movement
    [132845] = true, -- Unnatural Movement
    [132849] = true, -- Unnatural Movement
    [132848] = true, -- Unnatural Movement

    [135218] = true, -- Unnatural Movement (Rank 2)
    [135220] = true, -- Unnatural Movement (Rank 2)
    [135223] = true, -- Unnatural Movement (Rank 2)
    [135226] = true, -- Unnatural Movement (Rank 2)
    [135225] = true, -- Unnatural Movement (Rank 2)

    -------------------------------------
    -- VAMPIRE ACTIVES ------------------
    -------------------------------------

    [32893] = true,  -- Eviscerate (Eviscerate)

    [38949] = true,  -- Blood for Blood
    [145002] = true, -- Blood for Blood

    [38956] = true,  -- Arterial Burst
    [81491] = true,  -- Arterial Burst

    [132141] = true, -- Blood Frenzy
    [172418] = true, -- Blood Frenzy
    [142464] = true, -- Blood Frenzy

    [134160] = true, -- Simmering Frenzy
    [134166] = true, -- Simmering Frenzy
    [134165] = true, -- Simmering Frenzy

    [135841] = true, -- Sated Fury
    [172648] = true, -- Sated Fury
    [135847] = true, -- Sated Fury
    [142495] = true, -- Sated Fury
    [135846] = true, -- Sated Fury

    [134583] = true, -- Vampiric Drain
    [134588] = true, -- Vampiric Drain

    [135905] = true, -- Drain Vigor
    [135906] = true, -- Drain Vigor
    [135907] = true, -- Drain Vigor

    [137259] = true, -- Exhilarating Drain
    [137260] = true, -- Exhilarating Drain
    [137261] = true, -- Exhilarating Drain

    [128709] = true, -- Mesmerize
    [128712] = true, -- Mesmerize
    [137798] = true, -- Mesmerize

    [137861] = true, -- Hypnosis
    [137865] = true, -- Hypnosis
    [137866] = true, -- Hypnosis

    [138097] = true, -- Stupefy
    [138098] = true, -- Stupefy
    [138130] = true, -- Stupefy
    [138099] = true, -- Stupefy

    [32986] = true,  -- Mist Form (Mist Form)

    [38963] = true,  -- Elusive Mist (Elusive Mist)
    [38967] = true,  -- Major Expedition (Elusive Mist)

    [38965] = true,  -- Blood Mist (Blood Mist)
    [38968] = true,  -- Blood Mist (Blood Mist)
    [135427] = true, -- Blood Mist (Blood Mist)

    [32624] = true,  -- Blood Scion (Blood Scion)
    [135978] = true, -- Blood Scion (Blood Scion)
    [138565] = true, -- Blood Scion (Blood Scion)
    -- [138607] = true, -- Blood Scion (Blood Scion)
    [138564] = true, -- Blood Scion (Blood Scion)
    [140368] = true, -- Blood Scion (Blood Scion)
    [135945] = true, -- Blood Scion (Blood Scion)
    [138568] = true, -- Blood Scion (Blood Scion)

    [38932] = true,  -- Swarming Scion (Swarming Scion)
    [136092] = true, -- Swarming Scion (Swarming Scion)
    [138614] = true, -- Swarming Scion (Swarming Scion)
    [138607] = true, -- Swarming Scion (Swarming Scion)
    [138613] = true, -- Swarming Scion (Swarming Scion)
    [140777] = true, -- Swarming Scion (Swarming Scion)
    [136088] = true, -- Swarming Scion (Swarming Scion)
    [38935] = true,  -- Swarming Scion (Swarming Scion)
    [138615] = true, -- Swarming Scion (Swarming Scion)

    [38931] = true,  -- Perfect Scion (Perfect Scion)
    [137420] = true, -- Perfect Scion (Perfect Scion)
    [138618] = true, -- Perfect Scion (Perfect Scion)
    [138617] = true, -- Perfect Scion (Perfect Scion)
    [140779] = true, -- Perfect Scion (Perfect Scion)
    [137416] = true, -- Perfect Scion (Perfect Scion)
    [138619] = true, -- Perfect Scion (Perfect Scion)

    -------------------------------------
    -- VAMPIRE QUEST --------------------
    -------------------------------------

    [44670] = true,  -- Vamp Theater Head Grab Stun
    [39507] = true,  -- VampInitStun_Profane
    [39505] = true,  -- VampInit_FeedTarget

    [44222] = true,  -- VampireInitiation_Lamae
    [39653] = true,  -- VampInitStun_Submit
    [39506] = true,  -- Devour
    [39518] = true,  -- VampInitStun
    [39728] = true,  -- VampInit_TheaterFeed
    [39422] = true,  -- Mist Form
    [39509] = true,  -- VampInit_PC Becomes a Vampire
    [44134] = true,  -- Vampire Abilities
    [56684] = true,  -- Quick Strike
    [140367] = true, -- Voice of Lamae
    [140370] = true, -- Voice of Lamae
    [140371] = true, -- Voice of Lamae
    [135533] = true, -- Lamae's Blessing
    -- [40499] = true, -- Rite of the Scion
    [72945] = true,  -- _CRWN Become Vampire
    [72946] = true,  -- Stun

    -------------------------------------
    -- WEREWOLF PASSIVES ----------------
    -------------------------------------

    [35658] = true,  -- Lycanthrophy
    -- [31068] = true, -- Sanies Lupinus (NPC Bite)
    [40521] = true,  -- Sanies Lupinus (Player Bite)

    [32464] = true,  -- Light Attack (Werewolf)
    [32477] = true,  -- Heavy Attack (Werewolf)
    [32479] = true,  -- Heavy Attack (Werewolf)
    [32478] = true,  -- Heavy Attack Damage Bonus
    [32480] = true,  -- Heavy Attack (Werewolf)
    [32494] = true,  -- Heavy Attack (Werewolf)
    [60773] = true,  -- Heavy Attack (Werewolf)
    [40544] = true,  -- Keep Corpse
    [40545] = true,  -- Keep Corpse

    [32634] = true,  -- Devour (Rank 1)
    [33208] = true,  -- Devour
    [33209] = true,  -- Devour
    [37233] = true,  -- Devour

    [32636] = true,  -- Pursuit (Rank 1)
    [46142] = true,  -- Pursuit (Rank 2)

    [32637] = true,  -- Blood Rage (Rank 1)
    [46135] = true,  -- Blood Rage (Rank 2)
    [144209] = true, -- Blood Rage (Werewolf/Berserker)
    [144208] = true, -- Blood Rage (Werewolf/Berserker)
    [144211] = true, -- Blood Rage (Pack Leader)
    [144210] = true, -- Blood Rage (Pack Leader)

    [32639] = true,  -- Bloodmoon (Rank 1)
    [40514] = true,  -- Ally Bite (Bloodmoon)
    [40515] = true,  -- Devour (Bloodmoon)
    [40520] = true,  -- Q3047 - Knockdown (Bloodmoon)
    [40525] = true,  -- Bit an ally (Bloodmoon)

    [32638] = true,  -- Savage Strength (Savage Strength - Rank 1)
    [46139] = true,  -- Savage Strength (Savage Strength - Rank 2)
    [150999] = true, -- Major Resolve (Savage Strength)

    [32641] = true,  -- Call of the Pack (Rank 1)
    [80283] = true,  -- Call of the Pack
    [46137] = true,  -- Call of the Pack (Rank 2)
    [80282] = true,  -- Call of the Pack

    -------------------------------------
    -- WEREWOLF ACTIVES -----------------
    -------------------------------------

    [32632] = true,  -- Pounce (Pounce)
    [32645] = true,  -- Pounce (Pounce)
    [137157] = true, -- Carnage (Pounce)
    [137156] = true, -- Carnage (Pounce)

    [39105] = true,  -- Brutal Pounce (Brutal Pounce)
    [39109] = true,  -- Brutal Pounce (Brutal Pounce)
    [137186] = true, -- Brutal Carnage (Brutal Pounce)
    [137184] = true, -- Brutal Carnage (Brutal Pounce)
    [137189] = true, -- Brutal Carnage (Brutal Pounce)

    [39104] = true,  -- Feral Pounce (Feral Pounce)
    [39107] = true,  -- Feral Pounce (Feral Pounce)
    [137165] = true, -- Feral Carnage (Feral Pounce)
    [137167] = true, -- Feral Carnage (Feral Pounce)
    [137168] = true, -- Feral Carnage (Feral Pounce)
    [137164] = true, -- Feral Carnage (Feral Pounce)

    [137193] = true, -- Major Brutality (Hircine's Bounty - All Morphs)
    [58310] = true,  -- Hircine's Bounty (Hircine's Bounty)
    [137202] = true, -- Hircine's Bounty (Hircine's Bounty)

    [58317] = true,  -- Hircine's Rage (Hircine's Rage)
    [137204] = true, -- Hircine's Rage (Hircine's Rage)
    [137206] = true, -- Major Berserk (Hircine's Rage)

    [58325] = true,  -- Hircine's Fortitude (Hircine's Fortitude)
    [137209] = true, -- Hircine's Fortitude (Hircine's Fortitude)
    [137210] = true, -- Hircine's Fortitude (Hircine's Fortitude)

    [138072] = true, -- Major Savagery (Roar - All Morphs)

    [32633] = true,  -- Roar (Roar)
    [125004] = true, -- Roar (Roar)
    [137257] = true, -- Off Balance (Roar)

    [39113] = true,  -- Ferocious Roar (Ferocious Roar)
    [125007] = true, -- Ferocious Roar (Ferocious Roar)
    [45834] = true,  -- Off Balance (Ferocious Roar)
    [137287] = true, -- Ferocious Roar (Ferocious Roar)

    [39114] = true,  -- Deafening Roar (Deafening Roar)
    [125023] = true, -- Deafening Roar (Deafening Roar)
    [111788] = true, -- Major Breach (Deafening Roar)
    [137311] = true, -- Minor Maim (Deafening Roar)
    [137312] = true, -- Off Balance (Deafening Roar)

    [58405] = true,  -- Piercing Howl (Piercing Howl)
    [137317] = true, -- Piercing Howl (Piercing Howl)

    [58775] = true,  -- Feeding Frenzy (Howl of Despair - Feeding Frenzy Synergy)
    [131353] = true, -- Empower (Howl of Despair - Feeding Frenzy Synergy)
    [58813] = true,  -- Feeding Frenzy (Howl of Despair - Feeding Frenzy Synergy)
    [58742] = true,  -- Howl of Despair (Howl of Despair)
    [58745] = true,  -- Feeding Frenzy (Howl of Despair)
    [58744] = true,  -- Howl of Despair Synergy (Howl of Despair)
    [137321] = true, -- Piercing Howl (Howl of Despair)

    [58801] = true,  -- Howl of Agony Bonus (Howl of Agony)
    [58798] = true,  -- Howl of Agony (Howl of Agony)

    [58855] = true,  -- Infectious Claws (Infectious Claws)
    [58856] = true,  -- Infectious Claws (Infectious Claws)

    [58864] = true,  -- Claws of Anguish (Claws of Anguish)
    [58865] = true,  -- Claws of Anguish (Claws of Anguish)
    [58869] = true,  -- Major Defile (Claws of Anguish)

    [58879] = true,  -- Claws of Life (Claws of Life)
    [58880] = true,  -- Claws of Life (Claws of Life)
    [61378] = true,  -- Claws of Life Caused Damage (Claws of Life)
    [61379] = true,  -- Claws of Life Saved Damage (Claws of Life)
    [58881] = true,  -- Claws of Life (Claws of Life)

    [33469] = true,  -- Werewolf Transformation (Werewolf Transformation - All Morphs)
    [39033] = true,  -- Werewolf Transform Setup (Werewolf Transformation - All Morphs)
    [131323] = true, -- Werewolf Transform Setup (Werewolf Transformation - All Morphs)
    [39035] = true,  -- Werewolf (Werewolf Transformation - All Morphs)
    [39023] = true,  -- Werewolf Resource Bar Setup (Werewolf Transformation - All Morphs)
    [39025] = true,  -- Charge Werewolf (Werewolf Transformation - All Morphs)
    [39038] = true,  -- Werewolf Effects Setup (Werewolf Transformation - All Morphs)
    [39039] = true,  -- Bonus Stamina (Werewolf Transformation - All Morphs)
    [39051] = true,  -- Kill Trigger (Werewolf Transformation - All Morphs)
    [39050] = true,  -- Devour Passive
    [39477] = true,  -- De-Werewolf (Werewolf Transformation - All Morphs)
    [39478] = true,  -- Remove Sprint (Werewolf Transformation - All Morphs)
    [80194] = true,  -- Remove Pets (Werewolf Transformation - All Morphs)
    [42246] = true,  -- Charge Ultimate (Werewolf Transformation - All Morphs)

    [32455] = true,  -- Werewolf Transformation (Werewolf Transformation)
    [47028] = true,  -- Werewolf Transformation (Werewolf Transformation)
    [111832] = true, -- Werewolf Transformation (Werewolf Transformation)

    [39075] = true,  -- Pack Leader (Pack Leader)
    [47069] = true,  -- Pack Leader (Pack Leader)
    [111843] = true, -- Pack Leader (Pack Leader)
    [137339] = true, -- Pack Leader Effects Setup (Pack Leader)
    [137340] = true, -- Devour Passive (Pack Leader)
    [137341] = true, -- Bonus Stamina (Pack Leader)
    [137343] = true, -- Kill Trigger (Pack Leader)
    [137348] = true, -- Minor Courage (Pack Leader)
    [112144] = true, -- Pack Leader (Pack Leader)
    [80180] = true,  -- Birth Direwolf (Pack Leader)
    [137373] = true, -- Birth Direwolf (Pack Leader)
    [80181] = true,  -- Familiar Set Target (Pack Leader)
    [80177] = true,  -- Pack Leader (Pack Leader)
    [80178] = true,  -- Pack Leader (Pack Leader)
    [80184] = true,  -- Lunge (Pack Leader)
    [127161] = true, -- Lunge (Pack Leader)
    [80189] = true,  -- Gnash (Pack Leader)
    [80190] = true,  -- Gnash (Pack Leader)

    [39076] = true,  -- Werewolf Berserker (Werewolf Berserker)
    [47083] = true,  -- Werewolf Berserker (Werewolf Berserker)
    [111844] = true, -- Werewolf Berserker (Werewolf Berserker)
    [89147] = true,  -- Werewolf Berserker Bleed (Werewolf Berserker)

    -------------------------------------
    -- WEREWOLF QUEST EVENTS ------------
    -------------------------------------

    [39421] = true, -- Q4961 HircineStun
    [65429] = true, -- Q4961 Songamdir Werewolf
    [39441] = true, -- Hircine's Power
    [75008] = true, -- Werewolf Transformation
    [39457] = true, -- Werewolf Transformation
    [39458] = true, -- Werewolf Effects
    [40123] = true, -- Devour Passive

    [55885] = true, -- Light Attack
    [55886] = true, -- Heavy Attack (Were)
    [55887] = true, -- Heavy Attack Damage Bonus
    [55888] = true, -- Heavy Attack
    [55891] = true, -- Heavy Attack Werewolf
    [55890] = true, -- Heavy Attack

    [44687] = true, -- Slow Despawn Self 15M
    [40101] = true, -- Q4961 Feast Swipe
    [40102] = true, -- Q4961 Feast Munch
    -- [40124] = true, -- Devour
    -- [40125] = true, -- Devour

    [41057] = true, -- Begin Werewolf

    [73123] = true, -- _CRWN Become Werewolf
    [73124] = true, -- Stun
    [73126] = true, -- Werewolf Appearance
    [73181] = true, -- Werewolf Appearance

    -------------------------------------
    -- DARK BROTHERHOOD PASSIVES --------
    -------------------------------------

    [78219] = true,  -- Blade of Woe (Rank 1)
    [76325] = true,  -- Blade of Woe
    [77101] = true,  -- Blade of Woe
    [77102] = true,  -- Blade of Woe Snare
    [146301] = true, -- Blade of Woe
    [81101] = true,  -- Assassins League Style Item Gi
    [81118] = true,  -- Assassins League Style Item FX
    [81133] = true,  -- Assassins League Style Item FX
    [81604] = true,  -- Self Reveal

    [77392] = true,  -- Scales of Pitiless Justice (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [77394] = true,  -- Scales of Pitiless Justice II (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [77395] = true,  -- Scales of Pitiless Justice III (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [79865] = true,  -- Scales of Pitiless Justice IV (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [77397] = true,  -- Padomaic Sprint (Rank 1)
    [79623] = true,  -- Major Expedition (Blade of Woe Kill)
    [77398] = true,  -- Padomaic Sprint II (Rank 2)
    [79624] = true,  -- Major Expedition (Blade of Woe Kill)
    [77399] = true,  -- Padomaic Sprint III (Rank 3)
    [79625] = true,  -- Major Expedition (Blade of Woe Kill)
    [79868] = true,  -- Padomaic Sprint IV (Rank 4)
    [79877] = true,  -- Major Expedition (Blade of Woe Kill)

    [77396] = true,  -- Shadowy Supplier (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion

    [77400] = true,  -- Shadow Rider (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion

    [77401] = true,  -- Spectral Assassin (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [80636] = true,  -- Spectral Assassin

    -------------------------------------
    -- FIGHTERS GUILD PASSIVES ----------
    -------------------------------------

    [29062] = true, -- Intimidating Presence (Rank 1)

    [35803] = true, -- Slayer (Rank 1)
    [45595] = true, -- Slayer (Rank 2)
    [45596] = true, -- Slayer (Rank 3)

    [35800] = true, -- Banish the Wicked (Rank 1)
    [35801] = true, -- Banish the Wicked
    [45597] = true, -- Banish the Wicked (Rank 2)
    [45598] = true, -- Banish the Wicked
    [45599] = true, -- Banish the Wicked (Rank 3)
    [45600] = true, -- Banish the Wicked

    [40393] = true, -- Skilled Tracker (Rank 1)

    [35804] = true, -- Bounty Hunter (Rank 1)

    -------------------------------------
    -- FIGHTERS GUILD ACTIVES -----------
    -------------------------------------

    [35721] = true,  -- Silver Bolts (Silver Bolts)

    [40300] = true,  -- Silver Shards (Silver Shards)
    [40327] = true,  -- Silver Shards (Silver Shards)

    [40336] = true,  -- Silver Leash (Silver Leash)
    [40340] = true,  -- Silver Leash (Silver Leash)
    [109354] = true, -- Silver Leash (Silver Leash)

    [35737] = true,  -- Circle of Protection (Circle of Protection)
    [80271] = true,  -- Minor Endurance (Circle of Protection)
    [35739] = true,  -- Minor Protection (Circle of Protection)
    [35738] = true,  -- Circle of Protection (Circle of Protection)

    [40181] = true,  -- Turn Evil (Turn Evil)
    [80276] = true,  -- Minor Endurance (Turn Evil)
    [40185] = true,  -- Minor Protection (Turn Evil)
    [40184] = true,  -- Turn Evil (Turn Evil)
    [40187] = true,  -- Turn Evil (Turn Evil)

    [40169] = true,  -- Ring of Preservation (Ring of Preservation)
    [80284] = true,  -- Minor Endurance (Ring of Preservation)
    [40171] = true,  -- Minor Protection (Ring of Preservation)
    [80293] = true,  -- Ring of Preservation (Ring of Preservation)
    [40170] = true,  -- Ring of Preservation (Ring of Preservation)

    [35765] = true,  -- Sense Evil (Expert Hunter - All Ranks)
    [64509] = true,  -- Major Savagery (Expert Hunter - All Ranks)
    [35762] = true,  -- Expert Hunter (Expert Hunter)
    [80307] = true,  -- Expert Hunter (Expert Hunter)

    [40194] = true,  -- Evil Hunter (Evil Hunter)
    [80381] = true,  -- Evil Hunter (Evil Hunter)

    [80469] = true,  -- Sense Evil 1 (Camouflaged Hunter)
    [40195] = true,  -- Camouflaged Hunter (Camouflaged Hunter)
    [80338] = true,  -- Camouflaged Hunter (Camouflaged Hunter)
    [80471] = true,  -- Minor Berserk (Camouflaged Hunter)

    [35750] = true,  -- Trap Beast (Trap Beast)
    [35757] = true,  -- Trap Beast (Trap Beast)
    [35754] = true,  -- Trap Beast (Trap Beast)
    [35756] = true,  -- Trap Beast (Trap Beast)
    [35753] = true,  -- Trap Beast (Trap Beast)
    [68595] = true,  -- Minor Force (Trap Beast)

    [40382] = true,  -- Barbed Trap (Barbed Trap)
    [40386] = true,  -- Barbed Trap (Barbed Trap)
    [40389] = true,  -- Barbed Trap (Barbed Trap)
    [40385] = true,  -- Barbed Trap (Barbed Trap)
    [40384] = true,  -- Barbed Trap (Barbed Trap)
    [68632] = true,  -- Minor Force (Barbed Trap)

    [40372] = true,  -- Lightweight Beast Trap (Lightweight Beast Trap)
    [40378] = true,  -- Daedric Mines (Lightweight Beast Trap)
    [40377] = true,  -- Summon Shade (Lightweight Beast Trap)
    [40376] = true,  -- Lightweight Beast Trap (Lightweight Beast Trap)
    [40375] = true,  -- Lightweight Beast Trap (Lightweight Beast Trap)
    [40374] = true,  -- Lightweight Beast Trap (Lightweight Beast Trap)
    [68628] = true,  -- Minor Force (Lightweight Beast Trap)

    [35713] = true,  -- Dawnbreaker (Dawnbreaker)
    [62305] = true,  -- Dawnbreaker (Dawnbreaker)

    [40161] = true,  -- Flawless Dawnbreaker (Flawless Dawnbreaker)
    [126312] = true, -- Flawless Dawnbreaker Passive (Flawless Dawnbreaker)
    [62310] = true,  -- Flawless Dawnbreaker (Flawless Dawnbreaker)

    [40158] = true,  -- Dawnbreaker of Smiting (Dawnbreaker of Smiting)
    [40160] = true,  -- Dawnbreaker of Smiting (Dawnbreaker of Smiting)
    [62314] = true,  -- Dawnbreaker of Smiting (Dawnbreaker of Smiting)

    -------------------------------------
    -- MAGES GUILD PASSIVES -------------
    -------------------------------------

    [29061] = true, -- Persuasive Will (Rank 1)

    [40436] = true, -- Mage Adept (Rank 1)
    [45601] = true, -- Mage Adept (Rank 2)

    [40437] = true, -- Everlasting Magic (Rank 1)
    [45602] = true, -- Everlasting Magic (Rank 2)

    [40438] = true, -- Magicka Controller (Rank 1)
    [45603] = true, -- Magicka Controller (Rank 2)

    [43561] = true, -- Might of the Guild (Rank 1)
    [65507] = true, -- Empower
    [45607] = true, -- Might of the Guild (Rank 2)
    [65541] = true, -- Empower

    -------------------------------------
    -- MAGES GUILD ACTIVES --------------
    -------------------------------------

    [77928] = true,  -- Major Prophecy (Magelight)
    [30920] = true,  -- Magelight (Magelight)
    [31079] = true,  -- Magelight (Magelight)

    [77945] = true,  -- Major Prophecy (Inner Light)
    [40478] = true,  -- Inner Light (Inner Light)
    [40480] = true,  -- Inner Light (Inner Light)

    [77958] = true,  -- Major Prophecy (Radiant Magelight)
    [77960] = true,  -- Radiant Magelight (Radiant Magelight)
    [40483] = true,  -- Radiant Magelight (Radiant Magelight)
    [40484] = true,  -- Radiant Magelight (Radiant Magelight)

    [28567] = true,  -- Entropy (Entropy)
    [126370] = true, -- Entropy (Entropy)

    [40457] = true,  -- Degeneration (Degeneration)
    [126374] = true, -- Degeneration (Degeneration)
    [63227] = true,  -- Major Sorcery (Degeneration)

    [40452] = true,  -- Structured Entropy (Structured Entropy)
    [126371] = true, -- Structured Entropy (Structured Entropy)
    [40456] = true,  -- Structured Entropy (Structured Entropy)
    [40454] = true,  -- Structured Entropy (Structured Entropy)

    [31637] = true,  -- Only 1 Fire Rune (Fire Rune - All Ranks)
    [31632] = true,  -- Fire Rune (Fire Rune)
    [40648] = true,  -- Fire Rune (Fire Rune)
    [31635] = true,  -- Fire Rune (Fire Rune)
    [31633] = true,  -- Fire Rune (Fire Rune)

    [40470] = true,  -- Volcanic Rune (Volcanic Rune)
    [40693] = true,  -- Volcanic Rune (Volcanic Rune)
    [40473] = true,  -- Volcanic Rune (Volcanic Rune)
    [40477] = true,  -- Volcanic Rune (Volcanic Rune)
    [40476] = true,  -- Volcanic Rune (Volcanic Rune)
    [40472] = true,  -- Volcanic Rune (Volcanic Rune)

    [40465] = true,  -- Scalding Rune (Scalding Rune)
    [40692] = true,  -- Scalding Rune (Scalding Rune)
    [40469] = true,  -- Scalding Rune (Scalding Rune)
    [40468] = true,  -- Scalding Rune (Scalding Rune)
    [40467] = true,  -- Scalding Rune (Scalding Rune)

    [31642] = true,  -- Equilibrium (Equilibrium)
    [48131] = true,  -- Equilibrium (Equilibrium)
    [97279] = true,  -- Equilibrium (Equilibrium)

    [40445] = true,  -- Spell Symmetry (Spell Symmetry)
    [40449] = true,  -- Spell Symmetry (Spell Symmetry)
    [48136] = true,  -- Spell Symmetry (Spell Symmetry)
    [97293] = true,  -- Equilibrium (Equilibrium)

    [40441] = true,  -- Balance (Balance)
    [80160] = true,  -- Major Resolve (Balance)
    [48141] = true,  -- Balance (Balance)
    [97297] = true,  -- Equilibrium (Equilibrium)

    [16536] = true,  -- Meteor (Meteor)
    [63430] = true,  -- Meteor (Meteor)
    [17912] = true,  -- Meteor (Meteor)
    [16538] = true,  -- Meteor Knockback (Meteor)
    [63429] = true,  -- Meteor (Meteor)
    [114701] = true, -- Stun (Meteor)

    [40489] = true,  -- Ice Comet (Ice Comet)
    [63456] = true,  -- Ice Comet (Ice Comet)
    [63457] = true,  -- Ice Comet (Ice Comet)
    [40492] = true,  -- Ice Comet (Ice Comet)
    [63455] = true,  -- Ice Comet Knockback (Ice Comet)
    [63454] = true,  -- Ice Comet (Ice Comet)
    [114714] = true, -- Stun (Ice Comet)

    [40493] = true,  -- Shooting Star (Shooting Star)
    [63474] = true,  -- Shooting Star (Shooting Star)
    [63472] = true,  -- Shooting Star (Shooting Star)
    [40495] = true,  -- Shooting Star (Shooting Star)
    [63473] = true,  -- Shooting Star (Shooting Star)
    [63471] = true,  -- Shooting Star (Shooting Star)
    [114715] = true, -- Stun (Shooting Star)
    [134553] = true, -- Shooting Star (Shooting Star)

    -------------------------------------
    -- PSIJIC ORDER PASSIVES ------------
    -------------------------------------

    [103793] = true, -- See the Unseen (See the Unseen - Rank 1)

    [103809] = true, -- Clairvoyance (Clairvoyance - Rank 1)
    [103811] = true, -- Clairvoyance (Clairvoyance - Rank 2)

    [103819] = true, -- Spell Orb (Spell Orb - Rank 1)
    [103820] = true, -- Spell Orb
    [103827] = true, -- Spell Orb
    [103878] = true, -- Spell Orb (Spell Orb - Rank 2)
    [103879] = true, -- Spell Orb
    [103880] = true, -- Spell Orb

    [103888] = true, -- Concentrated Barrier (Concentrated Barrier - Rank 1)
    [103923] = true, -- Concentrated Barrier
    [103942] = true, -- Concentrated Barrier
    [104313] = true, -- Concentrated Barrier

    [103964] = true, -- Concentrated Barrier (Concentrated Barrier - Rank 2)
    [103966] = true, -- Concentrated Barrier
    [103968] = true, -- Concentrated Barrier
    [104338] = true, -- Concentrated Barrier

    [103972] = true, -- Deliberation (Deliberation - Rank 1)

    -------------------------------------
    -- PSIJIC ORDER ACTIVES -------------
    -------------------------------------

    [103488] = true, -- Time Stop (Time Stop)
    [109176] = true, -- Time Stop (Time Stop)
    [103538] = true, -- Time Stop (Time Stop)
    [104007] = true, -- Time Stop (Time Stop)
    [104009] = true, -- Time Stop (Time Stop)
    [104050] = true, -- Time Stop (Time Stop)

    [104079] = true, -- Time Freeze (Time Freeze)
    [104122] = true, -- Time Freeze (Time Freeze)
    [109179] = true, -- Time Freeze (Time Freeze)
    [104080] = true, -- Time Freeze (Time Freeze)
    [104081] = true, -- Time Freeze (Time Freeze)
    [104082] = true, -- Time Freeze (Time Freeze)
    [104083] = true, -- Time Freeze (Time Freeze)
    [104085] = true, -- Time Freeze (Time Freeze)

    [104059] = true, -- Borrowed Time (Borrowed Time)
    [109178] = true, -- Borrowed Time (Borrowed Time)
    [104071] = true, -- Borrowed Time (Borrowed Time)
    [104072] = true, -- Borrowed Time (Borrowed Time)
    [104073] = true, -- Borrowed Time (Borrowed Time)
    [104075] = true, -- Borrowed Time (Borrowed Time)
    [104078] = true, -- Borrowed Time (Borrowed Time)

    [103483] = true, -- Imbue Weapon (Imbue Weapon)
    [103485] = true, -- Imbue Weapon (Imbue Weapon)
    [110420] = true, -- Imbue Weapon Restore (Imbue Weapon)

    [103571] = true, -- Elemental Weapon (Elemental Weapon)
    [103572] = true, -- Elemental Weapon (Elemental Weapon)
    [110421] = true, -- Elemental Weapon Restore (Elemental Weapon)

    [103623] = true, -- Crushing Weapon (Crushing Weapon)
    [103626] = true, -- Crushing Weapon (Crushing Weapon)
    [103628] = true, -- Crushing Weapon (Crushing Weapon)
    [110422] = true, -- Crushing Weapon Restore (Crushing Weapon)

    [103503] = true, -- Accelerate (Accelerate)
    [103520] = true, -- Major Expedition (Accelerate)
    [103521] = true, -- Minor Force (Accelerate)

    [103706] = true, -- Channeled Acceleration (Channeled Acceleration)
    [103707] = true, -- Major Expedition (Channeled Acceleration)
    [103708] = true, -- Minor Force (Channeled Acceleration)

    [103710] = true, -- Race Against Time (Race Against Time)
    [103711] = true, -- Major Expedition (Race Against Time)
    [103712] = true, -- Minor Force (Race Against Time)
    [122260] = true, -- Race Against Time (Race Against Time)

    [103543] = true, -- Mend Wounds (Mend Wounds)
    [107583] = true, -- Mend Wounds (Mend Wounds)
    [107579] = true, -- Mend Wounds (Mend Wounds)
    [118617] = true, -- Mend Wounds (Mend Wounds)

    [103747] = true, -- Mend Spirit (Mend Spirit)
    [107629] = true, -- Mend Spirit (Mend Spirit)
    [107632] = true, -- Major Resolve (Mend Spirit)
    [107630] = true, -- Mend Spirit (Mend Spirit)
    [103752] = true, -- Major Resolve (Mend Spirit)
    [118638] = true, -- Mend Spirit (Mend Spirit)

    [103755] = true, -- Symbiosis (Symbiosis)
    [107636] = true, -- Symbiosis (Symbiosis)
    [107637] = true, -- Symbiosis (Symbiosis)
    [107638] = true, -- Symbiosis (Symbiosis)
    [118645] = true, -- Symbiosis (Symbiosis)

    [103492] = true, -- Meditate (Meditate)
    [103493] = true, -- Snare (Meditate)
    [103499] = true, -- Meditate (Meditate)
    [103500] = true, -- Meditate (Meditate)
    [103501] = true, -- Meditate (Meditate)

    [103652] = true, -- Deep Thoughts (Deep Thoughts)
    [103653] = true, -- Deep Thoughts (Deep Thoughts)
    [103654] = true, -- Deep Thoughts (Deep Thoughts)
    [103655] = true, -- Deep Thoughts (Deep Thoughts)
    [103656] = true, -- Deep Thoughts (Deep Thoughts)

    [103665] = true, -- Introspection (Introspection)
    [103666] = true, -- Introspection (Introspection)
    [103667] = true, -- Introspection (Introspection)
    [103668] = true, -- Introspection (Introspection)
    [103669] = true, -- Introspection (Introspection)
    [103670] = true, -- Introspection (Introspection)

    [103478] = true, -- Undo (Undo)
    [108609] = true, -- Undo (Undo)
    [108615] = true, -- Undo (Undo)

    [103557] = true, -- Precognition (Precognition)
    [108621] = true, -- Precognition (Precognition)
    [108625] = true, -- Precognition (Precognition)
    [108626] = true, -- Precognition (Precognition)

    [103570] = true, -- Minor Protection (Temporal Guard)
    [103564] = true, -- Temporal Guard (Temporal Guard)
    [108641] = true, -- Temporal Guard (Temporal Guard)
    [108643] = true, -- Temporal Guard (Temporal Guard)

    -------------------------------------
    -- THIEVES GUILD PASSIVES -----------
    -------------------------------------

    [74580] = true, -- Finders Keepers (Rank 1)

    [76454] = true, -- Swiftly Forgotten (Rank 1)
    [76455] = true, -- Swiftly Forgotten II (Rank 2)
    [76456] = true, -- Swiftly Forgotten III (Rank 3)
    [76457] = true, -- Swiftly Forgotten IV (Rank 4)

    [76458] = true, -- Haggling (Rank 1)
    [76459] = true, -- Haggling II (Rank 2)
    [76460] = true, -- Haggling III (Rank 3)
    [76461] = true, -- Haggling IV (Rank 4)

    [76451] = true, -- Clemency (Rank 1)

    [76452] = true, -- Timely Escape (Rank 1)
    [77962] = true, -- Timely Escape Achievement
    [77963] = true, -- Timely Escape Achievement

    [76453] = true, -- Veil of Shadows (Rank 1)

    -------------------------------------
    -- UNDAUNTED PASSIVES ---------------
    -------------------------------------

    [55584] = true, -- Undaunted Command (Rank 1)
    [55606] = true, -- Undaunted Command
    [55607] = true, -- Undaunted Command Magicka Rest
    [55608] = true, -- Undaunted Command Stamina Rest
    [55676] = true, -- Undaunted Command (Rank 2)
    [55677] = true, -- Undaunted Command
    [55678] = true, -- Undaunted Command Magicka Rest
    [55679] = true, -- Undaunted Command Stamina Rest

    [55366] = true, -- Undaunted Mettle (Rank 1)
    [55386] = true, -- Undaunted Mettle (Rank 2)

    -------------------------------------
    -- UNDAUNTED ACTIVES ----------------
    -------------------------------------

    [108782] = true, -- Synergy Damage Bonus (Blood Altar - Blood Funnel Synergy)
    [39500] = true,  -- Blood Funnel (Blood Altar - Blood Funnel Synergy)
    [39501] = true,  -- Blood Funnel (Blood Altar - Blood Funnel Synergy)
    [39519] = true,  -- Blood Funnel (Blood Altar - Blood Funnel Synergy)
    [39521] = true,  -- Blood Funnel (Blood Altar - Blood Funnel Synergy)
    [80020] = true,  -- Minor Lifesteal (Blood Altar - All Morphs)
    [39489] = true,  -- Blood Altar (Blood Altar)
    [41328] = true,  -- Summon Shade (Blood Altar)
    [39493] = true,  -- Blood Altar (Blood Altar)

    [41967] = true,  -- Sanguine Altar (Sanguine Altar)
    [41970] = true,  -- Sanguine Altar (Sanguine Altar)
    [41969] = true,  -- Sanguine Altar (Sanguine Altar)

    [108787] = true, -- Synergy Damage Bonus (Overflowing Altar - Blood Feast Synergy)
    [41963] = true,  -- Blood Feast (Overflowing Altar - Blood Feast Synergy)
    [41964] = true,  -- Blood Feast (Overflowing Altar - Blood Feast Synergy)
    [41965] = true,  -- Blood Feast (Overflowing Altar - Blood Feast Synergy)
    [41966] = true,  -- Blood Feast (Overflowing Altar - Blood Feast Synergy)

    [41958] = true,  -- Overflowing Altar (Overflowing Altar)
    [41961] = true,  -- Overflowing Altar (Overflowing Altar)
    [41960] = true,  -- Overflowing Altar (Overflowing Altar)

    [39429] = true,  -- Spawn Broodling (Trapping Webs - Spawn Broodlings Synergy)
    [39451] = true,  -- Spawn Broodling (Trapping Webs - Spawn Broodlings Synergy)
    [41543] = true,  -- Summon Spider Spawn (Trapping Webs - Spawn Broodlings Synergy)
    [39430] = true,  -- Spawn Broodling (Trapping Webs - Spawn Broodlings Synergy)
    [77245] = true,  -- Bite (Trapping Webs - Spawn Broodlings Synergy)

    [80030] = true,  -- Only 1 Trapping Web (Trapping Webs - All Morphs)
    [39425] = true,  -- Trapping Webs (Trapping Webs)
    [80080] = true,  -- Trapping Webs (Trapping Webs)
    [102551] = true, -- Trapping Webs (Trapping Webs)
    [80079] = true,  -- Trapping Webs (Trapping Webs)
    [103242] = true, -- Trapping Webs (Trapping Webs)
    [126718] = true, -- Trapping Webs (Trapping Webs)
    [80083] = true,  -- Trapping Webs (Trapping Webs)
    [80078] = true,  -- Trapping Webs (Trapping Webs)

    [41994] = true,  -- Black Widow (Shadow Silk - Black Widows Synergy)
    [41997] = true,  -- Black Widow (Shadow Silk - Black Widows Synergy)
    [41998] = true,  -- Black Widow (Shadow Silk - Black Widows Synergy)
    [42000] = true,  -- Black Widow Poison (Shadow Silk - Black Widows Synergy)
    [42007] = true,  -- Black Widow Poison (Shadow Silk - Black Widows Synergy)

    [41990] = true,  -- Shadow Silk (Shadow Silk)
    [80105] = true,  -- Shadow Silk (Shadow Silk)
    [103263] = true, -- Trapping Webs (Shadow Silk)
    [80108] = true,  -- Shadow Silk (Shadow Silk)
    [41993] = true,  -- Shadow Silk (Shadow Silk)
    [126720] = true, -- Shadow Silk (Shadow Silk)
    [80107] = true,  -- Shadow Silk (Shadow Silk)
    [41991] = true,  -- Shadow Silk (Shadow Silk)

    [42016] = true,  -- Arachnophobia (Tangling Webs - Arachnophobia Synergy)
    [42019] = true,  -- Arachnophobia (Tangling Webs - Arachnophobia Synergy)
    [42023] = true,  -- Arachnophobia (Tangling Webs - Arachnophobia Synergy)
    [42020] = true,  -- Arachnophobia (Tangling Webs - Arachnophobia Synergy)

    [42012] = true,  -- Tangling Webs (Tangling Webs)
    [80127] = true,  -- Tangling Webs (Tangling Webs)
    [103268] = true, -- Trapping Webs (Tangling Webs)
    [80130] = true,  -- Tangling Webs (Tangling Webs)
    [42015] = true,  -- Tangling Webs (Tangling Webs)
    [126722] = true, -- Tangling Webs (Tangling Webs)
    [80129] = true,  -- Tangling Webs (Tangling Webs)
    [42013] = true,  -- Tangling Webs (Tangling Webs)

    [41838] = true,  -- Radiate (Inner Fire - Radiate Synergy)
    [41840] = true,  -- Radiate (Inner Fire - Radiate Synergy)
    [41839] = true,  -- Radiate (Inner Fire - Radiate Synergy)

    [39475] = true,  -- Inner Fire (Inner Fire)
    [39481] = true,  -- Inner Fire (Inner Fire)
    [39480] = true,  -- Inner Fire (Inner Fire)

    [42056] = true,  -- Inner Rage (Inner Rage)
    [42058] = true,  -- Inner Rage (Inner Rage)
    [42057] = true,  -- Inner Rage (Inner Rage)

    [42060] = true,  -- Inner Rage (Inner Beast)
    [42062] = true,  -- Inner Rage (Inner Beast)
    [42063] = true,  -- Inner Rage (Inner Beast)
    [42061] = true,  -- Inner Rage (Inner Beast)

    [39379] = true,  -- Bone Wall (Bone Shield - Bone Wall Synergy)
    [39424] = true,  -- Bone Wall (Bone Shield - Bone Wall Synergy)

    [39369] = true,  -- Bone Shield (Bone Shield)
    [39376] = true,  -- Bone Shield (Bone Shield)
    [39375] = true,  -- Bone Shield (Bone Shield)

    [42138] = true,  -- Spiked Bone Shield (Spiked Bone Shield)
    [42141] = true,  -- Spiked Bone Shield (Spiked Bone Shield)
    [42140] = true,  -- Spiked Bone Shield (Spiked Bone Shield)
    [42139] = true,  -- Spiked Bone Shield (Spiked Bone Shield)

    [42198] = true,  -- Spinal Surge (Bone Surge - Spinal Surge Synergy)
    [42197] = true,  -- Major Vitality (Bone Surge - Spinal Surge Synergy)
    [42196] = true,  -- Spinal Surge (Bone Surge - Spinal Surge Synergy)

    [42176] = true,  -- Bone Surge (Bone Surge)
    [42193] = true,  -- Bone Surge (Bone Surge)
    [42192] = true,  -- Bone Surge (Bone Surge)

    [39301] = true,  -- Combustion (Necrotic Orb - Combustion Synergy)
    [85434] = true,  -- Spear Shards / Necrotic Orb CD (Necrotic Orb - Combustion Synergy)
    [95039] = true,  -- Combustion (Necrotic Orb - Combustion Synergy)
    [95040] = true,  -- Combustion (Necrotic Orb - Combustion Synergy)
    [85431] = true,  -- Combustion (Necrotic Orb - Combustion Synergy)
    [85432] = true,  -- Combustion (Necrotic Orb - Combustion Synergy)

    [39298] = true,  -- Necrotic Orb (Necrotic Orb)
    [127329] = true, -- Necrotic Orb (Necrotic Orb)
    [39299] = true,  -- Necrotic Orb (Necrotic Orb)
    [39300] = true,  -- Necrotic Orb (Necrotic Orb)

    [42028] = true,  -- Mystic Orb (Mystic Orb)
    [127331] = true, -- Mystic Orb (Mystic Orb)
    [42029] = true,  -- Mystic Orb (Mystic Orb)
    [42030] = true,  -- Mystic Orb (Mystic Orb)

    [108802] = true, -- Synergy Damage Bonus (Energy Orb - Healing Combustion Synergy)
    [63507] = true,  -- Healing Combustion (Energy Orb - Healing Combustion Synergy)
    [63512] = true,  -- Spear Shards / Necrotic Orb CD (Energy Orb - Healing Combustion Synergy)
    [95041] = true,  -- Combustion (Energy Orb - Healing Combustion Synergy)
    [95042] = true,  -- Combustion (Energy Orb - Healing Combustion Synergy)
    [67797] = true,  -- Combustion (Energy Orb - Healing Combustion Synergy)
    [63511] = true,  -- Combustion (Energy Orb - Healing Combustion Synergy)

    [42038] = true,  -- Energy Orb (Energy Orb)
    [127332] = true, -- Energy Orb (Energy Orb)
    [42039] = true,  -- Energy Orb (Energy Orb)
    [42040] = true,  -- Energy Orb (Energy Orb)

    -------------------------------------
    -- ASSAULT PASSIVES -----------------
    -------------------------------------

    [39248] = true, -- Continuous Attack (Rank 1)
    [39249] = true, -- Continuous Attack
    [45614] = true, -- Continuous Attack (Rank 2)
    [45617] = true, -- Continuous Attack
    [39254] = true, -- Reach (Rank 1)
    [45621] = true, -- Reach (Rank 2)
    [39252] = true, -- Combat Frenzy (Rank 1)
    [39253] = true, -- Combat Frenzy
    [45619] = true, -- Combat Frenzy (Rank 2)
    [45620] = true, -- Combat Frenzy

    -------------------------------------
    -- ASSAULT ACTIVES ------------------
    -------------------------------------

    [38566] = true,  -- Rapid Maneuver (Rapid Maneuver)
    [101161] = true, -- Major Expedition (Rapid Maneuver)

    [40211] = true,  -- Retreating Maneuver (Retreating Maneuver)
    [101169] = true, -- Major Expedition (Retreating Maneuver)

    [40215] = true,  -- Charging Maneuver (Charging Maneuver)
    [101178] = true, -- Major Expedition (Charging Maneuver)
    [40219] = true,  -- Minor Expedition (Charging Maneuver)

    [61503] = true,  -- Vigor (Vigor)
    [61504] = true,  -- Vigor (Vigor)

    [61505] = true,  -- Echoing Vigor (Echoing Vigor)
    [61506] = true,  -- Echoing Vigor (Echoing Vigor)

    [61507] = true,  -- Resolving Vigor (Resolving Vigor)
    [61509] = true,  -- Resolving Vigor (Resolving Vigor)

    [33376] = true,  -- Caltrops (Caltrops)
    [38548] = true,  -- Spear Shards (Caltrops)
    [38549] = true,  -- Caltrops (Caltrops)
    [38553] = true,  -- Spear Shards (Caltrops)
    [38561] = true,  -- Caltrops (Caltrops)
    [113769] = true, -- Caltrops (Caltrops)

    [40255] = true,  -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [40257] = true,  -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [40265] = true,  -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [40263] = true,  -- Spear Shards (Anti-Cavalry Caltrops)
    [40267] = true,  -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [40266] = true,  -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [113770] = true, -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)

    [40242] = true,  -- Razor Caltrops (Razor Caltrops)
    [40244] = true,  -- Razor Caltrops (Razor Caltrops)
    [40251] = true,  -- Caltrops (Razor Caltrops)
    [40249] = true,  -- Spear Shards (Razor Caltrops)
    [40254] = true,  -- Major Breach (Razor Caltrops)
    [40252] = true,  -- Razor Caltrops (Razor Caltrops)
    [113771] = true, -- Razor Caltrops (Razor Caltrops)

    [61487] = true,  -- Magicka Detonation (Magicka Detonation)
    [61490] = true,  -- FX DUMMY (Magicka Detonation)
    [66482] = true,  -- Magicka Detonation (Magicka Detonation)
    [61488] = true,  -- Magicka Detonation (Magicka Detonation)

    [61491] = true,  -- Inevitable Detonation (Inevitable Detonation)
    [61492] = true,  -- FX DUMMY (Inevitable Detonation)
    [66491] = true,  -- Magicka Detonation (Inevitable Detonation)
    [61493] = true,  -- Inevitable Detonation (Inevitable Detonation)

    [61500] = true,  -- Proximity Detonation (Proximity Detonation)
    [61501] = true,  -- FX DUMMY (Proximity Detonation)
    [66499] = true,  -- Magicka Detonation (Proximity Detonation)
    [61502] = true,  -- Proximity Detonation (Proximity Detonation)

    [38563] = true,  -- War Horn (War Horn)
    [38564] = true,  -- War Horn (War Horn)
    [94080] = true,  -- War Horn (War Horn)

    [40223] = true,  -- Aggressive Horn (Aggressive Horn)
    [40224] = true,  -- Aggressive Horn (Aggressive Horn)
    [94800] = true,  -- Aggressive Horn (Aggressive Horn)
    [40225] = true,  -- Major Force (Aggressive Horn)

    [40220] = true,  -- Sturdy Horn (Sturdy Horn)
    [40221] = true,  -- Sturdy Horn (Sturdy Horn)
    [63571] = true,  -- Sturdy Horn (Sturdy Horn)
    [95094] = true,  -- Sturdy (Sturdy Horn)

    -------------------------------------
    -- SUPPORT PASSIVES -----------------
    -------------------------------------

    [39255] = true, -- Magicka Aid (Rank 1)
    [45622] = true, -- Magicka Aid (Rank 2)
    [39259] = true, -- Combat Medic (Rank 1)
    [45624] = true, -- Combat Medic (Rank 2)
    [39261] = true, -- Battle Resurrection (Rank 1)
    [45625] = true, -- Battle Resurrection (Rank 2)

    -------------------------------------
    -- SUPPORT ACTIVES ------------------
    -------------------------------------

    [41735] = true, -- Only 1 Siege Shield (Siege Shield - All Morphs)
    [38570] = true, -- Siege Shield (Siege Shield)
    [39844] = true, -- Siege Shield (Siege Shield)

    [40229] = true, -- Siege Weapon Shield (Siege Weapon Shield)
    [40231] = true, -- Siege Weapon Shield (Siege Weapon Shield)
    [40230] = true, -- Siege Weapon Shield (Siege Weapon Shield)

    [40226] = true, -- Propelling Shield (Propelling Shield)
    [40227] = true, -- Propelling Shield (Propelling Shield)

    [38571] = true, -- Purge (Purge)

    [40232] = true, -- Efficient Purge (Efficient Purge)

    [40234] = true, -- Cleanse (Cleanse)
    [40236] = true, -- Cleanse (Cleanse)

    [61511] = true, -- Guard (Guard)
    [80923] = true, -- Guard (Guard)
    [78338] = true, -- Guard (Guard)
    [80926] = true, -- Guard Saved Damage Value (Guard)

    [61536] = true, -- Mystic Guard (Mystic Guard)
    [80947] = true, -- Mystic Guard (Mystic Guard)
    [80953] = true, -- Minor Vitality (Mystic Guard)
    [64080] = true, -- Minor Vitality (Mystic Guard)
    [81415] = true, -- Guard (Mystic Guard)
    [80950] = true, -- Guard Saved Damage Value (Mystic Guard)

    [61529] = true, -- Stalwart Guard (Stalwart Guard)
    [80983] = true, -- Stalwart Guard (Stalwart Guard)
    [80984] = true, -- Minor Force (Stalwart Guard)
    [80986] = true, -- Minor Force (Stalwart Guard)
    [81420] = true, -- Guard (Stalwart Guard)
    [80988] = true, -- Guard Saved Damage Value (Stalwart Guard)

    [61489] = true, -- Revealing Flare (Revealing Flare)
    [61497] = true, -- Revealing Flare (Revealing Flare)
    [61498] = true, -- Revealing Flare (Revealing Flare)
    [61496] = true, -- Revealing Flare (Revealing Flare)

    [61519] = true, -- Lingering Flare (Lingering Flare)
    [61523] = true, -- Nova (Lingering Flare)
    [61522] = true, -- Nova (Lingering Flare)
    [61521] = true, -- Lingering Flare (Lingering Flare)

    [61524] = true, -- Blinding Flare (Blinding Flare)
    [61527] = true, -- Nova (Blinding Flare)
    [61526] = true, -- Nova (Blinding Flare)
    [61528] = true, -- Blinding Flare (Blinding Flare)
    [77974] = true, -- Blinding Flare (Blinding Flare)

    [38573] = true, -- Barrier (Barrier)

    [40237] = true, -- Reviving Barrier (Reviving Barrier)
    [40238] = true, -- Reviving Barrier (Reviving Barrier Heal)

    [40239] = true, -- Replenishing Barrier (Replenishing Barrier)
    [40240] = true, -- Replenishing Barrier (Replenishing Barrier)
    [40241] = true, -- Replenishing Barrier (Replenishing Barrier)

    -------------------------------------
    -- EMPEROR PASSIVES -----------------
    -------------------------------------

    [39625] = true, -- Monarch
    [39630] = true, -- Authority
    [39644] = true, -- Domination
    [39647] = true, -- Tactician
    [39641] = true, -- Emperor

    -------------------------------------
    -- RACIALS --------------------------
    -------------------------------------

    -- Breton
    [36247] = true, -- Opportunist (Rank 1)
    [35995] = true, -- Gift of Magnus (Rank 1)
    [45259] = true, -- Gift of Magnus (Rank 2)
    [45260] = true, -- Gift of Magnus (Rank 3)
    [36266] = true, -- Spell Resistance (Rank 1)
    [45261] = true, -- Spell Resistance (Rank 2)
    [45262] = true, -- Spell Resistance (Rank 3)
    [36303] = true, -- Magicka Mastery (Rank 1)
    [45263] = true, -- Magicka Mastery (Rank 2)
    [45264] = true, -- Magicka Mastery (Rank 3)

    -- Orc (Orsimer)
    [33293] = true,  -- Craftsman (Rank 1)
    [33301] = true,  -- Brawny (Rank 1)
    [45307] = true,  -- Brawny (Rank 2)
    [45309] = true,  -- Brawny (Rank 3)
    [84668] = true,  -- Unflinching Rage (Rank 1)
    [118196] = true, -- Unflinching Rage (Rank 1)
    [84670] = true,  -- Unflinching Rage (Rank 2)
    [118203] = true, -- Unflinching Rage (Rank 2)
    [84672] = true,  -- Unflinching Rage (Rank 3)
    [118206] = true, -- Unflinching Rage (Rank 3)
    [33304] = true,  -- Swift Warrior (Rank 1)
    [45311] = true,  -- Swift Warrior (Rank 2)
    [45312] = true,  -- Swift Warrior (Rank 3)

    -- Redguard
    [84680] = true,  -- Wayfarer (Rank 1)
    [36009] = true,  -- Martial Training (Rank 1)
    [45277] = true,  -- Martial Training (Rank 2)
    [45278] = true,  -- Martial Training (Rank 3)
    [117752] = true, -- Conditioning (Rank 1)
    [117753] = true, -- Conditioning (Rank 2)
    [117754] = true, -- Conditioning (Rank 3)
    [36546] = true,  -- Adrenaline Rush (Rank 1)
    [36548] = true,  -- Adrenaline Rush
    [45313] = true,  -- Adrenaline Rush (Rank 2)
    [45314] = true,  -- Adrenaline Rush
    [45315] = true,  -- Adrenaline Rush (Rank 3)
    [45316] = true,  -- Adrenaline Rush

    -- High Elf (Altmer)
    [35965] = true,  -- Highborn (Rank 1)
    [35993] = true,  -- Spell Recharge (Rank 1)
    [118110] = true, -- Spell Recharge (Rank 1)
    [118111] = true, -- Spell Recharge (Rank 1)
    [45273] = true,  -- Spell Recharge (Rank 2)
    [118113] = true, -- Spell Recharge (Rank 2)
    [118114] = true, -- Spell Recharge (Rank 2)
    [45274] = true,  -- Spell Recharge (Rank 3)
    [118116] = true, -- Spell Recharge (Rank 3)
    [118117] = true, -- Spell Recharge (Rank 3)
    [117968] = true, -- Syrabane's Boon (Rank 1)
    [117969] = true, -- Syrabane's Boon (Rank 2)
    [117970] = true, -- Syrabane's Boon (Rank 3)
    [35998] = true,  -- Elemental Talent (Rank 1)
    [45275] = true,  -- Elemental Talent (Rank 2)
    [45276] = true,  -- Elemental Talent (Rank 3)

    -- Wood Elf (Bosmer)
    [36008] = true, -- Acrobat (Rank 1)
    [36022] = true, -- Hunter's Eye (Rank 1)
    [45295] = true, -- Hunter's Eye (Rank 2)
    [45296] = true, -- Hunter's Eye (Rank 3)
    [64279] = true, -- Y'ffre's Endurance (Rank 1)
    [64280] = true, -- Y'ffre's Endurance (Rank 2)
    [64281] = true, -- Y'ffre's Endurance (Rank 3)
    [36011] = true, -- Resist Affliction (Rank 1)
    [45317] = true, -- Resist Affliction (Rank 2)
    [45319] = true, -- Resist Affliction (Rank 3)

    -- Khajiit
    [36063] = true,  -- Cutpurse (Rank 1)
    [70386] = true,  -- Nimble (Rank 1)
    [70388] = true,  -- Nimble (Rank 2)
    [70390] = true,  -- Nimble (Rank 3)
    [117846] = true, -- Lunar Blessings (Rank 1)
    [117847] = true, -- Lunar Blessings (Rank 2)
    [117848] = true, -- Lunar Blessings (Rank 3)
    [36067] = true,  -- Carnage (Rank 1)
    [45299] = true,  -- Carnage (Rank 2)
    [45301] = true,  -- Carnage (Rank 3)

    -- Argonian
    [36582] = true, -- Amphibian (Rank 1)
    [36568] = true, -- Resourceful (Rank 1)
    [49151] = true, -- Resourceful (Rank 1)
    [63694] = true, -- Resourceful
    [63695] = true, -- Resourceful
    [63696] = true, -- Resourceful
    [45243] = true, -- Resourceful (Rank 2)
    [63700] = true, -- Resourceful (Rank 2)
    [63697] = true, -- Resourceful
    [63698] = true, -- Resourceful
    [63699] = true, -- Resourceful
    [45247] = true, -- Resourceful (Rank 3)
    [63704] = true, -- Resourceful (Rank 3)
    [63701] = true, -- Resourceful
    [63702] = true, -- Resourceful
    [63703] = true, -- Resourceful
    [36583] = true, -- Argonian Resistance (Rank 1)
    [45253] = true, -- Argonian Resistance (Rank 2)
    [45255] = true, -- Argonian Resistance (Rank 3)
    [36585] = true, -- Quick Mend (Rank 1)
    [45257] = true, -- Quick Mend (Rank 2)
    [45258] = true, -- Quick Mend (Rank 3)

    -- Dark Elf (Dunmer)
    [36588] = true, -- Ashlander (Rank 1)
    [36591] = true, -- Dynamic (Rank 1)
    [45265] = true, -- Dynamic (Rank 2)
    [45267] = true, -- Dynamic (Rank 3)
    [36593] = true, -- Resist Flame (Rank 1)
    [45269] = true, -- Resist Flame (Rank 2)
    [45270] = true, -- Resist Flame (Rank 3)
    [36598] = true, -- Destructive Ancestry (Rank 1)
    [45271] = true, -- Destructive Ancestry (Rank 2)
    [45272] = true, -- Destructive Ancestry (Rank 3)

    -- Nord
    [36626] = true,  -- Reveler (Rank 1)
    [36064] = true,  -- Stalwart (Rank 1)
    [118182] = true, -- Stalwart (Rank 1)
    [45297] = true,  -- Stalwart (Rank 2)
    [118184] = true, -- Stalwart (Rank 2)
    [45298] = true,  -- Stalwart (Rank 3)
    [118186] = true, -- Stalwart (Rank 3)
    [36627] = true,  -- Resist Frost (Rank 1)
    [45303] = true,  -- Resist Frost (Rank 2)
    [45304] = true,  -- Resist Frost (Rank 3)
    [36628] = true,  -- Rugged (Rank 1)
    [45305] = true,  -- Rugged (Rank 2)
    [45306] = true,  -- Rugged (Rank 3)

    -- Imperial
    [36312] = true, -- Diplomat (Rank 1)
    [50903] = true, -- Tough (Rank 1)
    [50906] = true, -- Tough (Rank 2)
    [50907] = true, -- Tough (Rank 3)
    [36153] = true, -- Imperial Mettle (Rank 1)
    [45279] = true, -- Imperial Mettle (Rank 2)
    [45280] = true, -- Imperial Mettle (Rank 3)
    [36155] = true, -- Red Diamond (Rank 1)
    [45291] = true, -- Red Diamond (Rank 2)
    [45293] = true, -- Red Diamond (Rank 3)

    -------------------------------------
    -- CRAFTING  ------------------------
    -------------------------------------

    -- Alchemy
    [45542] = true, -- Solvent Proficiency (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [45547] = true, -- Solvent Proficiency (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [45550] = true, -- Solvent Proficiency (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [45551] = true, -- Solvent Proficiency (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion
    [45552] = true, -- Solvent Proficiency (Rank 5) -- NOTE: No actual aura or event displayed for this, listed for completion
    [49163] = true, -- Solvent Proficiency (Rank 6) -- NOTE: No actual aura or event displayed for this, listed for completion
    [70042] = true, -- Solvent Proficiency (Rank 7) -- NOTE: No actual aura or event displayed for this, listed for completion
    [70043] = true, -- Solvent Proficiency (Rank 8) -- NOTE: No actual aura or event displayed for this, listed for completion

    [47840] = true, -- Keen Eye: Reagents (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47841] = true, -- Keen Eye: Reagents (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47842] = true, -- Keen Eye: Reagents (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [45569] = true, -- Medicinal Use (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [45571] = true, -- Medicinal Use (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [45573] = true, -- Medicinal Use (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [45577] = true, -- Chemistry (Rank 1)
    [45578] = true, -- Chemistry (Rank 2)
    [45579] = true, -- Chemistry (Rank 3)

    [45555] = true, -- Laboratory Use (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion

    [47831] = true, -- Snakeblood (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47832] = true, -- Snakeblood (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47834] = true, -- Snakeblood (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    -- Blacksmithing
    [47276] = true, -- Metalworking (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47277] = true, -- Metalworking (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47278] = true, -- Metalworking (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47279] = true, -- Metalworking (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47280] = true, -- Metalworking (Rank 5) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47281] = true, -- Metalworking (Rank 6) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48157] = true, -- Metalworking (Rank 7) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48158] = true, -- Metalworking (Rank 8) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48159] = true, -- Metalworking (Rank 9) -- NOTE: No actual aura or event displayed for this, listed for completion
    [70041] = true, -- Metalworking (Rank 10) -- NOTE: No actual aura or event displayed for this, listed for completion

    [47854] = true, -- Keen Eye: Ore (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47855] = true, -- Keen Eye: Ore (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47856] = true, -- Keen Eye: Ore (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48169] = true, -- Miner Hireling (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48170] = true, -- Miner Hireling (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48171] = true, -- Miner Hireling (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48163] = true, -- Metal Extraction (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48164] = true, -- Metal Extraction (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48165] = true, -- Metal Extraction (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48160] = true, -- Metallurgy (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48161] = true, -- Metallurgy (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48162] = true, -- Metallurgy (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [58784] = true, -- Metallurgy (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48166] = true, -- Temper Expertise (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48167] = true, -- Temper Expertise (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48168] = true, -- Temper Expertise (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    -- Clothing
    [47288] = true, -- Tailoring (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47289] = true, -- Tailoring (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47290] = true, -- Tailoring (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47291] = true, -- Tailoring (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47292] = true, -- Tailoring (Rank 5) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47293] = true, -- Tailoring (Rank 6) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48187] = true, -- Tailoring (Rank 7) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48188] = true, -- Tailoring (Rank 8) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48189] = true, -- Tailoring (Rank 9) -- NOTE: No actual aura or event displayed for this, listed for completion
    [70044] = true, -- Tailoring (Rank 10) -- NOTE: No actual aura or event displayed for this, listed for completion

    [47860] = true, -- Keen Eye: Cloth (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47861] = true, -- Keen Eye: Cloth (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47862] = true, -- Keen Eye: Cloth (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48199] = true, -- Outfitter Hireling (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48200] = true, -- Outfitter Hireling (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48201] = true, -- Outfitter Hireling (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48193] = true, -- Unraveling (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48194] = true, -- Unraveling (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48195] = true, -- Unraveling (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48190] = true, -- Stitching (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48191] = true, -- Stitching (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48192] = true, -- Stitching (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [58782] = true, -- Stitching (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48196] = true, -- Tannin Expertise (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48197] = true, -- Tannin Expertise (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48198] = true, -- Tannin Expertise (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    -- Enchanting
    [46758] = true, -- Aspect Improvement (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46759] = true, -- Aspect Improvement (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46760] = true, -- Aspect Improvement (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46763] = true, -- Aspect Improvement (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [46727] = true, -- Potency Improvement (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46729] = true, -- Potency Improvement (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46731] = true, -- Potency Improvement (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46735] = true, -- Potency Improvement (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46736] = true, -- Potency Improvement (Rank 5) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46740] = true, -- Potency Improvement (Rank 6) -- NOTE: No actual aura or event displayed for this, listed for completion
    [49112] = true, -- Potency Improvement (Rank 7) -- NOTE: No actual aura or event displayed for this, listed for completion
    [49113] = true, -- Potency Improvement (Rank 8) -- NOTE: No actual aura or event displayed for this, listed for completion
    [49114] = true, -- Potency Improvement (Rank 9) -- NOTE: No actual aura or event displayed for this, listed for completion
    [70045] = true, -- Potency Improvement (Rank 10) -- NOTE: No actual aura or event displayed for this, listed for completion

    [47851] = true, -- Keen Eye: Rune Stones -- Keen Eye: Rune Stones (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47852] = true, -- Keen Eye: Rune Stones -- Keen Eye: Rune Stones (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47853] = true, -- Keen Eye: Rune Stones -- Keen Eye: Rune Stones (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [46770] = true, -- Hireling (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46771] = true, -- Hireling (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46772] = true, -- Hireling (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [46767] = true, -- Runestone Extraction (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46768] = true, -- Runestone Extraction (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [46769] = true, -- Runestone Extraction (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    -- Jewelry Crafting
    [103632] = true, -- Engraver (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103633] = true, -- Engraver (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103634] = true, -- Engraver (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103635] = true, -- Engraver (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103636] = true, -- Engraver (Rank 5) -- NOTE: No actual aura or event displayed for this, listed for completion

    [103637] = true, -- Keen Eye: Jewelry (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103638] = true, -- Keen Eye: Jewelry (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103639] = true, -- Keen Eye: Jewelry (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [103643] = true, -- Jewelry Extraction (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103644] = true, -- Jewelry Extraction (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103645] = true, -- Jewelry Extraction (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [103640] = true, -- Lapidary Research (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103641] = true, -- Lapidary Research (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103642] = true, -- Lapidary Research (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [108098] = true, -- Lapidary Research (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [103646] = true, -- Platings Expertise (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103647] = true, -- Platings Expertise (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [103648] = true, -- Platings Expertise (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    -- Provisioning
    [44625] = true, -- Recipe Quality (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44630] = true, -- Recipe Quality (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44631] = true, -- Recipe Quality (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [69953] = true, -- Recipe Quality (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [44590] = true, -- Recipe Improvement (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44595] = true, -- Recipe Improvement (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44597] = true, -- Recipe Improvement (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44598] = true, -- Recipe Improvement (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44599] = true, -- Recipe Improvement (Rank 5) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44650] = true, -- Recipe Improvement (Rank 6) -- NOTE: No actual aura or event displayed for this, listed for completion

    [44602] = true, -- Gourmand (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44609] = true, -- Gourmand (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44610] = true, -- Gourmand (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [44612] = true, -- Connoisseur (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44614] = true, -- Connoisseur (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44615] = true, -- Connoisseur (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [44616] = true, -- Chef (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44617] = true, -- Chef (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44619] = true, -- Chef (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [44620] = true, -- Brewer (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44621] = true, -- Brewer (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44624] = true, -- Brewer (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [44634] = true, -- Hireling (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44640] = true, -- Hireling (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [44641] = true, -- Hireling (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    -- Woodworking
    [47282] = true, -- Woodworking (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47283] = true, -- Woodworking (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47284] = true, -- Woodworking (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47285] = true, -- Woodworking (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47286] = true, -- Woodworking (Rank 5) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47287] = true, -- Woodworking (Rank 6) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48172] = true, -- Woodworking (Rank 7) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48173] = true, -- Woodworking (Rank 8) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48174] = true, -- Woodworking (Rank 9) -- NOTE: No actual aura or event displayed for this, listed for completion
    [70046] = true, -- Woodworking (Rank 10) -- NOTE: No actual aura or event displayed for this, listed for completion

    [47857] = true, -- Keen Eye: Wood (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47858] = true, -- Keen Eye: Wood (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [47859] = true, -- Keen Eye: Wood (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48184] = true, -- Lumberjack Hireling (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48185] = true, -- Lumberjack Hireling (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48186] = true, -- Lumberjack Hireling (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48178] = true, -- Wood Extraction (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48179] = true, -- Wood Extraction (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48180] = true, -- Wood Extraction (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48181] = true, -- Carpentry (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48182] = true, -- Carpentry (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48183] = true, -- Carpentry (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion
    [58783] = true, -- Carpentry (Rank 4) -- NOTE: No actual aura or event displayed for this, listed for completion

    [48175] = true, -- Resin Expertise (Rank 1) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48176] = true, -- Resin Expertise (Rank 2) -- NOTE: No actual aura or event displayed for this, listed for completion
    [48177] = true, -- Resin Expertise (Rank 3) -- NOTE: No actual aura or event displayed for this, listed for completion

    -------------------------------------
    -- NPC ABILITIES (SHARED) -----------
    -------------------------------------

    -- GENERIC NPC COMBAT EVENTS
    [20542] = true, -- Prioritize Hit
    [38433] = true, -- Prioritize Hit
    [20546] = true, -- Prioritize Hit
    [94793] = true, -- Prioritize Hit
    [37360] = true, -- No Light Attacks
    [15160] = true, -- Monster Heavy Attack
    [31373] = true, -- Modify Shared CD Ability
    [46858] = true, -- Second Wind
    -- [82686] = true, -- AD (Area Denial) Shared Cool
    -- [28528] = true, -- Modify Clearing Move Cooldown
    [59100] = true, -- AI Range (Ranged Brute EXC)
    [29535] = true, -- Call to Ranged
    [36845] = true, -- Shadow Cloak Stun Remover
    [28931] = true, -- Set Surround Hide Run Away Abi
    [61933] = true, -- Remove

    -- SHARED NPC PASSIVES
    [33097] = true,  -- Scary Immunities -- Various NPC's
    [44176] = true,  -- Flying Immunities -- Various NPC's
    [13739] = true,  -- Backstabber -- Various NPC's
    [112296] = true, -- Increased Speed -- Dire Wolf + Sentinel
    [73768] = true,  -- GEN 5 Hits -- Various NPC's
    [73769] = true,  -- GEN 5 Hits -- Various NPC's
    [73772] = true,  -- GEN 5 Hits -- Various NPC's
    [79147] = true,  -- GEN 3 Hits -- Various NPC's
    [79148] = true,  -- GEN 3 Hits -- Various NPC's
    [79149] = true,  -- GEN 3 Hits -- Various NPC's
    [73916] = true,  -- GEN 2 Hits -- Various NPC's
    [73917] = true,  -- GEN 2 Hits -- Various NPC's
    [73919] = true,  -- GEN 2 Hits -- Various NPC's
    [88283] = true,  -- No Call Ally (is Ally) -- Summoner NPCs
    [88289] = true,  -- No Call Ally (Failed) -- Summoner NPCs
    [89175] = true,  -- No Call Ally 1:1 Ally Tracker -- Summoner NPCs
    [89176] = true,  -- No Call Ally -- Summoner NPCs
    [89177] = true,  -- No Call Ally -- Summoner NPCs

    -- SHARED NPC ACTIVE EVENTS
    [8239] = true,   -- Hamstrung -- Various NPC's
    [10845] = true,  -- Run Away! -- Humanoid NPC's
    [31813] = true,  -- Run Away! -- Humanoid NPC's
    [82703] = true,  -- Run Away! -- Humanoid NPC's
    [18386] = true,  -- Run Away! -- NPC (Mostly Creatures)
    [14249] = true,  -- Surround -- NPC (Mostly Animals)
    [134998] = true, -- Surround -- NPC (Mostly Animals)
    [135000] = true, -- Surround -- NPC (Mostly Animals)
    [135001] = true, -- Surround -- NPC (Mostly Animals)
    [135002] = true, -- Surround -- NPC (Mostly Animals)
    [135003] = true, -- Surround -- NPC (Mostly Animals)
    [135011] = true, -- Surround -- NPC (Mostly Animals)
    [135012] = true, -- Surround -- NPC (Mostly Animals)
    [135013] = true, -- Surround -- NPC (Mostly Animals)
    [135014] = true, -- Surround -- NPC (Mostly Animals)
    [135015] = true, -- Surround -- NPC (Mostly Animals)

    -- STANDARD NPC ABILITIES
    [2874] = true, -- Staggered

    -- CRITTER EVENTS
    [28890] = true, -- OnDeathFear -- Critter
    [2581] = true,  -- Flee -- Critter
    [79544] = true, -- Mischievous Dodge -- Nixad
    [79600] = true, -- Mischievous Dodge -- Nixad
    [79555] = true, -- Mischievous Dodge -- Nixad
    [79601] = true, -- Mischievous Dodge -- Nixad
    [79602] = true, -- Mischievous Dodge -- Nixad
    [79545] = true, -- Mischievous Dodge -- Nixad

    -- MONSTER FIGHT ABILITIES
    [9363] = true,  -- Generic 1 Dmg Monster No Push -- Monster Fight
    [9364] = true,  -- Monster Fight Immunities -- Monster Fight
    [40165] = true, -- Scene Choreo Brace -- Monster Fight
    [40190] = true, -- Roll Dodge -- Monster Fight
    [40193] = true, -- Roll Dodge -- Monster Fight
    [45611] = true, -- On Me -- Monster Fight
    [40120] = true, -- Quick Strike -- Monster Fight
    [40203] = true, -- Heavy Attack -- Monster Fight
    [44364] = true, -- Off-Balance Exploit -- Monster Fight

    -------------------------------------
    -- FRIENDLY NPC EVENTS --------------
    -------------------------------------

    [48279] = true, -- Quick Strike
    [48278] = true, -- Heavy Attack
    [39088] = true, -- Light Attack
    [39097] = true, -- Medium Attack
    [39101] = true, -- Heavy Attack
    [60703] = true, -- Fright Force
    [48330] = true, -- Aspect of Terror
    [48331] = true, -- Aspect of Terror
    [48342] = true, -- Quick Shot
    [48337] = true, -- Burning Arrow

    [42905] = true, -- Recover
    [42937] = true, -- TargetPriorityException
    [17500] = true, -- Generic Self PermaStun Kneel
    [57111] = true, -- Interactable Stand

    [4246] = true,  -- PC Duel Flag
    [4457] = true,  -- Duel On Self
    [4197] = true,  -- Recovering
    [4198] = true,  -- PC Duel Heal

    -- [48296] = true, -- Flare
    -- [48298] = true, -- Heat Wave
    -- [48299] = true, -- Heat Wave

    -------------------------------------
    -- JUSTICE NPCS ---------------------
    -------------------------------------

    [63424] = true,  -- JUST Guard Awarness (Guard)
    [63903] = true,  -- Guard Hit by CC
    [63153] = true,  -- Guard Immunities
    [63154] = true,  -- Guard Immunities
    [63163] = true,  -- Guard Speed Boost
    [63174] = true,  -- Guard Speed Boost
    [63168] = true,  -- Cage Talons
    [63180] = true,  -- JUST Used Talons Speed Boost
    [63182] = true,  -- Talons Boost 1
    [63186] = true,  -- JUST Guard Used Talons Speed B
    [63157] = true,  -- Heavy Blow
    [63268] = true,  -- Uppercut
    [63160] = true,  -- Heavy Blow Knockdown
    [63261] = true,  -- Heavy Blow
    [63265] = true,  -- Uppercut
    [63263] = true,  -- Heavy Blow Knockdown
    [64060] = true,  -- Block Guard CC
    [63145] = true,  -- Criminal's Bane
    [63148] = true,  -- Major Defile
    [63149] = true,  -- Criminal's Bane
    [63202] = true,  -- Criminal's Bane
    [63926] = true,  -- Pre-stack check
    [63095] = true,  -- Focused Strike
    [63093] = true,  -- Charge
    [63094] = true,  -- Shield Charge
    [63198] = true,  -- Fiery Chain
    [63199] = true,  -- Fiery Chain
    [63200] = true,  -- Firey Chain
    [63911] = true,  -- Guard Stacking Damage
    [64134] = true,  -- JUST Guard Evade
    [64150] = true,  -- JUST Death Timer

    [64152] = true,  -- JUST Unlock Death Bolts

    [63086] = true,  -- Guard Charge
    [63258] = true,  -- Guard Charge

    [64139] = true,  -- Piercing Bolt
    [64267] = true,  -- Focused Shot

    [63259] = true,  -- Charge
    [63260] = true,  -- Shield Charge

    [63179] = true,  -- Flame Shard
    [63194] = true,  -- Flame Shard
    [63197] = true,  -- Magma Prison

    [63905] = true,  -- Guard CC Break Timer
    [63906] = true,  -- Guard CC Break Anim
    [63904] = true,  -- Guard CC Immunity

    [78790] = true,  -- Seek
    [78793] = true,  -- Seek LOS
    [78802] = true,  -- Seek
    [78803] = true,  -- Seek
    [78804] = true,  -- Seek
    [78760] = true,  -- Confusion
    [78761] = true,  -- LOS Tar
    [78762] = true,  -- LOS Check
    [78764] = true,  -- Confusion
    [78775] = true,  -- Confusion
    [78767] = true,  -- Confusion
    [78768] = true,  -- Confusion
    [78769] = true,  -- Confusion
    [78770] = true,  -- Confusion
    [78766] = true,  -- Confusion
    [78772] = true,  -- Confusion
    [78771] = true,  -- Confusion
    [78765] = true,  -- Confusion

    [78743] = true,  -- Flare
    [78789] = true,  -- Flare
    [78750] = true,  -- Revealed
    [78746] = true,  -- Flare
    [78744] = true,  -- Flare

    [75613] = true,  -- Shadowcloak Immunity (Mage Guard)
    [77921] = true,  -- Clairvoyance Tutorial (Mage Guard)
    [77919] = true,  -- Clairvoyance Tutorial (Mage Guard)
    [77937] = true,  -- Clairvoyance (Mage Guard)
    [77941] = true,  -- Revealed
    [77943] = true,  -- Clairvoyance (Mage Guard)
    [77917] = true,  -- Empower Weapon: Flame (Mage Guard)
    [74502] = true,  -- Focused Strike (Mage Guard)
    [74503] = true,  -- Focused Strike (Mage Guard)
    [74504] = true,  -- Focused Strike (Mage Guard)
    [74862] = true,  -- Teleport Trap (Mage Guard)
    [74870] = true,  -- Teleport Trap (Mage Guard)
    [74867] = true,  -- Teleport Trap (Mage Guard)
    [74884] = true,  -- Teleport Trap (Mage Guard)
    [74885] = true,  -- Teleport Trap (Mage Guard)
    [74864] = true,  -- Teleport Trap (Mage Guard)
    [74863] = true,  -- Teleport Trap (Mage Guard)
    [74506] = true,  -- Encase (Mage Guard)
    [74522] = true,  -- Encase (Mage Guard)
    [74533] = true,  -- Encase (Mage Guard)
    [74534] = true,  -- Encase (Mage Guard)
    [74535] = true,  -- Encase (Mage Guard)
    [74536] = true,  -- Encase (Mage Guard)
    [74510] = true,  -- Encase (Mage Guard)
    [74996] = true,  -- Streak (Mage Guard)

    [77450] = true,  -- Clairvoyance Tutorial (Mage Guard - Instanced)
    [77449] = true,  -- Clairvoyance Tutorial (Mage Guard - Instanced)
    [72694] = true,  -- Clairvoyance (Mage Guard - Instanced)
    [72695] = true,  -- Revealed (Mage Guard - Instanced)
    [77444] = true,  -- Clairvoyance (Mage Guard - Instanced)
    [78060] = true,  -- Revealed (Mage Guard - Instanced)
    [75808] = true,  -- Guard Speed Boost (Mage Guard - Instanced)
    [75809] = true,  -- Guard Speed Boost (Mage Guard - Instanced)

    [54363] = true,  -- Halt (Guard)
    [63625] = true,  -- Arrest Stun (Guard)
    [148272] = true, -- Arrest Passenger Dismount (Guard)
    [64647] = true,  -- Remove Effects (Guard)

    [77452] = true,  -- Shadow Cloak Immunity (Basic Justice NPC)
    [78012] = true,  -- Quick Strike (Basic Justice NPC)
    [48321] = true,  -- CON_Bamf Out (Basic Justice NPC)
    [64161] = true,  -- Flee (Basic Justice NPC)
    [62472] = true,  -- Stab (Justice Rogue)
    [62506] = true,  -- Thrown Dagger (Justice Rogue)
    [78013] = true,  -- Quick Shot (Justice Archer)
    [62408] = true,  -- Bound Weapon (Justice Mage)
    [62409] = true,  -- Fiery Wind (Justice Mage)
    [62502] = true,  -- Fiery Wind (Justice Mage)
    [62407] = true,  -- Fiery Touch (Justice Mage)
    [61984] = true,  -- Invisibility Potion (Justice Mage)

    [78265] = true,  -- Alarm (Estate Marshal - DB)
    [80539] = true,  -- Alarm (Estate Marshal - DB)
    [67567] = true,  -- Generic Self Stun (Estate Marshal - DB)
    [78266] = true,  -- Alarm (Estate Marshal - DB)
    [78910] = true,  -- Alarm (Estate Marshal - DB)

    [73226] = true,  -- Hurried Ward (Mage Guard - DB)
    [73230] = true,  -- Hurried Ward (Mage Guard - DB)
    [73229] = true,  -- Hurried Ward (Mage Guard - DB)

    -------------------------------------
    -- TRAPS & ENVIRONMENTAL HAZARDS ----
    -------------------------------------

    [32236] = true,  -- Trap Regen Stopper Enemy (Generic Trap)

    [62230] = true,  -- Coldharbour Flames (Flame Trap)
    [62771] = true,  -- Coldharbour Flames (Flame Trap)
    [62769] = true,  -- Coldharbour Flames (Flame Trap)
    [62770] = true,  -- Coldharbour Flames (Flame Trap)

    [20886] = true,  -- Falling Rocks (Falling Rocks)
    [20888] = true,  -- Falling Rocks (Falling Rocks)
    [27479] = true,  -- Falling Rocks (Falling Rocks)

    [21940] = true,  -- Spike Trap (Spike Trap)
    [21943] = true,  -- Spike Trap (Spike Trap)
    [21941] = true,  -- Spike Trap Snare (Spike Trap)
    [21942] = true,  -- Trap Sprung (Spike Trap)

    [20482] = true,  -- Mistwatch Collapse
    [20483] = true,  -- Falling Rocks
    [29602] = true,  -- Falling Rocks

    [44180] = true,  -- Generic Flame Trap Warn
    [17198] = true,  -- Fire Trap (Player)
    [31606] = true,  -- Fire Trap (Player)
    [17314] = true,  -- Fire Trap (Player)

    [72887] = true,  -- Steam Burst (Fire)
    [72888] = true,  -- Fire Attack 1 (Fire)
    [72889] = true,  -- Fire Attack 2 (Fire)
    [72890] = true,  -- Laser Snare (Fire)

    [26530] = true,  -- Bear Trap (Bear Trap)
    [26531] = true,  -- Bear Trap (Bear Trap)

    [20258] = true,  -- Sigil of Frost (Sigil of Frost)
    [20260] = true,  -- Rune Burst (Sigil of Frost)
    [20259] = true,  -- Sigil of Frost Snare (Sigil of Frost)

    [33591] = true,  -- Fire (Fire)
    [33594] = true,  -- Fire (Fire)
    [49897] = true,  -- Fire (Fire)

    [27939] = true,  -- Bthzark Laser Beam (Generic Flame Wave Target)
    [27940] = true,  -- Laser Damage (Generic Flame Wave Shooter)
    [27943] = true,  -- Laser Snare (Generic Flame Wave Shooter)

    [28398] = true,  -- Generic Steam Warning (Steam Trap)
    [32244] = true,  -- Searing Steam (Steam Trap)
    [32245] = true,  -- Searing Steam (Steam Trap)
    [32246] = true,  -- Searing Steam (Steam Trap)

    [26039] = true,  -- Vent Steam (Steam Vent) -- Volenfell
    [26040] = true,  -- Steam Blast (Steam Vent) -- Volenfell
    [26088] = true,  -- Vent Steam (Steam Vent) -- Volenfell
    [26089] = true,  -- Steam Blast (Steam Vent) -- Volenfell
    [26090] = true,  -- Vent Steam (Steam Vent) -- Volenfell
    [26091] = true,  -- Steam Blast (Steam Vent) -- Volenfell
    [26076] = true,  -- Vent Steam (Steam Vent) -- Volenfell
    [26077] = true,  -- Steam Blast (Steam Vent) -- Volenfell

    [75810] = true,  -- Trap Regen Stopper (Gas Blossom) -- Housing
    [110416] = true, -- Putrid Cloud (Gas Blossom) -- Housing

    [110541] = true, -- Stunted Current (Static Pitcher) -- Housing
    [110542] = true, -- Stunted Current (Static Pitcher) -- Housing
    [111229] = true, -- Stunted Current (Static Pitcher) -- Housing
    [110576] = true, -- Stunted Current (Static Pitcher) -- Housing
    [110578] = true, -- Stunted Current (Static Pitcher) -- Housing

    [111256] = true, -- Surprise Attack (Lantern Mantis) -- Housing
    [113122] = true, -- Disarmed (Lantern Mantis) -- Housing
    [111347] = true, -- Surprise Attack (Lantern Mantis) -- Housing
    [111260] = true, -- Surprise Attack (Lantern Mantis) -- Housing
    [111348] = true, -- Surprise Attack (Lantern Mantis) -- Housing
    [111258] = true, -- Surprise Attack (Lantern Mantis) -- Housing
    [111261] = true, -- Surprise Attack (Lantern Mantis) -- Housing

    -- Elinhir Private Arena
    [117429] = true, -- Lava Eruption (Lava Trap)
    [117430] = true, -- Projectile (Lava Trap)
    [117431] = true, -- Lava Eruption (Lava Trap)
    [117433] = true, -- Projectile (Lava Trap)
    [117442] = true, -- Lava Eruption (Lava Trap)
    [117443] = true, -- Projectile (Lava Trap)
    [117428] = true, -- Lava Eruption (Lava Trap)
    [118438] = true, -- Major Breach (Lava Trap)

    [117482] = true, -- Shock Wall (Lightning Trap)
    [117600] = true, -- Shock Wall (Lightning Trap)
    [117620] = true, -- Lightning Trap (Lightning Trap)

    [117508] = true, -- Shock Wall (Lightning Trap)
    [117480] = true, -- Shock Wall (Lightning Trap)
    [117622] = true, -- Shock Wall (Lightning Trap)
    [117617] = true, -- Shock Wall (Lightning Trap)
    [117598] = true, -- Shock Wall (Lightning Trap)
    [117599] = true, -- Shock Wall (Lightning Trap)

    [117136] = true, -- Blade Trap (Blade Trap)
    [117140] = true, -- Move buff (Blade Trap)
    [117141] = true, -- Stun (Blade Trap)
    [117667] = true, -- Blade Despawn (Blade Trap)
    [117139] = true, -- Spinning Blade (Blade Trap)
    [117145] = true, -- Serrated Blade (Blade Trap)

    -- Slaughterfish / Lava
    [44029] = true,  -- Slaughterfish Attack (Slaughterfish)
    [66863] = true,  -- Slaughterfish Bonus (Slaughterfish)
    [44034] = true,  -- Slaughterfish Attack (Slaughterfish)
    [44039] = true,  -- Slaughterfish Attack (Slaughterfish)

    [113080] = true, -- Slaughterfish Attack (Slaughterfish - Cyrodiil)
    [113081] = true, -- Slaughterfish Bonus (Slaughterfish - Cyrodiil)
    [113082] = true, -- Slaughterfish Attack (Slaughterfish - Cyrodiil)
    [113083] = true, -- Slaughterfish Attack (Slaughterfish - Cyrodiil)

    [19224] = true,  -- In Lava (Lava - Halls of Torment)
    [19225] = true,  -- Lava Snare (Lava - Halls of Torment)
    [11338] = true,  -- In Lava (Lava - The Earth Forge)
    [11339] = true,  -- Lava Snare (Lava - The Earth Forge)

    [55923] = true,  -- Lava (Lava - City of Ash II)
    [56277] = true,  -- Lava (Lava - City of Ash II)
    [55925] = true,  -- Lava (Lava - City of Ash II)

    [5139] = true,   -- Lava (Dragonstar Arena)
    [5140] = true,   -- Lava (Dragonstar Arena)

    [72711] = true,  -- Hidden (Hiding Spot)
    [72712] = true,  -- Hiding Spot (Hiding Spot)
    [80262] = true,  -- Hiding Spot (Hiding Spot)
    [77335] = true,  -- Threat Drop (Hiding Spot)
    [77336] = true,  -- Threat Drop (Hiding Spot)
    [77337] = true,  -- Threat Drop (Hiding Spot)
    [77338] = true,  -- Threat Drop (Hiding Spot)
    [77339] = true,  -- Threat Drop (Hiding Spot)
    [75670] = true,  -- Threat Drop (Hiding Spot)
    [75747] = true,  -- Hiding Spot (Hiding Spot)

    -------------------------------------
    -- HUMANOID NPCS --------------------
    -------------------------------------

    [10618] = true, -- Quick Strike -- Shared
    [12437] = true, -- Quick Shot -- Shared
    [12456] = true, -- Ice Arrow -- Shared
    [10639] = true, -- Flare -- Shared
    [11604] = true, -- Is Fire Ranged -- Shared
    [43768] = true, -- Health Potion -- Shared
    [44471] = true, -- Roll Dodge -- Shared
    [44477] = true, -- Roll Dodge -- Shared
    [44480] = true, -- Roll Dodge -- Shared
    [44479] = true, -- Roll Left -- Shared
    [44482] = true, -- Roll Right -- Shared
    [39058] = true, -- Bear Trap -- Shared
    [39060] = true, -- Bear Trap -- Shared
    [39065] = true, -- Bear Trap -- Shared
    [40070] = true, -- Bear Trap -- Shared
    [64750] = true, -- Briarheart Set Resurrectable -- Shared

    [10648] = true, -- Throw Oil -- Synergies (Footsoldier)
    [11039] = true, -- Spread Out Sound -- Synergies (Footsoldier)
    [10824] = true, -- Oil Up -- Synergies (Footsoldier)
    [11016] = true, -- Throw Oil -- Synergies (Footsoldier)
    [10650] = true, -- Oil Drenched -- Synergies (Footsoldier)
    [12439] = true, -- Burning Arrow -- Synergies (Archer)
    [14068] = true, -- Ignite -- Synergies (Archer)
    [14070] = true, -- Ignite -- Synergies (Archer)
    [10805] = true, -- Ignite -- Synergies (Fire Mage)
    [10814] = true, -- Ignite -- Synergies (Fire Mage)
    [10809] = true, -- Ignite -- Synergies (Fire Mage)
    [10825] = true, -- Ignite -- Synergies (Fire Mage)
    [10813] = true, -- Ignite -- Synergies (Fire Mage)
    [38261] = true, -- Ignite -- Synergies (Fire Mage)
    [38262] = true, -- Ignite -- Synergies (Fire Mage)
    [38260] = true, -- Ignite -- Synergies (Fire Mage)

    -- [31387] = true, -- Necromancer Synergy Kill Self (Cultist)
    -- [43756] = true, -- Necromancer Synergy Kill Self (Cultist)

    [14096] = true,  -- Heavy Attack -- Footsoldier
    [27683] = true,  -- Step Back -- Footsoldier
    [28499] = true,  -- Throw Dagger -- Footsoldier
    [28502] = true,  -- Throw Dagger -- Footsoldier
    [28504] = true,  -- Throw Dagger -- Footsoldier

    [29400] = true,  -- Power Bash -- Guard
    [29401] = true,  -- Power Bash -- Guard
    [29402] = true,  -- Power Bash -- Guard
    [29761] = true,  -- Brace -- Guard
    [29759] = true,  -- Brace Snare -- Guard
    [29762] = true,  -- Blocked Stack -- Guard
    [29757] = true,  -- Remove block -- Guard
    [84351] = true,  -- Remove block -- Guard
    [29766] = true,  -- Blocked Stack -- Guard
    [29765] = true,  -- Uber Attack -- Guard
    [29767] = true,  -- Uber Attack -- Guard
    [84346] = true,  -- Uber Attack -- Guard

    [34917] = true,  -- Low Slash -- Brute
    [34919] = true,  -- Low Slash -- Brute
    [13705] = true,  -- ready for rush -- Brute
    [42832] = true,  -- ready for rush -- Brute
    [13701] = true,  -- Focused Charge -- Brute
    [14924] = true,  -- Focused Charge -- Brute
    [66623] = true,  -- charge stun cleanup -- Brute
    [48542] = true,  -- Focused Charge -- Brute
    [48543] = true,  -- Charge -- Brute
    [14935] = true,  -- Charge -- Brute
    [14925] = true,  -- Charge -- Brute
    [14926] = true,  -- Charge -- Brute
    [14921] = true,  -- Charge -- Brute
    [14930] = true,  -- Charge -- Brute
    [14922] = true,  -- Charge -- Brute
    [14923] = true,  -- Charge -- Brute

    [26308] = true,  -- Cleave -- Ravager
    [29378] = true,  -- Uppercut -- Ravager
    [29379] = true,  -- Uppercut -- Ravager
    [29380] = true,  -- Uppercut -- Ravager

    [29035] = true,  -- Quick Strike -- Rogue/Skirmisher
    [12381] = true,  -- Assassinate -- Rogue/Skirmisher
    [28408] = true,  -- Whirlwind -- Rogue/Skirmisher
    [85339] = true,  -- Whirlwind -- Rogue/Skirmisher
    [45508] = true,  -- Passing Through -- Rogue/Skirmisher
    [67928] = true,  -- Passing Through Immunity -- Rogue/Skirmisher
    [67938] = true,  -- Kill Me -- Rogue/Skirmisher
    [67939] = true,  -- Damage Self -- Rogue/Skirmisher
    [67930] = true,  -- Passing Through Cleanup -- Rogue/Skirmisher
    [45511] = true,  -- Spread Out Sound -- Rogue/Skirmisher

    [35164] = true,  -- Agony -- Berserker
    [76328] = true,  -- Agony -- Berserker
    [35165] = true,  -- Agony -- Berserker
    [76330] = true,  -- Agony -- Berserker
    [10735] = true,  -- Blood Craze -- Berserker
    [49252] = true,  -- Blood Craze -- Berserker
    [49253] = true,  -- Blood Craze -- Berserker
    [49254] = true,  -- Blood Craze -- Berserker
    [44206] = true,  -- Minor Maim -- Berserker
    [44208] = true,  -- Heated Blades -- Berserker

    [34742] = true,  -- Fiery Breath -- Dragonknight
    [34797] = true,  -- Fiery Breath -- Dragonknight
    [34646] = true,  -- Lava Whip -- Dragonknight
    [34647] = true,  -- Lava Whip -- Dragonknight
    [34704] = true,  -- Dark Talons -- Dragonknight
    [74472] = true,  -- Dark Talons -- Dragonknight
    [34706] = true,  -- Dark Talons -- Dragonknight
    [44227] = true,  -- Dragonknight Standard -- Dragonknight
    [44228] = true,  -- Dragonknight Standard -- Dragonknight
    [44229] = true,  -- Dragonknight Standard -- Dragonknight
    [52041] = true,  -- Blink Strike -- Dragonknight
    [52045] = true,  -- Blink Strike -- Dragonknight
    [52051] = true,  -- Blink Strike -- Dragonknight
    [136500] = true, -- Blink Strike -- Dragonknight

    [29510] = true,  -- Thunder Hammer -- Thundermaul
    [29511] = true,  -- Thunder Hammer -- Thundermaul
    [17867] = true,  -- Shock Aura -- Thundermaul
    [44407] = true,  -- Lightning Form -- Thundermaul
    [44408] = true,  -- Lightning Form -- Thundermaul

    [81219] = true,  -- Shock -- Thundermaul
    [81215] = true,  -- Shock Aura -- Thundermaul
    -- [77905] = true, -- Knockback -- Thundermaul
    -- [77906] = true, -- Stun -- Thundermaul
    -- [57832] = true, -- CC Immunity Knock Back -- Thundermaul
    [81193] = true, -- Agonizing Strike -- Thundermaul
    [81195] = true, -- Agonizing Fury -- Thundermaul
    [81206] = true, -- Agonizing Bolts -- Thundermaul
    [81207] = true, -- Agonizing Bolts -- Thundermaul
    [81196] = true, -- Agonizing Fury -- Thundermaul
    [81197] = true, -- Agonizing Fury -- Thundermaul
    [81217] = true, -- Thunder Hammer -- Thundermaul
    [81218] = true, -- Thunder Hammer -- Thundermaul

    [73712] = true, -- Shadow Cloak -- Nightblade
    [73713] = true, -- Shadow Cloak -- Nightblade
    -- [36470] = true, -- Veiled Strike -- Nightblade
    -- [36471] = true, -- Veiled Strike -- Nightblade
    [137148] = true, -- Veiled Strike -- Nightblade
    [137152] = true, -- Veiled Strike -- Nightblade
    [138382] = true, -- Shadow Cloak -- Nightblade
    [137150] = true, -- Shadow Cloak -- Nightblade
    [36460] = true,  -- Teleport Strike -- Nightblade
    [63821] = true,  -- Teleport Strike -- Nightblade
    [63822] = true,  -- Teleport Strike -- Nightblade
    [44345] = true,  -- Soul Tether -- Nightblade
    [44349] = true,  -- Soul Tether -- Nightblade
    [44352] = true,  -- Soul Tether -- Nightblade
    [44350] = true,  -- Soul Tether -- Nightblade
    [44346] = true,  -- Soul Tether -- Nightblade
    [137661] = true, -- Soul Tether -- Nightblade

    [37108] = true,  -- Arrow Spray -- Archer
    [37109] = true,  -- Arrow Spray -- Archer
    [28628] = true,  -- Volley -- Archer
    [28629] = true,  -- Volley -- Archer
    [74978] = true,  -- Taking Aim -- Archer
    [74980] = true,  -- Taking Aim -- Archer

    [89460] = true,  -- Set Area -- Pet Ranger
    [16571] = true,  -- Set Area -- Pet Ranger
    [36609] = true,  -- Set Area -- Pet Ranger
    [36499] = true,  -- Roll Dodge -- Pet Ranger
    [88226] = true,  -- Call Ally -- Pet Ranger
    [88227] = true,  -- Call Ally -- Pet Ranger
    [88252] = true,  -- Call Ally -- Pet Ranger
    [88251] = true,  -- Call Ally -- Pet Ranger
    [88248] = true,  -- Call Ally -- Pet Ranger
    [89425] = true,  -- Call Ally -- Pet Ranger
    [88288] = true,  -- Call Ally -- Pet Ranger
    [88281] = true,  -- Call Ally -- Pet Ranger
    [88278] = true,  -- Call Ally -- Pet Ranger
    [89233] = true,  -- Call Ally -- Pet Ranger
    [44301] = true,  -- Trap Beast -- Pet Ranger
    [44305] = true,  -- Trap Beast -- Pet Ranger
    [44307] = true,  -- Trap Beast -- Pet Ranger

    [15164] = true,  -- Heat Wave -- Fire Mage
    [16588] = true,  -- Heat Wave -- Fire Mage
    [47095] = true,  -- Fire Rune -- Fire Mage
    [47096] = true,  -- Fire Rune -- Fire Mage
    [47102] = true,  -- Fire Rune -- Fire Mage
    [47101] = true,  -- Fire Rune -- Fire Mage
    [47103] = true,  -- Fire Rune -- Fire Mage

    [14524] = true,  -- Shock -- Storm Mage
    [58693] = true,  -- Thunder Thrall Check -- Storm Mage
    [29469] = true,  -- Thunder Thrall -- Storm Mage
    [29471] = true,  -- Thunder Thrall -- Storm Mage
    [29472] = true,  -- Thunder Thrall -- Storm Mage
    [29470] = true,  -- Thunder Thrall -- Storm Mage

    [12459] = true,  -- Winter's Reach -- Frost Mage
    [12460] = true,  -- Winter's Reach -- Frost Mage
    [14550] = true,  -- Winter's Reach -- Frost Mage
    [14178] = true,  -- Ice Barrier -- Frost Mage
    [49902] = true,  -- Ice Barrier Immunity -- Frost Mage
    [60898] = true,  -- Ice Barrier -- Frost Mage
    [14194] = true,  -- Ice Barrier -- Frost Mage
    [29331] = true,  -- Ice Barrier -- Frost Mage
    -- [7145] = true, -- Chilled -- Frost Mage

    [35151] = true,  -- Spell Absorption -- Spirit Mage
    [14472] = true,  -- Burdening Eye -- Spirit Mage
    [35149] = true,  -- Burdening Eye -- Spirit Mage
    [89057] = true,  -- Burdening Eye -- Spirit Mage
    [89042] = true,  -- Burdening Eye -- Spirit Mage
    [14477] = true,  -- Burden -- Spirit Mage
    [89063] = true,  -- Burden -- Spirit Mage
    [37200] = true,  -- Burden -- Spirit Mage
    [35141] = true,  -- Burden -- Spirit Mage
    [35142] = true,  -- Burden -- Spirit Mage
    [89041] = true,  -- Burdening Eye -- Spirit Mage

    [37150] = true,  -- Flare -- Battlemage
    [37028] = true,  -- Quick Strike -- Battlemage
    [37029] = true,  -- Quick Strike -- Battlemage
    [37030] = true,  -- Quick Strike -- Battlemage
    [37021] = true,  -- Empower Weapon: Flame -- Battlemage
    [37087] = true,  -- Lightning Onslaught -- Battlemage
    [37156] = true,  -- Lightning Onslaught -- Battlemage
    [37137] = true,  -- Lightning Onslaught -- Battlemage
    [37129] = true,  -- Ice Cage -- Battlemage
    [37131] = true,  -- Ice Cage -- Battlemage
    [37132] = true,  -- Ice Cage -- Battlemage
    [44216] = true,  -- Negate Magic -- Battlemage
    [50108] = true,  -- Negate Magic -- Battlemage
    [50107] = true,  -- Negate Magic -- Battlemage

    [37126] = true,  -- Entropic Flare -- Time Bomb Mage
    [14370] = true,  -- Void -- Time Bomb Mage
    [134637] = true, -- Void -- Time Bomb Mage
    [36985] = true,  -- Void -- Time Bomb Mage
    [36987] = true,  -- Void Burst -- Time Bomb Mage
    [36986] = true,  -- Void -- Time Bomb Mage
    [36988] = true,  -- Void -- Time Bomb Mage
    [36989] = true,  -- Void -- Time Bomb Mage
    [36990] = true,  -- Void -- Time Bomb Mage

    [56828] = true,  -- Fright Force -- Fear Mage
    [14350] = true,  -- Aspect of Terror -- Fear Mage
    [37084] = true,  -- Aspect of Terror -- Fear Mage
    [35849] = true,  -- Shadow Cloak -- Fear Mage
    [35865] = true,  -- Shadow Cloak -- Fear Mage
    [35850] = true,  -- Shadow Cloak -- Fear Mage
    [89020] = true,  -- Shadow Cloak -- Fear Mage

    [44247] = true,  -- Dark Shade -- Dreadweaver
    [89005] = true,  -- Dark Shade -- Dreadweaver
    [89006] = true,  -- Dark Shade -- Dreadweaver
    [89008] = true,  -- Dark Shade -- Dreadweaver
    [39729] = true,  -- TargetPriorityException -- Dreadweaver
    [44250] = true,  -- Dark Shade -- Dreadweaver
    [89017] = true,  -- Dark Shade -- Dreadweaver
    [89010] = true,  -- Corrode -- Dreadweaver - Dark Shade
    [89012] = true,  -- Minor Maim -- Dreadweaver - Dark Shade
    [89016] = true,  -- Dark Shade -- Dreadweaver
    [89454] = true,  -- Dark Shade -- Dreadweaver
    [89455] = true,  -- Dark Shade -- Dreadweaver

    [44323] = true,  -- Dampen Magic -- Soulbrander
    [44258] = true,  -- Radiant Magelight -- Soulbrander
    [44263] = true,  -- Radiant Magelight -- Soulbrander
    [44259] = true,  -- Magelight -- Soulbrander

    [29372] = true,  -- Necrotic Spear -- Necromancer
    [5605] = true,   -- Summon the Dead -- Necromancer
    [31848] = true,  -- Summon the Dead -- Necromancer
    [88582] = true,  -- Summon the Dead -- Necromancer
    [88583] = true,  -- Summon the Dead -- Necromancer
    [88599] = true,  -- Summon the Dead -- Necromancer
    [88590] = true,  -- Summon the Dead -- Necromancer
    [88591] = true,  -- Summon the Dead -- Necromancer
    [88592] = true,  -- Summon the Dead -- Necromancer
    -- [88586] = true, -- Summon the Dead -- Necromancer
    [88589] = true,  -- Summon the Dead -- Necromancer
    -- [88600] = true, -- Summon the Dead -- Necromancer
    [88602] = true,  -- Summon the Dead -- Necromancer
    -- [88618] = true, -- Summon the Dead -- Necromancer
    [88611] = true,  -- Summon the Dead -- Necromancer
    [88607] = true,  -- Summon the Dead -- Necromancer
    [88613] = true,  -- Summon the Dead -- Necromancer
    [88621] = true,  -- Summon the Dead -- Necromancer
    [88615] = true,  -- Summon the Dead -- Necromancer
    -- [88610] = true, -- Summon the Dead -- Necromancer
    [88608] = true,  -- Summon the Dead -- Necromancer
    [88614] = true,  -- Summon the Dead -- Necromancer
    [88622] = true,  -- Summon the Dead -- Necromancer
    [88616] = true,  -- Summon the Dead -- Necromancer
    [88626] = true,  -- Summon the Dead -- Necromancer
    [88627] = true,  -- Summon the Dead -- Necromancer
    -- [88601] = true, -- Summon the Dead -- Necromancer
    [88593] = true,  -- Summon the Dead -- Necromancer
    -- [88617] = true, -- Summon the Dead -- Necromancer
    [88594] = true,  -- Summon the Dead -- Necromancer
    [88595] = true,  -- Summon the Dead -- Necromancer
    [88596] = true,  -- Summon the Dead -- Necromancer
    [88612] = true,  -- Summon the Dead -- Necromancer
    [88597] = true,  -- Summon the Dead -- Necromancer
    [88598] = true,  -- Summon the Dead -- Necromancer
    [88566] = true,  -- Summon the Dead -- Necromancer
    [88554] = true,  -- Summon the Dead -- Necromancer
    [88555] = true,  -- Summon the Dead -- Necromancer
    [88556] = true,  -- Summon the Dead -- Necromancer
    [88561] = true,  -- Summon the Dead -- Necromancer
    [13397] = true,  -- Empower Undead -- Necromancer
    [88560] = true,  -- Summon the Dead -- Necromancer
    [89182] = true,  -- Summon the Dead -- Necromancer
    [89230] = true,  -- Summon the Dead -- Necromancer

    [7590] = true,   -- Entropic Bolt -- Bonelord
    [35387] = true,  -- Bone Cage -- Bonelord
    [88322] = true,  -- Bone Cage -- Bonelord
    [35391] = true,  -- Defiled Grave -- Bonelord
    [35383] = true,  -- Summon Abomination -- Bonelord
    [35384] = true,  -- Summon Abomination -- Bonelord
    [88522] = true,  -- Summon Abomination -- Bonelord
    [88526] = true,  -- Summon Abomination -- Bonelord
    [88506] = true,  -- Summon Abomination -- Bonelord
    [88507] = true,  -- Summon Abomination -- Bonelord
    [88504] = true,  -- Summon Abomination -- Bonelord
    [88503] = true,  -- Summon Abomination -- Bonelord
    [89231] = true,  -- Summon Abomination -- Bonelord
    [89184] = true,  -- Summon Abomination -- Bonelord
    [44339] = true,  -- Bone Surge -- Bonelord

    [79803] = true,  -- Covetous Return -- Healer
    [10601] = true,  -- Minor Wound -- Healer
    [57534] = true,  -- Focused Healing -- Healer
    [57536] = true,  -- Spread Out Sound -- Healer
    [57537] = true,  -- Focused Healing -- Healer
    [57538] = true,  -- Focused Healing -- Healer
    [50931] = true,  -- Healer Immune -- Healer
    [50975] = true,  -- Healer Immune -- Healer
    [50966] = true,  -- Healer Immune -- Healer
    [50998] = true,  -- Rite of Passage -- Healer
    [44328] = true,  -- Rite of Passage -- Healer
    [44329] = true,  -- Rite of Passage -- Healer
    [44330] = true,  -- Rite of Passage -- Healer
    [44331] = true,  -- Rite of Passage Self Snare -- Healer

    [29669] = true,  -- Coiled Lash -- Shaman
    [29520] = true,  -- Aura of Protection -- Shaman
    [65314] = true,  -- Aura of Protection -- Shaman
    [65432] = true,  -- Aura of Protection -- Shaman
    [29521] = true,  -- Aura of Protection -- Shaman
    [29595] = true,  -- Aura of Protection -- Shaman
    [83073] = true,  -- Summon Died -- Shaman
    [29597] = true,  -- Combustion -- Shaman
    [29598] = true,  -- Off Balance -- Shaman

    [68866] = true,  -- War Horn -- Faction NPC
    [68867] = true,  -- War Horn Battlecry -- Faction NPC
    [68868] = true,  -- War Horn Battlecry -- Faction NPC
    [68869] = true,  -- War Horn Battlecry -- Faction NPC
    [38118] = true,  -- Caltrops -- Faction NPC
    [43644] = true,  -- Barrier [monster synergy] -- Faction NPC
    [43645] = true,  -- Barrier [monster synergy] -- Faction NPC
    [43646] = true,  -- Barrier [monster synergy] -- Faction NPC
    [41793] = true,  -- Anti-Cavalry Caltrops -- Faction NPC
    [38119] = true,  -- Caltrops -- Faction NPC
    [38125] = true,  -- Caltrops -- Faction NPC

    [65033] = true,  -- Retaliation -- Winterborn Warrior (DLC)
    [69158] = true,  -- Retaliation -- Winterborn Warrior (DLC)
    [69154] = true,  -- Retaliation -- Winterborn Warrior (DLC)
    [67114] = true,  -- Retaliation -- Winterborn Warrior (DLC)
    [69157] = true,  -- Retaliation -- Winterborn Warrior (DLC)
    [69153] = true,  -- Retaliation -- Winterborn Warrior (DLC)
    [69167] = true,  -- Retaliation -- Winterborn Warrior (DLC)
    [1347] = true,   -- Off-Balance -- Winterborn Warrior (DLC)
    [14883] = true,  -- Off-Balance -- Winterborn Warrior (DLC)
    [4508] = true,   -- Off-Balance -- Winterborn Warrior (DLC)
    [70070] = true,  -- Heavy Strike -- Winterborn Warrior (DLC)
    [64980] = true,  -- Javelin -- Winterborn Warrior (DLC)
    [69282] = true,  -- Roll Dodge Back -- Winterborn Warrior (DLC)
    [69278] = true,  -- Roll Dodge Back -- Winterborn Warrior (DLC)

    [54593] = true,  -- Flare -- Winterborn Mage (DLC)
    [55909] = true,  -- Grasping Vines -- Winterborn Mage (DLC)
    [55911] = true,  -- Grasping Vines -- Winterborn Mage (DLC)
    [55917] = true,  -- Grasping Vines -- Winterborn Mage (DLC)
    [55918] = true,  -- Grasping Vines -- Winterborn Mage (DLC)
    [55916] = true,  -- Grasping Vineburst -- Winterborn Mage (DLC)

    [64704] = true,  -- Flames -- Winterborn Mage (DLC)
    [64711] = true,  -- Flames -- Winterborn Mage (DLC)
    [64706] = true,  -- Flames -- Winterborn Mage (DLC)
    [64707] = true,  -- Flames -- Winterborn Mage (DLC)
    [64708] = true,  -- Flames -- Winterborn Mage (DLC)
    [64709] = true,  -- Flames -- Winterborn Mage (DLC)
    [64710] = true,  -- Flames -- Winterborn Mage (DLC)
    [64712] = true,  -- Flames -- Winterborn Mage (DLC)
    [64713] = true,  -- Flames -- Winterborn Mage (DLC)
    [64714] = true,  -- Flames -- Winterborn Mage (DLC)
    [64715] = true,  -- Flames -- Winterborn Mage (DLC)
    [64716] = true,  -- Flames -- Winterborn Mage (DLC)
    [64717] = true,  -- Flames -- Winterborn Mage (DLC)
    [64718] = true,  -- Flames -- Winterborn Mage (DLC)
    [64719] = true,  -- Flames -- Winterborn Mage (DLC)
    [64720] = true,  -- Flames -- Winterborn Mage (DLC)
    [64721] = true,  -- Flames -- Winterborn Mage (DLC)
    [64722] = true,  -- Flames -- Winterborn Mage (DLC)
    [64723] = true,  -- Flames -- Winterborn Mage (DLC)
    [64724] = true,  -- Flames -- Winterborn Mage (DLC)
    [64725] = true,  -- Flames -- Winterborn Mage (DLC)
    [64726] = true,  -- Flames -- Winterborn Mage (DLC)
    [64727] = true,  -- Flames -- Winterborn Mage (DLC)

    [54184] = true,  -- Revenge 2 -- Vosh Rakh Devoted (DLC)
    [53987] = true,  -- Rally -- Vosh Rakh Devoted (DLC)
    [54397] = true,  -- Rally -- Vosh Rakh Devoted (DLC)
    [65235] = true,  -- Enrage -- Vosh Rakh Devoted (DLC)
    [65237] = true,  -- Scary -- Vosh Rakh Devoted (DLC)
    [54027] = true,  -- Divine Leap -- Vosh Rakh Devoted (DLC)
    [65183] = true,  -- Divine Leap Target -- Vosh Rakh Devoted (DLC)
    [67272] = true,  -- Invisible No Target -- Vosh Rakh Devoted (DLC)
    [54028] = true,  -- Divine Leap -- Vosh Rakh Devoted (DLC)
    [67593] = true,  -- Divine Leap Stagger -- Vosh Rakh Devoted (DLC)
    [54050] = true,  -- Divine Leap Stun -- Vosh Rakh Devoted (DLC)

    [51000] = true,  -- Cleave Stance -- Dremora Caitiff (DLC)
    [50927] = true,  -- Enter Combat -- Dremora Caitiff (DLC)
    [51921] = true,  -- Cleave Stance -- Dremora Caitiff (DLC)
    [51923] = true,  -- Cleave Stance -- Dremora Caitiff (DLC)
    [51939] = true,  -- Cleave Stance -- Dremora Caitiff (DLC)
    [51940] = true,  -- Cleave Stance -- Dremora Caitiff (DLC)
    [51941] = true,  -- Cleave Stance -- Dremora Caitiff (DLC)
    [51942] = true,  -- Cleave Stance -- Dremora Caitiff (DLC)

    [72723] = true,  -- Fool Me Once -- Sentinel (TG DLC)
    [74486] = true,  -- Low Slash -- Sentinel (TG DLC)
    [74487] = true,  -- Low Slash -- Sentinel (TG DLC)
    [74480] = true,  -- Fiery Grip -- Sentinel (TG DLC)
    [74483] = true,  -- Fiery Grip -- Sentinel (TG DLC)
    [72748] = true,  -- Fool Me Once HOLD -- Sentinel (TG DLC)
    [72725] = true,  -- Fool Me Once -- Sentinel (TG DLC)
    [77468] = true,  -- Fool Me Once -- Sentinel (TG DLC)

    [74630] = true,  -- Flare Trap Proxy -- Archer (TG DLC)
    [72716] = true,  -- Uncanny Dodge -- Archer (TG DLC)
    [72717] = true,  -- Uncanny Dodge SCU REM -- Archer (TG DLC)
    [72719] = true,  -- Uncanny Dodge SCU REM -- Archer (TG DLC)
    [72214] = true,  -- Poisoned Arrow -- Archer (TG DLC)
    [72217] = true,  -- Poisoned Arrow -- Archer (TG DLC)
    [76089] = true,  -- Snipe -- Archer (TG DLC)
    [72221] = true,  -- Shadow Cloak -- Archer (TG DLC)
    [72222] = true,  -- Shadow Cloak -- Archer (TG DLC)
    [72220] = true,  -- Snipe -- Archer (TG DLC)
    [74628] = true,  -- Flare Trap -- Archer (TG DLC)
    [74618] = true,  -- Flare Trap -- Archer (TG DLC)
    [74627] = true,  -- Flare Trap -- Archer (TG DLC)
    [77446] = true,  -- Flare Trap -- Archer (TG DLC)
    [74619] = true,  -- Flare Trap -- Archer (TG DLC)
    [74621] = true,  -- Revealed -- Archer (TG DLC)
    [74620] = true,  -- Flare Trap REM -- Archer (TG DLC)

    [81360] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77472] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [79523] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [81366] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77672] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77748] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77742] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77778] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77765] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77750] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77697] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77738] = true,  -- 'Til Death -- Bodyguard (DB DLC)
    [77554] = true,  -- Shard Shield -- Bodyguard (DB DLC)
    [77555] = true,  -- Shard Shield -- Bodyguard (DB DLC)
    [77473] = true,  -- Shield Charge -- Bodyguard (DB DLC)
    [77838] = true,  -- Shield Charge -- Bodyguard (DB DLC)
    [77815] = true,  -- Shield Charge -- Bodyguard (DB DLC)
    [77927] = true,  -- Staggered -- Bodyguard (DB DLC)

    [77020] = true,  -- Basilisk Powder (Tracker)
    [77089] = true,  -- Basilisk Powder (Tracker)
    [77087] = true,  -- Basilisk Powder (Tracker)
    [79954] = true,  -- Basilisk Powder (Tracker)
    [77019] = true,  -- Pin (Tracker)
    [77030] = true,  -- Pin (Tracker)
    [78432] = true,  -- Lunge (Tracker)
    [79993] = true,  -- Lunge (Tracker)
    [79955] = true,  -- Lunge (Tracker)
    [78435] = true,  -- Lunge (Tracker)
    [79930] = true,  -- Lunge (Tracker)
    [79929] = true,  -- Lunge (Tracker)
    [78664] = true,  -- Lunge (Tracker)
    [129913] = true, -- Lunge Target (Tracker)

    [88481] = true,  -- Spectral Claw (Beastcaller)
    [88478] = true,  -- Swarm (Beastcaller)
    [88371] = true,  -- Dive (Beastcaller)
    [88393] = true,  -- Dive (Beastcaller)
    [88394] = true,  -- Gore (Beastcaller)
    [88395] = true,  -- Gore (Beastcaller)
    [88400] = true,  -- Gore (Beastcaller)
    [88409] = true,  -- Raise the Earth (Beastcaller)
    [88657] = true,  -- Feral Guardian (Beastcaller)
    [92303] = true,  -- Despawn Override (Beastcaller)
    [92158] = true,  -- Raise the Earth (Beastcaller)
    [92157] = true,  -- Raise the Earth (Beastcaller)
    [92159] = true,  -- Raise the Earth (Beastcaller)
    [92156] = true,  -- Summon the Dead (Beastcaller)

    [87854] = true,  -- Quick Shot (Arbalest)
    [87855] = true,  -- Arrow Stab (Arbalest)
    [87901] = true,  -- Bombard (Arbalest)
    [90399] = true,  -- Bombard (Arbalest)
    [87904] = true,  -- Bombard (Arbalest)
    [87902] = true,  -- Bombard (Arbalest)
    [87713] = true,  -- Quakeshot (Arbalest)
    [87715] = true,  -- Quakeshot (Arbalest)
    [87834] = true,  -- Quakeshot (Arbalest)
    [87835] = true,  -- Quakeshot (Arbalest)
    [87837] = true,  -- Quakeshot (Arbalest)
    [87852] = true,  -- Quakeshot (Arbalest)
    [87422] = true,  -- Chilled Ground (Arbalest)
    [87491] = true,  -- Chilled Ground (Arbalest)

    [86881] = true,  -- Hack
    [86882] = true,  -- Hack
    [86883] = true,  -- Slash
    [86884] = true,  -- Slash
    [85342] = true,  -- Twin Slashes
    [85343] = true,  -- Twin Slashes
    [85368] = true,  -- Twin Slashes Bleed
    [86879] = true,  -- Chop
    [86880] = true,  -- Hack
    [85359] = true,  -- Reverse Slash
    [85365] = true,  -- Assassinate Bonus
    [86704] = true,  -- Chop (Hleran Noble)
    [86705] = true,  -- Lop (Hleran Noble)
    [85361] = true,  -- Puncture (Hleran Noble)
    [85362] = true,  -- Major Fracture (Hleran Noble)

    [87064] = true,  -- Volcanic Debris (Fire-Binder)
    [87067] = true,  -- Volcanic Debris (Fire-Binder)
    [87065] = true,  -- Volcanic Debris (Fire-Binder)
    [92647] = true,  -- Volcanic Debris (Fire-Binder)
    [87069] = true,  -- Volcanic Debris (Fire-Binder)
    [87068] = true,  -- Volcanic Debris (Fire-Binder)
    [87066] = true,  -- Volcanic Debris (Fire-Binder)
    [88845] = true,  -- Empower Atronach (Fire-Binder)
    [92646] = true,  -- Volcanic Debris (Fire-Binder)

    [81545] = true,  -- Fright Force (Voidbringer)
    [76621] = true,  -- Shadeway (Voidbringer)
    [76760] = true,  -- Shadeway (Voidbringer)
    [76762] = true,  -- Shadeway (Voidbringer)
    [76784] = true,  -- Shadeway (Voidbringer)
    [76619] = true,  -- Pool of Shadow (Voidbringer)
    [76623] = true,  -- Pool of Shadow (Voidbringer)
    [76624] = true,  -- Pool of Shadow (Voidbringer)
    [76668] = true,  -- Pool of Shadow (Voidbringer)
    [76669] = true,  -- Pool of Shadow (Voidbringer)
    [76653] = true,  -- Pool of Shadow (Voidbringer)
    [76728] = true,  -- Pool of Shadow (Voidbringer)
    [76821] = true,  -- SHA Deepest Shadow BON (Voidbringer)
    [76620] = true,  -- Shadowy Duplicate (Voidbringer)
    [77005] = true,  -- Shadowy Duplicate (Voidbringer)
    [76967] = true,  -- Shadowy Duplicate (Voidbringer)
    [76979] = true,  -- Shadowy Duplicate (Voidbringer)
    [76995] = true,  -- Shadowy Duplicate (Voidbringer)
    [76955] = true,  -- Shadowy Duplicate (Voidbringer)
    [76957] = true,  -- Shadowy Duplicate (Voidbringer)
    [81079] = true,  -- Shadowy Duplicate (Voidbringer)
    [76998] = true,  -- Shadowy Duplicate (Voidbringer)
    [76996] = true,  -- Shadowy Duplicate (Voidbringer)
    [76985] = true,  -- Shadowy Duplicate (Voidbringer)
    [77009] = true,  -- Shadowy Duplicate (Voidbringer)

    [88361] = true,  -- Vile Flare (Skaafin Masquer)
    [88327] = true,  -- Shadeway (Skaafin Masquer)
    [88337] = true,  -- Shadeway (Skaafin Masquer)
    [88338] = true,  -- Shadeway (Skaafin Masquer)
    [88339] = true,  -- Shadeway (Skaafin Masquer)
    [88341] = true,  -- Shadeway (Skaafin Masquer)
    [88325] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88329] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88336] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88330] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88332] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88333] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88331] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88335] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88334] = true,  -- Pool of Shadow (Skaafin Masquer)
    [88340] = true,  -- Deep Denial (Skaafin Masquer)
    [88326] = true,  -- Create Masque (Skaafin Masquer)
    [88353] = true,  -- Create Masque (Skaafin Masquer)
    [88358] = true,  -- Shadowy Duplicate (Skaafin Masquer)
    [88345] = true,  -- Shadowy Duplicate (Skaafin Masquer)
    [88348] = true,  -- Shadowy Duplicate (Skaafin Masquer)
    [88350] = true,  -- Shadowy Duplicate (Skaafin Masquer)
    [88346] = true,  -- Shadowy Duplicate (Skaafin Masquer)
    [88342] = true,  -- Create Masque (Skaafin Masquer)
    [88383] = true,  -- Create Masque (Skaafin Masquer)
    [88343] = true,  -- Create Masque (Skaafin Masquer)
    [88360] = true,  -- Create Masque (Skaafin Masquer)
    [88352] = true,  -- Create Masque (Skaafin Masquer)
    [88351] = true,  -- Shadowy Duplicate (Skaafin Masquer)
    [88349] = true,  -- Shadowy Duplicate (Skaafin Masquer)
    [88354] = true,  -- Shadowy Duplicate (Skaafin Masquer)

    [84817] = true,  -- Skaafin Flare (Skaafin Witchling)
    [84815] = true,  -- Skaafin Flare (Skaafin Witchling)
    [84818] = true,  -- Fiendish Healing (Skaafin Witchling)
    [84831] = true,  -- Fiendish Healing (Skaafin Witchling)
    [84829] = true,  -- Fiendish Healing (Skaafin Witchling)
    [84833] = true,  -- Fiendish Healing (Skaafin Witchling)
    [84820] = true,  -- Fiendish Healing (Skaafin Witchling)
    [84821] = true,  -- Fiendish Healing (Skaafin Witchling)

    [84835] = true,  -- Broken Pact (Skaafin Witchling)
    [84851] = true,  -- Broken Pact (Skaafin Witchling)
    [84850] = true,  -- Broken Pact (Skaafin Witchling)
    [84838] = true,  -- Broken Pact (Skaafin Witchling)
    [84836] = true,  -- Broken Pact (Skaafin Witchling)
    [84837] = true,  -- Broken Pact (Skaafin Witchling)

    -------------------------------------
    -- CYRODIIL GUARDS ------------------
    -------------------------------------

    [47717] = true, -- Quick Strike (Guard T1)
    [46220] = true, -- Puncture (Guard T1 + T2)
    [46221] = true, -- Puncture (Guard T1 + T2)
    [46830] = true, -- Bleeding Strike (Guard T2)
    [46832] = true, -- Bleeding (Guard T2)
    [46831] = true, -- Bleeding (Guard T2)
    [36304] = true, -- Razor Armor (Guard T2)
    [36306] = true, -- Razor Armor (Guard T2)
    [36305] = true, -- Spike Armor Damage Return (Guard T2)

    [7880] = true,  -- Light Attack (Mage T1)
    [7881] = true,  -- Guardian Storm (Mage T1)
    [7883] = true,  --  Guardian Storm (Mage T1)
    [21629] = true, -- Mage's Lifesteal (Mage T1)
    [21632] = true, -- Lifesteal (Mage T1)
    [21631] = true, -- Lifesteal (Mage T1)
    [46335] = true, -- Crystal Shard (Mage T1)
    [46336] = true, -- Crystal Shard Stun (Mage T1)

    [46711] = true, -- Bound Aegis (Mage T2)
    [46726] = true, -- Shock Torrent (Mage T2)
    [46730] = true, -- Shock Torrent (Mage T2)
    [46818] = true, -- Lasting Storm (Mage T2)
    [46819] = true, -- Storm Damage (Mage T2)
    [46716] = true, -- Stolen Essence (Mage T2)
    [46719] = true, -- Stolen Essence (Mage T2)
    [46718] = true, -- Lifesteal (Mage T2)
    [46717] = true, -- Lifesteal (Mage T2)
    [46704] = true, -- Crystal Blast (Mage T2)
    [46705] = true, -- Crystal Blast (Mage T2)
    [46706] = true, -- Crystal Shard Stun (Mage T2)
    [52806] = true, -- Unstable Core (Mage T2)
    [52808] = true, -- Unstable Core  (Mage T2)
    [75397] = true, -- Unstable Core (Mage T2)
    [75395] = true, -- Reflected FX (Mage T2)

    [57962] = true, -- Minor Wound (Mender T1)
    [46236] = true, -- Rune Focus (Mender T1)
    [46270] = true, -- Summon Shade (Mender T1)
    [46272] = true, -- Rune Focus (Mender T1)
    [21636] = true, -- Telekinetic Prison (Mender T1)
    [21638] = true, -- Telekinetic Disorient (Mender T1)
    [46839] = true, -- Major Wound (Mender T2)
    [46902] = true, -- Rune Power (Mender T2)
    [46903] = true, -- Summon Shade (Mender T2)
    [46904] = true, -- Rune Focus (Mender T2)
    [46905] = true, -- Shattering Prison (Mender T2)
    [46906] = true, -- Telekinetic Disorient (Mender T2)
    [46910] = true, -- Shattering Prison (Mender T2)
    [46847] = true, -- Potent Healing (Mender T2)
    [52862] = true, -- Health Boon (Mender T2)
    [22469] = true, -- Siege Shield (Mender T2)
    [22489] = true, -- Siege Bubble (Mender T2)
    [32423] = true, -- Siege heal (Mender T2)
    [51891] = true, -- Negate Magic (Mender T2)
    [51893] = true, -- Negate Magic (Mender T2)
    [51894] = true, -- Negate Magic (Mender T2)

    [52864] = true, -- Quick Shot (Archer T1)
    -- [52865] = true, -- Volley (Archer T1)
    -- [52866] = true, -- Volley (Archer T1)
    [70413] = true, -- Burning Arrow (Archer - Cyrodiil)
    -- [70417] = true, -- Ignite (Archer T1)
    -- [70414] = true, -- Ignite (Archer T1)
    -- [54257] = true, -- Upgraded Volley (Archer T2)
    -- [54258] = true, -- Upgraded Volley (Archer T2)
    [54264] = true, -- Lethal Arrow (Archer T2)
    [54265] = true, -- Lethal Arrow (Archer T2)
    [54259] = true, -- Draining Shot (Archer T2)
    [54261] = true, -- Draining Shot (Archer T2)

    [16510] = true, -- Fire Salvo (Honor Guard T1)
    [15780] = true, -- Honor Guard Rage (Honor Guard T1)
    [32446] = true, -- Guardian Heal (Honor Guard T1)
    [32447] = true, -- Dragon Blood (Honor Guard T1)
    [35113] = true, -- Extended Chains (Honor Guard T1)
    [35115] = true, -- Pull (Honor Guard T1)
    [46990] = true, -- Improved Fire Torrent (Honor Guard T1)
    [46991] = true, -- Fire Torrent Burning (Honor Guard T1)
    [46992] = true, -- Crippling Rage (Honor Guard T1)
    [47001] = true, -- Crippling Rage (Honor Guard T1)
    [47004] = true, -- Guardian Heal (Honor Guard T1)
    [47005] = true, -- Dragon Blood (Honor Guard T1)
    [47019] = true, -- Puncturing Chains (Honor Guard T1)
    [47023] = true, -- Puncture (Honor Guard T1)
    [47020] = true, -- Pull (Honor Guard T1)
    [15781] = true, -- Triple Strike (Honor Guard T1 + T2)
    [15783] = true, -- Triple Strike (Honor Guard T1 + T2)
    [15782] = true, -- Triple Strike (Honor Guard T1 + T2)

    -------------------------------------
    -- ANIMALS --------------------------
    -------------------------------------

    [5451] = true,   -- Bite -- Alit
    [5452] = true,   -- Lacerate -- Alit
    [84356] = true,  -- Lacerate -- Alit
    [56984] = true,  -- Laceration -- Alit
    [56983] = true,  -- Laceration -- Alit

    [4413] = true,   -- Swipe -- Bear
    [4415] = true,   -- Crushing Swipe -- Bear
    [38772] = true,  -- Crushing Swipe -- Bear
    [18273] = true,  -- Crushing Swipe -- Bear
    [139956] = true, -- Savage Blow -- Bear
    [139957] = true, -- Savage Blow -- Bear
    [139963] = true, -- Savage Bleeding -- Bear
    [139958] = true, -- Savage Bleeding -- Bear
    [4419] = true,   -- Daunting Roar -- Bear

    [70355] = true,  -- Bite -- Great Bear
    [70357] = true,  -- Lunge -- Great Bear
    [70359] = true,  -- Lunge -- Great Bear
    [70366] = true,  -- Slam -- Great Bear
    [89189] = true,  -- Slam -- Great Bear
    [69073] = true,  -- Knockdown -- Great Bear
    [70372] = true,  -- Ferocity -- Great Bear
    [70375] = true,  -- Ferocity -- Great Bear
    [70376] = true,  -- Ferocity -- Great Bear
    [70374] = true,  -- Ferocity -- Great Bear

    [4583] = true,   -- Bite -- Crocodile
    [9642] = true,   -- Bite -- Crocodile
    [4587] = true,   -- Crushing Chomp -- Crocodile
    [4591] = true,   -- Sweep -- Crocodile
    [32051] = true,  -- Sweep -- Crocodile
    [4594] = true,   -- Ancient Skin -- Crocodile

    [8971] = true,   -- Bite -- Duneripper
    [9643] = true,   -- Bite -- Duneripper
    [8972] = true,   -- Crushing Chomp -- Duneripper
    [8977] = true,   -- Sweep -- Duneripper
    [32461] = true,  -- Sweep -- Duneripper
    [8974] = true,   -- Burrow -- Duneripper
    [42866] = true,  -- Burrow -- Duneripper
    [82269] = true,  -- DuneRipper Birth -- Duneripper

    [7214] = true,   -- Bite -- Durzog
    [7221] = true,   -- Rend -- Durzog
    [7227] = true,   -- Rotbone -- Durzog
    [16878] = true,  -- Rotbone -- Durzog

    [6304] = true,   -- Swipe -- Dreugh
    [18002] = true,  -- Slash -- Dreugh
    [18003] = true,  -- Slash -- Dreugh
    [18005] = true,  -- Slash -- Dreugh
    [6308] = true,   -- Shocking Touch -- Dreugh
    [6328] = true,   -- Shocking Rake -- Dreugh
    [27100] = true,  -- Shocking Rake -- Dreugh

    [54374] = true,  -- Tusks -- Echatere
    [54375] = true,  -- Shockwave -- Echatere
    [54378] = true,  -- Shockwave -- Echatere
    [68971] = true,  -- Staggered -- Echatere
    [54380] = true,  -- Headbutt -- Echatere
    [54382] = true,  -- Headbutt -- Echatere
    [54381] = true,  -- Headbutt -- Echatere

    [4628] = true,   -- Scrape -- Giant Bat
    [60920] = true,  -- Scrape -- Giant Bat
    [4632] = true,   -- Screech -- Giant Bat
    [47321] = true,  -- Screech -- Giant Bat
    [18319] = true,  -- Screech -- Giant Bat
    [4630] = true,   -- Draining Bite -- Giant Bat
    [18320] = true,  -- Draining Bite -- Giant Bat

    [8540] = true,   -- Strike -- Giant Snake
    [5240] = true,   -- Lash -- Giant Snake
    [30214] = true,  -- Lash -- Giant Snake
    [5242] = true,   -- Kiss of Poison -- Giant Snake
    [21826] = true,  -- Kiss of Poison -- Giant Snake
    [5244] = true,   -- Shed Skin -- Giant Snake
    [21993] = true,  -- Shed Skin -- Giant Snake

    [5440] = true,   -- Bite -- Guar
    [5443] = true,   -- Headbutt -- Guar
    [5441] = true,   -- Dive -- Guar
    [84359] = true,  -- Dive -- Guar

    [72803] = true,  -- Hardened Shell - Haj Mota
    [74123] = true,  -- Claw -- Haj Mota
    [72786] = true,  -- Horn Strike -- Haj Mota
    [72787] = true,  -- Horn Strike -- Haj Mota
    [73479] = true,  -- Horn Strike -- Haj Mota
    [73481] = true,  -- Horn Strike -- Haj Mota
    [74272] = true,  -- Bite -- Haj Mota
    [76578] = true,  -- Bite -- Haj Mota
    [72793] = true,  -- Toxic Mucus -- Haj Mota
    [76577] = true,  -- Toxic Mucous -- Haj Mota
    [72815] = true,  -- Toxic Mucous -- Haj Mota
    [72794] = true,  -- Toxic Pool -- Haj Mota
    [72795] = true,  -- Toxic Pool -- Haj Mota
    [72796] = true,  -- Bog Burst -- Haj Mota
    [72799] = true,  -- Bog Burst -- Haj Mota
    [76183] = true,  -- Bog Burst -- Haj Mota
    [72800] = true,  -- Bog Burst -- Haj Mota
    [74336] = true,  -- Bog Burst -- Haj Mota
    [74337] = true,  -- Bog Burst -- Haj Mota
    [76184] = true,  -- Bog Burst -- Haj Mota
    [72789] = true,  -- Shockwave -- Haj Mota
    [75828] = true,  -- Shockwave -- Haj Mota
    [73494] = true,  -- Shockwave -- Haj Mota
    [73495] = true,  -- Shockwave -- Haj Mota
    [73496] = true,  -- Shockwave -- Haj Mota
    [73497] = true,  -- Shockwave -- Haj Mota
    [73498] = true,  -- Shockwave -- Haj Mota
    [73499] = true,  -- Shockwave -- Haj Mota

    [5362] = true,   -- Slam -- Kagouti
    [5363] = true,   -- Chomp -- Kagouti
    [5926] = true,   -- Toss -- Kagouti
    [42889] = true,  -- Toss -- Kagouti
    [42888] = true,  -- Toss -- Kagouti
    [18198] = true,  -- Toss -- Kagouti
    [14202] = true,  -- Charge
    [14196] = true,  -- Charge
    [14819] = true,  -- Charge
    [48544] = true,  -- Charge
    [14825] = true,  -- Charge
    [14828] = true,  -- Charge
    [14829] = true,  -- Charge
    [18751] = true,  -- Charge
    [87276] = true,  -- Chomp (Kagouti Whelp)
    [87310] = true,  -- Run Away! (Kagouti Whelp)
    [87312] = true,  -- Run Away! (Kagouti Whelp)

    [7170] = true,   -- Rend -- Lion
    [60630] = true,  -- Rend -- Lion
    [60641] = true,  -- Claw -- Lion
    [7158] = true,   -- Bite -- Lion
    [7161] = true,   -- Double Strike -- Lion
    [7176] = true,   -- Daunting Roar -- Lion
    [8705] = true,   -- Weakness -- Lion

    [8596] = true,   -- Swipe -- Mammoth
    [8601] = true,   -- Vigorous Swipe -- Mammoth
    [8604] = true,   -- Vigorous Swipe -- Mammoth
    [75633] = true,  -- Vigorous Swipe -- Mammoth
    [75634] = true,  -- Vigorous Swipes -- Mammoth
    [8600] = true,   -- Stomp -- Mammoth
    [23197] = true,  -- Stomp -- Mammoth
    [23164] = true,  -- Stomp -- Mammoth
    [23230] = true,  -- Charge -- Mammoth
    [48551] = true,  -- Focused Charge -- Mammoth
    [23223] = true,  -- Focused Charge -- Mammoth
    [23226] = true,  -- Charge -- Mammoth
    [23221] = true,  -- Charge -- Mammoth
    [23222] = true,  -- Charge -- Mammoth
    [23225] = true,  -- Charge -- Mammoth
    [23227] = true,  -- Charge -- Mammoth
    [23224] = true,  -- Charge -- Mammoth

    [4192] = true,   -- Pincer -- Mudcrab
    [4224] = true,   -- Double Claw Strike -- Mudcrab
    [4226] = true,   -- Double Claw Strike -- Mudcrab
    [4200] = true,   -- Unforgiving Claws -- Mudcrab
    [85082] = true,  -- Unforgiving Claws -- Mudcrab
    [28825] = true,  -- Scuttle -- Mudcrab
    [42841] = true,  -- Scuttle -- Mudcrab

    [16667] = true,  -- Slap -- Netch
    [16690] = true,  -- Thrust -- Netch
    [16697] = true,  -- Poisonbloom -- Netch
    [16698] = true,  -- Poisonbloom -- Netch

    [7266] = true,   -- Strike -- Nix-Hound
    [13416] = true,  -- Strike -- Nix-Hound
    [7268] = true,   -- Leech -- Nix-Hound
    [12303] = true,  -- Leech -- Nix-Hound
    [18344] = true,  -- Leech -- Nix-Hound
    [7273] = true,   -- Dampworm -- Nix-Hound
    [38635] = true,  -- Dampworm -- Nix-Hound
    [38640] = true,  -- Dampworm -- Nix-Hound
    [7271] = true,   -- Ambush -- Nix-Hound
    [18190] = true,  -- Shadowstep -- Nix-Hound

    -- [5362] = true,   -- Slam -- Skeever
    [21904] = true,  -- Rend -- Skeever

    [21947] = true,  -- Bite -- Wamasu
    [21949] = true,  -- Sweep -- Wamasu
    [46833] = true,  -- Sweep -- Wamasu
    [37178] = true,  -- Sweep -- Wamasu
    [21951] = true,  -- Repulsion Shock -- Wamasu
    [21952] = true,  -- Repulsion Shock -- Wamasu
    [22045] = true,  -- Static -- Wamasu
    [21956] = true,  -- Charge -- Wamasu
    [21957] = true,  -- Charge -- Wamasu
    [48556] = true,  -- Focused Charge -- Wamasu
    [21960] = true,  -- Focused Charge -- Wamasu
    [21964] = true,  -- Charge -- Wamasu
    [21963] = true,  -- Charge -- Wamasu
    [21961] = true,  -- Charge -- Wamasu
    [21967] = true,  -- Charge -- Wamasu
    [21962] = true,  -- Charge -- Wamasu
    [21959] = true,  -- Charge -- Wamasu

    [55868] = true,  -- Sweep (Wamasu - Boss)
    [55870] = true,  -- Sweep (Wamasu - Boss)
    [55869] = true,  -- Sweep (Wamasu - Boss)
    [55866] = true,  -- Repulsion Shock (Wamasu - Boss)
    [55867] = true,  -- Repulsion Shock (Wamasu - Boss)
    [55850] = true,  -- Impending Storm (Wamasu - Boss)
    [55851] = true,  -- Impending Storm (Wamasu - Boss)
    [55852] = true,  -- Impending Storm (Wamasu - Boss)
    [55853] = true,  -- Impending Storm (Wamasu - Boss)
    [55854] = true,  -- Impending Storm (Wamasu - Boss)
    [55855] = true,  -- Impending Storm (Wamasu - Boss)
    [55857] = true,  -- Impending Storm (Wamasu - Boss)
    [55856] = true,  -- Impending Storm (Wamasu - Boss)
    [55860] = true,  -- Ball Lightning (Wamasu - Boss)
    [55864] = true,  -- Storm Bound (Wamasu - Boss)
    [55862] = true,  -- Storm Bound (Wamasu - Boss)
    [55863] = true,  -- Storm Bound (Wamasu - Boss)
    [55861] = true,  -- Storm Bound (Wamasu - Boss)
    [64277] = true,  -- Storm Bound Fx (Wamasu - Boss)

    [44781] = true,  -- Swipe -- Welwa
    [45937] = true,  -- Cleave -- Welwa
    [44791] = true,  -- Rear Kick -- Welwa
    [44792] = true,  -- Rear Kick -- Welwa
    [47942] = true,  -- Charge -- Welwa
    [50714] = true,  -- Focused Charge -- Welwa
    [52417] = true,  -- Charge -- Welwa
    [45987] = true,  -- Focused Charge -- Welwa
    [45990] = true,  -- Charge -- Welwa
    [45986] = true,  -- Charge -- Welwa
    [45991] = true,  -- Charge -- Welwa
    [52828] = true,  -- Charge -- Welwa
    [45984] = true,  -- Charge -- Welwa
    [52829] = true,  -- Charge -- Welwa
    [51842] = true,  -- Snare Weakness -- Welwa
    [51843] = true,  -- CON_Knockback&Knockdown -- Welwa
    [44782] = true,  -- Roll Dodge -- Welwa
    [48697] = true,  -- Roll Dodge -- Welwa
    [48698] = true,  -- Roll Dodge -- Welwa

    [4022] = true,   -- Bite -- Wolf
    [42844] = true,  -- Rotbone -- Wolf
    [14523] = true,  -- Helljoint -- Wolf
    [75818] = true,  -- Helljoint -- Wolf
    [13808] = true,  -- Call of the Pack -- Wolf
    [45720] = true,  -- Call of the Pack -- Wolf
    [45721] = true,  -- Call of the Pack -- Wolf
    [14272] = true,  -- Call of the Pack -- Wolf
    [14273] = true,  -- Call of the Pack -- Wolf
    [45751] = true,  -- Call of the Pack -- Jackal
    [45753] = true,  -- Call of the Pack -- Jackal
    [26658] = true,  -- Call of the Pack -- Jackal
    -- [26659] = true, -- Call of the Pack -- Jackal
    [4114] = true,   -- Howl -- Wolf

    [76319] = true,  -- Backstab -- Dire Wolf
    [80382] = true,  -- Bite -- Dire Wolf
    [80383] = true,  -- Bite -- Dire Wolf
    [76307] = true,  -- Lunge -- Dire Wolf
    [76308] = true,  -- Lunge -- Dire Wolf
    [76303] = true,  -- Nip -- Dire Wolf
    [76304] = true,  -- Nip -- Dire Wolf
    [76305] = true,  -- Gnash -- Dire Wolf
    [76306] = true,  -- Gnash -- Dire Wolf
    [76311] = true,  -- Harry -- Dire Wolf
    [85656] = true,  -- Harry -- Dire Wolf
    [76312] = true,  -- Harry -- Dire Wolf
    [76313] = true,  -- Harry -- Dire Wolf
    [76317] = true,  -- Harry -- Dire Wolf
    [80568] = true,  -- Harry -- Dire Wolf
    [80569] = true,  -- Harry -- Dire Wolf
    [80570] = true,  -- Harry -- Dire Wolf
    [80571] = true,  -- Harry -- Dire Wolf
    [134764] = true, -- Harry -- Dire Wolf
    [134768] = true, -- Harry -- Dire Wolf
    [134769] = true, -- Harry -- Dire Wolf
    [134770] = true, -- Harry -- Dire Wolf
    [134772] = true, -- Harry -- Dire Wolf
    [76324] = true,  -- Baleful Call -- Dire Wolf
    [76322] = true,  -- Baleful Call -- Dire Wolf

    -------------------------------------
    -- DAEDRA ---------------------------
    -------------------------------------

    [51256] = true,  -- Siphon (Shared Daedra)
    [31115] = true,  -- Summon Dark Anchor (Daedric Synergy)
    [59129] = true,  -- Generic Status Immune (Daedric Synergy)
    [94481] = true,  -- Summon Dark Anchor (Daedric Synergy)
    [31129] = true,  -- Anchor Summon Minions (Daedric Synergy)
    [31367] = true,  -- Daedric Synergy (Daedric Synergy)
    [31130] = true,  -- Daedric Synergy Anchor Minion (Daedric Synergy)
    [58897] = true,  -- Daedric Synergy (Daedric Synergy)
    [68453] = true,  -- Explosive Charge (Daedric Synergy)
    [68449] = true,  -- Explosive Charge (Daedric Synergy)
    [68452] = true,  -- Explosive Charge (Daedric Synergy)

    [48092] = true,  -- Swipe -- Air Atronach
    [48093] = true,  -- Swipe -- Air Atronach
    [48096] = true,  -- Flare -- Air Atronach
    [48121] = true,  -- Heavy Attack -- Air Atronach
    [48137] = true,  -- Tornado -- Air Atronach
    [81912] = true,  -- CL-SS Flame Atronach spawn in -- Air Atronach
    [51261] = true,  -- Combustion -- Air Atronach
    [51262] = true,  -- Air Atronach Flame -- Air Atronach
    [51265] = true,  -- Air Atronach Flame -- Air Atronach
    [51281] = true,  -- Flame Tornado -- Air Atronach
    [51282] = true,  -- Flame Tornado -- Air Atronach
    [49565] = true,  -- CL-SS Storm Atronach spawn in -- Air Atronach
    [51272] = true,  -- Combustion -- Air Atronach
    [51271] = true,  -- Air Atronach Flame -- Air Atronach
    [51270] = true,  -- Air Atronach Flame -- Air Atronach
    [50023] = true,  -- Lightning Rod -- Air Atronach
    [88902] = true,  -- Lightning Rod -- Air Atronach
    [50026] = true,  -- Lightning Rod -- Air Atronach
    [81936] = true,  -- CL-SS Frost Atronach spawn in -- Air Atronach
    [51268] = true,  -- Combustion -- Air Atronach
    [51269] = true,  -- Air Atronach Flame -- Air Atronach
    [51267] = true,  -- Air Atronach Flame -- Air Atronach
    [50021] = true,  -- Ice Vortex -- Air Atronach
    [50022] = true,  -- Ice Vortex -- Air Atronach

    [9743] = true,   -- Entropic Touch -- Banekin
    [9747] = true,   -- Dire Wound -- Banekin
    [9748] = true,   -- Envelop -- Banekin
    [9749] = true,   -- Envelop -- Banekin

    [4798] = true,   -- Headbutt -- Clannfear
    [4799] = true,   -- Tail Spike -- Clannfear
    [84443] = true,  -- Tail Spike -- Clannfear
    [93745] = true,  -- Rending Leap -- Clannfear
    [93746] = true,  -- Rending Leap -- Clannfear
    [94899] = true,  -- Rending Leap -- Clannfear
    [93750] = true,  -- Rending Leap -- Clannfear
    [93748] = true,  -- Rending Leap Ranged -- Clannfear
    [91395] = true,  -- Devour -- Clannfear
    [91398] = true,  -- Devour -- Clannfear
    [91396] = true,  -- Devour -- Clannfear

    [26551] = true,  -- Strike -- Daedric Titan
    [32852] = true,  -- Scourge Bolt -- Daedric Titan
    [26641] = true,  -- Soul Flame -- Daedric Titan
    [32696] = true,  -- Soul Flame -- Daedric Titan
    [35280] = true,  -- Soul Flame -- Daedric Titan
    [35277] = true,  -- Soul Flame -- Daedric Titan
    [73437] = true,  -- Soul Flame -- Daedric Titan
    [35278] = true,  -- Soul Flame -- Daedric Titan
    [35524] = true,  -- Close -- Daedric Titan
    [34405] = true,  -- Swallowing Souls -- Daedric Titan
    [34406] = true,  -- Swallowing Souls -- Daedric Titan
    [34407] = true,  -- Swallowing Souls -- Daedric Titan
    [26554] = true,  -- Wing Gust -- Daedric Titan
    [33085] = true,  -- Wing Gust -- Daedric Titan
    [33086] = true,  -- Wing Gust -- Daedric Titan

    [4750] = true,   -- Jagged Claw -- Daedroth
    [4778] = true,   -- Fiery Jaws -- Daedroth
    [4771] = true,   -- Fiery Breath -- Daedroth
    [4772] = true,   -- Fiery Breath -- Daedroth
    [91946] = true,  -- Ground Tremor -- Daedroth
    [91947] = true,  -- Ground Tremor -- Daedroth
    [91952] = true,  -- Ground Tremor -- Daedroth
    [91950] = true,  -- Ground Tremor -- Daedroth
    [91955] = true,  -- Ground Tremor -- Daedroth
    [91956] = true,  -- Ground Tremor -- Daedroth
    [91953] = true,  -- Ground Tremor -- Daedroth
    [91949] = true,  -- Ground Tremor -- Daedroth
    [91937] = true,  -- Burst of Embers -- Daedroth
    [91939] = true,  -- Burst of Embers -- Daedroth
    [91941] = true,  -- Burst of Embers -- Daedroth
    [91940] = true,  -- Burst of Embers -- Daedroth
    [91943] = true,  -- Burst of Embers -- Daedroth
    [91942] = true,  -- Burst of Embers -- Daedroth
    [91938] = true,  -- Burst of Embers -- Daedroth

    [15157] = true,  -- Flare -- Flame Atronach
    [12254] = true,  -- Flare -- Flame Atronach
    [26324] = true,  -- Lava Geyser -- Flame Atronach
    [26326] = true,  -- Lava Geyser -- Flame Atronach
    [26325] = true,  -- Lava Geyser -- Flame Atronach
    [4891] = true,   -- Radiance -- Flame Atronach
    [4491] = true,   -- Radiance -- Flame Atronach
    [26319] = true,  -- Combustion -- Flame Atronach
    [50216] = true,  -- Combustion -- Flame Atronach
    [50215] = true,  -- Combustion -- Flame Atronach

    [4813] = true,   -- Claw -- Flesh Atronach
    [63275] = true,  -- Claw -- Flesh Atronach
    [16524] = true,  -- Stomp -- Flesh Atronach
    [63276] = true,  -- Stomp -- Flesh Atronach
    [4829] = true,   -- Fire Brand -- Flesh Atronach
    [35413] = true,  -- Fire Brand -- Flesh Atronach
    [4817] = true,   -- Unyielding Mace -- Flesh Atronach
    [65234] = true,  -- Snare Atronach -- Flesh Atronach
    [20226] = true,  -- Stun -- Flesh Atronach
    [27326] = true,  -- Unyielding Mace -- Flesh Atronach
    [23077] = true,  -- Bleeding -- Flesh Atronach

    [67123] = true,  -- Tremor -- Flesh Colossus
    [67637] = true,  -- Falling Debris Projectile -- Flesh Colossus
    [67636] = true,  -- Falling Debris -- Flesh Colossus
    [67626] = true,  -- Debris Target 1 -- Flesh Colossus
    [67627] = true,  -- Debris Target 2 -- Flesh Colossus
    [67628] = true,  -- Debris Target 3 -- Flesh Colossus
    [67629] = true,  -- Debris Target 4 -- Flesh Colossus
    [66869] = true,  -- Pin -- Flesh Colossus
    [67076] = true,  -- Self Snare -- Flesh Colossus
    [65709] = true,  -- Pin -- Flesh Colossus
    [65735] = true,  -- Maisma Channel -- Flesh Colossus
    [65747] = true,  -- Miasmic Cloud Target -- Flesh Colossus
    [50341] = true,  -- Miasma Pool -- Flesh Colossus
    [65746] = true,  -- Miasma Pool -- Flesh Colossus
    [53233] = true,  -- Miasma Pool -- Flesh Colossus
    [67872] = true,  -- Sweep -- Flesh Colossus
    [68824] = true,  -- Sweep -- Flesh Colossus
    [68813] = true,  -- Sweep Knockbavck -- Flesh Colossus
    [67829] = true,  -- Sweep Line Origin -- Flesh Colossus
    [67831] = true,  -- Sweep Line 1 -- Flesh Colossus
    [67834] = true,  -- Sweep Line 2 -- Flesh Colossus
    [67835] = true,  -- Sweep Line 3 -- Flesh Colossus
    [67842] = true,  -- Sweep Shockwave -- Flesh Colossus
    [76128] = true,  -- Stumble Forward -- Flesh Colossus
    [76139] = true,  -- Stumble Forward -- Flesh Colossus
    [76140] = true,  -- Stumble Forward -- Flesh Colossus
    [76130] = true,  -- Stumble Forward -- Flesh Colossus
    [76131] = true,  -- Stumble Forward -- Flesh Colossus
    [76129] = true,  -- Stumble Forward -- Flesh Colossus
    [65755] = true,  -- Staggered -- Flesh Colossus
    [76133] = true,  -- Stumble Forward -- Flesh Colossus
    [68826] = true,  -- Staggered -- Flesh Colossus
    [67766] = true,  -- Ghastly Bellow -- Flesh Colossus
    [67772] = true,  -- Enraged -- Flesh Colossus
    [49430] = true,  -- Smash -- Flesh Colossus
    [49429] = true,  -- Claw -- Flesh Colossus

    [17069] = true,  -- Ice Spear -- Frost Atronach
    [5009] = true,   -- Ice Shards -- Frost Atronach
    [33549] = true,  -- Chilling Aura -- Frost Atronach
    [33551] = true,  -- Chilling Aura -- Frost Atronach
    [5017] = true,   -- Hoarfrost Fist -- Frost Atronach
    [44906] = true,  -- Hoarfrost Fist -- Frost Atronach
    [44907] = true,  -- Hoarfrost Fist -- Frost Atronach
    [44908] = true,  -- Hoarfrost Fist -- Frost Atronach
    [33502] = true,  -- Frozen Ground -- Frost Atronach
    [33506] = true,  -- Frozen Ground -- Frost Atronach
    [33508] = true,  -- Frozen Ground -- Frost Atronach
    [33509] = true,  -- Frozen Ground -- Frost Atronach
    [33510] = true,  -- Frozen Ground -- Frost Atronach
    [129960] = true, -- Frozen Ground -- Frost Atronach
    [129959] = true, -- Frozen Ground -- Frost Atronach
    [51645] = true,  -- Frozen Ground -- Frost Atronach
    [51646] = true,  -- Frozen Ground -- Frost Atronach

    [65926] = true,  -- Slash -- Grievous Twilight
    [65845] = true,  -- Rend -- Grievous Twilight
    [66643] = true,  -- Rend -- Grievous Twilight
    [50596] = true,  -- Shadow Bolt -- Grievous Twilight
    [50626] = true,  -- Shadow Strike -- Grievous Twilight
    [60792] = true,  -- Grevious Root Immune -- Grievous Twilight
    [50628] = true,  -- Shadow Strike -- Grievous Twilight
    [50635] = true,  -- Shadow Strike -- Grievous Twilight
    [65889] = true,  -- Shadow Strike -- Grievous Twilight
    [65893] = true,  -- Grevious Root Immune -- Grievous Twilight
    [65891] = true,  -- Shadow Strike -- Grievous Twilight
    [65896] = true,  -- Shadow Strike -- Grievous Twilight
    [65895] = true,  -- Shadow Strike -- Grievous Twilight
    [50609] = true,  -- Blend into Shadows -- Grievous Twilight

    [11076] = true,  -- Chasten -- Harvester
    [11079] = true,  -- Black Winter -- Harvester
    [26006] = true,  -- Black Winter -- Harvester
    [26007] = true,  -- Black Winter -- Harvester
    [26009] = true,  -- Black Winter -- Harvester
    [26008] = true,  -- Black Winter -- Harvester
    [74794] = true,  -- Staggered -- Harvester
    [11083] = true,  -- The Feast -- Harvester
    [26110] = true,  -- The Feast -- Harvester
    [67206] = true,  -- Summon Target
    [67200] = true,  -- Summon Projectile
    [67212] = true,  -- Summon Target
    [67213] = true,  -- Summon Projectile
    [67220] = true,  -- Summon Target
    [67221] = true,  -- Summon Projectile
    [67230] = true,  -- Summon Target
    [67231] = true,  -- Summon Projectile
    [26017] = true,  -- Creeping Doom -- Harvester
    [26018] = true,  -- Creeping Doom -- Harvester
    [88070] = true,  -- Creeping Doom -- Harvester
    [26069] = true,  -- The Feast Registered Trigger -- Harvester
    [25987] = true,  -- The Feast -- Harvester
    [25988] = true,  -- The Feast -- Harvester
    [25989] = true,  -- The Feast -- Harvester
    [25990] = true,  -- The Feast -- Harvester
    [26085] = true,  -- The Feast Tick -- Harvester
    [26084] = true,  -- The Feast -- Harvester

    [8204] = true,   -- Strike -- Ogrim
    [8205] = true,   -- Regeneration -- Ogrim
    [70581] = true,  -- Regeneration -- Ogrim
    [24689] = true,  -- Body Slam -- Ogrim
    [24690] = true,  -- Body Slam -- Ogrim
    [48553] = true,  -- Focused Charge -- Ogrim
    [24694] = true,  -- Body Slam -- Ogrim
    [24691] = true,  -- Body Slam -- Ogrim
    [24699] = true,  -- Body Slam -- Ogrim
    [24693] = true,  -- Body Slam -- Ogrim
    [24700] = true,  -- Body Slam -- Ogrim
    [24695] = true,  -- Body Slam -- Ogrim
    [73380] = true,  -- Been Blocked -- Ogrim
    [24692] = true,  -- Body Slam -- Ogrim
    [91848] = true,  -- Stomp -- Ogrim
    [91850] = true,  -- Stomp -- Ogrim
    [91851] = true,  -- Stomp -- Ogrim
    [91855] = true,  -- Boulder Toss -- Ogrim
    [127630] = true, -- Boulder Toss -- Ogrim

    [6158] = true,   -- Flare -- Scamp
    [6166] = true,   -- Heat Wave -- Scamp
    [6167] = true,   -- Heat Wave -- Scamp
    [6160] = true,   -- Rain of Fire -- Scamp
    [6162] = true,   -- Rain of Fire -- Scamp

    [8778] = true,   -- Strike -- Spider Daedra
    [8808] = true,   -- Spit -- Spider Daedra
    [8779] = true,   -- Lightning Onslaught -- Spider Daedra
    [91901] = true,  -- Lightning Onslaught -- Spider Daedra
    [91903] = true,  -- Lightning Onslaught -- Spider Daedra
    [91904] = true,  -- Lightning Onslaught -- Spider Daedra
    [38658] = true,  -- Lightning Onslaught -- Spider Daedra
    [8782] = true,   -- Lightning Storm -- Spider Daedra
    [20530] = true,  -- Lightning Storm -- Spider Daedra
    [8773] = true,   -- Summon Spiderling -- Spider Daedra
    [89303] = true,  -- Summon Spiderling -- Spider Daedra
    [89301] = true,  -- Summon Spiderling -- Spider Daedra
    [89302] = true,  -- Summon Spiderling -- Spider Daedra
    [89300] = true,  -- Summon Spiderling -- Spider Daedra
    [89299] = true,  -- Summon Spiderling -- Spider Daedra
    [89306] = true,  -- Web -- Spider Daedra
    [89307] = true,  -- Web -- Spider Daedra

    [4858] = true,   -- Bash -- Storm Atronach
    [13898] = true,  -- Strike -- Storm Atronach
    [35220] = true,  -- Impending Storm -- Storm Atronach
    [35222] = true,  -- Impending Storm -- Storm Atronach
    [35228] = true,  -- Impending Storm -- Storm Atronach
    [35229] = true,  -- Impending Storm -- Storm Atronach
    [35230] = true,  -- Impending Storm -- Storm Atronach
    [35231] = true,  -- Impending Storm -- Storm Atronach
    [35234] = true,  -- Impending Storm -- Storm Atronach
    [35247] = true,  -- Impending Storm -- Storm Atronach
    [4864] = true,   -- Storm Bound -- Storm Atronach
    [129915] = true, -- Storm Bound -- Storm Atronach
    [35240] = true,  -- Storm Bound -- Storm Atronach
    [12287] = true,  -- Storm Bound -- Storm Atronach
    [12288] = true,  -- Storm Bound -- Storm Atronach
    [12286] = true,  -- Storm Bound -- Storm Atronach

    [7095] = true,   -- Heavy Attack -- Xivilai
    [44904] = true,  -- Empower Weapon: Frost -- Xivilai
    [83072] = true,  -- Frozen Edge -- Xivilai
    [49203] = true,  -- Frozen Weapon -- Xivilai
    [88947] = true,  -- Lightning Grasp -- Xivilai
    [88951] = true,  -- Lightning Grasp -- Xivilai
    [88949] = true,  -- Lightning Grasp -- Xivilai
    [88948] = true,  -- Lightning Grasp -- Xivilai
    [111955] = true, -- Lightning Grasp -- Xivilai
    [7100] = true,   -- Hand of Flame -- Xivilai
    [25747] = true,  -- Hand of Flame -- Xivilai
    [25749] = true,  -- Hand of Flame -- Xivilai
    [88968] = true,  -- Hand of Flame -- Xivilai
    [88969] = true,  -- Hand of Flame -- Xivilai
    [25728] = true,  -- Hand of Flame -- Xivilai
    [7101] = true,   -- Summon Daedra -- Xivilai
    [88976] = true,  -- Summon Daedra -- Xivilai
    [25726] = true,  -- Summon Daedra -- Xivilai
    [88974] = true,  -- Summon Daedra -- Xivilai
    -- [88973] = true,  -- Summon Daedra -- Xivilai
    [89232] = true,  -- Summon Daedra -- Xivilai

    [4652] = true,   -- Gaze -- Watcher
    [4653] = true,   -- Shockwave -- Watcher
    [43817] = true,  -- Shockwave Snare -- Watcher
    [95855] = true,  -- Shockwave -- Watcher
    [95856] = true,  -- Shockwave -- Watcher
    [53880] = true,  -- Shockwave -- Watcher
    [9219] = true,   -- Doom-Truth's Gaze -- Watcher
    [95915] = true,  -- Doom-Truth's Gaze -- Watcher
    [95916] = true,  -- Doom-Truth's Gaze -- Watcher
    [95917] = true,  -- Doom-Truth's Gaze -- Watcher
    [95918] = true,  -- Doom-Truth's Gaze -- Watcher
    [95890] = true,  -- Doom-Truth's Gaze -- Watcher
    [9220] = true,   -- Doom-Truth's Gaze -- Watcher
    [14518] = true,  -- Doom-Truth's Gaze -- Watcher
    [14425] = true,  -- Doom-Truth's Gaze -- Watcher
    [14462] = true,  -- Doom-Truth's Gaze -- Watcher
    [14426] = true,  -- Doom-Truth's Gaze -- Watcher
    [14546] = true,  -- Doom-Truth's Gaze -- Watcher

    [12062] = true,  -- Kick -- Winged Twilight
    [13690] = true,  -- Kick -- Winged Twilight
    [6410] = true,   -- Tail Clip -- Winged Twilight
    [63612] = true,  -- Tail Clip -- Winged Twilight
    [6412] = true,   -- Dusk's Howl -- Winged Twilight

    -------------------------------------
    -- UNDEAD ---------------------------
    -------------------------------------

    [38828] = true,  -- Desecrated Ground -- Desecrated Ground
    [69900] = true,  -- Desecrated Ground -- Desecrated Ground
    [69905] = true,  -- Desecrated Ground -- Desecrated Ground
    [38829] = true,  -- Desecrated Ground Bonus -- Desecrated Ground
    [38832] = true,  -- Undead Synergy -- Desecrated Ground
    [38831] = true,  -- Desecrated Ground -- Desecrated Ground
    [38834] = true,  -- Desecrated Ground Snare -- Desecrated Ground
    [69950] = true,  -- Desecrated Ground -- Desecrated Ground

    [8550] = true,   -- Slash -- Bloodfiend
    [8551] = true,   -- Slash -- Bloodfiend
    [8564] = true,   -- Rending Slash -- Bloodfiend
    [8554] = true,   -- Flurry -- Bloodfiend
    [9194] = true,   -- Flurry -- Bloodfiend
    [8569] = true,   -- Devastating Leap -- Bloodfiend
    [32023] = true,  -- Generic Stagger Enemy -- Bloodfiend
    [48940] = true,  -- Ambush -- Bloodfiend

    [5028] = true,   -- Strike -- Bone Colossus
    [5050] = true,   -- Bone Saw -- Bone Colossus
    [30590] = true,  -- Bone Saw -- Bone Colossus
    [17206] = true,  -- Bone Saw -- Bone Colossus
    [5030] = true,   -- Voice to Wake the Dead -- Bone Colossus
    [5044] = true,   -- Risen Dead -- Bone Colossus
    [88133] = true,  -- Voice to Wake the Dead -- Bone Colossus
    [5033] = true,   -- Voice to Wake the Dead -- Bone Colossus
    [5035] = true,   -- Voice to Wake the Dead -- Bone Colossus
    [5036] = true,   -- Voice to Wake the Dead -- Bone Colossus
    [17221] = true,  -- Slap -- Bone Colossus
    [17207] = true,  -- Necromantic Implosion -- Bone Colossus
    [88828] = true,  -- Necromantic Implosion -- Bone Colossus
    [89533] = true,  -- Necromantic Implosion -- Bone Colossus
    [49128] = true,  -- Necromantic Implosion -- Bone Colossus
    [88132] = true,  -- Voice to Wake the Dead -- Bone Colossus

    [72980] = true,  -- Singing Strike -- Defiled Aegis
    [72981] = true,  -- Singing Slice -- Defiled Aegis
    [72979] = true,  -- Dissonant Blow -- Defiled Aegis
    [72995] = true,  -- Symphony of Blades -- Defiled Aegis
    [72996] = true,  -- Symphony of Blades -- Defiled Aegis
    [77612] = true,  -- Symphony of Blades -- Defiled Aegis
    [73020] = true,  -- Shattered Harmony -- Defiled Aegis
    [76180] = true,  -- Shattered Harmony -- Defiled Aegis
    [73021] = true,  -- Shattered Harmony -- Defiled Aegis
    [73025] = true,  -- Tomb Guardian -- Defiled Aegis
    [73322] = true,  -- Shattered Harmony -- Defiled Aegis
    [74993] = true,  -- Shattered Harmony -- Defiled Aegis

    [8812] = true,   -- Double Strike -- Ghost
    [8813] = true,   -- Double Strike -- Ghost
    [18514] = true,  -- Chill Touch -- Ghost
    [18515] = true,  -- Chill Touch -- Ghost
    [18765] = true,  -- Haunting Spectre -- Ghost
    [18766] = true,  -- Haunting Spectre -- Ghost
    [19137] = true,  -- Haunting Spectre -- Ghost
    [19138] = true,  -- Haunting Spectre -- Ghost
    [19140] = true,  -- Haunting Spectre -- Ghost

    [9541] = true,   -- Necrotic Spear -- Lich
    [20756] = true,  -- Defiled Ground -- Lich
    [22521] = true,  -- Defiled Ground -- Lich
    [22523] = true,  -- Defiled Ground -- Lich
    [20812] = true,  -- Defiled Ground -- Lich
    [22525] = true,  -- Defiled Ground -- Lich
    [73925] = true,  -- Soul Cage -- Lich
    [22602] = true,  -- Soul Cage -- Lich
    [73927] = true,  -- Soul Cage -- Lich
    [73928] = true,  -- Soul Cage -- Lich
    [73930] = true,  -- Soul Cage -- Lich
    [73932] = true,  -- Soul Cage -- Lich
    [73933] = true,  -- Soul Cage -- Lich
    [73938] = true,  -- Soul Cage -- Lich
    [73936] = true,  -- Soul Cage -- Lich
    [73935] = true,  -- Soul Cage -- Lich
    [73929] = true,  -- Soul Cage -- Lich
    [73931] = true,  -- Soul Rupture -- Lich
    [73926] = true,  -- Soul Cage -- Lich
    [73937] = true,  -- Soul Cage -- Lich
    [73939] = true,  -- Soul Rupture -- Lich
    [73934] = true,  -- Soul Cage -- Lich

    [49702] = true,  -- Entropic Flare -- Spellfiend
    [50456] = true,  -- Entropic Flare -- Spellfiend
    [50182] = true,  -- Consuming Energy -- Spellfiend
    [50183] = true,  -- Consuming Energy -- Spellfiend
    [52398] = true,  -- Consuming Energy -- Spellfiend

    [68735] = true,  -- Vampiric Drain -- Vampire
    [68750] = true,  -- Vampiric Drain -- Vampire
    [68765] = true,  -- Vampiric Drain -- Vampire
    [68771] = true,  -- Vampiric Drain Heal Dummy -- Vampire
    [68772] = true,  -- Vampiric Drain -- Vampire

    [2849] = true,   -- Claw Slash -- Werewolf
    [4651] = true,   -- Claw Slash -- Werewolf
    [2850] = true,   -- Swipe -- Werewolf
    [2867] = true,   -- Crushing Leap -- Werewolf
    [45576] = true,  -- Generic Stagger Enemy -- Werewolf
    [3415] = true,   -- Flurry -- Werewolf
    [113156] = true, -- Flurry -- Werewolf
    [13950] = true,  -- Flurry -- Werewolf
    [9467] = true,   -- Flurry -- Werewolf
    [60636] = true,  -- Flurry -- Werewolf
    [44055] = true,  -- Devour -- Werewolf
    [44054] = true,  -- Devour -- Werewolf
    [5785] = true,   -- Blood Scent -- Werewolf
    [58529] = true,  -- Blood Scent -- Werewolf
    [27329] = true,  -- Houndsman Transform -- Werewolf
    [27344] = true,  -- Houndsman Regen -- Werewolf
    [27345] = true,  -- Houndsman Stun -- Werewolf
    [27362] = true,  -- Houndsman Delay -- Werewolf
    [27365] = true,  -- MT Houndsman Removal -- Werewolf
    [27382] = true,  -- MT Houndsman -- Werewolf

    [4323] = true,   -- Ice Bolt -- Wraith
    [4337] = true,   -- Winter's Reach -- Wraith
    [4346] = true,   -- Winter's Reach -- Wraith
    [43146] = true,  -- Winter's Reach -- Wraith

    [2954] = true,   -- Swipe -- Zombie
    [13972] = true,  -- Swipe -- Zombie
    [63614] = true,  -- Swipe -- Zombie
    [2969] = true,   -- Pound -- Zombie
    [2960] = true,   -- Vomit -- Zombie
    [30347] = true,  -- Vomit -- Zombie

    -------------------------------------
    -- DWEMER ---------------------------
    -------------------------------------

    [20238] = true, -- Move Back -- Synergy (Dwemer Spider)
    [19970] = true, -- Static Field -- Synergy (Dwemer Spider)
    [19997] = true, -- Static Field -- Synergy (Dwemer Spider)
    [20506] = true, -- Overcharge Trigger -- Synergy (Dwemer Spider)
    [27333] = true, -- Overcharge -- Synergy (Dwemer Spider)
    [20207] = true, -- Overcharge -- Synergy (Another Dwemer)
    [27458] = true, -- tell others -- Synergy (Another Dwemer)
    [20206] = true, -- Overcharge -- Synergy (Another Dwemer)
    [20221] = true, -- Overcharge -- Synergy (Another Dwemer)
    [20505] = true, -- Overcharge -- Synergy (Dwemer Spider - Source)
    [20222] = true, -- Overcharge -- Synergy (Another Dwemer)
    [20504] = true, -- Overcharge -- Synergy (Dwemer Spider - Source)
    [20220] = true, -- Overcharge -- Synergy (Dwemer Spider - Other)
    [52679] = true, -- Overcharge -- Synergy (Dwemer Sphere)
    [52680] = true, -- Overcharge -- Synergy (Dwemer Centurion)

    [11245] = true, -- Axe -- Dwemer Centurion
    [13783] = true, -- Hammer -- Dwemer Centurion
    [11247] = true, -- Sweeping Spin -- Dwemer Centurion
    [43554] = true, -- Sweeping Spin -- Dwemer Centurion
    [11262] = true, -- Sweeping Spin -- Dwemer Centurion
    [11246] = true, -- Steam Breath -- Dwemer Centurion
    [11282] = true, -- Steam Breath -- Dwemer Centurion

    [64423] = true, -- Sparks -- Dwemer Sentry
    [64463] = true, -- Static Shield -- Dwemer Sentry
    [84312] = true, -- Static Shield -- Dwemer Sentry
    [70133] = true, -- Static Shield -- Dwemer Sentry
    [64556] = true, -- Static Eruption -- Dwemer Sentry
    [64489] = true, -- Find Turret -- Dwemer Sentry
    [64508] = true, -- Find Turret -- Dwemer Sentry
    [64460] = true, -- Static Shield -- Dwemer Sentry
    [70134] = true, -- Static Shield -- Dwemer Sentry
    [68790] = true, -- Static Shield Explosion -- Dwemer Sentry
    [64479] = true, -- Thunderbolt -- Dwemer Sentry
    [64543] = true, -- Thunderbolt -- Dwemer Sentry

    [7484] = true,  -- Blade -- Dwemer Sphere
    [7485] = true,  -- Dart -- Dwemer Sphere
    [16031] = true, -- Ricochet Wave -- Dwemer Sphere
    [29832] = true, -- Ricochet Wave -- Dwemer Sphere
    [7520] = true,  -- Steam Wall -- Dwemer Sphere
    [84216] = true, -- Steam Wall -- Dwemer Sphere
    [7544] = true,  -- Quake -- Dwemer Sphere
    [46053] = true, -- Quake -- Dwemer Sphere

    [7719] = true,  -- Shocking Touch -- Dwemer Spider
    [20507] = true, -- Double Strike -- Dwemer Spider
    [20508] = true, -- Double Strike -- Dwemer Spider
    -- [7717] = true, -- Detonation -- Dwemer Spider
    [15206] = true, -- Detonation -- Dwemer Spider
    [84019] = true, -- Detonation -- Dwemer Spider
    [13536] = true, -- Detonation -- Dwemer Spider

    -------------------------------------
    -- INSECTS --------------------------
    -------------------------------------

    [5278] = true,  -- Bite -- Assassin Beetle
    [6137] = true,  -- Laceration -- Assassin Beetle
    [51736] = true, -- Bleeding -- Assassin Beetle
    [51735] = true, -- Bleeding -- Assassin Beetle
    [44198] = true, -- Ambush -- Assassin Beetle
    [5268] = true,  -- Collywobbles -- Assassin Beetle
    [5273] = true,  -- Collywobbles -- Assassin Beetle
    [13677] = true, -- Acid Blood -- Assassin Beetle
    [13681] = true, -- Acid Blood -- Assassin Beetle
    [13680] = true, -- Acid Blood -- Assassin Beetle
    [29822] = true, -- Shadow Step -- Assassin Beetle
    [91789] = true, -- Ambush -- Assassin Beetle
    [91791] = true, -- Feast -- Assassin Beetle

    [6754] = true,  -- Pincer -- Giant Scorpion
    [6755] = true,  -- Sting -- Giant Scorpion
    [13671] = true, -- Sting -- Giant Scorpion
    [6757] = true,  -- Blurred Strike -- Giant Scorpion
    [9040] = true,  -- Blurred Strike -- Giant Scorpion
    [6756] = true,  -- Paralyze -- Giant Scorpion
    [12312] = true, -- Snare -- Giant Scorpion
    [6758] = true,  -- Hardened Carapace -- Giant Scorpion

    [4731] = true,  -- Bite -- Giant Spider
    [44086] = true, -- Fire Runes -- Giant Spider
    [5789] = true,  -- Poisonous Burst -- Giant Spider
    [5790] = true,  -- Poisonous Burst -- Giant Spider
    [5685] = true,  -- Corrosive Bite -- Giant Spider
    [8087] = true,  -- Poison Spray -- Giant Spider
    [8088] = true,  -- Poison Spray -- Giant Spider
    [4730] = true,  -- Spit -- Giant Spider
    [4737] = true,  -- Encase -- Giant Spider
    [47319] = true, -- Encase -- Giant Spider
    [47320] = true, -- Encase -- Giant Spider
    [47318] = true, -- Encase -- Giant Spider
    [13382] = true, -- Devour -- Giant Spider
    [20541] = true, -- Devour -- Giant Spider
    [13381] = true, -- Devour -- Giant Spider
    [13380] = true, -- Devour -- Giant Spider

    [9225] = true,  -- Bite -- Giant Wasp
    [9226] = true,  -- Sting -- Giant Wasp
    [25103] = true, -- Charge -- Giant Wasp
    [25110] = true, -- Charge -- Giant Wasp
    [48559] = true, -- Focused Charge -- Giant Wasp
    [48557] = true, -- Charge -- Giant Wasp
    [25114] = true, -- Focused Charge -- Giant Wasp
    [25119] = true, -- Charge -- Giant Wasp
    [25116] = true, -- Charge -- Giant Wasp
    [25113] = true, -- Charge -- Giant Wasp
    [25120] = true, -- Charge -- Giant Wasp
    [25115] = true, -- Charge -- Giant Wasp
    [25111] = true, -- Charge -- Giant Wasp
    [25112] = true, -- Charge -- Giant Wasp
    [9229] = true,  -- Inject Larva -- Giant Wasp
    [9237] = true,  -- Larva Gestation -- Giant Wasp
    [54685] = true, -- Young Wasp Initialize -- Giant Wasp
    [9238] = true,  -- Larva Burst -- Giant Wasp
    [9242] = true,  -- Larva Burst -- Giant Wasp
    [10392] = true, -- Larva Burst -- Giant Wasp

    [6788] = true,  -- Bite -- Hoarvor
    [6800] = true,  -- Bloodletting -- Hoarvor
    [42292] = true, -- Bloodletting -- Hoarvor
    [6795] = true,  -- Latch On -- Hoarvor
    [13585] = true, -- Latch On -- Hoarvor
    [13587] = true, -- Latch On -- Hoarvor

    [61248] = true, -- Necrotic Explosion -- Necrotic Hoarvor
    [61243] = true, -- Vile Bite -- Necrotic Hoarvor
    [69392] = true, -- Vile Bite Poison -- Necrotic Hoarvor
    [61244] = true, -- Fevered Retch -- Necrotic Hoarvor
    [61245] = true, -- Fevered Retch -- Necrotic Hoarvor
    [61360] = true, -- Infectious Swarm -- Necrotic Hoarvor
    [61380] = true, -- Infectious Swarm -- Necrotic Hoarvor
    [61377] = true, -- Infectious Swarm -- Necrotic Hoarvor
    [61372] = true, -- Infectious Swarm -- Necrotic Hoarvor
    [61374] = true, -- Infectious Swarm -- Necrotic Hoarvor
    [61375] = true, -- Infectious Swarm Snare -- Necrotic Hoarvor
    [61376] = true, -- Infectious Swarm -- Necrotic Hoarvor
    [61427] = true, -- Necrotic Explosion -- Necrotic Hoarvor
    [61249] = true, -- Necrotic Explosion -- Necrotic Hoarvor
    [61388] = true, -- Necrotic Explosion Snare -- Necrotic Hoarvor

    [73166] = true, -- Bite -- Kotu Gava
    [73214] = true, -- Bite -- Kotu Gava
    [73215] = true, -- Bite -- Kotu Gava

    [73192] = true, -- Swarmburst -- Kotu Gava Broodmother
    [73184] = true, -- Vile Spit -- Kotu Gava Broodmother
    [73172] = true, -- Swarm -- Kotu Gava Broodmother
    [73173] = true, -- Swarm -- Kotu Gava Broodmother
    [73193] = true, -- Swarm -- Kotu Gava Broodmother
    [73177] = true, -- Swarmburst -- Kotu Gava Broodmother
    [73174] = true, -- Swarm -- Kotu Gava Broodmother
    [73176] = true, -- Swarm -- Kotu Gava Broodmother
    [73175] = true, -- Swarm -- Kotu Gava Broodmother
    [76579] = true, -- Bite -- Kotu Gava Broodmother
    [76580] = true, -- Bite -- Kotu Gava Broodmother
    [76581] = true, -- Bite -- Kotu Gava Broodmother
    [73199] = true, -- Swarmburst -- Kotu Gava Broodmother
    [73194] = true, -- Swarmburst -- Kotu Gava Broodmother
    [73198] = true, -- Swarmburst -- Kotu Gava Broodmother

    [8276] = true,  -- Bite -- Kwama Scrib
    [83977] = true, -- Bite -- Kwama Scrib
    [8272] = true,  -- Spit -- Kwama Scrib
    [47838] = true, -- Contagion -- Kwama Scrib
    [10916] = true, -- Burrow -- Kwama Scrib
    [42869] = true, -- Burrow -- Kwama Scrib

    [9287] = true,  -- Bite -- Kwama Worker
    [9291] = true,  -- Pounce -- Kwama Worker
    [83953] = true, -- Pounce -- Kwama Worker
    [14839] = true, -- Charge -- Kwama Worker
    [14841] = true, -- Charge -- Kwama Worker
    [48539] = true, -- Focused Charge -- Kwama Worker
    [14846] = true, -- Focused Charge -- Kwama Worker
    [18808] = true, -- Charge -- Kwama Worker
    [18810] = true, -- Charge -- Kwama Worker
    [14844] = true, -- Charge -- Kwama Worker
    [14845] = true, -- Charge -- Kwama Worker
    [18814] = true, -- Charge -- Kwama Worker
    [48540] = true, -- Charge -- Kwama Worker
    [18548] = true, -- Charge -- Kwama Worker
    [18546] = true, -- Shattered Ground -- Kwama Worker

    [15011] = true, -- Swipe -- Kwama Warrior
    [9763] = true,  -- Smash -- Kwama Warrior
    [9764] = true,  -- Smash -- Kwama Warrior
    [9769] = true,  -- Excavation -- Kwama Warrior
    [18585] = true, -- Excavation -- Kwama Warrior
    [27463] = true, -- Excavation -- Kwama Warrior
    [49192] = true, -- Excavation -- Kwama Warrior
    [18567] = true, -- Excavation -- Kwama Warrior
    [18568] = true, -- Kwama Scrib Swarm -- Kwama Warrior

    [6127] = true,  -- Bite -- Shalk
    [5260] = true,  -- Flamethrower -- Shalk
    [10947] = true, -- Fiery Breath -- Shalk
    [5252] = true,  -- Fire Bite -- Shalk
    [6129] = true,  -- Fire Bite -- Shalk
    [5262] = true,  -- Burning Ground -- Shalk
    [5265] = true,  -- Burning Ground -- Shalk

    [5308] = true,  -- Thunder Bite -- Thunderbug
    [8429] = true,  -- Zap -- Thunderbug
    [65079] = true, -- Zap -- Thunderbug
    [26379] = true, -- Zap -- Thunderbug
    [26382] = true, -- Bolt -- Thunderbug
    [26412] = true, -- Thunderstrikes -- Thunderbug
    [26414] = true, -- Thunderstrikes -- Thunderbug
    [26428] = true, -- Thunderstrikes -- Thunderbug
    [26436] = true, -- Thunderstrikes -- Thunderbug
    [26437] = true, -- Thunderstrikes -- Thunderbug
    [26426] = true, -- Thunderstrikes -- Thunderbug
    [34981] = true, -- Thunderstrikes -- Thunderbug
    [26416] = true, -- Thunderstrikes -- Thunderbug
    [26418] = true, -- Thunderstrikes -- Thunderbug
    [34980] = true, -- Thunderstrikes -- Thunderbug

    -------------------------------------
    -- MONSTER --------------------------
    -------------------------------------

    [10259] = true,  -- Double Swipe -- Gargoyle
    [32672] = true,  -- Double Swipe -- Gargoyle
    [10270] = true,  -- Quake -- Gargoyle
    [128063] = true, -- Quake -- Gargoyle
    [10271] = true,  -- Quake -- Gargoyle
    [10256] = true,  -- Lacerate -- Gargoyle
    [25716] = true,  -- Stun -- Gargoyle
    [25718] = true,  -- Bleeding -- Gargoyle
    [25714] = true,  -- Vampiric Touch -- Gargoyle
    [25715] = true,  -- Vampiric Touch -- Gargoyle
    [51352] = true,  -- Petrify (Gargoyle)
    [51365] = true,  -- Petrify (Gargoyle)
    [51353] = true,  -- Petrify (Gargoyle)
    [51354] = true,  -- Petrify (Gargoyle)

    [8671] = true,   -- Sweep -- Giant
    [46845] = true,  -- Sweep -- Giant
    [8674] = true,   -- Kick -- Giant
    [26124] = true,  -- Shatter -- Giant
    [26126] = true,  -- Shatter -- Giant
    [26127] = true,  -- Shatter -- Giant
    [26128] = true,  -- Shatter -- Giant
    [26129] = true,  -- Shatter -- Giant
    [127904] = true, -- Crushing Quake -- Giant
    [127909] = true, -- Giant's Maul -- Giant
    [127910] = true, -- Giant's Maul -- Giant
    [127908] = true, -- Obliterate -- Giant

    [2901] = true,   -- Staff Strike -- Hag
    [2786] = true,   -- Steal Essence -- Hag
    [21642] = true,  -- Steal Essence -- Hag
    [3349] = true,   -- Reflective Shadows -- Hag
    [2821] = true,   -- Luring Snare -- Hag
    [32267] = true,  -- Grapple -- Hag
    [32268] = true,  -- Grapple -- Hag

    [10611] = true,  -- Flare -- Hagraven
    [10615] = true,  -- Raven Storm -- Hagraven
    [10616] = true,  -- Raven Storm -- Hagraven
    [12426] = true,  -- Raven Storm -- Hagraven
    [10613] = true,  -- Fire Bomb -- Hagraven
    [10614] = true,  -- Fire Bomb -- Hagraven
    [58220] = true,  -- Surround -- Hagraven
    [58221] = true,  -- Shadow Strike -- Hagraven
    [58222] = true,  -- Shadow Strike -- Hagraven
    [64781] = true,  -- Briar Heart Can Resurrect -- Hagraven
    [64786] = true,  -- Briar Heart Resurrection -- Hagraven
    [64806] = true,  -- Briarheart Resurrection -- Hagraven
    [64800] = true,  -- Briarheart Resurrection -- Hagraven
    [64808] = true,  -- Briarheart Resurrection -- Hagraven
    [65027] = true,  -- Briarheart Resurrection -- Hagraven
    [65028] = true,  -- System Shock -- Hagraven

    [4112] = true,   -- Talon -- Harpy
    [4125] = true,   -- Kick -- Harpy
    [4684] = true,   -- Bolt -- Harpy
    [4123] = true,   -- Wing Slice -- Harpy
    [24369] = true,  -- Wing Slice -- Harpy
    [13515] = true,  -- Wind Gust -- Harpy
    [13516] = true,  -- Wind Gust -- Harpy
    [13517] = true,  -- Wind Gust -- Harpy
    [24604] = true,  -- Charged Ground -- Harpy
    [8628] = true,   -- Charged Ground -- Harpy
    [4689] = true,   -- Lightning Gale -- Harpy
    [4690] = true,   -- Lightning Gale -- Harpy

    [9846] = true,   -- Bite -- Ice Wraith
    [24929] = true,  -- Shard Burst -- Ice Wraith
    [126486] = true, -- Shard Burst -- Ice Wraith
    [126487] = true, -- Shard Burst -- Ice Wraith
    [126490] = true, -- Shard Burst -- Ice Wraith
    [43809] = true,  -- Shard Burst -- Ice Wraith
    [9853] = true,   -- Shard Burst -- Ice Wraith
    [43810] = true,  -- Shard Burst -- Ice Wraith
    [38920] = true,  -- Shard Burst -- Ice Wraith
    [24877] = true,  -- Shard Burst -- Ice Wraith
    [24865] = true,  -- Blood in the Water -- Ice Wraith
    [24866] = true,  -- Blood in the Water -- Ice Wraith
    [48549] = true,  -- Focused Charge -- Ice Wraith
    [24870] = true,  -- Blood in the Water -- Ice Wraith
    [24872] = true,  -- Blood in the Water -- Ice Wraith
    [24869] = true,  -- Blood in the Water -- Ice Wraith
    [46565] = true,  -- Rubble -- Ice Wraith
    [46563] = true,  -- Blood in the Water -- Ice Wraith
    [24867] = true,  -- Blood in the Water -- Ice Wraith

    [14801] = true,  -- Flare -- Imp (Fire)
    [14802] = true,  -- Fireball -- Imp (Fire)
    [17703] = true,  -- Flame Ray -- Imp (Fire)
    [65078] = true,  -- Flame Ray -- Imp (Fire)
    [17706] = true,  -- Flame Ray -- Imp (Fire)

    [7732] = true,   -- Bolt -- Imp (Lightning)
    [13648] = true,  -- Spark -- Imp (Lightning)
    [8884] = true,   -- Zap -- Imp (Lightning)
    [65077] = true,  -- Zap -- Imp (Lightning)
    [14666] = true,  -- Zap -- Imp (Lightning)

    [88906] = true,  -- Frost Bolt -- Imp (Frost)
    [88918] = true,  -- Frostball -- Imp (Frost)
    [81794] = true,  -- Frost Ray -- Imp (Frost)
    [88907] = true,  -- Frost Ray -- Imp (Frost)
    [88915] = true,  -- Frost Ray -- Imp (Frost)
    [88917] = true,  -- Frost Ray -- Imp (Frost)
    [88916] = true,  -- Frost Ray -- Imp (Frost)
    [88908] = true,  -- Frost Ray -- Imp (Frost)

    [9670] = true,   -- Strike -- Lamia
    [9671] = true,   -- Howling Strike -- Lamia
    [89382] = true,  -- Howling Strike -- Lamia
    [9674] = true,   -- Resonate -- Lamia
    [23281] = true,  -- Resonate -- Lamia
    [7830] = true,   -- Shockwave -- Lamia Medica
    [9677] = true,   -- Summon Spectral Lamia -- Lamia Medica
    [12074] = true,  -- Summon Spectral Lamia -- Lamia Medica
    [9680] = true,   -- Summon Spectral Lamia -- Lamia Medica
    [89399] = true,  -- Summon Spectral Lamia -- Lamia Medica
    [89398] = true,  -- Summon Spectral Lamia -- Lamia Medica
    [89400] = true,  -- Summon Spectral Lamia -- Lamia Medica
    [7835] = true,   -- Convalescence -- Lamia Medica
    [24745] = true,  -- Harmony -- Lamia
    [7831] = true,   -- Harmony -- Lamia
    [23358] = true,  -- Harmony -- Lamia
    [24814] = true,  -- Harmony -- Lamia
    [24817] = true,  -- Harmony -- Lamia

    [3757] = true,   -- Claw -- Lurcher
    [3860] = true,   -- Pulverize -- Lurcher
    [32698] = true,  -- Pulverize -- Lurcher
    [3855] = true,   -- Crushing Limbs -- Lurcher
    [38554] = true,  -- Stun -- Lurcher
    [3767] = true,   -- Choking Pollen -- Lurcher
    [4769] = true,   -- Choking Pollen -- Lurcher

    [75863] = true,  -- Cleave -- Minotaur
    [75864] = true,  -- Cleave -- Minotaur
    [75865] = true,  -- Cleave -- Minotaur
    [75867] = true,  -- Clobber -- Minotaur
    [80440] = true,  -- Clobber -- Minotaur
    [80014] = true,  -- Clobber -- Minotaur
    [75868] = true,  -- Clobber -- Minotaur
    [75917] = true,  -- Ram -- Minotaur
    [75920] = true,  -- Ram -- Minotaur
    [75921] = true,  -- Ram -- Minotaur
    [75919] = true,  -- Ram -- Minotaur
    [75922] = true,  -- Ram -- Minotaur
    [75872] = true,  -- Flying Axe -- Minotaur
    [79541] = true,  -- Flying Leap -- Minotaur
    [79540] = true,  -- Flying Leap -- Minotaur
    [79539] = true,  -- Flying Leap -- Minotaur
    [75925] = true,  -- Elemental Weapon -- Minotaur
    [75926] = true,  -- Elemental Pool -- Minotaur
    [75928] = true,  -- Elemental Pool -- Minotaur
    [75935] = true,  -- Elemental Wave -- Minotaur
    [75936] = true,  -- Elemental Wave -- Minotaur
    [75937] = true,  -- Elemental Wave -- Minotaur
    [75933] = true,  -- Elemental Wave -- Minotaur

    [75949] = true,  -- Fiery Surge -- Minotaur Shaman
    [77989] = true,  -- Flame Wave -- Minotaur Shaman
    [75951] = true,  -- Brimstone Hailfire -- Minotaur Shaman
    [75952] = true,  -- Brimstone Hailfire -- Minotaur Shaman
    [75953] = true,  -- Brimstone Hailfire -- Minotaur Shaman
    [75954] = true,  -- Brimstone Hailfire -- Minotaur Shaman
    [75955] = true,  -- Pillars of Nirn -- Minotaur Shaman
    [81577] = true,  -- Pillars of Nirn -- Minotaur Shaman
    [75962] = true,  -- Pillars of Nirn - Minotaur Shaman
    [75956] = true,  -- Pillars of Nirn -- Minotaur Shaman
    [75957] = true,  -- Pillars of Nirn -- Minotaur Shaman
    [75980] = true,  -- Pillar Eruption -- Minotaur Shaman
    [75976] = true,  -- Pillar of Nirn -- Minotaur Shaman
    [81578] = true,  -- Pillar of Nirn -- Minotaur Shaman
    [75978] = true,  -- Pillar Explosion -- Minotaur Shaman
    [75994] = true,  -- Molten Armor (Minotaur Shaman)
    [79689] = true,  -- Molten Armor (Minotaur Shaman)

    [5520] = true,   -- Frost Bolt -- Nereid
    [5559] = true,   -- Icy Geyser -- Nereid
    [11024] = true,  -- Icy Geyser -- Nereid
    [5540] = true,   -- Hurricane -- Nereid
    [16040] = true,  -- Hurricane -- Nereid
    [95288] = true,  -- Hurricane -- Nereid

    [5254] = true,   -- Punch -- Ogre
    [5257] = true,   -- Backhand -- Ogre
    [5256] = true,   -- Shockwave -- Ogre
    [34616] = true,  -- Shockwave -- Ogre
    [6150] = true,   -- Off Balance -- Ogre
    [5349] = true,   -- Stagger -- Ogre
    [8069] = true,   -- Intimidating Roar -- Ogre
    [24985] = true,  -- Intimidating Roar -- Ogre
    [5881] = true,   -- Smash -- Ogre
    [24948] = true,  -- Smash -- Ogre
    [34627] = true,  -- Smash -- Ogre
    [24949] = true,  -- Smash -- Ogre
    [34614] = true,  -- Smash -- Ogre

    [53136] = true,  -- Frost Bolt -- Ogre Shaman
    [65434] = true,  -- Frost Bolt -- Ogre Shaman
    [53773] = true,  -- Frost Bolt -- Ogre Shaman
    [53774] = true,  -- Frost Bolt -- Ogre Shaman
    [65469] = true,  -- Frost Bolt -- Ogre Shaman
    [65470] = true,  -- Frost Bolt -- Ogre Shaman
    [82685] = true,  -- CC (Crowd Control) Shared Cool -- Ogre Shaman

    [53142] = true,  -- Ice Pillar -- Ogre Shaman
    [54414] = true,  -- Ice Pillar Initialize -- Ogre Shaman
    [34385] = true,  -- Generic AOE -- Ogre Shaman
    [53145] = true,  -- Ice Pillar Chill -- Ogre Shaman
    [53966] = true,  -- Ice Pillar Chill -- Ogre Shaman
    [54256] = true,  -- Ice Pillar Chill -- Ogre Shaman
    [54327] = true,  -- Winter's Reach -- Ogre Shaman
    [74457] = true,  -- Ice Pillar -- Ogre Shaman
    [82687] = true,  -- S (Support) Shared Cool -- Ogre Shaman
    [64540] = true,  -- Freeze Wounds -- Ogre Shaman
    [72069] = true,  -- Freeze Wounds -- Ogre Shaman
    [70592] = true,  -- Freeze Wounds -- Ogre Shaman
    [53137] = true,  -- Freeze Wounds -- Ogre Shaman
    [72068] = true,  -- Freeze Wounds -- Ogre Shaman
    [70591] = true,  -- Freeze Wounds -- Ogre Shaman

    [2986] = true,   -- Lacerate -- Spriggan
    [21582] = true,  -- Nature's Swarm -- Spriggan
    [31699] = true,  -- Nature's Swarm -- Spriggan
    [13475] = true,  -- Healing Salve -- Spriggan
    [89083] = true,  -- Healing Salve -- Spriggan
    [89084] = true,  -- Healing Salve -- Spriggan
    [89085] = true,  -- Healing Salve -- Spriggan
    [89099] = true,  -- Summon Beast -- Spriggan
    [89143] = true,  -- Summon Beast -- Spriggan
    [89119] = true,  -- Summon Beast -- Spriggan
    [89102] = true,  -- Summon Beast -- Spriggan
    [89157] = true,  -- Summon Beast -- Spriggan
    [89158] = true,  -- Summon Beast -- Spriggan
    [89159] = true,  -- Summon Beast -- Spriggan
    [89151] = true,  -- Summon Beast -- Spriggan
    [89154] = true,  -- Summon Beast -- Spriggan
    [89160] = true,  -- Summon Beast -- Spriggan
    [89168] = true,  -- Summon Beast -- Spriggan
    [89170] = true,  -- Summon Beast -- Spriggan
    [89127] = true,  -- Summon Beast -- Spriggan
    [21570] = true,  -- Backstep -- Spriggan
    [13477] = true,  -- Control Beast -- Spriggan
    [89126] = true,  -- Summon Beast -- Spriggan
    [89229] = true,  -- Summon Beast -- Spriggan

    [42793] = true,  -- Strangler: -- Strangler
    [42794] = true,  -- Strangler: -- Strangler
    [9320] = true,   -- Strike -- Strangler
    [14219] = true,  -- Spit -- Strangler
    [9346] = true,   -- Strangle -- Strangler
    [42211] = true,  -- Strangle -- Strangler
    [9322] = true,   -- Poisoned Ground -- Strangler
    [9323] = true,   -- Poisoned Ground -- Strangler
    [9321] = true,   -- Grapple -- Strangler
    [9707] = true,   -- Grapple -- Strangler
    [14221] = true,  -- Grapple -- Strangler
    [64132] = true,  -- Grapple Immunity -- Strangler

    [8926] = true,   -- Regeneration -- Troll
    [61225] = true,  -- Regeneration -- Troll
    [8925] = true,   -- Slap -- Troll
    [44736] = true,  -- Swinging Cleave -- Troll
    [44737] = true,  -- Swinging Cleave -- Troll
    [9009] = true,   -- Tremor -- Troll
    [73945] = true,  -- Tremor -- Troll
    [9011] = true,   -- Tremor -- Troll

    [48253] = true,  -- Rock Toss -- Troll (Ranged)
    [60549] = true,  -- Rock Toss -- Troll (Ranged)
    [48256] = true,  -- Boulder Toss -- Troll (Ranged)
    [48258] = true,  -- Boulder Toss -- Troll (Ranged)
    [48259] = true,  -- Boulder Toss -- Troll (Ranged)
    [58655] = true,  -- Turn -- Troll (Ranged)
    [48257] = true,  -- Boulder Toss -- Troll (Ranged)
    [50387] = true,  -- Boulder Toss -- Troll (Ranged)
    [48282] = true,  -- Consuming Omen -- Troll (Ranged)
    -- [48288] = true,  -- Consuming Omen -- Troll (Ranged)
    -- [48286] = true,  -- Consuming Omen -- Troll (Ranged)
    [48287] = true, -- Consuming Omen -- Troll (Ranged)
    [48294] = true, -- Consuming Omen -- Troll (Ranged)
    [48297] = true, -- Consuming Omen -- Troll (Ranged)
    [48286] = true, -- Consuming Omen -- Troll (Ranged)
    [48288] = true, -- Consuming Omen -- Troll (Ranged)

    [76266] = true, -- Rip -- River Troll (DB DLC)
    [76268] = true, -- Lope -- River Troll (DB DLC)
    [76271] = true, -- Lope -- River Troll (DB DLC)
    [78834] = true, -- Lope -- River Troll (DB DLC)
    [76274] = true, -- Lope -- River Troll (DB DLC)
    [76295] = true, -- Crab Toss -- River Troll (DB DLC)
    [80506] = true, -- Crab Toss -- River Troll (DB DLC)
    [81046] = true, -- Crab Toss -- River Troll (DB DLC)
    [76297] = true, -- Crab Toss -- River Troll (DB DLC)
    [76302] = true, -- SW Spawn Stun -- River Troll (DB DLC)
    [76298] = true, -- Crab Toss -- River Troll (DB DLC)
    [81045] = true, -- Crab Toss -- River Troll (DB DLC)
    [76300] = true, -- Scuttle -- River Troll (DB DLC)
    [76277] = true, -- Close Wounds -- River Troll (DB DLC)
    [76278] = true, -- Close Wounds -- River Troll (DB DLC)
    [78314] = true, -- Close Wounds -- River Troll (DB DLC)

    [4304] = true,  -- Assault -- Wisp
    [18634] = true, -- Assault -- Wisp
    [4309] = true,  -- Dying Blast -- Wisp
    [64221] = true, -- Dying Blast -- Wisp

    [6596] = true,  -- Summon Wisp -- Wispmother
    [64211] = true, -- Summon Wisp -- Wispmother
    -- [19052] = true,  -- Rain of Wisps -- Wispmother
    -- [19058] = true,  -- Rain of Wisps -- Wispmother
    [8003] = true,   -- Rain of Wisps -- Wispmother
    [19062] = true,  -- Rain of Wisps -- Wispmother
    -- [19049] = true,  -- Rain of Wisps -- Wispmother
    [19045] = true,  -- Rain of Wisps -- Wispmother
    [19047] = true,  -- Rain of Wisps -- Wispmother
    [19055] = true,  -- Rain of Wisps -- Wispmother
    [19049] = true,  -- Rain of Wisps -- Wispmother
    [19052] = true,  -- Rain of Wisps -- Wispmother
    [19058] = true,  -- Rain of Wisps -- Wispmother
    [7976] = true,   -- Rain of Wisps -- Wispmother
    [8025] = true,   -- Rain of Wisps -- Wispmother
    [19043] = true,  -- Rain of Wisps -- Wispmother
    [19050] = true,  -- Rain of Wisps -- Wispmother
    [19056] = true,  -- Rain of Wisps -- Wispmother
    [61204] = true,  -- Rain of Wisps -- Wispmother
    [19061] = true,  -- Rain of Wisps -- Wispmother

    [18040] = true,  -- Clone -- Wispmother
    [18049] = true,  -- Clone -- Wispmother
    [18060] = true,  -- Clone -- Wispmother
    [18069] = true,  -- Wispmother Surround Clone 1 -- Wispmother
    [18073] = true,  -- Wispmother Surround Clone 2 -- Wispmother
    [18066] = true,  -- Wispmother Surround -- Wispmother
    [19069] = true,  -- Rain of Wisps -- Wispmother

    [49395] = true,  -- Punch (Mantikora)
    [49397] = true,  -- Spear Sweep (Mantikora)
    [49499] = true,  -- Spear Throw (Mantikora)
    [49501] = true,  -- Spear Throw (Mantikora)
    [49504] = true,  -- Spear Throw (Mantikora)
    [49505] = true,  -- Spear Throw (Mantikora)
    [49500] = true,  -- Spear Throw (Mantikora)
    [49404] = true,  -- Rear Up (Mantikora)
    [49406] = true,  -- Rear Up (Mantikora)
    [49405] = true,  -- Rear Up (Mantikora)
    [49402] = true,  -- Tail Whip (Mantikora)
    [49403] = true,  -- Tail Whip (Mantikora)
    [51242] = true,  -- Enrage (Mantikora)
    [50187] = true,  -- Enrage (Mantikora)
    [56687] = true,  -- Enrage (Mantikora)
    [56688] = true,  -- Enrage (Mantikora)
    [87712] = true,  -- Enraged (Mantikora)
    [56689] = true,  -- Enraged (Mantikora)

    [105459] = true, -- Triggered (Yaghra Strider)
    [103777] = true, -- Lacerate (Yaghra Strider)
    [103778] = true, -- Lacerate (Yaghra Strider)
    [105432] = true, -- Lacerate (Yaghra Strider)
    [105433] = true, -- Lacerate (Yaghra Strider)
    [103780] = true, -- Bleeding Laceratation (Yaghra Strider)
    [104479] = true, -- Reave (Yaghra Strider)
    [104509] = true, -- Reave (Yaghra Strider)
    [104508] = true, -- Reave (Yaghra Strider)
    [105214] = true, -- Lunge (Yaghra Strider)
    [110418] = true, -- Lunge (Yaghra Strider)
    [105220] = true, -- Lunge (Yaghra Strider)
    [105221] = true, -- Lunge (Yaghra Strider)
    [105285] = true, -- Lunge (Yaghra Strider)
    [105330] = true, -- Frenzy (Yaghra Strider)
    [105428] = true, -- Frenzy (Yaghra Strider)
    [109469] = true, -- Frenzy (Yaghra Strider)

    [103776] = true, -- Slash (Yaghra Strider)
    [103775] = true, -- Chop (Yaghra Strider)
    [103784] = true, -- Dazed Snare (Yaghra Strider)
    [103786] = true, -- Purge (Yaghra Strider)
    [103804] = true, -- Deluge (Yaghra Strider)
    [103810] = true, -- Deluge (Yaghra Strider)
    [103812] = true, -- Deluge (Yaghra Strider)
    [103852] = true, -- Deluge (Yaghra Strider)
    [103805] = true, -- Deluge (Yaghra Strider)
    [103849] = true, -- Deluge (Yaghra Strider)
    [103856] = true, -- Deluge (Yaghra Strider)
    [103857] = true, -- Deluge (Yaghra Strider)
    [103821] = true, -- YAGRAN Deluge AoE2 (Yaghra Strider)
    [103850] = true, -- Deluge (Yaghra Strider)
    [103858] = true, -- Deluge (Yaghra Strider)
    [103862] = true, -- Deluge (Yaghra Strider)
    [103864] = true, -- Deluge (Yaghra Strider)
    [103931] = true, -- Luminescent Mark (Yaghra Strider)
    [103955] = true, -- Knockback (Yaghra Strider)
    [103954] = true, -- Stun (Yaghra Strider)
    [103993] = true, -- Luminescent Mark (Yaghra Strider)
    [103958] = true, -- Luminescent Mark (Yaghra Strider)
    [103957] = true, -- Luminescent Mark (Yaghra Strider)
    [103973] = true, -- Luminescent Mark (Yaghra Strider)
    [103991] = true, -- Luminescent Mark (Yaghra Strider)
    [103992] = true, -- Luminescent Burn (Yaghra Strider)

    -------------------------------------
    -- MORROWIND DLC NPCS ---------------
    -------------------------------------

    -- Nix Ox
    [85199] = true, -- Scythe
    [85200] = true, -- Scythe
    [85197] = true, -- Snap
    [85198] = true, -- Snap
    [85201] = true, -- Bite
    [85202] = true, -- Gore
    [85084] = true, -- Shriek
    [85085] = true, -- Shriek
    [90765] = true, -- Acid Spray
    [90776] = true, -- Acid Spray
    [90777] = true, -- Acid Spray
    [90779] = true, -- Acid Spray
    [90781] = true, -- Acid Spray
    [90790] = true, -- Acid Spray
    [90780] = true, -- Acid Spray
    [90778] = true, -- Acid Pool
    [90809] = true, -- Acid Spray
    [90811] = true, -- Acid Spray
    [90810] = true, -- Acid Spray
    [90814] = true, -- Acid Spray
    [90813] = true, -- Acid Spray
    [90816] = true, -- Acid Spray
    [90812] = true, -- Acid Spray
    [90815] = true, -- Acid Pool
    [85172] = true, -- Winnow
    [94846] = true, -- Winnow
    [85175] = true, -- Winnow
    [85186] = true, -- Winnow
    [85173] = true, -- Winnow
    [85203] = true, -- Nix-Call
    [95389] = true, -- Nix-Call
    [90187] = true, -- Nix-Call
    [90190] = true, -- Nix-Call
    [89940] = true, -- Turret

    -- Cliff Strider
    [93597] = true, -- Achievement (Cliff Strider)
    [85387] = true, -- Snap (Cliff Strider)
    [85388] = true, -- Stab (Cliff Strider)
    [93516] = true, -- Tail Lash (Cliff Strider)
    [85395] = true, -- Dive (Cliff Strider)
    [92129] = true, -- Dive (Cliff Strider)
    [92085] = true, -- Dive (Cliff Strider)
    [85398] = true, -- Dive (Cliff Strider)
    [90319] = true, -- Dive (Cliff Strider)
    [90320] = true, -- Dive (Cliff Strider)
    [85399] = true, -- Retch (Cliff Strider)
    [85420] = true, -- Retch (Cliff Strider)
    [85421] = true, -- Retch (Cliff Strider)
    [85436] = true, -- Frenzied Feast (Cliff Strider)
    [85448] = true, -- Frenzied Feast (Cliff Strider)
    [85390] = true, -- Slash (Cliff Strider Matriarch)
    [85391] = true, -- Slash (Cliff Strider Matriarch)
    [85394] = true, -- Slash (Cliff Strider Matriarch)
    [85392] = true, -- Slash (Cliff Strider Matriarch)
    [85393] = true, -- Slash (Cliff Strider Matriarch)

    -- Fetcherfly Nest
    [87022] = true, -- Summon Swarm
    [92017] = true, -- Summon Swarm
    [86561] = true, -- Snare
    [85645] = true, -- Bombard
    [85646] = true, -- Bomb
    [85522] = true, -- Ashen Wind
    [85524] = true, -- Ashen wind
    [85525] = true, -- Ashen Wind
    [85526] = true, -- Ashen Cloud
    [87125] = true, -- Heat Vents
    [87126] = true, -- Heat Vents
    [92018] = true, -- Summon Swarm

    -- Fetcherfly Hive Golem
    [92083] = true, -- Slam
    [87062] = true, -- Fetcherfly Storm
    [87071] = true, -- Fetcherfly Storm
    [87072] = true, -- Fetcherfly Storm
    [87073] = true, -- Fetcherfly Storm
    [92075] = true, -- Fetcherfly Storm
    [87087] = true, -- Fetcherfly Storm
    [87095] = true, -- Colonize
    [92078] = true, -- Colonize
    [92079] = true, -- Colonize
    [92077] = true, -- Colonize
    [92081] = true, -- Colonize
    [87030] = true, -- Focused Swarm
    [87031] = true, -- Focused Swarm

    -- Dwemer Arquebus
    [85242] = true, -- Quick Shot
    [85255] = true, -- Shock Blast
    [88668] = true, -- Impulse Mine
    [88730] = true, -- Impulse Mine
    [88728] = true, -- Impluse Mine
    [85270] = true, -- Shock Barrage
    [85288] = true, -- Shock Barrage
    [91013] = true, -- Shock Barrage
    [85319] = true, -- Siege Ballista
    [91093] = true, -- Split Bolt
    [91087] = true, -- Split Bolt
    [91092] = true, -- Split Bolt
    [91094] = true, -- Split Bolt
    [91095] = true, -- Split Bolt
    [91096] = true, -- Split Bolt
    [85326] = true, -- Polarizing Field
    [85327] = true, -- Polarizing Field
    [85334] = true, -- Polarizing Field

    -- Hunger
    [84825] = true, -- Slash
    [84826] = true, -- Slash
    [84827] = true, -- Rake
    [84834] = true, -- Rake
    [94903] = true, -- Spring
    [94908] = true, -- Spring
    [94907] = true, -- Spring
    [87237] = true, -- Spring
    [87242] = true, -- Spring
    [87241] = true, -- Spring
    [87247] = true, -- Devour
    [87988] = true, -- Devour
    [91413] = true, -- Devour
    [87252] = true, -- Devour
    [87253] = true, -- Devour
    [87251] = true, -- Devour
    [87385] = true, -- Devour
    [87386] = true, -- Devour
    [87987] = true, -- Devour
    [87250] = true, -- Devour
    [84944] = true, -- Hollow
    [91440] = true, -- Hollow
    [91439] = true, -- Hollow
    [84967] = true, -- Hollow
    [84988] = true, -- Hollow
    [84990] = true, -- Hollow
    [87269] = true, -- Torpor
    [87270] = true, -- Torpor
    [87538] = true, -- Torpor
    [87536] = true, -- Torpor
    [89751] = true, -- Dispel Illusion
    [87271] = true, -- Torpor
    [87273] = true, -- Torpor
    [91426] = true, -- Match Health
    [87639] = true, -- Fade
    [91425] = true, -- Torpor
    [91433] = true, -- Torpor

    -- Iron Atronach
    [89030] = true, -- Subduction
    [88246] = true, -- Iron Hand
    [88247] = true, -- Eruption
    [88282] = true, -- Rock Stomp
    [88286] = true, -- Rock Stomp
    [88296] = true, -- Rock Stomp
    [88285] = true, -- Rock Stomp
    [88295] = true, -- Rock Stomp
    [88261] = true, -- Lava Wave
    [88270] = true, -- Lava Wave
    [88271] = true, -- Lava Wave
    [88269] = true, -- Lava Wave
    [88272] = true, -- Lava Wave
    [88267] = true, -- Lava Wave
    [88266] = true, -- Lava Wave
    [95281] = true, -- Lava Wave
    [89259] = true, -- Subduction
    [89260] = true, -- Subduction
    [89261] = true, -- Subduction
    [89258] = true, -- Subduction
    [88297] = true, -- Blast Furnace
    [88298] = true, -- Blast Furnace
    [88319] = true, -- Blast Furnace
    [88320] = true, -- Blast Furnace
    [88321] = true, -- Blast Furnace
    [88323] = true, -- Blast Furnace
    [88316] = true, -- Blast Furnace
    [88317] = true, -- Blast Furnace
    [88318] = true, -- Blast Furnace

    -------------------------------------
    -- WORLD BOSSES ---------------------
    -------------------------------------

    -- World Boss - Windshriek Strand
    [87283] = true, -- Regeneration (Skullbreaker)
    [87284] = true, -- Regeneration (Skullbreaker)
    [52024] = true, -- Rock Toss (Skullbreaker)
    [84066] = true, -- Ground Shock (Skullbreaker)
    [84072] = true, -- Ground Shock (Skullbreaker)
    [84069] = true, -- Ground Shock (Skullbreaker)
    [84068] = true, -- Ground Shock (Skullbreaker)
    [84070] = true, -- Ground Shock (Skullbreaker)
    [84074] = true, -- Ground Shock (Skullbreaker)
    [84071] = true, -- Ground Shock (Skullbreaker)
    [84073] = true, -- Ground Shock (Skullbreaker)
    [84075] = true, -- Ground Shock (Skullbreaker)
    [84067] = true, -- Effected (Skullbreaker)
    [83651] = true, -- Feral Impact (Skullbreaker)
    [83670] = true, -- Feral Impact (Skullbreaker)
    [83980] = true, -- Feral Impact (Skullbreaker)
    [83997] = true, -- Feral Impact (Skullbreaker)
    [83668] = true, -- Feral Impact (Skullbreaker)
    [83671] = true, -- Feral Impact (Skullbreaker)
    [84076] = true, -- Carrion Call (Skullbreaker)
    [84338] = true, -- Swoop (Harpy)

    -- World Boss - Reaper's Henge
    [58966] = true, -- RM-GB1 Flesh Atronach Boss (Varien)

    -- World Boss - Deathsong Cleft
    [32882] = true, -- V7369 Lurcher FX

    -- World Boss - Big Ozur's Valley
    [85070] = true, -- Blazing Bolt (Big Ozur)
    [85071] = true, -- Blazing Bolt (Big Ozur)
    [83180] = true, -- Molten Pillar (Big Ozur)
    [83182] = true, -- Molten Pillar (Big Ozur)
    [83183] = true, -- Molten Shackles (Big Ozur)
    [83185] = true, -- Molten Shackles (Big Ozur)
    [83186] = true, -- Molten Shackles (Big Ozur)
    [83184] = true, -- Molten Shackles (Big Ozur)
    [83206] = true, -- Molten Shackles (Big Ozur)
    [83203] = true, -- Molten Impact (Big Ozur)
    [83191] = true, -- Shaman Smash (Big Ozur)
    [83196] = true, -- Shaman Smash (Big Ozur)
    [83192] = true, -- Shaman Smash (Big Ozur)
    [83193] = true, -- Shaman Smash (Big Ozur)
    [83194] = true, -- Shaman Smash (Big Ozur)

    -- World Boss - The Wolf's Camp
    [10149] = true, -- Guards Transform (Lieutenant Bran, Annyce)
    [38331] = true, -- Werewolf Regen (Lieutenant Bran, Annyce)
    [38330] = true, -- Houndsman Stun (Lieutenant Bran, Annyce)
    [38334] = true, -- Houndsman Delay (Lieutenant Bran, Annyce)
    [26260] = true, -- Salazar Transform! (Salazar the Wolf)
    [38326] = true, -- Werewolf Regen (Salazar the Wolf)
    [38325] = true, -- Houndsman Stun (Salazar the Wolf)
    [38328] = true, -- Houndsman Delay (Salazar the Wolf)

    -- World Boss - Balefire Island
    [49294] = true, -- Rise (Grivier's Monstrosity)

    -- World Boss - Trapjaw's Cove
    [83945] = true, -- Tail Sweep (Trapjaw)
    [83947] = true, -- Tail Sweep (Trapjaw)
    [83948] = true, -- Tail Sweep (Trapjaw)
    [83951] = true, -- Tail Sweep (Trapjaw)
    [84028] = true, -- Impending Storm (Trapjaw)
    [84031] = true, -- Impending Storm (Trapjaw)
    [84032] = true, -- Impending Storm (Trapjaw)
    [84033] = true, -- Impending Storm (Trapjaw)
    [84034] = true, -- Impending Storm (Trapjaw)
    [84035] = true, -- Impending Storm (Trapjaw)
    [84036] = true, -- Impending Storm (Trapjaw)
    [84030] = true, -- Impending Storm (Trapjaw)
    [84168] = true, -- Rolling Thunder (Trapjaw)
    [84169] = true, -- Rolling Thunder (Trapjaw)
    [84175] = true, -- Focused Charge (Trapjaw)
    [84176] = true, -- Focused Charge (Trapjaw)
    [84182] = true, -- Charge (Trapjaw)
    [84177] = true, -- Charge (Trapjaw)
    [84179] = true, -- Rolling Thunder (Trapjaw)
    [84173] = true, -- Rolling Thunder (Trapjaw)
    [84172] = true, -- Charge (Trapjaw)
    [84171] = true, -- Charge (Trapjaw)
    [83925] = true, -- Trapping Bolt (Trapjaw)
    [83930] = true, -- Trapping Bolt (Trapjaw)
    [83932] = true, -- Remove Bolt (Trapjaw)
    [83926] = true, -- Remove Bolt (Trapjaw)
    [83928] = true, -- Arx_boss2_KDrecover (Trapjaw)
    [83929] = true, -- Dummy (Trapjaw)
    [25763] = true, -- Remove Bolt (Trapjaw)

    -- World Boss - Spider Nest
    [84150] = true, -- Call of the Brood (Old Widow Silk)
    [84564] = true, -- Summon Swarm (Old Widow Silk)
    [84563] = true, -- Summon Swarm (Old Widow Silk)
    [84151] = true, -- Constricting Webs (Old Widow Silk)
    [84155] = true, -- Constricting Webs (Old Widow Silk)
    [84608] = true, -- Web Wrap (Old Widow Silk)
    [84548] = true, -- Venom Spray (Old Widow Silk)
    [84549] = true, -- Venom Spray (Old Widow Silk)
    [84159] = true, -- Spit Poison (Old Widow Silk)
    [84162] = true, -- Spit Poison (Old Widow Silk)
    [84161] = true, -- Spit Poison (Old Widow Silk)
    [84160] = true, -- Spit Poison (Old Widow Silk)

    -- World Boss - Mudcrab Beach
    [82965] = true, -- Crabuchet (Titanclaw)
    [82969] = true, -- Crabuchet (Titanclaw)
    [83003] = true, -- Crabuchet (Titanclaw)
    [83475] = true, -- Crabuchet (Titanclaw)
    [82980] = true, -- Crabuchet (Titanclaw)
    [82997] = true, -- Crabuchet (Titanclaw)
    [82981] = true, -- Crabuchet (Titanclaw)
    [82983] = true, -- Crabuchet (Titanclaw)
    [82970] = true, -- Crabuchet (Titanclaw)
    [83000] = true, -- Crabuchet (Titanclaw)
    [83021] = true, -- Crabuchet (Titanclaw)

    -- World Boss - Abandoned Farm
    [27971] = true, -- Burn the House (Scamp)
    [27933] = true, -- Burn the House (Scamp)

    -- World Boss - Valeguard Tower
    [84039] = true, -- Stone Swipe (Menhir Stoneskin)
    [84040] = true, -- Stone Swipe (Menhir Stoneskin)
    [84041] = true, -- Stone Swipe (Menhir Stoneskin)
    [84037] = true, -- Petrifying Bellow (Menhir Stoneskin)
    [84038] = true, -- Petrifying Bellow (Menhir Stoneskin)
    [84580] = true, -- Petrifing Bellow (Menhir Stoneskin)
    [84292] = true, -- Graven Slash (Menhir Stoneskin)
    [84293] = true, -- Stun (Menhir Stoneskin)
    [84294] = true, -- Graven Slash (Menhir Stoneskin)
    [84014] = true, -- Awaken (Menhir Stoneskin)
    [84029] = true, -- Awaken (Menhir Stoneskin)
    [84417] = true, -- Awaken (Menhir Stoneskin)
    [85461] = true, -- Awaken (Menhir Stoneskin)

    -- World Boss - Magdelena's Haunt
    [83924] = true, -- Shadow Bolt (Magdelena)
    [83922] = true, -- Curse of Terror (Magdelena)
    [83923] = true, -- Curse of Terror (Magdelena)
    [83880] = true, -- Reflective Shadows (Magdelena)
    [83227] = true, -- Dark Resurrection (Magdelena)
    [83884] = true, -- Steal Essence (Magdelena)
    [83886] = true, -- Shadow Flare (Magdelena)
    [83883] = true, -- Shadow Flare (Magdelena)

    -------------------------------------
    -- QUESTS - SHARED ------------------
    -------------------------------------

    [55831] = true,  -- Found Recommended Ore (Blacksmith Certification)
    [56061] = true,  -- Found Recommended Jute (Clothier Certification)
    [55965] = true,  -- Found Recommended Maple (Woodworker Certification)
    [56266] = true,  -- Found Recommended Solvent and (Alchemist Certification)
    [56256] = true,  -- Found Recommended Runestones (Enchanter Certification)
    [55983] = true,  -- Found Recommended Ingredients (Provisioner Certification)
    [103376] = true, -- Found Recommended Dust (Jewelry Crafting Certification)

    -------------------------------------
    -- MAIN QUEST -----------------------
    -------------------------------------

    -- Tutorial (Soul Shriven in Coldharbour)
    [82077] = true, -- Portal In
    [90733] = true, -- Knockout
    [48675] = true, -- Vitality of the Titanborn
    [62805] = true, -- Stun
    [62802] = true, -- Targetable Off
    [62803] = true, -- Targetable On
    [62801] = true, -- Portal Spawn
    [75514] = true, -- Greater Protection
    [75527] = true, -- Ultimate Protection
    [64089] = true, -- Titan Bash
    [64091] = true, -- Power Bash
    [64772] = true, -- MQ1 Input Lock LAtk
    [64769] = true, -- MQ1 Input Lock LAtk
    [64092] = true, -- PermaStun
    [64133] = true, -- PermRoot
    [63883] = true, -- Major Protection
    [1718] = true,  -- Attack
    [64029] = true, -- MQ1 Inpuit Lock Visual
    [61748] = true, -- Heavy Attack
    [64784] = true, -- MQ1 Tutorial Block Heavy
    [61956] = true, -- Off-Balance Timer
    [61980] = true, -- Off-Balance
    [61961] = true, -- Perma Set Off Balance Target
    [64677] = true, -- MQ1 Tutorial Perma Off-Balance
    [64676] = true, -- MQ1 Tutorial Perma Off-Balance
    [61916] = true, -- Heat Wave
    [64798] = true, -- MQ1 Heat Wave (Tutorial)
    [75531] = true, -- Retarget
    [0] = true,     -- No Name
    [63737] = true, -- Heavy Attack
    [63684] = true, -- Uppercut
    [63685] = true, -- Uppercut Stun
    [63686] = true, -- Uppercut
    [63761] = true, -- Pound
    [63752] = true, -- Vomit
    [63753] = true, -- Vomit
    [64069] = true, -- Sentinel Barrier
    [64247] = true, -- MQ1 Input Lock Visual No Delay
    [63555] = true, -- MQ1 Sneak Atk Tutorial Trigger
    [63559] = true, -- MQ1 Sneak Tutorial Trigger
    [64072] = true, -- Eye of the Sentinel
    [64112] = true, -- CON_Ground Rise on
    [48345] = true, -- Focused Healing
    [48346] = true, -- Minor Wound
    [51692] = true, -- Ground Rise on
    [51693] = true, -- Hate
    [63521] = true, -- Bone Crush
    [63522] = true, -- Bone Saw
    [61648] = true, -- Replenish Stamina
    [61644] = true, -- Incapacitating Terror
    [61646] = true, -- Incapacitating Terror
    [64074] = true, -- Incapacitating Terror
    [64166] = true, -- Major Protection
    [63398] = true, -- Backlash
    [63615] = true, -- Insight
    [64110] = true, -- Rending the Skein
    [63637] = true, -- Teleport
    [63633] = true, -- Escape Cold Harbor
    [63638] = true, -- Mq1_ExitLeap
    [63636] = true, -- Dummy
    [63635] = true, -- Escape Cold Harbor
    [64101] = true, -- Waking
    [25992] = true, -- CON_Screen Flash White

    -- The Harborage
    [47664] = true, -- Rending the Skein
    [36375] = true, -- Mind Portal
    [36394] = true, -- Dream Shade
    [36377] = true, -- Dream Spawn
    [36252] = true, -- Soul Burst
    [36376] = true, -- Reverse Mind Portal

    -- Daughter of Giants
    [46133] = true, -- Rending the Skein
    [27697] = true, -- Ragjar Change Forms
    [52724] = true, -- Call Lyris
    [27698] = true, -- Impostor Transform
    [29994] = true, -- Inferno (Manifestation of Solitude)
    [27689] = true, -- Lyris Dons Armor
    [37384] = true, -- MQ2 Clannfear Birthing Effects (Ancient Clannfear)
    [27767] = true, -- Rending Leap (Ancient Clannfear)
    [27769] = true, -- Rending Leap (Ancient Clannfear)
    [27774] = true, -- Knockdown (Ancient Clannfear)
    [27776] = true, -- Feeding (Ancient Clannfear)
    [27708] = true, -- Lyris Wields Axe
    [28718] = true, -- Spawn (Manifestation of Terror)
    [28792] = true, -- Gaze (Manifestation of Terror)
    [28788] = true, -- MQ2_Boss1_Doom-Truth'sGaze (Manifestation of Terror)
    [49960] = true, -- Fire Runes (Manifestation of Terror)
    [49958] = true, -- Fire Runes (Manifestation of Terror)
    [49961] = true, -- Doom-Truth's Gaze (Manifestation of Terror)
    [28723] = true, -- Gravity Well (Manifestation of Terror)
    [28725] = true, -- Gravity Well (Manifestation of Terror)
    [28726] = true, -- Gravity Well (Manifestation of Terror)
    [28730] = true, -- Gravity Well (Manifestation of Terror)
    [28737] = true, -- Recovery (Manifestation of Terror)
    [28742] = true, -- Tentacle Whip (Manifestation of Terror)
    [28753] = true, -- Tentacle Whip (Manifestation of Terror)
    [28745] = true, -- Tentacle Whip (Manifestation of Terror)
    [28746] = true, -- Tentacle Whip (Manifestation of Terror)
    [28751] = true, -- Been Hit (Manifestation of Terror)
    [28752] = true, -- Tentacle Whip (Manifestation of Terror)
    [13364] = true, -- CON_Magic Transformation

    -- Chasing Shadows
    [18686] = true, -- JB - Test Door Fade to Blacks

    -- Castle of the Worm
    [14597] = true, -- CON_Stealth Despawn
    [41852] = true, -- Necrotic
    [16019] = true, -- Bone Pile Explosion
    [39211] = true, -- MQ3 Disintegrate
    [10993] = true, -- Generic Magic Explosion Large
    [33597] = true, -- Invisible Underground
    [35794] = true, -- Material Effect
    [33540] = true, -- Intro Explosion
    -- [33548] = true, -- CON_Knockback&Knockdown
    -- [33547] = true, -- Fire Backlash
    [31244] = true, -- Consuming Darkness
    [32563] = true, -- Skeleton Stun Targetable
    [32561] = true, -- Skeleton Stun
    [31232] = true, -- Skeleton Stun Targetable
    [31222] = true, -- Skeleton Stun
    [32557] = true, -- Skeleton Stun Targetable
    [32555] = true, -- Skeleton Stun
    [31250] = true, -- Raising the Dead
    [32558] = true, -- Delay
    [32554] = true, -- Delay
    [32564] = true, -- Delay
    [32562] = true, -- Ravager Weapons
    [32553] = true, -- Ravager Weapons
    [32556] = true, -- Fire Mage Weapons
    [34484] = true, -- Soul Cage
    [34462] = true, -- Soul Cage
    [34473] = true, -- Soul Cage
    [34475] = true, -- Soul Cage
    [34479] = true, -- Soul Cage
    [34480] = true, -- Soul Cage
    [34481] = true, -- Soul Cage
    [34482] = true, -- Soul Cage
    [34483] = true, -- Soul Cage
    [34478] = true, -- TickCounter
    [34470] = true, -- Soul Cage
    [34463] = true, -- Soul Cage
    [34458] = true, -- Soul Cage
    [34460] = true, -- Soul Cage
    [33034] = true, -- Collosus
    [31275] = true, -- Ground Rise On
    [31348] = true, -- Hate
    [70409] = true, -- Necromantic Barrier
    [31321] = true, -- Disruption
    [31334] = true, -- Oblivion
    [31480] = true, -- Overwhelming Power
    [31341] = true, -- Unleashed Oblivion
    -- [14972] = true, -- CON_Knockback&Knockdown
    -- [14973] = true, -- Fire Backlash
    [31344] = true, -- Escape
    [34420] = true, -- MQ Knockback and Knockdown, Sh
    [34421] = true, -- MQ Knockback and Knockdown, Sh

    -- Halls of Torment
    [36679] = true, -- Flaming Vice
    [36672] = true, -- Summon Sword Saint
    [36673] = true, -- Sword Saint Rise
    [36858] = true, -- Swordstorm
    [36860] = true, -- Swordstorm damage
    [39777] = true, -- Molag Bal Doomed Soul
    [39778] = true, -- Swallowed
    [36807] = true, -- Light
    [36884] = true, -- Light
    [36885] = true, -- Light
    [36886] = true, -- Light
    [36784] = true, -- Dark Seduction Shield
    -- [44561] = true, -- FGQ4 RGT Event Knockback
    -- [44563] = true, -- FGQ4 RGT Event Knockback
    [36890] = true, -- Seductive Bind
    [36862] = true, -- FG Doshia Harvester Transform
    [37015] = true, -- Lash of Torment
    [6632] = true,  -- CON_MagicExplosionLarge
    [37166] = true, -- Engulfing Grip
    [26941] = true, -- CON_EvilBeamSummonOnSelf
    [37173] = true, -- Flame Shield (Duchess of Anguish)
    [37176] = true, -- Register (Duchess of Anguish)
    [37175] = true, -- Flare Up (Duchess of Anguish)
    [38729] = true, -- Royal Strike (Duchess of Anguish)
    [38741] = true, -- Royal Snare (Duchess of Anguish)
    [38727] = true, -- Summon Daedra (Duchess of Anguish)
    [38728] = true, -- Summon Daedra (Duchess of Anguish)

    -- Valley of Blades
    [36668] = true, -- MQ4.5 Titan Fly (Titan)
    [36797] = true, -- MQ4.5 S11 Seq A
    [42081] = true, -- Generic Statue Stoneskin
    [36798] = true, -- MQ4.5 S11 Seq B
    [36819] = true, -- MQ4.5 S11 Seq F
    [6870] = true,  -- CV Delay 10 Seconds
    [44396] = true, -- Mannimarco Spawn
    [36025] = true, -- SW CON_Screen Shake on Target
    [38354] = true, -- MQ4.5 Undead Sword Singer Init

    -- Shadow of Sancre Tor
    [44413] = true, -- CON_EvilBeamSummonOnSelf
    [44662] = true, -- Sai Torture
    [37368] = true, -- Awaken
    [41021] = true, -- Mannimarco's Triumph
    [39302] = true, -- Necromantic Revival
    [39304] = true, -- Necromantic Revival
    [39367] = true, -- Altar Use
    [44642] = true, -- Dream Spawn
    [37827] = true, -- Stendarr's Protection
    [46816] = true, -- Shake
    [41989] = true, -- Manniintro
    [38207] = true, -- Death Bolt (Mannimarco)
    [41067] = true, -- Dummy (Mannimarco)
    [41069] = true, -- Dummy (Mannimarco)
    [40398] = true, -- Daedric Step (Mannimarco)
    [40401] = true, -- Daedric Step (Mannimarco)
    [40400] = true, -- Daedric Step (Mannimarco)
    [40399] = true, -- Daedric Step (Mannimarco)
    [38215] = true, -- Death's Gaze (Mannimarco)
    [38217] = true, -- Death's Gaze (Mannimarco)
    [40346] = true, -- Death's Rejuvenation (Mannimarco)
    [40425] = true, -- Impending Doom (Mannimarco)
    [40428] = true, -- Nova (Mannimarco)
    [40431] = true, -- Doom (Mannimarco)
    [40427] = true, -- Doom (Mannimarco)
    [40430] = true, -- Doom (Mannimarco)
    [41022] = true, -- Nova (Mannimarco)
    -- [40429] = true, -- IntroKB (Mannimarco)
    -- [40426] = true, -- Staggering Roar (Mannimarco)
    [40973] = true, -- Portal Spawn (Mannimarco)
    [40976] = true, -- dummy (Mannimarco)
    [40534] = true, -- Portalspawnin (Mannimarco)
    [41837] = true, -- Ghostly (Mannimarco)
    [44083] = true, -- Ghostly (Mannimarco)
    [42078] = true, -- StopPortalStun (Mannimarco)
    [42079] = true, -- PortalStabalize (Mannimarco)
    [42083] = true, -- PortalHoldstun (Mannimarco)
    [40573] = true, -- StopPortalStun (Mannimarco)
    [40554] = true, -- Dun_Mq5_Portalstabalize (Mannimarco)
    [40978] = true, -- Portal Spawn (Mannimarco)
    [40980] = true, -- dummy (Mannimarco)
    [40981] = true, -- Portal Spawn (Mannimarco)
    [40983] = true, -- dummy (Mannimarco)
    [41096] = true, -- Dummy
    [41056] = true, -- Ghost Manniappears
    [38198] = true, -- Obliterate 3
    [41196] = true, -- Smash (Molag Bal)
    [41198] = true, -- IntroKB (Molag Bal)
    [41197] = true, -- Staggering Roar (Molag Bal)
    [41385] = true, -- Dummystun (Molag Bal)
    [47522] = true, -- Nocom (Molag Bal)

    -- Council of the Five Companions
    [36543] = true, -- Portal Cast (Varen Aquilarios)
    [18417] = true, -- Rending the Skein (Varen Aquilarios)
    [36071] = true, -- MQ5.5 Mannimarco Tortured
    [36421] = true, -- Drink with Lyris

    -- Messages Across Tamriel
    [48079] = true, -- Galerion's Grandiose Greeting
    [48086] = true, -- Vanus Appearance Player KB

    -- The Weight of Three Crowns
    [38141] = true, -- Lady Laurent Delay
    [38142] = true, -- Telenger Delay
    [38143] = true, -- Capt Alphaury Delay
    [36445] = true, -- Lightning Strike
    [36446] = true, -- Wrath
    [15792] = true, -- CHT Coldharbour
    [47472] = true, -- CHT Unstable Spawn
    [8095] = true,  -- Generic Magic Explosion
    [26542] = true, -- Emanating Prescence
    [47424] = true, -- CHT Valerion Bubb
    [47186] = true, -- CHT Portal Killer

    -------------------------------------
    -- QUESTS - FIGHTERS GUILD ----------
    -------------------------------------

    -- Anchors from the Harbour
    -- [14974] = true, -- CON_Knockback&KnockdownSelf
    -- [14975] = true, -- Fire Backlash
    [17744] = true, -- Ray of Judgment (Doshia)
    [16300] = true, -- Soul Drain (Doshia)
    [31441] = true, -- FG Doshia Harvester Transform (Doshia)
    [47945] = true, -- Healing Transformation (Doshia)
    [47944] = true, -- Transform (Doshia)
    [47943] = true, -- Galthis Knockback (Doshia)

    -- The Dangerous Past
    [16062] = true, -- FGQ2 CV Sees-All-Colors V0
    [16006] = true, -- Opening Portal...
    [16007] = true, -- FGQ2 CV Portal
    [16926] = true, -- FGQ2 PC Can Spawn SC2
    [16304] = true, -- FGQ2 Sees Surrender
    [16305] = true, -- Generic Surrender Perm Check
    [16928] = true, -- FGQ2 PC Can Space SC4
    [15990] = true, -- Preserving Soul...
    [16930] = true, -- FGQ2 PC Can Spawn SC6
    [16931] = true, -- FGQ2 PC Can Spawn SC7
    [27236] = true, -- FGQ2 Crystal Beam
    [16932] = true, -- FGQ2 PC Can Spawn SC8
    [16933] = true, -- FGQ2 PC Can Spawn SC9
    [34961] = true, -- Standby
    [16298] = true, -- Q3858 Sees Change Appearance
    [16036] = true, -- FGQ2 CV Portal 2

    -- The Prismatic Core
    [39385] = true, -- Visions of Abagarlas
    [46577] = true, -- Visions of Abagarlas
    [47732] = true, -- FG3 Dark Beam FX
    [39348] = true, -- CCTEST Necrobomb Destruction
    [50166] = true, -- Q3885 MV Destroy Knockback
    [39357] = true, -- Necrobomb Camerashake
    [39358] = true, -- Necrobomb Flash
    [5259] = true,  -- CV Delay 4 Seconds
    [17919] = true, -- FG Q3885 Flame Burst
    [27881] = true, -- Earth Shake
    [27444] = true, -- FG Q3 Jump 1
    [39577] = true, -- Palolel's Rage
    -- [39579] = true, -- CON_Knockback&Knockdown
    -- [39578] = true, -- Staggering Roar

    -- Proving the Deed
    [33158] = true, -- FG4 PC Can Spawn
    [16716] = true, -- FGQ4 PC Talked to A
    [16718] = true, -- FGQ4 PC Talked to C
    [16719] = true, -- FGQ4 PC Talked to R
    [16679] = true, -- Disuprtion
    [25981] = true, -- Prismatic Light
    [25979] = true, -- FG4 RGT Event Knockback
    [25980] = true, -- FGQ4 RGT Event Knockback
    [25984] = true, -- Subversion (Aelif)
    [25985] = true, -- FGQ4 PC Failed Crystals
    [14432] = true, -- CON_DwemerSmokeBurst
    [64217] = true, -- Damage Immunity Under 50% (Aelif)
    [64218] = true, -- Combat Regen (Aelif)
    [64220] = true, -- Base Damage Reduction (Aelif)
    [47188] = true, -- FG4 Auroran Spawn (Auroran Battlemage)
    [16472] = true, -- Summoning... (Aelif)
    [16516] = true, -- FGQ4 CV Aelif Final Perm Vers (Aelif)

    -- Will of the Council
    [17297] = true, -- Q3973 Cast Portal
    [47184] = true, -- Summoning...
    [31547] = true, -- Summoning Ritual
    [31548] = true, -- Jofnir Summon 2
    [47181] = true, -- FG5 Jofnir Beam
    [47182] = true, -- FG5 Aelif Beam
    [47183] = true, -- FG5 Magic Explosion
    [26883] = true, -- Prismatic Beam
    [26842] = true, -- Prismatic Beam
    [28939] = true, -- Heat Wave (Sees-All-Colors)
    [28941] = true, -- Crackling Earth (Sees-All-Colors)
    [28940] = true, -- Crackling Earth (Sees-All-Colors)
    [28943] = true, -- Crackling Earth (Sees-All-Colors)
    [28949] = true, -- Crackling Earth (Sees-All-Colors)
    [28951] = true, -- Crackling Earth (Sees-All-Colors)
    [28952] = true, -- Crackling Earth (Sees-All-Colors)
    [28946] = true, -- Heat Wave (Sees-All-Colors)
    [45999] = true, -- Heat Wave (Sees-All-Colors)
    [47758] = true, -- Imprisonment (Aelif)
    [51138] = true, -- Q3973 Aelif Stealth DSPN
    [34687] = true, -- Corruption Cloud
    [17503] = true, -- Titan Transform
    [64111] = true, -- Transformation

    -------------------------------------
    -- QUESTS - MAGES GUILD ---------
    -------------------------------------

    -- Long Lost Lore
    [29648] = true, -- MGQ1 Book 1
    [21640] = true, -- CON_Blue Glow on Ground
    [16848] = true, -- MGQ1 CV Crystal
    [16800] = true, -- MGQ1 Crystal Beam 1
    [16816] = true, -- MGQ1 Crystal Beam 2
    [16818] = true, -- MGQ1 Crystal Beam 3
    [16808] = true, -- MGQ1 CV Shalidor
    [49347] = true, -- MG2 Shali Buff for Sound
    [32955] = true, -- MG Shalidor FX
    [16852] = true, -- MG 1/2/4 Cast Portal to SI
    [16856] = true, -- MG 1/2/4 CV Darkness
    [17131] = true, -- Q3916 PC Can Spawn E3
    [16974] = true, -- Q3916 PC Can Spawn E4
    [17132] = true, -- Q3916 PC Can Spawn E5
    [17133] = true, -- Q3916 PC Can Spawn E6
    [29651] = true, -- MGQ1 Book 4
    [29650] = true, -- MGQ1 Book 3
    [29649] = true, -- MGQ1 Book 2
    [48228] = true, -- MGQ3 Book FX
    [16973] = true, -- MGQ1 Event Scamp Pause
    [16829] = true, -- MGQ1 CV Books
    [31266] = true, -- MGQ1 PC Retrieved Boo
    [16883] = true, -- Shalidor's Rebuke
    [16866] = true, -- Q3916 Shalidor Teleport PC

    -- Simply Misplaced
    [26390] = true, -- MGQ2 Event Screen Shake
    [26396] = true, -- Q4435 Event Jump
    [31704] = true, -- Risen Dead
    [26481] = true, -- MG2 Essence On
    [26633] = true, -- MG2 Essence Attraction
    [26406] = true, -- MG2 Captured Essence
    [49346] = true, -- MG2 Essence Buff for Sound
    [31502] = true, -- MGQ2 Asakala Sahdina Barrier
    [31503] = true, -- MGQ2 Asakala Rashomta Barrier
    [26561] = true, -- MG2 Essence Deposit
    [26914] = true, -- MGQ2 Orange Cast
    [26573] = true, -- MGQ2 Green Cast
    [26943] = true, -- MG2 Greater Essence
    [26634] = true, -- MG2 Captured Sahdina Essence
    [26581] = true, -- MG2 Captured Rashomta Essence
    [26572] = true, -- MG2 Red Cast
    [26570] = true, -- MG2 Purple Cast
    [26576] = true, -- MGQ2 White Beam
    [31493] = true, -- MGQ2 Give PC Wabbajack
    [26587] = true, -- Wabbajack
    [70471] = true, -- Wabbajack
    [70473] = true, -- Wabbajack HIT
    [6618] = true,  -- CON_SmokeBurst
    [27651] = true, -- MGQ2 PC Used Wabbajack on Targ
    [27238] = true, -- Explosion
    [26684] = true, -- Charge

    -- Circus of Cheerful Slaughter
    [16859] = true, -- MG Quest 3 Teleporting Book
    [16882] = true, -- MG Quest 3 Pet on Fire
    [27637] = true, -- Queen's Fury
    [34854] = true, -- Immune
    -- [29814] = true, -- Ansei Ward
    -- [29815] = true, -- Ansei Ward 3
    [29827] = true, -- MG Mage Despawn
    [34858] = true, -- Book

    -- Chateau of the Ravenous Rodent
    [26735] = true, -- MG4 Sheo Stun Shali
    [25878] = true, -- MG Sheogorath Despawn
    [31123] = true, -- Darkness
    [31128] = true, -- Darkness
    [16870] = true, -- Crystal Beam
    [31279] = true, -- MG4 Book Banish PC

    -- The Mad God's Bargain
    [31331] = true, -- Book Beam
    [31342] = true, -- Archmage Surprise
    [31435] = true, -- MGQ5 Book 4
    [31434] = true, -- MGQ5 Book 3
    [31433] = true, -- MGQ5 Book 2
    [31432] = true, -- MGQ5 Book 1
    [31361] = true, -- Summon Portal
    [31444] = true, -- Screen Shake
    [31446] = true, -- Screen Shake
    [31450] = true, -- Shivering Summons
    -- [39370] = true, -- MGQ5_Knockback&KnockdownSelf
    -- [39371] = true, -- Fire Backlash
    [17478] = true, -- MG Quest 5 Sheo Stun
    [17551] = true, -- Spectral Key
    [20928] = true, -- Spectral Key
    [39554] = true, -- Butterfly Shield
    [39555] = true, -- Summon Scamp
    [39527] = true, -- Skeleton Trap
    [39528] = true, -- Projectile
    [39529] = true, -- Trap Down
    [39533] = true, -- Polymorph
    [40851] = true, -- Polymorph Snare
    [35533] = true, -- Polymorph
    [39556] = true, -- Transform Scamp
    [39558] = true, -- Rabbit
    [39559] = true, -- Atronach
    [39560] = true, -- Netch
    [39391] = true, -- Summon Pig
    [39393] = true, -- Ungulate Ordnance
    [39423] = true, -- Mad God's Whimsy

    -- The Arch-Mage's Boon
    [7700] = true,  -- EB Generic 5 Min Counter 01
    [48094] = true, -- Q4971 Shalidor Prep
    [48098] = true, -- Q4971 Shaldior Read
    [48077] = true, -- Q4971 Shali Cast (Saved)

    --------------------------------------
    -- QUEST / ZONES - ALDMERI DOMINION --
    --------------------------------------

    --------------------
    -- Khenarthi's Roost
    --------------------

    -- World Events
    [32460] = true, -- KR ES Walking Speed Rand
    [25311] = true, -- AM Posture Reset
    [32085] = true, -- Q4680 Water Stone Beam
    [32765] = true, -- KR-TM Priestess Cast

    -- Storm on the Horizon
    [35411] = true, -- Q4680 - CV Wait
    [51219] = true, -- Q4680 End Quest CV

    -- Cast Adrift
    [31429] = true, -- Q4620 01 Healed Edhelas
    [31430] = true, -- Q4620 01 Healed Nistel
    [31431] = true, -- Q4620 01 Healed Onglorn
    [35192] = true, -- Q4620 Use Lodestone

    -- Tears of the Two Moons
    [32766] = true, -- 4625 Uldor's Possession
    [32052] = true, -- 4625 02 Skeleton Exploade
    [32053] = true, -- 4625 02 Skeleton Exploade
    [31649] = true, -- 4625 Ward 1
    [31665] = true, -- 4625 Ward 2
    [33233] = true, -- 4625 Stun for Beckon 1.5s
    [31652] = true, -- 4625 Gathwen Destory Ward
    [33231] = true, -- 4625 Ward Destory
    [33029] = true, -- Blessing (Gathwen)
    [33136] = true, -- Blessing (Gathwen)
    [35185] = true, -- 4625 Heal (Gathwen)
    [32063] = true, -- Feedback
    [49084] = true, -- RobS PC 1 Dmg Limit
    [31740] = true, -- 4625 Damage Shield
    [35195] = true, -- No Heal Check
    [11451] = true, -- CON_NecroBoneExplosion
    [31709] = true, -- 4625 Gathwen Beam Ritual
    [35197] = true, -- Beam Damage
    [31745] = true, -- Risen Dead
    [32056] = true, -- 4625 08 Gathwen Down
    [33278] = true, -- Increased Speed
    [32060] = true, -- Shocked
    [32768] = true, -- 4625 Uldor's Evil Spirit
    [33285] = true, -- 4625 Uldor Banish
    [11069] = true, -- CON_DistortionAura
    [22524] = true, -- Teleport
    [61732] = true, -- Q4625 Distortion
    [32705] = true, -- 4625 No Yell
    [31968] = true, -- Wrath
    [31969] = true, -- Wrath
    [31970] = true, -- Wrath
    [33449] = true, -- 4625 Stop Bolts
    [33402] = true, -- Wrath
    [33403] = true, -- Wrath
    [33404] = true, -- Wrath

    -- The Perils of Diplomacy
    [32264] = true, -- Unconscious
    [36094] = true, -- Q4624 Treaty Tracker
    [31608] = true, -- Q4624
    [46686] = true, -- Hidden in Crate
    [32594] = true, -- Q4624 GL Smellovision Spell
    [33284] = true, -- Q4624 GL Speed Buff
    [31543] = true, -- KR MS Follow Trail CV
    [31788] = true, -- KR MS Maormer Assassin
    [32595] = true, -- Q4624 GL Murderizing
    [16376] = true, -- AM Q3834 Ninja Poof
    [32604] = true, -- Q4624 Deal with Maormer Stab

    -- The Tempest Unleashed
    [34454] = true, -- KR CQ Maormer Wind Trail
    [54244] = true, -- CV Delay 3 Seconds
    [34567] = true, -- Q4621 PC Storm Drain
    [10223] = true, -- NPC 75% Speed
    [26186] = true, -- Q4406 Water Splash
    [34701] = true, -- Q4621 Destory Horn
    [34708] = true, -- Q4621 Horn Exploade
    [26952] = true, -- Jump Down 10 Meters
    [34735] = true, -- Q4621 Atronach Death
    [34746] = true, -- a
    [34747] = true, -- a

    -- Dark Knowledge
    [6351] = true,  -- CON_GhostlyFlash
    [32571] = true, -- Q4667 Spinners
    [32581] = true, -- Q4667 Daedroth ATK
    [32574] = true, -- Q4667 Watcher
    [35271] = true, -- CV Delay 30 Seconds
    [35264] = true, -- Q4667 Pulling Grasp
    [35265] = true, -- Q4667 Stun
    [35268] = true, -- Sahira Screams

    -- The Root of the Problem
    [44213] = true, -- Scrib Corruption
    [32214] = true, -- KR-MN Lurching
    [32864] = true, -- Q4673 Kwama Gnaw FX
    [32188] = true, -- SW Stun
    [32116] = true, -- Rejuvination
    [44214] = true, -- Scrib Cleanse
    [31948] = true, -- Burrow
    [31947] = true, -- Burrow

    -- A Pinch of Sugar
    [32495] = true, -- Q4692 Talking
    [32335] = true, -- Q4692 Thunderthrow
    [32330] = true, -- Q4962 Thunderburrow
    [32359] = true, -- Thunderstrikes
    [37044] = true, -- Q4692 ACT
    [37045] = true, -- Q4692 VIS
    [37046] = true, -- Q4692 ACT
    [37047] = true, -- Q4692 VIS
    [37039] = true, -- Q4692 ACT
    [37041] = true, -- Q4692 VIS
    [37035] = true, -- Q4692 ACT
    [37036] = true, -- Q4692 VIS
    [37042] = true, -- Q4692 ACT
    [37043] = true, -- Q4692 VIS

    -- The Family Business
    [32877] = true, -- 4693 Skooma Bag Exploade

    -- Moon-Sugar Medicament
    -- [43047] = true, -- RobS Crouch Fiddle 3 Sec

    --------------------
    -- Auridon
    --------------------

    -- World Boss - Seaside Scarp Camp
    [10854] = true, -- Can Spread Out -- Quenyas
    [45789] = true, -- RobS Bone Colossus Rise -- Oskana
    [84048] = true, -- Defiled Ground -- Quenyas
    [84047] = true, -- Defiled Ground -- Quenyas
    [84045] = true, -- Seal of Defilement -- Quenyas
    [84044] = true, -- Seal of Defilement -- Quenyas
    [84050] = true, -- Defiled Ground -- Quenyas
    [83782] = true, -- Staff Strike -- Quenyas
    [83783] = true, -- Bash -- Quenyas
    [83776] = true, -- Dark Summons -- Quenyas
    [84283] = true, -- Coursing Bones (Oskana)
    [84285] = true, -- Coursing Bones (Oskana)
    [84284] = true, -- Coursing Bones (Oskana)
    [84286] = true, -- Wake the Dead -- Oskana
    [84287] = true, -- Voice to Wake the Dead -- Oskana
    [84288] = true, -- Voice to Wake the Dead -- Oskana
    [84289] = true, -- Voice to Wake the Dead -- Oskana

    -- World Boss - Wreck of the Raptor
    [32858] = true, -- CON_Ghost Ship Auridon FX

    -- World Boss - Heretic's Summons
    [82984] = true, -- Rending Leap
    [82986] = true, -- Rending Leap
    [82934] = true, -- Shrieking Summons -- Snapjaw
    [83013] = true, -- Shrieking Summons -- Snapjaw
    [82935] = true, -- Summon Brood -- Snapjaw
    [82937] = true, -- Summon Brood - Snapjaw
    [83151] = true, -- Savage Claw -- Snapjaw
    [83150] = true, -- Tail Whip -- Snapjaw
    [83009] = true, -- Rending Leap -- Snapjaw
    [83059] = true, -- Rending Leap -- Snapjaw
    [83011] = true, -- Rending Leap -- Snapjaw
    [87989] = true, -- Rending Leap -- Snapjaw
    [83012] = true, -- Devour -- Snapjaw
    [85649] = true, -- Devour -- Snapjaw
    [83169] = true, -- Devour -- Snapjaw
    [83049] = true, -- Charge -- Clannfear
    [83038] = true, -- Charge -- Clannfear
    [83036] = true, -- Ferocious Charge -- Clannfear
    [83033] = true, -- Ferocious Charge -- Clannfear
    [83039] = true, -- Ferocious Charge -- Clannfear
    [83040] = true, -- Focused Charge -- Clannfear
    [83035] = true, -- Charge -- Clannfear
    [83034] = true, -- Charge -- Clannfear
    [83041] = true, -- Charge Charge -- Clannfear
    [83042] = true, -- Ferocious Charge -- Clannfear
    [83046] = true, -- Charge -- Clannfear
    [83016] = true, -- Necrotic Explosion -- Clannfear
    [83017] = true, -- Daedric Explosion -- Clannfear
    [83018] = true, -- Daedric Explosion -- Clannfear

    -- World Boss - Heritance Proving Ground
    [26248] = true, -- Quck Strike
    [47259] = true, -- Frostarrows

    -- Delve - Ondil
    [22687] = true, -- Gen Ritual Necromantic

    -- Delve - Entila's Folly
    [52402] = true, -- Webdrop

    -- Delve -- Bewan
    [7701] = true, -- EB Generic 5 Min Counter 02
    [7702] = true, -- EB Generic 5 Min Counter 03

    -- Delve -- Mehrune's Spite
    [47218] = true, -- AR-DC5-Boss Mati

    -- Public Dungeon - Toothmaul Gully
    [56731] = true, -- Bloodroot Link
    -- [58937] = true, -- Generic Assassinate an NPC
    -- [58939] = true, -- Generic Assassinate an NPC

    -- Ensuring Security
    [22692] = true, -- Q4255 VH Soldier Spawn

    -- A Hostile Situation
    [22579] = true, -- Q4255 PC Black Out and Port
    [51296] = true, -- Test Waypoint Tele
    [25347] = true, -- Q4256 Eminwe's Arrow
    [22699] = true, -- Q4256 Event Jump

    -- To Tanzelwil
    [50783] = true, -- Q4211 - Needs Finish Quest

    -- In the Name of the Queen
    [22274] = true, -- Ancestral Binding
    [21533] = true, -- CON_EVilBeamSummonOnSelf

    -- Rites of the Queen
    [48921] = true, -- Ancestral Spirit
    [48922] = true, -- Boss
    [48924] = true, -- Ancestral Spirit
    [48926] = true, -- Boss
    [48927] = true, -- Ancestral Spirit
    [48929] = true, -- Boss

    -- The Unveiling
    [28714] = true, -- Q4294 Fade to Black 5sec
    [50762] = true, -- Q4294 Fade to Black 5sec
    [22718] = true, -- Knock Out
    [50763] = true, -- Q4294 Fade to Black 5sec
    [36540] = true, -- 2 Second Timer
    [61575] = true, -- CON_Destealth
    [10665] = true, -- Generic Permanent Hidden Abili

    -- Lifting the Veil
    [29684] = true, -- Q4330 Altmer Disguise (Raz)
    [23392] = true, -- Altmer Glamour
    [23540] = true, -- Teleport
    [23527] = true, -- Drinking...
    [23543] = true, -- Teleport

    -- The Veil Falls
    [24807] = true, -- Hidden Buff 30sec
    [24254] = true, -- Door Beam 1
    [46068] = true, -- Door Beam 2
    [46069] = true, -- Door Beam 3

    -- To Dawnbreak
    [24855] = true, -- Q4355 Lan + Sin Theater

    -- Through the Ashes
    [16864] = true, -- CON_SmokeBurst
    [24864] = true, -- Q4355 PC
    [25333] = true, -- Q4355 PC Completed Fasaran
    [24863] = true, -- Q4355 PC Persauded Elannie
    [25332] = true, -- Q4355 PC Completed Elannie
    [48646] = true, -- Magefire
    [2379] = true,  -- On Fire

    -- Breaking the Barrier
    [21876] = true, -- Q4260 West Barrier Teleport
    [21878] = true, -- Q4260 East Barrier Teleport

    -- Sever All Ties
    [22395] = true, -- Q4261 ROD Barrier Teleport
    [22423] = true, -- Q4261 Counter 1
    [22424] = true, -- Q4261 Counter 2
    [22425] = true, -- Q4261 Counter 3
    [22426] = true, -- Q4261 Counter 4
    [22349] = true, -- ROD CV Puzzle Flame 1
    [22350] = true, -- ROD CV Puzzle Flame 2
    [22351] = true, -- ROD CV Puzzle Flame 3
    [22355] = true, -- ROD CV Puzzle Flame 4
    [22400] = true, -- Q4261 ROD PC Finished Puzzle
    [21770] = true, -- Q4261 ROD PC Returns 1
    [21771] = true, -- Q4261 ROD PC Returns 2
    [10991] = true, -- Generic Magic Explosion Small
    [21772] = true, -- Q4261 ROD PC Returns 3
    [24790] = true, -- Q4261 Daedric Estre
    [44120] = true, -- Q4261 Damage Shield 3 Sec
    [44141] = true, -- RobS Quick Stun
    [44138] = true, -- Q4261 Estre Knockback
    [44140] = true, -- Q4686 Aulus Shield
    [44153] = true, -- Q4261 Healer Blocks
    [44157] = true, -- Q4261 Healer Blocks Stun
    [22074] = true, -- Q4261 ROD Event Atro Spawn In
    [49224] = true, -- Q4868 Aulus Knockback
    [49223] = true, -- Q4868 Aulus Knockback
    [44136] = true, -- RobS Stun Perm
    [44105] = true, -- Q4261 Damage Shield
    [22030] = true, -- Q4261 ROD Event Atro on Estre
    [38279] = true, -- Generic Permasurrender
    [44171] = true, -- Q4261 Estre Dead
    [44169] = true, -- Q4261
    [21831] = true, -- Q4261 CV Finale Friendlies
    [21778] = true, -- ROD PC Returns 4

    -- The Great Tree
    [46762] = true, -- Drinking Contest

    -- Silsailen Rescue
    [25353] = true, -- Hidden Buff 7sec

    -- Real Marines
    -- [44289] = true, -- Generic UFX Crouch Fiddle
    [22378] = true, -- Equiping...

    -- Teldur's End
    [3961] = true, -- Generic 8m Fake Buff

    -- The Serpent's Beacon
    [64303] = true, -- Drinking Mead
    [21364] = true, -- Casting...
    [21409] = true, -- Reading...

    -- Corruption Stones
    [22889] = true, -- Purifying
    [22912] = true, -- Q4223 Purification
    [22930] = true, -- Q4223 Purification
    [22929] = true, -- Q4223 Purification

    -- The First Patient
    [85079] = true, -- Knockback
    [22448] = true, -- Q4266 Tie up Hendil

    -- Depths of Madness
    [22077] = true, -- Teleport
    [22470] = true, -- Q4272 Sanessalmo Taunt Buff ST
    [22079] = true, -- Teleport
    [22158] = true, -- Collecting Magic with Jar...
    [22141] = true, -- Collecting...
    [22160] = true, -- Collecting...
    [22187] = true, -- Throwing Spore Potion
    [22081] = true, -- Portal to Despair
    [21985] = true, -- Teleport
    [22271] = true, -- Teleport Scroll AB

    -- Silent Village
    [22277] = true, -- Magic Explosion
    [22533] = true, -- Weakened
    [21968] = true, -- Binding Bear...
    [46993] = true, -- Destruction Beam
    [45784] = true, -- Generic Spawn Fire Atronach AM

    -- A Village Awakened
    [23329] = true, -- Binding
    [23332] = true, -- Binding

    -- Take Me Home
    [3055] = true,  -- CV Delay 2 Seconds
    [28264] = true, -- Summon Familiar

    -- The Racer
    [25642] = true,  -- Q4409 Frog Run Speed
    [48489] = true,  -- Q4409-Timer,Short(15s)
    [112463] = true, -- Speed

    -- Spirited Away
    [25651] = true, -- Distortion Spawn
    [25678] = true, -- Transformation

    -- The Mallari-Mora
    -- [47077] = true, -- Knockback Stagger
    -- [47082] = true, -- Fire Backlash
    [21333] = true, -- Forging...
    [21643] = true, -- Q4220 CV Undercroft Barrier
    [24789] = true, -- Q4220 Soul Thirster Ground Pro
    [28771] = true, -- Q4220 Thirster Stun
    [21108] = true, -- Transferring...
    [21393] = true, -- Q4220 PC Chooses to Rescue
    [21040] = true, -- Q4220 Spirit Layer Ability
    [21112] = true, -- Q4220 PC Forced to L0
    [21656] = true, -- Q4220 PC Spawned Ghost 1/4
    [21657] = true, -- Q4220 PC Spawned Ghost 2/4
    [21658] = true, -- Q4220 PC Spawned Ghost 3/4
    [45191] = true, -- Q4220 Asst. Soul PFX
    [21106] = true, -- Q4220 Assistant Death
    [21391] = true, -- Q4220 CV Elenya Rescued
    [21398] = true, -- Q4220 PC to L0 Elenya Rescued
    [21390] = true, -- Q4220 CV Bolion Rescued
    [21397] = true, -- Q4220 PC to L0 Bolion Rescued
    [21392] = true, -- Q4220 CV Eryon Rescued
    [21399] = true, -- Q4220 PC to L0 Eryon Rescued
    [21389] = true, -- Q4220 CV Jiluza Rescued
    [21395] = true, -- Q4220 PC to L0 Jiluza Rescued
    [21403] = true, -- Spiritual Cloak
    [21672] = true, -- Q4220 Uri Projection FX

    -- An Act of Kindness
    [21674] = true, -- Q4221 Spirit Surrender Flag
    [22931] = true, -- Freeing Spirit...
    [21309] = true, -- Q4221 Quaronaldil Despawn
    [21331] = true, -- Q4221 PC Used Persuade
    [21282] = true, -- Q4221 CV Thief
    [21283] = true, -- Q4221 CV Warrior
    [21284] = true, -- Q4221 CV Serpent
    [21285] = true, -- Q4221 CV Mage
    [21286] = true, -- Q4221 CV Tower
    [21287] = true, -- Q4221 CV Lady
    [21288] = true, -- Q4221 CV Atronach
    [21289] = true, -- Q4221 CV Lord
    [21290] = true, -- Q4221 CV Steed
    [21291] = true, -- Q4221 CV Shadow
    [21292] = true, -- Q4221 CV Lover
    [21293] = true, -- Q4221 CV Ritual
    [21294] = true, -- Q4221 CV Apprentice
    [21315] = true, -- Spike Trap
    [21313] = true, -- Crippled!
    [21314] = true, -- Trap Sprung!
    [23656] = true, -- Q4221 Sirinque FX
    [23657] = true, -- Q4221 Sirinque FX Shake
    [23797] = true, -- Q4221 Sirinque Knockdown

    -- The Veiled Choice
    [23187] = true, -- Q4236 PC Untie Palith
    [30707] = true, -- Disguising...
    [23553] = true, -- Disguised

    -- Preventative Measure
    [23608] = true, -- Q4327 PC Used
    [23609] = true, -- Perparing Crystal...
    [22202] = true, -- CTY-Beam,Electric
    [23606] = true, -- Q4326 Crystal Backfire
    [23538] = true, -- Q4327 Sabotage
    [61446] = true, -- CON_ShockExplosion
    [24546] = true, -- Disrupting...
    [24535] = true, -- Disrupting...
    [24563] = true, -- Q4327 Delves Stop Casting
    [24548] = true, -- Recalling...

    -- Harsh Lesson
    [24660] = true, -- Defeated
    [30749] = true, -- Q4329 White Flag
    [25430] = true, -- Smoke Bomb
    [25305] = true, -- Bat Jump

    -- Blessings of the Eight
    [47149] = true, -- Magefire
    [23159] = true, -- Divine Speed
    [22728] = true, -- Water Beam
    [23217] = true, -- Fire Beam
    [24647] = true, -- Hidden Buff 1min
    [22745] = true, -- Q4300 Brazier A1
    [22746] = true, -- Q4300 Brazier A2
    [22747] = true, -- Q4300 Brazier A3
    [22748] = true, -- Q4300 Brazier A4
    [22749] = true, -- Q4300 Brazier B1
    [22750] = true, -- Q4300 Brazier B2
    [22751] = true, -- Q4300 Brazier B3
    [22752] = true, -- Q4300 Brazier B4

    -- Relic Rescue
    [11199] = true, -- Self Combat Delay

    -- Eye of the Ancients
    [24265] = true, -- Q4338 Buff Delay
    [24233] = true, -- Q4338 Source Fire Beam
    [24089] = true, -- Q4338 Fire Beam East
    [23805] = true, -- Q4338 Fire Beam West

    -- The Wayward Dagger
    [23344] = true, -- Q4295 General Say Buff
    [23357] = true, -- Q4295 Barracks Say Buff
    [23367] = true, -- Q4295 Bernadine Say Buff

    -- Eye Spy
    [11340] = true, -- CV Delay 30 Seconds
    [23454] = true, -- Disguising...
    [25600] = true, -- CV Delay 9 Seconds

    -- Rightful Inheritance
    [24826] = true, -- Spiteful Essence
    [24827] = true, -- Magic Explosion
    [30761] = true, -- CON_Skeleton Rise Dirt
    [30741] = true, -- Sorondil Helmet
    [49152] = true, -- Q4361 Werewolf Transform
    [49153] = true, -- Q4361 Werewolf Transform

    --------------------
    -- Grahtwood
    --------------------

    -- World Events
    [39775] = true, -- GW CTen BosmVKhaj Scare Ending (Peacemaker Achievement Location)
    [40035] = true, -- GW CTen Swinging Axe (Peacemaker Achievement Location)
    [39776] = true, -- GW CTen BosmVKhaj Calm Ending (Peacemaker Achievement Location)
    [39649] = true, -- GW CTen KhajVAltm Happy Comp (Peacemaker Achievement Location)
    [39650] = true, -- GW CTen KhajVAltm Sad Comp (Peacemaker Achievement Location)
    [60390] = true, -- Visability (Misc)
    [39638] = true, -- GW CulTen BosVSAlt Happy Comp (Peacemaker Achievement Location)

    -- World Boss - Nindaeril's Perch
    [70466] = true, -- 35% Boss Speed Buff (Nindaeril the Monsoon)
    [83515] = true, -- Hunter's Pounce (Bavura the Blizzard)
    [83517] = true, -- Hunter's Pounce (Bavura the Blizzard)
    [84018] = true, -- Hunter's Pounce (Bavura the Blizzard)
    [83521] = true, -- Hunter's Pounce (Bavura the Blizzard)
    [83832] = true, -- Frenzied Charge (Nindaeril the Monsoon)
    [83833] = true, -- Frenzied Charge (Nindaeril the Monsoon)
    [83846] = true, -- Frenzied Charge (Nindaeril the Monsoon)
    [83855] = true, -- Frenzied Charge (Nindaeril the Monsoon)
    [83852] = true, -- Frenzied Charge (Nindaeril the Monsoon)
    [83548] = true, -- Mighty Roar (Nindaeril the Monsoon)
    [83549] = true, -- Mighty Roar (Nindaeril the Monsoon)
    [83152] = true, -- Regal Fury (Both Cats)

    -- Public Dungeon - Root Sunder Ruins
    -- [34175] = true, -- Ground Rise
    [34176] = true, -- Blue Flam
    [57076] = true, -- Sundered Barrier

    -- Public Dungeon - Root Sunder Ruins - Forgotten Soul
    [26163] = true, -- Q4406 Entrance Laughter
    [38510] = true, -- Q4406 Post Accept SAT
    [26118] = true, -- Root Sunder
    [91627] = true, -- Root Sunder's Favor

    -- The Honor of the Queen
    [61157] = true, -- Q4943 Scene Tracker

    -- The Grips of Madness
    [38181] = true, -- Monster V Monster
    [38183] = true, -- Monster V Monster Heal
    [38218] = true, -- Q4868 Crazy Stun
    -- [43047] = true, -- RobS Crouch Fiddle 3 Sec
    [37276] = true, -- Q4868 Beast Person
    [38911] = true, -- Q4868 Beast Bear Begin
    [38918] = true, -- Improved Combat Health Regen R8
    [37277] = true, -- Q4868 Change Beast Person
    [37296] = true, -- Q4868 Change Beast Person
    [37297] = true, -- Q4868 Change Beast Person
    [37427] = true, -- 4868 Damage Shield
    [37315] = true, -- CFX_4868
    [37295] = true, -- Q4868 Change Beast Person
    [38498] = true, -- Lightning
    [38499] = true, -- Wrath
    [38500] = true, -- Wrath
    [37438] = true, -- Shocked
    [37436] = true, -- Shock
    [38516] = true, -- Q4868 Rufinus Is Lightning
    -- [47720] = true, -- RobS Stun 1 Sec
    [37463] = true, -- Q4868 Push NPC
    [38468] = true, -- Q4842 Stun
    [37464] = true, -- Q4842 Stun
    [37465] = true, -- Q4842 Despawn Self
    [38942] = true, -- Q4868 Rufinus Is Shocked
    [38943] = true, -- Rufinus's Lightning
    [38584] = true, -- Q4868 Push NPC
    [38596] = true, -- Q4842 Stun
    [37583] = true, -- Q4868 Unlock Chapel
    [37824] = true, -- Q4868 Elinwe Transform
    [38079] = true, -- CFX_4868 Sheo Spawn
    [37988] = true, -- Fire Backlash
    [38105] = true, -- CFX_4868 Sheo Spawn
    [38104] = true, -- CFX_4868 Sheo Spawn
    [38744] = true, -- Q4868 Sheo Teleports Player
    [38108] = true, -- Q4868 Sheo Teleports Player
    [38400] = true, -- Q4868 Stun Fade 2 Black
    [38116] = true, -- Q4868 Sheo Minions Spawn
    [38432] = true, -- CFX_4868 Sheo Fast Despawn
    [38720] = true, -- Lightning Fury
    [47710] = true, -- Lightning Fury
    [38426] = true, -- Q4868 Sheo Teleports Aulus
    [38748] = true, -- Aulus's Tongue
    [63710] = true, -- Aulus's Tongue
    [40702] = true, -- Q4868 Aulus Knockback
    [45978] = true, -- Q4868 Aulus Shield
    [40704] = true, -- Q4868 Aulus Knockback
    [44100] = true, -- Q4868 Aulus Knockback
    [47709] = true, -- Q4868 Aulus Knockback

    -- A Lasting Winter
    [2326] = true,  -- Ritual Cast
    [21622] = true, -- Hakra Is Called
    [11026] = true, -- Generic Shatter
    [47816] = true, -- Q4885 Nairume Near PC
    [47702] = true, -- Q4885 Block Use Ring
    [47706] = true, -- Q4885 Tag For Ice Stun
    [38377] = true, -- Q4885
    [38394] = true, -- Shatter
    [47780] = true, -- Q4885 Endare FX
    [38419] = true, -- Q4885 Endare Spawn In
    [42938] = true, -- GW-FW Endare
    [47756] = true, -- Q4885 Tag for Spawn Clone
    [38413] = true, -- Spawn Clone
    [47762] = true, -- Spawn Clone
    [47781] = true, -- Q4885 Clone Beam
    [38418] = true, -- Sibling Health
    [47770] = true, -- Q4885 Clone Less DMG
    [47768] = true, -- RobS Immunities 6 Sec
    [47782] = true, -- Q4885 Endare Leash FX
    [38441] = true, -- Become
    [47784] = true, -- Q4885 Inivs Lootable Spawn
    [47783] = true, -- Become
    [47804] = true, -- Q4885 Rajhin's Mantle Appears
    [47805] = true, -- Q4885 Rajhin's Mantle Appears
    [44664] = true, -- CV Delay 60 Seconds
    [41859] = true, -- Q4885 Completed 4885

    -- Lost in Study
    [25615] = true, -- Q4385 Flying Books
    [39535] = true, -- Q4893 Ukezai
    [39621] = true, -- Q4385 Stone
    [25751] = true, -- Q4385 Behelir Captive FX

    -- Heart of the Matter
    [25761] = true, -- Q4386 Bookcase Open
    [39783] = true, -- Q4386 Ukaezai Flip
    [46812] = true, -- Q4386 Ukaezai Body FX
    [39876] = true, -- Q4386 Port Down
    [45891] = true, -- Q4386 Port Stun
    [39908] = true, -- Q4386 Port Down
    [45972] = true, -- Q4386 Ukaezai Split 3
    [45975] = true, -- Q4386 Ukaezai Split 3
    [45997] = true, -- Q4386 Ukaezai Split 3
    [46188] = true, -- Q4386 Ukaezai Faints
    [45998] = true, -- Q4386 Ukaezai Book Summon
    [40848] = true, -- Q4385 Savage Book
    [40754] = true, -- Q4386 Vortex
    [40849] = true, -- Annihilation
    [39956] = true, -- Heart of Anumaril
    [46144] = true, -- Q4386 Ukaezai Boss Recover
    [45973] = true, -- Q4386 Ukaezai Split 2
    [45976] = true, -- Q4386 Ukaezai Split 2
    [46036] = true, -- Q4386 Ukaezai Split 2
    [45974] = true, -- Q4386 Ukaezai Split 1
    [45977] = true, -- Q4386 Ukaezai Split 1
    [46037] = true, -- Q4386 Ukaezai Split 1
    [25916] = true, -- Q4386 Child Cleanup
    [25917] = true, -- Q4386 Child Cleanup

    -- The Orrery of Elden Root
    [41979] = true, -- RobS Despawn Me Flag
    [40500] = true, -- Q4922 Use Mantle on Device
    [40504] = true, -- Q4922 Use Mantle on Device
    [40056] = true, -- Q4922 Mantle's Shadow
    [41862] = true, -- Q4922 Orrery Rumble Long
    [41863] = true, -- Q4922 Orrery Rumble
    [41860] = true, -- Q4922_Naemon Build Up
    [40038] = true, -- Q4922 Magic Bubble NPC
    [39595] = true, -- Q4922 Magic Bubble PC
    [40115] = true, -- Q4922_Naemon Cast FX
    [40390] = true, -- Q4922_Naemon Reverse Cast
    [22683] = true, -- Opening a Portal
    [40557] = true, -- (12127) CFX_4922 Mantle Cast S
    [14568] = true, -- TEST_Ritual Arcane
    [40121] = true, -- Q4922 Orrery Spawn Naemon
    [43829] = true, -- Q4922_Naemon_Spawn
    [40403] = true, -- Q4922 Orrery Screen Shake
    [40394] = true, -- CFX_4922 Naemon Ogre Glow
    [43820] = true, -- Quaking Stomp (Prince Naemon)
    [43822] = true, -- Quaking Stomp (Prince Naemon)
    [43823] = true, -- IntroKB (Prince Naemon)
    [43821] = true, -- Staggering Roar (Prince Naemon)
    [43827] = true, -- Projectile Vomit (Prince Naemon)
    [43828] = true, -- Belch (Prince Naemon)
    [40537] = true, -- Q49222 Ogre Transform Dead
    [40532] = true, -- Q49222 Ogre Transform Dead
    [40141] = true, -- Q4922 Orrery Spawn Ayrenn
    [41949] = true, -- Q4922 Ayrenn Spawn
    [40396] = true, -- Q4922 Ayrenn Divine Glow

    -- The Staff of Magnus
    [46997] = true, -- EB Generic 5 Sec Counter 01
    [33257] = true, -- EB Generic 10 Sec Counter 01
    [37037] = true, -- Q4735 Final Ayreen CV

    -- Passage Denied
    [39415] = true, -- Q4963 Close Portal
    [47301] = true, -- Stunned

    -- Forbidden Love
    [41340] = true, -- Q4387 Eraduure Extension
    [41341] = true, -- Q4387 Eraduure Out

    -- The Blacksap's Hold
    [39086] = true, -- Q4917 Spawn Portal
    [39110] = true, -- Q4917 Opens Portal
    [39158] = true, -- Q4917 03 Opens Portal
    [30750] = true, -- Generic Fade To Black 2.5s
    [32693] = true, -- 4625 Stun for Teleport 2.5s
    [39199] = true, -- Q4917 Thane Theater
    [39247] = true, -- RobS Stun .5 Sec
    [39244] = true, -- Q4917 Push Player Back
    [39260] = true, -- Q4917 Push Player Back
    [41342] = true, -- 10 Second Timer
    [39317] = true, -- Q4917 Left Hand Glow
    [39312] = true, -- CON_Portal Perm
    [39307] = true, -- Pulling Grasp
    [39308] = true, -- Stun
    [39384] = true, -- Q4917 Lurcher Construct Ground
    [41325] = true, -- Blacksap's Brew
    [39293] = true, -- Q4917 Lurcher Spawn
    [39504] = true, -- Q4917 Return to Prison
    [39502] = true, -- Q4917 Maeroth Theatre

    -- Unsafe Haven
    [26041] = true, -- Eavesdropping...
    [60389] = true, -- Bag Rat
    [41955] = true, -- Q4396 Completed

    -- Luck of the Albatross
    [18628] = true, -- Generic Stun Self
    [35984] = true, -- Q4436 Summon Pirate
    [24762] = true, -- CON_StealthVanish

    -- Forever Bound
    [37120] = true, -- FX_Q4445_Channel_Capture
    [35964] = true, -- 4445 Stun + Headgrab

    -- Scars Never Fade
    [35968] = true, -- Q4768 Bestowal Theatre Check
    [39542] = true, -- Q4768 Bestowal Theatre Block
    [35606] = true, -- Q4768 Duel Start Stun
    [41339] = true, -- RobS Stun 3 Sec
    [43151] = true, -- Q4768 Use Bucket
    [34867] = true, -- Q4768 No-Fingers Wet
    [35645] = true, -- Q4768 PC Tribunal Layer 2 Stun
    [34887] = true, -- Q4768 Tribunal Stun
    [34886] = true, -- Q4768 Slim-Jah Kills
    [35621] = true, -- Q4768 Search Mouse Hover
    [34933] = true, -- Q4768 Search Beach
    [34931] = true, -- Q4768 Stealh Argonian
    [34990] = true, -- Q4768 Stealth Stun
    [34551] = true, -- Q4768 Slim-Jah Beam

    -- Keeper of the Bones
    [35805] = true, -- SW Risen Dead
    [35852] = true, -- Dringoth
    [38637] = true, -- SW Theatre Tracker A
    [35848] = true, -- Q4773 Borchon
    [35855] = true, -- Q4773 Dringoth Possess
    [35854] = true, -- Q4773 Dringoth Splode
    [35858] = true, -- Possessed
    [64083] = true, -- Q4773 Dringoth Rib Cooldown
    [35862] = true, -- Possessed
    [35980] = true, -- Q4773 Stun
    [35857] = true, -- Q4773 Dringoth Proxy Splode
    [36639] = true, -- Q4773 Ethruin Rise

    -- Bosmer Insight
    [36161] = true, -- Q4833 Bestowal Hunter Spawn
    [36437] = true, -- Q4833 Fire Burst
    [36409] = true, -- Q4833
    [36438] = true, -- Q4833
    [36411] = true, -- Q4833
    [36457] = true, -- Q4833 Tiger Roar
    [36477] = true, -- Q4833 Wolf Howl
    [36544] = true, -- Fast Jumper
    [36554] = true, -- Vision Journey Start
    [36558] = true, -- Vision Journey Start
    [36859] = true, -- Vision Journey Start
    [36565] = true, -- Vision Journey Start
    [36597] = true, -- Vision Journey Start
    [36559] = true, -- Vision Journey Start
    [35991] = true, -- Vision Journey
    [36604] = true, -- Q4883 Spriggan Nature Spawn
    [36879] = true, -- Q4833 Teleport into Tree
    [36883] = true, -- Q4833 Teleport into Tree
    [36882] = true, -- Q4833 Teleport into Tree
    [36655] = true, -- RobS Screen Shake
    [36676] = true, -- Q4833 Nature Teleport PC
    [36677] = true, -- Q4833 Nature Teleport PC
    [36710] = true, -- Q4833 Apply Snake Buff
    [36713] = true, -- Snake Scales
    [36841] = true, -- Q4883 Apply Wolf Buff
    [36843] = true, -- Wolf's Pelt
    [36824] = true, -- Q4883 Apply Tiger Buff
    [36828] = true, -- Tiger's Fur

    -- The Unquiet Dead
    [37361] = true, -- CFX_4842 Ossuary Ghost Possess
    [37062] = true, -- Exorcise
    [17049] = true, -- CV Delay 6 Seconds
    [63719] = true, -- Double Strike
    [63720] = true, -- Double Strike
    [36887] = true, -- Kithshade Stun
    [36766] = true, -- Q4842 Stun Headgrab Knockback
    [36762] = true, -- Q4842 Puzzle Fail

    [36998] = true, -- Bind Spirit
    [36996] = true, -- Bind Spirit
    [37363] = true, -- Q4842 Pulling Slow
    [37365] = true, -- Q4842 Stun

    -- Until Death
    [39219] = true, -- Using Whistle...

    -- Phantom Guilt
    [38644] = true, -- Q4895-RecentCreepyWhisper
    [38642] = true, -- Q4895-FireCreepyWhisper

    -- Rare Imports
    [42388] = true, -- Q4908-KwamaChampSelfStun

    -- Eyes of Azura
    [38643] = true, -- Q4854-ALFire
    [38337] = true, -- Q4854 Best Guide
    [38341] = true, -- Q4854 Az Tracker
    [38342] = true, -- Q4854 Az Tracker B
    [37006] = true, -- CFX_Q4854
    [40511] = true, -- Q4854 Weakened
    [37205] = true, -- Animus Geode
    [37677] = true, -- Geodesic Corruption
    [37211] = true, -- Q4854 Empower Heart
    [37222] = true, -- Q4854 S5
    [37224] = true, -- Q4854 Lower Barrier
    [37228] = true, -- Q4854 Parent Vis
    [37000] = true, -- CFX_Q4854 Vastarie FX
    [37268] = true, -- Q4854 Vastarie Stun
    [37270] = true, -- Q4854
    [37264] = true, -- CFX_Q4854
    [37265] = true, -- Vastarie Port
    [37386] = true, -- Vas out
    [37314] = true, -- Q4854 Channel Stun
    [61461] = true, -- Q4854 Channel Stun PERM
    [38246] = true, -- Animus Geode
    [37082] = true, -- Q4854 to Coldharbour
    [37085] = true, -- Q4854 from Coldharbour
    [37585] = true, -- Q4854 Culanwe Fire B
    [37441] = true, -- Q4854 Vastarie
    [57967] = true, -- Coldharbour Spawn In
    [57982] = true, -- Coldharbour Despawn

    -- Pact Advocate
    [37486] = true, -- Q4851 Strangler Kill

    -- Carnival Conundrum
    [44879] = true, -- CV Delay 1.5 Seconds
    [42022] = true, -- 1 Hour Timer

    -- The Wounded Wood
    [44688] = true, -- Pour Blessed Water

    -- Enemies at the Gate
    [37670] = true, -- Q4395-ShamanWaitSequence
    [37674] = true, -- Q4395-ShamanWait
    [37676] = true, -- Q4395-ShamanWait
    [37679] = true, -- Q4395-ShamanWait
    [37682] = true, -- Q4395-ShamanWait

    -- A Chief Concern
    [38185] = true, -- CON_Jump Off Tower

    -- Blood Hunt
    [61191] = true, -- Q4915 - CV Appearance Tracker

    -- Flipping the Coin
    [39309] = true, -- Q4983 Stone Cats
    [41327] = true, -- Q4893 Statue Move
    [39229] = true, -- Strike
    [39231] = true, -- Q4893 Delay Spawn

    --------------------
    -- Grahtwood
    --------------------

    -- World Boss - Gathongor's Mine
    [84205] = true, -- Stinging Sputum
    [84207] = true, -- Stinging Sputum
    [84206] = true, -- Stinging Sputum
    [84196] = true, -- Marsh Masher
    [84198] = true, -- Marsh Masher
    [84199] = true, -- Marsh Masher
    [84200] = true, -- Marsh Masher
    [84202] = true, -- Marsh Masher
    [84204] = true, -- Marsh Masher
    [84201] = true, -- Marsh Masher
    [84203] = true, -- Marsh Masher
    [84197] = true, -- Marsh Masher
    [84208] = true, -- Savage Swipe
    [84209] = true, -- Wrecking Jaws
    [84211] = true, -- Wrecking Jaws
    [84210] = true, -- Wrecking Jaws
    [84137] = true, -- Swamp Minions
    [84140] = true, -- Find Anchor 1
    [84141] = true, -- Find Anchor 2
    [84138] = true, -- Minion of Stone
    [84139] = true, -- Minion of Stone
    [84212] = true, -- Bog Slam
    [84214] = true, -- Bog Slam
    [84213] = true, -- Bog Slam

    -- World Boss - Rootwater Spring
    [47084] = true, -- Rootwater Healing Spring
    [47086] = true, -- Rootwater Life Spring
    [47109] = true, -- Rootwater Heal

    -- World Boss - Thodundor's View
    [83164] = true, -- Clobber
    [83165] = true, -- Sweeping Backhand
    [83124] = true, -- Ferocious Bellow
    [83155] = true, -- Thunderous Smash
    [83156] = true, -- Thunderous Smash
    [83159] = true, -- Thunderous Smash
    [83157] = true, -- Thunderous Smash
    [83160] = true, -- Stone Crusher
    [83163] = true, -- Stone Crusher
    [83162] = true, -- Stone Crusher
    [83161] = true, -- Stone Crusher
    [83136] = true, -- Ground Shock
    [83138] = true, -- Ground Shock
    [83142] = true, -- Ground Shock
    [83143] = true, -- Ground Shock
    [83500] = true, -- Ground Shock
    [83499] = true, -- Ground Shock
    [83140] = true, -- Ground Shock
    [83141] = true, -- Ground Shock
    [83137] = true, -- Ground Shock
    [83777] = true, -- Iron Grip
    [83780] = true, -- Iron Grip

    -- Public Dungeon - Rulanyil's Fall
    [27607] = true, -- Q4462 Necro Channel
    [60485] = true, -- Arrow Burst
    [33581] = true, -- DUN-RF_Event_Blue_Fire

    -- Frighten the Fearsome
    [28498] = true, -- Speedier Walk
    [49927] = true, -- Magic Transformation

    -- Audience with the Wilderking
    [37759] = true, -- Spirit Armor
    [30822] = true, -- Q4593_FakeSeeBoss
    [31095] = true, -- Q4593_FakeHazaziConvoCheck
    [30858] = true, -- Q4593_PastSceneFX
    [30880] = true, -- Q4593_CanSeeVisions

    -- The Witch of Silatar
    [33289] = true, -- Q4586 Blue Fireplace FX
    [44555] = true, -- Q4586 Fire Story Teleport
    [33384] = true, -- Q4586 Aranias Vine Stun
    [46925] = true, -- Q4586 TP to Scene 1
    [33066] = true, -- Q4586_ChangeClothes
    [34842] = true, -- Q4586_ChangeClothesFEMALE
    [33069] = true, -- Q4586_Ara02_TreeSpell
    [33456] = true, -- Q4586_HugeTree
    [49116] = true, -- Q4586_HugeTree
    [49117] = true, -- Q4586_HugeTree
    [46929] = true, -- Q485 TP out of Silatar

    -- Throne of the Wilderking
    [35014] = true, -- Wilderking's Protection
    [49878] = true, -- SW Invisible Man
    [34411] = true, -- Q4750 Screen Shake
    [49823] = true, -- Q4750 BurrowFX
    [33701] = true, -- BurrowEND
    [33829] = true, -- Burrowing
    [37506] = true, -- Stealth
    [33727] = true, -- BurrowEND
    [33830] = true, -- Wilder Bamf
    [34416] = true, -- Q4750_WhiteFlash

    -- Veil of Illusion
    [31569] = true, -- Guise of the Queen
    [31544] = true, -- Guise of the Queen
    [31564] = true, -- Guise of the Queen
    [31679] = true, -- Blinded

    -- A Storm Upon the Shore
    [34430] = true, -- Invisibility Potion
    [24680] = true, -- Hidden Buff 4min

    -- Pelidil's End
    [34630] = true, -- Q4765 Sail After Peledil
    [34631] = true, -- Teleport
    [37387] = true, -- GS Seaside
    [33573] = true, -- GS Seaside
    [33579] = true, -- GS Seaside
    [34380] = true, -- GS SS Telegraph AoE
    [50784] = true, -- Magefire
    [39330] = true, -- GS Seaside Mage Launch
    [33577] = true, -- Maormer Fire
    [50719] = true, -- Q4765 Maormer Climb Into Boat
    [51298] = true, -- Q4765 Initial Serpent Appear
    [50764] = true, -- Q4762 Snake Spit AoE
    [50766] = true, -- CON_AOE_Template1
    [50767] = true, -- CON_AOE_Template1
    [50765] = true, -- CON_AOE_Template1
    [37393] = true, -- GS Seaside Catapult Animate
    [33545] = true, -- GS Seaside Catapult Shot
    [48049] = true, -- Q4765 Block Dummy Fire
    [48054] = true, -- Q4765 Impact Increment
    [33610] = true, -- GS SS Serpent Hit Descend
    [33828] = true, -- GS SS Serpent Track Hit
    [33609] = true, -- GS SS Serpent Rise
    [32396] = true, -- SM Mudcrab Fighter
    [33650] = true, -- GS SS Serpent Ready Ram
    [42042] = true, -- GS SS Serpent DIE
    [51303] = true, -- Q4765 Maomer TP In
    [42068] = true, -- CFX_4765 Mage Hold Open Portal
    [35697] = true, -- Serpent Chomp (Maormer Serpent)

    -- Retaking the Pass
    [31645] = true, -- Q4546 05 Skull Talk
    [30766] = true, -- Q4545 05 Release
    [31646] = true, -- Q4546 05
    [31676] = true, -- CV Delay 2 Seconds
    [31677] = true, -- CV Delay 2 Seconds
    [31678] = true, -- CV Delay 2 Seconds
    [29642] = true, -- Q4546 06 Rift Storm
    [18411] = true, -- Q3959 Starting Casting
    [29640] = true, -- Dark Beam
    [30800] = true, -- Light Beam
    [45650] = true, -- Indaenir's Spell
    [29504] = true, -- Q4546 Shade Layer
    [29505] = true, -- Q4546 Naemon Shade
    [47427] = true, -- Q4546 Shade Death Delay

    -- The Blight of the Bosmer
    [34499] = true, -- Corruption Beam
    [47425] = true, -- Q4608 Shade Death Delay

    -- Right of Theft
    [34344] = true, -- Q4601 Ghost Despawn
    [34345] = true, -- Q4601 GS PC Can Spawn
    [34346] = true, -- Ancient Wrath
    [34824] = true, -- Ancient Wrath
    [47430] = true, -- Q4601 Shade Death Delay
    [7246] = true,  -- CV Delay 1 Seconds
    [30002] = true, -- CV Ghost Flash

    -- Striking at the Heart
    [35496] = true, -- Q4690 Shade Layer
    [34597] = true, -- Q4690 Forest Spirit Layer
    [35619] = true, -- Q4690 CV VH Barrier (Perm)
    [35556] = true, -- Q4690
    [35529] = true, -- Shield
    [35611] = true, -- Q4690 CV VH Barrier (Timed)
    [34435] = true, -- Q4690

    [48491] = true, -- Q4960 Naemon Shield Shade
    [48537] = true, -- Q3868 Restore Player
    [48490] = true, -- Q4960 Boss Shade World
    [48498] = true, -- Q4960 Necor Skele Rise
    [34455] = true, -- Purify
    [34493] = true, -- Q4690
    [48486] = true, -- Q4960 Inda Revived

    --------------------------------------
    -- QUEST / ZONES - DAGGERFALL COVENANT --
    --------------------------------------

    --------------------
    -- Stros M'Kai
    --------------------

    -- Misc World Events
    [9694] = true, -- EB Generic 5 Min Counter 04
    [9695] = true, -- EB Generic 5 Min Counter 05

    -- Main Quest - Innocent Scoundrel
    [28098] = true, -- Despawn Self 3 Sec Delay
    [28099] = true, -- Despawn Self
    [27525] = true, -- Backstab
    [27633] = true, -- Q4454 SpawnFlavor GobboFighter

    -- Main Quest - Buried Secrets
    [28410] = true, -- Q4431 HackedSpiderFX (Neramo's Spider)
    [26535] = true, -- Control Rod (Neramo's Spider)

    -- Main Quest - Like Moths to a Candle
    [26887] = true, -- GenericCombatTheaterSnare 100 (Howler)
    [27755] = true, -- Sea Drake Disguise (Crafty Lerisa)
    [26892] = true, -- Donning Uniform... (Crafty Lerisa)
    [26895] = true, -- Sea Drake Uniform (Crafty Lerisa)
    -- [26925] = true, -- Freeing Prisoner... (Player)
    [28245] = true, -- Donning Uniform... (Mekag gro-Bug)
    [28246] = true, -- Sea Drake Uniform (Mekag gro-Bug)
    [28243] = true, -- Donning Uniform... (Haerdon)
    [28244] = true, -- Sea Drake Uniform (Haerdon)
    [28241] = true, -- Donning Uniform... (Crenard Dortene)
    [28242] = true, -- Sea Drake Uniform (Crenard Dortene)
    [26913] = true, -- Cabin Girl Disguise (Crafty Lerisa)
    [79985] = true, -- Mercy Kill (Player)
    [79989] = true, -- Mercy Kill (Player)

    -- Main Quest - The Spearhead's Crew
    [46482] = true, -- GMR Q4476 Gate NPC CV Post Que (Player)

    -- Main Quest - Tip of the Spearhead
    [27649] = true, -- Servant Disguise (Crafty Lerisa)
    [31209] = true, -- Q4476EntertainerLine01_01 (Player)
    [31210] = true, -- Q4476EntertainerLine01_02 (Player)
    [31207] = true, -- Q4476EntertainerLine02_01 (Player)
    [31208] = true, -- Q4476EntertainerLine02_02 (Player)
    [27702] = true, -- Charging Rod (Player)
    [31012] = true, -- Q4476 Knockdown (Player)
    [30770] = true, -- Q4476 SailToBet01 (Player)
    [30771] = true, -- Q4476 SailToBet02 (Player)

    -- Side Quest - Sphere Assembly
    [43976] = true, -- Q4381-SphereStartReplacement

    -- Side Quest - Izad's Treasure
    [27268] = true, -- Unearthed Chest

    -- Side Quest - Moment of Truth
    [26198] = true, -- Q4382 Dugroth W Sword
    [32263] = true, -- Q4382 SeeBaitCV

    -- Side Quest - Washed Ashore
    [45950] = true, -- Dirt Clods

    -- Side Quest - Last Night
    [26001] = true, -- Q4380 02
    [26002] = true, -- Q4380 05 Trelan Meets
    [26003] = true, -- Q4380 05 Trelan Meets
    [26004] = true, -- Q4380 05 Trelan Meets
    [29488] = true, -- Q4380 02
    [29487] = true, -- Q4380 02
    [29495] = true, -- Q4380 02
    [29497] = true, -- Q4380 02
    [29498] = true, -- Q4380 02
    [29499] = true, -- Q4380 02
    [29500] = true, -- Q4380 02
    [29496] = true, -- Q4380 02
    [46191] = true, -- Q4380 02

    --------------------
    -- Betnikh
    --------------------

    [26948] = true, -- Bloodthorn Uniform (Crafty Lerisa)
    [26939] = true, -- Q4468 EnergyMoteFX (Energy Mote)
    [25313] = true, -- Generic (Player)
    [44189] = true, -- RobS Stun 2.25 Sec (Abomination of Wrath/Fear/Hate)
    [44288] = true, -- Generic UFX Give (Abomination of Wrath/Fear/Hate)
    [26944] = true, -- Q4468 Staff of Arkay Flavor (Abomination of Wrath/Fear/Hate)
    [28358] = true, -- Q4468 Orc Raider Diguise (PlayeR)
    [31379] = true, -- Q4468 NureseExecution (Player)
    [31381] = true, -- Q4468 NureseExecution (Player)
    [31382] = true, -- Q4468 NureseExecution (Player)
    [31380] = true, -- Q4468SeeNureseGhost (Player)
    [31439] = true, -- Q4468 NureseExecution (Player)

    [31365] = true, -- Q4468 DragoExecution (Player)
    [31370] = true, -- Q4468 DragoExecution (Player)
    [31369] = true, -- Q4468 DragoExecution (Player)
    [31372] = true, -- Q4468SeeDragoGhost (Player)
    [31440] = true, -- Q4468 DragoExecution (Player)

    [31391] = true, -- Q4468 FredExecution (Player)
    [31393] = true, -- Q4468 NureseExecution (Player)
    [31394] = true, -- Q4468 NureseExecution (Player)
    [31392] = true, -- Q4468SeeNureseGhost (Player)

    [31402] = true, -- Q4468 VisanneExecution (Player)
    [31404] = true, -- Q4468 VisanneExecution (Player)
    [31405] = true, -- Q4468 VisanneExecution (Player)
    [31403] = true, -- Q4468SeeVisanneGhost (Player)

    [31427] = true, -- Q4468 AskedWrongQuestion01 (Player)
    [31428] = true, -- Q4468 AskedWrongQuestion01 (Player)

    [28489] = true, -- Q4468 RenwicHoldArtifact (King Renwic)
    [28487] = true, -- Q4468 RenwicCast (King Renwic)
    [28488] = true, -- Q4468 RenwicCastPop (King Renwic)

    -------------------------------------
    -- VVARDENFELL QUESTS/EVENTS --------
    -------------------------------------

    -- Tutorial
    [89095] = true,  -- Slaver Clothes
    [89096] = true,  -- Slaver Clothes
    [92087] = true,  -- Slaver Clothes
    [92088] = true,  -- Slaver Clothes
    [92089] = true,  -- Slaver Clothes
    [92090] = true,  -- Slaver Clothes
    [92091] = true,  -- Slaver Clothes
    [92092] = true,  -- Slaver Clothes
    [92093] = true,  -- Slaver Clothes
    [92094] = true,  -- Slaver Clothes
    [92095] = true,  -- Slaver Clothes
    [92096] = true,  -- Slaver Clothes
    [92097] = true,  -- Slaver Clothes
    [92098] = true,  -- Slaver Clothes
    [92099] = true,  -- Slaver Clothes
    [92100] = true,  -- Slaver Clothes
    [92101] = true,  -- Slaver Clothes
    [92102] = true,  -- Slaver Clothes
    [92103] = true,  -- Slaver Clothes
    [92104] = true,  -- Slaver Clothes
    [92105] = true,  -- Slaver Clothes
    [92106] = true,  -- Slaver Clothes
    [92107] = true,  -- Slaver Clothes
    [92108] = true,  -- Slaver Clothes
    [88444] = true,  -- Sit
    [93489] = true,  -- Sit
    [92743] = true,  -- Waking
    [47704] = true,  -- Q4885 No Damage Follower
    [88453] = true,  -- Bound
    [90591] = true,  -- Manacled
    [74501] = true,  -- Generic Stun 6s No Anim
    [94362] = true,  -- Q5804 Player Hit Reaction
    [92245] = true,  -- MQ1 Input Lock LAtk
    [92243] = true,  -- MQ1 Input Lock LAtk
    [92248] = true,  -- Q5804 Input Lock Visual
    [83416] = true,  -- Heavy Attack
    [93577] = true,  -- MQ1 Tutorial Block Heavy
    [92262] = true,  -- Off-Balance Timer
    [92265] = true,  -- Off-Balance
    [92263] = true,  -- Perma Set Off Balance Target
    [92266] = true,  -- MQ1 Tutorial Perma Off-Balance
    [92233] = true,  -- Throw Dagger
    [92238] = true,  -- MQ1 Heat Wave (Tutorial)
    [62546] = true,  -- MQ1 Lockpick Grant
    [92668] = true,  -- Whirlwind (Slaver Cutthroat)
    [92669] = true,  -- Whirlwind (Slaver Cutthroat)
    [93604] = true,  -- Q5804 Input Lock Visual
    [88904] = true,  -- Metal Trap
    [88905] = true,  -- Metal Trap
    [22337] = true,  -- Generic Fade to Black 2s
    [92002] = true,  -- Waking
    [106162] = true, -- Not CC Immune

    -- Divine Conundrum (Main Quest)
    [91600] = true, -- Disintegration
    [91604] = true, -- Carapace
    [91603] = true, -- Disintegration
    [91005] = true, -- Q5803 Divination Beam

    -- Divine Inquiries (Main Quest)
    [85264] = true, -- Sacrifice
    [85265] = true, -- Sacrifice
    [85266] = true, -- Sacrifice

    -- A Web of Trouble (Sidequest)
    [91347] = true, -- Readying Signal
    [89266] = true, -- Summon Spider
    [89269] = true, -- Summon Spider
    [89276] = true, -- Summon Exploder
    [89278] = true, -- Summon Exploder
    [89277] = true, -- Summon Exploder
    [89268] = true, -- Summon Spider
    [89272] = true, -- Spider Explosion
    [89282] = true, -- Spider Explosion
    [89274] = true, -- Spider Explosion

    -- Like Blood from a Stone (Sidequest)
    [86649] = true, -- Accelerated Transposition
    [86743] = true, -- Accelerated Transposition
    [86646] = true, -- Accelerated Transposition
    [90511] = true, -- Accelerated Transposition

    -- The Memory Stone (Sidequest)
    [87342] = true, -- Vision of a Memory
    [87359] = true, -- Memory Projection

    -- Fleeing the Past (SQ)
    [92580] = true, -- Q5887 - AshurStealthOut
    [93993] = true, -- Assassinate
    [94461] = true, -- Jump
    [93994] = true, -- Whirlwind
    [93995] = true, -- Whirlwind
    [92585] = true, -- Drink Potion

    -- Family Reunion (IDK if MQ or SQ)
    [86979] = true, -- Summon Skaafin
    [86980] = true, -- Summon Skaafin
    [86981] = true, -- Summon Skaafin

    -- A Melodic Mistake (SQ)
    [85450] = true, -- Q5872 - Dwemer Sound - Far
    [89255] = true, -- Q5872 - Dwemer Sound - Mid
    [86862] = true, -- Powered Up
    [86865] = true, -- Powered Up
    [86608] = true, -- Q5872 - Dwarven Barrier
    [86633] = true, -- Barrier Break
    [89256] = true, -- Q5872 - Dwemer Sound - Near
    [86709] = true, -- Q5872 - Puzzle Solved
    [86714] = true, -- Q5872 - Gnisis Teleport Succes

    -- Hatching a Plan (SQ)
    [91411] = true, -- Q5883- CliffStriderSpawn
    [95519] = true, -- Generic Stun 3s No Anim

    -- Breaking Through the Fog
    [94842] = true, -- Dousing...

    -- Haunted Grounds (SQ)
    [93411] = true, -- Q5863 - MasterBossDies Farwen
    [93412] = true, -- Q5863 - MasterBossDies Farwen

    -- Reclaiming Vos (SQ)
    [87812] = true, -- Stealth Shader
    [85105] = true, -- Unstable Reaction
    [85537] = true, -- Summon Personal Guard

    -- Ancestral Adversity (SQ)
    [86197] = true, -- Q5882 harp Notes
    [89734] = true, -- Wall Dissolve
    [88403] = true, -- Flame Jet
    [88491] = true, -- Searing Flame
    [88411] = true, -- Hammer
    [88413] = true, -- Hammer
    [88405] = true, -- Hammer
    [88406] = true, -- Hammer
    [89663] = true, -- Hammer
    [89664] = true, -- Hammer
    [88404] = true, -- Blade
    [88454] = true, -- Blade
    [88455] = true, -- Blade
    [88510] = true, -- Staggered
    [92720] = true, -- Necrotic Wave
    [92722] = true, -- Stomp of Flame
    [92723] = true, -- Fire Backlash
    [92721] = true, -- CON_Knockback&Knockdown

    -- DELVE (Khartag Point)
    [89753] = true, -- Shocking Touch -- Old Rust-Eye
    [89754] = true, -- Shocking Touch -- Old Rust-Eye

    -- At Any Cost (SQ)
    [85651] = true, -- Flare -- Scamp
    [91773] = true, -- Dark Rejuvenation -- Xykenaz
    [91774] = true, -- Dark Rejuvenation FX -- Xykenaz

    -- Matus-Akin Egg Mine (Delve)
    [88415] = true, -- Awaken the Colony
    [88416] = true, -- Awaken the Colony
    [88438] = true, -- Summon Skaafin
    [88417] = true, -- Awaken the Colony
    [88439] = true, -- Summon Skaafin

    [88419] = true, -- Charge
    [88422] = true, -- Charge
    [88427] = true, -- Charge
    [88431] = true, -- Charge
    [88428] = true, -- Charge
    [88435] = true, -- Charge
    [88437] = true, -- Charge
    [88432] = true, -- Charge
    [88426] = true, -- Charge
    [88433] = true, -- Charge
    [88430] = true, -- Charge
    [88425] = true, -- Shattered Ground

    -- A Hireling of House Telvanni (SQ)
    [87351] = true, -- Water Geyser Warning
    [87348] = true, -- Water Geyser Burst
    [87349] = true, -- Water Geyser Burst
    [87350] = true, -- Water Geyser Burst

    -- The Magister Makes a Move (SQ)
    [89246] = true, -- Q5914 Nelos Notices
    [89247] = true, -- Q4636 Delayed Teleport Ext 01
    [89756] = true, -- Guardian Shockwave
    [89757] = true, -- Guardian Shockwave
    [84273] = true, -- Sweeping Spin
    [90808] = true, -- TV 4 CV Delay

    -- The Heart of a Telvanni (SQ)
    [87738] = true, -- Powder Bomb
    [89564] = true, -- Knockout
    [93289] = true, -- Q5922 Stun Capt
    [88244] = true, -- The Slavemaster's Chains
    [43148] = true, -- CV Delay 10 Minutes

    -- Divine Delusions
    [86972] = true, -- Q5888 Chodala Magic Shield Fx
    [90630] = true, -- Frenzy
    [87958] = true, -- Ash Storm
    [87960] = true, -- Ash Storm
    [87959] = true, -- Ash Storm

    -- An Armiger's Duty (SQ)
    [89481] = true, -- Flame Jet
    [93583] = true, -- Taunt
    [90073] = true, -- Blinding Light
    [96174] = true, -- Q5877 - Q.Item Cooldown

    -- Divine Intervention (MQ)
    [86353] = true, -- Mechanical Possession
    [86417] = true, -- Inactive Centurion
    [86349] = true, -- Mechanical Possession
    [86355] = true, -- Mechanical Possession
    [92149] = true, -- VQ4 Fire Trap DoT
    [92150] = true, -- Fire Trap

    [91006] = true, -- Chodala's Shield
    [91669] = true, -- x
    [89909] = true, -- Tonal Inverter Ready
    [89910] = true, -- Tonal Inverter Ready
    [89911] = true, -- Tonal Inverter Ready
    [90080] = true, -- Tonal Inverter Ready
    [90952] = true, -- Tonal Inverter
    [90955] = true, -- Tonal Inverter
    [89901] = true, -- Tonal Inverter
    [91715] = true, -- Seryn's Connection
    [89904] = true, -- Tonal Inverter
    [89903] = true, -- Tonal Inverter

    [86815] = true, -- Daedric Bolt
    [90140] = true, -- Sunder's Echo
    [90149] = true, -- Sunder's Echo
    [90145] = true, -- Sunder's Echo
    [90143] = true, -- Sunder's Echo
    [90144] = true, -- Sunder's Echo
    [90148] = true, -- Sunder's Echo
    [90150] = true, -- Sunder's Echo
    [90146] = true, -- Sunder's Echo
    [90147] = true, -- Sunder's Echo

    [90139] = true, -- Empowered Strike
    [90141] = true, -- Empowered Strike
    [90142] = true, -- Empowered Strike

    [92304] = true, -- Q5893 Screen Flash White
    [88963] = true, -- Delay
    [90046] = true, -- Generic Stun + Headgrab 12s

    -- Divine Disaster (MQ)
    [92966] = true, -- Q5902_Screen Shake on Target
    [88465] = true, -- Skyfall
    [88466] = true, -- Skyfall
    [88467] = true, -- Skyfall
    [92536] = true, -- Vulnerability to Meteors

    -- Divine Restoration (MQ)
    [87101] = true, -- Blade Trap
    [87104] = true, -- Stun
    [87102] = true, -- Spinning Blade
    [87261] = true, -- Blade Vulnerability
    [91970] = true, -- Serrated Blade
    [91969] = true, -- Serrated Blade
    [89749] = true, -- Pulse
    [89750] = true, -- Pulse
    [89330] = true, -- Defensive Flare
    [92213] = true, -- Sparks
    [92228] = true, -- Pulse
    [92229] = true, -- Pulse
    [92227] = true, -- Pulse
    [92223] = true, -- Repair
    [92224] = true, -- Repair
    [92225] = true, -- Repair
    [89761] = true, -- Fabricate Beetle

    [90528] = true, -- Loyal Hound
    [87038] = true, -- Spinning Blades
    [87040] = true, -- Pinning Blades
    [87039] = true, -- Pinning Blades

    [87047] = true, -- Lunge
    [87053] = true, -- Lunge
    [87051] = true, -- Lunge
    [87048] = true, -- Lunge
    [87050] = true, -- Lunge
    [87049] = true, -- Lunge

    [87090] = true, -- Barbs
    [87096] = true, -- Barbs

    [90599] = true, -- Daedric Vigor
    [90501] = true, -- Tap the Divine
    [90525] = true, -- Phase Transition
    [90533] = true, -- Loyal Hound 1
    [90504] = true, -- VV-VQ5 Phase Transition
    [90502] = true, -- VV-VQ5 Phase Transition
    [92283] = true, -- Planar Shear
    [92284] = true, -- Planar Shear
    [90627] = true, -- targetable

    [90534] = true, -- Loyal Hound
    [90536] = true, -- Loyal Hound
    [90535] = true, -- Loyal Hound

    [90566] = true, -- Loyal Hound
    [90567] = true, -- Loyal Hound
    [90568] = true, -- Loyal Hound
    [90569] = true, -- Loyal Hound

    [87503] = true, -- Divine Hijack
    [90616] = true, -- Divine Hijack
    [87523] = true, -- Divine Hijack
    [87504] = true, -- Divine Hijack
    [87505] = true, -- Divine Hijack
    [90617] = true, -- Divine Hijack
    [87525] = true, -- Divine Hijack
    [87522] = true, -- Divine Hijack
    [90514] = true, -- Phase Transition

    [90524] = true, -- Divine Hijack
    [92411] = true, -- Contrived Portal
    [92412] = true, -- Contrived Portal
    [92413] = true, -- Contrived Portal

    -- Divine Blessings (MQ)
    [90572] = true, -- Q6003 - NP Ending Theater CV

    -- PUBLIC DUNGEON (The Forgotten Wastes)
    [88029] = true, -- Volcanic Activity (Deadfall)
    [91659] = true, -- Falling Rocks (Deadfall)
    [88030] = true, -- Falling Rocks (Deadfall)

    [92670] = true, -- Pyroclast (Meteor)
    [92671] = true, -- Pyroclast (Meteor)
    [92672] = true, -- Pyroclast (Meteor)

    [86930] = true, -- Volcanic Debris
    [86935] = true, -- Volcanic Debris
    [86932] = true, -- Volcanic Debris
    [90500] = true, -- Volcanic Debris
    [86934] = true, -- Volcanic Debris
    [86939] = true, -- Volcanic Debris
    [86938] = true, -- Volcanic Debris

    [92702] = true, -- Volcanic Debris
    [92705] = true, -- Volcanic Debris
    [92709] = true, -- Volcanic Debris
    [92703] = true, -- Volcanic Debris
    [92707] = true, -- Volcanic Debris
    [92706] = true, -- Volcanic Debris
    [92704] = true, -- Volcanic Debris

    [86983] = true, -- Succubus Touch
    [86984] = true, -- Succubus Touch
    [86989] = true, -- Succubus Touch

    -- PUBLIC DUNGEON (Nchuleftingth)
    [84510] = true, -- Searing Steam
    [84537] = true, -- Searing Steam
    [84527] = true, -- Searing Steam

    [90268] = true, -- Charge Whire Shock
    [90271] = true, -- Charge-Wire Shock
    [90269] = true, -- Charge-Wire Shock

    [90220] = true, -- Immune to Electricity

    [86634] = true, -- Swinging Cleave -- Mud-Tusk
    [86635] = true, -- Swinging Cleave -- Mud-Tusk
    [89210] = true, -- Boulder Toss -- Mud-Tusk
    [89234] = true, -- Turn -- Mud-Tusk
    [89240] = true, -- Boulder Toss -- Mud-Tusk
    [89239] = true, -- Boulder Toss -- Mud-Tusk
    [94935] = true, -- Tremor -- Mud-Tusk
    [94937] = true, -- Tremor -- Mud-Tusk
    [94936] = true, -- Tremor -- Mud-Tusk

    [86610] = true, -- Piston Thrust
    [86613] = true, -- Piston Thrust
    [86623] = true, -- Piston Thrust
    [86624] = true, -- Piston Thrust

    [90856] = true, -- Steam Piston
    [90860] = true, -- Spike Trap
    [90859] = true, -- Swinging Blades
    [90857] = true, -- Swinging Blades

    [86591] = true, -- Piston Thrust -- Guardian of Bthark
    [86592] = true, -- Piston Thrust -- Guardian of Bthark
    [86596] = true, -- Piston Thrust -- Guardian of Bthark
    [86595] = true, -- Piston Thrust -- Guardian of Bthark

    [69283] = true, -- Whirlwind Function -- Guardian of Bthark
    [69285] = true, -- Whirlwind Function -- Guardian of Bthark
    [69284] = true, -- Whirlwind Function -- Guardian of Bthark
    [69286] = true, -- Whirlwind Function -- Guardian of Bthark

    [86606] = true, -- Steam Breath -- Guardian of Bthark
    [86607] = true, -- Steam Breath -- Guardian of Bthark

    [90192] = true, -- Overcharge
    [90212] = true, -- Overcharge
    [90214] = true, -- Overcharge
    [90217] = true, -- Overcharge
    [90216] = true, -- Overcharge
    [90215] = true, -- Overcharge

    [71919] = true, -- Turret Occupied
    [71920] = true, -- Turret Mode

    [86567] = true, -- Fire Runes
    [86568] = true, -- Fire Runes
    [86569] = true, -- Fire Runes
    [86566] = true, -- Fire Runes
    [86570] = true, -- Shield Charge
    [86574] = true, -- Shield Charge
    [86575] = true, -- Shield Charge
    [86576] = true, -- Staggered

    -- [73095] = true, -- In Lava
    -- [73103] = true, -- Lava

    [51634] = true, -- Shocking Touch
    [86659] = true, -- Auditory Signal
    [86680] = true, -- Auditory Signal
    [86691] = true, -- Overcharge
    [86690] = true, -- Overcharge
    [86688] = true, -- Overcharge
    [86689] = true, -- Overcharge

    [92135] = true, -- Nchuleftingth Electricity
    [92136] = true, -- Laser Snare
    [92138] = true, -- Laser Damage

    [89998] = true, -- Auditory Command
    [90004] = true, -- Auditory Command
    [90005] = true, -- Auditory Command
    [90006] = true, -- Auditory Command
    [90007] = true, -- Auditory Command
    [90008] = true, -- Auditory Command
    [90009] = true, -- Auditory Command
    [90010] = true, -- Auditory Command

    [84332] = true, -- Demolish
    [84333] = true, -- Demolish
    [84334] = true, -- Demolish
    [84336] = true, -- Demolish
    [89917] = true, -- Boss
    [89918] = true, -- Boss
    [90783] = true, -- Indominable
    [90788] = true, -- Indominable
    [84738] = true, -- Indominable
    [84739] = true, -- Indominable
    [84755] = true, -- Indominable
    [91407] = true, -- Indominable
    [90821] = true, -- Enable
    [90862] = true, -- Indominable
    [90863] = true, -- Indominable
    [90867] = true, -- Indominable
    [91485] = true, -- Indominable
    [90869] = true, -- Indominable
    [90870] = true, -- Indominable
    [90874] = true, -- Indominable
    [91486] = true, -- Indominable

    [84554] = true, -- Momentum
    -- [84638] = true, -- Momentum
    [84606] = true, -- Momentum
    [84616] = true, -- Momentum

    [90597] = true, -- Overcharge Explusion
    [90598] = true, -- Overcharge Explusion

    -------------------------------------
    -- SUMMERSET QUESTS/EVENTS ----------
    -------------------------------------

    -- Tutorial - The Mind Trap
    [107581] = true, -- Mind Haze
    [107747] = true, -- Mind Trap
    [100672] = true, -- MQ1 Input Lock Visual
    [100678] = true, -- Major Protection
    [100671] = true, -- Heavy Attack
    [100683] = true, -- Block Me
    [100677] = true, -- Block Me
    [100686] = true, -- Off-Balance
    [100694] = true, -- Off-Balance
    [100687] = true, -- Off-Balance
    [100690] = true, -- Off-Balance
    [100722] = true, -- Heat Wave
    [100733] = true, -- Heat Wave

    [108553] = true, -- Generic ANY Stun 4s
    [106862] = true, -- SU Tutorial Touch PearlFail

    [105498] = true, -- Flog (Yaghra Larva)
    [105540] = true, -- Body Bash (Yaghra Larva)
    [105561] = true, -- Momentous Discharge (Yaghra Larva)
    [105563] = true, -- Momentous Discharge (Yaghra Larva)
    [105562] = true, -- Momentous Discharge (Yaghra Larva)
    [105601] = true, -- Explosive Toxins (Yaghra Larva)
    [108773] = true, -- Explosive Toxins (Yaghra Larva)
    [105605] = true, -- Explosive Toxins (Yaghra Larva)
    [105604] = true, -- Explosive Toxins (Yaghra Larva)

    [105737] = true, -- Stab (Yaghra Nightmare)
    [105739] = true, -- Stab (Yaghra Nightmare)
    [107282] = true, -- Impale (Yaghra Nightmare)
    [107284] = true, -- Impale (Yaghra Nightmare)
    [107299] = true, -- Impale (Yaghra Nightmare)

    [105867] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105876] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105874] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105877] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105878] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105879] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105880] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105881] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105873] = true, -- Pustulant Eruption (Yaghra Nightmare)

    [105889] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105912] = true, -- Pustulant Eruption (Yaghra Nightmare)
    [105893] = true, -- Pustulant Film (Yaghra Nightmare)

    -------------------------------------
    -- ELSWEYR QUESTS/EVENTS ------------
    -------------------------------------

    -- Main Quest - Tutorial - Bright Moons, Warm Sands
    [115184] = true, -- Regaining Consciousness
    [124493] = true, -- Sparring Stamina
    [116997] = true, -- MQ1 Input Lock Visual
    [120997] = true, -- Come at Me (Grand Adept Ma'hja-dro - Tutorial)
    [120999] = true, -- You Came At Me (Grand Adept Ma'hja-dro - Tutorial)
    [121000] = true, -- You Came At Me (Grand Adept Ma'hja-dro - Tutorial)
    [121005] = true, -- Heavy Attack (Grand Adept Ma'hja-dro - Tutorial)
    [121018] = true, -- Block Me (Grand Adept Ma'hja-dro - Tutorial)
    [121026] = true, -- Off-Balance (Grand Adept Ma'hja-dro - Tutorial)
    [121024] = true, -- Off-Balance (Grand Adept Ma'hja-dro - Tutorial)
    [126526] = true, -- Off-Balance (Grand Adept Ma'hja-dro - Tutorial)
    [126569] = true, -- Off-Balance Exploit (Grand Adept Ma'hja-dro - Tutorial)
    [126568] = true, -- Off-Balance Exploit (Grand Adept Ma'hja-dro - Tutorial)
    [126567] = true, -- Off-Balance Exploit (Grand Adept Ma'hja-dro - Tutorial)
    [121025] = true, -- Block Exploited (Grand Adept Ma'hja-dro - Tutorial)
    [121032] = true, -- Bash (Grand Adept Ma'hja-dro - Tutorial)
    [121035] = true, -- Staggered (Grand Adept Ma'hja-dro - Tutorial)
    [126501] = true, -- Bash (Grand Adept Ma'hja-dro - Tutorial)
    [121034] = true, -- Break Free ENd (Grand Adept Ma'hja-dro - Tutorial)
    [121036] = true, -- Heavy Strike (Grand Adept Ma'hja-dro - Tutorial)
    [121039] = true, -- Dagger Toss (Grand Adept Ma'hja-dro - Tutorial)
    [121042] = true, -- Off-Balance (Grand Adept Ma'hja-dro - Tutorial)
    [121040] = true, -- Off-Balance (Grand Adept Ma'hja-dro - Tutorial)
    [126573] = true, -- Off-Balance (Grand Adept Ma'hja-dro - Tutorial)
    [126572] = true, -- Off-Balance Exploit (Grand Adept Ma'hja-dro - Tutorial)
    [126571] = true, -- Off-Balance Exploit (Grand Adept Ma'hja-dro - Tutorial)
    [126570] = true, -- Off-Balance Exploit (Grand Adept Ma'hja-dro - Tutorial)
    [121041] = true, -- Block Exploited (Grand Adept Ma'hja-dro - Tutorial)
    [121183] = true, -- 420 (Grand Adept Ma'hja-dro - Tutorial)
    [121176] = true, -- 411 (Grand Adept Ma'hja-dro - Tutorial)

    [121475] = true, -- Devastating Leap (Bone Flayer)
    [121476] = true, -- Generic Stagger Enemy (Bone Flayer)
    [121473] = true, -- Flurry (Bone Flayer)
    [121474] = true, -- Flurry (Bone Flayer)

    [121456] = true, -- Necrotic Spear (Euraxian Necromancer)
    [121643] = true, -- Defiled Ground (Euraxian Necromancer)
    [121644] = true, -- Defiled Ground (Euraxian Necromancer)
    [121645] = true, -- Defiled Ground (Euraxian Necromancer)
    [121405] = true, -- Bone Surge II (Euraxian Necromancer)
    [121402] = true, -- Sum Necro Skeleton (Euraxian Necromancer)
    [121458] = true, -- Sum Necro Skeleton (Euraxian Necromancer)
    [114902] = true, -- Blastbones Leap (Blastbones)

    [119292] = true, -- Stun (Player - Star Haven Dragonhorn)

    [124281] = true, -- Set Area (Grand Adept Ma'hja-dro)
    [124286] = true, -- Set Area (Grand Adept Ma'hja-dro)
    [124304] = true, -- Set Area (Grand Adept Ma'hja-dro)
    [124283] = true, -- Roll Dodge (Grand Adept Ma'hja-dro)
    [124272] = true, -- Focused Healing (Grand Adept Ma'hja-dro)
    [124310] = true, -- Master's Shield (Grand Adept Ma'hja-dro)

    [121352] = true, -- Boss (Bahlokdaan)
    [121354] = true, -- Boss (Bahlokdaan)
    [121294] = true, -- Unrelenting Force (Bahlokdaan)
    [121349] = true, -- Unrelenting Force (Bahlokdaan)
    [124290] = true, -- Eat (Bahlokdaan)
    [124297] = true, -- Eat (Bahlokdaan)
    [121296] = true, -- Unrelenting Force (Bahlokdaan)
    [121350] = true, -- Unrelenting Force (Bahlokdaan)
    [121351] = true, -- Unrelenting Force (Bahlokdaan)
    [124337] = true, -- Unrelenting Force (Bahlokdaan)

    [124351] = true, -- Dragon Aura (Bahlokdaan)
    [124352] = true, -- Flame Aura (Bahlokdaan)
    [124312] = true, -- Burn, Fools! (Bahlokdaan)
    [125281] = true, -- Sweeping Breath (Bahlokdaan)
    [125286] = true, -- Sweeping Breath (Bahlokdaan)
    [125287] = true, -- Sweeping Breath (Bahlokdaan)
    [125285] = true, -- Sweeping Breath (Bahlokdaan)

    [125569] = true, -- Bite (Bahlokdaan)
    [122195] = true, -- Bite R (Bahlokdaan)
    [122196] = true, -- Bite L (Bahlokdaan)
    [122194] = true, -- Bite (Bahlokdaan)

    [125244] = true, -- Head Strike (Bahlokdaan)
    [125270] = true, -- Headbutt (Bahlokdaan)
    [125271] = true, -- Headbutt (Bahlokdaan)
    [125268] = true, -- Headbutt (Bahlokdaan)
    [125272] = true, -- Headbutt (Bahlokdaan)
    [125269] = true, -- Headbutt (Bahlokdaan)

    [125570] = true, -- Chomp (Bahlokdaan)
    [122200] = true, -- Chomp (Bahlokdaan)
    [122201] = true, -- Chomp (Bahlokdaan)
    [122199] = true, -- Chomp (Bahlokdaan)
    [117192] = true, -- Chomp (Bahlokdaan)

    [125241] = true, -- Tail Whip (Bahlokdaan)
    [125576] = true, -- Tail Swipe (Bahlokdaan)
    [125575] = true, -- Tail Swipe (Bahlokdaan)
    [125265] = true, -- Tail Whip (Bahlokdaan)
    [125266] = true, -- Tail Whip (Bahlokdaan)
    [125263] = true, -- Tail Whip (Bahlokdaan)
    [125267] = true, -- Tail Whip (Bahlokdaan)
    [125264] = true, -- Tail Whip (Bahlokdaan)

    [125242] = true, -- Wing Thrash (Bahlokdaan)
    [125278] = true, -- Wing Swipe (Bahlokdaan)
    [125277] = true, -- Wing Swipe (Bahlokdaan)
    [125247] = true, -- Wing Thrash (Bahlokdaan)
    [125250] = true, -- Wing Thrash (Bahlokdaan)
    [125245] = true, -- Wing Thrash (Bahlokdaan)
    [125249] = true, -- Wing Thrash (Bahlokdaan)
    [125246] = true, -- Wing Thrash (Bahlokdaan)

    [125243] = true, -- Wing Thrash (Bahlokdaan)
    [125275] = true, -- Wing Swipe (Bahlokdaan)
    [125274] = true, -- Wing Swipe (Bahlokdaan)
    [125255] = true, -- Wing Thrash (Bahlokdaan)
    [125256] = true, -- Wing Thrash (Bahlokdaan)
    [125253] = true, -- Wing Thrash (Bahlokdaan)
    [125257] = true, -- Wing Thrash (Bahlokdaan)
    [125254] = true, -- Wing Thrash (Bahlokdaan)

    [123812] = true, -- Summon Bahlokdaan (Bahlokdaan)
    [125607] = true, -- Receive Call (Bahlokdaan)
    [125606] = true, -- Receive Call (Bahlokdaan)
    [123118] = true, -- Takeoff (Bahlokdaan)
    [123119] = true, -- Takeoff (Bahlokdaan)
    [122675] = true, -- Ground Snare Exception (Bahlokdaan)

    -------------------------------------
    -- GREYMOOR QUESTS/EVENTS -----------
    -------------------------------------

    [136859] = true, -- Pushback (Player)

    [113260] = true, -- CVFHEAL CombatDet PASSIVE (Fennorian)
    [113263] = true, -- CVFHEAL CombatDet REG LeftCon (Fennorian)
    [113267] = true, -- CVFHEAL CombatDet IMM (Fennorian)
    [113283] = true, -- CVFHEAL CombatDet PASSIVE (Fennorian)
    [136492] = true, -- Snare (Fennorian)
    [136493] = true, -- Snare (Fennorian)
    [136494] = true, -- Snare (Fennorian)
    [113262] = true, -- CVFHEAL CombatDet NOB InCombat
    [113273] = true, -- CVFHEAL CombatDet STN Start
    [113275] = true, -- CVFHEAL CombatDet STN End
    [113261] = true, -- CVFHEAL CombatDet ROOT (Fennorian)
    [113281] = true, -- Damage (Fennorian)
    [113278] = true, -- Damage (Fennorian)
    [113269] = true, -- Heal (Fennorian)
    [113271] = true, -- Heal (Fennorian)

    [131863] = true, -- Uppercut (Vitrus the Bloody)
    [131865] = true, -- Uppercut (Vitrus the Bloody)
    [131864] = true, -- Uppercut (Vitrus the Bloody)
    [131861] = true, -- Throw Dagger (Vitrus the Bloody)
    [131862] = true, -- Stunned (Vitrus the Bloody)

    [135039] = true, -- Drop In (Frostbite Spider)
    [99564] = true,  -- Spiders (Frostbite Spider)
    [99566] = true,  -- Falling Spiders (Frostbite Spider)
    [99565] = true,  -- Falling Rocks (Frostbite Spider)

    -- [131796] = true, -- Can Be Hemo Buffed (Harrowfiend)

    [135773] = true, -- Flare (Matron Urgala)
    [135612] = true, -- Frost Wave (Matron Urgala)
    [135642] = true, -- Frost Wave (Matron Urgala)
    [135643] = true, -- Frost Wave (Matron Urgala)
    [135644] = true, -- Frost Wave (Matron Urgala)
    [135628] = true, -- Frost Wave (Matron Urgala)
    [135645] = true, -- Frost Wave (Matron Urgala)
    [135637] = true, -- Frost Wave (Matron Urgala)
    [135646] = true, -- Frost Wave (Matron Urgala)
    [135629] = true, -- Frost Wave (Matron Urgala)
    [135647] = true, -- Frost Wave (Matron Urgala)
    [135648] = true, -- Frost Wave (Matron Urgala)
    [135635] = true, -- Frost Wave (Matron Urgala)
    [135630] = true, -- Frost Wave (Matron Urgala)
    [135636] = true, -- Frost Wave (Matron Urgala)
    [135632] = true, -- Frost Wave (Matron Urgala)
    [135631] = true, -- Frost Wave (Matron Urgala)
    [135634] = true, -- Frost Wave (Matron Urgala)
    [135633] = true, -- Frost Wave (Matron Urgala)
    [135641] = true, -- Frost Wave (Matron Urgala)
    [135639] = true, -- Frost Wave (Matron Urgala)
    [135638] = true, -- Frost Wave (Matron Urgala)
    [135640] = true, -- Frost Wave (Matron Urgala)
    [135627] = true, -- Frost Wave (Matron Urgala)
    [135672] = true, -- Frost Wave (Matron Urgala)

    [135718] = true, -- Frost Vines (Matron Urgala)
    [135721] = true, -- Frost Vines (Matron Urgala)
    [135720] = true, -- Frost Vines (Matron Urgala)
    [135722] = true, -- Frost Vines (Matron Urgala)
    [135723] = true, -- Frost Vines (Matron Urgala)

    [137595] = true, -- Soul Charged (Witch Pike)
    [137652] = true, -- Soul Charged (Witch Pike)
    [137665] = true, -- Soul Charged (Witch Pike)

    -------------------------------------
    -- ARENAS ---------------------------
    -------------------------------------

    -- Dragonstar Arena (Shared)
    [56970] = true, -- CLDA - Normal Arena Normalize
    [56972] = true, -- CLDA - Normal Arena Normalize

    [15686] = true, -- Generic Spawn Apply Portal
    [56786] = true, -- CLDA - Arena 2 Bonus
    [81744] = true, -- Portal Spawn Bonus 3.5s
    [15687] = true, -- Generic Spawn Apply Portal
    [15688] = true, -- Generic Spawn Apply Portal
    [56788] = true, -- CLDA - Arena 2 Bonus

    -- Stage 1
    [58382] = true, -- Speedboost (Fighters Guild Swordmaster)
    [52733] = true, -- Silver Shards (Fighters Guild Swordmaster)
    [52735] = true, -- Silver Shards (Fighters Guild Swordmaster)
    [75845] = true, -- Silver Shards (Fighters Guild Swordmaster)
    [52729] = true, -- Expert Hunter (Fighters Guild Swordmaster)
    [52731] = true, -- Expert Hunter (Fighters Guild Swordmaster)

    [52738] = true, -- Ring of Preservation (Fighters Guild Gladiator)
    [52739] = true, -- Ring of Preservation (Fighters Guild Gladiator)
    [53236] = true, -- Ring of Preservation (Fighters Guild Gladiator)
    [83839] = true, -- Ring of Preservation (Fighters Guild Gladiator)
    [52744] = true, -- Ring of Preservation (Fighters Guild Gladiator)
    [52745] = true, -- Ring of Preservation (Fighters Guild Gladiator)

    [52752] = true, -- Ring of Preservation (Fighters Guild Gladiator)
    [60417] = true, -- Empowered By the Light (Fighters Guild Gladiator)
    [53191] = true, -- Enrage (Fighters Guild Gladiator)
    [57605] = true, -- Enrage (Fighters Guild Gladiator)
    [82996] = true, -- Enrage (Fighters Guild Gladiator)

    [53166] = true, -- Spike Trap (Spike Trap)
    [53169] = true, -- Spike Trap (Spike Trap)
    [53167] = true, -- Spike Trap Snare (Spike Trap)
    [53168] = true, -- Trap Sprung! (Spike Trap)
    [53172] = true, -- Spike Trap (Spike Trap)

    [52746] = true, -- Flawless Dawnbreaker (Champion Marcauld)
    [52747] = true, -- Flawless Dawnbreaker (Champion Marcauld)

    -- Stage 2 - The Frozen Ring
    [53329] = true, -- Warming Aura
    [53328] = true, -- Warming Aura
    [56789] = true, -- CLDA - Arena 3 Bonus
    [56791] = true, -- CLDA - Arena 3 Bonus

    [56755] = true, -- Pierce Armor (Sovngarde Brawler)
    [56757] = true, -- Puncture (Sovngarde Brawler)
    [56758] = true, -- Deep Slash (Sovngarde Brawler)
    [56759] = true, -- Deep Slash (Sovngarde Brawler)
    [56760] = true, -- Deep Slash (Sovngarde Brawler)

    [53239] = true, -- CLDA - Blizzard
    [53341] = true, -- Biting Cold
    [53342] = true, -- Biting Cold
    [60505] = true, -- Biting Cold Fx
    [60421] = true, -- Biting Cold
    [83466] = true, -- Biting Cold
    [53832] = true, -- Torch Grab

    [53313] = true, -- Volley (Sovngarde Ranger)
    [53340] = true, -- CLDA - Volley (Sovngarde Ranger)
    [53314] = true, -- Flame Volley (Sovngarde Ranger)

    [53264] = true, -- Rally (Sovngarde Slayer)
    [53265] = true, -- Rally (Sovngarde Slayer)
    [53266] = true, -- Rally (Sovngarde Slayer)

    [53260] = true, -- Assassinate Bonus (Sovngarde Slayer)
    [53259] = true, -- Reverse Slice (Sovngarde Slayer)
    [53262] = true, -- Reverse Slice (Sovngarde Slayer)
    [53261] = true, -- Reverse Slice (Sovngarde Slayer)

    [53286] = true, -- Crushing Shock (Sovngarde Icemage)
    [53288] = true, -- Crushing Shock (Sovngarde Icemage)
    [53287] = true, -- Crushing Shock (Sovngarde Icemage)
    [53289] = true, -- Force Shock (Destruction) (Sovngarde Icemage)
    [53290] = true, -- Stagger (Sovngarde Icemage)
    [53291] = true, -- Uber Attack (Sovngarde Icemage)

    [53270] = true, -- Frost Clench (Sovngarde Icemage)
    [53272] = true, -- Frost Clench (Sovngarde Icemage)
    [53271] = true, -- Deep Freeze (Sovngarde Icemage)

    [53274] = true, -- Unstable Wall of Frost (Sovngard Icemage)
    [53277] = true, -- Unstable Wall (Sovngard Icemage)
    [53276] = true, -- Unstable Wall of Frost (Sovngard Icemage)
    [53279] = true, -- Unstable Wall of Frost (Sovngard Icemage)
    [53280] = true, -- Unstable Wall of Frost (Sovngard Icemage)
    [53278] = true, -- Unstable Wall of Frost (Sovngard Icemage)
    [53275] = true, -- Unstable Wall of Frost (Sovngard Icemage)

    [57022] = true, -- CLDA - Normal Arena Duo Power
    [53240] = true, -- Brawler (Yavni Frost-Skin)
    [53241] = true, -- Brawler (Yavni Frost-Skin)
    [53243] = true, -- Brawler (Yavni Frost-Skin)

    [53250] = true, -- Wrecking Blow (Yavni Frost-Skin)
    [53251] = true, -- Wrecking Blow (Yavni Frost-Skin)
    [53252] = true, -- Wrecking Blow (Yavni Frost-Skin)
    [53253] = true, -- Wrecking Blow (Yavni Frost-Skin)
    [53255] = true, -- Wrecking Blow (Yavni Frost-Skin)
    [53256] = true, -- Wrecking Blow (Yavni Frost-Skin)

    [53292] = true, -- Elemental Susceptibility (Katti Ice-Turner)
    [53293] = true, -- Elemental Susceptibility (Katti Ice-Turner)
    [53301] = true, -- Icy Pulsar (Katti Ice-Turner)
    [53302] = true, -- Icy Pulsar (Katti Ice-Turner)

    -- Stage 3 - The Marsh
    [56803] = true, -- CLDA - Arena 4 Bonus
    [56805] = true, -- CLDA - Arena 4 Bonus

    [8243] = true,  -- Strike (Corprus Husk)
    [8244] = true,  -- Devastate (Corprus Husk)
    [8247] = true,  -- Vomit (Corprus Husk)
    [30616] = true, -- Vomit (Corprus Husk)
    [30615] = true, -- Wither (Corprus Husk)
    [22107] = true, -- Contaminate (Corprus Husk)
    [22109] = true, -- Contaminate (Corprus Husk)
    [22108] = true, -- Contaminate (Corprus Husk)

    [56798] = true, -- Explosive Curse (Dragonclaw Conjurer)
    [56800] = true, -- Daedric Curse (Dragonclaw Conjurer)
    [34966] = true, -- Daedric Curse Hack (Dragonclaw Conjurer)
    [56802] = true, -- Explosive Curse (Dragonclaw Conjurer)
    [56799] = true, -- Explosive Curse (Dragonclaw Conjurer)

    [83493] = true, -- CLST - Poison Cloud (Poison Cloud)
    [83495] = true, -- False (Poison Cloud)
    [83498] = true, -- Poisonous Cloud (Poison Cloud)
    [83496] = true, -- Poisonous Cloud (Poison Cloud)

    [56796] = true, -- Bound Aegis (Dragonclaw Hedge Wizard)

    [53701] = true, -- Ember Explosion (Shilia)
    [75609] = true, -- Ember Explosion (Shilia)
    [75608] = true, -- Ember Explosion (Shilia)
    [53703] = true, -- Flying Blade (Shilia)
    [53704] = true, -- Flying Blade (Shilia)
    [53699] = true, -- Steel Tornado (Shilia)
    [53698] = true, -- Steel Tornado (Shilia)
    [53700] = true, -- Whirlwind (Shilia)
    [53692] = true, -- Rapid Strikes (Shilia)
    [53693] = true, -- Rapid Strikes (Shilia)
    [53694] = true, -- Rapid Strikes (Shilia)

    [53654] = true, -- Streak (Nak'tah)
    [53656] = true, -- Streak (Nak'tah)
    [53613] = true, -- Thundering Presence (Nak'tah)
    [53614] = true, -- Thundering Presence (Nak'tah)
    [53624] = true, -- Lightning Flood (Nak'tah)
    [53625] = true, -- Lightning Flood (Nak'tah)
    [53659] = true, -- Power Overload Heavy Attack (Nak'tah)
    [53660] = true, -- Power Overload Heavy Attack (Nak'tah)
    [53675] = true, -- Power Overload Heavy Attack (Nak'tah)

    [53607] = true, -- Mages' Wrath (Nak'tah)
    [53611] = true, -- Mages' Fury
    [53610] = true, -- Mages' Wrath Explosion
    [53609] = true, -- Mages' Wrath Explosion

    -- Stage 4 - The Slave Pit
    [56868] = true, -- CLDA - Arena 5 Bonus
    [56870] = true, -- CLDA - Arena 5 Bonus

    [56838] = true, -- Mark Target (House Dres Nightblade)
    [56844] = true, -- Summon Shade (House Dres Nightblade)
    [56843] = true, -- Mark Target (House Dres Nightblade)

    [56822] = true, -- Puncturing Sweep (House Dres Templar)
    [56823] = true, -- Puncturing Sweep (House Dres Templar)
    [56824] = true, -- Puncturing Sweep (House Dres Templar)
    [56825] = true, -- Puncturing Sweep (House Dres Templar)
    [56827] = true, -- Puncturing Sweep (House Dres Templar)
    [27920] = true, -- Generic Knockback Stun (House Dres Templar)

    [54156] = true, -- Quick Strike (House Dres Slaver)
    [54160] = true, -- Berserker Frenzy (House Dres Slaver)
    [54161] = true, -- Berserker Frenzy (House Dres Slaver)
    [54162] = true, -- Berserker Frenzy Snare (House Dres Slaver)

    [54122] = true, -- Enslavement Chk (House Dres Slaver)
    [83774] = true, -- Enslavement (House Dres Slaver)
    [54123] = true, -- Lingering Death (House Dres Slaver)
    [54124] = true, -- Lingering Death (House Dres Slaver)
    [58287] = true, -- (16095) CLDA - Enslavement (House Dres Slaver)

    [54057] = true, -- Molten Weapons (Earthen Heart Knight)
    [54056] = true, -- Molten Armaments (Earthen Heart Knight)

    [54066] = true, -- Obsidian Shield (Earthen Heart Knight)
    [54065] = true, -- Igneous Shield (Earthen Heart Knight)

    [54077] = true, -- Cinder Storm (Earthen Heart Knight)
    [54079] = true, -- Ash Storm Remover (Earthen Heart Knight)
    [54081] = true, -- Cinder Storm (Earthen Heart Knight)
    [54078] = true, -- Eruption Snare (Earthen Heart Knight)
    [54080] = true, -- Cinder Storm (Earthen Heart Knight)

    [54053] = true, -- Stone Giant (Earthen Heart Knight)
    [54054] = true, -- Stone Giant (Earthen Heart Knight)
    [54055] = true, -- Stone Giant (Earthen Heart Knight)

    [54083] = true, -- Corrosive Armor (Earthen Heart Knight)
    [54085] = true, -- Corrosive Armor (Earthen Heart Knight)
    [54084] = true, -- Corrosive Armor (Earthen Heart Knight)

    [54067] = true, -- Fossilize (Earthen Heart Knight)
    [54069] = true, -- Fossilize (Earthen Heart Knight)
    [54068] = true, -- Fossilize (Earthen Heart Knight)

    -- Stage 5 - The Celestial Ring
    [56910] = true, -- CLDA - Arena 6 Bonus
    [56912] = true, -- CLDA - Arena 6 Bonus

    [52876] = true, -- Empowering Chains (Anka-Ra Blademaster)
    [52879] = true, -- Empowering Chains (Anka-Ra Blademaster)
    [52878] = true, -- Pull (Anka-Ra Blademaster)

    [25720] = true, -- Vampiric Touch (Gargoyle)

    [54411] = true, -- Celestial Blast (Anka-Ra Shadowcaster)
    [54415] = true, -- Celestial Blast (Anka-Ra Shadowcaster)
    [54404] = true, -- Celestial Blast (Anka-Ra Shadowcaster)
    [54405] = true, -- Celestial Blast (Anka-Ra Shadowcaster)
    [83441] = true, -- Celestial Blast (Anka-Ra Shadowcaster)
    [54314] = true, -- Celestial Ward (Tile Ward)
    [54315] = true, -- Celestial Ward (Tile Ward)
    [56255] = true, -- CDLA - Tile Ward Buff (Tile Ward)
    [54403] = true, -- Healing Ward (Tile Ward)

    [52885] = true, -- Engulfing Flames (Anal'a Tu'wha)
    [52887] = true, -- Engulfing Flames (Anal'a Tu'wha)

    [52882] = true, -- Unstable Flame (Anal'a Tu'wha)
    [52884] = true, -- Unstable Flame (Anal'a Tu'wha)
    [52883] = true, -- Unstable Flame (Anal'a Tu'wha)

    [52897] = true, -- Standard of Might (Anal'a Tu'wha)
    [52901] = true, -- Standard of Might (Anal'a Tu'wha)
    [52898] = true, -- Standard of Might (Anal'a Tu'wha)
    [52903] = true, -- Standard of Might (Anal'a Tu'wha)
    [52899] = true, -- Standard of Might (Anal'a Tu'wha)

    [52891] = true, -- Flames of Oblivion (Anal'a Tu'wha)
    [52892] = true, -- Flames of Oblivion (Anal'a Tu'wha)

    -- Stage 6 - The Grove
    [56943] = true, -- CLDA - Arena 7 Bonus
    [56945] = true, -- CLDA - Arena 7 Bonus

    [54608] = true, -- Drain Resource (Pacthunter Ranger)
    [54609] = true, -- Drain Resource (Pacthunter Ranger)
    [54610] = true, -- Drain Resource (Pacthunter Ranger)
    [60442] = true, -- Draining Poison (Pacthunter Ranger)
    [56402] = true, -- Drain Resource (Pacthunter Ranger)
    [56403] = true, -- Drain Resource (Pacthunter Ranger)

    [54512] = true, -- Regeneration Aura (Nature's Blessing)
    [54513] = true, -- Restore Stamina (Nature's Blessing)
    [54514] = true, -- Restore Magicka (Nature's Blessing)
    [56575] = true, -- Nature's Grasp (Nature's Blessing)
    [83468] = true, -- Restoring Nature (Nature's Blessing)

    [52820] = true, -- Acid Spray (Pishna Longshot)
    [52823] = true, -- Acid Spray (Pishna Longshot)
    [52821] = true, -- Acid Spray (Pishna Longshot)
    [52822] = true, -- Acid Spray (Pishna Longshot)

    [52803] = true, -- Poison Injection (Pishna Longshot)
    [52804] = true, -- Poison (Pishna Longshot)
    [52805] = true, -- Poison Injection (Pishna Longshot)

    [52825] = true, -- Lethal Arrow (Pishna Longshot)
    [52826] = true, -- Lethal Arrow (Pishna Longshot)

    -- Stage 7 - Circle of Rituals
    [56963] = true, -- CLDA - Arena 8 Bonus
    [56965] = true, -- CLDA - Arena 8 Bonus

    [56946] = true, -- Dragon Fire Scale (Bloodwraith Kynval)
    [56947] = true, -- Dragon Fire Scale (Bloodwraith Kynval)

    [56599] = true, -- CLDA - Captured Animation (Daedric Sacrifice)
    [54611] = true, -- CLDA - Sacrifice (Daedric Sacrifice)
    [55635] = true, -- CLDA - Daedric Sac Check (Daedric Sacrifice)
    [54634] = true, -- CLDA - Sacrifice (Daedric Sacrifice)
    [54635] = true, -- CLDA - Sacrifice (Daedric Sacrifice)
    [55355] = true, -- CLDA 7 - Summon Harvester (Daedric Sacrifice)
    [55353] = true, -- CLDA 7 - Summon Scamp (Daedric Sacrifice)
    [55354] = true, -- Q3868 Rise Knockback (Daedric Sacrifice)
    [54612] = true, -- CLDA - Sacrifice (Daedric Sacrifice)
    [55356] = true, -- Intro (Daedric Sacrifice)
    [55357] = true, -- Untargetable (Daedric Sacrifice)

    [52907] = true, -- Dark Flare (Shadow Knight)
    [52908] = true, -- Dark Flare Dummy (Shadow Knight)
    [52909] = true, -- Dark Flare (Shadow Knight)
    [52910] = true, -- Dark Flare Trauma (Shadow Knight)
    [22094] = true, -- Solar Flare Weaken (Shadow Knight)
    [52911] = true, -- Solar Flare (Shadow Knight)

    [52904] = true, -- Vampire's Bane (Shadow Knight)
    [52906] = true, -- Vampire's Bane (Shadow Knight)
    [52905] = true, -- Vampire's Bane (Shadow Knight)

    [52912] = true, -- Purifying Light (Shadow Knight)
    [52914] = true, -- Purifying Light (Shadow Knight)
    [52917] = true, -- Purifying Light (Shadow Knight)
    [52919] = true, -- Purifying Light (Shadow Knight)
    [52915] = true, -- Purifying Light (Shadow Knight)

    [52920] = true, -- Unstable Core (Shadow Knight)
    [52921] = true, -- Unstable Core (Shadow Knight)

    [52922] = true, -- Searing Light (Shadow Knight)
    [52924] = true, -- Searing Light (Shadow Knight)
    [52962] = true, -- Searing Light (Shadow Knight)

    [52927] = true, -- Solar Disturbance (Shadow Knight)
    [52929] = true, -- Solar Disturbance (Shadow Knight)
    [52931] = true, -- Solar Disturbance (Shadow Knight)
    [52933] = true, -- Solar Disturbance (Shadow Knight)
    [52928] = true, -- Solar Disturbance (Shadow Knight)
    [52932] = true, -- Solar Disturbance Snare (Shadow Knight)

    [54792] = true, -- Crystal Blast (Dark Mage)
    [54794] = true, -- Crystal Shard Stun (Dark Mage)
    [54793] = true, -- Crystal Blast (Dark Mage)

    [54795] = true, -- Shattering Prison (Dark Mage)
    [54798] = true, -- Encase (Dark Mage)
    [54799] = true, -- Encase (Dark Mage)
    [54797] = true, -- Encase (Dark Mage)
    [54796] = true, -- Shattering Prison (Dark Mage)

    [54829] = true, -- Suppression Field (Dark Mage)
    [54833] = true, -- Negate Magic (Dark Mage)
    [54831] = true, -- Suppresion Field (Dark Mage)

    [54819] = true, -- Daedric Minefield (Dark Mage)
    [54820] = true, -- Daedric Mines (Dark Mage)
    [54821] = true, -- Daedric Mines (Dark Mage)
    [54823] = true, -- Daedric Mines (Dark Mage)
    [54826] = true, -- Daedric Mines (Dark Mage)
    [54828] = true, -- Daedric Mines (Dark Mage)
    [54827] = true, -- Daedric Mines (Dark Mage)
    [54825] = true, -- Daedric Minefield (Dark Mage)
    [54824] = true, -- Daedric Minefield (Dark Mage)

    [54809] = true, -- Dark Deal (Dark Mage)
    [54812] = true, -- Dark Exchange Heal (Dark Mage)

    -- Stage 8 - Steamworks
    [56966] = true, -- CLDA - Arena 9 Bonus
    [56968] = true, -- CLDA - Arena 9 Bonus

    [25216] = true, -- Red (Dwarven Fire Centurion)
    [25211] = true, -- Whirlwind Function (Dwarven Fire Centurion)
    [25214] = true, -- Whirlwind Function (Dwarven Fire Centurion)
    [25213] = true, -- Whirlwind Function (Dwarven Fire Centurion)
    [25617] = true, -- Whirlwind Function (Dwarven Fire Centurion)

    [72180] = true, -- Electric Wave (Dwarven Sphere)
    [72181] = true, -- Electric Wave (Dwarven Sphere)

    [25220] = true, -- Blue (Dwarven Ice Centurion)
    [54841] = true, -- Ice Charge (Dwarven Ice Centurion)
    [55022] = true, -- Ice Charge (Dwarven Ice Centurion)
    [58900] = true, -- Ice Charge (Dwarven Ice Centurion)

    [56065] = true, -- Ice Charge (Dwarven Ice Centurion)
    [55981] = true, -- Ice Charge (Dwarven Ice Centurion)
    [56628] = true, -- Ice Charge (Dwarven Ice Centurion)
    [55982] = true, -- Ice Charge (Dwarven Ice Centurion)

    [52758] = true, -- Degeneration (Mavus Talnarith)
    [52761] = true, -- Degeneration (Mavus Talnarith)
    [52763] = true, -- Degeneration (Mavus Talnarith)
    [52759] = true, -- Degeneration (Mavus Talnarith)
    [52762] = true, -- Degeneration (Mavus Talnarith)

    [52773] = true, -- Ice Comet (Mavus Talnarith)
    [83491] = true, -- Ice Comet (Mavus Talnarith)
    [18032] = true, -- Stun (Mavus Talnarith)
    [83489] = true, -- Ice Comet Knockback (Mavus Talnarith)
    [83490] = true, -- Ice Comet (Mavus Talnarith)

    [52765] = true, -- Volcanic Rune (Mavus Talnarith)
    [83479] = true, -- Volcanic Rune (Mavus Talnarith)
    [83482] = true, -- Volcanic Rune (Mavus Talnarith)
    [83480] = true, -- Volcanic Rune (Mavus Talnarith)
    [83477] = true, -- Volcanic Rune (Mavus Talnarith)
    [83478] = true, -- Volcanic Rune (Mavus Talnarith)

    -- Stage 9 - Crypts of the Lost
    [55034] = true, -- CLDA - Sucked Under
    [55221] = true, -- Sucked Under
    [56739] = true, -- Damage Shield
    [55228] = true, -- Sucked Under
    [55915] = true, -- Sucked Under Fall Bonus
    [55035] = true, -- Sucked Under
    [55311] = true, -- Sucked Under
    [58426] = true, -- CLDA - Drop Hate

    [56985] = true, -- Spirit Shield (Zackael/Rubyn Jonnicent)
    [56990] = true, -- CLDA Arena9 - Zackael Shield (Zackael/Rubyn Jonnicent)
    [56992] = true, -- CLDA Arena9 - Zackael Shield (Zackael/Rubyn Jonnicent)
    [50928] = true, -- Self (Zackael Jonnicent)

    [55085] = true, -- Poison Mist (Vampire Lord Thisa)
    [55089] = true, -- Poison Mist (Vampire Lord Thisa)
    [55086] = true, -- Poison Mist (Vampire Lord Thisa)

    [55081] = true, -- Drain Essence (Vampire Lord Thisa)
    [55084] = true, -- Drain Essence (Vampire Lord Thisa)
    [55082] = true, -- Drain Essence (Vampire Lord Thisa)
    -- [55081] = true, -- Drain Essence (Vampire Lord Thisa)
    [21911] = true, -- Stun (Vampire Lord Thisa)

    [55090] = true, -- Devouring Swarm (Vampire Lord Thisa)
    [55092] = true, -- Devouring Swarm (Vampire Lord Thisa)
    [55091] = true, -- Devouring Swarm (Vampire Lord Thisa)

    -- Stage 10 - The Champion's Arena
    [55477] = true, -- Strife (Hiath the Battlemaster)
    [55478] = true, -- Strife (Hiath the Battlemaster)

    [55479] = true, -- Malefic Wreath (Hiath the Battlemaster)
    [55483] = true, -- Malefic Wreath (Hiath the Battlemaster)
    [55482] = true, -- Malefic Wreath (Hiath the Battlemaster)
    [55480] = true, -- Malefic Wreath (Hiath the Battlemaster)

    [55485] = true, -- Crippling Grasp (Hiath the Battlemaster)
    [55493] = true, -- Cripple (Hiath the Battlemaster)
    [55486] = true, -- Cripple (Hiath the Battlemaster)
    [55487] = true, -- Cripple (Hiath the Battlemaster)
    [55488] = true, -- Cripple (Hiath the Battlemaster)
    [55489] = true, -- Summon Shade (Hiath the Battlemaster)
    [55490] = true, -- Cripple (Hiath the Battlemaster)
    [55491] = true, -- Crippling Grasp (Hiath the Battlemaster)
    [55492] = true, -- Crippling Grasp (Hiath the Battlemaster)

    [55494] = true, -- Power Extraction (Hiath the Battlemaster)
    [55496] = true, -- Power Extraction (Hiath the Battlemaster)

    [58196] = true, -- Hiath's Fury (Hiath the Battlemaster)
    [55099] = true, -- Marked for Death (Hiath the Battlemaster)
    [55174] = true, -- Marked for Death (Hiath the Battlemaster)
    [55104] = true, -- Marked for Death (Hiath the Battlemaster)
    [58459] = true, -- Marked for Death (Hiath the Battlemaster)
    [55181] = true, -- Marked for Death (Hiath the Battlemaster)
    [55182] = true, -- Marked for Death (Hiath the Battlemaster)
    [59803] = true, -- CLDA - Hiath Summon Tracker (Hiath the Battlemaster)
    [55592] = true, -- CLDA - Swap Actions 75 (Hiath the Battlemaster)
    [55617] = true, -- CLDA - Swap Actions 50 (Hiath the Battlemaster)
    [55621] = true, -- CLDA - Swap Actions 25 (Hiath the Battlemaster)
    [55602] = true, -- CLDA10 - Spawn West (Hiath the Battlemaster)
    [55615] = true, -- CLDA10 - Spawn East (Hiath the Battlemaster)
    [55616] = true, -- CLDA10 - Spawn North (Hiath the Battlemaster)

    -- End Event
    [55670] = true, -- Levitate Speak 1
    [55639] = true, -- Levitate
    [55641] = true, -- Stun
    [55642] = true, -- Nocom
    [55643] = true, -- CLDA - Boethia Levitate
    [55649] = true, -- CLDA - Boethia Levitate

    -- Maelstrom Arena (Shared)
    [43882] = true, -- CON_Portal 3 Seconds
    [72057] = true, -- Portal Spawn
    [72059] = true, -- Portal Spawn
    [72060] = true, -- Portal Spawn
    [72058] = true, -- Portal Spawn

    [71957] = true, -- Sigil of Speed
    [71959] = true, -- Sigil of Speed
    [67257] = true, -- Speed Used
    [71947] = true, -- Sigil of Health
    [71948] = true, -- Sigil of Health
    [67227] = true, -- Healing Used
    [71900] = true, -- Sigil of Power
    [71912] = true, -- Sigil of Power
    [71901] = true, -- Sigil of Power
    [67210] = true, -- Power Used
    [71955] = true, -- Sigil of Defense
    [71956] = true, -- Sigil of Defense
    [67239] = true, -- Defense Used

    [71951] = true, -- Sigil of Defense
    [67240] = true, -- Sigil of Defense
    [71729] = true, -- Sigil of Defense
    [71953] = true, -- Sigil of Haste
    [67253] = true, -- Sigil of Haste
    [71902] = true, -- Sigil of Power
    [67209] = true, -- Sigil of Power
    [72444] = true, -- Sigil of Power
    [72445] = true, -- Sigil of Power
    [71949] = true, -- Sigil of Healing
    [66920] = true, -- Sigil of Healing
    [66921] = true, -- Healing Aura

    [71727] = true, -- DUN-MA Remove Pick Up Buffs
    [72408] = true, -- DUN-MA Remove Pick Up Buffs
    [72471] = true, -- DUN-MA Grant Resources
    [72472] = true, -- DUN-MA Grant Resources
    [72474] = true, -- DUN-MA Grant Resources

    [70928] = true, -- Is Essential Mob
    [73924] = true, -- DUN-MA Increased Gold
    [72286] = true, -- Portal Spawn
    [72430] = true, -- FNH Portal Spawn
    [72433] = true, -- FNH Portal Spawn
    [72287] = true, -- Portal Spawn
    [72288] = true, -- Portal Spawn
    [72432] = true, -- Portal Spawn
    [72431] = true, -- Portal Spawn

    -- Stage 1 - Vale of the Surreal
    [70885] = true, -- Miasma
    [68194] = true, -- Necrotic Orb (Necrotic Orb)
    [68195] = true, -- Seeking Orb (Necrotic Orb)
    [68199] = true, -- Dummy (Necrotic Orb)
    [68197] = true, -- Necrotic Essence (Necrotic Orb)
    [68198] = true, -- Necrotic Explosion (Necrotic Orb)

    [67765] = true, -- Multiply (Maxus the Many)
    [67768] = true, -- Summon Clones (Maxus the Many)
    [67705] = true, -- Clones Casted Stack (Maxus the Many)
    [73857] = true, -- Set Absorb CD (Maxus the Many)
    [67769] = true, -- Summon Clones (Maxus the Many)
    [44603] = true, -- Break Free (Clones)
    [44605] = true, -- Break Free (Clones)
    [44623] = true, -- Break Free (Clones)
    [44622] = true, -- Break Free (Clones)

    [67682] = true, -- Reunite (Maxus the Many)
    [67691] = true, -- Reunite (Maxus the Many)
    [67683] = true, -- Absorb Clones (Maxus the Many)
    [67687] = true, -- Reunite (Maxus the Many)
    [67694] = true, -- Reunite (Maxus the Many)
    [67690] = true, -- Set Clone CD (Maxus the Many)
    [67735] = true, -- Clone Absorbing (Maxus the Many)
    [67737] = true, -- Stun (Maxus the Many)
    [73856] = true, -- Shadow Heal (Maxus the Many)
    [67738] = true, -- Shadow Heal (Maxus the Many)
    [67736] = true, -- Clone Absorbed (Maxus the Many)
    [67692] = true, -- Set Clone CD (Maxus the Many)

    [67656] = true, -- Multiply (Maxus the Many)
    [67658] = true, -- Summon Clones (Maxus the Many)
    [73859] = true, -- Set Absorb CD (Maxus the Many)
    [67659] = true, -- Summon Clones (Maxus the Many)
    [67660] = true, -- Summon Clones (Maxus the Many)

    [69515] = true, -- Multiply (Maxus the Many)
    [69516] = true, -- Summon Clones (Maxus the Many)
    [73858] = true, -- Set Absorb CD (Maxus the Many)
    [69517] = true, -- Summon Clones (Maxus the Many)
    [69518] = true, -- Summon Clones (Maxus the Many)
    [69519] = true, -- Summon Clones (Maxus the Many)

    [70891] = true, -- Entropic Bolt (Maxus the Many)
    [70892] = true, -- Bone Cage (Maxus the Many)
    [70895] = true, -- Encase (Maxus the Many)
    [70893] = true, -- Defiled Grave (Maxus the Many)
    [70901] = true, -- Defiled Grave (Maxus the Many)
    [72148] = true, -- Bone Cage (Maxus the Many)
    [72151] = true, -- Encase (Maxus the Many)
    [72152] = true, -- Defiled Grave (Maxus the Many)
    [72149] = true, -- Defiled Grave (Maxus the Many)
    [70993] = true, -- Shadow Step (Maxus the Many)
    [73868] = true, -- Teleport Ground (Maxus the Many)

    [67771] = true, -- Set Absorb CD (Maxus the Many)
    [67662] = true, -- Set Absorb CD (Maxus the Many)
    [69522] = true, -- Set Absorb CD (Maxus the Many)
    [67739] = true, -- Shadow Heal (Maxus the Many)
    [72086] = true, -- Shadow Strength (Maxus the Many)

    -- Round 2 - Seht's Balcony
    [69018] = true, -- Generator (Generator)
    [69020] = true, -- Attack (Generator)
    [72722] = true, -- Knock Back (Generator)
    [72687] = true, -- Knock Back (Generator)
    [69101] = true, -- Shock (Generator)
    [72688] = true, -- Knock Back FX (Generator)
    [72690] = true, -- Overload (Generator)
    [72686] = true, -- Overload (Generator)
    [72736] = true, -- Overload 2 (Generator)

    [66793] = true, -- Blade Trap (Blade Trap)
    [71198] = true, -- Stun (Blade Trap)
    [73871] = true, -- Generic NPC 115% Speed (Blade Trap)
    [74021] = true, -- Generic NPC 115% Speed (Blade Trap)
    [66865] = true, -- NPC 200% Run (Blade Trap)
    [66797] = true, -- Spinning Blade (Blade Trap)
    [72414] = true, -- Serrated Blade (Blade Trap)
    [72413] = true, -- Serrated Blade (Blade Trap)
    [72194] = true, -- Serrated Blade (Blade Trap)
    [72199] = true, -- Serrated Blade (Blade Trap)

    [72489] = true, -- Heal (Generator)
    [69022] = true, -- Heal (Generator)
    [72036] = true, -- Stopped Blades (Blade Trap)
    [72419] = true, -- Stopped Blades (Blade Trap)
    [69102] = true, -- Heal (Generator)
    [69149] = true, -- Reset Switches (Generator)

    [73119] = true, -- NPC 50% Speed (Clockwork Sentry)
    [73118] = true, -- NPC 75% Speed (Clockwork Sentry)
    [73116] = true, -- Sentry Snare (Clockwork Sentry)
    [71047] = true, -- Thunderbolt (Clockwork Sentry)
    [71048] = true, -- Thunderbolt (Clockwork Sentry)
    [72067] = true, -- Energizing (Clockwork Sentry)

    [67182] = true, -- Silver (Centurion Champion)
    [72589] = true, -- Portal Spawn (Centurion Champion)
    [72591] = true, -- Portal Spawn (Centurion Champion)
    [72592] = true, -- Portal Spawn (Centurion Champion)
    [72590] = true, -- Portal Spawn (Centurion Champion)
    [67203] = true, -- Gold (Centurion Champion)
    [72599] = true, -- Portal Spawn (Centurion Champion)
    [72602] = true, -- Portal Spawn (Centurion Champion)
    [72601] = true, -- Portal Spawn (Centurion Champion)
    [72603] = true, -- Portal Spawn (Centurion Champion)
    [67207] = true, -- Copper (Centurion Champion)
    [72600] = true, -- Portal Spawn (Centurion Champion)
    [72605] = true, -- Portal Spawn (Centurion Champion)
    [72604] = true, -- Portal Spawn (Centurion Champion)
    [72606] = true, -- Portal Spawn (Centurion Champion)

    [69364] = true, -- Barrage Function (Centurion Champion)
    [69369] = true, -- Barrage Function (Centurion Champion)
    [69367] = true, -- Barrage Function (Centurion Champion)
    [69368] = true, -- Barrage Function (Centurion Champion)
    [69371] = true, -- Barrage Function (Centurion Champion)
    [69366] = true, -- Barrage Function (Centurion Champion)

    [67030] = true, -- Defense Mode (Centurion Champion)
    [66904] = true, -- Full Defense (Centurion Champion)
    [69317] = true, -- Sheild (Centurion Champion)
    [66905] = true, -- Full Defense (Centurion Champion)
    [69316] = true, -- Electric Shield (Centurion Champion)
    [68819] = true, -- Full Defense (Centurion Champion)

    [67625] = true, -- Lamia Queen (Lamia Queen)
    [67574] = true, -- Shock (Water)
    [67869] = true, -- Electric Water (Water)
    [67635] = true, -- Shock Water (Lamia Queen)
    [67871] = true, -- Shock (Water)

    [73879] = true, -- Lightning X (Lamia Queen)
    [73881] = true, -- Call Lightning (Lamia Queen)
    [73880] = true, -- Call Lightning (Lamia Queen)

    [73882] = true, -- Lightning g (Lamia Queen)
    [67757] = true, -- Queen's Poison (Lamia Queen)
    [67760] = true, -- CON_AOE_Template (Lamia Queen)
    [67759] = true, -- CON_AOE_Template (Lamia Queen)
    [67758] = true, -- Queen's Poison (Lamia Queen)

    [68357] = true, -- Queen's Radiance (Lamia Queen)
    [68358] = true, -- Queen's Radiance (Lamia Queen)
    [68382] = true, -- Grand Healing Fx (Lamia Queen)

    [76094] = true, -- Spit (Strangler)
    [76147] = true, -- Snared (Stangler)

    [21646] = true, -- Clawed Swipe (Lamia Queen)
    [73876] = true, -- Piercing Shriek (Lamia Queen)
    [73878] = true, -- Piercing Shriek (Lamia Queen)
    [73877] = true, -- Piercing Shriek (Lamia Queen)
    [73987] = true, -- No Scream Knockdown (Lamia Queen)

    -- Stage 4 - Seht's Flywheel
    [71044] = true, -- Turret Occupied
    [71045] = true, -- Turret Mode (Clockwork Sentry)
    [71050] = true, -- Static Shield (Clockwork Sentry)
    [71052] = true, -- Static Shield Explosion (Clockwork Sentry)
    [71053] = true, -- Static Shield (Clockwork Sentry)

    [73847] = true, -- Charged (Clockwork Sentry)
    [73850] = true, -- Static Shield (Clockwork Sentry)
    [73852] = true, -- Static Shield Explosion (Clockwork Sentry)
    [73851] = true, -- Static Shield (Clockwork Sentry)

    [69268] = true, -- Enrage (Achelir)
    [69269] = true, -- Enrage (Achelir)

    [72157] = true, -- Static Field (Dwarven Spider)
    [72159] = true, -- Static Field (Dwarven Spider)
    [72164] = true, -- tell others (Dwarven Spider)
    [72160] = true, -- Static Field (Dwarven Spider)
    [72165] = true, -- Overcharge Trigger (Dwarven Spider)
    [72163] = true, -- Overcharge (Dwarven Spider)
    [72178] = true, -- Overcharge (Dwarven Spider)
    [72171] = true, -- Overcharge (Dwarven Spider)
    [72179] = true, -- Overcharge (Dwarven Spider)
    [72172] = true, -- Overcharge Trigger (Dwarven Spider)
    [72169] = true, -- Overcharge (Dwarven Spider)

    [72166] = true, -- Overcharge (Dwarven Spider)
    [72174] = true, -- Overcharge (Dwarven Spider)
    [72167] = true, -- Overcharge (Dwarven Spider)
    [72175] = true, -- Overcharge (Dwarven Spider)
    [72176] = true, -- Overcharge (Dwarven Spider)

    [59858] = true, -- Generic Sphere Drop to Combat

    [68662] = true, -- Intro Stun (The Control Guardian)
    [68665] = true, -- Recovery (The Control Guardian)

    [68524] = true, -- Overcharged (The Control Guardian)
    [69088] = true, -- Overcharge (The Control Guardian)
    [69087] = true, -- Static Field (The Control Guardian)
    [69086] = true, -- Overcharge (The Control Guardian)
    [69098] = true, -- Overcharge Trigger (The Control Guardian)
    [68538] = true, -- Overchaged Bolt (The Control Guardian)
    [68537] = true, -- Overchaged Bolt (The Control Guardian)

    [70829] = true, -- Overcharged Cooldown (The Control Guardian)
    [68539] = true, -- Overheated (The Control Guardian)
    [70861] = true, -- Overheating (The Control Guardian)
    [71109] = true, -- Fire FX (The Control Guardian)
    [72208] = true, -- Rooted (The Control Guardian)
    [70860] = true, -- Overheated Flame (The Control Guardian)

    [68558] = true, -- Overheated Volley (The Control Guardian)
    [68548] = true, -- Overheated Volley (The Control Guardian)
    [68547] = true, -- Overheated Volley (The Control Guardian)
    [68546] = true, -- Overheated Volley (The Control Guardian)
    [68543] = true, -- Overheated Volley (The Control Guardian)

    [72197] = true, -- Quick Strike (Scavenger Thunder-Smith)
    [72195] = true, -- Thunder Hammer (Scavenger Thunder-Smith)
    [72196] = true, -- Thunder Hammer (Scavenger Thunder-Smith)
    [72198] = true, -- Wrecking Blow (Scavenger Thunder-Smith)
    [72200] = true, -- Wrecking Blow (Scavenger Thunder-Smith)
    [72201] = true, -- Wrecking Blow (Scavenger Thunder-Smith)
    [72204] = true, -- Streak (Scavenger Thunder-Smith)
    [72206] = true, -- Streak (Scavenger Thunder-Smith)
    [72202] = true, -- Overcharge (Scavenger Thunder-Smith)
    [72203] = true, -- Overcharge (Scavenger Thunder-Smith)

    -- Stage 5 - Rink of Frozen Blood
    [67805] = true, -- Frigid Waters
    [67811] = true, -- Frigid Waters
    [67810] = true, -- Frigid Waters
    [72525] = true, -- Frigid Waters
    [67808] = true, -- Frigid Waters
    [67814] = true, -- Frigid Waters
    [67812] = true, -- Frigid Waters
    [67809] = true, -- Frigid Waters

    [72417] = true, -- Poison Arrow (Huntsman Heartfinder)
    [72418] = true, -- Poison Arrow (Huntsman Heartfinder)

    [70897] = true, -- Call Ally (Huntsman Chillbane)
    [70898] = true, -- Call Ally (Huntsman Chillbane)
    [71939] = true, -- Frost Breath (Huntsman Chillbane)
    [98062] = true, -- Frost Breath (Huntsman Chillbane)
    [71940] = true, -- Frost Breath (Huntsman Chillbane)
    [71937] = true, -- Frost Nova (Huntsman Chillbane)
    [71938] = true, -- Frost Nova (Huntsman Chillbane)

    [71692] = true, -- Ready to Smash (Troll Breaker)
    [72446] = true, -- Smash Iceberg (Troll Breaker)
    [72450] = true, -- Interrupted (Troll Breaker)
    [72494] = true, -- Go To Closests Iceberg (Troll Breaker)
    [72011] = true, -- Stagger (Iceberg)
    [72013] = true, -- Stagger (Iceberg)
    [20746] = true, -- Emerge (Leimenid Oracle)
    [72012] = true, -- Stagger (Iceberg)

    [72703] = true, -- Cold Snap Bolt (Leimenid Oracle)
    [72704] = true, -- Cold Snap Snare (Leimenid Oracle)
    [72705] = true, -- Cold Snap (Leimenid Oracle)

    [71994] = true, -- Cold Snap Bolt (Leimenid Oracle)
    [71996] = true, -- Cold Snap Snare (Leimenid Oracle)
    [71997] = true, -- Cold Snap (Leimenid Oracle)

    [71926] = true, -- Frenzy of Blows (Angirgoth)
    [71930] = true, -- Frenzy of Blows (Angirgoth)
    [71929] = true, -- Frenzy of Blows (Angirgoth)

    [71931] = true, -- Rapid Strikes (Angirgoth)
    [71932] = true, -- Rapid Strikes (Angirgoth)
    [71933] = true, -- Rapid Strikes (Angirgoth)

    [71935] = true, -- Steel Tornado (Angirgoth)
    [71934] = true, -- Steel Tornado (Angirgoth)
    [71936] = true, -- Whirlwind (Angirgoth)

    [71914] = true, -- Speedboost (Ogre)

    [71630] = true, -- Emerge (Leimenid)
    [71897] = true, -- Frost Bolt (Leimenid)

    [71915] = true, -- Uppercut (Frost Atronach)

    [72438] = true, -- Shatter (Giant)
    [72440] = true, -- Shatter (Giant)
    [72441] = true, -- Shatter (Giant)
    [72442] = true, -- Shatter (Giant)
    [72439] = true, -- Shatter (Giant)

    [68439] = true, -- Enrage (Aki/Vigi)
    [68440] = true, -- Enrage (Aki/Vigi)
    [68441] = true, -- Enrage (Aki/Vigi)

    [74130] = true, -- Intimidating Roar (Aki/Vigi)
    [74131] = true, -- Intimidating Roar (Aki/Vigi)
    [74132] = true, -- Intimidating Roar (Aki/Vigi)

    [72044] = true, -- Boss Speedboost (Matriarch Runa)
    [66378] = true, -- Sweep (Matriarch Runa)
    [66379] = true, -- Sweep (Matriarch Runa)
    [66381] = true, -- Obliterate (Matriarch Runa)
    [66380] = true, -- Obliterate (Matriarch Runa)

    [72749] = true, -- Freezing Stomp (Matriarch Runa)
    [72751] = true, -- Freezing Stomp (Matriarch Runa)
    [72750] = true, -- Freezing Stomp (Matriarch Runa)

    [67088] = true, -- Intimidating Roar (Matriarch Runa)
    [67091] = true, -- Intimidating Roar (Matriarch Runa)
    [67092] = true, -- Intimidating Roar (Matriarch Runa)

    [66325] = true, -- Shatter (Matriarch Runa)
    [72752] = true, -- Shatter (Matriarch Runa)
    [66328] = true, -- Shatter (Matriarch Runa)
    [66330] = true, -- Shatter (Matriarch Runa)
    [66327] = true, -- Shatter (Matriarch Runa)
    [66331] = true, -- Shatter (Matriarch Runa)
    [66329] = true, -- Shatter (Matriarch Runa)
    [66326] = true, -- Shatter (Matriarch Runa)

    [71696] = true, -- Enrage (Matriarch Runa)
    [71700] = true, -- Charge (Matriarch Runa)
    [72409] = true, -- Taunt (Matriarch Runa)
    [71701] = true, -- Can Quake (Matriarch Runa)
    [71702] = true, -- Iceberg Calving (Matriarch Runa)
    [71710] = true, -- Iceberg Calving (Matriarch Runa)
    [71705] = true, -- Iceberg Calving (Matriarch Runa)
    [72037] = true, -- Stagger (Matriarch Runa)
    [71706] = true, -- Iceberg Calving (Matriarch Runa)
    [72707] = true, -- Iceberg Calving (Matriarch Runa)
    [71721] = true, -- Knockback (Matriarch Runa)
    [71720] = true, -- Stun (Matriarch Runa)

    [72005] = true, -- DUN-MA GM Stop Slam Trolls (Troll Breaker)

    [71613] = true, -- Transform (Huntsman NPCs)
    [71616] = true, -- Regeneration (Huntsman NPCs)
    [71614] = true, -- Stun (Huntsman NPCs)

    -------------------------------------
    -- DUNGEONS -------------------------
    -------------------------------------

    -- Banished Cells I
    [86710] = true, -- Checkpoint Tele Arrive (Banished Cells - 2nd to last boss)
    [8523] = true,  -- Keeper Prison
    [18998] = true, -- DUN_BC P6_Ritual_Daedric
    [18995] = true, -- DUN_BC Skeleton Rise
    [19028] = true, -- Drain Essence (Cell Haunter)
    [42052] = true, -- Drain Essence (Cell Haunter)
    [46235] = true, -- ClannFear Intro 1 (Shadowrend)
    [46258] = true, -- Clannfear Arrives (Shadowrend)
    [18725] = true, -- Spiked Headbutt (Shadowrend)
    [47587] = true, -- Tail Smite (Shadowrend)
    [47608] = true, -- Knocked Down (Shadowrend)
    [21886] = true, -- Summon Dark Proxy (Shadowrend)
    [21887] = true, -- Forward Charge (Shadowrend)
    [18728] = true, -- Pounce (Shadowrend)
    [35625] = true, -- Pounce (Shadowrend)
    [18772] = true, -- Feeding (Shadowrend)
    [18759] = true, -- Pounce (Shadowrend)
    [18708] = true, -- Summon Clannfear (Angata the Clannfear Handler)
    [18709] = true, -- Summon Appearance (Angata the Clannfear Handler)
    [19025] = true, -- Dead Zone (Skeletal Destroyer)
    [19027] = true, -- Dead Zone (Skeletal Destroyer)
    [18961] = true, -- Ghostly Summon (Generic Invisible Target)
    [18798] = true, -- Slash (High Kinlord Rilis)
    [33189] = true, -- Crushing Blow (High Kinlord Rilis)
    [33190] = true, -- Crushing Blow (High Kinlord Rilis)
    [33191] = true, -- Crushing Blow (High Kinlord Rilis)
    [18795] = true, -- CON_Invisible_30%_Speed_Debuff (The Feast)
    [86759] = true, -- The Feast Tick (The Feast)
    [33172] = true, -- Oblivion Restoration (The Feast)
    [33165] = true, -- Despawn Self (The Feast)
    [18840] = true, -- Soul Blast (High Kinlord Rilis)
    [18846] = true, -- Soul Blast (High Kinlord Rilis)
    [18847] = true, -- Soul Blast (High Kinlord Rilis)
    [18875] = true, -- Daedric Tempest (High Kinlord Rilis)
    [33437] = true, -- Daedric Tempest (High Kinlord Rilis)
    [33174] = true, -- Daedric Tempest (High Kinlord Rilis)
    [33179] = true, -- Daedric Tempest (High Kinlord Rilis)
    [33184] = true, -- Daedric Tempest (High Kinlord Rilis)
    [33187] = true, -- Daedric Tempest (High Kinlord Rilis)
    [33188] = true, -- Daedric Tempest (High Kinlord Rilis)
    [36522] = true, -- Daedric Flames (High Kinlord Rilis)
    [46296] = true, -- Crystals (Binding Stones)
    [36524] = true, -- Binding

    -- Banished Cells II
    [85885] = true, -- Teleport
    [32287] = true, -- Rilis' Cruelty
    [64490] = true, -- Shatter
    [31265] = true, -- NFX_Q4597 Cruelty Stone
    [36473] = true, -- DUN_BCH Cruelty One Shot
    [46715] = true, -- DUN_BCH Cruelty One Shot
    [46713] = true, -- DUN_BCH Cruelty One Shot

    [70612] = true, -- Chains
    [70613] = true, -- Chains
    [70614] = true, -- Chains
    [70615] = true, -- Chains
    [29481] = true, -- Chains
    [29486] = true, -- Chains
    [28786] = true, -- Inferno
    [28915] = true, -- Inferno
    [49190] = true, -- Dummy
    [49191] = true, -- Dummy
    [70633] = true, -- Dummy
    [70632] = true, -- Dummy
    [34408] = true, -- Stun

    [28902] = true, -- Swipe (Maw of the Infernal)
    [48271] = true, -- Breath of Flame (Maw of the Infernal)
    [49149] = true, -- Breath of Flame (Maw of the Infernal)
    [28903] = true, -- Immolating Bite (Maw of the Infernal)
    [35680] = true, -- Immolating Bite (Maw of the Infernal)
    [28905] = true, -- Immolating Bite (Maw of the Infernal)
    [28904] = true, -- Immolating Bite (Maw of the Infernal)
    [47127] = true, -- Nocom (Maw of the Infernal)

    [48281] = true, -- Slash (Keeper Voranil)
    [27826] = true, -- Crushing Blow (Keeper Voranil)
    [27827] = true, -- Crushing Blow (Keeper Voranil)
    [27828] = true, -- Crushing Blow (Keeper Voranil)
    [29018] = true, -- Berserker Frenzy (Keeper Voranil)
    [29020] = true, -- Berserker Frenzy (Keeper Voranil)
    [29022] = true, -- Berserker Frenzy Snare (Keeper Voranil)
    [28750] = true, -- Essence Siphon (Keeper Voranil)
    [28759] = true, -- Essence Siphon (Keeper Voranil)

    [32290] = true, -- Rilis' Madness (High Kinlord Rilis)
    [64518] = true, -- Shatter (The Second Binding Stone)

    [28964] = true, -- Spawn (Keeper Imiril)
    [30734] = true, -- Portal (Daedric Chaos)
    [31713] = true, -- Root (Daedric Chaos)
    [32044] = true, -- Has Jumped (Daedric Chaos)
    [31712] = true, -- Portal Leap (Daedric Chaos)
    [31726] = true, -- Corruption (Daedric Chaos)
    [32054] = true, -- SpawnRun (Banekin)
    [32038] = true, -- Into Portal (Keeper Imiril)
    [36631] = true, -- ExitPortal (Keeper Imiril)
    [31727] = true, -- Corruption (Daedric Chaos)
    [28916] = true, -- Slash (Keeper Imiril)
    [29143] = true, -- Daedric Blast (Keeper Imiril)

    [32291] = true, -- Rilis' Dominion (High Kinlord Rilis)
    [64526] = true, -- Shatter (The Third Binding Stone)

    [28961] = true, -- Sister's Love (Sister Sihna / Sister Vera)
    [28962] = true, -- Sister's Love (Sister Sihna / Sister Vera)
    [28966] = true, -- Dummy (Sister Sihna / Sister Vera)

    [35847] = true, -- Dummy
    [31436] = true, -- NFX_Q4597 Final Stone
    [46433] = true, -- DUN_BCH_Knockback&Knockdown (High Kinlord Rilis)
    [46435] = true, -- Fire Backlash (High Kinlord Rilis)

    [28715] = true, -- Daedric Bolt (High Kinlord Rilis)
    [28570] = true, -- Levitate (High Kinlord Rilis)
    [64618] = true, -- Bubble Immunity (High Kinlord Rilis)
    [28773] = true, -- Levitate (High Kinlord Rilis)
    [28462] = true, -- Levitate (High Kinlord Rilis)
    [64619] = true, -- Bubble Immunity (High Kinlord Rilis)
    [28775] = true, -- Levitate (High Kinlord Rilis)
    [28475] = true, -- Curse of Suffering
    [48502] = true, -- Snare
    [48889] = true, -- Curse of Suffering
    [48308] = true, -- Curse of Suffering
    [28571] = true, -- Curse of Dominance
    [48508] = true, -- Snare
    [48888] = true, -- Curse of Dominance
    [48507] = true, -- Curse of Dominance

    [29989] = true, -- Daedric Step
    [46967] = true, -- Daedric Step
    [46964] = true, -- Daedric Step
    [46965] = true, -- Daedric Step
    [46963] = true, -- Teleportdummy

    [36029] = true, -- The Feast Projectile
    [48908] = true, -- The Feast
    [48909] = true, -- The Feast
    [26070] = true, -- The Feast

    [48799] = true, -- Deadric Tempest
    [48802] = true, -- Daedric Tempest
    [48801] = true, -- Daedric Tempest
    [48810] = true, -- Daedric Tempest
    [48811] = true, -- Daedric Tempest
    [48812] = true, -- Daedric Tempest
    [48813] = true, -- Daedric Tempest
    [48803] = true, -- Daedric Tempest
    [48804] = true, -- Daedric Tempest
    [48805] = true, -- Daedric Tempest
    [48806] = true, -- Daedric Tempest
    [48807] = true, -- Daedric Tempest
    [48808] = true, -- Daedric Tempest
    [48809] = true, -- Daedric Tempest
    [48800] = true, -- Daedric Tempest

    [48814] = true, -- Daedric Tempest
    [48816] = true, -- Daedric Tempest
    [48818] = true, -- Daedric Tempest
    [48821] = true, -- Daedric Tempest
    [48823] = true, -- Daedric Tempest
    [48826] = true, -- Daedric Tempest
    [48827] = true, -- Daedric Tempest
    [48817] = true, -- Daedric Tempest
    [48819] = true, -- Daedric Tempest
    [48822] = true, -- Daedric Tempest
    [48824] = true, -- Daedric Tempest
    [48825] = true, -- Daedric Tempest
    [48820] = true, -- Daedric Tempest
    [48828] = true, -- Daedric Tempest
    [48815] = true, -- Daedric Tempest
    [28362] = true, -- Black Sigil
    [36020] = true, -- Black Sigil
    [28088] = true, -- Red Sigil
    [36030] = true, -- Red Sigil
    [31482] = true, -- DUN_BCH Portal

    -- Elden Hollow I
    [85726] = true, -- Teleport
    [14905] = true, -- Hacking Strike (Akash gra-Mal)
    [16834] = true, -- Executioner's Strike (Akash gra-Mal)
    [25309] = true, -- Fire Backlash (Akash gra-Mal)
    [25310] = true, -- CON_Knockback&Knockdown (Akash gra-Mal)
    [15999] = true, -- Leaping Strike (Akash gra-Mal)
    [16003] = true, -- Leaping Strike (Akash gra-Mal)
    [9936] = true,  -- Battlecry (Akash gra-Mal)
    [44093] = true, -- Battlecry (Akash gra-Mal)
    [16016] = true, -- Berserker Frenzy (Akash gra-Mal)
    [16017] = true, -- Berserker Frenzy (Akash gra-Mal)
    [16022] = true, -- Berserker Frenzy Snare (Akash gra-Mal)
    [25300] = true, -- Berserker Frenzy (Akash gra-Mal)
    [25301] = true, -- Berserker Frenzy (Akash gra-Mal)
    [25302] = true, -- Berserker Frenzy (Akash gra-Mal)
    [23498] = true, -- End Undeath
    [23481] = true, -- End Undeath
    [25400] = true, -- Intro Theater
    [25402] = true, -- Roar

    [15116] = true, -- Piercing Strike (Chokethorn)
    [15113] = true, -- Pulling Grasp (Chokethorn)
    [15114] = true, -- Pulling Grasp (Chokethorn)
    [9905] = true,  -- Pulling Grasp (Chokethorn)
    [25528] = true, -- Pulling Grasp (Chokethorn)
    [9910] = true,  -- Summon Saplings (Chokethorn)
    [25458] = true, -- Init Self Stun (Strangler Saplings)
    [25455] = true, -- Summon Saplings (Strangler Saplings)
    [9930] = true,  -- Heal Spores (Strangler Saplings)
    [9875] = true,  -- Fungal Burst (Chokethorn)
    [44092] = true, -- Generic Stagger Enemy (Chokethorn)

    [16451] = true, -- Watching Combat (Nenesh gro-Mal)
    [35816] = true, -- Leefseether (Leafseether)
    [44223] = true, -- Inhale (Leafseether)
    [44225] = true, -- Inhale (Leafseether)
    [14216] = true, -- Generic Shadowy Effect
    [25796] = true, -- Intro
    [25930] = true, -- Intro End
    [15120] = true, -- Phantasmal Bolt (Canonreeve Oraneth)
    [9845] = true,  -- Rotting Bolt (Canonreeve Oraneth)
    [9852] = true,  -- Rotting Bolt (Canonreeve Oraneth)
    [16262] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [16275] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [25932] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [25936] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [25938] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [25937] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [25348] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [25877] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [42601] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [25370] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [46800] = true, -- Necrotic Circle (Canonreeve Oraneth)
    [12478] = true, -- CON_Ground Rise ON (Darkfern Skeleton)
    [25820] = true, -- Necrotic Circle (Darkfern Skeleton)
    [25828] = true, -- Necrotic Circle (Darkfern Skeleton)
    [25829] = true, -- Necrotic Circle (Darkfern Skeleton)
    [25827] = true, -- Necrotic Circle (Darkfern Skeleton)
    [9944] = true,  -- Necrotic Burst (Canonreeve Oraneth)
    [15682] = true, -- Necrotic Burst (Canonreeve Oraneth)
    [15681] = true, -- Necrotic Burst (Canonreeve Oraneth)
    [9839] = true,  -- Bone Hurricane (Canonreeve Oraneth)

    [25721] = true, -- End Undeath
    [25724] = true, -- End Undeath
    [25722] = true, -- Fire Backlash
    [25723] = true, -- CON_Knockback&Knockdown
    [28830] = true, -- Rumbling
    [28820] = true, -- Rumbling
    [27888] = true, -- Darkness Below
    [27894] = true, -- Bonus Radius
    [27891] = true, -- Darkness Below
    [27893] = true, -- Darkness Below Immunity
    [27889] = true, -- Knockback Immunity
    [27892] = true, -- Darkness Below
    [27890] = true, -- Darkness Below
    [28886] = true, -- Darkness Below

    -- Elden Hollow II
    [85909] = true, -- Teleport
    [31114] = true, -- EHH_Striker_Invis
    [31109] = true, -- Intro
    [31347] = true, -- Portal
    [34376] = true, -- Flame Geyser (Dubroze the Infestor)
    [34377] = true, -- Flame Geyser (Dubroze the Infestor)
    [34378] = true, -- Flame Geyser (Dubroze the Infestor)

    [32791] = true, -- Q4675-Flip
    [40753] = true, -- PortalIntro (Portal)
    [32709] = true, -- Lacerate (Dark Root)
    [32567] = true, -- Hammering Light (Dark Root)
    [32572] = true, -- Hammering Light (Dark Root)
    [32569] = true, -- Hammering Light (Dark Root)
    [32582] = true, -- Hammering Light (Dark Root)
    [32585] = true, -- Hammering Light (Dark Root)
    [32583] = true, -- Hammering Light (Dark Root)
    [32586] = true, -- Hammering Light (Dark Root)
    [32589] = true, -- Hammering Light (Dark Root)
    [32587] = true, -- Hammering Light (Dark Root)
    [32590] = true, -- Hammering Light (Dark Root)
    [32593] = true, -- Hammering Light (Dark Root)
    [32591] = true, -- Hammering Light (Dark Root)
    [32707] = true, -- Summon Guardians (Dark Root)
    [32708] = true, -- Summon Guardians (Dark Root)
    [32845] = true, -- Summon Guardians (Dark Root)
    [32599] = true, -- Dummy (Dark Root)
    [32596] = true, -- Dummy (Dark Root)
    [33334] = true, -- Latch On Stamina (Frenzied Guardian)
    [33335] = true, -- Latch On Stamina (Frenzied Guardian)
    [33337] = true, -- Latch On Magicka (Mystic Guardian)
    [33338] = true, -- Latch On MAgicka (Mystic Guardian)
    [32648] = true, -- Fortified Ground (Fortified Guardian)
    [32653] = true, -- Fortification (Fortified Guardian)
    [32655] = true, -- Fortification (Fortified Guardian)
    [32654] = true, -- Fortification (Fortified Guardian)
    [32706] = true, -- Fortification (Fortified Guardian)
    [32647] = true, -- Empowered Ground (Mystic Guardian)
    [32613] = true, -- Empowered (Mystic Guardian)
    [32614] = true, -- Empowered (Mystic Guardian)
    [32618] = true, -- Empowered (Mystic Guardian)
    [32890] = true, -- Gleaming Light (Dark Root)
    [33533] = true, -- Glaring Light (Dark Root)
    [33535] = true, -- Brightening Light (Dark Root)

    [33169] = true, -- Incite Fear (Shadow Tendril)
    [33170] = true, -- Hate (Shadow Tendril)
    [33181] = true, -- Summon Despair (Shadow Tendril)
    [33164] = true, -- Incite Fear (Shadow Tendril)
    [47087] = true, -- Incite Fear (Shadow Tendril)

    [33513] = true, -- Q4675-Channel-On_Bakkhara
    [35799] = true, -- Q4675-Channel-On_Bakkhara
    [35798] = true, -- Beam
    [33499] = true, -- EHH_Boss_02_Shadow_Effect

    [32811] = true, -- Double Slam (Murklight)
    [32817] = true, -- Double Slam (Murklight)
    [33052] = true, -- Shadow Stomp (Murklight)

    [32832] = true, -- Consuming Shadow (Murklight)
    [32849] = true, -- Consuming Shadow (Murklight)
    [32851] = true, -- Consuming Shadow (Murklight)
    [32968] = true, -- Consuming Shadow (Murklight)
    [32971] = true, -- Consuming Shadow (Murklight)
    [32972] = true, -- Consuming Shadow (Murklight)
    [32973] = true, -- Consuming Shadow (Murklight)

    [32975] = true, -- Eclipse (Murklight)
    [32978] = true, -- Eclipse (Murklight)
    [33049] = true, -- Eclipse (Murklight)
    [33050] = true, -- Eclipse (Murklight)
    [33530] = true, -- Eclipse (Murklight)
    [33531] = true, -- Eclipse (Murklight)

    [33102] = true, -- Spout Shadow (The Shadow Guard)
    [33104] = true, -- Spout Shadow (The Shadow Guard)
    [33105] = true, -- Spout Shadow (The Shadow Guard)
    [48793] = true, -- Spout Shadow (The Shadow Guard)
    [33103] = true, -- Spout Shadow (The Shadow Guard)

    [61677] = true, -- Smoke Bomb
    [35375] = true, -- Emerge (Bogdan the Nightflame)
    [35429] = true, -- Emerge (Bogdan the Nightflame)
    [34171] = true, -- Emerge (Bogdan the Nightflame)
    [47114] = true, -- Emerge (Bogdan the Nightflame)
    [35371] = true, -- Emerge (Bogdan the Nightflame)
    [35372] = true, -- Emerge (Bogdan the Nightflame)
    [33465] = true, -- Dummy (Bogdan the Nightflame)
    [33313] = true, -- Swipe (Bogdan the Nightflame)
    [33461] = true, -- Empower (Bogdan the Nightflame)
    [33346] = true, -- Burn Down (Bogdan the Nightflame)
    [33359] = true, -- Burn Down (Bogdan the Nightflame)
    [33432] = true, -- Daedric Flame (Bogdan the Nightflame)
    [68492] = true, -- Delay Pulverize (Bogdan the Nightflame)
    [33435] = true, -- Daedric Flame (Bogdan the Nightflame)
    [33436] = true, -- Daedric Flame (Bogdan the Nightflame)
    [33434] = true, -- Daedric Flame (Bogdan the Nightflame)
    [33480] = true, -- Pulverize (Bogdan the Nightflame)
    [68521] = true, -- Delay Daedric Flame
    [33492] = true, -- Pulverize (Bogdan the Nightflame)
    [68522] = true, -- Delay Daedric Flame
    [33494] = true, -- Pulverize (Bogdan the Nightflame)
    [68523] = true, -- Delay Daedric Flame
    [34255] = true, -- Shadow (Bogdan the Nightflame)
    [34260] = true, -- Shadow (Bogdan the Nightflame)
    [34263] = true, -- Summon Despair White (Bogdan the Nightflame)
    [34367] = true, -- Shadow (Bogdan the Nightflame)
    [48898] = true, -- Focused Healing (Bogdan the Nightflame)
    [48901] = true, -- Incite Fear (Bogdan the Nightflame)
    [61115] = true, -- DUN-EH-Screen Shake
    [35777] = true, -- Portal Closing
    [32514] = true, -- Q4675-Portal
    [33471] = true, -- Flare
    [82789] = true, -- Flare

    [34348] = true, -- Dummy (The Opus of Torment)
    [30455] = true, -- Arachnophobia (The Opus of Torment)

    -- City of Ash I
    [85743] = true, -- Teleport
    [34245] = true, -- Fireball
    [34257] = true, -- Intro
    [34126] = true, -- DUN_CA_Brute_Fire

    [29501] = true, -- Jab (Golor the Banekin Handler)
    [31101] = true, -- Cleave (Golor the Banekin Handler)
    [25034] = true, -- Crushing Blow (Golor the Banekin Handler)
    [25035] = true, -- Crushing Blow (Golor the Banekin Handler)
    [25036] = true, -- Crushing Blow (Golor the Banekin Handler)

    [33604] = true, -- Summon Banekin (Golor the Banekin Handler)
    [33612] = true, -- Scampintro (Golor the Banekin Handler)
    [33605] = true, -- Dummy (Golor the Banekin Handler)
    [33606] = true, -- Dummy (Golor the Banekin Handler)
    [33607] = true, -- Dummy (Golor the Banekin Handler)
    [45322] = true, -- Dummy (Golor the Banekin Handler)

    [34956] = true, -- Intro (Warden of the Shrine)
    [34963] = true, -- Projectile (Warden of the Shrine)
    [34589] = true, -- Light Swing (Warden of the Shrine)
    [34607] = true, -- Measured Uppercut (Warden of the Shrine)
    [34608] = true, -- Measured Uppercut (Warden of the Shrine)
    [34609] = true, -- Measured Uppercut (Warden of the Shrine)
    [46567] = true, -- Teleport Strike (Warden of the Shrine)
    [46569] = true, -- Teleport Strike (Warden of the Shrine)
    [46568] = true, -- Teleport Strike (Warden of the Shrine)
    [34654] = true, -- Fan of Flames (Warden of the Shrine)
    [34655] = true, -- Fan of Flames (Warden of the Shrine)
    [34656] = true, -- Fan of Flames (Warden of the Shrine)
    [34657] = true, -- Fan of Flames (Warden of the Shrine)
    [34658] = true, -- Fan of Flames (Warden of the Shrine)
    [34659] = true, -- Fan of Flames (Warden of the Shrine)
    [34660] = true, -- Fan of Flames (Warden of the Shrine)
    [34661] = true, -- Fan of Flames (Warden of the Shrine)
    [34662] = true, -- Fan of Flames (Warden of the Shrine)
    [34664] = true, -- Fan of Flames (Warden of the Shrine)
    [34665] = true, -- Fan of Flames (Warden of the Shrine)
    [34666] = true, -- Fan of Flames (Warden of the Shrine)
    [34653] = true, -- Fan of Flames (Warden of the Shrine)
    [34620] = true, -- Fan of Flames (Warden of the Shrine)
    [34621] = true, -- Fan of Flames (Warden of the Shrine)
    [34622] = true, -- Fan of Flames (Warden of the Shrine)
    [34624] = true, -- Fan of Flames (Warden of the Shrine)
    [34632] = true, -- Fan of Flames (Warden of the Shrine)
    [34633] = true, -- Fan of Flames (Warden of the Shrine)
    [34634] = true, -- Fan of Flames (Warden of the Shrine)
    [34635] = true, -- Fan of Flames (Warden of the Shrine)
    [34625] = true, -- Fan of Flames (Warden of the Shrine)
    [34959] = true, -- Blazing Fire (Warden of the Shrine)
    [34960] = true, -- Blazing Fire (Warden of the Shrine)

    [34352] = true, -- Fire Tornado (Infernal Guardian)
    [34168] = true, -- Double Slam (Infernal Guardian)
    [34169] = true, -- Double Slam (Infernal Guardian)
    [34190] = true, -- Thorny Backhand (Infernal Guardian)
    [8398] = true,  -- Bleeding (Infernal Guardian)
    [23074] = true, -- Bleeding (Infernal Guardian)
    [34189] = true, -- Ground Slam (Infernal Guardian)
    [44080] = true, -- Ground Slam (Infernal Guardian)
    [64243] = true, -- Ground Slam (Infernal Guardian)
    [44079] = true, -- Ground Slam (Infernal Guardian)
    [44090] = true, -- Generic Stagger Enemy (Infernal Guardian)
    [35061] = true, -- Consuming Fire (Infernal Guardian)
    [35062] = true, -- Consuming Fire (Infernal Guardian)
    [35147] = true, -- Snare (Infernal Guardian)
    [35063] = true, -- Anchor1 (Infernal Guardian)
    [35091] = true, -- Anchor1 (Infernal Guardian)
    [35122] = true, -- Anchor21 (Infernal Guardian)
    [35065] = true, -- Anchor2 (Infernal Guardian)
    [35066] = true, -- Anchor3 (Infernal Guardian)
    [35067] = true, -- Anchor4 (Infernal Guardian)
    [35068] = true, -- Anchor1 (Infernal Guardian)
    [35069] = true, -- Anchor1 (Infernal Guardian)
    [35070] = true, -- Anchor1 (Infernal Guardian)
    [35071] = true, -- Anchor1 (Infernal Guardian)
    [35072] = true, -- Anchor1 (Infernal Guardian)
    [35073] = true, -- Anchor1 (Infernal Guardian)
    [35082] = true, -- Anchor1 (Infernal Guardian)
    [35083] = true, -- Anchor1 (Infernal Guardian)
    [35084] = true, -- Anchor1 (Infernal Guardian)
    [35085] = true, -- Anchor1 (Infernal Guardian)
    [35086] = true, -- Anchor1 (Infernal Guardian)
    [35087] = true, -- Anchor1 (Infernal Guardian)
    [35088] = true, -- Anchor1 (Infernal Guardian)
    [35089] = true, -- Anchor1 (Infernal Guardian)
    [35090] = true, -- Anchor1 (Infernal Guardian)
    [35125] = true, -- Anchor12 (Infernal Guardian)
    [35124] = true, -- Anchor12 (Infernal Guardian)
    [35126] = true, -- Anchor12 (Infernal Guardian)
    [35127] = true, -- Anchor12 (Infernal Guardian)
    [35128] = true, -- Anchor12 (Infernal Guardian)
    [35064] = true, -- Fire Projectile (Infernal Guardian)
    [35074] = true, -- Damage Anchor (Infernal Guardian)
    [35144] = true, -- Fiery Explosion (Infernal Guardian)
    [35145] = true, -- Consuming Fire (Infernal Guardian)
    [34183] = true, -- Tunneling Roots (Infernal Guardian)
    [34184] = true, -- Ground Anchor (Infernal Guardian)
    [34185] = true, -- Projectile (Infernal Guardian)
    [34188] = true, -- Damage Anchor (Infernal Guardian)
    [34187] = true, -- Tunneling Roots (Infernal Guardian)
    [44089] = true, -- Generic Enemy Stagger (Infernal Guardian)

    [44278] = true, -- Lava Geyser (Dark Ember)
    [44274] = true, -- Lava Geyser (Dark Ember)
    [44277] = true, -- Lava Geyser (Dark Ember)
    [44276] = true, -- Lava Geyser (Dark Ember)

    [35409] = true, -- Dummy (Rothariel Flameheart)
    [34198] = true, -- Burning Field (Rothariel Flameheart
    [34199] = true, -- Burning Field (Rothariel Flameheart)
    [34200] = true, -- Burning Field (Rothariel Flameheart)
    [34201] = true, -- Burning Field (Rothariel Flameheart)
    [34202] = true, -- Burning Field (Rothariel Flameheart)
    [34204] = true, -- Burning Field (Rothariel Flameheart)
    [34222] = true, -- Spiderexplosion (Rothariel Flameheart)
    [34205] = true, -- Deception (Rothariel Flameheart)
    [34224] = true, -- Dummy (Rothariel Flameheart)
    [34226] = true, -- Dummy (Rothariel Flameheart)
    [34223] = true, -- Dummy (Rothariel Flameheart)

    [34456] = true, -- Portal
    [49136] = true, -- Oblivion Portal
    [34516] = true, -- Dummy

    [34904] = true, -- Dummy (Razor Master Erthas)
    [34788] = true, -- Quick Draw (Razor Master Erthas)
    [34901] = true, -- Blazing Arrow (Razor Master Erthas)
    [34948] = true, -- Burning Embers (Razor Master Erthas)
    [34949] = true, -- Burning Embers (Razor Master Erthas)
    [34805] = true, -- Release Flame (Razor Master Erthas)
    [34819] = true, -- Release Flame (Razor Master Erthas)

    [34799] = true, -- Lava Pitch (Release Flame)
    [34814] = true, -- Release Flame (Release Flame)
    [34806] = true, -- Release Flame (Release Flame)
    [34809] = true, -- Dummy (Release Flame)
    [34810] = true, -- Dummy (Release Flame)
    [34811] = true, -- Dummy (Release Flame)
    [34812] = true, -- Dummy (Release Flame)
    [34820] = true, -- Lava Pitch (Release Flame)
    [34953] = true, -- Blazing Embers (Release Flame)
    [34955] = true, -- Dummy (Release Flame)
    [34951] = true, -- Blazing Embers (Release Flame)

    [34623] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34626] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34776] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34637] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34777] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34640] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34778] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34642] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34779] = true, -- Summon Flame Atronach (Razor Master Erthas)
    [34579] = true, -- Dummy (Flame Atronach)
    [34600] = true, -- Dummy (Flame Atronach)
    [34602] = true, -- Dummy (Flame Atronach)
    [35379] = true, -- Flare (Flame Atronach)
    [34892] = true, -- Body of Flame (Razor Master Erthas)
    [34895] = true, -- Body of Flame (Razor Master Erthas)
    [34896] = true, -- Body of Flame (Razor Master Erthas)
    [34898] = true, -- Body of Flame (Razor Master Erthas)
    [34780] = true, -- Summon Flame Atranach (Razor Master Erthas)
    [34784] = true, -- Summon Flame Atranach (Razor Master Erthas)
    [34785] = true, -- Summon Flame Atranach (Razor Master Erthas)
    [34786] = true, -- Summon Flame Atranach (Razor Master Erthas)
    [34641] = true, -- Summon Flame Atranach (Razor Master Erthas)

    [49138] = true, -- Oblivion Portal
    [49137] = true, -- Oblivion Portal

    [85237] = true, -- Notes (Scroll of Glorious Battle)
    [70113] = true, -- Soul Scream (Scroll of Glorious Battle)

    -- City of Ash II
    [85930] = true, -- Teleport
    [56243] = true, -- Jump

    [56097] = true, -- Portal Fx
    [54032] = true, -- Add Threat
    [53952] = true, -- Body of Flame
    [56089] = true, -- Tele Spot Used
    [56090] = true, -- Body of Flame
    [53956] = true, -- Body of Flame
    [53954] = true, -- Body of Flame
    [53957] = true, -- Body of Flame
    [53989] = true, -- Dummy
    [56080] = true, -- Body of Flame
    [56085] = true, -- Body of Flame
    [56082] = true, -- Body of Flame
    [53999] = true, -- Summon
    [56081] = true, -- Body of Flame
    [56084] = true, -- Body of Flame
    [54126] = true, -- Minor Wound (Akezel)
    [54025] = true, -- Spell Absorption (Akezel)
    [53994] = true, -- Focused Healing (Akezel)
    [53996] = true, -- Health Boon (Akezel)
    [53988] = true, -- Quick Draw (Merruz)
    [54021] = true, -- Release Flame (Merruz)
    [54024] = true, -- Release Flame (Merruz)
    [54130] = true, -- Release Flame (Merruz)
    [54022] = true, -- Release Flame (Merruz)
    [54023] = true, -- Release Flame (Merruz)
    [54136] = true, -- Blazing Embers (Merruz)
    [54132] = true, -- Blazing Embers (Merruz)
    [54134] = true, -- Blazing Embers (Merruz)
    [54137] = true, -- Blazing Embers (Merruz)
    [54138] = true, -- Blazing Embers (Merruz)
    [54139] = true, -- Blazing Embers (Merruz)
    [54133] = true, -- Blazing Embers (Merruz)
    [57120] = true, -- Blazing Embers (Merruz)
    [53976] = true, -- Blazing Arrow (Merruz)
    [53978] = true, -- Burning Embers (Merruz)
    [53977] = true, -- Burning Embers (Merruz)
    [57119] = true, -- Burning Embers (Merruz)
    [54129] = true, -- Fire Chain (Rukhan)
    [54145] = true, -- Fire Chain (Rukhan)
    [54096] = true, -- Pyrocasm (Rukhan)
    [54098] = true, -- CON_Knockback&Knockdown (Rukhan)
    [54097] = true, -- Fire Backlash (Rukhan)

    [55010] = true, -- Fiery Entrance
    [56056] = true, -- Quick Shot Nerf Damage
    [56074] = true, -- Start Clone Spawn In
    [56811] = true, -- Pyrocasm (Xivilai Ravager)
    [56813] = true, -- CON_Knockback&Knockdown (Xivilai Ravager)
    [56812] = true, -- Fire Backlash (Xivilai Ravager)
    [55367] = true, -- Flame Conduit
    [55407] = true, -- Flame Conduit
    [56547] = true, -- Flame Conduit
    [55466] = true, -- Flame Conduit
    [55442] = true, -- Flame Conduit

    [55652] = true, -- Venomous Explosion (Venomous Skeleton)
    [55659] = true, -- Venomous Explosion (Venomous Skeleton)
    [55654] = true, -- Venomous Explosion (Venomous Skeleton)
    [55655] = true, -- Venomous Explosion (Venomous Skeleton)
    [55658] = true, -- Venomous Explosion (Venomous Skeleton)
    [55657] = true, -- Venomous Explosion (Venomous Skeleton)

    [55184] = true, -- Urata Spawn In
    [46222] = true, -- RobS Immunities .5 Sec (Urata the Legion)
    [56419] = true, -- Flare (Urata the Legion)
    [56414] = true, -- Fire Runes (Urata the Legion)
    [56607] = true, -- Fire Runes (Urata the Legion)
    [56608] = true, -- Fire Runes (Urata the Legion)
    [56609] = true, -- Fire Runes (Urata the Legion)
    [56415] = true, -- Fire Runes (Urata the Legion)
    [54225] = true, -- Multiply (Urata the Legion)
    [54228] = true, -- Summon Clones (Urata the Legion)
    [56115] = true, -- Clones Casted Stack (Urata the Legion)
    [56120] = true, -- Set Absorb CD (Urata the Legion)
    [54227] = true, -- Clone Beam (Clones)
    [54272] = true, -- Clone Spawn FX (Clones)
    [54273] = true, -- Clone Spawn In (Clones)
    [72285] = true, -- No Damage While Spawning (Clones)
    [54455] = true, -- Clone Less DMG (Clones)
    [54447] = true, -- Summon Clones (Clones)
    [54449] = true, -- Summon Clones (Clones)

    [54277] = true, -- Reunite (Urata the Legion)
    [56131] = true, -- Reunite (Urata the Legion)
    [54453] = true, -- Absorb Clones (Urata the Legion)
    [56134] = true, -- Reunite (Urata the Legion)
    [56420] = true, -- Reunite (Urata the Legion)
    [56440] = true, -- Set Clone CD (Urata the Legion)
    [54283] = true, -- Clone Absorbing (Clones)
    [54494] = true, -- Stun (Clones)
    [54451] = true, -- Shadow Heal (Urata the Legion)
    [54450] = true, -- Shadow Heal (Urata the Legion)
    [56388] = true, -- Shadow Heal (Urata the Legion)
    [56132] = true, -- Shadow Heal (Urata the Legion)

    [56098] = true, -- Multiply (Urata the Legion)
    [56099] = true, -- Summon Clones (Urata the Legion)
    [56121] = true, -- Set Absorb CD (Urata the Legion)
    [56100] = true, -- Summon Clones (Urata the Legion)
    [56101] = true, -- Summon Clones (Urata the Legion)
    [56103] = true, -- Summon Clones (Urata the Legion)

    [56104] = true, -- Multiply (Urata the Legion)
    [56105] = true, -- Summon Clones (Urata the Legion)
    [56122] = true, -- Set Absorb CD (Urata the Legion)
    [56106] = true, -- Summon Clones (Urata the Legion)
    [56107] = true, -- Summon Clones (Urata the Legion)
    [56108] = true, -- Summon Clones (Urata the Legion)
    [56110] = true, -- Summon Clones (Urata the Legion)

    [56172] = true, -- Fiery Entrance
    [61201] = true, -- Melt Up
    [55728] = true, -- Scamp Spawn
    [56173] = true, -- Scamps
    [55434] = true, -- 30% Speed Buff
    [56178] = true, -- Gauntlet NPC Add Threat
    [56186] = true, -- Voice to Wake the Dead (Flame Colossus)
    [56187] = true, -- Voice to Wake the Dead (Flame Colossus)
    [56188] = true, -- Voice to Wake the Dead (Flame Colossus)
    [56189] = true, -- Voice to Wake the Dead (Flame Colossus)
    [86753] = true, -- Bone Flare (Flame Colossus)
    [55744] = true, -- Bone Flare (Flame Colossus)
    [56442] = true, -- Flame Conduit (Gilraen)

    [56055] = true, -- Jagged Claw (Horvantud the Fire Maw)
    [56054] = true, -- Fiery Jaws (Horvantud the Fire Maw)
    [56307] = true, -- Fiery Jaws (Horvantud the Fire Maw)
    [55203] = true, -- Seismic Tremor (Horvantud the Fire Maw)
    [56032] = true, -- Ground Tremor (Horvantud the Fire Maw)
    [56043] = true, -- Seismic Tremor (Horvantud the Fire Maw)
    [56036] = true, -- Ground Tremor (Horvantud the Fire Maw)
    [56037] = true, -- Ground Tremor (Horvantud the Fire Maw)
    [56038] = true, -- Ground Tremor (Horvantud the Fire Maw)
    [56039] = true, -- Ground Tremor (Horvantud the Fire Maw)
    [56040] = true, -- Ground Tremor (Horvantud the Fire Maw)
    [56034] = true, -- Tremor (Horvantud the Fire Maw)
    [56264] = true, -- Stagger (Horvantud the Fire Maw)
    [56265] = true, -- Tremor (Horvantud the Fire Maw)

    [56002] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56012] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56011] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56006] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56004] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56013] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56014] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56003] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56023] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56015] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56016] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56021] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56022] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56024] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56027] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56007] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56019] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56020] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56008] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56017] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56018] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56010] = true, -- Ground Quake (Horvantud the Fire Maw)
    [56009] = true, -- Ground Quake (Horvantud the Fire Maw)
    [55648] = true, -- VDUN_CoA_B1 Add Jump Down (Adds)
    [56069] = true, -- Add Bruiser (Adds)
    [56070] = true, -- Add Bruiser (Adds)
    [56071] = true, -- Add Bruiser (Adds)
    [56072] = true, -- Add Bruiser (Adds)
    [56073] = true, -- Add Bruiser (Adds)

    [55312] = true, -- Slag Breath (Horvantud the Fire Maw)
    [56091] = true, -- Slag Breath (Horvantud the Fire Maw)
    [55315] = true, -- Slag Breath (Horvantud the Fire Maw)
    [55313] = true, -- Slag Breath (Horvantud the Fire Maw)
    [55319] = true, -- Slag Breath (Horvantud the Fire Maw)
    [55314] = true, -- Slag Breath (Horvantud the Fire Maw)
    [55318] = true, -- Slag Breath (Horvantud the Fire Maw)
    [55333] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [56086] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [55334] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [55320] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [56092] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [55321] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [55335] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [56087] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [55336] = true, -- Fiery Breath (Horvantud the Fire Maw)

    [55326] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [56093] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [55327] = true, -- Fiery Breath (Horvantud the Fire Maw)

    [55337] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [56088] = true, -- Fiery Breath (Horvantud the Fire Maw)
    [55338] = true, -- Fiery Breath (Horvantud the Fire Maw)

    [55324] = true, -- Enrage 2 (Horvantud the Fire Maw)
    [55325] = true, -- Enrage 2 Tracker (Horvantud the Fire Maw)
    [55332] = true, -- Remove Enrage 1 (Horvantud the Fire Maw)
    [55330] = true, -- Remove Enrage 1 (Horvantud the Fire Maw)
    [55322] = true, -- Enrage 2 Bonus (Horvantud the Fire Maw)
    [55323] = true, -- Can Enrage Go 3 (Horvantud the Fire Maw)
    [55329] = true, -- Enrage 3 (Horvantud the Fire Maw)
    [55328] = true, -- Enrage 3 Bonus (Horvantud the Fire Maw)
    [55331] = true, -- Remove Enrage 2 (Horvantud the Fire Maw)
    [57618] = true, -- Damage Shield (Horvantud the Fire Maw)
    [55724] = true, -- Clean Up (Horvantud the Fire Maw)
    [55675] = true, -- VDUN-CoA-B1 Add Stealth Despaw (Horvantud the Fire Maw)

    [56191] = true, -- Bone Flare
    [56190] = true, -- Snare

    [54760] = true, -- VDUN-CoA-B2 Fly In Intro (Ash Titan)
    [54763] = true, -- VDUN-CoA-B2 Fly In Intro (Ash Titan)
    [54764] = true, -- Backdraft (Ash Titan)
    [54767] = true, -- Backdraft (Ash Titan)
    [54768] = true, -- Backdraft (Ash Titan)
    [56194] = true, -- Knockdown (Ash Titan)
    [56197] = true, -- Fire Backlash (Ash Titan)

    [54267] = true, -- Lava Bolt (Ash Titan)
    [54270] = true, -- Lava Bolt (Ash Titan)
    [54269] = true, -- Ethereal Flame (Ash Titan)
    [56151] = true, -- Ethereal Flame (Ash Titan)
    [56152] = true, -- Ethereal Flame (Ash Titan)

    [54218] = true, -- Monstrous Cleave (Ash Titan)
    [54224] = true, -- Monstrous Cleave (Ash Titan)
    [54223] = true, -- Monstrous Cleave (Ash Titan)
    [54222] = true, -- Monstrous Cleave (Ash Titan)
    [61214] = true, -- Monstrous Cleave (Ash Titan)
    [54221] = true, -- Monstrous Cleave (Ash Titan)
    [54266] = true, -- Cleave (Ash Titan)

    [54895] = true, -- Molten Rain (Ash Titan)
    [54913] = true, -- Molten Rain (Ash Titan)
    [56096] = true, -- Molten Rain (Ash Titan)
    [54973] = true, -- Molten Rain (Ash Titan)
    [55179] = true, -- Molten Rain (Ash Titan)
    [54915] = true, -- Molten Rain (Ash Titan)
    [54920] = true, -- Molten Rain (Ash Titan)
    [55176] = true, -- Molten Rain (Ash Titan)
    [55177] = true, -- Molten Rain (Ash Titan)
    [55128] = true, -- Molten Rain (Ash Titan)
    [55129] = true, -- Molten Rain (Ash Titan)
    [55130] = true, -- Molten Rain (Ash Titan)
    [55178] = true, -- Molten Rain (Ash Titan)
    [55175] = true, -- Molten Rain (Ash Titan)
    [56094] = true, -- Molten Rain (Ash Titan)
    [56095] = true, -- Molten Rain (Ash Titan)

    [54698] = true, -- Fire Swarm (Ash Titan)
    [54857] = true, -- Random Target (Ash Titan)
    [54858] = true, -- Knockback (Ash Titan)
    [54873] = true, -- Heavy Slash (Ash Titan)

    [54856] = true, -- Wing Burst (Ash Titan)
    [54855] = true, -- Shockwave (Ash Titan)
    [56145] = true, -- Shockwave (Ash Titan)
    [56144] = true, -- Shockwave (Ash Titan)
    [54859] = true, -- Stagger (Ash Titan)
    [54874] = true, -- Shockwave (Ash Titan)

    [54699] = true, -- Fire Swarm (Ash Titan)
    [54648] = true, -- Fire Swarm (Ash Titan)
    [54861] = true, -- Fire Swarm (Ash Titan)
    [54663] = true, -- Fire Swarm (Ash Titan)
    [54664] = true, -- Fire Swarm (Ash Titan)
    [54665] = true, -- Fire Swarm (Ash Titan)
    [54666] = true, -- Fire Swarm (Ash Titan)
    [54667] = true, -- Fire Swarm (Ash Titan)
    [54650] = true, -- Fire Swarm (Ash Titan)
    [54668] = true, -- Fire Swarm (Ash Titan)
    [54863] = true, -- Fire Swarm (Ash Titan)
    [54864] = true, -- Fire Swarm (Ash Titan)
    [54865] = true, -- Fire Swarm (Ash Titan)
    [54866] = true, -- Fire Swarm (Ash Titan)
    [54867] = true, -- Fire Swarm (Ash Titan)
    [54860] = true, -- Fire Swarm (Ash Titan)
    [54862] = true, -- Fire Swarm (Ash Titan)
    [54868] = true, -- Fire Swarm (Ash Titan)
    [54654] = true, -- Fire Swarm (Ash Titan)
    [56375] = true, -- Fire Swarm (Ash Titan)
    [56309] = true, -- Fire Swarm (Ash Titan)
    [56357] = true, -- Fire Swarm (Ash Titan)
    [56358] = true, -- Fire Swarm (Ash Titan)
    [56369] = true, -- Fire Swarm (Ash Titan)
    [56359] = true, -- Fire Swarm (Ash Titan)
    [56361] = true, -- Fire Swarm (Ash Titan)
    [56360] = true, -- Fire Swarm (Ash Titan)
    [56362] = true, -- Fire Swarm (Ash Titan)
    [56363] = true, -- Fire Swarm (Ash Titan)
    [56364] = true, -- Fire Swarm (Ash Titan)
    [56367] = true, -- Fire Swarm (Ash Titan)
    [56366] = true, -- Fire Swarm (Ash Titan)
    [56365] = true, -- Fire Swarm (Ash Titan)
    [56368] = true, -- Fire Swarm (Ash Titan)
    [56370] = true, -- Fire Swarm (Ash Titan)
    [56373] = true, -- Fire Swarm (Ash Titan)
    [56371] = true, -- Fire Swarm (Ash Titan)
    [56372] = true, -- Fire Swarm (Ash Titan)
    [56374] = true, -- Fire Swarm (Ash Titan)

    [56314] = true, -- Damage Shield (Ash Titan)
    [58468] = true, -- Shadow Cloak (Ash Titan)
    [54779] = true, -- Air Take Flame (Air Atronach)
    [54780] = true, -- Air Take Flame (Air Atronach)
    [54781] = true, -- Boss (Air Atronach)
    [54786] = true, -- VDUN_CoA_B2_Air Take Flame (Air Atronach)
    [54787] = true, -- Air Take Flame (Air Atronach)
    [54783] = true, -- Air Atronach Flame (Air Atronach)
    [54788] = true, -- Remove Blood Lust (Air Atronach)
    [56318] = true, -- Cooldowns (Ash Titan)
    [56319] = true, -- Cooldown2 (Ash Titan)

    [54366] = true, -- Flame Tornado (Air Atronach)
    [56312] = true, -- Flame Tornado (Air Atronach)
    [60683] = true, -- Flame Tornado (Air Atronach)
    [54367] = true, -- Flame Tornado (Air Atronach)
    [54370] = true, -- Flame Tornado Snare (Air Atronach)
    [56313] = true, -- Flame Tornado (Air Atronach)
    [54790] = true, -- Swipe (Air Atronach)
    [54791] = true, -- Swipe (Air Atronach)

    [55707] = true, -- Fiery Entrance
    [55725] = true, -- Scamps
    [55618] = true, -- VDUN_CoA_B3 Flame Atr Spawn In
    [2616] = true,  -- NPC Run Away Theater Speed
    [55215] = true, -- Capture Point

    [56227] = true, -- Fiery Entrace (Xivilai Fulminator / Boltaic)
    [56229] = true, -- Fiery Entrace (Xivilai Fulminator / Boltaic)
    [56231] = true, -- Fiery Entrace (Xivilai Fulminator / Boltaic)
    [56230] = true, -- Scamps (Xivilai Fulminator / Boltaic)
    [56232] = true, -- Scamps (Xivilai Fulminator / Boltaic)
    [56228] = true, -- Scamps (Xivilai Fulminator / Boltaic)
    [56591] = true, -- Shocking Entry (Xivilai Fulminator / Boltaic)
    [58280] = true, -- Scary Summon 1 (Xivilai Fulminator / Boltaic)
    [58281] = true, -- Scary Summon 1 (Xivilai Fulminator / Boltaic)
    [56601] = true, -- Scary Summon 2 (Xivilai Fulminator / Boltaic)
    [58279] = true, -- Scary Summon 2 (Xivilai Fulminator / Boltaic)

    [31171] = true, -- Frontflip
    [56651] = true, -- Flame Shield (Gilrean)

    [55879] = true, -- Lava Spout IdleFX
    [55783] = true, -- Slag Geyser
    [55800] = true, -- Slag Geyser
    [55792] = true, -- Slag Geyser
    [55784] = true, -- Slag Geyser
    [55801] = true, -- Slag Geyser
    [55793] = true, -- Slag Geyser
    [55759] = true, -- Slag Geyser
    [55798] = true, -- Slag Geyser
    [55790] = true, -- Slag Geyser
    [55786] = true, -- Slag Geyser
    [55787] = true, -- Slag Geyser
    [55788] = true, -- Slag Geyser
    [55794] = true, -- Slag Geyser
    [55796] = true, -- Slag Geyser
    [55797] = true, -- Slag Geyser
    [55802] = true, -- Slag Geyser
    [55804] = true, -- Slag Geyser
    [55805] = true, -- Slag Geyser
    [56068] = true, -- Slag Geyser

    [55513] = true, -- Flame Bolt (Valkyn Skoria)
    [55573] = true, -- Flame Bolt Knockdown (Valkyn Skoria)
    [55574] = true, -- Meteor Strike (Valkyn Skoria)
    [55575] = true, -- Meteor Strike (Valkyn Skoria)

    [55387] = true, -- Meteor Strike (Valkyn Skoria)
    [55758] = true, -- Meteor Strike (Valkyn Skoria)
    [56167] = true, -- Meteor Strike (Valkyn Skoria)
    [55757] = true, -- Meteor Strike (Valkyn Skoria)
    [55505] = true, -- Meteor (Valkyn Skoria)
    [55503] = true, -- Meteor (Valkyn Skoria)
    [55391] = true, -- Meteor Strike (Valkyn Skoria)
    [55390] = true, -- Meteor Strike (Valkyn Skoria)
    [55504] = true, -- Meteor (Valkyn Skoria)
    [55506] = true, -- Meteor (Valkyn Skoria)
    [55502] = true, -- Meteor (Valkyn Skoria)

    [55382] = true, -- Flame Strike (Valkyn Skoria)
    [55383] = true, -- Flame Strike (Valkyn Skoria)

    [55514] = true, -- Call the Flames (Valkyn Skoria)
    [55559] = true, -- Call the Flames (Valkyn Skoria)
    [55755] = true, -- Call the Flames (Valkyn Skoria)
    [55566] = true, -- Crackling Earth (Valkyn Skoria)
    [55568] = true, -- Crackling Earth (Valkyn Skoria)
    [55567] = true, -- Crackling Earth (Valkyn Skoria)
    [55564] = true, -- Crackling Earth (Valkyn Skoria)
    [55569] = true, -- Crackling Earth (Valkyn Skoria)
    [55565] = true, -- Crackling Earth (Valkyn Skoria)
    [55572] = true, -- Heat Wave (Valkyn Skoria)
    [55756] = true, -- Burning (Valkyn Skoria)

    [55426] = true, -- Magma Prison (Valkyn Skoria)
    [55463] = true, -- Magma Prison (Valkyn Skoria)
    [55464] = true, -- Magma Prison Track (Valkyn Skoria)
    [55458] = true, -- Magma Prison (Valkyn Skoria)
    [55429] = true, -- Magma Prison (Valkyn Skoria)
    [55468] = true, -- Magma Prison (Valkyn Skoria)
    [56296] = true, -- Magma Prison (Valkyn Skoria)
    [56383] = true, -- Magma Prison (Valkyn Skoria)
    [60644] = true, -- Magma Prison (Valkyn Skoria)
    [55469] = true, -- Magma Prison (Valkyn Skoria)
    [56297] = true, -- Magma Prison (Valkyn Skoria)

    [55030] = true, -- Leap to Center
    [55031] = true, -- Can Quake
    [55024] = true, -- Lava Quake
    [55032] = true, -- Lava Quake
    [55134] = true, -- Test
    [56549] = true, -- Lava Quake
    [56242] = true, -- Block Spout
    [58506] = true, -- Expl Sound
    [55133] = true, -- Can Teleport
    [55059] = true, -- Body of Flame
    [55062] = true, -- Body of Flame
    [55061] = true, -- Body of Flame
    [55060] = true, -- Body of Flame
    [55593] = true, -- Can Flame Shield
    [55497] = true, -- Rock Shield
    [55500] = true, -- Rock Shield
    [55632] = true, -- Add Ticking
    [55623] = true, -- Flame Atronach
    [55622] = true, -- Rock Shield
    [55499] = true, -- Rock Shield
    [55498] = true, -- Flame Spit
    [56305] = true, -- Flame Atro Add
    [55501] = true, -- Rock Shield
    [56239] = true, -- Rock Shield
    [56240] = true, -- Rock Shield
    [56241] = true, -- Rock Shield
    [56548] = true, -- Platform Detonation
    [56551] = true, -- Lava Quake
    [52008] = true, -- Destroy Sigil Stone

    [56564] = true, -- Book (Frigid Tome)
    [56562] = true, -- Book (Frigid Tome)
    [56563] = true, -- Book (Frigid Tome)

    -- Tempest Island
    [85791] = true, -- Teleport
    [28012] = true, -- Fireball
    [43049] = true, -- Fireball
    [23542] = true, -- Block

    [46732] = true, -- Sonic Scream
    [46738] = true, -- Piercing Shriek
    [46737] = true, -- Piercing Shriek

    [26653] = true, -- Introdummy
    [26313] = true, -- Lightning Hand
    [26674] = true, -- Introcloud
    [31097] = true, -- Dummy
    [26676] = true, -- IntroKB
    [26678] = true, -- Staggering Roar

    [42948] = true, -- VF_Boss1_Twisted_Steel (Sudden Storm)
    [26604] = true, -- Storm (Sudden Storm)
    [26619] = true, -- Shock (Sudden Storm)
    [46110] = true, -- Dummy (Sudden Storm)

    [26332] = true, -- Slash (Valaran Stormcaller)
    [26370] = true, -- Crushing Blow (Valaran Stormcaller)
    [26371] = true, -- Crushing Blow (Valaran Stormcaller)
    [26372] = true, -- Crushing Blow (Valaran Stormcaller)
    [26628] = true, -- Enervating Bolt (Valaran Stormcaller)
    [26631] = true, -- Enervating Bolt (Valaran Stormcaller)
    [26592] = true, -- Lightning Avatar (Valaran Stormcaller)

    [28391] = true, -- Q4538 Stoen Explosion (Conduit Stone)
    [32451] = true, -- Fire Backlash (Conduit Stone)

    [5696] = true,  -- Backstab (Yalorasse the Speaker)
    [5699] = true,  -- Backstab (Yalorasse the Speaker)
    [5698] = true,  -- Backstab (Yalorasse the Speaker)
    [5697] = true,  -- Backstab (Yalorasse the Speaker)

    [6106] = true,  -- Lightning Storm (Yalorasse the Speaker)
    [6108] = true,  -- Lightning Storm (Yalorasse the Speaker)
    [6107] = true,  -- Lightning Storm (Yalorasse the Speaker)

    [29063] = true, -- Poisoned Blade (Yalorasse the Speaker)
    [29064] = true, -- Crimson Web Poison (Yalorasse the Speaker)

    [26761] = true, -- Lightning Call
    [26776] = true, -- TCloud
    [26767] = true, -- Lightning Call
    [31579] = true, -- IntroKB
    [34357] = true, -- Intro End

    [26743] = true, -- Left Cross (Stormfist)
    [26714] = true, -- Skyward Slam (Stormfist)
    [26716] = true, -- Skyward Slam (Stormfist)
    [26715] = true, -- Skyward Slam (Stormfist)
    [27263] = true, -- Skyward Slam (Stormfist)

    [26748] = true, -- Enervating Stone (Stormfist)
    [46122] = true, -- Enervating Stone (Stormfist)
    [33212] = true, -- Enervating Stone (Stormfist)
    [26752] = true, -- Enervating Stone (Stormfist)
    [26938] = true, -- Enervating Stone (Stormfist)

    [26833] = true, -- Summon Storm Atronach (Stormfist)
    [26837] = true, -- Summon Storm Atronach (Stormfist)
    [26849] = true, -- Summon Storm Atronach (Stormfist)
    [26839] = true, -- Summon Storm Atronach (Stormfist)
    [26850] = true, -- Summon Storm Atronach (Stormfist)
    [26854] = true, -- Summon Storm Atronach (Stormfist)
    [26853] = true, -- Summon Storm Atronach (Stormfist)
    [26851] = true, -- Summon Storm Atronach (Stormfist)
    [26836] = true, -- Summon Storm Atronach (Stormfist)
    [26838] = true, -- Summon Storm Atronach (Stormfist)

    [26790] = true, -- Unstable Explosion (Stormfist)
    [26791] = true, -- Dummy (Stormfist)

    [27039] = true, -- Ethereal Chain (Commodore Ohmanil)
    [27058] = true, -- Ethereal Chain (Commodore Ohmanil)

    [27624] = true, -- Wind Storm
    [29144] = true, -- Q4538-Death From Above
    [46106] = true, -- DUN_TI3 Neider Intro Self FX

    [26534] = true, -- Sparking Strike
    [27596] = true, -- Lightning Strike

    [26741] = true, -- Swift Wind
    [26746] = true, -- Wind Charge
    [26759] = true, -- Swift Wind

    [26712] = true, -- Gust of Wind
    [46810] = true, -- Gust of Wind
    [46809] = true, -- Gust of Wind

    [26514] = true, -- Twister (Twister)
    [11184] = true, -- Windy Movement (Twister)
    [26517] = true, -- Electrical Shock (Twister)
    [26515] = true, -- Been Hit (Twister)
    [46808] = true, -- Stagger (Twister)

    -- Selene's Web
    [85833] = true, -- Teleport
    [64548] = true, -- Flare
    [64549] = true, -- Flare
    [32431] = true, -- Climb Away
    [32428] = true, -- Climb Away

    [30909] = true, -- Ensnare
    [31249] = true, -- Ensnare
    [46648] = true, -- Ensnare
    [31247] = true, -- Ensnare
    [49275] = true, -- Ensnare
    [31248] = true, -- Ensnare
    [30922] = true, -- Ensnare
    [31251] = true, -- Ensnare
    [64171] = true, -- SW_Boss3_WebGrip
    [30907] = true, -- Summon Primal Swarm
    [30908] = true, -- Summon Primal Swarm

    [33601] = true, -- Q4733_Torture

    [31085] = true, -- Trap (Trap)
    [31086] = true, -- Trap (Trap)

    [64761] = true, -- Fast (Longclaw)
    [31091] = true, -- Invisibility (Longclaw)
    [30781] = true, -- Mirror Ward (Longclaw)
    [30785] = true, -- Quick Shot (Longclaw)
    [30772] = true, -- Arrow Rain (Longclaw)
    [30774] = true, -- Arrow Rain (Longclaw)
    [30773] = true, -- Arrow Rain (Longclaw)
    [31024] = true, -- Senche Spirits (Longclaw)
    [46570] = true, -- Senche Spirits (Longclaw)
    [46571] = true, -- Senche Spirits (Longclaw)
    [30779] = true, -- Spirit Form (Senche Spirit)

    [30801] = true, -- Poison Shot (Longclaw)
    [30802] = true, -- Poison Shot (Longclaw)
    [30803] = true, -- Poison Shot (Longclaw)
    [60670] = true, -- Poison Shot (Longclaw)

    [31096] = true, -- Poison Burst (Longclaw)
    [31154] = true, -- Poison Burst (Longclaw)
    [31150] = true, -- Poison Burst (Longclaw)

    [43968] = true, -- Roll Dodge (Longclaw)
    [43973] = true, -- Roll Dodge (Longclaw)
    [30925] = true, -- Roll Dodge (Longclaw)

    [34520] = true, -- Q4733_Locked_Door_Effect

    [31202] = true, -- Venomous Burst (Queen Aklayah)
    [31205] = true, -- Venomous Burst (Queen Aklayah)
    [31203] = true, -- Venomous Burst (Queen Aklayah)
    [46647] = true, -- Nocom (Queen Aklayah)

    [47057] = true, -- Fast (Foulhide)
    [30982] = true, -- Swipe (Foulhide)

    [30996] = true, -- Vicious Maul (Foulhide)
    [46879] = true, -- Fire Backlash (Foulhide)
    [46878] = true, -- CON_Knockback&Knockdown (Foulhide)

    [31001] = true, -- Horrifying Roar (Foulhide)

    [30812] = true, -- Trampling Charge (Foulhide)
    [30813] = true, -- Trampling Charge (Foulhide)
    [30986] = true, -- Trampling Charge (Foulhide)
    [30989] = true, -- Trampling Charge (Foulhide)
    [31368] = true, -- Stun (Foulhide)
    [30987] = true, -- Trampling Charge (Foulhide)
    [30988] = true, -- Been Hit (Foulhide)
    [46895] = true, -- Knocked Down (Foulhide)
    [31366] = true, -- Emboldened (Foulhide)

    [31002] = true, -- Intro (Selene's Rose)
    [31003] = true, -- Lunge (Selene's Rose)
    [9039] = true,  -- Snare (Selene's Rose)

    [31241] = true, -- Summon Spiders (Mennir Many-Legs)
    [31245] = true, -- Dummy (Mennir Many-Legs)
    [31242] = true, -- Summon Spiders (Mennir Many-Legs)

    [46683] = true, -- Dummy

    [31189] = true, -- Bite (Selene)
    [31183] = true, -- Rending Venom (Selene)
    [31186] = true, -- Rending Venom (Selene)
    [31048] = true, -- Web Wrap (Selene)
    [31052] = true, -- Web Wrap (Selene)
    [31469] = true, -- Web Wrap (Selene)
    [31054] = true, -- Web Wrap (Selene)
    [31049] = true, -- Web Wrap (Selene)
    [31180] = true, -- Free Ally (Selene)

    [59486] = true, -- Shield (Selene)
    [59487] = true, -- Shield (Selene)
    [30991] = true, -- Webport (Selene)
    [35558] = true, -- Exoburst (Selene)
    [35561] = true, -- Encase (Selene)
    [35598] = true, -- Dummy (Selene)
    [35826] = true, -- Webmove (Selene)
    [46682] = true, -- Nocom (Selene)
    [46681] = true, -- Nocom (Selene)
    [58521] = true, -- Web (Selene)
    [35824] = true, -- DUN_SW_Boss3_Pullplayer (Selene)
    [33347] = true, -- Webbreakfx (Selene)
    [59488] = true, -- Remove Shield (Selene)

    [31190] = true, -- Transform into Bosmer (Selene)
    [31191] = true, -- Transform into Bosmer (Selene)
    [33559] = true, -- Transform into Bosmer (Selene)
    [31218] = true, -- Spiderexplosion (Selene)
    [85188] = true, -- 25% More Max Health (Adds)
    [85189] = true, -- 25% More Max Health (Adds)
    [31986] = true, -- Summon Melee (Adds)
    [31984] = true, -- Summon Melee (Adds)
    [31985] = true, -- Summon Melee (Adds)

    [30723] = true, -- Dummy (Ghostbear)
    [30728] = true, -- Summon Primal Spirit (Selene)
    [30731] = true, -- Summon Primal Spirit (Selene)
    [30725] = true, -- Dummy (Ghostbear)
    [30724] = true, -- Dummy (Ghostbear)
    [30730] = true, -- Summon Primal Spirit (Selene)
    [30970] = true, -- Summon Primal Spirit (Selene)
    [30969] = true, -- Summon Primal Spirit (Selene)

    [30968] = true, -- Bash (Selene)

    [30890] = true, -- Dummy (Selene)
    [30883] = true, -- Summon Senche Spirit (Selene)
    [30896] = true, -- Summon Senche Spirit (Selene)
    [30887] = true, -- Leap (Spectral Senche-Tiger)
    [49184] = true, -- Dummy (Selene)
    [30905] = true, -- IntroKB (Spectral Senche-Tiger)
    [30901] = true, -- Primal Leap (Spectral Senche-Tiger)

    [33860] = true, -- Q4733_Siphon

    -- Spindleclutch I
    [85714] = true, -- Teleport
    [18184] = true, -- Q4054 Torch Burn
    [46147] = true, -- Summon Swarm (Spindlekin)

    [21777] = true, -- Webdrop
    [17957] = true, -- Bite (Swarm Mother)
    [22034] = true, -- Inject Poison (Swarm Mother)
    [22035] = true, -- Inject Poison (Swarm Mother)
    [22087] = true, -- Inject Poison (Swarm Mother)
    [22086] = true, -- Inject Poison (Swarm Mother)
    [17964] = true, -- Impeding Webs (Swarm Mother)
    [34422] = true, -- Impeding Webs (Swarm Mother)
    [32080] = true, -- Impeding Webs (Swarm Mother)
    [21827] = true, -- Impeding Webs (Swarm Mother)
    [17965] = true, -- Impeding Webs (Swarm Mother)
    [17960] = true, -- Arachnid Leap (Swarm Mother)
    [20642] = true, -- Poisoned Fang (Swarm Mother)
    [18559] = true, -- Spawn Broodlings (Swarm Mother)

    [18690] = true, -- Fighter's Boon

    [18363] = true, -- Fiery Reach (Big Rabbu)
    [18365] = true, -- Grapple (Big Rabbu)

    [29985] = true, -- Whispers (The Whisperer)
    [33355] = true, -- Combat Walk (The Whisperer)

    [18076] = true, -- Impale (The Whisperer)
    [18111] = true, -- Arachnophobia (The Whisperer)
    [18116] = true, -- Arachnophobia (The Whisperer)
    [47981] = true, -- Webdrop (The Whisperer)

    [18078] = true, -- Web Blast (The Whisperer)
    [46218] = true, -- Fire Backlash (The Whisperer)
    [46219] = true, -- Web Blast (The Whisperer)

    [35572] = true, -- Grappling Web (The Whisperer)
    [35599] = true, -- Can Cast Explosion (The Whisperer)
    [35574] = true, -- Stun Picker (The Whisperer)
    [35575] = true, -- Grappling Web (The Whisperer)

    [18058] = true, -- Daedric Explosion (The Whisperer)
    [22033] = true, -- Daedric Explosion (The Whisperer)
    [22032] = true, -- Daedric Explosion Knockback (The Whisperer)

    -- Spindleclutch II
    [85897] = true, -- Teleport
    [29820] = true, -- Dummy
    [28749] = true, -- Intro

    [27922] = true, -- Claw (Blood Spawn)
    [27923] = true, -- Claw (Blood Spawn)

    [28093] = true, -- Vicious Smash (Blood Spawn)
    [47139] = true, -- Knockdown (Blood Spawn)
    [47140] = true, -- Knockdown (Blood Spawn)

    [47151] = true, -- Leap to Center (Blood Spawn)
    [47154] = true, -- Leap to Center (Blood Spawn)
    [47145] = true, -- Has Charged (Blood Spawn)
    [44594] = true, -- Sound Initial (Blood Spawn)
    [27995] = true, -- Cave-In (Blood Spawn)
    [28006] = true, -- Cave In (Blood Spawn)
    [64975] = true, -- Cave In Bonus (Blood Spawn)
    [40046] = true, -- Sound Level 1 (Blood Spawn)
    [47198] = true, -- Falling Rocks (Blood Spawn)
    [40047] = true, -- Sound Level 2 (Blood Spawn)
    [40048] = true, -- Sound Level 3 (Blood Spawn)
    [40049] = true, -- Sound Level 4 (Blood Spawn)

    [47331] = true, -- Cave-In (Blood Spawn)
    [47332] = true, -- Cave-In (Blood Spawn)
    [64979] = true, -- Cave In Bonus (Blood Spawn)

    [31611] = true, -- Crusing Rocks (Cave In)
    [87373] = true, -- Crusing Rocks (Cave In)

    [59598] = true, -- Smoke Bomb
    [59597] = true, -- Smoke Bomb

    [27764] = true, -- Dark Ritual (Praxin Douare)
    [27765] = true, -- Dummy (Praxin Douare)
    [27820] = true, -- Dummy (Praxin Douare)
    [28620] = true, -- Dummy (Praxin Douare)

    [28438] = true, -- Dummy (Praxin Douare)
    [47122] = true, -- Praxin's Nightmare (Praxin Douare)
    [27768] = true, -- Dummy (Praxin Douare)

    [18036] = true, -- Grappling Web (The Whisperer Nightmare)
    [21635] = true, -- Grappling Web (The Whisperer Nightmare)
    [18054] = true, -- Entangled (The Whisperer Nightmare)
    [18051] = true, -- Encased (The Whisperer Nightmare)
    [18039] = true, -- Grappling Web (The Whisperer Nightmare)
    [21477] = true, -- Can Cast Daedric Explosion (The Whisperer Nightmare)

    [27955] = true, -- Dummy (Praxin Douare)
    [28002] = true, -- Dummy (Praxin Douare)

    [27750] = true, -- Distorted Bolt (Praxin Douare)
    [27965] = true, -- Despair (Praxin Douare)
    [27975] = true, -- Lava Quake (Praxin Douare)
    [27973] = true, -- Lava Quake (Praxin Douare)
    [27974] = true, -- Lava Quake (Praxin Douare)
    [27979] = true, -- Despair (Praxin Douare)

    [27741] = true, -- Enervating Seal (Praxin Douare)
    [27748] = true, -- Enervating Seal (Praxin Douare)
    [27743] = true, -- Enervating Seal (Praxin Douare)
    [27744] = true, -- Enervating Seal (Praxin Douare)
    [27742] = true, -- Enervating Seal (Praxin Douare)

    [27703] = true, -- Harrowing Ring (Praxin Douare)
    [61443] = true, -- Harrowing Ring (Praxin Douare)
    [61442] = true, -- Harrowing Ring (Praxin Douare)
    [28406] = true, -- Dummy (Blood Essence)
    [61445] = true, -- Dummy (Blood Essence)
    [73016] = true, -- Dummy (Blood Essence)
    [27650] = true, -- Harrowing Ring (Blood Essence)
    [27684] = true, -- Dummy (Blood Essence)
    [27709] = true, -- Harrowing Ring (Blood Essence)
    [27653] = true, -- Dummy (Blood Essence)

    [86418] = true, -- Harrowing Ring (Harrowing Ring)
    [27655] = true, -- Harrowing Ring (Harrowing Ring)
    [27716] = true, -- Dummy (Blood Essence)
    [43176] = true, -- Shocked (Blood Essence)
    [61444] = true, -- Shocked (Blood Essence)
    [43173] = true, -- DUN_SCH_RingBurst (Blood Essence)

    [58502] = true, -- Invisibility
    [29782] = true, -- Cocooned

    [29828] = true, -- Dummy (Flesh Atronach)
    [61202] = true, -- Claw Buff Damage (Flesh Atronach)
    [27435] = true, -- Monstrous Growth (Flesh Atronach)
    [27436] = true, -- Monstrous Growth (Flesh Atronach)
    [27447] = true, -- Monstrous Growth (Flesh Atronach)
    [27437] = true, -- Monstrous Growth (Flesh Atronach)
    [27438] = true, -- Monstrous Growth (Flesh Atronach)
    [27448] = true, -- Monstrous Growth (Flesh Atronach)

    [27600] = true, -- Blood Pool (Urvan Veleth)
    [27611] = true, -- Blood Pool (Urvan Veleth)
    [27603] = true, -- Blood Pool (Urvan Veleth)
    [27605] = true, -- Blood Pool (Urvan Veleth)

    [32100] = true, -- Arachnopbohia
    [28632] = true, -- Intro (Vorenor Winterbourne)

    [27660] = true, -- Blood Drain (Vorenor Winterbourne)
    [27707] = true, -- Blood Drain (Vorenor Winterbourne)

    [27905] = true, -- Blood Pool (Vorenor Winterbourne)
    [32357] = true, -- Blood Pool (Vorenor Winterbourne)
    [27906] = true, -- Blood Pool (Vorenor Winterbourne)
    [27907] = true, -- Blood Pool (Vorenor Winterbourne)
    [32652] = true, -- Blood Pool (Vorenor Winterbourne)

    [27897] = true, -- Open Wounds (Vorenor Winterbourne)
    [27898] = true, -- Open Wounds (Vorenor Winterbourne)

    [27791] = true, -- Blood Frenzy (Vorenor Winterbourne)
    [27792] = true, -- Blood Frenzy (Vorenor Winterbourne)
    [27799] = true, -- Blood Frenzy (Vorenor Winterbourne)
    [33106] = true, -- Blood Frenzy (Vorenor Winterbourne)

    [31672] = true, -- Thrall Feast (Vorenor Winterbourne)
    [31669] = true, -- Shielded (Vorenor Winterbourne)
    [31663] = true, -- Restrained (Vorenor Winterbourne)
    [31674] = true, -- Thrall Feast (Vorenor Winterbourne)
    [31684] = true, -- Thrall Feast (Vorenor Winterbourne)
    [31685] = true, -- Thrall Feast (Vorenor Winterbourne)
    [31673] = true, -- Thrall Feast (Vorenor Winterbourne)
    [31686] = true, -- Thrall Feast (Vorenor Winterbourne)
    [31687] = true, -- Thrall Feast (Vorenor Winterbourne)
    [31688] = true, -- Thrall Feast (Vorenor Winterbourne)
    [31689] = true, -- Thrall Feast (Vorenor Winterbourne)
    [47120] = true, -- Death of the Suffering (Captive)
    [47118] = true, -- Death of the Suffering (Captive)

    -- Wayrest Sewers I
    [85732] = true, -- Teleport

    [34846] = true, -- Primal Sweep (Slimecraw)
    [34847] = true, -- Primal Sweep (Slimecraw)
    [34848] = true, -- Primal Sweep (Slimecraw)
    [34849] = true, -- Primal Sweep (Slimecraw)

    [14927] = true, -- Desecrate Soul (Investigator Garron)
    [14946] = true, -- Tormented summoning (WRBoss3 Invisible Man)

    [11712] = true, -- Death's Embrace (Investigator Garron)
    [9441] = true,  -- Dark Lance (Investigator Garron)
    [48933] = true, -- Backlash (Investigator Garron)
    [48932] = true, -- Backlash (Investigator Garron)
    [25593] = true, -- Summon Necrotic Orb (Investigator Garron)
    [25585] = true, -- WS_Boss1_Orb (Necrotic Orb)
    [25586] = true, -- Seeking Orb (Necrotic Orb)
    [25620] = true, -- Dummy (Necrotic Orb)
    [25591] = true, -- Necrotic Essence (Necrotic Orb)
    [25616] = true, -- Necrotic Explosion (Necrotic Orb)

    [9463] = true,  -- Summon Restless Souls (Investigator Garron)
    [35146] = true, -- Dummy (Investigator Garron)
    [9740] = true,  -- Tormented Summoning (Restless Soul)
    [48208] = true, -- CON_MagicExplosionLarge (Restless Soul)
    [9481] = true,  -- Growing Torment (Restless Soul)

    [12247] = true, -- Terrifying Roar (Uulgarg the Hungry)
    [58528] = true, -- Terrifying Roar (Uulgarg the Hungry)
    [35647] = true, -- Nocom (Uulgarg the Hungry)

    [14969] = true, -- Slash (Varaine Pellingare)
    [25548] = true, -- Smite (Varaine Pellingare)
    [25550] = true, -- CON_Knockback&Knockdown (Varaine Pellingare)
    [25549] = true, -- Fire Backlash (Varaine Pellingare)

    [9648] = true,  -- Spinning Clave (Varaine Pellingare)
    [9651] = true,  -- Spinning Clave (Varaine Pellingare)

    [36436] = true, -- Dummy (Varaine Pellingare)
    [25523] = true, -- Tidal Slash (Varaine Pellingare)
    [36435] = true, -- Tidal Slash (Varaine Pellingare)
    [25531] = true, -- Tidal Slash (Varaine Pellingare)
    [25530] = true, -- Tidal Slash (Varaine Pellingare)
    [36442] = true, -- Tidal Slash (Varaine Pellingare)
    [36444] = true, -- Tidal Slash (Varaine Pellingare)
    [9656] = true,  -- Poisoned Blade (Varaine Pellingare)

    [11739] = true, -- Strike (Allene Pellingare)
    [11752] = true, -- Penetrating Daggers (Allene Pellingare)
    [35051] = true, -- Penetrating Daggers (Allene Pellingare)
    [35050] = true, -- Penetrating Daggers (Allene Pellingare)
    [11747] = true, -- Razor Flourish (Allene Pellingare)

    [34991] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35006] = true, -- Hallucinogenic Fumes (Allene Pellingare)
    [34992] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35012] = true, -- Mind-Bending Mist (Allene Pellingare)
    [34994] = true, -- Mind-Bending Mist (Allene Pellingare)
    [34993] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35333] = true, -- CON_SmokeBurst (Fiendish Hallucination)
    [35003] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35004] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35005] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [34995] = true, -- Mind-Bending Mist (Allene Pellingare)
    [73034] = true, -- Mind-Bending Mist (Allene Pellingare)

    [35015] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35021] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35025] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35320] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35017] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35020] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35016] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35018] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35019] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35026] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35027] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35022] = true, -- Mind-Bending Mist (Allene Pellingare)
    [73035] = true, -- Mind-Bending Mist (Allene Pellingare)

    [35028] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35041] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35033] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35322] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35029] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35034] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35035] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35036] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35037] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35038] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35039] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35040] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35042] = true, -- Mind-Bending Mist (Fiendish Hallucination)
    [35030] = true, -- Mind-Bending Mist (Allene Pellingare)
    [73036] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35043] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35044] = true, -- Mind-Bending Mist (Allene Pellingare)
    [35075] = true, -- Ghost Burst (Allene Pellingare)
    [35107] = true, -- Ghost Burst (Allene Pellingare)

    -- Wayrest Sewers II
    [85915] = true, -- Teleport
    [61183] = true, -- Throw Dagger Nerf Damage (Skeletal Warrior)
    [42893] = true, -- Q4813 Yahyif Open Sickies Door (Yahyif)
    [43933] = true, -- Phased (Malubeth the Scourger)
    [47257] = true, -- Rend Soul (Altar Dummy)

    [36412] = true, -- Ethereal Bolt (Malubeth the Scourger)
    [36613] = true, -- Scourging Spark (Malubeth the Scourger)
    [36614] = true, -- Scourging Spark (Malubeth the Scourger)
    [36615] = true, -- Scourging Spark (Malubeth the Scourger)
    [36617] = true, -- Scourging Spark (Malubeth the Scourger)
    [36621] = true, -- Scourging Spark (Malubeth the Scourger)
    [36625] = true, -- Scourging Spark (Malubeth the Scourger)
    [36430] = true, -- Rend Soul (Malubeth the Scourger)
    [36433] = true, -- Rend Soul (Malubeth the Scourger)
    [36431] = true, -- Rend Soul (Malubeth the Scourger)
    [36577] = true, -- Rend Soul (Malubeth the Scourger)
    [47267] = true, -- Rend Soul2 (Malubeth the Scourger)
    [36533] = true, -- Rend Soul (Malubeth the Scourger)

    [35573] = true, -- DUN_WSH Zombie Leader (Zombie Harbringer)

    [36951] = true, -- Voice to Wake the Dead (Skull Reaper)
    [36952] = true, -- Voice to Wake the Dead (Risen Dead)
    [36953] = true, -- Voice to Wake the Dead (Risen Dead)
    [36954] = true, -- Voice to Wake the Dead (Risen Dead)
    [36956] = true, -- Channel Energy (Risen Dead)
    [36991] = true, -- Channel Energy (Risen Dead)
    [48769] = true, -- Channel Energy (Risen Dead)
    [36966] = true, -- Channel Energy (Risen Dead)
    [48768] = true, -- Channel Energy (Risen Dead)
    [48773] = true, -- Necromantic Burst (Risen Dead)
    [48772] = true, -- Necromantic Burst (Risen Dead)

    [36868] = true, -- Scorching Flames (Uulgarg the Risen)
    [36870] = true, -- Scorching Flames (Uulgarg the Risen)
    [36875] = true, -- Scorching Flames (Uulgarg the Risen)
    [50782] = true, -- Scorching Flames (Uulgarg the Risen)
    [36871] = true, -- Scorching Flames (Uulgarg the Risen)
    [36869] = true, -- Scorching Flames (Uulgarg the Risen)

    [36792] = true, -- Yahyif runs to Doom (Yahyif)
    [36791] = true, -- Frontflip (Yahyif)
    [37253] = true, -- Necrotic Bolt (Garron the Returned)
    [36709] = true, -- Necrotic Bolt (Garron the Returned)
    [36904] = true, -- Necrotic Barrage (Garron the Returned)
    [48716] = true, -- No Com (Garron the Returned)
    [36907] = true, -- Necrotic Barrage (Garron the Returned)
    [36909] = true, -- Necrotic Barrage (Garron the Returned)
    [36942] = true, -- Necrotic Barrage (Garron the Returned)
    [36944] = true, -- Necrotic Barrage (Garron the Returned)
    [36761] = true, -- Summon Minion (Garron the Returned)
    [36773] = true, -- Summon Minion (Garron the Returned)
    [48733] = true, -- Summon Minion (Garron the Returned)
    [48734] = true, -- Summon Minion (Garron the Returned)
    [48735] = true, -- Summon Minion (Garron the Returned)
    [36776] = true, -- Necrotic Spike (Garron the Returned)
    [36779] = true, -- Necrotic Burst (Garron the Returned)
    [36782] = true, -- Transform (Garron the Returned)
    [36780] = true, -- Summon Minion (Garron the Returned)

    [36838] = true, -- Deceptive Teleport (Garron the Returned)
    [36863] = true, -- Deceptive Teleport (Garron the Returned)
    [36867] = true, -- Deceptive Teleport (Garron the Returned)
    [36873] = true, -- Consume Life (Garron the Returned)
    [36877] = true, -- Consume Life (Garron the Returned)
    [36878] = true, -- Consume Life (Garron the Returned)

    [36895] = true, -- Haunting Spectre (The Forgotten One)
    [36905] = true, -- Haunting Spectre (The Forgotten One)
    [36906] = true, -- Haunting Spectre (The Forgotten One)
    [36897] = true, -- Haunting Spectre (The Forgotten One)
    [36900] = true, -- Haunting Spectre (The Forgotten One)

    [42901] = true, -- Varaine (Varaine Pellingare)
    [42902] = true, -- Allene (Allene Pellingare)
    [47007] = true, -- Nocom (Allene & Varaine Pellingare)

    [36413] = true, -- Quick Strike (Varaine Pellingare)
    [49159] = true, -- Cone of Rot (Varaine Pellingare)
    [49161] = true, -- Cone of Rot (Varaine Pellingare)
    [49160] = true, -- Cone of Rot (Varaine Pellingare)
    [36534] = true, -- Spinning Cleave (Varaine Pellingare)
    [36535] = true, -- Spinning Cleave (Varaine Pellingare)
    [36396] = true, -- Bludgeon (Varaine Pellingare)
    [36397] = true, -- Bludgeon (Varaine Pellingare)
    [36398] = true, -- Bludgeon (Varaine Pellingare)

    [36536] = true, -- Shield Sibling (Allene & Varaine Pellingare)
    [36537] = true, -- Shield Sibling (Allene & Varaine Pellingare)

    [49060] = true, -- PrisonCast (Allene Pellingare)
    [49074] = true, -- PrisonCast (Allene Pellingare)
    [49051] = true, -- Pellingare Prison (Allene Pellingare)
    [49052] = true, -- Pellingare Prison (Allene Pellingare)
    [49053] = true, -- Toxic Fumes (Allene Pellingare)
    [49058] = true, -- Dummy (Allene Pellingare)
    [49059] = true, -- Dummycheck (Allene Pellingare)
    [49054] = true, -- Untargetdummy (Allene Pellingare)
    [49107] = true, -- Dummy (Allene Pellingare)
    [72443] = true, -- RemoveInvis (Allene Pellingare)
    [49055] = true, -- Dummy (Allene Pellingare)
    [49127] = true, -- MOD CD (Allene Pellingare)
    [36378] = true, -- Quick Draw (Allene Pellingare)
    [35838] = true, -- Necrotic Arrow (Allenge Pellingare)
    [35839] = true, -- Necrotic Arrow (Allenge Pellingare)
    [43511] = true, -- Remove Buffs (Player)
    [36876] = true, -- DUN_WSH Kill Pel (Gedric Serre - Theater)

    -- Crypt of Hearts I
    [85749] = true,  -- Teleport (Crypt of Hearts I)
    [39126] = true,  -- Soul Prison (Shard of Alanwe)

    [22341] = true,  -- Frenzy (Zombie Stalker)
    [39827] = true,  -- Capture (Zombie)

    [22666] = true,  -- Dead (Zombie)
    [22713] = true,  -- Phantasmal Bolt (Archmaster Siniel)
    [22714] = true,  -- Necrotic Ritual (Archmaster Siniel)
    [22715] = true,  -- Necrotic Ritual (Archmaster Siniel)
    [22716] = true,  -- Necrotic Ritual (Archmaster Siniel)
    [22768] = true,  -- Induce Horror (Archmaster Siniel)
    [22770] = true,  -- Induce Horror (Archmaster Siniel)
    [32096] = true,  -- Induce Horror (Archmaster Siniel)
    [35979] = true,  -- Induce Horror (Archmaster Siniel)

    [46578] = true,  -- Teleport (Archmaster Siniel)
    [46581] = true,  -- Daedric Step (Archmaster Siniel)
    [46580] = true,  -- Daedric Step (Archmaster Siniel)
    [46579] = true,  -- Daedric Step (Archmaster Siniel)
    [22668] = true,  -- Awaken Dead (Archmaster Siniel)
    [46585] = true,  -- Wall of Souls (Archmaster Siniel)
    [22779] = true,  -- Corpse Shield (Archmaster Siniel)
    [22808] = true,  -- Corpse Shield (Archmaster Siniel)
    [32255] = true,  -- Corpse Shield (Archmaster Siniel)

    [32256] = true,  -- 5 (Archmaster Siniel)
    [32257] = true,  -- 4 (Archmaster Siniel)
    [32258] = true,  -- 3 (Archmaster Siniel)
    [32259] = true,  -- 2 (Archmaster Siniel)
    [22787] = true,  -- Corpse Explosion (Archmaster Siniel)
    [22807] = true,  -- Corpse Explosion (Archmaster Siniel)
    [22806] = true,  -- Corpse Explosion (Archmaster Siniel)
    [22702] = true,  -- Get Up (Zombie)
    [22704] = true,  -- Swipe (Zombie)

    [22588] = true,  -- Ground Rise (Death's Leviathan)
    [22488] = true,  -- Backhand (Death's Leviathan)
    [46947] = true,  -- Trample (Death's Leviathan)
    [111957] = true, -- Trample (Death's Leviathan)
    [46957] = true,  -- Trample (Death's Leviathan)
    [46953] = true,  -- Trample (Death's Leviathan)
    [46949] = true,  -- Damage Disabler (Death's Leviathan)
    [46952] = true,  -- Knocked Down (Death's Leviathan)
    [22527] = true,  -- Paralyzing Slam (Death's Leviathan)
    [22535] = true,  -- Paralyzing Slam (Death's Leviathan)
    [22476] = true,  -- Run to Fire Pile (Death's Leviathan)
    [46679] = true,  -- Immolate (Death's Leviathan)
    [46680] = true,  -- Immolate Colossus (Death's Leviathan)
    [46954] = true,  -- Fire Trail (Death's Leviathan)
    [46951] = true,  -- Fire Trail (Death's Leviathan)
    [46950] = true,  -- Fire Trail (Death's Leviathan)
    [46948] = true,  -- Fire Trail (Death's Leviathan)
    [23693] = true,  -- Paralyzing Slam (Death's Leviathan)
    [23685] = true,  -- Paralyzing Slam (Death's Leviathan)
    [22576] = true,  -- Paralyzing Slam (Death's Leviathan)
    [46674] = true,  -- Paralyzing Slam (Death's Leviathan)
    [46673] = true,  -- Paralyzing Slam (Death's Leviathan)
    [46677] = true,  -- Paralyzing Slam (Death's Leviathan)
    [46675] = true,  -- Paralyzing Slam (Death's Leviathan)
    [22491] = true,  -- Ignited (Death's Leviathan)
    [111923] = true, -- Ignited (Death's Leviathan)

    [39286] = true,  -- Tormenting Blade (Rulanir)
    [25345] = true,  -- Q4379-Anguish Snare (Faindor)
    [25346] = true,  -- Fireball (Faindor)
    [59615] = true,  -- Alanwe's Prison (Alanwe)

    [22301] = true,  -- Cleaving Swing (Ilambris-Athor)
    [32425] = true,  -- Lightning Empowerment (Ilambris-Athor)
    [22450] = true,  -- Summon Lightning Rod (Ilambris-Athor)
    [22431] = true,  -- Lightning Rod (Ilambris-Athor)
    [22432] = true,  -- Electric Prison (Ilambris-Athor)
    [22338] = true,  -- Axe Strike (Ilambris-Athor)
    [46691] = true,  -- Fire Backlash (Ilambris-Athor)
    [46692] = true,  -- CON_Knockback&Knockdown (Ilambris-Athor)

    [22456] = true,  -- Lightning Omnipotence (Ilambris-Zaven)
    [33299] = true,  -- Center Picker (Ilambris-Zaven)
    [33297] = true,  -- Center of Room (Generic Invisible Target)
    [33300] = true,  -- Pillar Picker (Ilambris-Athor)
    [33298] = true,  -- Lightning Pillars (Ilambris-Athor)
    [52598] = true,  -- Pillar Picker (Ilambris-Athor)

    [22397] = true,  -- Call Lightning (Ilambris-Athor)
    [33295] = true,  -- Lightning (Ilambris Athor)
    [22399] = true,  -- Call Lightning (Ilambris-Athor)
    [22402] = true,  -- Call Lightning (Ilambris-Athor)
    [22404] = true,  -- Call Lightning (Ilambris-Athor)
    [22398] = true,  -- Call Lightning (Ilambris-Athor)
    [22401] = true,  -- Call Lightning (Ilambris-Athor)
    [22403] = true,  -- Call Lightning (Ilambris-Athor)

    [22302] = true,  -- Fire Bolt (Ilambris-Zaven)
    [22342] = true,  -- Rolling Fire (Ilambris-Zaven)
    [22344] = true,  -- Rolling Fire (Ilambris-Zaven)
    [32424] = true,  -- Incensed (Ilambris-Zaven)
    [32436] = true,  -- Incensed (Ilambris-Zaven)
    [32481] = true,  -- Incensed (Ilambris-Zaven)
    [22390] = true,  -- Pyrocasm (Ilambris-Zaven)
    [44087] = true,  -- Fire Backlash (Ilambris-Zaven)
    [44088] = true,  -- CON_Knockback&Knockdown (Ilambris-Zaven)
    [22457] = true,  -- Emit Flames (Ilambris-Zaven)
    [32444] = true,  -- Emit Flames (Ilambris-Zaven)
    [32482] = true,  -- Emit Flames (Ilambris-Zaven)
    [32443] = true,  -- Emit Flames (Ilambris-Zaven)
    [52604] = true,  -- Emit Flames (Ilambris-Zaven)
    [22383] = true,  -- Rain Fire (Ilambris-Zaven)
    [22386] = true,  -- Rain Fire (Ilambris-Zaven)
    [22388] = true,  -- Rain Fire (Ilambris-Zaven)

    [25662] = true,  -- Merging of the Shards (Alanwe)

    -- Crypt of Hearts II
    [85936] = true,  -- Teleport
    [21544] = true,  -- Generic Evil Lightning
    [52270] = true,  -- VDUN_CoH_Alanwe Knocback
    [52268] = true,  -- Knockback
    [51975] = true,  -- Portal
    [48892] = true,  -- Q4487 Mephala Spawn/Despawn
    [53523] = true,  -- Claw Buff Damage (Flesh Atronach)

    [51744] = true,  -- Summon the Dead (Spiderkith Broodnurse)
    [51747] = true,  -- Risen Spider (Spiderkith Broodnurse)
    [51746] = true,  -- Voice to Wake the Spiders (Spiderkith Broodnurse)
    [51745] = true,  -- VO Sound (Spiderkith Broodnurse)
    [51750] = true,  -- Desecrated Remains (Spiderkith Broodnurse)
    [51753] = true,  -- Reanimate Skeleton (Spiderkith Broodnurse)
    [51751] = true,  -- VO Sound (Spiderkith Broodnurse)
    [53866] = true,  -- CON_AncientGhostlyFlash (Alanwe)

    [52030] = true,  -- VDUN-CoH MiniBoss 01 InitAct
    [52151] = true,  -- Necromantic Circle (Ibelgast's Broodnurse)
    [52040] = true,  -- Summon Atronach (Ibelgast's Broodnurse)
    [52048] = true,  -- Summon Atronach (Ibelgast's Broodnurse)
    [52160] = true,  -- Flesh Atronach Rises (Ibelgast's Broodnurse)
    [52072] = true,  -- Summon Atronach (Ibelgast's Broodnurse)

    [53597] = true,  -- Strike Buff Damage (Ogrim)
    [53285] = true,  -- Summon (Ogrim)

    [52954] = true,  -- Spit (Ruzozuzalpamaz)
    [51882] = true,  -- Creeping Storm (Ruzozuzalpamaz)
    [53942] = true,  -- Storm Tracker (Ruzozuzalpamaz)
    [51881] = true,  -- Creeping Storm (Creeping Storm)
    [54321] = true,  -- Stun (Creeping Storm)
    [51895] = true,  -- Creeping Storm (Creeping Storm)
    [51883] = true,  -- Creeping Storm (Creeping Storm)
    [53337] = true,  -- Creeping Storm (Creeping Storm)
    [52017] = true,  -- Lightning Onslaught (Ruzozuzalpamaz)
    [52019] = true,  -- Lightning Onslaught (Ruzozuzalpamaz)
    [53390] = true,  -- Lightning Onslaught (Ruzozuzalpamaz)
    [52018] = true,  -- Lightning Onslaught (Ruzozuzalpamaz)

    [53779] = true,  -- Webdrop (Spider)
    [51410] = true,  -- Spider Swarm (Spider)

    [53101] = true,  -- Small Delay (Ruzozuzalpamaz)
    [51381] = true,  -- Chattering Web (Ruzozuzalpamaz)
    [51386] = true,  -- Web Wrap (Ruzozuzalpamaz)
    [51385] = true,  -- Spider Bites (Ruzozuzalpamaz)
    [51383] = true,  -- Remove Bolt (Ruzozuzalpamaz)
    [53141] = true,  -- ACT Tip (Ruzozuzalpamaz)
    [51388] = true,  -- Remove Web (Ruzozuzalpamaz)
    [51389] = true,  -- Free Ally (Ruzozuzalpamaz)
    [56566] = true,  -- VDUN_CoH_Boss1 Remove Web (Ruzozuzalpamaz)
    [56567] = true,  -- Remove Web (Ruzozuzalpamaz)

    [52296] = true,  -- Summon Skeletons (Spiderkith Broodnurse)
    [52374] = true,  -- Grab Targets (Spiderkith Broodnurse)
    [52298] = true,  -- Skeletons Emerge (Spiderkith Broodnurse)
    [52359] = true,  -- Projectile (Spiderkith Broodnurse)
    [52383] = true,  -- Rise Beam (Spiderkith Broodnurse)
    [51758] = true,  -- Feral Mage (Skeleton)
    [52800] = true,  -- Feral Mage (Skeleton)
    [52799] = true,  -- Feral Mage (Skeleton)
    [52110] = true,  -- Skelly Water Rise (Skeleton)

    [54620] = true,  -- Uppercut (Chamber Guardian)
    [54622] = true,  -- Uppercut (Chamber Guardian)
    [54621] = true,  -- Uppercut Stun (Chamber Guardian)
    [51719] = true,  -- Consuming Horror (Chamber Guardian)
    [51722] = true,  -- Consuming Horror (Chamber Guardian)
    [51721] = true,  -- Consuming Horror (Chamber Guardian)
    [51731] = true,  -- Consuming Horror (Chamber Guardian)
    [51728] = true,  -- Consuming Horror (Chamber Guardian)

    [53132] = true,  -- Burn Corpse (Alanwe)
    [111630] = true, -- Burn Corpse (Alanwe)
    [111629] = true, -- Burn Corpse (Alanwe)
    [111624] = true, -- Burn Corpse (Alanwe)

    [52544] = true,  -- Shocking Entrance (Ilambris-Athor)
    [52549] = true,  -- Fiery Entrance (Ilambris-Zaven)
    [52058] = true,  -- Shock Hop (Ilambris-Athor)
    [52065] = true,  -- Fire Hop (Ilambris-Zaven)

    [52064] = true,  -- Untargetdummy (Ilambris-Athor)
    [52060] = true,  -- Dummy (Ilambris-Athor)
    [52062] = true,  -- dummy (Ilambris-Athor)

    [52071] = true,  -- Untargetdummy (Ilambris-Zaven)
    [52067] = true,  -- Dummy (Ilambris-Zaven)
    [52069] = true,  -- dummy (Ilambris-Zaven)

    [52099] = true,  -- Action (Ilambris Amalgam - Theater)
    [52100] = true,  -- Action (Ilambris Amalgam - Theater)
    [52039] = true,  -- Ritual (Ilambris Amalgam - Theater)
    [111934] = true, -- Delay (Ilambris Amalgam - Theater)
    [52057] = true,  -- Ritual (Ilambris Amalgam - Theater)
    [111935] = true, -- Delay (Ilambris Amalgam - Theater)
    [52146] = true,  -- Bone Rise Theater (Ilambris Amalgam - Theater)

    [52167] = true,  -- Shock Form (Ilambris Amalgam)
    [53599] = true,  -- Shock Stomp (Ilambris Amalgam)
    [53598] = true,  -- CON_Knockback&Knockdown (Ilambris Amalgam)
    [53600] = true,  -- Summon Shock Skeleton (Ilambris Amalgam)
    [53601] = true,  -- Summon Shock Skeleton (Ilambris Amalgam)
    [52278] = true,  -- Call Lightning (Ilambris Amalgam)
    [52480] = true,  -- Find the Enemy (Ilambris Amalgam)
    [52284] = true,  -- Call Lightning (Ilambris Amalgam)
    [52282] = true,  -- Call Lightning (Ilambris Amalgam)
    [52283] = true,  -- Call Lightning (Ilambris Amalgam)
    [52481] = true,  -- Call Lightning (Ilambris Amalgam)
    [52279] = true,  -- Call Lightning (Ilambris Amalgam)
    [53475] = true,  -- Strike (Ilambris Amalgam)
    [52269] = true,  -- Bone Shock (Ilambris Amalgam)
    [52491] = true,  -- Thunder Fist (Ilambris Amalgam)
    [52492] = true,  -- Thunder Fist (Ilambris Amalgam)
    [53403] = true,  -- Thunder Fist (Ilambris Amalgam)

    [52166] = true,  -- Fire Form (Ilambris Amalgam)
    [53592] = true,  -- Pyrocasm (Ilambris Amalgam)
    [53591] = true,  -- CON_Knockback&Knockback (Ilambris Amalgam)
    [53472] = true,  -- %40 Self Snare (Ilambris Amalgam)
    [52420] = true,  -- Fiery Explosion (Ilambris Amalgam)
    [53496] = true,  -- Fiery Explosion (Ilambris Amalgam)
    [53593] = true,  -- Summon Flame Skeleton (Ilambris Amalgam)
    [53594] = true,  -- Summon Flame Skeleton (Ilambris Amalgam)
    [52266] = true,  -- Bone Flare (Ilambris Amalgam)
    [52285] = true,  -- Rain Fire (Ilambris Amalgam)
    [52324] = true,  -- Find the enemy (Ilambris Amalgam)
    [52325] = true,  -- Rain Fire (Ilambris Amalgam)
    [52286] = true,  -- Rain Fire (Ilambris Amalgam)
    [53400] = true,  -- Rain Fire (Ilambris Amalgam)
    [53405] = true,  -- Flaming Voice (Ilambris Amalgam)
    [53406] = true,  -- Flaming Voice (Ilambris Amalgam)
    [53495] = true,  -- Fiery Explosion (Ilambris Amalgam)
    [53425] = true,  -- Fiery Explosion (Ilambris Amalgam)
    [56847] = true,  -- Fiery Explosion (Ilambris Amalgam)
    [53497] = true,  -- VDUN_COH_B2 Telegraph (Ilambris Amalgam)
    [53426] = true,  -- Fiery Explosion (Ilambris Amalgam)
    [53428] = true,  -- Fiery Explosion (Ilambris Amalgam)
    [53427] = true,  -- Fiery Explosion (Ilambris Amalgam)

    [52334] = true,  -- Final Storm (Ilambris Amalgam)
    [53516] = true,  -- Boss Debuff (Ilambris Amalgam)
    [53454] = true,  -- Summons (Ilambris Amalgam)
    [53459] = true,  -- Flaming Voice (Ilambris Amalgam)
    [53460] = true,  -- Shocking Voice (Ilambris Amalgam)
    [53456] = true,  -- Flaming Voice (Ilambris Amalgam)
    [53457] = true,  -- Flaming Voice (Ilambris Amalgam)
    [53458] = true,  -- Shocking Voice (Ilambris Amalgam)
    [52413] = true,  -- VDUN-CoH2 B2 Final Storm (Ilambris Amalgam)
    [52478] = true,  -- Find the Enemy (Ilambris Amalgam)
    [52488] = true,  -- Find the Enemy (Ilambris Amalgam)
    [52337] = true,  -- Rain Fire (Ilambris Amalgam)
    -- [52341] = true,  -- Call Lightning (Ilambris Amalgam)
    [52343] = true,  -- Call Lightning (Ilambris Amalgam)
    [52344] = true,  -- Call Lightning (Ilambris Amalgam)
    [52487] = true,  -- Call Lightning (Ilambris Amalgam)
    [53431] = true,  -- Rain Fire (Ilambris Amalgam)
    [52335] = true,  -- Rain Fire (Ilambris Amalgam)
    [52341] = true,  -- Rain Fire (Ilambris Amalgam)
    [52339] = true,  -- Call Lightning (Ilambris Amalgam)

    [52583] = true,  -- Summon Skeletons (Mezeluth)
    [52587] = true,  -- Grab Targets (Mezeluth)
    [52585] = true,  -- Skeletons Emerge (Mezeluth)
    [52586] = true,  -- Skeletons Emerge (Mezeluth)
    [52584] = true,  -- Projectile (Mezeluth)
    [52590] = true,  -- Skeleton Stun Targetable (Mezeluth)
    [52589] = true,  -- Skeleton Stun (Mezeluth)
    [52594] = true,  -- Delay (Mezeluth)

    [54020] = true,  -- Away Off (Mezeluth)
    [55955] = true,  -- Away Off (Mezeluth)
    [61211] = true,  -- Away Off (Mezeluth)
    [55954] = true,  -- Flare (Mezeluth)

    [51090] = true,  -- Rise and Fall (Mezeluth)
    [55961] = true,  -- VDUN_COH_Dark Betrayal (Mezeluth)
    [55962] = true,  -- VDUN_COH_Dark Betrayal (Mezeluth)
    [53196] = true,  -- Stalking Void (Mezeluth)
    [51111] = true,  -- Rise and Fall (Mezeluth)
    [51798] = true,  -- Rise and Fall (Mezeluth)
    [53347] = true,  -- Rise and Fall (Mezeluth)
    [53346] = true,  -- Fulminating Void (Mezeluth)
    [53348] = true,  -- Fulminating Void (Mezeluth)
    [55960] = true,  -- VDUN_COH_Dark Betrayal (Mezeluth)
    [53200] = true,  -- Cold Strike (Mezeluth)
    [51799] = true,  -- Fulminating Void (Mezeluth)
    [51824] = true,  -- Rise and Fall (Mezeluth)
    [53349] = true,  -- Fulminating Void (Mezeluth)
    [51804] = true,  -- Fulminating Void (Mezeluth)
    [55947] = true,  -- Rise and Fall Far (Mezeluth)
    [53199] = true,  -- Fiery Grip (Mezeluth)

    [17202] = true,  -- Goblin Theater Leap (Alanwe)
    [17204] = true,  -- Goblin Path (Alanwe)
    [52613] = true,  -- Stop Healing (Ebony Blade)
    [52610] = true,  -- Soul Lust (Ebony Blade)
    [53097] = true,  -- Blade Obj React (Ebony Blade)
    [52611] = true,  -- Soul Lust (Ebony Blade)
    [52620] = true,  -- Soul Lust (Ebony Blade)
    [52606] = true,  -- Binding (Ebony Blade)
    [52618] = true,  -- Binding (Ebony Blade)
    [52617] = true,  -- Binding (Ebony Blade)
    [52621] = true,  -- Nerien'eth Spawn (Ebony Blade)

    [51877] = true,  -- Necrotic Spear (Nerien'eth)
    [51792] = true,  -- Necrotic Spear (Nerien'eth)
    [51953] = true,  -- Skull Swarm (Nerien'eth)

    [52080] = true,  -- Necrotic Swarm (Nerien'eth)
    [52084] = true,  -- Necrotic Swarm (Nerien'eth)
    [52081] = true,  -- Necrotic Swarm (Nerien'eth)
    [52086] = true,  -- Necrotic Swarm (Nerien'eth)

    -- begin temp
    [52085] = true, -- Necrotic Swarm (Nerien'eth)
    [52096] = true, -- Necrotic Swarm (Nerien'eth)
    [52082] = true, -- Cursed Ground (Nerien'eth)
    [52093] = true, -- Soul Surge (Nerien'eth)
    -- end temp

    [51539] = true, -- Necrotic Blast (Nerien'eth)
    [51542] = true, -- Necrotic Blast (Nerien'eth)
    [51541] = true, -- Necrotic Blast (Nerien'eth)
    [52942] = true, -- Necrotic Blast (Nerien'eth)
    [51545] = true, -- Necrotic Blast (Nerien'eth)
    [51543] = true, -- Necrotic Blast (Nerien'eth)
    [52935] = true, -- Charged Skull (Nerien'eth)

    [51853] = true, -- Soul Pulse (Nerien'eth)
    [51857] = true, -- Soul Pulse (Nerien'eth)
    [51855] = true, -- Soul Pulse (Nerien'eth)
    [55894] = true, -- Pulse Blocker (Nerien'eth)
    [51858] = true, -- Soul Pulse (Nerien'eth)
    [51854] = true, -- Soul Pulse (Nerien'eth)
    [51864] = true, -- Force Pulse (Nerien'eth)
    [51867] = true, -- Force Pulse (Nerien'eth)

    [51943] = true, -- Soul Summon (Nerien'eth)
    [51947] = true, -- Soul Pulse (Nerien'eth)
    [51945] = true, -- Soul Pulse (Nerien'eth)
    [51948] = true, -- Soul Pulse (Nerien'eth)
    [51944] = true, -- Soul Pulse (Nerien'eth)

    [51969] = true, -- Soul Sacrifice (Nerien'eth)
    [55054] = true, -- Soul Sacrifice (Nerien'eth)
    [52856] = true, -- Soul Sacrifice (Nerien'eth)
    [52192] = true, -- Tainted Soul (Nerien'eth)
    [60632] = true, -- Shadow Cloak (Nerien'eth)

    [51886] = true, -- Tainted Soul (Student / Wraith)
    [51888] = true, -- Tainted Soul (Student / Wraith)
    [51899] = true, -- Tainted Soul (Student / Wraith)
    [60633] = true, -- Shadow Cloak (Student / Wraith)
    [51900] = true, -- Boss (Student / Wraith)
    [51887] = true, -- Tainted Soul (Student / Wraith)
    [51936] = true, -- Tainted Soul (Student / Wraith)

    [53122] = true, -- Ice Bolt (Wraith)
    [53123] = true, -- Cold Strike (Wraith)
    [51878] = true, -- Cold Strike (Wraith)
    [51879] = true, -- Cold Strike (Wraith)
    [51880] = true, -- Double Strike (Wraith)

    [49105] = true, -- RobS 3 Sec -75 DMG (Nerien'eth)
    [52945] = true, -- Clean Up (Player)
    [52635] = true, -- Teleport (Nerien'eth)
    [52639] = true, -- Teleport (Nerien'eth)
    [52637] = true, -- Teleport (Nerien'eth)
    [52640] = true, -- Teleport (Nerien'eth)
    [52670] = true, -- Tainted Soul (Nerien'eth)

    [52642] = true, -- VDUN_CoH_Boss3 Take Blade (Nerien'eth)
    [52647] = true, -- VDUN_CoH_Boss3 Take Blade (Nerien'eth)
    [52652] = true, -- VDUN_CoH_Boss3 Take Blade (Nerien'eth)
    [60631] = true, -- Shadow Cloak (Nerien'eth)
    [52669] = true, -- Damage Shield (Nerien'eth)
    [52990] = true, -- VDUN_CoH_Boss3 Take Blade (Nerien'eth)
    [53161] = true, -- VDUN_CoH_Boss3 Take Blade (Nerien'eth)
    [53173] = true, -- Post Process (Nerien'eth)
    [52643] = true, -- VDUN_CoH_Boss3 Take Blade (Nerien'eth)
    [52978] = true, -- Shout (Nerien'eth)
    [53135] = true, -- RobS -100 DMG Perm (Nerien'eth)
    [53133] = true, -- Soul Cage (Soul Cage)
    [53174] = true, -- Post Process (Player)

    [52119] = true, -- Enervating Sheen (Nerien'eth)
    [52872] = true, -- Enervating Sheen (Nerien'eth)
    [52164] = true, -- Enervating Sheen (Nerien'eth)
    [52165] = true, -- Enervating Sheen (Nerien'eth)
    [52120] = true, -- Enervating Sheen (Nerien'eth)

    [52126] = true, -- Teleport (Nerien'eth)
    [52130] = true, -- Teleport (Nerien'eth)
    [52128] = true, -- Teleport (Nerien'eth)
    [52131] = true, -- Teleport (Nerien'eth)
    [52127] = true, -- Teleport (Nerien'eth)

    [52133] = true, -- Blood Lust (Nerien'eth)
    [52132] = true, -- Blood Lust (Nerien'eth)
    [52138] = true, -- Blood Lust (Nerien'eth)
    [52139] = true, -- Blood Lust (Nerien'eth)
    [52137] = true, -- Stop Healing (Nerien'eth)
    [52180] = true, -- RobS Immunities 6 Sec (Nerien'eth)
    [52143] = true, -- Blood Lust (Nerien'eth)

    [52181] = true, -- Remove Blood Lust (Nerien'eth)
    [52397] = true, -- Tracker (Nerien'eth)
    [53257] = true, -- Delay Lich Crystal (Nerien'eth)
    [53761] = true, -- Kneel Track (Nerien'eth)

    [52514] = true, -- Damage Shield (Nerien'eth)
    [52516] = true, -- Damage Shield (Nerien'eth)
    [52517] = true, -- Damage Shield (Nerien'eth)

    [53184] = true, -- Fight for Your Life (Nerien'eth)
    [53183] = true, -- Fight for Your Life (Nerien'eth)

    [53185] = true, -- Resist Necrosis (Nerien'eth)
    [53186] = true, -- Resist Necrosis (Nerien'eth)

    [53258] = true, -- Rage (Nerien'eth)
    [52513] = true, -- Remove Blood Lust (Nerien'eth)
    [52512] = true, -- Remove Blood Lust (Nerien'eth)
    [52687] = true, -- Remove Blood Lust (Nerien'eth)
    [52142] = true, -- Blood Execution (Nerien'eth)
    [52750] = true, -- Remove Blood Lust (Nerien'eth)
    [59572] = true, -- Blood Lust (Nerien'eth)

    [53153] = true, -- No Com (Nerien'eth)
    [53154] = true, -- Necrotic Barrage (Nerien'eth)
    [53156] = true, -- t (Nerien'eth)
    [53157] = true, -- Cursed Ground (Nerien'eth)
    [53152] = true, -- Soul Surge (Nerien'eth)

    [51988] = true, -- Lethal Stab (Nerien'eth)
    [52412] = true, -- Lethal Stab (Nerien'eth)
    [53442] = true, -- Lethal Stab (Nerien'eth)
    [53446] = true, -- Lethal Cut (Nerien'eth)
    [53181] = true, -- Keen Strike (Nerien'eth)
    [51993] = true, -- Heavy Slash (Nerien'eth)
    [51994] = true, -- Heavy Slash (Nerien'eth)
    [51995] = true, -- Heavy Slash (Nerien'eth)
    [51997] = true, -- Ebony Whirlwind (Nerien'eth)
    [53127] = true, -- Ebony Whirlwind (Nerien'eth)
    [52495] = true, -- Ebony Whirlwind (Nerien'eth)
    [52494] = true, -- Ebony Whirlwind (Nerien'eth)
    [53134] = true, -- Tortured Souls (Nerien'eth)

    [54142] = true, -- Soul Cages Opened
    [53939] = true, -- Fire
    [53997] = true, -- Aura of Mephala
    [53009] = true, -- VDUN-CoH Final Spell
    [53076] = true, -- VDUN-CoH Final Spell React

    -- Volenfell
    [85798] = true, -- Teleport
    [25649] = true, -- Debilitating Roar (Desert Lion)
    [26707] = true, -- BCrucible-Wave Spawner Leap (Quintus Verres)
    [25038] = true, -- Slash (Quintus Verres)
    [25031] = true, -- VF_Boss1_Twisted Steel (Quintus Verres)
    [25029] = true, -- Twisted Steel (Quintus Verres)
    [25030] = true, -- Twisted Steel (Quintus Verres)

    [25055] = true, -- Dummy (Quintus Verres)
    [25060] = true, -- Staffpickup (Quintus Verres)
    [25067] = true, -- VF_Boss1_StaffHold (Quintus Verres)
    [25138] = true, -- VF_Boss1_StaffHold (Quintus Verres)
    [29452] = true, -- Dummy (Quintus Verres)

    [32081] = true, -- Nova (Quintus Verres)
    [25142] = true, -- Burning Groud (Quintus Verres)
    [25420] = true, -- Burning Groud (Quintus Verres)
    [25143] = true, -- Burning Ground (Quintus Verres)
    [25151] = true, -- Summon Wraith (Quintus Verres)
    [25149] = true, -- Firebolt (Quintus Verres)
    [25167] = true, -- Stagger (Quintus Verres)

    [25299] = true, -- Dummy (Quintus Verres)
    [25189] = true, -- VF_Boss1_Transferbeam (Quintus Verres)
    [25337] = true, -- Essence (Quintus Verres)
    [25306] = true, -- Gargoyleleap (Quintus Verres)
    [25404] = true, -- VF_Boss1_Leapdummy (Quintus Verres)
    [46312] = true, -- VF_Boss1_Leapdummy (Quintus Verres)
    [46313] = true, -- Fire Backlash (Quintus Verres)
    [46314] = true, -- CON_Knockback&Knockdown (Quintus Verres)
    [29456] = true, -- Death (Quintus Verres)

    [25218] = true, -- Double Swipe (Monstrous Gargoyle)
    [25219] = true, -- Double Swipe (Monstrous Gargoyle)

    [25227] = true, -- Petrifying Bellow (Monstrous Gargoyle)
    [42930] = true, -- Petrifying Bellow (Monstrous Gargoyle)

    [25222] = true, -- Heaving Quake (Monstrous Gargoyle)
    [25223] = true, -- Heaving Quake (Monstrous Gargoyle)
    [27318] = true, -- Heaving Quake (Monstrous Gargoyle)

    [64230] = true, -- Axe (Dwarven Centurion)
    [24930] = true, -- Tail Swipe (Tremorscale)
    [25639] = true, -- Dummy (Tremorscale)
    [24961] = true, -- Rupture (Tremorscale)

    [25672] = true, -- Flame Burst (Boilbite)
    [25673] = true, -- Counter (Boilbite)
    [25674] = true, -- Flame Burst (Boilbite)
    [25675] = true, -- Flame Burst (Boilbite)
    [25676] = true, -- Flame Burst (Boilbite)
    [25677] = true, -- Flame Burst (Boilbite)

    [25650] = true, -- PFXdummy (Tremorscale)
    [25652] = true, -- Speed (Tremorscale)
    [25679] = true, -- Intro 3 (Tremorscale)
    [25688] = true, -- Dummy (Tremorscale)
    [25689] = true, -- Dummy (Tremorscale)

    [25655] = true, -- Explosive Bolt (Unstable Construct)
    [25659] = true, -- Countdown (Unstable Construct)
    [25660] = true, -- Explosion (Unstable Construct)

    [24857] = true, -- Bite (Tremorscale)
    [24744] = true, -- Hemorrhaging Tear (Tremorscale)
    [24748] = true, -- Hemorrhaging Tear (Tremorscale)
    [24750] = true, -- Hemorrhaging Tear (Tremorscale)

    [24777] = true, -- Tail Swipe (Tremorscale)
    [24780] = true, -- Fire Backlash (Tremorscale)
    [24781] = true, -- CON_Knockback&Knockdown (Tremorscale)

    [24901] = true, -- Rupture Find (Tremorscale)
    [25426] = true, -- Addsummon (Tremorscale)
    [25434] = true, -- Rupture (Tremorscale)
    [29165] = true, -- Rupture (Tremorscale)
    [29167] = true, -- Dummy (Tremorscale)

    [29164] = true, -- Rupture (Tremorscale)
    [29163] = true, -- Staggering Roar (Tremorscale)
    [29166] = true, -- CON_Knockback&Knockdown (Tremorscale)

    -- [60312] = true, -- Taunt Immne (The Guardian's Strength)

    [25229] = true, -- Barrage Function (The Guardian's Spark)
    [44118] = true, -- Barrage Function (The Guardian's Spark)
    [44116] = true, -- Barrage Function (The Guardian's Spark)
    [44117] = true, -- Barrage Function (The Guardian's Spark)
    [44115] = true, -- Barrage Function (The Guardian's Spark)
    [44113] = true, -- Barrage Function (The Guardian's Spark)

    [25221] = true, -- Green (The Guardian's Soul)
    [25262] = true, -- Hammer Strike (The Guardian's Soul)
    [58657] = true, -- Hammer Strike (The Guardian's Soul)
    [25263] = true, -- Decapitation Function (The Guardian's Soul)
    [25265] = true, -- Decapitation Function (The Guardian's Soul)
    [25264] = true, -- Decapitation Function (The Guardian's Soul)
    [25273] = true, -- Equilibrium Function (The Guardian's Soul)
    [25274] = true, -- Equilibrium Function (The Guardian's Soul)
    [25538] = true, -- Equilibrium Function (The Guardian's Soul)
    [25539] = true, -- Equilibrium Function (The Guardian's Soul)
    [25540] = true, -- Equilibrium Function (The Guardian's Soul)
    [25545] = true, -- Equilibrium Function (The Guardian's Soul)
    [25546] = true, -- Equilibrium Function (The Guardian's Soul)

    -- Frostvault
    [115316] = true, -- Weatherman

    [117286] = true, -- Rending Bleed (Coldsnap Goblin - Shared)
    [117486] = true, -- Bleed (Coldsnap Goblin - Shared)

    [109574] = true, -- Fire Power (Coldsnap Harrier)
    [109590] = true, -- Firepower (Coldsnap Harrier)
    [109584] = true, -- Firepower (Coldsnap Harrier)
    [120945] = true, -- Firepower (Coldsnap Harrier)

    [117298] = true, -- Quick Strike (Coldsnap Snowstalker)
    [117352] = true, -- Whirlwind (Coldsnap Snowstalker)
    [118540] = true, -- Whirlwind (Coldsnap Snowstalker)

    [117295] = true, -- Bite (Coldsnap Durzog)
    [117296] = true, -- Rend (Coldsnap Durzog)

    [117289] = true, -- Backhand (Coldsnap Ogre)
    [117290] = true, -- Shockwave (Coldsnap Ogre)
    [118491] = true, -- Shockwave (Coldsnap Ogre)
    [117292] = true, -- Off Balance (Coldsnap Ogre)
    [117291] = true, -- Stagger (Coldsnap Ogre)
    [117287] = true, -- Crushing Blow (Coldsnap Ogre)
    [117288] = true, -- Crushing Blow (Coldsnap Ogre)

    [117316] = true, -- Ice Arrow (Coldsnap Skysplitter)
    [117323] = true, -- Ice Comet (Coldsnap Skysplitter)
    [117326] = true, -- Ice Comet (Coldsnap Skysplitter)
    [117325] = true, -- Ice Comet (Coldsnap Skysplitter)
    [117327] = true, -- Ice Comet (Coldsnap Skysplitter)
    [117324] = true, -- Ice Comet (Coldsnap Skysplitter)

    [117309] = true, -- Cleave (Coldsnap Frostbiter)

    [117345] = true, -- Low Slash (Coldsnap Toothbreaker)
    [117346] = true, -- Low Slash (Coldsnap Toothbreaker)
    [114490] = true, -- Maim (Coldsnap Toothbreaker)

    [119246] = true, -- Border Chk (Icestalker)
    [110390] = true, -- Icestalker Target
    [110391] = true, -- Icestalker Target 2
    [118131] = true, -- Get Hit
    [118132] = true, -- Icestalker Targ Remove

    [109821] = true, -- Rock Toss (Icestalker)
    [109822] = true, -- Rock Toss (Icestalker)

    [109801] = true, -- Leaping Crush (Icestalker)
    [119417] = true, -- Add 2.5 to Ground Slam CD (Icestalker)
    [109803] = true, -- Leaping Crush (Icestalker)
    [109802] = true, -- Leaping Crush (Icestalker)
    [109804] = true, -- Leaping Crush (Icestalker)
    [109805] = true, -- Leaping Crush (Icestalker)

    [109827] = true, -- Boulder Toss (Icestalker)
    [109832] = true, -- Turn (Icestalker)
    [109830] = true, -- Boulder Toss (Icestalker)
    [109829] = true, -- Boulder Toss (Icestalker)
    [109828] = true, -- Boulder Toss (Icestalker)

    [109811] = true, -- Ground Slam (Icestalker)
    [109813] = true, -- Ground Slam (Icestalker)
    [109814] = true, -- Ground Slam (Icestalker)
    [109815] = true, -- Ground Slam (Icestalker)
    [109816] = true, -- Ground Slam (Icestalker)
    [109817] = true, -- Ground Slam (Icestalker)
    [109812] = true, -- Ground Slam (Icestalker)
    [109818] = true, -- Ground Slam (Icestalker)
    [109819] = true, -- Ground Slam (Icestalker)
    [116684] = true, -- Ground Slam (Icestalker)
    [109820] = true, -- Effected (Icestalker)

    [109800] = true, -- Slap (Icestalker)

    [109833] = true, -- Frenzied Pummeling (Icestalker)
    [115179] = true, -- Extra Damage to Monsters (Icestalker)
    [109834] = true, -- Lifting Strike (Icestalker)
    [109835] = true, -- Frenzied Pummeling (Icestalker)
    [109870] = true, -- Time (Icestalker)
    [109878] = true, -- Caster Stun (Icestalker)
    [109837] = true, -- Pummel (Icestalker)
    [118489] = true, -- Frenzied Pummeling (Icestalker)
    [117791] = true, -- Frenzied Pummeling (Icestalker)
    [120638] = true, -- Remove (Icestalker)
    [109838] = true, -- End Stun (Icestalker)
    [121824] = true, -- Frenzied Pummeling (Icestalker)

    [119249] = true, -- Teleport Failsafe (Border Chk)
    [119461] = true, -- Teleport Failsafe (Border Chk)
    [119254] = true, -- Teleport Failsafe (Border Chk)
    [119255] = true, -- Teleport Failsafe (Border Chk)
    [120795] = true, -- Teleport Failsafe (Border Chk)

    [109806] = true, -- Frozen Aura (Icestalker)
    [109807] = true, -- Snare Ticker (Icestalker)
    [109808] = true, -- Frostbite (Icestalker)
    [109810] = true, -- Frozen Aura (Icestalker)

    [83430] = true,  -- Skeletal Smash (Ice Wraith)
    [83435] = true,  -- Headbutt (Ice Wraith)
    [83454] = true,  -- Skeletal Smash (Ice Wraith)
    [83453] = true,  -- Skeletal Smash (Ice Wraith)

    -- [76993] = true, -- 35% Bonus Movement (Skeevaton)
    [116683] = true, -- U23-DUN1 B N Intro (Skeevaton)

    -------------------------------------
    -- CYRODIIL -------------------------
    -------------------------------------

    [109844] = true, -- Reach
    [39671] = true,  -- Emperorship Alliance Bonus I
    -- [182782] = true, -- Emperorship Alliance Bonus II
    -- [182783] = true, -- Emperorship Alliance Bonus III
    -- [182784] = true, -- Emperorship Alliance Bonus IV
    -- [182785] = true, -- Emperorship Alliance Bonus V
    -- [182786] = true, -- Emperorship Alliance Bonus VI
    [11346] = true,  -- Home Keep Bonus
    [11341] = true,  -- Enemy Keep Bonus I
    [11343] = true,  -- Enemy Keep Bonus II
    [11345] = true,  -- Enemy Keep Bonus III
    [11347] = true,  -- Enemy Keep Bonus IV
    [11348] = true,  -- Enemy Keep Bonus V
    [11350] = true,  -- Enemy Keep Bonus VI
    [11352] = true,  -- Enemy Keep Bonus VII
    [11353] = true,  -- Enemy Keep Bonus VIII
    [11356] = true,  -- Enemy Keep Bonus IX

    [111549] = true, -- Edge Keep Bonus 1
    [111552] = true, -- Edge Keep Bonus 2
    [111553] = true, -- Edge Keep Bonus 3

    [15060] = true,  -- Defensive Scroll Bonus I
    [16350] = true,  -- Defensive Scroll Bonus II

    [15058] = true,  -- Offensive Scroll Bonus I
    [16348] = true,  -- Offensive Scroll Bonus II

    [66282] = true,  -- Blessing of War

    [15177] = true,  -- Elder Scroll of Altadoon
    [15178] = true,  -- Elder Scroll of Mnem
    [22282] = true,  -- Elder Scroll of Ghartok
    [22295] = true,  -- Elder Scroll of Chim
    [22297] = true,  -- Elder Scroll of Ni-Mohk
    [22299] = true,  -- Elder Scroll of Alma Ruma

    [109862] = true, -- Stronger Walls
    [109944] = true, -- Stronger Doors
    [64674] = true,  -- Cyrodiil Guard See Stealth
    [8077] = true,   -- Increased Guard Health
    [8639] = true,   -- Increased Damage
    [43754] = true,  -- Heavily Resistant Guards
    [8657] = true,   -- Heavily Armored Guards
    [8658] = true,   -- Eagle Eye Guards
    [25873] = true,  -- heal

    [64197] = true,  -- Sanctuary
    [64687] = true,  -- Silence
    [52291] = true,  -- Chain Pull Range Suppression
    [96091] = true,  -- Frozen Gate Suppression
    [97414] = true,  -- Nature Grasp Suppression
    [90095] = true,  -- Falling Damage Reduction
    [112288] = true, -- Wipe Undo Timer

    -- Siege Weapons
    [12256] = true,  -- Pack Siege

    [29673] = true,  -- Create Ballista Bolt...
    [29672] = true,  -- Create Ballista Bolt...
    [29671] = true,  -- Create Ballista Bolt...
    [7468] = true,   -- Ballista Bolt
    [7469] = true,   -- Ballista Bolt
    [13043] = true,  -- Ballista Bolt

    [30611] = true,  -- Create Ballista Fire Bolt...
    [30607] = true,  -- Create Ballista Fire Bolt...
    [16751] = true,  -- Create Ballista Fire Bolt...
    [16775] = true,  -- Fire Ballista Bolt
    [28480] = true,  -- Fire Ballista Bolt
    [14367] = true,  -- Fire Ballista Bolt

    [30612] = true,  -- Create Ballista Lightning Bolt...
    [30608] = true,  -- Create Ballista Lightning Bolt...
    [16752] = true,  -- Create Ballista Lightning Bolt...
    [14363] = true,  -- Lightning Ballista Bolt
    [14364] = true,  -- Lightning Ballista Bolt
    [16776] = true,  -- Lightning Ballista Bolt
    [76103] = true,  -- Magicka Hit
    [30454] = true,  -- Lightning Ballista Bolt

    [39914] = true,  -- Create Trebuchet...
    [39917] = true,  -- Create Trebuchet...
    [39910] = true,  -- Create Trebuchet...
    [14159] = true,  -- Stone Trebuchet
    [64109] = true,  -- Stone Trebuchet
    [14160] = true,  -- Stone Trebuchet

    [39913] = true,  -- Create Trebuchet...
    [39916] = true,  -- Create Trebuchet...
    [39909] = true,  -- Create Trebuchet...
    [13551] = true,  -- Iceball Trebuchet
    [64105] = true,  -- Iceball Trebuchet
    [13588] = true,  -- Iceball Trebuchet
    [13552] = true,  -- Iceball Trebuchet

    [13665] = true,  -- Create Trebuchet... (Firepot Trebuchet)
    [13664] = true,  -- Create Trebuchet... (Firepot Trebuchet)
    [13663] = true,  -- Create Trebuchet... (Firepot Trebuchet)
    [7010] = true,   -- Firepot Trebuchet (Firepot Trebuchet)
    [7429] = true,   -- Firepot Trebuchet (Firepot Trebuchet)
    [28483] = true,  -- Firepot Trebuchet (Firepot Trebuchet)
    [25869] = true,  -- Firepot Trebuchet (Firepot Trebuchet)

    [30613] = true,  -- Create Catapult Meatbag
    [30609] = true,  -- Create Catapult Meatbag
    [16755] = true,  -- Create Catapult Meatbag
    [88714] = true,  -- Meatbag
    [14774] = true,  -- Meatbag Catapult
    [104693] = true, -- Meatbag Catapult
    [32035] = true,  -- Meatbag Catapult
    [36408] = true,  -- Meatbag Catapult

    [30614] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
    [30610] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
    [16754] = true,  -- Create Catapult Oil Jar... (Oil Catapult)
    [104700] = true, -- Twisting Path (Oil Catapult)
    [16789] = true,  -- Oil Catapult (Oil Catapult)
    [104699] = true, -- Oil Catapult (Oil Catapult)
    [64108] = true,  -- Oil Catapult (Oil Catapult)
    [76105] = true,  -- Stamina Hit (Oil Catapult)
    [16790] = true,  -- Oil Catapult (Oil Catapult)

    [39915] = true,  -- Create Catapult Meatbag (Scattershot Catapult)
    [39918] = true,  -- Create Catapult Meatbag (Scattershot Catapult)
    [39911] = true,  -- Create Trebuchet... (Scattershot Catapult)
    [104690] = true, -- Twisting Path (Scattershot Catapult)
    [14611] = true,  -- Scattershot Catapult (Scattershot Catapult)
    [104695] = true, -- Scattershot Catapult (Scattershot Catapult)
    [104696] = true, -- Scattershot Catapult (Scattershot Catapult)

    [66438] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
    [66439] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
    [66440] = true,  -- Create Trebuchet... (Cold Stone Trebuchet)
    [66250] = true,  -- Stone Cold Trebuchet (Cold Stone Trebuchet)
    [66251] = true,  -- Stone Cold Trebuchet (Cold Stone Trebuchet)
    [66252] = true,  -- Stone Cold Trebuchet (Cold Stone Trebuchet)

    [66434] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
    [66388] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
    [66387] = true,  -- Create Trebuchet... (Cold Fire Trebuchet)
    [66246] = true,  -- Firepot Trebuchet (Cold Fire Trebuchet)
    [66247] = true,  -- Firepot Trebuchet (Cold Fire Trebuchet)
    [66248] = true,  -- Firepot Trebuchet (Cold Fire Trebuchet)
    [66245] = true,  -- Cold Harbor Trebuchet (Cold Fire Trebuchet)

    [66437] = true,  -- Create Ballista... (Cold Fire Ballista)
    [66436] = true,  -- Create Ballista... (Cold Fire Ballista)
    [66435] = true,  -- Create Ballista... (Cold Fire Ballista)
    [66242] = true,  -- Fire Ballista Bolt (Cold Fire Ballista)
    [66244] = true,  -- Fire Ballista Bolt (Cold Fire Ballista)
    [66243] = true,  -- Cold Harbor Ballista Bolt (Cold Fire Ballista)

    [135862] = true, -- Create Lance Cannon... (Shock Lancer)
    [135861] = true, -- Create Lance Cannon... (Shock Lancer)
    [135860] = true, -- Create Lance Cannon... (Shock Lancer)
    [138555] = true, -- Shock Lancer (Shock Lancer)
    [138556] = true, -- Shock Lancer (Shock Lancer)
    [138558] = true, -- Shock Lancer (Shock Lancer)
    [138557] = true, -- Shock Lancer (Shock Lancer)

    [135859] = true, -- Create Lance Cannon... (Fire Lancer)
    [135858] = true, -- Create Lance Cannon... (Fire Lancer)
    [135836] = true, -- Create Lance Cannon... (Fire Lancer)
    [138426] = true, -- Fire Lancer (Fire Lancer)
    [138434] = true, -- Fire Lancer (Fire Lancer)
    [138436] = true, -- Fire Lancer (Fire Lancer)
    [138435] = true, -- Fire Lancer (Fire Lancer)

    [135868] = true, -- Create Lance Cannon... (Frost Lancer)
    [135867] = true, -- Create Lance Cannon... (Frost Lancer)
    [135866] = true, -- Create Lance Cannon... (Frost Lancer)
    [138551] = true, -- Frost Lancer (Frost Lancer)
    [138552] = true, -- Frost Lancer (Frost Lancer)
    [138554] = true, -- Frost Lancer (Frost Lancer)
    [138553] = true, -- Frost Lancer (Frost Lancer)

    [22570] = true,  -- Create Boiling Oil... (Flaming Oil)
    [15775] = true,  -- Flaming oil (Flaming Oil)
    [15776] = true,  -- Flaming oil (Flaming Oil)

    [15876] = true,  -- Create Large Ram... (Battering Ram)
    [16171] = true,  -- Create Large Ram... (Battering Ram)
    [16170] = true,  -- Create Large Ram... (Battering Ram)

    [12355] = true,  -- Destroy Siege Weapon

    [13853] = true,  -- Wall Repair Kit
    [16723] = true,  -- Door Repair Kit
    [13601] = true,  -- Advanced Siege Repair Kit
    [112975] = true, -- Wall Repair Kit (Bridge and Milegate Repair Kit)

    [19039] = true,  -- Ebonheart Forward Camp
    [19040] = true,  -- Aldmeri Forward Camp
    [19041] = true,  -- Daggerfall Forward Camp

    -- Volendrung
    [118500] = true, -- Volendrung (Volendrung)
    [118507] = true, -- Volendrung Passive (Volendrung)
    [118509] = true, -- Set Volendrung Stats (Volendrung)

    [116762] = true, -- Light Attack (Volendrung)
    [116763] = true, -- Heavy Attack (Volendrung)
    [116765] = true, -- Heavy Attack (Volendrung)
    [147973] = true, -- Heavy Attack Damage Bonus (Volendrung)
    [116767] = true, -- Heavy Attack (Volendrung)
    [116766] = true, -- Heavy Attack (Volendrung)

    [118501] = true, -- Heal Self (Volendrung)
    [118504] = true, -- Damage Shield (Volendrung)

    [116093] = true, -- Rourken's Rebuke (Rourken's Rebuke)
    [116365] = true, -- Rourken's Rebuke (Rourken's Rebuke)
    [116364] = true, -- Rourken's Rebuke (Rourken's Rebuke)

    [116094] = true, -- Malacath's Vengeance (Malacath's Vengeance)

    [117979] = true, -- Accursed Charge (Accursed Charge)
    [117980] = true, -- Accursed Charge (Accursed Charge)

    [116095] = true, -- Pariah's Resolve (Pariah's Resolve)
    [116374] = true, -- Major Expedition (Pariah's Resolve)
    [116371] = true, -- Major Brutality (Pariah's Resolve)
    [116385] = true, -- Major Endurance (Pariah's Resolve)
    [116366] = true, -- Pariah's Resolve (Pariah's Resolve)

    [116096] = true, -- Ruinous Cyclone (Ruinous Cyclone)
    [116669] = true, -- Ruinous Cyclone (Ruinous Cyclone)
    [116680] = true, -- Ruinous Cyclone (Ruinous Cyclone)
    [116678] = true, -- Ruinous Cyclone (Ruinous Cyclone)

    -- World
    [21675] = true, -- Molag Bal's Favor (Daedric Titan / Daedroth)
    [21677] = true, -- Wall of Souls (Dremora Channeler)
    [21707] = true, -- Imperial Law (Player)

    -- Siege Warfare
    [35106] = true, -- Fire (Firepot Trebuchet)
    [35103] = true, -- Fire (Firepot Trebuchet)
    [35099] = true, -- Ice Damage (Iceball Trebuchet)
    [35100] = true, -- Iceball Snare
    [35112] = true, -- Stoneball (Stone Trebuchet)
    [35094] = true, -- Bolt (Ballista)
    [35055] = true, -- Fire (Firebolt Ballista)
    [35080] = true, -- Bolt (Lightning Ballista)
    [35078] = true, -- Snare (Lightning Ballista)
    [35121] = true, -- Ice Damage (Scattershot Catapult)
    [35119] = true, -- Scatter Snare (Scattershot Catapult)
    [35136] = true, -- Meatbag (Meatbag Catapult)
    [35138] = true, -- Diseased (Meatbag Catapult)
    [35132] = true, -- Oil Pot (Oil Catapult)
    [35131] = true, -- Oil Pot (Oil Catapult)
    [35365] = true, -- Fire (Flaming Oil)
    [33348] = true, -- Practice Siege Repair Kit (Practice Siege Repair Kit)

    -- Chaos Magic
    [70362] = true, -- Remove
    [70365] = true, -- Remove
    [27239] = true, -- Explosion

    -------------------------------------
    -- BATTLEGROUNDS --------------------
    -------------------------------------

    -- Arcane University
    [92600] = true, -- BGArcane Teleport 01
    [92602] = true, -- BGArcane Teleport 02
    [92605] = true, -- BGArcane Teleport 03
    [92607] = true, -- BGArcane Teleport 04
    [92609] = true, -- BGArcane Teleport 05
    [94480] = true, -- BGArcane Teleport 06
    [94483] = true, -- BGArcane Teleport 07
    -- [95826] = true, -- Worm Cult Curse
    -- [95829] = true, -- FX Dummy
    -- [95830] = true, -- Mark of the Worm
    -- [95831] = true, -- Mark of the Worm

    -- Foyada Quarry
    [87946] = true, -- BG Lava
    [87949] = true, -- Lava
    [87948] = true, -- Lava Snare
    [88707] = true, -- Lava Bonus

    -- Ald Carac
    -- [93602] = true, -- Move buff
    -- [92755] = true, -- Stun
    [92757] = true, -- Spinning Blade
    [92759] = true, -- Serrated Blade
    [92754] = true, -- Blade Vulnerability
    -- [92957] = true, -- Blade Despawn

    -------------------------------------
    -- SEASONAL EVENTS ------------------
    -------------------------------------

    -------------------------------------
    -- Jester's Festival
    -------------------------------------

    -- A Noble Guest
    [89243] = true, -- Butcher Awareness - A Noble Guest

    -- Springtime Flair
    [89201] = true, -- Flare -- Springtime Flair
    [87474] = true, -- Flower Garland -- Springtime Flair

    -- Royal Revelry
    [88095] = true, -- Illusion Dazzler -- Royal Revelry
    [88123] = true, -- Illusion Dazzler -- Royal Revelry
    [88124] = true, -- Illusion Dazzler -- Royal Revelry

    -- A Foe Most Porcine
    [144487] = true, -- Greased Lightning (King Boar)
    [127184] = true, -- Home (King Boar)
    [127185] = true, -- Thrash Anchor (King Boar)

    [149110] = true, -- Gore (King Boar)
    [149112] = true, -- Gore (King Boar)
    [149114] = true, -- Gore (King Boar)
    [149116] = true, -- Gore (King Boar)
    [149115] = true, -- Gore Tracker 1 (King Boar)
    [149109] = true, -- Gore (King Boar)
    [149118] = true, -- Gore Tracker 2 (King Boar)
    [149120] = true, -- Gore (King Boar)
    [149121] = true, -- Gore Tracker 3 (King Boar)
    [149117] = true, -- Gore (King Boar)
    [149108] = true, -- Gore (King Boar)

    [127193] = true, -- Uproot (King Boar)
    [127227] = true, -- Uproot (King Boar)
    [127194] = true, -- Uproot (King Boar)

    [143397] = true, -- Grease Shake (King Boar)
    [143696] = true, -- Grease Shake (King Boar)
    [145852] = true, -- Grease Shake (King Boar)
    [145170] = true, -- Grease Shake (King Boar)
    [145198] = true, -- Grease Shake (King Boar)
    [145209] = true, -- Grease Shake (King Boar)

    [145282] = true, -- Grease Shake (King Boar)
    [146018] = true, -- Grease Shake (King Boar)
    [143695] = true, -- Grease Slip (King Boar)
    [145099] = true, -- Slip Immune (King Boar)
    [144135] = true, -- Greased Hands (King Boar)
    [145861] = true, -- Greased Footing (King Boar)

    [144203] = true, -- Summon Prince Boars (Friendly NPC)
    [116849] = true, -- Fast (Prince Boar)
    [126947] = true, -- Thrash (Prince Boar)
    [126963] = true, -- Thrash Anchor (Prince Boar)
    [126998] = true, -- Thrash Anchor (Prince Boar)
    [126965] = true, -- Thrash Anchor (Prince Boar)
    [127000] = true, -- Thrash Anchor (Prince Boar)
    [126964] = true, -- Thrash Anchor (Prince Boar)
    [126999] = true, -- Thrash Anchor (Prince Boar)
    [126962] = true, -- Thrash Anchor (Prince Boar)
    [126997] = true, -- Thrash Anchor (Prince Boar)
    [129731] = true, -- Thrash Anchor (Prince Boar)
    [129730] = true, -- Thrash Anchor (Prince Boar)

    [144336] = true, -- Thrash (Prince Boar)
    [144343] = true, -- Thrash (Prince Boar)
    [144341] = true, -- Thrash (Prince Boar)
    [144342] = true, -- Thrash (Prince Boar)
    [144347] = true, -- Thrash (Prince Boar)
    [144345] = true, -- Thrash (Prince Boar)
    [144350] = true, -- Thrash (Prince Boar)
    [144352] = true, -- Thrash (Prince Boar)
    [144351] = true, -- Thrash (Prince Boar)

    -------------------------------------
    -- New Life Festival
    -------------------------------------

    -- Stonetooth Bash
    [84847] = true, -- Celebratory Belch -- Stonetooth Bash

    -- Snow Bear Plunge
    [85680] = true, -- Jump -- Snow Bear Plunge
    [83523] = true, -- Freezing -- Snow Bear Plunge
    [83544] = true, -- Cold -- Snow Bear Plunge
    [83522] = true, -- Warm -- Snow Bear Plunge

    -- Lava Foot Stomp
    [84125] = true, -- Breton Male Dance -- Lava Foot Stomp
    [84187] = true, -- Breton Dance -- Lava Foot Stomp
    [85544] = true, -- Breton Dance -- Lava Foot Stomp
    [84126] = true, -- Breton Female Dance -- Lava Foot Stomp
    [84188] = true, -- Breton Dance -- Lava Foot Stomp
    [85540] = true, -- Breton Dance -- Lava Foot Stomp
    [86752] = true, -- Entertaining -- Lava Foot Stomp
    [84127] = true, -- Dunmer Male Dance -- Lava Foot Stomp
    [84189] = true, -- Dunmer Dance -- Lava Foot Stomp
    [85545] = true, -- Breton Dance -- Lava Foot Stomp
    [84128] = true, -- Dunmer Female Dance -- Lava Foot Stomp
    [84190] = true, -- Dunmer Dance -- Lava Foot Stomp
    [85546] = true, -- Breton Dance -- Lava Foot Stomp
    [84130] = true, -- Altmer Male Dance -- Lava Foot Stomp
    [84191] = true, -- Bosmer Dance -- Lava Foot Stomp
    [85547] = true, -- Breton Dance -- Lava Foot Stomp
    [84131] = true, -- Altmer Female Dance -- Lava Foot Stomp
    [84192] = true, -- Bosmer Dance -- Lava Foot Stomp
    [85548] = true, -- Breton Dance -- Lava Foot Stomp
    [84133] = true, -- Nord Dance -- Lava Foot Stomp
    [84194] = true, -- Nord Dance -- Lava Foot Stomp
    [85549] = true, -- Breton Dance -- Lava Foot Stomp

    -- Castle Charm Challenge
    [84528] = true, -- Flame Juggling -- Castle Charm Challenge
    [84530] = true, -- Flame Juggling -- Castle Charm Challenge
    [85561] = true, -- Breton Dance -- Castle Charm Challenge
    [84506] = true, -- Dagger Juggling -- Castle Charm Challenge
    [84507] = true, -- Dagger Juggling -- Castle Charm Challenge
    [85560] = true, -- Breton Dance -- Castle Charm Challenge
    [84533] = true, -- Sword Swallowing -- Castle Charm Challenge
    [84534] = true, -- Sword Swallowing -- Castle Charm Challenge
    [85562] = true, -- Breton Dance -- Castle Charm Challenge

    -- Mud Ball Merriment
    -- [84330] = true, -- Mudball -- Mud Ball Merriment
    [84378] = true, -- Mudball -- Mud Ball Merriment
    [84335] = true, -- Covered in Mud -- Mud Ball Merriment
    [85639] = true, -- Covered in Mud -- Mud Ball Merriment

    -------------------------------------
    -- Witches Festival
    -------------------------------------

    -- The Witchmother's Bargain
    [83775] = true, -- Event - Q5742 WitchFest Intro (The Witchmother's Bargain)
    [83820] = true, -- Event Q5742 WitchFest Done (The Witchmother's Bargain)
    [85055] = true, -- Crows (The Witchmother's Bargain)
    [82898] = true, -- Event - WitchFest Theater (The Witchmother's Bargain)

    -------------------------------------
    -- Anniversary Event
    -------------------------------------

    -- Ache for Cake
    [88874] = true, -- Q5936 Destroy Voucher 2017 (Ache for Cake)

    -------------------------------------
    -- Pan-Elsweyr Celebration
    -------------------------------------

    -- Misc - Dragon Attacks
    [120954] = true, -- JusticeDragon-Flee
    [120956] = true, -- JusticeDragon-Flee
    [120957] = true, -- RUNJusticeDragon1
    [120958] = true, -- COWERJusticeDragon2
    [120960] = true, -- JusticeDragon-REG WPTReach
    [120961] = true, -- JusticeDragon-REG WPTReach
    [120977] = true, -- COWERJusticeDragon2
    [120980] = true, -- JusticeDragon-Flee
    [120981] = true, -- JusticeDragon-Flee

    -- Infinite Archive
    [212753] = true, -- Deposit Ink : Spammed event
    [212754] = true, -- Deposit Ink : Spammed event
    [203124] = true, -- Event - Verse Select. GAIN/GAINDUR/STUN
    [203125] = true, -- Event - Verse Select. GAIN/GAINDUR/STUN

    -- West Weald
    [210068] = true, -- Trigger Central VO 1
    [209292] = true, -- Rift Projectile B
    [209293] = true, -- Rift Projectile C
    [209294] = true, -- Rift Projectile D
    [209409] = true, -- Rift Projectile B
    [209410] = true, -- Rift Projectile C
    [209411] = true, -- Rift Projectile D
}

--- @type DebugAuras
Data.DebugAuras = debugAuras
