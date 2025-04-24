-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class CombatTextCombatCloudEventViewer : CombatTextEventViewer, ZO_InitializingObject
local CombatTextCombatCloudEventViewer = LUIE.CombatTextEventViewer:Subclass()
LUIE.CombatTextCombatCloudEventViewer = CombatTextCombatCloudEventViewer

local CombatTextConstants = LuiData.Data.CombatTextConstants
local AbbreviateNumber = LUIE.AbbreviateNumber
local string_format = string.format

function CombatTextCombatCloudEventViewer:New(...)
    local obj = LUIE.CombatTextEventViewer:New(...) --[[@as CombatTextEventViewer]]
    obj:RegisterCallback(CombatTextConstants.eventType.COMBAT, function (...)
        self:OnEvent(...)
    end)
    self.eventBuffer = {}
    return obj
end

function CombatTextCombatCloudEventViewer:OnEvent(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    local Settings = LUIE.CombatText.SV
    if Settings.animation.animationType ~= "cloud" then
        return
    end

    if (isDamageCritical or isHealingCritical or isDotCritical or isHotCritical) and not Settings.toggles.throttleCriticals then
        self:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, 1)
    else
        local eventKey = string_format("%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s", combatType, powerType, abilityName, abilityId, damageType, sourceName, tostring(isDamage), tostring(isDamageCritical), tostring(isHealing), tostring(isHealingCritical), tostring(isEnergize), tostring(isDrain), tostring(isDot), tostring(isDotCritical), tostring(isHot), tostring(isHotCritical), tostring(isMiss), tostring(isImmune), tostring(isParried), tostring(isReflected), tostring(isDamageShield), tostring(isDodged), tostring(isBlocked), tostring(isInterrupted))
        if self.eventBuffer[eventKey] == nil then
            self.eventBuffer[eventKey] = { value = value, hits = 1 }
            local throttleTime = 0
            if isDamage then
                throttleTime = Settings.throttles.damage
            elseif isDamageCritical then
                throttleTime = Settings.throttles.damagecritical
            elseif isDot then
                throttleTime = Settings.throttles.dot
            elseif isDotCritical then
                throttleTime = Settings.throttles.dotcritical
            elseif isHealing then
                throttleTime = Settings.throttles.healing
            elseif isHealingCritical then
                throttleTime = Settings.throttles.healingcritical
            elseif isHot then
                throttleTime = Settings.throttles.hot
            elseif isHotCritical then
                throttleTime = Settings.throttles.hotcritical
            end
            LUIE_CallLater(function ()
                self:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
            end, throttleTime)
        else
            self.eventBuffer[eventKey].value = self.eventBuffer[eventKey].value + value
            self.eventBuffer[eventKey].hits = self.eventBuffer[eventKey].hits + 1
        end
    end
end

function CombatTextCombatCloudEventViewer:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    if not self.eventBuffer[eventKey] then
        return
    end
    local value = self.eventBuffer[eventKey].value
    local hits = self.eventBuffer[eventKey].hits
    self.eventBuffer[eventKey] = nil
    self:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, hits)
end

function CombatTextCombatCloudEventViewer:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, hits)
    local Settings = LUIE.CombatText.SV
    value = AbbreviateNumber(value, Settings.common.abbreviateNumbers)

    -- Control setup
    local panel = LUIE_CombatText_Outgoing
    if combatType == CombatTextConstants.combatType.INCOMING then
        panel = LUIE_CombatText_Incoming
    end
    local w, h = panel:GetDimensions()
    local radiusW, radiusH = w / 2, h * 2
    local offsetX, offsetY = nil, nil

    if isDamageCritical or isHealingCritical or isDotCritical or isHotCritical then
        offsetX, offsetY = zo_random(-radiusW * 0.5, radiusW * 0.5), zo_random(-radiusH * 0.5, radiusH * 0.5)
    elseif isDot or isHot then                               -- http://www.mathopenref.com/coordgeneralellipse.html
        offsetX = zo_random(-radiusW * 0.95, radiusW * 0.95) -- Make radiusW a bit smaller to avoid horizontal animations
        offsetY = zo_sqrt(radiusH ^ 2 * (1 - (offsetX ^ 2 / radiusW ^ 2)))
        if combatType == CombatTextConstants.combatType.OUTGOING then
            offsetY = -offsetY
        end
    elseif isDamage or isHealing or isEnergize or isDrain or isDamageShield or isBlocked then
        offsetX, offsetY = zo_random(-radiusW, radiusW), zo_random(-radiusH * 0.5, radiusH)
    end

    local control, controlPoolKey = self.poolManager:GetPoolObject(CombatTextConstants.poolType.CONTROL)

    if isDot or isHot then
        control:SetAnchor(CENTER, panel, CENTER, 0, 0) -- Offsets are set in animation, not here
    else
        control:SetAnchor(CENTER, panel, CENTER, offsetX, offsetY)
    end

    -- Label setup in the correct order that the game handles damage
    local textFormat, fontSize, textColor = self:GetTextAttributes(powerType, damageType, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    if hits > 1 and Settings.toggles.showThrottleTrailer then
        value = string_format("%s (%d)", value, hits)
    end
    if (combatType == CombatTextConstants.combatType.INCOMING) and Settings.toggles.incomingDamageOverride and (isDamage or isDamageCritical) then
        textColor = Settings.colors.incomingDamageOverride
    end

    self:PrepareLabel(control.label, fontSize, textColor, self:FormatString(textFormat, { text = abilityName, value = value, powerType = powerType, damageType = damageType }))
    self:ControlLayout(control, abilityId, combatType, sourceName)

    -- Animation setup
    local animationPoolType = CombatTextConstants.poolType.ANIMATION_CLOUD
    if isDamageCritical or isHealingCritical or isDotCritical or isHotCritical then
        animationPoolType = CombatTextConstants.poolType.ANIMATION_CLOUD_CRITICAL
    elseif isDot or isHot then
        animationPoolType = CombatTextConstants.poolType.ANIMATION_CLOUD_FIREWORKS
    end
    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)

    if animationPoolType == CombatTextConstants.poolType.ANIMATION_CLOUD_FIREWORKS then
        local moveStep = animation:GetStepByName("move")
        moveStep:SetDeltaOffsetX(offsetX)
        moveStep:SetDeltaOffsetY(offsetY)
    end

    animation:Apply(control)
    animation:Play()

    -- Add items back into pool after use
    LUIE_CallLater(function ()
        self.poolManager:ReleasePoolObject(CombatTextConstants.poolType.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
    end, animation:GetDuration())
end
