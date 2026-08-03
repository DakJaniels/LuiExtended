--- @diagnostic disable: duplicate-set-field, duplicate-doc-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------
-- Alert text alignment (LUIE-owned) + register default HUD controls that ZOS
-- does not already hand to HUD_MANAGER so the game HUD Editor can move them.
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

local windowManager = WINDOW_MANAGER

--- @class LUIE.Unlock : table
--- @field alertTextSetupHooksInstalled boolean|nil
--- @field unmanagedHudElementsRegistered boolean|nil
--- @field preloadSettingsCallbackInstalled boolean|nil
local Unlock =
{
    alertTextSetupHooksInstalled = false,
    unmanagedHudElementsRegistered = false,
    preloadSettingsCallbackInstalled = false,
}

-- -----------------------------------------------------------------------------
-- Alert text alignment
-- -----------------------------------------------------------------------------

local function GetAlertAlignmentPoint(alignment)
    if alignment == 1 then
        return TOPLEFT
    elseif alignment == 2 then
        return TOP
    end
    return TOPRIGHT
end

local function GetAlertTextHorizontalAlignment(alignment)
    if alignment == 1 then
        return TEXT_ALIGN_LEFT
    elseif alignment == 2 then
        return TEXT_ALIGN_CENTER
    end
    return TEXT_ALIGN_RIGHT
end

local function GetResolvedAlertFrameAlignment()
    local alignment = LUIE.SV.AlertFrameAlignment or LUIE.Defaults.AlertFrameAlignment or 3
    if alignment < 1 or alignment > 3 then
        alignment = 3
    end
    return alignment
end

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
        control:SetAnchor(point, parent, point, 0, 0)
    end
end

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

-- -----------------------------------------------------------------------------
-- HUD_MANAGER registration for controls ZOS does not register
-- Observed API: esoui/EsoUI/Ingame/HUD/hudmanager.lua
-- -----------------------------------------------------------------------------

local function GetOrCreateHudElementRef(control)
    if control.hudElementRef then
        return control.hudElementRef
    end

    local existingRef = control:GetNamedChild("HUDElementRef")
    if existingRef then
        control.hudElementRef = existingRef
        return existingRef
    end

    local ref = windowManager:CreateControl(control:GetName() .. "HUDElementRef", control, CT_CONTROL)
    if not ref then
        return nil
    end
    ref:SetExcludeFromResizeToFitExtents(true)
    ref:ClearAnchors()
    ref:SetAnchor(CENTER)
    local width, height = control:GetDimensions()
    if width <= 0 then
        width = 100
    end
    if height <= 0 then
        height = 100
    end
    ref:SetDimensions(width, height)
    control.hudElementRef = ref
    return ref
end

local function PrepareControlForHudRegistration(control)
    if not control then
        return false, nil
    end

    local primaryValid, primaryPoint, relativeTo, relativePoint, offsetX, offsetY = control:GetAnchor(0)
    if not primaryValid then
        return false, nil
    end

    local secondaryValid = control:GetAnchor(1)
    local defaultAnchor
    if secondaryValid then
        local left = control:GetLeft()
        local top = control:GetTop()
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
        defaultAnchor = ZO_Anchor:New(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        defaultAnchor = ZO_Anchor:New(primaryPoint, relativeTo, relativePoint, offsetX, offsetY)
    end

    if not GetOrCreateHudElementRef(control) then
        return false, nil
    end

    return true, defaultAnchor
end

local function GetUnmanagedHudElementSpecs()
    return
    {
        {
            control = ZO_BattlegroundHUDFragmentTopLevel,
            displayName = GetString(LUIE_STRING_DEFAULT_FRAME_BATTLEGROUND_SCORE),
            registerKeyboard = true,
            registerGamepad = true,
            isValid = function ()
                return IsActiveWorldBattleground()
            end,
        },
        {
            control = ZO_ObjectiveCaptureMeter,
            displayName = GetString(LUIE_STRING_DEFAULT_FRAME_OBJECTIVE_METER),
            registerKeyboard = true,
            registerGamepad = true,
        },
        {
            control = ZO_PlayerToPlayerAreaPromptContainer,
            displayName = GetString(LUIE_STRING_DEFAULT_FRAME_PLAYER_INTERACTION),
            registerKeyboard = true,
            registerGamepad = true,
        },
        {
            control = ZO_PlayerProgress,
            displayName = GetString(LUIE_STRING_DEFAULT_FRAME_PLAYER_PROGRESS),
            registerKeyboard = true,
            registerGamepad = true,
        },
        {
            control = ZO_ReticleContainerInteract,
            displayName = GetString(LUIE_STRING_DEFAULT_FRAME_RETICLE_CONTAINER_INTERACT),
            registerKeyboard = true,
            registerGamepad = true,
        },
        {
            control = ZO_RamTopLevel,
            displayName = GetString(SI_SIEGETYPE3),
            registerKeyboard = true,
            registerGamepad = true,
            isValid = function ()
                return IsPlayerEscortingRam()
            end,
        },
        {
            control = ZO_TutorialHudInfoTipKeyboard,
            displayName = GetString(LUIE_STRING_DEFAULT_FRAME_TUTORIALS),
            registerKeyboard = true,
            registerGamepad = false,
            isValid = function ()
                return not IsInGamepadPreferredMode()
            end,
        },
        {
            control = ZO_TutorialHudInfoTipGamepad,
            displayName = GetString(LUIE_STRING_DEFAULT_FRAME_TUTORIALS),
            registerKeyboard = false,
            registerGamepad = true,
            isValid = function ()
                return IsInGamepadPreferredMode()
            end,
        },
    }
end

local function RegisterHudElement(control, displayName, defaultAnchor, isValid, registerKeyboard, registerGamepad)
    local config =
    {
        defaultAnchor = defaultAnchor,
        isValid = isValid,
    }

    if registerKeyboard and not HUD_MANAGER:GetKeyboardElementForControl(control) then
        HUD_MANAGER:RegisterKeyboardElement(control, displayName, config)
    end
    if registerGamepad and not HUD_MANAGER:GetGamepadElementForControl(control) then
        HUD_MANAGER:RegisterGamepadElement(control, displayName, config)
    end
end

function Unlock.RegisterUnmanagedHudElements()
    if Unlock.unmanagedHudElementsRegistered then
        return
    end
    if not HUD_MANAGER or not HUD_MANAGER.RegisterKeyboardElement then
        return
    end

    local specs = GetUnmanagedHudElementSpecs()
    for _, spec in ipairs(specs) do
        local control = spec.control
        if control then
            local ready, defaultAnchor = PrepareControlForHudRegistration(control)
            if ready and defaultAnchor then
                RegisterHudElement(
                    control,
                    spec.displayName,
                    defaultAnchor,
                    spec.isValid,
                    spec.registerKeyboard ~= false,
                    spec.registerGamepad ~= false
                )
            end
        end
    end

    Unlock.unmanagedHudElementsRegistered = true
end

function Unlock.InstallUnmanagedHudElementRegistration()
    if Unlock.preloadSettingsCallbackInstalled then
        return
    end
    if not HUD_MANAGER or not HUD_MANAGER.RegisterCallback then
        return
    end

    HUD_MANAGER:RegisterCallback("PreLoadSettings", function ()
        Unlock.RegisterUnmanagedHudElements()
    end)
    Unlock.preloadSettingsCallbackInstalled = true
end

Unlock.InstallUnmanagedHudElementRegistration()

LUIE.Unlock = Unlock
LUIE.ApplyAlertFrameAlignment = Unlock.ApplyAlertFrameAlignment
LUIE.RegisterUnmanagedHudElements = Unlock.RegisterUnmanagedHudElements
