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

-- -----------------------------------------------------------------------------
--  External-addon legacy view of LUIESV (e.g. Srendarr: LUIESV.Default[@name]["$AccountWide"].UnitFrames.*)
--  Megaserver data lives under GetWorldName(); module tables live in per-module globals after split.
-- -----------------------------------------------------------------------------

--- Weak-key cache: raw ZO bucket table -> overlay proxy (see ZO_ForwardUnimplementedMethodsForControl pattern).
--- @type table<table, table>
local s_accountWideOverlayProxyByRawBucket = setmetatable({}, { __mode = "k" })

--- @type table<table, table>
local s_characterOverlayProxyByRawBucket = setmetatable({}, { __mode = "k" })

--- @param rawBucketTable table Account-wide or character leaf on LUIESV
--- @param savedVarsProfile string
--- @param displayName string
--- @param characterKey string|nil When nil, resolve split modules from account-wide globals
--- @return table
local function CreateLegacyModuleNamespaceOverlayProxy(rawBucketTable, savedVarsProfile, displayName, characterKey)
    local overlayProxyCache = characterKey and s_characterOverlayProxyByRawBucket or s_accountWideOverlayProxyByRawBucket
    local existingOverlayProxy = overlayProxyCache[rawBucketTable]
    if existingOverlayProxy then
        return existingOverlayProxy
    end

    local function GetSplitModuleRawLeafForNamespace(namespaceKey)
        local moduleGlobalName = LUIE.ModuleSavedVarNames[namespaceKey]
        if not moduleGlobalName then
            return nil
        end
        if characterKey then
            return GetRawCharacterLeaf(moduleGlobalName, savedVarsProfile, displayName, characterKey)
        end
        return GetRawAccountWideLeaf(moduleGlobalName, savedVarsProfile, displayName)
    end

    local function ReadValueFromRawBucket(key)
        local value = rawget(rawBucketTable, key)
        if value ~= nil then
            return value
        end
        local rawBucketMetatable = getmetatable(rawBucketTable)
        if not rawBucketMetatable then
            return nil
        end
        local originalIndex = rawBucketMetatable.__index
        if type(originalIndex) == "function" then
            return originalIndex(rawBucketTable, key)
        elseif type(originalIndex) == "table" then
            return originalIndex[key]
        end
        return nil
    end

    local overlayProxy = setmetatable(
        {},
        {
            __index = function (overlayTable, key)
                if LUIE.ModuleSavedVarNames[key] then
                    local splitModuleLeaf = GetSplitModuleRawLeafForNamespace(key)
                    if splitModuleLeaf then
                        return splitModuleLeaf
                    end
                end
                return ReadValueFromRawBucket(key)
            end,
            __newindex = function (overlayTable, key, value)
                rawset(rawBucketTable, key, value)
            end,
        })

    overlayProxyCache[rawBucketTable] = overlayProxy
    return overlayProxy
end

--- @param savedVarsRoot table
--- @param savedVarsProfile string
--- @param displayName string
--- @return table|nil
local function CreateLegacyDisplayNameSubtreeProxy(savedVarsRoot, savedVarsProfile, displayName)
    local profileBranch = savedVarsRoot[savedVarsProfile]
    if not profileBranch then
        return nil
    end
    local rawDisplaySubtree = profileBranch[displayName]
    if not rawDisplaySubtree then
        return nil
    end

    return setmetatable(
        {},
        {
            __index = function (displayProxy, key)
                if key == "$AccountWide" then
                    local rawAccountWideBucket = rawDisplaySubtree["$AccountWide"]
                    if type(rawAccountWideBucket) == "table" then
                        return CreateLegacyModuleNamespaceOverlayProxy(rawAccountWideBucket, savedVarsProfile, displayName, nil)
                    end
                    return nil
                end
                local rawCharacterBucket = rawDisplaySubtree[key]
                if type(rawCharacterBucket) == "table" then
                    return CreateLegacyModuleNamespaceOverlayProxy(rawCharacterBucket, savedVarsProfile, displayName, key)
                end
                return rawCharacterBucket
            end,
            __newindex = function (displayProxy, key, value)
                rawDisplaySubtree[key] = value
            end,
        })
end

--- In-memory archive of `LUIESV["Default"]` after megaserver split (profile copy / support still use raw globals).
LUIE.ArchivedLegacyDefaultProfileBranch = nil

--- Whether `InstallExternalSavedVarsLegacyCompat` has been applied to `_G[LUIE.SVName]`.
LUIE.isExternalSavedVarsLegacyCompatInstalled = false

--- Redirect `LUIESV.Default` to the active megaserver profile and overlay split module namespaces for third-party reads.
function LUIE.InstallExternalSavedVarsLegacyCompat()
    if LUIE.isExternalSavedVarsLegacyCompatInstalled then
        return
    end

    local savedVarsRoot = _G[LUIE.SVName]
    if type(savedVarsRoot) ~= "table" then
        return
    end

    local legacyProfileKey = LUIE.LegacySavedVarsProfile
    local activeMegaserverProfile = LUIE.SavedVarsProfile or legacyProfileKey

    if legacyProfileKey ~= activeMegaserverProfile and type(savedVarsRoot[legacyProfileKey]) == "table" then
        LUIE.ArchivedLegacyDefaultProfileBranch = savedVarsRoot[legacyProfileKey]
        savedVarsRoot[legacyProfileKey] = nil
    end

    local legacyDefaultProfileProxy = setmetatable(
        {},
        {
            __index = function (legacyProfileProxy, displayName)
                return CreateLegacyDisplayNameSubtreeProxy(savedVarsRoot, activeMegaserverProfile, displayName)
            end,
            __newindex = function (legacyProfileProxy, displayName, value)
                savedVarsRoot[activeMegaserverProfile] = savedVarsRoot[activeMegaserverProfile] or {}
                savedVarsRoot[activeMegaserverProfile][displayName] = value
            end,
        })

    local savedVarsRootMetatable = getmetatable(savedVarsRoot) or {}
    local originalRootIndex = savedVarsRootMetatable.__index
    local originalRootNewIndex = savedVarsRootMetatable.__newindex

    local function SavedVarsRootIndexWrapper(savedVarsTable, key)
        if key == legacyProfileKey then
            return legacyDefaultProfileProxy
        end
        if originalRootIndex then
            if type(originalRootIndex) == "function" then
                return originalRootIndex(savedVarsTable, key)
            end
            return originalRootIndex[key]
        end
    end

    local function SavedVarsRootNewIndexWrapper(savedVarsTable, key, value)
        if key == legacyProfileKey then
            savedVarsRoot[activeMegaserverProfile] = value
            return
        end
        if originalRootNewIndex then
            originalRootNewIndex(savedVarsTable, key, value)
        else
            rawset(savedVarsTable, key, value)
        end
    end

    setmetatable(
        savedVarsRoot,
        {
            __index = SavedVarsRootIndexWrapper,
            __newindex = SavedVarsRootNewIndexWrapper,
        })

    LUIE.isExternalSavedVarsLegacyCompatInstalled = true
end
