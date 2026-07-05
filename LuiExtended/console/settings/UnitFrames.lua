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

local function ApplyCustomPlayerHideBarLayout()
    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
    UnitFrames.CustomFramesSetupAlternative()
end


-- LHAS items: localized `name`, canonical English `data` (matches SV after MigrateCanonicalFormatStrings).
local formatDropdownItems = UnitFrames.GetFormatOptionLHASItems()

local function formatDropdownGetData(storedValue)
    return SettingsAPI:LHASDropdownGetData(UnitFrames.NormalizeFormatOption(storedValue))
end

local defaultFramesFontStyleItems = {}
for styleIndex = 1, #LUIE.FONT_STYLE_CHOICES do
    defaultFramesFontStyleItems[styleIndex] =
    {
        name = LUIE.FONT_STYLE_CHOICES[styleIndex],
        data = LUIE.FONT_STYLE_CHOICES_VALUES[styleIndex],
    }
end

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

    local function buildDefaultFrameDropdownItems(frameKey)
        local choices = UnitFrames.GetDefaultFramesOptions(frameKey)
        local items = {}
        for choiceIndex = 1, #choices do
            local choice = choices[choiceIndex]
            items[choiceIndex] = { name = choice, data = choice }
        end
        return items
    end

    local defaultFramePlayerItems = buildDefaultFrameDropdownItems("Player")
    local defaultFrameTargetItems = buildDefaultFrameDropdownItems("Target")
    local defaultFrameGroupItems = buildDefaultFrameDropdownItems("Group")
    local defaultFrameBossItems = buildDefaultFrameDropdownItems("Boss")

    -- Register the settings panel
    if not LUIE.SV.UnitFrames_Enabled then
        return
    end

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
    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_UF),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset all frame positions when defaults is clicked
                                        UnitFrames.CustomFramesResetPosition(false)
                                    end
                                })

    -- Collect initial settings for main menu
    local initialSettings = {}

    -- Unit Frames module description
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_UF_DESCRIPTION),
    }

    -- Store common settings to add to CommonOptions submenu later
    local commonGlobalSettings =
    {
        -- ReloadUI Button
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RELOADUI),
            tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
            clickHandler = function ()
                SettingsAPI:ReloadUIWithPendingClear()
            end,
            buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        },
        SettingsAPI:ConsoleFontDeferLabelSetting(),
    }

    local sectionGroups = {}

    -- Helper function to build section settings
    local function buildSectionSettings(sectionName, settingsBuilder)
        local sectionSettings = {}
        settingsBuilder(sectionSettings)
        sectionGroups[sectionName] = sectionSettings
    end

    -- Build Default Unit Frames Options Section
    buildSectionSettings("DefaultFrames", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_DEFAULT),
            canSelect = false,
        }

        settings[#settings + 1] = SettingsAPI:ConsoleFontDeferLabelSetting()

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_PLAYER),
            items = defaultFramePlayerItems,
            getFunction = function ()
                return { data = UnitFrames.GetDefaultFramesSetting("Player") }
            end,
            setFunction = function (combobox, value, item)
                UnitFrames.SetDefaultFramesSetting("Player", item.data or item.name or value)
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = SettingsAPI:LHASDropdownGetData(UnitFrames.GetDefaultFramesSetting("Player", true)),
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_TARGET),
            items = defaultFrameTargetItems,
            getFunction = function ()
                return { data = UnitFrames.GetDefaultFramesSetting("Target") }
            end,
            setFunction = function (combobox, value, item)
                UnitFrames.SetDefaultFramesSetting("Target", item.data or item.name or value)
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = SettingsAPI:LHASDropdownGetData(UnitFrames.GetDefaultFramesSetting("Target", true)),
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_GROUPSMALL),
            items = defaultFrameGroupItems,
            getFunction = function ()
                return { data = UnitFrames.GetDefaultFramesSetting("Group") }
            end,
            setFunction = function (combobox, value, item)
                UnitFrames.SetDefaultFramesSetting("Group", item.data or item.name or value)
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = SettingsAPI:LHASDropdownGetData(UnitFrames.GetDefaultFramesSetting("Group", true)),
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_BOSS_COMPASS),
            items = defaultFrameBossItems,
            getFunction = function ()
                return { data = UnitFrames.GetDefaultFramesSetting("Boss") }
            end,
            setFunction = function (combobox, value, item)
                UnitFrames.SetDefaultFramesSetting("Boss", value)
                UnitFrames.ResetCompassBarMenu()
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = SettingsAPI:LHASDropdownGetData(UnitFrames.GetDefaultFramesSetting("Boss", true)),
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_REPOSIT),
            tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_REPOSIT_TP),
            getFunction = function ()
                return Settings.RepositionFrames
            end,
            setFunction = function (value)
                Settings.RepositionFrames = value
                UnitFrames.RepositionDefaultFrames()
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.RepositionFrames,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_VERT),
            tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_VERT_TP),
            min = -150,
            max = 300,
            step = 5,
            getFunction = function ()
                return Settings.RepositionFramesAdjust
            end,
            setFunction = function (value)
                Settings.RepositionFramesAdjust = value
                UnitFrames.RepositionDefaultFrames()
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.RepositionFramesAdjust,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_OOCTRANS),
            tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_OOCTRANS_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.DefaultOocTransparency
            end,
            setFunction = function (value)
                UnitFrames.SetDefaultFramesTransparency(value, nil)
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.DefaultOocTransparency,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_INCTRANS),
            tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_INCTRANS_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.DefaultIncTransparency
            end,
            setFunction = function (value)
                UnitFrames.SetDefaultFramesTransparency(nil, value)
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.DefaultIncTransparency,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.Format)
            end,
            setFunction = function (combobox, value, item)
                Settings.Format = item.data or item.name or value
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.Format),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_TP),
            items = SettingsAPI:GetFontsList(),
            getFunction = function ()
                return { data = Settings.DefaultFontFace }
            end,
            setFunction = function (combobox, value, item)
                Settings.DefaultFontFace = item.data or item.name or value
                SettingsAPI:MarkUnitFramesFontDeferred("default")
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.DefaultFontFace),
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_SIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            getFunction = function ()
                return Settings.DefaultFontSize
            end,
            setFunction = function (value)
                Settings.DefaultFontSize = value
                SettingsAPI:MarkUnitFramesFontDeferred("default")
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.DefaultFontSize,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_DFRAMES_FONT_STYLE_TP),
            items = defaultFramesFontStyleItems,
            getFunction = function ()
                return { data = Settings.DefaultFontStyle }
            end,
            setFunction = function (combobox, value, item)
                Settings.DefaultFontStyle = item.data or item.name or value
                SettingsAPI:MarkUnitFramesFontDeferred("default")
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.DefaultFontStyle),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_DFRAMES_LABEL_COLOR),
            getFunction = function ()
                return Settings.DefaultTextColour[1], Settings.DefaultTextColour[2], Settings.DefaultTextColour[3], Settings.DefaultTextColour[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.DefaultTextColour = { r, g, b, a }
                UnitFrames.DefaultFramesApplyColor()
            end,
            default = Defaults.DefaultTextColour,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_TARGET_COLOR_REACTION),
            tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_COLOR_REACTION_TP),
            getFunction = function ()
                return Settings.TargetColourByReaction
            end,
            setFunction = UnitFrames.TargetColorByReaction,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.TargetColourByReaction,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_TARGET_ICON_CLASS),
            tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_ICON_CLASS_TP),
            getFunction = function ()
                return Settings.TargetShowClass
            end,
            setFunction = function (value)
                Settings.TargetShowClass = value
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.TargetShowClass,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_TARGET_ICON_GFI),
            tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_ICON_GFI_TP),
            getFunction = function ()
                return Settings.TargetShowFriend
            end,
            setFunction = function (value)
                Settings.TargetShowFriend = value
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.TargetShowFriend,
        }
    end)

    -- Build Custom Unit Frames Options Section
    buildSectionSettings("CustomFrames", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_CUSTOM_GLOBAL),
            canSelect = false,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_TP),
            getFunction = function ()
                return Settings.CustomShieldBarSeparate
            end,
            setFunction = function (value)
                Settings.CustomShieldBarSeparate = value
                if value then
                    Settings.CustomShieldBarFull = false
                end
                UnitFrames.OnCustomShieldBarSettingsChanged(true)
                SettingsAPI:RefreshPanel(panel)
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomShieldBarSeparate,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_HEIGHT),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_SEPARATE_HEIGHT_TP),
            min = 4,
            max = 12,
            step = 1,
            getFunction = function ()
                return Settings.CustomShieldBarHeight
            end,
            setFunction = function (value)
                Settings.CustomShieldBarHeight = value
                UnitFrames.OnCustomShieldBarSettingsChanged(true)
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and (Settings.CustomShieldBarSeparate or not Settings.CustomShieldBarFull))
            end,
            default = Defaults.CustomShieldBarHeight,
            decimals = 0,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_OVERLAY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_OVERLAY_TP),
            getFunction = function ()
                return Settings.CustomShieldBarFull
            end,
            setFunction = function (value)
                Settings.CustomShieldBarFull = value
                UnitFrames.OnCustomShieldBarSettingsChanged(false)
                SettingsAPI:RefreshPanel(panel)
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and not Settings.CustomShieldBarSeparate)
            end,
            default = Defaults.CustomShieldBarFull,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_ALPHA),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SHIELD_ALPHA_TP),
            min = 0,
            max = 100,
            step = 1,
            getFunction = function ()
                return Settings.ShieldAlpha
            end,
            setFunction = function (value)
                Settings.ShieldAlpha = value
                UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and not Settings.CustomShieldBarSeparate)
            end,
            default = Defaults.ShieldAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_SMOOTHBARTRANS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_SMOOTHBARTRANS_TP),
            getFunction = function ()
                return Settings.CustomSmoothBar
            end,
            setFunction = function (value)
                Settings.CustomSmoothBar = value
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomSmoothBar,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Format unitFrame names with target marker",
            tooltip = "Format unitFrame names with target marker",
            getFunction = function ()
                return Settings.CustomTargetMarker
            end,
            setFunction = function (value)
                Settings.CustomTargetMarker = value
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomTargetMarker,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Target Frame Quick Hide Dead Enemy/Neutral",
            tooltip = "Target Frame Quick Hide Dead Enemy/Neutral",
            getFunction = function ()
                return Settings.QuickHideDead
            end,
            setFunction = function (value)
                Settings.QuickHideDead = value
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.QuickHideDead,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_QUICKHIDE_UNITMONSTER),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_QUICKHIDE_UNITMONSTER_TP),
            getFunction = function ()
                return Settings.QuickHideDeadUseUnitMonster
            end,
            setFunction = function (value)
                Settings.QuickHideDeadUseUnitMonster = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.QuickHideDead)
            end,
            default = Defaults.QuickHideDeadUseUnitMonster,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_HIDE_PLAYER_FRAME_DEATH),
            tooltip = GetString(LUIE_STRING_LAM_UF_HIDE_PLAYER_FRAME_DEATH_TP),
            getFunction = function ()
                return Settings.HidePlayerFrameOnDeath
            end,
            setFunction = function (value)
                Settings.HidePlayerFrameOnDeath = value
                UnitFrames.UpdatePlayerFrameDeathVisibility()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.HidePlayerFrameOnDeath,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_TARGET_LINGER_CURSOR),
            tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_LINGER_CURSOR_TP),
            getFunction = function ()
                return Settings.TargetLingerInCursorMode
            end,
            setFunction = function (value)
                Settings.TargetLingerInCursorMode = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetLingerInCursorMode,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_TARGET_LINGER_DURATION),
            tooltip = GetString(LUIE_STRING_LAM_UF_TARGET_LINGER_DURATION_TP),
            min = 0,
            max = 30,
            step = 5,
            getFunction = function ()
                return Settings.TargetLingerDuration
            end,
            setFunction = function (value)
                Settings.TargetLingerDuration = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget and Settings.TargetLingerInCursorMode)
            end,
            default = Defaults.TargetLingerDuration,
        }
    end)

    buildSectionSettings("CustomFramesFontTexture", function (settings)
        local sectionRows = UnitFrames.BuildLHASFontTextureSettingsSection(Settings, Defaults, SettingsAPI)
        for i = 1, #sectionRows do
            settings[#settings + 1] = sectionRows[i]
        end
    end)

    -- Build Custom Unit Frame Color Options Section
    buildSectionSettings("CustomFramesColor", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_CFRAMES_COLOR),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEALTH),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourHealth[1], Settings.CustomColourHealth[2], Settings.CustomColourHealth[3], Settings.CustomColourHealth[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourHealth = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
            end,
            default = Defaults.CustomColourHealth,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_SHIELD),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourShield[1], Settings.CustomColourShield[2], Settings.CustomColourShield[3]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourShield = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
            end,
            default = Defaults.CustomColourShield,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TRAUMA),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourTrauma[1], Settings.CustomColourTrauma[2], Settings.CustomColourTrauma[3]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourTrauma = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
            end,
            default = Defaults.CustomColourTrauma,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_MAGICKA),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourMagicka[1], Settings.CustomColourMagicka[2], Settings.CustomColourMagicka[3], Settings.CustomColourMagicka[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourMagicka = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuPlayerMagickaStaminaOnly()
            end,
            default = Defaults.CustomColourMagicka,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_STAMINA),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourStamina[1], Settings.CustomColourStamina[2], Settings.CustomColourStamina[3], Settings.CustomColourStamina[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourStamina = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuPlayerMagickaStaminaOnly()
            end,
            default = Defaults.CustomColourStamina,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_INVULNERABLE),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourInvulnerable[1], Settings.CustomColourInvulnerable[2], Settings.CustomColourInvulnerable[3]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourInvulnerable = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuHealthShieldTraumaInvulnerableAndGroupRaid()
            end,
            default = Defaults.CustomColourInvulnerable,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_DPS),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourDPS[1], Settings.CustomColourDPS[2], Settings.CustomColourDPS[3], Settings.CustomColourDPS[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourDPS = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourDPS,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEALER),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourHealer[1], Settings.CustomColourHealer[2], Settings.CustomColourHealer[3], Settings.CustomColourHealer[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourHealer = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourHealer,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TANK),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourTank[1], Settings.CustomColourTank[2], Settings.CustomColourTank[3], Settings.CustomColourTank[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourTank = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourTank,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_DK),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourDragonknight[1], Settings.CustomColourDragonknight[2], Settings.CustomColourDragonknight[3], Settings.CustomColourDragonknight[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourDragonknight = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourDragonknight,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_NB),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourNightblade[1], Settings.CustomColourNightblade[2], Settings.CustomColourNightblade[3], Settings.CustomColourNightblade[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourNightblade = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourNightblade,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_SORC),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourSorcerer[1], Settings.CustomColourSorcerer[2], Settings.CustomColourSorcerer[3], Settings.CustomColourSorcerer[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourSorcerer = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourSorcerer,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_TEMP),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourTemplar[1], Settings.CustomColourTemplar[2], Settings.CustomColourTemplar[3], Settings.CustomColourTemplar[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourTemplar = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourTemplar,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_WARD),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourWarden[1], Settings.CustomColourWarden[2], Settings.CustomColourWarden[3], Settings.CustomColourWarden[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourWarden = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourWarden,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_NECRO),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourNecromancer[1], Settings.CustomColourNecromancer[2], Settings.CustomColourNecromancer[3], Settings.CustomColourNecromancer[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourNecromancer = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourNecromancer,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_ARCA),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourArcanist[1], Settings.CustomColourArcanist[2], Settings.CustomColourArcanist[3], Settings.CustomColourArcanist[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourArcanist = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            default = Defaults.CustomColourArcanist,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_PLAYER),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourPlayer[1], Settings.CustomColourPlayer[2], Settings.CustomColourPlayer[3], Settings.CustomColourPlayer[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourPlayer = { r, g, b, a }
                UnitFrames.CustomFramesApplyReactionColorForMenu()
            end,
            default = Defaults.CustomColourPlayer,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_FRIENDLY),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourFriendly[1], Settings.CustomColourFriendly[2], Settings.CustomColourFriendly[3], Settings.CustomColourFriendly[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourFriendly = { r, g, b, a }
                UnitFrames.CustomFramesApplyReactionColorForMenu()
            end,
            default = Defaults.CustomColourFriendly,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_COMPANION),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourCompanion[1], Settings.CustomColourCompanion[2], Settings.CustomColourCompanion[3], Settings.CustomColourCompanion[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourCompanion = { r, g, b, a }
                UnitFrames.CustomFramesApplyReactionColorForMenu()
            end,
            default = Defaults.CustomColourCompanion,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_HOSTILE),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourHostile[1], Settings.CustomColourHostile[2], Settings.CustomColourHostile[3], Settings.CustomColourHostile[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourHostile = { r, g, b, a }
                UnitFrames.CustomFramesApplyReactionColorForMenu()
            end,
            default = Defaults.CustomColourHostile,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_NEUTRAL),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourNeutral[1], Settings.CustomColourNeutral[2], Settings.CustomColourNeutral[3], Settings.CustomColourNeutral[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourNeutral = { r, g, b, a }
                UnitFrames.CustomFramesApplyReactionColorForMenu()
            end,
            default = Defaults.CustomColourNeutral,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_FILL_R_GUARD),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourGuard[1], Settings.CustomColourGuard[2], Settings.CustomColourGuard[3], Settings.CustomColourGuard[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourGuard = { r, g, b, a }
                UnitFrames.CustomFramesApplyReactionColorForMenu()
            end,
            default = Defaults.CustomColourGuard,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_COLOR),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourPet[1], Settings.CustomColourPet[2], Settings.CustomColourPet[3], Settings.CustomColourPet[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourPet = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuPetFramesOnly()
            end,
            default = Defaults.CustomColourPet,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_COLOR),
            tooltip = nil,
            getFunction = function ()
                return Settings.CustomColourCompanionFrame[1], Settings.CustomColourCompanionFrame[2], Settings.CustomColourCompanionFrame[3], Settings.CustomColourCompanionFrame[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CustomColourCompanionFrame = { r, g, b, a }
                UnitFrames.CustomFramesApplyColorsMenuCompanionFrameOnly()
            end,
            default = Defaults.CustomColourCompanionFrame,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }
    end)

    -- Build Custom Unit Frames (Player) Options Section
    buildSectionSettings("CustomFramesPlayer", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_HEADER),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_PLAYER),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_PLAYER_TP),
            getFunction = function ()
                return Settings.CustomFramesPlayer
            end,
            setFunction = function (value)
                Settings.CustomFramesPlayer = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomFramesPlayer,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_PLAYER),
            tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_PLAYER_TP),
            items = SettingsAPI:GetNameDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfNameDisplayIndex(Settings.DisplayOptionsPlayer, Defaults.DisplayOptionsPlayer))
            end,
            setFunction = function (combobox, value, item)
                Settings.DisplayOptionsPlayer = item.data
                UnitFrames.CustomFramesReloadControlsMenu(false, nil, nil, false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.DisplayOptionsPlayer),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatOnePlayer)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatOnePlayer = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatOnePlayer),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatTwoPlayer)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatTwoPlayer = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatTwoPlayer),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_WIDTH),
            tooltip = nil,
            min = 200,
            max = 1000,
            step = 5,
            getFunction = function ()
                return Settings.PlayerBarWidth
            end,
            setFunction = function (value)
                Settings.PlayerBarWidth = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerBarWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_HIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.PlayerBarHeightHealth
            end,
            setFunction = function (value)
                Settings.PlayerBarHeightHealth = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerBarHeightHealth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_HIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.PlayerBarHeightMagicka
            end,
            setFunction = function (value)
                Settings.PlayerBarHeightMagicka = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerBarHeightMagicka,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_HIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.PlayerBarHeightStamina
            end,
            setFunction = function (value)
                Settings.PlayerBarHeightStamina = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerBarHeightStamina,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_OOCPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_OOCPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.PlayerOocAlpha
            end,
            setFunction = function (value)
                Settings.PlayerOocAlpha = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerOocAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_ICPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_ICPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.PlayerIncAlpha
            end,
            setFunction = function (value)
                Settings.PlayerIncAlpha = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerIncAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BuFFS_PLAYER),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BuFFS_PLAYER_TP),
            getFunction = function ()
                return Settings.HideBuffsPlayerOoc
            end,
            setFunction = function (value)
                Settings.HideBuffsPlayerOoc = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.HideBuffsPlayerOoc,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_NAMESELF),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_NAMESELF_TP),
            getFunction = function ()
                return Settings.PlayerEnableYourname
            end,
            setFunction = function (value)
                Settings.PlayerEnableYourname = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerEnableYourname,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MOUNTSIEGEWWBAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MOUNTSIEGEWWBAR_TP),
            getFunction = function ()
                return Settings.PlayerEnableAltbarMSW
            end,
            setFunction = function (value)
                Settings.PlayerEnableAltbarMSW = value
                UnitFrames.CustomFramesSetupAlternative()
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerEnableAltbarMSW,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBAR_TP),
            getFunction = function ()
                return Settings.PlayerEnableAltbarXP
            end,
            setFunction = function (value)
                Settings.PlayerEnableAltbarXP = value
                UnitFrames.CustomFramesSetupAlternative()
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerEnableAltbarXP,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBARCOLOR),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_XPCPBARCOLOR_TP),
            getFunction = function ()
                return Settings.PlayerChampionColour
            end,
            setFunction = function (value)
                Settings.PlayerChampionColour = value
                UnitFrames.OnChampionPointGained()
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerEnableAltbarXP)
            end,
            default = Defaults.PlayerChampionColour,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_HEALTH),
            tooltip = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_HEALTH_TP),
            min = 0,
            max = 50,
            step = 1,
            getFunction = function ()
                return Settings.LowResourceHealth
            end,
            setFunction = function (value)
                Settings.LowResourceHealth = value
                UnitFrames.CustomFramesReloadLowResourceThreshold()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.LowResourceHealth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_MAGICKA),
            tooltip = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_MAGICKA_TP),
            min = 0,
            max = 50,
            step = 1,
            getFunction = function ()
                return Settings.LowResourceMagicka
            end,
            setFunction = function (value)
                Settings.LowResourceMagicka = value
                UnitFrames.CustomFramesReloadLowResourceThreshold()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.LowResourceMagicka,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_STAMINA),
            tooltip = GetString(LUIE_STRING_LAM_UF_LOWRESOURCE_STAMINA_TP),
            min = 0,
            max = 50,
            step = 1,
            getFunction = function ()
                return Settings.LowResourceStamina
            end,
            setFunction = function (value)
                Settings.LowResourceStamina = value
                UnitFrames.CustomFramesReloadLowResourceThreshold()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.LowResourceStamina,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_PLAYER_DODGE_PREDICTION),
            tooltip = GetString(LUIE_STRING_LAM_UF_PLAYER_DODGE_PREDICTION_TP),
            getFunction = function ()
                return Settings.ShowPlayerDodgePrediction
            end,
            setFunction = function (value)
                Settings.ShowPlayerDodgePrediction = value
                UnitFrames.PlayerDodgePrediction.Refresh()
            end,
            default = Defaults.ShowPlayerDodgePrediction,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_PLAYER_DODGE_PREDICTION_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_UF_PLAYER_DODGE_PREDICTION_COLOR_TP),
            getFunction = function ()
                return Settings.PlayerDodgePredictionColor[1], Settings.PlayerDodgePredictionColor[2], Settings.PlayerDodgePredictionColor[3], Settings.PlayerDodgePredictionColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.PlayerDodgePredictionColor = { r, g, b, a }
                UnitFrames.PlayerDodgePrediction.Refresh()
            end,
            default = Defaults.PlayerDodgePredictionColor,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.ShowPlayerDodgePrediction)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PLAYER)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
            getFunction = function ()
                return Settings.PlayerEnableArmor
            end,
            setFunction = function (value)
                Settings.PlayerEnableArmor = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerEnableArmor,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PLAYER)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
            getFunction = function ()
                return Settings.PlayerEnablePower
            end,
            setFunction = function (value)
                Settings.PlayerEnablePower = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerEnablePower,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PLAYER)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
            getFunction = function ()
                return Settings.PlayerEnableRegen
            end,
            setFunction = function (value)
                Settings.PlayerEnableRegen = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerEnableRegen,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_VETERANCY_RANK),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_VETERANCY_RANK_TP),
            getFunction = function ()
                return Settings.PlayerShowVeterancyRank
            end,
            setFunction = function (value)
                Settings.PlayerShowVeterancyRank = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerShowVeterancyRank,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_OVERLAND_DIFFICULTY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_OVERLAND_DIFFICULTY_TP),
            getFunction = function ()
                return Settings.PlayerShowOverlandDifficulty
            end,
            setFunction = function (value)
                Settings.PlayerShowOverlandDifficulty = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerShowOverlandDifficulty,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT_TP),
            getFunction = function ()
                return Settings.PlayerOocAlphaPower
            end,
            setFunction = function (value)
                Settings.PlayerOocAlphaPower = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.PlayerOocAlphaPower,
        }
    end)

    buildSectionSettings("CustomFramesTarget", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESTARGET_HEADER),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_ENABLE_TARGET_TP),
            getFunction = function ()
                return Settings.CustomFramesTarget
            end,
            setFunction = function (value)
                Settings.CustomFramesTarget = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomFramesTarget,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_TARGET_TP),
            items = SettingsAPI:GetNameDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfNameDisplayIndex(Settings.DisplayOptionsTarget, Defaults.DisplayOptionsTarget))
            end,
            setFunction = function (combobox, value, item)
                Settings.DisplayOptionsTarget = item.data
                UnitFrames.CustomFramesReloadControlsMenu(false, nil, nil, false, false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.DisplayOptionsTarget),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatOneTarget)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatOneTarget = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatOneTarget),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatTwoTarget)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatTwoTarget = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatTwoTarget),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_WIDTH),
            tooltip = nil,
            min = 200,
            max = 1000,
            step = 5,
            getFunction = function ()
                return Settings.TargetBarWidth
            end,
            setFunction = function (value)
                Settings.TargetBarWidth = value
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetBarWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_HEIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.TargetBarHeight
            end,
            setFunction = function (value)
                Settings.TargetBarHeight = value
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetBarHeight,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_OOCPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_OOCPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.TargetOocAlpha
            end,
            setFunction = function (value)
                Settings.TargetOocAlpha = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetOocAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_ICPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_ICPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.TargetIncAlpha
            end,
            setFunction = function (value)
                Settings.TargetIncAlpha = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetIncAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BUFFS_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_BUFFS_TARGET_TP),
            getFunction = function ()
                return Settings.HideBuffsTargetOoc
            end,
            setFunction = function (value)
                Settings.HideBuffsTargetOoc = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.HideBuffsTargetOoc,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_REACTION_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_REACTION_TARGET_TP),
            getFunction = function ()
                return Settings.FrameColorReaction
            end,
            setFunction = function (value)
                Settings.FrameColorReaction = value
                UnitFrames.CustomFramesApplyReactionColor()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.FrameColorReaction,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_CLASS_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_CLASS_TARGET_TP),
            getFunction = function ()
                return Settings.FrameColorClass
            end,
            setFunction = function (value)
                Settings.FrameColorClass = value
                UnitFrames.CustomFramesApplyReactionColor()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.FrameColorClass,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_CLASSLABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_CLASSLABEL_TP),
            getFunction = function ()
                return Settings.TargetEnableClass
            end,
            setFunction = function (value)
                Settings.TargetEnableClass = value
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetEnableClass,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_FRIEND_ICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_FRIEND_ICON_TP),
            getFunction = function ()
                return Settings.CustomTargetShowFriendIcon
            end,
            setFunction = function (value)
                Settings.CustomTargetShowFriendIcon = value
                UnitFrames.RefreshCustomTargetFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.CustomTargetShowFriendIcon,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_GUILD_ICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_GUILD_ICON_TP),
            getFunction = function ()
                return Settings.CustomTargetShowGuildIcon
            end,
            setFunction = function (value)
                Settings.CustomTargetShowGuildIcon = value
                UnitFrames.RefreshCustomTargetFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.CustomTargetShowGuildIcon,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_IGNORED_ICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TARGET_IGNORED_ICON_TP),
            getFunction = function ()
                return Settings.CustomTargetShowIgnoredIcon
            end,
            setFunction = function (value)
                Settings.CustomTargetShowIgnoredIcon = value
                UnitFrames.RefreshCustomTargetFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.CustomTargetShowIgnoredIcon,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETHRESHOLD),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETHRESHOLD_TP),
            min = 0,
            max = 50,
            step = 5,
            getFunction = function ()
                return Settings.ExecutePercentage
            end,
            setFunction = function (value)
                Settings.ExecutePercentage = value
                UnitFrames.CustomFramesReloadExecuteMenu()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.ExecutePercentage,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETEXTURE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_EXETEXTURE_TP),
            getFunction = function ()
                return Settings.TargetEnableSkull
            end,
            setFunction = function (value)
                Settings.TargetEnableSkull = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetEnableSkull,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TITLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_TITLE_TP),
            getFunction = function ()
                return Settings.TargetEnableTitle
            end,
            setFunction = function (value)
                Settings.TargetEnableTitle = value
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetEnableTitle,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_VETERANCY_RANK),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_VETERANCY_RANK_TP),
            getFunction = function ()
                return Settings.TargetShowVeterancyRank
            end,
            setFunction = function (value)
                Settings.TargetShowVeterancyRank = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetShowVeterancyRank,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_OVERLAND_DIFFICULTY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_OVERLAND_DIFFICULTY_TP),
            getFunction = function ()
                return Settings.TargetShowOverlandDifficulty
            end,
            setFunction = function (value)
                Settings.TargetShowOverlandDifficulty = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetShowOverlandDifficulty,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MONSTER_OVERLAND),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MONSTER_OVERLAND_TP),
            getFunction = function ()
                return Settings.TargetMonsterOverlandDifficulty
            end,
            setFunction = function (value)
                Settings.TargetMonsterOverlandDifficulty = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget and Settings.TargetShowOverlandDifficulty)
            end,
            default = Defaults.TargetMonsterOverlandDifficulty,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MONSTER_CLASSICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MONSTER_CLASSICON_TP),
            getFunction = function ()
                return Settings.TargetHighlightMonsterUnits
            end,
            setFunction = function (value)
                Settings.TargetHighlightMonsterUnits = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetHighlightMonsterUnits,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TP),
            getFunction = function ()
                return Settings.TargetEnableRank
            end,
            setFunction = function (value)
                Settings.TargetEnableRank = value
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetEnableRank,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TITLE_PRIORITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANK_TITLE_PRIORITY_TP),
            items =
            {
                { name = "AVA Rank", data = "AVA Rank" },
                { name = "Title",    data = "Title"    }
            },
            getFunction = function ()
                return { data = Settings.TargetTitlePriority }
            end,
            setFunction = function (combobox, value, item)
                Settings.TargetTitlePriority = item.data or item.name or value
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.TargetTitlePriority),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget and Settings.TargetEnableRank and Settings.TargetEnableTitle)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANKICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_RANKICON_TP),
            getFunction = function ()
                return Settings.TargetEnableRankIcon
            end,
            setFunction = function (value)
                Settings.TargetEnableRankIcon = value
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetEnableRankIcon,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_TARGET)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
            getFunction = function ()
                return Settings.TargetEnableArmor
            end,
            setFunction = function (value)
                Settings.TargetEnableArmor = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetEnableArmor,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_TARGET)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
            getFunction = function ()
                return Settings.TargetEnablePower
            end,
            setFunction = function (value)
                Settings.TargetEnablePower = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetEnablePower,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_TARGET)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
            getFunction = function ()
                return Settings.TargetEnableRegen
            end,
            setFunction = function (value)
                Settings.TargetEnableRegen = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetEnableRegen,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_MISSPOWERCOMBAT_TP),
            getFunction = function ()
                return Settings.TargetOocAlphaPower
            end,
            setFunction = function (value)
                Settings.TargetOocAlphaPower = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
            default = Defaults.TargetOocAlphaPower,
        }
    end)

    -- Build Frame positions section (console X/Y sliders; range covers 1080p + margin)
    buildSectionSettings("CustomFramesPositions", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POSITIONS_HEADER),
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POSITIONS_TP),
        }

        -- Unlock for previewing frames;
        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_UNLOCK),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_UNLOCK_TP),
            getFunction = function ()
                return UnitFrames.CustomFramesMovingState
            end,
            setFunction = function (value)
                UnitFrames.CustomFramesSetMovingState(value)
            end,
            default = false,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_RESETPOSIT_TP),
            clickHandler = function ()
                UnitFrames.CustomFramesResetPosition(false)
            end,
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
        }

        local positionFrameConfig =
        {
            { unitTag = "player",          label = "Player",     disable = function () return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer) end    },
            { unitTag = "reticleover",     label = "Target",     disable = function () return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget) end    },
            { unitTag = "companion",       label = "Companion",  disable = function () return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion) end },
            { unitTag = "SmallGroup1",     label = "Group",      disable = function () return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup) end     },
            { unitTag = "RaidGroup1",      label = "Raid",       disable = function () return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid) end      },
            { unitTag = "boss1",           label = "Boss",       disable = function () return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses) end    },
            { unitTag = "AvaPlayerTarget", label = "PvP Target", disable = function () return not (LUIE.SV.UnitFrames_Enabled and Settings.AvaCustFramesTarget) end   },
            { unitTag = "PetGroup1",       label = "Pet",        disable = function () return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet) end       },
        }

        local gw = GuiRoot:GetWidth()
        local gh = GuiRoot:GetHeight()
        for _, cfg in ipairs(positionFrameConfig) do
            local unitTag = cfg.unitTag
            local attr = UnitFrames.CustomFramePositionAttr[unitTag]
            if not attr then
                break
            end
            settings[#settings + 1] = { type = LHAS.ST_LABEL, label = cfg.label }
            settings[#settings + 1] =
            {
                type = LHAS.ST_SLIDER,
                label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X_TP),
                min = -gw,
                max = gw,
                step = 10,
                getFunction = function ()
                    local left, _ = UnitFrames.CustomFramesGetPosition(unitTag)
                    return left
                end,
                setFunction = function (value)
                    local pos = Settings[attr] or {}
                    Settings[attr] = { value, pos[2] or 0 }
                    UnitFrames.CustomFramesSetPositions()
                end,
                disable = cfg.disable,
                default = 0,
            }
            settings[#settings + 1] =
            {
                type = LHAS.ST_SLIDER,
                label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y_TP),
                min = -gh,
                max = gh,
                step = 10,
                getFunction = function ()
                    local _, top = UnitFrames.CustomFramesGetPosition(unitTag)
                    return top
                end,
                setFunction = function (value)
                    local pos = Settings[attr] or {}
                    Settings[attr] = { pos[1] or 0, value }
                    UnitFrames.CustomFramesSetPositions()
                end,
                disable = cfg.disable,
                default = 0,
            }
        end
    end)

    -- Build Custom Unit Frames Bar Alignment Section
    buildSectionSettings("CustomFramesBarAlignment", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_BAR_ALIGN),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_HEALTH),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_HEALTH_TP),
            items = SettingsAPI:GetAlignmentOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfAlignmentIndex(Settings.BarAlignPlayerHealth, Defaults.BarAlignPlayerHealth))
            end,
            setFunction = function (combobox, value, item)
                Settings.BarAlignPlayerHealth = item.data
                UnitFrames.CustomFramesApplyBarAlignment()
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BarAlignPlayerHealth),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_MAGICKA),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_MAGICKA_TP),
            items = SettingsAPI:GetAlignmentOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfAlignmentIndex(Settings.BarAlignPlayerMagicka, Defaults.BarAlignPlayerMagicka))
            end,
            setFunction = function (combobox, value, item)
                Settings.BarAlignPlayerMagicka = item.data
                UnitFrames.CustomFramesApplyBarAlignment()
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BarAlignPlayerMagicka),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_STAMINA),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_PLAYER_STAMINA_TP),
            items = SettingsAPI:GetAlignmentOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfAlignmentIndex(Settings.BarAlignPlayerStamina, Defaults.BarAlignPlayerStamina))
            end,
            setFunction = function (combobox, value, item)
                Settings.BarAlignPlayerStamina = item.data
                UnitFrames.CustomFramesApplyBarAlignment()
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BarAlignPlayerStamina),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_TARGET_TP),
            items = SettingsAPI:GetAlignmentOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfAlignmentIndex(Settings.BarAlignTarget, Defaults.BarAlignTarget))
            end,
            setFunction = function (combobox, value, item)
                Settings.BarAlignTarget = item.data
                UnitFrames.CustomFramesApplyBarAlignment()
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.BarAlignTarget),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesTarget)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_PLAYER),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_PLAYER_TP),
            getFunction = function ()
                return Settings.BarAlignCenterLabelPlayer
            end,
            setFunction = function (value)
                Settings.BarAlignCenterLabelPlayer = value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.BarAlignCenterLabelPlayer,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_TARGET),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_TARGET_TP),
            getFunction = function ()
                return Settings.BarAlignCenterLabelTarget
            end,
            setFunction = function (value)
                Settings.BarAlignCenterLabelTarget = value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.BarAlignCenterLabelTarget,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_CENTER_FORM),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_LABEL_CENTER_FORM),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatCenterLabel)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatCenterLabel = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
                UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatCenterLabel),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }
    end)

    -- Build Additional Player Frame Display Options Section
    buildSectionSettings("CustomFramesPlayerTargetOptions", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_OPTIONS_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_PLAYER_TARGET),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD_TP),
            items = SettingsAPI:GetPlayerFrameOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfPlayerFrameIndex(Settings.PlayerFrameOptions, Defaults.PlayerFrameOptions))
            end,
            setFunction = function (combobox, value, item)
                Settings.PlayerFrameOptions = item.data
                UnitFrames.MenuUpdatePlayerFrameOptions(Settings.PlayerFrameOptions)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.PlayerFrameOptions),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            warning = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_METHOD_WARN),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_HORIZ_ADJUST),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_HORIZ_ADJUST_TP),
            min = 0,
            max = 500,
            step = 5,
            getFunction = function ()
                return Settings.AdjustStaminaHPos
            end,
            setFunction = function (value)
                Settings.AdjustStaminaHPos = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
            end,
            default = Defaults.AdjustStaminaHPos,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_VERT_ADJUST),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_S_VERT_ADJUST_TP),
            min = -250,
            max = 250,
            step = 5,
            getFunction = function ()
                return Settings.AdjustStaminaVPos
            end,
            setFunction = function (value)
                Settings.AdjustStaminaVPos = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
            end,
            default = Defaults.AdjustStaminaVPos,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_HORIZ_ADJUST),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_HORIZ_ADJUST_TP),
            min = 0,
            max = 500,
            step = 5,
            getFunction = function ()
                return Settings.AdjustMagickaHPos
            end,
            setFunction = function (value)
                Settings.AdjustMagickaHPos = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
            end,
            default = Defaults.AdjustMagickaHPos,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_VERT_ADJUST),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_M_VERT_ADJUST_TP),
            min = -250,
            max = 250,
            step = 5,
            getFunction = function ()
                return Settings.AdjustMagickaVPos
            end,
            setFunction = function (value)
                Settings.AdjustMagickaVPos = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.PlayerFrameOptions == 2)
            end,
            default = Defaults.AdjustMagickaVPos,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_SPACING),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_SPACING_TP),
            min = -1,
            max = 4,
            step = 1,
            getFunction = function ()
                return Settings.PlayerBarSpacing
            end,
            setFunction = function (value)
                Settings.PlayerBarSpacing = value
                UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and (Settings.PlayerFrameOptions == 1 or Settings.PlayerFrameOptions == 3))
            end,
            default = Defaults.PlayerBarSpacing,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOLABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOLABEL_TP),
            getFunction = function ()
                return Settings.HideLabelHealth
            end,
            setFunction = function (value)
                Settings.HideLabelHealth = value
                Settings.HideBarHealth = false
                ApplyCustomPlayerHideBarLayout()
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.HideLabelHealth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOBAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_HP_NOBAR_TP),
            getFunction = function ()
                return Settings.HideBarHealth
            end,
            setFunction = function (value)
                Settings.HideBarHealth = value
                ApplyCustomPlayerHideBarLayout()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelHealth)
            end,
            default = Defaults.HideBarHealth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOLABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOLABEL_TP),
            getFunction = function ()
                return Settings.HideLabelMagicka
            end,
            setFunction = function (value)
                Settings.HideLabelMagicka = value
                Settings.HideBarMagicka = false
                ApplyCustomPlayerHideBarLayout()
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.HideLabelMagicka,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOBAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_MAG_NOBAR_TP),
            getFunction = function ()
                return Settings.HideBarMagicka
            end,
            setFunction = function (value)
                Settings.HideBarMagicka = value
                ApplyCustomPlayerHideBarLayout()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelMagicka)
            end,
            default = Defaults.HideBarMagicka,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOLABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOLABEL_TP),
            getFunction = function ()
                return Settings.HideLabelStamina
            end,
            setFunction = function (value)
                Settings.HideLabelStamina = value
                Settings.HideBarStamina = false
                ApplyCustomPlayerHideBarLayout()
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.HideLabelStamina,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOBAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_STAM_NOBAR_TP),
            getFunction = function ()
                return Settings.HideBarStamina
            end,
            setFunction = function (value)
                Settings.HideBarStamina = value
                ApplyCustomPlayerHideBarLayout()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer and Settings.HideLabelStamina)
            end,
            default = Defaults.HideBarStamina,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_REVERSE_RES),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPT_PLAYER_REVERSE_RES_TP),
            getFunction = function ()
                return Settings.ReverseResourceBars
            end,
            setFunction = function (value)
                Settings.ReverseResourceBars = value
                ApplyCustomPlayerHideBarLayout()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPlayer)
            end,
            default = Defaults.ReverseResourceBars,
        }
    end)

    -- Build Custom Unit Frames (Group) Options Section
    buildSectionSettings("CustomFramesGroup", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_GROUP),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_LUIEFRAMESENABLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_LUIEFRAMESENABLE_TP),
            getFunction = function ()
                return Settings.CustomFramesGroup
            end,
            setFunction = function (value)
                Settings.CustomFramesGroup = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomFramesGroup,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID),
            tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID_TP),
            items = SettingsAPI:GetNameDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfNameDisplayIndex(Settings.DisplayOptionsGroupRaid, Defaults.DisplayOptionsGroupRaid))
            end,
            setFunction = function (combobox, value, item)
                Settings.DisplayOptionsGroupRaid = item.data
                UnitFrames.CustomFramesReloadControlsMenu(false, false, false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.DisplayOptionsGroupRaid),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_LEFT_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatOneGroup)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatOneGroup = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutGroup(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatOneGroup),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_RIGHT_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatTwoGroup)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatTwoGroup = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutGroup(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatTwoGroup),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_WIDTH),
            tooltip = nil,
            min = 100,
            max = 400,
            step = 5,
            getFunction = function ()
                return Settings.GroupBarWidth
            end,
            setFunction = function (value)
                Settings.GroupBarWidth = value
                UnitFrames.CustomFramesApplyLayoutGroup(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupBarWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_HEIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.GroupBarHeight
            end,
            setFunction = function (value)
                Settings.GroupBarHeight = value
                UnitFrames.CustomFramesApplyLayoutGroup(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupBarHeight,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.GroupAlpha
            end,
            setFunction = function (value)
                Settings.GroupAlpha = value
                UnitFrames.CustomFramesGroupAlpha()
                UnitFrames.CustomFramesApplyLayoutGroup(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_SPACING),
            tooltip = nil,
            min = 20,
            max = 80,
            step = 2,
            getFunction = function ()
                return Settings.GroupBarSpacing
            end,
            setFunction = function (value)
                Settings.GroupBarSpacing = value
                UnitFrames.CustomFramesApplyLayoutGroup(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupBarSpacing,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_INCPLAYER),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_INCPLAYER_TP),
            getFunction = function ()
                return not Settings.GroupExcludePlayer
            end,
            setFunction = function (value)
                Settings.GroupExcludePlayer = not value
                UnitFrames.CustomFramesGroupUpdate()
                UnitFrames.CustomFramesApplyLayoutGroup(false)
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = not Defaults.GroupExcludePlayer,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_ROLEICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_ROLEICON_TP),
            getFunction = function ()
                return Settings.RoleIconSmallGroup
            end,
            setFunction = function (value)
                Settings.RoleIconSmallGroup = value
                UnitFrames.CustomFramesApplyLayoutGroup(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.RoleIconSmallGroup,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_FRIEND_ICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_FRIEND_ICON_TP),
            getFunction = function ()
                return Settings.GroupShowFriendIcon
            end,
            setFunction = function (value)
                Settings.GroupShowFriendIcon = value
                UnitFrames.RefreshCustomSmallGroupFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupShowFriendIcon,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_GUILD_ICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_GUILD_ICON_TP),
            getFunction = function ()
                return Settings.GroupShowGuildIcon
            end,
            setFunction = function (value)
                Settings.GroupShowGuildIcon = value
                UnitFrames.RefreshCustomSmallGroupFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupShowGuildIcon,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_IGNORED_ICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_IGNORED_ICON_TP),
            getFunction = function ()
                return Settings.GroupShowIgnoredIcon
            end,
            setFunction = function (value)
                Settings.GroupShowIgnoredIcon = value
                UnitFrames.RefreshCustomSmallGroupFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupShowIgnoredIcon,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_VETERANCY_RANK),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_VETERANCY_RANK_TP),
            getFunction = function ()
                return Settings.GroupShowVeterancyRank
            end,
            setFunction = function (value)
                Settings.GroupShowVeterancyRank = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupShowVeterancyRank,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESG_OVERLAND_DIFFICULTY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESG_OVERLAND_DIFFICULTY_TP),
            getFunction = function ()
                return Settings.GroupShowOverlandDifficulty
            end,
            setFunction = function (value)
                Settings.GroupShowOverlandDifficulty = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupShowOverlandDifficulty,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYCLASS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYCLASS_TP),
            getFunction = function ()
                return Settings.ColorClassGroup
            end,
            setFunction = function (value)
                Settings.ColorClassGroup = value
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.ColorClassGroup,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYROLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_GFRAMESBYROLE_TP),
            getFunction = function ()
                return Settings.ColorRoleGroup
            end,
            setFunction = function (value)
                Settings.ColorRoleGroup = value
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.ColorRoleGroup,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Sort Group Frames by Role",
            tooltip = "Sort group members by role (Tank -> Healer -> DPS).",
            getFunction = function ()
                return Settings.SortRoleGroup
            end,
            setFunction = function (value)
                Settings.SortRoleGroup = value
                UnitFrames.CustomFramesApplyLayoutGroup(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.SortRoleGroup,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
            getFunction = function ()
                return Settings.GroupEnableArmor
            end,
            setFunction = function (value)
                Settings.GroupEnableArmor = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupEnableArmor,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
            getFunction = function ()
                return Settings.GroupEnablePower
            end,
            setFunction = function (value)
                Settings.GroupEnablePower = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupEnablePower,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_GROUP)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
            getFunction = function ()
                return Settings.GroupEnableRegen
            end,
            setFunction = function (value)
                Settings.GroupEnableRegen = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupEnableRegen,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Combat Glow",
            tooltip = "Display a red glow around group member health bars when they are in combat (fades in/out smoothly).",
            getFunction = function ()
                return Settings.GroupCombatGlow
            end,
            setFunction = function (value)
                Settings.GroupCombatGlow = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup)
            end,
            default = Defaults.GroupCombatGlow,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Combat Glow Color",
            tooltip = "Set the color of the combat glow border displayed around group frames.",
            getFunction = function ()
                return Settings.GroupCombatGlowColor[1], Settings.GroupCombatGlowColor[2], Settings.GroupCombatGlowColor[3], Settings.GroupCombatGlowColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.GroupCombatGlowColor = { r, g, b, a }
                UnitFrames.UpdateGroupCombatGlow()
            end,
            default = Defaults.GroupCombatGlowColor,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesGroup and Settings.GroupCombatGlow)
            end,
        }
    end)

    -- Build Custom Unit Frames (Raid) Options Section
    buildSectionSettings("CustomFramesRaid", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_RAID),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_LUIEFRAMESENABLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_LUIEFRAMESENABLE_TP),
            getFunction = function ()
                return Settings.CustomFramesRaid
            end,
            setFunction = function (value)
                Settings.CustomFramesRaid = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomFramesRaid,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID),
            tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_NAMEDISPLAY_GROUPRAID_TP),
            items = SettingsAPI:GetNameDisplayOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfNameDisplayIndex(Settings.DisplayOptionsGroupRaid, Defaults.DisplayOptionsGroupRaid))
            end,
            setFunction = function (combobox, value, item)
                Settings.DisplayOptionsGroupRaid = item.data
                UnitFrames.CustomFramesReloadControlsMenu(false, false, false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.DisplayOptionsGroupRaid),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatRaid)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatRaid = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatRaid),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_WIDTH),
            tooltip = nil,
            min = 100,
            max = 500,
            step = 5,
            getFunction = function ()
                return Settings.RaidBarWidth
            end,
            setFunction = function (value)
                Settings.RaidBarWidth = value
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidBarWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_HEIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.RaidBarHeight
            end,
            setFunction = function (value)
                Settings.RaidBarHeight = value
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidBarHeight,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_GROUPRAID_OPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.GroupAlpha
            end,
            setFunction = function (value)
                Settings.GroupAlpha = value
                UnitFrames.CustomFramesGroupAlpha()
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.GroupAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_LAYOUT),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_LAYOUT_TP),
            items =
            {
                { name = "1 x 12", data = "1 x 12" },
                { name = "2 x 6",  data = "2 x 6"  },
                { name = "3 x 4",  data = "3 x 4"  },
                { name = "6 x 2",  data = "6 x 2"  }
            },
            getFunction = function ()
                return { data = Settings.RaidLayout }
            end,
            setFunction = function (combobox, value, item)
                Settings.RaidLayout = item.data or item.name or value
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.RaidLayout),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_SPACER),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_SPACER_TP),
            getFunction = function ()
                return Settings.RaidSpacers
            end,
            setFunction = function (value)
                Settings.RaidSpacers = value
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidSpacers,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_NAMECLIP),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_NAMECLIP_TP),
            min = 0,
            max = 200,
            step = 1,
            getFunction = function ()
                return Settings.RaidNameClip
            end,
            setFunction = function (value)
                Settings.RaidNameClip = value
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidNameClip,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_ROLEICON),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_ROLEICON_TP),
            items = SettingsAPI:GetRaidIconOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeUfRaidIconIndex(Settings.RaidIconOptions, Defaults.RaidIconOptions))
            end,
            setFunction = function (combobox, value, item)
                Settings.RaidIconOptions = item.data
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.RaidIconOptions),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_VETERANCY_RANK),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_VETERANCY_RANK_TP),
            getFunction = function ()
                return Settings.RaidShowVeterancyRank
            end,
            setFunction = function (value)
                Settings.RaidShowVeterancyRank = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidShowVeterancyRank,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESR_OVERLAND_DIFFICULTY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESR_OVERLAND_DIFFICULTY_TP),
            getFunction = function ()
                return Settings.RaidShowOverlandDifficulty
            end,
            setFunction = function (value)
                Settings.RaidShowOverlandDifficulty = value
                UnitFrames.RefreshVeterancyOverlandFrameStaticControls()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidShowOverlandDifficulty,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYCLASS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYCLASS_TP),
            getFunction = function ()
                return Settings.ColorClassRaid
            end,
            setFunction = function (value)
                Settings.ColorClassRaid = value
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.ColorClassRaid,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYROLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESBYROLE_TP),
            getFunction = function ()
                return Settings.ColorRoleRaid
            end,
            setFunction = function (value)
                Settings.ColorRoleRaid = value
                UnitFrames.CustomFramesApplyColorsMenuGroupRaidMembersOnly()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.ColorRoleRaid,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESSORT),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_RFRAMESSORT_TP),
            getFunction = function ()
                return Settings.SortRoleRaid
            end,
            setFunction = function (value)
                Settings.SortRoleRaid = value
                UnitFrames.CustomFramesApplyLayoutRaid(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid and Settings.ColorRoleRaid)
            end,
            default = Defaults.SortRoleRaid,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
            getFunction = function ()
                return Settings.RaidEnableArmor
            end,
            setFunction = function (value)
                Settings.RaidEnableArmor = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidEnableArmor,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
            getFunction = function ()
                return Settings.RaidEnablePower
            end,
            setFunction = function (value)
                Settings.RaidEnablePower = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidEnablePower,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_RAID)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
            getFunction = function ()
                return Settings.RaidEnableRegen
            end,
            setFunction = function (value)
                Settings.RaidEnableRegen = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidEnableRegen,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Combat Glow",
            tooltip = "Display a red glow around raid member health bars when they are in combat (fades in/out smoothly).",
            getFunction = function ()
                return Settings.RaidCombatGlow
            end,
            setFunction = function (value)
                Settings.RaidCombatGlow = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid)
            end,
            default = Defaults.RaidCombatGlow,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Combat Glow Color",
            tooltip = "Set the color of the combat glow border displayed around raid frames.",
            getFunction = function ()
                return Settings.RaidCombatGlowColor[1], Settings.RaidCombatGlowColor[2], Settings.RaidCombatGlowColor[3], Settings.RaidCombatGlowColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.RaidCombatGlowColor = { r, g, b, a }
                UnitFrames.UpdateGroupCombatGlow()
            end,
            default = Defaults.RaidCombatGlowColor,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesRaid and Settings.RaidCombatGlow)
            end,
        }
    end)

    -- Build Group Resources (LibGroupBroadcast) Options Section
    buildSectionSettings("GroupResources", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Group Resources",
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_GROUP_RESOURCES),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Enable Group Resources",
            tooltip = "Display magicka and stamina bars for group members using LibGroupBroadcast.",
            getFunction = function ()
                return Settings.GroupResources.enabled
            end,
            setFunction = function (value)
                Settings.GroupResources.enabled = value
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.OnSettingsChanged()
                end
            end,
            warning = "Requires LibGroupBroadcast library. " .. GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and LibGroupBroadcast)
            end,
            default = Defaults.GroupResources.enabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Stamina First",
            tooltip = "Show stamina bar above magicka bar instead of below.",
            getFunction = function ()
                return Settings.GroupResources.staminaFirst
            end,
            setFunction = function (value)
                Settings.GroupResources.staminaFirst = value
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.UpdateAllLayouts()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
            default = Defaults.GroupResources.staminaFirst,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Fade Effect on Resource Loss",
            tooltip = "Show a fade-out ghost effect when resources decrease for better visibility.",
            getFunction = function ()
                return Settings.GroupResources.enableFadeEffect
            end,
            setFunction = function (value)
                Settings.GroupResources.enableFadeEffect = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
            default = Defaults.GroupResources.enableFadeEffect,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Hide Resource Bars (Timeout)",
            tooltip = "Hide resource bars after no updates received for set timeout period.",
            getFunction = function ()
                return Settings.GroupResources.hideResourceBarsToggle
            end,
            setFunction = function (value)
                Settings.GroupResources.hideResourceBarsToggle = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
            default = Defaults.GroupResources.hideResourceBarsToggle,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "    Hide Timeout (seconds)",
            tooltip = "Seconds after last resource update before hiding bars.",
            min = 5,
            max = 600,
            step = 5,
            getFunction = function ()
                return Settings.GroupResources.hideResourceBarsTimeout
            end,
            setFunction = function (value)
                Settings.GroupResources.hideResourceBarsTimeout = value
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled and Settings.GroupResources.hideResourceBarsToggle)
            end,
            default = Defaults.GroupResources.hideResourceBarsTimeout,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Group Frame Bar Width",
            tooltip = nil,
            min = 50,
            max = 300,
            step = 5,
            getFunction = function ()
                return Settings.GroupResources.groupBarWidth
            end,
            setFunction = function (value)
                Settings.GroupResources.groupBarWidth = value
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.UpdateAllLayouts()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
            default = Defaults.GroupResources.groupBarWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Group Frame Bar Height",
            tooltip = nil,
            min = 3,
            max = 15,
            step = 1,
            getFunction = function ()
                return Settings.GroupResources.groupBarHeight
            end,
            setFunction = function (value)
                Settings.GroupResources.groupBarHeight = value
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.UpdateAllLayouts()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
            default = Defaults.GroupResources.groupBarHeight,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Raid Frame Bar Width",
            tooltip = nil,
            min = 50,
            max = 250,
            step = 5,
            getFunction = function ()
                return Settings.GroupResources.raidBarWidth
            end,
            setFunction = function (value)
                Settings.GroupResources.raidBarWidth = value
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.UpdateAllLayouts()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
            default = Defaults.GroupResources.raidBarWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Raid Frame Bar Height",
            tooltip = nil,
            min = 3,
            max = 15,
            step = 1,
            getFunction = function ()
                return Settings.GroupResources.raidBarHeight
            end,
            setFunction = function (value)
                Settings.GroupResources.raidBarHeight = value
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.UpdateAllLayouts()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
            default = Defaults.GroupResources.raidBarHeight,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Magicka Gradient Start",
            tooltip = nil,
            getFunction = function ()
                return Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart[1], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart[2], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart[3], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart = { r, g, b, a }
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.RefreshColors()
                end
            end,
            default = Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientStart,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Magicka Gradient End",
            tooltip = nil,
            getFunction = function ()
                return Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd[1], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd[2], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd[3], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd = { r, g, b, a }
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.RefreshColors()
                end
            end,
            default = Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_MAGICKA].gradientEnd,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Stamina Gradient Start",
            tooltip = nil,
            getFunction = function ()
                return Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart[1], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart[2], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart[3], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart = { r, g, b, a }
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.RefreshColors()
                end
            end,
            default = Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientStart,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Stamina Gradient End",
            tooltip = nil,
            getFunction = function ()
                return Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd[1], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd[2], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd[3], Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd = { r, g, b, a }
                if UnitFrames.GroupResources then
                    UnitFrames.GroupResources.RefreshColors()
                end
            end,
            default = Defaults.GroupResources.colors[COMBAT_MECHANIC_FLAGS_STAMINA].gradientEnd,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupResources.enabled)
            end,
        }
    end)

    -- Build Group Combat Stats (LibGroupCombatStats) Options Section
    buildSectionSettings("GroupCombatStats", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Group Combat Stats",
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_GROUP_COMBAT_STATS),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Enable Combat Stats Display",
            tooltip = "Display ultimate status, DPS, and HPS for group members using LibGroupCombatStats.",
            getFunction = function ()
                return Settings.GroupCombatStats.enabled
            end,
            setFunction = function (value)
                Settings.GroupCombatStats.enabled = value
                if UnitFrames.GroupCombatStats then
                    UnitFrames.GroupCombatStats.OnSettingsChanged()
                end
            end,
            warning = "Requires LibGroupCombatStats library. " .. GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and LibGroupCombatStats)
            end,
            default = Defaults.GroupCombatStats.enabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Ultimate Icons",
            tooltip = "Display ultimate ability icon with charge indicator on group frames.",
            getFunction = function ()
                return Settings.GroupCombatStats.showUltimate
            end,
            setFunction = function (value)
                Settings.GroupCombatStats.showUltimate = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
            end,
            default = Defaults.GroupCombatStats.showUltimate,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show DPS",
            tooltip = "Display damage per second values on group frames.",
            getFunction = function ()
                return Settings.GroupCombatStats.showDPS
            end,
            setFunction = function (value)
                Settings.GroupCombatStats.showDPS = value
                if UnitFrames.GroupCombatStats then
                    UnitFrames.GroupCombatStats.RefreshAll()
                end
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
            end,
            default = Defaults.GroupCombatStats.showDPS,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show HPS",
            tooltip = "Display healing per second values on group frames.",
            getFunction = function ()
                return Settings.GroupCombatStats.showHPS
            end,
            setFunction = function (value)
                Settings.GroupCombatStats.showHPS = value
                if UnitFrames.GroupCombatStats then
                    UnitFrames.GroupCombatStats.RefreshAll()
                end
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled)
            end,
            default = Defaults.GroupCombatStats.showHPS,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Group Frames (4 player)",
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "    Ultimate Icon Size",
            tooltip = "Set the size of ultimate icons displayed on group frames (4 player).",
            min = 16,
            max = 36,
            step = 2,
            getFunction = function ()
                return Settings.GroupCombatStats.ultIconGroupSize
            end,
            setFunction = function (value)
                Settings.GroupCombatStats.ultIconGroupSize = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
            end,
            default = Defaults.GroupCombatStats.ultIconGroupSize,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "    Horizontal Offset",
            tooltip = "Adjust horizontal position of ultimate icons on group frames.",
            min = -20,
            max = 20,
            step = 1,
            getFunction = function ()
                return Settings.GroupCombatStats.ultIconGroupOffsetX
            end,
            setFunction = function (value)
                Settings.GroupCombatStats.ultIconGroupOffsetX = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
            end,
            default = Defaults.GroupCombatStats.ultIconGroupOffsetX,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_GROUP_ULT_ICON_OFFSET_Y),
            tooltip = "Adjust vertical position of ultimate icons on group frames.",
            min = -20,
            max = 20,
            step = 1,
            getFunction = function ()
                return Settings.GroupCombatStats.ultIconGroupOffsetY
            end,
            setFunction = function (value)
                Settings.GroupCombatStats.ultIconGroupOffsetY = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupCombatStats.enabled and Settings.GroupCombatStats.showUltimate)
            end,
            default = Defaults.GroupCombatStats.ultIconGroupOffsetY,
        }
    end)

    -- Build Group Potion Cooldowns Options Section
    buildSectionSettings("GroupPotionCooldowns", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Group Potion Cooldowns",
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_GROUP_POTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Enable Group Potion Cooldowns",
            tooltip = "Display potion cooldown status for group members on custom unit frames (requires LibGroupPotionCooldowns).",
            getFunction = function ()
                return Settings.GroupPotionCooldowns.enabled
            end,
            setFunction = function (value)
                Settings.GroupPotionCooldowns.enabled = value
                if UnitFrames.GroupPotionCooldowns then
                    UnitFrames.GroupPotionCooldowns.OnSettingsChanged()
                end
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and LibGroupPotionCooldowns)
            end,
            default = Defaults.GroupPotionCooldowns.enabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Remaining Time",
            tooltip = "Display countdown timer on potion icon when on cooldown.",
            getFunction = function ()
                return Settings.GroupPotionCooldowns.showRemainingTime
            end,
            setFunction = function (value)
                Settings.GroupPotionCooldowns.showRemainingTime = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
            end,
            default = Defaults.GroupPotionCooldowns.showRemainingTime,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Group Frames (4 player)",
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_ICON_SIZE),
            tooltip = "Set the size of potion cooldown icons on group frames (4 player).",
            min = 14,
            max = 32,
            step = 2,
            getFunction = function ()
                return Settings.GroupPotionCooldowns.potionIconGroupSize
            end,
            setFunction = function (value)
                Settings.GroupPotionCooldowns.potionIconGroupSize = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
            end,
            default = Defaults.GroupPotionCooldowns.potionIconGroupSize,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "    Horizontal Offset",
            tooltip = "Adjust horizontal position of potion icon on group frames.",
            min = -20,
            max = 20,
            step = 1,
            getFunction = function ()
                return Settings.GroupPotionCooldowns.potionIconGroupOffsetX
            end,
            setFunction = function (value)
                Settings.GroupPotionCooldowns.potionIconGroupOffsetX = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
            end,
            default = Defaults.GroupPotionCooldowns.potionIconGroupOffsetX,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_GROUP_POTION_OFFSET_Y),
            tooltip = SettingsAPI:ConsoleTooltip(LUIE_STRING_LAM_UF_GROUP_POTION_OFFSET_Y_TP),
            min = -20,
            max = 20,
            step = 1,
            getFunction = function ()
                return Settings.GroupPotionCooldowns.potionIconGroupOffsetY
            end,
            setFunction = function (value)
                Settings.GroupPotionCooldowns.potionIconGroupOffsetY = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupPotionCooldowns.enabled)
            end,
            default = Defaults.GroupPotionCooldowns.potionIconGroupOffsetY,
        }
    end)

    -- Build Group Food & Drink Buffs Options Section
    buildSectionSettings("GroupFoodDrinkBuff", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Group Food & Drink Buffs",
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_GROUP_FOODDRINK),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Enable Group Food & Drink Buffs",
            tooltip = "Display food and drink buff icons for group members.",
            getFunction = function ()
                return Settings.GroupFoodDrinkBuff.enabled
            end,
            setFunction = function (value)
                Settings.GroupFoodDrinkBuff.enabled = value
                if UnitFrames.GroupFoodDrinkBuff then
                    UnitFrames.GroupFoodDrinkBuff.OnSettingsChanged()
                end
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.GroupFoodDrinkBuff.enabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Food/drink buff icons are only displayed on group frames (4-player groups). Raid frames do not have space for these icons.",
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_NO_BUFF),
            tooltip = "Display an icon when a group member has no food or drink buff active.",
            getFunction = function ()
                return Settings.GroupFoodDrinkBuff.showNoBuff
            end,
            setFunction = function (value)
                Settings.GroupFoodDrinkBuff.showNoBuff = value
                if UnitFrames.GroupFoodDrinkBuff then
                    UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
            end,
            default = Defaults.GroupFoodDrinkBuff.showNoBuff,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Remaining Time",
            tooltip = "Display countdown timer on food/drink buff icons showing time remaining (hours/minutes/seconds).",
            getFunction = function ()
                return Settings.GroupFoodDrinkBuff.showRemainingTime
            end,
            setFunction = function (value)
                Settings.GroupFoodDrinkBuff.showRemainingTime = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
            end,
            default = Defaults.GroupFoodDrinkBuff.showRemainingTime,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Use Custom Quality Icons",
            tooltip = "Use custom quality-based icons (green/blue/purple) instead of actual buff icons. Green = single stat, Blue = dual stat, Purple = triple stat.",
            getFunction = function ()
                return Settings.GroupFoodDrinkBuff.useCustomIcons
            end,
            setFunction = function (value)
                Settings.GroupFoodDrinkBuff.useCustomIcons = value
                if UnitFrames.GroupFoodDrinkBuff then
                    UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
            end,
            default = Defaults.GroupFoodDrinkBuff.useCustomIcons,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Group Frame Icon Size",
            tooltip = nil,
            min = 16,
            max = 32,
            step = 2,
            getFunction = function ()
                return Settings.GroupFoodDrinkBuff.iconSizeGroup
            end,
            setFunction = function (value)
                Settings.GroupFoodDrinkBuff.iconSizeGroup = value
                if UnitFrames.GroupFoodDrinkBuff then
                    UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                end
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
            end,
            default = Defaults.GroupFoodDrinkBuff.iconSizeGroup,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Group Frame Icon Offset X",
            tooltip = nil,
            min = -20,
            max = 20,
            step = 1,
            getFunction = function ()
                return Settings.GroupFoodDrinkBuff.iconOffsetXGroup
            end,
            setFunction = function (value)
                Settings.GroupFoodDrinkBuff.iconOffsetXGroup = value
                if UnitFrames.GroupFoodDrinkBuff then
                    UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                end
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
            end,
            default = Defaults.GroupFoodDrinkBuff.iconOffsetXGroup,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Group Frame Icon Offset Y",
            tooltip = nil,
            min = -20,
            max = 20,
            step = 1,
            getFunction = function ()
                return Settings.GroupFoodDrinkBuff.iconOffsetYGroup
            end,
            setFunction = function (value)
                Settings.GroupFoodDrinkBuff.iconOffsetYGroup = value
                if UnitFrames.GroupFoodDrinkBuff then
                    UnitFrames.GroupFoodDrinkBuff.RefreshFrames()
                end
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.GroupFoodDrinkBuff.enabled)
            end,
            default = Defaults.GroupFoodDrinkBuff.iconOffsetYGroup,
        }
    end)

    -- Build Custom Unit Frames (Companion) Options Section
    buildSectionSettings("CustomFramesCompanion", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_COMPANION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ENABLE_TP),
            getFunction = function ()
                return Settings.CustomFramesCompanion
            end,
            setFunction = function (value)
                Settings.CustomFramesCompanion = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomFramesCompanion,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatCompanion)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatCompanion = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutCompanion(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatCompanion),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_WIDTH),
            tooltip = nil,
            min = 100,
            max = 500,
            step = 5,
            getFunction = function ()
                return Settings.CompanionWidth
            end,
            setFunction = function (value)
                Settings.CompanionWidth = value
                UnitFrames.CustomFramesApplyLayoutCompanion(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_HEIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.CompanionHeight
            end,
            setFunction = function (value)
                Settings.CompanionHeight = value
                UnitFrames.CustomFramesApplyLayoutCompanion(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionHeight,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_COMPANION)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
            getFunction = function ()
                return Settings.CompanionEnableArmor
            end,
            setFunction = function (value)
                Settings.CompanionEnableArmor = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionEnableArmor,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_COMPANION)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
            getFunction = function ()
                return Settings.CompanionEnablePower
            end,
            setFunction = function (value)
                Settings.CompanionEnablePower = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionEnablePower,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_COMPANION)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
            getFunction = function ()
                return Settings.CompanionEnableRegen
            end,
            setFunction = function (value)
                Settings.CompanionEnableRegen = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionEnableRegen,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Combat Glow",
            tooltip = "Display a glow border around the companion health bar when the companion is in combat.",
            getFunction = function ()
                return Settings.CompanionCombatGlow
            end,
            setFunction = function (value)
                Settings.CompanionCombatGlow = value
                UnitFrames.UpdateCompanionCombatGlow()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionCombatGlow,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Combat Glow Color",
            tooltip = "Set the color of the combat glow border displayed around the companion frame.",
            getFunction = function ()
                return Settings.CompanionCombatGlowColor[1], Settings.CompanionCombatGlowColor[2], Settings.CompanionCombatGlowColor[3], Settings.CompanionCombatGlowColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.CompanionCombatGlowColor = { r, g, b, a }
                UnitFrames.UpdateCompanionCombatGlow()
            end,
            default = Defaults.CompanionCombatGlowColor,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion and Settings.CompanionCombatGlow)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_OOCPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_OOCPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.CompanionOocAlpha
            end,
            setFunction = function (value)
                Settings.CompanionOocAlpha = value
                UnitFrames.CustomFramesApplyCompanionInCombat(true)
                UnitFrames.CustomFramesApplyLayoutCompanion(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionOocAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ICPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ICPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.CompanionIncAlpha
            end,
            setFunction = function (value)
                Settings.CompanionIncAlpha = value
                UnitFrames.CustomFramesApplyCompanionInCombat(true)
                UnitFrames.CustomFramesApplyLayoutCompanion(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionIncAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_NAMECLIP),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_NAMECLIP_TP),
            min = 0,
            max = 200,
            step = 1,
            getFunction = function ()
                return Settings.CompanionNameClip
            end,
            setFunction = function (value)
                Settings.CompanionNameClip = value
                UnitFrames.CustomFramesApplyLayoutCompanion(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionNameClip,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_USE_CLASS_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_USE_CLASS_COLOR_TP),
            getFunction = function ()
                return Settings.CompanionUseClassColor
            end,
            setFunction = function (value)
                Settings.CompanionUseClassColor = value
                UnitFrames.CustomFramesApplyColorsMenuCompanionFrameOnly()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionUseClassColor,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_HEADER),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_ENABLE_TP),
            getFunction = function ()
                return Settings.CompanionAbilityTrack.enabled
            end,
            setFunction = function (value)
                Settings.CompanionAbilityTrack.enabled = value
                UnitFrames.CustomFramesApplyLayoutCompanion(false)
                if UnitFrames.companionAbilityTrack then
                    UnitFrames.companionAbilityTrack:RefreshAll()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionAbilityTrack.enabled,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_ICON_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_ICON_SIZE_TP),
            min = 16,
            max = 40,
            step = 1,
            getFunction = function ()
                return Settings.CompanionAbilityTrack.iconSize
            end,
            setFunction = function (value)
                Settings.CompanionAbilityTrack.iconSize = value
                UnitFrames.CustomFramesApplyLayoutCompanion(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion and Settings.CompanionAbilityTrack.enabled)
            end,
            default = Defaults.CompanionAbilityTrack.iconSize,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_SHOW_EFFECT),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_SHOW_EFFECT_TP),
            getFunction = function ()
                return Settings.CompanionAbilityTrack.showEffectTimer
            end,
            setFunction = function (value)
                Settings.CompanionAbilityTrack.showEffectTimer = value
                if UnitFrames.companionAbilityTrack then
                    UnitFrames.companionAbilityTrack:RefreshAll()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion and Settings.CompanionAbilityTrack.enabled)
            end,
            default = Defaults.CompanionAbilityTrack.showEffectTimer,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_SHOW_STACKS),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_ABILITIES_SHOW_STACKS_TP),
            getFunction = function ()
                return Settings.CompanionAbilityTrack.showStacks
            end,
            setFunction = function (value)
                Settings.CompanionAbilityTrack.showStacks = value
                if UnitFrames.companionAbilityTrack then
                    UnitFrames.companionAbilityTrack:RefreshAll()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion and Settings.CompanionAbilityTrack.enabled)
            end,
            default = Defaults.CompanionAbilityTrack.showStacks,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_RAPPORT_FLOURISH),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_RAPPORT_FLOURISH_TP),
            getFunction = function ()
                return Settings.CompanionRapportFlourish.enabled
            end,
            setFunction = function (value)
                Settings.CompanionRapportFlourish.enabled = value
                if not value and UnitFrames.companionRapportFlourish then
                    UnitFrames.companionRapportFlourish:StopFlourish()
                end
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesCompanion)
            end,
            default = Defaults.CompanionRapportFlourish.enabled,
        }
    end)

    -- Build Custom Unit Frames (Pet) Options Section
    buildSectionSettings("CustomFramesPet", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_PET),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ENABLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ENABLE_TP),
            getFunction = function ()
                return Settings.CustomFramesPet
            end,
            setFunction = function (value)
                Settings.CustomFramesPet = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomFramesPet,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatPet)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatPet = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
                UnitFrames.CustomFramesApplyLayoutPet(false)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatPet),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_WIDTH),
            tooltip = nil,
            min = 100,
            max = 500,
            step = 5,
            getFunction = function ()
                return Settings.PetWidth
            end,
            setFunction = function (value)
                Settings.PetWidth = value
                UnitFrames.CustomFramesApplyLayoutPet(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_HEIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.PetHeight
            end,
            setFunction = function (value)
                Settings.PetHeight = value
                UnitFrames.CustomFramesApplyLayoutPet(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetHeight,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PET)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
            getFunction = function ()
                return Settings.PetEnableArmor
            end,
            setFunction = function (value)
                Settings.PetEnableArmor = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetEnableArmor,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PET)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
            getFunction = function ()
                return Settings.PetEnablePower
            end,
            setFunction = function (value)
                Settings.PetEnablePower = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetEnablePower,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_CFRAMES_APPEARANCE_PET)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
            getFunction = function ()
                return Settings.PetEnableRegen
            end,
            setFunction = function (value)
                Settings.PetEnableRegen = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetEnableRegen,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Show Combat Glow",
            tooltip = "Display a glow border around pet health bars when the pet is in combat.",
            getFunction = function ()
                return Settings.PetCombatGlow
            end,
            setFunction = function (value)
                Settings.PetCombatGlow = value
                UnitFrames.UpdatePetCombatGlow()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetCombatGlow,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = "    Combat Glow Color",
            tooltip = "Set the color of the combat glow border displayed around pet frames.",
            getFunction = function ()
                return Settings.PetCombatGlowColor[1], Settings.PetCombatGlowColor[2], Settings.PetCombatGlowColor[3], Settings.PetCombatGlowColor[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.PetCombatGlowColor = { r, g, b, a }
                UnitFrames.UpdatePetCombatGlow()
            end,
            default = Defaults.PetCombatGlowColor,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet and Settings.PetCombatGlow)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_OOCPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_OOCPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.PetOocAlpha
            end,
            setFunction = function (value)
                Settings.PetOocAlpha = value
                UnitFrames.CustomFramesApplyPetInCombat(true)
                UnitFrames.CustomFramesApplyLayoutPet(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetOocAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ICPACITY),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_ICPACITY_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.PetIncAlpha
            end,
            setFunction = function (value)
                Settings.PetIncAlpha = value
                UnitFrames.CustomFramesApplyPetInCombat(true)
                UnitFrames.CustomFramesApplyLayoutPet(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetIncAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_NAMECLIP),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_NAMECLIP_TP),
            min = 0,
            max = 200,
            step = 1,
            getFunction = function ()
                return Settings.PetNameClip
            end,
            setFunction = function (value)
                Settings.PetNameClip = value
                UnitFrames.CustomFramesApplyLayoutPet(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetNameClip,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_USE_CLASS_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPET_USE_CLASS_COLOR_TP),
            getFunction = function ()
                return Settings.PetUseClassColor
            end,
            setFunction = function (value)
                Settings.PetUseClassColor = value
                UnitFrames.CustomFramesApplyColorsMenuPetFramesOnly()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesPet)
            end,
            default = Defaults.PetUseClassColor,
        }
    end)

    -- Build Pet Whitelist Section
    buildSectionSettings("PetWhitelist", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_PET_WHITELIST),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_BLACKLIST_DESCRIPT),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_NECROMANCER),
            tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_NECROMANCER_TP),
            clickHandler = function ()
                UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Necromancer)
                SettingsAPI:RefreshPanel(panel)
                UnitFrames.CustomPetUpdate()
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PET_WHITELIST")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_NECROMANCER),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SORCERER),
            tooltip = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SORCERER_TP),
            clickHandler = function ()
                UnitFrames.AddBulkToCustomList(Settings.whitelist, PetNames.Sorcerer)
                SettingsAPI:RefreshPanel(panel)
                UnitFrames.CustomPetUpdate()
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_PET_WHITELIST")
            end,
            buttonText = GetString(LUIE_STRING_LAM_UF_WHITELIST_ADD_SORCERER),
        }

        -- Store temp text for adding items
        if not Settings.tempWhitelistText then
            Settings.tempWhitelistText = ""
        end

        -- Add Item edit box
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunction = function ()
                return Settings.tempWhitelistText or ""
            end,
            setFunction = function (value)
                Settings.tempWhitelistText = value
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        -- Add Item button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            clickHandler = function ()
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
                    SettingsAPI:RefreshPanel(panel)
                end
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        -- Manage Pet Whitelist
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST),
            tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_DESCRIPT),
            clickHandler = function ()
                if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_PET_WHITELIST"] then
                    LUIE.ShowBlacklistDialog("LUIE_MANAGE_PET_WHITELIST")
                end
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            buttonText = GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST),
        }
    end)

    -- Build Custom Unit Frames (Boss) Options Section
    buildSectionSettings("CustomFramesBoss", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESB_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure custom frames for boss and elite enemy encounters, showing health, shields, and important mechanics information.",
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESB_LUIEFRAMESENABLE),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESB_LUIEFRAMESENABLE_TP),
            getFunction = function ()
                return Settings.CustomFramesBosses
            end,
            setFunction = function (value)
                Settings.CustomFramesBosses = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.CustomFramesBosses,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_LABEL_TP),
            items = formatDropdownItems,
            getFunction = function ()
                return formatDropdownGetData(Settings.CustomFormatBoss)
            end,
            setFunction = function (combobox, value, item)
                Settings.CustomFormatBoss = item.data or item.name or value
                UnitFrames.CustomFramesFormatLabels(true)
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.CustomFormatBoss),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESB_WIDTH),
            tooltip = nil,
            min = 100,
            max = 500,
            step = 5,
            getFunction = function ()
                return Settings.BossBarWidth
            end,
            setFunction = function (value)
                Settings.BossBarWidth = value
                UnitFrames.CustomFramesApplyLayoutBosses(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossBarWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESB_HEIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.BossBarHeight
            end,
            setFunction = function (value)
                Settings.BossBarHeight = value
                UnitFrames.CustomFramesApplyLayoutBosses(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossBarHeight,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Boss Frame Vertical Spacing",
            tooltip = "Vertical spacing between boss frames.",
            min = 0,
            max = 20,
            step = 1,
            getFunction = function ()
                return Settings.BossBarSpacing
            end,
            setFunction = function (value)
                Settings.BossBarSpacing = value
                UnitFrames.CustomFramesApplyLayoutBosses(false)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossBarSpacing,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESB_OPACITYOOC),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESB_OPACITYOOC_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.BossOocAlpha
            end,
            setFunction = function (value)
                Settings.BossOocAlpha = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossOocAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESB_OPACITYIC),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESB_OPACITYIC_TP),
            min = 0,
            max = 100,
            step = 5,
            getFunction = function ()
                return Settings.BossIncAlpha
            end,
            setFunction = function (value)
                Settings.BossIncAlpha = value
                UnitFrames.CustomFramesApplyInCombat(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossIncAlpha,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR), GetString(LUIE_STRING_LAM_UF_SHARED_BOSS)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_ARMOR_TP),
            getFunction = function ()
                return Settings.BossEnableArmor
            end,
            setFunction = function (value)
                Settings.BossEnableArmor = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossEnableArmor,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_POWER), GetString(LUIE_STRING_LAM_UF_SHARED_BOSS)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_POWER_TP),
            getFunction = function ()
                return Settings.BossEnablePower
            end,
            setFunction = function (value)
                Settings.BossEnablePower = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossEnablePower,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_REGEN), GetString(LUIE_STRING_LAM_UF_SHARED_BOSS)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_REGEN_TP),
            getFunction = function ()
                return Settings.BossEnableRegen
            end,
            setFunction = function (value)
                Settings.BossEnableRegen = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossEnableRegen,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat(GetString(LUIE_STRING_LAM_UF_SHARED_THRESHOLDS), GetString(LUIE_STRING_LAM_UF_SHARED_BOSS)),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHARED_THRESHOLDS_TP),
            getFunction = function ()
                return Settings.BossShowThresholdMarkers
            end,
            setFunction = function (value)
                Settings.BossShowThresholdMarkers = value
                UnitFrames.UpdateBossThresholds()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses)
            end,
            default = Defaults.BossShowThresholdMarkers,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Threshold Label X Offset",
            tooltip = "Horizontal nudge applied to both the top percent label and the bottom mechanic-name label.",
            min = -100,
            max = 100,
            step = 1,
            getFunction = function ()
                return Settings.BossThresholdLabelOffsetX
            end,
            setFunction = function (value)
                Settings.BossThresholdLabelOffsetX = value
                UnitFrames.UpdateBossThresholds()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses and Settings.BossShowThresholdMarkers)
            end,
            default = Defaults.BossThresholdLabelOffsetX,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = "Threshold Label Y Padding",
            tooltip = "Padding away from the boss stack. Top percent labels are pushed up by this many pixels and bottom rotated mechanic-name labels are pushed down by the same amount.",
            min = -100,
            max = 100,
            step = 1,
            getFunction = function ()
                return Settings.BossThresholdLabelOffsetY
            end,
            setFunction = function (value)
                Settings.BossThresholdLabelOffsetY = value
                UnitFrames.UpdateBossThresholds()
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.CustomFramesBosses and Settings.BossShowThresholdMarkers)
            end,
            default = Defaults.BossThresholdLabelOffsetY,
        }
    end)

    -- Build Custom Unit Frames (PvP Target Frame) Options Section
    buildSectionSettings("CustomFramesPvP", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = "Configure custom frames for PvP environments (Cyrodiil, Imperial City, Battlegrounds) with player-specific display options.",
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_TARGETFRAME),
            tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_TARGETFRAME_TP),
            getFunction = function ()
                return Settings.AvaCustFramesTarget
            end,
            setFunction = function (value)
                Settings.AvaCustFramesTarget = value
            end,
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.AvaCustFramesTarget,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_TARGETFRAME_WIDTH),
            tooltip = nil,
            min = 300,
            max = 700,
            step = 5,
            getFunction = function ()
                return Settings.AvaTargetBarWidth
            end,
            setFunction = function (value)
                Settings.AvaTargetBarWidth = value
                UnitFrames.CustomFramesApplyLayoutAvaPlayerTargetFrame(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.AvaCustFramesTarget)
            end,
            default = Defaults.AvaTargetBarWidth,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_TARGETFRAME_HEIGHT),
            tooltip = nil,
            min = 20,
            max = 70,
            step = 1,
            getFunction = function ()
                return Settings.AvaTargetBarHeight
            end,
            setFunction = function (value)
                Settings.AvaTargetBarHeight = value
                UnitFrames.CustomFramesApplyLayoutAvaPlayerTargetFrame(true)
            end,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.AvaCustFramesTarget)
            end,
            default = Defaults.AvaTargetBarHeight,
        }
    end)

    -- Build Common Options Section
    buildSectionSettings("CommonOptions", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_UF_COMMON_GLOBAL),
        }

        -- Add common global settings (ReloadUI, etc.)
        for i = 1, #commonGlobalSettings do
            settings[#settings + 1] = commonGlobalSettings[i]
        end

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_SHORTNUMBERS),
            tooltip = GetString(LUIE_STRING_LAM_UF_SHORTNUMBERS_TP),
            getFunction = function ()
                return Settings.ShortenNumbers
            end,
            setFunction = function (value)
                Settings.ShortenNumbers = value
                UnitFrames.CustomFramesFormatLabels(true)
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.ShortenNumbers,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_CAPTIONCOLOR),
            tooltip = nil,
            getFunction = function ()
                return Settings.Target_FontColour[1], Settings.Target_FontColour[2], Settings.Target_FontColour[3], Settings.Target_FontColour[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Target_FontColour = { r, g, b, a }
            end,
            default = Defaults.Target_FontColour,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_NPCFONTCOLOR),
            tooltip = nil,
            getFunction = function ()
                return Settings.Target_FontColour_FriendlyNPC[1], Settings.Target_FontColour_FriendlyNPC[2], Settings.Target_FontColour_FriendlyNPC[3], Settings.Target_FontColour_FriendlyNPC[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Target_FontColour_FriendlyNPC = { r, g, b, a }
            end,
            default = Defaults.Target_FontColour_FriendlyNPC,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_PLAYERFONTCOLOR),
            tooltip = nil,
            getFunction = function ()
                return Settings.Target_FontColour_FriendlyPlayer[1], Settings.Target_FontColour_FriendlyPlayer[2], Settings.Target_FontColour_FriendlyPlayer[3], Settings.Target_FontColour_FriendlyPlayer[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Target_FontColour_FriendlyPlayer = { r, g, b, a }
            end,
            default = Defaults.Target_FontColour_FriendlyPlayer,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_HOSTILEFONTCOLOR),
            tooltip = nil,
            getFunction = function ()
                return Settings.Target_FontColour_Hostile[1], Settings.Target_FontColour_Hostile[2], Settings.Target_FontColour_Hostile[3], Settings.Target_FontColour_Hostile[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Target_FontColour_Hostile = { r, g, b, a }
            end,
            default = Defaults.Target_FontColour_Hostile,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_NEUTRAL_FONT_COLOR),
            tooltip = nil,
            getFunction = function ()
                return Settings.Target_FontColour_Neutral[1], Settings.Target_FontColour_Neutral[2], Settings.Target_FontColour_Neutral[3], Settings.Target_FontColour_Neutral[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.Target_FontColour_Neutral = { r, g, b, a }
            end,
            default = Defaults.Target_FontColour_Neutral,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = "Neutral Use Default Color",
            tooltip = "Use default caption color for neutral units instead of the neutral font color.",
            getFunction = function ()
                return Settings.Target_Neutral_UseDefaultColour
            end,
            setFunction = function (value)
                Settings.Target_Neutral_UseDefaultColour = value
            end,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.Target_Neutral_UseDefaultColour,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_RETICLECOLOR),
            tooltip = GetString(LUIE_STRING_LAM_UF_COMMON_RETICLECOLOR_TP),
            getFunction = function ()
                return Settings.ReticleColourByReaction
            end,
            setFunction = UnitFrames.ReticleColorByReaction,
            disable = function ()
                return not LUIE.SV.UnitFrames_Enabled
            end,
            default = Defaults.ReticleColourByReaction,
        }
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_UF_COMMON_RETICLECOLORINTERACT),
            tooltip = nil,
            getFunction = function ()
                return Settings.ReticleColour_Interact[1], Settings.ReticleColour_Interact[2], Settings.ReticleColour_Interact[3], Settings.ReticleColour_Interact[4]
            end,
            setFunction = function (r, g, b, a)
                Settings.ReticleColour_Interact = { r, g, b, a }
            end,
            default = Defaults.ReticleColour_Interact,
            disable = function ()
                return not (LUIE.SV.UnitFrames_Enabled and Settings.ReticleColourByReaction)
            end,
        }
    end)

    local allSettings = {}
    SettingsAPI:AppendSettingsList(allSettings, initialSettings)
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_COMMON_HEADER), sectionGroups["CommonOptions"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_DFRAMES_HEADER), sectionGroups["DefaultFrames"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMES_HEADER), sectionGroups["CustomFrames"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMES_FONT_TEXTURE_HEADER), sectionGroups["CustomFramesFontTexture"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMES_COLOR_HEADER), sectionGroups["CustomFramesColor"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESPLAYER_HEADER), sectionGroups["CustomFramesPlayer"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESTARGET_HEADER), sectionGroups["CustomFramesTarget"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMES_POSITIONS_HEADER), sectionGroups["CustomFramesPositions"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMES_ALIGN_HEADER), sectionGroups["CustomFramesBarAlignment"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESPT_OPTIONS_HEADER), sectionGroups["CustomFramesPlayerTargetOptions"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESG_HEADER), sectionGroups["CustomFramesGroup"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESR_HEADER), sectionGroups["CustomFramesRaid"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_GROUP_RESOURCES_HEADER), sectionGroups["GroupResources"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_GROUP_COMBAT_STATS_HEADER), sectionGroups["GroupCombatStats"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_GROUP_POTION_HEADER), sectionGroups["GroupPotionCooldowns"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_GROUP_FOODDRINK_HEADER), sectionGroups["GroupFoodDrinkBuff"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESCOMPANION_HEADER), sectionGroups["CustomFramesCompanion"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESPET_HEADER), sectionGroups["CustomFramesPet"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_CUSTOM_LIST_UF_WHITELIST), sectionGroups["PetWhitelist"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESB_HEADER), sectionGroups["CustomFramesBoss"])
    SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_CFRAMESPVP_HEADER), sectionGroups["CustomFramesPvP"])
    panel:AddSettings(allSettings)
end
