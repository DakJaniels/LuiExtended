-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local HARVEST_MAP_TOUR_PIN_TYPE_STRING = "MAP_PIN_TYPE_HARVEST_TOUR"
local POLYGON_CENTER_ALPHA = 0.39  -- ZO_MapPin:UpdateSize (EsoUI/Ingame/Map/MapPin.lua:2870)
local KEEP_LINK_BASE_THICKNESS = 8 -- ZO_MapKeepLink virtual (WorldMap.xml)
local KEEP_LINK_MIN_THICKNESS = 2

--- Pin filter group -> saved scale key (ZO_MapPin.PIN_TYPE_TO_PIN_GROUP, MapPin.lua:656).
local PIN_FILTER_GROUP_TO_SCALE_SETTING_KEY =
{
    [MAP_FILTER_QUESTS] = "pinScaleQuest",
    [MAP_FILTER_GROUP_MEMBERS] = "pinScaleGroup",
    [MAP_FILTER_WAYSHRINES] = "pinScaleWayshrine",
    [MAP_FILTER_OBJECTIVES] = "pinScalePoi",
    [MAP_FILTER_DIG_SITES] = "pinScaleDigSite",
}

--- @param pinType integer|nil
--- @return boolean
function MiniMap.IsHarvestMapCustomPinType(pinType)
    if not pinType then
        return false
    end
    local customPins = ZO_WorldMap_GetPinManager().customPins
    if not customPins then
        return false
    end
    local customPinData = customPins[pinType]
    return customPinData ~= nil and customPinData.pinTypeString == HARVEST_MAP_TOUR_PIN_TYPE_STRING
end

--- User scale for a world-map pin type: explicit per-type override, HarvestMap, filter-group category, then "other".
--- @param pinType integer|nil
--- @return number
function MiniMap.GetPinTypeScaleMultiplier(pinType)
    local settings = MiniMap.SV
    local baseScale = settings.defaultPinScale or 1
    if pinType and settings.pinTypeScales and settings.pinTypeScales[pinType] then
        return baseScale * settings.pinTypeScales[pinType]
    end
    if pinType and MiniMap.IsHarvestMapCustomPinType(pinType) then
        local harvestMapScale = settings.pinScaleHarvestMap
        if harvestMapScale == nil then
            harvestMapScale = 1
        end
        return baseScale * harvestMapScale
    end
    if pinType then
        local pinGroup = ZO_MapPin.PIN_TYPE_TO_PIN_GROUP[pinType]
        local scaleSettingKey = pinGroup and PIN_FILTER_GROUP_TO_SCALE_SETTING_KEY[pinGroup]
        local categoryScale = scaleSettingKey and settings[scaleSettingKey]
        if categoryScale then
            return baseScale * categoryScale
        end
    end
    if settings.pinScaleOther then
        return baseScale * settings.pinScaleOther
    end
    return baseScale
end

--- @class LUIE_MiniMap_PinEntry
--- @field worldMapPin ZO_MapPin
--- @field pinControl LUIE_MiniMap_PinControl
--- @field pinKey any
--- @field areaControl TextureControl|nil
--- @field areaKey any
--- @field polygonControl PolygonControl|nil
--- @field polygonKey any
--- @field generation integer
--- @field isMoving boolean
--- @field isAnimated boolean
--- @field isPlayer boolean
--- @field lastNormalizedX number|nil
--- @field lastNormalizedY number|nil
--- @field lastHidden boolean|nil
--- @field lastSize number|nil
--- @field lastRotation number|nil
--- @field lastTexture string|nil
--- @field lastHighlightTexture string|nil

--- Mirrors the world-map pin manager (ZO_WorldMap_GetPinManager()) and keep network into minimap-owned
--- control pools. Nothing in the world map `ZO_WorldMapContainer` tree is reparented or modified.
--- @class LUIE_MiniMap_PinLayer : ZO_InitializingObject
--- @field manager LUIE_MiniMap_Manager
--- @field panAndZoom LUIE_MiniMap_PanAndZoom
--- @field pinsContainer Control
--- @field polygonsContainer Control
--- @field linksContainer Control
--- @field pinPool ZO_ControlPool
--- @field areaBlobPool ZO_ControlPool
--- @field polygonPool ZO_ControlPool
--- @field linkPool ZO_ControlPool
--- @field pinEntriesByWorldMapPin table<ZO_MapPin, LUIE_MiniMap_PinEntry>
--- @field playerPinEntry LUIE_MiniMap_PinEntry|nil
--- @field generation integer
--- @field pinsDirty boolean
--- @field linksDirty boolean
LUIE_MiniMap_PinLayer = ZO_InitializingObject:Subclass()

--- Hooks are installed on class tables once per session; they forward to whichever layer is active.
--- @type LUIE_MiniMap_PinLayer|nil
LUIE_MiniMap_PinLayer.activeLayer = nil
LUIE_MiniMap_PinLayer.hooksSetUp = false

local function MarkActiveLayerPinsDirty()
    local activeLayer = LUIE_MiniMap_PinLayer.activeLayer
    if activeLayer then
        activeLayer.pinsDirty = true
    end
end

local function MarkActiveLayerLinksDirty()
    local activeLayer = LUIE_MiniMap_PinLayer.activeLayer
    if activeLayer then
        activeLayer.linksDirty = true
    end
end

function LUIE_MiniMap_PinLayer.SetupHooks()
    if LUIE_MiniMap_PinLayer.hooksSetUp then
        return
    end
    LUIE_MiniMap_PinLayer.hooksSetUp = true
    -- EsoUI/Ingame/Map/MapPin_Manager.lua: CreatePin (465), RemovePins (584); ReleaseObject/ReleaseAllObjects are
    -- inherited from ZO_ObjectPool (ZO_PostHook resolves them through the class metatable and writes the wrapper
    -- onto ZO_WorldMapPins_Manager only).
    ZO_PostHook(ZO_WorldMapPins_Manager, "CreatePin", MarkActiveLayerPinsDirty)
    ZO_PostHook(ZO_WorldMapPins_Manager, "RemovePins", MarkActiveLayerPinsDirty)
    ZO_PostHook(ZO_WorldMapPins_Manager, "ReleaseObject", MarkActiveLayerPinsDirty)
    ZO_PostHook(ZO_WorldMapPins_Manager, "ReleaseAllObjects", MarkActiveLayerPinsDirty)
    -- EsoUI/Ingame/Map/MapPin.lua: SetData (2936) re-skins a pin in place (ChangePinType, tint, glow).
    ZO_PostHook(ZO_MapPin, "SetData", MarkActiveLayerPinsDirty)
    -- EsoUI/Ingame/Map/WorldMap.lua: ZO_KeepNetwork:RefreshLinks (610).
    ZO_PostHook(ZO_KeepNetwork, "RefreshLinks", MarkActiveLayerLinksDirty)
end

--- @param manager LUIE_MiniMap_Manager
--- @param pinsContainer Control
--- @param polygonsContainer Control
--- @param linksContainer Control
function LUIE_MiniMap_PinLayer:Initialize(manager, pinsContainer, polygonsContainer, linksContainer)
    self.manager = manager
    self.panAndZoom = manager.panAndZoom
    self.pinsContainer = pinsContainer
    self.polygonsContainer = polygonsContainer
    self.linksContainer = linksContainer
    self.pinPool = ZO_ControlPool:New("LUIE_MiniMap_Pin", pinsContainer, "Pin")
    self.areaBlobPool = ZO_ControlPool:New("LUIE_MiniMap_AreaBlob", polygonsContainer, "Area")
    self.polygonPool = ZO_ControlPool:New("LUIE_MiniMap_PolygonBlob", polygonsContainer, "Polygon")
    self.linkPool = ZO_ControlPool:New("LUIE_MiniMap_KeepLink", linksContainer, "Link")
    self.pinEntriesByWorldMapPin = {}
    self.playerPinEntry = nil
    self.generation = 0
    self.pinsDirty = true
    self.linksDirty = true
    LUIE_MiniMap_PinLayer.SetupHooks()
end

function LUIE_MiniMap_PinLayer:Activate()
    LUIE_MiniMap_PinLayer.activeLayer = self
    self.pinsDirty = true
    self.linksDirty = true
end

function LUIE_MiniMap_PinLayer:Deactivate()
    if LUIE_MiniMap_PinLayer.activeLayer == self then
        LUIE_MiniMap_PinLayer.activeLayer = nil
    end
end

function LUIE_MiniMap_PinLayer:MarkAllDirty()
    self.pinsDirty = true
    self.linksDirty = true
end

function LUIE_MiniMap_PinLayer:ReleaseAll()
    self.pinPool:ReleaseAllObjects()
    self.areaBlobPool:ReleaseAllObjects()
    self.polygonPool:ReleaseAllObjects()
    self.linkPool:ReleaseAllObjects()
    self.pinEntriesByWorldMapPin = {}
    self.playerPinEntry = nil
    self.pinsDirty = true
    self.linksDirty = true
end

-- Sizing ---------------------------------------------------------------------

--- ZO_MapPin:UpdateSize formula (MapPin.lua:2881-2883) with the minimap zoom curve and the user scale multiplier.
--- @param pinType integer
--- @return number
function LUIE_MiniMap_PinLayer:ComputePinSize(pinType)
    local singlePinData = ZO_MapPin.PIN_DATA[pinType]
    local baseSize = MiniMap.MINIMAP_PIN_DEFAULT_SIZE
    local minSize = MiniMap.MINIMAP_PIN_MIN_SIZE
    if singlePinData then
        baseSize = singlePinData.size or baseSize
        minSize = singlePinData.minSize or minSize
    end
    local userScale
    if pinType == MAP_PIN_TYPE_PLAYER then
        -- Player pin follows the Player Pip scale only (old ApplyNativeHudPlayerPinScale: SetScaleModifier(drawSize / base)).
        userScale = MiniMap.SV.playerPinScale or MiniMap.Defaults.playerPinScale
    else
        userScale = MiniMap.GetPinTypeScaleMultiplier(pinType)
    end
    return zo_max((baseSize * self.panAndZoom:GetCurvedPinScale() * userScale) / GetUICustomScale(), minSize)
end

--- The world-map player pin is the camera-heading pip (ZO_WorldMapPins_Manager:UpdateMovingPins rotates it by
--- GetPlayerCameraHeading, MapPin_Manager.lua:786). It stays visible while following next to the centre
--- character arrow; `showPlayerPip` only hides it when the map is panned or scroll-locked.
--- @return boolean
function LUIE_MiniMap_PinLayer:IsPlayerPinEntryHidden()
    return (not self.panAndZoom:GetFollowsPlayer()) and MiniMap.SV.showPlayerPip == false
end

-- Per-frame entry point ------------------------------------------------------

--- Called from the manager interval update while the map is idle and the fragment is showing.
function LUIE_MiniMap_PinLayer:Update()
    if self.pinsDirty then
        self.pinsDirty = false
        self:RefreshAllPins()
    else
        self:UpdateMovingPins()
    end
    if self.linksDirty then
        self.linksDirty = false
        self:RefreshLinks()
    end
end

--- Content size or user scale changed: every pin entry needs new dimensions and anchors.
function LUIE_MiniMap_PinLayer:RelayoutAll()
    self:RefreshAllPins()
    self:RefreshLinks()
    self.pinsDirty = false
    self.linksDirty = false
end

-- Pin entry -----------------------------------------------------------------

--- @param worldMapPin ZO_MapPin
--- @return LUIE_MiniMap_PinEntry
function LUIE_MiniMap_PinLayer:CreatePinEntry(worldMapPin)
    local pinControl, pinKey = self.pinPool:AcquireObject()
    --- @cast pinControl LUIE_MiniMap_PinControl
    if not pinControl.background then
        pinControl.background = pinControl:GetNamedChild("Background")
        pinControl.highlight = pinControl:GetNamedChild("Highlight")
    end
    local pinType = worldMapPin:GetPinType()
    local singlePinData = ZO_MapPin.PIN_DATA[pinType]
    --- @type LUIE_MiniMap_PinEntry
    local pinEntry =
    {
        worldMapPin = worldMapPin,
        pinControl = pinControl,
        pinKey = pinKey,
        generation = 0,
        isMoving = worldMapPin:IsUnit() or worldMapPin:IsObjective(),
        isAnimated = singlePinData ~= nil and singlePinData.isAnimated == true,
        isPlayer = pinType == MAP_PIN_TYPE_PLAYER,
    }
    self.pinEntriesByWorldMapPin[worldMapPin] = pinEntry
    return pinEntry
end

--- @param worldMapPin ZO_MapPin
--- @param pinEntry LUIE_MiniMap_PinEntry
function LUIE_MiniMap_PinLayer:ReleasePinEntry(worldMapPin, pinEntry)
    self.pinPool:ReleaseObject(pinEntry.pinKey)
    if pinEntry.areaKey then
        self.areaBlobPool:ReleaseObject(pinEntry.areaKey)
    end
    if pinEntry.polygonKey then
        self.polygonPool:ReleaseObject(pinEntry.polygonKey)
    end
    if self.playerPinEntry == pinEntry then
        self.playerPinEntry = nil
    end
    self.pinEntriesByWorldMapPin[worldMapPin] = nil
end

function LUIE_MiniMap_PinLayer:RefreshAllPins()
    local pinManager = ZO_WorldMap_GetPinManager()
    local activePins = pinManager:GetActiveObjects()
    self.generation = self.generation + 1
    local generation = self.generation
    local contentWidth = self.panAndZoom:GetContentWidth()
    local contentHeight = self.panAndZoom:GetContentHeight()
    local playerPinHidden = self:IsPlayerPinEntryHidden()

    for _, worldMapPin in pairs(activePins) do
        local pinEntry = self.pinEntriesByWorldMapPin[worldMapPin]
        if not pinEntry then
            pinEntry = self:CreatePinEntry(worldMapPin)
        end
        pinEntry.generation = generation
        self:ApplyPinEntryAppearance(pinEntry, contentWidth, contentHeight, playerPinHidden)
    end

    for worldMapPin, pinEntry in pairs(self.pinEntriesByWorldMapPin) do
        if pinEntry.generation ~= generation then
            self:ReleasePinEntry(worldMapPin, pinEntry)
        end
    end
end

--- Light pass: unit, objective and animated pins re-read position/visibility only.
--- The player pin entry is skipped here; LUIE_MiniMap_Manager:OnFrameUpdate drives it every frame via UpdatePlayerPinEntry.
function LUIE_MiniMap_PinLayer:UpdateMovingPins()
    local contentWidth = self.panAndZoom:GetContentWidth()
    local contentHeight = self.panAndZoom:GetContentHeight()
    local playerPinHidden = self:IsPlayerPinEntryHidden()
    for _, pinEntry in pairs(self.pinEntriesByWorldMapPin) do
        if (pinEntry.isMoving or pinEntry.isAnimated) and not pinEntry.isPlayer then
            self:ApplyPinEntryPosition(pinEntry, contentWidth, contentHeight, playerPinHidden)
            if pinEntry.isAnimated then
                local worldMapBackground = pinEntry.worldMapPin.backgroundControl
                pinEntry.pinControl.background:SetTextureCoords(worldMapBackground:GetTextureCoords())
            end
        end
    end
end

--- @param pinEntry LUIE_MiniMap_PinEntry
--- @param contentWidth number
--- @param contentHeight number
--- @param playerPinHidden boolean
function LUIE_MiniMap_PinLayer:ApplyPinEntryPosition(pinEntry, contentWidth, contentHeight, playerPinHidden)
    local worldMapPin = pinEntry.worldMapPin
    -- IsControlHidden() reads the pin's own flag (ZO_MapPin:SetLocation, MapPin.lua:3113 `myControl:SetHidden(not valid)`).
    -- IsHidden() would include ancestors and ZO_WorldMap is hidden whenever the minimap is running.
    local hidden = worldMapPin:GetControl():IsControlHidden() or (pinEntry.isPlayer and playerPinHidden)
    local normalizedX, normalizedY
    if not hidden then
        normalizedX, normalizedY = worldMapPin:GetNormalizedPosition()
    end
    local rotation = nil
    if pinEntry.isPlayer then
        -- ZO_WorldMapPins_Manager:UpdateMovingPins rotates the player pin by GetPlayerCameraHeading (MapPin_Manager.lua:795).
        rotation = GetPlayerCameraHeading()
    end
    self:ApplyPinEntryPlacement(pinEntry, hidden, normalizedX, normalizedY, rotation, contentWidth, contentHeight)
end

--- Per-frame player pin entry. Position comes from the same GetMapPlayerPosition read that scrolls the map, so the
--- camera pip and the map centre move in the same frame; the world-map player pin only refreshes when the hidden world
--- map is updated (interval update) and at ZOS's PIN_UPDATE_DELAY, which is what made the pip step behind the map.
--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param isShownInCurrentMap boolean|nil
--- @param isSymbolicLocation boolean|nil
function LUIE_MiniMap_PinLayer:UpdatePlayerPinEntry(normalizedX, normalizedY, isShownInCurrentMap, isSymbolicLocation)
    local pinEntry = self.playerPinEntry
    if not pinEntry then
        return
    end
    -- MapPin_Manager.lua:793-799: shown only when isShownInCurrentMap; rotation 0 for symbolic locations.
    local hidden = not LUIE_MiniMap_PanAndZoom.IsPlayerPositionShown(normalizedX, normalizedY, isShownInCurrentMap) or self:IsPlayerPinEntryHidden()
    local rotation = 0
    if not isSymbolicLocation then
        rotation = GetPlayerCameraHeading()
    end
    self:ApplyPinEntryPlacement(pinEntry, hidden, normalizedX, normalizedY, rotation, self.panAndZoom:GetContentWidth(), self.panAndZoom:GetContentHeight())
end

--- Shared placement: hidden flag, anchor (only when the normalized position changed) and optional background rotation.
--- @param pinEntry LUIE_MiniMap_PinEntry
--- @param hidden boolean
--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param rotation number|nil
--- @param contentWidth number
--- @param contentHeight number
function LUIE_MiniMap_PinLayer:ApplyPinEntryPlacement(pinEntry, hidden, normalizedX, normalizedY, rotation, contentWidth, contentHeight)
    local pinControl = pinEntry.pinControl
    if hidden ~= pinEntry.lastHidden then
        pinEntry.lastHidden = hidden
        pinControl:SetHidden(hidden)
        if pinEntry.areaControl then
            pinEntry.areaControl:SetHidden(hidden)
        end
        if pinEntry.polygonControl then
            pinEntry.polygonControl:SetHidden(hidden)
        end
    end
    if hidden then
        return
    end

    if normalizedX ~= pinEntry.lastNormalizedX or normalizedY ~= pinEntry.lastNormalizedY then
        pinEntry.lastNormalizedX = normalizedX
        pinEntry.lastNormalizedY = normalizedY
        local offsetX = normalizedX * contentWidth
        local offsetY = normalizedY * contentHeight
        pinControl:ClearAnchors()
        pinControl:SetAnchor(CENTER, self.pinsContainer, TOPLEFT, offsetX, offsetY)
        if pinEntry.areaControl then
            pinEntry.areaControl:ClearAnchors()
            pinEntry.areaControl:SetAnchor(CENTER, self.polygonsContainer, TOPLEFT, offsetX, offsetY)
        end
        if pinEntry.polygonControl then
            pinEntry.polygonControl:ClearAnchors()
            pinEntry.polygonControl:SetAnchor(CENTER, self.polygonsContainer, TOPLEFT, offsetX, offsetY)
        end
    end

    if rotation ~= nil and rotation ~= pinEntry.lastRotation then
        pinEntry.lastRotation = rotation
        pinControl.background:SetTextureRotation(rotation)
    end
end

--- Full pass: texture, tint, highlight, draw level, size, area blob, polygon blob, then position.
--- @param pinEntry LUIE_MiniMap_PinEntry
--- @param contentWidth number
--- @param contentHeight number
--- @param playerPinHidden boolean
function LUIE_MiniMap_PinLayer:ApplyPinEntryAppearance(pinEntry, contentWidth, contentHeight, playerPinHidden)
    local worldMapPin = pinEntry.worldMapPin
    local pinControl = pinEntry.pinControl
    local pinType = worldMapPin:GetPinType()
    pinEntry.isPlayer = pinType == MAP_PIN_TYPE_PLAYER
    if pinEntry.isPlayer then
        self.playerPinEntry = pinEntry
    elseif self.playerPinEntry == pinEntry then
        self.playerPinEntry = nil
    end
    pinEntry.isMoving = worldMapPin:IsUnit() or worldMapPin:IsObjective()
    local singlePinData = ZO_MapPin.PIN_DATA[pinType]
    pinEntry.isAnimated = singlePinData ~= nil and singlePinData.isAnimated == true

    -- Background (ZO_MapPin:SetData writes texture, coords, color and draw level onto backgroundControl).
    local worldMapBackground = worldMapPin.backgroundControl
    local background = pinControl.background
    local textureName = worldMapBackground:GetTextureFileName()
    if textureName ~= pinEntry.lastTexture then
        pinEntry.lastTexture = textureName
        background:SetTexture(textureName)
    end
    background:SetTextureCoords(worldMapBackground:GetTextureCoords())
    if pinEntry.isPlayer then
        -- Camera-heading pip: camera pip colour while following, player pip colour when panned (old ApplyNativeWorldMapPlayerPinColors).
        if self.panAndZoom:GetFollowsPlayer() then
            background:SetColor(MiniMap.GetPlayerCameraPipColor())
        else
            background:SetColor(MiniMap.GetPlayerPipColor())
        end
    else
        background:SetColor(worldMapBackground:GetColor())
    end
    background:SetDrawLevel(worldMapBackground:GetDrawLevel())
    background:SetHidden(worldMapBackground:IsControlHidden())

    -- Highlight glow.
    local worldMapHighlight = worldMapPin.highlightControl
    local highlight = pinControl.highlight
    local highlightHidden = worldMapHighlight:IsControlHidden()
    highlight:SetHidden(highlightHidden)
    if not highlightHidden then
        local highlightTexture = worldMapHighlight:GetTextureFileName()
        if highlightTexture ~= pinEntry.lastHighlightTexture then
            pinEntry.lastHighlightTexture = highlightTexture
            highlight:SetTexture(highlightTexture)
        end
        highlight:SetColor(worldMapHighlight:GetColor())
        highlight:SetDrawLevel(worldMapHighlight:GetDrawLevel())
    end

    -- Size.
    local size = self:ComputePinSize(pinType)
    if size ~= pinEntry.lastSize then
        pinEntry.lastSize = size
        pinControl:SetDimensions(size, size)
    end

    -- Area blob (radius pins; ZO_MapPin:UpdateSize 2846-2860).
    local worldMapAreaBlob = worldMapPin.pinBlob
    if worldMapAreaBlob and not worldMapAreaBlob:IsControlHidden() and worldMapPin.radius and worldMapPin.radius > 0 then
        if not pinEntry.areaControl then
            pinEntry.areaControl, pinEntry.areaKey = self.areaBlobPool:AcquireObject()
        end
        local areaControl = pinEntry.areaControl
        local pinDiameter = worldMapPin.radius * 2 * contentHeight
        if singlePinData and singlePinData.minAreaSize and pinDiameter < singlePinData.minAreaSize then
            pinDiameter = singlePinData.minAreaSize
        end
        areaControl:SetTexture(worldMapAreaBlob:GetTextureFileName())
        areaControl:SetColor(worldMapAreaBlob:GetColor())
        areaControl:SetDimensions(pinDiameter, pinDiameter)
    elseif pinEntry.areaControl then
        self.areaBlobPool:ReleaseObject(pinEntry.areaKey)
        pinEntry.areaControl = nil
        pinEntry.areaKey = nil
    end

    -- Polygon blob (dig sites; ZO_MapPin:SetLocation 3138-3153 and UpdateSize 2863-2875).
    local borderInformation = worldMapPin.borderInformation
    if worldMapPin.polygonBlob and borderInformation and borderInformation.borderPoints then
        if not pinEntry.polygonControl then
            pinEntry.polygonControl, pinEntry.polygonKey = self.polygonPool:AcquireObject()
        end
        local polygonControl = pinEntry.polygonControl
        polygonControl:ClearPoints()
        for _, point in ipairs(borderInformation.borderPoints) do
            polygonControl:AddPoint(point.x, point.y)
        end
        polygonControl:SetDimensions(borderInformation.borderWidth * contentWidth, borderInformation.borderHeight * contentHeight)
        local centerRed, centerGreen, centerBlue = worldMapPin:GetCenterColor():UnpackRGB()
        polygonControl:SetCenterColor(centerRed, centerGreen, centerBlue, POLYGON_CENTER_ALPHA)
        polygonControl:SetBorderColor(worldMapPin:GetBorderColor():UnpackRGBA())
    elseif pinEntry.polygonControl then
        self.polygonPool:ReleaseObject(pinEntry.polygonKey)
        pinEntry.polygonControl = nil
        pinEntry.polygonKey = nil
    end

    -- Force a position/visibility rewrite after a full pass.
    pinEntry.lastNormalizedX = nil
    pinEntry.lastNormalizedY = nil
    pinEntry.lastHidden = nil
    pinEntry.lastRotation = nil
    self:ApplyPinEntryPosition(pinEntry, contentWidth, contentHeight, playerPinHidden)
end

-- Keep links -----------------------------------------------------------------

--- Mirrors ZO_KeepNetwork's link pool (WorldMap.lua:486-648). Each world map link control stores
--- startNX/startNY/endNX/endNY and is laid out with ZO_Anchor_LineInContainer (ZO_Anchor.lua:302).
function LUIE_MiniMap_PinLayer:RefreshLinks()
    self.linkPool:ReleaseAllObjects()
    local worldMapLinkContainer = ZO_WorldMapContainerKeepLinks
    if not worldMapLinkContainer or not self.panAndZoom:HasMap() then
        return
    end
    local contentWidth = self.panAndZoom:GetContentWidth()
    local contentHeight = self.panAndZoom:GetContentHeight()
    local thickness = zo_max(KEEP_LINK_MIN_THICKNESS, KEEP_LINK_BASE_THICKNESS * self.panAndZoom:GetCurvedPinScale())
    for childIndex = 1, worldMapLinkContainer:GetNumChildren() do
        local worldMapLink = worldMapLinkContainer:GetChild(childIndex)
        if worldMapLink and not worldMapLink:IsControlHidden() and worldMapLink.startNX then
            local linkControl = self.linkPool:AcquireObject()
            --- @cast linkControl LineControl
            linkControl:SetTexture(worldMapLink:GetTextureFileName())
            linkControl:SetColor(worldMapLink:GetColor())
            linkControl:SetThickness(thickness)
            ZO_Anchor_LineInContainer(linkControl, self.linksContainer,
                                      worldMapLink.startNX * contentWidth, worldMapLink.startNY * contentHeight,
                                      worldMapLink.endNX * contentWidth, worldMapLink.endNY * contentHeight)
        end
    end
end
