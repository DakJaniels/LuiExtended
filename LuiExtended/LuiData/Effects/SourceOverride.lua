-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local Unitnames = Data.UnitNames
local Abilities = Data.Abilities

--------------------------------------------------------------------------------------------------------------------------------
-- Override source name = when one of these abilities hits change the source to match this name. Used for death recap to rename odd trap or source names for damage.
-- source = '' -- Change source name
-- pet = '' -- Change or remove pet name
-- removePlayer = true -- If for some reason a damage effect is sourced from the player, set it to not be flagged as isPlayer == true in order to stop AVA rank, etc from showing.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) EffectSourceOverride
local effectSourceOverride =
{

    -- PLAYER SETS
    [71678] = { pet = Abilities.Set_Morkuldin }, -- Morkuldin (Morkuldin Sword)
    [71679] = { pet = Abilities.Set_Morkuldin }, -- Morkuldin Cleave (Morkuldin Sword)

    -- PLAYER ABILITIES
    [33219] = { pet = Abilities.Skill_Shade },        -- Corrosive Strike (Dark Shade)
    [123945] = { pet = Abilities.Skill_Dark_Shade },  -- Corrosive Flurry (Dark Shade)
    [108936] = { pet = Abilities.Skill_Dark_Shade },  -- Corrosive Slash (Dark Shade)
    [51556] = { pet = Abilities.Skill_Shadow_Image }, -- Corrosive Arrow (Shadow Image)

    -- BATTLEGROUNDS

    -- TRAPS
    [62769] = { source = Abilities.Trap_Cold_Fire_Trap },              -- Coldharbour Flames (MQ Tutorial)
    [62770] = { source = Abilities.Trap_Cold_Fire_Trap },              -- Coldharbour Flames (MQ Tutorial)
    [17314] = { source = Abilities.Trap_Fire_Trap, addSource = true }, -- Fire Trap (Fire Trap)

    [21943] = { source = Abilities.Trap_Spike_Trap },                  -- Spike Trap (Corpse Masher) -- Stros M'Kai

    [72888] = { source = Abilities.Trap_Fire_Trap },                   -- Fire Attack 1 (Fire) -- Banished Cells II
    [72889] = { source = Abilities.Trap_Fire_Trap },                   -- Fire Attack 2 (Fire) -- Banished Cells II

    [33594] = { source = Abilities.Skill_Flames },                     -- Fire (Fire) -- Throne of the Wilderking

    [20483] = { source = Abilities.Trap_Falling_Rocks },               -- Falling Rocks

    [27940] = { source = Abilities.Trap_Charge_Wire },                 -- Laser Damage (Generic Flame Wave Shooter) -- Stros M'Kai
    [32245] = { source = Abilities.Trap_Steam_Vent },                  -- Searing Steam (Steam Trap) -- Stros M'Kai

    -- CYRODIIL
    [21707] = { source = Unitnames.NPC_Dremora_Channeler }, -- Imperial Law (Player) NPC_Dremora_Channeler

    -- ENVIRONMENTAL
    [44034] = { source = Abilities.Trap_Slaughterfish, addSource = true },  -- Slaughterfish Attack
    [113082] = { source = Abilities.Trap_Slaughterfish, addSource = true }, -- Slaughterfish Attack

    [19224] = { source = Abilities.Trap_Lava, addSource = true },           -- In Lava (Halls of Torment)
    [11338] = { source = Abilities.Trap_Lava, addSource = true },           -- In Lava (Earth Forge)
    [56277] = { source = Abilities.Trap_Lava, addSource = true },           -- In Lava (City of Ash II)
    [5140] = { source = Abilities.Trap_Lava, addSource = true },            -- Dragonstar Arena (City of Ash II)

    -- TRAPS (Go back over these)
    [92150] = { source = "Dwarven Furnace" },            -- Fire Trap {Vvardenfell}
    [89481] = { source = "Flame Jet Trap" },             -- Flame Jet {Vvardenfell}
    [88491] = { source = "Flame Jet Trap" },             -- Searing Flame {Vvardenfell}
    [88411] = { source = "Hammer Trap" },                -- Hammer {Vvardenfell}
    [88405] = { source = "Hammer Trap" },                -- Hammer {Vvardenfell}
    [89663] = { source = "Hammer Trap" },                -- Hammer {Vvardenfell}
    [89664] = { source = "Hammer Trap" },                -- Hammer {Vvardenfell}
    [88404] = { source = "Blade Trap" },                 -- Blade {Vvardenfell}
    [88454] = { source = "Blade Trap" },                 -- Blade {Vvardenfell}
    [88455] = { source = "Blade Trap" },                 -- Blade {Vvardenfell}
    [91659] = { source = Abilities.Trap_Falling_Rocks }, -- Falling Rocks {Vvardenfell}
    [92672] = { source = "Red Mountain" },               -- Pyroclast  {Vvardenfell}
    [84527] = { source = "Steam Vent" },                 -- Searing Steam {Vvardenfell}

    -----------------------------------------------
    -- QUESTS
    -----------------------------------------------

    -----------------------------------------------
    -- VVARDENFELL
    -----------------------------------------------

    -- Main Quest
    [88467] = { source = "Baar Dau" },            -- Skyfall {Divine Disaster}
    [87102] = { source = "Spinning Blade Trap" }, -- Spinning Blade {Divine Restoration}
    [91969] = { source = "Spinning Blade Trap" }, -- Spinning Blade {Divine Restoration}
    [86743] = { source = "Vapor Cloud" },         -- Accelerated Transposition {Like Blood from a Stone}

    -- Sidequests
    [89282] = { source = "Exploding Spider" }, -- Spider Explosion {A Web of Trouble}

    -----------------------------------------------
    -- ARENAS
    -----------------------------------------------

    -- Dragonstar Arena
    [55341] = { source = Abilities.Skill_Biting_Cold, addSource = true },        -- Biting Cold (Player)
    [60421] = { source = Abilities.Skill_Biting_Cold, addSource = true },        -- Biting Cold (Player)
    [83441] = { source = Unitnames.NPC_Anka_Ra_Shadowcaster, addSource = true }, -- Celestial Blast (Player)
    [55182] = { source = Unitnames.Boss_Hiath_the_Battlemaster },                -- Marked for Death (Hiath the Battlemaster)

    -- Maelstrom Arena
    [67871] = { source = Unitnames.Boss_Lamia_Queen },                      -- Shock (Water)
    [72525] = { source = Abilities.Skill_Frigid_Waters, addSource = true }, -- Frigid Waters (Player)
    [67808] = { source = Abilities.Skill_Frigid_Waters, addSource = true }, -- Frigid Waters (Player)

    -----------------------------------------------
    -- DUNGEONS
    -----------------------------------------------

    -- City of Ash I
    [34820] = { pet = "" }, -- Lava Pitch (Release Flame)
    [34951] = { pet = "" }, -- Blazing Embers (Release Flame)

    -- City of Ash II
    [54133] = { pet = "" },                             -- Blazing Embers (Marruz)
    [56034] = { pet = "" },                             -- Ground Tremor (Horvantud the Fire Maw)
    [55756] = { pet = "" },                             -- Burning (Valkyn Skoria)
    [56068] = { source = Abilities.Skill_Slag_Geyser }, -- Slag Geyser (Lava Pools)

    -- Selene's Web
    [31086] = { source = Abilities.Skill_Bear_Trap }, -- Trap (Trap)
    [30901] = { pet = "" },                           -- IntroKB (Spectral Senche-Tiger)

    -- Spindleclutch II
    [31611] = { source = Abilities.Skill_Cave_In },                                     -- Crushing Rocks (Cave In)
    [87373] = { source = Abilities.Skill_Cave_In },                                     -- Cave-In (Collapsed Ceiling)
    [86418] = { source = Unitnames.Boss_Praxin_Douare, pet = "", removePlayer = true }, -- Harrowing Ring (Blood Essence)
    [27655] = { source = Unitnames.Boss_Praxin_Douare, pet = "", removePlayer = true }, -- Harrowing Ring (Blood Essence)

    -- Crypt of Hearts I
    [22432] = { pet = "" }, -- Electric Prison (Lightning Rod)

    -- Crypt of Hearts II
    [51883] = { pet = "" }, -- Creeping Storm (Creeping Storm)
}

--- @class EffectSourceOverrideData
--- @field source (string | integer)?
--- @field pet (string | integer )?
--- @field addSource boolean?
--- @field removePlayer boolean?

--- @class (partial) EffectSourceOverride
--- @field [integer] EffectSourceOverrideData
Effects.EffectSourceOverride = effectSourceOverride
