-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects
local Abilities = Data.Abilities

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- List of abilities flagged to display a Proc highlight / sound notification in Combat Info when the Ability Bar is updated with a matching id.
--------------------------------------------------------------------------------------------------------------------------------
--- @class IsAbilityProc
Effects.IsAbilityProc =
{
    [20824] = true, -- Power Lash (Flame Lash)
    [23105] = true, -- Power Lash (Flame Lash)
    [61907] = true, -- Assassin's Will (Grim Focus)
    [61932] = true, -- Assassin's Scourge (Relentless Focus)
    [61930] = true, -- Assassin's Will (Merciless Resolve)
}

-- Flagged to update on a bar slot update
--- @class BaseForAbilityProc
Effects.BaseForAbilityProc =
{
    [20816] = true, -- Flash Lash
    [61902] = true, -- Grim Focus
    [61927] = true, -- Relentless Focus
    [61919] = true, -- Merciless Resolve

}

--------------------------------------------------------------------------------------------------------------------------------
-- List of abilities flagged to display a Proc highlight / sound notification when an ability with a matching name appears as a buff.
--------------------------------------------------------------------------------------------------------------------------------
--- @class HasAbilityProc
Effects.HasAbilityProc =
{
    [Abilities.Skill_Crystal_Fragments] = 46327,
}
