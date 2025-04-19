-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

--- @param summonShade integer
--- @return integer
local function GetSummonShade(summonShade)
    summonShade = 38517
    local raceId = GetUnitRaceId("player")
    if raceId == 9 then
        summonShade = 88662 -- khajiit
    elseif raceId == 6 then
        summonShade = 88663 -- argonian
    end
    return summonShade
end

--- @type integer
local summonShade

--- @param shadowImage integer
--- @return integer
local function GetShadowImage(shadowImage)
    shadowImage = 38528
    local raceId = GetUnitRaceId("player")
    if raceId == 9 then
        shadowImage = 88696 -- khajiit
    elseif raceId == 6 then
        shadowImage = 88697 -- argonian
    end
    return shadowImage
end

--- @type integer
local shadowImage

--- @param darkShade integer
--- @return integer
local function GetDarkShade(darkShade)
    darkShade = 35438
    local raceId = GetUnitRaceId("player")
    if raceId == 9 then
        darkShade = 88677 -- khajiit
    elseif raceId == 6 then
        darkShade = 88678 -- argonian
    end
    return darkShade
end

--- @type integer
local darkShade

-- AbilityTables namespace
--- @class (partial) AbilityTables
local AbilityTables =
{

    -- Dragonknight Cyrodiil Templates
    Skill_Vengeance_Standard = 237627,         -- Vengeance Dragonknight Standard
    Skill_Vengeance_Lava_Whip = 237606,        -- Vengeance Lava Whip
    Skill_Vengeance_Searing_Strike = 237607,   -- Vengeance Searing Strike
    Skill_Vengeance_Fiery_Breath = 237615,     -- Vengeance Fiery Breath
    Skill_Vengeance_Fiery_Grip = 237620,       -- Vengeance Fiery Grip
    Skill_Vengeance_Inferno = 237624,          -- Vengeance Inferno
    Skill_Vengeance_Dragon_Leap = 237648,      -- Vengeance Dragon Leap
    Skill_Vengeance_Spiked_Armor = 237630,     -- Vengeance Spiked Armor
    Skill_Vengeance_Dark_Talons = 237636,      -- Vengeance Dark Talons
    Skill_Vengeance_Dragon_Blood = 237638,     -- Vengeance Dragon Blood
    Skill_Vengeance_Protective_Scale = 237639, -- Vengeance Protective Scale
    Skill_Vengeance_Inhale = 237641,           -- Vengeance Inhale
    Skill_Vengeance_Magma_Armor = 237790,      -- Vengeance Magma Armor
    Skill_Vengeance_Stonefist = 237781,        -- Vengeance Stonefist
    Skill_Vengeance_Molten_Weapons = 237782,   -- Vengeance Molten Weapons
    Skill_Vengeance_Obsidian_Shield = 237785,  -- Vengeance Obsidian Shield
    Skill_Vengeance_Petrify = 237787,          -- Vengeance Petrify
    Skill_Vengeance_Ash_Cloud = 237788,        -- Vengeance Ash Cloud

    -- ---------------------------------------------------
    -- GENERIC BUFFS & DEBUFFS ---------------------------
    -- ---------------------------------------------------

    -- Major/Minor
    Skill_Minor_Mangle = 61733,

    -- Generic
    Skill_Off_Balance = 14062,
    Skill_Off_Balance_Immunity = 134599,
    Skill_Major_Vulnerability_Immunity = GetString(LUIE_STRING_SKILL_GENERIC_MAJOR_VULNERABILITY_IMMUNITY),
    Skill_Hindrance = 46210,

    -- ---------------------------------------------------
    -- INNATE ABILITIES ----------------------------------
    -- ---------------------------------------------------

    -- Simulated Auras
    Innate_Recall = 6811,
    Innate_Recall_Penalty = GetString(LUIE_STRING_SKILL_RECALL_PENALTY),               -- Recall Penalty
    Innate_Resurrection_Immunity = GetString(LUIE_STRING_SKILL_RESURRECTION_IMMUNITY), -- Resurrection Immunity
    Innate_Soul_Gem_Resurrection = GetString(LUIE_STRING_SKILL_SOUL_GEM_RESURRECTION), -- Soul Gem Resurrection

    -- Player Basic
    Innate_Immobilize_Immunity = 29721,
    Innate_Stun = 14756,      -- Stun
    Innate_Disguise = 31287,  -- Disguise
    Innate_Disguised = 23553, -- Disguised
    Innate_Sneak = 20299,     -- Sneak
    Innate_Hidden = 20309,    -- Hidden
    Innate_Mounted = GetString(LUIE_STRING_SKILL_MOUNTED),
    Innate_Mounted_Passenger = GetString(LUIE_STRING_SKILL_MOUNTED_PASSENGER),
    Innate_Vanity_Pet = GetString(SI_COLLECTIBLECATEGORYTYPE3),
    Innate_Assistant = GetString(SI_COLLECTIBLECATEGORYTYPE8),
    -- Innate_Sprint                     = 15614, -- Sprint
    -- Innate_Gallop                     = GetString(LUIE_STRING_SKILL_MOUNT_SPRINT), -- Gallop
    Innate_Brace = 29761,                                                              -- Brace
    Innate_Block = 2890,                                                               -- Block
    Innate_Bash = 21970,                                                               -- Bash
    Innate_Bash_Stun = 21971,                                                          -- Bash Stun
    Innate_Fall_Damage = GetString(LUIE_STRING_SKILL_FALL_DAMAGE),                     -- Fall Damage
    Innate_Absorbing_Skyshard = GetString(LUIE_STRING_SKILL_ABSORBING_SKYSHARD),       -- Absorbing Skyshard
    Innate_Receiving_Boon = GetString(LUIE_STRING_SKILL_RECEIVING_BOON),               -- Receiving Boon
    Innate_Ayleid_Well = GetString(LUIE_STRING_SKILL_AYLEID_WELL),                     -- Ayleid Well
    Innate_Ayleid_Well_Fortified = GetString(LUIE_STRING_SKILL_AYLEID_WELL_FORTIFIED), -- Ayleid Well
    Innate_Aetherial_Well = 151928,
    Innate_CC_Immunity = 38117,                                                        -- CC Immunity
    Innate_Stagger = 1834,                                                             -- Stagger
    Innate_Revive = 5823,                                                              -- Revive

    Innate_Create_Station = GetString(LUIE_STRING_SKILL_CRAFTING_STATION),
    Innate_Summon = 29585,
    Innate_Indrik_Nascent = GetCollectibleName(5710),
    Innate_Indrik_Spectral = zo_strformat("<<1>>", GetCollectibleName(6942)),
    Innate_Sovereign_Sow = GetCollectibleName(7270),
    Innate_Deadlands_Firewalker = GetCollectibleName(774),
    Innate_Unstable_Morpholith = GetCollectibleName(8124),
    Innate_Fillet_Fish = GetString(LUIE_STRING_SKILL_FILLET_FISH),
    Innate_Pardon_Edict_Low = GetString(LUIE_STRING_SKILL_COUNTERFEIT_PARDON_EDICT),
    Innate_Pardon_Edict_Medium = GetString(LUIE_STRING_SKILL_LENIENCY_EDICT),
    Innate_Pardon_Edict_High = GetString(LUIE_STRING_SKILL_GRAND_AMNESTY_EDICT),

    Innate_Merethic_Restorative_Resin = GetItemLinkName("|H0:item:69434:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Aetheric_Cipher = GetItemLinkName("|H0:item:115028:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Create_Psijic_Ambrosia_Recipe = 68258,

    Innate_Chef_Arquitius_Torte_Dissertation = GetItemLinkName("|H0:item:171430:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Chef_Arquitius_Lost_Thesis = GetItemLinkName("|H0:item:171434:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Breton_Terrier_Mammoth_Bone = GetItemLinkName("|H0:item:171469:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Mummified_Alfiq_Parts = GetItemLinkName("|H0:item:147929:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Plague_Drenched_Fabric = GetItemLinkName("|H0:item:147930:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Guar_Stomp = GetCollectibleName(6197),
    Innate_Swamp_Jelly = GetCollectibleName(5656),
    Innate_Dwarven_Theodolite = GetCollectibleName(1232),
    Innate_Big_Eared_Ginger_Kitten = GetCollectibleName(4996),
    Innate_Psijic_Glowglobe = GetCollectibleName(5047),
    Innate_Sixth_House_Robe = GetCollectibleName(1230),
    Innate_Stone_Husk_Fragment = GetItemLinkName("|H0:item:166466:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Welkynar_Binding = GetItemLinkName("|H0:item:141736:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    Innate_Arena_Gladiators_Exultation = GetItemLinkName("|H0:item:141751:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Arena_Gladiators_Mockery = GetItemLinkName("|H0:item:146042:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Arena_Gladiators_Recognition = GetItemLinkName("|H0:item:138785:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Arena_Gladiators_Roar = GetItemLinkName("|H0:item:147285:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Knights_Rebuke = GetItemLinkName("|H0:item:159544:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Knights_Resolve = GetItemLinkName("|H0:item:159535:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Reach_Mages_Ferocity = GetItemLinkName("|H0:item:166469:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Siege_of_Cyrodiil_Recognition = GetItemLinkName("|H0:item:151938:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Siege_of_Cyrodiil_Recommendation = GetItemLinkName("|H0:item:153536:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Alliance_Standard_Bearers = GetItemLinkName("|H0:item:151934:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Siege_of_Cyrodiil_Commendation = GetItemLinkName("|H0:item:171532:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Innate_Siege_of_Cyrodiil_Distinction = GetItemLinkName("|H0:item:167303:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    -- World
    Innate_Drop_Anchor = 86717,                                    -- Drop Anchor
    Innate_Anchor_Drop = GetString(LUIE_STRING_SKILL_ANCHOR_DROP), -- Anchor Drop
    Innate_Power_of_the_Daedra = 46690,                            -- Power of the Daedra

    -- Weapon Attacks
    Skill_Light_Attack = 39088,             -- Light Attack
    Skill_Medium_Attack = 39097,            -- Medium Attack
    Skill_Heavy_Attack = 39101,             -- Heavy Attack

    Skill_Light_Attack_Unarmed = 23604,     -- Light Attack (Unarmed)
    Skill_Heavy_Attack_Unarmed = 18429,     -- Heavy Attack (Unarmed)

    Skill_Light_Attack_Two_Handed = 16037,  -- Light Attack (Two Handed)
    Skill_Heavy_Attack_Two_Handed = 16041,  -- Heavy Attack (Two Handed)
    Skill_Light_Attack_One_Handed = 15435,  -- Light Attack (One Handed)
    Skill_Heavy_Attack_One_Handed = 15279,  -- Heavy Attack (One Handed)
    Skill_Light_Attack_Dual_Wield = 16499,  -- Light Attack (Dual Wield)
    Skill_Heavy_Attack_Dual_Wield = 16420,  -- Heavy Attack (Dual Wield)
    Skill_Light_Attack_Bow = 16688,         -- Light Attack (Bow)
    Skill_Heavy_Attack_Bow = 16691,         -- Heavy Attack (Bow)

    Skill_Light_Attack_Ice = 16277,         -- Light Attack (Ice)
    Skill_Heavy_Attack_Ice = 16261,         -- Heavy Attack (Ice)
    Skill_Light_Attack_Inferno = 16165,     -- Light Attack (Inferno)
    Skill_Heavy_Attack_Inferno = 15383,     -- Heavy Attack (Inferno)
    Skill_Light_Attack_Lightning = 18350,   -- Light Attack (Lightning)
    Skill_Heavy_Attack_Lightning = 18396,   -- Heavy Attack (Lightning)

    Skill_Light_Attack_Restoration = 16145, -- Light Attack (Restoration)
    Skill_Heavy_Attack_Restoration = 16212, -- Heavy Attack (Restoration)

    Skill_Light_Attack_Volendrung = 116762, -- Light Attack (Volendrung)
    Skill_Heavy_Attack_Volendrung = 116763, -- Heavy Attack (Volendrung)

    Skill_Light_Attack_Werewolf = 32464,    -- Light Attack (Werewolf)
    Skill_Heavy_Attack_Werewolf = 32477,    -- Heavy Attack (Werewolf)

    -- ---------------------------------------------------
    -- COMSUMABLES & ITEMS -------------------------------
    -- ---------------------------------------------------

    -- Glyphs
    Item_Glyph_of_Weapon_Damage = 17910,

    -- Potions/Poisons
    Potion_Invisiblity = 3668,
    Potion_Ravage_Health = 46111,
    Potion_Restore_Health = 45221,
    Potion_Restore_Magicka = 45223,
    Potion_Restore_Stamina = 45225,
    Poison_Creeping_Drain_Health = 79701,
    Poison_Lingering_Restore_Health = 79702,
    Poison_Stealth_Draining_Poison = GetString(LUIE_STRING_SKILL_POISON_STEALTH_DRAIN),
    Poison_Conspicuous_Poison = GetString(LUIE_STRING_SKILL_POISON_CONSPICUOUS),

    -- Food/Drink
    Food_Magicka_Stamina_Increase = 61294,
    Food_Health_Stamina_Increase = 61255,
    Food_Health_Magicka_Increase = 61257,
    Food_Orzorgas_Tripe_Trifle_Pocket = GetItemLinkName("|H0:item:71057:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Orzorgas_Blood_Price_Pie = GetItemLinkName("|H0:item:71058:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Orzorgas_Smoked_Bear_Haunch = GetItemLinkName("|H0:item:71059:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Pumpkin_Snack_Skewer = GetItemLinkName("|H0:item:87686:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Frosted_Brains = GetItemLinkName("|H0:item:87696:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Jagga_Drenched_Mud_Ball = GetItemLinkName("|H0:item:112434:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Lava_Foot_Soup = GetItemLinkName("|H0:item:112425:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Artaeum_Pickled_Fish_Bowl = GetItemLinkName("|H0:item:139016:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Crown_Crate_Meal = GetItemLinkName("|H0:item:94437:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Crown_Meal = GetItemLinkName("|H0:item:64711:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Crown_Combat_Mystics_Stew = GetItemLinkName("|H0:item:124675:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Food_Crown_Vigorous_Ragout = GetItemLinkName("|H0:item:124676:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Health_Recovery = 61322,
    Drink_Magicka_Recovery = 61325,
    Drink_Stamina_Recovery = 61328,
    Drink_Magicka_Stamina_Recovery = 61345,
    Drink_Health_Stamina_Recovery = 61340,
    Drink_Health_Magicka_Recovery = 61335,
    Drink_Primary_Stat_Recovery = 61350,
    Drink_Increase = GetString(LUIE_STRING_SKILL_DRINK_INCREASE),
    Drink_Orzorgas_Red_Frothgar = GetItemLinkName("|H0:item:71056:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Bowl_of_Peeled_Eyeballs = GetItemLinkName("|H0:item:87687:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Ghastly_Eye_Bowl = GetItemLinkName("|H0:item:87695:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Bergama_Warning_Fire = GetItemLinkName("|H0:item:112426:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Betnikh_Twice_Spiked_Ale = GetItemLinkName("|H0:item:112433:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Hissmir_Fish_Eye_Rye = GetItemLinkName("|H0:item:101879:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Snow_Bear_Glow_Wine = GetItemLinkName("|H0:item:112440:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Crown_Crate_Drink = GetItemLinkName("|H0:item:94438:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Crown_Drink = GetItemLinkName("|H0:item:64712:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Crown_Stout_Magic_Liqueur = GetItemLinkName("|H0:item:124677:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Drink_Crown_Vigorous_Tincture = GetItemLinkName("|H0:item:124678:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    -- Experience Consumables
    Experience_Psijic_Ambrosia = GetItemLinkName("|H0:item:64221:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),         -- Psijic Ambrosia
    Experience_Aetherial_Ambrosia = GetItemLinkName("|H0:item:120076:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),     -- Aetherial Ambrosia
    Experience_Mythic_Ambrosia = GetItemLinkName("|H0:item:115027:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),        -- Mythic Aetherial Ambrosia
    Experience_Crown_Scroll = GetItemLinkName("|H0:item:64537:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),           -- Crown Experience Scroll
    Experience_Crown_Crate_Scroll_1 = GetItemLinkName("|H0:item:94439:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),   -- Gold Coast Experience Scroll
    Experience_Crown_Crate_Scroll_2 = GetItemLinkName("|H0:item:94440:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),   -- Major Gold Coast Experience Scroll
    Experience_Crown_Crate_Scroll_3 = GetItemLinkName("|H0:item:94441:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),   -- Grand Gold Coast Experience Scroll
    Experience_Crown_Crate_Scroll_4 = GetItemLinkName("|H0:item:214517:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), -- Hero's Return Experience Scroll

    -- Alliance War Skill Consumables
    Experience_Alliance_War_Skill_1 = GetItemLinkName("|H0:item:171262:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Alliance War Skill Line Scroll
    Experience_Alliance_War_Skill_2 = GetItemLinkName("|H0:item:170148:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Alliance War Skill Line Scroll, Major
    Experience_Alliance_War_Skill_3 = GetItemLinkName("|H0:item:171263:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Alliance War Skill Line Scroll, Grand

    Experience_Alliance_War_Torte_1 = GetItemLinkName("|H0:item:171323:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Colovian War Torte
    Experience_Alliance_War_Torte_2 = GetItemLinkName("|H0:item:171329:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Molten War Torte
    Experience_Alliance_War_Torte_3 = GetItemLinkName("|H0:item:171432:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- White-Gold War Torte

    -- Misc Consumables
    Consumable_Festival_Mints = GetItemLinkName("|H0:item:112442:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- High Hrothgar Festival Mints
    Consumable_Sailors_Grog = GetItemLinkName("|H0:item:112441:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),        -- Sailor's Warning Festival Grog
    Consumable_Sparkwreath_Dazzler = GetItemLinkName("|H0:item:114946:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"), -- Sparkwreath Dazzler
    Consumable_Plume_Dazzler = GetItemLinkName("|H0:item:114947:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),       -- Plume Dazzler
    Consumable_Spiral_Dazzler = GetItemLinkName("|H0:item:114948:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- Spiral Dazzler
    Skill_Sparkly_Hat_Dazzler = GetItemLinkName("|H0:item:120891:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- Sparkly Hat Dazzler
    Consumable_Revelry_Pie = GetItemLinkName("|H0:item:147300:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),         -- Revelry Pie

    -- Mementos
    Memento_Almalexias_Lantern = GetCollectibleName(341),
    -- Memento_Battered_Bear_Trap        = GetCollectibleName(343),
    Memento_Bonesnap_Binding_Stone = GetCollectibleName(348),
    Memento_Discourse_Amaranthine = GetCollectibleName(345),
    Menento_Lenas_Wand_of_Finding = GetCollectibleName(340),
    Memento_Nirnroot_Wine = GetCollectibleName(344),
    Memento_Mystery_Meat = GetString(LUIE_STRING_SKILL_COLLECTIBLE_MYSTERY_MEAT),
    Memento_Sanguines_Goblet = GetCollectibleName(338),
    Memento_Token_of_Root_Sunder = GetCollectibleName(349),
    Memento_Storm_Atronach_Transform = GetCollectibleName(596),
    Memento_Wild_Hunt_Transform = GetCollectibleName(759),
    Memento_Dwemervamidium_Mirage = GetCollectibleName(1183),
    Memento_Swarm_of_Crows = GetCollectibleName(1384),
    Memento_Fire_Breathers_Torches = GetCollectibleName(600),
    Memento_Jugglers_Knives = GetCollectibleName(598),
    Memento_Sword_Swallowers_Blade = GetCollectibleName(597),
    Memento_Sealing_Amulet = GetCollectibleName(351),
    Memento_Twilight_Shard = GetCollectibleName(1158),
    Memento_Yokudan_Totem = GetCollectibleName(350),
    Memento_Blade_of_the_Blood_Oath = GetCollectibleName(390),
    Memento_Dreamers_Chime = GetCollectibleName(1229),
    Memento_Hidden_Pressure_Vent = GetCollectibleName(354),
    Memento_Coin_of_Illusory_Riches = GetCollectibleName(361),
    Memento_Malacaths_Wrathful_Flame = GetCollectibleName(353),
    Memento_Jubliee_Cake = 87998,
    Memento_Mud_Ball = 86749,
    Memento_Cherry_Blossom_Branch = GetCollectibleName(1108),

    Memento_Festive_Noise_Maker = GetCollectibleName(5885),
    Memento_Jesters_Festival_Joke_Popper = GetCollectibleName(5887),

    Memento_Thetys_Ramarys_Bait_Kit = GetCollectibleName(8658),

    Memento_Storm_Atronach_Aura = GetCollectibleName(594),
    Memento_Storm_Orb_Juggle = GetCollectibleName(595),
    Memento_Wild_Hunt_Aura = GetCollectibleName(760),
    Memento_Floral_Swirl_Aura = GetCollectibleName(758),
    Memento_Dwarven_Puzzle_Orb = GetCollectibleName(1181),
    Memento_Dwarven_Tonal_Forks = GetCollectibleName(1182),
    Memento_Crows_Calling = GetCollectibleName(1383),
    Memento_Fiery_Orb = GetCollectibleName(1481),
    Memento_Flame_Pixie = GetCollectibleName(1482),
    Memento_Flame_Eruption = GetCollectibleName(1483),
    Memento_Frost_Shard = GetCollectibleName(4707),
    Memento_Rune_of_Levitation = GetCollectibleName(4706),
    Memento_Dragon_Summons_Focus = GetCollectibleName(4708),
    Memento_The_Pie_of_Misrule = GetCollectibleName(1167),
    Memento_Jesters_Scintillator = GetCollectibleName(4797),
    Memento_Witchmothers_Whistle = GetCollectibleName(479),
    Memento_Psijic_Celestial_Orb = GetCollectibleName(5031),
    Memento_Psijic_Tautology_Glass = GetCollectibleName(5032),
    Memento_Sapiarchic_Discorporation = GetCollectibleName(5033),
    Memento_Ghost_Lantern = GetCollectibleName(5212),
    Memento_Mire_Drum = GetCollectibleName(5734),
    Memento_Vossa_Satl = GetCollectibleName(5735),
    Memento_Corruption_of_Maarselok = GetCollectibleName(6642),
    Memento_Dragonhorn_Curio = GetCollectibleName(6641),
    Memento_Winnowing_Plague_Decoction = GetCollectibleName(6368),
    Memento_Skeletal_Marionette = GetCollectibleName(6643),
    Memento_Throwing_Bones = GetCollectibleName(8079),
    Memento_Full_Scale_Golden_Anvil_Replica = GetCollectibleName(9363),
    Memento_Mostly_Stable_Juggling_Potions = GetCollectibleName(8072),

    -- ---------------------------------------------------
    -- ITEM SETS -----------------------------------------
    -- ---------------------------------------------------

    Set_Bogdan_the_Nightflame = GetString(LUIE_STRING_SKILL_SET_BOGDAN_THE_NIGHTFLAME),
    Set_Lord_Warden_Dusk = GetString(LUIE_STRING_SKILL_SET_LORD_WARDEN_DUSK),
    Set_Scourge_Harvester = 59564,
    Set_Maw_of_the_Infernal = 59507,
    Set_Nerieneth = 59592,
    Set_Shadowrend = 80989,
    Set_Spawn_of_Mephala = 59497,
    Set_Swarm_Mother = 80592,
    Set_The_Troll_King = GetString(LUIE_STRING_SKILL_SET_TROLL_KING),
    Set_Energy_Charge = GetString(LUIE_STRING_SKILL_SET_ENERGY_CHARGE),
    Set_Scavenging_Demise = 116947,
    Set_Varens_Legacy = 79029,
    Set_Syvarras_Scales = 75717,
    Set_Twin_Sisters = 32828,
    Set_Wilderqueens_Arch = 34870,
    Set_Plague_Slinger = 102113,
    Set_Ice_Furnace = GetString(LUIE_STRING_SKILL_SET_ICE_FURNACE),
    Set_Hand_of_Mephala = { 84353, 84355 },
    Set_Tormentor = 67280,
    Set_Destructive_Mage = 51315,
    Set_Healing_Mage = 51442,
    Set_Vicious_Serpent = 61440,
    Set_Vicecannon_of_Venom = 79464,
    Set_Cooldown = GetString(LUIE_STRING_SKILL_SET_COOLDOWN),
    Set_Eternal_Hunt = 75927,
    Set_Glorious_Defender = 71180,
    Set_Para_Bellum = 71191,
    Set_Winterborn = 71644,
    Set_Nocturnals_Favor = 106803,
    Set_Vestment_of_Olorime = 107117,
    Set_Mantle_of_Siroria = 107093,
    Set_Harmful_Winds = GetString(LUIE_STRING_SKILL_SET_HARMFUL_WINDS),
    Set_Sloads_Semblance = 106797,
    Set_Shield_of_Ursus = 111437,
    Set_Ursus_Blessing = 112414,
    Set_Grace_of_Gloom = 106865,
    Set_Noble_Duelist = GetString(LUIE_STRING_SKILL_SET_NOBLE_DUELIST),
    Set_Soldier_of_Anguish = 113460,
    Set_Affliction = 34787,
    Set_Sentry = 32807,
    Set_Line_Breaker = 75753,
    Set_False_Gods_Devotion = 121823,
    Set_Morkuldin = 71670,
    Set_Senchals_Duty = 129442,
    Set_Phoenix = 68933,
    Set_Immortal_Warrior = 51300,
    Set_Eternal_Warrior = 61436,
    Set_Juggernaut = 34512,
    Set_Honors_Scorn = 121917,
    Set_Honors_Love = 121913,
    Set_Warming_Aura = 133210,
    Set_Aegis_Caller = 133490,
    Set_Reactive_Armor = 68947,
    Set_Kynes_Blessing = 136098,
    Set_Blood_Curse = 139903,
    Set_Sanguine_Burst = 142305,
    Set_Heed_the_Call = 142780,
    Set_Legacy_of_Karth = 147388,

    Disguise_Monks_Disguise = GetString(LUIE_STRING_SKILL_DISGUISE_MONKS_DISGUISE),

    -- ---------------------------------------------------
    -- CHAMPION ABILITIES --------------------------------
    -- ---------------------------------------------------

    Champion_Riposte = 60230,
    Champion_Expert_Evasion = 151113,

    -- ---------------------------------------------------
    -- SKILL LINE PASSIVES -------------------------------
    -- ---------------------------------------------------

    -- Sorcerer
    Passive_Persistence = 31378,

    -- Templar
    Passive_Light_Weaver = 31760,

    -- Warden
    Passive_Bond_with_Nature = GetString(LUIE_STRING_SKILL_BOND_WITH_NATURE),
    Passive_Savage_Beast = 86062,
    Passive_Natures_Gift = 93054,

    -- Weapon
    Passive_Follow_Up = 29389,
    Passive_Destruction_Expert = 30965,

    -- Soul Magic
    Passive_Soul_Summons = 39269,

    -- Vampire
    Passive_Blood_Ritual = 33091,

    -- Werewolf
    Passive_Bloodmoon = 32639,

    -- Undaunted
    Passive_Undaunted_Command = 55584,

    -- Racial
    Passive_Red_Diamond = 36155,

    -- ---------------------------------------------------
    -- CLASS SKILLS --------------------------------------
    -- ---------------------------------------------------

    -- Dragonknight
    Skill_Fiery_Breath = 20917,
    Skill_Fiery_Grip = 20492,
    Skill_Empowering_Chains = 20499,
    Skill_Inferno = 28967,
    Skill_Shackle = 32905,
    Skill_Dragon_Blood = 29004,
    Skill_Inhale = 31837,
    Skill_Dragon_Leap = 29016,
    Skill_Take_Flight = 32719,
    Skill_Ferocious_Leap = 32715,
    Skill_Stonefist = 29032,
    Skill_Molten_Weapons = 29043,

    -- Nightblade
    Skill_Death_Stroke = 33398,
    Skill_Incapacitating_Strike = 36508,
    Skill_Soul_Harvest = 36514,
    Skill_Corrosive_Strike = 33219,
    Skill_Corrosive_Spin = GetString(LUIE_STRING_SKILL_CORROSIVE_SPIN_TP),
    Skill_Summon_Shade = GetSummonShade(summonShade),
    Skill_Shade = "Shade",
    Skill_Dark_Shade = GetDarkShade(darkShade),
    Skill_Shadow_Image = GetShadowImage(shadowImage),
    Skill_Crippling_Grasp = 36957,
    Skill_Sap_Essence = 36891,

    -- Sorcerer
    Skill_Crystal_Shard = 43714,
    Skill_Crystal_Blast = 46704,
    Skill_Crystal_Fragments = 46324,
    Skill_Daedric_Tomb = 24842,
    Skill_Daedric_Minefield = 24834,
    Skill_Unstable_Pulse = GetString(LUIE_STRING_SKILL_UNSTABLE_PULSE),
    Skill_Volatile_Pulse = GetString(LUIE_STRING_SKILL_VOLATILE_PULSE),
    Skill_Summon_Storm_Atronach = 23634,
    Skill_Greater_Storm_Atronach = 23492,
    Skill_Summon_Charged_Atronach = 23495,
    Skill_Atronach_Zap = 23428,
    Skill_Bound_Aegis = 24163,
    Skill_Lightning_Form = 23210,
    Skill_Kick = 4125,
    Skill_Entropic_Touch = 9743,
    Skill_Intercept = 23284,

    -- Templar
    Skill_Puncturing_Sweep = 26797,
    Skill_Aurora_Javelin = 26800,
    Skill_Crescent_Sweep = 22139,
    Skill_Sun_Fire = 21726,
    Skill_Dark_Flare = 22110,
    Skill_Unstable_Core = 22004,
    Skill_Radiant_Glory = 63044,
    Skill_Nova = 21752,
    Skill_Solar_Disturbance = 21758,
    Skill_Cleansing_Ritual = 22265,
    Skill_Restoring_Focus = 22237,

    -- Warden
    Skill_Feral_Guardian = 85982,
    Skill_Eternal_Guardian = 85986,
    Skill_Lotus_Blossom = 85855,
    Skill_Natures_Grasp = 85564,
    Skill_Bursting_Vines = 85859,
    Skill_Natures_Embrace = 85858,
    Skill_Shimmering_Shield = 86143,
    Skill_Frozen_Device = 86179,

    -- Necromancer
    Skill_Skeletal_Mage = 114317,
    Skill_Skeletal_Arcanist = 118726,
    Skill_Bitter_Harvest = 115238,
    Skill_Deaden_Pain = 118623,
    Skill_Bone_Goliath_Transformation = 115001,
    Skill_Pummeling_Goliath = 118664,
    Skill_Ravenous_Goliath = 118279,

    -- ---------------------------------------------------
    -- WEAPON SKILLS -------------------------------------
    -- ---------------------------------------------------

    -- Restoration Staff
    Skill_Blessing_of_Restoration = GetString(LUIE_STRING_SKILL_BLESSING_OF_RESTORATION),

    -- Destruction Staff
    Skill_Crushing_Shock = 46348,
    Skill_Frozen = 68719,
    Skill_Flame_Touch = 29073,
    Skill_Flame_Clench = 38985,
    Skill_Shock_Clench = 38993,
    Skill_Frost_Clench = 38989,
    Skill_Weakness_to_Elements = 29173,
    Skill_Frost_Pulsar = 39163,

    -- Two-Handed
    Skill_Uppercut = 28279,
    Skill_Stampede = 38788,
    Skill_Cleave = 20919,

    -- One Hand & Shield
    Skill_Puncture = 28306,
    Skill_Deep_Slash = 38268,
    Skill_Shield_Charge = 28719,
    Skill_Invasion = 38405,
    Skill_Power_Bash = 28365,

    -- Dual Wield
    Skill_Twin_Slashes = 28379,
    Skill_Hidden_Blade = 21157,
    Skill_Shrouded_Daggers = 38914,
    Skill_Flying_Blade = 38910,

    -- Bow
    Skill_Draining_Shot = 38669,
    Skill_Bombard = 38705,
    Skill_Venom_Arrow = 38645,
    Skill_Rapid_Fire = 83465,

    -- ---------------------------------------------------
    -- ARMOR SKILLS --------------------------------------
    -- ---------------------------------------------------

    -- Heavy Armor
    Skill_Unstoppable_Brute = 39205,

    -- ---------------------------------------------------
    -- SOUL MAGIC SKILLS ---------------------------------
    -- ---------------------------------------------------

    Skill_Consuming_Trap = 40317,

    -- ---------------------------------------------------
    -- VAMPIRE SKILLS ------------------------------------
    -- ---------------------------------------------------

    Skill_Feed = 33152,
    Skill_Vampirism = GetString(LUIE_STRING_SKILL_VAMPIRISM),
    Skill_Profane_Symbol = GetString(LUIE_STRING_SKILL_PROFANE_SYMBOL),
    Skill_Blood_Scion = 32624,
    Skill_Swarming_Scion = 38932,
    Skill_Perfect_Scion = 38931,

    -- ---------------------------------------------------
    -- WEREWOLF SKILLS -----------------------------------
    -- ---------------------------------------------------

    Skill_Werewolf_Transformation = 32455,
    Skill_Devour = 32634,
    Skill_Carnage = 137157,
    Skill_Brutal_Carnage = 137186,
    Skill_Feral_Carnage = 137165,
    Skill_Hircines_Rage = 58317,
    Skill_Remove = 31262,

    -- ---------------------------------------------------
    -- GUILD SKILLS --------------------------------------
    -- ---------------------------------------------------

    -- Dark Brotherhood
    Skill_Blade_of_Woe = 78219,

    -- Fighters Guild
    Skill_Revealed = 11717,
    Skill_Marked = 103943,
    Skill_Lightweight_Beast_Trap = 40372,
    Skill_Flawless_Dawnbreaker = 40161,

    -- Mages Guild
    Skill_Magelight = 30920,
    Skill_Entropy = 28567,
    Skill_Meteor = 16536,
    Skill_Ice_Comet = 40489,
    Skill_Shooting_Star = 40493,

    -- Psijic Order
    Skill_Imbue_Weapon = 103483,
    Skill_Elemental_Weapon = 103571,
    Skill_Crushing_Weapon = 103623,

    -- Undaunted
    Skill_Black_Widow = 41994,
    Skill_Arachnophobia = 42016,

    -- ---------------------------------------------------
    -- ALLIANCE WAR --------------------------------------
    -- ---------------------------------------------------

    -- Assault
    Skill_Caltrops = 33376,
    Skill_Razor_Caltrops = 40242,

    -- Support
    Skill_Lingering_Flare = 61519,
    Skill_Reviving_Barrier = 40237,

    -- ---------------------------------------------------
    -- CYRODIIL ------------------------------------------
    -- ---------------------------------------------------

    Skill_Battle_Spirit = GetString(LUIE_STRING_SKILL_BATTLE_SPIRIT),
    Skill_Edge_Keep_Bonus_I = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_SKILL_EDGE_KEEP_BONUS), "I"),
    Skill_Edge_Keep_Bonus_II = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_SKILL_EDGE_KEEP_BONUS), "II"),
    Skill_Edge_Keep_Bonus_III = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_SKILL_EDGE_KEEP_BONUS), "III"),
    Skill_Guard_Detection = GetString(LUIE_STRING_SKILL_GUARD_DETECTION),

    Skill_Stow_Siege_Weapon = GetString(LUIE_STRING_SKILL_STOW_SIEGE_WEAPON),
    Skill_Deploy = GetString(LUIE_STRING_SKILL_DEPLOY),
    Skill_Pact = GetString(LUIE_STRING_SKILL_PACT),
    Skill_Covenant = GetString(LUIE_STRING_SKILL_COVENANT),
    Skill_Dominion = GetString(LUIE_STRING_SKILL_DOMINION),
    Skill_Ballista = 68205,
    Skill_Fire_Ballista = 35049,
    Skill_Lightning_Ballista = GetString(LUIE_STRING_SKILL_LIGHTNING_BALLISTA),

    Skill_Stone_Trebuchet = 14159,
    Skill_Iceball_Trebuchet = 13551,
    Skill_Firepot_Trebuchet = 7010,
    Skill_Meatbag_Catapult = 14774,
    Skill_Oil_Catapult = 16789,
    Skill_Scattershot_Catapult = 14611,

    Skill_Shock_Lancer = 138555,
    Skill_Fire_Lancer = 138426,
    Skill_Frost_Lancer = 138551,

    Skill_Cold_Stone_Trebuchet = GetString(LUIE_STRING_SKILL_COLD_STONE_TREBUCHET),
    Skill_Cold_Fire_Trebuchet = GetString(LUIE_STRING_SKILL_COLD_FIRE_TREBUCHET),
    Skill_Cold_Fire_Ballista = GetString(LUIE_STRING_SKILL_COLD_FIRE_BALLISTA),

    Skill_Flaming_Oil = 15774,
    Skill_Battering_Ram = 15197,

    Skill_Siege_Repair_Kit = GetItemLinkName("|H0:item:27112:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),          -- Siege Repair Kit
    Skill_Keep_Wall_Repair_Kit = GetItemLinkName("|H0:item:27138:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),      -- Keep Wall Masonry Repair Kit
    Skill_Keep_Door_Repair_Kit = GetItemLinkName("|H0:item:27962:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),      -- Keep Door Woodwork Repair Kit
    Skill_Bridge_Repair_Kit = GetItemLinkName("|H0:item:142133:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),        -- Bridge and Milegate Repair Kit
    Skill_Practice_Siege_Repair_Kit = GetItemLinkName("|H0:item:43056:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Practice Siege Repair Kit

    Skill_Pact_Forward_Camp = GetItemLinkName("|H0:item:29534:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),          -- Pact Foward Camp
    Skill_Dominion_Forward_Camp = GetItemLinkName("|H0:item:29533:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- Dominion Forward Camp
    Skill_Covenant_Forward_Camp = GetItemLinkName("|H0:item:29535:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- Covenant Forward Camp

    Skill_Razor_Armor = 36304,

    Skill_Consume_Lifeforce = GetString(LUIE_STRING_SKILL_CONSUME_LIFEFORCE),
    Skill_Wall_of_Souls = 21677,

    -- ---------------------------------------------------
    -- BATTLEGROUNDS -------------------------------------
    -- ---------------------------------------------------

    Skill_Mark_of_the_Worm = 95830,

    -- ---------------------------------------------------
    -- NPC ABILITIES -------------------------------------
    -- ---------------------------------------------------

    -- Shared/Basic
    Skill_Hamstring = 70068,
    Skill_Boss_CC_Immunity = GetString(LUIE_STRING_SKILL_BOSS_CC_IMMUNITY),
    Skill_Backstabber = 13739,

    -- Human
    Skill_Ignite = 14070,
    Skill_Shield_Rush = GetString(LUIE_STRING_SKILL_SHIELD_RUSH),
    Skill_Shock_Aura = 17867,
    Skill_Shock_Blast = 85255,
    Skill_Improved = GetString(LUIE_STRING_SKILL_IMPROVED),
    Skill_Knockback = 77905,
    Skill_Weakness = 8705,
    Skill_Staff_Strike = 2901,
    Skill_Ice_Barrier = 14178,
    Skill_Vanish = 24687,
    Skill_Bone_Cage = 35387,
    Skill_Defensive_Ward = GetString(LUIE_STRING_SKILL_DEFENSIVE_WARD),
    Skill_Divine_Leap = 54027,
    Skill_Inspire = GetString(LUIE_STRING_SKILL_INSPIRE),
    Skill_Hide_in_Shadows = GetString(LUIE_STRING_SKILL_HIDE_IN_SHADOWS),
    Skill_Recover = 42905,
    Skill_Clobber = 24671,
    Skill_Shadowy_Barrier = GetString(LUIE_STRING_SKILL_SHADOWY_BARRIER),
    Skill_Flare_Trap = 74628,
    Skill_Bear_Trap = 39058,
    Skill_Void_Burst = 36987,

    -- Justice
    Skill_Heavy_Blow = 63157,
    Skill_Mighty_Charge = GetString(LUIE_STRING_SKILL_MIGHTY_CHARGE),
    Skill_Throw_Dagger = 28499,
    Skill_Detection = GetString(LUIE_STRING_SKILL_DETECTION),

    -- Cyrodiil
    Skill_Shock_Torrent = 46726,
    Skill_Improved_Shock_Torrent = GetString(LUIE_STRING_SKILL_IMPROVED_SHOCK_TORRENT),
    Skill_Lasting_Storm = 46818,
    Skill_Bleeding_Strike = 46830,
    Skill_Telekinetic_Prison = 21636,
    Skill_Shattering_Prison = 46905,
    Skill_Siege_Barrier = GetString(LUIE_STRING_SKILL_SIEGE_BARRIER),
    Skill_Fire_Torrent = GetString(LUIE_STRING_SKILL_FIRE_TORRENT),
    Skill_Improved_Fire_Torrent = 46990,
    Skill_Puncturing_Chains = GetString(LUIE_STRING_SKILL_PUNCTURING_CHAINS),
    Skill_Improved_Volley = GetString(LUIE_STRING_SKILL_IMPROVED_VOLLEY),

    -- Animals
    Skill_Lacerate = 5452,
    Skill_Bite = 17957,
    Skill_Savage_Blow = 139956,
    Skill_Slam = 70366,
    Skill_Rip_and_Tear = GetString(LUIE_STRING_SKILL_RIP_AND_TEAR),
    Skill_Rush = 14380,
    Skill_Vigorus_Swipes = 75634,
    Skill_Barreling_Charge = GetString(LUIE_STRING_SKILL_BARRELING_CHARGE),
    Skill_Storm_Bound = 55864,
    Skill_Swipe = 2850,
    Skill_Blitz = GetString(LUIE_STRING_SKILL_BLITZ),
    Skill_Toxic_Mucus = 72793,
    Skill_Gore = 85202,
    Skill_Bile_Spit = 64559,

    -- Insects
    Skill_Paralyze = 6756,
    Skill_Web = 58521,
    Skill_Inject_Larva = 9229,
    Skill_Zoom = GetString(LUIE_STRING_SKILL_ZOOM),
    Skill_Vile_Bite = 61243,
    Skill_Infectious_Swarm = 61360,
    Skill_Necrotic_Explosion = 61427,
    Skill_Contagion = 47838,
    Skill_Plow = GetString(LUIE_STRING_SKILL_PLOW),
    Skill_Zap = 8429,
    Skill_Leeching_Bite = GetString(LUIE_STRING_SKILL_LEECHING_BITE),
    Skill_Fetcherfly_Colony = GetString(LUIE_STRING_SKILL_FETCHERFLY_COLONY),
    Skill_Fetcherfly_Swarm = GetString(LUIE_STRING_SKILL_FETCHERFLY_SWARM),
    Skill_Call_Scribs = 38545,

    -- Daedra
    Skill_Summon_Daedric_Arch = 65404,
    Skill_Empower_Atronach_Flame = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_FLAME),
    Skill_Empower_Atronach_Frost = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_FROST),
    Skill_Empower_Atronach_Storm = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_STORM),
    Skill_Headbutt = 54380,
    Skill_Tail_Spike = 4799,
    Skill_Rending_Leap = 93745,
    Skill_Radiance = 4891,
    Skill_Unyielding_Mace = 4817,
    Skill_Pin = 65709,
    Skill_Sweep = 67872,
    Skill_Enrage = 71696,
    Skill_Stomp = 91848,
    Skill_Boulder_Toss = 91855,
    Skill_Shockwave = 4653,
    Skill_Doom_Truths_Gaze = 9219,
    Skill_The_Feast = 11083,
    Skill_Flame_Geyser = 34376,

    -- Undead
    Skill_Desecrated_Ground = 38828,
    Skill_Colossal_Stomp = GetString(LUIE_STRING_SKILL_COLOSSAL_STOMP),
    Skill_Defiled_Ground = 22521,
    Skill_Soul_Rupture = 73931,

    -- Monsters
    Skill_Luring_Snare = 2821,
    Skill_Assault = 4304,
    Skill_Crushing_Limbs = 3855,
    Skill_Pillars_of_Nirn = 75955,
    Skill_Claw = 27922,
    Skill_Obliterate = 127908,
    Skill_Fiery_Surge = 75949,

    -- Dwemer
    Skill_Static_Shield = 64463,
    Skill_Dart = 7485,
    Skill_Split_Bolt = 91093,
    Skill_Turret_Mode = 71045,
    Skill_Overcharge = 27333,

    -- ---------------------------------------------------
    -- TRAPS ---------------------------------------------
    -- ---------------------------------------------------

    Trap_Cold_Fire_Trap = GetString(LUIE_STRING_SKILL_COLD_FIRE_TRAP),
    Trap_Falling_Rocks = 20886,
    Trap_Fire_Trap = 17198,
    Trap_Spike_Trap = 21940,
    Trap_Sigil_of_Frost = 20258,

    Trap_Lava_Trap = GetString(LUIE_STRING_SKILL_LAVA_TRAP),
    Trap_Lightning_Trap = GetString(LUIE_STRING_SKILL_LIGHTNING_TRAP),
    Trap_Blade_Trap = 66793,

    Trap_Slaughterfish = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:42861:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Trap_Lava = 5139,

    Trap_Charge_Wire = GetString(LUIE_STRING_SKILL_CHARGE_WIRE),
    Trap_Steam_Vent = GetString(LUIE_STRING_SKILL_STEAM_VENT),

    Trap_Static_Pitcher = GetItemLinkName("|H0:item:145491:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Trap_Gas_Blossom = GetItemLinkName("|H0:item:145492:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Trap_Lantern_Mantis = GetItemLinkName("|H0:item:145493:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    Trap_Hiding_Spot = 72712,

    -- ---------------------------------------------------
    -- WORLD BOSSES --------------------------------------
    -- ---------------------------------------------------

    Skill_Ferocious_Charge = 83033,
    Skill_Molten_Impact = 83203,
    Skill_Molten_Pillar_Incalescence = GetString(LUIE_STRING_SKILL_MOLTEN_PILLAR_INCALESCENCE),
    Skill_Trapping_Bolt = 83925,
    Skill_Remove_Bolt = 25763,
    Skill_Poison_Spit = 21708,
    Skill_Graven_Slash = 84292,

    -- ---------------------------------------------------
    -- QUEST ABILITIES -----------------------------------
    -- ---------------------------------------------------

    -- Seasonal
    Skill_Lava_Foot_Stomp = GetString(LUIE_STRING_SKILL_LAVA_FOOT_STOMP),
    Skill_Knife_Juggling = GetString(LUIE_STRING_SKILL_KNIFE_JUGGLING),
    Skill_Torch_Juggling = GetString(LUIE_STRING_SKILL_TORCH_JUGGLING),
    Skill_Sword_Swallowing = 84533,
    Skill_Celebratory_Belch = 84847,
    Event_Petal_Pelters = GetQuestItemNameFromLink("|H0:quest_item:6145|h|h"),
    Event_Crow_Caller = GetItemLinkName("|H0:item:81189:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    Event_Sparkle_Dazzler = GetQuestItemNameFromLink("|H0:quest_item:6191|h|h"),
    Event_Burst_Dazzler = GetQuestItemNameFromLink("|H0:quest_item:6192|h|h"),
    Event_Flash_Dazzler = GetQuestItemNameFromLink("|H0:quest_item:6193|h|h"),

    Skill_Grease_Slip = 143695,
    Skill_Thrash = 144340,

    -- MSQ
    Skill_Wall_of_Flames = GetString(LUIE_STRING_SKILL_WALL_OF_FLAMES),
    Skill_Necrotic = 41852,
    Skill_Barrier = 38573,
    Skill_Swordstorm = 36858,
    Skill_Flame_Shield = 37173,
    Skill_Royal_Strike = 38729,
    Skill_Consecrate_Shrine = GetString(LUIE_STRING_SKILL_CONSECRATE_SHRINE),
    Skill_Remove_Ward = "Remove Ward",
    Skill_Shock = 27598,
    Skill_Drink_Mead = 13941,
    Skill_Unstable_Portal = GetString(LUIE_STRING_SKILL_UNSTABLE_PORTAL),
    Skill_Stabilize_Portal = GetString(LUIE_STRING_SKILL_STABILIZE_PORTAL),
    Skill_Close_Unstable_Rift = GetString(LUIE_STRING_SKILL_CLOSE_UNSTABLE_RIFT),

    -- Fighters Guild
    Skill_Palolels_Rage = 39577,
    Skill_Prismatic_Light = 25981,
    Skill_Quick_Strike = 10618,
    Skill_Quick_Shot = 12437,
    Skill_Flame_Blossom = GetString(LUIE_STRING_SKILL_FLAME_BLOSSOM),

    -- Mages Guild
    Skill_Rock = 26775,
    Skill_Essence = 25337,
    Skill_Sahdinas_Essence = GetString(LUIE_STRING_SKILL_SAHDINAS_ESSENCE),
    Skill_Rashomtas_Essence = GetString(LUIE_STRING_SKILL_RASHOMTAS_ESSENCE),
    Skill_Polymorph_Skeleton = GetString(LUIE_STRING_SKILL_POLYMORPH_SKELETON),
    Skill_Drain_Vitality = 8787,
    Skill_Ungulate_Ordnance = 39393,

    -- Aldmeri Dominion
    Skill_Drain_Energy = GetString(LUIE_STRING_SKILL_DRAIN_ENERGY),
    Skill_Blessing = 33029,
    Skill_Beckon_Gathwen = GetString(LUIE_STRING_SKILL_BECKON_GATHWEN),
    Skill_Summon = 29585,
    Skill_Ancestral_Spirit = 48921,
    Skill_Drinking = 23527,
    Skill_Disruption = 31321,
    Skill_Voice_to_Wake_the_Dead = 5030,
    Skill_Barrier_Rebuke = GetString(LUIE_STRING_SKILL_BARRIER_REBUKE),
    Skill_Dispel = 8490,
    Skill_Teleport_Scroll = GetString(LUIE_STRING_SKILL_TELEPORT_SCROLL),
    Skill_Purify = 22260,
    Skill_Bind_Hands = GetString(LUIE_STRING_SKILL_BIND_HANDS),
    Skill_Bind_Bear = GetString(LUIE_STRING_SKILL_BIND_BEAR),
    Skill_Aetherial_Shift = GetString(LUIE_STRING_SKILL_AETHERIAL_SHIFT),
    Skill_Free_Spirit = GetString(LUIE_STRING_SKILL_FREE_SPIRIT),
    Skill_Unbind = GetString(LUIE_STRING_SKILL_UNBIND),
    Skill_Crystal = 67121,
    Skill_Backfire = GetString(LUIE_STRING_SKILL_BACKFIRE),
    Skill_Close_Portal = 23370,
    Skill_Lightning_Strike = 27596,
    Skill_Push = 8692,
    Skill_Absorb = 30869,
    Skill_Mantles_Shadow = GetString(LUIE_STRING_SKILL_MANTLES_SHADOW),
    Skill_Quaking_Stomp = 43820,
    Skill_Projectile_Vomit = 43827,
    Skill_Call_for_Help = 53430,
    Skill_Throw_Water = GetString(LUIE_STRING_SKILL_THROW_WATER),
    Skill_Snake_Scales = 36713,
    Skill_Wolfs_Pelt = 36843,
    Skill_Tigers_Fur = 36828,
    Skill_Feedback = 32063,
    Skill_Soul_Binding = 21171,
    Skill_Empower_Heart = GetString(LUIE_STRING_SKILL_EMPOWER_TWILIT_HEART),
    Skill_Restricting_Vines = GetString(LUIE_STRING_SKILL_RESTRICTING_VINES),
    Skill_Change_Clothes = GetString(LUIE_STRING_SKILL_CHANGE_CLOTHES),
    Skill_Fancy_Clothing = GetString(LUIE_STRING_SKILL_FANCY_CLOTHING),
    Skill_Flames = 64704,
    Skill_Burrow = 8974,
    Skill_Emerge = 20746,
    Skill_Serpent_Spit = GetString(LUIE_STRING_SKILL_SERPENT_SPIT),
    Skill_Shadow_Wood = GetString(LUIE_STRING_SKILL_SHADOW_WOOD),
    Skill_Disperse_Corruption = GetString(LUIE_STRING_SKILL_DISPERSE_CORRUPTION),
    Skill_Undead_Legion = 35809,
    Skill_Call_Corrupt_Lurchers = GetString(LUIE_STRING_SKILL_CALL_CORRUPT_LURCHERS),

    -- Daggerfall Covenant
    Skill_Neramos_Control_Rod = GetQuestItemName(3703),
    Skill_Vision_of_the_Past = 36834,

    -- Summerset Quests
    Skill_Pustulant_Eruption = 105867,

    -- Elsweyr Quests
    Skill_Flame_Aura = 124352,
    Skill_Star_Haven_Dragonhorn = GetString(LUIE_STRING_SKILL_STAR_HAVEN_DRAGONHORN),
    Skill_Steadfast_Ward = 37232,
    Skill_Wing_Thrash = 125242,

    -- Greymoor Quests
    Skill_Piercing_Dagger = GetString(LUIE_STRING_SKILL_PIERCING_DAGGER),
    Skill_Frostbolt = 119222,
    Skill_Freezing_Vines = GetString(LUIE_STRING_SKILL_FREEZING_VINES),
    Skill_Freezing_Vineburst = GetString(LUIE_STRING_SKILL_FREEZING_VINEBURST),

    -- ---------------------------------------------------
    -- ARENA EFFECTS -----------------------------------
    -- ---------------------------------------------------

    -- Dragonstar Area
    Skill_Dawnbreaker = 35713,
    Skill_Flame_Volley = 53314,
    Skill_Daedric_Curse = 24326,
    Skill_Poison_Cloud = 21411,
    Skill_Flurry = 28607,
    Skill_Mages_Wrath = 19123,
    Skill_Caustic_Armor = GetString(LUIE_STRING_SKILL_CAUSTIC_ARMOR),
    Skill_Enslavement = 83774,
    Skill_Cinder_Storm = 20779,
    Skill_Petrify = 29037,
    Skill_Celestial_Ward = 54315,
    Skill_Draining_Poison = 60442,
    Skill_Natures_Blessing = GetString(LUIE_STRING_SKILL_NATURES_BLESSING),
    Skill_Reflective_Scale = GetString(LUIE_STRING_SKILL_REFLECTIVE_SCALE),
    Skill_Summon_Scamp = 39555,
    Skill_Summon_Harvester = 58054,
    Skill_Summon_Daedric_Titan = GetString(LUIE_STRING_SKILL_SUMMON_DAEDRIC_TITAN),
    Skill_Suppression_Field = 28341,
    Skill_Sucked_Under = 55221,
    Skill_Spirit_Shield = 56985,
    Skill_Blazing_Fire = 34959,
    Skill_Empowered_by_the_Light = GetString(LUIE_STRING_SKILL_EMPOWERED_BY_THE_LIGHT),
    Skill_Warmth = 29430,
    Skill_Arena_Torch = GetString(LUIE_STRING_SKILL_ARENA_TORCH),
    Skill_Biting_Cold = 53341,
    Skill_Circle_of_Protection_NPC = 35737,

    -- Maelstrom Arena
    Skill_Sigil_of_Healing = 66920,
    Skill_Defiled_Grave = 70893,
    Skill_Overload = 72690,
    Skill_Energize = GetString(LUIE_STRING_SKILL_ENERGIZE),
    Skill_Defensive_Protocol = GetString(LUIE_STRING_SKILL_DEFENSIVE_PROTOCOL),

    Skill_Electrified_Water = 69913,
    Skill_Call_Lightning = 73881,
    Skill_Spit = 76094,
    Skill_Venting_Flames = GetString(LUIE_STRING_SKILL_VENTING_FLAMES),
    Skill_Voltaic_Overload = 109059,
    Skill_Cold_Snap = 72705,
    Skill_Summon_Deathless_Wolf = GetString(LUIE_STRING_SKILL_SUMMON_DEATHLESS_WOLF),
    Skill_Iceberg_Calving = 71702,
    Skill_Frigid_Waters = 67805,

    -- ---------------------------------------------------
    -- DUNGEON EFFECTS -----------------------------------
    -- ---------------------------------------------------

    -- Banished Cells I
    Skill_Tail_Smite = 47587,
    Skill_Shadow_Proxy = 114655,
    Skill_Overpower = 52997,

    -- Banished Cells II
    Skill_Pool_of_Fire = GetString(LUIE_STRING_SKILL_POOL_OF_FIRE),
    Skill_Sisters_Bond = GetString(LUIE_STRING_SKILL_SISTERS_BOND),
    Skill_Levitate = 28570,
    Skill_Essence_Siphon = 28750,
    Skill_Daedric_Chaos = GetString(LUIE_STRING_SKILL_DAEDRIC_CHAOS),
    Skill_Chaotic_Dispersion = GetString(LUIE_STRING_SKILL_CHAOTIC_DISPERSION),
    Skill_Chaotic_Return = GetString(LUIE_STRING_SKILL_CHAOTIC_RETURN),
    Skill_Summon_Daedroth = 69356,
    Skill_Resilience = GetString(LUIE_STRING_SKILL_RESILIENCE),

    -- Elden Hollow I
    Skill_Executioners_Strike = 16834,
    Skill_Whirling_Axe = GetString(LUIE_STRING_SKILL_WHIRLING_AXE),
    Skill_Crushing_Blow = 33189, -- TODO: Move to the first instance of this rename being neccesary
    Skill_Measured_Uppercut = 34607,
    Skill_Heal_Spores = GetString(LUIE_STRING_SKILL_HEAL_SPORES),
    Skill_Summon_Saplings = GetString(LUIE_STRING_SKILL_SUMMON_STRANGLER_SAPLINGS),
    Skill_Reanimate_Skeletons = GetString(LUIE_STRING_SKILL_REANIMATE_SKELETONS),

    -- Elden Hollow II
    Skill_Fortified_Ground = 32648,
    Skill_Empowered_Ground = 32647,
    Skill_Siphon_Magicka = GetString(LUIE_STRING_SKILL_SIPHON_MAGICKA),
    Skill_Siphon_Stamina = GetString(LUIE_STRING_SKILL_SIPHON_STAMINA),
    Skill_Shadow_Tendril = GetString(LUIE_STRING_SKILL_SHADOW_TENDRIL),
    Skill_Nova_Tendril = GetString(LUIE_STRING_SKILL_NOVA_TENDRIL),

    -- City of Ash I
    Skill_Steel_Cyclone = 5843,
    Skill_Fan_of_Flames = 34654,
    Skill_Thorny_Backhand = 34190,
    Skill_Fiery_Deception = 52224,
    Skill_Blazing_Arrow = 34901,
    Skill_Blazing_Embers = 34953,
    Skill_Summon_Flame_Atronach = 34623,
    Skill_Summon_Flame_Atronachs = GetString(LUIE_STRING_SKILL_SUMMON_FLAME_ATRONACHS),
    Skill_Oblivion_Gate = GetString(LUIE_STRING_SKILL_OBLIVION_GATE),

    -- City of Ash II
    Skill_Trail_of_Flames = GetString(LUIE_STRING_SKILL_TRAIL_OF_FLAMES),
    Skill_Pyroclasm = 92269,
    Skill_Fire_Rune = 47102,
    Skill_Seismic_Tremor = 55203,
    Skill_Enraged_Fortitude = GetString(LUIE_STRING_SKILL_ENRAGED_FORTITUDE),
    Skill_Wing_Gust = 26554,
    Skill_Flame_Tsunami = GetString(LUIE_STRING_SKILL_FLAME_TSUNAMI),
    Skill_Ignore_Pain = GetString(LUIE_STRING_SKILL_IGNORE_PAIN),
    Skill_Flame_Bolt = 55513,
    Skill_Call_the_Flames = 55514,
    Skill_Slag_Geyser = 56068,
    Skill_Platform_Detonation = 56548,
    Skill_Volcanic_Shield = GetString(LUIE_STRING_SKILL_VOLCANIC_SHIELD),
    Skill_Meteoric_Strike = GetString(LUIE_STRING_SKILL_METEORIC_STRIKE),
    Skill_Flame_Barrier = GetString(LUIE_STRING_SKILL_FLAME_BARRIER),
    Skill_Call_Storm_Atronach = GetString(LUIE_STRING_SKILL_CALL_STORM_ATRONACH),
    Skill_Call_Storm_Atronachs = GetString(LUIE_STRING_SKILL_CALL_STORM_ATRONACHS),

    -- Tempest Island
    Skill_Sonic_Scream = 46732,
    Skill_Sudden_Storm = GetString(LUIE_STRING_SKILL_SUDDEN_STORM),
    Skill_Shadowstep = 18190,
    Skill_Poisoned_Blade = 29063,
    Skill_Stormfist = 80520,
    Skill_Wind_Charge = 26746,
    Skill_Twister = 26514,
    Skill_Heavy_Slash = 51993,
    Skill_Precision_Strike = GetString(LUIE_STRING_SKILL_PRECISION_STRIKE),

    -- Selene's Web
    Skill_Primal_Swarm = GetString(LUIE_STRING_SKILL_PRIMAL_SWARM),
    Skill_Volley = 28876,
    Skill_Senche_Spirit = GetString(LUIE_STRING_SKILL_SENCHE_SPIRIT),
    Skill_Lash = 5240,
    Skill_Vicious_Maul = 30996,
    Skill_Trampling_Charge = 30987,
    Skill_Selenes_Rose = GetString(LUIE_STRING_SKILL_SELENES_ROSE),
    Skill_Free_Ally = 31180,
    Skill_Primal_Maul = GetString(LUIE_STRING_SKILL_PRIMAL_MAUL),
    Skill_Primal_Leap = 30901,
    Skill_Root_Guard = GetString(LUIE_STRING_SKILL_ROOT_GUARD),
    Skill_Earth_Mender = GetString(LUIE_STRING_SKILL_EARTH_MENDER),
    Skill_True_Shot = GetString(LUIE_STRING_SKILL_TRUE_SHOT),

    -- Spindleclutch I
    Skill_Summon_Swarm = 51408,
    Skill_Arachnid_Leap = 17960,
    Skill_Spawn_Hatchlings = GetString(LUIE_STRING_SKILL_SPAWN_HATCHLINGS),
    Skill_Web_Blast = 18078,
    Skill_Grappling_Web = 35572,
    Skill_Daedric_Explosion = 18058,

    -- Spindleclutch II
    Skill_Vicious_Smash = 28093,
    Skill_Quake = 10270,
    Skill_Cave_In = 27995,
    Skill_Praxins_Nightmare = 47122,
    Skill_Harrowing_Ring = 27703,
    Skill_Wracking_Pain = GetString(LUIE_STRING_SKILL_WRACKING_PAIN),

    -- Wayrest Sewers I
    Skill_Dark_Lance = 9441,
    Skill_Summon_Restless_Souls = 9463,
    Skill_Hallucinogenic_Fumes = 35006,

    -- Wayrest Sewers II
    Skill_Scourging_Spark = 36613,
    Skill_Necromantic_Implosion = 17207,
    Skill_Escaped_Souls = GetString(LUIE_STRING_SKILL_ESCAPED_SOULS),
    Skill_Overhead_Smash = 20915,

    -- Crypt of Hearts I
    Skill_Trample = 46947,
    Skill_Immolate = 46679,
    Skill_Electric_Prison = 22432,
    Skill_Overwhelming_Blow = GetString(LUIE_STRING_SKILL_OVERWHELMING_BLOW),

    -- Crypt of Hearts II
    Skill_Summon_Spiderkith = GetString(LUIE_STRING_SKILL_SUMMON_SPIDERKITH),
    Skill_Summon_Death_Spider = GetString(LUIE_STRING_SKILL_SUMMON_DEATH_SPIDER),
    Skill_Summon_Atronach = 52040,
    Skill_Chattering_Web = 51381,
    Skill_Spider_Swarm = 51410,
    Skill_Shock_Stomp = 53599,
    Skill_Fire_Stomp = 61611,
    Skill_Shock_Form = 52167,
    Skill_Fire_Form = 52166,
    Skill_Split_Flare = GetString(LUIE_STRING_SKILL_SPLIT_FLARE),
    Skill_Void_Grip = GetString(LUIE_STRING_SKILL_VOID_GRIP),
    Skill_Fulminating_Void = 51799,
    Skill_Skull_Volley = GetString(LUIE_STRING_SKILL_SKULL_VOLLEY),
    Skill_Daedric_Step = 46581,
    Skill_Soul_Pulse = 51853,
    Skill_Cold_Strike = 53123,
    Skill_Chilling_Bolt = GetString(LUIE_STRING_SKILL_CHILLING_BOLT),
    Skill_Soul_Sacrifice = 51969,
    Skill_Draw_the_Ebony_Blade = GetString(LUIE_STRING_SKILL_DRAW_THE_EBONY_BLADE),
    Skill_Ebony_Shield = GetString(LUIE_STRING_SKILL_EBONY_SHIELD),
    Skill_Resist_Necrosis = 53185,
    Skill_Lethal_Stab = 51988,

    -- Volenfell
    Skill_Mighty_Swing = GetString(LUIE_STRING_SKILL_MIGHTY_SWING),
    Skill_Flame_Wraith = GetString(LUIE_STRING_SKILL_FLAME_WRAITH),
    Skill_Burning_Ground = 25143,
    Skill_Gargoyle_Leap = GetString(LUIE_STRING_SKILL_GARGOYLE_LEAP),
    Skill_Explosive_Bolt = 25655,
    Skill_Tail_Swipe = 24777,
    Skill_Rupture = 29164,

    -- Frostvault
    Skill_Rending_Bleed = 117286,
    Skill_Leaping_Crush = 109801,
    Skill_Lifting_Strike = 109834,
    Skill_Frenzied_Pummeling = 118489,
    Skill_Frozen_Aura = 109806,

    -- ---------------------------------------------------
    -- KEEP UPGRADE --------------------------------------
    -- ---------------------------------------------------

    Keep_Upgrade_Food_Guard_Range = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_GUARD_RANGE),
    Keep_Upgrade_Food_Heartier_Guards = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_HEARTIER_GUARDS),
    Keep_Upgrade_Food_Resistant_Guards = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_RESISTANT_GUARDS),
    Keep_Upgrade_Food_Stronger_Guards = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_STRONGER_GUARDS),
    Keep_Upgrade_Ore_Armored_Guards = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_ARMORED_GUARDS),
    Keep_Upgrade_Ore_Corner_Build = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_CORNER_BUILD),
    Keep_Upgrade_Ore_Siege_Platform = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_SIEGE_PLATFORM),
    Keep_Upgrade_Ore_Stronger_Walls = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_STRONGER_WALLS),
    Keep_Upgrade_Ore_Wall_Regeneration = GetString(LUIE_STRING_KEEP_UPGRADE_ORE_WALL_REGENERATION),
    Keep_Upgrade_Wood_Archer_Guard = GetString(LUIE_STRING_KEEP_UPGRADE_WOOD_ARCHER_GUARD),
    Keep_Upgrade_Wood_Door_Regeneration = GetString(LUIE_STRING_KEEP_UPGRADE_WOOD_DOOR_REGENERATION),
    Keep_Upgrade_Wood_Siege_Cap = GetString(LUIE_STRING_KEEP_UPGRADE_WOOD_SIEGE_CAP),
    Keep_Upgrade_Wood_Stronger_Doors = GetString(LUIE_STRING_KEEP_UPGRADE_WOOD_STRONGER_DOORS),
    Keep_Upgrade_Food_Mender_Abilities = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_MENDER_ABILITIES),
    Keep_Upgrade_Food_Honor_Guard_Abilities = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_HONOR_GUARD_ABILITIES),
    Keep_Upgrade_Food_Mage_Abilities = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_MAGE_ABILITIES),
    Keep_Upgrade_Food_Mage_Abilities_Fix = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_MAGE_ABILITIES_FIX),
    Keep_Upgrade_Food_Guard_Abilities = GetString(LUIE_STRING_KEEP_UPGRADE_FOOD_GUARD_ABILITIES),
}

--- @type AbilityTables[]
local AbilityTablesStrings = setmetatable({},
    {
        __index = function (t, k)
            local v = AbilityTables[k]
            if type(v) == "number" then
                local name = zo_strformat("<<C:1>>", GetAbilityName(v))
                t[k] = name
                return name
            elseif type(v) == "string" then
                t[k] = v
                return v
            end
            return v
        end
    })

-- Export string data to global namespace
--- @class (partial) AbilityTables
LuiData.Data.Abilities = AbilityTablesStrings
