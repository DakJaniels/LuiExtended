-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

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
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_TRAP_FIRE_DDS,
            source = Abilities.Skill_Flames,
        }, -- Firemoth Island (Vvardenfell - Broken Bonds)
    },
    [121005] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_HEAVY_DDS }, -- Heavy Attack (Vitrus the Bloody)
    },

    [70355] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_BITE_BLACK_DDS }, -- Bite (Great Bear)
    },
    [70357] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_LUNGE_BLACK_DDS }, -- Lunge (Great Bear)
    },
    [70359] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_LUNGE_BLACK_DDS }, -- Lunge (Great Bear)
    },
    [70366] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_CRUSHING_SWIPE_BLACK_DDS }, -- Slam (Great Bear)
    },
    [89189] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_CRUSHING_SWIPE_BLACK_DDS }, -- Slam (Great Bear)
    },
    [69073] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_CRUSHING_SWIPE_BLACK_DDS }, -- Knockdown (Great Bear)
    },
    [70374] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_FEROCITY_BLACK_DDS }, -- Ferocity (Great Bear)
    },

    [80382] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_BITE_WHITE_DDS }, -- Bite (Dire Wolf)
    },
    [80383] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_BITE_WHITE_DDS }, -- Bite (Dire Wolf)
    },
    [76307] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_LUNGE_WHITE_DDS }, -- Lunge (Dire Wolf)
    },
    [76308] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_LUNGE_WHITE_DDS }, -- Lunge (Dire Wolf)
    },
    [76303] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_NIP_WHITE_DDS }, -- Nip (Dire Wolf)
    },
    [76304] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_NIP_WHITE_DDS }, -- Nip (Dire Wolf)
    },
    [76305] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_GNASH_WHITE_DDS }, -- Gnash (Dire Wolf)
    },
    [76306] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_GNASH_WHITE_DDS }, -- Gnash (Dire Wolf)
    },
    [76311] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_HARRY_WHITE_DDS }, -- Harry (Dire Wolf)
    },
    [85656] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_HARRY_WHITE_DDS }, -- Harry (Dire Wolf)
    },
    [76324] =
    {
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DIREWOLF_BALEFUL_CALL_WHITE_DDS }, -- Baleful Call (Dire Wolf)
    },

    -- ALDMERI DOMINION

    [77905] =
    {                                                                                      -- Knockback (Giant)
        -- QUESTS
        [1013] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_YAGHRANIGHTMARE_IMPALE_DDS }, -- Summerset (The Mind Trap) -- Yaghra Nightmare
        [381] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HAMMER_2H_SHOCK_AURA_DDS,
            name = Abilities.Skill_Shock_Blast,
        },                                                                                                   -- Auridon - Captain Blanchete
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_WARDEN_GORE_DDS, name = Abilities.Skill_Gore }, -- Deepwood Vale (Greymoor)
    },
    [77906] =
    {                                                                                      -- Stun (Giant)
        -- QUESTS
        [1013] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_YAGHRANIGHTMARE_IMPALE_DDS }, -- Summerset (The Mind Trap) -- Yaghra Nightmare
        [381] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_HAMMER_2H_SHOCK_AURA_DDS,
            name = Abilities.Skill_Shock_Blast,
        },                                                                                                   -- Auridon - Captain Blanchete
        [1160] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_WARDEN_GORE_DDS, name = Abilities.Skill_Gore }, -- Deepwood Vale (Greymoor)
    },

    -- DUNGEONS

    [10618] =
    {                                                                                   -- Quick Strike (Shared)
        -- DUNGEONS
        [931] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_2H_LIGHT_DDS }, -- Elden Hollow II
    },

    [60920] =
    {                                                                              -- Scrape (Giant Bat)
        [146] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_SCRAPE_DARK_DDS }, -- Wayrest Sewers
        [933] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_SCRAPE_DARK_DDS }, -- Wayrest Sewers II
    },
    [4632] =
    {                                                                               -- Screech (Giant Bat)
        [146] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_SCREECH_DARK_DDS }, -- Wayrest Sewers
        [933] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_SCREECH_DARK_DDS }, -- Wayrest Sewers II
    },
    [47321] =
    {                                                                               -- Screech (Giant Bat)
        [146] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_SCREECH_DARK_DDS }, -- Wayrest Sewers
        [933] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_SCREECH_DARK_DDS }, -- Wayrest Sewers II
    },
    [18319] =
    {                                                                               -- Screech (Giant Bat)
        [146] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_SCREECH_DARK_DDS }, -- Wayrest Sewers
        [933] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_SCREECH_DARK_DDS }, -- Wayrest Sewers II
    },
    [4630] =
    {                                                                                     -- Draining Bite (Giant Bat)
        [146] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_DRAINING_BITE_DARK_DDS }, -- Wayrest Sewers
        [933] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BAT_DRAINING_BITE_DARK_DDS }, -- Wayrest Sewers II
    },

    [21582] =
    {                                                                                                                              -- Nature's Swarm (Spriggan)
        [ZoneNames.Zone_Hectahame] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_NATURES_SWARM_RED_DDS, },                -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_NATURES_SWARM_RED_DDS, },         -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_NATURES_SWARM_RED_DDS, },      -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_NATURES_SWARM_RED_DDS, }, -- Hectahame Ritual Chamber
    },
    [31699] =
    {                                                                                                                              -- Nature's Swarm (Spriggan)
        [ZoneNames.Zone_Hectahame] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_NATURES_SWARM_RED_DDS, },                -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_NATURES_SWARM_RED_DDS, },         -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_NATURES_SWARM_RED_DDS, },      -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_NATURES_SWARM_RED_DDS, }, -- Hectahame Ritual Chamber
    },
    [13475] =
    { -- Healing Salve (Spriggan)
        [ZoneNames.Zone_Hectahame] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_HEALING_SALVE_RED_DDS,
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_HEALING_SALVE_RED_DDS,
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_HEALING_SALVE_RED_DDS,
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_HEALING_SALVE_RED_DDS,
        }, -- Hectahame Ritual Chamber
    },
    [13477] =
    { -- Control Beast (Spriggan)
        [ZoneNames.Zone_Hectahame] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_CONTROL_BEAST_RED_DDS,
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_CONTROL_BEAST_RED_DDS,
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_CONTROL_BEAST_RED_DDS,
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPRIGGAN_CONTROL_BEAST_RED_DDS,
        }, -- Hectahame Ritual Chamber
    },

    [3757] =
    {                                                                                                           -- Claw (Lurcher)
        [931] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_RED_DDS },                             -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_RED_DDS },        -- Hectahame
        [ZoneNames.Zone_Hectahame] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_RED_DDS },        -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_RED_DDS }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_RED_DDS,
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_RED_DDS,
        },                                                                            -- Valenheart
        [559] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_RED_DDS },   -- Hectahame Ritual Chamber
        [108] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CLAW_GREEN_DDS }, -- Greenshade
    },
    [3860] =
    {                                                                                                         -- Pulverize (Lurcher)
        [931] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_PULVERIZE_RED_DDS },                      -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_PULVERIZE_RED_DDS }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_PULVERIZE_RED_DDS,
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_PULVERIZE_RED_DDS,
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_PULVERIZE_RED_DDS,
        },                                                                                 -- Hectahame Ritual Chamber
        [559] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_PULVERIZE_RED_DDS },   -- Valenheart
        [108] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_PULVERIZE_GREEN_DDS }, -- Greenshade
    },
    [3855] =
    {                                                                                         -- Crushing Limbs (Lurcher)
        [931] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS }, -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS,
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS,
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS,
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS,
        },                                                                                      -- Hectahame Ritual Chamber
        [559] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS },   -- Valenheart
        [108] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_GREEN_DDS }, -- Greenshade
    },
    [38554] =
    {                                                                                         -- Crushing Limbs (Lurcher)
        [931] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS }, -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS,
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS,
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS,
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS,
        },                                                                                      -- Hectahame Ritual Chamber
        [559] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_RED_DDS },   -- Valenheart
        [108] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CRUSHING_LIMBS_GREEN_DDS }, -- Greenshade
    },
    [3767] =
    {                                                                                         -- Choking Pollen (Lurcher)
        [931] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS }, -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS,
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS,
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS,
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS,
        },                                                                                      -- Hectahame Ritual Chamber
        [559] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS },   -- Valenheart
        [108] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_GREEN_DDS }, -- Greenshade
    },
    [4769] =
    {                                                                                         -- Choking Pollen (Lurcher)
        [931] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS }, -- Elden Hollow II
        [ZoneNames.Zone_Hectahame] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS,
        }, -- Hectahame
        [ZoneNames.Zone_Hectahame_Armory] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS,
        }, -- Hectahame Armory
        [ZoneNames.Zone_Hectahame_Arboretum] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS,
        }, -- Hectahame Arboretum
        [ZoneNames.Zone_Hectahame_Ritual_Chamber] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS,
        },                                                                                      -- Hectahame Ritual Chamber
        [559] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_RED_DDS },   -- Valenheart
        [108] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_LURCHER_CHOKING_POLLEN_GREEN_DDS }, -- Greenshade
    },

    [9039] =
    {                                                                                                         -- Snare (Selene's Rose)
        [31] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_STRANGLER_LASH_DDS, name = Abilities.Skill_Lash }, -- Selene's Web
        [933] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SCOURGING_SPARK_SNARE_DDS,
            name = Abilities.Skill_Scourging_Spark,
        }, -- Wayrest Sewers II
    },
    [33097] =
    {                            -- Scary Immunities (Flesh Atronach)
        [936] = { hide = true }, -- Spindleclutch II
    },
    [48281] =
    {                                                                                  -- Slash (Keeper Voranil)
        [935] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_LIGHT_DDS }, -- Banished Cells II
    },
    [27826] =
    { -- Crushing Blow (Yalorasse the Speaker)
        [58] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_DW_CRUSHING_BLOW_DDS,
            name = Abilities.Skill_Precision_Strike,
        }, -- Tempest Island
        [935] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_SLAM_DDS,
            name = Abilities.Skill_Crushing_Blow,
        }, -- Banished Cells II
    },
    [27827] =
    { -- Crushing Blow (Yalorasse the Speaker)
        [58] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_DW_CRUSHING_BLOW_DDS,
            name = Abilities.Skill_Precision_Strike,
        }, -- Tempest Island
        [935] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_SLAM_DDS,
            name = Abilities.Skill_Crushing_Blow,
        }, -- Banished Cells II
    },
    [27828] =
    { -- Crushing Blow  (Yalorasse the Speaker)
        [58] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_SWORD_DW_CRUSHING_BLOW_DDS,
            name = Abilities.Skill_Precision_Strike,
        }, -- Tempest Island
        [935] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_MACE_2H_SLAM_DDS,
            name = Abilities.Skill_Crushing_Blow,
        }, -- Banished Cells II
    },
    [25034] =
    { -- Crushing Blow (Golor the Banekin Handler)
        [22] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_MIGHTY_SWING_DDS,
            name = Abilities.Skill_Mighty_Swing,
        }, -- Volenfell
    },
    [25035] =
    { -- Crushing Blow (Golor the Banekin Handler)
        [22] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_MIGHTY_SWING_DDS,
            name = Abilities.Skill_Mighty_Swing,
        }, -- Volenfell
    },
    [25036] =
    { -- Crushing Blow (Golor the Banekin Handler)
        [22] =
        {
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_2H_MIGHTY_SWING_DDS,
            name = Abilities.Skill_Mighty_Swing,
        }, -- Volenfell
    },

    -- QUESTS
    [1718] =
    {                                                                                   -- Attack (CH + Vvardenfell Tutorial)
        [809] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_1H_LIGHT_DDS },   -- The Wailing Prison (MSQ - Tutorial) -- Dremora Churl
        [968] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_ATTACK_UNARMED_LIGHT_DDS }, -- Firemoth Island (Vvardenfell - Broken Bonds) -- Naryu
    },
    [61748] =
    {                                                                                 -- Heavy Attack (CH Tutorial)
        [809] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_1H_HEAVY_DDS }, -- The Wailing Prison (MSQ - Tutorial) -- Dreamora Kynval
    },
    [14096] =
    {                                                                                 -- Heavy Attack (Footsoldier)
        [809] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_SPELL_AXE_1H_HEAVY_DDS }, -- The Wailing Prison (MSQ - Tutorial) -- Dreamora Kynval
    },
}

--- @class (partial) ZoneDataOverride
Effects.ZoneDataOverride = zoneDataOverride
