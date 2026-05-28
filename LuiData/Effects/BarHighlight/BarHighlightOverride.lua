-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

local contingency = { newId = 222285, showFakeAura = true, noRemove = true, duration = 22000 }
--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

--- @class BarHighlightOverrideOptions
--- @field newId integer | nil The ability ID to track instead of the original
--- @field showFakeAura boolean | nil Whether to display a fake aura using EVENT_COMBAT_EVENT
--- @field noRemove boolean | nil Whether to keep the effect active on fading or target change
--- @field duration integer | nil Override duration for the effect (in milliseconds)
--- @field hide boolean | nil Whether to hide this bar highlight entirely
--- @field combatTrack boolean|nil Register EVENT_COMBAT_EVENT for newId without g_barFakeAura (keeps EVENT_EFFECT_CHANGED for fade)

--- @type table<integer, BarHighlightOverrideOptions>
local barHighlightOverride =
{
    -- Optional
    -- newId = # -- Replace ID
    -- showFakeAura = true -- USE EVENT_COMBAT_EVENT instead - allows auras to display even if they weren't applied. Should be used with major/minor effects.
    -- noRemove = true -- don't remove effect on fading or target change -- Doesn't apply to hostile effects. Should be used with major/minor effects.
    -- duration = # -- override duration
    -- hide = true -- Hide this bar highlight

    ---------------------------
    -- Dragonknight -----------
    ---------------------------

    -- Ardent Flame
    [23806] = { newId = 23808 },  -- Lava Whip --> Off Balance
    [20805] = { newId = 122658 }, -- Molten Whip --> Seething Fury
    -- Flame Lash / Power Lash (U49+): stacks use abilityId 34117 in EVENT_COMBAT_EVENT (EFFECT_GAINED hitValue=stacks, EFFECT_GAINED_DURATION hitValue=ms).
    -- combatTrack registers combat listener without g_barFakeAura so player buff fade still clears via EVENT_EFFECT_CHANGED.
    [20816] = { newId = 34117, combatTrack = true, duration = 20000 },
    [20824] = { newId = 34117 },
    [23105] = { newId = 34117, combatTrack = true, duration = 20000 },
    [20657] = { newId = 44363 },                        -- Searing Strike
    [20668] = { newId = 44369 },                        -- Searing Claw
    -- Hearthfire / Hearth and Home / Fire Keeper: bar timer tracks EffectGroundDisplay ground duration (not HOT / reticle buffs).
    -- Do not use showFakeAura here — combat-only timers lose g_toggledSlotsPlayer and clear on target change.
    [31837] = { newId = 32710 }, -- Core of Flame --> ground entity id
    [32785] = { newId = 32710 }, -- Heart of Flame --> ground entity id
    [32792] = { newId = 32710 }, -- Soul of Flame --> ground entity id
    [20660] = { newId = 44373 },                        -- Burning Embers
    [20917] = { newId = 31102 },                        -- Fiery Breath
    [20944] = { newId = 31103 },                        -- Noxious Breath
    [20930] = { newId = 31104 },                        -- Engulfing Flames
    [20499] = { newId = 61737 },                        -- Empowering Chains --> Empower
    [32963] = { newId = 32958 },                        -- Shifting Standard

    -- Draconic Power
    [20245] = { newId = 20527 },                        -- Dark Talons
    [20252] = { newId = 31898 },                        -- Burning Talons
    [20251] = { newId = 20528 },                        -- Choking Talons -- TODO: Possibly track Maim here as well
    [29004] = { showFakeAura = true, noRemove = true }, -- Dragon Blood
    [32744] = { showFakeAura = true, noRemove = true }, -- Green Dragon Blood
    [32722] = { showFakeAura = true, noRemove = true }, -- Coagulating Blood

    [21014] = { newId = 108798 },                       -- Protective Plate

    [29012] = { newId = 114590 },                       -- Dragon Leap --> Stun
    [32719] = { newId = 114600 },                       -- Take Flight --> Stun
    [32715] = { newId = 61814 },                        -- Ferocious Leap

    -- Earthen Heart
    [29032] = { newId = 134310 },                      -- Superheated Ward
    [31816] = { newId = 134340 },                      -- Magma Fist
    [31820] = { newId = 261754 },                      -- Volcanic Ward
    [29043] = { newId = 258658, showFakeAura = true }, -- Molten Weapons --> Major Sorcery
    [31874] = { newId = 258666, showFakeAura = true }, -- Igneous Weapons --> Major Sorcery
    [31888] = { newId = 258661, showFakeAura = true }, -- Molten Armaments

    ---------------------------
    -- Nightblade -------------
    ---------------------------

    -- Assassination
    [18342] = { newId = 79717 },                   -- Teleport Strike --> Minor Vulnerability
    [25493] = { newId = 35336 },                   -- Lotus Fan
    [25484] = { newId = 79717 },                   -- Ambush --> Minor Vulnerability
    [33375] = { newId = 61716 },                   -- Blur --> Major Evasion
    [35414] = { newId = 61716 },                   -- Mirage --> Major Evasion
    [35419] = { newId = 125314, noRemove = true }, -- Phantasmal Escape --> Major Evasion
    [61902] = { newId = 122585 },                  -- Grim Focus
    [61927] = { newId = 122587 },                  -- Relentless Focus
    [61919] = { newId = 122586 },                  -- Merciless Resolve
    [33398] = { newId = 61389 },                   -- Death Stroke --> Damage Taken Increased
    [36508] = { newId = 61393 },                   -- Incapacitating Strike --> Damage Taken Increased
    [36514] = { newId = 61400 },                   -- Soul Harvest --> Damage Taken Increased

    -- Shadow
    [25255] = { newId = 34733 },                                        -- Veiled Strike --> Off-Balance
    [25260] = { newId = 34733 },                                        -- Surprise Attack --> Off-Balance
    [25267] = { newId = 34736 },                                        -- Concealed Weapon
    [25375] = { newId = 229837, showFakeAura = true, noRemove = true }, -- Shadow Cloak
    [25380] = { newId = 234617 },                                       -- Shadowy Disguise
    -- [25352] = { }, -- Aspect of Terror -- TODO: Disabled because API won't return correct duration for Fear
    -- [37470] = { }, -- Mass Hysteria -- TODO: Disabled because API won't return correct duration for Fear
    [33211] = { showFakeAura = true, noRemove = true },                -- Summon Shade
    [35434] = { showFakeAura = true, noRemove = true },                -- Dark Shade --> Summon Shade
    [35441] = { showFakeAura = true, noRemove = true },                -- Shadow Image --> Shadow
    [35445] = { newId = 35441, showFakeAura = true, noRemove = true }, -- Shadow Image Teleport --> Shadow

    -- Siphoning
    [33291] = { newId = 33292 },                       -- Strife
    [34838] = { newId = 34841, noRemove = true },      -- Funnel Health
    [34835] = { newId = 34836 },                       -- Swallow Soul
    [33308] = { newId = 108925, noRemove = true },     -- Malevolent Offering
    [34721] = { newId = 108927, noRemove = true },     -- Shrewd Offering
    [34727] = { newId = 108932, noRemove = true },     -- Healthy Offering
    [33326] = { newId = 33333 },                       -- Cripple
    [36943] = { newId = 36947 },                       -- Debilitate
    [36957] = { newId = 36960 },                       -- Crippling Grasp
    [33316] = { newId = 33317, showFakeAura = true },  -- Drain Power --> Major Sorcery
    [36901] = { newId = 131344, showFakeAura = true }, -- Power Extraction --> Major Sorcery
    [36891] = { newId = 62240, showFakeAura = true },  -- Sap Essence --> Major Sorcery
    [25091] = { newId = 25093 },                       -- Soul Shred
    [35460] = { newId = 35462 },                       -- Soul Tether

    ---------------------------
    -- Sorcerer ---------------
    ---------------------------

    -- Dark Magic
    [24371] = { newId = 24559 },  -- rune prison
    [24578] = { newId = 24581 },  -- shattering prison
    [24584] = { newId = 114903 }, -- Dark Exchange
    [24589] = { newId = 114909 }, -- dark conversion
    [24595] = { newId = 114908 }, -- dark deal
    [24828] = { newId = 24830 },  -- Daedric Mines
    [24842] = { newId = 24844 },  -- daedric tomb (first mine) 24846; 24847
    [24834] = { newId = 25158 },  -- Daedric Minefield --> Daedric Mines

    -- Daedric Summoning
    [23492] = { newId = 80463 },                                         -- greater storm atronarch
    [23495] = { newId = 23668 },                                         -- Summon Charged Atronach
    [23634] = { newId = 80459 },                                         -- Summon Storm Atronach
    [24165] = { newId = 203447 },                                        -- bound armaments
    [77140] = { newId = 77354, showFakeAura = true, noRemove = true },   -- twilight tormentor enrage
    [77182] = { newId = 77187, showFakeAura = true, noRemove = true },   -- volatile pulse
    [108840] = { newId = 108842, showFakeAura = true, noRemove = true }, -- summon unstable familiar
    [23304] = { newId = 108844, showFakeAura = true, noRemove = true },  -- unstable pulse
    [24636] = { newId = 77354, showFakeAura = true, noRemove = true },   -- summon twilight tormentor
    [23316] = { newId = 77187, showFakeAura = true, noRemove = true },   -- summon volatile familiar

    -- Storm Calling
    [18718] = { newId = 18746 },  -- mages' fury
    [19109] = { newId = 19118 },  -- endless fury
    [19123] = { newId = 19125 },  -- mages' wrath
    [23182] = { newId = 157462 }, -- lightning splash
    [23205] = { newId = 157537 }, -- lightning flood
    [23200] = { newId = 157535 }, -- liquid lightning
    [23234] = { newId = 51392 },  -- bolt escape fatigue
    [23236] = { newId = 51392 },  -- streak fatigue
    [23277] = { newId = 51392 },  -- ball of lightning fatigue

    ---------------------------
    -- Templar ----------------
    ---------------------------

    -- Aedric Spear
    [26792] = { showFakeAura = true, noRemove = true, duration = 10000 }, -- Biting Jabs
    [26158] = { newId = 37409 },                                          -- Piercing Javelin
    [26800] = { newId = 37414 },                                          -- Aurora Javelin
    [26804] = { newId = 32099 },                                          -- Binding Javelin
    [22149] = { newId = 49205 },                                          -- Focused Charge
    [22161] = { newId = 49213 },                                          -- Explosive Charge
    [15540] = { newId = 15546 },                                          -- Toppling Charge
    [26188] = { newId = 95933 },                                          -- Spear Shards (Spear Shards)
    [26858] = { newId = 95957 },                                          -- Luminous Shards (Luminous Shards)
    [26869] = { newId = 26880 },                                          -- Blazing Spear (Blazing Spear)
    [22178] = { newId = 22179 },                                          -- Sun Shield
    [22182] = { newId = 22183 },                                          -- Radiant Ward
    [22180] = { newId = 49091 },                                          -- Blazing Shield
    [22138] = { newId = 62593 },                                          -- Radial Sweep
    [22144] = { newId = 62599 },                                          -- Empowering Sweep
    [22139] = { newId = 62607 },                                          -- Crescent Sweep

    -- Dawn's Wrath
    [21726] = { newId = 21728 }, -- Sun Fire
    [21729] = { newId = 21731 }, -- Vampire's Bane
    [21732] = { newId = 21734 }, -- Reflective Light (Reflective Light)
    [22057] = { newId = 61737 }, -- Solar Flare --> Empower
    [22110] = { newId = 61737 }, -- Dark Flare --> Empower
    [21752] = { newId = 21976 }, -- Nova (Nova)
    [21755] = { newId = 22003 }, -- Solar Prison (Solar Prison)
    [21758] = { newId = 22001 }, -- Solar Disturbance (Solar Disturbance)

    -- Restoring Light
    [22253] = { newId = 35632 },                        -- Honor the Dead
    [26209] = { newId = 88401 },                        -- Restoring Aura --> Minor Magickasteal
    [26807] = { newId = 88401 },                        -- Radiant Aura --> Minor Magickasteal
    [22265] = { showFakeAura = true, noRemove = true }, -- Cleansing Ritual (Cleansing Ritual)
    [22259] = { showFakeAura = true, noRemove = true }, -- Ritual of Retribution (Ritual of Retribution)
    [22262] = { showFakeAura = true, noRemove = true }, -- Extended Ritual (Extended Ritual)
    [22314] = { newId = 61735 },                        -- Hasty Prayer (Healing Ritual Morph)
    [22240] = { newId = 37009 },                        -- Channeled Focus
    [22237] = { newId = 114842 },                       -- Restoring Focus

    [22223] = { showFakeAura = true },                  -- Rite of Passage
    [22229] = { showFakeAura = true },                  -- Remembrance
    [22226] = { showFakeAura = true },                  -- Practiced Incantation

    ---------------------------
    -- Warden -----------------
    ---------------------------

    -- Animal Companions

    [85995] = { newId = 130129 },      -- Dive --> Off-Balance
    [85999] = { newId = 130139 },      -- Cutting Dive --> Off-Balance
    [86003] = { newId = 130145 },      -- Screaming Cliff Racer --> Off-Balance

    [86023] = { newId = 101703 },      -- Swarm
    [86027] = { newId = 101904 },      -- Fetcher Infection
    [86031] = { newId = 101944 },      -- Growing Swarm
    [86037] = { showFakeAura = true }, -- Falcon's Swiftness
    [86041] = { showFakeAura = true }, -- Deceptive Predator
    [86045] = { showFakeAura = true }, -- Bird of Prey

    -- Green Balance
    [85862] = { newId = 87019, showFakeAura = true }, -- Enchanted Growth --> Minor Endurance
    [85922] = { newId = 85840 },                      -- Budding Seeds
    [85564] = { newId = 90266 },                      -- Nature's Grasp
    [85858] = { newId = 87074 },                      -- Nature's Embrace

    -- Winter's Embrace
    [86122] = { newId = 86224, showFakeAura = true }, -- Frost Cloak --> Major Resolve
    [86126] = { newId = 88758, showFakeAura = true }, -- Expansive Frost Cloak --> Major Resolve
    [86130] = { newId = 88761, showFakeAura = true }, -- Ice Fortress --> Major Resolve
    [86148] = { newId = 90833 },                      -- Arctic Wind
    [86152] = { newId = 90835 },                      -- Polar Wind
    [86156] = { newId = 90834 },                      -- Arctic Blast --> Arctic Blast Stun

    [86135] = { showFakeAura = true },                -- Crystallized Shield --> Crystalized Shield
    [86139] = { showFakeAura = true },                -- Crystallized Slab --> Crystalized Slab
    [86143] = { showFakeAura = true },                -- Shimmering Shield --> Shimmering Shield

    -- Ultimate
    [219680] = { combatTrack = true, duration = 7000 }, -- Highland Sentinel (~7s active window)

    ---------------------------
    -- Necromancer ------------
    ---------------------------

    [114860] = { newId = 114863 },                                                         -- Blastbones
    [117330] = { newId = 114863 },                                                         -- Blastbones
    [117690] = { newId = 117691 },                                                         -- Blighted Blastbones
    [117693] = { newId = 117691 },                                                         -- Blighted Blastbones
    [117749] = { newId = 117750, showFakeAura = true, noRemove = true, duration = 20500 }, -- Grave Lord's Sacrifice
    [117773] = { newId = 117750 },                                                         -- Relentless Blastbones --> Stalking Blastbones

    [115924] = { newId = 116445 },                                                         -- Shocking Siphon
    [118763] = { newId = 118764 },                                                         -- Detonating Siphon
    [118008] = { newId = 118009 },                                                         -- Mystic Siphon

    [118226] = { newId = 125750 },                                                         -- Ruinous Scythe --> Off Balance
    [118223] = { newId = 122625 },                                                         -- Hungry Scythe

    [115238] = { newId = 115240 },                                                         -- Bitter Harvest
    [118623] = { newId = 124165 },                                                         -- Deaden Pain
    [118639] = { newId = 124193 },                                                         -- Necrotic Potency

    [115177] = { newId = 121513 },                                                         -- Grave Grasp
    [118308] = { newId = 118309 },                                                         -- Ghostly Embrace
    [118352] = { newId = 118354 },                                                         -- Empowering Grasp

    [114196] = { newId = 114206, showFakeAura = true },                                    -- Render Flesh --> Minor Defile
    [117883] = { newId = 117885, showFakeAura = true },                                    -- Resistant Flesh --> Minor Defile
    [117888] = { newId = 117890, showFakeAura = true },                                    -- Blood Sacrifice --> Minor Defile

    [115315] = { newId = 115326 },                                                         -- Life amid Death
    [118017] = { newId = 118022 },                                                         -- Renewing Undeath
    [118809] = { newId = 118814 },                                                         -- Enduring Undeath

    [115926] = { newId = 116450 },                                                         -- Restoring Tether
    [118070] = { newId = 118071 },                                                         -- Braided Tether
    [118122] = { newId = 118123 },                                                         -- Mortal Coil

    [118379] = { newId = 124999, showFakeAura = true },                                    -- Animate Blastbones

    ---------------------------
    -- Arcanist ---------------
    ---------------------------
    [193398] = { newId = 184220 },                                       -- Beam --> Crux
    [185817] = { newId = 185818 },                                       -- Abyssal Impact (abyssal ink)
    [183006] = { newId = 183008 },                                       -- Cephaliarch's Flail (abyssal ink)
    [185823] = { newId = 185825 },                                       -- Tentacular Dread (abyssal ink)
    [185836] = { newId = 185838 },                                       -- The Imperfect Ring (the imperfect ring)
    [201286] = { newId = 185838 },                                       -- The Imperfect Ring (cost mag)
    [185839] = { newId = 185840 },                                       -- Rune of Displacement (rune of displacement)
    [201293] = { newId = 185840 },                                       -- Rune of Displacement (cost stam)
    [182988] = { newId = 182989 },                                       -- Fulminating Rune (cost mag)
    [201296] = { newId = 182989 },                                       -- Fulminating Rune (cost stam)
    [183165] = { newId = 38254 },                                        -- Runic Jolt (taunt)
    [183430] = { newId = 187742 },                                       -- Runic Sunder (armor steal)
    [186531] = { newId = 38254 },                                        -- Runic Embrace (taunt)
    [185894] = { newId = 888101 },                                       -- Runespite Ward
    [185901] = { newId = 888101 },                                       -- Spiteward of the Lucid Mind
    [183241] = { newId = 888101 },                                       -- Impervious Runeward
    [185912] = { newId = 194637 },                                       -- Runic Defense (TODO: see if can make the timer go away)
    [183401] = { newId = 194646 },                                       -- Runeguard of Still Waters (TODO: see if can make the timer go away)
    [186489] = { newId = 186492 },                                       -- Runeguard of Freedom (TODO: see if can make the timer go away)
    [185918] = { newId = 79717 },                                        -- Rune of Eldritch Horror (minor vuln)
    [185921] = { newId = 79717 },                                        -- Rune of Uncanny Adoration (minor vuln)
    [183267] = { newId = 145975 },                                       -- Rune of the Colorless Pool (minor brittle)
    [186209] = { newId = 186210, showFakeAura = true, duration = 6000 }, -- Tidal Chakram (cost mag)
    [198567] = { newId = 186210, showFakeAura = true, duration = 6000 }, -- Tidal Chakram (cost stam)
    [186189] = { newId = 189565 },                                       -- Evolving Runemend
    [183447] = { showFakeAura = true, noRemove = true, newId = 183449 }, -- Chakram Shields
    [198564] = { newId = 194237, showFakeAura = true, duration = 6000 }, -- Chakram of Destiny (player shield)

    -- Gate morphs: bar timer tracks entry portal ground; noRemove = ignore FADE on teleport until countdown ends
    [186211] = { newId = 195190, showFakeAura = true, noRemove = true, duration = 7000 }, -- Fleet-Footed Gate (cast → entry portal ground)
    [197856] = { newId = 195190, showFakeAura = true, noRemove = true, duration = 7000 }, -- Fleet-Footed Gate (cost variant)

    [186220] = { newId = 195204, showFakeAura = true, noRemove = true, duration = 7000 }, -- Passage Between Worlds (cast → entry portal ground)
    [190394] = { newId = 195204, showFakeAura = true, noRemove = true, duration = 7000 }, -- Passage Between Worlds (cost variant)

    [183542] = { newId = 195167, showFakeAura = true, noRemove = true, duration = 7000 }, -- Apocryphal Gate (cast → entry portal ground)
    [178457] = { newId = 195167, showFakeAura = true, noRemove = true, duration = 7000 }, -- Apocryphal Gate (cost variant)

    -- Remedy Cascade (channeled): channel combat id reports [Chan] 4500 in combat log
    [183537] = { combatTrack = true, duration = 4500 },                 -- Remedy Cascade (cost mag)
    [198309] = { combatTrack = true, duration = 4500 },                 -- Remedy Cascade (cost stam)
    [178454] = { newId = 183537, combatTrack = true, duration = 4500 }, -- Remedy Cascade (cost variant → channel id)

    -- Curative Surge (channeled)
    [186200] = { combatTrack = true, duration = 4500 }, -- Curative Surge (cost mag)
    [198537] = { combatTrack = true, duration = 4500 }, -- Curative Surge (cost stam)

    -- Cascading Fortune (channeled)
    [186193] = { combatTrack = true, duration = 4500 }, -- Cascading Fortune (cost mag)
    [198330] = { combatTrack = true, duration = 4500 }, -- Cascading Fortune (cost stam)

    -- Fatecarver (channeled): slotted id maps to player channel combat id; combatTrack + duration for slot registration
    [185805] = { newId = 189533, combatTrack = true, duration = 4500 }, -- Fatecarver (magicka)
    [193331] = { combatTrack = true, duration = 4500 },                 -- Fatecarver (stamina)
    [183122] = { newId = 189533, combatTrack = true, duration = 4500 }, -- Exhausting Fatecarver (magicka)
    [193397] = { combatTrack = true, duration = 4500 },                 -- Exhausting Fatecarver (stamina)
    [186366] = { newId = 189533, combatTrack = true, duration = 4500 }, -- Pragmatic Fatecarver (magicka)
    [193398] = { combatTrack = true, duration = 4500 },                 -- Pragmatic Fatecarver (stamina)

    ---------------------------
    -- Two Handed -------------
    ---------------------------

    [38807] = { newId = 61737 },                        -- Wrecking Blow --> Empower
    [38814] = { newId = 131562 },                       -- Dizzying Swing --> Off Balance
    [38788] = { newId = 38791 },                        -- Stampede
    [38745] = { newId = 38747 },                        -- Carve
    [38754] = { newId = 38763 },                        -- Brawler

    [28448] = { newId = 99789 },                        -- Critical Charge --> Merciless Charge
    [38778] = { newId = 99789 },                        -- Critical Rush --> Merciless Charge

    [28297] = { showFakeAura = true, noRemove = true }, -- Momentum --> Major Brutality
    [38794] = { newId = 38797 },                        -- Forward Momentum
    [83216] = { newId = 83217 },                        -- Berserker Strike
    [83229] = { newId = 83230 },                        -- Onslaught
    [83238] = { newId = 83239 },                        -- Berserker Rage

    ---------------------------
    -- One Hand and Shield ----
    ---------------------------

    [28306] = { newId = 38254 }, -- Puncture --> Major Breach
    [38256] = { newId = 38254 }, -- Ransack --> Major Breach
    [38250] = { newId = 38254 }, -- Pierce Armor --> Major Breach
    [28304] = { newId = 61723 }, -- Low Slash --> Minor Maim
    [38268] = { newId = 61723 }, -- Deep Slash --> Minor Maim
    [38264] = { newId = 61723 }, -- Heroic Slash --> Minor Maim
    [28719] = { newId = 28720 }, -- Shield Charge
    [38401] = { newId = 38404 }, -- Shielded Assault
    [38405] = { newId = 38407 }, -- Invasion
    [38455] = { newId = 83446 }, -- Reverberating Bash
    [38452] = { newId = 80625 }, -- Power Slam --> Resentment

    ---------------------------
    -- Dual Wield -------------
    ---------------------------

    [28607] = { newId = 99806 },   -- Flurry --> Cruel Flurry
    [38857] = { newId = 99806 },   -- Rapid Strikes --> Cruel Flurry
    [38846] = { newId = 99806 },   -- Bloodthirst --> Cruel Flurry

    [28379] = { newId = 29293 },   -- Twin Slashes --> Twin Slashes Bleed
    [38839] = { newId = 38841 },   -- Rending Slashes --> Rending Slashes Bleed
    -- [38845] = { newId = 38852 },   -- Blood Craze
    [38845] = { newId = 38848 },   -- Blood Craze

    [28591] = { newId = 100474 },  -- Whirlwind --> Chaotic Whirlwind
    [38891] = { newId = 100474 },  -- Whirling Blades --> Chaotic Whirlwind
    [38861] = { newId = 100474 },  -- Steel Tornado --> Chaotic Whirlwind

    [21157] = { newId = 61665 },   -- Hidden Blade --> Major Brutality
    [38914] = { newId = 61665 },   -- Shrouded Daggers --> Major Brutality
    [38910] = { newId = 126667 },  -- Flying Blade
    [126659] = { newId = 126667 }, -- Flying Blade

    [83600] = { newId = 85156 },   -- Lacerate
    [85187] = { newId = 85192 },   -- Rend
    [85179] = { newId = 85184 },   -- Thrive in Chaos

    ---------------------------
    -- Bow --------------------
    ---------------------------

    [38685] = { newId = 61726 },  -- Lethal Arrow --> Minor Defile
    [38687] = { newId = 61742 },  -- Focused Aim --> Minor Breach

    [28879] = { newId = 113627 }, -- Scatter Shot --> Virulent Shot
    [38672] = { newId = 113627 }, -- Magnum Shot --> Virulent Shot
    [38669] = { newId = 113627 }, -- Draining Shot --> Virulent Shot

    [31271] = { newId = 100302 }, -- Arrow Spray --> Piercing Spray
    [38705] = { newId = 100302 }, -- Bombard --> Piercing Spray
    [38701] = { newId = 100302 }, -- Acid Spray --> Piercing Spray

    [28869] = { newId = 44540 },  -- Poison Arrow
    [38645] = { newId = 44545 },  -- Venom Arrow
    [38660] = { newId = 44549 },  -- Poison Injection
    -- [83465] = { newId = 55131, showFakeAura = true, duration = 4000 }, -- Rapid Fire --> CC Immunity
    [85257] = { newId = 85261 },  -- Toxic Barrage
    [85451] = { newId = 85458 },  -- Ballista

    ---------------------------
    -- Destruction Staff ------
    ---------------------------

    [46340] = { newId = 100306 }, -- Force Shock --> Concentrated Force (*VAS Destro*)
    [46348] = { newId = 100306 }, -- Crushing Shock --> Concentrated Force (*VAS Destro*)
    [46356] = { newId = 100306 }, -- Force Pulse --> Concentrated Force (*VAS Destro*)
    -- [28807] = { newId = 28807 }, -- Wall of Fire
    -- [28854] = { newId = 28854 }, -- Wall of Storms
    -- [28849] = { newId = 28849 }, -- Wall of Frost
    -- [39053] = { newId = 39053 }, -- Unstable Wall of Fire
    -- [39073] = { newId = 39073 }, -- Unstable Wall of Storms
    -- [39067] = { newId = 39067 }, -- Unstable Wall of Frost
    -- [39012] = { newId = 39012 }, -- Blockade of Fire
    -- [39018] = { newId = 39018 }, -- Blockade of Storms
    -- [39028] = { newId = 39028 }, -- Blockade of Frost
    [29073] = { newId = 62648 },  -- Flame Touch
    [29089] = { newId = 62722 },  -- Shock Touch
    [29078] = { newId = 62692 },  -- Frost Touch
    [38985] = { newId = 140334 }, -- Flame Clench --> Destructive Impact (*Master Destro*)
    [38993] = { newId = 140334 }, -- Shock Clench --> Destructive Impact (*Master Destro*)
    [38989] = { newId = 38254 },  -- Frost Clench --> Taunt
    [38944] = { newId = 62682 },  -- Flame Reach
    [38978] = { newId = 62745 },  -- Shock Reach
    [38970] = { newId = 62712 },  -- Frost Reach
    [29173] = { newId = 61743 },  -- Weakness to Elements --> Major Breach
    [39089] = { newId = 39089 },  -- Elemental Susceptibility
    [39095] = { newId = 61743 },  -- Elemental Drain --> Major Breach
    [28794] = { newId = 115003 }, -- Fire Impulse --> Wild Impulse (*BRP Destro*)
    [28799] = { newId = 115003 }, -- Shock Impulse --> Wild Impulse (*BRP Destro*)
    [28798] = { newId = 115003 }, -- Frost Impulse --> Wild Impulse (*BRP Destro*)
    [39145] = { newId = 115003 }, -- Fire Ring --> Wild Impulse (*BRP Destro*)
    [39147] = { newId = 115003 }, -- Shock Ring --> Wild Impulse (*BRP Destro*)
    [39146] = { newId = 115003 }, -- Frost Ring --> Wild Impulse (*BRP Destro*)
    [39162] = { newId = 115003 }, -- Flame Pulsar --> Wild Impulse (*BRP Destro*)
    [39167] = { newId = 115003 }, -- Storm Pulsar --> Wild Impulse (*BRP Destro*)
    [39163] = { newId = 115003 }, -- Frost Pulsar --> Wild Impulse (*BRP Destro*)
    [83625] = { newId = 83625 },  -- Fire Storm
    [83630] = { newId = 83630 },  -- Thunder Storm
    [83628] = { newId = 83628 },  -- Icy Storm
    [83682] = { newId = 83682 },  -- Eye of Flame
    [83686] = { newId = 83686 },  -- Eye of Lightning
    [83684] = { newId = 83684 },  -- Eye of Frost
    [85126] = { newId = 85126 },  -- Fiery Rage
    [85130] = { newId = 85130 },  -- Thunderous Rage
    [85128] = { newId = 85128 },  -- Icy Rage

    ---------------------------
    -- Restoration Staff ------
    ---------------------------

    [37243] = { showFakeAura = true, noRemove = true }, -- Blessing of Protection (Blessing of Protection)
    [40103] = { showFakeAura = true, noRemove = true }, -- Blessing of Restoration (Blessing of Restoration)
    [40094] = { showFakeAura = true, noRemove = true }, -- Combat Prayer (Combat Prayer)
    [31531] = { newId = 86304 },                        -- Force Siphon (Force Siphon)
    [40109] = { newId = 86304 },                        -- Siphon Spirit (Siphon Spirit)
    [40116] = { newId = 86304 },                        -- Quick Siphon (Quick Siphon)

    ---------------------------
    -- Armor ------------------
    ---------------------------

    [29556] = { newId = 63015, showFakeAura = true },  -- Evasion --> Major Evasion
    [39195] = { newId = 39196, showFakeAura = true },  -- Shuffle --> Major Evasion
    [39192] = { newId = 126958, showFakeAura = true }, -- Elude --> Major Evasion
    [29552] = { newId = 126581, noRemove = true },     -- Unstoppable
    [39205] = { newId = 126582, noRemove = true },     -- Immovable Brute
    [39197] = { newId = 126583, noRemove = true },     -- Immovable

    ---------------------------
    -- Soul Magic -------------
    ---------------------------

    [26768] = { newId = 126890 }, -- Soul Trap (Soul Trap)
    [40328] = { newId = 126895 }, -- Soul Splitting Trap (Soul Splitting Trap)
    [40317] = { newId = 126897 }, -- Consuming Trap (Consuming Trap)

    -- [39270] = { newId = 55131, showFakeAura = true, duration = 5000 }, -- Soul Strike --> CC Immunity
    -- [40420] = { newId = 55131, showFakeAura = true, duration = 6000 }, -- Soul Assault --> CC Immunity
    -- [40414] = { newId = 55131, showFakeAura = true, duration = 5000 }, -- Shatter Soul --> CC Immunity

    ---------------------------
    -- Vampire ----------------
    ---------------------------

    [132141] = { newId = 172418 }, -- Blood Frenzy
    [134160] = { newId = 134166 }, -- Simmering Frenzy
    [135841] = { newId = 172648 }, -- Sated Fury

    [128709] = { newId = 128712 }, -- Mesmerize
    [137861] = { newId = 137865 }, -- Hypnosis
    [138097] = { newId = 138098 }, -- Stupefy

    ---------------------------
    -- Werewolf ---------------
    ---------------------------

    [32632] = { newId = 137156 },                      -- Pounce --> Carnage
    [39105] = { newId = 137189 },                      -- Brutal Pounce --> Brutal Carnage
    [39104] = { newId = 137164 },                      -- Feral Pounce --> Feral Carnage

    [58317] = { newId = 137206, showFakeAura = true }, -- Hircine's Rage --> Major Berserk
    [58325] = { newId = 61704 },                       -- hircine's fortitude (minor fortitude)
    [32633] = { newId = 137257 },                      -- roar (off-balance)
    [39113] = { newId = 45834 },                       -- ferocious roar (off-balance); 137287 is heavy attack speed buff
    [39114] = { newId = 61743 },                       -- deafening roar major breach; 137312 is off-balance
    [58855] = { newId = 58856 },                       -- Infectious Claws
    [58864] = { newId = 58865 },                       -- Claws of Anguish
    [58879] = { newId = 58880 },                       -- Claws of Life

    ---------------------------
    -- Fighters Guild ---------
    ---------------------------

    [40336] = { newId = 40340 },                        -- Silver Leash
    [40195] = { noRemove = true },                      -- Camouflaged Hunter

    [35750] = { showFakeAura = true, noRemove = true }, -- Trap Beast
    [40382] = { showFakeAura = true, noRemove = true }, -- Barbed Trap
    [40372] = { showFakeAura = true, noRemove = true }, -- Lightweight Beast Trap

    [35713] = { newId = 62305 },                        -- Dawnbreaker
    [40161] = { newId = 126312 },                       -- Flawless Dawnbreaker
    [40158] = { newId = 62314 },                        -- Dawnbreaker of Smiting

    ---------------------------
    -- Mages Guild ------------
    ---------------------------

    [28567] = { newId = 126370 },                     -- Entropy
    [40457] = { newId = 126374 },                     -- Degeneration --> Major Sorcery
    [40452] = { newId = 126371 },                     -- Structured Entropy --> Major Sorcery

    [31642] = { newId = 48131 },                      -- Equilibrium
    [40445] = { newId = 40449, showFakeAura = true }, -- Spell Symmetry (Spell Symmetry)
    [40441] = { newId = 48141, showFakeAura = true }, -- Balance
    [16536] = { newId = 63430 },                      -- Meteor
    [40489] = { newId = 63456 },                      -- Ice Comet
    [40493] = { newId = 63473 },                      -- Shooting Star

    ---------------------------
    -- Psijic Order -----------
    ---------------------------

    [103488] = { newId = 104050 },                      -- Time Stop
    [104059] = { newId = 104078 },                      -- Borrowed Time
    [103503] = { newId = 103521, showFakeAura = true }, -- Accelerate --> Minor Force
    [103706] = { newId = 103708, showFakeAura = true }, -- Channeled Acceleration --> Minor Force
    [103710] = { newId = 103712, showFakeAura = true }, -- Race Against Time
    [103543] = { hide = true },                         -- Mend Wounds
    [103747] = { hide = true },                         -- Mend Spirit
    [103755] = { hide = true },                         -- Symbiosis

    ---------------------------
    -- Undaunted --------------
    ---------------------------
    [39489] = { newId = 39489 }, -- blood altar
    [41967] = { newId = 41967 }, -- sanguine altar
    [41958] = { newId = 41958 }, -- overflowing altar
    [39425] = { newId = 39425 }, -- trapping webs
    [41990] = { newId = 41990 }, -- shadow silk
    [42012] = { newId = 42012 }, -- tangling webs
    [39475] = { newId = 38254 }, -- Inner Fire --> Taunt
    [42056] = { newId = 38254 }, -- Inner Rage --> Taunt
    [42060] = { newId = 42062 }, -- Inner Beast
    [39369] = { newId = 39369 }, -- bone shield
    [42138] = { newId = 42138 }, -- spiked bone shield
    [42176] = { newId = 42176 }, -- bone surge
    [39298] = { newId = 39298 }, -- necrotic orb
    [42028] = { newId = 42028 }, -- mystic orb
    [42038] = { newId = 42038 }, -- energy orb

    ---------------------------
    -- Assault ----------------
    ---------------------------

    [38566] = { newId = 61736 }, -- Rapid Maneuver --> Major Expedition
    [40211] = { newId = 61736 }, -- Retreating Maneuver --> Major Expedition
    [40215] = { newId = 61736 }, -- Charging Maneuver --> Major Expedition
    [61503] = { newId = 61504 }, -- Vigor
    [61505] = { newId = 61506 }, -- Echoing Vigor
    [61507] = { newId = 61509 }, -- Resolving Vigor
    [33376] = { newId = 38549 }, -- Caltrops
    [40255] = { newId = 40265 }, -- Anti-Cavalry Caltrops
    [40242] = { newId = 40251 }, -- Razor Caltrops --> Caltrops
    [38563] = { newId = 38564 }, -- War Horn
    [40223] = { newId = 40224 }, -- Aggressive Horn
    [40220] = { newId = 40221 }, -- Sturdy Horn

    ---------------------------
    -- Support ----------------
    ---------------------------

    [61489] = { newId = 61498 }, -- Revealing Flare
    [61519] = { newId = 61522 }, -- Lingering Flare
    [61524] = { newId = 61526 }, -- Blinding Flare

    ---------------------------
    -- Volendrung -------------
    ---------------------------

    [116093] = { newId = 116364 }, -- Rourken's Rebuke
    [116095] = { newId = 116366 }, -- Pariah's Resolve

    ---------------------------
    -- Contingency ------------
    ---------------------------

    [217528] = contingency, -- "Ulfsild's Contingency"
    [217604] = contingency, -- "Ulfsild's Contingency"
    [217605] = contingency, -- "Magical Contingency"
    [217608] = contingency, -- "Warding Contingency"
    [217609] = contingency, -- "Repelling Contingency"
    [217610] = contingency, -- "Repelling Contingency"
    [217611] = contingency, -- "Binding Contingency"
    [217613] = contingency, -- "Healing Contingency"
    [217616] = contingency, -- "Ulfsild's Contingency"
    [217618] = contingency, -- "Ulfsild's Contingency"
    [217621] = contingency, -- "Lingering Contingency"
    [217652] = contingency, -- "Remedying Contingency"
    [217653] = contingency, -- "Ulfsild's Contingency"
    [217654] = contingency, -- "Tenacious Contingency"
    [217655] = contingency, -- "Growing Contingency"
    [217656] = contingency, -- "Opportunistic Contingency"
    [217657] = contingency, -- "Ulfsild's Contingency"
    [217659] = contingency, -- "Ulfsild's Contingency"
    [218340] = contingency, -- "Snaring Contingency"
    [218341] = contingency, -- "Ulfsild's Contingency"
    [219662] = contingency, -- "Ulfsild's Contingency"
    [221155] = contingency, -- "Dragonknight's Contingency"
    [221156] = contingency, -- "Dragonknight's Contingency"
    [221157] = contingency, -- "Dragonknight's Contingency"
    [221158] = contingency, -- "Dragonknight's Contingency"
    [221159] = contingency, -- "Templar's Contingency"
    [221160] = contingency, -- "Templar's Contingency"
    [221161] = contingency, -- "Templar's Contingency"
    [221166] = contingency, -- "Sorcerer's Contingency"
    [221167] = contingency, -- "Sorcerer's Contingency"
    [221168] = contingency, -- "Sorcerer's Contingency"
    [221169] = contingency, -- "Nightblade's Contingency"
    [221170] = contingency, -- "Nightblade's Contingency"
    [221171] = contingency, -- "Nightblade's Contingency"
    [221172] = contingency, -- "Nightblade's Contingency"
    [221173] = contingency, -- "Warden's Contingency"
    [221174] = contingency, -- "Warden's Contingency"
    [221175] = contingency, -- "Warden's Contingency"
    [221176] = contingency, -- "Warden's Contingency"
    [221177] = contingency, -- "Warden's Contingency"
    [221179] = contingency, -- "Necromancer's Contingency"
    [221180] = contingency, -- "Necromancer's Contingency"
    [221181] = contingency, -- "Necromancer's Contingency"
    [221182] = contingency, -- "Necromancer's Contingency"
    [221183] = contingency, -- "Necromancer's Contingency"
    [221184] = contingency, -- "Necromancer's Contingency"
    [221185] = contingency, -- "Arcanist's Contingency"
    [221189] = contingency, -- "Ulfsild's Contingency"
    [221352] = contingency, -- "Ulfsild's Contingency"
    [221353] = contingency, -- "Ulfsild's Contingency"
    [221354] = contingency, -- "Binding Contingency"
    [221355] = contingency, -- "Ulfsild's Contingency"
    [221356] = contingency, -- "Repelling Contingency"
    [221392] = contingency, -- "Contingency"
    [221734] = contingency, -- "Ulfsild's Contingency"
    [222364] = contingency, -- "Ulfsild's Contingency"
    [222678] = contingency, -- "Ulfsild's Contingency"
    [229656] = contingency, -- "Bloody Contingency"
    [229657] = contingency, -- "Ulfsild's Contingency"
    [229658] = contingency, -- "Lingering Contingency"
    [229659] = contingency, -- "Ulfsild's Contingency"
    [240148] = contingency, -- "Ulfsild's Contingency"
    [240149] = contingency, -- "Healing Contingency"
    [240150] = contingency, -- "Ulfsild's Contingency"

    ---------------------------
    -- Temp -------------------
    ---------------------------
    [217699] = { newId = 227087 }, -- Dragonknight's Banner
}

Effects.BarHighlightOverride = barHighlightOverride
