-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextCombatEllipseEventViewer : LuiExtended.CombatTextEventViewer
local CombatTextCombatEllipseEventViewer = LUIE.CombatTextEventViewer:Subclass()

--- @class (partial) LuiExtended.CombatTextCombatEllipseEventViewer
LUIE.CombatTextCombatEllipseEventViewer = CombatTextCombatEllipseEventViewer

local CombatTextConstants = LuiData.Data.CombatTextConstants
local AbbreviateNumber = LUIE.AbbreviateNumber
local string_format = string.format
function CombatTextCombatEllipseEventViewer:Initialize(poolManager, eventListener)
    LUIE.CombatTextEventViewer.Initialize(self, poolManager, eventListener)
    self:RegisterCallback(CombatTextConstants.eventType.COMBAT, function (...) self:OnEvent(...) end)
    self.eventBuffer = {}
    self.activeControls = { [CombatTextConstants.combatType.OUTGOING] = {}, [CombatTextConstants.combatType.INCOMING] = {} }
    self.lastControl = {}
end

function CombatTextCombatEllipseEventViewer:OnEvent(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    local Settings = LUIE.CombatText.SV
    if Settings.animation.animationType ~= "ellipse" then
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

function CombatTextCombatEllipseEventViewer:ViewFromEventBuffer(combatType, powerType, eventKey, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted)
    if not self.eventBuffer[eventKey] then
        return
    end
    local value = self.eventBuffer[eventKey].value
    local hits = self.eventBuffer[eventKey].hits
    self.eventBuffer[eventKey] = nil
    self:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, hits)
end

function CombatTextCombatEllipseEventViewer:View(combatType, powerType, value, abilityName, abilityId, damageType, sourceName, isDamage, isDamageCritical, isHealing, isHealingCritical, isEnergize, isDrain, isDot, isDotCritical, isHot, isHotCritical, isMiss, isImmune, isParried, isReflected, isDamageShield, isDodged, isBlocked, isInterrupted, hits)
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
    local point = BOTTOMRIGHT
    local relativePoint = TOPRIGHT
    if combatType == CombatTextConstants.combatType.INCOMING then
        panel = LUIE_CombatText_Incoming
        if Settings.animation.incoming.directionType == "up" then
            point, relativePoint = TOPRIGHT, BOTTOMRIGHT
        end
    else
        panel = LUIE_CombatText_Outgoing
        if Settings.animation.outgoing.directionType == "up" then
            point, relativePoint = TOPRIGHT, BOTTOMRIGHT
        end
    end

    local offsetX, targetX = 0, -1
    local offsetY, targetY = 0, 1

    if isDot or isHot or isEnergize or isDrain or isMiss or isImmune or isParried or isReflected or isDamageShield or isDodged or isBlocked or isInterrupted then
        offsetY, targetY, targetX = 0.2, 0.8, -0.8
    end

    if point == TOPRIGHT or point == TOPLEFT then
        offsetY, targetY = -offsetY, -targetY
    end

    --- Anchor points: -----------------------------
    --  3 .. 1 .. 9
    --  .    .    .
    --  2 ..128.. 8
    --  .    .    .
    --  6 .. 4 .. 12
    --
    --  TOP + LEFT     = TOPLEFT     (1 + 2 = 3)
    --  TOP + RIGHT    = TOPRIGHT    (1 + 8 = 9)
    --  BOTTOM + LEFT  = BOTTOMLEFT  (4 + 2 = 6)
    --  BOTTOM + RIGHT = BOTTOMRIGHT (4 + 8 = 12)
    -------------------------------------------------

    if (panel:GetCenter()) > GuiRoot:GetWidth() / 2 then
        point, relativePoint = point - RIGHT + LEFT, relativePoint - RIGHT + LEFT
        targetX = -targetX
    end

    local w, h = panel:GetDimensions()
    control:SetAnchor(point, panel, relativePoint, offsetX * w, offsetY * h)

    if point == TOPRIGHT or point == TOPLEFT then
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

    -- Animation Setup
    local animationXPoolType, animationYPoolType
    if isDamageCritical or isHealingCritical or isDotCritical or isHotCritical then
        animationXPoolType = CombatTextConstants.poolType.ANIMATION_ELLIPSE_X_CRIT
        animationYPoolType = CombatTextConstants.poolType.ANIMATION_ELLIPSE_Y_CRIT
    else
        animationXPoolType = CombatTextConstants.poolType.ANIMATION_ELLIPSE_X
        animationYPoolType = CombatTextConstants.poolType.ANIMATION_ELLIPSE_Y
    end

    local animationX, animationXPoolKey = self.poolManager:GetPoolObject(animationXPoolType)
    animationX:GetStepByName("scrollX"):SetDeltaOffsetX(targetX * (w * 0.35))
    animationX:Apply(control.iconHost or control.icon)
    animationX:Play()

    local animationY, animationYPoolKey = self.poolManager:GetPoolObject(animationYPoolType)
    local verticalOffset = (targetY * h + 550)
    if point == TOPRIGHT or point == TOPLEFT then
        verticalOffset = -verticalOffset
    end
    animationY:GetStepByName("scrollY"):SetDeltaOffsetY(verticalOffset)
    animationY:Apply(control)
    animationY:SetStopHandler(function ()
        self.poolManager:ReleasePoolObject(CombatTextConstants.poolType.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationXPoolType, animationXPoolKey)
        self.poolManager:ReleasePoolObject(animationYPoolType, animationYPoolKey)
        self.activeControls[combatType][control:GetName()] = nil
        if self.lastControl[combatType] == control then
            self.lastControl[combatType] = nil
        end
    end)
    animationY:Play()
end
