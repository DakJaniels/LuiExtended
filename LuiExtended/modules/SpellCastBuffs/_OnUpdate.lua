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

-- Helper function to determine if effect is priority
--- @param contextType string
--- @param id integer
--- @param abilityName string
--- @return boolean
local function isPriorityEffect(contextType, id, abilityName)
    if contextType == "buff" then
        return SpellCastBuffs.SV.PriorityBuffTable[id] or SpellCastBuffs.SV.PriorityBuffTable[abilityName]
    else
        return SpellCastBuffs.SV.PriorityDebuffTable[id] or SpellCastBuffs.SV.PriorityDebuffTable[abilityName]
    end
end

-- Determine fill color based on buff type and conditions
--- @param contextType string
--- @param id integer
--- @param abilityName string
--- @param unbreakable integer
--- @return table
local function determineFillColor(contextType, id, abilityName, unbreakable)
    local priority = isPriorityEffect(contextType, id, abilityName)
    if contextType == "buff" then
        if priority then
            return SpellCastBuffs.SV.colors.prioritybuff
        elseif unbreakable == 1 and SpellCastBuffs.SV.ColorCosmetic then
            return SpellCastBuffs.SV.colors.cosmetic
        else
            return SpellCastBuffs.SV.colors.buff
        end
    else -- debuff
        if priority then
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
--- @param buff table
--- @param isDebuff boolean
--- @param isPriority boolean
local function setProgressBarColors(buff, isDebuff, isPriority)
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

--- @param buff table
--- @param buffType integer
--- @param unbreakable integer
--- @param id integer
local function SetSingleIconBuffType(buff, buffType, unbreakable, id)
    -- Determine context type and get ability name
    local contextType = (buffType == BUFF_EFFECT_TYPE_BUFF) and "buff" or "debuff"
    local abilityName = GetAbilityName(id)

    -- Apply visual settings
    local fillColor = determineFillColor(contextType, id, abilityName, unbreakable)
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
        local priority = isPriorityEffect(contextType, id, abilityName)
        setProgressBarColors(buff, buffType == BUFF_EFFECT_TYPE_DEBUFF, priority)
    end
end

-- Create a single buff icon control
local function CreateSingleIcon(container, effectType)
    -- Create main buff container
    local buff = UI:Backdrop(SpellCastBuffs.BuffContainers[container], nil, nil, { 0, 0, 0, 0.5 }, { 0, 0, 0, 1 }, false)
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

-- Helper to get sort iteration parameters
local function getSortIteration(container, count)
    local sortDir = SpellCastBuffs.sortDirection[container]
    if sortDir == "Right to Left" or sortDir == "Top to Bottom" then
        return count, 1, -1
    else
        return 1, count, 1
    end
end

--- @param currentTimeMs number
--- @param sortedList table
--- @param container string
local function updateBar(currentTimeMs, sortedList, container)
    local iconsNum = #sortedList
    local istart, iend, istep = getSortIteration(container, iconsNum)
    local iconsArray = SpellCastBuffs.BuffContainers[container].icons

    local index = 0 -- Global icon counter
    for i = istart, iend, istep do
        index = index + 1
        -- Get current buff definition
        local effect = sortedList[i]

        local ground = effect.groundLabel
        local remain = (effect.ends ~= nil) and (effect.ends - currentTimeMs) or nil
        local buff = iconsArray[index]
        local auraStarts = effect.starts or nil
        local auraEnds = effect.ends or nil
        -- Modify recall penalty to show forced max duration
        if effect.id == 999016 then
            auraStarts = auraEnds - 600000
        end

        -- If this isn't a permanent duration buff then update the bar on every tick
        if buff and buff.bar and buff.bar.bar then
            if auraStarts and auraEnds and remain > 0 and not ground then
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
local function updateIcons(currentTimeMs, sortedList, container)
    local containerData = SpellCastBuffs.BuffContainers[container]

    -- Special workaround for container with player long buffs. We do not need to update it every 100ms, but rather 3 times less often
    if containerData.skipUpdate then
        containerData.skipUpdate = containerData.skipUpdate + 1
        if containerData.skipUpdate > 1 then
            containerData.skipUpdate = 0
        else
            return
        end
    end

    local iconsNum = #sortedList
    local istart, iend, istep = getSortIteration(container, iconsNum)

    -- Size of icon+padding
    local iconSize = SpellCastBuffs.SV.IconSize + SpellCastBuffs.padding

    -- Set width of contol that holds icons. This will make alignment automatic
    if containerData.iconHolder then
        if containerData.alignVertical then
            containerData.iconHolder:SetDimensions(0, iconSize * iconsNum - SpellCastBuffs.padding)
        else
            containerData.iconHolder:SetDimensions(iconSize * iconsNum - SpellCastBuffs.padding, 0)
        end
    end

    -- Prepare variables for manual alignment of icons
    local row = 0 -- row counter for multi-row placement
    local next_row_break = 1
    local iconsArray = containerData.icons
    local maxIcons = containerData.maxIcons
    local prevIconsCount = containerData.prevIconsCount
    local alignmentDir = SpellCastBuffs.alignmentDirection[container]
    local iconHolder = containerData.iconHolder
    local countChanged = iconsNum ~= prevIconsCount

    -- Re-anchor all icons when count changes and iconHolder exists (to maintain chain)
    if countChanged and iconHolder then
        for j = 1, iconsNum do
            if iconsArray[j] then
                SpellCastBuffs.ResetSingleIcon(container, iconsArray[j], iconsArray[j - 1])
            end
        end
    end

    -- Iterate over list of sorted icons
    local index = 0 -- Global icon counter
    for i = istart, iend, istep do
        -- Get current buff definition
        local effect = sortedList[i]
        index = index + 1
        -- Get or create icon
        local buff = iconsArray[index]
        local isNewIcon = false
        if buff == nil then
            buff = CreateSingleIcon(container, effect.type)
            iconsArray[index] = buff
            isNewIcon = true
        end

        -- Calculate remaining time
        local remain = (effect.ends ~= nil) and (effect.ends - currentTimeMs) or nil
        local name = (effect.name ~= nil) and effect.name or nil

        -- Anchor new icon to previous one (or iconHolder for first icon) and initialize settings
        if isNewIcon then
            SpellCastBuffs.ResetSingleIcon(container, buff, iconsArray[index - 1])
        end

        -- Ensure buff is shown
        buff:SetHidden(false)

        -- Perform manual alignment
        if not containerData.iconHolder then
            if iconsNum ~= prevIconsCount and index == next_row_break then
                -- Padding of first icon in a row
                local anchor, leftPadding

                if alignmentDir then
                    if alignmentDir == LEFT then
                        anchor = TOPLEFT
                        leftPadding = SpellCastBuffs.padding
                    elseif alignmentDir == RIGHT then
                        anchor = TOPRIGHT
                        leftPadding = -zo_min(maxIcons, iconsNum - maxIcons * row) * iconSize - SpellCastBuffs.padding
                    else
                        anchor = TOP
                        leftPadding = -0.5 * (zo_min(maxIcons, iconsNum - maxIcons * row) * iconSize - SpellCastBuffs.padding)
                    end
                else
                    -- Fallback
                    anchor = TOP
                    leftPadding = -0.5 * (zo_min(maxIcons, iconsNum - maxIcons * row) * iconSize - SpellCastBuffs.padding)
                end

                buff:ClearAnchors()
                buff:SetAnchor(TOPLEFT, containerData, anchor, leftPadding, row * iconSize)
                -- Determine if we need to make next row
                if maxIcons then
                    -- If buffs then stack down
                    if container == "player1" or container == "target1" then
                        row = row + 1
                        -- If debuffs then stack up
                    elseif container == "player2" or container == "target2" then
                        row = row - 1
                    elseif container == "playerb" then
                        row = row + (SpellCastBuffs.SV.StackPlayerBuffs == "Down" and 1 or -1)
                    elseif container == "playerd" then
                        row = row + (SpellCastBuffs.SV.StackPlayerDebuffs == "Down" and 1 or -1)
                    elseif container == "targetb" then
                        row = row + (SpellCastBuffs.SV.StackTargetBuffs == "Down" and 1 or -1)
                    elseif container == "targetd" then
                        row = row + (SpellCastBuffs.SV.StackTargetDebuffs == "Down" and 1 or -1)
                    end
                    next_row_break = next_row_break + maxIcons
                end
            end
        end

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
                local formattedName = effect._cachedName or zo_strformat("<<C:1>>", effect.name)
                if not effect._cachedName then
                    effect._cachedName = formattedName
                end
                buff.name:SetText(formattedName)
            end
            
            -- Clear cached values when effect changes
            effect._sortKey = nil
            effect._cachedText = nil
            effect._cachedName = nil
        end

        if effect.stack and effect.stack > 0 then
            buff.stack:SetText(string_format("%s", effect.stack))
            buff.stack:SetHidden(false)
        else
            buff.stack:SetHidden(true)
        end

        -- For update remaining text. Cache formatted text to avoid redundant formatting
        if remain and not effect.fakeDuration then
            local remainSeconds = remain / 1000
            local cachedText = effect._cachedText
            local newText
            
            if remain > 86400000 then
                -- more then 1 day
                newText = string_format("%d d", zo_floor(remain / 86400000))
            elseif remain > 6000000 then
                -- over 100 minutes - display XXh
                newText = string_format("%dh", zo_floor(remain / 3600000))
            elseif remain > 600000 then
                -- over 10 minutes - display XXm
                newText = string_format("%dm", zo_floor(remain / 60000))
            elseif remain > 60000 or container == "player_long" then
                local m = zo_floor(remain / 60000)
                local s = zo_floor(remainSeconds - 60 * m)
                newText = string_format("%d:%.2d", m, s)
            else
                newText = string_format(SpellCastBuffs.SV.RemainingTextMillis and "%.1f" or "%.1d", remainSeconds)
            end
            
            -- Only update text if it changed
            if cachedText ~= newText then
                buff.label:SetText(newText)
                effect._cachedText = newText
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

    -- Hide and cleanup excess icons
    local maxIconsCount = #iconsArray
    for i = iconsNum + 1, maxIconsCount do
        if iconsArray[i] then
            iconsArray[i]:SetHidden(true)
        end
    end

    -- Clean up excess icons if we have significantly more than needed (keep a small buffer)
    -- Only cleanup if we have more than 10 extra icons to avoid frequent create/destroy
    if maxIconsCount > iconsNum + 10 then
        for i = iconsNum + 11, maxIconsCount do
            iconsArray[i] = nil
        end
    end

    -- Save icon number processed to compare in next update iteration
    containerData.prevIconsCount = iconsNum
end


-- Helper function to get sort key for an effect (cached on effect for performance)
local function getSortKey(effect)
    if effect._sortKey then
        return effect._sortKey
    end
    local duration = (effect.ends == nil or effect.dur == 0 or effect.groundLabel or effect.toggle) and 0 or effect.dur
    effect._sortKey = duration
    return duration
end

-- Helper function to sort buffs (optimized)
--- @param x table
--- @param y table
--- @return boolean?
local function buffSort(x, y)
    local xDuration = getSortKey(x)
    local yDuration = getSortKey(y)
    
    -- Both permanent/ground/toggle (duration 0)
    if xDuration == 0 and yDuration == 0 then
        if x.toggle and y.toggle then
            return x.name < y.name
        elseif x.toggle then
            return true
        elseif y.toggle then
            return false
        else
            return x.name < y.name
        end
    end
    
    -- One permanent, one not - permanent comes first
    if xDuration == 0 then
        return true
    end
    if yDuration == 0 then
        return false
    end
    
    -- Both non-permanent - sort by end time (longer first), then by start time, then by name
    if x.ends ~= y.ends then
        return x.ends > y.ends
    end
    if x.starts ~= y.starts then
        return x.starts < y.starts
    end
    return x.name < y.name
end

-- Reusable tables for OnUpdate (cleared each update to avoid allocations)
local buffsSorted = {}
local sortedCounts = {}
local needs_update = {}
local isProminent = {}

-- Runs OnUpdate - 100 ms buffer
--- @param currentTimeMs number
function SpellCastBuffs.OnUpdate(currentTimeMs)
    local containerRouting = SpellCastBuffs.containerRouting
    local EffectsList = SpellCastBuffs.EffectsList

    -- Clear and initialize containers and prepare sort arrays
    ZO_ClearTable(buffsSorted)
    ZO_ClearTable(sortedCounts)
    ZO_ClearTable(needs_update)
    ZO_ClearTable(isProminent)

    for _, container in pairs(containerRouting) do
        needs_update[container] = true
        buffsSorted[container] = {}
        sortedCounts[container] = 0
        if container == "prominentbuffs" or container == "prominentdebuffs" then
            isProminent[container] = true
        end
    end
    -- Initialize player_long separately as it may not be in containerRouting
    buffsSorted.player_long = {}
    sortedCounts.player_long = 0

    -- Filter expired events and build array for sorting
    for context, effectsList in pairs(EffectsList) do
        local container = containerRouting[context]
        if container or context == "player1" then
            for k, v in pairs(effectsList) do
                -- Remove expired effect
                if v.ends ~= nil and v.dur > 0 and v.ends < currentTimeMs then
                    effectsList[k] = nil
                elseif v.starts < currentTimeMs then
                    -- Always show prominent effects
                    if v.target == "prominent" and container then
                        sortedCounts[container] = sortedCounts[container] + 1
                        buffsSorted[container][sortedCounts[container]] = v
                        -- Short-term effects
                    elseif v.type == BUFF_EFFECT_TYPE_DEBUFF or v.forced == "short" or not (v.forced == "long" or v.ends == nil or v.dur == 0) then
                        if v.target == "reticleover" and SpellCastBuffs.SV.ShortTermEffects_Target and container then
                            sortedCounts[container] = sortedCounts[container] + 1
                            buffsSorted[container][sortedCounts[container]] = v
                        elseif v.target == "player" and SpellCastBuffs.SV.ShortTermEffects_Player and container then
                            sortedCounts[container] = sortedCounts[container] + 1
                            buffsSorted[container][sortedCounts[container]] = v
                        end
                        -- Long-term effects
                    elseif v.target == "reticleover" and SpellCastBuffs.SV.LongTermEffects_Target and container then
                        sortedCounts[container] = sortedCounts[container] + 1
                        buffsSorted[container][sortedCounts[container]] = v
                    elseif v.target == "player" and SpellCastBuffs.SV.LongTermEffects_Player then
                        if SpellCastBuffs.SV.LongTermEffectsSeparate and container and container ~= "prominentbuffs" and container ~= "prominentdebuffs" then
                            sortedCounts.player_long = sortedCounts.player_long + 1
                            buffsSorted.player_long[sortedCounts.player_long] = v
                        elseif container then
                            sortedCounts[container] = sortedCounts[container] + 1
                            buffsSorted[container][sortedCounts[container]] = v
                        end
                    end
                end
            end
        end
    end

    -- Sort effects in container and draw them on screen
    for _, container in pairs(containerRouting) do
        if needs_update[container] then
            local sorted = buffsSorted[container]
            if #sorted > 0 then
                -- Clear sort keys before sorting (they may be stale)
                for i = 1, #sorted do
                    sorted[i]._sortKey = nil
                end
                table_sort(sorted, buffSort)
            end
            updateIcons(currentTimeMs, sorted, container)
        end
    end

    -- Update prominent buff bars
    for container, _ in pairs(isProminent) do
        updateBar(currentTimeMs, buffsSorted[container], container)
    end

    -- Update player_long if it has effects
    if sortedCounts.player_long > 0 then
        local sorted = buffsSorted.player_long
        -- Clear sort keys before sorting
        for i = 1, #sorted do
            sorted[i]._sortKey = nil
        end
        table_sort(sorted, buffSort)
        updateIcons(currentTimeMs, sorted, "player_long")
    end

    -- Display Block buff for player if enabled
    if SpellCastBuffs.SV.ShowBlockPlayer and not SpellCastBuffs.SV.HidePlayerBuffs then
        if IsBlockActive() and not IsPlayerStunned() then
            local abilityId = 974
            local abilityName = Abilities.Innate_Brace
            local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
            EffectsList[context][abilityId] =
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
