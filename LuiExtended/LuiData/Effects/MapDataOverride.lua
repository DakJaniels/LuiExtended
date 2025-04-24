-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
local Effects = Data.Effects
local ZoneNames = Data.ZoneNames

--- @class (partial) MapDataOverride
--- @field [integer] { [string]: { icon: string, name: string, hide: boolean } } # Maps ability IDs to zone-specific icon overrides
local mapDataOverride =
{
    [70355] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = "LuiExtended/media/icons/abilities/ability_bear_bite_w.dds" } },               -- Bite (Great Bear)
    [70357] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = "LuiExtended/media/icons/abilities/ability_bear_lunge_white.dds" } },          -- Lunge (Great Bear)
    [70359] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = "LuiExtended/media/icons/abilities/ability_bear_lunge_white.dds" } },          -- Lunge (Great Bear)
    [70366] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = "LuiExtended/media/icons/abilities/ability_bear_crushing_swipe_white.dds" } }, -- Slam (Great Bear)
    [89189] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = "LuiExtended/media/icons/abilities/ability_bear_crushing_swipe_white.dds" } }, -- Slam (Great Bear)
    [69073] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = "LuiExtended/media/icons/abilities/ability_bear_crushing_swipe_white.dds" } }, -- Knockdown (Great Bear)
    [70374] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = "LuiExtended/media/icons/abilities/ability_bear_ferocity_white.dds" } },       -- Ferocity (Great Bear)
}

--- @class (partial) MapDataOverride
Effects.MapDataOverride = mapDataOverride
