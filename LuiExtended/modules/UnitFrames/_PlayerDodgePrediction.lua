--- @diagnostic disable: undefined-field, missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local eventManager = GetEventManager()
local moduleName = UnitFrames.moduleName

local ROLL_DODGE_ABILITY_ID = 28549
local EXPERT_EVASION_COOLDOWN_ABILITY_ID = 151113
local DODGE_FATIGUE_ABILITY_ID = 69143
local MARKER_POOL_TEMPLATE = "LUIE_DodgePredictionMarker"
local MARKER_WIDTH = 2
local SMOOTH_MS = 250
local POST_DODGE_REFRESH_MS = 1000

local COST_REFRESH_ABILITY_IDS =
{
    [EXPERT_EVASION_COOLDOWN_ABILITY_ID] = true,
    [DODGE_FATIGUE_ABILITY_ID] = true,
}

--- @class LUIE_PlayerDodgePrediction : ZO_InitializingCallbackObject
--- @field markerPool ZO_ControlPool|nil
--- @field animationPool ZO_ObjectPool|nil
--- @field lastCost integer|nil
LUIE_PlayerDodgePrediction = ZO_InitializingCallbackObject:Subclass()

LUIE_PlayerDodgePrediction.DODGE_COST_CHANGED = "DodgeCostChanged"

function LUIE_PlayerDodgePrediction:Initialize()
    self.markerPool = nil
    self.animationPool = nil
    self.lastCost = nil

    local function OnRefresh()
        self:Refresh()
    end

    do
        local OnEffectChangedCallback = function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            if COST_REFRESH_ABILITY_IDS[abilityId] then
                OnRefresh()
            end
        end
        local effectName = moduleName .. "DodgePredictionEffect"

        eventManager:RegisterForEvent(effectName, EVENT_EFFECT_CHANGED, OnEffectChangedCallback)
        eventManager:AddFilterForEvent(effectName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    end

    do
        local OnEventCombatEventCallback = function (eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            zo_callLater(OnRefresh, POST_DODGE_REFRESH_MS)
        end
        local combatName = moduleName .. "DodgePredictionCombat"
        eventManager:RegisterForEvent(combatName, EVENT_COMBAT_EVENT, OnEventCombatEventCallback)
        eventManager:AddFilterForEvent(combatName, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, ROLL_DODGE_ABILITY_ID)
        eventManager:AddFilterForEvent(combatName, EVENT_COMBAT_EVENT, REGISTER_FILTER_UNIT_TAG, "player")
    end

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionActivated", EVENT_PLAYER_ACTIVATED, OnRefresh)

    self:Refresh()
end

--- @return boolean
function LUIE_PlayerDodgePrediction:IsEnabled()
    local sv = UnitFrames.SV
    return UnitFrames.Enabled and sv and sv.CustomFramesPlayer and sv.ShowPlayerDodgePrediction
end

--- @return boolean
function LUIE_PlayerDodgePrediction:ShouldUseSmoothBar()
    return self:IsEnabled() and UnitFrames.SV.CustomSmoothBar
end

--- @return table|nil
function LUIE_PlayerDodgePrediction:GetStaminaFrame()
    local player = UnitFrames.CustomFrames and UnitFrames.CustomFrames["player"]
    return player and player[COMBAT_MECHANIC_FLAGS_STAMINA]
end

--- @return integer
function LUIE_PlayerDodgePrediction:GetDodgeCost()
    return zo_max(0, GetAbilityCost(ROLL_DODGE_ABILITY_ID, COMBAT_MECHANIC_FLAGS_STAMINA, nil, "player"))
end

--- @return integer
local function GetBarAlignment()
    local index = UnitFrames.SV.BarAlignPlayerStamina or 1
    if type(index) == "number" then
        return zo_clamp(index, 1, 3)
    end
    if index == GetString(LUIE_STRING_LAM_UF_ALIGNMENT_RIGHT_LEFT) then
        return 2
    end
    if index == GetString(LUIE_STRING_LAM_UF_ALIGNMENT_CENTER) then
        return 3
    end
    return 1
end

--- @param staminaFrame table
--- @return number displayed
--- @return number effectiveMax
function LUIE_PlayerDodgePrediction:GetBarValues(staminaFrame)
    local bar = staminaFrame.bar
    if bar then
        local _, max = bar:GetMinMax()
        local displayed = bar:GetValue()
        if UnitFrames.SV.CustomSmoothBar then
            if bar.luiDodgeMarkerAnimation then
                local animation = bar.luiDodgeMarkerAnimation:GetFirstAnimation()
                if animation and animation.endValue then
                    displayed = animation.endValue
                end
            else
                displayed = ZO_StatusBar_GetTargetValue(bar) or displayed
            end
        end
        if max and max > 0 then
            return displayed, max
        end
    end
    local powerValue, _, powerEffectiveMax = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
    return powerValue, powerEffectiveMax
end

--- @param line Control
--- @param canAfford boolean
local function ApplyMarkerColor(line, canAfford)
    local color = UnitFrames.SV.PlayerDodgePredictionColor or UnitFrames.Defaults.PlayerDodgePredictionColor
    local r, g, b, a = color[1], color[2], color[3], color[4]
    if not canAfford then
        r, g, b = 1, 0.35, 0.35
    end
    line:SetCenterColor(r, g, b, a)
    line:SetEdgeColor(r, g, b, a)
end

--- @param bar StatusBarControl
--- @return ZO_ControlPool
function LUIE_PlayerDodgePrediction:GetMarkerPool(bar)
    if self.markerPool and self.markerPool.parent == bar then
        return self.markerPool
    end
    if self.markerPool then
        self.markerPool:ReleaseAllObjects()
    end
    self.markerPool = ZO_ControlPool:New(MARKER_POOL_TEMPLATE, bar, "DodgePredictionMarker")
    self.markerPool:SetCustomFactoryBehavior(function (line)
        line:SetEdgeTexture("", 1, 1, 0, 0)
    end)
    return self.markerPool
end

--- @param staminaFrame table|nil
function LUIE_PlayerDodgePrediction:ReleaseMarker(staminaFrame)
    if staminaFrame and staminaFrame.bar then
        self:StopSmoothAnimation(staminaFrame.bar)
    end
    if not staminaFrame then
        return
    end
    staminaFrame.dodgePredictionLastCost = nil
    if self.markerPool then
        if staminaFrame.dodgePredictionPoolKey then
            self.markerPool:ReleaseObject(staminaFrame.dodgePredictionPoolKey)
        end
        if staminaFrame.dodgePredictionPoolKeyCenterLeft then
            self.markerPool:ReleaseObject(staminaFrame.dodgePredictionPoolKeyCenterLeft)
        end
        if staminaFrame.dodgePredictionPoolKeyCenterRight then
            self.markerPool:ReleaseObject(staminaFrame.dodgePredictionPoolKeyCenterRight)
        end
    end
    staminaFrame.dodgePredictionLine = nil
    staminaFrame.dodgePredictionPoolKey = nil
    staminaFrame.dodgePredictionLineCenterLeft = nil
    staminaFrame.dodgePredictionLineCenterRight = nil
    staminaFrame.dodgePredictionPoolKeyCenterLeft = nil
    staminaFrame.dodgePredictionPoolKeyCenterRight = nil
end

--- @param bar StatusBarControl
--- @param staminaFrame table
--- @param alignment integer
--- @return Control|nil
--- @return Control|nil
--- @return Control|nil
function LUIE_PlayerDodgePrediction:AcquireMarkers(bar, staminaFrame, alignment)
    local pool = self:GetMarkerPool(bar)

    if alignment == 3 then
        if  staminaFrame.dodgePredictionLineCenterLeft
        and staminaFrame.dodgePredictionLineCenterRight
        and staminaFrame.dodgePredictionLineCenterLeft:GetParent() == bar then
            return nil, staminaFrame.dodgePredictionLineCenterLeft, staminaFrame.dodgePredictionLineCenterRight
        end
        self:ReleaseMarker(staminaFrame)
        local lineLeft, keyLeft = pool:AcquireObject(1)
        local lineRight, keyRight = pool:AcquireObject(2)
        staminaFrame.dodgePredictionLineCenterLeft = lineLeft
        staminaFrame.dodgePredictionLineCenterRight = lineRight
        staminaFrame.dodgePredictionPoolKeyCenterLeft = keyLeft
        staminaFrame.dodgePredictionPoolKeyCenterRight = keyRight
        return nil, lineLeft, lineRight
    end

    if staminaFrame.dodgePredictionLine and staminaFrame.dodgePredictionLine:GetParent() == bar then
        return staminaFrame.dodgePredictionLine, nil, nil
    end
    self:ReleaseMarker(staminaFrame)
    local line, key = pool:AcquireObject(1)
    staminaFrame.dodgePredictionLine = line
    staminaFrame.dodgePredictionPoolKey = key
    return line, nil, nil
end

--- @param bar StatusBarControl
--- @param predicted number
--- @param effectiveMax number
--- @param alignment integer
--- @param line Control|nil
--- @param lineLeft Control|nil
--- @param lineRight Control|nil
--- @param canAfford boolean
function LUIE_PlayerDodgePrediction:PositionMarkers(bar, predicted, effectiveMax, alignment, line, lineLeft, lineRight, canAfford)
    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()

    if alignment == 3 then
        ApplyMarkerColor(lineLeft, canAfford)
        ApplyMarkerColor(lineRight, canAfford)
        local percent = zo_clamp(predicted / effectiveMax, 0, 1)
        local halfSpan = zo_min((barWidth * percent) / 2, zo_max(0, (barWidth / 2) - MARKER_WIDTH))
        local centerX = barWidth / 2
        local leftX = zo_floor(centerX - halfSpan - MARKER_WIDTH)
        local rightX = zo_floor(centerX + halfSpan)
        lineLeft:ClearAnchors()
        lineRight:ClearAnchors()
        lineLeft:SetDimensions(MARKER_WIDTH, barHeight)
        lineRight:SetDimensions(MARKER_WIDTH, barHeight)
        lineLeft:SetAnchor(TOPLEFT, bar, TOPLEFT, leftX, 0)
        lineLeft:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, leftX, 0)
        lineRight:SetAnchor(TOPLEFT, bar, TOPLEFT, rightX, 0)
        lineRight:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, rightX, 0)
        lineLeft:SetHidden(false)
        lineRight:SetHidden(false)
        return
    end

    ApplyMarkerColor(line, canAfford)
    local lineX = zo_clamp(zo_floor(zo_clamp(predicted / effectiveMax, 0, 1) * barWidth), 0, zo_max(0, barWidth - MARKER_WIDTH))
    line:ClearAnchors()
    line:SetDimensions(MARKER_WIDTH, barHeight)
    if alignment == 2 then
        line:SetAnchor(TOPRIGHT, bar, TOPRIGHT, -lineX, 0)
        line:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -lineX, 0)
    else
        line:SetAnchor(TOPLEFT, bar, TOPLEFT, lineX, 0)
        line:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, lineX, 0)
    end
    line:SetHidden(false)
end

--- @param bar StatusBarControl
--- @param displayed number
--- @param effectiveMax number|nil
function LUIE_PlayerDodgePrediction:PositionMarkerFromBar(bar, displayed, effectiveMax)
    local staminaFrame = self:GetStaminaFrame()
    if not staminaFrame or staminaFrame.bar ~= bar or not staminaFrame.dodgePredictionLastCost then
        return
    end
    if not effectiveMax or effectiveMax <= 0 then
        local _, max = bar:GetMinMax()
        effectiveMax = max
    end
    if not effectiveMax or effectiveMax <= 0 then
        return
    end

    local cost = staminaFrame.dodgePredictionLastCost
    local predicted = zo_clamp(displayed - cost, 0, effectiveMax)
    local alignment = GetBarAlignment()
    local canAfford = displayed >= cost
    local line = staminaFrame.dodgePredictionLine
    local lineLeft = staminaFrame.dodgePredictionLineCenterLeft
    local lineRight = staminaFrame.dodgePredictionLineCenterRight

    if alignment == 3 then
        if not lineLeft or not lineRight or lineLeft:IsHidden() then
            return
        end
    elseif not line or line:IsHidden() then
        return
    end

    self:PositionMarkers(bar, predicted, effectiveMax, alignment, line, lineLeft, lineRight, canAfford)
end

-- Smooth transition mirrors ZO_StatusBar_SmoothTransition (StatusBarTemplates.lua) + marker sync.
function LUIE_PlayerDodgePrediction:AcquireAnimation()
    if not self.animationPool then
        local owner = self
        self.animationPool = ZO_ObjectPool:New(function ()
                                                   local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_StatusBarGrowTemplate")
                                                   timeline:GetFirstAnimation():SetUpdateFunction(function (animation, progress)
                                                       local bar = animation.bar
                                                       if not bar then
                                                           return
                                                       end
                                                       local value = zo_lerp(animation.initialValue, animation.endValue, progress)
                                                       bar:SetValue(value)
                                                       if owner:IsEnabled() then
                                                           local _, max = bar:GetMinMax()
                                                           owner:PositionMarkerFromBar(bar, value, max)
                                                       end
                                                   end)
                                                   timeline:SetHandler("OnStop", function (timelineSelf, completedPlaying)
                                                       local animation = timelineSelf:GetFirstAnimation()
                                                       local bar = animation and animation.bar
                                                       if bar then
                                                           bar.luiDodgeMarkerAnimation = nil
                                                           if bar.onStopCallback then
                                                               bar.onStopCallback(bar, completedPlaying)
                                                           end
                                                       end
                                                       if timelineSelf.key then
                                                           owner.animationPool:ReleaseObject(timelineSelf.key)
                                                       end
                                                   end)
                                                   return timeline
                                               end, function (timeline)
                                                   local animation = timeline:GetFirstAnimation()
                                                   animation.bar = nil
                                                   animation.initialValue = nil
                                                   animation.endValue = nil
                                               end)
    end
    local timeline, key = self.animationPool:AcquireObject()
    timeline.key = key
    return timeline
end

--- @param bar StatusBarControl|nil
function LUIE_PlayerDodgePrediction:StopSmoothAnimation(bar)
    if bar and bar.luiDodgeMarkerAnimation then
        bar.luiDodgeMarkerAnimation:Stop()
    end
end

--- @param bar StatusBarControl
--- @param value number
--- @param max number
--- @param forceInit boolean|nil
function LUIE_PlayerDodgePrediction:SmoothTransition(bar, value, max, forceInit)
    local cost = self:GetDodgeCost()
    local staminaFrame = self:GetStaminaFrame()
    if cost > 0 and staminaFrame and staminaFrame.bar == bar and staminaFrame.backdrop then
        local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
        if barWidth > 0 and barHeight > 0 then
            local alignment = GetBarAlignment()
            local line, lineLeft, lineRight = self:AcquireMarkers(bar, staminaFrame, alignment)
            staminaFrame.dodgePredictionLastCost = cost
            if alignment == 3 then
                if lineLeft and lineRight then
                    lineLeft:SetHidden(false)
                    lineRight:SetHidden(false)
                end
            elseif line then
                line:SetHidden(false)
            end
        end
    end

    local oldValue = bar:GetValue()
    bar:SetMinMax(0, max)
    local oldMax = bar.max or max
    bar.max = max

    if forceInit or max <= 0 then
        bar:SetValue(value)
        if bar.luiDodgeMarkerAnimation then
            bar.luiDodgeMarkerAnimation:Stop()
        end
        self:PositionMarkerFromBar(bar, value, max)
        return
    end

    if oldMax > 0 and oldMax ~= max then
        oldValue = oldValue * (max / oldMax)
        bar:SetValue(oldValue)
    end

    if not bar.luiDodgeMarkerAnimation then
        bar.luiDodgeMarkerAnimation = self:AcquireAnimation()
    end

    local animation = bar.luiDodgeMarkerAnimation:GetFirstAnimation()
    animation:SetDuration(SMOOTH_MS)
    animation.bar = bar
    animation.initialValue = oldValue
    animation.endValue = value
    bar.luiDodgeMarkerAnimation:PlayFromStart()
end

--- @param positionOnly boolean|nil
function LUIE_PlayerDodgePrediction:Refresh(positionOnly)
    local staminaFrame = self:GetStaminaFrame()

    if not self:IsEnabled() then
        if staminaFrame and staminaFrame.bar then
            self:StopSmoothAnimation(staminaFrame.bar)
        end
        self:ReleaseMarker(staminaFrame)
        return
    end

    local bar = staminaFrame and staminaFrame.bar
    if not staminaFrame or not staminaFrame.backdrop or not bar then
        self:ReleaseMarker(staminaFrame)
        return
    end

    local cost = (positionOnly and staminaFrame.dodgePredictionLastCost) or self:GetDodgeCost()
    if not cost or cost <= 0 then
        self:ReleaseMarker(staminaFrame)
        return
    end

    local displayed, effectiveMax = self:GetBarValues(staminaFrame)
    if not effectiveMax or effectiveMax <= 0 then
        self:ReleaseMarker(staminaFrame)
        return
    end

    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    if barWidth <= 0 or barHeight <= 0 then
        self:ReleaseMarker(staminaFrame)
        return
    end

    local alignment = GetBarAlignment()
    local line, lineLeft, lineRight = self:AcquireMarkers(bar, staminaFrame, alignment)
    if alignment == 3 then
        if not lineLeft or not lineRight then
            return
        end
    elseif not line then
        return
    end

    if not positionOnly and self.lastCost ~= cost then
        self.lastCost = cost
        self:FireCallbacks(LUIE_PlayerDodgePrediction.DODGE_COST_CHANGED, cost)
    end

    staminaFrame.dodgePredictionLastCost = cost
    self:PositionMarkers(bar, zo_clamp(displayed - cost, 0, effectiveMax), effectiveMax, alignment, line, lineLeft, lineRight, displayed >= cost)
end
