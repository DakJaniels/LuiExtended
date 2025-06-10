--- @param summonShade integer
--- @return integer
local function GetSummonShade(summonShade)
    summonShade = 38517
    local raceId = GetUnitRaceId("player")
    if raceId == 9 then
        summonShade = 88662 -- khajiit
    elseif raceId == 6 then
        summonShade = 88663 -- argonian
    end
    return summonShade
end

--- @type integer
local summonShade

--- @param shadowImage integer
--- @return integer
local function GetShadowImage(shadowImage)
    shadowImage = 38528
    local raceId = GetUnitRaceId("player")
    if raceId == 9 then
        shadowImage = 88696 -- khajiit
    elseif raceId == 6 then
        shadowImage = 88697 -- argonian
    end
    return shadowImage
end

--- @type integer
local shadowImage

--- @param darkShade integer
--- @return integer
local function GetDarkShade(darkShade)
    darkShade = 35438
    local raceId = GetUnitRaceId("player")
    if raceId == 9 then
        darkShade = 88677 -- khajiit
    elseif raceId == 6 then
        darkShade = 88678 -- argonian
    end
    return darkShade
end

--- @type integer
local darkShade

--- @class (partial) LUIE_ActionBar
local ActionBar = LUIE.ActionBar

--[[
	[slot_id] = config:
	- {effect_id, custom_duration} = timer will start when the effect will fire
	- true = start timer instantly using duration from the ability description
	- false = ignore this slot
	- number = same as "true", but use value as a duration
]]
ActionBar.abilityConfig =
{

    -- Two Handed
    [38814] = { 131562 }, -- dizzying swing (off-balance)
    [38807] = { 61745 },  -- wrecking blow (major berserk)
    [38788] = { 38791 },  -- stampede
    [38745] = { 38747 },  -- carve bleed
    [28297] = {},         -- momentum
    [38794] = {},         -- forward momentum
    [83216] = { 83217 },  -- berserker strike
    [83229] = { 83230 },  -- onslaught
    [83238] = { 83239 },  -- berserker rage
    [217180] = { 38254 }, -- goading smash (Scribing?) (taunt)
    [219972] = { 38254 }, -- goading smash (scribing) (taunt)

    -- Shield
    [28306] = { 38254 },  -- puncture (taunt)
    [38250] = { 38254 },  -- pierce armor (taunt)
    [38256] = { 38254 },  -- ransack (taunt)
    [222966] = { 38254 }, -- goading throw (scribing) (taunt)
    [28304] = { 61723 },  -- low slash (minor maim)
    [38268] = { 61723 },  -- deep slash (minor maim)
    [38264] = { 61708 },  -- heroic slash (minor heroism)
    [28727] = {},         -- defensive posture
    [38312] = {},         -- defensive stance
    [38317] = {},         -- absorb missile
    [28719] = { 28720 },  -- shield charge (stun)
    [38401] = { 38404 },  -- shielded assault (shield)
    [38405] = { 38407 },  -- invasion (stun)
    [38452] = { 80625 },  -- power slam (resentment)

    -- Dual Wield
    [28607] = { 99806 },  -- flurry (maelstrom buff)
    [38857] = { 99806 },  -- rapid strikes (maelstrom buff)
    [38846] = { 99806 },  -- bloodthirst (maelstrom buff)
    [28379] = { 29293 },  -- twin slashes
    [38839] = { 38841 },  -- rending slashes
    [38845] = { 38848 },  -- blood craze
    [28591] = { 100474 }, -- whirlwind (asylum buff)
    [38891] = { 100474 }, -- whirling blades (asylum buff)
    [38861] = { 100474 }, -- steel tornado (asylum buff)
    [21157] = { 61665 },  -- hidden blade (major brutality)
    [38914] = { 61665 },  -- shrouded daggers (major brutality)
    [38910] = { 126667 }, -- flying blade first cast
    [126659] = false,     -- flying blade jump (ignore major brutality)
    [83600] = { 85156 },  -- lacerate
    [85187] = { 85192 },  -- rend
    [85179] = { 85182 },  -- thrive in chaos

    -- Bow
    [38687] = false,      -- focused aim (minor fracture)
    [38685] = false,      -- lethal arrow
    [28879] = { 113627 }, -- scatter shot (BRP bow)
    [38672] = { 113627 }, -- magnum shot (BRP bow)
    [38669] = { 113627 }, -- draining shot (BRP bow)
    [38705] = { 38707 },  -- bombard (immobilized)
    [38701] = { 38703 },  -- acid spray
    [28869] = { 44540 },  -- poison arrow
    [38645] = { 44545 },  -- venom arrow
    [38660] = { 44549 },  -- poison injection
    [83465] = { 55131 },  -- rapid fire (cc immunity)
    [85257] = { 55131 },  -- toxic barrage (cc immunity)
    [85451] = { 85458 },  -- ballista
    [216674] = { 38254 }, -- goading valult (scribing) (taunt)

    -- Destruction Staff
    [46340] = { 100306 }, -- force shock (vAS destro)
    [46348] = { 100306 }, -- crushing shock (vAS destro)
    [46356] = { 100306 }, -- force pulse (vAS destro)

    [29073] = { 62648 },  -- flame touch
    [29089] = { 62722 },  -- shock touch
    [29078] = { 62692 },  -- frost touch
    [38985] = { 140334 }, -- flame clench (master destro)
    [38993] = { 140334 }, -- shock clench (master destro)
    [38989] = { 38254 },  -- frost clench (taunt)
    [38944] = { 62682 },  -- flame reach
    [38978] = { 62745 },  -- shock reach
    [38970] = { 62712 },  -- frost reach
    [29173] = { 61743 },  -- Weakness to elements
    [28794] = { 115003 }, -- fire impulse (BRP destro)
    [28799] = { 115003 }, -- shock impulse (BRP destro)
    [28798] = { 115003 }, -- frost impulse (BRP destro)
    [39145] = { 115003 }, -- fire ring (BRP destro)
    [39147] = { 115003 }, -- shock ring (BRP destro)
    [39146] = { 115003 }, -- frost ring (BRP destro)
    [39162] = { 115003 }, -- flame pulsar (BRP destro)
    [39167] = { 115003 }, -- shock pulsar (BRP destro)
    [39163] = { 115003 }, -- frost pulsar (BRP destro)

    -- Restoration Staff
    [37243] = { 61693 }, -- blessing of protection (minor resolve)
    [40094] = { 61744 }, -- combat prayer (minor berserk)
    [40103] = { 61693 }, -- blessing of restoration (minor resolve)
    [31531] = { 86304 }, -- force siphon
    [40109] = { 86304 }, -- siphon spirit
    [40116] = { 86304 }, -- quick siphon

    -- Armor
    [29556] = { 61716 }, -- evasion
    [39195] = { 61716 }, -- shuffle
    [39192] = { 61716 }, -- elude
    [29552] = { 61694 }, -- unstoppable (major resolve)
    [39205] = { 61694 }, -- unstoppable brute (major resolve)
    [39197] = { 61694 }, -- immovable (major resolve)

    -- Werewolf
    [32632] = { 137156 }, -- punce (carnage bleed)
    [39105] = { 137184 }, -- brutal pounce (brutal carnage bleed)
    [39104] = { 137164 }, -- feral pounce (brutal carnage bleed)
    [58317] = { 61745 },  -- hircine's rage (major berserk)
    [58325] = { 61704 },  -- hircine's fortitude (minor fortitude)
    [32633] = { 137257 }, -- roar (off-balance)
    [39113] = { 45834 },  -- ferocious roar (off-balance); 137287 is heavy attack speed buff
    [39114] = { 61743 },  -- deafening roar major breach; 137312 is off-balance
    [58855] = { 58856 },  -- infectious claws
    [58864] = { 58865 },  -- claws of anguish
    [58879] = { 58880 },  -- claws of life
    [39075] = { 32455 },  -- pack leader
    [39076] = { 32455 },  -- werewolf berserker

    -- Vampire
    [32986] = { 106208 },  -- mist form
    [38963] = { 106209 },  -- elusive mist
    [38965] = { 49268 },   -- blood mist
    [132141] = { 172418 }, -- blood frenzy
    [134160] = { 134166 }, -- simmering frenzy
    [135841] = { 172648 }, -- sated fury
    [128709] = { 128712 }, -- Mesmerize
    [137861] = { 137865 }, -- Hypnosis
    [138097] = { 138098 }, -- Stupefy (Stun)

    -- Soul Magic
    [26768] = { 126890 }, -- soul trap
    [40328] = { 126895 }, -- soul splitting trap
    [40317] = { 126897 }, -- consuming trap

    -- Fighters Guild
    [40336] = { 38254 },  -- silver leash (taunt)
    [35750] = {},         -- trap beast dot
    [40372] = {},         -- lightweight beast trap dot
    [40382] = { 40385 },  -- barbed trap dot
    [40195] = { 61744 },  -- camouflaged hunter (minor berserk)
    [35713] = { 62305 },  -- dawnbreaker
    [40158] = { 62314 },  -- dawnbreaker of smiting
    [40161] = { 126312 }, -- flawless dawnbreaker

    -- Mages Guild
    [28567] = { 126370 }, -- entropy
    [40452] = { 126371 }, -- structured entropy
    [40457] = { 126374 }, -- degeneration
    [31632] = {},         -- fire rune
    [40470] = {},         -- volcanic rune
    [40465] = {},         -- {  40468 }; -- scalding rune (dot)
    [31642] = { 48131 },  -- equilibrium (healing debuff)
    [40445] = { 48136 },  -- spell symmetry (healing debuff)
    [40441] = { 61694 },  -- balance (major resolve)
    [16536] = { 63430 },  -- meteor
    [40489] = { 63456 },  -- ice comet
    [40493] = { 63473 },  -- shooting star

    -- Psijic Order
    [103488] = { 104050 }, -- time stop
    [104059] = { 104078 }, -- borrowed time
    [103483] = { 103879 }, -- imbue weapon
    [103571] = { 103879 }, -- elemental weapon
    [103623] = { 103879 }, -- crushing weapon
    [103503] = { 61746 },  -- accelerate (minor force)
    [103706] = { 61746 },  -- channeled acceleration
    [103710] = { 61746 },  -- race against time

    -- Undaunted
    [39475] = { 38254 }, -- inner fire (taunt)
    [42056] = { 38254 }, -- inner rage (taunt)
    [42060] = { 38254 }, -- inner beast (taunt)

    -- Alliance War
    -- Assault
    [61503] = { 61504 }, -- vigor
    [61505] = { 61506 }, -- echoing vigor
    -- [61507] = { 61693 }; -- resolving vigor
    [38566] = { 61736 }, -- rapid maneuver
    [40211] = { 61736 }, -- retreating maneuver
    [40215] = { 61736 }, -- charging maneuver
    [33376] = { 38549 }, -- caltrops
    [40242] = { 40251 }, -- razor caltrops
    [40255] = { 40265 }, -- anti-cavalry caltrops
    [38563] = { 38564 }, -- war horn
    [40220] = { 40221 }, -- sturdy war horn
    [40223] = { 40224 }, -- aggressive warhorn (30 sec); 61747: 10 sec major force

    -- Support
    [61511] = { 78338 }, -- guard  -- [80923] = { 61511 }; -- guard
    [61529] = { 81415 }, -- stalwart guard  -- [80983] = { 81420 }; -- stalwart guard gain
    [61536] = { 81415 }, -- mystic guard -- [80947] = { 61536 }; -- mystic guard

    [81420] = { 61529 }, -- guard slot id while link is acitve
    [61489] = { 61498 }, -- revealing flare
    [61519] = { 61522 }, -- lingering flare
    [61524] = { 61526 }, -- blinding flare

    -- Dragonknight
    [20805] = { 122658 }, -- show seething fury on the molten whip icon
    [20657] = { 44363 },  -- searing strike
    [20668] = { 44369 },  -- venomous claw
    [20660] = { 44373 },  -- burning embers
    [20917] = { 31102 },  -- fiery breath
    [20930] = { 31104 },  -- engulfing flames
    [20944] = { 31103 },  -- noxious breath
    [20492] = { 61736 },  -- fiery grip (major expedition)
    [20496] = { 61736 },  -- unrelenting grip (major expedition)
    [20499] = { 61737 },  -- empowering chains (empower)
    [20245] = { 20527 },  -- dark talons
    [20251] = { 61723 },  -- choking talons (minor maim)
    [20252] = { 31898 },  -- burning talons
    [29004] = { 61698 },  -- dragon blood (major fortitude)
    [32722] = { 61698 },  -- coagulating blood (major fortitude)
    [32744] = { 61549 },  -- green dragon blood (minor vitality)
    [31837] = { 31841 },  -- inhale
    [32785] = { 32788 },  -- draw essence
    [32792] = { 32796 },  -- deep breath
    [32715] = { 61814 },  -- ferocious leap
    [133027] = { 31816 }, -- track stone giant
    [32673] = { 61711 },  -- fragmented shield
    [29043] = { 61665 },  -- molten weapons
    [31874] = { 61665 },  -- igneous weapons
    [31888] = { 61665 },  -- molten armaments
    [29037] = {},         -- petrify
    [32678] = {},         -- shattering rocks
    [32685] = {},         -- fossilize

    -- Sorcerer
    [43714] = false,       -- crystal shard
    [46324] = { 46327 },   -- crystal fragment proc
    [114716] = { 46327 },  -- crystal fragment proc
    [46331] = {},          -- crystal weapon
    [24371] = { 24559 },   -- rune prison
    [24578] = { 24581 },   -- shattering prison
    [24584] = { 114903 },  -- Dark Exchange
    [24589] = { 114909 },  -- dark conversion
    [24595] = { 114908 },  -- dark deal
    [24842] = { 24844 },   -- daedric tomb (first mine) 24846; 24847
    [77182] = { 77187 },   -- volatile pulse
    [23316] = { 77187 },   -- summon volatile familiar
    [77140] = { 77354 },   -- twilight tormentor enrage
    [24636] = { 77354 },   -- summon twilight tormentor
    [108840] = { 108842 }, -- summon unstable familiar
    [23304] = { 108844 },  -- unstable pulse
    [24165] = { 203447 },  -- bound armaments
    [23634] = { 80459 },   -- Summon Storm Atronach
    [23492] = { 80463 },   -- greater storm atronarch
    [23495] = { 23668 },   -- Summon Charged Atronach
    [18718] = { 18746 },   -- mages' fury
    [19109] = { 19118 },   -- endless fury
    [19123] = { 19125 },   -- mages' wrath
    [23182] = { 157462 },  -- lightning splash
    [23205] = { 157537 },  -- lightning flood
    [23200] = { 157535 },  -- liquid lightning
    [23234] = { 51392 },   -- bolt escape fatigue
    [23236] = { 51392 },   -- streak fatigue
    [23277] = { 51392 },   -- ball of lightning fatigue

    -- Templar
    [26188] = { 95933 }, -- spear shards
    [26858] = { 95957 }, -- luminous shards
    [26869] = { 26880 }, -- blazing spear
    [22178] = { 22179 }, -- sun shield
    [22180] = { 49091 }, -- blazing shield
    [22182] = { 22183 }, -- radiant ward
    [22138] = { 62593 }, -- radial sweep
    [22139] = { 62607 }, -- crescent sweep
    [22144] = { 62599 }, -- empowering sweep
    [21726] = { 21728 }, -- sun fire
    [21732] = { 21734 }, -- reflective light
    [21729] = { 21731 }, -- vampire's bane
    [22057] = { 61737 }, -- solar flare (empower)
    [22110] = { 61737 }, -- dark flare (empower)
    [63029] = false,     -- radiant destruction
    [63044] = false,     -- radiant glory
    [63046] = false,     -- radiant oppression
    [21752] = { 21576 }, -- nova
    [21755] = { 22003 }, -- solar prison
    [21758] = { 22001 }, -- solar disturbance
    [22253] = { 35632 }, -- honor the dead
    [22314] = { 61735 }, -- hasty prayer (minor expedition)
    [26209] = { 61704 }, -- radiant aura minor endurance
    [26807] = { 61704 }, -- radiant aura minor endurance

    -- Warden
    [85995] = { 130129 }, -- dive (off-balance)
    [85999] = { 130140 }, -- cutting dive (bleed)
    [86003] = { 178330 }, -- screaming cliff racer (off-balance wd)
    [86009] = {},         -- scorch
    [86015] = {},         -- deep fissure
    [86019] = {},         -- subterranean assault
    [86023] = { 101703 }, -- swarm
    [86027] = { 101904 }, -- fetcher infection
    [86031] = { 101944 }, -- growing swarm
    [86037] = { 177288 }, -- falcon's swiftness
    [86041] = { 177289 }, -- deceptive predator
    [86045] = { 177290 }, -- bird of prey
    [85862] = { 61704 },  -- enchanted growth (minor endurance)
    [85564] = { 90266 },  -- nature's grasp healing
    [85858] = { 88726 },  -- nature's embrace healing
    [86122] = { 61694 },  -- frost cloak
    [86126] = { 61694 },  -- expansive frost cloak
    [86130] = { 61694 },  -- ice fortress
    [86148] = { 90833 },  -- arctic wind
    [86156] = { 90834 },  -- arctic blast
    [86152] = { 90835 },  -- polar wind
    [86135] = {},         -- crystallized shield
    [86139] = {},         -- crystallized slab
    [86143] = {},         -- shimmering shield
    [86175] = {},         -- frozen gate
    [86179] = {},         -- frozen device
    [86183] = {},         -- frozen retreat
    [86113] = { 132429 }, -- northern storm

    -- Nightblade
    [33386] = false,                           -- assassin's blade
    [34843] = false,                           -- killer's blade
    [34851] = false,                           -- impale
    [25484] = { 79717 },                       -- ambush (minor vulnerability)
    [18342] = { 79717 },                       -- teleport strike (minor vulnerability)
    [25493] = { 79717 },                       -- lotus fan (minor vulnerability)
    [33375] = { 61716 },                       -- blur (major evasion)
    [35414] = { 61716 },                       -- mirage (major evasion)
    [35419] = { 61716 },                       -- phantasmal escape (125314 = 2.5 sec snare immune)
    [61902] = {},                              -- grim focus (ingame timer is bugged)
    [61907] = { 61902 },                       --  false  ; -- grim focus proc
    [61919] = {},                              -- merciless resolve (ingame timer is bugged)
    [61930] = { 61919 },                       -- false  ; -- merciless resolve proc
    [61927] = {},                              -- relentless focus (ingame timer is bugged)
    [61932] = { 61927 },                       -- false  ; -- relentless focus proc
    [33398] = { 61389 },                       -- death stroke
    [36508] = { 61393 },                       -- incap (70 ult)
    [113105] = { 113107 },                     -- incap (120 ult)
    [36514] = { 61400 },                       -- soul harvest
    [25255] = { 25256 },                       -- veiled strike (off-balance)
    [25267] = { 34739 },                       -- concealed weapon
    [25260] = { 34733 },                       -- surprise attack (off-balance)
    [25375] = { 234617 },                      -- shadow cloak (born from shadow)
    [25380] = { 234617 },                      -- shadowy disguise (born from shadow)
    [25352] = { 147643 },                      -- aspect of terror
    [37470] = { 147643 },                      -- mass hysteria
    [37475] = {},                              -- manifestation of terror
    [33211] = { GetSummonShade(summonShade) }, -- summon shade
    [35434] = { GetDarkShade(darkShade) },     -- dark shade
    [35441] = { GetShadowImage(shadowImage) }, -- shadow image
    [35445] = false,                           -- shadow image proc
    [33291] = { 33292 },                       -- strife heal
    [34838] = { 34841 },                       -- funnel health heal
    [34835] = { 34836 },                       -- swallow soul heal
    [33308] = { 108925 },                      -- melevolent offering
    [34721] = { 108927 },                      -- shrewd offering
    [34727] = { 108932 },                      -- healthy offering
    [33326] = { 33333 },                       -- cripple
    [36943] = { 36947 },                       -- debilitate
    [36957] = { 36960 },                       -- crippling grasp
    [36908] = { 215672 },                      -- leeching strikes
    [33316] = { 61665 },                       -- drain power
    [36901] = { 61665 },                       -- power extraction
    [36891] = { 61665 },                       -- sap essence
    [25091] = { 25093 },                       -- soul shred
    [35460] = { 35462 },                       -- soul tether

    -- Necromancer
    [117637] = { 117638 }, -- ricochet skull: base (0 stacks)
    [123718] = { 117638 }, -- 1 stack
    [123719] = { 117638 }, -- 2 stacks
    [117624] = { 117625 }, -- venom skull: base (0 stacks)
    [123699] = { 117625 }, -- 1 stack
    [123704] = { 117625 }, -- 2 stacks
    [114860] = { 114863 }, -- blastbones
    [117330] = { 114863 }, -- blastbones
    [117690] = { 117691 }, -- blighted blastbones
    [117693] = { 117691 }, -- blighted blastbones
    [117749] = {},         -- grave lord's sacrifice
    [115924] = { 116445 }, -- shocking siphon
    [118763] = { 118764 }, -- detonating siphon
    [118008] = { 118009 }, -- mystic siphon
    [122174] = { 106754 }, -- frozen colossus (major vuln)
    [122388] = { 106754 }, -- glacial colossus (major vuln)
    [122391] = { 106754 }, -- pestilent colossus (major vuln)
    [118223] = { 122625 }, -- hungry scythe (healing over time)
    [118226] = { 125750 }, -- ruinous scythe (off-balance)
    [115177] = { 61723 },  -- grave grasp (minor maim)
    [118308] = { 61723 },  -- ghostly embrace (minor maim)
    [118352] = { 61737 },  -- empowering grasp (empower)
    [114196] = { 61726 },  -- render flesh (minor defile)
    [117883] = { 117886 }, -- resistant flesh
    [117888] = false,      -- blood sacrifice
    [115307] = false,      -- expunge
    [117940] = false,      -- expunge and modify
    [117919] = false,      -- hexproof
    [115315] = { 115326 }, -- life amid death
    [118017] = { 118022 }, -- renewing undeath
    [118809] = { 118814 }, -- enduring undeath
    [115926] = { 116450 }, -- restoring tether
    [118070] = { 118071 }, -- braided teher
    [118122] = { 118123 }, -- mortal coil
    [115410] = false,      -- reanimate
    [118367] = false,      -- renewing animation
    [118379] = false,      -- animate blastbones

    -- Arcanist
    [185794] = { 184220 }, -- runeblades
    [188658] = { 184220 }, -- runeblades
    [185803] = { 184220 }, -- writhing runeblades
    [188787] = { 184220 }, -- writhing runeblades
    [182977] = { 184220 }, -- escalating runeblades
    [188780] = { 184220 }, -- escalating runeblades
    [185817] = { 185818 }, -- abyssal impact
    [183006] = { 183008 }, -- cephaliarch's flail
    [185823] = { 185825 }, -- tentacular dread
    [185836] = { 185838 }, -- the imperfect ring
    [185839] = { 185840 }, -- rune of displacement
    [182988] = { 182989 }, -- fulminating rune (Stam)
    [201296] = { 182989 }, -- fulminating rune (Mag)
    [189791] = { 189792 }, -- the unblinking eye
    [189837] = { 191367 }, -- the tide king's gaze
    [183165] = { 38254 },  -- runic jolt (taunt)
    [183430] = { 187742 }, -- runic sunder (armor steal)
    [186531] = { 38254 },  -- runic embrace (taunt)
    [183241] = { 184362 }, -- impervious runeward
    [185912] = { 194637 }, -- runic defense
    [183401] = { 194646 }, -- runeguard of still waters
    [186489] = { 61721 },  -- runeguard of freedom
    [185918] = { 79717 },  -- rune of eldritch horror
    [185921] = { 79717 },  -- rune of uncanny adoration
    [183267] = { 145975 }, -- rune of the colorless pool
    [183261] = { 184220 }, -- runemend
    [198282] = { 184220 }, -- runemend
    [186189] = { 184220 }, -- evolving runemend
    [198288] = { 184220 }, -- evolving runemend
    [186191] = { 184220 }, -- audacious runemend
    [198292] = { 184220 }, -- audacious runemend
    [183447] = { 184220 }, -- chakram shields
    [198563] = { 184220 }, -- chakram shields
    [186207] = { 184220 }, -- chakram of destiny
    [198564] = { 184220 }, -- chakram of destiny
    [186209] = { 184220 }, -- tidal chakram
    [198567] = { 184220 }, -- tidal chakram
    [183542] = { 195167 }, -- apocryphal gate
    [186211] = { 195190 }, -- fleet-footed gate
    [186220] = { 195204 }, -- passage between worlds
    [183709] = { 183712 }, -- vitalizing glyphic
    [193794] = { 193797 }, -- glyphic of the tides
    [193558] = { 193559 }, -- resonating glyphic
    [183648] = { 61694 },  -- fatewoven armor
    [185908] = { 61694 },  -- cruxweaver armor
    [186477] = { 61694 },  -- unbreakable fate
    [238256] = { 61694 },  -- vengeance fatewoven armor

    -- Volendrung
    [116095] = { 61665 }, -- Major Brutality

    -- Lucent Citadel
    [199287] = { 199288 }, -- Ghost Light Speed
    [199290] = { 218361 }, -- Ghost Light Shield
}

ActionBar.contingency =
{
    221185, -- Arcanist's Contingency
    217611, -- Binding Contingency
    221354, -- Binding Contingency
    221392, -- Contingency
    221155, -- Dragonknight's Contingency
    221156, -- Dragonknight's Contingency
    221157, -- Dragonknight's Contingency
    221158, -- Dragonknight's Contingency
    217655, -- Growing Contingency
    217613, -- Healing Contingency
    217621, -- Lingering Contingency
    217605, -- Magical Contingency
    221179, -- Necromancer's Contingency
    221180, -- Necromancer's Contingency
    221181, -- Necromancer's Contingency
    221182, -- Necromancer's Contingency
    221183, -- Necromancer's Contingency
    221184, -- Necromancer's Contingency
    221169, -- Nightblade's Contingency
    221170, -- Nightblade's Contingency
    221171, -- Nightblade's Contingency
    221172, -- Nightblade's Contingency
    217656, -- Opportunistic Contingency
    217652, -- Remedying Contingency
    217609, -- Repelling Contingency
    217610, -- Repelling Contingency
    221356, -- Repelling Contingency
    218340, -- Snaring Contingency
    221166, -- Sorcerer's Contingency
    221167, -- Sorcerer's Contingency
    221168, -- Sorcerer's Contingency
    221159, -- Templar's Contingency
    221160, -- Templar's Contingency
    221161, -- Templar's Contingency
    217654, -- Tenacious Contingency
    217528, -- Ulfsild's Contingency
    217604, -- Ulfsild's Contingency
    217616, -- Ulfsild's Contingency
    217618, -- Ulfsild's Contingency
    217653, -- Ulfsild's Contingency
    217657, -- Ulfsild's Contingency
    217659, -- Ulfsild's Contingency
    218341, -- Ulfsild's Contingency
    219662, -- Ulfsild's Contingency
    221189, -- Ulfsild's Contingency
    221352, -- Ulfsild's Contingency
    221353, -- Ulfsild's Contingency
    221355, -- Ulfsild's Contingency
    221734, -- Ulfsild's Contingency
    222285, -- Ulfsild's Contingency
    222364, -- Ulfsild's Contingency
    222678, -- Ulfsild's Contingency
    221173, -- Warden's Contingency
    221174, -- Warden's Contingency
    221175, -- Warden's Contingency
    221176, -- Warden's Contingency
    221177, -- Warden's Contingency
    217608, -- Warding Contingency
}

-- [stackId] = {stackId, abilityId_1, abilityId_2, ...}
ActionBar.stackMap =
{


    -- carve bleed
    [38747] =
    {
        38747, -- carve bleed
        38745, -- Carve (2H)
    },

    [38802] = { 38802 }, -- rally

    -- Spell Orb
    [103879] =
    {
        103879, -- spell orb
        103483, -- imbue weapon
        103571, -- elemental weapon
        103623, -- crushing weapon
        103503, -- accelerate
        103706, -- channeled acceleration
        103710, -- race against time
    },

    -- mist form fatigue
    [106208] =
    {
        106208, -- mist form fatigue
        32986,  -- mist form
    },

    -- elusive mist fatigue
    [106209] =
    {
        106209, -- elusive mist fatigue
        38963,  -- elusive mist
    },

    -- blood mist fatigue
    [49247] =
    {
        49247, -- blood mist fatigue
        38965, -- blood mist
    },

    -- blood frenzy stacks
    [172418] =
    {
        172418, -- blood frenzy stacks
        132141  -- blood frenzy
    },

    -- simmering frenzy stacks
    [134166] =
    {
        134166, -- simmering frenzy stacks
        134160, -- simmering frenzy
    },

    -- sated fury stacks
    [172648] =
    {
        172648, -- sated fury stacks
        135841, -- sated fury
    },

    -- force pulse (vAS destro)
    [100306] =
    {
        100306, -- force pulse (vAS destro)
        46340,  -- force shock
        46348,  -- crushing shock
        46356,  -- force pulse
    },

    -- chaotic whirlwind (vAS dw)
    [100474] =
    {
        100474, -- chaotic whirlwind (vAS dw)
        28591,  -- whirlwind
        38891,  -- whirling blades
        38861,  -- steel tornado
    },

    [122585] = { 61902 }, -- Grim Focus
    [122586] = { 61919 }, -- Merciless Resolve
    [122587] = { 61927 }, -- Relentless Focus

    -- Bound Armaments
    [203447] =
    {
        203447, -- Bound Armaments Stacks
        24165,  -- Bound Armaments
    },

    -- Streak Fatigue
    [51392] =
    {
        51392, -- Streak Fatigue
        23234, -- Bolt Escape
        23236, -- Streak
        23277, -- Ball of Lightning
    },

    [29032] = { 29032, 133037 }, -- Stone Fist (stacks on self)
    [31816] = { 31816, 133027 }, -- Stone Giant (stacks on self)

    -- Seething Fury
    [122658] =
    {
        122658, -- show seething fury on the molten whip icon
        20805,  -- molten whip
    },

    [117638] = { 117638, 117637, 123718, 123719 }, -- Ricochet Skull
    [117625] = { 117625, 117624, 123699, 123704 }, -- venom skull
    [125749] = { 125750 },                         -- ruinous scythe

    -- Crux
    [184220] =
    {
        184220, -- crux
        185794, -- runeblades
        188658, -- runeblades
        185803, -- writhing runeblades
        188787, -- writhing runeblades
        182977, -- escalating runeblades
        188780, -- escalating runeblades
        185805, -- fatecarver
        193331, -- fatecarver
        183122, -- exhausting fatecarver
        193397, -- exhausting fatecarver
        186366, -- pragmatic fatecarver
        193398, -- pragmatic fatecarver
        183261, -- runemend
        198282, -- runemend
        186189, -- evolving runemend
        198288, -- evolving runemend
        186191, -- audacious runemend
        198292, -- audacious runemend
        183537, -- remedy cascade
        198309, -- remedy cascade
        186193, -- cascading fortune
        198330, -- cascading fortune
        186200, -- curative surge
        198537, -- curative surge
        183447, -- chakram shields
        198563, -- chakram shields
        186207, -- chakram of destiny
        198564, -- chakram of destiny
        186209, -- tidal chakram
        198567, -- tidal chakram
        183241, -- impervious runeward
        184362, -- impervious runeward
        185901, -- spiteward
        238174, -- vengeance fatecarver
        238249, -- vengeance runespite ward
        238482, -- vengeance remedy cascade
    },

    -- Leeching Strikes
    [215672] =
    {
        215672, -- Leeching Strikes Cost Reduction
        36908,  -- Leeching Strikes
    },

    -- Healing Springs Mag Recovey
    [40062] =
    {
        40062, -- Healing Springs
        40060, -- Healing Springs
        99781, -- Grand Rejuviantion
    },

    -- Echoing Vigor
    [61506] =
    {
        61506, -- Echoing Vigor
        -- 61503, -- Echoing Vigor
        -- 61504, -- Echoing Vigor
        -- 61505, -- Echoing Vigor
    },

    -- Ulfsild's Contingency
    [217528] = ActionBar.contingency,
    [222285] = ActionBar.contingency,
    [222678] = ActionBar.contingency,

    [63430] = { 63430, 16536 }, -- meteor
    [63456] = { 63456, 40489 }, -- ice comet
    [63473] = { 63473, 40493 }, -- shooting star

    -- [222370] = { 222370 } -- Anchorite's Potency, to show Soul Gems

    [134336] =
    {
        134336,
    },

    -- Fetcher Infection
    [91416] =
    {
        86027,
        101904,
    },

    -- Brutal Pounce (Carnage Bleed)
    [137189] =
    {
        137189,
        137184,
        39105
    },
}
