-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------


local eventManager = GetEventManager()

local LUIE_CallLaterId = 1

---
--- @param callback function
--- @param minInterval integer
--- @return integer callLaterId
LUIE_callLater = function (callback, minInterval)
    local id = LUIE_CallLaterId
    local name = "LUIE_CallLaterFunction" .. id
    LUIE_CallLaterId = LUIE_CallLaterId + 1

    eventManager:RegisterForUpdate(name, minInterval, function ()
        eventManager:UnregisterForUpdate(name)
        func(id)
    end)
    return id
end

---
--- @param id integer
LUIE_removeCallLater = function (id)
    eventManager:UnregisterForUpdate("LUIE_CallLaterFunction" .. id)
end
