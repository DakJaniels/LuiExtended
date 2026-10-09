-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local MINIMAP_HOLD_ZOOM_IN_MULTIPLIER = 0.55
local MINIMAP_HOLD_ZOOM_OUT_MULTIPLIER = 1.25
local MINIMAP_EDGE_NORMALIZED_THRESHOLD = 0.04
local MINIMAP_AUTO_ZOOM_EDGE_THROTTLE_MS = 600

--- Zoom, content size and scroll math for the minimap scroll area.
--- Callbacks: "ZoomChanged"(zoom, revealTemporarily), "ContentSizeChanged"(contentWidth, contentHeight), "FollowChanged"(followsPlayer).
--- @class LUIE_MiniMap_PanAndZoom : ZO_InitializingCallbackObject
--- @field scroll ScrollControl
--- @field map Control
--- @field zoom number
--- @field baseWidth number Map sheet pixel width at zoom 1 (tile pixel width * horizontal tiles).
--- @field baseHeight number
--- @field mapFollowsPlayer boolean
--- @field lastPlayerNormalizedX number|nil
--- @field lastPlayerNormalizedY number|nil
--- @field holdZoomActive boolean
--- @field holdZoomSavedValue number|nil
--- @field lastZoomContextSignature string|nil
--- @field nextAutoZoomEdgeCheckMs number
LUIE_MiniMap_PanAndZoom = ZO_InitializingCallbackObject:Subclass()

--- @param scrollControl ScrollControl
--- @param mapControl Control
function LUIE_MiniMap_PanAndZoom:Initialize(scrollControl, mapControl)
    self.scroll = scrollControl
    self.map = mapControl
    self.zoom = MiniMap.SV.resetZoomLevel or MiniMap.Defaults.resetZoomLevel
    self.baseWidth = 0
    self.baseHeight = 0
    self.mapFollowsPlayer = MiniMap.SV.followPlayer == true and MiniMap.SV.zoneScrollLockEnabled ~= true
    self.lastPlayerNormalizedX = nil
    self.lastPlayerNormalizedY = nil
    self.holdZoomActive = false
    self.holdZoomSavedValue = nil
    self.lastZoomContextSignature = nil
    self.nextAutoZoomEdgeCheckMs = 0
    -- ScrollControl:SetScrollBounding (ESOUIDocumentation.txt); 0 lets the map scroll to its edges without bounce.
    self.scroll:SetScrollBounding(0)
end

-- Content size ---------------------------------------------------------------

--- @return boolean
function LUIE_MiniMap_PanAndZoom:HasMap()
    return self.baseWidth > 0 and self.baseHeight > 0
end

--- @return number
function LUIE_MiniMap_PanAndZoom:GetContentWidth()
    return self.zoom * self.baseWidth
end

--- @return number
function LUIE_MiniMap_PanAndZoom:GetContentHeight()
    return self.zoom * self.baseHeight
end

--- @return number
function LUIE_MiniMap_PanAndZoom:GetZoom()
    return self.zoom
end

--- Pin scale curve shared with EsoUI/Ingame/Map/MapPin.lua:2882 (zo_clamp(curvedZoom, MIN_PIN_SCALE, MAX_PIN_SCALE)).
--- @return number
function LUIE_MiniMap_PanAndZoom:GetCurvedPinScale()
    return zo_clamp(self.zoom, MiniMap.MINIMAP_PIN_MIN_SCALE, MiniMap.MINIMAP_PIN_MAX_SCALE)
end

function LUIE_MiniMap_PanAndZoom:ApplyContentSize()
    local contentWidth = self:GetContentWidth()
    local contentHeight = self:GetContentHeight()
    self.map:SetDimensions(contentWidth, contentHeight)
    self:FireCallbacks("ContentSizeChanged", contentWidth, contentHeight)
end

--- @param baseWidth number
--- @param baseHeight number
function LUIE_MiniMap_PanAndZoom:SetBaseMapSize(baseWidth, baseHeight)
    if baseWidth == self.baseWidth and baseHeight == self.baseHeight then
        return
    end
    self.baseWidth = baseWidth
    self.baseHeight = baseHeight
    self:ApplyContentSize()
end

-- Zoom -----------------------------------------------------------------------

--- Whole zone visible; map content not smaller than scroll area (no letterboxing).
--- @return number
function LUIE_MiniMap_PanAndZoom:GetMinimumZoom()
    if not self:HasMap() then
        return MiniMap.MINIMAP_ZOOM_MIN_FALLBACK
    end
    local scrollWidth = self.scroll:GetWidth()
    local scrollHeight = self.scroll:GetHeight()
    if scrollWidth <= 0 or scrollHeight <= 0 then
        return MiniMap.MINIMAP_ZOOM_MIN_FALLBACK
    end
    return zo_min(scrollWidth / self.baseWidth, scrollHeight / self.baseHeight)
end

--- @param zoom number
--- @return number
function LUIE_MiniMap_PanAndZoom:ClampZoomValue(zoom)
    return zo_clamp(zoom, self:GetMinimumZoom(), MiniMap.MINIMAP_ZOOM_MAX)
end

--- @param zoom number
--- @param revealTemporarily boolean|nil
function LUIE_MiniMap_PanAndZoom:SetZoom(zoom, revealTemporarily)
    local previousContentWidth = self:GetContentWidth()
    local previousContentHeight = self:GetContentHeight()
    local clampedZoom = self:ClampZoomValue(zoom)
    local zoomChanged = clampedZoom ~= self.zoom
    self.zoom = clampedZoom
    if zoomChanged then
        self:ApplyContentSize()
    end
    if self:HasMap() then
        self:ApplyScrollAfterZoom(previousContentWidth, previousContentHeight)
    end
    self:FireCallbacks("ZoomChanged", self.zoom, revealTemporarily == true)
end

--- @param delta number 0 resets to the saved default zoom, otherwise a wheel/keybind step count.
--- @param revealTemporarily boolean|nil
function LUIE_MiniMap_PanAndZoom:ApplyZoom(delta, revealTemporarily)
    if delta == 0 then
        self:SetZoom(MiniMap.SV.resetZoomLevel or MiniMap.Defaults.resetZoomLevel, revealTemporarily)
    else
        self:SetZoom(self.zoom + delta * MiniMap.MINIMAP_ZOOM_STEP, revealTemporarily)
    end
end

--- @param revealTemporarily boolean|nil
function LUIE_MiniMap_PanAndZoom:ClampZoomToLimits(revealTemporarily)
    self:SetZoom(self.zoom, revealTemporarily)
end

--- @return number
function LUIE_MiniMap_PanAndZoom:GetContextBaseZoom()
    local settings = MiniMap.SV
    if IsActiveWorldBattleground() then
        return settings.battlegroundMapZoom or settings.resetZoomLevel
    end
    local mapContentType = GetMapContentType()
    if mapContentType == MAP_CONTENT_BATTLEGROUND then
        return settings.battlegroundMapZoom or settings.resetZoomLevel
    end
    if mapContentType == MAP_CONTENT_DUNGEON or IsUnitInDungeon("player") then
        return settings.dungeonMapZoom or settings.resetZoomLevel
    end
    local horizontalTiles = GetMapNumTiles()
    if horizontalTiles and horizontalTiles > 1 and settings.overworldMultiTileZoom then
        return settings.overworldMultiTileZoom
    end
    return settings.resetZoomLevel
end

--- @return number
function LUIE_MiniMap_PanAndZoom:GetMountedZoomMultiplier()
    local settings = MiniMap.SV
    if IsMounted() and settings.mountedZoomMultiplier then
        return settings.mountedZoomMultiplier
    end
    return 1
end

--- @return number
function LUIE_MiniMap_PanAndZoom:GetEffectiveDefaultZoom()
    return self:GetContextBaseZoom() * self:GetMountedZoomMultiplier()
end

--- Tile grid + context base zoom; changes only when the zoom rules change, not on every subzone label hop.
--- @return string
function LUIE_MiniMap_PanAndZoom:GetZoomContextSignature()
    local horizontalTiles, verticalTiles = GetMapNumTiles()
    return string.format("%d:%d:%.4f", horizontalTiles or 0, verticalTiles or 0, self:GetContextBaseZoom())
end

function LUIE_MiniMap_PanAndZoom:RecordZoomContextSignature()
    self.lastZoomContextSignature = self:GetZoomContextSignature()
end

--- Snaps to the context default zoom (no temporary label reveal).
function LUIE_MiniMap_PanAndZoom:ApplyContextDefaultZoom()
    self:RecordZoomContextSignature()
    self:SetZoom(self:GetEffectiveDefaultZoom(), false)
end

--- @return boolean applied
function LUIE_MiniMap_PanAndZoom:ApplyContextZoomWhenMapContextChanged()
    if self.holdZoomActive then
        return false
    end
    local signature = self:GetZoomContextSignature()
    if self.lastZoomContextSignature == signature then
        return false
    end
    self.lastZoomContextSignature = signature
    self:SetZoom(self:GetEffectiveDefaultZoom(), false)
    return true
end

--- @param zoomIn boolean
function LUIE_MiniMap_PanAndZoom:BeginHoldZoom(zoomIn)
    if self.holdZoomActive then
        return
    end
    self.holdZoomActive = true
    self.holdZoomSavedValue = self.zoom
    local factor = zoomIn and MINIMAP_HOLD_ZOOM_IN_MULTIPLIER or MINIMAP_HOLD_ZOOM_OUT_MULTIPLIER
    self:SetZoom(self.zoom * factor, true)
end

function LUIE_MiniMap_PanAndZoom:EndHoldZoom()
    if not self.holdZoomActive or self.holdZoomSavedValue == nil then
        self.holdZoomActive = false
        return
    end
    local savedZoom = self.holdZoomSavedValue
    self.holdZoomSavedValue = nil
    self.holdZoomActive = false
    self:SetZoom(savedZoom, true)
end

-- Follow / scroll ------------------------------------------------------------

--- @return boolean
function LUIE_MiniMap_PanAndZoom:GetFollowsPlayer()
    if MiniMap.SV.zoneScrollLockEnabled == true then
        return false
    end
    return self.mapFollowsPlayer
end

--- @param followsPlayer boolean
function LUIE_MiniMap_PanAndZoom:SetFollowsPlayer(followsPlayer)
    self.mapFollowsPlayer = followsPlayer
    if followsPlayer then
        self:ClearFollowCache()
    end
    self:FireCallbacks("FollowChanged", self:GetFollowsPlayer())
end

function LUIE_MiniMap_PanAndZoom:ClearFollowCache()
    self.lastPlayerNormalizedX = nil
    self.lastPlayerNormalizedY = nil
end

--- Player pip / follow scroll use isShownInCurrentMap like ZO_WorldMapPins_Manager:UpdateMovingPins (MapPin_Manager.lua:793).
--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param isShownInCurrentMap boolean|nil
--- @return boolean
function LUIE_MiniMap_PanAndZoom.IsPlayerPositionShown(normalizedX, normalizedY, isShownInCurrentMap)
    return isShownInCurrentMap == true and normalizedX ~= nil and normalizedY ~= nil
end

--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param isShownInCurrentMap boolean|nil
function LUIE_MiniMap_PanAndZoom:CenterOnPlayer(normalizedX, normalizedY, isShownInCurrentMap)
    if normalizedX == nil or normalizedY == nil then
        local playerHeading
        normalizedX, normalizedY, playerHeading, isShownInCurrentMap = GetMapPlayerPosition("player")
    end
    if not LUIE_MiniMap_PanAndZoom.IsPlayerPositionShown(normalizedX, normalizedY, isShownInCurrentMap) then
        return
    end
    local scroll = self.scroll
    local horizontalScroll = (normalizedX * self:GetContentWidth()) - (scroll:GetWidth() / 2)
    local verticalScroll = (normalizedY * self:GetContentHeight()) - (scroll:GetHeight() / 2)
    -- Sub-pixel scroll writes do not move the map but still fire OnScrollOffsetChanged on both axes.
    if zo_abs(horizontalScroll - scroll:GetHorizontalScroll()) >= 1 then
        scroll:SetHorizontalScroll(horizontalScroll)
    end
    if zo_abs(verticalScroll - scroll:GetVerticalScroll()) >= 1 then
        scroll:SetVerticalScroll(verticalScroll)
    end
    self.lastPlayerNormalizedX = normalizedX
    self.lastPlayerNormalizedY = normalizedY
end

--- Follow interval update: scrolls only when the player's normalized position changed since the last write.
--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param isShownInCurrentMap boolean|nil
function LUIE_MiniMap_PanAndZoom:FollowPlayer(normalizedX, normalizedY, isShownInCurrentMap)
    if normalizedX ~= self.lastPlayerNormalizedX or normalizedY ~= self.lastPlayerNormalizedY then
        self:CenterOnPlayer(normalizedX, normalizedY, isShownInCurrentMap)
    end
end

--- @param previousContentWidth number
--- @param previousContentHeight number
function LUIE_MiniMap_PanAndZoom:ApplyScrollAfterZoom(previousContentWidth, previousContentHeight)
    if previousContentWidth <= 0 or previousContentHeight <= 0 then
        return
    end
    if self:GetFollowsPlayer() then
        self:ClearFollowCache()
        self:CenterOnPlayer()
        return
    end
    local scroll = self.scroll
    local scrollWidth = scroll:GetWidth()
    local scrollHeight = scroll:GetHeight()
    local normalizedFocusX = (scroll:GetHorizontalScroll() + scrollWidth / 2) / previousContentWidth
    local normalizedFocusY = (scroll:GetVerticalScroll() + scrollHeight / 2) / previousContentHeight
    local newScrollX = normalizedFocusX * self:GetContentWidth() - scrollWidth / 2
    local newScrollY = normalizedFocusY * self:GetContentHeight() - scrollHeight / 2
    scroll:SetHorizontalScroll(newScrollX)
    scroll:SetVerticalScroll(newScrollY)
    MiniMap.SV.panOffsetX = newScrollX
    MiniMap.SV.panOffsetY = newScrollY
end

function LUIE_MiniMap_PanAndZoom:ApplyPanOffsets()
    self.scroll:SetHorizontalScroll(MiniMap.SV.panOffsetX or 0)
    self.scroll:SetVerticalScroll(MiniMap.SV.panOffsetY or 0)
end

function LUIE_MiniMap_PanAndZoom:SavePanOffsets()
    MiniMap.SV.panOffsetX = self.scroll:GetHorizontalScroll()
    MiniMap.SV.panOffsetY = self.scroll:GetVerticalScroll()
end

--- Scroll handler passthrough (LUIE_MiniMap_Scroll OnScrollOffsetChanged).
--- @param horizontal number
--- @param vertical number
function LUIE_MiniMap_PanAndZoom:OnScrollOffsetChanged(horizontal, vertical)
    MiniMap.SV.panOffsetX = horizontal
    MiniMap.SV.panOffsetY = vertical
end

--- @param mapName string
--- @return boolean applied
function LUIE_MiniMap_PanAndZoom:ApplyFixedMapScroll(mapName)
    if MiniMap.SV.zoneScrollLockEnabled ~= true or not MiniMap.SV.zoneScrollLockByMapName then
        return false
    end
    local fixedEntry = MiniMap.SV.zoneScrollLockByMapName[mapName]
    if not fixedEntry or not self:HasMap() then
        return false
    end
    local scroll = self.scroll
    local scrollX = fixedEntry.x * self:GetContentWidth() - scroll:GetWidth() / 2
    local scrollY = fixedEntry.y * self:GetContentHeight() - scroll:GetHeight() / 2
    scroll:SetHorizontalScroll(scrollX)
    scroll:SetVerticalScroll(scrollY)
    MiniMap.SV.panOffsetX = scrollX
    MiniMap.SV.panOffsetY = scrollY
    return true
end

--- Keybind: freeze the current scroll focus for this map, or go back to following the player.
--- @param mapName string
function LUIE_MiniMap_PanAndZoom:ToggleFixedMapPosition(mapName)
    MiniMap.SV.zoneScrollLockEnabled = not MiniMap.SV.zoneScrollLockEnabled
    if not MiniMap.SV.zoneScrollLockByMapName then
        MiniMap.SV.zoneScrollLockByMapName = {}
    end
    if MiniMap.SV.zoneScrollLockEnabled then
        if self:HasMap() then
            local scroll = self.scroll
            local focusX = (scroll:GetHorizontalScroll() + scroll:GetWidth() / 2) / self:GetContentWidth()
            local focusY = (scroll:GetVerticalScroll() + scroll:GetHeight() / 2) / self:GetContentHeight()
            MiniMap.SV.zoneScrollLockByMapName[mapName] = { x = focusX, y = focusY }
        end
        self:SetFollowsPlayer(false)
    else
        MiniMap.SV.followPlayer = true
        self:SetFollowsPlayer(true)
        self:CenterOnPlayer()
    end
end

--- @param normalizedX number|nil
--- @param normalizedY number|nil
--- @param isShownInCurrentMap boolean|nil
--- @return boolean zoomedOut
function LUIE_MiniMap_PanAndZoom:TryAutoZoomOutAtMapEdge(normalizedX, normalizedY, isShownInCurrentMap)
    if MiniMap.SV.autoZoomOutAtEdge ~= true or not self:GetFollowsPlayer() then
        return false
    end
    local nowMs = GetFrameTimeMilliseconds()
    if nowMs < self.nextAutoZoomEdgeCheckMs then
        return false
    end
    self.nextAutoZoomEdgeCheckMs = nowMs + MINIMAP_AUTO_ZOOM_EDGE_THROTTLE_MS
    if not LUIE_MiniMap_PanAndZoom.IsPlayerPositionShown(normalizedX, normalizedY, isShownInCurrentMap) then
        return false
    end
    if  normalizedX > MINIMAP_EDGE_NORMALIZED_THRESHOLD and normalizedX < (1 - MINIMAP_EDGE_NORMALIZED_THRESHOLD)
    and normalizedY > MINIMAP_EDGE_NORMALIZED_THRESHOLD and normalizedY < (1 - MINIMAP_EDGE_NORMALIZED_THRESHOLD) then
        return false
    end
    if self.zoom <= self:GetMinimumZoom() then
        return false
    end
    self:ApplyZoom(-1, true)
    return true
end

--- Screen point to normalized map coordinates (nil when outside the map sheet).
--- @param screenX number
--- @param screenY number
--- @return number|nil normalizedX
--- @return number|nil normalizedY
function LUIE_MiniMap_PanAndZoom:GetNormalizedPointFromScreen(screenX, screenY)
    local contentWidth = self:GetContentWidth()
    local contentHeight = self:GetContentHeight()
    if contentWidth <= 0 or contentHeight <= 0 then
        return nil, nil
    end
    local scroll = self.scroll
    local localX = screenX - scroll:GetLeft() + scroll:GetHorizontalScroll()
    local localY = screenY - scroll:GetTop() + scroll:GetVerticalScroll()
    local normalizedX = localX / contentWidth
    local normalizedY = localY / contentHeight
    if normalizedX < 0 or normalizedX > 1 or normalizedY < 0 or normalizedY > 1 then
        return nil, nil
    end
    return normalizedX, normalizedY
end
