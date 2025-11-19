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

--------------------------------------------------------------------------------------------------------------------------------
-- List of abilities flagged to display a Proc highlight / sound notification when an ability with a matching name appears as a buff.
--------------------------------------------------------------------------------------------------------------------------------

-- Also track this id on bar highlight
-- SECONDARY ID = ORIGINAL BAR HIGHLIGHT ID
--- @class (partial) BarHighlightExtraId
local barHighlightExtraId =
{

    -- Dragonknight
    [20253] = 31898, -- Burning Talons
    [61785] = 32685, -- Fossilize

    -- Sorcerer
    [89491] = 24330,  -- Haunting Curse
    [132946] = 28482, -- Streak

    -- Warden
    [130140] = 130139, -- Cutting Dive --> Off-Balance
    [87194] = 88761,   -- Minor Protection --> Major Resolve (Ice Fortress)

    -- Necromancer
    [143915] = 121513, -- Grave Grasp
    [143917] = 121513, -- Grave Grasp
    [118325] = 118309, -- Ghostly Embrace
    [143945] = 118309, -- Ghostly Embrace
    [143948] = 118354, -- Empowering Grasp
    [143949] = 118354, -- Empowering Grasp

    -- Bow
    [38707] = 100302,  -- Bombard --> Piercing Spray
    [38703] = 100302,  -- Acid Spray --> Piercing Spray

    [28887] = 113627,  -- Virulent Shot --> Scatter Shot
    [38674] = 113627,  -- Virulent Shot --> Magnum Shot
    [131688] = 113627, -- Virulent Shot --> Draining Shot

    -- Mages Guild
    [40468] = 40465, -- Scalding Rune
    [40476] = 40470, -- Volcanic Rune

    -- Psijic Order
    [104085] = 104079, -- Time Freeze

    -- Werewolf
    [32633] = 137257, -- Roar --> Off Balance
    [39114] = 137312, -- > Deafening Roar --> Off Balance -- TODO: Could possibly track Major Breach/Minor Maim

    -- Vampire
    [138130] = 138098, -- Stupefy
}

--- @class (partial) BarHighlightExtraId
Effects.BarHighlightExtraId = barHighlightExtraId
