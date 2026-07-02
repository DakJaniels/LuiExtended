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

local defaultPos = {}

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

-- Save default frame positions
function UnitFrames.SaveDefaultFramePositions()
    -- Get Default Positions
    defaultPos.health = GetAnchorInfo(ZO_PlayerAttributeHealth)
    defaultPos.magicka = GetAnchorInfo(ZO_PlayerAttributeMagicka)
    defaultPos.stamina = GetAnchorInfo(ZO_PlayerAttributeStamina)
    defaultPos.siege = GetAnchorInfo(ZO_PlayerAttributeSiegeHealth)
    defaultPos.ram = GetAnchorInfo(ZO_RAM.control)
    defaultPos.smallGroup = GetAnchorInfo(ZO_SmallGroupAnchorFrame)
end

-- Adjust default frame position.
function UnitFrames.RepositionDefaultFrames()
    if not UnitFrames.SV.RepositionFrames then
        if defaultPos.health then
            ZO_PlayerAttributeHealth:ClearAnchors()
            ZO_PlayerAttributeHealth:SetAnchor(defaultPos.health[1], defaultPos.health[2], defaultPos.health[3], defaultPos.health[4], defaultPos.health[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_PlayerAttributeMagicka:ClearAnchors()
            ZO_PlayerAttributeMagicka:SetAnchor(defaultPos.magicka[1], defaultPos.magicka[2], defaultPos.magicka[3], defaultPos.magicka[4], defaultPos.magicka[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_PlayerAttributeStamina:ClearAnchors()
            ZO_PlayerAttributeStamina:SetAnchor(defaultPos.stamina[1], defaultPos.stamina[2], defaultPos.stamina[3], defaultPos.stamina[4], defaultPos.stamina[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_PlayerAttributeSiegeHealth:ClearAnchors()
            ZO_PlayerAttributeSiegeHealth:SetAnchor(defaultPos.siege[1], defaultPos.siege[2], defaultPos.siege[3], defaultPos.siege[4], defaultPos.siege[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_RAM.control:ClearAnchors()
            ZO_RAM.control:SetAnchor(defaultPos.ram[1], defaultPos.ram[2], defaultPos.ram[3], defaultPos.ram[4], defaultPos.ram[5] - UnitFrames.SV.RepositionFramesAdjust)
            ZO_SmallGroupAnchorFrame:ClearAnchors()
            ZO_SmallGroupAnchorFrame:SetAnchor(defaultPos.smallGroup[1], defaultPos.smallGroup[2], defaultPos.smallGroup[3], defaultPos.smallGroup[4], defaultPos.smallGroup[5] - UnitFrames.SV.RepositionFramesAdjust)
        end
    end

    -- Reposition frames
    if UnitFrames.SV.RepositionFrames then
        -- Shift to center magicka and stamina bars
        ZO_PlayerAttributeHealth:ClearAnchors()
        ZO_PlayerAttributeHealth:SetAnchor(BOTTOM, ActionButton5, TOP, 0, -47 - UnitFrames.SV.RepositionFramesAdjust)
        ZO_PlayerAttributeMagicka:ClearAnchors()
        ZO_PlayerAttributeMagicka:SetAnchor(TOPRIGHT, ZO_PlayerAttributeHealth, BOTTOM, -1, 2)
        ZO_PlayerAttributeStamina:ClearAnchors()
        ZO_PlayerAttributeStamina:SetAnchor(TOPLEFT, ZO_PlayerAttributeHealth, BOTTOM, 1, 2)
        -- Shift to the right siege weapon health and ram control
        ZO_PlayerAttributeSiegeHealth:ClearAnchors()
        ZO_PlayerAttributeSiegeHealth:SetAnchor(CENTER, ZO_PlayerAttributeHealth, CENTER, 300, 0)
        ZO_RAM.control:ClearAnchors()
        ZO_RAM.control:SetAnchor(BOTTOM, ZO_PlayerAttributeHealth, TOP, 300, 0)
        -- Shift a little upwards small group unit frames
        ZO_SmallGroupAnchorFrame:ClearAnchors()
        ZO_SmallGroupAnchorFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 20, 80) -- default is 28,100
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

    local min_value = UnitFrames.SV.DefaultOocTransparency / 100
    local max_value = UnitFrames.SV.DefaultIncTransparency / 100

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
