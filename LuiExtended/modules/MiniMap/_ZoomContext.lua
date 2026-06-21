-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

MiniMap.holdZoomActive = false
MiniMap.holdZoomSavedValue = nil

local MINIMAP_HOLD_ZOOM_IN_MULTIPLIER = 0.55
local MINIMAP_HOLD_ZOOM_OUT_MULTIPLIER = 1.25

local EDGE_NORM_THRESHOLD = 0.04

local function ClampZoomAndRevealZoomLabel()
    if not MiniMap.mapController then
        return
    end
    MiniMap.mapController:ClampZoomToLimits(true)
    if MiniMap.view then
        MiniMap.view:SetZoomLabel(MiniMap.zoom, true)
    end
end

--- @return boolean
function MiniMap.IsInDungeonMap()
    return IsUnitInDungeon("player")
end

--- @return boolean
function MiniMap.IsInBattlegroundMap()
    return IsActiveWorldBattleground()
end

--- @return number
function MiniMap.GetContextBaseZoom()
    local settings = MiniMap.SV
    if MiniMap.IsInBattlegroundMap() then
        return settings.battlegroundMapZoom or settings.resetZoomLevel
    end
    local mapContentType = GetMapContentType()
    if mapContentType == MAP_CONTENT_BATTLEGROUND then
        return settings.battlegroundMapZoom or settings.resetZoomLevel
    end
    if mapContentType == MAP_CONTENT_DUNGEON or MiniMap.IsInDungeonMap() then
        return settings.dungeonMapZoom or settings.resetZoomLevel
    end
    local horizontalTiles = select(1, GetMapNumTiles())
    if horizontalTiles and horizontalTiles > 1 and settings.overworldMultiTileZoom then
        return settings.overworldMultiTileZoom
    end
    return settings.resetZoomLevel
end

--- @return number
function MiniMap.GetMountedZoomMultiplier()
    local settings = MiniMap.SV
    if IsMounted() and settings.mountedZoomMultiplier then
        return settings.mountedZoomMultiplier
    end
    return 1
end

--- @return number
function MiniMap.GetEffectiveDefaultZoom()
    return MiniMap.GetContextBaseZoom() * MiniMap.GetMountedZoomMultiplier()
end

function MiniMap.ApplyContextDefaultZoom()
    if not MiniMap.mapController then
        return
    end
    MiniMap.zoom = MiniMap.GetEffectiveDefaultZoom()
    MiniMap.ClampSavedDefaultZoom()
    MiniMap.mapController:ApplyZoom(0, false)
end

--- @param mapData MiniMapMapData
function MiniMap.TryAutoZoomOutAtMapEdge(mapData)
    local settings = MiniMap.SV
    if settings.autoZoomOutAtEdge ~= true or not MiniMap.mapController then
        return
    end
    if not MiniMap.GetMapFollowsPlayer() then
        return
    end
    local normalizedX, normalizedY, _, isShownInCurrentMap = MiniMap.GetMapPlayerPositionForMirror("player")
    if not MiniMap.IsMapPlayerPositionShownOnHudMap(normalizedX, normalizedY, isShownInCurrentMap) then
        return
    end
    if  normalizedX > EDGE_NORM_THRESHOLD and normalizedX < (1 - EDGE_NORM_THRESHOLD)
    and normalizedY > EDGE_NORM_THRESHOLD and normalizedY < (1 - EDGE_NORM_THRESHOLD) then
        return
    end
    MiniMap.Zoom(-1)
end

function MiniMap.ToggleFixedMapPosition()
    MiniMap.SV.zoneScrollLockEnabled = not MiniMap.SV.zoneScrollLockEnabled
    if not MiniMap.SV.zoneScrollLockByMapName then
        MiniMap.SV.zoneScrollLockByMapName = {}
    end
    if MiniMap.SV.zoneScrollLockEnabled and MiniMap.mapController and MiniMap.mapController:IsReady() then
        local mapData = MiniMap.mapController:GetMapData()
        if mapData then
            local scroll = MiniMap.view.scroll
            local contentWidth = MiniMap.mapController:GetMapContentWidth()
            local contentHeight = MiniMap.mapController:GetMapContentHeight()
            if contentWidth > 0 and contentHeight > 0 then
                local focusX = (scroll:GetHorizontalScroll() + scroll:GetWidth() / 2) / contentWidth
                local focusY = (scroll:GetVerticalScroll() + scroll:GetHeight() / 2) / contentHeight
                MiniMap.SV.zoneScrollLockByMapName[mapData.rawName] = { x = focusX, y = focusY }
            end
        end
        MiniMap.runtime:SetMapFollowsPlayer(false)
    elseif MiniMap.SV.zoneScrollLockEnabled == false then
        MiniMap.RecenterFollow()
    end
end

--- @param mapData MiniMapMapData
--- @return boolean
function MiniMap.ApplyFixedMapScroll(mapData)
    if MiniMap.SV.zoneScrollLockEnabled ~= true or not MiniMap.SV.zoneScrollLockByMapName then
        return false
    end
    local fixedEntry = MiniMap.SV.zoneScrollLockByMapName[mapData.rawName]
    if not fixedEntry or not MiniMap.view or not MiniMap.mapController then
        return false
    end
    local scroll = MiniMap.view.scroll
    local contentWidth = MiniMap.mapController:GetMapContentWidth()
    local contentHeight = MiniMap.mapController:GetMapContentHeight()
    local scrollX = fixedEntry.x * contentWidth - scroll:GetWidth() / 2
    local scrollY = fixedEntry.y * contentHeight - scroll:GetHeight() / 2
    scroll:SetHorizontalScroll(scrollX)
    scroll:SetVerticalScroll(scrollY)
    MiniMap.SV.panOffsetX = scrollX
    MiniMap.SV.panOffsetY = scrollY
    return true
end

--- @param zoomIn boolean
function MiniMap.BeginHoldZoom(zoomIn)
    if not MiniMap.Enabled or not MiniMap.mapController then
        return
    end
    if MiniMap.holdZoomActive then
        return
    end
    MiniMap.holdZoomActive = true
    MiniMap.holdZoomSavedValue = MiniMap.zoom
    local factor = zoomIn and MINIMAP_HOLD_ZOOM_IN_MULTIPLIER or MINIMAP_HOLD_ZOOM_OUT_MULTIPLIER
    MiniMap.zoom = zo_clamp(MiniMap.zoom * factor, MiniMap.mapController:GetMinimumZoom(), 1.8)
    ClampZoomAndRevealZoomLabel()
end

function MiniMap.EndHoldZoom()
    if not MiniMap.holdZoomActive or MiniMap.holdZoomSavedValue == nil then
        MiniMap.holdZoomActive = false
        return
    end
    MiniMap.zoom = MiniMap.holdZoomSavedValue
    MiniMap.holdZoomSavedValue = nil
    MiniMap.holdZoomActive = false
    ClampZoomAndRevealZoomLabel()
end
