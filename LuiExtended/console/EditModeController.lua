-- -----------------------------------------------------------------------------
--  LuiExtended Console Edit Mode Controller                                   --
--  Handles edit mode for console/gamepad UI element movement                 --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class LUIE.EditModeController
--- @field editModeActive boolean Whether edit mode is currently active
--- @field actionLayerName string Name of the action layer for edit mode
--- @field actionLayerActive boolean Whether the action layer is currently active
--- @field keybindStripDescriptor table Keybind strip descriptor for edit mode
--- @field keybindStripActive boolean Whether keybind strip is currently active
--- @field keybindScenes table List of scene names that allow keybind strip
--- @field keybindSceneCallbacks table Map of registered scene callbacks
--- @field keybindFragmentSceneName string Name of scene with keybind fragment
--- @field activePanelId string? ID of currently active panel for movement
--- @field editModeFocusId string? ID of panel currently focused in edit mode
local EditModeController = {}

EditModeController.__index = EditModeController

-- Constants
local REDUCED_KEYBIND_STRIP_HEIGHT = 48

--- Helper functions for module availability
local function IsModuleAvailable(moduleName)
    local module = LUIE[moduleName]
    return module ~= nil
end

local function IsUnitFramesAvailable()
    return IsModuleAvailable("UnitFrames") and LUIE.UnitFrames.CustomFramesMovingState ~= nil
end

local function IsSpellCastBuffsAvailable()
    return IsModuleAvailable("SpellCastBuffs") and LUIE.SpellCastBuffs and LUIE.SpellCastBuffs.Enabled
end

local function IsActionBarAvailable()
    return IsModuleAvailable("ActionBar") and LUIE.ActionBar.CastBarUnlocked ~= nil
end

local function IsInfoPanelAvailable()
    return IsModuleAvailable("InfoPanel") and LUIE.InfoPanel.panelUnlocked ~= nil
end

local function IsAbilityAlertsAvailable()
    return IsModuleAvailable("CombatInfo") and LUIE.CombatInfo.AbilityAlerts and LUIE.CombatInfo.AbilityAlerts.AlertFrameUnlocked ~= nil
end

local function IsCombatTextAvailable()
    return IsModuleAvailable("CombatText") and LUIE.CombatText.Enabled and LUIE.CombatText.SV and LUIE.CombatText.SV.unlocked
end

local function IsSynergyTrackerAvailable()
    return IsModuleAvailable("CombatInfo") and LUIE.CombatInfo.SynergyTrackerInstance ~= nil
end

--- Creates new EditModeController
--- @return LUIE.EditModeController
function EditModeController:New()
    local controller =
    {
        editModeActive = false,
        actionLayerName = GetString(SI_KEYBINDINGS_LAYER_USER_INTERFACE_SHORTCUTS),
        actionLayerActive = false,
        keybindStripDescriptor = nil,
        keybindStripActive = false,
        keybindScenes = { "hud", "hudui", "gamepadInteract", "LibHarvensAddonSettingsScene" },
        keybindSceneCallbacks = {},
        keybindFragmentSceneName = nil,
        activePanelId = nil,
        editModeFocusId = nil,
        keybindStripReduced = false,
        keybindStripOriginalHeight = nil,
        keybindStripBackgroundOriginalHeight = nil,
        keybindStripBackgroundTextureOriginalHeight = nil,
        keybindStripCenterAdjusted = false,
        showAllLabels = false,
        triggeringModule = nil, -- Track which module triggered edit mode
    }
    return setmetatable(controller, EditModeController)
end

--- Checks if edit mode is active
--- @return boolean
function EditModeController:IsEditModeActive()
    return self.editModeActive == true
end

--- Sets edit mode active state
--- @param active boolean
--- @param triggeringModule string? Optional module name that triggered edit mode (e.g., "UnitFrames", "SpellCastBuffs")
function EditModeController:SetEditModeActive(active, triggeringModule)
    local shouldEnable = active == true
    if self.editModeActive == shouldEnable then
        return
    end

    self.editModeActive = shouldEnable

    -- Track which module triggered edit mode
    if shouldEnable and triggeringModule then
        self.triggeringModule = triggeringModule
    end

    -- Check if we're in settings scene and need to close it
    local currentScene = SCENE_MANAGER:GetCurrentScene()
    local currentName = currentScene and currentScene:GetName()
    local wasInSettingsScene = currentName == "LibHarvensAddonSettingsScene"

    if shouldEnable then
        -- If in settings scene, close it and return to hud
        if wasInSettingsScene then
            local settingsScene = SCENE_MANAGER:GetScene("LibHarvensAddonSettingsScene")
            if settingsScene then
                settingsScene:SetState("hiding")
            end
            -- Navigate back to hud scene
            LUIE_callLater(function ()
                             SCENE_MANAGER:Show("hud")
                         end, 50)
        end

        -- Activate action layer FIRST before anything else
        self:ActivateActionLayer()
        -- Then select first panel and refresh
        self:SelectFirstFocusablePanel()
    else
        self:ClearEditModeFocus()
        -- Remove keybind strip and restore sizing BEFORE deactivating action layer
        self:RemoveKeybindStrip()
        -- Always restore sizing when exiting edit mode (even if keybind strip wasn't active)
        if self.keybindStripReduced then
            self:ApplyKeybindStripSizing()
        end
        -- Force cleanup of keybind backdrop to ensure it disappears immediately
        self:ForceCleanupKeybindBackdrop()
        self:DeactivateActionLayer()

        -- Re-lock the module that triggered edit mode
        if self.triggeringModule then
            if self.triggeringModule == "UnitFrames" and LUIE.UnitFrames and LUIE.UnitFrames.CustomFramesSetMovingState then
                LUIE.UnitFrames.CustomFramesSetMovingState(false)
            elseif self.triggeringModule == "SpellCastBuffs" and LUIE.SpellCastBuffs and LUIE.SpellCastBuffs.SetMovingState then
                LUIE.SpellCastBuffs.SetMovingState(false)
            elseif self.triggeringModule == "ActionBar" and LUIE.ActionBar and LUIE.ActionBar.SetMovingState then
                LUIE.ActionBar.SetMovingState(false)
            elseif self.triggeringModule == "InfoPanel" and LUIE.InfoPanel and LUIE.InfoPanel.SetMovingState then
                LUIE.InfoPanel.SetMovingState(false)
            elseif self.triggeringModule == "AbilityAlerts" and LUIE.CombatInfo and LUIE.CombatInfo.AbilityAlerts and LUIE.CombatInfo.AbilityAlerts.SetMovingStateAlert then
                LUIE.CombatInfo.AbilityAlerts.SetMovingStateAlert(false)
            elseif self.triggeringModule == "CombatText" and LUIE.CombatText and LUIE.CombatText.SetMovingState then
                LUIE.CombatText.SetMovingState(false)
            elseif self.triggeringModule == "SynergyTracker" and LUIE.CombatInfo and LUIE.CombatInfo.SynergyTrackerInstance and LUIE.CombatInfo.SynergyTrackerInstance.SetUnlocked then
                LUIE.CombatInfo.SynergyTrackerInstance:SetUnlocked(false)
            end
            self.triggeringModule = nil
        end
    end

    self.activePanelId = nil
    if LUIE.Unlock then
        LUIE.Unlock:RefreshAllPanels()
        LUIE.Unlock:RefreshGridOverlay()
    end

    -- Refresh module movers BEFORE refreshing keybind strip
    self:RefreshModuleMovers()

    -- Refresh keybind strip - this will check current scene and show if in allowed scene
    self:RefreshKeybindStrip()

    -- If we're in an allowed scene but keybind strip isn't active, ensure fragment is added
    if shouldEnable then
        LUIE_callLater(function ()
                         currentScene = SCENE_MANAGER:GetCurrentScene()
                         currentName = currentScene and currentScene:GetName()
                         if currentName then
                             for _, allowedScene in ipairs(self.keybindScenes) do
                                 if currentName == allowedScene then
                                     if KEYBIND_STRIP_GAMEPAD_FRAGMENT and currentScene and not currentScene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
                                         currentScene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
                                         self.keybindFragmentSceneName = currentName
                                     end
                                     break
                                 end
                             end
                         end
                     end, 150)
    end

    self:RefreshGridOverlay()

    local message = shouldEnable and "Edit mode enabled" or "Edit mode disabled"
    CHAT_ROUTER:AddSystemMessage(string.format("[LUIE] %s", message))
end

--- Refreshes grid overlay visibility
function EditModeController:RefreshGridOverlay()
    if not LUIE.GridOverlay then
        return
    end

    -- Refresh grid overlays for each module type
    local accountWideSettings = LUIESV["Default"][GetDisplayName()]["$AccountWide"]

    -- Default grid
    local gridEnabled = accountWideSettings and accountWideSettings.snapToGrid_default
    local gridSize = (accountWideSettings and accountWideSettings.snapToGridSize_default) or 15
    local shouldShowDefault = gridEnabled and (self.editModeActive or self.activePanelId ~= nil)
    LUIE.GridOverlay.Refresh("default", shouldShowDefault, gridSize)

    -- Unit frames grid
    if LUIE.UnitFrames and LUIE.UnitFrames.CustomFramesMovingState then
        local unitFramesGridEnabled = accountWideSettings and accountWideSettings.snapToGrid_unitFrames
        local unitFramesGridSize = (accountWideSettings and accountWideSettings.snapToGridSize_unitFrames) or 15
        local shouldShow = unitFramesGridEnabled and (self.editModeActive or (self.activePanelId and self.activePanelId:match("^unitFrame_")))
        LUIE.GridOverlay.Refresh("unitFrames", shouldShow, unitFramesGridSize)
    end

    -- Buffs grid
    if LUIE.SpellCastBuffs and LUIE.SpellCastBuffs.Enabled then
        local buffsGridEnabled = accountWideSettings and accountWideSettings.snapToGrid_buffs
        local buffsGridSize = (accountWideSettings and accountWideSettings.snapToGridSize_buffs) or 15
        local shouldShow = buffsGridEnabled and (self.editModeActive or (self.activePanelId and self.activePanelId:match("^buff_")))
        LUIE.GridOverlay.Refresh("buffs", shouldShow, buffsGridSize)
    end
end

--- Refreshes all module movers (UnitFrames, SpellCastBuffs, etc.)
function EditModeController:RefreshModuleMovers()
    local MoverHelper = LUIE.ConsoleMoverHelper
    if not MoverHelper then return end

    -- Refresh UnitFrames movers
    if IsUnitFramesAvailable() then
        self:RefreshUnitFramesMovers(MoverHelper)
    end

    -- Refresh SpellCastBuffs movers
    if IsSpellCastBuffsAvailable() then
        self:RefreshSpellCastBuffsMovers(MoverHelper)
    end

    -- Refresh other module movers
    self:RefreshOtherModuleMovers(MoverHelper)
end

--- Refreshes UnitFrames movers
function EditModeController:RefreshUnitFramesMovers(MoverHelper)
    local unitTags = { "player", "reticleover", "companion", "SmallGroup1", "RaidGroup1", "boss1", "AvaPlayerTarget", "PetGroup1" }

    for _, unitTag in ipairs(unitTags) do
        local frame = LUIE.UnitFrames.CustomFrames[unitTag]
        if frame and frame.tlw then
            local identifier = "unitFrame_" .. unitTag

            -- Create coordinate label if it doesn't exist (check both preview and direct access)
            if frame.tlw.preview and LUIE.Unlock then
                -- Check if coordLabel already exists (may have been created in Unlock.CreateTopLevelWindow)
                if not frame.tlw.preview.coordLabel then
                    local frameName = unitTag:gsub("^%l", string.upper)
                    local positionText = "Default"
                    if LUIE.UnitFrames.SV and LUIE.UnitFrames.SV[frame.tlw.customPositionAttr] then
                        local x = LUIE.UnitFrames.SV[frame.tlw.customPositionAttr][1] or 0
                        local y = LUIE.UnitFrames.SV[frame.tlw.customPositionAttr][2] or 0
                        positionText = string.format("%d, %d | %s", x, y, frameName)
                    else
                        positionText = string.format("Default | %s", frameName)
                    end
                    frame.tlw.preview.coordLabel = LUIE.Unlock.CreateCoordinateLabel(frame.tlw.preview, positionText)
                end
            end

            MoverHelper.UpdateControlState(frame.tlw, identifier, LUIE.UnitFrames.CustomFramesMovingState)

            -- Handle buff/debuff previews when locked to unit frames
            self:UpdateUnitFrameBuffPreviews(frame, identifier, unitTag)
        end
    end
end

--- Updates buff/debuff previews for unit frames
function EditModeController:UpdateUnitFrameBuffPreviews(frame, identifier, unitTag)
    if not IsSpellCastBuffsAvailable() or (unitTag ~= "player" and unitTag ~= "reticleover") then return end

    local lockToUnitFrames = LUIE.SpellCastBuffs.SV.lockPositionToUnitFrames ~= false
    if not lockToUnitFrames then return end

    local shouldShow = self:IsEditModeActive() or LUIE.UnitFrames.CustomFramesMovingState

    if frame.buffs and frame.buffs.preview then
        frame.buffs.preview:SetHidden(not shouldShow)
    end
    if frame.debuffs and frame.debuffs.preview then
        frame.debuffs.preview:SetHidden(not shouldShow)
    end
end

--- Refreshes SpellCastBuffs movers
function EditModeController:RefreshSpellCastBuffsMovers(MoverHelper)
    if not LUIE.SpellCastBuffs then return end

    local lockToUnitFrames = LUIE.SpellCastBuffs.SV.lockPositionToUnitFrames ~= false

    if not lockToUnitFrames then
        -- Refresh independent buff containers
        local containers =
        {
            { container = LUIE.SpellCastBuffs.BuffContainers.playerb, id = "buff_playerb" },
            { container = LUIE.SpellCastBuffs.BuffContainers.playerd, id = "buff_playerd" },
            { container = LUIE.SpellCastBuffs.BuffContainers.targetb, id = "buff_targetb" },
            { container = LUIE.SpellCastBuffs.BuffContainers.targetd, id = "buff_targetd" },
        }
        for _, item in ipairs(containers) do
            if item.container and item.container:GetType() == CT_TOPLEVELCONTROL then
                MoverHelper.UpdateControlState(item.container, item.id, LUIE.SpellCastBuffs.BuffsMovingState)
            end
        end
    else
        -- Hide independent buff container previews when locked to unit frames
        local containers =
        {
            LUIE.SpellCastBuffs.BuffContainers.playerb,
            LUIE.SpellCastBuffs.BuffContainers.playerd,
            LUIE.SpellCastBuffs.BuffContainers.targetb,
            LUIE.SpellCastBuffs.BuffContainers.targetd,
        }
        for _, container in ipairs(containers) do
            if container and container.preview then
                container.preview:SetHidden(true)
            end
        end
    end

    -- Refresh always-available containers if buffs are unlocked
    local buffsUnlocked = not lockToUnitFrames and LUIE.SpellCastBuffs.BuffContainers.playerb and LUIE.SpellCastBuffs.BuffContainers.playerb.gamepadHandler
    if buffsUnlocked then
        local alwaysContainers =
        {
            { container = LUIE.SpellCastBuffs.BuffContainers.player_long,      id = "buff_player_long"      },
            { container = LUIE.SpellCastBuffs.BuffContainers.prominentbuffs,   id = "buff_prominentbuffs"   },
            { container = LUIE.SpellCastBuffs.BuffContainers.prominentdebuffs, id = "buff_prominentdebuffs" },
        }
        for _, item in ipairs(alwaysContainers) do
            if item.container and item.container:GetType() == CT_TOPLEVELCONTROL then
                MoverHelper.UpdateControlState(item.container, item.id, LUIE.SpellCastBuffs.BuffsMovingState)
            end
        end
    end
end

--- Refreshes other module movers (CastBar, InfoPanel, etc.)
function EditModeController:RefreshOtherModuleMovers(MoverHelper)
    -- CastBar
    if IsActionBarAvailable() then
        local uiTlw = LUIE.ActionBar.uiTlw
        if uiTlw and uiTlw.castBar and uiTlw.castBar:GetType() == CT_TOPLEVELCONTROL then
            MoverHelper.UpdateControlState(uiTlw.castBar, "castBar", LUIE.ActionBar.CastBarUnlocked)
        end
    end

    -- InfoPanel
    if IsInfoPanelAvailable() then
        local uiPanel = LUIE.InfoPanel.Panel
        if uiPanel and uiPanel:GetType() == CT_TOPLEVELCONTROL then
            MoverHelper.UpdateControlState(uiPanel, "infoPanel", LUIE.InfoPanel.panelUnlocked)
        end
    end

    -- AbilityAlerts
    if IsAbilityAlertsAvailable() then
        local uiTlw = LUIE.CombatInfo.AbilityAlerts.uiTlw
        if uiTlw and uiTlw.alertFrame and uiTlw.alertFrame:GetType() == CT_TOPLEVELCONTROL then
            MoverHelper.UpdateControlState(uiTlw.alertFrame, "abilityAlerts", LUIE.CombatInfo.AbilityAlerts.AlertFrameUnlocked)
        end
    end

    -- CombatText
    if IsCombatTextAvailable() then
        if LUIE.CombatText.panelWrappers then
            for k, wrapper in pairs(LUIE.CombatText.panelWrappers) do
                if wrapper and wrapper:GetType() == CT_TOPLEVELCONTROL then
                    MoverHelper.UpdateControlState(wrapper, "combatText_" .. k, LUIE.CombatText.SV.unlocked)
                end
            end
        end
    end

    -- SynergyTracker
    if IsSynergyTrackerAvailable() then
        local tracker = LUIE.CombatInfo.SynergyTrackerInstance
        local Settings = LUIE.CombatInfo.SV and LUIE.CombatInfo.SV.synergy
        if tracker.control and tracker.control:GetType() == CT_TOPLEVELCONTROL and Settings and Settings.unlocked then
            MoverHelper.UpdateControlState(tracker.control, "synergyTracker", Settings.unlocked)
        end
    end
end

--- Toggles edit mode on/off
function EditModeController:ToggleEditMode()
    self:SetEditModeActive(not self.editModeActive)
end

--- Activates action layer
function EditModeController:ActivateActionLayer()
    if not self.actionLayerName then
        return
    end

    -- Always push the action layer (can be called multiple times safely)
    PushActionLayerByName(self.actionLayerName)
    self.actionLayerActive = true
end

--- Deactivates action layer
function EditModeController:DeactivateActionLayer()
    if not self.actionLayerName or not self.actionLayerActive then
        return
    end
    RemoveActionLayerByName(self.actionLayerName)
    self.actionLayerActive = false
end

--- Adds unit frame panel IDs to the list
local function AddUnitFramePanelIds(ids)
    if not IsUnitFramesAvailable() then return end

    local unitTags = { "player", "reticleover", "companion", "SmallGroup1", "RaidGroup1", "boss1", "AvaPlayerTarget", "PetGroup1" }
    for _, unitTag in ipairs(unitTags) do
        local frame = LUIE.UnitFrames.CustomFrames[unitTag]
        if frame and frame.tlw then
            table.insert(ids, "unitFrame_" .. unitTag)
        end
    end
end

--- Adds buff container panel IDs to the list
local function AddBuffPanelIds(ids, includeLocked)
    if not IsSpellCastBuffsAvailable() then return end

    local lockToUnitFrames = LUIE.SpellCastBuffs.SV.lockPositionToUnitFrames ~= false

    if not lockToUnitFrames or includeLocked then
        local containers =
        {
            { container = LUIE.SpellCastBuffs.BuffContainers.playerb, id = "buff_playerb" },
            { container = LUIE.SpellCastBuffs.BuffContainers.playerd, id = "buff_playerd" },
            { container = LUIE.SpellCastBuffs.BuffContainers.targetb, id = "buff_targetb" },
            { container = LUIE.SpellCastBuffs.BuffContainers.targetd, id = "buff_targetd" },
        }
        for _, item in ipairs(containers) do
            if item.container and item.container:GetType() == CT_TOPLEVELCONTROL then
                table.insert(ids, item.id)
            end
        end
    end

    -- Always add these containers (not locked to unit frames)
    local alwaysContainers =
    {
        { container = LUIE.SpellCastBuffs.BuffContainers.player_long,      id = "buff_player_long"      },
        { container = LUIE.SpellCastBuffs.BuffContainers.prominentbuffs,   id = "buff_prominentbuffs"   },
        { container = LUIE.SpellCastBuffs.BuffContainers.prominentdebuffs, id = "buff_prominentdebuffs" },
    }
    for _, item in ipairs(alwaysContainers) do
        if item.container and item.container:GetType() == CT_TOPLEVELCONTROL then
            table.insert(ids, item.id)
        end
    end
end

--- Adds combat text panel IDs to the list
local function AddCombatTextPanelIds(ids)
    if not IsCombatTextAvailable() then return end

    if LUIE.CombatText.panelWrappers then
        for k, wrapper in pairs(LUIE.CombatText.panelWrappers) do
            if wrapper and wrapper:GetType() == CT_TOPLEVELCONTROL then
                table.insert(ids, "combatText_" .. k)
            end
        end
    else
        -- Fallback to panels if wrappers don't exist yet
        for k, _ in pairs(LUIE.CombatText.SV.panels) do
            local panel = _G[k]
            if panel then
                table.insert(ids, "combatText_" .. k)
            end
        end
    end
end

--- Enumerates all focusable panel IDs
--- @param triggeringModule string? Optional module name to filter panels
--- @return string[]
local function EnumerateFocusablePanelIds(triggeringModule)
    local ids = {}

    -- If a triggering module is specified, only include panels from that module
    if triggeringModule == "UnitFrames" then
        AddUnitFramePanelIds(ids)
    elseif triggeringModule == "SpellCastBuffs" then
        AddBuffPanelIds(ids, true)
    elseif triggeringModule == "ActionBar" and IsActionBarAvailable() then
        table.insert(ids, "castBar")
    elseif triggeringModule == "InfoPanel" and IsInfoPanelAvailable() then
        table.insert(ids, "infoPanel")
    elseif triggeringModule == "AbilityAlerts" and IsAbilityAlertsAvailable() then
        table.insert(ids, "abilityAlerts")
    elseif triggeringModule == "CombatText" then
        AddCombatTextPanelIds(ids)
    elseif triggeringModule == "SynergyTracker" and IsSynergyTrackerAvailable() then
        local tracker = LUIE.CombatInfo.SynergyTrackerInstance
        local Settings = LUIE.CombatInfo.SV and LUIE.CombatInfo.SV.synergy
        if tracker.control and tracker.control:GetType() == CT_TOPLEVELCONTROL and Settings and Settings.unlocked then
            table.insert(ids, "synergyTracker")
        end
    else
        -- No triggering module specified, include all unlocked panels
        -- Add default unlock panels
        if LUIE.Unlock and LUIE.Unlock.defaultPanels then
            for element, _ in pairs(LUIE.Unlock.defaultPanels) do
                local frameName = element:GetName()
                local mover = LUIE.Unlock.movers[frameName]
                if mover then
                    table.insert(ids, frameName)
                end
            end
        end

        -- Add all available panels
        AddUnitFramePanelIds(ids)
        AddBuffPanelIds(ids, false)
        if IsActionBarAvailable() then table.insert(ids, "castBar") end
        if IsInfoPanelAvailable() then table.insert(ids, "infoPanel") end
        if IsAbilityAlertsAvailable() then table.insert(ids, "abilityAlerts") end
        AddCombatTextPanelIds(ids)
        if IsSynergyTrackerAvailable() then
            local tracker = LUIE.CombatInfo.SynergyTrackerInstance
            local Settings = LUIE.CombatInfo.SV and LUIE.CombatInfo.SV.synergy
            if tracker.control and tracker.control:GetType() == CT_TOPLEVELCONTROL and Settings and Settings.unlocked then
                table.insert(ids, "synergyTracker")
            end
        end
    end

    return ids
end

--- Clears edit mode focus
function EditModeController:ClearEditModeFocus()
    self.editModeFocusId = nil
    LUIE.Unlock:RefreshAllPanels()
end

--- Checks if a panel ID is valid and focusable
--- @param panelId string
--- @return boolean
local function IsValidPanelId(panelId)
    if not panelId then
        return false
    end

    -- Check default unlock panels
    if LUIE.Unlock and LUIE.Unlock.movers[panelId] then
        return true
    end

    -- Check unit frame panels
    if panelId:match("^unitFrame_") then
        local unitTag = panelId:match("^unitFrame_(.+)$")
        if unitTag and LUIE.UnitFrames and LUIE.UnitFrames.CustomFrames[unitTag] and LUIE.UnitFrames.CustomFrames[unitTag].tlw then
            return true
        end
    end

    -- Check buff panels
    if panelId:match("^buff_") then
        if LUIE.SpellCastBuffs and LUIE.SpellCastBuffs.Enabled then
            local containerName = panelId:match("^buff_(.+)$")
            if containerName then
                -- Map identifier to container name
                local containerMap =
                {
                    ["playerb"] = "playerb",
                    ["playerd"] = "playerd",
                    ["targetb"] = "targetb",
                    ["targetd"] = "targetd",
                    ["player_long"] = "player_long",
                    ["prominentbuffs"] = "prominentbuffs",
                    ["prominentdebuffs"] = "prominentdebuffs",
                }
                local mappedName = containerMap[containerName]
                if mappedName and LUIE.SpellCastBuffs.BuffContainers[mappedName] then
                    return true
                end
            end
        end
    end

    -- Check other module panels
    if panelId == "castBar" and LUIE.ActionBar and LUIE.ActionBar.CastBarUnlocked then
        return true
    end
    if panelId == "infoPanel" and LUIE.InfoPanel and LUIE.InfoPanel.panelUnlocked then
        return true
    end
    if panelId == "abilityAlerts" and LUIE.CombatInfo and LUIE.CombatInfo.AbilityAlerts and LUIE.CombatInfo.AbilityAlerts.AlertFrameUnlocked then
        return true
    end

    -- Check combat text panels
    if panelId:match("^combatText_") then
        if LUIE.CombatText and LUIE.CombatText.Enabled and LUIE.CombatText.SV and LUIE.CombatText.SV.unlocked then
            local panelName = panelId:match("^combatText_(.+)$")
            if panelName and LUIE.CombatText.SV.panels[panelName] and _G[panelName] then
                return true
            end
        end
    end

    -- Check synergy tracker panel
    if panelId == "synergyTracker" then
        if LUIE.CombatInfo and LUIE.CombatInfo.SynergyTrackerInstance then
            local tracker = LUIE.CombatInfo.SynergyTrackerInstance
            local Settings = LUIE.CombatInfo.SV and LUIE.CombatInfo.SV.synergy
            if tracker.control and Settings and Settings.unlocked then
                return true
            end
        end
    end

    return false
end

--- Sets edit mode focus to a panel
--- @param panelId string?
function EditModeController:SetEditModeFocus(panelId)
    if not self.editModeActive then
        return
    end

    -- Explicitly disable gamepad movement on ALL panels before changing focus
    -- This ensures any active LCA timers are cancelled
    if LUIE.UnitFrames and LUIE.UnitFrames.CustomFrames then
        for _, frame in pairs(LUIE.UnitFrames.CustomFrames) do
            if frame.tlw and frame.tlw.gamepadHandler then
                if frame.tlw.gamepadHandler.ToggleGamepadMove then
                    frame.tlw.gamepadHandler:ToggleGamepadMove(false)
                end
                frame.tlw.gamepadMoveFocused = false
            end
        end
    end
    if LUIE.SpellCastBuffs and LUIE.SpellCastBuffs.BuffContainers then
        for _, container in pairs(LUIE.SpellCastBuffs.BuffContainers) do
            if container and container.gamepadHandler then
                if container.gamepadHandler.ToggleGamepadMove then
                    container.gamepadHandler:ToggleGamepadMove(false)
                end
                container.gamepadMoveFocused = false
            end
        end
    end

    if panelId and IsValidPanelId(panelId) then
        self.editModeFocusId = panelId
    else
        self.editModeFocusId = nil
    end

    if LUIE.Unlock then
        LUIE.Unlock:RefreshAllPanels()
    end
    -- Refresh module movers to enable gamepad movement on newly focused panel
    self:RefreshModuleMovers()
    self:RefreshKeybindStrip()
end

--- Selects first focusable panel
function EditModeController:SelectFirstFocusablePanel()
    local ids = EnumerateFocusablePanelIds(self.triggeringModule)
    if #ids == 0 then
        self.editModeFocusId = nil
        return
    end

    local target = self.editModeFocusId
    if not target or not IsValidPanelId(target) then
        target = ids[1]
    end

    self:SetEditModeFocus(target)
end

--- Starts moving a control (for individual panel movement from settings)
--- @param panelId string
function EditModeController:StartControlMove(panelId)
    if not IsValidPanelId(panelId) then
        return
    end

    self.activePanelId = panelId
    if LUIE.Unlock then
        LUIE.Unlock:RefreshAllPanels()
        LUIE.Unlock:RefreshGridOverlay()
    end
    self:RefreshModuleMovers()
    self:RefreshGridOverlay()
end

--- Stops control movement
function EditModeController:StopControlMove()
    if not self.activePanelId then
        return
    end

    self.activePanelId = nil
    if LUIE.Unlock then
        LUIE.Unlock:RefreshAllPanels()
        LUIE.Unlock:RefreshGridOverlay()
    end
    self:RefreshModuleMovers()
    self:RefreshGridOverlay()
end

--- Cycles focused panel in direction
--- @param direction integer
function EditModeController:CycleFocusedPanel(direction)
    if not (self.editModeActive and direction and direction ~= 0) then
        return
    end

    local ids = EnumerateFocusablePanelIds(self.triggeringModule)
    local count = #ids
    if count == 0 then
        return
    end

    local currentIndex = 1
    for index, id in ipairs(ids) do
        if id == self.editModeFocusId then
            currentIndex = index
            break
        end
    end

    local nextIndex = ((currentIndex - 1 + direction) % count) + 1
    self:SetEditModeFocus(ids[nextIndex])
end

--- Toggles label visibility
function EditModeController:ToggleLabels()
    if not self:IsEditModeActive() then
        return
    end

    self.showAllLabels = not self.showAllLabels
    self:RefreshModuleMovers()

    local status = self.showAllLabels and "all labels visible" or "only active label visible"
    CHAT_ROUTER:AddSystemMessage(string.format("[LUIE] Labels: %s", status))
end

--- Ensures keybind descriptor is created
function EditModeController:EnsureKeybindDescriptor()
    if self.keybindStripDescriptor then
        return
    end

    local controller = self
    self.keybindStripDescriptor =
    {
        -- Enter Edit Mode (ethereal - only shows on keybind press)
        {
            name = "Enter Edit Mode",
            keybind = "UI_SHORTCUT_TERTIARY",
            ethereal = true,
            visible = function ()
                return IsInGamepadPreferredMode() and not controller:IsEditModeActive()
            end,
            callback = function ()
                controller:SetEditModeActive(true)
            end,
        },

        -- Exit Edit Mode
        {
            name = "Exit Edit Mode",
            keybind = "UI_SHORTCUT_NEGATIVE",
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            visible = function ()
                return IsInGamepadPreferredMode() and controller:IsEditModeActive()
            end,
            callback = function ()
                controller:SetEditModeActive(false)
            end,
        },

        -- Previous Panel (LB only - no left stick)
        {
            name = "Previous Panel",
            keybind = "UI_SHORTCUT_LEFT_SHOULDER",
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,
            visible = function ()
                return IsInGamepadPreferredMode() and controller:IsEditModeActive()
            end,
            callback = function ()
                controller:CycleFocusedPanel(-1)
            end,
        },

        -- Next Panel (RB only - no right stick)
        {
            name = "Next Panel",
            keybind = "UI_SHORTCUT_RIGHT_SHOULDER",
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,
            visible = function ()
                return IsInGamepadPreferredMode() and controller:IsEditModeActive()
            end,
            callback = function ()
                controller:CycleFocusedPanel(1)
            end,
        },

        -- Toggle Labels
        {
            name = function ()
                return controller.showAllLabels and "Hide Labels" or "Show All Labels"
            end,
            keybind = "UI_SHORTCUT_QUATERNARY",
            alignment = KEYBIND_STRIP_ALIGN_RIGHT,
            visible = function ()
                return IsInGamepadPreferredMode() and controller:IsEditModeActive()
            end,
            callback = function ()
                controller:ToggleLabels()
            end,
        },
    }
end

--- Removes keybind strip
function EditModeController:RemoveKeybindStrip()
    if not (self.keybindStripActive and self.keybindStripDescriptor) then
        return
    end

    KEYBIND_STRIP:RemoveKeybindButtonGroup(self.keybindStripDescriptor)
    self.keybindStripActive = false
    self:ApplyKeybindStripSizing()

    if self.keybindFragmentSceneName then
        local scene = SCENE_MANAGER:GetScene(self.keybindFragmentSceneName)
        if scene and scene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
            scene:RemoveFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
        end
        self.keybindFragmentSceneName = nil
    end
end

--- Applies keybind strip sizing based on edit mode
function EditModeController:ApplyKeybindStripSizing()
    local shouldReduce = self.editModeActive and IsInGamepadPreferredMode()
    if shouldReduce then
        if not self.keybindStripReduced then
            if KEYBIND_STRIP and KEYBIND_STRIP.control then
                self.keybindStripOriginalHeight = self.keybindStripOriginalHeight or KEYBIND_STRIP.control:GetHeight()
                KEYBIND_STRIP.control:SetHeight(REDUCED_KEYBIND_STRIP_HEIGHT)
            end

            if ZO_KeybindStripGamepadBackground then
                self.keybindStripBackgroundOriginalHeight = self.keybindStripBackgroundOriginalHeight
                    or ZO_KeybindStripGamepadBackground:GetHeight()
                ZO_KeybindStripGamepadBackground:SetHeight(REDUCED_KEYBIND_STRIP_HEIGHT)
                if self.keybindStripBackgroundWasHidden == nil then
                    self.keybindStripBackgroundWasHidden = ZO_KeybindStripGamepadBackground:IsHidden()
                end
                ZO_KeybindStripGamepadBackground:SetHidden(true)
            end

            if ZO_KeybindStripGamepadBackgroundTexture then
                self.keybindStripBackgroundTextureOriginalHeight = self.keybindStripBackgroundTextureOriginalHeight
                    or ZO_KeybindStripGamepadBackgroundTexture:GetHeight()
                ZO_KeybindStripGamepadBackgroundTexture:SetHeight(REDUCED_KEYBIND_STRIP_HEIGHT)
                ZO_KeybindStripGamepadBackgroundTexture:SetHidden(true)
            end

            if KEYBIND_STRIP and KEYBIND_STRIP.centerParent and not self.keybindStripCenterAdjusted then
                KEYBIND_STRIP.centerParent:ClearAnchors()
                KEYBIND_STRIP.centerParent:SetAnchor(BOTTOM, KEYBIND_STRIP.control, BOTTOM, 0, -6)
                self.keybindStripCenterAdjusted = true
            end

            self.keybindStripReduced = true
        end
    elseif self.keybindStripReduced then
        if KEYBIND_STRIP and KEYBIND_STRIP.control and self.keybindStripOriginalHeight then
            KEYBIND_STRIP.control:SetHeight(self.keybindStripOriginalHeight)
        end

        if ZO_KeybindStripGamepadBackground and self.keybindStripBackgroundOriginalHeight then
            ZO_KeybindStripGamepadBackground:SetHeight(self.keybindStripBackgroundOriginalHeight)
        end

        if ZO_KeybindStripGamepadBackgroundTexture and self.keybindStripBackgroundTextureOriginalHeight then
            ZO_KeybindStripGamepadBackgroundTexture:SetHeight(self.keybindStripBackgroundTextureOriginalHeight)
            ZO_KeybindStripGamepadBackgroundTexture:SetHidden(false)
        end

        if KEYBIND_STRIP and KEYBIND_STRIP.centerParent and self.keybindStripCenterAdjusted then
            KEYBIND_STRIP.centerParent:ClearAnchors()
            KEYBIND_STRIP.centerParent:SetAnchor(CENTER, KEYBIND_STRIP.control, CENTER, 0, 0)
            self.keybindStripCenterAdjusted = false
        end

        if ZO_KeybindStripGamepadBackground then
            if self.keybindStripBackgroundWasHidden ~= nil then
                ZO_KeybindStripGamepadBackground:SetHidden(self.keybindStripBackgroundWasHidden)
            end
        end

        self.keybindStripBackgroundWasHidden = nil
        self.keybindStripReduced = false
    end
end

--- Forces cleanup of keybind backdrop when exiting edit mode
function EditModeController:ForceCleanupKeybindBackdrop()
    -- Force hide backdrop controls to ensure they disappear immediately
    if ZO_KeybindStripGamepadBackground then
        ZO_KeybindStripGamepadBackground:SetHidden(true)
    end
    if ZO_KeybindStripGamepadBackgroundTexture then
        ZO_KeybindStripGamepadBackgroundTexture:SetHidden(true)
    end

    -- Force a scene refresh to ensure backdrop is properly removed
    local currentScene = SCENE_MANAGER:GetCurrentScene()
    if currentScene then
        -- Trigger a scene state refresh by briefly toggling the fragment
        if currentScene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
            currentScene:RemoveFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
            -- Small delay to ensure cleanup, then force scene refresh
            LUIE_callLater(function ()
                             -- Force update the scene to ensure backdrop is gone
                             if currentScene:IsShowing() then
                                 currentScene:Refresh()
                             end
                         end, 50)
        end
    end
end

--- Handles keybind scene state change
--- @param sceneName string
--- @param oldState integer?
--- @param newState integer?
function EditModeController:OnKeybindSceneStateChange(sceneName, oldState, newState)
    newState = newState or oldState
    if not IsInGamepadPreferredMode() then
        return
    end

    if not self.editModeActive then
        return
    end

    if newState == SCENE_SHOWING or newState == SCENE_SHOWN then
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene and not scene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
            scene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
            self.keybindFragmentSceneName = sceneName
        end

        if not self.keybindStripActive then
            self:RefreshKeybindStrip()
        end
    elseif newState == SCENE_HIDDEN or newState == SCENE_HIDING then
        local scene = SCENE_MANAGER:GetScene(sceneName)
        if scene and scene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
            scene:RemoveFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
        end

        if self.keybindFragmentSceneName == sceneName then
            self.keybindFragmentSceneName = nil
        end

        self:RemoveKeybindStrip()
    end
end

--- Refreshes keybind strip
function EditModeController:RefreshKeybindStrip()
    self:EnsureKeybindDescriptor()
    if not self.keybindStripDescriptor then
        return
    end

    self:ApplyKeybindStripSizing()

    if not (self.editModeActive and IsInGamepadPreferredMode()) then
        self:RemoveKeybindStrip()
        return
    end

    local currentScene = SCENE_MANAGER:GetCurrentScene()
    local currentName = currentScene and currentScene:GetName()
    local allowed = false

    if currentName and self.keybindScenes then
        for _, name in ipairs(self.keybindScenes) do
            if name == currentName then
                allowed = true
                break
            end
        end
    end

    if not allowed then
        self:RemoveKeybindStrip()
        return
    end

    currentScene = SCENE_MANAGER:GetCurrentScene()
    if KEYBIND_STRIP_GAMEPAD_FRAGMENT and currentScene and not currentScene:HasFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT) then
        currentScene:AddFragment(KEYBIND_STRIP_GAMEPAD_FRAGMENT)
        self.keybindFragmentSceneName = currentName
    end

    if self.keybindStripActive then
        KEYBIND_STRIP:UpdateKeybindButtonGroup(self.keybindStripDescriptor)
    else
        KEYBIND_STRIP:AddKeybindButtonGroup(self.keybindStripDescriptor)
        self.keybindStripActive = true
    end
end

--- Registers a scene for keybind callbacks
--- @param sceneName string
function EditModeController:RegisterKeybindScene(sceneName)
    if self.keybindSceneCallbacks[sceneName] then
        return
    end

    local scene = SCENE_MANAGER:GetScene(sceneName)
    if not scene then
        return
    end

    scene:RegisterCallback("StateChange", function (oldState, newState)
        self:OnKeybindSceneStateChange(sceneName, oldState, newState)
    end)

    self.keybindSceneCallbacks[sceneName] = true
end

--- Initializes keybind strip
function EditModeController:InitializeKeybindStrip()
    if not KEYBIND_STRIP then
        return
    end

    self:EnsureKeybindDescriptor()

    for _, sceneName in ipairs(self.keybindScenes) do
        self:RegisterKeybindScene(sceneName)
    end

    if self.editModeActive then
        self:RefreshKeybindStrip()
    end
end

--- Handles preferred mode changes to refresh keybinds
function EditModeController:OnGamepadPreferredModeChanged()
    LUIE_callLater(function ()
                     self:RefreshKeybindStrip()
                 end, 200)
end

LUIE.EditModeController = EditModeController:New()
