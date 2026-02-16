-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatTextAnimation : ZO_InitializingObject
local CombatTextAnimation = ZO_InitializingObject:Subclass()

--- @class (partial) LuiExtended.CombatTextAnimation
LUIE.CombatTextAnimation = CombatTextAnimation

local animationManager = GetAnimationManager()
local ANIMATION_ALPHA = ANIMATION_ALPHA
local ANIMATION_SCALE = ANIMATION_SCALE
local ANIMATION_TRANSLATE = ANIMATION_TRANSLATE
local linearEase = ZO_LinearEase

function CombatTextAnimation:New(...)
    --- @class LuiExtended.CombatTextAnimation
    local obj = setmetatable({}, self)
    obj.timeline = animationManager:CreateTimeline()
    obj.timeline:SetPlaybackType(0, 0)
    obj.namedSteps = {}
    obj:Initialize(...)
    return obj
end

function CombatTextAnimation:Initialize(...)
    -- To be overridden
end

function CombatTextAnimation:Apply(control)
    self.timeline:ApplyAllAnimationsToControl(control)
end

function CombatTextAnimation:Stop()
    self.timeline:Stop()
end

--- Sets a one-shot OnStop handler and clears it after firing.
--- @param callback function|nil
function CombatTextAnimation:SetStopHandler(callback)
    if callback == nil then
        self.timeline:SetHandler("OnStop", nil)
        return
    end

    self.timeline:SetHandler("OnStop", function (timeline, completedPlaying)
        callback(timeline, completedPlaying)
        self.timeline:SetHandler("OnStop", nil)
    end)
end

--- Resets the animation timeline for reuse.
function CombatTextAnimation:Reset()
    self.timeline:Stop()
    self.timeline:SetProgress(0)
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
    --- @cast step AnimationObjectAlpha
    step:SetAlphaValues(startAlpha, endAlpha)
    step:SetDuration(duration)
    step:SetEasingFunction(easingFunc or linearEase)
    if (stepName ~= nil and stepName ~= "") then self.namedSteps[stepName] = step end
    return step
end

function CombatTextAnimation:Scale(stepName, startScale, endScale, duration, delay, easingFunc)
    local step = self.timeline:InsertAnimation(ANIMATION_SCALE, nil, delay or 0)
    --- @cast step AnimationObjectScale
    step:SetScaleValues(startScale, endScale)
    step:SetDuration(duration)
    step:SetEasingFunction(easingFunc or linearEase)
    if (stepName ~= nil and stepName ~= "") then self.namedSteps[stepName] = step end
    return step
end

function CombatTextAnimation:Move(stepName, offsetX, offsetY, duration, delay, easingFunc)
    local step = self.timeline:InsertAnimation(ANIMATION_TRANSLATE, nil, delay or 0)
    --- @cast step AnimationObjectTranslate
    step:SetTranslateDeltas(offsetX, offsetY, TRANSLATE_ANIMATION_DELTA_TYPE_FROM_START)
    step:SetDuration(duration)
    step:SetEasingFunction(easingFunc or linearEase)
    if (stepName ~= nil and stepName ~= "") then self.namedSteps[stepName] = step end
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
    if (stepName ~= nil and stepName ~= "") then
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
