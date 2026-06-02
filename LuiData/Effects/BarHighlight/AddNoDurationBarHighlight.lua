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
    [32821] = true, -- Engulfing Dragonfire channel (player); combat GAIN DUR 5000 per tick

    -- Necromancer
    [114131] = true, -- Flame Skull charges
    [117625] = true, -- Venom Skull charges
    [117638] = true, -- Ricochet Skull charges
    [115240] = true, -- Bitter Harvest
    [124165] = true, -- Deaden Pain
    [124193] = true, -- Necrotic Potency
    [118814] = true, -- Enduring Undeath (ground/tooltip track)
    [118810] = true, -- Enduring Undeath (corpse-extended player aura)

    -- Two Handed
    [61737] = true, -- Empower (Wrecking Blow); API Dur 0 until combat refresh
}

Effects.AddNoDurationBarHighlight = addNoDurationBarHighlight
