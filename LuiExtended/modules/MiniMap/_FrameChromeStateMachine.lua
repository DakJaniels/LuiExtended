-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

MINIMAP_FRAME_CHROME_TRIGGER_COMMANDS =
{
    PADLOCK_LOCK = "PADLOCK_LOCK",
    SETTINGS_LOCK = "SETTINGS_LOCK",
    UNLOCK = "UNLOCK",
    POINTER_ENTER = "POINTER_ENTER",
    POINTER_EXIT = "POINTER_EXIT",
}

--- @class MiniMapFrameChromeStateMachine : ZO_StateMachine_Base
MiniMapFrameChromeStateMachine = ZO_StateMachine_Base:Subclass()
MiniMap.MiniMapFrameChromeStateMachine = MiniMapFrameChromeStateMachine

--- @return MiniMapFrameChromeStateMachine
function MiniMapFrameChromeStateMachine:New()
    local object = ZO_StateMachine_Base.New(self)
    --- @cast object MiniMapFrameChromeStateMachine
    object:Initialize()
    return object
end

function MiniMapFrameChromeStateMachine:Initialize()
    ZO_StateMachine_Base.Initialize(self, "MINIMAP_FRAME_CHROME_STATE_MACHINE")

    local commands = MINIMAP_FRAME_CHROME_TRIGGER_COMMANDS

    self:AddState("Unlocked")
    self:AddState("LockedAwaitingPointerExit")
    self:AddState("LockedHidden")
    self:AddState("LockedShown")

    self:AddEdgeAutoName("Unlocked", "LockedAwaitingPointerExit")
    self:AddEdgeAutoName("Unlocked", "LockedHidden")
    self:AddEdgeAutoName("LockedAwaitingPointerExit", "LockedHidden")
    self:AddEdgeAutoName("LockedHidden", "LockedShown")
    self:AddEdgeAutoName("LockedShown", "LockedHidden")
    self:AddEdgeAutoName("LockedShown", "Unlocked")
    self:AddEdgeAutoName("LockedHidden", "Unlocked")
    self:AddEdgeAutoName("LockedAwaitingPointerExit", "Unlocked")

    self:AddTrigger("PADLOCK_LOCK", ZO_StateMachine_TriggerStateCallback, commands.PADLOCK_LOCK)
    self:AddTrigger("SETTINGS_LOCK", ZO_StateMachine_TriggerStateCallback, commands.SETTINGS_LOCK)
    self:AddTrigger("UNLOCK", ZO_StateMachine_TriggerStateCallback, commands.UNLOCK)
    self:AddTrigger("POINTER_ENTER", ZO_StateMachine_TriggerStateCallback, commands.POINTER_ENTER)
    self:AddTrigger("POINTER_EXIT", ZO_StateMachine_TriggerStateCallback, commands.POINTER_EXIT)

    self:AddTriggerToEdge("PADLOCK_LOCK", "Unlocked_TO_LockedAwaitingPointerExit")
    self:AddTriggerToEdge("SETTINGS_LOCK", "Unlocked_TO_LockedHidden")
    self:AddTriggerToEdge("POINTER_EXIT", "LockedAwaitingPointerExit_TO_LockedHidden")
    self:AddTriggerToEdge("POINTER_ENTER", "LockedHidden_TO_LockedShown")
    self:AddTriggerToEdge("POINTER_EXIT", "LockedShown_TO_LockedHidden")
    self:AddTriggerToEdge("UNLOCK", "LockedShown_TO_Unlocked")
    self:AddTriggerToEdge("UNLOCK", "LockedHidden_TO_Unlocked")
    self:AddTriggerToEdge("UNLOCK", "LockedAwaitingPointerExit_TO_Unlocked")

    local stateMachine = self
    local stateNames =
    {
        "Unlocked",
        "LockedAwaitingPointerExit",
        "LockedHidden",
        "LockedShown",
    }
    for stateIndex = 1, #stateNames do
        local stateName = stateNames[stateIndex]
        self:GetStateByName(stateName):RegisterCallback("OnActivated", function ()
            stateMachine:ApplyFrameChromeForStateName(stateName)
        end)
    end
end

--- @param stateName string
function MiniMapFrameChromeStateMachine:ApplyFrameChromeForStateName(stateName)
    local view = MiniMap.view
    if not view or not view.root then
        return
    end
    local positionLocked = stateName ~= "Unlocked"
    local chromeShown = stateName == "Unlocked" or stateName == "LockedShown"
    local padlockState = TOGGLE_BUTTON_OPEN
    if positionLocked then
        padlockState = TOGGLE_BUTTON_CLOSED
    end
    local lockButton = view.framePositionLock
    if lockButton then
        ZO_ToggleButton_SetState(lockButton, padlockState)
    end
    local moveGrip = view.frameMoveGrip
    if moveGrip then
        moveGrip:SetHidden(positionLocked)
        moveGrip:SetMouseEnabled(not positionLocked)
    end
    local frameChrome = view.frameChrome
    if frameChrome then
        frameChrome:SetHidden(not chromeShown)
    end
    view.root:SetMovable(not positionLocked)
end

function MiniMapFrameChromeStateMachine:Start()
    if MiniMap.SV and MiniMap.SV.lockPosition == true then
        self:SetCurrentState("LockedHidden")
    else
        self:SetCurrentState("Unlocked")
    end
end

function MiniMapFrameChromeStateMachine:NotifySettingsLockChanged()
    if MiniMap.SV and MiniMap.SV.lockPosition == true then
        self:FireCallbacks(MINIMAP_FRAME_CHROME_TRIGGER_COMMANDS.SETTINGS_LOCK)
    else
        self:FireCallbacks(MINIMAP_FRAME_CHROME_TRIGGER_COMMANDS.UNLOCK)
    end
end
