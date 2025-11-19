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
-- If one of these id's is applied then we set the buffSlot for ON_EFFECT_CHANGED to be a single name identifier to prevent more than one aura from appearing. Only works with unlimited duration or equal duration effects.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) EffectMergeId
local effectMergeId =
{
    [47768] = "MERGED_EFFECT_CC_IMMUNITY_QUEST", -- RobS Immunities 6 Sec (Grahtwood - A Lasting Winter)
}

--- @class (partial) EffectMergeId
Effects.EffectMergeId = effectMergeId
