-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------


local eventManager = GetEventManager()

local LUIE_CallLaterId = 1337

---
--- @param callback function
--- @param minInterval integer
--- @return integer callLaterId
function LUIE_callLater(callback, minInterval)
    local id = LUIE_CallLaterId
    local name = "LUIE_CallLaterFunction" .. id
    LUIE_CallLaterId = LUIE_CallLaterId + 1

    eventManager:RegisterForPostEffectsUpdate(name, minInterval, function ()
        eventManager:UnregisterForPostEffectsUpdate(name)
        callback(id)
    end)
    return id
end

---
--- @param id integer
function LUIE_removeCallLater(id)
    eventManager:UnregisterForPostEffectsUpdate("LUIE_CallLaterFunction" .. id)
end
