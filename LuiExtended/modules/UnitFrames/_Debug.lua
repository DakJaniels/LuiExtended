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

UnitFrames.debugAttributeVisualOverrides = UnitFrames.debugAttributeVisualOverrides or {}

local function VisualEffectCacheKey(visualType, statType, attributeType, powerType)
    return string.format("%d_%d_%d_%d", visualType, statType, attributeType, powerType)
end

local function SetDebugVisualOverride(visualUnitTag, visualType, statType, attributeType, powerType, value)
    UnitFrames.debugAttributeVisualOverrides[visualUnitTag] = UnitFrames.debugAttributeVisualOverrides[visualUnitTag] or {}
    local key = VisualEffectCacheKey(visualType, statType, attributeType, powerType)
    if value == nil or value == 0 then
        UnitFrames.debugAttributeVisualOverrides[visualUnitTag][key] = nil
    else
        UnitFrames.debugAttributeVisualOverrides[visualUnitTag][key] = value
    end
    if UnitFrames.InvalidateAttributeVisualEffectCache then
        UnitFrames.InvalidateAttributeVisualEffectCache(visualUnitTag)
    end
end

function UnitFrames.ClearDebugAttributeVisualOverrides(visualUnitTag)
    if visualUnitTag then
        UnitFrames.debugAttributeVisualOverrides[visualUnitTag] = nil
        if UnitFrames.InvalidateAttributeVisualEffectCache then
            UnitFrames.InvalidateAttributeVisualEffectCache(visualUnitTag)
        end
    else
        UnitFrames.debugAttributeVisualOverrides = {}
        if UnitFrames.InvalidateAttributeVisualEffectCache then
            UnitFrames.InvalidateAttributeVisualEffectCache(nil)
        end
    end
end

local function EnsureSavedHealthForFrame(frameKey, sourceUnitTag)
    if not UnitFrames.savedHealth[frameKey] then
        UnitFrames.savedHealth[frameKey] = { 1, 1, 1, 0, 0 }
    end
    local saved = UnitFrames.savedHealth[frameKey]
    local healthValue, healthMax, healthEffectiveMax = GetUnitPower(sourceUnitTag, COMBAT_MECHANIC_FLAGS_HEALTH)
    saved[1] = healthValue
    saved[2] = healthMax
    saved[3] = healthEffectiveMax
end

-- Pushes live power into `frame` while using `frameKey` for savedHealth / visualizer lookups.
local function PushPowerValuesForFrame(frame, frameKey, sourceUnitTag)
    if not frame then return end
    EnsureSavedHealthForFrame(frameKey, sourceUnitTag)
    for powerType, control in pairs(frame) do
        if type(powerType) == "number" and control then
            local powerValue, powerMax, powerEffectiveMax = GetUnitPower(sourceUnitTag, powerType)
            UnitFrames.UpdateAttribute(frameKey, powerType, control, powerValue, powerEffectiveMax, false, nil)
        end
    end
end

local function ResolveFrameKey(frameArg)
    if not frameArg or frameArg == "" then
        return "player"
    end
    local aliases =
    {
        sg1 = "SmallGroup1",
        sg2 = "SmallGroup2",
        sg3 = "SmallGroup3",
        sg4 = "SmallGroup4",
        rg1 = "RaidGroup1",
        rg2 = "RaidGroup2",
        tar = "reticleover",
        target = "reticleover",
    }
    local key = aliases[string.lower(frameArg)] or frameArg
    if UnitFrames.CustomFrames[key] then
        return key
    end
    return key
end

local function RefreshDebugAttributeVisualizers(visualUnitTag)
    local mods = UnitFrames.VisualizerModules
    if not mods then return end

    local healthEffectiveMax = 1
    if UnitFrames.savedHealth[visualUnitTag] then
        healthEffectiveMax = UnitFrames.savedHealth[visualUnitTag][3] or 1
    end
    if healthEffectiveMax < 1 then
        healthEffectiveMax = 1
    end

    if mods.StatChangeModule then
        mods.StatChangeModule:UpdateStat(visualUnitTag, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
        mods.StatChangeModule:UpdateStat(visualUnitTag, STAT_POWER, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
    end
    if mods.RegenerationModule then
        mods.RegenerationModule:UpdateRegen(visualUnitTag, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
        mods.RegenerationModule:UpdateRegen(visualUnitTag, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, COMBAT_MECHANIC_FLAGS_MAGICKA)
        mods.RegenerationModule:UpdateRegen(visualUnitTag, STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, COMBAT_MECHANIC_FLAGS_STAMINA)
    end
    if mods.PossessionModule then
        local possessionValue = UnitFrames.GetAttributeVisualEffectValue(visualUnitTag, ATTRIBUTE_VISUAL_POSSESSION, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
        mods.PossessionModule:UpdatePossession(visualUnitTag, possessionValue)
    end
    if mods.UnwaveringModule then
        mods.UnwaveringModule:UpdateInvulnerable(visualUnitTag)
    end
    if mods.PowerShieldModule then
        local shieldValue = UnitFrames.GetAttributeVisualEffectValue(visualUnitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
        local traumaValue = UnitFrames.GetAttributeVisualEffectValue(visualUnitTag, ATTRIBUTE_VISUAL_TRAUMA, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
        local noHealValue = UnitFrames.GetAttributeVisualEffectValue(visualUnitTag, ATTRIBUTE_VISUAL_NO_HEALING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH)
        mods.PowerShieldModule:UpdateShield(visualUnitTag, shieldValue, healthEffectiveMax)
        mods.PowerShieldModule:UpdateTrauma(visualUnitTag, traumaValue, healthEffectiveMax)
        mods.PowerShieldModule:UpdateNoHealing(visualUnitTag, noHealValue)
    end
end

local DEBUG_VISUAL_PRESET_NAMES =
{
    "power", "powerdec", "armor", "armordec", "hot", "dot", "maghot", "stamhot",
    "shield", "trauma", "noheal", "possession", "unwavering", "clear",
}

local function ApplyDebugVisualPreset(visualUnitTag, presetName)
    presetName = string.lower(presetName or "")

    local isKnown = presetName == "" or presetName == "clear"
    if not isKnown then
        for _, name in ipairs(DEBUG_VISUAL_PRESET_NAMES) do
            if name == presetName then
                isKnown = true
                break
            end
        end
    end
    if not isKnown then
        return false
    end

    UnitFrames.ClearDebugAttributeVisualOverrides(visualUnitTag)
    if UnitFrames.savedHealth[visualUnitTag] then
        UnitFrames.savedHealth[visualUnitTag][4] = 0
        UnitFrames.savedHealth[visualUnitTag][5] = 0
    end

    local maxHealth = (UnitFrames.savedHealth[visualUnitTag] and UnitFrames.savedHealth[visualUnitTag][3]) or 20000
    if maxHealth < 1 then maxHealth = 20000 end

    if presetName == "clear" or presetName == "" then
        RefreshDebugAttributeVisualizers(visualUnitTag)
        return true
    end

    if presetName == "power" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, 1)
    elseif presetName == "powerdec" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_POWER, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, -1)
    elseif presetName == "armor" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_DECREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, -1)
    elseif presetName == "armordec" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_INCREASED_STAT, STAT_ARMOR_RATING, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, 1)
    elseif presetName == "hot" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, -1)
    elseif presetName == "dot" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_DECREASED_REGEN_POWER, STAT_HEALTH_REGEN_COMBAT, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, 1)
    elseif presetName == "maghot" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_MAGICKA_REGEN_COMBAT, ATTRIBUTE_MAGICKA, COMBAT_MECHANIC_FLAGS_MAGICKA, -1)
    elseif presetName == "stamhot" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_INCREASED_REGEN_POWER, STAT_STAMINA_REGEN_COMBAT, ATTRIBUTE_STAMINA, COMBAT_MECHANIC_FLAGS_STAMINA, -1)
    elseif presetName == "shield" then
        local shieldAmount = zo_floor(maxHealth * 0.35)
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_POWER_SHIELDING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, shieldAmount)
        if UnitFrames.savedHealth[visualUnitTag] then
            UnitFrames.savedHealth[visualUnitTag][4] = shieldAmount
        end
    elseif presetName == "trauma" then
        local traumaAmount = zo_floor(maxHealth * 0.25)
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_TRAUMA, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, traumaAmount)
        if UnitFrames.savedHealth[visualUnitTag] then
            UnitFrames.savedHealth[visualUnitTag][5] = traumaAmount
        end
    elseif presetName == "noheal" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_NO_HEALING, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, 1)
    elseif presetName == "possession" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_POSSESSION, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, 1)
    elseif presetName == "unwavering" then
        SetDebugVisualOverride(visualUnitTag, ATTRIBUTE_VISUAL_UNWAVERING_POWER, STAT_MITIGATION, ATTRIBUTE_HEALTH, COMBAT_MECHANIC_FLAGS_HEALTH, 1)
    else
        return false
    end

    RefreshDebugAttributeVisualizers(visualUnitTag)
    return true
end

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

local function ShowFrameForDebug(frameKey)
    local frame = UnitFrames.CustomFrames[frameKey]
    if not frame then
        return nil
    end
    ShowFrame(frame)
    if string.sub(frameKey, 1, 10) == "SmallGroup" then
        ApplyPositions()
        UnitFrames.CustomFramesApplyLayoutGroup(false)
        if frame.tlw then frame.tlw:SetHidden(false) end
    elseif string.sub(frameKey, 1, 9) == "RaidGroup" then
        ApplyPositions()
        UnitFrames.CustomFramesApplyLayoutRaid(false, true)
        if frame.tlw then frame.tlw:SetHidden(false) end
    elseif frameKey == "player" then
        ApplyPositions()
        UnitFrames.CustomFramesApplyLayoutPlayerFrame(false)
    elseif frameKey == "reticleover" then
        ApplyPositions()
        UnitFrames.CustomFramesApplyLayoutReticleoverFrame(false)
    elseif string.sub(frameKey, 1, 4) == "boss" then
        ApplyPositions()
        UnitFrames.CustomFramesApplyLayoutBosses(true)
    end
    RefreshFrameStatics(frame, PREVIEW_SOURCE_UNIT)
    PushPowerValuesForFrame(frame, frameKey, PREVIEW_SOURCE_UNIT)
    return frame
end

local function DebugAttributeVisuals(arg1, arg2)
    if not arg1 or arg1 == "" or string.lower(arg1) == "help" then
        LUIE.AddSystemMessage("[LUIE] /luieufdebug <frame> <preset>  — frame: player, reticleover, SmallGroup1, sg1, RaidGroup1, boss1, …")
        LUIE.AddSystemMessage("[LUIE] Presets: " .. table.concat(DEBUG_VISUAL_PRESET_NAMES, ", "))
        return
    end

    local frameKey
    local presetName

    if arg2 and arg2 ~= "" then
        frameKey = ResolveFrameKey(arg1)
        presetName = string.lower(arg2)
    else
        frameKey = ResolveFrameKey("player")
        presetName = string.lower(arg1)
    end

    if not UnitFrames.CustomFrames[frameKey] then
        LUIE.AddSystemMessage(string.format("[LUIE] UnitFrames debug: unknown or disabled frame '%s'.", frameKey))
        return
    end

    ShowFrameForDebug(frameKey)

    if not ApplyDebugVisualPreset(frameKey, presetName) then
        LUIE.AddSystemMessage(string.format("[LUIE] Unknown visual preset '%s'. Use /luieufdebug help.", presetName))
        return
    end

    LUIE.AddSystemMessage(string.format("[LUIE] UnitFrames visual debug: %s → %s", frameKey, presetName))
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
    UnitFrames.CustomFramesApplyLayoutBosses(true)
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
    UnitFrames.ClearDebugAttributeVisualOverrides(nil)

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

SLASH_COMMANDS["/luieufdebug"] = function (arg)
    local frameArg, presetArg = arg:match("^(%S+)%s+(%S+)$")
    if frameArg then
        DebugAttributeVisuals(frameArg, presetArg)
    else
        DebugAttributeVisuals(arg, nil)
    end
end

for command, handler in pairs(DEBUG_COMMANDS) do
    SLASH_COMMANDS[command] = handler
end
