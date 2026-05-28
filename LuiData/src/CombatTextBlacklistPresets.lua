-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

--- @class (partial) CombatTextBlacklistPresets
local blacklistPresets = {}

-- Sets
blacklistPresets.Sets =
{
    [135919] = true, -- Spell Parasite (Spell Parasite's)
}

-- Sorcerer
blacklistPresets.Sorcerer =
{
    [114903] = true, -- Dark Exchange
    [114908] = true, -- Dark Deal
    [114909] = true, -- Dark Conversion
}

-- Templar
blacklistPresets.Templar =
{
    [37009] = true,  -- Channeled Focus (Channeled Focus)
    [114842] = true, -- Restoring Focus (Restoring Focus)
}

-- Warden
blacklistPresets.Warden =
{
    [114854] = true, -- Betty Netch (Blue Betty)
    [114853] = true, -- Bull Netch (Bull Netch)
}

-- Necromancer
blacklistPresets.Necromancer =
{
    [123233] = true, -- Mortal Coil (Mortal Coil)
}

-- Dragonknight
blacklistPresets.Dragonknight =
{
    [32786] = true, -- Draw Essence (Draw Essence)
    [32789] = true, -- Draw Essence (Draw Essence)
}

-- Nightblade
blacklistPresets.Nightblade =
{
    [114957] = true, -- Siphoning Strikes (Siphoning Strikes)
    [114963] = true, -- Leeching Strikes (Leeching Strikes)
    [114964] = true, -- Leeching Strikes (Leeching Strikes)
    [114968] = true, -- Siphoning Attacks (Siphoning Attacks)
    [114969] = true, -- Siphoning Attacks (Siphoning Attacks)
}

-- Arcanist (Eye ult IMMUNE combat spam only)
blacklistPresets.Arcanist =
{
    [191889] = true, -- The Languid Eye (IMMUNE status tick bundle)
}

--- @class (partial) CombatTextBlacklistPresets
Data.CombatTextBlacklistPresets = blacklistPresets
