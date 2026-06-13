-- -----------------------------------------------------------------------------
--  LuiExtended - Suppress vanilla ZO UnitFrames / PlayerAttributeBars when LUIE
--  custom frames replace them (see UnitFrames.ApplyZOUnitFrameSuppression).
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

local eventManager = GetEventManager()

--- Stacks with other addons (e.g. Death Recap "deathRecap") via ZO_HiddenReasons.
UnitFrames.ZO_FRAME_SUPPRESSION_HIDDEN_REASON = "LUIE_CustomFramesReplace"

local PLAYER_ATTRIBUTE_BAR_SUFFIXES =
{
    "Health",
    "Stamina",
    "Magicka",
    "MountStamina",
    "Werewolf",
    "SiegeHealth",
}

function UnitFrames.ShouldSuppressZOPlayerAttributeBars()
    if not UnitFrames.SV.SuppressZOPlayerAttributeBarsWhenReplaced then
        return false
    end
    if UnitFrames.SV.DefaultFramesNewPlayer ~= 1 then
        return false
    end
    return UnitFrames.CustomFrames["player"] ~= nil
end

function UnitFrames.ShouldSuppressZOTarget()
    if not UnitFrames.SV.SuppressZOTargetFrameWhenReplaced then
        return false
    end
    if UnitFrames.SV.DefaultFramesNewTarget ~= 1 then
        return false
    end
    return UnitFrames.CustomFrames["reticleover"] ~= nil
end

function UnitFrames.ShouldSuppressZOGroup()
    if not UnitFrames.SV.SuppressZOGroupFramesWhenReplaced then
        return false
    end
    if UnitFrames.SV.DefaultFramesNewGroup ~= 1 then
        return false
    end
    local hasSmallGroup = UnitFrames.SV.CustomFramesGroup and UnitFrames.CustomFrames["SmallGroup1"] ~= nil
    local hasRaidGroup = UnitFrames.SV.CustomFramesRaid and UnitFrames.CustomFrames["RaidGroup1"] ~= nil
    return hasSmallGroup or hasRaidGroup
end

function UnitFrames.ShouldSuppressZOCompanion()
    if not UnitFrames.SV.SuppressZOCompanionFrameWhenReplaced then
        return false
    end
    if not UnitFrames.SV.CustomFramesCompanion then
        return false
    end
    return UnitFrames.CustomFrames["companion"] ~= nil
end

local function VanillaUnitFramesPowerHandlerStillNeeded()
    if not UnitFrames.ShouldSuppressZOTarget() then
        return true
    end
    if not UnitFrames.ShouldSuppressZOGroup() then
        return true
    end
    if not UnitFrames.ShouldSuppressZOCompanion() then
        return true
    end
    return false
end

function UnitFrames.ShouldUnregisterZOUnitFramesControlEvents()
    return UnitFrames.ShouldSuppressZOTarget()
        and UnitFrames.ShouldSuppressZOGroup()
        and UnitFrames.ShouldSuppressZOCompanion()
end

function UnitFrames.SuppressZOPlayerAttributeBars()
    for suffixIndex = 1, #PLAYER_ATTRIBUTE_BAR_SUFFIXES do
        local suffix = PLAYER_ATTRIBUTE_BAR_SUFFIXES[suffixIndex]
        local controlName = "ZO_PlayerAttribute" .. suffix
        local frame = _G[controlName]
        if frame then
            eventManager:UnregisterForAllEvents(controlName)
            eventManager:UnregisterForUpdate(controlName .. "FadeUpdate")
            frame:SetHidden(true)
        end
    end

    if ZO_PlayerAttribute then
        eventManager:UnregisterForAllEvents("ZO_PlayerAttribute")
        ZO_PlayerAttribute:SetHidden(true)
    end
end

function UnitFrames.UnregisterZOUnitFramesPowerHandlerIfUnused()
    if VanillaUnitFramesPowerHandlerStillNeeded() then
        return
    end
    eventManager:UnregisterForAllEvents("UnitFrames")
    eventManager:UnregisterForUpdate("UnitFrames")
end

function UnitFrames.UnregisterZOUnitFramesControlEventsIfFullySuppressed()
    if not UnitFrames.ShouldUnregisterZOUnitFramesControlEvents() then
        return
    end
    eventManager:UnregisterForAllEvents("ZO_UnitFrames")
end

local function ApplyVanillaTargetFrameSuppression()
    if not UnitFrames.ShouldSuppressZOTarget() then
        return
    end
    local hiddenReason = UnitFrames.ZO_FRAME_SUPPRESSION_HIDDEN_REASON
    if UNIT_FRAMES then
        UNIT_FRAMES:SetFrameHiddenForReason("reticleover", hiddenReason, true)
    end
    if ZO_TargetUnitFramereticleover then
        ZO_TargetUnitFramereticleover:SetHidden(true)
    end
end

local function ApplyVanillaCompanionFrameSuppression()
    if not UnitFrames.ShouldSuppressZOCompanion() then
        return
    end
    local hiddenReason = UnitFrames.ZO_FRAME_SUPPRESSION_HIDDEN_REASON
    if UNIT_FRAMES then
        UNIT_FRAMES:SetFrameHiddenForReason("companion", hiddenReason, true)
    end
end

--- Hide vanilla group/raid UI when LUIE custom group frames are active for the current group layout.
--- @param groupSize integer?
function UnitFrames.HideVanillaGroupAndRaidFramesForCustomFrames(groupSize)
    groupSize = groupSize or GetGroupSize()
    local layoutUsesCustomGroupFrames = false
    if UnitFrames.SV.CustomFramesGroup and groupSize <= 4 then
        layoutUsesCustomGroupFrames = true
    elseif UnitFrames.SV.CustomFramesRaid then
        if groupSize > 4 or (not UnitFrames.CustomFrames["SmallGroup1"] and UnitFrames.CustomFrames["RaidGroup1"]) then
            layoutUsesCustomGroupFrames = true
        end
    end
    if not layoutUsesCustomGroupFrames or not UnitFrames.ShouldSuppressZOGroup() then
        return
    end
    if ZO_UnitFramesGroups then
        ZO_UnitFramesGroups:SetHidden(true)
    end
    local hiddenReason = UnitFrames.ZO_FRAME_SUPPRESSION_HIDDEN_REASON
    if UNIT_FRAMES then
        UNIT_FRAMES:SetGroupAndRaidFramesHiddenForReason(hiddenReason, true)
        UNIT_FRAMES:DisableGroupAndRaidFrames()
    end
end

function UnitFrames.ApplyZOUnitFrameSuppression()
    if UNIT_FRAMES == nil and ZO_UnitFrames == nil then
        return
    end

    if UnitFrames.ShouldSuppressZOPlayerAttributeBars() then
        UnitFrames.SuppressZOPlayerAttributeBars()
    end

    ApplyVanillaTargetFrameSuppression()
    ApplyVanillaCompanionFrameSuppression()
    UnitFrames.HideVanillaGroupAndRaidFramesForCustomFrames(GetGroupSize())

    UnitFrames.UnregisterZOUnitFramesControlEventsIfFullySuppressed()
    UnitFrames.UnregisterZOUnitFramesPowerHandlerIfUnused()
end

local function OnUnitFramesCreated()
    UnitFrames.ApplyZOUnitFrameSuppression()
end

CALLBACK_MANAGER:RegisterCallback("UnitFramesCreated", OnUnitFramesCreated)
