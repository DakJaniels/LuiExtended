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

-- Load Settings API
local SettingsAPI = LUIE.SettingsAPI

-- Load LibAddonMenu
local LAM = LUIE.LAM

-- Create Settings Menu
function LUIE.CreateSettings()
    local Defaults = LUIE.Defaults
    local Settings = LUIE.SV

    local optionsData = {}

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

    -- -- Changelog Button
    -- optionsData[#optionsData + 1] = SettingsAPI.CreateButtonOption(
    --     GetString(LUIE_STRING_LAM_CHANGELOG),
    --     GetString(LUIE_STRING_LAM_CHANGELOG_TP),
    --     function ()
    --         LUIE.ToggleChangelog(false)
    --         SCENE_MANAGER:ShowBaseScene()
    --     end,
    --     "half",
    --     function () return not Settings.ShowChangeLog end
    -- )

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
    optionsData[#optionsData + 1] = SettingsAPI.CreateSliderOption(
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
        function () return LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end,
        function (value)
            LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV = value
            ReloadUI("ingame")
        end,
        "full",
        nil,
        nil,
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON)
    )

    -- Copy Profile Dropdown
    local profileDropdown = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY),
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY_TP),
        profileCharacters,
        function () return profileCharacters end,
        function (value) profileQueuedCopy = value end,
        "full",
        nil,
        nil,
        nil,
        "name-up"
    )
    profileDropdown.scrollable = true and 7
    profileControls[#profileControls + 1] = profileDropdown

    -- Copy Profile Button
    profileControls[#profileControls + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON),
        GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON_TP),
        CopyCharacterProfile,
        "full",
        nil,
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
        function () return not LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV end,
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

    -- Modules Header
    optionsData[#optionsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_MODULEHEADER)
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

    -- Action Bar Module
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Action Bar",
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
        "Enhanced action bar with cooldown timers, ultimate tracking, and cast bar.",
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

    -- Misc Settings
    optionsData[#optionsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_MISCHEADER)
    )

    -- Show Changelog
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show Changelog when there is a update to LUIE.",
        "Show Changelog when there is a update to LUIE.",
        function () return Settings.ShowChangeLog end,
        function (value) Settings.ShowChangeLog = value end,
        "full",
        nil,
        Defaults.ShowChangeLog,
        nil,
        true
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
        "Use Custom Icons",
        "Use Custom Icons",
        function () return Settings.CustomIcons end,
        function (value) Settings.CustomIcons = value end,
        "full",
        nil,
        Defaults.CustomIcons
    )

    -- Missing Base Game Settings
    optionsData[#optionsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_MISSINGBASEGAMESETTINGS)
    )

    -- Energy Sustainability
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Energy Sustainability",
        "Toggle energy sustainability measures",
        function () return GetCVar("EnergySustainabilityMeasuresEnabled") == "1" end,
        function (value) SetCVar("EnergySustainabilityMeasuresEnabled", value and "1" or "0") end,
        "full",
        nil,
        false
    )

    -- FPS Limit
    optionsData[#optionsData + 1] = SettingsAPI.CreateSliderOption(
        "FPS Limit",
        "Set the maximum FPS limit (requires game restart)\nDefault game UI only allows up to 100",
        1,
        300,
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
        "Skip Pregame Videos",
        "Skip intro videos when launching the game",
        function () return GetCVar("SkipPregameVideos") == "1" end,
        function (value) SetCVar("SkipPregameVideos", value and "1" or "0") end,
        "full",
        nil,
        true
    )

    -- Raw Mouse Input
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Raw Mouse Input",
        "Enable raw mouse input for more precise control",
        function () return GetCVar("MouseRawInput") == "1" end,
        function (value) SetCVar("MouseRawInput", value and "1" or "0") end,
        "full",
        nil,
        true
    )

    -- Screenshot Format
    optionsData[#optionsData + 1] = SettingsAPI.CreateDropdownOption(
        "Screenshot Format",
        "Choose the format for saved screenshots",
        { "JPG", "PNG", "BMP" },
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
        "PNG"
    )

    -- Disable Razer Chroma
    optionsData[#optionsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Disable Razer Chroma",
        "Disable Razer Chroma integration",
        function () return GetCVar("UseChromaIfAvailable") == "0" end,
        function (value) SetCVar("UseChromaIfAvailable", value and "0" or "1") end,
        "full",
        nil,
        true
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
