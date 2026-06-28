-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local g_ElementMovingEnabled

local GridOverlay = LUIE.GridOverlay

local pairs = pairs
local ipairs = ipairs
local type = type
local table_concat = table.concat
local table_sort = table.sort
local wm = WINDOW_MANAGER

-- Load Settings API
local SettingsAPI = LUIE.SettingsAPI

-- Load LibAddonMenu
local LAM = LUIE.LAM

local MISSING_SCREENSHOT_FORMAT_VALUES = { "JPG", "PNG", "BMP" }

local MISSING_SPEAKER_SETUP_VALUES =
{
    "Use Windows Setting",
    "Mono",
    "Stereo",
    "2.1",
    "4.0",
    "4.1",
    "5.0",
    "5.1",
    "7.1",
}

local MISSING_SPEAKER_SETUP_BY_VALUE =
{
    ["Use Windows Setting"] = 0,
    ["Mono"] = 1,
    ["Stereo"] = 2,
    ["2.1"] = 3,
    ["4.0"] = 4,
    ["4.1"] = 5,
    ["5.0"] = 6,
    ["5.1"] = 7,
    ["7.1"] = 8,
}

local MISSING_SPATIAL_SOUND_QUALITY_VALUES = { "Low", "High" }

local function GetMissingScreenshotFormatChoices()
    return MISSING_SCREENSHOT_FORMAT_VALUES
end

local function GetMissingSpeakerSetupChoices()
    return
    {
        GetString(LUIE_STRING_LAM_MISSING_SPEAKER_USE_WINDOWS),
        GetString(LUIE_STRING_LAM_MISSING_SPEAKER_MONO),
        GetString(LUIE_STRING_LAM_MISSING_SPEAKER_STEREO),
        "2.1",
        "4.0",
        "4.1",
        "5.0",
        "5.1",
        "7.1",
    }
end

local function GetMissingSpeakerSetupFromCVar()
    local config = tonumber(GetCVar("SPEAKER_SETUP")) or 0
    return MISSING_SPEAKER_SETUP_VALUES[config + 1] or MISSING_SPEAKER_SETUP_VALUES[1]
end

local function GetMissingSpatialSoundQualityChoices()
    return
    {
        GetString(LUIE_STRING_LAM_MISSING_QUALITY_LOW),
        GetString(LUIE_STRING_LAM_MISSING_QUALITY_HIGH),
    }
end

local function GetMissingSpatialSoundQualityFromCVar()
    local quality = tonumber(GetCVar("SPATIAL_SOUND_QUALITY")) or 0
    return quality == 1 and "High" or "Low"
end

-- Create Settings Menu
function LUIE.CreateSettings()
    local Defaults = LUIE.Defaults
    local Settings = LUIE.SV

    local optionsData = {}

    -- SavedVariables profile copy: megaserver (ZO profile) -> @account -> $AccountWide or character row; applies to LUIESV + all module globals in LUIE.ModuleSavedVarNames.
    local copyPick_server
    local copyPick_account
    local copyPick_bucket
    local copyPick_sourceKind
    local copyPick_characterName

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

    local function ProfileCopyRefreshBucketDropdown()
        copyPick_bucket = nil
        local ctrl = wm:GetControlByName("LUIE_LAM_ProfileCopy_Bucket") --- @type LUIE_LAM_ProfileCopy_Bucket
        if not (ctrl and ctrl.UpdateChoices) then
            return
        end
        local labels, values = ProfileCopyBuildBucketChoices()
        ctrl.data.choices = labels
        ctrl.data.choicesValues = values
        ctrl:UpdateChoices(labels, values)
        ctrl:UpdateValue()
    end

    local function ProfileCopyRefreshCharacterDropdownOnly()
        local charCtrl = wm:GetControlByName("LUIE_LAM_ProfileCopy_SourceCharacter") --- @type LUIE_LAM_ProfileCopy_SourceCharacter
        if not (charCtrl and charCtrl.UpdateChoices) then
            return
        end
        local labels, values = ProfileCopyBuildCharacterRowChoices()
        charCtrl.data.choices = labels
        charCtrl.data.choicesValues = values
        charCtrl:UpdateChoices(labels, values)
        charCtrl:UpdateValue()
    end

    local function ProfileCopyRefreshSourceRowDropdowns()
        if profileCopySplitSourceUI then
            copyPick_characterName = nil
            ProfileCopyRefreshCharacterDropdownOnly()
            local kindCtrl = wm:GetControlByName("LUIE_LAM_ProfileCopy_SourceKind") --- @type LUIE_LAM_ProfileCopy_SourceKind
            if kindCtrl and kindCtrl.UpdateValue then
                kindCtrl:UpdateValue()
            end
        else
            ProfileCopyRefreshBucketDropdown()
        end
    end

    local function ProfileCopyRefreshAccountDropdown()
        copyPick_account = nil
        copyPick_bucket = nil
        if profileCopySplitSourceUI then
            copyPick_sourceKind = "accountwide"
            copyPick_characterName = nil
        end
        local ctrl = wm:GetControlByName("LUIE_LAM_ProfileCopy_Account") --- @type LUIE_LAM_ProfileCopy_Account
        if not (ctrl and ctrl.UpdateChoices) then
            return
        end
        local labels, values = ProfileCopyBuildAccountChoices()
        ctrl.data.choices = labels
        ctrl.data.choicesValues = values
        ctrl:UpdateChoices(labels, values)
        ctrl:UpdateValue()
        ProfileCopyRefreshSourceRowDropdowns()
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

    local initialServerLabels, initialServerValues = ProfileCopyBuildServerChoices()
    local initialAccountLabels, initialAccountValues = ProfileCopyBuildAccountChoices()
    local initialBucketLabels, initialBucketValues
    local initialKindLabels, initialKindValues
    local initialCharacterLabels, initialCharacterValues
    if profileCopySplitSourceUI then
        copyPick_sourceKind = "accountwide"
        initialKindLabels =
        {
            GetString(LUIE_STRING_LAM_SVPROFILE_COPY_KIND_ACCOUNTWIDE),
            GetString(LUIE_STRING_LAM_SVPROFILE_COPY_KIND_CHARACTER),
        }
        initialKindValues = { "accountwide", "character" }
        initialCharacterLabels, initialCharacterValues = ProfileCopyBuildCharacterRowChoices()
    else
        initialBucketLabels, initialBucketValues = ProfileCopyBuildBucketChoices()
        do
            if #initialBucketValues > 0 then
                if ProfileCopyValueInList(initialBucketValues, "$AccountWide") then
                    copyPick_bucket = "$AccountWide"
                else
                    copyPick_bucket = initialBucketValues[1]
                end
            end
        end
    end

    local panelData =
    {
        type = "panel",
        name = LUIE.name,
        displayName = LUIE.name,
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luiset",
        registerForRefresh = true,
        registerForDefaults = false,
    }

    -- Changelog Button
    optionsData[#optionsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CHANGELOG),
        GetString(LUIE_STRING_LAM_CHANGELOG_TP),
        function ()
            if not Settings.ShowChangeLog then
                return
            end
            SCENE_MANAGER:ShowBaseScene()
            LUIE.ToggleChangelog(false)
        end,
        "half",
        function () return not Settings.ShowChangeLog end
    )

    -- ReloadUI Button
    optionsData[#optionsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function () ReloadUI("ingame") end,
        "half"
    )

    -- Default UI Elements Position Unlock
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI),
        GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI_TP),
        function () return g_ElementMovingEnabled end,
        function (value)
            g_ElementMovingEnabled = value
            LUIE.SetupElementMover(value)
        end,
        "half",
        nil,
        false,
        nil,
        nil,
        LUIE.ResetElementPosition
    )

    -- Grid Snap Settings
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_SHARED_GRID_SNAP_ENABLE), GetString(LUIE_STRING_SHARED_MODULE_DEFAULT_UI)),
        zo_strformat(GetString(LUIE_STRING_SHARED_GRID_SNAP_ENABLE_TP), GetString(LUIE_STRING_SHARED_MODULE_DEFAULT_UI)),
        function () return _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGrid_default end,
        function (value)
            local accountWideSettings = _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGrid_default = value
            local gridSize = accountWideSettings.snapToGridSize_default or 15
            GridOverlay.Refresh("default", g_ElementMovingEnabled and value, gridSize)
        end,
        "half",
        nil,
        false
    )

    -- Grid Size
    optionsData[#optionsData + 1] = SettingsAPI.CreateSliderOption(
        zo_strformat(GetString(LUIE_STRING_SHARED_GRID_SNAP_SIZE), GetString(LUIE_STRING_SHARED_MODULE_DEFAULT_UI)),
        zo_strformat(GetString(LUIE_STRING_SHARED_GRID_SNAP_SIZE_TP), GetString(LUIE_STRING_SHARED_MODULE_DEFAULT_UI)),
        5,
        100,
        5,
        function () return _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGridSize_default or 15 end,
        function (value)
            local accountWideSettings = _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGridSize_default = value
            GridOverlay.Refresh("default", g_ElementMovingEnabled and accountWideSettings.snapToGrid_default, value)
        end,
        "half",
        function () return not _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGrid_default end,
        15
    )

    -- Default UI Elements Position Reset
    optionsData[#optionsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RESETPOSITION),
        GetString(LUIE_STRING_LAM_RESET_DEFAULT_UI_TP),
        LUIE.ResetElementPosition,
        "half",
        nil,
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON)
    )

    -- Character Profile Settings Submenu
    local profileControls = {}

    -- Character Profile Description
    profileControls[#profileControls + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_DESCRIPTION)
    )

    -- Use Character Specific Settings Toggle
    profileControls[#profileControls + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE),
        GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE_TP),
        function () return _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end,
        function (value)
            _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].CharacterSpecificSV = value
            ReloadUI("ingame")
        end,
        "full",
        nil,
        nil,
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON)
    )

    -- Profile copy (source path + target / cross-megaserver notes)
    profileControls[#profileControls + 1] = SettingsAPI.CreateDescriptionOption(
        zo_strformat("<<1>>\n\n<<2>>\n\n<<3>>", GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY), GetString(LUIE_STRING_LAM_SVPROFILE_COPY_TARGET_DESC), GetString(LUIE_STRING_LAM_SVPROFILE_COPY_CROSS_TP))
    )

    -- Source megaserver (ZO_SavedVars profile)
    local serverDropdown = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SERVER),
        GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SERVER_TP),
        initialServerLabels,
        function ()
            local _, values = ProfileCopyBuildServerChoices()
            if #values == 0 then
                copyPick_server = ProfileCopyCurrentProfile()
                return copyPick_server
            end
            if not copyPick_server or not ProfileCopyValueInList(values, copyPick_server) then
                copyPick_server = values[1]
            end
            return copyPick_server
        end,
        function (value)
            copyPick_server = value
            copyPick_account = nil
            copyPick_bucket = nil
            zo_callLater(ProfileCopyRefreshAccountDropdown, 0)
        end,
        "full",
        nil,
        nil,
        nil,
        "name-up",
        nil,
        initialServerValues,
        7
    )
    serverDropdown.reference = "LUIE_LAM_ProfileCopy_Server"
    profileControls[#profileControls + 1] = serverDropdown

    -- Source @account
    local accountDropdown = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_COPY_ACCOUNT),
        GetString(LUIE_STRING_LAM_SVPROFILE_COPY_ACCOUNT_TP),
        initialAccountLabels,
        function ()
            local _, values = ProfileCopyBuildAccountChoices()
            if #values == 0 then
                copyPick_account = nil
                return nil
            end
            if not copyPick_account or not ProfileCopyValueInList(values, copyPick_account) then
                local preferred = GetDisplayName()
                if ProfileCopyValueInList(values, preferred) then
                    copyPick_account = preferred
                else
                    copyPick_account = values[1]
                end
            end
            return copyPick_account
        end,
        function (value)
            copyPick_account = value
            copyPick_bucket = nil
            zo_callLater(ProfileCopyRefreshSourceRowDropdowns, 0)
        end,
        "full",
        nil,
        nil,
        nil,
        "name-up",
        nil,
        initialAccountValues,
        7
    )
    accountDropdown.reference = "LUIE_LAM_ProfileCopy_Account"
    profileControls[#profileControls + 1] = accountDropdown

    if profileCopySplitSourceUI then
        local kindDropdown = SettingsAPI.CreateDropdownOption(
            GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SOURCE_KIND),
            GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SOURCE_KIND_TP),
            initialKindLabels,
            function ()
                if not copyPick_sourceKind or not ProfileCopyValueInList(initialKindValues, copyPick_sourceKind) then
                    copyPick_sourceKind = "accountwide"
                end
                return copyPick_sourceKind
            end,
            function (value)
                copyPick_sourceKind = value
                copyPick_characterName = nil
                zo_callLater(ProfileCopyRefreshCharacterDropdownOnly, 0)
            end,
            "full",
            nil,
            nil,
            nil,
            nil,
            nil,
            initialKindValues,
            7
        )
        kindDropdown.reference = "LUIE_LAM_ProfileCopy_SourceKind"
        profileControls[#profileControls + 1] = kindDropdown

        local charDropdown = SettingsAPI.CreateDropdownOption(
            GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SOURCE_CHARACTER),
            GetString(LUIE_STRING_LAM_SVPROFILE_COPY_SOURCE_CHARACTER_TP),
            initialCharacterLabels,
            function ()
                local _, values = ProfileCopyBuildCharacterRowChoices()
                if #values == 0 then
                    copyPick_characterName = nil
                    return nil
                end
                if (copyPick_sourceKind or "accountwide") ~= "character" then
                    return values[1]
                end
                if not copyPick_characterName or not ProfileCopyValueInList(values, copyPick_characterName) then
                    copyPick_characterName = values[1]
                end
                return copyPick_characterName
            end,
            function (value)
                copyPick_characterName = value
            end,
            "full",
            function ()
                return (copyPick_sourceKind or "accountwide") ~= "character"
            end,
            nil,
            nil,
            nil,
            nil,
            initialCharacterValues,
            7
        )
        charDropdown.reference = "LUIE_LAM_ProfileCopy_SourceCharacter"
        profileControls[#profileControls + 1] = charDropdown
    else
        -- Source row ($AccountWide or character) — single list when not using character-specific saved vars
        local bucketDropdown = SettingsAPI.CreateDropdownOption(
            GetString(LUIE_STRING_LAM_SVPROFILE_COPY_BUCKET),
            GetString(LUIE_STRING_LAM_SVPROFILE_COPY_BUCKET_TP),
            initialBucketLabels,
            function ()
                local _, values = ProfileCopyBuildBucketChoices()
                if #values == 0 then
                    copyPick_bucket = nil
                    return nil
                end
                if not copyPick_bucket or not ProfileCopyValueInList(values, copyPick_bucket) then
                    if ProfileCopyValueInList(values, "$AccountWide") then
                        copyPick_bucket = "$AccountWide"
                    else
                        copyPick_bucket = values[1]
                    end
                end
                return copyPick_bucket
            end,
            function (value)
                copyPick_bucket = value
            end,
            "full",
            nil,
            nil,
            nil,
            nil,
            nil,
            initialBucketValues,
            7
        )
        bucketDropdown.reference = "LUIE_LAM_ProfileCopy_Bucket"
        profileControls[#profileControls + 1] = bucketDropdown
    end

    -- Copy Profile Button
    profileControls[#profileControls + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON),
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON_TP),
        ProfileCopyExecute,
        "full",
        ProfileCopyIsCopyDisabled,
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON)
    )

    -- Reset Current Character Settings Button
    profileControls[#profileControls + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR),
        GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR_TP),
        function ()
            DeleteCurrentProfile(false)
            ReloadUI("ingame")
        end,
        "half",
        function () return not _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end,
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON)
    )

    -- Reset Account Wide Settings Button
    profileControls[#profileControls + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT),
        GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT_TP),
        function ()
            DeleteCurrentProfile(true)
            ReloadUI("ingame")
        end,
        "half",
        nil,
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON)
    )

    optionsData[#optionsData + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_HEADER),
        profileControls
    )

    optionsData[#optionsData + 1] = SettingsAPI.CreateSubmenuOption(
        GetString(LUIE_STRING_LAM_CHATOUTPUT_HEADER),
        LUIE.BuildChatOutputLAMControls(SettingsAPI)
    )

    -- Modules Header
    optionsData[#optionsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_MODULEHEADER)
    )

    -- Action Bar Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_AB_SHOWACTIONBAR),
        nil,
        function () return Settings.ActionBar_Enabled end,
        function (value) Settings.ActionBar_Enabled = value end,
        "half",
        nil,
        Defaults.ActionBar_Enabled,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Action Bar Description
    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_AB_DESCRIPTION),
        "half"
    )

    -- Combat Info Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_SHOWCOMBATINFO),
        nil,
        function () return Settings.CombatInfo_Enabled end,
        function (value) Settings.CombatInfo_Enabled = value end,
        "half",
        nil,
        Defaults.CombatInfo_Enabled,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Combat Info Description
    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CI_DESCRIPTION),
        "half"
    )

    -- Combat Text Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_SHOWCOMBATTEXT),
        nil,
        function () return Settings.CombatText_Enabled end,
        function (value) Settings.CombatText_Enabled = value end,
        "half",
        nil,
        Defaults.CombatText_Enabled,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Combat Text Description
    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_DESCRIPTION),
        "half"
    )

    -- Buffs & Debuffs Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_BUFF_ENABLEEFFECTSTRACK),
        nil,
        function () return Settings.SpellCastBuff_Enable end,
        function (value) Settings.SpellCastBuff_Enable = value end,
        "half",
        nil,
        Defaults.SpellCastBuff_Enable,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Buffs & Debuffs Description
    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_BUFFS_DESCRIPTION),
        "half"
    )

    -- Chat Announcements Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ENABLE),
        nil,
        function () return Settings.ChatAnnouncements_Enable end,
        function (value) Settings.ChatAnnouncements_Enable = value end,
        "half",
        nil,
        Defaults.ChatAnnouncements_Enable,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Chat Announcements Module Description
    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CA_DESCRIPTION),
        "half"
    )

    -- Slash Commands Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_ENABLE),
        nil,
        function () return Settings.SlashCommands_Enable end,
        function (value) Settings.SlashCommands_Enable = value end,
        "half",
        nil,
        Defaults.SlashCommands_Enable,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Slash Commands Module Description
    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DESCRIPTION),
        "half"
    )

    -- Show InfoPanel
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_ENABLE),
        nil,
        function () return Settings.InfoPanel_Enabled end,
        function (value) Settings.InfoPanel_Enabled = value end,
        "half",
        nil,
        Defaults.InfoPanel_Enabled,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- InfoPanel Module Description
    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_PNL_DESCRIPTION),
        "half"
    )

    -- MiniMap Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_MINIMAP_ENABLE),
        GetString(LUIE_STRING_LAM_MINIMAP_ENABLE_TP),
        function () return Settings.MiniMap_Enabled end,
        function (value) Settings.MiniMap_Enabled = value end,
        "half",
        nil,
        Defaults.MiniMap_Enabled,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_MINIMAP_DESCRIPTION),
        "half"
    )

    -- Unit Frames Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_ENABLE),
        nil,
        function () return Settings.UnitFrames_Enabled end,
        function (value) Settings.UnitFrames_Enabled = value end,
        "half",
        nil,
        Defaults.UnitFrames_Enabled,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Unit Frames module description
    optionsData[#optionsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_UF_DESCRIPTION),
        "half"
    )

    -- Misc Settings
    optionsData[#optionsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_MISCHEADER)
    )

    -- Show Changelog
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CHANGELOG),
        GetString(LUIE_STRING_LAM_CHANGELOG_TP),
        function () return Settings.ShowChangeLog end,
        function (value) Settings.ShowChangeLog = value end,
        "full",
        nil,
        Defaults.ShowChangeLog,
        nil,
        true
    )

    local alertAlignmentOptions = { "LEFT", "CENTER", "RIGHT" }
    local alertAlignmentOptionsKeys = { ["LEFT"] = 1, ["CENTER"] = 2, ["RIGHT"] = 3 }

    optionsData[#optionsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_ALERT_TEXT_ALIGNMENT),
        GetString(LUIE_STRING_LAM_ALERT_TEXT_ALIGNMENT_TP),
        alertAlignmentOptions,
        function ()
            local index = Settings.AlertFrameAlignment or Defaults.AlertFrameAlignment
            return alertAlignmentOptions[index] or alertAlignmentOptions[3]
        end,
        function (value)
            Settings.AlertFrameAlignment = alertAlignmentOptionsKeys[value] or 3
            LUIE.ApplyAlertFrameAlignment()
        end,
        "full",
        function () return Settings.HideAlertFrame end,
        alertAlignmentOptions[Defaults.AlertFrameAlignment]
    )

    -- Hide Alerts
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_ALERT_HIDE_ALL),
        GetString(LUIE_STRING_LAM_ALERT_HIDE_ALL_TP),
        function () return Settings.HideAlertFrame end,
        function (value)
            Settings.HideAlertFrame = value
            LUIE.SetupAlertFrameVisibility()
        end,
        "full",
        nil,
        Defaults.HideAlertFrame
    )

    -- Toggle XP Bar popup
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_HIDE_EXPERIENCE_BAR),
        GetString(LUIE_STRING_LAM_HIDE_EXPERIENCE_BAR_TP),
        function () return Settings.HideXPBar end,
        function (value) Settings.HideXPBar = value end,
        "full",
        nil,
        Defaults.HideXPBar
    )

    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SUPPRESS_ZO_BUFFDEBUFF_WHEN_HIDDEN),
        LUIE.GetLAMSuppressZOBuffDebuffWhenHiddenTooltip(),
        function () return Settings.SuppressZOBuffDebuffWhenHidden end,
        function (value) Settings.SuppressZOBuffDebuffWhenHidden = value end,
        "full",
        nil,
        Defaults.SuppressZOBuffDebuffWhenHidden,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
        true
    )

    -- Startup Message Options
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_STARTUPMSG),
        GetString(LUIE_STRING_LAM_STARTUPMSG_TP),
        function () return Settings.StartupInfo end,
        function (value) Settings.StartupInfo = value end,
        "full",
        nil,
        Defaults.StartupInfo
    )

    -- Custom Icons
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_MISSING_CUSTOM_ICONS),
        GetString(LUIE_STRING_LAM_MISSING_CUSTOM_ICONS_TP),
        function () return Settings.CustomIcons end,
        function (value) Settings.CustomIcons = value end,
        "full",
        nil,
        Defaults.CustomIcons,
        nil,
        true
    )

    -- Missing Base Game Settings
    optionsData[#optionsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_MISSINGBASEGAMESETTINGS)
    )

    -- Energy Sustainability
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_MISSING_ENERGY_SUSTAINABILITY),
        GetString(LUIE_STRING_LAM_MISSING_ENERGY_SUSTAINABILITY_TP),
        function () return GetCVar("EnergySustainabilityMeasuresEnabled") == "1" end,
        function (value) SetCVar("EnergySustainabilityMeasuresEnabled", value and "1" or "0") end,
        "full",
        nil,
        false
    )

    -- FPS Limit
    optionsData[#optionsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_MISSING_FPS_LIMIT),
        GetString(LUIE_STRING_LAM_MISSING_FPS_LIMIT_TP),
        1,
        999,
        1,
        function ()
            local minFrameTime = tonumber(GetCVar("MinFrameTime.2"))
            return minFrameTime and zo_floor(1 / minFrameTime + 0.5) or 100
        end,
        function (value)
            local minFrameTime = string.format("%.8f", 1 / value)
            SetCVar("MinFrameTime.2", minFrameTime)
        end,
        "full",
        nil,
        100
    )

    -- Skip Pregame Videos
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_MISSING_SKIP_PREGAME_VIDEOS),
        GetString(LUIE_STRING_LAM_MISSING_SKIP_PREGAME_VIDEOS_TP),
        function () return GetCVar("SkipPregameVideos") == "1" end,
        function (value) SetCVar("SkipPregameVideos", value and "1" or "0") end,
        "full",
        nil,
        true
    )

    -- Raw Mouse Input
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_MISSING_RAW_MOUSE_INPUT),
        GetString(LUIE_STRING_LAM_MISSING_RAW_MOUSE_INPUT_TP),
        function () return GetCVar("MouseRawInput") == "1" end,
        function (value) SetCVar("MouseRawInput", value and "1" or "0") end,
        "full",
        nil,
        true
    )

    -- Screenshot Format
    optionsData[#optionsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_MISSING_SCREENSHOT_FORMAT),
        GetString(LUIE_STRING_LAM_MISSING_SCREENSHOT_FORMAT_TP),
        GetMissingScreenshotFormatChoices(),
        function ()
            local format = GetCVar("ScreenshotFormat.2")
            if format == "PNG" then
                return "PNG"
            elseif format == "BMP" then
                return "BMP"
            else
                return "JPG"
            end
        end,
        function (value) SetCVar("ScreenshotFormat.2", value) end,
        "full",
        nil,
        "PNG",
        nil,
        nil,
        nil,
        MISSING_SCREENSHOT_FORMAT_VALUES
    )

    -- Disable Razer Chroma
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_MISSING_DISABLE_RAZER_CHROMA),
        GetString(LUIE_STRING_LAM_MISSING_DISABLE_RAZER_CHROMA_TP),
        function () return GetCVar("UseChromaIfAvailable") == "0" end,
        function (value) SetCVar("UseChromaIfAvailable", value and "0" or "1") end,
        "full",
        nil,
        true
    )

    -- Speaker Setup
    optionsData[#optionsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_MISSING_SPEAKER_SETUP),
        GetString(LUIE_STRING_LAM_MISSING_SPEAKER_SETUP_TP),
        GetMissingSpeakerSetupChoices(),
        function ()
            return GetMissingSpeakerSetupFromCVar()
        end,
        function (value)
            SetCVar("SPEAKER_SETUP", tostring(MISSING_SPEAKER_SETUP_BY_VALUE[value] or 0))
        end,
        "full",
        nil,
        "Use Windows Setting",
        nil,
        nil,
        nil,
        MISSING_SPEAKER_SETUP_VALUES
    )

    -- Spatial Sound
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_MISSING_SPATIAL_SOUND),
        GetString(LUIE_STRING_LAM_MISSING_SPATIAL_SOUND_TP),
        function () return GetCVar("SPATIAL_SOUND") == "1" end,
        function (value) SetCVar("SPATIAL_SOUND", value and "1" or "0") end,
        "full",
        nil,
        false
    )

    -- Spatial Sound Quality
    optionsData[#optionsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_MISSING_SPATIAL_SOUND_QUALITY),
        GetString(LUIE_STRING_LAM_MISSING_SPATIAL_SOUND_QUALITY_TP),
        GetMissingSpatialSoundQualityChoices(),
        function ()
            return GetMissingSpatialSoundQualityFromCVar()
        end,
        function (value)
            SetCVar("SPATIAL_SOUND_QUALITY", value == "High" and "1" or "0")
        end,
        "full",
        nil,
        "Low",
        nil,
        nil,
        nil,
        MISSING_SPATIAL_SOUND_QUALITY_VALUES
    )

    if LUIE.IsDevDebugEnabled() then
        -- Developer Options Header
        optionsData[#optionsData + 1] = SettingsAPI.CreateHeaderOption(
            "Developer Options"
        )

        -- Disable Precompiled Lua
        optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
            "Disable Precompiled Lua",
            "Disable use of precompiled Lua files",
            function () return GetCVar("UsePrecompiledLua.2") == "0" end,
            function (value) SetCVar("UsePrecompiledLua.2", value and "0" or "1") end,
            "full",
            nil,
            true,
            "This is a developer option that may affect game performance. Changes require a UI reload.",
            true
        )

        -- Disable Precompiled XML
        optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
            "Disable Precompiled XML",
            "Disable use of precompiled XML files",
            function () return GetCVar("UsePrecompiledXML.2") == "0" end,
            function (value) SetCVar("UsePrecompiledXML.2", value and "0" or "1") end,
            "full",
            nil,
            true,
            "This is a developer option that may affect game performance. Changes require a UI reload.",
            true
        )

        -- Profile Control Creation
        optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
            "Profile Control Creation",
            "Enable profiling of UI control creation",
            function () return GetCVar("ProfileControlCreation") == "1" end,
            function (value) SetCVar("ProfileControlCreation", value and "1" or "0") end,
            "full",
            nil,
            false,
            "This is a developer option that may affect game performance. Changes require a UI reload.",
            true
        )

        -- Enable Lua Class Verification
        optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
            "Lua Class Verification",
            "Enable Lua class verification",
            function () return GetCVar("EnableLuaClassVerification") == "1" end,
            function (value) SetCVar("EnableLuaClassVerification", value and "1" or "0") end,
            "full",
            nil,
            false,
            "This is a developer option that may affect game performance. Changes require a UI reload.",
            true
        )
    end
    LAM:RegisterAddonPanel(LUIE.name .. "AddonOptions", panelData)
    LAM:RegisterOptionControls(LUIE.name .. "AddonOptions", optionsData)
end
