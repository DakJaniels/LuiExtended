-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Data for icon & description to show for the fake Disguise buff applied to the player.
--------------------------------------------------------------------------------------------------------------------------------

--- Required:
--- icon = '' -- Icon to use
--- description = '' -- String to use for description when equipped (used by Chat Announcements)
--- id = # -- Ability id to pull a tooltip description from
--- @class (exact) DisguiseIcons : table
--- @field icon string Icon to use
--- @field description string String to use for description when equipped (used by Chat Announcements)
--- @field id integer|nil Ability id to pull a tooltip description from


--- @alias EffectsDisguiseIcons DisguiseIcons[]
local DisguiseIcons =
{
    [0] = { icon = "LuiExtended/media/icons/disguises/disguise_generic.dds", description = "by the Earring of Disguise.", id = nil }, -- Generic Disguise override - at least the Arenthia quest in Reaper's March applies a disguise without utilizing an item
    [2571] = { icon = "LuiExtended/media/icons/disguises/disguise_midnight_union_disguise.dds", description = "as a Midnight Union thief.", id = 35607 },
    [27266] = { icon = "LuiExtended/media/icons/disguises/disguise_vanguard_uniform.dds", description = "as a soldier in Tanval's Vanguard.", id = 50177 },
    [29536] = { icon = "LuiExtended/media/icons/disguises/disguise_stormfist_disguise.dds", description = "as a Stormfist soldier.", id = 19086 },
    [40283] = { icon = "LuiExtended/media/icons/disguises/disguise_keepers_garb.dds", description = "as a Keeper of the Shell.", id = 31118 },
    [40286] = { icon = "LuiExtended/media/icons/disguises/disguise_seadrake_disguise.dds", description = "as a Seadrake pirate.", id = 27457 },
    [40294] = { icon = "LuiExtended/media/icons/disguises/disguise_pirate_disguise.dds", description = "as a Blackheart Haven pirate.", id = 29986 },
    [40296] = { icon = "LuiExtended/media/icons/disguises/disguise_red_rook_disguise.dds", description = "as a Red Rook bandit.", id = 28076 },
    [42413] = { icon = "LuiExtended/media/icons/disguises/disguise_colovian_uniform.dds", description = "as a Colovian soldier.", id = 31766 },
    [42736] = { icon = "LuiExtended/media/icons/disguises/disguise_servants_robes.dds", description = "as a servant of Headman Bhosek.", id = 32045 },
    [43046] = { icon = "LuiExtended/media/icons/disguises/disguise_forebear_dishdasha.dds", description = "as a member of the Forebears.", id = 33220 },
    [43047] = { icon = "LuiExtended/media/icons/disguises/disguise_crown_dishdasha.dds", description = "as a member of the Crowns.", id = 33221 },
    [43508] = { icon = "LuiExtended/media/icons/disguises/disguise_generic.dds", description = "in a Seaside Sanctuary disguise.", id = nil }, -- NO ICON (Probably doesn't exist)
    [43511] = { icon = "LuiExtended/media/icons/disguises/disguise_sea_viper_armor.dds", description = "as a Maormer soldier.", id = 33534 },  -- NO ICON
    [43515] = { icon = "LuiExtended/media/icons/disguises/disguise_imperial_disguise.dds", description = "as an Imperial soldier.", id = 34267 },
    [44448] = { icon = "LuiExtended/media/icons/disguises/disguise_frostedge_bandit_disguise.dds", description = "as a Frostedge bandit.", id = 38167 },
    [44580] = { icon = "LuiExtended/media/icons/disguises/disguise_hollow_moon_garb.dds", description = "as a member of the Hollow Moon.", id = nil },
    [44587] = { icon = "LuiExtended/media/icons/disguises/disguise_northwind_disguise.dds", description = "as a Stonetalon clan member.", id = 38878 },
    [44697] = { icon = "LuiExtended/media/icons/disguises/disguise_hallins_stand_seventh_legion_disguise.dds", description = "as a member of the Seventh Legion.", id = 39295 },
    [45006] = { icon = "LuiExtended/media/icons/disguises/disguise_phaer_mercenary_disguise.dds", description = "as a Phaer Mercenary.", id = 43716 },
    [45007] = { icon = "LuiExtended/media/icons/disguises/disguise_quendeluun_veiled_heritance_disguise.dds", description = "as a member of the invading Ebonheart Pact forces.", id = 43719 },
    [45008] = { icon = "LuiExtended/media/icons/disguises/disguise_vulkhel_guard_marine_disguise.dds", description = "as a First Auridon Marine.", id = 43722 },
    [45781] = { icon = "LuiExtended/media/icons/disguises/disguise_kollopi_essence.dds", description = "by the Kollopi Essence.", id = 30879 },
    [45803] = { icon = "LuiExtended/media/icons/disguises/disguise_bloodthorn_disguise.dds", description = "as a Bloodthorn Cultist.", id = 46281 },
    [54332] = { icon = "LuiExtended/media/icons/disguises/disguise_fort_amol_guard_disguise.dds", description = "as a Fort Amol guard.", id = 47574 },
    [54380] = { icon = "LuiExtended/media/icons/disguises/disguise_steel_shrike_uniform.dds", description = "as a member of the Steel Shrikes.", id = 19013 },
    [54483] = { icon = "LuiExtended/media/icons/disguises/disguise_courier_uniform.dds", description = "as a Gold Coast mercenary courier.", id = 48429 },
    [54994] = { icon = "LuiExtended/media/icons/disguises/disguise_shadowsilk_gem.dds", description = "as a Shadowsilk Goblin.", id = 51906 },
    [55014] = { icon = "LuiExtended/media/icons/disguises/disguise_generic.dds", description = "as a member of Wolfbane Watch.", id = nil },            -- (Not sure it exists)
    [55262] = { icon = "LuiExtended/media/icons/disguises/disguise_generic.dds", description = "by the Earring of Disguise.", id = nil },               -- Compatibility - for Arenthia quest is player is wearing a Guild Tabard
    [64260] = { icon = "LuiExtended/media/icons/disguises/disguise_generic.dds", description = "in colorful Dark Elf clothing.", id = 20175 },          -- NO ICON (Not sure it exists)
    [71090] = { icon = "LuiExtended/media/icons/disguises/disguise_servants_outfit.dds", description = "as a servant of the Iron Wheel.", id = 27649 }, -- TODO: Check this ID is right
    [71541] = { icon = "LuiExtended/media/icons/disguises/disguise_generic.dds", description = "as a Castle Kvatch sentinel.", id = nil },              -- NO ICON (Not sure it exists)
    [71789] = { icon = "LuiExtended/media/icons/disguises/disguise_generic.dds", description = "as a Castle Kvatch sentinel.", id = nil },              -- NO ICON (Not sure it exists)
    -- [79332] = { icon = "LuiExtended/media/icons/disguises/disguise_monks_disguise.dds", description = "as a monk." },                                   -- HAS AN AURA SO NOT NECESSARY (Note - we make an exception to HIDE this itemId to prevent errors)
    [79505] = { icon = "LuiExtended/media/icons/disguises/disguise_generic.dds", description = "as a Sentinel Guard.", id = nil },                      -- NO ICON (Not sure it exists)
    [94209] = { icon = "LuiExtended/media/icons/disguises/disguise_scarlet_judges_regalia.dds", description = "as The Scarlet Judge.", id = 85204 },
}

--- @type EffectsDisguiseIcons
Effects.DisguiseIcons = DisguiseIcons
