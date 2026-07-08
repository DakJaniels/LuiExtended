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
local AssistantIcons = Effects.AssistantIcons

local pairs = pairs
local zo_strformat = zo_strformat

-- Called by SpellCastBuffs.MountStatus to display mount icon
function SpellCastBuffs.DisplayMountIcon()
    --[[
        -- Target support is not implemented

        -- Bail out if somehow a non-player/target unitTag gets passed here
        if unitTag ~= "player" and unitTag ~= "reticleover" then
            return
        end

        -- Bail out if we have target mount hidden (we check for target buffs being disabled in the reticleover function that calls this function)
        if unitTag == "reticleover" and SpellCastBuffs.SV.IgnoreMountTarget then
            return
        end
    ]]
    --

    -- Check mounted state
    local name = GetRawUnitName("player")
    local mountedState = GetTargetMountedStateInfo(name)

    if mountedState == MOUNTED_STATE_MOUNT_RIDER or mountedState == MOUNTED_STATE_MOUNT_PASSENGER then
        local description
        local icon
        if mountedState == MOUNTED_STATE_MOUNT_RIDER then
            if SpellCastBuffs.SV.MountDetail then
                -- Get detailed collectible information for the player
                local collectible = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
                local nickname = GetCollectibleNickname(collectible)
                name, description, icon = GetCollectibleInfo(collectible)

                -- Add the nickname into the name if present
                if nickname ~= "" and nickname ~= nil then
                    name = zo_strformat(GetString(SI_COLLECTIBLE_NAME_WITH_NICKNAME_FORMATTER), name, nickname)
                end
            else
                name = Abilities.Innate_Mounted
                description = Tooltips.Innate_Mounted
                icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_MOUNTED_DDS
            end
        elseif mountedState == MOUNTED_STATE_MOUNT_PASSENGER then
            name = Abilities.Innate_Mounted_Passenger
            description = Tooltips.Innate_Mounted_Passenger
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_MOUNTED_DDS
        end

        local abilityId = 999017
        local abilityName = Abilities.Innate_Mounted
        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityId] =
        {
            uid = abilityId,
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = name,
            icon = icon,
            backdrop = true,
            tooltip = description,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "long",
            restart = true,
            iconNum = 0,
        }
    end
end

--- - Handler to create Mount Buff icon for player.
--- - **EVENT_MOUNTED_STATE_CHANGED **
---
--- @param mounted boolean
function SpellCastBuffs.MountStatus(mounted)
    -- Clear current mount icon
    local abilityId = 999017
    SpellCastBuffs.ClearPlayerBuff(abilityId)
    -- Display mount icon if settings are enabled
    if mounted and not (SpellCastBuffs.SV.IgnoreMountPlayer or SpellCastBuffs.SV.HidePlayerBuffs) then
        SpellCastBuffs.DisplayMountIcon()
    end
end

--- - Waits 100 ms + latency for the delay in activating collectibles before checking
--- - **EVENT_COLLECTIBLE_USE_RESULT **
---
--- @param eventId integer
--- @param result CollectibleUsageBlockReason
--- @param isAttemptingActivation boolean
function SpellCastBuffs.CollectibleUsed(eventId, result, isAttemptingActivation)
    local latency = GetLatency()
    latency = latency + 100
    zo_callLater(SpellCastBuffs.CollectibleBuff, latency)
end

-- Handles delayed call from SpellCastBuffs.CollectibleUsed()
function SpellCastBuffs.CollectibleBuff()
    -- Remove Icon First
    local ids = { 999018, 999019 }
    for _, v in pairs(ids) do
        SpellCastBuffs.ClearPlayerBuff(v)
    end

    -- Bail out if Player Buffs are hidden
    if SpellCastBuffs.SV.HidePlayerBuffs then
        return
    end

    -- Bail out if we are in a PVP Zone
    if LUIE.ResolvePVPZone() then
        return
    end

    -- Bail out if we are in a house
    local currentHouse = GetCurrentZoneHouseId()
    if currentHouse ~= nil and currentHouse > 0 then
        return
    end

    -- Pets
    if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, GAMEPLAY_ACTOR_CATEGORY_PLAYER) > 0 and not SpellCastBuffs.SV.IgnorePet then
        local collectible = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_VANITY_PET, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        local name
        local description
        local icon
        if SpellCastBuffs.SV.PetDetail then
            -- Get detailed collectible information for the player
            local nickname = GetCollectibleNickname(collectible)
            name, description, icon = GetCollectibleInfo(collectible)

            -- Add the nickname into the name if present
            if nickname ~= "" and nickname ~= nil then
                name = zo_strformat(GetString(SI_COLLECTIBLE_NAME_WITH_NICKNAME_FORMATTER), name, nickname)
            end
        else
            name = Abilities.Innate_Vanity_Pet
            description = Tooltips.Innate_Vanity_Pet
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_PET_DDS
        end

        local abilityId = 999018
        local abilityName = Abilities.Innate_Vanity_Pet
        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = name,
            icon = icon,
            backdrop = true,
            tooltip = description,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "long",
            restart = true,
            iconNum = 0,
        }
    end

    -- Assistants
    if GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER) > 0 and not SpellCastBuffs.SV.IgnoreAssistant then
        local collectible = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT, GAMEPLAY_ACTOR_CATEGORY_PLAYER)
        local name, description, collectibleIcon = GetCollectibleInfo(collectible)
        local iconAssistant = AssistantIcons[name] or collectibleIcon or ""

        local abilityId = 999019
        local abilityName = Abilities.Innate_Assistant
        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = name,
            icon = iconAssistant,
            backdrop = true,
            tooltip = description,
            dur = 0,
            starts = 1,
            ends = nil, -- ends=nil : last buff in sorting
            forced = "long",
            restart = true,
            iconNum = 0,
        }
    end
end
