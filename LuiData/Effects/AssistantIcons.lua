-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data

local Effects = Data.Effects

local GetCollectibleName = GetCollectibleName

--------------------------------------------------------------------------------------------------------------------------------
-- Icon to display for Assistant Collectibles
--------------------------------------------------------------------------------------------------------------------------------
--- @class (partial) AssistantIcons
--- @field [string] string Table mapping collectible names to their icon paths
local assistantIcons =
{
    -- Original Assistants
    [GetCollectibleName(267)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_TYTHIS_DDS,                 -- Tythis Andromo
    [GetCollectibleName(300)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_PIRHARRI_DDS,               -- Pirharri
    [GetCollectibleName(301)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_NUZHIMEH_DDS,               -- Nuzhimeh
    [GetCollectibleName(396)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_PREMIUMMERCHANT_01_DDS, -- Allaria Erwen
    [GetCollectibleName(397)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_PREMIUMBANKER_01_DDS,   -- Cassus Andronicus

    -- Banker & Merchant Assistants
    [GetCollectibleName(6376)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_EZABI_DDS,        -- Ezabi
    [GetCollectibleName(6378)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_FEZEZ_DDS,        -- Fezez
    [GetCollectibleName(8994)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_CROWBANKER_DDS,   -- Baron Jangleplume
    [GetCollectibleName(8995)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_CROWMERCHANT_DDS, -- Peddler of Prizes

    -- Factotum Assistants
    [GetCollectibleName(9743)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_FACTOTUMBANKER_DDS,   -- Factotum Property Steward
    [GetCollectibleName(9744)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_FACTOTUMMERCHANT_DDS, -- Factotum Commerce Delegate
    [GetCollectibleName(9745)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_GHRASHAROG_DDS,       -- Ghrashgarog

    -- Newer Assistants
    [GetCollectibleName(10184)] = LUIE_MEDIA_ICONS_ASSISTANTS_ASSISTANT_GILADIL_DDS,                     -- Giladil
    [GetCollectibleName(10617)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_ADERENEFARGRAVESMUGGLER_DDS, -- Aderene
    [GetCollectibleName(10618)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_ZUQOTH_DDS,                  -- Zuqoth
    [GetCollectibleName(11059)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_HOARFROST_DDS,               -- Hoarfrost
    [GetCollectibleName(11097)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_PYROCLAST_DDS,               -- Pyroclast

    -- Latest Additions
    [GetCollectibleName(11876)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_DRINWETH_VALENWOODARMORER_DDS,      -- Drinweth
    [GetCollectibleName(11877)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_TZOZABRAR_DWARVENDECONSTRUCTOR_DDS, -- Tzozabrar
    [GetCollectibleName(12413)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_ERITHEBANKER_DDS,                   -- Eri
    [GetCollectibleName(12414)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_ASSISTANT_XYNTHEMERCHANT_DDS,                 -- Xyn
    [GetCollectibleName(13063)] = LUIE_MEDIA_ICONS_NEW_ASSISTANTS_AST_SILURUZ_DDS,                              -- Siluruz
}

--- @class (partial) AssistantIcons
Effects.AssistantIcons = assistantIcons
