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

-- Combat Event (Source = Player)
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
function SpellCastBuffs.OnCombatEventOut(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    if targetType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER_PET then
        return
    end

    -- If the ability is blacklisted
    if SpellCastBuffs.SV.BlacklistTable[abilityId] or SpellCastBuffs.SV.BlacklistTable[abilityName] then
        return
    end

    if not (Effects.FakePlayerOfflineAura[abilityId] or Effects.FakePlayerDebuffs[abilityId] or Effects.FakeStagger[abilityId] or Effects.IsGroundMineDamage[abilityId]) then
        return
    end

    -- Handling for Trap Beast
    if Effects.IsGroundMineDamage[abilityId] and sourceType == COMBAT_UNIT_TYPE_PLAYER then
        if result == ACTION_RESULT_BLOCKED or result == ACTION_RESULT_BLOCKED_DAMAGE or result == ACTION_RESULT_CRITICAL_DAMAGE or result == ACTION_RESULT_DAMAGE or result == ACTION_RESULT_DAMAGE_SHIELDED or result == ACTION_RESULT_IMMUNE or result == ACTION_RESULT_MISS or result == ACTION_RESULT_PARTIAL_RESIST or result == ACTION_RESULT_REFLECTED or result == ACTION_RESULT_RESIST or result == ACTION_RESULT_WRECKING_DAMAGE or result == ACTION_RESULT_DODGED then
            local compareId
            if abilityId == 35754 then
                compareId = 35750
            elseif abilityId == 40389 then
                compareId = 40382
            elseif abilityId == 40376 then
                compareId = 40372
            end
            if compareId then
                -- Remove mine buff if damage is triggered
                local context = "player1" -- Default context

                -- Check if the compareId exists in FakePlayerOfflineAura before accessing its properties
                if Effects.FakePlayerOfflineAura[compareId] and Effects.FakePlayerOfflineAura[compareId].ground then
                    context = "ground"
                end

                -- Check for prominent buff/debuff settings
                if SpellCastBuffs.SV.PromDebuffTable[compareId] then
                    context = "promd_player"
                elseif SpellCastBuffs.SV.PromBuffTable[compareId] then
                    context = "promb_player"
                end

                -- Remove the effect from the appropriate context
                SpellCastBuffs.EffectsList[context][compareId] = nil
            end
        end
    end

    -- If the action result isn't a starting/ending event then we ignore it.
    if result ~= ACTION_RESULT_BEGIN and result ~= ACTION_RESULT_EFFECT_GAINED and result ~= ACTION_RESULT_EFFECT_GAINED_DURATION and result ~= ACTION_RESULT_EFFECT_FADED then
        return
    end

    local unbreakable
    local stack
    local iconName
    local effectName
    local duration
    local effectType
    local groundLabel = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].groundLabel or false

    if Effects.EffectOverride[abilityId] then
        if Effects.EffectOverride[abilityId].hideReduce and SpellCastBuffs.SV.HideReduce then
            return
        end
        unbreakable = Effects.EffectOverride[abilityId].unbreakable or 0
        stack = Effects.EffectOverride[abilityId].stack or 0
    else
        unbreakable = 0
        stack = 0
    end

    -- Fake offline auras created by the player
    if Effects.FakePlayerOfflineAura[abilityId] and sourceType == COMBAT_UNIT_TYPE_PLAYER then
        -- Bail out if we ignore begin events
        if Effects.FakePlayerOfflineAura[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakePlayerOfflineAura[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakePlayerOfflineAura[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if SpellCastBuffs.SV.HidePlayerBuffs and not (SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[effectName] or SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName] or Effects.FakePlayerOfflineAura[abilityId].ground) then
            return
        end

        -- Prominent Support
        local context
        if Effects.FakePlayerOfflineAura[abilityId].ground then
            context = "ground"
        else
            context = "player1"
        end
        if SpellCastBuffs.SV.PromDebuffTable[abilityId] or SpellCastBuffs.SV.PromDebuffTable[effectName] then
            context = "promd_player"
        elseif SpellCastBuffs.SV.PromBuffTable[abilityId] or SpellCastBuffs.SV.PromBuffTable[effectName] then
            context = "promb_player"
        end

        if SpellCastBuffs.EffectsList[context][abilityId] and Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].stackAdd then
            -- Before removing old effect, if this effect is currently present and stack is set to increment on event, then add to stack counter
            stack = SpellCastBuffs.EffectsList[context][abilityId].stack + Effects.EffectOverride[abilityId].stackAdd
        end

        SpellCastBuffs.EffectsList[context][abilityId] = nil

        local toggle = Effects.EffectOverride[abilityId] and Effects.EffectOverride[abilityId].toggle or false

        iconName = Effects.FakePlayerOfflineAura[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakePlayerOfflineAura[abilityId].name or GetAbilityName(abilityId)
        duration = Effects.FakePlayerOfflineAura[abilityId].duration
        if duration == "GET" then
            duration = GetAbilityDuration(abilityId) or 0
        end
        local finalId = Effects.FakePlayerOfflineAura[abilityId].shiftId or abilityId
        if Effects.FakePlayerOfflineAura[abilityId].shiftId then
            iconName = Effects.FakePlayerOfflineAura and Effects.FakePlayerOfflineAura[finalId].icon or GetAbilityIcon(finalId)
            effectName = Effects.FakePlayerOfflineAura and Effects.FakePlayerOfflineAura[finalId].name or GetAbilityName(finalId)
        end
        local forcedType = Effects.FakePlayerOfflineAura[abilityId].long and "long" or "short"
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        -- Pull unbreakable info from Shift Id if present
        unbreakable = Effects.EffectOverride[finalId].unbreakable or unbreakable
        if source == LUIE.PlayerNameFormatted then
            -- If the "buff" is flagged as a debuff, then display it here instead
            if Effects.FakePlayerOfflineAura[abilityId].ground == true then
                SpellCastBuffs.EffectsList[context][finalId] =
                {
                    target = SpellCastBuffs.DetermineTarget(context),
                    type = BUFF_EFFECT_TYPE_DEBUFF,
                    id = finalId,
                    name = effectName,
                    icon = iconName,
                    dur = duration,
                    starts = beginTime,
                    ends = (duration > 0) and endTime or nil,
                    forced = "short",
                    restart = true,
                    iconNum = 0,
                    unbreakable = unbreakable,
                    stack = stack,
                    groundLabel = groundLabel,
                    toggle = toggle,
                }
                -- Otherwise, display as a normal buff
            else
                SpellCastBuffs.EffectsList[context][finalId] =
                {
                    target = SpellCastBuffs.DetermineTarget(context),
                    type = 1,
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
    end

    -- Creates fake debuff icons for debuffs without an aura - These refresh on reapplication/removal (Applied on target by player)
    if Effects.FakePlayerDebuffs[abilityId] and (sourceType == COMBAT_UNIT_TYPE_PLAYER or targetType == COMBAT_UNIT_TYPE_PLAYER) then
        -- Bail out if we ignore begin events
        if Effects.FakePlayerDebuffs[abilityId].ignoreBegin and (result == ACTION_RESULT_BEGIN) then
            return
        end
        if Effects.FakePlayerDebuffs[abilityId].refreshOnly and (result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_EFFECT_GAINED) then
            return
        end
        if Effects.FakePlayerDebuffs[abilityId].ignoreFade and (result == ACTION_RESULT_EFFECT_FADED) then
            return
        end
        if SpellCastBuffs.SV.HideTargetDebuffs then
            return
        end
        if not DoesUnitExist("reticleover") then
            return
        end
        -- if GetUnitReaction("reticleover") ~= UNIT_REACTION_HOSTILE then return end
        local displayName = GetDisplayName()
        local unitTag = displayName
        if IsUnitDead(unitTag) then
            return
        end
        iconName = Effects.FakePlayerDebuffs[abilityId].icon or GetAbilityIcon(abilityId)

        -- Override icon with default if enabled
        if SpellCastBuffs.SV.UseDefaultIcon and SpellCastBuffs.ShouldUseDefaultIcon(abilityId) == true then
            iconName = SpellCastBuffs.GetDefaultIcon(Effects.EffectOverride[abilityId].cc)
        end

        effectName = Effects.FakePlayerDebuffs[abilityId].name or GetAbilityName(abilityId)
        local context = "reticleover2" -- NOTE: TODO - No prominent support here and probably won't add
        duration = Effects.FakePlayerDebuffs[abilityId].duration
        local overrideDuration = Effects.FakePlayerDebuffs[abilityId].overrideDuration
        effectType = BUFF_EFFECT_TYPE_DEBUFF
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("reticleover"))
        -- if unitName ~= target then return end
        if source == LUIE.PlayerNameFormatted and target ~= nil then
            if SpellCastBuffs.SV.HideTargetDebuffs then
                return
            end
            if unitName == target then
                SpellCastBuffs.EffectsList.ground[abilityId] =
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
                    savedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName),
                    fakeDuration = overrideDuration,
                    groundLabel = groundLabel,
                }
            else
                SpellCastBuffs.EffectsList.saved[abilityId] =
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
                    savedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName),
                    fakeDuration = overrideDuration,
                    groundLabel = groundLabel,
                }
            end
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
        if SpellCastBuffs.SV.HideTargetDebuffs then
            return
        end
        iconName = Effects.FakeStagger[abilityId].icon or GetAbilityIcon(abilityId)
        effectName = Effects.FakeStagger[abilityId].name or GetAbilityName(abilityId)
        local context = "reticleover2" -- NOTE: TODO - No prominent support here and probably won't add
        duration = Effects.FakeStagger[abilityId].duration
        local beginTime = GetFrameTimeMilliseconds()
        local endTime = beginTime + duration
        local source = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, sourceName)
        local target = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName)
        local unitName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, GetUnitName("reticleover"))
        if source == LUIE.PlayerNameFormatted and target ~= nil then
            if SpellCastBuffs.SV.HideTargetDebuffs then
                return
            end
            if unitName == target then
                SpellCastBuffs.EffectsList.ground[abilityId] =
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
                    savedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName),
                    groundLabel = groundLabel,
                }
            else
                SpellCastBuffs.EffectsList.saved[abilityId] =
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
                    savedName = zo_strformat(LUIE_UPPER_CASE_NAME_FORMATTER, targetName),
                    groundLabel = groundLabel,
                }
            end
        end
    end
end
