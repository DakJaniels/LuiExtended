-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- LUIE overlays on view.pins (waypoint + off-center player pip). POI pins live on ZO_WorldMapContainer.

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local WAYPOINT_PIN_TEXTURE = "EsoUI/Art/Compass/compass_waypoint.dds"
local WAYPOINT_PIN_CONTROL_NAME = "_PlayerWaypoint"
local PLAYER_MAP_PIN_CONTROL_NAME = "_PlayerMapPin"
local PLAYER_MAP_PIN_TEXTURE = "EsoUI/Art/MapPins/UI-WorldMapPlayerPip.dds"
local MINIMAP_PIN_MIN_SCALE = 0.6
local MINIMAP_PIN_MAX_SCALE = 1.0
local MINIMAP_PIN_MIN_SIZE = 18

--- @class MiniMapPinController : ZO_InitializingObject
--- @field view MiniMapView
--- @field mapController MiniMapMapController
--- @field overlayPinPool ZO_ObjectPool
local MiniMapPinController = ZO_InitializingObject:Subclass()
MiniMap.MiniMapPinController = MiniMapPinController

--- @param view MiniMapView
--- @param mapController MiniMapMapController
function MiniMapPinController:Initialize(view, mapController)
    self.view = view
    self.mapController = mapController
    self:CreateOverlayPinPool()
end

function MiniMapPinController:CreateOverlayPinPool()
    local pinsParent = self.view.pins
    local pinController = self

    local function createOverlayPinRoot(objectKey)
        local controlName = string.format("%s%s", pinsParent:GetName(), objectKey)
        local root = WINDOW_MANAGER:CreateControl(controlName, pinsParent, CT_CONTROL)
        local background = WINDOW_MANAGER:CreateControl(string.format("%sBackground", controlName), root, CT_TEXTURE)
        background:SetAnchor(TOPLEFT, root, TOPLEFT, 0, 0)
        background:SetAnchor(BOTTOMRIGHT, root, BOTTOMRIGHT, 0, 0)
        root.luiMiniMapPinBackground = background
        return root
    end

    local function overlayPinFactory(_pool, objectKey)
        local existing = pinsParent:GetNamedChild(objectKey) --- @type MiniMapPinControl
        if existing and existing.luiMiniMapPinBackground then
            return existing
        end
        if existing then
            existing:SetParent(nil)
        end
        return createOverlayPinRoot(objectKey)
    end

    local function resetOverlayPin(control)
        control:SetHidden(true)
        control:ClearAnchors()
        control.luiMiniMapNormalizedX = nil
        control.luiMiniMapNormalizedY = nil
        control.luiMiniMapPinWidth = nil
        control.luiMiniMapPinHeight = nil
        control.luiMiniMapPinScale = nil
        control.luiMiniMapPinType = nil
        control.luiMiniMapPinTexture = nil
    end

    self.overlayPinPool = ZO_ObjectPool:New(overlayPinFactory, resetOverlayPin)
    self.overlayPinPool:SetCustomAcquireBehavior(function (control)
        control:SetHidden(false)
    end)
end

function MiniMapPinController:ReleaseAllPinPools()
    self:RestoreAllDigSitePolygonsToWorldMap()
    if self.overlayPinPool then
        self.overlayPinPool:ReleaseAllObjects()
    end
end

--- @param callback fun(mapPin: ZO_MapPin)
function MiniMapPinController:ForEachMirroredAntiquityDigSiteMapPin(callback)
    local pinManager = ZO_WorldMap_GetPinManager()
    local antiquityDigSiteKeys = pinManager.m_keyToPinMapping and pinManager.m_keyToPinMapping.antiquityDigSite
    if antiquityDigSiteKeys then
        for _, keysByTag in pairs(antiquityDigSiteKeys) do
            for _, pinKey in pairs(keysByTag) do
                local mapPin = pinManager:GetActiveObject(pinKey)
                if mapPin and mapPin:IsAntiquityDigSitePin() and mapPin.polygonBlob and mapPin.borderInformation then
                    callback(mapPin)
                end
            end
        end
        return
    end
    for _, mapPin in pairs(pinManager:GetActiveObjects()) do
        if mapPin:IsAntiquityDigSitePin() and mapPin.polygonBlob and mapPin.borderInformation then
            callback(mapPin)
        end
    end
end

--- @param mapPin ZO_MapPin
function MiniMapPinController:RestoreDigSitePolygonToWorldMap(mapPin)
    if not mapPin or not mapPin.polygonBlob then
        if mapPin then
            mapPin.luiMiniMapPolygonOnMiniMap = nil
            mapPin.luiMiniMapDigSiteZoneName = nil
        end
        return
    end
    if not mapPin.luiMiniMapPolygonOnMiniMap then
        return
    end
    local polygonBlob = mapPin.polygonBlob
    polygonBlob:SetParent(ZO_WorldMapContainer)
    mapPin:UpdateSize()
    mapPin:UpdateLocation()
    if ZO_WorldMap_IsWorldMapShowing() then
        polygonBlob:SetHidden(false)
    else
        polygonBlob:SetHidden(true)
    end
    mapPin.luiMiniMapPolygonOnMiniMap = nil
    mapPin.luiMiniMapDigSiteZoneName = nil
end

function MiniMapPinController:RestoreAllDigSitePolygonsToWorldMap()
    local pinController = self
    local function restoreIfAttached(mapPin)
        if mapPin.luiMiniMapPolygonOnMiniMap then
            pinController:RestoreDigSitePolygonToWorldMap(mapPin)
        end
    end
    self:ForEachMirroredAntiquityDigSiteMapPin(restoreIfAttached)
    for _, mapPin in pairs(ZO_WorldMap_GetPinManager():GetActiveObjects()) do
        restoreIfAttached(mapPin)
    end
end

function MiniMapPinController:IsPinSyncCoroutineActive()
    return false
end

function MiniMapPinController:CancelPinSyncCoroutine()
end

--- @param _trace string|nil
function MiniMapPinController:AbortPinSyncCoroutine(_trace)
end

--- @param pinControlName string
function MiniMapPinController:ReleaseOverlayPin(pinControlName)
    if self.overlayPinPool:GetActiveObject(pinControlName) then
        self.overlayPinPool:ReleaseObject(pinControlName)
    end
end

--- @param pinControlName string
--- @return MiniMapPinControl|nil
function MiniMapPinController:AcquireOverlayPin(pinControlName)
    return self.overlayPinPool:AcquireObject(pinControlName)
end

--- @param pin MiniMapPinControl
--- @return TextureControl|nil
function MiniMapPinController:GetOverlayPinTextureSurface(pin)
    return pin.luiMiniMapPinBackground
end

--- @param pinWidth number
--- @param pinHeight number
--- @param pinScale boolean
--- @param pinType MapPinType|nil
--- @return number, number
function MiniMapPinController:GetPinDimensions(pinWidth, pinHeight, pinScale, pinType)
    if pinScale then
        local worldMapWidth, worldMapHeight = ZO_WorldMap_GetMapDimensions()
        local contentHeight = self.mapController:GetMapContentHeight()
        if worldMapHeight and worldMapHeight > 0 and contentHeight > 0 then
            local scaleToMinimap = contentHeight / worldMapHeight
            return pinWidth * scaleToMinimap, pinHeight * scaleToMinimap
        end
        local zoom = MiniMap.zoom
        return pinWidth * zoom, pinHeight * zoom
    end

    local minSize = MINIMAP_PIN_MIN_SIZE
    if pinType and ZO_MapPin.PIN_DATA then
        local pinTypeData = ZO_MapPin.PIN_DATA[pinType]
        if pinTypeData and pinTypeData.minSize then
            minSize = pinTypeData.minSize
        end
    end

    local userScale = MiniMap.GetPinTypeScaleMultiplier(pinType)
    local curvedZoom = zo_clamp(MiniMap.zoom, MINIMAP_PIN_MIN_SCALE, MINIMAP_PIN_MAX_SCALE)
    local uiScale = GetUICustomScale()
    local width = zo_max((pinWidth * curvedZoom * userScale) / uiScale, minSize)
    local height = zo_max((pinHeight * curvedZoom * userScale) / uiScale, minSize)
    return width, height
end

function MiniMapPinController:GetPlayerWaypointTexture()
    local staticTexture = ZO_MapPin.GetStaticPinTexture(MAP_PIN_TYPE_PLAYER_WAYPOINT)
    if staticTexture and staticTexture ~= "" then
        return staticTexture
    end
    return WAYPOINT_PIN_TEXTURE
end

--- @param mapData MiniMapMapData
--- @param normalizedX number
--- @param normalizedY number
--- @return number, number
function MiniMapPinController:GetMapPinOffsets(mapData, normalizedX, normalizedY)
    local contentWidth = self.mapController:GetMapContentWidth()
    local contentHeight = self.mapController:GetMapContentHeight()
    return normalizedX * contentWidth, normalizedY * contentHeight
end

--- @param pin MiniMapPinControl
--- @param pinTexture string
--- @param drawWidth number
--- @param drawHeight number
--- @param pinColor table
function MiniMapPinController:ApplyOverlayPinAppearance(pin, pinTexture, drawWidth, drawHeight, pinColor)
    pin:SetDimensions(drawWidth, drawHeight)
    local surface = self:GetOverlayPinTextureSurface(pin)
    if surface then
        surface:SetTexture(pinTexture)
        surface:SetColor(pinColor.r, pinColor.g, pinColor.b, 1)
    end
    pin.luiMiniMapPinTexture = pinTexture
end

--- @param pin MiniMapPinControl
--- @param normalizedX number
--- @param normalizedY number
--- @param pinWidth number
--- @param pinHeight number
--- @param pinScale boolean
--- @param pinType MapPinType|nil
function MiniMapPinController:SetOverlayPinLayoutMetadata(pin, normalizedX, normalizedY, pinWidth, pinHeight, pinScale, pinType)
    pin.luiMiniMapNormalizedX = normalizedX
    pin.luiMiniMapNormalizedY = normalizedY
    pin.luiMiniMapPinWidth = pinWidth
    pin.luiMiniMapPinHeight = pinHeight
    pin.luiMiniMapPinScale = pinScale
    pin.luiMiniMapPinType = pinType
end

--- @param pin MiniMapPinControl
--- @param pinsParent Control
--- @param mapData MiniMapMapData
function MiniMapPinController:RelayoutOverlayPin(pin, pinsParent, mapData)
    local normalizedX = pin.luiMiniMapNormalizedX
    local normalizedY = pin.luiMiniMapNormalizedY
    if not normalizedX or not normalizedY or normalizedX <= 0 then
        return
    end
    local pinWidth = pin.luiMiniMapPinWidth or 32
    local pinHeight = pin.luiMiniMapPinHeight or 32
    local pinScale = pin.luiMiniMapPinScale
    local pinType = pin.luiMiniMapPinType
    local pinX, pinY = self:GetMapPinOffsets(mapData, normalizedX, normalizedY)
    local drawWidth, drawHeight = self:GetPinDimensions(pinWidth, pinHeight, pinScale, pinType)
    local pinTexture = pin.luiMiniMapPinTexture
    if pinTexture and pinTexture ~= "" then
        self:ApplyOverlayPinAppearance(pin, pinTexture, drawWidth, drawHeight, { r = 1, g = 1, b = 1 })
    else
        pin:SetDimensions(drawWidth, drawHeight)
    end
    pin:ClearAnchors()
    pin:SetAnchor(CENTER, pinsParent, TOPLEFT, pinX, pinY)
end

--- @param mapData MiniMapMapData
function MiniMapPinController:RelayoutActivePinsForUserPinScale(mapData)
    self:RelayoutActivePinsForZoom(mapData)
end

--- @param mapData MiniMapMapData
function MiniMapPinController:RelayoutActivePinsForZoom(mapData)
    local pinsParent = self.view.pins
    for _, pin in pairs(self.overlayPinPool:GetActiveObjects()) do
        self:RelayoutOverlayPin(pin, pinsParent, mapData)
    end
    self:SyncPlayerWaypoint(mapData)
    self:SyncPlayerMapPin(mapData)
end

--- @param mapData MiniMapMapData
function MiniMapPinController:SyncPlayerWaypoint(mapData)
    local waypointX, waypointY = MiniMap.GetMapPlayerWaypointForMirror()
    if not waypointX or waypointX <= 0 or not waypointY or waypointY <= 0 then
        self:ReleaseOverlayPin(WAYPOINT_PIN_CONTROL_NAME)
        return
    end

    local pinsParent = self.view.pins
    local waypointTexture = self:GetPlayerWaypointTexture()
    local pin = self:AcquireOverlayPin(WAYPOINT_PIN_CONTROL_NAME)
    if not pin then
        return
    end
    local pinX, pinY = self:GetMapPinOffsets(mapData, waypointX, waypointY)
    local drawWidth, drawHeight = self:GetPinDimensions(32, 32, false, MAP_PIN_TYPE_PLAYER_WAYPOINT)

    self:ApplyOverlayPinAppearance(pin, waypointTexture, drawWidth, drawHeight, { r = 1, g = 1, b = 1 })
    pin:ClearAnchors()
    pin:SetAnchor(CENTER, pinsParent, TOPLEFT, pinX, pinY)
    pin:SetDrawLayer(DL_OVERLAY)
    pin.zoneName = mapData.rawName
    self:SetOverlayPinLayoutMetadata(pin, waypointX, waypointY, 32, 32, false, MAP_PIN_TYPE_PLAYER_WAYPOINT)
end

--- @param mapData MiniMapMapData
function MiniMapPinController:SyncPlayerMapPin(mapData)
    if MiniMap.IsNativeWorldMapContainerAttached() then
        MiniMap.ApplyNativeWorldMapPlayerPinVisibility()
        if not MiniMap.GetMapFollowsPlayer() then
            self:ReleaseOverlayPin(PLAYER_MAP_PIN_CONTROL_NAME)
            return
        end
    end

    if MiniMap.GetMapFollowsPlayer() then
        self:ReleaseOverlayPin(PLAYER_MAP_PIN_CONTROL_NAME)
        return
    end

    local normalizedX, normalizedY, playerHeading, isShownInCurrentMap = MiniMap.GetMapPlayerPositionForMirror("player")
    if not isShownInCurrentMap or not normalizedX or normalizedX <= 0 then
        self:ReleaseOverlayPin(PLAYER_MAP_PIN_CONTROL_NAME)
        return
    end

    local pinsParent = self.view.pins
    local pin = self:AcquireOverlayPin(PLAYER_MAP_PIN_CONTROL_NAME)
    if not pin then
        return
    end
    local pinX, pinY = self:GetMapPinOffsets(mapData, normalizedX, normalizedY)
    local drawSize = MiniMap.GetPlayerPinDrawSize()

    self:ApplyOverlayPinAppearance(pin, PLAYER_MAP_PIN_TEXTURE, drawSize, drawSize, { r = 1, g = 1, b = 1 })
    local playerPinSurface = self:GetOverlayPinTextureSurface(pin)
    if playerPinSurface then
        playerPinSurface:SetTextureRotation(playerHeading)
    end
    pin:ClearAnchors()
    pin:SetAnchor(CENTER, pinsParent, TOPLEFT, pinX, pinY)
    pin:SetDrawLayer(DL_OVERLAY)
    pin.zoneName = mapData.rawName
    self:SetOverlayPinLayoutMetadata(pin, normalizedX, normalizedY, drawSize, drawSize, false, nil)
end

--- Refreshes ZOS container pins and LUIE waypoint / player overlays.
--- @param mapData MiniMapMapData
function MiniMapPinController:SyncLuiOverlays(mapData)
    MiniMap.TryAttachNativeWorldMapContainer()
    MiniMap.RefreshNativeWorldMapContainer()
    MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
    self:SyncPlayerWaypoint(mapData)
    self:SyncPlayerMapPin(mapData)
end
