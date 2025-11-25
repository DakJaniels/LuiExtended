-- -----------------------------------------------------------------------------
--  LuiExtended Console Mover Helper                                           --
--  Helper utilities for console/gamepad UI element movement                    --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Only load on console
if not IsConsoleUI() then
    return
end

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class LUIE.ConsoleMoverHelper
local MoverHelper = {}

--- Helper to check if a control has required methods
--- @param control userdata The control to check
--- @param ... string Method names to check for
--- @return boolean
local function HasMethods(control, ...)
    if not control then return false end
    for i = 1, select('#', ...) do
        local method = select(i, ...)
        if not control[method] then return false end
    end
    return true
end

--- Creates font string for labels
--- @param fontName string The font name to use
--- @param size number The font size
--- @param style string The font style
--- @return string
local function CreateFontString(fontName, size, style)
    return ZO_CreateFontString(fontName, size, style)
end

--- Updates preview label font to use a better readable font
--- @param label userdata The label control to update
local function UpdatePreviewLabelFont(label)
    if not HasMethods(label, "SetFont") then return end

    local fontName = "LUIE Default Font"
    local fontSize = 14
    local fontStyle = "soft-shadow-thick"

    if LUIE.Fonts and LUIE.Fonts[fontName] then
        label:SetFont(CreateFontString(fontName, fontSize, fontStyle))
    else
        -- Fallback to gamepad font if LUIE font not available
        local fallbackFont = (IsInGamepadPreferredMode() or IsConsoleUI()) and "$(GAMEPAD_MEDIUM_FONT)" or "$(MEDIUM_FONT)"
        label:SetFont(fallbackFont .. "|" .. fontSize .. "|" .. fontStyle)
    end
end

--- Sets up LibCombatAlerts handler for a control
--- @param control userdata The control to set up
--- @param gridType string Grid type for snapping ("unitFrames", "buffs", etc.)
--- @param onMoveStopCallback function? Optional callback when movement stops
--- @return userdata? handler The LCA handler or nil if LCA not available
function MoverHelper.SetupGamepadHandler(control, gridType, onMoveStopCallback)
    local LCA = LibCombatAlerts
    if not (LCA and LCA.MoveableControl) then
        return nil
    end

    -- Check if handler already exists
    if control.gamepadHandler then
        return control.gamepadHandler
    end

    local m_options = { color = 0x33DD33FF, size = 2 }
    local handler = LCA.MoveableControl:New(control, m_options)
    if not handler then
        return nil
    end

    -- Set up grid snapping
    local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]
    local gridSetting = "snapToGrid_" .. gridType
    local sizeSetting = "snapToGridSize_" .. gridType
    local gridEnabled = accountWideSettings and accountWideSettings[gridSetting]
    local gridSize = (accountWideSettings and accountWideSettings[sizeSetting]) or 15

    if gridEnabled and gridSize > 0 then
        handler:SetSnap(gridSize)
    end

    -- Register move stop callback
    local controlName = control:GetName() or "Unknown"
    handler:RegisterCallback(
        string.format("LUIE_MoveStop_%s", controlName),
        LCA.EVENT_CONTROL_MOVE_STOP,
        function (newPos)
            local left, top = control:GetLeft(), control:GetTop()
            if gridEnabled then
                left, top = LUIE.ApplyGridSnap(left, top, gridType)
                control:ClearAnchors()
                control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            end
            if onMoveStopCallback then
                onMoveStopCallback(control, left, top)
            end

            -- Stop control movement if EditModeController is tracking it
            local EditModeController = LUIE.EditModeController
            if EditModeController and EditModeController.activePanelId then
                EditModeController:StopControlMove()
            end
        end
    )

    control.gamepadHandler = handler
    return handler
end

--- Updates control state based on edit mode
--- @param control userdata The control to update
--- @param identifier string Unique identifier for this control in edit mode
--- @param isUnlocked boolean Whether the control should be unlocked
function MoverHelper.UpdateControlState(control, identifier, isUnlocked)
    if not HasMethods(control, "SetMouseEnabled", "SetMovable") then return end

    local EditModeController = LUIE.EditModeController
    local isEditModeActive = EditModeController and EditModeController:IsEditModeActive() or false
    local editModeFocusId = EditModeController and EditModeController.editModeFocusId or nil

    -- Determine control states
    local isFocused = editModeFocusId == identifier
    local isVisible = isEditModeActive or isUnlocked
    local unlocked = isEditModeActive or isUnlocked
    local shouldGamepadMove = isEditModeActive and isFocused

    -- Update basic control state
    control:SetMouseEnabled(false)
    control:SetMovable(unlocked)
    if HasMethods(control, "SetHidden") then
        control:SetHidden(not isVisible)
    end

    -- Update gamepad handler
    if control.gamepadHandler then
        if HasMethods(control.gamepadHandler, "ToggleLock") then
            control.gamepadHandler:ToggleLock(not unlocked)
        end
        if HasMethods(control.gamepadHandler, "ToggleGamepadMove") then
            control.gamepadHandler:ToggleGamepadMove(shouldGamepadMove, 10000)
        end
    end

    -- Update preview elements
    if control.preview then
        MoverHelper.UpdatePreviewState(control.preview, isFocused, isVisible, isEditModeActive, EditModeController)
    end

    -- Update preview label fonts
    MoverHelper.UpdatePreviewFonts(control, isVisible, isEditModeActive, EditModeController, isFocused)
end

--- Updates preview visual state
--- @param preview userdata The preview control
--- @param isFocused boolean Whether the control is focused
--- @param isVisible boolean Whether the control is visible
--- @param isEditModeActive boolean Whether edit mode is active
--- @param EditModeController table The edit mode controller
function MoverHelper.UpdatePreviewState(preview, isFocused, isVisible, isEditModeActive, EditModeController)
    if not preview then return end

    -- Update preview colors if methods exist
    if HasMethods(preview, "SetCenterColor", "SetEdgeColor") then
        if isFocused then
            preview:SetCenterColor(0.2, 0.8, 0.2, 0.35)
            preview:SetEdgeColor(0.2, 0.9, 0.2, 1.0)
        else
            preview:SetCenterColor(0.05, 0.6, 0.9, 0.25)
            preview:SetEdgeColor(0.05, 0.6, 0.9, 0.9)
        end
    end

    -- Update preview visibility
    if HasMethods(preview, "SetHidden") then
        preview:SetHidden(not isVisible)
    end

    -- Update coordinate label visibility
    if preview.coordLabel then
        local showLabel = isVisible and (isEditModeActive and (EditModeController.showAllLabels or isFocused))
        preview.coordLabel:SetHidden(not showLabel)
        if showLabel then
            UpdatePreviewLabelFont(preview.coordLabel)
        end
    end

    -- Update anchor label font
    if preview.anchorLabel then
        UpdatePreviewLabelFont(preview.anchorLabel)
    end
end

--- Updates preview label fonts
--- @param control userdata The control containing preview labels
--- @param isVisible boolean Whether the control is visible
--- @param isEditModeActive boolean Whether edit mode is active
--- @param EditModeController table The edit mode controller
--- @param isFocused boolean Whether the control is focused
function MoverHelper.UpdatePreviewFonts(control, isVisible, isEditModeActive, EditModeController, isFocused)
    -- Update preview name label font (can be on control or control.preview)
    local previewLabel = control.previewLabel or (control.preview and control.preview.previewLabel)
    if previewLabel and HasMethods(previewLabel, "SetFont") then
        local fontName = "LUIE Default Font"
        local fontSize = 16
        local fontStyle = "soft-shadow-thick"

        if LUIE.Fonts and LUIE.Fonts[fontName] then
            previewLabel:SetFont(CreateFontString(fontName, fontSize, fontStyle))
        else
            local fallbackFont = (IsInGamepadPreferredMode() or IsConsoleUI()) and "$(GAMEPAD_MEDIUM_FONT)" or "$(MEDIUM_FONT)"
            previewLabel:SetFont(fallbackFont .. "|" .. fontSize .. "|" .. fontStyle)
        end
    end
end

--- Starts moving a control (for gamepad mode)
--- @param control userdata The control to start moving
--- @param identifier string Unique identifier for this control
function MoverHelper.StartControlMove(control, identifier)
    if not control then
        return
    end

    local EditModeController = LUIE.EditModeController
    if EditModeController then
        EditModeController.activePanelId = identifier
    end

    if control.gamepadHandler then
        control.gamepadHandler:ToggleGamepadMove(true, 10000)
    else
        control:SetHidden(false)
        control:SetMovable(true)
    end
end

--- Stops moving a control
--- @param control userdata The control to stop moving
function MoverHelper.StopControlMove(control)
    if not control then
        return
    end

    if control.gamepadHandler then
        control.gamepadHandler:ToggleGamepadMove(false)
    end

    local EditModeController = LUIE.EditModeController
    if EditModeController then
        EditModeController.activePanelId = nil
    end
end

LUIE.ConsoleMoverHelper = MoverHelper

return MoverHelper
