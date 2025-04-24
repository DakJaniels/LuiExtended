-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

local BUFF_EFFECT_TYPE_BUFF = BUFF_EFFECT_TYPE_BUFF
local BUFF_EFFECT_TYPE_DEBUFF = BUFF_EFFECT_TYPE_DEBUFF

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
-- Fake Ground Damaging Effect Auras - We use EffectOverride to pull information for these unlike the other tables above.
-- duration = duration of the effect
-- type = BUFF_EFFECT_TYPE_BUFF or BUFF_EFFECT_TYPE_DEBUFF
-- merge = Simple merge functionality for id's - these will be considered the same ID so as not to display multiple auras (for effects that have consecutive hits with different id's like Pestilent Colossus)
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) AddGroundDamageAura
local addGroundDamageAura =
{

    --------------------
    -- PLAYER
    --------------------

    -- Siege
    [104693] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Meatbag Catapult
    [104695] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Scattershot Catapult

    -- Sets
    [59591] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },    -- Bogdan Totem (Bogdan the Nightflame)
    [97883] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Domihaus (Domihaus)
    [97899] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Domihaus (Domihaus)
    [97857] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },    -- Earthgore (Earthgore)
    [84502] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Grothdarr (Grothdarr)
    [80526] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Ilambris
    [81038] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },    -- Sentinel of Rkugamz
    [59498] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Spawn of Mephala
    [80522] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Stormfist
    [102094] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Thurvokun
    [75692] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Bahraha's Curse
    [97539] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },    -- Draugr's Rest
    [67204] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Leeching Plate (of Leeching)
    [133494] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Aegis Caller (Aegis Caller's)
    [135658] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Winter's Respite (of Winter's Respite)

    -- Dragonknight
    [28995] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Dragonknight Standard
    [32960] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Shifting Standard
    [32964] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Shifting Standard
    [32948] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Standard of Might

    [61772] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Ash Cloud (Ash Cloud)
    [34791] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Cinder Storm (Cinder Storm)
    [32711] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Eruption (Eruption)

    -- Nightblade
    [36052] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Twisting Path (Twisting Path)
    [64006] = { duration = 2000, type = BUFF_EFFECT_TYPE_BUFF },   -- Refreshing Path (Refreshing Path)
    [36490] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Veil of Blades (Veil of Blades)

    -- Sorcerer
    [23189] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Lightning Splash (Lightning Splash)
    [23202] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Liquid Lightning (Liquid Lightning)
    [23208] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Lightning Flood (Lightning Flood)
    [80435] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Suppression Field (Suppression Field)
    [80405] = { duration = 600, type = BUFF_EFFECT_TYPE_BUFF },    -- Absorption Field (Absorption Field)

    -- Templar
    [95931] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Spear Shards
    [95955] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Luminous Shards
    [26879] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Blazing Spear

    [26286] = { duration = 2100, type = BUFF_EFFECT_TYPE_BUFF },   -- Healing Ritual (Cleansing Ritual)
    [80172] = { duration = 2100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Ritual of Retribution
    [26303] = { duration = 2100, type = BUFF_EFFECT_TYPE_BUFF },   -- Extended Ritual

    [112145] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },  -- Rune Focus (Rune Focus)
    [112166] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },  -- Channeled focus (Channeled Focus)
    [112167] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },  -- Rune Focus Circle Bonus (Restoring Focus)

    [22225] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Rite of Passage
    [22231] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Remembrance
    [22228] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Practiced Incantation

    [21753] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Nova
    [21756] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Solar Prison
    [21759] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Solar Disturbance

    -- Warden
    [130406] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Arctic Blast (Arctic Blast)

    [129434] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Budding Seeds (Budding Seeds)

    [85534] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },    -- Secluded Grove (Secluded Grove)
    [88747] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },    -- Enchanted Forest (Enchanted Forest)
    [88783] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Impaling Shards (Impaling Shards)
    [88791] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Gripping Shards (Gripping Shards)
    [88802] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Winter's Revenge (Winter's Revenge)

    [86247] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Sleet Storm (Sleet Storm)
    [88860] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Northern Storm (Northern Storm)
    [88863] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Permafrost (Permafrost)

    -- Necromancer
    [115254] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Boneyard (Boneyard)
    [117809] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Unnerving Boneyard (Unnerving Boneyard)
    [117854] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Avid Boneyard (Avid Boneyard)

    [116410] = { duration = 500, type = BUFF_EFFECT_TYPE_DEBUFF },             -- Shocking Siphon (Shocking Siphon)
    [118766] = { duration = 500, type = BUFF_EFFECT_TYPE_DEBUFF },             -- Detonating Siphon (Detonating Siphon)
    [118011] = { duration = 500, type = BUFF_EFFECT_TYPE_DEBUFF },             -- Mystic Siphon (Mystic Siphon)

    [122178] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Frozen Colossus (Frozen Colossus)
    [122399] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF, merge = 2 }, -- Pestilent Colossus (Pestilent Colossus)
    [122400] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF, merge = 2 }, -- Pestilent Colossus (Pestilent Colossus)
    [122401] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF, merge = 2 }, -- Pestilent Colossus (Pestilent Colossus)
    [122392] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Glacial Colossus (Glacial Colossus)

    [118289] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Ravenous Goliath (Ravenous Goliath)

    [115385] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },              -- Life amid Death (Life amid Death)
    [118021] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },              -- Renewing Undeath (Renewing Undeath)
    [118813] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },              -- Enduring Undeath (Enduring Undeath)

    -- Two-Handed
    [126474] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Stampede (Stampede)

    -- Bow
    [28877] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Volley (Volley)
    [38690] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Endless Hail (Endless Hail)
    [38696] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Arrow Barrage (Arrow Barrage)

    -- Destruction Staff
    [62896] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Wall of Fire
    [62971] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Wall of Storms
    [62931] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Wall of Frost
    [39054] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Unstable Wall of Fire
    [39079] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Unstable Wall of Storms
    [39071] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Unstable Wall of Frost
    [62912] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Blockade of Fire
    [62990] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Blockade of Storms
    [62951] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Blockade of Frost

    [83626] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Fire Storm
    [83631] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Thunder Storm
    [83629] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Ice Storm
    [85127] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Fiery Rage
    [85131] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Thunderous Rage
    [85129] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Icy Rage
    [83683] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Eye of Flame
    [83687] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Eye of Lightning
    [83685] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Eye of Frost

    -- Restoration Staff
    [28386] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF }, -- Grand Healing
    [40059] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF }, -- Illustrious Healing
    [40061] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF }, -- Healing Springs

    -- Fighters Guild
    [80293] = { duration = 600, type = BUFF_EFFECT_TYPE_BUFF }, -- Ring of Preservation (Ring of Preservation)

    -- Mages Guild
    [63429] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Meteor (Meteor)
    [63454] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Ice Comet (Ice Comet)
    [63471] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Shooting Star (Shooting Star)

    -- Undaunted
    [39299] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Necrotic Orb (Necrotic Orb)
    [42029] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Mystic Orb (Mystic Orb)
    [42039] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Energy Orb (Energy Orb)

    -- Vampire
    [38935] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Swarming Scion

    -- Assault
    [38561] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Caltrops (Caltrops)
    [40267] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [40252] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Razor Caltrops (Razor Caltrops)

    -- Volendrung
    [116669] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Ebony Cyclone (Ruinous Cyclone)

    --------------------
    -- TRAPS
    --------------------

    [17314] = { duration = 2000, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Fire Trap (Player)

    [72888] = { duration = 2000, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Fire Attack 1 (Fire) -- Banished Cells II
    [72889] = { duration = 2000, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Fire Attack 2 (Fire) -- Banished Cells II

    [33594] = { duration = 2000, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Fire (Fire) -- Throne of the Wilderking

    [27940] = { duration = 350, type = BUFF_EFFECT_TYPE_DEBUFF },   -- Laser Damage (Generic Flame Wave Shooter) -- Stros M'Kai
    [32245] = { duration = 2000, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Searing Steam (Steam Trap) -- Stros M'Kai

    [26040] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },   -- Steam Blast (Steam Vent) -- Volenfell
    [26089] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },   -- Steam Blast (Steam Vent) -- Volenfell
    [26091] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },   -- Steam Blast (Steam Vent) -- Volenfell
    [26077] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },   -- Steam Blast (Steam Vent) -- Volenfell

    [110416] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Putrid Cloud (Gas Blossom) -- Housing
    [110542] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Stunted Current (Static Pitcher) -- Housing

    --------------------
    -- NPC
    --------------------

    -- Cyrodiil
    [7883] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Guardian Storm (Cyrodiil Mage)
    [46819] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Storm Damage (Cyrodiil Mage)
    [52866] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Volley (Cyrodiil Archer)
    [54258] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Upgraded Volley (Cyrodiil Archer)
    [70414] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Ignite (Cyrodiil Archer)

    -- Human
    [38125] = { duration = 1500, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Caltrops  (Faction NPCs)
    [14068] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Ignite (Archer Synergy)
    [10813] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Ignite (Mage Synergy)
    [38260] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Ignite (Mage Synergy)
    [28629] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Volley (Archer)
    [47102] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Fire Rune (Fire Mage)
    [37131] = { duration = 2000, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Ice Cage (Battlemage)
    [44228] = { duration = 1200, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Dragonknight Standard (Dragonknight - NPC)

    [76624] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Pool of Shadow (Voidbringer)
    [76728] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Pool of Shadow (Voidbringer)

    [88330] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Pool of Shadow (Masquer)
    [88334] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Pool of Shadow (Masquer)

    [84837] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Broken Pact (Skaafin Witchling)

    -- Animal
    [16698] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Poisonbloom (Netch)
    [90778] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Acid Pool (Nix-Ox)
    [90815] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Acid Pool (Nix-Ox)
    [85421] = { duration = 750, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Retch (Cliff Strider)

    -- Insect
    [13680] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Acid Blood (Assassin Beetle)
    [5265] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Burning Ground (Shalk)
    [72794] = { duration = 750, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Toxic Pool (Haj Mota)
    [87126] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Heat Vents (Fetcherfly Nest)

    -- Monsters
    [4769] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },   -- Choking Pollen (Lurcher)
    [16040] = { duration = 1500, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Hurricane (Nereid)
    [75928] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Elemental Pool (Minotaur)
    [75953] = { duration = 2000, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Brimstone Hailfire (Minotaur Shaman)
    [75976] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Pillar of Nirn (Minotaur Shaman)
    [8628] = { duration = 800, type = BUFF_EFFECT_TYPE_DEBUFF },   -- Charged Ground (Harpy)
    [103862] = { duration = 750, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Deluge (Yaghra Spewer)
    [103992] = { duration = 750, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Luminescent Burn (Yaghra Spewer)

    -- Daedra
    [9749] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Envelop (Banekin)
    [91938] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Burst of Embers (Daedroth)
    [51645] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Frozen Ground (Frost Atronach)
    [6162] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Rain of Fire (Scamp)
    [88323] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Blast Furnace (Iron Atronach)
    [73437] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Soul Flame (Daedric Titan)
    [53233] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Miasma Pool (Flesh Colossus)

    -- Undead
    [20812] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Defiled Ground (Lich)
    [73929] = { duration = 1000, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Soul Cage (Lich)
    [73937] = { duration = 1000, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Soul Cage (Lich)
    [69950] = { duration = 2100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Desecrated Ground (Desecrated Ground - Undead Synergy)

    -- Dwemer
    [19997] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },           -- Static Field (Dwemer Spider)

    [91094] = { duration = 650, type = BUFF_EFFECT_TYPE_DEBUFF, merge = 1 }, -- Split Bolt (Dwemer Arquebus)
    [91095] = { duration = 650, type = BUFF_EFFECT_TYPE_DEBUFF, merge = 1 }, -- Split Bolt (Dwemer Arquebus)
    [91096] = { duration = 650, type = BUFF_EFFECT_TYPE_DEBUFF, merge = 1 }, -- Split Bolt (Dwemer Arquebus)

    ------------------
    -- WORLD BOSSES --
    ------------------

    -- Auridon
    [84045] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Seal of Defilement (Quenyas)

    -- Greenshade
    [84206] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Stinging Sputum (Gathongor the Mauler)

    -- Stormhaven
    [84160] = { duration = 2100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Spit Poison (Old Widow Silk)
    [83000] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Crabuchet (Titanclaw)

    ------------------
    -- QUESTS --------
    ------------------

    -- Elsweyr
    [121644] = { duration = 800, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Defiled Ground (Euraxian Necromancer) (Bright Moons, Warm Sands)

    -- Summerset

    ------------------
    -- ARENAS --------
    ------------------

    -- Dragonstar Arena
    [53314] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Flame Volley (Sovngarde Ranger)
    [53280] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Unstable Wall of Frost (Sovngarde Icemage)

    [53341] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Biting Cold (Biting Cold)
    [60421] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Biting Cold (Biting Cold)

    [83498] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Poisonous Cloud (Poison Cloud)
    [53625] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Lightning Flood (Nak'tah)
    [54080] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Cinder Storm (Earthen Heart Knight)
    [52903] = { duration = 1200, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Standard of Might (Anal'a Tu'wha)
    [83468] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Restoring Nature (Nature's Blessing)
    [52933] = { duration = 1200, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Solar Disturbance (Shadow Knight)
    [55086] = { duration = 1700, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Poison Mist (Vampire Lord Thisa)
    [55092] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Devouring Swarm (Vampire Lord Thisa)
    [55182] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Marked for Death (Hiath the Battlemaster)

    -- Maelstrom Arena
    [68197] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Necrotic Essence (Necrotic Orb)
    [70901] = { duration = 1200, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Defiled Grave (Maxus the Many)
    [72149] = { duration = 1200, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Defiled Grave (Maxus the Many)

    [69101] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Shock (Generator)
    [66797] = { duration = 333, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Spinning Blade (Blade Trap)
    [69102] = { duration = 600, type = BUFF_EFFECT_TYPE_BUFF },    -- Heal (Generator)
    [69316] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Electric Shield (Centurion Champion)

    [67871] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Shock (Water)
    [67758] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Queen's Poison (Lamia Queen)
    [68358] = { duration = 1100, type = BUFF_EFFECT_TYPE_BUFF },   -- Queen's Radiance (Lamia Queen)
    [72159] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Static Field (Dwarven Spider)
    [70860] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Overheated Flame (The Control Guardian)

    [72525] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Frigid Waters (Player)
    [67808] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Frigid Waters (Player)

    ------------------
    -- DUNGEONS ------
    ------------------

    -- Banished Cells I
    [19027] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Dead Zone (Skeletal Destroyer)
    [33188] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Daedric Tempest (High Kinlord Rilis)

    -- Banished Cells II
    [28904] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Immolating Bite (Maw of the Infernal)
    [31727] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Corruption (Daedric Chaos)
    [48800] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Daedric Tempest (High Kinlord Rilis)
    [48815] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Daedric Tempest (High Kinlord Rilis)

    -- Elden Hollow I
    [42601] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Necrotic Circle (Canonreeve Oraneth)

    -- Elden Hollow II
    [32972] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Consuming Shadow (Murklight)
    [33050] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Eclipse (Murklight)
    [33103] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Spout Shadow (The Shadow Guard)
    [33434] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Daedric Flame (Bogdan the Nightflame)

    -- City of Ash I
    [34960] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Blazing Fire (Warden of the Shrine)
    [34204] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Burning Field

    -- City of Ash II
    [56415] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Fire Runes (Urata the Legion)
    [56151] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Ethereal Flame (Ash Titan)

    -- Tempest Island
    [26619] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Shock (Sudden Storm)
    [6108] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Lightning Storm
    [26752] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Enervating Stone (Stormfist)

    -- Selene's Web
    [30908] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Summon Primal Swarm (Treethane Kerninn)
    [30773] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Arrow Rain (Longclaw)
    [31150] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Poison Burst (Longclaw)

    -- Spindleclutch II
    [27603] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Blood Pool (Urvan Veleth)
    [27906] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Blood Pool (Vorenor Winterbourne)

    -- Wayrest Sewers I
    [25591] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Necrotic Essence (Necrotic Orb)

    -- Wayrest Sewers II
    [36625] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Scourging Spark (Malubeth the Scourger)
    [36869] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Scorching Flames (Uulgarg the Risen)

    -- Crypt of Hearts I
    [22716] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Necrotic Ritual (Archmaster Siniel)
    [46950] = { duration = 900, type = BUFF_EFFECT_TYPE_DEBUFF },  -- Fire Trail (Death's Leviathan)
    [22432] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Electric Prison (Ilambris-Athor)
    [22388] = { duration = 2000, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Rain Fire (Ilambris-Zaven)

    -- Crypt of Hearts II
    [51883] = { duration = 1100, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Creeping Storm (Creeping Storm)
    [52286] = { duration = 1500, type = BUFF_EFFECT_TYPE_DEBUFF, merge = 3 }, -- Rain Fire (Ilambris-Zaven)
    [52335] = { duration = 1500, type = BUFF_EFFECT_TYPE_DEBUFF, merge = 3 }, -- Rain Fire (Ilambris-Zaven)
    [52082] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Cursed Ground (Nerien'eth)
    [53157] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF },            -- Cursed Ground (Nerien'eth)
    [53134] = { duration = 600, type = BUFF_EFFECT_TYPE_DEBUFF },             -- Tortured Souls (Nerien'eth)

    -- Volenfell
    [25143] = { duration = 1600, type = BUFF_EFFECT_TYPE_DEBUFF }, -- Burning Ground (Quintus Verres)
}


--- @class (partial) AddGroundDamageAura
Effects.AddGroundDamageAura = addGroundDamageAura
