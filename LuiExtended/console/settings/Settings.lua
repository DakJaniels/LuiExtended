-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local g_ElementMovingEnabled

local GridOverlay = LUIE.GridOverlay

local pairs = pairs
local table_concat = table.concat

-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

-- Create Settings Menu
function LUIE.CreateConsoleSettings()
    local Defaults = LUIE.Defaults
    local Settings = LUIE.SV

    local settingsData = {}

    local profileCharacters = {} -- List of character profiles
    local profileQueuedCopy      -- Currently queued character copy name for copy button

    -- Generate list of character profiles for Menu function
    local function GenerateCharacterProfiles()
        local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV -- Pull info from SV for account wide
        local playerName = GetUnitName("player")

        for accountName, data in pairs(LUIESV["Default"]) do
            for profile, vars in pairs(data) do
                if profile == "$AccountWide" then
                    profile = "$AccountWide (" .. accountName .. ")" -- Add display name onto Account Wide for differentiation
                end
                if vars.version == LUIE.SVVer and ((isCharacterSpecific and profile ~= playerName) or not isCharacterSpecific) then
                    -- Add list of other player characters (but not self) to settings to copy. We also add AccountWide here so you can copy from your base settings if desired.
                    profileCharacters[#profileCharacters + 1] = profile -- Use the length operator (#) to append to the table, which is faster than table.insert()
                end
            end
        end
        return profileCharacters -- Return the table of profiles
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
        for accountName, data in pairs(LUIESV["Default"]) do
            if data[deleteProfile] then
                data[deleteProfile] = nil
                break
            end
        end
    end

    -- Copy a character profile & replace another.
    local function CopyCharacterProfile()
        local displayName = GetDisplayName()
        if not LUIESV["Default"][displayName] or not LUIESV["Default"][displayName]["$AccountWide"] then
            return
        end
        local isCharacterSpecific = LUIESV["Default"][displayName]["$AccountWide"].CharacterSpecificSV -- Pull info from SV for account wide
        local copyTarget = isCharacterSpecific and GetUnitName("player") or "$AccountWide"
        local sourceCharacter, targetCharacter
        local accountWideString = "$AccountWide ("
        for accountName, data in pairs(LUIESV["Default"]) do
            local accountWideName = accountWideString .. accountName .. ")"
            if profileQueuedCopy == accountWideName then
                profileQueuedCopy = "$AccountWide"
            end -- When the account name matches the one we're iterating through, copy that value
            for profile, vars in pairs(data) do
                if profile == profileQueuedCopy then
                    sourceCharacter = vars
                end
                if profile == copyTarget then
                    targetCharacter = vars
                end
            end
        end
        if not sourceCharacter or not targetCharacter then
            CHAT_ROUTER:AddSystemMessage(GetString(LUIE_STRING_LAM_PROFILE_COPY_ERROR))
            return
        else
            CopyTable(sourceCharacter, targetCharacter)
            ReloadUI("ingame")
        end
    end

    GenerateCharacterProfiles()

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(LUIE.name,
                                {
                                    allowDefaults = false,
                                    allowRefresh = true
                                })

    -- Changelog Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_CHANGELOG),
        GetString(LUIE_STRING_LAM_CHANGELOG_TP),
        function ()
            LUIE.ToggleChangelog(false)
            SCENE_MANAGER:ShowBaseScene()
        end,
        "half",
        function () return not Settings.ShowChangeLog end
    )

    -- ReloadUI Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function () ReloadUI("ingame") end,
        "half"
    )

    -- Default UI Elements Position Unlock
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI),
        GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI_TP),
        function () return g_ElementMovingEnabled end,
        function (value)
            g_ElementMovingEnabled = value
            LUIE.SetupElementMover(value)
        end,
        "half",
        nil,
        false
    )

    -- Grid Snap Settings
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Enable Grid Snap",
        "Enable snapping UI elements to a grid when moving them",
        function () return LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_default end,
        function (value)
            local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGrid_default = value
            local gridSize = accountWideSettings.snapToGridSize_default or 15
            GridOverlay.Refresh("default", g_ElementMovingEnabled and value, gridSize)
        end,
        "half",
        nil,
        false
    )

    -- Grid Size
    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Grid Size",
        "Set the size of the grid for snapping UI elements",
        5,
        100,
        5,
        function () return LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGridSize_default or 15 end,
        function (value)
            local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGridSize_default = value
            GridOverlay.Refresh("default", g_ElementMovingEnabled and accountWideSettings.snapToGrid_default, value)
        end,
        "half",
        function () return not LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_default end,
        15
    )

    -- Default UI Elements Position Reset
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RESETPOSITION),
        GetString(LUIE_STRING_LAM_RESET_DEFAULT_UI_TP),
        LUIE.ResetElementPosition,
        "half"
    )

    -- Character Profile Settings Section (no submenu in LHAS)
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_HEADER)
    )

    -- Character Profile Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_DESCRIPTION)
    )

    -- Use Character Specific Settings Toggle
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE),
        GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE_TP),
        function () return LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end,
        function (value)
            LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV = value
            ReloadUI("ingame")
        end,
        "full",
        nil,
        nil
    )

    -- Copy Profile Dropdown - Convert profileCharacters to {name, data} format
    local profileItems = {}
    for i, profile in ipairs(profileCharacters) do
        profileItems[i] = { name = profile, data = profile }
    end
    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY),
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY_TP),
        profileItems,
        function () return profileQueuedCopy or "" end,
        function (combobox, value, item)
            profileQueuedCopy = item.data
        end,
        "full",
        nil,
        nil
    )

    -- Copy Profile Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON),
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON_TP),
        CopyCharacterProfile,
        "full"
    )

    -- Reset Current Character Settings Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR),
        GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR_TP),
        function ()
            DeleteCurrentProfile(false)
            ReloadUI("ingame")
        end,
        "half",
        function () return not LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end
    )

    -- Reset Account Wide Settings Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT),
        GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT_TP),
        function ()
            DeleteCurrentProfile(true)
            ReloadUI("ingame")
        end,
        "half"
    )

    -- Modules Header
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_MODULEHEADER)
    )

    -- Unit Frames Module
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_ENABLE),
        nil,
        function () return Settings.UnitFrames_Enabled end,
        function (value) Settings.UnitFrames_Enabled = value end,
        "half",
        nil,
        Defaults.UnitFrames_Enabled
    )

    -- Unit Frames module description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_UF_DESCRIPTION)
    )

    -- Action Bar Module
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Action Bar",
        nil,
        function () return Settings.ActionBar_Enabled end,
        function (value) Settings.ActionBar_Enabled = value end,
        "half",
        nil,
        Defaults.ActionBar_Enabled
    )

    -- Action Bar Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        "Enhanced action bar with cooldown timers, ultimate tracking, and cast bar."
    )

    -- Combat Info Module
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CI_SHOWCOMBATINFO),
        nil,
        function () return Settings.CombatInfo_Enabled end,
        function (value) Settings.CombatInfo_Enabled = value end,
        "half",
        nil,
        Defaults.CombatInfo_Enabled
    )

    -- Combat Info Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CI_DESCRIPTION)
    )

    -- Combat Text Module
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CT_SHOWCOMBATTEXT),
        nil,
        function () return Settings.CombatText_Enabled end,
        function (value) Settings.CombatText_Enabled = value end,
        "half",
        nil,
        Defaults.CombatText_Enabled
    )

    -- Combat Text Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CT_DESCRIPTION)
    )

    -- Buffs & Debuffs Module
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_BUFF_ENABLEEFFECTSTRACK),
        nil,
        function () return Settings.SpellCastBuff_Enable end,
        function (value) Settings.SpellCastBuff_Enable = value end,
        "half",
        nil,
        Defaults.SpellCastBuff_Enable
    )

    -- Buffs & Debuffs Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_BUFFS_DESCRIPTION)
    )

    -- Chat Announcements Module
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_CA_ENABLE),
        nil,
        function () return Settings.ChatAnnouncements_Enable end,
        function (value) Settings.ChatAnnouncements_Enable = value end,
        "half",
        nil,
        Defaults.ChatAnnouncements_Enable
    )

    -- Chat Announcements Module Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_CA_DESCRIPTION)
    )

    -- Slash Commands Module
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_ENABLE),
        nil,
        function () return Settings.SlashCommands_Enable end,
        function (value) Settings.SlashCommands_Enable = value end,
        "half",
        nil,
        Defaults.SlashCommands_Enable
    )

    -- Slash Commands Module Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_SLASHCMDS_DESCRIPTION)
    )

    -- Show InfoPanel
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_PNL_ENABLE),
        nil,
        function () return Settings.InfoPanel_Enabled end,
        function (value) Settings.InfoPanel_Enabled = value end,
        "half",
        nil,
        Defaults.InfoPanel_Enabled
    )

    -- InfoPanel Module Description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_PNL_DESCRIPTION)
    )

    -- Misc Settings
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_MISCHEADER)
    )

    -- Show Changelog
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show Changelog when there is a update to LUIE.",
        "Show Changelog when there is a update to LUIE.",
        function () return Settings.ShowChangeLog end,
        function (value) Settings.ShowChangeLog = value end,
        "full",
        nil,
        Defaults.ShowChangeLog
    )

    -- Hide Alerts
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
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
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_HIDE_EXPERIENCE_BAR),
        GetString(LUIE_STRING_LAM_HIDE_EXPERIENCE_BAR_TP),
        function () return Settings.HideXPBar end,
        function (value) Settings.HideXPBar = value end,
        "full",
        nil,
        Defaults.HideXPBar
    )

    -- Startup Message Options
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_STARTUPMSG),
        GetString(LUIE_STRING_LAM_STARTUPMSG_TP),
        function () return Settings.StartupInfo end,
        function (value) Settings.StartupInfo = value end,
        "full",
        nil,
        Defaults.StartupInfo
    )

    -- Custom Icons
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Use Custom Icons",
        "Use Custom Icons",
        function () return Settings.CustomIcons end,
        function (value) Settings.CustomIcons = value end,
        "full",
        nil,
        Defaults.CustomIcons
    )

    -- Add all settings to the panel
    panel:AddSettings(settingsData)
end
