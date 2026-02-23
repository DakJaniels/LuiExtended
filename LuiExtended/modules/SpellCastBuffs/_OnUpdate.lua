-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local UI = LUIE.UI

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
local Abilities = Data.Abilities
local Effects = Data.Effects

local zo_floor = zo_floor
local zo_min = zo_min
local string_format = string.format
local zo_strformat = zo_strformat
local table_sort = table.sort
local GetAbilityName = GetAbilityName
local IsBlockActive = IsBlockActive
local IsPlayerStunned = IsPlayerStunned


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
    }
    return ccColors[ccType] or SpellCastBuffs.SV.colors.nocc
end

--- @param buff table
--- @param buffType integer
--- @param unbreakable integer
--- @param id integer
local SetSingleIconBuffType = function (buff, buffType, unbreakable, id)
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
            elseif SpellCastBuffs.SV.ColorCC and Effects.EffectOverride[id] and Effects.EffectOverride[id].cc then
                return getCCColor(Effects.EffectOverride[id].cc)
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

        buff.bar.backdrop:SetCenterColor(0.1 * colors[1], 0.1 * colors[2], 0.1 * colors[3], 0.75)
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

    buff.back:SetHidden(true)
    buff.drop:SetHidden(false)

    -- Set cooldown color if it exists
    if buff.cd then
        buff.cd:SetFillColor(fillColor[1], fillColor[2], fillColor[3], fillColor[4])
    end

    -- Set progress bar colors if they exist
    if buff.bar then
        setProgressBarColors(buffType == BUFF_EFFECT_TYPE_DEBUFF, isPriorityEffect())
    end
end

-- Initialize buff icon pools per container (called once on module init)
local buffIconPools = {}

local function GetOrCreateBuffIconPool(container)
    if not buffIconPools[container] then
        local function BuffIconFactory(objectPool)
            local effectType = nil -- Will be set when acquired

            -- Create main buff container as a flex item inside iconHolder.
            -- Explicitly disable grow/shrink so icons stay fixed size regardless of container pressure.
            -- Start excluded from yoga layout — included only when actually shown via CreateSingleIcon.
            local buff = UI:Backdrop(SpellCastBuffs.BuffContainers[container].iconHolder, nil, nil, { 0, 0, 0, 0.5 }, { 0, 0, 0, 1 }, false)
            buff:SetFlexGrow(0)
            buff:SetFlexShrink(0)
            buff:SetExcludeFromFlexbox(true)
            -- Setup mouse interaction
            buff:SetMouseEnabled(true)
            buff:SetHandler("OnMouseEnter", SpellCastBuffs.Buff_OnMouseEnter)
            buff:SetHandler("OnMouseExit", SpellCastBuffs.Buff_OnMouseExit)
            buff:SetHandler("OnMouseUp", SpellCastBuffs.Buff_OnMouseUp)

            -- Border layer - hidden by default, shown only for non-collectible buffs
            buff.back = UI:Texture(buff, "fill", nil, "EsoUI/Art/ActionBar/abilityFrame_buff.dds", DL_BACKGROUND, true)

            -- Glow border layer
            buff.frame = UI:Texture(buff, { CENTER, CENTER }, nil, nil, DL_OVERLAY, false)

            -- Background layer (except for player_long container)
            if container ~= "player_long" then
                -- Create background texture
                buff.iconbg = UI:Texture(buff, "fill", nil, "EsoUI/Art/ActionBar/abilityInset.dds", DL_CONTROLS, false)
                -- Create dark backdrop behind the texture
                local bgBackdrop = UI:Backdrop(buff.iconbg, "fill", nil, { 0, 0, 0, 0.9 }, { 0, 0, 0, 0.9 }, false)
                bgBackdrop:SetDrawLevel(DL_CONTROLS)
            end

            -- Collectible/mount background
            buff.drop = UI:Texture(buff, nil, nil, LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_BACKGROUND_DDS, DL_BACKGROUND, true)

            -- Main ability icon
            buff.icon = UI:Texture(buff, nil, nil, "/esoui/art/icons/icon_missing.dds", DL_CONTROLS, false)

            -- Duration label
            buff.label = UI:Label(buff, nil, nil, nil, SpellCastBuffs.buffsFont, nil, false)
            buff.label:SetAnchor(TOPLEFT, buff, LEFT, -SpellCastBuffs.padding, -SpellCastBuffs.SV.LabelPosition)
            buff.label:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, SpellCastBuffs.padding, -2)

            -- Debug ability ID label
            buff.abilityId = UI:Label(buff, { CENTER, CENTER }, nil, nil, SpellCastBuffs.buffsFont, nil, false)
            buff.abilityId:SetDrawLayer(DL_OVERLAY)
            buff.abilityId:SetDrawTier(DT_MEDIUM)

            -- Stack count label
            buff.stack = UI:Label(buff, nil, nil, nil, SpellCastBuffs.buffsFont, nil, false)
            buff.stack:SetAnchor(CENTER, buff, BOTTOMLEFT, 0, 0)
            buff.stack:SetAnchor(CENTER, buff, TOPRIGHT, -SpellCastBuffs.padding * 3, SpellCastBuffs.padding * 3)

            if buff.iconbg then
                buff.cd = UI:ControlWithType(buff, "fill", nil, false, nil, CT_COOLDOWN)
                buff.cd:SetAnchor(TOPLEFT, buff, TOPLEFT, 1, 1)
                buff.cd:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -1, -1)
                buff.cd:SetDrawLayer(DL_BACKGROUND)
            end

            if container == "prominentbuffs" or container == "prominentdebuffs" then
                buff.effectType = effectType
                buff.name = UI:Label(buff, nil, nil, nil, SpellCastBuffs.prominentFont, nil, false)

                -- Create progress bar
                buff.bar =
                {
                    backdrop = UI:Backdrop(buff, nil, { 154, 16 }, nil, nil, false),
                    bar = UI:StatusBar(buff, nil, { 150, 12 }, nil, false),
                }

                -- Setup bar properties
                buff.bar.backdrop:SetEdgeTexture("", 8, 2, 2, 2)
                buff.bar.backdrop:SetDrawLayer(DL_BACKGROUND)
                buff.bar.backdrop:SetDrawLevel(DL_CONTROLS)
                buff.bar.bar:SetMinMax(0, 1)
            end

            return buff
        end

        local function BuffIconReset(buff)
            buff:SetHidden(true)
            buff:SetExcludeFromFlexbox(true)
            buff:ClearAnchors()
            buff:SetAlpha(1)
            if buff.cd then
                buff.cd:StartCooldown(0, 0, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
            end
            buff.label:SetText("")
            buff.stack:SetHidden(true)
            if buff.name then
                buff.name:SetText("")
            end
            if buff.bar then
                buff.bar.bar:SetValue(0)
            end
        end

        -- Create the pool
        buffIconPools[container] = ZO_ObjectPool:New(BuffIconFactory, BuffIconReset)
    end

    return buffIconPools[container]
end

local CreateSingleIcon = function (container, effectType)
    local pool = GetOrCreateBuffIconPool(container)
    local buff = pool:AcquireObject()

    -- Reset icon properties for first use
    SpellCastBuffs.ResetSingleIcon(container, buff)

    -- Include in Yoga first, then (re)apply margins — Yoga may clear node properties
    -- on the exclude→include transition so margins must be set after SetExcludeFromFlexbox(false).
    buff:SetExcludeFromFlexbox(false)
    SpellCastBuffs.ApplyIconFlexMargin(container, buff)
    buff:SetHidden(false)

    return buff
end

-- Quadratic easing out - decelerating to zero velocity (For buff fade)
--- @param t number
--- @param b number
--- @param c number
--- @param d number
--- @return number
local EaseOutQuad = function (t, b, c, d)
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

--- @param currentTimeMs number
--- @param sortedList table
--- @param container string
local updateBar = function (currentTimeMs, sortedList, container)
    -- updateIcons always assigns icons[i] = sortedList[i] (1→N order).
    -- Flex direction handles visual ordering, so bar values must use the same 1→N mapping.
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

--- @param currentTimeMs number
--- @param sortedList table
--- @param container string
local updateIcons = function (currentTimeMs, sortedList, container)
    -- Special workaround for container with player long buffs. We do not need to update it every 100ms, but rather 3 times less often
    if SpellCastBuffs.BuffContainers[container].skipUpdate then
        SpellCastBuffs.BuffContainers[container].skipUpdate = SpellCastBuffs.BuffContainers[container].skipUpdate + 1
        if SpellCastBuffs.BuffContainers[container].skipUpdate > 1 then
            SpellCastBuffs.BuffContainers[container].skipUpdate = 0
        else
            return
        end
    end

    local iconsNum = #sortedList

    -- Flex layout handles visual ordering; always iterate 1→N in sorted order
    local index = 0 -- Global icon counter
    for i = 1, iconsNum do
        -- Get current buff definition
        local effect = sortedList[i]
        index = index + 1
        -- Get or create icon from pool
        if SpellCastBuffs.BuffContainers[container].icons[index] == nil then
            SpellCastBuffs.BuffContainers[container].icons[index] = CreateSingleIcon(container, effect.type)
        end

        -- Calculate remaining time
        local remain = (effect.ends ~= nil) and (effect.ends - currentTimeMs) or nil
        local name = (effect.name ~= nil) and effect.name or nil

        local buff = SpellCastBuffs.BuffContainers[container].icons[index]
        -- Include in Yoga FIRST, then set margins.
        -- SetExcludeFromFlexbox may clear Yoga node properties on the transition,
        -- so margins must be (re)applied after the node is included, not before.
        buff:SetExcludeFromFlexbox(false)
        SpellCastBuffs.ApplyIconFlexMargin(container, buff)
        buff:SetHidden(false)

        -- If previously this icon was used for different effect, then setup it again
        if effect.iconNum ~= index then
            effect.iconNum = index
            effect.restart = true
            SetSingleIconBuffType(buff, effect.type, effect.unbreakable, effect.id)

            -- Setup Info for Tooltip function to pull
            buff.effectId = effect.id
            buff.effectName = name
            buff.buffType = effect.type
            buff.buffSlot = effect.buffSlot
            buff.tooltip = effect.tooltip
            buff.duration = effect.dur or 0
            buff.container = container

            if effect.backdrop then
                buff.drop:SetHidden(false)
            else
                buff.drop:SetHidden(true)
            end
            buff.icon:SetTexture(effect.icon)
            buff:SetAlpha(1)
            buff:SetHidden(false)
            if not remain or effect.fakeDuration then
                if effect.toggle then
                    buff.label:SetText("T")
                elseif effect.groundLabel then
                    buff.label:SetText("G")
                else
                    buff.label:SetText(nil)
                end
            end

            if buff.abilityId and effect.id then
                buff.abilityId:SetText(effect.id)
            end

            if buff.name then
                buff.name:SetText(zo_strformat("<<C:1>>", effect.name))
            end
        end

        if effect.stack and effect.stack > 0 then
            buff.stack:SetText(string_format("%s", effect.stack))
            buff.stack:SetHidden(false)
        else
            buff.stack:SetHidden(true)
        end

        -- For update remaining text. For temporary effects this is not very efficient, but we have not much such effects
        if remain and not effect.fakeDuration then
            if remain > 86400000 then
                -- more then 1 day
                buff.label:SetText(string_format("%d d", zo_floor(remain / 86400000)))
            elseif remain > 6000000 then
                -- over 100 minutes - display XXh
                buff.label:SetText(string_format("%dh", zo_floor(remain / 3600000)))
            elseif remain > 600000 then
                -- over 10 minutes - display XXm
                buff.label:SetText(string_format("%dm", zo_floor(remain / 60000)))
            elseif remain > 60000 or container == "player_long" then
                local m = zo_floor(remain / 60000)
                local s = remain / 1000 - 60 * m
                buff.label:SetText(string_format("%d:%.2d", m, s))
            else
                buff.label:SetText(string_format(SpellCastBuffs.SV.RemainingTextMillis and "%.1f" or "%.1d", remain / 1000))
            end
        end
        if effect.restart and buff.cd ~= nil then
            -- Modify recall penalty to show forced max duration
            if effect.id == 999016 then
                effect.dur = 600000
            end
            if remain == nil or effect.dur == nil or effect.dur == 0 or effect.fakeDuration then
                buff.cd:StartCooldown(0, 0, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_REMAINING, false)
            else
                buff.cd:StartCooldown(remain, effect.dur, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false)
                effect.restart = false
            end
        end

        -- Now possibly fade out expiring icon
        if SpellCastBuffs.SV.FadeOutIcons and remain ~= nil and remain < 2000 then
            -- buff:SetAlpha( 0.05 + remain/2106 )
            buff:SetAlpha(EaseOutQuad(remain, 0, 1, 2000))
        end
    end

    -- Hide rest of icons and remove them from yoga layout so they don't affect wrap calculations
    for i = iconsNum + 1, #SpellCastBuffs.BuffContainers[container].icons do
        local icon = SpellCastBuffs.BuffContainers[container].icons[i]
        icon:SetHidden(true)
        icon:SetExcludeFromFlexbox(true)
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
--- }
--- @param y {
--- dur: number|nil,
--- ends: number|nil,
--- groundLabel: string,
--- name: string,
--- starts: number,
--- toggle: boolean,
--- }
--- @return boolean?
local buffSort = function (x, y)
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
        return (x.starts == y.starts) and (x.name < y.name) or (x.ends > y.ends)
        -- One permanent, one not
    else
        return (xDuration == 0)
    end
    return nil
end

-- Runs OnUpdate - 100 ms buffer
--- @param currentTimeMs number
function SpellCastBuffs.OnUpdate(currentTimeMs)
    local buffsSorted = {}
    local sortedCounts = {}
    local needs_update = {}
    local isProminent = {}

    -- And reset sizes of already existing icons
    for _, container in pairs(SpellCastBuffs.containerRouting) do
        needs_update[container] = true
        -- Prepare sort container
        if buffsSorted[container] == nil then
            buffsSorted[container] = {}
        end
        sortedCounts[container] = 0
        -- Refresh prominent buff labels on each update tick
        if container == "prominentbuffs" or container == "prominentdebuffs" then
            isProminent[container] = true
        end
    end

    -- Filter expired events and build array for sorting
    for context, effectsList in pairs(SpellCastBuffs.EffectsList) do
        local container = SpellCastBuffs.containerRouting[context]
        for k, v in pairs(effectsList) do
            -- Remove effect (that is not permanent and has duration)
            if v.ends ~= nil and v.dur > 0 and v.ends < currentTimeMs then
                effectsList[k] = nil
            elseif container then
                -- Add icons to to-be-sorted list only if effect already started
                if v.starts < currentTimeMs then
                    -- Filter Effects
                    -- Always show prominent effects
                    if v.target == "prominent" then
                        sortedCounts[container] = sortedCounts[container] + 1
                        buffsSorted[container][sortedCounts[container]] = v
                        -- If the effect is not flagged as long or 0 duration and flagged to display in short container, then display normally.
                    elseif v.type == BUFF_EFFECT_TYPE_DEBUFF or v.forced == "short" or not (v.forced == "long" or v.ends == nil or v.dur == 0) then
                        if v.target == "reticleover" and SpellCastBuffs.SV.ShortTermEffects_Target then
                            sortedCounts[container] = sortedCounts[container] + 1
                            buffsSorted[container][sortedCounts[container]] = v
                        elseif v.target == "player" and SpellCastBuffs.SV.ShortTermEffects_Player then
                            sortedCounts[container] = sortedCounts[container] + 1
                            buffsSorted[container][sortedCounts[container]] = v
                        end
                        -- If the effect is a long term effect on the target then use Long Term Target settings.
                    elseif v.target == "reticleover" and SpellCastBuffs.SV.LongTermEffects_Target then
                        sortedCounts[container] = sortedCounts[container] + 1
                        buffsSorted[container][sortedCounts[container]] = v
                        -- If the effect is a long term effect on the player then use Long Term Player settings.
                    elseif v.target == "player" and SpellCastBuffs.SV.LongTermEffects_Player then
                        -- Choose container for long-term player buffs
                        if SpellCastBuffs.SV.LongTermEffectsSeparate and not (container == "prominentbuffs" or container == "prominentdebuffs") then
                            sortedCounts.player_long = sortedCounts.player_long + 1
                            buffsSorted.player_long[sortedCounts.player_long] = v
                        else
                            sortedCounts[container] = sortedCounts[container] + 1
                            buffsSorted[container][sortedCounts[container]] = v
                        end
                    end
                end
            end
        end
    end

    -- Sort effects in container and draw them on screen
    for _, container in pairs(SpellCastBuffs.containerRouting) do
        if needs_update[container] then
            table_sort(buffsSorted[container], buffSort)
            updateIcons(currentTimeMs, buffsSorted[container], container)
        end
        needs_update[container] = false
    end

    for _, container in pairs(SpellCastBuffs.containerRouting) do
        if isProminent[container] then
            updateBar(currentTimeMs, buffsSorted[container], container)
        end
    end

    -- Display Block buff for player if enabled
    if SpellCastBuffs.SV.ShowBlockPlayer and not SpellCastBuffs.SV.HidePlayerBuffs then
        if IsBlockActive() and not IsPlayerStunned() then -- Is Block Active returns true when the player is stunned currently.
            local abilityId = 974
            local abilityName = Abilities.Innate_Brace
            local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
            SpellCastBuffs.EffectsList[context][abilityId] =
            {
                target = SpellCastBuffs.DetermineTarget(context),
                type = 1,
                id = abilityId,
                name = abilityName,
                icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_BLOCK_DDS,
                dur = 0,
                starts = currentTimeMs,
                ends = nil,
                restart = true,
                iconNum = 0,
                forced = "short",
                toggle = true,
            }
        else
            SpellCastBuffs.ClearPlayerBuff(974)
        end
    end
end
