-- -----------------------------------------------------------------------------
--  LuiExtended - LibCustomNames / LibCustomIcons on custom unit frames
--  Optional libraries. CustomNames, CustomIcons, and CustomIconAnimations
--  default off in UnitFrames.Defaults.
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames

--- @class LUIE_CustomFrameObject
local FrameObject = LUIE_CustomFrameObject

--- Custom portrait texture. The animation and the last applied account live on the control.
--- @class LUIE_CustomIconControl : TextureControl
--- @field customIconAnimation AnimationObjectTexture|nil
--- @field customIconAccountName string|nil
--- @field customIconUsesAnimation boolean|nil

local CUSTOM_ICON_FULL_LEFT = 0
local CUSTOM_ICON_FULL_RIGHT = 1
local CUSTOM_ICON_FULL_TOP = 0
local CUSTOM_ICON_FULL_BOTTOM = 1

--- @param iconControl LUIE_CustomIconControl
local function StopCustomIconAnimation(iconControl)
    local animationObject = iconControl.customIconAnimation
    if not animationObject then
        return
    end
    local timeline = animationObject:GetTimeline()
    if timeline and timeline:IsPlaying() then
        timeline:Stop()
    end
end

--- Texture and texture coords are already set by the caller. SetTexture here would reset those coords.
--- @param iconControl LUIE_CustomIconControl
--- @param columns number
--- @param rows number
--- @param frameRate number
local function PlayCustomIconAnimation(iconControl, columns, rows, frameRate)
    local animationObject = iconControl.customIconAnimation
    if not animationObject then
        animationObject = CreateSimpleAnimation(ANIMATION_TEXTURE, iconControl)
        iconControl.customIconAnimation = animationObject
    end
    animationObject:SetImageData(columns, rows)
    animationObject:SetFramerate(frameRate)
    local timeline = animationObject:GetTimeline()
    timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
    if not timeline:IsPlaying() then
        timeline:PlayFromStart()
    end
end

--- @param unitFrame LUIE_CustomFrameObject
--- @param iconControl LUIE_CustomIconControl
local function MatchCustomIconToClassIconSize(unitFrame, iconControl)
    local classIcon = unitFrame.classIcon
    if not classIcon then
        return
    end
    local width, height = classIcon:GetDimensions()
    if width > 0 and height > 0 then
        iconControl:SetDimensions(width, height)
    end
end

--- Hide the portrait and stop its timeline. Safe when the frame has no custom icon control.
--- @param unitFrame LUIE_CustomFrameObject|nil
function UnitFrames.HideCustomPlayerIcon(unitFrame)
    if not unitFrame or not unitFrame.customIcon then
        return
    end
    local iconControl = unitFrame.customIcon --- @type LUIE_CustomIconControl
    StopCustomIconAnimation(iconControl)
    iconControl.customIconAccountName = nil
    iconControl.customIconUsesAnimation = false
    iconControl:SetTextureCoords(CUSTOM_ICON_FULL_LEFT, CUSTOM_ICON_FULL_RIGHT, CUSTOM_ICON_FULL_TOP, CUSTOM_ICON_FULL_BOTTOM)
    iconControl:SetHidden(true)
end

--- LibCustomIcons.GetAnimated currently returns `{ texturePath, columns, rows, fps }`.
--- The unpacked form is `texture, left, right, top, bottom, columns, rows, fps`.
--- @param displayName string
--- @return string|nil texturePath
--- @return number left
--- @return number right
--- @return number top
--- @return number bottom
--- @return number|nil columns
--- @return number|nil rows
--- @return number|nil frameRate
local function ResolveAnimatedCustomIcon(displayName)
    local texturePath, left, right, top, bottom, columns, rows, frameRate = LibCustomIcons.GetAnimated(displayName)
    if type(texturePath) == "table" then
        columns = texturePath[2]
        rows = texturePath[3]
        frameRate = texturePath[4]
        texturePath = texturePath[1]
        left = CUSTOM_ICON_FULL_LEFT
        right = CUSTOM_ICON_FULL_RIGHT
        top = CUSTOM_ICON_FULL_TOP
        bottom = CUSTOM_ICON_FULL_BOTTOM
    end
    if type(texturePath) ~= "string" then
        return nil, CUSTOM_ICON_FULL_LEFT, CUSTOM_ICON_FULL_RIGHT, CUSTOM_ICON_FULL_TOP, CUSTOM_ICON_FULL_BOTTOM, nil, nil, nil
    end
    return texturePath, left or CUSTOM_ICON_FULL_LEFT, right or CUSTOM_ICON_FULL_RIGHT, top or CUSTOM_ICON_FULL_TOP, bottom or CUSTOM_ICON_FULL_BOTTOM, columns, rows, frameRate
end

--- First cell of an animated sheet, used when animation is off and there is no static icon.
--- @param displayName string
--- @return string|nil texturePath
--- @return number left
--- @return number right
--- @return number top
--- @return number bottom
local function ResolveAnimatedCustomIconFirstFrame(displayName)
    local texturePath, left, right, top, bottom, columns, rows = ResolveAnimatedCustomIcon(displayName)
    if type(texturePath) ~= "string" then
        return nil, CUSTOM_ICON_FULL_LEFT, CUSTOM_ICON_FULL_RIGHT, CUSTOM_ICON_FULL_TOP, CUSTOM_ICON_FULL_BOTTOM
    end
    local rightCoord = right
    local bottomCoord = bottom
    if columns and columns > 0 then
        rightCoord = left + ((right - left) / columns)
    end
    if rows and rows > 0 then
        bottomCoord = top + ((bottom - top) / rows)
    end
    return texturePath, left, rightCoord, top, bottomCoord
end

--- @param displayName string
--- @return string|nil texturePath
--- @return number left
--- @return number right
--- @return number top
--- @return number bottom
--- @return number|nil columns
--- @return number|nil rows
--- @return number|nil frameRate
local function ResolveCustomIconTexture(displayName)
    local playAnimation = UnitFrames.SV.CustomIconAnimations == true
    if playAnimation and LibCustomIcons.HasAnimated(displayName) then
        local texturePath, left, right, top, bottom, columns, rows, frameRate = ResolveAnimatedCustomIcon(displayName)
        if texturePath and columns and rows and frameRate and columns > 0 and rows > 0 and frameRate > 0 then
            return texturePath, left, right, top, bottom, columns, rows, frameRate
        end
    end
    if LibCustomIcons.HasStatic(displayName) then
        local texturePath, left, right, top, bottom = LibCustomIcons.GetStatic(displayName)
        if type(texturePath) == "string" then
            return texturePath, left or CUSTOM_ICON_FULL_LEFT, right or CUSTOM_ICON_FULL_RIGHT, top or CUSTOM_ICON_FULL_TOP, bottom or CUSTOM_ICON_FULL_BOTTOM, nil, nil, nil
        end
    end
    if LibCustomIcons.HasAnimated(displayName) then
        local texturePath, left, right, top, bottom = ResolveAnimatedCustomIconFirstFrame(displayName)
        if texturePath then
            return texturePath, left, right, top, bottom, nil, nil, nil
        end
    end
    return nil, CUSTOM_ICON_FULL_LEFT, CUSTOM_ICON_FULL_RIGHT, CUSTOM_ICON_FULL_TOP, CUSTOM_ICON_FULL_BOTTOM, nil, nil, nil
end

--- Colored LibCustomNames entry for this player, or nil when the option is off, the library is missing, or this account has no custom name.
--- @param unitTag string|nil
--- @return string|nil customName
function UnitFrames.GetCustomPlayerName(unitTag)
    if not UnitFrames.SV or UnitFrames.SV.CustomNames ~= true then
        return nil
    end
    if LibCustomNames == nil then
        return nil
    end
    if unitTag == nil or unitTag == "" or not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) then
        return nil
    end
    local displayName = GetUnitDisplayName(unitTag)
    if displayName == nil or displayName == "" then
        return nil
    end
    local customName = LibCustomNames.Get(displayName, true)
    if customName == nil or customName == "" then
        return nil
    end
    return customName
end

--- Apply or hide the sibling custom-icon texture. Does not change the class icon.
--- @param unitFrame LUIE_CustomFrameObject|nil
function UnitFrames.ApplyCustomPlayerIcon(unitFrame)
    if not unitFrame or not unitFrame.customIcon then
        return
    end
    local iconControl = unitFrame.customIcon --- @type LUIE_CustomIconControl
    local unitTag = unitFrame.unitTag
    local showCustomIcon = UnitFrames.SV and UnitFrames.SV.CustomIcons == true and LibCustomIcons ~= nil
    if showCustomIcon and unitTag == "player" and UnitFrames.SV.PlayerEnableYourname ~= true then
        showCustomIcon = false
    end
    if showCustomIcon and (unitTag == nil or unitTag == "" or not DoesUnitExist(unitTag) or not IsUnitPlayer(unitTag) or not IsUnitOnline(unitTag)) then
        showCustomIcon = false
    end
    local displayName = nil
    if showCustomIcon then
        displayName = GetUnitDisplayName(unitTag)
        if displayName == nil or displayName == "" then
            showCustomIcon = false
        end
    end

    local texturePath, left, right, top, bottom, columns, rows, frameRate
    if showCustomIcon then
        texturePath, left, right, top, bottom, columns, rows, frameRate = ResolveCustomIconTexture(displayName)
        if texturePath == nil then
            showCustomIcon = false
        end
    end
    if not showCustomIcon then
        UnitFrames.HideCustomPlayerIcon(unitFrame)
        return
    end

    local useAnimation = columns ~= nil and rows ~= nil and frameRate ~= nil
    MatchCustomIconToClassIconSize(unitFrame, iconControl)
    if iconControl.customIconAccountName == displayName and iconControl.customIconUsesAnimation == useAnimation and not iconControl:IsControlHidden() then
        return
    end

    StopCustomIconAnimation(iconControl)
    iconControl:SetTexture(texturePath)
    iconControl:SetTextureCoords(left, right, top, bottom)
    iconControl:SetHidden(false)
    iconControl.customIconAccountName = displayName
    iconControl.customIconUsesAnimation = useAnimation
    if useAnimation then
        PlayCustomIconAnimation(iconControl, columns, rows, frameRate)
    end
end

--- Re-anchor after the portrait is shown or hidden outside a full static-control pass (offline label, settings).
--- @param unitFrame LUIE_CustomFrameObject|nil
function UnitFrames.RelayoutCustomPlayerIcon(unitFrame)
    if not unitFrame or not unitFrame.customIcon then
        return
    end
    if unitFrame.frameCategory == "raid" then
        if unitFrame.raidTemplate == UnitFrames.RAID_FRAME_TEMPLATE_EXPANDED then
            UnitFrames.ApplyRaidExpandedMemberLayout(unitFrame)
        else
            UnitFrames.LayoutCompactRaidCustomIcon(unitFrame)
        end
        return
    end
    if FrameObject.HasCustomTopInfoFrameCategory(unitFrame) then
        FrameObject.LayoutTopInfoForFrame(unitFrame)
    end
end

--- Settings checkbox: refresh names and portraits without a reload.
function UnitFrames.RefreshCustomIdentityFrames()
    local function RefreshCustomFrame(unitFrame)
        if unitFrame == nil then
            return
        end
        UnitFrames.UpdateStaticControls(unitFrame)
    end
    RefreshCustomFrame(UnitFrames.CustomFrames["player"])
    RefreshCustomFrame(UnitFrames.CustomFrames["reticleover"])
    RefreshCustomFrame(UnitFrames.CustomFrames["AvaPlayerTarget"])
    for index = 1, 4 do
        RefreshCustomFrame(UnitFrames.CustomFrames["SmallGroup" .. index])
    end
    for index = 1, 12 do
        RefreshCustomFrame(UnitFrames.CustomFrames["RaidGroup" .. index])
    end
    UnitFrames.CustomFramesApplyLayoutGroup(false)
    UnitFrames.CustomFramesApplyLayoutRaid(false)
end
