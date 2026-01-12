--- @diagnostic disable: missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local moduleName = UnitFrames.moduleName
local eventManager = GetEventManager()
local windowManager = GetWindowManager()
local sceneManager = SCENE_MANAGER

-- -----------------------------------------------------------------------------

-- Default Regen/degen animation used on default group frames and custom frames
local function CreateRegenAnimation(parent, anchors, dims, alpha, number)
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
            LUIE.Error("[LUIE] CreateRegenAnimation: Invalid animation number '" .. tostring(number) .. "'.")
        end
        return nil
    end

    if #dims ~= 2 then
        dims = { parent:GetDimensions() }
    end

    local updateDims = { dims[2] * 1.9, dims[2] * 0.85 }
    local control = windowManager:CreateControl(nil, parent, CT_TEXTURE)
    if anchors ~= nil and #anchors >= 2 and #anchors <= 5 then
        control:SetAnchor(anchors[1], anchors[5] or parent, anchors[2], anchors[3] or 0, anchors[4] or 0)
    end
    control:SetDimensions(updateDims[1], updateDims[2])
    control:SetTexture(config.texture)
    control:SetDrawLayer(2)
    control:SetHidden(true)
    local distance = dims[1] * config.distanceMult
    local offsetX = dims[1] * config.offsetXMult

    control:SetAlpha(alpha or 0)
    control:SetDrawLayer(DL_CONTROLS)

    -- Find the first valid anchor and set up the animation
    for i = 0, MAX_ANCHORS - 1 do
        local isValid, _, _, _, _, offsetY = control:GetAnchor(i)
        if isValid then
            -- Use XML-defined animation timeline template
            control.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("LUIE_RegenAnimationTemplate", control)

            -- Configure translate animation with dynamic offsets based on bar size
            control.animation = control.timeline:GetAnimation(1)
            control.animation:SetTranslateOffsets(offsetX, offsetY, offsetX + distance, offsetY)

            return control
        end
    end

    if LUIE.IsDevDebugEnabled() then
        LUIE.Error("[LUIE] CreateRegenAnimation: No valid anchors found for animation.")
    end
    return nil
end

-- Possession halo animated texture (32-frame sprite sheet: 4 columns x 8 rows)
local function CreatePossessionHaloAnimation(backdrop)
    local halo = windowManager:CreateControl(nil, backdrop, CT_TEXTURE)
    halo:SetTexture("EsoUI/Art/UnitAttributeVisualizer/possession_animatedHalo_32fr.dds")
    halo:SetDrawLayer(DL_BACKGROUND)
    halo:SetAnchor(LEFT, backdrop, LEFT, -80, 0)
    halo:SetAnchor(RIGHT, backdrop, RIGHT, 80, 0)
    halo:SetHeight(128)
    halo:SetDrawTier(DT_LOW)
    halo:SetHidden(true)

    -- Use XML-defined animation timeline
    halo.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("LUIE_PossessionHaloAnimation", halo)
    halo.animation = halo.timeline:GetAnimation(1)

    return halo
end

-- No-healing fade animation (controls overlay and stripe)
local function CreateNoHealingFadeAnimation(overlay, stripeOverlay)
    if not overlay then
        return nil
    end

    -- Use XML-defined animation timeline
    local fadeTimeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("LUIE_NoHealingFadeAnimation", overlay)

    -- Add stripe overlay to same timeline if provided (custom LUIE feature)
    if stripeOverlay then
        local stripeFade = fadeTimeline:InsertAnimation(ANIMATION_ALPHA, stripeOverlay, 0)
        stripeFade:SetAlphaValues(0, 1)
        stripeFade:SetDuration(200)
        stripeFade:SetEasingFunction(ZO_EaseInQuadratic)
    end

    -- Store references for OnStop handler
    fadeTimeline.overlay = overlay
    fadeTimeline.stripe = stripeOverlay

    return fadeTimeline
end

-- Combat glow border (static red glow for group frames in combat)
local function CreateCombatGlowBorder(backdrop)
    -- Create from XML virtual template with parent-based unique name
    local parentName = backdrop:GetName() or ("LUIE_UF_Backdrop_" .. tostring(backdrop))
    local uniqueName = parentName .. "_CombatGlow"

    local glow = windowManager:CreateControlFromVirtual(uniqueName, backdrop, "LUIE_CombatGlowBorder")

    -- Configure blend mode (can't be set in XML)
    glow:SetBlendMode(TEX_BLEND_MODE_ADD)

    return glow
end

-- Decreased armour overlay visuals
---
---@param parent Control
---@param small boolean
---@return Control
local function CreateDecreasedArmorOverlay(parent, small)
    -- Create from XML virtual template with parent-based unique name
    local parentName = parent:GetName() or ("LUIE_UF_Parent_" .. tostring(parent))
    local uniqueName = parentName .. "_DecreasedArmorOverlay"

    local templateName = small and "LUIE_DecreasedArmorOverlay_Small" or "LUIE_DecreasedArmorOverlay"
    local control = windowManager:CreateControlFromVirtual(uniqueName, parent, templateName)

    -- Get texture references
    control.smallTex = control:GetNamedChild("_SmallTex") ---@type TextureControl
    if not small then
        control.normalTex = control:GetNamedChild("_NormalTex") ---@type TextureControl
    end

    -- Set texture files
    control.smallTex:SetTexture(LUIE_MEDIA_UNITFRAMES_UNITATTRIBUTEVISUALIZER_ATTRIBUTEBAR_DYNAMIC_DECREASEDARMOR_SMALL_DDS)
    if control.normalTex then
        control.normalTex:SetTexture(LUIE_MEDIA_UNITFRAMES_UNITATTRIBUTEVISUALIZER_ATTRIBUTEBAR_DYNAMIC_DECREASEDARMOR_STANDARD_DDS)
    end

    return control
end

-- Helper to create the Player Frame
local function CreatePlayerFrame()
    if UnitFrames.SV.CustomFramesPlayer then
        -- Get references to XML-created controls
        local playerTlw = LUIE_CustomPlayerFrame
        playerTlw.customPositionAttr = "CustomFramesPlayerFramePos"
        playerTlw.preview = playerTlw:GetNamedChild("_Preview")
        local player = playerTlw:GetNamedChild("_Player")
        local topInfo = player:GetNamedChild("_TopInfo")
        local botInfo = player:GetNamedChild("_BotInfo")
        local buffAnchor = player:GetNamedChild("_BuffAnchor")
        local phb = player:GetNamedChild("_Health")
        local pmb = player:GetNamedChild("_Magicka")
        local psb = player:GetNamedChild("_Stamina")
        local alt = botInfo:GetNamedChild("_Alternative")
        local pli = topInfo:GetNamedChild("_LevelIcon")

        -- Add to scene fragments (controls are already created via XML)
        local fragment = ZO_HUDFadeSceneFragment:New(playerTlw, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

        UnitFrames.CustomFrames["player"] =
        {
            ["unitTag"] = "player",
            ["tlw"] = playerTlw,
            ["control"] = player,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = phb,
                ["labelOne"] = phb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = phb:GetNamedChild("_LabelTwo"),
                ["trauma"] = phb:GetNamedChild("_Trauma"),
                ["bar"] = phb:GetNamedChild("_Bar"),
                ["shield"] = phb:GetNamedChild("_Shield"),
                ["noHealingOverlay"] = phb:GetNamedChild("_NoHealingOverlay"),
                ["noHealingStripe"] = phb:GetNamedChild("_NoHealingStripe"),
                ["possessionOverlay"] = phb:GetNamedChild("_PossessionOverlay"),
                ["threshold"] = UnitFrames.healthThreshold,
            },
            [COMBAT_MECHANIC_FLAGS_MAGICKA] =
            {
                ["backdrop"] = pmb,
                ["labelOne"] = pmb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = pmb:GetNamedChild("_LabelTwo"),
                ["bar"] = pmb:GetNamedChild("_Bar"),
                ["threshold"] = UnitFrames.magickaThreshold,
            },
            [COMBAT_MECHANIC_FLAGS_STAMINA] =
            {
                ["backdrop"] = psb,
                ["labelOne"] = psb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = psb:GetNamedChild("_LabelTwo"),
                ["bar"] = psb:GetNamedChild("_Bar"),
                ["threshold"] = UnitFrames.staminaThreshold,
            },
            ["alternative"] =
            {
                ["backdrop"] = alt,
                ["enlightenment"] = alt:GetNamedChild("_Enlightenment"),
                ["bar"] = alt:GetNamedChild("_Bar"),
                ["icon"] = alt:GetNamedChild("_Icon"),
            },
            ["topInfo"] = topInfo,
            ["name"] = topInfo:GetNamedChild("_Name"),
            ["levelIcon"] = pli,
            ["level"] = topInfo:GetNamedChild("_Level"),
            ["classIcon"] = topInfo:GetNamedChild("_ClassIcon"),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["buffs"] = playerTlw:GetNamedChild("_Buffs"),
            ["debuffs"] = playerTlw:GetNamedChild("_Debuffs"),
        }

        UnitFrames.CustomFrames["player"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

        -- Hide labels based on settings
        local labelSettings =
        {
            { flag = UnitFrames.SV.HideLabelHealth,  mechanic = COMBAT_MECHANIC_FLAGS_HEALTH  },
            { flag = UnitFrames.SV.HideLabelStamina, mechanic = COMBAT_MECHANIC_FLAGS_STAMINA },
            { flag = UnitFrames.SV.HideLabelMagicka, mechanic = COMBAT_MECHANIC_FLAGS_MAGICKA },
        }

        local settingKey = nil
        local setting
        while true do
            settingKey, setting = next(labelSettings, settingKey)
            if settingKey == nil then break end
            if setting.flag then
                UnitFrames.CustomFrames["player"][setting.mechanic].labelOne:SetHidden(true)
                UnitFrames.CustomFrames["player"][setting.mechanic].labelTwo:SetHidden(true)
            end
        end

        UnitFrames.CustomFrames["controlledsiege"] =
        {
            ["unitTag"] = "controlledsiege",
        }
    end
end

-- Helper to create the Target Frame
local function CreateTargetFrame()
    if UnitFrames.SV.CustomFramesTarget then
        -- Get references to XML-created controls
        local targetTlw = LUIE_CustomTargetFrame
        targetTlw.customPositionAttr = "CustomFramesTargetFramePos"
        targetTlw.preview = targetTlw:GetNamedChild("_Preview")
        targetTlw.previewLabel = targetTlw.preview:GetNamedChild("_Label")
        local target = targetTlw:GetNamedChild("_Target")
        local topInfo = target:GetNamedChild("_TopInfo")
        local botInfo = target:GetNamedChild("_BotInfo")
        local buffAnchor = target:GetNamedChild("_BuffAnchor")
        local thb = target:GetNamedChild("_Health")
        local tli = topInfo:GetNamedChild("_LevelIcon")
        local ari = botInfo:GetNamedChild("_AvaRankIcon")

        local buffs, debuffs
        if UnitFrames.SV.PlayerFrameOptions == 1 then
            buffs = targetTlw:GetNamedChild("_Buffs")
            debuffs = targetTlw:GetNamedChild("_Debuffs")
        else
            buffs = targetTlw:GetNamedChild("_Debuffs")
            debuffs = targetTlw:GetNamedChild("_Buffs")
        end

        local fragment = ZO_HUDFadeSceneFragment:New(targetTlw, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

        UnitFrames.CustomFrames["reticleover"] =
        {
            ["unitTag"] = "reticleover",
            ["tlw"] = targetTlw,
            ["control"] = target,
            ["canHide"] = true,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = thb,
                ["labelOne"] = thb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = thb:GetNamedChild("_LabelTwo"),
                ["trauma"] = thb:GetNamedChild("_Trauma"),
                ["bar"] = thb:GetNamedChild("_Bar"),
                ["invulnerable"] = thb:GetNamedChild("_Invulnerable"),
                ["invulnerableInlay"] = thb:GetNamedChild("_InvulnerableInlay"),
                ["shield"] = thb:GetNamedChild("_Shield"),
                ["noHealingOverlay"] = thb:GetNamedChild("_NoHealingOverlay"),
                ["noHealingStripe"] = thb:GetNamedChild("_NoHealingStripe"),
                ["possessionOverlay"] = thb:GetNamedChild("_PossessionOverlay"),
                ["threshold"] = UnitFrames.targetThreshold,
            },
            ["topInfo"] = topInfo,
            ["name"] = topInfo:GetNamedChild("_Name"),
            ["levelIcon"] = tli,
            ["level"] = topInfo:GetNamedChild("_Level"),
            ["classIcon"] = topInfo:GetNamedChild("_ClassIcon"),
            ["className"] = topInfo:GetNamedChild("_ClassName"),
            ["friendIcon"] = topInfo:GetNamedChild("_FriendIcon"),
            ["star1"] = topInfo:GetNamedChild("_Star1"),
            ["star2"] = topInfo:GetNamedChild("_Star2"),
            ["star3"] = topInfo:GetNamedChild("_Star3"),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["title"] = botInfo:GetNamedChild("_Title"),
            ["avaRankIcon"] = ari,
            ["avaRank"] = botInfo:GetNamedChild("_AvaRank"),
            ["dead"] = thb:GetNamedChild("_Dead"),
            ["skull"] = target:GetNamedChild("_Skull"),
            ["buffs"] = buffs,
            ["debuffs"] = debuffs,
        }
        UnitFrames.CustomFrames["reticleover"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        UnitFrames.CustomFrames["reticleover"].className:SetDrawLayer(DL_BACKGROUND)
    end
end

-- Helper to create the Ava Player Target Frame
local function CreateAvaPlayerTargetFrame()
    if UnitFrames.SV.AvaCustFramesTarget then
        -- Get references to XML-created controls
        local targetTlw = LUIE_CustomAvaPlayerTargetFrame
        targetTlw.customPositionAttr = "AvaCustFramesTargetFramePos"
        targetTlw.preview = targetTlw:GetNamedChild("_Preview")
        targetTlw.previewLabel = targetTlw.preview:GetNamedChild("_Label")
        local target = targetTlw:GetNamedChild("_Target")
        local topInfo = target:GetNamedChild("_TopInfo")
        local botInfo = target:GetNamedChild("_BotInfo")
        local buffAnchor = target:GetNamedChild("_BuffAnchor")
        local thb = target:GetNamedChild("_Health")
        local cn = botInfo:GetNamedChild("_ClassName")

        local fragment = ZO_HUDFadeSceneFragment:New(targetTlw, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

        UnitFrames.CustomFrames["AvaPlayerTarget"] =
        {
            ["unitTag"] = "reticleover",
            ["tlw"] = targetTlw,
            ["control"] = target,
            ["canHide"] = true,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = thb,
                ["label"] = thb:GetNamedChild("_Label"),
                ["labelOne"] = thb:GetNamedChild("_LabelOne"),
                ["labelTwo"] = thb:GetNamedChild("_LabelTwo"),
                ["trauma"] = thb:GetNamedChild("_Trauma"),
                ["bar"] = thb:GetNamedChild("_Bar"),
                ["invulnerable"] = thb:GetNamedChild("_Invulnerable"),
                ["invulnerableInlay"] = thb:GetNamedChild("_InvulnerableInlay"),
                ["shield"] = thb:GetNamedChild("_Shield"),
                ["noHealingOverlay"] = thb:GetNamedChild("_NoHealingOverlay"),
                ["noHealingStripe"] = thb:GetNamedChild("_NoHealingStripe"),
                ["possessionOverlay"] = thb:GetNamedChild("_PossessionOverlay"),
                ["threshold"] = UnitFrames.targetThreshold,
            },
            ["topInfo"] = topInfo,
            ["name"] = topInfo:GetNamedChild("_Name"),
            ["classIcon"] = topInfo:GetNamedChild("_ClassIcon"),
            ["avaRankIcon"] = topInfo:GetNamedChild("_AvaRankIcon"),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["className"] = cn,
            ["title"] = botInfo:GetNamedChild("_Title"),
            ["avaRank"] = botInfo:GetNamedChild("_AvaRank"),
            ["dead"] = thb:GetNamedChild("_Dead"),
        }

        UnitFrames.CustomFrames["AvaPlayerTarget"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Percentage%"
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].labelOne.format = "Current + Shield"
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].labelTwo.format = "Max"

        UnitFrames.AvaCustFrames["reticleover"] = UnitFrames.CustomFrames["AvaPlayerTarget"]
    end
end

-- Helper to create the Small Group Frames
local function CreateSmallGroupFrames()
    if UnitFrames.SV.CustomFramesGroup then
        -- Get references to XML-created controls
        local group = LUIE_CustomSmallGroupFrame
        group.customPositionAttr = "CustomFramesGroupFramePos"
        group.preview = group:GetNamedChild("_Preview")
        group.previewLabel = group.preview:GetNamedChild("_Label")

        -- Add to scene fragments (controls are already created via XML)
        local fragment = ZO_HUDFadeSceneFragment:New(group, 0, 0)

        local sceneList = { "hud", "hudui", "siegeBar", "siegeBarUI", "loot" }
        local sceneKey = nil
        local scene
        while true do
            sceneKey, scene = next(sceneList, sceneKey)
            if sceneKey == nil then break end
            sceneManager:GetScene(scene):AddFragment(fragment)
        end

        for i = 1, 4 do
            local unitTag = "SmallGroup" .. i
            local control = group:GetNamedChild("_" .. unitTag)
            local topInfo = control:GetNamedChild("_TopInfo")
            local ghb = control:GetNamedChild("_Health")
            local gli = topInfo:GetNamedChild("_LevelIcon")

            -- Get container for LibGroupBroadcast integrations (positioned to right of health bar)
            local libGroupContainer = control:GetNamedChild("_LibGroupContainer")
            if not libGroupContainer then
                if LUIE.IsDevDebugEnabled() then
                    LUIE.Error("[LUIE] CreateSmallGroupFrames: Failed to get _LibGroupContainer for " .. unitTag)
                end
            end

            -- Create combat glow animation
            local combatGlow = CreateCombatGlowBorder(ghb)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = group,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = ghb,
                    ["labelOne"] = ghb:GetNamedChild("_LabelOne"),
                    ["labelTwo"] = ghb:GetNamedChild("_LabelTwo"),
                    ["trauma"] = ghb:GetNamedChild("_Trauma"),
                    ["bar"] = ghb:GetNamedChild("_Bar"),
                    ["shield"] = ghb:GetNamedChild("_Shield"),
                    ["noHealingOverlay"] = ghb:GetNamedChild("_NoHealingOverlay"),
                    ["noHealingStripe"] = ghb:GetNamedChild("_NoHealingStripe"),
                    ["possessionOverlay"] = ghb:GetNamedChild("_PossessionOverlay"),
                    ["combatGlow"] = combatGlow,
                },
                ["topInfo"] = topInfo,
                ["name"] = topInfo:GetNamedChild("_Name"),
                ["levelIcon"] = gli,
                ["level"] = topInfo:GetNamedChild("_Level"),
                ["classIcon"] = topInfo:GetNamedChild("_ClassIcon"),
                ["friendIcon"] = topInfo:GetNamedChild("_FriendIcon"),
                ["roleIcon"] = ghb:GetNamedChild("_RoleIcon"),
                ["dead"] = ghb:GetNamedChild("_Dead"),
                ["leader"] = topInfo:GetNamedChild("_Leader"),
                ["libGroupContainer"] = libGroupContainer,
                ["resourceMagicka"] =
                {
                    ["backdrop"] = control:GetNamedChild("_ResourceMagicka"),
                    ["bar"] = control:GetNamedChild("_ResourceMagicka"):GetNamedChild("_Bar"),
                },
                ["resourceStamina"] =
                {
                    ["backdrop"] = control:GetNamedChild("_ResourceStamina"),
                    ["bar"] = control:GetNamedChild("_ResourceStamina"):GetNamedChild("_Bar"),
                },
            }

            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            control.defaultUnitTag = GetGroupUnitTagByIndex(i)
            control:SetMouseEnabled(true)
            control:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)
            topInfo.defaultUnitTag = GetGroupUnitTagByIndex(i)
            topInfo:SetMouseEnabled(true)
            topInfo:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)

            local realUnitTag = GetGroupUnitTagByIndex(i)
            if realUnitTag then
                UnitFrames.CustomFrames[realUnitTag] = UnitFrames.CustomFrames[unitTag]
            end
        end
    end
end

-- Helper to create the Raid Group Frames
local function CreateRaidGroupFrames()
    if UnitFrames.SV.CustomFramesRaid then
        -- Get references to XML-created controls
        local raid = LUIE_CustomRaidGroupFrame
        raid.customPositionAttr = "CustomFramesRaidFramePos"
        raid.preview = raid:GetNamedChild("_Preview")
        raid.previewLabel = raid.preview:GetNamedChild("_Label")

        -- Add to scene fragments (controls are already created via XML)
        local fragment = ZO_HUDFadeSceneFragment:New(raid, 0, 0)

        local sceneList = { "hud", "hudui", "siegeBar", "siegeBarUI", "loot" }
        local sceneKey = nil
        local scene
        while true do
            sceneKey, scene = next(sceneList, sceneKey)
            if sceneKey == nil then break end
            sceneManager:GetScene(scene):AddFragment(fragment)
        end

        for i = 1, 12 do
            local unitTag = "RaidGroup" .. i
            local control = raid:GetNamedChild("_" .. unitTag)
            local rhb = control:GetNamedChild("_Health")

            -- Create container for LibGroupBroadcast integrations (positioned to right of health bar)
            local libGroupContainer = control:GetNamedChild("_LibGroupContainer")

            -- Get resource bars from XML for LibGroupBroadcast integration
            local magBackdrop = control:GetNamedChild("_ResourceMagicka")
            local stamBackdrop = control:GetNamedChild("_ResourceStamina")

            -- Create combat glow animation
            local combatGlow = CreateCombatGlowBorder(rhb)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = raid,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = rhb,
                    ["label"] = rhb:GetNamedChild("_Label"),
                    ["trauma"] = rhb:GetNamedChild("_Trauma"),
                    ["bar"] = rhb:GetNamedChild("_Bar"),
                    ["shield"] = rhb:GetNamedChild("_Shield"),
                    ["noHealingOverlay"] = rhb:GetNamedChild("_NoHealingOverlay"),
                    ["noHealingStripe"] = rhb:GetNamedChild("_NoHealingStripe"),
                    ["possessionOverlay"] = rhb:GetNamedChild("_PossessionOverlay"),
                    ["combatGlow"] = combatGlow,
                },
                ["name"] = rhb:GetNamedChild("_Name"),
                ["roleIcon"] = rhb:GetNamedChild("_RoleIcon"),
                ["classIcon"] = rhb:GetNamedChild("_ClassIcon"),
                ["dead"] = rhb:GetNamedChild("_Dead"),
                ["leader"] = rhb:GetNamedChild("_Leader"),
                ["libGroupContainer"] = libGroupContainer,
                ["resourceMagicka"] =
                {
                    ["backdrop"] = magBackdrop,
                    ["bar"] = magBackdrop:GetNamedChild("_Bar"),
                },
                ["resourceStamina"] =
                {
                    ["backdrop"] = stamBackdrop,
                    ["bar"] = stamBackdrop:GetNamedChild("_Bar"),
                },
            }
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

            control.defaultUnitTag = GetGroupUnitTagByIndex(i)
            control:SetMouseEnabled(true)
            control:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)

            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"

            local realUnitTag = GetGroupUnitTagByIndex(i)
            if realUnitTag then
                UnitFrames.CustomFrames[realUnitTag] = UnitFrames.CustomFrames[unitTag]
            end
        end
    end
end

-- Helper to create the Pet Frames
local function CreatePetFrames()
    if UnitFrames.SV.CustomFramesPet then
        -- Get references to XML-created controls
        local pet = LUIE_CustomPetFrame
        pet.customPositionAttr = "CustomFramesPetFramePos"
        pet.preview = pet:GetNamedChild("_Preview")
        pet.previewLabel = pet.preview:GetNamedChild("_Label")

        -- Add to scene fragments (controls are already created via XML)
        local fragment = ZO_HUDFadeSceneFragment:New(pet, 0, 0)

        local sceneList = { "hud", "hudui", "siegeBar", "siegeBarUI", "loot" }
        local sceneKey = nil
        local scene
        while true do
            sceneKey, scene = next(sceneList, sceneKey)
            if sceneKey == nil then break end
            sceneManager:GetScene(scene):AddFragment(fragment)
        end

        for i = 1, 7 do
            local unitTag = "PetGroup" .. i
            local control = pet:GetNamedChild("_" .. unitTag)
            local shb = control:GetNamedChild("_Health")

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = pet,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = shb,
                    ["label"] = shb:GetNamedChild("_Label"),
                    ["trauma"] = shb:GetNamedChild("_Trauma"),
                    ["bar"] = shb:GetNamedChild("_Bar"),
                    ["shield"] = shb:GetNamedChild("_Shield"),
                    ["noHealingOverlay"] = shb:GetNamedChild("_NoHealingOverlay"),
                    ["noHealingStripe"] = shb:GetNamedChild("_NoHealingStripe"),
                    ["possessionOverlay"] = shb:GetNamedChild("_PossessionOverlay"),
                },
                ["dead"] = shb:GetNamedChild("_Dead"),
                ["name"] = shb:GetNamedChild("_Name"),
            }
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"
        end
    end
end

-- Helper to create the Companion Frame
local function CreateCompanionFrame()
    if UnitFrames.SV.CustomFramesCompanion then
        -- Get references to XML-created controls
        local companionTlw = LUIE_CustomCompanionFrame
        companionTlw.customPositionAttr = "CustomFramesCompanionFramePos"
        companionTlw.preview = companionTlw:GetNamedChild("_Preview")
        companionTlw.previewLabel = companionTlw.preview:GetNamedChild("_Label") ---@type LabelControl
        -- Update font to use better readable font
        if IsConsoleUI() and LUIE.ConsoleMoverHelper then
            local fontName = "LUIE Default Font"
            if LUIE.Fonts and LUIE.Fonts[fontName] then
                local fontSize = 16
                local fontStyle = "soft-shadow-thick"
                local fontString = LUIE.CreateFontString(fontName, fontSize, fontStyle)
                companionTlw.previewLabel:SetFont(fontString)
            else
                if IsInGamepadPreferredMode() then
                    companionTlw.previewLabel:SetFont("$(GAMEPAD_MEDIUM_FONT)|16|soft-shadow-thick")
                else
                    companionTlw.previewLabel:SetFont("$(MEDIUM_FONT)|16|soft-shadow-thick")
                end
            end
        end

        -- Add to scene fragments (controls are already created via XML)
        local fragment = ZO_HUDFadeSceneFragment:New(companionTlw, 0, 0)

        local sceneList = { "hud", "hudui", "siegeBar", "siegeBarUI", "loot" }
        local sceneKey = nil
        local scene
        while true do
            sceneKey, scene = next(sceneList, sceneKey)
            if sceneKey == nil then break end
            sceneManager:GetScene(scene):AddFragment(fragment)
        end

        local companion = companionTlw:GetNamedChild("_Companion")
        local shb = companion:GetNamedChild("_Health")

        UnitFrames.CustomFrames["companion"] =
        {
            ["unitTag"] = "companion",
            ["tlw"] = companionTlw,
            ["control"] = companion,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = shb,
                ["label"] = shb:GetNamedChild("_Label"),
                ["trauma"] = shb:GetNamedChild("_Trauma"),
                ["bar"] = shb:GetNamedChild("_Bar"),
                ["shield"] = shb:GetNamedChild("_Shield"),
                ["noHealingOverlay"] = shb:GetNamedChild("_NoHealingOverlay"),
                ["noHealingStripe"] = shb:GetNamedChild("_NoHealingStripe"),
                ["possessionOverlay"] = shb:GetNamedChild("_PossessionOverlay"),
            },
            ["dead"] = shb:GetNamedChild("_Dead"),
            ["name"] = shb:GetNamedChild("_Name"),
        }
        UnitFrames.CustomFrames["companion"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"
    end
end

-- Helper to create the Bosses Frames
local function CreateBossFrames()
    if UnitFrames.SV.CustomFramesBosses then
        -- Get references to XML-created controls
        local bosses = LUIE_CustomBossFrame
        bosses.customPositionAttr = "CustomFramesBossesFramePos"
        bosses.preview = bosses:GetNamedChild("_Preview")
        bosses.previewLabel = bosses.preview:GetNamedChild("_Label")

        -- Add to scene fragments (controls are already created via XML)
        local fragment = ZO_HUDFadeSceneFragment:New(bosses, 0, 0)

        local sceneList = { "hud", "hudui", "siegeBar", "siegeBarUI", "loot" }
        local sceneKey = nil
        local scene
        while true do
            sceneKey, scene = next(sceneList, sceneKey)
            if sceneKey == nil then break end
            sceneManager:GetScene(scene):AddFragment(fragment)
        end

        for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local unitTag = "boss" .. i
            local control = bosses:GetNamedChild("_" .. unitTag)
            local bhb = control:GetNamedChild("_Health")

            local thresholdContainer = bhb:GetNamedChild("_ThresholdContainer")

            UnitFrames.CustomFrames[unitTag] =
            {
                ["unitTag"] = unitTag,
                ["tlw"] = bosses,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = bhb,
                    ["label"] = bhb:GetNamedChild("_Label"),
                    ["trauma"] = bhb:GetNamedChild("_Trauma"),
                    ["bar"] = bhb:GetNamedChild("_Bar"),
                    ["invulnerable"] = bhb:GetNamedChild("_Invulnerable"),
                    ["invulnerableInlay"] = bhb:GetNamedChild("_InvulnerableInlay"),
                    ["shield"] = bhb:GetNamedChild("_Shield"),
                    ["noHealingOverlay"] = bhb:GetNamedChild("_NoHealingOverlay"),
                    ["noHealingStripe"] = bhb:GetNamedChild("_NoHealingStripe"),
                    ["possessionOverlay"] = bhb:GetNamedChild("_PossessionOverlay"),
                    ["thresholdContainer"] = thresholdContainer,
                    ["thresholdMarkers"] = {},
                    ["threshold"] = UnitFrames.targetThreshold,
                },
                ["dead"] = bhb:GetNamedChild("_Dead"),
                ["name"] = bhb:GetNamedChild("_Name"),
            }
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Percentage%"
        end
    end
end

-- Helper to set up common actions for all created frames
local function SetupCommonFrameActions()
    local tlwOnMoveStart = function (self)
        -- For console UI, coordLabel is updated by MoverHelper, so skip anchorLabel update
        if not IsConsoleUI() and self.preview.anchorLabel then
            eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
                self.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", self:GetLeft(), self:GetTop()))
            end)
        end
    end

    local tlwOnMoveStop = function (self)
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
        UnitFrames.SV[self.customPositionAttr] = { self:GetLeft(), self:GetTop() }
    end

    local frameBaseNames = { "player", "reticleover", "companion", "SmallGroup", "RaidGroup", "boss", "AvaPlayerTarget", "PetGroup" }

    local baseNameKey = nil
    local baseName
    while true do
        baseNameKey, baseName = next(frameBaseNames, baseNameKey)
        if baseNameKey == nil then break end
        local unitFrame = UnitFrames.CustomFrames[baseName] or UnitFrames.CustomFrames[baseName .. "1"]
        if unitFrame and unitFrame.tlw then
            -- Movement handlers
            unitFrame.tlw:SetHandler("OnMoveStart", tlwOnMoveStart)
            unitFrame.tlw:SetHandler("OnMoveStop", tlwOnMoveStop)

            -- Create anchor preview
            unitFrame.tlw.preview.anchorTexture = windowManager:CreateControl(nil, unitFrame.tlw.preview, CT_TEXTURE)
            unitFrame.tlw.preview.anchorTexture:SetAnchor(TOPLEFT, unitFrame.tlw.preview, TOPLEFT)
            unitFrame.tlw.preview.anchorTexture:SetDimensions(16, 16)
            unitFrame.tlw.preview.anchorTexture:SetTexture("/esoui/art/reticle/border_topleft.dds")
            unitFrame.tlw.preview.anchorTexture:SetDrawLayer(DL_OVERLAY)
            unitFrame.tlw.preview.anchorTexture:SetColor(1, 1, 0, 0.9)

            -- For console UI, don't create anchorLabel - EditModeController will create a better coordLabel instead
            if not IsConsoleUI() then
                unitFrame.tlw.preview.anchorLabel = windowManager:CreateControl(nil, unitFrame.tlw.preview, CT_LABEL)
                unitFrame.tlw.preview.anchorLabel:SetFont("ZoFontGameSmall")
                unitFrame.tlw.preview.anchorLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                unitFrame.tlw.preview.anchorLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
                unitFrame.tlw.preview.anchorLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                unitFrame.tlw.preview.anchorLabel:SetAnchor(BOTTOMLEFT, unitFrame.tlw.preview, TOPLEFT, 0, -1)
                unitFrame.tlw.preview.anchorLabel:SetText("xxx, yyy")
                unitFrame.tlw.preview.anchorLabel:SetColor(1, 1, 0, 1)
                unitFrame.tlw.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
                unitFrame.tlw.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
                unitFrame.tlw.preview.anchorLabelBg = windowManager:CreateControl(nil, unitFrame.tlw.preview.anchorLabel, CT_BACKDROP)
                unitFrame.tlw.preview.anchorLabelBg:SetCenterColor(0, 0, 0, 1)
                unitFrame.tlw.preview.anchorLabelBg:SetEdgeColor(0, 0, 0, 1)
                unitFrame.tlw.preview.anchorLabelBg:SetEdgeTexture("", 8, 1, 1, 1)
                unitFrame.tlw.preview.anchorLabelBg:SetDrawLayer(DL_BACKGROUND)
                unitFrame.tlw.preview.anchorLabelBg:SetAnchorFill(unitFrame.tlw.preview.anchorLabel)
                unitFrame.tlw.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
                unitFrame.tlw.preview.anchorLabelBg:SetDrawTier(DT_LOW)
            end
        end

        -- Anchor bars to their backdrops
        local shieldOverlay = (baseName == "RaidGroup" or baseName == "boss") or not UnitFrames.SV.CustomShieldBarSeparate

        for i = 0, 12 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            local frame = UnitFrames.CustomFrames[unitTag]

            if frame then
                local powerTypeList = { COMBAT_MECHANIC_FLAGS_HEALTH, COMBAT_MECHANIC_FLAGS_MAGICKA, COMBAT_MECHANIC_FLAGS_STAMINA, "alternative" }
                local powerTypeKey = nil
                local powerType
                while true do
                    powerTypeKey, powerType = next(powerTypeList, powerTypeKey)
                    if powerTypeKey == nil then break end
                    local powerBar = frame[powerType]

                    if powerBar then
                        powerBar.bar:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                        powerBar.bar:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)

                        if powerBar.enlightenment then
                            powerBar.enlightenment:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                            powerBar.enlightenment:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
                        end

                        if powerBar.trauma then
                            powerBar.trauma:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                            powerBar.trauma:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
                        end

                        if powerBar.invulnerable then
                            powerBar.invulnerable:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                            powerBar.invulnerable:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
                            powerBar.invulnerableInlay:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 3, 3)
                            powerBar.invulnerableInlay:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -3, -3)
                        end

                        if powerBar.noHealingOverlay then
                            -- No-healing overlay: works like shield overlay with SetValue() calls
                            -- Anchors to backdrop, fills are controlled by status bar value
                            powerBar.noHealingOverlay:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                            powerBar.noHealingOverlay:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
                            powerBar.noHealingOverlay:SetTexture(LUIE_MEDIA_UNITFRAMES_TEXTURES_DIAGONAL_DDS)
                            powerBar.noHealingOverlay:SetDrawLevel(1) -- Draw below shield (which has no explicit level, defaults higher due to creation order)
                            powerBar.noHealingOverlay:SetHidden(true)
                            powerBar.noHealingOverlay:SetAlpha(0)
                            -- Dark red tint with transparency so health color shows through
                            powerBar.noHealingOverlay:SetColor(0.8, 0.1, 0.1, 0.5)
                        end

                        -- Ensure labels render above overlays (draw level 10 is above overlay at 5)
                        if powerBar.labelOne then
                            powerBar.labelOne:SetDrawTier(DT_HIGH)
                            powerBar.labelOne:SetDrawLayer(DL_OVERLAY)
                            powerBar.labelOne:SetDrawLevel(10)
                        end
                        if powerBar.labelTwo then
                            powerBar.labelTwo:SetDrawTier(DT_HIGH)
                            powerBar.labelTwo:SetDrawLayer(DL_OVERLAY)
                            powerBar.labelTwo:SetDrawLevel(10)
                        end
                        if powerBar.label then
                            powerBar.label:SetDrawTier(DT_HIGH)
                            powerBar.label:SetDrawLayer(DL_OVERLAY)
                            powerBar.label:SetDrawLevel(10)
                        end
                        if frame.roleIcon then
                            frame.roleIcon:SetDrawTier(DT_HIGH)
                            frame.roleIcon:SetDrawLayer(DL_OVERLAY)
                            frame.roleIcon:SetDrawLevel(10)
                        end

                        if powerBar.noHealingStripe then
                            -- Diagonal stripe: status bar that syncs value with noHealingOverlay
                            powerBar.noHealingStripe:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                            powerBar.noHealingStripe:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
                            powerBar.noHealingStripe:SetTexture(LUIE_MEDIA_UNITFRAMES_TEXTURES_DIAGONAL_DDS)
                            powerBar.noHealingStripe:SetDrawLevel(1) -- Draw below shield (same level as overlay, relies on creation order)
                            powerBar.noHealingStripe:SetColor(1, 0.3, 0.3, 0.8)
                            powerBar.noHealingStripe:SetHidden(true)
                        end

                        -- Create fade animation for overlay and stripe
                        if powerBar.noHealingOverlay then
                            powerBar.noHealingFadeAnimation = CreateNoHealingFadeAnimation(
                                powerBar.noHealingOverlay,
                                powerBar.noHealingStripe
                            )
                        end

                        if powerBar.possessionOverlay then
                            powerBar.possessionOverlay:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 0, -2)
                            powerBar.possessionOverlay:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, 0, 2)
                            powerBar.possessionOverlay:SetDrawTier(DT_HIGH)
                            powerBar.possessionOverlay:SetDrawLayer(DL_CONTROLS)

                            -- Get three-part possession glow textures from XML
                            if not powerBar.possessionGlowLeft then
                                powerBar.possessionGlowLeft = powerBar.possessionOverlay:GetNamedChild("_GlowLeft")
                                powerBar.possessionGlowRight = powerBar.possessionOverlay:GetNamedChild("_GlowRight")
                                powerBar.possessionGlowCenter = powerBar.possessionOverlay:GetNamedChild("_GlowCenter")

                                -- Create animated halo texture using helper function
                                powerBar.possessionHalo = CreatePossessionHaloAnimation(powerBar.backdrop)
                            end
                        end

                        if powerBar.shield then
                            powerBar.shield:ClearAnchors()
                            if shieldOverlay then
                                if UnitFrames.SV.CustomShieldBarFull then
                                    powerBar.shield:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                                    powerBar.shield:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
                                else
                                    powerBar.shield:SetAnchor(BOTTOMLEFT, powerBar.backdrop, BOTTOMLEFT, 1, 1)
                                    powerBar.shield:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)
                                    powerBar.shield:SetHeight(UnitFrames.SV.CustomShieldBarHeight)
                                end
                            else
                                powerBar.shieldbackdrop = windowManager:CreateControl(nil, frame.control, CT_BACKDROP)
                                powerBar.shieldbackdrop:SetCenterColor(0, 0, 0, 0.4)
                                powerBar.shieldbackdrop:SetEdgeColor(0, 0, 0, 0.6)
                                powerBar.shieldbackdrop:SetEdgeTexture("", 8, 1, 1, 1)
                                powerBar.shieldbackdrop:SetDrawLayer(DL_BACKGROUND)
                                powerBar.shieldbackdrop:SetHidden(true)
                                powerBar.shield:SetAnchor(TOPLEFT, powerBar.shieldbackdrop, TOPLEFT, 1, 1)
                                powerBar.shield:SetAnchor(BOTTOMRIGHT, powerBar.shieldbackdrop, BOTTOMRIGHT, -1, -1)
                            end
                            -- Ensure shield renders above no-healing overlay
                            powerBar.shield:SetDrawLevel(2)
                        end
                    end
                end

                -- Anchor resource bars if they exist (for LibGroupBroadcast integration)
                if frame.resourceMagicka and frame.resourceMagicka.bar then
                    frame.resourceMagicka.bar:SetAnchor(TOPLEFT, frame.resourceMagicka.backdrop, TOPLEFT, 1, 1)
                    frame.resourceMagicka.bar:SetAnchor(BOTTOMRIGHT, frame.resourceMagicka.backdrop, BOTTOMRIGHT, -1, -1)
                end
                if frame.resourceStamina and frame.resourceStamina.bar then
                    frame.resourceStamina.bar:SetAnchor(TOPLEFT, frame.resourceStamina.backdrop, TOPLEFT, 1, 1)
                    frame.resourceStamina.bar:SetAnchor(BOTTOMRIGHT, frame.resourceStamina.backdrop, BOTTOMRIGHT, -1, -1)
                end
            end
        end
    end
end

-- Generic function to setup regen/degen animations
local function SetupRegenAnimations(frameConfig)
    if not UnitFrames.SV[frameConfig.enableFlag] then
        return
    end

    for i = frameConfig.startIndex, frameConfig.endIndex do
        local unitTag = frameConfig.prefix .. (i == 0 and "" or i)
        local frame = UnitFrames.CustomFrames[unitTag]

        if frame then
            local powerTypeList =
            {
                COMBAT_MECHANIC_FLAGS_HEALTH,
                COMBAT_MECHANIC_FLAGS_MAGICKA,
                COMBAT_MECHANIC_FLAGS_STAMINA
            }
            local powerTypeKey = nil
            local powerType
            while true do
                powerTypeKey, powerType = next(powerTypeList, powerTypeKey)
                if powerTypeKey == nil then break end
                if frame[powerType] then
                    local backdrop = frame[powerType].backdrop
                    local size1 = UnitFrames.SV[frameConfig.widthSV]
                    local size2 = UnitFrames.SV[frameConfig.heightSV]

                    if size1 and size2 then
                        local heightReduction = size2 * frameConfig.heightMultiplier
                        local dims = { size1 - 4, size2 - heightReduction }

                        frame[powerType].regen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, dims, 0.55, "regen1")
                        frame[powerType].regen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, dims, 0.55, "regen2")
                        frame[powerType].degen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, dims, 0.55, "degen1")
                        frame[powerType].degen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, dims, 0.55, "degen2")
                    end
                end
            end
        end
    end
end

-- Generic function to setup armor overlays
local function SetupArmorOverlays(frameConfig)
    if not UnitFrames.SV[frameConfig.enableFlag] then
        return
    end

    for i = frameConfig.startIndex, frameConfig.endIndex do
        local unitTag = frameConfig.prefix .. (i == 0 and "" or i)
        local frame = UnitFrames.CustomFrames[unitTag]

        if frame and frame[COMBAT_MECHANIC_FLAGS_HEALTH] then
            if not frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat then
                frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat = {}
            end

            local backdrop = frame[COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
            frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_ARMOR_RATING] =
            {
                ["dec"] = CreateDecreasedArmorOverlay(backdrop, false),
                ["inc"] = backdrop:GetNamedChild("_ArmorInc"), -- Get from XML (already hidden by default)
            }
        end
    end
end

-- Helper to set up Power Glow animations for all frames that have it displayed
local function SetupPowerGlowAnimations()
    local baseNameList = { "player", "reticleover", "AvaPlayerTarget", "boss", "SmallGroup", "RaidGroup" }
    local baseNameKey = nil
    local baseName
    while true do
        baseNameKey, baseName = next(baseNameList, baseNameKey)
        if baseNameKey == nil then break end
        for i = 0, 12 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            local frame = UnitFrames.CustomFrames[unitTag]

            if  frame and frame[COMBAT_MECHANIC_FLAGS_HEALTH] and frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat
            and frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_POWER]
            and frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_POWER].inc then
                local control = frame[COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_POWER].inc

                -- Use XML-defined animation timeline
                control.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("LUIE_PowerGlowAnimation", control)
                control.animation = control.timeline:GetAnimation(1)

                -- Configure framerate dynamically based on current game framerate
                control.animation:SetFramerate(GetFramerate())

                control.timeline:PlayFromStart()
            end
        end
    end
end

-- Add the top level windows to global controls list
local function AddTopLevelWindows()
    local frameTags = { "player", "reticleover", "companion", "SmallGroup1", "RaidGroup1", "boss1", "AvaPlayerTarget", "PetGroup1" }

    local unitTagKey = nil
    local unitTag
    while true do
        unitTagKey, unitTag = next(frameTags, unitTagKey)
        if unitTagKey == nil then break end
        if UnitFrames.CustomFrames[unitTag] then
            LUIE.Components[moduleName .. "_CustomFrame_" .. unitTag] = UnitFrames.CustomFrames[unitTag].tlw
        end
    end
end

-- Used to create custom frames extender controls for player and target.
-- Called from UnitFrames.Initialize
function UnitFrames.CreateCustomFrames()
    -- Create Custom unit frames
    CreatePlayerFrame()
    CreateTargetFrame()
    CreateAvaPlayerTargetFrame()
    CreateSmallGroupFrames()
    CreateRaidGroupFrames()
    CreatePetFrames()
    CreateCompanionFrame()
    CreateBossFrames()
    SetupCommonFrameActions()

    -- Setup regen animations using config table
    local regenConfigs =
    {
        {
            prefix = "player",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "PlayerEnableRegen",
            widthSV = "PlayerBarWidth",
            heightSV = "PlayerBarHeightHealth",
            heightMultiplier = 0.3
        },
        {
            prefix = "reticleover",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "PlayerEnableRegen",
            widthSV = "TargetBarWidth",
            heightSV = "TargetBarHeight",
            heightMultiplier = 0.3
        },
        {
            prefix = "AvaPlayerTarget",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "PlayerEnableRegen",
            widthSV = "AvaTargetBarWidth",
            heightSV = "AvaTargetBarHeight",
            heightMultiplier = 0.3
        },
        {
            prefix = "SmallGroup",
            startIndex = 1,
            endIndex = 4,
            enableFlag = "GroupEnableRegen",
            widthSV = "GroupBarWidth",
            heightSV = "GroupBarHeight",
            heightMultiplier = 0.4
        },
        {
            prefix = "RaidGroup",
            startIndex = 1,
            endIndex = 12,
            enableFlag = "RaidEnableRegen",
            widthSV = "RaidBarWidth",
            heightSV = "RaidBarHeight",
            heightMultiplier = 0.3
        },
        {
            prefix = "boss",
            startIndex = BOSS_RANK_ITERATION_BEGIN,
            endIndex = BOSS_RANK_ITERATION_END,
            enableFlag = "BossEnableRegen",
            widthSV = "BossBarWidth",
            heightSV = "BossBarHeight",
            heightMultiplier = 0.3
        },
    }

    local configKey = nil
    local config
    while true do
        configKey, config = next(regenConfigs, configKey)
        if configKey == nil then break end
        SetupRegenAnimations(config)
    end

    -- Setup armor overlays using config table
    local armorConfigs =
    {
        {
            prefix = "player",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "PlayerEnableArmor"
        },
        {
            prefix = "reticleover",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "PlayerEnableArmor"
        },
        {
            prefix = "AvaPlayerTarget",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "PlayerEnableArmor"
        },
        {
            prefix = "SmallGroup",
            startIndex = 1,
            endIndex = 4,
            enableFlag = "GroupEnableArmor"
        },
        {
            prefix = "RaidGroup",
            startIndex = 1,
            endIndex = 12,
            enableFlag = "RaidEnableArmor"
        },
        {
            prefix = "boss",
            startIndex = BOSS_RANK_ITERATION_BEGIN,
            endIndex = BOSS_RANK_ITERATION_END,
            enableFlag = "BossEnableArmor"
        },
    }

    local armorConfigKey = nil
    local armorConfig
    while true do
        armorConfigKey, armorConfig = next(armorConfigs, armorConfigKey)
        if armorConfigKey == nil then break end
        SetupArmorOverlays(armorConfig)
    end

    SetupPowerGlowAnimations()

    -- Set proper anchors according to user preferences
    UnitFrames.CustomFramesApplyLayoutPlayer(true)
    UnitFrames.CustomFramesApplyLayoutGroup(true)
    UnitFrames.CustomFramesApplyLayoutRaid(true)
    UnitFrames.CustomFramesApplyLayoutPet(true)
    UnitFrames.CustomFramesApplyLayoutCompanion(true)
    UnitFrames.CustomPetUpdate()
    UnitFrames.CompanionUpdate()
    UnitFrames.CustomFramesApplyLayoutBosses()
    UnitFrames.CustomFramesSetPositions()
    UnitFrames.CustomFramesFormatLabels(true)
    UnitFrames.CustomFramesApplyTexture()
    UnitFrames.CustomFramesApplyFont()
    UnitFrames.CustomFramesApplyBarAlignment()

    AddTopLevelWindows()
end
