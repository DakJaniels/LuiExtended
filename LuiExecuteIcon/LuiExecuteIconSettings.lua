-- -----------------------------------------------------------------------------
--  LuiExecuteIcon - Settings (PC: LibAddonMenu, Console: LibHarvensAddonSettings)
-- -----------------------------------------------------------------------------

local ADDON_NAME = "LuiExecuteIcon"

-- Strings (inline to avoid separate lang file for minimal addon)
local L =
{
    PANEL_NAME = "Lui Execute Icon",
    ENABLE_SKULL = "Enable execute skull icon",
    ENABLE_SKULL_TP = "Show the skull texture next to the target frame when a hostile target is in execute range.",
    THRESHOLD = "Execute threshold %",
    THRESHOLD_TP = "Health percentage below which the skull icon is shown (default 20).",
}

-- -----------------------------------------------------------------------------
-- PC: LibAddonMenu
-- -----------------------------------------------------------------------------

function LuiExecuteIcon.RegisterPCSettings()
    local panelData =
    {
        type = "panel",
        name = L.PANEL_NAME,
        displayName = L.PANEL_NAME,
        author = "@dack_janiels[PC]",
        version = "1.0.0",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local options =
    {
        {
            type = "checkbox",
            name = L.ENABLE_SKULL,
            tooltip = L.ENABLE_SKULL_TP,
            getFunc = function ()
                return LuiExecuteIcon.SV.enableSkull
            end,
            setFunc = function (value)
                LuiExecuteIcon.SV.enableSkull = value
                LuiExecuteIcon.UpdateVisibility()
            end,
            width = "full",
            default = LuiExecuteIcon.Defaults.enableSkull,
        },
        {
            type = "slider",
            name = L.THRESHOLD,
            tooltip = L.THRESHOLD_TP,
            min = 5,
            max = 50,
            step = 1,
            getFunc = function ()
                return LuiExecuteIcon.SV.executeThreshold
            end,
            setFunc = function (value)
                LuiExecuteIcon.SV.executeThreshold = value
                LuiExecuteIcon.UpdateVisibility()
            end,
            width = "full",
            default = LuiExecuteIcon.Defaults.executeThreshold,
        },
    }

    LibAddonMenu2:RegisterAddonPanel(ADDON_NAME .. "Options", panelData)
    LibAddonMenu2:RegisterOptionControls(ADDON_NAME .. "Options", options)
end

-- -----------------------------------------------------------------------------
-- Console: LibHarvensAddonSettings
-- -----------------------------------------------------------------------------

function LuiExecuteIcon.RegisterConsoleSettings()
    local LHAS = LibHarvensAddonSettings
    local settingsData = {}

    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = L.ENABLE_SKULL,
        tooltip = L.ENABLE_SKULL_TP,
        getFunction = function ()
            return LuiExecuteIcon.SV.enableSkull
        end,
        setFunction = function (value)
            LuiExecuteIcon.SV.enableSkull = value
            LuiExecuteIcon.UpdateVisibility()
        end,
        default = LuiExecuteIcon.Defaults.enableSkull,
    }

    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_SLIDER,
        label = L.THRESHOLD,
        tooltip = L.THRESHOLD_TP,
        min = 5,
        max = 50,
        step = 1,
        getFunction = function ()
            return LuiExecuteIcon.SV.executeThreshold
        end,
        setFunction = function (value)
            LuiExecuteIcon.SV.executeThreshold = value
            LuiExecuteIcon.UpdateVisibility()
        end,
        default = LuiExecuteIcon.Defaults.executeThreshold,
    }

    local panel = LHAS:AddAddon(ADDON_NAME,
                                {
                                    allowDefaults = true,
                                    allowRefresh = true,
                                })
    panel:AddSettings(settingsData)
end
