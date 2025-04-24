-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
LUIE.CombatTextCrowdControlEventViewer = LUIE.CombatTextEventViewer:Subclass()
local CombatTextCrowdControlEventViewer = LUIE.CombatTextCrowdControlEventViewer

local poolTypes = LuiData.Data.CombatTextConstants.poolType
local eventType = LuiData.Data.CombatTextConstants.eventType
local combatType = LuiData.Data.CombatTextConstants.combatType
local crowdControlTypes = LuiData.Data.CombatTextConstants.crowdControlType
--- @diagnostic disable-next-line: duplicate-set-field
function CombatTextCrowdControlEventViewer:New(...)
    local obj = LUIE.CombatTextEventViewer:New(...)
    obj:RegisterCallback(eventType.CROWDCONTROL, function (...)
        self:OnEvent(...)
    end)
    self.locationOffset = { [combatType.OUTGOING] = 0, [combatType.INCOMING] = 0 }
    self.activeCrowdControls = { [combatType.OUTGOING] = 0, [combatType.INCOMING] = 0 }
    return obj
end

function CombatTextCrowdControlEventViewer:OnEvent(crowdControlType, eventCombatType)
    local combatTypeConstant = LuiData.Data.CombatTextConstants.combatType
    local Settings = LUIE.CombatText.SV
    -- Label setup
    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)
    local size, color, text

    -- Disoriented
    if crowdControlType == crowdControlTypes.DISORIENTED then
        color = Settings.colors.disoriented
        size = Settings.fontSizes.crowdControl
        text = self:FormatString(Settings.formats.disoriented, { text = GetString(LUIE_STRING_LAM_CT_SHARED_DISORIENTED) })

        -- Feared
    elseif crowdControlType == crowdControlTypes.FEARED then
        color = Settings.colors.feared
        size = Settings.fontSizes.crowdControl
        text = self:FormatString(Settings.formats.feared, { text = GetString(LUIE_STRING_LAM_CT_SHARED_FEARED) })

        -- Off Balanced
    elseif crowdControlType == crowdControlTypes.OFFBALANCED then
        color = Settings.colors.offBalanced
        size = Settings.fontSizes.crowdControl
        text = self:FormatString(Settings.formats.offBalanced, { text = GetString(LUIE_STRING_LAM_CT_SHARED_OFF_BALANCE) })

        -- Silenced
    elseif crowdControlType == crowdControlTypes.SILENCED then
        color = Settings.colors.silenced
        size = Settings.fontSizes.crowdControl
        text = self:FormatString(Settings.formats.silenced, { text = GetString(LUIE_STRING_LAM_CT_SHARED_SILENCED) })

        -- Stunned
    elseif crowdControlType == crowdControlTypes.STUNNED then
        color = Settings.colors.stunned
        size = Settings.fontSizes.crowdControl
        text = self:FormatString(Settings.formats.stunned, { text = GetString(LUIE_STRING_LAM_CT_SHARED_STUNNED) })

        -- Charmed
    elseif crowdControlType == crowdControlTypes.CHARMED then
        color = Settings.colors.charmed
        size = Settings.fontSizes.crowdControl
        text = self:FormatString(Settings.formats.charmed, { text = GetString(LUIE_STRING_LAM_CT_SHARED_CHARMED) })
    end

    self:PrepareLabel(control.label, size, color, text)
    self:ControlLayout(control)

    -- Control setup
    local panel, point, relativePoint = LUIE_CombatText_Outgoing, TOP, BOTTOM

    if eventCombatType == combatTypeConstant.INCOMING then
        panel = LUIE_CombatText_Incoming

        if Settings.animation.incoming.directionType == "down" then
            point, relativePoint = BOTTOM, TOP
        end
    else
        if Settings.animation.outgoing.directionType == "down" then
            point, relativePoint = BOTTOM, TOP
        end
    end

    if point == TOP then
        control:SetAnchor(point, panel, relativePoint, 0, -(self.locationOffset[eventCombatType] * (Settings.fontSizes.crowdControl + 5)))
    else
        control:SetAnchor(point, panel, relativePoint, 0, self.locationOffset[eventCombatType] * (Settings.fontSizes.crowdControl + 5))
    end

    self.locationOffset[eventCombatType] = self.locationOffset[eventCombatType] + 1
    self.activeCrowdControls[eventCombatType] = self.activeCrowdControls[eventCombatType] + 1

    -- Get animation
    local animationPoolType = poolTypes.ANIMATION_SCROLL_CRITICAL
    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)
    animation:Apply(control)
    animation:Play()

    -- Add items back into pool after animation
    LUIE_CallLater(function ()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activeCrowdControls[eventCombatType] = self.activeCrowdControls[eventCombatType] - 1

        if self.activeCrowdControls[eventCombatType] == 0 then
            self.locationOffset[eventCombatType] = 0
        end
    end, animation:GetDuration())
end
