-- -----------------------------------------------------------------------------
--  LuiExtended — SavedVariables migration (per-megaserver profile + per-module globals)
--  See ZO_SavedVars in esoui/libraries/utility/zo_savedvars.lua for path layout.
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local GetString = GetString
local zo_strformat = zo_strformat
local pairs = pairs
local ipairs = ipairs
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

--- Merge keys from legacy display subtree into the megaserver row when both exist (fixes empty-shell @account rows created before legacy `Default` data was copied).
--- @param destSubtree table
--- @param srcSubtree table
local function MergeDisplaySubtreeMissingFromLegacy(destSubtree, srcSubtree)
    if type(destSubtree) ~= "table" or type(srcSubtree) ~= "table" then
        return
    end
    for k, v in pairs(srcSubtree) do
        if k == "$AccountWide" and type(v) == "table" then
            if destSubtree[k] == nil then
                destSubtree[k] = {}
                ZO_DeepTableCopy(v, destSubtree[k])
            else
                ShallowMergeTableSkipVersion(destSubtree[k], v)
            end
        elseif type(v) == "table" and k ~= "$AccountWide" then
            if destSubtree[k] == nil then
                destSubtree[k] = {}
                ZO_DeepTableCopy(v, destSubtree[k])
            else
                ShallowMergeTableSkipVersion(destSubtree[k], v)
            end
        elseif destSubtree[k] == nil then
            if type(v) == "table" then
                destSubtree[k] = {}
                ZO_DeepTableCopy(v, destSubtree[k])
            else
                destSubtree[k] = v
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

--- Account-wide toggle for per-character LuiExtended profiles (stored on `$AccountWide`, not on character core `LUIE.SV`).
--- @return boolean
function LUIE.IsCharacterSpecificSavedVarsEnabled()
    local aw = LUIE.GetCoreAccountWideRawTable()
    return aw.CharacterSpecificSV == true
end

--- If legacy ZO profile `"Default"` holds this @DisplayName, merge or copy into the megaserver profile branch.
function LUIE.MigrateDisplaySubtreeFromLegacyProfile()
    local root = _G[LUIE.SVName]
    if not root then
        return
    end
    local legacy = LUIE.LegacySavedVarsProfile
    local world = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local dn = GetDisplayName()
    if not root[legacy] or not root[legacy][dn] then
        return
    end
    if not root[world] or not root[world][dn] then
        root[world] = root[world] or {}
        root[world][dn] = {}
        ZO_DeepTableCopy(root[legacy][dn], root[world][dn])
        return
    end
    MergeDisplaySubtreeMissingFromLegacy(root[world][dn], root[legacy][dn])
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

--- @return table
local function BuildModuleDefaultsLookup()
    return
    {
        UnitFrames = LUIE.UnitFrames.Defaults,
        CombatText = LUIE.CombatText.Defaults,
        ChatAnnouncements = LUIE.ChatAnnouncements.Defaults,
        SpellCastBuffs = LUIE.SpellCastBuffs.Defaults,
        ActionBar = LUIE.ActionBar.Defaults,
        InfoPanel = LUIE.InfoPanel.Defaults,
        SlashCommands = LUIE.SlashCommands.Defaults,
        CombatInfo = LUIE.CombatInfo.Defaults,
        MiniMap = LUIE.MiniMap.Defaults,
    }
end

--- Move each module namespace from one `LUIESV` profile row into split module globals, clearing keys on the legacy bucket.
--- @param luiRoot table
--- @param profile string
--- @param charSpecific boolean
--- @param ver integer
--- @param moduleDefaults table
--- @param dn string
local function MigrateModuleNamespacesFromLuiESVProfile(luiRoot, profile, charSpecific, ver, moduleDefaults, dn)
    for _, moduleKey in ipairs(LUIE.ModuleSavedVarNamespaceKeys) do
        local globalName = LUIE.ModuleSavedVarNames[moduleKey]
        local defaults = moduleDefaults[moduleKey]
        if globalName and defaults then
            if charSpecific then
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
end

--- @param luiRoot table
--- @param profile string
--- @param displayName string
--- @param charSpecific boolean
--- @return integer
local function CountLegacyModuleNamespacesInLuiESVProfile(luiRoot, profile, displayName, charSpecific)
    local displayRoot = luiRoot and luiRoot[profile] and luiRoot[profile][displayName]
    if not displayRoot then
        return 0
    end
    local count = 0
    local function countBucket(bucket)
        if type(bucket) ~= "table" then
            return
        end
        for _, moduleKey in ipairs(LUIE.ModuleSavedVarNamespaceKeys) do
            if bucket[moduleKey] ~= nil then
                count = count + 1
            end
        end
    end
    if charSpecific then
        for charKey, charBucket in pairs(displayRoot) do
            if charKey ~= "$AccountWide" and type(charBucket) == "table" then
                countBucket(charBucket)
            end
        end
    else
        countBucket(displayRoot["$AccountWide"])
    end
    return count
end

--- After core `LUIE.SV` exists: move each module namespace from `LUIESV` into its own global, then clear the old namespace key.
function LUIE.MigrateSplitModuleSavedVarsFromLuiESV()
    if LUIE.IsMigrationDone("split_module_saved_vars_v1") then
        return
    end

    local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local dn = GetDisplayName()
    local charSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    local ver = LUIE.SVVer
    local moduleDefaults = BuildModuleDefaultsLookup()
    local luiRoot = _G[LUIE.SVName]

    MigrateModuleNamespacesFromLuiESVProfile(luiRoot, profile, charSpecific, ver, moduleDefaults, dn)

    LUIE.MarkMigrationDone("split_module_saved_vars_v1")
end

--- Repair: migrate any module namespaces still present under `LUIESV` for this account (including profile `Default` after v1 only scanned the megaserver row, or after partial backup restore).
function LUIE.RepairSplitModuleSavedVarsFromLegacy()
    if LUIE.IsMigrationDone("split_module_saved_vars_v2") then
        return
    end
    if not LUIE.SV then
        return
    end

    local luiRoot = _G[LUIE.SVName]
    if not luiRoot then
        return
    end

    local charSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    local ver = LUIE.SVVer
    local dn = GetDisplayName()
    local moduleDefaults = BuildModuleDefaultsLookup()
    local world = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local legacy = LUIE.LegacySavedVarsProfile

    MigrateModuleNamespacesFromLuiESVProfile(luiRoot, world, charSpecific, ver, moduleDefaults, dn)
    if legacy ~= world then
        MigrateModuleNamespacesFromLuiESVProfile(luiRoot, legacy, charSpecific, ver, moduleDefaults, dn)
    end

    if CountLegacyModuleNamespacesInLuiESVProfile(luiRoot, world, dn, charSpecific) > 0 then
        return
    end
    if legacy ~= world and CountLegacyModuleNamespacesInLuiESVProfile(luiRoot, legacy, dn, charSpecific) > 0 then
        return
    end

    LUIE.MarkMigrationDone("split_module_saved_vars_v2")
end

--- @param displayName string
--- @return boolean
function LUIE.LuiESVLegacyModuleNamespacesEmptyForDisplay(displayName)
    if not LUIE.SV then
        return true
    end
    local luiRoot = _G[LUIE.SVName]
    if not luiRoot then
        return true
    end
    local charSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    local world = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local legacy = LUIE.LegacySavedVarsProfile
    if CountLegacyModuleNamespacesInLuiESVProfile(luiRoot, world, displayName, charSpecific) > 0 then
        return false
    end
    if legacy ~= world and CountLegacyModuleNamespacesInLuiESVProfile(luiRoot, legacy, displayName, charSpecific) > 0 then
        return false
    end
    return true
end

--- Count non-version keys in a raw saved-vars leaf (cheap “populated” signal for diagnostics).
--- @param leaf table|nil
--- @return integer
function LUIE.SavedVarsRawLeafNonVersionKeyCount(leaf)
    if type(leaf) ~= "table" then
        return 0
    end
    local n = 0
    for k in pairs(leaf) do
        if k ~= "version" then
            n = n + 1
        end
    end
    return n
end

--- Print SavedVariables migration diagnostics to chat (`/luie svstatus`).
function LUIE.PrintSavedVariablesMigrationStatus()
    local mig = LUIE.SV and LUIE.SV.Migrations
    local function mkey(k)
        return mig and mig[k] == true and "true" or "false"
    end

    local world = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local legacy = LUIE.LegacySavedVarsProfile
    local dn = GetDisplayName()
    local charSpec = LUIE.IsCharacterSpecificSavedVarsEnabled()

    LUIE.ChatOutput:Print(GetString(LUIE_STRING_SV_STATUS_HEADER), true)
    LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_WORLD_PROFILE), tostring(world)), true)
    LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_DISPLAY_NAME), dn), true)
    LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_CHAR_SPECIFIC), tostring(charSpec)), true)
    LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_SPLIT_V1), mkey("split_module_saved_vars_v1")), true)
    LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_SPLIT_V2), mkey("split_module_saved_vars_v2")), true)
    LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_PRUNED_V1), mkey("lui_pruned_legacy_default_profile_v1")), true)

    local luiRoot = _G[LUIE.SVName]
    if type(luiRoot) == "table" then
        local hasDefault = luiRoot[legacy] ~= nil and luiRoot[legacy][dn] ~= nil
        local hasWorld = luiRoot[world] ~= nil and luiRoot[world][dn] ~= nil
        LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_DEFAULT_EXISTS), tostring(hasDefault)), true)
        LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_WORLD_EXISTS), tostring(world), tostring(hasWorld)), true)
        local cDef = CountLegacyModuleNamespacesInLuiESVProfile(luiRoot, legacy, dn, charSpec)
        local cWorld = CountLegacyModuleNamespacesInLuiESVProfile(luiRoot, world, dn, charSpec)
        LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_LEGACY_NS_DEFAULT), tostring(cDef)), true)
        LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_LEGACY_NS_WORLD), tostring(cWorld)), true)
    else
        LUIE.ChatOutput:Print(GetString(LUIE_STRING_SV_STATUS_ROOT_MISSING), true)
    end

    for _, moduleKey in ipairs(LUIE.ModuleSavedVarNamespaceKeys) do
        local globalName = LUIE.ModuleSavedVarNames[moduleKey]
        if globalName then
            local leaf
            if charSpec then
                leaf = GetRawCharacterLeaf(globalName, world, dn, GetUnitName("player"))
            else
                leaf = GetRawAccountWideLeaf(globalName, world, dn)
            end
            local n = LUIE.SavedVarsRawLeafNonVersionKeyCount(leaf)
            LUIE.ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_SV_STATUS_RAW_LEAF_KEYS), globalName, tostring(n)), true)
        end
    end
end

--- After per-module globals are live, remove the duplicate ZO profile branch `LUIESV["Default"][@DisplayName]`
--- so the SavedVariables file stops carrying two copies of the same account (megaserver profile is canonical).
--- Safe once split migrations completed and legacy module namespaces are gone from `LUIESV` for this display name.
function LUIE.PruneLegacyLuiESVDefaultProfileBranch()
    if LUIE.IsMigrationDone("lui_pruned_legacy_default_profile_v1") then
        return
    end
    if not LUIE.IsMigrationDone("split_module_saved_vars_v1") then
        return
    end
    if not LUIE.IsMigrationDone("split_module_saved_vars_v2") then
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

--- When character profiles were enabled but modules still bound account-wide, module data may only exist on `$AccountWide` split leaves. Seed the current character raw leaf from account-wide for keys not yet present (does not overwrite).
function LUIE.SeedCharacterModuleSavedVarsFromAccountWide()
    if not LUIE.IsCharacterSpecificSavedVarsEnabled() then
        return
    end

    local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local dn = GetDisplayName()
    local charKey = GetUnitName("player")

    for _, moduleKey in ipairs(LUIE.ModuleSavedVarNamespaceKeys) do
        local globalName = LUIE.ModuleSavedVarNames[moduleKey]
        if globalName then
            local srcAw = GetRawAccountWideLeaf(globalName, profile, dn)
            if type(srcAw) == "table" and LUIE.SavedVarsRawLeafNonVersionKeyCount(srcAw) > 0 then
                local charLeaf = GetRawCharacterLeaf(globalName, profile, dn, charKey)
                local charKeyCount = LUIE.SavedVarsRawLeafNonVersionKeyCount(charLeaf)
                if charLeaf == nil or charKeyCount == 0 then
                    local g = _G[globalName]
                    g[profile] = g[profile] or {}
                    g[profile][dn] = g[profile][dn] or {}
                    if charLeaf == nil then
                        g[profile][dn][charKey] = {}
                        charLeaf = g[profile][dn][charKey]
                    end
                    ShallowMergeTableSkipVersion(charLeaf, srcAw)
                end
            end
        end
    end
end

-- -----------------------------------------------------------------------------
--  Chat output settings: LUIE_ChatAnnouncements_SV -> LUIESV.ChatOutput (account-wide routing)
-- -----------------------------------------------------------------------------

local CHAT_OUTPUT_MIGRATION_KEYS =
{
    "ChatMethod",
    "ChatBypassFormat",
    "TimeStamp",
    "TimeStampFormat",
}

--- Copy legacy chat routing keys from Chat Announcements module SV into `LUIE.SV.ChatOutput`.
--- Tab/timestamp preferences become account-wide (or per-character when `CharacterSpecificSV` is on).
function LUIE.MigrateChatOutputToCore()
    if not LUIE.SV or LUIE.IsMigrationDone("chat_output_to_core") then
        return
    end

    LUIE.SV.ChatOutput = LUIE.SV.ChatOutput or {}
    local dest = LUIE.SV.ChatOutput

    local globalName = LUIE.ModuleSavedVarNames.ChatAnnouncements
    local src = LUIE.GetRawModuleAccountWideLeaf(globalName)
    if LUIE.IsCharacterSpecificSavedVarsEnabled() then
        local charSrc = LUIE.GetRawModuleCharacterLeaf(globalName)
        if charSrc then
            src = charSrc
        end
    end

    if type(src) == "table" then
        for _, key in ipairs(CHAT_OUTPUT_MIGRATION_KEYS) do
            if src[key] ~= nil then
                dest[key] = src[key]
            end
        end
        if type(src.ChatTab) == "table" then
            dest.ChatTab = dest.ChatTab or {}
            ZO_DeepTableCopy(src.ChatTab, dest.ChatTab)
        end
        if type(src.TimeStampColor) == "table" then
            dest.TimeStampColor = { unpack(src.TimeStampColor) }
        end
        if type(src.Social) == "table" then
            dest.Social = dest.Social or {}
            if src.Social.FriendStatusCA ~= nil then
                dest.Social.FriendStatusCA = src.Social.FriendStatusCA
            end
            if src.Social.FriendIgnoreCA ~= nil then
                dest.Social.FriendIgnoreCA = src.Social.FriendIgnoreCA
            end
        end
    end

    dest.Social = dest.Social or {}
    if dest.Social.FriendStatusCA == nil then
        dest.Social.FriendStatusCA = LUIE.Defaults.ChatOutput.Social.FriendStatusCA
    end
    if dest.Social.FriendIgnoreCA == nil then
        dest.Social.FriendIgnoreCA = LUIE.Defaults.ChatOutput.Social.FriendIgnoreCA
    end

    LUIE.MarkMigrationDone("chat_output_to_core")
end

--- Move deprecated core `TempAlert*` slash toggles into Chat Announcements `Notify.*` and remove legacy keys.
function LUIE.MigrateTempSlashAlertsToChatAnnouncements()
    if not LUIE.SV or LUIE.IsMigrationDone("temp_slash_alerts_to_ca") then
        return
    end

    local core = LUIE.GetCoreAccountWideRawTable()
    local globalName = LUIE.ModuleSavedVarNames.ChatAnnouncements
    local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    local defaults = LUIE.ChatAnnouncements.Defaults
    local dest
    if LUIE.IsCharacterSpecificSavedVarsEnabled() then
        dest = ZO_SavedVars:New(globalName, LUIE.SVVer, nil, defaults, profile)
    else
        dest = ZO_SavedVars:NewAccountWide(globalName, LUIE.SVVer, nil, defaults, profile)
    end

    dest.Notify = dest.Notify or {}
    local notify = dest.Notify

    if core.TempAlertHome == true then
        notify.SlashHomeAlert = true
        notify.SlashHomeCA = true
    end
    if core.TempAlertCampaign == true then
        notify.SlashCampaignAlert = true
        notify.SlashCampaignCA = true
        notify.CampaignQueueAlert = true
        notify.CampaignQueueCA = true
    end
    if core.TempAlertOutfit == true then
        notify.OutfitEquipAlert = true
        notify.OutfitEquipCA = true
    end

    core.TempAlertHome = nil
    core.TempAlertCampaign = nil
    core.TempAlertOutfit = nil
    if LUIE.SV then
        LUIE.SV.TempAlertHome = nil
        LUIE.SV.TempAlertCampaign = nil
        LUIE.SV.TempAlertOutfit = nil
    end

    LUIE.MarkMigrationDone("temp_slash_alerts_to_ca")
end
