-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class LUIE.GridOverlay
local GridOverlay = {}
GridOverlay.__index = GridOverlay

local windowManager = GetWindowManager()
local mathFloor = math.floor
local round = zo_round

local GRID_COLOR =
{
    r = 0.1,
    g = 0.7,
    b = 0.9,
    a = 0.35,
}

local function ResetLine(line)
    line:ClearAnchors()
    line:SetHidden(true)
end

local function CreateLine(parent)
    local line = windowManager:CreateControl(nil, parent, CT_LINE)
    line:SetDrawLayer(DL_BACKGROUND)
    line:SetDrawTier(DT_LOW)
    line:SetDrawLevel(2)
    line:SetColor(GRID_COLOR.r, GRID_COLOR.g, GRID_COLOR.b, GRID_COLOR.a)
    line:SetThickness(1)
    line:SetHidden(true)
    return line
end

function GridOverlay:New(identifier)
    local overlay =
    {
        id = identifier,
        control = nil,
        verticalPool = nil,
        horizontalPool = nil,
        size = 0,
    }

    return setmetatable(overlay, GridOverlay)
end

function GridOverlay:EnsureControl()
    if self.control then
        return
    end

    local control = windowManager:CreateTopLevelWindow("LUIEGridOverlay" .. self.id)
    control:SetAnchorFill(GuiRoot)
    control:SetDrawLayer(DL_BACKGROUND)
    control:SetDrawTier(DT_LOW)
    control:SetDrawLevel(1)
    control:SetAlpha(1)
    control:SetMouseEnabled(false)
    control:SetMovable(false)
    control:SetHidden(true)
    control:SetClampedToScreen(false)

    self.control = control

    local function Factory()
        return CreateLine(self.control)
    end

    self.verticalPool = ZO_ObjectPool:New(function ()
                                              return Factory()
                                          end, ResetLine)
    self.horizontalPool = ZO_ObjectPool:New(function ()
                                                return Factory()
                                            end, ResetLine)
end

function GridOverlay:AcquireLine(pool, key)
    local line
    line = select(1, pool:AcquireObject(key))
    line:SetHidden(false)
    return line
end

function GridOverlay:ReleaseUnused(pool, maxKey)
    local active = pool:GetActiveObjects()
    local keysToRelease = {}
    for key in pairs(active) do
        if key > maxKey then
            keysToRelease[#keysToRelease + 1] = key
        end
    end
    for _, key in ipairs(keysToRelease) do
        pool:ReleaseObject(key)
    end
end

function GridOverlay:ReleaseAll()
    if self.verticalPool then
        self.verticalPool:ReleaseAllObjects()
    end
    if self.horizontalPool then
        self.horizontalPool:ReleaseAllObjects()
    end
end

function GridOverlay:UpdateLines(size)
    if not self.control or size <= 0 then
        return
    end

    local rootWidth = GuiRoot:GetWidth() or 0
    local rootHeight = GuiRoot:GetHeight() or 0

    local verticalCount = mathFloor(rootWidth / size)
    for i = 0, verticalCount do
        local offsetX = round(i * size)
        local line = self:AcquireLine(self.verticalPool, i)
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, self.control, TOPLEFT, offsetX, 0)
        line:SetAnchor(BOTTOMLEFT, self.control, BOTTOMLEFT, offsetX, 0)
    end
    self:ReleaseUnused(self.verticalPool, verticalCount)

    local horizontalCount = mathFloor(rootHeight / size)
    for i = 0, horizontalCount do
        local offsetY = round(i * size)
        local line = self:AcquireLine(self.horizontalPool, i)
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, offsetY)
        line:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, 0, offsetY)
    end
    self:ReleaseUnused(self.horizontalPool, horizontalCount)
end

function GridOverlay:Hide()
    if not self.control then
        return
    end

    self:ReleaseAll()
    self.control:SetHidden(true)
end

function GridOverlay:SetHidden(hidden)
    if not self.control then
        return
    end

    if hidden then
        self:Hide()
        return
    end

    self.control:SetHidden(false)
    self:UpdateLines(self.size)
end

function GridOverlay:Refresh(visible, size)
    if size then
        self.size = size
    end

    local effectiveSize = self.size or 0
    if not visible or effectiveSize <= 0 then
        self:Hide()
        return
    end

    self:EnsureControl()
    self.control:SetHidden(false)
    self:UpdateLines(effectiveSize)
end

--- @class LUIE.GridOverlayManager
local GridOverlayManager =
{
    overlays = {},
}

function GridOverlayManager:GetOverlay(identifier)
    local overlay = self.overlays[identifier]
    if not overlay then
        overlay = GridOverlay:New(identifier)
        self.overlays[identifier] = overlay
    end
    return overlay
end

function GridOverlayManager.Refresh(identifier, visible, size)
    local overlay = GridOverlayManager:GetOverlay(identifier)
    overlay:Refresh(visible, size)
end

function GridOverlayManager.SetHidden(identifier, hidden)
    local overlay = GridOverlayManager.overlays[identifier]
    if overlay then
        overlay:SetHidden(hidden)
    end
end

function GridOverlayManager.Hide(identifier)
    local overlay = GridOverlayManager.overlays[identifier]
    if overlay then
        overlay:Hide()
    end
end

function GridOverlayManager.HideAll()
    for _, overlay in pairs(GridOverlayManager.overlays) do
        overlay:Hide()
    end
end

--- @class LUIE.GridOverlayManager
LUIE.GridOverlay = GridOverlayManager
