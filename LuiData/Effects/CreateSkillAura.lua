-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

--- @class EffectCreateSkillAuraData
--- @field abilityId integer
--- @field name? string -- Add a custom name
--- @field icon? string -- Add a custom icon
--- @field removeOnEnd? boolean -- Remove this aura when one of these effects ends.
--- @field requiredStack? integer -- Requires this number of stacks to apply
--------------------------------------------------------------------------------------------------------------------------------
-- This will create an effect on the player or target when X skill is detected as active. SpellCastBuffs creates the buff by the name listed here, this way if 3 or 4 effects all need to display for 1 ability, it will only show the one aura.
--------------------------------------------------------------------------------------------------------------------------------

--- @class (partial) EffectCreateSkillAura
--- @field [integer] EffectCreateSkillAuraData
Effects.EffectCreateSkillAura =
{
    [65235] = { abilityId = 33097, removeOnEnd = true }, -- Enrage (Vosh Rakh Devoted)
    [50187] = { abilityId = 33097, removeOnEnd = true }, -- Enrage (Mantikora)
    [56689] = { abilityId = 33097, removeOnEnd = true }, -- Enraged (Mantikora)
    [72725] = { abilityId = 28301, removeOnEnd = true }, -- Fool Me Once (Sentinel) (TG DLC)
}
