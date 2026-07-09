-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

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
    [0] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_GENERIC_DDS, description = "by the Earring of Disguise.", id = nil }, -- Generic Disguise override - at least the Arenthia quest in Reaper's March applies a disguise without utilizing an item
    [2571] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_MIDNIGHT_UNION_DISGUISE_DDS, description = "as a Midnight Union thief.", id = 35607 },
    [27266] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_VANGUARD_UNIFORM_DDS, description = "as a soldier in Tanval's Vanguard.", id = 50177 },
    [29536] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_STORMFIST_DISGUISE_DDS, description = "as a Stormfist soldier.", id = 19086 },
    [40283] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_KEEPERS_GARB_DDS, description = "as a Keeper of the Shell.", id = 31118 },
    [40286] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_SEADRAKE_DISGUISE_DDS, description = "as a Seadrake pirate.", id = 27457 },
    [40294] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_PIRATE_DISGUISE_DDS, description = "as a Blackheart Haven pirate.", id = 29986 },
    [40296] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_RED_ROOK_DISGUISE_DDS, description = "as a Red Rook bandit.", id = 28076 },
    [42413] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_COLOVIAN_UNIFORM_DDS, description = "as a Colovian soldier.", id = 31766 },
    [42736] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_SERVANTS_ROBES_DDS, description = "as a servant of Headman Bhosek.", id = 32045 },
    [43046] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_FOREBEAR_DISHDASHA_DDS, description = "as a member of the Forebears.", id = 33220 },
    [43047] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_CROWN_DISHDASHA_DDS, description = "as a member of the Crowns.", id = 33221 },
    [43508] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_GENERIC_DDS, description = "in a Seaside Sanctuary disguise.", id = nil }, -- NO ICON (Probably doesn't exist)
    [43511] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_SEA_VIPER_ARMOR_DDS, description = "as a Maormer soldier.", id = 33534 },  -- NO ICON
    [43515] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_IMPERIAL_DISGUISE_DDS, description = "as an Imperial soldier.", id = 34267 },
    [44448] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_FROSTEDGE_BANDIT_DISGUISE_DDS, description = "as a Frostedge bandit.", id = 38167 },
    [44580] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_HOLLOW_MOON_GARB_DDS, description = "as a member of the Hollow Moon.", id = nil },
    [44587] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_NORTHWIND_DISGUISE_DDS, description = "as a Stonetalon clan member.", id = 38878 },
    [44697] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_HALLINS_STAND_SEVENTH_LEGION_DISGUISE_DDS, description = "as a member of the Seventh Legion.", id = 39295 },
    [45006] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_PHAER_MERCENARY_DISGUISE_DDS, description = "as a Phaer Mercenary.", id = 43716 },
    [45007] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_QUENDELUUN_VEILED_HERITANCE_DISGUISE_DDS, description = "as a member of the invading Ebonheart Pact forces.", id = 43719 },
    [45008] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_VULKHEL_GUARD_MARINE_DISGUISE_DDS, description = "as a First Auridon Marine.", id = 43722 },
    [45781] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_KOLLOPI_ESSENCE_DDS, description = "by the Kollopi Essence.", id = 30879 },
    [45803] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_BLOODTHORN_DISGUISE_DDS, description = "as a Bloodthorn Cultist.", id = 46281 },
    [223700] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_BLOODTHORN_DISGUISE_DDS, description = "as a Bloodthorn Cultist.", id = 46281 }, -- Bloodthorn Cultist Outfit (live aura 259286 is hidden)
    [54332] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_FORT_AMOL_GUARD_DISGUISE_DDS, description = "as a Fort Amol guard.", id = 47574 },
    [54380] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_STEEL_SHRIKE_UNIFORM_DDS, description = "as a member of the Steel Shrikes.", id = 19013 },
    [54483] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_COURIER_UNIFORM_DDS, description = "as a Gold Coast mercenary courier.", id = 48429 },
    [54994] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_SHADOWSILK_GEM_DDS, description = "as a Shadowsilk Goblin.", id = 51906 },
    [55014] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_GENERIC_DDS, description = "as a member of Wolfbane Watch.", id = nil },            -- (Not sure it exists)
    [55262] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_GENERIC_DDS, description = "by the Earring of Disguise.", id = nil },               -- Compatibility - for Arenthia quest is player is wearing a Guild Tabard
    [64260] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_GENERIC_DDS, description = "in colorful Dark Elf clothing.", id = 20175 },          -- NO ICON (Not sure it exists)
    [71090] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_SERVANTS_OUTFIT_DDS, description = "as a servant of the Iron Wheel.", id = 27649 }, -- TODO: Check this ID is right
    [71541] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_GENERIC_DDS, description = "as a Castle Kvatch sentinel.", id = nil },              -- NO ICON (Not sure it exists)
    [71789] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_GENERIC_DDS, description = "as a Castle Kvatch sentinel.", id = nil },              -- NO ICON (Not sure it exists)
    -- [79332] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_MONKS_DISGUISE_DDS, description = "as a monk." },                                   -- HAS AN AURA SO NOT NECESSARY (Note - we make an exception to HIDE this itemId to prevent errors)
    [79505] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_GENERIC_DDS, description = "as a Sentinel Guard.", id = nil },                      -- NO ICON (Not sure it exists)
    [94209] = { icon = LUIE_MEDIA_ICONS_DISGUISES_DISGUISE_SCARLET_JUDGES_REGALIA_DDS, description = "as The Scarlet Judge.", id = 85204 },
}

--- @type EffectsDisguiseIcons
Effects.DisguiseIcons = DisguiseIcons

--- Resolve icon/description/tooltip id for a worn costume itemId.
--- Falls back to the item's game icon when the id is missing from DisguiseIcons.
--- @param itemId integer
--- @return DisguiseIcons
function Effects.GetDisguiseDisplayData(itemId)
    local disguiseData = DisguiseIcons[itemId]
    if disguiseData then
        return disguiseData
    end

    if itemId ~= 0 then
        local itemLink = GetItemLink(BAG_WORN, EQUIP_SLOT_COSTUME, LINK_STYLE_DEFAULT)
        local icon = GetItemLinkIcon(itemLink)
        if icon and icon ~= "" then
            return
            {
                icon = icon,
                description = zo_strformat("as <<1>>.", GetItemName(BAG_WORN, EQUIP_SLOT_COSTUME)),
                id = nil,
            }
        end
    end

    return DisguiseIcons[0]
end
