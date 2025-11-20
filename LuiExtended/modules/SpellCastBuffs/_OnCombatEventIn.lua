-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local UI = LUIE.UI
local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type Effects
local Effects = Data.Effects
local Abilities = Data.Abilities
local Tooltips = Data.Tooltips
local string_format = string.format
local printToChat = LUIE.PrintToChat
local zo_strformat = zo_strformat
local table_insert = table.insert
local table_sort = table.sort
-- local displayName = GetDisplayName()
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()

local moduleName = SpellCastBuffs.moduleName

-- Combat Event (Target = Player)
--- @param eventCode integer
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
function SpellCastBuffs.OnCombatEventIn(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if not (Effects.FakeExternalBuffs[abilityId] or Effects.FakeExternalDebuffs[abilityId] or Effects.FakePlayerBuffs[abilityId] or Effects.FakeStagger[abilityId] or Effects.AddGroundDamageAura[abilityId]) then
        return
    end

    -- If the ability is blacklisted
    if SpellCastBuffs.SV.BlacklistTable[abilityId] or SpellCastBuffs.SV.BlacklistTable[abilityName] then
        return
    end

    -- Create ground auras for damaging effects if toggled on
    if SpellCastBuffs.SV.GroundDamageAura and Effects.AddGroundDamageAura[abilityId] then
        -- Return if this isn't damage or healing, or blocked, dodged, or shielded.
        if result ~= ACTION_RESULT_DAMAGE and result ~= ACTION_RESULT_DAMAGE_SHIELDED and result ~= ACTION_RESULT_DODGED and result ~= ACTION_RESULT_CRITICAL_DAMAGE and result ~= ACTION_RESULT_CRITICAL_HEAL and result ~= ACTION_RESULT_HEAL and result ~= ACTION_RESULT_BLOCKED and result ~= ACTION_RESULT_BLOCKED_DAMAGE and result ~= ACTION_RESULT_HOT_TICK and result ~= ACTION_RESULT_HOT_TICK_CRITICAL and result ~= ACTION_RESULT_DOT_TICK and result ~= ACTION_RESULT_DOT_TICK_CRITICAL and not Effects.AddGroundDamageAura[abilityId].exception then
            return
        end

        -- Only allow exceptions through if flagged as such
        if Effects.AddGroundDamageAura[abilityId].exception and result ~= Effects.AddGroundDamageAura[abilityId].exception then
            return
        end

        local stack
        local iconName = GetAbilityIcon(abilityId)
        local effectName
        local unbreakable
        local duration = Effects.AddGroundDamageAura[abilityId].duration
        local effectType = Effects.AddGroundDamageAura[abilityId].type
        local buffSlot
        local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false
        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

        if Effects.EffectOverride[abilityId] then
            effectName = Effects.EffectOverride[abilityId].name or abilityName
            unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
            stack = Effects.EffectOverride[abilityId].stack or 0
        else
            effectName = abilityName
            unbreakable = 0
            stack = 0
        end

        -- Override name, icon, or hide based on MapZoneIndex
        if Effects.ZoneDataOverride[abilityId] then
            local index = GetZoneId(GetCurrentMapZoneIndex())
            local zoneName = GetPlayerLocationName()
            if Effects.ZoneDataOverride[abilityId][index] then
                if Effects.ZoneDataOverride[abilityId][index].icon then
                    iconName = Effects.ZoneDataOverride[abilityId][index].icon
                end
                if Effects.ZoneDataOverride[abilityId][index].name then
                    effectName = Effects.ZoneDataOverride[abilityId][index].name
                end
                if Effects.ZoneDataOverride[abilityId][index].hide then
                    return
                end
            end
            if Effects.ZoneDataOverride[abilityId][zoneName] then
                if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                    iconName = Effects.ZoneDataOverride[abilityId][zoneName].icon
                end
                if Effects.ZoneDataOverride[abilityId][zoneName].name then
                    effectName = Effects.ZoneDataOverride[abilityId][zoneName].name
                end
                if Effects.ZoneDataOverride[abilityId][zoneName].hide then
                    return
                end
            end
        end

        -- Override name, icon, or hide based on Map Name
        if Effects.MapDataOverride[abilityId] then
            local mapName = GetMapName()
            if Effects.MapDataOverride[abilityId][mapName] then
                if Effects.MapDataOverride[abilityId][mapName].icon then
                    iconName = Effects.MapDataOverride[abilityId][mapName].icon
                end
                if Effects.MapDataOverride[abilityId][mapName].name then
                    effectName = Effects.MapDataOverride[abilityId][mapName].name
                end
                if Effects.MapDataOverride[abilityId][mapName].hide then
                    return
                end
            end
        end

        -- Override name or icon based off unitName
        if Effects.EffectOverrideByName[abilityId] then
            local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
            if Effects.EffectOverrideByName[abilityId][unitName] then
                if Effects.EffectOverrideByName[abilityId][unitName].hide then
                    if Effects.EffectOverrideByName[abilityId][unitName].zone then
                        local zones = Effects.EffectOverrideByName[abilityId][unitName].zone
                        local index = GetZoneId(GetCurrentMapZoneIndex())
                        for k, v in pairs(zones) do
                            -- d(k)
                            -- d(index)
                            if k == index then
                                return
                            end
                        end
                    else
                        return
                    end
                end
                iconName = Effects.EffectOverrideByName[abilityId][unitName].icon or iconName
                effectName = Effects.EffectOverrideByName[abilityId][unitName].name or effectName
            end
        end

        if Effects.AddGroundDamageAura[abilityId].merge then
            buffSlot = "GroundDamageAura" .. tostring(Effects.AddGroundDamageAura[abilityId].merge)
        else
            buffSlot = abilityId
        end

        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local context = "player" .. effectType

        -- Stack Resolution
        if SpellCastBuffs.EffectsList[context][buffSlot] and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
            if Effects.EffectOverride[abilityId].stackMax then
                if not (SpellCastBuffs.EffectsList[context][buffSlot].stack == Effects.EffectOverride[abilityId].stackMax) then
                    stack = SpellCastBuffs.EffectsList[context][buffSlot].stack + Effects.EffectOverride[abilityId].stackAdd
                else
                    stack = SpellCastBuffs.EffectsList[context][buffSlot].stack
                end
            else
                stack = SpellCastBuffs.EffectsList[context][buffSlot].stack + Effects.EffectOverride[abilityId].stackAdd
            end
        end

        -- TODO: May need to update this to support prominent
        SpellCastBuffs.EffectsList[context][buffSlot] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = effectType,
            id = abilityId,
            name = effectName,
            icon = iconName,
            dur = duration,
            starts = beginTime,
            ends = (duration > 0) and endTime or nil,
            forced = "short",
            restart = true,
            iconNum = 0,
            unbreakable = unbreakable,
            fakeDuration = true,
            groundLabel = groundLabel,
            toggle = toggle,
            stack = stack,
        }
    end

    -- Special handling for Crystallized Shield + Morphs
    if abilityId == 86135 or abilityId == 86139 or abilityId == 86143 then
        if result == ACTION_RESULT_DAMAGE_SHIELDED then
            local context = "player1"
            local effectName = Effects.EffectOverrideByName[abilityId]
            context = SpellCastBuffs.DetermineContext(context, abilityId, effectName)

            if SpellCastBuffs.EffectsList[context][abilityId] then
                SpellCastBuffs.EffectsList[context][abilityId].stack = SpellCastBuffs.EffectsList[context][abilityId].stack - 1
                if SpellCastBuffs.EffectsList[context][abilityId].stack == 0 then
                    SpellCastBuffs.EffectsList[context][abilityId] = nil
                end
            end
        end
    end

    -- If the action result isn't a starting/ending event then we ignore it.
    if result ~= ACTION_RESULT_BEGIN and result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION and result ~= ACTION_RESULT_EFFECT_FADED then
        return
    end

    -- Toggled on when we need to ignore double events from some ids
    if SpellCastBuffs.ignoreAbilityId[abilityId] then
        SpellCastBuffs.ignoreAbilityId[abilityId] = nil
        return
    end

    local unbreakable
    local stack
    local internalStack
    local iconName
    local effectName
    local duration
    local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false

    if Effects.EffectOverride[abilityId] then
        if Effects.EffectOverride[abilityId].hideReduce and SpellCastBuffs.SV.HideReduce then
            return
        end
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stack = Effects.EffectOverride[abilityId].stack or 0
        internalStack = Effects.EffectOverride[abilityId].internalStack or nil
    else
        unbreakable = 0
        stack = 0
        internalStack = nil
    end

    -- Creates fake buff icons for buffs without an aura - These refresh on reapplication/removal (Applied on player by target)
    if Effects.FakeExternalBuffs[abilityId] and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER) then
        -- Bail out if we ignore begin events
        if Effects.FakeExternalBuffs[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakeExternalBuffs[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakeExternalBuffs[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if SpellCastBuffs.SV.HidePlayerBuffs then
            return
        end

        iconName = Effects.FakeExternalBuffs[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakeExternalBuffs[abilityId].name or GetAbilityName(abilityId)
        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, effectName)
        SpellCastBuffs.EffectsList[context][abilityId] = nil
        local overrideDuration = Effects.FakeExternalBuffs[abilityId].overrideDuration
        duration = Effects.FakeExternalBuffs[abilityId].duration
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        if source ~= "" and target == LUIE.PlayerNameFormatted then
            SpellCastBuffs.EffectsList[context][abilityId] =
            {
                target = SpellCastBuffs.DetermineTarget(context),
                type = 1,
                id = abilityId,
                name = effectName,
                icon = iconName,
                dur = duration,
                starts = beginTime,
                ends = (duration > 0) and endTime or nil,
                forced = "short",
                restart = true,
                iconNum = 0,
                unbreakable = unbreakable,
                fakeDuration = overrideDuration,
                groundLabel = groundLabel,
            }
        end
    end

    -- Creates fake debuff icons for debuffs without an aura - These refresh on reapplication/removal (Applied on player by target)
    if Effects.FakeExternalDebuffs[abilityId] and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER) then
        -- Bail out if we ignore begin events
        if Effects.FakeExternalDebuffs[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakeExternalDebuffs[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakeExternalDebuffs[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if SpellCastBuffs.SV.HidePlayerDebuffs then
            return
        end
        -- Bail out if we hide ground snares/etc to replace them with auras for damage
        if SpellCastBuffs.SV.GroundDamageAura and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].hideGround then
            return
        end

        local context = "player2"

        -- Stack handling
        if SpellCastBuffs.EffectsList[context][abilityId] and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
            -- Before removing old effect, if this effect is currently present and stack is set to increment on event, then add to stack counter
            if Effects.EffectOverride[abilityId].stackMax then
                if not (SpellCastBuffs.EffectsList[context][abilityId].stack == Effects.EffectOverride[abilityId].stackMax) then
                    stack = SpellCastBuffs.EffectsList[context][abilityId].stack + Effects.EffectOverride[abilityId].stackAdd
                else
                    stack = SpellCastBuffs.EffectsList[context][abilityId].stack
                end
            else
                stack = SpellCastBuffs.EffectsList[context][abilityId].stack + Effects.EffectOverride[abilityId].stackAdd
            end
        end

        if internalStack then
            if not SpellCastBuffs.InternalStackCounter[abilityId] then
                SpellCastBuffs.InternalStackCounter[abilityId] = 0
            end -- Create stack if it doesn't exist
            if result == ACTION_RESULT_EFFECT_FADED then
                SpellCastBuffs.InternalStackCounter[abilityId] = SpellCastBuffs.InternalStackCounter[abilityId] - 1
            elseif result == ACTION_RESULT_EFFECT_GAINED_DURATION then
                SpellCastBuffs.InternalStackCounter[abilityId] = SpellCastBuffs.InternalStackCounter[abilityId] + 1
            end
            if SpellCastBuffs.EffectsList[context][abilityId] then
                if SpellCastBuffs.InternalStackCounter[abilityId] <= 0 then
                    SpellCastBuffs.EffectsList[context][abilityId] = nil
                    SpellCastBuffs.InternalStackCounter[abilityId] = nil
                end
            end
        else
            SpellCastBuffs.EffectsList[context][abilityId] = nil
        end

        iconName = Effects.FakeExternalDebuffs[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakeExternalDebuffs[abilityId].name or GetAbilityName(abilityId)
        duration = Effects.FakeExternalDebuffs[abilityId].duration
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)

        if Effects.ZoneDataOverride[abilityId] then
            local index = GetZoneId(GetCurrentMapZoneIndex())
            local zoneName = GetPlayerLocationName()
            if Effects.ZoneDataOverride[abilityId][index] then
                if Effects.ZoneDataOverride[abilityId][index].icon then
                    iconName = Effects.ZoneDataOverride[abilityId][index].icon
                end
                if Effects.ZoneDataOverride[abilityId][index].name then
                    effectName = Effects.ZoneDataOverride[abilityId][index].name
                end
                if Effects.ZoneDataOverride[abilityId][index].hide then
                    return
                end
            end
            if Effects.ZoneDataOverride[abilityId][zoneName] then
                if Effects.ZoneDataOverride[abilityId][zoneName].icon then
                    iconName = Effects.ZoneDataOverride[abilityId][zoneName].icon
                end
                if Effects.ZoneDataOverride[abilityId][zoneName].name then
                    effectName = Effects.ZoneDataOverride[abilityId][zoneName].name
                end
                if Effects.ZoneDataOverride[abilityId][zoneName].hide then
                    return
                end
            end
        end

        -- Override name, icon, or hide based on Map Name
        if Effects.MapDataOverride[abilityId] then
            local mapName = GetMapName()
            if Effects.MapDataOverride[abilityId][mapName] then
                if Effects.MapDataOverride[abilityId][mapName].icon then
                    iconName = Effects.MapDataOverride[abilityId][mapName].icon
                end
                if Effects.MapDataOverride[abilityId][mapName].name then
                    effectName = Effects.MapDataOverride[abilityId][mapName].name
                end
                if Effects.MapDataOverride[abilityId][mapName].hide then
                    return
                end
            end
        end

        -- Override icon with default if enabled
        if SpellCastBuffs.SV.UseDefaultIcon and SpellCastBuffs.ShouldUseDefaultIcon(abilityId) == true then
            iconName = SpellCastBuffs.GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
        end

        -- TODO: Temp - converts icon for Helljoint, might be other abilities that need this in the future
        if abilityId == 14523 then
            if source == "Jackal" then
                iconName = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_JACKAL_HELLJOINT_DDS
            end
        end

        if source ~= "" and target == LUIE.PlayerNameFormatted then
            SpellCastBuffs.EffectsList[context][abilityId] =
            {
                target = SpellCastBuffs.DetermineTarget(context),
                type = BUFF_EFFECT_TYPE_DEBUFF,
                id = abilityId,
                name = effectName,
                icon = iconName,
                dur = duration,
                starts = beginTime,
                ends = (duration > 0) and endTime or nil,
                forced = "short",
                restart = true,
                iconNum = 0,
                unbreakable = unbreakable,
                groundLabel = groundLabel,
                stack = stack,
            }
        end
    end

    -- Creates fake buff icons for buffs without an aura - These refresh on reapplication/removal (Applied on player by player)
    if Effects.FakePlayerBuffs[abilityId] and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER) then
        -- Bail out if we ignore begin events
        if Effects.FakePlayerBuffs[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakePlayerBuffs[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakePlayerBuffs[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if SpellCastBuffs.SV.HidePlayerBuffs and not (SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[effectName] or SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName]) then
            return
        end
        if Effects.FakePlayerBuffs[abilityId].onlyExtra and not SpellCastBuffs.SV.ExtraBuffs then
            return
        end
        if Effects.FakePlayerBuffs[abilityId].onlyExtended and not (SpellCastBuffs.SV.ExtraBuffs and SpellCastBuffs.SV.ExtraExpanded) then
            return
        end

        -- If this is a fake set ICD then don't display if we have Set ICD's disabled.
        if Effects.IsSetICD[abilityId] and SpellCastBuffs.SV.IgnoreSetICDPlayer then
            return
        end
        -- If this is an ability ICD then don't display if we have Ability ICD's disabled.
        if Effects.IsAbilityICD[abilityId] and SpellCastBuffs.SV.IgnoreAbilityICDPlayer then
            return
        end

        -- Prominent Support
        local effectType = Effects.FakePlayerBuffs[abilityId].debuff and BUFF_EFFECT_TYPE_DEBUFF or BUFF_EFFECT_TYPE_BUFF -- TODO: Expand this for below instead of calling again
        local context = "player" .. effectType

        if SpellCastBuffs.EffectsList[context][abilityId] and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
            -- Before removing old effect, if this effect is currently present and stack is set to increment on event, then add to stack counter
            stack = SpellCastBuffs.EffectsList[context][abilityId].stack + Effects.EffectOverride[abilityId].stackAdd
        end
        if abilityId == 26406 then
            SpellCastBuffs.ignoreAbilityId[abilityId] = true
        end

        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

        iconName = Effects.FakePlayerBuffs[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakePlayerBuffs[abilityId].name or GetAbilityName(abilityId)
        duration = Effects.FakePlayerBuffs[abilityId].duration
        if duration == "GET" then
            duration = GetAbilityDuration(abilityId) or 0
        end
        local finalId = Effects.FakePlayerBuffs[abilityId].shiftId or abilityId
        if Effects.FakePlayerBuffs[abilityId].shiftId then
            iconName = Effects.FakePlayerBuffs[finalId] and Effects.FakePlayerBuffs[finalId].icon or GetAbilityIcon(finalId)
            effectName = Effects.FakePlayerBuffs[finalId] and Effects.FakePlayerBuffs[finalId].name or GetAbilityName(finalId)
        end
        -- TODO: Do we want to enable self debuffs from this to show as prominent (ICD for sets for example?)
        context = SpellCastBuffs.DetermineContextSimple(context, finalId, effectName)
        SpellCastBuffs.EffectsList[context][finalId] = nil
        local forcedType = Effects.FakePlayerBuffs[abilityId].long and "long" or "short"
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        -- Pull unbreakable info from Shift Id if present
        unbreakable = (Effects.EffectOverride[finalId] and Effects.EffectOverride[finalId].unbreakable) or unbreakable
        if source == LUIE.PlayerNameFormatted and target == LUIE.PlayerNameFormatted then
            SpellCastBuffs.EffectsList[context][finalId] =
            {
                target = SpellCastBuffs.DetermineTarget(context),
                type = effectType,
                id = finalId,
                name = effectName,
                icon = iconName,
                dur = duration,
                starts = beginTime,
                ends = (duration > 0) and endTime or nil,
                forced = forcedType,
                restart = true,
                iconNum = 0,
                unbreakable = unbreakable,
                stack = stack,
                groundLabel = groundLabel,
                toggle = toggle,
            }
        end
    end

    -- Simulates fake debuff icons for stagger effects - works for both (target -> player) and (player -> target) - DOES NOT REFRESH - Only expiration condition is the timer
    if Effects.FakeStagger[abilityId] then
        -- Bail out if we ignore begin events
        if Effects.FakeStagger[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakeStagger[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakeStagger[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if SpellCastBuffs.SV.HidePlayerDebuffs then
            return
        end
        iconName = Effects.FakeStagger[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakeStagger[abilityId].name or GetAbilityName(abilityId)
        duration = Effects.FakeStagger[abilityId].duration
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("reticleover"))
        local context = "player2"
        if source ~= "" and target == LUIE.PlayerNameFormatted then
            SpellCastBuffs.EffectsList[context][abilityId] =
            {
                target = SpellCastBuffs.DetermineTarget(context),
                type = BUFF_EFFECT_TYPE_DEBUFF,
                id = abilityId,
                name = effectName,
                icon = iconName,
                dur = duration,
                starts = beginTime,
                ends = (duration > 0) and endTime or nil,
                forced = "short",
                restart = true,
                iconNum = 0,
                unbreakable = unbreakable,
                groundLabel = groundLabel,
            }
        end
    end
end
