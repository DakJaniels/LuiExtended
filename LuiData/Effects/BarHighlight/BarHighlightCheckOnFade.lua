-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

local PLAYER_UNIT_TAG = "player"
local TARGET_UNIT_TAG = "reticleover"

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

-- When the primary tracked effect fades, do an iteration over player buffs to see if another buff is present, if so trigger bar highlight for it
-- ORIGINAL TRACKED ID = OTHER ID'S TO CHECK FOR
-- Priority is ID1 > ID2 if present
-- If duration value is set to an ID, the duration will be pulled from this ID
-- If durationMod value is set to an ID, this value will be subtracted from the final duration (UNUSED)
-- Note that any secondary id's for Bar Highlight in the table above will set their id to the original tracked id here
-- Note all effects will check unitTag unless an id2Tag or id3Tag are specified in which case they will switch unitTags when searching for other ids.

--- @class BarHighlightOverrideEntry
--- @field id1 integer | nil Primary ability ID to track
--- @field id2 integer | nil Secondary ability ID to check
--- @field id3 integer | nil Tertiary ability ID to check
--- @field unitTag string Unit tag to filter effects ("player" or "reticleover")
--- @field id2Tag string | nil Unit tag to filter effects ("player" or "reticleover")
--- @field id3Tag string | nil Unit tag to filter effects ("player" or "reticleover")
--- @field duration integer | nil Ability ID whose duration to use (passed to GetUpdatedAbilityDuration). When set, fake path is used instead of buff scan.
--- @field durationMod integer | nil Ability ID whose duration to subtract from duration (e.g. Phantasmal Escape from Major Evasion). Passed to GetUpdatedAbilityDuration.
--- @type table<integer, BarHighlightOverrideEntry>
local barHighlightCheckOnFade =
{

    -- Dragonknight
    [108798] = { id1 = 21014, unitTag = PLAYER_UNIT_TAG },                             -- Fleetstep Wings
    [122407] = { id1 = 21017, unitTag = PLAYER_UNIT_TAG },                             -- Protect the Brood
    [31898] = { id1 = 20253, id2 = 31898, unitTag = TARGET_UNIT_TAG },                 -- Burning Talons
    [32744] = { id1 = 61698, id2 = 61705, unitTag = PLAYER_UNIT_TAG },                 -- Blood of the Green Dragon HoT fade --> Major Fortitude / Major Endurance (remaining duration)
    [261754] = { id1 = 258203, id2 = 31820, unitTag = PLAYER_UNIT_TAG },               -- Volcanic Ward primary buff fade --> secondary / slotted remainder
    [258203] = { id1 = 261754, id2 = 31820, unitTag = PLAYER_UNIT_TAG },               -- Volcanic Ward secondary buff fade --> primary / slotted remainder
    [31808] = { id1 = 20328, unitTag = PLAYER_UNIT_TAG },                              -- Earthshield Mantle shield fade --> mantle player buff remainder
    [54931] = { id1 = 61742, id2 = 79717, id3 = 54931, unitTag = TARGET_UNIT_TAG },    -- Fossilize stun fade --> Minor Breach / Minor Vuln / stun on target (reticle resync)
    [259138] = { id1 = 61742, id2 = 259138, id3 = 259137, unitTag = TARGET_UNIT_TAG }, -- Shattering Rocks stun fade --> breach display / stun / breach combat on target

    -- Nightblade
    [125314] = { duration = 90620, durationMod = 125314, unitTag = PLAYER_UNIT_TAG }, -- Phantasmal Escape --> Major Evasion
    [33357] = { id1 = 61743, id2 = 33357, unitTag = TARGET_UNIT_TAG },               -- Mark Target debuff fade --> breach / mark
    [36968] = { id1 = 61743, id2 = 36968, id3 = 36994, unitTag = TARGET_UNIT_TAG }, -- Piercing Mark
    [36967] = { id1 = 61743, id2 = 36967, unitTag = TARGET_UNIT_TAG },               -- Reaper's Mark
    [35336] = { id1 = 35336, id2 = 79717, unitTag = TARGET_UNIT_TAG },               -- Lotus Fan DoT --> vuln
    [61389] = { id1 = 61389, unitTag = TARGET_UNIT_TAG },                             -- Death Stroke debuff
    [61393] = { id1 = 61393, unitTag = TARGET_UNIT_TAG },                             -- Incapacitating Strike debuff
    [61400] = { id1 = 61400, id2 = 61727, unitTag = TARGET_UNIT_TAG },               -- Soul Harvest debuff + defile
    [122585] = { id1 = 122585, unitTag = PLAYER_UNIT_TAG },                           -- Grim Focus stacks after spend
    [122587] = { id1 = 122587, unitTag = PLAYER_UNIT_TAG },                           -- Relentless Focus stacks after spend
    [33211] = { id1 = 33211, unitTag = PLAYER_UNIT_TAG },                             -- Summon Shade pet timer
    [33290] = { id1 = 33290, id2 = 33211, unitTag = PLAYER_UNIT_TAG },
    [35438] = { id1 = 35438, unitTag = PLAYER_UNIT_TAG },                             -- Dark Shade (slotted)
    [108940] = { id1 = 108940, id2 = 35438, unitTag = PLAYER_UNIT_TAG },
    [35441] = { id1 = 35441, unitTag = PLAYER_UNIT_TAG },                             -- Shadow Image (slotted)
    [38528] = { id1 = 38528, id2 = 35441, unitTag = PLAYER_UNIT_TAG },
    [35451] = { id1 = 35451, id2 = 35441, unitTag = PLAYER_UNIT_TAG },

    -- Siphoning (Offering self-drain fades; bar keeps slotted highlight on Minor Mending)
    [108932] = { id1 = 61710, id2 = 108934, unitTag = PLAYER_UNIT_TAG }, -- Healthy Offering --> Minor Mending

    -- Warden
    [130139] = { id1 = 130140, id2 = 130139, unitTag = TARGET_UNIT_TAG }, -- Off-Balance --> Cutting Dive / Off-Balance

    [86009] = { id1 = 178020, unitTag = PLAYER_UNIT_TAG },                -- Scorch
    [86019] = { id1 = 146919, unitTag = PLAYER_UNIT_TAG },                -- Subterranean Assault
    [86015] = { id1 = 178028, unitTag = PLAYER_UNIT_TAG },                -- Deep Fissure

    [85552] = { id1 = 85552, unitTag = PLAYER_UNIT_TAG },                 -- Living Vines (If player mouses over target with this ability and mouses off and has this ability on themselves, we want to resume that)
    [85850] = { id1 = 85850, unitTag = PLAYER_UNIT_TAG },                 -- Leeching Vines (If player mouses over target with this ability and mouses off and has this ability on themselves, we want to resume that)
    [85851] = { id1 = 85851, unitTag = PLAYER_UNIT_TAG },                 -- Living Trellis (If player mouses over target with this ability and mouses off and has this ability on themselves, we want to resume that)
    -- [85807] = { id1 = 91819, unitTag = PLAYER_UNIT_TAG }, -- Healing Thicket -- TODO: Doesn't work for some reason

    -- Necromancer
    [121513] = { id1 = 121513, id2 = 143915, id3 = 143917, unitTag = TARGET_UNIT_TAG }, -- Minor Maim --> Grave Grasp / Minor Maim
    [118309] = { id1 = 118309, id2 = 118325, id3 = 143945, unitTag = TARGET_UNIT_TAG }, -- Minor Maim --> Ghostly Embrace / Minor Maim
    [118354] = { id1 = 118354, id2 = 143948, id3 = 143949, unitTag = TARGET_UNIT_TAG }, -- Minor Maim --> Empowering Grasp / Minor Maim
    [253163] = { id1 = 253163, id2 = 253164, id3 = 119068, unitTag = TARGET_UNIT_TAG }, -- Vengeance Grave Grasp / Minor Maim / immunity
    [269944] = { id1 = 269944, id2 = 255165, unitTag = TARGET_UNIT_TAG },               -- Battle Trauma (6s + 4s components)
    [255184] = { id1 = 61693, id2 = 255185, unitTag = PLAYER_UNIT_TAG },                -- Stand Firm --> Minor Resolve / heal combat
    [255189] = { id1 = 61705, id2 = 61707, unitTag = PLAYER_UNIT_TAG },                 -- Regroup --> Major Endurance / Major Intellect
    [255326] = { id1 = 61744, id2 = 61735, unitTag = PLAYER_UNIT_TAG },                 -- Marshaling Cry --> Minor Berserk / Minor Expedition
    [255479] = { id1 = 255479, id2 = 255512, unitTag = PLAYER_UNIT_TAG },               -- Detonating Strike proc / player track remainder
    [246026] = { id1 = 246026, id2 = 61694, unitTag = PLAYER_UNIT_TAG },                -- Bone Armor buff fade --> Major Resolve remainder
    [114131] = { id1 = 114131, unitTag = PLAYER_UNIT_TAG },                             -- Flame Skull charges (resync stacks after per-cast combat FADE)
    [117625] = { id1 = 117625, unitTag = PLAYER_UNIT_TAG },                             -- Venom Skull charges
    [117638] = { id1 = 117638, unitTag = PLAYER_UNIT_TAG },                             -- Ricochet Skull charges
    [255682] = { id1 = 255682, unitTag = PLAYER_UNIT_TAG },                             -- In The Fray (post-recast FADE resync)
    [255689] = { id1 = 61722, unitTag = PLAYER_UNIT_TAG },                              -- Warding Interception --> Major Protection
    [269817] = { id1 = 269817, id2 = 61723, unitTag = TARGET_UNIT_TAG },                -- Ensnaring Chains ROOT + Minor Maim on reticle
    [255952] = { id1 = 255952, id2 = 255953, unitTag = TARGET_UNIT_TAG },               -- Demoralizing Disruption silence + stun
    [255651] = { id1 = 255651, unitTag = TARGET_UNIT_TAG },                             -- Shoulder Toss stun on reticle
    [256560] = { id1 = 256560, unitTag = TARGET_UNIT_TAG },                             -- Blade Bite bleed on reticle
    [256690] = { duration = 256693, durationMod = 256692, unitTag = PLAYER_UNIT_TAG },  -- Nimble Feint (dummy 4s − fatigue 3s after disorient fade)
    [256695] = { id1 = 256695, id2 = 61746, unitTag = PLAYER_UNIT_TAG },               -- Stalker's Quarry + Minor Force
    [256736] = { id1 = 256736, id2 = 145977, unitTag = TARGET_UNIT_TAG },               -- Focus Fire + Major Brittle
    [256713] = { duration = 256715, durationMod = 256713, unitTag = PLAYER_UNIT_TAG },  -- Cleansing Shadow (dummy 4s − invis 3s on player)

    -- Two Handed
    [131562] = { id1 = 131562, id2 = 16825, id3 = 137807, unitTag = TARGET_UNIT_TAG }, -- Dizzying Swing OB 7s / exploit stun 2s / immune snare 2s
    [16825] = { id1 = 16825, id2 = 131562, id3 = 137807, unitTag = TARGET_UNIT_TAG },
    [137807] = { id1 = 137807, id2 = 131562, id3 = 16825, unitTag = TARGET_UNIT_TAG },
    [38797] = { duration = 38794, durationMod = 38797, unitTag = PLAYER_UNIT_TAG }, -- Forward Momentum --> Major Brutality / Minor Endurance

    -- Sorcerer (target CC debuffs + bundled maim)
    [143659] = { id1 = 61725, id2 = 143659, unitTag = TARGET_UNIT_TAG },               -- Encase immobilize fade --> Major Maim
    [143663] = { id1 = 61725, id2 = 143663, id3 = 214457, unitTag = TARGET_UNIT_TAG }, -- Shattering Prison
    [143668] = { id1 = 61725, id2 = 143668, unitTag = TARGET_UNIT_TAG },               -- Restraining Prison

    -- Dual Wield
    [126667] = { id1 = 61665, unitTag = PLAYER_UNIT_TAG }, -- Flying Blade --> Major Brutality

    -- Bow
    -- [100302] = { id1 = 38707, id2 = 100302, unitTag = TARGET_UNIT_TAG }, -- Piercing Spray --> Bombard / Bombard / Piercing Spray
    [100302] = { id1 = 38703, id2 = 100302, unitTag = TARGET_UNIT_TAG }, -- Piercing Spray --> Acid Spray / Piercing Spray

    -- 113627] = { id1 = 28887, id2 = 113627, unitTag = TARGET_UNIT_TAG }, -- Virulent Shot --> Scatter Shot / Virulent Shot
    -- 113627] = { id1 = 38674, id2 = 113627, unitTag = TARGET_UNIT_TAG }, -- Virulent Shot --> Magnum Shot / Virulent Shot
    [113627] = { id1 = 131688, id2 = 113627, unitTag = TARGET_UNIT_TAG }, -- Virulent Shot --> Draining Shot / Virulent Shot

    -- Medium Armor
    [39196] = { duration = 63019, durationMod = 39196, unitTag = PLAYER_UNIT_TAG }, -- Shuffle --> Major Evasion

    -- Heavy Armor
    [126581] = { duration = 63084, durationMod = 126581, unitTag = PLAYER_UNIT_TAG }, -- Unstoppable --> Major Resolve
    [126582] = { duration = 63134, durationMod = 126582, unitTag = PLAYER_UNIT_TAG }, -- Immovable Brute --> Major Resolve
    [126583] = { duration = 63119, durationMod = 126583, unitTag = PLAYER_UNIT_TAG }, -- Immovable --> Major Resolve

    -- Werewolf
    [137257] = { id1 = 137257, id2 = 32633, unitTag = TARGET_UNIT_TAG }, -- Off Balance --> Roar / Off Balance
    [137312] = { id1 = 137312, id2 = 39114, unitTag = TARGET_UNIT_TAG }, -- Off Balance --> Deafening Roar / Off Balance

    -- Fighters Guild
    [35750] = { duration = 68595, unitTag = PLAYER_UNIT_TAG }, -- Trap Beast --> Minor Force
    [40382] = { duration = 68632, unitTag = PLAYER_UNIT_TAG }, -- Barbed Trap --> Minor Force
    [40372] = { duration = 68628, unitTag = PLAYER_UNIT_TAG }, -- Lightweight Beast Trap --> Minor Force

    -- Mages Guild
    [40449] = { id1 = 48136, unitTag = PLAYER_UNIT_TAG },                           -- Spell Symmetry
    [48141] = { duration = 80160, durationMod = 48141, unitTag = PLAYER_UNIT_TAG }, -- Balance --> Major Resolve

    -- Support
    [40237] = { id1 = 40238, unitTag = PLAYER_UNIT_TAG }, -- Reviving Barrier --> Reviving Barrier Heal

    -- Volendrung
    [116366] = { duration = 116374, durationMod = 116366, unitTag = PLAYER_UNIT_TAG }, -- Pariah's Resolve
}

Effects.BarHighlightCheckOnFade = barHighlightCheckOnFade
