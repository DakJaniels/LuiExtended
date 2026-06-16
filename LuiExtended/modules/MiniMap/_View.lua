-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local DEFAULT_RESIZE_HANDLE_SIZE = 8

--- @class MiniMapView : ZO_InitializingObject
--- @field root TopLevelWindow
--- @field background BackdropControl
--- @field scroll ScrollControl
--- @field map Control
--- @field pins Control
--- @field zone LabelControl
--- @field zoomLabel LabelControl
--- @field player TextureControl
--- @field playerCam TextureControl
--- @field statusOverlay StatusBarControl
--- @field statusLabel LabelControl
--- @field zoomIn ButtonControl|nil
--- @field zoomOut ButtonControl|nil
--- @field clockLabel LabelControl|nil
local MiniMapView = ZO_InitializingObject:Subclass()
MiniMap.MiniMapView = MiniMapView

--- @param rootControl TopLevelWindow
function MiniMapView:Initialize(rootControl)
    self.root = rootControl
    self.background = rootControl:GetNamedChild("_Background")
    self.scroll = rootControl:GetNamedChild("_Scroll")
    self.zone = rootControl:GetNamedChild("_Zone")
    self.zoomLabel = rootControl:GetNamedChild("_ZoomLabel")
    self.player = rootControl:GetNamedChild("_Player")
    self.playerCam = rootControl:GetNamedChild("_PlayerCam")
    self.zoomIn = rootControl:GetNamedChild("_ZoomIn")
    self.zoomOut = rootControl:GetNamedChild("_ZoomOut")
    self.map = self.scroll:GetNamedChild("_Map")
    self.pins = self.map:GetNamedChild("_Pins")
    self.statusOverlay = self.scroll:GetNamedChild("_StatusOverlay")
    self.statusLabel = self.statusOverlay:GetNamedChild("_Label")
    self.clockLabel = rootControl:GetNamedChild("_ClockLabel")
end

--- @param settings MiniMapDefaults
function MiniMapView:ApplySavedLayout(settings)
    local root = self.root
    root:ClearAnchors()
    root:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, settings.offsetX, settings.offsetY)
    root:SetDimensions(settings.width, settings.height)
    self.background:SetDimensions(settings.width + 8, settings.height + 8)
    self.scroll:SetDimensions(settings.width, settings.height)
    self:ApplyInteractionLocks(settings)
    self:ApplyChromeVisibility(settings)
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
    if MiniMap.inputController then
        MiniMap.inputController:ApplyFrameDragMouseEnabled()
    end
end

--- @param rootControl Control
--- @param childSuffix string
--- @param globalControl Control|nil
--- @return Control|nil
function MiniMapView:GetChromeControl(rootControl, childSuffix, globalControl)
    local child = rootControl:GetNamedChild(childSuffix)
    if child then
        return child
    end
    return globalControl
end

function MiniMapView:ResolveChromeControls()
    local root = self.root
    self.zoomIn = self:GetChromeControl(root, "_ZoomIn", LUIE_MiniMap_ZoomIn)
    self.zoomOut = self:GetChromeControl(root, "_ZoomOut", LUIE_MiniMap_ZoomOut)
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

--- @param settings MiniMapDefaults
function MiniMapView:ApplyChromeVisibility(settings)
    self:ResolveChromeControls()
    local showZoom = self:GetSettingsBoolean(settings, "showZoomButtons", MiniMap.Defaults.showZoomButtons)
    if self.zoomIn then
        self.zoomIn:SetHidden(not showZoom)
        self.zoomIn:SetMouseEnabled(showZoom)
    end
    if self.zoomOut then
        self.zoomOut:SetHidden(not showZoom)
        self.zoomOut:SetMouseEnabled(showZoom)
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

--- @param zoom number
function MiniMapView:SetZoomLabel(zoom)
    self.zoomLabel:SetText(string.format("%.0f%%", zoom * 100))
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
    self.background:SetDimensions(MiniMap.SV.width + 8, MiniMap.SV.height + 8)
    self.scroll:SetDimensions(MiniMap.SV.width, MiniMap.SV.height)
end

function MiniMapView:ApplyPlayerIconDimensions()
    local drawSize = MiniMap.GetPlayerPinDrawSize()
    local wedgeRatio = MiniMap.PLAYER_CAMERA_PIP_SIZE_RATIO
    if MiniMap.SV and MiniMap.SV.cameraWedgeScale then
        wedgeRatio = wedgeRatio * MiniMap.SV.cameraWedgeScale
    end
    local cameraSize = zo_round(drawSize * wedgeRatio)
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
    self.playerCam:SetBlendMode(TEX_BLEND_MODE_ADD)
    local _, _, _, alpha = self.playerCam:GetColor()
    self.playerCam:SetColor(1, 1, 1, alpha)
    self:ApplyPlayerIconDimensions()
end

-- Handlers called from MiniMap.xml

function MiniMap.OnRootMoveStop(control)
    if not MiniMap.SV then
        return
    end
    MiniMap.SV.offsetX = control:GetRight() - GuiRoot:GetRight()
    MiniMap.SV.offsetY = control:GetBottom() - GuiRoot:GetBottom()
    if MiniMap.SV.positionGridDivisor and MiniMap.SV.positionGridDivisor > 1 then
        MiniMap.ApplyPositionGridSnap(MiniMap.SV)
    end
end

function MiniMap.OnRootResizeStart(control)
    if not MiniMap.SV or MiniMap.SV.lockSize then
        return
    end
    MiniMap.resize = true
end

function MiniMap.OnRootResizeStop(control)
    MiniMap.resize = false
    if MiniMap.SV and MiniMap.SV.keepSquareAspect == true then
        MiniMap.ApplySquareAspect()
    end
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
    MiniMap.view:OnResizePersist()
    local mapController = MiniMap.mapController
    if mapController and mapController:IsReady() then
        mapController:ClampZoomToLimits()
    end
end
