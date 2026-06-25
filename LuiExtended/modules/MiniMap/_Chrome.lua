-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

-- -----------------------------------------------------------------------------
-- MiniMap chrome overlay.
--
-- The minimap reuses the real ZO_WorldMap, so the LUIE frame chrome (backdrop,
-- zone label, zoom percent label, hover-reveal mover, styled zoom buttons) is
-- instantiated from the LUIE_MiniMapChrome virtual template (frontend/MiniMap.xml)
-- as a child of ZO_WorldMap and positioned relative to ZO_WorldMap /
-- ZO_WorldMapScroll. This file owns chrome creation, placement, hover/fade
-- behaviour, and the XML handler forwarders.
-- -----------------------------------------------------------------------------

local ZOOM_LABEL_MAX_ALPHA = 0.4
local ZOOM_CHROME_HOLD_MS = 1250
local ZOOM_CHROME_FADE_OUT_MS = 200
local ZOOM_BUTTON_MAX_ALPHA = 1
local FRAME_CHROME_HIDE_DELAY_MS = 200

--- @return Control|nil
local function GetChromeHost()
    return ZO_WorldMap
end

--- The rectangular map viewport the chrome frames; resized by ZOS on every map resize.
--- @return Control|nil
local function GetMapViewport()
    return ZO_WorldMapScroll
end

--- @return table|nil
local function GetChrome()
    return MiniMap.chrome
end

-- -----------------------------------------------------------------------------
-- Creation
-- -----------------------------------------------------------------------------

--- Build the chrome overlay as a child of ZO_WorldMap and resolve its controls.
function MiniMap.CreateChrome()
    if MiniMap.chrome then
        return
    end
    local host = GetChromeHost()
    if not host then
        return
    end

    local chromeControl = CreateControlFromVirtual(host:GetName() .. "LUIEChrome", host, "LUIE_MiniMapChrome")
    local zoneLabel = chromeControl:GetNamedChild("_Zone")
    local frameChromeHover = chromeControl:GetNamedChild("_FrameChromeHover")
    local frameChrome = frameChromeHover:GetNamedChild("_FrameChrome")

    local chrome =
    {
        control = chromeControl,
        background = chromeControl:GetNamedChild("_Background"),
        zone = zoneLabel,
        zoneDivider = zoneLabel:GetNamedChild("_Divider"),
        zoomLabel = chromeControl:GetNamedChild("_ZoomLabel"),
        frameChromeHover = frameChromeHover,
        frameChrome = frameChrome,
        framePositionLock = frameChrome:GetNamedChild("_PositionLock"),
        frameMoveGrip = frameChrome:GetNamedChild("_MoveGrip"),
        zoomChromeHover = chromeControl:GetNamedChild("_ZoomChromeHover"),
        zoomIn = chromeControl:GetNamedChild("_ZoomIn"),
        zoomOut = chromeControl:GetNamedChild("_ZoomOut"),
        attachSide = "left",
        zoomLabelHideLaterId = nil,
        zoomLabelFadeActive = nil,
        zoomButtonsHideLaterId = nil,
        zoomButtonsFadeActive = nil,
        frameChromeHideCallId = nil,
        zoomChromeExitCallId = nil,
    }
    MiniMap.chrome = chrome

    chromeControl:ClearAnchors()
    chromeControl:SetAnchorFill(host)
    -- Stay hidden until EnterMiniMapMode shows it, so the chrome never flashes
    -- over the full world map before the minimap mode is active.
    chromeControl:SetHidden(true)
    chrome.zone:SetMouseEnabled(false)
    chrome.zoomLabel:SetHidden(true)
    chrome.zoomLabel:SetAlpha(ZOOM_LABEL_MAX_ALPHA)

    MiniMap.SetZoomButtonsIdleChromeState()
    MiniMap.ApplyChromePlacement()
end

-- -----------------------------------------------------------------------------
-- Placement
-- -----------------------------------------------------------------------------

--- Choose the side the hover mover attaches to so it never runs off-screen.
--- @return "left"|"right"
function MiniMap.GetFrameChromeAttachSide()
    local viewport = GetMapViewport()
    if not viewport then
        return "left"
    end
    local hotspotWidth = MiniMap.FRAME_CHROME_HOVER_SIZE
    local chromeWidth = MiniMap.FRAME_CHROME_BAR_WIDTH
    local margin = MiniMap.FRAME_CHROME_LEFT_EDGE_MARGIN
    local outsideX = MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_X
    local neededLeft = hotspotWidth + chromeWidth + outsideX + margin
    if viewport:GetLeft() - neededLeft < GuiRoot:GetLeft() then
        return "right"
    end
    return "left"
end

--- @param side "left"|"right"
function MiniMap.ApplyFrameChromeControlOrder(side)
    local chrome = GetChrome()
    if not chrome then
        return
    end
    local lockButton = chrome.framePositionLock
    local moveGrip = chrome.frameMoveGrip
    local frameChrome = chrome.frameChrome
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

function MiniMap.ApplyFrameChromePlacement()
    local chrome = GetChrome()
    local viewport = GetMapViewport()
    if not chrome or not viewport then
        return
    end
    local hoverSize = MiniMap.FRAME_CHROME_HOVER_SIZE
    local outsideX = MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_X
    local outsideY = MiniMap.FRAME_CHROME_OUTSIDE_OFFSET_Y
    local side = MiniMap.GetFrameChromeAttachSide()
    chrome.attachSide = side

    chrome.frameChromeHover:ClearAnchors()
    chrome.frameChromeHover:SetDimensions(hoverSize, hoverSize)
    if side == "left" then
        chrome.frameChromeHover:SetAnchor(TOPRIGHT, viewport, BOTTOMLEFT, -outsideX, outsideY)
    else
        chrome.frameChromeHover:SetAnchor(TOPLEFT, viewport, BOTTOMRIGHT, outsideX, outsideY)
    end

    chrome.frameChrome:ClearAnchors()
    if side == "left" then
        chrome.frameChrome:SetAnchor(TOPRIGHT, chrome.frameChromeHover, BOTTOMRIGHT, 0, 0)
    else
        chrome.frameChrome:SetAnchor(TOPLEFT, chrome.frameChromeHover, BOTTOMLEFT, 0, 0)
    end
    MiniMap.ApplyFrameChromeControlOrder(side)
end

function MiniMap.ApplyZoneLabelPlacement()
    local chrome = GetChrome()
    local viewport = GetMapViewport()
    if not chrome or not viewport then
        return
    end
    local zoneOffset = MiniMap.ZONE_LABEL_CHROME_OFFSET
    local zoneLabel = chrome.zone
    local zoneDivider = chrome.zoneDivider
    local infoPanelFillsZoneSlot = MiniMap.IsInfoPanelAnchorActive()

    -- Anchor to the map viewport (ZO_WorldMapScroll), not the ZO_WorldMap frame:
    -- the frame still reserves layout space for the hidden title bar / buttons.
    zoneLabel:ClearAnchors()
    if infoPanelFillsZoneSlot then
        zoneLabel:SetAnchor(BOTTOM, viewport, TOP, 0, -zoneOffset)
    else
        zoneLabel:SetAnchor(TOP, viewport, BOTTOM, 0, zoneOffset + 4)
    end

    zoneDivider:ClearAnchors()
    zoneDivider:SetAnchor(BOTTOMLEFT, zoneLabel, BOTTOMLEFT, -80, zoneOffset)
    zoneDivider:SetAnchor(BOTTOMRIGHT, zoneLabel, BOTTOMRIGHT, 80, zoneOffset)
end

--- Frame the map viewport with the backdrop and position the zoom percent label
--- and zoom buttons, then re-run the hover mover + zone placement.
function MiniMap.ApplyChromePlacement()
    local chrome = GetChrome()
    local viewport = GetMapViewport()
    if not chrome or not viewport then
        return
    end

    chrome.background:ClearAnchors()
    chrome.background:SetAnchor(TOPLEFT, viewport, TOPLEFT, -3, -3)
    chrome.background:SetAnchor(BOTTOMRIGHT, viewport, BOTTOMRIGHT, 3, 3)

    chrome.zoomLabel:ClearAnchors()
    chrome.zoomLabel:SetAnchor(TOPRIGHT, viewport, TOPRIGHT, -4, 4)

    chrome.zoomIn:ClearAnchors()
    chrome.zoomIn:SetAnchor(BOTTOMRIGHT, viewport, BOTTOMRIGHT, -4, -4)
    chrome.zoomOut:ClearAnchors()
    chrome.zoomOut:SetAnchor(BOTTOMRIGHT, chrome.zoomIn, BOTTOMLEFT, -2, 0)
    chrome.zoomChromeHover:ClearAnchors()
    chrome.zoomChromeHover:SetAnchor(BOTTOMRIGHT, viewport, BOTTOMRIGHT, -54, 0)

    MiniMap.ApplyZoneLabelPlacement()
    MiniMap.ApplyFrameChromePlacement()
end

-- -----------------------------------------------------------------------------
-- Zone label
-- -----------------------------------------------------------------------------

--- @param zoneName string
function MiniMap.SetZoneText(zoneName)
    local chrome = GetChrome()
    if not chrome then
        return
    end
    chrome.zone:SetText(MiniMap.StripMapNameFormatting(zoneName or ""))
end

-- -----------------------------------------------------------------------------
-- Zoom percent label (transient reveal + fade)
-- -----------------------------------------------------------------------------

local function ClearZoomLabelFadeUpdate()
    local chrome = GetChrome()
    if chrome and chrome.zoomLabelFadeActive then
        chrome.zoomLabel:SetHandler("OnUpdate", nil)
        chrome.zoomLabelFadeActive = nil
    end
end

local function CancelZoomLabelTransient()
    local chrome = GetChrome()
    if chrome and chrome.zoomLabelHideLaterId then
        zo_removeCallLater(chrome.zoomLabelHideLaterId)
        chrome.zoomLabelHideLaterId = nil
    end
    ClearZoomLabelFadeUpdate()
end

local function StartZoomLabelFadeOut()
    local chrome = GetChrome()
    if not chrome or chrome.zoomLabel:IsHidden() then
        return
    end
    ClearZoomLabelFadeUpdate()
    local fadeStartMs = GetFrameTimeMilliseconds()
    chrome.zoomLabelFadeActive = true
    chrome.zoomLabel:SetHandler("OnUpdate", function (control)
        local progress = zo_clamp((GetFrameTimeMilliseconds() - fadeStartMs) / ZOOM_CHROME_FADE_OUT_MS, 0, 1)
        control:SetAlpha(ZOOM_LABEL_MAX_ALPHA * (1 - progress))
        if progress >= 1 then
            ClearZoomLabelFadeUpdate()
            control:SetHidden(true)
            control:SetAlpha(ZOOM_LABEL_MAX_ALPHA)
        end
    end)
end

--- @param zoom number Context scale shown as a percent.
--- @param revealTransient boolean|nil
function MiniMap.SetZoomLabel(zoom, revealTransient)
    local chrome = GetChrome()
    if not chrome then
        return
    end
    chrome.zoomLabel:SetText(string.format("%.0f%%", zoom * 100))
    if not revealTransient then
        return
    end
    CancelZoomLabelTransient()
    chrome.zoomLabel:SetHidden(false)
    chrome.zoomLabel:SetAlpha(ZOOM_LABEL_MAX_ALPHA)
    chrome.zoomLabelHideLaterId = zo_callLater(function ()
        chrome.zoomLabelHideLaterId = nil
        StartZoomLabelFadeOut()
    end, ZOOM_CHROME_HOLD_MS)
end

-- -----------------------------------------------------------------------------
-- Zoom buttons (hover reveal + idle fade)
-- -----------------------------------------------------------------------------

--- @return boolean
local function AreZoomButtonsEnabled()
    return MiniMap.SV.showZoomButtons == true
end

function MiniMap.SetZoomButtonsIdleChromeState()
    local chrome = GetChrome()
    if not chrome then
        return
    end
    chrome.zoomIn:SetHidden(true)
    chrome.zoomIn:SetAlpha(ZOOM_BUTTON_MAX_ALPHA)
    chrome.zoomIn:SetMouseEnabled(false)
    chrome.zoomOut:SetHidden(true)
    chrome.zoomOut:SetAlpha(ZOOM_BUTTON_MAX_ALPHA)
    chrome.zoomOut:SetMouseEnabled(false)
    if AreZoomButtonsEnabled() then
        chrome.zoomChromeHover:SetMouseEnabled(true)
    end
end

local function ClearZoomButtonsFadeUpdate()
    local chrome = GetChrome()
    if chrome and chrome.zoomButtonsFadeActive then
        chrome.zoomIn:SetHandler("OnUpdate", nil)
        chrome.zoomButtonsFadeActive = nil
    end
end

local function CancelZoomButtonsTransient()
    local chrome = GetChrome()
    if chrome and chrome.zoomButtonsHideLaterId then
        zo_removeCallLater(chrome.zoomButtonsHideLaterId)
        chrome.zoomButtonsHideLaterId = nil
    end
    ClearZoomButtonsFadeUpdate()
end

local function RevealZoomButtonsTransient()
    local chrome = GetChrome()
    if not chrome or not AreZoomButtonsEnabled() then
        return
    end
    CancelZoomButtonsTransient()
    chrome.zoomChromeHover:SetMouseEnabled(false)
    chrome.zoomIn:SetHidden(false)
    chrome.zoomIn:SetAlpha(ZOOM_BUTTON_MAX_ALPHA)
    chrome.zoomIn:SetMouseEnabled(true)
    chrome.zoomOut:SetHidden(false)
    chrome.zoomOut:SetAlpha(ZOOM_BUTTON_MAX_ALPHA)
    chrome.zoomOut:SetMouseEnabled(true)
end

local function StartZoomButtonsFadeOut()
    local chrome = GetChrome()
    if not chrome or chrome.zoomIn:IsHidden() then
        return
    end
    ClearZoomButtonsFadeUpdate()
    local fadeStartMs = GetFrameTimeMilliseconds()
    chrome.zoomButtonsFadeActive = true
    chrome.zoomIn:SetHandler("OnUpdate", function ()
        local progress = zo_clamp((GetFrameTimeMilliseconds() - fadeStartMs) / ZOOM_CHROME_FADE_OUT_MS, 0, 1)
        local alpha = ZOOM_BUTTON_MAX_ALPHA * (1 - progress)
        chrome.zoomIn:SetAlpha(alpha)
        if not chrome.zoomOut:IsHidden() then
            chrome.zoomOut:SetAlpha(alpha)
        end
        if progress >= 1 then
            ClearZoomButtonsFadeUpdate()
            MiniMap.SetZoomButtonsIdleChromeState()
        end
    end)
end

local function ScheduleZoomButtonsFadeAfterIdle()
    local chrome = GetChrome()
    if not chrome or not AreZoomButtonsEnabled() then
        return
    end
    CancelZoomButtonsTransient()
    chrome.zoomButtonsHideLaterId = zo_callLater(function ()
        chrome.zoomButtonsHideLaterId = nil
        StartZoomButtonsFadeOut()
    end, ZOOM_CHROME_HOLD_MS)
end

--- @return boolean
local function IsMouseOverZoomChromeRegion()
    local chrome = GetChrome()
    if not chrome then
        return false
    end
    if not chrome.zoomChromeHover:IsHidden() and MouseIsOver(chrome.zoomChromeHover) then
        return true
    end
    if not chrome.zoomIn:IsHidden() and MouseIsOver(chrome.zoomIn) then
        return true
    end
    if not chrome.zoomOut:IsHidden() and MouseIsOver(chrome.zoomOut) then
        return true
    end
    return false
end

local function CancelZoomChromeExitDebounce()
    local chrome = GetChrome()
    if chrome and chrome.zoomChromeExitCallId then
        zo_removeCallLater(chrome.zoomChromeExitCallId)
        chrome.zoomChromeExitCallId = nil
    end
end

-- -----------------------------------------------------------------------------
-- Frame chrome (hover-reveal mover: padlock + move grip)
-- -----------------------------------------------------------------------------

--- @return boolean
local function IsFrameChromePinnedOpen()
    return MiniMap.SV.lockPosition ~= true
end

--- @return boolean
local function IsMouseOverFrameChromeRegion()
    local chrome = GetChrome()
    if not chrome then
        return false
    end
    if MouseIsOver(chrome.frameChromeHover) then
        return true
    end
    if MouseIsOver(chrome.frameChrome) then
        return true
    end
    if MouseIsOver(chrome.framePositionLock) then
        return true
    end
    if not chrome.frameMoveGrip:IsHidden() and MouseIsOver(chrome.frameMoveGrip) then
        return true
    end
    return false
end

local function ShowFrameChrome()
    local chrome = GetChrome()
    if chrome then
        chrome.frameChrome:SetHidden(false)
    end
end

local function HideFrameChromeIfPointerLeft()
    local chrome = GetChrome()
    if not chrome or IsFrameChromePinnedOpen() or IsMouseOverFrameChromeRegion() then
        return
    end
    chrome.frameChrome:SetHidden(true)
end

local function CancelFrameChromeHide()
    local chrome = GetChrome()
    if chrome and chrome.frameChromeHideCallId then
        zo_removeCallLater(chrome.frameChromeHideCallId)
        chrome.frameChromeHideCallId = nil
    end
end

--- Reconcile frame chrome visibility with the pinned-open (unlocked) state.
function MiniMap.RefreshFrameChromeVisibility()
    if IsFrameChromePinnedOpen() or IsMouseOverFrameChromeRegion() then
        ShowFrameChrome()
    else
        HideFrameChromeIfPointerLeft()
    end
end

--- Apply padlock toggle state + move grip availability from the lock setting.
function MiniMap.ApplyFrameChromeLockState()
    local chrome = GetChrome()
    if not chrome then
        return
    end
    local positionLocked = MiniMap.SV.lockPosition == true
    ZO_ToggleButton_SetState(chrome.framePositionLock, positionLocked and TOGGLE_BUTTON_CLOSED or TOGGLE_BUTTON_OPEN)
    chrome.frameMoveGrip:SetHidden(positionLocked)
    chrome.frameMoveGrip:SetMouseEnabled(not positionLocked)
    MiniMap.RefreshFrameChromeVisibility()
end

-- -----------------------------------------------------------------------------
-- Visibility / settings application
-- -----------------------------------------------------------------------------

--- Apply zone-name show state + font.
function MiniMap.ApplyChromeZoneSettings()
    local chrome = GetChrome()
    if not chrome then
        return
    end
    local settings = MiniMap.SV
    local defaults = MiniMap.Defaults
    local showZoneName = settings.showZoneName ~= false
    chrome.zone:SetHidden(not showZoneName)
    chrome.zoneDivider:SetHidden(not showZoneName)

    local faceKey = settings.zoneNameFontFace or defaults.zoneNameFontFace
    local fontName = LUIE.Fonts[faceKey]
    if not fontName or fontName == "" then
        fontName = LUIE.Fonts[defaults.zoneNameFontFace] or defaults.zoneNameFontFace
    end
    local fontSize = (settings.zoneNameFontSize and settings.zoneNameFontSize > 0) and settings.zoneNameFontSize or defaults.zoneNameFontSize
    local fontStyle = settings.zoneNameFontStyle or defaults.zoneNameFontStyle
    chrome.zone:SetFont(LUIE.CreateFontString(fontName, fontSize, fontStyle))
end

--- Apply zoom-button feature visibility (idle state when enabled, fully off when disabled).
function MiniMap.ApplyChromeZoomButtonSettings()
    local chrome = GetChrome()
    if not chrome then
        return
    end
    local showZoom = AreZoomButtonsEnabled()
    CancelZoomButtonsTransient()
    chrome.zoomChromeHover:SetHidden(not showZoom)
    chrome.zoomChromeHover:SetMouseEnabled(showZoom)
    MiniMap.SetZoomButtonsIdleChromeState()
end

--- @param hidden boolean
function MiniMap.SetChromeHidden(hidden)
    local chrome = GetChrome()
    if not chrome then
        return
    end
    chrome.control:SetHidden(hidden)
end

-- -----------------------------------------------------------------------------
-- XML handlers
-- -----------------------------------------------------------------------------

function MiniMap.OnFrameChromeHotspotMouseEnter(control)
    CancelFrameChromeHide()
    ShowFrameChrome()
end

function MiniMap.OnFrameChromeHotspotMouseExit(control)
    CancelFrameChromeHide()
    if IsFrameChromePinnedOpen() then
        return
    end
    local chrome = GetChrome()
    if not chrome then
        return
    end
    chrome.frameChromeHideCallId = zo_callLater(function ()
        chrome.frameChromeHideCallId = nil
        HideFrameChromeIfPointerLeft()
    end, FRAME_CHROME_HIDE_DELAY_MS)
end

function MiniMap.OnFrameChromeMouseEnter(control)
    MiniMap.OnFrameChromeHotspotMouseEnter(control)
end

function MiniMap.OnFrameChromeMouseExit(control)
    MiniMap.OnFrameChromeHotspotMouseExit(control)
end

function MiniMap.OnFramePositionLockInitialized(lockButton)
    local initialState = (MiniMap.SV and MiniMap.SV.lockPosition) and TOGGLE_BUTTON_CLOSED or TOGGLE_BUTTON_OPEN
    ZO_ToggleButton_Initialize(lockButton, TOGGLE_BUTTON_TYPE_PADLOCK, initialState)
    ZO_MouseTooltipBehavior_OnInitialized(lockButton)
    lockButton:SetTooltipString(GetString(LUIE_STRING_MINIMAP_FRAME_LOCK_TP))
end

function MiniMap.OnFramePositionLockClicked(control, button, ctrl, alt, shift, command)
    CancelFrameChromeHide()
    MiniMap.SV.lockPosition = not MiniMap.SV.lockPosition
    MiniMap.ApplyLiveSettings()
end

function MiniMap.OnFrameMoveGripInitialized(moveGrip)
    ZO_MouseTooltipBehavior_OnInitialized(moveGrip)
    moveGrip:SetTooltipString(GetString(LUIE_STRING_MINIMAP_FRAME_MOVE_TP))
end

function MiniMap.OnFrameMoveGripMouseDown(control, button, ctrl, alt, shift, command)
    if button ~= MOUSE_BUTTON_INDEX_LEFT or MiniMap.SV.lockPosition then
        return
    end
    local host = GetChromeHost()
    if host then
        host:StartMoving()
    end
end

function MiniMap.OnFrameMoveGripMouseUp(control, button, upInside, ctrl, alt, shift, command)
    if button ~= MOUSE_BUTTON_INDEX_LEFT then
        return
    end
    local host = GetChromeHost()
    if host then
        host:StopMovingOrResizing()
        MiniMap.SaveMapPosition()
        MiniMap.ApplyChromePlacement()
    end
end

function MiniMap.OnZoomChromeHoverMouseEnter(control)
    local chrome = GetChrome()
    if not chrome or not AreZoomButtonsEnabled() then
        return
    end
    CancelZoomChromeExitDebounce()
    RevealZoomButtonsTransient()
end

function MiniMap.OnZoomChromeHoverMouseExit(control)
    local chrome = GetChrome()
    if not chrome or not AreZoomButtonsEnabled() then
        return
    end
    CancelZoomChromeExitDebounce()
    chrome.zoomChromeExitCallId = zo_callLater(function ()
        chrome.zoomChromeExitCallId = nil
        if IsMouseOverZoomChromeRegion() then
            return
        end
        ScheduleZoomButtonsFadeAfterIdle()
    end, FRAME_CHROME_HIDE_DELAY_MS)
end

function MiniMap.OnZoomInClicked(control, button, ctrl, alt, shift, command)
    if MiniMap.Enabled then
        MiniMap.Zoom(1)
    end
end

function MiniMap.OnZoomOutClicked(control, button, ctrl, alt, shift, command)
    if MiniMap.Enabled then
        MiniMap.Zoom(-1)
    end
end
