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

local moduleName = LUIE.name .. "InfoPanel"

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
}
InfoPanel.SV = {}
InfoPanel.panelUnlocked = false

local combatFadeUpdateName = moduleName .. "CombatFade"

local COMBAT_FADE_DURATION = 0.25 -- seconds
local panelHiddenByCombat = false -- true after we hid the panel for combat; so we only fade-in when showing after combat

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

-- -----------------------------------------------------------------------------
-- Meter system (ZOS-style component objects)
-- -----------------------------------------------------------------------------

local updateDriverName = moduleName .. "UpdateDriver"
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

local InfoPanelMeterBase = ZO_Object:Subclass()

function InfoPanelMeterBase:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

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

-- -----------------------------------------------------------------------------
-- Meter implementations
-- -----------------------------------------------------------------------------

local ClockMeter = InfoPanelMeterBase:Subclass()

function ClockMeter:Initialize(infoPanel)
    InfoPanelMeterBase.Initialize(self, infoPanel, "Clock", ZO_ONE_SECOND_IN_MILLISECONDS)
end

function ClockMeter:IsEnabled()
    return not self.infoPanel.SV.HideClock
end

function ClockMeter:ApplyFont(fontString)
    if uiClock.label then uiClock.label:SetFont(fontString) end
end

function ClockMeter:Update(nowMs)
    if not self:IsEnabled() or not uiClock.label then return end
    local timestring = GetTimeString()
    uiClock.label:SetText(LUIE.CreateTimestamp(timestring, self.infoPanel.SV.ClockFormat))
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
    local fps = GetFramerate()
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
    uiFps.label:SetText(string_format("%d fps", fps))
    uiFps.label:SetColor(color.r, color.g, color.b, 1)
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
    uiLatency.label:SetText(string_format("%d ms", lat))
    uiLatency.label:SetColor(color.r, color.g, color.b, 1)
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
    uiGems.label:SetText((fullCount > 9) and fullText or (fullText .. "/" .. emptyCount))
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
    uiBags.label:SetText(ZO_FormatFraction(bagUsed, bagSize))
    uiBags.label:SetColor(color.r, color.g, color.b, 1)
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
    uiArmour.label:SetText(string_format("%d%%", duraPercentage))
    uiArmour.label:SetColor(color.r, color.g, color.b, 1)
    uiArmour.icon:SetColor(iconcolor.r, iconcolor.g, iconcolor.b, 1)
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
    uiGold.label:SetText(ZO_CommaDelimitNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)))
    uiGold.label:SetColor(colors.GOLD.r, colors.GOLD.g, colors.GOLD.b, 1)
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
    if uiFeedTimer.label then uiFeedTimer.label:SetFont(fontString) end
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
            uiFeedTimer.label:SetText(GetString(LUIE_STRING_PNL_MAXED))
            self:SetHiddenLocally(true)
            return
        else
            local mountFeedTimer = GetTimeUntilCanBeTrained()
            if mountFeedTimer and mountFeedTimer > 0 then
                local hours = zo_floor(mountFeedTimer / ZO_ONE_HOUR_IN_MILLISECONDS)
                local minutes = zo_floor((mountFeedTimer - (hours * ZO_ONE_HOUR_IN_MILLISECONDS)) / ZO_ONE_MINUTE_IN_MILLISECONDS)
                uiFeedTimer.label:SetText(string_format("%dh %dm", hours, minutes))
            else
                uiFeedTimer.label:SetText(GetString(LUIE_STRING_PNL_TRAINNOW))
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

    uiFeedTimer.label:SetText(mountFeedMessage)
end

-- Build/replace the meter registry (called during Initialize)
function InfoPanel.BuildMeters()
    meters = {}
    metersOrdered = {}

    local function AddMeter(meter)
        meters[meter.id] = meter
        metersOrdered[#metersOrdered + 1] = meter
    end

    AddMeter(LatencyMeter:New(InfoPanel))
    AddMeter(FpsMeter:New(InfoPanel))
    AddMeter(ClockMeter:New(InfoPanel))
    AddMeter(SoulGemsMeter:New(InfoPanel))
    AddMeter(MountFeedMeter:New(InfoPanel))
    AddMeter(ArmourMeter:New(InfoPanel))
    AddMeter(WeaponChargesMeter:New(InfoPanel))
    AddMeter(BagsMeter:New(InfoPanel))
    AddMeter(GoldMeter:New(InfoPanel))
end

function InfoPanel.OnUpdateDriver()
    if not InfoPanel.Enabled or not uiPanel then
        return
    end
    if uiPanel:IsHidden() then
        return
    end

    local nowMs = GetFrameTimeMilliseconds()
    ForEachMeter(function (meter)
        if meter:IsEnabled() and meter:ShouldUpdate(nowMs) then
            meter:Update(nowMs)
            meter:MarkUpdated(nowMs)
        end
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
    local fontName = LUIE.Fonts[InfoPanel.SV.FontFace]
    if not fontName or fontName == "" then
        fontName = "LUIE Default Font"
        -- if LUIE.IsDevDebugEnabled() then
        --     LUIE:Log("Debug",GetString(LUIE_STRING_ERROR_FONT))
        -- end
    end

    local fontStyle = InfoPanel.SV.FontStyle
    local fontSize = (InfoPanel.SV.FontSize and InfoPanel.SV.FontSize > 0) and InfoPanel.SV.FontSize or 16

    -- Create font string
    g_infoPanelFont = LUIE.CreateFontString(fontName, fontSize, fontStyle)

    -- Apply font to all elements
    ForEachMeter(function (meter)
        if meter.ApplyFont then
            meter:ApplyFont(g_infoPanelFont)
        end
    end)
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
        return
    end
    panelHiddenByCombat = false
    local targetAlpha = (InfoPanel.SV.transparency and InfoPanel.SV.transparency / 100) or 1
    uiPanel:SetHidden(false)
    uiPanel:SetAlpha(0)
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

-- Rearranges panel elements. Called from Initialize and settings menu.
function InfoPanel.RearrangePanel()
    if not InfoPanel.Enabled then
        return
    end
    local function MeterEnabled(id, fallbackEnabled)
        local meter = InfoPanel.GetMeter(id)
        if meter and meter.IsEnabled then
            return meter:IsEnabled()
        end
        return fallbackEnabled
    end
    -- Reset scale of panel
    uiPanel:SetScale(1)
    -- Top row
    local anchorTop = nil
    local sizeTop = 0
    -- Latency
    if not MeterEnabled("Latency", not InfoPanel.SV.HideLatency) then
        uiLatency.control:SetHidden(true)
    else
        uiLatency.control:ClearAnchors()
        uiLatency.control:SetAnchor(LEFT, anchorTop or uiTopRow, (anchorTop == nil) and LEFT or RIGHT, 0, 0)
        uiLatency.control:SetHidden(false)
        sizeTop = sizeTop + uiLatency.control:GetWidth()
        anchorTop = uiLatency.control
    end
    -- FPS
    if not MeterEnabled("FPS", not InfoPanel.SV.HideFPS) then
        uiFps.control:SetHidden(true)
    else
        uiFps.control:ClearAnchors()
        uiFps.control:SetAnchor(LEFT, anchorTop or uiTopRow, (anchorTop == nil) and LEFT or RIGHT, 0, 0)
        uiFps.control:SetHidden(false)
        sizeTop = sizeTop + uiFps.control:GetWidth()
        anchorTop = uiFps.control
    end
    -- Time
    if not MeterEnabled("Clock", not InfoPanel.SV.HideClock) then
        uiClock.control:SetHidden(true)
    else
        uiClock.control:ClearAnchors()
        uiClock.control:SetAnchor(LEFT, anchorTop or uiTopRow, (anchorTop == nil) and LEFT or RIGHT, 0, 0)
        uiClock.control:SetHidden(false)
        sizeTop = sizeTop + uiClock.control:GetWidth()
        anchorTop = uiClock.control
    end
    -- Soulgems
    if not MeterEnabled("SoulGems", not InfoPanel.SV.HideGems) then
        uiGems.control:SetHidden(true)
    else
        uiGems.control:ClearAnchors()
        uiGems.control:SetAnchor(LEFT, anchorTop or uiTopRow, (anchorTop == nil) and LEFT or RIGHT, 0, 0)
        uiGems.control:SetHidden(false)
        sizeTop = sizeTop + uiGems.control:GetWidth()
        anchorTop = uiGems.control
    end
    -- Set row size
    uiTopRow:SetWidth((sizeTop > 0) and sizeTop or 10)
    -- Bottom row
    local anchorBot = nil
    local sizeBot = 0
    -- Feed timer
    if not MeterEnabled("MountFeed", not InfoPanel.SV.HideMountFeed) then
        uiFeedTimer.control:SetHidden(true)
        sizeBot = sizeBot - (uiFeedTimer.control:GetWidth() * 0.15)
    else
        uiFeedTimer.control:ClearAnchors()
        uiFeedTimer.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiFeedTimer.control:SetHidden(false)
        sizeBot = sizeBot + uiFeedTimer.control:GetWidth()
        anchorBot = uiFeedTimer.control
    end
    -- Durability
    if not MeterEnabled("Armour", not InfoPanel.SV.HideArmour) then
        uiArmour.control:SetHidden(true)
    else
        uiArmour.control:ClearAnchors()
        uiArmour.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiArmour.control:SetHidden(false)
        sizeBot = sizeBot + uiArmour.control:GetWidth()
        anchorBot = uiArmour.control
    end
    -- Charges
    if not MeterEnabled("WeaponCharges", not InfoPanel.SV.HideWeapons) then
        uiWeapons.control:SetHidden(true)
    else
        uiWeapons.control:ClearAnchors()
        uiWeapons.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiWeapons.control:SetHidden(false)
        sizeBot = sizeBot + uiWeapons.control:GetWidth()
        anchorBot = uiWeapons.control
    end
    -- Bags
    if not MeterEnabled("Bags", not InfoPanel.SV.HideBags) then
        uiBags.control:SetHidden(true)
    else
        uiBags.control:ClearAnchors()
        uiBags.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiBags.control:SetHidden(false)
        sizeBot = sizeBot + uiBags.control:GetWidth()
        anchorBot = uiBags.control
    end
    -- Gold (moved to end for right positioning)
    if not MeterEnabled("Gold", not InfoPanel.SV.HideGold) then
        uiGold.control:SetHidden(true)
    else
        uiGold.control:ClearAnchors()
        uiGold.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiGold.control:SetHidden(false)
        InfoPanel.UpdateGoldDisplay()
        sizeBot = sizeBot + uiGold.control:GetWidth()
        anchorBot = uiGold.control
    end
    -- Set row size
    uiBotRow:SetWidth((sizeBot > 0) and sizeBot or 10)
    -- Set size of panel
    uiPanel:SetWidth(zo_max(uiTopRow:GetWidth(), uiBotRow:GetWidth(), 39 * 6))
    -- Set scale of panel again
    InfoPanel.SetScale()
    -- Apply transparency
    InfoPanel.ApplyTransparency()
end

function InfoPanel.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        InfoPanel.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "InfoPanel", InfoPanel.Defaults)
    else
        InfoPanel.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "InfoPanel", InfoPanel.Defaults)
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
    local fontName = LUIE.Fonts[InfoPanel.SV.FontFace]
    if not fontName or fontName == "" then
        fontName = "LUIE Default Font"
    end
    local fontStyle = InfoPanel.SV.FontStyle
    local fontSize = (InfoPanel.SV.FontSize and InfoPanel.SV.FontSize > 0) and InfoPanel.SV.FontSize or 16
    g_infoPanelFont = LUIE.CreateFontString(fontName, fontSize, fontStyle)

    -- Top Row Controls
    uiLatency.control = LUIE_InfoPanel_TopRow_Latency
    uiLatency.icon = LUIE_InfoPanel_TopRow_Latency_Icon
    uiLatency.label = LUIE_InfoPanel_TopRow_Latency_Label

    uiFps.label = LUIE_InfoPanel_TopRow_Fps
    uiFps.control = uiFps.label

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

    InfoPanel.RearrangePanel()

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

    -- Set event handlers
    eventManager:RegisterForEvent(moduleName, EVENT_LOOT_RECEIVED, InfoPanel.OnBagUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, InfoPanel.OnBagUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEM_DESTROYED, InfoPanel.OnBagUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_FULL_UPDATE, InfoPanel.OnBagUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_ITEMS_AUTO_TRANSFERRED_TO_CRAFT_BAG, InfoPanel.OnBagUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, InfoPanel.OnBagCapacityChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_CARRIED_CURRENCY_UPDATE, InfoPanel.OnCurrencyUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_RIDING_SKILL_IMPROVEMENT, InfoPanel.UpdateMountFeedTimer)

    -- Single update driver; meters handle their own intervals
    eventManager:RegisterForUpdate(updateDriverName, ZO_ONE_SECOND_IN_MILLISECONDS, InfoPanel.OnUpdateDriver)

    -- Combat state: always register so enabling HideInCombat in settings later works. Handler checks HideInCombat.
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_COMBAT_STATE, function (eventId, inCombat)
        InfoPanel.OnPlayerCombatState(inCombat)
    end)
    if not InfoPanel.SV.HideInCombat then
        -- XML defaults to hidden="true"; ensure panel is visible when option is off
        uiPanel:SetHidden(false)
        InfoPanel.ApplyTransparency()
    else
        -- Sync initial visibility when option is on (e.g. show panel if not in combat)
        InfoPanel.OnPlayerCombatState(IsUnitInCombat("player"))
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
    -- Clear anchors and let XML default anchor take over
    uiPanel:ClearAnchors()
    uiPanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24, 20)
end

-- Handler for OnMoveStop event (called from XML)
--- @param control Control
function InfoPanel.OnPanelMoveStop(control)
    if InfoPanel.SV then
        InfoPanel.SV.position = { control:GetCenter() }
    end
end

-- Unlock panel for moving. Called from Settings Menu.
function InfoPanel.SetMovingState(state)
    if not InfoPanel.Enabled then
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
    uiPanel:SetScale(InfoPanel.SV.panelScale and InfoPanel.SV.panelScale / 100 or 1)
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

function InfoPanel.OnUpdate01()
    local nowMs = GetFrameTimeMilliseconds()
    local clockMeter = InfoPanel.GetMeter("Clock")
    if clockMeter then
        clockMeter:Update(nowMs)
        clockMeter:MarkUpdated(nowMs)
    end
    local fpsMeter = InfoPanel.GetMeter("FPS")
    if fpsMeter then
        fpsMeter:Update(nowMs)
        fpsMeter:MarkUpdated(nowMs)
    end
end

function InfoPanel.OnUpdate10()
    local nowMs = GetFrameTimeMilliseconds()
    local latencyMeter = InfoPanel.GetMeter("Latency")
    if latencyMeter then
        latencyMeter:Update(nowMs)
        latencyMeter:MarkUpdated(nowMs)
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

function InfoPanel.OnUpdate60()
    local nowMs = GetFrameTimeMilliseconds()
    local armourMeter = InfoPanel.GetMeter("Armour")
    if armourMeter then
        armourMeter:Update(nowMs)
        armourMeter:MarkUpdated(nowMs)
    end
    local weaponsMeter = InfoPanel.GetMeter("WeaponCharges")
    if weaponsMeter then
        weaponsMeter:Update(nowMs)
        weaponsMeter:MarkUpdated(nowMs)
    end
    InfoPanel.DoBagUpdate()
    InfoPanel.UpdateMountFeedTimer()
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
