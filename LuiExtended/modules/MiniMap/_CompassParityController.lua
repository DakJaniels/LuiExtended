-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- Quest breadcrumb overlays on view.pins when native g_mapPinManager pins are missing (compass parity).

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local COMPASS_PARITY_OVERLAY_PREFIX = "_CompassParity_"
local COMPASS_QUEST_PIN_TEXTURES =
{
    [MAP_PIN_TYPE_ASSISTED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
    [MAP_PIN_TYPE_ASSISTED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon_assisted.dds",
    [MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon_assisted.dds",
    [MAP_PIN_TYPE_ASSISTED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon_assisted.dds",
    [MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_CONDITION] = "EsoUI/Art/Compass/zoneStoryQuest_icon_assisted.dds",
    [MAP_PIN_TYPE_ASSISTED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/zoneStoryQuest_icon_assisted.dds",
    [MAP_PIN_TYPE_TRACKED_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
    [MAP_PIN_TYPE_TRACKED_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
    [MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon.dds",
    [MAP_PIN_TYPE_TRACKED_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon.dds",
    [MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_CONDITION] = "EsoUI/Art/Compass/zoneStoryQuest_icon.dds",
    [MAP_PIN_TYPE_TRACKED_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/zoneStoryQuest_icon.dds",
    [MAP_PIN_TYPE_QUEST_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
    [MAP_PIN_TYPE_QUEST_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/quest_icon.dds",
    [MAP_PIN_TYPE_QUEST_REPEATABLE_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon.dds",
    [MAP_PIN_TYPE_QUEST_REPEATABLE_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/repeatableQuest_icon.dds",
    [MAP_PIN_TYPE_QUEST_ZONE_STORY_CONDITION] = "EsoUI/Art/Compass/zoneStoryQuest_icon.dds",
    [MAP_PIN_TYPE_QUEST_ZONE_STORY_OPTIONAL_CONDITION] = "EsoUI/Art/Compass/zoneStoryQuest_icon.dds",
}

--- @class MiniMapCompassParityController : ZO_InitializingObject
--- @field pinController MiniMapPinController
--- @field mapController MiniMapMapController
--- @field activeOverlayKeys table<string, boolean>
local MiniMapCompassParityController = ZO_InitializingObject:Subclass()
MiniMap.MiniMapCompassParityController = MiniMapCompassParityController

--- @param pinController MiniMapPinController
--- @param mapController MiniMapMapController
function MiniMapCompassParityController:Initialize(pinController, mapController)
    self.pinController = pinController
    self.mapController = mapController
    self.activeOverlayKeys = {}
end

--- @param pinType MapPinType
--- @return string
function MiniMapCompassParityController:GetQuestPinTexture(pinType)
    local texture = COMPASS_QUEST_PIN_TEXTURES[pinType]
    if texture then
        return texture
    end
    local staticTexture = ZO_MapPin.GetStaticPinTexture(pinType)
    if staticTexture and staticTexture ~= "" then
        return staticTexture
    end
    return "EsoUI/Art/Compass/quest_icon.dds"
end

--- @param pinManager ZO_WorldMapPins_Manager
--- @param questIndex integer
--- @param stepIndex integer
--- @param conditionIndex integer
--- @param pinType MapPinType
--- @return boolean
function MiniMapCompassParityController:HasVisibleNativeQuestPin(pinManager, questIndex, stepIndex, conditionIndex, pinType)
    local keysByTag = pinManager.m_keyToPinMapping.quest[questIndex]
    if not keysByTag then
        return false
    end
    for tag, pinKey in pairs(keysByTag) do
        if type(tag) == "table" then
            local tagQuestIndex = tag[1]
            local tagConditionIndex = tag[2]
            local tagStepIndex = tag[3]
            if tagQuestIndex == questIndex and tagStepIndex == stepIndex and tagConditionIndex == conditionIndex then
                local mapPin = pinManager:GetActiveObject(pinKey)
                if mapPin and mapPin:GetPinType() == pinType then
                    local pinControl = mapPin:GetControl()
                    if pinControl and not pinControl:IsHidden() then
                        return true
                    end
                end
            end
        end
    end
    return false
end

--- @param questIndex integer
--- @param stepIndex integer
--- @param conditionIndex integer
--- @param suffix string
--- @return string
function MiniMapCompassParityController:GetOverlayObjectKey(questIndex, stepIndex, conditionIndex, suffix)
    return string.format("%sQuest_%d_%d_%d%s", COMPASS_PARITY_OVERLAY_PREFIX, questIndex, stepIndex, conditionIndex, suffix)
end

--- @param questIndex integer
--- @param stepIndex integer
--- @param conditionIndex integer
--- @param pinType MapPinType
--- @param normalizedX number
--- @param normalizedY number
--- @param objectKey string
--- @param mapData MiniMapMapData
--- @param activeOverlayKeys table<string, boolean>
function MiniMapCompassParityController:PlaceQuestOverlayIfNeeded(
    questIndex,
    stepIndex,
    conditionIndex,
    pinType,
    normalizedX,
    normalizedY,
    objectKey,
    mapData,
    activeOverlayKeys
)
    if not normalizedX or not normalizedY or normalizedX <= 0 or normalizedY <= 0 then
        return
    end
    if not ZO_WorldMap_IsNormalizedPointInsideMapBounds(normalizedX, normalizedY) then
        return
    end

    local pinManager = ZO_WorldMap_GetPinManager()
    if self:HasVisibleNativeQuestPin(pinManager, questIndex, stepIndex, conditionIndex, pinType) then
        return
    end

    local pinController = self.pinController
    local pin = pinController:AcquireOverlayPin(objectKey)
    if not pin then
        return
    end

    activeOverlayKeys[objectKey] = true
    local pinsParent = pinController.view.pins
    local pinX, pinY = pinController:GetMapPinOffsets(mapData, normalizedX, normalizedY)
    local baseSize = 32
    local drawWidth, drawHeight = pinController:GetPinDimensions(baseSize, baseSize, false, pinType)
    local pinTexture = self:GetQuestPinTexture(pinType)

    pinController:ApplyOverlayPinAppearance(pin, pinTexture, drawWidth, drawHeight, { r = 1, g = 1, b = 1 })
    pin:ClearAnchors()
    pin:SetAnchor(CENTER, pinsParent, TOPLEFT, pinX, pinY)
    pin:SetDrawLayer(DL_OVERLAY)
    pin.zoneName = mapData.rawName
    pinController:SetOverlayPinLayoutMetadata(pin, normalizedX, normalizedY, baseSize, baseSize, false, pinType)
end

--- @param questIndex integer
--- @param conditionData table
--- @param stepIndex integer
--- @param conditionIndex integer
--- @param mapData MiniMapMapData
--- @param activeOverlayKeys table<string, boolean>
function MiniMapCompassParityController:TryQuestConditionOverlays(
    questIndex,
    conditionData,
    stepIndex,
    conditionIndex,
    mapData,
    activeOverlayKeys
)
    local pinType = conditionData.pinType
    if not pinType then
        return
    end

    local pinManager = ZO_WorldMap_GetPinManager()
    local isGlobalMap = ZO_WorldMapPins_Manager.IsCurrentMapGlobal()
    local forceHudQuestPins = MiniMap.SV and MiniMap.SV.forceQuestPinsOnMinimap == true

    local xLoc, yLoc = conditionData.xLoc, conditionData.yLoc
    local insideWorld = conditionData.insideCurrentMapWorld == true
    local nativeWouldPlace = insideWorld
        and ZO_WorldMap_IsNormalizedPointInsideMapBounds(xLoc, yLoc)
        and (forceHudQuestPins or MiniMap.IsQuestPinGroupShownOnHud())
    if nativeWouldPlace and isGlobalMap then
        nativeWouldPlace = FOCUSED_QUEST_TRACKER:IsOnTracker(TRACK_TYPE_QUEST, questIndex) and not IsZoneStoryAssisted()
    end

    if nativeWouldPlace then
        if self:HasVisibleNativeQuestPin(pinManager, questIndex, stepIndex, conditionIndex, pinType) then
            return
        end
    end

    local overlayAllowed = forceHudQuestPins or MiniMap.IsQuestPinGroupShownOnHud()
    if not overlayAllowed then
        return
    end

    if xLoc and yLoc and ZO_WorldMap_IsNormalizedPointInsideMapBounds(xLoc, yLoc) then
        local objectKey = self:GetOverlayObjectKey(questIndex, stepIndex, conditionIndex, "")
        self:PlaceQuestOverlayIfNeeded(questIndex, stepIndex, conditionIndex, pinType, xLoc, yLoc, objectKey, mapData, activeOverlayKeys)
    end

    if conditionData.symbolicState == QUEST_PIN_STATE_HAS_ADDITIONAL_SYMBOLIC_POSITION then
        local additionalX = conditionData.additionalSymbolicLocX
        local additionalY = conditionData.additionalSymbolicLocY
        if additionalX and additionalY and ZO_WorldMap_IsNormalizedPointInsideMapBounds(additionalX, additionalY) then
            local objectKey = self:GetOverlayObjectKey(questIndex, stepIndex, conditionIndex, "_Addl")
            self:PlaceQuestOverlayIfNeeded(questIndex, stepIndex, conditionIndex, pinType, additionalX, additionalY, objectKey, mapData, activeOverlayKeys)
        end
    end
end

function MiniMapCompassParityController:ReleaseStaleCompassParityOverlays(activeOverlayKeys)
    local pinController = self.pinController
    for objectKey in pairs(self.activeOverlayKeys) do
        if not activeOverlayKeys[objectKey] then
            pinController:ReleaseOverlayPin(objectKey)
        end
    end
    self.activeOverlayKeys = activeOverlayKeys
end

--- @param mapData MiniMapMapData
function MiniMapCompassParityController:SyncQuestBreadcrumbOverlays(mapData)
    if not MiniMap.SV or MiniMap.SV.showCompassParityPins ~= true then
        self:ReleaseAllCompassParityOverlays()
        return
    end
    local activeOverlayKeys = {}
    for questIndex in pairs(WORLD_MAP_QUEST_BREADCRUMBS.activeQuests) do
        local questSteps = WORLD_MAP_QUEST_BREADCRUMBS:GetSteps(questIndex)
        if questSteps then
            for stepIndex, questConditions in pairs(questSteps) do
                for conditionIndex, conditionData in pairs(questConditions) do
                    self:TryQuestConditionOverlays(questIndex, conditionData, stepIndex, conditionIndex, mapData, activeOverlayKeys)
                end
            end
        end
    end

    self:ReleaseStaleCompassParityOverlays(activeOverlayKeys)
end

function MiniMapCompassParityController:ReleaseAllCompassParityOverlays()
    local pinController = self.pinController
    for objectKey in pairs(self.activeOverlayKeys) do
        pinController:ReleaseOverlayPin(objectKey)
    end
    self.activeOverlayKeys = {}
end
