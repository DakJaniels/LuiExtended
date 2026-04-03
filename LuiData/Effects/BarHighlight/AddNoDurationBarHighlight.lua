-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- We don't add bar highlights for 0 duration abilities, a few abilities with dynamic durations show as 0 duration so we need this override table.
--------------------------------------------------------------------------------------------------------------------------------
--- @type table<integer, boolean>
local addNoDurationBarHighlight =
{
    -- Dragonknight
    [34117] = true, -- Power Lash stacks (Flame Lash); combat supplies duration; API may still read 0 for bar slot registration

    -- Nightblade (Grim Focus morph buff ids on bar after override)
    [122585] = true, -- Grim Focus
    [122587] = true, -- Relentless Focus
    [122586] = true, -- Merciless Resolve

    -- Necromancer
    [115240] = true, -- Bitter Harvest
    [124165] = true, -- Deaden Pain
    [124193] = true, -- Necrotic Potency
    [118814] = true, -- Enduring Undeath
}

Effects.AddNoDurationBarHighlight = addNoDurationBarHighlight
