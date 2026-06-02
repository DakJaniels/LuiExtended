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
-- Expert Evasion: ICD debuff on the player after a free roll (LuiData Effects/Override.lua, 151113).
local EXPERT_EVASION_COOLDOWN_ABILITY_ID = 151113
-- Champion node ability from GetChampionAbilityId (LuiData DebugAuras.lua, typically 142092 on node 51).
local EXPERT_EVASION_NODE_ABILITY_ID = 142092
local EXPERT_EVASION_CHAMPION_SKILL_ID = 51
local DODGE_FATIGUE_ABILITY_ID = 69143
-- Medium Armor passive Athletics (LuiData DebugAuras 29742 / 45574).
local ATHLETICS_ABILITY_IDS =
{
    45574,
    29742,
}
local MARKER_POOL_TEMPLATE = "LUIE_DodgePredictionMarker"
local DEFAULT_DODGE_FATIGUE_PERCENT_PER_STACK = 33
local DEFAULT_ATHLETICS_DODGE_REDUCTION_PERCENT_PER_MEDIUM_PIECE = 4
local MARKER_POOL_KEY_SINGLE = 1
local MARKER_POOL_KEY_CENTER_LEFT = 2
local MARKER_POOL_KEY_CENTER_RIGHT = 3
local MARKER_WIDTH = 2
local LUIE_STAMINA_SMOOTH_MS = 250

LUIE_PLAYER_DODGE_PREDICTION_CALLBACK_DODGE_COST_CHANGED = "DodgeCostChanged"

--- Player dodge prediction marker on custom stamina bar (singleton feature on UnitFrames).
--- @class LUIE_PlayerDodgePrediction : ZO_CallbackObject
--- @field expertEvasionOnCooldown boolean
--- @field playerDodgeFatigueStacks integer
--- @field eventsRegistered boolean
--- @field markerPool ZO_ControlPool|nil
--- @field staminaBarAnimationPool ZO_ObjectPool|nil
--- @field lastPublishedCost integer|nil
LUIE_PlayerDodgePrediction = ZO_CallbackObject:Subclass()

--- @return LUIE_PlayerDodgePrediction
function LUIE_PlayerDodgePrediction:New()
    local obj = ZO_CallbackObject.New(self)
    obj.expertEvasionOnCooldown = false
    obj.playerDodgeFatigueStacks = 0
    obj.eventsRegistered = false
    obj.markerPool = nil
    obj.staminaBarAnimationPool = nil
    obj.lastPublishedCost = nil
    return obj
end

function LUIE_PlayerDodgePrediction:IsFeatureEnabled()
    local sv = UnitFrames.SV
    return UnitFrames.Enabled and sv and sv.CustomFramesPlayer and sv.ShowPlayerDodgePrediction
end

--- Player stamina bar uses LUIE smooth pool (dodge marker synced in bar animation tick).
--- @return boolean
function LUIE_PlayerDodgePrediction:ShouldUseLUIEStaminaSmooth()
    return self:IsFeatureEnabled() and UnitFrames.SV.CustomSmoothBar
end

--- @return table|nil stamina attribute frame from custom player UI
function LUIE_PlayerDodgePrediction:GetPlayerStaminaFrame()
    local player = UnitFrames.CustomFrames and UnitFrames.CustomFrames["player"]
    return player and player[COMBAT_MECHANIC_FLAGS_STAMINA]
end

--- @param abilityId integer
--- @return boolean
local function PlayerHasBuffAbility(abilityId)
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, _, _, _, _, _, _, buffAbilityId = GetUnitBuffInfo("player", i)
        if buffAbilityId == abilityId then
            return true
        end
    end
    return false
end

--- @param abilityId integer
--- @return boolean
local function IsExpertEvasionChampionNodeAbility(abilityId)
    return abilityId == EXPERT_EVASION_NODE_ABILITY_ID or abilityId == EXPERT_EVASION_COOLDOWN_ABILITY_ID
end

--- Expert Evasion champion node (Conditioning / Fitness). Node 51; GetChampionAbilityId is 142092, not the ICD buff 151113.
--- @return integer|nil championSkillId
local function GetExpertEvasionChampionSkillId()
    if IsExpertEvasionChampionNodeAbility(GetChampionAbilityId(EXPERT_EVASION_CHAMPION_SKILL_ID)) then
        return EXPERT_EVASION_CHAMPION_SKILL_ID
    end
    for disciplineIndex = 1, GetNumChampionDisciplines() do
        if GetChampionDisciplineType(GetChampionDisciplineId(disciplineIndex)) == CHAMPION_DISCIPLINE_TYPE_CONDITIONING then
            for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
                local championSkillId = GetChampionSkillId(disciplineIndex, skillIndex)
                if IsExpertEvasionChampionNodeAbility(GetChampionAbilityId(championSkillId)) then
                    return championSkillId
                end
            end
        end
    end
end

--- @param championSkillId integer
--- @return boolean
local function IsChampionSkillSlottedOnChampionBar(championSkillId)
    local startSlotIndex, endSlotIndex = GetAssignableChampionBarStartAndEndSlots()
    for actionSlotIndex = startSlotIndex, endSlotIndex do
        if  GetSlotType(actionSlotIndex, HOTBAR_CATEGORY_CHAMPION) == ACTION_TYPE_CHAMPION_SKILL
        and GetSlotBoundId(actionSlotIndex, HOTBAR_CATEGORY_CHAMPION) == championSkillId then
            return true
        end
    end
    return false
end

--- Purchased on the constellation and slotted on the champion bar when the skill type requires it.
--- @return boolean
local function PlayerHasExpertEvasionChampionPassive()
    local championSkillId = GetExpertEvasionChampionSkillId()
    if not championSkillId or GetNumPointsSpentOnChampionSkill(championSkillId) <= 0 then
        return false
    end
    if CanChampionSkillTypeBeSlotted(GetChampionSkillType(championSkillId)) then
        return IsChampionSkillSlottedOnChampionBar(championSkillId)
    end
    return true
end

function LUIE_PlayerDodgePrediction:SyncExpertEvasionCooldownFromBuffs()
    self.expertEvasionOnCooldown = PlayerHasBuffAbility(EXPERT_EVASION_COOLDOWN_ABILITY_ID)
end

function LUIE_PlayerDodgePrediction:SyncPlayerDodgeFatigueStacksFromBuffs()
    self.playerDodgeFatigueStacks = 0
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == DODGE_FATIGUE_ABILITY_ID then
            self.playerDodgeFatigueStacks = stackCount or 0
            return
        end
    end
end

--- @param changeType integer
--- @param abilityId integer
--- @param stackCount integer|nil
--- @return boolean stateChanged
function LUIE_PlayerDodgePrediction:OnDodgeFatigueEffectChanged(changeType, abilityId, stackCount)
    if abilityId ~= DODGE_FATIGUE_ABILITY_ID then
        return false
    end
    if changeType == EFFECT_RESULT_FADED then
        self.playerDodgeFatigueStacks = 0
    elseif changeType == EFFECT_RESULT_GAINED
    or     changeType == EFFECT_RESULT_UPDATED
    or     changeType == EFFECT_RESULT_FULL_REFRESH then
        self.playerDodgeFatigueStacks = stackCount or 0
    else
        return false
    end
    return true
end

--- @param changeType integer
--- @param abilityId integer
--- @return boolean stateChanged
function LUIE_PlayerDodgePrediction:OnExpertEvasionEffectChanged(changeType, abilityId)
    if abilityId ~= EXPERT_EVASION_COOLDOWN_ABILITY_ID then
        return false
    end
    if changeType == EFFECT_RESULT_FADED then
        self.expertEvasionOnCooldown = false
    elseif changeType == EFFECT_RESULT_GAINED
    or     changeType == EFFECT_RESULT_UPDATED
    or     changeType == EFFECT_RESULT_FULL_REFRESH then
        self.expertEvasionOnCooldown = true
    else
        return false
    end
    return true
end

--- @return number percent increase per Dodge Fatigue stack (ability 69143 sheet).
local function GetDodgeFatiguePercentPerStack()
    local numAdvanced = GetAbilityNumAdvancedStats(DODGE_FATIGUE_ABILITY_ID)
    if not numAdvanced or numAdvanced < 1 then
        return DEFAULT_DODGE_FATIGUE_PERCENT_PER_STACK
    end
    for index = 1, numAdvanced do
        local statType, displayFormat, effectValue = GetAbilityAdvancedStatAndEffectByIndex(DODGE_FATIGUE_ABILITY_ID, index)
        if  statType == ADVANCED_STAT_DISPLAY_TYPE_DODGE_COST
        and displayFormat == ADVANCED_STAT_DISPLAY_FORMAT_PERCENT
        and effectValue > 0 then
            return effectValue
        end
    end
    return DEFAULT_DODGE_FATIGUE_PERCENT_PER_STACK
end

--- @return integer
function LUIE_PlayerDodgePrediction:GetPlayerDodgeFatigueStacks()
    return self.playerDodgeFatigueStacks
end

--- @return integer
local function GetEquippedMediumArmorPieceCount()
    local counter = 0
    for bagSlot = 0, 16 do
        local itemLink = GetItemLink(BAG_WORN, bagSlot, LINK_STYLE_DEFAULT)
        if GetItemLinkArmorType(itemLink) == ARMORTYPE_MEDIUM then
            counter = counter + 1
        end
    end
    return counter
end

--- Percent per medium piece from Athletics ability sheet (fallback when advanced stat is unavailable).
--- @return number
local function GetAthleticsDodgeReductionPercentPerMediumPiece()
    for abilityIndex = 1, #ATHLETICS_ABILITY_IDS do
        local abilityId = ATHLETICS_ABILITY_IDS[abilityIndex]
        local numAdvanced = GetAbilityNumAdvancedStats(abilityId)
        if numAdvanced and numAdvanced >= 1 then
            for index = 1, numAdvanced do
                local statType, displayFormat, effectValue = GetAbilityAdvancedStatAndEffectByIndex(abilityId, index)
                if  statType == ADVANCED_STAT_DISPLAY_TYPE_DODGE_COST
                and displayFormat == ADVANCED_STAT_DISPLAY_FORMAT_PERCENT
                and effectValue > 0 then
                    return effectValue
                end
            end
        end
    end
    return DEFAULT_ATHLETICS_DODGE_REDUCTION_PERCENT_PER_MEDIUM_PIECE
end

--- @param abilityId integer
--- @return boolean
local function IsAthleticsAbilityId(abilityId)
    return abilityId == ATHLETICS_ABILITY_IDS[1] or abilityId == ATHLETICS_ABILITY_IDS[2]
end

--- @return boolean
local function PlayerHasAthleticsPassive()
    for skillLineIndex = 1, GetNumSkillLines(SKILL_TYPE_ARMOR) do
        local numAbilities = GetNumSkillAbilities(SKILL_TYPE_ARMOR, skillLineIndex)
        for skillIndex = 1, numAbilities do
            local abilityId = GetSkillAbilityId(SKILL_TYPE_ARMOR, skillLineIndex, skillIndex, true)
            if IsAthleticsAbilityId(abilityId) then
                return GetNumPassiveSkillRanks(SKILL_TYPE_ARMOR, skillLineIndex, skillIndex) > 0
            end
        end
    end
    return false
end

--- Athletics + other roll-dodge cost reductions (Medium Armor: 4% per medium piece).
--- @return number total reduction percent (e.g. 20 for five medium pieces)
local function GetRollDodgeCostReductionPercent()
    local _, _, percentValue = GetAdvancedStatValue(ADVANCED_STAT_DISPLAY_TYPE_DODGE_COST)
    if percentValue and percentValue > 0 then
        return percentValue
    end
    if not PlayerHasAthleticsPassive() then
        return 0
    end
    local mediumPieces = GetEquippedMediumArmorPieceCount()
    if mediumPieces <= 0 then
        return 0
    end
    return mediumPieces * GetAthleticsDodgeReductionPercentPerMediumPiece()
end

--- @param baseCost integer
--- @return integer
local function ApplyAthleticsRollDodgeCostReduction(baseCost)
    local reductionPercent = GetRollDodgeCostReductionPercent()
    if reductionPercent <= 0 then
        return baseCost
    end
    return zo_max(0, zo_round(baseCost * (1 - reductionPercent / 100)))
end

local function ApplyDodgeFatigueToCost(baseCost, fatigueStacks, percentPerStack)
    if fatigueStacks <= 0 then
        return baseCost
    end
    return zo_max(0, zo_round(baseCost * ((1 + percentPerStack / 100) ^ fatigueStacks)))
end

--- Next roll dodge stamina cost (GetAbilityCost + Athletics + Dodge Fatigue + Expert Evasion).
--- @return integer
function LUIE_PlayerDodgePrediction:GetPredictedRollDodgeStaminaCost()
    local cost = zo_max(0, GetAbilityCost(ROLL_DODGE_ABILITY_ID, COMBAT_MECHANIC_FLAGS_STAMINA, nil, "player"))
    cost = ApplyAthleticsRollDodgeCostReduction(cost)
    if not PlayerHasExpertEvasionChampionPassive() then
        return ApplyDodgeFatigueToCost(cost, self.playerDodgeFatigueStacks, GetDodgeFatiguePercentPerStack())
    end
    if self.expertEvasionOnCooldown then
        return ApplyDodgeFatigueToCost(cost, self.playerDodgeFatigueStacks, GetDodgeFatiguePercentPerStack())
    end
    return 0
end

--- @return integer 1 = L-->R, 2 = R-->L, 3 = center
local function GetStaminaBarAlignment()
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
--- @param useBarAnimatedValue boolean|nil when true, use bar:GetValue() during smooth transitions
--- @return integer displayed
--- @return integer effectiveMax
function LUIE_PlayerDodgePrediction:GetStaminaBarValues(staminaFrame, useBarAnimatedValue)
    local bar = staminaFrame.bar
    if bar then
        local _, max = bar:GetMinMax()
        local displayed = bar:GetValue()
        if UnitFrames.SV.CustomSmoothBar and not useBarAnimatedValue then
            if bar.luiStaminaDodgeAnimation then
                local customAnimation = bar.luiStaminaDodgeAnimation:GetFirstAnimation()
                if customAnimation and customAnimation.endValue then
                    displayed = customAnimation.endValue
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

--- L-->R / R-->L: single edge at predicted fill boundary.
--- @param line Control
--- @param bar StatusBarControl
--- @param predicted number
--- @param alignment integer
--- @param staminaFrame table|nil
local function PositionDodgeMarkerEdge(line, bar, predicted, alignment, staminaFrame)
    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    local lineX = bar:CalculateSizeWithoutLeadingEdgeForValue(predicted)
    lineX = zo_clamp(lineX, 0, zo_max(0, barWidth - MARKER_WIDTH))

    if  staminaFrame
    and staminaFrame.dodgePredictionLastEdgeLineX == lineX
    and staminaFrame.dodgePredictionLastEdgeAlignment == alignment then
        return
    end

    if staminaFrame then
        staminaFrame.dodgePredictionLastEdgeLineX = lineX
        staminaFrame.dodgePredictionLastEdgeAlignment = alignment
        staminaFrame.dodgePredictionLastCenterLeftX = nil
        staminaFrame.dodgePredictionLastCenterRightX = nil
    end

    line:ClearAnchors()
    line:SetDimensions(MARKER_WIDTH, barHeight)

    if alignment == 2 then
        line:SetAnchor(TOPRIGHT, bar, TOPRIGHT, -lineX, 0)
        line:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, -lineX, 0)
    else
        line:SetAnchor(TOPLEFT, bar, TOPLEFT, lineX, 0)
        line:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, lineX, 0)
    end
end

--- Center: symmetric band shrinks toward the middle as predicted stamina drops.
--- @param lineLeft Control
--- @param lineRight Control
--- @param bar StatusBarControl
--- @param predicted number
--- @param effectiveMax number
--- @param staminaFrame table|nil
local function PositionDodgeMarkerCenter(lineLeft, lineRight, bar, predicted, effectiveMax, staminaFrame)
    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    local percent = zo_clamp(predicted / effectiveMax, 0, 1)
    local halfSpan = (barWidth * percent) / 2
    halfSpan = zo_min(halfSpan, zo_max(0, (barWidth / 2) - MARKER_WIDTH))
    local centerX = barWidth / 2
    local leftX = zo_floor(centerX - halfSpan - MARKER_WIDTH)
    local rightX = zo_floor(centerX + halfSpan)

    if  staminaFrame
    and staminaFrame.dodgePredictionLastCenterLeftX == leftX
    and staminaFrame.dodgePredictionLastCenterRightX == rightX then
        return
    end

    if staminaFrame then
        staminaFrame.dodgePredictionLastCenterLeftX = leftX
        staminaFrame.dodgePredictionLastCenterRightX = rightX
        staminaFrame.dodgePredictionLastEdgeLineX = nil
        staminaFrame.dodgePredictionLastEdgeAlignment = nil
    end

    lineLeft:ClearAnchors()
    lineRight:ClearAnchors()
    lineLeft:SetDimensions(MARKER_WIDTH, barHeight)
    lineRight:SetDimensions(MARKER_WIDTH, barHeight)
    lineLeft:SetAnchor(TOPLEFT, bar, TOPLEFT, leftX, 0)
    lineLeft:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, leftX, 0)
    lineRight:SetAnchor(TOPLEFT, bar, TOPLEFT, rightX, 0)
    lineRight:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, rightX, 0)
end

local function ClearDodgeMarkerPositionCache(staminaFrame)
    if not staminaFrame then
        return
    end
    staminaFrame.dodgePredictionLastEdgeLineX = nil
    staminaFrame.dodgePredictionLastEdgeAlignment = nil
    staminaFrame.dodgePredictionLastCenterLeftX = nil
    staminaFrame.dodgePredictionLastCenterRightX = nil
end

--- @param line Control
--- @param canAfford boolean
local function ApplyLineColor(line, canAfford)
    local color = UnitFrames.SV.PlayerDodgePredictionColor or UnitFrames.Defaults.PlayerDodgePredictionColor
    local r, g, b, a = color[1], color[2], color[3], color[4]
    if not canAfford then
        r, g, b = 1, 0.35, 0.35
    end
    line:SetCenterColor(r, g, b, a)
    line:SetEdgeColor(r, g, b, a)
end

--- Positions dodge marker lines from a known displayed stamina value (bar may already reflect this value).
--- @param bar StatusBarControl
--- @param displayed number
--- @param effectiveMax number|nil
function LUIE_PlayerDodgePrediction:PositionMarkerFromBar(bar, displayed, effectiveMax)
    local staminaFrame = self:GetPlayerStaminaFrame()
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
    local alignment = GetStaminaBarAlignment()
    local canAfford = displayed >= cost

    if alignment == 3 then
        local lineLeft = staminaFrame.dodgePredictionLineCenterLeft
        local lineRight = staminaFrame.dodgePredictionLineCenterRight
        if not lineLeft or not lineRight or lineLeft:IsHidden() or lineRight:IsHidden() then
            return
        end
        ApplyLineColor(lineLeft, canAfford)
        ApplyLineColor(lineRight, canAfford)
        PositionDodgeMarkerCenter(lineLeft, lineRight, bar, predicted, effectiveMax, staminaFrame)
    else
        local line = staminaFrame.dodgePredictionLine
        if not line or line:IsHidden() then
            return
        end
        ApplyLineColor(line, canAfford)
        PositionDodgeMarkerEdge(line, bar, predicted, alignment, staminaFrame)
    end
end

--- @param staminaFrame table|nil
function LUIE_PlayerDodgePrediction:ReleaseStaminaMarker(staminaFrame)
    if staminaFrame and staminaFrame.bar then
        self:StopStaminaBarSmoothAnimation(staminaFrame.bar)
    end
    if not staminaFrame then
        return
    end
    ClearDodgeMarkerPositionCache(staminaFrame)
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

--- @param bar StatusBarControl
--- @param staminaFrame table
--- @return Control|nil line edge alignment
--- @return Control|nil lineLeft center alignment
--- @return Control|nil lineRight center alignment
function LUIE_PlayerDodgePrediction:AcquireStaminaMarkers(bar, staminaFrame)
    local pool = self:GetMarkerPool(bar)
    local alignment = GetStaminaBarAlignment()

    if alignment == 3 then
        local lineLeft = staminaFrame.dodgePredictionLineCenterLeft
        local lineRight = staminaFrame.dodgePredictionLineCenterRight
        if  lineLeft and lineRight
        and staminaFrame.dodgePredictionPoolKeyCenterLeft
        and staminaFrame.dodgePredictionPoolKeyCenterRight
        and lineLeft:GetParent() == bar and lineRight:GetParent() == bar then
            return nil, lineLeft, lineRight
        end
    else
        local line = staminaFrame.dodgePredictionLine
        if line and staminaFrame.dodgePredictionPoolKey and line:GetParent() == bar then
            return line, nil, nil
        end
    end

    self:ReleaseStaminaMarker(staminaFrame)

    if alignment == 3 then
        local lineLeft, keyLeft = pool:AcquireObject(MARKER_POOL_KEY_CENTER_LEFT)
        local lineRight, keyRight = pool:AcquireObject(MARKER_POOL_KEY_CENTER_RIGHT)
        staminaFrame.dodgePredictionLineCenterLeft = lineLeft
        staminaFrame.dodgePredictionLineCenterRight = lineRight
        staminaFrame.dodgePredictionPoolKeyCenterLeft = keyLeft
        staminaFrame.dodgePredictionPoolKeyCenterRight = keyRight
        return nil, lineLeft, lineRight
    end

    local line, key = pool:AcquireObject(MARKER_POOL_KEY_SINGLE)
    staminaFrame.dodgePredictionLine = line
    staminaFrame.dodgePredictionPoolKey = key
    return line, nil, nil
end

function LUIE_PlayerDodgePrediction:OnStaminaBarAnimationUpdate(customAnimation, progress)
    local bar = customAnimation.bar
    if not bar then
        return
    end
    local newBarValue = zo_lerp(customAnimation.initialValue, customAnimation.endValue, progress)
    bar:SetValue(newBarValue)
    if self:IsFeatureEnabled() then
        local _, max = bar:GetMinMax()
        self:PositionMarkerFromBar(bar, newBarValue, max)
    end
end

function LUIE_PlayerDodgePrediction:OnStaminaBarAnimationStop(timeline, completedPlaying)
    local animationKey = timeline.key
    local customAnimation = timeline:GetFirstAnimation()
    local bar = customAnimation and customAnimation.bar
    if bar then
        bar.luiStaminaDodgeAnimation = nil
        if bar.onStopCallback then
            bar.onStopCallback(bar, completedPlaying)
        end
    end
    if self.staminaBarAnimationPool and animationKey then
        self.staminaBarAnimationPool:ReleaseObject(animationKey)
    end
end

function LUIE_PlayerDodgePrediction:AcquireStaminaBarAnimation()
    if not self.staminaBarAnimationPool then
        local owner = self
        local function Factory(objectPool)
            local timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("ZO_StatusBarGrowTemplate")
            timeline:GetFirstAnimation():SetUpdateFunction(function (customAnimation, progress)
                owner:OnStaminaBarAnimationUpdate(customAnimation, progress)
            end)
            timeline:SetHandler("OnStop", function (timelineSelf, ...)
                owner:OnStaminaBarAnimationStop(timelineSelf, ...)
            end)
            return timeline
        end

        local function Reset(timeline)
            local customAnimation = timeline:GetFirstAnimation()
            customAnimation.bar = nil
            customAnimation.initialValue = nil
            customAnimation.endValue = nil
        end

        self.staminaBarAnimationPool = ZO_ObjectPool:New(Factory, Reset)
    end

    local timeline, key = self.staminaBarAnimationPool:AcquireObject()
    timeline.key = key
    return timeline
end

--- Stops LUIE player stamina smooth animation (when dodge prediction or smooth bar is disabled).
--- @param bar StatusBarControl|nil
function LUIE_PlayerDodgePrediction:StopStaminaBarSmoothAnimation(bar)
    if not bar or not bar.luiStaminaDodgeAnimation then
        return
    end
    bar.luiStaminaDodgeAnimation:Stop()
end

--- @param bar StatusBarControl
--- @param cost integer
--- @return boolean
function LUIE_PlayerDodgePrediction:PrepareStaminaDodgeMarkersForSmoothBar(bar, cost)
    local staminaFrame = self:GetPlayerStaminaFrame()
    if not staminaFrame or staminaFrame.bar ~= bar or cost <= 0 then
        return false
    end

    local backdrop = staminaFrame.backdrop
    if not backdrop then
        return false
    end

    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    if barWidth <= 0 or barHeight <= 0 then
        return false
    end

    staminaFrame.dodgePredictionLastCost = cost
    local alignment = GetStaminaBarAlignment()
    local line, lineLeft, lineRight = self:AcquireStaminaMarkers(bar, staminaFrame)
    ClearDodgeMarkerPositionCache(staminaFrame)

    if alignment == 3 then
        if not lineLeft or not lineRight then
            return false
        end
        lineLeft:SetHidden(false)
        lineRight:SetHidden(false)
    else
        if not line then
            return false
        end
        line:SetHidden(false)
    end
    return true
end

--- @param cost integer
--- @param positionOnly boolean|nil
function LUIE_PlayerDodgePrediction:PublishDodgeCostIfChanged(cost, positionOnly)
    if positionOnly then
        return
    end
    if self.lastPublishedCost ~= cost then
        self.lastPublishedCost = cost
        self:FireCallbacks(LUIE_PLAYER_DODGE_PREDICTION_CALLBACK_DODGE_COST_CHANGED, cost)
    end
end

--- Smooth transition for player stamina when dodge prediction uses combined bar+marker animation (see ZO_StatusBar_SmoothTransition).
--- @param bar StatusBarControl
--- @param value number
--- @param max number
--- @param forceInit boolean|nil
function LUIE_PlayerDodgePrediction:SmoothTransitionStaminaBar(bar, value, max, forceInit)
    local cost = self:GetPredictedRollDodgeStaminaCost()
    if cost > 0 then
        self:PrepareStaminaDodgeMarkersForSmoothBar(bar, cost)
    end

    local oldValue = bar:GetValue()
    bar:SetMinMax(0, max)
    local oldMax = bar.max or max
    bar.max = max

    if forceInit or max <= 0 then
        bar:SetValue(value)
        if bar.luiStaminaDodgeAnimation then
            bar.luiStaminaDodgeAnimation:Stop()
        end
        self:PositionMarkerFromBar(bar, value, max)
        return
    end

    if oldMax > 0 and oldMax ~= max then
        local maxChange = max / oldMax
        oldValue = oldValue * maxChange
        bar:SetValue(oldValue)
    end

    if not bar.luiStaminaDodgeAnimation then
        bar.luiStaminaDodgeAnimation = self:AcquireStaminaBarAnimation()
    end

    local customAnimation = bar.luiStaminaDodgeAnimation:GetFirstAnimation()
    customAnimation:SetDuration(LUIE_STAMINA_SMOOTH_MS)
    customAnimation.bar = bar
    customAnimation.initialValue = oldValue
    customAnimation.endValue = value

    bar.luiStaminaDodgeAnimation:PlayFromStart()
end

--- @param positionOnly boolean|nil When true, reuse last predicted cost (stamina bar value updates only).
function LUIE_PlayerDodgePrediction:Refresh(positionOnly)
    local staminaFrame = self:GetPlayerStaminaFrame()

    if not self:IsFeatureEnabled() then
        if staminaFrame and staminaFrame.bar then
            self:StopStaminaBarSmoothAnimation(staminaFrame.bar)
        end
        self:ReleaseStaminaMarker(staminaFrame)
        return
    end

    local backdrop = staminaFrame and staminaFrame.backdrop
    local bar = staminaFrame and staminaFrame.bar
    if not backdrop or not bar then
        self:ReleaseStaminaMarker(staminaFrame)
        return
    end

    local cost
    if positionOnly and staminaFrame.dodgePredictionLastCost then
        cost = staminaFrame.dodgePredictionLastCost
    else
        cost = self:GetPredictedRollDodgeStaminaCost()
    end
    if cost <= 0 then
        self:ReleaseStaminaMarker(staminaFrame)
        return
    end

    local displayed, effectiveMax = self:GetStaminaBarValues(staminaFrame)
    if not effectiveMax or effectiveMax <= 0 then
        self:ReleaseStaminaMarker(staminaFrame)
        return
    end

    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    if barWidth <= 0 or barHeight <= 0 then
        self:ReleaseStaminaMarker(staminaFrame)
        return
    end

    local alignment = GetStaminaBarAlignment()
    local line, lineLeft, lineRight = self:AcquireStaminaMarkers(bar, staminaFrame)
    local predicted = zo_clamp(displayed - cost, 0, effectiveMax)
    local canAfford = displayed >= cost

    staminaFrame.dodgePredictionLastCost = cost
    ClearDodgeMarkerPositionCache(staminaFrame)
    self:PublishDodgeCostIfChanged(cost, positionOnly)

    if alignment == 3 then
        if not lineLeft or not lineRight then
            return
        end
        ApplyLineColor(lineLeft, canAfford)
        ApplyLineColor(lineRight, canAfford)
        PositionDodgeMarkerCenter(lineLeft, lineRight, bar, predicted, effectiveMax, staminaFrame)
        lineLeft:SetHidden(false)
        lineRight:SetHidden(false)
    else
        if not line then
            return
        end
        ApplyLineColor(line, canAfford)
        PositionDodgeMarkerEdge(line, bar, predicted, alignment, staminaFrame)
        line:SetHidden(false)
    end
end

function LUIE_PlayerDodgePrediction:RegisterEvents()
    if self.eventsRegistered then
        return
    end
    self.eventsRegistered = true

    local onRefresh = function ()
        self:Refresh()
    end

    local effectHandler = moduleName .. "DodgePredictionEffect"
    eventManager:RegisterForEvent(effectHandler, EVENT_EFFECT_CHANGED, function (_, changeType, _, _, _, _, _, stackCount, _, _, _, _, _, _, _, abilityId)
        if self:OnExpertEvasionEffectChanged(changeType, abilityId)
        or self:OnDodgeFatigueEffectChanged(changeType, abilityId, stackCount) then
            onRefresh()
        end
    end)
    eventManager:AddFilterForEvent(effectHandler, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionInventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onRefresh)

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionChampion", EVENT_CHAMPION_POINT_UPDATE, function (_, unitTag)
        if unitTag == "player" then
            self:SyncExpertEvasionCooldownFromBuffs()
            onRefresh()
        end
    end)

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionPlayerActivated", EVENT_PLAYER_ACTIVATED, function ()
        self:SyncExpertEvasionCooldownFromBuffs()
        self:SyncPlayerDodgeFatigueStacksFromBuffs()
        onRefresh()
    end)

    local hotbarHandler = moduleName .. "DodgePredictionHotbar"
    eventManager:RegisterForEvent(hotbarHandler, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, onRefresh)
    eventManager:AddFilterForEvent(hotbarHandler, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, REGISTER_FILTER_UNIT_TAG, "player")

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionChampionBar", EVENT_HOTBAR_SLOT_UPDATED, function (_, _, hotbarCategory)
        if hotbarCategory == HOTBAR_CATEGORY_CHAMPION then
            onRefresh()
        end
    end)
    eventManager:RegisterForEvent(moduleName .. "DodgePredictionChampionBars", EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, onRefresh)

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionChampionPurchase", EVENT_CHAMPION_PURCHASE_RESULT, function (_, result)
        if result == CHAMPION_PURCHASE_SUCCESS then
            onRefresh()
        end
    end)
end

function LUIE_PlayerDodgePrediction:Initialize()
    if not UnitFrames.Enabled then
        return
    end
    self:SyncExpertEvasionCooldownFromBuffs()
    self:SyncPlayerDodgeFatigueStacksFromBuffs()
    self:RegisterEvents()
    self:Refresh()
end

-- -----------------------------------------------------------------------------
-- Facade (preserves UnitFrames.PlayerDodgePrediction.* call sites)
-- -----------------------------------------------------------------------------

UnitFrames.PlayerDodgePrediction = {}

local function GetDodgePredictionInstance()
    return UnitFrames.dodgePrediction
end

function UnitFrames.PlayerDodgePrediction.Initialize()
    if not UnitFrames.dodgePrediction then
        UnitFrames.dodgePrediction = LUIE_PlayerDodgePrediction:New()
    end
    UnitFrames.dodgePrediction:Initialize()
end

function UnitFrames.PlayerDodgePrediction.RegisterEvents()
    local instance = GetDodgePredictionInstance()
    if instance then
        instance:RegisterEvents()
    end
end

function UnitFrames.PlayerDodgePrediction.Refresh(positionOnly)
    local instance = GetDodgePredictionInstance()
    if instance then
        instance:Refresh(positionOnly)
    end
end

function UnitFrames.PlayerDodgePrediction.ShouldUseLUIEStaminaSmooth()
    local instance = GetDodgePredictionInstance()
    return instance and instance:ShouldUseLUIEStaminaSmooth() or false
end

function UnitFrames.PlayerDodgePrediction.SmoothTransitionStaminaBar(bar, value, max, forceInit)
    local instance = GetDodgePredictionInstance()
    if instance then
        instance:SmoothTransitionStaminaBar(bar, value, max, forceInit)
    end
end

function UnitFrames.PlayerDodgePrediction.StopStaminaBarSmoothAnimation(bar)
    local instance = GetDodgePredictionInstance()
    if instance then
        instance:StopStaminaBarSmoothAnimation(bar)
    end
end

function UnitFrames.PlayerDodgePrediction.PositionMarkerFromBar(bar, displayed, effectiveMax)
    local instance = GetDodgePredictionInstance()
    if instance then
        instance:PositionMarkerFromBar(bar, displayed, effectiveMax)
    end
end
