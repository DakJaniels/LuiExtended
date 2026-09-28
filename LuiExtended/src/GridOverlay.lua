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
local eventManager = GetEventManager()
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
    line:SetThickness("1px")
    line:SetPixelRoundingEnabled(true)
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
    local canvasWidth, canvasHeight = self.control:GetDimensions()
    canvasWidth = canvasWidth or 0
    canvasHeight = canvasHeight or 0
    local layoutOffsetZero = LUIE.FormatUiLayoutMeasurement(0)

    local verticalLineCount = zo_floor(canvasWidth / gridSize)
    for lineIndex = 0, verticalLineCount do
        local offsetX = zo_round(lineIndex * gridSize)
        local layoutOffsetX = LUIE.FormatUiLayoutMeasurement(offsetX)
        local line = self:AcquireLine(self.verticalPool, lineIndex)
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, self.control, TOPLEFT, layoutOffsetX, layoutOffsetZero)
        line:SetAnchor(BOTTOMLEFT, self.control, BOTTOMLEFT, layoutOffsetX, layoutOffsetZero)
    end
    self:ReleaseUnused(self.verticalPool, verticalLineCount)

    local horizontalLineCount = zo_floor(canvasHeight / gridSize)
    for lineIndex = 0, horizontalLineCount do
        local offsetY = zo_round(lineIndex * gridSize)
        local layoutOffsetY = LUIE.FormatUiLayoutMeasurement(offsetY)
        local line = self:AcquireLine(self.horizontalPool, lineIndex)
        line:ClearAnchors()
        line:SetAnchor(TOPLEFT, self.control, TOPLEFT, layoutOffsetZero, layoutOffsetY)
        line:SetAnchor(TOPRIGHT, self.control, TOPRIGHT, layoutOffsetZero, layoutOffsetY)
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

-- Saved preview offsets are UI units on the canvas that was active when they were stored.
-- Custom scale changes how many UI units fit on screen, so the same 1620,200 is a different point after the toggle.
local CANVAS_RATIO_EPSILON = 0.001
local UI_SCALE_REFRESH_DELAY_MS = 50
local uiScaleRefreshGeneration = 0
local cachedCanvasWidth = 0
local cachedCanvasHeight = 0

local BUFF_PREVIEW_OFFSET_KEYS =
{
    { "playerbOffsetX", "playerbOffsetY" },
    { "playerdOffsetX", "playerdOffsetY" },
    { "targetbOffsetX", "targetbOffsetY" },
    { "targetdOffsetX", "targetdOffsetY" },
    { "player_longOffsetX", "player_longOffsetY" },
    { "prominentbVOffsetX", "prominentbVOffsetY" },
    { "prominentbHOffsetX", "prominentbHOffsetY" },
    { "prominentdVOffsetX", "prominentdVOffsetY" },
    { "prominentdHOffsetX", "prominentdHOffsetY" },
}

local function TranslatePreviewCoordinate(coordinate, canvasRatio)
    return zo_round(coordinate * canvasRatio)
end

local function TranslateUnitFramePreviewPositions(canvasRatioX, canvasRatioY)
    local unitFrames = LUIE.UnitFrames
    local customFramesShared = LUIE.CustomFramesShared
    if not unitFrames or not unitFrames.SV or not unitFrames.CustomFrames or not customFramesShared then
        return
    end
    local registryKeys = customFramesShared.MOVER_ANCHOR_REGISTRY_KEYS
    if not registryKeys then
        return
    end
    for keyIndex = 1, #registryKeys do
        local unitTag = registryKeys[keyIndex]
        local customFrame = unitFrames.CustomFrames[unitTag]
        if customFrame and customFrame.tlw and customFrame.tlw.customPositionAttr then
            local savedPosition = unitFrames.SV[customFrame.tlw.customPositionAttr]
            if type(savedPosition) == "table" and savedPosition[1] and savedPosition[2] then
                local translatedLeft = TranslatePreviewCoordinate(savedPosition[1], canvasRatioX)
                local translatedTop = TranslatePreviewCoordinate(savedPosition[2], canvasRatioY)
                translatedLeft, translatedTop = LUIE.ApplyGridSnap(translatedLeft, translatedTop, "unitFrames")
                unitFrames.SV[customFrame.tlw.customPositionAttr] = { translatedLeft, translatedTop }
            end
        end
    end
end

local function TranslateBuffPreviewPositions(canvasRatioX, canvasRatioY)
    local spellCastBuffs = LUIE.SpellCastBuffs
    if not spellCastBuffs or not spellCastBuffs.SV then
        return
    end
    local savedVariables = spellCastBuffs.SV
    for keyIndex = 1, #BUFF_PREVIEW_OFFSET_KEYS do
        local offsetKeys = BUFF_PREVIEW_OFFSET_KEYS[keyIndex]
        local savedOffsetX = savedVariables[offsetKeys[1]]
        local savedOffsetY = savedVariables[offsetKeys[2]]
        if type(savedOffsetX) == "number" and type(savedOffsetY) == "number" then
            local translatedLeft = TranslatePreviewCoordinate(savedOffsetX, canvasRatioX)
            local translatedTop = TranslatePreviewCoordinate(savedOffsetY, canvasRatioY)
            translatedLeft, translatedTop = LUIE.ApplyGridSnap(translatedLeft, translatedTop, "buffs")
            savedVariables[offsetKeys[1]] = translatedLeft
            savedVariables[offsetKeys[2]] = translatedTop
        end
    end
end

local function ApplyTranslatedPreviewAnchors()
    if GridOverlayManager.sharedOverlay then
        ApplyRequesters(GridOverlayManager)
    end
    local unitFrames = LUIE.UnitFrames
    if unitFrames and unitFrames.SV and unitFrames.CustomFrames and unitFrames.CustomFramesSetPositions then
        unitFrames.CustomFramesSetPositions()
    end
    local spellCastBuffs = LUIE.SpellCastBuffs
    if spellCastBuffs and spellCastBuffs.SV and spellCastBuffs.BuffContainers and spellCastBuffs.SetTlwPosition then
        spellCastBuffs.SetTlwPosition()
    end
end

--- Keep a preview's fraction of the screen when custom scale changes the UI canvas, then snap in that new space.
local function TranslatePreviewPositionsForCanvasChange()
    local canvasWidth, canvasHeight = GuiRoot:GetDimensions()
    if not canvasWidth or canvasWidth <= 0 or not canvasHeight or canvasHeight <= 0 then
        return
    end
    if cachedCanvasWidth > 0 and cachedCanvasHeight > 0 then
        local canvasRatioX = canvasWidth / cachedCanvasWidth
        local canvasRatioY = canvasHeight / cachedCanvasHeight
        if zo_abs(canvasRatioX - 1) > CANVAS_RATIO_EPSILON or zo_abs(canvasRatioY - 1) > CANVAS_RATIO_EPSILON then
            TranslateUnitFramePreviewPositions(canvasRatioX, canvasRatioY)
            TranslateBuffPreviewPositions(canvasRatioX, canvasRatioY)
        end
    end
    cachedCanvasWidth = canvasWidth
    cachedCanvasHeight = canvasHeight
    ApplyTranslatedPreviewAnchors()
end

local function ScheduleTranslatePreviewPositionsForCanvasChange()
    uiScaleRefreshGeneration = uiScaleRefreshGeneration + 1
    local scheduledGeneration = uiScaleRefreshGeneration
    zo_callLater(function ()
        if scheduledGeneration ~= uiScaleRefreshGeneration then
            return
        end
        TranslatePreviewPositionsForCanvasChange()
    end, UI_SCALE_REFRESH_DELAY_MS)
end

local GRID_OVERLAY_UI_SCALE_EVENT = "LUIE_GridOverlay_UIScale"
eventManager:RegisterForEvent(GRID_OVERLAY_UI_SCALE_EVENT, EVENT_INTERFACE_SETTING_CHANGED, function (_, settingSystemType, settingId)
    if settingSystemType ~= SETTING_TYPE_UI then
        return
    end
    if settingId == UI_SETTING_USE_CUSTOM_SCALE or settingId == UI_SETTING_CUSTOM_SCALE then
        ScheduleTranslatePreviewPositionsForCanvasChange()
    end
end)
eventManager:RegisterForEvent(GRID_OVERLAY_UI_SCALE_EVENT, EVENT_SCREEN_RESIZED, function ()
    TranslatePreviewPositionsForCanvasChange()
end)
