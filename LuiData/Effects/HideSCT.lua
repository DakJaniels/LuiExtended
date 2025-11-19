-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Hide this ID from appearing in any way on Combat Cloud Text - Useful for spammy ids.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) EffectHideSCT
local effectHideSCT =
{
    -- Player - Basic
    [45982] = true, -- Bash Stun

    -- Champion Points
    [151861] = true, -- Shadowstrike
    [151860] = true, -- Shadowstrike

    -- Player - Weapons
    [18429] = true, -- Heavy Attack (Unarmed)
    [16041] = true, -- Heavy Attack (Two Handed)
    [15279] = true, -- Heavy Attack (One Handed)
    [16420] = true, -- Heavy Attack (Dual Wield)
    [16691] = true, -- Heavy Attack (Bow)
    [16261] = true, -- Heavy Attack (Ice)
    [15383] = true, -- Heavy Attack (Inferno)

    -- Player - Werewolf
    [32477] = true,  -- Heavy Attack (Werewolf)
    [111832] = true, -- Werewolf Transformation
    [111843] = true, -- Pack Leader
    [111844] = true, -- Werewolf Berserker

    -- Sets
    [32755] = true, -- Nikulas' Heavy Armor (of Nikulas)
    [59499] = true, -- Mephala's Web (Spawn of Mephala)
    [75706] = true, -- Bahraha's Curse (of Bahraha's Curse)
    [34870] = true, -- Wilderqueen's Arch (of the Wilderqueen)
    [84357] = true, -- Hand of Mephala Webbing (of Mephala's Hand)

    ----------------------------
    -- Arcanist
    ----------------------------
    [184291] = true, -- Exhausting Fatecarver(IMMUNE)

    ----------------------------
    -- Nightblade
    ----------------------------

    [25375] = true, -- Shadow Cloak (Shadow Cloak)
    [25380] = true, -- Shadowy Disguise (Shadowy Disguise)
    [25412] = true, -- Consuming Darkness (Consuming Darkness)
    [36495] = true, -- Bolstering Darkness (Bolstering Darkness)
    [36487] = true, -- Veil of Blades (Veil of Blades)

    ----------------------------
    -- Dragonknight
    ----------------------------

    [29126] = true, -- Ash Cloud
    [20780] = true, -- Cinder Storm
    [32712] = true, -- Eruption

    ----------------------------
    -- Sorcerer
    ----------------------------

    [29824] = true, -- Negate Magic
    [47147] = true, -- Negate Magic
    [47160] = true, -- Suppression Field
    [47159] = true, -- Suppression Field
    [47168] = true, -- Absorption Field
    [47167] = true, -- Absorption Field

    [24799] = true, -- Overload End
    [24808] = true, -- Overload End
    [24805] = true, -- Overload End

    ----------------------------
    -- Templar
    ----------------------------

    -- Passives
    [80195] = true, -- Sacred Ground (Sacred Ground) - Rune Focus
    [80230] = true, -- Sacred Ground (Sacred Ground) - Cleansing Ritual
    [80261] = true, -- Sacred Ground (Sacred Ground) - Rite of Passage

    -- Actives
    [76908] = true, -- Puncturing Strikes
    [76912] = true, -- Biting Jabs
    [76916] = true, -- Puncturing Sweep

    ----------------------------
    -- Warden
    ----------------------------

    [86238] = true, -- Impaling Shards (Impaling Shards)
    [87448] = true, -- Gripping Shards (Gripping Shards)
    [88801] = true, -- Winter's Revenge (Gripping Shards)
    [86250] = true, -- Sleet Storm (Sleet Storm)
    [88858] = true, -- Northern Storm (Northern Storm)
    [88861] = true, -- Permafrost (Permafrost)

    ----------------------------
    -- Necromancer
    ----------------------------
    [121513] = true, -- Grave Grasp (Grave Grasp)
    [143915] = true, -- Grave Grasp (Grave Grasp)
    [143917] = true, -- Grave Grasp (Grave Grasp)
    [118309] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118325] = true, -- Ghostly Embrace (Ghostly Embrace)
    [143945] = true, -- Ghostly Embrace (Ghostly Embrace)
    [118354] = true, -- Empowering Grasp (Empowering Grasp)
    [143948] = true, -- Empowering Grasp (Empowering Grasp)
    [143949] = true, -- Empowering Grasp (Empowering Grasp)

    ----------------------------
    -- One Hand and Shield
    ----------------------------

    [126604] = true, -- Defensive Posture (Defensive Posture)
    [126608] = true, -- Defensive Stance (Defensive Stance)
    [83301] = true,  -- Spell Wall (Spell Wall)

    ----------------------------
    -- Destruction Staff
    ----------------------------

    [68719] = true,  -- Frozen (Wall of Elements)
    [104825] = true, -- Icy Rage (Elemental Rage)

    ----------------------------
    -- Vampire Quest
    ----------------------------

    [39728] = true, -- VampInit_TheaterFeed
    [39509] = true, -- VampInit_PC Becomes a Vampire

    ----------------------------
    -- Psijic Order
    ----------------------------

    [103538] = true, -- Time Stop (Time Stop)
    [104007] = true, -- Time Stop (Time Stop)
    [104009] = true, -- Time Stop (Time Stop)
    [104071] = true, -- Borrowed Time (Borrowed Time)
    [104072] = true, -- Borrowed Time (Borrowed Time)
    [104073] = true, -- Borrowed Time (Borrowed Time)
    [104080] = true, -- Time Freeze (Time Freeze)
    [104081] = true, -- Time Freeze (Time Freeze)
    [104082] = true, -- Time Freeze (Time Freeze)
    [104083] = true, -- Time Freeze (Time Freeze)

    ----------------------------
    -- Undaunted
    ----------------------------

    [80079] = true, -- Trapping Webs (Trapping Webs)
    [80108] = true, -- Shadow Silk (Shadow Silk)
    [80130] = true, -- Tangling Webs (Tangling Webs)

    ----------------------------
    -- Assault
    ----------------------------

    [113769] = true, -- Caltrops (Caltrops)
    [113770] = true, -- Anti-Cavalry Caltrops (Anti-Cavalry Caltrops)
    [113771] = true, -- Razor Caltrops (Razor Caltrops)

    ----------------------------
    -- Artifacts
    ----------------------------

    -- Volendrung
    [116763] = true, -- Heavy Attack (Volendrung)
    [116680] = true, -- Ebony Cyclone (Ruinous Cyclone)

    -- NPC Basic
    [36845] = true, -- Shadow Cloak Stun Remover

    -- Cyrodiil
    [12355] = true, -- Destroy Siege Weapon

    -- Human NPC
    [10648] = true, -- Throw Oil (Synergy)
    [35391] = true, -- Defiled Grave (Bonelord)
    [87066] = true, -- Volanic Debris (Fire-Binder)
    [37132] = true, -- Ice Cage (Battlemage)

    -- Cyrodiil NPC
    [21632] = true, -- Lifesteal (Cryodiil Mage T1)
    [46718] = true, -- Stolen Essence (Cryodiil Mage T2)
    [51893] = true, -- Negate Magic (Cyrodiil Mender T1 + T2)

    -- Daedra NPC
    [35278] = true, -- Soul Flame (Daedric Titan)
    [51646] = true, -- Frozen Ground (Frost Atronach)
    [4829] = true,  -- Fire Brand (Flesh Atronach)
    [6410] = true,  -- Tail Clip (Winged Twilight)
    [24699] = true, -- Body Slam (Ogrim)

    -- Undead NPC
    [22525] = true, -- Defiled Ground (Lich)
    [13972] = true, -- Swipe (Zombie)

    -- Monster
    [32268] = true, -- Grapple (Hag)
    [95288] = true, -- Hurricane (Nereid)
    [5881] = true,  -- Smash (Ogre)
    [82685] = true, -- CC (Crown Control) Shared Cool
    [14221] = true, -- Grapple (Strangler)
    [75954] = true, -- Brimstone Hailfire (Minotaur Shaman)

    ----------------------------
    -- World Boss
    ----------------------------

    [84047] = true, -- Defiled Ground (World Boss - Quenyas)
    [83155] = true, -- Thunderous Smash (Thodundor of the Hill)
    [83180] = true, -- Molten Pillar (Big Ozur)
    [83184] = true, -- Molten Shackles (Ice Pillar)

    ----------------------------
    -- Quests
    ----------------------------

    -- Werewolf
    [55886] = true, -- Heavy Attack (Were) (Hircine's Gift)

    -- Main Quest
    [61648] = true, -- Replenish Stamina (Tutorial - Child of Bones)

    -- Mages Guild
    [40851] = true, -- Polymorph Snare (The Mad God's Bargain)

    -- Grahtwood
    [38748] = true, -- Aulus's Tongue (The Grips of Madness)

    -- Vvardenfell
    [82272] = true, -- Dark Reach (Slavemaster Arenim -- Vvardenfell -- The Heart of a Telvanni)
    [82273] = true, -- Dark Reach (Slavemaster Arenim -- Vvardenfell -- The Heart of a Telvanni)
    [89903] = true, -- Tonal Inverter (Divine Intervention)
    [86989] = true, -- Succubus Touch (Echoes of a Fallen House)

    -- Nchuleftingth (Public Dungeon)
    [86624] = true, -- Piston Thrust (Dwarven Piston)
    [90857] = true, -- Spike Trap (Dwarven Piston)
    [84334] = true, -- Demolish (Nchulaeon the Eternal)
    [84336] = true, -- Demolish (Nchulaeon the Eternal)

    -- Forgotten Wastes (Public Dungeon)
    [86934] = true, -- Volcanic Debris
    [86938] = true, -- Volcanic Debris
    [92707] = true, -- Volcanic Debris
    [92704] = true, -- Volcanic Debris

    ----------------------------
    -- World Bosses
    ----------------------------

    [83948] = true, -- Tail Sweep (Trapjaw) - Trapjaw's Cove

    ----------------------------
    -- Arenas
    ----------------------------

    -- Dragonstar Arena
    [53252] = true, -- Wrecking Blow (Yavni Frost-Skin)
    [54123] = true, -- Lingering Death (House Dres Slaver)
    [54078] = true, -- Eruption Snare (Earthen Heart Knight)
    [52932] = true, -- Solar Disturbance Snare (Shadow Knight)
    [52762] = true, -- Degeneration (Mavus Talnarith)
    [55486] = true, -- Cripple (Hiath the Battlemaster)

    -- Maelstrom Arena
    [71729] = true, -- Sigil of Defense (Sigil of Defense)
    [72200] = true, -- Wrecking Blow (Scavenger Thunder-Smith)
    [67810] = true, -- Frigid Waters
    [66381] = true, -- Obliterate (Matriach Runa)

    ----------------------------
    -- Dungeons
    ----------------------------

    -- Elden Hollow
    [8398] = true, -- Bleeding (Infernal Guardian)

    -- Elden Hollow II
    [34378] = true, -- Flame Geyser (Dubroze the Infestor)

    -- Tempest Island
    [6107] = true, -- Lightning Storm (Yalorasse the Speaker)
}

--- @class (partial) EffectHideSCT
Effects.EffectHideSCT = effectHideSCT
