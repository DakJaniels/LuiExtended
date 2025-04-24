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
-- Fake offline auras created by the player
-- ground == true - Set the target to ground instead of player.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) FakePlayerOfflineAura
local fakePlayerOfflineAura =
{
    -- Sets
    [75814] = { duration = "GET" }, -- Lunar Bastion (Lunar Bastion)

    -- Templar
    [22265] = { duration = "GET" }, -- Cleansing Ritual (Cleansing Ritual)
    [22259] = { duration = "GET" }, -- Ritual of Retribution (Ritual of Retribution)
    [22262] = { duration = "GET" }, -- Extended Ritual (Extended Ritual)

    -- Fighter's Guild
    [35750] = { duration = "GET", ground = true }, -- Trap Beast (Trap Beast)
    [40382] = { duration = "GET", ground = true }, -- Barbed Trap (Barbed Trap)
    [40372] = { duration = "GET", ground = true }, -- Lightweight Beast Trap (Lightweight Beast Trap)
}


--- @class (partial) FakePlayerOfflineAura
Effects.FakePlayerOfflineAura = fakePlayerOfflineAura
