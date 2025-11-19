-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

--- @class (partial) EffectIsOakenSoul
local isOakenSoul =
{
    [61665] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61665)),   -- "Major Brutality"
    [61667] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61667)),   -- "Major Savagery"
    [61687] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61687)),   -- "Major Sorcery"
    [61689] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61689)),   -- "Major Prophecy"
    [61694] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61694)),   -- "Major Resolve"
    [61697] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61697)),   -- "Minor Fortitude"
    [61704] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61704)),   -- "Minor Endurance"
    [61706] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61706)),   -- "Minor Intellect"
    [61708] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61708)),   -- "Minor Heroism"
    [61710] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61710)),   -- "Minor Mending"
    [61721] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61721)),   -- "Minor Protection"
    [61737] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61737)),   -- "Empower"
    [61744] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61744)),   -- "Minor Berserk"
    [61746] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(61746)),   -- "Minor Force"
    [76617] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(76617)),   -- "Minor Slayer"
    [76618] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(76618)),   -- "Minor Aegis"
    [147417] = ZO_CachedStrFormat(GetString(SI_ABILITY_NAME), GetAbilityName(147417)), -- "Minor Courage"
}

--- @class (partial) EffectIsOakenSoul
Effects.IsOakenSoul = isOakenSoul
