-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local Abilities = Data.Abilities

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
-- Fake Stagger Effects - For debuffs applied on the player or on a target that don't need to check for a removal condition (Useful for effects like staggers where this is no way to break out of them for the short duration they are applied.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) FakeStagger
local fakeStagger =
{
    -- Player Basic
    [115607] = { duration = 2000 }, -- Hard Dismount (Mount)
    [141004] = { duration = 2000 }, -- Hard Dismount (Passenger Mount)

    -- Dual Wield
    [126640] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Stagger (Hidden Blade)
    [126650] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Stagger (Shrouded Daggers)
    [126655] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Stagger (Flying Blade)

    -- Bow
    [38649] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Poison Arrow (Venom Arrow)

    -- Destruction Staff
    [48009] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Stagger (Crushing Shock)

    -- On Player
    [2874] = { duration = 433 },                                                                                         -- Staggered (Generic Stagger applied to player by many different NPC abilities)
    [29402] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Power Bash (Stagger when hit with Power Bash)
    [29765] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Uber Attack (Player staggers self by hitting Blocking NPC with Heavy Attack)
    [68971] = { duration = 433 },                                                                                        -- Staggered (Echatere - Shockwave)
    [12426] = { duration = 433 },                                                                                        -- Raven Storm (Hagraven)
    [32698] = { duration = 433 },                                                                                        -- Pulverize (Lurcher - Pulverize)
    [5349] = { duration = 433 },                                                                                         -- Stagger (Ogre - Shockwave)
    [49405] = { duration = 433 },                                                                                        -- Rear Up (Mantikora)
    [76133] = { duration = 433 },                                                                                        -- Stumble Forward (Flesh Colossus - Blocked)
    [65755] = { duration = 600 },                                                                                        -- Staggered (Flesh Colossus - Block Pin)
    [68826] = { duration = 600 },                                                                                        -- Staggered (Flesh Colossus - Block Sweep)
    [74794] = { duration = 433 },                                                                                        -- Black Winter (Harvester)
    [32023] = { duration = 433 },                                                                                        -- Generic Stagger Enemy (Bloodfiend)
    [17206] = { duration = 433 },                                                                                        -- Bone Saw (Bone Colossus)
    [45576] = { duration = 433 },                                                                                        -- Generic Stagger Enemy (Werewolf)
    [69157] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Retaliation (Winterborn Warrior)
    [69153] = { duration = 1000 },                                                                                       -- Retaliation (Winterborn Warrior)
    [54050] = { duration = 500 },                                                                                        -- Divine Leap Stun (Vosh Rakh Devoted)
    [77927] = { duration = 433 },                                                                                        -- Staggered (Bodyguard) (DB DLC)
    [74483] = { duration = 1000 },                                                                                       -- Fiery Grip (Sentinel) (TG DLC)
    [35115] = { duration = 1000 },                                                                                       -- Pull (Extended Chains) (Cyrodiil Guard T2)
    [47020] = { duration = 1000 },                                                                                       -- Pull (Puncturing Chains) (Cyrodiil Guard T2)

    -- Quest
    [144339] = { duration = 433 }, -- Staggered (Prince Boar) - A Foe Most Porcine
    [84284] = { duration = 433 },  -- Coursing Bones (Oskana)
    [84197] = { duration = 433 },  -- Marsh Masher (Gathongor the Mauler)
    [83161] = { duration = 433 },  -- Stone Crusher (Thodundor of the Hill)
    [83141] = { duration = 433 },  -- Ground Shock (Thodundor of the Hill)

    --[[
    [64322] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Glacial Spikes', duration = 1000}, -- Glacial Spikes (For King and Glory - Urfon Ice-Heart) - TEMP FIX
    [72479] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Glacial Spikes', duration = 1000}, -- Glacial Spikes (For King and Glory - Urfon Ice-Heart) - TEMP FIX
    [75463] = {icon = 'esoui/art/icons/ability_debuff_stagger.dds', name = Abilities.Innate_Stagger, duration = 433}, -- Magma Diver (The King's Gambit - Shield-Wife Razbela)
    [67156] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Kindlepitch Slick', duration = 550}, -- Kindlepitch Slick (Blood on a King's Hands) (Can't be dispelled so best option)
    [70543] = {icon = 'esoui/art/icons/ability_debuff_snare.dds', name = 'Oil Fire', duration = 550}, -- Kindlepitch Slick (Blood on a King's Hands) (Can't be dispelled so best option)
    ]]
    --

    -- Vvardenfell
    [86576] = { duration = 433 }, -- Renduril the Hammer (Nchuleftingth)
    [88510] = { duration = 433 }, -- Staggered (Vvardenfell -- Ancestral Adversity)

    -- Elsweyr
    [121476] = { duration = 433 }, -- Devastating Leap (Bone Flayer) (Bright Moons, Warm Sands)

    -- On Target
    [86310] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 500 }, -- Stagger (Player Blocks charged NPC attack)
    [21972] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 500 }, -- Stagger (Player interrupts NPC cast)

    -- Dragonstar Arena
    [53290] = { icon = "/esoui/art/icons/ability_debuff_stagger.dds", name = Abilities.Innate_Stagger, duration = 433 }, -- Stagger (Sovngarde Icemage)

    -- Maelstrom Arena
    [72012] = { duration = 700 }, -- Stagger (Iceberg)
    [71938] = { duration = 600 }, -- Frost Nova (Huntsman Chillbane)
    [72750] = { duration = 433 }, -- Freezing Stomp (Matriarch Runa)

    -----------------
    -- Dungeons -----
    -----------------

    -- Elden Hollow I
    [44093] = { duration = 433 }, -- Battlecry (Akash gra-Mal)
    [44092] = { duration = 433 }, -- Generic Stagger Enemy (Chokethorn)

    -- City of Ash I
    [44090] = { duration = 433 }, -- Generic Stagger Enemy (Infernal Guardian)
    [44089] = { duration = 433 }, -- Generic Stagger Enemy (Infernal Guardian)

    -- City of Ash II
    [55657] = { duration = 433 }, -- Venomous Explosion (Venomous Skeleton)
    [56264] = { duration = 500 }, -- Stagger (Horvantud the Fire Maw)
    [54221] = { duration = 500 }, -- Monstrous Cleave (Ash Titan)
    [54859] = { duration = 500 }, -- Stagger (Ash Titan)
    [56551] = { duration = 433 }, -- Lava Quake (Valkyn Skoria)

    -- Tempest Island
    [46737] = { duration = 433 }, -- Piercing Shriek (Sonolia the Matriarch)
    [46808] = { duration = 100 }, -- Stagger (Twister)

    -- Crypt of Hearts II
    [53403] = { duration = 433 }, -- Thunder Fist (Ilambris Amalgam)
    [51543] = { duration = 433 }, -- Necrotic Blast (Nerien'eth)
    [51867] = { duration = 567 }, -- Force Pulse (Nerien'eth)
    [52494] = { duration = 567 }, -- Ebony Whirlwind (Nerien'eth)

    -- Frostvault
    [117291] = { duration = 433 }, -- Stagger (Coldsnap Ogre)
    [109810] = { duration = 600 }, -- Frozen Aura (Icestalker)
}

--- @class (partial) FakeStagger
Effects.FakeStagger = fakeStagger
