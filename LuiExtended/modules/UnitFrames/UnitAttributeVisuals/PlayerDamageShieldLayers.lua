-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

--- @type LUIE.CustomFramesShared
local Shared = LUIE.CustomFramesShared

local eventManager = EVENT_MANAGER

local PLAYER_UNIT_TAG = "player"
local RECONCILE_UPDATE_NAME = "LUIE_PlayerDamageShieldLayers_Reconcile"
local EFFECT_EVENT_NAME = "LUIE_PlayerDamageShieldLayers_Effect"
local SETTING_EVENT_NAME = "LUIE_PlayerDamageShieldLayers_Setting"
local FADED_ALPHA_RATIO = 0.3
local SHIELD_VALUE_EPSILON = 0.5
local IDENTITY_CLAIM_SECONDS = 1
local HELD_GAIN_RECONCILE_LIMIT = 2
local SMOOTH_TRANSITION_MS = 250
local SHIELD_LAYER_DRAW_LEVEL = Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 2
local PRIORITY_SHIELD_LAYER_DRAW_LEVEL = Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 3
local OVERLAY_ABOVE_SHIELD_DRAW_LEVEL = Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 4
local OVERLAY_BELOW_SHIELD_DRAW_LEVEL = Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 1

--- @class LUIE_PlayerDamageShieldRecord
--- @field effectSlot integer|nil
--- @field abilityId integer|nil
--- @field beginTime number
--- @field value number
--- @field awaitingIdentity boolean

--- @class LUIE_PlayerDamageShieldHeldGain
--- @field effectSlot integer
--- @field abilityId integer
--- @field beginTime number
--- @field reconcilesRemaining integer

--- @class LUIE_PlayerDamageShieldLayers
local PlayerDamageShieldLayers = {}
LUIE.PlayerDamageShieldLayers = PlayerDamageShieldLayers

--- @type LUIE_PlayerDamageShieldRecord[]
local playerShieldRecords = {}
--- @type LUIE_PlayerDamageShieldHeldGain[]
local heldEffectGains = {}
--- @type integer[]
local heldFadedEffectSlots = {}

local pendingShieldSum = 0
local pendingShieldSumIsSet = false
local pendingFullRefresh = false
local unitChangeInProgress = false
local reconcileRegistered = false
local ledgerGeneration = 0

--- @param array table
local function WipeArray(array)
    for index = #array, 1, -1 do
        array[index] = nil
    end
end

--- @return number
local function GetDamageShieldVisibilitySetting()
    return tonumber(GetSetting(SETTING_TYPE_COMBAT, COMBAT_SETTING_DAMAGE_SHIELD_VISIBILITY))
end

--- @return UnitFrames.CustomFramePowerEntry|nil
local function GetPlayerHealthEntry()
    local playerFrame = UnitFrames.CustomFrames[PLAYER_UNIT_TAG]
    if not playerFrame then
        return nil
    end
    return playerFrame[COMBAT_MECHANIC_FLAGS_HEALTH]
end

--- @return number
local function GetPlayerHealthEffectiveMax()
    if DoesUnitExist(PLAYER_UNIT_TAG) then
        local _, _, healthEffectiveMax = GetUnitPower(PLAYER_UNIT_TAG, COMBAT_MECHANIC_FLAGS_HEALTH)
        return healthEffectiveMax
    end
    local savedHealth = UnitFrames.savedHealth[PLAYER_UNIT_TAG]
    if savedHealth then
        return savedHealth[3]
    end
    return 1
end

--- @return number
local function SumShieldRecords()
    local total = 0
    for index = 1, #playerShieldRecords do
        total = total + playerShieldRecords[index].value
    end
    return total
end

--- @return integer
local function CountActiveShieldRecords()
    local activeCount = 0
    for index = 1, #playerShieldRecords do
        if playerShieldRecords[index].value > 0 then
            activeCount = activeCount + 1
        end
    end
    return activeCount
end

--- @return integer
function PlayerDamageShieldLayers.GetActiveLayerCount()
    return CountActiveShieldRecords()
end

local function ClearShieldRecords()
    WipeArray(playerShieldRecords)
end

--- @param effectSlot integer
local function RemoveShieldRecordsForEffectSlot(effectSlot)
    for index = #playerShieldRecords, 1, -1 do
        if playerShieldRecords[index].effectSlot == effectSlot then
            table.remove(playerShieldRecords, index)
        end
    end
end

--- Attribute visuals only publish the summed shield. Scale keeps every live record's share of that sum.
--- @param shieldSum number
--- @return boolean createdAnonymous
local function ScaleShieldRecordsToSum(shieldSum)
    if shieldSum <= SHIELD_VALUE_EPSILON then
        ClearShieldRecords()
        return false
    end

    local ledgerSum = SumShieldRecords()
    if ledgerSum <= SHIELD_VALUE_EPSILON then
        ClearShieldRecords()
        playerShieldRecords[1] =
        {
            effectSlot = nil,
            abilityId = nil,
            beginTime = GetFrameTimeSeconds(),
            value = shieldSum,
            awaitingIdentity = true,
        }
        return true
    end

    local scale = shieldSum / ledgerSum
    for index = 1, #playerShieldRecords do
        playerShieldRecords[index].value = playerShieldRecords[index].value * scale
    end
    return false
end

--- @param visibilitySetting DamageShieldVisibilitySetting
--- @return integer|nil
local function FindPriorityShieldRecordIndex(visibilitySetting)
    local priorityIndex = nil
    if visibilitySetting == DAMAGE_SHIELD_VISIBILITY_SETTING_START_TIME then
        local earliestBeginTime = nil
        for index = 1, #playerShieldRecords do
            local record = playerShieldRecords[index]
            if record.value > 0 and (earliestBeginTime == nil or record.beginTime < earliestBeginTime) then
                earliestBeginTime = record.beginTime
                priorityIndex = index
            end
        end
        return priorityIndex
    end

    local highestValue = nil
    local earliestBeginTime = nil
    for index = 1, #playerShieldRecords do
        local record = playerShieldRecords[index]
        if record.value > 0 then
            local takesPriority = highestValue == nil
                or record.value > highestValue
                or (record.value == highestValue and record.beginTime < earliestBeginTime)
            if takesPriority then
                highestValue = record.value
                earliestBeginTime = record.beginTime
                priorityIndex = index
            end
        end
    end
    return priorityIndex
end

--- @return boolean
function PlayerDamageShieldLayers.IsDrawingLayers()
    local visibilitySetting = GetDamageShieldVisibilitySetting()
    if visibilitySetting == DAMAGE_SHIELD_VISIBILITY_SETTING_OFF then
        return false
    end
    if visibilitySetting ~= DAMAGE_SHIELD_VISIBILITY_SETTING_CURRENT_HEALTH
        and visibilitySetting ~= DAMAGE_SHIELD_VISIBILITY_SETTING_START_TIME then
        return false
    end
    return CountActiveShieldRecords() >= 2
end

--- Same fill alpha as GetShieldBarFillAlpha("player") in the unit frame color menu.
--- @return number
local function GetPlayerShieldFillAlpha()
    if UnitFrames.SV.CustomShieldBarSeparate then
        return UnitFrames.SV.CustomColourShield[4] or (UnitFrames.SV.ShieldAlpha / 100) or 1
    end
    return UnitFrames.SV.ShieldAlpha / 100
end

--- @return number red, number green, number blue, number fullAlpha
local function GetPlayerShieldColor()
    local shieldColor = UnitFrames.SV.CustomColourShield
    return shieldColor[1], shieldColor[2], shieldColor[3], GetPlayerShieldFillAlpha()
end

--- @param layerBar StatusBarControl
--- @param shieldBar StatusBarControl
local function AnchorShieldLayerBar(layerBar, shieldBar)
    layerBar:SetParent(shieldBar:GetParent())
    layerBar:ClearAnchors()
    layerBar:SetAnchor(TOPLEFT, shieldBar, TOPLEFT, 0, 0)
    layerBar:SetAnchor(BOTTOMRIGHT, shieldBar, BOTTOMRIGHT, 0, 0)
    layerBar:SetDrawLayer(shieldBar:GetDrawLayer())
    layerBar:SetDrawTier(shieldBar:GetDrawTier())
    local appearance = UnitFrames.GetCustomFrameAppearance("player")
    layerBar:SetTexture(LUIE.StatusbarTextures[appearance.texture])
end

--- @param healthFrame UnitFrames.CustomFramePowerEntry
--- @return StatusBarControl
local function AcquireShieldLayerBar(healthFrame)
    local pool = healthFrame.shieldLayers
    for index = 1, #pool do
        if not pool[index].shieldLayerInUse then
            pool[index].shieldLayerInUse = true
            return pool[index]
        end
    end

    local layerIndex = #pool + 1
    local layerBar = healthFrame.backdrop:CreateControl("$(parent)ShieldLayer" .. layerIndex, CT_STATUSBAR)
    layerBar:SetMouseEnabled(false)
    layerBar:SetHidden(true)
    layerBar:SetAlpha(1)
    layerBar.shieldLayerInUse = true
    pool[layerIndex] = layerBar
    return layerBar
end

--- @param healthFrame UnitFrames.CustomFramePowerEntry
--- @param layersActive boolean
function PlayerDamageShieldLayers.ApplyOverlayDrawLevels(healthFrame, layersActive)
    local overlayDrawLevel = layersActive and OVERLAY_ABOVE_SHIELD_DRAW_LEVEL or OVERLAY_BELOW_SHIELD_DRAW_LEVEL
    if healthFrame.trauma then
        healthFrame.trauma:SetDrawLevel(overlayDrawLevel)
    end
    if healthFrame.noHealingOverlay then
        healthFrame.noHealingOverlay:SetDrawLevel(overlayDrawLevel)
    end
    if healthFrame.noHealingStripe then
        healthFrame.noHealingStripe:SetDrawLevel(overlayDrawLevel)
    end
end

--- @param healthFrame UnitFrames.CustomFramePowerEntry
function PlayerDamageShieldLayers.HideLayerBars(healthFrame)
    local pool = healthFrame.shieldLayers
    if not pool then
        return
    end
    for index = 1, #pool do
        local layerBar = pool[index]
        layerBar.shieldLayerInUse = false
        if layerBar.animation then
            layerBar.animation:Stop()
        end
        layerBar:SetValue(0)
        layerBar:SetHidden(true)
    end
    PlayerDamageShieldLayers.ApplyOverlayDrawLevels(healthFrame, false)
end

--- @param healthFrame UnitFrames.CustomFramePowerEntry
function PlayerDamageShieldLayers.ApplyAnchors(healthFrame)
    if not healthFrame.shield or not healthFrame.shieldLayers then
        return
    end
    local pool = healthFrame.shieldLayers
    for index = 1, #pool do
        AnchorShieldLayerBar(pool[index], healthFrame.shield)
    end
end

--- @param layerBar StatusBarControl
--- @param shieldValue number
--- @param healthEffectiveMax number
--- @param alpha number
--- @param drawLevel integer
--- @param shieldBar StatusBarControl
local function ShowShieldLayerBar(layerBar, shieldValue, healthEffectiveMax, alpha, drawLevel, shieldBar)
    AnchorShieldLayerBar(layerBar, shieldBar)
    layerBar:SetDrawLevel(drawLevel)
    local red, green, blue = GetPlayerShieldColor()
    layerBar:SetColor(red, green, blue, alpha)
    layerBar:SetHidden(false)
    if UnitFrames.SV.CustomSmoothBar then
        ZO_StatusBar_SmoothTransition(layerBar, shieldValue, healthEffectiveMax, false, nil, SMOOTH_TRANSITION_MS)
    else
        layerBar:SetMinMax(0, healthEffectiveMax)
        layerBar:SetValue(shieldValue)
    end
end

--- @param healthFrame UnitFrames.CustomFramePowerEntry
--- @param shieldValue number
--- @param healthEffectiveMax number
--- @return boolean layersDrawn
function PlayerDamageShieldLayers.UpdateShieldBar(healthFrame, shieldValue, healthEffectiveMax)
    if not PlayerDamageShieldLayers.IsDrawingLayers() then
        return false
    end

    local visibilitySetting = GetDamageShieldVisibilitySetting()
    local priorityIndex = FindPriorityShieldRecordIndex(visibilitySetting)
    local _, _, _, fullAlpha = GetPlayerShieldColor()
    local fadedAlpha = fullAlpha * FADED_ALPHA_RATIO
    local pool = healthFrame.shieldLayers

    for index = 1, #pool do
        pool[index].shieldLayerInUse = false
    end

    for index = 1, #playerShieldRecords do
        local record = playerShieldRecords[index]
        if record.value > 0 then
            local layerBar = AcquireShieldLayerBar(healthFrame)
            local isPriority = index == priorityIndex
            local alpha = isPriority and fullAlpha or fadedAlpha
            local drawLevel = isPriority and PRIORITY_SHIELD_LAYER_DRAW_LEVEL or SHIELD_LAYER_DRAW_LEVEL
            ShowShieldLayerBar(layerBar, record.value, healthEffectiveMax, alpha, drawLevel, healthFrame.shield)
        end
    end

    for index = 1, #pool do
        local layerBar = pool[index]
        if not layerBar.shieldLayerInUse then
            if layerBar.animation then
                layerBar.animation:Stop()
            end
            layerBar:SetValue(0)
            layerBar:SetHidden(true)
        end
    end

    if healthFrame.shield.animation then
        healthFrame.shield.animation:Stop()
    end
    healthFrame.shield:SetHidden(true)
    if healthFrame.shieldbackdrop then
        healthFrame.shieldbackdrop:SetHidden(not (shieldValue > 0))
    end
    PlayerDamageShieldLayers.ApplyOverlayDrawLevels(healthFrame, true)
    return true
end

function PlayerDamageShieldLayers.RefreshFromSavedHealth()
    local healthFrame = GetPlayerHealthEntry()
    if not healthFrame or not healthFrame.shield then
        return
    end
    local savedHealth = UnitFrames.savedHealth[PLAYER_UNIT_TAG]
    if not savedHealth then
        return
    end
    local healthEffectiveMax = GetPlayerHealthEffectiveMax()
    local shieldModule = UnitFrames.VisualizerModules.PowerShieldModule
    shieldModule:UpdateShieldBar(healthFrame, savedHealth[4], healthEffectiveMax)
    local healthValue = savedHealth[1]
    if DoesUnitExist(PLAYER_UNIT_TAG) then
        healthValue = GetUnitPower(PLAYER_UNIT_TAG, COMBAT_MECHANIC_FLAGS_HEALTH)
    end
    UnitFrames.UpdateAttribute(PLAYER_UNIT_TAG, COMBAT_MECHANIC_FLAGS_HEALTH, healthFrame, healthValue, healthEffectiveMax, false, false)
end

local function DropShieldRecordsMissingFromBuffs()
    local activeEffectSlots = {}
    local numBuffs = GetNumBuffs(PLAYER_UNIT_TAG)
    for buffIndex = 1, numBuffs do
        local _, _, _, buffSlot = GetUnitBuffInfo(PLAYER_UNIT_TAG, buffIndex)
        activeEffectSlots[buffSlot] = true
    end
    for index = #playerShieldRecords, 1, -1 do
        local effectSlot = playerShieldRecords[index].effectSlot
        if effectSlot ~= nil and not activeEffectSlots[effectSlot] then
            table.remove(playerShieldRecords, index)
        end
    end
end

--- @param heldGain LUIE_PlayerDamageShieldHeldGain
--- @return boolean
local function ClaimAwaitingShieldIdentity(heldGain)
    local awaitingIndex = nil
    local awaitingCount = 0
    for index = 1, #playerShieldRecords do
        local record = playerShieldRecords[index]
        if record.awaitingIdentity and record.effectSlot == nil then
            awaitingCount = awaitingCount + 1
            awaitingIndex = index
        end
    end
    if awaitingCount ~= 1 then
        return false
    end
    for index = 1, #playerShieldRecords do
        if playerShieldRecords[index].effectSlot == heldGain.effectSlot then
            return false
        end
    end

    local record = playerShieldRecords[awaitingIndex]
    if math.abs(heldGain.beginTime - record.beginTime) > IDENTITY_CLAIM_SECONDS then
        return false
    end
    record.effectSlot = heldGain.effectSlot
    record.abilityId = heldGain.abilityId
    record.beginTime = heldGain.beginTime
    record.awaitingIdentity = false
    return true
end

local function DecayHeldEffectGains()
    local writeIndex = 1
    for index = 1, #heldEffectGains do
        local heldGain = heldEffectGains[index]
        heldGain.reconcilesRemaining = heldGain.reconcilesRemaining - 1
        if heldGain.reconcilesRemaining > 0 then
            heldEffectGains[writeIndex] = heldGain
            writeIndex = writeIndex + 1
        end
    end
    for index = writeIndex, #heldEffectGains do
        heldEffectGains[index] = nil
    end
end

local function ClearHeldEffectGains()
    WipeArray(heldEffectGains)
end

--- @return number
local function ReadPlayerShieldSum()
    if pendingShieldSumIsSet then
        return pendingShieldSum
    end
    local savedHealth = UnitFrames.savedHealth[PLAYER_UNIT_TAG]
    if savedHealth then
        return savedHealth[4]
    end
    return 0
end

local function ReconcilePlayerShieldLedger()
    local shieldSum = ReadPlayerShieldSum()
    pendingShieldSumIsSet = false

    if pendingFullRefresh then
        pendingFullRefresh = false
        DropShieldRecordsMissingFromBuffs()
    end

    for index = 1, #heldFadedEffectSlots do
        RemoveShieldRecordsForEffectSlot(heldFadedEffectSlots[index])
    end
    WipeArray(heldFadedEffectSlots)

    local delta = shieldSum - SumShieldRecords()
    local freshEffectGains = {}
    local carriedEffectGains = {}
    for index = 1, #heldEffectGains do
        local heldGain = heldEffectGains[index]
        if heldGain.reconcilesRemaining == HELD_GAIN_RECONCILE_LIMIT then
            freshEffectGains[#freshEffectGains + 1] = heldGain
        else
            carriedEffectGains[#carriedEffectGains + 1] = heldGain
        end
    end

    local function BindShieldGain(heldGain)
        RemoveShieldRecordsForEffectSlot(heldGain.effectSlot)
        local refreshedDelta = shieldSum - SumShieldRecords()
        if refreshedDelta > SHIELD_VALUE_EPSILON then
            playerShieldRecords[#playerShieldRecords + 1] =
            {
                effectSlot = heldGain.effectSlot,
                abilityId = heldGain.abilityId,
                beginTime = heldGain.beginTime,
                value = refreshedDelta,
                awaitingIdentity = false,
            }
        end
        ClearHeldEffectGains()
    end

    if delta > SHIELD_VALUE_EPSILON and #freshEffectGains == 1 then
        BindShieldGain(freshEffectGains[1])
    elseif delta > SHIELD_VALUE_EPSILON and #freshEffectGains == 0 and #carriedEffectGains == 1 then
        BindShieldGain(carriedEffectGains[1])
    elseif delta > SHIELD_VALUE_EPSILON and (#freshEffectGains > 1 or #carriedEffectGains > 1) then
        local unmatchedGain = freshEffectGains[1] or carriedEffectGains[1]
        playerShieldRecords[#playerShieldRecords + 1] =
        {
            effectSlot = nil,
            abilityId = nil,
            beginTime = unmatchedGain.beginTime,
            value = delta,
            awaitingIdentity = false,
        }
        ClearHeldEffectGains()
    elseif #freshEffectGains == 1 and #carriedEffectGains == 0 then
        local claimedIdentity = ClaimAwaitingShieldIdentity(freshEffectGains[1])
        if math.abs(shieldSum - SumShieldRecords()) > SHIELD_VALUE_EPSILON then
            ScaleShieldRecordsToSum(shieldSum)
        end
        if claimedIdentity then
            ClearHeldEffectGains()
        else
            DecayHeldEffectGains()
        end
    else
        if math.abs(shieldSum - SumShieldRecords()) > SHIELD_VALUE_EPSILON then
            ScaleShieldRecordsToSum(shieldSum)
        end
        if #freshEffectGains == 0 then
            ClearHeldEffectGains()
        else
            DecayHeldEffectGains()
        end
    end

    PlayerDamageShieldLayers.RefreshFromSavedHealth()
end

local function ScheduleShieldLedgerReconcile()
    if reconcileRegistered then
        return
    end
    reconcileRegistered = true
    local scheduledGeneration = ledgerGeneration
    eventManager:RegisterForUpdate(RECONCILE_UPDATE_NAME, 0, function ()
        eventManager:UnregisterForUpdate(RECONCILE_UPDATE_NAME)
        reconcileRegistered = false
        if scheduledGeneration ~= ledgerGeneration then
            return
        end
        ReconcilePlayerShieldLedger()
    end)
end

--- @param effectSlot integer
--- @param abilityId integer
--- @param beginTime number
local function NoteHeldEffectGain(effectSlot, abilityId, beginTime)
    for index = 1, #heldEffectGains do
        local heldGain = heldEffectGains[index]
        if heldGain.effectSlot == effectSlot then
            heldGain.abilityId = abilityId
            heldGain.beginTime = beginTime
            heldGain.reconcilesRemaining = HELD_GAIN_RECONCILE_LIMIT
            return
        end
    end
    heldEffectGains[#heldEffectGains + 1] =
    {
        effectSlot = effectSlot,
        abilityId = abilityId,
        beginTime = beginTime,
        reconcilesRemaining = HELD_GAIN_RECONCILE_LIMIT,
    }
end

local function ClearPendingLedgerEvents()
    pendingShieldSumIsSet = false
    pendingFullRefresh = false
    WipeArray(heldFadedEffectSlots)
    ClearHeldEffectGains()
end

function PlayerDamageShieldLayers.BeginUnitChange()
    ledgerGeneration = ledgerGeneration + 1
    unitChangeInProgress = true
    ClearShieldRecords()
    ClearPendingLedgerEvents()
end

--- @param shieldSum number
function PlayerDamageShieldLayers.OnShieldSum(shieldSum)
    if unitChangeInProgress then
        unitChangeInProgress = false
        ClearShieldRecords()
        if shieldSum > SHIELD_VALUE_EPSILON then
            playerShieldRecords[1] =
            {
                effectSlot = nil,
                abilityId = nil,
                beginTime = GetFrameTimeSeconds(),
                value = shieldSum,
                awaitingIdentity = true,
            }
        end
        return
    end

    pendingShieldSum = shieldSum
    pendingShieldSumIsSet = true
    ScheduleShieldLedgerReconcile()
end

function PlayerDamageShieldLayers.ClearForUnitTag()
    ledgerGeneration = ledgerGeneration + 1
    unitChangeInProgress = false
    ClearShieldRecords()
    ClearPendingLedgerEvents()
    PlayerDamageShieldLayers.RefreshFromSavedHealth()
end

local function OnPlayerEffectChanged(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId)
    if changeType == EFFECT_RESULT_GAINED then
        NoteHeldEffectGain(effectSlot, abilityId, beginTime)
        ScheduleShieldLedgerReconcile()
    elseif changeType == EFFECT_RESULT_FADED then
        heldFadedEffectSlots[#heldFadedEffectSlots + 1] = effectSlot
        ScheduleShieldLedgerReconcile()
    elseif changeType == EFFECT_RESULT_FULL_REFRESH then
        pendingFullRefresh = true
        ScheduleShieldLedgerReconcile()
    end
end

local function OnDamageShieldVisibilitySettingChanged(eventId, settingType, settingId)
    if settingType ~= SETTING_TYPE_COMBAT or settingId ~= COMBAT_SETTING_DAMAGE_SHIELD_VISIBILITY then
        return
    end
    PlayerDamageShieldLayers.RefreshFromSavedHealth()
end

eventManager:RegisterForEvent(EFFECT_EVENT_NAME, EVENT_EFFECT_CHANGED, OnPlayerEffectChanged)
eventManager:AddFilterForEvent(EFFECT_EVENT_NAME, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, PLAYER_UNIT_TAG)
eventManager:RegisterForEvent(SETTING_EVENT_NAME, EVENT_INTERFACE_SETTING_CHANGED, OnDamageShieldVisibilitySettingChanged)
eventManager:AddFilterForEvent(SETTING_EVENT_NAME, EVENT_INTERFACE_SETTING_CHANGED, REGISTER_FILTER_SETTING_SYSTEM_TYPE, SETTING_TYPE_COMBAT)

return PlayerDamageShieldLayers
