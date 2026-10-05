-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

--- @class MiniMapRuntime : ZO_InitializingObject
--- @field view MiniMapView
--- @field mapController MiniMapMapController
--- @field pinController MiniMapPinController
--- @field lastPlayerNormX number|nil
--- @field lastPlayerNormY number|nil
--- @field lastPlayerHeading number|nil
--- @field lastCameraHeading number|nil
--- @field mapFollowsPlayer boolean
--- @field lastFollowUpdateMs number|nil
local MiniMapRuntime = ZO_InitializingObject:Subclass()
MiniMap.MiniMapRuntime = MiniMapRuntime

--- @param view MiniMapView
--- @param mapController MiniMapMapController
--- @param pinController MiniMapPinController
function MiniMapRuntime:Initialize(view, mapController, pinController)
    self.view = view
    self.mapController = mapController
    self.pinController = pinController
end

function MiniMapRuntime:Start()
end

function MiniMapRuntime:Stop()
end

function MiniMapRuntime:UpdateCenterPlayerPipVisibility()
    local followPlayer = MiniMap.GetMapFollowsPlayer()
    local showPlayerPip = MiniMap.SV.showPlayerPip ~= false
    -- LUIE_MiniMap_Player is the character arrow (GetMapPlayerPosition heading).
    -- LUIE_MiniMap_PlayerCam is the cone. Same parent and draw tier as the arrow, which already paints above the scroll.
    self.view.player:SetHidden((not followPlayer) or (not showPlayerPip))
    self.view.playerCam:SetHidden(not followPlayer)
    if followPlayer then
        self.view.player:SetDrawLayer(DL_OVERLAY)
        self.view.player:SetDrawTier(DT_HIGH)
        self.view.player:SetDrawLevel(2)
        self.view.playerCam:SetDrawLayer(DL_OVERLAY)
        self.view.playerCam:SetDrawTier(DT_HIGH)
        self.view.playerCam:SetDrawLevel(1)
    end
end

--- @param followsPlayer boolean
function MiniMapRuntime:SetMapFollowsPlayer(followsPlayer)
    self.mapFollowsPlayer = followsPlayer
    self:UpdateCenterPlayerPipVisibility()
    if MiniMap.IsNativeWorldMapContainerAttached() then
        MiniMap.ApplyNativeWorldMapPlayerPinVisibility()
        MiniMap.ApplyNativeHudPlayerPinScale()
        MiniMap.ApplyNativeWorldMapPlayerPinColors()
    end
end

function MiniMapRuntime:ClearFollowScrollCache()
    self.lastPlayerNormX = nil
    self.lastPlayerNormY = nil
    self.lastPlayerHeading = nil
    self.lastCameraHeading = nil
end

--- @param mapContentWidth number
--- @param mapContentHeight number
function MiniMapRuntime:ApplyScrollCenterOnPlayer(mapContentWidth, mapContentHeight)
    local scroll = self.view.scroll
    local playerNormalizedX, playerNormalizedY, _, isShownInCurrentMap = MiniMap.GetMapPlayerPositionForMirror("player")
    if not MiniMap.IsMapPlayerPositionShownOnHudMap(playerNormalizedX, playerNormalizedY, isShownInCurrentMap) then
        return
    end
    local horizontalScroll = (playerNormalizedX * mapContentWidth) - (scroll:GetWidth() / 2)
    local verticalScroll = (playerNormalizedY * mapContentHeight) - (scroll:GetHeight() / 2)
    scroll:SetHorizontalScroll(horizontalScroll)
    scroll:SetVerticalScroll(verticalScroll)
    MiniMap.SV.panOffsetX = horizontalScroll
    MiniMap.SV.panOffsetY = verticalScroll
end

--- @param previousContentWidth number
--- @param previousContentHeight number
function MiniMapRuntime:ApplyScrollAfterZoom(previousContentWidth, previousContentHeight)
    if previousContentWidth <= 0 or previousContentHeight <= 0 then
        return
    end

    local mapContentWidth = self.mapController:GetMapContentWidth()
    local mapContentHeight = self.mapController:GetMapContentHeight()
    local scroll = self.view.scroll

    if MiniMap.GetMapFollowsPlayer() then
        self:ApplyScrollCenterOnPlayer(mapContentWidth, mapContentHeight)
        return
    end

    local scrollX = scroll:GetHorizontalScroll()
    local scrollY = scroll:GetVerticalScroll()
    local viewportWidth = scroll:GetWidth()
    local viewportHeight = scroll:GetHeight()
    local normalizedFocusX = (scrollX + viewportWidth / 2) / previousContentWidth
    local normalizedFocusY = (scrollY + viewportHeight / 2) / previousContentHeight
    local newScrollX = normalizedFocusX * mapContentWidth - viewportWidth / 2
    local newScrollY = normalizedFocusY * mapContentHeight - viewportHeight / 2

    scroll:SetHorizontalScroll(newScrollX)
    scroll:SetVerticalScroll(newScrollY)
    MiniMap.SV.panOffsetX = newScrollX
    MiniMap.SV.panOffsetY = newScrollY
end

function MiniMapRuntime:OnFollowTick()
    if not MiniMap.Enabled then
        return
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return
    end
    if MiniMap.playerMapMirrorDepth > 0 then
        return
    end
    if MiniMap.IsPinMirrorMachineBusy() then
        return
    end

    local mapData = self.mapController:GetMapData()
    if not mapData or not self.mapController:IsReady() then
        return
    end

    MiniMap.SyncHudMapSheetToPlayerLocation()
    MiniMap.SyncNativeHudMapGeometryToContent()

    self:UpdateCenterPlayerPipVisibility()

    local playerNormalizedX, playerNormalizedY, playerHeading, isShownInCurrentMap, isSymbolicLocation = MiniMap.GetMapPlayerPositionForMirror("player")
    local playerCameraHeading = GetPlayerCameraHeading()
    local scroll = self.view.scroll
    local mapContentWidth = self.mapController:GetMapContentWidth()
    local mapContentHeight = self.mapController:GetMapContentHeight()
    local followPlayer = MiniMap.GetMapFollowsPlayer()

    if followPlayer then
        local horizontalScroll = (playerNormalizedX * mapContentWidth) - (scroll:GetWidth() / 2)
        local verticalScroll = (playerNormalizedY * mapContentHeight) - (scroll:GetHeight() / 2)
        if playerNormalizedX ~= self.lastPlayerNormX
        or playerNormalizedY ~= self.lastPlayerNormY
        or horizontalScroll ~= scroll:GetHorizontalScroll()
        or verticalScroll ~= scroll:GetVerticalScroll() then
            self:ApplyScrollCenterOnPlayer(mapContentWidth, mapContentHeight)
        end
        if playerHeading ~= self.lastPlayerHeading then
            self.view.player:SetTextureRotation(playerHeading)
            self.lastPlayerHeading = playerHeading
        end
        if playerCameraHeading ~= self.lastCameraHeading then
            self.view.playerCam:SetTextureRotation(playerCameraHeading)
            self.lastCameraHeading = playerCameraHeading
        end
        if MiniMap.ShouldRunThrottled("AutoZoomEdge", 600) then
            MiniMap.TryAutoZoomOutAtMapEdge(mapData)
        end
    else
        local panDragActive = MiniMap.inputController.panDragActive
        if not panDragActive then
            scroll:SetHorizontalScroll(MiniMap.SV.panOffsetX or 0)
            scroll:SetVerticalScroll(MiniMap.SV.panOffsetY or 0)
        end
        self.pinController:SyncPlayerMapPin(mapData)
    end

    self.lastPlayerNormX = playerNormalizedX
    self.lastPlayerNormY = playerNormalizedY

    MiniMap.TickHudMovingAndPlayerPins(followPlayer, playerNormalizedX, playerNormalizedY, isShownInCurrentMap, isSymbolicLocation)
end

function MiniMapRuntime:ApplyScrollFromPanOffsets()
    local scroll = self.view.scroll
    scroll:SetHorizontalScroll(MiniMap.SV.panOffsetX or 0)
    scroll:SetVerticalScroll(MiniMap.SV.panOffsetY or 0)
    self:UpdateCenterPlayerPipVisibility()
end

--- @return boolean
function MiniMap.ShouldRunFollowUpdate()
    if not MiniMap.Enabled or not MiniMap.runtime then
        return false
    end
    local hudSceneFragment = MiniMap.hudSceneFragment
    if not hudSceneFragment or not hudSceneFragment:IsShowing() then
        return false
    end
    if MiniMap.IsWorldMapBlockingMiniMapWork() then
        return false
    end
    return true
end

function MiniMap.OnRootUpdate(control, time)
    if not MiniMap.ShouldRunFollowUpdate() then
        return
    end
    -- MiniMap.UpdateHudMinimapPinMouseOverFromPointer()
    local runtime = MiniMap.runtime
    local now = GetFrameTimeMilliseconds()
    local followRefreshMs = MiniMap.GetMovingPinRefreshMs()
    if runtime.lastFollowUpdateMs and (now - runtime.lastFollowUpdateMs) < followRefreshMs then
        return
    end
    runtime.lastFollowUpdateMs = now
    runtime:OnFollowTick()
end
