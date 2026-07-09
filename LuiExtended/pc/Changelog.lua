--- @diagnostic disable: undefined-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
--- @field changelogManager LUIE_Changelog_Manager?
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local zo_strformat = zo_strformat
local table_concat = table.concat
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
local CHANGELOG_TREE_INSET_X = 8
local CHANGELOG_SCROLL_THUMB_WIDTH = 8
local CHANGELOG_SCROLLBAR_GUTTER_FALLBACK = CHANGELOG_SCROLL_THUMB_WIDTH + 8
local CHANGELOG_SECTION_BODY_TREE_INDENT = CHANGELOG_THEME.spacing.md
local CHANGELOG_SECTION_BODY_LABEL_PAD_X = 16
local CHANGELOG_SECTION_BODY_HEIGHT_SLACK = 6
local CHANGELOG_VERSION_HEADER_MATCH = "|cFFA500LuiExtended Version "
local CHANGELOG_SCROLL_THUMB = "EsoUI/Art/Miscellaneous/scrollbox_elevator.dds"
local CHANGELOG_SCROLL_THUMB_DISABLED = "EsoUI/Art/Miscellaneous/scrollbox_elevator_disabled.dds"
local CHANGELOG_SCROLL_TRACK = "EsoUI/Art/Miscellaneous/scrollbox_track.dds"
local CHANGELOG_SCROLL_THUMB_HEIGHT = 32

local CHANGELOG_SECTION_HEADER_TEMPLATE = "LUIE_Changelog_SectionHeader_Template"
local CHANGELOG_SECTION_BODY_TEMPLATE = "LUIE_Changelog_SectionBody_Template"
local CHANGELOG_LAYOUT_UPDATE_NAME = "LUIE_ChangelogLayoutFinalize"
local LUIE_CHANGELOG_SCENE_NAME = "LUIE_Changelog"

-- -----------------------------------------------------------------------------
local changelogMessages =
{
    -- Version Header 7.2.6.2
    "|cFFA500LuiExtended Version 7.2.6.2|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Optional notifications when you save or equip an armory build (chat, center-screen message, and/or alert), with customizable message color, under Notify settings.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Outfit equip notifications no longer error when the game reports success without an equipped outfit index.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Bloodthorn Cultist Outfit disguise shows the correct buff icon and tooltip.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Disguise enter and exit messages use the correct costume-specific wording for supported disguises, including Bloodthorn Cultist Outfit.",
    "",
    -- Version Header 7.2.6.1
    "|cFFA500LuiExtended Version 7.2.6.1|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Active assistant buff icons now use the game's collectible art when no custom icon is configured, so newly added assistants display correctly.",
    "",
    -- Version Header 7.2.6.0
    "|cFFA500LuiExtended Version 7.2.6.0|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Custom player completely hide Magicka or Stamina bar no longer leaves a stray bar at the frame corner; hide-bar toggles apply immediately.",
    "",
    -- Version Header 7.2.5.9
    "|cFFA500LuiExtended Version 7.2.5.9|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Champion and Level info on custom target frame should now refresh properly, it was only being updated if the toggle for overland difficulty icons were enabled.",
    "",
    -- Version Header 7.2.5.8
    "|cFFA500LuiExtended Version 7.2.5.8|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Text: Optional |cFFFFFFShow Ability Icon Frame|r and |cFFFFFFColor Icon Frame|r (PC) on outgoing combat text, with frames around ability icons (round for passives, square for actives). On PC, |cFFFFFFColor Icon Frame|r tints the frame using colors sampled from each ability icon; otherwise the frame uses the default white style. Console: |cFFFFFFShow Ability Icon Frame|r only.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console: LUIE messages appear in the gamepad chat log; unsupported chat links no longer cause errors when clicked.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: On the default target frame, veterancy rank and friend/guild/ignored icons stay aligned when rank or social icons show or hide.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Group DPS/HPS labels show during combat only, then hide shortly after combat ends so old values are not left on screen.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Overland difficulty icon on custom frames only when the game would show difficulty above normal (same as default nameplates).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Info: Ability alerts fade out smoothly after the cast finishes; alert icon borders and fade behavior improved.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Skill ability experience announcements no longer fire for passives, crafted abilities, or abilities already at max rank.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console: Unit Frames health number format dropdowns display and save correctly again.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console: Toggling Action Bar bar labels no longer turns on the game's built-in action bar ability timers setting.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t PC: Unlock Default UI Frames: player interaction prompt sizing corrected.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t General stability and performance improvements...",
    "",
    -- Version Header 7.2.5.7
    "|cFFA500LuiExtended Version 7.2.5.7|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Custom target and custom small group frames: optional friend, guild, and ignored icons (separate toggles).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar / LuiData: Cyrodiil Vengeance bag items (siege deployables, repair kit, and related gear): cast bar times, ability and buff data, and custom tooltips.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Group loot messages now respect |cFFFFFFPlayer Name Display Method|r (for example @ UserID), including on localized game clients.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Achievement updates and ignored achievement categories resolve the correct category again.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Cast bar duration is more reliable for some abilities when timing comes from combat event data.",
    "",
    -- Version Header 7.2.5.6
    "|cFFA500LuiExtended Version 7.2.5.6|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Optional announcements when an individual ability gains experience (for example from quest rewards). Per skill line under Skills: chat message and/or alert, optional icon, optional progress toward the next ability rank, and a minimum gain filter.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Changelog (PC): The version welcome window opens after you enter the world (load screen) instead of during addon load; closing the window marks that version as seen.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: |cFFFFFFQuick Hide Dead|r sub-option label and tooltip clarified.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Default target frame: health value and percentage no longer overlap the target's level and name text.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Default target frame (|cFFFFFFUse Extender|r): veterancy rank icon spacing next to the alliance rank icon improved for wide rank art.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Custom player, target, and group frames: Top Info row layout improved (level, champion points, difficulty icons, and name alignment; clearer reticle target display).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: |cFFFFFFReset Position|r for the cast bar correctly turns off cast bar move mode so the bar is not left in a bad state.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Console: Unit Frames and Combat Text settings dropdown options display and save correctly again.",
    "",
    -- Version Header 7.2.5.5
    "|cFFA500LuiExtended Version 7.2.5.5|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Default Unit Frames -> Default TARGET Frame with Use Extender option now shows Veterancy Rank Icon to the right of the Alliance Rank Icon.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t General stability and performance improvements...",
    "",
    -- Version Header 7.2.5.4
    "|cFFA500LuiExtended Version 7.2.5.4|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Ultimate now shows cost instead of out of 500.\n While in werewolf form, the ultimate count reflects your current fury count out of 1000.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Changed the base draw tier of unitframes so promts will now be able to draw on top.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Disabled tooltips for future me to look into fixing :)",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t General stability and performance improvements...",
    "",
    -- Version Header 7.2.5.3
    "|cFFA500LuiExtended Version 7.2.5.3|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Info: Block indicator remaining-block count uses a shadow label and vertical offset on the shield art for clearer readability.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Pin mirror and waypoint sync run deferred work when the world map unblocks; map reload failures no longer leave gameplay pin tickers stuck.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Group invite response when you are already in a group now names the inviter correctly (matches ZOS alert handler argument order).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Custom AvA player target frame shows only for a hostile living player on reticleover when AvA target frames are enabled; TopInfo layout refreshes with frame visibility.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: With |cFFFFFFLock position to unit frames|r, player/target out-of-combat and in-combat opacity from Unit Frames applies to buff and debuff icons; SpellCastBuffs container alpha no longer overrides those regions.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: |cFFFFFFShow Border Cooldown|r radial sweep only on timed buffs; permanent effects no longer show a cooldown layer over the icon (inset frame unchanged).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: When locked to unit frames, icon art, borders, inset panel, and radial cooldown tint fade together at OOC/INC opacity (per-icon alpha; avoids crushed or popped chrome).",
    "",
    -- Version Header 7.2.5.2
    "|cFFA500LuiExtended Version 7.2.5.2|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Removed ZO unit frame suppression (runtime hide/release/unregister of vanilla player, target, group, and companion UI). Default hide behavior is again init-time and matches pre-7.2.5 patterns.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Default Unit Frames dropdowns are back to three choices (Disable, Do nothing, Use Extender). Removed |cFFFFFFDisable + Unregister ZOS Events|r and related strings.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Existing saves from 7.2.5.0/7.2.5.1 four-option values are mapped at load to the three-option behavior without rewriting saved variables.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Default PLAYER |cFFFFFFDisable|r now hides vanilla player attribute bars after custom frames are built, on player activated, and when the dropdown changes (fixes bars still visible when custom player frames are enabled).",
    "",
    -- Version Header 7.2.5.1
    "|cFFA500LuiExtended Version 7.2.5.1|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Restored pre-7.2.5 behavior for existing Default Unit Frames saved values (read-time legacy decode until you re-select a dropdown to store the new four-option scheme).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Fixed compass boss health bars and Extender / Do nothing modes misbehaving after the 7.2.5.0 Default Frames dropdown change.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Re-show default player attribute bars when Default PLAYER Frame no longer uses a hide-vanilla mode; clear group/raid disable state when group suppression is released.",
    "",
    -- Version Header 7.2.5.0
    "|cFFA500LuiExtended Version 7.2.5.0|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Default Unit Frames dropdowns add |cFFFFFFDisable + Unregister ZOS Events|r as a fourth choice alongside Disable, Do nothing, and Use Extender (per-slot hide vs unregister; applies without UI reload when changed in settings).",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Fixed UI error when updating default group Extender frames on title or rank events (TopInfo overland icon on frames without TopInfo controls).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Target champion point and level display on the default target frame refresh on title, rank, and level events when vanilla target UI is visible.",
    "",
    -- Version Header 7.2.4.9
    "|cFFA500LuiExtended Version 7.2.4.9|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: |cFFFFFFShow Global Cooldown|r now updates cooldown visuals on the LUIE backbar row as well as the active bar.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Backbar base-game activation (proc) glow syncs slot use-failure state and only listens to inactive-hotbar slot/effect events.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Inventory loot and bag updates refactored into dedicated handlers (bag, bank, craft, fence, guild bank, item delay/formatting).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Removed |cFFFFFFCamera Wedge|r scale setting from PC and console settings.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Native HUD player pip scaling and visibility when following the minimap vs when attached to the world map.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Clarified |cFFFFFFMoving pins (ms)|r / moving pin refresh descriptions (de, fr, ru, zh).",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Fixed flickering when the base game |cFFFFFFAbility Bar|r is set to |cFFFFFFAutomatic|r (LUIE no longer overrides ZOS HUD fade alpha on |cFFFFFFZO_ActionBar1|r).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Backbar proc glow no longer uses invalid offset slot ids when cooldown updates refresh activation highlights.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Fixed inventory-related event registration across split inventory modules.",
    "",
    -- Version Header 7.2.4.8
    "|cFFA500LuiExtended Version 7.2.4.8|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: |cFFFFFFShow during Death Recap|r visibility toggle under Visibility.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: |cFFFFFFPlayer Pip Color|r and |cFFFFFFCamera Wedge Color|r pickers under Appearance.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: |cFFFFFFZone Name Font|r face, size, and style submenu when |cFFFFFFShow Zone Name|r is enabled (PC).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: |cFFFFFFPin Updates|r sliders for |cFFFFFFMoving pins (ms)|r and |cFFFFFFPin hover (ms)|r under Advanced.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap (console): |cFFFFFFFrame Layout|r with |cFFFFFFShow Map Now|r, bottom-right position offsets, and |cFFFFFFFrame Width|r / |cFFFFFFFrame Height|r (height follows width when |cFFFFFFKeep Square Aspect|r is on); settings reorganized into sections.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: When |cFFFFFFShow Zoom Buttons|r is enabled, zoom plus/minus fade in on map hover.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: |cFFFFFFKeep Square Aspect|r resize keeps a square while respecting whether you dragged width or height.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Pin mouseover and sticky-pin selection on the HUD minimap; mouseover lists update before map clicks and on the |cFFFFFFPin hover (ms)|r refresh setting.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Improved map ping handling, objective/POI pin sync, and LUIE waypoint overlay refresh after native pin updates.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: With |cFFFFFFWaypoint Requires Shift|r, Shift+click can clear the player waypoint on the minimap.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap / Info Panel: |cFFFFFFAnchor InfoPanel to MiniMap|r saves and restores the Info Panel anchor when you turn anchoring off.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap (PC): LibAddonMenu settings grouped into submenus (Zoom & Map, Visibility, Context Zoom, Appearance, Advanced).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Keybind display names for minimap actions in Settings → Controls; MiniMap strings refreshed (de, fr, ru, zh).",
    "",
    -- Version Header 7.2.4.7
    "|cFFA500LuiExtended Version 7.2.4.7|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t |cFFFFFFMiniMap (BETA)|r: Optional HUD minimap module. Enable under Module Settings on the main LuiExtended panel, then reload UI; configure under LuiExtended → MiniMap (BETA). Zoom (default, subzone, dungeon, battleground, mounted), follow player, lock position and size, per-category pin scales, visibility rules (HUD, combat, looting, mounted, housing, draw tier), waypoint click behavior, and keybinds for zoom, recenter, visibility, combat, and fixed position.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Optional suppress vanilla player attribute bars, target frame, group and raid frames, and companion frame while the matching LUIE custom frames are enabled (PC and console).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Misc Settings: |cFFFFFFUnregister Hidden Buff/Debuff UI|r stops vanilla buff and debuff UI from running in the background when the game buff UI is disabled.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Optional |cFFFFFFShow Item Type|r on loot lines (same pattern as trait and style display).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Cast bar |cFFFFFFicon frame color|r picker under cast bar settings.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap / Info Panel: Optional anchor Info Panel below the minimap with zone name above the map; legacy minimap clock mode removed.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t MiniMap: Shared pin draw sizing for overlays and world-map container pins; improved quest pin sync and layout recovery.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: |cFFFFFFTopInfo|r row on player, target, small group, and AvA frames with level, veterancy rank, and overland difficulty icons in the caption area.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar / LuiData: Bar highlight tracks |cFFFFFFHidden Blade|r and |cFFFFFFShrouded Daggers|r major brutality and major sorcery with slotted major duration caps tied to player buffs.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Artificial effect overrides and tooltips for |cFFFFFFUnderdog|r damage and healing and |cFFFFFFSolo Queue|r XP and AP bonuses.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Cast bar label normalization for additional wayshrine recall cast abilities.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Companion |cFFFFFFAbility Track|r uses an aura cache for duration and stack feedback on companion buffs and hotbar effects.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: Announcements use updated tab routing so active chat tabs receive lines reliably; deprecated system-message options removed from Chat Output settings.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData 7.2.2.1: Dragonknight effect overrides and tooltip visibility fixes; LuiExtended dependency updated accordingly.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Off Balance is no longer auto-added to |cFFFFFFProminent Debuffs|r on first load (existing saved entries are unchanged). Prominent debuff remove list and right-click menu now match prominent routing, including the canonical Off Balance name entry.",
    "",
    -- Version Header 7.2.4.6
    "|cFFA500LuiExtended Version 7.2.4.6|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Info: |cFFFFFFSynergy Tracker|r has been temporarily removed from the addon while it is reworked (settings and UI will return in a future update).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SavedVariables: Removed the `LUIESV.Default` metatable compat layer (`InstallExternalSavedVarsLegacyCompat`). Third-party addons (for example |cFFFFFFS'rendarr|r group aura anchoring) should read |cFFFFFFLUIE.SV|r and |cFFFFFFLUIE.UnitFrames.SV|r at runtime after LuiExtended loads, not raw `LUIESV` / split module globals.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Fixed repeated UI errors when multiple guild bank item deposit or withdraw lines printed in the same loot queue batch.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Guild bank loot announcements now retain the guild id per queued message so the guild name stays correct when several items are moved quickly.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Announcements: Guild bank context message formatting always passes enough arguments for multi-placeholder withdraw/deposit strings (including when the guild label is empty).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: |cFFFFFFWildfire Embers|r target debuff auras are no longer overridden as |cFFFFFFBurning Embers|r.",
    "",
    -- Version Header 7.2.4.5
    "|cFFA500LuiExtended Version 7.2.4.5|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Character Profile: |cFFFFFFEnable Character-Specific Settings|r now correctly applies to all LuiExtended module saved variables (including |cFFFFFFUnit Frames|r repositioning); custom frame positions no longer carry over between characters when profiles are enabled. Module data that was written to the account-wide bucket while the toggle was on may seed into the current character on first login after this update.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: |cFFFFFFCharacter Name|r name display on custom player and target bars now shows the character name instead of following the game UI primary name preference (which could show |cFFFFFF@UserID|r when |cFFFFFFCharacter Name|r was selected).",
    "",
    -- Version Header 7.2.4.4
    "|cFFA500LuiExtended Version 7.2.4.4|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Info Panel: Top and bottom rows reflow from a single layout pass when enabled meters change; nested rearrange calls no longer double-refresh meters. Label padding and minimum widths are adjusted for FPS, memory, latency, and bags.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Reset to defaults (and other settings that refresh boss threshold markers) no longer cause a Lua error when CrutchAlerts is loaded and no boss unit is present; default 25/50/75 markers apply until a boss is active.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Repositioned Active Combat Tips again apply the higher draw tier to the visible tip label text (correct control after Update 50).",
    "",
    -- Version Header 7.2.4.3
    "|cFFA500LuiExtended Version 7.2.4.3|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Info Synergy Tracker: Optional Horizontal Icon Alignment (left or right) when minimal display uses horizontal icon layout; row width follows Maximum Synergies to Display.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: CrutchAlerts boss threshold mechanic labels fade in and out and only the next upcoming mechanic is highlighted when several thresholds share the same name; markers still update from cached boss health when the boss unit is absent.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Repositioned Active Combat Tips use a higher draw tier so tip text stays visible above overlapping UI.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Combat Info Synergy Tracker: Unlock positioning preview stays visible during HUD refreshes while you drag the frame.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData / SpellCastBuffs: Forceful and Feeding Frenzy (stage 3) use corrected ability icons; Feeding Frenzy max-stage player buff shows in the buff tracker again.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames (debug): /luiufboss and /luiufbosshp preview threshold markers and step simulated boss HP (requires Show threshold markers).",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Legacy TempAlert home, campaign, and outfit slash toggles migrate into Notify options correctly for character-specific saved variables.",
    "",

    -- Version Header 7.2.4.2
    "|cFFA500LuiExtended Version 7.2.4.2|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Gamepad Character Sheet: The Challenge Difficulty row and dropdown are visible again after Update 50.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Gamepad Skills and Skills Advisor: Custom ability icons on skill lists still display correctly after Update 50 compatibility updates.",
    "",

    -- Version Header 7.2.4.1
    "|cFFA500LuiExtended Version 7.2.4.1|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Other players' overland challenge tier changes no longer spam chat; your own tier still announces once under Notify → Challenge Difficulty. Cooldown and combat failure alerts use the same Notify toggles.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Custom target, group, and raid frames now show other players' overland challenge tier icons on their names.",
    "",

    -- Version Header 7.2.4.0
    "|cFFA500LuiExtended Version 7.2.4.0|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Display Veterancy Rank and Overland Difficulty Icon are configured per custom frame type (Player, Target, Small Group, Raid); prior target-only toggles migrate on first load after upgrade.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Veterancy and overland difficulty display default off for new installs; upgraded profiles keep enabled options via migration.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Compass-integrated default boss bar uses the base-game compass SetBossBarHiddenForReason stack instead of replacing boss bar refresh, so the compass boss UI stays hidden unless Compass Boss Bar is selected.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Take All mail loot again shows sender names on attachment lines (hireling and other system mail).",
    "",

    -- Version Header 7.2.3.9
    "|cFFA500LuiExtended Version 7.2.3.9|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Optional Show Rapport Change on custom companion frames shows a green + or red - beside the companion bar when rapport goes up or down.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Update 50 announcements cover Tamriel Tomes rollover currency, veterancy rank-up notices, overland difficulty alerts, timed activity reroll reset, season recap, clearer hireling mail sender names, and large-group invite messaging aligned with the base game.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Translations: Settings and in-game text are grouped by module (Action Bar, Chat Announcements, Combat Info, Combat Text, Info Panel, Slash Commands, SpellCastBuffs, Unit Frames, and shared options) with expanded English and updated language files.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements Social: Friends List Log On/Off Name Format lets you show one name using Player Name Display Method (default) or both names in base-game order (@UserID with Character Name) with LUIE link styling.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: In veterancy zones, optional Display Veterancy Rank on custom player, target, group, and raid frames; optional Overland Difficulty Icon on target names (with a monsters-only option) to match base-game nameplates.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Optional notices when you unlock a set at a consolidated attunable crafting station in your home (separate toggles for chat, center-screen messages, and alerts).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Optional chat and alert notices for LuiExtended /home and primary home, /campaign checks, Cyrodiil queue updates, outfit changes, and common social errors (invites, ignore list, and similar).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Guild bank deposits, withdrawals, and moved items show which guild's bank you used.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar / LuiData: Better bar highlights and stack timers for more Cyrodiil Vengeance kits (Vanguard, Scout, Bone Totem, and related Alliance War abilities).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Cast bar supports more recall and teleport items (Mages Guild Recall, DLC-style recalls, and similar consumables).",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Guard confiscation loot no longer lists your legitimately worn gear after a weapon swap when you are caught with a bounty; only stolen items are announced.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Friend online/offline messages default to a single name from Player Name Display Method; optional Friends List Log On/Off Name Format restores base-game @UserID with Character Name order (fixes reversed name order from 7.2.3.7).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Weekly and other timed challenge updates no longer print twice when both challenge tracking and progress announcements are enabled.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: Dragonknight Landslide passive stacks in the skills menu use the Landslide icon instead of Dragon Leap ground art.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Recalls no longer cancel when you click a wayshrine on the world map while standing still.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Slash Commands (PC): With LibSlashCommander installed, LUIE slash commands no longer register twice after /reloadui.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Shield, trauma, and related health bar overlays update more reliably on custom player, target, group, companion, pet, and boss frames.",
    "",

    -- Version Header 7.2.3.8
    "|cFFA500LuiExtended Version 7.2.3.8|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar / LuiData: Bar highlight taunt timers on each slotted taunt ability (including multiple taunts on one bar and on the back bar) share the player taunt debuff on your reticle target; previously only one slot updated because highlights were keyed only to debuff id 38254.",
    "",

    -- Version Header 7.2.3.7
    "|cFFA500LuiExtended Version 7.2.3.7|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Optional Display Collection Status on loot announcements shows a green check when a set collection piece or container collectible is already known, or a red X when it is not (off by default).",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output / ChatAnnouncements: When Chat Announcements owns friend, ignore, and related social lines, default CHAT_ROUTER duplicates are suppressed; friend online/offline and friend/ignore Chat Announcements toggles are stored under Chat Output Social (FriendStatusCA, FriendIgnoreCA) and re-chain suppression when changed.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output (PC): Per-tab routing shows an inline settings warning when no tab has both LUIE and System enabled so announcements have a deliverable tab.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData / Action Bar: Grim Focus and its morphs use improved stack labels and bar highlights (including reload seeding when the track buff is already active); Leeching Strikes cost-reduction stacks display on the visible buff via PullStacks tracking.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Unified buff icon backdrop and ApplyBuffIconChrome for consistent chrome; tooltip inset textures preload to avoid pop-in; debug tooltips layout and refresh improvements.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Taking attached gold from multiple mails individually (same amount and sender) now prints a currency line per mail again; duplicate mail gold announcements within 2.5s are still suppressed per mail (Take All unchanged).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: Announcements missing when LUIE was on but System was off; enabling LUIE on a tab now turns System on for that tab, with a settings note and one-time chat warning when no tab can receive messages.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Show Backbar mirrors the base-game activation proc glow on inactive weapon bar slots (same highlight as the active bar when an ability is ready).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Show Triggered proc feedback on the back bar (timed procs, instant procs, and stack-based highlights such as Necromancer skull charges) matches the front bar again.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Necromancer Flame, Venom, and Ricochet skull charge highlights use separate tracking (Venom advances from the charge buff and any in-combat Necromancer ability while slotted, not only skull casts). Stack labels, proc at full charge, and clear after the empowered cast match the base game.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar / LuiData: Venom Skull bar stacks show 1 through 3 when the charge buff reports three stacks (Flame and Ricochet remain 1 and 2 with proc at two charges).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Necromancer skull charge buff tooltips pull live morph text from the skill sheet (localized) instead of shortened static strings.",
    "",

    -- Version Header 7.2.3.6
    "|cFFA500LuiExtended Version 7.2.3.6|r",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output (PC): Per-tab routing grid with LUIE and System columns (up to 20 tabs). Shorter setting tooltips.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: Print to Specific Tabs works again with LibChatMessage loaded.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: Tab rows follow the number of open chat tabs; inactive slots stay disabled.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: Display System Messages in ALL Tabs honors Print to All Tabs for system-style messages.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: Per-tab toggles keep saved values when greyed out after LAM refresh.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Debug environment (/luie debug): Persists across /reloadui; reload while debugging no longer resets extra addons you enabled for testing.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Debug environment (/luie debug): One chat reminder per UI load while debug is active (including ingame /reloadui). Logout and quit still restore your prior addon selection.",
    "",

    -- Version Header 7.2.3.5
    "|cFFA500LuiExtended Version 7.2.3.5|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: When Color Debuffs by Crowd Control Type is enabled, optional Color non-CC debuffs by damage type (cooldown fill) plus per-damage-type color pickers tint the cooldown fill from combat-reported damage type when no crowd-control class applies.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Misc Settings: In-game Changelog uses collapsible version sections with stable scroll and wrap width, and layout refresh when sections expand.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output (PC): When LibChatMessage is installed, Chat Output settings integrate LibChatMessage time prefix, format presets, history restore, and timestamp sync for proxy output.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Slash Commands (PC): When LibSlashCommander is installed, LUIE slash commands register through a shared registry for chat autocomplete and command descriptions.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: Werewolf abilities, buffs, tooltips, and bar highlights are finalized for Update 50 (including in-form Rampage morphs, Fury, and helper-aura cleanup on the buff frame).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: Added Infinite Archive and trial supplement combat alert tables merged at load for Endless Archive and additional trial and dungeon abilities.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData / Action Bar: Sorcerer and Two-Handed skill-line bar highlights and effect audits; Necromancer skull stack highlights keep bar highlights while stacks remain (combatStackNoExpire); proc stack thresholds and combat-stack tracking improvements.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Guild trader sale mail with subject Item Sold is recognized for sender resolution and chat announcements.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs (debug): Debug tooltips format remaining time, use an overflow column, and skip redundant rebuilds on hover.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Debug environment (/luie debug): Saved-vars reconciliation after load and on logout restores addon enablement cleanly.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Endless Archive and Night Market adventure-zone HUD tracker positions persist again after reloadui, zone change, and turning off Unlock Default UI Elements (tracker container saved-vars key on RefreshAnchors post-hook).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Reset to Defaults for unlock positions also clears AlertFrameAlignment so alert text alignment resets with other unlock data.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: CrutchAlerts BossHealthBar integration caches handles at init instead of reading CrutchAlerts in hot paths, avoiding errors in strict debug environments when Crutch is disabled.",
    "",

    -- Version Header 7.2.3.4
    "|cFFA500LuiExtended Version 7.2.3.4|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Misc Settings (PC) / Settings (console): Alert Text Alignment dropdown (Left, Center, Right) for on-screen combat alerts. Sets the default notification anchor when the frame is not unlocked, re-anchors the scrolling alert buffer to match, and applies the same alignment to wrapped multi-line alert lines on keyboard and gamepad.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Custom Raid, Companion, Pet, and Boss frames no longer render unit names larger than health/value text on stock settings. The single Font Size control now matches both saved fields and on-screen text without moving the slider first (including a one-time migration for existing profiles).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Active Combat Tips (dodge and synergy help) use a dedicated layout anchor so tips dismiss correctly again; saved positions migrate from the old ZO_ActiveCombatTipsTip unlock key.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Frame mover previews follow each HUD element's on-screen position. Moving one unlocked panel no longer drags other preview overlays with it (for example Equipment Status or Ram when the action bar is moved).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unlock: Saved positions for the compass, player XP bar, and HUD trackers are re-applied after ZOS UI refresh (compass style, XP template, tracker anchor refresh) without replacing ZOS template functions.",
    "",

    -- Version Header 7.2.3.3
    "|cFFA500LuiExtended Version 7.2.3.3|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Companion Ability Track adds an optional icon row on the custom Companion frame for companion hotbar abilities (including built-in interrupt), with optional cooldown radial, effect timer, and stack labels. Enable it under Custom Unit Frames → Companion; it is off by default for new installs.",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Use Separate Shield Bar again shows shield on custom Player, Target, Small Group, Companion, and Pet frames (including live updates from settings without /reloadui). Companion layout reserves space for the shield row and places the ability track below it.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs (debug): Show Debug Ability ID no longer cuts off digits on buff icons.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs (debug): Ability IDs show on existing buffs after /reloadui without waiting for them to refresh.",
    "",

    -- Version Header 7.2.3.2
    "|cFFA500LuiExtended Version 7.2.3.2|r",
    "",
    -- New
    "|cFFFF00New:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Off Balance can now be tracked as a single Prominent Debuff. Adding \"Off Balance\" to Prominent Debuffs covers every renamed Off Balance variant, Off Balance applied by allies, and the Off Balance Immunity buff, all routed to the prominent target column. It is added to Prominent Debuffs once by default; remove it and it will not be re-added.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: New shared chat output settings (timestamp on/off, format and color, tab routing, and system-message handling) are now stored account-wide (or per-character when Character-Specific Settings is enabled) and shared across LUIE modules. Existing Chat Announcements chat settings are migrated automatically, and Combat Text now exposes the same chat output options.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: Added LibChatMessage integration on PC for better compatibility with external chat addons (such as pChat) when LUIE prints to chat.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Chat Output: Added rChat integration on PC (external formatting and CHAT_ROUTER re-chaining) alongside existing pChat support when Allow Addons to Modify LUIE Messages is enabled.",
    "",
    -- Changes
    "|cFFFF00Changes:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: Werewolf abilities, buffs, and tooltips were overhauled for Update 50, including renamed and new skills (Gnash, Bloody Gnash, Rending Claws, Bloodclaws, Claw Fury, Rip and Tear), Blood Hunger stacks, the Fury resource, Insatiable Hunger, and the Rampage ultimate. Buff classifications were corrected (for example, Deafening Roar now grants Major Cowardice and Major Maim instead of Major Breach), and internal helper auras are hidden so the buff frame keeps the correct icons.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData / Action Bar: Dragonknight abilities received updated buff tracking, tooltips, and bar highlights (Lava / Volcanic / Molten Whip, Flame Lash, Power Lash, Dragonfire Breath, Engulfing Dragonfire, Dragon Blood morphs, Battle Roar, Landslide and Mantle morphs, Searing Strike, Burning Embers, and Core / Heart / Soul of Flame), with more accurate bar-highlight stack consumption and dynamic tooltip values.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t LuiData: Added tracking, tooltips, ground-effect auras, cast bar entries, and Combat Text blacklist presets for new Arcanist abilities, a dynamic Fated Fortune tooltip, and support for new Update 50 trial abilities and effects.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Prominent buff and debuff name labels were repositioned to a single line in the strip above the progress bar for a cleaner layout.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Action Bar: Added noRemove handling so certain tracked bar highlights are not cleared early, and combat-event pass-through is now respected when remapping extra bar-highlight IDs.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs (debug): Ability ID font fitting runs only when the ID text or icon layout changed, reducing per-tick cost while Show Debug Ability ID is enabled.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Performance & Memory: Bounded several tables that could grow over long sessions and added cleanup on unit / viewer destruction and reloads (SpellCastBuffs buff sorting and ground / stack sweeps, ChatAnnouncements quest-item and group-loot tracking, Combat Text event viewers, Crowd Control animation cache and Synergy Tracker eviction, Group Resources callbacks, Unit Frames attribute visualizers, and dodge-prediction / power-update handling).",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs (debug): Show Debug Ability ID on pooled buff/debuff icons no longer intermittently fails to draw the numeric ID (most noticeable on target buff routing) after icons are recycled from the shared pool. Pool reset clears per-icon text caches, slot rebind refreshes the ID label, and LabelControl:Clean() runs before truncation checks when font fitting runs.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Show Block Player brace icon displays again when full display rebuilds are not forced every tick. The synthetic block effect is updated in place while blocking, and the display sorter includes effects whose start time equals the current update (not only strictly earlier).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: ClearPlayerBuff and ClearFakeEffectEntry only mark the display dirty when an effects-list row was actually removed, instead of every 100 ms while not blocking with Show Block Player enabled.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t SpellCastBuffs: Target buff and debuff icons no longer linger after clearing reticle; ReloadEffects now marks the display dirty when target lists are cleared (empty reticle or dead unit).",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Compact (Raid) name labels now grow to fit the caption font size instead of being shrunk by the game, the Raid Name Clip slider hides or clips names correctly across its full range, and the raid layout now refreshes all 12 slots so size / clip changes preview while solo and empty slots no longer keep stale geometry.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: The no-healing (healing-absorbed) overlay and the damage shield now layer correctly above the health fill on custom frames.",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Alert and loot-history hooks are now installed only once, preventing duplicate announcements if module setup runs again in the same session.",
    "",

    -- Version Header 7.2.3.1
    "|cFFA500LuiExtended Version 7.2.3.1|r",
    "",
    -- Fix
    "|cFFFF00Fix:|r",
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t Unit Frames: Per-category Font/Texture settings now show Font Size (Label) and Font Size (Bar) only for Player, Target, Group (small group), and AvA frames that use a separate top caption row. Raid, Companion, Pet, and Boss use a single Font Size slider for all text on the health bar (name and values). Compact frames with different saved label and bar sizes now render one consistent size until you change that slider (both values are updated together when you do).",
    "",

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
    "|t12:12:EsoUI/Art/Miscellaneous/bullet.dds|t ChatAnnouncements: Display Announcements for Event Zone: Night Market (PC and console). Separate chat, center-screen, and alert toggles for Daring Race, Arachnid Invasion, and Guiding Light. Still missing some; will be added when I see them.",
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
        -- Keep scrollbar lane width when content is short so note wrap width does not change on expand/collapse.
        ZO_Scroll_SetHideScrollbarOnDisable(scrollContainer, false)
    end

    scrollBar:SetThumbTexture(CHANGELOG_SCROLL_THUMB, CHANGELOG_SCROLL_THUMB_DISABLED, "", CHANGELOG_SCROLL_THUMB_WIDTH, CHANGELOG_SCROLL_THUMB_HEIGHT, 0, 0, 1, 1)

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

-- -----------------------------------------------------------------------------
-- Changelog UI manager (ZO_DeferredInitializingObject + tree/scroll layout).
-- -----------------------------------------------------------------------------

--- @class LUIE_Changelog_Manager : ZO_DeferredInitializingObject
local LUIE_Changelog_Manager = ZO_DeferredInitializingObject:Subclass()

function LUIE_Changelog_Manager:Initialize()
    self.control = LUIE_Changelog
    self.fragment = ZO_SimpleSceneFragment:New(self.control)
    self.scene = ZO_Scene:New(LUIE_CHANGELOG_SCENE_NAME, SCENE_MANAGER)
    self.scene:AddFragment(self.fragment)
    self.tree = nil
    self.controls = {}
    self.headerPool = nil
    self.bodyPool = nil
    self.layoutEventManager = GetEventManager()
    self.contentWidth = CHANGELOG_CONTENT_WIDTH
    self.sectionBodyWidth = CHANGELOG_CONTENT_WIDTH - CHANGELOG_SECTION_BODY_TREE_INDENT
    self.sectionBodyLabelWidth = self.sectionBodyWidth - CHANGELOG_SECTION_BODY_LABEL_PAD_X
    self.contentWidthLocked = false
    ZO_DeferredInitializingObject.Initialize(self, self.scene)
end

function LUIE_Changelog_Manager:GetScrollChild()
    return LUIE_Changelog_ContainerScrollChild
end

function LUIE_Changelog_Manager:GetScrollbarGutter()
    local scrollBar = LUIE_Changelog_ContainerScrollBar
    if scrollBar then
        local scrollBarWidth = scrollBar:GetWidth()
        if scrollBarWidth > 0 then
            return scrollBarWidth
        end
    end
    return CHANGELOG_SCROLLBAR_GUTTER_FALLBACK
end

function LUIE_Changelog_Manager:ApplyContentMetrics(force)
    if self.contentWidthLocked and not force then
        return
    end
    local scrollChild = self:GetScrollChild()
    if not scrollChild then
        return
    end
    local scroll = LUIE_Changelog_Container and LUIE_Changelog_Container.scroll
    local baseWidth = scroll and scroll:GetWidth() or scrollChild:GetWidth()
    if baseWidth <= CHANGELOG_TREE_INSET_X then
        self.contentWidth = CHANGELOG_CONTENT_WIDTH
    else
        self.contentWidth = zo_max(400, baseWidth - self:GetScrollbarGutter() - CHANGELOG_TREE_INSET_X)
    end
    self.sectionBodyWidth = self.contentWidth - CHANGELOG_SECTION_BODY_TREE_INDENT
    self.sectionBodyLabelWidth = self.sectionBodyWidth - CHANGELOG_SECTION_BODY_LABEL_PAD_X
    self.contentWidthLocked = true
end

function LUIE_Changelog_Manager:IsSectionBodyControl(control)
    return control:GetNamedChild("Text") ~= nil and control:GetNamedChild("Title") == nil
end

function LUIE_Changelog_Manager:GetSectionControlWidth(control)
    if self:IsSectionBodyControl(control) then
        return self.sectionBodyWidth
    end
    return self.contentWidth
end

function LUIE_Changelog_Manager:ApplyControlWidths()
    for controlIndex = 1, #self.controls do
        local control = self.controls[controlIndex]
        local targetWidth = self:GetSectionControlWidth(control)
        if control:GetWidth() ~= targetWidth then
            control:SetWidth(targetWidth)
        end
    end
end

function LUIE_Changelog_Manager:ApplyBodyLabelAnchors(label)
    label:ClearAnchors()
    label:SetAnchor(TOPLEFT, nil, TOPLEFT, CHANGELOG_THEME.sectionBodyPadding, CHANGELOG_THEME.sectionBodyPadding)
end

function LUIE_Changelog_Manager:SetupSectionPools(scrollChild)
    if not self.headerPool then
        self.headerPool = ZO_ControlPool:New(CHANGELOG_SECTION_HEADER_TEMPLATE, scrollChild, "SecHdr")
        self.headerPool:SetCustomResetBehavior(function (header)
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
    if not self.bodyPool then
        self.bodyPool = ZO_ControlPool:New(CHANGELOG_SECTION_BODY_TEMPLATE, scrollChild, "SecBody")
        self.bodyPool:SetCustomResetBehavior(function (wrap)
            wrap.bodyLabel = nil
        end)
    end
end

function LUIE_Changelog_Manager:SetupSectionHeader(header, title, expanded)
    header:SetWidth(self.contentWidth)
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

function LUIE_Changelog_Manager:MeasureSectionBodyTextHeight(label)
    local fontHeight = label:GetFontHeight()
    local _, measuredHeight = label:GetTextDimensions()
    local numLines = label:GetNumLines()
    if numLines > 0 then
        measuredHeight = zo_max(measuredHeight, numLines * fontHeight)
    end
    local bodyText = label:GetText()
    local _, utilHeight = ZO_LabelUtils_GetTextDimensions(bodyText, CHANGELOG_THEME.fontBody, self.sectionBodyLabelWidth)
    return zo_max(measuredHeight, utilHeight, fontHeight) + CHANGELOG_SECTION_BODY_HEIGHT_SLACK
end

--- Re-measure wrapped section body after the control is in the tree (first expand needs this).
--- @param wrap Control
function LUIE_Changelog_Manager:RefreshSectionBodyLayout(wrap)
    local label = wrap:GetNamedChild("Text")
    local bodyBg = wrap:GetNamedChild("Bg")
    if not label or not bodyBg then
        return
    end
    local pad = CHANGELOG_THEME.sectionBodyPadding
    if label.Clean then
        label:Clean()
    end
    self:ApplyBodyLabelAnchors(label)
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    label:SetMaxLineCount(0)
    label:SetWidth(self.sectionBodyLabelWidth)
    local textHeight = self:MeasureSectionBodyTextHeight(label)
    local wrapHeight = textHeight + pad * 2
    label:SetHeight(textHeight)
    wrap:SetHeight(wrapHeight)
    bodyBg:SetHeight(wrapHeight)
end

function LUIE_Changelog_Manager:SetupSectionBody(wrap, lines)
    local bodyText = FormatChangelogSectionBody(lines)

    wrap:SetWidth(self.sectionBodyWidth)

    local bodyBg = wrap:GetNamedChild("Bg")
    ApplyChangelogBackdrop(bodyBg, "surface")

    local label = wrap:GetNamedChild("Text")
    label:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
    label:SetMaxLineCount(0)
    label:SetWidth(self.sectionBodyLabelWidth)
    label:SetText(bodyText)
    local bodyR, bodyG, bodyB, bodyA = ZO_DEFAULT_ENABLED_COLOR:UnpackRGBA()
    label:SetColor(bodyR, bodyG, bodyB, bodyA)

    wrap.bodyLabel = label
    self:RefreshSectionBodyLayout(wrap)
end

function LUIE_Changelog_Manager:RefreshAllSectionBodies()
    for controlIndex = 1, #self.controls do
        local control = self.controls[controlIndex]
        if control.bodyWrap then
            self:RefreshSectionBodyLayout(control.bodyWrap)
        elseif control:GetNamedChild("Text") and control:GetNamedChild("Bg") then
            self:RefreshSectionBodyLayout(control)
        end
    end
end

function LUIE_Changelog_Manager:SetSectionExpanded(header, expanded)
    if header.toggleBtn then
        header.toggleBtn:SetText(expanded and "-" or "+")
    end
end

function LUIE_Changelog_Manager:RemoveControlFromList(control)
    for controlIndex = #self.controls, 1, -1 do
        if self.controls[controlIndex] == control then
            table.remove(self.controls, controlIndex)
            return
        end
    end
end

function LUIE_Changelog_Manager:GetControlSubtreeBottom(control, maxBottom)
    if not control:IsHidden() then
        maxBottom = zo_max(maxBottom, control:GetTop() + control:GetHeight())
    end
    for childIndex = 1, control:GetNumChildren() do
        local child = control:GetChild(childIndex)
        if child then
            maxBottom = self:GetControlSubtreeBottom(child, maxBottom)
        end
    end
    return maxBottom
end

function LUIE_Changelog_Manager:UpdateScrollChildHeight(scrollChild)
    local childTop = scrollChild:GetTop()
    local maxBottom = self:GetControlSubtreeBottom(scrollChild, childTop)
    scrollChild:SetHeight(zo_max(400, maxBottom - childTop + 12))
end

function LUIE_Changelog_Manager:FinalizeLayout()
    local scrollChild = self:GetScrollChild()
    if not scrollChild or not self.tree then
        return
    end
    self:ApplyContentMetrics()
    self:ApplyControlWidths()
    self.tree:Update()
    self:RefreshAllSectionBodies()
    self.tree:Update()
    self:UpdateScrollChildHeight(scrollChild)
    if LUIE_Changelog_Container then
        ZO_Scroll_UpdateScrollBar(LUIE_Changelog_Container, true)
    end
end

function LUIE_Changelog_Manager:UpdateTreeLayoutAfterToggle(sectionHeader, expanded)
    local scrollChild = self:GetScrollChild()
    if not scrollChild or not self.tree then
        return
    end
    if expanded and sectionHeader.bodyWrap then
        if sectionHeader.bodyWrap:GetWidth() ~= self.sectionBodyWidth then
            sectionHeader.bodyWrap:SetWidth(self.sectionBodyWidth)
        end
    end
    self.tree:Update()
    if expanded and sectionHeader.bodyWrap then
        self:RefreshSectionBodyLayout(sectionHeader.bodyWrap)
        self.tree:Update()
    end
    self:UpdateScrollChildHeight(scrollChild)
    if LUIE_Changelog_Container then
        ZO_Scroll_UpdateScrollBar(LUIE_Changelog_Container, true)
    end
end

function LUIE_Changelog_Manager:ScheduleLayoutFinalize()
    local manager = self
    self.layoutEventManager:UnregisterForUpdate(CHANGELOG_LAYOUT_UPDATE_NAME)
    self.layoutEventManager:RegisterForUpdate(CHANGELOG_LAYOUT_UPDATE_NAME, 0, function ()
        manager.layoutEventManager:UnregisterForUpdate(CHANGELOG_LAYOUT_UPDATE_NAME)
        manager:FinalizeLayout()
    end)
end

function LUIE_Changelog_Manager:RequestLayoutRefresh()
    local scrollChild = self:GetScrollChild()
    if scrollChild and #self.controls > 0 and self.tree then
        self:FinalizeLayout()
        self:ScheduleLayoutFinalize()
    end
end

function LUIE_Changelog_Manager:AttachSectionBody(header, headerNode, tree)
    if header.bodyNode or not header.sectionLines then
        return
    end

    local bodyWrap, poolKey = self.bodyPool:AcquireObject()
    header.bodyWrap = bodyWrap
    header.bodyPoolKey = poolKey
    header.bodyNode = tree:AddChild(headerNode, bodyWrap, CHANGELOG_THEME.spacing.md)
    self.controls[#self.controls + 1] = bodyWrap
    self:SetupSectionBody(bodyWrap, header.sectionLines)
end

function LUIE_Changelog_Manager:DetachSectionBody(header, tree)
    if not header.bodyNode then
        return
    end

    tree:RemoveNode(header.bodyNode)
    if header.bodyWrap then
        self:RemoveControlFromList(header.bodyWrap)
    end
    if header.bodyPoolKey then
        self.bodyPool:ReleaseObject(header.bodyPoolKey)
    end
    header.bodyWrap = nil
    header.bodyPoolKey = nil
    header.bodyNode = nil
end

function LUIE_Changelog_Manager:ReleaseTreeUI()
    self.layoutEventManager:UnregisterForUpdate(CHANGELOG_LAYOUT_UPDATE_NAME)
    if self.tree then
        self.tree:Clear()
    end
    if self.headerPool then
        self.headerPool:ReleaseAllObjects()
    end
    if self.bodyPool then
        self.bodyPool:ReleaseAllObjects()
    end
    self.controls = {}
    self.contentWidthLocked = false
end

function LUIE_Changelog_Manager:OnSectionExpanded(node, expanded)
    local sectionHeader = node:GetControl()
    self:SetSectionExpanded(sectionHeader, expanded)
    if expanded then
        self:AttachSectionBody(sectionHeader, node, self.tree)
    else
        self:DetachSectionBody(sectionHeader, self.tree)
    end
    self:UpdateTreeLayoutAfterToggle(sectionHeader, expanded)
end

function LUIE_Changelog_Manager:BuildTreeUI()
    local scrollChild = self:GetScrollChild()
    if not scrollChild then
        return
    end

    self:ReleaseTreeUI()
    self:ApplyContentMetrics()

    local sections = ParseChangelogVersionSections(changelogMessages)
    if #sections == 0 then
        return
    end

    self:SetupSectionPools(scrollChild)

    local treeAnchor = ZO_Anchor:New(TOPLEFT, scrollChild, TOPLEFT, 4, 4)
    local tree = ZO_TreeControl:New(treeAnchor, 14, 8)
    tree:SetRelativePoint(BOTTOMLEFT)
    self.tree = tree

    local lastHeaderNode
    self.controls = {}
    local manager = self

    for sectionIndex = 1, #sections do
        local section = sections[sectionIndex]
        local openByDefault = sectionIndex == 1
        local displayTitle = GetChangelogVersionDisplayTitle(section.title)

        local header = self.headerPool:AcquireObject(sectionIndex)
        self:SetupSectionHeader(header, displayTitle, openByDefault)

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
        self:SetSectionExpanded(header, openByDefault)

        local function toggleSection()
            if header.treeNode then
                header.treeNode:ToggleExpanded()
            end
        end

        headerNode:SetExpandedCallback(function (node, expanded)
            manager:OnSectionExpanded(node, expanded)
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

        self.controls[#self.controls + 1] = header

        if openByDefault then
            self:AttachSectionBody(header, headerNode, tree)
        end
    end

    self:FinalizeLayout()
    self:ScheduleLayoutFinalize()
end

function LUIE_Changelog_Manager:OnDeferredInitialize()
    ApplyChangelogWindowTheme()
    LUIE_Changelog_Title:SetText(LUIE.FormatChangelogWindowTitle())
    LUIE_Changelog_About:SetText(zo_strformat(GetString(LUIE_STRING_CORE_CHANGELOG_ABOUT_LINE), LUIE.version, LUIE.author))

    local scrollChild = LUIE_Changelog_ContainerScrollChild
    if scrollChild then
        scrollChild:SetHandler("OnRectHeightChanged", function ()
            if LUIE_Changelog_Container then
                ZO_Scroll_UpdateScrollBar(LUIE_Changelog_Container, true)
            end
        end)
    end
end

function LUIE_Changelog_Manager:OnShowing()
    if #self.controls == 0 then
        self:BuildTreeUI()
    end
end

function LUIE_Changelog_Manager:OnShown()
    self:RequestLayoutRefresh()
end

function LUIE_Changelog_Manager:OnHidden()
    LUIE.SV.WelcomeVersion = LUIE.version
end

function LUIE_Changelog_Manager:Show()
    self.control:ClearAnchors()
    self.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, -120)
    SCENE_MANAGER:Show(LUIE_CHANGELOG_SCENE_NAME)
end

function LUIE_Changelog_Manager:Hide()
    if SCENE_MANAGER:IsShowing(LUIE_CHANGELOG_SCENE_NAME) then
        SCENE_MANAGER:ShowBaseScene()
    end
end

local function IsChangelogFeatureEnabled()
    return LUIE.SV.ShowChangeLog == true
end

local function GetLUIEChangelogManager()
    if not IsChangelogFeatureEnabled() then
        return nil
    end
    if not LUIE.changelogManager then
        LUIE.changelogManager = LUIE_Changelog_Manager:New()
    end
    return LUIE.changelogManager
end

-- -----------------------------------------------------------------------------
-- Hide toggle called by the menu or xml button
function LUIE.ToggleChangelog(option)
    local manager = GetLUIEChangelogManager()
    if not manager then
        if option and SCENE_MANAGER:IsShowing(LUIE_CHANGELOG_SCENE_NAME) then
            SCENE_MANAGER:ShowBaseScene()
        end
        return
    end
    if option then
        manager:Hide()
    else
        manager:Show()
    end
end

-- -----------------------------------------------------------------------------
-- Called on first player activation when LUIE.SV.ShowChangeLog is enabled (see Initialize_PC.lua LoadScreen).
function LUIE.ChangelogScreen()
    if not IsChangelogFeatureEnabled() then
        return
    end

    local manager = GetLUIEChangelogManager()
    if not manager then
        return
    end

    if LUIE.SV.WelcomeVersion ~= LUIE.version then
        manager:Show()
    end
end

-- -----------------------------------------------------------------------------
