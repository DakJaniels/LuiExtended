-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local MINIMAP_WAYPOINT_DRAG_THRESHOLD = 8
--- Mouse-exit debounce (200ms) plus the idle hold (1250ms) the zoom buttons sit through.
local MINIMAP_ZOOM_MOUSE_EXIT_HOLD_MS = 1450
local MINIMAP_DRAG_BAR_MOUSE_OVER_UPDATE_NAME = "LUIE_MiniMap_DragBarMouseOverUpdate"
local MINIMAP_DRAG_BAR_MOUSE_OVER_UPDATE_MS = 50

--- Mouse input on the minimap frame: pan drag, waypoint set/clear, group ping, wheel zoom, drag bar mouse-over,
--- padlock and frame drag bar. No world-map pre-hooks: the world map is never under the mouse here.
--- @class LUIE_MiniMap_Input : ZO_InitializingObject
--- @field manager LUIE_MiniMap_Manager
--- @field frame LUIE_MiniMap_Frame
--- @field panAndZoom LUIE_MiniMap_PanAndZoom
--- @field dragBarMouseOverUpdateRegistered boolean
--- @field panDragActive boolean
--- @field panDragMoved boolean
--- @field panDragStartX number
--- @field panDragStartY number
--- @field panScrollStartX number
--- @field panScrollStartY number
--- @field pendingWaypointClick boolean
LUIE_MiniMap_Input = ZO_InitializingObject:Subclass()

--- @param manager LUIE_MiniMap_Manager
function LUIE_MiniMap_Input:Initialize(manager)
    self.manager = manager
    self.frame = manager.frame
    self.panAndZoom = manager.panAndZoom
    self.dragBarMouseOverUpdateRegistered = false
    self.panDragActive = false
    self.panDragMoved = false
    self.panDragStartX = 0
    self.panDragStartY = 0
    self.panScrollStartX = 0
    self.panScrollStartY = 0
    self.pendingWaypointClick = false
end

--- Click actions are ignored while the map is paused (world map open, fast travel) or has no map sheet.
--- @return boolean
function LUIE_MiniMap_Input:CanInteractWithMap()
    return self.manager:IsMapInteractive() and self.panAndZoom:HasMap()
end

--- @param shift boolean
--- @return boolean
function LUIE_MiniMap_Input:WaypointModifierActive(shift)
    if MiniMap.SV.waypointClickRequiresShift then
        return shift == true
    end
    return true
end

--- @param mouseX number
--- @param mouseY number
--- @param shift boolean
function LUIE_MiniMap_Input:TrySetWaypointFromClick(mouseX, mouseY, shift)
    if not self:CanInteractWithMap() or not self:WaypointModifierActive(shift) then
        return
    end
    local normalizedX, normalizedY = self.panAndZoom:GetNormalizedPointFromScreen(mouseX, mouseY)
    if not normalizedX or not normalizedY then
        return
    end
    -- PingMap(pingType, mapDisplayType, normalizedX, normalizedY) (ESOUIDocumentation.txt); same call as
    -- ZO_WorldMap gamepad waypoint placement (WorldMap.lua:4363).
    PingMap(MAP_PIN_TYPE_PLAYER_WAYPOINT, MAP_TYPE_LOCATION_CENTERED, normalizedX, normalizedY)
    MiniMap.LogDebug("Waypoint set at %.3f, %.3f", normalizedX, normalizedY)
end

--- @param shift boolean
function LUIE_MiniMap_Input:TryRemovePlayerWaypointFromClick(shift)
    if not self:CanInteractWithMap() or not self:WaypointModifierActive(shift) then
        return
    end
    -- WorldMap.lua:2871
    ZO_WorldMap_RemovePlayerWaypoint()
end

--- @param mouseX number
--- @param mouseY number
function LUIE_MiniMap_Input:TrySetGroupPingFromClick(mouseX, mouseY)
    if not self:CanInteractWithMap() then
        return
    end
    local normalizedX, normalizedY = self.panAndZoom:GetNormalizedPointFromScreen(mouseX, mouseY)
    if not normalizedX or not normalizedY then
        return
    end
    -- WorldMap.lua:2550
    PingMap(MAP_PIN_TYPE_PING, MAP_TYPE_LOCATION_CENTERED, normalizedX, normalizedY)
end

-- Pan drag -------------------------------------------------------------------

--- OnUpdate is attached to the map control only while dragging (WorldMap.lua does the same for ZO_WorldMapContainer).
--- @param panDragUpdateEnabled boolean
function LUIE_MiniMap_Input:SetPanDragUpdateEnabled(panDragUpdateEnabled)
    local mapControl = self.frame.map
    if panDragUpdateEnabled then
        mapControl:SetHandler("OnUpdate", function ()
            self:OnPanDragUpdate()
        end)
    else
        mapControl:SetHandler("OnUpdate", nil)
    end
end

--- @param mouseX number
--- @param mouseY number
function LUIE_MiniMap_Input:StartPanDrag(mouseX, mouseY)
    self.panDragActive = true
    self.panDragMoved = false
    self.panDragStartX = mouseX
    self.panDragStartY = mouseY
    local scroll = self.frame.scroll
    self.panScrollStartX = scroll:GetHorizontalScroll()
    self.panScrollStartY = scroll:GetVerticalScroll()
    if MiniMap.SV.followPlayer == true and MiniMap.SV.zoneScrollLockEnabled ~= true then
        self.panAndZoom:SetFollowsPlayer(false)
    end
    self:SetPanDragUpdateEnabled(true)
end

function LUIE_MiniMap_Input:OnPanDragUpdate()
    if not self.panDragActive then
        return
    end
    local mouseX, mouseY = GetUIMousePosition()
    local deltaX = mouseX - self.panDragStartX
    local deltaY = mouseY - self.panDragStartY
    if zo_abs(deltaX) > MINIMAP_WAYPOINT_DRAG_THRESHOLD or zo_abs(deltaY) > MINIMAP_WAYPOINT_DRAG_THRESHOLD then
        self.panDragMoved = true
    end
    local scroll = self.frame.scroll
    scroll:SetHorizontalScroll(self.panScrollStartX - deltaX)
    scroll:SetVerticalScroll(self.panScrollStartY - deltaY)
end

--- Follow setting on: snap back to the player. Otherwise keep the panned offsets.
function LUIE_MiniMap_Input:FinishPanDrag()
    if MiniMap.SV.zoneScrollLockEnabled == true then
        self.panAndZoom:SavePanOffsets()
        return
    end
    if MiniMap.SV.followPlayer == true then
        self.panAndZoom:SetFollowsPlayer(true)
        self.panAndZoom:CenterOnPlayer()
        return
    end
    self.panAndZoom:SavePanOffsets()
end

--- @param mouseX number|nil
--- @param mouseY number|nil
--- @param shift boolean|nil
function LUIE_MiniMap_Input:StopPanDrag(mouseX, mouseY, shift)
    if not self.panDragActive then
        return
    end
    self.panDragActive = false
    self:SetPanDragUpdateEnabled(false)
    if not self.panDragMoved and mouseX and mouseY then
        self:TrySetWaypointFromClick(mouseX, mouseY, shift == true)
    end
    self:FinishPanDrag()
end

--- Cancels a drag without a click action (used when the map pauses mid-drag).
function LUIE_MiniMap_Input:CancelPanDrag()
    if not self.panDragActive then
        return
    end
    self.panDragActive = false
    self:SetPanDragUpdateEnabled(false)
    self:FinishPanDrag()
end

-- Mouse button handlers ----------------------------------------------------

--- @param button integer
--- @param shift boolean
function LUIE_MiniMap_Input:HandleMapMouseUp(button, shift)
    if button == MOUSE_BUTTON_INDEX_RIGHT then
        self:TryRemovePlayerWaypointFromClick(shift)
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

--- @param button integer
--- @param shift boolean
function LUIE_MiniMap_Input:OnScrollMouseDown(button, shift)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    if MiniMap.SV.waypointClickRequiresShift and shift then
        self.pendingWaypointClick = true
    end
end

--- @param button integer
--- @param shift boolean
function LUIE_MiniMap_Input:OnScrollMouseUp(button, shift)
    self:HandleMapMouseUp(button, shift)
end

--- @param button integer
--- @param ctrl boolean
--- @param shift boolean
function LUIE_MiniMap_Input:OnMapMouseDown(button, ctrl, shift)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    if ctrl and not shift then
        local mouseX, mouseY = GetUIMousePosition()
        self:TrySetGroupPingFromClick(mouseX, mouseY)
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
function LUIE_MiniMap_Input:OnMapMouseUp(button, shift)
    self:HandleMapMouseUp(button, shift)
end

--- @param delta number
function LUIE_MiniMap_Input:OnMouseWheel(delta)
    if not self.panAndZoom:HasMap() then
        return
    end
    self.panAndZoom:ApplyZoom(delta, true)
end

-- Controls ---------------------------------------------------------------------

--- Mouse entered the drag bar or its padlock. Exit is not event driven: OnMouseExit fires when the mouse
--- crosses from the bar onto the padlock child, which is what made the old drag bar flicker. Instead the bar is checked on an update
--- with MouseIsOver until the mouse is geometrically outside it (ZO_ContextualActionBar_OnUpdate,
--- EsoUI/Ingame/Contextual/Contextual.lua:136-141 does the same).
function LUIE_MiniMap_Input:StartDragBarMouseOverUpdate()
    self.frame:FireDragBarCommand(LUIE_MINIMAP_DRAG_BAR_TRIGGER_COMMANDS.MOUSE_ENTER)
    if self.dragBarMouseOverUpdateRegistered then
        return
    end
    self.dragBarMouseOverUpdateRegistered = true
    EVENT_MANAGER:RegisterForUpdate(MINIMAP_DRAG_BAR_MOUSE_OVER_UPDATE_NAME, MINIMAP_DRAG_BAR_MOUSE_OVER_UPDATE_MS, function ()
        self:UpdateDragBarMouseOver()
    end)
end

function LUIE_MiniMap_Input:UpdateDragBarMouseOver()
    if MouseIsOver(self.frame.dragBar) then
        return
    end
    self:StopDragBarMouseOverUpdate()
    self.frame:FireDragBarCommand(LUIE_MINIMAP_DRAG_BAR_TRIGGER_COMMANDS.MOUSE_EXIT)
end

function LUIE_MiniMap_Input:StopDragBarMouseOverUpdate()
    if not self.dragBarMouseOverUpdateRegistered then
        return
    end
    self.dragBarMouseOverUpdateRegistered = false
    EVENT_MANAGER:UnregisterForUpdate(MINIMAP_DRAG_BAR_MOUSE_OVER_UPDATE_NAME)
end

--- Same flow as ZO_MouseTooltipBehavior_OnMouseEnter (EsoUI/Libraries/ZO_Templates/ControlTemplates.lua:24-36), but
--- SetTooltipText (EsoUI/Libraries/ZO_Templates/Tooltip.lua:57) adds the line with font "" = the ZO_BaseTooltip keyboard
--- default, which does not render on GameCore where a mouse is still usable. Add the line with the platform body font
--- (LUIE.Font.GetTooltipBodyFont: "" on keyboard, ZoFontGamepad18 on GameCore) instead.
--- @param control Control
local function ShowMouseTooltip(control)
    local tooltipString = control:GetTooltipString()
    if not tooltipString or tooltipString == "" then
        return
    end
    local tooltipControl = InformationTooltip
    control.activeMouseTooltipControl = tooltipControl
    InitializeTooltip(tooltipControl)
    ZO_Tooltips_SetupDynamicTooltipAnchors(tooltipControl, control)
    tooltipControl:AddLine(tooltipString, LUIE.Font.GetTooltipBodyFont(), ZO_TOOLTIP_DEFAULT_COLOR:UnpackRGB())
end

--- Bar body: pan cursor + "drag to move" tooltip while unlocked (chat tabs do this, EsoUI/Ingame/ChatSystem/SharedChatSystem.xml:57-65).
--- @param barControl Control
function LUIE_MiniMap_Input:OnDragBarMouseEnter(barControl)
    self:StartDragBarMouseOverUpdate()
    if MiniMap.SV.lockPosition == true then
        return
    end
    WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_PAN)
    ShowMouseTooltip(barControl)
end

--- @param barControl Control
function LUIE_MiniMap_Input:OnDragBarMouseExit(barControl)
    WINDOW_MANAGER:SetMouseCursor(MOUSE_CURSOR_DO_NOT_CARE)
    ZO_MouseTooltipBehavior_OnMouseExit(barControl)
end

--- @param lockButton ButtonControl
function LUIE_MiniMap_Input:OnPositionLockMouseEnter(lockButton)
    self:StartDragBarMouseOverUpdate()
    ShowMouseTooltip(lockButton)
end

--- @param lockButton ButtonControl
function LUIE_MiniMap_Input:OnPositionLockMouseExit(lockButton)
    ZO_MouseTooltipBehavior_OnMouseExit(lockButton)
end

function LUIE_MiniMap_Input:OnZoomMouseOverAreaEnter()
    self.frame:RevealZoomButtonsTemporarily()
end

--- Moving between the mouse-over region and a zoom button fires exit then enter; the enter cancels this fade.
function LUIE_MiniMap_Input:OnZoomMouseOverAreaExit()
    self.frame:ScheduleZoomButtonsFade(MINIMAP_ZOOM_MOUSE_EXIT_HOLD_MS)
end

function LUIE_MiniMap_Input:OnPositionLockClicked()
    local positionWillLock = MiniMap.SV.lockPosition ~= true
    MiniMap.SV.lockPosition = positionWillLock
    self.manager:ApplySettings()
    if positionWillLock then
        self.frame:FireDragBarCommand(LUIE_MINIMAP_DRAG_BAR_TRIGGER_COMMANDS.PADLOCK_LOCK)
    else
        self.frame:FireDragBarCommand(LUIE_MINIMAP_DRAG_BAR_TRIGGER_COMMANDS.UNLOCK)
    end
end

--- Drag on the bar body moves the frame (SharedChatContainer:StartDraggingTab, SharedChatSystem.lua:1048-1049).
--- OnDragStart rather than OnMouseDown: a plain click on the bar does nothing.
--- @param button integer
function LUIE_MiniMap_Input:OnDragBarDragStart(button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT or MiniMap.SV.lockPosition == true then
        return
    end
    self.frame.root:StartMoving()
end

--- @param button integer
function LUIE_MiniMap_Input:OnDragBarMouseUp(button)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    -- SharedChatContainer:StopDraggingTab, SharedChatSystem.lua:1123
    self.frame.root:StopMovingOrResizing()
end
