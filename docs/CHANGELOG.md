# LuiExtended Changelog

## Version 7.2.6.3

### New

- Chat Announcements: Display Announcements for Dynamic Encounters (PC and console). Separate chat, center-screen, and alert toggles for Vampire Hunt, Flowervine Farm, Bilsa's Delivery, and Misc.

### Fixed

- SpellCastBuffs: Adding any **Off Balance** ability id (or the canonical name) to **Prominent Debuffs** now tracks all Off Balance variants and Off Balance Immunity. Profiles that never received the default Off Balance prominent entry are seeded once on load.
- SpellCastBuffs: **Crowd Control Immunity** (28301 / 38117) can be tracked as a prominent debuff on targets (same target-buff promote path as Off Balance Immunity).
- Unit Frames: Custom player champion icon and level no longer clear when changing frame settings; they refresh immediately.
- Unit Frames: Turning off **Target - Display Title** no longer leaves NPC or guild trader captions visible when **Target - Display AVA Rank Name** is still on. Rank name still applies to player targets only.
- Unit Frames: Invulnerable targets (for example guards) no longer show a health percentage next to the Invulnerable label.

## Version 7.2.6.2

### New

- Chat Announcements: Optional notifications when you save or equip an armory build (chat, center-screen message, and/or alert), with customizable message color, under Notify settings.

### Fixed

- Chat Announcements: Outfit equip notifications no longer error when the game reports success without an equipped outfit index.
- SpellCastBuffs: Bloodthorn Cultist Outfit disguise shows the correct buff icon and tooltip.
- Chat Announcements: Disguise enter and exit messages use the correct costume-specific wording for supported disguises, including Bloodthorn Cultist Outfit.

## Version 7.2.6.1

### Fixed

- SpellCastBuffs: Active assistant buff icons now use the game's collectible art when no custom icon is configured, so newly added assistants display correctly.

## Version 7.2.6.0

### Fixed

- Unit Frames: Custom player completely hide Magicka or Stamina bar no longer leaves a stray bar at the frame corner; hide-bar toggles apply immediately.

## Version 7.2.5.9

### Fixed

- Unit Frames: Champion and Level info on custom target frame should now refresh properly, it was only being updated if the toggle for overland difficulty icons were enabled.

## Version 7.2.5.8

### New

- Combat Text: Optional **Show Ability Icon Frame** and **Color Icon Frame** (PC) on outgoing combat text, with frames around ability icons (round for passives, square for actives). On PC, **Color Icon Frame** tints the frame using colors sampled from each ability icon; otherwise the frame uses the default white style. Console: **Show Ability Icon Frame** only.
- Console: LUIE messages appear in the gamepad chat log; unsupported chat links no longer cause errors when clicked.

### Fixed

- Unit Frames: On the default target frame, veterancy rank and friend/guild/ignored icons stay aligned when rank or social icons show or hide.
- Unit Frames: Group DPS/HPS labels show during combat only, then hide shortly after combat ends so old values are not left on screen.
- Unit Frames: Overland difficulty icon on custom frames only when the game would show difficulty above normal (same as default nameplates).
- Combat Info: Ability alerts fade out smoothly after the cast finishes; alert icon borders and fade behavior improved.
- Chat Announcements: Skill ability experience announcements no longer fire for passives, crafted abilities, or abilities already at max rank.
- Console: Unit Frames health number format dropdowns display and save correctly again.
- Console: Toggling Action Bar bar labels no longer turns on the game's built-in action bar ability timers setting.
- PC: Unlock Default UI Frames: player interaction prompt sizing corrected.
- General stability and performance improvements...

## Version 7.2.5.7

### New

- Unit Frames: Custom target and custom small group frames: optional friend, guild, and ignored icons (separate toggles).
- Action Bar / LuiData: Cyrodiil Vengeance bag items (siege deployables, repair kit, and related gear): cast bar times, ability and buff data, and custom tooltips.

### Fixed

- Chat Announcements: Group loot messages now respect Player Name Display Method (for example @ UserID), including on localized game clients.
- Chat Announcements: Achievement updates and ignored achievement categories resolve the correct category again.
- Action Bar: Cast bar duration is more reliable for some abilities when timing comes from combat event data.

## Version 7.2.5.6

### New

- Chat Announcements: Optional announcements when an individual ability gains experience (for example from quest rewards). Per skill line under Skills: chat message and/or alert, optional icon, optional progress toward the next ability rank, and a minimum gain filter.

### Changes

- Changelog (PC): The version welcome window opens after you enter the world (load screen) instead of during addon load; closing the window marks that version as seen.
- Unit Frames: Quick Hide Dead sub-option label and tooltip clarified.

### Fixed

- Unit Frames: Default target frame: health value and percentage no longer overlap the target's level and name text.
- Unit Frames: Default target frame (Use Extender): veterancy rank icon spacing next to the alliance rank icon improved for wide rank art.
- Unit Frames: Custom player, target, and group frames: Top Info row layout improved (level, champion points, difficulty icons, and name alignment; clearer reticle target display).
- Action Bar: Reset Position for the cast bar correctly turns off cast bar move mode so the bar is not left in a bad state.
- Console: Unit Frames and Combat Text settings dropdown options display and save correctly again.

## Version 7.2.5.5

### Fixed

- Unit Frames: Default Unit Frames -> Default TARGET Frame ; Use Extender option ; Now shows Veterancy Rank Icon to the right of the Alliance Rank Icon.
- General stability and performance improvements...

## Version 7.2.5.4

### New

- Action Bar: Ultimate now shows cost instead of out of 500. While in werewolf form, the ultimate count reflects your current fury count out of 1000.

### Changes

- Unit Frames: Changed the base draw tier of unitframes so prompts will now be able to draw on top.
- MiniMap: Disabled tooltips for future me to look into fixing :)

### Fixed

- General stability and performance improvements...

## Version 7.2.5.3

### Changes

- Combat Info: Block indicator remaining-block count uses a shadow label and vertical offset on the shield art for clearer readability.
- MiniMap: Pin mirror and waypoint sync run deferred work when the world map unblocks; map reload failures no longer leave gameplay pin tickers stuck.

### Fixed

- Chat Announcements: Group invite response when you are already in a group now names the inviter correctly (matches ZOS alert handler argument order).
- Unit Frames: Custom AvA player target frame shows only for a hostile living player on reticleover when AvA target frames are enabled; TopInfo layout refreshes with frame visibility.
- SpellCastBuffs: With **Lock position to unit frames**, player/target out-of-combat and in-combat opacity from Unit Frames applies to buff and debuff icons; SpellCastBuffs container alpha no longer overrides those regions.
- SpellCastBuffs: **Show Border Cooldown** radial sweep only on timed buffs; permanent effects no longer show a cooldown layer over the icon (inset frame unchanged).
- SpellCastBuffs: When locked to unit frames, icon art, borders, inset panel, and radial cooldown tint fade together at OOC/INC opacity (per-icon alpha; avoids crushed or popped chrome).

## Version 7.2.5.2

### Fixed

- Unit Frames: Removed ZO unit frame suppression (runtime hide/release/unregister of vanilla player, target, group, and companion UI). Default hide behavior is again init-time and matches pre-7.2.5 patterns.
- Unit Frames: Default Unit Frames dropdowns are back to three choices (Disable, Do nothing, Use Extender). Removed **Disable + Unregister ZOS Events** and related strings.
- Unit Frames: Existing saves from 7.2.5.0/7.2.5.1 four-option values are mapped at load to the three-option behavior without rewriting saved variables.
- Unit Frames: Default PLAYER **Disable** now hides vanilla player attribute bars after custom frames are built, on player activated, and when the dropdown changes (fixes bars still visible when custom player frames are enabled).

## Version 7.2.5.1

### Fixed

- Unit Frames: Restored pre-7.2.5 behavior for existing Default Unit Frames saved values (read-time legacy decode until you re-select a dropdown to store the new four-option scheme).
- Unit Frames: Fixed compass boss health bars and Extender / Do nothing modes misbehaving after the 7.2.5.0 Default Frames dropdown change.
- Unit Frames: Re-show default player attribute bars when Default PLAYER Frame no longer uses a hide-vanilla mode; clear group/raid disable state when group suppression is released.

## Version 7.2.5.0

### Changes

- Unit Frames: Default Unit Frames dropdowns add **Disable + Unregister ZOS Events** as a fourth choice alongside Disable, Do nothing, and Use Extender (per-slot hide vs unregister; applies without UI reload when changed in settings).

### Fixed

- Unit Frames: Fixed UI error when updating default group Extender frames on title or rank events (TopInfo overland icon on frames without TopInfo controls).
- Unit Frames: Target champion point and level display on the default target frame refresh on title, rank, and level events when vanilla target UI is visible.

## Version 7.2.4.9

### Changes

- Action Bar: **Show Global Cooldown** now updates cooldown visuals on the LUIE backbar row as well as the active bar.
- Action Bar: Backbar base-game activation (proc) glow syncs slot use-failure state and only listens to inactive-hotbar slot/effect events.
- Chat Announcements: Inventory loot and bag updates refactored into dedicated handlers (bag, bank, craft, fence, guild bank, item delay/formatting).
- MiniMap: Removed **Camera Wedge** scale setting from PC and console settings.
- MiniMap: Native HUD player pip scaling and visibility when following the minimap vs when attached to the world map.
- MiniMap: Clarified **Moving pins (ms)** / moving pin refresh descriptions (de, fr, ru, zh).

### Fixed

- Action Bar: Fixed flickering when the base game **Ability Bar** is set to **Automatic** (LUIE no longer overrides ZOS HUD fade alpha on the main action bar control).
- Action Bar: Backbar proc glow no longer uses invalid offset slot ids when cooldown updates refresh activation highlights.
- Chat Announcements: Fixed inventory-related event registration across split inventory modules.

## Version 7.2.4.8

### New

- MiniMap: **Show during Death Recap** visibility toggle under Visibility.
- MiniMap: **Player Pip Color** and **Camera Wedge Color** pickers under Appearance.
- MiniMap: **Zone Name Font** face, size, and style submenu when **Show Zone Name** is enabled (PC).
- MiniMap: **Pin Updates** sliders for **Moving pins (ms)** and **Pin hover (ms)** under Advanced.
- MiniMap (console): **Frame Layout** with **Show Map Now**, bottom-right position offsets, and **Frame Width** / **Frame Height** (height follows width when **Keep Square Aspect** is on); settings reorganized into sections.

### Changes

- MiniMap: When **Show Zoom Buttons** is enabled, zoom plus/minus fade in on map hover.
- MiniMap: **Keep Square Aspect** resize keeps a square while respecting whether you dragged width or height.
- MiniMap: Pin mouseover and sticky-pin selection on the HUD minimap; mouseover lists update before map clicks and on the **Pin hover (ms)** refresh setting.
- MiniMap: Improved map ping handling, objective/POI pin sync, and LUIE waypoint overlay refresh after native pin updates.
- MiniMap: With **Waypoint Requires Shift**, Shift+click can clear the player waypoint on the minimap.
- MiniMap / Info Panel: **Anchor InfoPanel to MiniMap** saves and restores the Info Panel anchor when you turn anchoring off.
- MiniMap (PC): LibAddonMenu settings grouped into submenus (Zoom & Map, Visibility, Context Zoom, Appearance, Advanced).
- MiniMap: Keybind display names for minimap actions in Settings → Controls; MiniMap strings refreshed (de, fr, ru, zh).

## Version 7.2.4.7

### New

- MiniMap (BETA): Optional HUD minimap module. Enable under Module Settings on the main LuiExtended panel, then reload UI; configure under **LuiExtended → MiniMap (BETA)**. Zoom (default, subzone, dungeon, battleground, mounted), follow player, lock position and size, per-category pin scales, visibility rules (HUD, combat, looting, mounted, housing, draw tier), waypoint click behavior, and keybinds for zoom, recenter, visibility, combat, and fixed position.
- Unit Frames: Optional suppress vanilla player attribute bars, target frame, group and raid frames, and companion frame while the matching LUIE custom frames are enabled (PC and console).
- Misc Settings: **Unregister Hidden Buff/Debuff UI** stops vanilla buff and debuff UI from running in the background when the game buff UI is disabled.
- Chat Announcements: Optional **Show Item Type** on loot lines (same pattern as trait and style display).
- Action Bar: Cast bar **icon frame color** picker under cast bar settings.

### Changes

- MiniMap / Info Panel: Optional anchor Info Panel below the minimap with zone name above the map; legacy minimap clock mode removed.
- MiniMap: Shared pin draw sizing for overlays and world-map container pins; improved quest pin sync and layout recovery.
- Unit Frames: **TopInfo** row on player, target, small group, and AvA frames with level, veterancy rank, and overland difficulty icons in the caption area.
- Action Bar / LuiData: Bar highlight tracks **Hidden Blade** and **Shrouded Daggers** major brutality and major sorcery with slotted major duration caps tied to player buffs.
- SpellCastBuffs: Artificial effect overrides and tooltips for **Underdog** damage and healing and **Solo Queue** XP and AP bonuses.
- Action Bar: Cast bar label normalization for additional wayshrine recall cast abilities.
- Unit Frames: Companion **Ability Track** uses an aura cache for duration and stack feedback on companion buffs and hotbar effects.
- Chat Output: Announcements use updated tab routing so active chat tabs receive lines reliably; deprecated system-message options removed from Chat Output settings.
- LuiData 7.2.2.1: Dragonknight effect overrides and tooltip visibility fixes; LuiExtended dependency updated accordingly.

### Fixed

- SpellCastBuffs: Off Balance is no longer auto-added to **Prominent Debuffs** on first load (existing saved entries are unchanged). Prominent debuff remove list and right-click menu now match prominent routing, including the canonical Off Balance name entry.

## Version 7.2.4.6

### Changes

- Combat Info: **Synergy Tracker** has been temporarily removed from the addon while it is reworked (settings and UI will return in a future update).

### Fixed

- Chat Announcements: Fixed repeated UI errors when multiple guild bank item deposit or withdraw lines printed in the same loot queue batch.
- Chat Announcements: Guild bank loot announcements now retain the guild id per queued message so the guild name stays correct when several items are moved quickly.
- Chat Announcements: Guild bank context message formatting always passes enough arguments for multi-placeholder withdraw/deposit strings (including when the guild label is empty).
- LuiData: **Wildfire Embers** target debuff auras are no longer overridden as **Burning Embers**.

## Version 7.2.4.5

### Fixed

- Character Profile: **Enable Character-Specific Settings** now correctly applies to all LuiExtended module saved variables (including **Unit Frames** repositioning); custom frame positions no longer carry over between characters when profiles are enabled. Module data that was written to the account-wide bucket while the toggle was on may seed into the current character on first login after this update.
- Unit Frames: **Character Name** name display on custom player and target bars now shows the character name instead of following the game UI primary name preference (which could show **@UserID** when **Character Name** was selected).

## Version 7.2.4.4

### Changes

- Info Panel: Top and bottom rows reflow from a single layout pass when enabled meters change; nested rearrange calls no longer double-refresh meters. Label padding and minimum widths are adjusted for FPS, memory, latency, and bags.

### Fixed

- Unit Frames: **Reset to defaults** (and other settings that refresh boss threshold markers) no longer cause a Lua error when **CrutchAlerts** is loaded and no boss unit is present; default 25/50/75 markers apply until a boss is active.
- Unlock: Repositioned **Active Combat Tips** again apply the higher draw tier to the visible tip label text (correct control after **Update 50**).

## Version 7.2.4.3

### New

- Combat Info **Synergy Tracker**: Optional **Horizontal Icon Alignment** (left or right) when minimal display uses **Horizontal Icon Layout**; row width follows **Maximum Synergies to Display**.

### Changes

- Unit Frames: **CrutchAlerts** boss threshold mechanic labels fade in and out and only the next upcoming mechanic is highlighted when several thresholds share the same name; markers still update from cached boss health when the boss unit is absent.
- Unlock: Repositioned **Active Combat Tips** use a higher draw tier so tip text stays visible above overlapping UI.
- Combat Info **Synergy Tracker**: Unlock positioning preview stays visible during HUD refreshes while you drag the frame.
- LuiData / SpellCastBuffs: **Forceful** and **Feeding Frenzy** (stage 3) use corrected ability icons; Feeding Frenzy max-stage player buff shows in the buff tracker again.
- Unit Frames (debug): **/luiufboss** and **/luiufbosshp** preview threshold markers and step simulated boss HP (requires **Show threshold markers**).

### Fixed

- ChatAnnouncements: Legacy **TempAlert** home, campaign, and outfit slash toggles migrate into **Notify** options correctly for character-specific saved variables.

## Version 7.2.4.2

### Fixed

- Gamepad **Character Sheet**: The **Challenge Difficulty** row and dropdown are visible again after **Update 50**.
- Gamepad **Skills** and **Skills Advisor**: Custom ability icons on skill lists still display correctly after **Update 50** compatibility updates.

## Version 7.2.4.1

### Fixed

- ChatAnnouncements: Other players' overland challenge tier changes no longer spam chat; your own tier still announces once under **Notify → Challenge Difficulty**. Cooldown and combat failure alerts use the same Notify toggles.
- Unit Frames: Custom **target**, **group**, and **raid** frames now show other players' overland challenge tier icons on their names.

## Version 7.2.4.0

### Changes

- Unit Frames: **Display Veterancy Rank** and **Overland Difficulty Icon** are configured per custom frame type (**Player**, **Target**, **Small Group**, **Raid**); prior target-only toggles migrate on first load after upgrade.
- Unit Frames: Veterancy and overland difficulty display default **off** for new installs; upgraded profiles keep enabled options via migration.
- Unit Frames: Compass-integrated default boss bar no longer hides the compass boss UI unless **Compass Boss Bar** is selected.

### Fixed

- ChatAnnouncements: Take All mail loot again shows sender names on attachment lines (hireling and other system mail).

## Version 7.2.3.9

### New

- Unit Frames: Optional **Show Rapport Change** on custom companion frames shows a green **+** or red **-** beside the companion bar when rapport goes up or down.

### Changes

- ChatAnnouncements: **Update 50** announcements cover Tamriel Tomes rollover currency, veterancy rank-up notices, overland difficulty alerts, timed activity reroll reset, season recap, clearer hireling mail sender names, and large-group invite messaging aligned with the base game.
- Translations: Settings and in-game text are grouped by module (**Action Bar**, **Chat Announcements**, **Combat Info**, **Combat Text**, **Info Panel**, **Slash Commands**, **SpellCastBuffs**, **Unit Frames**, and shared options) with expanded English and updated language files.
- ChatAnnouncements Social: **Friends List Log On/Off Name Format** lets you show one name using **Player Name Display Method** (default) or both names in base-game order (**@UserID with Character Name**) with LUIE link styling.
- Unit Frames: In veterancy zones, optional **Display Veterancy Rank** on custom player, target, group, and raid frames; optional **Overland Difficulty Icon** on target names (with a monsters-only option) to match base-game nameplates.
- ChatAnnouncements: Optional notices when you unlock a set at a consolidated attunable crafting station in your home (separate toggles for chat, center-screen messages, and alerts).
- ChatAnnouncements: Optional chat and alert notices for LuiExtended **/home** and primary home, **/campaign** checks, Cyrodiil queue updates, outfit changes, and common social errors (invites, ignore list, and similar).
- ChatAnnouncements: Guild bank deposits, withdrawals, and moved items show which guild's bank you used.
- Action Bar / LuiData: Better bar highlights and stack timers for more Cyrodiil **Vengeance** kits (Vanguard, Scout, Bone Totem, and related Alliance War abilities).
- Action Bar: Cast bar supports more recall and teleport items (Mages Guild Recall, DLC-style recalls, and similar consumables).

### Fixed

- ChatAnnouncements: Guard confiscation loot no longer lists your legitimately worn gear after a weapon swap when you are caught with a bounty; only stolen items are announced.
- ChatAnnouncements: Friend online/offline messages default to a single name from **Player Name Display Method**; optional **Friends List Log On/Off Name Format** restores base-game **@UserID with Character Name** order (fixes reversed name order from 7.2.3.7).
- ChatAnnouncements: Weekly and other timed challenge updates no longer print twice when both challenge tracking and progress announcements are enabled.
- LuiData: Dragonknight **Landslide** passive stacks in the skills menu use the Landslide icon instead of Dragon Leap ground art.
- Action Bar: Recalls no longer cancel when you click a wayshrine on the world map while standing still.
- Slash Commands (PC): With **LibSlashCommander** installed, LUIE slash commands no longer register twice after **/reloadui**.
- Unit Frames: Shield, trauma, and related health bar overlays update more reliably on custom player, target, group, companion, pet, and boss frames.

## Version 7.2.3.8

### Fixed

- Action Bar / LuiData: Bar highlight taunt timers on each slotted taunt ability (including multiple taunts on one bar and on the back bar) share the player taunt debuff on your reticle target; previously only one slot updated because highlights were keyed only to debuff id **38254**.

## Version 7.2.3.7

### New

- ChatAnnouncements: Optional **Display Collection Status** on loot announcements shows a green check when a set collection piece or container collectible is already known, or a red X when it is not (**off by default**).

### Changes

- Chat Output / ChatAnnouncements: When Chat Announcements owns friend, ignore, and related social lines, default **CHAT_ROUTER** duplicates are suppressed; friend online/offline and friend/ignore Chat Announcements toggles are stored under **Chat Output** Social (**FriendStatusCA**, **FriendIgnoreCA**) and re-chain suppression when changed.
- Chat Output (PC): Per-tab routing shows an inline settings warning when no tab has both **LUIE** and **System** enabled so announcements have a deliverable tab.
- LuiData / Action Bar: **Grim Focus** and its morphs use improved stack labels and bar highlights (including reload seeding when the track buff is already active); **Leeching Strikes** cost-reduction stacks display on the visible buff via **PullStacks** tracking.
- SpellCastBuffs: Unified buff icon backdrop and **ApplyBuffIconChrome** for consistent chrome; tooltip inset textures preload to avoid pop-in; debug tooltips layout and refresh improvements.

### Fixed

- ChatAnnouncements: Taking attached gold from multiple mails individually (same amount and sender) now prints a currency line per mail again; duplicate mail gold announcements within 2.5s are still suppressed per mail (**Take All** unchanged).
- Chat Output: Announcements missing when **LUIE** was on but **System** was off; enabling **LUIE** on a tab now turns **System** on for that tab, with a settings note and one-time chat warning when no tab can receive messages.
- Action Bar: **Show Backbar** mirrors the base-game activation proc glow on inactive weapon bar slots (same highlight as the active bar when an ability is ready).
- Action Bar: **Show Triggered** proc feedback on the back bar (timed procs, instant procs, and stack-based highlights such as Necromancer skull charges) matches the front bar again.
- Action Bar: Necromancer **Flame**, **Venom**, and **Ricochet** skull charge highlights use separate tracking (**Venom** advances from the charge buff and any in-combat Necromancer ability while slotted, not only skull casts). Stack labels, proc at full charge, and clear after the empowered cast match the base game.
- Action Bar / LuiData: **Venom Skull** bar stacks show **1** through **3** when the charge buff reports three stacks (**Flame** and **Ricochet** remain **1** and **2** with proc at two charges).
- SpellCastBuffs: Necromancer skull charge buff tooltips pull live morph text from the skill sheet (localized) instead of shortened static strings.

## Version 7.2.3.6

### Changes

- Chat Output (PC): Per-tab routing grid with **LUIE** and **System** columns (up to 20 tabs). Shorter setting tooltips.

### Fixed

- Chat Output: **Print to Specific Tabs** works again with **LibChatMessage** loaded.
- Chat Output: Tab rows follow the number of open chat tabs; inactive slots stay disabled.
- Chat Output: **Display System Messages in ALL Tabs** honors **Print to All Tabs** for system-style messages.
- Chat Output: Per-tab toggles keep saved values when greyed out after LAM refresh.
- Debug environment (**/luie debug**): Persists across **/reloadui**; reload while debugging no longer resets extra addons you enabled for testing.
- Debug environment (**/luie debug**): One chat reminder per UI load while debug is active (including ingame **/reloadui**). Logout and quit still restore your prior addon selection.

## Version 7.2.3.5

### New

- SpellCastBuffs: When **Color Debuffs by Crowd Control Type** is enabled, optional **Color non-CC debuffs by damage type (cooldown fill)** plus per-damage-type color pickers tint the cooldown fill from combat-reported damage type when no crowd-control class applies.
- Misc Settings: In-game **Changelog** uses collapsible version sections with stable scroll and wrap width, and layout refresh when sections expand.
- Chat Output (PC): When **LibChatMessage** is installed, **Chat Output** settings integrate LibChatMessage time prefix, format presets, history restore, and timestamp sync for proxy output.
- Slash Commands (PC): When **LibSlashCommander** is installed, LUIE slash commands register through a shared registry for chat autocomplete and command descriptions.

### Changes

- LuiData: **Werewolf** abilities, buffs, tooltips, and bar highlights are finalized for **Update 50** (including in-form **Rampage** morphs, **Fury**, and helper-aura cleanup on the buff frame).
- LuiData: Added **Infinite Archive** and trial supplement combat alert tables merged at load for Endless Archive and additional trial and dungeon abilities.
- LuiData / Action Bar: **Sorcerer** and **Two-Handed** skill-line bar highlights and effect audits; **Necromancer** skull stack highlights keep bar highlights while stacks remain (**combatStackNoExpire**); proc stack thresholds and combat-stack tracking improvements.
- ChatAnnouncements: Guild trader sale mail with subject **Item Sold** is recognized for sender resolution and chat announcements.
- SpellCastBuffs (debug): Debug tooltips format remaining time, use an overflow column, and skip redundant rebuilds on hover.
- Debug environment (**/luie debug**): Saved-vars reconciliation after load and on logout restores addon enablement cleanly.

### Fixed

- Unlock: **Endless Archive** and **Night Market** adventure-zone HUD tracker positions persist again after **/reloadui**, zone change, and turning off **Unlock Default UI Elements** (tracker container saved-vars key on **RefreshAnchors** post-hook).
- Unlock: **Reset to Defaults** for unlock positions also clears **AlertFrameAlignment** so alert text alignment resets with other unlock data.
- Unit Frames: **CrutchAlerts** BossHealthBar integration caches handles at init instead of reading CrutchAlerts in hot paths, avoiding errors in strict debug environments when Crutch is disabled.

## Version 7.2.3.4

### New

- Misc Settings (PC) / Settings (console): **Alert Text Alignment** dropdown (Left, Center, Right) for on-screen combat alerts. Sets the default notification anchor when the frame is not unlocked, re-anchors the scrolling alert buffer to match, and applies the same alignment to **wrapped** multi-line alert lines on keyboard and gamepad.

### Fixed

- Unit Frames: Custom **Raid**, **Companion**, **Pet**, and **Boss** frames no longer render unit names larger than health/value text on stock settings. The single **Font Size** control now matches both saved fields and on-screen text without moving the slider first (including a one-time migration for existing profiles).
- Unlock: **Active Combat Tips** (dodge and synergy help) use a dedicated layout anchor so tips dismiss correctly again; saved positions migrate from the old **ZO_ActiveCombatTipsTip** unlock key.
- Unlock: Frame mover previews follow each HUD element's on-screen position. Moving one unlocked panel no longer drags other preview overlays with it (for example Equipment Status or Ram when the action bar is moved).
- Unlock: Saved positions for the compass, player XP bar, and HUD trackers are re-applied after ZOS UI refresh (compass style, XP template, tracker anchor refresh) without replacing ZOS template functions.

## Version 7.2.3.3

### New

- Unit Frames: **Companion Ability Track** adds an optional icon row on the custom **Companion** frame for companion hotbar abilities (including built-in interrupt), with optional cooldown radial, effect timer, and stack labels. Enable it under Custom Unit Frames → Companion; it is **off by default** for new installs.

### Fixed

- Unit Frames: **Use Separate Shield Bar** again shows shield on custom **Player**, **Target**, **Small Group**, **Companion**, and **Pet** frames (including live updates from settings without **/reloadui**). Companion layout reserves space for the shield row and places the **Companion Ability Track** icon row below it.
- SpellCastBuffs (debug): **Show Debug Ability ID** no longer cuts off digits on buff icons.
- SpellCastBuffs (debug): Ability IDs show on existing buffs after **/reloadui** without waiting for them to refresh.

## Version 7.2.3.2

### New

- SpellCastBuffs: **Off Balance** can now be tracked as a single **Prominent Debuff**. Adding "Off Balance" to Prominent Debuffs covers every renamed Off Balance variant, Off Balance applied by allies, and the **Off Balance Immunity** buff, all routed to the prominent target column. It is added to Prominent Debuffs once by default; remove it and it will not be re-added.
- Chat Output: New shared **chat output** settings (timestamp on/off, format and color, tab routing, and system-message handling) are now stored **account-wide** (or per-character when **Character-Specific Settings** is enabled) and shared across LUIE modules. Existing Chat Announcements chat settings are migrated automatically, and **Combat Text** now exposes the same chat output options.
- Chat Output: Added **LibChatMessage** integration on PC for better compatibility with external chat addons (such as pChat) when LUIE prints to chat.
- Chat Output: Added **rChat** integration on PC (external formatting and CHAT_ROUTER re-chaining) alongside existing pChat support when **Allow Addons to Modify LUIE Messages** is enabled.

### Changes

- LuiData: **Werewolf** abilities, buffs, and tooltips were overhauled for **Update 50**, including renamed and new skills (Gnash, Bloody Gnash, Rending Claws, Bloodclaws, Claw Fury, Rip and Tear), **Blood Hunger** stacks, the **Fury** resource, **Insatiable Hunger**, and the **Rampage** ultimate. Buff classifications were corrected (for example, Deafening Roar now grants **Major Cowardice** and **Major Maim** instead of Major Breach), and internal helper auras are hidden so the buff frame keeps the correct icons.
- LuiData / Action Bar: **Dragonknight** abilities received updated buff tracking, tooltips, and bar highlights (Lava / Volcanic / Molten Whip, Flame Lash, Power Lash, Dragonfire Breath, Engulfing Dragonfire, Dragon Blood morphs, Battle Roar, Landslide and Mantle morphs, Searing Strike, Burning Embers, and Core / Heart / Soul of Flame), with more accurate bar-highlight stack consumption and dynamic tooltip values.
- LuiData: Added tracking, tooltips, ground-effect auras, cast bar entries, and Combat Text blacklist presets for new **Arcanist** abilities, a dynamic **Fated Fortune** tooltip, and support for new **Update 50** trial abilities and effects.
- SpellCastBuffs: Prominent buff and debuff name labels were repositioned to a single line in the strip above the progress bar for a cleaner layout.
- Action Bar: Added **noRemove** handling so certain tracked bar highlights are not cleared early, and combat-event pass-through is now respected when remapping extra bar-highlight IDs.
- SpellCastBuffs (debug): Ability ID font fitting runs only when the ID text or icon layout changed, reducing per-tick cost while **Show Debug Ability ID** is enabled.
- Performance & Memory: Bounded several tables that could grow over long sessions and added cleanup on unit / viewer destruction and reloads (SpellCastBuffs buff sorting and ground / stack sweeps, ChatAnnouncements quest-item and group-loot tracking, Combat Text event viewers, Crowd Control animation cache and Synergy Tracker eviction, Group Resources callbacks, Unit Frames attribute visualizers, and dodge-prediction / power-update handling).

### Fixed

- SpellCastBuffs (debug): **Show Debug Ability ID** on pooled buff/debuff icons no longer intermittently fails to draw the numeric ID (most noticeable on target buff routing) after icons are recycled from the shared pool. Pool reset clears per-icon text caches, slot rebind refreshes the ID label, and **LabelControl:Clean()** runs before truncation checks when font fitting runs.
- SpellCastBuffs: **Show Block Player** brace icon displays again when full display rebuilds are not forced every tick. The synthetic block effect is updated in place while blocking, and the display sorter includes effects whose start time equals the current update (not only strictly earlier).
- SpellCastBuffs: **ClearPlayerBuff** and **ClearFakeEffectEntry** only mark the display dirty when an effects-list row was actually removed, instead of every 100 ms while not blocking with Show Block Player enabled.
- SpellCastBuffs: Target buff and debuff icons no longer linger after clearing reticle; **ReloadEffects** now marks the display dirty when target lists are cleared (empty reticle or dead unit).
- Unit Frames: Compact (**Raid**) name labels now grow to fit the caption font size instead of being shrunk by the game, the **Raid Name Clip** slider hides or clips names correctly across its full range, and the raid layout now refreshes all 12 slots so size / clip changes preview while solo and empty slots no longer keep stale geometry.
- Unit Frames: The no-healing (healing-absorbed) overlay and the damage shield now layer correctly above the health fill on custom frames.
- ChatAnnouncements: Alert and loot-history hooks are now installed only once, preventing duplicate announcements if module setup runs again in the same session.

## Version 7.2.3.1

### Fixed

- Unit Frames: Per-category **Font/Texture** settings now show **Font Size (Label)** and **Font Size (Bar)** only for **Player**, **Target**, **Group** (small group), and **AvA** frames that use a separate top caption row. **Raid**, **Companion**, **Pet**, and **Boss** use a single **Font Size** slider for all text on the health bar (name and values). Compact frames with different saved label and bar sizes now render one consistent size until you change that slider (both saved values update together when you do).

## Version 7.2.3.0

### Changes

- Unit Frames: Player and Target **Display Power Change Overlay** now default to **off**. A one-time migration turns the overlay off for existing saves that still had the previous default (on). Re-enable under Custom Unit Frames if you want the increased-power halo.
- Unit Frames: When that overlay is enabled, increased power and possession animated halo textures on the custom **health bar** tint with the same RGBA as the health bar when LUIE applies custom frame colors.

### Fixed

- Unit Frames: Custom frame unit names now always use **Font Size (Label)** for that frame type (Player, Target, Group, Raid, Companion, Pet, Boss, AvA). Names on raid, pet, and similar layouts that sit on the health bar no longer incorrectly use **Font Size (Bar)**, which could make names render smaller than the label size in settings (for example size 16 on screen while the slider shows 22).

## Version 7.2.2.9

### New

- ChatAnnouncements: Adventure Zone faction reputation gains are now announced in chat as loot-style messages (with optional icon and optional running total, matching your Loot settings).
- SpellCastBuffs (debug): Tooltip debug meta now supports an overflow tooltip column so large debug dumps don’t run off-screen.

### Changes

- Unit Frames: Next roll dodge prediction now tracks **Dodge Fatigue** stacks from buffs (and refreshes on stack changes) for more accurate predicted stamina cost.
- SpellCastBuffs (debug): Debug meta now lists all Derived/Advanced stat rows (no longer capped to a small number of rows), with overflow handled via the secondary tooltip.
- Unit Frames: Increased Power / possession halo visuals better match the health bar (layering + bar texture/color consistency) and avoid showing the animated halo in the empty portion of the bar.

### Fixed

- LuiData: Maelstrom 2H (Merciless Charge) set buff tooltip text is now correct and uses the proper dynamic description source.
- LuiData/Debug: Updated Maelstrom-related debug aura/result mappings and corrected minor label issues (for example “HEAL ABSORBED”).

## Version 7.2.2.8

### Fixed

- Unit Frames: Roll dodge stamina indicator on the custom player bar now follows **Left to Right**, **Right to Left**, and **Center** stamina bar alignment settings.
- Unit Frames: With **Center** alignment, the dodge indicator uses two lines that bracket your stamina after the next dodge (the band moves inward toward the middle as stamina drops).
- Unit Frames: Roll dodge prediction includes **Medium Armor Athletics** dodge cost reduction (per piece of medium armor worn).
- Unit Frames: Roll dodge indicator tracks more smoothly when **Custom Smooth Bar** is enabled on player frames.

## Version 7.2.2.7

### Changes

- Changelog: Moved changelog code so it would only load on PC (not supported on console at this time).
- ChatAnnouncements: Added more Night Market chat settings.

### New

- Unit Frames: Optional next roll dodge indicator on the custom player stamina bar (PC and console, default off). A vertical line shows where your stamina would be after one dodge; it turns red if you cannot afford that dodge. Updates for **Dodge Fatigue** and for **Expert Evasion** when that champion perk is slotted on your bar.
- Combat Text: Optional setting **Show ability cast costs as drain (Incoming)** (PC and console, default off). **Display Resource Drain (Incoming)** still shows drains from the combat log unless you enable cast-cost display.

### Fixed

- Combat Text: Fixed duplicate mitigation floating text (for example two **Immune Bash** lines when bashing a hard-targeted immune enemy out of range).

## Version 7.2.2.6

### New

- ChatAnnouncements: Display Announcements for **Event Zone: Night Market** (PC and console). Separate chat, center-screen, and alert toggles for **Daring Race**, **Arachnid Invasion**, and **Guiding Light** Still missing some; will be added when I see them.
- Classified Night Market [C]EVENT_DISPLAY_ANNOUNCEMENT[/C] lines by activity text (not whole zone 1559): Daring Race (for example Tempest earned, race objectives, Daring Race: … Complete, Void Collapse); Arachnid Invasion (invasion begins, defense complete, invasion repelled); Guiding Light (countdown, begins, complete, and reward earned lines such as Agonizing Tether or Exsanguinate).

### Changes

- ChatAnnouncements: Display Announcement debug (when enabled) also logs category, icon path, and lifespanMS to help report new center-screen text on the ESOUI thread.
- PC settings: Font face and font style dropdowns preview each entry in the list (LuiExtended fontable_dropdown LAM control; fixed preview size, no dependency on a forked LibAddonMenu). Texture dropdowns preview status bar art (textureable_dropdown) for Unit Frames per-category appearance, Action Bar cast bar, and Buffs & Debuffs prominent progress texture.
- Unit Frames: Changing font or bar texture under a Custom Unit Frames appearance category (Player, Target, Group, etc.) reapplies only that category instead of refreshing every custom frame type on each slider or dropdown change.

### Fixed

- Combat Text (PC): All color picker defaults in settings now include alpha so LAM Reset to Default restores full RGBA (opacity), not RGB only.

## Version 7.2.2.5

### Fixed

- ChatAnnouncements: Smithing and universal deconstruction (station deconstruction tab, Giladil, and LibLazyCrafting deconstruct queues such as Dolgubon's Lazy Writ Creator) now use deconstruct/receive item messages (and extract for glyphs) instead of craft/use. Destroyed gear no longer shows as "You use." LibLazyCrafting provisioning writs and other active craft/improve paths still use craft/use labels.

## Version 7.2.2.4

### New

- Action Bar: Out-of-combat and in-combat opacity sliders (0-100%) under Display Options. Affects the game action bar (ZO_ActionBar1, including LUIE backbar and slot overlays) and the cast bar when cast bar is enabled. PC and console.
- Buffs & Debuffs (SpellCastBuffs): Out-of-combat and in-combat opacity sliders under Position and Display. Applies to each active buff/debuff container (floating top-level windows or unit-frame-locked buff/debuff regions).
- Combat Text: Replaced single Set Transparency with separate out-of-combat and in-combat sliders (0-100%). Existing saves copy the old value to both. PC and console.
- Combat Info - Synergy Tracker: Out-of-combat and in-combat opacity sliders under Display Options (0-100%, same style as unit frames).
- Combat Info - Synergy Tracker: Display mode Icon + Cooldown (minimal) and Hidden (no HUD list; detection, sounds, blacklist, and priority overrides still run). Optional horizontal layout for minimal. Right-click synergy rows for priority (game default and 1-10) and blacklist. Minimal mode uses tiered sort (ready -> active waiting -> cooldown -> idle).
- Unit Frames: Custom frame font and bar texture are no longer one global set for every frame. Under Custom Unit Frames, Font/Texture Settings provides separate profiles for Player, Target, Group, Raid, Companion, Pet, Boss, and AvA (font, font style, label size, bar size, texture). Existing saves copy your previous global custom font/texture into all eight categories on first load. PC uses nested submenus; console uses a dedicated Font/Texture Settings section. Group broadcast overlays (combat stats, potion cooldowns, food/drink buff, group resources) use the Group profile (raid potion labels use Raid when on raid frames).
- Buffs & Debuffs: Optional Display API debug on Tooltip (PC, under Tooltip Options). Hovering a buff icon can show status effect type, ability type, API buff slot, LuiData EffectOverride/CC hints, and live list-index timing overlay lines for tuning icons and tooltips.

### Changes

- Unit Frames: Attribute visual updates (shield, regeneration, stat change) use coalesced power updates and cached visual state to cut redundant bar refreshes.

### Fixed

- Action Bar / Buffs & Debuffs: Opacity sliders apply reliably after /reloadui (uses live ZO_ActionBar1 at apply time; buff containers re-apply when HUD fade resets alpha). Combat state still updates OOC vs in-combat values.
- ChatAnnouncements: Fixed duplicate weekly challenge progress lines when two identical challenges advance at once (for example four chat messages instead of two). Progress and Tracking announcements no longer double up for the same challenge slot; each slot still announces separately.
- Buffs & Debuffs: Fewer duplicate buff icons when ground auras and target buff/debuff rows route to the same container (shared-container dedupe and per-container ability dedupe on refresh).

## Version 7.2.2.3

### Fixed

- SavedVariables (7.2.1.7+ split): Additional migration repair scans profile Default and your megaserver row (GetWorldName()) so module settings are not left on defaults when a second @account had an empty megaserver shell, when backups reintroduced pre-split LUIESV data, or when split migration finished before legacy namespaces were cleared. Pruning `LUIESV["Default"][@You]` on disk now waits until that repair completes. InstallExternalSavedVarsLegacyCompat no longer deletes the entire on-disk `LUIESV["Default"]` tree when that helper runs (which could remove other @accounts' only copy). The LUIESV.Default legacy read path / metatable compat for Srendarr still only loads on PC when Srendarr is enabled (not used on console).
- New slash: /luie svstatus prints migration flags, whether LUIESV still holds legacy module tables, and a quick population hint per split global (paste for support).
- Support tips: Megaserver EU vs NA use separate saved-variable profile rows; switching regions can look like a reset until you configure or copy settings per megaserver (LAM Character Profile copy). Restoring backups from AutoBackup or similar should include every SavedVariables global listed in the addon manifest (LUIESV and all LUIE_*_SV), not LUIESV alone, and preferably while the game is closed.
- SpellCastBuffs: Buff and debuff icon borders should look like the stock buff bar again.

## Version 7.2.2.2

### Fixed

- ChatAnnouncements: Prevent malformed display-name chat links (empty link payload) that could crash pChat when copying or formatting system messages. Names are normalized before building links; guild, friends, mail, group loot indexing, duel alerts, and related paths use shared helpers.
- ChatAnnouncements: Duel invite failure alerts now pass character vs display name to name resolution in the correct order.
- ChatAnnouncements: Group loot member index falls back to character name when unit display name is not yet available.

## Version 7.2.2.1

### Fixed

- ChatAnnouncements: When Loot Mail is enabled, "Mail received." and "Mail deleted!" are no longer shown while mail attachments are being looted (for example hireling batches via auto-mail addons). Item loot lines still print.
- ChatAnnouncements: Fixed repeated "You receive mail with … Gold from …" lines after auto-looting mail and fast traveling. Mail session resets on zone load and mailbox close, inbox updates no longer refill the take queue when the UI is gone, and duplicate mail gold lines within 2.5s are suppressed.
- ChatAnnouncements: Hireling / auto-mail loot: correct sender per attachment (FIFO queue), no pre-filled inbox queue on mailbox open, hireling names from GetMailSender when journal info is empty (fixes "from []"), mail item lines while the mailbox UI is not open.

## Version 7.2.2.0

### Changes

- Console settings: Smoother menu navigation when browsing module options, and options that depend on another setting now grey out or update right away without leaving the menu.
- Console: Changing fonts in several modules (Action Bar, Combat Info, Combat Text, Info Panel, Buffs & Debuffs, Unit Frames) is applied after you Reload UI, with a reminder in chat and in the menu, which helps avoid memory issues on console.
- Console: When moving UI elements, position numbers and preview names (unit frames, buff windows, cast bar, combat text, alerts) are easier to read on screen.

### New

- ChatAnnouncements: Quest Kill Counter Filters. Some quests show a center-screen or alert on every kill for a counter objective. Add a filter per quest so you only see the updates you care about.
- LuiExtended settings, Chat Announcements, Quest Kill Counter Filters. Turn on Enable, enter the quest name from your journal, optional objective text if you only want one step filtered, choose Milestones (kill counts like 25, 50, 75), Hide all, or Complete only, then Add Filter.
- PC: pick a rule under Remove Filter or use Clear All Filters. Console: Manage Filters to remove a saved rule. Changes apply right away; you do not need to reload the UI.

### Fixed

- Console, Action Bar cast bar: Turn the cast bar on/off at the top of the section; other cast bar options stay disabled until it is on. Reset Position moves the bar back, updates the position sliders, and turns off Unlock Cast Bar so the bar is not left hidden.
- Action Bar: Reset Position works even when adjusting position from the menu, and the X/Y sliders match where the bar actually sits.
- Console settings: Section description text no longer highlights as if it were a setting you could change.
- Console: Slash Commands settings could fail to open.
- Console, Unit Frames: Position coordinates show again while custom frames are unlocked and you move them.
- ChatAnnouncements: Fixed repeated "You receive mail with … Gold from …" lines after auto-looting mail and fast traveling (for example hireling gold then porting to a guild house). Mail session state now resets on zone load and mailbox close, inbox updates no longer refill the take queue while the UI is gone, and duplicate mail gold currency lines within 2.5s are suppressed.
- Combat Text: Group death notifications no longer show a missing name (for example " died!") when "Use account name" is enabled. Display name now falls back to character name, and alerts are skipped when no name is available.

## Version 7.2.1.9

### Fixed

- Unlock: Moving the Quest Log with frame movers now keeps the world-event progress HUD (dynamic events tracker`, ritual/world-event objectives such as adventure zone skirmishes) stacked directly above the quest log instead of leaving it at the default screen position.

## Version 7.2.1.8

### Changes

- SavedVariables: Third-party addons that still read `LUIESV.Default[@DisplayName]["$AccountWide"]` (for example Srendarr checking LuiExtended unit frame options) are supported again`, Default resolves to this session's megaserver profile (GetWorldName()), and module namespaces such as UnitFrames on that path overlay the split module globals after migration.
- Character Profile copy (PC and console): Clearer settings labels and tooltips for megaserver, @account, copy source, and source character (less internal "row / saved vars" wording).
- Combat Text: "Show Throttle Trailer" tooltip wording updated (default and locale strings), which describes the (N) suffix on merged totals and that throttle ms sliders control combining hits, not this checkbox.

### Fixed

- Combat Text: Attempt to fix throttle ms sliders appearing to do nothing at 0, a 0 ms setting now bypasses the merge buffer and shows each combat event immediately instead of deferring with zo_callLater (which still merged same-frame hits); critical damage/heal/DoT/HoT throttle times follow the same four sliders as in the menu (damage, DoT, healing, HoT) instead of separate unused *critical saved vars left at 200 ms.

## Version 7.2.1.7

### Major change

- SavedVariables layout: module settings now live in separate account-wide globals (LUIE_UnitFrames_SV, LUIE_CombatText_SV, LUIE_ChatAnnouncements_SV, LUIE_SpellCastBuffs_SV, LUIE_ActionBar_SV, LUIE_InfoPanel_SV, LUIE_SlashCommands_SV, LUIE_CombatInfo_SV) alongside LUIESV (see the addon manifest). Megaserver-specific rows use the ZO_SavedVars profile from your world name; legacy data under profile Default is migrated on load (expect one reload after updating).
- PC (LAM) and console (LibHarvens): Character Profile "Copy Profile" uses three controls`, source megaserver profile, @DisplayName, then $AccountWide or a character row matching LUIE.SVVer. The copy writes that path into this session's target row for LUIESV and every module global above.

### New

- Slash command /luie debug on`, saves your current AddOns enable state, disables everything outside the LUIE debug allowlist (LuiExtended, LuiData, LuiMedia, LibMediaProvider; PC: LibAddonMenu-2.0; console: LibHarvensAddonSettings and LibConsoleDialogs), then reloads the UI.
- /luie debug off`, restores the saved state and reloads; /luie debug status (or /luie debug alone) reports whether debug environment mode is active.
- After reload, a one-shot chat line confirms debug mode or that your addon list was restored.
- Info Panel: Optional memory display on the top row (after FPS). Console shows add-on memory pool used/capacity (MB); PC shows approximate Lua heap size (no forced GC on the HUD tick). Toggle under Info Panel elements; on console, pool fill uses the same read-only color tiers as FPS/latency when enabled.

### Changes

- Custom Tooltips: Updated the RU lang strings for Battle Spirit`, thank you Impda.
- PC settings (LAM): FPS Limit slider maximum raised to 999 (vanilla interface settings only go up to 100).

### Fixed

- Info Panel: FPS readout is rounded and capped at 999, matching the built-in performance meter (fixes showing one FPS lower than the game meter, for example 164 vs 165).
- UnitFrames: Fixed custom frames rendering below in-world 3D overlays (for example survey reset marker arrows and similar icons).
- UnitFrames: Player stamina bar anchor now matches Health-to-Magicka layering (correct bar inheritance).
- UnitFrames: Custom frames use draw tier MEDIUM instead of LOW (player, target, group, raid, pet, companion, boss, AvA target).
- UnitFrames: Out-of-combat alpha refresh no longer skips the first apply when combat state was still unset.
- UnitFrames: LAM`, in-combat/OOC alpha and hide-buff-OOC changes from the menu reapply immediately; boss/companion/pet opacity sliders use the same immediate path.
- UnitFrames: LAM`, player/target OOC and in-combat transparency sliders no longer unhide other custom frame windows as a side effect.
- UnitFrames: LAM`, layout preview is split per frame (player, reticle target, AvA player target) so bar and chrome tweaks only affect the frame you are editing.
- UnitFrames: LAM`, player name vs target name display no longer pops the wrong custom frame window.
- UnitFrames: Custom reticle target`, AvA rank icon hidden when rank is zero; rank chrome can refresh without full static control updates (avoids buff/debuff anchor clashes).
- ChatAnnouncements: Opening a container (including from inventory) no longer prints looted gold before the "You empty [container]" line; gold flushes after that line.
- ChatAnnouncements: Mail Take All`, correct sender per mail, proper queueing, dedicated delayed loot lines, and flush order so gold and attachments match the mail you took.
- ChatAnnouncements: Batched crafting "You use" lines list consumed materials in station order (smithing, provisioning, alchemy) instead of sorting by item id.
- ChatAnnouncements: Rare group-join lines with raw gamepad name-icon markup or broken links when gamepad UI was active`, join messages now build name links from raw event names.
- Combat Text: Ability costs can show as incoming resource drain even when the game never sends a native power-drain combat result (matched via slot use + power update, with dedupe so you do not get two lines).
- Combat Text: Inferred drain no longer blames unrelated pool ticks (for example sprint stamina) on the wrong bar ability.
- Combat Text: Group death alerts and alliance-point SCT use the correct event payload again.
- Combat Text: Champion points`, correct event wiring to the point panel, player filter, and cap detection via CanUnitGainChampionPoints.
- Combat Text: Resource energize/drain respects mechanic bitflags; self-target costs follow outgoing toggles with sensible merge for one-sided incoming settings.
- Combat Text: Event viewer`, ultimate energize formatting, drain colors, and abbreviated drain amounts no longer double the minus sign on negative hit values.

## Version 7.2.1.6

### Changes

- SpellCastBuffs: Many buff tooltips now use the game's current skill description instead of outdated fixed text. Custom text still applies where we intentionally override (for example Brace, Sneak, champion skills, and armor passives).
- SpellCastBuffs: With Custom Tooltips turned off, morph-related buff tooltips still apply correctly instead of being wiped by the default path.
- InfoPanel: Internal cleanup only`, on-screen behavior should match what you're used to.
- Tooltips: Minor behind-the-scenes tidy-up for damage-type wording on abilities.
- Added support for Tonic of Portent Favor (shows like other XP-style buffs with correct icon and tooltip).

### Fixed

- ChatAnnouncements: When several enchanting runes are announced at once, they list in the same order as at an enchanting station (potency, then essence, then aspect).
- ActionBar highlights: Templar Cleansing Ritual morphs (base, Ritual of Retribution, Extended Ritual) keep reliable duration tracking on the bar.
- Igneous Weapons: removed an extra Major Sorcery bundle buff so you don't see two overlapping Sorcery icons from that skill line.
- Molten Armaments: bundle tooltip matches the morph description; Sneak stealth buff uses up-to-date sneak text and avoids duplicate sneak rows when stealth is tracked.
- Mirage: Extra Buffs no longer shows a duplicate fake combat buff next to the real morph aura.
- Siphoning Attacks (bundle and morph); Feral, Eternal, and Wild Guardian; Inferno / Incinerate / Cauterize aura buffs`, tooltips aligned with the skills window.
- InfoPanel: Backpack space (used / total) updates reliably after destroying items, after large inventory syncs, and when materials move into the craft bag.
- Combat Text: Test Font and Test Animation in settings now dispatch preview events on the combat event listener instead of the global callback manager, so preview text shows again (PC LAM; console animation test).

## Version 7.2.1.5

### Fixed

- revert test code. thank you all who participated.

## Version 7.2.1.4

### Fixed

- Gamepass api change

## Version 7.2.1.3

### Fixed

- ActionBar: when Fancy Action Bar (FAB/FAB+) is loaded, companion quickslot re-anchoring is skipped so FAB's post-bar-swap layout is not overwritten (fixes quickslot jumping when using both addons).

## Version 7.2.1.2

### Fixed

- address nil value error in UnitFrame

## Version 7.2.1.1

### Fixed

- Unlock (PC): Night Market favor counter`, frame mover matches the real counter again instead of an oversized box.
- Unlock (PC): turning on UI unlock no longer shows the favor mover across the whole screen the first time (before you move it or reload).

## Version 7.2.1.0

### New

- ActionBar: companion ultimate tracking`, optional value and percent labels on the companion ultimate slot (font, colors, vertical offset, hide when full); quickslot/keybind layout follows ZOS companion anchor chain when the companion button is shown.
- CombatInfo (console): reset-to-defaults restores the module's saved settings from defaults and refreshes Ability Alerts and Crowd Control Tracker UI.
- UnitFrames (debug): new /luiufall`, toggles every custom-frame preview at once, temporarily enables frame-move mode for layout, and restores the previous unlock state when turned off.

### Changes

- Unlock: ZO_AdvZoneHUD_TopLevel (Night Market favor counter) mover uses ZO_HUDTelvarMeter width/height when present so the frame tracks the Telvar/stone meter layout.
- UnitFrames: custom frame color handling updated to respect saved alpha values.
- UnitFrames: CrutchAlerts Boss Health Bar integration`, uses the current API (including per-boss boss1/boss2 threshold tables when the encounter provides them); stack-level percent labels above the boss block and rotated mechanic names below; shared thresholds draw a single line through all visible boss bars; listens for BossHealthBar.RegisterThresholdsChangeListener so programmatic overrides refresh markers; ACTIVE / IMMINENT / PASSED tinting matches Crutch bar colors and updates as boss HP changes (rounding follows Crutch useFloorRounding when Crutch is loaded).
- Settings (PC & console): boss threshold marker anchor dropdowns removed (obsolete with the stack layout); X/Y controls are a horizontal nudge for both label rows and shared vertical padding from the bar block.
- DependsOn: LuiData minimum version raised to match bundled data (see manifest).
- LuiData: Battle Spirit custom tooltip strings updated for U49 (33% healing reduction when 8 or more HoTs are active; Cyrodiil includes the ability-range line, Imperial City does not). German and French strings pulled from live client text; Russian Battle Spirit lines remain English until a verified localization export is available.
- Internal: several modules now use ZO math globals (zo_floor, zo_max, zo_min, etc.) instead of math.* for consistency with ESO UI code.
- UnitFrames (debug): slash-command previews for individual frames`, /luiufplayer, /luiuftar, /luiufsm, /luiufraid, /luiufpet, /luiufboss, /luiufcomp, /luiufava show enabled custom frames with live player power and labels.
- Settings (PC & console): custom frame unlock checkbox and grid-snap overlay refresh use UnitFrames.CustomFramesMovingState (removed duplicate local moving flag).

### Fixed

- SpellCastBuffs: artificial effect handling aligned with the live id table (0 ESO Plus through 8 Solo Queue AP bonus). Imperial City Battle Spirit (id 3) is shown with the IC tooltip instead of being treated as Battleground Deserter; LFG (id 2) uses the LFG tooltip; deserter cooldown logic applies to id 4 only; Underdog / Solo Queue entries (5–8) keep API timing instead of inheriting the old id-3 behavior.
- LuiData: Looking For Group artificial-effect display name now reads GetArtificialEffectInfo(2) (was incorrectly using index 1).
- Stats screen (keyboard & gamepad): optional artificial-effect Ability ID debug lines updated to the same id map as SpellCastBuffs.
- UnitFrames: boss threshold markers and mechanic labels align to the health bar (labels were anchored from the bar center horizontally; lines used the left edge).
- UnitFrames: boss threshold markers clear when no boss units exist (wipe / despawn) instead of lingering on screen.
- UnitFrames: custom group/raid frame repositioning`, member controls have mouse disabled while moving so the top-level window reliably receives drags.

## Version 7.2.0.9

### New

- Unlock: Dynamic Events Tracker (Night Market) mover.

## Version 7.2.0.8

### Fixed

- General: Swapped to using zo_callLater. it might make the code happy, who knows...

## Version 7.2.0.7

### Fixed

- General: Fix a API change from update 50 that made it to live.

## Version 7.2.0.6

### Fixed

- ChatAnnouncements: incorrect items were showing as being confiscated.

## Version 7.2.0.5

### Changes

- Unlock: Added base UI unlock for battering ram status indicator.

## Version 7.2.0.4

### Changes

- SlashCommands: `/cake` and `/jubilee` should now work without needing yearly updates...

### Fixed

- Error when clicking link for timed activities due to 11.3.5 code change in the `ZO_TimedActivities_Manager` Class.
- Action bar: Flame Lash / Power Lash proc icon flicker (GitHub #379). `SetupActionSlot` no longer applies `BarIdOverride` for proc/base pairs flagged in `IsAbilityProc` / `BaseForAbilityProc` (global `actionbutton` hook; disabling the ActionBar module alone did not avoid it).
- Action bar: Power Lash stack buff (abilityId 34117, U41+ 5x / 20s). bar highlight tracks combat/buff data via `combatTrack`, toggled labels show stacks and timer; stacks decrement on Power Lash cast (`OnAbilityUsed`), timer and overlay clear when stacks reach zero; sync from `EVENT_EFFECT_CHANGED` / combat when ZOS reports zero stacks.

## Version 7.2.0.3

### Fixed

- Error on player interaction.

### New

- SpellCastBuffs: setting to move the player long buffs container.

## Version 7.2.0.2

### Fixed

- Info Panel / font system: fixed crash "Checking type on argument fontStyle failed in GetFontStyleString_lua" when SavedVariables contained a display string (e.g. |cFFFFFFNormal|r) or invalid FontStyle. Migration and font creation now normalize values and use a safe default; Info Panel and SpellCastBuffs use the shared wrapper so only valid FontStyle integers (0–7) are passed to the game API.

## Version 7.2.0.1

### New

- UnitFrames: option to hide the custom player frame when dead; the frame shows again when you are alive.
- UnitFrames: option to keep the custom target frame visible in cursor mode; when the reticle target is cleared (e.g. opening inventory or map), the frame and its SpellCastBuffs target icons can linger with the last target's data. Optional auto-clear after 5–30 seconds (or never).
- Info Panel: option to hide the panel in combat; it becomes visible again when combat ends.

### Changes

- UnitFrames: custom player and target frame bar width slider max increased from 500 to 1000.

## Version 7.2.0.0

### New

- ChatAnnouncements: support for new currency types (Seals, Trade Bars); settings, labels, and tooltips updated across languages. Tome Points and cache handling improved.
- ChatAnnouncements: furnishing vault announcements and related event handling.
- ChatAnnouncements: track multi versus single weekly challenges, with settings and localization (DE, FR, RU, TR, default).
- GridOverlay refactor: functionality and settings updated; new XML, bindings, Unlock/BlacklistDialog, SpellCastBuffs/UnitFrames integration, AbilityAlerts/Changelog frontend touched.
- UnitFrames: optional hostile flag for attribute visuals.

### Changes

- ChatAnnouncements: instanceDisplayType changed to zoneDisplayType to align with api doc.
- SpellCastBuffs: event callback tweaks (Collectibles, ReloadEffects, Stealth); furnishing vault and related logic.
- ChatAnnouncements: merge from main (PlayerToPlayer hooks, settings_tweaks); gamepad behavior adjusted.
- LuiData effects: broad updates across BarHighlight, Fake effects, Overrides, KeepUpgrade, OakenSoul, and related namespaces.
- BarHighlight: populate table on player activated (DestroFix); ActionBar cleanup and BarHighlight data/override updates.
- ActionBar: nil checks and robustness.

### Fixed

- SpellCastBuffs: artificial effect logic.
- Hand of Mephala: LuiData KeepUpgrade/Override, AbilityTables, UnitNamesTable, ZoneNamesTable, and data namespace.
- LuiData AbilityTables fix.
- SpellCastBuffs and UnitFrames: missing saved-variable defaults and tooltip fixes.
- ChatAnnouncements: debug formatting.

## Version 7.1.5.0

### Changes

- Block Indicator is off by default. You can enable/disable it in the Combat Info settings.

## Version 7.1.4.9

### Fixed

- SpellCastBuffs now sort correctly.
- Fixed texture path in buff module.

### New

- Block Indicator: Located in the CombatInfo module.

## Version 7.1.4.8

### Fixed

- Oakensoul buff filtering works again.

## Version 7.1.4.7

### Fixed

- Backend change to buff modules controls to utilize object pooling.

## Version 7.1.4.6

### Fixed

- ActionBar timers should be working again for abilities we have data on and ultimates.
- Buffs module changes - fix to how to controls were being drawn.

## Version 7.1.4.5

### New

- If using the LUIE ActionBar, you can now pick up and drag abilities between bars using mouse mode.
- If using the LUIE ActionBar with back bar enabled, equipping OakenSoul or anything that overrides the player bars temporarily will hide the backbar.

### Changes

- ActionBar module no longer creates highlight texture if FancyActionBar is enabled. Requested change due to double highlights.

### Fixed

- Lua Error on Companion level up. Reported on Github. Thanks
- Proc sound for 5/10 stack of Merciless Resolve, 4/8 stack of Crystal Fragments now play.
- Added a check to ActionBar.Castbar to prevent nil errors.
- Fixed manifest so Minion 4 should now work correctly.

## Version 7.1.4.4

### Changes

- PVP/AVA/BATTLEGROUND center screen announcement size changed from large -> small.

## Version 7.1.4.3

### New

- Extended chat announcements to cover more pvp/ava events, system broadcasts, eso plus, outfit change, daily login reward, tales of tribute.

### Changes

- Rewrote all control creations to utilize XML, this is a performance improvement.
- Split data/media into libraries: [LuiMedia](https://www.esoui.com/downloads/info4374-LuiMedia.html) centralizes all media registration to prevent redundant table creation for modules that use custom media, work only needs to be done once right :) [LuiData](https://www.esoui.com/downloads/info4373-LuiData.html)
- Moved action bar related things in combat info into a new action bar module; existing settings should be migrated.

### Fixed

- Resolved a long-standing Memory leak in the combat text module :eek:

### Miscellaneous

- There is probably stuff I missed in this log, but it has been an ongoing project on console, it is about time to get PC on the same version with the fixes.

## Version 7.1.4.3

- more ps5 texture tweaks.

## Version 7.1.4.2

- more ps5 texture fixes

## Version 7.1.4.1

- hopefully fix to some ps5 textures....

## Version 7.1.4.0

- Major bug fix and changes.
- Memory leak from combat text should be fixed, it was in all my test scenarios.
- Movers now use x/y sliders.
- TODO: Fix movers for Combat Text panels.

## Version 7.1.3.11

- feat: move info panel to xml.
- fix: unitframe stuff

## Version 7.1.3.9

- fix: champ star pixelation on ps5
- feat: move custom unitframe control creation code to xml.
- feat: move ability alert creation to xml and utilize object pools.

## Version 7.1.3.8

- Migrates SpellCastBuffs to an XML + metapool architecture, adds a new SynergyTracker UI, consolidates ActionBar management into the module, and updates related namespaces, settings, and event handling.
- SpellCastBuffs (major refactor): Migrates UI to XML (TopLevelControls + virtual LUIE_SpellCastBuffIcon), adds mouse/tooltip handlers, grid-snap move support. Rewrites to method-based API (ZO_Object), centralizes event registration, and uses ZO_MetaPool for icon pooling/perf. Enhances prominent bars/labels, cooldown/stack handling, disguise/mount/WW logic; updates settings/invoke sites.
- SynergyTracker (new UI): Adds XML-driven tracker and controller with rows, cooldown overlays, tooltips, HUD scene integration, and movement save.
- ActionBar (consolidation): Merges manager into module, centralizes events/helpers, backbar handling, cooldown hook logic; removes ActionBarManager.lua.
- CastBar/Namespaces: Adjusts module names/event registrations; cleans up CombatInfo/AbilityAlerts namespace setup.
- Infrastructure: Version bump, GridOverlay docs/manager polish, settings/initialization updated for method calls.

## Version 7.1.3.7

- fix: console errors when interacting with a player
- NEW LOADING LOGIC FOR CONSOLE! If ESO is not in focus, LUIE will not load until it is, this prevents many CPU budget errors, if you experience this(grey unit frames/black icons) you need to port to a house or go through a door that triggers a load screen to refresh the ui without reloading.

## Version 7.1.3.6

- fix: synergy tracker restore placement on reload

## Version 7.1.3.5

- fix: Unitframes settings options

## Version 7.1.3.4

- fix: Adjust InfoPanel position calculation to use center coordinates instead of top-left coordinates.
- fix: Update companion ultimate cost calculation in ActionBar module.
- fix: Collectibles we don't have data for were showing the default unknow icon in the Chat Announcements, switched to using the games API to parse the link if we don't have the data.
- change: Swapped to using ZO_Currency_GetPlatformCurrencyIcon in Chat Announcements.
- change: buff icons are being worked.

## Version 7.1.3.3

- more settings fixes

## Version 7.1.3.2

- fix: backbar for actionbar was not able to be enabled in the settings menu

## Version 7.1.3.1

- settings menu rework, now uses submenus
- edit mode should now work better, no more needing to open another menu to make the backdrop clear
- fixed reported errors from multiple discord reports, thanks all, keep reporting.

## Version 7.1.3.0

- Console settings overhaul. Many things still need tweaks. will be doing updates regularly to address issues.

## Version 7.1.0.7

### New

- Crowd Control Tracker preview window with pooled controls so players can experiment with stun/immobilize visuals and the updated charm handling outside combat.
- Unlock-mode grid overlay rebuilt as a pooled control system, tied into SpellCastBuffs and UnitFrames settings for lighter footprint and easier snapping.
- Custom boss frames now read CrutchAlerts boss-phase thresholds, include a settings toggle, and ship localized strings for supported languages.

### Changes

- Combat action bar overhaul: hotbar category validation, pooled cooldown widgets, and smarter throttling to keep cooldown displays in sync.
- Group resource bars now reformat their layout and spacing based on LibGroupBroadcast data so raid and small-group frames stay aligned with the new integrations.
- Refactored Group Food & Drink Buffs module with localized API usage, unified data helpers, and migrated drink tracking into `LuiData/Effects` for maintenance.
- Integrated LUIE icon/tooltip overrides, slash-command refresh, countdown timer display, and smart anchoring with other LibGroupBroadcast widgets.
- Applied inventory event filters, update throttling, and LuiData version checks to eliminate redundant refreshes and stale-data warnings.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.6...v7.1.0.7](https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.6...v7.1.0.7)

## Version 7.1.0.6

### Fixed

- Fixed LAM 'Reset to Defaults' functionality across all settings panels - frame positions, dropdown selections, and panel unlock states now properly reset to their default values.
- Fixed 19 dropdown default values that were incorrectly using numeric indices instead of display strings, affecting player frame layout, bar alignments, raid icons, GCD method, alert filters, icon options, bracket displays, and guild rank options.
- Fixed Combat Text panel unlock checkbox inverting its state when using LAM reset.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.5...v7.1.0.6](https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.5...v7.1.0.6)

## Version 7.1.0.5

### Fixed

- Significant CombatInfo performance optimization: eliminated redundant function calls and addon state checks that were causing frame freezes on high-buff-count scenarios (especially noticeable on Arcanist).

### New

- Integration with LibFoodDrinkBuff: small group unit frames now display food/drink buff status icons and time remaining. Can be turned on and configured in the Unit Frames settings.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/comparev7.1.0.4...v7.1.0.5](https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.4...v7.1.0.5)

## Version 7.1.0.4

### Fixed

- No-healing overlay is now rendered above the shield overlay.
- Shield animations are smooth again. oops.

### New

- Ability timers can now be manually changed in the settings.
- Synergy Panel, viewer for recent seen synergies.
- In-Combat unitframe border, added settings for Group and RaidGroup to have a red(by default) border around frames when in combat.

### Miscellaneous

- Moved code around in the CombatInfo module. *Shouldn't break anything.
- Added two ZOS Method overwrites to bypass a *Private* function error when using custom icons; the error propagated when dragging a ability in the skills menu.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.3...v7.1.0.4](https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.3...v7.1.0.4)

## Version 7.1.0.3

### New

- Added small group sort by role, just like raid frames.

### Changes

- LibGroupBroadcast integrations, ULT icons, potion icon, dps, hps are only visible in small group frames for now, raid frames will need ui rework to fit everything in. Resource bars should be placed below the raid frame in a small gap if that setting is enabled.
- Migrated font system to use ZOS's native ZO_CreateFontString function.
- Implemented migration system with SV flags to automatically convert legacy font style values (runs once per module).

### Miscellaneous

- Cleaned up obsolete font style string constants from localization files.
- Consolidated settings menu font style dropdowns to use shared arrays for consistency.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.2...v7.1.0.3](https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.2...v7.1.0.3)

## Version 7.1.0.2

### New

- Integration with LibGroupResources, LibGroupCombatStats, LibGroupPotionCooldowns. Tweaks will be made, need people to test and let me know.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/comparev7.1.0.1...v7.1.0.2](https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.1...v7.1.0.2)

## Version 7.1.0.1

### Fixed

- Unitframes should now show visuals correctly; somehow in testing I didn't catch a 0-index issue, sorry all. Let me know in the ESOUI comments/Github if any issues remain.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/comparev7.1.0.0...v7.1.0.1](https://github.com/DakJaniels/LuiExtended/compare/v7.1.0.0...v7.1.0.1)

## Version 7.1.0.0

### New

- Implemented ZOS-style coordinator architecture for Unit Attribute Visualizers.
- Added support for 16:10 displays and Steam Deck.

### Changes

- Completely refactored UnitFrames module for improved code quality and maintainability.
- Enhanced no-healing indicator with distinctive diagonal stripe pattern for better visibility.
- Reduced power shield update animation duration from 250ms to 100ms for more responsive feedback.
- Improved attribute visualizer module architecture with proper event handling and unit-tag filtering.
- Updated aspect ratio detection and scaling for unit frames.

### Miscellaneous

- Significant code cleanup and elimination of duplication throughout the codebase.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/v7.0.1.0...v7.1.0.0](https://github.com/DakJaniels/LuiExtended/compare/v7.0.1.0...v7.1.0.0)

## Version 7.0.1.0

### New

- Added option to use @account names instead of character names in teammate death notifications (Combat Text → Group Member Death → Use Account Names).
- Added transparency control for Info Panel (Info Panel → Info Panel Transparency, %).

### Changes

- Refactored font system to use 'LUIE Default Font' instead of 'Univers 67' across all modules for better consistency.
- Added initial console support and improved settings compatibility.
- Various settings improvements and optimizations.

### Removed

- Group Buffs functionality. Users should now use the dedicated 'Group Buff Panels addon by code65536' instead.

### Miscellaneous

- Updated terms and license information.
- I'm sure I missed a note on some other things that changed. View the full change log on Git.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/v7.0.0.2...v7.0.1.0](https://github.com/DakJaniels/LuiExtended/compare/v7.0.0.2...v7.0.1.0)

## Version 7.0.0.2

### Fixed

- Attempt fix for gamepadui when using the /leave command, it now shows a dialog to confirm.
- Added Grave Lords Sacrifice timer.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/v7.0.0.1...v7.0.0.2](https://github.com/DakJaniels/LuiExtended/compare/v7.0.0.1...v7.0.0.2)

## Version 7.0.0.1

### Fixed

- error fix for group buffs

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/v7.0.0.0...v7.0.0.1](https://github.com/DakJaniels/LuiExtended/compare/v7.0.0.0...v7.0.0.1)

## Version 7.0.0.0

### Fixed

- Grim Focus and Bound Armorments count now go to the new 10/8 respectively.
- Fix trailing dash persisting after countdown timer expires in AbilityAlerts.

### New

- Group buff tracking, found in the SpellcastBuff module, this is in beta and can be turned off.
- Added right click support for buffs/debuffs so you can easily add/remove them to the prominent buff/debuff and group buff trackers. work in progress.

- I'm sure I missed a note on some other things that changed. View the full change log on Git.
Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.6.1...v7.0.0.0](https://github.com/DakJaniels/LuiExtended/compare/6.9.6.1...v7.0.0.0)

## Version 6.9.6.1

### Fixed

- Fix for error in gamepad skills menu.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.6.0...6.9.6.1](https://github.com/DakJaniels/LuiExtended/compare/6.9.6.0...6.9.6.1)

## Version 6.9.6.0

### New Features

- Unit Frames now display group election information, including current voting status. (Because who doesn’t want more democracy in their UI?)
- Added a setting for custom frames to quickly hide dead enemy or neutral NPCs. This shouldn't be hiding dead players, let me know if it does. (If it does, oops,guess you’re a ghost now.)

### Fixed

- Addressed an issue where target frames could display duplicate icons. (Note: This fix is still under evaluation and may not fully resolve the issue. So, you know, don’t @ me if it’s still broken.)
- Fixed an issue where the chat announcement system could display incorrect information about restricted communication permissions. (Because misinformation is so last patch.)

### Improvements

- Enhanced logic for more accurate identification of Destruction Staff spell icons. (Now with 20% more accuracy, probably.)

### Miscellaneous

- Started refactoring the codebase to improve readability and maintainability. Started with the Unit Frames module. Report any issues/errors to me in the comments or on Github. (If you find a bug, congratulations, you’re part of QA now.)

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.5.4...6.9.6.0](https://github.com/DakJaniels/LuiExtended/compare/6.9.5.4...6.9.6.0)

## Version 6.9.5.4

### Fixed

- More tweaks. We *should* be back into a stable state. As always, let me know in the comments if you have any issues.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.5.3...6.9.5.4](https://github.com/DakJaniels/LuiExtended/compare/6.9.5.3...6.9.5.4)

## Version 6.9.5.3

### Fixed

- Some timer fixes. More tweaks will be needed. Feedback needed! Leave a comment, or start a discusson on git [GitHub Discussions](https://github.com/DakJaniels/LuiExtended/discussions)
- Resolve error with powershield.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.5.1...6.9.5.3](https://github.com/DakJaniels/LuiExtended/compare/6.9.5.1...6.9.5.3)

## Version 6.9.5.1

### Fixed

- Some timer fixes. Feedback needed! Leave a comment, or start a discusson on git [GitHub Discussions](https://github.com/DakJaniels/LuiExtended/discussions)

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.5...6.9.5.1](https://github.com/DakJaniels/LuiExtended/compare/6.9.5...6.9.5.1)

## Version 6.9.5

### New-ish

- Re-Enabled using the games api, if you have a conflict, turn off LUIE's backbar and label timer. * Work in progress, feedback welcome, git or comments.

### Bug Fixes

- Resolved an issue with Off-Balance tracking in the Prominent Debuff container.
- Fixed missing icon chat message when purchasing items from vendors.
- Added an option to hide the bracing buff (block) on the player. This setting can be found in Buffs & Debuffs -> Long & Short-Term Effect Options -> Short-Term Effect Filters -> Show Block - Player. Default is "ON".

### Miscellaneous

- Performance optimizations.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.4...6.9.5](https://github.com/DakJaniels/LuiExtended/compare/6.9.4...6.9.5)

## Version 6.9.4

### Revert

- Removed timer code. To many issues with other action bar addons enabled.
Yes that means timers for sorc pets dont show again.

### Bug Fixes

- Chat announcement fixes. Looking at you guards... if you know you know.
- Combat Text resources now warn again if you are low.

### Miscellaneous

- Some other things, it's been a long weekend.

### Notes

- As a reminder, the combat text module can be intensive with the amount of animations that go on.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.3...6.9.4](https://github.com/DakJaniels/LuiExtended/compare/6.9.3...6.9.4)

## Version 6.9.3

### General

- More action bar tweaks.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.2...6.9.3](https://github.com/DakJaniels/LuiExtended/compare/6.9.3...6.9.4)

## Version 6.9.2

### General

- hotfix for ability icons being weird with fancyactionbar+. sorry all.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.1...6.9.2](https://github.com/DakJaniels/LuiExtended/compare/6.9.1...6.9.2)

## Version 6.9.1

### General

- hotfix for unit-frame layout. sorry all.
- removed a debug print.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.9.0...6.9.1](https://github.com/DakJaniels/LuiExtended/compare/6.9.0...6.9.1)

## Version 6.9.0

### General

- Bug fixes and stability improvements.
- Performance optimizations for texture handling.
- Major code refactoring and organization improvements.
- Localized many global calls in LuiData for better performance.
- Our backbar is now hidden if ActionDurationReminder, FancyActionBar, or FancyActionBar\43 is detected. Why have more than one bar?

### Features

- Added support for rounded textures on unitframes. This would be the `Tube` and `Steel` textures in the texture list.
- New tracking system for abilities without existing data.
- Added conditional checks for displaying the last item count.
- Tweaked the fade animation for buff/debuff icons to fade out smoother.

### Improvements

- Refactored CombatInfo.lua with new helper functions for code clarity.
- Improved ability ID handling and UI element visibility.
- Added SetHighDrawPriority, GetCorrectedAbilityId, and UpdateStackText functions.
- Implemented changes suggested in issue #328.
- Updated anchor logic and annotations.
- Gamepad UI experience improvements.

### Bug Fixes

- Fixed ultimate event handling.
- Added nil checks to prevent errors.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.9...6.9.0](https://github.com/DakJaniels/LuiExtended/compare/6.8.9...6.9.0)

## Version 6.8.9

### General

- Re-encoded custom icons, reducing memory footprint by 22.5 MB, as a result `shadercache.cooked` might need to be deleted for the game to regenerate the texture paths.
- Bug fixes and stability improvements. Please report any errors in the comments.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.8.2...6.8.9](https://github.com/DakJaniels/LuiExtended/compare/6.8.8.2...6.8.9)

## Version 6.8.8.2

### General

- Another fix for errors in UnitFrames.lua. Please report any errors in the comments.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.8.1...6.8.8.2](https://github.com/DakJaniels/LuiExtended/compare/6.8.8.1...6.8.8.2)

## Version 6.8.8.1

### General

- Fix for errors in UnitFrames.lua. Thank you @Anthonysc for testing
- There is a new toggle in the unitframes module to format names with the eso target markers.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.8...6.8.8.1](https://github.com/DakJaniels/LuiExtended/compare/6.8.8...6.8.8.1)

## Version 6.8.8

### General

- Due to frequency of updates, I have disabled showing the changelog when there is a version increase.
If you still would like to see a popup there is a setting under Miscellaneous Settings to enable that.
- Added some timer data for Arcanist.
- Fixed an error if LibChatMessasge's history feature was enabled.
- Fixed timestamps to properly disable if "Allow Addons to Modify LUIE Messages" was toggled in the settings.
- Updated tooltip for Gallop to show as 15%. Custom Tooltips need to be enabled to see this...
- Updated stealth tooltip text for update 101045. Custom Tooltips need to be enabled to see this...
- Misc small changes.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.7.2...6.8.8](https://github.com/DakJaniels/LuiExtended/compare/6.8.7.2...6.8.8)

## Version 6.8.7.2

### General

- Fixed frame snapping calculations for edge cases
- Optimized grid snapping performance
- Adjusted UI elements for better visual alignment

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.7.1...6.8.7.2](https://github.com/DakJaniels/LuiExtended/compare/6.8.7.1...6.8.7.2)

## Version 6.8.7.1

### General

- Minor bug fix, default frames we not snapping. They are now.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.7...6.8.7.1](https://github.com/DakJaniels/LuiExtended/compare/6.8.7...6.8.7.1)

## Version 6.8.7

### General

- Added a new grid snapping system. Currently only for default game frames, custom unit frames, and the buffs & debuffs module.
- Code cleanup and optimizations.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.6...6.8.7](https://github.com/DakJaniels/LuiExtended/compare/6.8.6...6.8.7)

## Version 6.8.6

### General

- Added chat announcements for Grimoires and Scripts, off by Default. Can be toggled on under the Miscellaneous Announcements section of the Chat Announce settings menu.
- Added a new font. Montserrat.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.5...6.8.6](https://github.com/DakJaniels/LuiExtended/compare/6.8.5...6.8.6)

## Version 6.8.5

### General

- Added chat announcements for Golden Pursuits and Weekly Endeavors, off by Default. Thanks cyberox.
- More illegal string formatting fixes.

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.4...6.8.5](https://github.com/DakJaniels/LuiExtended/compare/6.8.4...6.8.5)

## Version 6.8.4

### General

- Blood Craze id update so it will now be tracked on the actionbar. Thanks @ExVault.
- Fix for chat alerts. If you know, you know...
- Code cleanup and improvements

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.3...6.8.4](https://github.com/DakJaniels/LuiExtended/compare/6.8.3...6.8.4)

## Version 6.8.2, 6.8.3

### General

- LuiData tweaks
- Font fixes
- Code cleanup and improvements

Full Changelog: [https://github.com/DakJaniels/LuiExtended/compare/6.8.2...6.8.3](https://github.com/DakJaniels/LuiExtended/compare/6.8.2...6.8.3)

- LUIE's data has been moved into the LuiData library, this is included with LuiExtended.
- Added more bar textures to use on our custom frames.
- Improved font registration for our custom fonts.
- Using cached strings for the combat text module. This should improve performance.
- Code cleanup and improvements.
- Changelog in progress...
- Fix for operator + is not supported for number + nil error in chat announcements.
- Added UI mover for Interact Text (affects default 'E' keybind position).
- Fixed active guard ability toggle icon not displaying.
- Fixed chat announcements for crafting items and materials to properly display all entries.
- Fix for some unitframe errors.
- Fix for missing buffs in Cyrodiil.
- Added Fatecarver Immune message to the Combat Text ignore list. No more spam from that now.
- Restructured the data folders code.
- And many more small tweak. There shouldn't be any errors but as always let me know in the comments.
- Updated to API version 101044
- Fixed bug with the ESO Plus Member icon always being visible on the long buff display.
- Hopefully fixed the illegal string format call...
- Added new companions so you can keybind them now.
- Oakensoul menu setting added to Buffs & Debuffs Module -> Display Options. Reload required.
- Added preliminary support for OakenSoul, still needs some tweaks.
- Fixed invite bug. Hopefully.
- Added missing assistants for keybinds.
- Added Warden AOE pre-Charm AoE to AoE alerts.
- Update for Gold Road.
- Updated fonts to .slug format for Update 41 API changes.
- Fixed an issue where the Player to Player interaction menu could throw UI errors.
- Fixed issues with Negate tracking in the Crowd Control Tracker (thanks to ACastanza).
- Fixed issues with CC Tracker occasionally throwing errors with snares & roots.
- Fixed an issue where the Combat Text settings reset with this update. This was due to an issue where the specific Saved Variables for Combat Text were accidentally renamed. Your old settings will be restored as long as you haven't manually cleared your saved variables since the update. The renamed variables will also be cleaned up and removed so as not to inflate the size of your LUIE Saved Variables file.

---

## Version 6.6.8

### [General]

- Added the ArchivoNarrow font as a selectable option.
- Added the ability to move the Endless Archive progress tracker (when you Unlock Default UI Elements).
- Updated tooltips for several effects for Cryodiil Siege weapons that were out of date.
- Fixed an error that could occur with currency announcements when purchasing items on the Crown Store.
- Added an option to show an item loss message when you fillet a fish (manually).
- Updated the context messages for filleting fish at the provisioning station to "You fillet..."
- KNOWN ISSUE: When filleting a certain amount of fish (seems to be under ~50) the messages for filleting at the crafting station won't display the proper amount of fish used. You can read more details about this on the pinned post in the LUIE comments on ESOUI.
- Crowd Control Tracker will now no longer show a CC warning for the cosmetic stun effects when entering various portals in Endless Archive (Thanks ACastanza for finding all these abilityIds).
- Floating Markers now use a different more detailed texture.
- Fixed an issue where the Floating Marker was removed when changing zones.
- Fixed an issue where the font selection for default Unit Frames (with the extender option enabled) wasn't working correctly.
- Fixed an issue where Chat Announcements for fencing items were displaying incorrectly.
- Updated the hooks for Campaign Bonuses in Cryodiil - fixes a default UI issue with the display of the Emperorship Alliance Bonus passive.
- Reimplemented custom tooltips for Buffs & Debuffs. This now has a menu option to toggle on/off (disabled by default since custom tooltips require manual update and are not all up to date).
- Updated "Display Announcements" to use a much better setup (and added support for Endless Archive Progression). These are misc announcements that cover a lot of different things. Menu option configurations are updated for Display Announcements.
- Added support for the new "Archival Fortunes" currency earned in Endless Archive.
- Filleting fish at the crafting station now shows context-specific messages as intended.
- Fixed an issue when mailing gold to another player - if you sent over half of the gold in your inventory the chat announcement would display the value of gold remaining in your bag as the sent amount. This is due to an API issue and required a workaround to fix.
- Added a new submenu with an option to display Floating Markers for enemies you are in combat with (thanks to DakJaniels).
- Bar Highlight tracking for Destruction Staff abilities now works properly on the back bar.
- Added a new menu option to track Heavy Attack casts (disabled by default).
- Fixed an issue where AOE Damage tracking on Crowd Control Tracker wasn't working.
- Added an option to change the Clock Formatting (similar to chat timestamp formatting you can customize how the clock displays). Default settings match the current behavior of the Info Panel clock.
- Added effects to the Unit Frames when a unit becomes Invulnerable (boss invulnerability phases, etc...).
- Fixed an issue where having unanchored buff frames could throw UI errors under certain conditions.
- Added error prevention for item chat messages throwing a UI error under certain conditions.
- Updated Bar Highlight & Buff Tracking for these abilities and their morphs: Trap Beast (Fighters Guild), Scorch (Warden), Grim Focus (Nightblade), Bound Armaments (Sorcerer), Blood Frenzy (Vampire).
- Abilities that "echo" now display a stack counter (for Bar Highlight & Buff Tracking) to serve as a counter - so far this includes Scorch & Haunting Curse.
- Added options for row stacking for the Player/Target Buff & Debuff frames when the option to anchor the frames to the Custom Unit Frames is DISABLED. You can customize how wide the containers are and the direction the rows stack (up or down).
- Fixed an issue where the Collectible messages/announcements could throw UI errors.
- Fixed an issue where the Ultimate Label would not correctly update if Bar Highlight tracking was disabled.
- You can now display the back bar without Bar Highlight tracking enabled if you just want to add the back bar to see it.
- Flame Lash (Dragonknight) ability icon on the ability bar now glows when Power Lash is available (targeting an enemy that is rooted or Off-Balance).
- Unit Frames now display the "Trauma" effect (healing absorption) - this has a customizable color and will display on all bars. You can also display the value on the bars but this must be configured in the settings menu (the dropdowns for the format now include options for adding the Trauma value).
- Fixed an issue where the colors for Chat Announcement messages were not showing properly.
- Fixed issues causing UI errors with Gamepad Mode Skills Window.
- Tons of code optimization and cleanup thanks to DakJaniels.
- Crystallized Shield & its morphs are now correctly tracked on Combat Info - Bar Highlight and Buffs & Debuffs (Note: the stack count only displays for the player as the ability doesn't return any information to the API about the stack count).
- Fixed issues caused by LUIE with "Dolgubon's Lazy Writ Crafter." The auto-abandon quest option in Writ Crafter now works properly and Quest Center Screen Announcements will now follow the "Hide Writ Quest Announcements" setting in Writ Crafter.
- Added a toggleable option to hide the display of loot when the addon "Loot Log" is active.
- Fixed an issue where Collectible Chat Announcements weren't displaying correctly.
- Added the option to track Immobilize & Snare effects to the Crowd Control Tracker (thanks to ACastanza). These options are disabled by default. Immobilization tracking requires the base game menu setting under Combat for Active Combat Tips to be enabled. Immobilization effects will display as snares if the setting for Immobilized Warnings is disabled.
- Fixed an issue where the cast bar for Recall would be interrupted when teleporting to a Wayshrine in a different zone."
- Fixed Bar Highlight tracking for some abilities.
- Fixed Proc Sounds not working (Note: Grim Focus is going to require some work due to the changes to the ability).
- Added the option to play Tales of Tribute with a group member to the Right Click Menu for Group Frames.
- Re-enabled ability timers again (thanks to DakJaniels)
- Added New AOEs to AOE Tracker Dataset & fixed certain effects showing up in CC tracker (thanks Anthonysc)
- Fixed Exhausting Fatecarver not extending the castbar
- Fixed Cast Bar for Fatecarver and Remedy Cascade
- Added /changerole command
- Added Arcanists Fatecarver and Remedy Cascade skills to Cast Bar
- Stop Cast Bar when you get interrupted
- Fixed keybindings for Armory and Deconstruction
- Added Pyroclast & Hoarfrost
- Fixed Aderene
- Fixed lua error with mementos
- Added Armory, Fence & Deconstruction to CollectibleTables to hopefully fix a bug with Giladil
- Added Zuqoth Armory Assistant
- Reworked Slash Handling: Will disable armory, companion, merchant or banker if you do not have any of them unlocked. If you buy one of them you need to /reloadui for LUI to update
- Fixed Role colors in Battlegrounds
- Added Sharp & Azandar Keybindings
- Removed the Keybindings for individual Banker and Merchants (You have to select your prefered Banker and Merchant now in LUIE Settings -> SlashCommands -> General)
- Rewrote Collectible handling to make adding new banker, merchants & companions easier in the future
- Added Aderene
- Fixed Colors in Battlegrounds (thanks to Anthonysc)
- Added Necrom companions (thanks to GwynneBleidd)
- Added 3 x 4 Raid layout
- Made shield bar height also work in overlay mode
- Added Charm CC support (thanks to Anthonysc)
- Fixed Arcanist class colors (thanks Anthonysc)
- Removed buff & debuff overrides as they were causing too many troubles
- Changed shield bar overlay to be smaller
- Removed 24 player group support
- Added option to sort group by role
- Added Arcanist class color (thanks Anthonysc)
- Fixed an issue where the option to invite a player to a game of Tales of Tribute was missing from the Player interaction wheel.
- German localization updated.
- Re-enabled GCD Tracker and Potion Timer and updated them to support High Isle.
- Fixed small issue with Potion Timer colors.
- Fixed Ultimate display.
- German localization updated thanks to the efforts of saenic!
- Added French localization thanks to the efforts of Zhull-GH!
- Implemented the features of Nagolite's "Updated Assistants for Lui Extended" patch, see more details below in the Slash Commands section.
- Made a few minor changes to tooltips and icons.
- GCD Tracker: Disabled this feature due to API changes made in High Isle breaking it.
- Potion Timer: Disabled this feature due to API changes made in High Isle breaking it.
- Updated Slash Commands & keybindings with support for Crow Assistants, Factotum Assistants, Ghrasharog, and Giladil the Ragpicker. Thanks to Nagolite for implementing these features!
- Updated Slash Commands & keybindings with support for Ember and Isobel, the new companions.
- Various quality improvements and fixes made to Slash Command & keybinding functionality for summoning assistants & companions thanks to the efforts of Nagolite.
- Fixed an issue where the icon for the ground tracker buff for Nova and its morphs was missing.
- Fixed an issue where no ground tracker buff was displaying for Cleansing Ritual and its morphs.
- Rune Focus and its morphs now show a buff when you are standing in the healing circle.
- Vampire Stages now show as long term buffs.
- Fixed various ability tooltips to account for changes made in the last couple updates.
- Alerts for collectible usage will now also display when you summon/dismiss a companion.
- You can now specify '/home inside' or '/home outside' when warping to your primary home.
- The '/home' slash command now has an option to toggle whether to default to warping inside or outside your primary home.
- Added a '/companion' slash command to summon a companion and menu option to determine the default companion to summon. You can also specify the companion to summon with '/companion mirri' or '/companion bastian' or by using the '/mirri' or '/bastian' command.
- Added keybinding options to summon either companion.
- Added a Unit Frame for tracking your active companion (enabled by default). This frame takes the previous default position of the Pet Unit Frames. The Pet Unit Frames position will be reset to default when loading the addon and save any changes you make after.
- Updated support for the "Dead" label to display on frames. Now companions, pets, bosses, and your target will show as "Dead" instead of at 0 Health.
- The Target Unit Frame now displays an indicator when a player is being resurrected or reviving (to match the behavior of Group Unit Frames), this also works for the Companion Unit Frame.
- Fixed an issue where the '/outfit' command was not working properly due to an API change I missed.
- Fixed an issue where a UI error would occur when mousing over a Companion with the "Target - Use Reaction Color" option enabled in Unit Frames settings.
- Added the option to change the Reaction Color for Companions in the Custom Unit Frame Color Options menu.
- Duration & Stack Tracking for Bar Highlight is currently disabled. Something that changed in the API broke this and I haven't been able to figure out what caused it yet despite rooting around for an exceptionally long time. I may have to rewrite this component in the future. I'd suggest using Action Duration Reminder in the meantime.
- The Gamepad Skills Window & Gamepad Skills Advisor now properly show custom passive icons added by LUIE.
- The Gamepad Active Effects Window now properly hides buffs & debuffs filtered out by LUIE.
- Updated the tooltips for Alliance War Tortes / Scrolls to clarify they increase both "Alliance Rank and Alliance War Skill Line progression."
- Updated the backdrop & tooltip for Cyrodiil Food/Drink buffs since the quality was upgraded from White to Blue.
- Added Icons & Cast Bar support for various item/collectible fragment combination/use.
- Added Icons & Cast Bar support for many Collectibles that were missing it.
- Added Icons & Cast Bar support for the Aetherial Well furnishing item.
- Updated icons and tooltips for the Champion System update.
- Improved icons for several item sets.
- Removed the custom icns used for Major/Minor Aegis, Courage, Slayer, and Toughness since ZOS has implemented new icons.
- The Active Effects Window will now display more detailed information about the type of Buff/Debuff to match the behavior of mousing over LUIE buffs (I.E. shows whether the effect is unbreakable, a ground effect, an AOE Tracker, etc).
- Fixed some missing ACTION_RESULT's for the debug logging option to stop it from throwing errors.
- The toggle option to show Set Internal Cooldowns now has support for the Sentry set and has been moved into the Short-Term effects filters.
- Added an option to toggle the display of Ability Internal Cooldowns (for Champion Abilities - Expert Evasion & Slippery)
- Removed some name override data for Weapon Glyphs (the abilities are just called Crusher/Hardening/Weakening/Weapon Damage) instead of "X Enchantment." This makes the only change from the default UI renaming "Berserker" from the Glyph of Weapon Damage to "Weapon Damage."
- Updated light/medium/heavy attacks for unarmed/weapons/Volendrung/Werewolf to match the current and updated syntax ZOS implemented ex. "Light Attack (Two Handed)."
- The Internal Cooldown for Werewolf & Vampire Player Bites now show as Long-Term effects.
- Experience: Updated and restored the announcements for Champion Points being earned.
- Experience: Cleaned up and normalized messages related to Respec Notifications.
- Currency: Fixed an issue where currency postage values weren't always correct when sending mail.
- Loot: Fixed an issue where Chat Announcements for learning recipes would display the total item count for that recipe if there were other copies of the recipe in your inventory.
- Loot: Fixed some collectibles not showing a collectible link when purchasing them from the event vendor.
- Collectible: Collectible Messages now have the option to display both Category & Subcategory.
- Group: When forming a group and inviting a player to the group, the inviter will now see a "You have formed a group" message followed by a message indicating the invited player has joined.
- Group: When you kick the last player in a group instead of seeing a "You have been removed from the group" message, it will now be indicated that you have disbanded the group.
- Cast Bar: Added a blacklist option for the Cast Bar.
- Crowd Control Tracker: "Hiding Spot" is now localized and hidden so non-EN clients should not have a stun effect pop up for this.
- Potion Timer: Now shows Days/Hours/Minutes format for longer duration CD's such as Research Scrolls & Mementos.
- Added the '/setprimaryhome' command to set the primary home.
- Added the '/eye' command and keybind to use the Antiquarian's Eye.
- Collectible usage keybinds and slash commands will now return an error when trying to use a Merchant/Banker/Fence in a player home.
- Collectible usage keybinds and slash commands will now display the collectible name that can't be used when an error occurs.
- Fixed an issue where the error alert (if enabled) for collectible usage failure when the collectible was not unlocked was missing the name of the collectible.
- The Experience Bar will now show the proper color/icon for the Champion Point being earned.
- Removed a setting that toggled whether to show the max Champion Points the player/target had earned vs the amount allocated. The API no longer provides information about how many points have been allocated for targets.
- Fixed an issue where the button to whitelist Assistant names for the Pet Frames was adding "Tythis" instead of "Tythis Andromo."
- Added options to Buffs & Debuffs, Combat Info - Ability Alerts, Combat Info - Crowd Control Tracker, and Combat Text to use default icons for crowd control effects. This is a WIP for some of the modules as certain things require manual table data to work correctly. I will be aiming to at least add full support for player abilities.
- Reset the default color options for Buffs & Debuffs, Combat Info - Ability Alerts (Crowd Control Colors), and Combat Info - Crowd Control Tracker. This change will apply once when loading the addon and save any changes you make after.
- Components that have a blacklist/whitelist function now all have buttons with confirmation prompts to clear the entire list.
- Updated the keybindings for summoning Merchant/Banker/Fence to display a message in chat always. Previously this used the setting under Chat Announcements for collectible use messages.
- Consolidated several submenus in Buffs & Debuffs.
- You can now change the container alignment of Long Term Effects & Prominent Buffs/Debuffs without reloading the UI.
- Prominent Buffs will no longer show clipping bars/labels when set to display with the horizontal method.
- Added an option to hide the display of Short-term effects on the Player/Target in addition to Long-term effects.
- Added a new "Priority Buffs & Debuffs" whitelist. These buffs & debuffs will show up with a different color.
- Added a new menu to customize buff/debuff colors, and the option to toggle coloring debuffs by CC type (Very heavy WIP since it requires manual table data).
- Fixed an issue where there was no buff icon for Argonian and Khajiit Summon Shade and its morphs.
- Updated mouseover tooltips for buffs/debuffs to reflect if they are a ground buff/debuff, or a tracker effect for an AOE cast by the player.
- Added the CC Immunity buff to Target Dummies that were missing it.
- Implemented a safeguard that should prevent a UI error from occuring when refining a large amount of crafting materials.
- Ability Alerts - Added an option for mitigation alerts to color the incoming ability name by its CC type. Adjusted a few menu options for syntax to accommodate for this change.
- Bar Highlight - Fixed an issue where Crystallized Shield and its morphs would throw a UI error when taking damage with this component enabled.
- Bar Highlight - Fixed an issue where the bar highlight for Argonian and Khajiit Summon Shade and its morphs didn't function properly.
- Bar Highlight - Subterranean Assault now shows a 6 second timer when cast to track the full duration of its effect.
- Crowd Control Tracker - Added new color options for Knockback & Pull/Levitate effects.
- Crowd Control Tracker - Fixed an issue where unbreakable buffs would turn from the Unbreakable Color to default CC color when the break free animation played.
- Reset the default bleed damage color to red. This change will apply once when loading the addon and save any changes you make after.
- Optimized and reorganized the filtering code, now prominent effects will always show even when long or short-term effects are hidden.
- "Fake" buffs such as Sneak, Disguised, and Mounted can now be displayed as prominent.
- Updated the tooltips for Major/Minor Endurance, Fortitude, and Intellect to reflect their new % values.
- Updated the tooltip for Battle Spirit to reflect the changes made in the Flames of Ambition update.
- Added icons & tooltips for the new Status Effects for Physical, Bleed, and Magic Damage.
- Sneak now has a dynamic tooltip that displays the movement speed reduction and stamina cost.
- Merged the "Long-Term Effects Filters" submenu options into the "Long-Term Effects" submenu options.
- Added an option to disable the display of Short-Term Effects.
- Added an option to toggle detailed information on/off for active Non-Combat Pet buff (on by default to match previous behavior).
- Non-Combat Pet and Assistant buffs no longer display inside houses since you can't have active collectibles of this type inside a house.
- Fixed an issue where the Target Iron Atronach, Trial was displaying duplicate buffs.
- Updated tracking for Off Balance Immunity. Now you can set this as a Prominent Buff to track the effect on the player or a Prominent Debuff to track the effect on targets.
- Fixed an issue where adding/removing a buff/debuff from Prominent Effects or from the Blacklist would reset the buff container anchoring.
- Combat Text automatically hid some resource regeneration/drain effects that could be slightly spammy (Bull Netch for example). This is no longer the case and instead buttons have been added to the blacklist menu for class abilities that are spammy. By default the stamina drain from sneak is added to this blacklist.
- Updated the /cake command to use the 2021 Jubilee Cake.
- Updated the /campaign command to work with campaigns added more recently. Thanks to TarodBOFH for discovering this issue.
- Mousing over the XP Bar on the player frame will now show "Max XP" and hide enlightened status details if the player is at max Champion Points (to mimic the behavior of the default XP bar).
- Fixed an issue where Combat Text was throwing UI errors for Bleed abilities. I missed that a DAMAGE_TYPE_BLEED was added with this patch as a new damage type for bleeds.
- Fixed an issue where the Global Cooldown Tracking component of Combat Info was throwing UI errors.
- Fixed various errors related to API changes from this update.
- Attempted to fix an issue where the Combat Info Bar Highlight component threw errors when Shimmering Shield was hit on a Warden.
- Removed a hooked function for Guild Heraldry updates that had been reported to cause errors.
- Removed some unused icons and updated tooltips for most new Champion Point abilities.
- A more detailed Change Log may be released in the future. This was a quick update for Flames of Ambition.
- Due to API changes with Major/Minor effects the Bar Highlight component of Combat Info may have some issues tracking Major/Minor debuffs applied onto a target. In some cases they won't start tracking until you mouse off and back on to the target. This is due to some issues with the API that I hope are addressed in the future (although it may not technically qualify as a bug).
- Updated icons & tooltips for the new sets and Alliance War skill line consumables introduced in this update.
- You can now independently control the alignment and sorting direction of each buff or debuff container. The new settings mirror the previous default settings, you may need to readjust some of these settings if you had modified them before.
- You can now independently control the Horizontal/Vertical orientation of the Long Term Buffs, Prominent Buffs, and Prominent Debuffs container. The new settings mirror the previous default settings, you may need to readjust some of these settings if you had modified them before.
- Added a new Alignment & Sorting Options submenu for the changes above to make changing these settings easier.
- Removed the display of Cyrodiil Home/Enemy/Edge Keep bonus buffs - these took up too much space and the functions used to determine/display them were inefficient.
- The toggle option for Cyrodiil buffs now only applies to Cyrodiil Scroll bonuses. Emperorship Alliance Bonus & Blessing of War will now always display (Note: The toggle setting for Battle Spirit is separate and remains unchanged).
- The options for Consolidating Major/Minor effects has been removed due to API changes to Major/Minor effect handling.
- Custom icons for Major/Minor effects from Potions/Poisons have been removed due to API Changes and the menu option for toggling these icons has been removed (Note: The option to toggle the default icons for Major/Minor Slayer/Aegis remains).
- Removed the "Highlight Secondary Id" option from Bar Highlight settings. This applied to all of about 2 or 3 abilities before (The magicka regen buff for Honor the Dead for example) that now always display when Highlight is enabled.
- Currently no chat announcement/alert will display when another player joins your group. This is due to the API Event for group members joining (EVENT_GROUP_MEMBER_JOINED) not triggering properly when players join. I've reported the issue so hopefully it is addressed by the next major game update.
- Added the option to mount as a passenger to the Player to Player interact wheel. I'm not sure if passenger mounts have been added onto the live server yet.
- Added a cast bar for mounting as a passenger and Crowd Control tracker will now display the stun effect if you get dismounted while riding as a passenger.
- Fixed an issue where the color for the radial border of debuffs was black instead of red due to some testing I was doing and forgot to revert.
- The mounted buff has been updated to specify whether you are mounted or riding as a passenger.
- Updated the Thief Mundus Stone tooltip to reflect the reduced critical chance from the changes made in game update 6.1.6.
- Fixed an issue where a UI error would occur when you hit Champion Level on a character with Alerts for level up enabled. Also fixed this chat announcement & alert to display the champion system icon properly.
- Crystal Fragments will now only play its proc sound when the buff is initially gained and not when it is refreshed. This is due to an issue with its implementation - it can actually proc off of itself when you fire the instant cast frag but the buff is consumed during the GCD as it goes off.
- Additional RU translation completed thanks to FAR747!
- Updated aura tracking and tooltips for all sets and player abilities changed/added in the Stonethorn update.
- Improved the quality and added new icons for sets as well as improved many NPC ability icons.
- Improved the quality of the cast bar icons for mementos & usable items (siege, pardon edicts, etc).
- Added cast bars & icons for several item interactions (creating Psijic Ambrosia Recipe, Aetheric Cipher, Alliance Standard-Bearer's License, etc).
- Fixed an issue where some ability names in tooltips weren't punctuated properly due to the base UI string SI_UNIT_NAME being changed.
- Updated the Werewolf Timer buff. It's no longer possible to determine the duration of werewolf form due to the variance in Werewolf power drain based off passives and proximity to other Werewolves - but the bar will update based on the % power value when it is set to display as a prominent buff.
- Added an aura that displays in combat when wearing Snow Treaders (only for self due to API limitations).
- Updated the tooltips for Mundus Stone buffs to have consistent syntax with other buffs.
- Updated the tooltips for Daedric Titan abilities to show the correct snare speed reduction %.
- Hid the dummy "Death Achieve Check" buff that would sometimes display on players in Veteran dungeons.
- The debug function to display combat and buff events in chat now prints out to chat normally (so pChat and other chat addons can save the messages).
- Transmutation Geodes are now added to the blacklist for Group Member Loot.
- Removed the Mercenary Motifs from the blacklist for Group Member Loot since they are no longer anywhere near as common.
- Fixed several issues with quest item added/removed messages, including fixing the messages for combining quest items to work properly.
- Combat Alerts: Combat alerts for nearby enemy attacks will now hide when the player is in a duel.
- Combat Alerts: Fixed an issue where the sound toggle setting for Single Target CC Abilities wasn't updating properly due to a typo in the variable name.
- Bar Highlight: Ground Mine abilities will now display a stack count.
- Bar Highlight: Added tracking support for Arena Weapon Sets where it was fitting.
- Bar Highlight: Fixed an issue where some abilities that tracked multiple effect ids weren't displaying properly.
- Bar Highlight: Fixed an error that could occasionally occur when a ground mine effect expired.
- Fixed an error that could occasionally occur when a player changed their title.
- Fixed an issue where sometimes the anchored player buffs frame would clip into the extra bar (horse stamina/werewolf/siege).
- The extra bar for Werewolf will no longer show a duration remaining on the mouseover tooltip due to changes made to the skill line, and will now refer to werewolf power as "Rage."
- Thanks to FAR747 for doing additional translation for the RU localization!
- Updated a few icons, including a new appropriately explosive looking icon for Vicious Death.
- Updated the tooltips for Battle Spirit, the LFG Buff, and Thrassian Stranglers to use more consistent syntax.
- The under level 50 player Looking For Group health & power buff is now named "Looking for Group" instead of "Looking For Group" (en localization only). I have the power to fix improper title capitalization and I will use it.
- Note: I made a discovery recently that when the pChat addon is enabled a lot of the loot chat messages that print multiple items out will get cut very short. This has something to do with the "Enable Copy" setting in pChat, disable this option in pChat if you want the full messages to show.
- When crafting items, if too many items are sent to the item printer at once (currently 12+), the message will now be replaced with "too many items to display." Otherwise the message wouldn't display at all. This is probably temporary, in the future I'd like to split the items received into multiple lines.
- Chat Printer: Added a check if the Combat Metrics addon Combat Log is enabled in order to not print messages to the CMX window if you have the "Print to Specific Tabs" option enabled.
- Indrik Feathers/Berries purchased from the Event Merchants should now display a proper collectible link in chat.
- Separated the "Mail Notifications" option in Misc Announcements into a separate option for "Send/Receive" and "Errors." Errors are enabled to print to chat by default (this alters the default UI behavior of displaying an alert in the corner of the screen).
- Added a "Stow" context option for Loot Announcements for stowing siege weapons (packing your deployed siege weapons back into your inventory).
- Added an option in Collectibles & Lorebook Announcements (enabled by default) to only display the Center Screen Announcement for books discovered if they are in the Shalidor's Library category (normal non-lore books won't show a CSA).
- Ability Alerts: Updated the sound options for Ability Alerts to use different specific categories to give more control over the sounds played. NOTE: This is a WORK IN PROGRESS, only overland abilities are setup for this. I'm hoping to have dungeon abilities updated for the Stonethorn update.
- Ability Alerts: Added an option to show a modifier on certain messages. Currently this is enabled by default and will add an "ON YOU!" message if something is directly targeting you. There's also a "SPREAD OUT!" modifier that will be added to AOE abilities that require the group to spread out.
- Ability Alerts: Fixed an issue where with the "Show Nearby NPC Events" setting disabled many enemy attacks wouldn't show an alert event if they were directly targeting you.
- Bar Highlight: Fixed an issue where hitting a Warden with Crystallized Shield (and its morphs) would throw a UI error.
- Bar Highlight: Added a customizable threshold for displaying decimal values for Bar Highlight timers (1-30 sec duration).
- Ultimate Percentage: Fixed an issue where sometimes when you resurrected the ultimate percentage label would show at 100% even when set to hide.
- A ton of additional Russian translation has been done by FAR747 including localizing pet names for the buttons in the Pet Unit Frames Options. If you notice any errors with translations, reach out to FAR747 on ESOUI!
- Added Grainy Statusbar textures to the dropdown texture options for Unit Frames (thanks to saenic).
- Updated icons/auras/alerts/etc for Volenfell as well as improved many enemy ability icons.
- The option to unlock default UI elements has been expanded with the ability to move the Alerts Frame, Compass, and Experience Bar.
- Fixed an issue where when moving the Objective Capture Meter frame, the objective fill for the frame wouldn't move with it.
- Added an option to hide ALL alerts (that display by default in the upper right corner of the screen).
- Added a toggle option under Position and Display Options for showing useful raid debuffs applied by other players (enabled by default to mimic the current behavior).
- Added a toggle option under Position and Display Options for showing Major/Minor debuffs applied by other players (enabled by default to mimic the current behavior).
- Added buttons under Buff & Debuff Blacklisting to separately add Major & Minor Buffs/Debuffs to the blacklist and a button to clear all entries in the ability blacklist.
- Added a toggle option under Custom Icon & Normalization Options to use the default icons for Major & Minor Slayer/Aegis/Courage/Toughness instead of the custom LUIE icons..
- Fixed the order in which Antiquity announcements display in chat (after gold/loot but before collectibles/achievements).
- Bar Highlight: Expanded the ability to hide bar label fractions with an option to show fractions when the remaining duration is < 10 seconds and hide them above that duration. Thanks to saenic for implementing this feature!
- Ability Alerts: Fixed an issue where interrupt alerts weren't showing (thanks to Niobiritzu for finding this issue).
- Ability Alerts: Adjusted the alert for Boulder Toss (Ogrim) to have a slight post cast duration so it remains active while the rock hurtles toward your domepiece.
- Ability Alerts: Hid the alert for the Bear Trap dropped by some NPCs since it was pretty much pointless..
- Added a button to clear all entries in the ability blacklist for Combat Text..
- Added a button to add all of your CURRENTLY active pets to the whitelist for pet names. This option is useful if you are using an addon like RuESO that changes the way Pet Unit Names display.
- Added toggle options to hide the Player Health Bar label and entirely hide the Player Health Bar. I don't recommend hiding the bar but you can still do it if you like.
- Expanded the option to unlock default UI elements and move them with more elements (Action Bar, Subtitles, Infamy Meter, etc) as well as improved the unlock functionality.
- Updated icons/auras/tooltips/etc to adjust for changes made to the Vampire & Werewolf skill lines and quests, as well as new sets & mythic items added in Greymoor.
- Updated icons/auras/tooltips/alerts/etc for the abilities used by enemies in the Greymoor tutorial area and enemies and bosses in Crypt of Hearts II.
- Updated and improved some icons for enemy abilities and player sets and improved the icons used by Sorcerer and Werewolf pets.
- Updated some player ability tooltips to account for some of the syntax changes and tooltip improvements made by game updates.
- General: Fixed an potential issue that could occur with the message printer in Chat Announcements if somehow there was a gap in the index of queued messages.
- Loot: Storage Coffer/Chest collectible items that can be purchased from vendors will now display a proper collectible link when the item is purchased.
- Loot: Fixed an issue where the "Bracket Options" setting was not properly applying to items looted by other players.
- Loot: Added an option to use the generic message color for Loot/Currency transactions that are merged (buying/selling an item).
- Loot: Added support to display a message when you list an item for sale on the guild store.
- Loot: When trading/mailing items, separate stacks of the same item are now combined into one chat message. So if you send 6 stacks of 200 weapon power potions to someone you'll now just see one chat message specifying you sent 1200 potions instead of 6 lines of 200.
- Loot: Updated the options for context messages for Potion/Food/Drink if you choose to modify them.
- Loot: Added a context message for excavating items/gold from a dig site.
- Loot: Added options to display Chat Announcements when a Recipe/Motif/Style is learned as well as an option to disable the default alert (upper right corner message) that appears.
- Antiquities: Added a menu for Antiquities, allowing you to customize the display of Chat Announcements/Alerts/Center Screen Announcements when discovering a lead. You can click on the Antiquity links from Chat Announcements to open the Codex entry for them.
- Bar Highlight: Added the option to display the backbar for Bar Highlight Ability Tracking with several customization options.
- Bar Highlight: Added a stack counter to tracked abilities.
- Bar Highlight: Cleaned up the backend for Bar Highlight tracking, and the highlights now sync with the flipcard animations when bar swapping, making everything look a little smoother.
- Bar Highlight: Tracking for Sorcerer - Bound Armaments now just shows the duration of the overall buff instead of the 10 sec stack duration making it easier to follow.
- Bar Highlight: Tracking for Warden - Crystallized Shield (and its morphs) now track stacks.
- Ultimate Tracking: The ultimate tracking percentage label will now cap at 100% value, and both the value and percentage labels and will update when your Vampire Stage changes or when you change your equipped gear (in case you equip/unequip a set that reduces ultimate cost).
- Ultimate Generation: Fixed an issue where the Ultimate Generation texture sometimes wouldn't display when you were generating ultimate.
- Combat Alerts: Added a context message for "Hard CC" for the interrupt notification for abilities that can only be interrupted by hard crowd control effects.
- The option to move default Unit Frames up/down is now independent from the option to set them to display in a pyramid mode and both of these options now update on the fly rather than requiring a /reloadui.
- Added a new menu for Player & Target [*] Bar Fill Direction in Unit Frames allowing you to choose the direction the bars fill from. This allows you to have the bars behave more similarly to the default frames.
- Added an option to the new menu to set the value label for player/target frames to display in the center of the bar instead of having a right and left label.
- Added a slash command and keybinding option to dismiss Sorcerer and Warden pets.
- NOTE: Currently no changes have been made for LUIE Components for the new Vampire Skill Line, Werewolf Skill Line Changes, or any new sets & mythic items added with this update. Buffs & Debuffs will not have custom icons or tooltips, Vampire Abilities won't be correctly labeled for the purpose of hiding them in the menu settings, and Bar Highlight/Cast Bars for new vampire/werewolf abilities are not implemented. Implementing everything listed here will be the priority for the next update.
- Updated tooltips & auras for all item sets & monster helms changed in this update as well as updated custom icons for some sets.
- Added support for new potions/poisons added in Greymoor & fixed an issue where the tick rate was not displaying correctly in the tooltips for damaging potions and poisons.
- Temple Guards in Cyrodiil now show the correct faction specific icon for their Stealth detection ability.
- Added options in the menu to display when items are used/lost for: Potion, Food/Drink, Repair Kits/Siege Repair Kits, Soul Gems, Siege Deployment, misc items such as Keep Recall Stones, and items turned in for quests.
- You no longer need to toggle on "Display Item Loss - Destroyed Items" to show other types of messages related to inventory items being lost/used/etc.
- Fixed a longstanding issue with the "Display Materials Used" crafting loot option. This will now show the correct item when an item is pulled from the inventory instead of the craft bag.
- Messages for crafting materials used will now merge quantities in the case of separate stacks or items being used from multiple bags. For example if you use 30 ingots, 10 from the bank, 10 from inventory, and 10 from the craft bag - they will now just show as using 30x ingot.
- Loot messages displayed for items being crafted/deconstructed will now merge stacks instead of displaying individually. For example if you create 10 Iron Battle Axes, you'll now see "You craft [Iron Battle Axe] x10" instead of 10 individual comma separated items.
- Added support for any addon that uses LibLazyCrafting (Dolgubon's Lazy Writ Creator, etc) for crafting messages. You will now see item messages labeled correctly as crafted/used regardless of what tab of the Crafting interface you are on.
- Updated icons & cast bars for deploying new Siege Weapons.
- The cast bar for deploying siege will now break when you tab in and out of the game or open an ingame window (inventory, character screen, etc).
- The cast bar for stowing siege weapons now breaks if you exit siege mode in the middle of the cast.
- Updated icons/tooltips/alerts/cc tracker/etc for Elsweyr Tutorial, Stros M'Kai and most of Betnikh.
- Fixed an issue with the Loot History window displacing when you unlocked and moved its position.
- Fixed the UI error thrown when trying to reset movable base game UI elements to their default position.
- Fixed an issue where when learning skills with a non-english localization the names would not properly format and show ^f and ^m tags.
- Tweaked a few minor ordering issues with quest update message chat announcements.
- Added some additional conditional messages for quest item acquisition/usage.
- Fixed an issue with the Dampen Magic ability used by some NPC casters throwing alerts every time the shield refreshed (whenever the shield took damage). It will now only display an alert on cast.
- Fixed an issue where the confirmation messages for adding/removing pets to the Whitelist referred to it incorrectly as the "Pet Blacklist."
- Switched Pet Unit Frames to use a whitelist instead of blacklist. You must add pets to the whitelist in order for them to show up. By default no entries are added here.
- Added five buttons to add specific pets to the whitelist - Necromancer, Sorcerer, Warden, and Item Set Pets, as well as Assistants.
- Added a button to clear the entire whitelist.
- Updated the icons for Flying Immunites, Boss Immunites, Major Vulnerability Immunity, Off-Balance Immunity, Minor Toughness, as well as the icons for Major and Minor Aegis, Slayer, and Courage.
- Added an option to the base LuiExtended menu to unlock several default UI elements - Quest Tracker, Battleground Score, Loot History, and Equipment Status.
- Housing Target dummies will now display a "Boss Immunities" buff.
- Added a "Custom Icon & Normalization Options" menu to Buffs & Debuffs. Added 3 individual options in this menu that allow you to toggle the custom icons for potion/poison/status effects that have a major/minor effect with the major/minor effect icon. The option for poisons is enabled by default.
- Added an option to display "Container" loot messages in Chat Announcements when you empty a container item in your inventory and it is removed.
- Fixed some minor timing issues with the Chat Printer (the chat printer operates on a 50ms throttle to allow any event messages to be properly ordered - some events don't properly line up so they now delay the printer slightly so all queued messages display simultaneously.
- The throttle settings for Tel Var Stones no longer apply to stones when looting them from a chest/container.
- Achievement Tracking Categories are now hardcoded into the menu so I don't have to update the categories with each game update. This will cause these settings to reset for anyone who modified them.
- Added an option to always show the Center Screen Announcement for Achievement Completion even if you have the category filtered out. This is how Achievement Tracking worked before this option was implemented - so it is enabled by default.
- Using the /friend Slash Command now displays a prompt confirming the name entry & allows you to type a note to that person.
- Unit Frame names will no longer abbreviate to "..." when cut off and will now truncate instead. This allows for better use of the frame space.
- Added resurrection monitoring status to Group & Raid Unit Frames - now you will be able to see when a target is being resurrected, has a pending resurrection, or is self-reviving. This label updates dynamically and replaces the "Dead" label when one of these conditions is met.
- Updated the right click handler for custom Group Unit Frames to allow you to request to add the player as a friend.
- Increased the default Raid Frame width by 20 units. This won't modify your current settings.
- Added Unit Frames for pets - with a new color option for the pet bar and the option to color the bar by your Class color.
- Added a name blacklist for the new pet frames. Entering a pet name (not case-sensitive) will hide it from displaying on your UI.
- Updated icons, tooltips, alerts, and cc tracker for several dungeons (EH I & EH II, COA I & COA II, and Tempest Island) as well as a multitude of monster attacks.
- Fixed an issue where the default tooltips for abilities weren't displaying in the Active Effects Window on both the keyboard and gamepad UI.
- Added a workaround for duplicate Quest Accepted messages displayed in chat if enabled when using Dolgubon's Lazy Writ Crafter.
- Updated the /cake command to summon the 2020 anniversary cake and updated the icon. Too little too late at this point.
- Slash Commands are no longer set to nil when disabled in the options menu, this means you will need to reload the UI when disabling slash commands you don't want to use. This is to stop LUIE from removing commands if another addon also adds the same slash command with similar functionality.
- Updated icons, tooltips, alerts, and cc tracker for Crypt of Hearts I.
- Updated and added a good chunk of improved custom icons.
- Fixed an issue where Friend logon/logoff messages would duplicate when using pChat, now my tatsumaki is more powerful.
- Fixed an issue where the Center Screen Announcement for completing a lore collection for a zone that resulted in Mages Guild reputation gain would throw a UI error & fixed an issue where the Chat Announcement for this event had an icon that was colored by the default system text color.
- Fixed an issue where the fallback font variable was misnamed. This could cause the addon to fail to load if for some reason the selected font wasn't found.
- Removed a debug line from Ability Alerts that could display when enemies used abilities.
- Fixed an issue where using the /fence Slash Command or Keybinding would throw an error.
- When summoning a banker, fence, or merchant with the keybinding, your Chat Announcement setting will now determine if a feedback chat message is displayed. Note that using the slash command will still always return feedback into chat.
- Added a keybinding option for "Leave Group."
- Restored the ability to print chat messages to specific chat tabs.
- Removed the "Enable pChat Message Saving" setting and replaced it with an "Allow Addons to Modify LUIE Messages." It has the same functionality but is disabled by default. This setting can always be enabled now instead of toggling off when selecting the option to print to specific chat tabs (it still won't effect messages printed to specific tabs but will handle system messages if you choose to print those in all tabs).
- Fixed an issue where having LibChatMessage enabled would bypass some Chat Announcements toggle settings, the most common being friends logging on & off. Now if you choose to disable these messages, they will cease to display properly.
- Fixed an issue where promoting a player to group leader or being promoted to group leader sometimes wouldn't properly show the promotion chat message/alert.
- Fixed an issue with the Crowd Control Tracker where "Player Set AOE" was using the setting for "Player Ultimate AOE."
- Fixed an issue where the keybinding options for Summon Banker/Merchant were reversed (Banker key summoned Merchant and vice versa).
- Fixed a few strings missing from the German translation.
- DE translation has been started and populated thoroughly thanks to AmonFlorian!
- Added keybindings to summon the new Cat Banker/Merchant from the crown store.
- Updated tooltips, auras, icons, etc for player ability and set changes in Scalebreaker, Dragonhold, and Harrowstorm, as well as did a pass on the tooltips for all of these abilities to update and add range, normalize syntax, etc.
- I purchased a large amount of icons for use from various game development platforms such as the Unity store, this means I will be significantly improving the quality of all custom icons. A good deal of new work as been added with more to come. Credits for custom icons listed at the bottom of the changelog.
- Attacks sourced from Morkuldin will now properly show the localized name "Morkuldin" in death recap.
- Perfected Weapon effect auras, damage, resource restore etc no longer have a "(Perfected)" tag on the end. Some set names were getting a little too long on Combat Text.
- Dark Shade and its morphs now have proper names in Death Recap instead of "Gloom Wrath" (this is the actual name of the pet NPC you summon with Dark Shade + morphs, hopefully ZOS will update it at some point).
- Added the "Forced Square" font into the list of fonts to choose from for LUIE components. Thanks nomaddc!
- Added a function that allows all of LUIE's component frames to be hidden. I did this with support in mind for Essential Housing Tools (and potentially any other addon that makes significant changes to scene display).
- Hooked into the Keep Upgrade interface in Cyrodiil (in Keyboard and Gamepad mode). Improved the icons & tooltips as well as tooltip formatting for this menu.
- Hooked into the Campaign Bonuses tab in the Campaign Browser (in Keyboard and Gamepad mode). Improved the icons & tooltips as well as tooltip formatting for this menu.
- The character "Active Effects" Window in gamepad mode will now display updated tooltips properly.
- Prominent Buffs can now be sorted horizontally in addition to the default vertical setting. May still need some testing. Thanks to AmonFlorian!
- Added an option to display the Ability Id & Buff Type of auras in the tooltips submenu for Buffs & Debuffs.
- Improved Tooltip formatting & extended this formatting to the character "Active Effects" Window.
- Updated the icons for all player weapons attacks to be better quality.
- Updated various icons for sets and attacks to be better quality.
- Updated the icons for many NPC attacks to be far better quality.
- The Iron Atronach Target Dummy nows shows a "fake" debuff icon for Minor Magickasteal (ZoS implementation of this debuff is inconsistent and this one was not showing).
- Added functionality to pull the info from a skill morph for some passive abilities that have shared auras. For example: the Minor Effects from Restoring Aura / Radiant Aura will now show their proper source.
- Updated the tooltips for Dawnbreaker, Beast Trap, and Roar of Alkosh to no longer refer to their damage over time component as "Bleed" damage, as these effects are not considered a bleed effect.
- The stun from the Warden's Feral Guardian + morphs now shows for the player (and other players too since it's pet and not player sources), but at least it can be seen now.
- Removed the menu option for tracking the Sprint/Gallop buff for now - the new method ZOS is using doesn't return an abilityId in game.
- Previously I had changed a lot of NPC uppercut abilities to use the name/icon for Dizzying Swing to stay consistent with how its mechanics work. However, now that the stun has been removed from Dizzying, I'm just reverting this to their default (and fixing missing icons/etc where need).
- The Warden ability Crystallized Shield and its morphs now display the stacks of reflection charges remaining and track the actual duration. This is done by showing the effect that was some reason hidden by default and hiding the default dummy tracker buff.
- Some buffs & debuffs were not able to be blacklisted (due to being "fake" effects) created using Combat Events instead of Effect Events. Added blacklist support for these auras.
- Stone Giant's "Stagger" debuff will now show for all players on a target since it effects everyone attacking the target, and any Dragonknight can contribute to refreshing the stacks.
- When the werewolf transformation timer is added to prominent buffs, it will now display the timer bar properly.
- Print Chat to multiple tabs is disabled currently due to significant changes that were made to the chat API - will hopefully be reimplemented in the future. You can still toggle timestamps for LUIE messages on/off.
- Added additional achievement tracking categories for the new DLC.
- Added a submenu into Collectible Options to enable the display of a chat message or alert when a Collectible in the Vanity Pets, Assistants, Ability Skins or one of the Appearance Changes is used.
- Added support for Undaunted Keys fors currency and loot tracking.
- Fixed some issues with/updated the way VENDOR loot works with the merged messages option selected. Now if you choose to display total currency/total loot it will always display regardless of your individual selections in the other menus. This is so if you want to see totals indepedently on vendors but not when looting (or vice versa) you can.
- Added a 1000 ms delay on resetting the variable that determines if the player is currently browsing a store. Depending on latency its possible to purchase items from a vendor and then close the window before a response from the server places the items in your inventory. When this happened the items would appear as looted instead of purchased. This throttle should stop this from happening.
- Fixed an error with the messages displayed for absorbing skyshards due to the function not being updated with the API changes made in Dragonhold. Thanks AmonFlorian for making this change.
- Updated the quest item added/removed loot tracking to have more syntax options for things like turning in quest items, discarding them, etc. Some of this is automatic and some requires manual input so it will take a while before everything works perfectly.
- Updated many handlers for various Chat Announcement components for API changes made over the last couple years. I will be adjusting these on each update in the future instead of letting myself get behind. A few things that weren't working should be now.
- Added some new support to changes made to the Guild API (when roster was added). Guild rank changes will now display with better information thanks to some new events added in the API.
- Did a pass on the Group Finder chat announcements. The event sequence for group finder is an absolute chaotic mess, but from my testing done on the PTS everything appears to display cleanly, with proper alerts for leaving/entering queue, ready check failure reasons, and entering an LFG activity. I have to hide all group events when an LFG group forms because a mess of party leaving/joining/leader changing happens during it. Hopefully with live server lag during busy times this will still function properly.
- Implemented the features of Miat's Crowd Control Tracker into LUIE (with permission, thanks to dorrino!). This version of the crowd control tracker is enhanced with several new features.
- Display a different border color based on the type of CC applied (including unbreakable cc).
- Choose a custom sound to play when effected by CC.
- Display an alert when standing in hostile AOE effects with various toggleable categories and different sounds options for each. This list requires manual input but I have player skills added, most overland mobs and have at least made some progress adding dungeon/arena abilities.

- Updated many abilities in Combat Alerts with better duration tracking and proper CC types.
- Bar Highlight tracking now supports tracking multiple ability id's, resulting in the ability to track ground mine durations & their effects individually and to track both the physical & magical dot from Soul Trap and so on.
- Updated Bar Highlight tracking to handle API changes made in Scalebreaker. The bar highlights were being refreshed too quickly which could lead to performance issues and resulted in a stuttering effect occuring on the "proc" animation highlight.
- Added a few checks into bar highlight tracking to potentially stop errors from being thrown occasionally.
- Bound Armaments now plays a proc alert upon reaching 4 stacks (and will play the proc animation at any number of stacks).
- Procs that change the ability on your bar (Grim Focus, Power Lash for example) will now have a 3 sec iternal cooldown for playing the proc sound, this way the sound doesn't spam if you swap targets or bar swap.
- Updated the "Absorbing Skyshard" cast bar to use a new icon added in U24.
- Toggling the LUIE ultimate tracker on disables the default UI ultimate tracker to stop overlap from occuring.
- The ability alerts component has had some functionality updates. These are mostly backend feature changes that allow me to get around some of the limitations of the API to display better sources for effects that don't provide them etc, by using manual values.
- Made some changes to interrupt detection for the cast bar due to changes due to API changes. The castbar should now cancel when the player bashes or blocks if those actions can break the cast (Harrowstorm added the ability to bash the air to interrupt channeled effects).
- Fixed an issue where the font selection wasn't working properly and would always use the default game font.
- Combat Text font selection is now sorted alphabetically like most other long dropdown selections.
- Added a slider to control the speed of Combat Text, thanks to AmonFlorian!
- Added an ability blacklist menu to Combat Text. This functions in the same way as the Buffs & Debuffs blacklist - you can blacklist by AbilityId or AbilityName.
- Fixed an error where the setting for Throttling Critical Hits was being reset when the setting for Throttling normal hits was toggled.
- Throttle for Critical Hits menu option is now disabled when Throttle for normal hits is disabled.
- Added a menu option to choose between the old banker/merchant or the cat banker/merchant for their respective slash commands.
- Any slash command that uses a collectible will now display a message in chat when the collectible is summoned or unsummoned.
- Toggling the LUIE overlay on for default unit frames now disables the default UI unitframe text menu option to stop overlap from occuring.
- Custom ability icons by and modified from eleazzaar licensed under the CC[*]3 License ([https://creativecommons.org/licenses/by/3.0/](https://creativecommons.org/licenses/by/3.0/))
- Custom ability icons by and modified from AKiZA, Angelina Avgustova, Blade Dancer, ClayManStudio, Dayed, Digital Worlds JSC, Ever Probe, HOSE, Jon Snow, Josch, Kalle Olli, Moon Tribe, N-hance Studio, PONETI, REXARD, Sky Painter, The 7 Heaven, TiGame, and TonityEden licensed under the Unity Store single entity license. ([https://unity3d.com/legal/as_terms](https://unity3d.com/legal/as_terms))
- Custom ability icons by and modified from a-ravlik & micart licensed under the GraphicRiver regular license. ([https://graphicriver.net/licenses/terms/regular](https://graphicriver.net/licenses/terms/regular))
- Custom ability icons by and modified from Forrest Imel, Frostwindz and Mizuko licensed under the GameDevMarket.net pro license. ([https://www.gamedevmarket.net/terms-conditions/#pro-licence](https://www.gamedevmarket.net/terms-conditions/#pro-licence))
- Fixed an issue where initiating a vote kick on a party member in LFG through the Player to Player interaction menu would throw a UI error due to referencing a renamed function.
- Fixed an issue where recieving Crown Store gifts through the Notifications prompt would cause a Protected Call error. Unfortunately this means accepted/declined response text from sending various invite types to the player will no longer work. I'll have to find another way to handle this in the future.
- Updated the auras/icons/tooltips/bar highlight, etc for all Necromancer skill line active and passive skills.
- Fixed an issue where inviting a player to the guild would display duplicate Guild Member joined messages (since the player invited is added to the roster). Thanks to Eearslya Sleiarion for this fix!
- Updated the currency announcements to correctly display "Earn" context message for Defensive Keep Ticks.
- Updated a significant amount of enemy abilities for Active Combat Alerts (more alerts now show the correct cast time and cc type).
- Fixed a missing local in Hooks.lua & adjusted the load order in order to fix an issue wcausing Friend Invites to throw a UI error.
- Death Recap will now show a source for some environmental effects that used to display with no source (a good example is some variants of traps in areas would source the damage they deal from the player instead of the trap).
- Updated icons, auras, and tooltips for the remaining item sets added with Elsweyr.
- Updated MOST icons, auras, tooltips, and bar highlight for Volendrung artifact weapon abilities. Still missing any effects not present or usable in the tutorial quest.
- Updated icons, auras, tooltips, and bar highlight for the Grave Lord Necromancer skill line.
- The Crusher & Weakening Glyph debuffs will now show for all players on targets regardless of who applied it.
- Removed some code used to create a fake "Home Keep" buff for players in Cyrodiil due to the changed in Elsweyr showing a proper buff again.
- Added icons/tooltips/alerts for Boss Wamasu in Craglorn.
- Updated the Achievement Tracking options with the missing category added with Elsweyr.
- The option to display the global cooldown on abilities when used now only hooks the default UI when enabled. If you disable this component and prefer to use another addon for handling the GCD, it is now possible.
- Fixed a few missing strings for the default variables for Combat Alerts. These default variables have been adjusted to automatically replace the settings that were incorrect.
- Combat Alerts now fade out over 1 sec when the effect ends for a cleaner appearance.
- Combat Alert cast/channel time tracking has been updated to be more accurate.
- Updated the Cast Time & CC type of many alerts. This is still a work in progress, unfortunately the majority of channeled abilities in game don't provide the correct duration in the API settings so I have to check them manually which is rather time consuming.
- Added basic support for interrupt detection for Combat Alerts. This doesn't work in all situations, anything not directly targeting the player or creating a buff effect doesn't provide enough information to determine if an ability was interrupted.
- Added two toggles to show Overkill/Overhealing in the Common Options menu of Combat Text. These are enabled by default, resulting in damage/healing being displayed the same way it was before the API changes made with Elsweyr.
- Added an option to swap the position of the Stamina & Magicka Bar when using the Pyramid or Separate Frames option. Contributed by Eearslya Sleiarion, thanks!
- Removed LibStub dependency since it is embedded in both libraries LuiExtended depends on.
- Fixed an issue with the function that loaded LMP that could cause UI Errors.
- Fixed an issue with the Werewolf Buff Icon Option that would cause UI errors when you died in Werewolf form.
- Added localization and updated tooltips for some of the menu options for Combat Info Alerts.
- Removed embedded libaries, you will now need to download LibAddonMenu and LibMediaProvider separately.
- Fixed an issue where LUIE wasn't dependent on LibStub which could cause the addon not to load correctly.
- Fixed an issue where a missing variable was causing the "Show Icon for Active Assistant" option to throw UI errors.
- Added custom icons for a few sets added in Elsweyr.
- Streamlined and updated some code present in modules, which probably won't be noticeable at all but may cause a slight performance increase.
- Russian translation updated thanks to @amanozako
- Added an option to toggle whether detailed tooltips display on mouseover and to assign a "sticky tooltip" duration to stop them from fading instantly when mousing off.
- Updated tooltips, auras, icons, etc for all player abilities & sets changed in Elsweyr. New sets/Necromancer abilities are not done yet.
- Updated auras for various shared vanilla dungeon boss abilities as well as updated specific auras in Elden Hollow II, Banished Cells I & II, and Spindleclutch II
- Updated auras for DSA Normal and Stage 1 & 2 on Veteran.
- Updated auras for Maelstrom Arena Stage 1-5 on Normal & Veteran.
- Added an icon for the Daedric Titan ability "Swallowing Souls" that is cast when you interrupt Soul Flame.
- Can now add Werewolf Timer to prominent buffs.
- Can now blacklist Home & Edge Keep Bonus buffs.
- Fixed an issue where UI errors would appear when wearing the Dunmer Cultural Garb disguise or when wearing a Guild Tabard when doing the Arenthia questline in Reaper's March.
- Roll Dodge Fatigue now displays stacks each time you roll dodge, and specifies it costs 33% more per stack in the tooltip.
- Bolt Escape Fatigue tooltip updated to indicate more clearly that the cost is increased by 50% per stack.
- Added a new Combat Alerts component, this is a revamp from the Combat Text alerts moved into this component.
- New combat alerts now throttle by 50 ms in order to filter out dummy/bad events (out of range, etc) to prevent possible spam.
- New combat alerts have the option to display a sound, a countdown label for the cast time of the ability, as well as color the icon border based off the type of CC the ability applies.
- Fixed an issue introduced on the PTS due to EVENT_ACTION_SLOT_ABILITY_SLOTTED being removed.
- Removed the Combat Alerts menu and settings, this component has been updated and moved to Combat Info.
- Due to the above change, the "Always Hide Ingame Tips" option has been removed. You can now toggle on/off the display of ingame tips independently from LUIE's combat alerts.
- Added class color option for Necromancer class.
- Some food tooltips may not be right (ZoS hasn't updated them). If they are not fixed with the live update of Elsweyr I will adjust them.
- Most combat alerts don't have a timer added yet nor do they show the type of crowd control incoming as this must be done manually on my end.
- I haven't had the chance to sort through Necromancer abilities yet so Combat Info Bar Highlights may not be working/accurate for all abilities.
- The menu options for Combat Info - Active Combat Alerts are still work in progress and not localized for RU translation.
- The timer bar for the Werewolf buff indicator if you add it to prominent buffs does not work correctly.
- Added updated auras for more dungeons - Elden Hollow II, COA I & II, Tempest Island, Selene's Web, and Spindleclutch I & II and updated a few various icons for enemy abilities.
- Fixed a bug where LUIE was causing Guild Trade search history to not display correctly, thanks to scorpius2k1 for discovering the source of the issue.
- Updated the Changelog to no longer use LibMsgWin, it now uses much simpler and clean xml code to generate the log, thanks to psypanda.
- Buff sorting updated - Now buffs will sort Toggle > Ground/Unlimited Duration > others and those will all sort alphabetically relative to their categories.
- Lots of various table cleanup and minor optimization.
- Fixed an error that could occur when crafting items when switching between crafting tabs with items queued in Multicraft or with other addons like Dolgubon's Lazy Writ Crafter. Note the chat log output may not be correct when this happens - but it should no longer cause a UI error.
- Fixed an issue where the Quest Items in your inventory would display [Received] messages when you log into a character for the first time. While the UI does send the events for this, LUIE just ignores it on login now.
- Updated filtering for combat alerts, there should no longer be duplicate alerts displayed from the same ability.
- Added a new option for Alerts to display Unmitigatable Effects - was prompted to do this by a few dungeon abilities that you can't avoid.
- Added new commands for /cake (/anniverary), /pie (/jester), /mead (/newlife), and /witch (/witchfest) to use the Event XP Boost mementos.
- Added the /report 'name' command - which open the "Report a Player" window and autofills it with useful information.
- Updated auras/icons/tooltips/cast bar/etc for all Player Abilities, Siege Weapons/Repair Kits, any missing & new item sets.
- Updated auras/icons/tooltips/combat alerts/etc for almost all basic NPC abilities, and started working on Dungeon abilities.
- Prominent Buffs will now display even when ALL OTHER BUFF/DEBUFF options are turned off. This was always the intended behavior, but was not working due to a massive oversight on my part.
- Added a new toggle option for Ground Damage/Healing Auras - when enabled a debuff aura will be displayed when you are standing in a ground aoe effect (e.g. Arrow Barrage)
- Fixed an issue where dropping a new rearming trap after only 1 of the 2 traps was consumed would result in two mine auras showing.
- When looting multiple bodies at once - multiple items with the same ID are now combined into a single count. This significantly reduces the amount of spam loot logging generates.
- Updated the Achievement Options with the new category added in Wrathstone and fixed an issue where only some categories would toggle off correctly.
- Cast Bar - The cast bar will now automatically break when certain actions are taken, such as roll dodging.
- Cast Bar - Added functionality to break the cast bar on movement for casts where this happens, as well as fixed various issues with the cast bar not refreshing when interrupting your cast & attempting to recast before the bar finished.
- Ability Bar - Updated the default "Activation Highlight" effect (e.g. Shadow Image Teleport) to now loop the visual effect on the bar rather than playing only once.
- Ability Bar - Guard and its morphs now display the Toggle Highlight visual effect used by other toggle effects (e.g. Mend Wounds) when active instead of just turning into an "X" icon on the bar.
- Updated Combat Alerts to work toward making them less spammy (requiring specific criteria for each ability when cast, and applying a refire delay when various error events such as an NPC being out of range are detected).
- Added "Summon" alerts to Combat Alerts - notifying you if an enemy summons an add.
- Fixed an error where the Interrupt message on Combat Alerts was displaying as "01Interrupt" due to a syntax error in the default color.
- Hid a few snares that rapidly refire from ground auras or other effects that would result in spam when you were immune to them.
- Fixed an issue introduced on the PTS where Player Names on the Group Unit Frames were being displaced from their proper positions.
- General: Significantly updated the Russian localization, as well as fixed an error causing RU strings not to load at all. Thanks KiriX!
- Buffs & Debuffs: Updated tooltips & some auras/icons for all Weapon, Armor, Soul Magic, and Werewolf Skills.
- Combat Info: Fixed a few abilities that had broken Bar Highlight functionality and did some minor cleanup with this functionality.
- General: Fixed typos in the RU localization that was causing UI errors. Thank you Jmopel for fixing this!
- General: Fixed an issue with the hook for the Skill Window to add custom passive/racial icons that prevented Harven's Improved Skills Window from working correctly.
- Buffs & Debuffs: Added tooltips for all Warden abilities & for melee weapon abilities.
- Buffs & Debuffs: Fixed broken tooltips on Stealth-Draining / Conspicuous Poison.
- Buffs & Debuffs: Added an aura for the new ID used for Dismount Stun.
- Buffs & Debuffs: When "Hide Duplicates in Paired Auras" is toggled in SCB, the Active Effects window on the character screen will also hide the auras.
- Chat Announcements: Occasionally "Champion Point Gained" Center Screen Announcements can trigger at the same time, causing the output to display the wrong Champion Points gained. Added a small throttle to prevent this.
- Combat Info: Added a redundant check in Combat Info to stop possible duplicate controls for Bar Highlight from being created and throwing UI errors.
- Combat Text: Reset the "Interrupt" notification color due to a formatting error that occured.
- Unit Frames - Fixed an issue where the default Player / Target / Group frames would fail to display even when enabled in the menu. This setting has been updated and the Saved Variables have been reset. Default Frames will be disabled by default and can be re-enabled by changing the menu option.
- Did some various minor optimization, removing some old and un-needed functions and adjusting a few functions that were enabled all the time to only be used when relevant options are enabled.
- Fixed font paths for non-English localizations.
- Updated Russian localization with many new translations from KiriX. Thank you!
- Fixed an issue where the new icons added for Cyrodiil Campaign Bonuses were clipping through the rounded frames in the Campaign Window.
- Reimplemented custom icons in the Skills Menu & Skills Advisor for Racials & Various passive skill lines.
- Fixed an issue where the Mount icon wouldn't disappear when dismounting in any other way than pressing the mount key. This is due to an issue with the API that should be addressed in a later ESO update.
- Fixed various minor issues with buffs & debuffs from changes made in the Wolfhunter & Murkmire updates.
- Updated tooltips for Champion abilities.
- Updated icons, tooltips, and names for Seasonal Items, Seasonal Experience buffs, and mementos.
- Updated the names & tooltips of various food and consumable items by using the Item Names and Item Descriptions from these items.
- Added duration into most toolips and updated the functions used for this to pull accurate values.
- Updated tooltips for almost all item sets (missing Rewards for the Worthy Sets) and all Classes except Warden. Other skill lines will be processed in the future.
- Added a timer to the "Battleground Deserter" debuff - and moved it into the long term effects container if enabled.
- WIP - Started adding support to add a "G" label on any buff/debuff effect that is applied while the player is standing in a ground AoE effect. This is only implemented on some abilities but will be expanded in the future.
- Fixed an issue where some undispellable debuffs (read by the game API as buffs) weren't set to debuffs in the Character Screen Active Effects Panel.
- "Crystal Fragments Proc" has been renamed to "Crystal Fragments." If you are tracking it by name in a prominent container you will need to update the name. The abilityId remains unchanged.
- Fixed an issue where Prominent buffs with an unlimited duration would duplicate auras when you zoned into a new aura.
- Added fake buffs for Home Keep Bonus & Edge Keep Bonuses to Player/Target when Cyrodiil Buffs are enabled.
- Added currency message options for Event Tickets.
- Fixed an issue where sometimes when rapidly looting/stealing items the message context would switch back from looted/stolen to "received."
- Fixed an issue causing Tel'var Stone and Alliance Point transactions not to display the amount of currency spent with the merged message option enabled.
- Updated Alliance Point throttle to include AP earned from Keep Repairs & Resurrecting Players.
- Added a note to specify that the "Show Used Crafting Items" option in Loot Announcements doesn't work properly without ESO Plus.
- Fixed achievement tracking categories missing with the Murkmire update.
- Fixed a UI Error that would occur from Disguise Alerts during "The Colovian Occupation" quest in Arenthia in Reaper's March. This quest puts you into a disguised state without an item in your disguise slot which was causing errors.
- Added a cast/channel bar for various mementos (replacing the icons that showed on buffs & debuffs previously).
- Added a cast/channel bar for some seasonal quest events & items (replaced the icons that showed on buffs & debuffs previously).
- Fixed an issue causing Crystal Fragments proc not to play a sound or be tracked.
- Fixed a few missing Bar Highlight trackers.
- Fixed an issue introduced with Murkmire where Bar Highlight & Ultimate Tracking was not behaving properly due to relying on a function no longer used by the API.
- Dragonknight - Updated the icon for Power Lash to stand out a little more from Molten Whip.
- Nightblade - Shadow Image now has a unique icon (with similar colorization to the new green color for Incapciating Strike when the player is above 120 ultimate).
- Nightblade - The Proc Icon for Grim Focus and its morphs now shows the remaining timer for Grim Focus on it.
- Sorcerer - Unstable Familiar & Summon Winged Twilight abilities now use different icons on their bar/for their effects. The icons matching the base icon are ingame but for some reason not used.
- Added an option to display Group Member Deaths (enabled by default).
- Updated the variable names for Incoming Ability Alerts - this will reset the color for Block, Dodge, Avoid, and Interrupt notifications. In a previous update Combat Alerts were changed to support multiple colors for the different alert mitigation types to improve clarity - this resets this for anyone who wasn't aware as well as adds a blue color for interrupt instead of white.
- Info Panel no longer shows on all screens (Now hidden in menus, on the world map, and during dialogues).
- Added an option to enable the Info Panel on the World Map Screen.
- Added Resolution Selection options to UnitFrames, this changes the default anchors for UnitFrames.
- Updated UnitFrame default positions to anchor relative to the center of the screen rather than top left.
- If you are installing the addon for the first time or clearing saved variables - the default unit frames are now disabled by default.
- Added a "Disable" option to Default Group Unit Frames. It was confusing not being able to set this to disabled before if you were using Custom Group/Raid Frames.
- Added an option to toggle off the Default Compass Boss Bar.
- Added target Rank Stars to elite enemy NPC frames - this will show 1-3 stars based on the difficulty of the elite mob you are fighting - similar to the default boss/target frames indicators.
- Updated Group/Raid frames to follow this functionality described in the Custom Raid Frames description: "If custom group frames are unused, then this raid frame will also be used for small groups."
- Added an option to color the Target Frame by Player Class - this option takes precedence over Reaction Colors when both options are enabled.
- Fixed an issue where Group/Raid Frames didn't color correctly when no role was detected (in Battlegrounds).
- Fixed an issue where the Mount Stamina bar wouldn't toggle off properly when dismounting in any other way than pressing the mount key. This is due to an issue with the API that should be addressed in a later ESO update.
- Fixed an issue where the shared transparency setting for Group/Raid frames under Custom Raid Frames would be disabled when Custom Group Frames were disabled.
- Flipped the menu order for color Group/Raid Frames by Class/Role. Role color takes precendence and therefore is the later option listed in the menu.
- Combat Info: Fixed an issue where Cast Bar custom position was not saving correctly.
- Unit Frames: Fixed an issue where Group and Raid frame Role Colors & Icons were not working (thanks SilverWF for finding the issue and fixing it).
- Temporarily removed custom icons for passives and racials in the skill tree due to the related functions for this being changed in the update. I intend to reimplement this in the future.
- Fixed various localization issues with some components.
- Moved UnitFrames, Buffs & Debuffs, Combat Text, and Info Panel components down to lower draw layers (preventing them from overlapping low priority layer custom addon windows).
- It may have been possible for debuffs not cast by the player to display in prominent buffs - added a filter to only show debuffs sourced from the player.
- Fake & Consolidated Buffs & Debuffs can now be added to Prominent Buffs & Debuffs or the Blacklist by AbilityId.
- Mousing over buffs & debuffs now shows the tooltip information.
- Right clicking on buffs that can be removed will now remove the buff.
- Updated & added custom tooltips for many abilities - as well as added normalized tooltips for Major/Minor effects.
- Updated icons + auras for Main Story Quests, Fighter's Guild, Mage's Guild & the first 2 (about 50% of Greenshade as well) zones of AD quests.
- Updated icons for NPC summon abilities (Each summon type now has an individual icon).
- Hid various dummy id's for NPC summon abilities & NPC Caltrops.
- Fixed an issue where NPC name based icon/name overrides for pets didn't correctly apply to the Death Recap Screen.
- Buff Icon for Vanity Pet / Mount now shows the actual collectible icon overlaid over a background (Added an option to show the generic mount icon if desired).
- Added cast bar for various general effects such as Filleting Fish, using Keep/Imperial City Retreat Sigils, Pardon Edicts, etc...
- Added an option to show when items are removed by quests or events. This requires the destroyed item message display option to be enabled (Otherwise can't tell if a player just destroys an item).
- Removed hook for EVENT_BROADCAST - stops duplicate server shutdown messages from being displayed.
- Updated Achievement Tracking Categories to support all achievement categories (they have been branched out again with Wolfhunter DLC).
- Added some additional conditionals to messages displayed when upgrading an item in order to prevent errors.
- Added option to resize Cast Bar & Cast Bar Icon
- Cast Bar Frame is now centered by default, and resizing keeps the bar centered
- Cast Bar - Significantly improved the display options when unlocking the Cast Bar in the menu to adjust position.
- Cast Bar will now break when incoming hard CC hits the player - or when the player rolls/blocks
- Fixed a bug where Bar Highlight effects that were created by EVENT_COMBAT_EVENT would be removed when mousing over another target.
- Added cast bar indicators for for Main Story Quests, Fighters Guild, Mages Guild & the first 2 (about 50% of Greenshade as well) zones of AD quests.
- Added cast bar for Soul Gem Resurrection.
- Combat Text menu completely reorganized in order to be more accessible. All options are now categorized together (I.E. all options for Outgoing Damage, Healing, etc are grouped together now rather than being split across multiple submenus).
- Updated Alerts to use different colors for each type of alert in order to improve differentiation.
- Updated Alerts to use conditionals to determine if "Name" or "No Name" prefixes should be used. These options have been added to the menu as well.
- Fixed an issue where custom icons/ability names based off target name were not displaying correctly.
- Added the silence effect from Negate Magic & Morphs to the blacklist for SCT - this will no longer spam immunity notifications every .5 seconds on CC Immune targets.
- Fixed a major issue where Unit Frames did not properly follow the Account Wide / Player Specific saved variable settings in the menu.
- Added right click handler for Group Frames - you can now acccess group menu functions by right clicking frames.
- Fixed an issue where disabling the option to display the player in Small Group frames would cause the role of class color to be incorrect.
- Added Group Frames, Raid Frames, and Boss Frames into "loot" scene to prevent those frames from disappearing when looting an item.
- Added tooltips to Custom Frames - Alternate Player Bar( for level information, Siege, Werewolf, and Mounted Status).
- Alternate Player Bar - Champion XP bar now shows Enlightenment value.
- Fixed an issue where frames weren't added to the "siegeBarUI" scene - causing your frames (and buffs if anchored) to fade when typing in chat or switching to mouse controls while using a Siege weapon.
- Werewolf Buff Indicator (Buffs & Debuffs) & Power Bar (Unit Frames) now behave correctly when dead/reincarnating
- Fixed issue with Werewolf buff icon bouncing back and forth between effects that had a longer duration than it (due to forcing it to always have a maximum duration of 38 seconds).
- Devour Cast Bar now ends when devour channel is broken
- Devour now pauses Werewolf Timer buff when starting and resumes immediately when ending
- Combat Info: Added a cast bar for player abilities. Has a variety of customization options and position customization.
- Combat Info: Fixed an issue where bar highlight for some abilities wasn't working. Updated ground tracking and mine tracking to remove auras when ground effects end prematurely.
- Buffs & Debuffs: Ground based auras are now removed when a ground effect ends prematurely.
- Buffs & Debuffs: Updated mine tracker to work for Eternal Hunt set, Manifestation of Terror, and Frozen Gate + morphs.
- Buffs & Debuffs: Fixed an issue where disabling ground effects from display would not do anything - as well as fixed blacklisting ground abilities not working.
- Buffs & Debuffs: Updated icons and auras for base Cyrodiil buffs. Keep bonus now shows a stack counter equivalent to the number of enemy keeps your Alliance controls. Also hid some useless auras on Guards/Structures.
- Buffs & Debuffs: Added missing icon/name changes for pve bite variants of Lycantrophy and Vampirism precursors (evidently its a different abilityId than you get from player bites).
- Buffs & Debuffs: Updated a few various icons for auras & environmental hazards.
- Combat Info: All bar proc abilities will now play a sound when available for use, not just Crystal Fragments.
- Buffs & Debuffs: Fixed an issue with the prominent buffs font selector that could cause a UI error if an invalid font was selected.
- Buffs & Debuffs: The debug option for Combat Events and Effect Changes now display abilities with the name updated to reflect changes made by LUIE.
- Added RU Translation thanks to a ton of effort from KiriX!

- Did a pass on ALL player skill line abilities - updated auras for all abilities with name corrections, icon corrections, and hid unneccessary dummy auras.
- Added custom icons for the attacks used by Nightblade, Sorcerer, and Warden pet abilities.
- Added custom icons for a great deal of NPCs that were missing them including all Dwemer NPCs, Giants, Trolls, Daedric Hungers, Iron Atronachs, etc...
- Updated localization for major/minor debuffs so that all languages will show major/minor debuffs on the target regardless of source.
- Reset the options for "Display Extra Buffs & Consolidate Buffs" to account for some changes made with this update as well as added an additional option to consolidate single major/minor auras.
- Grim Focus updated to track its stack count on the duration buff applied to the player.
- Fixed an issue where Ground Mine stacks weren't decremented when a mine triggered if an aura was set to prominent.
- Removed a significant amount of older code related to ground effects that should result in minor performance enhancement.
- Fixed an issue where the Pelinal's Ferocity experience buff was not correctly labeled as an experience buffs for the purpose of hiding it from display.
- Updated auras for various sets, and added updated icons/auras for sets from Dragonstar/Maelstrom Arena, as well as all Summerset sets.
- Fixed an issue where prominent auras weren't removed from tracking when the player died.
- Added the option to display a timer buff when transformed into a Werewolf. This timer will pause at a Werewolf Shrine or when using the Devour passive.
- Fixed an issue where dummy auras added by target name (example: CC Immunity buff added to some boss NPCs) would display on dead targets.
- Fixed an issue where Artifical Effect id's would not refresh when updating settings in the Buffs & Debuffs menu (dummy auras added by ZOS - such as Battle Spirit).

- Fixed an issue that was causing Disguise Notifications not to display even when enabled.
- Updated Achievement Tracking options with all current categories.
- Added Psijic Order guild reputation tracking.
- Fixed an issue where the menu option to modify the context currency/loot message for "Spend" was missing.
- Added a new context message option "Pay" for gold given to NPC's in conversation options.
- Jewelry Crafting should now be supported by Loot crafting messages.

- Did a pass on ALL player skill line abilities - Bar Ability Highlight tracking is now supported for any ability the player can slot.
- Bar Ability Highlight tracking now supports multi-target tracking, when changing targets the highlighted abilities will update based on what debuffs are currently applied to that target.
- Fixed an issue where the Crystal Fragments proc sound wouldn't play due to a bad variable name.

- Fixed an issue where errors would be displayed when the Shorten Numbers option was enabled.

- Reimplemented the menu option to change the scaling on the Info Panel for higher resolution displays.
- Mount feed cooldown notification updated from "Feed Now" to "Train Now."

- Added the "/outfit" "#" command. Allows you to swap to an outfit. Also adding keybinding options.

- Implemented an ingame changelog that will display on the first load with LuiExtended enabled when the version number is different than your current version. This changelog can also be viewed from the addon settings menu.
- Added the option to switch between using ACCOUNT WIDE or CHARACTER SPECIFIC savedVariables settings. Profiles can be copied between characters or deleted from the addon settings menu.
- Separated Slash Commands & Info Panel modules into their own individual component menus.
- Updated and cleaned up various menus to be more intuitive.
- Replaced GetSynergyInfo() hook with ZO_Synergy:OnSynergyAbilityChanged() hook in order to fix compatibility issue with Innocent Blade of Woe addon by dorrino. This is a better way to hook, as only the displayed icon is modified and the original synergy info is preserved.
- Chat Printing settings have been moved to Chat Announcements - and updated to allow the option to print to individual tabs instead of all tabs. This allows you to have loot, experience, etc notifications only display in one chat tab. Also added a toggle to allow system/notification based messages to bypass this and still appear in all tabs. These settings have been reset to default due to this change.
- Added an option to choose the color for timestamps prepended to chat messages.

- Added the ability to track prominent player buffs & debuffs by name or AbilityId. Prominent containers support the ability to display the aura name and a timer bar.
- Added the ability to blacklist buffs & debuffs by name or AbilityId.
- Updated auras and improved custom icons for various NPC abilities as well as added new icons and updated auras for many NPC's missing them.
- Added auras & icons for Scalecaller Crown Crate memento effects.
- New internal table allows simulated aura display on targets based on name. This allows for the display of buffs such as Radiance on Flame Atronachs and CC Immunity on boss rank enemies.
- Added a Debug option to display the AbilityId of effects on their buff/debuff icon.
- Added Night Mother's Gaze & Line-Breaker into debuffs that always display on a target regardless of source.
- Fixed an unintentional change which modified the Line-Breaker debuff from the Alkosh set to be named "Roar of Alkosh." This should prevent Combat Metrics from combining the two debuffs when reporting uptime.
- Fixed an issue where Off Balance Immunity wasn't displaying on targets and adjusted it to display as a buff rather then debuff. This effect can still be tracked by prominent buffs & debuffs due to its importance.

- Updated the default variable settings for Alliance Point, Tel Var Stone, and Experience Point notifications so throttling is enabled by default.

- Added an option to toggle on/off the display of bar highlight for secondary effects like the magicka restore from Honor the Dead or Major Savagery from Biting Jabs.
- Added option to change the formatting of the Ultimate Percentage Label & set the default font/position to match that of bar highlight.
- Added an option to play a sound on ability procs.
- Anchored bar labels to Action Button instead of flipcards, this stops the label from wiggling erratically when swapping bars.
- Fixed an issue where when bar ability highlight for the Ultimate slot was enabled along with Ultimate % label the two labels would overlap on application for a split second.
- Fixed an issue where the initial bar highlight label created for effects would display the default base ability duration without compensating for the extra duration added to many abilites added by EVENT_EFFECT_CHANGED.

- Added an option to set Transparency for Combat Text.
- Added an option to abbreviate numbers like 12345 to 12.3k.
- Updated Incoming Ability Alerts to hide suggested mitigation options by default. Now messages will simply display incoming ability name/icon unless mitigation method notification is toggled on.

- Info Panel module has been moved to its own "LuiExtended - Info Panel" settings menu.
- Fixed an issue where the Info Panel displayed over other UI menu's by adding it into the Scene Manager.
- Fixed an issue where the "Feed Now" timer was clipped.
- Fixed an issue where the Armor Durability indicator was clipped.
- Removed outdated Imperial City Trophy Display & Scaling Options.

- Slash Commands module has been moved to its own "LuiExtended - Slash Commands" settings menu.
- Slash commands can now be enabled or disabled individually.
- Added /banker, /merchant, /fence commands to summon assistants.
- Added /ready command to initiate ready checks.
- Added keybinding options for /banker, /merchant, /fence, /ready, /home & /regroup.

- Added an option to display the AVA Icon & Rank Number independently from the Title or AVA Rank Name on Target Frames.
- Added an option to set the priority for AVA Rank vs Title Display on Target Frames.
- Added individual options to choose the Low Resource threshold for HP/Magicka/Stamina labels.
- Added an option to select the transparency of the shield bar when using the default Overlay mode.
- Fixed an issue on Target Frames where rank 0 "Citizen" players would display with a rank number of "ava."
- Fixed an issue where changing the Player Frames layout would also reset the position of Group, Raid, Boss, and AvA frames.
- Fixed an issue where the AvA rank icon of players of the same faction was colored white. The AvA icon for players of the same faction will now display the proper faction color.
- Base - Updated LibAddonMenu to the latest version.
- Buffs & Debuffs - (WIP) Updating auras for Dragonknight Skills & added new custom icon for Power Lash (only rank 1 currently).
- Buffs & Debuffs - Added Debug Options in the Buffs & Debuffs Menu for EVENT_COMBAT_EVENT and EVENT_EFFECT_CHANGED - Mostly this is included for development.
- Buffs & Debuffs: Added option to only show one buff/debuff in paired effects (like Burning Talons or Throw Dagger that have a dot + snare/root of the same duration) - saves some space in the debuff container.
- Buffs & Debuffs - Vampire Stage now shows a Stack Counter dependant on the stage.
- Buffs & Debuffs - Did a pass on all basic overland Human NPC's and Human DLC NPC's as well as Justice NPC's and Cyrodiil Guards. Aura updates, icons & Combat Text alerts updated. Some Animal + Insect mobs have been updated as well.
- Buffs & Debuffs - Added ground mine aura tracker for Eternal Hunt set.
- Chat Announcements - Fixed an issue with the score always displaying as "nil" in VMA/DSA/Trial Announcements.
- Chat Announcements - Hopefully fixed an issue where some users were getting error messages on login or looting related to the Laundered item function.
- Chat Announcements - Updated Quest Loot display function to now display removed items first always instead of going in order of the item index.
- Combat Text - Added support for Combat Event based notifications to Alerts.
- Combat Text: Added option to display new Alerts for two events:[LIST]
- Important Buffs: Show an alert when an important/powerful enemy ability is used such as significant power increases.
- Destroy: Show an alert when a priority target is spawned - enemies or objects that apply significant damage boost, damage reduction, or invulnerability. So far just used for Goblin Shaman's Aura of Protection.
- Combat Text - Hid the notification that targets are immune to the Sacred Ground templar passive snare due to screen spam.
- Unit Frames - Fixed an issue where Guard -Invulnerable- HP bars would remain in the red execute range text color if mousing over them when the previous target was in execute range.
- Fixed an issue where using Beast Trap (and its morphs) with the Buffs & Debuffs component enabled could throw UI errors.
- Fixed an issue where the aura for Beast Trap (and its morphs) ground duration tracking wouldn't be removed when the target dodged the attack.
- Did a pass on custom override tables for Templar Skills, Destruction Staff, Restoration Staff, Fighter's Guild, and Medium Armor. Many effects are now fixed to show the proper names and icons for Buffs & Debuffs and Combat Text. Additionally many erroneous auras that displayed now longer show up - such as pointless placeholder effects when the healing effect from Healing Ward fading triggered. Bar Highlight tracking for Combat Info has been updated to track many more abilities both offensive and defensive in these ability categories.
- The above support extends to additional addons if they use GetAbilityName() or GetAbilityIcon() functions - For example Combat Metrics will show the correct icon/name for incoming healing tracked from Templar/Restoration Staff skills with LUI Extended enabled. Previously many healing abilities were named incorrectly, a good example being the initial heal from Healing Ward being named "Grand Healing."
- General cleanup - Removed some un-needed hooks and a few lines of outdated code from various components.
- Fixed an issue due to an oudated hook function where the Skills Advisor would throw UI errors whenever an ability was learned.
- Skills Advisor now reads custom icons used for Class passive abilities.

- Added localization support for auras for player abilities, sets, and consumables.
- Thanks to the API update added Death Recap list can now use AbilityId's to properly update ability Names & Icons.
- New icon added for Soul Summons passive, Roar of Alkosh
- Added new icons for root effect from Beast Trap and it's Morphs and the Fighter's Guild skill Silver Leash's secondary ability "Tighten."
- Effects with a stack count now display at one stack rather than only showing their stack count when above 1 stack.
- Fixed an issue where Fake Debuffs (buffs/debuffs without an effect aura that are manually tracked so the player can keep track of them - example is Rearming Traps damage component) weren't properly saving their info for Target players and would fade when changing target and then mousing back over the target again.
- Stack support added for Ground Mine effects - Rearming Trap now displays with 2 stacks, one is consumed every time rearming trap triggers. Later support to be added for Daedric Mines, and sets like Eternal Hunt.
- Added an option to toggle on/off the display of Extra Buff/Debuff icons for certain player abilities that don't normally show a tracking icon such as Dragon Blood or Restoring Focus.
- Added an option to toggle on/off consolidation of Major/Minor buff/debuff auras from certain player abilities such as Dragon Blood or Restoring Focus.

- Updated currency context messages to support currency received from Level Up Rewards.
- Updated icon for Outfit Change tokens.
- Crafting loot messages will now display for equipped items (for the new base game feature to upgrade equipped items).
- Hopefully updated Guild Heraldry function to display the correct amount of gold deducted when setting Heraldry (can't test this currently).
- When buying a Horse from the Stable, the Item Link is now replaced with a Collectible Link.
- Fixed an issue where a few functions wouldn't properly set item brackets based on the menu setting.

- Fixed an issue where label timers for active abilities highlighted on the Action bar would flash when a potion was used.
- Fixed an issue where label timers for active abilities on the action bar didn't apply the label immediately upon the effect being gained (sometimes showing 0 duration or no label for a split second).
- Updated bar tracking function to be more accurate. Bar tracking no longer starts until the actual EVENT_EFFECT_CHANGED or EVENT_COMBAT_EVENT fires.
- Bar tracking now uses effect duration (with a custom table for fixing issues) rather than GetAbilityDuration() as these value's often don't match for ground targeted effects.
- Reimplemented highlight animation for skills with a proc effect that change the Action Bar icon when enabled (Grim Focus + morphs, Silver Leash).

- Fixed an issue where the Ellipse style text did not properly display with the scrolling direction set to up.

- Added multiple options to choose how to display the Player Name on UnitFrames. You can now select a different method for Player, Target, and Group/Raid.
- Updated several Menu Options to change on the fly rather then requiring /reloadUI.
- Updated several Menu Options to properly unhide the relevant frames when making customization changes.
- Unit Frames - Fixed issue with Regen Arrows animation throwing errors if one of the few abilities in game that properly tries to apply a magicka or stamina regen animation is used. Now if the regeneration type isn't Health the function will end.
- Base Addon - Death recap custom icon replacement temporarily disabled. New function is all set and will be implemented with the API changes when the Dragon Bones update goes live.
- Buffs & Debuffs - Added individual hide options for Player/Target for Food/Drink buffs & Experience buffs.
- Buffs & Debuffs - Updated localization for Consumables & Mementos
- Chat Announcements - Merged Currency and Loot context messages into one set, and moved the settings into their own Shared Submenu.
- Chat Announcements - Added tracking options for Transmute Crystals, Outfit Change Tokens, Crowns, and Crown Gems to currency announcements.
- Chat Announcements - Removed pointless ZO_Smithing and ZO_Enchanting hooks - these could cause other addons that hook the same function such as FCO Craft Filter and Multicraft not to work properly.
- Chat Announcements - Added option to hide the Guild Trading House listing fee.
- Chat Announcements - Fixed an issue where laundering/fencing items without "Merge Currency & Loot Messages" enabled would throw UI errors. Now added context messages for Fence/Launder without a gold value in case of this.
- Chat Announcements - Fixed an issue where mail received when returned from another player would throw errors when loot or currency announcements were enabled.
- Chat Announcements - Fixed an issue where the Group Leader changing would occasionally throw UI errors (after leaving group sometimes the event would fire).
- Combat Info - Can now toggle the Ultimate Value label and Ultimate Percentage label independently.
- Combat Info - Can now toggle to display the duration label and glow effect on Ultimate ability. This will hide the % label for the duration of the active ability when enabled.
- Combat Text - Removed IsError filter on Combat Text which was preventing immunity messages from displaying correctly.
- Combat Text - Hopefully fixed an issue with Combat Text occasionally throwing error messages on Alerts with the Single Line Alert method option selected.
- Info Panel - Updated spacing and font format for Info Panel.
- Info Panel - Adjusted the threshold for the colorization of various labels and removed the decimal place in FPS tracking.
- Unit Frames - Added an option to color target custom Unit Frame by Reaction type.
- Unit Frames - Guards now have an - Invulnerable - tag on their HP bar instead of displaying HP.
- Unit Frames - Fixed an issue where the Regen arrows animation was applied on Magicka/Stamina bar (this was never implemented in the game correctly to use and only seemed to trigger from something in Cyrodiil).
- Unit Frames - Fixed an issue where the alternate bar would not anchor correctly to the separate shield bar if enabled when using Horizontal or Pyramid unit frames.
- Unit Frames - Fixed issue where setting menu option for player frame mode would throw errors if the custom target frame was disabled.
- Unit Frames - Fixed an issue where the a UI error would be displayed if the PVP Target Frame was enabled.
- Unit Frames - Fixed spacing issues with alternate bar below frames - now the distance should be normalized for all bar setups.
- Unit Frames - Moved menu for Additional Player Frame options down as well as updated a few menu strings.
- Combat Info - Fixed a MAJOR PERFORMANCE ISSUE with the Show Global Cooldown function - This setting is now reset to disabled for all players using the addon. This setting now has a warning for high CPU usage.
- Buffs & Debuffs - Changed icons for the one hour buffs granted by completing World Boss events in Craglorn to use the achievement icons which fit far better for each buff.
- Chat Announcements - Moved Common Options settings for Chat Announcements to the bottom of the menu and fixed the missing header.
- Chat Announcements - Moved the various events related to EVENT_DISPLAY_ANNOUNCEMENT into their own category in chat announcements. This currently includes: Respec Notifications, Entering/Leaving Group Area, DSA/Maelstrom Stages, Maelstrom Rounds, Imperial City Area Messages, Craglorn Buffs (new).
- Chat Announcements - Display Announcements no longer display a debug message by default - You can now turn this setting on if you'd like to help process messages that are not yet included in the LUI Extended Options.
- Chat Announcements - Fixed an issue where sending a COD payment would also send a duplicate "Mail sent!" message if Mail Notifications are on.
- Chat Announcements - Fixed a UI error that would occur in gamepad mode when trying to send mail due to not being able to determine the recipient name.
- Chat Announcements - Fixed Group Loot member names sometimes displaying as "nil"
- Chat Announcements - Fixed an issue where UI errors would be thrown when attempting to trade after accepting a trade invite after reloading the UI.
- Chat Announcements - Mail, Trade, and Group Loot functions now have fallback options in case the name of the target player cannot be resolved. There are new context menu strings for these messages.
- Chat Announcements - Formerly when sending mail to an invalid player name, a currency sent and received message would print for the transaction and immediate refund. These messages are now suppressed.
- Unit Frames - Fixed an issue where regen/degen arrows would play the first time you moused over a target on loading the game.
- Unit Frames - Moved menu options into dropdown categories instead of one gigantic menu
- Unit Frames - Added new Player Frame Methods - You can now choose to have bars displayed in a horizontal spread out layout like the default UI, or in a Pyramid stack. NOTE: This setting will reset your custom positions and center the frames!!!
- Unit Frames - Alternate Bar (XP Tracker, Werewolf Tracker, Siege Tracker, Mount Stamina Tracker) is now located centered below the attribute bars. Additionally this frame will now move to the stamina or magicka bar if you have Horizontal or Pyramid Frames selected.
- Fixed a MASSIVE performance issue caused by the Unit Frames Regeneration Arrows overlay - This update should remove menu lag and fps drop when turning your camera or in crowded areas as well as FPS drop in combat. You may still experience some FPS hit when using the Scrolling Combat Text. Let me know if you have any major performance issues after this update.
- Added filters onto Combat Events for CombatInfo component to increase performance
- WIP: Started to add a new method for Unit Frames to display the 3 bars separately on the bottom of the screen. This is a work in progress with menu option localization incomplete, default position incomplete, and missing functionality to move the mount/ww bar to the stamina/magicka frames.
- Buffs & Debuffs - Added filters for EVENT_COMBAT_EVENT - Should help with performance issues.
- Combat Text - Added filters for EVENT_COMBAT_EVENT - Should help with performance issues.
- Chat Announcements - Added group loot print function back in (never intended to remove it).
- Chat Announcements - Fixed an issue where inviting a player to group who could not be found would display "That player is busy" instead of "Could not find a played named "input" to invite."
- Chat Announcements - Fixed an error that would occur when depositing items into the bank.
- Chat Announcements - Temporarily removed EVENT_DISPLAY_ANNOUNCEMENT debug message. Think I've just about logged everything here now, thanks guys.
- Unit Frames - Frames no longer unhide in menus when group members change role/or leader is updated
- Fixed a MAJOR issue causing group invites to not function when Chat Announcements was enabled.
- Fixed an issue where using the Sell All Junk button at a vendor with Loot Announcements enabled would throw errors when more than one item was sold. The fix here is temporary (only one item will display - with the total value of gold received) until I have time to drum up a better solution.
- Buffs & Debuffs - Fixed an issue with a missing function causing buffs fading to throw UI errors when Fade Out Expiring Icons is enabled.
- Chat Announcements - Hopefully fixed an issue where Guild Rank changes would throw UI errors when enabled. I am unable to verify this works currently due to lacking a guild to test in on the PTS.
- Chat Announcements - Fixed an issue where all currency gain/loss would display unless you had all 4 currency types set to disabled.
- Chat Announcements - Fixed an issue where certain functions in this component would trigger even when it was disabled in the settings menu.
- Combat Text - Combat text controls renamed to "LUIE_CombatText" to prevent conflicts with other addons.
- Combat Text - Added slight filter for combat events (previously a few variables were being set on every combat event even if it wasn't related to player or pet/target - now that only happens if the source/target is the player or pet)
- Combat Text - Added an option (disabled by default) to hide nearby enemies abilities that don't directly target the player. This prevents spam from abilites that are happening out of range of the player when disabled. Note: These alerts still always display in dungeons since players are likely to all be in relatively the same area.
- Combat Text - Fixed an issue where incoming mitigation warnings would always display even when disabled.
- Combat Text - Added a missing menu option for turning Outgoing Reflects off. Additionally fixed the toggle options for reflects so Incoming displays attacks you Reflect and Outgoing displays attacked an enemy reflected.
- Damage Meter Component has been removed. Highly suggest using Combat Metrics instead. ([Combat Metrics on ESOUI](http://www.esoui.com/downloads/info1360-CombatMetrics.html)).
- Combat Info component has been split into two components: Scrolling Combat text has been revamped and replaced with the more advanced features from the Combat Cloud addon. Combat Info has been updated with additional functionality. More details listed per component below.
- Added an option to Hide the Experience Bar/Skill Progess Bar from popping up when the player earns XP from Experience Gain from Quests, Discover, Boss Kills, and Skill Line Updates. This is useful if you wish to place a UI component in the top left corner of your screen.
- Updated description and functionality of the various SLASH commands. Error messages have been streamlined and will display additional alerts based off your preferences in Chat Announcements for the relevant commands.
- Several SLASH commands now return errors if attempting to use them in Cyrodiil or Battlegrounds where it is not possible to do so.
- /regroup command no longer attempts to invite offline players or duplicate players in the party, as well as provides information if no additional players are present. If all party members are offline the regroup command will not proceed.
- Added a new /campaign option to queue for campaign. Enter /campaign "name" to queue for a campaign.
- Added Trajan Pro and Trajan Pro Bold fonts to the font library for use in LUI.
- Dropdown menu options to select font now use a scrollbar method to prevent the number of font choices from going off the screen.
- Adjusted menu options for various components to be more logically organized.
- Fixed an issue where Buff/Debuff names, Combat Text messages and Item Styles did not display correctly on non-English clients.
- Fixed an issue where the /kick SLASH command would prevent the /kick emote from being used. Now if you enter /kick without any additional input, the kick emote will be performed correctly.

- Bar highlighting component removed and reimplemented in Combat Info component.
- Buffs/Debuffs now display by EffectSlot instead of abilityId, this means if you have 3 searing strikes on your, they will all show as an individual debuff as you would expect.
- Buffs/Debuffs will not display the stack count in the upper right corner of the icon when applicable.
- Player/target debuffs no longer stack infinitely across the screen when anchored to the LUI Target Frame, and instead will stack upward (in the same way buffs stack downward).
- Remaining time label can now be moved up or down to be positioned below or further inside the icon.
- The radial cooldown border for buffs and debuffs now shows relevant to the total duration of the effect. Previously effects showed a solid border until their remaining time dropped below 8 seconds.
- Buffs/debuffs with unlimited durations will now display a solid radial cooldown border instead of being empty.
- Recall Cooldown indicator renamed to Recall Penalty and adjusted radial cooldown border to show its remaining duration relevant to the full 10 minute duration.
- Added an option to reverse the buff sorting order for the Long Term buff container.
- Fixed an issue where the long term buff container anchor was displaced when moving the frames with the Horizontal display option selected.
- Added an option to HIDE the display of player or target buffs in addition to debuffs. Also added an option to hide the display of ground targeted buffs and debuffs.
- Removed many excessive icons options for collectibles. Collectibles have been condensed into 3 options: Assistants, Vanity Pets, and Mounts.
- When the option to show equipped disguises is enabled, a buff will no longer be displayed when wearing a guild tabard.
- Option to Show/Hide Vampirism & Lycanthrophy buffs on Player/Target have been split into several categories: Vampirism Stage, Lycanthrophy, Precursor Disease, and Bite Cooldown
- Option to Show/Hide Battle Spirit on Player/Target have been updated to now correctly display Battle Spirit in Battlegrounds, Cyrodiil, or Duels.
- Added an option to Show/Hide Soul Summons internal cooldown on Player/Target.
- Added an option to Show/Hide Set Bonus long internal cooldowns (Phoenix, Eternal Warrior, Immortal Warrior) on Player/Target.
- Ground targeted buffs/debuffs no longer incorrectly display an aura when the player presses the relevant ability but cancels it without selecting the target location.
- Updated code for ground targeted buffs/debuffs for more accurate duration resolution. Note: Not all buffs/debuffs have been correctly adjusted to use this new code yet)
- Added/updated icons for new Clockwork City food, and new crown items and memento's added in the last several updates.
- Updated aura information for various consumables and memento's (Examples include hiding some goofy duplicate buffs that show for certain food/drinks, renaming seasonal foods that didn't have the correct names, etc)
- Updated several memento self-stuns as well as various other abilities to use the "unbreakable" border color for buffs/debuffs - indicating there is no way to remove the effect.
- Updated icons and auras for New Life Festival & added icon for new memento version of Breda's Magnificent Mead.
- Updated Dodge Fatigue and Bolt Escape Fatigue auras to use the "unbreakable" border.
- Added new custom icons & fixed aura display for almost all Item Sets in the game (missing VMA and DSA sets currently due to lack of inclusion in PTS containers - will be added in the future). Several new "fake auras" have been added to make certain effects easier to track such as Ilambris or Spawn of Mephala.
- Updated Death Recap to display many of the new icons applied to item sets and abilities.
- Internal cooldown buffs (Phoenix, Eternal Warrior, Immortal Warrior, Soul Summons, Vampire/WW Bite) now use a significantly darkened icon to represent they are on cooldown.
- Added custom icons for several Justice Guard abilities as well as updated the display of various auras. (Hid a bunch of pointless trigger buffs that offered no useful information).
- Added custom icons for Daedric Anchor abilities - Static Charge, Anchor Drop (meteor damage from standing under a dropped NPC), and Power of the Daedra.
- Added custom icons for Champion Point Passives
- Added custom icon for Ayleid Well health bonus

### Chat Announcements

## Version 5.2 (Clockwork City)

###

- Many announcements now send messages to a single printer function on a 50 ms throttle. This function interprets the messages it receives in order to print them in a logical manner. This means when a large number of messages is displayed from for example, a quest being completed, the messages will be displayed in a logical order. In addition this solves the issue where certain components used to cause an annoying scrolling effect as the messages were printed at different ms intervals.
- Added individual options to toggle the display of [] brackets for Character/Account Name Links, Item Links, Lorebook Links, Collectible Links, and Achievement Links.
- Most components now allow you to toggle on/off the display of Chat Announcements, Alerts, or Center Screen Announcements.
- Significantly updated the syntax and display options for most components.
- Hooked MANY functions in the game in order to provide more accurate information for commands and errors sent from ingame menus.
- Shared - Added an option to use a single color for currency and item gain/loss instead of context based color.
- Shared - Updated the syntax for Currency & Loot messages to display more detailed messages.
- Currency - Added in several missing methods of currency acquisition with context messages.
- Currency - Currency Names now use zo_stringformat, allowing you to enter both a singular and plural name for the currency if you wish to change it.
- Currency - Streamlined options to throttle the gain of Alliance Points and Tel Var Stones. Now the throttle timer will be extended if additional currency is acquired instead of always displaying the currency gained a set duration after it is received. In other words: If you continue to earn AP at 3 second intervals with a 5 second throttle set, the currency gained will not print until a lapse of 5 seconds occurs between gaining currency.
- Loot - Updated indexing function to always display accurate information about items received!
- Loot - Fixed various issues with the display of Armor Type, Style, and Trait
- Loot - Updated Group Loot to display either the Character or Account name of the player receiving the item based off your setting.
- Loot - Fixed Group Loot/Notable Loot function to correctly display Green Quality set items looted.
- Loot - Added individual options to show when a Quest Item is Looted or Removed from your inventory.
- Loot - Added individual options to toggle the display of Total Item Count and Total Currency remaining when purchasing an item from a vendor.
- Experience/Skills - Removed several options for cleaner functionality. Updated syntax for experience gain.
- Experience/Skills - Now the throttle timer will be extended if additional experience is earned instead of always displaying the experience earned a set duration after it is received. In other words: If you continue to earn experience at 3 second intervals with a 5 second throttle set, the experience earned will not print until a lapse of 5 seconds occurs between earning experience.
- Experience/Skills - Added option to toggle the display of Enlightenment State change messages.
- Experience/Skills - Added option to toggle the display of Respec Notifications (champion points, attributes, skill points, morphs).
- Experience/Skills - Added option to toggle the display of Skill Points earned and Skyshards absorbed with several options to adjust display.
- Experience/Skills - Added options to toggle the display of Skill Lines Unlocked, Skill Line Progression, and Ability Progression.
- Experience/Skills - Added options to toggle the display of Guild Reputation earned. With various options for color and syntax - and a throttle option for Fighter's Guild reputation earned from kills.
- Collectibles/Lorebooks - Added several new options to Collectibles and Lorebooks display and updated syntax for messages.
- Achievements - Removed several options for cleaner functionality. Added several options and updated syntax for messages.
- Quest/POI - Quest Difficult Icon will now display in Accept/Complete/Abandon messages correctly.
- Quest/POI - Added many new options to toggle the display of various individual quest updates.
- Quest/POI - Added option to toggle the display of Imperial City Sewers area notification messages.
- Social/Guild - Added many new options to toggle the display of various messages.
- Social/Guild - Added option to color guild names and ranks based on Alliance.
- Group/LFG/Trial - Added many new options to toggle the display of various individual LFG or Trial messages.
- Group/LFG/Trial - Messages are now hooked to functions and should no longer display spammy/incorrect information.
- Group/LFG/Trial - Added option to toggle the display of Maelstrom Arena/Dragonstar Arena stage start notifications.
- Group/LFG/Trial - Added option to toggle the display of Maelstrom Arena round notifications.
- Misc Announcements - Added option to toggle the display of Entering/Leaving Group Area notifications.
- Misc Announcements - Updated Mail Notifications to be slightly more basic.
- Misc Announcements - Updated options and syntax for Bag/Bank & Riding Skill Upgrades.

- Removed all old combat text options and damage meter options. Combat Text features moved into Combat Text component.
- Removed old Global Cooldown function to implement new one based off the unused Zenimax GCD function. Added various options.
- Added new Bar Ability highlight options with the ability to add a duration onto the label. This component tracks active abilities or procs.
- Procs triggered when Bar highlight is enabled now play a sound.
- Updated and separated old option to display a Cooldown duration for Potions and Quickslot items. Added options to configure label formatting.

- Combat Text component completed replaced by a modified and updated version of the Combat Cloud addon originally by Sideshow: [Combat Cloud on ESOUI](http://www.esoui.com/downloads/info281-CombatCloud.html#info)
- Adjusted default options for Combat Text to have formatting similar to the default game combat text.
- Combat Text now uses icon and name override tables from LUI buffs & debuffs components.
- Combat Text now hides some un-needed or spammy messages such as resource drain from Sprint and Stealth.
- Fixed an issue from Combat Cloud where the combat state would not be correctly toggled when reloading the UI in combat causing Enter/Leave combat messages to be reversed.
- Fixed an issue where the Potion Ready alert would not trigger due to referencing a function that no longer exists.
- Adjusted text speed for all scrolling methods to be slightly faster and have less overlap. Ellipse method now much faster and more similar to old LUIE style or FTC style combat text.
- Added options to adjust the format for Damage/Critical Damage, Dots/Critical Dots, Healing/Critical Healing, and Hots/Critical Hots individually.
- Added options to override the color for all Critical Damage done, all Critical Healing done, or all incoming damage. This can be used if you want to emulate the way the default game combat text is formatted.
- Notifications to Block/Dodge/Interrupt have been overhauled and replaced with new advanced notifications, allowing you to display a warning displaying the name/icon of the incoming ability as well as the ways it can be mitigated. This option has various customization options for formatting and to choose what ranks of NPC's trigger these alerts.

- Fixed regeneration/degeneration arrow animation!
- Added option to toggle the display of hot/dot animation, power change, and armor change individually for Player/Target, Group, Raid, and Boss frames.
- Power and Armor change overlays now use the animated effects from the default unitframes.
- Added option to change the display method for Champion Points (show above cap or limit to cap). This extends to the default unit frames as well.
- Added individual options to hide the display of the target Title/AVA Rank. Anchored buffs container position will adjust based off whether or not a target has a title/ava rank displayed.
- Added option to color group/raid unit frames by Class Color.
- Added option to display either Class Icon or Role on Raid Frames (one or the other or set a certain way depending on whether the player is in PVE or PVP content).
- Separated transparency and size options for Player/Target bars.
- Added option to hide anchored buffs frames when out of combat (if you choose to set player/target frame to 0 opacity when out of combat you might want to hide the buffs as well).
- Added option to format the label on Raid/Boss frames.
- Added option to configure the transparency of Group/Raid frames.
- Added option to configure the transparency and size of Boss Frames.
- Added option to shift the vertical location of default player frames if repositioning is enabled.
- Fixed an issue where character name was displayed instead of account name for the player when name display method was set to "@UserId" or "Character Name @UserId"
- Fixed an issue causing Default Unit Frames overlay components (Class/Friend Icon and labels) to sharply disappear on target change rather than fading out with the base frame components
- Low Stamina/Magicka will now flash green/blue on the bar instead of red.
- Fixed an issue where sometimes the low resource flash effect would play several times on the stamina bar on player death.
- Fixed an issue where the "Dead" label would clip into the role icon for dead players.

---

## Version 5.1.2 Update (Horns of the Reach)

- Updated API version for Horns of the Reach.
- Buff and debuff icon countdown border now displays based on the FULL duration of the buff rather than only counting down at 8 seconds.
- Temporarily removed function that add news icons to Death Recap until I have a chance to look at the changes to the function from this API update.
- Removed LibAnnoyingUpdate and LibCustomTitles - Don't really see a need for these libraries to be here.

## Version 5.1.1

- Buffs & Debuffs: Fixed bar highlight for the majority of abilities to work correctly again! Note its a long time WIP to significantly enhance what shows here but it requires manual processing of every relevant rank of ability and morph to do so.
- Buffs & Debuffs: Hiding certain buff categories from displaying on the player/target (Mundus, ESO Plus, etc) now works correctly again!
- Buffs & Debuffs: Updated auras & icons for Air Atronach & Kotu Gava, added icons to Death Recap.
- Chat Announcements: Added an option to show the total # of items held when an item is looted (thanks to a new ZOS function).

## Version 5.1

### General Components

- Added posthooks for GetAbilityName and GetAbilityIcon, allowing new LUI ability icons and name corrections to be used by other addons (not fully implemented yet).
- Started custom icon implementation with Death Recap - at the moment only a bit of this is done and only English localization is supported (I have to override specificially by NPC names and skill names), although most of the single player content in Morrowind has been added.
- Updated many passive skill tree icons and racial icons. Now passives for each skill tree have icons that match the relevant style of their active abilities. Please let me know if there are any icons you don't like. Still enhancing a few of them!

### Unit Frames

- Fixed a major issue where Unit Frames disappeared in Battlegrounds when swapping to potions, an issue with Unit Frames disappearing randomly in player houses, and not correctly hiding when in the Housing Editor.
- Fixed an issue where Wardens appears with a white square instead of the proper class icon
- Fixed an issue where players changing role or joining/leaving group would cause the Unit Frames to appear when in another interface tab.
- Fixed an issue where bars had blank space in front of them if Role Icons were toggled on in a battleground.
- Group and Raid Frames now shift if Role Icons are enabled and a player changes their role to none.

### Buffs and Debuffs

- Integrated into default UI components, the Effects Screen will now show the update names and icons of abilities, and hide relevant abilities that provide no useful information. NOTE: Does not hide special category buffs such as Cyrodiil Bonuses or Battle Spirit, these are only hidden from the LUI Buff & Debuff frames if selected.
- Added different border colors for unbreakable/unremovable crowd control effects (haven't had time to expand implementation for this much yet)
- Updated and enhanced many custom icons and did a pass to hide more pointless auras (blue skill placeholder icons). There is still much to do! NOTE: At the moment there are a few placeholder icons present for several effects, I will replace these as soon as I can.
- Implemented Artificial Effect Id's (something ZOS added recently) - The only cases I've seen this used so far is for the Battle Spirt buffs when dueling or in a Battleground).
- Fixed various menu options here to function slightly better
- TEMPORARY ISSUE: Bar highlight for many abilities is currently disabled, I am in the process of switching from a basic abilityName resolving function to using abilityId's for more control of the bar highlight. It will be reimplemented in the future.

### Chat Announcements

- Corrected and updated various strings for consistency.
- Fixed various misc small issues and adjusted timing on some chat printing events. The order of events is far less likely to be out of whack when a large amount of events happen at once.
- Achievements Announcements: Significantly overhauled the options for Achievements Announcements
- Collectible Announcements: Overhauled the options for Collectible Announcements and moved them into a new menu category with Lorebooks.
- Lorebook Announcements: Added option to display Lorebooks Discovered (and Eidetic Memory Books + Crafting Motifs) with many customization options.
- Loot Announcements: Fixed a bug that caused the index to break when items were confiscated by a Guard and the option to print the items confiscated was disabled. Regardless of the options selected, the index should refresh correctly when items are confiscated
- Loot Announcements: Fixed an issue where using Gamepad mode and crafted item announcements would throw a placeholder error string.
- Loot Announcements: Added Subscriber Bank into Loot Announcements. Bank items should all display correctly again now.
- Loot Announcements: When equipping multiple pieces of gear or equipping a set of gear with addons like AlphaGear, LUI is much less likely to erroneously print [Received] notifications in chat. NOTE: This will still happen if you rapidly spam equip/uneqip a piece of gear, I am looking into a solution for this.
- Loot Announcements: Fixed an issue where items added to the craft bag from not-looted sources
- Currency Announcements: Fixed an issue where earning gold from battleground medals earned was displaying a debug message.always displayed as [Looted].
- Group Announcements: Updated group invite messages to correctly work with the changes to this event implemented in Update 14 (It no longer resolves names automatically and only returns what you type when using /invite to invite someone).
- Group Announcements: Updated Group Finder message syntax to correctly display Dungeons and Battlegrounds.
- Group Announcements: Updated methods used for LFG announcements to be more accurate and relevant. Unfortunately the events thrown by the API here are chaotic, I may be able to tune it just a little more in the future.
- Misc: Bag Space Upgrade Announcements: Added an additional check here to prevent these messages from appearing randomly in chat.
- Misc: Mail Announcements: Updated the reset timer on displaying sent mail message info, when the server lags its less likely you should see any duplicate sent messages now.
- Misc: Duel Announcements: Added an option to configure the "Duel Started" message to various formats with the addition of the icon ZOS uses in Update 14.
- Misc: Disguise Announcements: Fixed and updated Center Screen Messages for disguises equipped/unequipped.
- Quest Announcements: Fixed and updated Center Screen Messages for Quests abandoned (this will now display the Icon for quest difficulty if the option is toggled on).

- Hopefully fixed an issue where using a set equipping addon such as AlphaGear would cause [Received] item displays to print out randomly.
- Added "Raid Name Clip" slider in the UnitFrames Options, this allows you to clip the raid frame name manually in order to prevent it from overlapping with the HP display.
- Fixed an issue where removing items from the Guild Bank would occasionally throw UI errors.
- Added a debug message to fix an error where Crafting items with Crafted Loot Announcments on would sometimes throw errors. I'm still attempting to determine the cause of this, please notify me if you receive the error notification.

- Fixed an issue caused by the last hotfix that broke Buffs & Debuffs attaching to the custom unitframes.
- Fixed an issue where Hide TARGET Buffs menu option was missing.

- Fixed an issue causing Tel Var Stone currency announcements to throw UI errors.
- Fixed an issue where the addon did not load correctly for certain people.

---

## Version 5.00

### LUIE Base

- LUIE Chat Printing function has been updated, this option can be turned on to add timestamps to messages or help with compatibility issues with certain addons such as Social Indicators if you are also using pChat.
- Chat Announcements and Buffs & Debuffs now have their own individual menus for easier use.
- Improved functionality of existing commands.
- Error returns from slash commands now also display a ZO Alert and play the generic error sound.
- /regroup and /disband now return errors when attempted in LFG.
- Updated /ginvite command syntax. Now format is /ginvite "#" "name."
- Guild order is now indexed correctly, allowing all /g commands to work properly when guilds are left/joined without having to reload the UI.
- New Command: /ignore "name"
- New Command: /removeignore "name"
- New Command: /friend "name"
- New Command: /removefriend "name"
- New Command: /leave - Leaves current group
- New Command: /kick "name" - Kicks the target player if you are the group leader.
- New Command: /votekick "name" - Initiates a votekick in LFG.
- New Command: /gquit "#" - Quit guild # entered.
- New Command: /gkick "#" "name" - Kicks the target player from guild # if you have permissions to do so.

### Chat Announcements (Updates and Bugfixes)

- Separate many Chat Announcement components into better categories and expanded options.
- Updated and normalized strings for various CA functions to be more consistent, a long with fixing several broken strings.
- Guild Messages now have the correct Alliance Icons.
- Group Finder messages now display correctly for all players whether joining as a full group, partial group, or as an individual.
- Fixed an issue where removing items from the mail could cause UI errors.
- Fixed an issue where moving items around in the guild bank could cause UI errors.
- Fixed several issues with context messages for mail, as well as fixing an error that would cause items to be falsely announced to the player if they attempted to loot and one or more items were unable to be looted due to lack of inventory space.
- Justice confiscation messages reverted to display 1 item per line again - the multiline print from it was causing issues when enough items were removed at once.
- Fixed several issues with currency announcement formatting - most importantly the total value will now correctly separate large numbers with commas (or relevant localization)
- Fixed an issue where purchasing mount riding skill upgrades also printing a bag space upgrade message with both components active.
- Fixed an issue where Achievement details were not displaying correctly in the Achievements component.
- Show destroyed items and show confiscated items now also applies to EQUIPPED items.
- Major update to Loot Announcements - Now looted items will be indexed and printed in a more accurate fashion. This means some odd events that didn't trigger a loot message before such as obtaining a ring of Mara, receiving loot from the Dark Brotherhood Supplier, or purchasing items from the Crown Store will now show a loot message.
- Crafting Loot Announcements has been updated to now show better context specific messages based off the type of crafting you are performing (ex: Researching a item now shows as [Researched]).

### Chat Announcements (New Components)

- Quest Announcements: New category added with options to display quests being accepted/failed/abandoned with various additional options and POI discovery/completion options as well.
- Group, Guild and Social Announcements have been split off from the misc menu and now have several addition sub options.
- Loot Announcements: Added color options for [Context Specific] gain or loss messages for currency announcements.
- Experience Announcements: Added option to show Level Icon if the "Total Level" setting is toggled on for experience gain.
- Experience Announcements: Added option to display enlightened state changes.
- Social Announcements: Added Dueling
- Misc Announcements: Added option to display "Inventory is Full" messages.
- Misc Announcements: Added Pledge of Mara
- Misc Announcements: Added /stuck messages
- Loot Announcements: New option to display when a COLLECTIBLE is unlocked.
- Loot Announcements: Added toggle option to show when a lockpick is broken.
- Loot Announcements: Added a new option to display when a disguise is equipped/unequipped.
- Misc Announcements: Added new component for Disguises that displays a message when you enter/exit a DISGUISE state (entering/exiting the relevant area for the disguise). These messages are context specific based off the disguise.
- Misc Announcements: Added new component for Disguises that displays a warning message and plays an alert sound when the player is near a Sentry NPC or performing suspicious activity.
- NEW THROTTLE OPTIONS: Added a throttle (delays printing of gains) and a threshold option (prevents display of values under a certain value) for Gold/AP/TV gain in Combat to prevent spam.
- Currency Announcements: Added an option to HIDE the display of Guild Trader posting fee gold loss. This is intended as an option for players using AGS (or any other addon that prints a message when an item is purchased from a Trader).
- Group Announcements: Added invididual toggles for Group/LFG messages.

### Buffs and Debuffs

- Added in icons and custom auras for several champion point passive effects that were missing them.
- Removed pointless buff icons that display for ~100 ms from the Magicka and Stamina restore effects that are applied on the player when resurrected by another player.
- Added icon for generic "melee snare" applied by players in PVP. Updated icon for ghost ability "Haunting Spectre."
- Resurrection Immunity icon will now correctly display if the player relogs or reloads UI after dying and then resurrects.
- PVP Support Line "Guard" ability added to the list of effects that display as "T" toggled.
- Stealth icon now has a "T" toggled indicator.
- Fixed broken links to Poison icons, poisons will now display correctly.
- Updated categorical icon display toggle options to now hide icons for the player or target individually.
- Toggle option added to show/hide BLOCK icon.
- Toggle option added to show/hide Recall Cooldown indicator.
- Toggle option added to show/hide Battle Spirit (individually from Cyrodiil buffs)
- Toggle option added to show/hide ESO Plus Member icon
- New toggle added to display DISGUISED state on the player or target.
- Updated icons for Wild Hunt Crates - Momento Rewards and new poisons
- Updated icons for XP Scrolls, Psijic Ambrosia, Mythic Aetherial Ambrosia
- New icon added for Resurrection Immunity & Recall Cooldown
- Added aura for Skyshard Collect and Mundus Stone use.
- Added new toggleable display option for various collectibles - Mount, Non-Combat Pets, Assistants, Polymorphs, Skins, Costumes, and Hats. NOTE: These icons automatically adjust and hide each other when an effect is blocking another. For example wearing a polymorph will hide active Skins, Costumes, and Hats. Pets are automatically hidden in Cyrodiil as well.
- Added new toggleable display for disguise equipped.

### Unit Frames

- Updated code for resizing and positioning, names should now longer clip into icons on the player bar, and the target bar will no longer fail to shorten the name correctly.
- Removed an unnecessary guild indexing function that was being used to display Guild Icons on unitframes (now using a far more lightweight solution). This will likely fix issues with the game hardlocking when running LUIE with Guild Notificators.
- Raid frames now display HP value as well as % HP
- Added toggleable option to display ROLE icon on party / raid frames.
- Added toggleable option to color party / raid frames by ROLE.

## Version 4.99f

### BUGFIXES

- Fixed a major error with the option to turn off the display of stamina/magicka bar labels or bar display. Now these features work as intended.
- Fixed an issue where the party leader name on group frames would clip into the other icons.
- Fixed an annoying issue where weapon and armor trait crafting items, as well as style materials would display their trait/style.
- Fixed an issue where withdrawing crafting materials from the guild bank was throwing UI errors (if you have a craft bag, the materials attempt to go into it).
- Fixed an issue where removing an item from trade with items remaining in a later slot index would try to display the nonexistent item in the slot and throw an error.
- Support added for CraftBagExtended to the Bank and Guild Bank announcements. (Limited support, some display issues when moving items between craft bag and bag during Bank transactions).
- Fixed broken saved variables in LuiExtended.lua that affected the functionality of chat system settings.
- Fixed the Chat Announcements toggle option to hide materials consumed by crafting - now items will be hidden with the option off, and displayed with the option on.
- Something random caused a bag upgrade message to display for no reason with 0 upgrades purchased. I added a check  to make sure the upgrade value is 1 or greater so this erroneous message should never display again.
- Fixed a missing icon for Dwemer Spider "Overcharge" ability.
- Fixed a missing icon for Resurrection Immunity and added a toggle option to show or hide this buff in Spell Cast Buff preferences.
- Updated the ground tracking timer for Spear Shards to be more accurate since the Homestead patch cast time reduction.

### NEW ADDITIONS

### Chat Announcements

- ADDED menu option to show items confiscated by a guard. This feature was implemented but missing the option to toggle it on.
- Items received from deconstructing or items displayed from use when crafting now display in a single line separated by commas to conserve space.
- Additionally, items confiscated by a guard now follow the single line separated by comma's format.
- Added slider to filter out AP gain below X value (0-10000).
- Added slider to filter out XP gain below X value (0-10000).
- Added option to throttle XP from kills by up to 5 seconds.
- Enhanced the XP printout function, now experience gains from Quests that also complete a world POI display both experience sources, with the correct relevant %.
- New toggle option to display an icon for level up messages (normal level icon for normal levels, and relevant champion point for Champion Levels).
- New toggle option to color the level display text based on the context of the level.

### Buffs and Debuffs

- Added option to hide the display of target BUFFS.
- Added option to hide the display of target DEBUFFS.
- Added option to hide the display of GROUND buffs and debuffs.
- Added an option to toggle the glow on ability bar icons on and off for active buffs.
- Added an option to toggle the glow on ability bar icons on and off for active procs.

### Unit Frames

- Replaced quest marker icon for the normal experience bar with normal level icon on UnitFrames.
- Added % HP display to raid frames.
- Adjusted critter HP label from "-critter-" to " - Critter - " -o something about this still bothers me. Any suggestions welcome. I tried making the bar blank but that looked odd as well.
- Added an option to configure the % of HP in which the the enemy HP bar text label turns turn as well as the execute skull displays.

## Version 4.99e

- Sending mail with Gold currency change announcements toggled on, but currency icons off will no longer throw a UI error from attempting to reference an invalid variable.
- Added a description of the SLASH COMMANDS available in LUI to the main Addon settings window.
- Fixed a minor issue where Costume items were being hidden by the Hide Trash chat announcements option.

---

## Version 4.99d

- Fixed a silly oversight that caused groups of items looted from the mail to all share the icon of the first looted item. (Accidentally declared a variable as global instead of local).
- Fixed a double declaration of a variable in SpellCastBuffs.lua (shouldn't have effected anything, but just in case).

---

## Version 4.99c

- Fixed an issue with raid frames where players going offline was throwing UI errors.
- Fixed a minor issue with raid frames that caused player names to clip into the OFFLINE label if present.
- The Unit Frames Champion XP bar now shows the correct value for completion toward the next level.
- Currency Change Reason 32 (AH Refund) now has a proper context message and will no longer display a debug message.
- Lockpick failure message no longer insults you :-D
- Grey quality clothing looted when stealing, as well as disguises looted are no longer considered trash when the filter option for hiding Trash items is toggled on.
- Disguises have been added into the show prominent loot setting.
- Show only prominent items option no longer unintentionally applies to items received in the mail.
- Made some changes to further integrate the mail components with one another - this should hopefully stop UI errors from being thrown occasionally.

---

## Version 4.99b

- Fixed MAJOR issue with debuffs not displaying on the player.
- Added separate Player Buff, Player Debuff, Target Buff, and Target Debuff containers when you toggle the Hard-Lock position to Unit Frames option off. This allows you to have separate buff/debuff frames without using the LUI player & target frames.
- Enhanced Party Frames to update more consistently when party members go offline.
- Added a toggle option under Buffs and Debuffs to turn off the icon display for Sprint/Gallop
- Added a toggle option in Chat Announcements to turn off default string enhancements. This was added as a request due to the lack of other localization support currently. I recommend using this setting otherwise unless you are experiencing some sort of conflict with another addon.
- Added a toggle option to complete turn off the Chat Announcements component.
- Fixed an issue that was causing an error to generate when editing settings in the Chat Announcements loot component.

---

## Version 4.99a

- File size decreased significantly, previously I had accidentally included various GitHub repository files in the directory.
- Fixed an issue with debuffs not refreshing correctly when changing targets.
- Fixed an issue with the /regroup command not displaying names correctly and trying to reinvite before the group was disbanded. (Please let me know if you experience issues with this still!)
- Added a toggle option for social notifications (friend/ignore list messages)

### Overall Changes

- Added new Slash commands: /home, /disband, /regroup, ginvite1,2,3,4,5.
- Updated options for any messages LUI prints to chat. By default messages are no longer printed to system chat by default. This functionality was intended to allow players using pChat to take advantage of pChat's feature to preserve messages in chat between sessions.
- Timestamp now has more options and the color now matches that of pChat.
- Reorganized the folder structure of the addon, as well as updated Addon libraries.

### Combat Info

- Fixed an issue with Ultimate % values not correctly updating outside of combat when swapping weapons.

### Buffs and Debuffs

- Adjusted buffs and debuffs component for the new API changes, now players will only be able to see self applied or pet applied debuffs, as well as major/minor category debuffs.
- Updated Major and Minor debuffs to use the new Zenimax icons added to the game in Homestead [COLOR="RED"]NOTE: if you prefer the old buff icons, you can download an optional patch [URL="[https://puu.sh/ugsXY.zip](https://puu.sh/ugsXY.zip)"]here[/URL]. Extract effects.lua to LuiExtended\modules.[/COLOR]
- Implemented horizontal container orientation for long term effects.
- Updated a number of buffs that display a green highlight on the ability bar while their duration is active.
- Updated the duration of ground tracking effects to be more accurate based on cast time. There is still some work to do here.
- Added a significant amount of new icons for player effects - Potions, poisons, food, experience consumables, momentos, and weapon enchants.
- Added a significant amount of new icons for NPC abilities, as well as updating icons for certain player passives, champion point passives with active components, etc..
- Many placeholder icons used by abilities or NPC abilites have been updated.
- Implemented new "fake" buff tracking to display a buff/debuff for effects that normally do not show one in the base game. This includes the weapon and spell damage weapon enchant procs.
- Utilized new "fake" buff option to make a far more accurate display of Stagger effects on players and NPC's. Now for example, when a heavy attack from an NPC is blocked, the stagger effect should appear to smoothly transition into a stun as the mob staggers backwards.
- Altered a significant amount of NPC abilities and quest based buffs and debuffs to correctly display as a buff or debuff if they were not previously, as well as hid multiple useless debuffs that provided no useful feedback to the player.
- Corrected errors with various ability name inconsistency to provide a more polished experience. Renamed the Ability ID for weapon medium attacks so they now properly display as "Medium Attack."

### Chat Announcements

- Added option to choose method of name display printed to chat for players - Character Name, Display Name, or both.
- Added option to print Group Event messages to chat - Leaving/joining a group, disbanding, queueing, ready checks, votekicks.
- Added option to print Trade Event messages to chat - Trade invitation and success/cancellation.
- Added option to print Mail Event messages to chat - Mail sent, received, or deleted.
- Added option to print Guild notifications to chat - Invites, members leaving, as well as rank changes.
- Added option to display a message when Bag/Bank space upgrades are purchased, as well as Riding Skill Upgrades
- Added option to display a notification when lockpick attempts succeed or fail.
- Added option to display a message when gold or items are confiscated by a guard.
- Expanded option to display currency changes for Gold, AP, Tel Var Stones, and Writ Vouchers with multiple options for customization.
- Multiple options for currency color, method of display, and syntax are available.
- Updated option to display items looted - with the option to filter certain items, as well as show notible items looted by group members.
- Added option to display inventory changes from selling or buying at a vendor or laundering at a fence.
- Added option to display inventory changes from depositing or withdrawing from the bank.
- Added option to display inventory changes from sending and receiving mail.
- Added option to display inventory changes from trading.
- Added option to display inventory changes from crafting items - with an optional setting to show materials that are consumed.
- Added option to display when items are destroyed.
- Added option to display the Armor Type, Trait, and Style of an item.
- New option to MERGE the results of inventory changes with currency changes where applicable.
- Significantly overhauled the experience component - now allows the display of experience gain and levelups. With options for formatting, and the ability to toggle the display of experience gain in combat.

### Unit Frames

- Added the ability to individually control the size of custom Magic and Stamina bar.
- Added the ability to hide the Magicka or Stamina bar labels, or hide the bars entirely.
- Updated the icons on unit frames to be more consistent, as well as replaced the execute skull texture.
- Added option to choose method of name display for player targets - Character Name, Display Name, or both.

---

## Version 4.35

- Buff: Added Magicka Bomb to Debuffs re-adjusted some vMOL debuffs and replaced rending slashes with the actual icon instead of the bleed tick icon.

---

## Version 4.30

- Unit Frames: Fixed smooth transition
- Transition from Veteran ranks to Champion points after 50*
- Buff: Fixed issues with black box on buffs and added vMOL buffs
- Bug fixes

---

## Version 4.14

- Unit Frames: Added option to display shield bar as separate from health
- Unit Frames: Added option to shorten numbers from 12,345 to 12.3k
- Bug fixes

---

## Version 4.13

- Info Panel: added option to disable colouring of FPS/Latency
- Unit Frames: Fixed small misalignment in raid group when having more then 1 column and spacing enabled
- Unit Frames: Added configuration option to set custom transparency when In-Combat

---

## Version 4.12

- Added 13 fonts from Combat Cloud addon; added optional dependency on LMP library to theoretically fetching more fonts from other addons that uses that library. You can select those new fonts in Unit Frames module. No additional fonts for Combat Info module yet
- Lots of various minor and not changes all over the addon code

---

## Version 4.11

- Only API version bump. Everything seems to work without any further changes. Not really tested much though.

---

## Version 4.10

- Buffs: added back timer on Vampire Stage 1-3 buff on player
- Various fixes here and there; typos

---

## Version 4.9

- Buffs: added option to manually select direction of sorted buffs (LtR vs RtL)
- CombatLog: to log incoming debuffs events
- DamageMeter: added logic to count how many actual mobs were damaged

---

## Version 4.8.a

- CombatLog: added option to adjust combat log font size manually

---

## Version 4.8

- CombatInfo: added 'Cleanse Now!' alert
- CombatLog: added more colours to messages and increased font size by 1
- CombatLog: added option to auto-focus corresponding chat tab during combat
- CombatLog: added option to save last 20 messages during logout

---

## Version 4.7

- CombatInfo: changed back the default (for new installations) cloud-like floating text
- CombatInfo: added options to filter out healing and dots events (in- and out-)
- CombatInfo: added more colouring to cloud-like floating labels when damage-dependent colouring option is on
- UnitFrames: fixed smooth target health bar transition on target change

---

## Version 4.6

- Info Panel: fixed IC trophies panel items
- UnitFrames: added smooth transition effect to custom bars (can be disabled in menu)
- Buffs: filtered out *some* effects, that come usually (f.e. boundless storm, volatile armor, combat prayer)

---

## Version 4.5

- Combat Log: (new) added as a part of Damage Meter module.
- Buffs: fixed issue when buffs were disappearing on character death
- Scrolling combat text: added option to drop some events if queue is getting too long
- Info Panel: added 3rd row (off by default) to track IC trophies
- Various minor fixes and optimizations

---

## Version 4.4

- Buffs: re-added option for cooldown UI element on short buffs icons.
- Buffs: added option to select in what format to display remaining numbers ("%.1f" vs "%.2d")
- Various fixes in other modules

---

## Version 4.3

- Buffs: added option to change font on icons
- Buffs: re-implemented option to split players buffs into 2 windows (short/long). The alignment of long buffs as of now fixed to be vertical.

---

## Version 4.2-beta

- Damage meter: added abilities icons into full damage details window
- Buffs: re-added manual tracking of effects whose information is not provided by API (Negate, Liquid Lighting, Runes, etc).
- Known issue: manual tracking of ground-targeted skills from time to time wrongly triggers creation of custom buff icon when the use of the skill was canceled

---

## Version 4.1-beta

- Various fixes in all modules
- Buffs: First part of reworked Buffs/Effects tracking. Some work is still required

---

## Version 4.0-beta

- Updated all modules for new ESO API
- Combat Info: updated scrolling text to include more skill names.
- Buffs/Debuffs: currently being refactored to work better with new API. Most of the core functionality is present, but it requires more patching and testing.

---

## Version 3.10

- Custom Unit Frames: added another target frame which will display only PvP targets
- Combat Info: tweaked a little existing cloud-like floating labels
- Combat Info: added completely new scrolling text labels. You can switch between existing and new ones, or you can have both of them (though a bit unpractical)

---

## Version 3.9

- Long-term buffs: added option to enable buff icons only for player and not for target
- Custom Unit Frames: Player and Target bars width can be controlled independently
- Custom Unit Frames: Added label to display current anchored position of frames when they are unlocked.

---

## Version 3.8

- Default Unit Frames Extender: added option to change overlay labels colour
- Ultimate Generation Tracking was moved to Combat Info module. Not it will display glowing texture under Ultimate skill button

---

## Version 3.7

- Fixed Achievement reporting on French clients
- Changed icons on Damage Meter mini panel
- Added option to force ChampionXP display for v1-v13 characters

---

## Version 3.6

- Damage Meter: added graph plot feature
- Fixed several minor bugs

---

## Version 3.5

- Long-term effects: added Crystal Fragment Proc to ignored buffs. Now this effect is tracked only in Short-term buffs module
- Chat Announcement: added achievement tracking routines (disabled by default)

---

## Version 3.4

- Custom Unit Frames: added option for shield bar to be full-height instead of default half-height one
- Custom Unit Frames: added option for target frame to show large skull texture when target should be executed (enabled by default)
- Short-term buffs: Stealth custom buff icon is now optional and can be disabled via settings menu

---

## Version 3.3

- Default Unit Frames: changed default font to be consistent with other default UI elements; added options to customize this font
- Default Unit Frames: added Friend/Ignore/Guild icon to default UI small group frames
- Custom Unit Frames: changed left label on target control for critter units. Now it will read as "-critter-" instead of default "9 / 9" health values. Right label will be hidden for critters

---

## Version 3.2

- Unit Frames: Friend/Ignore icon is now Friend/Ignore/Guild, i.e. it will track now if player is if one of your guilds
- Unit Frames: this Friend/Ignore/Guild was added to Custom Small Group frames and Default Target frame to the right of unit name
- Custom Unit Frames: changed position of Leader icon on Custom Small Group frames
- Custom Unit Frames: added options NOT to sort raid size group alphabetically and to add small vertical spacers for every 4 raid members. This way the ordering and grouping of members *should* correspond to default UI one, though it was not well tested
- Combat Info: added EXPERIMENTAL option to Throttle (group similar) damage and heals events

---

## Version 3.1

- Custom Unit Frames: revised group update code to solve (hopefully) short freezes during raids
- Damage Meter: changed mini-panel default backdrop texture
- Damage Meter: added option to make it completely transparent
- Damage Meter: added option to hide combat time label and have only 3 other visible

---

## Version 3.0

- Custom Unit Frames: fixed issue with experience bar for vr1-vr13 players (I hope so)
- Custom Unit Frames: added IsFriend/IsIgnored icon to target frame
- Short-term buffs: added option to change alignment of icons within holding container
- Prints to chat information on Looted items, Gold and XP changes, Group events.

---

## Version 2.15

- Short-term buffs: updated code for spell activation detection. This should help with ground-targeted spells.
- Custom Unit Frames:
- - Added separate options to display experience bar and Mount/Siege/WW
- - Added option to set colour of ChampionXP bar according to champion point being earned; changed textures of champion point.
- - Size of this alternative bar will now scale with size of the font used

---

## Version 2.14

- Info Panel: added option to change panel scale. This should help on screens with large resolution
- Short-term buffs: rewritten potion tracking algorithms, added passive skill effects tracking
- Short-term buffs: added code to remove 'Mines' target debuff on first activation. This relates to Fire Rune and Daedric Mines

---

## Version 2.13

- Combat Info: rewritten UI part of module. Now different floating text areas are unlockable and movable
- Ultimate Tracking: added option not to hide %% value when > 100%
- Info Panel: added option to toggle information parts to display
- Short-term buffs: added custom "stealth" buff icon

---

## Version 2.12

- Unit Frames: Increased maximum font and sizes of frames, optimized layout for extra large sizes
- Unit Frames: Experience alternative bar will show ChampionXP only for level cap players. For vr1-vr13 it will continue to show your veteran rank progress
- Combat Info: Experience floating text will take account Enlightened buff for vr14 players, i.e. the numbers displayed will relate to ChampionXP instead of raw one
- Long-term effects: added option to hide Cyrodiil buffs
- Short-term buffs: added "toggle" texture for skills: Surge, Momentum and Entropy

---

## Version 2.11

- Unit Frames: Fixed issue that prevented frames to be unlocked for moving
- Ultimate Tracking is merged into Combat Info module
- Damage Meter: Finally completed code to display full damage statistics. Credits goes to FTC: in my version just the layout is a bit different; the code co collect statistics is almost identical to FTC one. To display statistics you can setup key binding or click on fight time label on damage meter mini panel

---

## Version 2.10

- Short-term buffs: Added (optional) in-combat ultimate gain icon
- Combat Info: Added (optional) floating text for interruption and stunned effects as well as miss and reflected events

---

## Version 2.9

- Added Bosses encounter separate frames. When you are in dungeon and near Boss zone, new frame will appear and show current status of up to 6 bosses as thought by game API

---

## Version 2.8

- Added option to display target players class as a text label (disabled by default)
- Added feature to blink player power bars when you are out of power
- Optimized inventory lookup code in Info Panel, so it safely ignores game flooding of evens when you are caught stealing by the guard
- Adjusted a little timing settings for small floating labels in Combat Info module

---

## Version 2.7a

- Added option to enable each component in default and custom frames independently of each other
- Added new option for name colouring for Friendly Players targets
- Fixed bug introduced in previous release
- Added Proc animation over ActionBar slot for Crystal Fragments passive

---

## Version 2.6

- Added options to change all sizes of player and target custom frames
- Many bugfixes and improvements

---

## Version 2.5

- Added option to disable alternative bar on player custom frame
- Added options to change all sizes on group and raid custom frames
- Adjusted the way visuals are displayed on player and target frames
- Many bugs were fixed and a lot of code optimized

---

## Version 2.4

- Added option to disable default target frames when default unit frames extender is not used
- Added option to exclude yourself from small group custom frames
- Added new visuals for increased/decreased armor and increased power on player and target frames (optional)

---

## Version 2.3

- Bug fixes to previous release
- Added option to disable default player frames when default unit frames extender is not used
- Added Small Group Custom frames.

---

## Version 2.2 - new Unit Frames

### Combat Info

- added option to select font sizes for scrolling text
- changed routing for outgoing healing
- added option to colour outgoing damage according to damage type
- Contains previous Default Unit Frames Externder module
- Provides new Custom Frames for Player, Target, (Raid)Group
- Allows to lock position of short-term buffs and debuffs to corresponding unit frames

---

## Version 2.1

- Added option to select between 3 font families for floating combat text
- Added display of attributes drained/energized events
- Minor fixes to buff tracking modules

---

## Version 2.0

- API version bump 100011
- Dropped CrystalFragmentProc module, as now API provides needed info
- Rewritten Short-term buffs module is the same way as FTC was modified
- Default Unit Frames module now put commas into long numbers
- Updates to colouring of reticle.

---

## Version 1.19 - pre Update 6

- Updated LAM to r17
- Added compatibility code to mount feed timer, so it does not give error on PTS
- Added new manual "Recall" long term effect timer
- In CombatInfo module: the previously queued areas now display numbers as they appear in game events

---

## Version 1.18

- Added combat status "In/Out Of Combat" alert (disabled by default)
- Bug fixes in Default Unit Frames module, related to group member shields

---

## Version 1.17

- Added option to disable all icons in Combat Info module
- Code cleanup in some other modules

---

## Version 1.16

- Added more combat tips alerts, rewritten corresponding settings menu
- Added weapon charges tracking into Info Panel

---

## Version 1.15

- Fixes for previous release
- Added option to menu to actually switch on and off Combat Tips alerts
- Changed default font for Combat Alerts

---

## Version 1.14

- NEW: Alerts for active combat tips in Combat Info module
- NEW: Group Members class icons in Default Unit Frames extender module

---

## Version 1.13

- NEW: Damage Meter is enabled by default now
- Player class now properly position without gap left to target level
- More missing icons for synergies and weapon enchantments

---

## Version 1.12

- NEW: Displays player class icon for current target
- More missing icons for sorc pets and lightning staff

---

## Version 1.11

- Added some missing icons for floating text damage in Combat Info module
- Added option to change color of reticle according to target reaction in Default Unit Frames module

---

## Version 1.10

- Default Unit Frames module now displays health and shield numerical values for small group members

---

## Version 1.9.2

- Minor tweaks to Combat Info Module
- Again commented out Damage Meter.

---

## Version 1.9.1

- Updated to add more options to Default Unit Frames module

---

## Version 1.9

- NEW: Default Unit Frames Extender module
- NEW: Long-term Effects Tracker
- Minor updater here and there

---

## Version 1.8

- Added tracking of used potions into Shot-Time Buffs module
- Rewritten localization module. Full localization for German and French game clients

---

## Version 1.7

- More customization of how short-time buffs looks
- Adjustments to Combat Info module, so floating text will be more spread on screen

---

## Version 1.6

- Reworked settings menu
- NEW: (optional) Fadeout expiring buffs icons (disabled by default)
- Minor bug fixes here and there

---

## Version 1.5a

- Info Panel can be unlocked via settings and moved to desired position on screen

---

## Version 1.5

- NEW: Prints to chat name of player who has joined and left your group
- Added vampire feeding 5.5-seconds buff icon

---

## Version 1.4

- Added routines to create 10-seconds Resurrection Immunity buff on player when the soul gem is used to revive
- Some adjustments to spells timing table

---

## Version 1.3

- Code optimization in InfoPanel
- Added proper icon to UltimateReady alert
- Added several missing translations of spells

---

## Version 1.2

- Partial localization. Though some of the abilities names are still missing
- New feature: low health/magicka/stamina alert
- Proper handling of Burning effect from EVENT_COMBAT_EVENT to display 4-seconds debuff on target
- Code optimization

---

## Version 1.1

- Proper handling of ground targeted abilities
- Removal of shield short-time buffs when shield disappears before expiration time
- Removal of buffs and debuffs when player or target dies

---

## Version 1.0

- Initial release
