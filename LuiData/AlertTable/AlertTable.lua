-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
local UnitNames = Data.UnitNames

local ACTION_RESULT_BEGIN = ACTION_RESULT_BEGIN
local ACTION_RESULT_EFFECT_GAINED = ACTION_RESULT_EFFECT_GAINED

local LUIE_ALERT_SOUND_TYPE_AOE = LUIE_ALERT_SOUND_TYPE_AOE
local LUIE_ALERT_SOUND_TYPE_AOE_CC = LUIE_ALERT_SOUND_TYPE_AOE_CC
local LUIE_ALERT_SOUND_TYPE_DESTROY = LUIE_ALERT_SOUND_TYPE_DESTROY
local LUIE_ALERT_SOUND_TYPE_GROUND = LUIE_ALERT_SOUND_TYPE_GROUND
local LUIE_ALERT_SOUND_TYPE_HEAL = LUIE_ALERT_SOUND_TYPE_HEAL
local LUIE_ALERT_SOUND_TYPE_POWER_ATTACK = LUIE_ALERT_SOUND_TYPE_POWER_ATTACK
local LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE
local LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE
local LUIE_ALERT_SOUND_TYPE_ST = LUIE_ALERT_SOUND_TYPE_ST
local LUIE_ALERT_SOUND_TYPE_ST_CC = LUIE_ALERT_SOUND_TYPE_ST_CC
local LUIE_ALERT_SOUND_TYPE_SUMMON = LUIE_ALERT_SOUND_TYPE_SUMMON
local LUIE_ALERT_SOUND_TYPE_TRAVELER = LUIE_ALERT_SOUND_TYPE_TRAVELER
local LUIE_ALERT_SOUND_TYPE_TRAVELER_CC = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC
local LUIE_CC_TYPE_FEAR = LUIE_CC_TYPE_FEAR
local LUIE_CC_TYPE_KNOCKBACK = LUIE_CC_TYPE_KNOCKBACK
local LUIE_CC_TYPE_SILENCE = LUIE_CC_TYPE_SILENCE
local LUIE_CC_TYPE_SNARE = LUIE_CC_TYPE_SNARE
local LUIE_CC_TYPE_STAGGER = LUIE_CC_TYPE_STAGGER
local LUIE_CC_TYPE_STUN = LUIE_CC_TYPE_STUN
local LUIE_CC_TYPE_UNBREAKABLE = LUIE_CC_TYPE_UNBREAKABLE

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
    - minHitValue: number    -- Only show when combat event hitValue is >= this (ms)
    - maxHitValue: number    -- Only show when combat event hitValue is <= this (ms)
    - hitValueEquals: number -- Only show when hitValue matches exactly
    - eventdetect: boolean   -- Detect combat events without a source or target
    - auradetect: boolean    -- Detect aura application instead of using targeting info

    **Source Name Modification Options:**
    - fakeName: string       -- Set a custom name for the source
    - bossName: boolean      -- Use the current BOSS target frame name if available
    - bossMatch: string      -- Specifies a boss name match when multiple bosses exist
    - noForcedNameOverride: boolean -- Fill in the name only if it is missing

    **Crowd Control (CC) Type:**
    - cc: integer             -- Set the type of CC effect (e.g. LUIE_CC_TYPE_STUN, LUIE_CC_TYPE_FEAR, etc.)

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
--- @field minHitValue? number         -- (Filtering) Minimum combat log hitValue (ms) to show alert
--- @field maxHitValue? number         -- (Filtering) Maximum combat log hitValue (ms) to show alert
--- @field hitValueEquals? number      -- (Filtering) Exact hitValue (ms) required to show alert
--- @field eventdetect? boolean        -- (Filtering) Detects events with no source or target
--- @field auradetect? boolean         -- (Filtering) Detects aura applications
--- @field fakeName? string            -- (Source Name Modification) Custom source name override
--- @field bossName? boolean           -- (Source Name Modification) Use boss target frame name if possible
--- @field bossMatch? {[string]:string}           -- (Source Name Modification) Specific boss name for matching
--- @field noForcedNameOverride? boolean -- (Source Name Modification) Only override if name is missing
--- @field cc? integer                  -- (CC Type) Crowd control type (e.g. LUIE_CC_TYPE_STUN)
--- @field duration? number            -- (Duration) Duration in milliseconds for alert display
--- @field refire? number|string       -- (Other Modifiers) Refire duration (delay between alerts)
--- @field ignoreRefresh? boolean      -- (Other Modifiers) Ignores refresh events
--- @field neverShowInterrupt? boolean -- (Other Modifiers) Do not display interrupt alerts
--- @field effectOnlyInterrupt? boolean -- (Other Modifiers) Only display interrupts on early effect fade
--- @field alwaysShowInterrupt? boolean -- (Other Modifiers) Always display interrupts even without duration
--- @field noSelf? boolean             -- (Other Modifiers) Suppress alerts for self-generated events
--- @field durationOnlyIfTarget? boolean -- (Other Modifiers) Show duration timer only if the player is the target
--- @field hideIfNoSource? boolean     -- (Other Modifiers) Hide alerts when source name is missing
--- @field noDirect? boolean
--- @field spreadOut? boolean
--- @field hiddenDuration? integer
--- @field postCast? integer
--- @field sound? integer
--- @field shouldusecc? boolean

--- @class (partial) AlertTable
--- @field [integer] AlertTableItem
local alertTable =
{
    --------------------------------------------------
    -- JUSTICE NPC'S ---------------------------------
    --------------------------------------------------

    [63157] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Blow (Justice Guard 1H)
    [63261] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1250, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Blow (Justice Guard 2H)
    [63179] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true, cc = LUIE_CC_TYPE_STUN, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Flame Shard (Justice Guard 2H)
    [78743] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true }, -- Flare (Justice Guard - Any)

    [74862] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Teleport Trap (Mage Guard)

    [62409] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 3500, refire = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fiery Wind (Justice Mage NPC)
    [62472] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Stab (Justice Dagger NPC)

    [78265] = { priority = 2, result = ACTION_RESULT_BEGIN, power = true, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Alarm (Estate Marshal) (DB DLC)

    [73229] = { priority = 2, power = true, auradetect = true, ignoreRefresh = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Hurried Ward (Guard - DB Mage)

    --------------------------------------------------
    -- STANDARD NPC'S --------------------------------
    --------------------------------------------------

    -- Shared
    -- [39058] = { avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, cc = LUIE_CC_TYPE_UNBREAKABLE }, -- Bear Trap (Bear Trap)

    -- Synergy
    [12439] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 1800, refire = 2500, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Burning Arrow (Synergy)
    [10805] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Calixte_Darkblood, UnitNames.Boss_Angata_the_Clannfear_Handler }, duration = 1500, refire = 2500, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Ignite (Synergy)

    -- Abilities
    [29378] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_KNOCKBACK, duration = 1600, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Uppercut (Ravager)

    [28408] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossMatch = { UnitNames.Boss_Smiles_With_Knife }, duration = 1533, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Whirlwind (Skirmisher)

    [37108] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Arrow Spray (Archer)
    [28628] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 6800, refire = 2000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Volley (Archer)
    [74978] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true, cc = LUIE_CC_TYPE_STUN, duration = 9000, sound = LUIE_ALERT_SOUND_TYPE_POWER_ATTACK }, -- Taking Aim (Archer)

    [14096] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1250, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack (Footsoldier)
    [28499] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1200, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Throw Dagger (Footsoldier)

    [29400] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Power Bash (Guard)
    [29761] = { priority = 3, power = true, auradetect = true, effectOnlyInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Brace (Guard)

    [13701] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Focused Charge (Brute)

    [35164] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, cc = LUIE_CC_TYPE_STUN, duration = 1333, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Agony (Berserker)

    [29510] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossMatch = { UnitNames.Boss_Anarume, UnitNames.Boss_Fangoz, UnitNames.Boss_Nenesh_gro_Mal, UnitNames.NPC_Xivilai_Boltaic }, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Thunder Hammer (Thundermaul)
    [17867] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Anarume, UnitNames.Boss_Fangoz, UnitNames.Boss_Nenesh_gro_Mal, UnitNames.NPC_Xivilai_Boltaic }, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Shock Aura (Thundermaul)
    [44407] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Lightning Form (Thundermaul)
    [81215] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Captain_Blanchete }, cc = LUIE_CC_TYPE_STUN, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shock Aura (Thundermaul - Boss)
    [81195] = { priority = 2, avoid = true, auradetect = true, bossMatch = { UnitNames.Boss_Captain_Blanchete }, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Agonizing Fury (Thundermaul - Boss)
    [81217] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossMatch = { UnitNames.Boss_Captain_Blanchete }, duration = 1533, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Thunder Hammer (Thundermaul - Boss)

    [36470] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Veiled Strike (Nightblade)
    [137148] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Veiled Strike (Nightblade)
    [44345] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Dogas_the_Berserker }, cc = LUIE_CC_TYPE_STUN, duration = 600, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Soul Tether (Nightblade)

    [34742] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fiery Breath (Dragonknight)
    [34646] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Lava Whip (Dragonknight)
    [44227] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Jahlasri, UnitNames.Boss_Dugan_the_Red }, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Dragonknight Standard (Dragonknight - Elite)
    [52041] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, bossMatch = { UnitNames.Boss_Jahlasri }, cc = LUIE_CC_TYPE_STUN, duration = 1667, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Blink Strike (Dragonknight - Elite)

    [88251] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call Ally (Pet Ranger)
    [88248] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call Ally (Pet Ranger)
    [89425] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call Ally (Pet Ranger)
    [44301] = { priority = 3, dodge = true, auradetect = true, cc = LUIE_CC_TYPE_SNARE, ignoreRefresh = true, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Trap Beast (Pet Ranger)

    [15164] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Akezel, UnitNames.Boss_Calixte_Darkblood }, noForcedNameOverride = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Heat Wave (Fire Mage)
    [47095] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Calixte_Darkblood, UnitNames.Boss_Keeper_Areldur }, duration = 2000, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Fire Rune (Fire Mage)

    [29471] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossMatch = { UnitNames.NPC_Xivilai_Fulminator, UnitNames.NPC_Xivilai_Boltaic }, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Thunder Thrall (Storm Mage)

    [12459] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Winter's Reach (Frost Mage)
    [14194] = { priority = 3, power = true, auradetect = true, fakeName = "", refire = 3000, hideIfNoSource = true, hiddenDuration = 2500, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Ice Barrier (Frost Mage)

    [35151] = { priority = 3, interrupt = true, auradetect = true, fakeName = "", bossMatch = { UnitNames.Boss_Shagura }, duration = 8000, effectOnlyInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Spell Absorption (Spirit Mage)
    [14472] = { priority = 2, summon = true, auradetect = true, fakeName = "", bossMatch = { UnitNames.Boss_Shagura }, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Burdening Eye (Spirit Mage)

    [36985] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, hiddenDuration = 3500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Void (Time Bomb Mage)

    [37087] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Thjormar_the_Drowned, UnitNames.Boss_Stroda_gra_Drom, UnitNames.NPC_Xivilai_Fulminator, UnitNames.NPC_Xivilai_Boltaic }, duration = 1500, postCast = 1250, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Lightning Onslaught (Battlemage)
    [37129] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Thjormar_the_Drowned, UnitNames.Boss_Stroda_gra_Drom }, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Ice Cage (Battlemage)
    [44216] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Thjormar_the_Drowned, UnitNames.Boss_Stroda_gra_Drom }, cc = LUIE_CC_TYPE_SILENCE, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Negate Magic (Battlemage - Elite)

    [88554] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon the Dead (Necromancer)
    [88555] = { priority = 2, summon = true, auradetect = true, fakeName = "", bossMatch = { UnitNames.Boss_Gravecaller_Niramo, UnitNames.Boss_Grivier_Bloodcaller, UnitNames.Boss_Louna_Darkblood }, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon the Dead (Necromancer)
    [88556] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon the Dead (Necromancer)
    [13397] = { priority = 3, result = ACTION_RESULT_EFFECT_GAINED, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Gravecaller_Niramo, UnitNames.Boss_Grivier_Bloodcaller, UnitNames.Boss_Louna_Darkblood }, duration = 5000, hideIfNoSource = true, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Empower Undead (Necromancer)

    [14350] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_FEAR, duration = 1667, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Aspect of Terror (Fear Mage)

    [44250] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Dark Shade (Dreadweaver)

    [44323] = { priority = 3, power = true, auradetect = true, ignoreRefresh = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Dampen Magic (Soulbrander)
    [44258] = { priority = 3, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Radiant Magelight (Soulbrander)

    [35387] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Overlord_Nur_dro }, cc = LUIE_CC_TYPE_SNARE, duration = 1000, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Defiled Grave (Bonelord)
    [88506] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Abomination (Bonelord)
    [88507] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, fakeName = "", bossMatch = { UnitNames.Boss_Overlord_Nur_dro }, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Abomination (Bonelord)

    [57534] = { priority = 3, interrupt = true, auradetect = true, fakeName = "", duration = 4000, effectOnlyInterrupt = true, noSelf = true, hideIfNoSource = true, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Focused Healing (Healer)
    [50966] = { priority = 2, power = true, auradetect = true, duration = 5000, alwaysShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Healer Immune (Healer - Craglorn/DLC)
    [44328] = { priority = 2, interrupt = true, auradetect = true, duration = 4500, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Rite of Passage (Healer)

    [29520] = { priority = 2, destroy = true, auradetect = true, fakeName = "", bossMatch = { UnitNames.Boss_Bagul }, sound = LUIE_ALERT_SOUND_TYPE_DESTROY }, -- Aura of Protection (Shaman)

    [68866] = { priority = 2, power = true, auradetect = true, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- War Horn (Faction NPC)
    [43644] = { priority = 3, avoid = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Barrier [monster synergy]  (Faction NPCs)
    [43645] = { priority = 3, avoid = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Barrier [monster synergy]  (Faction NPCs)
    [43646] = { priority = 3, avoid = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Barrier [monster synergy]  (Faction NPCs)

    [70070] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1250, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Strike (Winterborn Warrior)
    [64980] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1200, postCast = 500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Javelin (Winterborn Warrior)
    [65033] = { priority = 3, result = ACTION_RESULT_EFFECT_GAINED, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Retaliation (Winterborn Warrior)

    [55909] = { priority = 3, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, postCast = 2300, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Grasping Vines (Winterborn Mage)
    [64704] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, interrupt = true, eventdetect = true, duration = 4500, refire = 1500, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Flames (Winterborn Mage)

    [65235] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Enrage (Vosh Rakh Devoted)
    [53987] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, duration = 3000, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Rally (Vosh Rakh Devoted)
    [54027] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 4000, refire = 1600, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Divine Leap (Vosh Rakh Devoted)

    [51000] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Cleave Stance (Dremora Caitiff) (Craglorn)

    [72725] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Fool Me Once (Sentinel) (TG DLC)

    [76089] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Snipe (Archer) (TG DLC)
    -- [72220] = { block = true, dodge = true, reflect = true, priority = 3, result = ACTION_RESULT_BEGIN, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Snipe (Archer) (TG DLC) -- This is cast from stealth - so for the time being, maybe hide.
    [72222] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Shadow Cloak (Archer) (TG DLC)

    [77472] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Til Death (Bodyguard) (DB DLC)
    [77554] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Shard Shield (Bodyguard) (DB DLC)
    [77473] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shield Charge (Bodyguard) (DB DLC)

    [77089] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_STUN, duration = 1250, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Basilisk Powder (Tracker) (Morrowind)
    [77087] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Basilisk Powder (Tracker) (Morrowind)
    [77019] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, reflect = true, cc = LUIE_CC_TYPE_SNARE, duration = 766, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Pin (Tracker) (Morrowind)
    [78432] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Lunge (Tracker) (Morrowind)

    [88371] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 1000, postCast = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Dive (Beastcaller) (Morrowind)
    [88394] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1000, postCast = 2300, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Gore (Beastcaller) (Morrowind)
    [88409] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Raise the Earth (Beastcaller)

    [87901] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Bombard (Arbalest) (Morrowind)
    [87422] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Chilled Ground (Arbalest) (Morrowind)
    [87713] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1300, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Quakeshot (Arbalest) (Morrowind)

    [85359] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1267, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Reverse Slash (Drudge)

    [87064] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Volcanic Debris (Fire-Binder) (Morrowind)
    [88845] = { priority = 3, interrupt = true, auradetect = true, duration = 15000, effectOnlyInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Empower Atronach (Fire-Binder) (Morrowind)

    [76621] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, noDirect = true, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Shadeway (Voidbringer) (Morrowind)
    [76619] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Pool of Shadow (Voidbringer) (Morrowind)
    [76979] = { priority = 3, block = true, avoid = true, auradetect = true, fakeName = "", cc = LUIE_CC_TYPE_STUN, duration = 5000, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shadowy Duplicate (Voidbringer) (Morrowind)

    [88327] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, noDirect = true, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Shadeway (Skaafin Masquer) (Morrowind)
    [88325] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Pool of Shadow (Skaafin Masquer) (Morrowind)
    [88348] = { priority = 3, block = true, avoid = true, auradetect = true, fakeName = "", cc = LUIE_CC_TYPE_STUN, duration = 5000, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shadowy Duplicate (Skaafin Masquer) (Morrowind)

    [84818] = { priority = 3, interrupt = true, auradetect = true, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Fiendish Healing (Skaafin Witchling) (Morrowind)

    [84835] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 2300, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Broken Pact (Skaafin) (Morrowind)

    -- ANIMALS
    [5452] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Lacerate (Alit)

    [4415] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1600, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Crushing Swipe (Bear)
    [139956] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Savage Blow (Bear)

    [70366] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossMatch = { UnitNames.Boss_Gurgozu, UnitNames.Boss_Graufang }, cc = LUIE_CC_TYPE_STUN, duration = 2167, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Slam (Great Bear)
    [70374] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Ferocity (Great Bear)

    [4591] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 970, hideIfNoSource = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Sweep (Crocodile)
    [4594] = { priority = 2, power = true, auradetect = true, refire = 500, ignoreRefresh = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Ancient Skin (Crocodile)

    [8977] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 1721, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Sweep (Duneripper)

    [7227] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1100, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Rotbone (Durzog)

    [6308] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, reflect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Shocking Touch (Dreugh)
    [6328] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 3600, refire = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Shocking Rake (Dreugh)

    [54375] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1300, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shockwave (Echatere)
    [54380] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1300, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Headbutt (Echatere)

    [4632] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Screech (Giant Bat)
    [4630] = { priority = 3, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, duration = 1800, refire = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Draining Bite (Giant Bat)

    [5240] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2600, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Lash (Giant Snake)
    [5242] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Kiss of Poison (Giant Snake)
    [5244] = { priority = 3, interrupt = true, auradetect = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Shed Skin (Giant Snake)

    [5441] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Dive (Guar)

    [14196] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Charge (Kagouti)
    [5363] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Chomp (Kagouti)
    [5926] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Toss (Kagouti)
    [87276] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Chomp (Kagouti Whelp)

    [7161] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Double Strike (Lion)

    [8601] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 6000, refire = 600, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Vigorous Swipe (Mammoth)
    [8600] = { priority = 3, result = ACTION_RESULT_EFFECT_GAINED, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 3000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Stomp (Mammoth)
    [23230] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Charge (Mammoth)

    [4200] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Unforgiving Claws (Mudcrab)

    [16690] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Thrust (Netch)
    [16697] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 7500, refire = 1800, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Poisonbloom (Netch)

    [7268] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 5650, refire = 500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Leech (Nix-Hound)
    [7273] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Dampworm (Nix-Hound)

    [21904] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Rend (Skeever)

    [21951] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 4900, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Repulsion Shock (Wamasu)
    [21949] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1400, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Sweep (Wamasu)
    [21957] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Charge (Wamasu)
    [22045] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- - Static (Wamasu)

    [55866] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 4900, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Repulsion Shock (Wamasu - Boss)
    [55868] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1200, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Sweep (Wamasu - Boss)
    [55850] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Impending Storm (Wamasu - Boss)
    [55860] = { priority = 2, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_SNARE, duration = 1700, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Storm Bound (Wamasu - Boss)

    [44791] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Rear Kick (Welwa)
    [50714] = { priority = 3, result = ACTION_RESULT_EFFECT_GAINED, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Charge (Welwa)

    [42844] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1100, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Rotbone (Wolf)
    [14523] = { priority = 3, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_SNARE, duration = 6800, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Helljoint (Wolf)
    [14272] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call of the Pack (Wolf)
    [26658] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Call of the Pack (Jackal)

    [72793] = { priority = 2, result = ACTION_RESULT_BEGIN, dodge = true, reflect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1767, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Toxic Mucus (Haj Mota)
    [72796] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Bog Burst (Haj Mota)
    [72789] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1667, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Shockwave (Haj Mota)

    [76307] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1467, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Lunge (Dire Wolf)
    [76324] = { priority = 2, power = true, auradetect = true, refire = 1000, hiddenDuration = 2500, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Baleful Call (Dire Wolf)

    [85201] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1167, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Bite (Nix-Ox)
    [85084] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 500, refire = 750, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shriek (Nix-Ox)
    [90765] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Acid Spray (Nix-Ox)
    [90809] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Acid Spray (Nix-Ox)
    [85172] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Winnow (Nix-Ox)
    [85203] = { priority = 2, power = true, auradetect = true, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Nix-Call (Nix-Ox)

    [85395] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1333, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Dive (Cliff Strider)
    [85399] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Retch (Cliff Strider)
    [85390] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1600, refire = 750, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Slash (Cliff Strider)

    -- INSECTS
    [6137] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 800, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Laceration (Assassin Beetle)
    [5268] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Collywobbles (Assassin Beetle)

    [6757] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Blurred Strike (Giant Scorpion)
    [6756] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Paralyze (Giant Scorpion)
    [6758] = { priority = 2, power = true, auradetect = true, refire = 500, ignoreRefresh = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Hardened Carapace (Giant Scorpion)

    [5789] = { priority = 3, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, duration = 2000, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fire Runes (Giant Spider)
    [5685] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Corrosive Bite (Giant Spider)
    [8087] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 5100, refire = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Poison Spray (Giant Spider)
    -- [4737] = { avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Encase (Giant Spider)
    [13382] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, alwaysShowInterrupt = true, hideIfNoSource = true, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Devour (Giant Spider)

    [9226] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Sting (Wasp)
    [25110] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Focused Charge (Giant Wasp)
    [9229] = { priority = 3, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Inject Larva (Giant Wasp)

    [6800] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Bloodletting (Hoarvor)
    [6795] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 7850, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Latch On (Hoarvor)

    [61244] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fevered Retch (Necrotic Hoarvor)
    [61360] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 5500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Infectious Swarm (Necrotic Hoarvor)
    [61427] = { priority = 3, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1200, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Necrotic Explosion (Necrotic Hoarvor)

    [14841] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Focused Charge (Kwama Worker)

    [9769] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 3267, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Excavation (Kwama Warrior)
    [49192] = { priority = 3, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Excavation (Kwama Warrior)

    [5260] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 2700, refire = 750, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Flamethrower (Shalk)
    [5252] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1100, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Fire Bite (Shalk)
    [5262] = { priority = 3, avoid = true, interrupt = true, auradetect = true, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Burning Ground (Shalk)

    [8429] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 4600, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Zap (Thunderbug)
    [26412] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, duration = 1500, postCast = 1800, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Thunderstrikes (Thunderbug)

    [73172] = { priority = 3, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_SNARE, duration = 3667, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Swarm (Kotu Gava Broodmother)
    [73199] = { priority = 3, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Swarmburst (Kotu Gava Broodmother)

    [87022] = { priority = 3, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Swarm (Fetcherfly Nest)
    -- [85645] = { block = true, avoid = true, priority = 3, result = ACTION_RESULT_BEGIN, duration = 1000 }, -- Bombard (Fetcherfly Nest)
    [87125] = { priority = 3, avoid = true, interrupt = true, auradetect = true, duration = 8000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Heat Vents (Fetcherfly Nest)

    [92078] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, destroy = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_DESTROY }, -- Colonize (Fetcherfly Hive Golem)
    [87062] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SILENCE, duration = 4000, postCast = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fetcherfly Storm (Fetcherfly Hive Golem)
    [87030] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 867, postCast = 750, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Focused Swarm (Fetcherfly Hive Golem)

    -- DAEDRA
    [31115] = { priority = 2, destroy = true, auradetect = true, fakeName = "", refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_DESTROY }, -- Summon Dark Anchor (Daedric Synergy)
    -- [68449] = { avoid = true, refire = 1000, priority = 3, duration = 500, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Explosive Charge (Daedric Synergy) -- TODO: Needs result if ever enabled.

    [48121] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack (Air Atronach)
    [48137] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Tornado (Air Atronach)

    [51262] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Air Atronach Flame (Air Atronach)
    [51271] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Air Atronach Flame (Air Atronach)
    [51269] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Air Atronach Flame (Air Atronach)

    [51281] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 3250, refire = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Flame Tornado (Air Atronach)
    [50021] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Ice Vortex (Air Atronach)
    [50023] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 4600, refire = 800, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Lightning Rod (Air Atronach)

    [9747] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dire Wound (Banekin)
    [9748] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 3000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Envelop (Banekin)

    [4799] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Tail Spike (Clannfear)
    [93745] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Rending Leap (Clannfear)

    [26641] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Soul Flame (Daedric Titan)
    [34405] = { priority = 2, block = true, avoid = true, auradetect = true, duration = 2200, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Swallowing Souls (Daedric Titan)
    [26554] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Wing Gust (Daedric Titan)

    [4771] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Ysolmarr_the_Roving_Pyre, UnitNames.Boss_Gar_Xuu_Gar }, duration = 3100, refire = 1250, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fiery Breath (Daedroth)
    [91946] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Ysolmarr_the_Roving_Pyre, UnitNames.Boss_Gar_Xuu_Gar }, cc = LUIE_CC_TYPE_STAGGER, duration = 1000, postCast = 750, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Ground Tremor (Daedroth)
    [91937] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossMatch = { UnitNames.Boss_Ysolmarr_the_Roving_Pyre, UnitNames.Boss_Gar_Xuu_Gar }, cc = LUIE_CC_TYPE_STUN, duration = 1767, postCast = 500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Burst of Embers (Daedroth)

    [26324] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 1300, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Lava Geyser (Flame Atronach)
    -- [50216] = { block = true, avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, refire = 250, duration = 2000, neverShowInterrupt = true }, -- Combustion (Flame Atronach)

    [5017] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 2500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Hoarfrost Fist (Frost Atronach)
    [33502] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Frozen Ground (Frost Atronach)

    [50626] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 2750, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shadow Strike (Grevious Twilight) -- TODO: Is this st or aoe?
    [65889] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 2750, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shadow Strike (Grevious Twilight) -- TODO: Is this st or aoe?

    [4829] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fire Brand (Flesh Atronach)
    [4817] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Unyielding Mace (Flesh Atronach)
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
    [66869] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Pin (Flesh Colossus) -- TODO: Is this AOE?
    [67872] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1600, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Sweep (Flesh Colossus) -- TODO: Is this AOE?
    [76139] = { priority = 2, block = true, dodge = true, auradetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Stumble Forward (Flesh Colossus) -- TODO: Is this AOE?
    -- [67772] = { power = true, priority = 2, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Enraged (Flesh Colossus) -- TODO: Does this have an aura now?
    [49430] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1750, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Smash (Flesh Colossus) -- TODO: Is this only ST?
    [49429] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1250, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Claw (Flesh Colossus) -- TODO: Is this only ST?

    [11079] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1300, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Black Winter (Harvester)
    [26017] = { priority = 2, destroy = true, auradetect = true, fakeName = "", bossMatch = { UnitNames.Boss_High_Kinlord_Rilis }, refire = 5000, sound = LUIE_ALERT_SOUND_TYPE_DESTROY }, -- Creeping Doom (Harvester)

    [8205] = { priority = 3, interrupt = true, auradetect = true, duration = 6000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Regeneration (Ogrim)
    [24690] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Focused Charge (Ogrim)
    [91848] = { priority = 3, result = ACTION_RESULT_BEGIN, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1970, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Stomp (Ogrim)
    [91855] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2000, postCast = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Boulder Toss (Ogrim)

    [6166] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Heat Wave (Scamp)
    [6160] = { priority = 3, avoid = true, interrupt = true, auradetect = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Rain of Fire (Scamp)

    [8779] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, eventdetect = true, duration = 2000, postCast = 1750, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Lightning Onslaught (Spider Daedra)
    -- [89306] = { avoid = true, priority = 3, result = ACTION_RESULT_BEGIN, eventdetect = true, fakeName = UnitNames.NPC_Spiderling, cc = LUIE_CC_TYPE_SNARE, duration = 1000, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Web (Spiderling)
    [8782] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 2000, postCast = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Lightning Storm (Spider Daedra)
    [8773] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Spiderling (Spider Daedra)

    [35220] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Zymel_Etitan, UnitNames.Boss_Zymel_Kruz }, duration = 1200, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Impending Storm (Storm Atronach)
    [4864] = { priority = 2, result = ACTION_RESULT_BEGIN, dodge = true, cc = LUIE_CC_TYPE_SNARE, duration = 633, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Storm Bound (Storm Atronach)

    [7095] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack (Xivilai)
    [88947] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossMatch = { UnitNames.NPC_Xivilai_Fulminator, UnitNames.NPC_Xivilai_Boltaic }, noDirect = true, hiddenDuration = 3000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Lightning Grasp (Xivilai)
    [7100] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 1333, postCast = 3000, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Hand of Flame (Xivilai)
    [25726] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Daedra (Xivilai)

    [4653] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shockwave (Watcher)
    [9219] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 4000, refire = 1750, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Doom-Truth's Gaze (Watcher)
    [14425] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 3500, refire = 1750, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Doom-Truth's Gaze (Watcher)

    [6410] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1700, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Tail Clip (Winged Twilight)
    [6412] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Dusk's Howl (Winged Twilight)

    [94903] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Spring (Hunger)
    [87237] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 667, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Spring (Hunger)
    [87252] = { priority = 2, power = true, auradetect = true, cc = LUIE_CC_TYPE_STUN, duration = 6000, refire = 400, effectOnlyInterrupt = true, noSelf = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Devour (Hunger)
    [84944] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 2300, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Hollow (Hunger)
    [87269] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Torpor (Hunger)

    [88282] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 767, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Rock Stomp (Iron Atronach)
    [88261] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true, duration = 800, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Lava Wave (Iron Atronach)
    [88297] = { priority = 2, avoid = true, auradetect = true, duration = 6000, effectOnlyInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Blast Furnace (Iron Atronach)

    -- UNDEAD
    [8569] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1300, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Devastating Leap (Bloodfiend)
    [8554] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 2400, hideIfNoSource = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Flurry (Bloodfiend)

    [5050] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossMatch = { UnitNames.Boss_Griviers_Monstrosity, UnitNames.Boss_Skeletal_Destroyer }, cc = LUIE_CC_TYPE_STAGGER, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Bone Saw (Bone Colossus)
    [5030] = { priority = 2, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = "", bossMatch = { UnitNames.Boss_Griviers_Monstrosity, UnitNames.Boss_Oskana, UnitNames.Boss_Skeletal_Destroyer }, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Voice to Wake the Dead (Bone Colossus)
    [17207] = { priority = 3, block = true, dodge = true, auradetect = true, duration = 2500, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Necromantic Implosion (Risen Dead)

    [18514] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_SNARE, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Chill Touch (Ghost)
    [19137] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_FEAR, duration = 2000, postCast = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Haunting Spectre (Ghost)

    [22521] = { priority = 2, avoid = true, auradetect = true, bossMatch = { UnitNames.Boss_Valanir_the_Restless }, cc = LUIE_CC_TYPE_SNARE, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Defiled Ground (Lich)
    [73925] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Valanir_the_Restless }, cc = LUIE_CC_TYPE_STUN, duration = 7450, refire = 2000, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Soul Cage (Lich)

    [50182] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Consuming Energy (Spellfiend)

    [68735] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 6000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Vampiric Drain (Vampire)

    [2867] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Crushing Leap (Werewolf)
    [3415] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 4667, refire = 1100, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Flurry (Werewolf)
    [44055] = { priority = 3, interrupt = true, auradetect = true, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Devour (Werewolf)
    [5785] = { priority = 2, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Blood Scent (Werewolf)

    [4337] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Winter's Reach (Wraith)

    [2969] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Pound (Zombie)
    [2960] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, duration = 2100, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Vomit (Zombie)

    [72979] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dissonant Blow (Defiled Aegis)
    [72995] = { priority = 2, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, eventdetect = true, duration = 6100, refire = 1100, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Symphony of Blades (Defiled Aegis) -- Higher priority because damage is very high
    [76180] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Shattered Harmony (Defiled Aegis)

    -- MONSTERS
    [10270] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 2550, refire = 1250, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Quake (Gargoyle)
    [10256] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Lacerate (Gargoyle)
    [51352] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2000, postCast = 600, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Petrify (Gargoyle)

    [26124] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Shatter (Giant)
    [127910] = { priority = 2, block = true, avoid = true, auradetect = true, cc = LUIE_CC_TYPE_STUN, duration = 3200, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Giant's Maul (Giant)

    [2786] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 6100, refire = 1250, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Steal Essence (Hag)
    [2821] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, cc = LUIE_CC_TYPE_STUN, duration = 700, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Luring Snare (Hag)
    [3349] = { priority = 2, power = true, auradetect = true, duration = 8000, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Reflective Shadows (Hag)

    [10615] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Raven Storm (Hagraven)
    [10613] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, duration = 2050, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fire Bomb (Hagraven)
    [64808] = { priority = 2, summon = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Briarheart Ressurection (Hagraven)

    [4123] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Wing Slice (Harpy)
    [13515] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Wind Gust (Harpy)
    [24604] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 8000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Charged Ground (Harpy)
    [4689] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 1300, postCast = 1750, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Lightning Gale (Harpy)

    [43809] = { priority = 3, avoid = true, auradetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1750, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shard Burst (Ice Wraith)
    [24866] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Focused Charge (Ice Wraith)

    [17703] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 4550, refire = 750, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Flame Ray (Imp - Fire)
    [8884] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 4550, refire = 750, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Zap (Imp - Lightning)
    [81794] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 4600, refire = 750, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Frost Ray (Imp - Frost)

    [9671] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Howling Strike (Lamia)
    [9674] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1500, postCast = 1500, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER_CC }, -- Resonate (Lamia)
    [7835] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Convalescence (Lamia)
    -- [7831] = { interrupt = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, refire = 2500, duration = 5000 }, -- Harmony (Lamia)
    [9680] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Spectral Lamia

    [3860] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Pulverize (Lurcher)
    [3855] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Crushing Limbs (Lurcher)
    [3767] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Limbscather, UnitNames.Boss_Heart_of_Rootwater, UnitNames.Boss_Ravenous_Loam }, duration = 5600, refire = 1100, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Choking Pollen (Lurcher)

    [5559] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 2200, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Icy Geyser (Nereid)
    [5540] = { priority = 3, avoid = true, interrupt = true, auradetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 8000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Hurricane (Nereid)

    [24985] = { priority = 3, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Intimidating Roar (Ogre)
    [5881] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_SNARE, duration = 1300, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Smash (Ogre)
    [5256] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Shockwave (Ogre)

    [53142] = { priority = 2, result = ACTION_RESULT_BEGIN, destroy = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_DESTROY }, -- Ice Pillar (Ogre Shaman)
    -- [64540] = { interrupt = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Freeze Wounds (Ogre Shaman)
    -- [53137] = { interrupt = true, priority = 3, eventdetect = true, result = ACTION_RESULT_BEGIN, duration = 4000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Freeze Wounds (Ogre Shaman)

    [21582] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Nature's Swarm (Spriggan)
    [13475] = { priority = 3, interrupt = true, auradetect = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Healing Salve (Spriggan)
    [13477] = { priority = 3, interrupt = true, auradetect = true, fakeName = "", duration = 5000, effectOnlyInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Control Beast (Spriggan)
    [89119] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Beast (Spriggan)
    [89102] = { priority = 2, summon = true, auradetect = true, fakeName = "", sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Summon Beast (Spriggan)

    [9346] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Strangle (Strangler)
    [9322] = { priority = 3, avoid = true, auradetect = true, bossMatch = { UnitNames.Boss_Bone_Grappler, UnitNames.Boss_Dirge_of_Thorns }, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Poisoned Ground (Strangler)
    [9321] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, cc = LUIE_CC_TYPE_STUN, duration = 700, refire = 500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Grapple (Strangler)

    [44736] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 2150, refire = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Swinging Cleave (Troll)
    [9009] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 2500, refire = 300, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Tremor (Troll)

    [76268] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STAGGER, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Lope (River Troll)
    [76277] = { priority = 2, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, duration = 5233, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Close Wounds (River Troll)
    [76295] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Crab Toss (River Troll)

    [48256] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Boulder Toss (Troll - Ranged)
    [48282] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Consuming Omen (Troll - Ranged)

    [4309] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Dying Blast (Wisp)

    [7976] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 13500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Rain of Wisps (Wispmother)
    [18040] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Clone (Wispmother)

    [75867] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1333, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Clobber (Minotaur)
    [75917] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Ram (Minotaur)
    [79541] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, auradetect = true, cc = LUIE_CC_TYPE_STAGGER, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Flying Leap (Minotaur)
    [75925] = { priority = 2, power = true, auradetect = true, ignoreRefresh = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Elemental Weapon (Minotaur)

    [75951] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 3100, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Brimstone Hailfire (Minotaur Shaman)
    [75955] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 3800, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Pillars of Nirn (Minotaur Shaman)
    [75994] = { priority = 2, power = true, auradetect = true, ignoreRefresh = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Molten Armor (Minotaur Shaman)

    [49499] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2000 }, -- Spear Throw (Mantikora)
    [49404] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2000 }, -- Rear Up (Mantikora)
    [49402] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1750 }, -- Tail Whip (Mantikora)
    [50187] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Enrage (Mantikora)
    [56689] = { priority = 2, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Enraged (Mantikora)

    [104479] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_STUN, duration = 933 }, -- Reave (Yaghra Strider) -- TODO: SOUND / CHECK AOE / ETC
    [105214] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER }, -- Lunge (Yaghra Strider) -- TODO: SOUND / CHECK AOE / ETC
    [105330] = { priority = 2, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, duration = 1167 }, -- Frenzy (Yaghra Strider) -- TODO: SOUND / CHECK AOE / ETC

    [103804] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1900, refire = 800 }, -- Deluge (Yaghra Strider) -- TODO: SOUND / CHECK AOE / ETC
    [103931] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1333 }, -- Luminescent Mark (Yaghra Spewer) -- TODO: SOUND / CHECK AOE / ETC

    -- DWEMER
    [16031] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossMatch = { UnitNames.Boss_Unstable_Construct }, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Ricochet Wave (Dwemer Sphere)
    [7520] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1267, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Steam Wall (Dwemer Sphere)
    [7544] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossMatch = { UnitNames.Boss_Unstable_Construct }, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Quake (Dwemer Sphere)

    [11247] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Sweeping Spin (Dwemer Centurion)
    [11246] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 3500, refire = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Steam Breath (Dwemer Centurion)

    [20507] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 800, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Double Strike (Dwemer Spider)
    -- [7717] = { block = true, avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, duration = 1600, neverShowInterrupt = true }, -- Detonation (Dwemer Spider)
    [19970] = { priority = 3, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DAMAGE }, -- Static Field (Dwemer Spider - Overcharge Synergy)
    -- [20207] = { interrupt = true, priority = 3, eventdetect = true }, -- Overcharge (Dwemer Spider - Overcharge Synergy)
    -- [20505] = { block = true, avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, refire = 250, duration = 2000, neverShowInterrupt = true }, -- Overcharge (Dwemer Spider - Overcharge Synergy)
    -- [20222] = { block = true, avoid = true, priority = 3, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, refire = 250, duration = 2000, neverShowInterrupt = true }, -- Overcharge (Dwemer Spider - Overcharge Synergy)

    [64479] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, duration = 1367, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Thunderbolt (Dwemer Sentry)

    [88668] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Impulse Mine (Dwemer Arquebus)
    [85270] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 15800, refire = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shock Barrage (Dwemer Arquebus)
    [85319] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_GROUND }, -- Siege Ballista (Dwemer Arquebus)
    [85326] = { priority = 3, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, duration = 10000, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_HEAL }, -- Polarizing Field (Dwemer Arquebus)

    -- WORLD
    [95820] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Static Charge (Dark Anchor)

    --------------------------------------------------
    -- FRIENDLY NPC ----------------------------------
    --------------------------------------------------

    [42905] = { priority = 1, power = true, auradetect = true, sound = LUIE_ALERT_SOUND_TYPE_POWER_DEFENSE }, -- Recover (Friendly NPC)

    --------------------------------------------------
    -- WORLD BOSSES ----------------------------------
    --------------------------------------------------

    -- World Boss - Seaside Scarp Camp
    [84048] = { priority = 1, avoid = true, auradetect = true, fakeName = UnitNames.Boss_Quenyas, cc = LUIE_CC_TYPE_SNARE, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Defiled Ground (Quenyas)
    [83776] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Quenyas, refire = 1000, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Dark Summons (Quenyas)
    [84283] = { priority = 1, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Oskana, cc = LUIE_CC_TYPE_STAGGER, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Coursing Bones (Oskana)
    [84286] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Oskana, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- -- Wake the Dead (Oskana)

    -- World Boss - Heretic's Summons
    [82934] = { priority = 1, summon = true, auradetect = true, neverShowInterrupt = true, sound = LUIE_ALERT_SOUND_TYPE_SUMMON }, -- Shrieking Summons (Snapjaw)
    [83150] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1200 }, -- Tail Whip (Snapjaw)
    [83009] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1500 }, -- Rending Leap (Snapjaw)
    [83033] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, fakeName = UnitNames.NPC_Clannfear, refire = 500, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Focused Charge (Clannfear - Snapjaw)
    -- [83016] = { block = true, avoid = true, priority = 2, eventdetect = true, result = ACTION_RESULT_EFFECT_GAINED, refire = 250, duration = 1000, effectOnlyInterrupt = true, fakeName = UnitNames.NPC_Clannfear }, -- Necrotic Explosion (Clannfear - Snapjaw)

    -- World Boss - Nindaeril's Perch
    [83515] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2000 }, -- Hunter's Pounce (Bavura the Blizzard)
    [83832] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Nindaeril_the_Monsoon, cc = LUIE_CC_TYPE_STUN }, -- Frenzied Charge (Nindaeril the Monsoon)
    [83548] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, fakeName = UnitNames.Boss_Nindaeril_the_Monsoon, cc = LUIE_CC_TYPE_FEAR, duration = 1000 }, -- Mighty Roar (Nindaeril the Monsoon)

    -- World Boss - Gathongor's Mine
    [84205] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 1000, postCast = 4000 }, -- Stinging Sputum (Gathongor the Mauler)
    [84196] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1100, postCast = 2500 }, -- Marsh Masher (Gathongor the Mauler)
    [84209] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 600 }, -- Wrecking Jaws (Gathongor the Mauler)
    [84212] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 2100 }, -- Bog Slam (Gathongor the Mauler)

    -- World Boss - Thodundor's View
    [83155] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1300 }, -- Thunderous Smash (Thodundor of the Hill)
    [83160] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1800 }, -- Stone Crusher (Thodundor of the Hill)
    [83136] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_SNARE, duration = 800, postCast = 1500 }, -- Ground Shock (Thodundor of the Hill)

    -- World Boss - Windshriek Strand
    [84066] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 2500, postCast = 2500 }, -- Ground Shock (Skullbreaker)
    [83651] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 4500, refire = 500 }, -- Feral Impact (Skullbreaker)
    [84076] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Carrion Call (Skullbreaker)

    -- World Boss - Big Ozur's Valley
    [83180] = { priority = 1, result = ACTION_RESULT_BEGIN, destroy = true, eventdetect = true, bossName = true }, -- Molten Pillar (Big Ozur)
    [83206] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, avoid = true, eventdetect = true, bossName = true, refire = 2000 }, -- Molten Shackles (Ice Pillar)
    [83191] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 3800 }, -- Shaman Smash (Big Ozur)

    -- World Boss - The Wolf's Camp
    [10149] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, refire = 5000 }, -- Guards Transform (Lieutenant Bran, Annyce)

    -- World Boss - Trapjaw's Cove
    [83945] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 1200 }, -- Tail Sweep (Trapjaw)
    [84028] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, bossName = true, duration = 2000, postCast = 4000 }, -- Impending Storm (Trapjaw)
    [84169] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN }, -- Rolling Thunder (Trapjaw)
    [83925] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, reflect = true, cc = LUIE_CC_TYPE_STUN, duration = 1700 }, -- Trapping Bolt (Trapjaw)
    [83930] = { priority = 1, power = true, auradetect = true, noSelf = true }, -- Trapping Bolt (Trapjaw)

    -- World Boss - Spider Nest
    [84150] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Call of the Brood (Old Widow Silk)
    [84151] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 400 }, -- Constricting Webs (Old Widow Silk)
    [84548] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossName = true, duration = 5100, refire = 1200 }, -- Venom Spray (Old Widow Silk)
    -- [84159] = { dodge = true, priority = 1, result = ACTION_RESULT_BEGIN, duration = 100, postCast = 500 }, -- Spit Poison (Old Widow Silk)
    [84161] = { priority = 1, avoid = true, auradetect = true, bossName = true, refire = 10000, hiddenDuration = 10000 }, -- Spit Poison (Old Widow Silk)

    -- World Boss - Mudcrab Beach
    [82965] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 7233 }, -- Crabuchet (Titanclaw)

    -- World Boss - Valeguard Tower
    [84037] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 700 }, -- Petrifying Bellow (Menhir Stoneskin)
    [84292] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 500 }, -- Graven Slash (Menhir Stoneskin)
    [84014] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Awaken (Menhir Stoneskin)
    [84029] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Awaken (Menhir Stoneskin)
    [84417] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Awaken (Menhir Stoneskin)

    -- World Boss - Magdelena's Haunt
    [83922] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 500, postCast = 1500 }, -- Curse of Terror (Magdelena)
    [83880] = { priority = 1, power = true, auradetect = true, duration = 8000 }, -- Reflective Shadows (Magdelena)
    [83227] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Dark Resurrection (Magdelena)

    --------------------------------------------------
    -- MAIN QUEST ------------------------------------
    --------------------------------------------------

    -- MSQ Tutorial (Soul Shriven in Coldharbour)
    -- [61748] = { block = true, priority = 1}, -- Heavy Attack (Tutorial) -- Default game tutorials display regardless
    -- [61916] = { interrupt = true, priority = 1}, -- Heat Wave (Tutorial) -- Default game tutorials display regardless
    [63737] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack (Tutorial)
    [63684] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2200, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Uppercut (Tutorial)
    [63761] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Pound (Tutorial)
    [63752] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 2750, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Vomit (Tutorial)
    [63521] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 2500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Bone Crush (Tutorial)

    -- MSQ 2 (Daughter of Giants)
    [27767] = { priority = 2, block = true, bs = true, dodge = true }, -- Rending Leap (Ancient Clannfear)
    [28788] = { priority = 2, block = true, eventdetect = true }, -- MQ2_Boss1_Doom-Truth'sGaze (Manifestation of Terror)
    [28723] = { priority = 2, avoid = true, eventdetect = true, refire = 500 }, -- Gravity Well (Manifestation of Terror)

    -- MSQ 4 (Castle of the Worm)
    [34484] = { priority = 2, block = true, avoid = true, refire = 500 }, -- Soul Cage (Mannimarco)

    -- MSQ 6 (Halls of Torment)
    [36858] = { priority = 2, avoid = true, interrupt = true, eventdetect = true, refire = 1500 }, -- Swordstorm (Tharn Doppleganger)
    [37173] = { priority = 2, interrupt = true, eventdetect = true }, -- Flame Shield (Duchess of Anguish)
    [38729] = { priority = 2, block = true, interrupt = true, refire = 500 }, -- Royal Strike (Duchess of Anguish)

    -- MSQ 7 (Shadow of Sancre Tor)
    [39302] = { priority = 2, interrupt = true, eventdetect = true, refire = 1000 }, -- Necromantic Revival
    [38215] = { priority = 2, interrupt = true, refire = 1000 }, -- Death's Gaze (Mannimarco)
    [40425] = { priority = 2, avoid = true }, -- Impending Doom (Mannimarco)
    [40973] = { priority = 2, power = true, eventdetect = true }, -- Portal Spawn (Mannimarco)
    [40978] = { priority = 2, power = true, eventdetect = true }, -- Portal Spawn (Mannimarco)
    [40981] = { priority = 2, power = true, eventdetect = true }, -- Portal Spawn (Mannimarco)

    --------------------------------------------------
    -- GUILD QUESTS ----------------------------------
    --------------------------------------------------

    -- The Prismatic Core
    [39577] = { priority = 2, block = true, interrupt = true }, -- Palolel's Rage (Queen Palolel)

    -- Will of the Council
    [28939] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, duration = 6500, refire = 2200, postCast = 2000 }, -- Heat Wave (Sees-All-Colors)

    -- The Mad God's Bargain
    [39555] = { priority = 2, interrupt = true, eventdetect = true, refire = 1500 }, -- Summon Scamp (Haskill)
    [39527] = { priority = 2, block = true, avoid = true, interrupt = true, refire = 1500 }, -- Skeleton Trap (Haskill)
    [35533] = { priority = 2, interrupt = true, refire = 1500 }, -- Polymorph (Haskill)
    [39391] = { priority = 2, interrupt = true, eventdetect = true, refire = 1500 }, -- Summon Pig (Haskill)

    --------------------------------------------------
    -- AD QUESTS -------------------------------------
    --------------------------------------------------

    -- Rites of the Queen
    [48921] = { priority = 2, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Norion }, -- Ancestral Spirit
    [48924] = { priority = 2, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Norion }, -- Ancestral Spirit
    [48927] = { priority = 2, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Norion }, -- Ancestral Spirit

    -- Sever All Ties
    [44138] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, fakeName = UnitNames.Boss_High_Kinlady_Estre, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Q4261 Estre Knockback (High Kinlady Estre)

    -- The Grips of Madness
    [38748] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, cc = LUIE_CC_TYPE_STUN, duration = 3000 }, -- Aulus's Tongue (Mayor Aulus)
    [40702] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Mayor_Aulus, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Q4868 Aulus Knockback (Mayor Aulus)

    -- A Lasting Winter
    [38413] = { priority = 2, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = UnitNames.Elite_General_Endare }, -- Spawn Clone (General Endare)

    -- The Orrery of Elden Root
    [43820] = { priority = 2, result = ACTION_RESULT_BEGIN, dodge = true, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Prince_Naemon, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1970 }, -- Quaking Stomp (Prince Naemon)
    [43827] = { priority = 2, avoid = true, eventdetect = true, auradetect = true, duration = 2916 }, -- Projectile Vomit (Prince Naemon)

    -- Striking at the Heart
    [48491] = { priority = 2, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Prince_Naemon, refire = 120000 }, -- Q4960 Naemon Shield Shade (Shade of Naemon)
    [48498] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Prince_Naemon, refire = 120000 }, -- Q4960 Necor Skele Rise (Shade of Naemon)

    --------------------------------------------------
    -- VVARDENFELL -----------------------------------
    --------------------------------------------------

    -- Tutorial
    -- [83416] = { block = true, priority = 1}, -- Heavy Attack (Tutorial) -- Default game tutorials display regardless
    -- [92233] = { interrupt = true, priority = 1}, -- Throw Dagger (Tutorial) -- Default game tutorials display regardless
    [92668] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.NPC_Slaver_Cutthroat, duration = 2533, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Whirlwind (Slaver Cutthroat)

    -- TODO: THE REST OF THESE NON-TUTORIAL

    -- Main Quest
    [87958] = { priority = 2, avoid = true, interrupt = true }, -- Ash Storm (Divine Delusions)
    [90139] = { priority = 2, block = true, bs = true, dodge = true }, -- Empowered Strike (Divine Intervention)
    [87038] = { priority = 2, block = true, bs = true, dodge = true }, -- Spinning Blades (Divine Restoration)
    [87047] = { priority = 2, block = true, dodge = true, refire = 1500 }, -- Lunge (Divine Restoration)
    [87090] = { priority = 2, block = true, dodge = true }, -- Barbs (Divine Restoration)
    [90616] = { priority = 2, block = true, avoid = true, refire = 10000 }, -- Divine Hijack (Divine Restoration)

    -- Sidequests
    [92720] = { priority = 2, block = true, avoid = true }, -- Necrotic Wave (Ancestral Adversity)
    [77541] = { priority = 2, block = true, dodge = true }, -- Brand's Cleave (The Heart of a Telvanni)

    -- Delves/Public Dungeons/World
    [88427] = { priority = 3, block = true, bs = true, dodge = true, auradetect = true }, -- Charge (Kwama Worker - Matus-Akin Egg Mine)

    [86983] = { priority = 2, interrupt = true }, -- Succubus Touch (Echoes of a Fallen House)
    [86930] = { priority = 2, block = true, dodge = true, interrupt = true }, -- Volcanic Debris (The Forgotten Wastes)
    [92702] = { priority = 2, block = true, dodge = true, interrupt = true }, -- Volcanic Debris (The Forgotten Wastes)

    [89210] = { priority = 3, block = true, avoid = true }, -- Boulder Toss (Nchuleftingth - Mud-Tusk)

    [86570] = { priority = 3, block = true, dodge = true }, -- Shield Charge (Nchuleftingth - Renduril the Hammer)
    [90597] = { priority = 2, block = true, avoid = true }, -- Overcharge Expulsion

    --------------------------------------------------
    -- SUMMERSET -------------------------------------
    --------------------------------------------------

    [105601] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, avoid = true, duration = 1250, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Explosive Toxins (Yaghra Larva)
    [107282] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 1067, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Impale (Yaghra Nightmare)
    [105867] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 1200, postCast = 4000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Pustulant Explosion (Yaghra Nightmare)

    --------------------------------------------------
    -- ELSWEYR ---------------------------------------
    --------------------------------------------------

    [121475] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1300, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Devastating Leap (Bone Flayer)
    [121473] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 2400, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Flurry (Bone Flayer)

    [121643] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, duration = 2800, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Defiled Ground (Euraxian Necromancer)

    [125281] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Bahlokdaan, duration = 4400, refire = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Sweeping Breath (Bahlokdaan)
    [125244] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Bahlokdaan, cc = LUIE_CC_TYPE_STUN, duration = 1567, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Head Strike (Bahlokdaan)
    [125570] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Chomp (Bahlokdaan)
    [122200] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Chomp (Bahlokdaan)
    [122201] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Chomp (Bahlokdaan)
    [125241] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Bahlokdaan, cc = LUIE_CC_TYPE_STUN, duration = 1567, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Tail Whip (Bahlokdaan)
    [125242] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Bahlokdaan, cc = LUIE_CC_TYPE_STUN, duration = 1533, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Wing Thrash (Bahlokdaan)
    [125243] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Bahlokdaan, cc = LUIE_CC_TYPE_STUN, duration = 1533, sound = LUIE_ALERT_SOUND_TYPE_AOE_CC }, -- Wing Thrash (Bahlokdaan)

    --------------------------------------------------
    -- GREYMOOR ---------------------------------------
    --------------------------------------------------

    [135718] = { priority = 2, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, cc = LUIE_CC_TYPE_SNARE, duration = 1500, postCast = 2300, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Frost Vines (Matron Urgala)
    [135612] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true, interrupt = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE, duration = 4500, refire = 2000, sound = LUIE_ALERT_SOUND_TYPE_TRAVELER }, -- Frost Wave (Matron Urgala)

    --------------------------------------------------
    -- ARENAS ----------------------------------------
    --------------------------------------------------

    -- Dragonstar Arena

    -- Stage 1
    [52729] = { priority = 1, power = true, auradetect = true }, -- Expert Hunter (Fighters Guild Swordmaster)
    [52738] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true }, -- Ring of Preservation (Fighters Guild Gladiator)
    [82996] = { priority = 1, power = true, auradetect = true }, -- Enrage (Fighters Guild Gladiator)

    [52746] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Champion_Marcauld }, -- Flawless Dawnbreaker (Champion Marcauld)

    -- Stage 2 - The Frozen Ring
    [53264] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true }, -- Rally (Sovngarde Slayer)
    [53313] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, refire = 1500 }, -- Volley (Sovngarde Slayer)

    [53286] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true }, -- Crushing Shock (Sovngarde Icemage)
    [53274] = { priority = 1, avoid = true, auradetect = true, bossMatch = { UnitNames.Boss_Katti_Ice_Turner } }, -- Unstable Wall of Frost (Sovngarde Icemage)

    [53250] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true }, -- Wrecking Blow (Yavni Frost-Skin)
    [53301] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Katti_Ice_Turner } }, -- Icy Pulsar (Katti Ice-Turner)

    -- Stage 3 - The Marsh
    [8244] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true }, -- Devastate (Corprus Husk)
    [8247] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, refire = 1750 }, -- Vomit (Corprus Husk)
    -- [22109] = { avoid = true, priority = 3, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true, refire = 250 }, -- Contaminate (Corprus Husk)

    [83493] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, refire = 1000 }, -- CLST - Poison Cloud (Poison Cloud)

    [56796] = { priority = 1, power = true, auradetect = true }, -- Bound Aegis (Dragonclaw Hedge Wizard)

    [53613] = { priority = 1, power = true, auradetect = true }, -- Thundering Presence (Nak'tah)
    [53624] = { priority = 1, avoid = true, auradetect = true, bossMatch = { UnitNames.Boss_Nak_tah } }, -- Lightning Flood (Nak'tah)
    [53659] = { priority = 1, block = true, avoid = true, interrupt = true, auradetect = true }, -- Power Overload Heavy Attack (Nak'tah)

    -- Stage 4 - The Slave Pit
    [54160] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.NPC_House_Dres_Slaver, refire = 750 }, -- Berserker Frenzy (House Dres Slaver)
    [83774] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, refire = 750 }, -- Enslavement (House Dres Slaver)

    [54056] = { priority = 1, power = true, auradetect = true, refire = 500 }, -- Molten Armaments (Earthen Heart Knight)
    [54065] = { priority = 1, power = true, auradetect = true, ignoreRefresh = true }, -- Igneous Shield (Earthen Heart Knight)
    [54077] = { priority = 1, avoid = true, auradetect = true, bossMatch = { UnitNames.Boss_Earthen_Heart_Knight } }, -- Cinder Storm (Earthen Heart Knight)
    [54053] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, reflect = true }, -- Stone Giant (Earthen Heart Knight)
    [54083] = { priority = 1, power = true, auradetect = true }, -- Corrosive Armor (Earthen Heart Knight)
    [54067] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true }, -- Fossilize (Earth Heart Knight)

    -- Stage 5 - The Celestial Ring
    [54411] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, fakeName = UnitNames.NPC_Anka_Ra_Shadowcaster }, -- Celestial Blast (Anka-Ra Shadowcaster)
    [54404] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, unmit = true, fakeName = UnitNames.NPC_Anka_Ra_Shadowcaster }, -- Celestial Blast (Anka-Ra Shadowcaster)
    [52897] = { priority = 1, avoid = true, auradetect = true, bossName = true }, -- Standard of Might (Anal'a Tu'wha)
    [52891] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Anala_tuwha } }, -- Flames of Oblivion (Anal'a Tu'wha)

    -- Stage 6 - The Grove
    [54608] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true }, -- Drain Resource (Pacthunter Ranger)
    -- [54512] = { power = true, priority = 1, result = ACTION_RESULT_EFFECT_GAINED, eventdetect = true }, -- Regeneration Aura (Nature's Blessing)
    [52820] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true }, -- Acid Spray (Pishna Longshot)
    [52825] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true }, -- Lethal Arrow (Pishna Longshot)

    -- Stage 7 - Circle of Rituals
    [56946] = { priority = 1, power = true, auradetect = true }, -- Dragon Fire Scale (Bloodwraith Kynval)
    [54634] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, auradetect = true }, -- CLDA - Sacrifice (Daedric Sacrifice)
    [54635] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, auradetect = true }, -- CLDA - Sacrifice (Daedric Sacrifice)
    [54612] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, auradetect = true }, -- CLDA - Sacrifice (Daedric Sacrifice)

    [52907] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true }, -- Dark Flare (Shadow Knight)
    [52912] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true }, -- Purifying Light (Shadow Knight)
    [52927] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Shadow_Knight, bossMatch = { UnitNames.Boss_Hiath_the_Battlemaster } }, -- Solar Disturbance (Shadow Knight)

    [54792] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, reflect = true }, -- Crystal Blast (Dark Mage)
    [54819] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Dark_Mage } }, -- Daedric Minefield (Dark Mage)
    [54829] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Dark_Mage, bossMatch = { UnitNames.Boss_Hiath_the_Battlemaster } }, -- Suppression Field (Dark Mage)
    [54809] = { priority = 1, interrupt = true, auradetect = true }, -- Dark Deal (Dark Mage)

    -- Stage 8 - Steamworks
    [54841] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true }, -- Ice Charge (Dwarven Ice Centurion)
    [56065] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, noSelf = true }, -- Ice Charge (Dwarven Ice Centurion)
    [72180] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, interrupt = true, eventdetect = true, fakeName = UnitNames.NPC_Dwarven_Sphere }, -- Electric Wave (Dwarven Sphere)

    [52773] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true }, -- Ice Comet (Mavus Talnarith)
    [52765] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Mavus_Talnarith }, -- Volcanic Rune (Mavus Talnarith)

    -- Stage 9 - Crypts of the Lost
    [56985] = { priority = 1, power = true, auradetect = true }, -- Spirit Shield (Zakael/Rubyn Jonnicent)
    [55089] = { priority = 1, avoid = true, auradetect = true }, -- Poison Mist (Vampire Lord Thisa)
    [55090] = { priority = 1, avoid = true, auradetect = true }, -- Devouring Swarm (Vampire Lord Thisa)
    [55081] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, fakeName = UnitNames.Boss_Vampire_Lord_Thisa, noSelf = true }, -- Vampire Lord Thisa

    [55479] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true }, -- Malefic Wreath (Hiath the Battlemaster)
    [55496] = { priority = 1, power = true, auradetect = true }, -- Power Extraction (Hiath the Battlemaster)
    [55174] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, unmit = true }, -- Marked for Death (Hiath the Battlemaster)

    -- Maelstrom Arena

    -- Stage 1 - Vale of the Surreal
    [70892] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, bossName = true }, -- Bone Cage (Maxus the Many)
    [72148] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, bossName = true }, -- Bone Cage (Maxus the Many)
    [67765] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Multiply (Maxus the Many)
    [67656] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Multiply (Maxus the Many)
    [69515] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Multiply (Maxus the Many)
    [67691] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, bossName = true }, -- Reunite (Maxus the Many)

    -- Stage 2 - Seht's Balcony
    -- [71047] = { block = true, avoid = true, priority = 3, result = ACTION_RESULT_BEGIN }, -- Thunderbolt (Clockwork Sentry)
    [72067] = { priority = 2, power = true, auradetect = true }, -- Energizing (Clockwork Sentry)
    [69364] = { priority = 1, avoid = true, auradetect = true }, -- Barrage Function (Centurion Champion)
    [66904] = { priority = 1, power = true, auradetect = true }, -- Full Defense (Centurion Champion)

    -- Stage 3 - The Drome of Toxic Shock
    [67635] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true }, -- Shock Water (Lamia Queen)
    [73879] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true }, -- Lightning X (Lamia Queen)
    [67757] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true }, -- Queen's Poison (Lamia Queen)
    [68357] = { priority = 1, power = true, auradetect = true }, -- Queen's Radiance (Lamia Queen)
    [73876] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, refire = 1000 }, -- Piercing Shriek (Lamia Queen)

    -- Stage 4 - Seht's Flywheel
    [71045] = { priority = 1, power = true, auradetect = true }, -- Turret Mode (Clockwork Sentry)
    [71050] = { priority = 1, power = true, auradetect = true, ignoreRefresh = true }, -- Static Shield (Clockwork Sentry)
    [73850] = { priority = 1, power = true, auradetect = true, ignoreRefresh = true }, -- Static Shield (Clockwork Sentry)
    [69268] = { priority = 1, power = true, auradetect = true }, -- Enrage (Achelir)

    [72157] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true, fakeName = UnitNames.NPC_Dwarven_Spider }, -- Static Field (Dwarven Spider)
    [72166] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, block = true, avoid = true, eventdetect = true, refire = 250, neverShowInterrupt = true }, -- Overcharge (Dwarven Spider)
    [72174] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, block = true, avoid = true, eventdetect = true, refire = 250, neverShowInterrupt = true }, -- Overcharge (Dwarven Spider)

    [68524] = { priority = 1, power = true, auradetect = true }, -- Overcharged (The Control Guardian)
    [68539] = { priority = 1, power = true, auradetect = true }, -- Overheated (The Control Guardian)
    [68558] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, refire = 20000 }, -- Overheated Volley (The Control Guardian)

    [72195] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true }, -- Thunder Hammer (Scavenger Thunder-Smith)
    [72198] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, dodge = true }, -- Wrecking Blow (Scavenger Thunder-Smith)
    [72202] = { priority = 2, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.NPC_Scavenger_Thunder_Smith }, -- Overcharge (Scavenger Thunder-Smith)

    -- Stage 5 - Rink of Frozen Blood

    [70898] = { priority = 2, summon = true, auradetect = true, fakeName = "" }, -- Call Ally (Huntsman Chillbane)
    [71939] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true }, -- Frost Breath (Huntsman Chillbane)
    [71937] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true }, -- Frost Nova (Huntsman Chillbane)

    [72446] = { priority = 1, interrupt = true, auradetect = true }, -- Smash Iceberg (Troll Breaker)
    [71926] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true }, -- Frenzy of Blows (Angirgoth)

    [72438] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true }, -- Shatter (Giant)
    [68439] = { priority = 1, power = true, auradetect = true }, -- Enrage (Aki/Vigi)
    [74130] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true }, -- Intimidating Roar (Aki/Vigi)

    [66378] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true }, -- Sweep (Matriarch Runa)
    [72749] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, eventdetect = true, bossName = true }, -- Freezing Stomp (Matriarch Runa)
    [67088] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true }, -- Intimidating Roar (Matriarch Runa)
    [66325] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true }, -- Shatter (Matriarch Runa)
    [72409] = { priority = 1, avoid = true, auradetect = true }, -- Taunt (Matriarch Runa)

    --------------------------------------------------
    -- DUNGEONS --------------------------------------
    --------------------------------------------------

    -- Banished Cells I
    [19028] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, duration = 5050, refire = 1500 }, -- Drain Essence (Cell Haunter)
    [47587] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 3000 }, -- Tail Smite (Shadowrend)
    [21886] = { priority = 1, summon = true, auradetect = true, bossName = true }, -- Summon Dark Proxy (Shadowrend)
    [18772] = { priority = 1, interrupt = true, auradetect = true, fakeName = "", duration = 3000, effectOnlyInterrupt = true, noSelf = true }, -- Feeding (Shadowrend)
    [18708] = { priority = 1, summon = true, auradetect = true, bossName = true }, -- Summon Clannfear (Angata the Clannfear Handler)
    [19025] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 1500, postCast = 4000 }, -- Dead Zone (Skeletal Destroyer)

    [33189] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Crushing Blow (High Kinlord Rilis)
    [18840] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, hiddenDuration = 750 }, -- Soul Blast (High Kinlord Rilis)
    [18875] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 2600, refire = 1500, postCast = 5000 }, -- Daedric Tempest (High Kinlord Rilis)
    [18795] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, destroy = true, eventdetect = true, bossName = true, refire = 1000 }, -- CON_Invisible_30%_Speed_Debuff (The Feast)

    -- Banished Cells II
    [48271] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossName = true, duration = 4000, refire = 2500 }, -- Breath of Flame (Maw of the Infernal)
    [27826] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, cc = LUIE_CC_TYPE_STUN, duration = 2000 }, -- Crushing Blow (Keeper Voranil)
    [29018] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 3550, refire = 750 }, -- Berserker Frenzy (Keeper Voranil)
    [28750] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1750 }, -- Essence Siphon (Keeper Voranil)

    [32038] = { priority = 1, power = true, auradetect = true, hiddenDuration = 2500 }, -- Into Portal
    [36631] = { priority = 1, power = true, auradetect = true, bossName = true, hiddenDuration = 2500 }, -- ExitPortal

    [29143] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 2000 }, -- Daedric Blast (Keeper Imiril)
    [28962] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true }, -- Sister's Love (Sister Sihna / Sister Vera)
    [48799] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 1000, refire = 1500, postCast = 5000 }, -- Daedric Tempest (High Kinlord Rilis)
    [48814] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 1000, refire = 1500, postCast = 5000 }, -- Daedric Tempest (High Kinlord Rilis)
    [28570] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, duration = 1000 }, -- Levitate (High Kinlord Rilis)
    [28462] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, duration = 1000 }, -- Levitate (High Kinlord Rilis)
    [46967] = { priority = 1, power = true, auradetect = true, hiddenDuration = 2500 }, -- Daedric Step (High Kinlord Rilis)
    [88070] = { priority = 1, summon = true, auradetect = true, fakeName = "", bossMatch = { UnitNames.Boss_High_Kinlord_Rilis }, refire = 5000, hideIfNoSource = true }, -- Creeping Doom (Harvester)

    -- Elden Hollow I
    [16834] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2000 }, -- Executioner's Strike (Akash gra-Mal)
    [15999] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 750 }, -- Leaping Strike (Akash gra-Mal)
    [16016] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 3550 }, -- Berserker Frenzy (Akash gra-Mal)

    [9910] = { priority = 1, result = ACTION_RESULT_BEGIN, destroy = true, eventdetect = true, bossName = true }, -- Summon Saplings (Chokethorn)
    [9930] = { priority = 1, interrupt = true, auradetect = true, fakeName = UnitNames.NPC_Strangler_Saplings, effectOnlyInterrupt = true, alwaysShowInterrupt = true }, -- Heal Spores (Chokethorn)
    [9875] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2000, neverShowInterrupt = true }, -- Fungal Burst (Chokethorn)

    [44223] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Leafseether, cc = LUIE_CC_TYPE_STAGGER, duration = 1750 }, -- Inhale (Leafseether)

    [9845] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 2000, neverShowInterrupt = true }, -- Rotting Bolt (Canonreeve Oraneth)
    [16262] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 2000, postCast = 6000 }, -- Necrotic Circle (Canonreeve Oraneth)
    [9944] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 3000 }, -- Necrotic Burst (Canonreeve Oraneth)
    [9839] = { priority = 1, power = true, auradetect = true, ignoreRefresh = true }, -- Bone Hurricane (Canonreeve Oraneth)
    [25820] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true, refire = 5000 }, -- Necrotic Circle (Canonreeve Oraneth)

    -- Elden Hollow II
    [34376] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_FEAR, duration = 3300, refire = 2000 }, -- Flame Geyser (Dubroze the Infestor)
    [32707] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true }, -- Summon Guardians (Dark Root)
    [33334] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, fakeName = UnitNames.NPC_Frenzied_Guardian, alwaysShowInterrupt = true, hiddenDuration = 1800 }, -- Latch On Stamina (Frenzied Guardian)
    [33337] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, fakeName = UnitNames.NPC_Mystic_Guardian, alwaysShowInterrupt = true, hiddenDuration = 1800 }, -- Latch On Magicka (Mystic Guardian)
    [32890] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true, bossName = true }, -- Gleaming Light (Dark Root)
    [33533] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true, bossName = true }, -- Glaring Light (Dark Root)
    [33535] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true, bossName = true }, -- Brightening Light (Dark Root)

    [33170] = { priority = 1, destroy = true, auradetect = true, bossName = true }, -- Hate (Shadow Tendril)

    [33052] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 900 }, -- Shadow Stomp (Murklight)
    [32832] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 4700, refire = 1750, neverShowInterrupt = true, postCast = 4000 }, -- Consuming Shadow (Murklight)
    [32975] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 2000, neverShowInterrupt = true, postCast = 4000 }, -- Eclipse (Murklight)

    [33102] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 5000, refire = 1250, postCast = 4000 }, -- Spout Shadow (The Shadow Guard)

    [33432] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 4300, postCast = 4000 }, -- Daedric Flame (Bogdan the Nightflame)
    [33480] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true, duration = 1500 }, -- Pulverize (Bogdan the Nightflame)
    [33492] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true, duration = 1500 }, -- Pulverize (Bogdan the Nightflame)
    [33494] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true, duration = 1500 }, -- Pulverize (Bogdan the Nightflame)
    [34260] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, destroy = true, eventdetect = true, bossName = true, refire = 1000 }, -- Shadow (Nova Tendril)

    -- City of Ash I
    [31101] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossName = true, duration = 1200 }, -- Cleave (Golor the Banekin Handler)
    [25034] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_POWER_ATTACK }, -- Crushing Blow (Golor the Banekin Handler)
    [33604] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true }, -- Summon Banekin (Golor the Banekin Handler)

    [34607] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1500 }, -- Measured Uppercut (Warden of the Shrine)
    [34654] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, auradetect = true, bossName = true }, -- Fan of Flames (Warden of the Shrine)
    [34620] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, auradetect = true, bossName = true }, -- Fan of Flames (Warden of the Shrine)

    [34190] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, cc = LUIE_CC_TYPE_STAGGER, duration = 550 }, -- Thorny Backhand (Infernal Guardian)
    [34189] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2000 }, -- Ground Slam (Infernal Guardian)
    [35061] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 8000 }, -- Consuming Fire (Infernal Guardian)
    [34183] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, cc = LUIE_CC_TYPE_STAGGER, duration = 800, postCast = 2000 }, -- Tunneling Roots (Infernal Guardian)

    [44278] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, avoid = true, duration = 2000, spreadOut = true }, -- Lava Geyser (Dark Ember)

    [34198] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true }, -- Burning Field (Rothariel Flameheart)
    [34205] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, auradetect = true }, -- Deception (Rothariel Flameheart)

    [34901] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 1500 }, -- Blazing Arrow (Razor Master Erthas)
    [34805] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true }, -- Release Flame (Razor Master Erthas)
    [34623] = { priority = 1, summon = true, auradetect = true, bossName = true }, -- Summon Flame Atronach (Razor Master Erthas)
    [34780] = { priority = 1, summon = true, auradetect = true, bossName = true }, -- Summon Flame Atranach (Razor Master Erthas)
    [34892] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, bossName = true, hiddenDuration = 2500 }, -- Body of Flame (Razor Master Erthas)

    -- City of Ash II
    [53999] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Rukhan }, -- Summon (Flame Atronach)
    [54021] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Marruz } }, -- Release Flame (Marruz)
    [53976] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 1500 }, -- Blazing Arrow (Marruz)
    [54025] = { priority = 1, interrupt = true, auradetect = true, fakeName = UnitNames.Boss_Akezel, duration = 7000, effectOnlyInterrupt = true }, -- Spell Absorption (Akezel)
    [53994] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true, fakeName = UnitNames.Boss_Akezel, duration = 3000 }, -- Focused Healing (Akezel)
    [54096] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Rukhan, cc = LUIE_CC_TYPE_STUN, duration = 2500 }, -- Pyrocasm (Rukhan)

    [56811] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, cc = LUIE_CC_TYPE_STUN, duration = 2500 }, -- Pyrocasm (Xivilai Ravager)

    [56414] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, bossName = true, duration = 1000, postCast = 3000 }, -- Fire Runes (Urata the Legion)
    [54225] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Multiply (Urata the Legion)
    [56098] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Multiply (Urata the Legion)
    [56104] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Multiply (Urata the Legion)
    [56131] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, bossName = true, duration = 8000 }, -- Reunite (Urata the Legion)

    [56186] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = UnitNames.NPC_Flame_Colossus }, -- Voice to Wake the Dead (Bone Colossus)

    [55203] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STAGGER, duration = 850, neverShowInterrupt = true, postCast = 2500 }, -- Seismic Tremor (Horvantud the Fire Maw)
    [56002] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 13500, neverShowInterrupt = true }, -- Ground Quake (Horvantud the Fire Maw)
    [55312] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 4200, neverShowInterrupt = true }, -- Slag Breath (Horvantud the Fire Maw)
    [55333] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 3000, neverShowInterrupt = true }, -- Fiery Breath (Horvantud the Fire Maw)
    [55320] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 4200, neverShowInterrupt = true }, -- Fiery Breath (Horvantud the Fire Maw)
    [55335] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 3000, neverShowInterrupt = true }, -- Fiery Breath (Horvantud the Fire Maw)
    [55326] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 4200, neverShowInterrupt = true }, -- Fiery Breath (Horvantud the Fire Maw)
    [55337] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 3000, neverShowInterrupt = true }, -- Fiery Breath (Horvantud the Fire Maw)
    [57618] = { priority = 1, power = true, auradetect = true, ignoreRefresh = true }, -- Damage Shield (Horvantud the Fire Maw)
    [55315] = { priority = 1, power = true, auradetect = true }, -- Slag Breath (Horvantud the Fire Maw)
    [55324] = { priority = 1, power = true, auradetect = true }, -- Enrage 2 (Horvantud the Fire Maw)
    [55329] = { priority = 1, power = true, auradetect = true }, -- Enrage 3 (Horvantud the Fire Maw)

    [54218] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1500, neverShowInterrupt = true }, -- Monstrous Cleave (Ash Titan)
    [54895] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossName = true, duration = 7700 }, -- Molten Rain (Ash Titan)
    [54698] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 3000, neverShowInterrupt = true, postCast = 4000 }, -- Fire Swarm (Ash Titan)

    [58468] = { priority = 1, power = true, auradetect = true }, -- Shadow Cloak (Ash Titan)
    [54783] = { priority = 1, power = true, auradetect = true }, -- Air Atronach Flame (Air Atronach)
    [54366] = { priority = 1, avoid = true, auradetect = true, duration = 15000, effectOnlyInterrupt = true }, -- Flame Tornado (Air Atronach)
    [60683] = { priority = 1, power = true, auradetect = true, ignoreRefresh = true }, -- Flame Tornado (Air Atronach)

    [58280] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true }, -- Scary Summon 1 (Xivilai Fulminator / Boltaic)
    [56601] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true, refire = 2000 }, -- Scary Summon 2 (Xivilai Fulminator / Boltaic)

    [55513] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1500 }, -- Flame Bolt (Valkyn Skoria)
    [55387] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1600 }, -- Meteor Strike (Valkyn Skoria)
    [55514] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 1250, postCast = 4000 }, -- Call the Flames (Valkyn Skoria)
    [55426] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2000 }, -- Magma Prison (Valkyn Skoria)
    [55024] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STAGGER, duration = 3000 }, -- Lava Quake (Valkyn Skoria)
    [55500] = { priority = 1, power = true, auradetect = true, ignoreRefresh = true }, -- Rock Shield (Valkyn Skoria)
    [55623] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true, refire = 5000 }, -- Flame Atronach (Valkyn Skoria)
    [55059] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, bossName = true, hiddenDuration = 2500 }, -- Body of Flame (Valkyn Skoria)

    -- Tempest Island
    [46732] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STAGGER, duration = 2300, refire = 1000 }, -- Sonic Scream (Sonolia the Matriarch)

    [26370] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Slash (Valaran Stormcaller)
    [26628] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, cc = LUIE_CC_TYPE_STUN, duration = 1500 }, -- Enervating Bolt (Valaran Stormcaller)
    [26592] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true }, -- Lightning Avatar (Valaran Stormcaller)

    [6106] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_SNARE, duration = 1867, postCast = 4000 }, -- Lightning Storm (Yalorasse the Speaker)

    [26748] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 5100, refire = 1000 }, -- Enervating Stone (Stormfist)
    [26714] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Skyward Slam (Stormfist)
    [26833] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Summon Storm Atronach (Stormfist)
    [26790] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, bossName = true, refire = 60000 }, -- Unstable Explosion (Stormfist)

    [27039] = { priority = 1, interrupt = true, auradetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 7500, effectOnlyInterrupt = true, noSelf = true }, -- Ethereal Chain (Commodore Ohmanil)

    [27596] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, duration = 1483 }, -- Lightning Strike (Stormreeve Neider)
    [26741] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, hiddenDuration = 1000 }, -- Swift Wind (Stormreeve Neider)
    [26712] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 3000 }, -- Gust of Wind (Stormreeve Neider)

    -- Selene's Web
    [30909] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 5600, refire = 2000 }, -- Ensnare (Treethane Kerninn)
    [30907] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 6200 }, -- Summon Primal Swarm (Treethane Kerninn)

    [30781] = { priority = 1, power = true, auradetect = true }, -- Mirror Ward (Longclaw)
    [30772] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 8000, refire = 1250, neverShowInterrupt = true }, -- Arrow Rain (Longclaw)
    [30779] = { priority = 1, summon = true, auradetect = true, fakeName = "", refire = 500 }, -- Spirit Form (Senche Spirit)
    [31096] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 600, postCast = 4000 }, -- Poison Burst (Longclaw)

    [31202] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 400, postCast = 1000 }, -- Venomous Burst (Queen Aklayah)
    [31205] = { priority = 1, power = true, auradetect = true, duration = 6000, noSelf = true }, -- Venomous Burst (Queen Aklayah)

    [30996] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 1800 }, -- Vicious Maul (Foulhide)
    [30812] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 2250, postCast = 2000 }, -- Trampling Charge (Foulhide)
    [31002] = { priority = 1, summon = true, auradetect = true, fakeName = "", refire = 5000 }, -- Intro (Selene's Rose)

    [31241] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true }, -- Summon Spiders (Mennir Many-Legs)

    [31048] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 400 }, -- Web Wrap (Selene)
    [31052] = { priority = 1, power = true, auradetect = true, duration = 30000, effectOnlyInterrupt = true, noSelf = true }, -- Web Wrap (Selene)
    [30731] = { priority = 1, block = true, dodge = true, auradetect = true, cc = LUIE_CC_TYPE_STUN, duration = 2150 }, -- Summon Primal Spirit (Selene)
    [30896] = { priority = 1, dodge = true, auradetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, hiddenDuration = 1900 }, -- Summon Senche Spirit (Selene)

    [31986] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true }, -- Summon Melee (Selene)
    [31984] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true }, -- Summon Healer (Selene)
    [31985] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true }, -- Summon Archer (Selene)

    -- Spindleclutch I
    [46147] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Summon Swarm (Spindlekin)

    [22034] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Inject Poison (Swarm Mother)
    [17964] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, cc = LUIE_CC_TYPE_SNARE }, -- Impeding Webs (Swarm Mother)
    [17960] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1000, postCast = 500 }, -- Arachnid Leap (Swarm Mother)
    [18559] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true, refire = 1000 }, -- Spawn Broodling (Swarm Mother)

    [18111] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1500, postCast = 500 }, -- Arachnophobia (Swarm Mother)
    [18078] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 1200 }, -- Web Blast (Swarm Mother)
    [35572] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1200 }, -- Grappling Web (Swarm Mother)
    [18058] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2500 }, -- Daedric Explosion (Swarm Mother)

    -- Spindleclutch II
    [28093] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Vicious Smash (Blood Spawn)
    [27995] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 2350 }, -- Cave-In (Blood Spawn)
    [47331] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true, refire = 60000 }, -- Cave-In (Blood Spawn)
    [47198] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, auradetect = true, fakeName = "", refire = 5000 }, -- Falling Rocks (Cave In)

    [28438] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, bossName = true }, -- Dummy (Praxin Douare)
    [18036] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true, fakeName = UnitNames.NPC_The_Whisperer_Nightmare, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000, refire = 2500 }, -- Grappling Web (The Whisperer Nightmare)

    [27965] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 1200, postCast = 3000 }, -- Despair (Praxin Douare)
    [27741] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 1500 }, -- Enervating Seal (Praxin Douare)
    [27703] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2500 }, -- Harrowing Ring (Praxin Douare)
    [61443] = { priority = 1, power = true, auradetect = true, noSelf = true }, -- Harrowing Ring (Praxin Douare)

    [27435] = { priority = 1, power = true, auradetect = true }, -- Monstrous Growth (Flesh Atronach)
    [27437] = { priority = 1, power = true, auradetect = true }, -- Monstrous Growth (Flesh Atronach)

    [27600] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, auradetect = true }, -- Blood Pool (Urvan Veleth)

    [27905] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 1500, postCast = 4000 }, -- Blood Pool (Vorenor Winterbourne)
    [27897] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, duration = 2000 }, -- Open Wounds (Vorenor Winterbourne)
    [27791] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, duration = 2000 }, -- Blood Frenzy (Vorenor Winterbourne)

    [31672] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, bossName = true, refire = 2500 }, -- Thrall Feast (Vorenor Winterbourne)

    -- Wayrest Sewers I
    [34846] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1500 }, -- Primal Sweep (Slimecraw)

    [9441] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Dark Lance (Investigator Garron)
    [25593] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true }, -- Summon Necrotic Orb (Investigator Garron)
    [9740] = { priority = 1, summon = true, auradetect = true, bossName = true }, -- Tormented Summoning (Restless Soul)

    [25548] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2000 }, -- Smite (Varaine Pellingare)
    [9648] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 2000 }, -- Spinning Cleave (Varaine Pellingare)
    [36435] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 733, postCast = 1000 }, -- Tidal Slash (Varaine Pellingare)
    [9656] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, duration = 500, postCast = 1000 }, -- Poisoned Blade (Varaine Pellingare)

    [11752] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Penetrating Daggers (Allene Pellingare)
    [35006] = { priority = 1, power = true, auradetect = true }, -- Hallucinogenic Fumes (Allene Pellingare)
    [35021] = { priority = 1, power = true, auradetect = true }, -- Mind-Bending Mist (Allene Pellingare)
    [35041] = { priority = 1, power = true, auradetect = true }, -- Mind-Bending Mist (Allene Pellingare)

    -- Wayrest Sewers II
    [36613] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Malubeth_the_Scourger, cc = LUIE_CC_TYPE_SNARE, duration = 3000, postCast = 4000 }, -- Scourging Spark (Malubeth the Scourger)
    [36431] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true, noSelf = true }, -- Rend Soul (Malubeth the Scourger)

    [36951] = { priority = 1, result = ACTION_RESULT_BEGIN, summon = true, eventdetect = true, fakeName = UnitNames.Boss_Skull_Reaper }, -- Voice to Wake the Dead (Bone Colossus)
    [48773] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.NPC_Risen_Dead, duration = 1500, refire = 1000 }, -- Necromantic Burst (Risen Dead)

    [36904] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Garron_the_Returned, duration = 5300 }, -- Necrotic Barrage (Garron the Returned)
    [36761] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Garron_the_Returned, cc = LUIE_CC_TYPE_STAGGER, duration = 2700 }, -- Necrotic Barrage (Garron the Returned)
    [36780] = { priority = 1, summon = true, auradetect = true, fakeName = UnitNames.Boss_Garron_the_Returned, refire = 2000 }, -- Summon Minion (Garron the Returned)
    [36838] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, fakeName = UnitNames.Boss_Garron_the_Returned, hiddenDuration = 2500 }, -- Deceptive Teleport (Garron the Returned)
    [36873] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true, fakeName = UnitNames.Boss_Garron_the_Returned, duration = 9000, refire = 10000 }, -- Consume Life (Garron the Returned)

    [36895] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_The_Forgotten_One, duration = 1000, postCast = 3500 }, -- Haunting Spectre (The Forgotten One)

    [49159] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, bossMatch = { UnitNames.Boss_Varaine_Pellingare }, duration = 100, postCast = 900 }, -- Cone of Rot (Varaine Pellingare)
    [36534] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 2500 }, -- Spinning Cleave (Varaine Pellingare)
    [36396] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Bludgeon (Varaine Pellingare)
    [35838] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, interrupt = true, duration = 1500 }, -- Necrotic Arrow (Allene Pellingare)
    [36537] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true }, -- Shield Sibling (Allene & Varaine Pellingare)
    [49053] = { priority = 1, power = true, auradetect = true, refire = 5000 }, -- Toxic Fumes (Allene Pellingare)

    -- Crypt of Hearts I
    [22714] = { priority = 1, avoid = true, auradetect = true, bossName = true }, -- Necrotic Ritual (Archmaster Siniel)
    [22768] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_FEAR }, -- Induce Horror (Archmaster Siniel)
    [46581] = { priority = 1, power = true, auradetect = true, hiddenDuration = 2500 }, -- Daedric Step (Archmaster Siniel)
    [22808] = { priority = 1, power = true, auradetect = true, ignoreRefresh = true }, -- Corpse Shield (Archmaster Siniel)
    [22787] = { priority = 1, unmit = true, auradetect = true }, -- Corpse Explosion (Archmaster Siniel)

    [111957] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STUN, duration = 1500, postCast = 1500 }, -- Trample (Death's Leviathan)
    [22527] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, bossName = true, duration = 2000 }, -- Paralyzing Slam (Death's Leviathan)
    [46680] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true, bossName = true, refire = 1000 }, -- Immolate Colossus (Death's Leviathan)

    [22450] = { priority = 1, avoid = true, auradetect = true, fakeName = UnitNames.Boss_Ilambris_Athor, neverShowInterrupt = true }, -- Summon Lightning Rod (Ilambris-Athor)
    [22338] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1500 }, -- Axe Strike (Ilambris-Athor)
    [32425] = { priority = 1, power = true, auradetect = true }, -- Lightning Empowerment (Ilambris-Athor)
    [22456] = { priority = 1, power = true, auradetect = true }, -- Lightning Omnipotence (Ilambris-Athor)
    [22397] = { priority = 1, avoid = true, auradetect = true, duration = 11000, neverShowInterrupt = true }, -- Call Lightning (Ilambris-Athor)
    [22342] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Ilambris_Zaven, duration = 1000, postCast = 1500 }, -- Rolling Fire (Ilambris-Zaven)
    [32424] = { priority = 1, power = true, auradetect = true }, -- Incensed (Ilambris-Zaven)
    [22390] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Ilambris_Zaven, cc = LUIE_CC_TYPE_STUN, duration = 2500 }, -- Pyrocasm (Ilambris-Zaven)
    [22457] = { priority = 1, power = true, auradetect = true }, -- Emit Flames (Ilambris-Zaven)
    [22383] = { priority = 1, avoid = true, auradetect = true, duration = 6100, neverShowInterrupt = true }, -- Rain Fire (Ilambris-Zaven)

    -- Crypt of Hearts II
    [51746] = { priority = 2, summon = true, auradetect = true, fakeName = UnitNames.NPC_Spiderkith_Broodnurse }, -- Summon the Dead (Spiderkith Broodnurse)
    [51753] = { priority = 2, summon = true, auradetect = true, fakeName = UnitNames.NPC_Spiderkith_Broodnurse }, -- Reanimate Skeleton (Spiderkith Broodnurse)
    [52040] = { priority = 2, result = ACTION_RESULT_BEGIN, eventdetect = true, fakeName = UnitNames.NPC_Spiderkith_Broodnurse, refire = 1000, shouldusecc = true, stack = 2 }, -- Summon Atronach (Ibelgast's Broodnurse)
    [52160] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, fakeName = UnitNames.NPC_Spiderkith_Broodnurse }, -- Flesh Atronach Rises (Ibelgast's Broodnurse)
    [53285] = { priority = 2, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, fakeName = UnitNames.NPC_Ogrim }, -- Summon (Ogrim)
    [51882] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 3000, postCast = 5000 }, -- Creeping Storm (Ruzozuzalpamaz)
    [52017] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 2000, postCast = 2200 }, -- Lightning Onslaught (Ruzozuzalpamaz)
    [53779] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, eventdetect = true, bossName = true, refire = 5000 }, -- Webdrop (Ruzozuzalpamaz)
    [51386] = { priority = 1, power = true, auradetect = true, duration = 30000, effectOnlyInterrupt = true, noSelf = true }, -- Web Wrap (Ruzozuzalpamaz)

    [54620] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_STUN, duration = 1000 }, -- Uppercut (Chamber Guardian)
    [51719] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Chamber_Guardian, cc = LUIE_CC_TYPE_FEAR, duration = 1000, postCast = 2100 }, -- Consuming Horror (Chamber Guardian)
    [51728] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, summon = true, auradetect = true, fakeName = UnitNames.Boss_Chamber_Guardian, refire = 5000 }, -- Consuming Horror (Chamber Guardian)

    [52167] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1650 }, -- Shock Form (Ilambris Amalgam)
    [53600] = { priority = 1, power = true, auradetect = true, bossName = true }, -- Summon Shock Skeleton (Ilambris Amalgam)
    [52278] = { priority = 1, avoid = true, auradetect = true }, -- Call Lightning (Ilambris Amalgam)
    [52491] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_STAGGER, duration = 1150 }, -- Thunder Fist (Ilambris Amalgam)
    [52166] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1650 }, -- Fire Form (Ilambris Amalgam)
    [53593] = { priority = 1, power = true, auradetect = true, bossName = true }, -- Summon Flame Skeleton (Ilambris Amalgam)
    [52285] = { priority = 1, avoid = true, auradetect = true }, -- Rain Fire (Ilambris Amalgam)
    [52334] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, power = true, eventdetect = true, bossName = true }, -- Final Storm (Ilambris Amalgam)

    [51090] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, bossName = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Rise and Fall (Mezeluth)

    [51539] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Necrotic Blast (Nerien'eth)
    [52080] = { priority = 1, power = true, auradetect = true, duration = 12000, effectOnlyInterrupt = true }, -- Necrotic Swarm (Nerien'eth)
    [51853] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, fakeName = UnitNames.Boss_Nerieneth, hiddenDuration = 1000 }, -- Soul Pulse (Nerien'eth)
    [51864] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Nerieneth, cc = LUIE_CC_TYPE_STAGGER, duration = 2000 }, -- Force Pulse (Nerien'eth)
    [51943] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, fakeName = UnitNames.Boss_Nerieneth, hiddenDuration = 1000 }, -- Soul Summon (Nerien'eth)
    [60632] = { priority = 1, summon = true, auradetect = true, duration = 8000, neverShowInterrupt = true }, -- Shadow Cloak (Nerien'eth)
    [52635] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, fakeName = UnitNames.Boss_Nerieneth, hiddenDuration = 1000 }, -- Teleport (Nerien'eth)
    [60631] = { priority = 1, power = true, auradetect = true, duration = 12000, neverShowInterrupt = true }, -- Shadow Cloak (Nerien'eth)
    [52119] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, fakeName = UnitNames.Boss_Nerieneth, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 3000, refire = 1000 }, -- Enervating Sheen (Nerien'eth)
    [52126] = { priority = 1, result = ACTION_RESULT_BEGIN, power = true, eventdetect = true, fakeName = UnitNames.Boss_Nerieneth, hiddenDuration = 1000 }, -- Teleport (Nerien'eth)
    [52143] = { priority = 1, power = true, auradetect = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 14500, noSelf = true }, -- Blood Lust (Nerien'eth)
    [51988] = { priority = 1, result = ACTION_RESULT_BEGIN, dodge = true, cc = LUIE_CC_TYPE_SNARE, duration = 1750 }, -- Lethal Stab (Nerien'eth)
    [51993] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1000 }, -- Heavy Slash (Nerien'eth)
    [51997] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Nerieneth, cc = LUIE_CC_TYPE_STAGGER, duration = 1000, postCast = 500 }, -- Ebony Whirlwind (Nerien'eth)

    -- Volenfell
    [25649] = { priority = 1, result = ACTION_RESULT_BEGIN, unmit = true, eventdetect = true, fakeName = UnitNames.Boss_Desert_Lion, cc = LUIE_CC_TYPE_FEAR, duration = 2000 }, -- Debilitating Roar (Desert Lion)

    [25029] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 6000 }, -- Twisted Steel (Quintus Verres)
    [25142] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 2000, postCast = 4000 }, -- Burning Groud (Quintus Verres)

    [25227] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Monstrous_Gargoyle, cc = LUIE_CC_TYPE_STUN, duration = 2100 }, -- Petrifying Bellow (Monstrous Gargoyle)
    [25222] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Monstrous_Gargoyle, duration = 6100, refire = 5000 }, -- Heaving Quake (Monstrous Gargoyle)

    [25672] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, bossName = true, duration = 4000 }, -- Flame Burst (Boilbite)
    [25655] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 700 }, -- Explosive Bolt (Unstable Construct)
    [25659] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, auradetect = true, duration = 1500, noSelf = true }, -- Countdown (Unstable Construct)

    [24777] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, eventdetect = true, fakeName = UnitNames.Boss_Tremorscale, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1500 }, -- Tail Swipe (Tremorscale)
    [29167] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, eventdetect = true, fakeName = UnitNames.Boss_Tremorscale, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 1800 }, -- Dummy (Tremorscale)

    [25211] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true }, -- Whirlwind Function (The Guardian's Strength)
    [25229] = { priority = 1, avoid = true, auradetect = true }, -- Barrage Function (Centurion Champion)
    [25262] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true, duration = 1950 }, -- Hammer Strike (The Guardian's Soul)
    [25263] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, cc = LUIE_CC_TYPE_UNBREAKABLE, duration = 2000 }, -- Decapitation Function (The Guardian's Soul)

    -- Frostvault
    [109574] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, refire = 3250 }, -- Fire Power (Coldsnap Harrier)
    [117352] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, eventdetect = true }, -- Whirlwind (Coldsnap Snowstalker)
    [117290] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, avoid = true }, -- Shockwave (Coldsnap Ogre)
    [117287] = { priority = 2, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true }, -- Crushing Blow (Coldsnap Ogre)
    [117326] = { priority = 3, result = ACTION_RESULT_EFFECT_GAINED, block = true, refire = 250 }, -- Ice Comet (Coldsnap Skysplitter)
    [109827] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, eventdetect = true }, -- Boulder Toss (Icestalker)
    [109811] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true }, -- Ground Slam (Icestalker)
    [109837] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true, eventdetect = true }, -- Frenzied Pummeling (Icestalker)
    [109806] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, eventdetect = true }, -- Frozen Aura (Icestalker)
    [83430] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true }, -- Skeletal Smash (Ice Wraith)
}

--- @class (partial) AlertTable
Data.AlertTable = alertTable
