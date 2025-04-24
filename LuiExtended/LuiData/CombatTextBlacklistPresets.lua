-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

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

--- @class (partial) CombatTextBlacklistPresets
Data.CombatTextBlacklistPresets = blacklistPresets
