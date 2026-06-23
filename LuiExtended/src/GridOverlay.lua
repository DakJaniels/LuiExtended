-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- -----------------------------------------------------------------------------
-- Constants
-- -----------------------------------------------------------------------------

local DEFAULT_GRID_SIZE = 15
local OVERLAY_CONTROL_NAME = "LUIE_Grid_Overlay"
local LINE_TEMPLATE_V = "LUIE_Grid_Overlay_Line_V"
local LINE_TEMPLATE_H = "LUIE_Grid_Overlay_Line_H"

local GRID_COLOR =
{
    r = 0.1,
    g = 0.7,
    b = 0.9,
    a = 0.35,
}

local SCENE_NAMES = { "hud", "hudui", "gameMenuInGame", "siegeBar", "siegeBarUI" }

-- -----------------------------------------------------------------------------
-- Line control helpers (used by pool)
-- -----------------------------------------------------------------------------

local windowManager = GetWindowManager()
local sceneManager = SCENE_MANAGER
local zo_floor = zo_floor
local zo_round = zo_round

local function ResetLine(line)
    line:ClearAnchors()
    line:SetHidden(true)
end

local function ApplyLineStyle(line)
    line:SetDrawLayer(DL_BACKGROUND)
    line:SetDrawTier(DT_LOW)
    line:SetDrawLevel(2)
    line:SetColor(GRID_COLOR.r, GRID_COLOR.g, GRID_COLOR.b, GRID_COLOR.a)
    line:SetThickness(1)
end

-- -----------------------------------------------------------------------------
-- GridOverlay instance (single shared overlay, deferred pools, fragment-driven visibility)
-- -----------------------------------------------------------------------------

--- @class LUIE.GridOverlay : ZO_DeferredInitializingObject
local GridOverlay = ZO_DeferredInitializingObject:Subclass()
GridOverlay.__index = GridOverlay

function GridOverlay:Initialize(identifier, fragment, control)
    ZO_DeferredInitializingObject.Initialize(self, fragment)
    self.identifier = identifier
    self.control = control
    self.fragment = fragment
    self.verticalPool = nil
    self.horizontalPool = nil
    self.size = 0
    self:OnDeferredInitialize()
end

function GridOverlay:OnDeferredInitialize()
    local parentControl = self.control
    local function verticalLineFactory(objectPool, objectKey)
        return ZO_ObjectPool_CreateControl(LINE_TEMPLATE_V, objectPool, parentControl)
    end
    local function horizontalLineFactory(objectPool, objectKey)
        return ZO_ObjectPool_CreateControl(LINE_TEMPLATE_H, objectPool, parentControl)
    end
    --- @diagnostic disable-next-line: assign-type-mismatch
    self.verticalPool = ZO_ObjectPool:New(verticalLineFactory, ResetLine) --- @type ZO_ObjectPool
    self.verticalPool:SetCustomFactoryBehavior(function (line)
        ApplyLineStyle(line)
    end)
    self.verticalPool:SetCustomAcquireBehavior(function (line)
        line:SetHidden(false)
    end)

    --- @diagnostic disable-next-line: assign-type-mismatch
    self.horizontalPool = ZO_ObjectPool:New(horizontalLineFactory, ResetLine) --- @type ZO_ObjectPool
    self.horizontalPool:SetCustomFactoryBehavior(function (line)
        ApplyLineStyle(line)
    end)
    self.horizontalPool:SetCustomAcquireBehavior(function (line)
        line:SetHidden(false)
    end)
end

function GridOverlay:GetControl()
    return self.control
end

function GridOverlay:AddFragmentToScenes()
    for sceneIndex, sceneName in ipairs(SCENE_NAMES) do
        local scene = sceneManager:GetScene(sceneName)
        if scene and not scene:HasFragment(self.fragment) then
            scene:AddFragment(self.fragment)
        end
    end
end

function GridOverlay:RemoveFragmentFromScenes()
    for sceneIndex, sceneName in ipairs(SCENE_NAMES) do
        local scene = sceneManager:GetScene(sceneName)
        if scene then
            scene:RemoveFragment(self.fragment)
        end
    end
end

function GridOverlay:OnShowing()
    self:UpdateLines(self.size)
end

function GridOverlay:AcquireLine(objectPool, objectKey)
    local line = select(1, objectPool:AcquireObject(objectKey))
    return line
end

function GridOverlay:ReleaseUnused(objectPool, maxRetainedKey)
    local activeObjects = objectPool:GetActiveObjects()
    for objectKey in pairs(activeObjects) do
        if objectKey > maxRetainedKey then
            objectPool:ReleaseObject(objectKey)
        end
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

function GridOverlay:UpdateLines(gridSize)
    if not self.control or gridSize <= 0 then
        return
    end
    if not self.verticalPool or not self.horizontalPool then
        return
    end
    local rootWidth = GuiRoot:GetWidth() or 0
    local rootHeight = GuiRoot:GetHeight() or 0

    local verticalLineCount = zo_floor(rootWidth / gridSize)
    for lineIndex = 0, verticalLineCount do
        local offsetX = zo_round(lineIndex * gridSize)
        local line = self:AcquireLine(self.verticalPool, lineIndex)
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, self.control, TOPLEFT, offsetX, 0)
        line:SetAnchor(BOTTOMLEFT, self.control, BOTTOMLEFT, offsetX, 0)
    end
    self:ReleaseUnused(self.verticalPool, verticalLineCount)

    local horizontalLineCount = zo_floor(rootHeight / gridSize)
    for lineIndex = 0, horizontalLineCount do
        local offsetY = zo_round(lineIndex * gridSize)
        local line = self:AcquireLine(self.horizontalPool, lineIndex)
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, offsetY)
        line:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, 0, offsetY)
    end
    self:ReleaseUnused(self.horizontalPool, horizontalLineCount)
end

function GridOverlay:Hide()
    if not self.control then
        return
    end
    self:ReleaseAll()
    self:RemoveFragmentFromScenes()
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
    self:AddFragmentToScenes()
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
    self:AddFragmentToScenes()
    if self.verticalPool and self.horizontalPool then
        self:UpdateLines(effectiveSize)
    end
end

-- -----------------------------------------------------------------------------
-- GridOverlayManager (single shared overlay, requester aggregation)
-- -----------------------------------------------------------------------------

--- @class LUIE.GridOverlayManager
--- @field requesters table<string, { visible: boolean, size: number }>
--- @field sharedOverlay LUIE.GridOverlay?
local GridOverlayManager =
{
    requesters = {},
}

local SHARED_OVERLAY_ID = "shared"

--- @param manager LUIE.GridOverlayManager
--- @return LUIE.GridOverlay?
local function GetSharedOverlay(manager)
    if not manager.sharedOverlay then
        local control = windowManager:GetControlByName(OVERLAY_CONTROL_NAME)
        if not control then
            return nil
        end
        control:SetAnchorFill(GuiRoot)
        control:SetDrawLayer(DL_BACKGROUND)
        control:SetDrawTier(DT_LOW)
        control:SetDrawLevel(0)
        control:SetAlpha(1)
        control:SetMouseEnabled(false)
        control:SetMovable(false)
        control:SetHidden(true)
        control:SetClampedToScreen(false)
        local fragment = ZO_SimpleSceneFragment:New(control)
        local overlay = GridOverlay:New(SHARED_OVERLAY_ID, fragment, control)
        --- @cast overlay LUIE.GridOverlay
        manager.sharedOverlay = overlay
    end
    return manager.sharedOverlay
end

local function ApplyRequesters(manager)
    local visibleAny = false
    local minSize = nil
    for requesterIdentifier, requester in pairs(manager.requesters) do
        if requester.visible and requester.size then
            visibleAny = true
            if minSize == nil or requester.size < minSize then
                minSize = requester.size
            end
        end
    end
    local sizeEffective = (visibleAny and minSize) or DEFAULT_GRID_SIZE
    local overlay = GetSharedOverlay(manager)
    if overlay then
        overlay:Refresh(visibleAny, sizeEffective)
    end
end

function GridOverlayManager:GetOverlay(identifier)
    return GetSharedOverlay(self)
end

function GridOverlayManager.Refresh(identifier, visible, size)
    local manager = GridOverlayManager
    manager.requesters[identifier] = { visible = visible, size = size or DEFAULT_GRID_SIZE }
    ApplyRequesters(manager)
end

function GridOverlayManager.SetHidden(identifier, hidden)
    local manager = GridOverlayManager
    if not manager.requesters[identifier] then
        manager.requesters[identifier] = { visible = true, size = DEFAULT_GRID_SIZE }
    end
    manager.requesters[identifier].visible = not hidden
    ApplyRequesters(manager)
end

function GridOverlayManager.Hide(identifier)
    local manager = GridOverlayManager
    if manager.requesters[identifier] then
        manager.requesters[identifier].visible = false
    end
    ApplyRequesters(manager)
end

function GridOverlayManager.HideAll()
    local manager = GridOverlayManager
    manager.requesters = {}
    local overlay = GetSharedOverlay(manager)
    if overlay then
        overlay:Hide()
    end
end

LUIE.GridOverlay = GridOverlayManager
