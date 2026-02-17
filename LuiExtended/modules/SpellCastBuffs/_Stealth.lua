-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Abilities = Data.Abilities
local Tooltips = Data.Tooltips

-- TODO: Update id's here with fake ids probably, to set different icons etc for Prominent add/remove

-- Called by SpellCastBuffs.DisguiseItem()
function SpellCastBuffs.SetDisguiseItem()
    local abilityId = 999020
    -- Remove buff first
    SpellCastBuffs.ClearPlayerBuff(abilityId)

    -- If we don't have a disguise equipped, have a Monk's Disguise (already has buff icon) or Guild Tabard then bail out
    if SpellCastBuffs.currentDisguise == 0 or SpellCastBuffs.currentDisguise == 79332 or SpellCastBuffs.currentDisguise == 55262 then
        return
    end

    local name = GetItemName(BAG_WORN, EQUIP_SLOT_COSTUME)
    local abilityName = Abilities.Innate_Disguise
    local icon = Effects.DisguiseIcons[SpellCastBuffs.currentDisguise].icon
    local idTooltip = Effects.DisguiseIcons[SpellCastBuffs.currentDisguise].id or ""
    local tooltip = Effects.EffectOverride[idTooltip] and Effects.EffectOverride[idTooltip].tooltip or Tooltips.Disguise_Generic
    -- Determine Context
    local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
    -- Create Buff
    SpellCastBuffs.EffectsList[context][abilityId] =
    {
        target = SpellCastBuffs.DetermineTarget(context),
        type = 1,
        id = abilityId,
        name = name,
        icon = icon,
        tooltip = tooltip,
        dur = 0,
        starts = 1,
        ends = nil, -- ends=nil : last buff in sorting
        forced = "long",
        restart = true,
        iconNum = 0,
    }
end

-- Called on item slot change for Disguise.
--- - **EVENT_INVENTORY_SINGLE_SLOT_UPDATE **
---
--- @param eventId integer
--- @param bagId Bag
--- @param slotIndex integer
--- @param isNewItem boolean
--- @param itemSoundCategory ItemUISoundCategory
--- @param inventoryUpdateReason integer
--- @param stackCountChange integer
--- @param triggeredByCharacterName string?
--- @param triggeredByDisplayName string?
--- @param isLastUpdateForMessage boolean
--- @param bonusDropSource BonusDropSource
function SpellCastBuffs.DisguiseItem(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    -- If slotIndex isn't the disguise/tabard slot then return
    if slotIndex ~= EQUIP_SLOT_COSTUME or SpellCastBuffs.SV.IgnoreDisguise or SpellCastBuffs.SV.HidePlayerBuffs then
        return
    end

    -- Set current disguise
    SpellCastBuffs.currentDisguise = GetItemId(BAG_WORN, EQUIP_SLOT_COSTUME) or 0

    -- Set the icon for the disguise to display
    SpellCastBuffs.SetDisguiseItem()
end

-- Handles disguise changes for player/reticleover
--- - **EVENT_DISGUISE_STATE_CHANGED **
---
--- @param eventId integer
--- @param unitTag string
--- @param disguiseState DisguiseState
function SpellCastBuffs.DisguiseStateChanged(eventId, unitTag, disguiseState)
    -- Bail out if we don't have disguise or unitTag buffs enabled
    if unitTag == "player" and (not SpellCastBuffs.SV.DisguiseStatePlayer or SpellCastBuffs.SV.HidePlayerBuffs) then
        return
    elseif unitTag == "reticleover" and (not SpellCastBuffs.SV.DisguiseStatePlayer or SpellCastBuffs.SV.HideTargetBuffs) then
        return
    end

    -- Bail out if for some reason we have no value for disguiseState
    if disguiseState == nil then
        return
    end

    local abilityId = 50602
    local abilityName = Abilities.Innate_Disguised
    -- Determine Context
    local context = unitTag .. "1"
    context = SpellCastBuffs.DetermineContextSimple(context, abilityId, abilityName)

    -- Remove buff first
    SpellCastBuffs.EffectsList[context][abilityId] = nil

    -- Add disguise icon if we are in any state of disguise
    if disguiseState == DISGUISE_STATE_DISGUISED or disguiseState == DISGUISE_STATE_DANGER or disguiseState == DISGUISE_STATE_SUSPICIOUS or disguiseState == DISGUISE_STATE_DISCOVERED then
        SpellCastBuffs.EffectsList[context][abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_DISGUISED_DDS,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "short",
            restart = true,
            iconNum = 0,
        }
    end
end

local function RemoveSneak(context)
    local abilityId = 20299
    local abilityName = Abilities.Innate_Sneak
    local contexta = SpellCastBuffs.DetermineContextSimple(context, abilityId, abilityName)
    SpellCastBuffs.EffectsList[contexta][abilityId] = nil
end

local function RemoveHidden(context)
    local abilityId = 20309
    local abilityName = Abilities.Innate_Hidden
    local contextb = SpellCastBuffs.DetermineContextSimple(context, abilityId, abilityName)
    SpellCastBuffs.EffectsList[contextb][abilityId] = nil
end

-- Handles stealth state changes for player/reticleover
--- - **EVENT_STEALTH_STATE_CHANGED **
---
--- @param eventId integer
--- @param unitTag string
--- @param stealthState StealthState
function SpellCastBuffs.StealthStateChanged(eventId, unitTag, stealthState)
    -- Bail out if we don't have stealth or unitTag buffs enabled
    if unitTag == "player" and (not SpellCastBuffs.SV.StealthStatePlayer or SpellCastBuffs.SV.HidePlayerBuffs) then
        return
    elseif unitTag == "reticleover" and (not SpellCastBuffs.SV.StealthStateTarget or SpellCastBuffs.SV.HideTargetBuffs) then
        return
    end

    -- Bail out if for some reason we have no value for stealthState
    if stealthState == nil then
        return
    end

    -- Determine Context
    local context = unitTag .. "1"
    -- Remove buffs first
    RemoveSneak(context)
    RemoveHidden(context)

    -- Add hidden icon if we are hidden
    if stealthState == STEALTH_STATE_HIDDEN or stealthState == STEALTH_STATE_HIDDEN_ALMOST_DETECTED then
        local abilityId = 20299
        local abilityName = Abilities.Innate_Sneak
        context = SpellCastBuffs.DetermineContextSimple(context, abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_HIDDEN_DDS,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "short",
            restart = true,
            iconNum = 0,
        }
        -- Add invisible icon if we are invisible
    elseif stealthState == STEALTH_STATE_STEALTH or stealthState == STEALTH_STATE_STEALTH_ALMOST_DETECTED then
        local abilityId = 20309
        local abilityName = Abilities.Innate_Hidden
        context = SpellCastBuffs.DetermineContextSimple(context, abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_INVISIBLE_DDS,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "short",
            restart = true,
            iconNum = 0,
        }
    end
end
