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
-- Fake Buffs applied onto the player by NPCs or Events (Friendly)
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) FakeExternalBuffs
local fakeExternalBuffs =
{

    -- Quests
    [21403] = { duration = 60000, ignoreFade = true }, -- Spiritual Cloak (The Mallari-Mora)

    -- Elsweyr Quests
    [124310] = { duration = 10000 }, -- Master's Shield (Grand Adept Ma'hja-dro)

    ----------------
    -- Dungeons ----
    ----------------

    -- Elden Root II
    [32655] = { duration = 0 }, -- Fortification (Fortified Guardian)
    [32614] = { duration = 0 }, -- Empowered (Mystic Guardian)
}

--- @class (partial) FakeExternalBuffs
Effects.FakeExternalBuffs = fakeExternalBuffs
