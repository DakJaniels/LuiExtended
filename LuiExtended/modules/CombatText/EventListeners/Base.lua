-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextEventListener : ZO_InitializingObject
LUIE.CombatTextEventListener = ZO_InitializingObject:Subclass()

--- @class (partial) LuiExtended.CombatTextEventListener
local CombatTextEventListener = LUIE.CombatTextEventListener

local callbackManager = CALLBACK_MANAGER
local eventManager = EVENT_MANAGER

local moduleName = LUIE.name .. "CombatText"

--- @type integer
local eventPostfix = 1 -- Used to create unique name when registering multiple times to the same game event

--- @return LuiExtended.CombatTextEventListener
function CombatTextEventListener:New()
    local obj = setmetatable({}, self)
    return obj
end

--- @param event any
--- @param func fun(...)
--- @param ... any
function CombatTextEventListener:RegisterForEvent(event, func, ...)
    eventManager:RegisterForEvent(moduleName .. "Event" .. tostring(event) .. "_" .. eventPostfix, event, function (eventCode, ...) func(...) end)

    --- @type any[]
    local filters = { ... }
    local filtersCount = select("#", ...)
    if filtersCount > 0 then
        for i = 1, filtersCount, 2 do
            eventManager:AddFilterForEvent(moduleName .. "Event" .. tostring(event) .. "_" .. eventPostfix, event, filters[i], filters[i + 1])
        end
    end

    eventPostfix = eventPostfix + 1
end

--- @param name any
--- @param timer any
--- @param func fun(...)
--- @param ... any
function CombatTextEventListener:RegisterForUpdate(name, timer, func, ...)
    eventManager:RegisterForUpdate(moduleName .. "Event" .. tostring(name) .. "_" .. eventPostfix, timer, func)
end

--- @param ... any
function CombatTextEventListener:TriggerEvent(...)
    callbackManager:FireCallbacks(...)
end
