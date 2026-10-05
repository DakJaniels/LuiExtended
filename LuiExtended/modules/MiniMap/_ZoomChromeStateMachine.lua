-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

MINIMAP_ZOOM_CHROME_TRIGGER_COMMANDS =
{
    REVEAL = "REVEAL",
    FADE_COMPLETE = "FADE_COMPLETE",
}

--- Transient zoom chrome (zoom buttons, zoom label): revealed on pointer or zoom, faded back out after a hold.
--- The hold and the fade are one ZO_AlphaAnimation per control, so there is no timer and no OnUpdate.
--- @class MiniMapZoomChromeStateMachine : ZO_StateMachine_Base
--- @field animatedControls Control[]
--- @field alphaAnimations ZO_AlphaAnimation[]
--- @field maxAlpha number
--- @field fadeMilliseconds number
--- @field fadeGeneration number
--- @field revealedState ZO_StateMachine_State
--- @field idleState ZO_StateMachine_State
MiniMapZoomChromeStateMachine = ZO_StateMachine_Base:Subclass()
MiniMap.MiniMapZoomChromeStateMachine = MiniMapZoomChromeStateMachine

--- @param stateMachineName string
--- @param animatedControls Control[]
--- @param maxAlpha number
--- @param fadeMilliseconds number
--- @return MiniMapZoomChromeStateMachine
function MiniMapZoomChromeStateMachine:New(stateMachineName, animatedControls, maxAlpha, fadeMilliseconds)
    local object = ZO_StateMachine_Base.New(self, stateMachineName, animatedControls, maxAlpha, fadeMilliseconds)
    --- @cast object MiniMapZoomChromeStateMachine
    return object
end

--- @param stateMachineName string
--- @param animatedControls Control[]
--- @param maxAlpha number
--- @param fadeMilliseconds number
function MiniMapZoomChromeStateMachine:Initialize(stateMachineName, animatedControls, maxAlpha, fadeMilliseconds)
    ZO_StateMachine_Base.Initialize(self, stateMachineName)

    self.animatedControls = animatedControls
    self.maxAlpha = maxAlpha
    self.fadeMilliseconds = fadeMilliseconds
    self.fadeGeneration = 0

    self.alphaAnimations = {}
    for controlIndex = 1, #animatedControls do
        local alphaAnimation = ZO_AlphaAnimation:New(animatedControls[controlIndex])
        alphaAnimation:SetMinMaxAlpha(0, maxAlpha)
        self.alphaAnimations[controlIndex] = alphaAnimation
    end

    local commands = MINIMAP_ZOOM_CHROME_TRIGGER_COMMANDS

    self.idleState = self:AddState("Idle")
    self.revealedState = self:AddState("Revealed")

    self:AddEdgeAutoName("Idle", "Revealed")
    self:AddEdgeAutoName("Revealed", "Idle")

    self:AddTrigger("REVEAL", ZO_StateMachine_TriggerStateCallback, commands.REVEAL)
    self:AddTrigger("FADE_COMPLETE", ZO_StateMachine_TriggerStateCallback, commands.FADE_COMPLETE)

    self:AddTriggerToEdge("REVEAL", "Idle_TO_Revealed")
    self:AddTriggerToEdge("FADE_COMPLETE", "Revealed_TO_Idle")

    local stateMachine = self
    self.revealedState:RegisterCallback("OnActivated", function ()
        stateMachine:ApplyRevealedChrome()
    end)
    self.idleState:RegisterCallback("OnActivated", function ()
        stateMachine:ApplyIdleChrome()
    end)

    self:SetCurrentState("Idle")
end

--- Overridden by the owner to show the chrome controls.
function MiniMapZoomChromeStateMachine:ApplyRevealedChrome()
end

--- Overridden by the owner to hide the chrome controls.
function MiniMapZoomChromeStateMachine:ApplyIdleChrome()
end

--- @return boolean
function MiniMapZoomChromeStateMachine:IsRevealed()
    return self:GetCurrentState() == self.revealedState
end

--- Stops a running hold or fade. ZO_AlphaAnimation fires its OnStop callback even when stopped early
--- (ZO_ALPHA_ANIMATION_OPTION_PREVENT_CALLBACK clears the timeline, not the animation that owns the callback),
--- so the generation count is what tells a cancelled fade from a finished one.
function MiniMapZoomChromeStateMachine:CancelFade()
    self.fadeGeneration = self.fadeGeneration + 1
    for animationIndex = 1, #self.alphaAnimations do
        self.alphaAnimations[animationIndex]:Stop()
    end
end

--- Full alpha now, no fade queued. Used while the pointer is over the chrome.
function MiniMapZoomChromeStateMachine:Reveal()
    self:CancelFade()
    if self:IsRevealed() then
        self:ApplyRevealedChrome()
        return
    end
    self:FireCallbacks(MINIMAP_ZOOM_CHROME_TRIGGER_COMMANDS.REVEAL)
end

--- @param holdMilliseconds number Time at full alpha before the fade starts.
function MiniMapZoomChromeStateMachine:ScheduleFade(holdMilliseconds)
    if not self:IsRevealed() then
        return
    end
    self:CancelFade()
    local fadeGeneration = self.fadeGeneration
    local stateMachine = self
    local function OnFadeStopped()
        if stateMachine.fadeGeneration ~= fadeGeneration then
            return
        end
        stateMachine:FireCallbacks(MINIMAP_ZOOM_CHROME_TRIGGER_COMMANDS.FADE_COMPLETE)
    end
    -- ZO_AlphaAnimation:FadeOut scales the duration by the control's current alpha, so a 0.4 alpha label
    -- would otherwise fade in 0.4 of the configured time (ZO_AlphaAnimation.lua FadeOut).
    local scaledFadeMilliseconds = self.fadeMilliseconds / self.maxAlpha
    for animationIndex = 1, #self.alphaAnimations do
        local fadeCallback = nil
        if animationIndex == 1 then
            fadeCallback = OnFadeStopped
        end
        self.alphaAnimations[animationIndex]:FadeOut(
            holdMilliseconds,
            scaledFadeMilliseconds,
            ZO_ALPHA_ANIMATION_OPTION_FORCE_ALPHA,
            fadeCallback,
            ZO_ALPHA_ANIMATION_OPTION_FORCE_SHOWN
        )
    end
end

--- @param holdMilliseconds number
function MiniMapZoomChromeStateMachine:RevealThenFade(holdMilliseconds)
    self:Reveal()
    self:ScheduleFade(holdMilliseconds)
end

--- Back to the idle chrome with no animation pending.
function MiniMapZoomChromeStateMachine:Shutdown()
    self:CancelFade()
    if self:IsRevealed() then
        self:FireCallbacks(MINIMAP_ZOOM_CHROME_TRIGGER_COMMANDS.FADE_COMPLETE)
    else
        self:ApplyIdleChrome()
    end
end
