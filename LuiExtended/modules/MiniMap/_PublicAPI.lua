-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

--- Exported map mode id for third-party integration.
MiniMap.MAP_MODE_LUIE_MINIMAP = 42

--- @return boolean
function MiniMap.IsModuleEnabled()
    return MiniMap.Enabled == true and LUIE.SV.MiniMap_Enabled == true
end

--- @return number
function MiniMap.GetZoom()
    return MiniMap.zoom
end

function MiniMap.RequestPinResync()
    if MiniMap.mapEventController then
        MiniMap.mapEventController:SchedulePinSync()
    end
end

function MiniMap.RegisterPinResyncCallback(callback)
    MiniMap.pinResyncCallbacks = MiniMap.pinResyncCallbacks or {}
    MiniMap.pinResyncCallbacks[#MiniMap.pinResyncCallbacks + 1] = callback
end

function MiniMap.FirePinResyncCallbacks()
    local callbacks = MiniMap.pinResyncCallbacks
    if not callbacks then
        return
    end
    for callbackIndex = 1, #callbacks do
        callbacks[callbackIndex]()
    end
end

local PIN_FILTER_GROUP_TO_SCALE_SETTING_KEY =
{
    [MAP_FILTER_QUESTS] = "pinScaleQuest",
    [MAP_FILTER_GROUP_MEMBERS] = "pinScaleGroup",
    [MAP_FILTER_WAYSHRINES] = "pinScaleWayshrine",
    [MAP_FILTER_OBJECTIVES] = "pinScalePoi",
    [MAP_FILTER_DIG_SITES] = "pinScaleDigSite",
}

--- @param pinGroup integer|nil
--- @param settings MiniMapDefaults
--- @return number|nil categoryScale when pinGroup matches a LAM category
function MiniMap.GetPinCategoryScaleForFilterGroup(pinGroup, settings)
    if not pinGroup or not settings then
        return nil
    end
    local scaleSettingKey = PIN_FILTER_GROUP_TO_SCALE_SETTING_KEY[pinGroup]
    return scaleSettingKey and settings[scaleSettingKey]
end

--- @param pinType MapDisplayPinType|nil
--- @return number
function MiniMap.GetPinTypeScaleMultiplier(pinType)
    local settings = MiniMap.SV
    local baseScale = settings.defaultPinScale or 1
    if pinType and settings.pinTypeScales and settings.pinTypeScales[pinType] then
        return baseScale * settings.pinTypeScales[pinType]
    end
    if pinType then
        local pinGroup = ZO_MapPin.PIN_TYPE_TO_PIN_GROUP[pinType]
        local categoryScale = MiniMap.GetPinCategoryScaleForFilterGroup(pinGroup, settings)
        if categoryScale then
            return baseScale * categoryScale
        end
    end
    if settings.pinScaleOther then
        return baseScale * settings.pinScaleOther
    end
    return baseScale
end
