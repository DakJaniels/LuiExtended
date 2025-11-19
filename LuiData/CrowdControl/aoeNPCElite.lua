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
--- @class (partial) aoeNPCElite
local aoeNPCElite =
{

    -- Overland / Standard NPC's
    [44228] = 0, -- Dragonknight Standard (Dragonknight - Elite)
    [81197] = 1, -- Agonizing Fury (Thundermaul - Boss)
    [21952] = 1, -- Repulsion Shock (Wamasu)
    [55867] = 0, -- Repulsion Shock (Wamasu - Boss)
    [72794] = 1, -- Toxic Pool (Haj Mota)
    [53233] = 1, -- Miasma Pool (Flesh Colossus)
    [52866] = 1, -- Volley (Cyrodiil Archer)
    [54258] = 1, -- Upgraded Volley (Cyrodiil Archer)
    [10271] = 1, -- Quake (Gargoyle)
    [9011] = 1,  -- Tremor (Troll)
    [48297] = 1, -- Consuming Omen (Troll - Ranged)
    [19061] = 1, -- Rain of Wisps (Wispmother)
    [75928] = 1, -- Elemental Pool (Minotaur)
    [75953] = 1, -- Brimstone Hailfire (Minotaur Shaman)
    [75976] = 1, -- Pillar of Nirn (Minotaur Shaman)
    [75980] = 1, -- Pillar Eruption (Minotaur Shaman)
    [11282] = 1, -- Steam Breath (Dwemer Centurion)

    -- World
    [95841] = 1, -- Static Charge (Dark Anchor)

    -- Quests
    [50765] = 1, -- CON_AOE_Template1 (Pelidil's End)

    -- Summerset
    [105889] = 1, -- Pustulant Eruption (Yaghra Nightmare)

    -- Dragonstar Arena
    [53314] = 1, -- Flame Volley (Sovngarde Ranger)
    [53280] = 1, -- Unstable Wall of Frost (Sovngarde Icemage)
    [53614] = 1, -- Thundering Presence (Nak'tah)
    [53625] = 1, -- Lightning Flood (Nak'tah)
    [56824] = 1, -- Puncturing Sweep (House Dres Templar)
    [54161] = 1, -- Berserker Frenzy (House Dres Slaver)
    [54080] = 1, -- Cinder Storm (Earthen Heart Knight)
    [52892] = 1, -- Flames of Oblivion (Anal'a Tu'wha)
    [55981] = 1, -- Ice Charge (Dwarven Ice Centurion)

    -- Maelstrom Arena
    [72159] = 1, -- Static Field (Dwarven Spider)
    [72203] = 1, -- Overcharge (Scavenger Thunder-Smith)
}

--- @class (partial) aoeNPCElite
CrowdControl.aoeNPCElite = aoeNPCElite
