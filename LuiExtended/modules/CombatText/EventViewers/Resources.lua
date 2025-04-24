-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
LUIE.CombatTextResourceEventViewer = LUIE.CombatTextEventViewer:Subclass()
local CombatTextResourceEventViewer = LUIE.CombatTextResourceEventViewer
local poolTypes = LuiData.Data.CombatTextConstants.poolType
local eventType = LuiData.Data.CombatTextConstants.eventType
local resourceTypes = LuiData.Data.CombatTextConstants.resourceType
--- @diagnostic disable-next-line: duplicate-set-field
function CombatTextResourceEventViewer:New(...)
    local obj = LUIE.CombatTextEventViewer:New(...)
    obj:RegisterCallback(eventType.RESOURCE, function (...)
        self:OnEvent(...)
    end)
    self.locationOffset = 0 -- Simple way to avoid overlapping. When the number of active notes is back to 0, the offset is also reset
    self.activeResources = 0
    return obj
end

function CombatTextResourceEventViewer:OnEvent(resourceType, value)
    local Settings = LUIE.CombatText.SV
    local control, controlPoolKey = self.poolManager:GetPoolObject(poolTypes.CONTROL)
    local size, color, text

    if resourceType == resourceTypes.LOW_HEALTH then
        color = Settings.colors.lowHealth
        size = Settings.fontSizes.resource
        text = self:FormatString(Settings.formats.resourceHealth, { value = value, text = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_HEALTH) })
    elseif resourceType == resourceTypes.LOW_MAGICKA then
        color = Settings.colors.lowMagicka
        size = Settings.fontSizes.resource
        text = self:FormatString(Settings.formats.resourceMagicka, { value = value, text = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_MAGICKA) })
    elseif resourceType == resourceTypes.LOW_STAMINA then
        color = Settings.colors.lowStamina
        size = Settings.fontSizes.resource
        text = self:FormatString(Settings.formats.resourceStamina, { value = value, text = GetString(LUIE_STRING_LAM_CT_SHARED_LOW_STAMINA) })
    elseif resourceType == resourceTypes.ULTIMATE then
        color = Settings.colors.ultimateReady
        size = Settings.fontSizes.readylabel
        text = self:FormatString(Settings.formats.ultimateReady, { text = GetString(LUIE_STRING_LAM_CT_SHARED_ULTIMATE_READY) })
    elseif resourceType == resourceTypes.POTION then
        color = Settings.colors.potionReady
        size = Settings.fontSizes.readylabel
        text = self:FormatString(Settings.formats.potionReady, { text = GetString(LUIE_STRING_LAM_CT_SHARED_POTION_READY) })
    end

    self:PrepareLabel(control.label, size, color, text)
    self:ControlLayout(control)

    control:SetAnchor(CENTER, LUIE_CombatText_Resource, TOP, 0, self.locationOffset * (Settings.fontSizes.resource + 5))
    self.locationOffset = (self.locationOffset + 1) % 4
    self.activeResources = self.activeResources + 1

    local animationPoolType = poolTypes.ANIMATION_RESOURCE
    if resourceType == resourceTypes.LOW_HEALTH or resourceType == resourceTypes.LOW_MAGICKA or resourceType == resourceTypes.LOW_STAMINA then
        animationPoolType = poolTypes.ANIMATION_RESOURCE
    end

    local animation, animationPoolKey = self.poolManager:GetPoolObject(animationPoolType)
    animation:Apply(control)
    animation:Play()

    if Settings.toggles.warningSound and (resourceType == resourceTypes.LOW_HEALTH or resourceType == resourceTypes.LOW_STAMINA or resourceType == resourceTypes.LOW_MAGICKA) then
        PlaySound("Quest_StepFailed")
    end

    LUIE_CallLater(function ()
        self.poolManager:ReleasePoolObject(poolTypes.CONTROL, controlPoolKey)
        self.poolManager:ReleasePoolObject(animationPoolType, animationPoolKey)
        self.activeResources = self.activeResources - 1
        if self.activeResources == 0 then
            self.locationOffset = 0
        end
    end, animation:GetDuration())
end
