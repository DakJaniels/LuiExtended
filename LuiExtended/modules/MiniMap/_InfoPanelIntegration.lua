-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Optional stack: InfoPanel below MiniMap (zone slot) when SV.anchorInfoPanelToMiniMap (reads LUIE.InfoPanel).

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

--- @return boolean
function MiniMap.IsInfoPanelAnchorActive()
    if not MiniMap.Enabled or not MiniMap.SV or MiniMap.SV.anchorInfoPanelToMiniMap ~= true then
        return false
    end
    local infoPanel = LUIE.InfoPanel
    return infoPanel ~= nil and infoPanel.Enabled == true and LUIE_InfoPanel ~= nil
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
