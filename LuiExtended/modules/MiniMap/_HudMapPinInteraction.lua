-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- HUD minimap native pin mouseover lists (EsoUI/Ingame/Map/MapPin_Manager.lua BuildMouseOverPinLists).

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local hudMinimapBuildMouseOverPinListsPreHookActive --- @type function|nil

local function NoOpHudMinimapBuildMouseOverPinListsPreHook()
    return false
end

--- @return boolean
function MiniMap.ShouldHudMinimapOverrideWorldMapInput()
    return MiniMap.Enabled == true
        and MiniMap.IsNativeWorldMapContainerAttached()
        and not MiniMap.IsWorldMapBlockingMiniMapWork()
end

--- @return boolean
function MiniMap.IsPointerOverHudMinimapMap()
    local view = MiniMap.view
    local hudSceneFragment = MiniMap.hudSceneFragment
    if not view or not hudSceneFragment or not hudSceneFragment:IsShowing() then
        return false
    end
    local scroll = view.scroll
    if scroll and MouseIsOver(scroll) then
        return true
    end
    local mapControl = view.map
    if mapControl and MouseIsOver(mapControl) then
        return true
    end
    return false
end

--- Mirrors ZO_WorldMapPins_Manager:BuildMouseOverPinLists with isMouseOverWorldMap true on the HUD minimap.
--- @param pinManager ZO_WorldMapPins_Manager
--- @param cursorPositionX number
--- @param cursorPositionY number
--- @return boolean listsChanged
--- @return boolean needsContinuousTooltipUpdates
function MiniMap.BuildHudMinimapMouseOverPinLists(pinManager, cursorPositionX, cursorPositionY)
    local isMouseOverWorldMap = true

    pinManager.previousMouseOverPins, pinManager.currentMouseOverPins = pinManager.currentMouseOverPins, pinManager.previousMouseOverPins
    local currentMouseOverPins = pinManager.currentMouseOverPins

    for pin, isMousedOver in pairs(currentMouseOverPins) do
        if isMousedOver then
            currentMouseOverPins[pin] = isMouseOverWorldMap and pin:MouseIsOver(cursorPositionX, cursorPositionY)
        end
    end

    local stickyPin = ZO_WorldMap_GetStickyPin()
    stickyPin:ClearNearestCandidate()

    local pins = pinManager:GetActiveObjects()
    for _, pin in pairs(pins) do
        currentMouseOverPins[pin] = isMouseOverWorldMap and pin:MouseIsOver(cursorPositionX, cursorPositionY)
        stickyPin:ConsiderPin(pin, cursorPositionX, cursorPositionY)
    end

    stickyPin:SetStickyPinFromNearestCandidate()

    local wasPreviouslyMousedOver, doMouseEnter, doMouseExit
    local listsChanged = false
    local needsContinuousTooltipUpdates = false

    for pin, isMousedOver in pairs(currentMouseOverPins) do
        wasPreviouslyMousedOver = pinManager.previousMouseOverPins[pin]
        doMouseEnter = isMousedOver and not wasPreviouslyMousedOver
        doMouseExit = not isMousedOver and wasPreviouslyMousedOver

        pinManager.mouseExitPins[pin] = doMouseExit

        listsChanged = listsChanged or doMouseEnter or doMouseExit
        needsContinuousTooltipUpdates = needsContinuousTooltipUpdates or (isMousedOver and pin:NeedsContinuousTooltipUpdates())
    end

    return listsChanged, needsContinuousTooltipUpdates
end

--- ZO_PreHook target for UpdateMouseOverPins while the pointer is over the HUD minimap.
--- @param pinManager ZO_WorldMapPins_Manager
--- @return boolean true suppresses stock UpdateMouseOverPins
function MiniMap.HudMinimapUpdateMouseOverPinsPreHook(pinManager)
    if not MiniMap.ShouldHudMinimapOverrideWorldMapInput() or not MiniMap.IsPointerOverHudMinimapMap() then
        return false
    end
    local cursorPositionX
    local cursorPositionY
    if SCENE_MANAGER:IsCurrentSceneGamepad() then
        cursorPositionX, cursorPositionY = ZO_WorldMapScroll:GetCenter()
    else
        cursorPositionX, cursorPositionY = GetUIMousePosition()
    end
    MiniMap.BuildHudMinimapMouseOverPinLists(pinManager, cursorPositionX, cursorPositionY)
    pinManager.mousedOverPinWasReset = false
    return true
end

--- Installs ZO_PreHook on pin manager UpdateMouseOverPins (tail-call delegator; see ZO_Hook.lua).
function MiniMap.InstallHudMinimapPinInteractionPreHooks()
    if hudMinimapBuildMouseOverPinListsPreHookActive == nil then
        hudMinimapBuildMouseOverPinListsPreHookActive = MiniMap.HudMinimapUpdateMouseOverPinsPreHook
        ZO_PreHook(ZO_WorldMap_GetPinManager(), "UpdateMouseOverPins", function (pinManager)
            return hudMinimapBuildMouseOverPinListsPreHookActive(pinManager)
        end)
    else
        hudMinimapBuildMouseOverPinListsPreHookActive = MiniMap.HudMinimapUpdateMouseOverPinsPreHook
    end
end

--- Disables HUD pin interaction pre-hook without /reloadui.
function MiniMap.DisableHudMinimapPinInteractionPreHooks()
    hudMinimapBuildMouseOverPinListsPreHookActive = NoOpHudMinimapBuildMouseOverPinListsPreHook
end

--- Refreshes pin mouseover lists immediately before a click on LUIE scroll/map.
function MiniMap.FlushHudMinimapPinMouseOverForClick()
    if not MiniMap.ShouldHudMinimapOverrideWorldMapInput() or not MiniMap.IsPointerOverHudMinimapMap() then
        return
    end
    ZO_WorldMap_GetPinManager():UpdateMouseOverPins()
end

--- Throttled UpdateMouseOverPins while the pointer is over the HUD minimap (no world-map tooltips).
function MiniMap.UpdateHudMinimapPinMouseOverFromPointer()
    if not MiniMap.ShouldHudMinimapOverrideWorldMapInput() or not MiniMap.IsPointerOverHudMinimapMap() then
        return
    end
    if MiniMap.ShouldRunThrottled("HudMinimapPinMouseOver", MiniMap.GetPinMouseOverRefreshMs()) then
        ZO_WorldMap_GetPinManager():UpdateMouseOverPins()
    end
end
