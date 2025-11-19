-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data
local CrowdControl = Data.CrowdControl
-- List of effects sourced by the player that damage self that should be shown
--- @class (partial) LavaAlerts
local lavaAlerts =
{
    -- Player
    [115607] = true, -- Dismount Stun (Mount)
    [141004] = true, -- Dismount Stun (Passenger Mount)

    -- Consumables
    [68565] = true, -- Stun (Potion of Stun)

    -- World
    [95841] = true, -- Static Charge (Dark Anchor)

    -- Battlegrounds
    [87949] = true, -- Lava (Foyada Quarry)

    -- Traps & World
    [44034] = true,  -- Slaughterfish Attack (Stirk)
    [113082] = true, -- Slaughterfish Attack (Cyrodiil)
    [19224] = true,  -- In Lava (Halls of Torment)
    [11338] = true,  -- In Lava (The Earth Forge)
    [56277] = true,  -- Lava (City of Ash II)
    [5140] = true,   -- Lava (Dragonstar Arena)

    [17314] = true,  -- Fire Trap (Player)

    -- Quests
    [31502] = true, -- MGQ2 Asakala Sahdina Barrier (Simply Misplaced)
    [31503] = true, -- MGQ2 Asakala Rashomta Barrier (Simply Misplaced)
    [21876] = true, -- Q4260 West Barrier Teleport (Breaking the Barrier)
    [21878] = true, -- Q4260 East Barrier Teleport (Breaking the Barrier)
    [22395] = true, -- Q4261 ROD Barrier Teleport (Sever All Ties)
    [23606] = true, -- Q4326 Crystal Backfire (Preventative Measure)
    [37438] = true, -- Shocked (The Grips of Madness)
    [36766] = true, -- Q4842 Stun Headgrab Knockback (The Unquiet Dead)

    --------------
    -- Arenas ----
    --------------

    -- Dragonstar Arena
    [53341] = true, -- Biting Cold (Player)
    [60421] = true, -- Biting Cold (Player)
    [54405] = true, -- Celestial Blast (Player)

    -- Maelstrom Arena
    [72525] = true, -- Frigid Waters (Player)
    [67808] = true, -- Frigid Waters (Player)

    --------------
    -- Dungeons --
    --------------

    -- Elden Hollow II
    [30455] = true, -- Arachnophobia (The Opus of Torment)

    -- City of Ash I
    [70113] = true, -- Soul Scream (Scroll of Glorious Battle)

    -- City of Ash II
    [56563] = true, -- Book (Frigid Tome)

    -- Selene's Web
    [58521] = true, -- Web (Selene)

    -- Wayrest Sewers II
    [49052] = true, -- Pellingare Prison (Allene Pellingare)
}

--- @class (partial) LavaAlerts
CrowdControl.LavaAlerts = lavaAlerts
