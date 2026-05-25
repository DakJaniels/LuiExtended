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
-- Expert Evasion: ICD debuff after a free roll (LuiData Effects/Override.lua, ability 151113).
local EXPERT_EVASION_COOLDOWN_ABILITY_ID = 151113
-- Champion node id (GetChampionAbilityId -> 151113); stable across clients.
local EXPERT_EVASION_CHAMPION_SKILL_ID = 51
local DODGE_FATIGUE_ABILITY_ID = 69143
local MARKER_POOL_TEMPLATE = "LUIE_DodgePredictionMarker"
local DEFAULT_DODGE_FATIGUE_PERCENT_PER_STACK = 33
local MARKER_POOL_OBJECT_KEY = 1
local MARKER_WIDTH = 2

local eventsRegistered = false
local markerPool
local expertEvasionOnCooldown = false

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

--- Expert Evasion champion node (Conditioning / Fitness). Uses GetChampionAbilityId + GetNumPointsSpentOnChampionSkill.
--- @return integer|nil championSkillId
local function GetExpertEvasionChampionSkillId()
    if GetChampionAbilityId(EXPERT_EVASION_CHAMPION_SKILL_ID) == EXPERT_EVASION_COOLDOWN_ABILITY_ID then
        return EXPERT_EVASION_CHAMPION_SKILL_ID
    end
    for disciplineIndex = 1, GetNumChampionDisciplines() do
        if GetChampionDisciplineType(GetChampionDisciplineId(disciplineIndex)) == CHAMPION_DISCIPLINE_TYPE_CONDITIONING then
            for skillIndex = 1, GetNumChampionDisciplineSkills(disciplineIndex) do
                local championSkillId = GetChampionSkillId(disciplineIndex, skillIndex)
                if GetChampionAbilityId(championSkillId) == EXPERT_EVASION_COOLDOWN_ABILITY_ID then
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

--- GetAbilityCost(28549) is base; Dodge Fatigue stacks multiply cost (LuiData 69143, combat log verified).
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

--- Next roll dodge stamina cost (GetAbilityCost + Dodge Fatigue + Expert Evasion).
--- @return integer
local function GetPredictedRollDodgeStaminaCost()
    local cost = zo_max(0, GetAbilityCost(ROLL_DODGE_ABILITY_ID, COMBAT_MECHANIC_FLAGS_STAMINA, nil, "player"))
    if not PlayerHasExpertEvasionChampionPassive() then
        return ApplyDodgeFatigueToCost(cost)
    end
    if expertEvasionOnCooldown then
        return ApplyDodgeFatigueToCost(cost)
    end
    return 0
end

--- @param staminaFrame table
--- @return integer displayed
--- @return integer effectiveMax
local function GetStaminaBarValues(staminaFrame)
    local bar = staminaFrame.bar
    if bar then
        local _, max = bar:GetMinMax()
        local displayed = bar:GetValue()
        if max and max > 0 then
            return displayed, max
        end
    end
    local powerValue, _, powerEffectiveMax = GetUnitPower("player", COMBAT_MECHANIC_FLAGS_STAMINA)
    return powerValue, powerEffectiveMax
end

--- @param staminaFrame table|nil
local function ReleaseStaminaMarker(staminaFrame)
    if not staminaFrame or not staminaFrame.dodgePredictionPoolKey or not markerPool then
        return
    end
    markerPool:ReleaseObject(staminaFrame.dodgePredictionPoolKey)
    staminaFrame.dodgePredictionLine = nil
    staminaFrame.dodgePredictionPoolKey = nil
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
--- @return Control|nil
local function AcquireStaminaMarker(bar, staminaFrame)
    local pool = GetMarkerPool(bar)
    local line = staminaFrame.dodgePredictionLine
    if line and staminaFrame.dodgePredictionPoolKey and line:GetParent() == bar then
        return line
    end
    ReleaseStaminaMarker(staminaFrame)
    local key
    line, key = pool:AcquireObject(MARKER_POOL_OBJECT_KEY)
    staminaFrame.dodgePredictionLine = line
    staminaFrame.dodgePredictionPoolKey = key
    return line
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

    local line = AcquireStaminaMarker(bar, staminaFrame)
    if not line then
        return
    end

    local predicted = zo_clamp(displayed - cost, 0, effectiveMax)
    local lineX = bar:CalculateSizeWithoutLeadingEdgeForValue(predicted)
    lineX = zo_clamp(lineX, 0, zo_max(0, barWidth - MARKER_WIDTH))

    ApplyLineColor(line, displayed >= cost)
    line:ClearAnchors()
    line:SetDimensions(MARKER_WIDTH, barHeight)
    line:SetAnchor(TOPLEFT, bar, TOPLEFT, lineX, 0)
    line:SetAnchor(BOTTOMLEFT, bar, BOTTOMLEFT, lineX, 0)
    line:SetHidden(false)
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
