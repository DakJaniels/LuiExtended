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
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_CHANGELOG),
        tooltip = GetString(LUIE_STRING_LAM_CHANGELOG_TP),
        buttonText = GetString(LUIE_STRING_LAM_CHANGELOG),
        clickHandler = function ()
            LUIE.ToggleChangelog(false)
            SCENE_MANAGER:ShowBaseScene()
        end,
        disable = function () return not Settings.ShowChangeLog end
    }

    -- ReloadUI Button
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        clickHandler = function () ReloadUI("ingame") end
    }

    -- Default UI Elements Position Unlock
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI),
        tooltip = GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI_TP),
        getFunction = function () return g_ElementMovingEnabled end,
        setFunction = function (value)
            g_ElementMovingEnabled = value
            LUIE.SetupElementMover(value)
        end,
        default = false
    }

    -- Grid Snap Settings
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = "Enable Grid Snap",
        tooltip = "Enable snapping UI elements to a grid when moving them",
        getFunction = function () return LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_default end,
        setFunction = function (value)
            local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGrid_default = value
            local gridSize = accountWideSettings.snapToGridSize_default or 15
            GridOverlay.Refresh("default", g_ElementMovingEnabled and value, gridSize)
        end,
        default = false
    }

    -- Grid Size
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_SLIDER,
        label = "Grid Size",
        tooltip = "Set the size of the grid for snapping UI elements",
        min = 5,
        max = 100,
        step = 5,
        format = "%.0f",
        getFunction = function () return LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGridSize_default or 15 end,
        setFunction = function (value)
            local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGridSize_default = value
            GridOverlay.Refresh("default", g_ElementMovingEnabled and accountWideSettings.snapToGrid_default, value)
        end,
        default = 15,
        disable = function () return not LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_default end
    }

    -- Default UI Elements Position Reset
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RESETPOSITION),
        tooltip = GetString(LUIE_STRING_LAM_RESET_DEFAULT_UI_TP),
        buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
        clickHandler = LUIE.ResetElementPosition
    }

    -- Character Profile Settings Section
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_SECTION,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_HEADER)
    }

    -- Character Profile Description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_DESCRIPTION)
    }

    -- Use Character Specific Settings Toggle
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE),
        tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE_TP),
        getFunction = function () return LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end,
        setFunction = function (value)
            LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV = value
            ReloadUI("ingame")
        end
    }

    -- Copy Profile Dropdown - Convert profileCharacters to {name, data} format
    local profileItems = {}
    for i, profile in ipairs(profileCharacters) do
        profileItems[i] = { name = profile, data = profile }
    end
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_DROPDOWN,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY),
        tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY_TP),
        items = profileItems,
        getFunction = function () return profileQueuedCopy or "" end,
        setFunction = function (combobox, value, item)
            profileQueuedCopy = item.data
        end
    }

    -- Copy Profile Button
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON),
        tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON_TP),
        buttonText = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON),
        clickHandler = CopyCharacterProfile
    }

    -- Reset Current Character Settings Button
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR),
        tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR_TP),
        buttonText = GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR),
        clickHandler = function ()
            DeleteCurrentProfile(false)
            ReloadUI("ingame")
        end,
        disable = function () return not LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end
    }

    -- Reset Account Wide Settings Button
    settingsData[#settingsData + 1] =
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

    -- Modules Header
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_SECTION,
        label = GetString(LUIE_STRING_LAM_MODULEHEADER)
    }

    -- Unit Frames Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_UF_ENABLE),
        getFunction = function () return Settings.UnitFrames_Enabled end,
        setFunction = function (value) Settings.UnitFrames_Enabled = value end,
        default = Defaults.UnitFrames_Enabled
    }

    -- Unit Frames module description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_UF_DESCRIPTION)
    }

    -- Action Bar Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = "Action Bar",
        getFunction = function () return Settings.ActionBar_Enabled end,
        setFunction = function (value) Settings.ActionBar_Enabled = value end,
        default = Defaults.ActionBar_Enabled
    }

    -- Action Bar Description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = "Enhanced action bar with cooldown timers, ultimate tracking, and cast bar."
    }

    -- Combat Info Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CI_SHOWCOMBATINFO),
        getFunction = function () return Settings.CombatInfo_Enabled end,
        setFunction = function (value) Settings.CombatInfo_Enabled = value end,
        default = Defaults.CombatInfo_Enabled
    }

    -- Combat Info Description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_CI_DESCRIPTION)
    }

    -- Combat Text Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CT_SHOWCOMBATTEXT),
        getFunction = function () return Settings.CombatText_Enabled end,
        setFunction = function (value) Settings.CombatText_Enabled = value end,
        default = Defaults.CombatText_Enabled
    }

    -- Combat Text Description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_CT_DESCRIPTION)
    }

    -- Buffs & Debuffs Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_BUFF_ENABLEEFFECTSTRACK),
        getFunction = function () return Settings.SpellCastBuff_Enable end,
        setFunction = function (value) Settings.SpellCastBuff_Enable = value end,
        default = Defaults.SpellCastBuff_Enable
    }

    -- Buffs & Debuffs Description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_BUFFS_DESCRIPTION)
    }

    -- Chat Announcements Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_CA_ENABLE),
        getFunction = function () return Settings.ChatAnnouncements_Enable end,
        setFunction = function (value) Settings.ChatAnnouncements_Enable = value end,
        default = Defaults.ChatAnnouncements_Enable
    }

    -- Chat Announcements Module Description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_CA_DESCRIPTION)
    }

    -- Slash Commands Module
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_SLASHCMDS_ENABLE),
        getFunction = function () return Settings.SlashCommands_Enable end,
        setFunction = function (value) Settings.SlashCommands_Enable = value end,
        default = Defaults.SlashCommands_Enable
    }

    -- Slash Commands Module Description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_SLASHCMDS_DESCRIPTION)
    }

    -- Show InfoPanel
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_PNL_ENABLE),
        getFunction = function () return Settings.InfoPanel_Enabled end,
        setFunction = function (value) Settings.InfoPanel_Enabled = value end,
        default = Defaults.InfoPanel_Enabled
    }

    -- InfoPanel Module Description
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_PNL_DESCRIPTION)
    }

    -- Misc Settings
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_SECTION,
        label = GetString(LUIE_STRING_LAM_MISCHEADER)
    }

    -- Show Changelog
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = "Show Changelog when there is a update to LUIE.",
        tooltip = "Show Changelog when there is a update to LUIE.",
        getFunction = function () return Settings.ShowChangeLog end,
        setFunction = function (value) Settings.ShowChangeLog = value end,
        default = Defaults.ShowChangeLog
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
        label = "Use Custom Icons",
        tooltip = "Use Custom Icons",
        getFunction = function () return Settings.CustomIcons end,
        setFunction = function (value) Settings.CustomIcons = value end,
        default = Defaults.CustomIcons
    }

    -- Add all settings to the panel
    panel:AddSettings(settingsData)
end
