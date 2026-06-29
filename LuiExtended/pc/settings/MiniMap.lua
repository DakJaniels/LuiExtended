-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local ipairs = ipairs
local pairs = pairs
local table_insert = table.insert
local zo_strformat = zo_strformat
local LAM = LUIE.LAM

local MINIMAP_LAM_FONT_PREVIEW_SIZE = 14

local miniMapFontChoicesList = nil
local miniMapLamPreviewFontStringCache = {}

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

local function GetMiniMapFontChoicesList()
    if miniMapFontChoicesList then
        return miniMapFontChoicesList
    end
    local fontsList = {}
    for fontName, _ in pairs(LUIE.Fonts) do
        table_insert(fontsList, fontName)
    end
    miniMapFontChoicesList = fontsList
    return fontsList
end

local function ResolveMiniMapFontStyleForPreview(choiceValue, choiceName)
    local value = choiceValue
    if value == nil then
        value = choiceName
    end
    if value == nil then
        return nil
    end
    for styleIndex, styleValue in ipairs(LUIE.FONT_STYLE_CHOICES_VALUES) do
        if styleValue == value then
            return styleValue
        end
    end
    for styleIndex, styleName in ipairs(LUIE.FONT_STYLE_CHOICES) do
        if styleName == value then
            return LUIE.FONT_STYLE_CHOICES_VALUES[styleIndex]
        end
    end
    return value
end

local function CachedMiniMapLamPreviewFontString(facePath, size, style)
    -- Named fonts (ZoFont*/LUIE_Font_*) are applied as-is; only slug faces compose.
    if LUIE.Font.IsNamedData(facePath) then
        return facePath
    end
    local cacheKey = (facePath or "") .. "\0" .. tostring(size) .. "\0" .. tostring(style or "")
    local cached = miniMapLamPreviewFontStringCache[cacheKey]
    if cached == nil then
        cached = LUIE.CreateFontString(facePath, size, style)
        miniMapLamPreviewFontStringCache[cacheKey] = cached
    end
    return cached
end

local function CreateMiniMapZoneNameFaceItemFont(getStyle)
    return function (faceKey, choiceName)
        local facePath = LUIE.Fonts[faceKey]
        if not facePath then
            return nil
        end
        local styleResolved
        if getStyle then
            styleResolved = ResolveMiniMapFontStyleForPreview(getStyle(), nil)
        end
        return CachedMiniMapLamPreviewFontString(facePath, MINIMAP_LAM_FONT_PREVIEW_SIZE, styleResolved)
    end
end

local function CreateMiniMapZoneNameStyleItemFont(getFace)
    return function (styleValue, choiceName)
        local styleResolved = ResolveMiniMapFontStyleForPreview(styleValue, choiceName)
        local faceKey = getFace and getFace() or nil
        local facePath = (faceKey and LUIE.Fonts[faceKey]) or LUIE.Fonts["LUIE Default Font"]
        if not facePath then
            return nil
        end
        return CachedMiniMapLamPreviewFontString(facePath, MINIMAP_LAM_FONT_PREVIEW_SIZE, styleResolved)
    end
end

function MiniMap.CreateSettings()
    local Defaults = MiniMap.Defaults

    if not LUIE.SV.MiniMap_Enabled then
        return
    end

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
        width = "full",
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "button",
        name = GetString(LUIE_STRING_LAM_RELOADUI),
        tooltip = GetString(LUIE_STRING_LAM_RELOADUI_BUTTON),
        func = function () ReloadUI("ingame") end,
        width = "full",
    }

    local generalControls =
    {
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM_TP),
            min = 10,
            max = 180,
            step = 1,
            getFunc = function () return (MiniMap.SV.resetZoomLevel or Defaults.resetZoomLevel) * 100 end,
            setFunc = function (value)
                MiniMap.SV.resetZoomLevel = value / 100
                MiniMap.ClampSavedDefaultZoom()
                if MiniMap.mapController and MiniMap.mapController:IsReady() then
                    MiniMap.mapController:ApplyZoom(0)
                end
            end,
            width = "full",
            default = Defaults.resetZoomLevel * 100,
            disabled = disabled,
        },
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
        },
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
        },
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
        },
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
        },
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
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_WAYPOINT_SHIFT_TP),
            getFunc = function () return MiniMap.SV.waypointClickRequiresShift end,
            setFunc = function (value) MiniMap.SV.waypointClickRequiresShift = value end,
            width = "full",
            default = Defaults.waypointClickRequiresShift,
            disabled = disabled,
        },
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
        },
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_MINIMAP_CONSOLE_SECTION_GENERAL),
        disabled = disabled,
        controls = generalControls,
    }

    local layoutControls =
    {
        {
            type = "button",
            name = GetString(LUIE_STRING_LAM_RESETPOSITION),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_RESETPOSITION_TP),
            func = function () MiniMap.ResetPosition() end,
            width = "full",
            disabled = disabled,
        },
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
        },
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
        },
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_MINIMAP_CONSOLE_LAYOUT_HEADER),
        disabled = disabled,
        controls = layoutControls,
    }

    local visibilityControls = {}
    for optionIndex = 1, #miniMapHudVisibilityOptions do
        local option = miniMapHudVisibilityOptions[optionIndex]
        local settingKey = option.key
        visibilityControls[#visibilityControls + 1] =
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
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_MINIMAP_VISIBILITY_HEADER),
        disabled = disabled,
        controls = visibilityControls,
    }

    local zoomContextControls = {}
    for sliderIndex = 1, #miniMapRegionZoomSliders do
        local slider = miniMapRegionZoomSliders[sliderIndex]
        zoomContextControls[#zoomContextControls + 1] =
        {
            type = "slider",
            name = GetString(slider.name),
            tooltip = GetString(slider.tp),
            min = slider.scale100 and 50 or 10,
            max = slider.scale100 and 200 or 180,
            step = 1,
            getFunc = function ()
                local value = MiniMap.SV[slider.key] or Defaults[slider.key]
                return value * 100
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
    zoomContextControls[#zoomContextControls + 1] =
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
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_MINIMAP_ZOOM_CONTEXT_HEADER),
        disabled = disabled,
        controls = zoomContextControls,
    }

    local pinCategoryControls = {}
    for categoryIndex = 1, #miniMapPinCategoryScales do
        local category = miniMapPinCategoryScales[categoryIndex]
        pinCategoryControls[#pinCategoryControls + 1] =
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
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_MINIMAP_PIN_CATEGORY_HEADER),
        disabled = disabled,
        controls = pinCategoryControls,
    }

    local zoneNameFontDisabled = function ()
        return disabled() or MiniMap.SV.showZoneName == false
    end

    local zoneNameFontSubmenuControls =
    {
        {
            type = "fontable_dropdown",
            name = GetString(LUIE_STRING_LAM_FONT),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZONE_NAME_FONT_TP),
            choices = GetMiniMapFontChoicesList(),
            sort = "name-up",
            scrollable = 7,
            getFunc = function () return MiniMap.SV.zoneNameFontFace end,
            setFunc = function (var)
                MiniMap.SV.zoneNameFontFace = var
                MiniMap.ApplyZoneNameFont()
            end,
            itemFont = CreateMiniMapZoneNameFaceItemFont(function () return MiniMap.SV.zoneNameFontStyle end),
            width = "full",
            disabled = zoneNameFontDisabled,
            default = Defaults.zoneNameFontFace,
        },
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_FONT_SIZE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZONE_NAME_FONT_SIZE_TP),
            min = 10,
            max = 30,
            step = 1,
            getFunc = function () return MiniMap.SV.zoneNameFontSize end,
            setFunc = function (value)
                MiniMap.SV.zoneNameFontSize = value
                MiniMap.ApplyZoneNameFont()
            end,
            width = "full",
            default = Defaults.zoneNameFontSize,
            disabled = zoneNameFontDisabled,
        },
        {
            type = "fontable_dropdown",
            name = GetString(LUIE_STRING_LAM_FONT_STYLE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ZONE_NAME_FONT_STYLE_TP),
            choices = LUIE.FONT_STYLE_CHOICES,
            choicesValues = LUIE.FONT_STYLE_CHOICES_VALUES,
            getFunc = function () return MiniMap.SV.zoneNameFontStyle end,
            setFunc = function (var)
                MiniMap.SV.zoneNameFontStyle = var
                MiniMap.ApplyZoneNameFont()
            end,
            itemFont = CreateMiniMapZoneNameStyleItemFont(function () return MiniMap.SV.zoneNameFontFace end),
            width = "full",
            disabled = zoneNameFontDisabled,
            default = Defaults.zoneNameFontStyle,
        },
    }

    local infoPanelModuleDisabled = function ()
        return disabled() or not LUIE.SV.InfoPanel_Enabled
    end

    local cameraWedgeSettingsDisabled = function ()
        return disabled() or not MiniMap.SV.followPlayer
    end

    local appearanceControls =
    {
        {
            type = "dropdown",
            name = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_MODE),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_MODE_TP),
            choices =
            {
                GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_DEFAULT),
                GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_HIDE),
                GetString(LUIE_STRING_LAM_MINIMAP_COMPASS_OVERRIDE_SHOW),
            },
            choicesValues = { 0, 1, 2 },
            getFunc = function () return MiniMap.SV.compassOverride or 0 end,
            setFunc = function (value)
                MiniMap.SV.compassOverride = value
                MiniMap.ApplyLiveSettings()
            end,
            width = "full",
            default = 0,
            disabled = disabled,
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_SHOW_ZONE_NAME_TP),
            getFunc = function () return MiniMap.SV.showZoneName ~= false end,
            setFunc = function (value)
                MiniMap.SV.showZoneName = value
                MiniMap.ApplyLiveSettings()
            end,
            width = "full",
            default = Defaults.showZoneName,
            disabled = disabled,
        },
        {
            type = "submenu",
            name = GetString(LUIE_STRING_LAM_MINIMAP_ZONE_NAME_FONT_HEADER),
            disabled = zoneNameFontDisabled,
            controls = zoneNameFontSubmenuControls,
        },
        {
            type = "colorpicker",
            name = GetString(LUIE_STRING_LAM_MINIMAP_PLAYER_PIP_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PLAYER_PIP_COLOR_TP),
            getFunc = function ()
                local color = MiniMap.SV.playerPipColor or Defaults.playerPipColor
                return color.r, color.g, color.b, color.a
            end,
            setFunc = function (red, green, blue, alpha)
                MiniMap.SV.playerPipColor = { r = red, g = green, b = blue, a = alpha }
                MiniMap.ApplyLiveSettings()
            end,
            width = "half",
            disabled = disabled,
            default =
            {
                r = Defaults.playerPipColor.r,
                g = Defaults.playerPipColor.g,
                b = Defaults.playerPipColor.b,
                a = Defaults.playerPipColor.a,
            },
        },
        {
            type = "colorpicker",
            name = GetString(LUIE_STRING_LAM_MINIMAP_CAMERA_WEDGE_COLOR),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_CAMERA_WEDGE_COLOR_TP),
            getFunc = function ()
                local color = MiniMap.SV.cameraWedgeColor or Defaults.cameraWedgeColor
                return color.r, color.g, color.b, color.a
            end,
            setFunc = function (red, green, blue, alpha)
                MiniMap.SV.cameraWedgeColor = { r = red, g = green, b = blue, a = alpha }
                MiniMap.ApplyLiveSettings()
            end,
            width = "half",
            disabled = cameraWedgeSettingsDisabled,
            default =
            {
                r = Defaults.cameraWedgeColor.r,
                g = Defaults.cameraWedgeColor.g,
                b = Defaults.cameraWedgeColor.b,
                a = Defaults.cameraWedgeColor.a,
            },
        },
        {
            type = "checkbox",
            name = GetString(LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_ANCHOR_INFOPANEL_TP),
            getFunc = function () return MiniMap.SV.anchorInfoPanelToMiniMap == true end,
            setFunc = function (value)
                if value then
                    MiniMap.CaptureInfoPanelAnchorSnapshot()
                end
                MiniMap.SV.anchorInfoPanelToMiniMap = value
                MiniMap.ApplyLiveSettings()
                if not value then
                    MiniMap.RestoreInfoPanelAnchor()
                end
            end,
            width = "full",
            default = Defaults.anchorInfoPanelToMiniMap,
            disabled = infoPanelModuleDisabled,
        },
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_MINIMAP_CHROME_HEADER),
        disabled = disabled,
        controls = appearanceControls,
    }

    local pinRefreshControls =
    {
        {
            type = "description",
            text = GetString(LUIE_STRING_LAM_MINIMAP_PIN_REFRESH_DESC),
            width = "full",
        },
        {
            type = "slider",
            name = GetString(LUIE_STRING_LAM_MINIMAP_MOVING_PIN_REFRESH_MS),
            tooltip = GetString(LUIE_STRING_LAM_MINIMAP_MOVING_PIN_REFRESH_MS_TP),
            min = MiniMap.MINIMAP_PIN_REFRESH_MS_MIN,
            max = MiniMap.MINIMAP_PIN_REFRESH_MS_MAX,
            step = 1,
            getFunc = function () return MiniMap.GetMovingPinRefreshMs() end,
            setFunc = function (value)
                MiniMap.SV.movingPinRefreshMs = zo_clamp(value, MiniMap.MINIMAP_PIN_REFRESH_MS_MIN, MiniMap.MINIMAP_PIN_REFRESH_MS_MAX)
            end,
            width = "full",
            default = Defaults.movingPinRefreshMs,
            disabled = disabled,
        },
        -- {
        --     type = "slider",
        --     name = GetString(LUIE_STRING_LAM_MINIMAP_PIN_MOUSEOVER_REFRESH_MS),
        --     tooltip = GetString(LUIE_STRING_LAM_MINIMAP_PIN_MOUSEOVER_REFRESH_MS_TP),
        --     min = MiniMap.MINIMAP_PIN_REFRESH_MS_MIN,
        --     max = MiniMap.MINIMAP_PIN_REFRESH_MS_MAX,
        --     step = 1,
        --     getFunc = function () return MiniMap.GetPinMouseOverRefreshMs() end,
        --     setFunc = function (value)
        --         MiniMap.SV.pinMouseOverRefreshMs = zo_clamp(value, MiniMap.MINIMAP_PIN_REFRESH_MS_MIN, MiniMap.MINIMAP_PIN_REFRESH_MS_MAX)
        --     end,
        --     width = "full",
        --     default = Defaults.pinMouseOverRefreshMs,
        --     disabled = disabled,
        -- },
    }

    optionsDataMiniMap[#optionsDataMiniMap + 1] =
    {
        type = "submenu",
        name = GetString(LUIE_STRING_LAM_MINIMAP_PIN_REFRESH_HEADER),
        disabled = disabled,
        controls = pinRefreshControls,
    }

    if LUIE.IsDevDebugEnabled() then
        local devAdvancedControls =
        {
            {
                type = "description",
                text = GetString(LUIE_STRING_LAM_MINIMAP_ADVANCED_DESC),
                width = "full",
            },
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
            },
        }

        optionsDataMiniMap[#optionsDataMiniMap + 1] =
        {
            type = "submenu",
            name = GetString(LUIE_STRING_LAM_MINIMAP_ADVANCED_HEADER),
            disabled = disabled,
            controls = devAdvancedControls,
        }
    end

    LAM:RegisterAddonPanel(LUIE.name .. "MiniMapOptions", panelDataMiniMap)
    LAM:RegisterOptionControls(LUIE.name .. "MiniMapOptions", optionsDataMiniMap)
end
