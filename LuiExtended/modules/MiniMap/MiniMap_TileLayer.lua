-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

--- Own tile pool for the minimap, built on ZO_WorldMapTiles_Manager (EsoUI/Ingame/Map/WorldMapTiles_Manager.lua).
--- Only `LayoutTiles` is overridden: the ZOS version sizes tiles from `ZO_MAP_CONSTANTS` and releases every tile
--- before re-acquiring; this version sizes from the minimap scroll area and keeps active tiles so their textures
--- (RELEASE_TEXTURE_AT_ZERO_REFERENCES) are not dropped between layouts.
--- @class LUIE_MiniMap_TileLayer : ZO_WorldMapTiles_Manager
--- @field panAndZoom LUIE_MiniMap_PanAndZoom
--- @field horizontalTiles integer|nil
--- @field verticalTiles integer|nil
--- @field totalTiles integer|nil
--- @field tilePixelWidth number
--- @field tilePixelHeight number
LUIE_MiniMap_TileLayer = ZO_WorldMapTiles_Manager:Subclass()

--- @param parentControl Control
--- @param panAndZoom LUIE_MiniMap_PanAndZoom
function LUIE_MiniMap_TileLayer:Initialize(parentControl, panAndZoom)
    -- ZO_ControlPool.Initialize(templateName, parent, overrideName): control names are parent:GetName() .. overrideName .. id
    ZO_ControlPool.Initialize(self, "LUIE_MiniMap_Tile", parentControl, "Tile")
    self.panAndZoom = panAndZoom
    self.tilePixelWidth = 0
    self.tilePixelHeight = 0
end

--- @return boolean
function LUIE_MiniMap_TileLayer:HasTiles()
    return self.totalTiles ~= nil and self.totalTiles > 0
end

--- Tile pixel size from the loaded texture file; falls back to the ZOS sheet size (ZO_WorldMap_GetMapDimensions,
--- WorldMap.lua:2668) divided by the tile grid until the first tile texture is resident.
--- @return boolean changed
function LUIE_MiniMap_TileLayer:UpdateTilePixelSize()
    if not self:HasTiles() then
        return false
    end
    local firstTile = self:GetActiveObject(1)
    local tileWidth, tileHeight = 0, 0
    if firstTile and firstTile:IsTextureLoaded() then
        tileWidth, tileHeight = firstTile:GetTextureFileDimensions()
    end
    if not tileWidth or tileWidth <= 0 or not tileHeight or tileHeight <= 0 then
        local sheetWidth, sheetHeight = ZO_WorldMap_GetMapDimensions()
        tileWidth = sheetWidth / self.horizontalTiles
        tileHeight = sheetHeight / self.verticalTiles
    end
    if tileWidth == self.tilePixelWidth and tileHeight == self.tilePixelHeight then
        return false
    end
    self.tilePixelWidth = tileWidth
    self.tilePixelHeight = tileHeight
    return true
end

--- @return number baseWidth, number baseHeight
function LUIE_MiniMap_TileLayer:GetBasePixelSize()
    if not self:HasTiles() then
        return 0, 0
    end
    return self.tilePixelWidth * self.horizontalTiles, self.tilePixelHeight * self.verticalTiles
end

--- Overrides ZO_WorldMapTiles_Manager:LayoutTiles (WorldMapTiles_Manager.lua:22-39).
function LUIE_MiniMap_TileLayer:LayoutTiles()
    if self.horizontalTiles == nil then
        self:UpdateMapData()
    end
    if not self:HasTiles() then
        self:ReleaseAllObjects()
        return
    end

    -- Release surplus keys only; AcquireObject(i) returns the already-active control for a live key.
    local activeObjects = self:GetActiveObjects()
    local surplusKeys = {}
    for tileKey in pairs(activeObjects) do
        if type(tileKey) ~= "number" or tileKey > self.totalTiles then
            surplusKeys[#surplusKeys + 1] = tileKey
        end
    end
    for index = 1, #surplusKeys do
        self:ReleaseObject(surplusKeys[index])
    end

    local contentWidth = self.panAndZoom:GetContentWidth()
    local contentHeight = self.panAndZoom:GetContentHeight()
    local tileWidth = contentWidth / self.horizontalTiles
    local tileHeight = contentHeight / self.verticalTiles

    for index = 1, self.totalTiles do
        local tileControl = self:AcquireObject(index)
        tileControl:SetDimensions(tileWidth, tileHeight)
        local offsetX = zo_mod(index - 1, self.horizontalTiles) * tileWidth
        local offsetY = zo_floor((index - 1) / self.horizontalTiles) * tileHeight
        tileControl:ClearAnchors()
        tileControl:SetAnchor(TOPLEFT, self.parent, TOPLEFT, offsetX, offsetY)
    end
end

--- Re-applies the current map's tile textures to the active tiles (no layout).
function LUIE_MiniMap_TileLayer:RefreshTextures()
    if not self:HasTiles() then
        return
    end
    for index = 1, self.totalTiles do
        local tileControl = self:GetActiveObject(index)
        if tileControl then
            tileControl:SetTexture(GetMapTileTexture(index))
        end
    end
end

--- @return boolean
function LUIE_MiniMap_TileLayer:AreTexturesLoaded()
    if not self:HasTiles() then
        return false
    end
    for index = 1, self.totalTiles do
        local tileControl = self:GetActiveObject(index)
        if not tileControl or not tileControl:IsTextureLoaded() then
            return false
        end
    end
    return true
end
