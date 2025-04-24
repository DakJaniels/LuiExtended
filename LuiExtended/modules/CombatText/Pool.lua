-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) CombatTextPool : ZO_ObjectPool
--- @field private poolType string The type of pool (control or animation)
LUIE.CombatTextPool = ZO_ObjectPool:Subclass()
--- @class (partial) CombatTextPool : ZO_ObjectPool
local CombatTextPool = LUIE.CombatTextPool

-- Import constants and utilities
local poolTypes = LuiData.Data.CombatTextConstants.poolType

--- @see easeInOutCirc(https://easings.net/#easeInOutCirc)
---
--- @param x number
--- @return number
local function easeInOutCirc(x)
    if x < 0.5 then
        return (1 - zo_sqrt(1 - (2 * x) * (2 * x))) / 2
    else
        return (zo_sqrt(1 - (-2 * x + 2) * (-2 * x + 2)) + 1) / 2
    end
end

-- Animation easing functions
local fastSlow = ZO_GenerateCubicBezierEase(0.3, 0.9, 0.7, 1)
local slowFast = ZO_GenerateCubicBezierEase(0.63, 0.1, 0.83, 0.69)
local even = ZO_GenerateCubicBezierEase(0.63, 1.2, 0.83, 1)

-- Animation configuration table
local AnimationConfigs =
{
    [poolTypes.ANIMATION_CLOUD] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Alpha(nil, 1, 0, speed * 500, speed * 1500, slowFast)
    end,
    [poolTypes.ANIMATION_CLOUD_CRITICAL] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Scale(nil, 1.5, 1, speed * 150, 0, slowFast)
        anim:Alpha(nil, 1, 0, speed * 500, speed * 1500, slowFast)
    end,
    [poolTypes.ANIMATION_CLOUD_FIREWORKS] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Move("move", 0, 0, speed * 250, 0, fastSlow)
        anim:Alpha("fadeOut", 1, 0, speed * 500, speed * 1500, slowFast)
    end,
    [poolTypes.ANIMATION_SCROLL] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Move("scroll", 0, 0, speed * 2500, 0, even)
        anim:Alpha("fadeOut", 1, 0, speed * 500, speed * 1400, slowFast)
    end,
    [poolTypes.ANIMATION_SCROLL_CRITICAL] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Scale(nil, 1.5, 1, speed * 150, 0, slowFast)
        anim:Move("scroll", 0, 0, speed * 2500, 0, even)
        anim:Alpha("fadeOut", 1, 0, speed * 500, speed * 1400, slowFast)
    end,
    [poolTypes.ANIMATION_DEATH] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Scale(nil, 1.5, 1, speed * 150, 0, slowFast)
        anim:Move("scroll", 0, 0, speed * 5000, 0, even)
        anim:Alpha("fadeOut", 1, 0, speed * 500, speed * 2000, slowFast)
    end,
    [poolTypes.ANIMATION_ALERT] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Scale(nil, 0.5, 1.5, speed * 100, 0, fastSlow)
        anim:Scale(nil, 1.5, 1, speed * 200, speed * 250, slowFast)
        anim:Alpha(nil, 1, 0, speed * 500, speed * 3000, slowFast)
    end,
    [poolTypes.ANIMATION_COMBATSTATE] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 1000, 0, slowFast)
        anim:Alpha(nil, 1, 0, speed * 500, speed * 3000, slowFast)
    end,
    [poolTypes.ANIMATION_POINT] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Alpha(nil, 1, 0, speed * 500, speed * 3000, slowFast)
    end,
    [poolTypes.ANIMATION_RESOURCE] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Scale(nil, 0.5, 1.5, speed * 100, 0, fastSlow)
        anim:Scale(nil, 1.5, 1, speed * 200, speed * 250, slowFast)
        anim:Alpha(nil, 1, 0, speed * 500, speed * 3000, slowFast)
    end,
    [poolTypes.ANIMATION_ELLIPSE_X] = function (anim, speed)
        anim:Move("scrollX", 0, 0, speed * 2500, 0, easeInOutCirc)
    end,
    [poolTypes.ANIMATION_ELLIPSE_Y] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Move("scrollY", 0, 0, speed * 2500)
        anim:Alpha("fadeOut", 1, 0, speed * 500, speed * 1800, slowFast)
    end,
    [poolTypes.ANIMATION_ELLIPSE_X_CRIT] = function (anim, speed)
        anim:Scale(nil, 1.5, 1, speed * 150, 0, slowFast)
        anim:Move("scrollX", 0, 0, speed * 2500, 0, easeInOutCirc)
    end,
    [poolTypes.ANIMATION_ELLIPSE_Y_CRIT] = function (anim, speed)
        anim:Alpha(nil, 0, 1, speed * 50)
        anim:Scale(nil, 1.5, 1, speed * 150, 0, slowFast)
        anim:Move("scrollY", 0, 0, speed * 2500)
        anim:Alpha("fadeOut", 1, 0, speed * 500, speed * 1800, slowFast)
    end,
}

--- Creates a new CombatTextPool instance
--- @param poolType string The type of pool to create
--- @return CombatTextPool
function CombatTextPool:New(poolType)
    if not poolType then
        error("poolType is required for CombatTextPool:New()")
    end

    --- @class (partial) CombatTextPool:ZO_ObjectPool
    local obj
    if poolType == poolTypes.CONTROL then
        --- @class (partial) CombatTextPool:ZO_ObjectPool
        obj = ZO_ObjectPool:New(self.CreateNewControl, self.ResetControl)
    else
        --- @class (partial) CombatTextPool:ZO_ObjectPool
        obj = ZO_ObjectPool:New(self.CreateNewAnimation, function () end)
    end

    obj.poolType = poolType

    -- Register this pool with the PoolManager
    if LUIE.CombatTextPoolManager then
        LUIE.CombatTextPoolManager:RegisterPool(poolType, obj)
    end

    return obj
end

--- Creates a new control for the pool
--- @return Control
function CombatTextPool:CreateNewControl()
    --- @type LUIE_CombatText_Virtual
    local control = CreateControlFromVirtual("LUIE_CombatText_Virtual_Instance", LUIE_CombatText, "LUIE_CombatText_Virtual", self:GetNextControlId())
    control.label = control:GetNamedChild("_Amount")
    control.icon = control:GetNamedChild("_Icon")
    return control
end

--- @class CombatTextPool_control : Control
--- @field label LabelControl
--- @field icon TextureControl

--- Resets a control to its default state
--- @param control CombatTextPool_control The control to reset
function CombatTextPool.ResetControl(control)
    control:ClearAnchors()
    control.label:ClearAnchors()
    control.icon:ClearAnchors()
    control.icon:SetHidden(true)
end

--- Creates a new animation for the pool
--- @return CombatTextAnimation
function CombatTextPool:CreateNewAnimation()
    local anim = LUIE.CombatTextAnimation:New()
    local Settings = LUIE.CombatText.SV
    local animationSpeed = 1 / (Settings.animation.animationDuration / 100)

    local animationConfig = AnimationConfigs[self.poolType]
    if animationConfig then
        animationConfig(anim, animationSpeed)
    end

    return anim
end
