-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- LUIE utility functions
local AddSystemMessage = LUIE.AddSystemMessage
local PrintToChat = LUIE.PrintToChat

--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs
local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local EffectOverride = Effects.EffectOverride
local DebugAuras = Data.DebugAuras
local DebugResults = Data.DebugResults


local zo_strformat = zo_strformat
local zo_iconFormat = zo_iconFormat


-- API function localizations
local GetAbilityIcon = GetAbilityIcon
local GetAbilityName = GetAbilityName
local GetAbilityDuration = GetAbilityDuration
local GetAbilityCastInfo = GetAbilityCastInfo


-- Debug Display for Combat Events
--- @param eventId integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function SpellCastBuffs.EventCombatDebug(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Don't display if this aura is already added to the filter
    if DebugAuras[abilityId] and SpellCastBuffs.SV.ShowDebugFilter then return end

    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    local source = zo_strformat("<<C:1>>", sourceName)
    local target = zo_strformat("<<C:1>>", targetName)
    local ability = zo_strformat("<<C:1>>", nameFormatted)
    local duration = GetAbilityDuration(abilityId)
    if duration == nil then
        duration = "0"
    end
    local channeled, durationValue = GetAbilityCastInfo(abilityId, nil, sourceType)
    local showacasttime = ""
    local showachantime = ""
    if channeled then
        showachantime = (" [Chan] " .. durationValue)
    elseif durationValue and durationValue > 0 then
        showacasttime = (" [Cast] " .. durationValue)
    end
    if source == LUIE.PlayerNameFormatted then
        source = "Player"
    end
    if target == LUIE.PlayerNameFormatted then
        target = "Player"
    end
    if sourceName == "" and targetName == "" then
        source = "NIL"
        target = "NIL"
    end

    local formattedResult = DebugResults[result]

    local finalString = (iconFormatted .. " [" .. abilityId .. "] " .. ability .. ": [S] " .. source .. " --> [T] " .. target .. " [D] " .. duration .. showachantime .. showacasttime .. " [R] " .. formattedResult)
    PrintToChat(finalString, true)
end

-- Debug Display for Effect Events
--- @param eventId integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SpellCastBuffs.EventEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if DebugAuras[abilityId] and SpellCastBuffs.SV.ShowDebugFilter then
        return
    end

    local iconFormatted = zo_iconFormat(GetAbilityIcon(abilityId), 16, 16)
    local nameFormatted = zo_strformat("<<C:1>>", GetAbilityName(abilityId))

    if unitName == "Offline" then
        unitName = "GROUND?"
    end
    unitName = zo_strformat("<<C:1>>", unitName)
    if unitName == LUIE.PlayerNameFormatted then
        unitName = "Player"
    end
    unitName = unitName .. " (" .. unitTag .. ")"

    local finalString
    if EffectOverride[abilityId] and EffectOverride[abilityId].hide then
        finalString = (iconFormatted .. "|c00E200 [" .. abilityId .. "] " .. nameFormatted .. ": HIDDEN LUI" .. ": [Tag] " .. unitName .. "|r")
        -- Use CHAT_ROUTER to bypass some other addons modifying this string
        CHAT_ROUTER:AddSystemMessage(finalString)
        return
    end

    local duration = (endTime - beginTime) * 1000

    local refreshOnly = ""
    if EffectOverride[abilityId] and EffectOverride[abilityId].refreshOnly then
        refreshOnly = " |c00E200(Hidden)|r "
    end

    if changeType == 1 then
        finalString = ("|c00E200Gained:|r " .. refreshOnly .. iconFormatted .. " [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Dur] " .. duration)
    elseif changeType == 2 then
        finalString = ("|c00E200Faded:|r " .. iconFormatted .. " [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName)
    else
        finalString = ("|c00E200Refreshed:|r " .. iconFormatted .. " (" .. changeType .. ") [" .. abilityId .. "] " .. nameFormatted .. ": [Tag] " .. unitName .. " [Dur] " .. duration)
    end
    PrintToChat(finalString, true)
end
