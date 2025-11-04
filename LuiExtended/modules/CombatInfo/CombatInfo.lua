-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local UI = LUIE.UI
local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Abilities = Data.Abilities
local Castbar = Data.CastBarTable
local OtherAddonCompatability = LUIE.OtherAddonCompatability

local pairs = pairs
local printToChat = LUIE.PrintToChat
local GetSlotTrueBoundId = LUIE.GetSlotTrueBoundId
local GetAbilityDuration = GetAbilityDuration
local timeMs = GetFrameTimeMilliseconds
local zo_strformat = zo_strformat
local string_format = string.format
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()
local animationManager = GetAnimationManager()
local ACTION_RESULT_AREA_EFFECT = 669966

local moduleName = LUIE.name .. "CombatInfo"

-- Import CombatInfo namespace (declared in Namespace.lua)
--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo

-- Import sub-modules (loaded before this file)
--- @class (partial) ActionBar
local ActionBar = CombatInfo.ActionBar
--- @class (partial) CastBar
local CastBar = CombatInfo.CastBar
--- @class (partial) EventHandlers
local EventHandlers = CombatInfo.EventHandlers

-- Module-local state
local g_barFont
local g_potionFont
local g_ultimateFont
local g_castbarFont
local g_ProcSound

-- ===== HELPER FUNCTIONS =====

local function getAbilityName(abilityId, casterUnitTag)
    return GetAbilityName(abilityId, casterUnitTag)
end

-- ===== WRAPPER FUNCTIONS (delegate to sub-modules) =====

-- ActionBar wrappers
function CombatInfo.OnActionSlotEffectUpdated(eventCode, hotbarCategory, actionSlotIndex)
    ActionBar.OnActionSlotEffectUpdated(eventCode, hotbarCategory, actionSlotIndex)
end

function CombatInfo.GetTrackedAbilitiesForOverride()
    return ActionBar.GetTrackedAbilitiesForOverride()
end

function CombatInfo.ClearDurationOverrides()
    ActionBar.ClearDurationOverrides()
end

function CombatInfo.AddDurationOverride(input)
    ActionBar.AddDurationOverride(input)
end

function CombatInfo.RemoveDurationOverride(input)
    ActionBar.RemoveDurationOverride(input)
end

function CombatInfo.ListDurationOverrides()
    ActionBar.ListDurationOverrides()
end

function CombatInfo.ResetUltimateLabel()
    ActionBar.ResetUltimateLabel()
end

function CombatInfo.ResetBarLabel()
    ActionBar.ResetBarLabel()
end

function CombatInfo.ResetPotionTimerLabel()
    ActionBar.ResetPotionTimerLabel()
end

function CombatInfo.OnSlotUpdated(eventCode, slotNum)
    ActionBar.OnSlotUpdated(eventCode, slotNum)
end

function CombatInfo.BarSlotUpdate(slotNum, wasfullUpdate, onlyProc)
    ActionBar.BarSlotUpdate(slotNum, wasfullUpdate, onlyProc)
end

function CombatInfo.UpdateUltimateLabel()
    ActionBar.UpdateUltimateLabel()
end

function CombatInfo.InventoryItemUsed()
    ActionBar.InventoryItemUsed()
end

function CombatInfo.UpdateAllSlotsForActiveHotbar(didActiveHotbarChange)
    ActionBar.UpdateAllSlotsForActiveHotbar(didActiveHotbarChange)
end

function CombatInfo.OnSlotsFullUpdate()
    ActionBar.OnSlotsFullUpdate()
end

function CombatInfo.OnActiveWeaponPairChanged(eventCode, activeWeaponPair)
    ActionBar.OnActiveWeaponPairChanged(eventCode, activeWeaponPair)
end

function CombatInfo.OnPowerUpdatePlayer(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    ActionBar.OnPowerUpdatePlayer(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
end

function CombatInfo.OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
    ActionBar.OnInventorySlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
end

function CombatInfo.OnDeath(eventCode, unitTag, isDead)
    ActionBar.OnDeath(eventCode, unitTag, isDead)
end

function CombatInfo.HideSlot(slotNum, abilityId)
    ActionBar.HideSlot(slotNum, abilityId)
end

function CombatInfo.ShowSlot(slotNum, abilityId, currentTimeMs, desaturate)
    ActionBar.ShowSlot(slotNum, abilityId, currentTimeMs, desaturate)
end

function CombatInfo.BackbarSetupTemplate()
    ActionBar.BackbarSetupTemplate()
end

function CombatInfo.BackbarToggleSettings()
    ActionBar.BackbarToggleSettings()
end

function CombatInfo.BackbarHideSlot(slotNum)
    ActionBar.BackbarHideSlot(slotNum)
end

function CombatInfo.BackbarShowSlot(slotNum)
    ActionBar.BackbarShowSlot(slotNum)
end

function CombatInfo.HookGCD()
    ActionBar.HookGCD()
end

function CombatInfo.UpdateBarHighlightTables()
    ActionBar.UpdateBarHighlightTables()
end

-- CastBar wrappers
function CombatInfo.CreateCastBar()
    CastBar.Initialize()
end

function CombatInfo.ResizeCastBar()
    CastBar.ResizeCastBar()
end

function CombatInfo.UpdateCastBar()
    CastBar.UpdateCastBar()
end

function CombatInfo.ResetCastBarPosition()
    CastBar.ResetCastBarPosition()
end

function CombatInfo.SetCastBarPosition()
    CastBar.SetCastBarPosition()
end

function CombatInfo.SetMovingState(state)
    CastBar.SetMovingState(state)
end

function CombatInfo.GenerateCastbarPreview(state)
    CastBar.GenerateCastbarPreview(state)
end

function CombatInfo.StopCastBar()
    CastBar.StopCastBar()
end

function CombatInfo.SoulGemResurrectionStart(eventCode, durationMs)
    CastBar.SoulGemResurrectionStart(eventCode, durationMs)
end

function CombatInfo.SoulGemResurrectionEnd(eventCode)
    CastBar.SoulGemResurrectionEnd(eventCode)
end

function CombatInfo.OnCombatEventBreakCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    CastBar.OnCombatEventBreakCast(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
end

function CombatInfo.OnGameCameraUIModeChanged(eventCode)
    CastBar.OnGameCameraUIModeChanged(eventCode)
end

function CombatInfo.OnSiegeEnd(eventCode)
    CastBar.OnSiegeEnd(eventCode)
end

function CombatInfo.OnAbilityUsed(eventCode, actionSlotIndex)
    CastBar.OnAbilityUsed(eventCode, actionSlotIndex)
end

-- EventHandlers wrappers
function CombatInfo.OnTargetChange(eventCode, unitTag)
    EventHandlers.OnTargetChange(eventCode, unitTag)
end

function CombatInfo.OnReticleTargetChanged(eventCode)
    EventHandlers.OnReticleTargetChanged(eventCode)
end

function CombatInfo.BarHighlightSwap(abilityId)
    EventHandlers.BarHighlightSwap(abilityId)
end

function CombatInfo.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer, passThrough, savedId)
    EventHandlers.OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, castByPlayer, passThrough, savedId)
end

function CombatInfo.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    EventHandlers.OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
end

function CombatInfo.OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    EventHandlers.OnCombatEventBar(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
end

-- ===== CORE FUNCTIONS (stay in main module) =====

-- Set Marker
--- @param removeMarker boolean?
function CombatInfo.SetMarker(removeMarker)
    if removeMarker then
        eventManager:UnregisterForEvent(moduleName .. "Marker", EVENT_PLAYER_ACTIVATED)
        SetFloatingMarkerInfo(MAP_PIN_TYPE_AGGRO, CombatInfo.SV.markerSize, "", "", true, false)
    end
    if CombatInfo.SV.showMarker ~= true then
        return
    end
    local LUIE_MARKER = "/LuiExtended/media/combatinfo/floatingicon/redarrow.dds"
    SetFloatingMarkerInfo(MAP_PIN_TYPE_AGGRO, CombatInfo.SV.markerSize, LUIE_MARKER, "", true, false)
    eventManager:RegisterForEvent(moduleName .. "Marker", EVENT_PLAYER_ACTIVATED, CombatInfo.OnPlayerActivatedMarker)
end

-- Clear and then (maybe) re-register event listeners
function CombatInfo.RegisterCombatInfo()
    eventManager:RegisterForUpdate(moduleName .. "OnUpdate", 100, CombatInfo.OnUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, CombatInfo.OnPlayerActivated)

    eventManager:UnregisterForEvent(moduleName, EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED)
    if CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, CombatInfo.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BLOCKED_DAMAGE)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdatePlayer", EVENT_POWER_UPDATE, CombatInfo.OnPowerUpdatePlayer)
        eventManager:AddFilterForEvent(moduleName .. "PowerUpdatePlayer", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, CombatInfo.OnInventorySlotUpdate)
        eventManager:AddFilterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT, REGISTER_FILTER_IS_NEW_ITEM, false)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdate2", EVENT_ULTIMATE_ABILITY_COST_CHANGED, CombatInfo.UpdateUltimateLabel)
    end
    if CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled or CombatInfo.SV.CastBarEnable then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, CombatInfo.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
    end
    if CombatInfo.SV.CastBarEnable then
        local counter = 0
        for result, _ in pairs(Castbar.CastBreakingStatus) do
            local eventName = moduleName .. "CombatEventCC" .. tostring(counter)
            counter = counter + 1
            eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, CombatInfo.OnCombatEventBreakCast)
            eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, result)
        end
        eventManager:RegisterForEvent(moduleName, EVENT_START_SOUL_GEM_RESURRECTION, CombatInfo.SoulGemResurrectionStart)
        eventManager:RegisterForEvent(moduleName, EVENT_END_SOUL_GEM_RESURRECTION, CombatInfo.SoulGemResurrectionEnd)
        eventManager:RegisterForEvent(moduleName, EVENT_GAME_CAMERA_UI_MODE_CHANGED, CombatInfo.OnGameCameraUIModeChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_END_SIEGE_CONTROL, CombatInfo.OnSiegeEnd)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED, CombatInfo.OnAbilityUsed)
    end
    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled or CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
        local function OnActiveHotbarUpdated(event, didActiveHotbarChange)
            CombatInfo.UpdateAllSlotsForActiveHotbar(didActiveHotbarChange)
        end
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnActiveHotbarUpdated)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, CombatInfo.OnSlotsFullUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, CombatInfo.OnSlotsFullUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED, CombatInfo.OnSlotUpdated)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, CombatInfo.OnActiveWeaponPairChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_WEAPON_PAIR_LOCK_CHANGED, CombatInfo.OnActiveWeaponPairChanged)

        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_EFFECT_UPDATE, CombatInfo.OnActionSlotEffectUpdated)
    end
    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled then
        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, CombatInfo.OnDeath)
        eventManager:AddFilterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, CombatInfo.OnTargetChange)
        eventManager:AddFilterForEvent(moduleName, EVENT_TARGET_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
        eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, CombatInfo.OnReticleTargetChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, CombatInfo.BackbarSetupTemplate)

        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED, CombatInfo.InventoryItemUsed)

        ActionBar.UpdateBarHighlightTables()
    end
    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled or CombatInfo.SV.CastBarEnable or CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName, EVENT_EFFECT_CHANGED, CombatInfo.OnEffectChanged)
        eventManager:RegisterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED, CombatInfo.OnEffectChanged)
        eventManager:AddFilterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)
    end
    if not IsConsoleUI() and (CombatInfo.SV.UltimateLabelEnabled or CombatInfo.SV.UltimatePctEnabled) then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, 0, SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA)
    end
end

function CombatInfo.ClearCustomList(list)
    local listRef = list == CombatInfo.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    for k, v in pairs(list) do
        list[k] = nil
    end
    ZO_GetChatSystem():Maximize()
    ZO_GetChatSystem().primaryContainer:FadeIn()
    printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
end

function CombatInfo.AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == CombatInfo.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    if id and id > 0 then
        local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, getAbilityName(id))
        local name = cachedName
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
            list[id] = true
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
end

function CombatInfo.RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == CombatInfo.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CASTBAR_BLACKLIST) or ""
    if id and id > 0 then
        local cachedName = ZO_CachedStrFormat(SI_ABILITY_NAME, getAbilityName(id))
        local name = cachedName
        local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        ZO_GetChatSystem():Maximize()
        ZO_GetChatSystem().primaryContainer:FadeIn()
        printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            ZO_GetChatSystem():Maximize()
            ZO_GetChatSystem().primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
end

function CombatInfo.OnPlayerActivatedMarker(eventCode)
    CombatInfo.SetMarker()
end

-- Updates local variables with new font
function CombatInfo.ApplyFont()
    if not CombatInfo.Enabled then
        return
    end

    local function setupFont(fontNameKey, fontStyleKey, fontSizeKey, defaultFontStyle, defaultFontSize)
        local fontName = LUIE.Fonts[CombatInfo.SV[fontNameKey]]
        if not fontName or fontName == "" then
            LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
            fontName = "LUIE Default Font"
        end
        local fontStyle = CombatInfo.SV[fontStyleKey] or defaultFontStyle
        local fontSize = (CombatInfo.SV[fontSizeKey] and CombatInfo.SV[fontSizeKey] > 0) and CombatInfo.SV[fontSizeKey] or defaultFontSize
        return ZO_CreateFontString(fontName, fontSize, fontStyle)
    end

    g_barFont = setupFont("BarFontFace", "BarFontStyle", "BarFontSize", FONT_STYLE_OUTLINE, 17)
    g_potionFont = setupFont("PotionTimerFontFace", "PotionTimerFontStyle", "PotionTimerFontSize", FONT_STYLE_OUTLINE, 17)
    g_ultimateFont = setupFont("UltimateFontFace", "UltimateFontStyle", "UltimateFontSize", FONT_STYLE_OUTLINE, 17)
    g_castbarFont = setupFont("CastBarFontFace", "CastBarFontStyle", "CastBarFontSize", FONT_STYLE_SOFT_SHADOW_THIN, 16)

    ActionBar.SetupFonts(g_barFont, g_potionFont, g_ultimateFont, g_ProcSound)
    CastBar.SetupFont(g_castbarFont)
end

-- Updates Proc Sound
function CombatInfo.ApplyProcSound(menu)
    local barProcSound = LUIE.Sounds[CombatInfo.SV.ProcSoundName]
    if not barProcSound or barProcSound == "" then
        printToChat(GetString(LUIE_STRING_ERROR_SOUND), true)
        barProcSound = "DeathRecap_KillingBlowShown"
    end

    g_ProcSound = barProcSound

    ActionBar.SetupFonts(g_barFont, g_potionFont, g_ultimateFont, g_ProcSound)

    if menu then
        PlaySound(g_ProcSound)
    end
end

-- Used to populate abilities icons after the user has logged on
function CombatInfo.OnPlayerActivated(eventCode)
    eventManager:UnregisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED)

    if CombatInfo.SV.ShowTriggered or CombatInfo.SV.ShowToggled then
        if not IsConsoleUI() then
            ActionBar.SetActionBarTimersEnabled()
        end
    end

    CombatInfo.OnSlotsFullUpdate()
    for i = 53, 57 do
        CombatInfo.BarSlotUpdate(i, true, false)
    end
    CombatInfo.OnPowerUpdatePlayer(EVENT_POWER_UPDATE, "player", nil, COMBAT_MECHANIC_FLAGS_ULTIMATE, GetUnitPower("player", COMBAT_MECHANIC_FLAGS_ULTIMATE))
end

-- Main update ticker (coordinates all sub-modules)
function CombatInfo.OnUpdate(currentTimeMs)
    ActionBar.OnUpdate(currentTimeMs)
    CastBar.OnUpdate(currentTimeMs)
end

-- Module initialization
function CombatInfo.Initialize(enabled)
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        CombatInfo.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "CombatInfo", CombatInfo.Defaults)
    else
        CombatInfo.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "CombatInfo", CombatInfo.Defaults)
    end

    if not LUIE.IsMigrationDone("combatinfo_fontstyles") then
        CombatInfo.SV.UltimateFontStyle = LUIE.MigrateFontStyle(CombatInfo.SV.UltimateFontStyle)
        CombatInfo.SV.BarFontStyle = LUIE.MigrateFontStyle(CombatInfo.SV.BarFontStyle)
        CombatInfo.SV.PotionTimerFontStyle = LUIE.MigrateFontStyle(CombatInfo.SV.PotionTimerFontStyle)
        CombatInfo.SV.CastBarFontStyle = LUIE.MigrateFontStyle(CombatInfo.SV.CastBarFontStyle)
        if CombatInfo.SV.alerts and CombatInfo.SV.alerts.toggles then
            CombatInfo.SV.alerts.toggles.alertFontStyle = LUIE.MigrateFontStyle(CombatInfo.SV.alerts.toggles.alertFontStyle)
        end
        LUIE.MarkMigrationDone("combatinfo_fontstyles")
    end

    if not enabled then
        return
    end
    CombatInfo.Enabled = true

    CombatInfo.ApplyFont()
    CombatInfo.ApplyProcSound()

    -- Initialize sub-modules
    ActionBar.Initialize()
    CastBar.Initialize()

    CombatInfo.RegisterCombatInfo()

    if CombatInfo.SV.GlobalShowGCD then
        CombatInfo.HookGCD()
    end

    CombatInfo.SetMarker()

    CombatInfo.AbilityAlerts.CreateAlertFrame()
    CombatInfo.AbilityAlerts.SetAlertFramePosition()
    CombatInfo.AbilityAlerts.SetAlertColors()

    CombatInfo.CrowdControlTracker.UpdateAOEList()
    CombatInfo.CrowdControlTracker.Initialize()

    CombatInfo.InitializeSynergyTracker()

    if not LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCI then
        LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCI = 0
    end
    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCI < 2 then
        CombatInfo.SV.alerts.colors.stunColor = CombatInfo.Defaults.alerts.colors.stunColor
        CombatInfo.SV.alerts.colors.knockbackColor = CombatInfo.Defaults.alerts.colors.knockbackColor
        CombatInfo.SV.alerts.colors.levitateColor = CombatInfo.Defaults.alerts.colors.levitateColor
        CombatInfo.SV.alerts.colors.disorientColor = CombatInfo.Defaults.alerts.colors.disorientColor
        CombatInfo.SV.alerts.colors.fearColor = CombatInfo.Defaults.alerts.colors.fearColor
        CombatInfo.SV.alerts.colors.charmColor = CombatInfo.Defaults.alerts.colors.charmColor
        CombatInfo.SV.alerts.colors.silenceColor = CombatInfo.Defaults.alerts.colors.silenceColor
        CombatInfo.SV.alerts.colors.staggerColor = CombatInfo.Defaults.alerts.colors.staggerColor
        CombatInfo.SV.alerts.colors.unbreakableColor = CombatInfo.Defaults.alerts.colors.unbreakableColor
        CombatInfo.SV.alerts.colors.snareColor = CombatInfo.Defaults.alerts.colors.snareColor
        CombatInfo.SV.alerts.colors.rootColor = CombatInfo.Defaults.alerts.colors.rootColor
        CombatInfo.SV.cct.colors[ACTION_RESULT_STUNNED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_STUNNED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_KNOCKBACK] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_KNOCKBACK]
        CombatInfo.SV.cct.colors[ACTION_RESULT_LEVITATED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_LEVITATED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_DISORIENTED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_DISORIENTED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_FEARED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_FEARED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_CHARMED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_CHARMED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_SILENCED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_SILENCED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_STAGGERED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_STAGGERED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_IMMUNE] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_IMMUNE]
        CombatInfo.SV.cct.colors[ACTION_RESULT_DODGED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_DODGED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_BLOCKED] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_BLOCKED]
        CombatInfo.SV.cct.colors[ACTION_RESULT_BLOCKED_DAMAGE] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_BLOCKED_DAMAGE]
        CombatInfo.SV.cct.colors[ACTION_RESULT_AREA_EFFECT] = CombatInfo.Defaults.cct.colors[ACTION_RESULT_AREA_EFFECT]
        CombatInfo.SV.cct.colors.unbreakable = CombatInfo.Defaults.cct.colors.unbreakable
    end
    LUIESV["Default"][GetDisplayName()]["$AccountWide"].AdjustVarsCI = 2
end
