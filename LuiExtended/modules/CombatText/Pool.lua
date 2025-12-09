-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextPool : ZO_ObjectPool
local CombatTextPool = ZO_ObjectPool:Subclass()

--- @class (partial) LuiExtended.CombatTextPool
LUIE.CombatTextPool = CombatTextPool

local poolTypes = LuiData.Data.CombatTextConstants.poolType

local fastSlow = ZO_GenerateCubicBezierEase(0.3, 0.9, 0.7, 1)
local slowFast = ZO_GenerateCubicBezierEase(0.63, 0.1, 0.83, 0.69)
local even = ZO_GenerateCubicBezierEase(0.63, 1.2, 0.83, 1)

local easeOutIn = function (progress)
    return ZO_EaseInOutQuadratic(progress)
end

function CombatTextPool:New(poolType)
    -- Check if poolType is not nil or empty
    if not poolType then
        error("poolType is required.")
    end

    local obj = setmetatable({}, self)
    obj.poolType = poolType

    if poolType == poolTypes.CONTROL then
        local function CreateControl(pool)
            local control = CreateControlFromVirtual("LUIE_CombatText_Virtual_Instance", LUIE_CombatText, "LUIE_CombatText_Virtual", pool:GetNextControlId())
            control.label = control:GetNamedChild("_Amount")
            control.icon = control:GetNamedChild("_Icon")
            return control
        end

        local function ResetControl(control)
            control:ClearAnchors()
            control:SetHidden(true)
            control.label:ClearAnchors()
            control.label:SetText("")
            control.icon:ClearAnchors()
            control.icon:SetHidden(true)
        end

        ZO_ObjectPool.Initialize(obj, CreateControl, ResetControl)
        obj:SetCustomAcquireBehavior(function (control)
            control:SetHidden(false)
        end)
    else
        -- Capture poolType in closure for animation factory
        local capturedPoolType = poolType
        ---
        --- @param animPool LuiExtended.CombatTextAnimation
        --- @return LuiExtended.CombatTextAnimation
        local function CreateAnimation(animPool)
            animPool = LUIE.CombatTextAnimation:New()
            local Settings = LUIE.CombatText.SV
            local animationSpeed = 1 / (Settings.animation.animationDuration / 100)

            local animationTypes =
            {
                [poolTypes.ANIMATION_CLOUD] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 1500, slowFast)
                end,
                [poolTypes.ANIMATION_CLOUD_CRITICAL] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
                    animPool:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 1500, slowFast)
                end,
                [poolTypes.ANIMATION_CLOUD_FIREWORKS] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Move("move", 0, 0, animationSpeed * 250, 0, fastSlow) -- x and y is set before the animation is played
                    animPool:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1500, slowFast)
                end,
                [poolTypes.ANIMATION_SCROLL] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Move("scroll", 0, 0, animationSpeed * 2500, 0, even)
                    animPool:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1400, slowFast)
                end,
                [poolTypes.ANIMATION_SCROLL_CRITICAL] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
                    animPool:Move("scroll", 0, 0, animationSpeed * 2500, 0, even)
                    animPool:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1400, slowFast)
                end,
                [poolTypes.ANIMATION_DEATH] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
                    animPool:Move("scroll", 0, 0, animationSpeed * 5000, 0, even)
                    animPool:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 2000, slowFast)
                end,
                [poolTypes.ANIMATION_ALERT] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Scale(nil, 0.5, 1.5, animationSpeed * 100, 0, fastSlow)
                    animPool:Scale(nil, 1.5, 1, animationSpeed * 200, animationSpeed * 250, slowFast)
                    animPool:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 3000, slowFast)
                end,
                [poolTypes.ANIMATION_COMBATSTATE] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 1000, 0, slowFast)
                    animPool:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 3000, slowFast)
                end,
                [poolTypes.ANIMATION_POINT] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 3000, slowFast)
                end,
                [poolTypes.ANIMATION_RESOURCE] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Scale(nil, 0.5, 1.5, animationSpeed * 100, 0, fastSlow)
                    animPool:Scale(nil, 1.5, 1, animationSpeed * 200, animationSpeed * 250, slowFast)
                    animPool:Alpha(nil, 1, 0, animationSpeed * 500, animationSpeed * 3000, slowFast)
                end,
                [poolTypes.ANIMATION_ELLIPSE_X] = function ()
                    animPool:Move("scrollX", 0, 0, animationSpeed * 2500, 0, easeOutIn)
                end,
                [poolTypes.ANIMATION_ELLIPSE_Y] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Move("scrollY", 0, 0, animationSpeed * 2500) -- for delay and easying function will be used defaults (0, ZO_LinearEase)
                    animPool:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1800, slowFast)
                end,
                [poolTypes.ANIMATION_ELLIPSE_X_CRIT] = function ()
                    animPool:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
                    animPool:Move("scrollX", 0, 0, animationSpeed * 2500, 0, easeOutIn)
                end,
                [poolTypes.ANIMATION_ELLIPSE_Y_CRIT] = function ()
                    animPool:Alpha(nil, 0, 1, animationSpeed * 50)
                    animPool:Scale(nil, 1.5, 1, animationSpeed * 150, 0, slowFast)
                    animPool:Move("scrollY", 0, 0, animationSpeed * 2500)
                    animPool:Alpha("fadeOut", 1, 0, animationSpeed * 500, animationSpeed * 1800, slowFast)
                end,
            }

            local animationType = animationTypes[capturedPoolType]
            if animationType then
                animationType()
            end

            return animPool
        end
        ---
        --- @param animPool LuiExtended.CombatTextAnimation
        local function ResetAnimation(animPool)
            animPool:Reset()
        end

        ZO_ObjectPool.Initialize(obj, CreateAnimation, ResetAnimation)
    end

    return obj
end
