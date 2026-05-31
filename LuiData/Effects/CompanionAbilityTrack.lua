-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- Companion UF ability track: slotted bound id -> effect/cooldown (not BarHighlightOverride).
-- Taxonomy + skillLineId from SkillDumper savedData.companion (per active companion + shared weapon/armor/guild).
-- Combat track ids from in-game logs where noted; new slotted ids default to {} until verified.
--------------------------------------------------------------------------------------------------------------------------------

--- @class CompanionAbilityTrackEntry
--- @field unitTag string|nil Unit tag for GetUnitBuffInfo (defaults to "companion" when omitted)
--- @field trackId integer|nil Primary buff/effect ability id on unitTag
--- @field groundTrackId integer|nil Ground effect id from combat (not on companion auras)
--- @field groundTrackIds integer[]|nil Additional ground segment ids (combat GAIN/FADE only)
--- @field maxStacks integer|nil Max stack count for stack label
--- @field alternateTrackId integer|nil Optional second track (e.g. target debuff)
--- @field alternateTrackIds integer[]|nil Additional ids on alternateUnitTag (e.g. taunt + synergy debuff)
--- @field alternateUnitTag string|nil Unit tag for alternateTrackId (e.g. "reticleover")
--- @field extraTrackIds integer[]|nil Additional companion buff ids (e.g. 213450 with Perigean)
--- @field builtInInterrupt boolean|nil Always show on UF row (not on assignable hotbar slots 3–7)

--- @class (partial) CompanionAbilityTrack
--- @field [integer] CompanionAbilityTrackEntry
local companionAbilityTrack =
{
    ---------------------------------------------------------------------------
    -- Built-in (not on assignable hotbar slots 3–7)
    ---------------------------------------------------------------------------

    -- Bash (157419): companion interrupt (fake UF slot); stun 157424 ~3s, Off Balance 45902 ~7s on reticleover
    [157419] =
    {
        builtInInterrupt = true,
        alternateUnitTag = "reticleover",
        alternateTrackIds = { 157424, 45902 },
    },

    ---------------------------------------------------------------------------
    -- Class — Bastian Hallix (Imperial); skillLineId 174–176 (SkillDumper with Bastian active)
    ---------------------------------------------------------------------------

    -- Ardent Warrior (174): ult + 3 actives on line index 1 in UI
    -- Unleashed Rage (157016): ~2s channel; cross fire ground segments 157023–157026 ~10s
    [157016] =
    {
        groundTrackId = 157023,
        groundTrackIds = { 157024, 157025, 157026 },
    },

    -- Crag Smash (155186): ~366ms cast nuke; no companion/player aura — CD from BEGIN
    [155186] = {},

    -- Fiery Flail (153687): Off Balance 154579 ~7s on reticleover
    [153687] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 154579,
    },

    -- Scorching Strike (154923): target DOT debuff 154924 ~8s on reticleover
    [154923] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 154924,
    },

    -- Draconic Armor (175)
    -- Drake's Blood (155268): self mitigation 155271 ~8s on companion after ~400ms cast
    [155268] =
    {
        unitTag = "companion",
        trackId = 155271,
    },

    -- Crushing Claws (153812): target root debuff 153813 ~4s on reticleover
    [153812] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 153813,
    },

    -- Blazing Grasp (153839): taunt 38254 ~15s on reticleover; pull stun bundle 153842 ~0.2s (shared: Tanlorin Draconic Armor)
    [153839] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 38254,
        alternateTrackIds = { 153842 },
    },

    -- Radiating Heart (176)
    -- Kindle (154925): ~266ms cast heal; fleeting GAIN on player/companion — CD from BEGIN (shared: Tanlorin)
    [154925] = {},

    -- Basalt Barrier (153851): group shield 153851 ~6s on player and companion
    [153851] =
    {
        unitTag = "companion",
        trackId = 153851,
        alternateUnitTag = "player",
        alternateTrackId = 153851,
    },

    -- Searing Weapons (155355): LA damage buff 155355 ~8s on player and companion
    [155355] =
    {
        unitTag = "companion",
        trackId = 155355,
        alternateUnitTag = "player",
        alternateTrackId = 155355,
    },

    ---------------------------------------------------------------------------
    -- Class — Mirri Elendis (Breton); skillLineId 177–179 (SkillDumper with Mirri active)
    ---------------------------------------------------------------------------

    -- Deadly Assassin (177)
    -- Impeccable Shot (157259): expose debuff 157259 ~3s on reticleover during channel (157260)
    [157259] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 157259,
    },

    -- Shadow Slash (156182): Off Balance 156183 ~7s on reticleover (~266ms cast)
    [156182] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 156183,
    },

    -- Warp Strike (153853): gap closer ~400ms; damage 153854 — CD from BEGIN
    [153853] = {},

    -- Slayer's Blade (153855): execute ~233ms; no target debuff in log — CD from BEGIN
    [153855] = {},

    -- Living Shade (178)
    -- Ghostly Evasion (157197): mitigation 157197 + 157198 ~8s on companion
    [157197] =
    {
        unitTag = "companion",
        trackId = 157197,
        extraTrackIds = { 157198 },
    },

    -- Masque of Torment (153856): fear debuff 153856 ~4s on reticleover (+ bundle 153857)
    [153856] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 153856,
        alternateTrackIds = { 153857 },
    },

    -- Twilight Mantle (157201): invisibility/heal bundle 157202 ~3s on companion (157203 CC)
    [157201] =
    {
        unitTag = "companion",
        trackId = 157202,
        extraTrackIds = { 157203 },
    },

    -- Soul Thief (179)
    -- Life Absorption (154790): ~200ms drain; heal burst 154794 — no lasting aura, CD from BEGIN
    [154790] = {},

    -- Blood Transfusion (157287): ally HOT 157287 ~8s on player
    [157287] =
    {
        unitTag = "player",
        trackId = 157287,
    },

    -- Life Siphon (157207): AOE drain; delayed heal 157208 — no lasting aura, CD from BEGIN
    [157207] = {},

    ---------------------------------------------------------------------------
    -- Class — Sharp-as-Night (Argonian); skillLineId 241–243 (SkillDumper with Sharp-as-Night active)
    ---------------------------------------------------------------------------

    -- Beasts of the Hunt (241)
    -- Gore (186488): wind-up 186488 ~1.8–2.4s on reticleover; toss damage 187903 ~0.5s; stun CC 188098 ~3s (187903 is not the stun timer)
    [186488] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 188098,
        alternateTrackIds = { 186488, 187903 },
    },

    -- Swoop (186056): gap closer; Off Balance 186482 ~7s on reticleover when leap connects
    [186056] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 186482,
    },

    -- Char (186486): shalk ground 187043 ~1s+ (187040 burst); burrow cast aura ~0.2s on companion
    [186486] =
    {
        groundTrackId = 187043,
        groundTrackIds = { 187040 },
    },

    -- Infest (186485): fetcherfly DOT 186526 ~8s + Minor Vulnerability 79717 on reticleover (186754); companion 196046
    [186485] =
    {
        unitTag = "companion",
        trackId = 196046,
        alternateUnitTag = "reticleover",
        alternateTrackId = 186526,
        alternateTrackIds = { 79717, 186754 },
    },

    -- Verdant Growth (243)
    -- Fungal Forage (186598): instant heal; combat 187039 ~0.5s on player at cast — CD from BEGIN
    [186598] = {},

    -- Perennial Bloom (186602): ground heal 187110 ~8s; companion stand-in 196047 (187111 heal ticks)
    [186602] =
    {
        groundTrackId = 187110,
        unitTag = "companion",
        trackId = 196047,
    },

    -- Petals of the Hunter (186601): LA heal proc buff 186601 ~8s on companion (187657 heal bundle)
    [186601] =
    {
        unitTag = "companion",
        trackId = 186601,
        extraTrackIds = { 187657 },
    },

    -- Winter's Bite (242)
    -- Sleetmail (186603): companion DR 201198 ~6s; player Major Resolve 61694 + combat bundle 187481
    [186603] =
    {
        unitTag = "companion",
        trackId = 201198,
        alternateUnitTag = "player",
        alternateTrackId = 61694,
    },

    -- Cold Snap (186604): frost ground 186604 ~8s; target root 187362 ~3s on reticleover (187165 DOT ticks)
    [186604] =
    {
        groundTrackId = 186604,
        alternateUnitTag = "reticleover",
        alternateTrackId = 187362,
    },

    -- Snow Squall (186605): self HOT 187125 ~8s on companion
    [186605] =
    {
        unitTag = "companion",
        trackId = 187125,
    },

    ---------------------------------------------------------------------------
    -- Class — Isobel Veloise (Breton); skillLineId 200–202 (SkillDumper with Isobel active)
    ---------------------------------------------------------------------------

    -- Blazing Might (200)
    -- Baneslayer (163763): ~3.8s channel 163763 on reticleover; finisher 163773; particle debuff 168864 ~10s
    [163763] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 168864,
        alternateTrackIds = { 163763, 163773 },
    },

    -- Penetrating Strikes (163458): ~1s channel on companion; ally LA boon 163496 ~8s on player (163491 channel hit)
    [163458] =
    {
        unitTag = "companion",
        trackId = 163458,
        alternateUnitTag = "player",
        alternateTrackId = 163496,
    },

    -- Sun Brand (163452): flame DOT 163455 ~8s on reticleover (163452 cast bundle)
    [163452] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 163455,
    },

    -- Divine Destruction (163564): 3s execute channel 163564 on reticleover while channeling
    [163564] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 163564,
    },

    -- Brilliant Shield (201)
    -- Solar Ward (163442): shield/DR 163583 ~6s on companion (163442 cast channel ~1s)
    [163442] =
    {
        unitTag = "companion",
        trackId = 163583,
    },

    -- Gallant Blitz (163590): charge; Off Balance 163593 ~7s on reticleover (163594 damage)
    [163590] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 163593,
    },

    -- Spear of Light (163725): channel on target; knockdown/stun 163726 ~4s on reticleover
    [163725] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 163726,
        alternateTrackIds = { 163725 },
    },

    -- Healing Grace (202)
    -- Blessed Sacrament (163614): ally HOT 163657 ~8s on player (163657 HOT ticks)
    [163614] =
    {
        alternateUnitTag = "player",
        alternateTrackId = 163657,
    },

    -- Holy Ground (163660): ground 163660 ~8s; companion stand-in 196043; enemy snare 163662 (163661 heal ticks)
    [163660] =
    {
        groundTrackId = 163660,
        unitTag = "companion",
        trackId = 196043,
        alternateUnitTag = "reticleover",
        alternateTrackId = 163662,
    },

    -- Beam of Reproach (163684): target heal zone 163684 ~8s on reticleover + Minor Mending 61710 (163689/169252 heals)
    [163684] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 163684,
        alternateTrackIds = { 61710 },
    },

    ---------------------------------------------------------------------------
    -- Class — Ember (Khajiit); skillLineId 196–198 (SkillDumper with Ember active)
    ---------------------------------------------------------------------------

    -- Lightning Caller (196)
    -- Raging Storm (164191): storm ground 164191 ~8–9s; target DOT 164235 (combat ticks)
    [164191] =
    {
        groundTrackId = 164191,
        alternateUnitTag = "reticleover",
        alternateTrackId = 164235,
    },

    -- Crystal Blast (164289): instant nuke ~0.8s cast; CD from BEGIN
    [164289] = {},

    -- Shocking Burst (166085): nexus ground 166085 ~8s; companion barricade 196045 (166087/166089 damage)
    [166085] =
    {
        groundTrackId = 166085,
        unitTag = "companion",
        trackId = 196045,
    },

    -- Thunderous Strike (164291): execute nuke; CD from BEGIN
    [164291] = {},

    -- Mischievous Caster (197)
    -- Entomb (165871): target root 165871 ~4s on reticleover; self HOT 169248 ~8s on companion; ice ground 165906–165908 ~2.5s
    [165871] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 165871,
        unitTag = "companion",
        trackId = 169248,
        groundTrackId = 165907,
        groundTrackIds = { 165906, 165908 },
    },

    -- Hurricane Visage (165860): lightning form 165860 ~8s on companion (165861 shock ticks on enemies)
    [165860] =
    {
        unitTag = "companion",
        trackId = 165860,
    },

    -- Trickster's Trap (165865): target stun 174718 ~3s on reticleover (165865 is cast id)
    [165865] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 174718,
    },

    -- Playful Schemer (198)
    -- Quick Fix (166018): instant heal ~0.6s cast; no persistent aura — CD from BEGIN
    [166018] = {},

    -- Shared Wards (166069): shield 166069 ~6s + HOT 169289 ~8s on player and companion
    [166069] =
    {
        unitTag = "companion",
        trackId = 169289,
        extraTrackIds = { 166069 },
        alternateUnitTag = "player",
        alternateTrackId = 169289,
        alternateTrackIds = { 166069 },
    },

    -- Second Wind (166068): CD refresh; only BEGIN in log — CD from BEGIN
    [166068] = {},

    ---------------------------------------------------------------------------
    -- Class — Tanlorin; skillLineId 264–266 (SkillDumper with Tanlorin active)
    -- Blazing Grasp (153839) + Kindle (154925): same slotted ids as Bastian DK lines above
    ---------------------------------------------------------------------------

    -- Draconic Armor (265)
    -- Extinguishing Breath (215042): exhale damage; self defensive aura 230733 ~2.5s on companion (combat 215043 heal)
    [215042] =
    {
        unitTag = "companion",
        trackId = 230733,
    },

    -- Igneous Armor (215048): group Major Resolve 61694 + shields ~6s; companion aura 215048 (+ damage shield 215052)
    [215048] =
    {
        unitTag = "companion",
        trackId = 215048,
        extraTrackIds = { 215052, 61694 },
    },

    -- Empathic Fighter (266)
    -- Ruinous Outburst (215215): ult wind-up 215229 ~0.5s on companion; target stun/knockback bundle 221505 ~2.5s (when not immune)
    [215215] =
    {
        unitTag = "companion",
        trackId = 215229,
        alternateUnitTag = "reticleover",
        alternateTrackIds = { 221505 },
    },

    -- Internal Conflict (214865): soul DOT 214866 ~6s on reticleover
    [214865] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 214866,
    },

    -- Explosive Fortitude (214948): retaliatory buff ~6s on companion (proc damage 214949/215608)
    [214948] =
    {
        unitTag = "companion",
        trackId = 214948,
    },

    -- Shattered Spirit (215001): soulfire DOT ~8s on reticleover (combat GAIN DUR); end burst 215036
    [215001] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 215001,
        alternateTrackIds = { 215036 },
    },

    -- Radiating Heart (264)
    -- Volcanic Arms (214703): group Major Brutality/Sorcery 61665/61687 ~8s on companion (combat 215504/215505)
    [214703] =
    {
        unitTag = "companion",
        trackId = 61665,
        extraTrackIds = { 61687, 215504, 215505 },
    },

    -- Haze of Cinders (214708): ash ground 215381 ~8s (215382 heal ticks; 215383 snare on enemies in ash)
    [214708] =
    {
        groundTrackId = 215381,
        groundTrackIds = { 215383 },
    },

    ---------------------------------------------------------------------------
    -- Class — Azandar al-Gazaar (Arcanist); skillLineId 246–248 (SkillDumper with Azandar active)
    ---------------------------------------------------------------------------

    -- Quill Knight (247)
    -- Scathing Rune (193130): taunt debuff 193132 ~15s + Minor Maim 61723 on reticleover (combat 196187)
    [193130] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 193132,
        alternateTrackIds = { 61723 },
    },

    -- Abor's Augmented Ward (191939): shield ~6s on companion; combat bundle 191943
    [191939] =
    {
        unitTag = "companion",
        trackId = 191939,
        extraTrackIds = { 191943 },
    },

    -- Fear of the Unknown (194266): fear 194267 ~4s on reticleover (combat 196367)
    [194266] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 194267,
        alternateTrackIds = { 196367 },
    },

    -- Revitalizing Researcher (248)
    -- Triptych Physic (192574): instant triple heal (192575/192576 ticks); no persistent aura — CD from BEGIN
    [192574] = {},

    -- Shields of Erudition (192937): group shield ~6s; companion aura 192941 (player ally 192939)
    [192937] =
    {
        unitTag = "companion",
        trackId = 192941,
    },

    -- Zone of Recuperation (193126): ground domain ~8s (193127 on units is dur 0 in aura scan)
    [193126] =
    {
        groundTrackId = 193126,
    },

    -- Scholar of Apocrypha (246)
    -- Vigorous Tentacular Eruption (195103): ~2s cast; gate stun 195176/195175 ~3s + Major Vulnerability 106754 ~4s on reticleover (combat 195242; hit 195169)
    [195103] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 106754,
        alternateTrackIds = { 195242, 195176, 195175 },
    },

    -- The Triune Word (191273): triple hit; combat bundles 191278/191279 — no persistent track (CD from BEGIN)
    [191273] = {},

    -- Tendrils of the Colorless Sea (191293): Minor Vulnerability 79717 ~6s on reticleover (combat 191299)
    [191293] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 79717,
        alternateTrackIds = { 191299 },
    },

    -- Fate Omen's Inspiration (191765): group Minor Berserk 61744 ~8s on companion (+ allies incl. player)
    [191765] =
    {
        unitTag = "companion",
        trackId = 61744,
    },

    ---------------------------------------------------------------------------
    -- Class — Zerith-var (Khajiit); skillLineId 260–262 (SkillDumper with Zerith-var active)
    ---------------------------------------------------------------------------

    -- Guardian's Commitment (skillLineId 262)
    -- Crescent Scythe (213164): stacks on companion 213176, max 3, 6s
    [213164] =
    {
        unitTag = "companion",
        trackId = 213176,
        maxStacks = 3,
    },

    -- Perigean Armor (213165): buff 213165 on companion; Major Resolve 213450 combat + aura 61694 (SpellCastBuffs display id)
    [213165] =
    {
        unitTag = "companion",
        trackId = 213165,
        extraTrackIds = { 213450, 61694 },
    },

    -- Dark Moon Totem (213166): self 232078 ~10.1s; ground 220229 ~10s; fear 213460 4s on reticleover
    [213166] =
    {
        unitTag = "companion",
        trackId = 232078,
        groundTrackId = 220229,
        alternateUnitTag = "reticleover",
        alternateTrackId = 213460,
    },

    -- Remedy of Atonement (skillLineId 261)
    -- Penance of Lorkhaj (213160): ~400ms cast heal on player; Minor Defile 61726 ~4s on companion (combat 213342)
    [213160] =
    {
        unitTag = "companion",
        trackId = 61726,
        extraTrackIds = { 213342 },
    },

    -- Azurah's Embrace (213162): ~400ms cast; player shield 213634 ~1s (213633 heal ticks on player + companion)
    [213162] =
    {
        unitTag = "player",
        trackId = 213634,
        extraTrackIds = { 213633 },
    },

    -- Atoning Spirit (222209): ~300ms cast; 8s HOT 222209 on player
    [222209] =
    {
        unitTag = "player",
        trackId = 222209,
    },

    -- Warrior's Banishment (skillLineId 260)
    -- Blade of the Crossing (213169): ~500ms wind-up; Crescent Slash 213678; Minor Magickasteal 88401 ~10s on reticleover (combat 214324)
    [213169] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 88401,
        alternateTrackIds = { 214324, 213678 },
    },

    -- Varmiina's Visage (213157): instant cast; no persistent track id in combat log (CD from BEGIN only)
    [213157] = {},

    -- Sepulchral Chill (213158): self 232079 ~10.1s; ground 213284 8s
    [213158] =
    {
        unitTag = "companion",
        trackId = 232079,
        groundTrackId = 213284,
    },

    -- Strands of the Lattice (216057): target siphon 221598 10s; corpse burst ground 216103 ~1s
    [216057] =
    {
        groundTrackId = 216103,
        alternateUnitTag = "reticleover",
        alternateTrackId = 221598,
    },

    ---------------------------------------------------------------------------
    -- Weapon — Two Handed (skillLineId 180)
    ---------------------------------------------------------------------------

    -- Staggering Swing (152433): stun/debuff 152445 ~2.5s on reticleover; combat bundle 152446
    [152433] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackIds = { 152445, 152446 },
    },

    -- Sunder (152512): base morph; DOT debuff id matches morphed line 154667 when slotted as morph
    [152512] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 154667,
    },

    -- Sunder morph (154667): cleave DOT ~8s on reticleover (same id as debuff in combat log)
    [154667] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 154667,
    },

    -- Sever (152624): execute cast; CD from BEGIN only in log
    [152624] = {},

    ---------------------------------------------------------------------------
    -- Weapon — One Hand and Shield (skillLineId 181)
    ---------------------------------------------------------------------------

    -- Provoke (152625): target debuff 157235 on reticleover, 15s
    [152625] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 157235,
    },

    -- Bashing Bulwark (155326): block 156219 on companion; target stun 155327 on reticleover (4s in combat log)
    [155326] =
    {
        unitTag = "companion",
        trackId = 156219,
        maxStacks = 3,
        alternateUnitTag = "reticleover",
        alternateTrackId = 155327,
    },

    -- On Guard (155328): self damage shield ~6s; no combat track id in log yet (CD from BEGIN)
    [155328] = {},

    ---------------------------------------------------------------------------
    -- Weapon — Dual Wield (skillLineId 182)
    ---------------------------------------------------------------------------

    -- Swift Assault (152629): channel ~600ms; no persistent aura in log (CD from BEGIN)
    [152629] = {},

    -- Spinning Steel (152693): instant cast ~366ms; no target debuff Gained in log (CD from BEGIN)
    [152693] = {},

    -- Razor Cape (152696): self buff ~8s on companion (same id as slotted); 152700 is ~1s hit proc (combat only, no Gained)
    [152696] =
    {
        unitTag = "companion",
        trackId = 152696,
    },

    ---------------------------------------------------------------------------
    -- Weapon — Bow (skillLineId 183)
    ---------------------------------------------------------------------------

    -- Piercing Arrow (152793): charged shot ~1s cast; CD from BEGIN (no target debuff in log)
    [152793] = {},

    -- Trick Shot (152701): root 154723 ~4s on reticleover
    [152701] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 154723,
    },

    -- Viper's Bite (152863): poison 152864 ~8s on reticleover (combat GAIN ~6s bundle)
    [152863] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 152864,
    },

    ---------------------------------------------------------------------------
    -- Weapon — Destruction Staff (skillLineId 184); morphs share base slots in UI
    ---------------------------------------------------------------------------

    -- Destructive Blast (157131): base; morphs 157133 flame / 157135 frost / 157136–157137 shock
    [157131] = {},

    -- Flame Blast (157133): stun 157132 ~2.5s on reticleover when applied; bundle 157134 ~2.5s (combat on hit, including IMMUNE)
    [157133] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackIds = { 157132, 157134 },
    },

    -- Frost Blast (157135): taunt debuff 159179 ~15s on reticleover
    [157135] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 159179,
    },

    -- Shock Blast (157136): splash DMG bundle; slotted cast id is usually 157137
    [157136] = {},

    -- Shock Blast (157137): primary target cast; secondary hit uses 157136 (CD from BEGIN, no debuff timer)
    [157137] = {},

    -- Elemental Barricade (157140): base; morphs 157145 fire / 157212 frost / 157224–157226 storm
    [157140] = {},

    -- Fire Barricade (157145): ground 157145 ~8s; companion 196039; extra ground segments 157141/157143/157144
    [157145] =
    {
        unitTag = "companion",
        trackId = 196039,
        groundTrackId = 157145,
        groundTrackIds = { 157141, 157143, 157144 },
    },

    -- Frost Barricade (157212): ground 157212 ~8s; companion 196041; extra ground segments 157210/157211/157213
    [157212] =
    {
        unitTag = "companion",
        trackId = 196041,
        groundTrackId = 157212,
        groundTrackIds = { 157210, 157211, 157213 },
    },

    -- Storm Barricade (157224): alternate bound id; same tracking as 157226
    [157224] =
    {
        unitTag = "companion",
        trackId = 196042,
        groundTrackId = 157226,
        groundTrackIds = { 157225, 157227, 157228, 157229 },
    },

    -- Storm Barricade (157226): ground 157226 ~8s (BEGIN in log); companion 196042; segments 157225/157227/157228
    [157226] =
    {
        unitTag = "companion",
        trackId = 196042,
        groundTrackId = 157226,
        groundTrackIds = { 157225, 157227, 157228, 157229 },
    },

    -- Arcane Nova (157230): base; morphs 157231 fire / 157232 frost / 157233 shock
    [157230] = {},

    -- Fire Nova (157231): Burning 18084 ~4s on reticleover (companion GAIN on nova hit)
    [157231] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackId = 18084,
    },

    -- Frost Nova (157232): Chill 95136 ~4s on reticleover; Minor Maim 61723/68368 ~4s (same hit)
    [157232] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackIds = { 95136, 61723, 68368 },
    },

    -- Shock Nova (157233): Concussion 95134 ~4s on reticleover; Minor Vulnerability 79717/68359 ~4s (same hit)
    [157233] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackIds = { 95134, 79717, 68359 },
    },

    ---------------------------------------------------------------------------
    -- Weapon — Restoration Staff (skillLineId 185)
    ---------------------------------------------------------------------------

    -- Rejuvenation (153066): companion HoT 154755 ~8s; player HoT 153066 ~8s (player id not on companion auras)
    [153066] =
    {
        unitTag = "companion",
        trackId = 154755,
    },

    -- Mending Incantation (153467): heal buff 153684 ~8s on player + companion
    [153467] =
    {
        unitTag = "companion",
        trackId = 153684,
    },

    -- Mystic Fortress (153685): damage shield ~6s on player (same id as slotted cast)
    [153685] =
    {
        unitTag = "player",
        trackId = 153685,
    },

    ---------------------------------------------------------------------------
    -- Armor — Light (skillLineId 186); passive Flow (157728) not tracked on UF
    ---------------------------------------------------------------------------

    -- Haste (156340): resets other CDs; no track id in log (CD from BEGIN)
    [156340] = {},

    ---------------------------------------------------------------------------
    -- Armor — Medium (skillLineId 187); passive Flexibility (157729) not tracked on UF
    ---------------------------------------------------------------------------

    -- Vanish (156596): invis/stealth 156597 ~6s on companion; bundle 156598
    [156596] =
    {
        unitTag = "companion",
        trackId = 156597,
        extraTrackIds = { 156598 },
    },

    ---------------------------------------------------------------------------
    -- Armor — Heavy (skillLineId 188); passive Firmness (157730) not tracked on UF
    ---------------------------------------------------------------------------

    -- Bulwark (156599): block/reflect ~5s; no combat track id in log yet (CD from BEGIN)
    [156599] = {},

    ---------------------------------------------------------------------------
    -- Guild — Fighters Guild (skillLineId 189)
    ---------------------------------------------------------------------------

    -- Sniping Silver (153686): channel; companion cast aura 154918 ~1s during aim
    [153686] =
    {
        unitTag = "companion",
        trackId = 154918,
    },

    -- Ritual of Salvation (154926): ground 154926 ~8s; companion marker 154927
    [154926] =
    {
        unitTag = "companion",
        trackId = 154927,
        groundTrackId = 154926,
    },

    -- Biting Trap (157747): ground 157747 ~8s; companion 157759 ~8.5s; root 157760 4s on reticleover
    [157747] =
    {
        unitTag = "companion",
        trackId = 157759,
        groundTrackId = 157747,
        alternateUnitTag = "reticleover",
        alternateTrackId = 157760,
    },

    ---------------------------------------------------------------------------
    -- Guild — Mages Guild (skillLineId 190)
    ---------------------------------------------------------------------------

    -- Starfall (155403): channeled strike on target; no companion/player aura in log (CD from BEGIN)
    [155403] = {},

    -- Reverse Entropy (155408): 8s HOT on player (same id as slotted)
    [155408] =
    {
        unitTag = "player",
        trackId = 155408,
    },

    -- Parallel (155411): instant self restore; no persistent track id (CD from BEGIN)
    [155411] = {},

    ---------------------------------------------------------------------------
    -- Guild — Undaunted (skillLineId 191)
    ---------------------------------------------------------------------------

    -- Crimson Font (155515): ground 155515 ~16s; companion fountain aura 196038 ~16s
    [155515] =
    {
        unitTag = "companion",
        trackId = 196038,
        groundTrackId = 155515,
    },

    -- Savage Instinct (157240): taunt 157242/157829 ~15s on reticleover; Savage Implosion synergy 157831 ~2s
    [157240] =
    {
        alternateUnitTag = "reticleover",
        alternateTrackIds = { 157242, 157829, 157831 },
    },

    -- Skeletal Aegis (155693): shield 155693 ~6s on companion; Bone Aegis 155714 ~6s on player (synergy)
    [155693] =
    {
        unitTag = "companion",
        trackId = 155693,
        alternateUnitTag = "player",
        alternateTrackId = 155714,
    },
}

--- @class (partial) CompanionAbilityTrack
Effects.CompanionAbilityTrack = companionAbilityTrack

--- Companion interrupt ability id (not assignable on bar slots 3–7); shown as extra UF icon.
Effects.CompanionBuiltInInterruptAbilityId = 157419
