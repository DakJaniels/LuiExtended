-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

-- CrowdControl.aoePlayerUltimate
-- CrowdControl.aoePlayerNormal
-- CrowdControl.aoePlayerSet
-- CrowdControl.aoeTrap
-- cc.aoeBoss
-- CrowdControl.aoeElite
-- CrowdControl.aoeNormal
-- Increment by 1 here if we want to change priority. Best way to do this is +1 for a new ability, and shared morphs or other damage sources from a shared attack don't increment.
-- Priority system doesn't support gaps so NEVER more than +1 here, also the FIRST ability in each tier needs to be +0 to prevent skips if a category is disabled in the options.
--- @class (partial) aoeTraps
local aoeTraps =
{

    [87949] = 0,  -- Lava (Foyada Quarry)
    [44034] = 0,  -- Slaughterfish Attack (Stirk)
    [113082] = 0, -- Slaughterfish Attack (Cyrodiil)
    [19224] = 0,  -- In Lava (Halls of Torment)
    [11338] = 0,  -- In Lava (The Earth Forge)
    [56277] = 0,  -- Lava (City of Ash II)
    [5140] = 0,   -- Lava (Dragonstar Arena)

    [62770] = 0,  -- Coldharbour Flames (Flame Trap) - Soul Shriven in Coldharbour
    [21943] = 0,  -- Spike Trap (Spike Trap)
    [53169] = 0,  -- Spike Trap (Spike Trap) - Dragonstar Arena
    [26531] = 0,  -- Bear Trap (Bear Trap)
    [31086] = 0,  -- Trap (Trap) - Selene's Web
    [20260] = 0,  -- Rune Burst (Sigil of Frost)
    [33594] = 0,  -- Fire (Fire) -- Greenshade - Throne of the Wilderking

    [17314] = 0,  -- Fire Trap (Player)
    [72888] = 0,  -- Fire Attack 1 (Fire) -- Banished Cells II
    [72889] = 0,  -- Fire Attack 2 (Fire) -- Banished Cells II

    [27940] = 0,  -- Laser Damage (Generic Flame Wave Shooter) -- Stros M'Kai
    [32245] = 0,  -- Searing Steam (Steam Trap) -- Stros M'Kai

    [26040] = 0,  -- Steam Blast (Steam Vent) -- Volenfell
    [26089] = 0,  -- Steam Blast (Steam Vent) -- Volenfell
    [26077] = 1,  -- Steam Blast (Steam Vent) -- Volenfell
    [26091] = 1,  -- Steam Blast (Steam Vent) -- Volenfell

    [110416] = 1, -- Putrid Cloud (Gas Blossom) -- Housing
    [110542] = 1, -- Stunted Current (Static Pitcher) -- Housing
    [111258] = 1, -- Surprise Attack (Lantern Mantis) -- Housing
    [111261] = 1, -- Surprise Attack (Lantern Mantis) -- Housing

    [92757] = 0,  -- Spinning Blade (Ald Carac)

    [117508] = 0, -- Shock Wall (Lightning Trap - Elinhir Private Arena)
    [117622] = 0, -- Shock Wall (Lightning Trap - Elinhir Private Arena)
    [117598] = 0, -- Shock Wall (Lightning Trap - Elinhir Private Arena)
    [117139] = 0, -- Spinning Blade (Blade Trap - Elinhir Private Arena)

    [92150] = 0,  -- Fire Trap (Vvardenfell -- Divine Delusions)
    [87102] = 0,  -- Spinning Blade (Vvardenfell -- Divine Restoration)
    [92284] = 0,  -- Planar Shear (Vvardenfell -- Divine Restoration)
    [86743] = 0,  -- Accelerated Transposition (Vvardenfell -- Like Blood from a Stone)
    [84527] = 0,  -- Searing Steam (Vvardenfell - Nchuleftingth)
    [90271] = 0,  -- Charge-Wire Shock (Vvardenfell - Nchuleftingth)
    [92138] = 0,  -- Laser Damage (Vvardenfell - Nchuleftingth)

    -- Quests
    [31970] = 1, -- Wrath (Tears of the Two Moons)
    [33404] = 0, -- Wrath (Tears of the Two Moons)
    [38499] = 1, -- Wrath (The Grips of Madness)
    [33577] = 1, -- Maormer Fire (Pelidil's End)

    -- Dragonstar Arena
    [53341] = 0, -- Biting Cold (Player)
    [60421] = 0, -- Biting Cold (Player)
    [83498] = 0, -- Poisonous Cloud (Poison Cloud)
    [83468] = 0, -- Restoring Nature (Nature's Blessing)

    -- Maelstrom Arena
    [69101] = 0, -- Shock (Generator)
    [66797] = 0, -- Spinning Blade (Blade Trap)
    [67871] = 0, -- Shock (Water)
    [72525] = 0, -- Frigid Waters (Player)
    [67808] = 0, -- Frigid Waters (Player)

    -- City of Ash II
    [56068] = 0, -- Slag Geyser (Lava Pool)

    -- Infinite Archive
    [224947] = 0, -- Frigid Waters (Infinite Archive)
}

--- @class (partial) aoeTraps
LuiData.Data.CrowdControl.aoeTraps = aoeTraps
