-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

-- -----------------------------------------------------------------------------
-- * DEBUG FUNCTIONS *
-- -----------------------------------------------------------------------------
-- Slash command driven previews that exercise the same layout / static / power
-- pipelines used at runtime so debugging reflects the user's saved positions,
-- bar dimensions, label visibility, and SV-driven control toggles.
--
-- All previews mirror live data from the player so power bars, names, class
-- icon, etc. populate immediately without waiting for unrelated events.
local PREVIEW_SOURCE_UNIT = "player"

local function NotifyMissing(name)
    LUIE.AddSystemMessage(string.format("[LUIE] UnitFrames debug: '%s' frame not enabled in settings.", name))
end

-- -----------------------------------------------------------------------------
-- Shared helpers
-- -----------------------------------------------------------------------------

-- Re-applies SV-backed (or dynamic-default) anchors to every custom TLW.
local function ApplyPositions()
    if UnitFrames.CustomFramesSetPositions then
        UnitFrames.CustomFramesSetPositions()
    end
end

-- Pushes live attribute values from `sourceUnitTag` into every numeric power
-- key on the supplied frame, exactly like UnitFrames.OnPowerUpdate would on a
-- real EVENT_POWER_UPDATE for that unit.
local function PushPowerValues(frame, sourceUnitTag)
    if not frame then return end
    for powerType, control in pairs(frame) do
        if type(powerType) == "number" and control then
            local powerValue, _, powerEffectiveMax = GetUnitPower(sourceUnitTag, powerType)
            UnitFrames.UpdateAttribute(sourceUnitTag, powerType, control, powerValue, powerEffectiveMax, false, nil)
        end
    end
end

-- Sets the preview unitTag and refreshes name labels, class icon, role icon,
-- AVA rank, etc. through the same path the runtime uses.
local function RefreshFrameStatics(frame, sourceUnitTag)
    if not frame then return end
    frame.unitTag = sourceUnitTag
    UnitFrames.UpdateStaticControls(frame)
end

-- Unhides both the TLW and the inner control. Layout functions only flip the
-- TLW when called with unhide=true; we always pass false so we can pick which
-- frames within a shared layout group become visible.
local function ShowFrame(frame)
    if not frame then return end
    if frame.tlw then frame.tlw:SetHidden(false) end
    if frame.control then frame.control:SetHidden(false) end
end

local function PreviewFrame(frame, sourceUnitTag)
    if not frame then return end
    ShowFrame(frame)
    RefreshFrameStatics(frame, sourceUnitTag)
    PushPowerValues(frame, sourceUnitTag)
end

-- -----------------------------------------------------------------------------
-- Single-frame previews
-- -----------------------------------------------------------------------------

local function DebugPlayer()
    local frame = UnitFrames.CustomFrames["player"]
    if not frame then
        NotifyMissing("player")
        return
    end
    ApplyPositions()
    UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
    PreviewFrame(frame, PREVIEW_SOURCE_UNIT)
end

local function DebugTarget()
    local frame = UnitFrames.CustomFrames["reticleover"]
    if not frame then
        NotifyMissing("reticleover")
        return
    end
    ApplyPositions()
    UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
    PreviewFrame(frame, PREVIEW_SOURCE_UNIT)
end

local function DebugAva()
    local frame = UnitFrames.CustomFrames["AvaPlayerTarget"]
    if not frame then
        NotifyMissing("AvaPlayerTarget")
        return
    end
    ApplyPositions()
    UnitFrames.CustomFramesApplyLayoutAvaPlayerTargetFrame(false)
    PreviewFrame(frame, PREVIEW_SOURCE_UNIT)
end

local function DebugCompanion()
    local frame = UnitFrames.CustomFrames["companion"]
    if not frame then
        NotifyMissing("companion")
        return
    end
    ApplyPositions()
    UnitFrames.CustomFramesApplyLayoutCompanion(false)
    PreviewFrame(frame, PREVIEW_SOURCE_UNIT)
end

local function DebugGroup()
    local first = UnitFrames.CustomFrames["SmallGroup1"]
    if not first then
        NotifyMissing("SmallGroup")
        return
    end
    ApplyPositions()
    UnitFrames.CustomFramesApplyLayoutGroup(false)
    if first.tlw then first.tlw:SetHidden(false) end
    for i = 1, 4 do
        PreviewFrame(UnitFrames.CustomFrames["SmallGroup" .. i], PREVIEW_SOURCE_UNIT)
    end
    UnitFrames.OnLeaderUpdate(nil, "SmallGroup1")
end

local function DebugRaid()
    local first = UnitFrames.CustomFrames["RaidGroup1"]
    if not first then
        NotifyMissing("RaidGroup")
        return
    end
    ApplyPositions()
    UnitFrames.CustomFramesApplyLayoutRaid(false, true)
    if first.tlw then first.tlw:SetHidden(false) end
    for i = 1, 12 do
        PreviewFrame(UnitFrames.CustomFrames["RaidGroup" .. i], PREVIEW_SOURCE_UNIT)
    end
    UnitFrames.OnLeaderUpdate(nil, "RaidGroup1")
end

local function DebugPets()
    local first = UnitFrames.CustomFrames["PetGroup1"]
    if not first then
        NotifyMissing("PetGroup")
        return
    end
    ApplyPositions()
    UnitFrames.CustomFramesApplyLayoutPet(false)
    if first.tlw then first.tlw:SetHidden(false) end
    for i = 1, 7 do
        PreviewFrame(UnitFrames.CustomFrames["PetGroup" .. i], PREVIEW_SOURCE_UNIT)
    end
end

local function DebugBosses()
    local first = UnitFrames.CustomFrames["boss1"]
    if not first then
        NotifyMissing("boss")
        return
    end
    ApplyPositions()
    -- CustomFramesApplyLayoutBosses already unhides the boss TLW at the end;
    -- still safe to call ShowFrame on each child to flip their controls.
    UnitFrames.CustomFramesApplyLayoutBosses()
    for i = 1, 7 do
        PreviewFrame(UnitFrames.CustomFrames["boss" .. i], PREVIEW_SOURCE_UNIT)
    end
    UnitFrames.ApplyBossThresholdMarkersSlashDebugPreview()
end

-- -----------------------------------------------------------------------------
-- Toggle-all
-- -----------------------------------------------------------------------------

UnitFrames.debugAllActive = UnitFrames.debugAllActive or false

local function EnableAllPreviews()
    DebugPlayer()
    DebugTarget()
    DebugAva()
    DebugCompanion()
    DebugGroup()
    DebugRaid()
    DebugPets()
    DebugBosses()
end

-- Restores game-driven state by routing through the same public refresh
-- functions runtime uses. Avoids duplicating hide/clear logic.
local function DisableAllPreviews()
    if UnitFrames.CustomFrames["player"] and UnitFrames.ReloadValues then
        UnitFrames.ReloadValues("player")
    end

    if UnitFrames.CustomFrames["reticleover"] or UnitFrames.CustomFrames["AvaPlayerTarget"] then
        if DoesUnitExist("reticleover") and UnitFrames.OnReticleTargetChanged then
            UnitFrames.OnReticleTargetChanged(nil)
        elseif UnitFrames.ClearTargetFrame then
            UnitFrames.ClearTargetFrame()
        end
    end

    if UnitFrames.CustomFrames["companion"] and UnitFrames.CompanionUpdate then
        UnitFrames.CompanionUpdate()
    end

    if UnitFrames.CustomFrames["PetGroup1"] and UnitFrames.CustomPetUpdate then
        UnitFrames.CustomPetUpdate()
    end

    if (UnitFrames.CustomFrames["SmallGroup1"] or UnitFrames.CustomFrames["RaidGroup1"]) and UnitFrames.CustomFramesGroupUpdate then
        UnitFrames.CustomFramesGroupUpdate()
    end

    if UnitFrames.CustomFrames["boss1"] and UnitFrames.OnBossesChanged then
        UnitFrames.OnBossesChanged(nil)
    end
end

local function DebugAll()
    UnitFrames.debugAllActive = not UnitFrames.debugAllActive
    if UnitFrames.debugAllActive then
        UnitFrames.debugAllCapturedMovingState = UnitFrames.CustomFramesMovingState == true
        EnableAllPreviews()
        UnitFrames.CustomFramesSetMovingState(true)
    else
        local revertMoving = UnitFrames.debugAllCapturedMovingState == true
        UnitFrames.debugAllCapturedMovingState = nil
        DisableAllPreviews()
        UnitFrames.CustomFramesSetMovingState(revertMoving)
    end
end

-- -----------------------------------------------------------------------------
-- Slash command registration
-- -----------------------------------------------------------------------------

local DEBUG_COMMANDS =
{
    ["/luiufsm"]     = DebugGroup,
    ["/luiufraid"]   = DebugRaid,
    ["/luiufplayer"] = DebugPlayer,
    ["/luiuftar"]    = DebugTarget,
    ["/luiufava"]    = DebugAva,
    ["/luiufpet"]    = DebugPets,
    ["/luiufboss"]   = DebugBosses,
    ["/luiufcomp"]   = DebugCompanion,
    ["/luiufall"]    = DebugAll,
}

for command, handler in pairs(DEBUG_COMMANDS) do
    SLASH_COMMANDS[command] = handler
end
