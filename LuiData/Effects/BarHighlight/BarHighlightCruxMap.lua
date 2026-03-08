-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- CRUX STACK MAPPING
-- Maps Crux effect ID (184220) to abilities that should display Crux stacks
--------------------------------------------------------------------------------------------------------------------------------

--- @class (partial) BarHighlightCruxMap
local barHighlightCruxMap =
{
    -- Crux effect ID maps to list of ability IDs that should show Crux stacks
    [184220] =
    {
        185825, -- Tentacular Dread
        186477, -- Unbreakable Fate
        185805, -- Fatecarver (cost mag)
        193331, -- Fatecarver (cost stam)
        183122, -- Exhausting Fatecarver (cost mag)
        193397, -- Exhausting Fatecarver (cost stam)
        186366, -- Pragmatic Fatecarver (cost mag)
        193398, -- Pragmatic Fatecarver (cost stam)
        198309, -- Remedy Cascade (cost stam)
        183537, -- Remedy Cascade (cost mag)
        198330, -- Cascading Fortune (cost stam)
        186193, -- Cascading Fortune (cost mag)
        198537, -- Curative Surge (cost stam)
        186200, -- Curative Surge (cost mag)
    },
}

--- @class (partial) BarHighlightCruxMap
Effects.BarHighlightCruxMap = barHighlightCruxMap
