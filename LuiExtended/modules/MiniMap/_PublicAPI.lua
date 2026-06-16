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
    return MiniMap.Enabled == true and LUIE.SV and LUIE.SV.MiniMap_Enabled == true
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

--- @param pinType MapPinType
--- @return number
function MiniMap.GetPinTypeScaleMultiplier(pinType)
    local settings = MiniMap.SV or MiniMap.Defaults
    local baseScale = settings.defaultPinScale or 1
    if pinType and settings.pinTypeScales and settings.pinTypeScales[pinType] then
        return baseScale * settings.pinTypeScales[pinType]
    end
    if pinType then
        local pinGroup = ZO_MapPin.PIN_TYPE_TO_PIN_GROUP[pinType]
        if pinGroup == MAP_FILTER_QUESTS and settings.pinScaleQuest then
            return baseScale * settings.pinScaleQuest
        end
        if pinGroup == MAP_FILTER_GROUP_MEMBERS and settings.pinScaleGroup then
            return baseScale * settings.pinScaleGroup
        end
        if pinGroup == MAP_FILTER_WAYSHRINES and settings.pinScaleWayshrine then
            return baseScale * settings.pinScaleWayshrine
        end
        if pinGroup == MAP_FILTER_OBJECTIVES and settings.pinScalePoi then
            return baseScale * settings.pinScalePoi
        end
        if pinGroup == MAP_FILTER_DIG_SITES and settings.pinScaleDigSite then
            return baseScale * settings.pinScaleDigSite
        end
    end
    if settings.pinScaleOther then
        return baseScale * settings.pinScaleOther
    end
    return baseScale
end
