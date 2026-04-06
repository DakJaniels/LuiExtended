-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

--------------------------------------------------------------------------------------------------------------------------------
-- EFFECTS TABLE FOR BAR HIGHLIGHT RELATED OVERRIDES
--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------
-- When a bar ability proc with a matching id appears, change the icon.
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) BarIdOverride
local barIdOverride =
{
    -- Dragonknight
    [20824] = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_DRAGONKNIGHT_POWER_LASH_DDS, -- Power Lash (Flame Lash)

    -- Nightblade
    [35445] = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_NIGHTBLADE_SHADOW_IMAGE_TELEPORT_DDS, -- Shadow Image Teleport (Shadow Image)

    -- Dual Wield
    [126659] = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_WEAPON_FLYING_BLADE_JUMP_DDS, -- Flying Blade (Flying Blade)

    -- Sorcerer
    [108840] = "/esoui/art/icons/ability_sorcerer_unstable_fimiliar_summoned.dds", -- Summon Unstable Familiar (Summon Unstable Familiar)
    [108845] = "/esoui/art/icons/ability_sorcerer_lightning_prey_summoned.dds",    -- Winged Twilight Restore (Summon Winged Twilight)

    -- Support
    [78338] = "/esoui/art/icons/ability_warrior_001.dds", -- Guard (Guard)
    [81415] = "/esoui/art/icons/ability_warrior_001.dds", -- Mystic Guard (Mystic Guard)
    [81420] = "/esoui/art/icons/ability_warrior_001.dds", -- Stalwart Guard (Stalwart Guard)
}

--- @class (partial) BarIdOverride
Effects.BarIdOverride = barIdOverride
