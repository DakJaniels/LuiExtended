-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local GridOverlay = LUIE.GridOverlay

local GetDisplayName = GetDisplayName
local zo_strformat = zo_strformat
local GetString = GetString
local ReloadUI = ReloadUI
local ZO_Dialogs_ShowGamepadDialog = ZO_Dialogs_ShowGamepadDialog

local PetNames = LuiData.Data.PetNames

local pairs = pairs
local table = table
local table_insert = table.insert
local g_FramesMovingEnabled = false -- Helper local flag

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

local formatOptions =
{
    GetString(LUIE_STRING_LAM_UF_FORMAT_NOTHING),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_TRAUMA),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_TRAUMA),
    GetString(LUIE_STRING_LAM_UF_FORMAT_MAX),
    GetString(LUIE_STRING_LAM_UF_FORMAT_PERCENTAGE),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_MAX),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_MAX),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_TRAUMA_MAX),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_TRAUMA_MAX),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_MAX_PERCENTAGE),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_MAX_PERCENTAGE),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_TRAUMA_MAX_PERCENTAGE),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_TRAUMA_MAX_PERCENTAGE),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_PERCENTAGE),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_PERCENTAGE),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_TRAUMA_PERCENTAGE),
    GetString(LUIE_STRING_LAM_UF_FORMAT_CURRENT_SHIELD_TRAUMA_PERCENTAGE)
}

local Whitelist, WhitelistValues = {}, {}

-- Create a list of Unitnames to use for Summon Whitelist (LHAS format)
local function GenerateCustomListLHAS(input)
    local items = {}
    local counter = 0
    for name in pairs(input) do
        counter = counter + 1
        items[counter] =
        {
            name = name,
            data = name
        }
    end
    return items
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
            -- Note: LHAS dropdown updates would need to be handled differently
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

-- Load LibHarvensAddonSettings
local LHAS = LibHarvensAddonSettings

function UnitFrames.CreateConsoleSettings()
    local Defaults = UnitFrames.Defaults
    local Settings = UnitFrames.SV

    -- Load Dialog Buttons
    loadDialogButtons()

    -- Register custom pet whitelist management dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_PET_WHITELIST",
        GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST),
        function ()
            return GenerateCustomListLHAS(Settings.whitelist)
        end,
        function (itemData)
            UnitFrames.RemoveFromCustomList(Settings.whitelist, itemData)
            UnitFrames.CustomPetUpdate()
        end,
        function (text)
            UnitFrames.AddToCustomList(Settings.whitelist, text)
            UnitFrames.CustomPetUpdate()
        end,
        function ()
            UnitFrames.ClearCustomList(Settings.whitelist)
            UnitFrames.CustomPetUpdate()
        end
    )

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_UF)),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset all frame positions when defaults is clicked
                                        UnitFrames.CustomFramesResetPosition(false)
                                    end,
                                    allowRefresh = true
                                })

    local settingsData = {}

    -- Unit Frames module description
    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_UF_DESCRIPTION)
    )

    -- ReloadUI Button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RELOADUI),
        GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        function ()
            ReloadUI("ingame")
        end,
        "full",
        nil,
        GetString(LUIE_STRING_LAM_RELOADUI)
    )

    -- Custom Unit Frames Unlock
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_UNLOCK),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_UNLOCK_TP),
        function ()
            return g_FramesMovingEnabled
        end,
        function (value)
            g_FramesMovingEnabled = value
            UnitFrames.CustomFramesSetMovingState(value)
        end,
        "half",
        nil,
        false
    )

    -- Grid Snap Settings for Unit Frames
    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Enable Grid Snap (Unit Frames)",
        "Enable snapping unit frames to a grid when moving them",
        function ()
            return LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_unitFrames
        end,
        function (value)
            local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGrid_unitFrames = value
            local gridSize = accountWideSettings.snapToGridSize_unitFrames or 15
            GridOverlay.Refresh("unitFrames", g_FramesMovingEnabled and value, gridSize)
        end,
        "half",
        nil,
        false
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Grid Size (Unit Frames)",
        "Set the size of the grid for snapping unit frames",
        5, 100, 5,
        function ()
            return LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGridSize_unitFrames or 15
        end,
        function (value)
            local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]
            accountWideSettings.snapToGridSize_unitFrames = value
            GridOverlay.Refresh("unitFrames", g_FramesMovingEnabled and accountWideSettings.snapToGrid_unitFrames, value)
        end,
        "half",
        function ()
            return not LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_unitFrames
        end,
        15
    )

    -- Custom Unit Frames Reset position
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_RESETPOSITION),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_RESETPOSIT_TP),
        function ()
            UnitFrames.CustomFramesResetPosition(false)
        end,
        "half",
        nil,
        GetString(LUIE_STRING_LAM_RESETPOSITION)
    )

    -- Default Unit Frames Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_PLAYER),
        nil,
        function ()
            local choices = UnitFrames.GetDefaultFramesOptions("Player")
            local items = {}
            for i, choice in ipairs(choices) do
                items[i] = { name = choice, data = choice }
            end
            return items
        end,
        function ()
            return UnitFrames.GetDefaultFramesSetting("Player")
        end,
        function (combobox, value, item)
            UnitFrames.SetDefaultFramesSetting("Player", value)
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        UnitFrames.GetDefaultFramesSetting("Player", true)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_TARGET),
        nil,
        function ()
            local choices = UnitFrames.GetDefaultFramesOptions("Target")
            local items = {}
            for i, choice in ipairs(choices) do
                items[i] = { name = choice, data = choice }
            end
            return items
        end,
        function ()
            return UnitFrames.GetDefaultFramesSetting("Target")
        end,
        function (combobox, value, item)
            UnitFrames.SetDefaultFramesSetting("Target", value)
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        UnitFrames.GetDefaultFramesSetting("Target", true)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_GROUPSMALL),
        nil,
        function ()
            local choices = UnitFrames.GetDefaultFramesOptions("Group")
            local items = {}
            for i, choice in ipairs(choices) do
                items[i] = { name = choice, data = choice }
            end
            return items
        end,
        function ()
            return UnitFrames.GetDefaultFramesSetting("Group")
        end,
        function (combobox, value, item)
            UnitFrames.SetDefaultFramesSetting("Group", value)
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        UnitFrames.GetDefaultFramesSetting("Group", true)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_BOSS_COMPASS),
        nil,
        function ()
            local choices = UnitFrames.GetDefaultFramesOptions("Boss")
            local items = {}
            for i, choice in ipairs(choices) do
                items[i] = { name = choice, data = choice }
            end
            return items
        end,
        function ()
            return UnitFrames.GetDefaultFramesSetting("Boss")
        end,
        function (combobox, value, item)
            UnitFrames.SetDefaultFramesSetting("Boss", value)
            UnitFrames.ResetCompassBarMenu()
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        UnitFrames.GetDefaultFramesSetting("Boss", true)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_REPOSIT),
        GetString(LUIE_STRING_LAM_UF_DFRAMES_REPOSIT_TP),
        function ()
            return Settings.RepositionFrames
        end,
        function (value)
            Settings.RepositionFrames = value
            UnitFrames.RepositionDefaultFrames()
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.RepositionFrames
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_VERT),
        GetString(LUIE_STRING_LAM_UF_DFRAMES_VERT_TP),
        -150, 300, 5,
        function ()
            return Settings.RepositionFramesAdjust
        end,
        function (value)
            Settings.RepositionFramesAdjust = value
            UnitFrames.RepositionDefaultFrames()
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.RepositionFramesAdjust
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_OOCTRANS),
        GetString(LUIE_STRING_LAM_UF_DFRAMES_OOCTRANS_TP),
        0, 100, 5,
        function ()
            return Settings.DefaultOocTransparency
        end,
        function (value)
            UnitFrames.SetDefaultFramesTransparency(value, nil)
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.DefaultOocTransparency
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_INCTRANS),
        GetString(LUIE_STRING_LAM_UF_DFRAMES_INCTRANS_TP),
        0, 100, 5,
        function ()
            return Settings.DefaultIncTransparency
        end,
        function (value)
            UnitFrames.SetDefaultFramesTransparency(nil, value)
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.DefaultIncTransparency
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL),
        GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL_TP),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.Format
        end,
        function (combobox, value, item)
            Settings.Format = value
        end,
        Defaults.Format,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_FONT),
        GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_TP),
        SettingsAPI.GetFontsList(),
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
        Defaults.DefaultFontFace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_FONT_SIZE),
        GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_SIZE_TP),
        10, 30, 1,
        function ()
            return Settings.DefaultFontSize
        end,
        function (value)
            Settings.DefaultFontSize = value
            UnitFrames.DefaultFramesApplyFont()
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.DefaultFontSize
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_FONT_STYLE),
        GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_STYLE_TP),
        function ()
            return Settings.DefaultFontStyle
        end,
        function (var)
            Settings.DefaultFontStyle = var
            UnitFrames.DefaultFramesApplyFont()
        end,
        Defaults.DefaultFontStyle,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL_COLOR),
        nil,
        function ()
            return unpack(Settings.DefaultTextColour)
        end,
        function (r, g, b, a)
            Settings.DefaultTextColour = { r, g, b, a }
            UnitFrames.DefaultFramesApplyColor()
        end,
        Defaults.DefaultTextColour,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_TARGET_COLOR_REACTION),
        GetString(LUIE_STRING_LAM_UF_TARGET_COLOR_REACTION_TP),
        function ()
            return Settings.TargetColourByReaction
        end,
        UnitFrames.TargetColorByReaction,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.TargetColourByReaction
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_TARGET_ICON_CLASS),
        GetString(LUIE_STRING_LAM_UF_TARGET_ICON_CLASS_TP),
        function ()
            return Settings.TargetShowClass
        end,
        function (value)
            Settings.TargetShowClass = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.TargetShowClass
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_TARGET_ICON_GFI),
        GetString(LUIE_STRING_LAM_UF_TARGET_ICON_GFI_TP),
        function ()
            return Settings.TargetShowFriend
        end,
        function (value)
            Settings.TargetShowFriend = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.TargetShowFriend
    )

    -- Custom Unit Frames Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_FONT),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TP),
        SettingsAPI.GetFontsList(),
        function ()
            return Settings.CustomFontFace
        end,
        function (var)
            Settings.CustomFontFace = var
            UnitFrames.CustomFramesApplyFont()
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFontFace
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS_TP),
        10, 30, 1,
        function ()
            return Settings.CustomFontOther
        end,
        function (value)
            Settings.CustomFontOther = value
            UnitFrames.CustomFramesApplyFont()
        end,
        "half",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFontOther
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS_TP),
        10, 30, 1,
        function ()
            return Settings.CustomFontBars
        end,
        function (value)
            Settings.CustomFontBars = value
            UnitFrames.CustomFramesApplyFont()
        end,
        "half",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFontBars
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateFontStyleDropdown(
        GetString(LUIE_STRING_LAM_FONT_STYLE),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_STYLE_TP),
        function ()
            return Settings.CustomFontStyle
        end,
        function (var)
            Settings.CustomFontStyle = var
            UnitFrames.CustomFramesApplyFont()
        end,
        Defaults.CustomFontStyle,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE_TP),
        SettingsAPI.GetStatusbarTexturesList(),
        function ()
            return Settings.CustomTexture
        end,
        function (var)
            Settings.CustomTexture = var
            UnitFrames.CustomFramesApplyTexture()
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomTexture
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_TP),
        function ()
            return Settings.CustomShieldBarSeparate
        end,
        function (value)
            Settings.CustomShieldBarSeparate = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomShieldBarSeparate,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_HEIGHT),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_HEIGHT_TP),
        4, 12, 1,
        function ()
            return Settings.CustomShieldBarHeight
        end,
        function (value)
            Settings.CustomShieldBarHeight = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
            UnitFrames.CustomFramesApplyLayoutGroup()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and not Settings.CustomShieldBarFull)
        end,
        Defaults.CustomShieldBarHeight,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_OVERLAY),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_OVERLAY_TP),
        function ()
            return Settings.CustomShieldBarFull
        end,
        function (value)
            Settings.CustomShieldBarFull = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and not Settings.CustomShieldBarSeparate)
        end,
        Defaults.CustomShieldBarFull,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_ALPHA),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_ALPHA_TP),
        0, 100, 1,
        function ()
            return Settings.ShieldAlpha
        end,
        function (value)
            Settings.ShieldAlpha = value
            UnitFrames.CustomFramesApplyColors(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and not Settings.CustomShieldBarSeparate)
        end,
        Defaults.ShieldAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SMOOTHBARTRANS),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_SMOOTHBARTRANS_TP),
        function ()
            return Settings.CustomSmoothBar
        end,
        function (value)
            Settings.CustomSmoothBar = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomSmoothBar
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Format unitFrame names with target marker",
        "Format unitFrame names with target marker",
        function ()
            return Settings.CustomTargetMarker
        end,
        function (value)
            Settings.CustomTargetMarker = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomTargetMarker
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Target Frame Quick Hide Dead Enemy/Neutral",
        "Target Frame Quick Hide Dead Enemy/Neutral",
        function ()
            return Settings.QuickHideDead
        end,
        function (value)
            Settings.QuickHideDead = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.QuickHideDead
    )

    -- Custom Unit Frame Color Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEALTH),
        nil,
        function ()
            return unpack(Settings.CustomColourHealth)
        end,
        function (r, g, b, a)
            Settings.CustomColourHealth = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourHealth,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_SHIELD),
        nil,
        function ()
            return Settings.CustomColourShield[1], Settings.CustomColourShield[2], Settings.CustomColourShield[3]
        end,
        function (r, g, b, a)
            Settings.CustomColourShield = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourShield,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TRAUMA),
        nil,
        function ()
            return Settings.CustomColourTrauma[1], Settings.CustomColourTrauma[2], Settings.CustomColourTrauma[3]
        end,
        function (r, g, b, a)
            Settings.CustomColourTrauma = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourTrauma,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_MAGICKA),
        nil,
        function ()
            return unpack(Settings.CustomColourMagicka)
        end,
        function (r, g, b, a)
            Settings.CustomColourMagicka = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourMagicka,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_STAMINA),
        nil,
        function ()
            return unpack(Settings.CustomColourStamina)
        end,
        function (r, g, b, a)
            Settings.CustomColourStamina = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourStamina,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_INVULNERABLE),
        nil,
        function ()
            return Settings.CustomColourInvulnerable[1], Settings.CustomColourInvulnerable[2], Settings.CustomColourInvulnerable[3]
        end,
        function (r, g, b, a)
            Settings.CustomColourInvulnerable = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourInvulnerable,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_DPS),
        nil,
        function ()
            return unpack(Settings.CustomColourDPS)
        end,
        function (r, g, b, a)
            Settings.CustomColourDPS = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourDPS,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEALER),
        nil,
        function ()
            return unpack(Settings.CustomColourHealer)
        end,
        function (r, g, b, a)
            Settings.CustomColourHealer = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourHealer,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TANK),
        nil,
        function ()
            return unpack(Settings.CustomColourTank)
        end,
        function (r, g, b, a)
            Settings.CustomColourTank = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourTank,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_DK),
        nil,
        function ()
            return unpack(Settings.CustomColourDragonknight)
        end,
        function (r, g, b, a)
            Settings.CustomColourDragonknight = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourDragonknight,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_NB),
        nil,
        function ()
            return unpack(Settings.CustomColourNightblade)
        end,
        function (r, g, b, a)
            Settings.CustomColourNightblade = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourNightblade,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_SORC),
        nil,
        function ()
            return unpack(Settings.CustomColourSorcerer)
        end,
        function (r, g, b, a)
            Settings.CustomColourSorcerer = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourSorcerer,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TEMP),
        nil,
        function ()
            return unpack(Settings.CustomColourTemplar)
        end,
        function (r, g, b, a)
            Settings.CustomColourTemplar = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourTemplar,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_WARD),
        nil,
        function ()
            return unpack(Settings.CustomColourWarden)
        end,
        function (r, g, b, a)
            Settings.CustomColourWarden = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourWarden,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_NECRO),
        nil,
        function ()
            return unpack(Settings.CustomColourNecromancer)
        end,
        function (r, g, b, a)
            Settings.CustomColourNecromancer = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourNecromancer,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_ARCA),
        nil,
        function ()
            return unpack(Settings.CustomColourArcanist)
        end,
        function (r, g, b, a)
            Settings.CustomColourArcanist = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourArcanist,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_PLAYER),
        nil,
        function ()
            return unpack(Settings.CustomColourPlayer)
        end,
        function (r, g, b, a)
            Settings.CustomColourPlayer = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourPlayer,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_FRIENDLY),
        nil,
        function ()
            return unpack(Settings.CustomColourFriendly)
        end,
        function (r, g, b, a)
            Settings.CustomColourFriendly = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourFriendly,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_COMPANION),
        nil,
        function ()
            return unpack(Settings.CustomColourCompanion)
        end,
        function (r, g, b, a)
            Settings.CustomColourCompanion = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourCompanion,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_HOSTILE),
        nil,
        function ()
            return unpack(Settings.CustomColourHostile)
        end,
        function (r, g, b, a)
            Settings.CustomColourHostile = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourHostile,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_NEUTRAL),
        nil,
        function ()
            return unpack(Settings.CustomColourNeutral)
        end,
        function (r, g, b, a)
            Settings.CustomColourNeutral = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourNeutral,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_GUARD),
        nil,
        function ()
            return unpack(Settings.CustomColourGuard)
        end,
        function (r, g, b, a)
            Settings.CustomColourGuard = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourGuard,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_COLOR),
        nil,
        function ()
            return unpack(Settings.CustomColourPet)
        end,
        function (r, g, b, a)
            Settings.CustomColourPet = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourPet,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_COLOR),
        nil,
        function ()
            return unpack(Settings.CustomColourCompanionFrame)
        end,
        function (r, g, b, a)
            Settings.CustomColourCompanionFrame = { r, g, b, a }
            UnitFrames.CustomFramesApplyColors(true)
        end,
        Defaults.CustomColourCompanionFrame,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    -- Custom Unit Frames (Player & Target) Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_PLAYER),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_PLAYER_TP),
        function ()
            return Settings.CustomFramesPlayer
        end,
        function (value)
            Settings.CustomFramesPlayer = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFramesPlayer,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_TARGET),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_TARGET_TP),
        function ()
            return Settings.CustomFramesTarget
        end,
        function (value)
            Settings.CustomFramesTarget = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFramesTarget,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_PLAYER),
        GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_PLAYER_TP),
        function ()
            local items = {}
            for i, option in ipairs(nameDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return nameDisplayOptions[Settings.DisplayOptionsPlayer]
        end,
        function (combobox, value, item)
            Settings.DisplayOptionsPlayer = nameDisplayOptionsKeys[value]
            UnitFrames.CustomFramesReloadControlsMenu(true)
        end,
        nameDisplayOptions[2],
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_TARGET),
        GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_TARGET_TP),
        function ()
            local items = {}
            for i, option in ipairs(nameDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return nameDisplayOptions[Settings.DisplayOptionsTarget]
        end,
        function (combobox, value, item)
            Settings.DisplayOptionsTarget = nameDisplayOptionsKeys[value]
            UnitFrames.CustomFramesReloadControlsMenu(true)
        end,
        nameDisplayOptions[2],
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT),
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT_TP),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.CustomFormatOnePT
        end,
        function (combobox, value, item)
            Settings.CustomFormatOnePT = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        Defaults.CustomFormatOnePT,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.CustomFormatTwoPT
        end,
        function (combobox, value, item)
            Settings.CustomFormatTwoPT = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        Defaults.CustomFormatTwoPT,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_WIDTH),
        nil,
        200, 500, 5,
        function ()
            return Settings.PlayerBarWidth
        end,
        function (value)
            Settings.PlayerBarWidth = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.PlayerBarWidth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_HIGHT),
        nil,
        20, 70, 1,
        function ()
            return Settings.PlayerBarHeightHealth
        end,
        function (value)
            Settings.PlayerBarHeightHealth = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.PlayerBarHeightHealth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_HIGHT),
        nil,
        20, 70, 1,
        function ()
            return Settings.PlayerBarHeightMagicka
        end,
        function (value)
            Settings.PlayerBarHeightMagicka = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.PlayerBarHeightMagicka
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_HIGHT),
        nil,
        20, 70, 1,
        function ()
            return Settings.PlayerBarHeightStamina
        end,
        function (value)
            Settings.PlayerBarHeightStamina = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.PlayerBarHeightStamina
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_OOCPACITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_OOCPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.PlayerOocAlpha
        end,
        function (value)
            Settings.PlayerOocAlpha = value
            UnitFrames.CustomFramesApplyInCombat()
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.PlayerOocAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_ICPACITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_ICPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.PlayerIncAlpha
        end,
        function (value)
            Settings.PlayerIncAlpha = value
            UnitFrames.CustomFramesApplyInCombat()
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.PlayerIncAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BuFFS_PLAYER),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BuFFS_PLAYER_TP),
        function ()
            return Settings.HideBuffsPlayerOoc
        end,
        function (value)
            Settings.HideBuffsPlayerOoc = value
            UnitFrames.CustomFramesApplyInCombat()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.HideBuffsPlayerOoc
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_NAMESELF),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_NAMESELF_TP),
        function ()
            return Settings.PlayerEnableYourname
        end,
        function (value)
            Settings.PlayerEnableYourname = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.PlayerEnableYourname
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MOUNTSIEGEWWBAR),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MOUNTSIEGEWWBAR_TP),
        function ()
            return Settings.PlayerEnableAltbarMSW
        end,
        function (value)
            Settings.PlayerEnableAltbarMSW = value
            UnitFrames.CustomFramesSetupAlternative()
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.PlayerEnableAltbarMSW
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBAR),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBAR_TP),
        function ()
            return Settings.PlayerEnableAltbarXP
        end,
        function (value)
            Settings.PlayerEnableAltbarXP = value
            UnitFrames.CustomFramesSetupAlternative()
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.PlayerEnableAltbarXP
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBARCOLOR),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBARCOLOR_TP),
        function ()
            return Settings.PlayerChampionColour
        end,
        function (value)
            Settings.PlayerChampionColour = value
            UnitFrames.OnChampionPointGained()
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerEnableAltbarXP)
        end,
        Defaults.PlayerChampionColour,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_HEALTH),
        GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_HEALTH_TP),
        0, 50, 1,
        function ()
            return Settings.LowResourceHealth
        end,
        function (value)
            Settings.LowResourceHealth = value
            UnitFrames.CustomFramesReloadLowResourceThreshold()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.LowResourceHealth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_MAGICKA),
        GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_MAGICKA_TP),
        0, 50, 1,
        function ()
            return Settings.LowResourceMagicka
        end,
        function (value)
            Settings.LowResourceMagicka = value
            UnitFrames.CustomFramesReloadLowResourceThreshold()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.LowResourceMagicka
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_STAMINA),
        GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_STAMINA_TP),
        0, 50, 1,
        function ()
            return Settings.LowResourceStamina
        end,
        function (value)
            Settings.LowResourceStamina = value
            UnitFrames.CustomFramesReloadLowResourceThreshold()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.LowResourceStamina
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_WIDTH),
        nil,
        200, 500, 5,
        function ()
            return Settings.TargetBarWidth
        end,
        function (value)
            Settings.TargetBarWidth = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
        end,
        Defaults.TargetBarWidth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_HEIGHT),
        nil,
        20, 70, 1,
        function ()
            return Settings.TargetBarHeight
        end,
        function (value)
            Settings.TargetBarHeight = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
        end,
        Defaults.TargetBarHeight
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_OOCPACITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_OOCPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.TargetOocAlpha
        end,
        function (value)
            Settings.TargetOocAlpha = value
            UnitFrames.CustomFramesApplyInCombat()
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.TargetOocAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_ICPACITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_ICPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.TargetIncAlpha
        end,
        function (value)
            Settings.TargetIncAlpha = value
            UnitFrames.CustomFramesApplyInCombat()
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.TargetIncAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BUFFS_TARGET),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BUFFS_TARGET_TP),
        function ()
            return Settings.HideBuffsTargetOoc
        end,
        function (value)
            Settings.HideBuffsTargetOoc = value
            UnitFrames.CustomFramesApplyInCombat()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.HideBuffsTargetOoc
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_REACTION_TARGET),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_REACTION_TARGET_TP),
        function ()
            return Settings.FrameColorReaction
        end,
        function (value)
            Settings.FrameColorReaction = value
            UnitFrames.CustomFramesApplyReactionColor()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
        end,
        Defaults.FrameColorReaction
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_CLASS_TARGET),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_CLASS_TARGET_TP),
        function ()
            return Settings.FrameColorClass
        end,
        function (value)
            Settings.FrameColorClass = value
            UnitFrames.CustomFramesApplyReactionColor()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
        end,
        Defaults.FrameColorClass
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_CLASSLABEL),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_CLASSLABEL_TP),
        function ()
            return Settings.TargetEnableClass
        end,
        function (value)
            Settings.TargetEnableClass = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
        end,
        Defaults.TargetEnableClass
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETHRESHOLD),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETHRESHOLD_TP),
        0, 50, 5,
        function ()
            return Settings.ExecutePercentage
        end,
        function (value)
            Settings.ExecutePercentage = value
            UnitFrames.CustomFramesReloadExecuteMenu()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
        end,
        Defaults.ExecutePercentage
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETEXTURE),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETEXTURE_TP),
        function ()
            return Settings.TargetEnableSkull
        end,
        function (value)
            Settings.TargetEnableSkull = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
        end,
        Defaults.TargetEnableSkull
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TITLE),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TITLE_TP),
        function ()
            return Settings.TargetEnableTitle
        end,
        function (value)
            Settings.TargetEnableTitle = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.TargetEnableTitle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TP),
        function ()
            return Settings.TargetEnableRank
        end,
        function (value)
            Settings.TargetEnableRank = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.TargetEnableRank
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TITLE_PRIORITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TITLE_PRIORITY_TP),
        function ()
            return
            {
                { name = "AVA Rank", data = "AVA Rank" },
                { name = "Title",    data = "Title"    }
            }
        end,
        function ()
            return Settings.TargetTitlePriority
        end,
        function (combobox, value, item)
            Settings.TargetTitlePriority = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        Defaults.TargetTitlePriority,
        5,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.TargetEnableRank and Settings.TargetEnableTitle)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANKICON),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANKICON_TP),
        function ()
            return Settings.TargetEnableRankIcon
        end,
        function (value)
            Settings.TargetEnableRankIcon = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.TargetEnableRankIcon
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_PT)),
        GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
        function ()
            return Settings.PlayerEnableArmor
        end,
        function (value)
            Settings.PlayerEnableArmor = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.PlayerEnableArmor,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_PT)),
        GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
        function ()
            return Settings.PlayerEnablePower
        end,
        function (value)
            Settings.PlayerEnablePower = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.PlayerEnablePower,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_PT)),
        GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
        function ()
            return Settings.PlayerEnableRegen
        end,
        function (value)
            Settings.PlayerEnableRegen = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.PlayerEnableRegen,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT_TP),
        function ()
            return Settings.CustomOocAlphaPower
        end,
        function (value)
            Settings.CustomOocAlphaPower = value
            UnitFrames.CustomFramesApplyInCombat()
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
        end,
        Defaults.CustomOocAlphaPower
    )

    -- Custom Unit Frames Bar Alignment Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_HEALTH),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_HEALTH_TP),
        function ()
            local items = {}
            for i, option in ipairs(alignmentOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return alignmentOptions[Settings.BarAlignPlayerHealth]
        end,
        function (combobox, value, item)
            Settings.BarAlignPlayerHealth = alignmentOptionsKeys[value]
            UnitFrames.CustomFramesApplyBarAlignment()
        end,
        alignmentOptions[Defaults.BarAlignPlayerHealth],
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_MAGICKA),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_MAGICKA_TP),
        function ()
            local items = {}
            for i, option in ipairs(alignmentOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return alignmentOptions[Settings.BarAlignPlayerMagicka]
        end,
        function (combobox, value, item)
            Settings.BarAlignPlayerMagicka = alignmentOptionsKeys[value]
            UnitFrames.CustomFramesApplyBarAlignment()
        end,
        alignmentOptions[Defaults.BarAlignPlayerMagicka],
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_STAMINA),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_STAMINA_TP),
        function ()
            local items = {}
            for i, option in ipairs(alignmentOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return alignmentOptions[Settings.BarAlignPlayerStamina]
        end,
        function (combobox, value, item)
            Settings.BarAlignPlayerStamina = alignmentOptionsKeys[value]
            UnitFrames.CustomFramesApplyBarAlignment()
        end,
        alignmentOptions[Defaults.BarAlignPlayerStamina],
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_TARGET),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_TARGET_TP),
        function ()
            local items = {}
            for i, option in ipairs(alignmentOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return alignmentOptions[Settings.BarAlignTarget]
        end,
        function (combobox, value, item)
            Settings.BarAlignTarget = alignmentOptionsKeys[value]
            UnitFrames.CustomFramesApplyBarAlignment()
        end,
        alignmentOptions[Defaults.BarAlignTarget],
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_PLAYER),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_PLAYER_TP),
        function ()
            return Settings.BarAlignCenterLabelPlayer
        end,
        function (value)
            Settings.BarAlignCenterLabelPlayer = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.BarAlignCenterLabelPlayer
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_TARGET),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_TARGET_TP),
        function ()
            return Settings.BarAlignCenterLabelTarget
        end,
        function (value)
            Settings.BarAlignCenterLabelTarget = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.BarAlignCenterLabelTarget
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_CENTER_FORM),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_CENTER_FORM),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.CustomFormatCenterLabel
        end,
        function (combobox, value, item)
            Settings.CustomFormatCenterLabel = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        Defaults.CustomFormatCenterLabel,
        5,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    -- Additional Player Frame Display Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_OPTIONS_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD_TP),
        function ()
            local items = {}
            for i, option in ipairs(playerFrameOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return playerFrameOptions[Settings.PlayerFrameOptions]
        end,
        function (combobox, value, item)
            Settings.PlayerFrameOptions = playerFrameOptionsKeys[value]
            UnitFrames.MenuUpdatePlayerFrameOptions(Settings.PlayerFrameOptions)
        end,
        playerFrameOptions[Defaults.PlayerFrameOptions],
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD_WARN)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_HORIZ_ADJUST),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_HORIZ_ADJUST_TP),
        0, 500, 5,
        function ()
            return Settings.AdjustStaminaHPos
        end,
        function (value)
            Settings.AdjustStaminaHPos = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
        end,
        Defaults.AdjustStaminaHPos,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_VERT_ADJUST),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_VERT_ADJUST_TP),
        -250, 250, 5,
        function ()
            return Settings.AdjustStaminaVPos
        end,
        function (value)
            Settings.AdjustStaminaVPos = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
        end,
        Defaults.AdjustStaminaVPos,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_HORIZ_ADJUST),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_HORIZ_ADJUST_TP),
        0, 500, 5,
        function ()
            return Settings.AdjustMagickaHPos
        end,
        function (value)
            Settings.AdjustMagickaHPos = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
        end,
        Defaults.AdjustMagickaHPos,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_VERT_ADJUST),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_VERT_ADJUST_TP),
        -250, 250, 5,
        function ()
            return Settings.AdjustMagickaVPos
        end,
        function (value)
            Settings.AdjustMagickaVPos = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
        end,
        Defaults.AdjustMagickaVPos,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_SPACING),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_SPACING_TP),
        -1, 4, 1,
        function ()
            return Settings.PlayerBarSpacing
        end,
        function (value)
            Settings.PlayerBarSpacing = value
            UnitFrames.CustomFramesApplyLayoutPlayer(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and (Settings.PlayerFrameOptions == 1 or Settings.PlayerFrameOptions == 3))
        end,
        Defaults.PlayerBarSpacing,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOLABEL),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOLABEL_TP),
        function ()
            return Settings.HideLabelHealth
        end,
        function (value)
            Settings.HideLabelHealth = value
            Settings.HideBarHealth = false
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.HideLabelHealth,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOBAR),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOBAR_TP),
        function ()
            return Settings.HideBarHealth
        end,
        function (value)
            Settings.HideBarHealth = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelHealth)
        end,
        Defaults.HideBarHealth,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOLABEL),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOLABEL_TP),
        function ()
            return Settings.HideLabelMagicka
        end,
        function (value)
            Settings.HideLabelMagicka = value
            Settings.HideBarMagicka = false
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.HideLabelMagicka,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOBAR),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOBAR_TP),
        function ()
            return Settings.HideBarMagicka
        end,
        function (value)
            Settings.HideBarMagicka = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelMagicka)
        end,
        Defaults.HideBarMagicka,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOLABEL),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOLABEL_TP),
        function ()
            return Settings.HideLabelStamina
        end,
        function (value)
            Settings.HideLabelStamina = value
            Settings.HideBarStamina = false
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.HideLabelStamina,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOBAR),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOBAR_TP),
        function ()
            return Settings.HideBarStamina
        end,
        function (value)
            Settings.HideBarStamina = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelStamina)
        end,
        Defaults.HideBarStamina,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_REVERSE_RES),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_REVERSE_RES_TP),
        function ()
            return Settings.ReverseResourceBars
        end,
        function (value)
            Settings.ReverseResourceBars = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
        end,
        Defaults.ReverseResourceBars,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Custom Unit Frames (Group) Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_LUIEFRAMESENABLE),
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_LUIEFRAMESENABLE_TP),
        function ()
            return Settings.CustomFramesGroup
        end,
        function (value)
            Settings.CustomFramesGroup = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFramesGroup,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID),
        GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID_TP),
        function ()
            local items = {}
            for i, option in ipairs(nameDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return nameDisplayOptions[Settings.DisplayOptionsGroupRaid]
        end,
        function (combobox, value, item)
            Settings.DisplayOptionsGroupRaid = nameDisplayOptionsKeys[value]
            UnitFrames.CustomFramesReloadControlsMenu(false, true, true)
        end,
        nameDisplayOptions[2],
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT),
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT_TP),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.CustomFormatOneGroup
        end,
        function (combobox, value, item)
            Settings.CustomFormatOneGroup = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutGroup(true)
        end,
        Defaults.CustomFormatOneGroup,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.CustomFormatTwoGroup
        end,
        function (combobox, value, item)
            Settings.CustomFormatTwoGroup = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutGroup(true)
        end,
        Defaults.CustomFormatTwoGroup,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_WIDTH),
        nil,
        100, 400, 5,
        function ()
            return Settings.GroupBarWidth
        end,
        function (value)
            Settings.GroupBarWidth = value
            UnitFrames.CustomFramesApplyLayoutGroup(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.GroupBarWidth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_HEIGHT),
        nil,
        20, 70, 1,
        function ()
            return Settings.GroupBarHeight
        end,
        function (value)
            Settings.GroupBarHeight = value
            UnitFrames.CustomFramesApplyLayoutGroup(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.GroupBarHeight
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY),
        GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.GroupAlpha
        end,
        function (value)
            Settings.GroupAlpha = value
            UnitFrames.CustomFramesGroupAlpha()
            UnitFrames.CustomFramesApplyLayoutGroup(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.GroupAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_SPACING),
        nil,
        20, 80, 2,
        function ()
            return Settings.GroupBarSpacing
        end,
        function (value)
            Settings.GroupBarSpacing = value
            UnitFrames.CustomFramesApplyLayoutGroup(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.GroupBarSpacing
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_INCPLAYER),
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_INCPLAYER_TP),
        function ()
            return not Settings.GroupExcludePlayer
        end,
        function (value)
            Settings.GroupExcludePlayer = not value
            UnitFrames.CustomFramesGroupUpdate()
            UnitFrames.CustomFramesApplyLayoutGroup(true)
            UnitFrames.CustomFramesApplyColors(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        not Defaults.GroupExcludePlayer
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_ROLEICON),
        GetString(LUIE_STRING_LAM_UF_CFRAMESG_ROLEICON_TP),
        function ()
            return Settings.RoleIconSmallGroup
        end,
        function (value)
            Settings.RoleIconSmallGroup = value
            UnitFrames.CustomFramesApplyLayoutGroup(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.RoleIconSmallGroup
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYCLASS),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYCLASS_TP),
        function ()
            return Settings.ColorClassGroup
        end,
        function (value)
            Settings.ColorClassGroup = value
            UnitFrames.CustomFramesApplyColors(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.ColorClassGroup
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYROLE),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYROLE_TP),
        function ()
            return Settings.ColorRoleGroup
        end,
        function (value)
            Settings.ColorRoleGroup = value
            UnitFrames.CustomFramesApplyColors(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.ColorRoleGroup
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Sort Group Frames by Role",
        "Sort group members by role (Tank -> Healer -> DPS).",
        function ()
            return Settings.SortRoleGroup
        end,
        function (value)
            Settings.SortRoleGroup = value
            UnitFrames.CustomFramesApplyLayoutGroup(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.SortRoleGroup
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
        GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
        function ()
            return Settings.GroupEnableArmor
        end,
        function (value)
            Settings.GroupEnableArmor = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.GroupEnableArmor,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
        GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
        function ()
            return Settings.GroupEnablePower
        end,
        function (value)
            Settings.GroupEnablePower = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.GroupEnablePower,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
        GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
        function ()
            return Settings.GroupEnableRegen
        end,
        function (value)
            Settings.GroupEnableRegen = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.GroupEnableRegen,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show Combat Glow",
        "Display a red glow around group member health bars when they are in combat (fades in/out smoothly).",
        function ()
            return Settings.GroupCombatGlow
        end,
        function (value)
            Settings.GroupCombatGlow = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
        end,
        Defaults.GroupCombatGlow
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        "Combat Glow Color",
        "Set the color of the combat glow border displayed around group frames.",
        function ()
            return unpack(Settings.GroupCombatGlowColor)
        end,
        function (r, g, b, a)
            Settings.GroupCombatGlowColor = { r, g, b, a }
            if UnitFrames.CustomFramesApplyColors then
                UnitFrames.CustomFramesApplyColors(true)
            end
        end,
        Defaults.GroupCombatGlowColor,
        5,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup and Settings.GroupCombatGlow)
        end
    )

    -- Custom Unit Frames (Raid) Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_LUIEFRAMESENABLE),
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_LUIEFRAMESENABLE_TP),
        function ()
            return Settings.CustomFramesRaid
        end,
        function (value)
            Settings.CustomFramesRaid = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFramesRaid,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID),
        GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID_TP),
        function ()
            local items = {}
            for i, option in ipairs(nameDisplayOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return nameDisplayOptions[Settings.DisplayOptionsGroupRaid]
        end,
        function (combobox, value, item)
            Settings.DisplayOptionsGroupRaid = nameDisplayOptionsKeys[value]
            UnitFrames.CustomFramesReloadControlsMenu(false, true, true)
        end,
        nameDisplayOptions[2],
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.CustomFormatRaid
        end,
        function (combobox, value, item)
            Settings.CustomFormatRaid = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        Defaults.CustomFormatRaid,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_WIDTH),
        nil,
        100, 500, 5,
        function ()
            return Settings.RaidBarWidth
        end,
        function (value)
            Settings.RaidBarWidth = value
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.RaidBarWidth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_HEIGHT),
        nil,
        20, 70, 1,
        function ()
            return Settings.RaidBarHeight
        end,
        function (value)
            Settings.RaidBarHeight = value
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.RaidBarHeight
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY),
        GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.GroupAlpha
        end,
        function (value)
            Settings.GroupAlpha = value
            UnitFrames.CustomFramesGroupAlpha()
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.GroupAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_LAYOUT),
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_LAYOUT_TP),
        function ()
            return
            {
                { name = "1 x 12", data = "1 x 12" },
                { name = "2 x 6",  data = "2 x 6"  },
                { name = "3 x 4",  data = "3 x 4"  },
                { name = "6 x 2",  data = "6 x 2"  }
            }
        end,
        function ()
            return Settings.RaidLayout
        end,
        function (combobox, value, item)
            Settings.RaidLayout = value
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        Defaults.RaidLayout,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_SPACER),
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_SPACER_TP),
        function ()
            return Settings.RaidSpacers
        end,
        function (value)
            Settings.RaidSpacers = value
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.RaidSpacers
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_NAMECLIP),
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_NAMECLIP_TP),
        0, 200, 1,
        function ()
            return Settings.RaidNameClip
        end,
        function (value)
            Settings.RaidNameClip = value
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.RaidNameClip
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_ROLEICON),
        GetString(LUIE_STRING_LAM_UF_CFRAMESR_ROLEICON_TP),
        function ()
            local items = {}
            for i, option in ipairs(raidIconOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return raidIconOptions[Settings.RaidIconOptions]
        end,
        function (combobox, value, item)
            Settings.RaidIconOptions = raidIconOptionsKeys[value]
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        raidIconOptions[Defaults.RaidIconOptions],
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYCLASS),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYCLASS_TP),
        function ()
            return Settings.ColorClassRaid
        end,
        function (value)
            Settings.ColorClassRaid = value
            UnitFrames.CustomFramesApplyColors(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.ColorClassRaid
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYROLE),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYROLE_TP),
        function ()
            return Settings.ColorRoleRaid
        end,
        function (value)
            Settings.ColorRoleRaid = value
            UnitFrames.CustomFramesApplyColors(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.ColorRoleRaid
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESSORT),
        GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESSORT_TP),
        function ()
            return Settings.SortRoleRaid
        end,
        function (value)
            Settings.SortRoleRaid = value
            UnitFrames.CustomFramesApplyLayoutRaid(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid and Settings.ColorRoleRaid)
        end,
        Defaults.SortRoleRaid
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
        GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
        function ()
            return Settings.RaidEnableArmor
        end,
        function (value)
            Settings.RaidEnableArmor = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.RaidEnableArmor,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
        GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
        function ()
            return Settings.RaidEnablePower
        end,
        function (value)
            Settings.RaidEnablePower = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.RaidEnablePower,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
        GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
        function ()
            return Settings.RaidEnableRegen
        end,
        function (value)
            Settings.RaidEnableRegen = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.RaidEnableRegen,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show Combat Glow",
        "Display a red glow around raid member health bars when they are in combat (fades in/out smoothly).",
        function ()
            return Settings.RaidCombatGlow
        end,
        function (value)
            Settings.RaidCombatGlow = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
        end,
        Defaults.RaidCombatGlow
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedColorpickerFromTable(
        "Combat Glow Color",
        "Set the color of the combat glow border displayed around raid frames.",
        function ()
            return unpack(Settings.RaidCombatGlowColor)
        end,
        function (r, g, b, a)
            Settings.RaidCombatGlowColor = { r, g, b, a }
            if UnitFrames.CustomFramesApplyColors then
                UnitFrames.CustomFramesApplyColors(true)
            end
        end,
        Defaults.RaidCombatGlowColor,
        5,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid and Settings.RaidCombatGlow)
        end
    )

    -- Group Resources (LibGroupBroadcast) Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Group Resources"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Enable Group Resources",
        "Display magicka and stamina bars for group members using LibGroupBroadcast.",
        function ()
            return Settings.GroupResources.enabled
        end,
        function (value)
            Settings.GroupResources.enabled = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and LibGroupBroadcast)
        end,
        Defaults.GroupResources.enabled,
        "Requires LibGroupBroadcast library. " .. GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Stamina First",
        "Show stamina bar above magicka bar instead of below.",
        function ()
            return Settings.GroupResources.staminaFirst
        end,
        function (value)
            Settings.GroupResources.staminaFirst = value
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.UpdateAllLayouts()
            end
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end,
        Defaults.GroupResources.staminaFirst
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Fade Effect on Resource Loss",
        "Show a fade-out ghost effect when resources decrease for better visibility.",
        function ()
            return Settings.GroupResources.enableFadeEffect
        end,
        function (value)
            Settings.GroupResources.enableFadeEffect = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end,
        Defaults.GroupResources.enableFadeEffect
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Hide Resource Bars (Timeout)",
        "Hide resource bars after no updates received for set timeout period.",
        function ()
            return Settings.GroupResources.hideResourceBarsToggle
        end,
        function (value)
            Settings.GroupResources.hideResourceBarsToggle = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end,
        Defaults.GroupResources.hideResourceBarsToggle
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        "Hide Timeout (seconds)",
        "Seconds after last resource update before hiding bars.",
        5, 600, 5,
        function ()
            return Settings.GroupResources.hideResourceBarsTimeout
        end,
        function (value)
            Settings.GroupResources.hideResourceBarsTimeout = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled and Settings.GroupResources.hideResourceBarsToggle)
        end,
        Defaults.GroupResources.hideResourceBarsTimeout,
        5
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Group Frame Bar Width",
        nil,
        50, 300, 5,
        function ()
            return Settings.GroupResources.groupBarWidth
        end,
        function (value)
            Settings.GroupResources.groupBarWidth = value
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.UpdateAllLayouts()
            end
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end,
        Defaults.GroupResources.groupBarWidth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Group Frame Bar Height",
        nil,
        3, 15, 1,
        function ()
            return Settings.GroupResources.groupBarHeight
        end,
        function (value)
            Settings.GroupResources.groupBarHeight = value
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.UpdateAllLayouts()
            end
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end,
        Defaults.GroupResources.groupBarHeight
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Raid Frame Bar Width",
        nil,
        50, 250, 5,
        function ()
            return Settings.GroupResources.raidBarWidth
        end,
        function (value)
            Settings.GroupResources.raidBarWidth = value
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.UpdateAllLayouts()
            end
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end,
        Defaults.GroupResources.raidBarWidth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Raid Frame Bar Height",
        nil,
        3, 15, 1,
        function ()
            return Settings.GroupResources.raidBarHeight
        end,
        function (value)
            Settings.GroupResources.raidBarHeight = value
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.UpdateAllLayouts()
            end
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end,
        Defaults.GroupResources.raidBarHeight
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        "Magicka Gradient Start",
        nil,
        function ()
            return unpack(Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart)
        end,
        function (r, g, b, a)
            Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart = { r, g, b, a }
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.RefreshColors()
            end
        end,
        Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        "Magicka Gradient End",
        nil,
        function ()
            return unpack(Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd)
        end,
        function (r, g, b, a)
            Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd = { r, g, b, a }
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.RefreshColors()
            end
        end,
        Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        "Stamina Gradient Start",
        nil,
        function ()
            return unpack(Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart)
        end,
        function (r, g, b, a)
            Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart = { r, g, b, a }
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.RefreshColors()
            end
        end,
        Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        "Stamina Gradient End",
        nil,
        function ()
            return unpack(Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd)
        end,
        function (r, g, b, a)
            Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd = { r, g, b, a }
            if UnitFrames.GroupResources then
                UnitFrames.GroupResources.RefreshColors()
            end
        end,
        Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
        end
    )

    -- Group Combat Stats (LibGroupCombatStats) Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Group Combat Stats"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Enable Combat Stats Display",
        "Display ultimate status, DPS, and HPS for group members using LibGroupCombatStats.",
        function ()
            return Settings.GroupCombatStats.enabled
        end,
        function (value)
            Settings.GroupCombatStats.enabled = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and LibGroupCombatStats)
        end,
        Defaults.GroupCombatStats.enabled,
        "Requires LibGroupCombatStats library. " .. GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show Ultimate Icons",
        "Display ultimate ability icon with charge indicator on group frames.",
        function ()
            return Settings.GroupCombatStats.showUltimate
        end,
        function (value)
            Settings.GroupCombatStats.showUltimate = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
        end,
        Defaults.GroupCombatStats.showUltimate,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show DPS",
        "Display damage per second values on group frames.",
        function ()
            return Settings.GroupCombatStats.showDPS
        end,
        function (value)
            Settings.GroupCombatStats.showDPS = value
            if UnitFrames.GroupCombatStats then
                UnitFrames.GroupCombatStats.RefreshAll()
            end
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
        end,
        Defaults.GroupCombatStats.showDPS,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show HPS",
        "Display healing per second values on group frames.",
        function ()
            return Settings.GroupCombatStats.showHPS
        end,
        function (value)
            Settings.GroupCombatStats.showHPS = value
            if UnitFrames.GroupCombatStats then
                UnitFrames.GroupCombatStats.RefreshAll()
            end
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
        end,
        Defaults.GroupCombatStats.showHPS,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Group Frames (4 player)"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        "Ultimate Icon Size",
        "Set the size of ultimate icons displayed on group frames (4 player).",
        16, 36, 2,
        function ()
            return Settings.GroupCombatStats.ultIconGroupSize
        end,
        function (value)
            Settings.GroupCombatStats.ultIconGroupSize = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
        end,
        Defaults.GroupCombatStats.ultIconGroupSize,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        "Horizontal Offset",
        "Adjust horizontal position of ultimate icons on group frames.",
        -20, 20, 1,
        function ()
            return Settings.GroupCombatStats.ultIconGroupOffsetX
        end,
        function (value)
            Settings.GroupCombatStats.ultIconGroupOffsetX = value
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
        end,
        Defaults.GroupCombatStats.ultIconGroupOffsetX,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        "Vertical Offset",
        "Adjust vertical position of ultimate icons on group frames.",
        -20, 20, 1,
        function ()
            return Settings.GroupCombatStats.ultIconGroupOffsetY
        end,
        function (value)
            Settings.GroupCombatStats.ultIconGroupOffsetY = value
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
        end,
        Defaults.GroupCombatStats.ultIconGroupOffsetY,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Group Potion Cooldowns Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Group Potion Cooldowns"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Enable Group Potion Cooldowns",
        "Display potion cooldown status for group members on custom unit frames (requires LibGroupPotionCooldowns).",
        function ()
            return Settings.GroupPotionCooldowns.enabled
        end,
        function (value)
            Settings.GroupPotionCooldowns.enabled = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.GroupPotionCooldowns.enabled,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show Remaining Time",
        "Display countdown timer on potion icon when on cooldown.",
        function ()
            return Settings.GroupPotionCooldowns.showRemainingTime
        end,
        function (value)
            Settings.GroupPotionCooldowns.showRemainingTime = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
        end,
        Defaults.GroupPotionCooldowns.showRemainingTime,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Group Frames (4 player)"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        "Potion Icon Size",
        "Set the size of potion cooldown icons on group frames (4 player).",
        14, 32, 2,
        function ()
            return Settings.GroupPotionCooldowns.potionIconGroupSize
        end,
        function (value)
            Settings.GroupPotionCooldowns.potionIconGroupSize = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
        end,
        Defaults.GroupPotionCooldowns.potionIconGroupSize,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        "Horizontal Offset",
        "Adjust horizontal position of potion icon on group frames.",
        -20, 20, 1,
        function ()
            return Settings.GroupPotionCooldowns.potionIconGroupOffsetX
        end,
        function (value)
            Settings.GroupPotionCooldowns.potionIconGroupOffsetX = value
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
        end,
        Defaults.GroupPotionCooldowns.potionIconGroupOffsetX,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateIndentedSliderOption(
        "Vertical Offset",
        "Adjust vertical position of potion icon on group frames.",
        -20, 20, 1,
        function ()
            return Settings.GroupPotionCooldowns.potionIconGroupOffsetY
        end,
        function (value)
            Settings.GroupPotionCooldowns.potionIconGroupOffsetY = value
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
        end,
        Defaults.GroupPotionCooldowns.potionIconGroupOffsetY,
        5,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Group Food & Drink Buffs Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        "Group Food & Drink Buffs"
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Enable Group Food & Drink Buffs",
        "Display food and drink buff icons for group members.",
        function ()
            return Settings.GroupFoodDrinkBuff.enabled
        end,
        function (value)
            Settings.GroupFoodDrinkBuff.enabled = value
            if UnitFrames.GroupFoodDrinkBuff then
                UnitFrames.GroupFoodDrinkBuff.OnSettingsChanged()
            end
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.GroupFoodDrinkBuff.enabled,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        "Food/drink buff icons are only displayed on group frames (4-player groups). Raid frames do not have space for these icons."
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show \"No Buff\" Icon",
        "Display an icon when a group member has no food or drink buff active.",
        function ()
            return Settings.GroupFoodDrinkBuff.showNoBuff
        end,
        function (value)
            Settings.GroupFoodDrinkBuff.showNoBuff = value
            if UnitFrames.GroupFoodDrinkBuff then
                UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
            end
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
        end,
        Defaults.GroupFoodDrinkBuff.showNoBuff
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Show Remaining Time",
        "Display countdown timer on food/drink buff icons showing time remaining (hours/minutes/seconds).",
        function ()
            return Settings.GroupFoodDrinkBuff.showRemainingTime
        end,
        function (value)
            Settings.GroupFoodDrinkBuff.showRemainingTime = value
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
        end,
        Defaults.GroupFoodDrinkBuff.showRemainingTime,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        "Use Custom Quality Icons",
        "Use custom quality-based icons (green/blue/purple) instead of actual buff icons. Green = single stat, Blue = dual stat, Purple = triple stat.",
        function ()
            return Settings.GroupFoodDrinkBuff.useCustomIcons
        end,
        function (value)
            Settings.GroupFoodDrinkBuff.useCustomIcons = value
            if UnitFrames.GroupFoodDrinkBuff then
                UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
            end
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
        end,
        Defaults.GroupFoodDrinkBuff.useCustomIcons
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Group Frame Icon Size",
        nil,
        16, 32, 2,
        function ()
            return Settings.GroupFoodDrinkBuff.iconSizeGroup
        end,
        function (value)
            Settings.GroupFoodDrinkBuff.iconSizeGroup = value
            if UnitFrames.GroupFoodDrinkBuff then
                UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
            end
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
        end,
        Defaults.GroupFoodDrinkBuff.iconSizeGroup,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Group Frame Icon Offset X",
        nil,
        -20, 20, 1,
        function ()
            return Settings.GroupFoodDrinkBuff.iconOffsetXGroup
        end,
        function (value)
            Settings.GroupFoodDrinkBuff.iconOffsetXGroup = value
            if UnitFrames.GroupFoodDrinkBuff then
                UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
            end
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
        end,
        Defaults.GroupFoodDrinkBuff.iconOffsetXGroup,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        "Group Frame Icon Offset Y",
        nil,
        -20, 20, 1,
        function ()
            return Settings.GroupFoodDrinkBuff.iconOffsetYGroup
        end,
        function (value)
            Settings.GroupFoodDrinkBuff.iconOffsetYGroup = value
            if UnitFrames.GroupFoodDrinkBuff then
                UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
            end
        end,
        "half",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
        end,
        Defaults.GroupFoodDrinkBuff.iconOffsetYGroup,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    -- Custom Unit Frames (Companion) Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ENABLE),
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ENABLE_TP),
        function ()
            return Settings.CustomFramesCompanion
        end,
        function (value)
            Settings.CustomFramesCompanion = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFramesCompanion,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.CustomFormatCompanion
        end,
        function (combobox, value, item)
            Settings.CustomFormatCompanion = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutCompanion(true)
        end,
        Defaults.CustomFormatCompanion,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_WIDTH),
        nil,
        100, 500, 5,
        function ()
            return Settings.CompanionWidth
        end,
        function (value)
            Settings.CompanionWidth = value
            UnitFrames.CustomFramesApplyLayoutCompanion(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
        end,
        Defaults.CompanionWidth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_HEIGHT),
        nil,
        20, 70, 1,
        function ()
            return Settings.CompanionHeight
        end,
        function (value)
            Settings.CompanionHeight = value
            UnitFrames.CustomFramesApplyLayoutCompanion(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
        end,
        Defaults.CompanionHeight
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_OOCPACITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_OOCPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.CompanionOocAlpha
        end,
        function (value)
            Settings.CompanionOocAlpha = value
            UnitFrames.CustomFramesApplyInCombat()
            UnitFrames.CustomFramesApplyLayoutCompanion(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
        end,
        Defaults.CompanionOocAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ICPACITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ICPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.CompanionIncAlpha
        end,
        function (value)
            Settings.CompanionIncAlpha = value
            UnitFrames.CustomFramesApplyInCombat()
            UnitFrames.CustomFramesApplyLayoutCompanion(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
        end,
        Defaults.CompanionIncAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_NAMECLIP),
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_NAMECLIP_TP),
        0, 200, 1,
        function ()
            return Settings.CompanionNameClip
        end,
        function (value)
            Settings.CompanionNameClip = value
            UnitFrames.CustomFramesApplyLayoutCompanion(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
        end,
        Defaults.CompanionNameClip
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_USE_CLASS_COLOR),
        GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_USE_CLASS_COLOR_TP),
        function ()
            return Settings.CompanionUseClassColor
        end,
        function (value)
            Settings.CompanionUseClassColor = value
            UnitFrames.CustomFramesApplyColors(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
        end,
        Defaults.CompanionUseClassColor
    )

    -- Custom Unit Frames (Pet) Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ENABLE),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ENABLE_TP),
        function ()
            return Settings.CustomFramesPet
        end,
        function (value)
            Settings.CustomFramesPet = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.CustomFramesPet,
        GetString(LUIE_STRING_LAM_RELOADUI_WARNING)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDropdownOption(
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
        GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
        function ()
            local items = {}
            for i, option in ipairs(formatOptions) do
                items[i] = { name = option, data = option }
            end
            return items
        end,
        function ()
            return Settings.CustomFormatPet
        end,
        function (combobox, value, item)
            Settings.CustomFormatPet = value
            UnitFrames.CustomFramesFormatLabels(true)
            UnitFrames.CustomFramesApplyLayoutPet(true)
        end,
        Defaults.CustomFormatPet,
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_WIDTH),
        nil,
        100, 500, 5,
        function ()
            return Settings.PetWidth
        end,
        function (value)
            Settings.PetWidth = value
            UnitFrames.CustomFramesApplyLayoutPet(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
        end,
        Defaults.PetWidth
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_HEIGHT),
        nil,
        20, 70, 1,
        function ()
            return Settings.PetHeight
        end,
        function (value)
            Settings.PetHeight = value
            UnitFrames.CustomFramesApplyLayoutPet(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
        end,
        Defaults.PetHeight
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_OOCPACITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_OOCPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.PetOocAlpha
        end,
        function (value)
            Settings.PetOocAlpha = value
            UnitFrames.CustomFramesApplyInCombat()
            UnitFrames.CustomFramesApplyLayoutPet(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
        end,
        Defaults.PetOocAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ICPACITY),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ICPACITY_TP),
        0, 100, 5,
        function ()
            return Settings.PetIncAlpha
        end,
        function (value)
            Settings.PetIncAlpha = value
            UnitFrames.CustomFramesApplyInCombat()
            UnitFrames.CustomFramesApplyLayoutPet(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
        end,
        Defaults.PetIncAlpha
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateSliderOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_NAMECLIP),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_NAMECLIP_TP),
        0, 200, 1,
        function ()
            return Settings.PetNameClip
        end,
        function (value)
            Settings.PetNameClip = value
            UnitFrames.CustomFramesApplyLayoutPet(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
        end,
        Defaults.PetNameClip
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_USE_CLASS_COLOR),
        GetString(LUIE_STRING_LAM_UF_CFRAMESPET_USE_CLASS_COLOR_TP),
        function ()
            return Settings.PetUseClassColor
        end,
        function (value)
            Settings.PetUseClassColor = value
            UnitFrames.CustomFramesApplyColors(true)
        end,
        "full",
        function ()
            return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
        end,
        Defaults.PetUseClassColor
    )

    -- Pet Whitelist Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateDescriptionOption(
        GetString(LUIE_STRING_LAM_UF_BLACKLIST_DESCRIPT)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_NECROMANCER),
        GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_NECROMANCER_TP),
        function ()
            UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Necromancer)
            if LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
            UnitFrames.CustomPetUpdate()
            -- Refresh dialog if open
            LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PET_WHITELIST")
        end,
        "half",
        nil,
        GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_NECROMANCER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SORCERER),
        GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SORCERER_TP),
        function ()
            UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Sorcerer)
            if LHAS.RefreshAddonSettings then
                LHAS:RefreshAddonSettings()
            end
            UnitFrames.CustomPetUpdate()
            -- Refresh dialog if open
            LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PET_WHITELIST")
        end,
        "half",
        nil,
        GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SORCERER)
    )

    -- Store temp text for adding items
    if not Settings.tempWhitelistText then
        Settings.tempWhitelistText = ""
    end

    -- Add Item edit box
    settingsData[#settingsData + 1] = SettingsAPI.CreateEditboxOption(
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
        function ()
            return Settings.tempWhitelistText or ""
        end,
        function (value)
            Settings.tempWhitelistText = value
        end,
        nil,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    -- Add Item button
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
        GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
        function ()
            local text = Settings.tempWhitelistText or ""
            if text and text ~= "" then
                UnitFrames.AddToCustomList(Settings.whitelist, text)
                Settings.tempWhitelistText = ""
                UnitFrames.CustomPetUpdate()
                -- Refresh the whitelist dialog if it's open
                if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_PET_WHITELIST"] then
                    LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PET_WHITELIST")
                end
                -- Refresh settings to clear the edit box
                if LHAS and LHAS.RefreshAddonSettings then
                    LHAS:RefreshAddonSettings()
                end
            end
        end,
        "half",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    -- Manage Pet Whitelist
    settingsData[#settingsData + 1] = SettingsAPI.CreateButtonOption(
        GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST),
        GetString(LUIE_STRING_LAM_UF_BLACKLIST_DESCRIPT),
        function ()
            if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_PET_WHITELIST"] then
                LUIE.ShowBlacklistDialog("LUIE_MANAGE_PET_WHITELIST")
            end
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST)
    )

    -- Common Options Section
    settingsData[#settingsData + 1] = SettingsAPI.CreateHeaderOption(
        GetString(LUIE_STRING_LAM_UF_COMMON_HEADER)
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_SHORTNUMBERS),
        GetString(LUIE_STRING_LAM_UF_SHORTNUMBERS_TP),
        function ()
            return Settings.ShortenNumbers
        end,
        function (value)
            Settings.ShortenNumbers = value
            UnitFrames.CustomFramesFormatLabels(true)
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.ShortenNumbers
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_COMMON_CAPTIONCOLOR),
        nil,
        function ()
            return unpack(Settings.Target_FontColour)
        end,
        function (r, g, b, a)
            Settings.Target_FontColour = { r, g, b, a }
        end,
        Defaults.Target_FontColour,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_COMMON_NPCFONTCOLOR),
        nil,
        function ()
            return unpack(Settings.Target_FontColour_FriendlyNPC)
        end,
        function (r, g, b, a)
            Settings.Target_FontColour_FriendlyNPC = { r, g, b, a }
        end,
        Defaults.Target_FontColour_FriendlyNPC,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_COMMON_PLAYERFONTCOLOR),
        nil,
        function ()
            return unpack(Settings.Target_FontColour_FriendlyPlayer)
        end,
        function (r, g, b, a)
            Settings.Target_FontColour_FriendlyPlayer = { r, g, b, a }
        end,
        Defaults.Target_FontColour_FriendlyPlayer,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateColorpickerFromTable(
        GetString(LUIE_STRING_LAM_UF_COMMON_HOSTILEFONTCOLOR),
        nil,
        function ()
            return unpack(Settings.Target_FontColour_Hostile)
        end,
        function (r, g, b, a)
            Settings.Target_FontColour_Hostile = { r, g, b, a }
        end,
        Defaults.Target_FontColour_Hostile,
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end
    )

    settingsData[#settingsData + 1] = SettingsAPI.CreateCheckboxOption(
        GetString(LUIE_STRING_LAM_UF_COMMON_RETICLECOLOR),
        GetString(LUIE_STRING_LAM_UF_COMMON_RETICLECOLOR_TP),
        function ()
            return Settings.ApplyReticle
        end,
        function (value)
            Settings.ApplyReticle = value
        end,
        "full",
        function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
        Defaults.ApplyReticle
    )

    -- Add all settings to the panel
    panel:AddSettings(settingsData)
end
