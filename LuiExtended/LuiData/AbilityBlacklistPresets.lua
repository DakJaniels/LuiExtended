-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

--- @class (partial) BlacklistPresets
--- @field public MinorBuffs table<number, boolean>
--- @field public MajorBuffs table<number, boolean>
--- @field public MinorDebuffs table<number, boolean>
--- @field public MajorDebuffs table<number, boolean>
local blacklistPresets =
{
    -- Minor Buffs
    MinorBuffs =
    {
        [61693] = true,  -- Minor Resolve
        [61697] = true,  -- Minor Fortitude
        [61704] = true,  -- Minor Endurance
        [61706] = true,  -- Minor Intellect
        [61685] = true,  -- Minor Sorcery
        [61691] = true,  -- Minor Prophecy
        [61662] = true,  -- Minor Brutality
        [61666] = true,  -- Minor Savagery
        [61744] = true,  -- Minor Berserk
        [61746] = true,  -- Minor Force
        [61549] = true,  -- Minor Vitality
        [61710] = true,  -- Minor Mending
        [61721] = true,  -- Minor Protection
        [61715] = true,  -- Minor Evasion
        [61735] = true,  -- Minor Expedition
        [61708] = true,  -- Minor Heroism
        [88490] = true,  -- Minor Toughness
        [147417] = true, -- Minor Courage
    },

    -- Major Buffs
    MajorBuffs =
    {
        [61694] = true,  -- Major Resolve
        [61698] = true,  -- Major Fortitude
        [61705] = true,  -- Major Endurance
        [61707] = true,  -- Major Intellect
        [61687] = true,  -- Major Sorcery
        [61689] = true,  -- Major Prophecy
        [61665] = true,  -- Major Brutality
        [61667] = true,  -- Major Savagery
        [61745] = true,  -- Major Berserk
        [61747] = true,  -- Major Force
        [61713] = true,  -- Major Vitality
        [61711] = true,  -- Major Mending
        [61722] = true,  -- Major Protection
        [61716] = true,  -- Major Evasion
        [61736] = true,  -- Major Expedition
        [63569] = true,  -- Major Gallop
        [61709] = true,  -- Major Heroism
        [109966] = true, -- Major Courage
    },

    -- Minor Debuffs
    MinorDebuffs =
    {
        [61742] = true,  -- Minor Breach
        [79717] = true,  -- Minor Vulnerability
        [61723] = true,  -- Minor Maim
        [61726] = true,  -- Minor Defile
        [88401] = true,  -- Minor Magickasteal
        [86304] = true,  -- Minor Lifesteal
        [79907] = true,  -- Minor Enervation
        [79895] = true,  -- Minor Uncertainty
        [79867] = true,  -- Minor Cowardice
        [61733] = true,  -- Minor Mangle
        [140699] = true, -- Minor Timidity
        [145975] = true, -- Minor Brittle
    },

    -- Major Debuffs
    MajorDebuffs =
    {
        [61743] = true,  -- Major Breach
        [106754] = true, -- Major Vulnerability
        [61725] = true,  -- Major Maim
        [61727] = true,  -- Major Defile
        [147643] = true, -- Major Cowardice
        [145977] = true, -- Major Brittle
    },
}

--- @class (partial) BlacklistPresets
Data.AbilityBlacklistPresets = blacklistPresets
