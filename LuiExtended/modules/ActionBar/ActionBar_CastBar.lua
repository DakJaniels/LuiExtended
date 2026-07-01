-- -----------------------------------------------------------------------------
--  LuiExtended — ActionBar cast bar (UI, combat-driven display, interrupts)
--  Distributed under The MIT License (MIT) (see LICENSE file)
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar
--- @class (partial) LUIE.ActionBar.CastBar
local CastBar = ActionBar.CastBar

local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Abilities = Data.Abilities
local Castbar = Data.CastBarTable

local LibCombat = LibCombat
local OtherAddonCompatability = LUIE.OtherAddonCompatability

local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()
local moduleName = CastBar.name
local string_format = string.format
local zo_strformat = zo_strformat

local LOG_PREFIX_CASTBAR = "[CastBar] "
local g_castBarDevDebugLog = false

-- local function logCastBar(message, ...)
--     if not g_castBarDevDebugLog then
--         return
--     end
--     LUIE:Log("Verbose", LOG_PREFIX_CASTBAR .. string_format(message, ...))
-- end

--- @param abilityId integer|nil
--- @return string
local function castBarFormatAbilityRef(abilityId)
    if not abilityId or abilityId == 0 then
        return "0"
    end
    local rawName = GetAbilityName(abilityId)
    if rawName and rawName ~= "" then
        return string_format("%s (%s)", abilityId, zo_strformat("<<C:1>>", rawName))
    end
    return tostring(abilityId)
end

function CastBar.RefreshDevDebugLogCache()
    g_castBarDevDebugLog = LUIE.IsDevDebugEnabled()
    if CastBar.SetLibCombatDevDebugLogCache then
        CastBar.SetLibCombatDevDebugLogCache(g_castBarDevDebugLog)
    end
end

CastBar.topLevelWindows = {}
local topLevelWindows = CastBar.topLevelWindows
CastBar.g_castCombatEventNames = {}
CastBar.usesLibCombatSkillTimings = false
local g_castCombatEventNames = CastBar.g_castCombatEventNames
local g_castBarState = {}
local g_casting = false
local g_castbarWorldMapFix = false
local g_castbarFont
local savedPlayerX = 0.000000000000000
local savedPlayerZ = 0.000000000000000
local playerX = 0.000000000000000
local playerZ = 0.000000000000000

local function castBarClearWorldMapFix()
    g_castbarWorldMapFix = false
    eventManager:UnregisterForUpdate(moduleName .. "CastBarFix")
end

local function castBarSyncPlayerMapPosition()
    playerX, playerZ = GetMapPlayerPosition("player")
    savedPlayerX = playerX
    savedPlayerZ = playerZ
end

--- @param castId integer
--- @return boolean
local function castBarShouldBreakCastOnMove(castId)
    return castId and castId ~= 0 and Castbar.BreakCastOnMove[castId] == true
end

local WEAVE_EDGE_SLOW_CASTBAR = ZO_ColorDef:New(1, 1, 0)
local g_castBarLibCombatTimingsActive = false
local g_castBarLibCombatLastStartMs = 0
local g_castBarLibCombatLastAbilityId = 0
--- Brief combat ShowCast suppress (e.g. after block-dismiss); cleared on weapon pair change.
local g_castBarSuppressAbilityUntilMs = {}
--- Slotted ids whose channel UI was cancelled (block etc.) while combat channel buff still ticks; cleared on track FADE.
local g_castBarChannelUiDismissedSlottedIds = {}
--- After zone load / PLAYER_ACTIVATED, ignore combat-driven ShowCast (buff replay) briefly.
local g_castBarPostActivateShowSuppressUntilMs = 0
--- Dedupe EVENT_ACTIVE_WEAPON_PAIR_CHANGED; cleared on real pair change.
local g_castBarActiveWeaponPair
--- True when IsBlockActive() at ShowCast start; bar stays while block held until release then re-block.
local g_castBarBlockHeldAtStart = false
--- Set when block was released during a cast that started while blocking; re-blocking cancels the bar.
local g_castBarBlockReleasedDuringCast = false

local INNATE_RECALL_ABILITY_ID = 6811
--- Customized Recalling cast ability ids (reference id + innate recall); built in BuildWayshrineRecallCastAbilityLookup.
local g_castBarWayshrineRecallAbilityIds = {}
--- Progression index for innate Recall; used with GetAbilityFxOverrideProgressionId fallback.
local g_castBarRecallProgressionIndex

--- Cast bar ability icon chrome (matches ZOS action bar / buff slot layering).
local CAST_BAR_ICON_FRAME_TEXTURE = "EsoUI/Art/ActionBar/iconFrame.dds"
local CAST_BAR_ICON_INSET_TEXTURE_KEYBOARD = "EsoUI/Art/ActionBar/abilityInset.dds"
local CAST_BAR_ICON_INSET_TEXTURE_GAMEPAD = "EsoUI/Art/Miscellaneous/Gamepad/gp_edgeFill.dds"
--- Inset between outer cell edge and ability art (ZO_BUFF_DEBUFF uses frame size - 4).
local CAST_BAR_ICON_ABILITY_INSET_PIXELS = 2

--- @return string
local function castBarGetIconInsetTexture()
    if IsInGamepadPreferredMode() then
        return CAST_BAR_ICON_INSET_TEXTURE_GAMEPAD
    end
    return CAST_BAR_ICON_INSET_TEXTURE_KEYBOARD
end

--- Frame texture + tint and inset background; safe to call after CreateCastBar / on settings refresh.
function CastBar.ApplyCastBarIconFrameVisual()
    if not g_castBarState or not g_castBarState.back then
        return
    end
    g_castBarState.back:SetTexture(CAST_BAR_ICON_FRAME_TEXTURE)
    local frameColor = ActionBar.SV.CastBarIconFrameColor or ActionBar.Defaults.CastBarIconFrameColor
    g_castBarState.back:SetColor(frameColor[1], frameColor[2], frameColor[3], frameColor[4])
    if g_castBarState.iconbg then
        g_castBarState.iconbg:SetTexture(castBarGetIconInsetTexture())
    end
end

--- Populates g_castBarWayshrineRecallAbilityIds from PLAYER_FX_OVERRIDE wayshrine collectibles.
function CastBar.BuildWayshrineRecallCastAbilityLookup()
    for abilityId in pairs(g_castBarWayshrineRecallAbilityIds) do
        g_castBarWayshrineRecallAbilityIds[abilityId] = nil
    end
    g_castBarWayshrineRecallAbilityIds[INNATE_RECALL_ABILITY_ID] = true

    local hasRecallProgression, recallProgressionIndex = GetAbilityProgressionXPInfoFromAbilityId(INNATE_RECALL_ABILITY_ID)
    g_castBarRecallProgressionIndex = hasRecallProgression and recallProgressionIndex or nil

    if Castbar.WayshrineRecallCastAbilityIds then
        for recallCastAbilityId in pairs(Castbar.WayshrineRecallCastAbilityIds) do
            g_castBarWayshrineRecallAbilityIds[recallCastAbilityId] = true
        end
    end

    local collectibleTotal = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE)
    for collectibleIndex = 1, collectibleTotal do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE, collectibleIndex)
        if collectibleId and collectibleId > 0 then
            if  GetCollectiblePlayerFxOverrideType(collectibleId) == PLAYER_FX_OVERRIDE_TYPE_ABILITY
            and GetCollectiblePlayerFxOverrideAbilityType(collectibleId) == PLAYER_FX_OVERRIDE_ABILITY_TYPE_WAYSHRINE then
                local referenceAbilityId = GetCollectibleReferenceId(collectibleId)
                if referenceAbilityId and referenceAbilityId > 0 then
                    g_castBarWayshrineRecallAbilityIds[referenceAbilityId] = true
                end
            end
        end
    end
end

--- @return boolean
local function castBarHasActiveWayshrineRecallPlayerFxOverride()
    local collectibleTotal = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE)
    for collectibleIndex = 1, collectibleTotal do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE, collectibleIndex)
        if collectibleId and collectibleId > 0 then
            if  GetCollectiblePlayerFxOverrideType(collectibleId) == PLAYER_FX_OVERRIDE_TYPE_ABILITY
            and GetCollectiblePlayerFxOverrideAbilityType(collectibleId) == PLAYER_FX_OVERRIDE_ABILITY_TYPE_WAYSHRINE
            and IsCollectibleActive(collectibleId, GAMEPLAY_ACTOR_CATEGORY_PLAYER) then
                return true
            end
        end
    end
    return false
end

--- @param abilityId integer
--- @return boolean
local function castBarAbilityCastInfoMatchesInnateRecall(abilityId)
    local recallChanneled, recallCastTimeMs = GetAbilityCastInfo(INNATE_RECALL_ABILITY_ID)
    local channeled, castTimeMs = GetAbilityCastInfo(abilityId)
    if (recallCastTimeMs or 0) <= 0 or (castTimeMs or 0) <= 0 then
        return false
    end
    return channeled == recallChanneled and castTimeMs == recallCastTimeMs
end

--- @param abilityId integer|nil
--- @return boolean
local function castBarIsWayshrineRecallCastAbility(abilityId)
    if not abilityId or abilityId == 0 then
        return false
    end
    if g_castBarWayshrineRecallAbilityIds[abilityId] then
        return true
    end
    if g_castBarRecallProgressionIndex then
        local fxOverrideProgressionId = GetAbilityFxOverrideProgressionId(abilityId)
        if fxOverrideProgressionId ~= 0 and fxOverrideProgressionId == g_castBarRecallProgressionIndex then
            return true
        end
    end
    if castBarHasActiveWayshrineRecallPlayerFxOverride() and castBarAbilityCastInfoMatchesInnateRecall(abilityId) then
        return true
    end
    return false
end

--- Input lag for cast/weave display (PerfectWeave: zo_min(GetLatency() / 2 - 1, 48)).
--- @return integer
function CastBar.GetCastBarInputLagMs()
    return zo_min(zo_max(GetLatency() / 2 - 1, 0), 48)
end

--- @return integer remainMs
--- @return integer durationMs
function CastBar.GetGcdSlotCooldownMs()
    local remain, duration = GetSlotCooldownInfo(Castbar.GcdReferenceSlot, ActionBar.GetHotbarCategory())
    return remain or 0, duration or 0
end

CastBar.TIMER_FORMAT_MS = 1
CastBar.TIMER_FORMAT_SEC_HUNDREDTHS = 2
CastBar.TIMER_FORMAT_SEC_THOUSANDTHS = 3

--- @param remainingCastMs integer
--- @return string
function CastBar.FormatCastBarTimerText(remainingCastMs)
    local format = ActionBar.SV.CastBarTimerFormat or CastBar.TIMER_FORMAT_MS
    local remainingSec = remainingCastMs / 1000
    if format == CastBar.TIMER_FORMAT_SEC_HUNDREDTHS then
        return string_format("%.2f", remainingSec)
    end
    if format == CastBar.TIMER_FORMAT_SEC_THOUSANDTHS then
        return string_format("%.3f", remainingSec)
    end
    return string_format("%d", zo_ceil(remainingCastMs))
end

CastBar.Private = {}
CastBar.Private.moduleName = moduleName
CastBar.Private.FormatAbilityRefForLog = castBarFormatAbilityRef
function CastBar.Private.GetState()
    return g_castBarState
end

function CastBar.Private.IsCasting()
    return g_casting
end

function CastBar.Private.SetLibCombatTimingsActive(active)
    g_castBarLibCombatTimingsActive = active
    CastBar.usesLibCombatSkillTimings = active
end

function CastBar.Private.RecordLibCombatCastStart(abilityId, startTimeMs)
    g_castBarLibCombatLastAbilityId = abilityId
    g_castBarLibCombatLastStartMs = startTimeMs
end

function CastBar.Private.ShouldDedupeCombatCastStart(abilityId)
    return g_castBarLibCombatTimingsActive
        and g_castBarLibCombatLastAbilityId == abilityId
        and (GetFrameTimeMilliseconds() - g_castBarLibCombatLastStartMs) < 50
end

local function castBarFilteredOut(abilityId, castAbilityName)
    if Castbar.CastIgnoreAbility[abilityId] then
        return true
    end
    if ActionBar.SV.blacklist[abilityId] or (castAbilityName and ActionBar.SV.blacklist[castAbilityName]) then
        return true
    end
    if Castbar.IsHeavy[abilityId] and not ActionBar.SV.CastBarHeavy then
        return true
    end
    return false
end

function CastBar.ShouldShowOnCastBar(abilityId, castAbilityName)
    if castBarFilteredOut(abilityId, castAbilityName) then
        return false
    end
    if Castbar.CastOverride[abilityId] or Castbar.IsCast[abilityId] then
        return true
    end
    if g_castBarLibCombatTimingsActive then
        return true
    end
    local channeled, castTime = GetAbilityCastInfo(abilityId)
    if channeled or (castTime or 0) > 0 then
        return true
    end
    if Castbar.CastDurationFix[abilityId]
    or Castbar.CastChannelConvert[abilityId]
    or Castbar.MultiCast[abilityId]
    or Castbar.CastChannelOverride[abilityId] then
        return true
    end
    return false
end

local function castBarSuppressAbilityBriefly(abilityId)
    if not abilityId or abilityId == 0 then
        return
    end
    local suppressMs = Castbar.CastBarChannelSuppressMs or 800
    g_castBarSuppressAbilityUntilMs[abilityId] = GetFrameTimeMilliseconds() + suppressMs
end

local function castBarIsAbilityShowCastSuppressed(abilityId)
    local suppressUntil = g_castBarSuppressAbilityUntilMs[abilityId]
    if not suppressUntil then
        return false
    end
    if GetFrameTimeMilliseconds() >= suppressUntil then
        g_castBarSuppressAbilityUntilMs[abilityId] = nil
        return false
    end
    return true
end

--- @param abilityId integer
--- @return integer|nil slottedId for CastChannelCombatTrack row (track combat id or slotted id)
local function castBarResolveChannelSlottedCastId(abilityId)
    if not Castbar.CastChannelCombatTrack then
        return nil
    end
    for trackAbilityId, track in pairs(Castbar.CastChannelCombatTrack) do
        if abilityId == trackAbilityId or abilityId == track.slottedId then
            return track.slottedId
        end
    end
    return nil
end

--- Slotted id whose channel UI is started from CastChannelCombatTrack buff ticks (e.g. Engulfing 20930 / 32821).
--- @param abilityId integer
--- @return boolean
local function castBarIsSlottedChannelCombatTracked(abilityId)
    if not abilityId or abilityId == 0 or not Castbar.CastChannelCombatTrack then
        return false
    end
    for _, track in pairs(Castbar.CastChannelCombatTrack) do
        if track.slottedId == abilityId then
            return true
        end
    end
    return false
end

--- @param abilityId integer
--- @return boolean
local function castBarIsChannelUiDismissed(abilityId)
    if not abilityId or abilityId == 0 then
        return false
    end
    local slottedId = castBarResolveChannelSlottedCastId(abilityId)
    if slottedId and g_castBarChannelUiDismissedSlottedIds[slottedId] then
        return true
    end
    return g_castBarChannelUiDismissedSlottedIds[abilityId] == true
end

--- @param slottedId integer
local function castBarDismissChannelUiForSlotted(slottedId)
    if not slottedId or slottedId == 0 then
        return
    end
    g_castBarChannelUiDismissedSlottedIds[slottedId] = true
    castBarSuppressAbilityBriefly(slottedId)
end

--- @param castId integer
local function castBarStopForBlockInterrupt(castId)
    local channelSlottedId = castBarResolveChannelSlottedCastId(castId)
    if channelSlottedId then
        castBarDismissChannelUiForSlotted(channelSlottedId)
    end
    CastBar.StopCastBar()
end

local function castBarClearChannelSuppressForSlotted(slottedId)
    if slottedId then
        g_castBarSuppressAbilityUntilMs[slottedId] = nil
        g_castBarChannelUiDismissedSlottedIds[slottedId] = nil
    end
end

local function castBarClearTransientCastBarState()
    for abilityId in pairs(g_castBarSuppressAbilityUntilMs) do
        g_castBarSuppressAbilityUntilMs[abilityId] = nil
    end
    for slottedId in pairs(g_castBarChannelUiDismissedSlottedIds) do
        g_castBarChannelUiDismissedSlottedIds[slottedId] = nil
    end
    g_castBarBlockHeldAtStart = false
    g_castBarBlockReleasedDuringCast = false
end

--- @param abilityId integer
--- @return boolean
local function castBarIsPostActivateShowSuppressed(abilityId)
    if abilityId == 0 then
        return false
    end
    return GetFrameTimeMilliseconds() < g_castBarPostActivateShowSuppressUntilMs
end

--- Clears in-progress cast UI and channel dismiss/suppress latches after zoning (combat buff replay otherwise reopens bars).
function CastBar.OnPlayerActivated()
    CastBar.BuildWayshrineRecallCastAbilityLookup()
    if not ActionBar.SV.CastBarEnable then
        return
    end
    CastBar.StopCastBar()
    castBarClearTransientCastBarState()
    castBarClearWorldMapFix()
    castBarSyncPlayerMapPosition()
    g_castBarPostActivateShowSuppressUntilMs = GetFrameTimeMilliseconds() + 2000
    local pair = ActionBar.GetHeldWeaponPair()
    if pair and pair ~= ACTIVE_WEAPON_PAIR_NONE then
        g_castBarActiveWeaponPair = pair
    else
        g_castBarActiveWeaponPair = nil
    end
end

--- @param abilityId integer
--- @return boolean
function CastBar.ShouldShowCastBarLabel(abilityId)
    return ActionBar.SV.CastBarLabel
end

--- Applies CastBarLabel to the name label during casts and unlock preview.
function CastBar.RefreshCastBarLabelVisibility()
    if not g_castBarState or not g_castBarState.bar or not g_castBarState.bar.name then
        return
    end
    if not ActionBar.SV.CastBarLabel then
        g_castBarState.bar.name:SetHidden(true)
        return
    end
    if g_casting then
        g_castBarState.bar.name:SetHidden(false)
        return
    end
    if ActionBar.CastBarUnlocked then
        CastBar.GenerateCastbarPreview(true)
    else
        g_castBarState.bar.name:SetHidden(true)
    end
end

function CastBar.GetCastDisplayNameAndIcon(abilityId)
    local displayAbilityId = abilityId
    if ActionBar.SV.CastBarHeavy and Castbar.IsHeavy[abilityId] then
        displayAbilityId = Castbar.HeavyCastMediumDisplay[abilityId] or abilityId
    end
    local icon
    local name
    local override = Effects.EffectOverride[displayAbilityId]
    if override and (override.icon or override.name) then
        icon = override.icon or GetAbilityIcon(abilityId)
        name = override.name or zo_strformat("<<C:1>>", GetAbilityName(abilityId))
    elseif OtherAddonCompatability.isLibCombatEnabled then
        icon = LibCombat.GetFormattedAbilityIcon(abilityId)
        name = LibCombat.GetFormattedAbilityName(abilityId)
    else
        icon = GetAbilityIcon(abilityId)
        name = zo_strformat("<<C:1>>", GetAbilityName(abilityId))
    end
    if castBarIsWayshrineRecallCastAbility(abilityId) then
        name = Abilities.Innate_Recall
        icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_RECALL_DDS
    end
    return icon, name
end

--- @param abilityId integer
--- @param result ActionResult
--- @param hitValue integer
--- @param channeled boolean
--- @param castTime integer
--- @return integer durationMs
function CastBar.ComputeCastDurationMs(abilityId, result, hitValue, channeled, castTime)
    local durationMs
    if channeled then
        durationMs = Castbar.CastDurationFix[abilityId] or (result == ACTION_RESULT_EFFECT_GAINED_DURATION and hitValue or 0)
    else
        durationMs = Castbar.CastDurationFix[abilityId] or castTime
        if (not durationMs or durationMs <= 0)
        and result == ACTION_RESULT_BEGIN
        and hitValue
        and hitValue > 0 then
            durationMs = hitValue
        end
    end
    if not durationMs or durationMs <= 0 then
        return 0
    end
    if channeled and not Castbar.CastDurationFix[abilityId] then
        durationMs = zo_max(durationMs, 1000)
    end
    durationMs = durationMs + (Castbar.CastDisplayDelayMs[abilityId] or 0) + CastBar.GetCastBarInputLagMs()
    return durationMs
end

--- @param abilityId integer
--- @param startTimeMs number
--- @param durationMs integer
--- @param channeled boolean
--- @param castAbilityIcon string|nil
--- @param castAbilityName string|nil
--- @param startedFromLibCombat boolean|nil
function CastBar.ShowCast(abilityId, startTimeMs, durationMs, channeled, castAbilityIcon, castAbilityName, startedFromLibCombat)
    -- logCastBar(("ShowCast call ability=%s durationMs=%s channeled=%s libCombat=%s", castBarFormatAbilityRef(abilityId), tostring(durationMs), tostring(channeled), tostring(startedFromLibCombat))
    if durationMs <= 0 then
        -- logCastBar(("ShowCast skipped ability=%s reason=duration", castBarFormatAbilityRef(abilityId))
        return
    end
    if castBarIsPostActivateShowSuppressed(abilityId) then
        -- logCastBar(("ShowCast skipped ability=%s reason=postActivate", castBarFormatAbilityRef(abilityId))
        return
    end
    if castBarIsChannelUiDismissed(abilityId) then
        if startedFromLibCombat then
            local clearSlottedId = castBarResolveChannelSlottedCastId(abilityId) or abilityId
            castBarClearChannelSuppressForSlotted(clearSlottedId)
            -- logCastBar(("ShowCast cleared channelDismiss for libCombat ability=%s", castBarFormatAbilityRef(abilityId))
        else
            -- logCastBar(("ShowCast skipped ability=%s reason=channelDismissed", castBarFormatAbilityRef(abilityId))
            return
        end
    end
    if castBarIsAbilityShowCastSuppressed(abilityId) and not startedFromLibCombat then
        -- logCastBar(("ShowCast skipped ability=%s reason=showCastSuppress", castBarFormatAbilityRef(abilityId))
        return
    end
    if g_casting and channeled then
        local castId = g_castBarState.id
        local nowMs = GetFrameTimeMilliseconds()
        if castId == abilityId and g_castBarState.remain and nowMs < g_castBarState.remain then
            -- logCastBar(("ShowCast skipped ability=%s reason=sameChannelActive", castBarFormatAbilityRef(abilityId))
            return
        end
    end
    if g_casting then
        CastBar.StopCastBar()
    end
    if not castAbilityIcon or not castAbilityName then
        castAbilityIcon, castAbilityName = CastBar.GetCastDisplayNameAndIcon(abilityId)
    elseif castBarIsWayshrineRecallCastAbility(abilityId) then
        castAbilityName = Abilities.Innate_Recall
        castAbilityIcon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_RECALL_DDS
    end

    local castEndTimeMs = startTimeMs + durationMs
    local remainingCastMs = castEndTimeMs - startTimeMs

    g_castBarState.remain = castEndTimeMs
    g_castBarState.starts = startTimeMs
    g_castBarState.ends = castEndTimeMs
    g_castBarState.icon:SetTexture(castAbilityIcon)
    g_castBarState.id = abilityId

    if channeled then
        g_castBarState.type = 2
        g_castBarState.bar.bar:SetValue(1)
    else
        g_castBarState.type = 1
        g_castBarState.bar.bar:SetValue(0)
    end
    g_castBarBlockHeldAtStart = IsBlockActive()
    g_castBarBlockReleasedDuringCast = false
    if CastBar.ShouldShowCastBarLabel(abilityId) then
        g_castBarState.bar.name:SetText(castAbilityName)
        g_castBarState.bar.name:SetHidden(false)
    else
        g_castBarState.bar.name:SetHidden(true)
    end
    if ActionBar.SV.CastBarTimer then
        g_castBarState.bar.timer:SetHidden(false)
        CastBar.UpdateCastBarTimerLabel(startTimeMs)
    end

    g_castBarState:SetHidden(false)
    if topLevelWindows.castBar then
        topLevelWindows.castBar.preview:SetHidden(true)
        topLevelWindows.castBar:SetHidden(false)
        ActionBar.ApplyDisplayAlpha()
    end
    g_casting = true
    castBarSyncPlayerMapPosition()
    if startedFromLibCombat then
        CastBar.Private.RecordLibCombatCastStart(abilityId, startTimeMs)
    end
    -- logCastBar("ShowCast started ability=%s durationMs=%s channeled=%s startTimeMs=%s libCombat=%s", castBarFormatAbilityRef(abilityId), tostring(durationMs), tostring(channeled), tostring(startTimeMs), tostring(startedFromLibCombat))
    eventManager:RegisterForUpdate(moduleName .. "CastBar", 20, CastBar.OnUpdateCastbar)
end

--- @param currentTimeMS number
function CastBar.UpdateCastBarTimerLabel(currentTimeMS)
    if not ActionBar.SV.CastBarTimer or not g_castBarState.bar or not g_castBarState.bar.timer then
        return
    end
    local remainingCastMs = g_castBarState.remain - currentTimeMS
    if remainingCastMs <= 0 then
        return
    end
    g_castBarState.bar.timer:SetText(CastBar.FormatCastBarTimerText(remainingCastMs))
end

function CastBar.UnregisterEvents()
    for _, eventName in ipairs(g_castCombatEventNames) do
        eventManager:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
    end
    for index = #g_castCombatEventNames, 1, -1 do
        g_castCombatEventNames[index] = nil
    end

    eventManager:UnregisterForEvent(moduleName .. "CombatEventCast", EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName, EVENT_START_SOUL_GEM_RESURRECTION)
    eventManager:UnregisterForEvent(moduleName, EVENT_END_SOUL_GEM_RESURRECTION)
    eventManager:UnregisterForEvent(moduleName, EVENT_GAME_CAMERA_UI_MODE_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_END_SIEGE_CONTROL)
    eventManager:UnregisterForEvent(moduleName .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "PlayerActivated", EVENT_PLAYER_ACTIVATED)
    eventManager:UnregisterForEvent(moduleName .. "PlayerDeactivated", EVENT_PLAYER_DEACTIVATED)
    eventManager:UnregisterForEvent(moduleName .. "SlotUsed", EVENT_ACTION_SLOT_ABILITY_USED)
    eventManager:UnregisterForEvent(moduleName .. "Effect", EVENT_EFFECT_CHANGED)
    eventManager:UnregisterForUpdate(moduleName .. "Interrupt")
    eventManager:UnregisterForUpdate(moduleName .. "CastBar")
    eventManager:UnregisterForUpdate(moduleName .. "CastBarFix")
    CastBar.UnregisterLibCombatEvents()
end

function CastBar.RegisterEvents()
    CastBar.UnregisterEvents()
    g_castBarActiveWeaponPair = nil
    if not ActionBar.SV.CastBarEnable then
        return
    end
    CastBar.BuildWayshrineRecallCastAbilityLookup()

    CastBar.RegisterLibCombatEvents()

    local combatResultIndex = 0
    for result, _ in pairs(Castbar.CastBreakingStatus) do
        combatResultIndex = combatResultIndex + 1
        local eventName = moduleName .. "CombatEventCC" .. combatResultIndex
        eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, function (_, actionResult, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            CastBar.OnCombatEventBreakCast(actionResult, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        end)
        eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, result)
        g_castCombatEventNames[#g_castCombatEventNames + 1] = eventName
    end

    eventManager:RegisterForEvent(moduleName .. "CombatEventCast", EVENT_COMBAT_EVENT, function (_, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        CastBar.HandleCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    end)
    eventManager:AddFilterForEvent(moduleName .. "CombatEventCast", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)

    eventManager:RegisterForEvent(moduleName, EVENT_START_SOUL_GEM_RESURRECTION, function (_, durationMs)
        CastBar.SoulGemResurrectionStart(durationMs)
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_END_SOUL_GEM_RESURRECTION, function (_)
        CastBar.SoulGemResurrectionEnd()
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_GAME_CAMERA_UI_MODE_CHANGED, function (_)
        CastBar.OnGameCameraUIModeChanged()
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_END_SIEGE_CONTROL, function (_)
        CastBar.OnSiegeEnd()
    end)
    eventManager:RegisterForEvent(moduleName .. "WeaponPair", EVENT_ACTIVE_WEAPON_PAIR_CHANGED, function (_, activeWeaponPair, locked)
        CastBar.OnActiveWeaponPairChanged(activeWeaponPair, locked)
    end)

    eventManager:RegisterForEvent(moduleName .. "PlayerDeactivated", EVENT_PLAYER_DEACTIVATED, function ()
        if ActionBar.SV.CastBarEnable then
            CastBar.StopCastBar()
            castBarClearTransientCastBarState()
        end
    end)

    eventManager:RegisterForEvent(moduleName .. "PlayerActivated", EVENT_PLAYER_ACTIVATED, function ()
        CastBar.OnPlayerActivated()
    end)

    eventManager:RegisterForEvent(moduleName .. "SlotUsed", EVENT_ACTION_SLOT_ABILITY_USED, function (_, actionSlotIndex)
        CastBar.OnActionSlotAbilityUsed(actionSlotIndex)
    end)

    eventManager:RegisterForEvent(moduleName .. "Effect", EVENT_EFFECT_CHANGED, function (_, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
        CastBar.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
    end)
    eventManager:AddFilterForEvent(moduleName .. "Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    eventManager:RegisterForUpdate(moduleName .. "Interrupt", 100, function ()
        CastBar.TickInterruptChecks()
    end)
end

function CastBar.Initialize()
    CastBar.RefreshDevDebugLogCache()
    CastBar.BuildWayshrineRecallCastAbilityLookup()
    CastBar.CreateCastBar()
    CastBar.UpdateCastBar()
    CastBar.SetCastBarPosition()
end

--- @param actionSlotIndex number
function CastBar.OnActionSlotAbilityUsed(actionSlotIndex)
    CastBar.StopForAbilitySlot(actionSlotIndex)
end

function CastBar.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType, passThrough, savedId)
    CastBar.OnEffectCastBreak(abilityId, changeType)
end

function CastBar.ApplyFont(fontString)
    g_castbarFont = fontString
    if g_castBarState.bar and g_castBarState.bar.name then
        g_castBarState.bar.name:SetFont(g_castbarFont)
        g_castBarState.bar.timer:SetFont(g_castbarFont)
    end
end

function CastBar.ApplyDisplayAlpha(alpha)
    if topLevelWindows.castBar and ActionBar.SV.CastBarEnable and topLevelWindows.castBar.SetAlpha then
        topLevelWindows.castBar:SetAlpha(alpha)
    end
end

function CastBar.OnEffectCastBreak(abilityId, changeType)
    if Castbar.CastBreakOnRemoveEffect[abilityId] and changeType == EFFECT_RESULT_FADED then
        local channelSlottedId = castBarResolveChannelSlottedCastId(abilityId)
        if channelSlottedId then
            castBarClearChannelSuppressForSlotted(channelSlottedId)
            CastBar.StopCastBar()
        else
            CastBar.StopCastBar()
        end
        if abilityId == 33208 then
            return true
        end
    end
    return false
end

function CastBar.StopForAbilitySlot(actionSlotIndex)
    if CastBar.usesLibCombatSkillTimings then
        return
    end
    if actionSlotIndex == 2 then
        CastBar.StopCastBar()
    end
end

function CastBar.OnActiveWeaponPairChanged(activeWeaponPair, weaponSwapDisabled)
    if not ActionBar.SV.CastBarEnable then
        return
    end
    if activeWeaponPair == ACTIVE_WEAPON_PAIR_NONE then
        return
    end
    if GetUnitLevel("player") < GetWeaponSwapUnlockedLevel() then
        return
    end
    if g_castBarActiveWeaponPair == nil then
        g_castBarActiveWeaponPair = activeWeaponPair
        return
    end
    if g_castBarActiveWeaponPair == activeWeaponPair then
        return
    end
    g_castBarActiveWeaponPair = activeWeaponPair

    if g_casting then
        CastBar.StopCastBar()
    end
    castBarClearTransientCastBarState()
end

-- -----------------------------------------------------------------------------
local function CastBarWorldMapFix()
    castBarClearWorldMapFix()
end

-- -----------------------------------------------------------------------------
-- Run on the EVENT_GAME_CAMERA_UI_MODE_CHANGED handler
--- Sets world-map cast bar fix buffer; breaks siege cast on window open if applicable.
function CastBar.OnGameCameraUIModeChanged()
    -- Changing zones in the World Map for some reason changes the player coordinates so when the player clicks on a Wayshrine to teleport the cast gets interrupted
    -- This buffer fixes this issue
    if g_casting then
        g_castbarWorldMapFix = true
        eventManager:RegisterForUpdate(moduleName .. "CastBarFix", 500, CastBarWorldMapFix)
    end
    -- Break Siege Deployment casts when opening UI windows
    if Castbar.BreakSiegeOnWindowOpen[g_castBarState.id] then
        CastBar.StopCastBar()
    end
end

-- -----------------------------------------------------------------------------
--- Stops cast bar when siege control ends (e.g. Stow Siege Weapon 12256).
function CastBar.OnSiegeEnd()
    if g_castBarState.id == 12256 then
        CastBar.StopCastBar()
    end
end

function CastBar.StopCastBar()
    local castBarUnlockedForPreview = ActionBar.CastBarUnlocked
    CastBar.HideWeaveLines()
    if g_castBarState.bar then
        g_castBarState.bar.name:SetHidden(true)
        g_castBarState.bar.timer:SetHidden(true)
    end
    if g_castBarState.SetHidden then
        g_castBarState:SetHidden(true)
    end
    if topLevelWindows.castBar then
        topLevelWindows.castBar:SetHidden(true)
    end
    g_castBarState.remain = nil
    g_castBarState.starts = nil
    g_castBarState.ends = nil
    g_castBarState.weaveDelayRel = nil
    g_castBarState.weaveGapEdge = nil
    g_casting = false
    g_castBarState.id = 0
    g_castBarBlockHeldAtStart = false
    g_castBarBlockReleasedDuringCast = false
    eventManager:UnregisterForUpdate(moduleName .. "CastBar")
    ActionBar.ApplyDisplayAlpha()

    if castBarUnlockedForPreview then
        CastBar.GenerateCastbarPreview(castBarUnlockedForPreview)
    end
end

-- -----------------------------------------------------------------------------
-- Updates Cast Bar - only enabled when Cast Bar is unhidden
--- Update tick: refreshes cast bar progress and timer label; stops when remain <= 0.
--- @param currentTimeMS number
function CastBar.OnUpdateCastbar(currentTimeMS)
    local castStartTimeMs = g_castBarState.starts
    local castEndTimeMs = g_castBarState.ends
    local remainingCastMs = g_castBarState.remain - currentTimeMS
    if remainingCastMs <= 0 then
        CastBar.StopCastBar()
    else
        if ActionBar.SV.CastBarTimer then
            CastBar.UpdateCastBarTimerLabel(currentTimeMS)
        end
        if g_castBarState.type == 1 then
            g_castBarState.bar.bar:SetValue((currentTimeMS - castStartTimeMs) / (castEndTimeMs - castStartTimeMs))
        else
            g_castBarState.bar.bar:SetValue(1 - ((currentTimeMS - castStartTimeMs) / (castEndTimeMs - castStartTimeMs)))
        end
        CastBar.TickWeaveGcdFeedback(currentTimeMS)
    end
end

--- While casting with weave helper: stretch delay marker and tint backdrop when slot 3 GCD is still active.
--- @param currentTimeMS number
function CastBar.TickWeaveGcdFeedback(currentTimeMS)
    if not CastBar.usesLibCombatSkillTimings or not ActionBar.SV.CastBarWeaveHelper or not g_casting then
        return
    end
    local bar = g_castBarState.bar
    if not bar or not bar.bar or not bar.lineDelay or bar.lineDelay:IsHidden() then
        return
    end
    local baseRel = g_castBarState.weaveDelayRel
    if not baseRel then
        return
    end
    local castStartTimeMs = g_castBarState.starts
    local castEndTimeMs = g_castBarState.ends
    local spanMs = castEndTimeMs - castStartTimeMs
    if spanMs <= 0 then
        return
    end
    local gcdRemainMs = select(1, CastBar.GetGcdSlotCooldownMs())
    local inputLagMs = CastBar.GetCastBarInputLagMs()
    local displayRel = baseRel
    if gcdRemainMs > inputLagMs then
        displayRel = zo_max(baseRel, zo_min(1, (currentTimeMS - castStartTimeMs + gcdRemainMs) / (spanMs + gcdRemainMs)))
    end
    local barControl = bar.bar
    local x = barControl:GetWidth() * displayRel
    bar.lineDelay:ClearAnchors()
    bar.lineDelay:SetAnchor(TOP, barControl, TOPLEFT, x, 0)
    bar.lineDelay:SetAnchor(BOTTOM, barControl, BOTTOMLEFT, x, 0)
    if bar.backdrop then
        local edge = g_castBarState.weaveGapEdge
        if gcdRemainMs > inputLagMs then
            edge = WEAVE_EDGE_SLOW_CASTBAR
        end
        if edge then
            local r, g, b = edge:UnpackRGB()
            bar.backdrop:SetEdgeColor(r, g, b, 1)
        end
    end
end

function CastBar.CreateCastBar()
    local fontString
    if ZO_IsConsoleOrGameCoreUI() then
        fontString = "ZoFontGamepad18"
    else
        fontString = "ZoFontGameMedium"
    end
    topLevelWindows.castBar = windowManager:CreateTopLevelWindow("LUIE_ACTIONBAR_CASTBAR_TLC")
    topLevelWindows.castBar:SetClampedToScreen(true)
    topLevelWindows.castBar:SetMouseEnabled(false)
    topLevelWindows.castBar:SetMovable(false)
    topLevelWindows.castBar:SetHidden(true)

    topLevelWindows.castBar:SetDimensions(ActionBar.SV.CastBarSizeW + ActionBar.SV.CastBarIconSize + 4, ActionBar.SV.CastBarSizeH)

    -- Setup Preview
    topLevelWindows.castBar.preview = topLevelWindows.castBar:CreateControl("$(parent)Preview", CT_BACKDROP)
    topLevelWindows.castBar.preview:SetCenterColor(0, 0, 0, 0.4)
    topLevelWindows.castBar.preview:SetEdgeColor(0, 0, 0, 0.6)
    topLevelWindows.castBar.preview:SetEdgeTexture("", 8, 1, 1, 1)
    topLevelWindows.castBar.preview:SetDrawLayer(DL_BACKGROUND)
    topLevelWindows.castBar.preview:SetAnchorFill(topLevelWindows.castBar)
    topLevelWindows.castBar.preview:SetHidden(true)
    topLevelWindows.castBar.previewLabel = topLevelWindows.castBar.preview:CreateControl("$(parent)Label", CT_LABEL)
    topLevelWindows.castBar.previewLabel:SetFont(ZO_IsConsoleOrGameCoreUI() and LUIE.GetPositionLabelFont() or fontString)
    topLevelWindows.castBar.previewLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    topLevelWindows.castBar.previewLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    topLevelWindows.castBar.previewLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    topLevelWindows.castBar.previewLabel:SetAnchor(CENTER, topLevelWindows.castBar.preview, CENTER)
    topLevelWindows.castBar.previewLabel:SetText("Cast Bar")

    -- Callback used to hide anchor coords preview label on movement start
    topLevelWindows.castBar:SetHandler("OnMoveStart", function ()
        eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
            topLevelWindows.castBar.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", topLevelWindows.castBar:GetLeft(), topLevelWindows.castBar:GetTop()))
        end)
    end)

    -- Callback used to save new position of frames
    topLevelWindows.castBar:SetHandler("OnMoveStop", function ()
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
        ActionBar.SV.CastbarOffsetX = topLevelWindows.castBar:GetLeft()
        ActionBar.SV.CastbarOffsetY = topLevelWindows.castBar:GetTop()
        ActionBar.SV.CastBarCustomPosition = { topLevelWindows.castBar:GetLeft(), topLevelWindows.castBar:GetTop() }
    end)

    topLevelWindows.castBar.preview.anchorTexture = topLevelWindows.castBar.preview:CreateControl("$(parent)AnchorTexture", CT_TEXTURE)
    topLevelWindows.castBar.preview.anchorTexture:SetAnchor(TOPLEFT, topLevelWindows.castBar.preview, TOPLEFT)
    topLevelWindows.castBar.preview.anchorTexture:SetDimensions(16, 16)
    topLevelWindows.castBar.preview.anchorTexture:SetTexture("/esoui/art/reticle/border_topleft.dds")
    topLevelWindows.castBar.preview.anchorTexture:SetDrawLayer(DL_OVERLAY)
    topLevelWindows.castBar.preview.anchorTexture:SetColor(1, 1, 0, 0.9)

    topLevelWindows.castBar.preview.anchorLabel = topLevelWindows.castBar.preview:CreateControl("$(parent)AnchorLabel", CT_LABEL)
    topLevelWindows.castBar.preview.anchorLabel:SetFont(LUIE.GetPositionLabelFont())
    topLevelWindows.castBar.preview.anchorLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    topLevelWindows.castBar.preview.anchorLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
    topLevelWindows.castBar.preview.anchorLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    topLevelWindows.castBar.preview.anchorLabel:SetAnchor(BOTTOMLEFT, topLevelWindows.castBar.preview, TOPLEFT, 0, -1)
    topLevelWindows.castBar.preview.anchorLabel:SetText("xxx, yyy")
    topLevelWindows.castBar.preview.anchorLabel:SetColor(1, 1, 0, 1)
    topLevelWindows.castBar.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
    topLevelWindows.castBar.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
    topLevelWindows.castBar.preview.anchorLabelBg = topLevelWindows.castBar.preview.anchorLabel:CreateControl("$(parent)Bg", CT_BACKDROP)
    topLevelWindows.castBar.preview.anchorLabelBg:SetCenterColor(0, 0, 0, 1)
    topLevelWindows.castBar.preview.anchorLabelBg:SetEdgeColor(0, 0, 0, 1)
    topLevelWindows.castBar.preview.anchorLabelBg:SetEdgeTexture("", 8, 1, 1, 1)
    topLevelWindows.castBar.preview.anchorLabelBg:SetDrawLayer(DL_BACKGROUND)
    topLevelWindows.castBar.preview.anchorLabelBg:SetAnchorFill(topLevelWindows.castBar.preview.anchorLabel)
    topLevelWindows.castBar.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
    topLevelWindows.castBar.preview.anchorLabelBg:SetDrawTier(DT_LOW)

    local fragment = ZO_HUDFadeSceneFragment:New(topLevelWindows.castBar, 0, 0)

    sceneManager:GetScene("hud"):AddFragment(fragment)
    sceneManager:GetScene("hudui"):AddFragment(fragment)
    sceneManager:GetScene("siegeBar"):AddFragment(fragment)
    sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

    g_castBarState = topLevelWindows.castBar:CreateControl("$(parent)Backdrop", CT_BACKDROP)
    g_castBarState:SetCenterColor(0, 0, 0, 0.5)
    g_castBarState:SetEdgeColor(0, 0, 0, 1)
    g_castBarState:SetEdgeTexture("", 8, 1, 1, 1)
    g_castBarState:SetDrawLayer(DL_BACKGROUND)
    g_castBarState:SetAnchor(LEFT, topLevelWindows.castBar, LEFT)

    g_castBarState.starts = 0
    g_castBarState.ends = 0
    g_castBarState.remain = 0

    g_castBarState:SetDimensions(ActionBar.SV.CastBarIconSize, ActionBar.SV.CastBarIconSize)

    g_castBarState.back = g_castBarState:CreateControl("$(parent)Back", CT_TEXTURE)
    g_castBarState.back:SetAnchor(TOPLEFT, g_castBarState, TOPLEFT)
    g_castBarState.back:SetAnchor(BOTTOMRIGHT, g_castBarState, BOTTOMRIGHT)
    g_castBarState.back:SetDrawLayer(DL_OVERLAY)
    g_castBarState.back:SetDrawTier(DT_MEDIUM)

    g_castBarState.iconbg = g_castBarState:CreateControl("$(parent)IconBg", CT_TEXTURE)
    g_castBarState.iconbg:SetDrawLayer(DL_BACKGROUND)
    g_castBarState.iconbg:SetDrawLevel(g_castBarState:GetDrawLevel() + 1)
    g_castBarState.iconbg:SetAnchor(TOPLEFT, g_castBarState, TOPLEFT)
    g_castBarState.iconbg:SetAnchor(BOTTOMRIGHT, g_castBarState, BOTTOMRIGHT)

    g_castBarState.icon = g_castBarState:CreateControl("$(parent)Icon", CT_TEXTURE)
    g_castBarState.icon:SetTexture("/esoui/art/icons/icon_missing.dds")
    g_castBarState.icon:SetDrawLayer(DL_CONTROLS)
    local iconArtInset = CAST_BAR_ICON_ABILITY_INSET_PIXELS
    g_castBarState.icon:SetAnchor(TOPLEFT, g_castBarState, TOPLEFT, iconArtInset, iconArtInset)
    g_castBarState.icon:SetAnchor(BOTTOMRIGHT, g_castBarState, BOTTOMRIGHT, -iconArtInset, -iconArtInset)

    CastBar.ApplyCastBarIconFrameVisual()

    g_castBarState.bar =
    {
        ["backdrop"] = g_castBarState:CreateControl("$(parent)Backdrop", CT_BACKDROP),
        ["bar"] = g_castBarState:CreateControl("$(parent)Bar", CT_STATUSBAR),
        ["name"] = g_castBarState:CreateControl("$(parent)Name", CT_LABEL),
        ["timer"] = g_castBarState:CreateControl("$(parent)Time", CT_LABEL),
    }
    g_castBarState.bar.backdrop:SetCenterColor(0, 0, 0, 0.4)
    g_castBarState.bar.backdrop:SetEdgeColor(0, 0, 0, 0.6)
    g_castBarState.bar.backdrop:SetEdgeTexture("", 8, 1, 1, 1)
    g_castBarState.bar.backdrop:SetDrawLayer(DL_BACKGROUND)
    g_castBarState.bar.backdrop:SetDimensions(ActionBar.SV.CastBarSizeW, ActionBar.SV.CastBarSizeH)
    g_castBarState.bar.bar:SetDimensions(ActionBar.SV.CastBarSizeW - 4, ActionBar.SV.CastBarSizeH - 4)
    g_castBarState.bar.name:SetFont(g_castbarFont or fontString)
    g_castBarState.bar.name:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    g_castBarState.bar.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    g_castBarState.bar.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    g_castBarState.bar.timer:SetFont(g_castbarFont or fontString)
    g_castBarState.bar.timer:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    g_castBarState.bar.timer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    g_castBarState.bar.timer:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    g_castBarState.id = 0

    local weaveLineWidth = CastBar.GetWeaveLineWidth()
    local function createWeaveLine(parent, name)
        local line = parent:CreateControl(name, CT_TEXTURE)
        line:SetColor(1, 1, 1, 1)
        line:SetDimensions(weaveLineWidth, ActionBar.SV.CastBarSizeH)
        line:SetHidden(true)
        return line
    end
    g_castBarState.bar.lineLA = createWeaveLine(g_castBarState.bar.backdrop, "$(parent)LineLA")
    g_castBarState.bar.lineSkill = createWeaveLine(g_castBarState.bar.backdrop, "$(parent)LineSkill")
    g_castBarState.bar.lineDelay = createWeaveLine(g_castBarState.bar.backdrop, "$(parent)LineDelay")

    g_castBarState.bar.backdrop:SetEdgeTexture("", 8, 2, 2, 1)
    g_castBarState.bar.backdrop:SetDrawLayer(DL_BACKGROUND)
    g_castBarState.bar.backdrop:SetDrawLevel(g_castBarState:GetDrawLevel() + 1)
    g_castBarState.bar.bar:SetMinMax(0, 1)
    g_castBarState.bar.backdrop:SetCenterColor((0.1 * 0.50), (0.1 * 0.50), (0.1 * 0.50), 0.75)
    local gradientStartRed, gradientStartGreen, gradientStartBlue, gradientStartAlpha = 0, 47 / 255, 130 / 255, 1
    local gradientEndRed, gradientEndGreen, gradientEndBlue, gradientEndAlpha = 82 / 255, 215 / 255, 1, 1
    g_castBarState.bar.bar:SetGradientColors(gradientStartRed, gradientStartGreen, gradientStartBlue, gradientStartAlpha, gradientEndRed, gradientEndGreen, gradientEndBlue, gradientEndAlpha)
    g_castBarState.bar.backdrop:SetCenterColor((0.1 * ActionBar.SV.CastBarGradientC1[1]), (0.1 * ActionBar.SV.CastBarGradientC1[2]), (0.1 * ActionBar.SV.CastBarGradientC1[3]), 0.75)
    gradientStartRed, gradientStartGreen, gradientStartBlue, gradientStartAlpha = ActionBar.SV.CastBarGradientC1[1], ActionBar.SV.CastBarGradientC1[2], ActionBar.SV.CastBarGradientC1[3], ActionBar.SV.CastBarGradientC1[4]
    gradientEndRed, gradientEndGreen, gradientEndBlue, gradientEndAlpha = ActionBar.SV.CastBarGradientC2[1], ActionBar.SV.CastBarGradientC2[2], ActionBar.SV.CastBarGradientC2[3], ActionBar.SV.CastBarGradientC2[4]
    g_castBarState.bar.bar:SetGradientColors(gradientStartRed, gradientStartGreen, gradientStartBlue, gradientStartAlpha, gradientEndRed, gradientEndGreen, gradientEndBlue, gradientEndAlpha)

    g_castBarState.bar.backdrop:ClearAnchors()
    g_castBarState.bar.backdrop:SetAnchor(LEFT, g_castBarState, RIGHT, 4, 0)

    g_castBarState.bar.timer:ClearAnchors()
    g_castBarState.bar.timer:SetAnchor(RIGHT, g_castBarState.bar.backdrop, RIGHT, -4, 0)
    g_castBarState.bar.timer:SetHidden(true)

    g_castBarState.bar.name:ClearAnchors()
    g_castBarState.bar.name:SetAnchor(LEFT, g_castBarState.bar.backdrop, LEFT, 4, 0)
    g_castBarState.bar.name:SetHidden(true)

    g_castBarState.bar.bar:SetTexture(LUIE.StatusbarTextures[ActionBar.SV.CastBarTexture])
    g_castBarState.bar.bar:ClearAnchors()
    g_castBarState.bar.bar:SetAnchor(CENTER, g_castBarState.bar.backdrop, CENTER, 0, 0)
    g_castBarState.bar.bar:SetAnchor(CENTER, g_castBarState.bar.backdrop, CENTER, 0, 0)

    g_castBarState.bar.timer:SetText("Timer")
    g_castBarState.bar.name:SetText("Name")

    g_castBarState:SetHidden(true)
end

-- -----------------------------------------------------------------------------
--- Resizes cast bar and icon to SV dimensions (CastBarSizeW, CastBarSizeH, CastBarIconSize).
function CastBar.ResizeCastBar()
    topLevelWindows.castBar:SetDimensions(ActionBar.SV.CastBarSizeW + ActionBar.SV.CastBarIconSize + 4, ActionBar.SV.CastBarSizeH)
    g_castBarState:ClearAnchors()
    g_castBarState:SetAnchor(LEFT, topLevelWindows.castBar, LEFT)

    g_castBarState:SetDimensions(ActionBar.SV.CastBarIconSize, ActionBar.SV.CastBarIconSize)
    g_castBarState.bar.backdrop:SetDimensions(ActionBar.SV.CastBarSizeW, ActionBar.SV.CastBarSizeH)
    g_castBarState.bar.bar:SetDimensions(ActionBar.SV.CastBarSizeW - 4, ActionBar.SV.CastBarSizeH - 4)

    g_castBarState.bar.backdrop:ClearAnchors()
    g_castBarState.bar.backdrop:SetAnchor(LEFT, g_castBarState, RIGHT, 4, 0)

    g_castBarState.bar.timer:ClearAnchors()
    g_castBarState.bar.timer:SetAnchor(RIGHT, g_castBarState.bar.backdrop, RIGHT, -4, 0)

    g_castBarState.bar.name:ClearAnchors()
    g_castBarState.bar.name:SetAnchor(LEFT, g_castBarState.bar.backdrop, LEFT, 4, 0)

    g_castBarState.bar.bar:ClearAnchors()
    g_castBarState.bar.bar:SetAnchor(CENTER, g_castBarState.bar.backdrop, CENTER, 0, 0)
    g_castBarState.bar.bar:SetAnchor(CENTER, g_castBarState.bar.backdrop, CENTER, 0, 0)

    CastBar.UpdateWeaveLineDimensions()
    CastBar.SetCastBarPosition()
end

-- -----------------------------------------------------------------------------
--- Applies cast bar texture, gradient, font, and visibility from SV; called on init and settings change.
function CastBar.UpdateCastBar()
    if not ActionBar.SV.CastBarEnable then
        return
    end
    if not g_castBarState or not g_castBarState.bar then
        return
    end
    g_castBarState.bar.name:SetFont(g_castbarFont)
    g_castBarState.bar.timer:SetFont(g_castbarFont)
    g_castBarState.bar.bar:SetTexture(LUIE.StatusbarTextures[ActionBar.SV.CastBarTexture])
    g_castBarState.bar.backdrop:SetCenterColor((0.1 * ActionBar.SV.CastBarGradientC1[1]), (0.1 * ActionBar.SV.CastBarGradientC1[2]), (0.1 * ActionBar.SV.CastBarGradientC1[3]), 0.75 * ActionBar.SV.CastBarGradientC1[4])
    local gradientStartRed, gradientStartGreen, gradientStartBlue, gradientStartAlpha = ActionBar.SV.CastBarGradientC1[1], ActionBar.SV.CastBarGradientC1[2], ActionBar.SV.CastBarGradientC1[3], ActionBar.SV.CastBarGradientC1[4]
    local gradientEndRed, gradientEndGreen, gradientEndBlue, gradientEndAlpha = ActionBar.SV.CastBarGradientC2[1], ActionBar.SV.CastBarGradientC2[2], ActionBar.SV.CastBarGradientC2[3], ActionBar.SV.CastBarGradientC2[4]
    g_castBarState.bar.bar:SetGradientColors(gradientStartRed, gradientStartGreen, gradientStartBlue, gradientStartAlpha, gradientEndRed, gradientEndGreen, gradientEndBlue, gradientEndAlpha)
    CastBar.ApplyCastBarIconFrameVisual()
    CastBar.RefreshCastBarLabelVisibility()
end

-- -----------------------------------------------------------------------------
--- Resets cast bar position to default (center screen).
function CastBar.ResetCastBarPosition()
    ActionBar.SV.CastbarOffsetX = nil
    ActionBar.SV.CastbarOffsetY = nil
    ActionBar.SV.CastBarCustomPosition = nil
    CastBar.SetCastBarPosition()
    CastBar.SetMovingState(false)
end

-- -----------------------------------------------------------------------------
--- Console/gamepad position sliders: saved TOPLEFT offsets, or live control coords when using default anchor.
--- @return number
function CastBar.GetCastBarOffsetX()
    if ActionBar.SV.CastbarOffsetX ~= nil then
        return ActionBar.SV.CastbarOffsetX
    end
    if topLevelWindows.castBar and topLevelWindows.castBar.GetLeft then
        return topLevelWindows.castBar:GetLeft()
    end
    return 0
end

-- -----------------------------------------------------------------------------
--- @return number
function CastBar.GetCastBarOffsetY()
    if ActionBar.SV.CastbarOffsetY ~= nil then
        return ActionBar.SV.CastbarOffsetY
    end
    if topLevelWindows.castBar and topLevelWindows.castBar.GetTop then
        return topLevelWindows.castBar:GetTop()
    end
    return 320
end

-- -----------------------------------------------------------------------------
--- Positions cast bar from SV (custom or default); called on load and when unlocking movement.
function CastBar.SetCastBarPosition()
    if topLevelWindows.castBar and topLevelWindows.castBar:GetType() == CT_TOPLEVELCONTROL then
        topLevelWindows.castBar:ClearAnchors()

        if ActionBar.SV.CastbarOffsetX ~= nil and ActionBar.SV.CastbarOffsetY ~= nil then
            topLevelWindows.castBar:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ActionBar.SV.CastbarOffsetX, ActionBar.SV.CastbarOffsetY)
        else
            topLevelWindows.castBar:SetAnchor(CENTER, GuiRoot, CENTER, 0, 320)
        end
    end

    local savedPos = ActionBar.SV.CastBarCustomPosition
    topLevelWindows.castBar.preview.anchorLabel:SetText((savedPos ~= nil and #savedPos == 2) and zo_strformat("<<1>>, <<2>>", savedPos[1], savedPos[2]) or "default")
end

-- -----------------------------------------------------------------------------
---
--- @param isUnlockedForMove boolean
function CastBar.SetMovingState(isUnlockedForMove)
    if not ActionBar.Enabled then
        return
    end
    ActionBar.CastBarUnlocked = isUnlockedForMove
    if topLevelWindows.castBar and topLevelWindows.castBar:GetType() == CT_TOPLEVELCONTROL then
        CastBar.GenerateCastbarPreview(isUnlockedForMove)
        topLevelWindows.castBar:SetMouseEnabled(isUnlockedForMove)
        topLevelWindows.castBar:SetMovable(isUnlockedForMove)
    end
end

-- -----------------------------------------------------------------------------
-- Called by ActionBar.SetMovingState from the menu as well as by CastBar.OnUpdateCastbar when preview is enabled
---
--- @param showPreview boolean
function CastBar.GenerateCastbarPreview(showPreview)
    local previewIcon = "esoui/art/icons/icon_missing.dds"
    g_castBarState.icon:SetTexture(previewIcon)
    if ActionBar.SV.CastBarLabel then
        local previewName = "Test"
        g_castBarState.bar.name:SetText(previewName)
        g_castBarState.bar.name:SetHidden(not showPreview)
    else
        g_castBarState.bar.name:SetHidden(true)
    end
    if ActionBar.SV.CastBarTimer then
        g_castBarState.bar.timer:SetText(CastBar.FormatCastBarTimerText(1000))
        g_castBarState.bar.timer:SetHidden(not showPreview)
    end
    g_castBarState.bar.bar:SetValue(1)

    topLevelWindows.castBar.preview:SetHidden(not showPreview)
    topLevelWindows.castBar:SetHidden(not showPreview)
    g_castBarState:SetHidden(not showPreview)
end

-- -----------------------------------------------------------------------------
--- @param durationMs integer
function CastBar.SoulGemResurrectionStart(durationMs)
    CastBar.StopCastBar()
    local resurrectionIcon = "esoui/art/icons/achievement_frostvault_death_challenge.dds"
    local resurrectionLabel = Abilities.Innate_Soul_Gem_Resurrection
    CastBar.ShowCast(0, GetFrameTimeMilliseconds(), durationMs, false, resurrectionIcon, resurrectionLabel, false)
end

-- -----------------------------------------------------------------------------
--- Stops cast bar and clears resurrection state.
function CastBar.SoulGemResurrectionEnd()
    CastBar.StopCastBar()
end

-- Very basic handler registered to only read CC events on the player
--- - **EVENT_COMBAT_EVENT **
function CastBar.OnCombatEventBreakCast(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Some cast/channel abilities (or effects we use to simulate this) stun the player - ignore the effects of these ids when this happens.
    if Castbar.IgnoreCastBarStun[abilityId] or Castbar.IgnoreCastBreakingActions[g_castBarState.id] then
        return
    end

    CastBar.StopCastBar()
end

--- Player-source EVENT_COMBAT_EVENT handler for cast/channel display (registered as CombatEventCast).
function CastBar.HandleCombatEvent(result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    -- Bail out past here if the cast bar is disabled or
    if
    not ActionBar.SV.CastBarEnable or (
        (sourceType ~= COMBAT_UNIT_TYPE_PLAYER and not Castbar.CastOverride[abilityId]) -- source isn't the player and the ability is not on the list of abilities to show the cast bar for
        and (targetType ~= COMBAT_UNIT_TYPE_PLAYER or result ~= ACTION_RESULT_EFFECT_FADED)
    )                                                                                   -- target isn't the player with effect faded
    then
        return
    end

    -- Stop when a cast breaking action is detected
    if Castbar.CastBreakingActions[abilityId] then
        if not Castbar.IgnoreCastBreakingActions[g_castBarState.id] then
            CastBar.StopCastBar()
        end
    end

    local channelTrack = Castbar.CastChannelCombatTrack and Castbar.CastChannelCombatTrack[abilityId]
    if channelTrack then
        if result == ACTION_RESULT_EFFECT_FADED and targetType == COMBAT_UNIT_TYPE_PLAYER then
            castBarClearChannelSuppressForSlotted(channelTrack.slottedId)
            CastBar.StopCastBar()
            return
        end
        if  (result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION)
        and sourceType == COMBAT_UNIT_TYPE_PLAYER then
            if not CastBar.Private.IsCasting() then
                castBarClearChannelSuppressForSlotted(channelTrack.slottedId)
            end
            if castBarIsChannelUiDismissed(channelTrack.slottedId) or castBarIsAbilityShowCastSuppressed(channelTrack.slottedId) then
                -- logCastBar(("HandleCombatEvent skip trackAbility=%s slotted=%s reason=channelDismissedOrSuppress", castBarFormatAbilityRef(abilityId), castBarFormatAbilityRef(channelTrack.slottedId))
                return
            end
            if CastBar.Private.IsCasting() then
                local castId = CastBar.Private.GetState().id
                if castId == channelTrack.slottedId or castId == abilityId then
                    -- logCastBar(("HandleCombatEvent skip trackAbility=%s slotted=%s reason=channelSameCast", castBarFormatAbilityRef(abilityId), castBarFormatAbilityRef(channelTrack.slottedId))
                    return
                end
                -- Channel buff ticks while another cast is shown: do not override in-progress bar.
                -- logCastBar(("HandleCombatEvent skip trackAbility=%s slotted=%s reason=channelOtherCast cast=%s", castBarFormatAbilityRef(abilityId), castBarFormatAbilityRef(channelTrack.slottedId), castBarFormatAbilityRef(castId))
                return
            end
            if CastBar.Private.ShouldDedupeCombatCastStart(channelTrack.slottedId) then
                -- logCastBar(("HandleCombatEvent skip slotted=%s reason=channelDedupe", castBarFormatAbilityRef(channelTrack.slottedId))
                return
            end
            local durationMs = CastBar.ComputeCastDurationMs(
                channelTrack.slottedId,
                ACTION_RESULT_EFFECT_GAINED_DURATION,
                channelTrack.durationMs,
                true,
                channelTrack.durationMs)
            if durationMs > 0 then
                local icon, name = CastBar.GetCastDisplayNameAndIcon(channelTrack.slottedId)
                CastBar.ShowCast(channelTrack.slottedId, GetFrameTimeMilliseconds(), durationMs, true, icon, name, false)
            end
            return
        end
        return
    end

    local castAbilityIcon, castAbilityName = CastBar.GetCastDisplayNameAndIcon(abilityId)

    if not CastBar.ShouldShowOnCastBar(abilityId, castAbilityName) then
        local chInfo, castTimeMs = GetAbilityCastInfo(abilityId)
        -- logCastBar(("HandleCombatEvent skip ability=%s result=%s reason=notCastBarEligible channeled=%s castTimeMs=%s", castBarFormatAbilityRef(abilityId), tostring(result), tostring(chInfo), tostring(castTimeMs or 0))
        return
    end

    local duration
    local channeled, castTime = GetAbilityCastInfo(abilityId)
    local forceChanneled = false

    -- Override certain things to display as a channel rather than cast.
    -- Note only works for events where we override the duration.
    if Castbar.CastChannelOverride[abilityId] then
        channeled = true
    end

    duration = CastBar.ComputeCastDurationMs(abilityId, result, hitValue, channeled, castTime)

    local trackedSlottedChannel = castBarIsSlottedChannelCombatTracked(abilityId)
    local channelSlottedId = castBarResolveChannelSlottedCastId(abilityId)
    if channelSlottedId and channeled then
        if result == ACTION_RESULT_EFFECT_GAINED or result == ACTION_RESULT_EFFECT_GAINED_DURATION then
            if castBarIsChannelUiDismissed(channelSlottedId) or castBarIsAbilityShowCastSuppressed(channelSlottedId) then
                -- logCastBar(("HandleCombatEvent skip ability=%s slotted=%s reason=channelGateSuppress", castBarFormatAbilityRef(abilityId), castBarFormatAbilityRef(channelSlottedId))
                return
            end
            if CastBar.Private.IsCasting() then
                local castId = CastBar.Private.GetState().id
                if castId == channelSlottedId then
                    -- logCastBar(("HandleCombatEvent skip ability=%s reason=channelGateSameCast", castBarFormatAbilityRef(abilityId))
                    return
                end
                if castId and castId ~= 0 then
                    -- logCastBar(("HandleCombatEvent skip ability=%s reason=channelGateOtherCast cast=%s", castBarFormatAbilityRef(abilityId), castBarFormatAbilityRef(castId))
                    return
                end
            end
            if CastBar.Private.ShouldDedupeCombatCastStart(channelSlottedId) then
                -- logCastBar(("HandleCombatEvent skip ability=%s slotted=%s reason=channelGateDedupe", castBarFormatAbilityRef(abilityId), castBarFormatAbilityRef(channelSlottedId))
                return
            end
        end
    end

    -- End the cast bar and restart if a new begin event is detected and the effect isn't a channel or fake cast
    if result == ACTION_RESULT_BEGIN and not channeled and not Castbar.CastDurationFix[abilityId] then
        CastBar.StopCastBar()
    elseif not trackedSlottedChannel and result == ACTION_RESULT_EFFECT_GAINED_DURATION and channeled then
        CastBar.StopCastBar()
    elseif not trackedSlottedChannel and result == ACTION_RESULT_EFFECT_GAINED and channeled then
        CastBar.StopCastBar()
    elseif result == ACTION_RESULT_EFFECT_FADED and channeled then
        CastBar.StopCastBar()
    end

    if Castbar.CastChannelConvert[abilityId] then
        channeled = true
        forceChanneled = true
        duration = CastBar.ComputeCastDurationMs(abilityId, result, hitValue, true, castTime)
    end

    -- Some abilities cast into a channeled stun effect - we want these abilities to display the cast and channel if flagged.
    -- Only flags on ACTION_RESULT_BEGIN so this won't interfere with the stun result that is converted to dissplay a channeled cast.
    if Castbar.MultiCast[abilityId] then
        if result == 2200 then
            channeled = false
            duration = CastBar.ComputeCastDurationMs(abilityId, result, hitValue, false, castTime or 0)
        elseif result == 2240 then
            CastBar.StopCastBar() -- Stop the cast bar when the GAINED event happens so that we can display the channel when the cast ends
        end
    end

    -- Special handling for werewolf transform and transform back
    if abilityId == 39033 or abilityId == 39477 then
        local skillType, skillIndex, abilityIndex, morphChoice, rankIndex = GetSpecificSkillAbilityKeysByAbilityId(32455)
        castAbilityName, castAbilityIcon = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
        if abilityId == 39477 then
            castAbilityName = zo_strformat("<<1>> <<2>>", Abilities.Skill_Remove, castAbilityName)
        end
    end

    if duration > 0 then
        local combatShowFromGain = (result == ACTION_RESULT_EFFECT_GAINED and (Castbar.CastDurationFix[abilityId] or channeled))
            or (result == ACTION_RESULT_EFFECT_GAINED_DURATION and (Castbar.CastDurationFix[abilityId] or channeled))
        if trackedSlottedChannel and channeled and combatShowFromGain then
            -- logCastBar(("HandleCombatEvent skip ability=%s result=%s reason=trackedChannelUseCombatTrack", castBarFormatAbilityRef(abilityId), tostring(result))
        elseif (not forceChanneled and (((result == ACTION_RESULT_BEGIN or result == ACTION_RESULT_BEGIN_CHANNEL) and not channeled) or combatShowFromGain)) or (forceChanneled and result == ACTION_RESULT_BEGIN) then
            if CastBar.Private.ShouldDedupeCombatCastStart(abilityId) then
                -- logCastBar(("HandleCombatEvent skip ability=%s result=%s reason=combatDedupe", castBarFormatAbilityRef(abilityId), tostring(result))
                return
            end
            CastBar.ShowCast(abilityId, GetFrameTimeMilliseconds(), duration, channeled, castAbilityIcon, castAbilityName, false)
        else
            -- logCastBar(("HandleCombatEvent skip ability=%s result=%s duration=%s channeled=%s reason=resultGate", castBarFormatAbilityRef(abilityId), tostring(result), tostring(duration), tostring(channeled))
        end
    end

    -- Fix to lower the duration of the next cast of Profane Symbol quest ability for Scion of the Blood Matron (Vampire)
    if abilityId == 39507 then
        zo_callLater(function ()
                         Castbar.CastDurationFix[39507] = 19500
                     end, 5000)
    end
end

function CastBar.TickInterruptChecks()
    -- Break g_castBarState when block is used for certain effects.
    if g_casting then
        local castId = g_castBarState.id
        if castId and castId ~= 0 and not Castbar.IgnoreCastBreakingActions[castId] then
            if not IsPlayerStunned() then
                local blockActive = IsBlockActive()
                local breakForBlock = false
                if g_castBarBlockHeldAtStart then
                    if not blockActive then
                        g_castBarBlockReleasedDuringCast = true
                    elseif g_castBarBlockReleasedDuringCast and blockActive then
                        breakForBlock = true
                    end
                elseif blockActive then
                    breakForBlock = true
                end
                if breakForBlock then
                    if castBarIsChannelUiDismissed(castId) then
                        CastBar.StopCastBar()
                    else
                        castBarStopForBlockInterrupt(castId)
                    end
                end
            end
        end
    end

    if not g_casting then
        return
    end

    -- Break g_castBarState when movement interrupt is detected for certain effects.
    savedPlayerX = playerX
    savedPlayerZ = playerZ
    playerX, playerZ = GetMapPlayerPosition("player")
    if savedPlayerX == playerX and savedPlayerZ == playerZ then
        return
    else
        -- Fix if the player clicks on a Wayshrine in the World Map (suppress coord jump while not moving; real movement still breaks)
        if castBarShouldBreakCastOnMove(g_castBarState.id) then
            if g_castbarWorldMapFix == false or IsPlayerMoving() then
                local castId = g_castBarState.id
                -- logCastBar(("TickInterrupt moveBreak ability=%s worldMapFix=%s isMoving=%s", castBarFormatAbilityRef(castId), tostring(g_castbarWorldMapFix), tostring(IsPlayerMoving()))
                CastBar.StopCastBar()
                castBarSuppressAbilityBriefly(castId)
                castBarClearWorldMapFix()
            elseif g_castbarWorldMapFix == true then
                g_castbarWorldMapFix = false
            end
        elseif g_castbarWorldMapFix == true then
            g_castbarWorldMapFix = false
        end
    end
end
