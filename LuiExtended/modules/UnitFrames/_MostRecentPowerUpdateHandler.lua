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

-- Unit tag families OnPowerUpdate serves (savedHealth + frame tables). One handler per family because each
-- ZO_MostRecentEventHandler owns a single namespace / filter set (ZOS BossBar.lua pattern).
local POWER_UPDATE_UNIT_TAG_FILTERS =
{
    { filterType = REGISTER_FILTER_UNIT_TAG_PREFIX, filterValue = "player" }, -- player + playerpetN
    { filterType = REGISTER_FILTER_UNIT_TAG, filterValue = "reticleover" },
    { filterType = REGISTER_FILTER_UNIT_TAG_PREFIX, filterValue = "group" },  -- groupN + groupNcompanion
    { filterType = REGISTER_FILTER_UNIT_TAG_PREFIX, filterValue = "boss" },
    { filterType = REGISTER_FILTER_UNIT_TAG, filterValue = "companion" },
    { filterType = REGISTER_FILTER_UNIT_TAG, filterValue = "controlledsiege" },
}

--- Registers coalesced EVENT_POWER_UPDATE handling (separate namespaces from vanilla UnitFrames).
function UnitFrames.RegisterRecentEventHandler()
    if UnitFrames.powerUpdateRecentHandlers then
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
    local handlers = {}
    for _, unitTagFilter in ipairs(POWER_UPDATE_UNIT_TAG_FILTERS) do
        local handler = ZO_MostRecentPowerUpdateHandler:New(moduleName .. "_PowerUpdate_" .. unitTagFilter.filterValue, MostRecentPowerUpdateHandlerFunction)
        handler:AddFilterForEvent(unitTagFilter.filterType, unitTagFilter.filterValue)
        handlers[#handlers + 1] = handler
    end
    UnitFrames.powerUpdateRecentHandlers = handlers
end
