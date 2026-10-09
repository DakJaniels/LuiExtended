-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local INFO_PANEL_DEFAULT_OFFSET_X = -24
local INFO_PANEL_DEFAULT_OFFSET_Y = 20

-- InfoPanel ------------------------------------------------------------------

--- @return boolean
function MiniMap.IsInfoPanelAnchorActive()
    if not MiniMap.Enabled or MiniMap.SV.anchorInfoPanelToMiniMap ~= true then
        return false
    end
    local infoPanel = LUIE.InfoPanel
    return infoPanel ~= nil and infoPanel.Enabled == true and LUIE_InfoPanel ~= nil
end

--- @param infoPanelControl Control
local function ApplyInfoPanelDefaultXmlAnchor(infoPanelControl)
    infoPanelControl:ClearAnchors()
    infoPanelControl:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, INFO_PANEL_DEFAULT_OFFSET_X, INFO_PANEL_DEFAULT_OFFSET_Y)
end

--- Optional InfoPanel stack (below the map, in the zone-label slot) and the HarvestMap minimap mode.
--- @class LUIE_MiniMap_Integrations : ZO_InitializingObject
--- @field manager LUIE_MiniMap_Manager
--- @field harvestMap table|nil The `Harvest` global when HarvestMap is enabled.
--- @field harvestMapMode table|nil LUIE mode table handed to HarvestMap's PinController:SetMode.
--- @field harvestMapOriginalCheckMapMode fun(controller: table)|nil
--- @field harvestMapOriginalIsInMinimapMode fun(mapMode: table): boolean|nil
--- @field harvestMapActive boolean
LUIE_MiniMap_Integrations = ZO_InitializingObject:Subclass()

--- @param manager LUIE_MiniMap_Manager
function LUIE_MiniMap_Integrations:Initialize(manager)
    self.manager = manager
    self.harvestMap = nil
    self.harvestMapMode = nil
    self.harvestMapActive = false
    if LUIE.OtherAddonCompatability.isHarvestMapEnabled and Harvest and Harvest.pinController and Harvest.mapMode and Harvest.mapPins then
        self.harvestMap = Harvest
    end
end

--- Saved copy of the InfoPanel's own anchor before the minimap takes it over (restored on disable).
function LUIE_MiniMap_Integrations:SaveInfoPanelAnchor()
    local infoPanel = LUIE.InfoPanel
    if not infoPanel or infoPanel.Enabled ~= true or LUIE_InfoPanel == nil then
        return
    end
    local isValidAnchor, point, _, relativePoint, offsetX, offsetY = LUIE_InfoPanel:GetAnchor(0)
    if not isValidAnchor then
        return
    end
    MiniMap.SV.infoPanelRestoreAnchor =
    {
        point = point,
        relativePoint = relativePoint,
        offsetX = offsetX,
        offsetY = offsetY,
    }
end

function LUIE_MiniMap_Integrations:RestoreInfoPanelAnchor()
    local infoPanel = LUIE.InfoPanel
    if not infoPanel or infoPanel.Enabled ~= true or LUIE_InfoPanel == nil then
        return
    end
    local infoPanelControl = LUIE_InfoPanel
    local savedAnchor = MiniMap.SV.infoPanelRestoreAnchor
    if savedAnchor and savedAnchor.point ~= nil and savedAnchor.relativePoint ~= nil then
        infoPanelControl:ClearAnchors()
        infoPanelControl:SetAnchor(savedAnchor.point, GuiRoot, savedAnchor.relativePoint, savedAnchor.offsetX or 0, savedAnchor.offsetY or 0)
        MiniMap.SV.infoPanelRestoreAnchor = nil
        return
    end
    if infoPanel.ApplyPanelPosition then
        infoPanel.ApplyPanelPosition()
        if infoPanel.SV and infoPanel.SV.position ~= nil and #infoPanel.SV.position == 2 then
            return
        end
    end
    ApplyInfoPanelDefaultXmlAnchor(infoPanelControl)
end

function LUIE_MiniMap_Integrations:ApplyInfoPanelAnchor()
    if not MiniMap.IsInfoPanelAnchorActive() then
        return
    end
    local infoPanelControl = LUIE_InfoPanel
    infoPanelControl:ClearAnchors()
    infoPanelControl:SetAnchor(TOP, self.manager.frame.root, BOTTOM, 0, MiniMap.ZONE_LABEL_OFFSET)
end

--- Zone label, drag bar and (optionally) the InfoPanel re-stack after any root layout change.
function LUIE_MiniMap_Integrations:RefreshFrameAttachments()
    local frame = self.manager.frame
    frame:ApplyZoneLabelPlacement()
    frame:ApplyDragBarPlacement()
    if MiniMap.IsInfoPanelAnchorActive() then
        self:ApplyInfoPanelAnchor()
    end
end

-- HarvestMap -----------------------------------------------------------------
-- HarvestMap/Modules/HarvestMap/Pins/MapPinController.lua: PinController:SetMode(mode) (207) calls mode:Activate();
-- CheckMapMode() (217) picks MAIN/NO/FYR/AUI/VOTAN modes; OnMapSizeChange(width, height) (234) sets MAP_WIDTH/HEIGHT,
-- re-checks the mode and relays out every pin. Mode tables (433-458) expose Activate(self) / GetDimensions(self).
-- MapMode.lua:53 IsInMinimapMode() only knows Fyr/AUI/Votan, and MapPins.lua:157 RedrawPins requires
-- Harvest.AreMinimapPinsVisible() and Harvest.mapMode:IsInMinimapMode() while the world map is hidden.
-- ZO_PostHook keeps the original return values, so both overrides are manual wrappers.

--- @return boolean
function LUIE_MiniMap_Integrations:IsHarvestMapMinimapModeActive()
    return self.harvestMapActive and not ZO_WorldMap_IsWorldMapShowing()
end

function LUIE_MiniMap_Integrations:SetupHarvestMapMode()
    local harvestMap = self.harvestMap
    if not harvestMap or self.harvestMapMode then
        return
    end
    local pinController = harvestMap.pinController
    local pinsLayer = self.manager.frame.pinsLayer
    local panAndZoom = self.manager.panAndZoom

    self.harvestMapMode =
    {
        Activate = function (mode)
            local container = pinController.container
            container:ClearAnchors()
            container:SetAnchor(TOPLEFT, pinsLayer, TOPLEFT, 0, 0)
            container:SetParent(pinsLayer)
        end,
        GetDimensions = function (mode)
            return panAndZoom:GetContentWidth(), panAndZoom:GetContentHeight()
        end,
    }

    self.harvestMapOriginalCheckMapMode = pinController.CheckMapMode
    local originalCheckMapMode = self.harvestMapOriginalCheckMapMode
    pinController.CheckMapMode = function (controller)
        if self:IsHarvestMapMinimapModeActive() then
            controller:SetMode(self.harvestMapMode)
            return
        end
        originalCheckMapMode(controller)
    end

    local mapMode = harvestMap.mapMode
    self.harvestMapOriginalIsInMinimapMode = mapMode.IsInMinimapMode
    local originalIsInMinimapMode = self.harvestMapOriginalIsInMinimapMode
    mapMode.IsInMinimapMode = function (modeObject)
        if self:IsHarvestMapMinimapModeActive() then
            return true
        end
        return originalIsInMinimapMode(modeObject)
    end
end

function LUIE_MiniMap_Integrations:ActivateHarvestMap()
    if not self.harvestMap then
        return
    end
    self:SetupHarvestMapMode()
    self.harvestMapActive = true
end

--- Hands QP_Container back to HarvestMap's own scroll (PinController:Initialize parents it to QP_Scroll anchored to
--- ZO_WorldMapContainer) and restores the original mode selection.
function LUIE_MiniMap_Integrations:DeactivateHarvestMap()
    if not self.harvestMap or not self.harvestMapActive then
        return
    end
    self.harvestMapActive = false
    local pinController = self.harvestMap.pinController
    self:ApplyHarvestMapPinScale()
    local container = pinController.container
    container:SetParent(pinController.scroll)
    container:ClearAnchors()
    container:SetAnchor(TOPLEFT, ZO_WorldMapContainer, TOPLEFT, 0, 0)
    pinController:OnMapSizeChange(ZO_WorldMapContainer:GetDimensions())
end

--- HarvestMap resource pins are CT_TEXTURECOMPOSITE controls; PinTypeManager:UpdateSize sets dimensions from
--- layout.size and never touches control scale, so the user multiplier is applied as a composite scale.
function LUIE_MiniMap_Integrations:ApplyHarvestMapPinScale()
    if not self.harvestMap then
        return
    end
    local pinTypeManagers = self.harvestMap.pinController.pinTypeManagers
    if not pinTypeManagers then
        return
    end
    local compositeScale = 1
    if self:IsHarvestMapMinimapModeActive() then
        compositeScale = MiniMap.SV.pinScaleHarvestMap
        if compositeScale == nil then
            compositeScale = 1
        end
    end
    for _, pinTypeManager in pairs(pinTypeManagers) do
        local composite = pinTypeManager.composite
        if composite then
            composite:SetScale(compositeScale)
        end
    end
end

--- Content size changed (zoom / new map): relayout HarvestMap pins to the minimap sheet.
function LUIE_MiniMap_Integrations:OnHarvestMapContentSizeChanged()
    if not self:IsHarvestMapMinimapModeActive() or not self.manager.panAndZoom:HasMap() then
        return
    end
    local panAndZoom = self.manager.panAndZoom
    self.harvestMap.pinController:OnMapSizeChange(panAndZoom:GetContentWidth(), panAndZoom:GetContentHeight())
    self:ApplyHarvestMapPinScale()
end

--- New map sheet: size first, then a redraw against the player's map data.
function LUIE_MiniMap_Integrations:OnHarvestMapMapChanged()
    if not self:IsHarvestMapMinimapModeActive() or not self.manager.panAndZoom:HasMap() then
        return
    end
    self:OnHarvestMapContentSizeChanged()
    if DoesCurrentMapMatchMapForPlayerLocation() then
        self.harvestMap.mapPins:RedrawPins()
    end
end
