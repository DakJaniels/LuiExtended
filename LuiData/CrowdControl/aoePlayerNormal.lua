-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
local CrowdControl = Data.CrowdControl
-- CrowdControl.aoePlayerUltimate
-- CrowdControl.aoePlayerNormal
-- CrowdControl.aoePlayerSet
-- CrowdControl.aoeTrap
-- cc.aoeBoss
-- CrowdControl.aoeElite
-- CrowdControl.aoeNormal
-- Increment by 1 here if we want to change priority. Best way to do this is +1 for a new ability, and shared morphs or other damage sources from a shared attack don't increment.
-- Priority system doesn't support gaps so NEVER more than +1 here, also the FIRST ability in each tier needs to be +0 to prevent skips if a category is disabled in the options.
--- @class (partial) aoePlayerNormal
local aoePlayerNormal =
{

    -- Psijic Order
    [104007] = 0, -- Time Stop
    [104072] = 0, -- Borrowed Time
    [104082] = 0, -- Time Freeze

    -- Dragonknight
    [32711] = 1, -- Eruption (Eruption)

    -- Warden
    [220630] = 1, -- Warden's Burst (Warden Scribing Class Charm Initial Cast)
    [220639] = 0, -- Warden's Burst (Warden Scribing Class Charm Initial Cast)

    [221173] = 1, -- Warden's Contingency (Warden Scribing Class Charm Initial Cast)
    [221174] = 0, -- Warden's Contingency (Warden Scribing Class Charm Initial Cast)

    -- [130406] = 0, -- Arctic Blast (Arctic Blast)
    [88783] = 1, -- Impaling Shards (Impaling Shards)
    [88791] = 0, -- Gripping Shards (Gripping Shards)
    [88802] = 0, -- Winter's Revenge (Winter's Revenge)

    -- Templar
    [26192] = 1, -- Spear Shards
    [95931] = 0, -- Spear Shards
    [26859] = 0, -- Luminous Shards
    [95955] = 0, -- Luminous Shards
    [26871] = 0, -- Blazing Spear
    [26879] = 0, -- Blazing Spear
    [80172] = 1, -- Ritual of Retribution (Ritual of Retribution)

    -- Sorcerer
    [23189] = 1, -- Lightning Splash (Lightning Splash)
    [23202] = 0, -- Liquid Lightning (Liquid Lightning)
    [23208] = 0, -- Lightning Flood (Lightning Flood)

    -- Nightblade
    [36052] = 1, -- Twisting Path (Twisting Path)

    -- Necromancer
    [115254] = 1, -- Boneyard (Boneyard)
    [117809] = 0, -- Unnerving Boneyard (Unnerving Boneyard)
    [117854] = 0, -- Avid Boneyard (Avid Boneyard)

    -- [116410] = 1, -- Shocking Siphon (Shocking Siphon)
    -- [118766] = 0, -- Detonating Siphon (Detonating Siphon)
    -- [118011] = 0, -- Mystic Siphon (Mystic Siphon)

    -- Arcanist
    [194844] = 0,   -- Fatecarver Snare (Exhausting Fatecarver)
    [194842] = 1,   -- Fatecarver (Fatecarver)
    [194843] = 1,   -- Fatecarver (Fatecarver, Area)
    [185805] = 1,   -- Fatecarver (Fatecarver, Area)
    [20185805] = 1, -- Fatecarver (Fatecarver, Area)
    [30185805] = 1, -- Fatecarver (Fatecarver, Area)
    [40185805] = 1, -- Fatecarver (Fatecarver, Area)
    [186366] = 1,   -- Pragmatic Fatecarver (Pragmatic Fatecarver)
    [186370] = 0,   -- Pragmatic Fatecarver (Pragmatic Fatecarver, Area)
    [20186366] = 1, -- Pragmatic Fatecarver (Pragmatic Fatecarver, Area)
    [30186366] = 1, -- Pragmatic Fatecarver (Pragmatic Fatecarver, Area)
    [40186366] = 1, -- Pragmatic Fatecarver (Pragmatic Fatecarver, Area)
    [183122] = 1,   -- Exhausting Fatecarver (Exhausting Fatecarver, Area)
    [184291] = 0,   -- Exhausting Fatecarver (Exhausting Fatecarver)
    [20183122] = 1, -- Exhausting Fatecarver (Exhausting Fatecarver, Area)
    [30183122] = 1, -- Exhausting Fatecarver (Exhausting Fatecarver, Area)
    [40183122] = 1, -- Exhausting Fatecarver (Exhausting Fatecarver, Area)
    [183123] = 0,   -- Exhausting Fatecarver (Exhausting Fatecarver, Area)
    -- [185817] = 1,   -- Abyssal Impact (Abyssal Impact)
    [186772] = 1,   -- Abyssal Impact (Abyssal Impact)
    -- [20185817] = 1, -- Abyssal Impact (Abyssal Impact)
    -- [30185817] = 1, -- Abyssal Impact (Abyssal Impact)
    -- [40185817] = 1, -- Abyssal Impact (Abyssal Impact)
    -- [183006] = 0,   -- Cephaliarch's Flail (Cephaliarch's Flail)
    [183009] = 0, -- Cephaliarch's Flail (Cephaliarch's Flail)
    -- [20183006] = 0, -- Cephaliarch's Flail (Cephaliarch's Flail)
    -- [30183006] = 0, -- Cephaliarch's Flail (Cephaliarch's Flail)
    -- [40183006] = 0, -- Cephaliarch's Flail (Cephaliarch's Flail)
    -- [185823] = 0,   -- Tentacular Dread (Tentacular Dread)
    [186773] = 0, -- Tentacular Dread (Tentacular Dread)
    -- [20185823] = 0, -- Tentacular Dread (Tentacular Dread)
    -- [30185823] = 0, -- Tentacular Dread (Tentacular Dread)
    -- [40185823] = 0, -- Tentacular Dread (Tentacular Dread)
    -- [185840] = 0, -- Rune of Displacement (Rune of Displacement, DOT)
    [187526] = 0, -- Rune of Displacement (Rune of Displacement)
    -- [185841] = 0, -- Rune of Displacement (Rune of Displacement)
    -- [195205] = 0, -- Rune of Displacement (Rune of Displacement)
    -- [195206] = 0, -- Rune of Displacement (Rune of Displacement, DOT)
    -- [195210] = 0, -- Rune of Displacement (Rune of Displacement)
    -- [198413] = 0, -- Rune of Displacement (Rune of Displacement)
    -- [186832] = 0, -- Runeguard of Still Waters (Runeguard of Still Waters Immobilize)
    -- [191083] = 1, -- Rune of Displacement (Rune of Displacement) -- Seen in Cyrodiil
    -- [187526] = 1, -- Rune of Displacement (Rune of Displacement) -- Seen in Cyrodiil
    -- [187513] = 1, -- Rune of Displacement (Rune of Displacement) -- Seen in Cyrodiil

    -- Destruction Staff
    [62896] = 1, -- Wall of Fire
    [62971] = 0, -- Wall of Storms
    [62931] = 0, -- Wall of Frost
    [39054] = 1, -- Unstable Wall of Fire
    [39079] = 0, -- Unstable Wall of Storms
    [39071] = 0, -- Unstable Wall of Frost
    [62912] = 1, -- Blockade of Fire
    [62990] = 0, -- Blockade of Storms
    [62951] = 0, -- Blockade of Frost

    -- Two-Handed
    [126474] = 1, -- Stampede

    -- Bow
    [28877] = 1, -- Volley
    [38690] = 0, -- Endless Hail
    [38696] = 0, -- Arrow Barrage
    [38707] = 0, -- Bombard

    -- Undaunted
    [39299] = 1, -- Necrotic Orb
    [42029] = 1, -- Mystic Orb

    -- Fighters Guild
    [35753] = 1, -- Trap Beast Immobilize (Trap Beast)
    [40384] = 1, -- Barbed Trap Immobilize (Barbed Trap)
    [40374] = 1, -- Lightweight Beast Trap Immobilize (Lightweight Beast Trap)

    -- Assault
    [38561] = 1,  -- Caltrops (Caltrops)
    [40267] = 0,  -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [40252] = 0,  -- Razor Caltrops (Razor Caltrops)
    [113771] = 0, -- Razor Caltrops (Razor Caltrops)

    -- Vampire
    [38968] = 0, -- Blood Mist (Blood Mist)

}

--- @class (partial) aoePlayerNormal
CrowdControl.aoePlayerNormal = aoePlayerNormal
