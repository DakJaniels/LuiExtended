-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
local CrowdControl = Data.CrowdControl
--- @class (partial) IgnoreList
local ignoreList =
{
    -- PVP
    [21927] = true, -- Minor Defile,
    [178118] = true, -- Overcharged,
    [178127] = true, -- Diseased,
    -- [88402] = true, -- Minor Magickasteal -- TODO: This id isn't the heal anymore so don't think this is needed here
    [40079] = true, -- Radiating Regeneration,
    [57468] = true, -- Radiating Regeneration,
    [62775] = true, -- Major Breach,
    [68368] = true, -- Minor Maim,
    [95136] = true, -- Chill,
    [146697] = true, -- Minor Brittle,
    [148798] = true, -- Minor Magickasteal,
    [178123] = true, -- Sundered,
    [187940] = true, -- Minor Courage,
    [187941] = true, -- Minor Endurance,
    [187942] = true, -- Minor Fortitude,
    [187943] = true, -- Minor Intellect,

    -- World
    [4197] = true, -- Recovering (NPC Duel),
    [54363] = true, -- Halt (Guard),

    -- Quests
    [34499] = true, -- Corruption Beam (The Blight of the Bosmer),

    -- Vampire
    [44670] = true, -- Vamp Theater Head Grab Stun (Scion of the Blood Matron),

    -- MSQ
    [28737] = true, -- Recovery (Manifestation of Terror),
    [32060] = true, -- Shocked (Tears of the Two Moons),
    [35645] = true, -- Q4768 PC Tribunal Layer 2 Stun (Scars Never Fade),
    [38108] = true, -- Q4868 Sheo Teleports Player (The Grips of Madness),
    [48077] = true, -- Q4971 Shali Cast (Saved),
    [61646] = true, -- Incapacitating Terror (Tutorial),
    [64072] = true, -- Eye of the Sentinel (Tutorial),

    -- Elsweyr
    [121032] = true, -- Bash (Grand Adept Ma'hja-dro) (Bright Moons, Warm Sands),
    [121035] = true, -- Staggered (Grand Adept Ma'hja-dro) (Bright Moons, Warm Sands),

    ----------------
    -- Arenas
    ----------------

    -- Dragonstar Arena
    [55221] = true, -- Sucked Under (Player),
    [55641] = true, -- Stun (Light of Boethia),

    ----------------
    -- Dungeons
    ----------------

    -- Banished Cells II
    [46433] = true, -- DUN_BCH_Knockback&Knockdown (High Kinlord Rilis),

    -- Elden Hollow I
    [25723] = true, -- CON_Knockback&Knockdown (Bakkhara),

    -- City of Ash II
    [55429] = true, -- Magma Prison (Valkyn Skoria),

    -- Tempest Island
    [26938] = true, -- Enervating Stone (Stormfist),

    -- Frostvault
    [109838] = true, -- End Stun (Icestalker) -- Frostvault,
    [119461] = true, -- Teleport Failsafe (Border Chk) -- Frostvault,

    -- Dreadsail Reef
    [166794] = true, -- Raging Current -- Dreadsail Reef,

    -- Endless Archive
    [192506] = true, -- Unstable Metamorphosis,
    [192956] = true, -- Enter the Endless,
    [192972] = true, -- Enter the Endless,
    [194570] = true, -- Enter the Endless,
    [194571] = true, -- Enter the Endless,
    [202803] = true, -- Enter the Endless (Group),
    [203101] = true, -- Vision Select,
    [203125] = true, -- Verse Select,
    [211431] = true, -- Side Content Transporter,
    [211433] = true, -- Side Content Selector (Group),
    [212065] = true, -- Enter the Endless,

    -- Lucient Citadel
    [218509] = true, -- Arcane Encumberance,

    ----------------
    -- Miscelaneous
    ----------------

    -- Snare Effects
    [8239] = true, -- Hamstring,
    [10650] = true, -- Oil Drenched,
    [85656] = true, -- Harry,
    [101693] = true, -- Arrow Spray,
    [127795] = true, -- Living Dark,
    [160949] = true, -- Warmth,
}

--- @class (partial) IgnoreList
CrowdControl.IgnoreList = ignoreList
