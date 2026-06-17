-- -----------------------------------------------------------------------------
--  LuiExtended — ActionBar cast bar LibCombat integration
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar
--- @class (partial) LUIE.ActionBar.CastBar
local CastBar = ActionBar.CastBar

local string_format = string.format

local LuiData = LuiData
local Castbar = LuiData.Data.CastBarTable

local LibCombat = LibCombat
local OtherAddonCompatability = LUIE.OtherAddonCompatability
local Private = CastBar.Private

local SKILL_SLOT_LIGHT_ATTACK = 1
-- Match LibCombat LIBCOMBAT_SKILLSTATUS_* (do not use globals at file load; LibCombat may be absent).
local SKILLSTATUS_INSTANT = 1
local SKILLSTATUS_BEGIN_DURATION = 2
local SKILLSTATUS_BEGIN_CHANNEL = 3
local SKILLSTATUS_SUCCESS = 4
local SKILLSTATUS_REGISTERED = 5
local SKILLSTATUS_QUEUE = 6
local WEAVE_OFFSET_MIN_MS = 400
local WEAVE_GAP_STALE_MS = 3000
local INSTANT_CAST_PLACEHOLDER_MS = 1000
local MIN_HARD_CAST_DISPLAY_MS = 1000

local g_skillTimingsRegistered = false
local g_castBarSlotPressMs = {}
local g_castBarQueuedPressMs = {}
local g_castBarLastSkillEndMs = 0
local g_castBarWeaveAfterLightAttack = false

local WEAVE_EDGE_DEFAULT = { 0, 0, 0, 0.6 }
local WEAVE_EDGE_GOOD = ZO_ColorDef:New(0, 0.95, 0.1)
local WEAVE_EDGE_SLOW = ZO_ColorDef:New(1, 1, 0)
local WEAVE_EDGE_BAD = ZO_ColorDef:New(1, 0, 0)

local LOG_PREFIX = "[CastBar LibCombat] "
local g_castBarLibCombatDevDebugLog = false

function CastBar.SetLibCombatDevDebugLogCache(enabled)
    g_castBarLibCombatDevDebugLog = enabled == true
end

-- LibCombat globals may be absent when the library addon is not loaded; use numeric ids from LibCombat.lua.
local SKILL_STATUS_LABEL =
{
    [1] = "INSTANT",
    [2] = "BEGIN_DURATION",
    [3] = "BEGIN_CHANNEL",
    [4] = "SUCCESS",
    [5] = "REGISTERED",
    [6] = "QUEUE",
}

local function libCombatSkillTimingsEventType()
    return LIBCOMBAT_EVENT_SKILL_TIMINGS or 19
end

-- local function logCastBarLibCombat(message, ...)
--     if not g_castBarLibCombatDevDebugLog then
--         return
--     end
--     LUIE:Log("Verbose", LOG_PREFIX .. string_format(message, ...))
-- end

-- local function formatAbilityRefForLog(abilityId)
-- local formatter = Private.FormatAbilityRefForLog
-- if formatter then
-- return formatter(abilityId)
-- end
-- return tostring(abilityId)
-- end

local function castBarUi()
    return Private.GetState().bar
end

--- Pre-clear press-time keys used as `reducedSlot` in SKILL_TIMINGS callbacks.
--- LibCombat uses `(weaponBar - 1) * 10 + slot` (3–8 active bar, 13–18 other weapon bar) — not LUIE UI slot 53+.
--- LUIE backbar action slots 53–57 are cleared in case any event supplies raw slot indices.
local function resetCastBarSlotPressTracking()
    for slotIndex = ActionBar.BAR_INDEX_START, ActionBar.BAR_INDEX_END do
        g_castBarSlotPressMs[slotIndex] = 0
        g_castBarSlotPressMs[slotIndex + 10] = 0
    end
    for slotIndex = ActionBar.BAR_INDEX_START, ActionBar.BACKBAR_INDEX_END do
        g_castBarSlotPressMs[slotIndex + ActionBar.BACKBAR_INDEX_OFFSET] = 0
    end
    g_castBarLastSkillEndMs = 0
    g_castBarWeaveAfterLightAttack = false
    g_castBarQueuedPressMs = {}
end

function CastBar.GetWeaveLineWidth()
    -- LibCombat defines LIBCOMBAT_LINE_SIZE at load (see LibCombat.lua); optional dep ensures order when present.
    if LIBCOMBAT_LINE_SIZE ~= nil then
        return tostring(LIBCOMBAT_LINE_SIZE)
    end
    return "1"
end

function CastBar.UpdateWeaveLineDimensions()
    local bar = castBarUi()
    if not bar or not bar.lineLA then
        return
    end
    local w, h = CastBar.GetWeaveLineWidth(), ActionBar.SV.CastBarSizeH
    bar.lineLA:SetDimensions(w, h)
    bar.lineSkill:SetDimensions(w, h)
    bar.lineDelay:SetDimensions(w, h)
end

function CastBar.ResetWeaveBackdropEdge()
    local bar = castBarUi()
    local backdrop = bar and bar.backdrop
    if backdrop then
        backdrop:SetEdgeColor(WEAVE_EDGE_DEFAULT[1], WEAVE_EDGE_DEFAULT[2], WEAVE_EDGE_DEFAULT[3], WEAVE_EDGE_DEFAULT[4])
    end
end

function CastBar.HideWeaveLines()
    local bar = castBarUi()
    if bar and bar.lineLA then
        bar.lineLA:SetHidden(true)
        bar.lineSkill:SetHidden(true)
        bar.lineDelay:SetHidden(true)
    end
    CastBar.ResetWeaveBackdropEdge()
end

function CastBar.UnregisterLibCombatEvents()
    if OtherAddonCompatability.isLibCombatEnabled and LibCombat and LibCombat.UnregisterForCombatEvent then
        LibCombat:UnregisterForCombatEvent(Private.moduleName, libCombatSkillTimingsEventType())
        -- logCastBarLibCombat("Unregister SKILL_TIMINGS (%s)", Private.moduleName)
    end
    g_skillTimingsRegistered = false
    Private.SetLibCombatTimingsActive(false)
    resetCastBarSlotPressTracking()
    -- logCastBarLibCombat("LibCombat timings inactive")
end

--- Call `CastBar.UnregisterLibCombatEvents()` first (e.g. via `CastBar.RegisterEvents` / `UnregisterEvents`).
function CastBar.RegisterLibCombatEvents()
    if not OtherAddonCompatability.isLibCombatEnabled then
        CastBar.UnregisterLibCombatEvents()
        -- logCastBarLibCombat("Register skipped: LibCombat addon not enabled")
        return
    end
    if not ActionBar.SV.CastBarEnable then
        CastBar.UnregisterLibCombatEvents()
        -- logCastBarLibCombat("Register skipped: CastBarEnable is false")
        return
    end
    if not ActionBar.SV.CastBarWeaveHelper then
        CastBar.UnregisterLibCombatEvents()
        -- logCastBarLibCombat("SKILL_TIMINGS not registered (weave helper off; cast bar uses combat events)")
        return
    end
    CastBar.UnregisterLibCombatEvents()
    resetCastBarSlotPressTracking()
    if not LibCombat or not LibCombat.RegisterForCombatEvent then
        -- logCastBarLibCombat("Register skipped: LibCombat API missing")
        return
    end
    local registered = LibCombat:RegisterForCombatEvent(Private.moduleName, libCombatSkillTimingsEventType(), CastBar.OnLibCombatSkillTimings)
    g_skillTimingsRegistered = registered == true
    Private.SetLibCombatTimingsActive(g_skillTimingsRegistered)
    -- logCastBarLibCombat("Register SKILL_TIMINGS (%s) ok=%s", Private.moduleName, tostring(g_skillTimingsRegistered))
end

--- Toggle weave UI + LibCombat SKILL_TIMINGS without full cast bar event teardown.
function CastBar.OnWeaveHelperSettingChanged()
    if not ActionBar.SV.CastBarWeaveHelper then
        CastBar.HideWeaveLines()
        CastBar.UnregisterLibCombatEvents()
        -- logCastBarLibCombat("Weave helper disabled")
        return
    end
    if not ActionBar.SV.CastBarEnable or not OtherAddonCompatability.isLibCombatEnabled then
        return
    end
    CastBar.RegisterLibCombatEvents()
    -- logCastBarLibCombat("Weave helper enabled")
end

local function setWeaveLineOnProgress(barControl, lineControl)
    local barMin, barMax = barControl:GetMinMax()
    local barSpan = barMax - barMin
    if barSpan <= 0 then
        return
    end
    local x = (barControl:GetValue() / barSpan) * barControl:GetWidth()
    lineControl:ClearAnchors()
    lineControl:SetAnchor(TOP, barControl, TOPLEFT, x, 0)
    lineControl:SetAnchor(BOTTOM, barControl, BOTTOMLEFT, x, 0)
end

local function weaveMarkersEnabled()
    return g_skillTimingsRegistered and ActionBar.SV.CastBarWeaveHelper
end

local function markSlotRegistered(timems, reducedSlot, slotIndex)
    g_castBarSlotPressMs[reducedSlot] = timems
    -- logCastBarLibCombat("REGISTERED reducedSlot=%s slotIndex=%s timems=%s", reducedSlot, slotIndex, timems)
    if not weaveMarkersEnabled() or not Private.IsCasting() then
        return
    end
    local bar = castBarUi()
    local barControl = bar and bar.bar
    if not barControl then
        return
    end
    local line = slotIndex == SKILL_SLOT_LIGHT_ATTACK and bar.lineLA or bar.lineSkill
    if not line then
        return
    end
    setWeaveLineOnProgress(barControl, line)
    line:SetAlpha(1)
    line:SetHidden(false)
end

local function ageWeaveMarkers()
    if not weaveMarkersEnabled() then
        return
    end
    local bar = castBarUi()
    if not bar or not bar.lineLA then
        return
    end
    for _, line in ipairs({ bar.lineLA, bar.lineSkill }) do
        if line:GetAlpha() < 0.9 then
            line:SetAlpha(0)
        else
            line:SetAlpha(0.8)
        end
    end
end

local function updateWeaveDelayMarker(timems, durationMs, abilityId, reducedSlot)
    if not weaveMarkersEnabled() then
        return
    end
    local bar = castBarUi()
    if not bar or not bar.bar or not bar.backdrop or not bar.lineDelay then
        return
    end
    local barControl = bar.bar
    local castEndMs = timems + durationMs
    local pressMs = zo_max(g_castBarSlotPressMs[reducedSlot] or 0, g_castBarQueuedPressMs[abilityId] or 0)
    local offsetEndMs = pressMs > 0 and (pressMs + durationMs) or castEndMs
    if offsetEndMs <= timems + WEAVE_OFFSET_MIN_MS then
        bar.lineDelay:SetHidden(true)
        -- logCastBarLibCombat("Weave delay hidden (offsetEndMs=%s <= min)", offsetEndMs)
        return
    end
    local rel = zo_clamp((offsetEndMs - timems) / (castEndMs - timems), 0, 1)
    local gapMs = 0
    if g_castBarLastSkillEndMs > 0 then
        gapMs = zo_max(0, timems - g_castBarLastSkillEndMs)
        if gapMs > WEAVE_GAP_STALE_MS then
            gapMs = 0
            g_castBarLastSkillEndMs = 0
            g_castBarWeaveAfterLightAttack = false
        end
    end
    local thresholdMs = ActionBar.SV.CastBarWeaveThresholdMs or 80
    local edge = g_castBarWeaveAfterLightAttack
        and (gapMs < thresholdMs and WEAVE_EDGE_GOOD or WEAVE_EDGE_SLOW)
        or WEAVE_EDGE_BAD
    local gcdRemainMs = select(1, CastBar.GetGcdSlotCooldownMs())
    local inputLagMs = CastBar.GetCastBarInputLagMs()
    if gcdRemainMs > inputLagMs then
        edge = WEAVE_EDGE_SLOW
    end
    local state = Private.GetState()
    state.weaveDelayRel = rel
    state.weaveGapEdge = edge
    local displayRel = rel
    if gcdRemainMs > inputLagMs and castEndMs > timems then
        displayRel = zo_max(rel, zo_min(1, (offsetEndMs - timems + gcdRemainMs) / (castEndMs - timems + gcdRemainMs)))
    end
    local x = barControl:GetWidth() * displayRel
    bar.lineDelay:ClearAnchors()
    bar.lineDelay:SetAnchor(TOP, barControl, TOPLEFT, x, 0)
    bar.lineDelay:SetAnchor(BOTTOM, barControl, BOTTOMLEFT, x, 0)
    bar.lineDelay:SetHidden(false)
    local r, g, b = edge:UnpackRGB()
    bar.backdrop:SetEdgeColor(r, g, b, 1)
    -- logCastBarLibCombat("Weave delay shown ability=%s reducedSlot=%s rel=%.2f displayRel=%.2f gapMs=%s gcdRemainMs=%s afterLA=%s", formatAbilityRefForLog(abilityId), reducedSlot, rel, displayRel, gapMs, gcdRemainMs, tostring(g_castBarWeaveAfterLightAttack))
end

local function durationMsFromSkillTiming(abilityId, skillStatus, skillDuration)
    if skillStatus == SKILLSTATUS_INSTANT then
        return CastBar.ComputeCastDurationMs(abilityId, ACTION_RESULT_BEGIN, INSTANT_CAST_PLACEHOLDER_MS, false, INSTANT_CAST_PLACEHOLDER_MS), false
    end
    if skillStatus ~= SKILLSTATUS_BEGIN_DURATION and skillStatus ~= SKILLSTATUS_BEGIN_CHANNEL then
        return 0, false
    end
    local channeled = skillStatus == SKILLSTATUS_BEGIN_CHANNEL
    local _, durationValue = GetAbilityCastInfo(abilityId)
    if skillDuration and skillDuration > 0 then
        durationValue = skillDuration
    end
    local durationMs = CastBar.ComputeCastDurationMs(
        abilityId,
        channeled and ACTION_RESULT_EFFECT_GAINED_DURATION or ACTION_RESULT_BEGIN,
        durationValue or 0,
        channeled,
        durationValue or skillDuration or 0)
    if not channeled and (durationValue or 0) > 0 and durationMs > 0 then
        durationMs = zo_max(durationMs, MIN_HARD_CAST_DISPLAY_MS)
    end
    return durationMs, channeled
end

function CastBar.OnLibCombatSkillTimings(_, timems, reducedSlot, abilityId, skillStatus, skillDelay, skillDuration)
    if not ActionBar.SV.CastBarEnable or not g_skillTimingsRegistered then
        return
    end

    local slotIndex = reducedSlot % 10
    local statusLabel = SKILL_STATUS_LABEL[skillStatus] or tostring(skillStatus)
    -- logCastBarLibCombat("SKILL_TIMINGS %s ability=%s reducedSlot=%s slotIndex=%s timems=%s skillDelay=%s skillDuration=%s", statusLabel, formatAbilityRefForLog(abilityId), reducedSlot, slotIndex, timems, tostring(skillDelay), tostring(skillDuration))

    if skillStatus == SKILLSTATUS_REGISTERED then
        markSlotRegistered(timems, reducedSlot, slotIndex)
        return
    end

    if skillStatus == SKILLSTATUS_QUEUE then
        g_castBarQueuedPressMs[abilityId] = timems
        -- logCastBarLibCombat("QUEUE ability=%s timems=%s", formatAbilityRefForLog(abilityId), timems)
        return
    end

    if skillStatus == SKILLSTATUS_SUCCESS then
        -- logCastBarLibCombat("SUCCESS ignored ability=%s", formatAbilityRefForLog(abilityId))
        return
    end

    if slotIndex == SKILL_SLOT_LIGHT_ATTACK then
        g_castBarWeaveAfterLightAttack = true
        -- logCastBarLibCombat("Light attack weave flag set")
        return
    end

    local icon, name = CastBar.GetCastDisplayNameAndIcon(abilityId)
    if not CastBar.ShouldShowOnCastBar(abilityId, name) then
        -- logCastBarLibCombat("Filtered from cast bar: ability=%s", formatAbilityRefForLog(abilityId))
        return
    end

    local durationMs, channeled = durationMsFromSkillTiming(abilityId, skillStatus, skillDuration)
    if durationMs <= 0 then
        -- logCastBarLibCombat("durationMs<=0 ability=%s status=%s", formatAbilityRefForLog(abilityId), statusLabel)
        return
    end

    -- logCastBarLibCombat("ShowCast LibCombat ability=%s durationMs=%s channeled=%s", formatAbilityRefForLog(abilityId), durationMs, tostring(channeled))
    CastBar.ShowCast(abilityId, timems, durationMs, channeled, icon, name, true)
    ageWeaveMarkers()
    updateWeaveDelayMarker(timems, durationMs, abilityId, reducedSlot)

    g_castBarWeaveAfterLightAttack = false
    g_castBarLastSkillEndMs = timems + durationMs
end
