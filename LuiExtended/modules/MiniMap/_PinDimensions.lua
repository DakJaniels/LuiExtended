-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- Shared pin draw sizing for LUIE overlays and ZO_WorldMapContainer pins.

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

MiniMap.MINIMAP_PIN_MIN_SCALE = 0.6
MiniMap.MINIMAP_PIN_MAX_SCALE = 1.0
MiniMap.MINIMAP_PIN_MIN_SIZE = 18

--- @param pinType MapDisplayPinType|nil
--- @return number
local function GetMinPinDrawSize(pinType)
    local minSize = MiniMap.MINIMAP_PIN_MIN_SIZE
    if pinType then
        local pinTypeData = ZO_MapPin.PIN_DATA[pinType]
        if pinTypeData and pinTypeData.minSize then
            minSize = pinTypeData.minSize
        end
    end
    return minSize
end

--- @param pinWidth number
--- @param pinHeight number
--- @param pinScale boolean
--- @param pinType MapDisplayPinType|nil
--- @param mapController MiniMapMapController|nil
--- @return number drawWidth
--- @return number drawHeight
function MiniMap.ComputePinDrawDimensions(pinWidth, pinHeight, pinScale, pinType, mapController)
    if pinScale then
        local worldMapWidth, worldMapHeight = ZO_WorldMap_GetMapDimensions()
        local contentHeight = mapController and mapController:GetMapContentHeight() or 0
        if worldMapHeight and worldMapHeight > 0 and contentHeight > 0 then
            local scaleToMinimap = contentHeight / worldMapHeight
            return pinWidth * scaleToMinimap, pinHeight * scaleToMinimap
        end
        local zoom = MiniMap.zoom
        return pinWidth * zoom, pinHeight * zoom
    end

    local minSize = GetMinPinDrawSize(pinType)
    local userScale = MiniMap.GetPinTypeScaleMultiplier(pinType)
    local curvedZoom = zo_clamp(MiniMap.zoom, MiniMap.MINIMAP_PIN_MIN_SCALE, MiniMap.MINIMAP_PIN_MAX_SCALE)
    local uiScale = GetUICustomScale()
    local width = zo_max((pinWidth * curvedZoom * userScale) / uiScale, minSize)
    local height = zo_max((pinHeight * curvedZoom * userScale) / uiScale, minSize)
    return width, height
end
