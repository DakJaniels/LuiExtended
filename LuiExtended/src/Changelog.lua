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
    -- Version Header 7.1.4.5
    "|cFFA500LuiExtended Version 7.1.4.5|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
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
