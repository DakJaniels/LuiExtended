-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Shared Major/Minor display ids (e.g. 61665 Major Brutality) refresh many unrelated skills.
-- Map display id -> slotted ability id -> max duration (ms) this slotted row should accept from the player buff.
-- Longer refreshes (e.g. Igneous 76518 / 61665 @ 60s) are ignored for shorter-cap slots (Hidden Blade @ 20s).
-- Values from LuiDevTool combat log (blade.txt): 68807/126647 combat + 61665 @ 20000; Flying 61665 @ 40000.
--------------------------------------------------------------------------------------------------------------------------------
local barHighlightSlottedMajorCap =
{
    [61665] =
    {
        [21157] = 20000, -- Hidden Blade (combat carrier 68807)
        [38914] = 20000, -- Shrouded Daggers (combat carrier 126647)
        [38910] = 40000, -- Flying Blade (player 61665 only; no 68807/126647 in log)
    },
}

Effects.BarHighlightSlottedMajorCap = barHighlightSlottedMajorCap
