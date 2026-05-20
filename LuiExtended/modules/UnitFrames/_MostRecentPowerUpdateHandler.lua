-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local moduleName = UnitFrames.moduleName

--- Registers coalesced EVENT_POWER_UPDATE handling (separate namespace from vanilla UnitFrames).
function UnitFrames.RegisterRecentEventHandler()
    if UnitFrames.powerUpdateRecentHandler then
        return
    end
    --- @param unitTag string
    --- @param powerIndex luaindex
    --- @param powerType CombatMechanicFlags
    --- @param powerValue integer
    --- @param powerMax integer
    --- @param powerEffectiveMax integer
    local function MostRecentPowerUpdateHandlerFunction(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
        UnitFrames.OnPowerUpdate(unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    end
    UnitFrames.powerUpdateRecentHandler = ZO_MostRecentPowerUpdateHandler:New(moduleName, MostRecentPowerUpdateHandlerFunction)
end
