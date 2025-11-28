--- @diagnostic disable: duplicate-set-field
-- -----------------------------------------------------------------------------
--  LuiExtended Console Unlock Module                                          --
--  Handles UI element unlocking and movement for console/gamepad              --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local UI = LUIE.UI
local GridOverlay = LUIE.GridOverlay
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local EditModeController = LUIE.EditModeController
-- -----------------------------------------------------------------------------

--- @class LUIE.Unlock : table
--- @field frameMoverEnabled boolean Flag indicating if frame movers are currently enabled
--- @field movers table Table of created mover frames
--- @field defaultPanels table Table of UI elements to unlock for moving
--- @field activePanelId string? ID of currently active panel for movement
local Unlock =
{
    frameMoverEnabled = false,
    movers = {},
    activePanelId = nil,
    defaultPanels =
    {
        [ZO_HUDInfamyMeter] = { GetString(LUIE_STRING_DEFAULT_FRAME_INFAMY_METER) },
        [ZO_HUDTelvarMeter] = { GetString(LUIE_STRING_DEFAULT_FRAME_TEL_VAR_METER) },
        [ZO_HUDDaedricEnergyMeter] = { GetString(LUIE_STRING_DEFAULT_FRAME_VOLENDRUNG_METER) },
        [ZO_HUDEquipmentStatus] = { GetString(LUIE_STRING_DEFAULT_FRAME_EQUIPMENT_STATUS), 64, 64 },
        [ZO_FocusedQuestTrackerPanel] = { GetString(LUIE_STRING_DEFAULT_FRAME_QUEST_LOG), nil, 200 },
        [ZO_BattlegroundHUDFragmentTopLevel] = { GetString(LUIE_STRING_DEFAULT_FRAME_BATTLEGROUND_SCORE), nil, 200 },
        [ZO_ActionBar1] = { GetString(LUIE_STRING_DEFAULT_FRAME_ACTION_BAR) },
        [ZO_Subtitles] = { GetString(LUIE_STRING_DEFAULT_FRAME_SUBTITLES), 256, 80 },
        [ZO_ObjectiveCaptureMeter] = { GetString(LUIE_STRING_DEFAULT_FRAME_OBJECTIVE_METER), 128, 128 },
        [ZO_PlayerToPlayerAreaPromptContainer] = { GetString(LUIE_STRING_DEFAULT_FRAME_PLAYER_INTERACTION), nil, 30 },
        [ZO_SynergyTopLevelContainer] = { GetString(LUIE_STRING_DEFAULT_FRAME_SYNERGY) },
        [ZO_CompassFrame] = { GetString(LUIE_STRING_DEFAULT_FRAME_COMPASS) },
        [ZO_PlayerProgress] = { GetString(LUIE_STRING_DEFAULT_FRAME_PLAYER_PROGRESS) },
        [ZO_EndDunHUDTrackerContainer] = { GetString(LUIE_STRING_DEFAULT_FRAME_ENDLESS_DUNGEON_TRACKER), 230, 100 },
        [ZO_ReticleContainerInteract] = { GetString(LUIE_STRING_DEFAULT_FRAME_RETICLE_CONTAINER_INTERACT) }
    }
}

-- -----------------------------------------------------------------------------
-- Grid Snap Functions
-- -----------------------------------------------------------------------------

--- Snaps a position to the nearest grid point
--- @param position integer The position to snap
--- @param gridSize integer The size of the grid
--- @return integer @The snapped position
function Unlock.SnapToGrid(position, gridSize)
    position = zo_floor(position)
    if (position % gridSize >= gridSize / 2) then
        return position + (gridSize - (position % gridSize))
    else
        return position - (position % gridSize)
    end
end

--- Applies grid snapping to a pair of coordinates based on the specified grid type
--- @param left integer The x coordinate
--- @param top integer The y coordinate
--- @param gridType string The type of grid to use ("default", "unitFrames", "buffs")
--- @return integer x
--- @return integer y
function Unlock.ApplyGridSnap(left, top, gridType)
    local gridSetting = "snapToGrid" .. (gridType and ("_" .. gridType) or "")
    local sizeSetting = "snapToGridSize" .. (gridType and ("_" .. gridType) or "")

    if LUIE.SV[gridSetting] then
        local gridSize = LUIE.SV[sizeSetting] or 10
        left = Unlock.SnapToGrid(left, gridSize)
        top = Unlock.SnapToGrid(top, gridSize)
    end
    return left, top
end

-- -----------------------------------------------------------------------------
-- Template Functions
-- -----------------------------------------------------------------------------

--- Replace the template function for certain elements to also use custom positions
--- @param object table<string, function> The object containing the template function to be replaced
--- @param functionName string The name of the template function to be replaced
--- @param frameName string The name of the frame associated with the template function
function Unlock.ReplaceDefaultTemplate(object, functionName, frameName)
    local zos_function = object[functionName]
    object[functionName] = function (self)
        local result = zos_function(self)
        local frameData = LUIE.SV[frameName]
        if frameData then
            local frame = _G[frameName]
            --- @cast frame userdata
            frame:ClearAnchors()
            frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, frameData[1], frameData[2])
        end
        return result
    end
end

-- -----------------------------------------------------------------------------
-- Element Handling Functions
-- -----------------------------------------------------------------------------

--- Helper function to adjust an element
--- @param element Control The element to be adjusted
--- @param config {[1]:string, [2]:number?, [3]:number?} The table containing adjustment values
function Unlock.AdjustElement(element, config)
    element:SetClampedToScreen(true)
    if config[2] then
        element:SetWidth(config[2])
    end
    if config[3] then
        element:SetHeight(config[3])
    end
end

--- Helper function to set the anchor of an element
--- @param element Control The element to set the anchor for
--- @param frameName string The name of the frame associated with the element
function Unlock.SetAnchor(element, frameName)
    local frameData = LUIE.SV[frameName]
    if not frameData then return end

    local x, y = frameData[1], frameData[2]

    -- Apply grid snapping if enabled
    if x ~= nil and y ~= nil then
        x, y = Unlock.ApplyGridSnap(x, y, "default")
        element:ClearAnchors()
        element:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end

    -- Fix the Objective Capture Meter fill alignment.
    if element == ZO_ObjectiveCaptureMeter then
        ZO_ObjectiveCaptureMeterFrame:SetAnchor(BOTTOM, ZO_ObjectiveCaptureMeter, BOTTOM, 0, 0)
    end

    -- Setup Alert Text to anchor properly.
    if element == ZO_AlertTextNotification then
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, " ")
        local alertText
        if not IsInGamepadPreferredMode() then
            alertText = ZO_AlertTextNotification:GetChild(1)
        else
            alertText = ZO_AlertTextNotificationGamepad:GetChild(1)
        end
        if x ~= nil and y ~= nil then
            --- @diagnostic disable-next-line: undefined-field
            alertText.fadingControlBuffer.anchor = ZO_Anchor:New(TOPRIGHT, ZO_AlertTextNotification, TOPRIGHT)
        end
    end
end

-- -----------------------------------------------------------------------------
-- Mover Creation and Management
-- -----------------------------------------------------------------------------

--- Helper function to create a coordinate label for mover frames
--- @param parent Control The parent control for the label
--- @param positionText string The text to display in the label
--- @return LabelControl label The created label
function Unlock.CreateCoordinateLabel(parent, positionText)
    local label = UI:Label(parent, { TOPLEFT, TOPLEFT, 2, 2 }, nil, { 0, 2 }, "ZoFontGameSmall", positionText, false)
    label:SetColor(1, 1, 0, 1)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawLevel(5)
    label:SetDrawTier(DT_MEDIUM)

    -- Create label background
    local bg = UI:Backdrop(label, "fill", nil, { 0, 0, 0, 1 }, { 0, 0, 0, 1 }, false)
    bg:SetDrawLayer(DL_OVERLAY)
    bg:SetDrawLevel(5)
    bg:SetDrawTier(DT_LOW)

    return label
end

--- Helper function to create a top-level window (mover)
--- @param element Control The element to create the top-level window for
--- @param config {[1]:string, [2]:number?, [3]:number?} The table containing window configuration values
--- @param point number The anchor point for the top-level window
--- @param relativePoint number The relative anchor point for the top-level window
--- @param offsetX number The X offset for the top-level window
--- @param offsetY number The Y offset for the top-level window
--- @param relativeTo Control The element to which the top-level window is relative
--- @return TopLevelWindow tlw The created top-level window
function Unlock.CreateTopLevelWindow(element, config, point, relativePoint, offsetX, offsetY, relativeTo)
    local tlw = UI:TopLevel({ point, relativePoint, offsetX, offsetY, relativeTo }, { element:GetWidth(), element:GetHeight() })
    tlw.customPositionAttr = element:GetName()

    -- Create preview backdrop
    tlw.preview = UI:Backdrop(tlw, "fill", nil, nil, nil, false)
    tlw.preview:SetDrawLayer(DL_OVERLAY)
    tlw.preview:SetDrawLevel(5)
    tlw.preview:SetDrawTier(DT_MEDIUM)

    -- Get initial position from saved variables if it exists
    local positionText = "Default"
    if LUIE.SV[tlw.customPositionAttr] then
        local x = LUIE.SV[tlw.customPositionAttr][1] or 0
        local y = LUIE.SV[tlw.customPositionAttr][2] or 0
        positionText = string.format("%d, %d | %s", x, y, config[1])
    else
        positionText = string.format("Default | %s", config[1])
    end

    -- Create coordinate label with initial position
    tlw.preview.coordLabel = Unlock.CreateCoordinateLabel(tlw.preview, positionText)

    --- @param self TopLevelWindow
    local function OnMoveStart(self)
        eventManager:RegisterForUpdate("LUIE_UnlockMoveUpdate", 200, function ()
            if self.preview and self.preview.coordLabel then
                local frameName = config[1]
                self.preview.coordLabel:SetText(string.format("%d, %d | %s", self:GetLeft(), self:GetTop(), frameName))
            end
        end)
    end

    --- @param self TopLevelWindow
    local function OnMoveStop(self)
        eventManager:UnregisterForUpdate("LUIE_UnlockMoveUpdate")
        if self.preview and self.preview.coordLabel then
            local frameName = config[1]
            self.preview.coordLabel:SetText(string.format("%d, %d | %s", self:GetLeft(), self:GetTop(), frameName))
        end
    end

    -- Add movement handlers
    tlw:SetHandler("OnMoveStart", OnMoveStart)
    tlw:SetHandler("OnMoveStop", OnMoveStop)

    -- Store reference to config for later use
    tlw.config = config

    -- Add gamepad movement support using LibCombatAlerts if available
    local LCA = LibCombatAlerts
    if LCA and LCA.MoveableControl then
        local m_options = { color = 0x33DD33FF, size = 2 }
        tlw.gamepadHandler = LCA.MoveableControl:New(tlw, m_options)
        if tlw.gamepadHandler then
            local snapSize = LUIE.SV.snapToGridSize_default or 15
            if LUIE.SV.snapToGrid_default and snapSize > 0 then
                tlw.gamepadHandler:SetSnap(snapSize)
            end

            -- Register callbacks for gamepad movement
            local frameName = element:GetName()
            tlw.gamepadHandler:RegisterCallback(
                string.format("LUIE_MoveStart_%s", frameName),
                LCA.EVENT_CONTROL_MOVE_START,
                function ()
                    OnMoveStart(tlw)
                end
            )

            tlw.gamepadHandler:RegisterCallback(
                string.format("LUIE_MoveStop_%s", frameName),
                LCA.EVENT_CONTROL_MOVE_STOP,
                function (newPos)
                    OnMoveStop(tlw)
                    local left, top = tlw:GetLeft(), tlw:GetTop()
                    if LUIE.SV.snapToGrid_default then
                        left, top = Unlock.ApplyGridSnap(left, top, "default")
                        tlw:ClearAnchors()
                        tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                    end
                    LUIE.SV[tlw.customPositionAttr] = { left, top }
                    Unlock.SetElementPosition()
                    if Unlock.activePanelId == frameName then
                        Unlock.StopControlMove()
                    end
                end
            )
        end
    end

    return tlw
end

--- Helper function to initialize the mover for a given element
--- @param element Control The element to create a mover for
--- @param config {[1]:string, [2]:number?, [3]:number?} The configuration for the element
--- @return TopLevelWindow|nil mover The created mover window or nil if initialization failed
function Unlock.InitializeElementMover(element, config)
    -- Adjust width and height constraints if provided
    if config[2] then
        element:SetWidth(config[2])
    end
    if config[3] then
        element:SetHeight(config[3])
    end

    -- Retrieve the anchor information for the element
    for i = 0, MAX_ANCHORS - 1 do
        local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY, anchorConstraints = element:GetAnchor(i)
        if isValidAnchor then
            -- Special handling for the Alert Text Notification element
            if element == ZO_AlertTextNotification then
                local frameName = element:GetName()
                if not LUIE.SV[frameName] then
                    point = TOPRIGHT
                    relativeTo = GuiRoot
                    relativePoint = TOPRIGHT
                    offsetX = 0
                    offsetY = 0
                    anchorConstraints = anchorConstraints or ANCHOR_CONSTRAINS_XY
                end
            end

            -- Create and configure the top-level window (mover) for the element
            local mover = Unlock.CreateTopLevelWindow(element, config, point, relativePoint, offsetX, offsetY, relativeTo)

            -- Add OnMoveStop handler for non-LCA movers
            if not mover.gamepadHandler then
                --- @param self TopLevelWindow
                local function OnMoveStop(self)
                    local left, top = self:GetLeft(), self:GetTop()

                    -- Apply grid snapping if enabled
                    if LUIE.SV.snapToGrid_default then
                        left, top = Unlock.ApplyGridSnap(left, top, "default")
                        self:ClearAnchors()
                        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                    end

                    -- Save the new position and update the element positions
                    LUIE.SV[self.customPositionAttr] = { left, top }
                    Unlock.SetElementPosition()

                    -- Stop active movement if this was the active panel
                    if Unlock.activePanelId == self.customPositionAttr then
                        Unlock.StopControlMove()
                    end
                end
                mover:SetHandler("OnMoveStop", OnMoveStop)
            end

            return mover
        end
    end
end

-- -----------------------------------------------------------------------------
-- Panel State Management
-- -----------------------------------------------------------------------------

--- Checks if a panel should be visible based on edit mode state
--- @param frameName string The frame name to check
--- @return boolean
function Unlock.IsPanelVisible(frameName)
    if EditModeController and EditModeController:IsEditModeActive() then
        return true
    end
    return Unlock.activePanelId == frameName
end

--- Checks if a panel should be unlocked for movement
--- @param frameName string The frame name to check
--- @return boolean
function Unlock.IsPanelUnlocked(frameName)
    if EditModeController and EditModeController:IsEditModeActive() then
        local focusId = EditModeController.editModeFocusId
        return focusId == nil or focusId == frameName
    end
    return Unlock.activePanelId == frameName
end

--- Refreshes panel state (locked, visible, etc)
--- @param frameName string The frame name to refresh
function Unlock.RefreshPanelState(frameName)
    local mover = Unlock.movers[frameName]
    if not mover then
        return
    end

    local isVisible = Unlock.IsPanelVisible(frameName)
    local isUnlocked = Unlock.IsPanelUnlocked(frameName)
    local isActive = (EditModeController and EditModeController.editModeFocusId == frameName) or (Unlock.activePanelId == frameName)

    -- Update visibility
    mover:SetHidden(not isVisible)

    -- Update mouse/gamepad enabled state
    mover:SetMouseEnabled(false)
    mover:SetMovable(isUnlocked)

    -- Enable gamepad movement handler if available
    if mover.gamepadHandler then
        mover.gamepadHandler:ToggleGamepadMove(isUnlocked, 10000)
    end

    -- Update preview highlight color based on active state
    if mover.preview then
        if isActive then
            mover.preview:SetCenterColor(0.2, 0.8, 0.2, 0.35)
            mover.preview:SetEdgeColor(0.2, 0.9, 0.2, 1.0)
        else
            mover.preview:SetCenterColor(0.05, 0.6, 0.9, 0.25)
            mover.preview:SetEdgeColor(0.05, 0.6, 0.9, 0.9)
        end
    end
end

--- Refreshes state for all panels
function Unlock.RefreshAllPanels()
    for frameName, _ in pairs(Unlock.movers) do
        Unlock.RefreshPanelState(frameName)
    end
end

--- Refreshes grid overlay visibility
function Unlock.RefreshGridOverlay()
    if not Unlock.frameMoverEnabled then
        GridOverlay.SetHidden("default", true)
        return
    end

    local gridEnabled = LUIE.SV.snapToGrid_default
    local shouldShow = false

    if EditModeController and EditModeController:IsEditModeActive() then
        shouldShow = gridEnabled
    else
        shouldShow = gridEnabled and Unlock.activePanelId ~= nil
    end

    local gridSize = LUIE.SV.snapToGridSize_default or 15
    GridOverlay.Refresh("default", shouldShow, gridSize)
end

--- Starts moving a control (for gamepad mode)
--- @param frameName string The frame name to start moving
function Unlock.StartControlMove(frameName)
    if not Unlock.movers[frameName] then
        return
    end

    Unlock.activePanelId = frameName
    Unlock.RefreshAllPanels()
    Unlock.RefreshGridOverlay()

    -- Enable gamepad movement for the active panel
    local mover = Unlock.movers[frameName]
    if mover then
        if mover.gamepadHandler then
            mover.gamepadHandler:ToggleGamepadMove(true, 10000)
        else
            -- Fallback: make mover visible and movable for basic gamepad support
            mover:SetHidden(false)
            mover:SetMovable(true)
        end
    end
end

--- Stops control movement
function Unlock.StopControlMove()
    if not Unlock.activePanelId then
        return
    end

    Unlock.activePanelId = nil
    Unlock.RefreshAllPanels()
    Unlock.RefreshGridOverlay()
end

--- Run when the UI scene changes to hide the unlocked elements if we're in the Addon Settings Menu
--- @param oldState number The previous state of the UI scene
--- @param newState number The new state of the UI scene
function Unlock.OnSceneChange(oldState, newState)
    if not Unlock.frameMoverEnabled then return end

    local isHidden = (newState == SCENE_SHOWN)
    for _, mover in pairs(Unlock.movers) do
        mover:SetHidden(isHidden)
    end
    if LUIE.SV.snapToGrid_default then
        GridOverlay.SetHidden("default", isHidden)
    end
end

--- Register scene callback for the game menu
function Unlock.RegisterSceneCallback()
    local scene = sceneManager:GetScene("gameMenuInGame")
    scene:RegisterCallback("StateChange", Unlock.OnSceneChange)
end

-- -----------------------------------------------------------------------------
-- Public API Functions
-- -----------------------------------------------------------------------------

--- Called when an element mover is adjusted and on initialization to update all positions
function Unlock.SetElementPosition()
    for element, config in pairs(Unlock.defaultPanels) do
        local frameName = element:GetName()
        if LUIE.SV[frameName] then
            Unlock.AdjustElement(element, config)
            Unlock.SetAnchor(element, frameName)
        end
    end

    -- Apply custom templates
    Unlock.ReplaceDefaultTemplate(ACTIVE_COMBAT_TIP_SYSTEM, "ApplyStyle", "ZO_ActiveCombatTips")
    Unlock.ReplaceDefaultTemplate(COMPASS_FRAME, "ApplyStyle", "ZO_CompassFrame")
    Unlock.ReplaceDefaultTemplate(PLAYER_PROGRESS_BAR, "RefreshTemplate", "ZO_PlayerProgress")
    Unlock.ReplaceDefaultTemplate(ZO_HUDTracker_Base, "RefreshAnchors", "ZO_EndDunHUDTrackerContainer")
end

--- Setup element movers based on the provided state
--- @param state boolean Whether to enable or disable the movers
function Unlock.SetupElementMover(state)
    Unlock.frameMoverEnabled = state
    local isFirstRun = next(Unlock.movers) == nil

    for element, config in pairs(Unlock.defaultPanels) do
        if isFirstRun then
            local mover = Unlock.InitializeElementMover(element, config)
            if mover then
                Unlock.movers[element:GetName()] = mover
            end
        end

        local mover = Unlock.movers[element:GetName()]
        --- @cast mover userdata
        if mover then
            -- In console mode, movers are controlled by edit mode
            mover:SetMouseEnabled(false)
            mover:SetMovable(false)
            mover:SetHidden(true)
        end
    end

    if isFirstRun then
        Unlock.RegisterSceneCallback()
    end

    Unlock.RefreshAllPanels()
    Unlock.RefreshGridOverlay()
end

--- Reset the position of windows. Called from the Settings Menu
function Unlock.ResetElementPosition()
    for element, _ in pairs(Unlock.defaultPanels) do
        local frameName = element:GetName()
        LUIE.SV[frameName] = nil
    end
    ReloadUI("ingame")
end

-- -----------------------------------------------------------------------------
-- Expose public functions to LUIE namespace
-- -----------------------------------------------------------------------------

-- Export grid snap functions for use in other modules
LUIE.SnapToGrid = Unlock.SnapToGrid
LUIE.ApplyGridSnap = Unlock.ApplyGridSnap

-- Export the public API
LUIE.SetElementPosition = Unlock.SetElementPosition
LUIE.SetupElementMover = Unlock.SetupElementMover
LUIE.ResetElementPosition = Unlock.ResetElementPosition

-- Store the Unlock module in LUIE
LUIE.Unlock = Unlock
