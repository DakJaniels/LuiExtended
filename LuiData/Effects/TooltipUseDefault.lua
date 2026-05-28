-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Table of NAME or ID's to add a third line to the tooltip. Any ability listed here should use its source ability as the tooltip, and this added 3 line will describe the effect. Used for major/minor effects & potions/poison primarily.
--------------------------------------------------------------------------------------------------------------------------------
Effects.TooltipNameOverride =
{
    -- TODO: Maybe remove
}

--------------------------------------------------------------------------------------------------------------------------------
-- LUIE for the most part overwrites default ability tooltips due to the fact they are only exposed for buffs/debuffs that are on the player. In some cases there is no description with scaling or we need to still use the default where possible.
-- The most noteworthy case of this is Mundus Boons, where there is a tooltip but no description. We want to display a generic tooltip describing the effect if mousing over another player - but display the default value with accurate number for self.
--------------------------------------------------------------------------------------------------------------------------------
--- @class TooltipUseDefault
Effects.TooltipUseDefault =
{
    [13940] = true, -- Boon: The Warrior
    [13943] = true, -- Boon: The Mage
    [13974] = true, -- Boon: The Serpent
    [13975] = true, -- Boon: The Thief
    [13976] = true, -- Boon: The Lady
    [13977] = true, -- Boon: The Steed
    [13978] = true, -- Boon: The Lord
    [13979] = true, -- Boon: The Apprentice
    [13980] = true, -- Boon: The Ritual
    [13981] = true, -- Boon: The Lover
    [13982] = true, -- Boon: The Atronach
    [13984] = true, -- Boon: The Shadow
    [13985] = true, -- Boon: The Tower

    -- Herald passives (timed stack buffs; use TooltipHandlers when GetAbilityEffectDescription stays at 0%%)
    [184860] = true, -- Harnessed Quintessence (timed stack)
}
