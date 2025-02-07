-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Unitnames = LuiData.Data.UnitNames
local Zonenames = LuiData.Data.ZoneNames
local Abilities = LuiData.Data.Abilities
local ZoneTable = LuiData.Data.ZoneTable

--[[
    LuiExtended AlertTable Definition

    This module defines alert configurations for combat events within LuiExtended.
    It provides options for setting alert priorities, mitigation and miscellaneous alerts,
    result filtering, source name modifications, crowd control (CC) types, duration settings,
    and other modifiers to tailor the behavior of alerts.

    **Priority Settings:**
    - priority: number (1-3)
        * 1 = ARENA/DUNGEON/TRIAL alerts
        * 2 = ELITE NPC/QUEST BOSS alerts
        * 3 = NORMAL NPC alerts

    **Mitigation Alerts Options:**
    - block: boolean         -- Show a Block Alert
    - bs: boolean            -- Add indicator for Block Stagger effect
    - dodge: boolean         -- Show a Dodge Alert
    - avoid: boolean         -- Show an Avoid Alert
    - interrupt: boolean     -- Show an Interrupt Alert
    - reflect: boolean       -- Show a Reflect Alert (not implemented, TODO)
    - unmit: boolean         -- Show an unmitigable alert

    **Miscellaneous Alerts Options:**
    - power: boolean         -- Show a power alert
    - summon: boolean        -- Show a summon alert
    - destroy: boolean       -- Show a destroy alert

    **Result / Filtering Options:**
    - result: ACTION_RESULT_TYPE  -- Determines the combat event action result to detect
    - eventdetect: boolean   -- Detect combat events without a source or target
    - auradetect: boolean    -- Detect aura application instead of using targeting info

    **Source Name Modification Options:**
    - fakeName: string       -- Set a custom name for the source
    - bossName: boolean      -- Use the current BOSS target frame name if available
    - bossMatch: string      -- Specifies a boss name match when multiple bosses exist
    - noForcedNameOverride: boolean -- Fill in the name only if it is missing

    **Crowd Control (CC) Type:**
    - cc: string             -- Set the type of CC effect (e.g. LUIE_CC_TYPE_STUN, LUIE_CC_TYPE_FEAR, etc.)

    **Duration:**
    - duration: number       -- Duration in milliseconds (e.g., for cast alerts)

    **Additional Modifiers:**
    - refire: number|string  -- Refire duration for repeated alerts
    - ignoreRefresh: boolean -- Ignores refresh events
    - neverShowInterrupt: boolean -- Disables the display of interrupt events
    - effectOnlyInterrupt: boolean -- Show interrupt only when an effect ends early
    - alwaysShowInterrupt: boolean -- Always show interrupt even in absence of a duration
    - noSelf: boolean        -- Do not show this alert if you are the source/target
    - durationOnlyIfTarget: boolean -- Only show a duration timer if the player is the target
    - hideIfNoSource: boolean -- Hide the alert if no source name is provided
]]

--- @class AlertTableItem
--- @field priority number             -- Priority of the alert (1: ARENA/DUNGEON/TRIAL, 2: ELITE NPC/QUEST BOSS, 3: NORMAL NPC)
--- @field block? boolean              -- (Mitigation) Displays block alert
--- @field bs? boolean                 -- (Mitigation) Displays block stagger indicator
--- @field dodge? boolean              -- (Mitigation) Displays dodge alert
--- @field avoid? boolean              -- (Mitigation) Displays avoid alert
--- @field interrupt? boolean          -- (Mitigation) Displays interrupt alert
--- @field reflect? boolean            -- (Mitigation) Displays reflect alert (TODO)
--- @field unmit? boolean              -- (Mitigation) Displays unmitigable alert
--- @field power? boolean              -- (Misc) Displays power alert
--- @field summon? boolean             -- (Misc) Displays summon alert
--- @field destroy? boolean            -- (Misc) Displays destroy alert
--- @field result? any                 -- (Filtering) Action result type to detect (ACTION_RESULT_TYPE)
--- @field eventdetect? boolean        -- (Filtering) Detects events with no source or target
--- @field auradetect? boolean         -- (Filtering) Detects aura applications
--- @field fakeName? string            -- (Source Name Modification) Custom source name override
--- @field bossName? boolean           -- (Source Name Modification) Use boss target frame name if possible
--- @field bossMatch? string           -- (Source Name Modification) Specific boss name for matching
--- @field noForcedNameOverride? boolean -- (Source Name Modification) Only override if name is missing
--- @field cc? string                  -- (CC Type) Crowd control type (e.g. LUIE_CC_TYPE_STUN)
--- @field duration? number            -- (Duration) Duration in milliseconds for alert display
--- @field refire? number|string       -- (Other Modifiers) Refire duration (delay between alerts)
--- @field ignoreRefresh? boolean      -- (Other Modifiers) Ignores refresh events
--- @field neverShowInterrupt? boolean -- (Other Modifiers) Do not display interrupt alerts
--- @field effectOnlyInterrupt? boolean -- (Other Modifiers) Only display interrupts on early effect fade
--- @field alwaysShowInterrupt? boolean -- (Other Modifiers) Always display interrupts even without duration
--- @field noSelf? boolean             -- (Other Modifiers) Suppress alerts for self-generated events
--- @field durationOnlyIfTarget? boolean -- (Other Modifiers) Show duration timer only if the player is the target
--- @field hideIfNoSource? boolean     -- (Other Modifiers) Hide alerts when source name is missing

--- @class (partial) AlertTable
--- @field [integer] table<AlertTableItem>
local AlertTable =
{
    --------------------------------------------------
    -- JUSTICE NPC'S ---------------------------------
    --------------------------------------------------

    [63157] =
    {
        block = true,
        dodge = true,
        priority = 2,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Heavy Blow (Justice Guard 1H)
    [63261] =
    {
        block = true,
        dodge = true,
        priority = 2,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1250,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Heavy Blow (Justice Guard 2H)
    [63179] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        reflect = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    },                                                                      -- Flame Shard (Justice Guard 2H)
    [78743] = { avoid = true, priority = 2, result = ACTION_RESULT_BEGIN }, -- Flare (Justice Guard - Any)

    [74862] =
    {
        block = true,
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Teleport Trap (Mage Guard)

    [62409] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        refire = 1500,
        result = ACTION_RESULT_BEGIN,
        duration = 3500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Fiery Wind (Justice Mage NPC)
    [62472] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    },                                                                                                            -- Stab (Justice Dagger NPC)

    [78265] = { power = true, priority = 2, result = ACTION_RESULT_BEGIN, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Alarm (Estate Marshal) (DB DLC)

    [73229] =
    {
        power = true,
        priority = 2,
        auradetect = true,
        ignoreRefresh = true,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    }, -- Hurried Ward (Guard - DB Mage)

    --------------------------------------------------
    -- STANDARD NPC'S --------------------------------
    --------------------------------------------------

    -- Shared
    -- [39058] = { avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, cc = LUIE_CC_TYPE_UNBREAKABLE }, -- Bear Trap (Bear Trap)

    -- Synergy
    [12439] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        refire = 2500,
        duration = 1800,
        postCast = 4000,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Burning Arrow (Synergy)
    [10805] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        postCast = 4000,
        refire = 2500,
        bossMatch = { Unitnames.Boss_Calixte_Darkblood, Unitnames.Boss_Angata_the_Clannfear_Handler },
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Ignite (Synergy)

    -- Abilities
    [29378] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1600,
        cc = LUIE_CC_TYPE_KNOCKBACK,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Uppercut (Ravager)

    [28408] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1533,
        bossMatch = { Unitnames.Boss_Smiles_With_Knife },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Whirlwind (Skirmisher)

    [37108] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_SNARE,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Arrow Spray (Archer)
    [28628] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 6800,
        eventdetect = true,
        refire = 2000,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Volley (Archer)
    [74978] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        reflect = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 9000,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_ATTACK,
    }, -- Taking Aim (Archer)

    [14096] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1250,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Heavy Attack (Footsoldier)
    [28499] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        reflect = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        cc = LUIE_CC_TYPE_SNARE,
        refire = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Throw Dagger (Footsoldier)

    [29400] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1400,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Power Bash (Guard)
    [29761] =
    {
        power = true,
        priority = 3,
        auradetect = true,
        effectOnlyInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    }, -- Brace (Guard)

    [13701] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Focused Charge (Brute)

    [35164] =
    {
        block = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1333,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Agony (Berserker)

    [29510] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        bossMatch =
        {
            Unitnames.Boss_Anarume,
            Unitnames.Boss_Fangoz,
            Unitnames.Boss_Nenesh_gro_Mal,
            Unitnames.NPC_Xivilai_Boltaic,
        },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Thunder Hammer (Thundermaul)
    [17867] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        bossMatch =
        {
            Unitnames.Boss_Anarume,
            Unitnames.Boss_Fangoz,
            Unitnames.Boss_Nenesh_gro_Mal,
            Unitnames.NPC_Xivilai_Boltaic,
        },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                       -- Shock Aura (Thundermaul)
    [44407] = { power = true, priority = 2, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Lightning Form (Thundermaul)
    [81215] =
    {
        block = true,
        interrupt = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STUN,
        bossMatch = { Unitnames.Boss_Captain_Blanchete },
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Shock Aura (Thundermaul - Boss)
    [81195] =
    {
        avoid = true,
        priority = 2,
        auradetect = true,
        cc = LUIE_CC_TYPE_SNARE,
        bossMatch = { Unitnames.Boss_Captain_Blanchete },
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Agonizing Fury (Thundermaul - Boss)
    [81217] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1533,
        bossMatch = { Unitnames.Boss_Captain_Blanchete },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Thunder Hammer (Thundermaul - Boss)

    [36470] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Veiled Strike (Nightblade)
    [137148] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Veiled Strike (Nightblade)
    [44345] =
    {
        block = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        duration = 600,
        bossMatch = { Unitnames.Boss_Dogas_the_Berserker },
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Soul Tether (Nightblade)

    [34742] =
    {
        block = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Fiery Breath (Dragonknight)
    [34646] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Lava Whip (Dragonknight)
    [44227] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossMatch = { Unitnames.Boss_Jahlasri, Unitnames.Boss_Dugan_the_Red },
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Dragonknight Standard (Dragonknight - Elite)
    [52041] =
    {
        block = true,
        dodge = true,
        priority = 2,
        bs = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1667,
        cc = LUIE_CC_TYPE_STUN,
        bossMatch = { Unitnames.Boss_Jahlasri },
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    },                                                                                                                 -- Blink Strike (Dragonknight - Elite)

    [88251] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call Ally (Pet Ranger)
    [88248] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call Ally (Pet Ranger)
    [89425] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call Ally (Pet Ranger)
    [44301] =
    {
        dodge = true,
        priority = 3,
        auradetect = true,
        ignoreRefresh = true,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Trap Beast (Pet Ranger)

    [15164] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1500,
        bossMatch = { Unitnames.Boss_Akezel, Unitnames.Boss_Calixte_Darkblood },
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
        noForcedNameOverride = true,
    }, -- Heat Wave (Fire Mage)
    [47095] =
    {
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2000,
        postCast = 4000,
        bossMatch = { Unitnames.Boss_Calixte_Darkblood, Unitnames.Boss_Keeper_Areldur },
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Fire Rune (Fire Mage)

    [29471] =
    {
        block = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        bossMatch = { Unitnames.NPC_Xivilai_Fulminator, Unitnames.NPC_Xivilai_Boltaic },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Thunder Thrall (Storm Mage)

    [12459] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Winter's Reach (Frost Mage)
    [14194] =
    {
        power = true,
        priority = 3,
        auradetect = true,
        fakeName = "",
        hiddenDuration = 2500,
        hideIfNoSource = true,
        refire = 3000,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    }, -- Ice Barrier (Frost Mage)

    [35151] =
    {
        interrupt = true,
        priority = 3,
        auradetect = true,
        duration = 8000,
        effectOnlyInterrupt = true,
        fakeName = "",
        bossMatch = { Unitnames.Boss_Shagura },
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    }, -- Spell Absorption (Spirit Mage)
    [14472] =
    {
        summon = true,
        priority = 2,
        auradetect = true,
        fakeName = "",
        bossMatch = { Unitnames.Boss_Shagura },
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    }, -- Burdening Eye (Spirit Mage)

    [36985] =
    {
        block = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        hiddenDuration = 3500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Void (Time Bomb Mage)

    [37087] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        eventdetect = true,
        postCast = 1250,
        bossMatch =
        {
            Unitnames.Boss_Thjormar_the_Drowned,
            Unitnames.Boss_Stroda_gra_Drom,
            Unitnames.NPC_Xivilai_Fulminator,
            Unitnames.NPC_Xivilai_Boltaic,
        },
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Lightning Onslaught (Battlemage)
    [37129] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_SNARE,
        eventdetect = true,
        bossMatch = { Unitnames.Boss_Thjormar_the_Drowned, Unitnames.Boss_Stroda_gra_Drom },
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Ice Cage (Battlemage)
    [44216] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_SILENCE,
        eventdetect = true,
        bossMatch = { Unitnames.Boss_Thjormar_the_Drowned, Unitnames.Boss_Stroda_gra_Drom },
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    },                                                                                                                 -- Negate Magic (Battlemage - Elite)

    [88554] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon the Dead (Necromancer)
    [88555] =
    {
        summon = true,
        priority = 2,
        auradetect = true,
        fakeName = "",
        bossMatch =
        {
            Unitnames.Boss_Gravecaller_Niramo,
            Unitnames.Boss_Grivier_Bloodcaller,
            Unitnames.Boss_Louna_Darkblood,
        },
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    },                                                                                                                 -- Summon the Dead (Necromancer)
    [88556] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon the Dead (Necromancer)
    [13397] =
    {
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        duration = 5000,
        bossMatch =
        {
            Unitnames.Boss_Gravecaller_Niramo,
            Unitnames.Boss_Grivier_Bloodcaller,
            Unitnames.Boss_Louna_Darkblood,
        },
        hideIfNoSource = true,
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    }, -- Empower Undead (Necromancer)

    [14350] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1667,
        cc = LUIE_CC_TYPE_FEAR,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    },                                                                                                                 -- Aspect of Terror (Fear Mage)

    [44250] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Dark Shade (Dreadweaver)

    [44323] =
    {
        power = true,
        priority = 3,
        auradetect = true,
        ignoreRefresh = true,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    },                                                                                                       -- Dampen Magic (Soulbrander)
    [44258] = { power = true, priority = 3, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Radiant Magelight (Soulbrander)

    [35387] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        cc = LUIE_CC_TYPE_SNARE,
        duration = 1000,
        postCast = 4000,
        bossMatch = { Unitnames.Boss_Overlord_Nur_dro },
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Defiled Grave (Bonelord)
    [88506] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = "",
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    }, -- Summon Abomination (Bonelord)
    [88507] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = "",
        bossMatch = { Unitnames.Boss_Overlord_Nur_dro },
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    }, -- Summon Abomination (Bonelord)

    [57534] =
    {
        interrupt = true,
        priority = 3,
        duration = 4000,
        auradetect = true,
        effectOnlyInterrupt = true,
        fakeName = "",
        hideIfNoSource = true,
        noSelf = true,
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    }, -- Focused Healing (Healer)
    [50966] =
    {
        power = true,
        auradetect = true,
        priority = 2,
        alwaysShowInterrupt = true,
        duration = 5000,
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    },                                                                                                                    -- Healer Immune (Healer - Craglorn/DLC)
    [44328] = { interrupt = true, priority = 2, auradetect = true, duration = 4500, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Rite of Passage (Healer)

    [29520] =
    {
        destroy = true,
        auradetect = true,
        priority = 2,
        fakeName = "",
        bossMatch = { Unitnames.Boss_Bagul },
        sound = LUIE_ALERT_SOUND_TYPE_DESTROY,
    }, -- Aura of Protection (Shaman)

    [68866] =
    {
        power = true,
        auradetect = true,
        refire = 1000,
        priority = 2,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE,
    },                                                                                                 -- War Horn (Faction NPC)
    [43644] = { avoid = true, priority = 3, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Barrier [monster synergy]  (Faction NPCs)
    [43645] = { avoid = true, priority = 3, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Barrier [monster synergy]  (Faction NPCs)
    [43646] = { avoid = true, priority = 3, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Barrier [monster synergy]  (Faction NPCs)

    [70070] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1250,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Heavy Strike (Winterborn Warrior)
    [64980] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        reflect = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
        postCast = 500,
    }, -- Javelin (Winterborn Warrior)
    [65033] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        duration = 1000,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Retaliation (Winterborn Warrior)

    [55909] =
    {
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        postCast = 2300,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Grasping Vines (Winterborn Mage)
    [64704] =
    {
        block = true,
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        refire = 1500,
        result = ACTION_RESULT_BEGIN,
        duration = 4500,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    },                                                                                                       -- Flames (Winterborn Mage)

    [65235] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Enrage (Vosh Rakh Devoted)
    [53987] =
    {
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 3000,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE,
    }, -- Rally (Vosh Rakh Devoted)
    [54027] =
    {
        block = true,
        dodge = true,
        priority = 3,
        refire = 1600,
        result = ACTION_RESULT_BEGIN,
        duration = 4000,
        cc = LUIE_CC_TYPE_STUN,
        neverShowInterrupt = true,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    },                                                                                                       -- Divine Leap (Vosh Rakh Devoted)

    [51000] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Cleave Stance (Dremora Caitiff) (Craglorn)

    [72725] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Fool Me Once (Sentinel) (TG DLC)

    [76089] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        reflect = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    },                                                                                                        -- Snipe (Archer) (TG DLC)
    -- [72220] = { block = true, dodge = true, reflect = true, priority = 3, result = ACTION_RESULT_BEGIN, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Snipe (Archer) (TG DLC) -- This is cast from stealth - so for the time being, maybe hide.
    [72222] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Shadow Cloak (Archer) (TG DLC)

    [77472] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Til Death (Bodyguard) (DB DLC)
    [77554] =
    {
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    }, -- Shard Shield (Bodyguard) (DB DLC)
    [77473] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Shield Charge (Bodyguard) (DB DLC)

    [77089] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1250,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Basilisk Powder (Tracker) (Morrowind)
    [77087] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        reflect = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Basilisk Powder (Tracker) (Morrowind)
    [77019] =
    {
        block = true,
        dodge = true,
        reflect = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 766,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Pin (Tracker) (Morrowind)
    [78432] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Lunge (Tracker) (Morrowind)

    [88371] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        eventdetect = true,
        postCast = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Dive (Beastcaller) (Morrowind)
    [88394] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STUN,
        eventdetect = true,
        postCast = 2300,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
    },                                                                                                                 -- Gore (Beastcaller) (Morrowind)
    [88409] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Raise the Earth (Beastcaller)

    [87901] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Bombard (Arbalest) (Morrowind)
    [87422] =
    {
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_SNARE,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Chilled Ground (Arbalest) (Morrowind)
    [87713] =
    {
        block = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1300,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Quakeshot (Arbalest) (Morrowind)

    [85359] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1267,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Reverse Slash (Drudge)

    [87064] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STUN,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Volcanic Debris (Fire-Binder) (Morrowind)
    [88845] =
    {
        interrupt = true,
        priority = 3,
        auradetect = true,
        duration = 15000,
        effectOnlyInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    }, -- Empower Atronach (Fire-Binder) (Morrowind)

    [76621] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
        noDirect = true,
    }, -- Shadeway (Voidbringer) (Morrowind)
    [76619] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Pool of Shadow (Voidbringer) (Morrowind)
    [76979] =
    {
        block = true,
        avoid = true,
        priority = 3,
        auradetect = true,
        duration = 5000,
        cc = LUIE_CC_TYPE_STUN,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
        fakeName = "",
    }, -- Shadowy Duplicate (Voidbringer) (Morrowind)

    [88327] =
    {
        block = true,
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
        noDirect = true,
    }, -- Shadeway (Skaafin Masquer) (Morrowind)
    [88325] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Pool of Shadow (Skaafin Masquer) (Morrowind)
    [88348] =
    {
        block = true,
        avoid = true,
        priority = 3,
        auradetect = true,
        duration = 5000,
        cc = LUIE_CC_TYPE_STUN,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
        fakeName = "",
    },                                                                                                                    -- Shadowy Duplicate (Skaafin Masquer) (Morrowind)

    [84818] = { interrupt = true, priority = 3, auradetect = true, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Fiendish Healing (Skaafin Witchling) (Morrowind)

    [84835] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        duration = 2300,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
        postCast = 4000,
    }, -- Broken Pact (Skaafin) (Morrowind)

    -- ANIMALS
    [5452] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Lacerate (Alit)

    [4415] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1600,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Crushing Swipe (Bear)
    [139956] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Savage Blow (Bear)

    [70366] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2167,
        cc = LUIE_CC_TYPE_STUN,
        bossMatch = { Unitnames.Boss_Gurgozu, Unitnames.Boss_Graufang },
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    },                                                                                                        -- Slam (Great Bear)
    [70374] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Ferocity (Great Bear)

    [4591] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 970,
        hideIfNoSource = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Sweep (Crocodile)
    [4594] =
    {
        power = true,
        auradetect = true,
        priority = 2,
        ignoreRefresh = true,
        refire = 500,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    }, -- Ancient Skin (Crocodile)

    [8977] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1721,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Sweep (Duneripper)

    [7227] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1100,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Rotbone (Durzog)

    [6308] =
    {
        block = true,
        dodge = true,
        reflect = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2500,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Shocking Touch (Dreugh)
    [6328] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        refire = 2000,
        duration = 3600,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Shocking Rake (Dreugh)

    [54375] =
    {
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1300,
        cc = LUIE_CC_TYPE_STAGGER,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Shockwave (Echatere)
    [54380] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1300,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Headbutt (Echatere)

    [4632] =
    {
        block = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        eventdetect = true,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Screech (Giant Bat)
    [4630] =
    {
        dodge = true,
        interrupt = true,
        priority = 3,
        refire = 1500,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Draining Bite (Giant Bat)

    [5240] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2600,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Lash (Giant Snake)
    [5242] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    },                                                                                                                   -- Kiss of Poison (Giant Snake)
    [5244] = { interrupt = true, priority = 3, auradetect = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Shed Skin (Giant Snake)

    [5441] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Dive (Guar)

    [14196] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Charge (Kagouti)
    [5363] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Chomp (Kagouti)
    [5926] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Toss (Kagouti)
    [87276] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Chomp (Kagouti Whelp)

    [7161] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Double Strike (Lion)

    [8601] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        refire = 600,
        duration = 6000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Vigorous Swipe (Mammoth)
    [8600] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_EFFECT_GAINED,
        duration = 3000,
        cc = LUIE_CC_TYPE_STAGGER,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Stomp (Mammoth)
    [23230] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Charge (Mammoth)

    [4200] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Unforgiving Claws (Mudcrab)

    [16690] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Thrust (Netch)
    [16697] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        refire = 1800,
        duration = 7500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Poisonbloom (Netch)

    [7268] =
    {
        interrupt = true,
        priority = 3,
        refire = 500,
        result = ACTION_RESULT_BEGIN,
        duration = 5650,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Leech (Nix-Hound)
    [7273] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Dampworm (Nix-Hound)

    [21904] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Rend (Skeever)

    [21951] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 4900,
        neverShowInterrupt = true,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Repulsion Shock (Wamasu)
    [21949] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1400,
        cc = LUIE_CC_TYPE_STUN,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Sweep (Wamasu)
    [21957] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    },                                                                                                       -- Charge (Wamasu)
    [22045] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, --- Static (Wamasu)

    [55866] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 4900,
        neverShowInterrupt = true,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Repulsion Shock (Wamasu - Boss)
    [55868] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        cc = LUIE_CC_TYPE_STUN,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Sweep (Wamasu - Boss)
    [55850] =
    {
        avoid = true,
        interrupt = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Impending Storm (Wamasu - Boss)
    [55860] =
    {
        dodge = true,
        interrupt = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1700,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Storm Bound (Wamasu - Boss)

    [44791] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Rear Kick (Welwa)
    [50714] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        eventdetect = true,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Charge (Welwa)

    [42844] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1100,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Rotbone (Wolf)
    [14523] =
    {
        dodge = true,
        interrupt = true,
        priority = 3,
        refire = 1000,
        result = ACTION_RESULT_BEGIN,
        duration = 6800,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    },                                                                                                                 -- Helljoint (Wolf)
    [14272] = { summon = true, auradetect = true, priority = 2, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call of the Pack (Wolf)
    [26658] = { summon = true, auradetect = true, priority = 2, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call of the Pack (Jackal)

    [72793] =
    {
        dodge = true,
        reflect = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1767,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Toxic Mucus (Haj Mota)
    [72796] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
    }, -- Bog Burst (Haj Mota)
    [72789] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1667,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
    }, -- Shockwave (Haj Mota)

    [76307] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1467,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Lunge (Dire Wolf)
    [76324] =
    {
        power = true,
        auradetect = true,
        priority = 2,
        refire = 1000,
        hiddenDuration = 2500,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE,
    }, -- Baleful Call (Dire Wolf)

    [85201] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1167,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Bite (Nix-Ox)
    [85084] =
    {
        block = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        refire = 750,
        result = ACTION_RESULT_BEGIN,
        duration = 500,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Shriek (Nix-Ox)
    [90765] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        refire = 1000,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Acid Spray (Nix-Ox)
    [90809] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        refire = 1000,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Acid Spray (Nix-Ox)
    [85172] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 500,
        cc = LUIE_CC_TYPE_STUN,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Winnow (Nix-Ox)
    [85203] =
    {
        power = true,
        auradetect = true,
        priority = 2,
        refire = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE,
    }, -- Nix-Call (Nix-Ox)

    [85395] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        duration = 1333,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Dive (Cliff Strider)
    [85399] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Retch (Cliff Strider)
    [85390] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        refire = 750,
        result = ACTION_RESULT_BEGIN,
        duration = 1600,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Slash (Cliff Strider)

    -- INSECTS
    [6137] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 800,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Laceration (Assassin Beetle)
    [5268] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Collywobbles (Assassin Beetle)

    [6757] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Blurred Strike (Giant Scorpion)
    [6756] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Paralyze (Giant Scorpion)
    [6758] =
    {
        power = true,
        auradetect = true,
        priority = 2,
        ignoreRefresh = true,
        refire = 500,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    }, -- Hardened Carapace (Giant Scorpion)

    [5789] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        duration = 2000,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Fire Runes (Giant Spider)
    [5685] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Corrosive Bite (Giant Spider)
    [8087] =
    {
        block = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        refire = 1200,
        result = ACTION_RESULT_BEGIN,
        duration = 5100,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Poison Spray (Giant Spider)
    -- [4737] = { avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Encase (Giant Spider)
    [13382] =
    {
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        hideIfNoSource = true,
        alwaysShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    }, -- Devour (Giant Spider)

    [9226] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1400,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Sting (Wasp)
    [25110] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Focused Charge (Giant Wasp)
    [9229] =
    {
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Inject Larva (Giant Wasp)

    [6800] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Bloodletting (Hoarvor)
    [6795] =
    {
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 7850,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Latch On (Hoarvor)

    [61244] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Fevered Retch (Necrotic Hoarvor)
    [61360] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 5500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Infectious Swarm (Necrotic Hoarvor)
    [61427] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        duration = 1200,
        cc = LUIE_CC_TYPE_SNARE,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Necrotic Explosion (Necrotic Hoarvor)

    [14841] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Focused Charge (Kwama Worker)

    [9769] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 3267,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                                 -- Excavation (Kwama Warrior)
    [49192] = { summon = true, priority = 3, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Excavation (Kwama Warrior)

    [5260] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        refire = 750,
        result = ACTION_RESULT_BEGIN,
        duration = 2700,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Flamethrower (Shalk)
    [5252] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1100,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Fire Bite (Shalk)
    [5262] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        auradetect = true,
        duration = 4000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Burning Ground (Shalk)

    [8429] =
    {
        interrupt = true,
        priority = 3,
        refire = 1000,
        result = ACTION_RESULT_BEGIN,
        duration = 4600,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Zap (Thunderbug)
    [26412] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        postCast = 1800,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Thunderstrikes (Thunderbug)

    [73172] =
    {
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 3667,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Swarm (Kotu Gava Broodmother)
    [73199] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    },                                                                                                                 -- Swarmburst (Kotu Gava Broodmother)

    [87022] = { summon = true, auradetect = true, priority = 3, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Swarm (Fetcherfly Nest)
    -- [85645] = { block = true, avoid = true, priority = 3, result = ACTION_RESULT_BEGIN, duration = 1000 }, -- Bombard (Fetcherfly Nest)
    [87125] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        auradetect = true,
        duration = 8000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Heat Vents (Fetcherfly Nest)

    [92078] =
    {
        destroy = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        sound = LUIE_ALERT_SOUND_TYPE_DESTROY,
    }, -- Colonize (Fetcherfly Hive Golem)
    [87062] =
    {
        block = true,
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 4000,
        cc = LUIE_CC_TYPE_SILENCE,
        postCast = 2000,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Fetcherfly Storm (Fetcherfly Hive Golem)
    [87030] =
    {
        block = true,
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 867,
        postCast = 750,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Focused Swarm (Fetcherfly Hive Golem)

    -- DAEDRA
    [31115] =
    {
        destroy = true,
        refire = 1000,
        priority = 2,
        auradetect = true,
        fakeName = "",
        sound = LUIE_ALERT_SOUND_TYPE_DESTROY,
    }, -- Summon Dark Anchor (Daedric Synergy)
    -- [68449] = { avoid = true, refire = 1000, priority = 3, duration = 500, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Explosive Charge (Daedric Synergy) -- TODO: Needs result if ever enabled.

    [48121] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Heavy Attack (Air Atronach)
    [48137] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                       -- Tornado (Air Atronach)

    [51262] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Air Atronach Flame (Air Atronach)
    [51271] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Air Atronach Flame (Air Atronach)
    [51269] = { power = true, auradetect = true, priority = 2, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Air Atronach Flame (Air Atronach)

    [51281] =
    {
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        refire = 1500,
        duration = 3250,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Flame Tornado (Air Atronach)
    [50021] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Ice Vortex (Air Atronach)
    [50023] =
    {
        block = true,
        interrupt = true,
        priority = 3,
        refire = 800,
        result = ACTION_RESULT_BEGIN,
        duration = 4600,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Lightning Rod (Air Atronach)

    [9747] =
    {
        block = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Dire Wound (Banekin)
    [9748] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 3000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Envelop (Banekin)

    [4799] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Tail Spike (Clannfear)
    [93745] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        duration = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Rending Leap (Clannfear)

    [26641] =
    {
        avoid = true,
        interrupt = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
    }, -- Soul Flame (Daedric Titan)
    [34405] =
    {
        block = true,
        avoid = true,
        priority = 2,
        auradetect = true,
        duration = 2200,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Swallowing Souls (Daedric Titan)
    [26554] =
    {
        block = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STUN,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Wing Gust (Daedric Titan)

    [4771] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        refire = 1250,
        result = ACTION_RESULT_BEGIN,
        duration = 3100,
        bossMatch = { Unitnames.Boss_Ysolmarr_the_Roving_Pyre, Unitnames.Boss_Gar_Xuu_Gar },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Fiery Breath (Daedroth)
    [91946] =
    {
        avoid = true,
        interrupt = true,
        eventdetect = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STAGGER,
        postCast = 750,
        bossMatch = { Unitnames.Boss_Ysolmarr_the_Roving_Pyre, Unitnames.Boss_Gar_Xuu_Gar },
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
    }, -- Ground Tremor (Daedroth)
    [91937] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1767,
        cc = LUIE_CC_TYPE_STUN,
        postCast = 500,
        bossMatch = { Unitnames.Boss_Ysolmarr_the_Roving_Pyre, Unitnames.Boss_Gar_Xuu_Gar },
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Burst of Embers (Daedroth)

    [26324] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1300,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Lava Geyser (Flame Atronach)
    -- [50216] = { block = true, avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, refire = 250, duration = 2000, neverShowInterrupt = true }, -- Combustion (Flame Atronach)

    [5017] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Hoarfrost Fist (Frost Atronach)
    [33502] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_SNARE,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Frozen Ground (Frost Atronach)

    [50626] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2750,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Shadow Strike (Grevious Twilight) -- TODO: Is this st or aoe?
    [65889] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2750,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Shadow Strike (Grevious Twilight) -- TODO: Is this st or aoe?

    [4829] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Fire Brand (Flesh Atronach)
    [4817] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Unyielding Mace (Flesh Atronach)
    --[[[67870] = {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1700,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Tremor AOE (Flesh Colossus) ]]
    -- TODO: Removed (also - is this AOE?)
    [66869] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Pin (Flesh Colossus) -- TODO: Is this AOE?
    [67872] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1600,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Sweep (Flesh Colossus) -- TODO: Is this AOE?
    [76139] =
    {
        block = true,
        dodge = true,
        priority = 2,
        auradetect = true,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Stumble Forward (Flesh Colossus) -- TODO: Is this AOE?
    -- [67772] = { power = true, priority = 2, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Enraged (Flesh Colossus) -- TODO: Does this have an aura now?
    [49430] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1750,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Smash (Flesh Colossus) -- TODO: Is this only ST?
    [49429] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1250,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Claw (Flesh Colossus) -- TODO: Is this only ST?

    [11079] =
    {
        avoid = true,
        interrupt = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1300,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
    }, -- Black Winter (Harvester)
    [26017] =
    {
        destroy = true,
        priority = 2,
        auradetect = true,
        fakeName = "",
        refire = 5000,
        bossMatch = { Unitnames.Boss_High_Kinlord_Rilis },
        sound = LUIE_ALERT_SOUND_TYPE_DESTROY,
    },                                                                                                                   -- Creeping Doom (Harvester)

    [8205] = { interrupt = true, priority = 3, auradetect = true, duration = 6000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Regeneration (Ogrim)
    [24690] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Focused Charge (Ogrim)
    [91848] =
    {
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1970,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Stomp (Ogrim)
    [91855] =
    {
        block = true,
        avoid = true,
        eventdetect = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STAGGER,
        postCast = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Boulder Toss (Ogrim)

    [6166] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Heat Wave (Scamp)
    [6160] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        auradetect = true,
        duration = 5000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Rain of Fire (Scamp)

    [8779] =
    {
        block = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        postCast = 1750,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Lightning Onslaught (Spider Daedra)
    -- [89306] = { avoid = true, priority = 3, result = ACTION_RESULT_BEGIN, eventdetect = true, fakeName = Unitnames.NPC_Spiderling, cc = LUIE_CC_TYPE_SNARE, duration = 1000, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Web (Spiderling)
    [8782] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        eventdetect = true,
        postCast = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                                -- Lightning Storm (Spider Daedra)
    [8773] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Spiderling (Spider Daedra)

    [35220] =
    {
        avoid = true,
        interrupt = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        postCast = 4000,
        bossMatch = { Unitnames.Boss_Zymel_Etitan, Unitnames.Boss_Zymel_Kruz },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Impending Storm (Storm Atronach)
    [4864] =
    {
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_SNARE,
        duration = 633,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Storm Bound (Storm Atronach)

    [7095] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1400,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Heavy Attack (Xivilai)
    [88947] =
    {
        block = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        hiddenDuration = 3000,
        bossMatch = { Unitnames.NPC_Xivilai_Fulminator, Unitnames.NPC_Xivilai_Boltaic },
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
        noDirect = true,
    }, -- Lightning Grasp (Xivilai)
    [7100] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1333,
        postCast = 3000,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Hand of Flame (Xivilai)
    [25726] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = "",
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    }, -- Summon Daedra (Xivilai)

    [4653] =
    {
        block = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        duration = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Shockwave (Watcher)
    [9219] =
    {
        block = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        refire = 1750,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        duration = 4000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Doom-Truth's Gaze (Watcher)
    [14425] =
    {
        block = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        refire = 1750,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        duration = 3500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Doom-Truth's Gaze (Watcher)

    [6410] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1700,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Tail Clip (Winged Twilight)
    [6412] =
    {
        block = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1200,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Dusk's Howl (Winged Twilight)

    [94903] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1200,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Spring (Hunger)
    [87237] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 667,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Spring (Hunger)
    [87252] =
    {
        power = true,
        refire = 400,
        priority = 2,
        auradetect = true,
        noSelf = true,
        duration = 6000,
        cc = LUIE_CC_TYPE_STUN,
        effectOnlyInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Devour (Hunger)
    [84944] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2300,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Hollow (Hunger)
    [87269] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1400,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Torpor (Hunger)

    [88282] =
    {
        avoid = true,
        eventdetect = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 767,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Rock Stomp (Iron Atronach)
    [88261] =
    {
        block = true,
        eventdetect = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 800,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Lava Wave (Iron Atronach)
    [88297] =
    {
        avoid = true,
        auradetect = true,
        priority = 2,
        duration = 6000,
        effectOnlyInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Blast Furnace (Iron Atronach)

    -- UNDEAD
    [8569] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1300,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Devastating Leap (Bloodfiend)
    [8554] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2400,
        hideIfNoSource = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Flurry (Bloodfiend)

    [5050] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STAGGER,
        bossMatch = { Unitnames.Boss_Griviers_Monstrosity, Unitnames.Boss_Skeletal_Destroyer },
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Bone Saw (Bone Colossus)
    [5030] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = "",
        bossMatch = { Unitnames.Boss_Griviers_Monstrosity, Unitnames.Boss_Oskana, Unitnames.Boss_Skeletal_Destroyer },
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    }, -- Voice to Wake the Dead (Bone Colossus)
    [17207] =
    {
        block = true,
        dodge = true,
        priority = 3,
        auradetect = true,
        duration = 2500,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Necromantic Implosion (Risen Dead)

    [18514] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Chill Touch (Ghost)
    [19137] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        cc = LUIE_CC_TYPE_FEAR,
        duration = 2000,
        postCast = 2000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Haunting Spectre (Ghost)

    [22521] =
    {
        avoid = true,
        priority = 2,
        auradetect = true,
        cc = LUIE_CC_TYPE_SNARE,
        neverShowInterrupt = true,
        bossMatch = { Unitnames.Boss_Valanir_the_Restless },
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Defiled Ground (Lich)
    [73925] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        cc = LUIE_CC_TYPE_STUN,
        duration = 7450,
        refire = 2000,
        neverShowInterrupt = true,
        bossMatch = { Unitnames.Boss_Valanir_the_Restless },
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Soul Cage (Lich)

    [50182] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Consuming Energy (Spellfiend)

    [68735] =
    {
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 6000,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Vampiric Drain (Vampire)

    [2867] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1400,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Crushing Leap (Werewolf)
    [3415] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        refire = 1100,
        result = ACTION_RESULT_BEGIN,
        duration = 4667,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    },                                                                                                                    -- Flurry (Werewolf)
    [44055] = { interrupt = true, priority = 3, auradetect = true, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Devour (Werewolf)
    [5785] =
    {
        power = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE,
    }, -- Blood Scent (Werewolf)

    [4337] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Winter's Reach (Wraith)

    [2969] =
    {
        block = true,
        dodge = true,
        bs = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Pound (Zombie)
    [2960] =
    {
        block = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2100,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Vomit (Zombie)

    [72979] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Dissonant Blow (Defiled Aegis)
    [72995] =
    {
        interrupt = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        refire = 1100,
        result = ACTION_RESULT_BEGIN,
        duration = 6100,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                                 -- Symphony of Blades (Defiled Aegis) -- Higher priority because damage is very high
    [76180] = { summon = true, auradetect = true, priority = 2, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Shattered Harmony (Defiled Aegis)

    -- MONSTERS
    [10270] =
    {
        block = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        refire = 1250,
        result = ACTION_RESULT_BEGIN,
        duration = 2550,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Quake (Gargoyle)
    [10256] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Lacerate (Gargoyle)
    [51352] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        postCast = 600,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Petrify (Gargoyle)

    [26124] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Shatter (Giant)
    [127910] =
    {
        block = true,
        avoid = true,
        priority = 2,
        auradetect = true,
        duration = 3200,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Giant's Maul (Giant)

    [2786] =
    {
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        refire = 1250,
        duration = 6100,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Steal Essence (Hag)
    [2821] =
    {
        block = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 700,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Luring Snare (Hag)
    [3349] =
    {
        power = true,
        priority = 2,
        auradetect = true,
        duration = 8000,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    }, -- Reflective Shadows (Hag)

    [10615] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
    }, -- Raven Storm (Hagraven)
    [10613] =
    {
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2050,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                  -- Fire Bomb (Hagraven)
    [64808] = { summon = true, priority = 2, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Briarheart Ressurection (Hagraven)

    [4123] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Wing Slice (Harpy)
    [13515] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Wind Gust (Harpy)
    [24604] =
    {
        avoid = true,
        interrupt = true,
        eventdetect = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 8000,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Charged Ground (Harpy)
    [4689] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1300,
        postCast = 1750,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Lightning Gale (Harpy)

    [43809] =
    {
        avoid = true,
        priority = 3,
        auradetect = true,
        duration = 1750,
        cc = LUIE_CC_TYPE_STUN,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Shard Burst (Ice Wraith)
    [24866] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Focused Charge (Ice Wraith)

    [17703] =
    {
        block = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        refire = 750,
        duration = 4550,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Flame Ray (Imp - Fire)
    [8884] =
    {
        block = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        refire = 750,
        duration = 4550,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Zap (Imp - Lightning)
    [81794] =
    {
        block = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        refire = 750,
        duration = 4600,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Frost Ray (Imp - Frost)

    [9671] =
    {
        block = true,
        bs = true,
        eventdetect = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Howling Strike (Lamia)
    [9674] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STAGGER,
        eventdetect = true,
        postCast = 1500,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC,
    }, -- Resonate (Lamia)
    [7835] =
    {
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    },                                                                                                                -- Convalescence (Lamia)
    -- [7831] = { interrupt = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, refire = 2500, duration = 5000 }, -- Harmony (Lamia)
    [9680] = { summon = true, auradetect = true, priority = 2, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Spectral Lamia

    [3860] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 500,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Pulverize (Lurcher)
    [3855] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Crushing Limbs (Lurcher)
    [3767] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        refire = 1100,
        result = ACTION_RESULT_BEGIN,
        duration = 5600,
        bossMatch = { Unitnames.Boss_Limbscather, Unitnames.Boss_Heart_of_Rootwater, Unitnames.Boss_Ravenous_Loam },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Choking Pollen (Lurcher)

    [5559] =
    {
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2200,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Icy Geyser (Nereid)
    [5540] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        auradetect = true,
        duration = 8000,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                       -- Hurricane (Nereid)

    [24985] = { power = true, auradetect = true, priority = 3, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Intimidating Roar (Ogre)
    [5881] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1300,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Smash (Ogre)
    [5256] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        eventdetect = true,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Shockwave (Ogre)

    [53142] =
    {
        destroy = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_DESTROY,
    }, -- Ice Pillar (Ogre Shaman)
    -- [64540] = { interrupt = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Freeze Wounds (Ogre Shaman)
    -- [53137] = { interrupt = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Freeze Wounds (Ogre Shaman)

    [21582] =
    {
        block = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                                    -- Nature's Swarm (Spriggan)
    [13475] = { interrupt = true, priority = 3, auradetect = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Healing Salve (Spriggan)
    [13477] =
    {
        interrupt = true,
        priority = 3,
        auradetect = true,
        duration = 5000,
        effectOnlyInterrupt = true,
        fakeName = "",
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    },                                                                                                                 -- Control Beast (Spriggan)
    [89119] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Beast (Spriggan)
    [89102] = { summon = true, priority = 2, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Beast (Spriggan)

    [9346] =
    {
        interrupt = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 5000,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Strangle (Strangler)
    [9322] =
    {
        avoid = true,
        priority = 3,
        auradetect = true,
        duration = 2000,
        bossMatch = { Unitnames.Boss_Bone_Grappler, Unitnames.Boss_Dirge_of_Thorns },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Poisoned Ground (Strangler)
    [9321] =
    {
        block = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        refire = 500,
        cc = LUIE_CC_TYPE_STUN,
        duration = 700,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Grapple (Strangler)

    [44736] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        refire = 2000,
        result = ACTION_RESULT_BEGIN,
        duration = 2150,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Swinging Cleave (Troll)
    [9009] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        refire = 300,
        result = ACTION_RESULT_BEGIN,
        duration = 2500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Tremor (Troll)

    [76268] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STAGGER,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Lope (River Troll)
    [76277] =
    {
        interrupt = true,
        priority = 2,
        eventdetect = true,
        refire = 1000,
        result = ACTION_RESULT_BEGIN,
        duration = 5233,
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    }, -- Close Wounds (River Troll)
    [76295] =
    {
        block = true,
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Crab Toss (River Troll)

    [48256] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2000,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Boulder Toss (Troll - Ranged)
    [48282] =
    {
        interrupt = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Consuming Omen (Troll - Ranged)

    [4309] =
    {
        block = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Dying Blast (Wisp)

    [7976] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 13500,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    },                                                                                                 -- Rain of Wisps (Wispmother)
    [18040] = { power = true, priority = 2, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Clone (Wispmother)

    [75867] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1333,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Clobber (Minotaur)
    [75917] =
    {
        block = true,
        dodge = true,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Ram (Minotaur)
    [79541] =
    {
        block = true,
        dodge = true,
        priority = 2,
        auradetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Flying Leap (Minotaur)
    [75925] =
    {
        power = true,
        auradetect = 2,
        priority = 2,
        ignoreRefresh = true,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE,
    }, -- Elemental Weapon (Minotaur)

    [75951] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 3100,
        cc = LUIE_CC_TYPE_SNARE,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Brimstone Hailfire (Minotaur Shaman)
    [75955] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        refire = 1000,
        result = ACTION_RESULT_BEGIN,
        duration = 3800,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Pillars of Nirn (Minotaur Shaman)
    [75994] =
    {
        power = true,
        priority = 2,
        auradetect = true,
        ignoreRefresh = true,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE,
    }, -- Molten Armor (Minotaur Shaman)

    [49499] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Spear Throw (Mantikora)
    [49404] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STAGGER,
    },                                                                                                       -- Rear Up (Mantikora)
    [49402] = { block = true, dodge = true, priority = 2, result = ACTION_RESULT_BEGIN, duration = 1750 },   -- Tail Whip (Mantikora)
    [50187] = { power = true, priority = 2, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Enrage (Mantikora)
    [56689] = { power = true, priority = 2, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Enraged (Mantikora)

    [104479] =
    {
        block = true,
        bs = true,
        dodge = true,
        interrupt = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 933,
        cc = LUIE_CC_TYPE_STUN,
    },                                                                                                                -- Reave (Yaghra Strider) -- TODO: SOUND / CHECK AOE / ETC
    [105214] = { block = true, dodge = true, priority = 2, result = ACTION_RESULT_BEGIN, cc = LUIE_CC_TYPE_STAGGER }, -- Lunge (Yaghra Strider) -- TODO: SOUND / CHECK AOE / ETC
    [105330] = { interrupt = true, priority = 2, eventdetect = true, result = ACTION_RESULT_BEGIN, duration = 1167 }, -- Frenzy (Yaghra Strider) -- TODO: SOUND / CHECK AOE / ETC

    [103804] =
    {
        interrupt = true,
        avoid = true,
        eventdetect = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        refire = 800,
        cc = LUIE_CC_TYPE_SNARE,
        duration = 1900,
    }, -- Deluge (Yaghra Strider) -- TODO: SOUND / CHECK AOE / ETC
    [103931] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1333,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Luminescent Mark (Yaghra Spewer) -- TODO: SOUND / CHECK AOE / ETC

    -- DWEMER
    [16031] =
    {
        avoid = true,
        interrupt = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        bossMatch = { Unitnames.Boss_Unstable_Construct },
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Ricochet Wave (Dwemer Sphere)
    [7520] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1267,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Steam Wall (Dwemer Sphere)
    [7544] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        bossMatch = { Unitnames.Boss_Unstable_Construct },
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Quake (Dwemer Sphere)

    [11247] =
    {
        block = true,
        dodge = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Sweeping Spin (Dwemer Centurion)
    [11246] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        refire = 2000,
        result = ACTION_RESULT_BEGIN,
        duration = 3500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Steam Breath (Dwemer Centurion)

    [20507] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 800,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    },                                                                                                       -- Double Strike (Dwemer Spider)
    -- [7717] = { block = true, avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, duration = 1600, neverShowInterrupt = true }, -- Detonation (Dwemer Spider)
    [19970] = { power = true, priority = 3, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Static Field (Dwemer Spider - Overcharge Synergy)
    -- [20207] = { interrupt = true, priority = 3, eventdetect = true }, -- Overcharge (Dwemer Spider - Overcharge Synergy)
    -- [20505] = { block = true, avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, refire = 250, duration = 2000, neverShowInterrupt = true }, -- Overcharge (Dwemer Spider - Overcharge Synergy)
    -- [20222] = { block = true, avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, refire = 250, duration = 2000, neverShowInterrupt = true }, -- Overcharge (Dwemer Spider - Overcharge Synergy)

    [64479] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1367,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Thunderbolt (Dwemer Sentry)

    [88668] =
    {
        block = true,
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Impulse Mine (Dwemer Arquebus)
    [85270] =
    {
        interrupt = true,
        priority = 3,
        refire = 1500,
        result = ACTION_RESULT_BEGIN,
        duration = 15800,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Shock Barrage (Dwemer Arquebus)
    [85319] =
    {
        avoid = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        eventdetect = true,
        sound = LUIE_ALERT_SOUND_TYPE_GROUND,
    }, -- Siege Ballista (Dwemer Arquebus)
    [85326] =
    {
        interrupt = true,
        priority = 3,
        eventdetect = true,
        refire = 1000,
        result = ACTION_RESULT_BEGIN,
        duration = 10000,
        sound = LUIE_ALERT_SOUND_TYPE_HEAL,
    }, -- Polarizing Field (Dwemer Arquebus)

    -- WORLD
    [95820] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_EFFECT_GAINED,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
        duration = 5000,
    }, -- Static Charge (Dark Anchor)

    --------------------------------------------------
    -- FRIENDLY NPC ----------------------------------
    --------------------------------------------------

    [42905] = { power = true, priority = 1, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Recover (Friendly NPC)

    --------------------------------------------------
    -- WORLD BOSSES ----------------------------------
    --------------------------------------------------

    -- World Boss - Seaside Scarp Camp
    [84048] =
    {
        avoid = true,
        priority = 1,
        auradetect = true,
        cc = LUIE_CC_TYPE_SNARE,
        fakeName = Unitnames.Boss_Quenyas,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Defiled Ground (Quenyas)
    [83776] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.Boss_Quenyas,
        refire = 1000,
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    }, -- Dark Summons (Quenyas)
    [84283] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        fakeName = Unitnames.Boss_Oskana,
        cc = LUIE_CC_TYPE_STAGGER,
        duration = 1500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Coursing Bones (Oskana)
    [84286] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Oskana,
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    }, -- -- Wake the Dead (Oskana)

    -- World Boss - Heretic's Summons
    [82934] =
    {
        summon = true,
        priority = 1,
        auradetect = true,
        neverShowInterrupt = true,
        sound = LUIE_ALERT_SOUND_TYPE_SUMMON,
    },                                                                                                     -- Shrieking Summons (Snapjaw)
    [83150] = { block = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1200 }, -- Tail Whip (Snapjaw)
    [83009] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        duration = 1500,
    }, -- Rending Leap (Snapjaw)
    [83033] =
    {
        block = true,
        dodge = true,
        bs = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.NPC_Clannfear,
        refire = 500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Focused Charge (Clannfear - Snapjaw)
    -- [83016] = { block = true, avoid = true, priority = 2, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, refire = 250, duration = 1000, effectOnlyInterrupt = true, fakeName = Unitnames.NPC_Clannfear }, -- Necrotic Explosion (Clannfear - Snapjaw)

    -- World Boss - Nindaeril's Perch
    [83515] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        cc = LUIE_CC_TYPE_STUN,
        duration = 2000,
        result = ACTION_RESULT_BEGIN,
    }, -- Hunter's Pounce (Bavura the Blizzard)
    [83832] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        cc = LUIE_CC_TYPE_STUN,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Nindaeril_the_Monsoon,
    }, -- Frenzied Charge (Nindaeril the Monsoon)
    [83548] =
    {
        interrupt = true,
        priority = 1,
        eventdetect = true,
        cc = LUIE_CC_TYPE_FEAR,
        duration = 1000,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Nindaeril_the_Monsoon,
    }, -- Mighty Roar (Nindaeril the Monsoon)

    -- World Boss - Gathongor's Mine
    [84205] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1000,
        postCast = 4000,
    }, -- Stinging Sputum (Gathongor the Mauler)
    [84196] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1100,
        eventdetect = true,
        bossName = true,
        cc = LUIE_CC_TYPE_STAGGER,
        postCast = 2500,
    }, -- Marsh Masher (Gathongor the Mauler)
    [84209] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 600,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Wrecking Jaws (Gathongor the Mauler)
    [84212] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2100,
        cc = LUIE_CC_TYPE_STUN,
        eventdetect = true,
        bossName = true,
    }, -- Bog Slam (Gathongor the Mauler)

    -- World Boss - Thodundor's View
    [83155] = { block = true, bs = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1300 }, -- Thunderous Smash (Thodundor of the Hill)
    [83160] =
    {
        block = true,
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        cc = LUIE_CC_TYPE_STAGGER,
        eventdetect = true,
        bossName = true,
    }, -- Stone Crusher (Thodundor of the Hill)
    [83136] =
    {
        block = true,
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 800,
        cc = LUIE_CC_TYPE_SNARE,
        eventdetect = true,
        bossName = true,
        postCast = 1500,
    }, -- Ground Shock (Thodundor of the Hill)

    -- World Boss - Windshriek Strand
    [84066] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 2500,
        postCast = 2500,
    }, -- Ground Shock (Skullbreaker)
    [83651] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        refire = 500,
        bossName = true,
        duration = 4500,
    },                                                                                                            -- Feral Impact (Skullbreaker)
    [84076] = { summon = true, priority = 1, eventdetect = true, result = ACTION_RESULT_BEGIN, bossName = true }, -- Carrion Call (Skullbreaker)

    -- World Boss - Big Ozur's Valley
    [83180] = { destroy = true, priority = 1, eventdetect = true, result = ACTION_RESULT_BEGIN, bossName = true }, -- Molten Pillar (Big Ozur)
    [83206] =
    {
        block = true,
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        refire = 2000,
        bossName = true,
    }, -- Molten Shackles (Ice Pillar)
    [83191] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        cc = LUIE_CC_TYPE_STUN,
        duration = 3800,
    }, -- Shaman Smash (Big Ozur)

    -- World Boss - The Wolf's Camp
    [10149] = { power = true, priority = 1, eventdetect = true, result = ACTION_RESULT_BEGIN, refire = 5000 }, -- Guards Transform (Lieutenant Bran, Annyce)

    -- World Boss - Trapjaw's Cove
    [83945] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1200,
        cc = LUIE_CC_TYPE_STUN,
        bossName = true,
    }, -- Tail Sweep (Trapjaw)
    [84028] =
    {
        interrupt = true,
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        bossName = true,
        postCast = 4000,
    }, -- Impending Storm (Trapjaw)
    [84169] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        bossName = true,
    }, -- Rolling Thunder (Trapjaw)
    [83925] =
    {
        block = true,
        dodge = true,
        reflect = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_STUN,
        duration = 1700,
    },                                                                          -- Trapping Bolt (Trapjaw)
    [83930] = { power = true, priority = 1, auradetect = true, noSelf = true }, -- Trapping Bolt (Trapjaw)

    -- World Boss - Spider Nest
    [84150] = { summon = true, priority = 1, eventdetect = true, result = ACTION_RESULT_BEGIN, bossName = true },   -- Call of the Brood (Old Widow Silk)
    [84151] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, cc = LUIE_CC_TYPE_STUN, duration = 400 }, -- Constricting Webs (Old Widow Silk)
    [84548] =
    {
        block = true,
        avoid = true,
        priority = 1,
        eventdetect = true,
        refire = 1200,
        result = ACTION_RESULT_BEGIN,
        duration = 5100,
        bossName = true,
    },                                                                                                                    -- Venom Spray (Old Widow Silk)
    -- [84159] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 100, postCast = 500 }, -- Spit Poison (Old Widow Silk)
    [84161] = { avoid = true, priority = 1, auradetect = true, refire = 10000, bossName = true, hiddenDuration = 10000 }, -- Spit Poison (Old Widow Silk)

    -- World Boss - Mudcrab Beach
    [82965] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 7233,
        bossName = true,
    }, -- Crabuchet (Titanclaw)

    -- World Boss - Valeguard Tower
    [84037] =
    {
        block = true,
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 700,
        bossName = true,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Petrifying Bellow (Menhir Stoneskin)
    [84292] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 500,
        cc = LUIE_CC_TYPE_STUN,
    },                                                                                                            -- Graven Slash (Menhir Stoneskin)
    [84014] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Awaken (Menhir Stoneskin)
    [84029] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Awaken (Menhir Stoneskin)
    [84417] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Awaken (Menhir Stoneskin)

    -- World Boss - Magdelena's Haunt
    [83922] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 500, postCast = 1500 },      -- Curse of Terror (Magdelena)
    [83880] = { power = true, priority = 1, auradetect = true, duration = 8000 },                                 -- Reflective Shadows (Magdelena)
    [83227] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Dark Resurrection (Magdelena)

    --------------------------------------------------
    -- MAIN QUEST ------------------------------------
    --------------------------------------------------

    -- MSQ Tutorial (Soul Shriven in Coldharbour)
    -- [61748] = { block = true, priority = 1}, -- Heavy Attack (Tutorial) -- Default game tutorials display regardless
    -- [61916] = { interrupt = true, priority = 1}, -- Heat Wave (Tutorial) -- Default game tutorials display regardless
    [63737] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        sound = LUIE_ALERT_SOUND_TYPE_ST,
    }, -- Heavy Attack (Tutorial)
    [63684] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2200,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Uppercut (Tutorial)
    [63761] =
    {
        block = true,
        dodge = true,
        priority = 3,
        bs = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1800,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Pound (Tutorial)
    [63752] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2750,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Vomit (Tutorial)
    [63521] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2500,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Bone Crush (Tutorial)

    -- MSQ 2 (Daughter of Giants)
    [27767] = { block = true, bs = true, dodge = true, priority = 2 },          -- Rending Leap (Ancient Clannfear)
    [28788] = { block = true, priority = 2, eventdetect = true },               -- MQ2_Boss1_Doom-Truth'sGaze (Manifestation of Terror)
    [28723] = { avoid = true, priority = 2, eventdetect = true, refire = 500 }, -- Gravity Well (Manifestation of Terror)

    -- MSQ 4 (Castle of the Worm)
    [34484] = { block = true, avoid = true, priority = 2, refire = 500 }, -- Soul Cage (Mannimarco)

    -- MSQ 6 (Halls of Torment)
    [36858] = { interrupt = true, avoid = true, priority = 2, eventdetect = true, refire = 1500 }, -- Swordstorm (Tharn Doppleganger)
    [37173] = { interrupt = true, priority = 2, eventdetect = true },                              -- Flame Shield (Duchess of Anguish)
    [38729] = { block = true, interrupt = true, priority = 2, refire = 500 },                      -- Royal Strike (Duchess of Anguish)

    -- MSQ 7 (Shadow of Sancre Tor)
    [39302] = { interrupt = true, priority = 2, eventdetect = true, refire = 1000 }, -- Necromantic Revival
    [38215] = { interrupt = true, priority = 2, refire = 1000 },                     -- Death's Gaze (Mannimarco)
    [40425] = { avoid = true, priority = 2 },                                        -- Impending Doom (Mannimarco)
    [40973] = { power = true, priority = 2, eventdetect = true },                    -- Portal Spawn (Mannimarco)
    [40978] = { power = true, priority = 2, eventdetect = true },                    -- Portal Spawn (Mannimarco)
    [40981] = { power = true, priority = 2, eventdetect = true },                    -- Portal Spawn (Mannimarco)

    --------------------------------------------------
    -- GUILD QUESTS ----------------------------------
    --------------------------------------------------

    -- The Prismatic Core
    [39577] = { block = true, interrupt = true, priority = 2 }, -- Palolel's Rage (Queen Palolel)

    -- Will of the Council
    [28939] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        refire = 2200,
        duration = 6500,
        postCast = 2000,
    }, -- Heat Wave (Sees-All-Colors)

    -- The Mad God's Bargain
    [39555] = { interrupt = true, priority = 2, eventdetect = true, refire = 1500 },         -- Summon Scamp (Haskill)
    [39527] = { interrupt = true, avoid = true, block = true, priority = 2, refire = 1500 }, -- Skeleton Trap (Haskill)
    [35533] = { interrupt = true, priority = 2, refire = 1500 },                             -- Polymorph (Haskill)
    [39391] = { interrupt = true, priority = 2, eventdetect = true, refire = 1500 },         -- Summon Pig (Haskill)

    --------------------------------------------------
    -- AD QUESTS -------------------------------------
    --------------------------------------------------

    -- Rites of the Queen
    [48921] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Norion,
    }, -- Ancestral Spirit
    [48924] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Norion,
    }, -- Ancestral Spirit
    [48927] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Norion,
    }, -- Ancestral Spirit

    -- Sever All Ties
    [44138] =
    {
        interrupt = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        fakeName = Unitnames.Boss_High_Kinlady_Estre,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Q4261 Estre Knockback (High Kinlady Estre)

    -- The Grips of Madness
    [38748] =
    {
        block = true,
        interrupt = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 3000,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Aulus's Tongue (Mayor Aulus)
    [40702] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        fakeName = Unitnames.Boss_Mayor_Aulus,
    }, -- Q4868 Aulus Knockback (Mayor Aulus)

    -- A Lasting Winter
    [38413] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Elite_General_Endare,
    }, -- Spawn Clone (General Endare)

    -- The Orrery of Elden Root
    [43820] =
    {
        dodge = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1970,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        fakeName = Unitnames.Boss_Prince_Naemon,
    },                                                                                                -- Quaking Stomp (Prince Naemon)
    [43827] = { avoid = true, priority = 2, auradetect = true, duration = 2916, eventdetect = true }, -- Projectile Vomit (Prince Naemon)

    -- Striking at the Heart
    [48491] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Prince_Naemon,
        refire = 120000,
    }, -- Q4960 Naemon Shield Shade (Shade of Naemon)
    [48498] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.Boss_Prince_Naemon,
        refire = 120000,
    }, -- Q4960 Necor Skele Rise (Shade of Naemon)

    --------------------------------------------------
    -- VVARDENFELL -----------------------------------
    --------------------------------------------------

    -- Tutorial
    -- [83416] = { block = true, priority = 1}, -- Heavy Attack (Tutorial) -- Default game tutorials display regardless
    -- [92233] = { interrupt = true, priority = 1}, -- Throw Dagger (Tutorial) -- Default game tutorials display regardless
    [92668] =
    {
        block = true,
        dodge = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2533,
        fakeName = Unitnames.NPC_Slaver_Cutthroat,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Whirlwind (Slaver Cutthroat)

    -- TODO: THE REST OF THESE NON-TUTORIAL

    -- Main Quest
    [87958] = { avoid = true, interrupt = true, priority = 2 },             -- Ash Storm (Divine Delusions)
    [90139] = { block = true, dodge = true, priority = 2, bs = true },      -- Empowered Strike (Divine Intervention)
    [87038] = { block = true, dodge = true, priority = 2, bs = true },      -- Spinning Blades (Divine Restoration)
    [87047] = { block = true, dodge = true, priority = 2, refire = 1500 },  -- Lunge (Divine Restoration)
    [87090] = { block = true, dodge = true, priority = 2 },                 -- Barbs (Divine Restoration)
    [90616] = { block = true, avoid = true, priority = 2, refire = 10000 }, -- Divine Hijack (Divine Restoration)

    -- Sidequests
    [92720] = { block = true, avoid = true, priority = 2 }, -- Necrotic Wave (Ancestral Adversity)
    [77541] = { block = true, dodge = true, priority = 2 }, -- Brand's Cleave (The Heart of a Telvanni)

    -- Delves/Public Dungeons/World
    [88427] = { block = true, dodge = true, priority = 3, bs = true, auradetect = true }, -- Charge (Kwama Worker - Matus-Akin Egg Mine)

    [86983] = { interrupt = true, priority = 2 },                                         -- Succubus Touch (Echoes of a Fallen House)
    [86930] = { block = true, dodge = true, interrupt = true, priority = 2 },             -- Volcanic Debris (The Forgotten Wastes)
    [92702] = { block = true, dodge = true, interrupt = true, priority = 2 },             -- Volcanic Debris (The Forgotten Wastes)

    [89210] = { block = true, avoid = true, priority = 3 },                               -- Boulder Toss (Nchuleftingth - Mud-Tusk)

    [86570] = { block = true, dodge = true, priority = 3 },                               -- Shield Charge (Nchuleftingth - Renduril the Hammer)
    [90597] = { block = true, avoid = true, priority = 2 },                               -- Overcharge Expulsion

    --------------------------------------------------
    -- SUMMERSET -------------------------------------
    --------------------------------------------------

    [105601] =
    {
        block = true,
        avoid = true,
        priority = 3,
        duration = 1250,
        result = ACTION_RESULT_BEGIN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Explosive Toxins (Yaghra Larva)
    [107282] =
    {
        block = true,
        dodge = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1067,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Impale (Yaghra Nightmare)
    [105867] =
    {
        avoid = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1200,
        postCast = 4000,
        cc = LUIE_CC_TYPE_SNARE,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Pustulant Explosion (Yaghra Nightmare)

    --------------------------------------------------
    -- ELSWEYR ---------------------------------------
    --------------------------------------------------

    [121475] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 1300,
        cc = LUIE_CC_TYPE_STAGGER,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Devastating Leap (Bone Flayer)
    [121473] =
    {
        block = true,
        dodge = true,
        priority = 3,
        result = ACTION_RESULT_BEGIN,
        duration = 2400,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Flurry (Bone Flayer)

    [121643] =
    {
        interrupt = true,
        avoid = true,
        priority = 3,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2800,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Defiled Ground (Euraxian Necromancer)

    [125281] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 4400,
        fakeName = Unitnames.Boss_Bahlokdaan,
        refire = 2000,
        sound = LUIE_ALERT_SOUND_TYPE_AOE,
    }, -- Sweeping Breath (Bahlokdaan)
    [125244] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1567,
        fakeName = Unitnames.Boss_Bahlokdaan,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Head Strike (Bahlokdaan)
    [125570] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1400,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Chomp (Bahlokdaan)
    [122200] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1400,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Chomp (Bahlokdaan)
    [122201] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1400,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_ST_CC,
    }, -- Chomp (Bahlokdaan)
    [125241] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1567,
        fakeName = Unitnames.Boss_Bahlokdaan,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Tail Whip (Bahlokdaan)
    [125242] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1533,
        fakeName = Unitnames.Boss_Bahlokdaan,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Wing Thrash (Bahlokdaan)
    [125243] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1533,
        fakeName = Unitnames.Boss_Bahlokdaan,
        cc = LUIE_CC_TYPE_STUN,
        sound = LUIE_ALERT_SOUND_TYPE_AOE_CC,
    }, -- Wing Thrash (Bahlokdaan)

    --------------------------------------------------
    -- GREYMOOR ---------------------------------------
    --------------------------------------------------

    [135718] =
    {
        dodge = true,
        interrupt = true,
        priority = 2,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_SNARE,
        postCast = 2300,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Frost Vines (Matron Urgala)
    [135612] =
    {
        block = true,
        avoid = true,
        interrupt = true,
        priority = 2,
        eventdetect = true,
        refire = 2000,
        cc = LUIE_CC_TYPE_SNARE,
        result = ACTION_RESULT_BEGIN,
        duration = 4500,
        sound = LUIE_ALERT_SOUND_TYPE_TRAVELER,
    }, -- Frost Wave (Matron Urgala)

    --------------------------------------------------
    -- ARENAS ----------------------------------------
    --------------------------------------------------

    -- Dragonstar Arena

    -- Stage 1
    [52729] = { power = true, priority = 1, auradetect = true },                                -- Expert Hunter (Fighters Guild Swordmaster)
    [52738] = { power = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true }, -- Ring of Preservation (Fighters Guild Gladiator)
    [82996] = { power = true, priority = 1, auradetect = true },                                -- Enrage (Fighters Guild Gladiator)

    [52746] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.Boss_Champion_Marcauld,
    }, -- Flawless Dawnbreaker (Champion Marcauld)

    -- Stage 2 - The Frozen Ring
    [53264] = { power = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true }, -- Rally (Sovngarde Slayer)
    [53313] =
    {
        avoid = true,
        interrupt = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        refire = 1500,
    }, -- Volley (Sovngarde Slayer)

    [53286] =
    {
        interrupt = true,
        block = true,
        dodge = true,
        reflect = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
    },                                                                                                            -- Crushing Shock (Sovngarde Icemage)
    [53274] = { avoid = true, priority = 1, auradetect = true, bossMatch = { Unitnames.Boss_Katti_Ice_Turner } }, -- Unstable Wall of Frost (Sovngarde Icemage)

    [53250] = { block = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN },                         -- Wrecking Blow (Yavni Frost-Skin)
    [53301] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossMatch = { Unitnames.Boss_Katti_Ice_Turner },
    }, -- Icy Pulsar (Katti Ice-Turner)

    -- Stage 3 - The Marsh
    [8244] = { block = true, bs = true, dodge = true, priority = 3, result = ACTION_RESULT_BEGIN },     -- Devastate (Corprus Husk)
    [8247] = { block = true, dodge = true, priority = 3, result = ACTION_RESULT_BEGIN, refire = 1750 }, -- Vomit (Corprus Husk)
    -- [22109] = { avoid = true, priority = 3, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, refire = 250 }, -- Contaminate (Corprus Husk)

    [83493] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, refire = 1000 }, -- CLST - Poison Cloud (Poison Cloud)

    [56796] = { power = true, priority = 1, auradetect = true },                                               -- Bound Aegis (Dragonclaw Hedge Wizard)

    [53613] = { power = true, priority = 1, auradetect = true },                                               -- Thundering Presence (Nak'tah)
    [53624] = { avoid = true, priority = 1, auradetect = true, bossMatch = { Unitnames.Boss_Nak_tah } },       -- Lightning Flood (Nak'tah)
    [53659] = { block = true, avoid = true, interrupt = true, priority = 1, auradetect = true },               -- Power Overload Heavy Attack (Nak'tah)

    -- Stage 4 - The Slave Pit
    [54160] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        refire = 750,
        eventdetect = true,
        fakeName = Unitnames.NPC_House_Dres_Slaver,
    },                                                                                                                -- Berserker Frenzy (House Dres Slaver)
    [83774] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, refire = 750 },                             -- Enslavement (House Dres Slaver)

    [54056] = { power = true, priority = 1, auradetect = true, refire = 500 },                                        -- Molten Armaments (Earthen Heart Knight)
    [54065] = { power = true, priority = 1, auradetect = true, ignoreRefresh = true },                                -- Igneous Shield (Earthen Heart Knight)
    [54077] = { avoid = true, priority = 1, auradetect = true, bossMatch = { Unitnames.Boss_Earthen_Heart_Knight } }, -- Cinder Storm (Earthen Heart Knight)
    [54053] = { block = true, dodge = true, reflect = true, priority = 1, result = ACTION_RESULT_BEGIN },             -- Stone Giant (Earthen Heart Knight)
    [54083] = { power = true, priority = 1, auradetect = true },                                                      -- Corrosive Armor (Earthen Heart Knight)
    [54067] = { block = true, interrupt = true, priority = 1, result = ACTION_RESULT_BEGIN },                         -- Fossilize (Earth Heart Knight)

    -- Stage 5 - The Celestial Ring
    [54411] =
    {
        power = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.NPC_Anka_Ra_Shadowcaster,
    }, -- Celestial Blast (Anka-Ra Shadowcaster)
    [54404] =
    {
        unmit = true,
        priority = 1,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.NPC_Anka_Ra_Shadowcaster,
    },                                                                            -- Celestial Blast (Anka-Ra Shadowcaster)
    [52897] = { avoid = true, priority = 1, auradetect = true, bossName = true }, -- Standard of Might (Anal'a Tu'wha)
    [52891] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        bossMatch = { Unitnames.Boss_Anala_tuwha },
    }, -- Flames of Oblivion (Anal'a Tu'wha)

    -- Stage 6 - The Grove
    [54608] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN },               -- Drain Resource (Pacthunter Ranger)
    -- [54512] = { power = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true }, -- Regeneration Aura (Nature's Blessing)
    [52820] = { block = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN }, -- Acid Spray (Pishna Longshot)
    [52825] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        reflect = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
    }, -- Lethal Arrow (Pishna Longshot)

    -- Stage 7 - Circle of Rituals
    [56946] = { power = true, priority = 1, auradetect = true },                                            -- Dragon Fire Scale (Bloodwraith Kynval)
    [54634] = { summon = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, auradetect = true },     -- CLDA - Sacrifice (Daedric Sacrifice)
    [54635] = { summon = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, auradetect = true },     -- CLDA - Sacrifice (Daedric Sacrifice)
    [54612] = { summon = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, auradetect = true },     -- CLDA - Sacrifice (Daedric Sacrifice)

    [52907] = { block = true, dodge = true, interrupt = true, priority = 1, result = ACTION_RESULT_BEGIN }, -- Dark Flare (Shadow Knight)
    [52912] = { interrupt = true, priority = 1, result = ACTION_RESULT_BEGIN },                             -- Purifying Light (Shadow Knight)
    [52927] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.Boss_Shadow_Knight,
        bossMatch = { Unitnames.Boss_Hiath_the_Battlemaster },
    }, -- Solar Disturbance (Shadow Knight)

    [54792] =
    {
        block = true,
        dodge = true,
        interrupt = true,
        reflect = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
    }, -- Crystal Blast (Dark Mage)
    [54819] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        bossMatch = { Unitnames.Boss_Dark_Mage },
    }, -- Daedric Minefield (Dark Mage)
    [54829] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.Boss_Dark_Mage,
        bossMatch = { Unitnames.Boss_Hiath_the_Battlemaster },
    },                                                               -- Suppression Field (Dark Mage)
    [54809] = { interrupt = true, priority = 1, auradetect = true }, -- Dark Deal (Dark Mage)

    -- Stage 8 - Steamworks
    [54841] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN },                                            -- Ice Charge (Dwarven Ice Centurion)
    [56065] = { avoid = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, noSelf = true }, -- Ice Charge (Dwarven Ice Centurion)
    [72180] =
    {
        avoid = true,
        interrupt = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.NPC_Dwarven_Sphere,
    },                                                                              -- Electric Wave (Dwarven Sphere)

    [52773] = { block = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED }, -- Ice Comet (Mavus Talnarith)
    [52765] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_EFFECT_GAINED,
        eventdetect = true,
        fakeName = Unitnames.Boss_Mavus_Talnarith,
    }, -- Volcanic Rune (Mavus Talnarith)

    -- Stage 9 - Crypts of the Lost
    [56985] = { power = true, priority = 1, auradetect = true }, -- Spirit Shield (Zakael/Rubyn Jonnicent)
    [55089] = { avoid = true, priority = 1, auradetect = true }, -- Poison Mist (Vampire Lord Thisa)
    [55090] = { avoid = true, priority = 1, auradetect = true }, -- Devouring Swarm (Vampire Lord Thisa)
    [55081] =
    {
        interrupt = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        noSelf = true,
        fakeName = Unitnames.Boss_Vampire_Lord_Thisa,
    },                                                                                        -- Vampire Lord Thisa

    [55479] = { block = true, interrupt = true, priority = 1, result = ACTION_RESULT_BEGIN }, -- Malefic Wreath (Hiath the Battlemaster)
    [55496] = { power = true, priority = 1, auradetect = true },                              -- Power Extraction (Hiath the Battlemaster)
    [55174] = { unmit = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED },           -- Marked for Death (Hiath the Battlemaster)

    -- Maelstrom Arena

    -- Stage 1 - Vale of the Surreal
    [70892] = { avoid = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, bossName = true }, -- Bone Cage (Maxus the Many)
    [72148] = { avoid = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, bossName = true }, -- Bone Cage (Maxus the Many)
    [67765] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true },        -- Multiply (Maxus the Many)
    [67656] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true },        -- Multiply (Maxus the Many)
    [69515] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true },        -- Multiply (Maxus the Many)
    [67691] = { power = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true },         -- Reunite (Maxus the Many)

    -- Stage 2 - Seht's Balcony
    -- [71047] = { block = true, avoid = true, priority = 3, result = ACTION_RESULT_BEGIN }, -- Thunderbolt (Clockwork Sentry)
    [72067] = { power = true, priority = 2, auradetect = true }, -- Energizing (Clockwork Sentry)
    [69364] = { avoid = true, priority = 1, auradetect = true }, -- Barrage Function (Centurion Champion)
    [66904] = { power = true, priority = 1, auradetect = true }, -- Full Defense (Centurion Champion)

    -- Stage 3 - The Drome of Toxic Shock
    [67635] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN },         -- Shock Water (Lamia Queen)
    [73879] = { avoid = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED }, -- Lightning X (Lamia Queen)
    [67757] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN },         -- Queen's Poison (Lamia Queen)
    [68357] = { power = true, priority = 1, auradetect = true },                    -- Queen's Radiance (Lamia Queen)
    [73876] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        refire = 1000,
    }, -- Piercing Shriek (Lamia Queen)

    -- Stage 4 - Seht's Flywheel
    [71045] = { power = true, priority = 1, auradetect = true },                       -- Turret Mode (Clockwork Sentry)
    [71050] = { power = true, priority = 1, auradetect = true, ignoreRefresh = true }, -- Static Shield (Clockwork Sentry)
    [73850] = { power = true, priority = 1, auradetect = true, ignoreRefresh = true }, -- Static Shield (Clockwork Sentry)
    [69268] = { power = true, priority = 1, auradetect = true },                       -- Enrage (Achelir)

    [72157] =
    {
        power = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.NPC_Dwarven_Spider,
    }, -- Static Field (Dwarven Spider)
    [72166] =
    {
        block = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        refire = 250,
        neverShowInterrupt = true,
    }, -- Overcharge (Dwarven Spider)
    [72174] =
    {
        block = true,
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        refire = 250,
        neverShowInterrupt = true,
    },                                                                                              -- Overcharge (Dwarven Spider)

    [68524] = { power = true, priority = 1, auradetect = true },                                    -- Overcharged (The Control Guardian)
    [68539] = { power = true, priority = 1, auradetect = true },                                    -- Overheated (The Control Guardian)
    [68558] = { avoid = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, refire = 20000 }, -- Overheated Volley (The Control Guardian)

    [72195] = { block = true, dodge = true, priority = 2, result = ACTION_RESULT_BEGIN },           -- Thunder Hammer (Scavenger Thunder-Smith)
    [72198] = { block = true, dodge = true, priority = 2, result = ACTION_RESULT_BEGIN },           -- Wrecking Blow (Scavenger Thunder-Smith)
    [72202] =
    {
        avoid = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.NPC_Scavenger_Thunder_Smith,
    }, -- Overcharge (Scavenger Thunder-Smith)

    -- Stage 5 - Rink of Frozen Blood

    [70898] = { summon = true, priority = 2, auradetect = true, fakeName = "" },                                 -- Call Ally (Huntsman Chillbane)
    [71939] = { block = true, avoid = true, priority = 2, result = ACTION_RESULT_BEGIN },                        -- Frost Breath (Huntsman Chillbane)
    [71937] = { block = true, avoid = true, priority = 2, result = ACTION_RESULT_BEGIN },                        -- Frost Nova (Huntsman Chillbane)

    [72446] = { interrupt = true, priority = 1, auradetect = true },                                             -- Smash Iceberg (Troll Breaker)
    [71926] = { block = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN },                        -- Frenzy of Blows (Angirgoth)

    [72438] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN },                                      -- Shatter (Giant)
    [68439] = { power = true, priority = 1, auradetect = true },                                                 -- Enrage (Aki/Vigi)
    [74130] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Intimidating Roar (Aki/Vigi)

    [66378] = { block = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN },                        -- Sweep (Matriarch Runa)
    [72749] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Freezing Stomp (Matriarch Runa)
    [67088] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Intimidating Roar (Matriarch Runa)
    [66325] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN },                                      -- Shatter (Matriarch Runa)
    [72409] = { avoid = true, priority = 1, auradetect = true },                                                 -- Taunt (Matriarch Runa)

    --------------------------------------------------
    -- DUNGEONS --------------------------------------
    --------------------------------------------------

    -- Banished Cells I
    [19028] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, refire = 1500, duration = 5050 }, -- Drain Essence (Cell Haunter)
    [47587] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 3000,
        cc = LUIE_CC_TYPE_STUN,
    },                                                                             -- Tail Smite (Shadowrend)
    [21886] = { summon = true, priority = 1, auradetect = true, bossName = true }, -- Summon Dark Proxy (Shadowrend)
    [18772] =
    {
        interrupt = true,
        priority = 1,
        auradetect = true,
        fakeName = "",
        duration = 3000,
        effectOnlyInterrupt = true,
        noSelf = true,
    },                                                                             -- Feeding (Shadowrend)
    [18708] = { summon = true, priority = 1, auradetect = true, bossName = true }, -- Summon Clannfear (Angata the Clannfear Handler)
    [19025] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1500,
        postCast = 4000,
    }, -- Dead Zone (Skeletal Destroyer)

    [33189] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        duration = 2000,
    }, -- Crushing Blow (High Kinlord Rilis)
    [18840] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        hiddenDuration = 750,
    }, -- Soul Blast (High Kinlord Rilis)
    [18875] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        refire = 1500,
        eventdetect = true,
        bossName = true,
        duration = 2600,
        postCast = 5000,
    }, -- Daedric Tempest (High Kinlord Rilis)
    [18795] =
    {
        destroy = true,
        priority = 1,
        result = ACTION_RESULT_EFFECT_GAINED,
        eventdetect = true,
        bossName = true,
        refire = 1000,
    }, -- CON_Invisible_30%_Speed_Debuff (The Feast)

    -- Banished Cells II
    [48271] =
    {
        block = true,
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        refire = 2500,
        bossName = true,
        duration = 4000,
    }, -- Breath of Flame (Maw of the Infernal)
    [27826] =
    {
        block = true,
        bs = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Crushing Blow (Keeper Voranil)
    [29018] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        refire = 750,
        eventdetect = true,
        bossName = true,
        duration = 3550,
    },                                                                                                     -- Berserker Frenzy (Keeper Voranil)
    [28750] = { block = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1750 }, -- Essence Siphon (Keeper Voranil)

    [32038] = { power = true, priority = 1, auradetect = true, hiddenDuration = 2500 },                    -- Into Portal
    [36631] = { power = true, priority = 1, auradetect = true, bossName = true, hiddenDuration = 2500 },   -- ExitPortal

    [29143] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 2000,
    },                                                                                                  -- Daedric Blast (Keeper Imiril)
    [28962] = { power = true, priority = 1, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED }, -- Sister's Love (Sister Sihna / Sister Vera)
    [48799] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        refire = 1500,
        bossName = true,
        duration = 1000,
        postCast = 5000,
    }, -- Daedric Tempest (High Kinlord Rilis)
    [48814] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        refire = 1500,
        bossName = true,
        duration = 1000,
        postCast = 5000,
    },                                                                                       -- Daedric Tempest (High Kinlord Rilis)
    [28570] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1000 }, -- Levitate (High Kinlord Rilis)
    [28462] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1000 }, -- Levitate (High Kinlord Rilis)
    [46967] = { power = true, priority = 1, auradetect = true, hiddenDuration = 2500 },      -- Daedric Step (High Kinlord Rilis)
    [88070] =
    {
        summon = true,
        priority = 1,
        auradetect = true,
        fakeName = "",
        refire = 5000,
        bossMatch = { Unitnames.Boss_High_Kinlord_Rilis },
        hideIfNoSource = true,
    }, -- Creeping Doom (Harvester)

    -- Elden Hollow I
    [16834] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STUN,
    },                                                                                                    -- Executioner's Strike (Akash gra-Mal)
    [15999] = { block = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 750 }, -- Leaping Strike (Akash gra-Mal)
    [16016] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 3550,
    },                                                                                                            -- Berserker Frenzy (Akash gra-Mal)

    [9910] = { destroy = true, priority = 1, eventdetect = true, result = ACTION_RESULT_BEGIN, bossName = true }, -- Summon Saplings (Chokethorn)
    [9930] =
    {
        interrupt = true,
        priority = 1,
        auradetect = true,
        fakeName = Unitnames.NPC_Strangler_Saplings,
        effectOnlyInterrupt = true,
        alwaysShowInterrupt = true,
    }, -- Heal Spores (Chokethorn)
    [9875] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 2000,
        cc = LUIE_CC_TYPE_STAGGER,
        neverShowInterrupt = true,
    }, -- Fungal Burst (Chokethorn)

    [44223] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.Boss_Leafseether,
        cc = LUIE_CC_TYPE_STAGGER,
        duration = 1750,
    },                                                                                                                 -- Inhale (Leafseether)

    [9845] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 2000, neverShowInterrupt = true }, -- Rotting Bolt (Canonreeve Oraneth)
    [16262] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        cc = LUIE_CC_TYPE_STUN,
        duration = 2000,
        postCast = 6000,
    }, -- Necrotic Circle (Canonreeve Oraneth)
    [9944] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 3000,
        cc = LUIE_CC_TYPE_STUN,
    },                                                                                -- Necrotic Burst (Canonreeve Oraneth)
    [9839] = { power = true, priority = 1, auradetect = true, ignoreRefresh = true }, -- Bone Hurricane (Canonreeve Oraneth)
    [25820] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        bossName = true,
        refire = 5000,
    }, -- Necrotic Circle (Canonreeve Oraneth)

    -- Elden Hollow II
    [34376] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        refire = 2000,
        result = ACTION_RESULT_BEGIN,
        duration = 3300,
        bossName = true,
        cc = LUIE_CC_TYPE_FEAR,
    },                                                                                                                    -- Flame Geyser (Dubroze the Infestor)
    [32707] = { summon = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, bossName = true }, -- Summon Guardians (Dark Root)
    [33334] =
    {
        interrupt = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.NPC_Frenzied_Guardian,
        hiddenDuration = 1800,
        alwaysShowInterrupt = true,
    }, -- Latch On Stamina (Frenzied Guardian)
    [33337] =
    {
        interrupt = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.NPC_Mystic_Guardian,
        hiddenDuration = 1800,
        alwaysShowInterrupt = true,
    },                                                                                                                   -- Latch On Magicka (Mystic Guardian)
    [32890] = { power = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, bossName = true }, -- Gleaming Light (Dark Root)
    [33533] = { power = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, bossName = true }, -- Glaring Light (Dark Root)
    [33535] = { power = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, bossName = true }, -- Brightening Light (Dark Root)

    [33170] = { destroy = true, priority = 1, auradetect = true, bossName = true },                                      -- Hate (Shadow Tendril)

    [33052] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 900 },                              -- Shadow Stomp (Murklight)
    [32832] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        refire = 1750,
        bossName = true,
        duration = 4700,
        postCast = 4000,
        neverShowInterrupt = true,
    }, -- Consuming Shadow (Murklight)
    [32975] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 2000,
        postCast = 4000,
        neverShowInterrupt = true,
    }, -- Eclipse (Murklight)

    [33102] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        refire = 1250,
        bossName = true,
        duration = 5000,
        postCast = 4000,
    }, -- Spout Shadow (The Shadow Guard)

    [33432] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 4300,
        postCast = 4000,
    }, -- Daedric Flame (Bogdan the Nightflame)
    [33480] =
    {
        unmit = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1500,
    }, -- Pulverize (Bogdan the Nightflame)
    [33492] =
    {
        unmit = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1500,
    }, -- Pulverize (Bogdan the Nightflame)
    [33494] =
    {
        unmit = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1500,
    }, -- Pulverize (Bogdan the Nightflame)
    [34260] =
    {
        destroy = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        bossName = true,
        refire = 1000,
    }, -- Shadow (Nova Tendril)

    -- City of Ash I
    [31101] =
    {
        block = true,
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1200,
    }, -- Cleave (Golor the Banekin Handler)
    [25034] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        sound = LUIE_ALERT_SOUND_TYPE_POWER_ATTACK,
    },                                                                                                                    -- Crushing Blow (Golor the Banekin Handler)
    [33604] = { summon = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, bossName = true }, -- Summon Banekin (Golor the Banekin Handler)

    [34607] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                                  -- Measured Uppercut (Warden of the Shrine)
    [34654] = { avoid = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, auradetect = true, bossName = true }, -- Fan of Flames (Warden of the Shrine)
    [34620] = { avoid = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, auradetect = true, bossName = true }, -- Fan of Flames (Warden of the Shrine)

    [34190] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 550, cc = LUIE_CC_TYPE_STAGGER },  -- Thorny Backhand (Infernal Guardian)
    [34189] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 2000,
        cc = LUIE_CC_TYPE_STAGGER,
    }, -- Ground Slam (Infernal Guardian)
    [35061] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 8000,
    }, -- Consuming Fire (Infernal Guardian)
    [34183] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 800,
        cc = LUIE_CC_TYPE_STAGGER,
        postCast = 2000,
    }, -- Tunneling Roots (Infernal Guardian)

    [44278] =
    {
        block = true,
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_EFFECT_GAINED,
        duration = 2000,
        spreadOut = true,
    },                                                                                                           -- Lava Geyser (Dark Ember)

    [34198] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Burning Field (Rothariel Flameheart)
    [34205] = { power = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, auradetect = true },           -- Deception (Rothariel Flameheart)

    [34901] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1500 },                     -- Blazing Arrow (Razor Master Erthas)
    [34805] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN },                                      -- Release Flame (Razor Master Erthas)
    [34623] = { summon = true, priority = 1, auradetect = true, bossName = true },                               -- Summon Flame Atronach (Razor Master Erthas)
    [34780] = { summon = true, priority = 1, auradetect = true, bossName = true },                               -- Summon Flame Atranach (Razor Master Erthas)
    [34892] =
    {
        power = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        hiddenDuration = 2500,
        bossName = true,
    }, -- Body of Flame (Razor Master Erthas)

    -- City of Ash II
    [53999] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.Boss_Rukhan,
    }, -- Summon (Flame Atronach)
    [54021] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossMatch = { Unitnames.Boss_Marruz },
    },                                                                                       -- Release Flame (Marruz)
    [53976] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1500 }, -- Blazing Arrow (Marruz)
    [54025] =
    {
        interrupt = true,
        priority = 1,
        auradetect = true,
        fakeName = Unitnames.Boss_Akezel,
        duration = 7000,
        effectOnlyInterrupt = true,
    }, -- Spell Absorption (Akezel)
    [53994] =
    {
        interrupt = true,
        priority = 1,
        eventdetect = true,
        fakeName = Unitnames.Boss_Akezel,
        result = ACTION_RESULT_BEGIN,
        duration = 3000,
    }, -- Focused Healing (Akezel)
    [54096] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.Boss_Rukhan,
        duration = 2500,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Pyrocasm (Rukhan)

    [56811] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2500,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Pyrocasm (Xivilai Ravager)

    [56414] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_EFFECT_GAINED,
        eventdetect = true,
        duration = 1000,
        postCast = 3000,
        bossName = true,
    },                                                                                                            -- Fire Runes (Urata the Legion)
    [54225] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Multiply (Urata the Legion)
    [56098] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Multiply (Urata the Legion)
    [56104] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Multiply (Urata the Legion)
    [56131] =
    {
        power = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 8000,
    }, -- Reunite (Urata the Legion)

    [56186] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.NPC_Flame_Colossus,
    }, -- Voice to Wake the Dead (Bone Colossus)

    [55203] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 850,
        cc = LUIE_CC_TYPE_STAGGER,
        neverShowInterrupt = true,
        postCast = 2500,
    }, -- Seismic Tremor (Horvantud the Fire Maw)
    [56002] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 13500,
        neverShowInterrupt = true,
    }, -- Ground Quake (Horvantud the Fire Maw)
    [55312] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 4200,
        neverShowInterrupt = true,
    }, -- Slag Breath (Horvantud the Fire Maw)
    [55333] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 3000,
        neverShowInterrupt = true,
    }, -- Fiery Breath (Horvantud the Fire Maw)
    [55320] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 4200,
        neverShowInterrupt = true,
    }, -- Fiery Breath (Horvantud the Fire Maw)
    [55335] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 3000,
        neverShowInterrupt = true,
    }, -- Fiery Breath (Horvantud the Fire Maw)
    [55326] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 4200,
        neverShowInterrupt = true,
    }, -- Fiery Breath (Horvantud the Fire Maw)
    [55337] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 3000,
        neverShowInterrupt = true,
    },                                                                                 -- Fiery Breath (Horvantud the Fire Maw)
    [57618] = { power = true, priority = 1, auradetect = true, ignoreRefresh = true }, -- Damage Shield (Horvantud the Fire Maw)
    [55315] = { power = true, priority = 1, auradetect = true },                       -- Slag Breath (Horvantud the Fire Maw)
    [55324] = { power = true, priority = 1, auradetect = true },                       -- Enrage 2 (Horvantud the Fire Maw)
    [55329] = { power = true, priority = 1, auradetect = true },                       -- Enrage 3 (Horvantud the Fire Maw)

    [54218] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 1500,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        neverShowInterrupt = true,
    }, -- Monstrous Cleave (Ash Titan)
    [54895] =
    {
        block = true,
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 7700,
    }, -- Molten Rain (Ash Titan)
    [54698] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 3000,
        cc = LUIE_CC_TYPE_STUN,
        postCast = 4000,
        neverShowInterrupt = true,
    },                                                                                                                    -- Fire Swarm (Ash Titan)

    [58468] = { power = true, auradetect = true, priority = 1 },                                                          -- Shadow Cloak (Ash Titan)
    [54783] = { power = true, auradetect = true, priority = 1 },                                                          -- Air Atronach Flame (Air Atronach)
    [54366] = { avoid = true, priority = 1, auradetect = true, duration = 15000, effectOnlyInterrupt = true },            -- Flame Tornado (Air Atronach)
    [60683] = { power = true, priority = 1, auradetect = true, ignoreRefresh = true },                                    -- Flame Tornado (Air Atronach)

    [58280] = { summon = true, priority = 1, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, bossName = true }, -- Scary Summon 1 (Xivilai Fulminator / Boltaic)
    [56601] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        bossName = true,
        refire = 2000,
    }, -- Scary Summon 2 (Xivilai Fulminator / Boltaic)

    [55513] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Flame Bolt (Valkyn Skoria)
    [55387] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1600,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Meteor Strike (Valkyn Skoria)
    [55514] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1250,
        postCast = 4000,
    },                                                                                                               -- Call the Flames (Valkyn Skoria)
    [55426] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 2000, cc = LUIE_CC_TYPE_STUN }, -- Magma Prison (Valkyn Skoria)
    [55024] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 3000,
        cc = LUIE_CC_TYPE_STAGGER,
    },                                                                                 -- Lava Quake (Valkyn Skoria)
    [55500] = { power = true, priority = 1, auradetect = true, ignoreRefresh = true }, -- Rock Shield (Valkyn Skoria)
    [55623] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        bossName = true,
        refire = 5000,
    }, -- Flame Atronach (Valkyn Skoria)
    [55059] =
    {
        power = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        hiddenDuration = 2500,
        bossName = true,
    }, -- Body of Flame (Valkyn Skoria)

    -- Tempest Island
    [46732] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        refire = 1000,
        duration = 2300,
        cc = LUIE_CC_TYPE_STAGGER,
    }, -- Sonic Scream (Sonolia the Matriarch)

    [26370] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                                    -- Slash (Valaran Stormcaller)
    [26628] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1500, cc = LUIE_CC_TYPE_STUN },      -- Enervating Bolt (Valaran Stormcaller)
    [26592] = { summon = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, bossName = true }, -- Lightning Avatar (Valaran Stormcaller)

    [6106] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1867,
        postCast = 4000,
        cc = LUIE_CC_TYPE_SNARE,
    }, -- Lightning Storm (Yalorasse the Speaker)

    [26748] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        refire = 1000,
        duration = 5100,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Enervating Stone (Stormfist)
    [26714] =
    {
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                            -- Skyward Slam (Stormfist)
    [26833] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Summon Storm Atronach (Stormfist)
    [26790] =
    {
        power = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        refire = 60000,
    }, -- Unstable Explosion (Stormfist)

    [27039] =
    {
        interrupt = true,
        priority = 1,
        auradetect = true,
        bossName = true,
        effectOnlyInterrupt = true,
        cc = LUIE_CC_TYPE_STUN,
        duration = 7500,
        noSelf = true,
    },                                                                                       -- Ethereal Chain (Commodore Ohmanil)

    [27596] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1483 }, -- Lightning Strike (Stormreeve Neider)
    [26741] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        hiddenDuration = 1000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Swift Wind (Stormreeve Neider)
    [26712] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 3000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Gust of Wind (Stormreeve Neider)

    -- Selene's Web
    [30909] =
    {
        unmit = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        refire = 2000,
        bossName = true,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        duration = 5600,
    }, -- Ensnare (Treethane Kerninn)
    [30907] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 6200,
    },                                                           -- Summon Primal Swarm (Treethane Kerninn)

    [30781] = { power = true, priority = 1, auradetect = true }, -- Mirror Ward (Longclaw)
    [30772] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        refire = 1250,
        duration = 8000,
        neverShowInterrupt = true,
    },                                                                                         -- Arrow Rain (Longclaw)
    [30779] = { summon = true, priority = 1, auradetect = true, refire = 500, fakeName = "" }, -- Spirit Form (Senche Spirit)
    [31096] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 600,
        postCast = 4000,
        cc = LUIE_CC_TYPE_STUN,
    },                                                                                                       -- Poison Burst (Longclaw)

    [31202] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 400, postCast = 1000 }, -- Venomous Burst (Queen Aklayah)
    [31205] = { power = true, priority = 1, auradetect = true, duration = 6000, noSelf = true },             -- Venomous Burst (Queen Aklayah)

    [30996] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1800,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Vicious Maul (Foulhide)
    [30812] =
    {
        avoid = true,
        block = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 2250,
        postCast = 2000,
        cc = LUIE_CC_TYPE_STUN,
    },                                                                                                                    -- Trampling Charge (Foulhide)
    [31002] = { summon = true, priority = 1, auradetect = true, fakeName = "", refire = 5000 },                           -- Intro (Selene's Rose)

    [31241] = { summon = true, priority = 1, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, bossName = true }, -- Summon Spiders (Mennir Many-Legs)

    [31048] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, cc = LUIE_CC_TYPE_STUN, duration = 400 },       -- Web Wrap (Selene)
    [31052] =
    {
        power = true,
        priority = 1,
        auradetect = true,
        duration = 30000,
        effectOnlyInterrupt = true,
        noSelf = true,
    },                                                                                                                  -- Web Wrap (Selene)
    [30731] = { block = true, dodge = true, priority = 1, auradetect = true, cc = LUIE_CC_TYPE_STUN, duration = 2150 }, -- Summon Primal Spirit (Selene)
    [30896] =
    {
        dodge = true,
        priority = 1,
        auradetect = true,
        bossName = true,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        hiddenDuration = 1900,
    },                                                                                                   -- Summon Senche Spirit (Selene)

    [31986] = { summon = true, priority = 1, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED }, -- Summon Melee (Selene)
    [31984] = { summon = true, priority = 1, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED }, -- Summon Healer (Selene)
    [31985] = { summon = true, priority = 1, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED }, -- Summon Archer (Selene)

    -- Spindleclutch I
    [46147] = { summon = true, priority = 1, eventdetect = true, result = ACTION_RESULT_BEGIN, bossName = true }, -- Summon Swarm (Spindlekin)

    [22034] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                                   -- Inject Poison (Swarm Mother)
    [17964] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, cc = LUIE_CC_TYPE_SNARE }, -- Impeding Webs (Swarm Mother)
    [17960] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        postCast = 500,
    }, -- Arachnid Leap (Swarm Mother)
    [18559] =
    {
        summon = true,
        priority = 1,
        result = ACTION_RESULT_EFFECT_GAINED,
        eventdetect = true,
        refire = 1000,
        bossName = true,
    }, -- Spawn Broodling (Swarm Mother)

    [18111] =
    {
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        duration = 1500,
        postCast = 500,
    },                                                                                       -- Arachnophobia (Swarm Mother)
    [18078] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1200 }, -- Web Blast (Swarm Mother)
    [35572] =
    {
        unmit = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        duration = 1200,
    }, -- Grappling Web (Swarm Mother)
    [18058] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        duration = 2500,
    }, -- Daedric Explosion (Swarm Mother)

    -- Spindleclutch II
    [28093] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Vicious Smash (Blood Spawn)
    [27995] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 2350,
    }, -- Cave-In (Blood Spawn)
    [47331] =
    {
        unmit = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        refire = 60000,
    }, -- Cave-In (Blood Spawn)
    [47198] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        auradetect = true,
        refire = 5000,
        fakeName = "",
    },                                                                                                            -- Falling Rocks (Cave In)

    [28438] = { summon = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Dummy (Praxin Douare)
    [18036] =
    {
        block = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.NPC_The_Whisperer_Nightmare,
        refire = 2500,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Grappling Web (The Whisperer Nightmare)

    [27965] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1200,
        postCast = 3000,
    },                                                                                       -- Despair (Praxin Douare)
    [27741] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1500 }, -- Enervating Seal (Praxin Douare)
    [27703] =
    {
        unmit = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2500,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                 -- Harrowing Ring (Praxin Douare)
    [61443] = { power = true, priority = 1, auradetect = true, noSelf = true },                        -- Harrowing Ring (Praxin Douare)

    [27435] = { power = true, priority = 1, auradetect = true },                                       -- Monstrous Growth (Flesh Atronach)
    [27437] = { power = true, priority = 1, auradetect = true },                                       -- Monstrous Growth (Flesh Atronach)

    [27600] = { avoid = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, auradetect = true }, -- Blood Pool (Urvan Veleth)

    [27905] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 1500,
        postCast = 4000,
    },                                                                                       -- Blood Pool (Vorenor Winterbourne)
    [27897] = { unmit = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 2000 }, -- Open Wounds (Vorenor Winterbourne)
    [27791] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 2000,
    }, -- Blood Frenzy (Vorenor Winterbourne)

    [31672] =
    {
        power = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        refire = 2500,
    }, -- Thrall Feast (Vorenor Winterbourne)

    -- Wayrest Sewers I
    [34846] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Primal Sweep (Slimecraw)

    [9441] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                           -- Dark Lance (Investigator Garron)
    [25593] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true, bossName = true }, -- Summon Necrotic Orb (Investigator Garron)
    [9740] = { summon = true, priority = 1, auradetect = true, bossName = true },                                -- Tormented Summoning (Restless Soul)

    [25548] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Smite (Varaine Pellingare)
    [9648] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 2000,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Spinning Cleave (Varaine Pellingare)
    [36435] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 733,
        postCast = 1000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                      -- Tidal Slash (Varaine Pellingare)
    [9656] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 500, postCast = 1000 }, -- Poisoned Blade (Varaine Pellingare)

    [11752] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                           -- Penetrating Daggers (Allene Pellingare)
    [35006] = { power = true, priority = 1, auradetect = true }, -- Hallucinogenic Fumes (Allene Pellingare)
    [35021] = { power = true, priority = 1, auradetect = true }, -- Mind-Bending Mist (Allene Pellingare)
    [35041] = { power = true, priority = 1, auradetect = true }, -- Mind-Bending Mist (Allene Pellingare)

    -- Wayrest Sewers II
    [36613] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 3000,
        postCast = 4000,
        cc = LUIE_CC_TYPE_SNARE,
        fakeName = Unitnames.Boss_Malubeth_the_Scourger,
    },                                                                                                                 -- Scourging Spark (Malubeth the Scourger)
    [36431] = { power = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, noSelf = true }, -- Rend Soul (Malubeth the Scourger)

    [36951] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Skull_Reaper,
    }, -- Voice to Wake the Dead (Bone Colossus)
    [48773] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.NPC_Risen_Dead,
        refire = 1000,
        duration = 1500,
    }, -- Necromantic Burst (Risen Dead)

    [36904] =
    {
        block = true,
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Garron_the_Returned,
        duration = 5300,
    }, -- Necrotic Barrage (Garron the Returned)
    [36761] =
    {
        block = true,
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Garron_the_Returned,
        cc = LUIE_CC_TYPE_STAGGER,
        duration = 2700,
    }, -- Necrotic Barrage (Garron the Returned)
    [36780] =
    {
        summon = true,
        priority = 1,
        auradetect = true,
        fakeName = Unitnames.Boss_Garron_the_Returned,
        refire = 2000,
    }, -- Summon Minion (Garron the Returned)
    [36838] =
    {
        power = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Garron_the_Returned,
        hiddenDuration = 2500,
    }, -- Deceptive Teleport (Garron the Returned)
    [36873] =
    {
        block = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Garron_the_Returned,
        duration = 9000,
        refire = 10000,
    }, -- Consume Life (Garron the Returned)

    [36895] =
    {
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_The_Forgotten_One,
        duration = 1000,
        postCast = 3500,
    }, -- Haunting Spectre (The Forgotten One)

    [49159] =
    {
        block = true,
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 100,
        postCast = 900,
        eventdetect = true,
        bossMatch = { Unitnames.Boss_Varaine_Pellingare },
    }, -- Cone of Rot (Varaine Pellingare)
    [36534] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2500,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Spinning Cleave (Varaine Pellingare)
    [36396] =
    {
        block = true,
        dodge = true,
        bs = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                         -- Bludgeon (Varaine Pellingare)
    [35838] = { dodge = true, interrupt = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1500 }, -- Necrotic Arrow (Allene Pellingare)
    [36537] = { power = true, priority = 1, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED },        -- Shield Sibling (Allene & Varaine Pellingare)
    [49053] = { power = true, priority = 1, auradetect = true, refire = 5000 },                                -- Toxic Fumes (Allene Pellingare)

    -- Crypt of Hearts I
    [22714] = { avoid = true, priority = 1, auradetect = true, bossName = true }, -- Necrotic Ritual (Archmaster Siniel)
    [22768] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        cc = LUIE_CC_TYPE_FEAR,
    },                                                                                  -- Induce Horror (Archmaster Siniel)
    [46581] = { power = true, priority = 1, auradetect = true, hiddenDuration = 2500 }, -- Daedric Step (Archmaster Siniel)
    [22808] = { power = true, priority = 1, auradetect = true, ignoreRefresh = true },  -- Corpse Shield (Archmaster Siniel)
    [22787] = { unmit = true, priority = 1, auradetect = true },                        -- Corpse Explosion (Archmaster Siniel)

    [111957] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        cc = LUIE_CC_TYPE_STUN,
        duration = 1500,
        postCast = 1500,
    }, -- Trample (Death's Leviathan)
    [22527] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 2000,
    }, -- Paralyzing Slam (Death's Leviathan)
    [46680] =
    {
        power = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        bossName = true,
        refire = 1000,
    }, -- Immolate Colossus (Death's Leviathan)

    [22450] =
    {
        avoid = true,
        priority = 1,
        auradetect = true,
        fakeName = Unitnames.Boss_Ilambris_Athor,
        neverShowInterrupt = true,
    }, -- Summon Lightning Rod (Ilambris-Athor)
    [22338] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                        -- Axe Strike (Ilambris-Athor)
    [32425] = { power = true, priority = 1, auradetect = true },                                              -- Lightning Empowerment (Ilambris-Athor)
    [22456] = { power = true, priority = 1, auradetect = true },                                              -- Lightning Omnipotence (Ilambris-Athor)
    [22397] = { avoid = true, priority = 1, auradetect = true, duration = 11000, neverShowInterrupt = true }, -- Call Lightning (Ilambris-Athor)
    [22342] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1000,
        postCast = 1500,
        fakeName = Unitnames.Boss_Ilambris_Zaven,
    },                                                           -- Rolling Fire (Ilambris-Zaven)
    [32424] = { power = true, priority = 1, auradetect = true }, -- Incensed (Ilambris-Zaven)
    [22390] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 2500,
        fakeName = Unitnames.Boss_Ilambris_Zaven,
        cc = LUIE_CC_TYPE_STUN,
    },                                                                                                       -- Pyrocasm (Ilambris-Zaven)
    [22457] = { power = true, priority = 1, auradetect = true },                                             -- Emit Flames (Ilambris-Zaven)
    [22383] = { avoid = true, priority = 1, auradetect = true, duration = 6100, neverShowInterrupt = true }, -- Rain Fire (Ilambris-Zaven)

    -- Crypt of Hearts II
    [51746] = { summon = true, priority = 2, auradetect = true, fakeName = Unitnames.NPC_Spiderkith_Broodnurse }, -- Summon the Dead (Spiderkith Broodnurse)
    [51753] = { summon = true, priority = 2, auradetect = true, fakeName = Unitnames.NPC_Spiderkith_Broodnurse }, -- Reanimate Skeleton (Spiderkith Broodnurse)
    [52040] =
    {
        shouldusecc = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        refire = 1000,
        fakeName = Unitnames.NPC_Spiderkith_Broodnurse,
        stack = 2,
    }, -- Summon Atronach (Ibelgast's Broodnurse)
    [52160] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.NPC_Spiderkith_Broodnurse,
    }, -- Flesh Atronach Rises (Ibelgast's Broodnurse)
    [53285] =
    {
        summon = true,
        priority = 2,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        fakeName = Unitnames.NPC_Ogrim,
    }, -- Summon (Ogrim)
    [51882] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 3000,
        postCast = 5000,
        bossName = true,
    }, -- Creeping Storm (Ruzozuzalpamaz)
    [52017] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        postCast = 2200,
        bossName = true,
    }, -- Lightning Onslaught (Ruzozuzalpamaz)
    [53779] =
    {
        summon = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        refire = 5000,
        bossName = true,
    }, -- Webdrop (Ruzozuzalpamaz)
    [51386] =
    {
        power = true,
        priority = 1,
        auradetect = true,
        duration = 30000,
        effectOnlyInterrupt = true,
        noSelf = true,
    }, -- Web Wrap (Ruzozuzalpamaz)

    [54620] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Uppercut (Chamber Guardian)
    [51719] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        postCast = 2100,
        cc = LUIE_CC_TYPE_FEAR,
        fakeName = Unitnames.Boss_Chamber_Guardian,
    }, -- Consuming Horror (Chamber Guardian)
    [51728] =
    {
        summon = true,
        priority = 1,
        auradetect = true,
        result = ACTION_RESULT_EFFECT_GAINED,
        refire = 5000,
        fakeName = Unitnames.Boss_Chamber_Guardian,
    }, -- Consuming Horror (Chamber Guardian)

    [52167] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 1650,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                            -- Shock Form (Ilambris Amalgam)
    [53600] = { power = true, priority = 1, auradetect = true, bossName = true }, -- Summon Shock Skeleton (Ilambris Amalgam)
    [52278] = { avoid = true, priority = 1, auradetect = true },                  -- Call Lightning (Ilambris Amalgam)
    [52491] =
    {
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 1150,
        cc = LUIE_CC_TYPE_STAGGER,
    }, -- Thunder Fist (Ilambris Amalgam)
    [52166] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        bossName = true,
        duration = 1650,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                                   -- Fire Form (Ilambris Amalgam)
    [53593] = { power = true, priority = 1, auradetect = true, bossName = true },                                        -- Summon Flame Skeleton (Ilambris Amalgam)
    [52285] = { avoid = true, priority = 1, auradetect = true },                                                         -- Rain Fire (Ilambris Amalgam)
    [52334] = { power = true, priority = 1, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, bossName = true }, -- Final Storm (Ilambris Amalgam)

    [51090] =
    {
        unmit = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        bossName = true,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Rise and Fall (Mezeluth)

    [51539] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                                         -- Necrotic Blast (Nerien'eth)
    [52080] = { power = true, priority = 1, auradetect = true, duration = 12000, effectOnlyInterrupt = true }, -- Necrotic Swarm (Nerien'eth)
    [51853] =
    {
        power = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Nerieneth,
        hiddenDuration = 1000,
    }, -- Soul Pulse (Nerien'eth)
    [51864] =
    {
        avoid = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_STAGGER,
        fakeName = Unitnames.Boss_Nerieneth,
    }, -- Force Pulse (Nerien'eth)
    [51943] =
    {
        power = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Nerieneth,
        hiddenDuration = 1000,
    },                                                                                                        -- Soul Summon (Nerien'eth)
    [60632] = { summon = true, priority = 1, auradetect = true, duration = 8000, neverShowInterrupt = true }, -- Shadow Cloak (Nerien'eth)
    [52635] =
    {
        power = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Nerieneth,
        hiddenDuration = 1000,
    },                                                                                                        -- Teleport (Nerien'eth)
    [60631] = { power = true, priority = 1, auradetect = true, duration = 12000, neverShowInterrupt = true }, -- Shadow Cloak (Nerien'eth)
    [52119] =
    {
        unmit = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 3000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        refire = 1000,
        fakeName = Unitnames.Boss_Nerieneth,
    }, -- Enervating Sheen (Nerien'eth)
    [52126] =
    {
        power = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        fakeName = Unitnames.Boss_Nerieneth,
        hiddenDuration = 1000,
    }, -- Teleport (Nerien'eth)
    [52143] =
    {
        power = true,
        priority = 1,
        auradetect = true,
        duration = 14500,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
        noSelf = true,
    },                                                                                                                -- Blood Lust (Nerien'eth)
    [51988] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 1750, cc = LUIE_CC_TYPE_SNARE }, -- Lethal Stab (Nerien'eth)
    [51993] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Heavy Slash (Nerien'eth)
    [51997] =
    {
        block = true,
        dodge = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1000,
        cc = LUIE_CC_TYPE_STAGGER,
        fakeName = Unitnames.Boss_Nerieneth,
        postCast = 500,
    }, -- Ebony Whirlwind (Nerien'eth)

    -- Volenfell
    [25649] =
    {
        unmit = true,
        priority = 1,
        eventdetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 2000,
        cc = LUIE_CC_TYPE_FEAR,
        fakeName = Unitnames.Boss_Desert_Lion,
    }, -- Debilitating Roar (Desert Lion)

    [25029] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 6000,
    }, -- Twisted Steel (Quintus Verres)
    [25142] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 2000,
        postCast = 4000,
    }, -- Burning Groud (Quintus Verres)

    [25227] =
    {
        block = true,
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.Boss_Monstrous_Gargoyle,
        duration = 2100,
        cc = LUIE_CC_TYPE_STUN,
    }, -- Petrifying Bellow (Monstrous Gargoyle)
    [25222] =
    {
        block = true,
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.Boss_Monstrous_Gargoyle,
        duration = 6100,
        refire = 5000,
    }, -- Heaving Quake (Monstrous Gargoyle)

    [25672] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        bossName = true,
        duration = 4000,
    },                                                                                                    -- Flame Burst (Boilbite)
    [25655] = { block = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 700 }, -- Explosive Bolt (Unstable Construct)
    [25659] =
    {
        avoid = true,
        priority = 1,
        auradetect = true,
        result = ACTION_RESULT_BEGIN,
        duration = 1500,
        noSelf = true,
    }, -- Countdown (Unstable Construct)

    [24777] =
    {
        block = true,
        bs = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        fakeName = Unitnames.Boss_Tremorscale,
        duration = 1500,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    }, -- Tail Swipe (Tremorscale)
    [29167] =
    {
        avoid = true,
        priority = 1,
        result = ACTION_RESULT_EFFECT_GAINED,
        eventdetect = true,
        fakeName = Unitnames.Boss_Tremorscale,
        duration = 1800,
        cc = LUIE_CC_TYPE_UNBREAKABLE,
    },                                                                                          -- Dummy (Tremorscale)

    [25211] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true }, -- Whirlwind Function (The Guardian's Strength)
    [25229] = { avoid = true, priority = 1, auradetect = true },                                -- Barrage Function (Centurion Champion)
    [25262] =
    {
        block = true,
        dodge = true,
        priority = 1,
        result = ACTION_RESULT_BEGIN,
        eventdetect = true,
        duration = 1950,
    },                                                                                                                                                -- Hammer Strike (The Guardian's Soul)
    [25263] = { block = true, bs = true, dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 2000, cc = LUIE_CC_TYPE_UNBREAKABLE, }, -- Decapitation Function (The Guardian's Soul)

    -- Frostvault
    [109574] = { block = true, interrupt = true, priority = 3, result = ACTION_RESULT_BEGIN, refire = 3250 },  -- Fire Power (Coldsnap Harrier)
    [117352] = { block = true, dodge = true, priority = 3, result = ACTION_RESULT_BEGIN, eventdetect = true }, -- Whirlwind (Coldsnap Snowstalker)
    [117290] = { block = true, avoid = true, priority = 2, result = ACTION_RESULT_BEGIN },                     -- Shockwave (Coldsnap Ogre)
    [117287] = { block = true, bs = true, dodge = true, priority = 2, result = ACTION_RESULT_BEGIN },          -- Crushing Blow (Coldsnap Ogre)
    [117326] = { block = true, priority = 3, result = ACTION_RESULT_EFFECT_GAINED, refire = 250 },             -- Ice Comet (Coldsnap Skysplitter)
    [109827] = { block = true, avoid = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true }, -- Boulder Toss (Icestalker)
    [109811] = { avoid = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true },               -- Ground Slam (Icestalker)
    [109837] = { interrupt = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true },           -- Frenzied Pummeling (Icestalker)
    [109806] = { block = true, priority = 1, result = ACTION_RESULT_BEGIN, eventdetect = true },               -- Frozen Aura (Icestalker)
    [83430] = { block = true, bs = true, dodge = true, priority = 3, result = ACTION_RESULT_BEGIN },           -- Skeletal Smash (Ice Wraith)
}

--- @class (partial) AlertTable
LuiData.Data.AlertTable = AlertTable
