-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------
-- Infinite Archive ability alerts (merged at load). Review in-game and refine mitigations.

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
local AlertTable = Data.AlertTable

local ACTION_RESULT_BEGIN = ACTION_RESULT_BEGIN
local ACTION_RESULT_EFFECT_GAINED = ACTION_RESULT_EFFECT_GAINED

local LUIE_ALERT_SOUND_TYPE_ST = LUIE_ALERT_SOUND_TYPE_ST
local LUIE_ALERT_SOUND_TYPE_ST_CC = LUIE_ALERT_SOUND_TYPE_ST_CC
local LUIE_ALERT_SOUND_TYPE_AOE = LUIE_ALERT_SOUND_TYPE_AOE

--- @class (partial) InfiniteArchiveAlerts
local infiniteArchiveAlerts =
{
    [35849] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shadow Cloak
    [43237] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Inferno
    [47461] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, interrupt = true, duration = 4500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Two-hander's Channel
    [94074] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 900, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- add spin
    [122995] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 600, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Bear Roar (fear)
    [145467] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Charge
    [150355] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Ice Atro Heavy Attack
    [157030] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Realmshaper Cast (interrupt)
    [159824] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 2200, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Yaghra Heavy Attack 2
    [173998] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Indrik Cast
    [191366] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Channeled Swipes
    [191428] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Shield Throw
    [191429] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Leap
    [191506] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Cleave
    [191526] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- AoE
    [191542] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Breath
    [191596] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Tail Smite
    [191598] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 100, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Pounce & Feed
    [191650] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [191653] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Charge?
    [191670] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Daedric Blast
    [191689] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- AoE
    [191693] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Flurry
    [191707] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [192039] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, dodge = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Splintering Mirror (extra shards after destroying Replicanum's shield)
    [192205] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Tho'at Replicanum
    [192348] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Burning Embers
    [192522] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Polymorph Skeleton
    [192658] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST },
    [192659] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Iceheart
    [192695] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Glass Leviathan
    [192707] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Glass Tendril
    [193164] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Summon spiders
    [193182] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Glass Labyrinth
    [193515] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Spit
    [193518] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Headbutt
    [193521] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Shockwave
    [193811] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [193812] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack
    [194034] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 600, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Grasping Scream (fear, can be blocked; ??? target)
    [194053] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Allene Pellingare
    [194077] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Add's Heavy Attack
    [194158] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC },
    [194269] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [194303] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- AoE
    [194335] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Spear
    [194345] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack
    [194356] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Fire Wave 1
    [194373] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Fire Wave 2
    [194378] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Fire Wave 3
    [194416] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Flame Spout
    [194549] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [194550] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Stomp AoE
    [194605] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- 3x Charges
    [194609] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Ground Smash
    [194626] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Blood Barrage
    [194656] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Realmshaper Heavy Attack
    [194663] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [194736] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Unrelenting Force
    [194749] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Breath
    [194756] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [194765] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Left Wing
    [194777] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Right Wing
    [194811] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Takeoff
    [194828] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, interrupt = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Perch (landing)
    [194830] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 3000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Storm Run
    [194894] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Dremora Ravager Uppercut
    [194907] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [194908] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [194918] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Yolnahkriin Left Wing Thrash
    [194932] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Yolnahkriin Right Wing Thrash
    [194966] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Takeoff
    [194987] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Ascendent Vanguard Heavy Attack
    [195079] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [195156] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- High Kinlord Rilis Bubble
    [195323] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 667, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Pulse (shock attack)
    [195350] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST },
    [195351] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Light Attack
    [195420] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Cleave
    [195455] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Molten Rain
    [195460] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- ???
    [195462] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Rock Fall
    [195484] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- AoE
    [195487] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Big Bang
    [195490] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Grothdarr
    [195510] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [195513] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Catching Flame (range attack)
    [195591] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Smash
    [195612] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Crashing Wave (dodgable AoE)
    [195639] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST },
    [195640] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Charge
    [195655] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 3000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Channel Shadow (3000/5000)
    [195669] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Double Slam (can't dodge)
    [195671] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Shadow Stomp
    [195722] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 3100, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Rune
    [195773] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1100, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Teleport & Strike
    [195790] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Roots
    [195959] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, interrupt = true, duration = 300, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Consume Life
    [195965] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Vorenor Winterbourne
    [195978] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST },
    [196129] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Necrotic Blast
    [196238] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Lethal Stab
    [196257] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Right Wing
    [196278] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Left Wing
    [196308] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Storm Breath
    [196371] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, interrupt = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Perch
    [196372] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Storm Run
    [196397] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [196401] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Cleave
    [196407] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 800, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shock Spear
    [196414] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Meteor Strike
    [196441] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Storm Slam
    [196517] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Summon Buff Totem
    [196719] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, interrupt = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Bulwark (range attack, not dodgable?)
    [196727] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Bulwark Standard
    [196806] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Negate
    [196845] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Realmshaper AoE
    [196860] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Durzog Rotbone
    [196867] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Wild Guar Jump
    [196919] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [196920] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 400, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Blade Dance
    [196997] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- one shot without block on high arcs (500ms to start -> 3500ms channel (reduces with each arc) -> big final hit)
    [197004] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Storm Atronach Impending Storm
    [197016] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shadow Orb
    [197065] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Agonizing Bolts (shock AoE)
    [197152] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Lord Warden Dusk
    [197157] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Barrage (3600/6000)
    [197355] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shatter
    [197421] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, interrupt = true, duration = 1750, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Curse
    [197573] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [197580] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Blood Rage (interrupt)
    [197604] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Charge
    [197614] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- AoE
    [197661] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 3000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack [2200/2245]
    [197683] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, interrupt = true, duration = 3750, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Aspect of Winter (ice comet)
    [197868] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Wipeout
    [197982] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, dodge = true, duration = 1250, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Don't dodge, or she will bug out
    [198007] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 100, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Charge
    [198103] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Blood Dive
    [198333] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Kjarg the Tuskscraper
    [198680] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- quick attack (hard to react)
    [198685] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- jump/stomp
    [198723] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Black Winter
    [198775] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Slam
    [198817] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack
    [198819] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Inferno (Fire Breath) (1500/2000)
    [198844] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Arctic Shred (Ice AoE)
    [198853] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Lightning Bolt (stun)
    [198902] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [198946] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- 3x combo 1st hit
    [198949] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- 3x combo 2nd hit
    [198950] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 3000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- 3x combo last hit (heavy attack)
    [198958] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Unstable Blitz
    [199387] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, interrupt = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Empowered Runeblades (interrupt), ~ 17s CD (first cast 15 or depends on crystal???)
    [199410] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shivering Swat (cone attack)
    [199437] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack
    [199503] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Ground Target (tentacle)
    [199600] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Cleave
    [199628] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, dodge = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Bewilder (add)
    [199901] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [199906] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 800, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Focal Quake
    [200060] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 10000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Gw
    [200067] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_ST },
    [201193] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Start Fight (86400000 Aramril -> P)
    [201360] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Tremorscale
    [201835] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Firesong Rockseer Heavy Attack
    [202129] = { priority = 3, result = ACTION_RESULT_BEGIN, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dreadhorn Blade-Bearer Heavy Attack
    [202377] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Bone Colossus
    [202513] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dwarven Sphere Shock Barrage
    [202530] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST },
    [202531] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dwarven Centurion
    [202539] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dwarven Sphere
    [202541] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST },
    [202607] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dreadhorn Earthgorer Clobber
    [202632] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 700, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dreadhorn Firehide
    [202656] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1467, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Dreadhorn Firehide AoE
    [202665] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Bear
    [202940] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Harry (arc 7+)
    [202945] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Wolf Lunge
    [202948] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Nip (arc 7+)
    [203100] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 900, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Cliff Strider AoE
    [203104] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Cliff Strider Dive
    [203464] = { priority = 3, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Dreadhorn Scrapper
    [203467] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 400, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Dreadhorn Scrapper Oil
    [203496] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Dremora Ironclad Heavy Attack
    [203519] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Throw Dagger
    [203525] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Teleport Strike
    [203593] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack 1
    [204209] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 3500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Void Strike (Heavy Attack)
    [204216] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 3600, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Void Barrage
    [204225] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1900, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Threshing Wings
    [204260] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Lunar Smash
    [204446] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [204515] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Liquidate (small AoE that makes her immune?)
    [204558] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Mind Blast
    [204560] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Yaghra Heavy Attack 1
    [205013] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Crush (quick attack)
    [205021] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Uneven Terrain
    [205030] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Galvanic Blow (shock AoE)
    [205036] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack
    [208124] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, dodge = true, duration = 4500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Glass Sky
    [209537] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Shield Throw
    [209640] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1800, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Bear Heavy Attack
    [209767] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Gelid Globe (Avatar of Vigor)
    [209846] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Right Wing Thrash
    [209924] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Chomp 1
    [209925] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Chomp 2
    [209926] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Chomp 3
    [209931] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Breath (<<<)
    [209948] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Breath (>>>)
    [210006] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- 3x combo start (2 quick hits)
    [210010] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- 3x combo final hit (heavy attack)
    [210028] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1350, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- throwing swords
    [210483] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Inferno
    [210519] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack
    [210561] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Totem Master's Totem
    [210599] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Totem Master's Totem
    [210837] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- infuse allies
    [210840] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [211114] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 1400, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Magma Frog Heavy 1
    [211976] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Fabled Mystic's Meteor
    [212000] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 5000, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Spawn
    [212001] = { priority = 1, result = ACTION_RESULT_BEGIN, interrupt = true, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Spellthief Nullification
    [212268] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, interrupt = true, duration = 1250, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- blobs/tentacles spawn
    [220881] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Big AoE
    [220959] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [221108] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Bite (puts bleeding)
    [221112] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack
    [221207] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Thunder Hammer
    [221209] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, interrupt = true, duration = 2000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Shock Aura
    [221213] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Slam
    [221219] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 633, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Standard
    [221231] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [221364] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, interrupt = true, duration = 44000, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Fabled Stormcaller's cast
    [221730] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Fabled Stormcaller's AoE
    [221753] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Fabled Lightbringer's Heavy Attack
    [221791] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, avoid = true, duration = 15000, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Shadow Spinneret
    [221809] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Mark of Mephala
    [221816] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack 2
    [221929] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Heavy Attack
    [221959] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, bs = true, dodge = true, interrupt = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Air Burst (charge) -> Beam (must interrupt)
    [221964] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Cyclone (AoE in front)
    [221975] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1600, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Heavy Attack
    [221979] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 2400, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Toxic Tide
    [221988] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Sundering Strike (armor debuff)
    [222885] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1200, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Hag 3x fireball
    [222916] = { priority = 1, result = ACTION_RESULT_EFFECT_GAINED, block = true, interrupt = true, duration = 700, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Lich small AoE
    [222919] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1365, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Lich big AoE
    [222933] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 2500, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Lich cone AoE
    [223086] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Magma Frog Heavy 2
    [223119] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Reap
    [223135] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_ST },
    [223191] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, avoid = true, interrupt = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Wraith of Crows AoE
    [223720] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, eventdetect = true, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- frost imp, same logic
    [226975] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 6700, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Combustion (boom)
    [227222] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, dodge = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Boulder
    [227232] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Nullification
    [227457] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- AoE
    [227953] = { priority = 1, result = ACTION_RESULT_BEGIN, block = true, interrupt = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_ST }, -- Agonizing Strike
    [228021] = { priority = 1, result = ACTION_RESULT_BEGIN, avoid = true, duration = 1500, sound = LUIE_ALERT_SOUND_TYPE_AOE }, -- Storm Cell (donut)

}

for abilityId, entry in pairs(infiniteArchiveAlerts) do
    AlertTable[abilityId] = entry
end
