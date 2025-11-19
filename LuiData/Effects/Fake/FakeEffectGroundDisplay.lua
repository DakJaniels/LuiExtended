-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local Tooltips = Data.Tooltips
local Abilities = Data.Abilities


--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR FAKE EFFECTS
--------------------------------------------------------------------------------------------------------------------------------
--- @class EffectGroundDisplayData
--- @field buff boolean -- Choose whether this effect shows up in any of these containers
--- @field debuff boolean -- Choose whether this effect shows up in any of these containers
--- @field ground boolean -- Choose whether this effect shows up in any of these containers
--- @field name? string -- Add a custom name
--- @field icon? string -- Add a custom icon
--- @field stackAdd? integer -- How many stacks to add when this effect begins (used for Ground Mines)
--- @field stackRemove? integer -- How many stacks to remove when this effect ends (used for Ground Mines)
--- @field stackReset? integer -- Maximum stack counter (used for Ground Mines)
--- @field noRemove? boolean -- Do not end this aura on EFFECT_RESULT_FADED
--------------------------------------------------------------------------------------------------------------------------------
-- Adds this aura to a list of fake Ground auras to display when the player casts them
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) EffectGroundDisplay
--- @field [integer] EffectGroundDisplayData
Effects.EffectGroundDisplay =
{
    -- Cyrodiil
    [88714] = { icon = "LuiExtended/media/icons/abilities/ability_ava_siege_meatbag_catapult.dds", name = Abilities.Skill_Meatbag_Catapult, buff = false, debuff = false, ground = true },          -- Meatbag (Meatbag Catapult)
    [104700] = { icon = "LuiExtended/media/icons/abilities/ability_spell_gtaoe_oil_snare.dds", name = Abilities.Skill_Oil_Catapult, buff = false, debuff = false, ground = true },                  -- Twisting Path (Oil Catapult)
    [104690] = { icon = "LuiExtended/media/icons/abilities/ability_ava_siege_scattershot_catapult.dds", name = Abilities.Skill_Scattershot_Catapult, buff = false, debuff = false, ground = true }, -- Twisting Path (Scattershot Catapult)

    -- Monster Sets
    [59590] = { icon = "LuiExtended/media/icons/abilities/ability_set_bogdan.dds", name = Abilities.Set_Bogdan_the_Nightflame, buff = true, debuff = false, ground = false },                                             -- Imperial Prison Item Set (Bogdan the Nightflame)
    [97882] = { icon = "LuiExtended/media/icons/abilities/ability_set_domihaus_fire.dds", buff = true, debuff = false, ground = true },                                                                                   -- Domihaus (Domihaus)
    [97855] = { icon = "LuiExtended/media/icons/abilities/ability_set_monster_earthgore.dds", buff = true, debuff = false, ground = false },                                                                              -- Earthgore (Earthgore)
    [80527] = { icon = "LuiExtended/media/icons/abilities/ability_set_ilambris.dds", buff = false, debuff = false, ground = true },                                                                                       -- Ilambris (Ilambris)
    [59587] = { icon = "LuiExtended/media/icons/abilities/ability_set_monster_lord_warden.dds", name = Abilities.Set_Lord_Warden_Dusk, buff = true, debuff = false, ground = false },                                     -- Lord Warden (Lord Warden)
    [59568] = { icon = "LuiExtended/media/icons/abilities/ability_set_monster_malubeth.dds", name = Abilities.Set_Scourge_Harvester, buff = true, debuff = false, ground = false, tooltip = Tooltips.Set_Malubeth_Heal }, -- Scourge Harvest (Malubeth)
    [59508] = { icon = "LuiExtended/media/icons/abilities/ability_set_maw_of_the_infernal.dds", name = Abilities.Set_Maw_of_the_Infernal, buff = true, debuff = false, ground = false },                                  -- Banished Cells Item Set (Maw of the Infernal)
    [81036] = { icon = "LuiExtended/media/icons/abilities/ability_dwarvenspider_heal.dds", buff = true, debuff = false, ground = false },                                                                                 -- Sentinel of Rkugamz
    [80954] = { icon = "LuiExtended/media/icons/abilities/ability_summon_shadow_proxy.dds", name = Abilities.Set_Shadowrend, buff = true, debuff = false, ground = false },                                               -- Shadowrend Summon (Shadowrend)
    [59497] = { icon = "LuiExtended/media/icons/abilities/ability_innate_web_white.dds", buff = false, debuff = false, ground = true },                                                                                   -- Spawn of Mephala (Spawn of Mephala)
    [80523] = { icon = "LuiExtended/media/icons/abilities/ability_stormatronach_enervating_stone.dds", buff = false, debuff = false, ground = true },                                                                     -- Stormfist (Stormfist)
    [102093] = { icon = "LuiExtended/media/icons/abilities/ability_set_monster_thurvokun.dds", buff = false, debuff = false, ground = true },                                                                             -- Thurvokun
    [59594] = { icon = "LuiExtended/media/icons/abilities/ability_spell_soul_rupture.dds", name = Abilities.Set_Nerieneth, buff = false, debuff = false, ground = true },                                                 -- Crypt of Hearts Item Set (Nerien'eth)
    [80545] = { icon = "LuiExtended/media/icons/abilities/ability_set_sellistrix.dds", buff = false, debuff = false, ground = true },                                                                                     -- Sellistrix (Sellistrix)
    -- [102136] = { icon = 'LuiExtended/media/icons/abilities/ability_set_monster_zaan.dds', buff = true, debuff = false, ground = false }, -- Zaan -- Buff icon for Zaan, may reimplement if I add a way to override tooltips for these.

    -- Crafted Sets
    [75930] = { icon = "LuiExtended/media/icons/abilities/ability_set_eternal_hunt.dds", name = Abilities.Set_Eternal_Hunt, buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 7 }, -- Daedric Mines (Eternal Hunt)
    [71671] = { icon = "LuiExtended/media/icons/abilities/ability_set_morkuldin_summon.dds", buff = true, debuff = false, ground = false },                                                                               -- Morkuldin (Morkuldin)
    [113181] = { icon = "/esoui/art/icons/mm_teaser.dds", buff = true, debuff = false, ground = false },                                                                                                                  -- Grave-Stake Collector (Grave-Stake Collector)
    [121915] = { icon = "LuiExtended/media/icons/abilities/ability_set_honors_scorn.dds", name = Abilities.Set_Honors_Scorn, buff = false, debuff = false, ground = true },                                               -- Coldharbour's Favorite (Coldharbour's Favorite)
    [121912] = { icon = "LuiExtended/media/icons/abilities/ability_set_honors_love.dds", name = Abilities.Set_Honors_Love, buff = true, debuff = false, ground = false },                                                 -- Coldharbour's Favorite (Coldharbour's Favorite)

    -- Overland Sets
    [75691] = { icon = "LuiExtended/media/icons/abilities/ability_spell_gtaoe_necrotic_snare.dds", buff = false, debuff = false, ground = true },                                     -- Bahraha's Curse
    [71664] = { icon = "LuiExtended/media/icons/abilities/ability_set_trinimacs_valor.dds", buff = false, debuff = false, ground = true },                                            -- Trinimac's Valor
    [135659] = { icon = "LuiExtended/media/icons/abilities/ability_set_winters_respite.dds", buff = true, debuff = false, ground = false },                                           -- Winter's Respite (of Winter's Respite)
    -- Dungeon Sets
    [97538] = { icon = "LuiExtended/media/icons/abilities/ability_set_draugrs_rest.dds", buff = true, debuff = false, ground = false },                                               -- Draugr's Rest
    [102106] = { icon = "/esoui/art/icons/achievement_bossflavoreasy.dds", name = Abilities.Set_Plague_Slinger, buff = false, debuff = false, ground = true },                        -- Skeever Corpse
    [97908] = { icon = "LuiExtended/media/icons/abilities/ability_set_hagravens_garden.dds", buff = true, debuff = false, ground = false },                                           -- Hagraven's Garden (Hagraven's)
    [67205] = { icon = "LuiExtended/media/icons/abilities/ability_set_leeching_plate.dds", buff = false, debuff = false, ground = true },                                             -- Leeching Plate (of Leeching)
    [84354] = { icon = "LuiExtended/media/icons/abilities/ability_innate_web_green.dds", buff = false, debuff = false, ground = true },                                               -- Hand of Mephala (of Mephala's Hand)
    [126924] = { icon = "LuiExtended/media/icons/abilities/ability_set_hollowfang.dds", buff = true, debuff = false, ground = false },                                                -- Hollowfang Thirst (Hollowfang Thirst)
    [133493] = { icon = "LuiExtended/media/icons/abilities/ability_set_aegis_caller.dds", name = Abilities.Set_Aegis_Caller, buff = false, debuff = false, ground = true },           -- Aegis Caller (Aegis Caller's)
    -- Trial Sets
    [107141] = { icon = "LuiExtended/media/icons/abilities/ability_set_olorime.dds", name = Abilities.Set_Vestment_of_Olorime, buff = true, debuff = false, ground = false },         -- Vestment of Olirime (Olorime's)
    [109084] = { icon = "LuiExtended/media/icons/abilities/ability_set_olorime.dds", name = Abilities.Set_Vestment_of_Olorime, buff = true, debuff = false, ground = false },         -- Ideal Vestment of Olirime (Olorime's Perfect)
    [107095] = { icon = "LuiExtended/media/icons/abilities/ability_set_mantle_of_siroria.dds", buff = true, debuff = false, ground = false },                                         -- Mantle of Siroria (Siroria's)
    [109081] = { icon = "LuiExtended/media/icons/abilities/ability_set_mantle_of_siroria.dds", name = Abilities.Set_Mantle_of_Siroria, buff = true, debuff = false, ground = false }, -- Ideal Mantle of Siroria (Perfect Siroria's)
    [136098] = { icon = "LuiExtended/media/icons/abilities/ability_set_kynes_blessing.dds", buff = true, debuff = false, ground = false },                                            -- Kyne's Blessing (of Kyne's Wind)
    [137995] = { icon = "LuiExtended/media/icons/abilities/ability_set_kynes_blessing.dds", buff = true, debuff = false, ground = false },                                            -- Kyne's Blessing (of Kyne's Wind (Perfect)) }

    -- Used only to flag abilities for Tooltips
    [75814] = { buff = false, debuff = false, ground = false }, -- Lunar Bastion (Lunar Bastion)

    ---------------------------
    -- Class Abilities --------
    ---------------------------

    -- Dragonknight
    [28988] = { buff = false, debuff = false, ground = true },                  -- Dragonknight Standard (Dragonknight Standard)
    [32958] = { buff = false, debuff = false, ground = true, noRemove = true }, -- Shifting Standard (Shifting Standard)
    [32947] = { buff = false, debuff = false, ground = true },                  -- Standard of Might (Standard of Might)
    [29059] = { buff = true, debuff = false, ground = false },                  -- Ash Cloud (Ash Cloud)
    [20779] = { buff = true, debuff = false, ground = false },                  -- Cinder Storm (Cinder Storm)
    [32710] = { buff = false, debuff = false, ground = true },                  -- Eruption (Eruption)

    -- Nightblade
    [33195] = { buff = true, debuff = false, ground = false },                                                -- Path of Darkness (Path of Darkness)
    [36049] = { buff = false, debuff = false, ground = true },                                                -- Twisting Path (Twisting Path)
    [36028] = { buff = true, debuff = false, ground = false },                                                -- Refreshing Path (Refreshing Path)
    [38517] = { buff = true, debuff = false, ground = false },                                                -- Summon Shade (Summon Shade)
    [88662] = { buff = true, debuff = false, ground = false },                                                -- Summon Shade (Summon Shade) -- Khajiit
    [88663] = { buff = true, debuff = false, ground = false },                                                -- Summon Shade (Summon Shade) -- Argonian
    [35438] = { buff = true, debuff = false, ground = false },                                                -- Dark Shade (Dark Shade)
    [88677] = { buff = true, debuff = false, ground = false },                                                -- Dark Shade (Dark Shade) -- Khajiit
    [88678] = { buff = true, debuff = false, ground = false },                                                -- Dark Shade (Dark Shade) -- Argonian
    [38528] = { name = Abilities.Skill_Shadow_Image, buff = true, debuff = false, ground = false },           -- Shadow (Shadow Image)
    [88696] = { name = Abilities.Skill_Shadow_Image, buff = true, debuff = false, ground = false },           -- Shadow (Shadow Image) -- Khajiit
    [88697] = { name = Abilities.Skill_Shadow_Image, buff = true, debuff = false, ground = false },           -- Shadow (Shadow Image) -- Argonian
    [37475] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 1 }, -- Manifestation of Terror (Nightblade)
    [25411] = { buff = true, debuff = false, ground = false },                                                -- Consuming Darkness (Consuming Darkness)
    [36493] = { buff = true, debuff = false, ground = false },                                                -- Bolstering Darkness (Bolstering Darkness)
    [36485] = { buff = true, debuff = false, ground = false },                                                -- Veil of Blades (Veil of Blades)

    -- Sorcerer
    [24830] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 3, icon = "/esoui/art/icons/ability_sorcerer_daedric_mines.dds" },                                               -- Daedric Mines (Daedric Mines)
    [24847] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 3, icon = "/esoui/art/icons/ability_sorcerer_daedric_tomb.dds", name = Abilities.Skill_Daedric_Tomb },           -- Daedric Mines (Daedric Tomb)
    [25158] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 5, icon = "/esoui/art/icons/ability_sorcerer_daedric_minefield.dds", name = Abilities.Skill_Daedric_Minefield }, -- Daedric Mines (Daedric Minefield)
    [27706] = { buff = false, debuff = false, ground = true },                                                                                                                                                            -- Negate Magic (Negate Magic)
    [28341] = { buff = false, debuff = false, ground = true },                                                                                                                                                            -- Suppression Field (Suppression Field)
    [28348] = { buff = false, debuff = false, ground = true },                                                                                                                                                            -- Absorption Field (Absorption Field)
    [23182] = { buff = false, debuff = false, ground = true },                                                                                                                                                            -- Lightning Splash (Lightning Splash)
    [23200] = { buff = false, debuff = false, ground = true },                                                                                                                                                            -- Liquid Lightning (Liquid Lightning)
    [23205] = { buff = false, debuff = false, ground = true },                                                                                                                                                            -- Lightning Flood (Lightning Flood)
    [23279] = { icon = "LuiExtended/media/icons/abilities/ability_sorcerer_intercept.dds", name = Abilities.Skill_Intercept, buff = true, debuff = false, ground = false },                                               -- Ball of Lightning (Ball of Lightning)

    -- Templar
    [95933] = { icon = "/esoui/art/icons/ability_templar_sun_strike.dds", buff = false, debuff = false, ground = true },        -- Spear Shards (Spear Shards)
    [95957] = { icon = "/esoui/art/icons/ability_templar_light_strike.dds", buff = false, debuff = false, ground = true },      -- Luminous Shards (Luminous Shards)
    [26880] = { icon = "/esoui/art/icons/ability_templarsun_thrust.dds", buff = false, debuff = false, ground = true },         -- Blazing Spear (Blazing Spear)
    [21976] = { icon = "/esoui/art/icons/ability_templar_nova.dds", buff = false, debuff = false, ground = true },              -- Nova (Nova)
    [22003] = { icon = "/esoui/art/icons/ability_templar_solar_prison.dds", buff = false, debuff = false, ground = true },      -- Solar Prison (Solar Prison)
    [22001] = { icon = "/esoui/art/icons/ability_templar_solar_disturbance.dds", buff = false, debuff = false, ground = true }, -- Solar Disturbance (Solar Disturbance)

    [22234] = { buff = true, debuff = false, ground = false },                                                                  -- Rune Focus (Rune Focus)

    -- Used only to flag abilities for Tooltips
    [22265] = { buff = false, debuff = false, ground = false }, -- Cleansing Ritual (Cleansing Ritual)
    [22259] = { buff = false, debuff = false, ground = false }, -- Ritual of Retribution (Ritual of Retribution)
    [22262] = { buff = false, debuff = false, ground = false }, -- Extended Ritual (Extended Ritual)

    -- Warden
    [86161] = { buff = false, debuff = false, ground = true },                                                -- Impaling Shards (Impaling Shards)
    [86165] = { buff = false, debuff = false, ground = true },                                                -- Gripping Shards (Gripping Shards)
    [86169] = { buff = false, debuff = false, ground = true },                                                -- Winter's Revenge (Winter's Revenge)
    [85578] = { buff = true, debuff = false, ground = false },                                                -- Healing Seed (Healing Seed)
    [85840] = { buff = true, debuff = false, ground = false },                                                -- Budding Seeds (Budding Seeds)
    [85845] = { buff = true, debuff = false, ground = false },                                                -- Corrupting Pollen (Corrupting Pollen)
    [85532] = { buff = true, debuff = false, ground = false },                                                -- Secluded Grove (Secluded Grove)
    [85804] = { buff = true, debuff = false, ground = false },                                                -- Enchanted Forest (Enchanted Forest)
    [85807] = { buff = true, debuff = false, ground = false },                                                -- Healing Thicket (Healing Thicket)
    [86175] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 3 }, -- Frozen Gate (Frozen Gate)
    [86179] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 3 }, -- Frozen Device (Frozen Device)
    [86183] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 3 }, -- Frozen Retreat (Frozen Retreat)

    -- Necromancer
    [115252] = { buff = false, debuff = false, ground = true },                                                          -- Boneyard (Boneyard)
    [117805] = { buff = false, debuff = false, ground = true },                                                          -- Unnerving Boneyard (Unnerving Boneyard)
    [117850] = { buff = false, debuff = false, ground = true },                                                          -- Avid Boneyard (Avid Boneyard)

    [116445] = { buff = false, debuff = false, ground = true },                                                          -- Shocking Siphon (Shocking Siphon)
    [118764] = { buff = false, debuff = false, ground = true },                                                          -- Detonating Siphon (Detonating Siphon)
    [118009] = { buff = false, debuff = false, ground = true },                                                          -- Mystic Siphon (Mystic Siphon)

    [122174] = { buff = false, debuff = false, ground = true },                                                          -- Frozen Colossus (Frozen Colossus)
    [122395] = { buff = false, debuff = false, ground = true },                                                          -- Pestilent Colossus (Pestilent Colossus)
    [122388] = { buff = false, debuff = false, ground = true },                                                          -- Glacial Colossus (Glacial Colossus)

    [115093] = { buff = true, debuff = false, ground = false },                                                          -- Bone Totem (Bone Totem)
    [118380] = { buff = true, debuff = false, ground = false },                                                          -- Remote Totem (Remote Totem)
    [118404] = { buff = true, debuff = false, ground = false },                                                          -- Agony Totem (Agony Totem)

    [115326] = { buff = true, debuff = false, ground = false, icon = "/esoui/art/icons/ability_necromancer_016.dds" },   -- Life amid Death (Life amid Death)
    [118022] = { buff = true, debuff = false, ground = false, icon = "/esoui/art/icons/ability_necromancer_016_a.dds" }, -- Renewing Undeath (Renewing Undeath)
    [118814] = { buff = true, debuff = false, ground = false, icon = "/esoui/art/icons/ability_necromancer_016_b.dds" }, -- Enduring Undeath (Enduring Undeath)

    ---------------------------
    -- Two-Handed -------------
    ---------------------------

    [38791] = { buff = false, debuff = false, ground = true }, -- Stampede (Stampede)

    ---------------------------
    -- Bow --------------------
    ---------------------------

    [28876] = { buff = false, debuff = false, ground = true }, -- Volley (Volley)
    [38689] = { buff = false, debuff = false, ground = true }, -- Endless Hail (Endless Hail)
    [38695] = { buff = false, debuff = false, ground = true }, -- Arrow Barrage (Arrow Barrage)
    [85458] = { buff = false, debuff = false, ground = true }, -- Ballista (Ballista)

    ---------------------------
    -- Destruction Staff ------
    ---------------------------

    [28807] = { buff = false, debuff = false, ground = true }, -- Wall of Fire (Wall of Elements)
    [28854] = { buff = false, debuff = false, ground = true }, -- Wall of Storms (Wall of Elements)
    [28849] = { buff = false, debuff = false, ground = true }, -- Wall of Frost (Wall of Elements)
    [39053] = { buff = false, debuff = false, ground = true }, -- Unstable Wall of Fire (Unstable Wall of Elements)
    [39073] = { buff = false, debuff = false, ground = true }, -- Unstable Wall of Storms (Unstable Wall of Elements)
    [39067] = { buff = false, debuff = false, ground = true }, -- Unstable Wall of Frost (Unstable Wall of Elements)
    [39012] = { buff = false, debuff = false, ground = true }, -- Blockade of Fire (Elemental Blockade)
    [39018] = { buff = false, debuff = false, ground = true }, -- Blockade of Storms (Elemental Blockade)
    [39028] = { buff = false, debuff = false, ground = true }, -- Blockade of Frost (Elemental Blockade)
    [83625] = { buff = false, debuff = false, ground = true }, -- Fire Storm (Elemental Storm)
    [83630] = { buff = false, debuff = false, ground = true }, -- Thunder Storm (Elemental Storm)
    [83628] = { buff = false, debuff = false, ground = true }, -- Ice Storm (Elemental Storm)
    [85126] = { buff = false, debuff = false, ground = true }, -- Fiery Rage (Elemental Rage)
    [85130] = { buff = false, debuff = false, ground = true }, -- Thunderous Rage (Elemental Rage)
    [85128] = { buff = false, debuff = false, ground = true }, -- Icy Rage (Elemental Rage)

    ---------------------------
    -- Restoration Staff ------
    ---------------------------

    [28385] = { buff = true, debuff = false, ground = false, noRemove = true }, -- Grand Healing (Grand Healing)
    [40058] = { buff = true, debuff = false, ground = false, noRemove = true }, -- Illustrious Healing (Illustrious Healing)
    [40060] = { buff = true, debuff = false, ground = false, noRemove = true }, -- Healing Springs (Healing Springs)

    ---------------------------
    -- Fighters Guild ---------
    ---------------------------

    [35737] = { buff = true, debuff = false, ground = false }, -- Circle of Protection (Circle of Protection)
    [40181] = { buff = true, debuff = false, ground = false }, -- Turn Evil (Turn Evil)
    [40169] = { buff = true, debuff = false, ground = false }, -- Ring of Preservation (Ring of Preservation)

    ---------------------------
    -- Mages Guild ------------
    ---------------------------

    [31632] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 1 },         -- Fire Rune (Fire Rune)
    [40470] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 1 },         -- Volcanic Rune (Volcanic Rune)
    [40465] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 1 },         -- Scalding Rune (Scalding Rune)
    [63430] = { icon = "/esoui/art/icons/ability_mageguild_005.dds", buff = false, debuff = false, ground = true },   -- Meteor (Meteor)
    [63456] = { icon = "/esoui/art/icons/ability_mageguild_005_b.dds", buff = false, debuff = false, ground = true }, -- Ice Comet (Ice Comet)
    [63473] = { icon = "/esoui/art/icons/ability_mageguild_005_a.dds", buff = false, debuff = false, ground = true }, -- Shooting Star (Shooting Star)

    ---------------------------
    -- Psijic Order -----------
    ---------------------------

    [104079] = { buff = false, debuff = false, ground = true, stackAdd = 1, stackRemove = 1, stackReset = 1 }, -- Time Freeze (Time Freeze)

    ---------------------------
    -- Undaunted --------------
    ---------------------------

    [39489] = { buff = true, debuff = false, ground = false }, -- Blood Altar (Blood Altar)
    [41967] = { buff = true, debuff = false, ground = false }, -- Sanguine Altar (Sanguine Altar)
    [41958] = { buff = true, debuff = false, ground = false }, -- Overflowing Altar (Overflowing Altar)
    [39425] = { buff = false, debuff = false, ground = true }, -- Trapping Webs (Trapping Webs)
    [41990] = { buff = false, debuff = false, ground = true }, -- Shadow Silk (Shadow Silk)
    [42012] = { buff = false, debuff = false, ground = true }, -- Tangling Webs (Tangling Webs)

    [39298] = { buff = false, debuff = false, ground = true }, -- Necrotic Orb (Necrotic Orb)
    [42028] = { buff = false, debuff = false, ground = true }, -- Mystic Orb (Mystic Orb)
    [42038] = { buff = true, debuff = false, ground = false }, -- Energy Orb (Energy Orb)

    ---------------------------
    -- Assault ----------------
    ---------------------------

    [38549] = { icon = "/esoui/art/icons/ability_ava_001.dds", buff = false, debuff = false, ground = true },                                          -- Caltrops (Caltrops)
    [40265] = { icon = "/esoui/art/icons/ability_ava_001_a.dds", buff = false, debuff = false, ground = true },                                        -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [40251] = { icon = "/esoui/art/icons/ability_ava_001_b.dds", name = Abilities.Skill_Razor_Caltrops, buff = false, debuff = false, ground = true }, -- Caltrops (Razor Caltrops)

    ---------------------------
    -- Support ----------------
    ---------------------------

    [38570] = { buff = true, debuff = false, ground = false },                                         -- Siege Shield (Siege Shield)
    [40229] = { buff = true, debuff = false, ground = false },                                         -- Siege Weapon Shield (Siege Weapon Shield)
    [40226] = { buff = true, debuff = false, ground = false },                                         -- Propelling Shield (Propelling Shield)

    [61498] = { buff = false, debuff = false, ground = true },                                         -- Revealing Flare (Revealing Flare)
    [61522] = { name = Abilities.Skill_Lingering_Flare, buff = false, debuff = false, ground = true }, -- Nova (Lingering Flare)
    [61526] = { buff = false, debuff = false, ground = true },                                         -- Blinding Flare (Blinding Flare)
}
