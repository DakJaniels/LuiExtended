-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

MiniMap.sessionMapVisible = true
MiniMap.consoleLayoutPreviewActive = false

local LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME = "LibHarvensAddonSettingsScene"

--- @return boolean
function MiniMap.IsPlayerInHouse()
    return GetCurrentZoneHouseId() ~= 0
end

--- @return boolean
function MiniMap.IsDeathRecapVisible()
    return not DEATH_RECAP_FRAGMENT:IsHidden()
end

function MiniMap.RegisterDeathRecapVisibilityHook()
    if MiniMap.deathRecapVisibilityHookRegistered then
        return
    end
    MiniMap.deathRecapVisibilityHookRegistered = true

    DEATH_RECAP_FRAGMENT:RegisterCallback("StateChange", function ()
        MiniMap.ApplyFragmentHiddenReasons()
        MiniMap.UpdateGameplayTickers()
    end)

    DEATH_RECAP:RegisterCallback("OnDeathRecapAvailableChanged", function ()
        MiniMap.ApplyFragmentHiddenReasons()
        MiniMap.UpdateGameplayTickers()
    end)
end

--- @return boolean
function MiniMap.GetContextAllowsMiniMap()
    if not MiniMap.Enabled then
        return false
    end
    if MiniMap.sessionMapVisible == false then
        return false
    end
    if MiniMap.SV.allowOnGameplayHud == false then
        return false
    end
    if IsUnitInCombat("player") and MiniMap.SV.allowDuringCombat ~= true then
        return false
    end
    if IsMounted() and MiniMap.SV.allowWhileMounted ~= true then
        return false
    end
    if MiniMap.IsPlayerInHouse() and MiniMap.SV.allowInPlayerHousing ~= true then
        return false
    end
    return true
end

function MiniMap.UpdateConditionalVisibility()
    if not MiniMap.Enabled or not MiniMap.view then
        return
    end
    local scene = SCENE_MANAGER:GetCurrentScene()
    if not MiniMap.IsMiniMapHudScene(scene) then
        return
    end
    MiniMap.ApplyFragmentHiddenReasons()
    MiniMap.ApplyCompassMode()
end

function MiniMap.ToggleShowMap()
    if not MiniMap.Enabled then
        return
    end
    MiniMap.sessionMapVisible = not MiniMap.sessionMapVisible
    MiniMap.UpdateConditionalVisibility()
    local message = MiniMap.sessionMapVisible and GetString(LUIE_STRING_MINIMAP_TOGGLE_SHOW_ON) or GetString(LUIE_STRING_MINIMAP_TOGGLE_SHOW_OFF)
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
    messageParams:SetText(message)
    messageParams:SetSound(SOUNDS.NONE)
    messageParams:SetLifespanMS(5000)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function MiniMap.ToggleShowInCombatSetting()
    MiniMap.SV.allowDuringCombat = not MiniMap.SV.allowDuringCombat
    MiniMap.UpdateConditionalVisibility()
end

--- Console: show MiniMap while LibHarvens addon settings are open (layout sliders).
--- @param active boolean
function MiniMap.SetConsoleLayoutPreviewActive(active)
    local wantActive = active == true
    if MiniMap.consoleLayoutPreviewActive == wantActive then
        return
    end
    MiniMap.consoleLayoutPreviewActive = wantActive

    local hudSceneFragment = MiniMap.hudSceneFragment
    local settingsScene = SCENE_MANAGER:GetScene(LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME)
    if wantActive then
        MiniMap.sessionMapVisible = true
        if hudSceneFragment and settingsScene and not settingsScene:HasFragment(hudSceneFragment) then
            settingsScene:AddFragment(hudSceneFragment)
        end
    elseif hudSceneFragment and settingsScene and settingsScene:HasFragment(hudSceneFragment) then
        settingsScene:RemoveFragment(hudSceneFragment)
    end

    MiniMap.ApplyFragmentHiddenReasons()
    MiniMap.UpdateGameplayTickers()
end

function MiniMap.ShowMapNowForConsoleLayout()
    if not MiniMap.Enabled or not ZO_IsConsoleOrGameCoreUI() then
        return
    end
    MiniMap.SetConsoleLayoutPreviewActive(true)
    MiniMap.ApplyFrameLayoutFromSavedSettings()
    if MiniMap.mapController and MiniMap.mapController:IsReady() then
        MiniMap.RefreshNativeWorldMapContainer()
    end
end

function MiniMap.ToggleConsoleLayoutPreview()
    if not MiniMap.Enabled or not ZO_IsConsoleOrGameCoreUI() then
        return
    end
    if MiniMap.consoleLayoutPreviewActive then
        MiniMap.SetConsoleLayoutPreviewActive(false)
    else
        MiniMap.ShowMapNowForConsoleLayout()
    end
end

function MiniMap.RegisterConsoleLayoutPreviewSettingsSceneHook()
    if MiniMap.consoleLayoutPreviewSettingsSceneHooked or not ZO_IsConsoleOrGameCoreUI() then
        return
    end
    local settingsScene = SCENE_MANAGER:GetScene(LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME)
    if not settingsScene then
        return
    end
    MiniMap.consoleLayoutPreviewSettingsSceneHooked = true
    settingsScene:RegisterCallback("StateChange", function (_, newState)
        if newState == SCENE_HIDDEN then
            MiniMap.SetConsoleLayoutPreviewActive(false)
        end
    end)
end

function MiniMap.ApplyDrawLayerPreference()
    if not MiniMap.view then
        return
    end
    local root = MiniMap.view.root
    if MiniMap.SV and MiniMap.SV.preferElevatedDrawTier == true then
        root:SetDrawLayer(DL_OVERLAY)
        root:SetDrawTier(DT_HIGH)
    else
        root:SetDrawLayer(DL_CONTROLS)
        root:SetDrawTier(DT_MEDIUM)
    end
end

function MiniMap.RegisterVisibilityEvents()
    local anchor = LUIE_MiniMap
    anchor:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function ()
        MiniMap.UpdateConditionalVisibility()
    end)
    anchor:RegisterForEvent(EVENT_MOUNTED_STATE_CHANGED, function ()
        MiniMap.UpdateConditionalVisibility()
    end)
    anchor:RegisterForEvent(EVENT_HOUSING_PLAYER_INFO_CHANGED, function ()
        MiniMap.UpdateConditionalVisibility()
    end)
    anchor:RegisterForEvent(EVENT_PLAYER_DEAD, function ()
        MiniMap.ApplyFragmentHiddenReasons()
        MiniMap.UpdateGameplayTickers()
    end)
    anchor:RegisterForEvent(EVENT_PLAYER_ALIVE, function ()
        MiniMap.ApplyFragmentHiddenReasons()
        MiniMap.UpdateGameplayTickers()
    end)
    MiniMap.RegisterDeathRecapVisibilityHook()
    MiniMap.RegisterConsoleLayoutPreviewSettingsSceneHook()
end
