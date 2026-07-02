-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextCombatCloudEventViewer : LuiExtended.CombatTextEventViewer
local CombatTextCombatCloudEventViewer = LUIE.CombatTextEventViewer:Subclass()

--- @class (partial) LuiExtended.CombatTextCombatCloudEventViewer
LUIE.CombatTextCombatCloudEventViewer = CombatTextCombatCloudEventViewer

local CombatTextConstants = LuiData.Data.CombatTextConstants
local AbbreviateNumber = LUIE.AbbreviateNumber
local string_format = string.format

function CombatTextCombatCloudEventViewer:Initialize(poolManager, eventListener)
    LUIE.CombatTextEventViewer.Initialize(self, poolManager, eventListener)
    self:RegisterCallback(CombatTextConstants.eventType.COMBAT, function (...) self:OnEvent(...) end)
    self.eventBuffer = {}
end

function CombatTextCombatCloudEventViewer:OnEvent(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    local Settings = LUIE.CombatText.SV
    if Settings.animation.animationType ~= "cloud" then
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
    local panel
    if combatType == CombatTextConstants.combatType.INCOMING then
        panel = LUIE_CombatText_Incoming
    else
        panel = LUIE_CombatText_Outgoing
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
    animation:SetStopHandler(function ()
        self.poolManager:ReleasePoolObject(CombatTextConstants.poolType.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
    end)
    animation:Play()
end
