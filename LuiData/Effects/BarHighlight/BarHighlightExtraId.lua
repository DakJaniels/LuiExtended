-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- List of abilities flagged to display a Proc highlight / sound notification when an ability with a matching name appears as a buff.
--------------------------------------------------------------------------------------------------------------------------------

-- Also track this id on bar highlight
-- SECONDARY ID = ORIGINAL BAR HIGHLIGHT ID
--- @class (partial) BarHighlightExtraId
local barHighlightExtraId =
{

    -- Dragonknight
    [108798] = 21014, -- Fleetstep Wings expedition carrier buff --> slotted (morph log path)
    [259744] = 21014, -- Fleetstep Wings Major Expedition combat --> slotted (bundle log path)
    [259761] = 21014, -- Fleetstep Wings Minor Brutality combat --> slotted
    -- Shared taunt/cowardice display ids: bar uses newId 38254 / combatTrack on slotted morph; extraId only for morph-specific combat bundles.
    [76498] = 20492,  -- Major Cowardice combat (Chains of Flame only; not 76502)
    [76502] = 20496,  -- Major Cowardice combat (Chains of Dominance) --> slotted
    [76506] = 20499,  -- Major Evasion combat (Chains of Devastation) --> slotted
    [147421] = 20499, -- Major Berserk combat (Chains of Devastation) --> slotted
    [259718] = 21007, -- Wing Buffet stun --> slotted
    [259719] = 21007, -- Wing Buffet knockback --> slotted
    [259323] = 29016, -- Dragon Leap travel (600 ms) --> slotted
    [262677] = 29016, -- Dragon Leap bundle --> slotted
    [114590] = 29016, -- Dragon Leap stun --> slotted
    [262678] = 29016, -- Dragon Leap stun --> slotted
    [259228] = 29016, -- Landslide (U49) --> Dragon Leap (Landslide on bar via BarHighlightOverride newId 29465)
    [259372] = 32719, -- Take Flight travel --> slotted
    [262683] = 32719, -- Take Flight bundle --> slotted
    [114600] = 32719, -- Take Flight stun --> slotted
    [262682] = 32719, -- Take Flight stun --> slotted
    [259241] = 32719, -- Landslide (U49) --> Take Flight
    [262681] = 32715, -- Ferocious Leap bundle --> slotted
    [114601] = 32715, -- Ferocious Leap stun --> slotted
    [262680] = 32715, -- Ferocious Leap stun --> slotted
    [32717] = 32715,  -- Ferocious Leap knockback aura (target; log, parallel 114601) --> slotted
    -- Landslide 29465 shared; bar newId 29465 only on 29016 (Take Flight bar uses 262682 stun — not 29465).
    [259684] = 32715, -- Landslide (U49) --> Ferocious Leap
    [258293] = 31816, -- Magma Fist player buff (6s empower) --> slotted
    [92507] = 29043,  -- Major Sorcery combat (Molten Weapons) --> slotted
    [131340] = 29043, -- Major Brutality combat (Molten Weapons) --> slotted
    [92503] = 31874,  -- Major Sorcery combat (Igneous Weapons) --> slotted
    [76518] = 31874,  -- Major Brutality combat (Igneous Weapons) --> slotted
    [92512] = 31888,  -- Major Sorcery combat (Molten Armaments) --> slotted
    [131341] = 31888, -- Major Brutality combat (Molten Armaments) --> slotted
    [76537] = 31888,  -- Empower combat (Molten Armaments) --> slotted
    [108675] = 29071, -- Major Mending combat (Obsidian Shield) --> slotted
    [55033] = 29224,  -- Major Mending combat (Igneous Shield) --> slotted
    [108676] = 32673, -- Major Mending combat (Fragmented Shield) --> slotted
    [61815] = 20319,  -- Major Resolve combat (Earthspike Mantle) --> slotted
    [61827] = 20328,  -- Major Resolve combat (Earthshield Mantle) --> slotted
    [61836] = 20323,  -- Major Resolve combat (Shatterspike Mantle) --> slotted
    [68807] = 21157,  -- Major Brutality combat (Hidden Blade) --> slotted
    [126647] = 38914, -- Major Brutality combat (Shrouded Daggers) --> slotted
    [32753] = 21017,  -- Protect the Brood Minor Protection combat --> slotted
    [260258] = 21017, -- Protect the Brood Major Expedition combat --> slotted
    [122407] = 21017, -- Protect the Brood (export buff path) --> slotted
    [259748] = 21017, -- Comrade's Vigor --> Protect the Brood
    [259749] = 21017,
    [259752] = 21017,
    [256798] = 23808, -- Volcanic Whip (replaces Lava Whip on bar) --> Lava Slam stack buff
    [20824] = 34117,  -- Power Lash on bar (replaces Flame Lash) --> stack buff 34117
    [20930] = 32821,  -- Engulfing slotted id --> channel tick track id (EFFECT_CHANGED uses 20930)
    [20253] = 31898,  -- Burning Talons
    [48946] = 31103,  -- Disintegrating Major Breach combat id --> DOT track on bar (log)
    [61785] = 32685,  -- Fossilize root (post-stun)
    [54931] = 32685,  -- Fossilize stun (target) --> slotted
    [259129] = 32685, -- Fossilize Minor Breach combat --> slotted
    [259130] = 32685, -- Fossilize Minor Vulnerability combat --> slotted
    [259090] = 29037, -- Petrify stun (target) --> slotted
    [259089] = 29037, -- Petrify Minor Breach combat (when present) --> slotted
    [61742] = 259090, -- Minor Breach display on target (Petrify bar key 259090; Fossilize uses 259129 combatTrack)
    [259138] = 32678, -- Shattering Rocks stun (target) --> slotted
    [259137] = 32678, -- Shattering Rocks Minor Breach combat --> slotted

    -- Nightblade
    [124803] = 18342, -- Teleport Strike Minor Vulnerability combat --> slotted
    [124806] = 25493, -- Lotus Fan vuln combat --> slotted
    [124804] = 25484, -- Ambush Minor Vulnerability combat --> slotted
    [33363] = 33357,  -- Mark Target combat --> slotted
    [33372] = 33357,
    [36980] = 36968,  -- Piercing Mark combat --> slotted
    [36984] = 36968,
    [36972] = 36967,  -- Reaper's Mark combat --> slotted
    [36976] = 36967,
    [177247] = 25352, -- Aspect of Terror cowardice combat --> slotted
    [177248] = 25352, -- Aspect of Terror cast --> slotted
    [177249] = 37470, -- Mass Hysteria cowardice combat --> slotted
    [177251] = 37475, -- Manifestation cowardice combat --> slotted
    [44871] = 25411,  -- Consuming Darkness Major Protection combat --> slotted
    [44862] = 36493,  -- Bolstering Darkness Major Protection combat --> slotted
    [126675] = 36901, -- Power Extraction Minor Cowardice combat --> slotted
    [33317] = 33316,  -- Drain Power Major Sorcery combat --> slotted
    [131342] = 33316, -- Drain Power Major Brutality combat --> slotted
    [131344] = 36901, -- Power Extraction Major Sorcery combat --> slotted
    [36903] = 36901,  -- Power Extraction Major Brutality combat --> slotted
    [62240] = 36891,  -- Sap Essence Major Sorcery combat --> slotted
    [131343] = 36891, -- Sap Essence Major Brutality combat --> slotted
    [108940] = 35438, -- Dark Shade player buff --> slotted
    [35434] = 35438,  -- Dark Shade summon combat --> slotted
    [38528] = 35441,  -- Shadow Image player buff --> slotted
    [35451] = 35441,  -- Shadow Image shade track --> slotted
    [35442] = 35441,

    -- Sorcerer
    [89491] = 24330,  -- Haunting Curse (1-stack target track --> slotted)
    [132946] = 23236, -- Streak (combat --> slotted; target stun 28482 hidden)
    [47147] = 27706,  -- Negate Magic in-field stun --> slotted ground
    [47159] = 28341,  -- Suppression Field stun --> slotted ground
    [47167] = 28348,  -- Absorption Field stun --> slotted ground

    -- Warden
    [130140] = 130139, -- Cutting Dive --> Off-Balance
    [87194] = 88761,   -- Minor Protection --> Major Resolve (Ice Fortress)

    -- Necromancer
    [114108] = 114131, -- Flame Skull (slotted / combat) --> charge buff
    [123683] = 114131, -- Flame Skull charged cast projectile --> charge buff
    [123685] = 114131, -- Flame Skull 3rd cast projectile --> charge buff
    [117624] = 117625, -- Venom Skull
    [117629] = 117625, -- Venom Skull (slotted name id)
    [123699] = 117625, -- Venom Skull charged cast --> charge buff
    [123704] = 117625, -- Venom Skull 3rd cast --> charge buff
    [117637] = 117638, -- Ricochet Skull
    [123718] = 117638, -- Ricochet Skull charged cast --> charge buff
    [123719] = 117638, -- Ricochet Skull 3rd cast --> charge buff
    [143915] = 121513, -- Grave Grasp
    [143917] = 121513, -- Grave Grasp
    [118325] = 118309, -- Ghostly Embrace
    [143945] = 118309, -- Ghostly Embrace
    [143948] = 118354, -- Empowering Grasp
    [143949] = 118354, -- Empowering Grasp
    [253164] = 253163, -- Vengeance Grave Grasp --> Minor Maim combat
    [119068] = 253163, -- Vengeance Grave Grasp --> Immobilize Immunity (target)
    [61693] = 255184,  -- Stand Firm --> Minor Resolve (player buff drives slotted bar)
    [61705] = 255189,  -- Regroup --> Major Endurance
    [61707] = 255189,  -- Regroup --> Major Intellect
    [61735] = 255326,  -- Marshaling Cry --> Minor Expedition
    [61744] = 255326,  -- Marshaling Cry --> Minor Berserk
    [255165] = 269944, -- Battle Trauma (4s dodge penalty on target --> 6s track id)
    [61694] = 246026,  -- Vengeance Bone Armor --> Major Resolve (player buff)
    [238130] = 238129, -- Vengeance Frozen Colossus (secondary ground --> slotted ground)
    [238132] = 238129, -- Vengeance Frozen Colossus (damage tick --> ground bar key)
    [255480] = 255479, -- Detonating Strike (damage combat --> proc bar)
    [255550] = 255479, -- Detonating Strike (ground tick --> proc bar)
    [61722] = 255689,  -- Warding Interception --> Major Protection (player buff drives slotted bar)

    -- Two Handed
    [16825] = 38814,  -- Off Balance Exploit stun --> Dizzying Swing (bar slot)
    [137807] = 38814, -- OB immune snare --> Dizzying Swing (bar slot)
    [126475] = 38788, -- Stampede player track --> slotted Stampede (Merciless 99789 is primary newId on 38788)
    [147423] = 38807, -- Empower combat --> Wrecking Blow
    [188408] = 38807, -- Major Berserk combat --> Wrecking Blow

    -- Bow
    [38707] = 100302,  -- Bombard --> Piercing Spray
    [38703] = 100302,  -- Acid Spray --> Piercing Spray

    [28887] = 113627,  -- Virulent Shot --> Scatter Shot
    [38674] = 113627,  -- Virulent Shot --> Magnum Shot
    [131688] = 113627, -- Virulent Shot --> Draining Shot

    -- Mages Guild
    [40468] = 40465, -- Scalding Rune
    [40476] = 40470, -- Volcanic Rune

    -- Psijic Order
    [104085] = 104079, -- Time Freeze

    -- Werewolf
    [32633] = 137257,  -- Roar --> Off Balance
    [170991] = 137257, -- Roar fear combat id --> Off Balance bar key
    [171001] = 45834,  -- Ferocious Roar fear combat id --> Off Balance bar key
    [171003] = 137312, -- Deafening Roar fear combat id --> Off Balance bar key
    [267745] = 58405,  -- Gnash Execute --> Gnash slot
    [58744] = 58742,   -- Rip and Tear Execute --> Rip and Tear slot
    [267747] = 58798,  -- Bloody Gnash Execute --> Bloody Gnash slot
    [39114] = 137312,  -- Deafening Roar --> Off Balance

    -- Vampire
    [138130] = 138098, -- Stupefy
}

--- @class (partial) BarHighlightExtraId
Effects.BarHighlightExtraId = barHighlightExtraId
