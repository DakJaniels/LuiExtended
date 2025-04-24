-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiData
local LuiData = LuiData

local Data = LuiData.Data
--- @class (partial) Effects
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
    [GetCollectibleName(267)] = "LuiExtended/media/icons/assistants/assistant_tythis.dds",                 -- Tythis Andromo
    [GetCollectibleName(300)] = "LuiExtended/media/icons/assistants/assistant_pirharri.dds",               -- Pirharri
    [GetCollectibleName(301)] = "LuiExtended/media/icons/assistants/assistant_nuzhimeh.dds",               -- Nuzhimeh
    [GetCollectibleName(396)] = "LuiExtended/media/icons/new_assistants/assistant_premiummerchant_01.dds", -- Allaria Erwen
    [GetCollectibleName(397)] = "LuiExtended/media/icons/new_assistants/assistant_premiumbanker_01.dds",   -- Cassus Andronicus

    -- Banker & Merchant Assistants
    [GetCollectibleName(6376)] = "LuiExtended/media/icons/assistants/assistant_ezabi.dds",        -- Ezabi
    [GetCollectibleName(6378)] = "LuiExtended/media/icons/assistants/assistant_fezez.dds",        -- Fezez
    [GetCollectibleName(8994)] = "LuiExtended/media/icons/assistants/assistant_crowbanker.dds",   -- Baron Jangleplume
    [GetCollectibleName(8995)] = "LuiExtended/media/icons/assistants/assistant_crowmerchant.dds", -- Peddler of Prizes

    -- Factotum Assistants
    [GetCollectibleName(9743)] = "LuiExtended/media/icons/assistants/assistant_factotumbanker.dds",   -- Factotum Property Steward
    [GetCollectibleName(9744)] = "LuiExtended/media/icons/assistants/assistant_factotummerchant.dds", -- Factotum Commerce Delegate
    [GetCollectibleName(9745)] = "LuiExtended/media/icons/assistants/assistant_ghrasharog.dds",       -- Ghrashgarog

    -- Newer Assistants
    [GetCollectibleName(10184)] = "LuiExtended/media/icons/assistants/assistant_giladil.dds",                     -- Giladil
    [GetCollectibleName(10617)] = "LuiExtended/media/icons/new_assistants/assistant_aderenefargravesmuggler.dds", -- Aderene
    [GetCollectibleName(10618)] = "LuiExtended/media/icons/new_assistants/assistant_zuqoth.dds",                  -- Zuqoth
    [GetCollectibleName(11059)] = "LuiExtended/media/icons/new_assistants/assistant_hoarfrost.dds",               -- Hoarfrost
    [GetCollectibleName(11097)] = "LuiExtended/media/icons/new_assistants/assistant_pyroclast.dds",               -- Pyroclast

    -- Latest Additions
    [GetCollectibleName(11876)] = "LuiExtended/media/icons/new_assistants/assistant_drinweth_valenwoodarmorer.dds",      -- Drinweth
    [GetCollectibleName(11877)] = "LuiExtended/media/icons/new_assistants/assistant_tzozabrar_dwarvendeconstructor.dds", -- Tzozabrar
    [GetCollectibleName(12413)] = "LuiExtended/media/icons/new_assistants/assistant_erithebanker.dds",                   -- Eri
    [GetCollectibleName(12414)] = "LuiExtended/media/icons/new_assistants/assistant_xynthemerchant.dds",                 -- Xyn
    [GetCollectibleName(13063)] = "LuiExtended/media/icons/new_assistants/ast_siluruz.dds",                              -- Siluruz
}

--- @class (partial) AssistantIcons
Effects.AssistantIcons = assistantIcons
