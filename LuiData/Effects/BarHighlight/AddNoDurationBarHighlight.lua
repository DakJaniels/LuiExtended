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
-- BarSlotUpdate skips toggled highlights when GetUpdatedAbilityDuration is 0 unless the **track** id (after BarHighlightOverride.newId) is listed here.
-- Does not suppress bar countdown labels — use BarHighlightHideDurationLabel for stack-only charge buffs (e.g. Necromancer skulls).
-- Do not list ids that still show a real timer from combatTrack (e.g. Power Lash 34117 keeps its 20s label via BarHighlightOverride.duration).
--------------------------------------------------------------------------------------------------------------------------------
--- @type table<integer, boolean>
local addNoDurationBarHighlight =
{
    -- Dragonknight
    [34117] = true, -- Power Lash stacks (Flame Lash); combat supplies duration; API may still read 0 for bar slot registration
    [32821] = true, -- Engulfing Dragonfire channel (player); combat GAIN DUR 5000 per tick

    -- Necromancer
    [114131] = true, -- Flame Skull charges (track; slotted 114108)
    [117625] = true, -- Venom Skull charges
    [117638] = true, -- Ricochet Skull charges
    [115240] = true, -- Bitter Harvest
    [124165] = true, -- Deaden Pain
    [124193] = true, -- Necrotic Potency
    [118814] = true, -- Enduring Undeath (ground/tooltip track)
    [118810] = true, -- Enduring Undeath (corpse-extended player aura)

    -- Two Handed
    [61737] = true, -- Empower (Wrecking Blow); API Dur 0 until combat refresh

    -- Nightblade — Grim Focus line (track buff API duration 0; stacks via counter + slotted id)
    [122585] = true, -- Grim Focus
    [122586] = true, -- Merciless Resolve
    [122587] = true, -- Relentless Focus
    [215672] = true, -- Leeching Strikes (stack effect; API duration 0)
}

Effects.AddNoDurationBarHighlight = addNoDurationBarHighlight

--------------------------------------------------------------------------------------------------------------------------------
-- Track ids: show stack highlight with no bar duration text (internal placeholder remain only).
-- Pair with BarHighlightStack + BarHighlightOverride.combatStackNoExpire on slotted skull rows.
--------------------------------------------------------------------------------------------------------------------------------
--- @type table<integer, boolean>
local barHighlightHideDurationLabel =
{
    [114131] = true, -- Flame Skull charges
    [117625] = true, -- Venom Skull charges
    [117638] = true, -- Ricochet Skull charges

    [122585] = true, -- Grim Focus (stack count on bar; no duration text)
    [122586] = true, -- Merciless Resolve
    [122587] = true, -- Relentless Focus

    [215672] = true, -- Leeching Strikes (stacks only)
    [36908] = true, -- Leeching Strikes (slotted; label keyed by slot id in ShowSlot)
}

Effects.BarHighlightHideDurationLabel = barHighlightHideDurationLabel
