-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) LUIE.CombatInfo
local CombatInfo = LUIE.CombatInfo

local pairs = pairs
local ipairs = ipairs
local math_min = math.min
local math_max = math.max
local math_ceil = math.ceil
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local zo_strformat = zo_strformat
local string_format = string.format

local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local HUD_SCENE = "hud"
local HUDUI_SCENE = "hudui"
local moduleName = LUIE.name .. "CombatInfo" .. "SynergyTracker"

-- UI Constants
local MAX_SYNERGY_SLOTS = 10
local SYNERGY_ROW_HEIGHT = 44
local SYNERGY_ROW_WIDTH = 320
local SYNERGY_ICON_SIZE = 40

--- Hardcoded shared cooldown groups
--- Wiki: "Luminous Shards and Energy Orb's synergies uniquely share the same cooldown"
--- These are the ONLY synergies that share cooldowns in ESO
--- @type table<integer, integer[]>
local HARDCODED_SHARED_COOLDOWNS =
{
    [26832] = { 26832, 95922, 39301, 88758 }, -- Blessed Shards (Spear Shards)
    [95922] = { 26832, 95922, 39301, 88758 }, -- Holy Shards (Luminous Shards)
    [39301] = { 26832, 95922, 39301, 88758 }, -- Combustion (Necrotic Orb)
    [88758] = { 26832, 95922, 39301, 88758 }, -- Healing Combustion (Energy Orb)
}

--- @class SynergyTracker : ZO_Object
--- @field control TopLevelWindow Main UI control
--- @field bg LUIE_SynergyTracker_UI_Background Background control for unlock mode
--- @field activeSynergies table<integer, table> Currently active synergies
--- @field synergyControls table[] UI controls for each synergy slot
--- @field synergyCooldowns table<integer, table> Synergies currently on cooldown
--- @field lastSynergyCount integer Last known synergy count
--- @field lastCooldownUpdate integer Last cooldown UI update time
--- @field lastLoggedCooldownCount integer Last logged cooldown count (for debug)
local SynergyTracker = ZO_Object:Subclass()
CombatInfo.SynergyTracker = SynergyTracker

--- Create new SynergyTracker instance
--- @return SynergyTracker
function SynergyTracker:New()
    local obj = ZO_Object.New(self)
    obj:Initialize()
    return obj
end

--- Initialize the SynergyTracker (loads controls from XML, creates fragment, registers events)
function SynergyTracker:Initialize()
    self.activeSynergies = {}
    self.synergyControls = {}
    self.lastSynergyCount = 0
    self.synergyCooldowns = {}
    self.lastLoggedCooldownCount = 0

    -- Get control from XML
    local mainControl = LUIE_SynergyTracker_UI
    if not mainControl then
        return
    end

    self.control = mainControl

    -- Get background control
    self.bg = LUIE_SynergyTracker_UI_Background
    if self.bg then
        -- Set backdrop colors (XML sets defaults, but we may need to adjust)
        self.bg:SetCenterColor(0, 0, 0, 0.5)
        self.bg:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
        self.bg:SetEdgeTexture("", 1, 1, 0, 0)
    end

    -- Load synergy row controls from XML
    for i = 1, MAX_SYNERGY_SLOTS do
        local row = GetControl("LUIE_SynergyTracker_UI_Row" .. i)
        if row then
            local iconBg = GetControl("LUIE_SynergyTracker_UI_Row" .. i .. "_IconBg")             --- @type TextureControl
            local icon = GetControl("LUIE_SynergyTracker_UI_Row" .. i .. "_Icon")                 --- @type TextureControl
            local posNum = GetControl("LUIE_SynergyTracker_UI_Row" .. i .. "_PosNum")             --- @type LabelControl
            local name = GetControl("LUIE_SynergyTracker_UI_Row" .. i .. "_Name")                 --- @type LabelControl
            local priority = GetControl("LUIE_SynergyTracker_UI_Row" .. i .. "_Priority")         --- @type LabelControl
            local cooldown = GetControl("LUIE_SynergyTracker_UI_Row" .. i .. "_Cooldown")         --- @type CooldownControl
            local cooldownText = GetControl("LUIE_SynergyTracker_UI_Row" .. i .. "_CooldownText") --- @type LabelControl

            -- Set fonts based on platform
            if name then
                if IsConsoleUI() or IsInGamepadPreferredMode() then
                    name:SetFont("$(GAMEPAD_MEDIUM_FONT)|18|soft-shadow-thick")
                else
                    name:SetFont("ZoInteractionPrompt")
                end
            end

            if priority then
                if IsConsoleUI() or IsInGamepadPreferredMode() then
                    priority:SetFont("$(GAMEPAD_MEDIUM_FONT)|16|soft-shadow-thick")
                else
                    priority:SetFont("ZoFontGame")
                end
            end

            if cooldownText then
                if IsConsoleUI() or IsInGamepadPreferredMode() then
                    cooldownText:SetFont("$(GAMEPAD_MEDIUM_FONT)|20|soft-shadow-thick")
                else
                    cooldownText:SetFont("ZoFontGameBold")
                end
            end

            -- Set up tooltip handlers
            if row then
                row:SetHandler("OnMouseEnter", function (control)
                    local abilityId = self.synergyControls[i].abilityId
                    if abilityId and abilityId > 0 then
                        InitializeTooltip(GameTooltip, control, BOTTOM, 0, -5, TOP)

                        local abilityName = zo_strformat(SI_ABILITY_NAME, GetAbilityName(abilityId))
                        GameTooltip:AddLine(abilityName, "ZoFontHeader2", 1, 1, 1, nil)

                        if not IsAbilityPassive(abilityId) then
                            local description = GetAbilityDescription(abilityId, nil, "player")
                            if description and description ~= "" then
                                GameTooltip:SetVerticalPadding(1)
                                ZO_Tooltip_AddDivider(GameTooltip)
                                GameTooltip:SetVerticalPadding(5)
                                GameTooltip:AddLine(description, "", ZO_NORMAL_TEXT:UnpackRGBA())
                            end
                        end
                    end
                end)

                row:SetHandler("OnMouseExit", function ()
                    ClearTooltip(GameTooltip)
                end)
            end

            self.synergyControls[i] =
            {
                row = row,
                iconBg = iconBg,
                icon = icon,
                posNum = posNum,
                name = name,
                priority = priority,
                cooldown = cooldown,
                cooldownText = cooldownText,
                abilityId = nil,
            }
        end
    end

    -- Initialize position and settings
    local Settings = CombatInfo.SV.synergy

    -- Register for HUD and HUDUI scene state changes to show/hide control
    local hudScene = sceneManager:GetScene(HUD_SCENE)
    local hudUIScene = sceneManager:GetScene(HUDUI_SCENE)

    local function OnSceneStateChange(oldState, newState)
        local isShown = newState == SCENE_SHOWN
        if isShown then
            zo_callLater(function () self:OnShowing() end, 0)
        else
            zo_callLater(function () self:OnHidden() end, 0)
        end
        -- Show/hide control based on scene state (unless unlocked for positioning)
        if not Settings.unlocked then
            self.control:SetHidden(not isShown)
        end
    end

    hudScene:RegisterCallback("StateChange", OnSceneStateChange)
    hudUIScene:RegisterCallback("StateChange", OnSceneStateChange)

    -- Initial state check
    local currentScene = sceneManager:GetCurrentScene()
    if currentScene == hudScene or currentScene == hudUIScene then
        if currentScene:GetState() == SCENE_SHOWN then
            self:OnShowing()
        end
    else
        self.control:SetHidden(true)
    end

    -- Restore saved position or use default
    if Settings.offsetX and Settings.offsetY then
        self.control:ClearAnchors()
        self.control:SetAnchor(CENTER, GuiRoot, CENTER, Settings.offsetX, Settings.offsetY)
    else
        self.control:ClearAnchors()
        self.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 200)
    end

    -- Update movable state based on settings
    self.control:SetMovable(Settings.unlocked)
    self.control:SetMouseEnabled(Settings.unlocked)

    -- Set background visibility
    if self.bg then
        self.bg:SetHidden(not Settings.unlocked)
    end

    -- Unlock/lock handlers
    if IsConsoleUI() and LUIE.ConsoleMoverHelper then
        -- Console version: Get preview elements from XML
        local MoverHelper = LUIE.ConsoleMoverHelper
        local preview = LUIE_SynergyTracker_UI_Preview
        local coordLabel = LUIE_SynergyTracker_UI_Preview_CoordLabel
        local previewLabel = LUIE_SynergyTracker_UI_Preview_Label

        if preview then
            self.control.preview = preview
            if coordLabel then
                preview.coordLabel = coordLabel
            end
            if previewLabel then
                self.control.previewLabel = previewLabel
            end

            -- Update coordinate label during movement
            self.control:SetHandler("OnMoveStart", function ()
                eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
                    local left, top = self.control:GetLeft(), self.control:GetTop()
                    if coordLabel then
                        coordLabel:SetText(zo_strformat("<<1>>, <<2>>", left, top))
                    end
                end)
            end)
        end

        self.control:SetHandler("OnMoveStop", function ()
            eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
            -- Convert center coordinates to offset from GuiRoot center
            local centerX, centerY = self.control:GetCenter()
            Settings.offsetX = centerX - GuiRoot:GetWidth() / 2
            Settings.offsetY = centerY - GuiRoot:GetHeight() / 2
        end)

        -- Update fonts
        MoverHelper.UpdateControlState(self.control, "synergyTracker", Settings.unlocked)

        -- Set up gamepad handler if unlocked
        if Settings.unlocked then
            MoverHelper.SetupGamepadHandler(
                self.control,
                "default",
                function (control, left, top)
                    -- Convert center coordinates to offset from GuiRoot center
                    local centerX, centerY = control:GetCenter()
                    Settings.offsetX = centerX - GuiRoot:GetWidth() / 2
                    Settings.offsetY = centerY - GuiRoot:GetHeight() / 2
                end
            )
        end
    else
        -- PC version
        self.control:SetHandler("OnMoveStop", function ()
            -- Convert center coordinates to offset from GuiRoot center
            local centerX, centerY = self.control:GetCenter()
            Settings.offsetX = centerX - GuiRoot:GetWidth() / 2
            Settings.offsetY = centerY - GuiRoot:GetHeight() / 2
        end)
    end

    -- Cooldown timer update loop (updates every second)
    self.lastCooldownUpdate = 0
    -- Note: OnUpdate is handled in XML, but we'll also set it here for safety
    self.control:SetHandler("OnUpdate", function ()
        local currentTime = GetGameTimeMilliseconds()
        if currentTime - self.lastCooldownUpdate >= 1000 then
            self.lastCooldownUpdate = currentTime
            self:UpdateCooldownDisplay()
        end
    end)

    -- Register events
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, function () self:OnSynergyAbilityChanged() end)
    eventManager:RegisterForEvent(moduleName, EVENT_SYNERGY_ABILITY_CHANGED, function () self:OnSynergyAbilityChanged() end)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_DEAD, function () self:OnPlayerDead() end)

    -- Combat event for synergy activation detection (filter by player source)
    eventManager:RegisterForEvent(moduleName, EVENT_COMBAT_EVENT, function (eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        self:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    end)
    eventManager:AddFilterForEvent(moduleName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- Effect changed for cooldown detection (filter by player unit tag)
    eventManager:RegisterForEvent(moduleName, EVENT_EFFECT_CHANGED, function (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        self:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    end)
    eventManager:AddFilterForEvent(moduleName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    -- Clean up any corrupted cooldown groups from old logic
    self:CleanupCorruptedCooldownGroups()

    -- Initial synergy check
    zo_callLater(function () self:RefreshActiveSynergies() end, 100)
end

--- Static handler for OnMoveStop from XML
function SynergyTracker.OnMoveStop()
    if CombatInfo.SynergyTrackerInstance then
        local Settings = CombatInfo.SV.synergy
        local centerX, centerY = CombatInfo.SynergyTrackerInstance.control:GetCenter()
        Settings.offsetX = centerX - GuiRoot:GetWidth() / 2
        Settings.offsetY = centerY - GuiRoot:GetHeight() / 2
    end
end

--- Static handler for OnUpdate from XML
function SynergyTracker.OnUpdate(control)
    if CombatInfo.SynergyTrackerInstance then
        local currentTime = GetGameTimeMilliseconds()
        if currentTime - CombatInfo.SynergyTrackerInstance.lastCooldownUpdate >= 1000 then
            CombatInfo.SynergyTrackerInstance.lastCooldownUpdate = currentTime
            CombatInfo.SynergyTrackerInstance:UpdateCooldownDisplay()
        end
    end
end

--- Called when HUD scene is showing
function SynergyTracker:OnShowing()
    self:RefreshActiveSynergies()
end

--- Called when HUD scene is hidden
function SynergyTracker:OnHidden()
    ClearTooltip(GameTooltip)
end

--- Refresh all active synergies (event-driven)
function SynergyTracker:RefreshActiveSynergies()
    local Settings = CombatInfo.SV.synergy
    local newSynergies = {}
    local numSynergies = GetNumberOfAvailableSynergies()

    local hadNewSynergy = numSynergies > self.lastSynergyCount

    for i = 1, numSynergies do
        local name, icon, prompt, priority, abilityId, canBeUsed = GetSynergyInfoAtIndex(i)

        if abilityId and abilityId > 0 and not Settings.blacklist[abilityId] then
            local overridePriority = Settings.priorityOverrides[abilityId]
            if overridePriority then
                SetSynergyPriorityOverride(abilityId, overridePriority)
                priority = overridePriority
            end

            newSynergies[abilityId] =
            {
                index = i,
                name = name or GetAbilityName(abilityId) or "Unknown",
                icon = icon or GetAbilityIcon(abilityId) or "",
                prompt = prompt or "",
                priority = priority,
                canBeUsed = canBeUsed,
                timestamp = GetGameTimeMilliseconds(),
            }

            if not Settings.detectedSynergies[abilityId] then
                Settings.detectedSynergies[abilityId] =
                {
                    name = newSynergies[abilityId].name,
                    icon = newSynergies[abilityId].icon,
                    firstSeen = GetGameTimeMilliseconds(),
                    timesSeen = 0,
                }
            end
        end
    end

    for abilityId, data in pairs(self.activeSynergies) do
        if not newSynergies[abilityId] then
            self:OnSynergyRemoved(abilityId, data)
        end
        -- Don't clear cooldowns for synergies that are still active
        -- They can be active (available) but still on cooldown for the player
    end

    -- Don't clear cooldowns for newly appearing synergies
    -- The synergy might reappear (someone else cast it) but player still has personal cooldown

    self.activeSynergies = newSynergies
    self.lastSynergyCount = numSynergies

    local currentTime = GetGameTimeMilliseconds()
    for abilityId, cooldownData in pairs(self.synergyCooldowns) do
        local elapsed = currentTime - cooldownData.startTime
        if elapsed >= cooldownData.duration then
            self.synergyCooldowns[abilityId] = nil
        end
    end

    self:UpdateDisplay()

    if hadNewSynergy and Settings.playSound and numSynergies > 0 then
        PlaySound(SOUNDS.ABILITY_SYNERGY_READY)
    end
end

--- Update the multi-synergy display
function SynergyTracker:UpdateDisplay()
    -- Don't update display if not in HUD/HUDUI scene
    local currentScene = sceneManager:GetCurrentScene()
    if currentScene ~= sceneManager:GetScene(HUD_SCENE) and currentScene ~= sceneManager:GetScene(HUDUI_SCENE) then
        return
    end
    if currentScene:GetState() ~= SCENE_SHOWN then
        return
    end

    -- Don't update if synergy controls haven't been loaded yet
    if not self.synergyControls or not self.synergyControls[1] then
        return
    end

    local Settings = CombatInfo.SV.synergy
    local numSynergies = GetNumberOfAvailableSynergies()
    local displayMode = Settings.displayMode
    local maxDisplay = Settings.maxDisplay or MAX_SYNERGY_SLOTS

    for i = 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        if control then
            control.row:SetHidden(true)
            if control.cooldown then
                control.cooldown:SetHidden(true)
            end
            if control.cooldownText then
                control.cooldownText:SetHidden(true)
            end
        end
    end

    if displayMode == "single" then
        local hasSynergy, synergyName, iconFilename, prompt = GetCurrentSynergyInfo()

        if hasSynergy and self.synergyControls[1] then
            local control = self.synergyControls[1]
            if control.icon then
                control.icon:SetTexture(iconFilename)
            end
            if control.name then
                control.name:SetText(prompt ~= "" and prompt or synergyName)
            end
            if control.priority then
                control.priority:SetHidden(true)
            end
            if control.cooldown then
                control.cooldown:SetHidden(true)
            end
            if control.cooldownText then
                control.cooldownText:SetHidden(true)
            end
            control.row:SetHidden(false)
        end

        self.control:SetHidden(not hasSynergy)
        self:UpdateCooldownDisplay()
        return
    end

    local displayList = {}
    local currentTime = GetGameTimeMilliseconds()
    local activeMap = {}

    for i = 1, numSynergies do
        local name, icon, prompt, priority, abilityId, canBeUsed = GetSynergyInfoAtIndex(i)
        if abilityId and abilityId > 0 then
            activeMap[abilityId] =
            {
                name = name,
                icon = icon,
                prompt = prompt,
                priority = priority,
                canBeUsed = canBeUsed,
            }
        end
    end

    for abilityId, synergyData in pairs(Settings.detectedSynergies) do
        if not Settings.blacklist[abilityId] then
            local isActive = activeMap[abilityId] ~= nil
            local cooldownData = self.synergyCooldowns[abilityId]
            local priority = Settings.priorityOverrides[abilityId] or 0

            local isOnCooldown = false
            local cooldownRemaining = nil
            if Settings.showCooldowns and cooldownData then
                local elapsed = currentTime - cooldownData.startTime
                local remaining = cooldownData.duration - elapsed
                if remaining > 0 then
                    isOnCooldown = true
                    cooldownRemaining = remaining
                end
            end

            local displayData = activeMap[abilityId] or
                {
                    name = synergyData.name,
                    icon = synergyData.icon,
                    prompt = "",
                    priority = priority,
                    canBeUsed = false,
                }

            table.insert(displayList,
                         {
                             abilityId = abilityId,
                             name = displayData.name,
                             icon = displayData.icon,
                             prompt = displayData.prompt or "",
                             priority = displayData.priority,
                             canBeUsed = isActive and displayData.canBeUsed,
                             isOnCooldown = isOnCooldown,
                             cooldownRemaining = cooldownRemaining,
                             isActive = isActive,
                         })
        end
    end

    table.sort(displayList, function (a, b)
        if a.isActive ~= b.isActive then
            return a.isActive
        end
        if a.priority ~= b.priority then
            return a.priority > b.priority
        end
        return a.name < b.name
    end)

    local displayCount = math_min(#displayList, maxDisplay)
    for i = 1, displayCount do
        local synergyData = displayList[i]
        local control = self.synergyControls[i]
        if not control then
            break
        end

        if control.icon then
            control.icon:SetTexture(synergyData.icon)
        end

        local displayText = synergyData.prompt
        if displayText == "" or displayMode == "compact" then
            displayText = synergyData.name
        end

        if control.name then
            control.name:SetText(displayText)
        end

        if Settings.showPriority and control.priority then
            control.priority:SetText(string_format("P%d", synergyData.priority))
            control.priority:SetHidden(false)
        elseif control.priority then
            control.priority:SetHidden(true)
        end

        if control.posNum then
            control.posNum:SetHidden(not Settings.showKeybinds)
        end

        if control.icon then
            if synergyData.isActive and synergyData.canBeUsed then
                control.icon:SetDesaturation(0)
            elseif synergyData.isOnCooldown then
                control.icon:SetDesaturation(1)
            elseif self.synergyCooldowns[synergyData.abilityId] then
                control.icon:SetDesaturation(0.3)
            else
                control.icon:SetDesaturation(0.6)
            end
        end

        control.abilityId = synergyData.abilityId
        control.row:SetHidden(false)
    end

    local cooldownCount = NonContiguousCount(self.synergyCooldowns)
    local totalToShow = math_max(numSynergies, cooldownCount)
    self.control:SetHidden(totalToShow == 0)

    self:UpdateCooldownDisplay()
end

--- Update cooldown timer displays (called every second)
function SynergyTracker:UpdateCooldownDisplay()
    local currentTime = GetGameTimeMilliseconds()
    local Settings = CombatInfo.SV.synergy

    for i = 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        if not control then
            break
        end
        local abilityId = control.abilityId

        if not control.row:IsHidden() and abilityId and self.synergyCooldowns[abilityId] then
            local cooldownData = self.synergyCooldowns[abilityId]
            local elapsed = currentTime - cooldownData.startTime
            local remaining = cooldownData.duration - elapsed

            if remaining > 0 and Settings.showCooldowns then
                if control.cooldown then
                    control.cooldown:StartCooldown(
                        remaining,
                        cooldownData.duration,
                        CD_TYPE_VERTICAL_REVEAL,
                        CD_TIME_TYPE_TIME_REMAINING,
                        false
                    )
                    control.cooldown:SetHidden(false)
                end

                if control.cooldownText then
                    local seconds = math_ceil(remaining / 1000)
                    control.cooldownText:SetText(string_format("%d", seconds))
                    control.cooldownText:SetHidden(false)
                end
            else
                if control.cooldown then
                    control.cooldown:SetHidden(true)
                end
                if control.cooldownText then
                    control.cooldownText:SetHidden(true)
                end
            end
        else
            if control.cooldown then
                control.cooldown:SetHidden(true)
            end
            if control.cooldownText then
                control.cooldownText:SetHidden(true)
            end
        end
    end
end

--- Synergy was removed (activated, timed out, or source destroyed)
--- @param abilityId integer Synergy ability ID
--- @param data table Synergy data
function SynergyTracker:OnSynergyRemoved(abilityId, data)
    local Settings = CombatInfo.SV.synergy

    if Settings.detectedSynergies[abilityId] then
        Settings.detectedSynergies[abilityId].timesSeen = (Settings.detectedSynergies[abilityId].timesSeen or 0) + 1
    end

    local cooldownDuration = GetAbilityCooldown(abilityId, "player")

    if Settings.showCooldowns and cooldownDuration and cooldownDuration > 0 then
        local currentTime = GetGameTimeMilliseconds()
        local sharedGroup = self:GetSharedCooldownGroup(abilityId)

        for _, groupAbilityId in ipairs(sharedGroup) do
            local synergyData = Settings.detectedSynergies[groupAbilityId]
            if synergyData and not Settings.blacklist[groupAbilityId] then
                self.synergyCooldowns[groupAbilityId] =
                {
                    startTime = currentTime,
                    duration = cooldownDuration,
                    name = synergyData.name,
                    icon = synergyData.icon,
                    priority = Settings.priorityOverrides[groupAbilityId] or 0,
                }
            end
        end

        self:UpdateDisplay()
    end
end

--- Event: Synergy ability changed (primary event)
function SynergyTracker:OnSynergyAbilityChanged()
    self:RefreshActiveSynergies()
end

--- Event: Player dead
function SynergyTracker:OnPlayerDead()
    ZO_ClearTable(self.activeSynergies)
    ZO_ClearTable(self.synergyCooldowns)
    self.lastSynergyCount = 0
    self:UpdateDisplay()
end

--- Event: Effect changed (immediate cooldown detection)
--- @param eventCode integer
--- @param changeType EffectResult
--- @param effectSlot integer
--- @param effectName string
--- @param unitTag string
--- @param beginTime number
--- @param endTime number
--- @param stackCount integer
--- @param iconName string
--- @param deprecatedBuffType string
--- @param effectType BuffEffectType
--- @param abilityType AbilityType
--- @param statusEffectType StatusEffectType
--- @param unitName string
--- @param unitId integer
--- @param abilityId integer
--- @param sourceType CombatUnitType
function SynergyTracker:OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    local Settings = CombatInfo.SV.synergy

    if not Settings.showCooldowns then
        return
    end

    if not abilityId or abilityId <= 0 then
        return
    end

    if not Settings.detectedSynergies[abilityId] or Settings.blacklist[abilityId] then
        return
    end

    if changeType == EFFECT_RESULT_FADED then
        self:ApplyImmediateCooldown(abilityId)
    elseif changeType == EFFECT_RESULT_GAINED then
        self.synergyCooldowns[abilityId] = nil
        self:UpdateDisplay()
    end
end

--- Event: Combat event (synergy activation detection)
--- @param eventCode integer
--- @param result ActionResult
--- @param isError boolean
--- @param abilityName string
--- @param abilityGraphic integer
--- @param abilityActionSlotType ActionSlotType
--- @param sourceName string
--- @param sourceType CombatUnitType
--- @param targetName string
--- @param targetType CombatUnitType
--- @param hitValue integer
--- @param powerType CombatMechanicFlags
--- @param damageType DamageType
--- @param log boolean
--- @param sourceUnitId integer
--- @param targetUnitId integer
--- @param abilityId integer
--- @param overflow integer
function SynergyTracker:OnCombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
    local Settings = CombatInfo.SV.synergy

    if Settings.detectedSynergies[abilityId] and not Settings.blacklist[abilityId] then
        if result > 0 and result < 2000 then
            self:DetectSharedCooldowns(abilityId)
        end
    end
end

--- Clean up old corrupted cooldown groups from saved variables
function SynergyTracker:CleanupCorruptedCooldownGroups()
    local Settings = CombatInfo.SV.synergy

    if not Settings.cooldownGroups then
        Settings.cooldownGroups = {}
        return
    end

    local oldCount = NonContiguousCount(Settings.cooldownGroups)
    ZO_ClearTable(Settings.cooldownGroups)

    if oldCount > 0 and LUIE.IsDevDebugEnabled() then
        LUIE.Debug("Cleared %d old cooldown groups", oldCount)
    end
end

--- Get shared cooldown group for a synergy
--- @param abilityId integer Synergy ability ID
--- @return integer[] Group of synergy IDs that share cooldowns
function SynergyTracker:GetSharedCooldownGroup(abilityId)
    local hardcodedGroup = HARDCODED_SHARED_COOLDOWNS[abilityId]
    if hardcodedGroup then
        return hardcodedGroup
    end
    return { abilityId }
end

--- Detect and apply shared cooldowns for activated synergy
--- @param activatedAbilityId integer Activated synergy ability ID
function SynergyTracker:DetectSharedCooldowns(activatedAbilityId)
    local Settings = CombatInfo.SV.synergy

    if not Settings.showCooldowns then
        return
    end

    local currentTime = GetGameTimeMilliseconds()
    local cooldownDuration = GetAbilityCooldown(activatedAbilityId, "player")

    if not cooldownDuration or cooldownDuration == 0 then
        return
    end

    local sharedGroup = self:GetSharedCooldownGroup(activatedAbilityId)

    -- Apply cooldown to all group members that don't already have it
    for _, abilityId in ipairs(sharedGroup) do
        local synergyData = Settings.detectedSynergies[abilityId]
        if synergyData and not self.synergyCooldowns[abilityId] then
            self.synergyCooldowns[abilityId] =
            {
                startTime = currentTime,
                duration = cooldownDuration,
                name = synergyData.name,
                icon = synergyData.icon,
                priority = Settings.priorityOverrides[abilityId] or 0,
            }
        end
    end

    self:UpdateDisplay()
end

--- Apply immediate cooldown when synergy effect fades
--- @param abilityId integer Synergy ability ID
function SynergyTracker:ApplyImmediateCooldown(abilityId)
    local Settings = CombatInfo.SV.synergy
    local currentTime = GetGameTimeMilliseconds()
    local cooldownDuration = GetAbilityCooldown(abilityId, "player")

    if not cooldownDuration or cooldownDuration == 0 then
        return
    end

    local sharedGroup = self:GetSharedCooldownGroup(abilityId)

    for _, groupAbilityId in ipairs(sharedGroup) do
        local synergyData = Settings.detectedSynergies[groupAbilityId]
        if synergyData and not Settings.blacklist[groupAbilityId] then
            self.synergyCooldowns[groupAbilityId] =
            {
                startTime = currentTime,
                duration = cooldownDuration,
                name = synergyData.name,
                icon = synergyData.icon,
                priority = Settings.priorityOverrides[groupAbilityId] or 0,
            }
        end
    end

    self:UpdateDisplay()
end

--- Unlock/lock UI for positioning
--- @param unlocked boolean Whether to unlock the UI
function SynergyTracker:SetUnlocked(unlocked)
    local Settings = CombatInfo.SV.synergy
    Settings.unlocked = unlocked

    if IsConsoleUI() and LUIE.ConsoleMoverHelper then
        local MoverHelper = LUIE.ConsoleMoverHelper
        local EditModeController = LUIE.EditModeController

        if unlocked then
            -- Set up gamepad handler if not already set up
            if not self.control.gamepadHandler then
                MoverHelper.SetupGamepadHandler(
                    self.control,
                    "default",
                    function (control, left, top)
                        -- Convert center coordinates to offset from GuiRoot center
                        local centerX, centerY = control:GetCenter()
                        Settings.offsetX = centerX - GuiRoot:GetWidth() / 2
                        Settings.offsetY = centerY - GuiRoot:GetHeight() / 2
                    end
                )
            end

            -- Activate edit mode
            if EditModeController then
                EditModeController:SetEditModeActive(true, "SynergyTracker")
            end

            self:ShowPreview()
        else
            -- Clean up gamepad handler
            if self.control.gamepadHandler then
                -- Handler cleanup is handled by MoverHelper.UpdateControlState
            end

            -- When locking, hide preview and return to normal display
            local currentScene = sceneManager:GetCurrentScene()
            local isInHUDScene = currentScene == sceneManager:GetScene(HUD_SCENE) or currentScene == sceneManager:GetScene(HUDUI_SCENE)
            if not isInHUDScene or currentScene:GetState() ~= SCENE_SHOWN then
                -- If we're not in HUD/HUDUI scene, hide the control
                self.control:SetHidden(true)
            else
                self:UpdateDisplay()
            end
        end

        -- Update control state
        MoverHelper.UpdateControlState(self.control, "synergyTracker", unlocked)
    else
        -- PC version
        self.control:SetMovable(unlocked)
        self.control:SetMouseEnabled(unlocked)
        if self.bg then
            self.bg:SetHidden(not unlocked)
        end

        if unlocked then
            self:ShowPreview()
        else
            -- When locking, hide preview and return to normal display
            local currentScene = sceneManager:GetCurrentScene()
            local isInHUDScene = currentScene == sceneManager:GetScene(HUD_SCENE) or currentScene == sceneManager:GetScene(HUDUI_SCENE)
            if not isInHUDScene or currentScene:GetState() ~= SCENE_SHOWN then
                -- If we're not in HUD/HUDUI scene, hide the control
                self.control:SetHidden(true)
            else
                self:UpdateDisplay()
            end
        end
    end
end

--- Show preview synergies for positioning
function SynergyTracker:ShowPreview()
    for i = 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        if control then
            if control.icon then
                control.icon:SetTexture("esoui/art/icons/ability_undaunted_001.dds")
            end
            if control.name then
                control.name:SetText(string_format("Preview Synergy %d", i))
                control.name:SetColor(1, 1, 1, 1)
            end
            if control.priority then
                control.priority:SetText(string_format("P%d", i))
            end
            if control.icon then
                control.icon:SetDesaturation(0)
            end
            control.row:SetHidden(false)
        end
    end

    for i = 4, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        if control then
            control.row:SetHidden(true)
        end
    end

    -- Force show when in unlock mode (even outside HUD scenes for positioning)
    self.control:SetHidden(false)
end

--- Reset position to default
function SynergyTracker:ResetPosition()
    local Settings = CombatInfo.SV.synergy
    Settings.offsetX = 0
    Settings.offsetY = 200

    self.control:ClearAnchors()
    self.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 200)
end

--- Update display options (keybinds, priority visibility)
function SynergyTracker:UpdateDisplayOptions()
    local Settings = CombatInfo.SV.synergy

    for i = 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        if control then
            if control.posNum then
                control.posNum:SetHidden(not Settings.showKeybinds)
            end
            if control.priority then
                control.priority:SetHidden(not Settings.showPriority)
            end
        end
    end

    self:UpdateDisplay()
end

--- Set priority override for a synergy
--- @param abilityId integer Synergy ability ID
--- @param priority integer|nil Priority value (nil to clear)
function SynergyTracker:SetPriorityOverride(abilityId, priority)
    local Settings = CombatInfo.SV.synergy

    if priority and priority > 0 then
        Settings.priorityOverrides[abilityId] = priority
        SetSynergyPriorityOverride(abilityId, priority)
    else
        Settings.priorityOverrides[abilityId] = nil
        ClearSynergyPriorityOverride(abilityId)
    end

    self:RefreshActiveSynergies()
end

--- Clear all priority overrides
function SynergyTracker:ClearAllPriorityOverrides()
    local Settings = CombatInfo.SV.synergy
    Settings.priorityOverrides = {}
    ClearAllSynergyPriorityOverrides()
    self:RefreshActiveSynergies()
end

--- Get sorted list of detected synergies
--- @return table[] Sorted list of synergy data
function SynergyTracker:GetDetectedSynergiesSorted()
    local Settings = CombatInfo.SV.synergy
    local list = {}

    for abilityId, data in pairs(Settings.detectedSynergies) do
        table.insert(list,
                     {
                         abilityId = abilityId,
                         name = data.name,
                         icon = data.icon,
                         timesSeen = data.timesSeen or 0,
                         firstSeen = data.firstSeen,
                     })
    end

    table.sort(list, function (a, b)
        return a.name < b.name
    end)

    return list
end

--- Factory function to create and initialize the tracker
--- @return SynergyTracker|nil Tracker instance or nil if disabled
function CombatInfo.InitializeSynergyTracker()
    -- Return existing instance if already created (singleton pattern)
    if CombatInfo.SynergyTrackerInstance then
        return CombatInfo.SynergyTrackerInstance
    end

    if not LUIE.SV.CombatInfo_Enabled then
        return
    end

    local Settings = CombatInfo.SV.synergy
    if not Settings.enabled then
        return
    end

    -- Create the tracker instance
    local tracker = SynergyTracker:New()

    -- Store globally for access from settings
    CombatInfo.SynergyTrackerInstance = tracker

    return tracker
end
