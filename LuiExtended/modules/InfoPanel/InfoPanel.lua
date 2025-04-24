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

local UI = LUIE.UI

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
    FontFace = "$(BOLD_FONT)",
    FontSize = 16,
    FontStyle = "soft-shadow-thin",
}
InfoPanel.SV = {}
InfoPanel.panelUnlocked = false

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

-- Apply font changes to the info panel elements
function InfoPanel.ApplyFont()
    if not InfoPanel.Enabled then
        return
    end

    -- Get font settings
    local fontName = LUIE.Fonts[InfoPanel.SV.FontFace]
    if not fontName or fontName == "" then
        if LUIE.IsDevDebugEnabled() then
            LUIE.Debug(GetString(LUIE_STRING_ERROR_FONT))
        end
        fontName = "$(BOLD_FONT)"
    end

    local fontStyle = (InfoPanel.SV.FontStyle and InfoPanel.SV.FontStyle ~= "") and InfoPanel.SV.FontStyle or "soft-shadow-thin"
    local fontSize = (InfoPanel.SV.FontSize and InfoPanel.SV.FontSize > 0) and InfoPanel.SV.FontSize or 16

    -- Create font string
    g_infoPanelFont = string_format("%s|%d|%s", fontName, fontSize, fontStyle)

    -- Apply font to all elements
    if uiLatency.label then uiLatency.label:SetFont(g_infoPanelFont) end
    if uiFps.label then uiFps.label:SetFont(g_infoPanelFont) end
    if uiClock.label then uiClock.label:SetFont(g_infoPanelFont) end
    if uiGems.label then uiGems.label:SetFont(g_infoPanelFont) end
    if uiGold.label then uiGold.label:SetFont(g_infoPanelFont) end
    if uiFeedTimer.label then uiFeedTimer.label:SetFont(g_infoPanelFont) end
    if uiArmour.label then uiArmour.label:SetFont(g_infoPanelFont) end
    if uiBags.label then uiBags.label:SetFont(g_infoPanelFont) end
end

function InfoPanel.SetDisplayOnMap()
    if InfoPanel.SV.DisplayOnWorldMap then
        sceneManager:GetScene("worldMap"):AddFragment(panelFragment)
    else
        sceneManager:GetScene("worldMap"):RemoveFragment(panelFragment)
    end
end

local function CreateUIControls()
    uiPanel = UI:TopLevel(nil, { 240, 48 })
    uiPanel:SetDrawLayer(DL_BACKGROUND)
    uiPanel:SetDrawTier(DT_LOW)
    uiPanel:SetDrawLevel(DL_CONTROLS)

    panelFragment = ZO_HUDFadeSceneFragment:New(uiPanel, 0, 0)

    sceneManager:GetScene("hud"):AddFragment(panelFragment)
    sceneManager:GetScene("hudui"):AddFragment(panelFragment)
    sceneManager:GetScene("siegeBar"):AddFragment(panelFragment)
    sceneManager:GetScene("siegeBarUI"):AddFragment(panelFragment)

    InfoPanel.SetDisplayOnMap() -- Add to map scene if the option is enabled.

    uiPanel.div = UI:Texture(uiPanel, nil, nil, "/esoui/art/miscellaneous/horizontaldivider.dds", DL_BACKGROUND, false)
    uiPanel.div:SetAnchor(LEFT, uiPanel, LEFT, -60, 0)
    uiPanel.div:SetAnchor(RIGHT, uiPanel, RIGHT, 60, 0)
    uiPanel.div:SetHeight(4)

    uiTopRow = UI:Control(uiPanel, { TOP, TOP, 0, 2 }, { 300, 20 }, false)

    uiBotRow = UI:Control(uiPanel, { BOTTOM, BOTTOM, 0, -2 }, { 300, 20 }, false)

    -- Create font string from settings
    local fontName = LUIE.Fonts[InfoPanel.SV.FontFace]
    if not fontName or fontName == "" then
        fontName = "$(BOLD_FONT)"
    end
    local fontStyle = (InfoPanel.SV.FontStyle and InfoPanel.SV.FontStyle ~= "") and InfoPanel.SV.FontStyle or "soft-shadow-thin"
    local fontSize = (InfoPanel.SV.FontSize and InfoPanel.SV.FontSize > 0) and InfoPanel.SV.FontSize or 16
    g_infoPanelFont = string_format("%s|%d|%s", fontName, fontSize, fontStyle)

    uiLatency.control = UI:Control(uiTopRow, nil, { 75, 20 }, false)
    uiLatency.icon = UI:Texture(uiLatency.control, { LEFT, LEFT }, { 24, 24 }, "/esoui/art/campaign/campaignbrowser_hipop.dds", nil, false)
    uiLatency.label = UI:Label(uiLatency.control, { LEFT, RIGHT, 0, 0, uiLatency.icon }, { 56, 20 }, { 0, 1 }, g_infoPanelFont, "11999 ms", false)

    uiFps.label = UI:Label(uiTopRow, nil, { 50, 20 }, { 1, 1 }, g_infoPanelFont, "999 fps", false)
    uiFps.control = uiFps.label

    uiClock.label = UI:Label(uiTopRow, nil, { 60, 20 }, { 1, 1 }, g_infoPanelFont, "88:88:88", false)
    uiClock.control = uiClock.label

    uiGems.control = UI:Control(uiTopRow, nil, { 48, 20 }, false)
    uiGems.icon = UI:Texture(uiGems.control, { LEFT, LEFT }, { 16, 16 }, nil, nil, false)
    uiGems.label = UI:Label(uiGems.control, { LEFT, RIGHT, 2, 0, uiGems.icon }, { 32, 20 }, { 0, 1 }, g_infoPanelFont, "8/88", false)

    -- Gold display
    uiGold.control = UI:Control(uiBotRow, nil, { 85, 20 }, false)
    uiGold.icon = UI:Texture(uiGold.control, { LEFT, LEFT }, { 12, 12 }, ZO_Currency_GetKeyboardCurrencyIcon(CURT_MONEY), nil, false)
    uiGold.label = UI:Label(uiGold.control, { LEFT, RIGHT, 2, 0, uiGold.icon }, { 65, 20 }, { 0, 1 }, g_infoPanelFont, ZO_CommaDelimitNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)), false)
    uiGold.label:SetColor(colors.GOLD.r, colors.GOLD.g, colors.GOLD.b, 1)

    uiFeedTimer.control = UI:Control(uiBotRow, nil, { 96, 20 }, false)
    uiFeedTimer.icon = UI:Texture(uiFeedTimer.control, { LEFT, LEFT }, { 28, 28 }, "/esoui/art/mounts/tabicon_mounts_up.dds", nil, false)
    uiFeedTimer.label = UI:Label(uiFeedTimer.control, { LEFT, RIGHT, 0, 0, uiFeedTimer.icon }, { 68, 20 }, { 0, 1 }, g_infoPanelFont, GetString(LUIE_STRING_PNL_TRAINNOW), false)

    uiArmour.control = UI:Control(uiBotRow, nil, { 55, 20 }, false)
    uiArmour.icon = UI:Texture(uiArmour.control, { LEFT, LEFT }, { 24, 24 }, "/esoui/art/progression/progression_indexicon_armor_up.dds", nil, false)
    uiArmour.label = UI:Label(uiArmour.control, { LEFT, RIGHT, 0, 0, uiArmour.icon }, { 41, 20 }, { 0, 1 }, g_infoPanelFont, "100%", false)

    uiWeapons.control = UI:Control(uiBotRow, nil, { 46, 20 }, false)
    uiWeapons.main = UI:Texture(uiWeapons.control, { LEFT, LEFT }, { 30, 30 }, "/esoui/art/progression/icon_1handplusrune.dds", nil, false)
    uiWeapons.swap = UI:Texture(uiWeapons.control, { RIGHT, RIGHT, 5 }, { 30, 30 }, "/esoui/art/progression/icon_1handplusrune.dds", nil, false)
    uiWeapons.main.slotIndex = EQUIP_SLOT_MAIN_HAND
    uiWeapons.swap.slotIndex = EQUIP_SLOT_BACKUP_MAIN

    uiBags.control = UI:Control(uiBotRow, nil, { 78, 20 }, false)
    uiBags.icon = UI:Texture(uiBags.control, { LEFT, LEFT }, { 28, 28 }, "/esoui/art/inventory/inventory_tabicon_misc_up.dds", nil, false)
    uiBags.label = UI:Label(uiBags.control, { LEFT, RIGHT, 0, 0, uiBags.icon }, { 50, 20 }, { 0, 1 }, g_infoPanelFont, "888/888", false)
end

-- Rearranges panel elements. Called from Initialize and settings menu.
function InfoPanel.RearrangePanel()
    if not InfoPanel.Enabled then
        return
    end
    -- Reset scale of panel
    uiPanel:SetScale(1)
    -- Top row
    local anchorTop = nil
    local sizeTop = 0
    -- Latency
    if InfoPanel.SV.HideLatency then
        uiLatency.control:SetHidden(true)
    else
        uiLatency.control:ClearAnchors()
        uiLatency.control:SetAnchor(LEFT, anchorTop or uiTopRow, (anchorTop == nil) and LEFT or RIGHT, 0, 0)
        uiLatency.control:SetHidden(false)
        sizeTop = sizeTop + uiLatency.control:GetWidth()
        anchorTop = uiLatency.control
    end
    -- FPS
    if InfoPanel.SV.HideFPS then
        uiFps.control:SetHidden(true)
    else
        uiFps.control:ClearAnchors()
        uiFps.control:SetAnchor(LEFT, anchorTop or uiTopRow, (anchorTop == nil) and LEFT or RIGHT, 0, 0)
        uiFps.control:SetHidden(false)
        sizeTop = sizeTop + uiFps.control:GetWidth()
        anchorTop = uiFps.control
    end
    -- Time
    if InfoPanel.SV.HideClock then
        uiClock.control:SetHidden(true)
    else
        uiClock.control:ClearAnchors()
        uiClock.control:SetAnchor(LEFT, anchorTop or uiTopRow, (anchorTop == nil) and LEFT or RIGHT, 0, 0)
        uiClock.control:SetHidden(false)
        sizeTop = sizeTop + uiClock.control:GetWidth()
        anchorTop = uiClock.control
    end
    -- Soulgems
    if InfoPanel.SV.HideGems then
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
    if InfoPanel.SV.HideMountFeed or uiFeedTimer.hideLocally then
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
    if InfoPanel.SV.HideArmour then
        uiArmour.control:SetHidden(true)
    else
        uiArmour.control:ClearAnchors()
        uiArmour.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiArmour.control:SetHidden(false)
        sizeBot = sizeBot + uiArmour.control:GetWidth()
        anchorBot = uiArmour.control
    end
    -- Charges
    if InfoPanel.SV.HideWeapons then
        uiWeapons.control:SetHidden(true)
    else
        uiWeapons.control:ClearAnchors()
        uiWeapons.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiWeapons.control:SetHidden(false)
        sizeBot = sizeBot + uiWeapons.control:GetWidth()
        anchorBot = uiWeapons.control
    end
    -- Bags
    if InfoPanel.SV.HideBags then
        uiBags.control:SetHidden(true)
    else
        uiBags.control:ClearAnchors()
        uiBags.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiBags.control:SetHidden(false)
        sizeBot = sizeBot + uiBags.control:GetWidth()
        anchorBot = uiBags.control
    end
    -- Gold (moved to end for right positioning)
    if InfoPanel.SV.HideGold then
        uiGold.control:SetHidden(true)
    else
        uiGold.control:ClearAnchors()
        uiGold.control:SetAnchor(LEFT, anchorBot or uiBotRow, (anchorBot == nil) and LEFT or RIGHT, 0, 0)
        uiGold.control:SetHidden(false)
        sizeBot = sizeBot + uiGold.control:GetWidth()
        anchorBot = uiGold.control
    end
    -- Set row size
    uiBotRow:SetWidth((sizeBot > 0) and sizeBot or 10)
    -- Set size of panel
    uiPanel:SetWidth(zo_max(uiTopRow:GetWidth(), uiBotRow:GetWidth(), 39 * 6))
    -- Set scale of panel again
    InfoPanel.SetScale()
end

function InfoPanel.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV["Default"][GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        InfoPanel.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "InfoPanel", InfoPanel.Defaults)
    else
        InfoPanel.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "InfoPanel", InfoPanel.Defaults)
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    InfoPanel.Enabled = true

    CreateUIControls()
    InfoPanel.RearrangePanel()

    -- add control to global list so it can be hidden
    LUIE.Components[moduleName] = uiPanel

    -- Panel position
    if InfoPanel.SV.position ~= nil and #InfoPanel.SV.position == 2 then
        uiPanel:SetAnchor(CENTER, GuiRoot, TOPLEFT, InfoPanel.SV.position[1], InfoPanel.SV.position[2])
    else
        uiPanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24, 20)
    end

    -- Dragging
    local OnMoveStop = function (self)
        InfoPanel.SV.position = { self:GetCenter() }
    end
    uiPanel:SetHandler("OnMoveStop", OnMoveStop)

    -- Set init values
    InfoPanel.OnUpdate01()
    InfoPanel.OnUpdate10()
    InfoPanel.OnUpdate60()
    InfoPanel.UpdateMountFeedTimer()

    -- Apply font settings
    InfoPanel.ApplyFont()

    -- Set event handlers
    eventManager:RegisterForEvent(moduleName, EVENT_LOOT_RECEIVED, InfoPanel.OnBagUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, InfoPanel.OnBagUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_BAG_CAPACITY_CHANGED, InfoPanel.OnBagCapacityChanged)
    eventManager:RegisterForEvent(moduleName, EVENT_CARRIED_CURRENCY_UPDATE, InfoPanel.OnCurrencyUpdate)
    eventManager:RegisterForEvent(moduleName, EVENT_RIDING_SKILL_IMPROVEMENT, InfoPanel.UpdateMountFeedTimer)
    eventManager:RegisterForUpdate(moduleName .. "01", ZO_ONE_SECOND_IN_MILLISECONDS, InfoPanel.OnUpdate01)
    eventManager:RegisterForUpdate(moduleName .. "10", ZO_ONE_SECOND_IN_MILLISECONDS * 10, InfoPanel.OnUpdate10)
    eventManager:RegisterForUpdate(moduleName .. "60", ZO_ONE_MINUTE_IN_MILLISECONDS, InfoPanel.OnUpdate60)
end

function InfoPanel.ResetPosition()
    InfoPanel.SV.position = nil
    if not InfoPanel.Enabled then
        return
    end
    uiPanel:ClearAnchors()
    uiPanel:SetAnchor(TOPRIGHT, GuiRoot, TOPRIGHT, -24, 20)
end

-- Unlock panel for moving. Called from Settings Menu.
function InfoPanel.SetMovingState(state)
    if not InfoPanel.Enabled then
        return
    end
    InfoPanel.panelUnlocked = state
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

-- EVENT HANDLING PATTERN:
-- We use a consistent pattern for event handling in InfoPanel:
-- 1. For simple events, the event handler is a direct function like OnCurrencyUpdate
-- 2. For events that need debouncing (like bag updates), we use a two-function pattern:
--    - OnBagUpdate: registers a delayed update
--    - DoBagUpdate: does the actual work after the delay
-- 3. Event handlers accept all event parameters and utilize them for rich functionality:
--    - UpdateMountFeedTimer: Different display based on riding skill improvement
--    - OnBagCapacityChanged: Shows capacity upgrades with special formatting
--    - OnCurrencyUpdate: Shows temporary notifications for significant gold changes
--
-- This approach reduces redundancy, makes the code easier to maintain, and creates
-- a better user experience by leveraging the event data for more contextual updates.

-- Listens to EVENT_INVENTORY_SINGLE_SLOT_UPDATE and EVENT_LOOT_RECEIVED
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
    eventManager:RegisterForUpdate(moduleName .. "PendingBagsUpdate", ZO_ONE_SECOND_IN_MILLISECONDS / 4, InfoPanel.DoBagUpdate)
end

-- Helper function to update bag display
local function UpdateBagDisplay()
    if InfoPanel.SV.HideBags then return end

    local bagSize = GetBagSize(BAG_BACKPACK)
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

-- Helper function to update soulgem display
local function UpdateSoulgemDisplay()
    if InfoPanel.SV.HideGems then return end

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

-- Performs calculation of empty space in bags
-- Called with delay by corresponding event listener
function InfoPanel.DoBagUpdate()
    -- Clear pending event
    eventManager:UnregisterForUpdate(moduleName .. "PendingBagsUpdate")

    -- Update bags and soulgems
    UpdateBagDisplay()
    UpdateSoulgemDisplay()
end

local function FormatClock(clockFormat)
    local timestring = GetTimeString()
    return LUIE.CreateTimestamp(timestring, clockFormat)
end

-- Helper function to update and color the clock display
local function UpdateClock()
    if InfoPanel.SV.HideClock then return end
    uiClock.label:SetText(FormatClock(InfoPanel.SV.ClockFormat))
end

-- Helper function to update and color the FPS display
local function UpdateFPS()
    if InfoPanel.SV.HideFPS then return end
    local fps = GetFramerate()
    local color = colors.WHITE
    if not InfoPanel.SV.DisableInfoColours then
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

-- Helper function to update and color the latency display
local function UpdateLatency()
    if InfoPanel.SV.HideLatency then return end
    local lat = GetLatency()
    local color = colors.WHITE
    if not InfoPanel.SV.DisableInfoColours then
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

-- Helper function to update and color armor durability display
local function UpdateArmourDurability()
    if InfoPanel.SV.HideArmour then return end

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

-- Helper function to update and color weapon charges display
local function UpdateWeaponCharges()
    if InfoPanel.SV.HideWeapons then return end

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

function InfoPanel.OnUpdate01()
    -- Update time
    UpdateClock()

    -- Update fps
    UpdateFPS()
end

function InfoPanel.OnUpdate10()
    -- Update latency
    UpdateLatency()
end

-- Update mount feed timer information
--- @param eventId integer|nil Optional - event ID if called from event
--- @param ridingSkillType RidingTrainType|nil Optional - riding skill type
--- @param previous integer|nil Optional - previous skill value
--- @param current integer|nil Optional - current skill value
--- @param source RidingTrainSource|nil Optional - source of the training
function InfoPanel.UpdateMountFeedTimer(eventId, ridingSkillType, previous, current, source)
    if InfoPanel.SV.HideMountFeed or not InfoPanel.Enabled then
        return
    end

    -- If this was triggered by the EVENT_RIDING_SKILL_IMPROVEMENT event
    if eventId == EVENT_RIDING_SKILL_IMPROVEMENT and ridingSkillType ~= nil and current ~= nil then
        -- Get current stats to check if fully trained
        local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
        local isFullyTrained = (inventoryBonus == maxInventoryBonus and staminaBonus == maxStaminaBonus and speedBonus == maxSpeedBonus)

        -- Skill was just improved - show appropriate message
        if isFullyTrained then
            -- All mount skills are now maxed
            uiFeedTimer.label:SetText(GetString(LUIE_STRING_PNL_MAXED))
            uiFeedTimer.hideLocally = true
            InfoPanel.RearrangePanel()
            return
        else
            -- Still has skills to train, show training cooldown
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

    -- Standard update without event - check training state
    local mountFeedTimer, mountFeedTotalTime = GetTimeUntilCanBeTrained()
    local mountFeedMessage = GetString(LUIE_STRING_PNL_MAXED)

    if mountFeedTimer ~= nil then
        if mountFeedTimer == 0 then
            local inventoryBonus, maxInventoryBonus, staminaBonus, maxStaminaBonus, speedBonus, maxSpeedBonus = GetRidingStats()
            if inventoryBonus ~= maxInventoryBonus or staminaBonus ~= maxStaminaBonus or speedBonus ~= maxSpeedBonus then
                mountFeedMessage = GetString(LUIE_STRING_PNL_TRAINNOW)
            else
                uiFeedTimer.hideLocally = true
                InfoPanel.RearrangePanel()
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

function InfoPanel.OnUpdate60()
    -- Update item durability
    UpdateArmourDurability()

    -- Get charges information
    UpdateWeaponCharges()

    -- Update bag slot count
    InfoPanel.DoBagUpdate()

    -- Update mount feed timer periodically in case it needs to be hidden
    -- This ensures the display updates even if no training events occur
    InfoPanel.UpdateMountFeedTimer()
end

-- Update bag capacity when it changes
--- @param eventId integer
--- @param previousCapacity integer
--- @param currentCapacity integer
--- @param previousUpgrade integer
--- @param currentUpgrade integer
function InfoPanel.OnBagCapacityChanged(eventId, previousCapacity, currentCapacity, previousUpgrade, currentUpgrade)
    -- Use event parameters to update bag display
    if InfoPanel.SV.HideBags then return end

    -- Use the currentCapacity parameter directly instead of calling GetBagSize
    local bagSize = currentCapacity
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
    uiGold.label:SetText(ZO_CommaDelimitNumber(GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER)))
    uiGold.label:SetColor(colors.GOLD.r, colors.GOLD.g, colors.GOLD.b, 1)
end
