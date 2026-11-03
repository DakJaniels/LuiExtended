--- @diagnostic disable: duplicate-set-field, duplicate-doc-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------
-- Alert text alignment (LUIE-owned). Stock HUD frames that ZOS does not
-- register are added by HUDitorTools ExtraHudElements.lua.
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class LUIE.Unlock : table
--- @field alertTextSetupHooksInstalled boolean|nil
local Unlock =
{
    alertTextSetupHooksInstalled = false,
}

-- -----------------------------------------------------------------------------
-- Alert text alignment
-- -----------------------------------------------------------------------------

--- @param alignment number 1 = left, 2 = center, 3 = right
--- @return integer
local function GetAlertAlignmentPoint(alignment)
    if alignment == 1 then
        return TOPLEFT
    elseif alignment == 2 then
        return TOP
    end
    return TOPRIGHT
end

--- @param alignment number 1 = left, 2 = center, 3 = right
--- @return integer
local function GetAlertTextHorizontalAlignment(alignment)
    if alignment == 1 then
        return TEXT_ALIGN_LEFT
    elseif alignment == 2 then
        return TEXT_ALIGN_CENTER
    end
    return TEXT_ALIGN_RIGHT
end

--- @return number
local function GetResolvedAlertFrameAlignment()
    local alignment = LUIE.SV.AlertFrameAlignment or LUIE.Defaults.AlertFrameAlignment or 3
    if alignment < 1 or alignment > 3 then
        alignment = 3
    end
    return alignment
end

--- Match ZO_AlertLine wrap to LUIE alignment (ZOS template defaults to RIGHT in XML).
--- @param control LabelControl
--- @param alignment number|nil
function Unlock.ApplyAlertLineTextAlignment(control, alignment)
    if not control then
        return
    end
    alignment = alignment or GetResolvedAlertFrameAlignment()
    control:SetHorizontalAlignment(GetAlertTextHorizontalAlignment(alignment))
    local parent = control:GetParent()
    if parent then
        local point = GetAlertAlignmentPoint(alignment)
        control:ClearAnchors()
        control:SetAnchor(point, parent, point, 0, 0, ANCHOR_CONSTRAINS_XY)
    end
end

--- Wrap ZO_FadingControlBuffer template setup so each new alert line gets alignment.
--- @param alertMessages ZO_AlertText_Keyboard|ZO_AlertText_Gamepad|nil
local function WrapAlertFadingControlBufferTemplates(alertMessages)
    if not alertMessages or not alertMessages.alerts then
        return
    end
    local templates = alertMessages.alerts.templates
    if not templates then
        return
    end
    for _, templateData in pairs(templates) do
        if templateData.setup and not templateData._luiAlertSetupWrapped then
            local originalSetup = templateData.setup
            templateData.setup = function (control, data)
                originalSetup(control, data)
                Unlock.ApplyAlertLineTextAlignment(control)
            end
            templateData._luiAlertSetupWrapped = true
        end
    end
end

--- @param alertMessages ZO_AlertText_Keyboard|ZO_AlertText_Gamepad|nil
local function RefreshActiveAlertLineAlignment(alertMessages)
    if not alertMessages or not alertMessages.alerts then
        return
    end
    local alignment = GetResolvedAlertFrameAlignment()
    local activeEntries = alertMessages.alerts.activeEntries
    if not activeEntries then
        return
    end
    for _, entryControl in ipairs(activeEntries) do
        if entryControl.activeLines then
            for _, lineControl in ipairs(entryControl.activeLines) do
                Unlock.ApplyAlertLineTextAlignment(lineControl, alignment)
            end
        end
    end
end

function Unlock.InstallAlertTextSetupHooks()
    if Unlock.alertTextSetupHooksInstalled then
        return
    end
    WrapAlertFadingControlBufferTemplates(ALERT_MESSAGES)
    WrapAlertFadingControlBufferTemplates(ALERT_MESSAGES_GAMEPAD)
    Unlock.alertTextSetupHooksInstalled = true
end

--- Reposition scrolling alert lines inside the notification frame (Phinix / Azurah method).
--- Does not move the alert TLW; the game HUD Editor owns frame position.
--- @param alertFrame Control
--- @param alignment number
function Unlock.ApplyAlertTextFadingBufferAnchor(alertFrame, alignment)
    if not alertFrame then
        return
    end
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, " ")
    local alertText = alertFrame:GetChild(1)
    if not alertText then
        return
    end
    --- @diagnostic disable-next-line: undefined-field
    if not alertText.fadingControlBuffer then
        return
    end
    local point = GetAlertAlignmentPoint(alignment)
    --- @diagnostic disable-next-line: undefined-field
    alertText.fadingControlBuffer.anchor = ZO_Anchor:New(point, alertFrame, point)
end

--- Apply LUIE.SV.AlertFrameAlignment to keyboard/gamepad alert notification text.
function Unlock.ApplyAlertFrameAlignment()
    if LUIE.SV.HideAlertFrame then
        return
    end
    Unlock.InstallAlertTextSetupHooks()
    local alignment = GetResolvedAlertFrameAlignment()

    local alertFrames = { ZO_AlertTextNotification, ZO_AlertTextNotificationGamepad }
    for _, alertFrame in ipairs(alertFrames) do
        if alertFrame then
            Unlock.ApplyAlertTextFadingBufferAnchor(alertFrame, alignment)
        end
    end

    RefreshActiveAlertLineAlignment(ALERT_MESSAGES)
    RefreshActiveAlertLineAlignment(ALERT_MESSAGES_GAMEPAD)
end

LUIE.Unlock = Unlock
LUIE.ApplyAlertFrameAlignment = Unlock.ApplyAlertFrameAlignment
