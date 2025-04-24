-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local Unitnames = Data.UnitNames


--- @class (partial) AddNameOnBossEngaged
local addNameOnBossEngaged =
{
    [Unitnames.Boss_Razor_Master_Erthas] = { [Unitnames.NPC_Flame_Atronach] = 33097 }, -- Scary Immunities --> Razor Master Erthas --> Flame Atronach (City of Ash I)
    [Unitnames.Boss_Ilambris_Amalgam] = { [Unitnames.NPC_Skeleton] = 33097 },          -- Scary Immunities --> Ilambris Amalgam --> Skeleton (Crypt of Hearts II)
}

--- @class (partial) AddNameOnBossEngaged
Effects.AddNameOnBossEngaged = addNameOnBossEngaged
