-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
LUIE.CombatTextCombatHybridEventViewer = LUIE.CombatTextEventViewer:Subclass()
local CombatTextCombatHybridEventViewer = LUIE.CombatTextCombatHybridEventViewer

local CombatTextConstants = LuiData.Data.CombatTextConstants
local AbbreviateNumber = LUIE.AbbreviateNumber
local string_format = string.format
--- @diagnostic disable-next-line: duplicate-set-field
function CombatTextCombatHybridEventViewer:New(...)
    local obj = LUIE.CombatTextEventViewer:New(...)
    obj:RegisterCallback(CombatTextConstants.eventType.COMBAT, function (...)
        self:OnEvent(...)
    end)
    self.eventBuffer = {}
    self.activeControls = { [CombatTextConstants.combatType.OUTGOING] = {}, [CombatTextConstants.combatType.INCOMING] = {} }
    self.lastControl = {}
    return obj
end

function CombatTextCombatHybridEventViewer:OnEvent(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    local Settings = LUIE.CombatText.SV
    if Settings.animation.animationType ~= "hybrid" then
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

function CombatTextCombatHybridEventViewer:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    if not self.eventBuffer[eventKey] then
        return
    end
    local value = self.eventBuffer[eventKey].value
    local hits = self.eventBuffer[eventKey].hits
    self.eventBuffer[eventKey] = nil
    self:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, hits)
end

function CombatTextCombatHybridEventViewer:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, hits)
    local Settings = LUIE.CombatText.SV
    value = AbbreviateNumber(value, Settings.common.abbreviateNumbers)

    local control, controlPoolKey = self.poolManager:GetPoolObject(CombatTextConstants.poolType.CONTROL)

    local textFormat, fontSize, textColor = self:GetTextAttributes(powerType, damageType, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    if hits > 1 and Settings.toggles.showThrottleTrailer then
        value = string_format("%s (%d)", value, hits)
    end
    if (combatType == CombatTextConstants.combatType.INCOMING) and Settings.toggles.incomingDamageOverride and (isDamage or isDamageCritical) then
        textColor = Settings.colors.incomingDamageOverride
    end

    self:PrepareLabel(control.label, fontSize, textColor, self:FormatString(textFormat, { text = abilityName, value = value, powerType = powerType, damageType = damageType }))
    self:ControlLayout(control, abilityId, combatType, sourceName)

    -- Control setup
    local panel, point, relativePoint = LUIE_CombatText_Outgoing, TOP, BOTTOM
    if combatType == CombatTextConstants.combatType.INCOMING then
        panel = LUIE_CombatText_Incoming
        if Settings.animation.incoming.directionType == "down" then
            point, relativePoint = BOTTOM, TOP
        end
    else
        if Settings.animation.outgoing.directionType == "down" then
            point, relativePoint = BOTTOM, TOP
        end
    end

    local w, h = panel:GetDimensions()
    local radiusW, radiusH = w / 4, h / 4
    local offsetX, offsetY = 0, 0

    if isDamageCritical or isHealingCritical or isDotCritical or isHotCritical then
        offsetX = zo_random(-radiusW, radiusW)
    elseif isDot or isHot then
        offsetX = zo_random(-radiusW, radiusW)
    elseif isDamage or isHealing or isEnergize or isDrain or isDamageShield or isBlocked then
        offsetX = zo_random(-radiusW, radiusW)
    end

    if point == TOP then
        if self.lastControl[combatType] == nil then
            offsetY = -25
        else
            offsetY = zo_max(-25, select(6, self.lastControl[combatType]:GetAnchor(0)))
        end
        control:SetAnchor(point, panel, relativePoint, offsetX, offsetY)

        if offsetY < 75 and self:IsOverlapping(control, self.activeControls[combatType]) then
            control:ClearAnchors()
            offsetY = select(6, self.lastControl[combatType]:GetAnchor(0)) + (fontSize * 1.5)
            control:SetAnchor(point, panel, relativePoint, offsetX, offsetY)
        end
    else
        if self.lastControl[combatType] == nil then
            offsetY = 25
        else
            offsetY = zo_min(25, select(6, self.lastControl[combatType]:GetAnchor(0)))
        end
        control:SetAnchor(point, panel, relativePoint, offsetX, offsetY)

        if offsetY > -75 and self:IsOverlapping(control, self.activeControls[combatType]) then
            control:ClearAnchors()
            offsetY = select(6, self.lastControl[combatType]:GetAnchor(0)) - (fontSize * 1.5)
            control:SetAnchor(point, panel, relativePoint, offsetX, offsetY)
        end
    end

    self.activeControls[combatType][control:GetName()] = control
    self.lastControl[combatType] = control

    -- Animation setup
    local animationPoolType = CombatTextConstants.poolType.ANIMATION_SCROLL
    if isDamageCritical or isHealingCritical or isDotCritical or isHotCritical then
        animationPoolType = CombatTextConstants.poolType.ANIMATION_SCROLL_CRITICAL
    end

    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)

    local targetY = h + 250
    if point == TOP then
        targetY = -targetY
    end
    animation:GetStepByName("scroll"):SetDeltaOffsetY(targetY)

    animation:Apply(control)
    animation:Play()

    -- Add items back into pool after use
    LUIE_CallLater(function ()
        self.poolManager:ReleasePoolObject(CombatTextConstants.poolType.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activeControls[combatType][control:GetName()] = nil
        if self.lastControl[combatType] == control then
            self.lastControl[combatType] = nil
        end
    end, animation:GetDuration())
end
