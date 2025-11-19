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
-- Fake debuffs applied onto a target by the player
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) FakePlayerDebuffs
local fakePlayerDebuffs =
{
    -- JUSTICE NPCS
    -- Disabled: Duration is too long and Guard always CC breaks. Maybe setup a callLater removal function?
    -- [63194] = { icon = 'esoui/art/icons/ability_dragonknight_013.dds', name = Abilities.Skill_Stonefist, duration = 6000 }, -- Flame Shard (Justice Guard 2H) -- If the player reflects

    ----------------------------------------------------------------
    -- PLAYER ABILITIES --------------------------------------------
    ----------------------------------------------------------------

    [86309] = { duration = 3000 }, -- Stun (Player blocks NPC charged attack)
    [86312] = { duration = 3000 }, -- Stun (Player blocks Ogrim Body Slam)

    -- Necromancer
    [118242] = { duration = 1000 }, -- Beckoning Armor (Beckoning Armor)

    -- Destruction Staff
    [38946] = { duration = 1800 }, -- Stun After Knockback Movement (Destructive Reach) -- Fire

    -- Vampire
    [40349] = { duration = 23000 }, -- Feed (Blood Ritual - Rank 1)

    -- Werewolf
    [40520] = { duration = 7000 }, -- Q3047 - Knockdown (Blood Moon - Rank 1)

    -- Item Sets
    [75706] = { duration = 1100, overrideDuration = true }, -- Bahraha's Curse -- Note: We add 100 ms to buffer here because it doesn't really matter and stops flashing
}

--- @class (partial) FakePlayerDebuffs
Effects.FakePlayerDebuffs = fakePlayerDebuffs
