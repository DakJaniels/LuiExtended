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

local miniMapHudVisibilityOptions =
{
    { key = "allowOnGameplayHud",     name = LUIE_STRING_LAM_MINIMAP_SHOW_HUD,         tp = LUIE_STRING_LAM_MINIMAP_SHOW_HUD_TP         },
    { key = "allowDuringCombat",      name = LUIE_STRING_LAM_MINIMAP_SHOW_COMBAT,      tp = LUIE_STRING_LAM_MINIMAP_SHOW_COMBAT_TP      },
    { key = "allowOnLootScene",       name = LUIE_STRING_LAM_MINIMAP_SHOW_LOOT,        tp = LUIE_STRING_LAM_MINIMAP_SHOW_LOOT_TP        },
    { key = "allowOnDeathRecap",      name = LUIE_STRING_LAM_MINIMAP_SHOW_DEATH_RECAP, tp = LUIE_STRING_LAM_MINIMAP_SHOW_DEATH_RECAP_TP },
    { key = "allowWhileMounted",      name = LUIE_STRING_LAM_MINIMAP_SHOW_MOUNTED,     tp = LUIE_STRING_LAM_MINIMAP_SHOW_MOUNTED_TP     },
    { key = "allowInPlayerHousing",   name = LUIE_STRING_LAM_MINIMAP_SHOW_HOUSING,     tp = LUIE_STRING_LAM_MINIMAP_SHOW_HOUSING_TP     },
    { key = "preferElevatedDrawTier", name = LUIE_STRING_LAM_MINIMAP_SHOW_ON_TOP,      tp = LUIE_STRING_LAM_MINIMAP_SHOW_ON_TOP_TP      },
}

local miniMapRegionZoomSliders =
{
    { key = "overworldMultiTileZoom", name = LUIE_STRING_LAM_MINIMAP_SUBZONE_ZOOM,      tp = LUIE_STRING_LAM_MINIMAP_SUBZONE_ZOOM_TP                      },
    { key = "dungeonMapZoom",         name = LUIE_STRING_LAM_MINIMAP_DUNGEON_ZOOM,      tp = LUIE_STRING_LAM_MINIMAP_DUNGEON_ZOOM_TP                      },
    { key = "battlegroundMapZoom",    name = LUIE_STRING_LAM_MINIMAP_BATTLEGROUND_ZOOM, tp = LUIE_STRING_LAM_MINIMAP_BATTLEGROUND_ZOOM_TP                 },
    { key = "mountedZoomMultiplier",  name = LUIE_STRING_LAM_MINIMAP_MOUNTED_ZOOM,      tp = LUIE_STRING_LAM_MINIMAP_MOUNTED_ZOOM_TP,     scale100 = true },
}

local miniMapPinCategoryScales =
{
    { key = "pinScaleQuest",     name = LUIE_STRING_LAM_MINIMAP_PINSCALE_QUEST     },
    { key = "pinScaleGroup",     name = LUIE_STRING_LAM_MINIMAP_PINSCALE_GROUP     },
    { key = "pinScalePoi",       name = LUIE_STRING_LAM_MINIMAP_PINSCALE_POI       },
    { key = "pinScaleWayshrine", name = LUIE_STRING_LAM_MINIMAP_PINSCALE_WAYSHRINE },
    { key = "pinScaleOther",     name = LUIE_STRING_LAM_MINIMAP_PINSCALE_OTHER     },
}

local function GetMiniMapCompassOverrideDropdownItems()
    return
    {
        { name = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_DEFAULT), data = 0 },
        { name = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_HIDE),    data = 1 },
        { name = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_SHOW),    data = 2 },
    }
end

--- @param allSettings table
--- @param sectionLabel string
--- @param sectionRows table|nil
local function appendSection(allSettings, sectionLabel, sectionRows)
    allSettings[#allSettings + 1] =
    {
        type = LHAS.ST_SECTION,
        label = sectionLabel,
    }
    if sectionRows then
        for rowIndex = 1, #sectionRows do
            allSettings[#allSettings + 1] = sectionRows[rowIndex]
        end
    end
end

function MiniMap.CreateConsoleSettings()
    local Defaults = MiniMap.Defaults

    if not LUIE.SV.MiniMap_Enabled then
        return
    end

    local disable = function () return not LUIE.SV.MiniMap_Enabled end

    local panel = LHAS:AddAddon(LUIE.FormatAddonSettingsPanelTitle(LUIE_STRING_LAM_MINIMAP),
                                {
                                    allowDefaults = true,
                                    allowRefresh = true,
                                    defaultsFunction = function ()
                                        MiniMap.ResetPosition()
                                    end,
                                })

    local function refreshPanelControls()
        if panel and panel.UpdateControls then
            panel:UpdateControls()
        end
    end

    local guiRootWidth = GuiRoot:GetWidth()
    local guiRootHeight = GuiRoot:GetHeight()
    local frameSizeMax = zo_min(guiRootWidth, guiRootHeight)

    local zoneNameFontDisabled = function ()
        return disable() or MiniMap.SV.showZoneName == false
    end

    local infoPanelModuleDisabled = function ()
        return disable() or not LUIE.SV.InfoPanel_Enabled
    end

    local cameraWedgeSettingsDisabled = function ()
        return disable() or not MiniMap.SV.followPlayer
    end

    local fontItems = SettingsAPI:GetFontsList()
    local fontStyleItems = {}
    for styleIndex = 1, #LUIE.FONT_STYLE_CHOICES do
        fontStyleItems[styleIndex] =
        {
            name = LUIE.FONT_STYLE_CHOICES[styleIndex],
            data = LUIE.FONT_STYLE_CHOICES_VALUES[styleIndex],
        }
    end
    table.sort(fontStyleItems, function (itemA, itemB) return itemA.name < itemB.name end)

    local generalSectionRows =
    {
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM_TP),
            min = 10,
            max = 180,
            step = 1,
            format = "%.0f",
            getFunction = function () return (MiniMap.SV.resetZoomLevel or Defaults.resetZoomLevel) * 100 end,
            setFunction = function (value)
                MiniMap.SV.resetZoomLevel = value / 100
                MiniMap.ClampSavedDefaultZoom()
                if MiniMap.mapController and MiniMap.mapController:IsReady() then
                    MiniMap.mapController:ApplyZoom(0)
                end
            end,
            default = Defaults.resetZoomLevel * 100,
            disable = disable,
        },
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
        },
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
        },
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
        },
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
        },
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
        },
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT_TP),
            getFunction = function () return MiniMap.SV.waypointClickRequiresShift end,
            setFunction = function (value) MiniMap.SV.waypointClickRequiresShift = value end,
            default = Defaults.waypointClickRequiresShift,
            disable = disable,
        },
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
        },
    }

    local layoutSectionRows =
    {
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_MAP_NOW),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_MAP_NOW_TP),
            buttonText = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_MAP_NOW),
            clickHandler = MiniMap.ToggleConsoleLayoutPreview,
            disable = disable,
        },
        {
            type = LHAS.ST_BUTTON,
            label = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_RESETPOSITION_TP),
            buttonText = GetString(LUIE_STRING_LAM_RESETPOSITION),
            clickHandler = MiniMap.ResetPosition,
            disable = disable,
        },
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_X),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_CONSOLE_POS_X_TP),
            min = -guiRootWidth,
            max = guiRootWidth,
            step = 10,
            format = "%.0f",
            getFunction = function () return MiniMap.SV.offsetX or Defaults.offsetX end,
            setFunction = function (value)
                MiniMap.SV.offsetX = value
                MiniMap.ApplyFrameLayoutFromSavedSettings()
            end,
            default = Defaults.offsetX,
            disable = disable,
        },
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_UF_CFRAMES_POS_Y),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_CONSOLE_POS_Y_TP),
            min = -guiRootHeight,
            max = guiRootHeight,
            step = 10,
            format = "%.0f",
            getFunction = function () return MiniMap.SV.offsetY or Defaults.offsetY end,
            setFunction = function (value)
                MiniMap.SV.offsetY = value
                MiniMap.ApplyFrameLayoutFromSavedSettings()
            end,
            default = Defaults.offsetY,
            disable = disable,
        },
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_FRAME_WIDTH),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_FRAME_WIDTH_TP),
            min = 100,
            max = frameSizeMax,
            step = 4,
            format = "%.0f",
            getFunction = function () return MiniMap.SV.width or Defaults.width end,
            setFunction = function (value)
                MiniMap.SV.width = value
                if MiniMap.SV.keepSquareAspect == true then
                    MiniMap.SV.height = value
                end
                MiniMap.ApplyFrameLayoutFromSavedSettings()
            end,
            default = Defaults.width,
            disable = disable,
        },
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_FRAME_HEIGHT),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_FRAME_HEIGHT_TP),
            min = 100,
            max = frameSizeMax,
            step = 4,
            format = "%.0f",
            getFunction = function () return MiniMap.SV.height or Defaults.height end,
            setFunction = function (value)
                MiniMap.SV.height = value
                if MiniMap.SV.keepSquareAspect == true then
                    MiniMap.SV.width = value
                end
                MiniMap.ApplyFrameLayoutFromSavedSettings()
            end,
            default = Defaults.height,
            disable = function ()
                return disable() or MiniMap.SV.keepSquareAspect == true
            end,
        },
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_KEEP_SQUARE),
            getFunction = function () return MiniMap.SV.keepSquareAspect end,
            setFunction = function (value)
                MiniMap.SV.keepSquareAspect = value
                if value then
                    MiniMap.ApplySquareAspect()
                end
                refreshPanelControls()
            end,
            default = Defaults.keepSquareAspect,
            disable = disable,
        },
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
        },
    }

    local visibilitySectionRows = {}
    for optionIndex = 1, #miniMapHudVisibilityOptions do
        local option = miniMapHudVisibilityOptions[optionIndex]
        local settingKey = option.key
        visibilitySectionRows[#visibilitySectionRows + 1] =
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
        }
    end

    local zoomContextSectionRows = {}
    for sliderIndex = 1, #miniMapRegionZoomSliders do
        local slider = miniMapRegionZoomSliders[sliderIndex]
        zoomContextSectionRows[#zoomContextSectionRows + 1] =
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
        }
    end
    zoomContextSectionRows[#zoomContextSectionRows + 1] =
    {
        type = LHAS.ST_CHECKBOX,
        label = GetString(LUIE_STRING_LAM_MINIMAP_AUTO_ZOOM_EDGE),
        tooltip = GetString(LUIE_STRING_LAM_MINIMAP_AUTO_ZOOM_EDGE_TP),
        getFunction = function () return MiniMap.SV.autoZoomOutAtEdge end,
        setFunction = function (value) MiniMap.SV.autoZoomOutAtEdge = value end,
        default = Defaults.autoZoomOutAtEdge,
        disable = disable,
    }

    local pinCategorySectionRows = {}
    for categoryIndex = 1, #miniMapPinCategoryScales do
        local category = miniMapPinCategoryScales[categoryIndex]
        pinCategorySectionRows[#pinCategorySectionRows + 1] =
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
        }
    end

    local chromeSectionRows =
    {
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_MODE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_MODE_TP),
            items = GetMiniMapCompassOverrideDropdownItems(),
            getFunction = function ()
                return { data = MiniMap.SV.compassOverride or 0 }
            end,
            setFunction = function (_combobox, _value, item)
                MiniMap.SV.compassOverride = item.data
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.compassOverride or 0,
            disable = disable,
        },
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME_TP),
            getFunction = function () return MiniMap.SV.showZoneName ~= false end,
            setFunction = function (value)
                MiniMap.SV.showZoneName = value
                MiniMap.ApplyLiveSettings()
                refreshPanelControls()
            end,
            default = Defaults.showZoneName,
            disable = disable,
        },
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_ZONE_NAME_FONT_HEADER),
            canSelect = false,
        },
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZONE_NAME_FONT_TP),
            items = fontItems,
            getFunction = function ()
                return MiniMap.SV.zoneNameFontFace or Defaults.zoneNameFontFace
            end,
            setFunction = function (_combobox, _value, item)
                MiniMap.SV.zoneNameFontFace = item.data or item.name
                MiniMap.ApplyZoneNameFont()
            end,
            default = Defaults.zoneNameFontFace,
            disable = zoneNameFontDisabled,
        },
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZONE_NAME_FONT_SIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            format = "%.0f",
            getFunction = function () return MiniMap.SV.zoneNameFontSize or Defaults.zoneNameFontSize end,
            setFunction = function (value)
                MiniMap.SV.zoneNameFontSize = value
                MiniMap.ApplyZoneNameFont()
            end,
            default = Defaults.zoneNameFontSize,
            disable = zoneNameFontDisabled,
        },
        {
            type = LHAS.ST_DROPDOWN,
            label = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZONE_NAME_FONT_STYLE_TP),
            items = fontStyleItems,
            getFunction = function ()
                local styleValue = MiniMap.SV.zoneNameFontStyle or Defaults.zoneNameFontStyle
                for choiceIndex = 1, #LUIE.FONT_STYLE_CHOICES_VALUES do
                    if LUIE.FONT_STYLE_CHOICES_VALUES[choiceIndex] == styleValue then
                        return LUIE.FONT_STYLE_CHOICES[choiceIndex]
                    end
                end
                return LUIE.FONT_STYLE_CHOICES[1]
            end,
            setFunction = function (_combobox, _value, item)
                MiniMap.SV.zoneNameFontStyle = item.data
                MiniMap.ApplyZoneNameFont()
            end,
            default = Defaults.zoneNameFontStyle,
            disable = zoneNameFontDisabled,
        },
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_MINIMAP_PLAYER_PIP_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PLAYER_PIP_COLOR_TP),
            getFunction = function ()
                local color = MiniMap.SV.playerPipColor or Defaults.playerPipColor
                return color.r, color.g, color.b, color.a
            end,
            setFunction = function (red, green, blue, alpha)
                MiniMap.SV.playerPipColor = { r = red, g = green, b = blue, a = alpha }
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.playerPipColor,
            disable = disable,
        },
        {
            type = LHAS.ST_COLOR,
            label = GetString(LUIE_STRING_LAM_MINIMAP_CAMERA_WEDGE_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_CAMERA_WEDGE_COLOR_TP),
            getFunction = function ()
                local color = MiniMap.SV.cameraWedgeColor or Defaults.cameraWedgeColor
                return color.r, color.g, color.b, color.a
            end,
            setFunction = function (red, green, blue, alpha)
                MiniMap.SV.cameraWedgeColor = { r = red, g = green, b = blue, a = alpha }
                MiniMap.ApplyLiveSettings()
            end,
            default = Defaults.cameraWedgeColor,
            disable = cameraWedgeSettingsDisabled,
        },
        {
            type = LHAS.ST_CHECKBOX,
            label = GetString(LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL_TP),
            getFunction = function () return MiniMap.SV.anchorInfoPanelToMiniMap == true end,
            setFunction = function (value)
                if value then
                    MiniMap.CaptureInfoPanelAnchorSnapshot()
                end
                MiniMap.SV.anchorInfoPanelToMiniMap = value
                MiniMap.ApplyLiveSettings()
                if not value then
                    MiniMap.RestoreInfoPanelAnchor()
                end
            end,
            default = Defaults.anchorInfoPanelToMiniMap,
            disable = infoPanelModuleDisabled,
        },
    }

    local pinRefreshSectionRows =
    {
        {
            type = LHAS.ST_LABEL,
            label = GetString(LUIE_STRING_LAM_MINIMAP_PIN_REFRESH_DESC),
        },
        {
            type = LHAS.ST_SLIDER,
            label = GetString(LUIE_STRING_LAM_MINIMAP_MOVING_PIN_REFRESH_MS),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_MOVING_PIN_REFRESH_MS_TP),
            min = MiniMap.MINIMAP_PIN_REFRESH_MS_MIN,
            max = MiniMap.MINIMAP_PIN_REFRESH_MS_MAX,
            step = 1,
            format = "%.0f",
            getFunction = function () return MiniMap.GetMovingPinRefreshMs() end,
            setFunction = function (value)
                MiniMap.SV.movingPinRefreshMs = zo_clamp(value, MiniMap.MINIMAP_PIN_REFRESH_MS_MIN, MiniMap.MINIMAP_PIN_REFRESH_MS_MAX)
            end,
            default = Defaults.movingPinRefreshMs,
            disable = disable,
        },
        -- {
        --     type = LHAS.ST_SLIDER,
        --     label = GetString(LUIE_STRING_LAM_MINIMAP_PIN_MOUSEOVER_REFRESH_MS),
        --     tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PIN_MOUSEOVER_REFRESH_MS_TP),
        --     min = MiniMap.MINIMAP_PIN_REFRESH_MS_MIN,
        --     max = MiniMap.MINIMAP_PIN_REFRESH_MS_MAX,
        --     step = 1,
        --     format = "%.0f",
        --     getFunction = function () return MiniMap.GetPinMouseOverRefreshMs() end,
        --     setFunction = function (value)
        --         MiniMap.SV.pinMouseOverRefreshMs = zo_clamp(value, MiniMap.MINIMAP_PIN_REFRESH_MS_MIN, MiniMap.MINIMAP_PIN_REFRESH_MS_MAX)
        --     end,
        --     default = Defaults.pinMouseOverRefreshMs,
        --     disable = disable,
        -- },
    }

    local devAdvancedSectionRows = nil
    if LUIE.IsDevDebugEnabled() then
        devAdvancedSectionRows =
        {
            {
                type = LHAS.ST_LABEL,
                label = GetString(LUIE_STRING_LAM_MINIMAP_ADVANCED_DESC),
            },
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
            },
        }
    end

    local settingsData = {}
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_LABEL,
        label = GetString(LUIE_STRING_LAM_MINIMAP_DESCRIPTION),
        canSelect = false,
    }
    settingsData[#settingsData + 1] =
    {
        type = LHAS.ST_BUTTON,
        label = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        buttonText = GetString(LUIE_STRING_LAM_RELOADUI),
        clickHandler = function ()
            SettingsAPI:ReloadUIWithPendingClear()
        end,
    }

    appendSection(settingsData, GetString(LUIE_STRING_LAM_MINIMAP_CONSOLE_SECTION_GENERAL), generalSectionRows)
    appendSection(settingsData, GetString(LUIE_STRING_LAM_MINIMAP_CONSOLE_LAYOUT_HEADER), layoutSectionRows)
    appendSection(settingsData, GetString(LUIE_STRING_LAM_MINIMAP_VISIBILITY_HEADER), visibilitySectionRows)
    appendSection(settingsData, GetString(LUIE_STRING_LAM_MINIMAP_ZOOM_CONTEXT_HEADER), zoomContextSectionRows)
    appendSection(settingsData, GetString(LUIE_STRING_LAM_MINIMAP_PIN_CATEGORY_HEADER), pinCategorySectionRows)
    appendSection(settingsData, GetString(LUIE_STRING_LAM_MINIMAP_CHROME_HEADER), chromeSectionRows)
    appendSection(settingsData, GetString(LUIE_STRING_LAM_MINIMAP_PIN_REFRESH_HEADER), pinRefreshSectionRows)
    if devAdvancedSectionRows then
        appendSection(settingsData, GetString(LUIE_STRING_LAM_MINIMAP_ADVANCED_HEADER), devAdvancedSectionRows)
    end

    panel:AddSettings(settingsData)
end
