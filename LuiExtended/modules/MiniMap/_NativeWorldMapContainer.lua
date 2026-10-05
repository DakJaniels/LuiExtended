-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Reparents ZO_WorldMapContainer under the HUD minimap while the full world map is closed.
-- Uses ZO_WorldMap_GetPinManager() and WORLD_MAP_TILES_MANAGER on the real container (EsoUI/Ingame/Map/WorldMap.lua).

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local eventManager = GetEventManager()

local WORLD_MAP_CONTAINER_BACKGROUND_TEXTURE = "EsoUI/Art/WorldMap/worldmap_map_background_512tile.dds"
local HUD_MAP_EDGE_FLAT_TEXTURE = "EsoUI/Art/Miscellaneous/listItem_backdrop_white.dds"
local NATIVE_PLAYER_PIP_TEXTURE = "EsoUI/Art/MapPins/UI-WorldMapPlayerPip.dds"

local pinManager = ZO_WorldMap_GetPinManager()
local panAndZoom = ZO_WorldMap_GetPanAndZoom()

local nativeWorldMapContainerAttached = false
local nativeWorldMapContainerHiddenForReload = false
local nativeWorldMapContainerStagedForTileLoad = false
--- When a map is already showing, a subzone reload keeps those tiles instead of the loading plate.
MiniMap.keepPreviousHudMapTilesVisible = false

--- @class MiniMapNativeWorldMapContainerRestore
--- @field parent Control
--- @field mapConstantsWidth number
--- @field mapConstantsHeight number
--- @field containerMouseEnabled boolean
--- @field playerWorldPinControl Control|nil
--- @field playerWorldPinWasHidden boolean|nil

local nativeWorldMapContainerRestore --- @type MiniMapNativeWorldMapContainerRestore|nil
local nativeHudMapOverlayLayoutReapplyScheduled = false
local nativeHudMapOverlayLayoutReapplySecondFrameScheduled = false
local NATIVE_HUD_MAP_OVERLAY_LAYOUT_REAPPLY_UPDATE_NAME = nil

local function GetNativeHudMapOverlayLayoutReapplyUpdateName()
    if not NATIVE_HUD_MAP_OVERLAY_LAYOUT_REAPPLY_UPDATE_NAME then
        NATIVE_HUD_MAP_OVERLAY_LAYOUT_REAPPLY_UPDATE_NAME = MiniMap.moduleName .. "NativeHudMapOverlayLayoutReapply"
    end
    return NATIVE_HUD_MAP_OVERLAY_LAYOUT_REAPPLY_UPDATE_NAME
end

--- Hides reparented ZO_WorldMapContainer while ReloadWorldMap runs so ZO_WorldMap_UpdateMap cannot flash full-zone dimensions.
--- A staged tile load stays shown at alpha 0. ZO_MapPanAndZoom:CanInitializeMap releases the texture unit when ZO_WorldMapContainer1 is hidden.
--- @param hidden boolean
function MiniMap.SetAttachedNativeWorldMapContainerHiddenForReload(hidden)
    nativeWorldMapContainerHiddenForReload = hidden == true
    if not nativeWorldMapContainerAttached then
        return
    end
    if nativeWorldMapContainerHiddenForReload and nativeWorldMapContainerStagedForTileLoad then
        ZO_WorldMapContainer:SetHidden(false)
        ZO_WorldMapContainer:SetAlpha(0)
        return
    end
    ZO_WorldMapContainer:SetHidden(nativeWorldMapContainerHiddenForReload)
    if not nativeWorldMapContainerHiddenForReload then
        nativeWorldMapContainerStagedForTileLoad = false
        ZO_WorldMapContainer:SetAlpha(1)
    end
end

--- @return boolean
function MiniMap.IsNativeWorldMapContainerStagedForTileLoad()
    return nativeWorldMapContainerStagedForTileLoad
end

--- Parents ZO_WorldMapContainer under the visible minimap so GetMapTileTexture can finish loading.
--- ZO_WorldMapTiles_Manager:UpdateTextures calls SetTexture, and a hidden tile drops that texture (RELEASE_TEXTURE_AT_ZERO_REFERENCES on ZO_MapTile).
function MiniMap.ShowNativeWorldMapContainerForTileLoad()
    if ZO_WorldMap_IsWorldMapShowing() then
        return
    end
    local view = MiniMap.view
    if not view or not view.map then
        return
    end
    nativeWorldMapContainerStagedForTileLoad = true
    if not nativeWorldMapContainerAttached then
        ZO_WorldMapContainer:SetParent(view.map)
        ZO_WorldMapContainer:SetMouseEnabled(false)
    end
    if MiniMap.keepPreviousHudMapTilesVisible then
        ZO_WorldMapContainer:SetAlpha(1)
        ZO_WorldMapContainer:SetHidden(false)
        return
    end
    ZO_WorldMapContainer:SetAlpha(0)
    ZO_WorldMapContainer:SetHidden(false)
    MiniMap.ClampStagedWorldMapContainerToMiniMapScroll()
end

--- Fits a staged container to the minimap scroll without LayoutTiles. LayoutTiles hides tiles and releases the texture unit.
function MiniMap.ClampStagedWorldMapContainerToMiniMapScroll()
    if not nativeWorldMapContainerStagedForTileLoad then
        return
    end
    local view = MiniMap.view
    if not view or not view.map or not view.scroll then
        return
    end
    local scrollWidth = view.scroll:GetWidth()
    local scrollHeight = view.scroll:GetHeight()
    if scrollWidth <= 0 or scrollHeight <= 0 then
        return
    end
    ZO_WorldMapContainer:ClearAnchors()
    ZO_WorldMapContainer:SetAnchor(TOPLEFT, view.map, TOPLEFT, 0, 0)
    ZO_WorldMapContainer:SetDimensions(scrollWidth, scrollHeight)

    local horizontalTiles = WORLD_MAP_TILES_MANAGER.horizontalTiles
    local verticalTiles = WORLD_MAP_TILES_MANAGER.verticalTiles
    local totalTiles = WORLD_MAP_TILES_MANAGER.totalTiles
    if not horizontalTiles or horizontalTiles < 1 or not verticalTiles or verticalTiles < 1 or not totalTiles then
        return
    end
    local tileWidth = scrollWidth / horizontalTiles
    local tileHeight = scrollHeight / verticalTiles
    for tileIndex = 1, totalTiles do
        local tileControl = WORLD_MAP_TILES_MANAGER:GetActiveObject(tileIndex)
        if tileControl then
            tileControl:SetHidden(false)
            tileControl:ClearAnchors()
            tileControl:SetDimensions(tileWidth, tileHeight)
            local xOffset = zo_mod(tileIndex - 1, horizontalTiles) * tileWidth
            local yOffset = zo_floor((tileIndex - 1) / horizontalTiles) * tileHeight
            tileControl:SetAnchor(TOPLEFT, ZO_WorldMapContainer, TOPLEFT, xOffset, yOffset)
        end
    end
end

--- Puts a not-yet-attached container back on ZO_WorldMapScroll. Attached restores go through RestoreWorldMapContainerToWorldMap.
function MiniMap.ReturnStagedWorldMapContainerToWorldMap()
    if not nativeWorldMapContainerStagedForTileLoad then
        return
    end
    nativeWorldMapContainerStagedForTileLoad = false
    if nativeWorldMapContainerAttached then
        return
    end
    ZO_WorldMapContainer:SetAlpha(1)
    ZO_WorldMapContainer:SetParent(ZO_WorldMapScroll)
    ZO_WorldMapContainer:ClearAnchors()
    ZO_WorldMapContainer:SetAnchor(CENTER, ZO_WorldMapScroll, CENTER, 0, 0)
    ZO_WorldMapContainer:SetMouseEnabled(true)
end

--- ZO_MapPanAndZoom:InitializeMap sets normalized zoom 0 and offset 0 once ZO_WorldMapContainer1 is loaded and shown.
function MiniMap.InitializeNativeWorldMapZoomedOutWhenPending()
    if not panAndZoom.pendingInitializeMap then
        return
    end
    local firstTile = WORLD_MAP_TILES_MANAGER:GetActiveObject(1)
    if firstTile and firstTile:IsHidden() then
        firstTile:SetHidden(false)
    end
    if panAndZoom:CanInitializeMap() then
        panAndZoom:InitializeMap()
        MiniMap.ReapplyNativeWorldMapTileTexturesAfterLayout()
    end
end

--- @return boolean
function MiniMap.IsAttachedNativeWorldMapContainerHiddenForReload()
    return nativeWorldMapContainerHiddenForReload
end

--- After ZO_WorldMap_UpdateMap while the container is under the HUD minimap, re-apply minimap MAP_WIDTH/HEIGHT or stay hidden during reload.
function MiniMap.ApplyNativeHudLayoutAfterWorldMapUpdateMap()
    if not nativeWorldMapContainerAttached then
        return
    end
    if MiniMap.keepPreviousHudMapTilesVisible then
        ZO_WorldMapContainer:SetHidden(false)
        ZO_WorldMapContainer:SetAlpha(1)
        local mapController = MiniMap.mapController
        if mapController then
            local mapContentWidth = mapController:GetMapContentWidth()
            local mapContentHeight = mapController:GetMapContentHeight()
            if mapContentWidth > 0 and mapContentHeight > 0 then
                MiniMap.ApplyNativeWorldMapContainerLayout(mapContentWidth, mapContentHeight)
            end
        end
        return
    end
    if nativeWorldMapContainerHiddenForReload then
        if nativeWorldMapContainerStagedForTileLoad then
            ZO_WorldMapContainer:SetHidden(false)
            ZO_WorldMapContainer:SetAlpha(0)
            return
        end
        ZO_WorldMapContainer:SetHidden(true)
        return
    end
    local mapController = MiniMap.mapController
    if mapController and mapController:IsReady() then
        ZO_WorldMapContainer:SetHidden(false)
        MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    else
        ZO_WorldMapContainer:SetHidden(true)
    end
end

function MiniMap.CancelNativeHudMapOverlayLayoutReapply()
    nativeHudMapOverlayLayoutReapplyScheduled = false
    nativeHudMapOverlayLayoutReapplySecondFrameScheduled = false
    eventManager:UnregisterForUpdate(GetNativeHudMapOverlayLayoutReapplyUpdateName())
    eventManager:UnregisterForUpdate(MiniMap.moduleName .. "NativeHudMapOverlayLayoutReapply2")
end

--- Runs ZOS g_mapRefresh:UpdateRefreshGroups via the world map OnUpdate handler (keep / link / location dirty groups).
function MiniMap.FlushWorldMapPinRefreshGroups()
    local worldMapControl = WORLD_MAP_MANAGER.control
    local onUpdate = worldMapControl:GetHandler("OnUpdate")
    if onUpdate then
        onUpdate(worldMapControl, GetFrameTimeSeconds())
    end
end

--- Stops ZO_MapPanAndZoom from re-anchoring ZO_WorldMapContainer to CENTER while it is parented under the HUD minimap.
function MiniMap.ResetNativeHudWorldMapPanState()
    panAndZoom:ClearLockPoint()
    panAndZoom:ClearTargetOffset()
    panAndZoom:ClearTargetNormalizedZoom()
    panAndZoom:SetCurrentOffset(0, 0)
end

--- Restores HUD minimap MAP constants and ZOS pins/links after ZO_WorldMap_UpdateMap / SetMapWindowSize.
function MiniMap.ReapplyNativeHudMapOverlayLayout()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    local mapController = MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    MiniMap.ResetNativeHudWorldMapPanState()
    MiniMap.FlushWorldMapPinRefreshGroups()
    MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    MiniMap.ResetNativeHudWorldMapPanState()
    MiniMap.RefreshWorldMapSuggestionPinsForMirror()
    MiniMap.RefreshWorldMapPingsForMirror()
end

function MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if nativeHudMapOverlayLayoutReapplyScheduled then
        return
    end
    nativeHudMapOverlayLayoutReapplyScheduled = true
    local updateName = GetNativeHudMapOverlayLayoutReapplyUpdateName()
    eventManager:RegisterForUpdate(updateName, 0, function ()
                                       nativeHudMapOverlayLayoutReapplyScheduled = false
                                       MiniMap.ReapplyNativeHudMapOverlayLayout()
                                       MiniMap.ScheduleNativeHudMapOverlayLayoutReapplySecondFrame()
                                   end, true)
end

--- Second frame after ZOS g_mapRefresh:UpdateRefreshGroups (world map OnUpdate).
function MiniMap.ScheduleNativeHudMapOverlayLayoutReapplySecondFrame()
    if not MiniMap.Enabled or not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if nativeHudMapOverlayLayoutReapplySecondFrameScheduled then
        return
    end
    nativeHudMapOverlayLayoutReapplySecondFrameScheduled = true
    local secondFrameUpdateName = MiniMap.moduleName .. "NativeHudMapOverlayLayoutReapply2"
    eventManager:RegisterForUpdate(secondFrameUpdateName, 0, function ()
                                       nativeHudMapOverlayLayoutReapplySecondFrameScheduled = false
                                       MiniMap.ReapplyNativeHudMapOverlayLayout()
                                   end, true)
end

--- @return boolean
function MiniMap.IsNativeWorldMapContainerAttached()
    return nativeWorldMapContainerAttached == true
end

--- @return boolean
function MiniMap.HasNativeMovingPinTargets()
    if GetGroupSize() > 1 then
        return true
    end
    return DoesUnitExist("companion")
end

--- Native HUD player pin + group/companion moving pins. Called from OnFollowTick after its guards.
--- Player normalized position is the sample from GetMapPlayerPositionForMirror so a parent-zone map index cannot place the pip.
--- @param followPlayer boolean|nil
--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param isShownInCurrentMap boolean|nil
--- @param isSymbolicLocation boolean|nil
function MiniMap.TickHudMovingAndPlayerPins(followPlayer, normalizedX, normalizedY, isShownInCurrentMap, isSymbolicLocation)
    if followPlayer == nil then
        followPlayer = MiniMap.GetMapFollowsPlayer()
    end
    if not nativeWorldMapContainerAttached then
        return
    end
    local hasGroupOrCompanionPins = MiniMap.HasNativeMovingPinTargets()
    if followPlayer then
        if hasGroupOrCompanionPins then
            pinManager:UpdateMovingPins()
        end
    else
        pinManager:UpdateMovingPins()
    end
    MiniMap.UpdateNativeHudPlayerMapPin(normalizedX, normalizedY, isShownInCurrentMap, isSymbolicLocation)
    MiniMap.ApplyNativeWorldMapPlayerPinColors()
    MiniMap.ApplyNativeHudPlayerHeadingAppearance()
end

--- ZOS UpdateMovingPins player block only (MapPin_Manager.lua) for solo follow pip sync.
--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param isShownInCurrentMap boolean|nil
--- @param isSymbolicLocation boolean|nil
function MiniMap.UpdateNativeHudPlayerMapPin(normalizedX, normalizedY, isShownInCurrentMap, isSymbolicLocation)
    local playerMapPin = pinManager:GetPlayerPin()
    if not playerMapPin then
        return
    end
    local xLoc, yLoc = normalizedX, normalizedY
    if xLoc == nil or yLoc == nil then
        xLoc, yLoc, _, isShownInCurrentMap, isSymbolicLocation = MiniMap.GetMapPlayerPositionForMirror("player")
    end
    playerMapPin:SetOriginalPosition(xLoc, yLoc)
    playerMapPin:SetIsSymbolicPosition(isSymbolicLocation)
    playerMapPin:SetLocation(xLoc, yLoc)
    -- SetLocation anchors with ZO_MAP_CONSTANTS (WorldMap.lua ZO_MapPin:UpdateLocation).
    -- Those constants are the world-map window after SetMapWindowSize, while the city tiles stay on the minimap content size.
    -- Wayshrines keep the layout anchors; only this moving pin was rewritten every tick, so it sat in the lower part of the city.
    local containerWidth, containerHeight = ZO_WorldMapContainer:GetDimensions()
    local constantWidth, constantHeight = ZO_WorldMap_GetMapDimensions()
    if containerWidth > 0 and containerHeight > 0
    and (zo_abs(containerWidth - constantWidth) > 1 or zo_abs(containerHeight - constantHeight) > 1) then
        local playerPinControl = playerMapPin:GetControl()
        playerPinControl:ClearAnchors()
        playerPinControl:SetAnchor(CENTER, playerPinControl:GetParent(), TOPLEFT, xLoc * containerWidth, yLoc * containerHeight)
    end
    if isShownInCurrentMap then
        playerMapPin:SetHidden(false)
        local rotation = isSymbolicLocation and 0 or GetPlayerCameraHeading()
        playerMapPin:SetRotation(rotation)
    else
        playerMapPin:SetHidden(true)
    end
end

--- MapPin_Manager.lua UpdateMovingPins and UpdateNativeHudPlayerMapPin rotate this pin with GetPlayerCameraHeading.
--- That rotation is the heading while the HUD map is attached. Show Player Pip only hides it when the map is not following.
function MiniMap.ApplyNativeHudPlayerHeadingAppearance()
    if not nativeWorldMapContainerAttached then
        return
    end
    local playerMapPin = pinManager:GetPlayerPin()
    if not playerMapPin then
        return
    end
    local playerPipTexture = ZO_MapPin.GetStaticPinTexture(MAP_PIN_TYPE_PLAYER)
    if not playerPipTexture or playerPipTexture == "" then
        playerPipTexture = NATIVE_PLAYER_PIP_TEXTURE
    end
    playerMapPin.backgroundControl:SetTexture(playerPipTexture)
    MiniMap.ApplyNativeHudPlayerPinScale()
    if MiniMap.SV.showPlayerPip == false and not MiniMap.GetMapFollowsPlayer() then
        playerMapPin:SetHidden(true)
    end
end

--- Native HUD player pin uses the same pip art as the overlay; size comes from Player Pip scale only.
function MiniMap.ApplyNativeHudPlayerPinScale()
    local playerMapPin = pinManager:GetPlayerPin()
    local drawSize = MiniMap.GetPlayerPinDrawSize()
    playerMapPin:SetScaleModifier(drawSize / MiniMap.PLAYER_PIN_BASE_SIZE)
end

--- Tints the ZOS HUD player map pin (ZO_WorldMapPins_Manager:GetPlayerPin), not a fixed pool index.
function MiniMap.ApplyNativeWorldMapPlayerPinColors()
    local playerMapPin = pinManager:GetPlayerPin()
    local backgroundControl = playerMapPin.backgroundControl
    local red, green, blue, alpha
    if MiniMap.GetMapFollowsPlayer() then
        red, green, blue, alpha = MiniMap.GetCameraWedgeColor()
    else
        red, green, blue, alpha = MiniMap.GetPlayerPipColor()
    end
    backgroundControl:SetColor(red, green, blue, alpha)
end

local function ApplyNativeWorldMapHudDrawOrder(view)
    view.pins:SetDrawLayer(DL_OVERLAY)
    view.pins:SetDrawTier(DT_HIGH)
    view.player:SetDrawLayer(DL_OVERLAY)
    view.player:SetDrawTier(DT_HIGH)
    view.playerCam:SetDrawLayer(DL_OVERLAY)
    view.playerCam:SetDrawTier(DT_HIGH)
end

function MiniMap.ApplyNativeWorldMapPlayerPinVisibility()
    if not nativeWorldMapContainerAttached or not nativeWorldMapContainerRestore then
        return
    end
    local playerMapPin = pinManager:GetPlayerPin()
    local playerWorldPinControl = playerMapPin:GetControl()
    nativeWorldMapContainerRestore.playerWorldPinControl = playerWorldPinControl
    if nativeWorldMapContainerRestore.playerWorldPinWasHidden == nil then
        nativeWorldMapContainerRestore.playerWorldPinWasHidden = playerWorldPinControl:IsHidden()
    end
    MiniMap.ApplyNativeWorldMapPlayerPinColors()
    MiniMap.ApplyNativeHudPlayerHeadingAppearance()
end

local function RestoreWorldMapPlayerPinVisibility()
    if not nativeWorldMapContainerRestore then
        return
    end
    local playerMapPin = pinManager:GetPlayerPin()
    if playerMapPin and playerMapPin.backgroundControl then
        local playerPipTexture = ZO_MapPin.GetStaticPinTexture(MAP_PIN_TYPE_PLAYER)
        if not playerPipTexture or playerPipTexture == "" then
            playerPipTexture = NATIVE_PLAYER_PIP_TEXTURE
        end
        playerMapPin.backgroundControl:SetTexture(playerPipTexture)
    end
    local playerWorldPinControl = nativeWorldMapContainerRestore.playerWorldPinControl
    if playerWorldPinControl and nativeWorldMapContainerRestore.playerWorldPinWasHidden ~= nil then
        playerWorldPinControl:SetHidden(nativeWorldMapContainerRestore.playerWorldPinWasHidden)
    end
    nativeWorldMapContainerRestore.playerWorldPinControl = nil
    nativeWorldMapContainerRestore.playerWorldPinWasHidden = nil
end

--- SetMapWindowSize (WorldMap.lua) writes ZO_MAP_CONSTANTS and the container to the world-map window.
--- The follow scroll still uses minimap content size, so the player pin (updated every tick) lands in the wrong part of a submap.
--- Opening and closing the world map runs this layout last, which is why the pip then stays correct.
function MiniMap.SyncNativeHudMapGeometryToContent()
    if not nativeWorldMapContainerAttached then
        return
    end
    if MiniMap.playerMapMirrorDepth > 0 or MiniMap.IsPinMirrorMachineBusy() then
        return
    end
    local mapController = MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    local mapContentWidth = mapController:GetMapContentWidth()
    local mapContentHeight = mapController:GetMapContentHeight()
    if mapContentWidth <= 0 or mapContentHeight <= 0 then
        return
    end
    local containerWidth, containerHeight = ZO_WorldMapContainer:GetDimensions()
    if zo_abs(containerWidth - mapContentWidth) <= 1
    and zo_abs(containerHeight - mapContentHeight) <= 1
    and zo_abs(ZO_MAP_CONSTANTS.MAP_WIDTH - mapContentWidth) <= 1
    and zo_abs(ZO_MAP_CONSTANTS.MAP_HEIGHT - mapContentHeight) <= 1 then
        return
    end
    MiniMap.ApplyNativeWorldMapContainerLayout(mapContentWidth, mapContentHeight)
end

--- @param mapContentWidth number
--- @param mapContentHeight number
function MiniMap.ApplyNativeWorldMapContainerLayout(mapContentWidth, mapContentHeight)
    if mapContentWidth <= 0 or mapContentHeight <= 0 then
        return
    end

    ZO_MAP_CONSTANTS.MAP_WIDTH = mapContentWidth
    ZO_MAP_CONSTANTS.MAP_HEIGHT = mapContentHeight

    ZO_WorldMapContainer:SetDimensions(mapContentWidth, mapContentHeight)
    ZO_WorldMapContainer:ClearAnchors()
    ZO_WorldMapContainer:SetAnchor(TOPLEFT, ZO_WorldMapContainer:GetParent(), TOPLEFT, 0, 0)
    ZO_WorldMapContainer:SetAlpha(1)
    ZO_WorldMapContainer:SetHidden(false)
    nativeWorldMapContainerStagedForTileLoad = false

    WORLD_MAP_TILES_MANAGER:LayoutTiles()
    MiniMap.ReapplyNativeWorldMapTileTexturesAfterLayout()

    pinManager:UpdateMovingPins()
    pinManager:UpdatePinsForMapSizeChange()
    WORLD_MAP_MANAGER:UpdateBlobs()

    MiniMap.ApplyNativeWorldMapPlayerPinVisibility()
    MiniMap.ApplyNativeWorldMapPlayerPinColors()
    MiniMap.ApplyNativeHudPlayerPinScale()
    if MiniMap.pinController then
        MiniMap.pinController:ApplyUserScaleToNativeWorldMapPins()
    end

    MiniMap.ResetNativeHudWorldMapPanState()

    if GetMapFilterType() == MAP_FILTER_TYPE_AVA_CYRODIIL then
        ZO_WorldMap_RefreshKeepNetwork()
    end

    if MiniMap.pinController then
        MiniMap.pinController:RefreshHarvestMapPinsForHud()
    end
    MiniMap.RefreshCustomPinsForHud()
    MiniMap.ApplyHudMapEdgeBackground()
end

--- Flat color for the area outside the map tiles. Stock swirl stays on the world map.
function MiniMap.RestoreWorldMapContainerBackground()
    local background = ZO_WorldMapContainerBackground
    background:SetParent(ZO_WorldMapScroll)
    background:ClearAnchors()
    background:SetAnchor(CENTER, ZO_WorldMapContainer, CENTER, 0, 0)
    background:SetDrawLayer(DL_BACKGROUND)
    background:SetTexture(WORLD_MAP_CONTAINER_BACKGROUND_TEXTURE)
    background:SetTextureCoords(0, 4, 0, 4)
    background:SetAddressMode(TEX_MODE_WRAP)
    background:SetColor(1, 1, 1, 1)
    background:SetDimensions(ZO_MAP_CONSTANTS.MAP_WIDTH * 2, ZO_MAP_CONSTANTS.MAP_HEIGHT * 2)
    background:SetHidden(false)
end

function MiniMap.ApplyHudMapEdgeBackground()
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    if not MiniMap.SV or MiniMap.SV.mapEdgeColorEnabled ~= true then
        MiniMap.RestoreWorldMapContainerBackground()
        return
    end
    local view = MiniMap.view
    if not view or not view.map then
        return
    end
    local background = ZO_WorldMapContainerBackground
    background:SetParent(view.map)
    background:SetDrawLayer(DL_BACKGROUND)
    background:SetDrawTier(DT_LOW)
    background:ClearAnchors()
    background:SetAnchor(CENTER, ZO_WorldMapContainer, CENTER, 0, 0)
    background:SetDimensions(ZO_MAP_CONSTANTS.MAP_WIDTH * 2, ZO_MAP_CONSTANTS.MAP_HEIGHT * 2)
    background:SetTexture(HUD_MAP_EDGE_FLAT_TEXTURE)
    background:SetTextureCoords(0, 1, 0, 1)
    background:SetAddressMode(TEX_MODE_CLAMP)
    local savedColor = MiniMap.SV.mapEdgeColor or MiniMap.Defaults.mapEdgeColor
    local alpha = savedColor.a
    if alpha == nil then
        alpha = 1
    end
    background:SetColor(savedColor.r, savedColor.g, savedColor.b, alpha)
    background:SetHidden(false)
    background:SetMouseEnabled(false)
end

--- @param mapController MiniMapMapController|nil
function MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
    mapController = mapController or MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    local mapContentWidth = mapController:GetMapContentWidth()
    local mapContentHeight = mapController:GetMapContentHeight()
    MiniMap.ApplyNativeWorldMapContainerLayout(mapContentWidth, mapContentHeight)
end

function MiniMap.RefreshNativeWorldMapContainer(refreshOptions)
    if not MiniMap.Enabled then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    local mapController = MiniMap.mapController
    if not mapController or not mapController:IsReady() then
        return
    end
    local syncSubzoneMapGeometry = refreshOptions and refreshOptions.syncSubzoneMapGeometry == true
    local applyContextZoomIfChanged = refreshOptions and refreshOptions.applyContextZoomIfChanged == true
    MiniMap.RunWithPlayerMapForMirror(function ()
        local geometryChanged = false
        if syncSubzoneMapGeometry then
            geometryChanged = MiniMap.SyncHudMapDataDimensionsFromPlayerMap(mapController)
        end
        if applyContextZoomIfChanged then
            MiniMap.ApplyHudContextZoomWhenMapContextChanged()
        end
        local mapData = mapController.map
        if mapData and mapData.numTiles > 0 then
            local invokeUpdateTextures = geometryChanged
                or MiniMap.ShouldInvokeNativeWorldMapUpdateTexturesForMapData(mapData)
            MiniMap.BindNativeWorldMapTilesForHud(mapData, invokeUpdateTextures)
        end
        MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
        MiniMap.RefreshWorldMapPinsForMirror()
        if MiniMap.IsNativeWorldMapContainerAttached() then
            MiniMap.FlushWorldMapPinRefreshGroups()
            MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController(mapController)
            MiniMap.ResetNativeHudWorldMapPanState()
        end
    end)
end

function MiniMap.TryAttachNativeWorldMapContainer()
    if not MiniMap.Enabled then
        return
    end
    if nativeWorldMapContainerAttached then
        MiniMap.ReapplyNativeHudMapOverlayLayout()
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    local view = MiniMap.view
    local mapController = MiniMap.mapController
    if not view or not mapController or not mapController:IsReady() then
        return
    end

    local restoreParent = ZO_WorldMapContainer:GetParent()
    local containerMouseEnabled = ZO_WorldMapContainer:IsMouseEnabled()
    if nativeWorldMapContainerStagedForTileLoad or restoreParent == view.map then
        restoreParent = ZO_WorldMapScroll
        containerMouseEnabled = true
    end

    nativeWorldMapContainerRestore =
    {
        parent = restoreParent,
        mapConstantsWidth = ZO_MAP_CONSTANTS.MAP_WIDTH,
        mapConstantsHeight = ZO_MAP_CONSTANTS.MAP_HEIGHT,
        containerMouseEnabled = containerMouseEnabled,
    }

    ZO_WorldMapContainer:SetParent(view.map)
    ZO_WorldMapContainer:SetDrawTier(DT_MEDIUM)
    ZO_WorldMapContainer:SetHidden(false)
    -- Keep ZOS WorldMap.xml mouse handlers off the HUD minimap (right-click would MapZoomOut / change map).
    ZO_WorldMapContainer:SetMouseEnabled(false)

    nativeWorldMapContainerAttached = true
    ApplyNativeWorldMapHudDrawOrder(view)
    MiniMap.RefreshNativeWorldMapContainer()
    MiniMap.ScheduleNativeHudMapOverlayLayoutReapply()
end

function MiniMap.RestoreWorldMapContainerToWorldMap()
    if not nativeWorldMapContainerAttached then
        MiniMap.ReturnStagedWorldMapContainerToWorldMap()
        return
    end
    nativeWorldMapContainerStagedForTileLoad = false

    MiniMap.CancelNativeHudMapOverlayLayoutReapply()
    RestoreWorldMapPlayerPinVisibility()
    if MiniMap.pinController then
        MiniMap.pinController:ResetNativeWorldMapPinUserScale()
    end

    local restore = nativeWorldMapContainerRestore
    local restoreParent = restore and restore.parent or ZO_WorldMapScroll
    ZO_WorldMapContainer:SetAlpha(1)
    ZO_WorldMapContainer:SetParent(restoreParent)
    ZO_WorldMapContainer:ClearAnchors()
    ZO_WorldMapContainer:SetAnchor(CENTER, restoreParent, CENTER, 0, 0)

    if restore then
        ZO_MAP_CONSTANTS.MAP_WIDTH = restore.mapConstantsWidth
        ZO_MAP_CONSTANTS.MAP_HEIGHT = restore.mapConstantsHeight
        ZO_WorldMapContainer:SetDimensions(restore.mapConstantsWidth, restore.mapConstantsHeight)
        ZO_WorldMapContainer:SetMouseEnabled(restore.containerMouseEnabled)
    else
        ZO_WorldMapContainer:SetMouseEnabled(true)
    end

    WORLD_MAP_TILES_MANAGER:LayoutTiles()
    pinManager:UpdatePinsForMapSizeChange()
    MiniMap.RestoreWorldMapContainerBackground()

    nativeWorldMapContainerAttached = false
    nativeWorldMapContainerRestore = nil

    if MiniMap.pinController then
        MiniMap.pinController:ApplyHarvestMapCompositeScale()
        MiniMap.pinController:RestoreAllDigSitePolygonsToWorldMap()
    end
end

function MiniMap.OnNativeWorldMapContainerZoomChanged()
    if not MiniMap.IsNativeWorldMapContainerAttached() then
        return
    end
    MiniMap.ApplyNativeWorldMapContainerLayoutFromMapController()
end

function MiniMap.ShutdownNativeWorldMapContainer()
    nativeWorldMapContainerHiddenForReload = false
    MiniMap.ReturnStagedWorldMapContainerToWorldMap()
    MiniMap.RestoreWorldMapContainerToWorldMap()
end
