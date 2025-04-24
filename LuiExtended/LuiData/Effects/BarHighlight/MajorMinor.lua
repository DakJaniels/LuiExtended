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
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

-- Table of all Major / Minor Effects (Used by CombatInfo Bar Highlight to override the 0 duration on these abilities)
--- @class (partial) MajorMinor
local majorMinor =
{
    -- Major / Minor Buffs
    [61693] = true,  -- Minor Resolve
    [61694] = true,  -- Major Resolve
    [61697] = true,  -- Minor Fortitude
    [61698] = true,  -- Major Fortitude
    [61704] = true,  -- Minor Endurance
    [61705] = true,  -- Major Endurance
    [61706] = true,  -- Minor Intellect
    [61707] = true,  -- Major Intellect
    [61685] = true,  -- Minor Sorcery
    [61687] = true,  -- Major Sorcery
    [61691] = true,  -- Minor Prophecy
    [61689] = true,  -- Major Prophecy
    [61662] = true,  -- Minor Brutality
    [61665] = true,  -- Major Brutality
    [61666] = true,  -- Minor Savagery
    [61667] = true,  -- Major Savagery
    [61744] = true,  -- Minor Berserk
    [61745] = true,  -- Major Berserk
    [61746] = true,  -- Minor Force
    [61747] = true,  -- Major Force
    [61549] = true,  -- Minor Vitality
    [61713] = true,  -- Major Vitality
    [61710] = true,  -- Minor Mending
    [61711] = true,  -- Major Mending
    [61721] = true,  -- Minor Protection
    [61722] = true,  -- Major Protection
    [61715] = true,  -- Minor Evasion
    [61716] = true,  -- Major Evasion
    [61735] = true,  -- Minor Expedition
    [61736] = true,  -- Major Expedition
    [63569] = true,  -- Major Gallop
    [61708] = true,  -- Minor Heroism
    [61709] = true,  -- Major Heroism
    [88490] = true,  -- Minor Toughness
    [147417] = true, -- Minor Courage
    [109966] = true, -- Major Courage

    -- Major / Minor Debuffs
    [61742] = true,  -- Minor Breach
    [61743] = true,  -- Major Breach
    [79717] = true,  -- Minor Vulnerability
    [106754] = true, -- Major Vulnerability
    [61723] = true,  -- Minor Maim
    [61725] = true,  -- Major Maim
    [61726] = true,  -- Minor Defile
    [61727] = true,  -- Major Defile
    [88401] = true,  -- Minor Magickasteal
    [86304] = true,  -- Minor Lifesteal
    [79907] = true,  -- Minor Enervation
    [79895] = true,  -- Minor Uncertainty
    [79867] = true,  -- Minor Cowardice
    [147643] = true, -- Major Cowardice
    [61733] = true,  -- Minor Mangle
    [140699] = true, -- Minor Timidity
    [145975] = true, -- Minor Brittle
    [145977] = true, -- Major Brittle

    -- Slayer / Aegis
    [76618] = true, -- Minor Aegis
    [93123] = true, -- Major Aegis
    [76617] = true, -- Minor Slayer
    [93109] = true, -- Major Slayer

    -- Empower
    [61737] = true, -- Empower
}

--- @class (partial) MajorMinor
Effects.MajorMinor = majorMinor
