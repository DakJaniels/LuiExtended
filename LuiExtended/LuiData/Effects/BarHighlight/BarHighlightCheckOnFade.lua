-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
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
--- @field duration integer | nil Override duration for the effect (in milliseconds)
--- @field durationMod integer | nil Duration modifier to subtract from final duration

--- @type table<integer, BarHighlightOverrideEntry>
local barHighlightCheckOnFade =
{

    -- Dragonknight
    [108798] = { id1 = 21014, unitTag = PLAYER_UNIT_TAG },             -- Protective Plate
    [31898] = { id1 = 20253, id2 = 31898, unitTag = TARGET_UNIT_TAG }, -- Burning Talons

    -- Nightblade
    [125314] = { duration = 90620, durationMod = 125314, unitTag = PLAYER_UNIT_TAG }, -- Phantasmal Escape --> Major Evasion

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

    -- Two Handed
    [38797] = { duration = 38794, durationMod = 38797, unitTag = PLAYER_UNIT_TAG }, -- Forward Momentum --> Major Brutality / Minor Endurance

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
