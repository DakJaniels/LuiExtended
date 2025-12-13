-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextPool : ZO_ObjectPool
local CombatTextPool = ZO_ObjectPool:Subclass()

--- @class (partial) LuiExtended.CombatTextPool
--- @field poolType LUIE_CombatText_POOL_TYPE
LUIE.CombatTextPool = CombatTextPool

local poolTypes = LuiData.Data.CombatTextConstants.poolType

local fastSlow = ZO_GenerateCubicBezierEase(0.3, 0.9, 0.7, 1)
local slowFast = ZO_GenerateCubicBezierEase(0.63, 0.1, 0.83, 0.69)
local even = ZO_GenerateCubicBezierEase(0.63, 1.2, 0.83, 1)

local easeOutIn = function (progress)
    return ZO_EaseInOutQuadratic(progress)
end

function CombatTextPool:Initialize(poolType)
    assert(poolType, "poolType is required.")

    self.poolType = poolType

    local function CreateControl(pool)
        local control = CreateControlFromVirtual("LUIE_CombatText_Virtual_Instance", LUIE_CombatText, "LUIE_CombatText_Virtual", pool:GetNextControlId())
        control.label = control:GetNamedChild("_Amount")
        control.icon = control:GetNamedChild("_Icon")
        return control
    end

    local function ResetControl(control)
        control:ClearAnchors()
        control.label:ClearAnchors()
        control.icon:ClearAnchors()
        control.icon:SetHidden(true)
    end

    local function DestroyControl(control)
        control:SetHidden(true)
        control:SetParent(nil)
        control:ClearAnchors()
        if control.label then
            control.label:ClearAnchors()
        end
        if control.icon then
            control.icon:ClearAnchors()
        end
    end

    local function CreateAnimation(pool)
        local anim = LUIE.CombatTextAnimation:New()
        local Settings = LUIE.CombatText.SV
        local animationSpeed = 1 / (Settings.animation.animationDuration / 100)

        if (poolType == poolTypes.ANIMATION_CLOUD) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 1500, slowFast)
        elseif (poolType == poolTypes.ANIMATION_CLOUD_CRITICAL) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
            anim:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 1500, slowFast)
        elseif (poolType == poolTypes.ANIMATION_CLOUD_FIREWORKS) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Move("move", 0, 0, animationSpeed * 250, 0, fastSlow)
            anim:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1500, slowFast)
        elseif (poolType == poolTypes.ANIMATION_SCROLL) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Move("scroll", 0, 0, animationSpeed * 2500, 0, even)
            anim:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1400, slowFast)
        elseif (poolType == poolTypes.ANIMATION_SCROLL_CRITICAL) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
            anim:Move("scroll", 0, 0, animationSpeed * 2500, 0, even)
            anim:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1400, slowFast)
        elseif (poolType == poolTypes.ANIMATION_DEATH) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
            anim:Move("scroll", 0, 0, animationSpeed * 5000, 0, even)
            anim:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 2000, slowFast)
        elseif (poolType == poolTypes.ANIMATION_ALERT) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Scale(nil, 0.5, 1.5, animationSpeed * 100, 0, fastSlow)
            anim:Scale(nil, 1.5, 1, animationSpeed * 200, animationSpeed * 250, slowFast)
            anim:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 3000, slowFast)
        elseif (poolType == poolTypes.ANIMATION_COMBATSTATE) then
            anim:Alpha(nil, 0, 1, animationSpeed * 1000, 0, slowFast)
            anim:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 3000, slowFast)
        elseif (poolType == poolTypes.ANIMATION_POINT) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 3000, slowFast)
        elseif (poolType == poolTypes.ANIMATION_RESOURCE) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Scale(nil, 0.5, 1.5, animationSpeed * 100, 0, fastSlow)
            anim:Scale(nil, 1.5, 1, animationSpeed * 200, animationSpeed * 250, slowFast)
            anim:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 3000, slowFast)
        elseif (poolType == poolTypes.ANIMATION_ELLIPSE_X) then
            anim:Move("scrollX", 0, 0, animationSpeed * 2500, 0, easeOutIn)
        elseif (poolType == poolTypes.ANIMATION_ELLIPSE_Y) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Move("scrollY", 0, 0, animationSpeed * 2500)
            anim:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1800, slowFast)
        elseif (poolType == poolTypes.ANIMATION_ELLIPSE_X_CRIT) then
            anim:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
            anim:Move("scrollX", 0, 0, animationSpeed * 2500, 0, easeOutIn)
        elseif (poolType == poolTypes.ANIMATION_ELLIPSE_Y_CRIT) then
            anim:Alpha(nil, 0, 1, animationSpeed * 50)
            anim:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
            anim:Move("scrollY", 0, 0, animationSpeed * 2500)
            anim:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1800, slowFast)
        end

        return anim
    end

    local function DestroyAnimation(anim)
        anim:Stop()
        anim:SetStopHandler(nil)
        anim:ClearCallbacks()
    end

    if poolType == poolTypes.CONTROL then
        ZO_ObjectPool.Initialize(self, CreateControl, ResetControl)
        self:SetCustomAcquireBehavior(function (control)
            control:SetHidden(false)
        end)
        self.destroyFunction = DestroyControl
    else
        local USE_POOLED_OBJECT_WRAPPER = true
        ZO_ObjectPool.Initialize(self, CreateAnimation, ZO_ObjectPool_DefaultResetObject, USE_POOLED_OBJECT_WRAPPER)
        self.destroyFunction = DestroyAnimation
    end
end

function CombatTextPool:DestroyFreeObject(objectKey)
    ZO_ObjectPool.DestroyFreeObject(self, objectKey, self.destroyFunction)
end

function CombatTextPool:DestroyAllFreeObjects()
    ZO_ObjectPool.DestroyAllFreeObjects(self, self.destroyFunction)
end
