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

function MiniMapInputController:StartPanDrag(mouseX, mouseY)
    self.panDragActive = true
    self.panDragMoved = false
    self.panDragStartX = mouseX
    self.panDragStartY = mouseY
    local scroll = self.view.scroll
    self.panScrollStartX = scroll:GetHorizontalScroll()
    self.panScrollStartY = scroll:GetVerticalScroll()
    if MiniMap.runtime and MiniMap.SV and MiniMap.SV.followPlayer == true and MiniMap.SV.enableFixedMapPosition ~= true then
        MiniMap.runtime:SetMapFollowsPlayer(false)
    end
end

function MiniMapInputController:CompletePanDragSession()
    if not MiniMap.SV then
        return
    end
    local scroll = self.view.scroll
    if MiniMap.SV.enableFixedMapPosition == true then
        MiniMap.SV.panOffsetX = scroll:GetHorizontalScroll()
        MiniMap.SV.panOffsetY = scroll:GetVerticalScroll()
        return
    end
    if MiniMap.SV.followPlayer == true then
        local runtime = self.runtime
        local mapController = self.mapController
        if runtime then
            runtime:SetMapFollowsPlayer(true)
            if mapController and mapController:IsReady() then
                runtime:ClearFollowScrollCache()
                runtime:ApplyScrollCenterOnPlayer(
                    mapController:GetMapContentWidth(),
                    mapController:GetMapContentHeight()
                )
            end
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

function MiniMapInputController:IsMouseOverFrameChromeHoverRegion()
    local frameChromeHover = self.view.frameChromeHover
    if frameChromeHover and MouseIsOver(frameChromeHover) then
        return true
    end
    local frameChrome = self.view.frameChrome
    if frameChrome and not frameChrome:IsHidden() and MouseIsOver(frameChrome) then
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
    if self:IsMouseOverFrameChromeHoverRegion() then
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
    local inputController = self
    self.frameChromeHideCallId = zo_callLater(function ()
                                                  inputController.frameChromeHideCallId = nil
                                                  inputController:HideFrameChromeIfPointerLeft()
                                              end, MINIMAP_FRAME_CHROME_HIDE_DELAY_MS)
end

function MiniMapInputController:OnFramePositionLockClicked(lockButton)
    if not MiniMap.SV then
        return
    end
    MiniMap.SV.lockPosition = not MiniMap.SV.lockPosition
    MiniMap.ApplyLiveSettings()
end

--- @param button integer
function MiniMapInputController:OnFrameMoveGripMouseDown(button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    if not MiniMap.SV or MiniMap.SV.lockPosition then
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

--- @param button integer
--- @param shift boolean
function MiniMapInputController:OnMapMouseDown(button, shift)
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
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    local mouseX, mouseY = GetUIMousePosition()
    if self.pendingWaypointClick then
        self.pendingWaypointClick = false
        self:TrySetWaypointFromClick(mouseX, mouseY, shift)
        return
    end
    self:StopPanDrag(mouseX, mouseY, shift)
end

--- @param horizontal number
--- @param vertical number
function MiniMapInputController:OnScrollOffsetChanged(horizontal, vertical)
    if not MiniMap.SV then
        return
    end
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
