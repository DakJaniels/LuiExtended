-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
local UnitNames = Data.UnitNames

-- When a certain boss in in range if this id is cast, use the specified name as the source (There are some cases where bosses have uniquely named abilities as other enemies in the dungeon so this is a way to have both show properly).
--- @class (partial) AlertBossNameConvert
local alertBossNameConvert =
{
    -- Focused Healing (Healer)
    [57534] =
    {

        -- DUNGEONS
        [UnitNames.Boss_Dubroze_the_Infestor] = UnitNames.NPC_Infested_Invoker, -- Elden Hollow II (other mobs in dungeon are NPC_Dremora_Invoker)
        [UnitNames.Boss_Ibelgast] = UnitNames.NPC_Ibelgasts_Cauterizer,         -- Crypt of Hearts II
    },
    -- Heat Wave (Fire Mage)
    [15164] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Ibelgast] = UnitNames.NPC_Ibelgasts_Cauterizer, -- Crypt of Hearts II
    },
    -- Fire Rune (Fire Mage)
    [47095] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Ibelgast] = UnitNames.NPC_Ibelgasts_Cauterizer, -- Crypt of Hearts II
    },
    -- Arrow Spray (Archer)
    [37108] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Ibelgast] = UnitNames.NPC_Ibelgasts_Wefter, -- Crypt of Hearts II
    },
    -- Volley (Archer)
    [28628] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Ibelgast] = UnitNames.NPC_Ibelgasts_Wefter, -- Crypt of Hearts II
    },
    -- Fire Brand (Flesh Atronach)
    [4829] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Ibelgast] = UnitNames.NPC_Ibelgasts_Flesh_Atronach, -- Crypt of Hearts II
    },
    -- Summon the Dead (Spiderkith Broodnurse)
    [51746] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Ibelgast] = UnitNames.NPC_Ibelgasts_Broodnurse, -- Crypt of Hearts II
    },
    -- Reanimate Skeleton (Spiderkith Broodnurse)
    [51753] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Ibelgast] = UnitNames.NPC_Ibelgasts_Broodnurse, -- Crypt of Hearts II
    },
    -- Spell Absorption (Spirit Mage)
    [35151] =
    {

        -- DUNGEONS
        [UnitNames.Boss_Dubroze_the_Infestor] = UnitNames.NPC_Infested_Invoker, -- Elden Hollow II (other mobs in dungeon are NPC_Dremora_Invoker)
    },
    -- Burdening Eye (Spirit Mage)
    [14472] =
    {

        -- DUNGEONS
        [UnitNames.Boss_Dubroze_the_Infestor] = UnitNames.NPC_Infested_Invoker, -- Elden Hollow II (other mobs in dungeon are NPC_Dremora_Invoker)
    },
    -- Dusk's Howl (Winged Twilight)
    [6412] =
    {

        -- DUNGEONS
        [UnitNames.Boss_Keeper_Imiril] = UnitNames.NPC_Dark_Twilight, -- Banished Cells II
    },
    -- Tail Spike (Clannfear)
    [4799] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Keeper_Imiril] = UnitNames.NPC_Dark_Clannfear, -- Banished Cells II
    },
    -- Rending Leap (Clannfear)
    [93745] =
    {
        -- DUNGEONS
        [UnitNames.Boss_Keeper_Imiril] = UnitNames.NPC_Dark_Clannfear, -- Banished Cells II
    },
}

--- @class (partial) AlertBossNameConvert
Data.AlertBossNameConvert = alertBossNameConvert
