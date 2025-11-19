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
-- When the player loads into the ZoneId listed below, add an unlimited duration long aura for the abilityId.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) ZoneBuffs
local zoneBuffs =
{
    -- Daggerfall Covenant Quests
    [811] = 28358, -- Zone: Ancient Carzog's Demise (Base Zone: Betnikh) (Quest: Unearthing the Past) - Q4468 Orc Raider Disguise
}

--- @class (partial) ZoneBuffs
Effects.ZoneBuffs = zoneBuffs
