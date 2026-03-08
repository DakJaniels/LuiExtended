-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects
local ZoneNames = Data.ZoneNames

--- @class (partial) MapDataOverride
--- @field [integer] { [string]: { icon: string, name: string, hide: boolean } } # Maps ability IDs to zone-specific icon overrides
local mapDataOverride =
{
    [70355] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_BITE_W_DDS } },               -- Bite (Great Bear)
    [70357] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_LUNGE_WHITE_DDS } },          -- Lunge (Great Bear)
    [70359] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_LUNGE_WHITE_DDS } },          -- Lunge (Great Bear)
    [70366] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_CRUSHING_SWIPE_WHITE_DDS } }, -- Slam (Great Bear)
    [89189] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_CRUSHING_SWIPE_WHITE_DDS } }, -- Slam (Great Bear)
    [69073] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_CRUSHING_SWIPE_WHITE_DDS } }, -- Knockdown (Great Bear)
    [70374] = { [ZoneNames.Zone_Deepwood_Barrow] = { icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_BEAR_FEROCITY_WHITE_DDS } },       -- Ferocity (Great Bear)
}

--- @class (partial) MapDataOverride
Effects.MapDataOverride = mapDataOverride
