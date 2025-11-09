-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData
local Data = LuiData.Data

local zo_callLater = zo_callLater

--- @class (partial) Quests
local quests = {}

-- List of Quest Items to ignore when Looted (Alot of quest items swap out for different id's mid quest and it looks silly having a ton of messages print)
quests.QuestItemHideLoot =
{
    -- Seasonal Quests
    [6013] = true, -- Soiled Napkin (Stonetooth Bash)
    [5918] = true, -- Crow Caller (The Witchmother's Bargain)

    -- Main Story Quests
    [2785] = true, -- Ayleid Tome (The Dangerous Past)

    -- Aldmeri Dominion
    [4264] = true, -- Ealcil's Lodestone (The Tempest Unleashed)
    [5434] = true, -- Deployment Plans (A Hostile Situation)
    [5435] = true, -- Poisoned Meat (A Hostile Situation)
    [3437] = true, -- Kindlepitch (Putting the Pieces Together)
    [3555] = true, -- Earring of the Altmer Nobility (Wearing the Veil)
    [3556] = true, -- Earring of the Altmer Nobility (The Veil Falls)
    [3357] = true, -- Runed Talisman (Breaking the Barrier)
    [3324] = true, -- Teleport Scroll (The Serpent's Beacon)
    [3769] = true, -- Teleport Scroll (Depths of Madness)
    [3770] = true, -- Teleport Scroll (Depths of Madness)
    [3771] = true, -- Teleport Scroll (Depths of Madness)
    [3416] = true, -- Teleport Scroll (Depths of Madness)
    [3400] = true, -- Binding Gem (Silent Village)
    [3292] = true, -- Sirinque's Crystal (An Act of Kindness)
    [3532] = true, -- Crystal (Preventative Measure)
    [4492] = true, -- Rajhin's Mantle (A Lasting Winter)
    [4650] = true, -- Heart of Anumaril (Heart of the Matter)
    [4596] = true, -- Rahjin's Mantle (The Orrery of Elden Root)
    [4645] = true, -- Rahjin's Mantle (The Orrery of Elden Root)
    [3663] = true, -- Lord Gharesh-ri's Notebook (Unsafe Haven)
    [4395] = true, -- Bag of Bones (Keeper of the Bones)
    [4396] = true, -- Bag of Bones (Keeper of the Bones)
    [4397] = true, -- Bag of Bones (Keeper of the Bones)
    [4398] = true, -- Bag of Bones (Keeper of the Bones)
    [4241] = true, -- Femur (Keeper of the Bones)
    [4243] = true, -- Tibia (Keeper of the Bones)
    [4244] = true, -- Fibula (Keeper of the Bones)
    [4245] = true, -- Ulna (Keeper of the Bones)
    [4246] = true, -- Radius (Keeper of the Bones)
    [4247] = true, -- Humerus (Keeper of the Bones)
    [4248] = true, -- Clavicle (Keeper of the Bones)
    [4249] = true, -- Scapula (Keeper of the Bones)
    [4251] = true, -- Finger Phalanges (Keeper of the Bones)
    [4252] = true, -- Toe Phalanges (Keeper of the Bones)
    [4253] = true, -- Vertebrae (Keeper of the Bones)
    [4254] = true, -- Ribs (Keeper of the Bones)
    [4259] = true, -- Pelvis (Keeper of the Bones)
    [4408] = true, -- Bone Scepter (The Unquiet Dead)
    [4387] = true, -- Bone Scepter (The Unquiet Dead)
    [4411] = true, -- Bone Scepter (The Unquiet Dead)
    [4431] = true, -- Sigil Geode (Eyes of Azura)
    [4432] = true, -- Sigil Geode (Eyes of Azura)
    [4433] = true, -- Sigil Geode (Eyes of Azura)
    [4442] = true, -- Sigil Geode (Eyes of Azura)
    [3597] = true, -- Rahkaz's Blade (The Enemy Within)
    [4577] = true, -- Dull Crystal Shard (Light in the Darkness)
}

-- List of Quest Items to ignore when Removed (Alot of quest items swap out for different id's mid quest and it looks silly having a ton of messages print)
quests.QuestItemHideRemove =
{
    -- Seasonal Quests
    [6012] = true, -- Soiled Napkin (Stonetooth Bash)

    -- Main Story Quests
    [2760] = true, -- Ayleid Tome (The Dangerous Past)

    -- Aldmeri Dominion
    [4423] = true, -- Ealcil's Lodestone (The Tempest Unleashed)
    [3429] = true, -- Deployment Plans (Ensuring Security)
    [3430] = true, -- Poisoned Meat (Ensuring Security)
    [3437] = true, -- Kindlepitch (Putting the Pieces Together)
    [3503] = true, -- Earring of the Altmer Nobility (Lifting the Veil)
    [3555] = true, -- Earring of the Altmer Nobility (Wearing the Veil)
    [3356] = true, -- Runed Talisman (Breaking the Barrier)
    [3325] = true, -- Teleport Scroll (The Serpent's Beacon)
    [3368] = true, -- Kindlepitch (The Serpent's Beacon)
    [3369] = true, -- Fire Salts (The Serpent's Beacon)
    [3415] = true, -- Teleport Scroll (Depths of Madness)
    [3769] = true, -- Teleport Scroll (Depths of Madness)
    [3770] = true, -- Teleport Scroll (Depths of Madness)
    [3771] = true, -- Teleport Scroll (Depths of Madness)
    [3403] = true, -- Bloodcrown Spores  (Depths of Madness)
    [3404] = true, -- Lavendercap Mushrooms (Depths of Madness)
    [3405] = true, -- Gleamcap Spores (Depths of Madness)
    [3395] = true, -- Binding Gem (Silent Village)
    [3291] = true, -- Micro Etched Crystal (An Act of Kindness)
    [3524] = true, -- Welyknd Stone (Eye of the Ancients)
    [3525] = true, -- Welyknd Stone (Eye of the Ancients)
    [3278] = true, -- Rune of Xarxes (The Mallari-Mora)
    [3279] = true, -- Rune of Magnus (The Mallari-Mora)
    [3532] = true, -- Crystal (Preventative Measure)
    [3491] = true, -- Crystal (Preventative Measure)

    [3458] = true, -- Relic Rescue
    [3459] = true, -- Relic Rescue
    [3460] = true, -- Relic Rescue
    [3461] = true, -- Relic Rescue
    [3462] = true, -- Relic Rescue
    [3463] = true, -- Relic Rescue
    [3464] = true, -- Relic Rescue
    [3465] = true, -- Relic Rescue

    [4492] = true, -- Rajhin's Mantle (A Lasting Winter)
    [3609] = true, -- Heart of Anumaril (Heart of the Matter)
    [4610] = true, -- Rahjin's Mantle (The Orrery of Elden Root)
    [4596] = true, -- Rahjin's Mantle (The Orrery of Elden Root)
    [4645] = true, -- Rahjin's Mantle (The Orrery of Elden Root)
    [3647] = true, -- Lord Gharesh-ri's Notebook (Unsafe Haven)
    [4261] = true, -- Bag of Bones (Keeper of the Bones)
    [4395] = true, -- Bag of Bones (Keeper of the Bones)
    [4396] = true, -- Bag of Bones (Keeper of the Bones)
    [4397] = true, -- Bag of Bones (Keeper of the Bones)
    [4241] = true, -- Femur (Keeper of the Bones)
    [4243] = true, -- Tibia (Keeper of the Bones)
    [4244] = true, -- Fibula (Keeper of the Bones)
    [4245] = true, -- Ulna (Keeper of the Bones)
    [4246] = true, -- Radius (Keeper of the Bones)
    [4247] = true, -- Humerus (Keeper of the Bones)
    [4248] = true, -- Clavicle (Keeper of the Bones)
    [4249] = true, -- Scapula (Keeper of the Bones)
    [4251] = true, -- Finger Phalanges (Keeper of the Bones)
    [4252] = true, -- Toe Phalanges (Keeper of the Bones)
    [4253] = true, -- Vertebrae (Keeper of the Bones)
    [4254] = true, -- Ribs (Keeper of the Bones)
    [4259] = true, -- Pelvis (Keeper of the Bones)
    [4384] = true, -- Bone Scepter (The Unquiet Dead)
    [4408] = true, -- Bone Scepter (The Unquiet Dead)
    [4387] = true, -- Bone Scepter (The Unquiet Dead)
    [4411] = true, -- Bone Scepter (The Unquiet Dead)
    [4479] = true, -- Loriasel Tablet Notes (Eyes of Azura)
    [4430] = true, -- Sigil Geode (Eyes of Azura)
    [4431] = true, -- Sigil Geode (Eyes of Azura)
    [4432] = true, -- Sigil Geode (Eyes of Azura)
    [4433] = true, -- Sigil Geode (Eyes of Azura)
    [4442] = true, -- Sigil Geode (Eyes of Azura)
    [3597] = true, -- Rahkaz's Blade (The Enemy Within)
    [3596] = true, -- Knife (The Enemy Within)
    [4576] = true, -- Dull Crystal Shard (Light in the Darkness)

    -- Vvardenfell
    [6125] = true, -- Fire Salts (Broken Bonds)
    [6126] = true, -- Kindlepitch (Broken Bonds)
}

-- Limit the maximum number of quantity of a quest item that can be added.
quests.QuestItemMaxQuantityAdd =
{
    [3518] = 1, -- Welkynd Stone (Eye of the Ancients)
}

-- When this item is gained display the "material" quest items used to make it.
quests.QuestItemMerge =
{

    [3360] = { 3368, 3369 },       -- Volatile Fire Mixture (The Serpent's Beacon) -- Kindlepitch, Fire Salts
    [3402] = { 3403, 3404, 3405 }, -- Spore Potion (The Depths of Madness) -- Bloodcrown Spores, Lavendercap Mushrooms, Gleamcap Spores

    -- Vvardenfell
    [6116] = { 6125, 6126 }, -- Fire Bomb (Broken Bonds) -- Fire Salts, Kindlepitch
}

-- Message to override when an item is removed.
-- LUIE_QUEST_MESSAGE_TURNIN = 1
-- LUIE_QUEST_MESSAGE_USE = 2
-- LUIE_QUEST_MESSAGE_EXHAUST = 3
-- LUIE_QUEST_MESSAGE_OFFER = 4
-- LUIE_QUEST_MESSAGE_DISCARD = 5
-- LUIE_QUEST_MESSAGE_CONFISCATE = 6
-- LUIE_QUEST_MESSAGE_OPEN = 11
-- LUIE_QUEST_MESSAGE_ADMINISTER = 12
-- LUIE_QUEST_MESSAGE_PLACE = 13
quests.ItemRemovedMessage =
{

    -- Jester's Festival
    [6163] = LUIE_QUEST_MESSAGE_OFFER,   -- Mudcrab Apples (A Noble Guest)
    [6145] = LUIE_QUEST_MESSAGE_DISCARD, -- Petal Pelters (Springtime Flair)
    [6186] = LUIE_QUEST_MESSAGE_TURNIN,  -- Glowing Ayleid Bone Dust (Royal Revelry)
    [6187] = LUIE_QUEST_MESSAGE_TURNIN,  -- Dragonfire Dust (Royal Revelry)
    [6192] = LUIE_QUEST_MESSAGE_EXHAUST, -- Burst Dazzler (Royal Revelry)
    [6193] = LUIE_QUEST_MESSAGE_EXHAUST, -- Flash Dazzler (Royal Revelry)
    [6191] = LUIE_QUEST_MESSAGE_EXHAUST, -- Sparkle Dazzler (Royal Revelry)
    [7628] = LUIE_QUEST_MESSAGE_DISCARD, -- Special Arena Pass (The King's Spoils)
    [7617] = LUIE_QUEST_MESSAGE_PLACE,   -- Slime Prank Kit (Prankster's Carnival)
    [7614] = LUIE_QUEST_MESSAGE_PLACE,   -- Glitter Prank Kit (Prankster's Carnival)
    [7616] = LUIE_QUEST_MESSAGE_PLACE,   -- Stinkpot Prank Kit (Prankster's Carnival)

    -- Werewolf / Vampire
    [5475] = LUIE_QUEST_MESSAGE_OFFER, -- Tribute (Hircine's Gift)

    -- Auridon (MSQ)
    [5434] = LUIE_QUEST_MESSAGE_CONFISCATE, -- Deployment Plans (A Hostile Situation)
    [5435] = LUIE_QUEST_MESSAGE_CONFISCATE, -- Poisoned Meat (A Hostile Situation)
    [3470] = LUIE_QUEST_MESSAGE_TURNIN,     -- Fistalle's Note (Putting the Pieces Together) -- TODO: Not sure if needed anymore
    [3434] = LUIE_QUEST_MESSAGE_TURNIN,     -- Armament Inventory (Putting the Pieces Together) -- TODO: Not sure if needed anymore
    [3435] = LUIE_QUEST_MESSAGE_TURNIN,     -- Heritance Officer's Uniform (Putting the Pieces Together) -- TODO: Not sure if needed anymore
    [3534] = LUIE_QUEST_MESSAGE_TURNIN,     -- Royal Blade (Lifting the Veil)
    [3556] = LUIE_QUEST_MESSAGE_EXHAUST,    -- Earring of Altmer Nobility (The Veil Falls)

    [3544] = LUIE_QUEST_MESSAGE_TURNIN,     -- Wedding Ring (Through the Ashes)
    [3548] = LUIE_QUEST_MESSAGE_DISCARD,    -- Missing Citizens (Through the Ashes)
    [3543] = LUIE_QUEST_MESSAGE_DISCARD,    -- Pendant (Through the Ashes)

    -- Stros M'Kai
    [3782] = LUIE_QUEST_MESSAGE_CONFISCATE, -- Giant Red Gemstone (Innocent Scoundrel)
    [3703] = LUIE_QUEST_MESSAGE_EXHAUST,    -- Neramo's Control Rod (Buried Secrets)
    [3888] = LUIE_QUEST_MESSAGE_EXHAUST,    -- Sea Drake Clothing Bundle (Like Moths to a Candle)
    [3780] = LUIE_QUEST_MESSAGE_DISCARD,    -- Storeroom Key (Like Moths to a Candle)
    [3781] = LUIE_QUEST_MESSAGE_DISCARD,    -- Antidote (Like Moths to a Candle)
    [3816] = LUIE_QUEST_MESSAGE_USE,        -- Headman Bhosek's Key (Tip of the Spearhead)
    [3818] = LUIE_QUEST_MESSAGE_USE,        -- Dwemer Device (Tip of the Spearhead)
    [3800] = LUIE_QUEST_MESSAGE_DISCARD,    -- Shovel (Izad's Treasure)
    [3803] = LUIE_QUEST_MESSAGE_OPEN,       -- The Clues, Damn Your Eyes (Izad's Treasure)
    [3819] = LUIE_QUEST_MESSAGE_DISCARD,    -- Captain Izad's Letter (Izad's Treasure)

    -- Vvardenfell
    [6116] = LUIE_QUEST_MESSAGE_USE, -- Fire Bomb (Broken Bonds)

    -- Elsweyr
    [7032] = LUIE_QUEST_MESSAGE_DISCARD, -- Letter from Abnur Tharn (Bright Moons, Warm Sands)
    [6929] = LUIE_QUEST_MESSAGE_USE,     -- Room Key (Bright Moons, Warm Sands)

    -- Greymoor
    [7161] = LUIE_QUEST_MESSAGE_TURNIN, -- Fennorian's Flask (Bound in Blood)
}

-- Message to override when an item is removed while we are in dialogue with an NPC.
quests.ItemRemovedInDialogueMessage =
{

    -- Stros M'Kai
    [3781] = LUIE_QUEST_MESSAGE_ADMINISTER, -- Antidote (Like Moths to a Candle)
}

-- Message to override when an item is received.
-- LUIE_QUEST_MESSAGE_COMBINE = 7
-- LUIE_QUEST_MESSAGE_MIX = 8
-- LUIE_QUEST_MESSAGE_BUNDLE = 9
-- LUIE_QUEST_MESSAGE_LOOT = 10
-- LUIE_QUEST_MESSAGE_STEAL = 14
quests.ItemReceivedMessage =
{

    -- Jester's Festival
    [6163] = LUIE_QUEST_MESSAGE_STEAL, -- Mudcrab Apples (A Noble Guest)
    [6192] = LUIE_QUEST_MESSAGE_LOOT,  -- Burst Dazzler (Royal Revelry)
    [6193] = LUIE_QUEST_MESSAGE_LOOT,  -- Flash Dazzler (Royal Revelry)
    [6191] = LUIE_QUEST_MESSAGE_LOOT,  -- Sparkle Dazzler (Royal Revelry)
    [7533] = LUIE_QUEST_MESSAGE_LOOT,  -- King Boar Invitational (A Foe Most Porcine)
    [7566] = LUIE_QUEST_MESSAGE_LOOT,  -- Fermented Mudcrab Apples (The King's Spoils)

    -- Auridon (MSQ)
    [3429] = LUIE_QUEST_MESSAGE_LOOT, -- Deployment Plans (Ensuring Security)
    [3470] = LUIE_QUEST_MESSAGE_LOOT, -- Fistalle's Note (Putting the Pieces Together)
    [3434] = LUIE_QUEST_MESSAGE_LOOT, -- Armament Inventory (Putting the Pieces Together)

    [3543] = LUIE_QUEST_MESSAGE_LOOT, -- Pendant (Through the Ashes)

    -- Stros M'Kai
    [3666] = LUIE_QUEST_MESSAGE_LOOT, -- Dwarven Part (Sphere Assembly)
    [3667] = LUIE_QUEST_MESSAGE_LOOT, -- Dwarven Part (Sphere Assembly)
    [3668] = LUIE_QUEST_MESSAGE_LOOT, -- Dwarven Part (Sphere Assembly)
    [3669] = LUIE_QUEST_MESSAGE_LOOT, -- Dwarven Part (Sphere Assembly)
    [3853] = LUIE_QUEST_MESSAGE_LOOT, -- Steel Bracelet (Dead Man's Wrist)
    [3854] = LUIE_QUEST_MESSAGE_LOOT, -- Crumpled Letter (Dead Man's Wrist)
    [3800] = LUIE_QUEST_MESSAGE_LOOT, -- Shovel (Izad's Treasure)
    [3803] = LUIE_QUEST_MESSAGE_LOOT, -- The Clues, Damn Your Eyes (Izad's Treasure)
    [3819] = LUIE_QUEST_MESSAGE_LOOT, -- Captain Izad's Letter (Izad's Treasure)
    [3858] = LUIE_QUEST_MESSAGE_LOOT, -- Shazeem's Blade (Washed Ashore)

    -- Vvardenfell
    [6116] = LUIE_QUEST_MESSAGE_MIX, -- Fire Bomb (Broken Bonds)

    -- Elsweyr
    [7032] = LUIE_QUEST_MESSAGE_LOOT, -- Letter from Abnur Tharn (Bright Moons, Warm Sands)
}

-- When turning a quest item in the prefix used is set to "Turn in" unless the "removed" message is changed. In which case it overrides that behavior. Items in this list will ignore their override message and ALWAYS display as turnin when turning in a quest.
quests.ItemIgnoreTurnIn = {}

-- TODO: Find a way to extend this to the quest log text
-- Replace the objective update text of a certain quest. Used to fix capitalization/punctuation errors. Matches string. Only works for EN.
quests.QuestAdvancedOverride =
{
    ["Tell Chief Dushkul that Gargak is dead"] = "Tell Chief Dushkul that Gargak is Dead",
}

quests.QuestObjectiveCompleteOverride =
{
    ["Completed: Run to Next Checkpoint"] = "Completed: Reach the Next Marker",
    ["Completed: Reach Next Marker"] = "Completed: Reach the Next Marker",
}

-- Call specific functions to add/remove table entries for funky quest items. This will trigger when a certain quest item is added.
quests.QuestItemModifyOnAdd =
{
    [3278] = function ()
        quests.QuestItemHideLoot[3280] = true
    end, -- Rune of Xarxes (The Mallari-Mora)
    [3279] = function ()
        quests.QuestItemHideLoot[3281] = true
    end, -- Rune of Magnus (The Mallari-Mora)
    [3532] = function ()
        quests.QuestItemHideLoot[3491] = true
    end, -- Crystal (Preventative Measure)
    [3769] = function ()
        quests.QuestItemHideLoot[3415] = true
    end, -- Teleport Scroll (Depths of Madness)
    [4485] = function ()
        quests.QuestItemHideRemove[4485] = true
    end, -- Rajhin's Mantle (A Lasting Winter)
    [4492] = function ()
        quests.QuestItemHideLoot[4485] = true
    end, -- Rajhin's Mantle (A Lasting Winter)
    [3597] = function ()
        quests.QuestItemHideLoot[3596] = true
    end, -- Rahkaz's Blade (The Enemy Within)

    -- Daggerfall Covenant
    [3818] = function ()
        quests.QuestItemHideLoot[3818] = true
    end, -- Dwemer Device (Tip of the Spearhead)
}

-- Call specific functions to add/remove table entries for funky quest items. This will trigger when a certain quest item is removed.
quests.QuestItemModifyOnRemove =
{
    [3532] = function ()
        quests.QuestItemHideRemove[3491] = nil
    end, -- Crystal (Preventative Measure)
    [4492] = function ()
        zo_callLater(function ()
                         quests.QuestItemHideRemove[4485] = nil
                     end, 2000)
    end, -- Rajhin's Mantle (A Lasting Winter)
    [4645] = function ()
        zo_callLater(function ()
                         quests.QuestItemHideRemove[4596] = nil
                     end, 2000)
    end, -- Rahjin's Mantle (The Orrery of Elden Root)
    [4411] = function ()
        quests.QuestItemHideRemove[4411] = nil
    end, -- Bone Scepter (The Unquiet Dead)
    [4479] = function ()
        quests.QuestItemHideLoot[4479] = true
        quests.QuestItemHideRemove[4479] = false
    end, -- Loriasel Tablet Notes (Eyes of Azura)
    [4442] = function ()
        quests.QuestItemHideRemove[4433] = nil
    end, -- Sigil Geode (Eyes of Azura)
    [3597] = function ()
        quests.QuestItemHideRemove[3596] = nil
    end, -- Rahkaz's Blade (The Enemy Within)

    -- Daggerfall Covenant
    [3818] = function ()
        quests.QuestItemHideRemove[3818] = true
    end, -- Dwemer Device (Tip of the Spearhead)
}

--- @class (partial) Quests
Data.Quests = quests
