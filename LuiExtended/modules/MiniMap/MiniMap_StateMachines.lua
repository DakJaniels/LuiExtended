-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

-- Both state machines are plain ZO_StateMachine_Base instances (EsoUI/Libraries/ZO_StateMachine/ZO_StateMachine.lua):
-- AddState / AddEdgeAutoName ("%s_TO_%s") / AddTrigger(name, ZO_StateMachine_TriggerStateCallback, command) fired via
-- stateMachine:FireCallbacks(command).

-- Zoom controls ----------------------------------------------------------------

LUIE_MINIMAP_FADE_TRIGGER_COMMANDS =
{
    REVEAL = "REVEAL",
    FADE_COMPLETE = "FADE_COMPLETE",
}

--- Zoom controls (zoom buttons, zoom label): revealed on mouse or zoom, faded back out after a hold.
--- The hold and the fade are one ZO_AlphaAnimation per control, so there is no timer and no OnUpdate.
--- @class LUIE_MiniMap_FadeStateMachine : ZO_StateMachine_Base
--- @field animatedControls Control[]
--- @field alphaAnimations ZO_AlphaAnimation[]
--- @field maxAlpha number
--- @field fadeMilliseconds number
--- @field fadeGeneration integer
--- @field revealedState ZO_StateMachine_State
--- @field idleState ZO_StateMachine_State
--- @field applyRevealed fun()
--- @field applyIdle fun()
LUIE_MiniMap_FadeStateMachine = ZO_StateMachine_Base:Subclass()

--- @param stateMachineName string
--- @param animatedControls Control[]
--- @param maxAlpha number
--- @param fadeMilliseconds number
--- @param applyRevealed fun()
--- @param applyIdle fun()
--- @return LUIE_MiniMap_FadeStateMachine
function LUIE_MiniMap_FadeStateMachine:New(stateMachineName, animatedControls, maxAlpha, fadeMilliseconds, applyRevealed, applyIdle)
    local object = ZO_StateMachine_Base.New(self, stateMachineName, animatedControls, maxAlpha, fadeMilliseconds, applyRevealed, applyIdle)
    --- @cast object LUIE_MiniMap_FadeStateMachine
    return object
end

--- @param stateMachineName string
--- @param animatedControls Control[]
--- @param maxAlpha number
--- @param fadeMilliseconds number
--- @param applyRevealed fun()
--- @param applyIdle fun()
function LUIE_MiniMap_FadeStateMachine:Initialize(stateMachineName, animatedControls, maxAlpha, fadeMilliseconds, applyRevealed, applyIdle)
    ZO_StateMachine_Base.Initialize(self, stateMachineName)

    self.animatedControls = animatedControls
    self.maxAlpha = maxAlpha
    self.fadeMilliseconds = fadeMilliseconds
    self.fadeGeneration = 0
    self.applyRevealed = applyRevealed
    self.applyIdle = applyIdle

    self.alphaAnimations = {}
    for controlIndex = 1, #animatedControls do
        local alphaAnimation = ZO_AlphaAnimation:New(animatedControls[controlIndex])
        alphaAnimation:SetMinMaxAlpha(0, maxAlpha)
        self.alphaAnimations[controlIndex] = alphaAnimation
    end

    local commands = LUIE_MINIMAP_FADE_TRIGGER_COMMANDS

    self.idleState = self:AddState("Idle")
    self.revealedState = self:AddState("Revealed")

    self:AddEdgeAutoName("Idle", "Revealed")
    self:AddEdgeAutoName("Revealed", "Idle")

    self:AddTrigger("REVEAL", ZO_StateMachine_TriggerStateCallback, commands.REVEAL)
    self:AddTrigger("FADE_COMPLETE", ZO_StateMachine_TriggerStateCallback, commands.FADE_COMPLETE)

    self:AddTriggerToEdge("REVEAL", "Idle_TO_Revealed")
    self:AddTriggerToEdge("FADE_COMPLETE", "Revealed_TO_Idle")

    self.revealedState:RegisterCallback("OnActivated", function ()
        self.applyRevealed()
    end)
    self.idleState:RegisterCallback("OnActivated", function ()
        self.applyIdle()
    end)

    self:SetCurrentState("Idle")
end

--- @return boolean
function LUIE_MiniMap_FadeStateMachine:IsRevealed()
    return self:GetCurrentState() == self.revealedState
end

--- Stops a running hold or fade. ZO_AlphaAnimation fires its OnStop callback even when stopped early, so the
--- generation count is what tells a cancelled fade from a finished one.
function LUIE_MiniMap_FadeStateMachine:CancelFade()
    self.fadeGeneration = self.fadeGeneration + 1
    for animationIndex = 1, #self.alphaAnimations do
        self.alphaAnimations[animationIndex]:Stop()
    end
end

--- Full alpha now, no fade queued. Used while the mouse is over the controls.
function LUIE_MiniMap_FadeStateMachine:Reveal()
    self:CancelFade()
    if self:IsRevealed() then
        self.applyRevealed()
        return
    end
    self:FireCallbacks(LUIE_MINIMAP_FADE_TRIGGER_COMMANDS.REVEAL)
end

--- @param holdMilliseconds number Time at full alpha before the fade starts.
function LUIE_MiniMap_FadeStateMachine:ScheduleFade(holdMilliseconds)
    if not self:IsRevealed() then
        return
    end
    self:CancelFade()
    local fadeGeneration = self.fadeGeneration
    local function OnFadeStopped()
        if self.fadeGeneration ~= fadeGeneration then
            return
        end
        self:FireCallbacks(LUIE_MINIMAP_FADE_TRIGGER_COMMANDS.FADE_COMPLETE)
    end
    -- ZO_AlphaAnimation:FadeOut scales the duration by the control's current alpha, so a 0.4 alpha label
    -- would otherwise fade in 0.4 of the configured time (EsoUI/Libraries/ZO_Animation/ZO_AlphaAnimation.lua).
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
function LUIE_MiniMap_FadeStateMachine:RevealThenFade(holdMilliseconds)
    self:Reveal()
    self:ScheduleFade(holdMilliseconds)
end

--- Back to the idle state with no animation pending.
function LUIE_MiniMap_FadeStateMachine:Shutdown()
    self:CancelFade()
    if self:IsRevealed() then
        self:FireCallbacks(LUIE_MINIMAP_FADE_TRIGGER_COMMANDS.FADE_COMPLETE)
    else
        self.applyIdle()
    end
end

-- Drag bar ---------------------------------------------------------------

LUIE_MINIMAP_DRAG_BAR_TRIGGER_COMMANDS =
{
    PADLOCK_LOCK = "PADLOCK_LOCK",
    SETTINGS_LOCK = "SETTINGS_LOCK",
    UNLOCK = "UNLOCK",
    MOUSE_ENTER = "MOUSE_ENTER",
    MOUSE_EXIT = "MOUSE_EXIT",
}

--- Padlock + drag-handle bar. Unlocked: always shown. Locked: invisible (alpha 0, still mouse enabled) until the
--- mouse enters the bar; it stays shown until the MouseIsOver update (MiniMap_Input) reports the mouse has left.
--- LockedAwaitingMouseExit keeps the bar visible right after a padlock click so the closed lock is seen.
--- @class LUIE_MiniMap_DragBarStateMachine : ZO_StateMachine_Base
--- @field frame LUIE_MiniMap_Frame
LUIE_MiniMap_DragBarStateMachine = ZO_StateMachine_Base:Subclass()

--- @param frame LUIE_MiniMap_Frame
--- @return LUIE_MiniMap_DragBarStateMachine
function LUIE_MiniMap_DragBarStateMachine:New(frame)
    local object = ZO_StateMachine_Base.New(self, frame)
    --- @cast object LUIE_MiniMap_DragBarStateMachine
    return object
end

--- @param frame LUIE_MiniMap_Frame
function LUIE_MiniMap_DragBarStateMachine:Initialize(frame)
    ZO_StateMachine_Base.Initialize(self, "LUIE_MINIMAP_DRAG_BAR_STATE_MACHINE")
    self.frame = frame

    local commands = LUIE_MINIMAP_DRAG_BAR_TRIGGER_COMMANDS

    self:AddState("Unlocked")
    self:AddState("LockedAwaitingMouseExit")
    self:AddState("LockedHidden")
    self:AddState("LockedShown")

    self:AddEdgeAutoName("Unlocked", "LockedAwaitingMouseExit")
    self:AddEdgeAutoName("Unlocked", "LockedHidden")
    self:AddEdgeAutoName("LockedAwaitingMouseExit", "LockedHidden")
    self:AddEdgeAutoName("LockedHidden", "LockedShown")
    self:AddEdgeAutoName("LockedShown", "LockedHidden")
    self:AddEdgeAutoName("LockedShown", "Unlocked")
    self:AddEdgeAutoName("LockedHidden", "Unlocked")
    self:AddEdgeAutoName("LockedAwaitingMouseExit", "Unlocked")

    self:AddTrigger("PADLOCK_LOCK", ZO_StateMachine_TriggerStateCallback, commands.PADLOCK_LOCK)
    self:AddTrigger("SETTINGS_LOCK", ZO_StateMachine_TriggerStateCallback, commands.SETTINGS_LOCK)
    self:AddTrigger("UNLOCK", ZO_StateMachine_TriggerStateCallback, commands.UNLOCK)
    self:AddTrigger("MOUSE_ENTER", ZO_StateMachine_TriggerStateCallback, commands.MOUSE_ENTER)
    self:AddTrigger("MOUSE_EXIT", ZO_StateMachine_TriggerStateCallback, commands.MOUSE_EXIT)

    self:AddTriggerToEdge("PADLOCK_LOCK", "Unlocked_TO_LockedAwaitingMouseExit")
    self:AddTriggerToEdge("SETTINGS_LOCK", "Unlocked_TO_LockedHidden")
    self:AddTriggerToEdge("MOUSE_EXIT", "LockedAwaitingMouseExit_TO_LockedHidden")
    self:AddTriggerToEdge("MOUSE_ENTER", "LockedHidden_TO_LockedShown")
    self:AddTriggerToEdge("MOUSE_EXIT", "LockedShown_TO_LockedHidden")
    self:AddTriggerToEdge("UNLOCK", "LockedShown_TO_Unlocked")
    self:AddTriggerToEdge("UNLOCK", "LockedHidden_TO_Unlocked")
    self:AddTriggerToEdge("UNLOCK", "LockedAwaitingMouseExit_TO_Unlocked")

    local stateNames =
    {
        "Unlocked",
        "LockedAwaitingMouseExit",
        "LockedHidden",
        "LockedShown",
    }
    for stateIndex = 1, #stateNames do
        local stateName = stateNames[stateIndex]
        self:GetStateByName(stateName):RegisterCallback("OnActivated", function ()
            self.frame:ApplyDragBarForStateName(stateName)
        end)
    end
end

function LUIE_MiniMap_DragBarStateMachine:Start()
    if MiniMap.SV.lockPosition == true then
        self:SetCurrentState("LockedHidden")
    else
        self:SetCurrentState("Unlocked")
    end
end

--- Settings toggle for lockPosition (padlock clicks fire PADLOCK_LOCK / UNLOCK directly from input).
function LUIE_MiniMap_DragBarStateMachine:NotifySettingsLockChanged()
    if MiniMap.SV.lockPosition == true then
        self:FireCallbacks(LUIE_MINIMAP_DRAG_BAR_TRIGGER_COMMANDS.SETTINGS_LOCK)
    else
        self:FireCallbacks(LUIE_MINIMAP_DRAG_BAR_TRIGGER_COMMANDS.UNLOCK)
    end
end
