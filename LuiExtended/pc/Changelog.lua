-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local zo_strformat = zo_strformat
local table_concat = table.concat
local MOUSE_BUTTON_INDEX_LEFT = MOUSE_BUTTON_INDEX_LEFT
local TOPLEFT = TOPLEFT
local BOTTOMLEFT = BOTTOMLEFT
local LEFT = LEFT
local RIGHT = RIGHT
local TEXT_ALIGN_LEFT = TEXT_ALIGN_LEFT
-- -----------------------------------------------------------------------------

local CHANGELOG_THEME =
{
    surface = { 0.05, 0.05, 0.07, 0.92 },
    surfaceAlt = { 0.12, 0.11, 0.14, 0.95 },
    border = { 0.35, 0.32, 0.28, 1 },
    spacing =
    {
        sm = 8,
        md = 12,
    },
    fontTitle = "ZoFontWinH2",
    fontSection = "ZoFontWinH4",
    fontBody = "ZoFontGame",
    sectionHeaderHeight = 40,
    sectionBodyPadding = 8,
}
local CHANGELOG_CONTENT_WIDTH = 830
local CHANGELOG_VERSION_HEADER_MATCH = "|cFFA500LuiExtended Version "
local CHANGELOG_SCROLL_THUMB = "EsoUI/Art/Miscellaneous/scrollbox_elevator.dds"
local CHANGELOG_SCROLL_THUMB_DISABLED = "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds"
local CHANGELOG_SCROLL_TRACK = "EsoUI/Art/Miscellaneous/scrollbox_track.dds"
local CHANGELOG_SCROLL_THUMB_WIDTH = 8
local CHANGELOG_SCROLL_THUMB_HEIGHT = 32

local CHANGELOG_SECTION_HEADER_TEMPLATE = "LUIE_Changelog_SectionHeader_Template"
local CHANGELOG_SECTION_BODY_TEMPLATE = "LUIE_Changelog_SectionBody_Template"
local changelogSectionHeaderPool
local changelogSectionBodyPool

-- -----------------------------------------------------------------------------
local changelogMessages =
{
    -- Version Header 7.2.3.0
    "|cFFA500LuiExtended Version 7.2.3.0|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Player and Target Display Power Change Overlay now default to off. A one-time migration turns the overlay off for existing saves that still had the previous default (on). Re-enable under Custom Unit Frames if you want the increased-power halo.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: When that overlay is enabled, increased power and possession animated halo textures on the custom health bar tint with the same RGBA as the health bar when LUIE applies custom frame colors.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Custom frame unit names now always use Font Size (Label) for that frame type (Player, Target, Group, Raid, Companion, Pet, Boss, AvA). Names on raid, pet, and similar layouts on the health bar no longer use Font Size (Bar) by mistake (for example name at 16 while the label slider shows 22).",
    "",
    -- Version Header 7.2.2.9
    "|cFFA500LuiExtended Version 7.2.2.9|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Adventure Zone faction reputation gains are now announced in chat as loot-style messages (with optional icon and optional total, matching Loot settings).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs (debug): Tooltip debug meta supports an overflow tooltip column so large debug dumps don’t run off-screen.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Next roll dodge prediction now tracks Dodge Fatigue stacks from buffs (and refreshes on stack changes) for more accurate predicted stamina cost.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs (debug): Debug meta now lists all Derived/Advanced stat rows; overflow continues in the secondary tooltip.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Increased Power / possession halo visuals better match the health bar (layering + bar texture/color consistency) and no longer show the animated halo in the empty part of the bar.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: Maelstrom 2H (Merciless Charge) set buff tooltip text is now correct and uses the proper dynamic description source.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData/Debug: Updated Maelstrom-related debug aura/result mappings and corrected minor label issues (for example \"HEAL ABSORBED\").",
    "",
    -- Version Header 7.2.2.8
    "|cFFA500LuiExtended Version 7.2.2.8|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Roll dodge stamina indicator on the custom player bar now follows Left to Right, Right to Left, and Center stamina bar alignment settings.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: With Center alignment, the dodge indicator uses two lines that bracket your stamina after the next dodge (the band moves inward toward the middle as stamina drops).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Roll dodge prediction includes Medium Armor Athletics dodge cost reduction (per piece of medium armor worn).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Roll dodge indicator tracks more smoothly when Custom Smooth Bar is enabled on player frames.",
    "",
    -- Version Header 7.2.2.7
    "|cFFA500LuiExtended Version 7.2.2.7|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Changelog: Moved changelog code so it would only load on pc as it does not work on console at this time.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Added more Night Market chat settings, check the settings.",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Optional next roll dodge indicator on the custom player stamina bar (PC and console, default off). A vertical line shows where your stamina would be after one dodge; it turns red if you cannot afford that dodge. Updates for Dodge Fatigue and for Expert Evasion when that champion perk is slotted on your bar.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Optional setting Show ability cast costs as drain (Incoming) (PC and console, default off). Display Resource Drain (Incoming) still shows drains from the combat log unless you turn cast-cost display on.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Fixed duplicate mitigation floating text (for example two Immune Bash lines when bashing a hard-targeted immune enemy out of range).",
    "",
    -- Version Header 7.2.2.6
    "|cFFA500LuiExtended Version 7.2.2.6|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Display Announcements — Event Zone: Night Market (PC and console). Separate chat, center-screen, and alert toggles for Daring Race, Arachnid Invasion, and Guiding Light. Still missing some; will be added when I see them.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Classified Night Market EVENT_DISPLAY_ANNOUNCEMENT lines by activity text (not whole zone 1559): Daring Race (for example Tempest earned, race objectives, Daring Race: … Complete, Void Collapse); Arachnid Invasion (invasion begins, defense complete, invasion repelled); Guiding Light (countdown, begins, complete, and reward earned lines such as Agonizing Tether or Exsanguinate).",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Display Announcement debug (when enabled) also logs category, icon path, and lifespanMS to help report new center-screen text on the ESOUI thread.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t PC settings: Font face and font style dropdowns preview each entry in the list (LuiExtended fontable_dropdown LAM control; fixed preview size, no dependency on a forked LibAddonMenu). Texture dropdowns preview status bar art (textureable_dropdown) for Unit Frames per-category appearance, Action Bar cast bar, and Buffs & Debuffs prominent progress texture.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Changing font or bar texture under a Custom Unit Frames appearance category (Player, Target, Group, etc.) reapplies only that category instead of refreshing every custom frame type on each slider or dropdown change.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text (PC): All color picker defaults in settings now include alpha so LAM Reset to Default restores full RGBA (opacity), not RGB only.",
    "",
    -- Version Header 7.2.2.5
    "|cFFA500LuiExtended Version 7.2.2.5|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Smithing and universal deconstruction (station deconstruction tab, Giladil, and LibLazyCrafting deconstruct queues such as Dolgubon's Lazy Writ Creator) now use deconstruct/receive item messages (and extract for glyphs) instead of craft/use. Destroyed gear no longer shows as \"You use.\" LibLazyCrafting provisioning writs and other active craft/improve paths still use craft/use labels.",
    "",
    -- Version Header 7.2.2.4
    "|cFFA500LuiExtended Version 7.2.2.4|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Out-of-combat and in-combat opacity sliders (0-100%) under Display Options. Affects the game action bar (`ZO_ActionBar1`, including LUIE backbar and slot overlays) and the cast bar when cast bar is enabled. PC and console.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Buffs & Debuffs (SpellCastBuffs): Out-of-combat and in-combat opacity sliders under Position and Display. Applies to each active buff/debuff container (floating top-level windows or unit-frame-locked buff/debuff regions).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Replaced single Set Transparency with separate out-of-combat and in-combat sliders (0-100%). Existing saves copy the old value to both. PC and console.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Info - Synergy Tracker: Out-of-combat and in-combat opacity sliders under Display Options (0-100%, same style as unit frames).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Info - Synergy Tracker: Display mode Icon + Cooldown (minimal) and Hidden (no HUD list; detection, sounds, blacklist, and priority overrides still run). Optional horizontal layout for minimal. Right-click synergy rows for priority (game default and 1-10) and blacklist. Minimal mode uses tiered sort (ready -> active waiting -> cooldown -> idle).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Custom frame font and bar texture are no longer one global set for every frame. Under Custom Unit Frames, Font/Texture Settings provides separate profiles for Player, Target, Group, Raid, Companion, Pet, Boss, and AvA (font, font style, label size, bar size, texture). Existing saves copy your previous global custom font/texture into all eight categories on first load. PC uses nested submenus; console uses a dedicated Font/Texture Settings section. Group broadcast overlays (combat stats, potion cooldowns, food/drink buff, group resources) use the Group profile (raid potion labels use Raid when on raid frames).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Buffs & Debuffs: Optional Display API debug on Tooltip (PC, under Tooltip Options). Hovering a buff icon can show status effect type, ability type, API buff slot, LuiData EffectOverride/CC hints, and live list-index timing overlay lines for tuning icons and tooltips.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Attribute visual updates (shield, regeneration, stat change) use coalesced power updates and cached visual state to cut redundant bar refreshes.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar / Buffs & Debuffs: Opacity sliders apply reliably after `/reloadui` (uses live `ZO_ActionBar1` at apply time; buff containers re-apply when HUD fade resets alpha). Combat state still updates OOC vs in-combat values.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Fixed duplicate weekly challenge progress lines when two identical challenges advance at once (for example four chat messages instead of two). Progress and Tracking announcements no longer double up for the same challenge slot; each slot still announces separately.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Buffs & Debuffs: Fewer duplicate buff icons when ground auras and target buff/debuff rows route to the same container (shared-container dedupe and per-container ability dedupe on refresh).",
    "",
    -- Version Header 7.2.2.3
    "|cFFA500LuiExtended Version 7.2.2.3|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SavedVariables (7.2.1.7+ split): Additional migration repair scans profile `Default` and your megaserver row (`GetWorldName()`) so module settings are not left on defaults when a second @account had an empty megaserver shell, when backups reintroduced pre-split `LUIESV` data, or when split migration finished before legacy namespaces were cleared. Pruning `LUIESV[\"Default\"][@You]` on disk now waits until that repair completes. `InstallExternalSavedVarsLegacyCompat` no longer deletes the entire on-disk `LUIESV[\"Default\"]` tree when that helper runs (which could remove other @accounts' only copy). The `LUIESV.Default` legacy read path / metatable compat for Srendarr still only loads on PC when Srendarr is enabled (not used on console).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t New slash: `/luie svstatus` prints migration flags, whether `LUIESV` still holds legacy module tables, and a quick population hint per split global (paste for support).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Support tips: Megaserver EU vs NA use separate saved-variable profile rows; switching regions can look like a reset until you configure or copy settings per megaserver (LAM Character Profile copy). Restoring backups from AutoBackup or similar should include every SavedVariables global listed in the addon manifest (`LUIESV` and all `LUIE_*_SV`), not `LUIESV` alone, and preferably while the game is closed.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Buff and debuff icon borders should look like the stock buff bar again.",
    "",
    -- Version Header 7.2.2.2
    "|cFFA500LuiExtended Version 7.2.2.2|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Prevent malformed display-name chat links (empty link payload) that could crash pChat when copying or formatting system messages. Names are normalized before building links; guild, friends, mail, group loot indexing, duel alerts, and related paths use shared helpers.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: LAM / gamepad settings no longer force unrelated custom frame top-level windows visible when changing options for another frame family; texture/font updates and per-type layout calls use the same refresh policy. Combat glow color pickers refresh glow visuals via UnitFrames.UpdateGroupCombatGlow. Reposition mode unlock still shows frames for dragging.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Group loot member index falls back to character name when unit display name is not yet available.",
    "",
    -- Version Header 7.2.2.1
    "|cFFA500LuiExtended Version 7.2.2.1|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: When Loot Mail is enabled, \"Mail received.\" and \"Mail deleted!\" are no longer shown while mail attachments are being looted (for example hireling batches via auto-mail addons). Item loot lines still print.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Fixed repeated \"You receive mail with … Gold from …\" lines after auto-looting mail and fast traveling. Mail session resets on zone load and mailbox close, inbox updates no longer refill the take queue when the UI is gone, and duplicate mail gold lines within 2.5s are suppressed.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Hireling / auto-mail loot: correct sender per attachment (FIFO queue), no pre-filled inbox queue on mailbox open, hireling names from GetMailSender when journal info is empty (fixes \"from []\"), mail item lines while the mailbox UI is not open.",
    "",
    -- Version Header 7.2.2.0
    "|cFFA500LuiExtended Version 7.2.2.0|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console settings: Smoother menu navigation when browsing module options, and options that depend on another setting now grey out or update right away without leaving the menu.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console: Changing fonts in several modules (Action Bar, Combat Info, Combat Text, Info Panel, Buffs & Debuffs, Unit Frames) is applied after you Reload UI, with a reminder in chat and in the menu - helps avoid memory issues on console.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console: When moving UI elements, position numbers and preview names (unit frames, buff windows, cast bar, combat text, alerts) are easier to read on screen.",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Quest Kill Counter Filters. Some quests show a center-screen or alert on every kill for a counter objective. Add a filter per quest so you only see the updates you care about.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiExtended settings, Chat Announcements, Quest Kill Counter Filters. Turn on Enable, enter the quest name from your journal, optional objective text if you only want one step filtered, choose Milestones (kill counts like 25, 50, 75), Hide all, or Complete only, then Add Filter.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t PC: pick a rule under Remove Filter or use Clear All Filters. Console: Manage Filters to remove a saved rule. Changes apply right away; you do not need to reload the UI.",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console - Action Bar cast bar: Turn the cast bar on/off at the top of the section; other cast bar options stay disabled until it is on. Reset Position moves the bar back, updates the position sliders, and turns off Unlock Cast Bar so the bar is not left hidden.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Reset Position works even when adjusting position from the menu, and the X/Y sliders match where the bar actually sits.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console settings: Section description text no longer highlights as if it were a setting you could change.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console - Slash Commands settings could fail to open.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console - Unit Frames: Position coordinates show again while custom frames are unlocked and you move them.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Group death notifications no longer show a missing name (for example \" died!\") when \"Use account name\" is enabled. Display name now falls back to character name, and alerts are skipped when no name is available.",
    "",
    -- Version Header 7.2.1.8
    "|cFFA500LuiExtended Version 7.2.1.8|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SavedVariables: Third-party addons that still read `LUIESV.Default[@DisplayName][\"$AccountWide\"]` (for example Srendarr checking LuiExtended unit frame options) are supported again - `Default` resolves to this session's megaserver profile (`GetWorldName()`), and module namespaces such as `UnitFrames` on that path overlay the split module globals after migration.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Character Profile copy (PC and console): Clearer settings labels and tooltips for megaserver, @account, copy source, and source character (less internal \"row / saved vars\" wording).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: \"Show Throttle Trailer\" tooltip wording updated (default and locale strings) - describes the (N) suffix on merged totals and that throttle ms sliders control combining hits, not this checkbox.",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Attempt to fix throttle ms sliders appearing to do nothing at 0 - a 0 ms setting now bypasses the merge buffer and shows each combat event immediately instead of deferring with `zo_callLater` (which still merged same-frame hits); critical damage/heal/DoT/HoT throttle times follow the same four sliders as in the menu (damage, DoT, healing, HoT) instead of separate unused `*critical` saved vars left at 200 ms.",
    "",
    -- Version Header 7.2.1.7
    "|cFFA500LuiExtended Version 7.2.1.7|r",
    "",
    -- Major change
    "|cFFFF00Major Change:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SavedVariables layout: module settings now use separate account-wide globals (`LUIE_UnitFrames_SV`, `LUIE_CombatText_SV`, `LUIE_ChatAnnouncements_SV`, `LUIE_SpellCastBuffs_SV`, `LUIE_ActionBar_SV`, `LUIE_InfoPanel_SV`, `LUIE_SlashCommands_SV`, `LUIE_CombatInfo_SV`) alongside `LUIESV` (see the addon manifest). Megaserver-specific rows use the ZO_SavedVars profile from `GetWorldName()`; legacy data under profile `Default` is migrated into the new layout on load (expect one reload after update).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t PC (LAM) and console (LibHarvens): Character Profile \"Copy Profile\" uses three controls - source megaserver profile, `@DisplayName`, then `$AccountWide` or a character row matching `LUIE.SVVer`. The copy writes that path into this session's target row for `LUIESV` and every module global above.",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Slash command `/luie debug on` - saves your current AddOns enable state, disables everything outside the LUIE debug allowlist (LuiExtended, LuiData, LuiMedia, LibMediaProvider; PC: LibAddonMenu-2.0; console: LibHarvensAddonSettings and LibConsoleDialogs), then reloads the UI.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t `/luie debug off` - restores the saved state and reloads; `/luie debug status` (or `/luie debug` alone) reports whether debug environment mode is active.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t After reload, a one-shot chat line confirms debug mode or that your addon list was restored.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Info Panel: Optional memory display on the top row (after FPS). Console shows add-on memory pool used/capacity (MB); PC shows approximate Lua heap size via collectgarbage (no forced GC on the HUD tick). Toggle under Info Panel elements; console pool fill uses the same read-only color tiers as FPS/latency when enabled.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Custom Tooltips: Updated the RU lang strings for Battle Spirit, thank you Impda.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t PC settings (LAM): FPS Limit slider maximum raised to 999 (vanilla interface settings only go up to 100)",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Info Panel: FPS readout uses `zo_round` on `GetFramerate()` and caps the displayed value at 999, matching the built-in performance meter (fixes showing one FPS lower than the game meter, for example 164 vs 165).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: Fixed custom frames rendering below in-world 3D overlays (for example survey reset marker arrows and similar icons).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: Player stamina bar XML anchor now targets the Magicka backdrop by name (matches Health to Magicka) instead of MagickaBackdrop, correcting layer inheritance for that bar.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: Custom TopLevelControls use draw tier MEDIUM instead of LOW (player, target, group, raid, pet, companion, boss, Ava target).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: Out-of-combat alpha refresh no longer skips the first apply when combat state was still unset (idle coerced to boolean before cache compare).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: LAM - `CustomFramesApplyInCombat(force)` lets menu-driven alpha and hide-buff-OOC changes reapply immediately (idle-state cache still used for combat/power events when `force` is off); boss/companion/pet opacity sliders use the forced path too.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: LAM - player/target OOC and IC transparency sliders no longer call `CustomFramesApplyLayoutPlayer`, so they no longer unhide the other custom TLWs as a side effect.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: LAM - layout split into `CustomFramesApplyLayoutPlayerFrame`, `CustomFramesApplyLayoutReticleoverFrame`, and `CustomFramesApplyLayoutAvaPlayerTargetFrame` (aggregate `CustomFramesApplyLayoutPlayer` unchanged for full init); PC and console settings call the matching handler so bar and chrome tweaks only preview the frame you are editing.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: `CustomFramesReloadControlsMenu` takes separate reticle vs AvA unhide arguments so player name display vs target name display does not pop the wrong custom TLW.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: Custom reticle target - AvA rank icon is not shown when `GetUnitAvARank` is zero (no blank texture from settings-only layout); after reticle layout, `CustomFramesLayoutRefreshReticleoverAvaRankOnly` updates rank chrome without running full `UpdateStaticControls` (avoids buff/debuff anchor clashes).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Opening a container (including from inventory) no longer prints looted gold before the \"You empty [container]\" line; loot gold is held until that line prints, then flushes.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Mail category Take All - correct sender per mail (no double dequeue / stale target), per-category sender queue, dedicated delayed loot lines (no wrong merge by item id), and flush order so gold and attachments match the mail you took.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Batched crafting \"You use\" lines list consumed materials in station order - smithing (material, then style, then trait), provisioning (primary food or drink base before additives and rare seasonings), and alchemy (potion or poison base before reagents) - instead of sorting by item id.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Attempt to fix rare group-join chat lines that showed raw gamepad name-icon markup (`gp_charNameIcon`) and broken display links when someone else joined while gamepad-preferred UI was active or after keyboard/gamepad UI switching; join messages now build name links from raw event names instead of ZO_GetPrimary/SecondaryPlayerName formatted strings.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: When ACTION_RESULT_POWER_DRAIN never fires on EVENT_COMBAT_EVENT, ability costs can still show as incoming resource drain - EVENT_ACTION_SLOT_ABILITY_USED is matched to the next matching player EVENT_POWER_UPDATE decrease (magicka, stamina, ultimate via COMBAT_MECHANIC_FLAGS_*), incoming drain toggles and blacklist apply, and a late native POWER_DRAIN for the same amount is deduped so you do not get two lines.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Inferred drain no longer attributes unrelated pool ticks (for example sprint stamina) to a bar ability whose `GetAbilityCost` for that pool is zero or different - expected costs come from `GetCurrentChainedAbility` + `GetAbilityCost`, each new slot use clears the prior pending correlation, and the power drop must match within a small tolerance.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Death and Points Alliance listeners no longer treat the first callback argument as `eventId` - `CombatTextEventListener:RegisterForEvent` already strips `eventCode`, so group death alerts and alliance-point SCT use the correct payload again.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Points Champion - `EVENT_CHAMPION_POINT_UPDATE` payload `(unitTag, oldChampionPoints, currentChampionPoints)` with player filter; `POINT` callbacks from the champion listener are now wired to the point panel viewer (same bug class as missing wiring for experience); cap detection uses `CanUnitGainChampionPoints` instead of raw CP count vs 3600.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Resource energize/drain gating uses `BitAnd` on `COMBAT_MECHANIC_FLAGS_*` (power type is a bitfield). Self-target `POWER_ENERGIZE` / `POWER_DRAIN` is shown on the outgoing panel with outgoing toggles, while incoming energize/drain toggles are merged for that case so one-sided settings still show costs; `REGISTER_FILTER_IS_ERROR` false on combat event registrations.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Event viewer - energize ultimate vs normal format uses bit checks; drain colors read `drainMagicka` / `drainStamina` (and related flags); cloud/ellipse/scroll/hybrid viewers pass absolute drain amounts through `AbbreviateNumber` so the default \"-%a\" format does not double the minus when `hitValue` is negative.",
    "",
    -- Version Header 7.2.1.6
    "|cFFA500LuiExtended Version 7.2.1.6|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Many buff tooltips now use the game's current skill description instead of outdated fixed text. Custom text still applies where we intentionally override (for example Brace, Sneak, champion skills, and armor passives).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: With Custom Tooltips turned off, morph-related buff tooltips still apply correctly instead of being wiped by the default path.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t InfoPanel: Internal cleanup only - on-screen behavior should match what you're used to.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Tooltips: Minor behind-the-scenes tidy-up for damage-type wording on abilities.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Added support for Tonic of Portent Favor (shows like other XP-style buffs with correct icon and tooltip).",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: When several enchanting runes are announced at once, they list in the same order as at an enchanting station (potency, then essence, then aspect).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ActionBar highlights: Templar Cleansing Ritual morphs (base, Ritual of Retribution, Extended Ritual) keep reliable duration tracking on the bar.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Igneous Weapons: removed an extra Major Sorcery bundle buff so you don't see two overlapping Sorcery icons from that skill line.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Molten Armaments: bundle tooltip matches the morph description; Sneak stealth buff uses up-to-date sneak text and avoids duplicate sneak rows when stealth is tracked.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Mirage: Extra Buffs no longer shows a duplicate fake combat buff next to the real morph aura.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Siphoning Attacks (bundle and morph); Feral, Eternal, and Wild Guardian; Inferno / Incinerate / Cauterize aura buffs - tooltips aligned with the skills window.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t InfoPanel: Backpack space (used / total) updates reliably after destroying items, after large inventory syncs, and when materials move into the craft bag.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Test Font and Test Animation in settings now dispatch preview events on the combat event listener instead of the global callback manager, so preview text shows again (PC LAM; console animation test).",
    "",
    -- Version Header 7.2.1.5
    "|cFFA500LuiExtended Version 7.2.1.5|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t revert test code. thank you all who participated.",
    "",
    -- Version Header 7.2.1.4
    "|cFFA500LuiExtended Version 7.2.1.4|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t GamePass: Swapped to ZO_IsConsoleOrGameCoreUI.",
    "",
    -- Version Header 7.2.1.3
    "|cFFA500LuiExtended Version 7.2.1.3|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ActionBar: when Fancy Action Bar (FAB/FAB+) is loaded, companion quickslot re-anchoring is skipped so FAB's post-bar-swap layout is not overwritten (fixes quickslot jumping when using both addons).",
    "",
    -- Version Header 7.2.1.2
    "|cFFA500LuiExtended Version 7.2.1.2|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t `user:/AddOns/LuiExtended/modules/UnitFrames/UnitFrames.lua:424: attempt to index a nil value`",
    "",
    -- Version Header 7.2.1.1
    "|cFFA500LuiExtended Version 7.2.1.1|r",
    "",
    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock (PC): Night Market favor counter - frame mover matches the real counter again instead of an oversized box.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock (PC): turning on UI unlock no longer shows the favor mover across the whole screen the first time (before you move it or reload).",
    "",
    -- Version Header 7.2.1.0
    "|cFFA500LuiExtended Version 7.2.1.0|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ActionBar: companion ultimate tracking - optional value and percent labels on the companion ultimate slot (font, colors, vertical offset, hide when full); quickslot/keybind layout follows ZOS companion anchor chain when the companion button is shown.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t CombatInfo (console): reset-to-defaults restores the module's saved settings from defaults and refreshes Ability Alerts and Crowd Control Tracker UI.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames (debug): new `/luiufall` - toggles every custom-frame preview at once, temporarily enables frame-move mode for layout, and restores the previous unlock state when turned off.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: custom frame color handling updated to respect saved alpha values.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: CrutchAlerts Boss Health Bar integration - uses the current API (including per-boss `boss1`/`boss2` threshold tables when the encounter provides them); stack-level percent labels above the boss block and rotated mechanic names below; shared thresholds draw a single line through all visible boss bars; listens for `BossHealthBar.RegisterThresholdsChangeListener` so programmatic overrides refresh markers; ACTIVE / IMMINENT / PASSED tinting matches Crutch bar colors and updates as boss HP changes (rounding follows Crutch `useFloorRounding` when Crutch is loaded).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Settings (PC & console): boss threshold marker anchor dropdowns removed (obsolete with the stack layout); X/Y controls are a horizontal nudge for both label rows and shared vertical padding from the bar block.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t DependsOn: LuiData minimum version raised to match bundled data (see manifest).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: Battle Spirit custom tooltip strings updated for U49 (33% healing reduction when 8 or more HoTs are active; Cyrodiil includes the ability-range line, Imperial City does not). German and French strings pulled from live client text; Russian Battle Spirit lines remain English until a verified localization export is available.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Internal: several modules now use ZO math globals (`zo_floor`, `zo_max`, `zo_min`, etc.) instead of `math.*` for consistency with ESO UI code.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames (debug): slash-command previews for individual frames - `/luiufplayer`, `/luiuftar`, `/luiufsm`, `/luiufraid`, `/luiufpet`, `/luiufboss`, `/luiufcomp`, `/luiufava` show enabled custom frames with live player power and labels.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Settings (PC & console): custom frame unlock checkbox and grid-snap overlay refresh use `UnitFrames.CustomFramesMovingState` (removed duplicate local moving flag).",
    "",

    -- Fixed
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: artificial effect handling aligned with the live id table (0 ESO Plus through 8 Solo Queue AP bonus). Imperial City Battle Spirit (id 3) is shown with the IC tooltip instead of being treated as Battleground Deserter; LFG (id 2) uses the LFG tooltip; deserter cooldown logic applies to id 4 only; Underdog / Solo Queue entries (5–8) keep API timing instead of inheriting the old id-3 behavior.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: Looking For Group artificial-effect display name now reads `GetArtificialEffectInfo(2)` (was incorrectly using index 1).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Stats screen (keyboard & gamepad): optional artificial-effect Ability ID debug lines updated to the same id map as SpellCastBuffs.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: boss threshold markers and mechanic labels align to the health bar (labels were anchored from the bar center horizontally; lines used the left edge).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: boss threshold markers clear when no boss units exist (wipe / despawn) instead of lingering on screen.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t UnitFrames: custom group/raid frame repositioning - member controls have mouse disabled while moving so the top-level window reliably receives drags.",
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
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action bar: Flame Lash / Power Lash proc icon flicker (GitHub #379) - `SetupActionSlot` no longer applies `BarIdOverride` for proc/base pairs flagged in `IsAbilityProc` / `BaseForAbilityProc` (global `actionbutton` hook; disabling the ActionBar module alone did not avoid it).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action bar: Power Lash stack buff (abilityId 34117, U41+ 5x / 20s) - bar highlight tracks combat/buff data via `combatTrack`, toggled labels show stacks and timer; stacks decrement on Power Lash cast (`OnAbilityUsed`), timer and overlay clear when stacks reach zero; sync from `EVENT_EFFECT_CHANGED` / combat when ZOS reports zero stacks.",
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
--- @param messages table
--- @return { title: string, lines: string[] }[]
local function ParseChangelogVersionSections(messages)
    local sections = {}
    local current
    for i = 1, #messages do
        local line = messages[i]
        if zo_strfind(line, CHANGELOG_VERSION_HEADER_MATCH, 1, true) then
            current = { title = line, lines = {} }
            sections[#sections + 1] = current
        elseif current then
            current.lines[#current.lines + 1] = line
        end
    end
    return sections
end

local function FormatChangelogSectionBody(lines)
    local bodyLines = {}
    for lineIndex = 1, #lines do
        local line = lines[lineIndex]
        if line ~= "" then
            bodyLines[#bodyLines + 1] = StringOnlyGSUB(line, "%[%*%]", "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t")
        end
    end
    return table_concat(bodyLines, "\n")
end

local function GetChangelogVersionDisplayTitle(coloredTitle)
    local plain = coloredTitle:gsub("|c%x+", ""):gsub("|r", "")
    local version = zo_strmatch(plain, "Version%s+([%d%.]+)")
    if version then
        return "Version " .. version
    end
    return plain
end

local function ApplyChangelogBackdrop(backdrop, variant)
    if not backdrop then
        return
    end
    local colors = CHANGELOG_THEME[variant] or CHANGELOG_THEME.surface
    backdrop:SetCenterColor(colors[1], colors[2], colors[3], colors[4])
    local border = CHANGELOG_THEME.border
    backdrop:SetEdgeColor(border[1], border[2], border[3], border[4])
end

local function ApplyChangelogScrollTheme()
    local scrollContainer = LUIE_Changelog_Container
    local scrollBar = LUIE_Changelog_ContainerScrollBar
    if not scrollBar then
        return
    end

    if scrollContainer then
        ZO_Scroll_SetUseFadeGradient(scrollContainer, false)
    end

    scrollBar:SetThumbTexture(CHANGELOG_SCROLL_THUMB, CHANGELOG_SCROLL_THUMB_DISABLED, nil, CHANGELOG_SCROLL_THUMB_WIDTH, CHANGELOG_SCROLL_THUMB_HEIGHT)

    scrollBar:SetBackgroundTopTexture(CHANGELOG_SCROLL_TRACK, 0, 0, 1, 1)
    scrollBar:SetBackgroundMiddleTexture(CHANGELOG_SCROLL_TRACK, 0, 0, 1, 1)
    scrollBar:SetBackgroundBottomTexture(CHANGELOG_SCROLL_TRACK, 0, 0, 1, 1)

    local track = CHANGELOG_THEME.surfaceAlt
    scrollBar:SetColor(track[1], track[2], track[3], track[4])

    local accentR, accentG, accentB, accentA = ZO_SELECTED_TEXT:UnpackRGBA()
    local thumb = scrollBar:GetThumbTextureControl()
    if thumb then
        thumb:SetColor(accentR, accentG, accentB, accentA)
    end

    local thumbMunge = scrollBar:GetNamedChild("ThumbMunge")
    if thumbMunge then
        thumbMunge:SetHidden(true)
    end
end

local function ApplyChangelogWindowTheme()
    ApplyChangelogBackdrop(LUIE_Changelog_Background, "surface")
    ApplyChangelogBackdrop(LUIE_Changelog_TitleBarBg, "surfaceAlt")

    local titleR, titleG, titleB, titleA = ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA()
    LUIE_Changelog_Title:SetColor(titleR, titleG, titleB, titleA)

    local aboutR, aboutG, aboutB, aboutA = ZO_DEFAULT_DISABLED_COLOR:UnpackRGBA()
    LUIE_Changelog_About:SetColor(aboutR, aboutG, aboutB, aboutA)

    ApplyChangelogScrollTheme()
end

local function EnsureChangelogSectionPools(scrollChild)
    if not changelogSectionHeaderPool then
        changelogSectionHeaderPool = ZO_ControlPool:New(CHANGELOG_SECTION_HEADER_TEMPLATE, scrollChild, "SecHdr")
        changelogSectionHeaderPool:SetCustomResetBehavior(function (header)
            header.treeNode = nil
            header.treeView = nil
            header.titleLabel = nil
            header.toggleBtn = nil
            header.sectionLines = nil
            header.bodyWrap = nil
            header.bodyPoolKey = nil
            header.bodyNode = nil
        end)
    end
    if not changelogSectionBodyPool then
        changelogSectionBodyPool = ZO_ControlPool:New(CHANGELOG_SECTION_BODY_TEMPLATE, scrollChild, "SecBody")
        changelogSectionBodyPool:SetCustomResetBehavior(function (wrap)
            wrap.bodyLabel = nil
        end)
    end
end

local function SetupChangelogSectionHeader(header, title, expanded)
    ApplyChangelogBackdrop(header:GetNamedChild("Bg"), "surfaceAlt")

    local titleLabel = header:GetNamedChild("Title")
    titleLabel:SetText(title)
    local accentR, accentG, accentB, accentA = ZO_SELECTED_TEXT:UnpackRGBA()
    titleLabel:SetColor(accentR, accentG, accentB, accentA)

    local toggleBtn = header:GetNamedChild("Toggle")
    toggleBtn:SetText(expanded and "-" or "+")

    header.titleLabel = titleLabel
    header.toggleBtn = toggleBtn
end

local function SetupChangelogSectionBody(wrap, lines)
    local bodyWidth = CHANGELOG_CONTENT_WIDTH - CHANGELOG_THEME.sectionBodyPadding * 2
    local bodyText = FormatChangelogSectionBody(lines)

    wrap:SetWidth(CHANGELOG_CONTENT_WIDTH)

    local bodyBg = wrap:GetNamedChild("Bg")
    ApplyChangelogBackdrop(bodyBg, "surface")

    local label = wrap:GetNamedChild("Text")
    label:SetWidth(bodyWidth)
    label:SetText(bodyText)
    local bodyR, bodyG, bodyB, bodyA = ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA()
    label:SetColor(bodyR, bodyG, bodyB, bodyA)

    local pad = CHANGELOG_THEME.sectionBodyPadding
    local _, textHeight = label:GetTextDimensions()
    local wrapHeight = textHeight + pad * 2
    label:SetHeight(textHeight)
    wrap:SetHeight(wrapHeight)
    bodyBg:SetHeight(wrapHeight)

    wrap.bodyLabel = label
end

local function SetChangelogSectionExpanded(header, expanded)
    if header.toggleBtn then
        header.toggleBtn:SetText(expanded and "-" or "+")
    end
end

local function RemoveChangelogControlFromList(controls, control)
    for controlIndex = #controls, 1, -1 do
        if controls[controlIndex] == control then
            table.remove(controls, controlIndex)
            return
        end
    end
end

local function AttachChangelogSectionBody(header, headerNode, tree, controls)
    if header.bodyNode or not header.sectionLines then
        return
    end

    local bodyWrap, poolKey = changelogSectionBodyPool:AcquireObject()
    SetupChangelogSectionBody(bodyWrap, header.sectionLines)
    header.bodyWrap = bodyWrap
    header.bodyPoolKey = poolKey
    header.bodyNode = tree:AddChild(headerNode, bodyWrap, CHANGELOG_THEME.spacing.md)
    controls[#controls + 1] = bodyWrap
end

local function DetachChangelogSectionBody(header, tree, controls)
    if not header.bodyNode then
        return
    end

    tree:RemoveNode(header.bodyNode)
    if header.bodyWrap then
        RemoveChangelogControlFromList(controls, header.bodyWrap)
    end
    if header.bodyPoolKey then
        changelogSectionBodyPool:ReleaseObject(header.bodyPoolKey)
    end
    header.bodyWrap = nil
    header.bodyPoolKey = nil
    header.bodyNode = nil
end

local function ReleaseChangelogTreeUI()
    if LUIE.changelogTree then
        LUIE.changelogTree:Clear()
    end
    if changelogSectionHeaderPool then
        changelogSectionHeaderPool:ReleaseAllObjects()
    end
    if changelogSectionBodyPool then
        changelogSectionBodyPool:ReleaseAllObjects()
    end
    LUIE.changelogControls = {}
end

local function UpdateChangelogScrollChildHeight(scrollChild, controls)
    local maxBottom = 0
    for controlIndex = 1, #controls do
        local control = controls[controlIndex]
        if not control:IsHidden() then
            local bottom = control:GetTop() + control:GetHeight()
            maxBottom = zo_max(maxBottom, bottom)
        end
    end
    scrollChild:SetHeight(zo_max(400, maxBottom - scrollChild:GetTop() + 12))
end

local function BuildChangelogTreeUI()
    local scrollChild = LUIE_Changelog_ContainerScrollChild
    if not scrollChild then
        return
    end

    ReleaseChangelogTreeUI()

    local sections = ParseChangelogVersionSections(changelogMessages)
    if #sections == 0 then
        return
    end

    EnsureChangelogSectionPools(scrollChild)

    local treeAnchor = ZO_Anchor:New(TOPLEFT, scrollChild, TOPLEFT, 4, 4)
    local tree = ZO_TreeControl:New(treeAnchor, 14, 8)
    tree:SetRelativePoint(BOTTOMLEFT)
    LUIE.changelogTree = tree

    local lastHeaderNode
    LUIE.changelogControls = {}
    local controls = LUIE.changelogControls

    for sectionIndex = 1, #sections do
        local section = sections[sectionIndex]
        local openByDefault = sectionIndex == 1
        local displayTitle = GetChangelogVersionDisplayTitle(section.title)

        local header = changelogSectionHeaderPool:AcquireObject(sectionIndex)
        SetupChangelogSectionHeader(header, displayTitle, openByDefault)

        local headerNode
        if lastHeaderNode == nil then
            headerNode = tree:AddChild(nil, header)
        else
            headerNode = tree:AddSibling(lastHeaderNode, header)
        end
        lastHeaderNode = headerNode

        header.treeNode = headerNode
        header.treeView = tree
        header.sectionLines = section.lines

        if not openByDefault then
            headerNode:ToggleExpanded(false)
        end
        SetChangelogSectionExpanded(header, openByDefault)

        local function toggleSection()
            if header.treeNode then
                header.treeNode:ToggleExpanded()
            end
        end

        headerNode:SetExpandedCallback(function (node, expanded)
            local sectionHeader = node:GetControl()
            SetChangelogSectionExpanded(sectionHeader, expanded)
            if expanded then
                AttachChangelogSectionBody(sectionHeader, node, tree, controls)
            else
                DetachChangelogSectionBody(sectionHeader, tree, controls)
            end
            tree:Update()
            UpdateChangelogScrollChildHeight(scrollChild, controls)
        end)

        header:SetHandler("OnMouseUp", function (_, button, upInside)
            if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
                toggleSection()
            end
        end)

        header.toggleBtn:SetHandler("OnMouseUp", function (_, button, upInside)
            if upInside and button == MOUSE_BUTTON_INDEX_LEFT then
                toggleSection()
            end
        end)

        controls[#controls + 1] = header

        if openByDefault then
            AttachChangelogSectionBody(header, headerNode, tree, controls)
        end
    end

    tree:Update()
    UpdateChangelogScrollChildHeight(scrollChild, controls)
end

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
    ApplyChangelogWindowTheme()
    LUIE_Changelog_Title:SetText(zo_strformat("<<1>> Changelog", LUIE.name))
    LUIE_Changelog_About:SetText(zo_strformat("v<<1>> by <<2>>", LUIE.version, LUIE.author))
    BuildChangelogTreeUI()

    -- Display the changelog if version number < current version
    if LUIE.SV.WelcomeVersion ~= LUIE.version then
        LUIE_Changelog:SetHidden(false)
    end

    -- Set version to current version
    LUIE.SV.WelcomeVersion = LUIE.version
end

-- -----------------------------------------------------------------------------
