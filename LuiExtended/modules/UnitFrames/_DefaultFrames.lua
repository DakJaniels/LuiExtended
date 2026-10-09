-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- Unit Frames namespace
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

--- ESO default player attribute bar control (has runtime field playerAttributeBarObject).
--- @class ZO_PlayerAttributeBarControl : Control
--- @field playerAttributeBarObject { timeline: table }

--- @class ZO_PlayerAttributeHealth : ZO_PlayerAttributeBarControl
--- @class ZO_PlayerAttributeMagicka : ZO_PlayerAttributeBarControl
--- @class ZO_PlayerAttributeStamina : ZO_PlayerAttributeBarControl

local pairs = pairs

local eventManager = GetEventManager()

-- Pyramid geometry from the previous SetAnchor layout.
local PYRAMID_HEALTH_BUTTON_GAP = 47
local PYRAMID_MAGICKA_OFFSET_X = -1
local PYRAMID_MAGICKA_OFFSET_Y = 2
local PYRAMID_STAMINA_OFFSET_X = 1
local PYRAMID_STAMINA_OFFSET_Y = 2
local PYRAMID_SIEGE_OFFSET_X = 300
local PYRAMID_RAM_OFFSET_X = 300
local PYRAMID_SMALL_GROUP_OFFSET_X = 20
local PYRAMID_SMALL_GROUP_OFFSET_Y = 80
-- PlayerAttributeBars.xml: SiegeHealth TOP to Health BOTTOM, offsetY -1.
local SIEGE_HEALTH_DEFAULT_OFFSET_Y = -1

local consoleDefaultPos = {}
local consoleDefaultPosCaptured = false
local defaultFrameHudCallbacksRegistered = false

local PLAYER_ATTRIBUTE_BAR_SUFFIXES =
{
    "Health",
    "Stamina",
    "Magicka",
    "MountStamina",
    "Werewolf",
    "SiegeHealth",
}



-- Following settings will be used in options menu to define DefaultFrames behaviour (stored 1-3).
UnitFrames.DEFAULT_FRAMES_MODE_DISABLE = 1
UnitFrames.DEFAULT_FRAMES_MODE_KEEP_DEFAULT = 2
UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER = 3

--- @param mode integer|nil
--- @return boolean
function UnitFrames.IsDefaultFramesModeHideVanilla(mode)
    return mode == UnitFrames.DEFAULT_FRAMES_MODE_DISABLE
end

--- @param mode integer|nil
--- @return boolean
function UnitFrames.IsDefaultFramesModeExtender(mode)
    return mode == UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER
end

local function GetDefaultFramesModeLabel(modeIndex)
    if modeIndex == UnitFrames.DEFAULT_FRAMES_MODE_DISABLE then
        return GetString(LUIE_STRING_LAM_UF_DFRAMES_MODE_DISABLE)
    end
    if modeIndex == UnitFrames.DEFAULT_FRAMES_MODE_KEEP_DEFAULT then
        return GetString(LUIE_STRING_LAM_UF_DFRAMES_MODE_KEEP_DEFAULT)
    end
    if modeIndex == UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER then
        return GetString(LUIE_STRING_LAM_UF_DFRAMES_MODE_EXTENDER)
    end
    return GetString(LUIE_STRING_LAM_UF_DFRAMES_MODE_DISABLE)
end

--- Maps saved DefaultFramesNew* to behavior modes 1-3 (does not rewrite SV).
--- @param frameKey "Player"|"Target"|"Group"|"Boss"
--- @return integer mode 1-3
function UnitFrames.GetEffectiveDefaultFramesMode(frameKey)
    local storedKey = "DefaultFramesNew" .. tostring(frameKey)
    local rawMode = UnitFrames.SV[storedKey]
    if rawMode == nil then
        return UnitFrames.DEFAULT_FRAMES_MODE_DISABLE
    end

    local fourModeFlagKey = "DefaultFramesNewFourMode" .. tostring(frameKey)
    if UnitFrames.SV[fourModeFlagKey] == true then
        if rawMode == 1 or rawMode == 2 then
            return UnitFrames.DEFAULT_FRAMES_MODE_DISABLE
        end
        if rawMode == 3 then
            return UnitFrames.DEFAULT_FRAMES_MODE_KEEP_DEFAULT
        end
        if rawMode >= 4 then
            return UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER
        end
        return UnitFrames.DEFAULT_FRAMES_MODE_DISABLE
    end

    if frameKey == "Boss" then
        if rawMode == 1 then
            return UnitFrames.DEFAULT_FRAMES_MODE_DISABLE
        end
        return UnitFrames.DEFAULT_FRAMES_MODE_KEEP_DEFAULT
    end

    if rawMode == 1 or rawMode == 2 or rawMode == 3 then
        return rawMode
    end
    if rawMode >= 4 then
        return UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER
    end
    return UnitFrames.DEFAULT_FRAMES_MODE_DISABLE
end

--- @return boolean
function UnitFrames.ShouldHideVanillaPlayerAttributeBarsForCustomPlayer()
    if not UnitFrames.SV.CustomFramesPlayer then
        return false
    end
    return UnitFrames.IsDefaultFramesModeHideVanilla(UnitFrames.GetEffectiveDefaultFramesMode("Player"))
end

--- @return boolean
function UnitFrames.ShouldHideVanillaTargetFrameForCustomTarget()
    if not UnitFrames.SV.CustomFramesTarget then
        return false
    end
    return UnitFrames.IsDefaultFramesModeHideVanilla(UnitFrames.GetEffectiveDefaultFramesMode("Target"))
end

--- Hide default player attribute bars when Default PLAYER is Disable and LUIE custom player is enabled.
function UnitFrames.ApplyHideDefaultPlayerAttributeBarsIfNeeded()
    if not UnitFrames.ShouldHideVanillaPlayerAttributeBarsForCustomPlayer() then
        return
    end
    for suffixIndex = 1, #PLAYER_ATTRIBUTE_BAR_SUFFIXES do
        local suffix = PLAYER_ATTRIBUTE_BAR_SUFFIXES[suffixIndex]
        local controlName = "ZO_PlayerAttribute" .. suffix
        local frame = _G[controlName]
        if frame then
            frame:UnregisterForEvent(EVENT_POWER_UPDATE)
            frame:UnregisterForEvent(EVENT_INTERFACE_SETTING_CHANGED)
            frame:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
            eventManager:UnregisterForUpdate(controlName .. "FadeUpdate")
            frame:SetHidden(true)
        end
    end
    if ZO_PlayerAttribute then
        eventManager:UnregisterForAllEvents("ZO_PlayerAttribute")
        ZO_PlayerAttribute:SetHidden(true)
    end
end

-- A function to extract the anchor information
--- @param frame Control
--- @return {point:AnchorPosition,relativeTo:object,relativePoint:AnchorPosition,offsetX:number,offsetY:number }|nil
local function GetAnchorInfo(frame)
    local anchorIndex = 1
    local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = frame:GetAnchor(anchorIndex)
    if not isValidAnchor then
        return
    end
    return { point, relativeTo, relativePoint, offsetX, offsetY }
end

-- Console still uses raw anchors. HUD_MANAGER:GetSavedAnchor returns the default anchor there.
local function CaptureConsoleDefaultFramePositions()
    if consoleDefaultPosCaptured then
        return
    end
    if not ZO_PlayerAttributeHealth or not ZO_RAM or not ZO_RAM.control or not ZO_SmallGroupAnchorFrame then
        return
    end
    consoleDefaultPos.health = GetAnchorInfo(ZO_PlayerAttributeHealth)
    consoleDefaultPos.magicka = GetAnchorInfo(ZO_PlayerAttributeMagicka)
    consoleDefaultPos.stamina = GetAnchorInfo(ZO_PlayerAttributeStamina)
    consoleDefaultPos.siege = GetAnchorInfo(ZO_PlayerAttributeSiegeHealth)
    consoleDefaultPos.ram = GetAnchorInfo(ZO_RAM.control)
    consoleDefaultPos.smallGroup = GetAnchorInfo(ZO_SmallGroupAnchorFrame)
    if consoleDefaultPos.health and consoleDefaultPos.magicka and consoleDefaultPos.stamina and consoleDefaultPos.siege and consoleDefaultPos.ram and consoleDefaultPos.smallGroup then
        consoleDefaultPosCaptured = true
    end
end

local function RepositionDefaultFramesConsole()
    CaptureConsoleDefaultFramePositions()
    local verticalAdjust = UnitFrames.SV.RepositionFramesAdjust or 0
    if not UnitFrames.SV.RepositionFrames then
        if consoleDefaultPosCaptured then
            ZO_PlayerAttributeHealth:ClearAnchors()
            ZO_PlayerAttributeHealth:SetAnchor(consoleDefaultPos.health[1], consoleDefaultPos.health[2], consoleDefaultPos.health[3], consoleDefaultPos.health[4], consoleDefaultPos.health[5] - verticalAdjust)
            ZO_PlayerAttributeMagicka:ClearAnchors()
            ZO_PlayerAttributeMagicka:SetAnchor(consoleDefaultPos.magicka[1], consoleDefaultPos.magicka[2], consoleDefaultPos.magicka[3], consoleDefaultPos.magicka[4], consoleDefaultPos.magicka[5] - verticalAdjust)
            ZO_PlayerAttributeStamina:ClearAnchors()
            ZO_PlayerAttributeStamina:SetAnchor(consoleDefaultPos.stamina[1], consoleDefaultPos.stamina[2], consoleDefaultPos.stamina[3], consoleDefaultPos.stamina[4], consoleDefaultPos.stamina[5] - verticalAdjust)
            ZO_PlayerAttributeSiegeHealth:ClearAnchors()
            ZO_PlayerAttributeSiegeHealth:SetAnchor(consoleDefaultPos.siege[1], consoleDefaultPos.siege[2], consoleDefaultPos.siege[3], consoleDefaultPos.siege[4], consoleDefaultPos.siege[5] - verticalAdjust)
            ZO_RAM.control:ClearAnchors()
            ZO_RAM.control:SetAnchor(consoleDefaultPos.ram[1], consoleDefaultPos.ram[2], consoleDefaultPos.ram[3], consoleDefaultPos.ram[4], consoleDefaultPos.ram[5] - verticalAdjust)
            ZO_SmallGroupAnchorFrame:ClearAnchors()
            ZO_SmallGroupAnchorFrame:SetAnchor(consoleDefaultPos.smallGroup[1], consoleDefaultPos.smallGroup[2], consoleDefaultPos.smallGroup[3], consoleDefaultPos.smallGroup[4], consoleDefaultPos.smallGroup[5] - verticalAdjust)
        end
        return
    end

    ZO_PlayerAttributeHealth:ClearAnchors()
    ZO_PlayerAttributeHealth:SetAnchor(BOTTOM, ActionButton5, TOP, 0, -PYRAMID_HEALTH_BUTTON_GAP - verticalAdjust)
    ZO_PlayerAttributeMagicka:ClearAnchors()
    ZO_PlayerAttributeMagicka:SetAnchor(TOPRIGHT, ZO_PlayerAttributeHealth, BOTTOM, PYRAMID_MAGICKA_OFFSET_X, PYRAMID_MAGICKA_OFFSET_Y)
    ZO_PlayerAttributeStamina:ClearAnchors()
    ZO_PlayerAttributeStamina:SetAnchor(TOPLEFT, ZO_PlayerAttributeHealth, BOTTOM, PYRAMID_STAMINA_OFFSET_X, PYRAMID_STAMINA_OFFSET_Y)
    ZO_PlayerAttributeSiegeHealth:ClearAnchors()
    ZO_PlayerAttributeSiegeHealth:SetAnchor(CENTER, ZO_PlayerAttributeHealth, CENTER, PYRAMID_SIEGE_OFFSET_X, 0)
    ZO_RAM.control:ClearAnchors()
    ZO_RAM.control:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, PYRAMID_RAM_OFFSET_X, 0)
    ZO_SmallGroupAnchorFrame:ClearAnchors()
    ZO_SmallGroupAnchorFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, PYRAMID_SMALL_GROUP_OFFSET_X, PYRAMID_SMALL_GROUP_OFFSET_Y)
end

--- Keyboard and gamepad HUD elements share one control. HUDManager.lua GetKeyboardElementForControl / GetGamepadElementForControl.
--- @param control Control|nil
--- @return ZO_HUDManager_Element|nil
local function GetActivePlatformHudElement(control)
    if IsInGamepadPreferredMode() then
        return HUD_MANAGER:GetGamepadElementForControl(control)
    end
    return HUD_MANAGER:GetKeyboardElementForControl(control)
end

--- Screen position of an anchor point, expressed the same way as ZO_GetControlPointOffsetFromGuiRoot.
--- @param anchorPoint AnchorPosition
--- @param screenX number
--- @param screenY number
--- @return number offsetX
--- @return number offsetY
local function GetGuiRootOffsetForAnchorPoint(anchorPoint, screenX, screenY)
    local guiRootCenterX, guiRootCenterY = GuiRoot:GetCenter()
    local offsetX
    if anchorPoint == TOPLEFT or anchorPoint == LEFT or anchorPoint == BOTTOMLEFT then
        offsetX = screenX
    elseif anchorPoint == TOP or anchorPoint == CENTER or anchorPoint == BOTTOM then
        offsetX = screenX - guiRootCenterX
    else
        offsetX = screenX - GuiRoot:GetRight()
    end

    local offsetY
    if anchorPoint == TOPLEFT or anchorPoint == TOP or anchorPoint == TOPRIGHT then
        offsetY = screenY
    elseif anchorPoint == LEFT or anchorPoint == CENTER or anchorPoint == RIGHT then
        offsetY = screenY - guiRootCenterY
    else
        offsetY = screenY - GuiRoot:GetBottom()
    end
    return offsetX, offsetY
end

--- @param element ZO_HUDManager_Element|nil
--- @param desiredOffsetX number
--- @param desiredOffsetY number
local function ApplyHudElementGuiRootOffset(element, desiredOffsetX, desiredOffsetY)
    if not element then
        return
    end
    local control = element:GetControl()
    -- Saved or default anchor first, so ApplyOffset reads the element's primary anchor point.
    element:RevertOffsetModifications()
    local anchorPoint = element.primaryAnchorPoint
    local controlOffsetX, controlOffsetY = ZO_GetControlPointOffsetFromGuiRoot(control, anchorPoint)
    local refOffsetX, refOffsetY = ZO_GetControlPointOffsetFromGuiRoot(control.hudElementRef, anchorPoint)
    local applyOffsetX = desiredOffsetX - (controlOffsetX - refOffsetX)
    local applyOffsetY = desiredOffsetY - (controlOffsetY - refOffsetY)
    element:ApplyOffset(applyOffsetX, applyOffsetY, false)
end

--- @param element ZO_HUDManager_Element|nil
--- @param verticalAdjust number
local function ApplySavedAnchorVerticalAdjust(element, verticalAdjust)
    if not element then
        return
    end
    element:RevertOffsetModifications()
    if verticalAdjust == 0 then
        return
    end
    local _, refOffsetX, refOffsetY = element:GetConvertedRefControlAnchorInfo()
    element:ApplyOffset(refOffsetX, refOffsetY - verticalAdjust, false)
end

--- @param element ZO_HUDManager_Element|nil
local function ResetHudElementToDefaultAnchor(element)
    if not element then
        return
    end
    element:ResetToDefaultAnchor(false)
end

--- FRAME_OPTIONS Combine defaults to true (PlayerAttributeBars.lua).
--- @param frameElement ZO_HUDManager_Element|nil
--- @return boolean
local function GetPlayerAttributeResourcesCombined(frameElement)
    if not frameElement then
        return true
    end
    local combineValue = frameElement:GetCustomOptionValue("Combine")
    if combineValue == nil then
        return true
    end
    return combineValue
end

local function RestoreSiegeHealthDefaultAnchor()
    local siegeHealth = ZO_PlayerAttributeSiegeHealth
    local health = ZO_PlayerAttributeHealth
    if not siegeHealth or not health then
        return
    end
    siegeHealth:ClearAnchors()
    siegeHealth:SetAnchor(TOP, health, BOTTOM, 0, SIEGE_HEALTH_DEFAULT_OFFSET_Y)
end

local function ApplyPyramidSiegeHealthAnchor()
    local siegeHealth = ZO_PlayerAttributeSiegeHealth
    local health = ZO_PlayerAttributeHealth
    if not siegeHealth or not health then
        return
    end
    siegeHealth:ClearAnchors()
    siegeHealth:SetAnchor(CENTER, health, CENTER, PYRAMID_SIEGE_OFFSET_X, 0)
end

--- @param verticalAdjust number
local function ApplyPyramidPlayerFrameLayout(verticalAdjust)
    local healthElement = GetActivePlatformHudElement(ZO_PlayerAttributeHealth)
    local magickaElement = GetActivePlatformHudElement(ZO_PlayerAttributeMagicka)
    local staminaElement = GetActivePlatformHudElement(ZO_PlayerAttributeStamina)
    local frameElement = GetActivePlatformHudElement(ZO_PlayerAttribute)
    local ramElement = GetActivePlatformHudElement(ZO_RAM.control)
    local smallGroupElement = GetActivePlatformHudElement(ZO_SmallGroupAnchorFrame)

    if healthElement and ActionButton5 then
        local healthControl = healthElement:GetControl()
        local buttonCenterX = ActionButton5:GetCenter()
        local buttonTop = ActionButton5:GetTop()
        local healthBottom = buttonTop - PYRAMID_HEALTH_BUTTON_GAP - verticalAdjust
        local healthCenterY = healthBottom - (healthControl:GetHeight() * 0.5)
        local desiredOffsetX, desiredOffsetY = GetGuiRootOffsetForAnchorPoint(healthElement.primaryAnchorPoint, buttonCenterX, healthCenterY)
        ApplyHudElementGuiRootOffset(healthElement, desiredOffsetX, desiredOffsetY)
    end

    local healthCenterX = ZO_PlayerAttributeHealth:GetCenter()
    local healthBottom = ZO_PlayerAttributeHealth:GetBottom()
    local healthTop = ZO_PlayerAttributeHealth:GetTop()

    if magickaElement then
        local magickaControl = magickaElement:GetControl()
        local anchorScreenX = healthCenterX + PYRAMID_MAGICKA_OFFSET_X
        local anchorScreenY = healthBottom + PYRAMID_MAGICKA_OFFSET_Y + (magickaControl:GetHeight() * 0.5)
        local desiredOffsetX, desiredOffsetY = GetGuiRootOffsetForAnchorPoint(magickaElement.primaryAnchorPoint, anchorScreenX, anchorScreenY)
        ApplyHudElementGuiRootOffset(magickaElement, desiredOffsetX, desiredOffsetY)
    end

    if staminaElement then
        local staminaControl = staminaElement:GetControl()
        local anchorScreenX = healthCenterX + PYRAMID_STAMINA_OFFSET_X
        local anchorScreenY = healthBottom + PYRAMID_STAMINA_OFFSET_Y + (staminaControl:GetHeight() * 0.5)
        local desiredOffsetX, desiredOffsetY = GetGuiRootOffsetForAnchorPoint(staminaElement.primaryAnchorPoint, anchorScreenX, anchorScreenY)
        ApplyHudElementGuiRootOffset(staminaElement, desiredOffsetX, desiredOffsetY)
    end

    if frameElement then
        frameElement:RevertOffsetModifications()
    end

    ApplyPyramidSiegeHealthAnchor()

    if ramElement then
        local anchorScreenX = healthCenterX + PYRAMID_RAM_OFFSET_X
        local anchorScreenY = healthTop
        local desiredOffsetX, desiredOffsetY = GetGuiRootOffsetForAnchorPoint(ramElement.primaryAnchorPoint, anchorScreenX, anchorScreenY)
        ApplyHudElementGuiRootOffset(ramElement, desiredOffsetX, desiredOffsetY)
    end

    if smallGroupElement then
        local desiredOffsetX, desiredOffsetY = GetGuiRootOffsetForAnchorPoint(smallGroupElement.primaryAnchorPoint, PYRAMID_SMALL_GROUP_OFFSET_X, PYRAMID_SMALL_GROUP_OFFSET_Y)
        ApplyHudElementGuiRootOffset(smallGroupElement, desiredOffsetX, desiredOffsetY)
    end
end

--- @param verticalAdjust number
local function ApplyVerticalPlayerFrameAdjust(verticalAdjust)
    local healthElement = GetActivePlatformHudElement(ZO_PlayerAttributeHealth)
    local magickaElement = GetActivePlatformHudElement(ZO_PlayerAttributeMagicka)
    local staminaElement = GetActivePlatformHudElement(ZO_PlayerAttributeStamina)
    local frameElement = GetActivePlatformHudElement(ZO_PlayerAttribute)
    local ramElement = GetActivePlatformHudElement(ZO_RAM.control)
    local smallGroupElement = GetActivePlatformHudElement(ZO_SmallGroupAnchorFrame)
    local resourcesCombined = GetPlayerAttributeResourcesCombined(frameElement)

    if resourcesCombined then
        ResetHudElementToDefaultAnchor(healthElement)
        ResetHudElementToDefaultAnchor(magickaElement)
        ResetHudElementToDefaultAnchor(staminaElement)
        RestoreSiegeHealthDefaultAnchor()
        ApplySavedAnchorVerticalAdjust(frameElement, verticalAdjust)
    else
        if frameElement then
            frameElement:RevertOffsetModifications()
        end
        ApplySavedAnchorVerticalAdjust(healthElement, verticalAdjust)
        ApplySavedAnchorVerticalAdjust(magickaElement, verticalAdjust)
        ApplySavedAnchorVerticalAdjust(staminaElement, verticalAdjust)
        RestoreSiegeHealthDefaultAnchor()
    end

    ApplySavedAnchorVerticalAdjust(ramElement, verticalAdjust)
    ApplySavedAnchorVerticalAdjust(smallGroupElement, verticalAdjust)
end

-- Adjust default frame position.
function UnitFrames.RepositionDefaultFrames()
    if not UnitFrames.Enabled then
        return
    end
    if not UnitFrames.SV or UnitFrames.SV.RepositionFrames == nil then
        return
    end
    if ZO_IsConsoleOrGameCoreUI() then
        RepositionDefaultFramesConsole()
        return
    end

    local verticalAdjust = UnitFrames.SV.RepositionFramesAdjust or 0
    if UnitFrames.SV.RepositionFrames then
        ApplyPyramidPlayerFrameLayout(verticalAdjust)
    else
        ApplyVerticalPlayerFrameAdjust(verticalAdjust)
    end
end

function UnitFrames.GetDefaultFramesOptions(frame)
    local retval = {}
    for modeIndex = UnitFrames.DEFAULT_FRAMES_MODE_DISABLE, UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER do
        if not (frame == "Boss" and modeIndex == UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER) then
            table.insert(retval, GetDefaultFramesModeLabel(modeIndex))
        end
    end
    return retval
end

function UnitFrames.SetDefaultFramesSetting(frame, value)
    local key = "DefaultFramesNew" .. tostring(frame)
    for modeIndex = UnitFrames.DEFAULT_FRAMES_MODE_DISABLE, UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER do
        if GetDefaultFramesModeLabel(modeIndex) == value then
            if modeIndex == UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER and frame ~= "Boss" then
                if not ZO_IsConsoleOrGameCoreUI() then
                    SetSetting(SETTING_TYPE_UI, UI_SETTING_RESOURCE_NUMBERS, 0, SETTINGS_SET_OPTION_SAVE_TO_PERSISTED_DATA)
                end
            end
            UnitFrames.SV[key] = modeIndex
            UnitFrames.ResetCompassBarMenu()
            UnitFrames.ApplyHideDefaultPlayerAttributeBarsIfNeeded()
            return
        end
    end
end

function UnitFrames.GetDefaultFramesSetting(frame, default)
    if default then
        local mode = UnitFrames.Defaults["DefaultFramesNew" .. tostring(frame)]
        if frame == "Boss" and (mode == nil or mode == 3) then
            mode = UnitFrames.DEFAULT_FRAMES_MODE_KEEP_DEFAULT
        elseif mode == nil or mode < UnitFrames.DEFAULT_FRAMES_MODE_DISABLE or mode > UnitFrames.DEFAULT_FRAMES_MODE_EXTENDER then
            mode = UnitFrames.DEFAULT_FRAMES_MODE_DISABLE
        end
        return GetDefaultFramesModeLabel(mode)
    end
    return GetDefaultFramesModeLabel(UnitFrames.GetEffectiveDefaultFramesMode(frame))
end

-- Used to create default frames extender controls for player and target.
-- Called from UnitFrames.Initialize
function UnitFrames.CreateDefaultFrames()
    -- Create text overlay for default unit frames for player and reticleover.
    local default_controls = {}

    if UnitFrames.IsDefaultFramesModeExtender(UnitFrames.GetEffectiveDefaultFramesMode("Player")) then
        default_controls.player =
        {
            [COMBAT_MECHANIC_FLAGS_HEALTH] = ZO_PlayerAttributeHealth,
            [COMBAT_MECHANIC_FLAGS_MAGICKA] = ZO_PlayerAttributeMagicka,
            [COMBAT_MECHANIC_FLAGS_STAMINA] = ZO_PlayerAttributeStamina,
        }
    end
    if UnitFrames.IsDefaultFramesModeExtender(UnitFrames.GetEffectiveDefaultFramesMode("Target")) then
        default_controls.reticleover = { [COMBAT_MECHANIC_FLAGS_HEALTH] = ZO_TargetUnitFramereticleover }
        -- UnitFrames.DefaultFrames.reticleover should be always present to hold target classIcon and friendIcon
    else
        UnitFrames.DefaultFrames.reticleover = { ["unitTag"] = "reticleover" }
    end
    -- Now loop through `default_controls` table and create actual labels (if any)
    for unitTag, fields in pairs(default_controls) do
        UnitFrames.DefaultFrames[unitTag] = { ["unitTag"] = unitTag }
        for powerType, parent in pairs(fields) do
            UnitFrames.DefaultFrames[unitTag][powerType] =
            {
                ["label"] = parent:CreateControl("$(parent)LUIEExtenderLabel", CT_LABEL),
                ["color"] = UnitFrames.SV.DefaultTextColour,
            }
            UnitFrames.DefaultFrames[unitTag][powerType].label:SetFont(LUIE.Font.GetDefaultFont())
            UnitFrames.DefaultFrames[unitTag][powerType].label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
            UnitFrames.DefaultFrames[unitTag][powerType].label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
            UnitFrames.DefaultFrames[unitTag][powerType].label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
            UnitFrames.DefaultFrames[unitTag][powerType].label:SetAnchor(CENTER, parent, CENTER)
        end
    end

    -- Reference to target unit frame. this is not an UI control! Used to add custom controls to existing fade-out components table
    UnitFrames.targetUnitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")

    -- When default Target frame is enabled set the threshold value to change color of label and add label to default fade list
    if UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH] then
        local healthEntry = UnitFrames.DefaultFrames.reticleover[COMBAT_MECHANIC_FLAGS_HEALTH]
        healthEntry.threshold = UnitFrames.targetThreshold
        -- Center the label on the bar background rather than the whole frame: the frame's
        -- vertical center is dragged down onto the Level/Name TextArea (anchored below the bar),
        -- which made the health value/percent overlap the target's level and name text.
        healthEntry.label:ClearAnchors()
        healthEntry.label:SetAnchor(CENTER, ZO_TargetUnitFramereticleoverBgContainer, CENTER, 0, 0)
        table.insert(UnitFrames.targetUnitFrame.fadeComponents, healthEntry.label)
    end

    -- Create classIcon and friendIcon: they should work even when default unit frames extender is disabled
    UnitFrames.DefaultFrames.reticleover.classIcon = UnitFrames.targetUnitFrame.frame:CreateControl("$(parent)LUIEClassIcon", CT_TEXTURE)
    UnitFrames.DefaultFrames.reticleover.classIcon:SetDimensions(32, 32)
    UnitFrames.DefaultFrames.reticleover.classIcon:SetHidden(true)
    UnitFrames.DefaultFrames.reticleover.friendIcon = UnitFrames.targetUnitFrame.frame:CreateControl("$(parent)LUIEFriendIcon", CT_TEXTURE)
    UnitFrames.DefaultFrames.reticleover.friendIcon:SetDimensions(32, 32)
    UnitFrames.DefaultFrames.reticleover.friendIcon:SetHidden(true)
    UnitFrames.DefaultFrames.reticleover.friendIcon:SetAnchor(TOPLEFT, ZO_TargetUnitFramereticleoverTextArea, TOPRIGHT, 30, -4)
    -- add those 2 icons to automatic fade list, so fading will be done automatically by game
    table.insert(UnitFrames.targetUnitFrame.fadeComponents, UnitFrames.DefaultFrames.reticleover.classIcon)
    table.insert(UnitFrames.targetUnitFrame.fadeComponents, UnitFrames.DefaultFrames.reticleover.friendIcon)

    -- When default Group frame in use, then create dummy boolean field, so this setting remain constant between /reloadui calls
    if UnitFrames.IsDefaultFramesModeExtender(UnitFrames.GetEffectiveDefaultFramesMode("Group")) then
        UnitFrames.DefaultFrames.SmallGroup = true
    end

    -- Apply fonts
    UnitFrames.DefaultFramesApplyFont()
end

-- Sets out-of-combat transparency values for default user-frames
function UnitFrames.SetDefaultFramesTransparency(min_pct_value, max_pct_value)
    if min_pct_value ~= nil then
        UnitFrames.SV.DefaultOocTransparency = min_pct_value
    end

    if max_pct_value ~= nil then
        UnitFrames.SV.DefaultIncTransparency = max_pct_value
    end

    local min_value = UnitFrames.SV.DefaultOocTransparency * 0.01
    local max_value = UnitFrames.SV.DefaultIncTransparency * 0.01

    local animationIndex = 1
    --- @type ZO_PlayerAttributeBarControl
    local healthBar = ZO_PlayerAttributeHealth
    healthBar.playerAttributeBarObject.timeline:GetAnimation(animationIndex):SetAlphaValues(min_value, max_value)
    --- @type ZO_PlayerAttributeBarControl
    local magickaBar = ZO_PlayerAttributeMagicka
    magickaBar.playerAttributeBarObject.timeline:GetAnimation(animationIndex):SetAlphaValues(min_value, max_value)
    --- @type ZO_PlayerAttributeBarControl
    local staminaBar = ZO_PlayerAttributeStamina
    staminaBar.playerAttributeBarObject.timeline:GetAnimation(animationIndex):SetAlphaValues(min_value, max_value)

    local inCombat = IsUnitInCombat("player")
    ZO_PlayerAttributeHealth:SetAlpha(inCombat and max_value or min_value)
    ZO_PlayerAttributeStamina:SetAlpha(inCombat and max_value or min_value)
    ZO_PlayerAttributeMagicka:SetAlpha(inCombat and max_value or min_value)
end

-- Creates default group unit UI controls on-fly
---
--- @param unitTag string
function UnitFrames.DefaultFramesCreateUnitGroupControls(unitTag)
    -- First make preparation for "groupN" unitTag labels
    if UnitFrames.DefaultFrames[unitTag] == nil then -- If unitTag is already in our list, then skip this
        if "group" == zo_strsub(unitTag, 0, 5) then  -- If it is really a group member unitTag
            local i = zo_strsub(unitTag, 6)
            if _G["ZO_GroupUnitFramegroup" .. i] then
                local parentBar = _G["ZO_GroupUnitFramegroup" .. i .. "Hp"]
                --- @cast parentBar Control
                local parentName = _G["ZO_GroupUnitFramegroup" .. i .. "Name"]
                -- Prepare dimension of regen bar
                local width, height = parentBar:GetDimensions()
                -- Populate UI elements
                UnitFrames.DefaultFrames[unitTag] =
                {
                    ["unitTag"] = unitTag,
                    [COMBAT_MECHANIC_FLAGS_HEALTH] =
                    {
                        label = parentBar:CreateControl("$(parent)LUIEExtenderLabel", CT_LABEL),
                        color = UnitFrames.SV.DefaultTextColour,
                        shield = parentBar:CreateControl("$(parent)LUIEShield", CT_STATUSBAR),
                    },
                    ["classIcon"] = parentName:CreateControl("$(parent)LUIEClassIcon", CT_TEXTURE),
                    ["friendIcon"] = parentName:CreateControl("$(parent)LUIEFriendIcon", CT_TEXTURE),
                }
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label:SetFont(LUIE.Font.GetDefaultFont())
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label:SetAnchor(TOP, parentBar, BOTTOM)
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetAnchor(BOTTOM, parentBar, BOTTOM, 0, 0)
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetDimensions(width - height, height)
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetColor(1, 0.75, 0, 0.5)
                UnitFrames.DefaultFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].shield:SetHidden(true)
                UnitFrames.DefaultFrames[unitTag].classIcon:SetAnchor(RIGHT, parentName, LEFT, -4, 2)
                UnitFrames.DefaultFrames[unitTag].classIcon:SetDimensions(24, 24)
                UnitFrames.DefaultFrames[unitTag].classIcon:SetHidden(true)
                UnitFrames.DefaultFrames[unitTag].friendIcon:SetAnchor(RIGHT, parentName, LEFT, -4, 24)
                UnitFrames.DefaultFrames[unitTag].friendIcon:SetDimensions(24, 24)
                UnitFrames.DefaultFrames[unitTag].friendIcon:SetHidden(true)
                -- Apply selected font
                UnitFrames.DefaultFramesApplyFont(unitTag)
            end
        end
    end
end

--- Refresh ZOS default target level/CP when vanilla reticleover frame is still shown.
--- @param unitTag string
function UnitFrames.RefreshDefaultTargetLevelDisplayIfNeeded(unitTag)
    if unitTag ~= "reticleover" then
        return
    end
    if not DoesUnitExist("reticleover") then
        return
    end
    if UnitFrames.ShouldHideVanillaTargetFrameForCustomTarget() then
        return
    end
    if not IsUnitPlayer("reticleover") then
        return
    end
    UnitFrames.UpdateDefaultLevelTarget()
    UnitFrames.LayoutDefaultReticleoverTargetIcons()
end

local DEFAULT_RETICLEOVER_SOCIAL_ICON_GAP = 2
local DEFAULT_RETICLEOVER_SOCIAL_TEXTAREA_OFFSET_X = 30
local DEFAULT_RETICLEOVER_SOCIAL_ICON_OFFSET_Y = -4
local DEFAULT_RETICLEOVER_VETERANCY_RANK_OFFSET = 20

--- Re-anchor ZOS veterancy rank and LUIE friend/guild/ignore icons on the default reticleover frame.
function UnitFrames.LayoutDefaultReticleoverTargetIcons()
    local allianceRankIcon = ZO_TargetUnitFramereticleoverRankIcon
    local targetVeteranRankIcon = ZO_TargetUnitFramereticleoverVeterancyRankIcon
    if targetVeteranRankIcon and allianceRankIcon then
        targetVeteranRankIcon:ClearAnchors()
        targetVeteranRankIcon:SetAnchor(CENTER, allianceRankIcon, RIGHT, DEFAULT_RETICLEOVER_VETERANCY_RANK_OFFSET, 0)
        -- uncomment to test max rank icons spacing.
        -- targetVeteranRankIcon:SetTexture"/esoui/art/vengeance/ranks/season00/s00_uniquerank_100.dds"
        -- allianceRankIcon:SetTexture("/esoui/art/ava/ava_rankicon_grandoverlord.dds")
    end

    local defaultReticleover = UnitFrames.DefaultFrames.reticleover
    if not defaultReticleover then
        return
    end
    local friendIcon = defaultReticleover.friendIcon
    if not friendIcon or friendIcon:IsHidden() then
        return
    end
    local textArea = ZO_TargetUnitFramereticleoverTextArea

    local anchorTo = textArea
    local offsetX = DEFAULT_RETICLEOVER_SOCIAL_TEXTAREA_OFFSET_X
    local offsetY = DEFAULT_RETICLEOVER_SOCIAL_ICON_OFFSET_Y

    if targetVeteranRankIcon and not targetVeteranRankIcon:IsHidden() then
        anchorTo = targetVeteranRankIcon
        offsetX = DEFAULT_RETICLEOVER_SOCIAL_ICON_GAP
    elseif allianceRankIcon and not allianceRankIcon:IsHidden() then
        anchorTo = allianceRankIcon
        offsetX = DEFAULT_RETICLEOVER_SOCIAL_ICON_GAP
    end

    friendIcon:ClearAnchors()
    friendIcon:SetAnchor(TOPLEFT, anchorTo, TOPRIGHT, offsetX, offsetY)
end

function UnitFrames.UpdateDefaultLevelTarget()
    local targetLevel = ZO_TargetUnitFramereticleoverLevel
    local targetChamp = ZO_TargetUnitFramereticleoverChampionIcon
    local targetName = ZO_TargetUnitFramereticleoverName
    local unitLevel
    local isChampion = IsUnitChampion("reticleover")
    if isChampion then
        unitLevel = GetUnitEffectiveChampionPoints("reticleover")
    else
        unitLevel = GetUnitLevel("reticleover")
    end

    if unitLevel > 0 then
        targetLevel:SetHidden(false)
        targetLevel:SetText(tostring(unitLevel))
        targetName:SetAnchor(TOPLEFT, targetLevel, TOPRIGHT, 10, 0)
    else
        targetLevel:SetHidden(true)
        targetName:SetAnchor(TOPLEFT)
    end

    if isChampion then
        targetChamp:SetHidden(false)
    else
        targetChamp:SetHidden(true)
    end
end

-- HUD_MANAGER:PropagateSettings reverts anchors before this fires (load, resize, gamepad mode).
local function OnDefaultFrameHudPropagateSettings()
    UnitFrames.RepositionDefaultFrames()
end

--- @param element ZO_HUDManager_Element
local function OnDefaultFrameHudOffsetsChanged(element)
    if element:GetControl() ~= ZO_ActionBar1 then
        return
    end
    UnitFrames.RepositionDefaultFrames()
end

--- @param oldState integer
--- @param newState integer
local function OnHudEditorSceneStateChange(oldState, newState)
    if newState ~= SCENE_HIDDEN then
        return
    end
    UnitFrames.RepositionDefaultFrames()
end

function UnitFrames.RegisterDefaultFrameHudCallbacks()
    if defaultFrameHudCallbacksRegistered then
        return
    end
    if ZO_IsConsoleOrGameCoreUI() then
        return
    end

    HUD_MANAGER:RegisterCallback("PropagateSettings", OnDefaultFrameHudPropagateSettings)
    HUD_MANAGER:RegisterCallback("OffsetsChanged", OnDefaultFrameHudOffsetsChanged)
    if HUD_EDITOR_SCENE_KEYBOARD then
        HUD_EDITOR_SCENE_KEYBOARD:RegisterCallback("StateChange", OnHudEditorSceneStateChange)
    end
    defaultFrameHudCallbacksRegistered = true
end
