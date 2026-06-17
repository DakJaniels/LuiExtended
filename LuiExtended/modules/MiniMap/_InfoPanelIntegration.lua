-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Optional stack: InfoPanel below MiniMap (zone slot) when SV.anchorInfoPanelToMiniMap (reads LUIE.InfoPanel).

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local INFO_PANEL_DEFAULT_OFFSET_X = -24
local INFO_PANEL_DEFAULT_OFFSET_Y = 20

--- @return boolean
function MiniMap.IsInfoPanelAnchorActive()
    if not MiniMap.Enabled or MiniMap.SV.anchorInfoPanelToMiniMap ~= true then
        return false
    end
    local infoPanel = LUIE.InfoPanel
    return infoPanel ~= nil and infoPanel.Enabled == true and LUIE_InfoPanel ~= nil
end

function MiniMap.CaptureInfoPanelAnchorSnapshot()
    local infoPanel = LUIE.InfoPanel
    if not infoPanel or infoPanel.Enabled ~= true or LUIE_InfoPanel == nil then
        return
    end
    local infoPanelControl = LUIE_InfoPanel
    local isValidAnchor, point, _, relativePoint, offsetX, offsetY = infoPanelControl:GetAnchor(0)
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

local function ApplyInfoPanelDefaultXmlAnchor(infoPanelControl)
    infoPanelControl:ClearAnchors()
    infoPanelControl:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, INFO_PANEL_DEFAULT_OFFSET_X, INFO_PANEL_DEFAULT_OFFSET_Y)
end

function MiniMap.RestoreInfoPanelAnchor()
    local infoPanel = LUIE.InfoPanel
    if not infoPanel or infoPanel.Enabled ~= true or LUIE_InfoPanel == nil then
        return
    end
    local infoPanelControl = LUIE_InfoPanel
    local snapshot = MiniMap.SV and MiniMap.SV.infoPanelRestoreAnchor
    if snapshot and snapshot.point ~= nil and snapshot.relativePoint ~= nil then
        infoPanelControl:ClearAnchors()
        infoPanelControl:SetAnchor(snapshot.point, GuiRoot, snapshot.relativePoint, snapshot.offsetX or 0, snapshot.offsetY or 0)
        if MiniMap.SV then
            MiniMap.SV.infoPanelRestoreAnchor = nil
        end
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

function MiniMap.ApplyInfoPanelAnchor()
    if not MiniMap.IsInfoPanelAnchorActive() then
        return
    end
    local view = MiniMap.view
    if not view or not view.root then
        return
    end

    local infoPanelControl = LUIE_InfoPanel
    infoPanelControl:ClearAnchors()
    infoPanelControl:SetAnchor(TOP, view.root, BOTTOM, 0, MiniMap.ZONE_LABEL_CHROME_OFFSET)
end

function MiniMap.ApplyChromeStacking()
    if MiniMap.view then
        MiniMap.view:ApplyZoneLabelPlacement()
        MiniMap.view:ApplyFrameChromePlacement()
    end
    if MiniMap.IsInfoPanelAnchorActive() then
        MiniMap.ApplyInfoPanelAnchor()
    end
end
