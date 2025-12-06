-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

---@class LuiExtended
local LUIE = LUIE
--- @class (partial) LuiExtended.CombatTextAnimation : ZO_InitializingObject
LUIE.CombatTextAnimation = ZO_InitializingObject:Subclass()
--- @class (partial) LuiExtended.CombatTextAnimation
local CombatTextAnimation = LUIE.CombatTextAnimation

local animationManager = ANIMATION_MANAGER

function CombatTextAnimation:New()
    local obj = setmetatable({}, self)
    obj.timeline = animationManager:CreateTimeline()
    obj.timeline:SetPlaybackType(0, 0)
    obj.namedSteps = {}
    return obj
end

function CombatTextAnimation:Apply(control)
    self.timeline:ApplyAllAnimationsToControl(control)
end

function CombatTextAnimation:Stop()
    self.timeline:Stop()
end

function CombatTextAnimation:SetProgress(progress)
    self.timeline:SetProgress(progress)
end

function CombatTextAnimation:Play()
    self.timeline:PlayFromStart()
end

function CombatTextAnimation:PlayForward()
    self.timeline:PlayForward()
end

function CombatTextAnimation:PlayInstantlyToEnd()
    self.timeline:PlayInstantlyToEnd()
end

function CombatTextAnimation:Alpha(stepName, startAlpha, endAlpha, duration, delay, easingFunc)
    local step = self.timeline:InsertAnimation(ANIMATION_ALPHA, nil, delay or 0)
    step:SetAlphaValues(startAlpha, endAlpha)
    step:SetDuration(duration)
    step:SetEasingFunction(easingFunc or ZO_LinearEase)
    if stepName ~= nil and stepName ~= "" then
        self.namedSteps[stepName] = step
    end
    return step
end

function CombatTextAnimation:Scale(stepName, startScale, endScale, duration, delay, easingFunc)
    local step = self.timeline:InsertAnimation(ANIMATION_SCALE, nil, delay or 0)
    step:SetScaleValues(startScale, endScale)
    step:SetDuration(duration)
    step:SetEasingFunction(easingFunc or ZO_LinearEase)
    if stepName ~= nil and stepName ~= "" then
        self.namedSteps[stepName] = step
    end
    return step
end

function CombatTextAnimation:Move(stepName, offsetX, offsetY, duration, delay, easingFunc)
    local step = self.timeline:InsertAnimation(ANIMATION_TRANSLATE, nil, delay or 0)
    step:SetTranslateDeltas(offsetX, offsetY)
    step:SetDuration(duration)
    step:SetEasingFunction(easingFunc or ZO_LinearEase)
    if stepName ~= nil and stepName ~= "" then
        self.namedSteps[stepName] = step
    end
    return step
end

function CombatTextAnimation:InsertCallback(func, delay)
    self.timeline:InsertCallback(func, delay)
end

function CombatTextAnimation:ClearCallbacks()
    self.timeline:ClearAllCallbacks()
end

function CombatTextAnimation:GetStep(i)
    return self.timeline:GetAnimation(i)
end

function CombatTextAnimation:GetStepByName(stepName)
    if stepName ~= nil and stepName ~= "" then
        return self.namedSteps[stepName]
    end
end

function CombatTextAnimation:GetLastStep()
    return self.timeline:GetLastAnimation()
end

function CombatTextAnimation:SetStepDelay(step, delay)
    return self.timeline:SetAnimationOffset(step, delay)
end

function CombatTextAnimation:GetDuration()
    return self.timeline:GetDuration()
end

function CombatTextAnimation:GetProgress()
    return self.timeline:GetProgress()
end
