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
--- @class (partial) aoePlayerUltimate
local aoePlayerUltimate =
{

    -- Dragonknight
    [28995] = 0, -- Dragonknight Standard
    [32960] = 0, -- Shifting Standard
    [32964] = 0, -- Shifting Standard
    [32948] = 0, -- Standard of Might

    -- Warden
    [86247] = 1, -- Sleet Storm (Sleet Storm)
    [88860] = 0, -- Northern Storm (Northern Storm)
    [88863] = 0, -- Permafrost (Permafrost)

    -- Templar
    [21753] = 1, -- Nova
    [21756] = 0, -- Solar Prison
    [21759] = 0, -- Solar Disturbance

    -- Nightblade
    [36490] = 1, -- Veil of Blades (Veil of Blades)

    -- Necromancer
    [122178] = 1, -- Frozen Colossus (Frozen Colossus)
    [122399] = 0, -- Pestilent Colossus (Pestilent Colossus)
    [122400] = 0, -- Pestilent Colossus (Pestilent Colossus)
    [122401] = 0, -- Pestilent Colossus (Pestilent Colossus)
    [122392] = 0, -- Glacial Colossus (Glacial Colossus)
    [118289] = 1, -- Ravenous Goliath (Ravenous Goliath)

    -- Sorcerer
    [80435] = 1, -- Suppression Field (Suppression Field)

    -- Arcanist
    [189793] = 1, -- The Unblinking Eye (The Unblinking Eye)
    [189839] = 0, -- The Tide King's Gaze (The Tide King's Gaze)
    [189837] = 0, -- The Tide King's Gaze (The Tide King's Gaze)?
    [191367] = 0, -- The Tide King's Gaze (The Tide King's Gaze)?
    [189869] = 1, -- The Languid Eye (The Languid Eye)
    [191889] = 1, -- The Languid Eye (The Languid Eye, Duration?)

    -- Destruction Staff
    [85127] = 1, -- Fiery Rage
    [85131] = 0, -- Thunderous Rage
    [85129] = 0, -- Icy Rage
    [83683] = 1, -- Eye of Flame
    [83687] = 0, -- Eye of Lightning
    [83685] = 0, -- Eye of Frost
    [83626] = 1, -- Fire Storm
    [83631] = 0, -- Thunder Storm
    [83629] = 0, -- Ice Storm

    -- Mages Guild
    [63429] = 1, -- Meteor
    [63454] = 0, -- Ice Comet
    [63471] = 0, -- Shooting Star

    -- Vampire
    [38935] = 1, -- Swarming Scion

    -- Volendrung
    [116669] = 1, -- Ebony Cyclone (Ruinous Cyclone)
}

--- @class (partial) aoePlayerUltimate
CrowdControl.aoePlayerUltimate = aoePlayerUltimate
