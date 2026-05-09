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

-- LuiExtended custom most recent power update handler for power updates
-- This does NOT touch the base game's ZO_MostRecentPowerUpdateHandler
--- @class LUIE.UnitFrames.MostRecentEventHandler : ZO_MostRecentEventHandler
UnitFrames.MostRecentEventHandler = ZO_MostRecentEventHandler:Subclass()

local function LUIE_PowerUpdateEqualityFunction(existingEventInfo, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    local existingUnitTag = existingEventInfo[1]
    local existingPowerType = existingEventInfo[3]
    return existingUnitTag == unitTag and existingPowerType == powerType
end

function UnitFrames.MostRecentEventHandler:New(namespace, handlerFunction)
    return ZO_MostRecentEventHandler.New(self, namespace, EVENT_POWER_UPDATE, LUIE_PowerUpdateEqualityFunction, handlerFunction)
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

function UnitFrames.RegisterRecentEventHandler()
    UnitFrames.MostRecentEventHandler:New(moduleName, MostRecentPowerUpdateHandlerFunction)
end
