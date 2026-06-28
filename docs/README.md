# LuiExtended [![Current Release](https://img.shields.io/github/release/DakJaniels/LuiExtended.svg)](https://github.com/DakJaniels/LuiExtended/releases) [![GitHub license](https://img.shields.io/github/license/DakJaniels/LuiExtended.svg)](https://github.com/DakJaniels/LuiExtended/blob/master/LICENSE)

LuiExtended is an AddOn that adds multiple custom components including

- **Unit Frames** Custom frames for player, target, group, raid, bosses, pets, and companion; default frame extenders; optional AvA layouts.
- **Info Panel** FPS, latency, clock, zone name, and optional memory readout on a compact HUD panel.
- **Action Bar** Cast bar, ultimate and companion ultimate display, backbar row, and bar highlight tracking (see Combat Info).
- **Buff and Debuff Tracking** Custom buff and debuff icons with manual effect overrides (LuiData).
- **Chat Announcements** Currency, loot, achievements, experience, social events, guild invites, quests, and more in chat.
- **Combat Info** GCD, quickslot cooldown, ability alerts, crowd control tracker, and related combat HUD tools.
- **Combat Text** Outgoing and incoming damage and healing, warnings, throttling, and resource gain display.
- **Slash Commands** Home travel, group tools, guild and social shortcuts, assistants, and settings shortcuts. See [Slash commands](#slash-commands) below.
- **MiniMap (BETA)** Optional HUD minimap (`/luimm` on PC). Enable under Misc Settings; requires UI reload.

Initially this [Elder Scrolls Online][1] AddOn was based partially on the [LUI][2] AddOn by LoPony and some features of [Foundry Tactical Combat][3] AddOn.

## Install and requirements

Install **LuiMedia**, **LuiData**, and **LuiExtended** from ESOUI (or this repo) and enable all three. PC also needs **LibAddonMenu-2.0**; console needs **LibHarvensAddonSettings** and **LibConsoleDialogs**. Version minimums are in `LuiExtended.addon` (`## DependsOn` / `## ConsoleDependsOn`).

Each major feature is a **module** you can toggle under LuiExtended settings. For a full breakdown (integrations, beta MiniMap, LuiData relationship, and what to test), see [MODULES.md](MODULES.md). To report bugs or help test, see [HOWTOHELP.md](HOWTOHELP.md). Translators see [LOCALIZATION.md](LOCALIZATION.md).

## Information

Buff, debuff, alert, and crowd-control **data** live in **LuiData** (`Effects`, `AlertTable`, `CrowdControl`, and related tables). Wrong icons, missing alerts, or bad effect tracking for a specific ability are often fixed there: open a [GitHub issue](https://github.com/DakJaniels/LuiExtended/issues) with the **ability ID**, module (buffs, Combat Info, etc.), and steps to reproduce. See [HOWTOHELP.md](HOWTOHELP.md) and [MODULES.md](MODULES.md).

## Slash commands

LuiExtended registers many chat slash commands. Unless noted, commands below belong to the **Slash Commands** module.

### Setup

- Enable **Slash Commands Module** in LuiExtended settings.
- Turn individual commands on or off under **LuiExtended → Slash Commands**. Run **`/reloadui`** after changing those toggles.
- Most commands are enabled by default. **`/guildkick` and `/guildquit` (and their aliases) are off by default.**
- On PC, optional **LibSlashCommander** adds autocomplete and descriptions without changing behavior.
- **`/bank`**, **`/merchant`**, **`/armory`**, **`/decon`**, and **`/companion`** summon or use the assistant or companion you pick in Slash Commands settings.

### Always registered (Slash Commands module enabled)

These register whenever the module is on; they are not controlled by the per-command toggles.

- **`/kick`** *name* — Remove a group member (LuiExtended handler; does not replace the `/kick` emote).
- **`/invite`** *name* — Invite a player to your group.
- **`/readycheck`** — Start a group ready check (same handler as `/ready` when that toggle is on).

### General

- **`/trade`** *name* — Invite a player to trade.
- **`/home`** [`inside` | `outside`] — Travel to your primary home. Use `inside` or `outside` for a specific entrance, or rely on the default chosen in settings.
- **`/setprimaryhome`** — Set your current home as primary.
- **`/campaign`** *name* — Queue for a campaign by name (home or guest campaign only).
- **`/outfit`** *1–10* — Equip the outfit in that slot.
- **`/report`** *name* — Open the report-player dialog for that name.

### Group

- **`/regroup`** — Save the party, disband, and reinvite members after a short delay.
- **`/disband`** — Disband the group (leader only).
- **`/leave`** — Leave the group. Aliases: `/leavegroup`.
- **`/remove`** *name* — Remove a member from the group (leader, non-LFG). Aliases: `/groupkick`, `/groupremove`.
- **`/changerole`** `tank` | `heal` | `dps` — Change your LFG role.
- **`/votekick`** *name* — Vote to remove a member in an LFG group. Aliases: `/voteremove`.
- **`/ready`** — Send a ready check to the group (toggleable; same handler as `/readycheck`).

### Guild

Guild slot `#` is the order shown in your Guild menu (1 = first guild, and so on).

- **`/guildinvite`** *#* *name* — Invite a player to a guild. Alias: `/ginvite`.
- **`/guildkick`** *#* *name* — Remove a player from a guild (with permission). Alias: `/gkick`. Off by default.
- **`/guildquit`** *#* — Leave a guild. Aliases: `/gquit`, `/guildleave`, `/gleave`. Off by default.

### Social

- **`/friend`** *name* — Send a friend invite. Alias: `/addfriend`.
- **`/ignore`** *name* — Add a player to ignored. Alias: `/addignore`.
- **`/unfriend`** *name* — Remove a friend. Alias: `/removefriend`.
- **`/unignore`** *name* — Remove from ignored. Alias: `/removeignore`.

### Companions and assistants

- **`/companion`** [*name*] — Summon your default companion from settings, or a companion by name if unlocked.
- Per-companion shortcuts — One command per companion in LuiData (lowercase short name), for example: `/bastian`, `/mirri`, `/ember`, `/isobel`, `/sharp-as-night`, `/azandar`, `/tanlorin`, `/zerith-var`. New companions added in LuiData get matching slashes automatically.
- **`/bank`**, **`/banker`** — Summon your selected banker.
- **`/sell`**, **`/merchant`**, **`/vendor`** — Summon your selected merchant.
- **`/fence`**, **`/smuggler`** — Summon your fence assistant.
- **`/armory`** — Summon your selected armory assistant.
- **`/decon`**, **`/deconstruction`** — Summon your selected deconstruction assistant.
- **`/eye`** — Use the Antiquarian's Eye (dig site, if unlocked).
- **`/pet`**, **`/pets`**, **`/dismisspet`**, **`/dismisspets`** — Dismiss active vanity pets.

### Holiday mementos

- **`/cake`**, **`/jubilee`** — Anniversary Jubilee cake XP memento.
- **`/pie`**, **`/jester`** — Jester's Festival pie XP memento.
- **`/mead`**, **`/newlife`** — New Life Festival mead XP memento.
- **`/witch`**, **`/witchfest`** — Witches Festival memento.

### Settings shortcuts (PC keyboard UI)

Registered with LibAddonMenu when you use the PC settings UI. With LibSlashCommander, these get shared autocomplete descriptions.

- **`/luiset`** — LuiExtended main settings
- **`/luisc`** — Slash Commands settings
- **`/luiuf`** — Unit Frames settings
- **`/luiab`** — Action Bar settings
- **`/luiscb`** — Buffs and debuffs settings
- **`/luica`** — Chat Announcements settings
- **`/luici`** — Combat Info settings
- **`/luict`** — Combat Text settings
- **`/luiip`** — Info Panel settings
- **`/luimm`** — MiniMap settings (when the module is enabled)

### Other LUIE utilities

- **`/rl`** — Reload UI (`/ingame`), registered only if no other addon already uses `/rl`.
- **`/luie`** — Developer and diagnostics entry point:
  - **`/luie svstatus`** — Print SavedVariables migration status.
  - **`/luie debug`** `on` | `off` | `status` — Toggle or inspect the LuiExtended debug environment (may reload UI).
- **`/luiecc`** — Preview Crowd Control tracker icons (Combat Info).
- **`/luiefoodbuff`** — Refresh group food and drink buff icons on unit frames (when that feature is enabled).

### Developer and diagnostics (advanced)

Support and development tools; not needed for normal play.

#### Unit Frames

- **`/luieufdebug`** [*frame*] [*preset*] — Attribute visuals debug.
- **`/luiufsm`** — Group frame debug preview.
- **`/luiufraid`** — Raid frame debug preview.
- **`/luiufplayer`** — Player frame debug preview.
- **`/luiuftar`** — Target frame debug preview.
- **`/luiufava`** — AvA frame debug preview.
- **`/luiufpet`** — Pet frame debug preview.
- **`/luiufboss`** — Boss frame debug preview.
- **`/luiufcomp`** — Companion frame debug preview.
- **`/luiufall`** — Debug preview for all frame categories.
- **`/luiufdumpfonts`** — Dump unit frame font diagnostics.

## Contribute

LuiExtended code is open source under the [MIT License](https://github.com/DakJaniels/LuiExtended/blob/master/LICENSE).  
Feel free to suggest or make contributions! You are welcome to copy and edit any code and features as long as they are not sections tagged as pulled from another addon.

## Disclaimer
>
>This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

  [1]: https://www.elderscrollsonline.com
  [2]: http://www.esoui.com/downloads/info413-LUI.html
  [3]: http://www.esoui.com/downloads/info28-FoundryTacticalCombat.html
