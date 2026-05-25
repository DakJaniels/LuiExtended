--- @diagnostic disable: undefined-field, missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local eventManager = GetEventManager()
local moduleName = UnitFrames.moduleName

UnitFrames.PlayerDodgePrediction = {}

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

local eventsRegistered = false
local smoothUpdateRegistered = false
local markerPool
local expertEvasionOnCooldown = false
local DODGE_PREDICTION_SMOOTH_UPDATE = moduleName .. "DodgePredictionSmoothUpdate"

local function IsFeatureEnabled()
    local sv = UnitFrames.SV
    return UnitFrames.Enabled and sv and sv.CustomFramesPlayer and sv.ShowPlayerDodgePrediction
end

--- @return table|nil stamina attribute frame from custom player UI
local function GetPlayerStaminaFrame()
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

local function SyncExpertEvasionCooldownFromBuffs()
    expertEvasionOnCooldown = PlayerHasBuffAbility(EXPERT_EVASION_COOLDOWN_ABILITY_ID)
end

--- @param changeType integer
--- @param abilityId integer
local function OnExpertEvasionEffectChanged(changeType, abilityId)
    if abilityId ~= EXPERT_EVASION_COOLDOWN_ABILITY_ID then
        return
    end
    if changeType == EFFECT_RESULT_FADED then
        expertEvasionOnCooldown = false
    elseif changeType == EFFECT_RESULT_GAINED
    or     changeType == EFFECT_RESULT_UPDATED
    or     changeType == EFFECT_RESULT_FULL_REFRESH then
        expertEvasionOnCooldown = true
    end
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
local function GetPlayerDodgeFatigueStacks()
    for i = 1, GetNumBuffs("player") do
        local _, _, _, _, stackCount, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if abilityId == DODGE_FATIGUE_ABILITY_ID then
            return stackCount or 0
        end
    end
    return 0
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

--- GetAbilityCost(28549) is base; Athletics reduces cost; Dodge Fatigue stacks multiply cost (LuiData 69143, combat log verified).
--- @param baseCost integer
--- @return integer
local function ApplyDodgeFatigueToCost(baseCost)
    local stacks = GetPlayerDodgeFatigueStacks()
    if stacks <= 0 then
        return baseCost
    end
    local percentPerStack = GetDodgeFatiguePercentPerStack()
    return zo_max(0, zo_round(baseCost * ((1 + percentPerStack / 100) ^ stacks)))
end

--- Next roll dodge stamina cost (GetAbilityCost + Athletics + Dodge Fatigue + Expert Evasion).
--- @return integer
local function GetPredictedRollDodgeStaminaCost()
    local cost = zo_max(0, GetAbilityCost(ROLL_DODGE_ABILITY_ID, COMBAT_MECHANIC_FLAGS_STAMINA, nil, "player"))
    cost = ApplyAthleticsRollDodgeCostReduction(cost)
    if not PlayerHasExpertEvasionChampionPassive() then
        return ApplyDodgeFatigueToCost(cost)
    end
    if expertEvasionOnCooldown then
        return ApplyDodgeFatigueToCost(cost)
    end
    return 0
end

--- @return integer 1 = L→R, 2 = R→L, 3 = center
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
local function GetStaminaBarValues(staminaFrame, useBarAnimatedValue)
    local bar = staminaFrame.bar
    if bar then
        local _, max = bar:GetMinMax()
        local displayed = bar:GetValue()
        if UnitFrames.SV.CustomSmoothBar and not useBarAnimatedValue then
            displayed = ZO_StatusBar_GetTargetValue(bar) or displayed
        end
        if max and max > 0 then
            return displayed, max
        end
    end
    local powerValue, _, powerEffectiveMax = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
    return powerValue, powerEffectiveMax
end

--- L→R / R→L: single edge at predicted fill boundary.
--- @param line Control
--- @param bar StatusBarControl
--- @param predicted number
--- @param alignment integer
local function PositionDodgeMarkerEdge(line, bar, predicted, alignment)
    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    local lineX = bar:CalculateSizeWithoutLeadingEdgeForValue(predicted)
    lineX = zo_clamp(lineX, 0, zo_max(0, barWidth - MARKER_WIDTH))

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
local function PositionDodgeMarkerCenter(lineLeft, lineRight, bar, predicted, effectiveMax)
    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    local percent = zo_clamp(predicted / effectiveMax, 0, 1)
    local halfSpan = (barWidth * percent) / 2
    halfSpan = zo_min(halfSpan, zo_max(0, (barWidth / 2) - MARKER_WIDTH))
    local centerX = barWidth / 2
    local leftX = centerX - halfSpan - MARKER_WIDTH
    local rightX = centerX + halfSpan

    lineLeft:ClearAnchors()
    lineRight:ClearAnchors()
    lineLeft:SetDimensions(MARKER_WIDTH, barHeight)
    lineRight:SetDimensions(MARKER_WIDTH, barHeight)
    lineLeft:SetAnchor(TOPLEFT, bar, TOPLEFT, leftX, 0)
    lineLeft:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, leftX, 0)
    lineRight:SetAnchor(TOPLEFT, bar, TOPLEFT, rightX, 0)
    lineRight:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, rightX, 0)
end

local function UnregisterSmoothPositionUpdate()
    if smoothUpdateRegistered then
        eventManager:UnregisterForUpdate(DODGE_PREDICTION_SMOOTH_UPDATE)
        smoothUpdateRegistered = false
    end
end

local function RegisterSmoothPositionUpdate()
    if smoothUpdateRegistered or not UnitFrames.SV.CustomSmoothBar then
        return
    end
    smoothUpdateRegistered = true
    eventManager:RegisterForUpdate(DODGE_PREDICTION_SMOOTH_UPDATE, 0, function ()
        local staminaFrame = GetPlayerStaminaFrame()
        if not staminaFrame or not staminaFrame.dodgePredictionLastCost then
            UnregisterSmoothPositionUpdate()
            return
        end
        local bar = staminaFrame.bar
        if not bar then
            UnregisterSmoothPositionUpdate()
            return
        end
        local displayed, effectiveMax = GetStaminaBarValues(staminaFrame, true)
        if not effectiveMax or effectiveMax <= 0 then
            return
        end
        local cost = staminaFrame.dodgePredictionLastCost
        local predicted = zo_clamp(displayed - cost, 0, effectiveMax)
        local alignment = GetStaminaBarAlignment()
        if alignment == 3 then
            local lineLeft = staminaFrame.dodgePredictionLineCenterLeft
            local lineRight = staminaFrame.dodgePredictionLineCenterRight
            if not lineLeft or not lineRight or lineLeft:IsHidden() or lineRight:IsHidden() then
                UnregisterSmoothPositionUpdate()
                return
            end
            PositionDodgeMarkerCenter(lineLeft, lineRight, bar, predicted, effectiveMax)
        else
            local line = staminaFrame.dodgePredictionLine
            if not line or line:IsHidden() then
                UnregisterSmoothPositionUpdate()
                return
            end
            PositionDodgeMarkerEdge(line, bar, predicted, alignment)
        end
    end)
end

--- @param staminaFrame table|nil
local function ReleaseStaminaMarker(staminaFrame)
    UnregisterSmoothPositionUpdate()
    if not staminaFrame then
        return
    end
    staminaFrame.dodgePredictionLastCost = nil
    if markerPool then
        if staminaFrame.dodgePredictionPoolKey then
            markerPool:ReleaseObject(staminaFrame.dodgePredictionPoolKey)
        end
        if staminaFrame.dodgePredictionPoolKeyCenterLeft then
            markerPool:ReleaseObject(staminaFrame.dodgePredictionPoolKeyCenterLeft)
        end
        if staminaFrame.dodgePredictionPoolKeyCenterRight then
            markerPool:ReleaseObject(staminaFrame.dodgePredictionPoolKeyCenterRight)
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
local function GetMarkerPool(bar)
    if markerPool and markerPool.parent == bar then
        return markerPool
    end
    if markerPool then
        markerPool:ReleaseAllObjects()
    end
    markerPool = ZO_ControlPool:New(MARKER_POOL_TEMPLATE, bar, "DodgePredictionMarker")
    markerPool:SetCustomFactoryBehavior(function (line)
        line:SetEdgeTexture("", 1, 1, 0, 0)
    end)
    return markerPool
end

--- @param bar StatusBarControl
--- @param staminaFrame table
--- @return Control|nil line edge alignment
--- @return Control|nil lineLeft center alignment
--- @return Control|nil lineRight center alignment
local function AcquireStaminaMarkers(bar, staminaFrame)
    local pool = GetMarkerPool(bar)
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

    ReleaseStaminaMarker(staminaFrame)

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

function UnitFrames.PlayerDodgePrediction.Refresh()
    local staminaFrame = GetPlayerStaminaFrame()

    if not IsFeatureEnabled() then
        ReleaseStaminaMarker(staminaFrame)
        return
    end

    local backdrop = staminaFrame and staminaFrame.backdrop
    local bar = staminaFrame and staminaFrame.bar
    if not backdrop or not bar then
        ReleaseStaminaMarker(staminaFrame)
        return
    end

    local cost = GetPredictedRollDodgeStaminaCost()
    if cost <= 0 then
        ReleaseStaminaMarker(staminaFrame)
        return
    end

    local displayed, effectiveMax = GetStaminaBarValues(staminaFrame)
    if not effectiveMax or effectiveMax <= 0 then
        ReleaseStaminaMarker(staminaFrame)
        return
    end

    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    if barWidth <= 0 or barHeight <= 0 then
        ReleaseStaminaMarker(staminaFrame)
        return
    end

    local alignment = GetStaminaBarAlignment()
    local line, lineLeft, lineRight = AcquireStaminaMarkers(bar, staminaFrame)
    local predicted = zo_clamp(displayed - cost, 0, effectiveMax)
    local canAfford = displayed >= cost

    staminaFrame.dodgePredictionLastCost = cost

    if alignment == 3 then
        if not lineLeft or not lineRight then
            return
        end
        ApplyLineColor(lineLeft, canAfford)
        ApplyLineColor(lineRight, canAfford)
        PositionDodgeMarkerCenter(lineLeft, lineRight, bar, predicted, effectiveMax)
        lineLeft:SetHidden(false)
        lineRight:SetHidden(false)
    else
        if not line then
            return
        end
        ApplyLineColor(line, canAfford)
        PositionDodgeMarkerEdge(line, bar, predicted, alignment)
        line:SetHidden(false)
    end
    RegisterSmoothPositionUpdate()
end

function UnitFrames.PlayerDodgePrediction.RegisterEvents()
    if eventsRegistered then
        return
    end
    eventsRegistered = true

    local onRefresh = function ()
        UnitFrames.PlayerDodgePrediction.Refresh()
    end

    local effectHandler = moduleName .. "DodgePredictionEffect"
    eventManager:RegisterForEvent(effectHandler, EVENT_EFFECT_CHANGED, function (_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
        OnExpertEvasionEffectChanged(changeType, abilityId)
        onRefresh()
    end)
    eventManager:AddFilterForEvent(effectHandler, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionInventory", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onRefresh)

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionChampion", EVENT_CHAMPION_POINT_UPDATE, function (_, unitTag)
        if unitTag == "player" then
            SyncExpertEvasionCooldownFromBuffs()
            onRefresh()
        end
    end)

    eventManager:RegisterForEvent(moduleName .. "DodgePredictionPlayerActivated", EVENT_PLAYER_ACTIVATED, function ()
        SyncExpertEvasionCooldownFromBuffs()
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

function UnitFrames.PlayerDodgePrediction.Initialize()
    if not UnitFrames.Enabled then
        return
    end
    SyncExpertEvasionCooldownFromBuffs()
    UnitFrames.PlayerDodgePrediction.RegisterEvents()
    UnitFrames.PlayerDodgePrediction.Refresh()
end
