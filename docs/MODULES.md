# LuiExtended modules and features

LuiExtended is a bundle of optional **modules**. Each module can be enabled or disabled under **LuiExtended → Module Settings** (Misc). Most modules have their own settings panel and slash shortcut on PC (see [README.md](README.md#settings-shortcuts-pc-keyboard-ui)).

**Required add-ons:** [LuiMedia](https://www.esoui.com/downloads/info1654-LuiMedia.html) (fonts, sounds, status bar textures, custom ability icons) and [LuiData](https://www.esoui.com/downloads/info1660-LuiData.html) (effect overrides, ability alert definitions, crowd control data, companion slash names, and related tables).

**Platforms:** PC (keyboard/mouse) uses **LibAddonMenu-2.0** for settings. Console (gamepad) uses **LibHarvensAddonSettings** and **LibConsoleDialogs**. Some features are PC-only (in-game changelog, parts of MiniMap workflow); note your platform when reporting bugs.

---

## Core (Miscellaneous settings)

Shared behavior that is not tied to a single gameplay module.

| Area | What it does |
| --- | --- |
| **SavedVariables profiles** | Account-wide settings by default; optional per-character profiles, copy between characters/accounts/megaservers, reset character or account defaults. |
| **Changelog** | PC: version welcome window and collapsible in-game changelog (`Display Changelog` in settings). |
| **Chat output** | Routes LUIE chat lines to selected tabs, optional timestamps, integration with LibChatMessage / pChat formatting when those add-ons are present. |
| **Default UI unlock** | Move quest log, battleground score, loot history, and equipment status windows. |
| **Grid overlay** | Snap-to-grid helpers while moving LUIE frames (unit frames, buff frames, etc.). |
| **Compatibility** | Hide experience/skill progress pop-up; optionally unregister vanilla buff/debuff UI when LUIE buff frames are hidden. |
| **Custom icons** | Use LuiMedia custom ability icons instead of stock art (affects alerts, buffs, and other icon surfaces). |
| **Missing base game settings** | Exposes a few CVars not shown in the stock UI (advanced; may affect performance). |
| **Debug** | `/luie debug` isolates LUIE on an allowlist for troubleshooting; `/luie svstatus` for SavedVariables migration info. |

**Useful feedback:** profile copy mistakes after reload, changelog or welcome version behavior, chat tab routing, grid snap issues, conflicts with other UI add-ons when suppressing ZOS buff/debuff UI.

---

## Unit Frames

Custom and enhanced unit frames for combat UI.

| Area | What it does |
| --- | --- |
| **Custom frames** | Player, target, small group, raid, boss, pet, companion, and PvP/AvA layouts with fonts, textures, colors, and positions. |
| **Default frames** | Text and bar options on stock ZOS unit frames; optional extenders. |
| **Group integrations** | Optional **LibGroupResources**, **LibGroupCombatStats**, and **LibGroupPotionCooldowns** display on group/raid frames when those libraries are installed. |
| **Group food and drink buffs** | Food/drink status icons on **small group** frames (4-player group), not raid frames. Settings under Unit Frames; `/luiefoodbuff` refreshes icons when enabled. |
| **Group extras** | Companion ability track, rapport flourish, election info, and related group UI. |
| **Quick Hide Dead** | Hide dead units on selected frame types (player-facing copy describes behavior without internal API names). |

**Useful feedback:** wrong health/power display, misaligned raid/group layouts, role icons/colors, LibGroup* integration, preview/debug commands (`/luiuf*`), performance in large raids.

---

## Action Bar

Action bar overlays and timing UI (settings: **Action Bar** module).

| Area | What it does |
| --- | --- |
| **Global cooldown** | GCD display on bars. |
| **Ultimate** | Player ultimate value/presentation; companion ultimate tracking. |
| **Back bar** | Secondary bar ability tracking. |
| **Bar highlight** | Tracks slotted abilities and proc/effect state on bars (pairs with Combat Info / LuiData). |
| **Quickslot** | Potion and quickslot cooldown timers. |
| **Cast bar** | Cast/channel bar for abilities and many interaction casts (wayshrine, boons, item interactions, etc.). |

**Useful feedback:** incorrect proc/highlight state, cast bar stuck or missing for a specific interaction, ultimate/companion ultimate desync, GCD or potion timer wrong after bar swap.

---

## Buffs and Debuffs (SpellCastBuffs)

Player/target (and related) buff and debuff icons driven by **LuiData** effect tables.

| Area | What it does |
| --- | --- |
| **Layout** | Anchored or free-floating frames, sorting, long-term vs short-term filters, prominent and priority lists, blacklists. |
| **Presentation** | Icons, colors (including CC/unbreakable/cosmetic), tooltips, normalization options. |
| **Ground / target effects** | Prominent containers for ground-targeted and priority effects. |

**Not shipped:** SpellCastBuffs **group buff/debuff tracking** on party members was removed years ago (use a dedicated group buff add-on such as **Group Buff Panels** by code65536). Archived implementation notes live under `.meta/TODO/_GroupBuffs.lua.txt` only; some locale strings remain but there is no in-game UI or logic.

**Useful feedback:** missing or duplicate icons, wrong duration/stack display, prominent/priority list behavior, conflicts with other buff trackers; include ability ID for LuiData effect fixes.

---

## Combat Info

Combat awareness: alerts, CC tracking, and markers (settings: **Combat Info**).

| Area | What it does |
| --- | --- |
| **Active combat alerts** | Incoming enemy ability alerts with optional mitigation hints, cast timers, sounds, and CC-colored borders (data from **LuiData** AlertTable). |
| **Crowd control tracker** | CC and many AOE ground alerts, immune state, stagger text, PvP-only modes, `/luiecc` preview. |
| **Floating markers** | Red arrow over enemies you are fighting. |
| **Bar highlight** | Shared logic with Action Bar for what appears on ability slots. |
| **Stock alert frame** | Option to hide ZOS top-right combat alerts when using LUIE alerts. |

**Useful feedback:** spam or missing alerts, wrong timing, incorrect mitigation label, CC tracker false positives in AOE, bar highlight not matching actual buff/debuff state, icon art quality for NPC abilities.

---

## Combat Text

Floating combat feedback (derived from **Combat Cloud**; settings: **Combat Text**).

| Area | What it does |
| --- | --- |
| **Damage and healing** | Incoming/outgoing numbers, colors, crit styling, throttling. |
| **Resources** | Magicka/stamina/ultimate gain and drain, low resource warnings. |
| **Mitigation and CC** | Block/dodge/avoid messaging, crowd control notifications. |
| **Death and alerts** | Group death notices, ability alert text tied to combat info options. |
| **Blacklist** | Suppress text for selected abilities. |

**Useful feedback:** throttle merging wrong hits, missing crits, overlapping panels, incorrect damage type colors, performance in large fights.

---

## Chat Announcements

Replace or supplement center-screen announcements with chat lines (settings: **Chat Announcements**).

Major categories (each has many sub-toggles):

- **Loot and inventory** (pickup, destroy, mail, bank, guild bank, fence, craft, etc.)
- **Currency** (gold, tel var, writ vouchers, event tokens, context messages)
- **Experience and progression** (XP, level up, skill lines, skill points, enlightenment, guild rep, companion level)
- **Quests and POI** (objectives, share, abandon, quest kill counter filters)
- **Achievements, antiquities, collectibles, lorebooks**
- **Display** (zone, dungeon, arena, misc, event zones such as Night Market)
- **Social and guild** (friends/ignore, guild rank, invites, trade, duels, Mara, LFG/group/raid)
- **Slash validation** (`/home`, `/campaign`, outfit equip, campaign queue, social errors)
- **Misc** (attunable stations, challenge difficulty, and other one-off hooks)

Also controls **chat tab routing** per message type and shares the core **Chat output** options with other modules.

**Useful feedback:** wrong item name or quantity, message format errors, a toggle that does not apply, duplicate lines with other add-ons (LootLog, writ add-ons, etc.), tab routing mistakes.

---

## Info Panel

Compact HUD readout (settings: **Info Panel**): latency, FPS, clock, zone, durability/weapon charge, and other optional elements; unlockable position.

**Useful feedback:** stale values, overlap with other HUD add-ons, gamepad vs keyboard layout.

---

## Slash Commands

Quality-of-life chat commands (settings: **Slash Commands**). Full list: [README.md slash commands](README.md#slash-commands).

**Useful feedback:** command not registering after toggle (remember `/reloadui`), permission errors on guild commands, companion or assistant summon wrong NPC, conflicts with other slash add-ons.

---

## MiniMap (BETA)

Optional HUD minimap (default **off**; enable in Misc module list, then **MiniMap** settings). PC: `/luimm` opens settings. Requires UI reload when enabling the module.

| Area | What it does |
| --- | --- |
| **Map frame** | Zoom, pin scale, follow player, lock position/size, visibility in HUD/combat/loot/menus. |
| **Input** | Waypoint on click vs Shift+click; zoom buttons. |
| **Pins** | Quest, group, and world pins with configurable refresh rates (advanced). |
| **Integration** | HUD scene visibility with other LUIE chrome; optional Info Panel hooks. |

**Policy:** MiniMap remains beta; avoid putting MiniMap changes in public release changelog bullets unless explicitly approved for release notes.

**Useful feedback:** pin drift, performance cost, wrong hide/show with menus or combat, gamepad navigation, waypoint behavior.

---

## LuiData (companion add-on)

Ships in the same repository; version pinned in `## DependsOn`. Holds large data tables (effects, alerts, crowd control, slash command companion names, etc.). Many LUIE bug reports are fixed by updating **LuiData** ability IDs or flags rather than UI code.

**Useful feedback:** include ability ID, icon name, and whether the issue is alert vs buff vs chat so LuiData tables can be updated.

---

## Optional add-on integrations

LuiExtended detects these when present (see manifest `## OptionalDependsOn`):

| Add-on | Typical use |
| --- | --- |
| **LibSlashCommander** | Autocomplete for LUIE slash commands (PC). |
| **LibChatMessage / pChat** | Chat formatting and timestamps for LUIE output. |
| **LibDebugLogger / DebugLogViewer** | Structured logging. |
| **LibGroupResources / LibGroupCombatStats / LibGroupPotionCooldowns** | Group frame overlays. |
| **CombatMetrics, CrutchAlerts, LibCombat, LibCombat2, Taneth** | Combat ecosystem hooks where implemented. |
| **LootLog** | Loot-related chat behavior coordination. |
| **DolgubonsLazyWritCreator / LibLazyCrafting** | Crafting/writ chat or UI coordination. |

Mention integrated add-ons and versions when reporting cross-add-on bugs.
