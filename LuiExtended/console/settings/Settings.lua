-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- local g_ElementMovingEnabled

-- local GridOverlay = LUIE.GridOverlay

local pairs = pairs
local ipairs = ipairs
local type = type
local table_concat = table.concat
local table_sort = table.sort

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings
local SettingsAPI = LUIE.ConsoleSettingsAPI

-- Create Settings Menu
function LUIE.CreateConsoleSettings()
    local Defaults = LUIE.Defaults
    local Settings = LUIE.SV

    local settingsData = {}

    -- SavedVariables profile copy (LibHarvens): megaserver -> @account -> row; `items` as functions so sibling dropdowns refresh via panel ValueChanged (LibHarvensAddonSettings Console/Settings.lua).
    local copyPick_server
    local copyPick_account
    local copyPick_bucket
    local copyPick_sourceKind
    local copyPick_characterName
    local serverItems = {}
    local accountItems = {}
    local bucketItems = {}
    local kindItems = {}
    local characterItems = {}

    local function wipeItems(t)
        for i = #t, 1, -1 do
            t[i] = nil
        end
    end

    local function ProfileCopyCurrentProfile()
        return LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
    end

    local function ProfileCopyEnumGlobalNames()
        local t = { LUIE.SVName }
        for _, modKey in ipairs(LUIE.ModuleSavedVarNamespaceKeys) do
            local gn = LUIE.ModuleSavedVarNames[modKey]
            if gn then
                t[#t + 1] = gn
            end
        end
        return t
    end

    local function ProfileCopyValueInList(values, v)
        if v == nil then
            return false
        end
        for i = 1, #values do
            if values[i] == v then
                return true
            end
        end
        return false
    end

    local function ProfileCopyUnionProfileKeys()
        local seen = {}
        for _, gn in ipairs(ProfileCopyEnumGlobalNames()) do
            local g = _G[gn]
            if type(g) == "table" then
                for k, v in pairs(g) do
                    if type(k) == "string" and type(v) == "table" then
                        seen[k] = true
                    end
                end
            end
        end
        local list = {}
        for k in pairs(seen) do
            list[#list + 1] = k
        end
        table_sort(list)
        return list
    end

    local function ProfileCopyBuildServerChoices()
        local profiles = ProfileCopyUnionProfileKeys()
        local current = ProfileCopyCurrentProfile()
        local labels, values = {}, {}
        for i = 1, #profiles do
            local p = profiles[i]
            values[i] = p
            if p == current then
                labels[i] = zo_strformat("<<1>> (<<2>>)", p, GetString(LUIE_STRING_LAM_SVPROFILE_COPY_CURRENT_PROFILE))
            else
                labels[i] = p
            end
        end
        return labels, values
    end

    local function ProfileCopyBuildAccountChoices()
        local serverProfile = copyPick_server or ProfileCopyCurrentProfile()
        local seen = {}
        for _, gn in ipairs(ProfileCopyEnumGlobalNames()) do
            local g = _G[gn]
            if type(g) == "table" then
                local branch = g[serverProfile]
                if type(branch) == "table" then
                    for acc, inner in pairs(branch) do
                        if type(acc) == "string" and type(inner) == "table" then
                            seen[acc] = true
                        end
                    end
                end
            end
        end
        local keys = {}
        for acc in pairs(seen) do
            keys[#keys + 1] = acc
        end
        table_sort(keys)
        local labels = {}
        for i = 1, #keys do
            labels[i] = keys[i]
        end
        return labels, keys
    end

    local function ProfileCopyGetTargetTriple()
        local tgtProfile = ProfileCopyCurrentProfile()
        local tgtAcc = GetDisplayName()
        local core = _G[LUIE.SVName]
        if not (core and core[tgtProfile] and core[tgtProfile][tgtAcc] and core[tgtProfile][tgtAcc]["$AccountWide"]) then
            return nil, nil, nil, false
        end
        local aw = core[tgtProfile][tgtAcc]["$AccountWide"]
        local isChar = aw.CharacterSpecificSV
        local tgtBucket = isChar and GetUnitName("player") or "$AccountWide"
        return tgtProfile, tgtAcc, tgtBucket, isChar
    end

    local function ProfileCopyBuildBucketChoices()
        local serverProfile = copyPick_server or ProfileCopyCurrentProfile()
        local accountName = copyPick_account
        local labels, values = {}, {}
        if not accountName then
            return labels, values
        end
        local tgtP, tgtA, _, isCharSpec = ProfileCopyGetTargetTriple()
        local playerName = GetUnitName("player")
        local seen = {}
        for _, gn in ipairs(ProfileCopyEnumGlobalNames()) do
            local g = _G[gn]
            if type(g) == "table" then
                local acctBranch = g[serverProfile] and g[serverProfile][accountName]
                if type(acctBranch) == "table" then
                    for bucketKey, vars in pairs(acctBranch) do
                        if type(bucketKey) == "string" and type(vars) == "table" and vars.version == LUIE.SVVer then
                            if not (isCharSpec and tgtP and serverProfile == tgtP and accountName == tgtA and bucketKey == playerName) then
                                if not seen[bucketKey] then
                                    seen[bucketKey] = true
                                    values[#values + 1] = bucketKey
                                end
                            end
                        end
                    end
                end
            end
        end
        table_sort(values, function (a, b)
            if a == "$AccountWide" then
                return true
            end
            if b == "$AccountWide" then
                return false
            end
            return a < b
        end)
        for i = 1, #values do
            local k = values[i]
            if k == "$AccountWide" then
                labels[i] = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_SVPROFILE_COPY_BUCKET_ACCOUNTWIDE), accountName)
            else
                labels[i] = k
            end
        end
        return labels, values
    end

    local function ProfileCopyBuildCharacterRowChoices()
        local serverProfile = copyPick_server or ProfileCopyCurrentProfile()
        local accountName = copyPick_account
        local labels, values = {}, {}
        if not accountName then
            return labels, values
        end
        local tgtP, tgtA, _, isCharSpec = ProfileCopyGetTargetTriple()
        local playerName = GetUnitName("player")
        local seen = {}
        for _, gn in ipairs(ProfileCopyEnumGlobalNames()) do
            local g = _G[gn]
            if type(g) == "table" then
                local acctBranch = g[serverProfile] and g[serverProfile][accountName]
                if type(acctBranch) == "table" then
                    for bucketKey, vars in pairs(acctBranch) do
                        if bucketKey ~= "$AccountWide" and type(bucketKey) == "string" and type(vars) == "table" and vars.version == LUIE.SVVer then
                            if not (isCharSpec and tgtP and serverProfile == tgtP and accountName == tgtA and bucketKey == playerName) then
                                if not seen[bucketKey] then
                                    seen[bucketKey] = true
                                    values[#values + 1] = bucketKey
                                end
                            end
                        end
                    end
                end
            end
        end
        table_sort(values)
        for i = 1, #values do
            labels[i] = values[i]
        end
        return labels, values
    end

    local profileCopySplitSourceUI
    do
        local p = ProfileCopyCurrentProfile()
        local core = _G[LUIE.SVName]
        local aw = core and core[p] and core[p][GetDisplayName()] and core[p][GetDisplayName()]["$AccountWide"]
        profileCopySplitSourceUI = aw and aw.CharacterSpecificSV
    end

    local function ProfileCopyGetEffectiveSourceBucket()
        if not profileCopySplitSourceUI then
            return copyPick_bucket
        end
        if (copyPick_sourceKind or "accountwide") == "character" then
            return copyPick_characterName
        end
        return "$AccountWide"
    end

    local function ProfileCopyRebuildServerItems()
        wipeItems(serverItems)
        local labels, values = ProfileCopyBuildServerChoices()
        for i = 1, #labels do
            serverItems[i] = { name = labels[i], data = values[i] }
        end
    end

    local function ProfileCopyRebuildAccountItems()
        wipeItems(accountItems)
        local _, accounts = ProfileCopyBuildAccountChoices()
        for i = 1, #accounts do
            local acc = accounts[i]
            accountItems[i] = { name = acc, data = acc }
        end
    end

    local function ProfileCopyRebuildBucketItems()
        wipeItems(bucketItems)
        local labels, values = ProfileCopyBuildBucketChoices()
        for i = 1, #labels do
            bucketItems[i] = { name = labels[i], data = values[i] }
        end
    end

    local function ProfileCopyInitKindItems()
        if #kindItems > 0 then
            return
        end
        kindItems[1] = { name = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_KIND_ACCOUNTWIDE), data = "accountwide" }
        kindItems[2] = { name = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_KIND_CHARACTER), data = "character" }
    end

    local function ProfileCopyRebuildCharacterItems()
        wipeItems(characterItems)
        local labels, values = ProfileCopyBuildCharacterRowChoices()
        for i = 1, #labels do
            characterItems[i] = { name = labels[i], data = values[i] }
        end
    end

    local function ProfileCopyRefreshBucketOrSplitPicks()
        if profileCopySplitSourceUI then
            copyPick_sourceKind = "accountwide"
            copyPick_characterName = nil
            ProfileCopyRebuildCharacterItems()
        else
            ProfileCopyRebuildBucketItems()
            if #bucketItems > 0 then
                local pickB = bucketItems[1].data
                for j = 1, #bucketItems do
                    if bucketItems[j].data == "$AccountWide" then
                        pickB = "$AccountWide"
                        break
                    end
                end
                copyPick_bucket = pickB
            else
                copyPick_bucket = nil
            end
        end
    end

    -- Copies data either to override character's data or creates a new table if no data for that character exists.
    -- Borrowed from Srendarr
    local function CopyTable(src, dest)
        return ZO_DeepTableCopy(src, dest)
    end

    -- Called from Menu by either reset current character or reset account wide settings button.
    local function DeleteCurrentProfile(account)
        local deleteProfile
        if account then
            deleteProfile = table_concat({ "$AccountWide (", GetDisplayName(), ")" })
        else
            deleteProfile = GetUnitName("player")
        end
        for accountName, data in pairs(_G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile]) do
            if data[deleteProfile] then
                data[deleteProfile] = nil
                break
            end
        end
    end

    local function ProfileCopyGetOrCreateLeaf(g, profile, account, bucket)
        if type(g) ~= "table" then
            return nil
        end
        g[profile] = g[profile] or {}
        g[profile][account] = g[profile][account] or {}
        if g[profile][account][bucket] == nil then
            g[profile][account][bucket] = { version = LUIE.SVVer }
        end
        return g[profile][account][bucket]
    end

    local function ProfileCopyIsSameAsTarget()
        local srcBucket = ProfileCopyGetEffectiveSourceBucket()
        local tgtP, tgtA, tgtB = ProfileCopyGetTargetTriple()
        if not (tgtP and tgtA and tgtB) then
            return false
        end
        if not (copyPick_server and copyPick_account and srcBucket) then
            return false
        end
        return copyPick_server == tgtP and copyPick_account == tgtA and srcBucket == tgtB
    end

    local function ProfileCopyIsCopyDisabled()
        local tgtP, tgtA, tgtB = ProfileCopyGetTargetTriple()
        if not (tgtP and tgtA and tgtB) then
            return true
        end
        local srcBucket = ProfileCopyGetEffectiveSourceBucket()
        if not (copyPick_server and copyPick_account and srcBucket) then
            return true
        end
        if profileCopySplitSourceUI and (copyPick_sourceKind or "accountwide") == "character" then
            local _, charVals = ProfileCopyBuildCharacterRowChoices()
            if not copyPick_characterName or not ProfileCopyValueInList(charVals, copyPick_characterName) then
                return true
            end
        end
        if ProfileCopyIsSameAsTarget() then
            return true
        end
        local core = _G[LUIE.SVName]
        local src = core and core[copyPick_server] and core[copyPick_server][copyPick_account] and core[copyPick_server][copyPick_account][srcBucket]
        if type(src) ~= "table" then
            return true
        end
        return false
    end

    local function ProfileCopyExecute()
        local tgtP, tgtA, tgtB = ProfileCopyGetTargetTriple()
        if not (tgtP and tgtA and tgtB) then
            LUIE.ChatOutput:Print(GetString(LUIE_STRING_LAM_PROFILE_COPY_ERROR), true)
            return
        end
        local srcBucket = ProfileCopyGetEffectiveSourceBucket()
        if not (copyPick_server and copyPick_account and srcBucket) then
            LUIE.ChatOutput:Print(GetString(LUIE_STRING_LAM_PROFILE_COPY_ERROR), true)
            return
        end
        if ProfileCopyIsSameAsTarget() then
            return
        end
        local anyCopied = false
        for _, gn in ipairs(ProfileCopyEnumGlobalNames()) do
            local g = _G[gn]
            if type(g) == "table" then
                local srcLeaf = g[copyPick_server] and g[copyPick_server][copyPick_account] and g[copyPick_server][copyPick_account][srcBucket]
                if type(srcLeaf) == "table" then
                    local destLeaf = ProfileCopyGetOrCreateLeaf(g, tgtP, tgtA, tgtB)
                    if type(destLeaf) == "table" then
                        CopyTable(srcLeaf, destLeaf)
                        anyCopied = true
                    end
                end
            end
        end
        if not anyCopied then
            LUIE.ChatOutput:Print(GetString(LUIE_STRING_LAM_PROFILE_COPY_ERROR), true)
            return
        end
        ReloadUI("ingame")
    end

    copyPick_server = ProfileCopyCurrentProfile()
    copyPick_account = nil
    copyPick_bucket = nil
    copyPick_sourceKind = nil
    copyPick_characterName = nil
    do
        local _, accVals = ProfileCopyBuildAccountChoices()
        if #accVals > 0 then
            local preferred = GetDisplayName()
            copyPick_account = ProfileCopyValueInList(accVals, preferred) and preferred or accVals[1]
        end
    end

    ProfileCopyRebuildServerItems()
    ProfileCopyRebuildAccountItems()
    if profileCopySplitSourceUI then
        ProfileCopyInitKindItems()
    end
    ProfileCopyRefreshBucketOrSplitPicks()

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(LUIE.name,
                                {
                                    allowDefaults = false,
                                    allowRefresh = true
                                })

    -- ReloadUI Button
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        clickHandler = function ()
            SettingsAPI:ReloadUIWithPendingClear()
        end
    }

    -- -- Default UI Elements Position Unlock
    -- settingsData[#settingsData + 1] =
    -- {
    --     type = LHAS.ST_CHECKBOX,
    --     label = GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI),
    --     tooltip = GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI_TP),
    --     getFunction = function () return g_ElementMovingEnabled end,
    --     setFunction = function (value)
    --         g_ElementMovingEnabled = value
    --         LUIE.SetupElementMover(value)
    --     end,
    --     default = false,
    --     disable = function () return true end
    -- }

    -- -- Grid Snap Settings
    -- settingsData[#settingsData + 1] =
    -- {
    --     type = LHAS.ST_CHECKBOX,
    --     label = "Enable Grid Snap",
    --     tooltip = "Enable snapping UI elements to a grid when moving them",
    --     getFunction = function () return _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGrid_default end,
    --     setFunction = function (value)
    --         local accountWideSettings = _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"]
    --         accountWideSettings.snapToGrid_default = value
    --         local gridSize = accountWideSettings.snapToGridSize_default or 15
    --         GridOverlay.Refresh("default", g_ElementMovingEnabled and value, gridSize)
    --     end,
    --     default = false
    -- }

    -- -- Grid Size
    -- settingsData[#settingsData + 1] =
    -- {
    --     type = LHAS.ST_SLIDER,
    --     label = "Grid Size",
    --     tooltip = "Set the size of the grid for snapping UI elements",
    --     min = 5,
    --     max = 100,
    --     step = 5,
    --     format = "%.0f",
    --     getFunction = function () return _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGridSize_default or 15 end,
    --     setFunction = function (value)
    --         local accountWideSettings = _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"]
    --         accountWideSettings.snapToGridSize_default = value
    --         GridOverlay.Refresh("default", g_ElementMovingEnabled and accountWideSettings.snapToGrid_default, value)
    --     end,
    --     default = 15,
    --     disable = function () return not _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGrid_default end
    -- }

    -- -- Default UI Elements Position Reset
    -- settingsData[#settingsData + 1] =
    -- {
    --     type = LHAS.ST_BUTTON,
    --     label = GetString(LUIE_STRING_LAM_RESETPOSITION),
    --     tooltip = GetString(LUIE_STRING_LAM_RESET_DEFAULT_UI_TP),
    --     buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
    --     clickHandler = LUIE.ResetElementPosition
    -- }

    local profileSectionRows = {}

    -- Character Profile Settings (submenu)
    profileSectionRows[#profileSectionRows + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE),
        tooltip = zo_strformat("<<1>>\n\n<<2>>", GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE_TP), GetString(LUIE_STRING_LAM_SVPROFILE_DESCRIPTION)),
        getFunction = function () return _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end,
        setFunction = function (value)
            _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].CharacterSpecificSV = value
            ReloadUI("ingame")
        end
    }

    -- Source megaserver (ZO_SavedVars profile)
    profileSectionRows[#profileSectionRows + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SERVER),
        tooltip = zo_strformat("<<1>>\n\n<<2>>\n\n<<3>>", GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY), GetString(LUIE_STRING_LAM_SVPROFILE_COPY_TARGET_DESC), GetString(LUIE_STRING_LAM_SVPROFILE_COPY_CROSS_TP)),
        items = function ()
            ProfileCopyRebuildServerItems()
            return serverItems
        end,
        getFunction = function ()
            ProfileCopyRebuildServerItems()
            for i = 1, #serverItems do
                if serverItems[i].data == copyPick_server then
                    return serverItems[i].name
                end
            end
            if #serverItems > 0 then
                copyPick_server = serverItems[1].data
                return serverItems[1].name
            end
            return ""
        end,
        setFunction = function (combobox, value, item)
            copyPick_server = item.data
            copyPick_account = nil
            copyPick_bucket = nil
            if profileCopySplitSourceUI then
                copyPick_sourceKind = "accountwide"
                copyPick_characterName = nil
            end
            do
                ProfileCopyRebuildAccountItems()
                if #accountItems > 0 then
                    local preferred = GetDisplayName()
                    local pick = accountItems[1].data
                    for j = 1, #accountItems do
                        if accountItems[j].data == preferred then
                            pick = preferred
                            break
                        end
                    end
                    copyPick_account = pick
                end
            end
            ProfileCopyRefreshBucketOrSplitPicks()
        end
    }

    -- Source @account
    profileSectionRows[#profileSectionRows + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_ACCOUNT),
        tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_ACCOUNT_TP),
        items = function ()
            ProfileCopyRebuildAccountItems()
            return accountItems
        end,
        getFunction = function ()
            ProfileCopyRebuildAccountItems()
            for i = 1, #accountItems do
                if accountItems[i].data == copyPick_account then
                    return accountItems[i].name
                end
            end
            if #accountItems > 0 then
                local preferred = GetDisplayName()
                for j = 1, #accountItems do
                    if accountItems[j].data == preferred then
                        copyPick_account = preferred
                        return accountItems[j].name
                    end
                end
                copyPick_account = accountItems[1].data
                return accountItems[1].name
            end
            return ""
        end,
        setFunction = function (combobox, value, item)
            copyPick_account = item.data
            copyPick_bucket = nil
            if profileCopySplitSourceUI then
                copyPick_sourceKind = "accountwide"
                copyPick_characterName = nil
            end
            ProfileCopyRefreshBucketOrSplitPicks()
        end
    }

    if profileCopySplitSourceUI then
        profileSectionRows[#profileSectionRows + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SOURCE_KIND),
            tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SOURCE_KIND_TP),
            items = function ()
                ProfileCopyInitKindItems()
                return kindItems
            end,
            getFunction = function ()
                ProfileCopyInitKindItems()
                local kind = copyPick_sourceKind or "accountwide"
                for i = 1, #kindItems do
                    if kindItems[i].data == kind then
                        return kindItems[i].name
                    end
                end
                copyPick_sourceKind = "accountwide"
                return kindItems[1].name
            end,
            setFunction = function (combobox, value, item)
                copyPick_sourceKind = item.data
                copyPick_characterName = nil
                ProfileCopyRebuildCharacterItems()
            end
        }

        profileSectionRows[#profileSectionRows + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SOURCE_CHARACTER),
            tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SOURCE_CHARACTER_TP),
            items = function ()
                ProfileCopyRebuildCharacterItems()
                return characterItems
            end,
            getFunction = function ()
                ProfileCopyRebuildCharacterItems()
                local _, values = ProfileCopyBuildCharacterRowChoices()
                if #values == 0 then
                    return ""
                end
                if (copyPick_sourceKind or "accountwide") ~= "character" then
                    return characterItems[1] and characterItems[1].name or values[1]
                end
                for i = 1, #characterItems do
                    if characterItems[i].data == copyPick_characterName then
                        return characterItems[i].name
                    end
                end
                copyPick_characterName = characterItems[1].data
                return characterItems[1].name
            end,
            setFunction = function (combobox, value, item)
                copyPick_characterName = item.data
            end,
            disable = function ()
                return (copyPick_sourceKind or "accountwide") ~= "character"
            end
        }
    else
        -- Source row ($AccountWide or character) — single list when not using character-specific saved vars
        profileSectionRows[#profileSectionRows + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_BUCKET),
            tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_COPY_BUCKET_TP),
            items = function ()
                ProfileCopyRebuildBucketItems()
                return bucketItems
            end,
            getFunction = function ()
                ProfileCopyRebuildBucketItems()
                for i = 1, #bucketItems do
                    if copyPick_bucket and bucketItems[i].data == copyPick_bucket then
                        return bucketItems[i].name
                    end
                end
                local _, bucketVals = ProfileCopyBuildBucketChoices()
                if #bucketVals == 0 then
                    return ""
                end
                if ProfileCopyValueInList(bucketVals, "$AccountWide") then
                    copyPick_bucket = "$AccountWide"
                else
                    copyPick_bucket = bucketVals[1]
                end
                for j = 1, #bucketItems do
                    if bucketItems[j].data == copyPick_bucket then
                        return bucketItems[j].name
                    end
                end
                copyPick_bucket = bucketItems[1].data
                return bucketItems[1].name
            end,
            setFunction = function (combobox, value, item)
                copyPick_bucket = item.data
            end
        }
    end

    -- Copy Profile Button
    profileSectionRows[#profileSectionRows + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON),
        tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON_TP),
        buttonText = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON),
        clickHandler = ProfileCopyExecute,
        disable = ProfileCopyIsCopyDisabled
    }

    -- Reset Current Character Settings Button
    profileSectionRows[#profileSectionRows + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR),
        tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR_TP),
        buttonText = GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR),
        clickHandler = function ()
            DeleteCurrentProfile(false)
            ReloadUI("ingame")
        end,
        disable = function () return not _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end
    }

    -- Reset Account Wide Settings Button
    profileSectionRows[#profileSectionRows + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT),
        tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT_TP),
        buttonText = GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT),
        clickHandler = function ()
            DeleteCurrentProfile(true)
            ReloadUI("ingame")
        end
    }

    SettingsAPI:AppendSection(settingsData, GetString(LUIE_STRING_LAM_SVPROFILE_HEADER), profileSectionRows)

    local chatOutputSectionRows = {}
    LUIE.AppendChatOutputConsoleControls(chatOutputSectionRows, LHAS, { omitSectionHeader = true })
    SettingsAPI:AppendSection(settingsData, GetString(LUIE_STRING_LAM_CHATOUTPUT_HEADER), chatOutputSectionRows)
    SettingsAPI:AppendSection(settingsData, GetString(LUIE_STRING_LAM_MODULEHEADER), nil, { subMenu = false })

    -- Unit Frames Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_UF_ENABLE),
        tooltip = GetString(LUIE_STRING_LAM_UF_DESCRIPTION),
        getFunction = function () return Settings.UnitFrames_Enabled end,
        setFunction = function (value) Settings.UnitFrames_Enabled = value end,
        default = Defaults.UnitFrames_Enabled
    }

    -- Action Bar Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_AB_SHOWACTIONBAR),
        tooltip = GetString(LUIE_STRING_LAM_AB_DESCRIPTION),
        getFunction = function () return Settings.ActionBar_Enabled end,
        setFunction = function (value) Settings.ActionBar_Enabled = value end,
        default = Defaults.ActionBar_Enabled
    }

    -- Combat Info Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CI_SHOWCOMBATINFO),
        tooltip = GetString(LUIE_STRING_LAM_CI_DESCRIPTION),
        getFunction = function () return Settings.CombatInfo_Enabled end,
        setFunction = function (value) Settings.CombatInfo_Enabled = value end,
        default = Defaults.CombatInfo_Enabled
    }

    -- Combat Text Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CT_SHOWCOMBATTEXT),
        tooltip = GetString(LUIE_STRING_LAM_CT_DESCRIPTION),
        getFunction = function () return Settings.CombatText_Enabled end,
        setFunction = function (value) Settings.CombatText_Enabled = value end,
        default = Defaults.CombatText_Enabled
    }

    -- Buffs & Debuffs Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_BUFF_ENABLEEFFECTSTRACK),
        tooltip = GetString(LUIE_STRING_LAM_BUFFS_DESCRIPTION),
        getFunction = function () return Settings.SpellCastBuff_Enable end,
        setFunction = function (value) Settings.SpellCastBuff_Enable = value end,
        default = Defaults.SpellCastBuff_Enable
    }

    -- Chat Announcements Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CA_ENABLE),
        tooltip = GetString(LUIE_STRING_LAM_CA_DESCRIPTION),
        getFunction = function () return Settings.ChatAnnouncements_Enable end,
        setFunction = function (value) Settings.ChatAnnouncements_Enable = value end,
        default = Defaults.ChatAnnouncements_Enable
    }

    -- Slash Commands Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_SLASHCMDS_ENABLE),
        tooltip = GetString(LUIE_STRING_LAM_SLASHCMDS_DESCRIPTION),
        getFunction = function () return Settings.SlashCommands_Enable end,
        setFunction = function (value) Settings.SlashCommands_Enable = value end,
        default = Defaults.SlashCommands_Enable
    }

    -- Show InfoPanel
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_PNL_ENABLE),
        tooltip = GetString(LUIE_STRING_LAM_PNL_DESCRIPTION),
        getFunction = function () return Settings.InfoPanel_Enabled end,
        setFunction = function (value) Settings.InfoPanel_Enabled = value end,
        default = Defaults.InfoPanel_Enabled
    }

    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_MINIMAP_ENABLE),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ENABLE_TP),
        getFunction = function () return Settings.MiniMap_Enabled end,
        setFunction = function (value) Settings.MiniMap_Enabled = value end,
        default = Defaults.MiniMap_Enabled
    }

    -- Misc Settings
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_MISCHEADER)
    }

    local alertAlignmentItems =
    {
        { name = "LEFT",   data = 1 },
        { name = "CENTER", data = 2 },
        { name = "RIGHT",  data = 3 },
    }

    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_ALERT_TEXT_ALIGNMENT),
        tooltip = GetString(LUIE_STRING_LAM_ALERT_TEXT_ALIGNMENT_TP),
        items = alertAlignmentItems,
        getFunction = function ()
            local index = Settings.AlertFrameAlignment or Defaults.AlertFrameAlignment
            for _, item in ipairs(alertAlignmentItems) do
                if item.data == index then
                    return item.name
                end
            end
            return "RIGHT"
        end,
        setFunction = function (combobox, value, item)
            Settings.AlertFrameAlignment = item.data
            LUIE.ApplyAlertFrameAlignment()
        end,
        default = alertAlignmentItems[Defaults.AlertFrameAlignment].name,
        disable = function ()
            return Settings.HideAlertFrame
        end,
    }

    -- Hide Alerts
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_ALERT_HIDE_ALL),
        tooltip = GetString(LUIE_STRING_LAM_ALERT_HIDE_ALL_TP),
        getFunction = function () return Settings.HideAlertFrame end,
        setFunction = function (value)
            Settings.HideAlertFrame = value
            LUIE.SetupAlertFrameVisibility()
        end,
        default = Defaults.HideAlertFrame
    }

    -- Toggle XP Bar popup
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_HIDE_EXPERIENCE_BAR),
        tooltip = GetString(LUIE_STRING_LAM_HIDE_EXPERIENCE_BAR_TP),
        getFunction = function () return Settings.HideXPBar end,
        setFunction = function (value) Settings.HideXPBar = value end,
        default = Defaults.HideXPBar
    }

    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_SUPPRESS_ZO_BUFFDEBUFF_WHEN_HIDDEN),
        tooltip = zo_strformat("<<1>> <<2>>", LUIE.GetLAMSuppressZOBuffDebuffWhenHiddenTooltip(), GetString(LUIE_STRING_LAM_RELOADUI_WARNING)),
        getFunction = function () return Settings.SuppressZOBuffDebuffWhenHidden end,
        setFunction = function (value) Settings.SuppressZOBuffDebuffWhenHidden = value end,
        default = Defaults.SuppressZOBuffDebuffWhenHidden
    }

    -- Startup Message Options
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_STARTUPMSG),
        tooltip = GetString(LUIE_STRING_LAM_STARTUPMSG_TP),
        getFunction = function () return Settings.StartupInfo end,
        setFunction = function (value) Settings.StartupInfo = value end,
        default = Defaults.StartupInfo
    }

    -- Custom Icons
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_MISSING_CUSTOM_ICONS),
        tooltip = GetString(LUIE_STRING_LAM_MISSING_CUSTOM_ICONS_TP),
        getFunction = function () return Settings.CustomIcons end,
        setFunction = function (value) Settings.CustomIcons = value end,
        default = Defaults.CustomIcons
    }

    -- Add all settings to the panel
    panel:AddSettings(settingsData)

    LUIE.consoleMainSettingsPanel = panel
    local chatOutputHeader = GetString(LUIE_STRING_LAM_CHATOUTPUT_HEADER)
    for i = 1, #panel.settings do
        local setting = panel.settings[i]
        if setting.type == LHAS.ST_SECTION and setting.labelText == chatOutputHeader then
            LUIE.consoleChatOutputSectionSetting = setting
            break
        end
    end
end
