# How to help test and report issues

Thank you for helping improve LuiExtended. This page explains where to send feedback and what details help most.

## Where to report

| Channel | Use for |
| --- | --- |
| [GitHub Issues](https://github.com/DakJaniels/LuiExtended/issues) | Bugs and reproducible problems (preferred for tracking). |
| [GitHub Discussions](https://github.com/DakJaniels/LuiExtended/discussions) | Design questions, broad feedback, or ideas that are not yet a bug report. |
| [ESOUI comments](https://www.esoui.com/downloads/info818-LuiExtended.html#comments) | General discussion and release reactions. |
| [GitHub Releases](https://github.com/DakJaniels/LuiExtended/releases) | Pre-release/beta builds when announced. |
| [dakjaniels@outlook.com](mailto:dakjaniels@outlook.com) | Private or sensitive reports if needed. |

## Before you file an issue

1. Note **LuiExtended version** and **AddOnVersion** (addon manifest or `/script`).
2. State **PC vs console** and **client language** (en, de, fr, ru, zh for Simplified Chinese, tr, …).
3. List **other add-ons** that touch the same UI (buff trackers, unit frames, combat text, loot chat, LibGroup*, etc.).
4. Confirm **LuiMedia** and **LuiData** versions meet the manifest minimums and are enabled.
5. Say which **module** is involved (Unit Frames, Combat Info, Chat Announcements, …). See [MODULES.md](MODULES.md) for a full map.
6. For ability/icon/alert issues, include **ability ID**, zone/boss name, and language if not English UI.
7. Attach **screenshots** or **Lua errors** from `/scriptui` when relevant.

Use the GitHub **bug report** template when opening a new issue; it matches the checklist above.

## What to test and report (by area)

The addon does far more than the short list below; [MODULES.md](MODULES.md) describes every module. These are the areas where detailed reports help most.

### Localization

See [LOCALIZATION.md](LOCALIZATION.md). Report missing keys, wrong grammar, overflow in settings UI, or untranslated strings (compare to `lang/*/default.lua`).

### Unit Frames

Layout breaks in raid vs group, wrong role colors/icons, LibGroup* overlays, **group food/drink buff icons** (small group frames only), companion/pet/boss frames, Quick Hide Dead behavior, and performance with many units.

### Action Bar

Cast bar for abilities or interactions, ultimate/companion ultimate display, back bar tracking, GCD/potion timers, bar highlight mismatches.

### Buffs and Debuffs

Missing/extra icons, prominent/priority lists, duration/stack errors, tooltip wrongness, and custom icon preference. Include the **ability ID** in GitHub issues when you can (`/script` or combat log). LUIE does **not** ship party-wide group buff tracking (see [MODULES.md](MODULES.md#buffs-and-debuffs-spellcastbuffs)).

### Combat Info

**Bar highlight:** effect fades early, never appears, or confusing proc choice when one skill has many effects.

**Active combat alerts:** spam, late/early alerts, wrong mitigation text, missing boss mechanics, bad custom icon for an NPC ability.

**Crowd control tracker:** false AOE alerts, immune/stagger display, PvP-only filter behavior, `/luiecc` preview vs live combat.

### Combat Text

Throttling, crit handling, panel overlap, wrong colors, blacklist not applied, low resource warnings.

### Chat Announcements

Wrong item/currency text, duplicate messages with LootLog or similar, toggles that do not apply, tab routing sending messages to the wrong chat tab.

### Info Panel and Slash Commands

Stale stats, HUD overlap, slash command not working after toggle (did you `/reloadui`?), guild/home/campaign command edge cases.

### MiniMap (BETA)

Only when you intentionally enable the module: pin accuracy, FPS impact, visibility with menus/combat, waypoint clicks, console vs PC. MiniMap may be omitted from public release notes unless explicitly called out for a release.

### Core / Misc

Profile copy between characters, changelog welcome window, chat output tabs, grid overlay snap, suppress vanilla buff/debuff option conflicting with other UI.

### LuiData

If alerts, buff icons, or CC types are wrong for one ability but UI settings look correct, mention **LuiData** version and ability ID so table updates can be tracked separately from LUIE code.

## Feature requests

Open a **feature request** issue on GitHub. Describe the problem, proposed behavior, which module it belongs to, and whether it affects PC, console, or both.

## Translations and code contributions

- Translations: [LOCALIZATION.md](LOCALIZATION.md), pull requests to `master`.
- Code: [MIT License](https://github.com/DakJaniels/LuiExtended/blob/master/LICENSE), respect sections noted as borrowed from other add-ons; see [CONTRIBUTORS.md](CONTRIBUTORS.md) and the PR template checklist (changelog files for user-facing changes).
