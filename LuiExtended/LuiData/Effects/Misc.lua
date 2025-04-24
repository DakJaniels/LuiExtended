-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
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
    [13940] = true, -- The Warrior
    [13943] = true, -- The Mage
    [13974] = true, -- The Serpent
    [13975] = true, -- The Thief
    [13976] = true, -- The Lady
    [13977] = true, -- The Steed
    [13978] = true, -- The Lord
    [13979] = true, -- The Apprentice
    [13980] = true, -- The Ritual
    [13981] = true, -- The Lover
    [13982] = true, -- The Atronach
    [13984] = true, -- The Shadow
    [13985] = true, -- The Tower
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

-- Food & Drink Buffs
Effects.IsFoodBuff =
{
    -- Food Buff
    [61259] = true,  -- Health Food
    [61260] = true,  -- Magicka Food
    [61261] = true,  -- Stamina Food
    [61294] = true,  -- Magicka + Stamina Food
    [61255] = true,  -- Health + Stamina Food
    [61257] = true,  -- Health + Magicka Food
    [61218] = true,  -- Triple Food
    [72819] = true,  -- Orzorga's Tripe Trifle Pocket
    [72822] = true,  -- Orzorga's Blood Price Pie
    [72824] = true,  -- Orzorga's Smoked Bear Haunch
    [100502] = true, -- Deregulated Mushroom Stew
    [100498] = true, -- Clockwork Citrus Filet
    [107789] = true, -- Artaeum Takeaway Broth
    [107748] = true, -- Artaeum Pickled Fish Bowl
    [84681] = true,  -- Crisp and Crunchy Pumpkin Skewer
    [84709] = true,  -- Crunchy Spider Skewer
    [84725] = true,  -- Frosted Brains
    [84678] = true,  -- Sweet Sanguine Apples
    [86798] = true,  -- Alcaire Festival Sword-Pie
    [86749] = true,  -- Jagga-Drenched "Mud Ball"
    [86673] = true,  -- Lava Foot Soup-and-Saltrice
    [86787] = true,  -- Rajhin's Sugar Claws
    [89955] = true,  -- Candied Jester's Coins
    [89971] = true,  -- Jewels of Misrule
    [66551] = true,  -- Vendor Health Food
    [66568] = true,  -- Vendor Magicka Food
    [66576] = true,  -- Vendor Stamina Food
    [72961] = true,  -- Cyrodilic Field Bar
    [72956] = true,  -- Cyrodilic Field Tack
    [72959] = true,  -- Cyrodilic Field Treat
    [85484] = true,  -- Crown Crate Fortifying Meal
    [68411] = true,  -- Crown Fortifying Meal
    [92435] = true,  -- Crown Combat Mystic's Stew
    [92474] = true,  -- Crown Vigorous Ragout
    [127596] = true, -- Bewitched Sugar Skulls
    -- Drink Buff
    [61322] = true,  -- Health Drink
    [61325] = true,  -- Magicka Drink
    [61328] = true,  -- Stamina Drink
    [61345] = true,  -- Magicka + Stamina Drink
    [61340] = true,  -- Health + Stamina Drink
    [61335] = true,  -- Health + Magicka Drink
    [61350] = true,  -- Triple Drink
    [72816] = true,  -- Orzorga's Red Frothgar
    [100488] = true, -- Spring-Loaded Infusion
    [84700] = true,  -- Bowl of "Peeled Eyeballs"
    [84735] = true,  -- Double Bloody Mara
    [84720] = true,  -- Ghastly Eye Bowl
    [84704] = true,  -- Witchmother's Party Punch
    [84731] = true,  -- Witchmother's Potent Brew
    [86677] = true,  -- Bergama Warning Fire
    [86746] = true,  -- Betnikh Twice-Spiked Ale
    [86559] = true,  -- Hissmir Fish-Eye Rye
    [86791] = true,  -- Snow Bear Glow-Wine
    [89957] = true,  -- Dubious Camoran Throne
    [66586] = true,  -- Vendor Health Drink
    [66590] = true,  -- Vendor Magicka Drink
    [66594] = true,  -- Vendor Stamina Drink
    [72971] = true,  -- Cyrodilic Field Tonic
    [72965] = true,  -- Cyrodilic Field Brew
    [72968] = true,  -- Cyrodilic Field Tea
    [85497] = true,  -- Crown Crate Refreshing Drink
    [68416] = true,  -- Crown Refreshing Drink
    [92433] = true,  -- Crown Stout Magic Liqueur
    [92476] = true,  -- Crown Vigorous Tincture
    [127531] = true, -- Corrupting Bloody Mara
    [127572] = true, -- Pack Leader's Bone Broth
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

    [2727] = true,   -- Off-Balance
    [134599] = true, -- Off Balance Immunity
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
