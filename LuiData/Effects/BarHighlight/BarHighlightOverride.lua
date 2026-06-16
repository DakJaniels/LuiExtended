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
--- @field combatTrackRemainOnSlotted boolean|nil When newId is a channel tick id: only slotted-id combat (and effect) sets bar timer; tick combat keeps highlight without resetting remain
--- @field combatStackNoExpire boolean|nil Dur-0 stack charge buff: keep bar highlight while stacks remain even if remain timestamp expired (ActionBar OnUpdate)

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
    [23806] = { newId = 23808, combatTrack = true, duration = 20000 },  -- Lava Whip --> Lava Slam / Volcanic Whip stacks (5, 20s)
    [256798] = { newId = 23808, combatTrack = true, duration = 20000 }, -- Volcanic Whip on bar --> same stack buff id
    [20805] = { newId = 122658, combatTrack = true, duration = 10000 }, -- Molten Whip --> Seething Fury (~10s; 122658 GAIN refreshes)
    -- Flame Lash / Power Lash (U49+): 34117 stack buff (5 stacks, 20s); 20824 replaces slotted Flame Lash when stacks are up.
    [20816] = { newId = 34117, combatTrack = true, duration = 20000 },
    [20824] = { newId = 34117, combatTrack = true, duration = 20000 },
    [20657] = { newId = 44363 }, -- Searing Strike
    [20668] = { newId = 44369 }, -- Searing Claw
    -- Core of Flame / Soul of Flame / Heart of Flame: ~4s player buff on slotted id (31837 / 32792 / 32785); no BarHighlightOverride entry.
    [20660] = { newId = 44373 }, -- Burning Embers
    [20917] = { newId = 31102 }, -- Dragonfire Breath --> target DOT
    [20944] = { newId = 31103 }, -- Disintegrating Dragonfire --> target DOT
    -- Engulfing Dragonfire: slotted 20930 (BEGIN/GAIN DUR ~4750, EFFECT_CHANGED buff); track 32821 (tick GAIN/GAIN DUR 5000, FADE).
    [20930] = { newId = 32821, combatTrack = true, duration = 5000, combatTrackRemainOnSlotted = true },
    [20492] = { newId = 38254 },                                                                              -- Chains of Flame --> Taunt (target, 15s; log 38254)
    [20496] = { newId = 38254 },                                                                              -- Chains of Dominance --> Taunt (target, 15s; shared 38254 track id)
    [76502] = { newId = 147643, showFakeAura = true, noRemove = true, duration = 15000, combatTrack = true }, -- Major Cowardice combat (Dominance; display 147643)
    -- Chains of Devastation: player hit buffs (log; no 61737 Empower). Primary bar = longer Major Evasion 10s; Berserk 6s via combat row + extraId.
    [20499] = { newId = 61716, showFakeAura = true, noRemove = true, duration = 10000, combatTrack = true },  -- --> Major Evasion (61716 display; 76506 combat)
    [76506] = { newId = 61716, showFakeAura = true, noRemove = true, duration = 10000, combatTrack = true },  -- Major Evasion combat bundle
    [147421] = { newId = 61745, showFakeAura = true, noRemove = true, duration = 6000, combatTrack = true },  -- Major Berserk combat --> 61745 display
    [32963] = { newId = 32958 },                                                                              -- Shifting Standard

    -- Draconic Power
    [20245] = { newId = 20527 },                    -- Dark Talons
    [20252] = { newId = 31898 },                    -- Burning Talons
    [20251] = { newId = 20528 },                    -- Choking Talons -- TODO: Possibly track Maim here as well
    -- Dragon Blood: bar keys newId; timer from player buff (61698), not slotted combat (1500 ms GAIN DUR). showFakeAura would block buff refresh on recast.
    [29004] = { newId = 61698, noRemove = true },   -- Dragon Blood --> Major Fortitude
    -- Green: 5s HoT buff (32744) on effect frame; HoT fade --> CheckOnFade --> remaining major time. noRemove keeps bar through HoT fade for swap.
    [32744] = { noRemove = true },                  -- Blood of the Green Dragon
    [32722] = { newId = 61698, noRemove = true },   -- Blood of the Elder Dragon --> Major Fortitude

    [21007] = { duration = 6000 },                  -- Wing Buffet (player buff)
    -- Fleetstep: slotted 21014 = 6000 ms; 108798 = 4000 ms expedition carrier (61736 display). CheckOnFade 108798 --> 21014.
    [21014] = { duration = 6000, noRemove = true }, -- Fleetstep Wings (slotted player buff on bar)
    [108798] = { noRemove = true },                 -- Fleetstep expedition carrier (~4s); fade --> CheckOnFade --> 21014 remainder
    -- 259744 combat Major Expedition (first Wing Buffet log); morph cast often omits -- use 108798/61736 above.
    [259744] = { newId = 61736, showFakeAura = true, noRemove = true, duration = 4000, combatTrack = true },
    [259761] = { newId = 61662, showFakeAura = true, noRemove = true, duration = 20000, combatTrack = true }, -- Minor Brutality when combat id fires
    -- Protect the Brood: slotted 21017 = 6000 ms; 61736 Major Expedition ~4s on player; 32753 combat -> 61721 Minor Protection 20s (13:29 log).
    [21017] = { duration = 6000, noRemove = true },                                                           -- Protect the Brood (slotted player buff on bar)
    [122407] = { noRemove = true },                                                                           -- Named brood buff in export; not in morph log -- CheckOnFade fallback
    [32753] = { newId = 61721, showFakeAura = true, noRemove = true, duration = 20000, combatTrack = true },  -- Minor Protection (combat)
    [260258] = { newId = 61736, showFakeAura = true, noRemove = true, duration = 4000, combatTrack = true },  -- Major Expedition (combat when present; morph log often 61736 only)

    -- Dragon Leap line (table 198758357): Landslide ground 29465/29466 (offset 32837063); stun 114590 / U49 262678 (offset 27087866).
    [29016] = { newId = 29465 },  -- Dragon Leap (slotted) --> Landslide (player ground, ~30s refresh)
    [29012] = { newId = 114590 }, -- Dragon Leap (cast combat) --> Stun
    -- Take Flight: do NOT use Landslide 29465 on bar (ActionBar maps slot to track id; Landslide Dur 0 / stack --> garbage labels e.g. -1472).
    [32719] = { newId = 262682 }, -- Take Flight (slotted) --> Stun (U49; combat log ~3000 ms)
    -- Ferocious Leap: bar tracks 10s shield (61814); Landslide 29465 via BarHighlightExtraId only (log).
    [32715] = { newId = 61814 },  -- Ferocious Leap (slotted) --> damage shield

    -- Earthen Heart — Superheated Ward / Volcanic Ward / Magma Fist (table 198758357; combat log)
    [29032] = { newId = 134310, duration = 6000 },                                                            -- Superheated Ward --> player buff 134310 (6s)
    [31820] = { newId = 261754, duration = 6000, noRemove = true },                                           -- Volcanic Ward --> primary player buff 261754 (6s; parallel 258203)
    [258203] = { hide = true },                                                                               -- Volcanic Ward secondary buff (same 6s; CheckOnFade ↔ 261754)
    [31816] = { newId = 134340 },                                                                             -- Magma Fist --> target Heat Shock 134340 (7s); self 258293 via ExtraId
    -- Molten Weapons line (table 198758357): slotted bar = player bundle; combat majors/empower via combatTrack + display ids.
    [29043] = { newId = 258658, showFakeAura = true, noRemove = true, duration = 30000 },                     -- Molten Weapons (player buff 258658, 30s)
    [31874] = { newId = 258666, showFakeAura = true, noRemove = true, duration = 60000 },                     -- Igneous Weapons (player buff 258666, 60s)
    [31888] = { newId = 258661, showFakeAura = true, noRemove = true, duration = 30000 },                     -- Molten Armaments (player buff 258661 + Empower, 30s)
    [92507] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },  -- Major Sorcery combat --> display
    [131340] = { newId = 61665, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true }, -- Major Brutality combat --> display
    [92503] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 60000, combatTrack = true },  -- Major Sorcery combat (Igneous, 60s)
    [76518] = { newId = 61665, showFakeAura = true, noRemove = true, duration = 60000, combatTrack = true },  -- Major Brutality combat (Igneous, 60s)
    [92512] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },  -- Major Sorcery combat (Molten Armaments)
    [131341] = { newId = 61665, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true }, -- Major Brutality combat (Molten Armaments)
    [76537] = { newId = 61737, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },  -- Empower combat (Molten Armaments only)

    -- Obsidian Shield line (table 198758357): slotted id = player buff 6s; combat Major Mending --> 61711 display.
    [29071] = { duration = 6000, noRemove = true },                                                          -- Obsidian Shield (player buff on bar, 6s)
    [29224] = { duration = 6000, noRemove = true },                                                          -- Igneous Shield (player buff on bar, 6s)
    [32673] = { duration = 6000, noRemove = true },                                                          -- Fragmented Shield (player buff on bar, 6s)
    [108675] = { newId = 61711, showFakeAura = true, noRemove = true, duration = 4000, combatTrack = true }, -- Major Mending combat (Obsidian Shield)
    [55033] = { newId = 61711, showFakeAura = true, noRemove = true, duration = 4000, combatTrack = true },  -- Major Mending combat (Igneous Shield)
    [108676] = { newId = 61711, showFakeAura = true, noRemove = true, duration = 6000, combatTrack = true }, -- Major Mending combat (Fragmented Shield, 6s)

    -- Earthspike Mantle line (table 198758357): slotted id = player buff 20s; Major Resolve combat --> 61694 (combatTrack, no showFakeAura on 61694).
    [20319] = { duration = 20000, noRemove = true },                                    -- Earthspike Mantle
    [20328] = { duration = 20000, noRemove = true },                                    -- Earthshield Mantle
    [31808] = { noRemove = true },                                                      -- Earthshield damage shield (6s); CheckOnFade --> 20328 mantle remainder
    [20323] = { duration = 20000, noRemove = true },                                    -- Shatterspike Mantle
    [61815] = { newId = 61694, noRemove = true, duration = 20000, combatTrack = true }, -- Major Resolve combat (Earthspike Mantle)
    [61827] = { newId = 61694, noRemove = true, duration = 20000, combatTrack = true }, -- Major Resolve combat (Earthshield Mantle)
    [61836] = { newId = 61694, noRemove = true, duration = 20000, combatTrack = true }, -- Major Resolve combat (Shatterspike Mantle)

    -- Petrify (table 198758357): slotted bar key 259090 (~8s stun). Breach: combat 259089 and/or display 61742 GAIN (10s); do not showFakeAura on 61742 (blocks real aura events).
    [29037] = { newId = 259090 },                                                         -- Petrify (slotted) --> target stun
    [259090] = { combatTrack = true, noRemove = true, duration = 8000 },                  -- Stun (target; combat / EFFECT_CHANGED on track id)
    [259089] = { newId = 259090, noRemove = true, duration = 10000, combatTrack = true }, -- Minor Breach combat (when present; same bar key as stun)

    -- Fossilize (table 198758357; mudcrab log): bar key 54931 (~8s stun). Breach/vuln combat 20s; display 61742/79717 share global ids (61742 ExtraId stays Petrify 259090).
    [32685] = { newId = 54931 },                                                         -- Fossilize (slotted) --> target stun
    [54931] = { combatTrack = true, noRemove = true, duration = 8000 },                  -- Stun (target)
    [259129] = { newId = 54931, noRemove = true, duration = 20000, combatTrack = true }, -- Minor Breach combat --> display 61742
    [259130] = { newId = 54931, noRemove = true, duration = 20000, combatTrack = true }, -- Minor Vulnerability combat --> display 79717

    -- Shattering Rocks (table 198758357; mudcrab log): bar key 259138 (~8s stun). Breach combat 259137 10s (no vuln/root).
    [32678] = { newId = 259138 },                                                         -- Shattering Rocks (slotted) --> target stun
    [259138] = { combatTrack = true, noRemove = true, duration = 8000 },                  -- Stun (target; log name Petrify)
    [259137] = { newId = 259138, noRemove = true, duration = 10000, combatTrack = true }, -- Minor Breach combat --> display 61742

    ---------------------------
    -- Nightblade -------------
    ---------------------------

    -- Assassination
    [18342] = { newId = 79717, noRemove = true, duration = 10000 },                   -- Teleport Strike --> Minor Vulnerability
    [124803] = { newId = 79717, noRemove = true, duration = 10000, combatTrack = true },
    [25493] = { newId = 35336, noRemove = true, duration = 5000 },                   -- Lotus Fan
    [124806] = { newId = 79717, noRemove = true, duration = 10000, combatTrack = true },
    [25484] = { newId = 79717, noRemove = true, duration = 10000 },                   -- Ambush --> Minor Vulnerability
    [124804] = { newId = 79717, noRemove = true, duration = 10000, combatTrack = true },
    [33357] = { newId = 33357, noRemove = true, duration = 20000 },                   -- Mark Target
    [33363] = { newId = 33357, noRemove = true, duration = 20000, combatTrack = true },
    [33372] = { newId = 33357, noRemove = true, duration = 20000, combatTrack = true },
    [36968] = { newId = 36968, noRemove = true, duration = 60000 },                   -- Piercing Mark
    [36980] = { newId = 36968, noRemove = true, duration = 60000, combatTrack = true },
    [36984] = { newId = 36968, noRemove = true, duration = 60000, combatTrack = true },
    [36967] = { newId = 36967, noRemove = true, duration = 20000 },                   -- Reaper's Mark
    [36972] = { newId = 36967, noRemove = true, duration = 20000, combatTrack = true },
    [36976] = { newId = 36967, noRemove = true, duration = 20000, combatTrack = true },
    [61902] = { newId = 122585 },                  -- Grim Focus
    [61927] = { newId = 122587 },                  -- Relentless Focus
    [61919] = { newId = 122586 },                  -- Merciless Resolve
    [33398] = { newId = 61389, noRemove = true, duration = 8000 },                   -- Death Stroke
    [36508] = { newId = 61393, noRemove = true, duration = 8000 },                   -- Incapacitating Strike
    [113107] = { newId = 61393, noRemove = true, duration = 12000, combatTrack = true }, -- Incap empowered debuff
    [36514] = { newId = 61400, noRemove = true, duration = 8000 },                   -- Soul Harvest

    -- Shadow
    [25255] = { newId = 34733 },                                        -- Veiled Strike --> Off-Balance
    [25260] = { newId = 34733 },                                        -- Surprise Attack --> Off-Balance
    [25267] = { newId = 34736 },                                        -- Concealed Weapon
    [33375] = { newId = 61716, noRemove = true, duration = 20000 },                   -- Blur --> Major Evasion
    [35414] = { newId = 61716, noRemove = true, duration = 20000 },                   -- Mirage --> Major Evasion
    [35419] = { newId = 125314, noRemove = true, duration = 20000 }, -- Phantasmal Escape --> Major Evasion
    [25375] = { newId = 229837, showFakeAura = true, noRemove = true, duration = 10000 }, -- Shadow Cloak
    [25377] = { showFakeAura = true, noRemove = true, duration = 3000 },                                       -- Dark Cloak
    [25380] = { newId = 234617, showFakeAura = true, noRemove = true, duration = 10000 },                                       -- Shadowy Disguise
    [33195] = { newId = 33197, duration = 11000 },                       -- Path of Darkness (ground track)
    [36049] = { newId = 36049, duration = 12000 },                       -- Twisting Path
    [36028] = { newId = 36028, duration = 12000 },                       -- Refreshing Path
    [25352] = { newId = 147643, noRemove = true, duration = 11000 },     -- Aspect of Terror --> Major Cowardice
    [177247] = { newId = 147643, noRemove = true, duration = 11000, combatTrack = true },
    [37470] = { newId = 147643, noRemove = true, duration = 12000 },     -- Mass Hysteria --> Major Cowardice
    [177249] = { newId = 147643, noRemove = true, duration = 12000, combatTrack = true },
    [37475] = { newId = 37475, duration = 24000 },                       -- Manifestation of Terror (ground)
    [177251] = { newId = 147643, noRemove = true, duration = 12000, combatTrack = true },
    -- Summon Shade (base — slotted 38517; bar track 33211)
    [38517] = { newId = 33211, showFakeAura = true, noRemove = true, duration = 22000 },
    [88662] = { newId = 33211, showFakeAura = true, noRemove = true, duration = 22000 },
    [88663] = { newId = 33211, showFakeAura = true, noRemove = true, duration = 22000 },
    [33211] = { showFakeAura = true, noRemove = true, duration = 22000 },
    [33290] = { newId = 33211, combatTrack = true, noRemove = true, duration = 22000 },
    -- Dark Shade morph (slotted 35438 — do not newId to 108940; API duration on track is ~1s)
    [35438] = { showFakeAura = true, noRemove = true, duration = 22000 },                -- Dark Shade (slotted)
    [88677] = { showFakeAura = true, noRemove = true, duration = 22000 },                -- Dark Shade -- Khajiit
    [88678] = { showFakeAura = true, noRemove = true, duration = 22000 },                -- Dark Shade -- Argonian
    [108940] = { newId = 35438, combatTrack = true, noRemove = true, duration = 22000 }, -- Dark Shade player buff
    [35434] = { newId = 35438, combatTrack = true, noRemove = true, duration = 22000 },  -- Dark Shade summon combat
    -- Shadow Image morph (slotted 35441 — do not newId to 35451; API duration on track is ~1s)
    [35441] = { showFakeAura = true, noRemove = true, duration = 22000 },                -- Shadow Image (slotted)
    [88696] = { showFakeAura = true, noRemove = true, duration = 22000 },                -- Shadow Image -- Khajiit
    [88697] = { showFakeAura = true, noRemove = true, duration = 22000 },                -- Shadow Image -- Argonian
    [38528] = { newId = 35441, combatTrack = true, noRemove = true, duration = 22000 },  -- Shadow Image player buff
    [35442] = { newId = 35441, combatTrack = true, noRemove = true, duration = 22000 },  -- Shadow Image summon combat
    [35451] = { newId = 35441, combatTrack = true, noRemove = true, duration = 22000 },  -- Shadow (shade track)
    [35445] = { newId = 35441, showFakeAura = true, noRemove = true },                   -- Shadow Image Teleport
    [25411] = { newId = 25411, duration = 14000 },                       -- Consuming Darkness (ground)
    [36493] = { newId = 36493, duration = 15000 },                       -- Bolstering Darkness (ground)
    [36485] = { newId = 36485, duration = 15000 },                       -- Veil of Blades (ground)

    -- Siphoning
    [33291] = { newId = 33292, duration = 10000, noRemove = true },                       -- Strife
    [34838] = { newId = 34841, duration = 10000, noRemove = true },      -- Funnel Health
    [34835] = { newId = 34836, duration = 10000, noRemove = true },                       -- Swallow Soul
    [33308] = { newId = 108925, noRemove = true, duration = 3000 },     -- Malevolent Offering
    [34721] = { newId = 108927, noRemove = true, duration = 2000 },     -- Shrewd Offering
    [34727] = { newId = 108932, noRemove = true, duration = 3000 },     -- Healthy Offering
    [108934] = { newId = 61710, combatTrack = true, noRemove = true, duration = 10000 }, -- Healthy Offering --> Minor Mending
    [36908] = { newId = 215672, combatTrack = true, combatStackNoExpire = true },        -- Leeching Strikes (stacks on effect 215672)
    [33326] = { newId = 33333, duration = 20000, noRemove = true },                       -- Cripple
    [36943] = { newId = 36947, duration = 20000, noRemove = true },                       -- Debilitate
    [36957] = { newId = 36960, duration = 18000, noRemove = true },                       -- Crippling Grasp
    [33316] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 30000 },  -- Drain Power --> Major Sorcery
    [33317] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },
    [131342] = { newId = 61665, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },
    [36901] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 30000 }, -- Power Extraction --> Major Sorcery
    [131344] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },
    [36903] = { newId = 61665, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },
    [175664] = { newId = 147417, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true }, -- Minor Courage (Power Extraction)
    [126675] = { newId = 79867, noRemove = true, duration = 10000, combatTrack = true }, -- Minor Cowardice (Power Extraction)
    [36891] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 30000 },  -- Sap Essence --> Major Sorcery
    [62240] = { newId = 61687, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },
    [131343] = { newId = 61665, showFakeAura = true, noRemove = true, duration = 30000, combatTrack = true },
    [25091] = { newId = 25093, duration = 4000, noRemove = true },                       -- Soul Shred
    [35508] = { newId = 61713, showFakeAura = true, noRemove = true, duration = 4000 }, -- Soul Siphon --> Major Vitality
    [63533] = { newId = 61713, showFakeAura = true, noRemove = true, duration = 4000, combatTrack = true },
    [35460] = { newId = 35462, duration = 7000, noRemove = true },                       -- Soul Tether

    ---------------------------
    -- Sorcerer ---------------
    ---------------------------

    -- Dark Magic
    [24371] = { newId = 24559 },                                    -- rune prison
    [24578] = { newId = 24581 },                                    -- rune cage
    [24584] = { newId = 114903 },                                   -- Dark Exchange
    [24589] = { newId = 114909 },                                   -- dark conversion
    [24595] = { newId = 114908 },                                   -- dark deal
    [24574] = { newId = 24574, duration = 120000 },                 -- defensive rune (player shield)
    [24828] = { newId = 24830, duration = 15000 },                  -- Daedric Mines (player placement)
    [24842] = { newId = 24847, duration = 16000 },                  -- daedric tomb (ground track 24847)
    [24834] = { newId = 25158, duration = 15000 },                  -- Daedric Minefield
    [27706] = { newId = 27706, duration = 12000 },                  -- negate magic (ground)
    [28341] = { newId = 28341, duration = 12000 },                  -- suppression field (ground)
    [28348] = { newId = 28348, duration = 12000 },                  -- absorption field (ground)
    [43714] = { newId = 143744, duration = 3000 },                  -- crystal shard (crystal weaver)
    [46324] = { newId = 46327, duration = 8000 },                   -- crystal fragments (proc)
    [46331] = { newId = 46331, duration = 6000 },                   -- crystal weapon (self buff)
    [28025] = { newId = 143659, noRemove = true, duration = 4000 }, -- encase (target immobilize)
    [28308] = { newId = 143663, noRemove = true, duration = 4000 }, -- shattering prison
    [28311] = { newId = 143668, noRemove = true, duration = 4000 }, -- restraining prison

    -- Daedric Summoning
    [23492] = { newId = 80463, duration = 15000 },                       -- greater storm atronach
    [23495] = { newId = 80468, duration = 15000 },                       -- summon charged atronach (player track)
    [23634] = { newId = 80459, duration = 15000 },                       -- summon storm atronach
    [24158] = { newId = 24158, duration = 3000 },                        -- bound armor
    [24163] = { newId = 24163, duration = 3000 },                        -- bound aegis
    [24165] = { newId = 203447, duration = 10000 },                      -- bound armaments
    [24326] = { newId = 24326, noRemove = true, duration = 6000 },       -- daedric curse (target)
    [24328] = { newId = 24328, noRemove = true, duration = 6000 },       -- daedric prey (target)
    [24330] = { newId = 24330, noRemove = true, combatTrack = true },    -- haunting curse (stacks via 89491 ExtraId)
    [28418] = { newId = 28418, duration = 6000 },                        -- conjured ward
    [29489] = { newId = 29489, duration = 6000 },                        -- hardened ward
    [29482] = { newId = 29482, duration = 10000 },                       -- empowered ward
    [77140] = { newId = 77354, showFakeAura = true, noRemove = true },   -- twilight tormentor enrage
    [77182] = { newId = 77187, showFakeAura = true, noRemove = true },   -- volatile pulse
    [108840] = { newId = 108842, showFakeAura = true, noRemove = true }, -- summon unstable familiar
    [23304] = { newId = 108844, showFakeAura = true, noRemove = true },  -- unstable pulse
    [24636] = { newId = 77354, showFakeAura = true, noRemove = true },   -- summon twilight tormentor
    [23316] = { newId = 77187, showFakeAura = true, noRemove = true },   -- summon volatile familiar

    -- Storm Calling
    [18718] = { newId = 18746, duration = 2000 },   -- mages' fury (target execute)
    [19109] = { newId = 19118, duration = 2000 },   -- endless fury (target execute)
    [19123] = { newId = 19125, duration = 2000 },   -- mages' wrath
    [23182] = { newId = 157462, duration = 10000 }, -- lightning splash (ground)
    [23205] = { newId = 157537, duration = 10000 }, -- lightning flood (ground)
    [23200] = { newId = 157535, duration = 15000 }, -- liquid lightning (ground)
    [23210] = { newId = 23210, duration = 20000 },  -- lightning form
    [23213] = { newId = 23213, duration = 30000 },  -- boundless storm
    [23231] = { newId = 23231, duration = 20000 },  -- hurricane
    [23234] = { newId = 51392, duration = 4000 },   -- bolt escape fatigue
    [23236] = { newId = 51392, duration = 4000 },   -- streak fatigue
    [23277] = { newId = 51392, duration = 4000 },   -- ball of lightning fatigue
    [23670] = { newId = 23670, duration = 33000 },  -- surge
    [23674] = { newId = 23674, duration = 33000 },  -- power surge
    [23678] = { newId = 23678, duration = 33000 },  -- critical surge

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

    -- Grave Lord — skull charge stacks (combatTrack; max 3 in BarHighlightStack)
    [114108] = { newId = 114131, combatTrack = true, combatStackNoExpire = true },         -- Flame Skull (slotted / cast 1 projectile)
    [123683] = { newId = 114131, combatTrack = true, combatStackNoExpire = true },         -- Flame Skull charged cast (no corpse; combat log cast 2+)
    [123685] = { newId = 114131, combatTrack = true, combatStackNoExpire = true },         -- Flame Skull every-3rd cast (+ corpse)
    [117624] = { newId = 117625, combatTrack = true, combatStackNoExpire = true },         -- Venom Skull (slotted / cast 1)
    [123699] = { newId = 117625, combatTrack = true, combatStackNoExpire = true },         -- Venom Skull charged cast
    [123704] = { newId = 117625, combatTrack = true, combatStackNoExpire = true },         -- Venom Skull 3rd cast
    [117637] = { newId = 117638, combatTrack = true, combatStackNoExpire = true },         -- Ricochet Skull (slotted / cast 1)
    [123718] = { newId = 117638, combatTrack = true, combatStackNoExpire = true },         -- Ricochet Skull charged cast
    [123719] = { newId = 117638, combatTrack = true, combatStackNoExpire = true },         -- Ricochet Skull 3rd cast

    [114860] = { newId = 114863 },                                                         -- Blastbones
    [117330] = { newId = 114863 },                                                         -- Blastbones
    [117690] = { newId = 117691 },                                                         -- Blighted Blastbones
    [117693] = { newId = 117691 },                                                         -- Blighted Blastbones
    [117749] = { newId = 117750, showFakeAura = true, noRemove = true, duration = 20500 }, -- Grave Lord's Sacrifice (Stalking)
    [117773] = { newId = 117750 },                                                         -- Relentless Blastbones --> Stalking Blastbones

    [115252] = { newId = 115255, showFakeAura = true, noRemove = true, duration = 10400 }, -- Boneyard
    [117805] = { newId = 117807, showFakeAura = true, noRemove = true, duration = 10400 }, -- Unnerving Boneyard
    [117850] = { newId = 117852, showFakeAura = true, noRemove = true, duration = 10400 }, -- Avid Boneyard

    [114317] = { newId = 114317, duration = 20000 },                                       -- Skeletal Mage
    [118680] = { newId = 118680, duration = 20000 },                                       -- Skeletal Archer
    [118726] = { newId = 118726, duration = 20000 },                                       -- Skeletal Arcanist

    [122174] = { newId = 122380, showFakeAura = true, noRemove = true, duration = 3000 },  -- Frozen Colossus
    [122395] = { newId = 122398, showFakeAura = true, noRemove = true, duration = 3000 },  -- Pestilent Colossus
    [122388] = { newId = 122391, showFakeAura = true, noRemove = true, duration = 3000 },  -- Glacial Colossus

    [115924] = { newId = 116445 },                                                         -- Shocking Siphon
    [118763] = { newId = 118764 },                                                         -- Detonating Siphon
    [118766] = { newId = 118764 },                                                         -- Detonating Siphon (ground tick id -> aura id)
    [118008] = { newId = 118009 },                                                         -- Mystic Siphon

    [118226] = { newId = 125750 },                                                         -- Ruinous Scythe --> Off Balance
    [118223] = { newId = 122625 },                                                         -- Hungry Scythe

    [115238] = { newId = 115240 },                                                         -- Bitter Harvest
    [118623] = { newId = 124165 },                                                         -- Deaden Pain
    [118639] = { newId = 124193 },                                                         -- Necrotic Potency

    [115177] = { newId = 121513 },                                                         -- Grave Grasp
    [118308] = { newId = 118309 },                                                         -- Ghostly Embrace
    [118352] = { newId = 118354 },                                                         -- Empowering Grasp

    [115206] = { newId = 115206, duration = 20000 },                                       -- Bone Armor
    [118237] = { newId = 118237, duration = 20000 },                                       -- Beckoning Armor
    [118244] = { newId = 118244, duration = 30000 },                                       -- Summoner's Armor

    [115093] = { newId = 115095, showFakeAura = true, noRemove = true, duration = 11100 }, -- Bone Totem
    [118380] = { newId = 118381, showFakeAura = true, noRemove = true, duration = 11100 }, -- Remote Totem
    [118404] = { newId = 118405, showFakeAura = true, noRemove = true, duration = 13100 }, -- Agony Totem

    [115001] = { newId = 115001, duration = 20000 },                                       -- Bone Goliath Transformation
    [118664] = { newId = 118664, duration = 20000 },                                       -- Pummeling Goliath
    [118279] = { newId = 118279, duration = 20000 },                                       -- Ravenous Goliath

    [114196] = { newId = 114206, showFakeAura = true },                                    -- Render Flesh --> Minor Defile
    [117883] = { newId = 117885, showFakeAura = true },                                    -- Resistant Flesh --> Minor Defile
    [117888] = { newId = 117890, showFakeAura = true },                                    -- Blood Sacrifice --> Minor Defile

    [115315] = { newId = 115532, showFakeAura = true, noRemove = true, duration = 5100 },  -- Life amid Death (player aura when extended)
    [118017] = { newId = 118018, showFakeAura = true, noRemove = true, duration = 5100 },  -- Renewing Undeath
    [118809] = { newId = 118810, showFakeAura = true, noRemove = true, duration = 30100 }, -- Enduring Undeath (corpse-extended HoT window)

    [115710] = { newId = 115710, duration = 16000 },                                       -- Spirit Mender
    [118912] = { newId = 118912, duration = 16000 },                                       -- Spirit Guardian
    [118840] = { newId = 118840, duration = 8000 },                                        -- Intensive Mender

    [115926] = { newId = 116450 },                                                         -- Restoring Tether
    [118070] = { newId = 118071 },                                                         -- Braided Tether
    [118122] = { newId = 118123 },                                                         -- Mortal Coil

    [118379] = { newId = 124999, showFakeAura = true, noRemove = true, duration = 8000 },  -- Animate Blastbones

    ---------------------------
    -- Arcanist ---------------
    ---------------------------
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
    [186211] = { newId = 195190, showFakeAura = true, noRemove = true, duration = 7000 }, -- Fleet-Footed Gate (cast --> entry portal ground)
    [197856] = { newId = 195190, showFakeAura = true, noRemove = true, duration = 7000 }, -- Fleet-Footed Gate (cost variant)

    [186220] = { newId = 195204, showFakeAura = true, noRemove = true, duration = 7000 }, -- Passage Between Worlds (cast --> entry portal ground)
    [190394] = { newId = 195204, showFakeAura = true, noRemove = true, duration = 7000 }, -- Passage Between Worlds (cost variant)

    [183542] = { newId = 195167, showFakeAura = true, noRemove = true, duration = 7000 }, -- Apocryphal Gate (cast --> entry portal ground)
    [178457] = { newId = 195167, showFakeAura = true, noRemove = true, duration = 7000 }, -- Apocryphal Gate (cost variant)

    -- Remedy Cascade (channeled): channel combat id reports [Chan] 4500 in combat log
    [183537] = { combatTrack = true, duration = 4500 },                                                    -- Remedy Cascade (cost mag)
    [198309] = { combatTrack = true, duration = 4500 },                                                    -- Remedy Cascade (cost stam)
    [178454] = { newId = 183537, combatTrack = true, duration = 4500, combatTrackRemainOnSlotted = true }, -- Remedy Cascade (cost variant --> channel id)

    -- Curative Surge (channeled)
    [186200] = { combatTrack = true, duration = 4500 }, -- Curative Surge (cost mag)
    [198537] = { combatTrack = true, duration = 4500 }, -- Curative Surge (cost stam)

    -- Cascading Fortune (channeled)
    [186193] = { combatTrack = true, duration = 4500 }, -- Cascading Fortune (cost mag)
    [198330] = { combatTrack = true, duration = 4500 }, -- Cascading Fortune (cost stam)

    -- Fatecarver (channeled): slotted id maps to player channel combat id; combatTrack + duration for slot registration
    [185805] = { newId = 189533, combatTrack = true, duration = 4500, combatTrackRemainOnSlotted = true }, -- Fatecarver (magicka)
    [193331] = { combatTrack = true, duration = 4500 },                                                    -- Fatecarver (stamina)
    [183122] = { newId = 189533, combatTrack = true, duration = 4500, combatTrackRemainOnSlotted = true }, -- Exhausting Fatecarver (magicka)
    [193397] = { combatTrack = true, duration = 4500 },                                                    -- Exhausting Fatecarver (stamina)
    [186366] = { newId = 189533, combatTrack = true, duration = 4500, combatTrackRemainOnSlotted = true }, -- Pragmatic Fatecarver (magicka)
    [193398] = { newId = 184220, combatTrack = true, duration = 4500 },                                    -- Pragmatic Fatecarver (stamina)

    ---------------------------
    -- Two Handed -------------
    ---------------------------

    [20919] = { newId = 159717, showFakeAura = true, duration = 6000 },                  -- Cleave --> damage shield
    [38807] = { newId = 61737, showFakeAura = true, duration = 3000 },                   -- Wrecking Blow --> Empower
    [38814] = { newId = 131562, noRemove = true },                                       -- Dizzying Swing --> Off Balance 7s (target)
    [16825] = { newId = 38814, duration = 2000, combatTrack = true, noRemove = true },   -- Off Balance Exploit stun (re-hit on OB; log 17:44)
    [137807] = { newId = 38814, duration = 2000, combatTrack = true, noRemove = true },  -- OB immune snare fallback (log IMMUNE + 137807 2s)
    [38788] = { newId = 99789, showFakeAura = true, duration = 18000, noRemove = true }, -- Stampede --> Merciless Charge (vMA); Stampede track via ExtraId 126475
    [38745] = { newId = 159728, showFakeAura = true, duration = 6000 },                  -- Carve --> damage shield (target bleed 38747)
    [38754] = { newId = 38763, showFakeAura = true, duration = 6000 },                   -- Brawler --> damage shield

    [28448] = { newId = 99789, showFakeAura = true, duration = 18000, noRemove = true }, -- Critical Charge --> Merciless Charge
    [38778] = { newId = 99789, showFakeAura = true, duration = 18000, noRemove = true }, -- Critical Rush --> Merciless Charge

    [28297] = { showFakeAura = true, noRemove = true },                                  -- Momentum --> Major Brutality
    [38794] = { newId = 38797 },                                                         -- Forward Momentum
    [38802] = { showFakeAura = true, noRemove = true },                                  -- Rally
    [83216] = { newId = 83217, showFakeAura = true, duration = 12000 },                  -- Berserker Strike
    [83229] = { newId = 83230, showFakeAura = true, duration = 8000 },                   -- Onslaught
    [83238] = { newId = 83239, showFakeAura = true, duration = 12000 },                  -- Berserker Rage

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

    [28607] = { newId = 99806 }, -- Flurry --> Cruel Flurry
    [38857] = { newId = 99806 }, -- Rapid Strikes --> Cruel Flurry
    [38846] = { newId = 99806 }, -- Bloodthirst --> Cruel Flurry

    [28379] = { newId = 29293 }, -- Twin Slashes --> Twin Slashes Bleed
    [38839] = { newId = 38841 }, -- Rending Slashes --> Rending Slashes Bleed
    -- [38845] = { newId = 38852 },   -- Blood Craze
    [38845] = { newId = 38848 }, -- Blood Craze

    -- Blade Cloak (28613): player self buff 247975 (~900 ms GAIN DUR pulse; 20s skill duration from slotted/effect).
    [28613] = { newId = 247975, combatTrack = true, duration = 900, combatTrackRemainOnSlotted = true, noRemove = true },

    [28591] = { newId = 100474 },  -- Whirlwind --> Chaotic Whirlwind
    [38891] = { newId = 100474 },  -- Whirling Blades --> Chaotic Whirlwind
    [38861] = { newId = 100474 },  -- Steel Tornado --> Chaotic Whirlwind

    -- Hidden Blade line (blade.txt): player [61665] @ 20s; combat [68807]/[126647] @ 20s; bar key = slotted id + BarHighlightSlottedMajorCap (blocks 60s Igneous 61665 on dagger slot).
    [21157] = { duration = 20000, noRemove = true },                                    -- Hidden Blade
    [38914] = { duration = 20000, noRemove = true },                                    -- Shrouded Daggers
    [68807] = { newId = 21157, noRemove = true, duration = 20000, combatTrack = true }, -- Major Brutality combat (Hidden Blade)
    [126647] = { newId = 38914, noRemove = true, duration = 20000, combatTrack = true }, -- Major Brutality combat (Shrouded Daggers)
    [38910] = { newId = 126667 },  -- Flying Blade (target mark; CheckOnFade resyncs player 61665)
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
    [39105] = { newId = 137184 },                      -- Brutal Pounce --> Brutal Carnage 12s DOT
    [39104] = { newId = 137164 },                      -- Feral Pounce --> Feral Carnage

    [58317] = { newId = 137206, showFakeAura = true }, -- Hircine's Rage --> Hircine's Rage active state
    [58325] = { newId = 61704 },                       -- hircine's fortitude (minor fortitude)
    [32633] = { newId = 137257 },                      -- roar (off-balance)
    [39113] = { newId = 45834 },                       -- ferocious roar (off-balance)
    [39114] = { newId = 137312 },                      -- Deafening Roar --> Off Balance 7s
    [58405] = { newId = 137317 },                      -- Gnash --> 400ms second-hit indicator
    [58742] = { newId = 58745 },                       -- Rip and Tear --> 400ms second-hit indicator
    [58798] = { newId = 58801 },                       -- Bloody Gnash --> 400ms second-hit indicator
    [58855] = { newId = 58856 },                       -- Rending Claws --> DOT
    [58864] = { newId = 58864 },                       -- Claw Fury --> channel buff
    [58879] = { newId = 58880 },                       -- Bloodclaws --> 10s target Bleed DOT

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

    -- Grimoire Support banners (table 198758357): Shocking Banner slotted --> player inspire buff 5s (227087/227088)
    [217706] = { newId = 227087, showFakeAura = true, noRemove = true, duration = 5000 }, -- Shocking Banner (Dragonknight's Banner on DK)
    [227088] = { hide = true },                                                           -- paired parallel buff
    [227089] = { hide = true },                                                           -- 100ms tick

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
    -- Cyrodiil Vengeance (combat log 2025-06; VENGEANCE_SKILL_MAP.csv)
    ---------------------------

    -- Necromancer — Bone Tyrant / Living Death / Grave Lord
    [253156] = { newId = 253163, combatTrack = true },                                    -- Vengeance Grave Grasp (QUEUED / ON CD / target 253163)
    [246025] = { newId = 246026, combatTrack = true, duration = 20000 },                  -- Vengeance Bone Armor (246025 GAIN DUR; 61694 on player)
    [246026] = { newId = 246026, combatTrack = true, duration = 20000 },                  -- Vengeance Bone Armor (246026 parallel GAIN DUR / FADE)
    [238178] = { newId = 238178, combatTrack = true, noRemove = true, duration = 4000 },  -- Vengeance Bone Totem (tooltip Duration 4s; log GAIN D 4000 + ground ~2s arm)
    [238258] = { newId = 238258, showFakeAura = true, noRemove = true, duration = 1000 }, -- Vengeance Life amid Death (ground)
    [238137] = { newId = 238137, combatTrack = true },                                    -- Vengeance Death Scythe (ON CD / OOR / STUN / STAGGER)
    [238129] = { newId = 238129, showFakeAura = true, noRemove = true, duration = 3000 }, -- Vengeance Frozen Colossus (ground; log 238129/238130 GAIN)
    [238255] = { newId = 238255, combatTrack = true },                                    -- Vengeance Expunge (QUEUED; cleanse + restore bundle)

    -- Alliance War — Soldier loadout kit
    [255057] = { newId = 255057, combatTrack = true },                   -- Sweeping Assault (CD / combat from log ON CD)
    [255164] = { newId = 269944, noRemove = true },                      -- Battle Trauma (reticle target; 269944 + 255165 via ExtraId / CheckOnFade)
    [255184] = { newId = 255184, combatTrack = true, duration = 20000 }, -- Stand Firm (log 255184 GAIN DUR / FADE; Minor Resolve 61693 on player)
    [255189] = { newId = 255189, combatTrack = true, duration = 10000 }, -- Regroup (255189 GAIN DUR; 61705 + 61707 on player)
    [255190] = { newId = 255189, combatTrack = true, duration = 10000 }, -- Regroup --> Major Intellect combat (remap to slotted)
    [255326] = { newId = 255326, combatTrack = true, duration = 15000 }, -- Marshaling Cry (255326 GAIN DUR; 61744 + 61735 on player)
    [255327] = { newId = 255326, combatTrack = true, duration = 15000 }, -- Marshaling Cry --> Minor Berserk combat (remap to slotted)
    [255479] = { newId = 255479, combatTrack = true, duration = 10000 }, -- Detonating Strike (255479 GAIN DUR; FADE on detonate cast)
    [255498] = { newId = 255479, combatTrack = true, duration = 10000 }, -- Detonating Strike (ground BEGIN; remap to proc bar)
    [255512] = { newId = 255479, combatTrack = true, duration = 10000 }, -- Detonating Strike (player track GAIN DUR; FADE with proc)

    -- Alliance War — Vanguard kit (log 2025-06-07)
    [255681] = { newId = 255682, showFakeAura = true, noRemove = true, duration = 20000 }, -- In The Fray --> player track 255682
    [255689] = { newId = 255689, combatTrack = true, duration = 6000 },                     -- Warding Interception + Major Protection 61722
    [255673] = { newId = 269817, noRemove = true },                                          -- Ensnaring Chains --> target ROOT 269817
    [255789] = { newId = 255789, showFakeAura = true, noRemove = true, duration = 2000 },   -- Unleashed Fury channel
    [255952] = { newId = 255952, noRemove = true },                                          -- Demoralizing Disruption (silence on target)
    [255650] = { newId = 255651 },                                                           -- Shoulder Toss (slotted) --> target stun
    [255651] = { combatTrack = true, noRemove = true, duration = 1400 },                   -- Stun on reticle (~1.4s; log GAIN DUR 1390)

    -- Alliance War — Scout kit (log 2025-06-07)
    [256557] = { newId = 256560, noRemove = true },                                          -- Blade Bite --> target bleed
    [256560] = { combatTrack = true, noRemove = true, duration = 6000 },                     -- Bleed track (stacks ≤3)
    [256690] = { combatTrack = true, noRemove = true, duration = 4000 },                     -- Nimble Feint disorient on reticle (log GAIN DUR 4000)
    [256692] = { showFakeAura = true, duration = 3000 },                                     -- Nimble Feint Fatigue (3s CD; CheckOnFade durationMod only)
    [256693] = { showFakeAura = true, duration = 4000 },                                     -- Nimble Feint Dummy (4s window; CheckOnFade duration only)
    [256715] = { showFakeAura = true, duration = 4000 },                                     -- Cleansing Shadow Dummy (4s CD; CheckOnFade duration only)
    [256694] = { newId = 256695, showFakeAura = true, noRemove = true, duration = 20000 },   -- Stalker's Quarry --> player track
    [256695] = { newId = 256695, combatTrack = true, duration = 20000 },                     -- Parallel player GAIN DUR / FADE
    [256713] = { showFakeAura = true, noRemove = true },                                     -- Cleansing Shadow (player invis 3s; CD 4s -- combat + CheckOnFade)
    [256716] = { newId = 256716, showFakeAura = true, noRemove = true, duration = 5000 },  -- Burst of Speed
    [256736] = { newId = 256736, combatTrack = true, noRemove = true, duration = 6000 },   -- Focus Fire ult (target GAIN DUR + Major Brittle)

    ---------------------------
    -- Temp -------------------
    ---------------------------
    [217699] = { newId = 227087 }, -- Dragonknight's Banner
}

Effects.BarHighlightOverride = barHighlightOverride
