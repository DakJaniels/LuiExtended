-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local MINIMAP_WAYPOINT_DRAG_THRESHOLD = 8
local MINIMAP_FRAME_CHROME_HIDE_DELAY_MS = 200

--- @class MiniMapInputController : ZO_InitializingObject
--- @field view MiniMapView
--- @field mapController MiniMapMapController
--- @field runtime MiniMapRuntime
--- @field panDragActive boolean
--- @field panDragStartX number
--- @field panDragStartY number
--- @field panDragMoved boolean
--- @field panScrollStartX number
--- @field panScrollStartY number
--- @field pendingWaypointClick boolean
--- @field frameChromeHideCallId integer|nil
--- @field zoomChromeExitCallId integer|nil
local MiniMapInputController = ZO_InitializingObject:Subclass()
MiniMap.MiniMapInputController = MiniMapInputController

--- @param view MiniMapView
--- @param mapController MiniMapMapController
--- @param runtime MiniMapRuntime
function MiniMapInputController:Initialize(view, mapController, runtime)
    self.view = view
    self.mapController = mapController
    self.runtime = runtime
    self.panDragActive = false
    self.panDragMoved = false
    self.pendingWaypointClick = false
    self.frameChromeHideCallId = nil
    self.zoomChromeExitCallId = nil
end

--- @param shift boolean
--- @return boolean
function MiniMapInputController:WaypointModifierActive(shift)
    if MiniMap.SV.waypointClickRequiresShift then
        return shift == true
    end
    return true
end

--- @param mouseX number
--- @param mouseY number
--- @param shift boolean
function MiniMapInputController:TrySetWaypointFromClick(mouseX, mouseY, shift)
    if MiniMap.fastTravel then
        return
    end
    if not self:WaypointModifierActive(shift) then
        return
    end
    if not self.mapController:IsReady() then
        return
    end
    local mapData = self.mapController:GetMapData()
    if not mapData then
        return
    end

    MiniMap.RunWithPlayerMapForMirror(function ()
        local scroll = self.view.scroll
        local scrollLeft = scroll:GetLeft()
        local scrollTop = scroll:GetTop()
        local localX = mouseX - scrollLeft + scroll:GetHorizontalScroll()
        local localY = mouseY - scrollTop + scroll:GetVerticalScroll()
        local mapWidth = self.mapController:GetMapContentWidth()
        local mapHeight = self.mapController:GetMapContentHeight()
        if mapWidth <= 0 or mapHeight <= 0 then
            return
        end

        local normalizedX = localX / mapWidth
        local normalizedY = localY / mapHeight
        if normalizedX < 0 or normalizedX > 1 or normalizedY < 0 or normalizedY > 1 then
            return
        end

        PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, normalizedX, normalizedY)
    end)
end

--- Clears the player waypoint when the waypoint modifier is active (Shift+right when shift is required).
--- @param shift boolean
function MiniMapInputController:TryRemovePlayerWaypointFromClick(shift)
    if MiniMap.fastTravel then
        return
    end
    if not self:WaypointModifierActive(shift) then
        return
    end
    MiniMap.RunWithPlayerMapForMirror(function ()
        ZO_WorldMap_RemovePlayerWaypoint()
    end)
    MiniMap.SyncHudOverlayPinsAfterNativeRefresh()
end

--- @param mouseX number
--- @param mouseY number
function MiniMapInputController:TrySetGroupPingFromClick(mouseX, mouseY)
    if MiniMap.fastTravel or not self.mapController:IsReady() then
        return
    end
    local mapData = self.mapController:GetMapData()
    if not mapData then
        return
    end
    MiniMap.RunWithPlayerMapForMirror(function ()
        local scroll = self.view.scroll
        local scrollLeft = scroll:GetLeft()
        local scrollTop = scroll:GetTop()
        local localX = mouseX - scrollLeft + scroll:GetHorizontalScroll()
        local localY = mouseY - scrollTop + scroll:GetVerticalScroll()
        local mapWidth = self.mapController:GetMapContentWidth()
        local mapHeight = self.mapController:GetMapContentHeight()
        if mapWidth <= 0 or mapHeight <= 0 then
            return
        end
        local normalizedX = localX / mapWidth
        local normalizedY = localY / mapHeight
        if normalizedX < 0 or normalizedX > 1 or normalizedY < 0 or normalizedY > 1 then
            return
        end
        PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, normalizedX, normalizedY)
    end)
end

--- ZOS map pins call ZO_WorldMap_MouseDown; shift+click is rally on the full map, not waypoint.
--- @param button integer
--- @param ctrl boolean
--- @param alt boolean
--- @param shift boolean
--- @return boolean true when the HUD minimap consumed the press (do not call stock ZO_WorldMap_MouseDown)
function MiniMapInputController:TryHandleHudMinimapWorldMapMouseDown(button, ctrl, alt, shift)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return false
    end
    if shift and not alt and not ctrl then
        local mouseX, mouseY = GetUIMousePosition()
        self:TrySetWaypointFromClick(mouseX, mouseY, true)
        return true
    end
    if not shift and not alt and ctrl then
        local mouseX, mouseY = GetUIMousePosition()
        self:TrySetGroupPingFromClick(mouseX, mouseY)
        return true
    end
    return false
end

--- @param mouseButton integer
--- @param upInside boolean
--- @return boolean true suppresses stock ZO_WorldMap_MouseUp
function MiniMapInputController:TryHandleHudMinimapWorldMapMouseUp(mouseButton, upInside)
    if not MiniMap.ShouldHudMinimapOverrideWorldMapInput() then
        return false
    end
    if mouseButton == MOUSE_BUTTON_INDEX_RIGHT then
        local shift = IsShiftKeyDown()
        local alt = IsAltKeyDown()
        local ctrl = IsControlKeyDown()
        if shift and not alt and not ctrl and self:WaypointModifierActive(true) then
            self:TryRemovePlayerWaypointFromClick(true)
        end
        return true
    end
    return false
end

--- Handles left/right mouse up on LUIE scroll/map (waypoint set/clear, pan end).
--- @param button integer
--- @param shift boolean
function MiniMapInputController:TryHandleMapPointerButtonUp(button, shift)
    if button == MOUSE_BUTTON_INDEX_RIGHT then
        if self:WaypointModifierActive(shift) then
            self:TryRemovePlayerWaypointFromClick(shift)
        end
        return
    end
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    local mouseX, mouseY = GetUIMousePosition()
    if self.pendingWaypointClick then
        self.pendingWaypointClick = false
        self:TrySetWaypointFromClick(mouseX, mouseY, shift)
        return
    end
    if self.panDragActive then
        self:StopPanDrag(mouseX, mouseY, shift)
    end
end

function MiniMapInputController:StartPanDrag(mouseX, mouseY)
    self.panDragActive = true
    self.panDragMoved = false
    self.panDragStartX = mouseX
    self.panDragStartY = mouseY
    local scroll = self.view.scroll
    self.panScrollStartX = scroll:GetHorizontalScroll()
    self.panScrollStartY = scroll:GetVerticalScroll()
    if MiniMap.SV.followPlayer == true and MiniMap.SV.zoneScrollLockEnabled ~= true then
        self.runtime:SetMapFollowsPlayer(false)
    end
end

function MiniMapInputController:CompletePanDragSession()
    local scroll = self.view.scroll
    if MiniMap.SV.zoneScrollLockEnabled == true then
        MiniMap.SV.panOffsetX = scroll:GetHorizontalScroll()
        MiniMap.SV.panOffsetY = scroll:GetVerticalScroll()
        return
    end
    if MiniMap.SV.followPlayer == true then
        local mapController = self.mapController
        self.runtime:SetMapFollowsPlayer(true)
        if mapController:IsReady() then
            self.runtime:ClearFollowScrollCache()
            self.runtime:ApplyScrollCenterOnPlayer(
                mapController:GetMapContentWidth(),
                mapController:GetMapContentHeight()
            )
        end
        return
    end
    MiniMap.SV.panOffsetX = scroll:GetHorizontalScroll()
    MiniMap.SV.panOffsetY = scroll:GetVerticalScroll()
end

--- @param mouseX number|nil
--- @param mouseY number|nil
--- @param shift boolean|nil
function MiniMapInputController:StopPanDrag(mouseX, mouseY, shift)
    if not self.panDragActive then
        return
    end
    self.panDragActive = false

    if not self.panDragMoved and mouseX and mouseY then
        self:TrySetWaypointFromClick(mouseX, mouseY, shift == true)
    end
    self:CompletePanDragSession()
end

function MiniMapInputController:OnPanDragTick()
    if not self.panDragActive then
        return
    end
    local mouseX, mouseY = GetUIMousePosition()
    local deltaX = mouseX - self.panDragStartX
    local deltaY = mouseY - self.panDragStartY
    if math.abs(deltaX) > MINIMAP_WAYPOINT_DRAG_THRESHOLD or math.abs(deltaY) > MINIMAP_WAYPOINT_DRAG_THRESHOLD then
        self.panDragMoved = true
    end
    local scroll = self.view.scroll
    scroll:SetHorizontalScroll(self.panScrollStartX - deltaX)
    scroll:SetVerticalScroll(self.panScrollStartY - deltaY)
end

function MiniMapInputController:ApplyFrameDragMouseEnabled()
    local background = self.view.background
    local zone = self.view.zone
    background:SetMouseEnabled(false)
    if zone then
        zone:SetMouseEnabled(false)
    end
end

function MiniMapInputController:IsFrameChromePinnedOpen()
    return MiniMap.SV.lockPosition ~= true
end

function MiniMapInputController:IsMouseOverFrameChromeHoverRegion()
    local frameChromeHover = self.view.frameChromeHover
    if frameChromeHover and MouseIsOver(frameChromeHover) then
        return true
    end
    local frameChrome = self.view.frameChrome
    if frameChrome and MouseIsOver(frameChrome) then
        return true
    end
    local lockButton = self.view.framePositionLock
    if lockButton and MouseIsOver(lockButton) then
        return true
    end
    local moveGrip = self.view.frameMoveGrip
    if moveGrip and not moveGrip:IsHidden() and MouseIsOver(moveGrip) then
        return true
    end
    return false
end

function MiniMapInputController:ShowFrameChrome()
    local frameChrome = self.view.frameChrome
    if frameChrome then
        frameChrome:SetHidden(false)
    end
end

function MiniMapInputController:HideFrameChromeIfPointerLeft()
    if self:IsFrameChromePinnedOpen() then
        return
    end
    if self:IsMouseOverFrameChromeHoverRegion() then
        return
    end
    local frameChrome = self.view.frameChrome
    if frameChrome then
        frameChrome:SetHidden(true)
    end
end

function MiniMapInputController:CancelFrameChromeHide()
    if self.frameChromeHideCallId then
        zo_removeCallLater(self.frameChromeHideCallId)
        self.frameChromeHideCallId = nil
    end
end

function MiniMapInputController:RefreshFrameChromeVisibility()
    if self:IsFrameChromePinnedOpen() or self:IsMouseOverFrameChromeHoverRegion() then
        self:ShowFrameChrome()
    else
        self:HideFrameChromeIfPointerLeft()
    end
end

function MiniMapInputController:OnFrameChromeHoverEnter()
    self:CancelFrameChromeHide()
    self:ShowFrameChrome()
end

function MiniMapInputController:OnFrameChromeHoverExit()
    self:CancelFrameChromeHide()
    if self:IsFrameChromePinnedOpen() then
        return
    end
    local inputController = self
    self.frameChromeHideCallId = zo_callLater(function ()
                                                  inputController.frameChromeHideCallId = nil
                                                  if inputController:IsFrameChromePinnedOpen() then
                                                      return
                                                  end
                                                  inputController:HideFrameChromeIfPointerLeft()
                                              end, MINIMAP_FRAME_CHROME_HIDE_DELAY_MS)
end

function MiniMapInputController:IsZoomButtonsFeatureEnabled()
    return self.view:IsZoomButtonsEnabled()
end

function MiniMapInputController:IsMouseOverZoomChromeRegion()
    local view = self.view
    if not view then
        return false
    end
    local zoomChromeHover = view.zoomChromeHover
    if zoomChromeHover and not zoomChromeHover:IsHidden() and MouseIsOver(zoomChromeHover) then
        return true
    end
    local zoomIn = view.zoomIn
    if zoomIn and not zoomIn:IsHidden() and MouseIsOver(zoomIn) then
        return true
    end
    local zoomOut = view.zoomOut
    if zoomOut and not zoomOut:IsHidden() and MouseIsOver(zoomOut) then
        return true
    end
    return false
end

function MiniMapInputController:CancelZoomChromeExitDebounce()
    if self.zoomChromeExitCallId then
        zo_removeCallLater(self.zoomChromeExitCallId)
        self.zoomChromeExitCallId = nil
    end
end

function MiniMapInputController:OnZoomChromeHoverEnter()
    if not self:IsZoomButtonsFeatureEnabled() then
        return
    end
    self:CancelZoomChromeExitDebounce()
    if self.view then
        self.view:RevealZoomButtonsTransient()
    end
end

function MiniMapInputController:OnZoomChromeHoverExit()
    if not self:IsZoomButtonsFeatureEnabled() then
        return
    end
    self:CancelZoomChromeExitDebounce()
    local inputController = self
    self.zoomChromeExitCallId = zo_callLater(function ()
                                                 inputController.zoomChromeExitCallId = nil
                                                 if inputController:IsMouseOverZoomChromeRegion() then
                                                     return
                                                 end
                                                 if inputController.view then
                                                     inputController.view:ScheduleZoomButtonsFadeAfterIdle()
                                                 end
                                             end, MINIMAP_FRAME_CHROME_HIDE_DELAY_MS)
end

function MiniMapInputController:OnFramePositionLockClicked(lockButton)
    self:CancelFrameChromeHide()
    MiniMap.SV.lockPosition = not MiniMap.SV.lockPosition
    MiniMap.ApplyLiveSettings()
end

--- @param button integer
function MiniMapInputController:OnFrameMoveGripMouseDown(button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    if MiniMap.SV.lockPosition then
        return
    end
    self.view.root:StartMoving()
end

--- @param button integer
function MiniMapInputController:OnFrameMoveGripMouseUp(button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    self.view.root:StopMovingOrResizing()
end

--- @param button integer
--- @param shift boolean
function MiniMapInputController:OnScrollMouseDown(button, shift)
    MiniMap.FlushHudMinimapPinMouseOverForClick()
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    if MiniMap.SV.waypointClickRequiresShift and shift then
        self.pendingWaypointClick = true
    end
end

--- @param button integer
--- @param shift boolean
function MiniMapInputController:OnScrollMouseUp(button, shift)
    self:TryHandleMapPointerButtonUp(button, shift)
end

--- @param button integer
--- @param shift boolean
function MiniMapInputController:OnMapMouseDown(button, shift)
    MiniMap.FlushHudMinimapPinMouseOverForClick()
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    if MiniMap.SV.waypointClickRequiresShift and shift then
        self.pendingWaypointClick = true
        return
    end
    local mouseX, mouseY = GetUIMousePosition()
    self:StartPanDrag(mouseX, mouseY)
end

--- @param button integer
--- @param shift boolean
function MiniMapInputController:OnMapMouseUp(button, shift)
    self:TryHandleMapPointerButtonUp(button, shift)
end

--- @param horizontal number
--- @param vertical number
function MiniMapInputController:OnScrollOffsetChanged(horizontal, vertical)
    MiniMap.SV.panOffsetX = horizontal
    MiniMap.SV.panOffsetY = vertical
end

-- Handlers called from MiniMap.xml

function MiniMap.OnScrollMouseDown(control, button, ctrl, alt, shift, command)
    if MiniMap.inputController then
        MiniMap.inputController:OnScrollMouseDown(button, shift)
    end
end

function MiniMap.OnScrollMouseUp(control, button, upInside, ctrl, alt, shift, command)
    if MiniMap.inputController then
        MiniMap.inputController:OnScrollMouseUp(button, shift)
    end
end

function MiniMap.OnMapMouseDown(control, button, ctrl, alt, shift, command)
    if MiniMap.inputController then
        MiniMap.inputController:OnMapMouseDown(button, shift)
    end
end

function MiniMap.OnMapMouseUp(control, button, upInside, ctrl, alt, shift, command)
    if MiniMap.inputController then
        MiniMap.inputController:OnMapMouseUp(button, shift)
    end
end

function MiniMap.OnMapUpdate(control, time)
    local inputController = MiniMap.inputController
    if inputController and inputController.panDragActive then
        inputController:OnPanDragTick()
    end
end

function MiniMap.OnFrameChromeHotspotMouseEnter(control)
    if MiniMap.inputController then
        MiniMap.inputController:OnFrameChromeHoverEnter()
    end
end

function MiniMap.OnFrameChromeHotspotMouseExit(control)
    if MiniMap.inputController then
        MiniMap.inputController:OnFrameChromeHoverExit()
    end
end

function MiniMap.OnFrameChromeMouseEnter(control)
    if MiniMap.inputController then
        MiniMap.inputController:OnFrameChromeHoverEnter()
    end
end

function MiniMap.OnFrameChromeMouseExit(control)
    if MiniMap.inputController then
        MiniMap.inputController:OnFrameChromeHoverExit()
    end
end

function MiniMap.OnZoomChromeHoverMouseEnter(control)
    if MiniMap.inputController then
        MiniMap.inputController:OnZoomChromeHoverEnter()
    end
end

function MiniMap.OnZoomChromeHoverMouseExit(control)
    if MiniMap.inputController then
        MiniMap.inputController:OnZoomChromeHoverExit()
    end
end

function MiniMap.OnFramePositionLockInitialized(lockButton)
    local initialState = TOGGLE_BUTTON_OPEN
    if MiniMap.SV and MiniMap.SV.lockPosition then
        initialState = TOGGLE_BUTTON_CLOSED
    end
    ZO_ToggleButton_Initialize(lockButton, TOGGLE_BUTTON_TYPE_PADLOCK, initialState)
    ZO_MouseTooltipBehavior_OnInitialized(lockButton)
    lockButton:SetTooltipString(GetString(LUIE_STRING_MINIMAP_FRAME_LOCK_TP))
end

function MiniMap.OnFramePositionLockClicked(control, button, ctrl, alt, shift, command)
    if MiniMap.inputController then
        MiniMap.inputController:OnFramePositionLockClicked(control)
    end
end

function MiniMap.OnFrameMoveGripInitialized(moveGrip)
    ZO_MouseTooltipBehavior_OnInitialized(moveGrip)
    moveGrip:SetTooltipString(GetString(LUIE_STRING_MINIMAP_FRAME_MOVE_TP))
end

function MiniMap.OnFrameMoveGripMouseDown(control, button, ctrl, alt, shift, command)
    if MiniMap.inputController then
        MiniMap.inputController:OnFrameMoveGripMouseDown(button)
    end
end

function MiniMap.OnFrameMoveGripMouseUp(control, button, upInside, ctrl, alt, shift, command)
    if MiniMap.inputController then
        MiniMap.inputController:OnFrameMoveGripMouseUp(button)
    end
end

function MiniMap.OnScrollOffsetChanged(control, horizontal, vertical)
    if MiniMap.inputController then
        MiniMap.inputController:OnScrollOffsetChanged(horizontal, vertical)
    end
end

function MiniMap.OnZoomInClicked(control, button, ctrl, alt, shift, command)
    if MiniMap.Enabled then
        MiniMap.Zoom(1)
    end
end

function MiniMap.OnZoomOutClicked(control, button, ctrl, alt, shift, command)
    if MiniMap.Enabled then
        MiniMap.Zoom(-1)
    end
end

local hudMinimapWorldMapMouseDownPreHookActive --- @type function|nil
local hudMinimapWorldMapMouseUpPreHookActive   --- @type function|nil

local function NoOpHudMinimapWorldMapMouseDownPreHook()
    return false
end

local function NoOpHudMinimapWorldMapMouseUpPreHook()
    return false
end

--- @param button integer
--- @param ctrl boolean
--- @param alt boolean
--- @param shift boolean
--- @return boolean true suppresses stock ZO_WorldMap_MouseDown
function MiniMap.HudMinimapWorldMapMouseDownPreHook(button, ctrl, alt, shift)
    if not MiniMap.ShouldHudMinimapOverrideWorldMapInput() then
        return false
    end
    local inputController = MiniMap.inputController
    if inputController and inputController:TryHandleHudMinimapWorldMapMouseDown(button, ctrl, alt, shift) then
        return true
    end
    return false
end

--- @param mapControl Control|nil
--- @param mouseButton integer
--- @param upInside boolean
--- @return boolean true suppresses stock ZO_WorldMap_MouseUp
function MiniMap.HudMinimapWorldMapMouseUpPreHook(mapControl, mouseButton, upInside)
    if not MiniMap.ShouldHudMinimapOverrideWorldMapInput() then
        return false
    end
    local inputController = MiniMap.inputController
    if inputController and inputController:TryHandleHudMinimapWorldMapMouseUp(mouseButton, upInside) then
        return true
    end
    return false
end

--- ZO_PreHook cannot be removed without /reloadui; use tail-call delegator to disable (see ZO_Hook.lua).
function MiniMap.InstallHudMinimapWorldMapInputPreHooks()
    if hudMinimapWorldMapMouseDownPreHookActive == nil then
        hudMinimapWorldMapMouseDownPreHookActive = MiniMap.HudMinimapWorldMapMouseDownPreHook
        ZO_PreHook("ZO_WorldMap_MouseDown", function (button, ctrl, alt, shift)
            return hudMinimapWorldMapMouseDownPreHookActive(button, ctrl, alt, shift)
        end)
        hudMinimapWorldMapMouseUpPreHookActive = MiniMap.HudMinimapWorldMapMouseUpPreHook
        ZO_PreHook("ZO_WorldMap_MouseUp", function (mapControl, mouseButton, upInside)
            return hudMinimapWorldMapMouseUpPreHookActive(mapControl, mouseButton, upInside)
        end)
    else
        hudMinimapWorldMapMouseDownPreHookActive = MiniMap.HudMinimapWorldMapMouseDownPreHook
        hudMinimapWorldMapMouseUpPreHookActive = MiniMap.HudMinimapWorldMapMouseUpPreHook
    end
end

--- ZO_PreHook cannot be removed without /reloadui; use tail-call delegator to disable (see ZO_Hook.lua).
function MiniMap.DisableHudMinimapWorldMapInputPreHooks()
    hudMinimapWorldMapMouseDownPreHookActive = NoOpHudMinimapWorldMapMouseDownPreHook
    hudMinimapWorldMapMouseUpPreHookActive = NoOpHudMinimapWorldMapMouseUpPreHook
end
