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

-- Pre-computed easing functions (module-level caching for performance)
local fastSlow = ZO_GenerateCubicBezierEase(0.3, 0.9, 0.7, 1)
local slowFast = ZO_GenerateCubicBezierEase(0.63, 0.1, 0.83, 0.69)
local even = ZO_GenerateCubicBezierEase(0.63, 1.2, 0.83, 1)

-- Ellipse easing (quadratic ease-in-out) - extracted from inline closures for performance
local ellipseEasing = function (p)
    if p < 0.5 then
        p = p + p
        return 0.5 * p * p
    end
    p = (1 - p) + (1 - p)
    return 1 - 0.5 * p * p
end

local animationConfigs =
{
    [poolTypes.ANIMATION_CLOUD] =
    {
        { type = "alpha", from = 0, to = 1, duration = 50                                        },
        { type = "alpha", from = 1, to = 0, startDelay = 500, endDelay = 1500, easing = slowFast },
    },
    [poolTypes.ANIMATION_CLOUD_CRITICAL] =
    {
        { type = "alpha", from = 0,   to = 1, duration = 50                                        },
        { type = "scale", from = 1.5, to = 1, duration = 150,   delay = 0,       easing = slowFast },
        { type = "alpha", from = 1,   to = 0, startDelay = 500, endDelay = 1500, easing = slowFast },
    },
    [poolTypes.ANIMATION_CLOUD_FIREWORKS] =
    {
        { type = "alpha", from = 0,          to = 1,         duration = 50                                                      },
        { type = "move",  label = "move",    duration = 250, delay = 0,    easing = fastSlow                                    },
        { type = "alpha", label = "fadeOut", from = 1,       to = 0,       startDelay = 500, endDelay = 1500, easing = slowFast },
    },
    [poolTypes.ANIMATION_SCROLL] =
    {
        { type = "alpha", from = 0,          to = 1,          duration = 50                                                      },
        { type = "move",  label = "scroll",  duration = 2500, delay = 0,    easing = even                                        },
        { type = "alpha", label = "fadeOut", from = 1,        to = 0,       startDelay = 500, endDelay = 1400, easing = slowFast },
    },
    [poolTypes.ANIMATION_SCROLL_CRITICAL] =
    {
        { type = "alpha", from = 0,          to = 1,          duration = 50                                                         },
        { type = "scale", from = 1.5,        to = 1,          duration = 150, delay = 0,        easing = slowFast                   },
        { type = "move",  label = "scroll",  duration = 2500, delay = 0,      easing = even                                         },
        { type = "alpha", label = "fadeOut", from = 1,        to = 0,         startDelay = 500, endDelay = 1400,  easing = slowFast },
    },
    [poolTypes.ANIMATION_DEATH] =
    {
        { type = "alpha", from = 0,          to = 1,          duration = 50                                                         },
        { type = "scale", from = 1.5,        to = 1,          duration = 150, delay = 0,        easing = slowFast                   },
        { type = "move",  label = "scroll",  duration = 5000, delay = 0,      easing = even                                         },
        { type = "alpha", label = "fadeOut", from = 1,        to = 0,         startDelay = 500, endDelay = 2000,  easing = slowFast },
    },
    [poolTypes.ANIMATION_ALERT] =
    {
        { type = "alpha", from = 0,   to = 1,   duration = 50                                        },
        { type = "scale", from = 0.5, to = 1.5, duration = 100,   delay = 0,       easing = fastSlow },
        { type = "scale", from = 1.5, to = 1,   duration = 200,   delay = 250,     easing = slowFast },
        { type = "alpha", from = 1,   to = 0,   startDelay = 500, endDelay = 3000, easing = slowFast },
    },
    [poolTypes.ANIMATION_COMBATSTATE] =
    {
        { type = "alpha", from = 0, to = 1, duration = 1000,  delay = 0,       easing = slowFast },
        { type = "alpha", from = 1, to = 0, startDelay = 500, endDelay = 3000, easing = slowFast },
    },
    [poolTypes.ANIMATION_POINT] =
    {
        { type = "alpha", from = 0, to = 1, duration = 50                                        },
        { type = "alpha", from = 1, to = 0, startDelay = 500, endDelay = 3000, easing = slowFast },
    },
    [poolTypes.ANIMATION_RESOURCE] =
    {
        { type = "alpha", from = 0,   to = 1,   duration = 50                                        },
        { type = "scale", from = 0.5, to = 1.5, duration = 100,   delay = 0,       easing = fastSlow },
        { type = "scale", from = 1.5, to = 1,   duration = 200,   delay = 250,     easing = slowFast },
        { type = "alpha", from = 1,   to = 0,   startDelay = 500, endDelay = 3000, easing = slowFast },
    },
    [poolTypes.ANIMATION_ELLIPSE_X] =
    {
        { type = "move", label = "scrollX", duration = 2500, delay = 0, easing = ellipseEasing },
    },
    [poolTypes.ANIMATION_ELLIPSE_Y] =
    {
        { type = "alpha", from = 0,          to = 1,         duration = 50                                                      },
        { type = "move",  label = "scrollY", duration = 2500                                                                    },
        { type = "alpha", label = "fadeOut", from = 1,       to = 0,       startDelay = 500, endDelay = 1800, easing = slowFast },
    },
    [poolTypes.ANIMATION_ELLIPSE_X_CRIT] =
    {
        { type = "scale", from = 1.5,        to = 1,          duration = 150, delay = 0,             easing = slowFast },
        { type = "move",  label = "scrollX", duration = 2500, delay = 0,      easing = ellipseEasing                   },
    },
    [poolTypes.ANIMATION_ELLIPSE_Y_CRIT] =
    {
        { type = "alpha", from = 0,          to = 1,         duration = 50                                                         },
        { type = "scale", from = 1.5,        to = 1,         duration = 150, delay = 0,        easing = slowFast                   },
        { type = "move",  label = "scrollY", duration = 2500                                                                       },
        { type = "alpha", label = "fadeOut", from = 1,       to = 0,         startDelay = 500, endDelay = 1800,  easing = slowFast },
    },
}

local function BuildAnimation(anim, poolType, speed)
    local config = animationConfigs[poolType]
    if not config then return end

    for _, step in ipairs(config) do
        if step.type == "alpha" then
            local label = step.label or nil
            if step.startDelay and step.endDelay then
                -- Fade out with delays: Alpha(label, from, to, startDelay, endDelay, easing)
                anim:Alpha(label, step.from, step.to, speed * step.startDelay, speed * step.endDelay, step.easing)
            else
                -- Simple fade: Alpha(label, from, to, duration, delay, easing)
                local delay = step.delay and speed * step.delay or nil
                anim:Alpha(label, step.from, step.to, speed * step.duration, delay, step.easing)
            end
        elseif step.type == "scale" then
            anim:Scale(nil, step.from, step.to, speed * step.duration, step.delay and speed * step.delay or 0, step.easing)
        elseif step.type == "move" then
            anim:Move(step.label, 0, 0, speed * step.duration, step.delay and speed * step.delay or 0, step.easing)
        end
    end
end

function CombatTextPool:Initialize(poolType)
    assert(poolType, "poolType is required.")

    self.poolType = poolType

    local function CreateControl(pool)
        local control = CreateControlFromVirtual("LUIE_CombatText_Virtual_Instance", LUIE_CombatText, "LUIE_CombatText_Virtual", pool:GetNextControlId())
        control.label = control:GetNamedChild("_Amount")
        control.iconHost = control:GetNamedChild("_IconHost")
        control.iconFrame = control.iconHost:GetNamedChild("_IconFrame")
        control.icon = control.iconHost:GetNamedChild("_Icon")
        return control
    end

    local function ResetControl(control)
        control:ClearAnchors()
        control.label:ClearAnchors()
        if control.iconHost then
            control.iconHost:ClearAnchors()
            control.iconHost:SetHidden(true)
        end
        if control.iconFrame then
            control.iconFrame:ClearAnchors()
            control.iconFrame:SetHidden(true)
            control.iconFrame:SetColor(1, 1, 1, 1)
        end
        control.icon:ClearAnchors()
        control.icon:SetHidden(true)
        control.icon:SetColor(1, 1, 1, 1)
        control.icon._lastTexture = nil
        control:SetHidden(true)
    end

    local function CreateAnimation()
        local anim = LUIE.CombatTextAnimation:New()
        local Settings = LUIE.CombatText.SV
        local speed = 1 / (Settings.animation.animationDuration / 100)
        BuildAnimation(anim, poolType, speed)
        return anim
    end

    if poolType == poolTypes.CONTROL then
        ZO_ObjectPool.Initialize(self, CreateControl, ResetControl)
        self:SetCustomAcquireBehavior(function (control)
            control:SetHidden(false)
        end)
    else
        local USE_POOLED_OBJECT_WRAPPER = true
        ZO_ObjectPool.Initialize(self, CreateAnimation, ZO_ObjectPool_DefaultResetObject, USE_POOLED_OBJECT_WRAPPER)
    end
end
