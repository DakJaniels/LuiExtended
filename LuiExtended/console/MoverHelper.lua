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

--- Updates preview label font to use a better readable font
--- @param label userdata The label control to update
local function UpdatePreviewLabelFont(label)
    if not label or not label.SetFont then
        return
    end

    -- Use a readable font for preview labels
    local fontName = "LUIE Default Font"
    if LUIE.Fonts and LUIE.Fonts[fontName] then
        local fontSize = 14
        local fontStyle = "soft-shadow-thick"
        local fontString = ZO_CreateFontString(fontName, fontSize, fontStyle)
        label:SetFont(fontString)
    else
        -- Fallback to gamepad font if LUIE font not available
        if IsInGamepadPreferredMode() or IsConsoleUI() then
            label:SetFont("$(GAMEPAD_MEDIUM_FONT)|14|soft-shadow-thick")
        else
            label:SetFont("$(MEDIUM_FONT)|14|soft-shadow-thick")
        end
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
    if not control or not control.SetMouseEnabled or not control.SetMovable then
        return
    end

    local EditModeController = LUIE.EditModeController
    local isEditModeActive = EditModeController and EditModeController:IsEditModeActive() or false
    local editModeFocusId = EditModeController and EditModeController.editModeFocusId or nil

    -- When edit mode is active, all unlocked panels are visible and unlocked
    -- When edit mode is NOT active, panels are only visible/unlocked if individually unlocked (for settings menu)
    local isFocused = editModeFocusId == identifier

    -- Determine visibility - show if edit mode is active (all unlocked) OR if individually unlocked
    local isVisible = isEditModeActive or isUnlocked

    -- Determine unlock state - unlocked if edit mode is active (all unlocked) OR if individually unlocked
    local unlocked = isEditModeActive or isUnlocked

    -- Determine gamepad movement - only enable for focused panel when in edit mode
    local shouldGamepadMove = isEditModeActive and isFocused

    -- Update control state
    control:SetMouseEnabled(false)
    control:SetMovable(unlocked)
    if control.SetHidden then
        control:SetHidden(not isVisible)
    end

    -- Update gamepad handler lock state
    if control.gamepadHandler and control.gamepadHandler.ToggleLock then
        control.gamepadHandler:ToggleLock(not unlocked)
    end

    -- Update gamepad movement state if changed
    if control.gamepadHandler and control.gamepadHandler.ToggleGamepadMove then
        control.gamepadHandler:ToggleGamepadMove(shouldGamepadMove, 10000)
    end

    -- Update preview highlight if it exists and has the required methods
    if control.preview then
        if control.preview.SetCenterColor and control.preview.SetEdgeColor then
            if isFocused then
                control.preview:SetCenterColor(0.2, 0.8, 0.2, 0.35)
                control.preview:SetEdgeColor(0.2, 0.9, 0.2, 1.0)
            else
                control.preview:SetCenterColor(0.05, 0.6, 0.9, 0.25)
                control.preview:SetEdgeColor(0.05, 0.6, 0.9, 0.9)
            end
        end
        if control.preview.SetHidden then
            control.preview:SetHidden(not isVisible)
        end
    end

    -- Update label visibility if it exists
    if control.preview and control.preview.coordLabel then
        local showLabel = isVisible and (isEditModeActive and (EditModeController.showAllLabels or isFocused))
        control.preview.coordLabel:SetHidden(not showLabel)
        -- Update font when label is shown
        if showLabel then
            UpdatePreviewLabelFont(control.preview.coordLabel)
        end
    end

    -- Update anchor label font if it exists
    if control.preview and control.preview.anchorLabel then
        UpdatePreviewLabelFont(control.preview.anchorLabel)
    end

    -- Update preview name label font if it exists
    -- Can be directly on control (SpellCastBuffs) or on control.preview (UnitFrames companion)
    local previewLabel = control.previewLabel
    if not previewLabel and control.preview then
        previewLabel = control.preview.previewLabel
    end

    if previewLabel and previewLabel.SetFont then
        local fontName = "LUIE Default Font"
        if LUIE.Fonts and LUIE.Fonts[fontName] then
            local fontSize = 16
            local fontStyle = "soft-shadow-thick"
            local fontString = ZO_CreateFontString(fontName, fontSize, fontStyle)
            previewLabel:SetFont(fontString)
        else
            if IsInGamepadPreferredMode() or IsConsoleUI() then
                previewLabel:SetFont("$(GAMEPAD_MEDIUM_FONT)|16|soft-shadow-thick")
            else
                previewLabel:SetFont("$(MEDIUM_FONT)|16|soft-shadow-thick")
            end
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
