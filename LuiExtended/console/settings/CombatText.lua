-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- Load Console Settings API
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) LuiExtended.CombatText
local CombatText = LUIE.CombatText
local CombatTextConstants = LuiData.Data.CombatTextConstants
local BlacklistPresets = LuiData.Data.CombatTextBlacklistPresets

local LHAS = LibHarvensAddonSettings

local type, pairs = type, pairs
local zo_strformat = zo_strformat

local animationTypeLabels =
{
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_CLOUD),
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_HYBRID),
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_SCROLL),
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_ELLIPSE),
}
local directionTypeLabels =
{
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_UP),
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_DOWN),
}
local iconSideLabels =
{
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_ICON_NONE),
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_ICON_LEFT),
    GetString(LUIE_STRING_LAM_CT_ANIM_VALUE_ICON_RIGHT),
}

local animationTypeDropdownItems = {}
for itemIndex = 1, #CombatTextConstants.animationType do
    animationTypeDropdownItems[itemIndex] =
    {
        name = animationTypeLabels[itemIndex],
        data = CombatTextConstants.animationType[itemIndex],
    }
end

local directionTypeDropdownItems = {}
for itemIndex = 1, #CombatTextConstants.directionType do
    directionTypeDropdownItems[itemIndex] =
    {
        name = directionTypeLabels[itemIndex],
        data = CombatTextConstants.directionType[itemIndex],
    }
end

local iconSideDropdownItems = {}
for itemIndex = 1, #CombatTextConstants.iconSide do
    iconSideDropdownItems[itemIndex] =
    {
        name = iconSideLabels[itemIndex],
        data = CombatTextConstants.iconSide[itemIndex],
    }
end

-- Convert to LHAS format {name, data}
local function GenerateCustomListLHAS(input)
    local items = {}
    local counter = 0
    for id in pairs(input) do
        counter = counter + 1
        local displayName
        if type(id) == "number" then
            displayName = zo_iconFormat(GetAbilityIcon(id), 16, 16) .. " [" .. id .. "] " .. zo_strformat("<<C:1>>", GetAbilityName(id))
        else
            displayName = id
        end
        items[counter] = { name = displayName, data = id }
    end
    return items
end

function CombatText.CreateConsoleSettings()
    local Defaults = CombatText.Defaults
    local Settings = CombatText.SV

    -- Register the settings panel
    if not LUIE.SV.CombatText_Enabled then
        return
    end

    -- Register custom blacklist management dialog
    LUIE.RegisterBlacklistDialog(
        "LUIE_MANAGE_CT_BLACKLIST",
        GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER),
        function ()
            return GenerateCustomListLHAS(Settings.blacklist)
        end,
        function (itemData)
            CombatText.RemoveFromCustomList(Settings.blacklist, itemData)
        end,
        function (text)
            CombatText.AddToCustomList(Settings.blacklist, text)
        end,
        function ()
            CombatText.ClearCustomList(Settings.blacklist)
        end
    )

    -- Get font list from SettingsAPI
    local fontItems = SettingsAPI:GetFontsList()

    -- Build font style list once for reuse
    local fontStyleItems = {}
    for i, styleName in ipairs(LUIE.FONT_STYLE_CHOICES) do
        fontStyleItems[i] = { name = styleName, data = LUIE.FONT_STYLE_CHOICES_VALUES[i] }
    end

    -- Create the addon settings panel
    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_CT),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        -- Reset all panel positions to defaults
                                        CombatText.ResetPanelPositions()
                                    end,
                                })

    LUIE.RegisterDialogueButton(
        "LUIE_CLEAR_CT_BLACKLIST",
        GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
        zo_strformat(GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_DIALOG), GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER)),
        function ()
            CombatText.ClearCustomList(CombatText.SV.blacklist)
            SettingsAPI:RefreshPanel(panel)
        end
    )

    -- Collect initial settings for main menu
    local initialSettings = {}

    -- Combat Text Description
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_CT_DESCRIPTION)
    }

    -- ReloadUI Button
    initialSettings[#initialSettings + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        clickHandler = function ()
            -- Lock all panels before reloading
            for k, _ in pairs(Settings.panels) do
                _G[k]:SetMouseEnabled(false)
                _G[k]:SetMovable(false)
                _G[k .. "_Backdrop"]:SetHidden(true)
                _G[k .. "_Label"]:SetHidden(true)
                local prev = _G[k .. "_Preview"]
                if prev then
                    prev:SetHidden(true)
                end
            end
            -- Reset the unlocked state
            Settings.unlocked = false
            SettingsAPI:ReloadUIWithPendingClear()
        end
    }

    initialSettings[#initialSettings + 1] = SettingsAPI:ConsoleFontDeferLabelSetting()

    local sectionGroups = {}

    -- Helper function to build section settings
    local function buildSectionSettings(sectionName, settingsBuilder)
        local sectionSettings = {}
        settingsBuilder(sectionSettings)
        sectionGroups[sectionName] = sectionSettings
    end

    -- Panel layout (unlock + position sliders)
    buildSectionSettings("PanelLayout", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_POSITIONS_TP),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_UNLOCK),
            tooltip = GetString(LUIE_STRING_LAM_CT_UNLOCK_TP),
            getFunction = function () return Settings.unlocked end,
            setFunction = function (value)
                CombatText.SetMovingState(value)
            end,
            default = Defaults.unlocked
        }

        -- Slider range: max offset of panel CENTER from screen CENTER while the panel stays on-screen
        -- (same idea as ZO_ReanchorControlForLeftSidePanel: layout uses screen size minus control size).
        local gw = GuiRoot:GetWidth()
        local gh = GuiRoot:GetHeight()
        local combatTextPanelSliderTargets =
        {
            { "LUIE_CombatText_Outgoing", GetString(LUIE_STRING_CT_PANEL_OUTGOING) },
            { "LUIE_CombatText_Incoming", GetString(LUIE_STRING_CT_PANEL_INCOMING) },
            { "LUIE_CombatText_Alert",    GetString(LUIE_STRING_CT_PANEL_ALERT)    },
            { "LUIE_CombatText_Point",    GetString(LUIE_STRING_CT_PANEL_POINT)    },
            { "LUIE_CombatText_Resource", GetString(LUIE_STRING_CT_PANEL_RESOURCE) },
        }

        for cj = 1, #combatTextPanelSliderTargets do
            local ck = combatTextPanelSliderTargets[cj][1]
            local dim = Settings.panels[ck] and Settings.panels[ck].dimensions
            local defDim = Defaults.panels[ck].dimensions
            local cw = (dim and dim[1]) or defDim[1]
            local ch = (dim and dim[2]) or defDim[2]
            local cmaxX = zo_max(0, (gw - cw) / 2)
            local cmaxY = zo_max(0, (gh - ch) / 2)
            if Settings.panels[ck] then
                local ox = zo_clamp(Settings.panels[ck].offsetX, -cmaxX, cmaxX)
                local oy = zo_clamp(Settings.panels[ck].offsetY, -cmaxY, cmaxY)
                if ox ~= Settings.panels[ck].offsetX or oy ~= Settings.panels[ck].offsetY then
                    Settings.panels[ck].offsetX = ox
                    Settings.panels[ck].offsetY = oy
                    CombatText.ReanchorPanelFromSaved(ck)
                    local cp = _G[ck]
                    if cp then
                        CombatText.SavePosition(cp)
                    end
                end
            end
        end

        for psi = 1, #combatTextPanelSliderTargets do
            local panelKey = combatTextPanelSliderTargets[psi][1]
            local panelTitle = combatTextPanelSliderTargets[psi][2]
            local dim = Settings.panels[panelKey] and Settings.panels[panelKey].dimensions
            local defDim = Defaults.panels[panelKey].dimensions
            local pw = (dim and dim[1]) or defDim[1]
            local ph = (dim and dim[2]) or defDim[2]
            local maxOffsetX = zo_max(0, (gw - pw) / 2)
            local maxOffsetY = zo_max(0, (gh - ph) / 2)

            settings[#settings + 1] =
            {
                type = LHAS.ST_LABEL,
                label = panelTitle,
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_SLIDER,
                label = zo_strformat("<<1>> — <<2>>", panelTitle, GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X_TP),
                min = -maxOffsetX,
                max = maxOffsetX,
                step = 10,
                format = "%.0f",
                getFunction = function ()
                    CombatText.MigratePanelSaveToCenter(panelKey)
                    return zo_clamp(Settings.panels[panelKey].offsetX, -maxOffsetX, maxOffsetX)
                end,
                setFunction = function (value)
                    CombatText.MigratePanelSaveToCenter(panelKey)
                    value = zo_clamp(value, -maxOffsetX, maxOffsetX)
                    Settings.panels[panelKey].offsetX = value
                    Settings.panels[panelKey].point = CENTER
                    Settings.panels[panelKey].relativePoint = CENTER
                    Settings.panels[panelKey].x = nil
                    Settings.panels[panelKey].y = nil
                    CombatText.ReanchorPanelFromSaved(panelKey)
                    local p = _G[panelKey]
                    if p then
                        CombatText.SavePosition(p)
                    end
                end,
                default = Defaults.panels[panelKey].offsetX,
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_SLIDER,
                label = zo_strformat("<<1>> — <<2>>", panelTitle, GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y)),
                tooltip = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y_TP),
                min = -maxOffsetY,
                max = maxOffsetY,
                step = 10,
                format = "%.0f",
                getFunction = function ()
                    CombatText.MigratePanelSaveToCenter(panelKey)
                    return zo_clamp(Settings.panels[panelKey].offsetY, -maxOffsetY, maxOffsetY)
                end,
                setFunction = function (value)
                    CombatText.MigratePanelSaveToCenter(panelKey)
                    value = zo_clamp(value, -maxOffsetY, maxOffsetY)
                    Settings.panels[panelKey].offsetY = value
                    Settings.panels[panelKey].point = CENTER
                    Settings.panels[panelKey].relativePoint = CENTER
                    Settings.panels[panelKey].x = nil
                    Settings.panels[panelKey].y = nil
                    CombatText.ReanchorPanelFromSaved(panelKey)
                    local p = _G[panelKey]
                    if p then
                        CombatText.SavePosition(p)
                    end
                end,
                default = Defaults.panels[panelKey].offsetY,
            }
        end
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
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CT_COMMON),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_IC_ONLY),
            tooltip = GetString(LUIE_STRING_LAM_CT_IC_ONLY_TP),
            getFunction = function () return Settings.toggles.inCombatOnly end,
            setFunction = function (v) Settings.toggles.inCombatOnly = v end,
            default = Defaults.toggles.inCombatOnly
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_SHARED_OOC_OPACITY),
            tooltip = GetString(LUIE_STRING_LAM_CT_OOC_TRANSPARENCY_TP),
            min = 0,
            max = 100,
            step = 5,
            format = "%.0f",
            getFunction = function () return Settings.common.oocAlpha end,
            setFunction = function (v) Settings.common.oocAlpha = v end,
            default = Defaults.common.oocAlpha
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_SHARED_IC_OPACITY),
            tooltip = GetString(LUIE_STRING_LAM_CT_IC_TRANSPARENCY_TP),
            min = 0,
            max = 100,
            step = 5,
            format = "%.0f",
            getFunction = function () return Settings.common.incAlpha end,
            setFunction = function (v) Settings.common.incAlpha = v end,
            default = Defaults.common.incAlpha
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_OVERKILL),
            tooltip = GetString(LUIE_STRING_LAM_CT_OVERKILL_TP),
            getFunction = function () return Settings.common.overkill end,
            setFunction = function (v) Settings.common.overkill = v end,
            default = Defaults.common.overkill
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_OVERHEAL),
            tooltip = GetString(LUIE_STRING_LAM_CT_OVERHEAL_TP),
            getFunction = function () return Settings.common.overheal end,
            setFunction = function (v) Settings.common.overheal = v end,
            default = Defaults.common.overheal
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_ABBREVIATE),
            tooltip = GetString(LUIE_STRING_LAM_CT_ABBREVIATE_TP),
            getFunction = function () return Settings.common.abbreviateNumbers end,
            setFunction = function (v) Settings.common.abbreviateNumbers = v end,
            default = Defaults.common.abbreviateNumbers
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_TP),
            getFunction = function () return Settings.common.useDefaultIcon end,
            setFunction = function (newValue) Settings.common.useDefaultIcon = newValue end,
            default = Defaults.common.useDefaultIcon
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS),
            tooltip = GetString(LUIE_STRING_LAM_CI_CCT_DEFAULT_ICON_OPTIONS_TP),
            items = SettingsAPI:GetGlobalIconOptionsList(),
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(SettingsAPI:NormalizeGlobalIconOptionIndex(Settings.common.defaultIconOptions, Defaults.common.defaultIconOptions))
            end,
            setFunction = function (combobox, value, item)
                Settings.common.defaultIconOptions = item.data or 1
            end,
            disable = function () return not Settings.common.useDefaultIcon end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.common.defaultIconOptions)
        }
    end)

    -- Build Blacklist Section
    buildSectionSettings("Blacklist", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_DESCRIPT)
        }

        -- Blacklist preset buttons
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SETS),
            tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SETS_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SETS),
            clickHandler = function ()
                CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Sets)
                SettingsAPI:RefreshPanel(panel)
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SORCERER),
            tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SORCERER_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_SORCERER),
            clickHandler = function ()
                CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Sorcerer)
                SettingsAPI:RefreshPanel(panel)
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_TEMPLAR),
            tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_TEMPLAR_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_TEMPLAR),
            clickHandler = function ()
                CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Templar)
                SettingsAPI:RefreshPanel(panel)
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_WARDEN),
            tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_WARDEN_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_WARDEN),
            clickHandler = function ()
                CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Warden)
                SettingsAPI:RefreshPanel(panel)
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NECROMANCER),
            tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NECROMANCER_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NECROMANCER),
            clickHandler = function ()
                CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Necromancer)
                SettingsAPI:RefreshPanel(panel)
                -- Refresh dialog if open
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_DRAGONKNIGHT),
            tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_DRAGONKNIGHT_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_DRAGONKNIGHT),
            clickHandler = function ()
                CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Dragonknight)
                SettingsAPI:RefreshPanel(panel)
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NIGHTBLADE),
            tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NIGHTBLADE_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_NIGHTBLADE),
            clickHandler = function ()
                CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Nightblade)
                SettingsAPI:RefreshPanel(panel)
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_ARCANIST),
            tooltip = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_ARCANIST_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_ADD_ARCANIST),
            clickHandler = function ()
                CombatText.AddBulkToCustomList(Settings.blacklist, BlacklistPresets.Arcanist)
                SettingsAPI:RefreshPanel(panel)
                LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
            end
        }

        -- Store temp text for adding items
        if not Settings.tempBlacklistText then
            Settings.tempBlacklistText = ""
        end

        -- Add Item edit box
        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            getFunction = function ()
                return Settings.tempBlacklistText or ""
            end,
            setFunction = function (value)
                Settings.tempBlacklistText = value
            end
        }

        -- Add Item button
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST_TP),
            buttonText = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_ADDLIST),
            clickHandler = function ()
                local text = Settings.tempBlacklistText or ""
                if text and text ~= "" then
                    CombatText.AddToCustomList(Settings.blacklist, text)
                    Settings.tempBlacklistText = ""
                    -- Refresh the blacklist dialog if it's open
                    if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_CT_BLACKLIST"] then
                        LUIE.RefreshBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
                    end
                    -- Refresh settings to clear the edit box
                    SettingsAPI:RefreshPanel(panel)
                end
            end
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            tooltip = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR_TP),
            buttonText = GetString(LUIE_STRING_LAM_UF_BLACKLIST_CLEAR),
            clickHandler = function () ZO_Dialogs_ShowGamepadDialog("LUIE_CLEAR_CT_BLACKLIST") end
        }

        -- Manage Blacklist
        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER),
            tooltip = GetString(LUIE_STRING_LAM_BUFF_BLACKLIST_REMLIST_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER),
            clickHandler = function ()
                if LUIE.BlacklistDialogs and LUIE.BlacklistDialogs["LUIE_MANAGE_CT_BLACKLIST"] then
                    LUIE.ShowBlacklistDialog("LUIE_MANAGE_CT_BLACKLIST")
                end
            end
        }
    end)

    -- Build Damage & Healing Options Section
    buildSectionSettings("DamageHealing", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_DAMAGE_AND_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DAMAGE_TP),
            getFunction = function () return Settings.toggles.incoming.showDamage end,
            setFunction = function (v) Settings.toggles.incoming.showDamage = v end,
            default = Defaults.toggles.incoming.showDamage
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DAMAGE_TP),
            getFunction = function () return Settings.toggles.outgoing.showDamage end,
            setFunction = function (v) Settings.toggles.outgoing.showDamage = v end,
            default = Defaults.toggles.outgoing.showDamage
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DAMAGE_TP),
            getFunction = function () return CombatText.GetFormat("damage") end,
            setFunction = function (v) CombatText.SetFormat("damage", v) end,
            default = Defaults.formats.damage
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DAMAGE_CRITICAL_TP),
            getFunction = function () return CombatText.GetFormat("damagecritical") end,
            setFunction = function (v) CombatText.SetFormat("damagecritical", v) end,
            default = Defaults.formats.damagecritical
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DAMAGE_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.damage end,
            setFunction = function (size) Settings.fontSizes.damage = size end,
            default = Defaults.fontSizes.damage
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DAMAGE_CRITICAL_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.damagecritical end,
            setFunction = function (size) Settings.fontSizes.damagecritical = size end,
            default = Defaults.fontSizes.damagecritical
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_DOT)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DOT_TP),
            getFunction = function () return Settings.toggles.incoming.showDot end,
            setFunction = function (v) Settings.toggles.incoming.showDot = v end,
            default = Defaults.toggles.incoming.showDot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DOT_TP),
            getFunction = function () return Settings.toggles.outgoing.showDot end,
            setFunction = function (v) Settings.toggles.outgoing.showDot = v end,
            default = Defaults.toggles.outgoing.showDot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DOT_TP),
            getFunction = function () return CombatText.GetFormat("dot") end,
            setFunction = function (v) CombatText.SetFormat("dot", v) end,
            default = Defaults.formats.dot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DOT_CRITICAL_TP),
            getFunction = function () return CombatText.GetFormat("dotcritical") end,
            setFunction = function (v) CombatText.SetFormat("dotcritical", v) end,
            default = Defaults.formats.dotcritical
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DOT_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.dot end,
            setFunction = function (size) Settings.fontSizes.dot = size end,
            default = Defaults.fontSizes.dot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_DOT_CRITICAL_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.dotcritical end,
            setFunction = function (size) Settings.fontSizes.dotcritical = size end,
            default = Defaults.fontSizes.dotcritical
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_HEADER_DAMAGE_COLOR)
        }

        -- Damage color pickers
        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_NONE),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_NONE_TP),
            getFunction = function () return Settings.colors.damage[0][1], Settings.colors.damage[0][2], Settings.colors.damage[0][3], Settings.colors.damage[0][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[0] = { r, g, b, a } end,
            default = Defaults.colors.damage[0]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_GENERIC),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_GENERIC_TP),
            getFunction = function () return Settings.colors.damage[1][1], Settings.colors.damage[1][2], Settings.colors.damage[1][3], Settings.colors.damage[1][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[1] = { r, g, b, a } end,
            default = Defaults.colors.damage[1]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_PHYSICAL),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_PHYSICAL_TP),
            getFunction = function () return Settings.colors.damage[2][1], Settings.colors.damage[2][2], Settings.colors.damage[2][3], Settings.colors.damage[2][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[2] = { r, g, b, a } end,
            default = Defaults.colors.damage[2]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_BLEED),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_BLEED_TP),
            getFunction = function () return Settings.colors.damage[12][1], Settings.colors.damage[12][2], Settings.colors.damage[12][3], Settings.colors.damage[12][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[12] = { r, g, b, a } end,
            default = Defaults.colors.damage[12]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_FIRE),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_FIRE_TP),
            getFunction = function () return Settings.colors.damage[3][1], Settings.colors.damage[3][2], Settings.colors.damage[3][3], Settings.colors.damage[3][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[3] = { r, g, b, a } end,
            default = Defaults.colors.damage[3]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_SHOCK),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_SHOCK_TP),
            getFunction = function () return Settings.colors.damage[4][1], Settings.colors.damage[4][2], Settings.colors.damage[4][3], Settings.colors.damage[4][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[4] = { r, g, b, a } end,
            default = Defaults.colors.damage[4]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OBLIVION),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OBLIVION_TP),
            getFunction = function () return Settings.colors.damage[5][1], Settings.colors.damage[5][2], Settings.colors.damage[5][3], Settings.colors.damage[5][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[5] = { r, g, b, a } end,
            default = Defaults.colors.damage[5]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_COLD),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_COLD_TP),
            getFunction = function () return Settings.colors.damage[6][1], Settings.colors.damage[6][2], Settings.colors.damage[6][3], Settings.colors.damage[6][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[6] = { r, g, b, a } end,
            default = Defaults.colors.damage[6]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_EARTH),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_EARTH_TP),
            getFunction = function () return Settings.colors.damage[7][1], Settings.colors.damage[7][2], Settings.colors.damage[7][3], Settings.colors.damage[7][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[7] = { r, g, b, a } end,
            default = Defaults.colors.damage[7]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_MAGIC),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_MAGIC_TP),
            getFunction = function () return Settings.colors.damage[8][1], Settings.colors.damage[8][2], Settings.colors.damage[8][3], Settings.colors.damage[8][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[8] = { r, g, b, a } end,
            default = Defaults.colors.damage[8]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DROWN),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DROWN_TP),
            getFunction = function () return Settings.colors.damage[9][1], Settings.colors.damage[9][2], Settings.colors.damage[9][3], Settings.colors.damage[9][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[9] = { r, g, b, a } end,
            default = Defaults.colors.damage[9]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DISEASE),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_DISEASE_TP),
            getFunction = function () return Settings.colors.damage[10][1], Settings.colors.damage[10][2], Settings.colors.damage[10][3], Settings.colors.damage[10][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[10] = { r, g, b, a } end,
            default = Defaults.colors.damage[10]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_POISON),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_POISON_TP),
            getFunction = function () return Settings.colors.damage[11][1], Settings.colors.damage[11][2], Settings.colors.damage[11][3], Settings.colors.damage[11][4] end,
            setFunction = function (r, g, b, a) Settings.colors.damage[11] = { r, g, b, a } end,
            default = Defaults.colors.damage[11]
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OVERRIDE),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DAMAGE_OVERRIDE_TP),
            getFunction = function () return Settings.toggles.criticalDamageOverride end,
            setFunction = function (v) Settings.toggles.criticalDamageOverride = v end,
            default = Defaults.toggles.criticalDamageOverride
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_DAMAGE_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_DAMAGE_COLOR_TP),
            getFunction = function () return Settings.colors.criticalDamageOverride[1], Settings.colors.criticalDamageOverride[2], Settings.colors.criticalDamageOverride[3], Settings.colors.criticalDamageOverride[4] end,
            setFunction = function (r, g, b, a) Settings.colors.criticalDamageOverride = { r, g, b, a } end,
            default = Defaults.colors.criticalDamageOverride
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_OVERRIDE),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_OVERRIDE_TP),
            getFunction = function () return Settings.toggles.incomingDamageOverride end,
            setFunction = function (v) Settings.toggles.incomingDamageOverride = v end,
            default = Defaults.toggles.incomingDamageOverride
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_INCOMING_COLOR_TP),
            getFunction = function () return Settings.colors.incomingDamageOverride[1], Settings.colors.incomingDamageOverride[2], Settings.colors.incomingDamageOverride[3], Settings.colors.incomingDamageOverride[4] end,
            setFunction = function (r, g, b, a) Settings.colors.incomingDamageOverride = { r, g, b, a } end,
            default = Defaults.colors.incomingDamageOverride
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_HEALING)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_HEALING_TP),
            getFunction = function () return Settings.toggles.incoming.showHealing end,
            setFunction = function (v) Settings.toggles.incoming.showHealing = v end,
            default = Defaults.toggles.incoming.showHealing
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_HEALING_TP),
            getFunction = function () return Settings.toggles.outgoing.showHealing end,
            setFunction = function (v) Settings.toggles.outgoing.showHealing = v end,
            default = Defaults.toggles.outgoing.showHealing
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HEALING_TP),
            getFunction = function () return CombatText.GetFormat("healing") end,
            setFunction = function (v) CombatText.SetFormat("healing", v) end,
            default = Defaults.formats.healing
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HEALING_CRITICAL_TP),
            getFunction = function () return CombatText.GetFormat("healingcritical") end,
            setFunction = function (v) CombatText.SetFormat("healingcritical", v) end,
            default = Defaults.formats.healingcritical
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HEALING_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.healing end,
            setFunction = function (size) Settings.fontSizes.healing = size end,
            default = Defaults.fontSizes.healing
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HEALING_CRITICAL_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.healingcritical end,
            setFunction = function (size) Settings.fontSizes.healingcritical = size end,
            default = Defaults.fontSizes.healingcritical
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_HOT)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_HOT_TP),
            getFunction = function () return Settings.toggles.incoming.showHot end,
            setFunction = function (v) Settings.toggles.incoming.showHot = v end,
            default = Defaults.toggles.incoming.showHot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_HOT_ABV), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_HOT_TP),
            getFunction = function () return Settings.toggles.outgoing.showHot end,
            setFunction = function (v) Settings.toggles.outgoing.showHot = v end,
            default = Defaults.toggles.outgoing.showHot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HOT_TP),
            getFunction = function () return CombatText.GetFormat("hot") end,
            setFunction = function (v) CombatText.SetFormat("hot", v) end,
            default = Defaults.formats.hot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_HOT_CRITICAL_TP),
            getFunction = function () return CombatText.GetFormat("hotcritical") end,
            setFunction = function (v) CombatText.SetFormat("hotcritical", v) end,
            default = Defaults.formats.hotcritical
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HOT_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.hot end,
            setFunction = function (size) Settings.fontSizes.hot = size end,
            default = Defaults.fontSizes.hot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_FONT_SIZE), GetString(LUIE_STRING_LAM_CT_SHARED_CRITICAL)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_HOT_CRITICAL_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.hotcritical end,
            setFunction = function (size) Settings.fontSizes.hotcritical = size end,
            default = Defaults.fontSizes.hotcritical
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_HEADER_HEALING_COLOR)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_TP),
            getFunction = function () return Settings.colors.healing[1], Settings.colors.healing[2], Settings.colors.healing[3], Settings.colors.healing[4] end,
            setFunction = function (r, g, b, a) Settings.colors.healing = { r, g, b, a } end,
            default = Defaults.colors.healing
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_OVERRIDE),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_HEALING_OVERRIDE_TP),
            getFunction = function () return Settings.toggles.criticalHealingOverride end,
            setFunction = function (v) Settings.toggles.criticalHealingOverride = v end,
            default = Defaults.toggles.criticalHealingOverride
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_HEALING_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_CRIT_HEALING_COLOR_TP),
            getFunction = function () return Settings.colors.criticalHealingOverride[1], Settings.colors.criticalHealingOverride[2], Settings.colors.criticalHealingOverride[3], Settings.colors.criticalHealingOverride[4] end,
            setFunction = function (r, g, b, a) Settings.colors.criticalHealingOverride = { r, g, b, a } end,
            default = Defaults.colors.criticalHealingOverride
        }
    end)

    -- Build Resource Gain & Drain Options Section
    buildSectionSettings("ResourceGainDrain", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_RESOURCE_GAIN_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_GAIN_LOSS_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.gainLoss end,
            setFunction = function (size) Settings.fontSizes.gainLoss = size end,
            default = Defaults.fontSizes.gainLoss
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_ENERGIZE_TP),
            getFunction = function () return Settings.toggles.incoming.showEnergize end,
            setFunction = function (v) Settings.toggles.incoming.showEnergize = v end,
            default = Defaults.toggles.incoming.showEnergize
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_ENERGIZE_TP),
            getFunction = function () return Settings.toggles.outgoing.showEnergize end,
            setFunction = function (v) Settings.toggles.outgoing.showEnergize = v end,
            default = Defaults.toggles.outgoing.showEnergize
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_ENERGIZE_TP),
            getFunction = function () return CombatText.GetFormat("energize") end,
            setFunction = function (v) CombatText.SetFormat("energize", v) end,
            default = Defaults.formats.energize
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_MAGICKA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_MAGICKA_TP),
            getFunction = function () return Settings.colors.energizeMagicka[1], Settings.colors.energizeMagicka[2], Settings.colors.energizeMagicka[3], Settings.colors.energizeMagicka[4] end,
            setFunction = function (r, g, b, a) Settings.colors.energizeMagicka = { r, g, b, a } end,
            default = Defaults.colors.energizeMagicka
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_STAMINA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_STAMINA_TP),
            getFunction = function () return Settings.colors.energizeStamina[1], Settings.colors.energizeStamina[2], Settings.colors.energizeStamina[3], Settings.colors.energizeStamina[4] end,
            setFunction = function (r, g, b, a) Settings.colors.energizeStamina = { r, g, b, a } end,
            default = Defaults.colors.energizeStamina
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_ENERGIZE_ULTIMATE_TP),
            getFunction = function () return Settings.toggles.incoming.showUltimateEnergize end,
            setFunction = function (v) Settings.toggles.incoming.showUltimateEnergize = v end,
            default = Defaults.toggles.incoming.showUltimateEnergize
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ENERGIZE_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_ENERGIZE_ULTIMATE_TP),
            getFunction = function () return Settings.toggles.outgoing.showUltimateEnergize end,
            setFunction = function (v) Settings.toggles.outgoing.showUltimateEnergize = v end,
            default = Defaults.toggles.outgoing.showUltimateEnergize
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_ENERGIZE_ULTIMATE_TP),
            getFunction = function () return CombatText.GetFormat("ultimateEnergize") end,
            setFunction = function (v) CombatText.SetFormat("ultimateEnergize", v) end,
            default = Defaults.formats.ultimateEnergize
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_ENERGIZE_ULTIMATE_TP),
            getFunction = function () return Settings.colors.energizeUltimate[1], Settings.colors.energizeUltimate[2], Settings.colors.energizeUltimate[3], Settings.colors.energizeUltimate[4] end,
            setFunction = function (r, g, b, a) Settings.colors.energizeUltimate = { r, g, b, a } end,
            default = Defaults.colors.energizeUltimate
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_INCOMING_DRAIN_TP),
            getFunction = function () return Settings.toggles.incoming.showDrain end,
            setFunction = function (v) Settings.toggles.incoming.showDrain = v end,
            default = Defaults.toggles.incoming.showDrain
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_INFER_CAST_RESOURCE_DRAIN),
            tooltip = GetString(LUIE_STRING_LAM_CT_INFER_CAST_RESOURCE_DRAIN_TP),
            getFunction = function () return Settings.common.inferResourceDrainOnCast end,
            setFunction = function (v) Settings.common.inferResourceDrainOnCast = v end,
            default = Defaults.common.inferResourceDrainOnCast,
            disable = function () return not Settings.toggles.incoming.showDrain end,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
            tooltip = GetString(LUIE_STRING_LAM_CT_OUTGOING_DRAIN_TP),
            getFunction = function () return Settings.toggles.outgoing.showDrain end,
            setFunction = function (v) Settings.toggles.outgoing.showDrain = v end,
            default = Defaults.toggles.outgoing.showDrain
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_COMBAT_DRAIN_TP),
            getFunction = function () return CombatText.GetFormat("drain") end,
            setFunction = function (v) CombatText.SetFormat("drain", v) end,
            default = Defaults.formats.drain
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_MAGICKA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DRAIN_MAGICKA_TP),
            getFunction = function () return Settings.colors.drainMagicka[1], Settings.colors.drainMagicka[2], Settings.colors.drainMagicka[3], Settings.colors.drainMagicka[4] end,
            setFunction = function (r, g, b, a) Settings.colors.drainMagicka = { r, g, b, a } end,
            default = Defaults.colors.drainMagicka
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_STAMINA), GetString(LUIE_STRING_LAM_CT_SHARED_COLOR)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_COMBAT_DRAIN_STAMINA_TP),
            getFunction = function () return Settings.colors.drainStamina[1], Settings.colors.drainStamina[2], Settings.colors.drainStamina[3], Settings.colors.drainStamina[4] end,
            setFunction = function (r, g, b, a) Settings.colors.drainStamina = { r, g, b, a } end,
            default = Defaults.colors.drainStamina
        }
    end)

    -- Build Mitigation Options Section
    buildSectionSettings("Mitigation", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_MITIGATION), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_MITIGATION_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.mitigation end,
            setFunction = function (size) Settings.fontSizes.mitigation = size end,
            default = Defaults.fontSizes.mitigation
        }

        -- Mitigation types (Miss, Immune, Parried, Reflected, Damage Shielded, Dodged, Blocked, Interrupted)
        local mitigationTypes =
        {
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_MISS),          incoming = "showMiss",         outgoing = "showMiss",         format = "miss",         color = "miss"         },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_IMMUNE),        incoming = "showImmune",       outgoing = "showImmune",       format = "immune",       color = "immune"       },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_PARRIED),       incoming = "showParried",      outgoing = "showParried",      format = "parried",      color = "parried"      },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_REFLECTED),     incoming = "showReflected",    outgoing = "showReflected",    format = "reflected",    color = "reflected"    },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE_SHIELD), incoming = "showDamageShield", outgoing = "showDamageShield", format = "damageShield", color = "damageShield" },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_DODGED),        incoming = "showDodged",       outgoing = "showDodged",       format = "dodged",       color = "dodged"       },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_BLOCKED),       incoming = "showBlocked",      outgoing = "showBlocked",      format = "blocked",      color = "blocked"      },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_INTERRUPTED),   incoming = "showInterrupted",  outgoing = "showInterrupted",  format = "interrupted",  color = "interrupted"  },
        }

        for _, mitType in ipairs(mitigationTypes) do
            settings[#settings + 1] =
            {
                type = LHAS.ST_LABEL,
                label = mitType.header
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_CHECKBOX,
                label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), mitType.header, GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString("LUIE_STRING_LAM_CT_INCOMING_" .. mitType.header:upper() .. "_TP"),
                getFunction = function () return Settings.toggles.incoming[mitType.incoming] end,
                setFunction = function (v) Settings.toggles.incoming[mitType.incoming] = v end,
                default = Defaults.toggles.incoming[mitType.incoming]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_CHECKBOX,
                label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), mitType.header, GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString("LUIE_STRING_LAM_CT_OUTGOING_" .. mitType.header:upper() .. "_TP"),
                getFunction = function () return Settings.toggles.outgoing[mitType.outgoing] end,
                setFunction = function (v) Settings.toggles.outgoing[mitType.outgoing] = v end,
                default = Defaults.toggles.outgoing[mitType.outgoing]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_EDIT,
                label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString("LUIE_STRING_LAM_CT_FORMAT_COMBAT_" .. mitType.format:upper() .. "_TP"),
                getFunction = function () return Settings.formats[mitType.format] end,
                setFunction = function (v) Settings.formats[mitType.format] = v end,
                default = Defaults.formats[mitType.format]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_COLOR,
                label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString("LUIE_STRING_LAM_CT_COLOR_COMBAT_" .. mitType.color:upper() .. "_TP"),
                getFunction = function () return Settings.colors[mitType.color][1], Settings.colors[mitType.color][2], Settings.colors[mitType.color][3], Settings.colors[mitType.color][4] end,
                setFunction = function (r, g, b, a) Settings.colors[mitType.color] = { r, g, b, a } end,
                default = Defaults.colors[mitType.color]
            }
        end
    end)

    -- Build Crowd Control Options Section
    buildSectionSettings("CrowdControl", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_CROWD_CONTROL), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_COMBAT_CROWD_CONTROL_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.crowdControl end,
            setFunction = function (size) Settings.fontSizes.crowdControl = size end,
            default = Defaults.fontSizes.crowdControl
        }

        -- Crowd Control types (Disoriented, Feared, Off-Balance, Silenced, Stunned, Charmed)
        local ccTypes =
        {
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_DISORIENTED), incoming = "showDisoriented", outgoing = "showDisoriented", format = "disoriented", color = "disoriented" },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_FEARED),      incoming = "showFeared",      outgoing = "showFeared",      format = "feared",      color = "feared"      },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_OFF_BALANCE), incoming = "showOffBalanced", outgoing = "showOffBalanced", format = "offBalanced", color = "offBalanced" },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_SILENCED),    incoming = "showSilenced",    outgoing = "showSilenced",    format = "silenced",    color = "silenced"    },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_STUNNED),     incoming = "showStunned",     outgoing = "showStunned",     format = "stunned",     color = "stunned"     },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_CHARMED),     incoming = "showCharmed",     outgoing = "showCharmed",     format = "charmed",     color = "charmed"     },
        }

        for _, ccType in ipairs(ccTypes) do
            settings[#settings + 1] =
            {
                type = LHAS.ST_LABEL,
                label = ccType.header
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_CHECKBOX,
                label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), ccType.header, GetString(LUIE_STRING_LAM_CT_SHARED_INCOMING)),
                tooltip = GetString("LUIE_STRING_LAM_CT_INCOMING_" .. ccType.header:upper() .. "_TP"),
                getFunction = function () return Settings.toggles.incoming[ccType.incoming] end,
                setFunction = function (v) Settings.toggles.incoming[ccType.incoming] = v end,
                default = Defaults.toggles.incoming[ccType.incoming]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_CHECKBOX,
                label = zo_strformat("<<1>> <<2>> (<<3>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), ccType.header, GetString(LUIE_STRING_LAM_CT_SHARED_OUTGOING)),
                tooltip = GetString("LUIE_STRING_LAM_CT_OUTGOING_" .. ccType.header:upper() .. "_TP"),
                getFunction = function () return Settings.toggles.outgoing[ccType.outgoing] end,
                setFunction = function (v) Settings.toggles.outgoing[ccType.outgoing] = v end,
                default = Defaults.toggles.outgoing[ccType.outgoing]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_EDIT,
                label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString("LUIE_STRING_LAM_CT_FORMAT_COMBAT_" .. ccType.format:upper() .. "_TP"),
                getFunction = function () return Settings.formats[ccType.format] end,
                setFunction = function (v) Settings.formats[ccType.format] = v end,
                default = Defaults.formats[ccType.format]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_COLOR,
                label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString("LUIE_STRING_LAM_CT_COLOR_COMBAT_" .. ccType.color:upper() .. "_TP"),
                getFunction = function () return Settings.colors[ccType.color][1], Settings.colors[ccType.color][2], Settings.colors[ccType.color][3], Settings.colors[ccType.color][4] end,
                setFunction = function (r, g, b, a) Settings.colors[ccType.color] = { r, g, b, a } end,
                default = Defaults.colors[ccType.color]
            }
        end
    end)

    -- Build Notification Options Section
    buildSectionSettings("Notification", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_NOTIFICATION), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_STATE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
            tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_IN_TP),
            getFunction = function () return Settings.toggles.showInCombat end,
            setFunction = function (v) Settings.toggles.showInCombat = v end,
            default = Defaults.toggles.showInCombat
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
            tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_COMBAT_OUT_TP),
            getFunction = function () return Settings.toggles.showOutCombat end,
            setFunction = function (v) Settings.toggles.showOutCombat = v end,
            default = Defaults.toggles.showOutCombat
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_COMBAT_IN_TP),
            getFunction = function () return CombatText.GetFormat("inCombat") end,
            setFunction = function (v) CombatText.SetFormat("inCombat", v) end,
            default = Defaults.formats.inCombat
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_COMBAT_OUT_TP),
            getFunction = function () return CombatText.GetFormat("outCombat") end,
            setFunction = function (v) CombatText.SetFormat("outCombat", v) end,
            default = Defaults.formats.outCombat
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_COMBAT_STATE_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.combatState end,
            setFunction = function (size) Settings.fontSizes.combatState = size end,
            default = Defaults.fontSizes.combatState
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_IN)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_COMBAT_IN_TP),
            getFunction = function () return Settings.colors.inCombat[1], Settings.colors.inCombat[2], Settings.colors.inCombat[3], Settings.colors.inCombat[4] end,
            setFunction = function (r, g, b, a) Settings.colors.inCombat = { r, g, b, a } end,
            default = Defaults.colors.inCombat
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_COMBAT_OUT)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_COMBAT_OUT_TP),
            getFunction = function () return Settings.colors.outCombat[1], Settings.colors.outCombat[2], Settings.colors.outCombat[3], Settings.colors.outCombat[4] end,
            setFunction = function (r, g, b, a) Settings.colors.outCombat = { r, g, b, a } end,
            default = Defaults.colors.outCombat
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_DEATH_HEADER)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_DEATH_NOTIFICATION),
            tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_NOTIFICATION_TP),
            getFunction = function () return Settings.toggles.showDeath end,
            setFunction = function (v) Settings.toggles.showDeath = v end,
            default = Defaults.toggles.showDeath
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_DEATH_USE_ACCOUNT_NAME),
            tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_USE_ACCOUNT_NAME_TP),
            getFunction = function () return Settings.toggles.useAccountNameForDeath end,
            setFunction = function (v) Settings.toggles.useAccountNameForDeath = v end,
            disable = function () return not Settings.toggles.showDeath end,
            default = Defaults.toggles.useAccountNameForDeath
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
            tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_FORMAT_TP),
            getFunction = function () return CombatText.GetFormat("death") end,
            setFunction = function (v) CombatText.SetFormat("death", v) end,
            default = Defaults.formats.death
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_FONT_SIZE_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.death end,
            setFunction = function (size) Settings.fontSizes.death = size end,
            default = Defaults.fontSizes.death
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_CT_DEATH_COLOR_TP),
            getFunction = function () return Settings.colors.death[1], Settings.colors.death[2], Settings.colors.death[3], Settings.colors.death[4] end,
            setFunction = function (r, g, b, a) Settings.colors.death = { r, g, b, a } end,
            default = Defaults.colors.death
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_POINTS_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.point end,
            setFunction = function (size) Settings.fontSizes.point = size end,
            default = Defaults.fontSizes.point
        }

        -- Point Gain types (Alliance, Experience, Champion)
        local pointTypes =
        {
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_ALLIANCE),   toggle = "showPointsAlliance",   format = "pointsAlliance",   color = "pointsAlliance"   },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_EXPERIENCE), toggle = "showPointsExperience", format = "pointsExperience", color = "pointsExperience" },
            { header = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_CHAMPION),   toggle = "showPointsChampion",   format = "pointsChampion",   color = "pointsChampion"   },
        }

        for _, pointType in ipairs(pointTypes) do
            settings[#settings + 1] =
            {
                type = LHAS.ST_LABEL,
                label = pointType.header
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_CHECKBOX,
                label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), pointType.header),
                tooltip = GetString("LUIE_STRING_LAM_CT_NOTIFICATION_" .. pointType.header:upper() .. "_TP"),
                getFunction = function () return Settings.toggles[pointType.toggle] end,
                setFunction = function (v) Settings.toggles[pointType.toggle] = v end,
                default = Defaults.toggles[pointType.toggle]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_EDIT,
                label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString("LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_" .. pointType.format:upper() .. "_TP"),
                getFunction = function () return Settings.formats[pointType.format] end,
                setFunction = function (v) Settings.formats[pointType.format] = v end,
                default = Defaults.formats[pointType.format]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_COLOR,
                label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString("LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_" .. pointType.color:upper() .. "_TP"),
                getFunction = function () return Settings.colors[pointType.color][1], Settings.colors[pointType.color][2], Settings.colors[pointType.color][3], Settings.colors[pointType.color][4] end,
                setFunction = function (r, g, b, a) Settings.colors[pointType.color] = { r, g, b, a } end,
                default = Defaults.colors[pointType.color]
            }
        end

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_AND_POTION_READY)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_RESOURCE_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.readylabel end,
            setFunction = function (size) Settings.fontSizes.readylabel = size end,
            default = Defaults.fontSizes.readylabel
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
            tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_ULTIMATE_READY_TP),
            getFunction = function () return Settings.toggles.showUltimate end,
            setFunction = function (v) Settings.toggles.showUltimate = v end,
            default = Defaults.toggles.showUltimate
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
            tooltip = GetString(LUIE_STRING_LAM_CT_NOTIFICATION_POTION_READY_TP),
            getFunction = function () return Settings.toggles.showPotionReady end,
            setFunction = function (v) Settings.toggles.showPotionReady = v end,
            default = Defaults.toggles.showPotionReady
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_ULTIMATE_TP),
            getFunction = function () return CombatText.GetFormat("ultimateReady") end,
            setFunction = function (v) CombatText.SetFormat("ultimateReady", v) end,
            default = Defaults.formats.ultimateReady
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_EDIT,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
            tooltip = GetString(LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_POTION_TP),
            getFunction = function () return CombatText.GetFormat("potionReady") end,
            setFunction = function (v) CombatText.SetFormat("potionReady", v) end,
            default = Defaults.formats.potionReady
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_ULTIMATE_TP),
            getFunction = function () return Settings.colors.ultimateReady[1], Settings.colors.ultimateReady[2], Settings.colors.ultimateReady[3], Settings.colors.ultimateReady[4] end,
            setFunction = function (r, g, b, a) Settings.colors.ultimateReady = { r, g, b, a } end,
            default = Defaults.colors.ultimateReady
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_COLOR,
            label = zo_strformat("<<1>> (<<2>>)", GetString(LUIE_STRING_LAM_CT_SHARED_COLOR), GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY)),
            tooltip = GetString(LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_POTION_TP),
            getFunction = function () return Settings.colors.potionReady[1], Settings.colors.potionReady[2], Settings.colors.potionReady[3], Settings.colors.potionReady[4] end,
            setFunction = function (r, g, b, a) Settings.colors.potionReady = { r, g, b, a } end,
            default = Defaults.colors.potionReady
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_FORMAT_DESCRIPTION)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CT_HEADER_SHARED_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_NOTIFICATION_RESOURCE_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function () return Settings.fontSizes.lowResource end,
            setFunction = function (size) Settings.fontSizes.lowResource = size end,
            default = Defaults.fontSizes.lowResource
        }

        -- Resource Warning types (Low Health, Low Magicka, Low Stamina)
        local resourceTypes =
        {
            { header = "HEALTH",  toggle = "showLowHealth",  format = "lowHealth",  color = "lowHealth"  },
            { header = "MAGICKA", toggle = "showLowMagicka", format = "lowMagicka", color = "lowMagicka" },
            { header = "STAMINA", toggle = "showLowStamina", format = "lowStamina", color = "lowStamina" },
        }

        for _, resType in ipairs(resourceTypes) do
            settings[#settings + 1] =
            {
                type = LHAS.ST_LABEL,
                label = GetString("LUIE_STRING_LAM_CT_NOTIFICATION_LOW_" .. resType.header)
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_CHECKBOX,
                label = zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_SHARED_DISPLAY), GetString("LUIE_STRING_LAM_CT_NOTIFICATION_LOW_" .. resType.header)),
                tooltip = GetString("LUIE_STRING_LAM_CT_NOTIFICATION_LOW_" .. resType.header .. "_TP"),
                getFunction = function () return Settings.toggles[resType.toggle] end,
                setFunction = function (v) Settings.toggles[resType.toggle] = v end,
                default = Defaults.toggles[resType.toggle]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_SLIDER,
                label = GetString("LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_" .. resType.header),
                tooltip = GetString("LUIE_STRING_LAM_CT_NOTIFICATION_WARNING_" .. resType.header .. "_TP"),
                min = 15,
                max = 50,
                step = 1,
                format = "%.0f",
                getFunction = function () return Settings.toggles["threshold" .. resType.header:sub(1, 1) .. resType.header:sub(2):lower()] end,
                setFunction = function (v) Settings.toggles["threshold" .. resType.header:sub(1, 1) .. resType.header:sub(2):lower()] = v end,
                disable = function () return not Settings.toggles[resType.toggle] end,
                default = Defaults.toggles["threshold" .. resType.header:sub(1, 1) .. resType.header:sub(2):lower()]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_EDIT,
                label = GetString(LUIE_STRING_LAM_CT_SHARED_FORMAT),
                tooltip = GetString("LUIE_STRING_LAM_CT_FORMAT_NOTIFICATION_LOW_" .. resType.format:upper() .. "_TP"),
                getFunction = function () return Settings.formats[resType.format] end,
                setFunction = function (v) Settings.formats[resType.format] = v end,
                default = Defaults.formats[resType.format]
            }

            settings[#settings + 1] =
            {
                type = LHAS.ST_COLOR,
                label = GetString(LUIE_STRING_LAM_CT_SHARED_COLOR),
                tooltip = GetString("LUIE_STRING_LAM_CT_COLOR_NOTIFICATION_LOW_" .. resType.color:upper() .. "_TP"),
                getFunction = function () return Settings.colors[resType.color][1], Settings.colors[resType.color][2], Settings.colors[resType.color][3], Settings.colors[resType.color][4] end,
                setFunction = function (r, g, b, a) Settings.colors[resType.color] = { r, g, b, a } end,
                default = Defaults.colors[resType.color]
            }
        end
    end)

    -- Build Font Options Section
    buildSectionSettings("Font", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_FONT_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CT_FONT),
            canSelect = false,
        }

        settings[#settings + 1] = SettingsAPI:ConsoleFontDeferLabelSetting()

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_FACE_TP),
            items = fontItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.fontFace)
            end,
            setFunction = function (combobox, value, item)
                Settings.fontFace = item.data or item.name or value
                SettingsAPI:MarkFontDeferred("combatText")
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.fontFace)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_SIZE_TP),
            min = 8,
            max = 72,
            step = 1,
            format = "%.0f",
            getFunction = function ()
                return Settings.fontSize
            end,
            setFunction = function (fontSize)
                Settings.fontSize = fontSize
                SettingsAPI:MarkFontDeferred("combatText")
            end,
            default = Defaults.fontSize
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_CT_FONT_STYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.fontStyle)
            end,
            setFunction = function (combobox, value, item)
                Settings.fontStyle = item.data
                SettingsAPI:MarkFontDeferred("combatText")
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.fontStyle)
        }
    end)

    -- Build Animation Options Section
    buildSectionSettings("Animation", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_CONSOLE_SECTION_CT_ANIMATION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_TYPE),
            tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_TYPE_TP),
            items = animationTypeDropdownItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.animation.animationType)
            end,
            setFunction = function (combobox, value, item)
                Settings.animation.animationType = item.data or item.name or value
                -- Recreate the combat event viewer with new animation type
                if CombatText.Enabled then
                    CombatText.CreateCombatEventViewer()
                end
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.animation.animationType)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_DURATION),
            tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_DURATION_TP),
            warning = GetString(LUIE_STRING_LAM_RELOADUI_WARNING),
            min = 5,
            max = 300,
            step = 5,
            getFunction = function ()
                return Settings.animation.animationDuration
            end,
            setFunction = function (value)
                Settings.animation.animationDuration = value
            end,
            default = 100
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_IN),
            tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_IN_TP),
            items = directionTypeDropdownItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.animation.incoming.directionType)
            end,
            setFunction = function (combobox, value, item)
                Settings.animation.incoming.directionType = item.data or item.name or value
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.animation.incoming.directionType)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_IN),
            tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_IN_TP),
            items = iconSideDropdownItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.animation.incomingIcon)
            end,
            setFunction = function (combobox, value, item)
                Settings.animation.incomingIcon = item.data or item.name or value
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.animation.incomingIcon)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_OUT),
            tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_DIRECTION_OUT_TP),
            items = directionTypeDropdownItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.animation.outgoing.directionType)
            end,
            setFunction = function (combobox, value, item)
                Settings.animation.outgoing.directionType = item.data or item.name or value
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.animation.outgoing.directionType)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_OUT),
            tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_OUT_TP),
            items = iconSideDropdownItems,
            getFunction = function ()
                return SettingsAPI:LHASDropdownGetData(Settings.animation.outgoingIcon)
            end,
            setFunction = function (combobox, value, item)
                Settings.animation.outgoingIcon = item.data or item.name or value
            end,
            default = SettingsAPI:LHASDropdownGetData(Defaults.animation.outgoingIcon)
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_FRAME),
            tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_ICON_FRAME_TP),
            getFunction = function ()
                return Settings.animation.showIconFrame
            end,
            setFunction = function (value)
                Settings.animation.showIconFrame = value
            end,
            default = Defaults.animation.showIconFrame,
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST),
            tooltip = GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST_TP),
            buttonText = GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST),
            clickHandler = function ()
                local listener = CombatText.combatEventListener
                if not listener then
                    return
                end
                listener:TriggerEvent(CombatTextConstants.eventType.COMBAT, CombatTextConstants.combatType.INCOMING, COMBAT_MECHANIC_FLAGS_STAMINA, zo_random(7, 777), GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST), 41567, DAMAGE_TYPE_PHYSICAL, "Test", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
                listener:TriggerEvent(CombatTextConstants.eventType.COMBAT, CombatTextConstants.combatType.OUTGOING, COMBAT_MECHANIC_FLAGS_STAMINA, zo_random(7, 777), GetString(LUIE_STRING_LAM_CT_ANIMATION_TEST), 41567, DAMAGE_TYPE_PHYSICAL, "Test", true, false, false, false, false, false, false, false, false, false, false, false, false, false)
            end
        }
    end)

    -- Build Throttle Options Section
    buildSectionSettings("Throttle", function (settings)
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_THROTTLE_HEADER),
        }

        -- Submenu description
        settings[#settings + 1] =
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_CT_THROTTLE_DESCRIPTION),
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_DAMAGE),
            tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_DAMAGE_TP),
            min = 0,
            max = 500,
            step = 50,
            format = "%.0f",
            getFunction = function () return Settings.throttles.damage end,
            setFunction = function (v) Settings.throttles.damage = v end,
            default = Defaults.throttles.damage
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_DOT),
            tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_DOT_TP),
            min = 0,
            max = 500,
            step = 50,
            format = "%.0f",
            getFunction = function () return Settings.throttles.dot end,
            setFunction = function (v) Settings.throttles.dot = v end,
            default = Defaults.throttles.dot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_HEALING),
            tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_HEALING_TP),
            min = 0,
            max = 500,
            step = 50,
            format = "%.0f",
            getFunction = function () return Settings.throttles.healing end,
            setFunction = function (v) Settings.throttles.healing = v end,
            default = Defaults.throttles.healing
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_CT_SHARED_HOT),
            tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_HOT_TP),
            min = 0,
            max = 500,
            step = 50,
            format = "%.0f",
            getFunction = function () return Settings.throttles.hot end,
            setFunction = function (v) Settings.throttles.hot = v end,
            default = Defaults.throttles.hot
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_THROTTLE_TRAILER),
            tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_TRAILER_TP),
            getFunction = function () return Settings.toggles.showThrottleTrailer end,
            setFunction = function (v) Settings.toggles.showThrottleTrailer = v end,
            default = Defaults.toggles.showThrottleTrailer
        }

        settings[#settings + 1] =
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_CT_THROTTLE_CRITICAL),
            tooltip = GetString(LUIE_STRING_LAM_CT_THROTTLE_CRITICAL_TP),
            getFunction = function () return Settings.toggles.throttleCriticals end,
            setFunction = function (v) Settings.toggles.throttleCriticals = v end,
            disable = function () return not Settings.toggles.showThrottleTrailer end,
            default = Defaults.toggles.throttleCriticals
        }
    end)

    if LUIE.SV.CombatText_Enabled then
        local allSettings = {}
        SettingsAPI:AppendSettingsList(allSettings, initialSettings)
        SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CT_PANEL_LAYOUT_SUBMENU), sectionGroups["PanelLayout"])
        SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_UF_COMMON_HEADER), sectionGroups["CommonOptions"])
        SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CT_BLACKLIST_HEADER), sectionGroups["Blacklist"])
        SettingsAPI:AppendSection(allSettings, zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_DAMAGE_AND_HEALING), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)), sectionGroups["DamageHealing"])
        SettingsAPI:AppendSection(allSettings, zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_RESOURCE_GAIN_DRAIN), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)), sectionGroups["ResourceGainDrain"])
        SettingsAPI:AppendSection(allSettings, zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_MITIGATION), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)), sectionGroups["Mitigation"])
        SettingsAPI:AppendSection(allSettings, zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_CROWD_CONTROL), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)), sectionGroups["CrowdControl"])
        SettingsAPI:AppendSection(allSettings, zo_strformat("<<1>> <<2>>", GetString(LUIE_STRING_LAM_CT_HEADER_NOTIFICATION), GetString(LUIE_STRING_LAM_CT_SHARED_OPTIONS)), sectionGroups["Notification"])
        SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CT_FONT_HEADER), sectionGroups["Font"])
        SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CT_ANIMATION_HEADER), sectionGroups["Animation"])
        SettingsAPI:AppendSection(allSettings, GetString(LUIE_STRING_LAM_CT_THROTTLE_HEADER), sectionGroups["Throttle"])
        panel:AddSettings(allSettings)
    end
end
