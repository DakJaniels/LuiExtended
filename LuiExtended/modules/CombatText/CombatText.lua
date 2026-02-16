-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class LuiExtended
local LUIE = LUIE

--- @class (partial) LuiExtended.CombatText
local CombatText = LUIE.CombatText

local CombatTextConstants = LuiData.Data.CombatTextConstants

local pairs = pairs
local printToChat = LUIE.PrintToChat

local eventManager = GetEventManager()
local chatSystem = ZO_GetChatSystem()

-- Table cache system is now global: use LUIE.GetCachedTable() and LUIE.RecycleTable()
-- See LuiExtended.lua for implementation details

local panelTitles =
{
    LUIE_CombatText_Outgoing = GetString(LUIE_STRING_CT_PANEL_OUTGOING),
    LUIE_CombatText_Incoming = GetString(LUIE_STRING_CT_PANEL_INCOMING),
    LUIE_CombatText_Point = GetString(LUIE_STRING_CT_PANEL_POINT),
    LUIE_CombatText_Alert = GetString(LUIE_STRING_CT_PANEL_ALERT),
    LUIE_CombatText_Resource = GetString(LUIE_STRING_CT_PANEL_RESOURCE),
}

---
--- @param panel Control
function CombatText.SavePosition(panel)
    local anchor = { panel:GetAnchor(0) }
    local dimensions = { panel:GetDimensions() }
    local panelSettings = LUIE.CombatText.SV.panels[panel:GetName()]
    panelSettings.point = anchor[2]
    panelSettings.relativePoint = anchor[4]
    panelSettings.offsetX = anchor[5]
    panelSettings.offsetY = anchor[6]
    panelSettings.dimensions = dimensions
end

--- Reset all panel positions to defaults
function CombatText.ResetPanelPositions()
    if not CombatText.Enabled then
        return
    end

    local Defaults = CombatText.Defaults
    local Settings = CombatText.SV

    -- Reset unlocked state
    Settings.unlocked = Defaults.unlocked

    -- Reset all panel settings to defaults
    for k, defaultPanel in pairs(Defaults.panels) do
        if Settings.panels[k] then
            -- Copy default values
            Settings.panels[k].point = defaultPanel.point
            Settings.panels[k].relativePoint = defaultPanel.relativePoint
            Settings.panels[k].offsetX = defaultPanel.offsetX
            Settings.panels[k].offsetY = defaultPanel.offsetY
            Settings.panels[k].dimensions = {}
            for i, dim in ipairs(defaultPanel.dimensions) do
                Settings.panels[k].dimensions[i] = dim
            end
            -- Remove x/y coordinates if they exist
            Settings.panels[k].x = nil
            Settings.panels[k].y = nil
        end
    end

    -- Lock all panels
    CombatText.SetMovingState(false)

    -- Re-apply panel positions
    local Combattext = GetControl("Combattext")
    if Combattext then
        for k, s in pairs(Settings.panels) do
            local panel = _G[k]
            if panel then
                panel:ClearAnchors()
                panel:SetAnchor(s.point, Combattext, s.relativePoint, s.offsetX, s.offsetY)
                panel:SetDimensions(unpack(s.dimensions))
            end
        end
    end
end

-- Bulk list add from menu buttons
---
--- @param list any
--- @param table any
function CombatText.AddBulkToCustomList(list, table)
    if table ~= nil then
        for k, v in pairs(table) do
            CombatText.AddToCustomList(list, k)
        end
    end
end

---
--- @param list any
function CombatText.ClearCustomList(list)
    local listRef = list == CombatText.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CT_BLACKLIST) or ""
    for k, v in pairs(list) do
        list[k] = nil
    end
    chatSystem:Maximize()
    chatSystem.primaryContainer:FadeIn()
    printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
end

-- List Handling (Add) for Prominent Auras & Blacklist
---
--- @param list any
--- @param input any
function CombatText.AddToCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == CombatText.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CT_BLACKLIST) or ""
    if id and id > 0 then
        local name = zo_strformat("<<C:1>>", GetAbilityName(id))
        if name ~= nil and name ~= "" then
            local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
            list[id] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
        end
    end
end

-- List Handling (Remove) for Prominent Auras & Blacklist
---
--- @param list any
--- @param input any
function CombatText.RemoveFromCustomList(list, input)
    local id = tonumber(input)
    local listRef = list == CombatText.SV.blacklist and GetString(LUIE_STRING_CUSTOM_LIST_CT_BLACKLIST) or ""
    if id and id > 0 then
        local name = zo_strformat("<<C:1>>", GetAbilityName(id))
        local icon = zo_iconFormat(GetAbilityIcon(id), 16, 16)
        list[id] = nil
        chatSystem:Maximize()
        chatSystem.primaryContainer:FadeIn()
        printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            printToChat(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
end

function CombatText.ApplyFont()
    local fontName = LUIE.Fonts[LUIE.CombatText.SV.fontFace]
    LUIE.CombatText.SV.fontFaceApplied = fontName
    if not fontName or fontName == "" then
        printToChat(GetString(LUIE_STRING_ERROR_FONT), true)
        LUIE.CombatText.SV.fontFaceApplied = "$(MEDIUM_FONT)"
    end
end

--- Create or recreate the combat event viewer based on animation type<br>
--- Uses instance-based callback system via eventListener reference
function CombatText.CreateCombatEventViewer()
    if not CombatText.Enabled or not CombatText.poolManager or not CombatText.combatEventListener then
        return
    end

    -- Remove old combat event viewer if it exists
    if CombatText.combatEventViewer then
        -- With ZO_CallbackObject, callbacks are managed by the listener instance
        -- No manual unregistration needed - just clear the viewer reference
        CombatText.combatEventViewer = nil
    end

    -- Create new combat event viewer based on animation type
    local animationType = CombatText.SV.animation.animationType
    local newViewer
    if animationType == "cloud" then
        newViewer = LUIE.CombatTextCombatCloudEventViewer:New(CombatText.poolManager, CombatText.combatEventListener)
    elseif animationType == "hybrid" then
        newViewer = LUIE.CombatTextCombatHybridEventViewer:New(CombatText.poolManager, CombatText.combatEventListener)
    elseif animationType == "scroll" then
        newViewer = LUIE.CombatTextCombatScrollEventViewer:New(CombatText.poolManager, CombatText.combatEventListener)
    elseif animationType == "ellipse" then
        newViewer = LUIE.CombatTextCombatEllipseEventViewer:New(CombatText.poolManager, CombatText.combatEventListener)
    end
    CombatText.combatEventViewer = newViewer
end

-- Unlock panels for moving
--- @param state boolean
function CombatText.SetMovingState(state)
    if not CombatText.Enabled then
        return
    end

    CombatText.SV.unlocked = state

    --- @class CombatTextPanels : LUIE_CombatText_Alert, LUIE_CombatText_Incoming, LUIE_CombatText_Outgoing, LUIE_CombatText_Point, LUIE_CombatText_Resource

    -- PC/Keyboard version
    local Settings = CombatText.SV
    for k, _ in pairs(Settings.panels) do
        local panel = _G[k] --- @type CombatTextPanels
        if panel then
            panel:SetMouseEnabled(state)
            panel:SetMovable(state)
            if _G[k .. "_Backdrop"] then
                _G[k .. "_Backdrop"]:SetHidden(not state)
            end
            if _G[k .. "_Label"] then
                _G[k .. "_Label"]:SetHidden(not state)
            end
            if state then
                -- Add grid snapping handler
                panel:SetHandler("OnMoveStop", function (self)
                    local left, top = self:GetLeft(), self:GetTop()
                    if LUIESV["Default"][GetDisplayName()]["$AccountWide"].snapToGrid_combatText then
                        left, top = LUIE.ApplyGridSnap(left, top, "combatText")
                        self:ClearAnchors()
                        self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
                    end
                    Settings.panels[k].x = left
                    Settings.panels[k].y = top
                end)
            end
        end
    end
end

-- Module initialization
function CombatText.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIESV.Default[GetDisplayName()]["$AccountWide"].CharacterSpecificSV
    if isCharacterSpecific then
        CombatText.SV = ZO_SavedVars:New(LUIE.SVName, LUIE.SVVer, "CombatText", CombatText.Defaults)
    else
        CombatText.SV = ZO_SavedVars:NewAccountWide(LUIE.SVName, LUIE.SVVer, "CombatText", CombatText.Defaults)
    end

    -- Migrate old string-based font styles to numeric constants (run once)
    if not LUIE.IsMigrationDone("combattext_fontstyles") then
        CombatText.SV.fontStyle = LUIE.MigrateFontStyle(CombatText.SV.fontStyle)
        LUIE.MarkMigrationDone("combattext_fontstyles")
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    CombatText.Enabled = true

    -- Apply Font
    CombatText.ApplyFont()

    -- Set panels to player configured settings
    local Combattext = GetControl("Combattext")
    for k, s in pairs(LUIE.CombatText.SV.panels) do
        if _G[k] ~= nil then
            _G[k]:ClearAnchors()
            _G[k]:SetAnchor(s.point, Combattext, s.relativePoint, s.offsetX, s.offsetY)
            _G[k]:SetDimensions(unpack(s.dimensions))
            _G[k]:SetHandler("OnMouseUp", CombatText.SavePosition)
            _G[k .. "_Label"]:SetFont(LUIE.CreateFontString(LUIE.CombatText.SV.fontFaceApplied, 26, LUIE.CombatText.SV.fontStyle))
            _G[k .. "_Label"]:SetText(panelTitles[k])
        else
            LUIE.CombatText.SV.panels[k] = nil
        end
    end

    -- Allow mouse resizing of panels
    LUIE_CombatText_Incoming:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
    LUIE_CombatText_Outgoing:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)

    -- Pool Manager
    CombatText.poolManager = LUIE.CombatTextPoolManager:New(CombatTextConstants.poolType) --- @type LuiExtended.CombatTextPoolManager

    -- Event Listeners (with ZO_CallbackObject support)
    CombatText.combatEventListener = LUIE.CombatTextCombatEventListener:New()
    CombatText.pointsAllianceListener = LUIE.CombatTextPointsAllianceEventListener:New()
    CombatText.pointsExperienceListener = LUIE.CombatTextPointsExperienceEventListener:New()
    CombatText.pointsChampionListener = LUIE.CombatTextPointsChampionEventListener:New()
    CombatText.resourcesPowerListener = LUIE.CombatTextResourcesPowerEventListener:New()
    CombatText.resourcesUltimateListener = LUIE.CombatTextResourcesUltimateEventListener:New()
    CombatText.resourcesPotionListener = LUIE.CombatTextResourcesPotionEventListener:New()
    CombatText.deathListener = LUIE.CombatTextDeathListener:New()

    -- Event Viewers (now receive listener references for callback registration)
    -- Memory optimization: Only instantiate the active animation viewer
    CombatText:CreateCombatEventViewer()
    CombatText.crowdControlEventViewer = LUIE.CombatTextCrowdControlEventViewer:New(CombatText.poolManager, CombatText.combatEventListener)
    CombatText.pointEventViewer = LUIE.CombatTextPointEventViewer:New(CombatText.poolManager, CombatText.pointsAllianceListener)
    CombatText.resourceEventViewer = LUIE.CombatTextResourceEventViewer:New(CombatText.poolManager, CombatText.resourcesPowerListener)
    CombatText.deathEventViewer = LUIE.CombatTextDeathViewer:New(CombatText.poolManager, CombatText.deathListener)

    -- Variable adjustment if needed
    if not LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCT then
        LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCT = 0
    end
    if LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCT < 2 then
        -- Set color for bleed damage to red
        CombatText.SV.colors.damage[DAMAGE_TYPE_BLEED] = CombatText.Defaults.colors.damage[DAMAGE_TYPE_BLEED]
    end
    if LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCT < 3 then
        -- Remove sneak drain from CT blacklist since it is no longer in the game
        if CombatText.SV.blacklist[20301] then
            CombatText.SV.blacklist[20301] = nil
        end
    end
    if LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCT < 4 then
        for k, v in pairs(LUIESV.Default[GetDisplayName()]) do
            for j, _ in pairs(v) do
                if j == "LuiExtendedCombatText" then
                    -- Don't want to throw any errors here so make sure these values exist before trying to remove them
                    if LUIESV.Default[GetDisplayName()][k] and LUIESV.Default[GetDisplayName()][k][j] then
                        LUIESV.Default[GetDisplayName()][k][j] = nil
                    end
                end
            end
        end
    end
    -- Increment so this doesn't occur again.
    LUIESV.Default[GetDisplayName()]["$AccountWide"].AdjustVarsCT = 4
end
