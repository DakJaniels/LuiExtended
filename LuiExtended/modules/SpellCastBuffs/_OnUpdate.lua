-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
local Abilities = Data.Abilities
local Effects = Data.Effects

local zo_floor = zo_floor
local string_format = string.format
local zo_strformat = zo_strformat
local table_sort = table.sort
local GetAbilityName = GetAbilityName
local IsBlockActive = IsBlockActive
local IsPlayerStunned = IsPlayerStunned

-- Matches SpellCastBuffs.xml ZO_DefaultCooldown alpha="0.5" (cooldown base alpha lives in SpellCastBuffs.ApplyBuffIconDisplayAlpha)
local BUFF_ICON_FADEOUT_MS = 2000

--- Maps API status effect type to LUIE_CC_TYPE for ColorCC when EffectOverride.cc is absent.
local statusEffectTypeToLuiCc =
{
    [STATUS_EFFECT_TYPE_STUN] = LUIE_CC_TYPE_STUN,
    [STATUS_EFFECT_TYPE_SNARE] = LUIE_CC_TYPE_SNARE,
    [STATUS_EFFECT_TYPE_ROOT] = LUIE_CC_TYPE_ROOT,
    [STATUS_EFFECT_TYPE_FEAR] = LUIE_CC_TYPE_FEAR,
    [STATUS_EFFECT_TYPE_SILENCE] = LUIE_CC_TYPE_SILENCE,
    [STATUS_EFFECT_TYPE_CHARM] = LUIE_CC_TYPE_CHARM,
    [STATUS_EFFECT_TYPE_MESMERIZE] = LUIE_CC_TYPE_CHARM,
    [STATUS_EFFECT_TYPE_LEVITATE] = LUIE_CC_TYPE_PULL,
    [STATUS_EFFECT_TYPE_DAZED] = LUIE_CC_TYPE_STAGGER,
}

--- Fallback when statusEffectType is NONE but ability row still tags CC via AbilityType (see DacksDevPlayground effect debug).
local abilityTypeToLuiCc =
{
    [ABILITY_TYPE_STUN] = LUIE_CC_TYPE_STUN,
    [ABILITY_TYPE_SNARE] = LUIE_CC_TYPE_SNARE,
    [ABILITY_TYPE_SILENCE] = LUIE_CC_TYPE_SILENCE,
    [ABILITY_TYPE_KNOCKBACK] = LUIE_CC_TYPE_KNOCKBACK,
    [ABILITY_TYPE_FEAR] = LUIE_CC_TYPE_FEAR,
    [ABILITY_TYPE_DISORIENT] = LUIE_CC_TYPE_DISORIENT,
    [ABILITY_TYPE_STAGGER] = LUIE_CC_TYPE_STAGGER,
    [ABILITY_TYPE_LEVITATE] = LUIE_CC_TYPE_PULL,
    [ABILITY_TYPE_PACIFY] = LUIE_CC_TYPE_SILENCE,
    [ABILITY_TYPE_OFFBALANCE] = LUIE_CC_TYPE_STAGGER,
}

--- @param abilityId integer|nil
--- @param statusEffectType StatusEffectType|integer|nil
--- @param abilityType AbilityType|integer|nil
--- @param combatCcType integer|nil LUIE_CC_TYPE_* derived from EVENT_COMBAT_EVENT when effect row lacks API CC fields
--- @return integer|nil LUIE_CC_TYPE_* when this debuff should use a CC color
function SpellCastBuffs.ResolveEffectCcType(abilityId, statusEffectType, abilityType, combatCcType)
    if not abilityId then
        return nil
    end
    local override = Effects.EffectOverride[abilityId]
    if override and override.cc then
        return override.cc
    end
    if override and override.ccMergedType and SpellCastBuffs.SV.HideReduce then
        return override.ccMergedType
    end
    if combatCcType then
        return combatCcType
    end
    if statusEffectType and statusEffectType ~= STATUS_EFFECT_TYPE_NONE then
        local fromStatus = statusEffectTypeToLuiCc[statusEffectType]
        if fromStatus then
            return fromStatus
        end
    end
    if abilityType and abilityType ~= ABILITY_TYPE_NONE then
        return abilityTypeToLuiCc[abilityType]
    end
    return nil
end

--- Chat/debug suffix for Effect debug (Show Debug Effect) — CC resolve + fill color hint.
--- @param abilityId integer
--- @param statusEffectType StatusEffectType|integer|nil
--- @param effectType BuffEffectType|integer
--- @param abilityType AbilityType|integer|nil
--- @return string
function SpellCastBuffs.FormatEffectCcDebugSuffix(abilityId, statusEffectType, effectType, abilityType)
    if effectType ~= BUFF_EFFECT_TYPE_DEBUFF then
        return ""
    end
    local chunks = {}
    chunks[#chunks + 1] = "StaFX:" .. SpellCastBuffs.FormatStatusEffectTypeLabel(statusEffectType or STATUS_EFFECT_TYPE_NONE)
    chunks[#chunks + 1] = "AbiT:" .. SpellCastBuffs.FormatAbilityTypeLabel(abilityType or ABILITY_TYPE_NONE)
    local resolvedCc = SpellCastBuffs.ResolveEffectCcType(abilityId, statusEffectType, abilityType, nil)
    if resolvedCc then
        chunks[#chunks + 1] = "CC-->" .. SpellCastBuffs.GetLuiCcTypeLabel(resolvedCc)
    else
        chunks[#chunks + 1] = "CC-->(none)"
    end
    local override = Effects.EffectOverride[abilityId]
    if override and override.cc then
        chunks[#chunks + 1] = "Ov:" .. SpellCastBuffs.GetLuiCcTypeLabel(override.cc)
    end
    if override and override.unbreakable == 1 and SpellCastBuffs.SV.ColorUnbreakable then
        chunks[#chunks + 1] = "|cBBBBFFFill:unbreakable|r"
    elseif SpellCastBuffs.SV.ColorCC then
        if resolvedCc then
            chunks[#chunks + 1] = "|c00E200Fill:CC|r"
        else
            chunks[#chunks + 1] = "|cFF6666Fill:debuff|r"
        end
    end
    return " [" .. table.concat(chunks, " ") .. "]"
end

-- Helper function to get CC color
--- @param ccType integer
--- @return table
local function getCCColor(ccType)
    local ccColors =
    {
        [LUIE_CC_TYPE_STUN] = SpellCastBuffs.SV.colors.stun,
        [LUIE_CC_TYPE_KNOCKDOWN] = SpellCastBuffs.SV.colors.stun,
        [LUIE_CC_TYPE_KNOCKBACK] = SpellCastBuffs.SV.colors.knockback,
        [LUIE_CC_TYPE_PULL] = SpellCastBuffs.SV.colors.levitate,
        [LUIE_CC_TYPE_DISORIENT] = SpellCastBuffs.SV.colors.disorient,
        [LUIE_CC_TYPE_FEAR] = SpellCastBuffs.SV.colors.fear,
        [LUIE_CC_TYPE_SILENCE] = SpellCastBuffs.SV.colors.silence,
        [LUIE_CC_TYPE_STAGGER] = SpellCastBuffs.SV.colors.stagger,
        [LUIE_CC_TYPE_SNARE] = SpellCastBuffs.SV.colors.snare,
        [LUIE_CC_TYPE_ROOT] = SpellCastBuffs.SV.colors.root,
        [LUIE_CC_TYPE_CHARM] = SpellCastBuffs.SV.colors.charm,
    }
    return ccColors[ccType] or SpellCastBuffs.SV.colors.nocc
end

--- @param buff table
--- @param buffType integer
--- @param unbreakable integer
--- @param id integer
--- @param statusEffectType StatusEffectType|integer|nil
--- @param abilityType AbilityType|integer|nil
--- @param container string
--- @param combatCcType integer|nil LUIE_CC_TYPE_* derived from EVENT_COMBAT_EVENT for fake combat entries
local function SetSingleIconBuffType(buff, container, buffType, unbreakable, id, statusEffectType, abilityType, combatCcType)
    -- Determine context type and get ability name
    local contextType = (buffType == BUFF_EFFECT_TYPE_BUFF) and "buff" or "debuff"
    local abilityName = GetAbilityName(id)

    -- Helper function to determine if effect is priority
    local function isPriorityEffect()
        if contextType == "buff" then
            return SpellCastBuffs.SV.PriorityBuffTable[id] or SpellCastBuffs.SV.PriorityBuffTable[abilityName]
        else
            return SpellCastBuffs.SV.PriorityDebuffTable[id] or SpellCastBuffs.SV.PriorityDebuffTable[abilityName]
        end
    end

    -- Determine fill color based on buff type and conditions
    local function determineFillColor()
        if contextType == "buff" then
            if isPriorityEffect() then
                return SpellCastBuffs.SV.colors.prioritybuff
            elseif unbreakable == 1 and SpellCastBuffs.SV.ColorCosmetic then
                return SpellCastBuffs.SV.colors.cosmetic
            else
                return SpellCastBuffs.SV.colors.buff
            end
        else -- debuff
            if isPriorityEffect() then
                return SpellCastBuffs.SV.colors.prioritydebuff
            elseif unbreakable == 1 and SpellCastBuffs.SV.ColorUnbreakable then
                return SpellCastBuffs.SV.colors.unbreakable
            elseif SpellCastBuffs.SV.ColorCC then
                local ccType = SpellCastBuffs.ResolveEffectCcType(id, statusEffectType, abilityType, combatCcType)
                if ccType then
                    return getCCColor(ccType)
                end
                if SpellCastBuffs.SV.DamageTypeFallback and SpellCastBuffs.SV.colors.damage then
                    local now = GetFrameTimeMilliseconds()
                    local entry = SpellCastBuffs.combatDamageTypeByAbilityId and SpellCastBuffs.combatDamageTypeByAbilityId[id] or nil
                    if entry and entry.expires and entry.expires > now then
                        local dt = entry.damageType
                        local dtColor = dt and SpellCastBuffs.SV.colors.damage[dt] or nil
                        if dtColor then
                            return dtColor
                        end
                    end
                end
                return SpellCastBuffs.SV.colors.debuff
            else
                return SpellCastBuffs.SV.colors.debuff
            end
        end
    end

    -- Helper function to set progress bar colors
    local function setProgressBarColors(isDebuff, isPriority)
        local colors
        if isDebuff then
            colors = isPriority and SpellCastBuffs.SV.ProminentProgressDebuffPriorityC2 or SpellCastBuffs.SV.ProminentProgressDebuffC2
        else
            colors = isPriority and SpellCastBuffs.SV.ProminentProgressBuffPriorityC2 or SpellCastBuffs.SV.ProminentProgressBuffC2
        end

        local gradientColors = isDebuff and
            (isPriority and SpellCastBuffs.SV.ProminentProgressDebuffPriorityC1 or SpellCastBuffs.SV.ProminentProgressDebuffC1) or
            (isPriority and SpellCastBuffs.SV.ProminentProgressBuffPriorityC1 or SpellCastBuffs.SV.ProminentProgressBuffC1)

        local backdropR = 0.1 * colors[1]
        local backdropG = 0.1 * colors[2]
        local backdropB = 0.1 * colors[3]
        local backdropA = 0.75
        buff.bar.backdrop:SetCenterColor(backdropR, backdropG, backdropB, backdropA)
        buff.bar.backdrop:SetEdgeColor(backdropR, backdropG, backdropB, backdropA)
        buff.bar.bar:SetGradientColors(colors[1], colors[2], colors[3], 1, gradientColors[1], gradientColors[2], gradientColors[3], 1)
    end

    -- Apply visual settings
    local fillColor = determineFillColor()
    local labelColor = contextType == "buff" and SpellCastBuffs.SV.colors.buff or SpellCastBuffs.SV.colors.debuff
    local textColor = SpellCastBuffs.SV.RemainingTextColoured and labelColor or { 1, 1, 1, 1 }

    -- Set visual properties
    buff.frame:SetTexture("/esoui/art/actionbar/" .. contextType .. "_frame.dds")
    buff.label:SetColor(textColor[1], textColor[2], textColor[3], textColor[4])
    buff.stack:SetColor(textColor[1], textColor[2], textColor[3], textColor[4])

    local borderTexture = (contextType == "buff") and SpellCastBuffs.GetBuffBorderTexture() or SpellCastBuffs.GetDebuffBorderTexture()
    buff.back:SetTexture(borderTexture)
    SpellCastBuffs.ApplyAbilityFrameTextureCoords(buff.back, SpellCastBuffs.SV.IconSize)

    -- Set cooldown color if it exists
    if buff.cd then
        buff.cd:SetFillColor(fillColor[1], fillColor[2], fillColor[3], fillColor[4])
        buff.cdFillR = fillColor[1]
        buff.cdFillG = fillColor[2]
        buff.cdFillB = fillColor[3]
        buff.cdFillA = fillColor[4]
    end

    -- Set progress bar colors if they exist
    if buff.bar then
        setProgressBarColors(buffType == BUFF_EFFECT_TYPE_DEBUFF, isPriorityEffect())
    end
end

local function CreateSingleIcon(container, effectType)
    local metaPool = SpellCastBuffs.GetBuffIconMetaPool(container)
    local buff, poolKey = metaPool:AcquireObject()
    buff.poolKey = poolKey

    SpellCastBuffs.ApplySingleIconLayout(container, buff)

    if effectType then
        local borderTexture = (effectType == BUFF_EFFECT_TYPE_BUFF) and SpellCastBuffs.GetBuffBorderTexture() or SpellCastBuffs.GetDebuffBorderTexture()
        buff.back:SetTexture(borderTexture)
        SpellCastBuffs.ApplyAbilityFrameTextureCoords(buff.back, SpellCastBuffs.SV.IconSize)
    end

    buff:SetExcludeFromFlexbox(false)
    SpellCastBuffs.ApplyIconFlexMargin(container, buff)
    buff.lastFlexContainer = container
    buff:SetHidden(false)

    return buff
end

-- Quadratic easing out - decelerating to zero velocity (For buff fade)
--- @param t number
--- @param b number
--- @param c number
--- @param d number
--- @return number
local function EaseOutQuad(t, b, c, d)
    -- protect against 1 / 0
    if t == 0 then
        t = 0.0001
    end
    if d == 0 then
        d = 0.0001
    end

    t = t / d
    return -c * t * (t - 2) + b
end

--- @param buff SpellCastBuffs_BuffIcon_Control
--- @param container string
--- @param remain number|nil
local function ApplyBuffIconExpireFade(buff, container, remain)
    local fadeAlpha = 1
    if SpellCastBuffs.SV.FadeOutIcons and remain ~= nil and remain < BUFF_ICON_FADEOUT_MS then
        fadeAlpha = EaseOutQuad(remain, 0, 1, BUFF_ICON_FADEOUT_MS)
    end

    SpellCastBuffs.ApplyBuffIconDisplayAlpha(buff, container, fadeAlpha)
end

--- @param currentTimeMs number
--- @param sortedList table
--- @param container string
local function updateBar(currentTimeMs, sortedList, container)
    -- updateIcons always assigns icons[i] = sortedList[i] (1-->N order).
    -- Flex direction handles visual ordering, so bar values must use the same 1-->N mapping.
    -- Old sort-direction–based reverse iteration no longer applies.
    for i = 1, #sortedList do
        local effect = sortedList[i]
        local buff = SpellCastBuffs.BuffContainers[container].icons[i]
        local auraStarts = effect.starts or nil
        local auraEnds = effect.ends or nil
        -- Modify recall penalty to show forced max duration
        if effect.id == 999016 then
            auraStarts = auraEnds - 600000
        end

        local ground = effect.groundLabel
        local remain = (effect.ends ~= nil) and (effect.ends - currentTimeMs) or nil

        if buff and buff.bar and buff.bar.bar then
            if auraStarts and auraEnds and remain and remain > 0 and not ground then
                buff.bar.bar:SetValue(1 - ((currentTimeMs - auraStarts) / (auraEnds - auraStarts)))
            elseif effect.werewolf then
                buff.bar.bar:SetValue(effect.werewolf)
            else
                buff.bar.bar:SetValue(1)
            end
        end
    end
end

-- Reused each OnUpdate tick to avoid allocating fresh tables (GC pressure).
local g_buffsSorted = {}
local g_sortedCounts = {}
local g_displayUidCounter = {}
local g_seenAbilityIdPerContainer = {}
local g_cachedDisplaySortedLists = {}
local g_isProminentContainer = {}

--- @param remain number
--- @param container string
--- @return string|nil
local function FormatRemainLabelText(remain, container)
    if remain > 86400000 then
        return string_format("%d d", zo_floor(remain / 86400000))
    elseif remain > 6000000 then
        return string_format("%dh", zo_floor(remain / 3600000))
    elseif remain > 600000 then
        return string_format("%dm", zo_floor(remain / 60000))
    elseif remain > 60000 or container == "player_long" then
        local m = zo_floor(remain / 60000)
        local s = remain / 1000 - 60 * m
        return string_format("%d:%.2d", m, s)
    end
    return string_format(SpellCastBuffs.SV.RemainingTextMillis and "%.1f" or "%.1d", remain / 1000)
end

--- @param buff SpellCastBuffs_BuffIcon_Control
--- @param container string
--- @param force boolean
local function ApplyIconLayoutIfNeeded(buff, container, force)
    local iconSize = SpellCastBuffs.SV.IconSize
    if force
    or buff.lastAppliedIconSize ~= iconSize
    or buff.lastLayoutVersion ~= SpellCastBuffs.displayLayoutVersion
    or buff.lastFlexContainer ~= container then
        buff:SetExcludeFromFlexbox(false)
        SpellCastBuffs.ApplyBuffIconSlotDimensions(buff, iconSize)
        SpellCastBuffs.ApplyIconFlexMargin(container, buff)
        buff.lastFlexContainer = container
        buff.lastAppliedIconSize = iconSize
        buff.lastLayoutVersion = SpellCastBuffs.displayLayoutVersion
        SpellCastBuffs.ApplyBuffIconAbilityIdLayout(buff)
    end
end

--- @param currentTimeMs number
--- @param sortedList table
--- @param container string
local function updateIconsStructure(currentTimeMs, sortedList, container)
    local iconsNum = #sortedList
    local index = 0

    for i = 1, iconsNum do
        local effect = sortedList[i]
        index = index + 1

        if SpellCastBuffs.BuffContainers[container].icons[index] == nil then
            SpellCastBuffs.BuffContainers[container].icons[index] = CreateSingleIcon(container, effect.type)
        end

        local buff = SpellCastBuffs.BuffContainers[container].icons[index]

        local slotRebound = effect.iconNum ~= index
        ApplyIconLayoutIfNeeded(buff, container, slotRebound)

        if buff.abilityId and effect.id and SpellCastBuffs.SV.ShowDebugAbilityId then
            SpellCastBuffs.UpdateAbilityIdDebugLabel(buff, tostring(effect.id))
        elseif buff.abilityId and not SpellCastBuffs.SV.ShowDebugAbilityId then
            buff.abilityId:SetHidden(true)
        end

        if slotRebound then
            buff:SetHidden(true)
            effect.iconNum = index
            effect.restart = true
            local name = (effect.name ~= nil) and effect.name or nil
            local statusFx = effect.debugMeta and effect.debugMeta.statusEffectType or nil
            local abiType = effect.debugMeta and effect.debugMeta.abilityType or nil
            local combatCcType = effect.combatCcType or nil
            SetSingleIconBuffType(buff, container, effect.type, effect.unbreakable, effect.id, statusFx, abiType, combatCcType)

            buff.effectId = effect.id
            buff.effectName = name
            buff.buffType = effect.type
            buff.buffSlot = effect.buffSlot
            buff.tooltip = effect.tooltip
            buff.isArtificial = effect.artificial == true
            buff.artificialEffectId = effect.artificialEffectId or effect.uid
            buff.duration = effect.dur or 0
            buff.debugMeta = effect.debugMeta

            buff.icon:SetTexture(effect.icon)
            buff:SetAlpha(1)
            SpellCastBuffs.ResetBuffIconChromeAlphas(buff)

            local remain = (effect.ends ~= nil) and (effect.ends - currentTimeMs) or nil
            if not remain or effect.fakeDuration then
                local staticLabel
                if effect.toggle then
                    staticLabel = "T"
                elseif effect.groundLabel then
                    staticLabel = "G"
                end
                if buff.lastLabelText ~= staticLabel then
                    buff.label:SetText(staticLabel)
                    buff.lastLabelText = staticLabel
                end
            else
                buff.lastLabelText = nil
            end

            if buff.name then
                local nameText = zo_strformat("<<C:1>>", effect.name)
                buff.name:SetText(nameText)
            end
        end

        buff.container = container
        SpellCastBuffs.ApplyBuffIconChrome(buff, container, effect)
        buff:SetHidden(false)
    end

    SpellCastBuffs.ReleaseSurplusBuffIcons(container, iconsNum)
end

--- @param currentTimeMs number
--- @param sortedList table
--- @param container string
local function updateIconsLight(currentTimeMs, sortedList, container)
    if SpellCastBuffs.BuffContainers[container].skipUpdate then
        SpellCastBuffs.BuffContainers[container].skipUpdate = SpellCastBuffs.BuffContainers[container].skipUpdate + 1
        if SpellCastBuffs.BuffContainers[container].skipUpdate > 1 then
            SpellCastBuffs.BuffContainers[container].skipUpdate = 0
        else
            return
        end
    end

    local iconsNum = #sortedList
    for i = 1, iconsNum do
        local effect = sortedList[i]
        local buff = SpellCastBuffs.BuffContainers[container].icons[i]
        if not buff then
            break
        end

        local remain = (effect.ends ~= nil) and (effect.ends - currentTimeMs) or nil

        if effect.stack and effect.stack > 0 then
            local stackText = string_format("%s", effect.stack)
            if buff.lastStackText ~= stackText then
                buff.stack:SetText(stackText)
                buff.lastStackText = stackText
            end
            buff.stack:SetHidden(false)
        else
            buff.stack:SetHidden(true)
            buff.lastStackText = nil
        end

        if remain and not effect.fakeDuration then
            local labelText = FormatRemainLabelText(remain, container)
            if buff.lastLabelText ~= labelText then
                buff.label:SetText(labelText)
                buff.lastLabelText = labelText
            end
        end

        local showRadialCooldown = SpellCastBuffs.ShouldShowBuffIconRadialCooldown(container, effect)
        if buff.cd and container ~= "player_long" then
            if showRadialCooldown then
                if effect.restart then
                    if effect.id == 999016 then
                        effect.dur = 600000
                    end
                    buff.cd:StartCooldown(remain, effect.dur, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
                    effect.restart = false
                end
            elseif effect.restart or not buff.cd:IsHidden() then
                SpellCastBuffs.ApplyBuffIconInsetVisual(buff, container, effect)
                effect.restart = false
            end
        end

        if buff.lastChromeLayoutVersion ~= SpellCastBuffs.displayLayoutVersion or effect.restart then
            SpellCastBuffs.ApplyBuffIconChrome(buff, container, effect)
        end

        if buff.abilityId then
            if SpellCastBuffs.SV.ShowDebugAbilityId and effect.id then
                SpellCastBuffs.UpdateAbilityIdDebugLabel(buff, tostring(effect.id))
            else
                buff.abilityId:SetHidden(true)
                buff.lastAbilityIdText = nil
                buff.abilityIdLabelDirty = nil
            end
        end

        ApplyBuffIconExpireFade(buff, container, remain)
    end
end

-- Helper function to sort buffs
--- @param x {
--- dur: number|nil,
--- ends: number|nil,
--- groundLabel: string,
--- name: string,
--- starts: number,
--- toggle: boolean,
--- displayUid?: number,
--- }
--- @param y {
--- dur: number|nil,
--- ends: number|nil,
--- groundLabel: string,
--- name: string,
--- starts: number,
--- toggle: boolean,
--- displayUid?: number,
--- }
--- @return boolean?
local function buffSort(x, y)
    local xDuration = (x.ends == nil or x.dur == 0 or x.groundLabel or x.toggle) and 0 or x.dur
    local yDuration = (y.ends == nil or y.dur == 0 or y.groundLabel or y.toggle) and 0 or y.dur
    -- Sort toggle effects
    if x.toggle or y.toggle then
        if xDuration == 0 and yDuration == 0 then
            if x.toggle and y.toggle then
                return (x.name < y.name)
            elseif x.toggle and not y.toggle then
                return (xDuration == 0)
            end
        else
            return (xDuration == 0)
        end
        -- Sort permanent/ground effects (might separate these at some point but for now want the sorting function simplified)
    elseif xDuration == 0 and yDuration == 0 then
        return (x.name < y.name)
        -- Both non-permanent
    elseif xDuration ~= 0 and yDuration ~= 0 then
        if x.starts == y.starts then
            if x.name == y.name then
                local xDisplayUid = x.displayUid or 0
                local yDisplayUid = y.displayUid or 0
                if xDisplayUid ~= yDisplayUid then
                    return xDisplayUid < yDisplayUid
                end
            end
            return x.name < y.name
        end
        return x.ends > y.ends
        -- One permanent, one not
    else
        return (xDuration == 0)
    end
    return nil
end

--- Appends an effect into the sorted display list for a container.
--- Hoisted to module scope (previously a local-in-OnUpdate, which allocated a
--- fresh function object every 100ms tick). All referenced state lives in
--- module-scope upvalues already (g_seenAbilityIdPerContainer / g_buffsSorted /
--- g_sortedCounts / g_displayUidCounter), so no behavioral change.
--- @param container string
--- @param effect table
local function appendSortedEffect(container, effect)
    if effect.id then
        local seen = g_seenAbilityIdPerContainer[container]
        if not seen then
            seen = {}
            g_seenAbilityIdPerContainer[container] = seen
        end
        local existingIndex = seen[effect.id]
        if existingIndex then
            local existing = g_buffsSorted[container][existingIndex]
            if effect.buffSlot and existing and not existing.buffSlot then
                g_buffsSorted[container][existingIndex] = effect
            end
            return
        end
    end
    g_sortedCounts[container] = (g_sortedCounts[container] or 0) + 1
    g_displayUidCounter[container] = (g_displayUidCounter[container] or 0) + 1
    effect.displayUid = g_displayUidCounter[container]
    local index = g_sortedCounts[container]
    g_buffsSorted[container][index] = effect
    if effect.id then
        local seen = g_seenAbilityIdPerContainer[container]
        if seen then
            seen[effect.id] = index
        end
    end
end

--- Rebuilds the sorted display lists from SpellCastBuffs.EffectsList.
--- Hoisted out of OnUpdate (was a nested local closure recreated each tick).
--- currentTimeMs is passed explicitly since it's the only per-tick value.
--- @param currentTimeMs number
local function rebuildDisplaySortedLists(currentTimeMs)
    SpellCastBuffs.displayLayoutVersion = SpellCastBuffs.displayLayoutVersion + 1

    for _, container in pairs(SpellCastBuffs.containerRouting) do
        if not g_buffsSorted[container] then
            g_buffsSorted[container] = {}
        else
            ZO_ClearNumericallyIndexedTable(g_buffsSorted[container])
        end
        if not g_seenAbilityIdPerContainer[container] then
            g_seenAbilityIdPerContainer[container] = {}
        else
            ZO_ClearTable(g_seenAbilityIdPerContainer[container])
        end
        g_sortedCounts[container] = 0
        g_displayUidCounter[container] = 0
        g_isProminentContainer[container] = (container == "prominentbuffs" or container == "prominentdebuffs")
    end
    if not g_buffsSorted.player_long then
        g_buffsSorted.player_long = {}
    else
        ZO_ClearNumericallyIndexedTable(g_buffsSorted.player_long)
    end
    if not g_seenAbilityIdPerContainer.player_long then
        g_seenAbilityIdPerContainer.player_long = {}
    else
        ZO_ClearTable(g_seenAbilityIdPerContainer.player_long)
    end
    g_sortedCounts.player_long = 0
    g_displayUidCounter.player_long = 0

    for context, effectsList in pairs(SpellCastBuffs.EffectsList) do
        local container = SpellCastBuffs.containerRouting[context]
        for _, v in pairs(effectsList) do
            if container and v.starts <= currentTimeMs then
                if v.target == "prominent" then
                    appendSortedEffect(container, v)
                elseif v.type == BUFF_EFFECT_TYPE_DEBUFF or v.forced == "short" or not (v.forced == "long" or v.ends == nil or v.dur == 0) then
                    if v.target == "reticleover" and SpellCastBuffs.SV.ShortTermEffects_Target then
                        appendSortedEffect(container, v)
                    elseif v.target == "player" and SpellCastBuffs.SV.ShortTermEffects_Player then
                        appendSortedEffect(container, v)
                    end
                elseif v.target == "reticleover" and SpellCastBuffs.SV.LongTermEffects_Target then
                    appendSortedEffect(container, v)
                elseif v.target == "player" and SpellCastBuffs.SV.LongTermEffects_Player then
                    if SpellCastBuffs.SV.LongTermEffectsSeparate and not (container == "prominentbuffs" or container == "prominentdebuffs") then
                        appendSortedEffect("player_long", v)
                    else
                        appendSortedEffect(container, v)
                    end
                end
            end
        end
    end

    for _, container in pairs(SpellCastBuffs.containerRouting) do
        table_sort(g_buffsSorted[container], buffSort)
        g_cachedDisplaySortedLists[container] = g_buffsSorted[container]
        updateIconsStructure(currentTimeMs, g_buffsSorted[container], container)
    end
    if g_buffsSorted.player_long then
        table_sort(g_buffsSorted.player_long, buffSort)
        g_cachedDisplaySortedLists.player_long = g_buffsSorted.player_long
        updateIconsStructure(currentTimeMs, g_buffsSorted.player_long, "player_long")
    end

    if SpellCastBuffs.SV.ShowDebugAbilityId then
        SpellCastBuffs.ScheduleAbilityIdDebugLabelRefresh()
    end
end

-- Runs OnUpdate - 100 ms buffer
--- @param currentTimeMs number
function SpellCastBuffs.OnUpdate(currentTimeMs)
    SpellCastBuffs.EnforceDisplayAlpha()

    -- Display Block buff for player if enabled (before display rebuild)
    if SpellCastBuffs.SV.ShowBlockPlayer and not SpellCastBuffs.SV.HidePlayerBuffs then
        if IsBlockActive() and not IsPlayerStunned() then
            local abilityId = 974
            local abilityName = Abilities.Innate_Brace
            local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
            local effectsList = SpellCastBuffs.EffectsList[context]
            local existing = effectsList and effectsList[abilityId]
            if not existing then
                SpellCastBuffs.MarkDisplayDirty()
                existing =
                {
                    uid = abilityId,
                    target = SpellCastBuffs.DetermineTarget(context),
                    type = 1,
                    id = abilityId,
                    name = abilityName,
                    icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_BLOCK_DDS,
                    dur = 0,
                    starts = currentTimeMs - 1,
                    ends = nil,
                    restart = true,
                    iconNum = 0,
                    forced = "short",
                    toggle = true,
                }
                effectsList[abilityId] = existing
            else
                existing.restart = true
            end
            if not SpellCastBuffs.blockPlayerEffectActive then
                SpellCastBuffs.MarkDisplayDirty()
            end
            SpellCastBuffs.blockPlayerEffectActive = true
        else
            if SpellCastBuffs.blockPlayerEffectActive then
                SpellCastBuffs.ClearPlayerBuff(974)
            end
            SpellCastBuffs.blockPlayerEffectActive = false
        end
    end

    local expiredAny = false

    for _, effectsList in pairs(SpellCastBuffs.EffectsList) do
        for k, v in pairs(effectsList) do
            if v.ends ~= nil and v.dur > 0 and v.ends < currentTimeMs then
                effectsList[k] = nil
                expiredAny = true
            end
        end
    end
    if expiredAny then
        SpellCastBuffs.MarkDisplayDirty()
    end

    -- Sweep expired ground-effect removal-protection timestamps. These are
    -- written in _OnEffectChangedGround.lua:120 as `protectAbilityRemoval[id] = currentTimeMs + 150`
    -- and only cleared on the next gain of the same ground ability. Without a
    -- sweep the table retains one entry for every distinct ground abilityId
    -- encountered during the session (bounded but real growth).
    if SpellCastBuffs.protectAbilityRemoval then
        for abilityId, expireAt in pairs(SpellCastBuffs.protectAbilityRemoval) do
            if expireAt < currentTimeMs then
                SpellCastBuffs.protectAbilityRemoval[abilityId] = nil
            end
        end
    end

    -- Sweep stale internal-stack-counter entries. _OnCombatEventHelpers.lua:457-469
    -- clears the counter only when the associated fake-effect entry exists and the
    -- counter reaches zero; on edge paths (fake entry cleared elsewhere first) the
    -- counter can stick. Nil any non-positive value so the map stays bounded to
    -- abilities with live fake stacks.
    if SpellCastBuffs.InternalStackCounter then
        for abilityId, stackCount in pairs(SpellCastBuffs.InternalStackCounter) do
            if not stackCount or stackCount <= 0 then
                SpellCastBuffs.InternalStackCounter[abilityId] = nil
            end
        end
    end

    if SpellCastBuffs.displayDirty then
        rebuildDisplaySortedLists(currentTimeMs)
        SpellCastBuffs.displayDirty = false
    end

    for _, container in pairs(SpellCastBuffs.containerRouting) do
        local sortedList = g_cachedDisplaySortedLists[container]
        if sortedList then
            updateIconsLight(currentTimeMs, sortedList, container)
        end
    end

    local playerLongList = g_cachedDisplaySortedLists.player_long
    if playerLongList then
        updateIconsLight(currentTimeMs, playerLongList, "player_long")
    end

    for _, container in pairs(SpellCastBuffs.containerRouting) do
        if g_isProminentContainer[container] then
            local sortedList = g_cachedDisplaySortedLists[container]
            if sortedList then
                updateBar(currentTimeMs, sortedList, container)
            end
        end
    end

    if SpellCastBuffs.devDebugEnabled then
        SpellCastBuffs.RecordBuffIconPoolHighWater()
    end

    SpellCastBuffs.TickDebugMetaTooltipLiveUpdate()
end
