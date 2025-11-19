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
--- @class (partial) aoeNPCBoss
local aoeNPCBoss =
{

    -- Vvardenfell
    [94936] = 0, -- Tremor (Nchuleftingth - Mud-Tusk)
    [86566] = 1, -- Fire Runes (Nchuleftingth - Friar Hadelar)
    [89754] = 1, -- Shocking Rake (Old Rust-Eye - Khartag Point)
    [90148] = 1, -- Sunder's Echo (Vvardenfell -- Divine Intervention)
    [90146] = 0, -- Sunder's Echo (Vvardenfell -- Divine Intervention)
    [69284] = 1, -- Whirlwind Function (Guardian of Bthark -- Nchuleftingth)
    [86607] = 1, -- Steam Breath (Guardian of Bthark -- Nchuleftingth)

    -- Elsweyr
    [124352] = 1, -- Flame Aura (Bahlokdaan)

    -- World Bosses
    [84045] = 1, -- Seal of Defilement (Quenyas) - World Boss - Seaside Scarp Camp
    [84206] = 1, -- Stinging Sputum (Gathongor the Mauler) - World Boss - Gathongor's Mine
    [83668] = 1, -- Feral Impact (Skullbreaker) - World Boss - Windshriek Strand
    [83671] = 1, -- Feral Impact (Skullbreaker) - World Boss - Windshriek Strand
    [84160] = 1, -- Spit Poison (Old Widow Silk) - World Boss - Spider Nest
    [84549] = 1, -- Venom Spray (Old Widow Silk) - World Boss - Spider Nest
    [83000] = 1, -- Crabuchet (Titanclaw) - World Boss - Mudcrab Beach
    [83021] = 1, -- Crabuchet (Titanclaw) - World Boss - Mudcrab Beach

    -- Quests
    [36860] = 1, -- Swordstorm Damage (MSQ - Halls of Torment)
    [87959] = 1, -- Ash Storm (Vvardenfell -- Divine Delusions)

    -- Dragonstar Arena
    [53660] = 1, -- Power Overload Heavy Attack (Nak'tah)
    [54084] = 1, -- Corrosive Armor (Earthen Heart Knight)
    [52903] = 1, -- Standard of Might (Anal'a Tu'wha0)
    [52933] = 1, -- Solar Disturbance (Shadow Knight)
    [55086] = 1, -- Poison Mist (Vampire Lord Thisa)
    [55092] = 1, -- Devouring Swarm (Vampire Lord Thisa)
    [55104] = 1, -- Marked for Death (Hiath the Battlemaster)
    [55182] = 0, -- Marked for Death (Hiath the Battlemaster)

    -- Maelstrom Arena
    [68197] = 1, -- Necrotic Essence (Necrotic Orb)
    [70901] = 1, -- Defiled Grave (Maxus the Many) -- NORMAL
    [72149] = 0, -- Defiled Grave (Maxus the Many) -- VETERAN
    [69366] = 1, -- Barrage Function (Centurion Champion)
    [69316] = 1, -- Electric Shield (Centurion Champion)
    [73880] = 1, -- Call Lightning (Lamia Queen)
    [67758] = 1, -- Queen's Poison (Lamia Queen)
    [68537] = 1, -- Overcharged Bolt (The Control Guardian)
    [70860] = 1, -- Overheated Flame (The Control Guardian)
    [68543] = 1, -- Overheated Volley (The Control Guardian)

    -- Banished Cells I
    [19027] = 1, -- Dead Zone (Skeletal Destroyer)
    [33188] = 1, -- Daedric Tempest (High Kinlord Rilis)

    -- Banished Cells II
    [28904] = 1, -- Immolating Bite (Maw of the Infernal)
    [49149] = 1, -- Breath of Flame (Maw of the Infernal)
    [29020] = 1, -- Berserker Frenzy (Keeper Voranil)
    [31727] = 1, -- Corruption (Keeper Imiril)
    [48800] = 1, -- Daedric Tempest (High Kinlord Rilis)
    [48815] = 0, -- Daedric Tempest (High Kinlord Rilis)

    -- Elden Hollow I
    [16017] = 1, -- Berserker Frenzy (Akasha gra-Mal)
    [25300] = 0, -- Berserker Frenzy (Akasha gra-Mal)
    [25301] = 0, -- Berserker Frenzy (Akasha gra-Mal)
    [25302] = 0, -- Berserker Frenzy (Akasha gra-Mal)
    [42601] = 1, -- Necrotic Circle (Canonreeve Oraneth)

    -- Elden Hollow II
    -- [34377] = 1, -- Flame Geyser (Dubroze the Infestor)
    [32972] = 1, -- Consuming Shadow (Murklight)
    [33050] = 1, -- Eclipse (Murklight)
    [33103] = 1, -- Spout Shadow (The Shadow Guard)
    [33434] = 1, -- Daedric Flame (Bogdan the Nightflame)

    -- City of Ash I
    [34960] = 1, -- Blazing Fire (Warden of the Shrine)
    [35145] = 1, -- Consuming Fire (Infernal Guardian)
    [34204] = 1, -- Burning Field (Rothariel Flameheart)

    -- City of Ash II
    [56415] = 1, -- Fire Runes (Urata the Legion)
    [55314] = 1, -- Slag Breath (Horvantud the Fire Maw)
    [55334] = 0, -- Fiery Breath (Horvantud the Fire Maw)
    [55321] = 0, -- Fiery Breath (Horvantud the Fire Maw)
    [55336] = 0, -- Fiery Breath (Horvantud the Fire Maw)
    [55327] = 0, -- Fiery Breath (Horvantud the Fire Maw)
    [55338] = 0, -- Fiery Breath (Horvantud the Fire Maw)
    [56010] = 1, -- Ground Quake (Horvantud the Fire Maw)
    [56151] = 1, -- Ethereal Flame (Ash Titan)
    [55175] = 1, -- Molten Rain (Ash Titan)
    [54637] = 1, -- Flame Tornado (Air Atronach)
    [55756] = 1, -- Burning (Valkyn Skoria)

    -- Tempest Island
    [26619] = 1, -- Shock (Sudden Storm)
    [6108] = 1,  -- Lightning Storm (Yalorasse the Speaker)
    [26752] = 1, -- Enervating Stone (Stormfist)
    [26517] = 1, -- Electrical Shock (Twister)

    -- Selene's Web
    [30908] = 1, -- Summon Primal Swarm (Treethane Kerninn)
    [30773] = 1, -- Arrow Rain (Longclaw)
    [31150] = 1, -- Poison Burst (Longclaw)
    [31203] = 1, -- Venomous Burst (Queen Aklayah)

    -- Spindleclutch II
    [28006] = 1, -- Cave In (Blood Spawn)
    [47332] = 0, -- Cave-In (Blood Spawn)
    [27603] = 1, -- Blood Pool (Urvan Veleth)
    [27906] = 1, -- Blood Pool (Vorenor Winterbourne)

    -- Wayrest Sewers I
    [25591] = 1, -- Necrotic Essence (Investigator Garron)

    -- Wayrest Sewers II
    [36625] = 1, -- Scourging Spark (Malubeth the Scourger)
    [36869] = 1, -- Scorching Flames (Uulgarg the Risen)
    [36944] = 1, -- Necrotic Barrage (Garron the Returned)

    -- Crypt of Hearts I
    [22716] = 1, -- Necrotic Ritual (Archmaster Siniel)
    [46950] = 1, -- Fire Trail (Death's Leviathan)
    [22432] = 1, -- Electric Prison (Lightning Rod)
    [22388] = 1, -- Rain Fire (Ilambris-Zaven)
    [22398] = 1, -- Call Lightning (Ilambris-Athor)
    [22401] = 0, -- Call Lightning (Ilambris-Athor)
    [22403] = 0, -- Call Lightning (Ilambris-Athor)

    -- Crypt of Hearts II
    [51883] = 1, -- Creeping Storm (Creeping Storm)
    [52286] = 1, -- Rain Fire (Ilambris Amalgam)
    [52335] = 0, -- Rain Fire (Ilambris Amalgam)
    [52279] = 1, -- Call Lightning (Ilambris Amalgam)
    [52339] = 0, -- Call Lightning (Ilambris Amalgam)
    [52082] = 1, -- Cursed Ground (Nerien'eth)
    [53157] = 0, -- Cursed Ground (Nerien'eth)
    [53134] = 1, -- Tortured Souls (Soul Cage)

    -- Volenfell
    [25030] = 1, -- Twisted Steel (Quintus Verres)
    [25143] = 1, -- Burning Ground (Quintus Verres)
    [25223] = 1, -- Heaving Quake (Quintus Verres)
    [25674] = 1, -- Flame Burst (Boilbite)
    [25675] = 1, -- Flame Burst (Boilbite)
    [25676] = 1, -- Flame Burst (Boilbite)
    [25677] = 1, -- Flame Burst (Boilbite)
    [44113] = 1, -- Barrage Function (The Guardian's Spark)
    [25213] = 1, -- Whirlwind Function (The Guardian's Strength)
}

--- @class (partial) aoeNPCBoss
CrowdControl.aoeNPCBoss = aoeNPCBoss
