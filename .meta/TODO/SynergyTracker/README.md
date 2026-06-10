# Synergy Tracker (archived)

Combat Info **Synergy Tracker** was removed from the shipped addon pending rework. Sources live here; they are **not** listed in `LuiExtended.addon`.

## Layout

| Path | Original location |
| ------ | ------------------- |
| `modules/CombatInfo/SynergyTracker.lua` | `LuiExtended/modules/CombatInfo/SynergyTracker.lua` |
| `frontend/SynergyTracker.xml` | `LuiExtended/frontend/SynergyTracker.xml` |
| `settings/pc/CombatInfo_SynergyTracker.lua` | excerpt from `pc/settings/CombatInfo.lua` |
| `settings/console/CombatInfo_SynergyTracker.lua` | excerpt from `console/settings/CombatInfo.lua` |
| `snippets/Namespace_synergy_defaults.lua` | `CombatInfo.SynergyTracker` stub + `Defaults.synergy` |
| `lang/CombatInfo/*.lua` | synergy-related `LUIE_STRING_*` keys per locale |

## Re-enable checklist

1. Copy `modules/CombatInfo/SynergyTracker.lua` and `frontend/SynergyTracker.xml` into `LuiExtended/`.
2. Add to `LuiExtended/LuiExtended.addon` (after other Combat Info modules):
   - `frontend/SynergyTracker.xml`
   - `modules/CombatInfo/SynergyTracker.lua`
3. Restore `CombatInfo.SynergyTracker` stub and `CombatInfo.Defaults.synergy` in `modules/CombatInfo/Namespace.lua` (see `snippets/Namespace_synergy_defaults.lua`).
4. In `modules/CombatInfo/CombatInfo.lua`, call `CombatInfo.InitializeSynergyTracker()` from `CombatInfo.Initialize` (after CCT init).
5. Merge settings excerpts from `settings/pc/CombatInfo_SynergyTracker.lua` and `settings/console/CombatInfo_SynergyTracker.lua` back into `pc/settings/CombatInfo.lua` and `console/settings/CombatInfo.lua`.
6. Merge locale strings from `lang/CombatInfo/` back into `LuiExtended/lang/CombatInfo/` for each locale.
7. Optional: uncomment `self.HookSynergy()` in `pc/Initialize_PC.lua` if synergy popup blacklist behavior (via `CombatInfo.SV.synergy`) should return with the tracker.

## Integration references

- Init: `CombatInfo.InitializeSynergyTracker()` in `SynergyTracker.lua` (factory); gated on `LUIE.SV.CombatInfo_Enabled` and `CombatInfo.SV.synergy.enabled`.
- PC settings: LAM submenu `LUIE_STRING_LAM_CI_SYNERGY_TRACKER_HEADER`.
- Console: `buildSectionSettings("SynergyTracker", ...)` and `SettingsAPI:AppendSection(allSettings, "Synergy Tracker", sectionGroups["SynergyTracker"])`.
