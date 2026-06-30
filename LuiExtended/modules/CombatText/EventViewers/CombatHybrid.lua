-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextCombatHybridEventViewer : LuiExtended.CombatTextEventViewer
local CombatTextCombatHybridEventViewer = LUIE.CombatTextEventViewer:Subclass()
--- @class (partial) LuiExtended.CombatTextCombatHybridEventViewer
LUIE.CombatTextCombatHybridEventViewer = CombatTextCombatHybridEventViewer

local CombatTextConstants = LuiData.Data.CombatTextConstants
local AbbreviateNumber = LUIE.AbbreviateNumber
local string_format = string.format
function CombatTextCombatHybridEventViewer:Initialize(poolManager, eventListener)
    LUIE.CombatTextEventViewer.Initialize(self, poolManager, eventListener)
    self:RegisterCallback(CombatTextConstants.eventType.COMBAT, function (...) self:OnEvent(...) end)
    self.eventBuffer = {}
    self.activeControls = { [CombatTextConstants.combatType.OUTGOING] = {}, [CombatTextConstants.combatType.INCOMING] = {} }
    self.lastControl = {}
end

function CombatTextCombatHybridEventViewer:OnEvent(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    local Settings = LUIE.CombatText.SV
    if Settings.animation.animationType ~= "hybrid" then
        return
    end

    if (isDamageCritical or isHealingCritical or isDotCritical or isHotCritical) and not Settings.toggles.throttleCriticals then
        self:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, 1)
    else
        -- Memory optimization: lightweight key instead of 24-part concatenation
        local flags = LUIE.GetCachedTable()
        flags.isDamage = isDamage
        flags.isDamageCritical = isDamageCritical
        flags.isDot = isDot
        flags.isDotCritical = isDotCritical
        flags.isHealing = isHealing
        flags.isHealingCritical = isHealingCritical
        flags.isHot = isHot
        flags.isHotCritical = isHotCritical
        local throttleTime = self:GetThrottleTime(Settings, flags)
        LUIE.RecycleTable(flags)

        if throttleTime <= 0 then
            self:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, 1)
        else
            local eventKey = abilityId .. "_" .. combatType .. "_" .. damageType .. "_" .. (isDamage and "1" or isDamageCritical and "2" or isHealing and "3" or isHealingCritical and "4" or isDot and "5" or isDotCritical and "6" or isHot and "7" or isHotCritical and "8" or isMiss and "9" or isImmune and "10" or isParried and "11" or isReflected and "12" or isDamageShield and "13" or isDodged and "14" or isBlocked and "15" or isInterrupted and "16" or isEnergize and "17" or isDrain and "18" or "0")
            if self.eventBuffer[eventKey] == nil then
                self.eventBuffer[eventKey] = { value = value, hits = 1 }
                zo_callLater(function ()
                                 self:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
                             end, throttleTime)
            else
                self.eventBuffer[eventKey].value = self.eventBuffer[eventKey].value + value
                self.eventBuffer[eventKey].hits = self.eventBuffer[eventKey].hits + 1
            end
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

    -- Use cached table instead of allocating new one
    local flags = LUIE.GetCachedTable()
    flags.isDamage = isDamage
    flags.isDamageCritical = isDamageCritical
    flags.isDot = isDot
    flags.isDotCritical = isDotCritical
    flags.isHealing = isHealing
    flags.isHealingCritical = isHealingCritical
    flags.isHot = isHot
    flags.isHotCritical = isHotCritical
    flags.isEnergize = isEnergize
    flags.isDrain = isDrain
    flags.isMiss = isMiss
    flags.isImmune = isImmune
    flags.isParried = isParried
    flags.isReflected = isReflected
    flags.isDamageShield = isDamageShield
    flags.isDodged = isDodged
    flags.isBlocked = isBlocked
    flags.isInterrupted = isInterrupted
    local textFormat, fontSize, textColor = self:GetTextAttributes(powerType, damageType, flags)
    LUIE.RecycleTable(flags) -- Return to cache immediately after use
    if hits > 1 and Settings.toggles.showThrottleTrailer then
        value = string_format("%s (%d)", value, hits)
    end
    if (combatType == CombatTextConstants.combatType.INCOMING) and Settings.toggles.incomingDamageOverride and (isDamage or isDamageCritical) then
        textColor = Settings.colors.incomingDamageOverride
    end

    self:PrepareLabel(control.label, fontSize, textColor, self:FormatString(textFormat, { text = abilityName, value = value, powerType = powerType, damageType = damageType }))
    self:ControlLayout(control, abilityId, combatType, sourceName, textColor)

    -- Control setup
    local panel
    local point = TOP
    local relativePoint = BOTTOM
    if combatType == CombatTextConstants.combatType.INCOMING then
        panel = LUIE_CombatText_Incoming
        if Settings.animation.incoming.directionType == "down" then
            point, relativePoint = BOTTOM, TOP
        end
    else
        panel = LUIE_CombatText_Outgoing
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
    animation:SetStopHandler(function ()
        self.poolManager:ReleasePoolObject(CombatTextConstants.poolType.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activeControls[combatType][control:GetName()] = nil
        if self.lastControl[combatType] == control then
            self.lastControl[combatType] = nil
        end
    end)
    animation:Play()
end
