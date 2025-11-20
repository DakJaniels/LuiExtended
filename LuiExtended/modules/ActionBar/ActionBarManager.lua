-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local LuiData = LuiData
local Data = LuiData.Data
local Castbar = Data.CastBarTable

--- @class (partial) LUIE.ActionBar
local ActionBar = LUIE.ActionBar

local eventManager = GetEventManager()

local moduleName = LUIE.name .. "ActionBar"

-- Local handler functions

local function HandleCompanionPowerUpdate(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    if powerType == COMBAT_MECHANIC_FLAGS_ULTIMATE then
        ActionBar.OnPowerUpdateCompanion(eventCode, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    end
end

local function HandleActiveCompanionStateChanged(eventCode, newState, oldState)
    ActionBar.UpdateCompanionUltimateLabel()
    ActionBar.SetCompanionAnchors()
end

local function HandleCompanionActivated(eventCode, companionId)
    ActionBar.UpdateCompanionUltimateLabel()
    ActionBar.SetCompanionAnchors()
end

local function HandleCompanionDeactivated(eventCode)
    ActionBar.UpdateCompanionUltimateLabel()
    ActionBar.SetCompanionAnchors()
end

local function HandleUltimateAbilityCostChanged()
    ActionBar.UpdateCompanionUltimateLabel()
end

-- Clear and then (maybe) re-register event listeners
function ActionBar.RegisterEvents()
    if not ActionBar.Enabled then
        return
    end

    -- Unregister all ActionBar events first
    eventManager:UnregisterForEvent(moduleName, EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_ABILITY_USED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_BAR_LOCKED_REASON_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_BAR_IS_RESPECCABLE_BAR_STATE_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_TARGET_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_EFFECT_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT)
    eventManager:UnregisterForEvent(moduleName .. "PowerUpdatePlayer", EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "PowerUpdate2", EVENT_ULTIMATE_ABILITY_COST_CHANGED)
    eventManager:UnregisterForEvent(moduleName, EVENT_ACTION_SLOT_EFFECT_UPDATE)
    eventManager:UnregisterForEvent(moduleName, EVENT_ARMORY_BUILD_RESTORE_RESPONSE)
    eventManager:UnregisterForEvent(moduleName, EVENT_WEAPON_PAIR_LOCK_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "ActionCooldowns", EVENT_ACTION_UPDATE_COOLDOWNS)
    eventManager:UnregisterForEvent(moduleName .. "ActionEffectsCleared", EVENT_ACTION_SLOT_EFFECTS_CLEARED)
    eventManager:UnregisterForEvent(moduleName .. "InventoryFullUpdate", EVENT_INVENTORY_FULL_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "CursorPickup", EVENT_CURSOR_PICKUP)
    eventManager:UnregisterForEvent(moduleName .. "CursorDropped", EVENT_CURSOR_DROPPED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE)
    eventManager:UnregisterForEvent(moduleName .. "ActiveCompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionActivated", EVENT_COMPANION_ACTIVATED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionDeactivated", EVENT_COMPANION_DEACTIVATED)
    eventManager:UnregisterForEvent(moduleName .. "CompanionUltimateCost", EVENT_ULTIMATE_ABILITY_COST_CHANGED)
    eventManager:UnregisterForUpdate(moduleName .. "OnUpdate")
    eventManager:UnregisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED)

    -- Unregister CastBar events
    local counter = 0
    for result, _ in pairs(Castbar.CastBreakingStatus) do
        local eventName = moduleName .. "CombatEventCC" .. tostring(counter)
        eventManager:UnregisterForEvent(eventName, EVENT_COMBAT_EVENT)
        counter = counter + 1
    end
    eventManager:UnregisterForEvent(moduleName .. "CastBarSoulGemStart", EVENT_START_SOUL_GEM_RESURRECTION)
    eventManager:UnregisterForEvent(moduleName .. "CastBarSoulGemEnd", EVENT_END_SOUL_GEM_RESURRECTION)
    eventManager:UnregisterForEvent(moduleName .. "CastBarCameraUI", EVENT_GAME_CAMERA_UI_MODE_CHANGED)
    eventManager:UnregisterForEvent(moduleName .. "CastBarSiegeEnd", EVENT_END_SIEGE_CONTROL)
    eventManager:UnregisterForEvent(moduleName .. "CastBarAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED)
    eventManager:UnregisterForEvent(moduleName .. "CastBarCombatEvent", EVENT_COMBAT_EVENT)

    -- Register Ultimate tracking events
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, ActionBar.EventHandlers.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BLOCKED_DAMAGE)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdatePlayer", EVENT_POWER_UPDATE, ActionBar.OnPowerUpdatePlayer)
        eventManager:AddFilterForEvent(moduleName .. "PowerUpdatePlayer", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ActionBar.OnInventorySlotUpdate)
        eventManager:AddFilterForEvent(moduleName .. "InventoryUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT, REGISTER_FILTER_IS_NEW_ITEM, false)
        eventManager:RegisterForEvent(moduleName .. "PowerUpdate2", EVENT_ULTIMATE_ABILITY_COST_CHANGED, ActionBar.UpdateUltimateLabel)
    end

    -- Register events for Ultimate or CastBar
    if ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled or ActionBar.SV.CastBarEnable then
        eventManager:RegisterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, ActionBar.EventHandlers.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CombatEvent2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
    end

    -- Register CastBar events if enabled
    if ActionBar.SV.CastBarEnable and ActionBar.CastBar then
        counter = 0
        for result, _ in pairs(Castbar.CastBreakingStatus) do
            local eventName = moduleName .. "CombatEventCC" .. tostring(counter)
            counter = counter + 1
            eventManager:RegisterForEvent(eventName, EVENT_COMBAT_EVENT, ActionBar.CastBar.OnCombatEventBreakCast)
            eventManager:AddFilterForEvent(eventName, EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false, REGISTER_FILTER_COMBAT_RESULT, result)
        end
        eventManager:RegisterForEvent(moduleName .. "CastBarSoulGemStart", EVENT_START_SOUL_GEM_RESURRECTION, ActionBar.CastBar.SoulGemResurrectionStart)
        eventManager:RegisterForEvent(moduleName .. "CastBarSoulGemEnd", EVENT_END_SOUL_GEM_RESURRECTION, ActionBar.CastBar.SoulGemResurrectionEnd)
        eventManager:RegisterForEvent(moduleName .. "CastBarCameraUI", EVENT_GAME_CAMERA_UI_MODE_CHANGED, ActionBar.CastBar.OnGameCameraUIModeChanged)
        eventManager:RegisterForEvent(moduleName .. "CastBarSiegeEnd", EVENT_END_SIEGE_CONTROL, ActionBar.CastBar.OnSiegeEnd)
        eventManager:RegisterForEvent(moduleName .. "CastBarAbilityUsed", EVENT_ACTION_SLOT_ABILITY_USED, ActionBar.CastBar.OnAbilityUsed)
        eventManager:RegisterForEvent(moduleName .. "CastBarCombatEvent", EVENT_COMBAT_EVENT, ActionBar.CastBar.OnCombatEvent)
        eventManager:AddFilterForEvent(moduleName .. "CastBarCombatEvent", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)
    end

    -- Register action bar slot events
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled or ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        local function OnActiveHotbarUpdated(event, didActiveHotbarChange)
            ActionBar.UpdateAllSlotsForActiveHotbar(didActiveHotbarChange)
        end
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ACTIVE_HOTBAR_UPDATED, OnActiveHotbarUpdated)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOTS_ALL_HOTBARS_UPDATED, ActionBar.OnSlotsFullUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_ARMORY_BUILD_RESTORE_RESPONSE, ActionBar.OnSlotsFullUpdate)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_UPDATED, ActionBar.OnSlotUpdated)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_WEAPON_PAIR_CHANGED, ActionBar.OnActiveWeaponPairChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_WEAPON_PAIR_LOCK_CHANGED, ActionBar.OnActiveWeaponPairChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_BAR_LOCKED_REASON_CHANGED, ActionBar.OnActionBarLockedReasonChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_BAR_IS_RESPECCABLE_BAR_STATE_CHANGED, ActionBar.OnActionBarIsRespeccableBarStateChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_ACTIVE_DAEDRIC_ARTIFACT_CHANGED, ActionBar.OnActiveDaedricArtifactChanged)

        eventManager:RegisterForEvent(moduleName, EVENT_ACTION_SLOT_EFFECT_UPDATE, ActionBar.OnActionSlotEffectUpdated)
    end

    -- Register triggered/toggled ability events
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled then
        eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, ActionBar.OnDeath)
        eventManager:AddFilterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
        eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, ActionBar.EventHandlers.OnTargetChange)
        eventManager:AddFilterForEvent(moduleName, EVENT_TARGET_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")
        eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, ActionBar.EventHandlers.OnReticleTargetChanged)
        eventManager:RegisterForEvent(moduleName, EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, ActionBar.BackbarSetupTemplate)

        eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_USED, ActionBar.InventoryItemUsed)

        ActionBar.UpdateBarHighlightTables()
    end

    -- Register effect changed events
    if ActionBar.SV.ShowTriggered or ActionBar.SV.ShowToggled or ActionBar.SV.CastBarEnable or ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled then
        eventManager:RegisterForEvent(moduleName, EVENT_EFFECT_CHANGED, ActionBar.EventHandlers.OnEffectChanged)
        eventManager:RegisterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED, ActionBar.EventHandlers.OnEffectChanged)
        eventManager:AddFilterForEvent(moduleName .. "Pet", EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET)
    end

    -- Hide default ultimate number if our labels are enabled
    if not IsConsoleUI() and (ActionBar.SV.UltimateLabelEnabled or ActionBar.SV.UltimatePctEnabled) then
        SetSetting(SETTING_TYPE_UI, UI_SETTING_ULTIMATE_NUMBER, 0, SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA)
    end

    -- Register always-on events (not conditional)
    eventManager:RegisterForEvent(moduleName .. "ActionCooldowns", EVENT_ACTION_UPDATE_COOLDOWNS, ActionBar.HandleActionUpdateCooldowns)
    eventManager:RegisterForEvent(moduleName .. "ActionEffectsCleared", EVENT_ACTION_SLOT_EFFECTS_CLEARED, ActionBar.OnSlotsFullUpdate)
    eventManager:RegisterForEvent(moduleName .. "InventoryFullUpdate", EVENT_INVENTORY_FULL_UPDATE, ActionBar.OnSlotsFullUpdate)
    eventManager:RegisterForEvent(moduleName .. "CursorPickup", EVENT_CURSOR_PICKUP, ActionBar.HandleCursorPickup)
    eventManager:RegisterForEvent(moduleName .. "CursorDropped", EVENT_CURSOR_DROPPED, ActionBar.HandleCursorDropped)

    -- Register companion ultimate power updates
    eventManager:RegisterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE, HandleCompanionPowerUpdate)
    eventManager:AddFilterForEvent(moduleName .. "CompanionPower", EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_ULTIMATE, REGISTER_FILTER_UNIT_TAG, "companion")

    -- Register companion state changes
    eventManager:RegisterForEvent(moduleName .. "ActiveCompanionState", EVENT_ACTIVE_COMPANION_STATE_CHANGED, HandleActiveCompanionStateChanged)
    eventManager:RegisterForEvent(moduleName .. "CompanionActivated", EVENT_COMPANION_ACTIVATED, HandleCompanionActivated)
    eventManager:RegisterForEvent(moduleName .. "CompanionDeactivated", EVENT_COMPANION_DEACTIVATED, HandleCompanionDeactivated)
    eventManager:RegisterForEvent(moduleName .. "CompanionUltimateCost", EVENT_ULTIMATE_ABILITY_COST_CHANGED, HandleUltimateAbilityCostChanged)

    -- Register update ticker and player activated event
    eventManager:RegisterForUpdate(moduleName .. "OnUpdate", 100, ActionBar.OnUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, ActionBar.OnPlayerActivated)
end
