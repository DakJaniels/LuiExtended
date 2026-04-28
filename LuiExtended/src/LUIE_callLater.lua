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

    local DO_ONCE = true
    eventManager:RegisterForPostEffectsUpdate(name, minInterval, function ()
                                                  callback(id)
                                              end, DO_ONCE)
    return id
end

---
--- @param id integer
LUIE_removeCallLater = function (id)
    eventManager:UnregisterForPostEffectsUpdate("LUIE_CallLaterFunction" .. id)
end
