-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

local GetAbilityName = GetAbilityName
local GetCollectibleName = GetCollectibleName
local GetItemLinkName = GetItemLinkName
local GetQuestItemName = GetQuestItemName
local GetQuestItemNameFromLink = GetQuestItemNameFromLink
local GetString = GetString
local GetUnitRaceId = GetUnitRaceId
local zo_strformat = zo_strformat

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
local abilityTables =
{

    -- Dragonknight — Vengeance Cyro templates (see docs/VENGEANCE_SKILL_MAP.csv)
    Skill_Vengeance_Standard = zo_strformat("<<C:1>>", GetAbilityName(237627)),          -- Vengeance Dragonknight Standard
    Skill_Vengeance_Lava_Whip = zo_strformat("<<C:1>>", GetAbilityName(237606)),         -- Vengeance Lava Whip
    Skill_Vengeance_Searing_Strike = zo_strformat("<<C:1>>", GetAbilityName(237607)),    -- Vengeance Searing Strike
    Skill_Vengeance_Dragonfire_Breath = zo_strformat("<<C:1>>", GetAbilityName(237615)), -- Vengeance Dragonfire Breath
    Skill_Vengeance_Chains_of_Flame = zo_strformat("<<C:1>>", GetAbilityName(237620)),   -- Vengeance Chains of Flame
    Skill_Vengeance_Inferno = zo_strformat("<<C:1>>", GetAbilityName(237624)),           -- Vengeance Inferno (Ardent Flame passive)
    Skill_Vengeance_Dragon_Leap = zo_strformat("<<C:1>>", GetAbilityName(237648)),       -- Vengeance Dragon Leap
    Skill_Vengeance_Earthspike_Mantle = zo_strformat("<<C:1>>", GetAbilityName(237630)), -- Vengeance Earthspike Mantle
    Skill_Vengeance_Dark_Talons = zo_strformat("<<C:1>>", GetAbilityName(237636)),       -- Vengeance Dark Talons
    Skill_Vengeance_Dragon_Blood = zo_strformat("<<C:1>>", GetAbilityName(237638)),      -- Vengeance Dragon Blood
    Skill_Vengeance_Wing_Buffet = zo_strformat("<<C:1>>", GetAbilityName(237639)),       -- Vengeance Wing Buffet
    Skill_Vengeance_Core_of_Flame = zo_strformat("<<C:1>>", GetAbilityName(237641)),     -- Vengeance Core of Flame
    Skill_Vengeance_Magma_Armor = zo_strformat("<<C:1>>", GetAbilityName(237790)),       -- Vengeance Magma Armor
    Skill_Vengeance_Superheated_Ward = zo_strformat("<<C:1>>", GetAbilityName(237781)),  -- Vengeance Superheated Ward
    Skill_Vengeance_Molten_Weapons = zo_strformat("<<C:1>>", GetAbilityName(237782)),    -- Vengeance Molten Weapons
    Skill_Vengeance_Obsidian_Shield = zo_strformat("<<C:1>>", GetAbilityName(237785)),   -- Vengeance Obsidian Shield
    Skill_Vengeance_Petrify = zo_strformat("<<C:1>>", GetAbilityName(237787)),           -- Vengeance Petrify
    Skill_Vengeance_Hearthfire = zo_strformat("<<C:1>>", GetAbilityName(237788)),        -- Vengeance Hearthfire

    -- ---------------------------------------------------
    -- GENERIC BUFFS & DEBUFFS ---------------------------
    -- ---------------------------------------------------

    -- Major/Minor
    Skill_Minor_Mangle = zo_strformat("<<C:1>>", GetAbilityName(61733)),

    -- Generic
    Skill_Off_Balance = zo_strformat("<<C:1>>", GetAbilityName(14062)),
    Skill_Off_Balance_Immunity = zo_strformat("<<C:1>>", GetAbilityName(134599)),
    Skill_Major_Vulnerability_Immunity = GetString(LUIE_STRING_SKILL_GENERIC_MAJOR_VULNERABILITY_IMMUNITY),
    Skill_Hindrance = zo_strformat("<<C:1>>", GetAbilityName(46210)),

    -- ---------------------------------------------------
    -- INNATE ABILITIES ----------------------------------
    -- ---------------------------------------------------

    -- Simulated Auras
    Innate_Recall = zo_strformat("<<C:1>>", GetAbilityName(6811)),
    Innate_Recall_Penalty = GetString(LUIE_STRING_SKILL_RECALL_PENALTY),               -- Recall Penalty
    Innate_Resurrection_Immunity = GetString(LUIE_STRING_SKILL_RESURRECTION_IMMUNITY), -- Resurrection Immunity
    Innate_Soul_Gem_Resurrection = GetString(LUIE_STRING_SKILL_SOUL_GEM_RESURRECTION), -- Soul Gem Resurrection

    -- Player Basic
    Innate_Immobilize_Immunity = zo_strformat("<<C:1>>", GetAbilityName(29721)),
    Innate_Stun = zo_strformat("<<C:1>>", GetAbilityName(14756)),      -- Stun
    Innate_Disguise = zo_strformat("<<C:1>>", GetAbilityName(31287)),  -- Disguise
    Innate_Disguised = zo_strformat("<<C:1>>", GetAbilityName(23553)), -- Disguised
    Innate_Sneak = zo_strformat("<<C:1>>", GetAbilityName(20299)),     -- Sneak
    Innate_Hidden = zo_strformat("<<C:1>>", GetAbilityName(20309)),    -- Hidden
    Innate_Mounted = GetString(LUIE_STRING_SKILL_MOUNTED),
    Innate_Mounted_Passenger = GetString(LUIE_STRING_SKILL_MOUNTED_PASSENGER),
    Innate_Vanity_Pet = GetString(SI_COLLECTIBLECATEGORYTYPE3),
    Innate_Assistant = GetString(SI_COLLECTIBLECATEGORYTYPE8),
    -- Innate_Sprint                     = zo_strformat("<<C:1>>", GetAbilityName(15614)), -- Sprint
    -- Innate_Gallop                     = GetString(LUIE_STRING_SKILL_MOUNT_SPRINT), -- Gallop
    Innate_Brace = zo_strformat("<<C:1>>", GetAbilityName(29761)),                     -- Brace
    Innate_Block = zo_strformat("<<C:1>>", GetAbilityName(2890)),                      -- Block
    Innate_Bash = zo_strformat("<<C:1>>", GetAbilityName(21970)),                      -- Bash
    Innate_Bash_Stun = zo_strformat("<<C:1>>", GetAbilityName(21971)),                 -- Bash Stun
    Innate_Fall_Damage = GetString(LUIE_STRING_SKILL_FALL_DAMAGE),                     -- Fall Damage
    Innate_Absorbing_Skyshard = GetString(LUIE_STRING_SKILL_ABSORBING_SKYSHARD),       -- Absorbing Skyshard
    Innate_Receiving_Boon = GetString(LUIE_STRING_SKILL_RECEIVING_BOON),               -- Receiving Boon
    Innate_Ayleid_Well = GetString(LUIE_STRING_SKILL_AYLEID_WELL),                     -- Ayleid Well
    Innate_Ayleid_Well_Fortified = GetString(LUIE_STRING_SKILL_AYLEID_WELL_FORTIFIED), -- Ayleid Well
    Innate_Aetherial_Well = zo_strformat("<<C:1>>", GetAbilityName(151928)),
    Innate_CC_Immunity = zo_strformat("<<C:1>>", GetAbilityName(38117)),               -- CC Immunity
    Innate_Stagger = zo_strformat("<<C:1>>", GetAbilityName(1834)),                    -- Stagger
    Innate_Revive = zo_strformat("<<C:1>>", GetAbilityName(5823)),                     -- Revive

    Innate_Create_Station = GetString(LUIE_STRING_SKILL_CRAFTING_STATION),
    Innate_Summon = zo_strformat("<<C:1>>", GetAbilityName(29585)),
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
    Innate_Create_Psijic_Ambrosia_Recipe = zo_strformat("<<C:1>>", GetAbilityName(68258)),

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
    Innate_Drop_Anchor = zo_strformat("<<C:1>>", GetAbilityName(86717)),         -- Drop Anchor
    Innate_Anchor_Drop = GetString(LUIE_STRING_SKILL_ANCHOR_DROP),               -- Anchor Drop
    Innate_Power_of_the_Daedra = zo_strformat("<<C:1>>", GetAbilityName(46690)), -- Power of the Daedra

    -- Weapon Attacks
    Skill_Light_Attack = zo_strformat("<<C:1>>", GetAbilityName(39088)),             -- Light Attack
    Skill_Medium_Attack = zo_strformat("<<C:1>>", GetAbilityName(39097)),            -- Medium Attack
    Skill_Heavy_Attack = zo_strformat("<<C:1>>", GetAbilityName(39101)),             -- Heavy Attack

    Skill_Light_Attack_Unarmed = zo_strformat("<<C:1>>", GetAbilityName(23604)),     -- Light Attack (Unarmed)
    Skill_Heavy_Attack_Unarmed = zo_strformat("<<C:1>>", GetAbilityName(18429)),     -- Heavy Attack (Unarmed)

    Skill_Light_Attack_Two_Handed = zo_strformat("<<C:1>>", GetAbilityName(16037)),  -- Light Attack (Two Handed)
    Skill_Heavy_Attack_Two_Handed = zo_strformat("<<C:1>>", GetAbilityName(16041)),  -- Heavy Attack (Two Handed)
    Skill_Light_Attack_One_Handed = zo_strformat("<<C:1>>", GetAbilityName(15435)),  -- Light Attack (One Handed)
    Skill_Heavy_Attack_One_Handed = zo_strformat("<<C:1>>", GetAbilityName(15279)),  -- Heavy Attack (One Handed)
    Skill_Light_Attack_Dual_Wield = zo_strformat("<<C:1>>", GetAbilityName(16499)),  -- Light Attack (Dual Wield)
    Skill_Heavy_Attack_Dual_Wield = zo_strformat("<<C:1>>", GetAbilityName(16420)),  -- Heavy Attack (Dual Wield)
    Skill_Light_Attack_Bow = zo_strformat("<<C:1>>", GetAbilityName(16688)),         -- Light Attack (Bow)
    Skill_Heavy_Attack_Bow = zo_strformat("<<C:1>>", GetAbilityName(16691)),         -- Heavy Attack (Bow)

    Skill_Light_Attack_Ice = zo_strformat("<<C:1>>", GetAbilityName(16277)),         -- Light Attack (Ice)
    Skill_Heavy_Attack_Ice = zo_strformat("<<C:1>>", GetAbilityName(16261)),         -- Heavy Attack (Ice)
    Skill_Light_Attack_Inferno = zo_strformat("<<C:1>>", GetAbilityName(16165)),     -- Light Attack (Inferno)
    Skill_Heavy_Attack_Inferno = zo_strformat("<<C:1>>", GetAbilityName(15383)),     -- Heavy Attack (Inferno)
    Skill_Light_Attack_Lightning = zo_strformat("<<C:1>>", GetAbilityName(18350)),   -- Light Attack (Lightning)
    Skill_Heavy_Attack_Lightning = zo_strformat("<<C:1>>", GetAbilityName(18396)),   -- Heavy Attack (Lightning)

    Skill_Light_Attack_Restoration = zo_strformat("<<C:1>>", GetAbilityName(16145)), -- Light Attack (Restoration)
    Skill_Heavy_Attack_Restoration = zo_strformat("<<C:1>>", GetAbilityName(16212)), -- Heavy Attack (Restoration)

    Skill_Light_Attack_Volendrung = zo_strformat("<<C:1>>", GetAbilityName(116762)), -- Light Attack (Volendrung)
    Skill_Heavy_Attack_Volendrung = zo_strformat("<<C:1>>", GetAbilityName(116763)), -- Heavy Attack (Volendrung)

    Skill_Light_Attack_Werewolf = zo_strformat("<<C:1>>", GetAbilityName(32464)),    -- Light Attack (Werewolf)
    Skill_Heavy_Attack_Werewolf = zo_strformat("<<C:1>>", GetAbilityName(32477)),    -- Heavy Attack (Werewolf)

    -- ---------------------------------------------------
    -- CONSUMABLES & ITEMS -------------------------------
    -- ---------------------------------------------------

    -- Glyphs
    Item_Glyph_of_Weapon_Damage = zo_strformat("<<C:1>>", GetAbilityName(17910)),

    -- Potions/Poisons
    Potion_Invisiblity = zo_strformat("<<C:1>>", GetAbilityName(3668)),
    Potion_Ravage_Health = zo_strformat("<<C:1>>", GetAbilityName(46111)),
    Potion_Restore_Health = zo_strformat("<<C:1>>", GetAbilityName(45221)),
    Potion_Restore_Magicka = zo_strformat("<<C:1>>", GetAbilityName(45223)),
    Potion_Restore_Stamina = zo_strformat("<<C:1>>", GetAbilityName(45225)),
    Poison_Creeping_Drain_Health = zo_strformat("<<C:1>>", GetAbilityName(79701)),
    Poison_Lingering_Restore_Health = zo_strformat("<<C:1>>", GetAbilityName(79702)),
    Poison_Stealth_Draining_Poison = GetString(LUIE_STRING_SKILL_POISON_STEALTH_DRAIN),
    Poison_Conspicuous_Poison = GetString(LUIE_STRING_SKILL_POISON_CONSPICUOUS),

    -- Food/Drink
    Food_Magicka_Stamina_Increase = zo_strformat("<<C:1>>", GetAbilityName(61294)),
    Food_Health_Stamina_Increase = zo_strformat("<<C:1>>", GetAbilityName(61255)),
    Food_Health_Magicka_Increase = zo_strformat("<<C:1>>", GetAbilityName(61257)),
    Food_Orzorgas_Tripe_Trifle_Pocket = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:71057:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Orzorgas_Blood_Price_Pie = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:71058:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Orzorgas_Smoked_Bear_Haunch = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:71059:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Pumpkin_Snack_Skewer = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:87686:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Frosted_Brains = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:87696:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Jagga_Drenched_Mud_Ball = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:112434:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Lava_Foot_Soup = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:112425:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Artaeum_Pickled_Fish_Bowl = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:139016:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Crown_Crate_Meal = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:94437:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Crown_Meal = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:64711:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Crown_Combat_Mystics_Stew = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:124675:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Food_Crown_Vigorous_Ragout = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:124676:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Drink_Health_Recovery = zo_strformat("<<C:1>>", GetAbilityName(61322)),
    Drink_Magicka_Recovery = zo_strformat("<<C:1>>", GetAbilityName(61325)),
    Drink_Stamina_Recovery = zo_strformat("<<C:1>>", GetAbilityName(61328)),
    Drink_Magicka_Stamina_Recovery = zo_strformat("<<C:1>>", GetAbilityName(61345)),
    Drink_Health_Stamina_Recovery = zo_strformat("<<C:1>>", GetAbilityName(61340)),
    Drink_Health_Magicka_Recovery = zo_strformat("<<C:1>>", GetAbilityName(61335)),
    Drink_Primary_Stat_Recovery = zo_strformat("<<C:1>>", GetAbilityName(61350)),
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
    Experience_Psijic_Ambrosia = GetItemLinkName("|H0:item:64221:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),       -- Psijic Ambrosia
    Experience_Aetherial_Ambrosia = GetItemLinkName("|H0:item:120076:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),   -- Aetherial Ambrosia
    Experience_Mythic_Ambrosia = GetItemLinkName("|H0:item:115027:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- Mythic Aetherial Ambrosia
    Experience_Tonic_Portent_Favor = GetItemLinkName("|H0:item:224839:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),  -- Tonic of Portent Favor
    Experience_Crown_Scroll = GetItemLinkName("|H0:item:64537:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),         -- Crown Experience Scroll
    Experience_Crown_Crate_Scroll_1 = GetItemLinkName("|H0:item:94439:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Gold Coast Experience Scroll
    Experience_Crown_Crate_Scroll_2 = GetItemLinkName("|H0:item:94440:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Major Gold Coast Experience Scroll
    Experience_Crown_Crate_Scroll_3 = GetItemLinkName("|H0:item:94441:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Grand Gold Coast Experience Scroll
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
    Memento_Jubliee_Cake = zo_strformat("<<C:1>>", GetAbilityName(87998)),
    Memento_Mud_Ball = zo_strformat("<<C:1>>", GetAbilityName(86749)),
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
    Set_Scourge_Harvester = zo_strformat("<<C:1>>", GetAbilityName(59564)),
    Set_Maw_of_the_Infernal = zo_strformat("<<C:1>>", GetAbilityName(59507)),
    Set_Nerieneth = zo_strformat("<<C:1>>", GetAbilityName(59592)),
    Set_Shadowrend = zo_strformat("<<C:1>>", GetAbilityName(80989)),
    Set_Spawn_of_Mephala = zo_strformat("<<C:1>>", GetAbilityName(59497)),
    Set_Swarm_Mother = zo_strformat("<<C:1>>", GetAbilityName(80592)),
    Set_The_Troll_King = GetString(LUIE_STRING_SKILL_SET_TROLL_KING),
    Set_Energy_Charge = GetString(LUIE_STRING_SKILL_SET_ENERGY_CHARGE),
    Set_Scavenging_Demise = zo_strformat("<<C:1>>", GetAbilityName(116947)),
    Set_Varens_Legacy = zo_strformat("<<C:1>>", GetAbilityName(79029)),
    Set_Syvarras_Scales = zo_strformat("<<C:1>>", GetAbilityName(75717)),
    Set_Twin_Sisters = zo_strformat("<<C:1>>", GetAbilityName(32828)),
    Set_Wilderqueens_Arch = zo_strformat("<<C:1>>", GetAbilityName(34870)),
    Set_Plague_Slinger = zo_strformat("<<C:1>>", GetAbilityName(102113)),
    Set_Ice_Furnace = GetString(LUIE_STRING_SKILL_SET_ICE_FURNACE),
    Set_Hand_of_Mephala = zo_strformat("<<C:1>>", GetAbilityName(84353)),
    Set_Hand_of_Mephala_Webbing = zo_strformat("<<C:1>>", GetAbilityName(84357)),
    Set_Tormentor = zo_strformat("<<C:1>>", GetAbilityName(67280)),
    Set_Destructive_Mage = zo_strformat("<<C:1>>", GetAbilityName(51315)),
    Set_Healing_Mage = zo_strformat("<<C:1>>", GetAbilityName(51442)),
    Set_Vicious_Serpent = zo_strformat("<<C:1>>", GetAbilityName(61440)),
    Set_Vicecannon_of_Venom = zo_strformat("<<C:1>>", GetAbilityName(79464)),
    Set_Cooldown = GetString(LUIE_STRING_SKILL_SET_COOLDOWN),
    Set_Eternal_Hunt = zo_strformat("<<C:1>>", GetAbilityName(75927)),
    Set_Glorious_Defender = zo_strformat("<<C:1>>", GetAbilityName(71180)),
    Set_Para_Bellum = zo_strformat("<<C:1>>", GetAbilityName(71191)),
    Set_Winterborn = zo_strformat("<<C:1>>", GetAbilityName(71644)),
    Set_Nocturnals_Favor = zo_strformat("<<C:1>>", GetAbilityName(106803)),
    Set_Vestment_of_Olorime = zo_strformat("<<C:1>>", GetAbilityName(107117)),
    Set_Mantle_of_Siroria = zo_strformat("<<C:1>>", GetAbilityName(107093)),
    Set_Harmful_Winds = GetString(LUIE_STRING_SKILL_SET_HARMFUL_WINDS),
    Set_Sloads_Semblance = zo_strformat("<<C:1>>", GetAbilityName(106797)),
    Set_Shield_of_Ursus = zo_strformat("<<C:1>>", GetAbilityName(111437)),
    Set_Ursus_Blessing = zo_strformat("<<C:1>>", GetAbilityName(112414)),
    Set_Grace_of_Gloom = zo_strformat("<<C:1>>", GetAbilityName(106865)),
    Set_Noble_Duelist = GetString(LUIE_STRING_SKILL_SET_NOBLE_DUELIST),
    Set_Soldier_of_Anguish = zo_strformat("<<C:1>>", GetAbilityName(113460)),
    Set_Affliction = zo_strformat("<<C:1>>", GetAbilityName(34787)),
    Set_Sentry = zo_strformat("<<C:1>>", GetAbilityName(32807)),
    Set_Line_Breaker = zo_strformat("<<C:1>>", GetAbilityName(75753)),
    Set_False_Gods_Devotion = zo_strformat("<<C:1>>", GetAbilityName(121823)),
    Set_Morkuldin = zo_strformat("<<C:1>>", GetAbilityName(71670)),
    Set_Senchals_Duty = zo_strformat("<<C:1>>", GetAbilityName(129442)),
    Set_Phoenix = zo_strformat("<<C:1>>", GetAbilityName(68933)),
    Set_Immortal_Warrior = zo_strformat("<<C:1>>", GetAbilityName(51300)),
    Set_Eternal_Warrior = zo_strformat("<<C:1>>", GetAbilityName(61436)),
    Set_Juggernaut = zo_strformat("<<C:1>>", GetAbilityName(34512)),
    Set_Honors_Scorn = zo_strformat("<<C:1>>", GetAbilityName(121917)),
    Set_Honors_Love = zo_strformat("<<C:1>>", GetAbilityName(121913)),
    Set_Warming_Aura = zo_strformat("<<C:1>>", GetAbilityName(133210)),
    Set_Aegis_Caller = zo_strformat("<<C:1>>", GetAbilityName(133490)),
    Set_Reactive_Armor = zo_strformat("<<C:1>>", GetAbilityName(68947)),
    Set_Kynes_Blessing = zo_strformat("<<C:1>>", GetAbilityName(136098)),
    Set_Blood_Curse = zo_strformat("<<C:1>>", GetAbilityName(139903)),
    Set_Sanguine_Burst = zo_strformat("<<C:1>>", GetAbilityName(142305)),
    Set_Heed_the_Call = zo_strformat("<<C:1>>", GetAbilityName(142780)),
    Set_Elemental_Catalyst = GetString(LUIE_STRING_SKILL_SET_ELEMENTAL_CATALYST),
    Set_Encratiss_Behemoth = GetString(LUIE_STRING_SKILL_SET_ENCRATISS_BEHEMOTH),
    Set_Slivers_Of_The_Null_Arca = GetString(LUIE_STRING_SKILL_SET_SLIVERS_OF_THE_NULL_ARCA),
    Set_Perfected_Slivers_Of_The_Null_Arca = GetString(LUIE_STRING_SKILL_SET_PERFECTED_SLIVERS_OF_THE_NULL_ARCA),
    Set_Legacy_of_Karth = zo_strformat("<<C:1>>", GetAbilityName(147388)),

    Disguise_Monks_Disguise = GetString(LUIE_STRING_SKILL_DISGUISE_MONKS_DISGUISE),

    -- ---------------------------------------------------
    -- CHAMPION ABILITIES --------------------------------
    -- ---------------------------------------------------

    Champion_Riposte = zo_strformat("<<C:1>>", GetAbilityName(60230)),
    Champion_Expert_Evasion = zo_strformat("<<C:1>>", GetAbilityName(151113)),

    -- ---------------------------------------------------
    -- SKILL LINE PASSIVES -------------------------------
    -- ---------------------------------------------------

    -- Sorcerer
    Passive_Persistence = zo_strformat("<<C:1>>", GetAbilityName(31378)),

    -- Templar
    Passive_Light_Weaver = zo_strformat("<<C:1>>", GetAbilityName(31760)),

    -- Warden
    Passive_Bond_with_Nature = GetString(LUIE_STRING_SKILL_BOND_WITH_NATURE),
    Passive_Savage_Beast = zo_strformat("<<C:1>>", GetAbilityName(86062)),
    Passive_Natures_Gift = zo_strformat("<<C:1>>", GetAbilityName(93054)),

    -- Weapon
    Passive_Follow_Up = zo_strformat("<<C:1>>", GetAbilityName(29389)),
    Passive_Destruction_Expert = zo_strformat("<<C:1>>", GetAbilityName(30965)),

    -- Soul Magic
    Passive_Soul_Summons = zo_strformat("<<C:1>>", GetAbilityName(39269)),

    -- Vampire
    Passive_Blood_Ritual = zo_strformat("<<C:1>>", GetAbilityName(33091)),

    -- Werewolf
    Passive_Bloodmoon = zo_strformat("<<C:1>>", GetAbilityName(32639)),

    -- Undaunted
    Passive_Undaunted_Command = zo_strformat("<<C:1>>", GetAbilityName(55584)),

    -- Racial
    Passive_Red_Diamond = zo_strformat("<<C:1>>", GetAbilityName(36155)),

    -- ---------------------------------------------------
    -- CLASS SKILLS --------------------------------------
    -- ---------------------------------------------------

    -- Dragonknight
    Skill_Fiery_Breath = zo_strformat("<<C:1>>", GetAbilityName(20917)),
    Skill_Chains_of_Flame = zo_strformat("<<C:1>>", GetAbilityName(20492)),
    Skill_Fiery_Grip = zo_strformat("<<C:1>>", GetAbilityName(20492)),        -- legacy key (NPC clones)
    Skill_Chains_of_Devastation = zo_strformat("<<C:1>>", GetAbilityName(20499)),
    Skill_Empowering_Chains = zo_strformat("<<C:1>>", GetAbilityName(20499)), -- legacy key
    Skill_Chains_of_Dominance = zo_strformat("<<C:1>>", GetAbilityName(20496)),
    Skill_Inferno = zo_strformat("<<C:1>>", GetAbilityName(28967)),
    Skill_Shackle = zo_strformat("<<C:1>>", GetAbilityName(32905)),
    Skill_Dragon_Blood = zo_strformat("<<C:1>>", GetAbilityName(29004)),
    Skill_Inhale = zo_strformat("<<C:1>>", GetAbilityName(31837)),
    Skill_Dragon_Leap = zo_strformat("<<C:1>>", GetAbilityName(29016)),
    Skill_Take_Flight = zo_strformat("<<C:1>>", GetAbilityName(32719)),
    Skill_Ferocious_Leap = zo_strformat("<<C:1>>", GetAbilityName(32715)),
    Skill_Wing_Buffet = zo_strformat("<<C:1>>", GetAbilityName(21007)),
    Skill_Fleetstep_Wings = zo_strformat("<<C:1>>", GetAbilityName(21014)),
    Skill_Protect_the_Brood = zo_strformat("<<C:1>>", GetAbilityName(21017)),
    Skill_Stonefist = zo_strformat("<<C:1>>", GetAbilityName(29032)), -- Superheated Ward (29032)
    Skill_Volcanic_Ward = zo_strformat("<<C:1>>", GetAbilityName(31820)),
    Skill_Magma_Fist = zo_strformat("<<C:1>>", GetAbilityName(31816)),
    Skill_Molten_Weapons = zo_strformat("<<C:1>>", GetAbilityName(29043)),
    Skill_Igneous_Weapons = zo_strformat("<<C:1>>", GetAbilityName(31874)),
    Skill_Molten_Armaments = zo_strformat("<<C:1>>", GetAbilityName(31888)),
    Skill_Obsidian_Shield = zo_strformat("<<C:1>>", GetAbilityName(29071)),
    Skill_Igneous_Shield = zo_strformat("<<C:1>>", GetAbilityName(29224)),
    Skill_Fragmented_Shield = zo_strformat("<<C:1>>", GetAbilityName(32673)),
    Skill_Earthspike_Mantle = zo_strformat("<<C:1>>", GetAbilityName(20319)),
    Skill_Earthshield_Mantle = zo_strformat("<<C:1>>", GetAbilityName(20328)),
    Skill_Shatterspike_Mantle = zo_strformat("<<C:1>>", GetAbilityName(20323)),

    -- Nightblade
    Skill_Death_Stroke = zo_strformat("<<C:1>>", GetAbilityName(33398)),
    Skill_Incapacitating_Strike = zo_strformat("<<C:1>>", GetAbilityName(36508)),
    Skill_Soul_Harvest = zo_strformat("<<C:1>>", GetAbilityName(36514)),
    Skill_Corrosive_Strike = zo_strformat("<<C:1>>", GetAbilityName(33219)),
    Skill_Corrosive_Spin = GetString(LUIE_STRING_SKILL_CORROSIVE_SPIN_TP),
    Skill_Summon_Shade = zo_strformat("<<C:1>>", GetAbilityName(GetSummonShade(summonShade))),
    Skill_Shade = "Shade",
    Skill_Dark_Shade = zo_strformat("<<C:1>>", GetAbilityName(GetDarkShade(darkShade))),
    Skill_Shadow_Image = zo_strformat("<<C:1>>", GetAbilityName(GetShadowImage(shadowImage))),
    Skill_Crippling_Grasp = zo_strformat("<<C:1>>", GetAbilityName(36957)),
    Skill_Sap_Essence = zo_strformat("<<C:1>>", GetAbilityName(36891)),

    -- Sorcerer
    Skill_Crystal_Shard = zo_strformat("<<C:1>>", GetAbilityName(43714)),
    Skill_Crystal_Blast = zo_strformat("<<C:1>>", GetAbilityName(46704)),
    Skill_Crystal_Fragments = zo_strformat("<<C:1>>", GetAbilityName(46324)),
    Skill_Daedric_Tomb = zo_strformat("<<C:1>>", GetAbilityName(24842)),
    Skill_Daedric_Minefield = zo_strformat("<<C:1>>", GetAbilityName(24834)),
    Skill_Unstable_Pulse = GetString(LUIE_STRING_SKILL_UNSTABLE_PULSE),
    Skill_Volatile_Pulse = GetString(LUIE_STRING_SKILL_VOLATILE_PULSE),
    Skill_Summon_Storm_Atronach = zo_strformat("<<C:1>>", GetAbilityName(23634)),
    Skill_Greater_Storm_Atronach = zo_strformat("<<C:1>>", GetAbilityName(23492)),
    Skill_Summon_Charged_Atronach = zo_strformat("<<C:1>>", GetAbilityName(23495)),
    Skill_Atronach_Zap = zo_strformat("<<C:1>>", GetAbilityName(23428)),
    Skill_Bound_Aegis = zo_strformat("<<C:1>>", GetAbilityName(24163)),
    Skill_Lightning_Form = zo_strformat("<<C:1>>", GetAbilityName(23210)),
    Skill_Kick = zo_strformat("<<C:1>>", GetAbilityName(4125)),
    Skill_Entropic_Touch = zo_strformat("<<C:1>>", GetAbilityName(9743)),
    Skill_Intercept = zo_strformat("<<C:1>>", GetAbilityName(23284)),

    -- Templar
    Skill_Puncturing_Sweep = zo_strformat("<<C:1>>", GetAbilityName(26797)),
    Skill_Aurora_Javelin = zo_strformat("<<C:1>>", GetAbilityName(26800)),
    Skill_Crescent_Sweep = zo_strformat("<<C:1>>", GetAbilityName(22139)),
    Skill_Sun_Fire = zo_strformat("<<C:1>>", GetAbilityName(21726)),
    Skill_Dark_Flare = zo_strformat("<<C:1>>", GetAbilityName(22110)),
    Skill_Unstable_Core = zo_strformat("<<C:1>>", GetAbilityName(22004)),
    Skill_Radiant_Glory = zo_strformat("<<C:1>>", GetAbilityName(63044)),
    Skill_Nova = zo_strformat("<<C:1>>", GetAbilityName(21752)),
    Skill_Solar_Disturbance = zo_strformat("<<C:1>>", GetAbilityName(21758)),
    Skill_Cleansing_Ritual = zo_strformat("<<C:1>>", GetAbilityName(22265)),
    Skill_Restoring_Focus = zo_strformat("<<C:1>>", GetAbilityName(22237)),

    -- Warden
    Skill_Feral_Guardian = zo_strformat("<<C:1>>", GetAbilityName(85982)),
    Skill_Eternal_Guardian = zo_strformat("<<C:1>>", GetAbilityName(85986)),
    Skill_Lotus_Blossom = zo_strformat("<<C:1>>", GetAbilityName(85855)),
    Skill_Natures_Grasp = zo_strformat("<<C:1>>", GetAbilityName(85564)),
    Skill_Bursting_Vines = zo_strformat("<<C:1>>", GetAbilityName(85859)),
    Skill_Natures_Embrace = zo_strformat("<<C:1>>", GetAbilityName(85858)),
    Skill_Shimmering_Shield = zo_strformat("<<C:1>>", GetAbilityName(86143)),
    Skill_Frozen_Device = zo_strformat("<<C:1>>", GetAbilityName(86179)),

    -- Necromancer
    Skill_Skeletal_Mage = zo_strformat("<<C:1>>", GetAbilityName(114317)),
    Skill_Skeletal_Arcanist = zo_strformat("<<C:1>>", GetAbilityName(118726)),
    Skill_Bitter_Harvest = zo_strformat("<<C:1>>", GetAbilityName(115238)),
    Skill_Deaden_Pain = zo_strformat("<<C:1>>", GetAbilityName(118623)),
    Skill_Bone_Goliath_Transformation = zo_strformat("<<C:1>>", GetAbilityName(115001)),
    Skill_Pummeling_Goliath = zo_strformat("<<C:1>>", GetAbilityName(118664)),
    Skill_Ravenous_Goliath = zo_strformat("<<C:1>>", GetAbilityName(118279)),

    -- ---------------------------------------------------
    -- WEAPON SKILLS -------------------------------------
    -- ---------------------------------------------------

    -- Restoration Staff
    Skill_Blessing_of_Restoration = GetString(LUIE_STRING_SKILL_BLESSING_OF_RESTORATION),

    -- Destruction Staff
    Skill_Crushing_Shock = zo_strformat("<<C:1>>", GetAbilityName(46348)),
    Skill_Frozen = zo_strformat("<<C:1>>", GetAbilityName(68719)),
    Skill_Flame_Touch = zo_strformat("<<C:1>>", GetAbilityName(29073)),
    Skill_Flame_Clench = zo_strformat("<<C:1>>", GetAbilityName(38985)),
    Skill_Shock_Clench = zo_strformat("<<C:1>>", GetAbilityName(38993)),
    Skill_Frost_Clench = zo_strformat("<<C:1>>", GetAbilityName(38989)),
    Skill_Weakness_to_Elements = zo_strformat("<<C:1>>", GetAbilityName(29173)),
    Skill_Frost_Pulsar = zo_strformat("<<C:1>>", GetAbilityName(39163)),

    -- Two-Handed
    Skill_Uppercut = zo_strformat("<<C:1>>", GetAbilityName(28279)),
    Skill_Stampede = zo_strformat("<<C:1>>", GetAbilityName(38788)),
    Skill_Cleave = zo_strformat("<<C:1>>", GetAbilityName(20919)),

    -- One Hand & Shield
    Skill_Puncture = zo_strformat("<<C:1>>", GetAbilityName(28306)),
    Skill_Deep_Slash = zo_strformat("<<C:1>>", GetAbilityName(38268)),
    Skill_Shield_Charge = zo_strformat("<<C:1>>", GetAbilityName(28719)),
    Skill_Invasion = zo_strformat("<<C:1>>", GetAbilityName(38405)),
    Skill_Power_Bash = zo_strformat("<<C:1>>", GetAbilityName(28365)),

    -- Dual Wield
    Skill_Twin_Slashes = zo_strformat("<<C:1>>", GetAbilityName(28379)),
    Skill_Hidden_Blade = zo_strformat("<<C:1>>", GetAbilityName(21157)),
    Skill_Shrouded_Daggers = zo_strformat("<<C:1>>", GetAbilityName(38914)),
    Skill_Flying_Blade = zo_strformat("<<C:1>>", GetAbilityName(38910)),

    -- Bow
    Skill_Draining_Shot = zo_strformat("<<C:1>>", GetAbilityName(38669)),
    Skill_Bombard = zo_strformat("<<C:1>>", GetAbilityName(38705)),
    Skill_Venom_Arrow = zo_strformat("<<C:1>>", GetAbilityName(38645)),
    Skill_Rapid_Fire = zo_strformat("<<C:1>>", GetAbilityName(83465)),

    -- ---------------------------------------------------
    -- ARMOR SKILLS --------------------------------------
    -- ---------------------------------------------------

    -- Heavy Armor
    Skill_Unstoppable_Brute = zo_strformat("<<C:1>>", GetAbilityName(39205)),

    -- ---------------------------------------------------
    -- SOUL MAGIC SKILLS ---------------------------------
    -- ---------------------------------------------------

    Skill_Consuming_Trap = zo_strformat("<<C:1>>", GetAbilityName(40317)),

    -- ---------------------------------------------------
    -- VAMPIRE SKILLS ------------------------------------
    -- ---------------------------------------------------

    Skill_Feed = zo_strformat("<<C:1>>", GetAbilityName(33152)),
    Skill_Vampirism = GetString(LUIE_STRING_SKILL_VAMPIRISM),
    Skill_Profane_Symbol = GetString(LUIE_STRING_SKILL_PROFANE_SYMBOL),
    Skill_Blood_Scion = zo_strformat("<<C:1>>", GetAbilityName(32624)),
    Skill_Swarming_Scion = zo_strformat("<<C:1>>", GetAbilityName(38932)),
    Skill_Perfect_Scion = zo_strformat("<<C:1>>", GetAbilityName(38931)),

    -- ---------------------------------------------------
    -- WEREWOLF SKILLS -----------------------------------
    -- ---------------------------------------------------

    Skill_Werewolf_Transformation = zo_strformat("<<C:1>>", GetAbilityName(32455)),
    Skill_Devour = zo_strformat("<<C:1>>", GetAbilityName(32634)),
    Skill_Carnage = zo_strformat("<<C:1>>", GetAbilityName(137157)),
    Skill_Brutal_Carnage = zo_strformat("<<C:1>>", GetAbilityName(137186)),
    Skill_Feral_Carnage = zo_strformat("<<C:1>>", GetAbilityName(137165)),
    Skill_Hircines_Rage = zo_strformat("<<C:1>>", GetAbilityName(58317)),
    Skill_Blood_Hunger = zo_strformat("<<C:1>>", GetAbilityName(267744)),
    Skill_Gnash = zo_strformat("<<C:1>>", GetAbilityName(58405)),
    Skill_Bloody_Gnash = zo_strformat("<<C:1>>", GetAbilityName(58798)),
    Skill_Bloodclaws = zo_strformat("<<C:1>>", GetAbilityName(58879)),
    Skill_Insatiable_Hunger = zo_strformat("<<C:1>>", GetAbilityName(268571)),
    Skill_Enduring_Rampage = zo_strformat("<<C:1>>", GetAbilityName(267425)),
    Skill_Remove = zo_strformat("<<C:1>>", GetAbilityName(31262)),

    -- ---------------------------------------------------
    -- GUILD SKILLS --------------------------------------
    -- ---------------------------------------------------

    -- Dark Brotherhood
    Skill_Blade_of_Woe = zo_strformat("<<C:1>>", GetAbilityName(78219)),

    -- Fighters Guild
    Skill_Revealed = zo_strformat("<<C:1>>", GetAbilityName(11717)),
    Skill_Marked = zo_strformat("<<C:1>>", GetAbilityName(103943)),
    Skill_Lightweight_Beast_Trap = zo_strformat("<<C:1>>", GetAbilityName(40372)),
    Skill_Flawless_Dawnbreaker = zo_strformat("<<C:1>>", GetAbilityName(40161)),

    -- Mages Guild
    Skill_Magelight = zo_strformat("<<C:1>>", GetAbilityName(30920)),
    Skill_Entropy = zo_strformat("<<C:1>>", GetAbilityName(28567)),
    Skill_Meteor = zo_strformat("<<C:1>>", GetAbilityName(16536)),
    Skill_Ice_Comet = zo_strformat("<<C:1>>", GetAbilityName(40489)),
    Skill_Shooting_Star = zo_strformat("<<C:1>>", GetAbilityName(40493)),

    -- Psijic Order
    Skill_Imbue_Weapon = zo_strformat("<<C:1>>", GetAbilityName(103483)),
    Skill_Elemental_Weapon = zo_strformat("<<C:1>>", GetAbilityName(103571)),
    Skill_Crushing_Weapon = zo_strformat("<<C:1>>", GetAbilityName(103623)),

    -- Undaunted
    Skill_Black_Widow = zo_strformat("<<C:1>>", GetAbilityName(41994)),
    Skill_Arachnophobia = zo_strformat("<<C:1>>", GetAbilityName(42016)),

    -- ---------------------------------------------------
    -- ALLIANCE WAR --------------------------------------
    -- ---------------------------------------------------

    -- Assault
    Skill_Caltrops = zo_strformat("<<C:1>>", GetAbilityName(33376)),
    Skill_Razor_Caltrops = zo_strformat("<<C:1>>", GetAbilityName(40242)),

    -- Support
    Skill_Lingering_Flare = zo_strformat("<<C:1>>", GetAbilityName(61519)),
    Skill_Reviving_Barrier = zo_strformat("<<C:1>>", GetAbilityName(40237)),
    Skill_Shocking_Banner = zo_strformat("<<C:1>>", GetAbilityName(217706)),

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
    Skill_Ballista = zo_strformat("<<C:1>>", GetAbilityName(68205)),
    Skill_Fire_Ballista = zo_strformat("<<C:1>>", GetAbilityName(35049)),
    Skill_Lightning_Ballista = GetString(LUIE_STRING_SKILL_LIGHTNING_BALLISTA),

    Skill_Stone_Trebuchet = zo_strformat("<<C:1>>", GetAbilityName(14159)),
    Skill_Iceball_Trebuchet = zo_strformat("<<C:1>>", GetAbilityName(13551)),
    Skill_Firepot_Trebuchet = zo_strformat("<<C:1>>", GetAbilityName(7010)),
    Skill_Meatbag_Catapult = zo_strformat("<<C:1>>", GetAbilityName(14774)),
    Skill_Oil_Catapult = zo_strformat("<<C:1>>", GetAbilityName(16789)),
    Skill_Scattershot_Catapult = zo_strformat("<<C:1>>", GetAbilityName(14611)),

    Skill_Shock_Lancer = zo_strformat("<<C:1>>", GetAbilityName(138555)),
    Skill_Fire_Lancer = zo_strformat("<<C:1>>", GetAbilityName(138426)),
    Skill_Frost_Lancer = zo_strformat("<<C:1>>", GetAbilityName(138551)),

    Skill_Cold_Stone_Trebuchet = GetString(LUIE_STRING_SKILL_COLD_STONE_TREBUCHET),
    Skill_Cold_Fire_Trebuchet = GetString(LUIE_STRING_SKILL_COLD_FIRE_TREBUCHET),
    Skill_Cold_Fire_Ballista = GetString(LUIE_STRING_SKILL_COLD_FIRE_BALLISTA),

    Skill_Flaming_Oil = zo_strformat("<<C:1>>", GetAbilityName(15774)),
    Skill_Battering_Ram = zo_strformat("<<C:1>>", GetAbilityName(15197)),

    Skill_Siege_Repair_Kit = GetItemLinkName("|H0:item:27112:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),          -- Siege Repair Kit
    Skill_Keep_Wall_Repair_Kit = GetItemLinkName("|H0:item:27138:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),      -- Keep Wall Masonry Repair Kit
    Skill_Keep_Door_Repair_Kit = GetItemLinkName("|H0:item:27962:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),      -- Keep Door Woodwork Repair Kit
    Skill_Bridge_Repair_Kit = GetItemLinkName("|H0:item:142133:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"),        -- Bridge and Milegate Repair Kit
    Skill_Practice_Siege_Repair_Kit = GetItemLinkName("|H0:item:43056:1:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h"), -- Practice Siege Repair Kit

    Skill_Pact_Forward_Camp = GetItemLinkName("|H0:item:29534:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),          -- Pact Foward Camp
    Skill_Dominion_Forward_Camp = GetItemLinkName("|H0:item:29533:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- Dominion Forward Camp
    Skill_Covenant_Forward_Camp = GetItemLinkName("|H0:item:29535:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),      -- Covenant Forward Camp

    -- Vengeance bag (Cyrodiil)
    Item_Vengeance_Repair_Kit = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:223122:175:1:0:0:0:0:0:0:0:0:0:0:0:0:36:0:0:0:0:0|h|h")),                 -- Cyrodiil Repair Kit of Vengeance
    Item_Vengeance_Flaming_Oil = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214329:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),                    -- Flaming Oil of Vengeance
    Item_Vengeance_Pact_Ballista = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214324:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),                   -- Pact Ballista of Vengeance
    Item_Vengeance_Pact_Battering_Ram = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214328:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),              -- Pact Battering Ram of Vengeance
    Item_Vengeance_Pact_Forward_Camp = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214347:2:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h")),               -- Pact Forward Camp of Vengeance
    Item_Vengeance_Pact_Meatbag_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:219146:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),          -- Pact Meatbag Catapult of Vengeance
    Item_Vengeance_Pact_Oil_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:223689:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),              -- Pact Oil Catapult of Vengeance
    Item_Vengeance_Pact_Scattershot_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:223696:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),      -- Pact Scattershot Catapult of Vengeance
    Item_Vengeance_Pact_Stone_Trebuchet = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214319:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),            -- Pact Stone Trebuchet of Vengeance
    Item_Vengeance_Dominion_Ballista = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214323:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),                 -- Dominion Ballista of Vengeance
    Item_Vengeance_Dominion_Battering_Ram = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214326:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),            -- Dominion Battering Ram of Vengeance
    Item_Vengeance_Dominion_Forward_Camp = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214346:2:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h")),             -- Dominion Forward Camp of Vengeance
    Item_Vengeance_Dominion_Meatbag_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:219145:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),        -- Dominion Meatbag Catapult of Vengeance
    Item_Vengeance_Dominion_Oil_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:223688:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),            -- Dominion Oil Catapult of Vengeance
    Item_Vengeance_Dominion_Scattershot_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:223694:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),    -- Dominion Scattershot Catapult of Vengeance
    Item_Vengeance_Dominion_Stone_Trebuchet = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214318:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),          -- Dominion Stone Trebuchet of Vengeance
    Item_Vengeance_Covenant_Ballista = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214325:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),                 -- Covenant Ballista of Vengeance
    Item_Vengeance_Covenant_Battering_Ram = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214327:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),            -- Covenant Battering Ram of Vengeance
    Item_Vengeance_Covenant_Forward_Camp = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214348:2:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h")),             -- Covenant Forward Camp of Vengeance
    Item_Vengeance_Covenant_Meatbag_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:219147:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),        -- Covenant Meatbag Catapult of Vengeance
    Item_Vengeance_Covenant_Oil_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:223690:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),            -- Covenant Oil Catapult of Vengeance
    Item_Vengeance_Covenant_Scattershot_Catapult = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:223695:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),    -- Covenant Scattershot Catapult of Vengeance
    Item_Vengeance_Covenant_Stone_Trebuchet = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214320:2:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),          -- Covenant Stone Trebuchet of Vengeance
    Item_Vengeance_Soul_Gem = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214316:32:50:0:0:0:0:0:0:0:0:0:0:0:65:36:0:1:0:0:0|h|h")),                    -- Soul Gem of Vengeance
    Item_Vengeance_Keep_Recall_Stone = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:220376:6:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h")),               -- Vengeance Keep Recall Stone
    Item_Vengeance_Tri_Restoration_Potion = zo_strformat("<<C:1>>", GetItemLinkName("|H1:item:214314:123:1:0:0:0:0:0:0:0:0:0:0:0:65:36:0:1:0:0:0|h|h")),      -- Tri-Restoration Potion of Vengeance
    Item_Vengeance_Keep_Recall_Cooldown = zo_strformat("<<C:1>>", GetAbilityName(254630)),                                                                  -- Vengeance Keep Recall Cooldown

    Skill_Razor_Armor = zo_strformat("<<C:1>>", GetAbilityName(36304)),

    Skill_Consume_Lifeforce = GetString(LUIE_STRING_SKILL_CONSUME_LIFEFORCE),
    Skill_Wall_of_Souls = zo_strformat("<<C:1>>", GetAbilityName(21677)),

    -- ---------------------------------------------------
    -- BATTLEGROUNDS -------------------------------------
    -- ---------------------------------------------------

    Skill_Mark_of_the_Worm = zo_strformat("<<C:1>>", GetAbilityName(95830)),

    -- ---------------------------------------------------
    -- NPC ABILITIES -------------------------------------
    -- ---------------------------------------------------

    -- Shared/Basic
    Skill_Hamstring = zo_strformat("<<C:1>>", GetAbilityName(70068)),
    Skill_Boss_CC_Immunity = GetString(LUIE_STRING_SKILL_BOSS_CC_IMMUNITY),
    Skill_Backstabber = zo_strformat("<<C:1>>", GetAbilityName(13739)),

    -- Human
    Skill_Ignite = zo_strformat("<<C:1>>", GetAbilityName(14070)),
    Skill_Shield_Rush = GetString(LUIE_STRING_SKILL_SHIELD_RUSH),
    Skill_Shock_Aura = zo_strformat("<<C:1>>", GetAbilityName(17867)),
    Skill_Shock_Blast = zo_strformat("<<C:1>>", GetAbilityName(85255)),
    Skill_Improved = GetString(LUIE_STRING_SKILL_IMPROVED),
    Skill_Knockback = zo_strformat("<<C:1>>", GetAbilityName(77905)),
    Skill_Weakness = zo_strformat("<<C:1>>", GetAbilityName(8705)),
    Skill_Staff_Strike = zo_strformat("<<C:1>>", GetAbilityName(2901)),
    Skill_Ice_Barrier = zo_strformat("<<C:1>>", GetAbilityName(14178)),
    Skill_Vanish = zo_strformat("<<C:1>>", GetAbilityName(24687)),
    Skill_Bone_Cage = zo_strformat("<<C:1>>", GetAbilityName(35387)),
    Skill_Defensive_Ward = GetString(LUIE_STRING_SKILL_DEFENSIVE_WARD),
    Skill_Divine_Leap = zo_strformat("<<C:1>>", GetAbilityName(54027)),
    Skill_Inspire = GetString(LUIE_STRING_SKILL_INSPIRE),
    Skill_Hide_in_Shadows = GetString(LUIE_STRING_SKILL_HIDE_IN_SHADOWS),
    Skill_Recover = zo_strformat("<<C:1>>", GetAbilityName(42905)),
    Skill_Clobber = zo_strformat("<<C:1>>", GetAbilityName(24671)),
    Skill_Shadowy_Barrier = GetString(LUIE_STRING_SKILL_SHADOWY_BARRIER),
    Skill_Flare_Trap = zo_strformat("<<C:1>>", GetAbilityName(74628)),
    Skill_Bear_Trap = zo_strformat("<<C:1>>", GetAbilityName(39058)),
    Skill_Void_Burst = zo_strformat("<<C:1>>", GetAbilityName(36987)),

    -- Justice
    Skill_Heavy_Blow = zo_strformat("<<C:1>>", GetAbilityName(63157)),
    Skill_Mighty_Charge = GetString(LUIE_STRING_SKILL_MIGHTY_CHARGE),
    Skill_Throw_Dagger = zo_strformat("<<C:1>>", GetAbilityName(28499)),
    Skill_Detection = GetString(LUIE_STRING_SKILL_DETECTION),

    -- Cyrodiil
    Skill_Shock_Torrent = zo_strformat("<<C:1>>", GetAbilityName(46726)),
    Skill_Improved_Shock_Torrent = GetString(LUIE_STRING_SKILL_IMPROVED_SHOCK_TORRENT),
    Skill_Lasting_Storm = zo_strformat("<<C:1>>", GetAbilityName(46818)),
    Skill_Bleeding_Strike = zo_strformat("<<C:1>>", GetAbilityName(46830)),
    Skill_Telekinetic_Prison = zo_strformat("<<C:1>>", GetAbilityName(21636)),
    Skill_Shattering_Prison = zo_strformat("<<C:1>>", GetAbilityName(46905)),
    Skill_Siege_Barrier = GetString(LUIE_STRING_SKILL_SIEGE_BARRIER),
    Skill_Fire_Torrent = GetString(LUIE_STRING_SKILL_FIRE_TORRENT),
    Skill_Improved_Fire_Torrent = zo_strformat("<<C:1>>", GetAbilityName(46990)),
    Skill_Puncturing_Chains = GetString(LUIE_STRING_SKILL_PUNCTURING_CHAINS),
    Skill_Improved_Volley = GetString(LUIE_STRING_SKILL_IMPROVED_VOLLEY),

    -- Animals
    Skill_Lacerate = zo_strformat("<<C:1>>", GetAbilityName(5452)),
    Skill_Bite = zo_strformat("<<C:1>>", GetAbilityName(17957)),
    Skill_Savage_Blow = zo_strformat("<<C:1>>", GetAbilityName(139956)),
    Skill_Slam = zo_strformat("<<C:1>>", GetAbilityName(70366)),
    Skill_Rip_and_Tear = GetString(LUIE_STRING_SKILL_RIP_AND_TEAR),
    Skill_Rush = zo_strformat("<<C:1>>", GetAbilityName(14380)),
    Skill_Vigorus_Swipes = zo_strformat("<<C:1>>", GetAbilityName(75634)),
    Skill_Barreling_Charge = GetString(LUIE_STRING_SKILL_BARRELING_CHARGE),
    Skill_Storm_Bound = zo_strformat("<<C:1>>", GetAbilityName(55864)),
    Skill_Swipe = zo_strformat("<<C:1>>", GetAbilityName(2850)),
    Skill_Blitz = GetString(LUIE_STRING_SKILL_BLITZ),
    Skill_Toxic_Mucus = zo_strformat("<<C:1>>", GetAbilityName(72793)),
    Skill_Gore = zo_strformat("<<C:1>>", GetAbilityName(85202)),
    Skill_Bile_Spit = zo_strformat("<<C:1>>", GetAbilityName(64559)),

    -- Insects
    Skill_Paralyze = zo_strformat("<<C:1>>", GetAbilityName(6756)),
    Skill_Web = zo_strformat("<<C:1>>", GetAbilityName(58521)),
    Skill_Inject_Larva = zo_strformat("<<C:1>>", GetAbilityName(9229)),
    Skill_Zoom = GetString(LUIE_STRING_SKILL_ZOOM),
    Skill_Vile_Bite = zo_strformat("<<C:1>>", GetAbilityName(61243)),
    Skill_Infectious_Swarm = zo_strformat("<<C:1>>", GetAbilityName(61360)),
    Skill_Necrotic_Explosion = zo_strformat("<<C:1>>", GetAbilityName(61427)),
    Skill_Contagion = zo_strformat("<<C:1>>", GetAbilityName(47838)),
    Skill_Plow = GetString(LUIE_STRING_SKILL_PLOW),
    Skill_Zap = zo_strformat("<<C:1>>", GetAbilityName(8429)),
    Skill_Leeching_Bite = GetString(LUIE_STRING_SKILL_LEECHING_BITE),
    Skill_Fetcherfly_Colony = GetString(LUIE_STRING_SKILL_FETCHERFLY_COLONY),
    Skill_Fetcherfly_Swarm = GetString(LUIE_STRING_SKILL_FETCHERFLY_SWARM),
    Skill_Call_Scribs = zo_strformat("<<C:1>>", GetAbilityName(38545)),

    -- Daedra
    Skill_Summon_Daedric_Arch = zo_strformat("<<C:1>>", GetAbilityName(65404)),
    Skill_Empower_Atronach_Flame = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_FLAME),
    Skill_Empower_Atronach_Frost = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_FROST),
    Skill_Empower_Atronach_Storm = GetString(LUIE_STRING_SKILL_EMPOWER_ATRONACH_STORM),
    Skill_Headbutt = zo_strformat("<<C:1>>", GetAbilityName(54380)),
    Skill_Tail_Spike = zo_strformat("<<C:1>>", GetAbilityName(4799)),
    Skill_Rending_Leap = zo_strformat("<<C:1>>", GetAbilityName(93745)),
    Skill_Radiance = zo_strformat("<<C:1>>", GetAbilityName(4891)),
    Skill_Unyielding_Mace = zo_strformat("<<C:1>>", GetAbilityName(4817)),
    Skill_Pin = zo_strformat("<<C:1>>", GetAbilityName(65709)),
    Skill_Sweep = zo_strformat("<<C:1>>", GetAbilityName(67872)),
    Skill_Enrage = zo_strformat("<<C:1>>", GetAbilityName(71696)),
    Skill_Stomp = zo_strformat("<<C:1>>", GetAbilityName(91848)),
    Skill_Boulder_Toss = zo_strformat("<<C:1>>", GetAbilityName(91855)),
    Skill_Shockwave = zo_strformat("<<C:1>>", GetAbilityName(4653)),
    Skill_Doom_Truths_Gaze = zo_strformat("<<C:1>>", GetAbilityName(9219)),
    Skill_The_Feast = zo_strformat("<<C:1>>", GetAbilityName(11083)),
    Skill_Flame_Geyser = zo_strformat("<<C:1>>", GetAbilityName(34376)),

    -- Undead
    Skill_Desecrated_Ground = zo_strformat("<<C:1>>", GetAbilityName(38828)),
    Skill_Colossal_Stomp = GetString(LUIE_STRING_SKILL_COLOSSAL_STOMP),
    Skill_Defiled_Ground = zo_strformat("<<C:1>>", GetAbilityName(22521)),
    Skill_Soul_Rupture = zo_strformat("<<C:1>>", GetAbilityName(73931)),

    -- Monsters
    Skill_Luring_Snare = zo_strformat("<<C:1>>", GetAbilityName(2821)),
    Skill_Assault = zo_strformat("<<C:1>>", GetAbilityName(4304)),
    Skill_Crushing_Limbs = zo_strformat("<<C:1>>", GetAbilityName(3855)),
    Skill_Pillars_of_Nirn = zo_strformat("<<C:1>>", GetAbilityName(75955)),
    Skill_Claw = zo_strformat("<<C:1>>", GetAbilityName(27922)),
    Skill_Obliterate = zo_strformat("<<C:1>>", GetAbilityName(127908)),
    Skill_Fiery_Surge = zo_strformat("<<C:1>>", GetAbilityName(75949)),

    -- Dwemer
    Skill_Static_Shield = zo_strformat("<<C:1>>", GetAbilityName(64463)),
    Skill_Dart = zo_strformat("<<C:1>>", GetAbilityName(7485)),
    Skill_Split_Bolt = zo_strformat("<<C:1>>", GetAbilityName(91093)),
    Skill_Turret_Mode = zo_strformat("<<C:1>>", GetAbilityName(71045)),
    Skill_Overcharge = zo_strformat("<<C:1>>", GetAbilityName(27333)),

    -- ---------------------------------------------------
    -- TRAPS ---------------------------------------------
    -- ---------------------------------------------------

    Trap_Cold_Fire_Trap = GetString(LUIE_STRING_SKILL_COLD_FIRE_TRAP),
    Trap_Falling_Rocks = zo_strformat("<<C:1>>", GetAbilityName(20886)),
    Trap_Fire_Trap = zo_strformat("<<C:1>>", GetAbilityName(17198)),
    Trap_Spike_Trap = zo_strformat("<<C:1>>", GetAbilityName(21940)),
    Trap_Sigil_of_Frost = zo_strformat("<<C:1>>", GetAbilityName(20258)),

    Trap_Lava_Trap = GetString(LUIE_STRING_SKILL_LAVA_TRAP),
    Trap_Lightning_Trap = GetString(LUIE_STRING_SKILL_LIGHTNING_TRAP),
    Trap_Blade_Trap = zo_strformat("<<C:1>>", GetAbilityName(66793)),

    Trap_Slaughterfish = zo_strformat("<<C:1>>", GetItemLinkName("|H0:item:42861:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h")),
    Trap_Lava = zo_strformat("<<C:1>>", GetAbilityName(5139)),

    Trap_Charge_Wire = GetString(LUIE_STRING_SKILL_CHARGE_WIRE),
    Trap_Steam_Vent = GetString(LUIE_STRING_SKILL_STEAM_VENT),

    Trap_Static_Pitcher = GetItemLinkName("|H0:item:145491:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Trap_Gas_Blossom = GetItemLinkName("|H0:item:145492:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),
    Trap_Lantern_Mantis = GetItemLinkName("|H0:item:145493:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    Trap_Hiding_Spot = zo_strformat("<<C:1>>", GetAbilityName(72712)),

    -- ---------------------------------------------------
    -- WORLD BOSSES --------------------------------------
    -- ---------------------------------------------------

    Skill_Ferocious_Charge = zo_strformat("<<C:1>>", GetAbilityName(83033)),
    Skill_Molten_Impact = zo_strformat("<<C:1>>", GetAbilityName(83203)),
    Skill_Molten_Pillar_Incalescence = GetString(LUIE_STRING_SKILL_MOLTEN_PILLAR_INCALESCENCE),
    Skill_Trapping_Bolt = zo_strformat("<<C:1>>", GetAbilityName(83925)),
    Skill_Remove_Bolt = zo_strformat("<<C:1>>", GetAbilityName(25763)),
    Skill_Poison_Spit = zo_strformat("<<C:1>>", GetAbilityName(21708)),
    Skill_Graven_Slash = zo_strformat("<<C:1>>", GetAbilityName(84292)),

    -- ---------------------------------------------------
    -- QUEST ABILITIES -----------------------------------
    -- ---------------------------------------------------

    -- Seasonal
    Skill_Lava_Foot_Stomp = GetString(LUIE_STRING_SKILL_LAVA_FOOT_STOMP),
    Skill_Knife_Juggling = GetString(LUIE_STRING_SKILL_KNIFE_JUGGLING),
    Skill_Torch_Juggling = GetString(LUIE_STRING_SKILL_TORCH_JUGGLING),
    Skill_Sword_Swallowing = zo_strformat("<<C:1>>", GetAbilityName(84533)),
    Skill_Celebratory_Belch = zo_strformat("<<C:1>>", GetAbilityName(84847)),
    Event_Petal_Pelters = GetQuestItemNameFromLink("|H0:quest_item:6145|h|h"),
    Event_Crow_Caller = GetItemLinkName("|H0:item:81189:1:1:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"),

    Event_Sparkle_Dazzler = GetQuestItemNameFromLink("|H0:quest_item:6191|h|h"),
    Event_Burst_Dazzler = GetQuestItemNameFromLink("|H0:quest_item:6192|h|h"),
    Event_Flash_Dazzler = GetQuestItemNameFromLink("|H0:quest_item:6193|h|h"),

    Skill_Grease_Slip = zo_strformat("<<C:1>>", GetAbilityName(143695)),
    Skill_Thrash = zo_strformat("<<C:1>>", GetAbilityName(144340)),

    -- MSQ
    Skill_Wall_of_Flames = GetString(LUIE_STRING_SKILL_WALL_OF_FLAMES),
    Skill_Necrotic = zo_strformat("<<C:1>>", GetAbilityName(41852)),
    Skill_Barrier = zo_strformat("<<C:1>>", GetAbilityName(38573)),
    Skill_Swordstorm = zo_strformat("<<C:1>>", GetAbilityName(36858)),
    Skill_Flame_Shield = zo_strformat("<<C:1>>", GetAbilityName(37173)),
    Skill_Royal_Strike = zo_strformat("<<C:1>>", GetAbilityName(38729)),
    Skill_Consecrate_Shrine = GetString(LUIE_STRING_SKILL_CONSECRATE_SHRINE),
    Skill_Remove_Ward = "Remove Ward",
    Skill_Shock = zo_strformat("<<C:1>>", GetAbilityName(27598)),
    Skill_Drink_Mead = zo_strformat("<<C:1>>", GetAbilityName(13941)),
    Skill_Unstable_Portal = GetString(LUIE_STRING_SKILL_UNSTABLE_PORTAL),
    Skill_Stabilize_Portal = GetString(LUIE_STRING_SKILL_STABILIZE_PORTAL),
    Skill_Close_Unstable_Rift = GetString(LUIE_STRING_SKILL_CLOSE_UNSTABLE_RIFT),

    -- Fighters Guild
    Skill_Palolels_Rage = zo_strformat("<<C:1>>", GetAbilityName(39577)),
    Skill_Prismatic_Light = zo_strformat("<<C:1>>", GetAbilityName(25981)),
    Skill_Quick_Strike = zo_strformat("<<C:1>>", GetAbilityName(10618)),
    Skill_Quick_Shot = zo_strformat("<<C:1>>", GetAbilityName(12437)),
    Skill_Flame_Blossom = GetString(LUIE_STRING_SKILL_FLAME_BLOSSOM),

    -- Mages Guild
    Skill_Rock = zo_strformat("<<C:1>>", GetAbilityName(26775)),
    Skill_Essence = zo_strformat("<<C:1>>", GetAbilityName(25337)),
    Skill_Sahdinas_Essence = GetString(LUIE_STRING_SKILL_SAHDINAS_ESSENCE),
    Skill_Rashomtas_Essence = GetString(LUIE_STRING_SKILL_RASHOMTAS_ESSENCE),
    Skill_Polymorph_Skeleton = GetString(LUIE_STRING_SKILL_POLYMORPH_SKELETON),
    Skill_Drain_Vitality = zo_strformat("<<C:1>>", GetAbilityName(8787)),
    Skill_Ungulate_Ordnance = zo_strformat("<<C:1>>", GetAbilityName(39393)),

    -- Aldmeri Dominion
    Skill_Drain_Energy = GetString(LUIE_STRING_SKILL_DRAIN_ENERGY),
    Skill_Blessing = zo_strformat("<<C:1>>", GetAbilityName(33029)),
    Skill_Beckon_Gathwen = GetString(LUIE_STRING_SKILL_BECKON_GATHWEN),
    Skill_Summon = zo_strformat("<<C:1>>", GetAbilityName(29585)),
    Skill_Ancestral_Spirit = zo_strformat("<<C:1>>", GetAbilityName(48921)),
    Skill_Drinking = zo_strformat("<<C:1>>", GetAbilityName(23527)),
    Skill_Disruption = zo_strformat("<<C:1>>", GetAbilityName(31321)),
    Skill_Voice_to_Wake_the_Dead = zo_strformat("<<C:1>>", GetAbilityName(5030)),
    Skill_Barrier_Rebuke = GetString(LUIE_STRING_SKILL_BARRIER_REBUKE),
    Skill_Dispel = zo_strformat("<<C:1>>", GetAbilityName(8490)),
    Skill_Teleport_Scroll = GetString(LUIE_STRING_SKILL_TELEPORT_SCROLL),
    Skill_Purify = zo_strformat("<<C:1>>", GetAbilityName(22260)),
    Skill_Bind_Hands = GetString(LUIE_STRING_SKILL_BIND_HANDS),
    Skill_Bind_Bear = GetString(LUIE_STRING_SKILL_BIND_BEAR),
    Skill_Aetherial_Shift = GetString(LUIE_STRING_SKILL_AETHERIAL_SHIFT),
    Skill_Free_Spirit = GetString(LUIE_STRING_SKILL_FREE_SPIRIT),
    Skill_Unbind = GetString(LUIE_STRING_SKILL_UNBIND),
    Skill_Crystal = zo_strformat("<<C:1>>", GetAbilityName(67121)),
    Skill_Backfire = GetString(LUIE_STRING_SKILL_BACKFIRE),
    Skill_Close_Portal = zo_strformat("<<C:1>>", GetAbilityName(23370)),
    Skill_Lightning_Strike = zo_strformat("<<C:1>>", GetAbilityName(27596)),
    Skill_Push = zo_strformat("<<C:1>>", GetAbilityName(8692)),
    Skill_Absorb = zo_strformat("<<C:1>>", GetAbilityName(30869)),
    Skill_Mantles_Shadow = GetString(LUIE_STRING_SKILL_MANTLES_SHADOW),
    Skill_Quaking_Stomp = zo_strformat("<<C:1>>", GetAbilityName(43820)),
    Skill_Projectile_Vomit = zo_strformat("<<C:1>>", GetAbilityName(43827)),
    Skill_Call_for_Help = zo_strformat("<<C:1>>", GetAbilityName(53430)),
    Skill_Throw_Water = GetString(LUIE_STRING_SKILL_THROW_WATER),
    Skill_Snake_Scales = zo_strformat("<<C:1>>", GetAbilityName(36713)),
    Skill_Wolfs_Pelt = zo_strformat("<<C:1>>", GetAbilityName(36843)),
    Skill_Tigers_Fur = zo_strformat("<<C:1>>", GetAbilityName(36828)),
    Skill_Feedback = zo_strformat("<<C:1>>", GetAbilityName(32063)),
    Skill_Soul_Binding = zo_strformat("<<C:1>>", GetAbilityName(21171)),
    Skill_Empower_Heart = GetString(LUIE_STRING_SKILL_EMPOWER_TWILIT_HEART),
    Skill_Restricting_Vines = GetString(LUIE_STRING_SKILL_RESTRICTING_VINES),
    Skill_Change_Clothes = GetString(LUIE_STRING_SKILL_CHANGE_CLOTHES),
    Skill_Fancy_Clothing = GetString(LUIE_STRING_SKILL_FANCY_CLOTHING),
    Skill_Flames = zo_strformat("<<C:1>>", GetAbilityName(64704)),
    Skill_Burrow = zo_strformat("<<C:1>>", GetAbilityName(8974)),
    Skill_Emerge = zo_strformat("<<C:1>>", GetAbilityName(20746)),
    Skill_Serpent_Spit = GetString(LUIE_STRING_SKILL_SERPENT_SPIT),
    Skill_Shadow_Wood = GetString(LUIE_STRING_SKILL_SHADOW_WOOD),
    Skill_Disperse_Corruption = GetString(LUIE_STRING_SKILL_DISPERSE_CORRUPTION),
    Skill_Undead_Legion = zo_strformat("<<C:1>>", GetAbilityName(35809)),
    Skill_Call_Corrupt_Lurchers = GetString(LUIE_STRING_SKILL_CALL_CORRUPT_LURCHERS),

    -- Daggerfall Covenant
    Skill_Neramos_Control_Rod = GetQuestItemName(3703),
    Skill_Vision_of_the_Past = zo_strformat("<<C:1>>", GetAbilityName(36834)),

    -- Summerset Quests
    Skill_Pustulant_Eruption = zo_strformat("<<C:1>>", GetAbilityName(105867)),

    -- Elsweyr Quests
    Skill_Flame_Aura = zo_strformat("<<C:1>>", GetAbilityName(124352)),
    Skill_Star_Haven_Dragonhorn = GetString(LUIE_STRING_SKILL_STAR_HAVEN_DRAGONHORN),
    Skill_Steadfast_Ward = zo_strformat("<<C:1>>", GetAbilityName(37232)),
    Skill_Wing_Thrash = zo_strformat("<<C:1>>", GetAbilityName(125242)),

    -- Greymoor Quests
    Skill_Piercing_Dagger = GetString(LUIE_STRING_SKILL_PIERCING_DAGGER),
    Skill_Frostbolt = zo_strformat("<<C:1>>", GetAbilityName(119222)),
    Skill_Freezing_Vines = GetString(LUIE_STRING_SKILL_FREEZING_VINES),
    Skill_Freezing_Vineburst = GetString(LUIE_STRING_SKILL_FREEZING_VINEBURST),

    -- ---------------------------------------------------
    -- ARENA EFFECTS -----------------------------------
    -- ---------------------------------------------------

    -- Dragonstar Area
    Skill_Dawnbreaker = zo_strformat("<<C:1>>", GetAbilityName(35713)),
    Skill_Flame_Volley = zo_strformat("<<C:1>>", GetAbilityName(53314)),
    Skill_Daedric_Curse = zo_strformat("<<C:1>>", GetAbilityName(24326)),
    Skill_Poison_Cloud = zo_strformat("<<C:1>>", GetAbilityName(21411)),
    Skill_Flurry = zo_strformat("<<C:1>>", GetAbilityName(28607)),
    Skill_Mages_Wrath = zo_strformat("<<C:1>>", GetAbilityName(19123)),
    Skill_Caustic_Armor = GetString(LUIE_STRING_SKILL_CAUSTIC_ARMOR),
    Skill_Enslavement = zo_strformat("<<C:1>>", GetAbilityName(83774)),
    Skill_Cinder_Storm = zo_strformat("<<C:1>>", GetAbilityName(20779)),
    Skill_Petrify = zo_strformat("<<C:1>>", GetAbilityName(29037)),
    Skill_Fossilize = zo_strformat("<<C:1>>", GetAbilityName(32685)),
    Skill_Shattering_Rocks = zo_strformat("<<C:1>>", GetAbilityName(32678)),
    Skill_Celestial_Ward = zo_strformat("<<C:1>>", GetAbilityName(54315)),
    Skill_Draining_Poison = zo_strformat("<<C:1>>", GetAbilityName(60442)),
    Skill_Natures_Blessing = GetString(LUIE_STRING_SKILL_NATURES_BLESSING),
    Skill_Reflective_Scale = GetString(LUIE_STRING_SKILL_REFLECTIVE_SCALE),
    Skill_Summon_Scamp = zo_strformat("<<C:1>>", GetAbilityName(39555)),
    Skill_Summon_Harvester = zo_strformat("<<C:1>>", GetAbilityName(58054)),
    Skill_Summon_Daedric_Titan = GetString(LUIE_STRING_SKILL_SUMMON_DAEDRIC_TITAN),
    Skill_Suppression_Field = zo_strformat("<<C:1>>", GetAbilityName(28341)),
    Skill_Sucked_Under = zo_strformat("<<C:1>>", GetAbilityName(55221)),
    Skill_Spirit_Shield = zo_strformat("<<C:1>>", GetAbilityName(56985)),
    Skill_Blazing_Fire = zo_strformat("<<C:1>>", GetAbilityName(34959)),
    Skill_Empowered_by_the_Light = GetString(LUIE_STRING_SKILL_EMPOWERED_BY_THE_LIGHT),
    Skill_Warmth = zo_strformat("<<C:1>>", GetAbilityName(29430)),
    Skill_Arena_Torch = GetString(LUIE_STRING_SKILL_ARENA_TORCH),
    Skill_Biting_Cold = zo_strformat("<<C:1>>", GetAbilityName(53341)),
    Skill_Circle_of_Protection_NPC = zo_strformat("<<C:1>>", GetAbilityName(35737)),

    -- Maelstrom Arena
    Skill_Sigil_of_Healing = zo_strformat("<<C:1>>", GetAbilityName(66920)),
    Skill_Defiled_Grave = zo_strformat("<<C:1>>", GetAbilityName(70893)),
    Skill_Overload = zo_strformat("<<C:1>>", GetAbilityName(72690)),
    Skill_Energize = GetString(LUIE_STRING_SKILL_ENERGIZE),
    Skill_Defensive_Protocol = GetString(LUIE_STRING_SKILL_DEFENSIVE_PROTOCOL),

    Skill_Electrified_Water = zo_strformat("<<C:1>>", GetAbilityName(69913)),
    Skill_Call_Lightning = zo_strformat("<<C:1>>", GetAbilityName(73881)),
    Skill_Spit = zo_strformat("<<C:1>>", GetAbilityName(76094)),
    Skill_Venting_Flames = GetString(LUIE_STRING_SKILL_VENTING_FLAMES),
    Skill_Voltaic_Overload = zo_strformat("<<C:1>>", GetAbilityName(109059)),
    Skill_Cold_Snap = zo_strformat("<<C:1>>", GetAbilityName(72705)),
    Skill_Summon_Deathless_Wolf = GetString(LUIE_STRING_SKILL_SUMMON_DEATHLESS_WOLF),
    Skill_Iceberg_Calving = zo_strformat("<<C:1>>", GetAbilityName(71702)),
    Skill_Frigid_Waters = zo_strformat("<<C:1>>", GetAbilityName(67805)),

    -- ---------------------------------------------------
    -- DUNGEON EFFECTS -----------------------------------
    -- ---------------------------------------------------

    -- Banished Cells I
    Skill_Tail_Smite = zo_strformat("<<C:1>>", GetAbilityName(47587)),
    Skill_Shadow_Proxy = zo_strformat("<<C:1>>", GetAbilityName(114655)),
    Skill_Overpower = zo_strformat("<<C:1>>", GetAbilityName(52997)),

    -- Banished Cells II
    Skill_Pool_of_Fire = GetString(LUIE_STRING_SKILL_POOL_OF_FIRE),
    Skill_Sisters_Bond = GetString(LUIE_STRING_SKILL_SISTERS_BOND),
    Skill_Levitate = zo_strformat("<<C:1>>", GetAbilityName(28570)),
    Skill_Essence_Siphon = zo_strformat("<<C:1>>", GetAbilityName(28750)),
    Skill_Daedric_Chaos = GetString(LUIE_STRING_SKILL_DAEDRIC_CHAOS),
    Skill_Chaotic_Dispersion = GetString(LUIE_STRING_SKILL_CHAOTIC_DISPERSION),
    Skill_Chaotic_Return = GetString(LUIE_STRING_SKILL_CHAOTIC_RETURN),
    Skill_Summon_Daedroth = zo_strformat("<<C:1>>", GetAbilityName(69356)),
    Skill_Resilience = GetString(LUIE_STRING_SKILL_RESILIENCE),

    -- Elden Hollow I
    Skill_Executioners_Strike = zo_strformat("<<C:1>>", GetAbilityName(16834)),
    Skill_Whirling_Axe = GetString(LUIE_STRING_SKILL_WHIRLING_AXE),
    Skill_Crushing_Blow = zo_strformat("<<C:1>>", GetAbilityName(33189)), -- TODO: Move to the first instance of this rename being necessary
    Skill_Measured_Uppercut = zo_strformat("<<C:1>>", GetAbilityName(34607)),
    Skill_Heal_Spores = GetString(LUIE_STRING_SKILL_HEAL_SPORES),
    Skill_Summon_Saplings = GetString(LUIE_STRING_SKILL_SUMMON_STRANGLER_SAPLINGS),
    Skill_Reanimate_Skeletons = GetString(LUIE_STRING_SKILL_REANIMATE_SKELETONS),

    -- Elden Hollow II
    Skill_Fortified_Ground = zo_strformat("<<C:1>>", GetAbilityName(32648)),
    Skill_Empowered_Ground = zo_strformat("<<C:1>>", GetAbilityName(32647)),
    Skill_Siphon_Magicka = GetString(LUIE_STRING_SKILL_SIPHON_MAGICKA),
    Skill_Siphon_Stamina = GetString(LUIE_STRING_SKILL_SIPHON_STAMINA),
    Skill_Shadow_Tendril = GetString(LUIE_STRING_SKILL_SHADOW_TENDRIL),
    Skill_Nova_Tendril = GetString(LUIE_STRING_SKILL_NOVA_TENDRIL),

    -- City of Ash I
    Skill_Steel_Cyclone = zo_strformat("<<C:1>>", GetAbilityName(5843)),
    Skill_Fan_of_Flames = zo_strformat("<<C:1>>", GetAbilityName(34654)),
    Skill_Thorny_Backhand = zo_strformat("<<C:1>>", GetAbilityName(34190)),
    Skill_Fiery_Deception = zo_strformat("<<C:1>>", GetAbilityName(52224)),
    Skill_Blazing_Arrow = zo_strformat("<<C:1>>", GetAbilityName(34901)),
    Skill_Blazing_Embers = zo_strformat("<<C:1>>", GetAbilityName(34953)),
    Skill_Summon_Flame_Atronach = zo_strformat("<<C:1>>", GetAbilityName(34623)),
    Skill_Summon_Flame_Atronachs = GetString(LUIE_STRING_SKILL_SUMMON_FLAME_ATRONACHS),
    Skill_Oblivion_Gate = GetString(LUIE_STRING_SKILL_OBLIVION_GATE),

    -- City of Ash II
    Skill_Trail_of_Flames = GetString(LUIE_STRING_SKILL_TRAIL_OF_FLAMES),
    Skill_Pyroclasm = zo_strformat("<<C:1>>", GetAbilityName(92269)),
    Skill_Fire_Rune = zo_strformat("<<C:1>>", GetAbilityName(47102)),
    Skill_Seismic_Tremor = zo_strformat("<<C:1>>", GetAbilityName(55203)),
    Skill_Enraged_Fortitude = GetString(LUIE_STRING_SKILL_ENRAGED_FORTITUDE),
    Skill_Wing_Gust = zo_strformat("<<C:1>>", GetAbilityName(26554)),
    Skill_Flame_Tsunami = GetString(LUIE_STRING_SKILL_FLAME_TSUNAMI),
    Skill_Ignore_Pain = GetString(LUIE_STRING_SKILL_IGNORE_PAIN),
    Skill_Flame_Bolt = zo_strformat("<<C:1>>", GetAbilityName(55513)),
    Skill_Call_the_Flames = zo_strformat("<<C:1>>", GetAbilityName(55514)),
    Skill_Slag_Geyser = zo_strformat("<<C:1>>", GetAbilityName(56068)),
    Skill_Platform_Detonation = zo_strformat("<<C:1>>", GetAbilityName(56548)),
    Skill_Volcanic_Shield = GetString(LUIE_STRING_SKILL_VOLCANIC_SHIELD),
    Skill_Meteoric_Strike = GetString(LUIE_STRING_SKILL_METEORIC_STRIKE),
    Skill_Flame_Barrier = GetString(LUIE_STRING_SKILL_FLAME_BARRIER),
    Skill_Call_Storm_Atronach = GetString(LUIE_STRING_SKILL_CALL_STORM_ATRONACH),
    Skill_Call_Storm_Atronachs = GetString(LUIE_STRING_SKILL_CALL_STORM_ATRONACHS),

    -- Tempest Island
    Skill_Sonic_Scream = zo_strformat("<<C:1>>", GetAbilityName(46732)),
    Skill_Sudden_Storm = GetString(LUIE_STRING_SKILL_SUDDEN_STORM),
    Skill_Shadowstep = zo_strformat("<<C:1>>", GetAbilityName(18190)),
    Skill_Poisoned_Blade = zo_strformat("<<C:1>>", GetAbilityName(29063)),
    Skill_Stormfist = zo_strformat("<<C:1>>", GetAbilityName(80520)),
    Skill_Wind_Charge = zo_strformat("<<C:1>>", GetAbilityName(26746)),
    Skill_Twister = zo_strformat("<<C:1>>", GetAbilityName(26514)),
    Skill_Heavy_Slash = zo_strformat("<<C:1>>", GetAbilityName(51993)),
    Skill_Precision_Strike = GetString(LUIE_STRING_SKILL_PRECISION_STRIKE),

    -- Selene's Web
    Skill_Primal_Swarm = GetString(LUIE_STRING_SKILL_PRIMAL_SWARM),
    Skill_Volley = zo_strformat("<<C:1>>", GetAbilityName(28876)),
    Skill_Senche_Spirit = GetString(LUIE_STRING_SKILL_SENCHE_SPIRIT),
    Skill_Lash = zo_strformat("<<C:1>>", GetAbilityName(5240)),
    Skill_Vicious_Maul = zo_strformat("<<C:1>>", GetAbilityName(30996)),
    Skill_Trampling_Charge = zo_strformat("<<C:1>>", GetAbilityName(30987)),
    Skill_Selenes_Rose = GetString(LUIE_STRING_SKILL_SELENES_ROSE),
    Skill_Free_Ally = zo_strformat("<<C:1>>", GetAbilityName(31180)),
    Skill_Primal_Maul = GetString(LUIE_STRING_SKILL_PRIMAL_MAUL),
    Skill_Primal_Leap = zo_strformat("<<C:1>>", GetAbilityName(30901)),
    Skill_Root_Guard = GetString(LUIE_STRING_SKILL_ROOT_GUARD),
    Skill_Earth_Mender = GetString(LUIE_STRING_SKILL_EARTH_MENDER),
    Skill_True_Shot = GetString(LUIE_STRING_SKILL_TRUE_SHOT),

    -- Spindleclutch I
    Skill_Summon_Swarm = zo_strformat("<<C:1>>", GetAbilityName(51408)),
    Skill_Arachnid_Leap = zo_strformat("<<C:1>>", GetAbilityName(17960)),
    Skill_Spawn_Hatchlings = GetString(LUIE_STRING_SKILL_SPAWN_HATCHLINGS),
    Skill_Web_Blast = zo_strformat("<<C:1>>", GetAbilityName(18078)),
    Skill_Grappling_Web = zo_strformat("<<C:1>>", GetAbilityName(35572)),
    Skill_Daedric_Explosion = zo_strformat("<<C:1>>", GetAbilityName(18058)),

    -- Spindleclutch II
    Skill_Vicious_Smash = zo_strformat("<<C:1>>", GetAbilityName(28093)),
    Skill_Quake = zo_strformat("<<C:1>>", GetAbilityName(10270)),
    Skill_Cave_In = zo_strformat("<<C:1>>", GetAbilityName(27995)),
    Skill_Praxins_Nightmare = zo_strformat("<<C:1>>", GetAbilityName(47122)),
    Skill_Harrowing_Ring = zo_strformat("<<C:1>>", GetAbilityName(27703)),
    Skill_Wracking_Pain = GetString(LUIE_STRING_SKILL_WRACKING_PAIN),

    -- Wayrest Sewers I
    Skill_Dark_Lance = zo_strformat("<<C:1>>", GetAbilityName(9441)),
    Skill_Summon_Restless_Souls = zo_strformat("<<C:1>>", GetAbilityName(9463)),
    Skill_Hallucinogenic_Fumes = zo_strformat("<<C:1>>", GetAbilityName(35006)),

    -- Wayrest Sewers II
    Skill_Scourging_Spark = zo_strformat("<<C:1>>", GetAbilityName(36613)),
    Skill_Necromantic_Implosion = zo_strformat("<<C:1>>", GetAbilityName(17207)),
    Skill_Escaped_Souls = GetString(LUIE_STRING_SKILL_ESCAPED_SOULS),
    Skill_Overhead_Smash = zo_strformat("<<C:1>>", GetAbilityName(20915)),

    -- Crypt of Hearts I
    Skill_Trample = zo_strformat("<<C:1>>", GetAbilityName(46947)),
    Skill_Immolate = zo_strformat("<<C:1>>", GetAbilityName(46679)),
    Skill_Electric_Prison = zo_strformat("<<C:1>>", GetAbilityName(22432)),
    Skill_Overwhelming_Blow = GetString(LUIE_STRING_SKILL_OVERWHELMING_BLOW),

    -- Crypt of Hearts II
    Skill_Summon_Spiderkith = GetString(LUIE_STRING_SKILL_SUMMON_SPIDERKITH),
    Skill_Summon_Death_Spider = GetString(LUIE_STRING_SKILL_SUMMON_DEATH_SPIDER),
    Skill_Summon_Atronach = zo_strformat("<<C:1>>", GetAbilityName(52040)),
    Skill_Chattering_Web = zo_strformat("<<C:1>>", GetAbilityName(51381)),
    Skill_Spider_Swarm = zo_strformat("<<C:1>>", GetAbilityName(51410)),
    Skill_Shock_Stomp = zo_strformat("<<C:1>>", GetAbilityName(53599)),
    Skill_Fire_Stomp = zo_strformat("<<C:1>>", GetAbilityName(61611)),
    Skill_Shock_Form = zo_strformat("<<C:1>>", GetAbilityName(52167)),
    Skill_Fire_Form = zo_strformat("<<C:1>>", GetAbilityName(52166)),
    Skill_Split_Flare = GetString(LUIE_STRING_SKILL_SPLIT_FLARE),
    Skill_Void_Grip = GetString(LUIE_STRING_SKILL_VOID_GRIP),
    Skill_Fulminating_Void = zo_strformat("<<C:1>>", GetAbilityName(51799)),
    Skill_Skull_Volley = GetString(LUIE_STRING_SKILL_SKULL_VOLLEY),
    Skill_Daedric_Step = zo_strformat("<<C:1>>", GetAbilityName(46581)),
    Skill_Soul_Pulse = zo_strformat("<<C:1>>", GetAbilityName(51853)),
    Skill_Cold_Strike = zo_strformat("<<C:1>>", GetAbilityName(53123)),
    Skill_Chilling_Bolt = GetString(LUIE_STRING_SKILL_CHILLING_BOLT),
    Skill_Soul_Sacrifice = zo_strformat("<<C:1>>", GetAbilityName(51969)),
    Skill_Draw_the_Ebony_Blade = GetString(LUIE_STRING_SKILL_DRAW_THE_EBONY_BLADE),
    Skill_Ebony_Shield = GetString(LUIE_STRING_SKILL_EBONY_SHIELD),
    Skill_Resist_Necrosis = zo_strformat("<<C:1>>", GetAbilityName(53185)),
    Skill_Lethal_Stab = zo_strformat("<<C:1>>", GetAbilityName(51988)),

    -- Volenfell
    Skill_Mighty_Swing = GetString(LUIE_STRING_SKILL_MIGHTY_SWING),
    Skill_Flame_Wraith = GetString(LUIE_STRING_SKILL_FLAME_WRAITH),
    Skill_Burning_Ground = zo_strformat("<<C:1>>", GetAbilityName(25143)),
    Skill_Gargoyle_Leap = GetString(LUIE_STRING_SKILL_GARGOYLE_LEAP),
    Skill_Explosive_Bolt = zo_strformat("<<C:1>>", GetAbilityName(25655)),
    Skill_Tail_Swipe = zo_strformat("<<C:1>>", GetAbilityName(24777)),
    Skill_Rupture = zo_strformat("<<C:1>>", GetAbilityName(29164)),

    -- Frostvault
    Skill_Rending_Bleed = zo_strformat("<<C:1>>", GetAbilityName(117286)),
    Skill_Leaping_Crush = zo_strformat("<<C:1>>", GetAbilityName(109801)),
    Skill_Lifting_Strike = zo_strformat("<<C:1>>", GetAbilityName(109834)),
    Skill_Frenzied_Pummeling = zo_strformat("<<C:1>>", GetAbilityName(118489)),
    Skill_Frozen_Aura = zo_strformat("<<C:1>>", GetAbilityName(109806)),

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

-- Export string data to global namespace
--- @class (partial) AbilityTables
--- Converted to strings with a __index metamethod.
Data.Abilities = abilityTables
