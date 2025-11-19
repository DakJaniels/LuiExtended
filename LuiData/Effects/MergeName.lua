-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local Abilities = Data.Abilities

--------------------------------------------------------------------------------------------------------------------------------
-- If one of these ability Names is applied then we set the buffSlot for ON_EFFECT_CHANGED to be a single name identifier to prevent more than one aura from appearing. Only works with unlimited duration or equal duration effects.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) EffectMergeName
local effectMergeName =
{
    [Abilities.Skill_Overcharge] = "MERGED_EFFECT_OVERCHARGE",
    [Abilities.Skill_Boulder_Toss] = "MERGED_EFFECT_BOULDER_TOSS",
    [Abilities.Skill_Boss_CC_Immunity] = "MERGED_EFFECT_BOSS_IMMUNITIES", -- Scary Immunities
}

--- @class (partial) EffectMergeName
Effects.EffectMergeName = effectMergeName
