-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) CombatTextEventListener : ZO_InitializingCallbackObject
local CombatTextEventListener = ZO_InitializingCallbackObject:Subclass()


local eventManager = EVENT_MANAGER

local moduleName = LUIE.name .. "CombatText"

--- @type integer
local eventPostfix = 1 -- Used to create unique name when registering multiple times to the same game event

--- Initialize event listener with callback support<br>
--- ZO_InitializingCallbackObject automatically handles callback registry setup
function CombatTextEventListener:Initialize(...)
    -- Base class initialization (no need to manually call ZO_CallbackObject.Initialize)
end

--- @param event any
--- @param func fun(...) Receives only event-specific arguments; the wrapper strips `eventCode`.
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

--- Fire a callback event to all registered listeners<br>
--- Uses instance-based callback system instead of global CALLBACK_MANAGER
--- @param ... any Event type and arguments to pass to callbacks
function CombatTextEventListener:TriggerEvent(...)
    self:FireCallbacks(...)
end

--- @class (partial) LuiExtended.CombatTextEventListener : CombatTextEventListener
LUIE.CombatTextEventListener = CombatTextEventListener:Subclass()
