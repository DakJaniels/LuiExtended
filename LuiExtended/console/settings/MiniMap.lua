--- @diagnostic disable: missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local SettingsAPI = LUIE.ConsoleSettingsAPI

--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local LHAS = LibHarvensAddonSettings

local miniMapVisibilityOptions =
{
    { key = "showInHud",        name = LUIE_STRING_LAM_MINIMAP_SHOW_HUD,     tp = LUIE_STRING_LAM_MINIMAP_SHOW_HUD_TP     },
    { key = "showInCombat",     name = LUIE_STRING_LAM_MINIMAP_SHOW_COMBAT,  tp = LUIE_STRING_LAM_MINIMAP_SHOW_COMBAT_TP  },
    { key = "showWhileLooting", name = LUIE_STRING_LAM_MINIMAP_SHOW_LOOT,    tp = LUIE_STRING_LAM_MINIMAP_SHOW_LOOT_TP    },
    { key = "showWhileMounted", name = LUIE_STRING_LAM_MINIMAP_SHOW_MOUNTED, tp = LUIE_STRING_LAM_MINIMAP_SHOW_MOUNTED_TP },
    { key = "showInHousing",    name = LUIE_STRING_LAM_MINIMAP_SHOW_HOUSING, tp = LUIE_STRING_LAM_MINIMAP_SHOW_HOUSING_TP },
    { key = "showOnTop",        name = LUIE_STRING_LAM_MINIMAP_SHOW_ON_TOP,  tp = LUIE_STRING_LAM_MINIMAP_SHOW_ON_TOP_TP  },
}

local miniMapZoomSliders =
{
    { key = "subZoneZoom",      name = LUIE_STRING_LAM_MINIMAP_SUBZONE_ZOOM,      tp = LUIE_STRING_LAM_MINIMAP_SUBZONE_ZOOM_TP                      },
    { key = "dungeonZoom",      name = LUIE_STRING_LAM_MINIMAP_DUNGEON_ZOOM,      tp = LUIE_STRING_LAM_MINIMAP_DUNGEON_ZOOM_TP                      },
    { key = "battlegroundZoom", name = LUIE_STRING_LAM_MINIMAP_BATTLEGROUND_ZOOM, tp = LUIE_STRING_LAM_MINIMAP_BATTLEGROUND_ZOOM_TP                 },
    { key = "mountedZoomScale", name = LUIE_STRING_LAM_MINIMAP_MOUNTED_ZOOM,      tp = LUIE_STRING_LAM_MINIMAP_MOUNTED_ZOOM_TP,     scale100 = true },
}

local miniMapPinCategoryScales =
{
    { key = "pinScaleQuest",     name = LUIE_STRING_LAM_MINIMAP_PINSCALE_QUEST     },
    { key = "pinScaleGroup",     name = LUIE_STRING_LAM_MINIMAP_PINSCALE_GROUP     },
    { key = "pinScalePoi",       name = LUIE_STRING_LAM_MINIMAP_PINSCALE_POI       },
    { key = "pinScaleWayshrine", name = LUIE_STRING_LAM_MINIMAP_PINSCALE_WAYSHRINE },
    { key = "pinScaleOther",     name = LUIE_STRING_LAM_MINIMAP_PINSCALE_OTHER     },
}

local miniMapClockModeItems =
{
    { name = "Off",     data = 0 },
    { name = "Real",    data = 1 },
    { name = "In-game", data = 2 },
    { name = "Both",    data = 3 },
}

local miniMapCompassModeItems =
{
    { name = "Untouched", data = 0 },
    { name = "Hidden",    data = 1 },
    { name = "Shown",     data = 2 },
}

function MiniMap.CreateConsoleSettings()
    local Defaults = MiniMap.Defaults
    local disable = function () return not LUIE.SV.MiniMap_Enabled end

    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_MINIMAP),
                                {
                                    allowDefaults = true,
                                    defaultsFunction = function ()
                                        MiniMap.ResetPosition()
                                    end,
                                })

    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_DESCRIPTION),
        })

    panel:AddSetting(
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RELOADUI),
            tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
            buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
            clickHandler = function ()
                SettingsAPI:ReloadUIWithPendingClear()
            end,
        })

    panel:AddSetting(SettingsAPI:ConsoleFontDeferLabelSetting())

    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM_TP),
            min = 10,
            max = 180,
            step = 1,
            format = "%.0f",
            getFunction = function () return (MiniMap.SV.defaultZoom or Defaults.defaultZoom) * 100 end,
            setFunction = function (value)
                MiniMap.SV.defaultZoom = value / 100
                MiniMap.ClampSavedDefaultZoom()
                if MiniMap.mapController and MiniMap.mapController:IsReady() then
                    MiniMap.mapController:ApplyZoom(0)
                end
            end,
            default = Defaults.defaultZoom * 100,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_PINSCALE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PINSCALE_TP),
            min = 10,
            max = 200,
            step = 1,
            format = "%.0f",
            getFunction = function () return (MiniMap.SV.defaultPinScale or Defaults.defaultPinScale) * 100 end,
            setFunction = function (value)
                MiniMap.SV.defaultPinScale = value / 100
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.defaultPinScale * 100,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE_TP),
            min = 50,
            max = 200,
            step = 5,
            format = "%.0f",
            getFunction = function () return (MiniMap.SV.playerPinScale or Defaults.playerPinScale) * 100 end,
            setFunction = function (value)
                MiniMap.SV.playerPinScale = value / 100
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.playerPinScale * 100,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER_TP),
            getFunction = function () return MiniMap.SV.followPlayer end,
            setFunction = function (value)
                MiniMap.SV.followPlayer = value
                if MiniMap.runtime then
                    MiniMap.runtime.mapFollowsPlayer = value
                end
                if value then
                    MiniMap.RecenterFollow()
                elseif MiniMap.view and MiniMap.runtime then
                    local scroll = MiniMap.view.scroll
                    MiniMap.SV.panOffsetX = scroll:GetHorizontalScroll()
                    MiniMap.SV.panOffsetY = scroll:GetVerticalScroll()
                    MiniMap.runtime:ApplyScrollFromPanOffsets()
                end
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.followPlayer,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_LOCK_POSITION),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_LOCK_POSITION_TP),
            getFunction = function () return MiniMap.SV.lockPosition end,
            setFunction = function (value)
                MiniMap.SV.lockPosition = value
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.lockPosition,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_LOCK_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_LOCK_SIZE_TP),
            getFunction = function () return MiniMap.SV.lockSize end,
            setFunction = function (value)
                MiniMap.SV.lockSize = value
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.lockSize,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT_TP),
            getFunction = function () return MiniMap.SV.waypointClickRequiresShift end,
            setFunction = function (value) MiniMap.SV.waypointClickRequiresShift = value end,
            default = Defaults.waypointClickRequiresShift,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS_TP),
            getFunction = function () return MiniMap.SV.showZoomButtons end,
            setFunction = function (value)
                MiniMap.SV.showZoomButtons = value
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.showZoomButtons,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_RESETPOSITION_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = MiniMap.ResetPosition,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_VISIBILITY_HEADER),
            canSelect = false,
        })

    for optionIndex = 1, #miniMapVisibilityOptions do
        local option = miniMapVisibilityOptions[optionIndex]
        local settingKey = option.key
        panel:AddSetting(
            {
                type = LHAS.ST_CHECKBOX,
                label = GetString(option.name),
                tooltip = GetString(option.tp),
                getFunction = function () return MiniMap.SV[settingKey] end,
                setFunction = function (value)
                    MiniMap.SV[settingKey] = value
                    MiniMap.ApplyLiveSettings()
                end,
                default = Defaults[settingKey],
                disable = disable,
            })
    end

    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM_CONTEXT_HEADER),
            canSelect = false,
        })

    for sliderIndex = 1, #miniMapZoomSliders do
        local slider = miniMapZoomSliders[sliderIndex]
        panel:AddSetting(
            {
                type = LHAS.ST_SLIDER,
                label = GetString(slider.name),
                tooltip = GetString(slider.tp),
                min = slider.scale100 and 50 or 10,
                max = slider.scale100 and 200 or 180,
                step = 1,
                format = "%.0f",
                getFunction = function ()
                    local value = MiniMap.SV[slider.key] or Defaults[slider.key]
                    return value * 100
                end,
                setFunction = function (value)
                    MiniMap.SV[slider.key] = value / 100
                    if MiniMap.mapController and MiniMap.mapController:IsReady() then
                        MiniMap.ApplyContextDefaultZoom()
                    end
                end,
                default = (Defaults[slider.key] or 0.5) * 100,
                disable = disable,
            })
    end

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_AUTO_ZOOM_EDGE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_AUTO_ZOOM_EDGE_TP),
            getFunction = function () return MiniMap.SV.autoZoomOutAtEdge end,
            setFunction = function (value) MiniMap.SV.autoZoomOutAtEdge = value end,
            default = Defaults.autoZoomOutAtEdge,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_PIN_CATEGORY_HEADER),
            canSelect = false,
        })

    for categoryIndex = 1, #miniMapPinCategoryScales do
        local category = miniMapPinCategoryScales[categoryIndex]
        panel:AddSetting(
            {
                type = LHAS.ST_SLIDER,
                label = GetString(category.name),
                min = 50,
                max = 200,
                step = 5,
                format = "%.0f",
                getFunction = function () return (MiniMap.SV[category.key] or 1) * 100 end,
                setFunction = function (value)
                    MiniMap.SV[category.key] = value / 100
                    MiniMap.ApplyLiveSettings()
                end,
                default = 100,
                disable = disable,
            })
    end

    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_CHROME_HEADER),
            canSelect = false,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_MINIMAP_CLOCK_MODE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_CLOCK_MODE_TP),
            items = miniMapClockModeItems,
            getFunction = function ()
                return { data = MiniMap.SV.clockMode or 0 }
            end,
            setFunction = function (_combobox, _value, item)
                MiniMap.SV.clockMode = item.data
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.clockMode or 0,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_MODE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_MODE_TP),
            items = miniMapCompassModeItems,
            getFunction = function ()
                return { data = MiniMap.SV.compassMode or 0 }
            end,
            setFunction = function (_combobox, _value, item)
                MiniMap.SV.compassMode = item.data
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.compassMode or 0,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_COMPASS_PARITY_PINS),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_COMPASS_PARITY_PINS_TP),
            getFunction = function () return MiniMap.SV.showCompassParityPins ~= false end,
            setFunction = function (value)
                MiniMap.SV.showCompassParityPins = value
                if not value and MiniMap.compassParityController then
                    MiniMap.compassParityController:ReleaseAllCompassParityOverlays()
                end
            end,
            default = Defaults.showCompassParityPins,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_FORCE_QUEST_PINS),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_FORCE_QUEST_PINS_TP),
            getFunction = function () return MiniMap.SV.forceQuestPinsOnMinimap == true end,
            setFunction = function (value)
                MiniMap.SV.forceQuestPinsOnMinimap = value
                if MiniMap.mapEventController then
                    MiniMap.mapEventController:RequestQuestPinSync()
                end
            end,
            default = Defaults.forceQuestPinsOnMinimap,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_KEEP_SQUARE),
            getFunction = function () return MiniMap.SV.keepSquareAspect end,
            setFunction = function (value)
                MiniMap.SV.keepSquareAspect = value
                if value then
                    MiniMap.ApplySquareAspect()
                end
            end,
            default = Defaults.keepSquareAspect,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_POSITION_GRID),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_POSITION_GRID_TP),
            min = 0,
            max = 8,
            step = 1,
            format = "%.0f",
            getFunction = function () return MiniMap.SV.positionGridDivisor or 0 end,
            setFunction = function (value)
                MiniMap.SV.positionGridDivisor = value
                if value > 1 then
                    MiniMap.ApplyPositionGridSnap(MiniMap.SV)
                end
            end,
            default = Defaults.positionGridDivisor or 0,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_CAMERA_WEDGE),
            min = 50,
            max = 150,
            step = 5,
            format = "%.0f",
            getFunction = function () return (MiniMap.SV.cameraWedgeScale or 1) * 100 end,
            setFunction = function (value)
                MiniMap.SV.cameraWedgeScale = value / 100
                MiniMap.ApplyLiveSettings()
            end,
            default = (Defaults.cameraWedgeScale or 1) * 100,
            disable = disable,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_ADVANCED_HEADER),
            canSelect = false,
        })

    panel:AddSetting(
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_ADVANCED_DESC),
        })

    if LUIE.IsDevDebugEnabled() then
        panel:AddSetting(
            {
                type = LHAS.ST_CHECKBOX,
                label = GetString(LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG),
                tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG_TP),
                getFunction = function () return MiniMap.SV.pinMirrorStateMachineDebug end,
                setFunction = function (value)
                    MiniMap.SV.pinMirrorStateMachineDebug = value
                    if MiniMap.pinMirrorStateMachine then
                        MiniMap.pinMirrorStateMachine:ApplyDebugLoggingFromSavedVars()
                    end
                end,
                default = Defaults.pinMirrorStateMachineDebug,
                disable = disable,
            })
    end
end
