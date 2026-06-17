-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local DEFAULT_RESIZE_HANDLE_SIZE = 8
local MINIMAP_ZOOM_LABEL_MAX_ALPHA = 0.4
local MINIMAP_ZOOM_CHROME_HOLD_MS = 1250
local MINIMAP_ZOOM_CHROME_FADE_OUT_MS = 200
local MINIMAP_ZOOM_LABEL_HOLD_MS = MINIMAP_ZOOM_CHROME_HOLD_MS
local MINIMAP_ZOOM_LABEL_FADE_OUT_MS = MINIMAP_ZOOM_CHROME_FADE_OUT_MS
local MINIMAP_ZOOM_BUTTON_MAX_ALPHA = 1

--- @class MiniMapView : ZO_InitializingObject
--- @field root TopLevelWindow
--- @field background BackdropControl
--- @field scroll ScrollControl
--- @field map Control
--- @field pins Control
--- @field zone LabelControl
--- @field zoneDivider TextureControl|nil
--- @field zoomLabel LabelControl
--- @field player TextureControl
--- @field playerCam TextureControl
--- @field statusOverlay StatusBarControl
--- @field statusLabel LabelControl
--- @field zoomIn ButtonControl|nil
--- @field zoomOut ButtonControl|nil
--- @field zoomChromeHover Control|nil
--- @field frameChromeHover Control|nil
--- @field frameChrome Control|nil
--- @field frameChromeAttachSide string|nil
--- @field framePositionLock ButtonControl|nil
--- @field frameMoveGrip Control|nil
--- @field zoomLabelHideLaterId integer|nil
--- @field zoomLabelFadeUpdateActive boolean|nil
--- @field zoomButtonsHideLaterId integer|nil
--- @field zoomButtonsFadeUpdateActive boolean|nil
local MiniMapView = ZO_InitializingObject:Subclass()
MiniMap.MiniMapView = MiniMapView

--- @param rootControl TopLevelWindow
function MiniMapView:Initialize(rootControl)
    self.root = rootControl
    self.background = rootControl:GetNamedChild("_Background")
    self.scroll = rootControl:GetNamedChild("_Scroll")
    self.zone = rootControl:GetNamedChild("_Zone")
    self.zoneDivider = self.zone:GetNamedChild("_Divider")
    self.zoomLabel = rootControl:GetNamedChild("_ZoomLabel")
    self.player = rootControl:GetNamedChild("_Player")
    self.playerCam = rootControl:GetNamedChild("_PlayerCam")
    self.zoomChromeHover = rootControl:GetNamedChild("_ZoomChromeHover")
    self.zoomIn = rootControl:GetNamedChild("_ZoomIn")
    self.zoomOut = rootControl:GetNamedChild("_ZoomOut")
    self.map = self.scroll:GetNamedChild("_Map")
    self.pins = self.map:GetNamedChild("_Pins")
    self.statusOverlay = self.scroll:GetNamedChild("_StatusOverlay")
    self.statusLabel = self.statusOverlay:GetNamedChild("_Label")
    self.frameChromeHover = rootControl:GetNamedChild("_FrameChromeHover")
    self.frameChrome = self.frameChromeHover:GetNamedChild("_FrameChrome")
    self.framePositionLock = self.frameChrome:GetNamedChild("_PositionLock")
    self.frameMoveGrip = self.frameChrome:GetNamedChild("_MoveGrip")
    self.zoomLabel:SetHidden(true)
    self.zoomLabel:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
end

--- @param settings MiniMapDefaults
--- @return number
function MiniMapView:GetResizeHandleInset(settings)
    if settings.lockSize == true then
        return 0
    end
    return DEFAULT_RESIZE_HANDLE_SIZE
end

--- Map/scroll area inside root; leaves root resize-handle strip mouse-free when size is unlocked.
--- @param settings MiniMapDefaults
function MiniMapView:ApplyRootClientLayout(settings)
    local root = self.root
    local width = root:GetWidth()
    local height = root:GetHeight()
    local inset = self:GetResizeHandleInset(settings)
    local contentWidth = width - 2 * inset
    local contentHeight = height - 2 * inset
    local framePad = 3

    self.scroll:ClearAnchors()
    self.scroll:SetAnchor(TOPLEFT, root, TOPLEFT, inset, inset)
    self.scroll:SetDimensions(contentWidth, contentHeight)

    self.background:ClearAnchors()
    self.background:SetAnchor(TOPLEFT, root, TOPLEFT, inset - framePad, inset - framePad)
    self.background:SetDimensions(contentWidth + 2 * framePad, contentHeight + 2 * framePad)
    self:ApplyFrameChromePlacement()
end

function MiniMapView:ApplySavedLayout(settings)
    local root = self.root
    root:ClearAnchors()
    root:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, settings.offsetX, settings.offsetY)
    root:SetDimensions(settings.width, settings.height)
    self:ApplyInteractionLocks(settings)
    self:ApplyChromeVisibility(settings)
    self:ApplyZoneLabelPlacement()
    self:ApplyFrameChromePlacement()
end

function MiniMapView:ApplyZoneLabelPlacement()
    local zoneLabel = self.zone
    local scroll = self.scroll
    local root = self.root
    if not zoneLabel or not scroll or not root then
        return
    end

    local zoneOffset = MiniMap.ZONE_LABEL_CHROME_OFFSET
    local zoneDivider = self.zoneDivider
    local infoPanelFillsZoneSlot = MiniMap.IsInfoPanelAnchorActive()

    zoneLabel:ClearAnchors()
    if infoPanelFillsZoneSlot then
        zoneLabel:SetAnchor(BOTTOM, scroll, TOP, 0, -zoneOffset)
    else
        zoneLabel:SetAnchor(TOP, root, BOTTOM, 0, zoneOffset)
    end

    if zoneDivider then
        zoneDivider:ClearAnchors()
        zoneDivider:SetAnchor(BOTTOMLEFT, zoneLabel, BOTTOMLEFT, -80, zoneOffset)
        zoneDivider:SetAnchor(BOTTOMRIGHT, zoneLabel, BOTTOMRIGHT, 80, zoneOffset)
    end
end

--- @return "left"|"right"
function MiniMapView:GetFrameChromeAttachSide()
    local root = self.root
    local scroll = self.scroll
    local anchorTarget = scroll or root
    if not anchorTarget then
        return "left"
    end
    local hotspotWidth = MiniMap.FRAME_CHROME_HOVER_SIZE
    local chromeWidth = MiniMap.FRAME_CHROME_BAR_WIDTH
    local margin = MiniMap.FRAME_CHROME_LEFT_EDGE_MARGIN
    local outsideX = MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_X
    local cornerLeft = anchorTarget:GetLeft()
    local guiLeft = GuiRoot:GetLeft()
    local neededLeft = hotspotWidth + chromeWidth + outsideX + margin
    if cornerLeft - neededLeft < guiLeft then
        return "right"
    end
    return "left"
end

--- @param side "left"|"right"
function MiniMapView:ApplyFrameChromeControlOrder(side)
    local lockButton = self.framePositionLock
    local moveGrip = self.frameMoveGrip
    local frameChrome = self.frameChrome
    if not lockButton or not moveGrip or not frameChrome then
        return
    end
    local gap = MiniMap.FRAME_CHROME_CONTROL_GAP
    lockButton:ClearAnchors()
    moveGrip:ClearAnchors()
    if side == "left" then
        lockButton:SetAnchor(RIGHT, frameChrome, RIGHT, 0, 0)
        moveGrip:SetAnchor(RIGHT, lockButton, LEFT, -gap, 0)
    else
        lockButton:SetAnchor(LEFT, frameChrome, LEFT, 0, 0)
        moveGrip:SetAnchor(LEFT, lockButton, RIGHT, gap, 0)
    end
end

function MiniMapView:ApplyFrameChromePlacement()
    local frameChromeHover = self.frameChromeHover
    local frameChrome = self.frameChrome
    local root = self.root
    local scroll = self.scroll
    if not frameChromeHover or not root then
        return
    end
    local anchorTarget = scroll or root
    local hoverSize = MiniMap.FRAME_CHROME_HOVER_SIZE
    local outsideX = MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_X
    local outsideY = MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_Y
    local side = self:GetFrameChromeAttachSide()
    self.frameChromeAttachSide = side

    frameChromeHover:ClearAnchors()
    frameChromeHover:SetDimensions(hoverSize, hoverSize)
    if side == "left" then
        frameChromeHover:SetAnchor(TOPRIGHT, anchorTarget, BOTTOMLEFT, -outsideX, outsideY)
    else
        frameChromeHover:SetAnchor(TOPLEFT, anchorTarget, BOTTOMRIGHT, outsideX, outsideY)
    end

    if frameChrome then
        frameChrome:ClearAnchors()
        if side == "left" then
            frameChrome:SetAnchor(TOPRIGHT, frameChromeHover, BOTTOMRIGHT, 0, 0)
        else
            frameChrome:SetAnchor(TOPLEFT, frameChromeHover, BOTTOMLEFT, 0, 0)
        end
        self:ApplyFrameChromeControlOrder(side)
    end
end

--- @param settings MiniMapDefaults
function MiniMapView:ApplyInteractionLocks(settings)
    local root = self.root
    root:SetMovable(settings.lockPosition ~= true)
    if settings.lockSize == true then
        root:SetResizeHandleSize(0)
    else
        root:SetResizeHandleSize(DEFAULT_RESIZE_HANDLE_SIZE)
    end
    self:ApplyRootClientLayout(settings)
    if MiniMap.inputController then
        MiniMap.inputController:ApplyFrameDragMouseEnabled()
    end
end

--- @param rootControl Control
--- @param childSuffix string
--- @return Control
function MiniMapView:GetChromeControl(rootControl, childSuffix)
    return rootControl:GetNamedChild(childSuffix)
end

function MiniMapView:ResolveChromeControls()
    local root = self.root
    self.zoomIn = self:GetChromeControl(root, "_ZoomIn")
    self.zoomOut = self:GetChromeControl(root, "_ZoomOut")
end

--- @param settings MiniMapDefaults|nil
--- @param settingKey string
--- @param defaultValue boolean
--- @return boolean
function MiniMapView:GetSettingsBoolean(settings, settingKey, defaultValue)
    if not settings then
        return defaultValue == true
    end
    local value = settings[settingKey]
    if value == nil then
        return defaultValue == true
    end
    return value == true
end

--- @return boolean
function MiniMapView:IsZoomButtonsEnabled()
    return self:GetSettingsBoolean(MiniMap.SV, "showZoomButtons", MiniMap.Defaults.showZoomButtons)
end

function MiniMapView:SetZoomButtonsIdleChromeState()
    if self.zoomIn then
        self.zoomIn:SetHidden(true)
        self.zoomIn:SetAlpha(MINIMAP_ZOOM_BUTTON_MAX_ALPHA)
        self.zoomIn:SetMouseEnabled(false)
    end
    if self.zoomOut then
        self.zoomOut:SetHidden(true)
        self.zoomOut:SetAlpha(MINIMAP_ZOOM_BUTTON_MAX_ALPHA)
        self.zoomOut:SetMouseEnabled(false)
    end
    if self.zoomChromeHover and self:IsZoomButtonsEnabled() then
        self.zoomChromeHover:SetMouseEnabled(true)
    end
end

--- @param settings MiniMapDefaults
function MiniMapView:ApplyChromeVisibility(settings)
    self:ResolveChromeControls()
    local showZoom = self:GetSettingsBoolean(settings, "showZoomButtons", MiniMap.Defaults.showZoomButtons)
    self:CancelZoomButtonsTransient()
    if self.zoomChromeHover then
        self.zoomChromeHover:SetHidden(not showZoom)
        self.zoomChromeHover:SetMouseEnabled(showZoom)
    end
    self:SetZoomButtonsIdleChromeState()
    self:ApplyZoneChrome(settings)
    self:ApplyFrameChromeFromSettings(settings)
end

--- @param settings MiniMapDefaults
function MiniMapView:ApplyZoneChrome(settings)
    local showZoneName = self:GetSettingsBoolean(settings, "showZoneName", MiniMap.Defaults.showZoneName)
    self.zone:SetHidden(not showZoneName)
    self.zone:SetMouseEnabled(false)
    self.zoneDivider:SetHidden(not showZoneName)
end

--- @param settings MiniMapDefaults
function MiniMapView:ApplyFrameChromeFromSettings(settings)
    local lockButton = self.framePositionLock
    local moveGrip = self.frameMoveGrip
    local positionLocked = settings.lockPosition == true
    local padlockState = positionLocked and TOGGLE_BUTTON_CLOSED or TOGGLE_BUTTON_OPEN
    ZO_ToggleButton_SetState(lockButton, padlockState)
    if moveGrip then
        moveGrip:SetHidden(positionLocked)
        moveGrip:SetMouseEnabled(not positionLocked)
    end
    if MiniMap.inputController then
        MiniMap.inputController:RefreshFrameChromeVisibility()
    end
end

function MiniMapView:ShowLoading(message)
    self.statusOverlay:SetHidden(false)
    self.statusLabel:SetText(message or "Loading")
end

function MiniMapView:HideLoading()
    self.statusOverlay:SetHidden(true)
    self.statusOverlay:SetMouseEnabled(false)
end

function MiniMapView:ClearZoomLabelFadeUpdate()
    local label = self.zoomLabel
    if label and self.zoomLabelFadeUpdateActive then
        label:SetHandler("OnUpdate", nil)
        self.zoomLabelFadeUpdateActive = nil
    end
end

function MiniMapView:CancelZoomLabelTransient()
    if self.zoomLabelHideLaterId then
        zo_removeCallLater(self.zoomLabelHideLaterId)
        self.zoomLabelHideLaterId = nil
    end
    self:ClearZoomLabelFadeUpdate()
end

function MiniMapView:StartZoomLabelFadeOut()
    local label = self.zoomLabel
    if not label or label:IsHidden() then
        return
    end
    self:ClearZoomLabelFadeUpdate()

    local startAlpha = MINIMAP_ZOOM_LABEL_MAX_ALPHA
    local fadeStartMs = GetFrameTimeMilliseconds()
    local view = self
    self.zoomLabelFadeUpdateActive = true
    label:SetHandler("OnUpdate", function (control)
        local elapsedMs = GetFrameTimeMilliseconds() - fadeStartMs
        local progress = zo_clamp(elapsedMs / MINIMAP_ZOOM_LABEL_FADE_OUT_MS, 0, 1)
        control:SetAlpha(startAlpha * (1 - progress))
        if progress >= 1 then
            view:ClearZoomLabelFadeUpdate()
            control:SetHidden(true)
            control:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
        end
    end)
end

function MiniMapView:ShutdownZoomLabelFade()
    self:CancelZoomLabelTransient()
    if self.zoomLabel then
        self.zoomLabel:SetHidden(true)
        self.zoomLabel:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
    end
end

function MiniMapView:ClearZoomButtonsFadeUpdate()
    local zoomIn = self.zoomIn
    if zoomIn and self.zoomButtonsFadeUpdateActive then
        zoomIn:SetHandler("OnUpdate", nil)
        self.zoomButtonsFadeUpdateActive = nil
    end
end

function MiniMapView:CancelZoomButtonsTransient()
    if self.zoomButtonsHideLaterId then
        zo_removeCallLater(self.zoomButtonsHideLaterId)
        self.zoomButtonsHideLaterId = nil
    end
    self:ClearZoomButtonsFadeUpdate()
end

function MiniMapView:RevealZoomButtonsTransient()
    if not self:IsZoomButtonsEnabled() then
        return
    end
    self:CancelZoomButtonsTransient()
    if self.zoomChromeHover then
        self.zoomChromeHover:SetMouseEnabled(false)
    end
    if self.zoomIn then
        self.zoomIn:SetHidden(false)
        self.zoomIn:SetAlpha(MINIMAP_ZOOM_BUTTON_MAX_ALPHA)
        self.zoomIn:SetMouseEnabled(true)
    end
    if self.zoomOut then
        self.zoomOut:SetHidden(false)
        self.zoomOut:SetAlpha(MINIMAP_ZOOM_BUTTON_MAX_ALPHA)
        self.zoomOut:SetMouseEnabled(true)
    end
end

function MiniMapView:StartZoomButtonsFadeOut()
    local zoomIn = self.zoomIn
    local zoomOut = self.zoomOut
    if not zoomIn or zoomIn:IsHidden() then
        return
    end
    self:ClearZoomButtonsFadeUpdate()

    local startAlpha = MINIMAP_ZOOM_BUTTON_MAX_ALPHA
    local fadeStartMs = GetFrameTimeMilliseconds()
    local view = self
    self.zoomButtonsFadeUpdateActive = true
    zoomIn:SetHandler("OnUpdate", function ()
        local elapsedMs = GetFrameTimeMilliseconds() - fadeStartMs
        local progress = zo_clamp(elapsedMs / MINIMAP_ZOOM_CHROME_FADE_OUT_MS, 0, 1)
        local alpha = startAlpha * (1 - progress)
        zoomIn:SetAlpha(alpha)
        if zoomOut and not zoomOut:IsHidden() then
            zoomOut:SetAlpha(alpha)
        end
        if progress >= 1 then
            view:ClearZoomButtonsFadeUpdate()
            view:SetZoomButtonsIdleChromeState()
        end
    end)
end

function MiniMapView:ScheduleZoomButtonsFadeAfterIdle()
    if not self:IsZoomButtonsEnabled() then
        return
    end
    self:CancelZoomButtonsTransient()
    local view = self
    self.zoomButtonsHideLaterId = zo_callLater(function ()
                                                   view.zoomButtonsHideLaterId = nil
                                                   view:StartZoomButtonsFadeOut()
                                               end, MINIMAP_ZOOM_CHROME_HOLD_MS)
end

function MiniMapView:ShutdownZoomButtonsFade()
    self:CancelZoomButtonsTransient()
    self:SetZoomButtonsIdleChromeState()
end

--- @param zoom number
--- @param revealTransient boolean|nil
function MiniMapView:SetZoomLabel(zoom, revealTransient)
    if not self.zoomLabel then
        return
    end
    self.zoomLabel:SetText(string.format("%.0f%%", zoom * 100))
    if not revealTransient then
        return
    end
    self:CancelZoomLabelTransient()
    local label = self.zoomLabel
    label:SetHidden(false)
    label:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
    local view = self
    self.zoomLabelHideLaterId = zo_callLater(function ()
                                                 view.zoomLabelHideLaterId = nil
                                                 view:StartZoomLabelFadeOut()
                                             end, MINIMAP_ZOOM_LABEL_HOLD_MS)
end

--- @param zoneName string
function MiniMapView:SetZoneName(zoneName)
    self.zone:SetText(MiniMap.StripMapNameFormatting(zoneName))
end

function MiniMapView:OnResizePersist()
    local width = self.root:GetWidth()
    local height = self.root:GetHeight()
    MiniMap.SV.width = (width < 100) and 100 or width
    MiniMap.SV.height = (height < 100) and 100 or height
    self.root:SetDimensions(MiniMap.SV.width, MiniMap.SV.height)
    self:ApplyRootClientLayout(MiniMap.SV)
end

function MiniMapView:ApplyPlayerIconDimensions()
    local drawSize = MiniMap.GetPlayerPinDrawSize()
    local cameraSize = zo_round(drawSize * MiniMap.PLAYER_CAMERA_PIP_SIZE_RATIO)
    self.player:SetResizeToFitFile(false)
    self.player:SetDimensions(drawSize, drawSize)
    self.playerCam:SetDimensions(cameraSize, cameraSize)
end

function MiniMapView:SetupPlayerIcons()
    self.scroll:SetScrollBounding(0)
    self.player:SetMouseEnabled(false)
    self.playerCam:SetMouseEnabled(false)
    self.statusOverlay:SetMouseEnabled(false)
    self.playerCam:SetAddressMode(TEX_MODE_CLAMP)
    self.playerCam:SetBlendMode(TEX_BLEND_MODE_ALPHA)
    self:ApplyPlayerIconDimensions()
    MiniMap.ApplyPlayerPipColors()
    self:ApplyFrameChromeFromSettings(MiniMap.SV)
    self:ApplyFrameChromePlacement()
end

-- Handlers called from MiniMap.xml

function MiniMap.OnRootMoveStop(control)
    MiniMap.SV.offsetX = control:GetRight() - GuiRoot:GetRight()
    MiniMap.SV.offsetY = control:GetBottom() - GuiRoot:GetBottom()
    if MiniMap.SV.positionGridDivisor and MiniMap.SV.positionGridDivisor > 1 then
        MiniMap.ApplyPositionGridSnap(MiniMap.SV)
    end
    MiniMap.ApplyChromeStacking()
end

function MiniMap.OnRootResizeStart(control)
    if MiniMap.SV.lockSize then
        return
    end
    MiniMap.resize = true
    if MiniMap.SV.keepSquareAspect == true then
        local mouseX, mouseY = GetUIMousePosition()
        local left, top, right, bottom = control:GetScreenRect()
        local minXToSide = zo_min(zo_abs(mouseX - left), zo_abs(mouseX - right))
        local minYToSide = zo_min(zo_abs(mouseY - top), zo_abs(mouseY - bottom))
        MiniMap.resizeIsWidthDriven = (minXToSide < minYToSide)
    else
        MiniMap.resizeIsWidthDriven = nil
    end
end

function MiniMap.OnRootResizeStop(control)
    if MiniMap.SV.keepSquareAspect == true then
        MiniMap.ApplySquareAspect(MiniMap.resizeIsWidthDriven)
    end
    MiniMap.resize = false
    MiniMap.resizeIsWidthDriven = nil
end

function MiniMap.OnRootMouseWheel(control, delta, ctrl, alt, shift, command)
    if MiniMap.Enabled then
        MiniMap.Zoom(delta)
    end
end

function MiniMap.OnRootRectChanged(control, newLeft, newTop, newRight, newBottom, oldLeft, oldTop, oldRight, oldBottom)
    if not MiniMap.resize or not MiniMap.view or not MiniMap.runtime then
        return
    end
    if MiniMap.SV.keepSquareAspect == true then
        MiniMap.ApplySquareAspect(MiniMap.resizeIsWidthDriven)
    else
        MiniMap.view:OnResizePersist()
    end
    MiniMap.ApplyChromeStacking()
    local mapController = MiniMap.mapController
    if mapController and mapController:IsReady() then
        mapController:ClampZoomToLimits()
    end
end
