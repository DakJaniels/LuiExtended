-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local zo_strformat = zo_strformat
local table_concat = table.concat
local GetDisplayName = GetDisplayName
-- -----------------------------------------------------------------------------
local changelogMessages =
{
    -- Version Header 7.2.1.0
    "|cFFA500LuiExtended Version 7.2.1.0|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ActionBar: companion ultimate tracking — optional value and percent labels on the companion ultimate slot (font, colors, vertical offset, hide when full); quickslot/keybind layout follows ZOS companion anchor chain when the companion button is shown.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t CombatInfo (console): reset-to-defaults restores the module's saved settings from defaults and refreshes Ability Alerts and Crowd Control Tracker UI.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames (debug): new `/luiufall` — toggles every custom-frame preview at once, temporarily enables frame-move mode for layout, and restores the previous unlock state when turned off.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: `ZO_AdvZoneHUD_TopLevel` (Night Market favor counter) mover uses `ZO_HUDTelvarMeter` width/height when present so the frame tracks the Telvar/stone meter layout.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: custom frame color handling updated to respect saved alpha values.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: CrutchAlerts Boss Health Bar integration — uses the current API (including per-boss `boss1`/`boss2` threshold tables when the encounter provides them); stack-level percent labels above the boss block and rotated mechanic names below; shared thresholds draw a single line through all visible boss bars; listens for `BossHealthBar.RegisterThresholdsChangeListener` so programmatic overrides refresh markers; ACTIVE / IMMINENT / PASSED tinting matches Crutch bar colors and updates as boss HP changes (rounding follows Crutch `useFloorRounding` when Crutch is loaded).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Settings (PC & console): boss threshold marker anchor dropdowns removed (obsolete with the stack layout); X/Y controls are a horizontal nudge for both label rows and shared vertical padding from the bar block.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t DependsOn: LuiData minimum version raised to match bundled data (see manifest).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Battle Spirit custom tooltips updated for U49 (extra healing reduction when 8 or more healing over time effects are active; Cyrodiil vs Imperial City variants).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Internal: several modules now use ZO math globals (`zo_floor`, `zo_max`, `zo_min`, etc.) instead of `math.*` for consistency with ESO UI code.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames (debug): slash-command previews for individual frames — `/luiufplayer`, `/luiuftar`, `/luiufsm`, `/luiufraid`, `/luiufpet`, `/luiufboss`, `/luiufcomp`, `/luiufava` show enabled custom frames with live player power and labels.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Settings (PC & console): custom frame unlock checkbox and grid-snap overlay refresh use `UnitFrames.CustomFramesMovingState` (removed duplicate local moving flag).",
    "",

    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: boss threshold markers and mechanic labels align to the health bar (labels were anchored from the bar center horizontally; lines used the left edge).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: boss threshold markers clear when no boss units exist (wipe / despawn) instead of lingering on screen.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: custom group/raid frame repositioning — member controls have mouse disabled while moving so the top-level window reliably receives drags.",
    "",
    -- Version Header 7.2.0.9
    "|cFFA500LuiExtended Version 7.2.0.9|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Dynamic Events Tracker (Night Market) mover.",
    "",
    -- Version Header 7.2.0.8
    "|cFFA500LuiExtended Version 7.2.0.8|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t General: Swapped to using zo_callLater. it might make the code happy, who knows...",
    "",
    -- Version Header 7.2.0.7
    "|cFFA500LuiExtended Version 7.2.0.7|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t General: Fix a API change from update 50 that made it to live.",
    "",
    -- Version Header 7.2.0.6
    "|cFFA500LuiExtended Version 7.2.0.6|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: incorrect items were showing as being confiscated.",
    "",
    -- Version Header 7.2.0.5
    "|cFFA500LuiExtended Version 7.2.0.5|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Added base UI unlock for battering ram status indicator.",
    "",
    -- Version Header 7.2.0.4
    "|cFFA500LuiExtended Version 7.2.0.4|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SlashCommands: `/cake` and `/jubilee` should now work without needing yearly updates...",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Error when clicking link for timed activities due to 11.3.5 code change in the `ZO_TimedActivities_Manager` Class.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action bar: Flame Lash / Power Lash proc icon flicker (GitHub #379) — `SetupActionSlot` no longer applies `BarIdOverride` for proc/base pairs flagged in `IsAbilityProc` / `BaseForAbilityProc` (global `actionbutton` hook; disabling the ActionBar module alone did not avoid it).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action bar: Power Lash stack buff (abilityId 34117, U41+ 5x / 20s) — bar highlight tracks combat/buff data via `combatTrack`, toggled labels show stacks and timer; stacks decrement on Power Lash cast (`OnAbilityUsed`), timer and overlay clear when stacks reach zero; sync from `EVENT_EFFECT_CHANGED` / combat when ZOS reports zero stacks.",
    "",
    -- Version Header 7.2.0.3 (console)
    "|cFFA500LuiExtended Version 7.2.0.3|r",
    "|c888888Console only.|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Error on player interaction.",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: setting to move the player long buffs container.",
    "",
    -- Version Header 7.2.0.2
    "|cFFA500LuiExtended Version 7.2.0.2|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Info Panel / font system: fixed crash \"Checking type on argument fontStyle failed in GetFontStyleString_lua\" when SavedVariables contained a display string (e.g. |cFFFFFFNormal|r) or invalid FontStyle. Migration and font creation now normalize values and use a safe default; Info Panel and SpellCastBuffs use the shared wrapper so only valid FontStyle integers (0–7) are passed to the game API.",
    "",
    -- Version Header 7.2.0.1
    "|cFFA500LuiExtended Version 7.2.0.1|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: option to hide the custom player frame when dead; the frame shows again when you are alive.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: option to keep the custom target frame visible in cursor mode; when the reticle target is cleared (e.g. opening inventory or map), the frame and its SpellCastBuffs target icons can linger with the last target's data. Optional auto-clear after 5–30 seconds (or never).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Info Panel: option to hide the panel in combat; it becomes visible again when combat ends.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: custom player and target frame bar width slider max increased from 500 to 1000.",
    "",
    -- Version Header 7.2.0.0
    "|cFFA500LuiExtended Version 7.2.0.0|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: support for new currency types (Seals, Trade Bars); settings, labels, and tooltips updated across languages. Tome Points and cache handling improved.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: furnishing vault announcements and related event handling.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: track multi versus single weekly challenges, with settings and localization (DE, FR, RU, TR, default).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t GridOverlay refactor: functionality and settings updated; new XML, bindings, Unlock/BlacklistDialog, SpellCastBuffs/UnitFrames integration, AbilityAlerts/Changelog frontend touched.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: optional hostile flag for attribute visuals.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: instanceDisplayType changed to zoneDisplayType to align with api doc.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: event callback tweaks (Collectibles, ReloadEffects, Stealth); furnishing vault and related logic.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: merge from main (PlayerToPlayer hooks, settings_tweaks); gamepad behavior adjusted.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData effects: broad updates across BarHighlight, Fake effects, Overrides, KeepUpgrade, OakenSoul, and related namespaces.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t BarHighlight: populate table on player activated (DestroFix); ActionBar cleanup and BarHighlight data/override updates.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ActionBar: nil checks and robustness.",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: artificial effect logic.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Hand of Mephala: LuiData KeepUpgrade/Override, AbilityTables, UnitNamesTable, ZoneNamesTable, and data namespace.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData AbilityTables fix.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs and UnitFrames: missing saved-variable defaults and tooltip fixes.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: debug formatting.",
    "",
    -- Version Header 7.1.4.5
    "|cFFA500LuiExtended Version 7.1.4.5|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t If using the LUIE ActionBar, you can now pick up and drag abilities between bars using mouse mode.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t If using the LUIE ActionBar with back bar enabled, equipping OakenSoul or anything that overrides the player bars temporarly will hide the backbar.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ActionBar module no longer creates highlight texture if FancyActionBar is enabled. Requested change due to double highlights.",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Lua Error on Companion level up. Reported on Github. Thanks",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Proc sound for 5/10 stack of Merciless Resolve, 4/8 stack of Crystal Fragments now play.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added a check to ActionBar.Castbar to prevent nil errors.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed manifest so Minion 4 should now work correctly.",
    "",
    -- Version Header 7.1.4.4
    "|cFFA500LuiExtended Version 7.1.4.4|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t PVP/AVA/BATTLEGROUND center screen announcement size changed from large -> small.",
    "",
    -- Version Header (PC 7.1.4.3)
    "|cFFA500LuiExtended Version 7.1.4.3|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Extended chat announcements to cover more pvp/ava events, system broadcasts, eso plus, outfit change, daily login reward, tales of tribute.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Rewrote all control creations to utilize XML, this is a performance improvement.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Split data/media into libraries: LuiMedia centralizes all media registration to prevent redundant table creation for modules that use custom media, work only needs to be done once right :) LuiData",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Moved action bar related things in combat info into a new action bar module; existing settings should be migrated.",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Resolved a long-standing Memory leak in the combat text module :eek:",
    "",
    -- Misc
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t There is probably stuff I missed in this log, but it has been an ongoing project on console, it is about time to get PC on the same version with the fixes.",
    "",
    -- Console releases that did not see a PC version
    "|c888888Console releases that did not see a PC version|r",
    "",
    -- Version 7.1.4.3 (console)
    "|cFFA500LuiExtended Version 7.1.4.3|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t more ps5 texture tweaks.",
    "",
    -- Version 7.1.4.2
    "|cFFA500LuiExtended Version 7.1.4.2|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t more ps5 texture fixes",
    "",
    -- Version 7.1.4.1
    "|cFFA500LuiExtended Version 7.1.4.1|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t hopefully fix to some ps5 textures....",
    "",
    -- Version 7.1.4.0
    "|cFFA500LuiExtended Version 7.1.4.0|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Major bug fix and changes.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Memory leak from combat text should be fixed, it was in all my test scenarios.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Movers now use x/y sliders.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t TODO: Fix movers for Combat Text panels.",
    "",
    -- Version 7.1.3.11
    "|cFFA500LuiExtended Version 7.1.3.11|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t feat: move info panel to xml.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: unitframe stuff",
    "",
    -- Version 7.1.3.9
    "|cFFA500LuiExtended Version 7.1.3.9|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: champ star pixelation on ps5",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t feat: move custom unitframe control creation code to xml.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t feat: move ability alert creation to xml and utilize object pools.",
    "",
    -- Version 7.1.3.8
    "|cFFA500LuiExtended Version 7.1.3.8|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Migrates SpellCastBuffs to an XML + metapool architecture, adds a new SynergyTracker UI, consolidates ActionBar management into the module, and updates related namespaces, settings, and event handling.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs (major refactor): Migrates UI to XML (TopLevelControls + virtual LUIE_SpellCastBuffIcon), adds mouse/tooltip handlers, grid-snap move support. Rewrites to method-based API (ZO_Object), centralizes event registration, and uses ZO_MetaPool for icon pooling/perf. Enhances prominent bars/labels, cooldown/stack handling, disguise/mount/WW logic; updates settings/invoke sites.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SynergyTracker (new UI): Adds XML-driven tracker and controller with rows, cooldown overlays, tooltips, HUD scene integration, and movement save.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ActionBar (consolidation): Merges manager into module, centralizes events/helpers, backbar handling, cooldown hook logic; removes ActionBarManager.lua.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t CastBar/Namespaces: Adjusts module names/event registrations; cleans up CombatInfo/AbilityAlerts namespace setup.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Infrastructure: Version bump, GridOverlay docs/manager polish, settings/initialization updated for method calls.",
    "",
    -- Version 7.1.3.7
    "|cFFA500LuiExtended Version 7.1.3.7|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: console errors when interacting with a player",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t NEW LOADING LOGIC FOR CONSOLE! If ESO is not in focus, LUIE will not load until it is, this prevents many CPU budget errors, if you experience this(grey unit frames/black icons) you need to port to a house or go through a door that triggers a load screen to refresh the ui without reloading.",
    "",
    -- Version 7.1.3.6
    "|cFFA500LuiExtended Version 7.1.3.6|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: synergy tracker restore placement on reload",
    "",
    -- Version 7.1.3.5
    "|cFFA500LuiExtended Version 7.1.3.5|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: Unitframes settings options",
    "",
    -- Version 7.1.3.4
    "|cFFA500LuiExtended Version 7.1.3.4|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: Adjust InfoPanel position calculation to use center coordinates instead of top-left coordinates.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: Update companion ultimate cost calculation in ActionBar module.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: Collectibles we don't have data for were showing the default unknow icon in the Chat Announcements, switched to using the games API to parse the link if we don't have the data.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t change: Swapped to using ZO_Currency_GetPlatformCurrencyIcon in Chat Announcements.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t change: buff icons are being worked.",
    "",
    -- Version 7.1.3.3
    "|cFFA500LuiExtended Version 7.1.3.3|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t more settings fixes",
    "",
    -- Version 7.1.3.2
    "|cFFA500LuiExtended Version 7.1.3.2|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fix: backbar for actionbar was not able to be enabled in the settings menu",
    "",
    -- Version 7.1.3.1
    "|cFFA500LuiExtended Version 7.1.3.1|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t settings menu rework, now uses submenus",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t edit mode should now work better, no more needing to open another menu to make the backdrop clear",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t fixed reported errors from multiple discord reports, thanks all, keep reporting.",
    "",
    -- Version 7.1.3.0
    "|cFFA500LuiExtended Version 7.1.3.0|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console settings overhaul. Many things still need tweaks. will be doing updates regularly to address issues.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.7|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Crowd Control Tracker preview window with pooled controls so players can test stun/immobilize visuals and encounter the updated charm handling in a safe space.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock mode grid overlay rebuilt as a pooled control system, wired into SpellCastBuffs and UnitFrames settings for lighter footprint and easier snapping.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Custom boss frames now read CrutchAlerts boss phase thresholds, expose a toggle in settings, and ship localized strings for supported languages.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat action bar overhaul: hotbar category validation, pooled cooldown widgets, and smarter throttling to keep cooldown displays in sync.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Group resource bars reformats their layout/spacing based on LibGroupBroadcast data so raid and small-group frames stay aligned with the new integrations.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Refactored Group Food & Drink Buffs module: localized API usage, unified data helpers, and migrated drink tracking into `LuiData/Effects` for maintenance.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Integrated LUIE icon/tooltip overrides, slash command refresh, countdown timer display, and smart anchoring with other LibGroupBroadcast widgets.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Applied inventory event filters, update throttling, and LuiData version checks to eliminate redundant refreshes and stale-data warnings.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.6|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed LAM 'Reset to Defaults' functionality across all settings panels - frame positions, dropdown selections, and panel unlock states now properly reset to their default values.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed 19 dropdown default values that were incorrectly using numeric indices instead of display strings, affecting: player frame layout, bar alignments, raid icons, global cooldown method, alert filters, icon options, bracket displays, and guild rank options.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Fixed Combat Text panel unlock checkbox inverting its state when using LAM reset (was toggling instead of setting the value directly).",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.5|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Significant CombatInfo performance optimization: eliminated redundant function calls and addon state checks that were causing frame freezes on high-buff-count scenarios (especially noticeable on Arcanist).",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Integration with LibFoodDrinkBuff: small group unit frames now display food/drink buff status icons and time remaining. Can be turned on and configured in the Unit Frames settings.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.4|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t No-healing overlay is now rendered above the shield overlay.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Shield animations are smooth again. oops.",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Ability timers can now be manually changed in the settings.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Synergy Panel, viewer for recent seen synergies.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t In-Combat unitframe border, added settings for Group and RaidGroup to have a red(by default) border around frames when in combat.",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Moved code around in the CombatInfo module. *Shouldn't break anything.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added two ZOS Method overwrites to bypass a *Private* function error when using custom icons; the error propagated when dragging a ability in the skills menu.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.3|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added small group sort by role, just like raid frames.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LibGroupBroadcast integrations, ULT icons, potion icon, dps, hps are only visible in small group frames for now, raid frames will need ui rework to fit everything in.\n Resource bars should be placed below the raid frame in a small gap if that setting is enabled.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Migrated font system to use ZOS's native ZO_CreateFontString function.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Implemented migration system with SV flags to automatically convert legacy font style values (runs once per module).",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Cleaned up obsolete font style string constants from localization files.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Consolidated settings menu font style dropdowns to use shared arrays for consistency.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.2|r",
    "",
    -- New Features
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Integration with LibGroupResources, LibGroupCombatStats, LibGroupPotionCooldowns.\nTweaks will be made, need people to test and let me know.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.1|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t \nUnitframes should now show visuals correctly; somehow in testing I didn't catch a 0-index issue, sorry all.\nLet me know in the ESOUI comments/Github if any issues remain.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.1.0.0|r",
    "",
    -- New Features
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Implemented ZOS-style coordinator architecture for Unit Attribute Visualizers.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Completely refactored UnitFrames module for improved code quality and maintainability.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Enhanced no-healing indicator with distinctive diagonal stripe pattern for better visibility.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Reduced power shield update animation duration from 250ms to 100ms for more responsive feedback.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Improved attribute visualizer module architecture with proper event handling and unit-tag filtering.",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Significant code cleanup and elimination of duplication throughout the codebase.",
    "",
    "|cFFA500LuiExtended Version 7.0.2.0|r",
    "",
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added support for 16:10 displays and Steam Deck.",
    "",
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Updated aspect ratio detection and scaling for unit frames.",
    "",
    -- Version Header
    "|cFFA500LuiExtended Version 7.0.1.0|r",
    "",
    -- New Features
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added option to use @account names instead of character names in teammate death notifications (Combat Text -> Group Member Death -> Use Account Names).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added transparency control for Info Panel (Info Panel -> Info Panel Transparency, %).",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Refactored font system to use 'LUIE Default Font' instead of 'Univers 67' across all modules for better consistency.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added initial console support and improved settings compatibility.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Various settings improvements and optimizations.",
    "",
    -- Removals
    "|cFFFF00Removed:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Group Buffs functionality. Users should now use the dedicated 'Group Buff Panels addon by code65536' instead.",
    "",
    -- Miscellaneous
    "|cFFFF00Miscellaneous:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Updated terms and license information.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t I'm sure I missed a note on some other things that changed. View the full change log on Git.",
    "",
}
-- -----------------------------------------------------------------------------
-- Hide toggle called by the menu or xml button
function LUIE.ToggleChangelog(option)
    LUIE_Changelog:ClearAnchors()
    LUIE_Changelog:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    LUIE_Changelog:SetHidden(option)
end

-- -----------------------------------------------------------------------------
-- Called on initialize
function LUIE.ChangelogScreen()
    -- concat messages into one string
    local changelog = table_concat(changelogMessages, "\n")
    -- If text start with '*' replace it with bullet texture
    changelog = StringOnlyGSUB(changelog, "%[%*%]", "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t")
    -- Set the window title
    LUIE_Changelog_Title:SetText(zo_strformat("<<1>> Changelog", LUIE.name))
    -- Set the about string
    LUIE_Changelog_About:SetText(zo_strformat("v<<1>> by <<2>>", LUIE.version, LUIE.author))
    -- Set the changelog text
    LUIE_Changelog_Text:SetText(changelog)

    -- Display the changelog if version number < current version
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].WelcomeVersion ~= LUIE.version then
        LUIE_Changelog:SetHidden(false)
    end

    -- Set version to current version
    LUIESV["Default"][GetDisplayName()]["$AccountWide"].WelcomeVersion = LUIE.version
end

-- -----------------------------------------------------------------------------
