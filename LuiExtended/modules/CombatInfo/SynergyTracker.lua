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
local PREVIEW_ROW_COUNT = 3
local ROW_WIDTH_FULL = 320
local ROW_WIDTH_MINIMAL = 44
local ROW_HEIGHT = 44
local MINIMAL_SLOT_GAP = 2
local CONTROL_WIDTH_DEFAULT = 320
local CONTROL_HEIGHT_DEFAULT = 440

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

local SORT_TIER_READY = 1
local SORT_TIER_ACTIVE_WAIT = 2
local SORT_TIER_COOLDOWN = 3
local SORT_TIER_IDLE = 4
local SORT_GAME_INDEX_INACTIVE = 999

--- @param entry table
--- @return integer
local function GetSynergyDisplaySortTier(entry)
    if entry.isOnCooldown and entry.cooldownRemaining and entry.cooldownRemaining > 0 then
        return SORT_TIER_COOLDOWN
    end
    if entry.isActive and entry.canBeUsed then
        return SORT_TIER_READY
    end
    if entry.isActive then
        return SORT_TIER_ACTIVE_WAIT
    end
    return SORT_TIER_IDLE
end

--- Tiered sort for Icon + Cooldown (minimal) display mode
--- @param a table
--- @param b table
--- @return boolean
local function CompareSynergyDisplayEntriesMinimal(a, b)
    local tierA = GetSynergyDisplaySortTier(a)
    local tierB = GetSynergyDisplaySortTier(b)
    if tierA ~= tierB then
        return tierA < tierB
    end
    if tierA == SORT_TIER_COOLDOWN then
        if a.cooldownRemaining ~= b.cooldownRemaining then
            return a.cooldownRemaining < b.cooldownRemaining
        end
    end
    if a.priority ~= b.priority then
        return a.priority > b.priority
    end
    local indexA = a.gameIndex or SORT_GAME_INDEX_INACTIVE
    local indexB = b.gameIndex or SORT_GAME_INDEX_INACTIVE
    if indexA ~= indexB then
        return indexA < indexB
    end
    return a.name < b.name
end

--- Legacy multi / compact list sort
--- @param a table
--- @param b table
--- @return boolean
local function CompareSynergyDisplayEntriesLegacy(a, b)
    if a.isActive ~= b.isActive then
        return a.isActive
    end
    if a.priority ~= b.priority then
        return a.priority > b.priority
    end
    return a.name < b.name
end

--- Set font on a label, selecting between PC and console variants
--- @param label LabelControl|nil
--- @param pcFont string Font for keyboard/mouse mode
--- @param consoleFont string Font for gamepad/console mode
local function SetLabelFont(label, pcFont, consoleFont)
    if label then
        label:SetFont((ZO_IsConsoleOrGameCoreUI() or IsInGamepadPreferredMode()) and consoleFont or pcFont)
    end
end

--- @class SynergyTracker : ZO_InitializingObject
--- @field control TopLevelWindow Main UI control
--- @field bg LUIE_SynergyTracker_UI_Background Background control for unlock mode
--- @field activeSynergies table<integer, table> Currently active synergies
--- @field synergyControls table[] UI controls for each synergy slot
--- @field synergyCooldowns table<integer, table> Synergies currently on cooldown
--- @field lastCooldownUpdate integer Last cooldown UI update time
local SynergyTracker = ZO_InitializingObject:Subclass()
CombatInfo.SynergyTracker = SynergyTracker

--- Re-anchor synergy rows (vertical stack vs horizontal icon strip for minimal mode)
--- @param displayMode string
--- @param visibleCount integer|nil Number of slots laid out (0 = defer until next update)
function SynergyTracker:ApplySlotAnchors(displayMode, visibleCount)
    if not self.synergyControls or not self.control then
        return
    end

    local Settings = CombatInfo.SV.synergy
    local isMinimal = displayMode == "minimal"
    local horizontal = isMinimal and Settings.minimalHorizontal
    local slotCount = visibleCount or 0

    for i = 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        if not control then
            break
        end

        local row = control.row
        row:ClearAnchors()

        if isMinimal then
            if slotCount > 0 and i <= slotCount then
                if horizontal then
                    local offsetX = (i - 1) * (ROW_WIDTH_MINIMAL + MINIMAL_SLOT_GAP)
                    row:SetAnchor(TOPLEFT, self.control, TOPLEFT, offsetX, 0)
                else
                    local offsetY = (i - 1) * ROW_HEIGHT
                    row:SetAnchor(TOPLEFT, self.control, TOPLEFT, 0, offsetY)
                end
            else
                row:SetAnchor(TOPLEFT, self.control, TOPLEFT, -10000, 0)
            end
        elseif i == 1 then
            row:SetAnchor(TOP, self.control, TOP, 0, 0)
        else
            local prevRow = self.synergyControls[i - 1].row
            row:SetAnchor(TOP, prevRow, BOTTOM, 0, 0)
        end
    end
end

--- Unlock move UI: backdrop visibility and row mouse so the top-level control receives drags
function SynergyTracker:UpdateUnlockInteraction()
    local Settings = CombatInfo.SV.synergy
    local unlocked = Settings.unlocked
    local isMinimal = Settings.displayMode == "minimal"

    if self.synergyControls then
        for i = 1, MAX_SYNERGY_SLOTS do
            local control = self.synergyControls[i]
            if control and control.row then
                -- Rows are mouse-enabled for tooltips; that blocks dragging the parent while unlocked
                control.row:SetMouseEnabled(not unlocked)
            end
        end
    end

    if self.bg then
        if unlocked and isMinimal then
            self.bg:SetHidden(true)
            self.bg:SetMouseEnabled(false)
        elseif unlocked then
            self.bg:SetHidden(false)
            self.bg:SetMouseEnabled(true)
            self.bg:SetCenterColor(0, 0, 0, 0.5)
            self.bg:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
        else
            self.bg:SetHidden(true)
            self.bg:SetMouseEnabled(false)
        end
    end
end

--- Resize the top-level tracker for minimal layouts
--- @param displayMode string
--- @param visibleCount integer
function SynergyTracker:ApplyContainerDimensions(displayMode, visibleCount)
    if not self.control then
        return
    end

    local Settings = CombatInfo.SV.synergy
    if displayMode == "minimal" and visibleCount > 0 then
        if Settings.minimalHorizontal then
            local width = visibleCount * ROW_WIDTH_MINIMAL + (visibleCount - 1) * MINIMAL_SLOT_GAP
            self.control:SetDimensions(width, ROW_HEIGHT)
        else
            self.control:SetDimensions(ROW_WIDTH_MINIMAL, visibleCount * ROW_HEIGHT)
        end
    else
        self.control:SetDimensions(CONTROL_WIDTH_DEFAULT, CONTROL_HEIGHT_DEFAULT)
    end
end

--- Apply row dimensions and child anchors for the current display mode
--- @param displayMode string
--- @param visibleCount integer|nil
function SynergyTracker:ApplyRowLayout(displayMode, visibleCount)
    if not self.synergyControls then
        return
    end

    local isMinimal = displayMode == "minimal"
    local rowWidth = isMinimal and ROW_WIDTH_MINIMAL or ROW_WIDTH_FULL

    for i = 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        if not control then
            break
        end

        control.row:SetDimensions(rowWidth, ROW_HEIGHT)

        if isMinimal then
            if control.name then
                control.name:SetHidden(true)
                control.name:SetDimensionConstraints(0, 0, 0, 0)
            end
            if control.posNum then
                control.posNum:SetHidden(true)
            end
            if control.priority then
                control.priority:SetHidden(true)
            end
        else
            if control.name then
                control.name:SetHidden(false)
                control.name:SetDimensionConstraints(0, 0, 200, 44)
            end
            if control.priority then
                control.priority:ClearAnchors()
                control.priority:SetAnchor(RIGHT, control.row, RIGHT, -5, 0)
            end
            if control.name and control.posNum then
                control.name:ClearAnchors()
                control.name:SetAnchor(LEFT, control.posNum, RIGHT, 8, 0)
            end
        end
    end

    if visibleCount ~= nil then
        self:ApplySlotAnchors(displayMode, visibleCount)
    end
end

--- Initialize the SynergyTracker (creates rows from virtual template, creates fragment, registers events)
function SynergyTracker:Initialize()
    self.activeSynergies = {}
    self.synergyControls = {}
    self.synergyCooldowns = {}

    local mainControl = LUIE_SynergyTracker_UI
    if not mainControl then
        return
    end

    self.control = mainControl

    self.bg = LUIE_SynergyTracker_UI_Background
    if self.bg then
        self.bg:SetCenterColor(0, 0, 0, 0.5)
        self.bg:SetEdgeColor(0.3, 0.3, 0.3, 0.8)
        self.bg:SetEdgeTexture("", 1, 1, 0, 0)
    end

    -- Instantiate synergy rows from the virtual template
    for i = 1, MAX_SYNERGY_SLOTS do
        local row = CreateControlFromVirtual("LUIE_SynergyTracker_UI_Row" .. i, self.control, "LUIE_SynergyTracker_RowTemplate")

        if i == 1 then
            row:SetAnchor(TOP, self.control, TOP, 0, 0)
        else
            row:SetAnchor(TOP, self.synergyControls[i - 1].row, BOTTOM, 0, 0)
        end

        local iconBg = row:GetNamedChild("_IconBg")             --- @type TextureControl
        local icon = row:GetNamedChild("_Icon")                 --- @type TextureControl
        local posNum = row:GetNamedChild("_PosNum")             --- @type LabelControl
        local name = row:GetNamedChild("_Name")                 --- @type LabelControl
        local priority = row:GetNamedChild("_Priority")         --- @type LabelControl
        local cooldown = row:GetNamedChild("_Cooldown")         --- @type CooldownControl
        local cooldownText = row:GetNamedChild("_CooldownText") --- @type LabelControl

        if posNum then
            posNum:SetText(tostring(i))
        end

        SetLabelFont(name, "ZoInteractionPrompt", "$(GAMEPAD_MEDIUM_FONT)|18|soft-shadow-thick")
        SetLabelFont(priority, "ZoFontGame", "$(GAMEPAD_MEDIUM_FONT)|16|soft-shadow-thick")
        SetLabelFont(cooldownText, "ZoFontGameBold", "$(GAMEPAD_MEDIUM_FONT)|20|soft-shadow-thick")

        if cooldown then
            cooldown:SetDrawTier(DT_MEDIUM)
        end
        if cooldownText then
            cooldownText:SetDrawTier(DT_HIGH)
        end

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

        row:SetHandler("OnMouseUp", function (control, button, upInside)
            self:OnSynergyRowMouseUp(control, button, upInside, i)
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

    local Settings = CombatInfo.SV.synergy

    self:ApplyRowLayout(Settings.displayMode)

    -- Migrate away from the old cooldownGroups saved variable field
    Settings.cooldownGroups = nil

    local hudScene = sceneManager:GetScene(HUD_SCENE)
    local hudUIScene = sceneManager:GetScene(HUDUI_SCENE)

    local function OnSceneStateChange(oldState, newState)
        local isShown = newState == SCENE_SHOWN
        if isShown then
            zo_callLater(function () self:OnShowing() end, 0)
        else
            zo_callLater(function () self:OnHidden() end, 0)
        end
        if not Settings.unlocked and Settings.displayMode ~= "hidden" then
            self.control:SetHidden(not isShown)
        end
    end

    hudScene:RegisterCallback("StateChange", OnSceneStateChange)
    hudUIScene:RegisterCallback("StateChange", OnSceneStateChange)

    local currentScene = sceneManager:GetCurrentScene()
    if currentScene == hudScene or currentScene == hudUIScene then
        if currentScene:GetState() == SCENE_SHOWN then
            self:OnShowing()
        end
    else
        self.control:SetHidden(true)
    end

    self.settingsSceneFragment = ZO_HUDFadeSceneFragment:New(self.control, 0, 0)

    self:ApplyPosition()

    self.control:SetMovable(Settings.unlocked)
    self.control:SetMouseEnabled(Settings.unlocked)

    self:UpdateUnlockInteraction()

    self.control:SetHandler("OnMoveStop", function ()
        local centerX, centerY = self.control:GetCenter()
        Settings.offsetX = centerX - GuiRoot:GetWidth() / 2
        Settings.offsetY = centerY - GuiRoot:GetHeight() / 2
    end)

    self.lastCooldownUpdate = 0
    self.control:SetHandler("OnUpdate", function ()
        local currentTime = GetGameTimeMilliseconds()
        local cooldownInterval = (CombatInfo.SV.synergy.displayMode == "minimal") and 200 or 1000
        if currentTime - self.lastCooldownUpdate >= cooldownInterval then
            self.lastCooldownUpdate = currentTime
            self:UpdateCooldownDisplay()
        end
    end)

    eventManager:RegisterForEvent(moduleName .. "CombatState", EVENT_PLAYER_COMBAT_STATE, function ()
        self:ApplyDisplayAlpha()
    end)

    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, function ()
        self:OnSynergyAbilityChanged()
        self:ApplyDisplayAlpha()
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_SYNERGY_ABILITY_CHANGED, function () self:OnSynergyAbilityChanged() end)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_DEAD, function () self:OnPlayerDead() end)

    eventManager:RegisterForEvent(moduleName, EVENT_COMBAT_EVENT, function (eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        self:OnCombatEvent(result, abilityId)
    end)
    eventManager:AddFilterForEvent(moduleName, EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    eventManager:RegisterForEvent(moduleName, EVENT_EFFECT_CHANGED, function (eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        self:OnEffectChanged(changeType, abilityId)
    end)
    eventManager:AddFilterForEvent(moduleName, EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")

    self:ApplyDisplayAlpha()

    zo_callLater(function () self:RefreshActiveSynergies() end, 100)
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
    local prevNonBlacklistedCount = NonContiguousCount(self.activeSynergies)

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
    end

    local hadNewSynergy = NonContiguousCount(newSynergies) > prevNonBlacklistedCount
    self.activeSynergies = newSynergies

    local currentTime = GetGameTimeMilliseconds()
    for abilityId, cooldownData in pairs(self.synergyCooldowns) do
        if currentTime - cooldownData.startTime >= cooldownData.duration then
            self.synergyCooldowns[abilityId] = nil
        end
    end

    self:UpdateDisplay()

    if hadNewSynergy and Settings.playSound then
        PlaySound(SOUNDS.ABILITY_SYNERGY_READY)
    end
end

--- Update the multi-synergy display
function SynergyTracker:UpdateDisplay()
    local currentScene = sceneManager:GetCurrentScene()
    local hudScene = sceneManager:GetScene(HUD_SCENE)
    local hudUIScene = sceneManager:GetScene(HUDUI_SCENE)
    if (currentScene ~= hudScene and currentScene ~= hudUIScene) or currentScene:GetState() ~= SCENE_SHOWN then
        return
    end

    if not self.synergyControls or not self.synergyControls[1] then
        return
    end

    local Settings = CombatInfo.SV.synergy
    local numSynergies = GetNumberOfAvailableSynergies()
    local displayMode = Settings.displayMode
    local maxDisplay = Settings.maxDisplay or MAX_SYNERGY_SLOTS
    local isMinimal = displayMode == "minimal"

    self:ApplyRowLayout(displayMode)

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

    if displayMode == "hidden" and not Settings.unlocked then
        self.control:SetHidden(true)
        self:ApplyDisplayAlpha()
        return
    end

    if displayMode == "single" then
        -- Build a candidate list and sort by priority, since index order is not priority order.
        local singleCandidates = {}
        for i = 1, numSynergies do
            local name, icon, prompt, priority, abilityId = GetSynergyInfoAtIndex(i)
            if abilityId and abilityId > 0 and not Settings.blacklist[abilityId] then
                table.insert(singleCandidates,
                             {
                                 index = i,
                                 name = name,
                                 icon = icon,
                                 prompt = prompt,
                                 priority = Settings.priorityOverrides[abilityId] or priority or 0,
                                 abilityId = abilityId,
                             })
            end
        end

        table.sort(singleCandidates, function (a, b)
            if a.priority ~= b.priority then
                return a.priority > b.priority
            end

            local aName = a.name or ""
            local bName = b.name or ""
            if aName ~= bName then
                return aName < bName
            end

            return a.index < b.index
        end)

        local topSynergy = singleCandidates[1]
        local showName = topSynergy and topSynergy.name
        local showIcon = topSynergy and topSynergy.icon
        local showPrompt = topSynergy and topSynergy.prompt
        local showAbilityId = topSynergy and topSynergy.abilityId

        local hasSynergy = topSynergy ~= nil
        if hasSynergy and self.synergyControls[1] then
            local control = self.synergyControls[1]
            if control.icon then
                control.icon:SetTexture(showIcon)
            end
            if control.name then
                control.name:SetText((showPrompt and showPrompt ~= "") and showPrompt or (showName or ""))
            end
            if control.priority then
                control.priority:SetHidden(true)
            end
            if control.posNum then
                control.posNum:SetHidden(true)
            end
            control.abilityId = showAbilityId
            control.row:SetHidden(false)
        end

        self.control:SetHidden(not hasSynergy)
        self:ApplyContainerDimensions(displayMode, 0)
        self:UpdateUnlockInteraction()
        self:UpdateCooldownDisplay()
        self:ApplyDisplayAlpha()
        return
    end

    local displayList = {}
    local currentTime = GetGameTimeMilliseconds()

    for abilityId, synergyData in pairs(Settings.detectedSynergies) do
        if not Settings.blacklist[abilityId] then
            local activeData = self.activeSynergies[abilityId]
            local isActive = activeData ~= nil
            local cooldownData = self.synergyCooldowns[abilityId]
            local priority = Settings.priorityOverrides[abilityId] or 0

            local isOnCooldown = false
            local cooldownRemaining = nil
            if Settings.showCooldowns and cooldownData then
                local remaining = cooldownData.duration - (currentTime - cooldownData.startTime)
                if remaining > 0 then
                    isOnCooldown = true
                    cooldownRemaining = remaining
                end
            end

            local displayData = activeData or
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
                             gameIndex = activeData and activeData.index or SORT_GAME_INDEX_INACTIVE,
                         })
        end
    end

    if isMinimal then
        table.sort(displayList, CompareSynergyDisplayEntriesMinimal)
    else
        table.sort(displayList, CompareSynergyDisplayEntriesLegacy)
    end

    local displayCount = zo_min(#displayList, maxDisplay)
    for i = 1, displayCount do
        local synergyData = displayList[i]
        local control = self.synergyControls[i]
        if not control then
            break
        end

        if control.icon then
            control.icon:SetTexture(synergyData.icon)
        end

        if isMinimal then
            if control.name then
                control.name:SetHidden(true)
            end
            if control.posNum then
                control.posNum:SetHidden(true)
            end
            if control.priority then
                control.priority:SetHidden(true)
            end
        else
            local displayText
            if displayMode == "compact" then
                displayText = synergyData.name
            else
                -- "multi": prefer the game's prompt string; if empty, build a short action string
                displayText = synergyData.prompt
                if displayText == "" then
                    displayText = zo_strformat(SI_USE_SYNERGY, synergyData.name)
                end
            end

            if control.name then
                control.name:SetHidden(false)
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
    local totalToShow = zo_max(numSynergies, cooldownCount)
    self.control:SetHidden(totalToShow == 0)

    if isMinimal then
        if displayCount > 0 then
            self:ApplyRowLayout(displayMode, displayCount)
        end
        self:ApplyContainerDimensions(displayMode, displayCount)
    else
        self:ApplyRowLayout(displayMode, MAX_SYNERGY_SLOTS)
        self:ApplyContainerDimensions(displayMode, 0)
    end

    self:UpdateUnlockInteraction()
    self:UpdateCooldownDisplay()
    self:ApplyDisplayAlpha()
end

--- Update cooldown timer displays (called every second via OnUpdate throttle)
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
            local remaining = cooldownData.duration - (currentTime - cooldownData.startTime)

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
                    control.cooldownText:SetText(string_format("%d", zo_ceil(remaining / 1000)))
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

--- Apply a cooldown for abilityId (and any synergies sharing its cooldown group)
--- @param abilityId integer Synergy ability ID that triggered the cooldown
function SynergyTracker:ApplyCooldown(abilityId)
    local Settings = CombatInfo.SV.synergy
    if not Settings.showCooldowns then
        return
    end

    local duration = GetAbilityCooldown(abilityId, "player")
    if not duration or duration == 0 then
        return
    end

    local now = GetGameTimeMilliseconds()
    for _, groupId in ipairs(self:GetSharedCooldownGroup(abilityId)) do
        local data = Settings.detectedSynergies[groupId]
        if data and not Settings.blacklist[groupId] then
            self.synergyCooldowns[groupId] =
            {
                startTime = now,
                duration = duration,
            }
        end
    end

    self:UpdateDisplay()
end

--- Synergy was removed (activated, timed out, or source destroyed)
--- @param abilityId integer Synergy ability ID
--- @param data table Synergy data
function SynergyTracker:OnSynergyRemoved(abilityId, data)
    local Settings = CombatInfo.SV.synergy

    if Settings.detectedSynergies[abilityId] then
        Settings.detectedSynergies[abilityId].timesSeen = (Settings.detectedSynergies[abilityId].timesSeen or 0) + 1
    end

    self:ApplyCooldown(abilityId)
end

--- Event: Synergy ability changed (primary event)
function SynergyTracker:OnSynergyAbilityChanged()
    self:RefreshActiveSynergies()
end

--- Event: Player dead — clear all runtime state
function SynergyTracker:OnPlayerDead()
    ZO_ClearTable(self.activeSynergies)
    ZO_ClearTable(self.synergyCooldowns)
    self:UpdateDisplay()
end

--- Event: Effect changed on player (immediate cooldown detection)
--- @param changeType EffectResult
--- @param abilityId integer
function SynergyTracker:OnEffectChanged(changeType, abilityId)
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
        self:ApplyCooldown(abilityId)
    elseif changeType == EFFECT_RESULT_GAINED then
        self.synergyCooldowns[abilityId] = nil
        self:UpdateDisplay()
    end
end

--- Event: Combat event (synergy activation detection, player source only)
--- @param result ActionResult
--- @param abilityId integer
function SynergyTracker:OnCombatEvent(result, abilityId)
    local Settings = CombatInfo.SV.synergy

    if Settings.detectedSynergies[abilityId] and not Settings.blacklist[abilityId] then
        if result > 0 and result < 2000 then
            self:ApplyCooldown(abilityId)
        end
    end
end

--- Get shared cooldown group for a synergy
--- @param abilityId integer Synergy ability ID
--- @return integer[] Group of synergy IDs that share cooldowns
function SynergyTracker:GetSharedCooldownGroup(abilityId)
    return HARDCODED_SHARED_COOLDOWNS[abilityId] or { abilityId }
end

--- Apply saved position (center offset from GuiRoot)
function SynergyTracker:ApplyPosition()
    local Settings = CombatInfo.SV.synergy
    local x = (Settings.offsetX ~= nil) and Settings.offsetX or 0
    local y = (Settings.offsetY ~= nil) and Settings.offsetY or 200
    self.control:ClearAnchors()
    self.control:SetAnchor(CENTER, GuiRoot, CENTER, x, y)
end

--- Set tracker opacity from in-combat / out-of-combat saved values (0–100, like unit frames)
function SynergyTracker:ApplyDisplayAlpha()
    if not self.control then
        return
    end

    local Settings = CombatInfo.SV.synergy
    local oocAlpha = Settings.oocAlpha or 100
    local incAlpha = Settings.incAlpha or 100
    local inCombat = IsUnitInCombat("player")
    self.control:SetAlpha(0.01 * (inCombat and incAlpha or oocAlpha))
end

--- Unlock/lock UI for positioning
--- @param unlocked boolean Whether to unlock the UI
function SynergyTracker:SetUnlocked(unlocked)
    local Settings = CombatInfo.SV.synergy
    Settings.unlocked = unlocked

    if ZO_IsConsoleOrGameCoreUI() then
        local settingsScene = sceneManager:GetScene("LibHarvensAddonSettingsScene")
        if self.settingsSceneFragment then
            if unlocked then
                settingsScene:AddFragment(self.settingsSceneFragment)
            else
                settingsScene:RemoveFragment(self.settingsSceneFragment)
            end
        end
    end

    self.control:SetMovable(unlocked)
    self.control:SetMouseEnabled(unlocked)
    self:UpdateUnlockInteraction()

    if unlocked then
        self:ShowPreview()
    else
        local currentScene = sceneManager:GetCurrentScene()
        local isInHUDScene = currentScene == sceneManager:GetScene(HUD_SCENE) or currentScene == sceneManager:GetScene(HUDUI_SCENE)
        if not isInHUDScene or currentScene:GetState() ~= SCENE_SHOWN then
            self.control:SetHidden(true)
        else
            self:UpdateDisplay()
        end
    end
end

--- Show preview synergies for positioning (shows PREVIEW_ROW_COUNT rows with placeholder data)
function SynergyTracker:ShowPreview()
    local Settings = CombatInfo.SV.synergy
    local layoutMode = Settings.displayMode
    if layoutMode == "hidden" then
        layoutMode = "multi"
    end
    local isMinimal = layoutMode == "minimal"
    local previewCount = PREVIEW_ROW_COUNT
    if isMinimal then
        previewCount = zo_min(Settings.maxDisplay or MAX_SYNERGY_SLOTS, MAX_SYNERGY_SLOTS)
    end
    self:ApplyRowLayout(layoutMode, previewCount)

    for i = 1, previewCount do
        local control = self.synergyControls[i]
        if control then
            if control.icon then
                control.icon:SetTexture("esoui/art/icons/ability_undaunted_001.dds")
            end
            if control.name then
                if isMinimal then
                    control.name:SetHidden(true)
                else
                    control.name:SetHidden(false)
                    control.name:SetText(string_format("Preview Synergy %d", i))
                    control.name:SetColor(1, 1, 1, 1)
                end
            end
            if control.posNum then
                control.posNum:SetHidden(isMinimal or not Settings.showKeybinds)
            end
            if control.priority then
                if isMinimal then
                    control.priority:SetHidden(true)
                else
                    control.priority:SetText(string_format("P%d", i))
                    control.priority:SetHidden(not Settings.showPriority)
                end
            end
            if control.icon then
                control.icon:SetDesaturation(0)
            end
            control.row:SetHidden(false)
        end
    end

    for i = previewCount + 1, MAX_SYNERGY_SLOTS do
        local control = self.synergyControls[i]
        if control then
            control.row:SetHidden(true)
        end
    end

    if isMinimal then
        self:ApplyRowLayout(layoutMode, previewCount)
        self:ApplyContainerDimensions(layoutMode, previewCount)
    end

    self:UpdateUnlockInteraction()
    self:ApplyDisplayAlpha()
    self.control:SetHidden(false)
end

--- Reset position to default
function SynergyTracker:ResetPosition()
    local Settings = CombatInfo.SV.synergy
    Settings.offsetX = 0
    Settings.offsetY = 200
    self:ApplyPosition()
end

--- Update display options (keybinds, priority visibility)
function SynergyTracker:UpdateDisplayOptions()
    local Settings = CombatInfo.SV.synergy
    local displayMode = Settings.displayMode

    if displayMode ~= "minimal" and displayMode ~= "hidden" then
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
    end

    self:UpdateDisplay()
end

--- Right-click context menu on a synergy row (priority override and blacklist)
--- @param control Control
--- @param button integer
--- @param upInside boolean
--- @param slotIndex integer
function SynergyTracker:OnSynergyRowMouseUp(control, button, upInside, slotIndex)
    if not upInside or button ~= MOUSE_BUTTON_INDEX_RIGHT then
        return
    end

    local Settings = CombatInfo.SV.synergy
    if Settings.unlocked then
        return
    end

    local slotControl = self.synergyControls[slotIndex]
    local abilityId = slotControl and slotControl.abilityId
    if not abilityId or abilityId <= 0 then
        return
    end

    ClearMenu()

    local abilityName = zo_strformat(SI_ABILITY_NAME, GetAbilityName(abilityId))
    AddMenuItem(abilityName, function () end, MENU_ADD_OPTION_LABEL)

    local currentOverride = Settings.priorityOverrides[abilityId]
    local isBlacklisted = Settings.blacklist[abilityId] == true

    AddMenuItem("Priority: Game Default", function ()
        self:SetPriorityOverride(abilityId, nil)
    end, nil, nil, nil, nil, nil, nil, currentOverride == nil)

    for priority = 1, 10 do
        local menuPriority = priority
        AddMenuItem(string_format("Priority: %d", menuPriority), function ()
            self:SetPriorityOverride(abilityId, menuPriority)
        end, nil, nil, nil, nil, nil, nil, currentOverride == menuPriority)
    end

    AddMenuItem(isBlacklisted and "Remove from Blacklist" or "Add to Blacklist", function ()
        self:SetSynergyBlacklisted(abilityId, not isBlacklisted)
    end)

    ShowMenu(control)
end

--- Set whether a synergy is blacklisted (hidden from the tracker)
--- @param abilityId integer
--- @param blacklisted boolean
function SynergyTracker:SetSynergyBlacklisted(abilityId, blacklisted)
    local Settings = CombatInfo.SV.synergy
    Settings.blacklist[abilityId] = blacklisted and true or nil
    self:RefreshActiveSynergies()
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

    local tracker = SynergyTracker:New()
    CombatInfo.SynergyTrackerInstance = tracker
    return tracker
end
