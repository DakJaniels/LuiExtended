-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local g_ElementMovingEnabled

local pairs = pairs
local table_concat = table.concat

-- Create Settings Menu
function LUIE.CreateSettings()
    -- Load LibAddonMenu
    local LAM = LibAddonMenu2
    if LAM == nil then
        return
    end

    local Defaults = LUIE.Defaults
    local Settings = LUIE.SV

    local optionsData = {}

    local profileCharacters = {} -- List of character profiles
    local profileQueuedCopy      -- Currently queued character copy name for copy button

    -- Generate list of character profiles for Menu function
    local function GenerateCharacterProfiles()
        local isCharacterSpecific = LUIESV.Default[GetDisplayName()]["$AccountWide"].CharacterSpecificSV -- Pull info from SV for account wide
        local playerName = GetUnitName("player")

        for accountName, data in pairs(LUIESV.Default) do
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
        for accountName, data in pairs(LUIESV.Default) do
            if data[deleteProfile] then
                data[deleteProfile] = nil
                break
            end
        end
    end

    -- Copy a character profile & replace another.
    local function CopyCharacterProfile()
        local displayName = GetDisplayName()
        if not LUIESV.Default[displayName] or not LUIESV.Default[displayName]["$AccountWide"] then
            return
        end
        local isCharacterSpecific = LUIESV.Default[displayName]["$AccountWide"].CharacterSpecificSV -- Pull info from SV for account wide
        local copyTarget = isCharacterSpecific and GetUnitName("player") or "$AccountWide"
        local sourceCharacter, targetCharacter
        local accountWideString = "$AccountWide ("
        for accountName, data in pairs(LUIESV.Default) do
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

    -- Changelog Button
    optionsData[#optionsData + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_CHANGELOG),
        tooltip = GetString(LUIE_STRING_LAM_CHANGELOG_TP),
        func = function ()
            LUIE.ToggleChangelog(false)
            SCENE_MANAGER:ShowBaseScene()
        end,
        width = "half",
    }

    -- ReloadUI Button
    optionsData[#optionsData + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        func = function ()
            ReloadUI("ingame")
        end,
        width = "half",
    }

    -- Default UI Elements Position Unlock
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI),
        tooltip = GetString(LUIE_STRING_LAM_UNLOCK_DEFAULT_UI_TP),
        getFunc = function ()
            return g_ElementMovingEnabled
        end,
        setFunc = function (value)
            g_ElementMovingEnabled = value
            LUIE.SetupElementMover(value)
        end,
        width = "half",
        default = false,
        resetFunc = LUIE.ResetElementPosition,
    }

    -- Default UI Elements Position Reset
    optionsData[#optionsData + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RESETPOSITION),
        tooltip = GetString(LUIE_STRING_LAM_RESET_DEFAULT_UI_TP),
        func = LUIE.ResetElementPosition,
        warning = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        width = "half",
    }

    -- Character Profile Settings Submenu
    optionsData[#optionsData + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_SVPROFILE_HEADER),
        controls =
        {
            {
                -- Character Profile Description
                type = "description",
                text = GetString(LUIE_STRING_LAM_SVPROFILE_DESCRIPTION),
                width = "full",
            },
            {
                -- Use Character Specific Settings Toggle
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE),
                tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_SETTINGSTOGGLE_TP),
                warning = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
                getFunc = function ()
                    return LUIESV.Default[GetDisplayName()]["$AccountWide"].CharacterSpecificSV
                end,
                setFunc = function (value)
                    LUIESV.Default[GetDisplayName()]["$AccountWide"].CharacterSpecificSV = value
                    ReloadUI("ingame")
                end,
                width = "full",
            },
            {
                -- Copy Profile Dropdown
                type = "dropdown",
                scrollable = true,
                name = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY),
                tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPY_TP),
                choices = profileCharacters,
                sort = "name-up",
                getFunc = function ()
                    return profileCharacters
                end,
                setFunc = function (value)
                    profileQueuedCopy = value
                end,
                width = "full",
            },
            {
                -- Copy Profile Button
                type = "button",
                name = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON),
                tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_PROFILECOPYBUTTON_TP),
                warning = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
                func = function ()
                    CopyCharacterProfile()
                end,
                width = "full",
            },
            {
                -- Reset Current Character Settings Button
                type = "button",
                name = GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR),
                tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_RESETCHAR_TP),
                warning = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
                func = function ()
                    DeleteCurrentProfile(false)
                    ReloadUI("ingame")
                end,
                width = "half",
                disabled = function ()
                    return not LUIESV.Default[GetDisplayName()]["$AccountWide"].CharacterSpecificSV
                end,
            },
            {
                -- Reset Account Wide Settings Button
                type = "button",
                name = GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT),
                tooltip = GetString(LUIE_STRING_LAM_SVPROFILE_RESETACCOUNT_TP),
                warning = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
                width = "half",
                func = function ()
                    DeleteCurrentProfile(true)
                    ReloadUI("ingame")
                end,
            },
        },
    }

    -- Modules Header
    optionsData[#optionsData + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_MODULEHEADER),
        width = "full",
    }

    -- Unit Frames Module
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_UF_ENABLE),
        getFunc = function ()
            return Settings.UnitFrames_Enabled
        end,
        setFunc = function (value)
            Settings.UnitFrames_Enabled = value
        end,
        width = "half",
        warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
        default = Defaults.UnitFrames_Enabled,
    }

    -- Unit Frames module description
    optionsData[#optionsData + 1] =
    {
        type = "description",
        width = "half",
        text = GetString(LUIE_STRING_LAM_UF_DESCRIPTION),
    }

    -- Combat Info Module
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_CI_SHOWCOMBATINFO),
        getFunc = function ()
            return Settings.CombatInfo_Enabled
        end,
        setFunc = function (value)
            Settings.CombatInfo_Enabled = value
        end,
        width = "half",
        warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
        default = Defaults.CombatInfo_Enabled,
    }

    -- Combat Info Description
    optionsData[#optionsData + 1] =
    {
        type = "description",
        width = "half",
        text = GetString(LUIE_STRING_LAM_CI_DESCRIPTION),
    }

    -- Combat Text Module
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_CT_SHOWCOMBATTEXT),
        getFunc = function ()
            return Settings.CombatText_Enabled
        end,
        setFunc = function (value)
            Settings.CombatText_Enabled = value
        end,
        width = "half",
        warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
        default = Defaults.CombatText_Enabled,
    }

    -- Combat Text Description
    optionsData[#optionsData + 1] =
    {
        type = "description",
        width = "half",
        text = GetString(LUIE_STRING_LAM_CT_DESCRIPTION),
    }

    -- Buffs & Debuffs Module
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_BUFF_ENABLEEFFECTSTRACK),
        getFunc = function ()
            return Settings.SpellCastBuff_Enable
        end,
        setFunc = function (value)
            Settings.SpellCastBuff_Enable = value
        end,
        width = "half",
        warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
        default = Defaults.SpellCastBuff_Enable,
    }

    -- Buffs & Debuffs Description
    optionsData[#optionsData + 1] =
    {
        type = "description",
        width = "half",
        text = GetString(LUIE_STRING_LAM_BUFFS_DESCRIPTION),
    }

    -- Chat Announcements Module
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_CA_ENABLE),
        getFunc = function ()
            return Settings.ChatAnnouncements_Enable
        end,
        setFunc = function (value)
            Settings.ChatAnnouncements_Enable = value
        end,
        width = "half",
        warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
        default = Defaults.ChatAnnouncements_Enable,
    }

    -- Chat Announcements Module Description
    optionsData[#optionsData + 1] =
    {
        type = "description",
        width = "half",
        text = GetString(LUIE_STRING_LAM_CA_DESCRIPTION),
    }

    -- Slash Commands Module
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_SLASHCMDS_ENABLE),
        getFunc = function ()
            return Settings.SlashCommands_Enable
        end,
        setFunc = function (value)
            Settings.SlashCommands_Enable = value
        end,
        width = "half",
        warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
        default = Defaults.SlashCommands_Enable,
    }

    -- Slash Commands Module Description
    optionsData[#optionsData + 1] =
    {
        type = "description",
        width = "half",
        text = GetString(LUIE_STRING_LAM_SLASHCMDS_DESCRIPTION),
    }

    -- Show InfoPanel
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_PNL_ENABLE),
        getFunc = function ()
            return Settings.InfoPanel_Enabled
        end,
        setFunc = function (value)
            Settings.InfoPanel_Enabled = value
        end,
        width = "half",
        warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
        default = Defaults.SlashCommands_Enable,
    }

    -- InfoPanel Module Description
    optionsData[#optionsData + 1] =
    {
        type = "description",
        width = "half",
        text = GetString(LUIE_STRING_LAM_PNL_DESCRIPTION),
    }

    -- Misc Settings
    optionsData[#optionsData + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_MISCHEADER),
        width = "full",
    }

    -- -- Alert Text Alignment
    -- optionsData[#optionsData + 1] =
    -- {
    --     type = "dropdown",
    --     name = GetString(LUIE_STRING_LAM_ALERT_TEXT_ALIGNMENT),
    --     tooltip = GetString(LUIE_STRING_LAM_ALERT_TEXT_ALIGNMENT_TP),
    --     choices = alignmentOptions,
    --     getFunc = function () return alignmentOptions[Settings.AlertFrameAlignment] end,
    --     setFunc = function (value) Settings.AlertFrameAlignment = alignmentOptionsKeys[value] end,
    --     width = "full",
    --     default = Defaults.AlertFrameAlignment,
    -- }

    --
    -- Modules Header
    -- optionsData[#optionsData + 1] =
    -- {
    --     type = "header",
    --     name = GetString(LUIE_STRING_LAM_MODULEHEADER),
    --     width = "full",
    -- }

    -- -- Custom Icons Toggle
    -- optionsData[#optionsData + 1] =
    -- {
    --     type = "checkbox",
    --     name = GetString(LUIE_STRING_LAM_CUSTOM_ICONS_ENABLE),
    --     tooltip = GetString(LUIE_STRING_LAM_CUSTOM_ICONS_ENABLE_TP),
    --     getFunc = function()
    --         return Settings.CustomIcons_Enabled
    --     end,
    --     setFunc = function(value)
    --         Settings.CustomIcons_Enabled = value
    --         -- Queue UI reload since this requires reinitialization of hooks
    --         ReloadUI("ingame")
    --     end,
    --     width = "half",
    --     warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
    --     default = Defaults.CustomIcons_Enabled,
    -- }
    -- -- Custom Icons Description
    -- optionsData[#optionsData + 1] =
    -- {
    --     type = "description",
    --     width = "half",
    --     text = GetString(LUIE_STRING_LAM_CUSTOM_ICONS_DESCRIPTION),
    -- }
    -- Hide Alerts
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_ALERT_HIDE_ALL),
        tooltip = GetString(LUIE_STRING_LAM_ALERT_HIDE_ALL_TP),
        getFunc = function ()
            return Settings.HideAlertFrame
        end,
        setFunc = function (value)
            Settings.HideAlertFrame = value
            LUIE.SetupAlertFrameVisibility()
        end,
        width = "full",
        default = Defaults.HideAlertFrame,
    }

    -- Toggle XP Bar popup
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_HIDE_EXPERIENCE_BAR),
        tooltip = GetString(LUIE_STRING_LAM_HIDE_EXPERIENCE_BAR_TP),
        getFunc = function ()
            return Settings.HideXPBar
        end,
        setFunc = function (value)
            Settings.HideXPBar = value
        end,
        width = "full",
        default = Defaults.HideXPBar,
    }

    -- Startup Message Options
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_STARTUPMSG),
        tooltip = GetString(LUIE_STRING_LAM_STARTUPMSG_TP),
        getFunc = function ()
            return Settings.StartupInfo
        end,
        setFunc = function (value)
            Settings.StartupInfo = value
        end,
        width = "full",
        default = Defaults.StartupInfo,
    }

    -- Missing Base Game Settings
    optionsData[#optionsData + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_MISSINGBASEGAMESETTINGS),
        width = "full",
    }

    -- Energy Sustainability
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = "Energy Sustainability",
        tooltip = "Toggle energy sustainability measures",
        getFunc = function ()
            return GetCVar("EnergySustainabilityMeasuresEnabled") == "1"
        end,
        setFunc = function (value)
            SetCVar("EnergySustainabilityMeasuresEnabled", value and "1" or "0")
        end,
        width = "full",
        default = false,
    }
    -- FPS Limit
    optionsData[#optionsData + 1] =
    {
        type = "slider",
        name = "FPS Limit",
        tooltip = "Set the maximum FPS limit (requires game restart)\nDefault game UI only allows up to 100",
        min = 1,
        max = 300,
        step = 1,
        getFunc = function ()
            -- Convert MinFrameTime to FPS (1/MinFrameTime)
            local minFrameTime = tonumber(GetCVar("MinFrameTime.2"))
            return minFrameTime and zo_floor(1 / minFrameTime + 0.5) or 100
        end,
        setFunc = function (value)
            -- Convert FPS to MinFrameTime (1/FPS)
            local minFrameTime = string.format("%.8f", 1 / value)
            SetCVar("MinFrameTime.2", minFrameTime)
        end,
        width = "full",
        default = 100,
    }

    -- Skip Pregame Videos
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = "Skip Pregame Videos",
        tooltip = "Skip intro videos when launching the game",
        getFunc = function ()
            return GetCVar("SkipPregameVideos") == "1"
        end,
        setFunc = function (value)
            SetCVar("SkipPregameVideos", value and "1" or "0")
        end,
        width = "full",
        default = true,
    }

    -- Raw Mouse Input
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = "Raw Mouse Input",
        tooltip = "Enable raw mouse input for more precise control",
        getFunc = function ()
            return GetCVar("MouseRawInput") == "1"
        end,
        setFunc = function (value)
            SetCVar("MouseRawInput", value and "1" or "0")
        end,
        width = "full",
        default = true,
    }

    -- Screenshot Format
    optionsData[#optionsData + 1] =
    {
        type = "dropdown",
        name = "Screenshot Format",
        tooltip = "Choose the format for saved screenshots",
        choices = { "JPG", "PNG", "BMP" },
        getFunc = function ()
            local format = GetCVar("ScreenshotFormat.2")
            if format == "PNG" then
                return "PNG"
            elseif format == "BMP" then
                return "BMP"
            else
                return "JPG"
            end
        end,
        setFunc = function (value)
            SetCVar("ScreenshotFormat.2", value)
        end,
        width = "full",
        default = "PNG",
    }

    -- Disable Razer Chrome
    optionsData[#optionsData + 1] =
    {
        type = "checkbox",
        name = "Disable Razer Chroma",
        tooltip = "Disable Razer Chroma integration",
        getFunc = function ()
            return GetCVar("UseChromaIfAvailable") == "0"
        end,
        setFunc = function (value)
            SetCVar("UseChromaIfAvailable", value and "0" or "1")
        end,
        width = "full",
        default = true,
    }
    if LUIE.IsDevDebugEnabled() then
        -- Developer Options Header
        optionsData[#optionsData + 1] =
        {
            type = "header",
            name = "Developer Options",
            width = "full",
        }

        -- Disable Precompiled Lua
        optionsData[#optionsData + 1] =
        {
            type = "checkbox",
            name = "Disable Precompiled Lua",
            tooltip = "Disable use of precompiled Lua files",
            getFunc = function ()
                return GetCVar("UsePrecompiledLua.2") == "0"
            end,
            setFunc = function (value)
                SetCVar("UsePrecompiledLua.2", value and "0" or "1")
            end,
            width = "full",
            default = true,
            requiresReload = true,
            warning = "This is a developer option that may affect game performance. Changes require a UI reload.",
        }

        -- Disable Precompiled XML
        optionsData[#optionsData + 1] =
        {
            type = "checkbox",
            name = "Disable Precompiled XML",
            tooltip = "Disable use of precompiled XML files",
            getFunc = function ()
                return GetCVar("UsePrecompiledXML.2") == "0"
            end,
            setFunc = function (value)
                SetCVar("UsePrecompiledXML.2", value and "0" or "1")
            end,
            width = "full",
            default = true,
            requiresReload = true,
            warning = "This is a developer option that may affect game performance. Changes require a UI reload.",
        }

        -- Profile Control Creation
        optionsData[#optionsData + 1] =
        {
            type = "checkbox",
            name = "Profile Control Creation",
            tooltip = "Enable profiling of UI control creation",
            getFunc = function ()
                return GetCVar("ProfileControlCreation") == "1"
            end,
            setFunc = function (value)
                SetCVar("ProfileControlCreation", value and "1" or "0")
            end,
            width = "full",
            default = false,
            requiresReload = true,
            warning = "This is a developer option that may affect game performance. Changes require a UI reload.",
        }

        -- Enable Lua Class Verification
        optionsData[#optionsData + 1] =
        {
            type = "checkbox",
            name = "Lua Class Verification",
            tooltip = "Enable Lua class verification",
            getFunc = function ()
                return GetCVar("EnableLuaClassVerification") == "1"
            end,
            setFunc = function (value)
                SetCVar("EnableLuaClassVerification", value and "1" or "0")
            end,
            width = "full",
            default = false,
            requiresReload = true,
            warning = "This is a developer option that may affect game performance. Changes require a UI reload.",
        }
    end
    LAM:RegisterAddonPanel(LUIE.name .. "AddonOptions", panelData)
    LAM:RegisterOptionControls(LUIE.name .. "AddonOptions", optionsData)
end
