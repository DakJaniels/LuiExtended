-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- Shared control factories for custom unit frames (no frame-category business rules).
--- @class LUIE.CustomFramesShared
--- @field STAT_POWER_HALO_DRAW_LEVEL integer
--- @field STAT_POWER_TRACK_DRAW_LEVEL integer
--- @field HEALTH_BAR_FILL_DRAW_LEVEL integer
--- @field SHIELD_BAR_FRAME_BASE_NAMES string[]
--- @field FRAME_TLW_BASE_NAMES string[]
--- @field MOVER_ANCHOR_REGISTRY_KEYS string[]
--- @field SMALL_GROUP_SIZE integer
--- @field RAID_GROUP_SIZE integer
--- @field CUSTOM_FRAME_HUD_SCENES ZO_Scene[]
--- @field ForEachMovableAnchorFrame fun(callback: fun(registryKey: string, frame: LUIE_CustomFrameObject, tlw: LUIE_PositionableTopLevelWindow))
--- @field CreateLUIETopLevel fun(globalName: string, templateName: string): TopLevelWindow
--- @field ApplyStackedMemberAnchors fun(parent: Control, unitTagPrefix: string, count: number, startIndex: number|nil)
--- @field CreateMemberRangeFromVirtual fun(parent: Control, baseName: string, templateName: string, rangeMin: number, rangeMax: number)
--- @field RegisterCustomFrameHudFragment fun(tlw: LUIE_PositionableTopLevelWindow): ZO_HUDFadeSceneFragment
--- @field IsCustomFrameHudScene fun(scene: ZO_Scene|nil): boolean
--- @field CreateRegenAnimation fun(parent: Control, anchors: table|nil, dims: table|nil, alpha: number|nil, number: string): UnitFrames.RegenStripControl|nil
--- @field SetHealthBarAbovePowerHalo fun(backdrop: Control, bar: StatusBarControl)
--- @field CreateHealthBarPowerHaloTrack fun(backdrop: Control, bar: StatusBarControl): StatusBarControl|nil
--- @field CreateBarBackgroundHalo fun(backdrop: Control, bar: StatusBarControl, controlNameSuffix: string, zoTextureVirtual: string, animationTimelineVirtual: string): Control|nil
--- @field CreatePossessionHaloAnimation fun(backdrop: Control, bar: StatusBarControl): Control|nil
--- @field CreateIncreasedPowerTexture fun(backdrop: Control, bar: StatusBarControl): Control|nil
--- @field CreateNoHealingFadeAnimation fun(overlay: StatusBarControl, stripeOverlay: StatusBarControl|nil): AnimationTimeline|nil
--- @field CreateCombatGlowBorder fun(backdrop: Control): Control
--- @field CreateDecreasedArmorOverlay fun(parent: Control, small: boolean): Control
local Shared = {}

--- @type LUIE.CustomFramesShared
LUIE.CustomFramesShared = Shared

-- STAT_POWER / possession full-bar halos: lowest layer on backdrop; opaque track + health fill draw above (see ArmorDamage.lua)
Shared.STAT_POWER_HALO_DRAW_LEVEL = 1
Shared.STAT_POWER_TRACK_DRAW_LEVEL = 5
Shared.HEALTH_BAR_FILL_DRAW_LEVEL = 10

Shared.SHIELD_BAR_FRAME_BASE_NAMES = { "player", "reticleover", "companion", "SmallGroup", "RaidGroup", "boss", "AvaPlayerTarget", "PetGroup" }

Shared.FRAME_TLW_BASE_NAMES = { "player", "reticleover", "companion", "SmallGroup", "RaidGroup", "boss", "AvaPlayerTarget", "PetGroup" }

Shared.SMALL_GROUP_SIZE = 4
Shared.RAID_GROUP_SIZE = 12

Shared.MOVER_ANCHOR_REGISTRY_KEYS =
{
    "player",
    "reticleover",
    "companion",
    "SmallGroup1",
    "RaidGroup1",
    "boss1",
    "AvaPlayerTarget",
    "PetGroup1",
}

-- Same table as LUIE.HudScene.GetGameplayScenes() after first build (ZOS HUD_FRAGMENT_GROUP + siege + loot).
Shared.CUSTOM_FRAME_HUD_SCENES = nil

--- Instantiate a custom unit frame top-level window from XML virtual template.
--- @param globalName string
--- @param templateName string
--- @return TopLevelWindow
function Shared.CreateLUIETopLevel(globalName, templateName)
    return CreateControlFromVirtual(globalName, GuiRoot, templateName)
end

--- Vertically stack member controls (first anchors to parent TOPLEFT).
--- @param parent Control
--- @param unitTagPrefix string e.g. "RaidGroup" (GetNamedChild uses "_" .. unitTagPrefix .. i)
--- @param count number
--- @param startIndex number|nil default 1
function Shared.ApplyStackedMemberAnchors(parent, unitTagPrefix, count, startIndex)
    startIndex = startIndex or 1
    local previous
    for offset = 0, count - 1 do
        local i = startIndex + offset
        local control = parent:GetNamedChild("_" .. unitTagPrefix .. i)
        if control then
            control:ClearAnchors()
            if offset == 0 then
                control:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
            else
                control:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, 0, 0)
            end
            previous = control
        end
    end
end

--- @param parent Control
--- @param baseName string
--- @param templateName string
--- @param rangeMin number
--- @param rangeMax number
function Shared.CreateMemberRangeFromVirtual(parent, baseName, templateName, rangeMin, rangeMax)
    CreateControlRangeFromVirtual(baseName, parent, templateName, rangeMin, rangeMax)
end

--- @param callback fun(registryKey: string, frame: LUIE_CustomFrameObject, tlw: LUIE_PositionableTopLevelWindow)
function Shared.ForEachMovableAnchorFrame(callback)
    --- @type UnitFrames
    local UnitFrames = LUIE.UnitFrames
    for keyIndex = 1, #Shared.MOVER_ANCHOR_REGISTRY_KEYS do
        local registryKey = Shared.MOVER_ANCHOR_REGISTRY_KEYS[keyIndex]
        local frame = UnitFrames.CustomFrames[registryKey]
        if frame and frame.tlw then
            callback(registryKey, frame, frame.tlw)
        end
    end
end

--- @param scene ZO_Scene|nil
--- @return boolean
function Shared.IsCustomFrameHudScene(scene)
    return LUIE.HudScene.IsHudGameplayScene(scene)
end

--- Register one HUD fade fragment on all custom-frame gameplay scenes (ZOS UNIT_FRAMES parity).
--- @param tlw LUIE_PositionableTopLevelWindow
--- @return ZO_HUDFadeSceneFragment
function Shared.RegisterCustomFrameHudFragment(tlw)
    return LUIE.HudScene.RegisterHudFadeFragmentOnGameplayScenes(tlw)
end

function Shared.CreateRegenAnimation(parent, anchors, dims, alpha, number)
    local animConfigs =
    {
        degen1 = { texture = LUIE_MEDIA_UNITFRAMES_REGENLEFT_DDS, distanceMult = -0.35, offsetXMult = 0.425 },
        degen2 = { texture = LUIE_MEDIA_UNITFRAMES_REGENRIGHT_DDS, distanceMult = 0.35, offsetXMult = -0.425 },
        regen1 = { texture = LUIE_MEDIA_UNITFRAMES_REGENRIGHT_DDS, distanceMult = 0.35, offsetXMult = 0.075 },
        regen2 = { texture = LUIE_MEDIA_UNITFRAMES_REGENLEFT_DDS, distanceMult = -0.35, offsetXMult = -0.075 },
    }

    local config = animConfigs[number]
    if not config then
        if LUIE.IsDevDebugEnabled() then
            LUIE:Log("Error", "[LUIE] CreateRegenAnimation: Invalid animation number '" .. tostring(number) .. "'.")
        end
        return nil
    end

    if dims == nil or #dims ~= 2 then
        dims = { parent:GetDimensions() }
    end

    local updateDims = { dims[2] * 1.9, dims[2] * 0.85 }
    local control = parent:CreateControl("$(parent)_RegenAnim_" .. number, CT_TEXTURE) --- @type UnitFrames.RegenStripControl
    if anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        control:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    control:SetDimensions(updateDims[1], updateDims[2])
    control:SetTexture(config.texture)
    control:SetDrawLayer(DL_OVERLAY)
    control:SetDrawLevel(parent:GetDrawLevel() + 1)
    control:SetHidden(true)
    control:SetAlpha(alpha or 0)
    local distance = dims[1] * config.distanceMult
    local offsetX = dims[1] * config.offsetXMult

    for i = 0, MAX_ANCHORS - 1 do
        local isValid, _, _, _, _, offsetY = control:GetAnchor(i)
        if isValid then
            control.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("LUIE_RegenAnimationTemplate", control)
            control.animation = control.timeline:GetAnimation(1) --- @type AnimationObjectTranslate
            control.animation:SetTranslateOffsets(offsetX, offsetY, offsetX + distance, offsetY)
            return control
        end
    end

    if LUIE.IsDevDebugEnabled() then
        LUIE:Log("Error", "[LUIE] CreateRegenAnimation: No valid anchors found for animation.")
    end
    return nil
end

function Shared.SetHealthBarAbovePowerHalo(backdrop, bar)
    if not backdrop or not bar then
        return
    end

    bar:SetDrawLevel(Shared.HEALTH_BAR_FILL_DRAW_LEVEL)

    local trauma = backdrop:GetNamedChild("_Trauma")
    if trauma then
        trauma:SetDrawLevel(Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 1)
    end

    local shield = backdrop:GetNamedChild("_Shield")
    if shield then
        shield:SetDrawLevel(Shared.HEALTH_BAR_FILL_DRAW_LEVEL + 2)
    end
end

function Shared.CreateHealthBarPowerHaloTrack(backdrop, bar)
    if not backdrop or not bar then
        return nil
    end
    --- @cast backdrop BackdropControl
    local track = backdrop:GetNamedChild("_PowerHaloTrack") --- @type StatusBarControl
    if not track then
        track = backdrop:CreateControl("$(parent)_PowerHaloTrack", CT_STATUSBAR)
        track:SetAnchor(TOPLEFT, bar, TOPLEFT, 0, 0)
        track:SetAnchor(BOTTOMRIGHT, bar, BOTTOMRIGHT, 0, 0)
        track:SetDrawTier(DT_LOW)
        track:SetDrawLayer(DL_BACKGROUND)
        track:SetDrawLevel(Shared.STAT_POWER_TRACK_DRAW_LEVEL)
        track:SetMinMax(0, 1)
        track:SetValue(1)
        track:SetMouseEnabled(false)
        local r, g, b, a = backdrop:GetCenterColor()
        track:SetColor(r, g, b, a)
    end

    return track
end

function Shared.CreateBarBackgroundHalo(backdrop, bar, controlNameSuffix, zoTextureVirtual, animationTimelineVirtual)
    if not backdrop or not bar then
        return nil
    end

    Shared.CreateHealthBarPowerHaloTrack(backdrop, bar)
    Shared.SetHealthBarAbovePowerHalo(backdrop, bar)

    local halo = CreateControlFromVirtual("$(parent)_" .. controlNameSuffix, backdrop, zoTextureVirtual)
    ApplyTemplateToControl(halo, ZO_GetPlatformTemplate(zoTextureVirtual))
    halo:SetDrawTier(DT_LOW)
    halo:SetDrawLayer(DL_BACKGROUND)
    halo:SetDrawLevel(Shared.STAT_POWER_HALO_DRAW_LEVEL)
    halo:SetAnchor(LEFT, bar, LEFT, -80, 0)
    halo:SetAnchor(RIGHT, bar, RIGHT, 80, 0)
    halo:SetHeight(128)
    halo:SetHidden(true)

    halo.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual(animationTimelineVirtual, halo)
    halo.animation = halo.timeline:GetAnimation(1)
    halo.animation:SetFramerate(32)

    return halo
end

function Shared.CreatePossessionHaloAnimation(backdrop, bar)
    return Shared.CreateBarBackgroundHalo(backdrop, bar, "PossessionHalo", "ZO_PossessionHaloTexture", "PossessionHaloAnimation")
end

function Shared.CreateIncreasedPowerTexture(backdrop, bar)
    return Shared.CreateBarBackgroundHalo(backdrop, bar, "IncreasedPowerHalo", "ZO_IncreasedPowerTexture", "IncreasedPowerAnimation")
end

function Shared.CreateNoHealingFadeAnimation(overlay, stripeOverlay)
    if not overlay then
        return nil
    end

    local fadeTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("LUIE_NoHealingFadeAnimation", overlay)

    if stripeOverlay then
        local stripeFade = fadeTimeline:InsertAnimation(ANIMATION_ALPHA, stripeOverlay, 0)
        stripeFade:SetAlphaValues(0, 1)
        stripeFade:SetDuration(200)
        stripeFade:SetEasingFunction(ZO_EaseInQuadratic)
    end

    fadeTimeline.overlay = overlay
    fadeTimeline.stripe = stripeOverlay

    return fadeTimeline
end

function Shared.CreateCombatGlowBorder(backdrop)
    local glow = CreateControlFromVirtual("$(parent)_CombatGlow", backdrop, "LUIE_CombatGlowBorder")
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)
    return glow
end

--- @param parent Control
--- @param small boolean
--- @return Control
function Shared.CreateDecreasedArmorOverlay(parent, small)
    local templateName = small and "LUIE_DecreasedArmorOverlay_Small" or "LUIE_DecreasedArmorOverlay"
    local control = CreateControlFromVirtual("$(parent)_DecreasedArmorOverlay", parent, templateName)

    control.smallTex = control:GetNamedChild("_SmallTex")
    if not small then
        control.normalTex = control:GetNamedChild("_NormalTex")
    end

    control.smallTex:SetTexture(LUIE_MEDIA_UNITFRAMES_UNITATTRIBUTEVISUALIZER_ATTRIBUTEBAR_DYNAMIC_DECREASEDARMOR_SMALL_DDS)
    if control.normalTex then
        control.normalTex:SetTexture(LUIE_MEDIA_UNITFRAMES_UNITATTRIBUTEVISUALIZER_ATTRIBUTEBAR_DYNAMIC_DECREASEDARMOR_STANDARD_DDS)
    end

    return control
end
