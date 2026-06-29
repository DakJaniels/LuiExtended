-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
-- InfoPanel namespace
--- @class (partial) LUIE.InfoPanel
local InfoPanel = {}
InfoPanel.__index = InfoPanel
--- @class (partial) LUIE.InfoPanel
LUIE.InfoPanel = InfoPanel

local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER

local pairs = pairs
local string_format = string.format
local collectgarbage = collectgarbage

local moduleName = LUIE.name .. "InfoPanel"

--- Clock refresh when ClockFormat includes xy (milliseconds).
local INFO_PANEL_CLOCK_INTERVAL_MS_PRECISE = 33
local INFO_PANEL_CLOCK_INTERVAL_MS_STANDARD = ZO_ONE_SECOND_IN_MILLISECONDS

local function InfoPanelClockFormatUsesMilliseconds(clockFormat)
    return type(clockFormat) == "string" and zo_strfind(clockFormat, "xy", 1, true) ~= nil
end

local colors =
{
    RED = { r = 1, g = 0, b = 0 },
    GREEN = { r = 0, g = 1, b = 0 },
    BLUE = { r = 0, g = 0, b = 1 },
    YELLOW = { r = 1, g = 1, b = 0 },
    WHITE = { r = 1, g = 1, b = 1 },
    BLACK = { r = 0, g = 0, b = 0 },
    GRAY = { r = 0.5, g = 0.5, b = 0.5 },
    GOLD = { r = 0.85, g = 0.7, b = 0.1 },
}

-- local fakeControl   = {}

InfoPanel.Enabled = false
InfoPanel.Defaults =
{
    ClockFormat = "HH:m:s",
    panelScale = 100,
    HideGold = true,
    FontFace = "LUIE Default Font",
    FontSize = 16,
    FontStyle = FONT_STYLE_SOFT_SHADOW_THIN,
    transparency = 100,
    HideInCombat = false,
    HideMemory = false,
}
InfoPanel.SV = {}
InfoPanel.panelUnlocked = false

local combatFadeUpdateName = moduleName .. "CombatFade"

local COMBAT_FADE_DURATION = 0.25 -- seconds
local panelHiddenByCombat = false -- true after we hid the panel for combat; so we only fade-in when showing after combat
local MAX_FRAMERATE = 999

-- UI elements
local g_infoPanelFont = nil -- This will be initialized when settings are loaded

--- @type TopLevelWindow
local uiPanel = nil
--- @type Control
local uiTopRow = nil
--- @type Control
local uiBotRow = nil
local uiClock = {}
local uiGems = {}
local uiGold = {}

-- Add info panel into LUIE namespace
InfoPanel.Panel = uiPanel

local uiLatency =
{
    color =
    {
        [1] = { ping = 100, color = colors.GREEN },
        [2] = { ping = 200, color = colors.YELLOW },
        [3] = { color = colors.RED },
    },
}

local uiFps =
{
    color =
    {
        [1] = { fps = 25, color = colors.RED },
        [2] = { fps = 40, color = colors.YELLOW },
        [3] = { color = colors.GREEN },
    },
}

local uiMemory =
{
    color =
    {
        [1] = { fill = 70, color = colors.GREEN },
        [2] = { fill = 90, color = colors.YELLOW },
        [3] = { color = colors.RED },
    },
}

local uiFeedTimer =
{
    hideLocally = false,
}

local uiArmour =
{
    color =
    {
        [1] = { dura = 25, color = colors.RED, iconcolor = colors.WHITE },
        [2] = { dura = 50, color = colors.YELLOW, iconcolor = colors.WHITE },
        [3] = { color = colors.GREEN, iconcolor = colors.WHITE },
    },
}

local uiWeapons =
{
    color =
    {
        [1] = { charges = 10, color = colors.RED },
        [2] = { charges = 25, color = colors.YELLOW },
        [3] = { color = colors.WHITE },
    },
}

local uiBags =
{
    color =
    {
        [1] = { fill = 70, color = colors.WHITE },
        [2] = { fill = 90, color = colors.YELLOW },
        [3] = { color = colors.RED },
    },
}

local panelFragment

--- @type ZO_OrderedRefreshGroup|nil
local infoPanelRefreshGroup = nil

local INFO_PANEL_REFRESH_DIRTY_FULL = "Full"
local INFO_PANEL_REFRESH_DIRTY_LAYOUT = "Layout"

local function FormatInfoPanelMemoryText()
    if ZO_IsConsoleOrGameCoreUI() then
        local usage = GetTotalUserAddOnMemoryPoolUsageMB()
        local cap = GetTotalUserAddOnMemoryPoolCapacityMB()
        return string_format("%d/%d", zo_floor(usage + 0.5), cap), usage, cap
    end
    local mb = collectgarbage("count") / 1024
    local text = (mb >= 100) and string_format("%.0fM", mb) or string_format("%.1fM", mb)
    return text, mb, nil
end

-- -----------------------------------------------------------------------------
-- Meter system (ZOS-style component objects)
-- -----------------------------------------------------------------------------

local meters = {}
local metersOrdered = {}

function InfoPanel.GetMeter(id)
    return meters[id]
end

local function ForEachMeter(fn)
    for i = 1, #metersOrdered do
        fn(metersOrdered[i])
    end
end

local InfoPanelMeterBase = ZO_InitializingObject:Subclass()

function InfoPanelMeterBase:Initialize(infoPanel, id, intervalMs)
    self.infoPanel = infoPanel
    self.id = id
    self.intervalMs = intervalMs or 1000
    self.lastUpdateMs = nil
end

function InfoPanelMeterBase:SetInterval(intervalMs)
    self.intervalMs = intervalMs
end

function InfoPanelMeterBase:GetInterval()
    return self.intervalMs or 1000
end

function InfoPanelMeterBase:MarkUpdated(nowMs)
    self.lastUpdateMs = nowMs
end

function InfoPanelMeterBase:ShouldUpdate(nowMs)
    if self.lastUpdateMs == nil then
        return true
    end
    return (nowMs - self.lastUpdateMs) >= self:GetInterval()
end

function InfoPanelMeterBase:IsEnabled()
    return true
end

function InfoPanelMeterBase:Update(nowMs)
    -- override
end

function InfoPanelMeterBase:ApplyFont(fontString)
    -- override
end

function InfoPanelMeterBase:GetUpdateEventName()
    return moduleName .. "Meter_" .. self.id
end

function InfoPanelMeterBase:UnregisterMeterUpdate()
    eventManager:UnregisterForUpdate(self:GetUpdateEventName())
end

function InfoPanelMeterBase:RegisterMeterUpdate()
    local updateName = self:GetUpdateEventName()
    eventManager:UnregisterForUpdate(updateName)
    local meter = self
    eventManager:RegisterForUpdate(updateName, meter:GetInterval(), function ()
        if not InfoPanel.Enabled or not uiPanel then
            return
        end
        if uiPanel:IsHidden() then
            return
        end
        if not meter:IsEnabled() then
            return
        end
        local nowMs = GetFrameTimeMilliseconds()
        if meter:ShouldUpdate(nowMs) then
            meter:Update(nowMs)
            meter:MarkUpdated(nowMs)
        end
    end)
end

-- -----------------------------------------------------------------------------
-- Meter implementations
-- -----------------------------------------------------------------------------

local INFO_PANEL_LABEL_PADDING = 6
local INFO_PANEL_CLOCK_LABEL_MIN_WIDTH = 60

--- @param label LabelControl
--- @param text string
--- @param minWidth number|nil
--- @return boolean layoutChanged
local function FitInfoPanelLabelToText(label, text, minWidth)
    if not label then
        return false
    end
    local labelWidth = label:GetStringWidth(text) + INFO_PANEL_LABEL_PADDING
    labelWidth = zo_max(minWidth or 0, labelWidth)
    if label.infoPanelLayoutWidth ~= labelWidth then
        label.infoPanelLayoutWidth = labelWidth
        label:SetWidth(labelWidth)
        return true
    end
    return false
end

--- @param control Control
--- @param icon TextureControl|nil
--- @param label LabelControl
--- @param text string
--- @param minLabelWidth number|nil
--- @param iconToLabelGap number|nil
--- @return boolean layoutChanged
local function FitInfoPanelIconLabelRow(control, icon, label, text, minLabelWidth, iconToLabelGap)
    if not control or not label then
        return false
    end
    local changed = FitInfoPanelLabelToText(label, text, minLabelWidth)
    local iconWidth = icon and icon:GetWidth() or 0
    local gap = iconToLabelGap or 0
    local totalWidth = iconWidth + gap + label:GetWidth()
    if control.infoPanelLayoutWidth ~= totalWidth then
        control.infoPanelLayoutWidth = totalWidth
        control:SetWidth(totalWidth)
        return true
    end
    return changed
end

--- @param control Control
--- @param label LabelControl|nil
local function ClearInfoPanelLayoutWidth(control, label)
    if control then
        control.infoPanelLayoutWidth = nil
    end
    if label then
        label.infoPanelLayoutWidth = nil
    end
end

function InfoPanel.ClearAllLayoutWidths()
    ClearInfoPanelLayoutWidth(uiLatency.control, uiLatency.label)
    ClearInfoPanelLayoutWidth(uiFps.control, uiFps.label)
    ClearInfoPanelLayoutWidth(uiMemory.control, uiMemory.label)
    ClearInfoPanelLayoutWidth(uiClock.control, uiClock.label)
    ClearInfoPanelLayoutWidth(uiGems.control, uiGems.label)
    ClearInfoPanelLayoutWidth(uiFeedTimer.control, uiFeedTimer.label)
    ClearInfoPanelLayoutWidth(uiArmour.control, uiArmour.label)
    ClearInfoPanelLayoutWidth(uiBags.control, uiBags.label)
    ClearInfoPanelLayoutWidth(uiGold.control, uiGold.label)
end

local ClockMeter = InfoPanelMeterBase:Subclass()

function ClockMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "Clock", INFO_PANEL_CLOCK_INTERVAL_MS_STANDARD)
    self:RefreshUpdateInterval()
end

function ClockMeter:RefreshUpdateInterval()
    local intervalMs = INFO_PANEL_CLOCK_INTERVAL_MS_STANDARD
    if self.infoPanel and self.infoPanel.SV and InfoPanelClockFormatUsesMilliseconds(self.infoPanel.SV.ClockFormat) then
        intervalMs = INFO_PANEL_CLOCK_INTERVAL_MS_PRECISE
    end
    self:SetInterval(intervalMs)
    self.lastUpdateMs = nil
    self.lastClockText = nil
    self:RegisterMeterUpdate()
end

function ClockMeter:IsEnabled()
    return not self.infoPanel.SV.HideClock
end

function ClockMeter:ApplyFont(fontString)
    if uiClock.label then
        uiClock.label:SetFont(fontString)
        ClearInfoPanelLayoutWidth(uiClock.control, uiClock.label)
        self.lastClockText = nil
    end
end

function ClockMeter:Update(nowMs)
    if not self:IsEnabled() or not uiClock.label then return end
    local timestring = GetTimeString()
    local clockFormat = self.infoPanel.SV.ClockFormat
    local milliseconds
    if InfoPanelClockFormatUsesMilliseconds(clockFormat) then
        milliseconds = string_format("%03d", nowMs % 1000)
    end
    local clockText = LUIE.ChatOutput:CreateTimestamp(timestring, clockFormat, milliseconds)
    if clockText == self.lastClockText then
        return
    end
    self.lastClockText = clockText
    uiClock.label:SetText(clockText)
    if FitInfoPanelLabelToText(uiClock.label, clockText, INFO_PANEL_CLOCK_LABEL_MIN_WIDTH) then
        if uiClock.control then
            uiClock.control.infoPanelLayoutWidth = nil
            uiClock.control:SetWidth(uiClock.label:GetWidth())
            uiClock.control.infoPanelLayoutWidth = uiClock.control:GetWidth()
        end
        self.infoPanel.RearrangePanel()
    end
end

local FpsMeter = InfoPanelMeterBase:Subclass()

function FpsMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "FPS", ZO_ONE_SECOND_IN_MILLISECONDS)
end

function FpsMeter:IsEnabled()
    return not self.infoPanel.SV.HideFPS
end

function FpsMeter:ApplyFont(fontString)
    if uiFps.label then uiFps.label:SetFont(fontString) end
end

function FpsMeter:Update(nowMs)
    if not self:IsEnabled() or not uiFps.label then return end
    local framerate = GetFramerate()
    if framerate > MAX_FRAMERATE then
        framerate = MAX_FRAMERATE
    end
    local fps = zo_round(framerate)
    local color = colors.WHITE
    if not self.infoPanel.SV.DisableInfoColours then
        color = uiFps.color[#uiFps.color].color
        for i = 1, #uiFps.color - 1 do
            if fps < uiFps.color[i].fps then
                color = uiFps.color[i].color
                break
            end
        end
    end
    local fpsText = zo_strformat(GetString(LUIE_STRING_PNL_FPS_FORMAT), fps)
    uiFps.label:SetText(fpsText)
    uiFps.label:SetColor(color.r, color.g, color.b, 1)
    if FitInfoPanelLabelToText(uiFps.label, fpsText, 48) then
        self.infoPanel.RearrangePanel()
    end
end

local MemoryMeter = InfoPanelMeterBase:Subclass()

function MemoryMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "Memory", ZO_ONE_SECOND_IN_MILLISECONDS)
end

function MemoryMeter:IsEnabled()
    if self.infoPanel.SV.HideMemory then
        return false
    end
    if ZO_IsConsoleOrGameCoreUI() then
        return GetTotalUserAddOnMemoryPoolCapacityMB() > 0
    end
    return true
end

function MemoryMeter:ApplyFont(fontString)
    if uiMemory.label then uiMemory.label:SetFont(fontString) end
end

function MemoryMeter:Update(nowMs)
    if not self:IsEnabled() or not uiMemory.label then return end
    local text, usage, cap = FormatInfoPanelMemoryText()
    uiMemory.label:SetText(text)
    if FitInfoPanelLabelToText(uiMemory.label, text, 44) then
        self.infoPanel.RearrangePanel()
    end

    local color = colors.WHITE
    if not self.infoPanel.SV.DisableInfoColours then
        if cap and cap > 0 then
            local filledSlotPercentage = (usage / cap) * 100
            color = uiMemory.color[#uiMemory.color].color
            for i = 1, #uiMemory.color - 1 do
                if filledSlotPercentage < uiMemory.color[i].fill then
                    color = uiMemory.color[i].color
                    break
                end
            end
        end
    end
    uiMemory.label:SetColor(color.r, color.g, color.b, 1)
end

local LatencyMeter = InfoPanelMeterBase:Subclass()

function LatencyMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "Latency", ZO_ONE_SECOND_IN_MILLISECONDS * 10)
end

function LatencyMeter:IsEnabled()
    return not self.infoPanel.SV.HideLatency
end

function LatencyMeter:ApplyFont(fontString)
    if uiLatency.label then uiLatency.label:SetFont(fontString) end
end

function LatencyMeter:Update(nowMs)
    if not self:IsEnabled() or not uiLatency.label then return end
    local lat = GetLatency()
    local color = colors.WHITE
    if not self.infoPanel.SV.DisableInfoColours then
        color = uiLatency.color[#uiLatency.color].color
        for i = 1, #uiLatency.color - 1 do
            if lat < uiLatency.color[i].ping then
                color = uiLatency.color[i].color
                break
            end
        end
    end
    local latText = zo_strformat(GetString(LUIE_STRING_PNL_LATENCY_MS_FORMAT), lat)
    uiLatency.label:SetText(latText)
    uiLatency.label:SetColor(color.r, color.g, color.b, 1)
    if FitInfoPanelIconLabelRow(uiLatency.control, uiLatency.icon, uiLatency.label, latText, 44, 0) then
        self.infoPanel.RearrangePanel()
    end
end

local SoulGemsMeter = InfoPanelMeterBase:Subclass()

function SoulGemsMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "SoulGems", ZO_ONE_MINUTE_IN_MILLISECONDS)
end

function SoulGemsMeter:IsEnabled()
    return not self.infoPanel.SV.HideGems
end

function SoulGemsMeter:ApplyFont(fontString)
    if uiGems.label then uiGems.label:SetFont(fontString) end
end

function SoulGemsMeter:Update(nowMs)
    if not self:IsEnabled() or not uiGems.label or not uiGems.icon then return end
    local myLevel = GetUnitEffectiveLevel("player")
    local _, icon, emptyCount = GetSoulGemInfo(SOUL_GEM_TYPE_EMPTY, myLevel, true)
    local _, iconF, fullCount = GetSoulGemInfo(SOUL_GEM_TYPE_FILLED, myLevel, true)
    emptyCount = zo_min(emptyCount, 99)
    fullCount = zo_min(fullCount, 9999)
    local fullText = (fullCount > 0) and ("|c00FF00" .. fullCount .. "|r") or "|cFF00000|r"
    if iconF ~= nil and iconF ~= "" and iconF ~= "/esoui/art/icons/icon_missing.dds" then
        icon = iconF
    end
    if icon == "/esoui/art/icons/icon_missing.dds" then
        icon = "/esoui/art/icons/soulgem_001_empty.dds"
    end
    uiGems.icon:SetTexture(icon)
    local gemsText = (fullCount > 9) and fullText or (fullText .. "/" .. emptyCount)
    uiGems.label:SetText(gemsText)
    if FitInfoPanelIconLabelRow(uiGems.control, uiGems.icon, uiGems.label, gemsText, 24, 2) then
        self.infoPanel.RearrangePanel()
    end
end

local BagsMeter = InfoPanelMeterBase:Subclass()

function BagsMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "Bags", ZO_ONE_MINUTE_IN_MILLISECONDS)
end

function BagsMeter:IsEnabled()
    return not self.infoPanel.SV.HideBags
end

function BagsMeter:ApplyFont(fontString)
    if uiBags.label then uiBags.label:SetFont(fontString) end
end

function BagsMeter:UpdateWithCapacity(bagSize)
    if not self:IsEnabled() or not uiBags.label then return end
    local bagUsed = GetNumBagUsedSlots(BAG_BACKPACK)
    local filledSlotPercentage = (bagUsed / bagSize) * 100
    local color = uiBags.color[#uiBags.color].color
    if bagSize - bagUsed > 10 then
        for i = 1, #uiBags.color - 1 do
            if filledSlotPercentage < uiBags.color[i].fill then
                color = uiBags.color[i].color
                break
            end
        end
    end
    local bagsText = ZO_FormatFraction(bagUsed, bagSize)
    uiBags.label:SetText(bagsText)
    uiBags.label:SetColor(color.r, color.g, color.b, 1)
    if FitInfoPanelIconLabelRow(uiBags.control, uiBags.icon, uiBags.label, bagsText, 48, 0) then
        self.infoPanel.RearrangePanel()
    end
end

function BagsMeter:Update(nowMs)
    if not self:IsEnabled() then return end
    self:UpdateWithCapacity(GetBagSize(BAG_BACKPACK))
end

local ArmourMeter = InfoPanelMeterBase:Subclass()

function ArmourMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "Armour", ZO_ONE_MINUTE_IN_MILLISECONDS)
end

function ArmourMeter:IsEnabled()
    return not self.infoPanel.SV.HideArmour
end

function ArmourMeter:ApplyFont(fontString)
    if uiArmour.label then uiArmour.label:SetFont(fontString) end
end

function ArmourMeter:Update(nowMs)
    if not self:IsEnabled() or not uiArmour.label or not uiArmour.icon then return end
    local slotCount = 0
    local duraSum = 0
    local totalSlots = GetBagSize(BAG_WORN)
    for slotNum = 0, totalSlots - 1 do
        if DoesItemHaveDurability(BAG_WORN, slotNum) == true then
            duraSum = duraSum + GetItemCondition(BAG_WORN, slotNum)
            slotCount = slotCount + 1
        end
    end
    local duraPercentage = (slotCount == 0) and 0 or duraSum / slotCount
    local color = uiArmour.color[#uiArmour.color].color
    local iconcolor = uiArmour.color[#uiArmour.color].iconcolor
    for i = 1, #uiArmour.color - 1 do
        if duraPercentage < uiArmour.color[i].dura then
            color = uiArmour.color[i].color
            iconcolor = uiArmour.color[i].iconcolor
            break
        end
    end
    local armourText = string_format("%d%%", duraPercentage)
    uiArmour.label:SetText(armourText)
    uiArmour.label:SetColor(color.r, color.g, color.b, 1)
    uiArmour.icon:SetColor(iconcolor.r, iconcolor.g, iconcolor.b, 1)
    if FitInfoPanelIconLabelRow(uiArmour.control, uiArmour.icon, uiArmour.label, armourText, 32, 0) then
        self.infoPanel.RearrangePanel()
    end
end

local WeaponChargesMeter = InfoPanelMeterBase:Subclass()

function WeaponChargesMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "WeaponCharges", ZO_ONE_MINUTE_IN_MILLISECONDS)
end

function WeaponChargesMeter:IsEnabled()
    return not self.infoPanel.SV.HideWeapons
end

function WeaponChargesMeter:Update(nowMs)
    if not self:IsEnabled() or not uiWeapons.main or not uiWeapons.swap then return end
    for _, icon in pairs({ uiWeapons.main, uiWeapons.swap }) do
        local charges, maxCharges = GetChargeInfoForItem(BAG_WORN, icon.slotIndex)
        local color = colors.GRAY
        if maxCharges > 0 then
            color = uiWeapons.color[#uiWeapons.color].color
            local chargesPercentage = 100 * charges / maxCharges
            for i = 1, #uiWeapons.color - 1 do
                if chargesPercentage < uiWeapons.color[i].charges then
                    color = uiWeapons.color[i].color
                    break
                end
            end
        end
        icon:SetColor(color.r, color.g, color.b, 1)
    end
end

local GoldMeter = InfoPanelMeterBase:Subclass()

function GoldMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "Gold", ZO_ONE_MINUTE_IN_MILLISECONDS)
end

function GoldMeter:IsEnabled()
    return not self.infoPanel.SV.HideGold
end

function GoldMeter:ApplyFont(fontString)
    if uiGold.label then uiGold.label:SetFont(fontString) end
end

function GoldMeter:Update(nowMs)
    if not self:IsEnabled() or not uiGold.label then return end
    local goldText = ZO_CommaDelimitNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER))
    uiGold.label:SetText(goldText)
    uiGold.label:SetColor(colors.GOLD.r, colors.GOLD.g, colors.GOLD.b, 1)
    if FitInfoPanelIconLabelRow(uiGold.control, uiGold.icon, uiGold.label, goldText, 48, 2) then
        self.infoPanel.RearrangePanel()
    end
end

local MountFeedMeter = InfoPanelMeterBase:Subclass()

function MountFeedMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "MountFeed", ZO_ONE_MINUTE_IN_MILLISECONDS)
    self.hideLocally = false
end

function MountFeedMeter:IsEnabled()
    if self.hideLocally then
        return false
    end
    return not self.infoPanel.SV.HideMountFeed
end

function MountFeedMeter:ApplyFont(fontString)
    if uiFeedTimer.label then
        uiFeedTimer.label:SetFont(fontString)
        ClearInfoPanelLayoutWidth(uiFeedTimer.control, uiFeedTimer.label)
    end
end

function MountFeedMeter:ApplyFeedTimerLabel(text)
    if not uiFeedTimer.label then
        return
    end
    uiFeedTimer.label:SetText(text)
    if FitInfoPanelIconLabelRow(uiFeedTimer.control, uiFeedTimer.icon, uiFeedTimer.label, text, 48, 0) then
        self.infoPanel.RearrangePanel()
    end
end

function MountFeedMeter:SetHiddenLocally(hidden)
    if self.hideLocally == hidden then return end
    self.hideLocally = hidden
    uiFeedTimer.hideLocally = hidden
    self.infoPanel.RearrangePanel()
end

function MountFeedMeter:UpdateFromEvent(eventId, ridingSkillType, previous, current, source)
    if self.infoPanel.SV.HideMountFeed or not self.infoPanel.Enabled or not uiFeedTimer.label then
        return
    end

    if eventId == EVENT_RIDING_SKILL_IMPROVEMENT and ridingSkillType ~= nil and current ~= nil then
        local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
        local isFullyTrained = (inventoryBonus == maxInventoryBonus and staminaBonus == maxStaminaBonus and speedBonus == maxSpeedBonus)
        if isFullyTrained then
            self:ApplyFeedTimerLabel(GetString(LUIE_STRING_PNL_MAXED))
            self:SetHiddenLocally(true)
            return
        else
            local mountFeedTimer = GetTimeUntilCanBeTrained()
            if mountFeedTimer and mountFeedTimer > 0 then
                local hours = zo_floor(mountFeedTimer / ZO_ONE_HOUR_IN_MILLISECONDS)
                local minutes = zo_floor((mountFeedTimer - (hours * ZO_ONE_HOUR_IN_MILLISECONDS)) / ZO_ONE_MINUTE_IN_MILLISECONDS)
                self:ApplyFeedTimerLabel(string_format("%dh %dm", hours, minutes))
            else
                self:ApplyFeedTimerLabel(GetString(LUIE_STRING_PNL_TRAINNOW))
            end
            return
        end
    end

    self:Update(GetFrameTimeMilliseconds())
end

function MountFeedMeter:Update(nowMs)
    if self.infoPanel.SV.HideMountFeed or not self.infoPanel.Enabled or not uiFeedTimer.label then
        return
    end

    local mountFeedTimer = GetTimeUntilCanBeTrained()
    local mountFeedMessage = GetString(LUIE_STRING_PNL_MAXED)

    if mountFeedTimer ~= nil then
        if mountFeedTimer == 0 then
            local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
            if inventoryBonus ~= maxInventoryBonus or staminaBonus ~= maxStaminaBonus or speedBonus ~= maxSpeedBonus then
                mountFeedMessage = GetString(LUIE_STRING_PNL_TRAINNOW)
            else
                self:SetHiddenLocally(true)
                return
            end
        elseif mountFeedTimer > 0 then
            local hours = zo_floor(mountFeedTimer / ZO_ONE_HOUR_IN_MILLISECONDS)
            local minutes = zo_floor((mountFeedTimer - (hours * ZO_ONE_HOUR_IN_MILLISECONDS)) / ZO_ONE_MINUTE_IN_MILLISECONDS)
            mountFeedMessage = string_format("%dh %dm", hours, minutes)
        end
    end

    self:ApplyFeedTimerLabel(mountFeedMessage)
end

-- Build/replace the meter registry (called during Initialize)
function InfoPanel.RefreshClockMeterUpdateInterval()
    local clockMeter = InfoPanel.GetMeter("Clock")
    if clockMeter and clockMeter.RefreshUpdateInterval then
        clockMeter:RefreshUpdateInterval()
    end
end

function InfoPanel.BuildMeters()
    meters = {}
    metersOrdered = {}

    local function AddMeter(meter)
        meters[meter.id] = meter
        metersOrdered[#metersOrdered + 1] = meter
    end

    AddMeter(LatencyMeter:New(InfoPanel))
    AddMeter(FpsMeter:New(InfoPanel))
    AddMeter(MemoryMeter:New(InfoPanel))
    AddMeter(ClockMeter:New(InfoPanel))
    AddMeter(SoulGemsMeter:New(InfoPanel))
    AddMeter(MountFeedMeter:New(InfoPanel))
    AddMeter(ArmourMeter:New(InfoPanel))
    AddMeter(WeaponChargesMeter:New(InfoPanel))
    AddMeter(BagsMeter:New(InfoPanel))
    AddMeter(GoldMeter:New(InfoPanel))
end

--- @class InfoPanelLayoutEntry
--- @field meterId string
--- @field fallbackEnabled fun(): boolean
--- @field getControl fun(): Control|nil
--- @field onShow fun()|nil

--- @type InfoPanelLayoutEntry[]
local INFO_PANEL_TOP_ROW_LAYOUT =
{
    {
        meterId = "Latency",
        fallbackEnabled = function () return not InfoPanel.SV.HideLatency end,
        getControl = function () return uiLatency.control end,
    },
    {
        meterId = "FPS",
        fallbackEnabled = function () return not InfoPanel.SV.HideFPS end,
        getControl = function () return uiFps.control end,
    },
    {
        meterId = "Memory",
        fallbackEnabled = function () return not InfoPanel.SV.HideMemory end,
        getControl = function () return uiMemory.control end,
    },
    {
        meterId = "Clock",
        fallbackEnabled = function () return not InfoPanel.SV.HideClock end,
        getControl = function () return uiClock.control end,
    },
    {
        meterId = "SoulGems",
        fallbackEnabled = function () return not InfoPanel.SV.HideGems end,
        getControl = function () return uiGems.control end,
    },
}

--- @type InfoPanelLayoutEntry[]
local INFO_PANEL_BOTTOM_ROW_LAYOUT =
{
    {
        meterId = "MountFeed",
        fallbackEnabled = function () return not InfoPanel.SV.HideMountFeed end,
        getControl = function () return uiFeedTimer.control end,
    },
    {
        meterId = "Armour",
        fallbackEnabled = function () return not InfoPanel.SV.HideArmour end,
        getControl = function () return uiArmour.control end,
    },
    {
        meterId = "WeaponCharges",
        fallbackEnabled = function () return not InfoPanel.SV.HideWeapons end,
        getControl = function () return uiWeapons.control end,
    },
    {
        meterId = "Bags",
        fallbackEnabled = function () return not InfoPanel.SV.HideBags end,
        getControl = function () return uiBags.control end,
    },
    {
        meterId = "Gold",
        fallbackEnabled = function () return not InfoPanel.SV.HideGold end,
        getControl = function () return uiGold.control end,
        onShow = function () InfoPanel.UpdateGoldDisplay() end,
    },
}

--- @param id string
--- @param fallbackEnabled boolean
--- @return boolean
local function InfoPanelMeterEnabled(id, fallbackEnabled)
    local meter = InfoPanel.GetMeter(id)
    if meter and meter.IsEnabled then
        return meter:IsEnabled()
    end
    return fallbackEnabled
end

--- @param rowControl Control
--- @param entries InfoPanelLayoutEntry[]
--- @return number
local function LayoutInfoPanelRow(rowControl, entries)
    local anchorControl = nil
    local rowWidth = 0
    for i = 1, #entries do
        local entry = entries[i]
        local control = entry.getControl()
        if control then
            if not InfoPanelMeterEnabled(entry.meterId, entry.fallbackEnabled()) then
                control:SetHidden(true)
                control:ClearAnchors()
            else
                control:ClearAnchors()
                control:SetAnchor(LEFT, anchorControl or rowControl, (anchorControl == nil) and LEFT or RIGHT, 0, 0)
                control:SetHidden(false)
                if entry.onShow then
                    entry.onShow()
                end
                rowWidth = rowWidth + control:GetWidth()
                anchorControl = control
            end
        end
    end
    rowControl:SetWidth((rowWidth > 0) and rowWidth or 10)
    return rowWidth
end

local function RefreshEnabledInfoPanelMetersForLayout()
    local nowMs = GetFrameTimeMilliseconds()
    ForEachMeter(function (meter)
        if meter:IsEnabled() then
            meter:Update(nowMs)
            meter:MarkUpdated(nowMs)
        end
    end)
end

local function ApplyInfoPanelDividerAnchors()
    local divider = uiPanel and uiPanel.div
    if not divider then
        return
    end
    divider:ClearAnchors()
    divider:SetAnchor(LEFT, uiPanel, LEFT, 0, 0)
    divider:SetAnchor(RIGHT, uiPanel, RIGHT, 0, 0)
end

local function PerformInfoPanelLayout()
    if not InfoPanel.Enabled or not uiPanel then
        return
    end

    uiPanel:SetTransformScale(1)

    local topWidth = LayoutInfoPanelRow(uiTopRow, INFO_PANEL_TOP_ROW_LAYOUT)
    local botWidth = LayoutInfoPanelRow(uiBotRow, INFO_PANEL_BOTTOM_ROW_LAYOUT)

    uiPanel:SetWidth(zo_max(topWidth, botWidth))
    ApplyInfoPanelDividerAnchors()
    InfoPanel.SetScale()
    InfoPanel.ApplyTransparency()
    if LUIE.MiniMap and LUIE.MiniMap.IsInfoPanelAnchorActive and LUIE.MiniMap.IsInfoPanelAnchorActive() then
        LUIE.MiniMap.ApplyInfoPanelAnchor()
    end
end

local function InfoPanelRefreshGroupIsActive()
    return InfoPanel.Enabled and uiPanel and not uiPanel:IsHidden()
end

local function InitializeInfoPanelRefreshGroup()
    local refreshGroup = ZO_OrderedRefreshGroup:New(ZO_ORDERED_REFRESH_GROUP_AUTO_CLEAN_PER_FRAME)
    refreshGroup:AddDirtyState(INFO_PANEL_REFRESH_DIRTY_FULL, function ()
        RefreshEnabledInfoPanelMetersForLayout()
        PerformInfoPanelLayout()
    end)
    refreshGroup:AddDirtyState(INFO_PANEL_REFRESH_DIRTY_LAYOUT, PerformInfoPanelLayout)
    refreshGroup:SetActive(InfoPanelRefreshGroupIsActive)
    infoPanelRefreshGroup = refreshGroup
end

function InfoPanel.RegisterAllMeterUpdates()
    ForEachMeter(function (meter)
        meter:RegisterMeterUpdate()
    end)
end

function InfoPanel.UnregisterAllMeterUpdates()
    ForEachMeter(function (meter)
        meter:UnregisterMeterUpdate()
    end)
end

-- Apply transparency to the info panel
function InfoPanel.ApplyTransparency()
    if not InfoPanel.Enabled or not uiPanel then
        return
    end

    local alpha = InfoPanel.SV.transparency / 100
    uiPanel:SetAlpha(alpha)
end

-- Apply font changes to the info panel elements
function InfoPanel.ApplyFont()
    if not InfoPanel.Enabled then
        return
    end

    -- Get font settings
    local fontStyle = InfoPanel.SV.FontStyle
    local fontSize = (InfoPanel.SV.FontSize and InfoPanel.SV.FontSize > 0) and InfoPanel.SV.FontSize or 16

    -- Create font string
    g_infoPanelFont = LUIE.Font.Resolve(InfoPanel.SV.FontFace, fontSize, fontStyle)

    -- Apply font to all elements
    InfoPanel.ClearAllLayoutWidths()
    ForEachMeter(function (meter)
        if meter.ApplyFont then
            meter:ApplyFont(g_infoPanelFont)
        end
    end)
    if InfoPanel.Enabled and uiPanel then
        InfoPanel.RearrangePanel(true)
    end
end

function InfoPanel.SetDisplayOnMap()
    if InfoPanel.SV.DisplayOnWorldMap then
        sceneManager:GetScene("worldMap"):AddFragment(panelFragment)
    else
        sceneManager:GetScene("worldMap"):RemoveFragment(panelFragment)
    end
end

-- Cancels any "show after delay" timer and combat fade update, then shows the panel. Uses manual fade-in when we had previously hidden it for combat; otherwise just show.
function InfoPanel.CancelCombatHideAndShow()
    eventManager:UnregisterForUpdate(combatFadeUpdateName)
    if not InfoPanel.Enabled or not uiPanel then
        return
    end
    if not panelHiddenByCombat then
        uiPanel:SetHidden(false)
        InfoPanel.ApplyTransparency()
        if infoPanelRefreshGroup then
            infoPanelRefreshGroup:TryClean()
        end
        return
    end
    panelHiddenByCombat = false
    local targetAlpha = (InfoPanel.SV.transparency and InfoPanel.SV.transparency / 100) or 1
    uiPanel:SetHidden(false)
    uiPanel:SetAlpha(0)
    if infoPanelRefreshGroup then
        infoPanelRefreshGroup:TryClean()
    end
    local startTime = GetFrameTimeMilliseconds()
    eventManager:RegisterForUpdate(combatFadeUpdateName, 16, function ()
        if not InfoPanel.Enabled or not uiPanel then
            eventManager:UnregisterForUpdate(combatFadeUpdateName)
            return
        end
        local elapsed = (GetFrameTimeMilliseconds() - startTime) / 1000
        if elapsed >= COMBAT_FADE_DURATION then
            eventManager:UnregisterForUpdate(combatFadeUpdateName)
            uiPanel:SetAlpha(targetAlpha)
            return
        end
        local a = targetAlpha * (elapsed / COMBAT_FADE_DURATION)
        uiPanel:SetAlpha(a)
    end)
end

-- Runs on EVENT_PLAYER_COMBAT_STATE. Fades out and hides when entering combat; fades in when leaving combat.
function InfoPanel.OnPlayerCombatState(inCombat)
    if not InfoPanel.Enabled or not uiPanel then
        return
    end
    if not InfoPanel.SV.HideInCombat then
        InfoPanel.CancelCombatHideAndShow()
        return
    end
    if inCombat then
        eventManager:UnregisterForUpdate(combatFadeUpdateName)
        uiPanel:SetHidden(false)
        local startAlpha = uiPanel:GetAlpha()
        if startAlpha <= 0 then
            uiPanel:SetHidden(true)
            panelHiddenByCombat = true
            return
        end
        local startTime = GetFrameTimeMilliseconds()
        eventManager:RegisterForUpdate(combatFadeUpdateName, 16, function ()
            if not InfoPanel.Enabled or not uiPanel then
                eventManager:UnregisterForUpdate(combatFadeUpdateName)
                return
            end
            local elapsed = (GetFrameTimeMilliseconds() - startTime) / 1000
            if elapsed >= COMBAT_FADE_DURATION then
                eventManager:UnregisterForUpdate(combatFadeUpdateName)
                uiPanel:SetAlpha(0)
                uiPanel:SetHidden(true)
                panelHiddenByCombat = true
                return
            end
            local a = startAlpha * (1 - elapsed / COMBAT_FADE_DURATION)
            uiPanel:SetAlpha(a)
        end)
    else
        InfoPanel.CancelCombatHideAndShow()
    end
end

--- Queues panel layout (coalesced per frame via ZO_OrderedRefreshGroup). Called from Initialize and settings menu.
--- @param refreshMeters boolean|nil When true, updates all enabled meters before layout (settings/init/font). Default false for layout-only reflows.
function InfoPanel.RearrangePanel(refreshMeters)
    if not InfoPanel.Enabled or not infoPanelRefreshGroup then
        return
    end

    if refreshMeters then
        infoPanelRefreshGroup:MarkDirty(INFO_PANEL_REFRESH_DIRTY_FULL)
    else
        infoPanelRefreshGroup:MarkDirty(INFO_PANEL_REFRESH_DIRTY_LAYOUT)
    end
end

function InfoPanel.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    if isCharacterSpecific then
        InfoPanel.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.InfoPanel, LUIE.SVVer, nil, InfoPanel.Defaults, LUIE.SavedVarsProfile)
    else
        InfoPanel.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.InfoPanel, LUIE.SVVer, nil, InfoPanel.Defaults, LUIE.SavedVarsProfile)
    end

    -- Migrate old string-based font styles to numeric constants (run once)
    -- Migrate font style (string/display/nil -> valid 0-7); run once per account
    if not LUIE.IsMigrationDone("infopanel_fontstyles_v2") then
        InfoPanel.SV.FontStyle = LUIE.MigrateFontStyle(InfoPanel.SV.FontStyle)
        LUIE.MarkMigrationDone("infopanel_fontstyles_v2")
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    InfoPanel.Enabled = true

    -- Reference XML-created controls
    uiPanel = LUIE_InfoPanel
    InfoPanel.Panel = uiPanel

    panelFragment = ZO_HUDFadeSceneFragment:New(uiPanel, 0, 0)

    sceneManager:GetScene("hud"):AddFragment(panelFragment)
    sceneManager:GetScene("hudui"):AddFragment(panelFragment)
    sceneManager:GetScene("siegeBar"):AddFragment(panelFragment)
    sceneManager:GetScene("siegeBarUI"):AddFragment(panelFragment)

    InfoPanel.SetDisplayOnMap() -- Add to map scene if the option is enabled.

    uiPanel.div = LUIE_InfoPanel_Divider

    uiTopRow = LUIE_InfoPanel_TopRow
    uiBotRow = LUIE_InfoPanel_BotRow

    -- Create font string from settings
    local fontStyle = InfoPanel.SV.FontStyle
    local fontSize = (InfoPanel.SV.FontSize and InfoPanel.SV.FontSize > 0) and InfoPanel.SV.FontSize or 16
    g_infoPanelFont = LUIE.Font.Resolve(InfoPanel.SV.FontFace, fontSize, fontStyle)

    -- Top Row Controls
    uiLatency.control = LUIE_InfoPanel_TopRow_Latency
    uiLatency.icon = LUIE_InfoPanel_TopRow_Latency_Icon
    uiLatency.label = LUIE_InfoPanel_TopRow_Latency_Label

    uiFps.label = LUIE_InfoPanel_TopRow_Fps
    uiFps.control = uiFps.label

    uiMemory.label = LUIE_InfoPanel_TopRow_Memory
    uiMemory.control = uiMemory.label

    uiClock.label = LUIE_InfoPanel_TopRow_Clock
    uiClock.control = uiClock.label

    uiGems.control = LUIE_InfoPanel_TopRow_Gems
    uiGems.icon = LUIE_InfoPanel_TopRow_Gems_Icon
    uiGems.label = LUIE_InfoPanel_TopRow_Gems_Label

    -- Bottom Row Controls
    uiFeedTimer.control = LUIE_InfoPanel_BotRow_FeedTimer
    uiFeedTimer.icon = LUIE_InfoPanel_BotRow_FeedTimer_Icon
    uiFeedTimer.label = LUIE_InfoPanel_BotRow_FeedTimer_Label

    uiArmour.control = LUIE_InfoPanel_BotRow_Armour
    uiArmour.icon = LUIE_InfoPanel_BotRow_Armour_Icon
    uiArmour.label = LUIE_InfoPanel_BotRow_Armour_Label

    uiWeapons.control = LUIE_InfoPanel_BotRow_Weapons
    uiWeapons.main = LUIE_InfoPanel_BotRow_Weapons_Main
    uiWeapons.swap = LUIE_InfoPanel_BotRow_Weapons_Swap
    uiWeapons.main.slotIndex = EQUIP_SLOT_MAIN_HAND
    uiWeapons.swap.slotIndex = EQUIP_SLOT_BACKUP_MAIN

    uiBags.control = LUIE_InfoPanel_BotRow_Bags
    uiBags.icon = LUIE_InfoPanel_BotRow_Bags_Icon
    uiBags.label = LUIE_InfoPanel_BotRow_Bags_Label

    -- Gold display
    uiGold.control = LUIE_InfoPanel_BotRow_Gold
    uiGold.icon = LUIE_InfoPanel_BotRow_Gold_Icon
    uiGold.icon:SetTexture(ZO_Currency_GetKeyboardCurrencyIcon(CURT_MONEY))
    uiGold.label = LUIE_InfoPanel_BotRow_Gold_Label
    uiGold.label:SetText(ZO_CommaDelimitNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)))
    uiGold.label:SetColor(colors.GOLD.r, colors.GOLD.g, colors.GOLD.b, 1)

    -- Build meter registry now that controls exist
    InfoPanel.BuildMeters()
    InfoPanel.RefreshClockMeterUpdateInterval()
    InitializeInfoPanelRefreshGroup()

    -- add control to global list so it can be hidden
    LUIE.Components[moduleName] = uiPanel

    -- Panel position - only set if user has saved a custom position
    InfoPanel.ApplyPanelPosition()

    -- Apply font settings
    InfoPanel.ApplyFont()

    -- Set init values (run once immediately, independent of visibility)
    local nowMs = GetFrameTimeMilliseconds()
    ForEachMeter(function (meter)
        meter:Update(nowMs)
        meter:MarkUpdated(nowMs)
    end)

    InfoPanel.RearrangePanel()

    -- Set event handlers
    -- * EVENT_LOOT_RECEIVED (*string* _receivedBy_, *string* _itemName_, *integer* _quantity_, *[ItemUISoundCategory|#ItemUISoundCategory]* _soundCategory_, *[LootItemType|#LootItemType]* _lootType_, *bool* _self_, *bool* _isPickpocketLoot_, *string* _questItemIcon_, *integer* _itemId_, *bool* _isStolen_)
    eventManager:RegisterForEvent(moduleName, EVENT_LOOT_RECEIVED, function () InfoPanel.OnBagUpdate() end)
    -- * EVENT_INVENTORY_SINGLE_SLOT_UPDATE (*[Bag|#Bag]* _bagId_, *integer* _slotIndex_, *bool* _isNewItem_, *[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_, *integer* _inventoryUpdateReason_, *integer* _stackCountChange_, *string:nilable* _triggeredByCharacterName_, *string:nilable* _triggeredByDisplayName_, *bool* _isLastUpdateForMessage_, *[BonusDropSource|#BonusDropSource]* _bonusDropSource_)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function () InfoPanel.OnBagUpdate() end)
    -- * EVENT_INVENTORY_ITEM_DESTROYED (*[ItemUISoundCategory|#ItemUISoundCategory]* _itemSoundCategory_)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_DESTROYED, function () InfoPanel.OnBagUpdate() end)
    -- * EVENT_INVENTORY_FULL_UPDATE
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_FULL_UPDATE, function () InfoPanel.OnBagUpdate() end)
    -- * EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG, function () InfoPanel.OnBagUpdate() end)
    -- * EVENT_INVENTORY_BAG_CAPACITY_CHANGED (*integer* _previousCapacity_, *integer* _currentCapacity_, *integer* _previousUpgrade_, *integer* _currentUpgrade_)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, InfoPanel.OnBagCapacityChanged)
    -- * EVENT_CARRIED_CURRENCY_UPDATE (*[CurrencyType|#CurrencyType]* _currency_, *integer* _newValue_, *integer* _oldValue_, *[CurrencyChangeReason|#CurrencyChangeReason]* _reason_, *integer* _reasonSupplementaryInfo_)
    eventManager:RegisterForEvent(moduleName, EVENT_CARRIED_CURRENCY_UPDATE, InfoPanel.OnCurrencyUpdate)
    -- * EVENT_RIDING_SKILL_IMPROVEMENT (*[RidingTrainType|#RidingTrainType]* _ridingSkillType_, *integer* _previous_, *integer* _current_, *[RidingTrainSource|#RidingTrainSource]* _source_)
    eventManager:RegisterForEvent(moduleName, EVENT_RIDING_SKILL_IMPROVEMENT, InfoPanel.UpdateMountFeedTimer)
    InfoPanel.RegisterAllMeterUpdates()

    -- Combat state: always register so enabling HideInCombat in settings later works. Handler checks HideInCombat.
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_COMBAT_STATE, function (eventId, inCombat)
        InfoPanel.OnPlayerCombatState(inCombat)
    end)
    if not InfoPanel.SV.HideInCombat then
        -- XML defaults to hidden="true"; show panel when option is off
        uiPanel:SetHidden(false)
        InfoPanel.ApplyTransparency()
    else
        -- Sync initial visibility when option is on (e.g. show panel if not in combat)
        InfoPanel.OnPlayerCombatState(IsUnitInCombat("player"))
    end

    if infoPanelRefreshGroup then
        infoPanelRefreshGroup:TryClean()
    end
end

-- Get current panel position (center X, Y). For console sliders.
function InfoPanel.GetPanelPosition()
    if InfoPanel.SV.position ~= nil and #InfoPanel.SV.position == 2 then
        return InfoPanel.SV.position[1], InfoPanel.SV.position[2]
    end
    if InfoPanel.Enabled and uiPanel and uiPanel.GetCenter then
        return uiPanel:GetCenter()
    end
    return 0, 0
end

-- Apply panel position from SV (center coords). Used by Initialize and console sliders.
function InfoPanel.ApplyPanelPosition()
    if not InfoPanel.Enabled or not uiPanel then
        return
    end
    if LUIE.MiniMap and LUIE.MiniMap.IsInfoPanelAnchorActive and LUIE.MiniMap.IsInfoPanelAnchorActive() then
        LUIE.MiniMap.ApplyInfoPanelAnchor()
        return
    end
    if InfoPanel.SV.position ~= nil and #InfoPanel.SV.position == 2 then
        uiPanel:ClearAnchors()
        uiPanel:SetAnchor(CENTER, GuiRoot, TOPLEFT, InfoPanel.SV.position[1], InfoPanel.SV.position[2])
    end
end

function InfoPanel.ResetPosition()
    InfoPanel.SV.position = nil
    if not InfoPanel.Enabled then
        return
    end
    if LUIE.MiniMap and LUIE.MiniMap.IsInfoPanelAnchorActive and LUIE.MiniMap.IsInfoPanelAnchorActive() then
        LUIE.MiniMap.ApplyInfoPanelAnchor()
        return
    end
    -- Clear anchors and let XML default anchor take over
    uiPanel:ClearAnchors()
    uiPanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24, 20)
end

-- Handler for OnMoveStop event (called from XML)
--- @param control Control
function InfoPanel.OnPanelMoveStop(control)
    if LUIE.MiniMap and LUIE.MiniMap.IsInfoPanelAnchorActive and LUIE.MiniMap.IsInfoPanelAnchorActive() then
        LUIE.MiniMap.ApplyInfoPanelAnchor()
        return
    end
    if InfoPanel.SV then
        InfoPanel.SV.position = { control:GetCenter() }
    end
end

-- Unlock panel for moving. Called from Settings Menu.
function InfoPanel.SetMovingState(state)
    if not InfoPanel.Enabled then
        return
    end
    if LUIE.MiniMap and LUIE.MiniMap.IsInfoPanelAnchorActive and LUIE.MiniMap.IsInfoPanelAnchorActive() then
        InfoPanel.panelUnlocked = false
        uiPanel:SetMouseEnabled(false)
        uiPanel:SetMovable(false)
        uiPanel:SetHidden(false)
        return
    end
    InfoPanel.panelUnlocked = state

    -- PC/Keyboard version
    uiPanel:SetMouseEnabled(state)
    uiPanel:SetMovable(state)
    uiPanel:SetHidden(false)
end

-- Set scale of Info Panel. Called from Settings Menu.
function InfoPanel.SetScale()
    if not InfoPanel.Enabled then
        return
    end
    uiPanel:SetTransformScale(InfoPanel.SV.panelScale and InfoPanel.SV.panelScale / 100 or 1)
end

-- Schedules a deferred bag/gems refresh for inventory-related events (signatures vary by eventId).
-- Registered: EVENT_LOOT_RECEIVED, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, EVENT_INVENTORY_ITEM_DESTROYED,
-- EVENT_INVENTORY_FULL_UPDATE, EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG.
--- @param eventId integer|nil
--- @param bagId number|nil
--- @param slotIndex number|nil
--- @param isNewItem boolean|nil
--- @param itemSoundCategory number|nil
--- @param updateReason number|nil
function InfoPanel.OnBagUpdate(eventId, bagId, slotIndex, isNewItem, itemSoundCategory, updateReason)
    -- We shall not execute bags size calculation immediately, but rather set a flag with delay function
    -- This is needed to avoid lockups when the game start flooding us with same event for every bag slot used
    -- While we do not need any good latency, we can afford to update info-panel label with 250ms delay
    eventManager:RegisterForUpdate(moduleName .. "PendingBagsUpdate", 250, InfoPanel.DoBagUpdate)
end

function InfoPanel.UpdateGoldDisplay()
    local meter = InfoPanel.GetMeter("Gold")
    if meter then
        local nowMs = GetFrameTimeMilliseconds()
        meter:Update(nowMs)
        meter:MarkUpdated(nowMs)
    end
end

-- Performs calculation of empty space in bags
-- Called with delay by corresponding event listener
function InfoPanel.DoBagUpdate()
    -- Clear pending event
    eventManager:UnregisterForUpdate(moduleName .. "PendingBagsUpdate")

    local nowMs = GetFrameTimeMilliseconds()
    local bagsMeter = InfoPanel.GetMeter("Bags")
    if bagsMeter then
        bagsMeter:Update(nowMs)
        bagsMeter:MarkUpdated(nowMs)
    end
    local gemsMeter = InfoPanel.GetMeter("SoulGems")
    if gemsMeter then
        gemsMeter:Update(nowMs)
        gemsMeter:MarkUpdated(nowMs)
    end
end

-- Update mount feed timer information
--- @param eventId integer|nil Optional - event ID if called from event
--- @param ridingSkillType RidingTrainType|nil Optional - riding skill type
--- @param previous integer|nil Optional - previous skill value
--- @param current integer|nil Optional - current skill value
--- @param source RidingTrainSource|nil Optional - source of the training
function InfoPanel.UpdateMountFeedTimer(eventId, ridingSkillType, previous, current, source)
    local meter = InfoPanel.GetMeter("MountFeed")
    if meter then
        meter:UpdateFromEvent(eventId, ridingSkillType, previous, current, source)
        meter:MarkUpdated(GetFrameTimeMilliseconds())
    end
end

-- Update bag capacity when it changes
--- @param eventId integer
--- @param previousCapacity integer
--- @param currentCapacity integer
--- @param previousUpgrade integer
--- @param currentUpgrade integer
function InfoPanel.OnBagCapacityChanged(eventId, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    local nowMs = GetFrameTimeMilliseconds()
    local meter = InfoPanel.GetMeter("Bags")
    if meter and meter.UpdateWithCapacity then
        meter:UpdateWithCapacity(currentCapacity)
        meter:MarkUpdated(nowMs)
    end
end

-- Update player's gold display
--- @param eventId integer
--- @param currency CurrencyType
--- @param newValue integer
--- @param oldValue integer
--- @param reason CurrencyChangeReason
--- @param reasonSupplementaryInfo integer
function InfoPanel.OnCurrencyUpdate(eventId, currency, newValue, oldValue, reason, reasonSupplementaryInfo)
    if not InfoPanel.Enabled or InfoPanel.SV.HideGold then
        return
    end

    -- Only update for gold currency
    if currency ~= CURT_MONEY then
        return
    end

    -- Display the current amount
    InfoPanel.UpdateGoldDisplay()
end
