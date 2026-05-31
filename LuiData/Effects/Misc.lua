-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects
local Abilities = Data.Abilities

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR MISC OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- List of abilities considered for Ultimate generation - used by CombatInfo to determine when Ultimate is being generated (Uses base abilityName sent to the listener - so we need the default names, not LuiData modified ones)
--------------------------------------------------------------------------------------------------------------------------------

Effects.IsWeaponAttack =
{
    [Abilities.Skill_Light_Attack_Unarmed] = true,     -- Light Attack (Unarmed)
    [Abilities.Skill_Heavy_Attack_Unarmed] = true,     -- Heavy Attack (Unarmed)
    [Abilities.Skill_Light_Attack_Two_Handed] = true,  -- Light Attack (Two Handed)
    [Abilities.Skill_Heavy_Attack_Two_Handed] = true,  -- Heavy Attack (Two Handed)
    [Abilities.Skill_Light_Attack_One_Handed] = true,  -- Light Attack (One Handed)
    [Abilities.Skill_Heavy_Attack_One_Handed] = true,  -- Heavy Attack (One Handed)
    [Abilities.Skill_Light_Attack_Dual_Wield] = true,  -- Light Attack (Dual Wield)
    [Abilities.Skill_Heavy_Attack_Dual_Wield] = true,  -- Heavy Attack (Dual Wield)
    [Abilities.Skill_Light_Attack_Bow] = true,         -- Light Attack (Bow)
    [Abilities.Skill_Heavy_Attack_Bow] = true,         -- Heavy Attack (Bow)
    [Abilities.Skill_Light_Attack_Ice] = true,         -- Light Attack (Ice)
    [Abilities.Skill_Heavy_Attack_Ice] = true,         -- Heavy Attack (Ice)
    [Abilities.Skill_Light_Attack_Inferno] = true,     -- Light Attack (Inferno)
    [Abilities.Skill_Heavy_Attack_Inferno] = true,     -- Heavy Attack (Inferno)
    [Abilities.Skill_Light_Attack_Lightning] = true,   -- Light Attack (Lightning)
    [Abilities.Skill_Heavy_Attack_Lightning] = true,   -- Heavy Attack (Lightning)
    [Abilities.Skill_Light_Attack_Restoration] = true, -- Light Attack (Restoration)
    [Abilities.Skill_Heavy_Attack_Restoration] = true, -- Heavy Attack (Restoration)
    [Abilities.Skill_Light_Attack_Volendrung] = true,  -- Light Attack (Volendrung)
    [Abilities.Skill_Heavy_Attack_Volendrung] = true,  -- Heavy Attack (Volendrung)
}

--------------------------------------------------------------------------------------------------------------------------------
-- List of abilities flagged as a Toggle. For the purpose of adding a "T" label to the buff icon.
--------------------------------------------------------------------------------------------------------------------------------
Effects.IsToggle =
{
    -- Innate
    [20299] = true, -- Sneak -- Used for hidden
    [20309] = true, -- Hidden -- Used for invisibility
    [40165] = true, -- Scene Choreo Brace (Monster Fight))
    [29761] = true, -- Brace (Guard)

    -- Sets
    [117082] = true, -- Frozen Watcher (Frozen Watcher)
    [134930] = true, -- Duneripper's Scales (Duneripper)
    [135554] = true, -- Grave Guardian (Grave Guardian's)

    -- Sorcerer
    [23304] = true, -- Summon Unstable Familiar
    [23319] = true, -- Summon Unstable Clannfear
    [23316] = true, -- Summon Volatile Familiar
    [24613] = true, -- Summon Winged Twilight
    [24636] = true, -- Summon Twilight Tormentor
    [24639] = true, -- Summon Twilight Matriarch
    [24785] = true, -- Overload
    [24806] = true, -- Energy Overload
    [24804] = true, -- Power Overload

    -- Warden
    [85982] = true, -- Feral Guardian
    [85986] = true, -- Eternal Guardian
    [85990] = true, -- Wild Guardian

    -- Psijic Order
    [103923] = true, -- Concentrated Barrier
    [103966] = true, -- Concentrated Barrier
    [103543] = true, -- Mend Wounds
    [103747] = true, -- Mend Spirit
    [103755] = true, -- Symbiosis
    [103492] = true, -- Meditate
    [103652] = true, -- Deep Thoughts
    [103665] = true, -- Introspection

    -- Support
    [80923] = true, -- Guard (Guard)
    [80947] = true, -- Mystic Guard (Mystic Guard)
    [80983] = true, -- Stalwart Guard (Stalwart Guard)

    -- Vampire
    [132141] = true, -- Blood Frenzy
    [134160] = true, -- Simmering Frenzy
    [135841] = true, -- Sated Fury
    [32986] = true,  -- Mist Form
    [38963] = true,  -- Elusive Mist
    [38965] = true,  -- Blood Mist

    -- NPC Abilities
    [44258] = true, -- Magelight (Soulbrander)
}

--------------------------------------------------------------------------------------------------------------------------------
-- Context Based Hidden Effects - Used by SpellCastBuffs.UpdateContextHideList to bulk hide certain abilities from displaying Buffs/Debuffs in the menu options.
--------------------------------------------------------------------------------------------------------------------------------

-- Vampire Stages
Effects.IsVamp =
{
    [135397] = true, -- Vampire Stage 1
    [135399] = true, -- Vampire Stage 2
    [135400] = true, -- Vampire Stage 3
    [135402] = true, -- Vampire Stage 4
    [135412] = true, -- Vampire Stage 5
}

-- Werewolf Buff
Effects.IsLycan =
{
    [35658] = true, -- Lycanthrophy
}

-- Werewolf & Vampire Precursor Diseases
Effects.IsVampLycanDisease =
{
    [39472] = true, -- Noxiphilic Sanguivoria (NPC Bite)
    [40360] = true, -- Noxiphilic Sanguivoria (Player Bite)
    [31068] = true, -- Sanies Lupinus (NPC Bite)
    [40521] = true, -- Sanies Lupinus (Player Bite)
}

-- Werewolf & Vampire Bite Cooldown Timers
Effects.IsVampLycanBite =
{
    [40359] = true, -- Fed on ally (Vampire)
    [40525] = true, -- Bit an ally (Werewolf)
}

-- Mundus Passives
Effects.IsBoon =
{
    [13940] = true, -- Boon: The Warrior
    [13943] = true, -- Boon: The Mage
    [13974] = true, -- Boon: The Serpent
    [13975] = true, -- Boon: The Thief
    [13976] = true, -- Boon: The Lady
    [13977] = true, -- Boon: The Steed
    [13978] = true, -- Boon: The Lord
    [13979] = true, -- Boon: The Apprentice
    [13980] = true, -- Boon: The Ritual
    [13981] = true, -- Boon: The Lover
    [13982] = true, -- Boon: The Atronach
    [13984] = true, -- Boon: The Shadow
    [13985] = true, -- Boon: The Tower
}

-- Cyrodiil Scrolls
Effects.IsCyrodiil =
{
    [15060] = true, -- Defensive Scroll Bonus I
    [16350] = true, -- Defensive Scroll Bonus II
    [15058] = true, -- Offensive Scroll Bonus I
    [16348] = true, -- Offensive Scroll Bonus II
}

-- Soul Summons
Effects.IsSoulSummons =
{
    [43752] = true, -- Soul Summons
}

-- Internal Cooldown for Set Procs
Effects.IsSetICD =
{
    [129477] = true, -- Immortal Warrior
    [127235] = true, -- Eternal Warrior
    [127032] = true, -- Phoenix
    [142401] = true, -- Juggernaut
    [117397] = true, -- Exhausted Sentry (of the Sentry)
}

-- Internal Cooldown for Ability Procs
Effects.IsAbilityICD =
{
    [151113] = true, -- Expert Evasion (Champion)
    [134254] = true, -- Winded (Champion)
}

-- Experience Buffs
Effects.IsExperienceBuff =
{
    -- Consumable
    [64210] = true,  -- Psijic Ambrosia
    [89683] = true,  -- Aetherial Ambrosia
    [88445] = true,  -- Mythic Aetherial Ambrosia
    [66776] = true,  -- Crown Experience Scroll
    [85501] = true,  -- Crown Crate Experience Scroll
    [85502] = true,  -- Major Crown Crate Experience Scroll
    [85503] = true,  -- Grand Crown Crate Experience Scroll
    [241125] = true, -- Hero's Return Experience Scroll
    [262221] = true, -- Tonic of Portent Favor

    -- Event
    [91369] = true,  -- The Pie of Misrule (Jester's Experience Boost Pie)
    [77123] = true,  -- Anniversary EXP Buff
    [118985] = true, -- Anniversary EXP Buff
    [136348] = true, -- Anniversary EXP Buff
    [152514] = true, -- Anniversary EXP Buff
    [96118] = true,  -- Witchmother's Boon
}

-- Alliance War XP Buffs
Effects.IsAllianceXPBuff =
{
    -- Consumable
    [147466] = true, -- Alliance Skill Gain (Alliance War Skill Line Scroll)
    [137733] = true, -- Alliance Skill Gain (Alliance War Skill Line Scroll, Major)
    [147467] = true, -- Alliance Skill Gain (Alliance War Skill Line Scroll, Grand)
    [147687] = true, -- Alliance Skill Gain 50% Boost (Colovian War Torte)
    [147733] = true, -- Alliance Skill Gain 100% Boost (Molten War Torte)
    [147734] = true, -- Alliance Skill Gain 150% Boost (White-Gold War Torte)
    -- World
    [66282] = true,  -- Blessing of War
}

-- Block Buffs (NPC and Player)
Effects.IsBlock =
{
    [29761] = true, -- Brace
    [40165] = true, -- Scene Choreo Brace
}

--------------------------------------------------------------------------------------------------------------------------------
-- Ground Mine Auras tracking
--------------------------------------------------------------------------------------------------------------------------------

Effects.IsGroundMineAura =
{
    -- Nightblade
    [37475] = true, -- Manifestation of Terror (Nightblade)

    -- Sorcerer
    [24830] = true, -- Daedric Mines (Daedric Mines)
    [24847] = true, -- Daedric Mines (Daedric Tomb)
    [25158] = true, -- Daedric Mines (Daedric Minefield)

    -- Fighters Guild
    [35750] = true, -- Trap Beast (Trap Beast)
    [40382] = true, -- Barbed Trap (Barbed Trap)
    [40372] = true, -- Lightweight Beast Trap (Lightweight Beast Trap)

    -- Mages Guild
    [31632] = true, -- Fire Rune (Fire Rune)
    [40470] = true, -- Volcanic Rune (Volcanic Rune)
    [40465] = true, -- Scalding Rune (Scalding Rune)

    -- Psijic Order
    [104079] = true, -- Time Freeze (Time Freeze)
}

--------------------------------------------------------------------------------------------------------------------------------
-- Ground Mine damage id's - breaks the trap beast mine tracker when this id is triggered
--------------------------------------------------------------------------------------------------------------------------------

Effects.IsGroundMineDamage =
{
    -- Fighter's Guild
    [35754] = true, -- Trap Beast (Trap Beast)
    [40389] = true, -- Barbed Trap (Barbed Trap)
    [40376] = true, -- Lightweight Beast Trap (Lightweight Beast Trap)
}

--------------------------------------------------------------------------------------------------------------------------------
-- Effects in this category will not have their stack count for mines display (This is effectively used for creating fake mines) for the purpose of some effects
--------------------------------------------------------------------------------------------------------------------------------

Effects.HideGroundMineStacks =
{
    [104079] = true, -- Time Freeze (Time Freeze)
}

--------------------------------------------------------------------------------------------------------------------------------
-- Abilities flagged as Ground Mines that need a stack counter, when an EFFECT_RESULT_FADED event occurs for these buffs decrement by 1 instead of being removed
--------------------------------------------------------------------------------------------------------------------------------

Effects.IsGroundMineStack =
{
    -- Sets
    [75930] = true, -- Deadric Mines (Eternal Hunt)

    -- Warden
    [86175] = true, -- Frozen Gate (Frozen Gate)
    [86179] = true, -- Frozen Device (Frozen Device)
    [86183] = true, -- Frozen Retreat (Frozen Retreat)
}

--------------------------------------------------------------------------------------------------------------------------------
-- Linked id's for tracking ground mine explosions - These id's all all merged into one and considered for the purpose of reducing the stack count of certain mine abilities
--------------------------------------------------------------------------------------------------------------------------------

Effects.LinkedGroundMine =
{
    [24832] = 24830, -- Daedric Mines (Daedric Mines)
    [24833] = 24830, -- Daedric Mines (Daedric Mines)

    [24846] = 24847, -- Daedric Mines (Daedric Tomb)
    [24844] = 24847, -- Daedric Mines (Daedric Tomb)

    [25157] = 25158, -- Daedric Mines (Daedric Minefield)
    [25159] = 25158, -- Daedric Mines (Daedric Minefield)
    [25160] = 25158, -- Daedric Mines (Daedric Minefield)
    [25162] = 25158, -- Daedric Mines (Daedric Minefield)
}

--------------------------------------------------------------------------------------------------------------------------------
-- Tracking for CC triggered from blocking/bashing enemies, we filter this out in Combat Alerts so they don't erroneously interrupt casts.
--------------------------------------------------------------------------------------------------------------------------------

Effects.BlockAndBashCC =
{
    [21972] = true, -- Stagger
    [21971] = true, -- Bash Stun
    [48416] = true, -- Uber Attack
    [45982] = true, -- Bash Stun
    [86310] = true, -- Stagger
    [86309] = true, -- Stun
    [86312] = true, -- Stun
}

--------------------------------------------------------------------------------------------------------------------------------
-- Filter out Debuffs to always display regardless of whether they are sourced from the player - useful for some odd effects that get applied by the player or a player pet but aren't actually sourced from them on the API
--------------------------------------------------------------------------------------------------------------------------------

Effects.DebuffDisplayOverrideId =
{
    ----------------------------------------------------------------
    -- INNATE / SHARED ---------------------------------------------
    ----------------------------------------------------------------

    -- Basic (Shared)
    [16593] = true, -- Melee Snare

    ----------------------------------------------------------------
    -- HOUSING TARGET DUMMY ----------------------------------------
    ----------------------------------------------------------------

    [120007] = true, -- Crusher
    [120011] = true, -- Engulfing Flames
    [120018] = true, -- Roar of Alkosh

    ----------------------------------------------------------------
    -- PLAYER ABILITIES --------------------------------------------
    ----------------------------------------------------------------

    -- Glyphs
    [17906] = true, -- Crusher (Glyph of Crushing)
    [17945] = true, -- Weakening (Glyph of Weakening)

    -- Item Sets
    [127070] = true, -- Way of Martial Knowledge (... of Martial Knowledge)
    [93305] = true,  -- Defiler (Defiler's)
    [51315] = true,  -- Destructive Mage (Aether ... of Destruction)
    [75753] = true,  -- Line-Breaker (of Alkosh)
    [93001] = true,  -- Mad Tinkerer (Stun from Fabricant)
    [126597] = true, -- Touch of Z'en (Z'en's)
    [126631] = true, -- Blight Seed (Azureblight)
    [80990] = true,  -- Shadowrend (Shadowrend)
    [81034] = true,  -- Shadowrend (Shadowrend)
    [80866] = true,  -- Tremorscale (Tremorscale)
    [100302] = true, -- Piercing Spray (Asylum Bow)
    [34384] = true,  -- The Morag Tong (of the Morag Tong)
    [142610] = true, -- Flame Weakness (of the Catalyst)
    [142652] = true, -- Frost Weakness (of the Catalyst)
    [142653] = true, -- Shock Weakness (of the Catalyst)

    -- Dragonknight
    [134336] = true, -- Stagger (Stone Giant)
    [98447] = true,  -- Shackle Snare (Dragonknight Standard Synergy)

    -- Sorcerer
    [143808] = true, -- Crystal Weapon (Crystal Weapon)

    -- Templar
    [31562] = true, -- Supernova (Nova Synergy)
    [34443] = true, -- Gravity Crush (Solar Prison Synergy)

    -- Warden
    [89129] = true,  -- Crushing Swipe (Feral Guardian)
    [105908] = true, -- Crushing Swipe (Eternal Guardian)
    [92666] = true,  -- Crushing Swipe (Wild Guardian)

    -- Necromancer
    [118618] = true, -- Pure Agony (Agony Totem)

    -- Warden
    [87560] = true, -- Frozen Gate Root (Frozen Gate)
    [92039] = true, -- Frozen Gate Root (Frozen Device)
    [92060] = true, -- Frozen Retreat Root (Frozen Retreat)

    -- Undaunted
    [42007] = true, -- Black Widow Poison (Shadow Silk - Black Widow Synergy)

    -- Werewolf
    [127161] = true, -- Lunge (Pack Leader)
}

-- These will always show regardless of the menu setting since they may indicate important information (self applied debuffs on enemy NPCs)
Effects.DebuffDisplayOverrideIdAlways =
{

    ----------------------------------------------------------------
    -- BASIC -----------------------------------------------
    ----------------------------------------------------------------

    [134599] = true, -- Off Balance Immunity
    -- Off Balance debuffs (LuiData/Effects/OffBalance.lua)
    [1347] = true,
    [2727] = true,
    [4508] = true,
    [5805] = true,
    [6150] = true,
    [7534] = true,
    [8392] = true,
    [11474] = true,
    [14062] = true,
    [14884] = true,
    [20806] = true,
    [25256] = true,
    [29598] = true,
    [34733] = true,
    [34737] = true,
    [37152] = true,
    [39077] = true,
    [45834] = true,
    [45902] = true,
    [61980] = true,
    [62968] = true,
    [62988] = true,
    [63108] = true,
    [70054] = true,
    [71877] = true,
    [72279] = true,
    [75214] = true,
    [89681] = true,
    [92265] = true,
    [99535] = true,
    [100582] = true,
    [100686] = true,
    [100689] = true,
    [100694] = true,
    [104012] = true,
    [116998] = true,
    [117008] = true,
    [117009] = true,
    [117010] = true,
    [117011] = true,
    [117292] = true,
    [120014] = true,
    [121026] = true,
    [121031] = true,
    [121042] = true,
    [121123] = true,
    [121124] = true,
    [125750] = true,
    [128752] = true,
    [130129] = true,
    [130139] = true,
    [130145] = true,
    [131562] = true,
    [137257] = true,
    [137312] = true,
    [154579] = true,
    [156183] = true,
    [163593] = true,
    [164731] = true,
    [186482] = true,
    [192997] = true,
    [208859] = true,
    [211496] = true,
    [212853] = true,
    [214432] = true,
    [218822] = true,
    [230828] = true,
    [236061] = true,
    [240504] = true,
    [241340] = true,
    [253689] = true,
    [256815] = true,
    [132831] = true, -- Major Vulnerability Invulnerability

    ----------------------------------------------------------------
    -- NPC ABILITIES -----------------------------------------------
    ----------------------------------------------------------------

    -- Human NPC's
    [88281] = true, -- Call Ally (Pet Ranger)
    [89017] = true, -- Dark Shade (Dreadweaver)
    [88561] = true, -- Summon the Dead (Necromancer)
    [88504] = true, -- Summon Abomination (Bonelord)
    [92158] = true, -- Raise the Earth (Beastcaller)
    [29597] = true, -- Combustion (Shaman)
    [89301] = true, -- Summon Spiderling (Spider Daedra)

    -- Monsters
    [89399] = true, -- Summon Spectral Lamia (Lamia)
    [89127] = true, -- Summon Beast (Spriggan)
    [42794] = true, -- Strangler: (Strangler)
    [48294] = true, -- Consuming Omen (Troll - Ranged)

    ----------------------------------------------------------------
    -- WORLD BOSSES ------------------------------------------------
    ----------------------------------------------------------------

    [84172] = true, -- Charge (Trapjaw)

    ----------------------------------------------------------------
    -- ARENAS ------------------------------------------------------
    ----------------------------------------------------------------

    -- Maelstrom Arena
    [72450] = true, -- Interrupted (Troll Breaker)
}

--------------------------------------------------------------------------------------------------------------------------------
-- Filter out Debuffs to always display regardless of whether they are sourced from the player - BY NAME
--------------------------------------------------------------------------------------------------------------------------------
Effects.DebuffDisplayOverrideName =
{
    [Abilities.Skill_Off_Balance] = true,
}

-- Add Major/Minor Id's to list to show always even if not sourced from the player
Effects.DebuffDisplayOverrideMajorMinor =
{
    [61742] = true,  -- Minor Breach
    [79717] = true,  -- Minor Vulnerability
    [61723] = true,  -- Minor Maim
    [61726] = true,  -- Minor Defile
    [88401] = true,  -- Minor Magickasteal
    [86304] = true,  -- Minor Lifesteal
    [79907] = true,  -- Minor Enervation
    [79895] = true,  -- Minor Uncertainty
    [79867] = true,  -- Minor Cowardice
    [61733] = true,  -- Minor Mangle
    [140699] = true, -- Minor Timidity
    [145975] = true, -- Minor Brittle
    [61743] = true,  -- Major Breach
    [106754] = true, -- Major Vulnerability
    [61725] = true,  -- Major Maim
    [61727] = true,  -- Major Defile
    [147643] = true, -- Major Cowardice
    -- [145977] = true, -- Major Brittle
}
