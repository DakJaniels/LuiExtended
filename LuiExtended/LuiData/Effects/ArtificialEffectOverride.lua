-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local Tooltips = Data.Tooltips
local Abilities = Data.Abilities

local zo_strgsub = zo_strgsub
local GetArtificialEffectInfo = GetArtificialEffectInfo

local ESO_Plus_Member = function ()
    local displayName, _, _, _, _, _ = GetArtificialEffectInfo(0)
    return displayName
end
--------------------------------------------------------------------------------------------------------------------------------
-- Using a separate chart for ZOS Artificial Effects just in case this is significantly expanded at any point -- Overrides Artificial Effect id name or icon.
--------------------------------------------------------------------------------------------------------------------------------

--- @class (partial) ArtificialEffectOverride
local artificialEffectOverride =
{
    -- ESO Plus Subscription Status
    -- Index 0: Displays active ESO Plus membership status in the Active Effects window
    -- Uses ESO_Plus_Member() function to dynamically fetch the display name
    [0] =
    {
        override = true,
        name = ESO_Plus_Member(),          -- Gets current ESO Plus membership display name
        tooltip = Tooltips.Innate_ESO_Plus -- Custom tooltip for ESO Plus status
    },

    -- Battle Spirit (PvP Combat Modifier)
    -- Index 1: Applied in Cyrodiil, Duels, and Battlegrounds
    -- Modifies player stats for PvP balance
    [1] =
    {
        override = true,
        tooltip = Tooltips.Innate_Battle_Spirit -- Custom tooltip explaining Battle Spirit effects
    },

    -- Looking For Group Status
    -- Index 2: Shows Dungeon Finder queue status
    -- Uses zo_strgsub to modify the default text, replacing "For" with "for"
    [2] =
    {
        override = true,
        name = zo_strgsub(GetArtificialEffectInfo(1), "For", "for"), -- Adjusts capitalization in LFG text
        tooltip = Tooltips.Innate_Looking_for_Group                  -- Custom tooltip for LFG status
    },

    -- Imperial City Battle Spirit
    -- Index 3: Specific version of Battle Spirit for Imperial City PvP zone
    -- Uses custom name from Abilities table
    [3] =
    {
        override = true,
        name = Abilities.Skill_Battle_Spirit,                 -- Custom name for Imperial City Battle Spirit
        tooltip = Tooltips.Innate_Battle_Spirit_Imperial_City -- Custom tooltip for IC Battle Spirit
    },

    -- Battleground Deserter Penalty
    -- Index 4: Applied when leaving Battleground matches early
    -- Only overrides the tooltip
    [4] =
    {
        override = true,
        tooltip = Tooltips.Innate_Battleground_Deserter -- Custom tooltip for deserter penalty
    },
}


--- @class (partial) ArtificialEffectOverride
--- @field [integer] {override:boolean,name:string,tooltip:string}
Effects.ArtificialEffectOverride = artificialEffectOverride
