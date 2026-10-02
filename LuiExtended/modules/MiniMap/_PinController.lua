-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- LUIE overlays on view.pins (waypoint + off-center player pip). POI pins live on ZO_WorldMapContainer.

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap
local pinManager = ZO_WorldMap_GetPinManager()
local WAYPOINT_PIN_TEXTURE = "EsoUI/Art/Compass/compass_waypoint.dds"
local WAYPOINT_PIN_CONTROL_NAME = "_PlayerWaypoint"
local PLAYER_MAP_PIN_CONTROL_NAME = "_PlayerMapPin"
local PLAYER_MAP_PIN_TEXTURE = "EsoUI/Art/MapPins/UI-WorldMapPlayerPip.dds"

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
    for _, mapPin in pairs(pinManager:GetActiveObjects()) do
        restoreIfAttached(mapPin)
    end
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
--- @param pinType MapDisplayPinType|nil
--- @return number, number
function MiniMapPinController:GetPinDimensions(pinWidth, pinHeight, pinScale, pinType)
    return MiniMap.ComputePinDrawDimensions(pinWidth, pinHeight, pinScale, pinType, self.mapController)
end

function MiniMapPinController:ResetNativeWorldMapPinUserScale()
    for _, mapPin in pairs(pinManager:GetActiveObjects()) do
        mapPin:ResetScale(false)
    end
end

--- HarvestMap resource pins are CT_TEXTURECOMPOSITE controls on QP_Container.
--- MAIN_MAP_MODE.Activate parents that container to ZO_WorldMapContainer (MapPinController.lua).
--- PinTypeManager:UpdateSize sets dimensions from layout.size and does not reset control scale.
function MiniMapPinController:ApplyHarvestMapCompositeScale()
    local harvestMap = _G["Harvest"]
    if not harvestMap or not harvestMap.pinController then
        return
    end
    local pinTypeManagers = harvestMap.pinController.pinTypeManagers
    if not pinTypeManagers then
        return
    end
    local compositeScale = 1
    if MiniMap.Enabled and MiniMap.IsNativeWorldMapContainerAttached() and not MiniMap.IsWorldMapBlockingMiniMapWork() then
        compositeScale = MiniMap.SV.pinScaleHarvestMap
        if compositeScale == nil then
            compositeScale = 1
        end
    end
    for _, pinTypeManager in pairs(pinTypeManagers) do
        local composite = pinTypeManager.composite
        if composite then
            composite:SetScale(compositeScale)
        end
    end
end

--- QP_Container stays under the hidden ZO_WorldMap until it is parented to ZO_WorldMapContainer.
--- MAIN_MAP_MODE is local to HarvestMap MapPinController.lua, so Activate cannot be called from here.
--- That Activate parents pinController.container the same way. OnMapSizeChange sets MAP_WIDTH.
--- MapPins:RedrawPins is the ZO_WorldMap_UpdateMap prehook, which runs before the tile texture and size exist.
function MiniMapPinController:RefreshHarvestMapPinsForHud()
    local harvestMap = _G["Harvest"]
    if not harvestMap or not harvestMap.pinController or not harvestMap.mapPins then
        return
    end
    local harvestPinContainer = harvestMap.pinController.container
    if not harvestPinContainer then
        return
    end
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    local mapWidth, mapHeight = ZO_WorldMapContainer:GetDimensions()
    if mapWidth <= 0 or mapHeight <= 0 then
        return
    end
    harvestMap.pinController:OnMapSizeChange(mapWidth, mapHeight)
    harvestPinContainer:ClearAnchors()
    harvestPinContainer:SetAnchor(TOPLEFT, ZO_WorldMapContainer, TOPLEFT, 0, 0)
    harvestPinContainer:SetParent(ZO_WorldMapContainer)
    if MiniMap.playerMapMirrorDepth > 0 or DoesCurrentMapMatchMapForPlayerLocation() then
        harvestMap.mapPins:RedrawPins()
    end
end

--- LibMapPins layout callbacks run only from ZO_WorldMapPins_Manager:RefreshCustomPins (MapPin_Manager.lua).
--- ZO_WorldMap_UpdateMap calls that before minimap MAP_WIDTH is set. A nil resize callback never looks up GetMapTileTexture again.
function MiniMap.RefreshCustomPinsForHud()
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    local mapController = MiniMap.mapController
    local loadedMapRawName = mapController and mapController.map and mapController.map.rawName
    if MiniMap.playerMapMirrorDepth == 0 and GetMapName() ~= loadedMapRawName then
        return
    end
    ZO_WorldMap_GetPinManager():RefreshCustomPins()
end

--- LAM pin scale on reparented g_mapPinManager pins (UpdateSize already ran in layout).
function MiniMapPinController:ApplyUserScaleToNativeWorldMapPins()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    local playerWorldPin = pinManager:GetPlayerPin()
    for _, mapPin in pairs(pinManager:GetActiveObjects()) do
        if mapPin ~= playerWorldPin then
            mapPin:SetScaleModifier(MiniMap.GetPinTypeScaleMultiplier(mapPin:GetPinType()))
        end
    end
    self:ApplyHarvestMapCompositeScale()
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
        local pinAlpha = pinColor.a
        if pinAlpha == nil then
            pinAlpha = 1
        end
        surface:SetColor(pinColor.r, pinColor.g, pinColor.b, pinAlpha)
    end
    pin.luiMiniMapPinTexture = pinTexture
end

--- @param pin MiniMapPinControl
--- @param normalizedX number
--- @param normalizedY number
--- @param pinWidth number
--- @param pinHeight number
--- @param pinScale boolean
--- @param pinType MapDisplayPinType|nil
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
    if not normalizedX or not normalizedY then
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
        local playerRed, playerGreen, playerBlue, playerAlpha = MiniMap.GetPlayerPipColor()
        self:ApplyOverlayPinAppearance(pin, pinTexture, drawWidth, drawHeight,
                                       { r = playerRed, g = playerGreen, b = playerBlue, a = playerAlpha })
    else
        pin:SetDimensions(drawWidth, drawHeight)
    end
    pin:ClearAnchors()
    pin:SetAnchor(CENTER, pinsParent, TOPLEFT, pinX, pinY)
end

--- @param mapData MiniMapMapData
function MiniMapPinController:RelayoutActivePinsForUserPinScale(mapData)
    self:RelayoutActivePinsForZoom(mapData)
    self:ApplyUserScaleToNativeWorldMapPins()
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
    if not MiniMap.IsMapNormalizedWaypointPlaced(waypointX, waypointY) then
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
    if MiniMap.SV.showPlayerPip == false then
        self:ReleaseOverlayPin(PLAYER_MAP_PIN_CONTROL_NAME)
        if MiniMap.IsNativeWorldMapContainerAttached() then
            MiniMap.ApplyNativeWorldMapPlayerPinVisibility()
        end
        return
    end

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
    if not MiniMap.IsMapPlayerPositionShownOnHudMap(normalizedX, normalizedY, isShownInCurrentMap) then
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

    local playerRed, playerGreen, playerBlue, playerAlpha = MiniMap.GetPlayerPipColor()
    self:ApplyOverlayPinAppearance(pin, PLAYER_MAP_PIN_TEXTURE, drawSize, drawSize,
                                   { r = playerRed, g = playerGreen, b = playerBlue, a = playerAlpha })
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

local function ReapplyMiniMapPinScaleAfterWorldMapPinRefresh()
    if MiniMap.pinController then
        MiniMap.pinController:ApplyUserScaleToNativeWorldMapPins()
    end
end

ZO_PostHook(ZO_WorldMapPins_Manager, "RefreshCustomPins", ReapplyMiniMapPinScaleAfterWorldMapPinRefresh)
