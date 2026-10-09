-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

-- Module lifecycle -----------------------------------------------------------

--- @param enabled boolean
function MiniMap.Initialize(enabled)
    if LUIE.IsCharacterSpecificSavedVarsEnabled() then
        MiniMap.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.MiniMap, LUIE.SVVer, nil, MiniMap.Defaults, LUIE.SavedVarsProfile)
    else
        MiniMap.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.MiniMap, LUIE.SVVer, nil, MiniMap.Defaults, LUIE.SavedVarsProfile)
    end
    MiniMap.ApplyDebugLogging()

    if not enabled then
        if MiniMap.manager then
            MiniMap.manager:Stop()
        end
        LUIE_MiniMap:SetHidden(true)
        MiniMap.Enabled = false
        return
    end

    MiniMap.Enabled = true
    if not MiniMap.manager then
        MiniMap.manager = LUIE_MiniMap_Manager:New(LUIE_MiniMap)
    end
    MiniMap.ClampSavedDefaultZoom()
    MiniMap.manager:Start()
end

--- @return LUIE_MiniMap_Manager|nil
local function GetRunningManager()
    local manager = MiniMap.manager
    if MiniMap.Enabled and manager and manager.running then
        return manager
    end
    return nil
end

-- Keybinds / public API ------------------------------------------------------

--- @param delta number Wheel/keybind steps; 0 resets to the saved default zoom.
function MiniMap.Zoom(delta)
    local manager = GetRunningManager()
    if manager then
        manager.panAndZoom:ApplyZoom(delta, true)
    end
end

--- Settings: `ApplyZoom(0)` after the default zoom slider moves.
--- @param delta number
function MiniMap.ApplyZoom(delta)
    local manager = GetRunningManager()
    if manager then
        manager.panAndZoom:ApplyZoom(delta, false)
    end
end

function MiniMap.ApplyContextDefaultZoom()
    local manager = GetRunningManager()
    if manager and manager:IsIdle() then
        manager.panAndZoom:ApplyContextDefaultZoom()
    end
end

--- @param zoomIn boolean
function MiniMap.BeginHoldZoom(zoomIn)
    local manager = GetRunningManager()
    if manager then
        manager.panAndZoom:BeginHoldZoom(zoomIn)
    end
end

function MiniMap.EndHoldZoom()
    local manager = GetRunningManager()
    if manager then
        manager.panAndZoom:EndHoldZoom()
    end
end

function MiniMap.RecenterFollow()
    local manager = GetRunningManager()
    if manager then
        manager:SetFollowPlayer(true)
    end
end

--- @param followPlayer boolean
function MiniMap.SetFollowPlayer(followPlayer)
    local manager = GetRunningManager()
    if manager then
        manager:SetFollowPlayer(followPlayer)
    else
        MiniMap.SV.followPlayer = followPlayer
    end
end

function MiniMap.ToggleFixedMapPosition()
    local manager = GetRunningManager()
    if manager then
        manager.panAndZoom:ToggleFixedMapPosition(GetMapName())
    end
end

function MiniMap.ToggleShowMap()
    local manager = GetRunningManager()
    if manager then
        manager.visibility:ToggleShowMap()
    end
end

function MiniMap.ToggleShowInCombatSetting()
    local manager = GetRunningManager()
    if manager then
        manager.visibility:ToggleShowInCombatSetting()
    else
        MiniMap.SV.allowDuringCombat = not MiniMap.SV.allowDuringCombat
    end
end

function MiniMap.ToggleConsoleLayoutPreview()
    local manager = GetRunningManager()
    if manager then
        manager.visibility:ToggleConsoleLayoutPreview()
    end
end

-- Settings -------------------------------------------------------------------

function MiniMap.ApplySettings()
    local manager = GetRunningManager()
    if manager then
        manager:ApplySettings()
    end
end

--- Position lock toggled from the settings panel (padlock clicks go through LUIE_MiniMap_Input).
function MiniMap.NotifySettingsLockChanged()
    local manager = GetRunningManager()
    if manager then
        manager.frame.dragBarStateMachine:NotifySettingsLockChanged()
    end
end

--- Update interval follows `movingPinRefreshMs`.
function MiniMap.RefreshUpdateRegistration()
    local manager = GetRunningManager()
    if manager then
        manager:RefreshUpdateRegistration()
    end
end

function MiniMap.ClampSavedDefaultZoom()
    local zoomMinimum = MiniMap.MINIMAP_ZOOM_MIN_FALLBACK
    local manager = MiniMap.manager
    if manager then
        zoomMinimum = manager.panAndZoom:GetMinimumZoom()
    end
    local resetZoomLevel = MiniMap.SV.resetZoomLevel or MiniMap.Defaults.resetZoomLevel
    if resetZoomLevel < zoomMinimum then
        resetZoomLevel = zoomMinimum
    elseif resetZoomLevel > MiniMap.MINIMAP_ZOOM_MAX then
        resetZoomLevel = MiniMap.MINIMAP_ZOOM_MAX
    end
    MiniMap.SV.resetZoomLevel = resetZoomLevel
end

function MiniMap.ApplyFrameLayoutFromSavedSettings()
    local manager = GetRunningManager()
    if manager then
        manager.frame:ApplyLayoutFromSavedSettings()
    end
end

function MiniMap.ApplyZoneNameFont()
    local manager = GetRunningManager()
    if manager then
        manager.frame:ApplyZoneNameFont()
    end
end

function MiniMap.ResetPosition()
    MiniMap.SV.offsetX = MiniMap.Defaults.offsetX
    MiniMap.SV.offsetY = MiniMap.Defaults.offsetY
    MiniMap.ApplyFrameLayoutFromSavedSettings()
end

-- InfoPanel integration ------------------------------------------------------

function MiniMap.SaveInfoPanelAnchor()
    local manager = MiniMap.manager
    if manager then
        manager.integrations:SaveInfoPanelAnchor()
    end
end

function MiniMap.RestoreInfoPanelAnchor()
    local manager = MiniMap.manager
    if manager then
        manager.integrations:RestoreInfoPanelAnchor()
    end
end

function MiniMap.ApplyInfoPanelAnchor()
    local manager = GetRunningManager()
    if manager then
        manager.integrations:ApplyInfoPanelAnchor()
    end
end

-- XML handlers (frontend/MiniMap.xml) ----------------------------------------

--- @param control TopLevelWindow
function MiniMap.OnRootMoveStop(control)
    local manager = GetRunningManager()
    if manager then
        manager.frame:OnRootMoveStop(control)
    end
end

--- @param control TopLevelWindow
function MiniMap.OnRootResizeStart(control)
    local manager = GetRunningManager()
    if manager then
        manager.frame:OnRootResizeStart(control)
    end
end

--- @param control TopLevelWindow
function MiniMap.OnRootResizeStop(control)
    local manager = GetRunningManager()
    if manager then
        manager.frame:OnRootResizeStop(control)
    end
end

function MiniMap.OnRootRectChanged(control, newLeft, newTop, newRight, newBottom, oldLeft, oldTop, oldRight, oldBottom)
    local manager = GetRunningManager()
    if manager then
        manager.frame:OnRootRectChanged()
    end
end

function MiniMap.OnRootMouseWheel(control, delta, ctrl, alt, shift, command)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnMouseWheel(delta)
    end
end

function MiniMap.OnScrollMouseDown(control, button, ctrl, alt, shift, command)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnScrollMouseDown(button, shift)
    end
end

function MiniMap.OnScrollMouseUp(control, button, upInside, ctrl, alt, shift, command)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnScrollMouseUp(button, shift)
    end
end

function MiniMap.OnScrollOffsetChanged(control, horizontal, vertical)
    local manager = GetRunningManager()
    if manager then
        manager.panAndZoom:OnScrollOffsetChanged(horizontal, vertical)
    end
end

function MiniMap.OnMapMouseDown(control, button, ctrl, alt, shift, command)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnMapMouseDown(button, ctrl, shift)
    end
end

function MiniMap.OnMapMouseUp(control, button, upInside, ctrl, alt, shift, command)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnMapMouseUp(button, shift)
    end
end

--- @param barControl Control
function MiniMap.OnDragBarInitialized(barControl)
    -- EsoUI/Libraries/ZO_Templates/ControlTemplates.lua:20 ZO_MouseTooltipBehavior_OnInitialized (mixes in SetTooltipString)
    ZO_MouseTooltipBehavior_OnInitialized(barControl)
    barControl:SetTooltipString(GetString(LUIE_STRING_MINIMAP_FRAME_MOVE_TP))
end

function MiniMap.OnDragBarMouseEnter(control)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnDragBarMouseEnter(control)
    end
end

function MiniMap.OnDragBarMouseExit(control)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnDragBarMouseExit(control)
    end
end

function MiniMap.OnDragBarDragStart(control, button)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnDragBarDragStart(button)
    end
end

function MiniMap.OnDragBarMouseUp(control, button, upInside, ctrl, alt, shift, command)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnDragBarMouseUp(button)
    end
end

function MiniMap.OnZoomMouseOverAreaMouseEnter(control)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnZoomMouseOverAreaEnter()
    end
end

function MiniMap.OnZoomMouseOverAreaMouseExit(control)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnZoomMouseOverAreaExit()
    end
end

--- @param lockButton ButtonControl
function MiniMap.OnPositionLockInitialized(lockButton)
    local initialState = TOGGLE_BUTTON_OPEN
    if MiniMap.SV and MiniMap.SV.lockPosition then
        initialState = TOGGLE_BUTTON_CLOSED
    end
    -- EsoUI/Libraries/ZO_Templates/ButtonTemplates.lua ZO_ToggleButton_Initialize; ZO_MouseTooltipBehavior_OnInitialized
    ZO_ToggleButton_Initialize(lockButton, TOGGLE_BUTTON_TYPE_PADLOCK, initialState)
    ZO_MouseTooltipBehavior_OnInitialized(lockButton)
    lockButton:SetTooltipString(GetString(LUIE_STRING_MINIMAP_FRAME_LOCK_TP))
end

function MiniMap.OnPositionLockClicked(control, button, ctrl, alt, shift, command)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnPositionLockClicked()
    end
end

function MiniMap.OnPositionLockMouseEnter(control)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnPositionLockMouseEnter(control)
    end
end

function MiniMap.OnPositionLockMouseExit(control)
    local manager = GetRunningManager()
    if manager then
        manager.input:OnPositionLockMouseExit(control)
    end
end

function MiniMap.OnZoomInClicked(control, button, ctrl, alt, shift, command)
    MiniMap.Zoom(1)
end

function MiniMap.OnZoomOutClicked(control, button, ctrl, alt, shift, command)
    MiniMap.Zoom(-1)
end
