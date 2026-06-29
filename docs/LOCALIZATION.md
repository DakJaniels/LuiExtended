# Localization

LuiExtended user-facing strings live under `LuiExtended/lang/`. English source strings are in each module's `default.lua`. The addon manifest loads `lang/<Module>/$(language).lua` for each module (see `## Language Files` in `LuiExtended.addon`). ESO resolves `$(language)` to the client language; if a locale file is missing for a module, that module falls back to `default.lua` (English).

## Locales with full module coverage

These languages aim for a `*.lua` file in **every** module folder listed below:

| Code | Language |
| --- | --- |
| `default` | English (source) |
| `de` | German |
| `fr` | French |
| `ru` | Russian |
| `zh` | Simplified Chinese (ESO client code `zh`) |

Modules with string tables: **Core**, **Shared**, **ActionBar**, **ChatAnnouncements**, **CombatInfo**, **CombatText**, **InfoPanel**, **SlashCommands**, **SpellCastBuffs**, **UnitFrames**, **MiniMap**.

There is no separate Traditional Chinese table in this repo; translate Simplified Chinese in `zh.lua`.

`_RegisterStrings.lua` registers string IDs for the client. Do not rename `LUIE_STRING_*` constants in locale files; only translate the string values.

## Partial locales (module by module)

Partial translation is normal. You add `tr.lua` (or another code) under one module at a time; untranslated modules keep using English. That is how **Turkish (`tr`)** is maintained today: `tr.lua` exists for Core, Shared, ChatAnnouncements, CombatInfo, CombatText, InfoPanel, SlashCommands, SpellCastBuffs, and UnitFrames, and not yet for every module (for example **ActionBar** and **MiniMap** still use English until someone adds those files).

Contributors can extend a partial locale incrementally. You do not need every module done before the first merge.

## LuiData and LuiMedia

**LuiData** and **LuiMedia** are separate add-ons with their own localization (if any). LUIE settings strings do not cover LuiData ability names shown from game data; those follow the ESO client language.

## How to contribute translations

1. Open the module's `default.lua` for the keys you need.
2. Add or update the same keys in the target locale file for that module (`de.lua`, `fr.lua`, `ru.lua`, `zh.lua`, `tr.lua`, or a new `$(language).lua` you are building out).
3. Keep format placeholders intact: `<<1>>`, `<<2>>`, `%n`, `%t`, `%a`, `\n`, and color markup such as `|cXXXXXX`.
4. Match tone and length where possible; settings tooltips can be long; test in-game on PC or console if you can.
5. Open a pull request against **`master`** with your locale updates only (avoid mixing unrelated code changes).

PC settings link here via **LuiExtended → Translation** in LibAddonMenu (same URL as this file on GitHub).

## Reporting translation bugs

When filing an issue, include:

- Client language code
- Module name (e.g. Unit Frames, Chat Announcements)
- English text and what you expected
- Screenshot if the string is truncated or overlaps in settings UI

English fixes belong in `default.lua`; other languages in the matching `$(language).lua`.
