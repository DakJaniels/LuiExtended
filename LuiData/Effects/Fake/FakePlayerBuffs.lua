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
-- Fake buffs applied onto the player by self (also supports debuffs with debuff = true)
-- onlyExtra -- Only display this if the Show Extra Buffs menu option is enabled
-- onlyExtended -- Only display this if the Show Extra Buffs menu option with "Extend Settings to Single Aura Effects" is enabled.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) FakePlayerBuffs
local fakePlayerBuffs =
{
    -- Misc Consumables
    -- [85355] = {icon = 'LuiExtended/media/icons/mementos/memento_fire-breathers_torches.dds', name = Abilities.Memento_Fire_Breathers_Torches, duration = 12000}, -- Flame Juggling (Consumable Version)
    -- [85354] = {icon = 'LuiExtended/media/icons/mementos/memento_jugglers_knives.dds', name = Abilities.Memento_Jugglers_Knives, duration = 12000}, -- Dagger Juggling (Consumable Verison)
    -- [85353] = {icon = 'LuiExtended/media/icons/mementos/memento_sword-swallowers_blade.dds', name = Abilities.Memento_Sword_Swallowers_Blade, duration = 12000}, -- Sword Swallowing (Consumable Version)

    -- Base Mementos
    [41988] = { duration = 10000 }, -- Bonesnap Binding Stone (Bonesnap Binding Stone)
    [39245] = { duration = 10000 }, -- Glimpse of the Forbidden (Discoure Amaranthine)
    -- [42076] = {icon = 'LuiExtended/media/icons/mementos/memento_mezha-dros_sealing_amulet.dds', name = Abilities.Memento_Sealing_Amulet, duration = 8000}, -- Tear (Mezha-dro's Sealing Amulet)
    -- [34578] = {icon = 'LuiExtended/media/icons/mementos/memento_nirnroot_wine.dds', name = Abilities.Memento_Nirnroot_Wine, duration = 8000}, -- Nirnroot Wine (Nirnroot Wine)
    [26339] = { duration = 5500 },  -- Questionable Meat Sack (Questionable Meat Sack)
    [25369] = { duration = 10000 }, -- Sanguine's Goblet (Sanguine's Goblet)
    [42008] = { duration = 10000 }, -- Blessing of Root Sunder (Token of Root Sunder)
    -- [42053] = {icon = 'LuiExtended/media/icons/mementos/memento_yokudan_totem.dds', name = Abilities.Memento_Yokudan_Totem, duration = 10000}, -- Yokudan Salute (Yokudan Totem)

    -- DLC Mementos
    -- [89550] = {icon = 'LuiExtended/media/icons/mementos/memento_twilight_shard.dds', name = Abilities.Memento_Twilight_Shard, duration = 9000 }, -- TROPHY Azura's Light (Twilight Shard)
    -- [79510] = {icon = 'LuiExtended/media/icons/mementos/memento_blade_of_the_blood_oath.dds', name = Abilities.Memento_Blade_of_the_Blood_Oath, duration = 6500}, -- TROPHY Blood Oath (Blade of the Blood Oath)
    -- [74151] = {icon = 'LuiExtended/media/icons/mementos/memento_hidden_pressure_vent.dds', name = Abilities.Memento_Hidden_Pressure_Vent, duration = 2500}, -- Stun (Hidden Pressure Vent)

    -- Crown Store Mementos
    [85349] = { duration = 180000 }, -- Storm Atronach Transform (Atronach Transformation)
    -- [85347] = {icon = 'LuiExtended/media/icons/mementos/memento_storm_atronach_juggle.dds', name = Abilities.Memento_Storm_Orb_Juggle, duration = 12000}, -- Storm Orb Juggle (Atronach Juggling)
    [86977] = { duration = 180000 }, -- Spriggan Transformation (Wild Hunt Transform)
    [92868] = { duration = 180000 }, -- Dwarven Transformation (Dwemervamidium Mirage)
    -- [97273] = { icon = 'LuiExtended/media/icons/mementos/memento_crows_calling.dds', name = Abilities.Memento_Crows_Calling, duration = 9000 }, -- TROPHY Death Crate Mem 1 (Crow's Calling)
    [97274] = { duration = 180000 }, -- Swarm of Crows (Swarm of Crows)

    -- [99318] = { icon = 'LuiExtended/media/icons/mementos/memento_fiery_orb.dds', name = Abilities.Memento_Fiery_Orb, duration = 9000 }, -- TROPHY Flame Crate Mem 1 (Fiery Orb)
    -- [99319] = { icon = 'LuiExtended/media/icons/mementos/memento_flame_pixie.dds', name = Abilities.Memento_Flame_Pixie, duration = 8000 }, -- Flame Crate Memento 2 (Flame Pixie)
    -- [99320] = { icon = 'LuiExtended/media/icons/mementos/memento_flame_eruption.dds', name = Abilities.Memento_Flame_Eruption, duration = 2000 }, -- TROPHY Flame Crate Mem 3 (Flame Eruption)
    -- [101874] = { icon = 'LuiExtended/media/icons/mementos/memento_scalecaller_frost_shard.dds', name = Abilities.Memento_Frost_Shard, duration = 10000 }, -- _CRWN Dragon Priest Mem2 Ice T (Scalecaller Frost Shard)
    -- [101877] = { icon = 'LuiExtended/media/icons/mementos/memento_scalecaller_rune_of_levitation.dds', name = Abilities.Memento_Rune_of_Levitation, duration = 9000 }, -- _CRWN Dragon Priest Mem1 Fl/St (Scalecaller Rune of Levitation)
    -- [101872] = { icon = 'LuiExtended/media/icons/mementos/memento_bone_dragon_summons_focus.dds', name = Abilities.Memento_Dragon_Summons_Focus, duration = 5000 }, -- _CRWN Dragon Priest Memento3 (Bone Dragon Summons Focus)
    [110483] = { duration = 6800 }, -- Ghost Lantern (Ghost Lantern)

    -- Set Items
    [149413] = { duration = 0 },              -- Wrath of Elements (Vateshran Destruction Staff)
    [98421] = { duration = 15000 },           -- Pirate Skeleton
    [98419] = { duration = 15000 },           -- Pirate Skeleton
    [98420] = { duration = 15000 },           -- Pirate Skeleton
    [81675] = { duration = 15000 },           -- Pirate Skeleton
    [83288] = { duration = 15000 },           -- Pirate Skeleton
    [83287] = { duration = 15000 },           -- Pirate Skeleton
    -- [124303] = { duration = 3000 }, -- Senche-Raht's Grit (Senche-Raht's)
    [117082] = { duration = 0 },              -- Frozen Watcher (Frozen Watcher)
    [134930] = { duration = 0 },              -- Duneripper's Scales
    [135554] = { duration = 0 },              -- Grave Guardian (Grave Guardian's)
    [106867] = { duration = 10000 },          -- Grace of Gloom (Gloom-Graced)
    [139552] = { duration = 0, long = true }, -- Snow Treaders (Snow Treaders)

    -- Set ICD's
    [129477] = { duration = 20000, debuff = true },                   -- Immortal Warrior
    [127235] = { duration = 60000, shiftId = 999010, debuff = true }, -- Eternal Warrior
    [127032] = { duration = 60000, shiftId = 999011, debuff = true }, -- Phoenix
    [142401] = { duration = 60000, shiftId = 999012, debuff = true }, -- Juggernaut

    -- Player (Basic)
    [123970] = { duration = 3000 }, -- Lesser Reincarnate

    -----------------
    -- Class --------
    -----------------

    -- Dragonknight
    [32956] = { duration = 0 },                                        -- Standard of Might (Standard of Might)

    [29004] = { duration = "GET", onlyExtended = true },               -- Dragon Blood
    [32744] = { duration = "GET", onlyExtra = true },                  -- Green Dragon Blood
    [32722] = { duration = "GET", onlyExtended = true },               -- Coagulating Blood

    [92507] = { duration = "GET", shiftId = 29043, onlyExtra = true }, -- Molten Weapons
    [92503] = { duration = "GET", shiftId = 31874, onlyExtra = true }, -- Igneous Weapons

    [31841] = { duration = 2500 },                                     -- Inhale
    [32796] = { duration = 2500 },                                     -- Deep Breath
    [32788] = { duration = 2500 },                                     -- Draw Essence

    -- Nightblade
    [90587] = { duration = "GET", shiftId = 33375, onlyExtended = true }, -- Blur
    [90593] = { duration = "GET", shiftId = 35414, onlyExtra = true },    -- Mirage
    [90620] = { duration = "GET", shiftId = 35419, onlyExtended = true }, -- Phantasmal Escape

    [33317] = { duration = "GET", shiftId = 33316, onlyExtra = true },    -- Drain Power
    [131344] = { duration = "GET", shiftId = 36901, onlyExtra = true },   -- Power Extraction
    [62240] = { duration = "GET", shiftId = 36891, onlyExtra = true },    -- Sap Essence

    -- Templar
    [22223] = { duration = 4000 }, -- Rite of Passage (Rite of Passage)
    [22229] = { duration = 4000 }, -- Remembrance (Remembrance)
    [22226] = { duration = 6000 }, -- Practiced Incantation (Practiced Incantation)

    -- Warden
    [87019] = { duration = "GET", onlyExtra = true, shiftId = 85862 },    -- Minor Endurance (Enchanted Growth)

    [86224] = { duration = "GET", onlyExtended = true, shiftId = 86122 }, -- Major Resolve (Frost Cloak)
    [88758] = { duration = "GET", onlyExtended = true, shiftId = 86126 }, -- Major Resolve (Expansive Frost Cloak)
    [88761] = { duration = "GET", onlyExtra = true, shiftId = 86130 },    -- Major Resolve (Ice Fortress)

    [86135] = { duration = "GET" },                                       -- Crystalized Shield (Crystallized Shield)
    [86139] = { duration = "GET" },                                       -- Crystalized Slab (Crystallized Slab)
    [86143] = { duration = "GET" },                                       -- Shimmering Shield (Shimmering Shield)

    -- Two Handed
    [28297] = { duration = "GET", onlyExtra = true }, -- Momentum
    [38794] = { duration = "GET", onlyExtra = true }, -- Forward Momentum

    -- Restoration Staff
    [37243] = { duration = "GET", onlyExtended = true, ignoreFade = true }, -- Blessing of Protection (Blessing of Protection)
    [40103] = { duration = "GET", onlyExtended = true, ignoreFade = true }, -- Blessing of Restoration (Blessing Of Restoration)
    [40094] = { duration = "GET", onlyExtra = true, ignoreFade = true },    -- Combat Prayer (Combat Prayer)

    -- Mages Guild
    [40449] = { duration = "GET" }, -- Spell Symmetry (Spell Symmetry)

    -- Psijic Order
    [122260] = { duration = "GET" }, -- Race Against Time (Race Against Time)

    -- Armor
    [63015] = { duration = "GET", onlyExtended = true, shiftId = 29556 }, -- Major Evasion (Evasion)
    [63019] = { duration = "GET", onlyExtended = true, shiftId = 39195 }, -- Major Evasion (Shuffle)
    [126958] = { duration = "GET" },                                      -- Elude (Elude)

    -- Vampire
    [145002] = { duration = 5000, debuff = true }, -- Blood for Blood (Blood for Blood)

    -- Werewolf
    [137206] = { duration = "GET", debuff = true }, -- Major Berserk (Hircine's Rage)

    -- Alliance War
    [101161] = { duration = "GET", shiftId = 38566, onlyExtended = true }, -- Rapid Maneuever (Rapid Maneuver)
    [101169] = { duration = "GET", shiftId = 40211 },                      -- Retreating Maneuever (Retreating Maneuver)
    [101178] = { duration = "GET", shiftId = 40215, onlyExtra = true },    -- Charging Maneuver (Charging Maneuver)

    -- Seasonal Quests (New Life Festival)
    -- [84125] = {icon = 'esoui/art/icons/achievement_newlifefestival_002.dds', name = Abilities.Skill_Lava_Foot_Stomp, duration = 10000}, -- Breton Male Dance (Lava Foot Stomp)
    -- [84126] = {icon = 'esoui/art/icons/achievement_newlifefestival_002.dds', name = Abilities.Skill_Lava_Foot_Stomp, duration = 10000}, -- Breton Female Dance (Lava Foot Stomp)
    -- [84127] = {icon = 'esoui/art/icons/achievement_newlifefestival_002.dds', name = Abilities.Skill_Lava_Foot_Stomp, duration = 10000}, -- Dunmer Male Dance (Lava Foot Stomp)
    -- [84128] = {icon = 'esoui/art/icons/achievement_newlifefestival_002.dds', name = Abilities.Skill_Lava_Foot_Stomp, duration = 10000}, -- Dunmer Female Dance (Lava Foot Stomp)
    -- [84130] = {icon = 'esoui/art/icons/achievement_newlifefestival_002.dds', name = Abilities.Skill_Lava_Foot_Stomp, duration = 10000}, -- Altmer Male Dance (Lava Foot Stomp)
    -- [84131] = {icon = 'esoui/art/icons/achievement_newlifefestival_002.dds', name = Abilities.Skill_Lava_Foot_Stomp, duration = 10000}, -- Altmer Female Dance (Lava Foot Stomp)
    -- [84133] = {icon = 'esoui/art/icons/achievement_newlifefestival_002.dds', name = Abilities.Skill_Lava_Foot_Stomp, duration = 10000}, -- Nord Dance (Lava Foot Stomp)
    -- [84528] = {icon = 'LuiExtended/media/icons/mementos/memento_fire_breathers_torches.dds', name = Abilities.Skill_Torch_Juggling, duration = 12000}, -- Flame Juggling (Castle Charm Challenge)
    -- [84506] = {icon = 'LuiExtended/media/icons/mementos/memento_jugglers_knives.dds', name = Abilities.Skill_Knife_Juggling, duration = 12000}, -- Dagger Juggling (Castle Charm Challenge)
    -- [84533] = {icon = 'LuiExtended/media/icons/mementos/memento_sword_swallowers_blade.dds', name = Abilities.Skill_Sword_Swallowing, duration = 12000}, -- Sword Swallowing (Castle Charm Challenge)
    -- [84847] = {icon = 'LuiExtended/media/icons/abilities/ability_quest_celebratory_belch.dds', name = Abilities.Skill_Celebratory_Belch, duration = 5000}, -- Celebratory Belch (Stonetooth Bash)

    ------------------------------
    -- Quests --------------------
    ------------------------------

    -- Mages Guild
    [26406] = { duration = 0 }, -- MG2 Captured Essence (Simply Misplaced)
    [26634] = { duration = 0 }, -- MG2 Captured Sahdina Essence
    [26581] = { duration = 0 }, -- MG2 Captured Rashomta Essence

    -- Aldmeri Dominion Quests
    [33066] = { icon = "LuiExtended/media/icons/disguises/disguise_fancy_clothing.dds", name = Abilities.Skill_Fancy_Clothing, duration = 0, long = true, ignoreBegin = true },        -- Q4586_ChangeClothes
    [34842] = { icon = "LuiExtended/media/icons/disguises/disguise_fancy_clothing_female.dds", name = Abilities.Skill_Fancy_Clothing, duration = 0, long = true, ignoreBegin = true }, -- Q4586_ChangeClothesFEMALE
    -- [29504] = { duration = 0, long = true }, -- Q4546 Shade Layer
    -- [34597] = { duration = 0, long = true }, -- Q4690 Forest Spirit Layer

    -- Quest related (Craglorn)
    -- [81807] = {icon = 'esoui/art/icons/achievement_104.dds', name = 'Power of the Stars', duration = 22000}, -- Power of the Stars (The Star-Gazers)

    -- Orsinium
    -- [66453] = {icon = 'LuiExtended/media/icons/abilities/ability_innate_hidden.dds', name = 'Hiding', duration = 45000}, -- Hiding (A Question of Succession)
}

--- @class (partial) FakePlayerBuffs
Effects.FakePlayerBuffs = fakePlayerBuffs
