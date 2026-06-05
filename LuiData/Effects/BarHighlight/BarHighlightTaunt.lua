-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- TAUNT BAR HIGHLIGHT (ActionBar)
-- Slotted bound ids that apply innate taunt; target debuff track id is shared (38254).
-- ActionBar keys remain/stack by slotted id and fans out on BarHighlightTauntDebuffId.
--------------------------------------------------------------------------------------------------------------------------------

--- Innate Taunt debuff on reticleover (combat log / Override.lua)
Effects.BarHighlightTauntDebuffId = 38254

--- @class (partial) BarHighlightTauntSlotted
local barHighlightTauntSlotted =
{
    -- Dragonknight
    [20492] = true,  -- Chains of Flame
    [20496] = true,  -- Chains of Dominance

    -- One Hand and Shield
    [28306] = true,  -- Puncture
    [38250] = true,  -- Pierce Armor
    [38256] = true,  -- Ransack

    -- Destruction Staff
    [38989] = true,  -- Frost Clench

    -- Fighters Guild
    [40336] = true,  -- Silver Leash

    -- Undaunted
    [39475] = true,  -- Inner Fire
    [42056] = true,  -- Inner Rage
    [42060] = true,  -- Inner Beast

    -- Arcanist
    [183165] = true, -- Runic Jolt
    [183430] = true, -- Runic Sunder
    [186531] = true, -- Runic Embrace

    -- Scribing (goading / taunt focus)
    [222966] = true, -- Goading Throw
    [217180] = true, -- Goading Smash
    [219972] = true, -- Goading Smash (variant id)
    [216674] = true, -- Goading Vault
}

Effects.BarHighlightTauntSlotted = barHighlightTauntSlotted
