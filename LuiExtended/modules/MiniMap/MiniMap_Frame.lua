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
--- Parchment matte between the ZO_FrameBackdrop inner edge and the map sheet.
local MINIMAP_PARCHMENT_MARGIN = .01
--- worldmap_map_background_512tile.dds repeats every 512px (ZO_WorldMapContainerBackground uses coords 0-4 over MAP_WIDTH * 2).
local MINIMAP_PARCHMENT_TILE_PIXELS = 512
local MINIMAP_MIN_FRAME_SIZE = 100
local MINIMAP_ZOOM_LABEL_MAX_ALPHA = 0.4
local MINIMAP_ZOOM_REVEAL_HOLD_MS = 1250
local MINIMAP_ZOOM_FADE_OUT_MS = 200
local MINIMAP_ZOOM_BUTTON_MAX_ALPHA = 1

--- Root control, layout, loading overlay, zone/zoom labels and the drag bar / zoom controls (LUIE_MiniMap in frontend/MiniMap.xml).
--- @class LUIE_MiniMap_Frame : ZO_InitializingObject
--- @field manager LUIE_MiniMap_Manager
--- @field root TopLevelWindow
--- @field background BackdropControl
--- @field parchment TextureControl
--- @field scroll ScrollControl
--- @field map Control
--- @field tilesLayer Control
--- @field linksLayer Control
--- @field polygonsLayer Control
--- @field pinsLayer Control
--- @field zone LabelControl
--- @field zoneDivider TextureControl
--- @field zoomLabel LabelControl
--- @field player TextureControl
--- @field playerCam TextureControl
--- @field statusOverlay StatusBarControl
--- @field statusLabel LabelControl
--- @field zoomMouseOverArea Control
--- @field zoomIn ButtonControl
--- @field zoomOut ButtonControl
--- @field dragBar Control
--- @field dragBarBackdrop BackdropControl
--- @field positionLockButton ButtonControl
--- @field dragHandle Control
--- @field zoomButtonsFadeStateMachine LUIE_MiniMap_FadeStateMachine
--- @field zoomLabelFadeStateMachine LUIE_MiniMap_FadeStateMachine
--- @field dragBarStateMachine LUIE_MiniMap_DragBarStateMachine
--- @field offsetSaveSuppressed boolean
--- @field resizing boolean
LUIE_MiniMap_Frame = ZO_InitializingObject:Subclass()

--- @param manager LUIE_MiniMap_Manager
--- @param rootControl TopLevelWindow
function LUIE_MiniMap_Frame:Initialize(manager, rootControl)
    self.manager = manager
    self.root = rootControl
    self.background = rootControl:GetNamedChild("_Background")
    self.parchment = rootControl:GetNamedChild("_Parchment")
    self.scroll = rootControl:GetNamedChild("_Scroll")
    self.map = self.scroll:GetNamedChild("_Map")
    self.tilesLayer = self.map:GetNamedChild("_Tiles")
    self.linksLayer = self.map:GetNamedChild("_Links")
    self.polygonsLayer = self.map:GetNamedChild("_Polygons")
    self.pinsLayer = self.map:GetNamedChild("_Pins")
    self.statusOverlay = self.scroll:GetNamedChild("_StatusOverlay")
    self.statusLabel = self.statusOverlay:GetNamedChild("_Label")
    self.zone = rootControl:GetNamedChild("_Zone")
    self.zoneDivider = self.zone:GetNamedChild("_Divider")
    self.zoomLabel = rootControl:GetNamedChild("_ZoomLabel")
    self.player = rootControl:GetNamedChild("_Player")
    self.playerCam = rootControl:GetNamedChild("_PlayerCam")
    self.zoomMouseOverArea = rootControl:GetNamedChild("_ZoomMouseOverArea")
    self.zoomIn = rootControl:GetNamedChild("_ZoomIn")
    self.zoomOut = rootControl:GetNamedChild("_ZoomOut")
    self.dragBar = rootControl:GetNamedChild("_DragBar")
    self.dragBarBackdrop = self.dragBar:GetNamedChild("_Backdrop")
    self.positionLockButton = self.dragBar:GetNamedChild("_PositionLock")
    self.dragHandle = self.dragBar:GetNamedChild("_DragHandle")
    self.offsetSaveSuppressed = false
    self.resizing = false

    self.zoomLabel:SetHidden(true)
    self.zoomLabel:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
    self.statusOverlay:SetMouseEnabled(false)
    self.statusLabel:SetText(GetString(LUIE_STRING_MINIMAP_LOADING))
    self.background:SetMouseEnabled(false)
    self.parchment:SetMouseEnabled(false)
    self.zone:SetMouseEnabled(false)

    self:CreateZoomFadeStateMachines()
    self.dragBarStateMachine = LUIE_MiniMap_DragBarStateMachine:New(self)
end

-- Drag bar and fade state machines ------------------------------------------------------

function LUIE_MiniMap_Frame:CreateZoomFadeStateMachines()
    local zoomButtonControls = { self.zoomIn, self.zoomOut }
    self.zoomButtonsFadeStateMachine = LUIE_MiniMap_FadeStateMachine:New(
        "LUIE_MINIMAP_ZOOM_BUTTONS_FADE_STATE_MACHINE",
        zoomButtonControls,
        MINIMAP_ZOOM_BUTTON_MAX_ALPHA,
        MINIMAP_ZOOM_FADE_OUT_MS,
        function ()
            self.zoomMouseOverArea:SetMouseEnabled(false)
            for controlIndex = 1, #zoomButtonControls do
                local zoomButton = zoomButtonControls[controlIndex]
                zoomButton:SetHidden(false)
                zoomButton:SetAlpha(MINIMAP_ZOOM_BUTTON_MAX_ALPHA)
                zoomButton:SetMouseEnabled(true)
            end
        end,
        function ()
            self:ApplyZoomButtonsIdleState()
        end
    )

    self.zoomLabelFadeStateMachine = LUIE_MiniMap_FadeStateMachine:New(
        "LUIE_MINIMAP_ZOOM_LABEL_FADE_STATE_MACHINE",
        { self.zoomLabel },
        MINIMAP_ZOOM_LABEL_MAX_ALPHA,
        MINIMAP_ZOOM_FADE_OUT_MS,
        function ()
            self.zoomLabel:SetHidden(false)
            self.zoomLabel:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
        end,
        function ()
            self.zoomLabel:SetHidden(true)
            self.zoomLabel:SetAlpha(MINIMAP_ZOOM_LABEL_MAX_ALPHA)
        end
    )
end

--- Drag bar state machine OnActivated hook.
--- The bar is never SetHidden: in LockedHidden it stays mouse enabled at alpha 0 so OnMouseEnter can bring it back.
--- Only the padlock's mouse is switched off while invisible so a blind click cannot toggle the lock.
--- @param stateName string
function LUIE_MiniMap_Frame:ApplyDragBarForStateName(stateName)
    local positionLocked = stateName ~= "Unlocked"
    local dragBarShown = stateName ~= "LockedHidden"
    local padlockState = TOGGLE_BUTTON_OPEN
    if positionLocked then
        padlockState = TOGGLE_BUTTON_CLOSED
    end
    -- EsoUI/Libraries/ZO_Templates/ButtonTemplates.lua:167 ZO_ToggleButton_SetState
    ZO_ToggleButton_SetState(self.positionLockButton, padlockState)
    self.positionLockButton:SetMouseEnabled(dragBarShown)
    self.dragHandle:SetHidden(positionLocked)
    self.dragBar:SetAlpha(dragBarShown and 1 or 0)
    self.root:SetMovable(not positionLocked)
    self:ApplyDragBarPlacement()
end

--- @param commandName string
function LUIE_MiniMap_Frame:FireDragBarCommand(commandName)
    self.dragBarStateMachine:FireCallbacks(commandName)
end

-- Layout ---------------------------------------------------------------------

--- @param settings MiniMapDefaults
--- @return number
function LUIE_MiniMap_Frame:GetResizeHandleInset(settings)
    if settings.lockSize == true then
        return 0
    end
    return DEFAULT_RESIZE_HANDLE_SIZE
end

--- Pixels the root may extend past GuiRoot so the backdrop outer edge can meet the screen.
--- Negative SetClampedToScreenInsets let the control pass the screen edge (ESOUIDocumentation.txt).
--- @param settings MiniMapDefaults
--- @return number
function LUIE_MiniMap_Frame:GetFrameScreenEdgeBleed(settings)
    local backdropInsetFromRoot = self:GetResizeHandleInset(settings) - MINIMAP_FRAME_BACKDROP_PAD - MINIMAP_PARCHMENT_MARGIN
    if backdropInsetFromRoot < 0 then
        return 0
    end
    return backdropInsetFromRoot
end

--- Zone label and divider hang off the root. Hidden label contributes no overflow.
--- @return number overflowLeft, number overflowTop, number overflowRight, number overflowBottom
function LUIE_MiniMap_Frame:GetZoneLabelScreenOverflow()
    local root = self.root
    if self.zone:IsHidden() then
        return 0, 0, 0, 0
    end
    local overflowLeft, overflowTop, overflowRight, overflowBottom = 0, 0, 0, 0
    local rootLeft, rootTop, rootRight, rootBottom = root:GetLeft(), root:GetTop(), root:GetRight(), root:GetBottom()
    local function AccumulatePastRoot(control)
        if control:IsHidden() then
            return
        end
        local controlLeft, controlTop, controlRight, controlBottom = control:GetLeft(), control:GetTop(), control:GetRight(), control:GetBottom()
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
    AccumulatePastRoot(self.zone)
    AccumulatePastRoot(self.zoneDivider)
    return overflowLeft, overflowTop, overflowRight, overflowBottom
end

--- @param settings MiniMapDefaults
function LUIE_MiniMap_Frame:ApplyScreenEdgeClamp(settings)
    local backdropBleed = self:GetFrameScreenEdgeBleed(settings)
    local overflowLeft, overflowTop, overflowRight, overflowBottom = self:GetZoneLabelScreenOverflow()
    self.root:SetClampedToScreenInsets(
        -(backdropBleed + overflowLeft),
        -(backdropBleed + overflowTop),
        -(backdropBleed + overflowRight),
        -(backdropBleed + overflowBottom))
end

--- Scroll area inside the root; leaves the resize-handle strip mouse-free when size is unlocked.
--- @param settings MiniMapDefaults
function LUIE_MiniMap_Frame:ApplyRootLayout(settings)
    local root = self.root
    local inset = self:GetResizeHandleInset(settings)
    local contentWidth = root:GetWidth() - 2 * inset
    local contentHeight = root:GetHeight() - 2 * inset
    -- Frame grows outward from the scroll: parchment matte, then the ZO_FrameBackdrop pad.
    local frameOutset = MINIMAP_FRAME_BACKDROP_PAD + MINIMAP_PARCHMENT_MARGIN

    self.scroll:ClearAnchors()
    self.scroll:SetAnchor(TOPLEFT, root, TOPLEFT, inset, inset)
    self.scroll:SetDimensions(contentWidth, contentHeight)

    local backgroundWidth = contentWidth + 2 * frameOutset
    local backgroundHeight = contentHeight + 2 * frameOutset
    self.background:ClearAnchors()
    self.background:SetAnchor(TOPLEFT, root, TOPLEFT, inset - frameOutset, inset - frameOutset)
    self.background:SetDimensions(backgroundWidth, backgroundHeight)

    -- Parchment is anchored to the backdrop in XML; keep the 512px tile at 1:1 scale.
    self.parchment:SetTextureCoords(0, backgroundWidth / MINIMAP_PARCHMENT_TILE_PIXELS, 0, backgroundHeight / MINIMAP_PARCHMENT_TILE_PIXELS)
    self:ApplyDragBarPlacement()
end

--- @param settings MiniMapDefaults
function LUIE_MiniMap_Frame:ApplySavedLayout(settings)
    local root = self.root
    self.offsetSaveSuppressed = true
    root:SetDimensions(settings.width, settings.height)
    self:ApplyControlVisibility(settings)
    self:ApplyZoneLabelPlacement()
    self:ApplyScreenEdgeClamp(settings)
    root:ClearAnchors()
    root:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, settings.offsetX, settings.offsetY)
    self:ApplyInteractionLocks(settings)
    self:ApplyDragBarPlacement()
    self.offsetSaveSuppressed = false
end

function LUIE_MiniMap_Frame:ApplyZoneLabelPlacement()
    local zoneOffset = MiniMap.ZONE_LABEL_OFFSET
    local infoPanelFillsZoneSlot = MiniMap.IsInfoPanelAnchorActive()
    local zoneNameAboveMap = MiniMap.SV.zoneNameAboveMap == true

    self.zone:ClearAnchors()
    if infoPanelFillsZoneSlot or zoneNameAboveMap then
        self.zone:SetAnchor(BOTTOM, self.scroll, TOP, 0, -zoneOffset)
    else
        self.zone:SetAnchor(TOP, self.root, BOTTOM, 0, zoneOffset)
    end

    self.zoneDivider:ClearAnchors()
    self.zoneDivider:SetAnchor(BOTTOMLEFT, self.zone, BOTTOMLEFT, -80, zoneOffset)
    self.zoneDivider:SetAnchor(BOTTOMRIGHT, self.zone, BOTTOMRIGHT, 80, zoneOffset)
end

--- The bar lives inside the map scroll area (bottom-left; the zoom buttons own the bottom-right), so it can never
--- hit the screen edge before the frame does. The visible backdrop is inset by DRAG_BAR_HIT_PADDING on every side.
function LUIE_MiniMap_Frame:ApplyDragBarPlacement()
    local hitPadding = MiniMap.DRAG_BAR_HIT_PADDING
    local visibleWidth = MiniMap.DRAG_BAR_BAR_WIDTH_UNLOCKED
    if MiniMap.SV.lockPosition == true then
        visibleWidth = MiniMap.DRAG_BAR_BAR_WIDTH_LOCKED
    end
    local cornerOffset = MiniMap.DRAG_BAR_CORNER_INSET - hitPadding

    local dragBar = self.dragBar
    dragBar:ClearAnchors()
    dragBar:SetDimensions(visibleWidth + 2 * hitPadding, MiniMap.DRAG_BAR_BAR_HEIGHT + 2 * hitPadding)
    dragBar:SetAnchor(BOTTOMLEFT, self.scroll, BOTTOMLEFT, cornerOffset, -cornerOffset)
end

--- @param settings MiniMapDefaults
function LUIE_MiniMap_Frame:ApplyInteractionLocks(settings)
    local root = self.root
    root:SetMovable(settings.lockPosition ~= true)
    if settings.lockSize == true then
        root:SetResizeHandleSize(0)
    else
        root:SetResizeHandleSize(DEFAULT_RESIZE_HANDLE_SIZE)
    end
    self:ApplyRootLayout(settings)
    self:ApplyScreenEdgeClamp(settings)
    self.background:SetMouseEnabled(false)
    self.zone:SetMouseEnabled(false)
end

-- Zoom controls ----------------------------------------------------------------

--- @return boolean
function LUIE_MiniMap_Frame:IsZoomButtonsEnabled()
    local showZoomButtons = MiniMap.SV.showZoomButtons
    if showZoomButtons == nil then
        return MiniMap.Defaults.showZoomButtons == true
    end
    return showZoomButtons == true
end

function LUIE_MiniMap_Frame:ApplyZoomButtonsIdleState()
    self.zoomIn:SetHidden(true)
    self.zoomIn:SetAlpha(MINIMAP_ZOOM_BUTTON_MAX_ALPHA)
    self.zoomIn:SetMouseEnabled(false)
    self.zoomOut:SetHidden(true)
    self.zoomOut:SetAlpha(MINIMAP_ZOOM_BUTTON_MAX_ALPHA)
    self.zoomOut:SetMouseEnabled(false)
    if self:IsZoomButtonsEnabled() then
        self.zoomMouseOverArea:SetMouseEnabled(true)
    end
end

--- @param settings MiniMapDefaults
function LUIE_MiniMap_Frame:ApplyControlVisibility(settings)
    local showZoom = self:IsZoomButtonsEnabled()
    self.zoomButtonsFadeStateMachine:Shutdown()
    self.zoomMouseOverArea:SetHidden(not showZoom)
    self.zoomMouseOverArea:SetMouseEnabled(showZoom)
    self:ApplyZoomButtonsIdleState()
    self:ApplyZoneLabelVisibility(settings)
end

--- @param settings MiniMapDefaults
function LUIE_MiniMap_Frame:ApplyZoneLabelVisibility(settings)
    local showZoneName = settings.showZoneName
    if showZoneName == nil then
        showZoneName = MiniMap.Defaults.showZoneName
    end
    self.zone:SetHidden(not showZoneName)
    self.zone:SetMouseEnabled(false)
    self.zoneDivider:SetHidden(not showZoneName)
end

function LUIE_MiniMap_Frame:RevealZoomButtonsTemporarily()
    if not self:IsZoomButtonsEnabled() then
        return
    end
    self.zoomButtonsFadeStateMachine:Reveal()
end

--- @param holdMilliseconds number
function LUIE_MiniMap_Frame:ScheduleZoomButtonsFade(holdMilliseconds)
    if not self:IsZoomButtonsEnabled() then
        return
    end
    self.zoomButtonsFadeStateMachine:ScheduleFade(holdMilliseconds)
end

function LUIE_MiniMap_Frame:ShutdownFadeStateMachines()
    self.zoomButtonsFadeStateMachine:Shutdown()
    self.zoomLabelFadeStateMachine:Shutdown()
end

--- @param zoom number
--- @param revealTemporarily boolean|nil
function LUIE_MiniMap_Frame:SetZoomLabel(zoom, revealTemporarily)
    self.zoomLabel:SetText(string.format("%.0f%%", zoom * 100))
    if revealTemporarily then
        self.zoomLabelFadeStateMachine:RevealThenFade(MINIMAP_ZOOM_REVEAL_HOLD_MS)
    end
end

-- Loading overlay / labels ---------------------------------------------------

function LUIE_MiniMap_Frame:ShowLoading()
    self.statusOverlay:SetHidden(false)
end

function LUIE_MiniMap_Frame:HideLoading()
    self.statusOverlay:SetHidden(true)
end

--- @param zoneName string
function LUIE_MiniMap_Frame:SetZoneName(zoneName)
    self.zone:SetText(MiniMap.StripMapNameFormatting(zoneName))
end

function LUIE_MiniMap_Frame:ApplyZoneNameFont()
    local settings = MiniMap.SV
    local defaults = MiniMap.Defaults
    local faceKey = settings.zoneNameFontFace or defaults.zoneNameFontFace
    local fontSize = (settings.zoneNameFontSize and settings.zoneNameFontSize > 0) and settings.zoneNameFontSize or defaults.zoneNameFontSize
    local fontStyle = settings.zoneNameFontStyle or defaults.zoneNameFontStyle
    self.zone:SetFont(LUIE.Font.Resolve(faceKey, fontSize, fontStyle))
end

-- Settings-driven layout -----------------------------------------------------

function LUIE_MiniMap_Frame:ApplyDrawLayerPreference()
    if MiniMap.SV.preferElevatedDrawTier == true then
        self.root:SetDrawLayer(DL_OVERLAY)
        self.root:SetDrawTier(DT_HIGH)
    else
        self.root:SetDrawLayer(DL_CONTROLS)
        self.root:SetDrawTier(DT_MEDIUM)
    end
end

function LUIE_MiniMap_Frame:ApplyAppearanceFromSettings()
    self:ApplyDrawLayerPreference()
    self.background:SetAlpha(MiniMap.SV.borderOpacity)
end

function LUIE_MiniMap_Frame:ApplyResizedDimensions()
    local width = self.root:GetWidth()
    local height = self.root:GetHeight()
    MiniMap.SV.width = zo_max(width, MINIMAP_MIN_FRAME_SIZE)
    MiniMap.SV.height = zo_max(height, MINIMAP_MIN_FRAME_SIZE)
    self.root:SetDimensions(MiniMap.SV.width, MiniMap.SV.height)
    self:ApplyRootLayout(MiniMap.SV)
end

function LUIE_MiniMap_Frame:ApplyLayoutFromSavedSettings()
    local settings = MiniMap.SV
    settings.width = zo_max(settings.width or MiniMap.Defaults.width, MINIMAP_MIN_FRAME_SIZE)
    settings.height = zo_max(settings.height or MiniMap.Defaults.height, MINIMAP_MIN_FRAME_SIZE)
    self:ApplySavedLayout(settings)
    self:ApplyRootLayout(settings)
    self.manager:RefreshFrameAttachments()
    self.manager.panAndZoom:ClampZoomToLimits(false)
end

-- Root XML handlers ----------------------------------------------------------

--- @param control TopLevelWindow
function LUIE_MiniMap_Frame:OnRootMoveStop(control)
    if self.offsetSaveSuppressed then
        return
    end
    MiniMap.SV.offsetX = control:GetRight() - GuiRoot:GetRight()
    MiniMap.SV.offsetY = control:GetBottom() - GuiRoot:GetBottom()
    self.manager:RefreshFrameAttachments()
end

--- @param control TopLevelWindow
function LUIE_MiniMap_Frame:OnRootResizeStart(control)
    if MiniMap.SV.lockSize then
        return
    end
    self.resizing = true
end

--- @param control TopLevelWindow
function LUIE_MiniMap_Frame:OnRootResizeStop(control)
    self.resizing = false
    self:OnRootMoveStop(control)
end

function LUIE_MiniMap_Frame:OnRootRectChanged()
    if not self.resizing then
        return
    end
    self:ApplyResizedDimensions()
    self.manager:RefreshFrameAttachments()
    self.manager.panAndZoom:ClampZoomToLimits(false)
end
