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

--- Initializes a new CombatTextAnimation instance.
--- Creates an animation timeline with one-shot playback and initializes the named steps table.
function CombatTextAnimation:Initialize()
    self.timeline = animationManager:CreateTimeline()
    self.timeline:SetPlaybackType(ANIMATION_PLAYBACK_ONE_SHOT, 0)
    self.namedSteps = {}
end

--- Applies all animations in the timeline to the specified control.
--- @param animatedControl object The control to apply animations to
function CombatTextAnimation:Apply(animatedControl)
    self.timeline:ApplyAllAnimationsToControl(animatedControl)
end

--- Stops the animation timeline.
function CombatTextAnimation:Stop()
    self.timeline:Stop()
end

--- Sets the progress of the animation timeline.
--- @param progress number The progress value (0.0 to 1.0)
function CombatTextAnimation:SetProgress(progress)
    self.timeline:SetProgress(progress)
end

--- Plays the animation timeline from the start.
function CombatTextAnimation:Play()
    self.timeline:PlayFromStart()
end

--- Plays the animation timeline forward from the current position.
function CombatTextAnimation:PlayForward()
    self.timeline:PlayForward()
end

--- Instantly plays the animation timeline to the end.
function CombatTextAnimation:PlayInstantlyToEnd()
    self.timeline:PlayInstantlyToEnd()
end

--- Creates an alpha (opacity) animation step.
--- @param stepName string|nil Optional name for the step (used for retrieval via GetStepByName)
--- @param startAlpha number Starting alpha value (0.0 to 1.0)
--- @param endAlpha number Ending alpha value (0.0 to 1.0)
--- @param duration integer Duration in milliseconds
--- @param delay integer|nil Optional delay in milliseconds (defaults to 0)
--- @param easingFunc function|nil Optional easing function (defaults to ZO_LinearEase)
--- @return object animationStep The created AnimationObjectAlpha step
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

--- Creates a scale animation step.
--- @param stepName string|nil Optional name for the step (used for retrieval via GetStepByName)
--- @param startScale number Starting scale value
--- @param endScale number Ending scale value
--- @param duration integer Duration in milliseconds
--- @param delay integer|nil Optional delay in milliseconds (defaults to 0)
--- @param easingFunc function|nil Optional easing function (defaults to ZO_LinearEase)
--- @return object animationStep The created AnimationObjectScale step
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

--- Creates a translate (movement) animation step.
--- @param stepName string|nil Optional name for the step (used for retrieval via GetStepByName)
--- @param offsetX number|layout_measurement X-axis offset/delta
--- @param offsetY number|layout_measurement Y-axis offset/delta
--- @param duration integer Duration in milliseconds
--- @param delay integer|nil Optional delay in milliseconds (defaults to 0)
--- @param easingFunc function|nil Optional easing function (defaults to ZO_LinearEase)
--- @return object animationStep The created AnimationObjectTranslate step
function CombatTextAnimation:Move(stepName, offsetX, offsetY, duration, delay, easingFunc)
    local step = self.timeline:InsertAnimation(ANIMATION_TRANSLATE, nil, delay or 0)
    step:SetTranslateDeltas(offsetX, offsetY, TRANSLATE_ANIMATION_DELTA_TYPE_FROM_START)
    step:SetDuration(duration)
    step:SetEasingFunction(easingFunc or ZO_LinearEase)
    if stepName ~= nil and stepName ~= "" then
        self.namedSteps[stepName] = step
    end
    return step
end

--- Inserts a callback into the animation timeline.
--- @param func function The callback function to execute
--- @param delay integer Delay in milliseconds before executing the callback
function CombatTextAnimation:InsertCallback(func, delay)
    self.timeline:InsertCallback(func, delay)
end

--- Clears all callbacks from the animation timeline.
function CombatTextAnimation:ClearCallbacks()
    self.timeline:ClearAllCallbacks()
end

--- Gets an animation step by index.
--- @param i integer The animation index (1-based)
--- @return object|nil animationStep The AnimationObject at the specified index, or nil if not found
function CombatTextAnimation:GetStep(i)
    return self.timeline:GetAnimation(i)
end

--- Gets an animation step by name (if it was named when created).
--- @param stepName string The name of the step
--- @return object|nil animationStep The AnimationObject with the specified name, or nil if not found
function CombatTextAnimation:GetStepByName(stepName)
    if stepName ~= nil and stepName ~= "" then
        return self.namedSteps[stepName]
    end
end

--- Gets the last animation step in the timeline.
--- @return object|nil animationStep The last AnimationObject in the timeline, or nil if empty
function CombatTextAnimation:GetLastStep()
    return self.timeline:GetLastAnimation()
end

--- Sets the delay/offset for a specific animation step.
--- @param step object The AnimationObject to set the delay for
--- @param delay integer The delay/offset in milliseconds
function CombatTextAnimation:SetStepDelay(step, delay)
    self.timeline:SetAnimationOffset(step, delay)
end

--- Gets the total duration of the animation timeline.
--- @return integer duration The duration in milliseconds
function CombatTextAnimation:GetDuration()
    local duration = self.timeline:GetDuration()
    return duration or 0
end

--- Gets the current progress of the animation timeline.
--- @return number progress The progress value (0.0 to 1.0)
function CombatTextAnimation:GetProgress()
    local progress = self.timeline:GetProgress()
    return progress or 0
end
