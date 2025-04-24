-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
local CrowdControl = Data.CrowdControl
-- CrowdControl.aoePlayerUltimate
-- CrowdControl.aoePlayerNormal
-- CrowdControl.aoePlayerSet
-- CrowdControl.aoeTrap
-- cc.aoeBoss
-- CrowdControl.aoeElite
-- CrowdControl.aoeNormal
-- Increment by 1 here if we want to change priority. Best way to do this is +1 for a new ability, and shared morphs or other damage sources from a shared attack don't increment.
-- Priority system doesn't support gaps so NEVER more than +1 here, also the FIRST ability in each tier needs to be +0 to prevent skips if a category is disabled in the options.
--- @class (partial) aoePlayerSet
local aoePlayerSet =
{

    -- Sets
    [102136] = 0, -- Zaan
    [59568] = 1,  -- Malubeth
    [80522] = 1,  -- Stormfist
    [59498] = 1,  -- Mephala's Web (Spawm of Mephala)
    [60972] = 1,  -- Fiery Breath (Maw of the Infernal)
    [80526] = 1,  -- Ilambris
    [84502] = 1,  -- Grothdarr
    [80561] = 1,  -- Iceheart
    [97883] = 1,  -- Domihaus
    [97899] = 0,  -- Domihaus
    [80565] = 1,  -- Kra'gh
    [75692] = 1,  -- Bahraha's Curse (of Bahraha's Curse)
    [57209] = 1,  -- Storm Knight's Plate (of the Storm Knight)
    [67136] = 1,  -- Overwhelming Surge (Overwhelming)
    [59696] = 1,  -- Embershield (Embershield)
    [67204] = 1,  -- Leeching Plate (of Leeching)
    [102094] = 1, -- Thurvokun (Thurvokun)
    [116920] = 1, -- Auroran's Thunder (Auroran's Thunder)
    [133494] = 1, -- Aegis Caller (Aegis Caller's)
    [137526] = 1, -- Hunter's Venom (Venomous)
    [143077] = 1, -- Stone Husk (Stone Husk)
    [167679] = 1, -- Nunatak (Nunatak)
    [167683] = 0, -- Nunatak Immobilize (Nunatak)
    [159277] = 0, -- Rush of Agony (Rush of Agony)
    [159275] = 1, -- Rush of Agony (Rush of Agony)
    [159391] = 0, -- Dark Convergence (Dark Convergence)
    [160317] = 0, -- Dark Convergence (Dark Convergence)
    [159386] = 1, -- Dark Convergence (Dark Convergence)
    [159387] = 1, -- Dark Convergence (Dark Convergence)
    [188886] = 0, -- Time Disruption (Snare, Judement of Akatosh)
    [189859] = 1, -- Time Disruption (AoE, Judement of Akatosh)

    -- Siege
    [104693] = 1, -- Meatbag Catapult
    [104695] = 1, -- Scattershot Catapult
    [138556] = 1, -- Shock Lancer
    [138434] = 1, -- Fire Lancer
    [138552] = 1, -- Frost Lancer
}

--- @class (partial) aoePlayerSet
CrowdControl.aoePlayerSet = aoePlayerSet
