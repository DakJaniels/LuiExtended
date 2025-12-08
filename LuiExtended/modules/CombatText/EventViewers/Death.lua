-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextDeathViewer : LuiExtended.CombatTextEventViewer
local CombatTextDeathViewer = LUIE.CombatTextEventViewer:Subclass()
--- @class (partial) LuiExtended.CombatTextDeathViewer
LUIE.CombatTextDeathViewer = CombatTextDeathViewer

local poolTypes = LuiData.Data.CombatTextConstants.poolType
local eventType = LuiData.Data.CombatTextConstants.eventType

local zo_strformat = zo_strformat

function CombatTextDeathViewer:Initialize(poolManager)
    LUIE.CombatTextEventViewer.Initialize(self, poolManager)
    self:RegisterCallback(eventType.DEATH, function (...) self:OnEvent(...) end)
    self.locationOffset = 0 -- Simple way to avoid overlapping. When number of active notes is back to 0, the offset is also reset
    self.activePoints = 0
end

function CombatTextDeathViewer:OnEvent(unitTag)
    local Settings = LUIE.CombatText.SV

    local name
    if Settings.toggles.useAccountNameForDeath then
        name = zo_strformat("<<1>>", GetUnitDisplayName(unitTag)) or ""
    else
        name = zo_strformat("<<1>>", GetUnitName(unitTag))
    end

    -- Label setup
    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)

    local size, color, text
    ---------------------------------------------------------------------------------------------------------------------------------------
    --- - POINTS
    ---------------------------------------------------------------------------------------------------------------------------------------
    color = Settings.colors.death
    size = Settings.fontSizes.death
    text = self:FormatString(Settings.formats.death, { text = name, value = name })

    self:PrepareLabel(control.label, size, color, text)
    self:ControlLayout(control)

    -- Control setup
    control:SetAnchor(CENTER, LUIE_CombatText_Point, TOP, 0, self.locationOffset * (Settings.fontSizes.death + 5))
    self.locationOffset = self.locationOffset + 1
    self.activePoints = self.activePoints + 1

    -- Get animation
    local animationPoolType = poolTypes.ANIMATION_DEATH
    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)

    local panel = LUIE_CombatText_Point
    local _, h = panel:GetDimensions()
    local targetY = h + 100
    animation:GetStepByName("scroll"):SetDeltaOffsetY(targetY)

    animation:Apply(control)
    animation:Play()

    local function animationCallback()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activePoints = self.activePoints - 1
        if self.activePoints == 0 or self.activePoints >= 5 then
            self.locationOffset = 0
        end
    end
    -- Add items back into pool after animation
    LUIE_callLater(animationCallback, animation:GetDuration())
end
