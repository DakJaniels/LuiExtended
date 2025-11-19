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
-- If this abilityId is up, then pull the duration from another active ability Id to set its duration (Unused - Might be useful in the future - Note this is supported in code)
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) EffectPullDuration
local effectPullDuration =
{
}

--- @class (partial) EffectPullDuration
Effects.EffectPullDuration = effectPullDuration
