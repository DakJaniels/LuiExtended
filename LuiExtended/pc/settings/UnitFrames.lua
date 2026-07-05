-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local SettingsAPI = LUIE.SettingsAPI

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local GridOverlay = LUIE.GridOverlay

local GetDisplayName = GetDisplayName
local zo_strformat = zo_strformat
local GetString = GetString
local ReloadUI = ReloadUI
local ZO_Dialogs_ShowDialog = ZO_Dialogs_ShowDialog

local PetNames = LuiData.Data.PetNames

local pairs = pairs

local function ApplyCustomPlayerHideBarLayout()
    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
    UnitFrames.CustomFramesSetupAlternative()
end

local nameDisplayOptions =
{
    GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_USERID),
    GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_CHARNAME),
    GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_CHARNAME_USERID)
}
local nameDisplayOptionsKeys =
{
    [GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_USERID)] = 1,
    [GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_CHARNAME)] = 2,
    [GetString(LUIE_STRING_LAM_UF_NAMEDISPLAY_CHARNAME_USERID)] = 3
}

local raidIconOptions =
{
    GetString(LUIE_STRING_LAM_UF_RAIDICON_NONE),
    GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_ONLY),
    GetString(LUIE_STRING_LAM_UF_RAIDICON_ROLE_ONLY),
    GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_PVP_ROLE_PVE),
    GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_PVE_ROLE_PVP)
}
local raidIconOptionsKeys =
{
    [GetString(LUIE_STRING_LAM_UF_RAIDICON_NONE)] = 1,
    [GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_ONLY)] = 2,
    [GetString(LUIE_STRING_LAM_UF_RAIDICON_ROLE_ONLY)] = 3,
    [GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_PVP_ROLE_PVE)] = 4,
    [GetString(LUIE_STRING_LAM_UF_RAIDICON_CLASS_PVE_ROLE_PVP)] = 5
}

local playerFrameOptions =
{
    GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_VERTICAL),
    GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_HORIZONTAL),
    GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_PYRAMID)
}
local playerFrameOptionsKeys =
{
    [GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_VERTICAL)] = 1,
    [GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_HORIZONTAL)] = 2,
    [GetString(LUIE_STRING_LAM_UF_PLAYERFRAME_PYRAMID)] = 3
}

local alignmentOptions =
{
    GetString(LUIE_STRING_LAM_UF_ALIGNMENT_LEFT_RIGHT),
    GetString(LUIE_STRING_LAM_UF_ALIGNMENT_RIGHT_LEFT),
    GetString(LUIE_STRING_LAM_UF_ALIGNMENT_CENTER)
}
local alignmentOptionsKeys =
{
    [GetString(LUIE_STRING_LAM_UF_ALIGNMENT_LEFT_RIGHT)] = 1,
    [GetString(LUIE_STRING_LAM_UF_ALIGNMENT_RIGHT_LEFT)] = 2,
    [GetString(LUIE_STRING_LAM_UF_ALIGNMENT_CENTER)] = 3
}

local targetTitlePriorityChoices =
{
    GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_PRIORITY_AVA),
    GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_PRIORITY_TITLE),
}
local targetTitlePriorityValues = { "AVA Rank", "Title" }

local raidLayoutChoices =
{
    GetString(LUIE_STRING_LAM_UF_RAID_LAYOUT_1X12),
    GetString(LUIE_STRING_LAM_UF_RAID_LAYOUT_2X6),
    GetString(LUIE_STRING_LAM_UF_RAID_LAYOUT_3X4),
    GetString(LUIE_STRING_LAM_UF_RAID_LAYOUT_6X2),
}
local raidLayoutValues = { "1 x 12", "2 x 6", "3 x 4", "6 x 2" }

local formatOptionChoices, formatOptionValues = UnitFrames.GetFormatOptionMenus()

local Whitelist, WhitelistValues = {}, {}

-- Create a list of Unitnames to use for Summon Whitelist
local function GenerateCustomList(input)
    local options, values = {}, {}
    local counter = 0
    for name in pairs(input) do
        counter = counter + 1
        options[counter] = name
        values[counter] = name
    end
    return options, values
end

local dialogs =
{
    [1] =
    { -- Clear Whitelist
        identifier = "LUIE_CLEAR_PET_WHITELIST",
        title = GetString(LUIE_STRING_LAM_UF_WHITELIST_CLEAR),
        text = zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG), GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST)),
        callback = function (dialog)
            UnitFrames.ClearCustomList(UnitFrames.SV.whitelist)
            LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(UnitFrames.SV.whitelist))
            UnitFrames.CustomPetUpdate()
        end,
    },
}

local function loadDialogButtons()
    for i = 1, #dialogs do
        local dialog = dialogs[i]
        LUIE.RegisterDialogueButton(dialog.identifier, dialog.title, dialog.text, dialog.callback)
    end
end

-- Load LibAddonMenu
local LAM = LUIE.LAM

function UnitFrames.CreateSettings()
    local Defaults = UnitFrames.Defaults
    local Settings = UnitFrames.SV

    if not LUIE.SV.UnitFrames_Enabled then
        return
    end

    -- Load Dialog Buttons
    loadDialogButtons()

    local panelDataUnitFrames =
    {
        type = "panel",
        name = LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_UF),
        displayName = LUIE.FormatAddonSettingsPanelDisplayName(LUIE_STRING_LAM_UF),
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luiuf",
        registerForRefresh = true,
        registerForDefaults = true,
        resetFunc = function ()
            -- LAM resets option values only; frame layout stays on the Reset Position button.
            UnitFrames.CustomFramesSetMovingState(false)
        end,
    }

    local optionsDataUnitFrames = {}

    -- Unit Frames module description
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "description",
        text = GetString(LUIE_STRING_LAM_UF_DESCRIPTION),
    }

    -- ReloadUI Button
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        func = function ()
            ReloadUI("ingame")
        end,
        width = "full",
    }

    -- Custom Unit Frames Unlock (canonical state: UnitFrames.CustomFramesMovingState, see _MenuFunctions CustomFramesSetMovingState)
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMES_UNLOCK),
        tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_UNLOCK_TP),
        getFunc = function ()
            return UnitFrames.CustomFramesMovingState == true
        end,
        setFunc = function (value)
            UnitFrames.CustomFramesSetMovingState(value)
        end,
        width = "half",
        default = false,
        resetFunc = function ()
            UnitFrames.CustomFramesSetMovingState(false)
        end,
    }

    -- Grid Snap Settings for Unit Frames
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "checkbox",
        name = zo_strformat(GetString(LUIE_STRING_SHARED_GRID_SNAP_ENABLE), GetString(LUIE_STRING_LAM_UF)),
        tooltip = zo_strformat(GetString(LUIE_STRING_SHARED_GRID_SNAP_ENABLE_TP), GetString(LUIE_STRING_LAM_UF)),
        getFunc = function ()
            return _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGrid_unitFrames
        end,
        setFunc = function (value)
            local accountWideSettings = _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGrid_unitFrames = value
            local gridSize = accountWideSettings.snapToGridSize_default or 15
            GridOverlay.Refresh("unitFrames", (UnitFrames.CustomFramesMovingState == true) and value, gridSize)
        end,
        width = "half",
        default = false,
    }

    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "slider",
        name = zo_strformat(GetString(LUIE_STRING_SHARED_GRID_SNAP_SIZE), GetString(LUIE_STRING_LAM_UF)),
        tooltip = zo_strformat(GetString(LUIE_STRING_SHARED_GRID_SNAP_SIZE_TP), GetString(LUIE_STRING_LAM_UF)),
        min = 5,
        max = 100,
        step = 5,
        getFunc = function ()
            return _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGridSize_default or 15
        end,
        setFunc = function (value)
            local accountWideSettings = _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGridSize_default = value
            GridOverlay.Refresh("unitFrames", (UnitFrames.CustomFramesMovingState == true) and accountWideSettings.snapToGrid_unitFrames, value)
        end,
        width = "half",
        default = 15,
        disabled = function ()
            return not _G[LUIE.SVName][LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile][GetDisplayName()]["$AccountWide"].snapToGrid_unitFrames
        end,
    }

    -- Custom Unit Frames Reset position
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RESETPOSITION),
        tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_RESETPOSIT_TP),
        func = function ()
            UnitFrames.CustomFramesResetPosition(false)
        end,
        width = "half",
    }

    -- Unit Frames - Default Unit Frames Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_DFRAMES_HEADER),
        controls =
        {
            {
                -- Default PLAYER frame
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_PLAYER),
                choices = UnitFrames.GetDefaultFramesOptions("Player"),
                getFunc = function ()
                    return UnitFrames.GetDefaultFramesSetting("Player")
                end,
                setFunc = function (value)
                    UnitFrames.SetDefaultFramesSetting("Player", value)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                default = UnitFrames.GetDefaultFramesSetting("Player", true),
            },
            {
                -- Default TARGET frame
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_TARGET),
                choices = UnitFrames.GetDefaultFramesOptions("Target"),
                getFunc = function ()
                    return UnitFrames.GetDefaultFramesSetting("Target")
                end,
                setFunc = function (value)
                    UnitFrames.SetDefaultFramesSetting("Target", value)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                default = UnitFrames.GetDefaultFramesSetting("Target", true),
            },
            {
                -- Default small GROUP frame
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_GROUPSMALL),
                choices = UnitFrames.GetDefaultFramesOptions("Group"),
                getFunc = function ()
                    return UnitFrames.GetDefaultFramesSetting("Group")
                end,
                setFunc = function (value)
                    UnitFrames.SetDefaultFramesSetting("Group", value)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                default = UnitFrames.GetDefaultFramesSetting("Group", true),
            },
            {
                -- Compass Boss Bar
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_BOSS_COMPASS),
                choices = UnitFrames.GetDefaultFramesOptions("Boss"),
                getFunc = function ()
                    return UnitFrames.GetDefaultFramesSetting("Boss")
                end,
                setFunc = function (value)
                    UnitFrames.SetDefaultFramesSetting("Boss", value)
                    UnitFrames.ResetCompassBarMenu()
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                default = UnitFrames.GetDefaultFramesSetting("Boss", true),
            },
            {
                -- Reposition default player bars
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_REPOSIT),
                tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_REPOSIT_TP),
                getFunc = function ()
                    return Settings.RepositionFrames
                end,
                setFunc = function (value)
                    Settings.RepositionFrames = value
                    UnitFrames.RepositionDefaultFrames()
                end,
                width = "full",
                default = Defaults.RepositionFrames,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Reposition frames adjust Y Coordinates
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_VERT),
                tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_VERT_TP),
                min = -150,
                max = 300,
                step = 5,
                getFunc = function ()
                    return Settings.RepositionFramesAdjust
                end,
                setFunc = function (value)
                    Settings.RepositionFramesAdjust = value
                    UnitFrames.RepositionDefaultFrames()
                end,
                width = "full",
                default = Defaults.RepositionFramesAdjust,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Out-of-Combat bars transparency
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_OOCTRANS),
                tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_OOCTRANS_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.DefaultOocTransparency
                end,
                setFunc = function (value)
                    UnitFrames.SetDefaultFramesTransparency(value, nil)
                end,
                width = "full",
                default = Defaults.DefaultOocTransparency,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- In-Combat bars transparency
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_INCTRANS),
                tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_INCTRANS_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.DefaultIncTransparency
                end,
                setFunc = function (value)
                    UnitFrames.SetDefaultFramesTransparency(nil, value)
                end,
                width = "full",
                default = Defaults.DefaultIncTransparency,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Format label text
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                sort = "name-up",
                getFunc = function ()
                    return Settings.Format
                end,
                setFunc = function (var)
                    Settings.Format = var
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.Format,
            },
            SettingsAPI.CreateFontDropdown(
                GetString(LUIE_STRING_LAM_FONT),
                GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_TP),
                function ()
                    return Settings.DefaultFontFace
                end,
                function (var)
                    Settings.DefaultFontFace = var
                    UnitFrames.DefaultFramesApplyFont()
                end,
                "full",
                function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                Defaults.DefaultFontFace,
                nil,
                "name-up",
                function () return Settings.DefaultFontSize end,
                function () return Settings.DefaultFontStyle end
            ),
            {
                -- DefaultFrames Font Size
                type = "slider",
                name = GetString(LUIE_STRING_LAM_FONT_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_SIZE_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function ()
                    return Settings.DefaultFontSize
                end,
                setFunc = function (value)
                    Settings.DefaultFontSize = value
                    UnitFrames.DefaultFramesApplyFont()
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.DefaultFontSize,
            },
            SettingsAPI.CreateFontStyleDropdown(
                GetString(LUIE_STRING_LAM_FONT_STYLE),
                GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_STYLE_TP),
                function ()
                    return Settings.DefaultFontStyle
                end,
                function (var)
                    Settings.DefaultFontStyle = var
                    UnitFrames.DefaultFramesApplyFont()
                end,
                function () return Settings.DefaultFontFace end,
                function () return Settings.DefaultFontSize end,
                "full",
                function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                Defaults.DefaultFontStyle
            ),
            {
                -- Color of text labels
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL_COLOR),
                getFunc = function ()
                    return unpack(Settings.DefaultTextColour)
                end,
                setFunc = function (r, g, b, a)
                    Settings.DefaultTextColour = { r, g, b, a }
                    UnitFrames.DefaultFramesApplyColor()
                end,
                width = "full",
                default =
                {
                    r = Defaults.DefaultTextColour[1],
                    g = Defaults.DefaultTextColour[2],
                    b = Defaults.DefaultTextColour[3],
                    a = Defaults.DefaultTextColour[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Color target name by reaction
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_TARGET_COLOR_REACTION),
                tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_COLOR_REACTION_TP),
                getFunc = function ()
                    return Settings.TargetColourByReaction
                end,
                setFunc = UnitFrames.TargetColorByReaction,
                width = "full",
                default = Defaults.TargetColourByReaction,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Target class icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_TARGET_ICON_CLASS),
                tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_ICON_CLASS_TP),
                getFunc = function ()
                    return Settings.TargetShowClass
                end,
                setFunc = function (value)
                    Settings.TargetShowClass = value
                end,
                width = "full",
                default = Defaults.TargetShowClass,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Target ignore/friend/guild icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_TARGET_ICON_GFI),
                tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_ICON_GFI_TP),
                getFunc = function ()
                    return Settings.TargetShowFriend
                end,
                setFunc = function (value)
                    Settings.TargetShowFriend = value
                end,
                width = "full",
                default = Defaults.TargetShowFriend,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMES_HEADER),
        controls =
        {
            {
                type = "submenu",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TEXTURE_HEADER),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TEXTURE_HEADER_TP),
                controls = UnitFrames.BuildLAMFontTextureSettingsSubmenu(Settings, Defaults, SettingsAPI),
            },
            {
                -- Custom Unit Frames Separate Shield Bar
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_TP),
                getFunc = function ()
                    return Settings.CustomShieldBarSeparate
                end,
                setFunc = function (value)
                    Settings.CustomShieldBarSeparate = value
                    if value then
                        Settings.CustomShieldBarFull = false
                    end
                    UnitFrames.OnCustomShieldBarSettingsChanged(true)
                end,
                width = "full",
                default = Defaults.CustomShieldBarSeparate,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Shield Bar Height
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_HEIGHT)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_HEIGHT_TP),
                min = 4,
                max = 12,
                step = 1,
                getFunc = function ()
                    return Settings.CustomShieldBarHeight
                end,
                setFunc = function (value)
                    Settings.CustomShieldBarHeight = value
                    UnitFrames.OnCustomShieldBarSettingsChanged(true)
                end,
                width = "full",
                default = Defaults.CustomShieldBarHeight,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomShieldBarSeparate or not Settings.CustomShieldBarFull))
                end,
            },
            {
                -- Custom Unit Frames Overlay Full Height Shield Bar
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_OVERLAY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_OVERLAY_TP),
                getFunc = function ()
                    return Settings.CustomShieldBarFull
                end,
                setFunc = function (value)
                    Settings.CustomShieldBarFull = value
                    UnitFrames.OnCustomShieldBarSettingsChanged(false)
                end,
                width = "full",
                default = Defaults.CustomShieldBarFull,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and not Settings.CustomShieldBarSeparate)
                end,
            },
            {
                -- Shield Transparency
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_ALPHA),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_ALPHA_TP),
                min = 0,
                max = 100,
                step = 1,
                getFunc = function ()
                    return Settings.ShieldAlpha
                end,
                setFunc = function (value)
                    Settings.ShieldAlpha = value
                    UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
                end,
                width = "full",
                default = Defaults.ShieldAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and not Settings.CustomShieldBarSeparate)
                end,
            },
            {
                -- Custom Unit Frames Smooth Bar Transition
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_SMOOTHBARTRANS),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SMOOTHBARTRANS_TP),
                getFunc = function ()
                    return Settings.CustomSmoothBar
                end,
                setFunc = function (value)
                    Settings.CustomSmoothBar = value
                end,
                width = "full",
                default = Defaults.CustomSmoothBar,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Target Marker
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_TARGET_MARKER_NAME_FORMAT_TP),
                tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_MARKER_NAME_FORMAT_TP),
                getFunc = function ()
                    return Settings.CustomTargetMarker
                end,
                setFunc = function (value)
                    Settings.CustomTargetMarker = value
                end,
                width = "full",
                default = Defaults.CustomTargetMarker,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Target Quick Hide Dead Enemy/Neutral
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_TARGET_QUICK_HIDE_DEAD_TP),
                tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_QUICK_HIDE_DEAD_TP),
                getFunc = function ()
                    return Settings.QuickHideDead
                end,
                setFunc = function (value)
                    Settings.QuickHideDead = value
                end,
                width = "full",
                default = Defaults.QuickHideDead,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_QUICKHIDE_UNITMONSTER),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_QUICKHIDE_UNITMONSTER_TP),
                getFunc = function ()
                    return Settings.QuickHideDeadUseUnitMonster
                end,
                setFunc = function (value)
                    Settings.QuickHideDeadUseUnitMonster = value
                end,
                width = "full",
                default = Defaults.QuickHideDeadUseUnitMonster,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.QuickHideDead)
                end,
            },
            {
                -- Hide Player Frame When Dead
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_HIDE_PLAYER_FRAME_DEATH),
                tooltip = GetString(LUIE_STRING_LAM_UF_HIDE_PLAYER_FRAME_DEATH_TP),
                getFunc = function ()
                    return Settings.HidePlayerFrameOnDeath
                end,
                setFunc = function (value)
                    Settings.HidePlayerFrameOnDeath = value
                    UnitFrames.UpdatePlayerFrameDeathVisibility()
                end,
                width = "full",
                default = Defaults.HidePlayerFrameOnDeath,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Keep Target Frame Visible in Cursor Mode
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_TARGET_LINGER_CURSOR),
                tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_LINGER_CURSOR_TP),
                getFunc = function ()
                    return Settings.TargetLingerInCursorMode
                end,
                setFunc = function (value)
                    Settings.TargetLingerInCursorMode = value
                end,
                width = "full",
                default = Defaults.TargetLingerInCursorMode,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_TARGET_LINGER_DURATION),
                tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_LINGER_DURATION_TP),
                min = 0,
                max = 30,
                step = 5,
                getFunc = function ()
                    return Settings.TargetLingerDuration
                end,
                setFunc = function (value)
                    Settings.TargetLingerDuration = value
                end,
                width = "full",
                default = Defaults.TargetLingerDuration,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget and Settings.TargetLingerInCursorMode)
                end,
            },
        },
    }
    -- Unit Frames - Custom Unit Frame Color Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEADER),
        controls =
        {
            {
                -- Custom Unit Frames Health Bar Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEALTH),
                getFunc = function ()
                    return unpack(Settings.CustomColourHealth)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourHealth = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourHealth[1],
                    g = Defaults.CustomColourHealth[2],
                    b = Defaults.CustomColourHealth[3],
                    a = Defaults.CustomColourHealth[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Shield Bar Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_SHIELD),
                getFunc = function ()
                    return Settings.CustomColourShield[1], Settings.CustomColourShield[2], Settings.CustomColourShield[3]
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourShield = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourShield[1],
                    g = Defaults.CustomColourShield[2],
                    b = Defaults.CustomColourShield[3],
                    a = Defaults.CustomColourShield[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Trauma Bar Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TRAUMA),
                getFunc = function ()
                    return Settings.CustomColourTrauma[1], Settings.CustomColourTrauma[2], Settings.CustomColourTrauma[3]
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourTrauma = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourTrauma[1],
                    g = Defaults.CustomColourTrauma[2],
                    b = Defaults.CustomColourTrauma[3],
                    a = Defaults.CustomColourTrauma[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Magicka Bar Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_MAGICKA),
                getFunc = function ()
                    return unpack(Settings.CustomColourMagicka)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourMagicka = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuPlayerMagickaStaminaOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourMagicka[1],
                    g = Defaults.CustomColourMagicka[2],
                    b = Defaults.CustomColourMagicka[3],
                    a = Defaults.CustomColourMagicka[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Stamina Bar Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_STAMINA),
                getFunc = function ()
                    return unpack(Settings.CustomColourStamina)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourStamina = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuPlayerMagickaStaminaOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourStamina[1],
                    g = Defaults.CustomColourStamina[2],
                    b = Defaults.CustomColourStamina[3],
                    a = Defaults.CustomColourStamina[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Invulnerable Bar Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_INVULNERABLE),
                getFunc = function ()
                    return Settings.CustomColourInvulnerable[1], Settings.CustomColourInvulnerable[2], Settings.CustomColourInvulnerable[3]
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourInvulnerable = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourInvulnerable[1],
                    g = Defaults.CustomColourInvulnerable[2],
                    b = Defaults.CustomColourInvulnerable[3],
                    a = Defaults.CustomColourInvulnerable[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames DPS Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_DPS),
                getFunc = function ()
                    return unpack(Settings.CustomColourDPS)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourDPS = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourDPS[1],
                    g = Defaults.CustomColourDPS[2],
                    b = Defaults.CustomColourDPS[3],
                    a = Defaults.CustomColourDPS[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Healer Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEALER),
                getFunc = function ()
                    return unpack(Settings.CustomColourHealer)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourHealer = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourHealer[1],
                    g = Defaults.CustomColourHealer[2],
                    b = Defaults.CustomColourHealer[3],
                    a = Defaults.CustomColourHealer[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Tank Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TANK),
                getFunc = function ()
                    return unpack(Settings.CustomColourTank)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourTank = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourTank[1],
                    g = Defaults.CustomColourTank[2],
                    b = Defaults.CustomColourTank[3],
                    a = Defaults.CustomColourTank[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Dragonknight Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_DK),
                getFunc = function ()
                    return unpack(Settings.CustomColourDragonknight)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourDragonknight = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourDragonknight[1],
                    g = Defaults.CustomColourDragonknight[2],
                    b = Defaults.CustomColourDragonknight[3],
                    a = Defaults.CustomColourDragonknight[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Nightblade Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_NB),
                getFunc = function ()
                    return unpack(Settings.CustomColourNightblade)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourNightblade = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourNightblade[1],
                    g = Defaults.CustomColourNightblade[2],
                    b = Defaults.CustomColourNightblade[3],
                    a = Defaults.CustomColourNightblade[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Sorcerer Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_SORC),
                getFunc = function ()
                    return unpack(Settings.CustomColourSorcerer)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourSorcerer = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourSorcerer[1],
                    g = Defaults.CustomColourSorcerer[2],
                    b = Defaults.CustomColourSorcerer[3],
                    a = Defaults.CustomColourSorcerer[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Templar Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TEMP),
                getFunc = function ()
                    return unpack(Settings.CustomColourTemplar)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourTemplar = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourTemplar[1],
                    g = Defaults.CustomColourTemplar[2],
                    b = Defaults.CustomColourTemplar[3],
                    a = Defaults.CustomColourTemplar[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Warden Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_WARD),
                getFunc = function ()
                    return unpack(Settings.CustomColourWarden)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourWarden = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourWarden[1],
                    g = Defaults.CustomColourWarden[2],
                    b = Defaults.CustomColourWarden[3],
                    a = Defaults.CustomColourWarden[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Necromancer Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_NECRO),
                getFunc = function ()
                    return unpack(Settings.CustomColourNecromancer)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourNecromancer = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourNecromancer[1],
                    g = Defaults.CustomColourNecromancer[2],
                    b = Defaults.CustomColourNecromancer[3],
                    a = Defaults.CustomColourNecromancer[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Arcanist Role Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_ARCA),
                getFunc = function ()
                    return unpack(Settings.CustomColourArcanist)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourArcanist = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourArcanist[1],
                    g = Defaults.CustomColourArcanist[2],
                    b = Defaults.CustomColourArcanist[3],
                    a = Defaults.CustomColourArcanist[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },

            {
                -- Custom Unit Reaction color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_PLAYER),
                getFunc = function ()
                    return unpack(Settings.CustomColourPlayer)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourPlayer = { r, g, b, a }
                    UnitFrames.CustomFramesApplyReactionColorForMenu()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourPlayer[1],
                    g = Defaults.CustomColourPlayer[2],
                    b = Defaults.CustomColourPlayer[3],
                    a = Defaults.CustomColourPlayer[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Reaction color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_FRIENDLY),
                getFunc = function ()
                    return unpack(Settings.CustomColourFriendly)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourFriendly = { r, g, b, a }
                    UnitFrames.CustomFramesApplyReactionColorForMenu()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourFriendly[1],
                    g = Defaults.CustomColourFriendly[2],
                    b = Defaults.CustomColourFriendly[3],
                    a = Defaults.CustomColourFriendly[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Reaction color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_COMPANION),
                getFunc = function ()
                    return unpack(Settings.CustomColourCompanion)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourCompanion = { r, g, b, a }
                    UnitFrames.CustomFramesApplyReactionColorForMenu()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourCompanion[1],
                    g = Defaults.CustomColourCompanion[2],
                    b = Defaults.CustomColourCompanion[3],
                    a = Defaults.CustomColourCompanion[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Reaction color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_HOSTILE),
                getFunc = function ()
                    return unpack(Settings.CustomColourHostile)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourHostile = { r, g, b, a }
                    UnitFrames.CustomFramesApplyReactionColorForMenu()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourHostile[1],
                    g = Defaults.CustomColourHostile[2],
                    b = Defaults.CustomColourHostile[3],
                    a = Defaults.CustomColourHostile[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Reaction color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_NEUTRAL),
                getFunc = function ()
                    return unpack(Settings.CustomColourNeutral)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourNeutral = { r, g, b, a }
                    UnitFrames.CustomFramesApplyReactionColorForMenu()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourNeutral[1],
                    g = Defaults.CustomColourNeutral[2],
                    b = Defaults.CustomColourNeutral[3],
                    a = Defaults.CustomColourNeutral[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Reaction color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_GUARD),
                getFunc = function ()
                    return unpack(Settings.CustomColourGuard)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourGuard = { r, g, b, a }
                    UnitFrames.CustomFramesApplyReactionColorForMenu()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourGuard[1],
                    g = Defaults.CustomColourGuard[2],
                    b = Defaults.CustomColourGuard[3],
                    a = Defaults.CustomColourGuard[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Custom Unit Frames Pet Bar Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_COLOR),
                getFunc = function ()
                    return unpack(Settings.CustomColourPet)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourPet = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuPetFramesOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourPet[1],
                    g = Defaults.CustomColourPet[2],
                    b = Defaults.CustomColourPet[3],
                    a = Defaults.CustomColourPet[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },

            {
                -- Custom Unit Frames Companion Bar Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_COLOR),
                getFunc = function ()
                    return unpack(Settings.CustomColourCompanionFrame)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CustomColourCompanionFrame = { r, g, b, a }
                    UnitFrames.CustomFramesApplyColorsMenuCompanionFrameOnly()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourCompanionFrame[1],
                    g = Defaults.CustomColourCompanionFrame[2],
                    b = Defaults.CustomColourCompanionFrame[3],
                    a = Defaults.CustomColourCompanionFrame[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (Player) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_HEADER),
        controls =
        {
            {
                -- Enable LUIE PLAYER frame
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_PLAYER),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_PLAYER_TP),
                getFunc = function ()
                    return Settings.CustomFramesPlayer
                end,
                setFunc = function (value)
                    Settings.CustomFramesPlayer = value
                end,
                width = "full",
                default = Defaults.CustomFramesPlayer,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Player Name Display Method (Player)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_PLAYER),
                tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_PLAYER_TP),
                choices = nameDisplayOptions,
                sort = "name-up",
                getFunc = function ()
                    return nameDisplayOptions[Settings.DisplayOptionsPlayer]
                end,
                setFunc = function (value)
                    Settings.DisplayOptionsPlayer = nameDisplayOptionsKeys[value]
                    UnitFrames.CustomFramesReloadControlsMenu(false, nil, nil, false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = nameDisplayOptions[2],
            },
            {
                -- Custom Unit Frames format left label
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomFormatOnePlayer
                end,
                setFunc = function (var)
                    Settings.CustomFormatOnePlayer = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFormatOnePlayer,
            },
            {
                -- Custom Unit Frames format right label
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomFormatTwoPlayer
                end,
                setFunc = function (var)
                    Settings.CustomFormatTwoPlayer = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFormatTwoPlayer,
            },
            {
                -- Player Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_WIDTH),
                min = 200,
                max = 1000,
                step = 5,
                getFunc = function ()
                    return Settings.PlayerBarWidth
                end,
                setFunc = function (value)
                    Settings.PlayerBarWidth = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerBarWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Player Health Bar Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_HIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.PlayerBarHeightHealth
                end,
                setFunc = function (value)
                    Settings.PlayerBarHeightHealth = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerBarHeightHealth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Player Magicka Bar Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_HIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.PlayerBarHeightMagicka
                end,
                setFunc = function (value)
                    Settings.PlayerBarHeightMagicka = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerBarHeightMagicka,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Player Stamina Bar Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_HIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.PlayerBarHeightStamina
                end,
                setFunc = function (value)
                    Settings.PlayerBarHeightStamina = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerBarHeightStamina,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Out-of-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_OOCPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_OOCPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.PlayerOocAlpha
                end,
                setFunc = function (value)
                    Settings.PlayerOocAlpha = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.PlayerOocAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- In-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_ICPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_ICPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.PlayerIncAlpha
                end,
                setFunc = function (value)
                    Settings.PlayerIncAlpha = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.PlayerIncAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- HIDE BUFFS OOC - PLAYER
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BuFFS_PLAYER),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BuFFS_PLAYER_TP),
                getFunc = function ()
                    return Settings.HideBuffsPlayerOoc
                end,
                setFunc = function (value)
                    Settings.HideBuffsPlayerOoc = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.HideBuffsPlayerOoc,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Display self name on Player Frame
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_NAMESELF),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_NAMESELF_TP),
                getFunc = function ()
                    return Settings.PlayerEnableYourname
                end,
                setFunc = function (value)
                    Settings.PlayerEnableYourname = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerEnableYourname,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Display Mount/Siege/Werewolf Bar
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MOUNTSIEGEWWBAR),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MOUNTSIEGEWWBAR_TP),
                getFunc = function ()
                    return Settings.PlayerEnableAltbarMSW
                end,
                setFunc = function (value)
                    Settings.PlayerEnableAltbarMSW = value
                    UnitFrames.CustomFramesSetupAlternative()
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerEnableAltbarMSW,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Display XP/Champion XP Bar
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBAR),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBAR_TP),
                getFunc = function ()
                    return Settings.PlayerEnableAltbarXP
                end,
                setFunc = function (value)
                    Settings.PlayerEnableAltbarXP = value
                    UnitFrames.CustomFramesSetupAlternative()
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerEnableAltbarXP,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Champion XP Bar Point-Type Color
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBARCOLOR)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBARCOLOR_TP),
                getFunc = function ()
                    return Settings.PlayerChampionColour
                end,
                setFunc = function (value)
                    Settings.PlayerChampionColour = value
                    UnitFrames.OnChampionPointGained()
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerChampionColour,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerEnableAltbarXP)
                end,
            },
            {
                -- Custom Unit Frames Low Health Warning
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_HEALTH),
                tooltip = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_HEALTH_TP),
                min = 0,
                max = 50,
                step = 1,
                getFunc = function ()
                    return Settings.LowResourceHealth
                end,
                setFunc = function (value)
                    Settings.LowResourceHealth = value
                    UnitFrames.CustomFramesReloadLowResourceThreshold()
                end,
                width = "full",
                default = Defaults.LowResourceHealth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Custom Unit Frames Low Magicka Warning
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_MAGICKA),
                tooltip = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_MAGICKA_TP),
                min = 0,
                max = 50,
                step = 1,
                getFunc = function ()
                    return Settings.LowResourceMagicka
                end,
                setFunc = function (value)
                    Settings.LowResourceMagicka = value
                    UnitFrames.CustomFramesReloadLowResourceThreshold()
                end,
                width = "full",
                default = Defaults.LowResourceMagicka,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Custom Unit Frames Low Stamina Warning
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_STAMINA),
                tooltip = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_STAMINA_TP),
                min = 0,
                max = 50,
                step = 1,
                getFunc = function ()
                    return Settings.LowResourceStamina
                end,
                setFunc = function (value)
                    Settings.LowResourceStamina = value
                    UnitFrames.CustomFramesReloadLowResourceThreshold()
                end,
                width = "full",
                default = Defaults.LowResourceStamina,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_PLAYER_DODGE_PREDICTION),
                tooltip = GetString(LUIE_STRING_LAM_UF_PLAYER_DODGE_PREDICTION_TP),
                getFunc = function ()
                    return Settings.ShowPlayerDodgePrediction
                end,
                setFunc = function (value)
                    Settings.ShowPlayerDodgePrediction = value
                    UnitFrames.PlayerDodgePrediction.Refresh()
                end,
                width = "full",
                default = Defaults.ShowPlayerDodgePrediction,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_PLAYER_DODGE_PREDICTION_COLOR)),
                tooltip = GetString(LUIE_STRING_LAM_UF_PLAYER_DODGE_PREDICTION_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.PlayerDodgePredictionColor)
                end,
                setFunc = function (r, g, b, a)
                    Settings.PlayerDodgePredictionColor = { r, g, b, a }
                    UnitFrames.PlayerDodgePrediction.Refresh()
                end,
                width = "full",
                default =
                {
                    r = Defaults.PlayerDodgePredictionColor[1],
                    g = Defaults.PlayerDodgePredictionColor[2],
                    b = Defaults.PlayerDodgePredictionColor[3],
                    a = Defaults.PlayerDodgePredictionColor[4],
                },
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.ShowPlayerDodgePrediction)
                end,
            },
            {
                -- Display Armor stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PLAYER)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
                getFunc = function ()
                    return Settings.PlayerEnableArmor
                end,
                setFunc = function (value)
                    Settings.PlayerEnableArmor = value
                end,
                width = "full",
                default = Defaults.PlayerEnableArmor,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Display Power stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PLAYER)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
                getFunc = function ()
                    return Settings.PlayerEnablePower
                end,
                setFunc = function (value)
                    Settings.PlayerEnablePower = value
                end,
                width = "full",
                default = Defaults.PlayerEnablePower,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Custom Unit Frames Display HoT / DoT Animations
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PLAYER)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
                getFunc = function ()
                    return Settings.PlayerEnableRegen
                end,
                setFunc = function (value)
                    Settings.PlayerEnableRegen = value
                end,
                width = "full",
                default = Defaults.PlayerEnableRegen,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_VETERANCY_RANK),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_VETERANCY_RANK_TP),
                getFunc = function ()
                    return Settings.PlayerShowVeterancyRank
                end,
                setFunc = function (value)
                    Settings.PlayerShowVeterancyRank = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.PlayerShowVeterancyRank,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_OVERLAND_DIFFICULTY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_OVERLAND_DIFFICULTY_TP),
                getFunc = function ()
                    return Settings.PlayerShowOverlandDifficulty
                end,
                setFunc = function (value)
                    Settings.PlayerShowOverlandDifficulty = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.PlayerShowOverlandDifficulty,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Treat Missing Power as In-Combat
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT_TP),
                getFunc = function ()
                    return Settings.PlayerOocAlphaPower
                end,
                setFunc = function (value)
                    Settings.PlayerOocAlphaPower = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.PlayerOocAlphaPower,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (Target) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESTARGET_HEADER),
        controls =
        {
            {
                -- Enable LUIE Target frame
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_TARGET_TP),
                getFunc = function ()
                    return Settings.CustomFramesTarget
                end,
                setFunc = function (value)
                    Settings.CustomFramesTarget = value
                end,
                width = "full",
                default = Defaults.CustomFramesTarget,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Player Name Display Method (Target)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_TARGET_TP),
                choices = nameDisplayOptions,
                sort = "name-up",
                getFunc = function ()
                    return nameDisplayOptions[Settings.DisplayOptionsTarget]
                end,
                setFunc = function (value)
                    Settings.DisplayOptionsTarget = nameDisplayOptionsKeys[value]
                    UnitFrames.CustomFramesReloadControlsMenu(false, nil, nil, false, false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = nameDisplayOptions[2],
            },
            {
                -- Custom Unit Frames format left label
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomFormatOneTarget
                end,
                setFunc = function (var)
                    Settings.CustomFormatOneTarget = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFormatOneTarget,
            },
            {
                -- Custom Unit Frames format right label
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomFormatTwoTarget
                end,
                setFunc = function (var)
                    Settings.CustomFormatTwoTarget = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFormatTwoTarget,
            },
            {
                -- Target Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_WIDTH),
                min = 200,
                max = 1000,
                step = 5,
                getFunc = function ()
                    return Settings.TargetBarWidth
                end,
                setFunc = function (value)
                    Settings.TargetBarWidth = value
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                default = Defaults.TargetBarWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Target Bars Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_HEIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.TargetBarHeight
                end,
                setFunc = function (value)
                    Settings.TargetBarHeight = value
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                default = Defaults.TargetBarHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Out-of-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_OOCPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_OOCPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.TargetOocAlpha
                end,
                setFunc = function (value)
                    Settings.TargetOocAlpha = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.TargetOocAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- In-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_ICPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_ICPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.TargetIncAlpha
                end,
                setFunc = function (value)
                    Settings.TargetIncAlpha = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.TargetIncAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- HIDE BUFFS OOC - TARGET
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BUFFS_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BUFFS_TARGET_TP),
                getFunc = function ()
                    return Settings.HideBuffsTargetOoc
                end,
                setFunc = function (value)
                    Settings.HideBuffsTargetOoc = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.HideBuffsTargetOoc,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Color Target by Reaction
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_REACTION_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_REACTION_TARGET_TP),
                getFunc = function ()
                    return Settings.FrameColorReaction
                end,
                setFunc = function (value)
                    Settings.FrameColorReaction = value
                    UnitFrames.CustomFramesApplyReactionColor()
                end,
                width = "full",
                default = Defaults.FrameColorReaction,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Color Target by Class
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_CLASS_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_CLASS_TARGET_TP),
                getFunc = function ()
                    return Settings.FrameColorClass
                end,
                setFunc = function (value)
                    Settings.FrameColorClass = value
                    UnitFrames.CustomFramesApplyReactionColor()
                end,
                width = "full",
                default = Defaults.FrameColorClass,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Display Target Class Label
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_CLASSLABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_CLASSLABEL_TP),
                getFunc = function ()
                    return Settings.TargetEnableClass
                end,
                setFunc = function (value)
                    Settings.TargetEnableClass = value
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                default = Defaults.TargetEnableClass,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Display Target Friend Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_FRIEND_ICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_FRIEND_ICON_TP),
                getFunc = function ()
                    return Settings.CustomTargetShowFriendIcon
                end,
                setFunc = function (value)
                    Settings.CustomTargetShowFriendIcon = value
                    UnitFrames.RefreshCustomTargetFrameStaticControls()
                end,
                width = "full",
                default = Defaults.CustomTargetShowFriendIcon,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_GUILD_ICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_GUILD_ICON_TP),
                getFunc = function ()
                    return Settings.CustomTargetShowGuildIcon
                end,
                setFunc = function (value)
                    Settings.CustomTargetShowGuildIcon = value
                    UnitFrames.RefreshCustomTargetFrameStaticControls()
                end,
                width = "full",
                default = Defaults.CustomTargetShowGuildIcon,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_IGNORED_ICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_IGNORED_ICON_TP),
                getFunc = function ()
                    return Settings.CustomTargetShowIgnoredIcon
                end,
                setFunc = function (value)
                    Settings.CustomTargetShowIgnoredIcon = value
                    UnitFrames.RefreshCustomTargetFrameStaticControls()
                end,
                width = "full",
                default = Defaults.CustomTargetShowIgnoredIcon,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Execute Health % Threshold
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETHRESHOLD),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETHRESHOLD_TP),
                min = 0,
                max = 50,
                step = 5,
                getFunc = function ()
                    return Settings.ExecutePercentage
                end,
                setFunc = function (value)
                    Settings.ExecutePercentage = value
                    UnitFrames.CustomFramesReloadExecuteMenu()
                end,
                width = "full",
                default = Defaults.ExecutePercentage,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Display Skull Execute Texture
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETEXTURE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETEXTURE_TP),
                getFunc = function ()
                    return Settings.TargetEnableSkull
                end,
                setFunc = function (value)
                    Settings.TargetEnableSkull = value
                end,
                width = "full",
                default = Defaults.TargetEnableSkull,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Display title on target frame
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TITLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TITLE_TP),
                getFunc = function ()
                    return Settings.TargetEnableTitle
                end,
                setFunc = function (value)
                    Settings.TargetEnableTitle = value
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                default = Defaults.TargetEnableTitle,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_VETERANCY_RANK),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_VETERANCY_RANK_TP),
                getFunc = function ()
                    return Settings.TargetShowVeterancyRank
                end,
                setFunc = function (value)
                    Settings.TargetShowVeterancyRank = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.TargetShowVeterancyRank,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_OVERLAND_DIFFICULTY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_OVERLAND_DIFFICULTY_TP),
                getFunc = function ()
                    return Settings.TargetShowOverlandDifficulty
                end,
                setFunc = function (value)
                    Settings.TargetShowOverlandDifficulty = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.TargetShowOverlandDifficulty,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MONSTER_OVERLAND),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MONSTER_OVERLAND_TP),
                getFunc = function ()
                    return Settings.TargetMonsterOverlandDifficulty
                end,
                setFunc = function (value)
                    Settings.TargetMonsterOverlandDifficulty = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.TargetMonsterOverlandDifficulty,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget and Settings.TargetShowOverlandDifficulty)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MONSTER_CLASSICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MONSTER_CLASSICON_TP),
                getFunc = function ()
                    return Settings.TargetHighlightMonsterUnits
                end,
                setFunc = function (value)
                    Settings.TargetHighlightMonsterUnits = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.TargetHighlightMonsterUnits,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Display rank name on target frame
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TP),
                getFunc = function ()
                    return Settings.TargetEnableRank
                end,
                setFunc = function (value)
                    Settings.TargetEnableRank = value
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                default = Defaults.TargetEnableRank,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Prioritize Title or AvA Rank
                type = "dropdown",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TITLE_PRIORITY)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TITLE_PRIORITY_TP),
                choices = targetTitlePriorityChoices,
                choicesValues = targetTitlePriorityValues,
                getFunc = function ()
                    return Settings.TargetTitlePriority
                end,
                setFunc = function (value)
                    Settings.TargetTitlePriority = value
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                default = Defaults.TargetTitlePriority,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget and Settings.TargetEnableRank and Settings.TargetEnableTitle)
                end,
            },
            {
                -- Display rank icon on target frame
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANKICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANKICON_TP),
                getFunc = function ()
                    return Settings.TargetEnableRankIcon
                end,
                setFunc = function (value)
                    Settings.TargetEnableRankIcon = value
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                default = Defaults.TargetEnableRankIcon,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Display Armor stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_TARGET)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
                getFunc = function ()
                    return Settings.TargetEnableArmor
                end,
                setFunc = function (value)
                    Settings.TargetEnableArmor = value
                end,
                width = "full",
                default = Defaults.TargetEnableArmor,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Display Power stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_TARGET)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
                getFunc = function ()
                    return Settings.TargetEnablePower
                end,
                setFunc = function (value)
                    Settings.TargetEnablePower = value
                end,
                width = "full",
                default = Defaults.TargetEnablePower,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Custom Unit Frames Display HoT / DoT Animations
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_TARGET)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
                getFunc = function ()
                    return Settings.TargetEnableRegen
                end,
                setFunc = function (value)
                    Settings.TargetEnableRegen = value
                end,
                width = "full",
                default = Defaults.TargetEnableRegen,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
            {
                -- Treat Missing Power as In-Combat
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT_TP),
                getFunc = function ()
                    return Settings.TargetOocAlphaPower
                end,
                setFunc = function (value)
                    Settings.TargetOocAlphaPower = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.TargetOocAlphaPower,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },
        },
    }

    -- Unit Frames -- Custom Unit Frames Bar Alignment
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_HEADER),
        controls =
        {
            {
                -- Alignment Player Health Bar
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_HEALTH),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_HEALTH_TP),
                choices = alignmentOptions,
                getFunc = function ()
                    return alignmentOptions[Settings.BarAlignPlayerHealth]
                end,
                setFunc = function (value)
                    Settings.BarAlignPlayerHealth = alignmentOptionsKeys[value]
                    UnitFrames.CustomFramesApplyBarAlignment()
                end,
                width = "full",
                default = alignmentOptions[Defaults.BarAlignPlayerHealth],
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Alignment Player Magicka Bar
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_MAGICKA),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_MAGICKA_TP),
                choices = alignmentOptions,
                getFunc = function ()
                    return alignmentOptions[Settings.BarAlignPlayerMagicka]
                end,
                setFunc = function (value)
                    Settings.BarAlignPlayerMagicka = alignmentOptionsKeys[value]
                    UnitFrames.CustomFramesApplyBarAlignment()
                end,
                width = "full",
                default = alignmentOptions[Defaults.BarAlignPlayerMagicka],
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Alignment Player Stamina Bar
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_STAMINA),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_STAMINA_TP),
                choices = alignmentOptions,
                getFunc = function ()
                    return alignmentOptions[Settings.BarAlignPlayerStamina]
                end,
                setFunc = function (value)
                    Settings.BarAlignPlayerStamina = alignmentOptionsKeys[value]
                    UnitFrames.CustomFramesApplyBarAlignment()
                end,
                width = "full",
                default = alignmentOptions[Defaults.BarAlignPlayerStamina],
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Alignment Target Health Bar
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_TARGET_TP),
                choices = alignmentOptions,
                getFunc = function ()
                    return alignmentOptions[Settings.BarAlignTarget]
                end,
                setFunc = function (value)
                    Settings.BarAlignTarget = alignmentOptionsKeys[value]
                    UnitFrames.CustomFramesApplyBarAlignment()
                end,
                width = "full",
                default = alignmentOptions[Defaults.BarAlignTarget],
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
                end,
            },

            {
                -- Center Label for Player Bars
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_PLAYER),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_PLAYER_TP),
                getFunc = function ()
                    return Settings.BarAlignCenterLabelPlayer
                end,
                setFunc = function (value)
                    Settings.BarAlignCenterLabelPlayer = value
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.BarAlignCenterLabelPlayer,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Center Label for Target Bar
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_TARGET),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_TARGET_TP),
                getFunc = function ()
                    return Settings.BarAlignCenterLabelTarget
                end,
                setFunc = function (value)
                    Settings.BarAlignCenterLabelTarget = value
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                default = Defaults.BarAlignCenterLabelTarget,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Custom Unit Frames format left label
                type = "dropdown",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_CENTER_FORM)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_CENTER_FORM),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                getFunc = function ()
                    return Settings.CustomFormatCenterLabel
                end,
                setFunc = function (var)
                    Settings.CustomFormatCenterLabel = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFormatCenterLabel,
            },
        },
    }

    -- Unit Frames - Additional Player Frame Display Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_OPTIONS_HEADER),
        controls =
        {
            {
                -- Player Frames Display Method
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD_TP),
                choices = playerFrameOptions,
                getFunc = function ()
                    return playerFrameOptions[Settings.PlayerFrameOptions]
                end,
                setFunc = function (value)
                    Settings.PlayerFrameOptions = playerFrameOptionsKeys[value]
                    UnitFrames.MenuUpdatePlayerFrameOptions(Settings.PlayerFrameOptions)
                end,
                width = "full",
                warning = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD_WARN),
                default = playerFrameOptions[Defaults.PlayerFrameOptions],
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Position Adjust Horizontal
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_HORIZ_ADJUST)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_HORIZ_ADJUST_TP),
                min = 0,
                max = 500,
                step = 5,
                getFunc = function ()
                    return Settings.AdjustStaminaHPos
                end,
                setFunc = function (value)
                    Settings.AdjustStaminaHPos = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.AdjustStaminaHPos,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
                end,
            },
            {
                -- Position Adjust Vertical
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_VERT_ADJUST)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_VERT_ADJUST_TP),
                min = -250,
                max = 250,
                step = 5,
                getFunc = function ()
                    return Settings.AdjustStaminaVPos
                end,
                setFunc = function (value)
                    Settings.AdjustStaminaVPos = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.AdjustStaminaVPos,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
                end,
            },
            {
                -- Position Adjust
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_HORIZ_ADJUST)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_HORIZ_ADJUST_TP),
                min = 0,
                max = 500,
                step = 5,
                getFunc = function ()
                    return Settings.AdjustMagickaHPos
                end,
                setFunc = function (value)
                    Settings.AdjustMagickaHPos = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.AdjustMagickaHPos,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
                end,
            },
            {
                -- Position Adjust
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_VERT_ADJUST)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_VERT_ADJUST_TP),
                min = -250,
                max = 250,
                step = 5,
                getFunc = function ()
                    return Settings.AdjustMagickaVPos
                end,
                setFunc = function (value)
                    Settings.AdjustMagickaVPos = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.AdjustMagickaVPos,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
                end,
            },
            {
                -- Spacing between Player Bars
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_SPACING)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_SPACING_TP),
                min = -1,
                max = 4,
                step = 1,
                getFunc = function ()
                    return Settings.PlayerBarSpacing
                end,
                setFunc = function (value)
                    Settings.PlayerBarSpacing = value
                    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                end,
                width = "full",
                default = Defaults.PlayerBarSpacing,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and (Settings.PlayerFrameOptions == 1 or Settings.PlayerFrameOptions == 3))
                end,
            },
            {
                -- Hide Player Health Bar Label
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOLABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOLABEL_TP),
                getFunc = function ()
                    return Settings.HideLabelHealth
                end,
                setFunc = function (value)
                    Settings.HideLabelHealth = value
                    Settings.HideBarHealth = false
                    ApplyCustomPlayerHideBarLayout()
                end,
                width = "full",
                default = Defaults.HideLabelHealth,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Hide Player Health Bar
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOBAR)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOBAR_TP),
                getFunc = function ()
                    return Settings.HideBarHealth
                end,
                setFunc = function (value)
                    Settings.HideBarHealth = value
                    ApplyCustomPlayerHideBarLayout()
                end,
                width = "full",
                default = Defaults.HideBarHealth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelHealth)
                end,
            },
            {
                -- Hide Player Magicka Bar Label
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOLABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOLABEL_TP),
                getFunc = function ()
                    return Settings.HideLabelMagicka
                end,
                setFunc = function (value)
                    Settings.HideLabelMagicka = value
                    Settings.HideBarMagicka = false
                    ApplyCustomPlayerHideBarLayout()
                end,
                width = "full",
                default = Defaults.HideLabelMagicka,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Hide Player Magicka Bar
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOBAR)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOBAR_TP),
                getFunc = function ()
                    return Settings.HideBarMagicka
                end,
                setFunc = function (value)
                    Settings.HideBarMagicka = value
                    ApplyCustomPlayerHideBarLayout()
                end,
                width = "full",
                default = Defaults.HideBarMagicka,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelMagicka)
                end,
            },
            {
                -- Hide Player Stamina Bar Label
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOLABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOLABEL_TP),
                getFunc = function ()
                    return Settings.HideLabelStamina
                end,
                setFunc = function (value)
                    Settings.HideLabelStamina = value
                    Settings.HideBarStamina = false
                    ApplyCustomPlayerHideBarLayout()
                end,
                width = "full",
                default = Defaults.HideLabelStamina,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Hide Player Stamina Bar
                type = "checkbox",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOBAR)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOBAR_TP),
                getFunc = function ()
                    return Settings.HideBarStamina
                end,
                setFunc = function (value)
                    Settings.HideBarStamina = value
                    ApplyCustomPlayerHideBarLayout()
                end,
                width = "full",
                default = Defaults.HideBarStamina,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelStamina)
                end,
            },
            {
                -- Reverse Player Magicka and Stamina
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_REVERSE_RES),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_REVERSE_RES_TP),
                getFunc = function ()
                    return Settings.ReverseResourceBars
                end,
                setFunc = function (value)
                    Settings.ReverseResourceBars = value
                    ApplyCustomPlayerHideBarLayout()
                end,
                width = "full",
                default = Defaults.ReverseResourceBars,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (Group) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_HEADER),
        controls =
        {
            {
                -- Enable Group Frames
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_LUIEFRAMESENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_LUIEFRAMESENABLE_TP),
                getFunc = function ()
                    return Settings.CustomFramesGroup
                end,
                setFunc = function (value)
                    Settings.CustomFramesGroup = value
                end,
                width = "full",
                default = Defaults.CustomFramesGroup,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Player Name Display Method (Group/Raid)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID),
                tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID_TP),
                choices = nameDisplayOptions,
                getFunc = function ()
                    return nameDisplayOptions[Settings.DisplayOptionsGroupRaid]
                end,
                setFunc = function (value)
                    Settings.DisplayOptionsGroupRaid = nameDisplayOptionsKeys[value]
                    UnitFrames.CustomFramesReloadControlsMenu(false, false, false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = nameDisplayOptions[2],
            },
            {
                -- Custom Unit Frames format left label
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                getFunc = function ()
                    return Settings.CustomFormatOneGroup
                end,
                setFunc = function (var)
                    Settings.CustomFormatOneGroup = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                end,
                width = "full",
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
                default = Defaults.CustomFormatOneGroup,
            },
            {
                -- Custom Unit Frames format right label
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                getFunc = function ()
                    return Settings.CustomFormatTwoGroup
                end,
                setFunc = function (var)
                    Settings.CustomFormatTwoGroup = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                end,
                width = "full",
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
                default = Defaults.CustomFormatTwoGroup,
            },
            {
                -- Group Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_WIDTH),
                min = 100,
                max = 400,
                step = 5,
                getFunc = function ()
                    return Settings.GroupBarWidth
                end,
                setFunc = function (value)
                    Settings.GroupBarWidth = value
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                end,
                width = "full",
                default = Defaults.GroupBarWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Group Bars Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_HEIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.GroupBarHeight
                end,
                setFunc = function (value)
                    Settings.GroupBarHeight = value
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                end,
                width = "full",
                default = Defaults.GroupBarHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Group / Raid ALPHA
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.GroupAlpha
                end,
                setFunc = function (value)
                    Settings.GroupAlpha = value
                    UnitFrames.CustomFramesGroupAlpha()
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                end,
                width = "full",
                default = Defaults.GroupAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Spacing between Group Bars
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_SPACING),
                min = 20,
                max = 80,
                step = 2,
                getFunc = function ()
                    return Settings.GroupBarSpacing
                end,
                setFunc = function (value)
                    Settings.GroupBarSpacing = value
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                end,
                width = "full",
                default = Defaults.GroupBarSpacing,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Include Player in Group Frame
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_INCPLAYER),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_INCPLAYER_TP),
                getFunc = function ()
                    return not Settings.GroupExcludePlayer
                end,
                setFunc = function (value)
                    Settings.GroupExcludePlayer = not value
                    UnitFrames.CustomFramesGroupUpdate()
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default = not Defaults.GroupExcludePlayer,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Show Role Icon on Group Frames
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_ROLEICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_ROLEICON_TP),
                getFunc = function ()
                    return Settings.RoleIconSmallGroup
                end,
                setFunc = function (value)
                    Settings.RoleIconSmallGroup = value
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                end,
                width = "full",
                default = Defaults.RoleIconSmallGroup,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_FRIEND_ICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_FRIEND_ICON_TP),
                getFunc = function ()
                    return Settings.GroupShowFriendIcon
                end,
                setFunc = function (value)
                    Settings.GroupShowFriendIcon = value
                    UnitFrames.RefreshCustomSmallGroupFrameStaticControls()
                end,
                width = "full",
                default = Defaults.GroupShowFriendIcon,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_GUILD_ICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_GUILD_ICON_TP),
                getFunc = function ()
                    return Settings.GroupShowGuildIcon
                end,
                setFunc = function (value)
                    Settings.GroupShowGuildIcon = value
                    UnitFrames.RefreshCustomSmallGroupFrameStaticControls()
                end,
                width = "full",
                default = Defaults.GroupShowGuildIcon,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_IGNORED_ICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_IGNORED_ICON_TP),
                getFunc = function ()
                    return Settings.GroupShowIgnoredIcon
                end,
                setFunc = function (value)
                    Settings.GroupShowIgnoredIcon = value
                    UnitFrames.RefreshCustomSmallGroupFrameStaticControls()
                end,
                width = "full",
                default = Defaults.GroupShowIgnoredIcon,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_VETERANCY_RANK),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_VETERANCY_RANK_TP),
                getFunc = function ()
                    return Settings.GroupShowVeterancyRank
                end,
                setFunc = function (value)
                    Settings.GroupShowVeterancyRank = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.GroupShowVeterancyRank,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESG_OVERLAND_DIFFICULTY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_OVERLAND_DIFFICULTY_TP),
                getFunc = function ()
                    return Settings.GroupShowOverlandDifficulty
                end,
                setFunc = function (value)
                    Settings.GroupShowOverlandDifficulty = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.GroupShowOverlandDifficulty,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Custom Unit Frames Group Color Class
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYCLASS),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYCLASS_TP),
                getFunc = function ()
                    return Settings.ColorClassGroup
                end,
                setFunc = function (value)
                    Settings.ColorClassGroup = value
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default = Defaults.ColorClassGroup,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Custom Unit Frames Group Color Player Role
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYROLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYROLE_TP),
                getFunc = function ()
                    return Settings.ColorRoleGroup
                end,
                setFunc = function (value)
                    Settings.ColorRoleGroup = value
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default = Defaults.ColorRoleGroup,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Custom Unit Frames Group Sort by role
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_SORT_BY_ROLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_SORT_BY_ROLE_TP),
                getFunc = function ()
                    return Settings.SortRoleGroup
                end,
                setFunc = function (value)
                    Settings.SortRoleGroup = value
                    UnitFrames.CustomFramesApplyLayoutGroup(false)
                end,
                width = "full",
                default = Defaults.SortRoleGroup,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Display Armor stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
                getFunc = function ()
                    return Settings.GroupEnableArmor
                end,
                setFunc = function (value)
                    Settings.GroupEnableArmor = value
                end,
                width = "full",
                default = Defaults.GroupEnableArmor,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Display Power stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
                getFunc = function ()
                    return Settings.GroupEnablePower
                end,
                setFunc = function (value)
                    Settings.GroupEnablePower = value
                end,
                width = "full",
                default = Defaults.GroupEnablePower,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Display Regen Arrows
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
                getFunc = function ()
                    return Settings.GroupEnableRegen
                end,
                setFunc = function (value)
                    Settings.GroupEnableRegen = value
                end,
                width = "full",
                default = Defaults.GroupEnableRegen,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Group Combat Glow
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_GLOW),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_GLOW_TP),
                getFunc = function ()
                    return Settings.GroupCombatGlow
                end,
                setFunc = function (value)
                    Settings.GroupCombatGlow = value
                end,
                width = "full",
                default = Defaults.GroupCombatGlow,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
                end,
            },
            {
                -- Group Combat Glow Color
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Combat Glow Color"),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_GLOW_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.GroupCombatGlowColor)
                end,
                setFunc = function (r, g, b, a)
                    Settings.GroupCombatGlowColor = { r, g, b, a }
                    UnitFrames.UpdateGroupCombatGlow()
                end,
                width = "full",
                default =
                {
                    r = Defaults.GroupCombatGlowColor[1],
                    g = Defaults.GroupCombatGlowColor[2],
                    b = Defaults.GroupCombatGlowColor[3],
                    a = Defaults.GroupCombatGlowColor[4]
                },
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup and Settings.GroupCombatGlow)
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (Raid) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_HEADER),
        controls =
        {
            {
                -- Enable Raid Frames
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_LUIEFRAMESENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_LUIEFRAMESENABLE_TP),
                getFunc = function ()
                    return Settings.CustomFramesRaid
                end,
                setFunc = function (value)
                    Settings.CustomFramesRaid = value
                end,
                width = "full",
                default = Defaults.CustomFramesRaid,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Player Name Display Method (Group/Raid)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID),
                tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID_TP),
                choices = nameDisplayOptions,
                getFunc = function ()
                    return nameDisplayOptions[Settings.DisplayOptionsGroupRaid]
                end,
                setFunc = function (value)
                    Settings.DisplayOptionsGroupRaid = nameDisplayOptionsKeys[value]
                    UnitFrames.CustomFramesReloadControlsMenu(false, false, false)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = nameDisplayOptions[2],
            },
            {
                -- Raid HP Bar Format
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                getFunc = function ()
                    return Settings.CustomFormatRaid
                end,
                setFunc = function (var)
                    Settings.CustomFormatRaid = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
                default = Defaults.CustomFormatRaid,
            },
            {
                -- Raid Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_WIDTH),
                min = 100,
                max = 500,
                step = 5,
                getFunc = function ()
                    return Settings.RaidBarWidth
                end,
                setFunc = function (value)
                    Settings.RaidBarWidth = value
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                default = Defaults.RaidBarWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Raid Bars Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_HEIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.RaidBarHeight
                end,
                setFunc = function (value)
                    Settings.RaidBarHeight = value
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                default = Defaults.RaidBarHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Group / Raid ALPHA
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.GroupAlpha
                end,
                setFunc = function (value)
                    Settings.GroupAlpha = value
                    UnitFrames.CustomFramesGroupAlpha()
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                default = Defaults.GroupAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Raid Frame Layout
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_LAYOUT),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_LAYOUT_TP),
                choices = raidLayoutChoices,
                choicesValues = raidLayoutValues,
                getFunc = function ()
                    return Settings.RaidLayout
                end,
                setFunc = function (var)
                    Settings.RaidLayout = var
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
                default = Defaults.RaidLayout,
            },
            {
                -- Add Spacer for every 4 members
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_SPACER),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_SPACER_TP),
                getFunc = function ()
                    return Settings.RaidSpacers
                end,
                setFunc = function (value)
                    Settings.RaidSpacers = value
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                default = Defaults.RaidSpacers,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Raid Name Clip
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_NAMECLIP),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_NAMECLIP_TP),
                min = 0,
                max = 200,
                step = 1,
                getFunc = function ()
                    return Settings.RaidNameClip
                end,
                setFunc = function (value)
                    Settings.RaidNameClip = value
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                default = Defaults.RaidNameClip,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Class / Role Icon on Raid Frames Setting
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_ROLEICON),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_ROLEICON_TP),
                choices = raidIconOptions,
                getFunc = function ()
                    return raidIconOptions[Settings.RaidIconOptions]
                end,
                setFunc = function (value)
                    Settings.RaidIconOptions = raidIconOptionsKeys[value]
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                default = raidIconOptions[Defaults.RaidIconOptions],
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_VETERANCY_RANK),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_VETERANCY_RANK_TP),
                getFunc = function ()
                    return Settings.RaidShowVeterancyRank
                end,
                setFunc = function (value)
                    Settings.RaidShowVeterancyRank = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.RaidShowVeterancyRank,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESR_OVERLAND_DIFFICULTY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_OVERLAND_DIFFICULTY_TP),
                getFunc = function ()
                    return Settings.RaidShowOverlandDifficulty
                end,
                setFunc = function (value)
                    Settings.RaidShowOverlandDifficulty = value
                    UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
                end,
                width = "full",
                default = Defaults.RaidShowOverlandDifficulty,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Custom Unit Frames Raid Color Player Class
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYCLASS),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYCLASS_TP),
                getFunc = function ()
                    return Settings.ColorClassRaid
                end,
                setFunc = function (value)
                    Settings.ColorClassRaid = value
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default = Defaults.ColorClassRaid,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Custom Unit Frames Raid Color Player Role
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYROLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYROLE_TP),
                getFunc = function ()
                    return Settings.ColorRoleRaid
                end,
                setFunc = function (value)
                    Settings.ColorRoleRaid = value
                    UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
                end,
                width = "full",
                default = Defaults.ColorRoleRaid,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Custom Unit Frames Raid Sort by role
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESSORT),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESSORT_TP),
                getFunc = function ()
                    return Settings.SortRoleRaid
                end,
                setFunc = function (value)
                    Settings.SortRoleRaid = value
                    UnitFrames.CustomFramesApplyLayoutRaid(false)
                end,
                width = "full",
                default = Defaults.SortRoleRaid,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid and Settings.ColorRoleRaid)
                end,
            },
            {
                -- Display Armor stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
                getFunc = function ()
                    return Settings.RaidEnableArmor
                end,
                setFunc = function (value)
                    Settings.RaidEnableArmor = value
                end,
                width = "full",
                default = Defaults.RaidEnableArmor,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Display Power stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
                getFunc = function ()
                    return Settings.RaidEnablePower
                end,
                setFunc = function (value)
                    Settings.RaidEnablePower = value
                end,
                width = "full",
                default = Defaults.RaidEnablePower,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Display Regen Arrows
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
                getFunc = function ()
                    return Settings.RaidEnableRegen
                end,
                setFunc = function (value)
                    Settings.RaidEnableRegen = value
                end,
                width = "full",
                default = Defaults.RaidEnableRegen,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Raid Combat Glow
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_GLOW),
                tooltip = GetString(LUIE_STRING_LAM_UF_RAID_COMBAT_GLOW_TP),
                getFunc = function ()
                    return Settings.RaidCombatGlow
                end,
                setFunc = function (value)
                    Settings.RaidCombatGlow = value
                end,
                width = "full",
                default = Defaults.RaidCombatGlow,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
                end,
            },
            {
                -- Raid Combat Glow Color
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Combat Glow Color"),
                tooltip = GetString(LUIE_STRING_LAM_UF_RAID_COMBAT_GLOW_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.RaidCombatGlowColor)
                end,
                setFunc = function (r, g, b, a)
                    Settings.RaidCombatGlowColor = { r, g, b, a }
                    UnitFrames.UpdateGroupCombatGlow()
                end,
                width = "full",
                default =
                {
                    r = Defaults.RaidCombatGlowColor[1],
                    g = Defaults.RaidCombatGlowColor[2],
                    b = Defaults.RaidCombatGlowColor[3],
                    a = Defaults.RaidCombatGlowColor[4]
                },
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid and Settings.RaidCombatGlow)
                end,
            },
        },
    }

    -- Unit Frames - Group Resources (LibGroupBroadcast) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_HEADER),
        controls =
        {
            {
                -- Enable Group Resources
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_ENABLE_TP),
                getFunc = function ()
                    return Settings.GroupResources.enabled
                end,
                setFunc = function (value)
                    Settings.GroupResources.enabled = value
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.OnSettingsChanged()
                    end
                end,
                width = "full",
                default = Defaults.GroupResources.enabled,
                warning = GetString(LUIE_STRING_LAM_UF_REQUIRES_LIBGROUPBROADCAST) .. GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and LibGroupBroadcast)
                end,
            },
            {
                -- Stamina First
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_STAMINA_FIRST),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_STAMINA_FIRST_TP),
                getFunc = function ()
                    return Settings.GroupResources.staminaFirst
                end,
                setFunc = function (value)
                    Settings.GroupResources.staminaFirst = value
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.UpdateAllLayouts()
                    end
                end,
                width = "full",
                default = Defaults.GroupResources.staminaFirst,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Enable Fade Effect
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_FADE),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_FADE_TP),
                getFunc = function ()
                    return Settings.GroupResources.enableFadeEffect
                end,
                setFunc = function (value)
                    Settings.GroupResources.enableFadeEffect = value
                end,
                width = "full",
                default = Defaults.GroupResources.enableFadeEffect,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Hide Resource Bars Toggle
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_HIDE_TIMEOUT_TOGGLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_HIDE_TIMEOUT_TOGGLE_TP),
                getFunc = function ()
                    return Settings.GroupResources.hideResourceBarsToggle
                end,
                setFunc = function (value)
                    Settings.GroupResources.hideResourceBarsToggle = value
                end,
                width = "full",
                default = Defaults.GroupResources.hideResourceBarsToggle,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Hide Timeout
                type = "slider",
                name = zo_strformat("<<1>>", GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_HIDE_TIMEOUT_LABEL)),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_HIDE_TIMEOUT_TP),
                min = 5,
                max = 600,
                step = 5,
                getFunc = function ()
                    return Settings.GroupResources.hideResourceBarsTimeout
                end,
                setFunc = function (value)
                    Settings.GroupResources.hideResourceBarsTimeout = value
                end,
                width = "full",
                default = Defaults.GroupResources.hideResourceBarsTimeout,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled and Settings.GroupResources.hideResourceBarsToggle)
                end,
            },
            {
                -- Group Bar Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_GROUP_BAR_WIDTH),
                min = 50,
                max = 300,
                step = 5,
                getFunc = function ()
                    return Settings.GroupResources.groupBarWidth
                end,
                setFunc = function (value)
                    Settings.GroupResources.groupBarWidth = value
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.UpdateAllLayouts()
                    end
                end,
                width = "half",
                default = Defaults.GroupResources.groupBarWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Group Bar Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_GROUP_BAR_HEIGHT),
                min = 3,
                max = 15,
                step = 1,
                getFunc = function ()
                    return Settings.GroupResources.groupBarHeight
                end,
                setFunc = function (value)
                    Settings.GroupResources.groupBarHeight = value
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.UpdateAllLayouts()
                    end
                end,
                width = "half",
                default = Defaults.GroupResources.groupBarHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Raid Bar Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_RAID_BAR_WIDTH),
                min = 50,
                max = 250,
                step = 5,
                getFunc = function ()
                    return Settings.GroupResources.raidBarWidth
                end,
                setFunc = function (value)
                    Settings.GroupResources.raidBarWidth = value
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.UpdateAllLayouts()
                    end
                end,
                width = "half",
                default = Defaults.GroupResources.raidBarWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Raid Bar Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_RAID_BAR_HEIGHT),
                min = 3,
                max = 15,
                step = 1,
                getFunc = function ()
                    return Settings.GroupResources.raidBarHeight
                end,
                setFunc = function (value)
                    Settings.GroupResources.raidBarHeight = value
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.UpdateAllLayouts()
                    end
                end,
                width = "half",
                default = Defaults.GroupResources.raidBarHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Magicka Color Start
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_MAGICKA_GRAD_START),
                getFunc = function ()
                    return unpack(Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart)
                end,
                setFunc = function (r, g, b, a)
                    Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart = { r, g, b, a }
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.RefreshColors()
                    end
                end,
                width = "half",
                default = ZO_ColorDef:New(unpack(Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart)),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Magicka Color End
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_MAGICKA_GRAD_END),
                getFunc = function ()
                    return unpack(Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd)
                end,
                setFunc = function (r, g, b, a)
                    Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd = { r, g, b, a }
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.RefreshColors()
                    end
                end,
                width = "half",
                default = ZO_ColorDef:New(unpack(Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd)),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Stamina Color Start
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_STAMINA_GRAD_START),
                getFunc = function ()
                    return unpack(Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart)
                end,
                setFunc = function (r, g, b, a)
                    Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart = { r, g, b, a }
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.RefreshColors()
                    end
                end,
                width = "half",
                default = ZO_ColorDef:New(unpack(Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart)),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
            {
                -- Stamina Color End
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_STAMINA_GRAD_END),
                getFunc = function ()
                    return unpack(Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd)
                end,
                setFunc = function (r, g, b, a)
                    Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd = { r, g, b, a }
                    if UnitFrames.GroupResources then
                        UnitFrames.GroupResources.RefreshColors()
                    end
                end,
                width = "half",
                default = ZO_ColorDef:New(unpack(Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd)),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
                end,
            },
        },
    }

    -- Unit Frames - Group Combat Stats (LibGroupCombatStats) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_HEADER),
        controls =
        {
            {
                -- Enable Group Combat Stats
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_ENABLE_TP),
                getFunc = function ()
                    return Settings.GroupCombatStats.enabled
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.enabled = value
                    if UnitFrames.GroupCombatStats then
                        UnitFrames.GroupCombatStats.OnSettingsChanged()
                    end
                end,
                width = "full",
                default = Defaults.GroupCombatStats.enabled,
                warning = GetString(LUIE_STRING_LAM_UF_REQUIRES_LIBGROUPCOMBATSTATS) .. GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and LibGroupCombatStats)
                end,
            },
            {
                -- Show Ultimate Icon
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_ULTIMATE),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_ULTIMATE_TP),
                getFunc = function ()
                    return Settings.GroupCombatStats.showUltimate
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.showUltimate = value
                end,
                width = "full",
                default = Defaults.GroupCombatStats.showUltimate,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
                end,
            },
            {
                -- Show DPS
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_DPS),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_DPS_TP),
                getFunc = function ()
                    return Settings.GroupCombatStats.showDPS
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.showDPS = value
                    if UnitFrames.GroupCombatStats then
                        UnitFrames.GroupCombatStats.RefreshAll()
                    end
                end,
                width = "half",
                default = Defaults.GroupCombatStats.showDPS,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
                end,
            },
            {
                -- Show HPS
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_HPS),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_HPS_TP),
                getFunc = function ()
                    return Settings.GroupCombatStats.showHPS
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.showHPS = value
                    if UnitFrames.GroupCombatStats then
                        UnitFrames.GroupCombatStats.RefreshAll()
                    end
                end,
                width = "half",
                default = Defaults.GroupCombatStats.showHPS,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
                end,
            },
            {
                -- Header for Group (4 player) settings
                type = "header",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_FRAMES_4P),
            },
            {
                -- Ultimate Icon Size (Group)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Ultimate Icon Size"),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_ULT_ICON_SIZE_TP),
                min = 16,
                max = 36,
                step = 2,
                getFunc = function ()
                    return Settings.GroupCombatStats.ultIconGroupSize
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.ultIconGroupSize = value
                end,
                width = "full",
                default = Defaults.GroupCombatStats.ultIconGroupSize,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
                end,
            },
            {
                -- Ultimate Icon Horizontal Offset (Group)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Horizontal Offset"),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_ULT_ICON_OFFSET_X_TP),
                min = -20,
                max = 20,
                step = 1,
                getFunc = function ()
                    return Settings.GroupCombatStats.ultIconGroupOffsetX
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.ultIconGroupOffsetX = value
                end,
                width = "half",
                default = Defaults.GroupCombatStats.ultIconGroupOffsetX,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
                end,
            },
            {
                -- Ultimate Icon Vertical Offset (Group)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Vertical Offset"),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_ULT_ICON_OFFSET_Y_TP),
                min = -20,
                max = 20,
                step = 1,
                getFunc = function ()
                    return Settings.GroupCombatStats.ultIconGroupOffsetY
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.ultIconGroupOffsetY = value
                end,
                width = "half",
                default = Defaults.GroupCombatStats.ultIconGroupOffsetY,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
                end,
            },
            -- {
            --     -- Header for Raid (12 player) settings
            --     type = "header",
            --     name = GetString(LUIE_STRING_LAM_UF_RAID_FRAMES_12P),
            -- },
            --[[ Raid ultimate icons commented out - no longer shown on raid frames
            {
                -- Ultimate Icon Size (Raid)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Ultimate Icon Size"),
                tooltip = GetString(LUIE_STRING_LAM_UF_RAID_ULT_ICON_SIZE_TP),
                min = 14,
                max = 32,
                step = 2,
                getFunc = function ()
                    return Settings.GroupCombatStats.ultIconRaidSize
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.ultIconRaidSize = value
                end,
                width = "full",
                default = Defaults.GroupCombatStats.ultIconRaidSize,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
                end,
            },
            ]] --
            --[[
            {
                -- Ultimate Icon Horizontal Offset (Raid)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Horizontal Offset"),
                tooltip = GetString(LUIE_STRING_LAM_UF_RAID_ULT_ICON_OFFSET_X_TP),
                min = 0,
                max = 100,
                step = 1,
                getFunc = function ()
                    return Settings.GroupCombatStats.ultIconRaidOffsetX
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.ultIconRaidOffsetX = value
                end,
                width = "half",
                default = Defaults.GroupCombatStats.ultIconRaidOffsetX,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
                end,
            },
            {
                -- Ultimate Icon Vertical Offset (Raid)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Vertical Offset"),
                tooltip = GetString(LUIE_STRING_LAM_UF_RAID_ULT_ICON_OFFSET_Y_TP),
                min = -50,
                max = 50,
                step = 1,
                getFunc = function ()
                    return Settings.GroupCombatStats.ultIconRaidOffsetY
                end,
                setFunc = function (value)
                    Settings.GroupCombatStats.ultIconRaidOffsetY = value
                end,
                width = "half",
                default = Defaults.GroupCombatStats.ultIconRaidOffsetY,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
                end,
            },
            ]] --
        },
    }

    -- Unit Frames - Group Potion Cooldowns Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_HEADER),
        controls =
        {
            {
                -- Enable Group Potion Cooldowns
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_ENABLE_TP),
                getFunc = function ()
                    return Settings.GroupPotionCooldowns.enabled
                end,
                setFunc = function (value)
                    Settings.GroupPotionCooldowns.enabled = value
                    if UnitFrames.GroupPotionCooldowns then
                        UnitFrames.GroupPotionCooldowns.OnSettingsChanged()
                    end
                end,
                width = "full",
                default = Defaults.GroupPotionCooldowns.enabled,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and LibGroupPotionCooldowns)
                end,
            },
            {
                -- Show Remaining Time
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_REMAINING),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_REMAINING_TP),
                getFunc = function ()
                    return Settings.GroupPotionCooldowns.showRemainingTime
                end,
                setFunc = function (value)
                    Settings.GroupPotionCooldowns.showRemainingTime = value
                end,
                width = "full",
                default = Defaults.GroupPotionCooldowns.showRemainingTime,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and LibGroupPotionCooldowns and Settings.GroupPotionCooldowns.enabled)
                end,
            },
            {
                -- Header for Group (4 player) settings
                type = "header",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_FRAMES_4P),
            },
            {
                -- Potion Icon Size (Group)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Potion Icon Size"),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_ICON_SIZE_TP),
                min = 14,
                max = 32,
                step = 2,
                getFunc = function ()
                    return Settings.GroupPotionCooldowns.potionIconGroupSize
                end,
                setFunc = function (value)
                    Settings.GroupPotionCooldowns.potionIconGroupSize = value
                end,
                width = "full",
                default = Defaults.GroupPotionCooldowns.potionIconGroupSize,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and LibGroupPotionCooldowns and Settings.GroupPotionCooldowns.enabled)
                end,
            },
            {
                -- Potion Icon Horizontal Offset (Group)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Horizontal Offset"),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_OFFSET_X_TP),
                min = -20,
                max = 20,
                step = 1,
                getFunc = function ()
                    return Settings.GroupPotionCooldowns.potionIconGroupOffsetX
                end,
                setFunc = function (value)
                    Settings.GroupPotionCooldowns.potionIconGroupOffsetX = value
                end,
                width = "half",
                default = Defaults.GroupPotionCooldowns.potionIconGroupOffsetX,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and LibGroupPotionCooldowns and Settings.GroupPotionCooldowns.enabled)
                end,
            },
            {
                -- Potion Icon Vertical Offset (Group)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Vertical Offset"),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_OFFSET_Y_TP),
                min = -20,
                max = 20,
                step = 1,
                getFunc = function ()
                    return Settings.GroupPotionCooldowns.potionIconGroupOffsetY
                end,
                setFunc = function (value)
                    Settings.GroupPotionCooldowns.potionIconGroupOffsetY = value
                end,
                width = "half",
                default = Defaults.GroupPotionCooldowns.potionIconGroupOffsetY,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and LibGroupPotionCooldowns and Settings.GroupPotionCooldowns.enabled)
                end,
            },
            --[[ Raid potion cooldown settings commented out - no longer shown on raid frames
            {
                -- Header for Raid (12 player) settings
                type = "header",
                name = GetString(LUIE_STRING_LAM_UF_RAID_FRAMES_12P),
            },
            {
                -- Potion Icon Size (Raid)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Potion Icon Size"),
                tooltip = GetString(LUIE_STRING_LAM_UF_RAID_POTION_ICON_SIZE_TP),
                min = 12,
                max = 28,
                step = 2,
                getFunc = function ()
                    return Settings.GroupPotionCooldowns.potionIconRaidSize
                end,
                setFunc = function (value)
                    Settings.GroupPotionCooldowns.potionIconRaidSize = value
                end,
                width = "full",
                default = Defaults.GroupPotionCooldowns.potionIconRaidSize,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
                end,
            },
            {
                -- Potion Icon Horizontal Offset (Raid)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Horizontal Offset"),
                tooltip = GetString(LUIE_STRING_LAM_UF_RAID_POTION_OFFSET_X_TP),
                min = 0,
                max = 100,
                step = 1,
                getFunc = function ()
                    return Settings.GroupPotionCooldowns.potionIconRaidOffsetX
                end,
                setFunc = function (value)
                    Settings.GroupPotionCooldowns.potionIconRaidOffsetX = value
                end,
                width = "half",
                default = Defaults.GroupPotionCooldowns.potionIconRaidOffsetX,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
                end,
            },
            {
                -- Potion Icon Vertical Offset (Raid)
                type = "slider",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Vertical Offset"),
                tooltip = GetString(LUIE_STRING_LAM_UF_RAID_POTION_OFFSET_Y_TP),
                min = -50,
                max = 50,
                step = 1,
                getFunc = function ()
                    return Settings.GroupPotionCooldowns.potionIconRaidOffsetY
                end,
                setFunc = function (value)
                    Settings.GroupPotionCooldowns.potionIconRaidOffsetY = value
                end,
                width = "half",
                default = Defaults.GroupPotionCooldowns.potionIconRaidOffsetY,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
                end,
            },
            ]] --
        },
    }

    -- Unit Frames - Group Food & Drink Buffs Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_HEADER),
        controls =
        {
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_ENABLE_TP),
                getFunc = function ()
                    return Settings.GroupFoodDrinkBuff.enabled
                end,
                setFunc = function (value)
                    Settings.GroupFoodDrinkBuff.enabled = value
                    if UnitFrames.GroupFoodDrinkBuff then
                        UnitFrames.GroupFoodDrinkBuff.OnSettingsChanged()
                    end
                end,
                width = "full",
                default = Defaults.GroupFoodDrinkBuff.enabled,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_RAID_NOTE_DESC),
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_NO_BUFF),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_NO_BUFF_TP),
                getFunc = function ()
                    return Settings.GroupFoodDrinkBuff.showNoBuff
                end,
                setFunc = function (value)
                    Settings.GroupFoodDrinkBuff.showNoBuff = value
                    if UnitFrames.GroupFoodDrinkBuff then
                        UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                    end
                end,
                width = "full",
                default = Defaults.GroupFoodDrinkBuff.showNoBuff,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_REMAINING),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_REMAINING_TP),
                getFunc = function ()
                    return Settings.GroupFoodDrinkBuff.showRemainingTime
                end,
                setFunc = function (value)
                    Settings.GroupFoodDrinkBuff.showRemainingTime = value
                end,
                width = "full",
                default = Defaults.GroupFoodDrinkBuff.showRemainingTime,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_QUALITY_ICONS),
                tooltip = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_QUALITY_ICONS_TP),
                getFunc = function ()
                    return Settings.GroupFoodDrinkBuff.useCustomIcons
                end,
                setFunc = function (value)
                    Settings.GroupFoodDrinkBuff.useCustomIcons = value
                    if UnitFrames.GroupFoodDrinkBuff then
                        UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                    end
                end,
                width = "full",
                default = Defaults.GroupFoodDrinkBuff.useCustomIcons,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
                end,
            },
            {
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_ICON_SIZE),
                min = 16,
                max = 32,
                step = 2,
                getFunc = function ()
                    return Settings.GroupFoodDrinkBuff.iconSizeGroup
                end,
                setFunc = function (value)
                    Settings.GroupFoodDrinkBuff.iconSizeGroup = value
                    if UnitFrames.GroupFoodDrinkBuff then
                        UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                    end
                end,
                width = "full",
                default = Defaults.GroupFoodDrinkBuff.iconSizeGroup,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
                end,
            },
            {
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_ICON_OFFSET_X),
                min = -20,
                max = 20,
                step = 1,
                getFunc = function ()
                    return Settings.GroupFoodDrinkBuff.iconOffsetXGroup
                end,
                setFunc = function (value)
                    Settings.GroupFoodDrinkBuff.iconOffsetXGroup = value
                    if UnitFrames.GroupFoodDrinkBuff then
                        UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                    end
                end,
                width = "half",
                default = Defaults.GroupFoodDrinkBuff.iconOffsetXGroup,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
                end,
            },
            {
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_ICON_OFFSET_Y),
                min = -20,
                max = 20,
                step = 1,
                getFunc = function ()
                    return Settings.GroupFoodDrinkBuff.iconOffsetYGroup
                end,
                setFunc = function (value)
                    Settings.GroupFoodDrinkBuff.iconOffsetYGroup = value
                    if UnitFrames.GroupFoodDrinkBuff then
                        UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                    end
                end,
                width = "half",
                default = Defaults.GroupFoodDrinkBuff.iconOffsetYGroup,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (Companion) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_HEADER),
        controls =
        {
            {
                -- Enable Companion Frames
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ENABLE_TP),
                getFunc = function ()
                    return Settings.CustomFramesCompanion
                end,
                setFunc = function (value)
                    Settings.CustomFramesCompanion = value
                end,
                width = "full",
                default = Defaults.CustomFramesCompanion,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Companion HP Bar Format
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                getFunc = function ()
                    return Settings.CustomFormatCompanion
                end,
                setFunc = function (var)
                    Settings.CustomFormatCompanion = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutCompanion(false)
                end,
                width = "full",
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
                default = Defaults.CustomFormatCompanion,
            },
            {
                -- Companion Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_WIDTH),
                min = 100,
                max = 500,
                step = 5,
                getFunc = function ()
                    return Settings.CompanionWidth
                end,
                setFunc = function (value)
                    Settings.CompanionWidth = value
                    UnitFrames.CustomFramesApplyLayoutCompanion(false)
                end,
                width = "full",
                default = Defaults.CompanionWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                -- Companion Bars Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_HEIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.CompanionHeight
                end,
                setFunc = function (value)
                    Settings.CompanionHeight = value
                    UnitFrames.CustomFramesApplyLayoutCompanion(false)
                end,
                width = "full",
                default = Defaults.CompanionHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_COMPANION)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
                getFunc = function ()
                    return Settings.CompanionEnableArmor
                end,
                setFunc = function (value)
                    Settings.CompanionEnableArmor = value
                end,
                width = "full",
                default = Defaults.CompanionEnableArmor,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_COMPANION)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
                getFunc = function ()
                    return Settings.CompanionEnablePower
                end,
                setFunc = function (value)
                    Settings.CompanionEnablePower = value
                end,
                width = "full",
                default = Defaults.CompanionEnablePower,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_COMPANION)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
                getFunc = function ()
                    return Settings.CompanionEnableRegen
                end,
                setFunc = function (value)
                    Settings.CompanionEnableRegen = value
                end,
                width = "full",
                default = Defaults.CompanionEnableRegen,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_GLOW),
                tooltip = GetString(LUIE_STRING_LAM_UF_COMPANION_COMBAT_GLOW_TP),
                getFunc = function ()
                    return Settings.CompanionCombatGlow
                end,
                setFunc = function (value)
                    Settings.CompanionCombatGlow = value
                    UnitFrames.UpdateCompanionCombatGlow()
                end,
                width = "full",
                default = Defaults.CompanionCombatGlow,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Combat Glow Color"),
                tooltip = GetString(LUIE_STRING_LAM_UF_COMPANION_COMBAT_GLOW_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.CompanionCombatGlowColor)
                end,
                setFunc = function (r, g, b, a)
                    Settings.CompanionCombatGlowColor = { r, g, b, a }
                    UnitFrames.UpdateCompanionCombatGlow()
                end,
                width = "full",
                default =
                {
                    r = Defaults.CompanionCombatGlowColor[1],
                    g = Defaults.CompanionCombatGlowColor[2],
                    b = Defaults.CompanionCombatGlowColor[3],
                    a = Defaults.CompanionCombatGlowColor[4],
                },
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion and Settings.CompanionCombatGlow)
                end,
            },
            {
                -- Companion - Out-of-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_OOCPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_OOCPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.CompanionOocAlpha
                end,
                setFunc = function (value)
                    Settings.CompanionOocAlpha = value
                    UnitFrames.CustomFramesApplyCompanionInCombat(true)
                    UnitFrames.CustomFramesApplyLayoutCompanion(false)
                end,
                width = "full",
                default = Defaults.CompanionOocAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                -- Companion - In-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ICPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ICPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.CompanionIncAlpha
                end,
                setFunc = function (value)
                    Settings.CompanionIncAlpha = value
                    UnitFrames.CustomFramesApplyCompanionInCombat(true)
                    UnitFrames.CustomFramesApplyLayoutCompanion(false)
                end,
                width = "full",
                default = Defaults.CompanionIncAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                -- Companion Name Clip
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_NAMECLIP),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_NAMECLIP_TP),
                min = 0,
                max = 200,
                step = 1,
                getFunc = function ()
                    return Settings.CompanionNameClip
                end,
                setFunc = function (value)
                    Settings.CompanionNameClip = value
                    UnitFrames.CustomFramesApplyLayoutCompanion(false)
                end,
                width = "full",
                default = Defaults.CompanionNameClip,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                -- Companion - Color Target by Class
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_USE_CLASS_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_USE_CLASS_COLOR_TP),
                getFunc = function ()
                    return Settings.CompanionUseClassColor
                end,
                setFunc = function (value)
                    Settings.CompanionUseClassColor = value
                    UnitFrames.CustomFramesApplyColorsMenuCompanionFrameOnly()
                end,
                width = "full",
                default = Defaults.CompanionUseClassColor,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                type = "header",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_HEADER),
                width = "full",
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_ENABLE_TP),
                getFunc = function ()
                    return Settings.CompanionAbilityTrack.enabled
                end,
                setFunc = function (value)
                    Settings.CompanionAbilityTrack.enabled = value
                    UnitFrames.CustomFramesApplyLayoutCompanion(false)
                    if UnitFrames.companionAbilityTrack then
                        UnitFrames.companionAbilityTrack:RefreshAll()
                    end
                end,
                width = "full",
                default = Defaults.CompanionAbilityTrack.enabled,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
            {
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_ICON_SIZE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_ICON_SIZE_TP),
                min = 16,
                max = 40,
                step = 1,
                getFunc = function ()
                    return Settings.CompanionAbilityTrack.iconSize
                end,
                setFunc = function (value)
                    Settings.CompanionAbilityTrack.iconSize = value
                    UnitFrames.CustomFramesApplyLayoutCompanion(false)
                end,
                width = "full",
                default = Defaults.CompanionAbilityTrack.iconSize,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion and Settings.CompanionAbilityTrack.enabled)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_SHOW_EFFECT),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_SHOW_EFFECT_TP),
                getFunc = function ()
                    return Settings.CompanionAbilityTrack.showEffectTimer
                end,
                setFunc = function (value)
                    Settings.CompanionAbilityTrack.showEffectTimer = value
                    if UnitFrames.companionAbilityTrack then
                        UnitFrames.companionAbilityTrack:RefreshAll()
                    end
                end,
                width = "full",
                default = Defaults.CompanionAbilityTrack.showEffectTimer,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion and Settings.CompanionAbilityTrack.enabled)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_SHOW_STACKS),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_SHOW_STACKS_TP),
                getFunc = function ()
                    return Settings.CompanionAbilityTrack.showStacks
                end,
                setFunc = function (value)
                    Settings.CompanionAbilityTrack.showStacks = value
                    if UnitFrames.companionAbilityTrack then
                        UnitFrames.companionAbilityTrack:RefreshAll()
                    end
                end,
                width = "full",
                default = Defaults.CompanionAbilityTrack.showStacks,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion and Settings.CompanionAbilityTrack.enabled)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_RAPPORT_FLOURISH),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_RAPPORT_FLOURISH_TP),
                getFunc = function ()
                    return Settings.CompanionRapportFlourish.enabled
                end,
                setFunc = function (value)
                    Settings.CompanionRapportFlourish.enabled = value
                    if not value and UnitFrames.companionRapportFlourish then
                        UnitFrames.companionRapportFlourish:StopFlourish()
                    end
                end,
                width = "full",
                default = Defaults.CompanionRapportFlourish.enabled,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (Pet) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_HEADER),
        controls =
        {
            {
                -- Enable Pet Frames
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ENABLE_TP),
                getFunc = function ()
                    return Settings.CustomFramesPet
                end,
                setFunc = function (value)
                    Settings.CustomFramesPet = value
                end,
                width = "full",
                default = Defaults.CustomFramesPet,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Pet HP Bar Format
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                getFunc = function ()
                    return Settings.CustomFormatPet
                end,
                setFunc = function (var)
                    Settings.CustomFormatPet = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPet(false)
                end,
                width = "full",
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
                default = Defaults.CustomFormatPet,
            },
            {
                -- Pet Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_WIDTH),
                min = 100,
                max = 500,
                step = 5,
                getFunc = function ()
                    return Settings.PetWidth
                end,
                setFunc = function (value)
                    Settings.PetWidth = value
                    UnitFrames.CustomFramesApplyLayoutPet(false)
                end,
                width = "full",
                default = Defaults.PetWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                -- Pet Bars Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_HEIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.PetHeight
                end,
                setFunc = function (value)
                    Settings.PetHeight = value
                    UnitFrames.CustomFramesApplyLayoutPet(false)
                end,
                width = "full",
                default = Defaults.PetHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PET)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
                getFunc = function ()
                    return Settings.PetEnableArmor
                end,
                setFunc = function (value)
                    Settings.PetEnableArmor = value
                end,
                width = "full",
                default = Defaults.PetEnableArmor,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PET)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
                getFunc = function ()
                    return Settings.PetEnablePower
                end,
                setFunc = function (value)
                    Settings.PetEnablePower = value
                end,
                width = "full",
                default = Defaults.PetEnablePower,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PET)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
                getFunc = function ()
                    return Settings.PetEnableRegen
                end,
                setFunc = function (value)
                    Settings.PetEnableRegen = value
                end,
                width = "full",
                default = Defaults.PetEnableRegen,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_GLOW),
                tooltip = GetString(LUIE_STRING_LAM_UF_PET_COMBAT_GLOW_TP),
                getFunc = function ()
                    return Settings.PetCombatGlow
                end,
                setFunc = function (value)
                    Settings.PetCombatGlow = value
                    UnitFrames.UpdatePetCombatGlow()
                end,
                width = "full",
                default = Defaults.PetCombatGlow,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", "Combat Glow Color"),
                tooltip = GetString(LUIE_STRING_LAM_UF_PET_COMBAT_GLOW_COLOR_TP),
                getFunc = function ()
                    return unpack(Settings.PetCombatGlowColor)
                end,
                setFunc = function (r, g, b, a)
                    Settings.PetCombatGlowColor = { r, g, b, a }
                    UnitFrames.UpdatePetCombatGlow()
                end,
                width = "full",
                default =
                {
                    r = Defaults.PetCombatGlowColor[1],
                    g = Defaults.PetCombatGlowColor[2],
                    b = Defaults.PetCombatGlowColor[3],
                    a = Defaults.PetCombatGlowColor[4],
                },
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet and Settings.PetCombatGlow)
                end,
            },
            {
                -- Pet - Out-of-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_OOCPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_OOCPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.PetOocAlpha
                end,
                setFunc = function (value)
                    Settings.PetOocAlpha = value
                    UnitFrames.CustomFramesApplyPetInCombat(true)
                    UnitFrames.CustomFramesApplyLayoutPet(false)
                end,
                width = "full",
                default = Defaults.PetOocAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                -- Pet - In-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ICPACITY),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ICPACITY_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.PetIncAlpha
                end,
                setFunc = function (value)
                    Settings.PetIncAlpha = value
                    UnitFrames.CustomFramesApplyPetInCombat(true)
                    UnitFrames.CustomFramesApplyLayoutPet(false)
                end,
                width = "full",
                default = Defaults.PetIncAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                -- Pet Name Clip
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_NAMECLIP),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_NAMECLIP_TP),
                min = 0,
                max = 200,
                step = 1,
                getFunc = function ()
                    return Settings.PetNameClip
                end,
                setFunc = function (value)
                    Settings.PetNameClip = value
                    UnitFrames.CustomFramesApplyLayoutPet(false)
                end,
                width = "full",
                default = Defaults.PetNameClip,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                -- Pet - Color Target by Class
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_USE_CLASS_COLOR),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_USE_CLASS_COLOR_TP),
                getFunc = function ()
                    return Settings.PetUseClassColor
                end,
                setFunc = function (value)
                    Settings.PetUseClassColor = value
                    UnitFrames.CustomFramesApplyColorsMenuPetFramesOnly()
                end,
                width = "full",
                default = Defaults.PetUseClassColor,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
                end,
            },
            {
                -- Unit Frames Pet Whitelist Header
                type = "header",
                name = GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST),
            },
            {
                -- Unit Frames Pet Whitelist Description
                type = "description",
                text = GetString(LUIE_STRING_LAM_UF_BLACKLIST_DESCRIPT),
            },
            -- Add Pet Names - Necromancer
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_NECROMANCER),
                tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_NECROMANCER_TP),
                func = function ()
                    UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Necromancer)
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                    UnitFrames.CustomPetUpdate()
                end,
                width = "half",
            },
            -- Add Pet Names - Sorcerer
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SORCERER),
                tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SORCERER_TP),
                func = function ()
                    UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Sorcerer)
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                    UnitFrames.CustomPetUpdate()
                end,
                width = "half",
            },
            -- Add Pet Names - Warden
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_WARDEN),
                tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_WARDEN_TP),
                func = function ()
                    UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Warden)
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                    UnitFrames.CustomPetUpdate()
                end,
                width = "half",
            },
            -- Add Pet Names - Sets
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SETS),
                tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SETS_TP),
                func = function ()
                    UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Sets)
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                    UnitFrames.CustomPetUpdate()
                end,
                width = "half",
            },
            -- Add Pet Names - Assistants
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_ASSISTANTS),
                tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_ASSISTANTS_TP),
                func = function ()
                    UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Assistants)
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                    UnitFrames.CustomPetUpdate()
                end,
                width = "half",
            },

            -- Add All Currently Active Pets
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_CURRENT),
                tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_CURRENT_TP),
                func = function ()
                    UnitFrames.AddCurrentPetsToCustomList(Settings.whitelist)
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                    UnitFrames.CustomPetUpdate()
                end,
                width = "half",
            },

            -- Clear Whitelist
            {
                type = "button",
                name = GetString(LUIE_STRING_LAM_UF_WHITELIST_CLEAR),
                tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_CLEAR_TP),
                func = function ()
                    ZO_Dialogs_ShowDialog("LUIE_CLEAR_PET_WHITELIST")
                end,
                width = "half",
            },

            {
                -- Unit Frames Pet Whitelist (Add)
                type = "editbox",
                name = GetString(LUIE_STRING_LAM_UF_BLACKLIST_ADDLIST),
                tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_ADDLIST_TP),
                getFunc = function () end,
                setFunc = function (value)
                    UnitFrames.AddToCustomList(Settings.whitelist, value)
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                    UnitFrames.CustomPetUpdate()
                end,
            },
            {
                -- Unit Frames Pet (Remove)
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_BLACKLIST_REMLIST),
                tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_REMLIST_TP),
                choices = Whitelist,
                choicesValues = WhitelistValues,
                scrollable = 7,
                sort = "name-up",
                getFunc = function ()
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                end,
                setFunc = function (value)
                    UnitFrames.RemoveFromCustomList(Settings.whitelist, value)
                    LUIE_WhitelistUF:UpdateChoices(GenerateCustomList(Settings.whitelist))
                    UnitFrames.CustomPetUpdate()
                end,
                reference = "LUIE_WhitelistUF",
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (Boss) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESB_HEADER),
        controls =
        {
            {
                -- Enable This Addon BOSS frames
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESB_LUIEFRAMESENABLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESB_LUIEFRAMESENABLE_TP),
                getFunc = function ()
                    return Settings.CustomFramesBosses
                end,
                setFunc = function (value)
                    Settings.CustomFramesBosses = value
                end,
                width = "full",
                default = Defaults.CustomFramesBosses,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Boss HP Bar Format
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
                choices = formatOptionChoices,
                choicesValues = formatOptionValues,
                getFunc = function ()
                    return Settings.CustomFormatBoss
                end,
                setFunc = function (var)
                    Settings.CustomFormatBoss = var
                    UnitFrames.CustomFramesFormatLabels(true)
                end,
                width = "full",
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
                default = Defaults.CustomFormatBoss,
            },
            {
                -- Boss Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESB_WIDTH),
                min = 100,
                max = 500,
                step = 5,
                getFunc = function ()
                    return Settings.BossBarWidth
                end,
                setFunc = function (value)
                    Settings.BossBarWidth = value
                    UnitFrames.CustomFramesApplyLayoutBosses(false)
                end,
                width = "full",
                default = Defaults.BossBarWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- Boss Bars Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESB_HEIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.BossBarHeight
                end,
                setFunc = function (value)
                    Settings.BossBarHeight = value
                    UnitFrames.CustomFramesApplyLayoutBosses(false)
                end,
                width = "full",
                default = Defaults.BossBarHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- Boss Bars Spacing
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_BOSS_VERTICAL_SPACING),
                tooltip = GetString(LUIE_STRING_LAM_UF_BOSS_VERTICAL_SPACING_TP),
                min = 0,
                max = 20,
                step = 1,
                getFunc = function ()
                    return Settings.BossBarSpacing
                end,
                setFunc = function (value)
                    Settings.BossBarSpacing = value
                    UnitFrames.CustomFramesApplyLayoutBosses(false)
                end,
                width = "full",
                default = Defaults.BossBarSpacing,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- Out-of-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESB_OPACITYOOC),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESB_OPACITYOOC_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.BossOocAlpha
                end,
                setFunc = function (value)
                    Settings.BossOocAlpha = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.BossOocAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- In-Combat frame opacity
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESB_OPACITYIC),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESB_OPACITYIC_TP),
                min = 0,
                max = 100,
                step = 5,
                getFunc = function ()
                    return Settings.BossIncAlpha
                end,
                setFunc = function (value)
                    Settings.BossIncAlpha = value
                    UnitFrames.CustomFramesApplyInCombat(true)
                end,
                width = "full",
                default = Defaults.BossIncAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- Display Armor stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_BOSS)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
                getFunc = function ()
                    return Settings.BossEnableArmor
                end,
                setFunc = function (value)
                    Settings.BossEnableArmor = value
                end,
                width = "full",
                default = Defaults.BossEnableArmor,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- Display Power stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_BOSS)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
                getFunc = function ()
                    return Settings.BossEnablePower
                end,
                setFunc = function (value)
                    Settings.BossEnablePower = value
                end,
                width = "full",
                default = Defaults.BossEnablePower,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- Display Regen Arrows
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_BOSS)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
                getFunc = function ()
                    return Settings.BossEnableRegen
                end,
                setFunc = function (value)
                    Settings.BossEnableRegen = value
                end,
                width = "full",
                default = Defaults.BossEnableRegen,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- Display Threshold Markers
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_THRESHOLDS), GetString(LUIE_STRING_LAM_UF_SHARED_BOSS)),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_THRESHOLDS_TP),
                getFunc = function ()
                    return Settings.BossShowThresholdMarkers
                end,
                setFunc = function (value)
                    Settings.BossShowThresholdMarkers = value
                    UnitFrames.UpdateBossThresholds()
                end,
                width = "full",
                default = Defaults.BossShowThresholdMarkers,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
                end,
            },
            {
                -- Threshold Label X Offset
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_BOSS_THRESHOLD_LABEL_X),
                tooltip = GetString(LUIE_STRING_LAM_UF_BOSS_THRESHOLD_LABEL_X_TP),
                min = -100,
                max = 100,
                step = 1,
                getFunc = function ()
                    return Settings.BossThresholdLabelOffsetX
                end,
                setFunc = function (value)
                    Settings.BossThresholdLabelOffsetX = value
                    UnitFrames.UpdateBossThresholds()
                end,
                width = "full",
                default = Defaults.BossThresholdLabelOffsetX,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses and Settings.BossShowThresholdMarkers)
                end,
            },
            {
                -- Threshold Label Y Padding
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_BOSS_THRESHOLD_LABEL_Y),
                tooltip = GetString(LUIE_STRING_LAM_UF_BOSS_THRESHOLD_LABEL_Y_TP),
                min = -100,
                max = 100,
                step = 1,
                getFunc = function ()
                    return Settings.BossThresholdLabelOffsetY
                end,
                setFunc = function (value)
                    Settings.BossThresholdLabelOffsetY = value
                    UnitFrames.UpdateBossThresholds()
                end,
                width = "full",
                default = Defaults.BossThresholdLabelOffsetY,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses and Settings.BossShowThresholdMarkers)
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (PvP Target Frame) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_HEADER),
        controls =
        {
            {
                -- Enable additional PvP Target frame
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_TARGETFRAME),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_TARGETFRAME_TP),
                getFunc = function ()
                    return Settings.AvaCustFramesTarget
                end,
                setFunc = function (value)
                    Settings.AvaCustFramesTarget = value
                end,
                width = "full",
                default = Defaults.AvaCustFramesTarget,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- PvP Target Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_TARGETFRAME_WIDTH),
                min = 300,
                max = 700,
                step = 5,
                getFunc = function ()
                    return Settings.AvaTargetBarWidth
                end,
                setFunc = function (value)
                    Settings.AvaTargetBarWidth = value
                    UnitFrames.CustomFramesApplyLayoutAvaPlayerTargetFrame(true)
                end,
                width = "full",
                default = Defaults.AvaTargetBarWidth,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.AvaCustFramesTarget)
                end,
            },
            {
                -- PvP Target Bars Height
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_TARGETFRAME_HEIGHT),
                min = 20,
                max = 70,
                step = 1,
                getFunc = function ()
                    return Settings.AvaTargetBarHeight
                end,
                setFunc = function (value)
                    Settings.AvaTargetBarHeight = value
                    UnitFrames.CustomFramesApplyLayoutAvaPlayerTargetFrame(true)
                end,
                width = "full",
                default = Defaults.AvaTargetBarHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.AvaCustFramesTarget)
                end,
            },
        },
    }

    -- Unit Frames - Common Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_COMMON_HEADER),
        controls =
        {
            {
                -- Shorten numbers
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_SHORTNUMBERS),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHORTNUMBERS_TP),
                getFunc = function ()
                    return Settings.ShortenNumbers
                end,
                setFunc = function (value)
                    Settings.ShortenNumbers = value
                    UnitFrames.CustomFramesFormatLabels(true)
                end,
                width = "full",
                default = Defaults.ShortenNumbers,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Default Caption Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_CAPTIONCOLOR),
                getFunc = function ()
                    return unpack(Settings.Target_FontColour)
                end,
                setFunc = function (r, g, b, a)
                    Settings.Target_FontColour = { r, g, b, a }
                end,
                width = "full",
                default =
                {
                    r = Defaults.Target_FontColour[1],
                    g = Defaults.Target_FontColour[2],
                    b = Defaults.Target_FontColour[3],
                    a = Defaults.Target_FontColour[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Friendly NPC Font Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_NPCFONTCOLOR),
                getFunc = function ()
                    return unpack(Settings.Target_FontColour_FriendlyNPC)
                end,
                setFunc = function (r, g, b, a)
                    Settings.Target_FontColour_FriendlyNPC = { r, g, b, a }
                end,
                width = "full",
                default =
                {
                    r = Defaults.Target_FontColour_FriendlyNPC[1],
                    g = Defaults.Target_FontColour_FriendlyNPC[2],
                    b = Defaults.Target_FontColour_FriendlyNPC[3],
                    a = Defaults.Target_FontColour_FriendlyNPC[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Friendly Player Font Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_PLAYERFONTCOLOR),
                getFunc = function ()
                    return unpack(Settings.Target_FontColour_FriendlyPlayer)
                end,
                setFunc = function (r, g, b, a)
                    Settings.Target_FontColour_FriendlyPlayer = { r, g, b, a }
                end,
                width = "full",
                default =
                {
                    r = Defaults.Target_FontColour_FriendlyPlayer[1],
                    g = Defaults.Target_FontColour_FriendlyPlayer[2],
                    b = Defaults.Target_FontColour_FriendlyPlayer[3],
                    a = Defaults.Target_FontColour_FriendlyPlayer[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Hostile Font Color
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_HOSTILEFONTCOLOR),
                getFunc = function ()
                    return unpack(Settings.Target_FontColour_Hostile)
                end,
                setFunc = function (r, g, b, a)
                    Settings.Target_FontColour_Hostile = { r, g, b, a }
                end,
                width = "full",
                default =
                {
                    r = Defaults.Target_FontColour_Hostile[1],
                    g = Defaults.Target_FontColour_Hostile[2],
                    b = Defaults.Target_FontColour_Hostile[3],
                    a = Defaults.Target_FontColour_Hostile[4]
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Apply same settings to reticle
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_COMMON_RETICLECOLOR),
                tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_RETICLECOLOR_TP),
                getFunc = function ()
                    return Settings.ReticleColourByReaction
                end,
                setFunc = UnitFrames.ReticleColorByReaction,
                width = "full",
                default = Defaults.ReticleColourByReaction,
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Interactible Reticle Color
                type = "colorpicker",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_COMMON_RETICLECOLORINTERACT)),
                getFunc = function ()
                    return unpack(Settings.ReticleColour_Interact)
                end,
                setFunc = function (r, g, b, a)
                    Settings.ReticleColour_Interact = { r, g, b, a }
                end,
                width = "full",
                default =
                {
                    r = Defaults.ReticleColour_Interact[1],
                    g = Defaults.ReticleColour_Interact[2],
                    b = Defaults.ReticleColour_Interact[3],
                    a = Defaults.ReticleColour_Interact[4]
                },
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.ReticleColourByReaction)
                end,
            },
        },
    }

    -- Register the settings panel
    LAM:RegisterAddonPanel(LUIE.name .. "UnitFramesOptions", panelDataUnitFrames)
    LAM:RegisterOptionControls(LUIE.name .. "UnitFramesOptions", optionsDataUnitFrames)
end
