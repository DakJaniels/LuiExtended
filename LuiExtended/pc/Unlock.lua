--- @diagnostic disable: duplicate-set-field, duplicate-doc-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local GridOverlay = LUIE.GridOverlay
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER
local windowManager = GetWindowManager()
-- -----------------------------------------------------------------------------

--- `_Preview` overlay or Unlock-created backdrop; optional labels depend on context (`Unlock` vs UnitFrames XML).
--- @class LUIE_PositionableTLWPreview : BackdropControl
--- @field coordLabel LabelControl|nil
--- @field anchorLabel LabelControl|nil
--- @field anchorTexture TextureControl|nil

--- TLW used by Unlock movers and UnitFrames custom roots (`LUIE.SV[customPositionAttr]` position persistence).
--- @class LUIE_PositionableTopLevelWindow : TopLevelWindow
--- @field customPositionAttr string
--- @field hudSceneFragment ZO_HUDFadeSceneFragment|nil
--- @field preview LUIE_PositionableTLWPreview|nil
--- @field previewLabel LabelControl|nil

--- Runtime control with a stable SV key when `GetName()` is not used (e.g. ACT layout anchor).
--- @class LUIE_UnlockPositionableControl : Control
--- @field luiUnlockPositionAttr string|nil

--- @class LUIE.Unlock : table
--- @field frameMoverEnabled boolean Flag indicating if frame movers are currently enabled
--- @field movers table Table of created mover frames
--- @field defaultPanels table Table of UI elements to unlock for moving
local Unlock =
{
    frameMoverEnabled = false,
    movers = {},
    dynamicEventsQuestHookInstalled = false,
    unlockPositionHooksInstalled = false,
    activeCombatTipsAnchor = nil,
    defaultPanels =
    {
        [ZO_HUDInfamyMeter] = { GetString(LUIE_STRING_DEFAULT_FRAME_INFAMY_METER) },
        [ZO_HUDTelvarMeter] = { GetString(LUIE_STRING_DEFAULT_FRAME_TEL_VAR_METER) },
        [ZO_HUDDaedricEnergyMeter] = { GetString(LUIE_STRING_DEFAULT_FRAME_VOLENDRUNG_METER) },
        [ZO_HUDEquipmentStatus] = { GetString(LUIE_STRING_DEFAULT_FRAME_EQUIPMENT_STATUS), 64, 64 },
        [ZO_FocusedQuestTrackerPanel] = { GetString(LUIE_STRING_DEFAULT_FRAME_QUEST_LOG), nil, 200 },
        [ZO_BattlegroundHUDFragmentTopLevel] = { GetString(LUIE_STRING_DEFAULT_FRAME_BATTLEGROUND_SCORE), nil, 200 },
        [ZO_ActionBar1] = { GetString(LUIE_STRING_DEFAULT_FRAME_ACTION_BAR) },
        [ZO_Subtitles] = { GetString(LUIE_STRING_DEFAULT_FRAME_SUBTITLES), 256, 80 },
        [ZO_ObjectiveCaptureMeter] = { GetString(LUIE_STRING_DEFAULT_FRAME_OBJECTIVE_METER), 128, 128 },
        [ZO_PlayerToPlayerAreaPromptContainer] = { GetString(LUIE_STRING_DEFAULT_FRAME_PLAYER_INTERACTION), nil, 30 },
        [ZO_SynergyTopLevelContainer] = { GetString(LUIE_STRING_DEFAULT_FRAME_SYNERGY), 256, 80 },
        [ZO_CompassFrame] = { GetString(LUIE_STRING_DEFAULT_FRAME_COMPASS) },                                        -- Needs custom template applied
        [ZO_PlayerProgress] = { GetString(LUIE_STRING_DEFAULT_FRAME_PLAYER_PROGRESS) },                              -- Needs custom template applied
        [ZO_EndDunHUDTrackerContainer] = { GetString(LUIE_STRING_DEFAULT_FRAME_ENDLESS_DUNGEON_TRACKER), 230, 100 }, -- Needs custom template applied
        [ZO_ReticleContainerInteract] = { GetString(LUIE_STRING_DEFAULT_FRAME_RETICLE_CONTAINER_INTERACT) },
        [ZO_RamTopLevel] = { GetString(SI_SIEGETYPE3), 290, 110 },
        [ZO_AdvZoneHUDTrackerContainer] = { "Dynamic Events Tracker", 230, 100 }, -- Needs custom template applied
        [ZO_LootHistoryControl_Keyboard] = { GetString(LUIE_STRING_DEFAULT_FRAME_LOOT_HISTORY), 280, 400 },
        [ZO_TutorialHudInfoTipKeyboard] = { GetString(LUIE_STRING_DEFAULT_FRAME_TUTORIALS) },
        [ZO_AlertTextNotification] = { GetString(LUIE_STRING_DEFAULT_FRAME_ALERTS), 600, 56 },
        [ZO_AdvZoneHUD_TopLevel] = { "NightMarket Favor counter" },
    }
}

-- -----------------------------------------------------------------------------
-- Grid Snap Functions
-- -----------------------------------------------------------------------------

--- Snaps a position to the nearest grid point
--- @param position integer The position to snap
--- @param gridSize integer The size of the grid
--- @return integer @The snapped position
function Unlock.SnapToGrid(position, gridSize)
    -- Round down
    position = zo_floor(position)

    -- Return value to closest grid point
    if (position % gridSize >= gridSize / 2) then
        return position + (gridSize - (position % gridSize))
    else
        return position - (position % gridSize)
    end
end

--- Applies grid snapping to a pair of coordinates based on the specified grid type
--- @param left integer The x coordinate
--- @param top integer The y coordinate
--- @param gridType string The type of grid to use ("default", "unitFrames", "buffs")
--- @return integer x
--- @return integer y
function Unlock.ApplyGridSnap(left, top, gridType)
    local gridSetting = "snapToGrid" .. (gridType and ("_" .. gridType) or "")
    local sizeSetting = "snapToGridSize_default"

    if LUIE.SV[gridSetting] then
        local gridSize = LUIE.SV[sizeSetting] or 10
        left = Unlock.SnapToGrid(left, gridSize)
        top = Unlock.SnapToGrid(top, gridSize)
    end
    return left, top
end

-- -----------------------------------------------------------------------------
-- Element Handling Functions
-- -----------------------------------------------------------------------------

--- Re-anchors a moved default UI frame after ZOS applies templates or tracker layout.
--- @param frameName string Saved-vars key (`element:GetName()` from `defaultPanels`).
function Unlock.ApplySavedUnlockFramePosition(frameName)
    local frameData = LUIE.SV[frameName]
    if not frameData then
        return
    end
    local frame = _G[frameName]
    if not frame then
        return
    end
    local x, y = frameData[1], frameData[2]
    if x == nil or y == nil then
        return
    end
    x, y = Unlock.ApplyGridSnap(x, y, "default")
    frame:ClearAnchors()
    frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y, ANCHOR_CONSTRAINS_XY)
end

--- Width/height for `ZO_AdvZoneHUD_TopLevel` that match the visible icon + score row (see ZO_AdventureZoneHUD:OnPlatformStyleChanged),
--- not the Telvar meter and not the XML full-screen stretch anchors on the top-level control.
--- @return number width
--- @return number height
local function GetAdvZoneHUDTightDimensions()
    local icon = ZO_AdvZoneHUD_TopLevelPlayerFactionIcon
    local label = ZO_AdvZoneHUD_TopLevelPlayerScoreLabel
    if not icon or not label then
        return 120, 44
    end
    local iw, ih = icon:GetWidth(), icon:GetHeight()
    local lw, lh = label:GetWidth(), label:GetHeight()
    if iw <= 0 or ih <= 0 or lw <= 0 or lh <= 0 then
        return 120, 44
    end
    return lw + iw + 5, zo_max(ih, lh)
end

--- `ZO_AdvZoneHUD_TopLevel` uses TOPLEFT + BOTTOMRIGHT anchors in XML (`AdventureZoneHUD.xml`), so it fills the screen until anchors are cleared.
--- Without saved coordinates, `SetElementPosition` never runs `SetAnchor`, `SetWidth`/`SetHeight` cannot shrink the stretch layout, and the mover initializes fullscreen.
--- Replace stretch with a single TOPLEFT anchored where the icon + score cluster sits (child positions relative to parent, see `ZO_AdventureZoneHUD:OnPlatformStyleChanged`).
--- @param tightW number
--- @param tightH number
local function ApplyAdvZoneHUDDefaultAnchorForMover(tightW, tightH)
    local element = ZO_AdvZoneHUD_TopLevel
    local icon = ZO_AdvZoneHUD_TopLevelPlayerFactionIcon
    local label = ZO_AdvZoneHUD_TopLevelPlayerScoreLabel
    if not element or not icon or not label then
        return
    end
    local parentLeft = element:GetLeft()
    local parentTop = element:GetTop()
    local contentLeft = zo_min(icon:GetLeft(), label:GetLeft())
    local contentTop = zo_min(icon:GetTop(), label:GetTop())
    element:ClearAnchors()
    element:SetWidth(tightW)
    element:SetHeight(tightH)
    element:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, parentLeft + contentLeft, parentTop + contentTop, ANCHOR_CONSTRAINS_XY)
end

--- Helper function to adjust an element
--- @param element Control The element to be adjusted
--- @param config {[1]:string, [2]:number?, [3]:number?} The table containing adjustment values
function Unlock.AdjustElement(element, config)
    element:SetClampedToScreen(true)
    local width, height = config[2], config[3]
    if element == ZO_AdvZoneHUD_TopLevel then
        width, height = GetAdvZoneHUDTightDimensions()
    end
    if width then element:SetWidth(width) end
    if height then element:SetHeight(height) end
end

function Unlock.ApplyDynamicEventsTrackerToQuest()
    if not LUIE.SV[ZO_FocusedQuestTrackerPanel:GetName()] then
        return
    end
    ZO_DynamicEventsTracker_TL:ClearAnchors()
    ZO_DynamicEventsTracker_TL:SetAnchor(BOTTOMRIGHT, ZO_FocusedQuestTrackerPanel, TOPRIGHT, 0, 0, ANCHOR_CONSTRAINS_XY)
end

function Unlock.RegisterDynamicEventsQuestAnchorHook()
    if Unlock.dynamicEventsQuestHookInstalled then
        return
    end
    ZO_PostHook(ZO_DynamicEventsTracker, "RefreshAnchors", function ()
        Unlock.ApplyDynamicEventsTrackerToQuest()
    end)
    Unlock.dynamicEventsQuestHookInstalled = true
end

function Unlock.ApplyActiveCombatTipsAnchors()
    local frameName = "LUIE_ActiveCombatTipsAnchor"
    if LUIE.SV["ZO_ActiveCombatTipsTip"] and not LUIE.SV[frameName] then
        LUIE.SV[frameName] = LUIE.SV["ZO_ActiveCombatTipsTip"]
        LUIE.SV["ZO_ActiveCombatTipsTip"] = nil
    end
    if not Unlock.activeCombatTipsAnchor then
        --- @type LUIE_UnlockPositionableControl
        local anchor = windowManager:CreateControl(nil, GuiRoot, CT_CONTROL)
        anchor.luiUnlockPositionAttr = frameName
        anchor:SetDimensions(250, 20)
        anchor:SetDrawLayer(DL_CONTROLS)
        anchor:SetAnchor(CENTER, GuiRoot, BOTTOM, 0, -250, ANCHOR_CONSTRAINS_XY)
        Unlock.activeCombatTipsAnchor = anchor
        if not Unlock.defaultPanels[anchor] then
            Unlock.defaultPanels[anchor] = { GetString(LUIE_STRING_DEFAULT_FRAME_ACTIVE_COMBAT_TIPS), 256, 80 }
        end
    end
    local anchor = Unlock.activeCombatTipsAnchor
    if not anchor then
        return
    end

    local frameData = LUIE.SV[frameName]
    if frameData and frameData[1] ~= nil and frameData[2] ~= nil then
        local x, y = Unlock.ApplyGridSnap(frameData[1], frameData[2], "default")
        anchor:ClearAnchors()
        anchor:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y, ANCHOR_CONSTRAINS_XY)
    else
        anchor:ClearAnchors()
        anchor:SetAnchor(CENTER, GuiRoot, BOTTOM, 0, -250, ANCHOR_CONSTRAINS_XY)
    end

    ZO_ActiveCombatTipsTip:ClearAnchors()
    ZO_ActiveCombatTipsTip:SetAnchor(CENTER, anchor, CENTER, 0, 0, ANCHOR_CONSTRAINS_XY)

    ZO_ActiveCombatTips:SetDrawTier(DT_HIGH)
    ZO_ActiveCombatTipsTip:SetDrawTier(DT_HIGH)
    ZO_ActiveCombatTipsTip:SetDrawLayer(DL_OVERLAY)
    if ZO_ActiveCombatTipsTipTipText then
        ZO_ActiveCombatTipsTipTipText:SetDrawTier(DT_HIGH)
        ZO_ActiveCombatTipsTipTipText:SetDrawLayer(DL_OVERLAY)
    end
end

function Unlock.RegisterUnlockPositionHooks()
    if Unlock.unlockPositionHooksInstalled then
        return
    end

    ZO_PostHook(ZO_HUDTracker_Base, "RefreshAnchors", function (tracker)
        if tracker.container then
            Unlock.ApplySavedUnlockFramePosition(tracker.container:GetName())
        end
    end)

    ZO_PostHook(COMPASS_FRAME, "ApplyStyle", function ()
        Unlock.ApplySavedUnlockFramePosition("ZO_CompassFrame")
    end)


    ZO_PostHook(PLAYER_PROGRESS_BAR, "RefreshTemplate", function ()
        Unlock.ApplySavedUnlockFramePosition("ZO_PlayerProgress")
    end)

    ZO_PostHook(ACTIVE_COMBAT_TIP_SYSTEM, "ApplyStyle", function ()
        Unlock.ApplyActiveCombatTipsAnchors()
    end)
    ZO_ReticleContainer:SetDrawLayer(DL_TEXT)
    Unlock.unlockPositionHooksInstalled = true
end

local ALERT_FRAME_SV_KEY = "ZO_AlertTextNotification"

--- @param alignment number 1 = left, 2 = center, 3 = right
--- @return integer
local function GetAlertAlignmentPoint(alignment)
    if alignment == 1 then
        return TOPLEFT
    elseif alignment == 2 then
        return TOP
    end
    return TOPRIGHT
end

--- @param alignment number 1 = left, 2 = center, 3 = right
--- @return integer
local function GetAlertTextHorizontalAlignment(alignment)
    if alignment == 1 then
        return TEXT_ALIGN_LEFT
    elseif alignment == 2 then
        return TEXT_ALIGN_CENTER
    end
    return TEXT_ALIGN_RIGHT
end

--- @return number
local function GetResolvedAlertFrameAlignment()
    local alignment = LUIE.SV.AlertFrameAlignment or LUIE.Defaults.AlertFrameAlignment or 3
    if alignment < 1 or alignment > 3 then
        alignment = 3
    end
    return alignment
end

--- Match `ZO_AlertLine` wrap to LUIE alignment (ZOS template defaults to RIGHT in XML).
--- @param control LabelControl
--- @param alignment number|nil
function Unlock.ApplyAlertLineTextAlignment(control, alignment)
    if not control then
        return
    end
    alignment = alignment or GetResolvedAlertFrameAlignment()
    control:SetHorizontalAlignment(GetAlertTextHorizontalAlignment(alignment))
    local parent = control:GetParent()
    if parent then
        local point = GetAlertAlignmentPoint(alignment)
        control:ClearAnchors()
        control:SetAnchor(point, parent, point, 0, 0, ANCHOR_CONSTRAINS_XY)
    end
end

--- Wrap `ZO_FadingControlBuffer` template setup so each new alert line gets alignment.
--- @param alertMessages ZO_AlertText_Keyboard|ZO_AlertText_Gamepad|nil
local function WrapAlertFadingControlBufferTemplates(alertMessages)
    if not alertMessages or not alertMessages.alerts then
        return
    end
    local templates = alertMessages.alerts.templates
    if not templates then
        return
    end
    for _, templateData in pairs(templates) do
        if templateData.setup and not templateData._luiAlertSetupWrapped then
            local originalSetup = templateData.setup
            templateData.setup = function (control, data)
                originalSetup(control, data)
                Unlock.ApplyAlertLineTextAlignment(control)
            end
            templateData._luiAlertSetupWrapped = true
        end
    end
end

--- @param alertMessages ZO_AlertText_Keyboard|ZO_AlertText_Gamepad|nil
local function RefreshActiveAlertLineAlignment(alertMessages)
    if not alertMessages or not alertMessages.alerts then
        return
    end
    local alignment = GetResolvedAlertFrameAlignment()
    local activeEntries = alertMessages.alerts.activeEntries
    if not activeEntries then
        return
    end
    for _, entryControl in ipairs(activeEntries) do
        if entryControl.activeLines then
            for _, lineControl in ipairs(entryControl.activeLines) do
                Unlock.ApplyAlertLineTextAlignment(lineControl, alignment)
            end
        end
    end
end

function Unlock.InstallAlertTextSetupHooks()
    if Unlock.alertTextSetupHooksInstalled then
        return
    end
    WrapAlertFadingControlBufferTemplates(ALERT_MESSAGES)
    WrapAlertFadingControlBufferTemplates(ALERT_MESSAGES_GAMEPAD)
    Unlock.alertTextSetupHooksInstalled = true
end

--- Default screen anchor for the alert TLW when no custom unlock position is saved.
--- @param alignment number
--- @return integer point
--- @return integer relativePoint
--- @return integer offsetX
--- @return integer offsetY
local function GetAlertDefaultScreenAnchor(alignment)
    local point = GetAlertAlignmentPoint(alignment)
    local offsetX = 0
    if alignment == 1 then
        offsetX = 15
    elseif alignment == 3 then
        offsetX = -15
    end
    return point, point, offsetX, 15
end

--- Reposition scrolling alert lines inside the notification frame (Phinix / Azurah method).
--- @param alertFrame Control
--- @param alignment number
function Unlock.ApplyAlertTextFadingBufferAnchor(alertFrame, alignment)
    if not alertFrame then
        return
    end
    ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, " ")
    local alertText = alertFrame:GetChild(1)
    if not alertText then
        return
    end
    --- @diagnostic disable-next-line: undefined-field
    if not alertText.fadingControlBuffer then
        return
    end
    local point = GetAlertAlignmentPoint(alignment)
    --- @diagnostic disable-next-line: undefined-field
    alertText.fadingControlBuffer.anchor = ZO_Anchor:New(point, alertFrame, point)
end

--- Apply `LUIE.SV.AlertFrameAlignment` to keyboard/gamepad alert notification frames.
function Unlock.ApplyAlertFrameAlignment()
    if LUIE.SV.HideAlertFrame then
        return
    end
    Unlock.InstallAlertTextSetupHooks()
    local alignment = GetResolvedAlertFrameAlignment()

    local hasCustomPosition = LUIE.SV[ALERT_FRAME_SV_KEY] ~= nil
    local alertFrames = { ZO_AlertTextNotification, ZO_AlertTextNotificationGamepad }

    for _, alertFrame in ipairs(alertFrames) do
        if alertFrame then
            if not hasCustomPosition then
                local point, relativePoint, offsetX, offsetY = GetAlertDefaultScreenAnchor(alignment)
                alertFrame:ClearAnchors()
                alertFrame:SetAnchor(point, GuiRoot, relativePoint, offsetX, offsetY, ANCHOR_CONSTRAINS_XY)
            end
            Unlock.ApplyAlertTextFadingBufferAnchor(alertFrame, alignment)
        end
    end

    RefreshActiveAlertLineAlignment(ALERT_MESSAGES)
    RefreshActiveAlertLineAlignment(ALERT_MESSAGES_GAMEPAD)
end

--- Helper function to set the anchor of an element
--- @param element Control The element to set the anchor for
--- @param frameName string The name of the frame associated with the element
function Unlock.SetAnchor(element, frameName)
    local frameData = LUIE.SV[frameName]
    if not frameData then return end

    local x, y = frameData[1], frameData[2]

    -- Apply grid snapping if enabled
    if x ~= nil and y ~= nil then
        x, y = Unlock.ApplyGridSnap(x, y, "default")
        element:ClearAnchors()
        element:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y, ANCHOR_CONSTRAINS_XY)
    end

    -- Fix the Objective Capture Meter fill alignment.
    if element == ZO_ObjectiveCaptureMeter then
        ZO_ObjectiveCaptureMeterFrame:SetAnchor(BOTTOM, ZO_ObjectiveCaptureMeter, BOTTOM, 0, 0, ANCHOR_CONSTRAINS_XY)
    end

    if element == ZO_AlertTextNotification and x ~= nil and y ~= nil then
        local alignment = LUIE.SV.AlertFrameAlignment or LUIE.Defaults.AlertFrameAlignment or 3
        Unlock.ApplyAlertTextFadingBufferAnchor(ZO_AlertTextNotification, alignment)
        if ZO_AlertTextNotificationGamepad then
            Unlock.ApplyAlertTextFadingBufferAnchor(ZO_AlertTextNotificationGamepad, alignment)
        end
    end

    if element == ZO_FocusedQuestTrackerPanel then
        Unlock.ApplyDynamicEventsTrackerToQuest()
    end
end

-- -----------------------------------------------------------------------------
-- Mover Creation and Management
-- -----------------------------------------------------------------------------

--- Saved-vars / mover key for unlock panels (ZOS frames use `GetName()`; addon panels may use `luiUnlockPositionAttr`).
--- @param element Control|LUIE_UnlockPositionableControl
--- @return string
function Unlock.GetUnlockPositionAttr(element)
    --- @type LUIE_UnlockPositionableControl
    local positionable = element
    return positionable.luiUnlockPositionAttr or element:GetName()
end

--- Top-level mover window name (addon-owned TLW; not the ZOS frame being repositioned).
--- `$(parent)_*` children require a non-empty parent name — `CreateTopLevelWindow(nil)` yields duplicate `_Preview`.
--- @param element Control
--- @return string
local function GetUnlockMoverTopLevelName(element)
    return "LUIE_UnlockMover_" .. Unlock.GetUnlockPositionAttr(element)
end

--- Place unlock mover overlay at the element's on-screen position (not its anchor chain).
--- ZOS HUD such as `ZO_HUDEquipmentStatus` anchors to the quickslot/action bar; copying `GetAnchor()`
--- ties other movers to the bar when it is repositioned.
--- @param mover TopLevelWindow
--- @param element Control
function Unlock.AnchorMoverToElementScreenPosition(mover, element)
    mover:ClearAnchors()
    mover:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, element:GetLeft(), element:GetTop(), ANCHOR_CONSTRAINS_XY)
end

--- One-time sync of all mover overlays to current HUD screen rects (e.g. when enabling frame movers). Not used after a single drag.
function Unlock.RefreshMoverScreenPositions()
    if not Unlock.frameMoverEnabled then
        return
    end
    for element, _ in pairs(Unlock.defaultPanels) do
        local mover = Unlock.movers[Unlock.GetUnlockPositionAttr(element)]
        if mover then
            Unlock.AnchorMoverToElementScreenPosition(mover, element)
        end
    end
end

--- Helper function to create a coordinate label for mover frames
--- @param parent Control The parent control for the label
--- @param positionText string The text to display in the label
--- @return LabelControl label The created label
function Unlock.CreateCoordinateLabel(parent, positionText)
    local label = parent.coordLabel
    if not label then
        label = parent:CreateControl("$(parent)_AnchorLabel", CT_LABEL)
        label:SetFont(LUIE.GetPositionLabelFont())
        label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        label:SetVerticalAlignment(TEXT_ALIGN_TOP)
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        label:SetAnchor(TOPLEFT, parent, TOPLEFT, 2, 2, ANCHOR_CONSTRAINS_XY)
        label:SetColor(1, 1, 0, 1)
        label:SetDrawLayer(DL_OVERLAY)
        label:SetDrawLevel(5)
        label:SetDrawTier(DT_MEDIUM)

        local bg = label:CreateControl("$(parent)_Bg", CT_BACKDROP)
        bg:SetCenterColor(0, 0, 0, 1)
        bg:SetEdgeColor(0, 0, 0, 1)
        bg:SetEdgeTexture("", 8, 1, 1, 1)
        bg:SetDrawLayer(DL_BACKGROUND)
        bg:SetAnchorFill(label)
        bg:SetDrawLayer(DL_OVERLAY)
        bg:SetDrawLevel(5)
        bg:SetDrawTier(DT_MEDIUM)
        parent.coordLabel = label
    end
    label:SetText(positionText)
    return label
end

--- Helper function to create a top-level window (mover)
--- @param element Control The element to create the top-level window for
--- @param config {[1]:string, [2]:number?, [3]:number?} The table containing window configuration values
--- @return LUIE_PositionableTopLevelWindow tlw The created top-level window
function Unlock.CreateTopLevelWindow(element, config)
    local attr = Unlock.GetUnlockPositionAttr(element)
    local moverName = GetUnlockMoverTopLevelName(element)
    --- @type LUIE_PositionableTopLevelWindow
    local tlw = Unlock.movers[attr] or _G[moverName]
    if not tlw then
        tlw = windowManager:CreateTopLevelWindow(moverName)
        tlw:SetDrawTier(DT_MEDIUM)
        tlw:SetClampedToScreen(true)
        tlw:SetMouseEnabled(false)
        tlw:SetMovable(false)
        tlw:SetHidden(true)
        tlw.customPositionAttr = attr
    end

    Unlock.AnchorMoverToElementScreenPosition(tlw, element)
    tlw:SetDimensions(element:GetWidth(), element:GetHeight())

    if not tlw.preview then
        tlw.preview = tlw:CreateControl("$(parent)_Preview", CT_BACKDROP)
        tlw.preview:SetCenterColor(0, 0, 0, 0.4)
        tlw.preview:SetEdgeColor(0, 0, 0, 0.6)
        tlw.preview:SetEdgeTexture("", 8, 1, 1, 1)
        tlw.preview:SetDrawLayer(DL_BACKGROUND)
        tlw.preview:SetAnchorFill(tlw)
        tlw.preview:SetDrawLayer(DL_OVERLAY)
        tlw.preview:SetDrawLevel(5)
        tlw.preview:SetDrawTier(DT_MEDIUM)
    end

    local positionText = "Default"
    if LUIE.SV[attr] then
        local x = LUIE.SV[attr][1] or 0
        local y = LUIE.SV[attr][2] or 0
        positionText = string.format("%d, %d | %s", x, y, config[1])
    else
        positionText = string.format("Default | %s", config[1])
    end
    Unlock.CreateCoordinateLabel(tlw.preview, positionText)

    if not tlw._luiUnlockMoveLabelHandlers then
        --- @param self LUIE_PositionableTopLevelWindow
        local function OnMoveStart(self)
            eventManager:RegisterForUpdate("LUIE_UnlockMoveUpdate", 200, function ()
                if self.preview and self.preview.coordLabel then
                    self.preview.coordLabel:SetText(string.format("%d, %d | %s", self:GetLeft(), self:GetTop(), config[1]))
                end
            end)
        end

        --- @param self LUIE_PositionableTopLevelWindow
        local function OnMoveStopLabelOnly(self)
            eventManager:UnregisterForUpdate("LUIE_UnlockMoveUpdate")
            if self.preview and self.preview.coordLabel then
                self.preview.coordLabel:SetText(string.format("%d, %d | %s", self:GetLeft(), self:GetTop(), config[1]))
            end
        end

        tlw:SetHandler("OnMoveStart", OnMoveStart)
        tlw:SetHandler("OnMoveStop", OnMoveStopLabelOnly)
        tlw._luiUnlockMoveLabelHandlers = true
    end

    return tlw
end

--- Helper function to initialize the mover for a given element
--- @param element Control The element to create a mover for
--- @param config {[1]:string, [2]:number?, [3]:number?} The configuration for the element
--- @return LUIE_PositionableTopLevelWindow|nil mover The created mover window or nil if initialization failed
function Unlock.InitializeElementMover(element, config)
    local attr = Unlock.GetUnlockPositionAttr(element)
    local existingMover = Unlock.movers[attr] or _G[GetUnlockMoverTopLevelName(element)]
    if existingMover then
        return existingMover
    end

    -- Adjust width and height constraints if provided
    local width, height = config[2], config[3]
    if element == ZO_AdvZoneHUD_TopLevel then
        width, height = GetAdvZoneHUDTightDimensions()
        -- First-time unlock: break XML stretch anchors so tight dimensions and mover TLW are not fullscreen (`ApplyAdvZoneHUDDefaultAnchorForMover`).
        if not LUIE.SV[element:GetName()] then
            ApplyAdvZoneHUDDefaultAnchorForMover(width, height)
        end
    end
    if width then element:SetWidth(width) end
    if height then element:SetHeight(height) end

    -- Retrieve the anchor information for the element
    for i = 0, MAX_ANCHORS - 1 do
        local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY, anchorConstraints = element:GetAnchor(i)
        if isValidAnchor then
            -- Special handling for the Alert Text Notification element
            if element == ZO_AlertTextNotification then
                local frameName = element:GetName()
                if not LUIE.SV[frameName] then
                    point = TOPRIGHT
                    relativeTo = GuiRoot
                    relativePoint = TOPRIGHT
                    offsetX = 0
                    offsetY = 0
                    anchorConstraints = anchorConstraints or ANCHOR_CONSTRAINS_XY
                end
            end

            --- @param self LUIE_PositionableTopLevelWindow
            local function OnMoveStop(self)
                local left, top = self:GetLeft(), self:GetTop()

                -- Apply grid snapping if enabled
                if LUIE.SV.snapToGrid_default then
                    left, top = Unlock.ApplyGridSnap(left, top, "default")
                    self:ClearAnchors()
                    self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top, ANCHOR_CONSTRAINS_XY)
                end

                -- Save the new position and update the element positions
                LUIE.SV[self.customPositionAttr] = { left, top }
                if self.preview and self.preview.coordLabel then
                    self.preview.coordLabel:SetText(string.format("%d, %d | %s", left, top, config[1]))
                end
                Unlock.ApplySavedPositionForElement(element, config)
            end

            local mover = Unlock.CreateTopLevelWindow(element, config)
            if not mover._luiUnlockSaveHandler then
                mover:SetHandler("OnMoveStop", OnMoveStop)
                mover._luiUnlockSaveHandler = true
            end

            return mover
        end
    end
end

--- Run when the UI scene changes to hide the unlocked elements if we're in the Addon Settings Menu
--- @param oldState number The previous state of the UI scene
--- @param newState number The new state of the UI scene
function Unlock.OnSceneChange(oldState, newState)
    if not Unlock.frameMoverEnabled then return end

    local isHidden = (newState == SCENE_SHOWN)
    for _, mover in pairs(Unlock.movers) do
        mover:SetHidden(isHidden)
    end
    if LUIE.SV.snapToGrid_default then
        GridOverlay.SetHidden("default", isHidden)
    end
end

--- Register scene callback for the game menu
function Unlock.RegisterSceneCallback()
    -- ZO_Scene:RegisterCallback stacks; without this guard a second call (e.g.
    -- from a re-run Initialize) would stack a second StateChange handler that
    -- would fire OnSceneChange twice on every menu open/close.
    if Unlock._sceneCallbackInstalled then
        return
    end
    local scene = sceneManager:GetScene("gameMenuInGame")
    scene:RegisterCallback("StateChange", Unlock.OnSceneChange)
    Unlock._sceneCallbackInstalled = true
end

-- -----------------------------------------------------------------------------
-- Public API Functions
-- -----------------------------------------------------------------------------

--- Apply saved position for one unlock panel (used when a single mover is dropped).
--- @param element Control
--- @param config {[1]:string, [2]:number?, [3]:number?}
function Unlock.ApplySavedPositionForElement(element, config)
    local frameName = Unlock.GetUnlockPositionAttr(element)
    if not LUIE.SV[frameName] then
        return
    end
    Unlock.AdjustElement(element, config)
    Unlock.SetAnchor(element, frameName)
    if element == ZO_FocusedQuestTrackerPanel then
        Unlock.ApplyDynamicEventsTrackerToQuest()
    end
    if element == Unlock.activeCombatTipsAnchor then
        Unlock.ApplyActiveCombatTipsAnchors()
    end
end

--- Called when an element mover is adjusted and on initialization to update all positions
function Unlock.SetElementPosition()
    for element, config in pairs(Unlock.defaultPanels) do
        local frameName = Unlock.GetUnlockPositionAttr(element)
        if LUIE.SV[frameName] then
            Unlock.AdjustElement(element, config)
            Unlock.SetAnchor(element, frameName)
        end
    end

    Unlock.ApplyActiveCombatTipsAnchors()
    Unlock.RegisterUnlockPositionHooks()
    Unlock.RegisterDynamicEventsQuestAnchorHook()
    Unlock.ApplyDynamicEventsTrackerToQuest()
    Unlock.ApplyAlertFrameAlignment()
end

--- Setup element movers based on the provided state
--- @param state boolean Whether to enable or disable the movers
function Unlock.SetupElementMover(state)
    Unlock.frameMoverEnabled = state
    local isFirstRun = next(Unlock.movers) == nil

    for element, config in pairs(Unlock.defaultPanels) do
        if isFirstRun then
            local mover = Unlock.InitializeElementMover(element, config)
            if mover then
                Unlock.movers[Unlock.GetUnlockPositionAttr(element)] = mover
            end
        end

        local mover = Unlock.movers[Unlock.GetUnlockPositionAttr(element)]
        --- @cast mover userdata
        if mover then
            mover:SetMouseEnabled(state)
            mover:SetMovable(state)
            mover:SetHidden(not state)
        end
    end

    if isFirstRun then
        Unlock.RegisterSceneCallback()
    end

    local gridSize = LUIE.SV.snapToGridSize_default or 15
    GridOverlay.Refresh("default", state and LUIE.SV.snapToGrid_default, gridSize)
    if state then
        Unlock.RefreshMoverScreenPositions()
    end
end

--- Reset the position of windows. Called from the Settings Menu
function Unlock.ResetElementPosition()
    for element, _ in pairs(Unlock.defaultPanels) do
        LUIE.SV[Unlock.GetUnlockPositionAttr(element)] = nil
    end
    LUIE.SV["ZO_ActiveCombatTipsTip"] = nil
    LUIE.SV.AlertFrameAlignment = nil
    ReloadUI("ingame")
end

-- -----------------------------------------------------------------------------
-- Expose public functions to LUIE namespace
-- -----------------------------------------------------------------------------

-- Export grid snap functions for use in other modules
LUIE.SnapToGrid = Unlock.SnapToGrid
LUIE.ApplyGridSnap = Unlock.ApplyGridSnap

-- Export the public API
LUIE.SetElementPosition = Unlock.SetElementPosition
LUIE.SetupElementMover = Unlock.SetupElementMover
LUIE.ResetElementPosition = Unlock.ResetElementPosition
LUIE.ApplyAlertFrameAlignment = Unlock.ApplyAlertFrameAlignment

-- Store the Unlock module in LUIE
LUIE.Unlock = Unlock
