-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) LUIE.MiniMap
local MiniMap = LUIE.MiniMap

local HudScene = LUIE.HudScene

local WORLD_MAP_SCENE_NAME_KEYBOARD = "worldMap"
local WORLD_MAP_SCENE_NAME_GAMEPAD = "gamepad_worldMap"
local LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME = "LibHarvensAddonSettingsScene"
local CONSOLE_PREVIEW_CLEARED_REASONS = { "MiniMapSession", "MiniMapCombat", "MiniMapMounted", "MiniMapHousing" }

-- HUD fragment ---------------------------------------------------------------

--- ZO_HUDFadeSceneFragment (EsoUI/Libraries/ZO_Scene/ZO_SceneFragmentTemplates.lua:589-697) with
--- ZO_HideableSceneFragmentMixin:SetHiddenForReason (560) for the conditional hide reasons.
--- @class LUIE_MiniMap_HudSceneFragment : ZO_HUDFadeSceneFragment
--- @field visibility LUIE_MiniMap_Visibility
--- @field SetHiddenForReason fun(self: LUIE_MiniMap_HudSceneFragment, reason: string, hidden: boolean, customShowDuration?: number, customHideDuration?: number)
LUIE_MiniMap_HudSceneFragment = ZO_HUDFadeSceneFragment:Subclass()

--- @param control Control
--- @param visibility LUIE_MiniMap_Visibility
--- @return LUIE_MiniMap_HudSceneFragment
function LUIE_MiniMap_HudSceneFragment:New(control, visibility)
    local fragment = ZO_HUDFadeSceneFragment.New(self, control, visibility)
    --- @cast fragment LUIE_MiniMap_HudSceneFragment
    return fragment
end

--- @param control Control
--- @param visibility LUIE_MiniMap_Visibility
function LUIE_MiniMap_HudSceneFragment:Initialize(control, visibility)
    ZO_HUDFadeSceneFragment.Initialize(self, control, 0, 0)
    self.visibility = visibility
end

function LUIE_MiniMap_HudSceneFragment:OnShown()
    ZO_HUDFadeSceneFragment.OnShown(self)
    self.visibility:OnFragmentShown()
end

function LUIE_MiniMap_HudSceneFragment:OnHidden()
    ZO_HUDFadeSceneFragment.OnHidden(self)
    self.visibility:OnFragmentHidden()
end

-- Visibility -----------------------------------------------------------------

--- HUD scene attachment, hide reasons (session toggle, combat, mounted, housing, death recap), loot scene
--- attachment, world-map scene gates and the console layout preview.
--- @class LUIE_MiniMap_Visibility : ZO_InitializingObject
--- @field manager LUIE_MiniMap_Manager
--- @field root TopLevelWindow
--- @field fragment LUIE_MiniMap_HudSceneFragment|nil
--- @field hiddenReasonCache table<string, boolean>
--- @field sessionMapVisible boolean
--- @field consoleLayoutPreviewActive boolean
--- @field registered boolean
--- @field worldMapKeyboardSceneHandler fun(oldState: string, newState: string)|nil
--- @field worldMapGamepadSceneHandler fun(oldState: string, newState: string)|nil
--- @field deathRecapFragmentHandler fun()|nil
--- @field deathRecapAvailableHandler fun()|nil
--- @field consoleSettingsSceneHandler fun(oldState: string, newState: string)|nil
LUIE_MiniMap_Visibility = ZO_InitializingObject:Subclass()

--- @param manager LUIE_MiniMap_Manager
--- @param rootControl TopLevelWindow
function LUIE_MiniMap_Visibility:Initialize(manager, rootControl)
    self.manager = manager
    self.root = rootControl
    self.fragment = nil
    self.hiddenReasonCache = {}
    self.sessionMapVisible = true
    self.consoleLayoutPreviewActive = false
    self.registered = false
end

--- @return boolean
function LUIE_MiniMap_Visibility:IsFragmentShowing()
    return self.fragment ~= nil and self.fragment:IsShowing()
end

--- @param scene ZO_Scene|nil
--- @return boolean
function LUIE_MiniMap_Visibility:IsMiniMapHudScene(scene)
    if not HudScene.IsHudGameplayScene(scene) then
        return false
    end
    if scene == LOOT_SCENE then
        return MiniMap.SV.allowOnLootScene == true
    end
    return true
end

--- @return boolean
function LUIE_MiniMap_Visibility.IsPlayerInHouse()
    return GetCurrentZoneHouseId() ~= 0
end

--- @return boolean
function LUIE_MiniMap_Visibility.IsDeathRecapVisible()
    return not DEATH_RECAP_FRAGMENT:IsHidden()
end

-- Registration ---------------------------------------------------------------

function LUIE_MiniMap_Visibility:Register()
    if self.registered then
        return
    end
    self.registered = true

    self.fragment = LUIE_MiniMap_HudSceneFragment:New(self.root, self)
    HudScene.AddFragmentToScenes(self.fragment, HudScene.GetGameplayScenesExcludingLoot())
    self:SyncLootSceneAttachment()

    -- World map scene gates: pause pin entry work while the world map is on screen.
    self.worldMapKeyboardSceneHandler = function (oldState, newState)
        self:OnWorldMapSceneStateChange(WORLD_MAP_SCENE_NAME_KEYBOARD, newState)
    end
    self.worldMapGamepadSceneHandler = function (oldState, newState)
        self:OnWorldMapSceneStateChange(WORLD_MAP_SCENE_NAME_GAMEPAD, newState)
    end
    WORLD_MAP_SCENE:RegisterCallback("StateChange", self.worldMapKeyboardSceneHandler)
    GAMEPAD_WORLD_MAP_SCENE:RegisterCallback("StateChange", self.worldMapGamepadSceneHandler)

    -- Death recap (EsoUI/Ingame/DeathRecap: DEATH_RECAP_FRAGMENT, DEATH_RECAP "OnDeathRecapAvailableChanged").
    self.deathRecapFragmentHandler = function ()
        self:ApplyHiddenReasons()
    end
    self.deathRecapAvailableHandler = function ()
        self:ApplyHiddenReasons()
    end
    DEATH_RECAP_FRAGMENT:RegisterCallback("StateChange", self.deathRecapFragmentHandler)
    DEATH_RECAP:RegisterCallback("OnDeathRecapAvailableChanged", self.deathRecapAvailableHandler)

    local root = self.root
    root:RegisterForEvent(EVENT_PLAYER_COMBAT_STATE, function ()
        self:UpdateConditionalVisibility()
    end)
    root:RegisterForEvent(EVENT_MOUNTED_STATE_CHANGED, function ()
        self:UpdateConditionalVisibility()
        self.manager:OnMountedStateChanged()
    end)
    root:RegisterForEvent(EVENT_HOUSING_PLAYER_INFO_CHANGED, function ()
        self:UpdateConditionalVisibility()
    end)
    root:RegisterForEvent(EVENT_PLAYER_DEAD, function ()
        self:ApplyHiddenReasons()
    end)
    root:RegisterForEvent(EVENT_PLAYER_ALIVE, function ()
        self:ApplyHiddenReasons()
    end)

    self:RegisterConsoleLayoutPreviewSettingsSceneHook()

    if ZO_WorldMap_IsWorldMapShowing() then
        local sceneName = WORLD_MAP_SCENE_NAME_KEYBOARD
        if SCENE_MANAGER:IsShowing(WORLD_MAP_SCENE_NAME_GAMEPAD) then
            sceneName = WORLD_MAP_SCENE_NAME_GAMEPAD
        end
        self:OnWorldMapOpening(sceneName)
    end
    self:ApplyHiddenReasons()
end

function LUIE_MiniMap_Visibility:Unregister()
    if not self.registered then
        return
    end
    self.registered = false
    self:SetConsoleLayoutPreviewActive(false)

    WORLD_MAP_SCENE:UnregisterCallback("StateChange", self.worldMapKeyboardSceneHandler)
    GAMEPAD_WORLD_MAP_SCENE:UnregisterCallback("StateChange", self.worldMapGamepadSceneHandler)
    DEATH_RECAP_FRAGMENT:UnregisterCallback("StateChange", self.deathRecapFragmentHandler)
    DEATH_RECAP:UnregisterCallback("OnDeathRecapAvailableChanged", self.deathRecapAvailableHandler)
    local settingsScene = SCENE_MANAGER:GetScene(LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME)
    if settingsScene and self.consoleSettingsSceneHandler then
        settingsScene:UnregisterCallback("StateChange", self.consoleSettingsSceneHandler)
    end
    self.consoleSettingsSceneHandler = nil

    local root = self.root
    root:UnregisterForEvent(EVENT_PLAYER_COMBAT_STATE)
    root:UnregisterForEvent(EVENT_MOUNTED_STATE_CHANGED)
    root:UnregisterForEvent(EVENT_HOUSING_PLAYER_INFO_CHANGED)
    root:UnregisterForEvent(EVENT_PLAYER_DEAD)
    root:UnregisterForEvent(EVENT_PLAYER_ALIVE)

    if self.fragment then
        local scenesToClear = HudScene.GetGameplayScenesExcludingLoot()
        scenesToClear[#scenesToClear + 1] = LOOT_SCENE
        HudScene.RemoveFragmentFromScenes(self.fragment, scenesToClear)
        self.fragment = nil
    end
    self.hiddenReasonCache = {}
    self.sessionMapVisible = true
end

-- Fragment callbacks ---------------------------------------------------------

function LUIE_MiniMap_Visibility:OnFragmentShown()
    self.manager:OnFragmentShown()
end

function LUIE_MiniMap_Visibility:OnFragmentHidden()
    self.manager:OnFragmentHidden()
end

-- Hide reasons ---------------------------------------------------------------

--- @param reason string
--- @param hidden boolean
function LUIE_MiniMap_Visibility:SetHiddenReasonIfChanged(reason, hidden)
    if self.hiddenReasonCache[reason] == hidden then
        return
    end
    self.hiddenReasonCache[reason] = hidden
    self.fragment:SetHiddenForReason(reason, hidden)
end

function LUIE_MiniMap_Visibility:ApplyHiddenReasons()
    if not self.fragment then
        return
    end
    if self.consoleLayoutPreviewActive then
        for reasonIndex = 1, #CONSOLE_PREVIEW_CLEARED_REASONS do
            self:SetHiddenReasonIfChanged(CONSOLE_PREVIEW_CLEARED_REASONS[reasonIndex], false)
        end
        return
    end
    local settings = MiniMap.SV
    self:SetHiddenReasonIfChanged("MiniMapSession", self.sessionMapVisible == false or settings.allowOnGameplayHud == false)
    self:SetHiddenReasonIfChanged("MiniMapCombat", IsUnitInCombat("player") and settings.allowDuringCombat ~= true)
    self:SetHiddenReasonIfChanged("MiniMapMounted", IsMounted() and settings.allowWhileMounted ~= true)
    self:SetHiddenReasonIfChanged("MiniMapHousing", LUIE_MiniMap_Visibility.IsPlayerInHouse() and settings.allowInPlayerHousing ~= true)
    self:SetHiddenReasonIfChanged("MiniMapDeathRecap", LUIE_MiniMap_Visibility.IsDeathRecapVisible() and settings.allowOnDeathRecap == false)
end

function LUIE_MiniMap_Visibility:UpdateConditionalVisibility()
    if not self:IsMiniMapHudScene(SCENE_MANAGER:GetCurrentScene()) then
        return
    end
    self:ApplyHiddenReasons()
end

--- Keybind: hide/show for this session with a small CSA.
function LUIE_MiniMap_Visibility:ToggleShowMap()
    self.sessionMapVisible = not self.sessionMapVisible
    self:UpdateConditionalVisibility()
    local message = GetString(LUIE_STRING_MINIMAP_TOGGLE_SHOW_OFF)
    if self.sessionMapVisible then
        message = GetString(LUIE_STRING_MINIMAP_TOGGLE_SHOW_ON)
    end
    local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_SMALL_TEXT, SOUNDS.NONE)
    messageParams:SetText(message)
    messageParams:SetSound(SOUNDS.NONE)
    messageParams:SetLifespanMS(5000)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)
end

function LUIE_MiniMap_Visibility:ToggleShowInCombatSetting()
    MiniMap.SV.allowDuringCombat = not MiniMap.SV.allowDuringCombat
    self:UpdateConditionalVisibility()
end

function LUIE_MiniMap_Visibility:SyncLootSceneAttachment()
    if not self.fragment then
        return
    end
    if MiniMap.SV.allowOnLootScene == true then
        HudScene.AddFragmentToScenes(self.fragment, { LOOT_SCENE })
    else
        HudScene.RemoveFragmentFromScenes(self.fragment, { LOOT_SCENE })
    end
end

-- World map scene gates ------------------------------------------------------

--- @param sceneName string
--- @param newState string
function LUIE_MiniMap_Visibility:OnWorldMapSceneStateChange(sceneName, newState)
    if newState == SCENE_SHOWING then
        self:OnWorldMapOpening(sceneName)
    end
end

--- @param sceneName string
function LUIE_MiniMap_Visibility:OnWorldMapOpening(sceneName)
    self.manager:OnWorldMapOpening()
    SCENE_MANAGER:CallWhen(sceneName, SCENE_HIDDEN, function ()
        if self.registered then
            self.manager:OnWorldMapClosed()
        end
    end)
end

-- Console layout preview -----------------------------------------------------

--- Console: keep the minimap on screen while the LibHarvens settings scene is open (layout sliders).
--- @param active boolean
function LUIE_MiniMap_Visibility:SetConsoleLayoutPreviewActive(active)
    local wantActive = active == true
    if self.consoleLayoutPreviewActive == wantActive then
        return
    end
    self.consoleLayoutPreviewActive = wantActive

    local settingsScene = SCENE_MANAGER:GetScene(LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME)
    if wantActive then
        self.sessionMapVisible = true
        if self.fragment and settingsScene and not settingsScene:HasFragment(self.fragment) then
            settingsScene:AddFragment(self.fragment)
        end
    elseif self.fragment and settingsScene and settingsScene:HasFragment(self.fragment) then
        settingsScene:RemoveFragment(self.fragment)
    end
    self:ApplyHiddenReasons()
end

function LUIE_MiniMap_Visibility:ShowMapNowForConsoleLayout()
    if not ZO_IsConsoleOrGameCoreUI() then
        return
    end
    self:SetConsoleLayoutPreviewActive(true)
    self.manager.frame:ApplyLayoutFromSavedSettings()
end

function LUIE_MiniMap_Visibility:ToggleConsoleLayoutPreview()
    if not ZO_IsConsoleOrGameCoreUI() then
        return
    end
    if self.consoleLayoutPreviewActive then
        self:SetConsoleLayoutPreviewActive(false)
    else
        self:ShowMapNowForConsoleLayout()
    end
end

function LUIE_MiniMap_Visibility:RegisterConsoleLayoutPreviewSettingsSceneHook()
    if self.consoleSettingsSceneHandler or not ZO_IsConsoleOrGameCoreUI() then
        return
    end
    local settingsScene = SCENE_MANAGER:GetScene(LIB_HARVENS_ADDON_SETTINGS_SCENE_NAME)
    if not settingsScene then
        return
    end
    self.consoleSettingsSceneHandler = function (oldState, newState)
        if newState == SCENE_HIDDEN then
            self:SetConsoleLayoutPreviewActive(false)
        end
    end
    settingsScene:RegisterCallback("StateChange", self.consoleSettingsSceneHandler)
end
