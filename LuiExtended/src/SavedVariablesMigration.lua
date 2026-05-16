-- -----------------------------------------------------------------------------
--  LuiExtended — SavedVariables migration (per-megaserver profile + per-module globals)
--  See ZO_SavedVars in esoui/libraries/utility/zo_savedvars.lua for path layout.
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local pairs = pairs
local type = type
local tostring = tostring

--- @param dest table
--- @param src table
local function ShallowMergeTableSkipVersion(dest, src)
    for k, v in pairs(src) do
        if k ~= "version" then
            if type(v) == "table" then
                if dest[k] == nil then
                    dest[k] = {}
                end
                ZO_DeepTableCopy(v, dest[k])
            else
                dest[k] = v
            end
        end
    end
end

--- Raw `LUIESV` / `_G[LUIE.SVName]` account-wide leaf (`$AccountWide`) for the active megaserver profile.
--- Used for legacy keys that remain on core SV (e.g. `AdjustVars*`).
--- @return table
function LUIE.GetCoreAccountWideRawTable()
    local root = _G[LUIE.SVName]
    local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local dn = GetDisplayName()
    root[profile] = root[profile] or {}
    root[profile][dn] = root[profile][dn] or {}
    root[profile][dn]["$AccountWide"] = root[profile][dn]["$AccountWide"] or {}
    return root[profile][dn]["$AccountWide"]
end

--- If legacy ZO profile `"Default"` holds this @DisplayName but the megaserver profile branch does not, deep-copy the display subtree once.
function LUIE.MigrateDisplaySubtreeFromLegacyProfile()
    local root = _G[LUIE.SVName]
    if not root then
        return
    end
    local legacy = LUIE.LegacySavedVarsProfile
    local world = LUIE.SavedVarsProfile
    local dn = GetDisplayName()
    if not root[legacy] or not root[legacy][dn] then
        return
    end
    if root[world] and root[world][dn] then
        return
    end
    root[world] = root[world] or {}
    root[world][dn] = {}
    ZO_DeepTableCopy(root[legacy][dn], root[world][dn])
end

--- @param globalName string
--- @param profile string
--- @param displayName string
--- @return table|nil
local function GetRawAccountWideLeaf(globalName, profile, displayName)
    local g = _G[globalName]
    if not g or not g[profile] or not g[profile][displayName] then
        return nil
    end
    return g[profile][displayName]["$AccountWide"]
end

--- @param globalName string
--- @param profile string
--- @param displayName string
--- @param characterKey string
--- @return table|nil
local function GetRawCharacterLeaf(globalName, profile, displayName, characterKey)
    local g = _G[globalName]
    if not g or not g[profile] or not g[profile][displayName] then
        return nil
    end
    return g[profile][displayName][characterKey]
end

--- After core `LUIE.SV` exists: move each module namespace from `LUIESV` into its own global, then clear the old namespace key.
function LUIE.MigrateSplitModuleSavedVarsFromLuiESV()
    if LUIE.IsMigrationDone("split_module_saved_vars_v1") then
        return
    end

    local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local dn = GetDisplayName()
    local charSpecific = LUIE.SV.CharacterSpecificSV
    local ver = LUIE.SVVer

    local moduleDefaults =
    {
        UnitFrames = LUIE.UnitFrames.Defaults,
        CombatText = LUIE.CombatText.Defaults,
        ChatAnnouncements = LUIE.ChatAnnouncements.Defaults,
        SpellCastBuffs = LUIE.SpellCastBuffs.Defaults,
        ActionBar = LUIE.ActionBar.Defaults,
        InfoPanel = LUIE.InfoPanel.Defaults,
        SlashCommands = LUIE.SlashCommands.Defaults,
        CombatInfo = LUIE.CombatInfo.Defaults,
    }

    for _, moduleKey in ipairs(LUIE.ModuleSavedVarNamespaceKeys) do
        local globalName = LUIE.ModuleSavedVarNames[moduleKey]
        local defaults = moduleDefaults[moduleKey]
        if globalName and defaults then
            if charSpecific then
                local luiRoot = _G[LUIE.SVName]
                local displayRoot = luiRoot and luiRoot[profile] and luiRoot[profile][dn]
                if displayRoot then
                    local proxy = ZO_SavedVars:New(globalName, ver, nil, defaults, profile)
                    local playerName = GetUnitName("player")
                    for charKey, charBucket in pairs(displayRoot) do
                        if charKey ~= "$AccountWide" and type(charBucket) == "table" then
                            local legacyMod = charBucket[moduleKey]
                            if legacyMod and type(legacyMod) == "table" then
                                if charKey == playerName then
                                    ShallowMergeTableSkipVersion(proxy, legacyMod)
                                else
                                    local g = _G[globalName]
                                    g[profile] = g[profile] or {}
                                    g[profile][dn] = g[profile][dn] or {}
                                    if not g[profile][dn][charKey] then
                                        g[profile][dn][charKey] = {}
                                    end
                                    local dest = g[profile][dn][charKey]
                                    if dest.version == nil or dest.version < ver then
                                        ZO_ClearTable(dest)
                                        dest.version = ver
                                    end
                                    ShallowMergeTableSkipVersion(dest, legacyMod)
                                end
                                charBucket[moduleKey] = nil
                            end
                        end
                    end
                end
            else
                local proxy = ZO_SavedVars:NewAccountWide(globalName, ver, nil, defaults, profile)
                local legacyAw = GetRawAccountWideLeaf(LUIE.SVName, profile, dn)
                local legacyMod = legacyAw and legacyAw[moduleKey]
                if legacyMod and type(legacyMod) == "table" then
                    ShallowMergeTableSkipVersion(proxy, legacyMod)
                    legacyAw[moduleKey] = nil
                end
            end
        end
    end

    LUIE.MarkMigrationDone("split_module_saved_vars_v1")
end

--- After per-module globals are live, remove the duplicate ZO profile branch `LUIESV["Default"][@DisplayName]`
--- so the SavedVariables file stops carrying two copies of the same account (megaserver profile is canonical).
--- Safe only once `split_module_saved_vars_v1` has completed and the world profile row exists for this display name.
function LUIE.PruneLegacyLuiESVDefaultProfileBranch()
    if LUIE.IsMigrationDone("lui_pruned_legacy_default_profile_v1") then
        return
    end
    if not LUIE.IsMigrationDone("split_module_saved_vars_v1") then
        return
    end

    local root = _G[LUIE.SVName]
    if not root then
        return
    end

    local legacy = LUIE.LegacySavedVarsProfile
    local world = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local dn = GetDisplayName()

    if legacy == world then
        LUIE.MarkMigrationDone("lui_pruned_legacy_default_profile_v1")
        return
    end

    -- Do not drop the legacy branch unless the megaserver profile has a subtree for this @name (avoids wiping the only copy).
    if not (root[world] and root[world][dn]) then
        return
    end

    if root[legacy] and root[legacy][dn] then
        root[legacy][dn] = nil
    end

    LUIE.MarkMigrationDone("lui_pruned_legacy_default_profile_v1")
end

--- Raw account-wide module leaf on a split global (`namespace == nil` in `ZO_SavedVars`).
--- @param globalName string
--- @return table|nil
function LUIE.GetRawModuleAccountWideLeaf(globalName)
    local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    return GetRawAccountWideLeaf(globalName, profile, GetDisplayName())
end

--- Raw character module leaf on a split global (for migrations that predate `CombatInfo.Initialize`).
--- @param globalName string
--- @return table|nil
function LUIE.GetRawModuleCharacterLeaf(globalName)
    local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    return GetRawCharacterLeaf(globalName, profile, GetDisplayName(), GetUnitName("player"))
end
