# LuiExtended [![Current Release](https://img.shields.io/github/release/ArtOfShred/LuiExtended.svg)](https://github.com/ArtOfShred/LuiExtended/releases) [![GitHub license](https://img.shields.io/github/license/ArtOfShred/LuiExtended.svg)](https://github.com/ArtOfShred/LuiExtended/blob/master/LICENSE)

LuiExtended is an AddOn that adds multiple custom components including

- **Buff & Debuff Tracking** Track buffs and debuffs with new custom icons and significant enhancements to auras done by using a manual override table.
- **Chat Announcements** Display messages in chat when spending or receiving currency, track loot, achievements, experience gain, social events, guild invites, quests, and much more.
- **Combat Info** Track your GCD, Ultimate Value, Quickslot Cooldown, Highlight Active Abilities on your bar, display a Castbar, show alerts for incoming enemy abilities, and track when you are effected by Crowd Control or standing in the radius of a damaging area of effect ability.
- **Combat Text** Display your outgoing and incoming damage/healing, track crowd control, track incoming damaging abilities with a new warning system, and monitor your resource gain.
- **Slash Commands** Adds useful commands to the game such as porting to your primary home, regrouping and more. See [Slash commands](#slash-commands) below.
- **Unit Frames** Custom Unitframes for Player/Target, Group, Raid, and Bosses. Color group and raid frames by Class or Role, track power changes, armor changes, and dots with animations on the frame.

Initially this [Elder Scrolls Online][1] AddOn was based partially on the [LUI][2] AddOn by LoPony and some features of [Foundry Tactical Combat][3] AddOn.

## Information

Spreadsheet tracking for Buff/Debuff issues: [Buff/Debuff issues spreadsheet][4].  
Goal is for this spreadsheet to also serve as a modders resource, and a bug tracker for inconsistencies with abilities in the game to report to Zenimax.

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

LuiExtended code is intended to be open source released under the MIT License.  
Feel free to suggest or make contributions! You are welcome to copy and edit any code and features as long as they are not sections tagged as pulled from another addon.

## Disclaimer
>
>This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

  [1]: https://www.elderscrollsonline.com
  [2]: http://www.esoui.com/downloads/info413-LUI.html
  [3]: http://www.esoui.com/downloads/info28-FoundryTacticalCombat.html
  [4]: https://docs.google.com/spreadsheets/d/1UVpe00hL2lR7wO0Fpo30sFMsc603kJqtEPtvWDHkA74/edit#gid=468027794
