-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
LUIE.CombatTextPointEventViewer = LUIE.CombatTextEventViewer:Subclass()
local CombatTextPointEventViewer = LUIE.CombatTextPointEventViewer

local poolTypes = LuiData.Data.CombatTextConstants.poolType
local eventType = LuiData.Data.CombatTextConstants.eventType
local pointTypes = LuiData.Data.CombatTextConstants.pointType
--- @diagnostic disable-next-line: duplicate-set-field
function CombatTextPointEventViewer:New(...)
    local obj = LUIE.CombatTextEventViewer:New(...)
    obj:RegisterCallback(eventType.POINT, function (...)
        self:OnEvent(...)
    end)
    self.locationOffset = 0 -- Simple way to avoid overlapping. When number of active notes is back to 0, the offset is also reset
    self.activePoints = 0
    return obj
end

function CombatTextPointEventViewer:OnEvent(pointType, value)
    local Settings = LUIE.CombatText.SV

    -- Label setup
    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)

    local size, color, text
    ---------------------------------------------------------------------------------------------------------------------------------------
    -- //POINTS//--
    ---------------------------------------------------------------------------------------------------------------------------------------
    if pointType == pointTypes.ALLIANCE_POINTS then
        color = Settings.colors.pointsAlliance
        size = Settings.fontSizes.point
        text = self:FormatString(Settings.formats.pointsAlliance, { value = value, text = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_ALLIANCE) })
    elseif pointType == pointTypes.EXPERIENCE_POINTS then
        color = Settings.colors.pointsExperience
        size = Settings.fontSizes.point
        text = self:FormatString(Settings.formats.pointsExperience, { value = value, text = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_EXPERIENCE) })
    elseif pointType == pointTypes.CHAMPION_POINTS then
        color = Settings.colors.pointsChampion
        size = Settings.fontSizes.point
        text = self:FormatString(Settings.formats.pointsChampion, { value = value, text = GetString(LUIE_STRING_LAM_CT_SHARED_POINTS_CHAMPION) })
        ---------------------------------------------------------------------------------------------------------------------------------------
        -- //COMBAT STATE//--
        ---------------------------------------------------------------------------------------------------------------------------------------
    elseif pointType == pointTypes.IN_COMBAT then
        color = Settings.colors.inCombat
        size = Settings.fontSizes.combatState
        text = self:FormatString(Settings.formats.inCombat, { value = value, text = GetString(LUIE_STRING_CT_COMBAT_IN_DEFAULT) })
    elseif pointType == pointTypes.OUT_COMBAT then
        color = Settings.colors.outCombat
        size = Settings.fontSizes.combatState
        text = self:FormatString(Settings.formats.outCombat, { value = value, text = GetString(LUIE_STRING_CT_COMBAT_OUT_DEFAULT) })
    end

    self:PrepareLabel(control.label, size, color, text)
    self:ControlLayout(control)

    -- Control setup
    control:SetAnchor(CENTER, LUIE_CombatText_Point, TOP, 0, self.locationOffset * (Settings.fontSizes.point + 5))
    self.locationOffset = self.locationOffset + 1
    self.activePoints = self.activePoints + 1

    -- Get animation
    local animationPoolType
    if pointType == pointTypes.IN_COMBAT or pointType == pointTypes.OUT_COMBAT then
        animationPoolType = poolTypes.ANIMATION_COMBATSTATE
    else
        animationPoolType = poolTypes.ANIMATION_POINT
    end
    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)
    animation:Apply(control)
    animation:Play()

    -- Add items back into pool after animation
    LUIE_CallLater(function ()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activePoints = self.activePoints - 1
        if self.activePoints == 0 then
            self.locationOffset = 0
        end
    end, animation:GetDuration())
end
