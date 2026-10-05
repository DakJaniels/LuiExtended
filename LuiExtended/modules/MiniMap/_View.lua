-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local DEFAULT_RESIZE_HANDLE_SIZE = 8
local MINIMAP_FRAME_BACKDROP_PAD = 3
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
--- @field zoomButtonsChromeStateMachine MiniMapZoomChromeStateMachine
--- @field zoomLabelChromeStateMachine MiniMapZoomChromeStateMachine
--- @field offsetSaveSuppressed boolean|nil
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
    self:CreateZoomChromeStateMachines()
end

--- Zoom buttons and zoom label both reveal, hold, then fade. Both run on MiniMapZoomChromeStateMachine.
function MiniMapView:CreateZoomChromeStateMachines()
    local view = self

    local zoomButtonControls = {}
    if self.zoomIn then
        zoomButtonControls[#zoomButtonControls + 1] = self.zoomIn
    end
    if self.zoomOut then
        zoomButtonControls[#zoomButtonControls + 1] = self.zoomOut
    end
    local zoomButtonsChromeStateMachine = MiniMap.MiniMapZoomChromeStateMachine:New(
        "LUIE_MINIMAP_ZOOM_BUTTONS_CHROME",
        zoomButtonControls,
        MINIMAP_ZOOM_BUTTON_MAX_ALPHA,
        MINIMAP_ZOOM_CHROME_FADE_OUT_MS
    )
    function zoomButtonsChromeStateMachine:ApplyRevealedChrome()
        if view.zoomChromeHover then
            view.zoomChromeHover:SetMouseEnabled(false)
        end
        for controlIndex = 1, #zoomButtonControls do
            local zoomButton = zoomButtonControls[controlIndex]
            zoomButton:SetHidden(false)
            zoomButton:SetAlpha(MINIMAP_ZOOM_BUTTON_MAX_ALPHA)
            zoomButton:SetMouseEnabled(true)
        end
    end
    function zoomButtonsChromeStateMachine:ApplyIdleChrome()
        view:SetZoomButtonsIdleChromeState()
    end
    self.zoomButtonsChromeStateMachine = zoomButtonsChromeStateMachine

    local zoomLabelChromeStateMachine = MiniMap.MiniMapZoomChromeStateMachine:New(
        "LUIE_MINIMAP_ZOOM_LABEL_CHROME",
        { self.zoomLabel },
        MINIMAP_ZOOM_LABEL_MAX_ALPHA,
        MINIMAP_ZOOM_LABEL_FADE_OUT_MS
    )
    function zoomLabelChromeStateMachine:ApplyRevealedChrome()
        view.zoomLabel:SetHidden(false)
        view.zoomLabel:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
    end
    function zoomLabelChromeStateMachine:ApplyIdleChrome()
        view.zoomLabel:SetHidden(true)
        view.zoomLabel:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
    end
    self.zoomLabelChromeStateMachine = zoomLabelChromeStateMachine
end

--- @param settings MiniMapDefaults
--- @return number
function MiniMapView:GetResizeHandleInset(settings)
    if settings.lockSize == true then
        return 0
    end
    return DEFAULT_RESIZE_HANDLE_SIZE
end

--- Pixels the root may extend past GuiRoot so the backdrop outer edge can meet the screen.
--- Backdrop is placed at resizeInset - MINIMAP_FRAME_BACKDROP_PAD (see ApplyRootClientLayout).
--- Negative SetClampedToScreenInsets let the control pass the screen (ESOUIDocumentation.txt; Tribute uses the same sign).
--- @param settings MiniMapDefaults
--- @return number
function MiniMapView:GetFrameScreenEdgeBleed(settings)
    local backdropInsetFromRoot = self:GetResizeHandleInset(settings) - MINIMAP_FRAME_BACKDROP_PAD
    if backdropInsetFromRoot < 0 then
        return 0
    end
    return backdropInsetFromRoot
end

--- Zone label and divider hang off the root. Hidden label contributes no overflow.
--- @return number overflowLeft
--- @return number overflowTop
--- @return number overflowRight
--- @return number overflowBottom
function MiniMapView:GetZoneLabelScreenOverflow()
    local root = self.root
    local zoneLabel = self.zone
    if not root or not zoneLabel or zoneLabel:IsHidden() then
        return 0, 0, 0, 0
    end
    local overflowLeft = 0
    local overflowTop = 0
    local overflowRight = 0
    local overflowBottom = 0
    local rootLeft = root:GetLeft()
    local rootTop = root:GetTop()
    local rootRight = root:GetRight()
    local rootBottom = root:GetBottom()
    local function AccumulatePastRoot(control)
        if not control or control:IsHidden() then
            return
        end
        local controlLeft = control:GetLeft()
        local controlTop = control:GetTop()
        local controlRight = control:GetRight()
        local controlBottom = control:GetBottom()
        if controlLeft < rootLeft then
            overflowLeft = zo_max(overflowLeft, rootLeft - controlLeft)
        end
        if controlTop < rootTop then
            overflowTop = zo_max(overflowTop, rootTop - controlTop)
        end
        if controlRight > rootRight then
            overflowRight = zo_max(overflowRight, controlRight - rootRight)
        end
        if controlBottom > rootBottom then
            overflowBottom = zo_max(overflowBottom, controlBottom - rootBottom)
        end
    end
    AccumulatePastRoot(zoneLabel)
    AccumulatePastRoot(self.zoneDivider)
    return overflowLeft, overflowTop, overflowRight, overflowBottom
end

--- @param settings MiniMapDefaults
function MiniMapView:ApplyScreenEdgeClamp(settings)
    local backdropBleed = self:GetFrameScreenEdgeBleed(settings)
    local overflowLeft, overflowTop, overflowRight, overflowBottom = self:GetZoneLabelScreenOverflow()
    self.root:SetClampedToScreenInsets(
        -(backdropBleed + overflowLeft),
        -(backdropBleed + overflowTop),
        -(backdropBleed + overflowRight),
        -(backdropBleed + overflowBottom))
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
    local framePad = MINIMAP_FRAME_BACKDROP_PAD

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
    self.offsetSaveSuppressed = true
    root:SetDimensions(settings.width, settings.height)
    self:ApplyChromeVisibility(settings)
    self:ApplyZoneLabelPlacement()
    self:ApplyScreenEdgeClamp(settings)
    root:ClearAnchors()
    root:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, settings.offsetX, settings.offsetY)
    self:ApplyInteractionLocks(settings)
    self:ApplyFrameChromePlacement()
    self.offsetSaveSuppressed = false
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
    local zoneNameAboveMap = MiniMap.SV ~= nil and MiniMap.SV.zoneNameAboveMap == true

    zoneLabel:ClearAnchors()
    if infoPanelFillsZoneSlot or zoneNameAboveMap then
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
    local chromeWidth = MiniMap.FRAME_CHROME_BAR_WIDTH
    local margin = MiniMap.FRAME_CHROME_LEFT_EDGE_MARGIN
    local outsideX = MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_X
    local cornerLeft = anchorTarget:GetLeft()
    local guiLeft = GuiRoot:GetLeft()
    local neededLeft = chromeWidth + outsideX + margin
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
        lockButton:SetAnchor(LEFT, frameChrome, LEFT, 0, 0)
        moveGrip:SetAnchor(LEFT, lockButton, RIGHT, gap, 0)
    else
        lockButton:SetAnchor(RIGHT, frameChrome, RIGHT, 0, 0)
        moveGrip:SetAnchor(RIGHT, lockButton, LEFT, -gap, 0)
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
    local anchorTarget = self.background or scroll or root
    local barWidth = MiniMap.FRAME_CHROME_BAR_WIDTH
    local barHeight = MiniMap.FRAME_CHROME_BAR_HEIGHT
    local cornerInset = MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_X
    local side = self:GetFrameChromeAttachSide()
    self.frameChromeAttachSide = side

    -- Keep the grip inside the backdrop. A grip outside the frame hits the screen
    -- before the frame does, so StartMoving cannot bring the edge flush.
    frameChromeHover:ClearAnchors()
    frameChromeHover:SetDimensions(barWidth, barHeight)
    if side == "left" then
        frameChromeHover:SetAnchor(BOTTOMLEFT, anchorTarget, BOTTOMLEFT, cornerInset, -cornerInset)
    else
        frameChromeHover:SetAnchor(BOTTOMRIGHT, anchorTarget, BOTTOMRIGHT, -cornerInset, -cornerInset)
    end

    if frameChrome then
        frameChrome:ClearAnchors()
        frameChrome:SetAnchor(BOTTOMLEFT, frameChromeHover, BOTTOMLEFT, 0, 0)
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
    self:ApplyScreenEdgeClamp(settings)
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
    self.zoomButtonsChromeStateMachine:Shutdown()
    if self.zoomChromeHover then
        self.zoomChromeHover:SetHidden(not showZoom)
        self.zoomChromeHover:SetMouseEnabled(showZoom)
    end
    self:SetZoomButtonsIdleChromeState()
    self:ApplyZoneChrome(settings)
end

--- @param settings MiniMapDefaults
function MiniMapView:ApplyZoneChrome(settings)
    local showZoneName = self:GetSettingsBoolean(settings, "showZoneName", MiniMap.Defaults.showZoneName)
    self.zone:SetHidden(not showZoneName)
    self.zone:SetMouseEnabled(false)
    self.zoneDivider:SetHidden(not showZoneName)
end

function MiniMapView:ShowLoading(message)
    self.statusOverlay:SetHidden(false)
    self.statusLabel:SetText(message or "Loading")
end

function MiniMapView:HideLoading()
    self.statusOverlay:SetHidden(true)
    self.statusOverlay:SetMouseEnabled(false)
end

function MiniMapView:RevealZoomButtonsTransient()
    if not self:IsZoomButtonsEnabled() then
        return
    end
    self.zoomButtonsChromeStateMachine:Reveal()
end

--- @param holdMilliseconds number
function MiniMapView:ScheduleZoomButtonsFade(holdMilliseconds)
    if not self:IsZoomButtonsEnabled() then
        return
    end
    self.zoomButtonsChromeStateMachine:ScheduleFade(holdMilliseconds)
end

function MiniMapView:ShutdownZoomButtonsFade()
    self.zoomButtonsChromeStateMachine:Shutdown()
end

function MiniMapView:ShutdownZoomLabelFade()
    self.zoomLabelChromeStateMachine:Shutdown()
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
    self.zoomLabelChromeStateMachine:RevealThenFade(MINIMAP_ZOOM_LABEL_HOLD_MS)
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
    self.playerCam:SetResizeToFitFile(false)
    self.playerCam:SetDimensions(cameraSize, cameraSize)
end

function MiniMapView:SetupPlayerIcons()
    self.scroll:SetScrollBounding(0)
    self.player:SetMouseEnabled(false)
    self.playerCam:SetMouseEnabled(false)
    self.statusOverlay:SetMouseEnabled(false)
    self.playerCam:ClearAnchors()
    self.playerCam:SetAnchor(CENTER, self.scroll, CENTER, 0, 0)
    self.playerCam:SetAddressMode(TEX_MODE_CLAMP)
    self.playerCam:SetBlendMode(TEX_BLEND_MODE_ALPHA)
    self:ApplyPlayerIconDimensions()
    MiniMap.ApplyPlayerPipColors()
    self:ApplyFrameChromePlacement()
end

-- Handlers called from MiniMap.xml

function MiniMap.OnRootMoveStop(control)
    if MiniMap.view and MiniMap.view.offsetSaveSuppressed then
        return
    end
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
    MiniMap.OnRootMoveStop(control)
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
