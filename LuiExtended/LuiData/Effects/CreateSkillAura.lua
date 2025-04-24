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
-- This will create an effect on the player or target when X skill is detected as active. SpellCastBuffs creates the buff by the name listed here, this way if 3 or 4 effects all need to display for 1 ability, it will only show the one aura.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) EffectCreateSkillAura
local EffectCreateSkillAura =
{
    -- Required:
    -- abilityId = #
    -- Optional:
    -- name = '' -- Add a custom name
    -- icon = '' -- Add a custom icon
    -- removeOnEnd = true -- Remove this aura when one of these effects ends.
    -- requiredStack = number -- Requires this number of stacks to apply

    [65235] = { removeOnEnd = true, abilityId = 33097 }, -- Enrage (Vosh Rakh Devoted)
    [50187] = { removeOnEnd = true, abilityId = 33097 }, -- Enrage (Mantikora)
    [56689] = { removeOnEnd = true, abilityId = 33097 }, -- Enraged (Mantikora)
    [72725] = { removeOnEnd = true, abilityId = 28301 }, -- Fool Me Once (Sentinel) (TG DLC)
}

--- @class (partial) EffectCreateSkillAura
Effects.EffectCreateSkillAura = EffectCreateSkillAura
