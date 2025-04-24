-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local ACTION_RESULT_BEGIN = ACTION_RESULT_BEGIN
local LUIE_CC_TYPE_STUN = LUIE_CC_TYPE_STUN
local LUIE_ALERT_SOUND_TYPE_ST_CC = LUIE_ALERT_SOUND_TYPE_ST_CC

--- @class (partial) ZoneTable
local zoneTable =
{

    [63157] = { block = true, dodge = true, priority = 2, bs = true, result = ACTION_RESULT_BEGIN, duration = 1500, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_ST_CC },                        -- Heavy Blow (Justice Guard 1H)
    [63261] = { block = true, dodge = true, priority = 2, bs = true, result = ACTION_RESULT_BEGIN, duration = 1250, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_ST_CC },                        -- Heavy Blow (Justice Guard 2H)
    [63179] = { block = true, dodge = true, interrupt = true, reflect = true, priority = 2, result = ACTION_RESULT_BEGIN, duration = 1000, cc = LUIE_CC_TYPE_STUN, sound = LUIE_ALERT_SOUND_TYPE_ST_CC }, -- Flame Shard (Justice Guard 2H)
}

--- @class (partial) ZoneTable
Data.ZoneTable = zoneTable
