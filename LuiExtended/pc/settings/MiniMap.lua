-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local zo_strformat = zo_strformat
local LAM = LUIE.LAM

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

function MiniMap.CreateSettings()
    local Defaults = MiniMap.Defaults
    local disabled = function () return not LUIE.SV.MiniMap_Enabled end

    local panelDataMiniMap =
    {
        type = "panel",
        name = zo_strformat("<<1>> - <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_MINIMAP)),
        displayName = zo_strformat("<<1>> <<2>>", LUIE.name, GetString(LUIE_STRING_LAM_MINIMAP)),
        author = LUIE.author .. "\n",
        version = LUIE.version,
        website = LUIE.website,
        feedback = LUIE.feedback,
        translation = LUIE.translation,
        donation = LUIE.donation,
        slashCommand = "/luimm",
        registerForRefresh = true,
        registerForDefaults = true,
    }

    local optionsDataMiniMap = {}

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "description",
        text = GetString(LUIE_STRING_LAM_MINIMAP_DESCRIPTION),
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "slider",
        name = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM_TP),
        min = 10,
        max = 180,
        step = 1,
        getFunc = function () return (MiniMap.SV.defaultZoom or Defaults.defaultZoom) * 100 end,
        setFunc = function (value)
            MiniMap.SV.defaultZoom = value / 100
            MiniMap.ClampSavedDefaultZoom()
            if MiniMap.mapController and MiniMap.mapController:IsReady() then
                MiniMap.mapController:ApplyZoom(0)
            end
        end,
        width = "full",
        default = Defaults.defaultZoom * 100,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "slider",
        name = GetString(LUIE_STRING_LAM_MINIMAP_PINSCALE),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PINSCALE_TP),
        min = 10,
        max = 200,
        step = 1,
        getFunc = function () return (MiniMap.SV.defaultPinScale or Defaults.defaultPinScale) * 100 end,
        setFunc = function (value)
            MiniMap.SV.defaultPinScale = value / 100
            MiniMap.ApplyLiveSettings()
        end,
        width = "full",
        default = Defaults.defaultPinScale * 100,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "slider",
        name = GetString(LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PLAYERPINSCALE_TP),
        min = 50,
        max = 200,
        step = 5,
        getFunc = function () return (MiniMap.SV.playerPinScale or Defaults.playerPinScale) * 100 end,
        setFunc = function (value)
            MiniMap.SV.playerPinScale = value / 100
            MiniMap.ApplyLiveSettings()
        end,
        width = "full",
        default = Defaults.playerPinScale * 100,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_FOLLOW_PLAYER_TP),
        getFunc = function () return MiniMap.SV.followPlayer end,
        setFunc = function (value)
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
        width = "full",
        default = Defaults.followPlayer,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_LOCK_POSITION),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_LOCK_POSITION_TP),
        getFunc = function () return MiniMap.SV.lockPosition end,
        setFunc = function (value)
            MiniMap.SV.lockPosition = value
            MiniMap.ApplyLiveSettings()
        end,
        width = "half",
        default = Defaults.lockPosition,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_LOCK_SIZE),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_LOCK_SIZE_TP),
        getFunc = function () return MiniMap.SV.lockSize end,
        setFunc = function (value)
            MiniMap.SV.lockSize = value
            MiniMap.ApplyLiveSettings()
        end,
        width = "half",
        default = Defaults.lockSize,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT_TP),
        getFunc = function () return MiniMap.SV.waypointClickRequiresShift end,
        setFunc = function (value) MiniMap.SV.waypointClickRequiresShift = value end,
        width = "full",
        default = Defaults.waypointClickRequiresShift,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_ZOOM_BUTTONS_TP),
        getFunc = function () return MiniMap.SV.showZoomButtons end,
        setFunc = function (value)
            MiniMap.SV.showZoomButtons = value
            MiniMap.ApplyLiveSettings()
        end,
        width = "full",
        default = Defaults.showZoomButtons,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RESETPOSITION),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_RESETPOSITION_TP),
        func = function () MiniMap.ResetPosition() end,
        width = "half",
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        func = function () ReloadUI("ingame") end,
        width = "half",
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_MINIMAP_VISIBILITY_HEADER),
        width = "full",
    }

    for optionIndex = 1, #miniMapVisibilityOptions do
        local option = miniMapVisibilityOptions[optionIndex]
        local settingKey = option.key
        optionsDataMiniMap[#optionsDataMiniMap + 1] =
        {
            type = "checkbox",
            name = GetString(option.name),
            tooltip = GetString(option.tp),
            getFunc = function () return MiniMap.SV[settingKey] end,
            setFunc = function (value)
                MiniMap.SV[settingKey] = value
                MiniMap.ApplyLiveSettings()
            end,
            width = "half",
            default = Defaults[settingKey],
            disabled = disabled,
        }
    end

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM_CONTEXT_HEADER),
        width = "full",
    }

    for sliderIndex = 1, #miniMapZoomSliders do
        local slider = miniMapZoomSliders[sliderIndex]
        optionsDataMiniMap[#optionsDataMiniMap + 1] =
        {
            type = "slider",
            name = GetString(slider.name),
            tooltip = GetString(slider.tp),
            min = slider.scale100 and 50 or 10,
            max = slider.scale100 and 200 or 180,
            step = 1,
            getFunc = function ()
                local value = MiniMap.SV[slider.key] or Defaults[slider.key]
                return slider.scale100 and value * 100 or value * 100
            end,
            setFunc = function (value)
                MiniMap.SV[slider.key] = value / 100
                if MiniMap.mapController and MiniMap.mapController:IsReady() then
                    MiniMap.ApplyContextDefaultZoom()
                end
            end,
            width = "full",
            default = (Defaults[slider.key] or 0.5) * 100,
            disabled = disabled,
        }
    end

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_AUTO_ZOOM_EDGE),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_AUTO_ZOOM_EDGE_TP),
        getFunc = function () return MiniMap.SV.autoZoomOutAtEdge end,
        setFunc = function (value) MiniMap.SV.autoZoomOutAtEdge = value end,
        width = "full",
        default = Defaults.autoZoomOutAtEdge,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_MINIMAP_PIN_CATEGORY_HEADER),
        width = "full",
    }

    for categoryIndex = 1, #miniMapPinCategoryScales do
        local category = miniMapPinCategoryScales[categoryIndex]
        optionsDataMiniMap[#optionsDataMiniMap + 1] =
        {
            type = "slider",
            name = GetString(category.name),
            min = 50,
            max = 200,
            step = 5,
            getFunc = function () return (MiniMap.SV[category.key] or 1) * 100 end,
            setFunc = function (value)
                MiniMap.SV[category.key] = value / 100
                MiniMap.ApplyLiveSettings()
            end,
            width = "half",
            default = 100,
            disabled = disabled,
        }
    end

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_MINIMAP_CHROME_HEADER),
        width = "full",
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "dropdown",
        name = GetString(LUIE_STRING_LAM_MINIMAP_CLOCK_MODE),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_CLOCK_MODE_TP),
        choices = { "Off", "Real", "In-game", "Both" },
        choicesValues = { 0, 1, 2, 3 },
        getFunc = function () return MiniMap.SV.clockMode or 0 end,
        setFunc = function (value)
            MiniMap.SV.clockMode = value
            MiniMap.ApplyLiveSettings()
        end,
        width = "full",
        default = 0,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "dropdown",
        name = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_MODE),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_MODE_TP),
        choices = { "Untouched", "Hidden", "Shown" },
        choicesValues = { 0, 1, 2 },
        getFunc = function () return MiniMap.SV.compassMode or 0 end,
        setFunc = function (value)
            MiniMap.SV.compassMode = value
            MiniMap.ApplyLiveSettings()
        end,
        width = "full",
        default = 0,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_COMPASS_PARITY_PINS),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_COMPASS_PARITY_PINS_TP),
        getFunc = function () return MiniMap.SV.showCompassParityPins ~= false end,
        setFunc = function (value)
            MiniMap.SV.showCompassParityPins = value
            if not value and MiniMap.compassParityController then
                MiniMap.compassParityController:ReleaseAllCompassParityOverlays()
            end
        end,
        width = "full",
        default = Defaults.showCompassParityPins,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_FORCE_QUEST_PINS),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_FORCE_QUEST_PINS_TP),
        getFunc = function () return MiniMap.SV.forceQuestPinsOnMinimap == true end,
        setFunc = function (value)
            MiniMap.SV.forceQuestPinsOnMinimap = value
            if MiniMap.mapEventController then
                MiniMap.mapEventController:RequestQuestPinSync()
            end
        end,
        width = "full",
        default = Defaults.forceQuestPinsOnMinimap,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "checkbox",
        name = GetString(LUIE_STRING_LAM_MINIMAP_KEEP_SQUARE),
        getFunc = function () return MiniMap.SV.keepSquareAspect end,
        setFunc = function (value)
            MiniMap.SV.keepSquareAspect = value
            if value then
                MiniMap.ApplySquareAspect()
            end
        end,
        width = "half",
        default = Defaults.keepSquareAspect,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "slider",
        name = GetString(LUIE_STRING_LAM_MINIMAP_POSITION_GRID),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_POSITION_GRID_TP),
        min = 0,
        max = 8,
        step = 1,
        getFunc = function () return MiniMap.SV.positionGridDivisor or 0 end,
        setFunc = function (value)
            MiniMap.SV.positionGridDivisor = value
            if value > 1 then
                MiniMap.ApplyPositionGridSnap(MiniMap.SV)
            end
        end,
        width = "half",
        default = 0,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "slider",
        name = GetString(LUIE_STRING_LAM_MINIMAP_CAMERA_WEDGE),
        min = 50,
        max = 150,
        step = 5,
        getFunc = function () return (MiniMap.SV.cameraWedgeScale or 1) * 100 end,
        setFunc = function (value)
            MiniMap.SV.cameraWedgeScale = value / 100
            MiniMap.ApplyLiveSettings()
        end,
        width = "full",
        default = 100,
        disabled = disabled,
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "header",
        name = GetString(LUIE_STRING_LAM_MINIMAP_ADVANCED_HEADER),
        width = "full",
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "description",
        text = GetString(LUIE_STRING_LAM_MINIMAP_ADVANCED_DESC),
    }

    if LUIE.IsDevDebugEnabled() then
        optionsDataMiniMap[#optionsDataMiniMap + 1] =
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PIN_MIRROR_STATE_MACHINE_DEBUG_TP),
            getFunc = function () return MiniMap.SV.pinMirrorStateMachineDebug end,
            setFunc = function (value)
                MiniMap.SV.pinMirrorStateMachineDebug = value
                if MiniMap.pinMirrorStateMachine then
                    MiniMap.pinMirrorStateMachine:ApplyDebugLoggingFromSavedVars()
                end
            end,
            width = "full",
            default = Defaults.pinMirrorStateMachineDebug,
            disabled = disabled,
        }
    end

    LAM:RegisterAddonPanel(LUIE.name .. "MiniMapOptions", panelDataMiniMap)
    LAM:RegisterOptionControls(LUIE.name .. "MiniMapOptions", optionsDataMiniMap)
end
