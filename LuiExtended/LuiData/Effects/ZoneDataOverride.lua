-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local ZoneNames = Data.ZoneNames
local Abilities = Data.Abilities

--------------------------------------------------------------------------------------------------------------------------------
-- When GetZoneId(GetCurrentMapZoneIndex()) matches this filter, customize the ability based off this criteria.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) ZoneDataOverride
local zoneDataOverride =
{

    -- TUTORIAL AREAS

    [11338] =
    { -- In Lava
        [968] =
        {
            name = Abilities.Skill_Flames,
            icon = "LuiExtended/media/icons/abilities/ability_trap_fire.dds",
            source = Abilities.Skill_Flames,
        }, -- Firemoth Island (Vvardenfell - Broken Bonds)
    },
    [121005] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_heavy.dds" }, -- Heavy Attack (Vitrus the Bloody)
    },

    [70355] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_bear_bite_black.dds" }, -- Bite (Great Bear)
    },
    [70357] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_bear_lunge_black.dds" }, -- Lunge (Great Bear)
    },
    [70359] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_bear_lunge_black.dds" }, -- Lunge (Great Bear)
    },
    [70366] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_bear_crushing_swipe_black.dds" }, -- Slam (Great Bear)
    },
    [89189] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_bear_crushing_swipe_black.dds" }, -- Slam (Great Bear)
    },
    [69073] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_bear_crushing_swipe_black.dds" }, -- Knockdown (Great Bear)
    },
    [70374] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_bear_ferocity_black.dds" }, -- Ferocity (Great Bear)
    },

    [80382] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_bite_white.dds" }, -- Bite (Dire Wolf)
    },
    [80383] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_bite_white.dds" }, -- Bite (Dire Wolf)
    },
    [76307] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_lunge_white.dds" }, -- Lunge (Dire Wolf)
    },
    [76308] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_lunge_white.dds" }, -- Lunge (Dire Wolf)
    },
    [76303] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_nip_white.dds" }, -- Nip (Dire Wolf)
    },
    [76304] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_nip_white.dds" }, -- Nip (Dire Wolf)
    },
    [76305] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_gnash_white.dds" }, -- Gnash (Dire Wolf)
    },
    [76306] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_gnash_white.dds" }, -- Gnash (Dire Wolf)
    },
    [76311] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_harry_white.dds" }, -- Harry (Dire Wolf)
    },
    [85656] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_harry_white.dds" }, -- Harry (Dire Wolf)
    },
    [76324] =
    {
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_direwolf_baleful_call_white.dds" }, -- Baleful Call (Dire Wolf)
    },

    -- ALDMERI DOMINION

    [77905] =
    {                                                                                               -- Knockback (Giant)
        -- QUESTS
        [1013] = { icon = "LuiExtended/media/icons/abilities/ability_yaghranightmare_impale.dds" }, -- Summerset (The Mind Trap) -- Yaghra Nightmare
        [381] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_hammer_2h_shock_aura.dds",
            name = Abilities.Skill_Shock_Blast,
        },                                                                                                            -- Auridon - Captain Blanchete
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_warden_gore.dds", name = Abilities.Skill_Gore }, -- Deepwood Vale (Greymoor)
    },
    [77906] =
    {                                                                                               -- Stun (Giant)
        -- QUESTS
        [1013] = { icon = "LuiExtended/media/icons/abilities/ability_yaghranightmare_impale.dds" }, -- Summerset (The Mind Trap) -- Yaghra Nightmare
        [381] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_hammer_2h_shock_aura.dds",
            name = Abilities.Skill_Shock_Blast,
        },                                                                                                            -- Auridon - Captain Blanchete
        [1160] = { icon = "LuiExtended/media/icons/abilities/ability_warden_gore.dds", name = Abilities.Skill_Gore }, -- Deepwood Vale (Greymoor)
    },

    -- DUNGEONS

    [10618] =
    {                                                                                            -- Quick Strike (Shared)
        -- DUNGEONS
        [931] = { icon = "LuiExtended/media/icons/abilities/ability_spell_sword_2h_light.dds" }, -- Elden Hollow II
    },

    [60920] =
    {                                                                                       -- Scrape (Giant Bat)
        [146] = { icon = "LuiExtended/media/icons/abilities/ability_bat_scrape_dark.dds" }, -- Wayrest Sewers
        [933] = { icon = "LuiExtended/media/icons/abilities/ability_bat_scrape_dark.dds" }, -- Wayrest Sewers II
    },
    [4632] =
    {                                                                                        -- Screech (Giant Bat)
        [146] = { icon = "LuiExtended/media/icons/abilities/ability_bat_screech_dark.dds" }, -- Wayrest Sewers
        [933] = { icon = "LuiExtended/media/icons/abilities/ability_bat_screech_dark.dds" }, -- Wayrest Sewers II
    },
    [47321] =
    {                                                                                        -- Screech (Giant Bat)
        [146] = { icon = "LuiExtended/media/icons/abilities/ability_bat_screech_dark.dds" }, -- Wayrest Sewers
        [933] = { icon = "LuiExtended/media/icons/abilities/ability_bat_screech_dark.dds" }, -- Wayrest Sewers II
    },
    [18319] =
    {                                                                                        -- Screech (Giant Bat)
        [146] = { icon = "LuiExtended/media/icons/abilities/ability_bat_screech_dark.dds" }, -- Wayrest Sewers
        [933] = { icon = "LuiExtended/media/icons/abilities/ability_bat_screech_dark.dds" }, -- Wayrest Sewers II
    },
    [4630] =
    {                                                                                              -- Draining Bite (Giant Bat)
        [146] = { icon = "LuiExtended/media/icons/abilities/ability_bat_draining_bite_dark.dds" }, -- Wayrest Sewers
        [933] = { icon = "LuiExtended/media/icons/abilities/ability_bat_draining_bite_dark.dds" }, -- Wayrest Sewers II
    },

    [21582] =
    {                                                                                                                                       -- Nature's Swarm (Spriggan)
        [ZoneNames.Zone_Hectahame] = { icon = "LuiExtended/media/icons/abilities/ability_spriggan_natures_swarm_red.dds", },                -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] = { icon = "LuiExtended/media/icons/abilities/ability_spriggan_natures_swarm_red.dds", },         -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] = { icon = "LuiExtended/media/icons/abilities/ability_spriggan_natures_swarm_red.dds", },      -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] = { icon = "LuiExtended/media/icons/abilities/ability_spriggan_natures_swarm_red.dds", }, -- Hectahame Ritual Chamber
    },
    [31699] =
    {                                                                                                                                       -- Nature's Swarm (Spriggan)
        [ZoneNames.Zone_Hectahame] = { icon = "LuiExtended/media/icons/abilities/ability_spriggan_natures_swarm_red.dds", },                -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] = { icon = "LuiExtended/media/icons/abilities/ability_spriggan_natures_swarm_red.dds", },         -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] = { icon = "LuiExtended/media/icons/abilities/ability_spriggan_natures_swarm_red.dds", },      -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] = { icon = "LuiExtended/media/icons/abilities/ability_spriggan_natures_swarm_red.dds", }, -- Hectahame Ritual Chamber
    },
    [13475] =
    { -- Healing Salve (Spriggan)
        [ZoneNames.Zone_Hectahame] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spriggan_healing_salve_red.dds",
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spriggan_healing_salve_red.dds",
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spriggan_healing_salve_red.dds",
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spriggan_healing_salve_red.dds",
        }, -- Hectahame Ritual Chamber
    },
    [13477] =
    { -- Control Beast (Spriggan)
        [ZoneNames.Zone_Hectahame] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spriggan_control_beast_red.dds",
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spriggan_control_beast_red.dds",
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spriggan_control_beast_red.dds",
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spriggan_control_beast_red.dds",
        }, -- Hectahame Ritual Chamber
    },

    [3757] =
    {                                                                                                                    -- Claw (Lurcher)
        [931] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_red.dds" },                             -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_red.dds" },        -- Hectahame
        [ZoneNames.Zone_Hectahame] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_red.dds" },        -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_red.dds" }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_red.dds",
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_red.dds",
        },                                                                                     -- Valenheart
        [559] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_red.dds" },   -- Hectahame Ritual Chamber
        [108] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_claw_green.dds" }, -- Greenshade
    },
    [3860] =
    {                                                                                                                  -- Pulverize (Lurcher)
        [931] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_pulverize_red.dds" },                      -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_pulverize_red.dds" }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_pulverize_red.dds",
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_pulverize_red.dds",
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_pulverize_red.dds",
        },                                                                                          -- Hectahame Ritual Chamber
        [559] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_pulverize_red.dds" },   -- Valenheart
        [108] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_pulverize_green.dds" }, -- Greenshade
    },
    [3855] =
    {                                                                                                  -- Crushing Limbs (Lurcher)
        [931] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds" }, -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds",
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds",
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds",
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds",
        },                                                                                               -- Hectahame Ritual Chamber
        [559] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds" },   -- Valenheart
        [108] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_green.dds" }, -- Greenshade
    },
    [38554] =
    {                                                                                                  -- Crushing Limbs (Lurcher)
        [931] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds" }, -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds",
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds",
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds",
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds",
        },                                                                                               -- Hectahame Ritual Chamber
        [559] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_red.dds" },   -- Valenheart
        [108] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_crushing_limbs_green.dds" }, -- Greenshade
    },
    [3767] =
    {                                                                                                  -- Choking Pollen (Lurcher)
        [931] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds" }, -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds",
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds",
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds",
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds",
        },                                                                                               -- Hectahame Ritual Chamber
        [559] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds" },   -- Valenheart
        [108] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_green.dds" }, -- Greenshade
    },
    [4769] =
    {                                                                                                  -- Choking Pollen (Lurcher)
        [931] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds" }, -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds",
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds",
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds",
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds",
        },                                                                                               -- Hectahame Ritual Chamber
        [559] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_red.dds" },   -- Valenheart
        [108] = { icon = "LuiExtended/media/icons/abilities/ability_lurcher_choking_pollen_green.dds" }, -- Greenshade
    },

    [9039] =
    {                                                                                                                  -- Snare (Selene's Rose)
        [31] = { icon = "LuiExtended/media/icons/abilities/ability_strangler_lash.dds", name = Abilities.Skill_Lash }, -- Selene's Web
        [933] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_scourging_spark_snare.dds",
            name = Abilities.Skill_Scourging_Spark,
        }, -- Wayrest Sewers II
    },
    [33097] =
    {                            -- Scary Immunities (Flesh Atronach)
        [936] = { hide = true }, -- Spindleclutch II
    },
    [48281] =
    {                                                                                           -- Slash (Keeper Voranil)
        [935] = { icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_light.dds" }, -- Banished Cells II
    },
    [27826] =
    { -- Crushing Blow (Yalorasse the Speaker)
        [58] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_sword_dw_crushing_blow.dds",
            name = Abilities.Skill_Precision_Strike,
        }, -- Tempest Island
        [935] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_slam.dds",
            name = Abilities.Skill_Crushing_Blow,
        }, -- Banished Cells II
    },
    [27827] =
    { -- Crushing Blow (Yalorasse the Speaker)
        [58] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_sword_dw_crushing_blow.dds",
            name = Abilities.Skill_Precision_Strike,
        }, -- Tempest Island
        [935] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_slam.dds",
            name = Abilities.Skill_Crushing_Blow,
        }, -- Banished Cells II
    },
    [27828] =
    { -- Crushing Blow  (Yalorasse the Speaker)
        [58] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_sword_dw_crushing_blow.dds",
            name = Abilities.Skill_Precision_Strike,
        }, -- Tempest Island
        [935] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_mace_2h_slam.dds",
            name = Abilities.Skill_Crushing_Blow,
        }, -- Banished Cells II
    },
    [25034] =
    { -- Crushing Blow (Golor the Banekin Handler)
        [22] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_mighty_swing.dds",
            name = Abilities.Skill_Mighty_Swing,
        }, -- Volenfell
    },
    [25035] =
    { -- Crushing Blow (Golor the Banekin Handler)
        [22] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_mighty_swing.dds",
            name = Abilities.Skill_Mighty_Swing,
        }, -- Volenfell
    },
    [25036] =
    { -- Crushing Blow (Golor the Banekin Handler)
        [22] =
        {
            icon = "LuiExtended/media/icons/abilities/ability_spell_axe_2h_mighty_swing.dds",
            name = Abilities.Skill_Mighty_Swing,
        }, -- Volenfell
    },

    -- QUESTS
    [1718] =
    {                                                                                            -- Attack (CH + Vvardenfell Tutorial)
        [809] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_light.dds" },   -- The Wailing Prison (MSQ - Tutorial) -- Dremora Churl
        [968] = { icon = "LuiExtended/media/icons/abilities/ability_attack_unarmed_light.dds" }, -- Firemoth Island (Vvardenfell - Broken Bonds) -- Naryu
    },
    [61748] =
    {                                                                                          -- Heavy Attack (CH Tutorial)
        [809] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_heavy.dds" }, -- The Wailing Prison (MSQ - Tutorial) -- Dreamora Kynval
    },
    [14096] =
    {                                                                                          -- Heavy Attack (Footsoldier)
        [809] = { icon = "LuiExtended/media/icons/abilities/ability_spell_axe_1h_heavy.dds" }, -- The Wailing Prison (MSQ - Tutorial) -- Dreamora Kynval
    },
}

--- @class (partial) ZoneDataOverride
Effects.ZoneDataOverride = zoneDataOverride
