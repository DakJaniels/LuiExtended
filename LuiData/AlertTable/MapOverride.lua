-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
local UnitNames = Data.UnitNames
local Zonenames = Data.ZoneNames

-- Map Name override - Sometimes we need to use GetMapName() instead of Location Name or ZoneId
--- @class (partial) AlertMapOverride
local alertMapOverride =
{
    -- Slam (Great Bear)
    [70366] =
    {
        -- QUESTS
        [Zonenames.Zone_Deepwood_Barrow] = UnitNames.NPC_Great_Bear, -- Deepwood Vale (Greymoor Tutorial)
    },
}

--- @class (partial) AlertMapOverride
Data.AlertMapOverride = alertMapOverride
