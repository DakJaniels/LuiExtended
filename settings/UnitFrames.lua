-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local FontsList = {}
local LMP = LibMediaProvider
if LMP then
    -- Add LUIE fonts first
    for f, _ in pairs(LUIE.Fonts) do
        table.insert(FontsList, f)
    end
    -- Add LMP fonts
    for _, font in ipairs(LMP:List(LMP.MediaType.FONT)) do
        -- Only add if not already in list
        if not LUIE.Fonts[font] then
            table.insert(FontsList, font)
        end
    end
end

-- Get sounds from LibMediaProvider
local SoundsList = {}
if LMP then
    -- Add LUIE sounds first
    for sound, _ in pairs(LUIE.Sounds) do
        table.insert(SoundsList, sound)
    end
    -- Add LMP sounds
    for _, sound in ipairs(LMP:List(LMP.MediaType.SOUND)) do
        -- Only add if not already in list
        if not LUIE.Sounds[sound] then
            table.insert(SoundsList, sound)
        end
    end
end

-- Get statusbar textures from LibMediaProvider
local StatusbarTexturesList = {}
if LMP then
    -- Add LUIE textures first
    for key, _ in pairs(LUIE.StatusbarTextures) do
        table.insert(StatusbarTexturesList, key)
    end
    -- Add LMP statusbar textures
    for _, texture in ipairs(LMP:List(LMP.MediaType.STATUSBAR)) do
        -- Only add if not already in list
        if not LUIE.StatusbarTextures[texture] then
            table.insert(StatusbarTexturesList, texture)
        end
    end
end

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local PetNames = LUIE.Data.PetNames
local pairs = pairs
local zo_strformat = zo_strformat
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

local resolutionOptions =
{
    GetString(LUIE_STRING_LAM_UF_RESOLUTION_1080P),
    GetString(LUIE_STRING_LAM_UF_RESOLUTION_1440P),
    GetString(LUIE_STRING_LAM_UF_RESOLUTION_4K)
}
local resolutionOptionsKeys =
{
    [GetString(LUIE_STRING_LAM_UF_RESOLUTION_1080P)] = 1,
    [GetString(LUIE_STRING_LAM_UF_RESOLUTION_1440P)] = 2,
    [GetString(LUIE_STRING_LAM_UF_RESOLUTION_4K)] = 3
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

function UnitFrames.CreateSettings()
    -- Load LibAddonMenu
    local LAM = LibAddonMenu2
    if LAM == nil then
        return
    end

    local Defaults = UnitFrames.Defaults
    --- @class (partial) LUIE_UnitFrames_SV
    local Settings = UnitFrames.SV

    -- Load Dialog Buttons
    loadDialogButtons()

    local panelDataUnitFrames =
    {
        type = "panel",
        name = zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_UF)),
        displayName = zo_strformat("<<1>> <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_UF)),
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luiuf",
        registerForRefresh = true,
        registerForDefaults = true,
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

    -- Resolution Options
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "dropdown",
        name = GetString(LUIE_STRING_LAM_UF_RESOLUTION),
        tooltip = GetString(LUIE_STRING_LAM_UF_RESOLUTION_TP),
        choices = resolutionOptions,
        getFunc = function ()
            return resolutionOptions[Settings.ResolutionOptions]
        end,
        setFunc = function (value)
            Settings.ResolutionOptions = resolutionOptionsKeys[value]
            UnitFrames.CustomFramesSetPositions()
        end,
        width = "full",
        default = Defaults.ResolutionOptions,
        disabled = function ()
            return not LUIE.SV.UnitFrames_Enabled
        end,
    }

    -- Custom Unit Frames Unlock
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMES_UNLOCK),
        tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_UNLOCK_TP),
        getFunc = function ()
            return g_FramesMovingEnabled
        end,
        setFunc = function (value)
            g_FramesMovingEnabled = value
            UnitFrames.CustomFramesSetMovingState(value)
        end,
        width = "half",
        default = false,
        resetFunc = function ()
            UnitFrames.CustomFramesResetPosition(false)
        end,
    }

    -- Grid Snap Settings for Unit Frames
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "checkbox",
        name = "Enable Grid Snap (Unit Frames)",
        tooltip = "Enable snapping unit frames to a grid when moving them",
        getFunc = function ()
            return LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGridUnitFrames
        end,
        setFunc = function (value)
            LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGridUnitFrames = value
        end,
        width = "half",
        default = false,
    }

    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "slider",
        name = "Grid Size (Unit Frames)",
        tooltip = "Set the size of the grid for snapping unit frames",
        min = 5,
        max = 100,
        step = 5,
        getFunc = function ()
            return LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGridUnitFramesSize or 15
        end,
        setFunc = function (value)
            LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGridUnitFramesSize = value
        end,
        width = "half",
        default = 15,
        disabled = function ()
            return not LUIESV.Default[GetDisplayName()]["$AccountWide"].snapToGridUnitFrames
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
                choices = formatOptions,
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
            {
                -- DefaultFrames Font
                type = "dropdown",
                scrollable = true,
                name = GetString(LUIE_STRING_LAM_FONT),
                tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_TP),
                choices = FontsList,
                sort = "name-up",
                getFunc = function ()
                    return Settings.DefaultFontFace
                end,
                setFunc = function (var)
                    Settings.DefaultFontFace = var
                    UnitFrames.DefaultFramesApplyFont()
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.DefaultFontFace,
            },
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
            {
                -- DefaultFrames Font Style
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_FONT_STYLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_STYLE_TP),
                choices =
                {
                    "|cFFFFFF" .. GetString(LUIE_FONT_STYLE_NORMAL) .. "|r",
                    "|c888888" .. GetString(LUIE_FONT_STYLE_SHADOW) .. "|r",
                    "|cEEEEEE" .. GetString(LUIE_FONT_STYLE_OUTLINE) .. "|r",
                    "|cFFFFFF" .. GetString(LUIE_FONT_STYLE_THICK_OUTLINE) .. "|r",
                    "|c777777" .. GetString(LUIE_FONT_STYLE_SOFT_SHADOW_THIN) .. "|r",
                    "|c666666" .. GetString(LUIE_FONT_STYLE_SOFT_SHADOW_THICK) .. "|r",
                },
                choicesValues =
                {
                    GetString(LUIE_FONT_STYLE_VALUE_NORMAL),
                    GetString(LUIE_FONT_STYLE_VALUE_SHADOW),
                    GetString(LUIE_FONT_STYLE_VALUE_OUTLINE),
                    GetString(LUIE_FONT_STYLE_VALUE_THICK_OUTLINE),
                    GetString(LUIE_FONT_STYLE_VALUE_SOFT_SHADOW_THIN),
                    GetString(LUIE_FONT_STYLE_VALUE_SOFT_SHADOW_THICK),
                },
                sort = "name-up",
                getFunc = function ()
                    return Settings.DefaultFontStyle
                end,
                setFunc = function (var)
                    Settings.DefaultFontStyle = var
                    UnitFrames.DefaultFramesApplyFont()
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.DefaultFontStyle,
            },
            {
                -- Color of text labels
                type = "colorpicker",
                name = GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL_COLOR),
                getFunc = function ()
                    return unpack(Settings.DefaultTextColour)
                end,
                setFunc = function (r, g, b, a)
                    Settings.DefaultTextColour = { r, g, b }
                    UnitFrames.DefaultFramesApplyColor()
                end,
                width = "full",
                default =
                {
                    r = Defaults.DefaultTextColour[1],
                    g = Defaults.DefaultTextColour[2],
                    b = Defaults.DefaultTextColour[3],
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
                -- Custom Unit Frames Font
                type = "dropdown",
                scrollable = true,
                name = GetString(LUIE_STRING_LAM_FONT),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TP),
                choices = FontsList,
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomFontFace
                end,
                setFunc = function (var)
                    Settings.CustomFontFace = var
                    UnitFrames.CustomFramesApplyFont()
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFontFace,
            },
            {
                -- Custom Unit Frames Font size labels
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_LABELS_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function ()
                    return Settings.CustomFontOther
                end,
                setFunc = function (value)
                    Settings.CustomFontOther = value
                    UnitFrames.CustomFramesApplyFont()
                end,
                width = "half",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFontOther,
            },
            {
                -- Custom Unit Frames Font size bars
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_SIZE_BARS_TP),
                min = 10,
                max = 30,
                step = 1,
                getFunc = function ()
                    return Settings.CustomFontBars
                end,
                setFunc = function (value)
                    Settings.CustomFontBars = value
                    UnitFrames.CustomFramesApplyFont()
                end,
                width = "half",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFontBars,
            },
            {
                -- Custom Unit Frames Font style
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_FONT_STYLE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_STYLE_TP),
                choices =
                {
                    "|cFFFFFF" .. GetString(LUIE_FONT_STYLE_NORMAL) .. "|r",
                    "|c888888" .. GetString(LUIE_FONT_STYLE_SHADOW) .. "|r",
                    "|cEEEEEE" .. GetString(LUIE_FONT_STYLE_OUTLINE) .. "|r",
                    "|cFFFFFF" .. GetString(LUIE_FONT_STYLE_THICK_OUTLINE) .. "|r",
                    "|c777777" .. GetString(LUIE_FONT_STYLE_SOFT_SHADOW_THIN) .. "|r",
                    "|c666666" .. GetString(LUIE_FONT_STYLE_SOFT_SHADOW_THICK) .. "|r",
                },
                choicesValues =
                {
                    GetString(LUIE_FONT_STYLE_VALUE_NORMAL),
                    GetString(LUIE_FONT_STYLE_VALUE_SHADOW),
                    GetString(LUIE_FONT_STYLE_VALUE_OUTLINE),
                    GetString(LUIE_FONT_STYLE_VALUE_THICK_OUTLINE),
                    GetString(LUIE_FONT_STYLE_VALUE_SOFT_SHADOW_THIN),
                    GetString(LUIE_FONT_STYLE_VALUE_SOFT_SHADOW_THICK),
                },
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomFontStyle
                end,
                setFunc = function (var)
                    Settings.CustomFontStyle = var
                    UnitFrames.CustomFramesApplyFont()
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFontStyle,
            },
            {
                -- Custom Unit Frames Texture
                type = "dropdown",
                scrollable = true,
                name = GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_TEXTURE_TP),
                choices = StatusbarTexturesList,
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomTexture
                end,
                setFunc = function (var)
                    Settings.CustomTexture = var
                    UnitFrames.CustomFramesApplyTexture()
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomTexture,
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                    UnitFrames.CustomFramesApplyLayoutGroup()
                end,
                width = "full",
                default = Defaults.CustomShieldBarHeight,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and not Settings.CustomShieldBarFull)
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
                    UnitFrames.CustomFramesApplyColors(true)
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
                name = "Format unitframe names with target marker",
                tooltip = "Format unitframe names with target marker",
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
                    Settings.CustomColourHealth = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourHealth[1],
                    g = Defaults.CustomColourHealth[2],
                    b = Defaults.CustomColourHealth[3],
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
                    Settings.CustomColourShield = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourShield[1],
                    g = Defaults.CustomColourShield[2],
                    b = Defaults.CustomColourShield[3],
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
                    Settings.CustomColourTrauma = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourTrauma[1],
                    g = Defaults.CustomColourTrauma[2],
                    b = Defaults.CustomColourTrauma[3],
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
                    Settings.CustomColourMagicka = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourMagicka[1],
                    g = Defaults.CustomColourMagicka[2],
                    b = Defaults.CustomColourMagicka[3],
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
                    Settings.CustomColourStamina = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourStamina[1],
                    g = Defaults.CustomColourStamina[2],
                    b = Defaults.CustomColourStamina[3],
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
                    Settings.CustomColourInvulnerable = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourInvulnerable[1],
                    g = Defaults.CustomColourInvulnerable[2],
                    b = Defaults.CustomColourInvulnerable[3],
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
                    Settings.CustomColourDPS = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourDPS[1],
                    g = Defaults.CustomColourDPS[2],
                    b = Defaults.CustomColourDPS[3],
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
                    Settings.CustomColourHealer = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourHealer[1],
                    g = Defaults.CustomColourHealer[2],
                    b = Defaults.CustomColourHealer[3],
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
                    Settings.CustomColourTank = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourTank[1],
                    g = Defaults.CustomColourTank[2],
                    b = Defaults.CustomColourTank[3],
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
                    Settings.CustomColourDragonknight = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourDragonknight[1],
                    g = Defaults.CustomColourDragonknight[2],
                    b = Defaults.CustomColourDragonknight[3],
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
                    Settings.CustomColourNightblade = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourNightblade[1],
                    g = Defaults.CustomColourNightblade[2],
                    b = Defaults.CustomColourNightblade[3],
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
                    Settings.CustomColourSorcerer = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourSorcerer[1],
                    g = Defaults.CustomColourSorcerer[2],
                    b = Defaults.CustomColourSorcerer[3],
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
                    Settings.CustomColourTemplar = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourTemplar[1],
                    g = Defaults.CustomColourTemplar[2],
                    b = Defaults.CustomColourTemplar[3],
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
                    Settings.CustomColourWarden = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourWarden[1],
                    g = Defaults.CustomColourWarden[2],
                    b = Defaults.CustomColourWarden[3],
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
                    Settings.CustomColourNecromancer = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourNecromancer[1],
                    g = Defaults.CustomColourNecromancer[2],
                    b = Defaults.CustomColourNecromancer[3],
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
                    Settings.CustomColourArcanist = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourArcanist[1],
                    g = Defaults.CustomColourArcanist[2],
                    b = Defaults.CustomColourArcanist[3],
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
                    Settings.CustomColourPlayer = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourPlayer[1],
                    g = Defaults.CustomColourPlayer[2],
                    b = Defaults.CustomColourPlayer[3],
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
                    Settings.CustomColourFriendly = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourFriendly[1],
                    g = Defaults.CustomColourFriendly[2],
                    b = Defaults.CustomColourFriendly[3],
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
                    Settings.CustomColourCompanion = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourCompanion[1],
                    g = Defaults.CustomColourCompanion[2],
                    b = Defaults.CustomColourCompanion[3],
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
                    Settings.CustomColourHostile = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourHostile[1],
                    g = Defaults.CustomColourHostile[2],
                    b = Defaults.CustomColourHostile[3],
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
                    Settings.CustomColourNeutral = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourNeutral[1],
                    g = Defaults.CustomColourNeutral[2],
                    b = Defaults.CustomColourNeutral[3],
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
                    Settings.CustomColourGuard = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourGuard[1],
                    g = Defaults.CustomColourGuard[2],
                    b = Defaults.CustomColourGuard[3],
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
                    Settings.CustomColourPet = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourPet[1],
                    g = Defaults.CustomColourPet[2],
                    b = Defaults.CustomColourPet[3],
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
                    Settings.CustomColourCompanionFrame = { r, g, b }
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default =
                {
                    r = Defaults.CustomColourCompanionFrame[1],
                    g = Defaults.CustomColourCompanionFrame[2],
                    b = Defaults.CustomColourCompanionFrame[3],
                },
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
        },
    }

    -- Unit Frames - Custom Unit Frames (Player & Target) Options Submenu
    optionsDataUnitFrames[#optionsDataUnitFrames + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_HEADER),
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
                    UnitFrames.CustomFramesReloadControlsMenu(true)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = nameDisplayOptions[2],
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
                    UnitFrames.CustomFramesReloadControlsMenu(true)
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
                choices = formatOptions,
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomFormatOnePT
                end,
                setFunc = function (var)
                    Settings.CustomFormatOnePT = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFormatOnePT,
            },
            {
                -- Custom Unit Frames format right label
                type = "dropdown",
                name = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
                tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
                choices = formatOptions,
                sort = "name-up",
                getFunc = function ()
                    return Settings.CustomFormatTwoPT
                end,
                setFunc = function (var)
                    Settings.CustomFormatTwoPT = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                disabled = function ()
                    return not LUIE.SV.UnitFrames_Enabled
                end,
                default = Defaults.CustomFormatTwoPT,
            },
            {
                -- Player Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_WIDTH),
                min = 200,
                max = 500,
                step = 5,
                getFunc = function ()
                    return Settings.PlayerBarWidth
                end,
                setFunc = function (value)
                    Settings.PlayerBarWidth = value
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyInCombat()
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.PlayerOocAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
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
                    UnitFrames.CustomFramesApplyInCombat()
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.PlayerIncAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
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
                    UnitFrames.CustomFramesApplyInCombat()
                end,
                width = "full",
                default = Defaults.HideBuffsPlayerOoc,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                -- Target Bars Width
                type = "slider",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_WIDTH),
                min = 200,
                max = 500,
                step = 5,
                getFunc = function ()
                    return Settings.TargetBarWidth
                end,
                setFunc = function (value)
                    Settings.TargetBarWidth = value
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyInCombat()
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.TargetOocAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
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
                    UnitFrames.CustomFramesApplyInCombat()
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.TargetIncAlpha,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
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
                    UnitFrames.CustomFramesApplyInCombat()
                end,
                width = "full",
                default = Defaults.HideBuffsTargetOoc,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.TargetEnableClass,
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.TargetEnableTitle,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.TargetEnableRank,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Prioritize Title or AvA Rank
                type = "dropdown",
                name = zo_strformat("\t\t\t\t\t<<1>>", GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TITLE_PRIORITY)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TITLE_PRIORITY_TP),
                choices = { "AVA Rank", "Title" },
                getFunc = function ()
                    return Settings.TargetTitlePriority
                end,
                setFunc = function (value)
                    Settings.TargetTitlePriority = value
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.TargetTitlePriority,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.TargetEnableRank and Settings.TargetEnableTitle)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
                end,
                width = "full",
                default = Defaults.TargetEnableRankIcon,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
                end,
            },
            {
                -- Display Armor stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_PT)),
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
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
                end,
            },
            {
                -- Display Power stat change
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_PT)),
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
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
                end,
            },
            {
                -- Custom Unit Frames Display HoT / DoT Animations
                type = "checkbox",
                name = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_PT)),
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
                    return not LUIE.SV.UnitFrames_Enabled
                end,
            },
            {
                -- Treat Missing Power as In-Combat
                type = "checkbox",
                name = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT_TP),
                getFunc = function ()
                    return Settings.CustomOocAlphaPower
                end,
                setFunc = function (value)
                    Settings.CustomOocAlphaPower = value
                    UnitFrames.CustomFramesApplyInCombat()
                end,
                width = "full",
                default = Defaults.CustomOocAlphaPower,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomFramesPlayer or Settings.CustomFramesTarget))
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
                default = Defaults.BarAlignPlayerHealth,
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
                default = Defaults.BarAlignPlayerMagicka,
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
                default = Defaults.BarAlignPlayerStamina,
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
                default = Defaults.BarAlignTarget,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                choices = formatOptions,
                getFunc = function ()
                    return Settings.CustomFormatCenterLabel
                end,
                setFunc = function (var)
                    Settings.CustomFormatCenterLabel = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                default = Defaults.PlayerFrameOptions,
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                end,
                width = "full",
                default = Defaults.HideBarHealth,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
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
                end,
                width = "full",
                default = Defaults.HideBarMagicka,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
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
                end,
                width = "full",
                default = Defaults.HideBarStamina,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
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
                end,
                width = "full",
                default = Defaults.ReverseResourceBars,
                warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
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
                    UnitFrames.CustomFramesReloadControlsMenu(false, true, true)
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
                choices = formatOptions,
                getFunc = function ()
                    return Settings.CustomFormatOneGroup
                end,
                setFunc = function (var)
                    Settings.CustomFormatOneGroup = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutGroup(true)
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
                choices = formatOptions,
                getFunc = function ()
                    return Settings.CustomFormatTwoGroup
                end,
                setFunc = function (var)
                    Settings.CustomFormatTwoGroup = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutGroup(true)
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
                    UnitFrames.CustomFramesApplyLayoutGroup(true)
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
                    UnitFrames.CustomFramesApplyLayoutGroup(true)
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
                    UnitFrames.CustomFramesApplyLayoutGroup(true)
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
                    UnitFrames.CustomFramesApplyLayoutGroup(true)
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
                    UnitFrames.CustomFramesApplyLayoutGroup(true)
                    UnitFrames.CustomFramesApplyColors(true)
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
                    UnitFrames.CustomFramesApplyLayoutGroup(true)
                end,
                width = "full",
                default = Defaults.RoleIconSmallGroup,
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
                    UnitFrames.CustomFramesApplyColors(true)
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
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default = Defaults.ColorRoleGroup,
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
                    UnitFrames.CustomFramesReloadControlsMenu(false, true, true)
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
                choices = formatOptions,
                getFunc = function ()
                    return Settings.CustomFormatRaid
                end,
                setFunc = function (var)
                    Settings.CustomFormatRaid = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
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
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
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
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
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
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
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
                choices = { "1 x 12", "2 x 6", "3 x 4", "6 x 2" },
                -- sort = "name-up",
                getFunc = function ()
                    return Settings.RaidLayout
                end,
                setFunc = function (var)
                    Settings.RaidLayout = var
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
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
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
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
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
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
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
                end,
                width = "full",
                default = Defaults.RaidIconOptions,
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
                    UnitFrames.CustomFramesApplyColors(true)
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
                    UnitFrames.CustomFramesApplyColors(true)
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
                    UnitFrames.CustomFramesApplyLayoutRaid(true)
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
                choices = formatOptions,
                getFunc = function ()
                    return Settings.CustomFormatCompanion
                end,
                setFunc = function (var)
                    Settings.CustomFormatCompanion = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutCompanion(true)
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
                    UnitFrames.CustomFramesApplyLayoutCompanion(true)
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
                    UnitFrames.CustomFramesApplyLayoutCompanion(true)
                end,
                width = "full",
                default = Defaults.CompanionHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
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
                    UnitFrames.CustomFramesApplyInCombat()
                    UnitFrames.CustomFramesApplyLayoutCompanion(true)
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
                    UnitFrames.CustomFramesApplyInCombat()
                    UnitFrames.CustomFramesApplyLayoutCompanion(true)
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
                    UnitFrames.CustomFramesApplyLayoutCompanion(true)
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
                    UnitFrames.CustomFramesApplyColors(true)
                end,
                width = "full",
                default = Defaults.CompanionUseClassColor,
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
                choices = formatOptions,
                getFunc = function ()
                    return Settings.CustomFormatPet
                end,
                setFunc = function (var)
                    Settings.CustomFormatPet = var
                    UnitFrames.CustomFramesFormatLabels(true)
                    UnitFrames.CustomFramesApplyLayoutPet(true)
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
                    UnitFrames.CustomFramesApplyLayoutPet(true)
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
                    UnitFrames.CustomFramesApplyLayoutPet(true)
                end,
                width = "full",
                default = Defaults.PetHeight,
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
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
                    UnitFrames.CustomFramesApplyInCombat()
                    UnitFrames.CustomFramesApplyLayoutPet(true)
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
                    UnitFrames.CustomFramesApplyInCombat()
                    UnitFrames.CustomFramesApplyLayoutPet(true)
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
                    UnitFrames.CustomFramesApplyLayoutPet(true)
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
                    UnitFrames.CustomFramesApplyColors(true)
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
                scrollable = true,
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
                choices = formatOptions,
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
                    UnitFrames.CustomFramesApplyLayoutBosses()
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
                    UnitFrames.CustomFramesApplyLayoutBosses()
                end,
                width = "full",
                default = Defaults.BossBarHeight,
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
                    UnitFrames.CustomFramesApplyInCombat()
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
                    UnitFrames.CustomFramesApplyInCombat()
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    UnitFrames.CustomFramesApplyLayoutPlayer(true)
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
                    Settings.Target_FontColour = { r, g, b }
                end,
                width = "full",
                default =
                {
                    r = Defaults.Target_FontColour[1],
                    g = Defaults.Target_FontColour[2],
                    b = Defaults.Target_FontColour[3],
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
                    Settings.Target_FontColour_FriendlyNPC = { r, g, b }
                end,
                width = "full",
                default =
                {
                    r = Defaults.Target_FontColour_FriendlyNPC[1],
                    g = Defaults.Target_FontColour_FriendlyNPC[2],
                    b = Defaults.Target_FontColour_FriendlyNPC[3],
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
                    Settings.Target_FontColour_FriendlyPlayer = { r, g, b }
                end,
                width = "full",
                default =
                {
                    r = Defaults.Target_FontColour_FriendlyPlayer[1],
                    g = Defaults.Target_FontColour_FriendlyPlayer[2],
                    b = Defaults.Target_FontColour_FriendlyPlayer[3],
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
                    Settings.Target_FontColour_Hostile = { r, g, b }
                end,
                width = "full",
                default =
                {
                    r = Defaults.Target_FontColour_Hostile[1],
                    g = Defaults.Target_FontColour_Hostile[2],
                    b = Defaults.Target_FontColour_Hostile[3],
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
                    Settings.ReticleColour_Interact = { r, g, b }
                end,
                width = "full",
                default =
                {
                    r = Defaults.ReticleColour_Interact[1],
                    g = Defaults.ReticleColour_Interact[2],
                    b = Defaults.ReticleColour_Interact[3],
                },
                disabled = function ()
                    return not (LUIE.SV.UnitFrames_Enabled and Settings.ReticleColourByReaction)
                end,
            },
        },
    }

    -- Register the settings panel
    if LUIE.SV.UnitFrames_Enabled then
        LAM:RegisterAddonPanel(LUIE.name .. "UnitFramesOptions", panelDataUnitFrames)
        LAM:RegisterOptionControls(LUIE.name .. "UnitFramesOptions", optionsDataUnitFrames)
    end
end
