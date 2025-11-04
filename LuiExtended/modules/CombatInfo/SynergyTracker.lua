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
local windowManager = GetWindowManager()
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

--- @class SynergyTracker : ZO_DeferredInitializingObject
--- @field control TopLevelWindow Main UI control
--- @field fragment ZO_FadeSceneFragment Scene fragment for HUD integration
--- @field bg Control Background control for unlock mode
--- @field activeSynergies table<integer, table> Currently active synergies
--- @field synergyControls table[] UI controls for each synergy slot
--- @field synergyCooldowns table<integer, table> Synergies currently on cooldown
--- @field lastSynergyCount integer Last known synergy count
--- @field lastCooldownUpdate integer Last cooldown UI update time
--- @field lastLoggedCooldownCount integer Last logged cooldown count (for debug)
local SynergyTracker = ZO_DeferredInitializingObject:Subclass()
CombatInfo.SynergyTracker = SynergyTracker

--- Create new SynergyTracker instance
--- @return SynergyTracker
function SynergyTracker:New()
    local obj = ZO_DeferredInitializingObject.New(self)
    obj:Initialize()
    return obj
end

--- Initialize the SynergyTracker (creates control and fragment)
function SynergyTracker:Initialize()
    self.activeSynergies = {}
    self.synergyControls = {}
    self.lastSynergyCount = 0
    self.synergyCooldowns = {}
    self.lastLoggedCooldownCount = 0

    -- Get or create control (check for existing control first)
    local controlName = "LUIE_SynergyTracker_UI"
    local control = windowManager:GetControlByName(controlName)

    if not control then
        control = windowManager:CreateTopLevelWindow(controlName)
        control:SetParent(GuiRoot)
        control:SetDimensions(SYNERGY_ROW_WIDTH, MAX_SYNERGY_SLOTS * SYNERGY_ROW_HEIGHT)
        control:SetDrawLayer(DL_OVERLAY)
        control:SetDrawTier(DT_MEDIUM)
        control:SetDrawLevel(1)
        control:SetMouseEnabled(false)
        control:SetClampedToScreen(true)
        control:SetHidden(true)
    end

    self.control = control

    -- Create scene fragment
    self.fragment = ZO_FadeSceneFragment:New(control)

    -- Add fragment to HUD and HUDUI scenes
    sceneManager:GetScene(HUD_SCENE):AddFragment(self.fragment)
    sceneManager:GetScene(HUDUI_SCENE):AddFragment(self.fragment)

    -- Initialize with fragment
    ZO_DeferredInitializingObject.Initialize(self, self.fragment)
end

--- Deferred initialization (creates UI controls, registers events)
--- Called automatically when HUD scene first shows
function SynergyTracker:OnDeferredInitialize()
    local Settings = CombatInfo.SV.synergy

    -- Restore saved position or use default
    if Settings.offsetX and Settings.offsetY then
        self.control:ClearAnchors()
        self.control:SetAnchor(CENTER, GuiRoot, CENTER, Settings.offsetX, Settings.offsetY)
    else
        self.control:SetAnchor(CENTER, GuiRoot, CENTER, 0, 200)
    end

    -- Update movable state based on settings
    self.control:SetMovable(Settings.unlocked)
    self.control:SetMouseEnabled(Settings.unlocked)

    -- Background (for visibility when unlocked)
    local bg = windowManager:CreateControl(nil, self.control, CT_BACKDROP)
    bg:SetAnchorFill()
    bg:SetCenterColor(0, 0, 0, 0.5)
    bg:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
    bg:SetEdgeTexture("", 1, 1, 0, 0)
    bg:SetHidden(not Settings.unlocked)
    self.bg = bg

    -- Create synergy display rows
    for i = 1, MAX_SYNERGY_SLOTS do
        local row = windowManager:CreateControl("LUIE_SynergyRow" .. i, self.control, CT_CONTROL)
        row:SetDimensions(SYNERGY_ROW_WIDTH, SYNERGY_ROW_HEIGHT)
        row:SetAnchor(TOP, self.control, TOP, 0, (i - 1) * SYNERGY_ROW_HEIGHT)
        row:SetMouseEnabled(true)
        row:SetHidden(true)

        -- Icon background
        local iconBg = windowManager:CreateControl(nil, row, CT_TEXTURE)
        iconBg:SetDimensions(SYNERGY_ICON_SIZE, SYNERGY_ICON_SIZE)
        iconBg:SetAnchor(LEFT, row, LEFT, 2, 0)
        iconBg:SetTexture("EsoUI/Art/ActionBar/abilityFrame64_up.dds")

        -- Icon
        local icon = windowManager:CreateControl(nil, iconBg, CT_TEXTURE)
        icon:SetDimensions(SYNERGY_ICON_SIZE - 4, SYNERGY_ICON_SIZE - 4)
        icon:SetAnchor(CENTER, iconBg, CENTER, 0, 0)

        -- Position number (optional)
        local posNum = windowManager:CreateControl(nil, row, CT_LABEL)
        posNum:SetFont("ZoFontGamepad27")
        posNum:SetAnchor(LEFT, iconBg, RIGHT, 5, 0)
        posNum:SetText(i)
        posNum:SetColor(1, 1, 0.5, 1)
        posNum:SetHidden(not Settings.showKeybinds)

        -- Synergy name/prompt
        local name = windowManager:CreateControl(nil, row, CT_LABEL)
        name:SetFont("ZoInteractionPrompt")
        name:SetAnchor(LEFT, posNum, RIGHT, 8, 0)
        name:SetDimensionConstraints(0, 0, 200, SYNERGY_ROW_HEIGHT)
        name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        name:SetVerticalAlignment(TEXT_ALIGN_CENTER)

        -- Priority indicator
        local priority = windowManager:CreateControl(nil, row, CT_LABEL)
        priority:SetFont("ZoFontGame")
        priority:SetAnchor(RIGHT, row, RIGHT, -5, 0)
        priority:SetColor(0.7, 0.7, 0.7, 1)
        priority:SetHidden(not Settings.showPriority)

        -- Cooldown overlay (vertical reveal on icon)
        local cooldown = windowManager:CreateControl(nil, icon, CT_COOLDOWN)
        cooldown:SetDrawLayer(DL_OVERLAY)
        cooldown:SetDrawTier(DT_MEDIUM)
        cooldown:SetAnchorFill(icon)
        cooldown:SetTexture("EsoUI/Art/ActionBar/abilityHighlight.dds")
        cooldown:SetFillColor(0, 0, 0, 0.7)
        cooldown:SetDesaturation(1)
        cooldown:SetHidden(true)

        -- Cooldown text (shows time remaining)
        local cooldownText = windowManager:CreateControl(nil, iconBg, CT_LABEL)
        cooldownText:SetFont("ZoFontGameBold")
        cooldownText:SetAnchor(CENTER, iconBg, CENTER, 0, 0)
        cooldownText:SetColor(1, 1, 1, 1)
        cooldownText:SetDrawLayer(DL_OVERLAY)
        cooldownText:SetDrawTier(DT_MEDIUM)
        cooldownText:SetHidden(true)

        -- Tooltip handlers
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

        row:SetHandler("OnMouseExit", function (control)
            ClearTooltip(GameTooltip)
        end)

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

    -- Unlock/lock handlers
    self.control:SetHandler("OnMoveStop", function ()
        Settings.offsetX = self.control:GetLeft() - GuiRoot:GetWidth() / 2
        Settings.offsetY = self.control:GetTop() - GuiRoot:GetHeight() / 2
    end)

    -- Cooldown timer update loop (updates every second)
    self.lastCooldownUpdate = 0
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
    self:RefreshActiveSynergies()
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
    -- Don't update display if fragment isn't showing (not in HUD/HUDUI scene)
    if not self.fragment:IsShowing() then
        return
    end

    local Settings = CombatInfo.SV.synergy
    local numSynergies = GetNumberOfAvailableSynergies()
    local displayMode = Settings.displayMode
    local maxDisplay = Settings.maxDisplay or MAX_SYNERGY_SLOTS

    for i = 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        control.row:SetHidden(true)
        control.cooldown:SetHidden(true)
        control.cooldownText:SetHidden(true)
    end

    if displayMode == "single" then
        local hasSynergy, synergyName, iconFilename, prompt = GetCurrentSynergyInfo()

        if hasSynergy then
            local control = self.synergyControls[1]
            control.icon:SetTexture(iconFilename)
            control.name:SetText(prompt ~= "" and prompt or synergyName)
            control.priority:SetHidden(true)
            control.cooldown:SetHidden(true)
            control.cooldownText:SetHidden(true)
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

        control.icon:SetTexture(synergyData.icon)

        local displayText = synergyData.prompt
        if displayText == "" or displayMode == "compact" then
            displayText = synergyData.name
        end

        control.name:SetText(displayText)

        if Settings.showPriority then
            control.priority:SetText(string_format("P%d", synergyData.priority))
            control.priority:SetHidden(false)
        else
            control.priority:SetHidden(true)
        end

        control.posNum:SetHidden(not Settings.showKeybinds)

        if synergyData.isActive and synergyData.canBeUsed then
            control.icon:SetDesaturation(0)
        elseif synergyData.isOnCooldown then
            control.icon:SetDesaturation(1)
        elseif self.synergyCooldowns[synergyData.abilityId] then
            control.icon:SetDesaturation(0.3)
        else
            control.icon:SetDesaturation(0.6)
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
        local abilityId = control.abilityId

        if not control.row:IsHidden() and abilityId and self.synergyCooldowns[abilityId] then
            local cooldownData = self.synergyCooldowns[abilityId]
            local elapsed = currentTime - cooldownData.startTime
            local remaining = cooldownData.duration - elapsed

            if remaining > 0 and Settings.showCooldowns then
                control.cooldown:StartCooldown(
                    remaining,
                    cooldownData.duration,
                    CD_TYPE_VERTICAL_REVEAL,
                    CD_TIME_TYPE_TIME_REMAINING,
                    false
                )
                control.cooldown:SetHidden(false)

                local seconds = math_ceil(remaining / 1000)
                control.cooldownText:SetText(string_format("%d", seconds))
                control.cooldownText:SetHidden(false)
            else
                control.cooldown:SetHidden(true)
                control.cooldownText:SetHidden(true)
            end
        else
            control.cooldown:SetHidden(true)
            control.cooldownText:SetHidden(true)
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

    self.control:SetMovable(unlocked)
    self.control:SetMouseEnabled(unlocked)
    self.bg:SetHidden(not unlocked)

    if unlocked then
        self:ShowPreview()
    else
        -- When locking, hide preview and return to normal display
        if not self.fragment:IsShowing() then
            -- If we're not in HUD/HUDUI scene, hide the control
            self.control:SetHidden(true)
        else
            self:UpdateDisplay()
        end
    end
end

--- Show preview synergies for positioning
function SynergyTracker:ShowPreview()
    for i = 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        control.icon:SetTexture("esoui/art/icons/ability_undaunted_001.dds")
        control.name:SetText(string_format("Preview Synergy %d", i))
        control.priority:SetText(string_format("P%d", i))
        control.icon:SetDesaturation(0)
        control.name:SetColor(1, 1, 1, 1)
        control.row:SetHidden(false)
    end

    for i = 4, MAX_SYNERGY_SLOTS do
        self.synergyControls[i].row:SetHidden(true)
    end

    -- Force show when in unlock mode (even outside HUD scenes for positioning)
    if not self.fragment:IsShowing() then
        self.fragment:Show()
    end
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
        self.synergyControls[i].posNum:SetHidden(not Settings.showKeybinds)
        self.synergyControls[i].priority:SetHidden(not Settings.showPriority)
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
