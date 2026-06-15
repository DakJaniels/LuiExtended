-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects
local Tooltips = Data.Tooltips
local Abilities = Data.Abilities

local GetArtificialEffectInfo = GetArtificialEffectInfo

local function ESO_Plus_Member()
    local displayName, _, _, _, _, _ = GetArtificialEffectInfo(0)
    return displayName
end

--------------------------------------------------------------------------------------------------------------------------------
-- ZOS ArtificialEffectId (live 12.0.5): 0 ESO Plus, 1 Battle Spirit, 2 LFG, 3 Battle Spirit IC,
-- 4 BG Deserter, 5 Underdog Damage, 6 Underdog Healing, 7 Solo Queue XP, 8 Solo Queue AP.
--
-- Tooltip Functionality (same semantics as Effects/Override.lua):
-- - tooltip = Tooltips.Innate_* -- LUIE lang string (zo_strformat via LUIE.FormatArtificialEffectTooltip)
-- - tooltipValue1 .. tooltipValue7 -- Override <<1>> .. <<7>>
-- - tooltipValue1Id .. tooltipValue7Id -- Pull <<n>> from GetAbilityDuration(id)/1000
-- - tooltipSetAbilityId -- Fill unset <<n>> from GetAbilityDescription(set ability)
-- - tooltipValue2Mod -- Derive value 2 from duration + mod (abilities only; unused on artificial rows)
--------------------------------------------------------------------------------------------------------------------------------

--- @class (partial) ArtificialEffectOverride
--- @field [integer] ArtificialEffectOverrideEntry

--- @class ArtificialEffectOverrideEntry
--- @field override boolean
--- @field name string|nil
--- @field tooltip string|nil
--- @field tooltipValue1 number|string|nil
--- @field tooltipValue2 number|string|nil
--- @field tooltipValue3 number|string|nil
--- @field tooltipValue4 number|string|nil
--- @field tooltipValue5 number|string|nil
--- @field tooltipValue6 number|string|nil
--- @field tooltipValue7 number|string|nil
--- @field tooltipValue1Id integer|nil
--- @field tooltipValue2Id integer|nil
--- @field tooltipValue3Id integer|nil
--- @field tooltipValue4Id integer|nil
--- @field tooltipValue5Id integer|nil
--- @field tooltipValue6Id integer|nil
--- @field tooltipValue7Id integer|nil
--- @field tooltipSetAbilityId integer|nil
--- @field tooltipValue2Mod number|nil

local artificialEffectOverride =
{
    [0] =
    {
        override = true,
        name = ESO_Plus_Member(),
        tooltip = Tooltips.Innate_ESO_Plus,
    },

    [1] =
    {
        override = true,
        name = Abilities.Skill_Battle_Spirit,
        tooltip = Tooltips.Innate_Battle_Spirit,
    },

    [2] =
    {
        override = true,
        name = StringOnlyGSUB(GetArtificialEffectInfo(2), "For", "for"),
        tooltip = Tooltips.Innate_Looking_for_Group,
    },

    [3] =
    {
        override = true,
        name = Abilities.Skill_Battle_Spirit,
        tooltip = Tooltips.Innate_Battle_Spirit_Imperial_City,
    },

    [4] =
    {
        override = true,
        tooltip = Tooltips.Innate_Battleground_Deserter,
    },

    [5] =
    {
        override = true,
        tooltip = Tooltips.Innate_Underdog_Damage,
    },

    [6] =
    {
        override = true,
        tooltip = Tooltips.Innate_Underdog_Healing,
    },

    [7] =
    {
        override = true,
        tooltip = Tooltips.Innate_Solo_Queue_XP,
    },

    [8] =
    {
        override = true,
        tooltip = Tooltips.Innate_Solo_Queue_AP,
    },
}

Effects.ArtificialEffectOverride = artificialEffectOverride
