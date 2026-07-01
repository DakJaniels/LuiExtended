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
local ChatOutput = LUIE.ChatOutput

local eventManager = GetEventManager()
local moduleName = LUIE.name .. "CombatTextPanels"
local chatSystem = ZO_GetChatSystem()

-- Table pool: LUIE.GetCachedTable() / LUIE.RecycleTable() (see LuiExtended.lua; RecycleTable clears keys before pooling).

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
    CombatText.UpdatePanelPreviewLabel(panel)
end

--- @param panel Control
function CombatText.UpdatePanelPreviewLabel(panel)
    local preview = panel.preview
    if preview and preview.anchorLabel then
        preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", panel:GetLeft(), panel:GetTop()))
    end
end

--- @param panel Control
function CombatText.OnPanelPreviewMoveStart(panel)
    local key = moduleName .. panel:GetName()
    eventManager:RegisterForUpdate(key, 200, function ()
        CombatText.UpdatePanelPreviewLabel(panel)
    end)
end

--- Grid snap, then persist as CENTER offsets on `LUIE_CombatText` (matches menu x/y sliders).
--- @param panel Control
function CombatText.OnPanelDragStop(panel)
    local key = moduleName .. panel:GetName()
    eventManager:UnregisterForUpdate(key)

    local Settings = CombatText.SV
    local panelKey = panel:GetName()
    local s = Settings.panels[panelKey]
    if not s then
        return
    end

    local left, top = panel:GetLeft(), panel:GetTop()
    if LUIE.GetCoreAccountWideRawTable().snapToGrid_combatText then
        left, top = LUIE.ApplyGridSnap(left, top, "combatText")
        panel:ClearAnchors()
        panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    end

    local parent = LUIE_CombatText
    local pl, pt = parent:GetLeft(), parent:GetTop()
    local pw, ph = parent:GetDimensions()
    local pcx, pcy = pl + pw / 2, pt + ph / 2
    local w, h = panel:GetDimensions()
    local offsetX = left + w / 2 - pcx
    local offsetY = top + h / 2 - pcy

    panel:ClearAnchors()
    panel:SetAnchor(CENTER, parent, CENTER, offsetX, offsetY)

    s.point = CENTER
    s.relativePoint = CENTER
    s.offsetX = offsetX
    s.offsetY = offsetY
    s.x = nil
    s.y = nil

    CombatText.SavePosition(panel)
end

--- Convert legacy TOPLEFT-on-GuiRoot saves to CENTER offsets on `LUIE_CombatText` so x/y sliders match.
--- @param panelKey string
function CombatText.MigratePanelSaveToCenter(panelKey)
    local s = CombatText.SV.panels[panelKey]
    if not s or not (s.point == TOPLEFT and s.relativePoint == TOPLEFT) then
        return
    end
    local w, h = unpack(s.dimensions)
    local panel = _G[panelKey]
    if panel then
        w, h = panel:GetDimensions()
    end
    local parent = LUIE_CombatText
    local pl, pt = parent:GetLeft(), parent:GetTop()
    local pw, ph = parent:GetDimensions()
    local pcx, pcy = pl + pw / 2, pt + ph / 2
    local left, top = s.offsetX, s.offsetY
    s.offsetX = left + w / 2 - pcx
    s.offsetY = top + h / 2 - pcy
    s.point = CENTER
    s.relativePoint = CENTER
    s.x = nil
    s.y = nil
    CombatText.ReanchorPanelFromSaved(panelKey)
end

--- Apply saved anchors for one panel (`CENTER` on `LUIE_CombatText`, or legacy `TOPLEFT` on `GuiRoot`).
--- @param panelKey string
function CombatText.ReanchorPanelFromSaved(panelKey)
    local s = CombatText.SV.panels[panelKey]
    local panel = _G[panelKey]
    if not panel or not s then
        return
    end
    panel:ClearAnchors()
    if s.point == TOPLEFT and s.relativePoint == TOPLEFT then
        panel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, s.offsetX, s.offsetY)
    else
        panel:SetAnchor(s.point, LUIE_CombatText, s.relativePoint, s.offsetX, s.offsetY)
    end
    CombatText.UpdatePanelPreviewLabel(panel)
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
    for k, s in pairs(Settings.panels) do
        local panel = _G[k]
        if panel then
            CombatText.ReanchorPanelFromSaved(k)
            panel:SetDimensions(unpack(s.dimensions))
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
    ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_CLEARED), listRef), true)
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
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_ID), icon, id, name, listRef), true)
        else
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_FAILED), input, listRef), true)
        end
    else
        if input ~= "" then
            list[input] = true
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_ADDED_NAME), input, listRef), true)
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
        ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_ID), icon, id, name, listRef), true)
    else
        if input ~= "" then
            list[input] = nil
            chatSystem:Maximize()
            chatSystem.primaryContainer:FadeIn()
            ChatOutput:Print(zo_strformat(GetString(LUIE_STRING_CUSTOM_LIST_REMOVED_NAME), input, listRef), true)
        end
    end
end

--- Alpha (0–1) for floating combat text labels/icons from OOC/IC saved values.
--- @return number
function CombatText.GetTextAlpha()
    local common = CombatText.SV.common
    local oocAlpha = common.oocAlpha or common.transparencyValue or 100
    local incAlpha = common.incAlpha or common.transparencyValue or 100
    local percent = IsUnitInCombat("player") and incAlpha or oocAlpha
    return percent / 100
end

function CombatText.ApplyFont()
    local fontData = LUIE.Font.FetchMedia(LUIE.CombatText.SV.fontFace)
    if not fontData or fontData == "" then
        ChatOutput:Print(GetString(LUIE_STRING_ERROR_FONT), true)
        fontData = "$(MEDIUM_FONT)"
    end
    -- Cache the resolved data + kind so the per-event hot path avoids a media lookup.
    -- Named fonts are applied as a token; custom slug faces compose per size.
    LUIE.CombatText.SV.fontFaceApplied = fontData
    LUIE.CombatText.fontIsNamed = LUIE.Font.IsNamedData(fontData)
    -- Reset the per-size font-string cache (face path). Combat fires PrepareLabel on
    -- every event across a small bounded set of sizes, so memoizing the composed
    -- "face|size|style" strings keeps per-event allocation (GC churn) at zero.
    LUIE.CombatText.fontStringCache = {}
end

--- Create or recreate the combat event viewer based on animation type<br>
--- Uses instance-based callback system via eventListener reference
function CombatText.CreateCombatEventViewer()
    if not CombatText.Enabled or not CombatText.poolManager or not CombatText.combatEventListener then
        return
    end

    -- Remove old combat event viewer if it exists.
    -- ZO_CallbackObject does NOT auto-clean callbacks when the owning object loses references;
    -- closures registered in viewer:Initialize close over `self` and stay pinned in the
    -- listener's callbackRegistry until explicitly unregistered. Failing to Destroy() leaks
    -- the old viewer (including its eventBuffer / activeControls) and stacks an extra
    -- early-returning closure on every combat event for each animation-type change.
    if CombatText.combatEventViewer then
        CombatText.combatEventViewer:Destroy()
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
            local preview = panel.preview or panel:GetNamedChild("_Preview")
            if preview then
                preview:SetHidden(not state)
            end
            if not state then
                eventManager:UnregisterForUpdate(moduleName .. k)
            end
        end
    end
end

-- Module initialization
function CombatText.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    if isCharacterSpecific then
        CombatText.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.CombatText, LUIE.SVVer, nil, CombatText.Defaults, LUIE.SavedVarsProfile)
    else
        CombatText.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.CombatText, LUIE.SVVer, nil, CombatText.Defaults, LUIE.SavedVarsProfile)
    end

    CombatText.RefreshMessageFormatDefaultsTable()
    CombatText.NormalizeStoredMessageFormats()

    -- Migrate old string-based font styles to numeric constants (run once)
    -- Migrate font style (string/display/nil -> valid 0-7); run once per account
    if not LUIE.IsMigrationDone("combattext_fontstyles_v2") then
        CombatText.SV.fontStyle = LUIE.MigrateFontStyle(CombatText.SV.fontStyle)
        LUIE.MarkMigrationDone("combattext_fontstyles_v2")
    end

    local common = CombatText.SV.common
    if common.oocAlpha == nil then
        common.oocAlpha = common.transparencyValue or CombatText.Defaults.common.oocAlpha
    end
    if common.incAlpha == nil then
        common.incAlpha = common.transparencyValue or CombatText.Defaults.common.incAlpha
    end

    if ZO_IsConsoleOrGameCoreUI() and CombatText.SV.animation then
        CombatText.SV.animation.colorIconFrame = false
    end

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    CombatText.Enabled = true

    -- Apply Font
    CombatText.ApplyFont()

    -- Set panels to player configured settings
    for k, s in pairs(LUIE.CombatText.SV.panels) do
        if _G[k] ~= nil then
            local panel = _G[k]
            panel:SetDimensions(unpack(s.dimensions))
            CombatText.ReanchorPanelFromSaved(k)
            panel:SetHandler("OnMouseUp", CombatText.SavePosition)
            local preview = panel:GetNamedChild("_Preview")
            if preview then
                panel.preview = preview --- @type BackdropControl
                panel.preview.anchorLabel = preview:GetNamedChild("_AnchorLabel")
                panel.preview.anchorLabelBg = preview:GetNamedChild("_AnchorLabelBg")
                panel.preview.anchorTexture = preview:GetNamedChild("_AnchorTexture")
            end
            local panelLabelFont = LUIE.CombatText.fontIsNamed and LUIE.CombatText.SV.fontFaceApplied or LUIE.CreateFontString(LUIE.CombatText.SV.fontFaceApplied, 26, LUIE.CombatText.SV.fontStyle)
            _G[k .. "_Label"]:SetFont(panelLabelFont)
            _G[k .. "_Label"]:SetText(panelTitles[k])
            CombatText.UpdatePanelPreviewLabel(panel)
            if preview then
                preview:SetHidden(not CombatText.SV.unlocked)
            end
        else
            LUIE.CombatText.SV.panels[k] = nil
        end
    end

    -- Allow mouse resizing of panels
    LUIE_CombatText_Incoming:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)
    LUIE_CombatText_Outgoing:SetResizeHandleSize(MOUSE_CURSOR_RESIZE_NS)

    LUIE.RefreshMoverOverlayFonts()

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

    -- Wire combat state (IN_COMBAT/OUT_COMBAT) into point viewer (fired by combatEventListener)
    CombatText.combatEventListener:RegisterCallback(CombatTextConstants.eventType.POINT, function (...)
        CombatText.pointEventViewer:OnEvent(...)
    end)
    -- Point viewer only registered on pointsAllianceListener in Initialize; champion and experience
    -- listeners are separate objects — forward their POINT callbacks here too.
    CombatText.pointsExperienceListener:RegisterCallback(CombatTextConstants.eventType.POINT, function (...)
        CombatText.pointEventViewer:OnEvent(...)
    end)
    CombatText.pointsChampionListener:RegisterCallback(CombatTextConstants.eventType.POINT, function (...)
        CombatText.pointEventViewer:OnEvent(...)
    end)
    -- Wire ultimate/potion ready into resource viewer (fired by resourcesUltimateListener, resourcesPotionListener)
    CombatText.resourcesUltimateListener:RegisterCallback(CombatTextConstants.eventType.RESOURCE, function (...)
        CombatText.resourceEventViewer:OnEvent(...)
    end)
    CombatText.resourcesPotionListener:RegisterCallback(CombatTextConstants.eventType.RESOURCE, function (...)
        CombatText.resourceEventViewer:OnEvent(...)
    end)

    -- Variable adjustment if needed
    local coreAw = LUIE.GetCoreAccountWideRawTable()
    if not coreAw.AdjustVarsCT then
        coreAw.AdjustVarsCT = 0
    end
    if coreAw.AdjustVarsCT < 2 then
        -- Set color for bleed damage to red
        CombatText.SV.colors.damage[DAMAGE_TYPE_BLEED] = CombatText.Defaults.colors.damage[DAMAGE_TYPE_BLEED]
    end
    if coreAw.AdjustVarsCT < 3 then
        -- Remove sneak drain from CT blacklist since it is no longer in the game
        if CombatText.SV.blacklist[20301] then
            CombatText.SV.blacklist[20301] = nil
        end
    end
    if coreAw.AdjustVarsCT < 4 then
        local profile = LUIE.SavedVarsProfile or LUIE.LegacySavedVarsProfile
        local displayRoot = _G[LUIE.SVName][profile][GetDisplayName()]
        if displayRoot then
            for k, v in pairs(displayRoot) do
                for j, _ in pairs(v) do
                    if j == "LuiExtendedCombatText" then
                        -- Don't want to throw any errors here so make sure these values exist before trying to remove them
                        if displayRoot[k] and displayRoot[k][j] then
                            displayRoot[k][j] = nil
                        end
                    end
                end
            end
        end
    end
    if coreAw.AdjustVarsCT < 5 then
        if CombatText.SV.common.inferResourceDrainOnCast == nil then
            CombatText.SV.common.inferResourceDrainOnCast = CombatText.Defaults.common.inferResourceDrainOnCast
        end
    end
    -- Increment so this doesn't occur again.
    coreAw.AdjustVarsCT = 5
end
