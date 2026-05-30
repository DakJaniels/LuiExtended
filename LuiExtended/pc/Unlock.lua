--- @diagnostic disable: duplicate-set-field, duplicate-doc-field
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
--- @class (partial) LuiExtended
local LUIE = LUIE
-- -----------------------------------------------------------------------------
local UI = LUIE.UI
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
--- @field preview LUIE_PositionableTLWPreview|nil
--- @field previewLabel LabelControl|nil

--- @class LUIE.Unlock : table
--- @field frameMoverEnabled boolean Flag indicating if frame movers are currently enabled
--- @field movers table Table of created mover frames
--- @field defaultPanels table Table of UI elements to unlock for moving
local Unlock =
{
    frameMoverEnabled = false,
    movers = {},
    dynamicEventsQuestHookInstalled = false,
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
        [ZO_SynergyTopLevelContainer] = { GetString(LUIE_STRING_DEFAULT_FRAME_SYNERGY) },
        [ZO_CompassFrame] = { GetString(LUIE_STRING_DEFAULT_FRAME_COMPASS) },                                        -- Needs custom template applied
        [ZO_PlayerProgress] = { GetString(LUIE_STRING_DEFAULT_FRAME_PLAYER_PROGRESS) },                              -- Needs custom template applied
        [ZO_EndDunHUDTrackerContainer] = { GetString(LUIE_STRING_DEFAULT_FRAME_ENDLESS_DUNGEON_TRACKER), 230, 100 }, -- Needs custom template applied
        [ZO_ReticleContainerInteract] = { GetString(LUIE_STRING_DEFAULT_FRAME_RETICLE_CONTAINER_INTERACT) },
        [ZO_RamTopLevel] = { GetString(SI_SIEGETYPE3), 290, 110 },
        [ZO_AdvZoneHUDTrackerContainer] = { "Dynamic Events Tracker", 230, 100 }, -- Needs custom template applied
        [ZO_LootHistoryControl_Keyboard] = { GetString(LUIE_STRING_DEFAULT_FRAME_LOOT_HISTORY), 280, 400 },
        [ZO_TutorialHudInfoTipKeyboard] = { GetString(LUIE_STRING_DEFAULT_FRAME_TUTORIALS) },
        [ZO_AlertTextNotification] = { GetString(LUIE_STRING_DEFAULT_FRAME_ALERTS), 600, 56 },
        [ZO_ActiveCombatTipsTip] = { GetString(LUIE_STRING_DEFAULT_FRAME_ACTIVE_COMBAT_TIPS), 250, 20 },
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
-- Template Functions
-- -----------------------------------------------------------------------------

--- Replace the template function for certain elements to also use custom positions
--- @param object table<string, function> The object containing the template function to be replaced
--- @param functionName string The name of the template function to be replaced
--- @param frameName string The name of the frame associated with the template function
function Unlock.ReplaceDefaultTemplate(object, functionName, frameName)
    local zos_function = object[functionName]
    object[functionName] = function (self)
        local result = zos_function(self)
        local frameData = LUIE.SV[frameName]
        if frameData then
            local frame = _G[frameName]
            --- @cast frame userdata
            frame:ClearAnchors()
            frame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, frameData[1], frameData[2], ANCHOR_CONSTRAINS_XY)
        end
        return result
    end
end

-- -----------------------------------------------------------------------------
-- Element Handling Functions
-- -----------------------------------------------------------------------------

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

    -- Setup Alert Text to anchor properly.
    -- Thanks to Phinix (Azurah) for this method of adjusting the fadingControlBuffer anchor to reposition the alert text.
    if element == ZO_AlertTextNotification then
        -- Throw a dummy alert just in case so alert text exists.
        ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.NONE, " ")
        local alertText
        if not IsInGamepadPreferredMode() then
            alertText = ZO_AlertTextNotification:GetChild(1)
        else
            alertText = ZO_AlertTextNotificationGamepad:GetChild(1)
        end
        -- Only adjust this if a custom position is set.
        if x ~= nil and y ~= nil then
            -- Anchor to the Top Right corner of the Alerts frame.
            --- @diagnostic disable-next-line: undefined-field
            alertText.fadingControlBuffer.anchor = ZO_Anchor:New(TOPRIGHT, ZO_AlertTextNotification, TOPRIGHT)
        end
    end

    if element == ZO_FocusedQuestTrackerPanel then
        Unlock.ApplyDynamicEventsTrackerToQuest()
    end
end

-- -----------------------------------------------------------------------------
-- Mover Creation and Management
-- -----------------------------------------------------------------------------

--- Helper function to create a coordinate label for mover frames
--- @param parent Control The parent control for the label
--- @param positionText string The text to display in the label
--- @return LabelControl label The created label
function Unlock.CreateCoordinateLabel(parent, positionText)
    local label = windowManager:CreateControl(nil, parent, CT_LABEL)
    label:SetFont(LUIE.GetPositionLabelFont())
    label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    label:SetVerticalAlignment(TEXT_ALIGN_TOP)
    label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    label:SetAnchor(TOPLEFT, parent, TOPLEFT, 2, 2, ANCHOR_CONSTRAINS_XY)
    label:SetText(positionText)
    label:SetColor(1, 1, 0, 1)
    label:SetDrawLayer(DL_OVERLAY)
    label:SetDrawLevel(5)
    label:SetDrawTier(DT_MEDIUM)

    -- Create label background
    local bg = windowManager:CreateControl(nil, label, CT_BACKDROP)
    bg:SetCenterColor(0, 0, 0, 1)
    bg:SetEdgeColor(0, 0, 0, 1)
    bg:SetEdgeTexture("", 8, 1, 1, 1)
    bg:SetDrawLayer(DL_BACKGROUND)
    bg:SetAnchorFill(label)
    bg:SetDrawLayer(DL_OVERLAY)
    bg:SetDrawLevel(5)
    bg:SetDrawTier(DT_LOW)

    return label
end

--- Helper function to create a top-level window (mover)
--- @param element Control The element to create the top-level window for
--- @param config {[1]:string, [2]:number?, [3]:number?} The table containing window configuration values
--- @param point number The anchor point for the top-level window
--- @param relativePoint number The relative anchor point for the top-level window
--- @param offsetX number The X offset for the top-level window
--- @param offsetY number The Y offset for the top-level window
--- @param relativeTo Control The element to which the top-level window is relative
--- @return LUIE_PositionableTopLevelWindow tlw The created top-level window
function Unlock.CreateTopLevelWindow(element, config, point, relativePoint, offsetX, offsetY, relativeTo)
    --- Runtime value is Zo `TopLevelWindow`; Unlock attaches `customPositionAttr` and `preview` (see class doc).
    --- @type LUIE_PositionableTopLevelWindow
    local tlw = windowManager:CreateTopLevelWindow(nil)
    tlw:SetClampedToScreen(true)
    tlw:SetMouseEnabled(false)
    tlw:SetMovable(false)
    tlw:SetHidden(true)
    tlw:SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY, ANCHOR_CONSTRAINS_XY)
    tlw:SetDimensions(element:GetWidth(), element:GetHeight())
    tlw.customPositionAttr = element:GetName()

    -- Create preview backdrop
    tlw.preview = windowManager:CreateControl(nil, tlw, CT_BACKDROP)
    tlw.preview:SetCenterColor(0, 0, 0, 0.4)
    tlw.preview:SetEdgeColor(0, 0, 0, 0.6)
    tlw.preview:SetEdgeTexture("", 8, 1, 1, 1)
    tlw.preview:SetDrawLayer(DL_BACKGROUND)
    tlw.preview:SetAnchorFill(tlw)
    tlw.preview:SetDrawLayer(DL_OVERLAY)
    tlw.preview:SetDrawLevel(5)
    tlw.preview:SetDrawTier(DT_MEDIUM)

    -- Get initial position from saved variables if it exists
    local positionText = "Default"
    if LUIE.SV[tlw.customPositionAttr] then
        local x = LUIE.SV[tlw.customPositionAttr][1] or 0
        local y = LUIE.SV[tlw.customPositionAttr][2] or 0
        positionText = string.format("%d, %d | %s", x, y, config[1])
    else
        positionText = string.format("Default | %s", config[1])
    end

    -- Create coordinate label with initial position
    tlw.preview.coordLabel = Unlock.CreateCoordinateLabel(tlw.preview, positionText)

    --- @param self LUIE_PositionableTopLevelWindow
    local function OnMoveStart(self)
        eventManager:RegisterForUpdate("LUIE_UnlockMoveUpdate", 200, function ()
            if self.preview and self.preview.coordLabel then
                local frameName = config[1] -- Get the frame name from the config
                self.preview.coordLabel:SetText(string.format("%d, %d | %s", self:GetLeft(), self:GetTop(), frameName))
            end
        end)
    end

    --- @param self LUIE_PositionableTopLevelWindow
    local function OnMoveStop(self)
        eventManager:UnregisterForUpdate("LUIE_UnlockMoveUpdate")
        if self.preview and self.preview.coordLabel then
            local frameName = config[1] -- Get the frame name from the config
            self.preview.coordLabel:SetText(string.format("%d, %d | %s", self:GetLeft(), self:GetTop(), frameName))
        end
    end

    -- Add movement handlers
    tlw:SetHandler("OnMoveStart", OnMoveStart)

    tlw:SetHandler("OnMoveStop", OnMoveStop)

    return tlw
end

--- Helper function to initialize the mover for a given element
--- @param element Control The element to create a mover for
--- @param config {[1]:string, [2]:number?, [3]:number?} The configuration for the element
--- @return LUIE_PositionableTopLevelWindow|nil mover The created mover window or nil if initialization failed
function Unlock.InitializeElementMover(element, config)
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
                Unlock.SetElementPosition()
            end

            -- Create and configure the top-level window (mover) for the element
            local mover = Unlock.CreateTopLevelWindow(element, config, point, relativePoint, offsetX, offsetY, relativeTo)
            mover:SetHandler("OnMoveStop", OnMoveStop)

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

--- Called when an element mover is adjusted and on initialization to update all positions
function Unlock.SetElementPosition()
    for element, config in pairs(Unlock.defaultPanels) do
        local frameName = element:GetName()
        if LUIE.SV[frameName] then
            Unlock.AdjustElement(element, config)
            Unlock.SetAnchor(element, frameName)
        end
    end

    -- Apply custom templates
    Unlock.ReplaceDefaultTemplate(ACTIVE_COMBAT_TIP_SYSTEM, "ApplyStyle", "ZO_ActiveCombatTips")
    Unlock.ReplaceDefaultTemplate(COMPASS_FRAME, "ApplyStyle", "ZO_CompassFrame")
    Unlock.ReplaceDefaultTemplate(PLAYER_PROGRESS_BAR, "RefreshTemplate", "ZO_PlayerProgress")
    Unlock.ReplaceDefaultTemplate(ZO_HUDTracker_Base, "RefreshAnchors", "ZO_EndDunHUDTrackerContainer")
    Unlock.ReplaceDefaultTemplate(ZO_HUDTracker_Base, "RefreshAnchors", "ZO_AdvZoneHUDTrackerContainer")
    Unlock.RegisterDynamicEventsQuestAnchorHook()
    Unlock.ApplyDynamicEventsTrackerToQuest()
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
                Unlock.movers[element:GetName()] = mover
            end
        end

        local mover = Unlock.movers[element:GetName()]
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
end

--- Reset the position of windows. Called from the Settings Menu
function Unlock.ResetElementPosition()
    for element, _ in pairs(Unlock.defaultPanels) do
        local frameName = element:GetName()
        LUIE.SV[frameName] = nil
    end
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

-- Store the Unlock module in LUIE
LUIE.Unlock = Unlock
