--- @diagnostic disable: missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
local UI = LUIE.UI
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local moduleName = UnitFrames.moduleName
local eventManager = GetEventManager()
local windowManager = GetWindowManager()
local sceneManager = SCENE_MANAGER

-- -----------------------------------------------------------------------------


-- Default Regen/degen animation used on default group frames and custom frames
local function CreateRegenAnimation(parent, anchors, dims, alpha, number)
    -- Table of animation configs (because hardcoding is for masochists)
    local animConfigs =
    {
        degen1 =
        {
            texture = "LuiExtended/media/unitframes/regenleft.dds",
            distanceMult = -0.35,
            offsetXMult = 0.425,
        },
        degen2 =
        {
            texture = "LuiExtended/media/unitframes/regenright.dds",
            distanceMult = 0.35,
            offsetXMult = -0.425,
        },
        regen1 =
        {
            texture = "LuiExtended/media/unitframes/regenright.dds",
            distanceMult = 0.35,
            offsetXMult = 0.075,
        },
        regen2 =
        {
            texture = "LuiExtended/media/unitframes/regenleft.dds",
            distanceMult = -0.35,
            offsetXMult = -0.075,
        },
    }

    local config = animConfigs[number]
    if not config then
        if LUIE.IsDevDebugEnabled() then
            -- If you pass in a bad number, you get nothing. (And you deserve it.)
            LUIE.Error("[LUIE] CreateRegenAnimation: Invalid animation number '" .. tostring(number) .. "'.")
        end
        return nil
    end

    if #dims ~= 2 then
        dims = { parent:GetDimensions() }
    end

    local updateDims = { dims[2] * 1.9, dims[2] * 0.85 }
    local control = UI:Texture(parent, anchors, updateDims, config.texture, 2, true)
    local distance = dims[1] * config.distanceMult
    local offsetX = dims[1] * config.offsetXMult

    control:SetHidden(true)
    control:SetAlpha(alpha or 0)
    control:SetDrawLayer(DL_CONTROLS)

    -- Find the first valid anchor and set up the animation (because why would you want more than one?)
    for i = 0, MAX_ANCHORS - 1 do
        local isValid, _, _, _, _, offsetY = control:GetAnchor(i)
        if isValid then
            -- Horizontal sliding animation
            local animation, timeline = CreateSimpleAnimation(ANIMATION_TRANSLATE, control, 0)
            animation:SetTranslateOffsets(offsetX, offsetY, offsetX + distance, offsetY)
            animation:SetDuration(1000)

            -- Fade in
            local fadeIn = timeline:InsertAnimation(ANIMATION_ALPHA, control, 0)
            fadeIn:SetAlphaValues(0, 0.75)
            fadeIn:SetDuration(250)
            fadeIn:SetEasingFunction(ZO_EaseOutQuadratic)

            -- Fade out
            local fadeOut = timeline:InsertAnimation(ANIMATION_ALPHA, control, 750)
            fadeOut:SetAlphaValues(0.75, 0)
            fadeOut:SetDuration(250)
            fadeOut:SetEasingFunction(ZO_EaseOutQuadratic)

            timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)
            control.animation = animation
            control.timeline = timeline

            return control
        end
    end
    if LUIE.IsDevDebugEnabled() then
        -- If you get here, you have no valid anchors. Sucks to be you.
        LUIE.Error("[LUIE] CreateRegenAnimation: No valid anchors found for animation.")
    end
    return nil
end

-- Decreased armour overlay visuals
local function CreateDecreasedArmorOverlay(parent, small)
    -- Config for overlay textures (because hardcoding is for people who hate themselves)
    local textureConfig =
    {
        small =
        {
            file = "LuiExtended/media/unitframes/unitattributevisualizer/attributebar_dynamic_decreasedarmor_small.dds",
            size = { 512, 32 },
            tier = DT_HIGH,
        },
        normal =
        {
            file = "LuiExtended/media/unitframes/unitattributevisualizer/attributebar_dynamic_decreasedarmor_standard.dds",
            size = { 512, 32 },
            tier = DT_HIGH,
        },
    }

    -- Create the base control (centered, because why not?)
    local control = UI:Control(parent, { CENTER, CENTER }, textureConfig.small.size, false)

    -- Always add the small texture (because apparently everyone gets to be small)
    control.smallTex = UI:Texture(control, { CENTER, CENTER }, textureConfig.small.size, textureConfig.small.file, 2, false)
    control.smallTex:SetDrawTier(textureConfig.small.tier)

    -- Only add the normal texture if 'small' is NOT true (logic, right?)
    if not small then
        control.normalTex = UI:Texture(control, { CENTER, CENTER }, textureConfig.normal.size, textureConfig.normal.file, 2, false)
        control.normalTex:SetDrawTier(textureConfig.normal.tier)
    end

    return control
end

-- Helper to create the Player Frame
local function CreatePlayerFrame()
    if UnitFrames.SV.CustomFramesPlayer then
        -- Player Frame
        local playerTlw = UI:TopLevel(nil, nil)
        playerTlw:SetDrawLayer(DL_BACKGROUND)
        playerTlw:SetDrawTier(DT_LOW)
        playerTlw:SetDrawLevel(DL_CONTROLS)
        playerTlw.customPositionAttr = "CustomFramesPlayerFramePos"
        playerTlw.preview = UI:Backdrop(playerTlw, "fill", nil, nil, nil, true)
        local player = UI:Control(playerTlw, { TOPLEFT, TOPLEFT }, nil, false)
        local topInfo = UI:Control(player, { BOTTOM, TOP, 0, -3 }, nil, false)
        local botInfo = UI:Control(player, { TOP, BOTTOM, 0, 2 }, nil, false)
        local buffAnchor = UI:Control(player, { TOP, BOTTOM, 0, 2 }, nil, false)
        local phb = UI:Backdrop(player, { TOP, TOP, 0, 0 }, nil, nil, nil, false)
        phb:SetDrawLayer(DL_BACKGROUND)
        phb:SetDrawLevel(DL_CONTROLS)
        local pmb = UI:Backdrop(player, nil, nil, nil, nil, false)
        pmb:SetDrawLayer(DL_BACKGROUND)
        pmb:SetDrawLevel(DL_CONTROLS)
        local psb = UI:Backdrop(player, nil, nil, nil, nil, false)
        psb:SetDrawLayer(DL_BACKGROUND)
        psb:SetDrawLevel(DL_CONTROLS)
        local alt = UI:Backdrop(botInfo, { RIGHT, RIGHT }, nil, nil, { 0, 0, 0, 1 }, false)
        local pli = UI:Texture(topInfo, nil, { 20, 20 }, nil, nil, false)

        local fragment = ZO_HUDFadeSceneFragment:New(playerTlw, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

        -- Collect all together
        UnitFrames.CustomFrames["player"] =
        {
            ["unitTag"] = "player",
            ["tlw"] = playerTlw,
            ["control"] = player,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = phb,
                ["labelOne"] = UI:Label(phb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "xx / yy", false),
                ["labelTwo"] = UI:Label(phb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                ["trauma"] = UI:StatusBar(phb, nil, nil, nil, true),
                ["bar"] = UI:StatusBar(phb, nil, nil, nil, false),
                ["shield"] = UI:StatusBar(phb, nil, nil, nil, true),
                ["threshold"] = UnitFrames.healthThreshold,
            },
            [COMBAT_MECHANIC_FLAGS_MAGICKA] =
            {
                ["backdrop"] = pmb,
                ["labelOne"] = UI:Label(pmb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "xx / yy", false),
                ["labelTwo"] = UI:Label(pmb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                ["bar"] = UI:StatusBar(pmb, nil, nil, nil, false),
                ["threshold"] = UnitFrames.magickaThreshold,
            },
            [COMBAT_MECHANIC_FLAGS_STAMINA] =
            {
                ["backdrop"] = psb,
                ["labelOne"] = UI:Label(psb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "xx / yy", false),
                ["labelTwo"] = UI:Label(psb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                ["bar"] = UI:StatusBar(psb, nil, nil, nil, false),
                ["threshold"] = UnitFrames.staminaThreshold,
            },
            ["alternative"] =
            {
                ["backdrop"] = alt,
                ["enlightenment"] = UI:StatusBar(alt, nil, nil, nil, false),
                ["bar"] = UI:StatusBar(alt, nil, nil, nil, false),
                ["icon"] = UI:Texture(alt, { RIGHT, LEFT, -2, 0 }, { 20, 20 }, nil, nil, false),
            },
            ["topInfo"] = topInfo,
            ["name"] = UI:Label(topInfo, { BOTTOMLEFT, BOTTOMLEFT }, nil, { 0, 4 }, nil, "Player Name", false),
            ["levelIcon"] = pli,
            ["level"] = UI:Label(topInfo, { LEFT, RIGHT, 1, 0, pli }, nil, { 0, 1 }, nil, "level", false),
            ["classIcon"] = UI:Texture(topInfo, { RIGHT, RIGHT, -1, 0 }, { 22, 22 }, nil, nil, false),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["buffs"] = UI:Control(playerTlw, nil, nil, false),
            ["debuffs"] = UI:Control(playerTlw, { BOTTOM, TOP, 0, -2, topInfo }, nil, false),
        }

        UnitFrames.CustomFrames["player"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

        -- If Health Label is hidden in menu optins, hide the health bar labels
        if UnitFrames.SV.HideLabelHealth then
            UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].labelOne:SetHidden(true)
            UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_HEALTH].labelTwo:SetHidden(true)
        end

        -- If Stamina Label is hidden in menu options, hide the stamina bar labels
        if UnitFrames.SV.HideLabelStamina then
            UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA].labelOne:SetHidden(true)
            UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_STAMINA].labelTwo:SetHidden(true)
        end

        -- If Magicka Label is hidden in menu options, hide the magicka bar labels
        if UnitFrames.SV.HideLabelMagicka then
            UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA].labelOne:SetHidden(true)
            UnitFrames.CustomFrames["player"][COMBAT_MECHANIC_FLAGS_MAGICKA].labelTwo:SetHidden(true)
        end

        UnitFrames.CustomFrames["controlledsiege"] =
        {
            ["unitTag"] = "controlledsiege", -- placeholder for alternative bar when using siege weapon
        }
    end
end

-- Helper to create the Target Frame
local function CreateTargetFrame()
    if UnitFrames.SV.CustomFramesTarget then
        -- Target Frame
        local targetTlw = UI:TopLevel(nil, nil)
        targetTlw:SetDrawLayer(DL_BACKGROUND)
        targetTlw:SetDrawTier(DT_LOW)
        targetTlw:SetDrawLevel(DL_CONTROLS)
        targetTlw.customPositionAttr = "CustomFramesTargetFramePos"
        targetTlw.preview = UI:Backdrop(targetTlw, "fill", nil, nil, nil, true)
        targetTlw.previewLabel = UI:Label(targetTlw.preview, { CENTER, CENTER }, nil, nil, "ZoFontGameMedium", "Target Frame", false)
        local target = UI:Control(targetTlw, { TOPLEFT, TOPLEFT }, nil, false)
        local topInfo = UI:Control(target, { BOTTOM, TOP, 0, -3 }, nil, false)
        local botInfo = UI:Control(target, { TOP, BOTTOM, 0, 2 }, nil, false)
        local buffAnchor = UI:Control(target, { TOP, BOTTOM, 0, 2 }, nil, false)
        local thb = UI:Backdrop(target, { TOP, TOP, 0, 0 }, nil, nil, nil, false)
        thb:SetDrawLayer(DL_BACKGROUND)
        thb:SetDrawLevel(DL_CONTROLS)
        local tli = UI:Texture(topInfo, nil, { 20, 20 }, nil, nil, false)
        local ari = UI:Texture(botInfo, { RIGHT, RIGHT, -1, 0 }, { 20, 20 }, nil, nil, false)
        local buffs
        local debuffs
        if UnitFrames.SV.PlayerFrameOptions == 1 then
            buffs = UI:Control(targetTlw, { TOP, BOTTOM, 0, 2, buffAnchor }, nil, false)
            debuffs = UI:Control(targetTlw, { BOTTOM, TOP, 0, -2, topInfo }, nil, false)
        else
            buffs = UI:Control(targetTlw, { BOTTOM, TOP, 0, -2, topInfo }, nil, false)
            debuffs = UI:Control(targetTlw, { TOP, BOTTOM, 0, 2, buffAnchor }, nil, false)
        end

        local fragment = ZO_HUDFadeSceneFragment:New(targetTlw, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

        -- Collect all together
        UnitFrames.CustomFrames["reticleover"] =
        {
            ["unitTag"] = "reticleover",
            ["tlw"] = targetTlw,
            ["control"] = target,
            ["canHide"] = true,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = thb,
                ["labelOne"] = UI:Label(thb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "xx / yy", false),
                ["labelTwo"] = UI:Label(thb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                ["trauma"] = UI:StatusBar(thb, nil, nil, nil, true),
                ["bar"] = UI:StatusBar(thb, nil, nil, nil, false),
                ["invulnerable"] = UI:StatusBar(thb, nil, nil, nil, false),
                ["invulnerableInlay"] = UI:StatusBar(thb, nil, nil, nil, false),
                ["shield"] = UI:StatusBar(thb, nil, nil, nil, true),
                ["threshold"] = UnitFrames.targetThreshold,
            },
            ["topInfo"] = topInfo,
            ["name"] = UI:Label(topInfo, { BOTTOMLEFT, BOTTOMLEFT }, nil, { 0, 4 }, nil, "Target Name", false),
            ["levelIcon"] = tli,
            ["level"] = UI:Label(topInfo, { LEFT, RIGHT, 1, 0, tli }, nil, { 0, 1 }, nil, "level", false),
            ["classIcon"] = UI:Texture(topInfo, { RIGHT, RIGHT, -1, 0 }, { 22, 22 }, nil, nil, false),
            ["className"] = UI:Label(topInfo, { BOTTOMRIGHT, TOPRIGHT, -1, -1 }, nil, { 2, 4 }, nil, "Class", false),
            ["friendIcon"] = UI:Texture(topInfo, { RIGHT, RIGHT, -20, 0 }, { 22, 22 }, nil, nil, false),
            ["star1"] = UI:Texture(topInfo, { RIGHT, RIGHT, -28, -1 }, { 16, 16 }, "/esoui/art/ava/ava_bgwindow_capturepointicon.dds", nil, true),
            ["star2"] = UI:Texture(topInfo, { RIGHT, RIGHT, -45, -1 }, { 16, 16 }, "/esoui/art/ava/ava_bgwindow_capturepointicon.dds", nil, true),
            ["star3"] = UI:Texture(topInfo, { RIGHT, RIGHT, -62, -1 }, { 16, 16 }, "/esoui/art/ava/ava_bgwindow_capturepointicon.dds", nil, true),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["title"] = UI:Label(botInfo, { TOPLEFT, TOPLEFT }, nil, { 0, 3 }, nil, "<Title>", false),
            ["avaRankIcon"] = ari,
            ["avaRank"] = UI:Label(botInfo, { RIGHT, LEFT, -1, 0, ari }, nil, { 2, 3 }, nil, "ava", false),
            ["dead"] = UI:Label(thb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "Status", true),
            ["skull"] = UI:Texture(target, { RIGHT, LEFT, -8, 0 }, nil, "LuiExtended/media/unitframes/unitframes_execute.dds", nil, true),
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
        -- Target Frame
        local targetTlw = UI:TopLevel(nil, nil)
        targetTlw:SetDrawLayer(DL_BACKGROUND)
        targetTlw:SetDrawTier(DT_LOW)
        targetTlw:SetDrawLevel(DL_CONTROLS)
        targetTlw.customPositionAttr = "AvaCustFramesTargetFramePos"
        targetTlw.preview = UI:Backdrop(targetTlw, "fill", nil, nil, nil, true)
        targetTlw.previewLabel = UI:Label(targetTlw.preview, { CENTER, CENTER }, nil, nil, "ZoFontGameMedium", "PvP Player Target Frame", false)
        local target = UI:Control(targetTlw, { TOPLEFT, TOPLEFT }, nil, false)
        local topInfo = UI:Control(target, { BOTTOM, TOP, 0, -3 }, nil, false)
        local botInfo = UI:Control(target, { TOP, BOTTOM, 0, 2 }, nil, false)
        local buffAnchor = UI:Control(target, { TOP, BOTTOM, 0, 2 }, nil, false)
        local thb = UI:Backdrop(target, { TOP, TOP, 0, 0 }, nil, nil, nil, false)
        thb:SetDrawLayer(DL_BACKGROUND)
        thb:SetDrawLevel(DL_CONTROLS)
        local cn = UI:Label(botInfo, { TOP, TOP }, nil, { 1, 3 }, nil, "Class", false)

        local fragment = ZO_HUDFadeSceneFragment:New(targetTlw, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)

        -- Collect all together
        -- Notice, that we put this table into same UnitFrames.CustomFrames table.
        -- This is done to apply formating more easier
        -- Later this table will be referenced from UnitFrames.AvaCustFrames
        UnitFrames.CustomFrames["AvaPlayerTarget"] =
        {
            ["unitTag"] = "reticleover",
            ["tlw"] = targetTlw,
            ["control"] = target,
            ["canHide"] = true,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = thb,
                ["label"] = UI:Label(thb, { CENTER, CENTER }, nil, { 1, 1 }, nil, "zz%", false),
                ["labelOne"] = UI:Label(thb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "xx + ss", false),
                ["labelTwo"] = UI:Label(thb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "yy", false),
                ["trauma"] = UI:StatusBar(thb, nil, nil, nil, true),
                ["bar"] = UI:StatusBar(thb, nil, nil, nil, false),
                ["invulnerable"] = UI:StatusBar(thb, nil, nil, nil, false),
                ["invulnerableInlay"] = UI:StatusBar(thb, nil, nil, nil, false),
                ["shield"] = UI:StatusBar(thb, nil, nil, nil, true),
                ["threshold"] = UnitFrames.targetThreshold,
            },
            ["topInfo"] = topInfo,
            ["name"] = UI:Label(topInfo, { BOTTOM, BOTTOM }, nil, { 1, 4 }, nil, "Target Name", false),
            ["classIcon"] = UI:Texture(topInfo, { LEFT, LEFT }, { 20, 20 }, nil, nil, false),
            ["avaRankIcon"] = UI:Texture(topInfo, { RIGHT, RIGHT }, { 20, 20 }, nil, nil, false),
            ["botInfo"] = botInfo,
            ["buffAnchor"] = buffAnchor,
            ["className"] = cn,
            ["title"] = UI:Label(botInfo, { TOP, BOTTOM, 0, 0, cn }, nil, { 1, 3 }, nil, "<Title>", false),
            ["avaRank"] = UI:Label(botInfo, { TOPRIGHT, TOPRIGHT }, nil, { 2, 3 }, nil, "ava", false),
            ["dead"] = UI:Label(thb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "Status", true),
        }

        UnitFrames.CustomFrames["AvaPlayerTarget"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Percentage%"
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].labelOne.format = "Current + Shield"
        UnitFrames.CustomFrames["AvaPlayerTarget"][COMBAT_MECHANIC_FLAGS_HEALTH].labelTwo.format = "Max"

        -- Put in into table with secondary frames so it can be accessed by other functions in this module
        UnitFrames.AvaCustFrames["reticleover"] = UnitFrames.CustomFrames["AvaPlayerTarget"]
    end
end

-- Helper to create the Small Group Frames
local function CreateSmallGroupFrames()
    if UnitFrames.SV.CustomFramesGroup then
        -- Group Frame
        local group = UI:TopLevel(nil, nil)
        group:SetDrawLayer(DL_BACKGROUND)
        group:SetDrawTier(DT_LOW)
        group:SetDrawLevel(DL_CONTROLS)
        group.customPositionAttr = "CustomFramesGroupFramePos"
        group.preview = UI:Backdrop(group, "fill", nil, nil, nil, true)
        group.previewLabel = UI:Label(group.preview, { BOTTOM, TOP, 0, -1, group }, nil, nil, "ZoFontGameMedium", "Small Group", false)

        local fragment = ZO_HUDFadeSceneFragment:New(group, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)
        sceneManager:GetScene("loot"):AddFragment(fragment)

        for i = 1, 4 do
            local unitTag = "SmallGroup" .. i
            local control = UI:Control(group, nil, nil, false)
            local topInfo = UI:Control(control, { BOTTOMRIGHT, TOPRIGHT, 0, -3 }, nil, false)
            local ghb = UI:Backdrop(control, { TOPLEFT, TOPLEFT }, nil, nil, nil, false)
            ghb:SetDrawLayer(DL_BACKGROUND)
            ghb:SetDrawLevel(DL_CONTROLS)
            local gli = UI:Texture(topInfo, nil, { 20, 20 }, nil, nil, false)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = group,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = ghb,
                    ["labelOne"] = UI:Label(ghb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "xx / yy", false),
                    ["labelTwo"] = UI:Label(ghb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                    ["trauma"] = UI:StatusBar(ghb, nil, nil, nil, true),
                    ["bar"] = UI:StatusBar(ghb, nil, nil, nil, false),
                    ["shield"] = UI:StatusBar(ghb, nil, nil, nil, true),
                },
                ["topInfo"] = topInfo,
                ["name"] = UI:Label(topInfo, { BOTTOMLEFT, BOTTOMLEFT }, nil, { 0, 4 }, nil, unitTag, false),
                ["levelIcon"] = gli,
                ["level"] = UI:Label(topInfo, { LEFT, RIGHT, 1, 0, gli }, nil, { 0, 1 }, nil, "level", false),
                ["classIcon"] = UI:Texture(topInfo, { RIGHT, RIGHT, -1, 0 }, { 22, 22 }, nil, nil, false),
                ["friendIcon"] = UI:Texture(topInfo, { RIGHT, RIGHT, -20, 0 }, { 22, 22 }, nil, nil, false),
                ["roleIcon"] = UI:Texture(ghb, { LEFT, LEFT, 5, 0 }, { 18, 18 }, nil, 2, false),
                ["dead"] = UI:Label(ghb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, "Status", false),
                ["leader"] = UI:Texture(topInfo, { LEFT, LEFT, -7, 0 }, { 32, 32 }, nil, 2, false),
            }

            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            control.defaultUnitTag = GetGroupUnitTagByIndex(i)
            control:SetMouseEnabled(true)
            control:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)
            topInfo.defaultUnitTag = GetGroupUnitTagByIndex(i)
            topInfo:SetMouseEnabled(true)
            topInfo:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)
            -- Map by real unitTag as well
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
        -- Raid Frame
        local raid = UI:TopLevel(nil, nil)
        raid:SetDrawLayer(DL_BACKGROUND)
        raid:SetDrawTier(DT_LOW)
        raid:SetDrawLevel(DL_CONTROLS)
        raid.customPositionAttr = "CustomFramesRaidFramePos"
        raid.preview = UI:Backdrop(raid, { TOPLEFT, TOPLEFT }, nil, nil, nil, true)
        raid.previewLabel = UI:Label(raid.preview, { BOTTOM, TOP, 0, -1, raid }, nil, nil, "ZoFontGameMedium", "Raid Group", false)

        local fragment = ZO_HUDFadeSceneFragment:New(raid, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)
        sceneManager:GetScene("loot"):AddFragment(fragment)

        for i = 1, 12 do
            local unitTag = "RaidGroup" .. i
            local control = UI:Control(raid, nil, nil, false)
            local rhb = UI:Backdrop(control, "fill", nil, nil, nil, false)
            rhb:SetDrawLayer(DL_BACKGROUND)
            rhb:SetDrawLevel(DL_CONTROLS)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = raid,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = rhb,
                    ["label"] = UI:Label(rhb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                    ["trauma"] = UI:StatusBar(rhb, nil, nil, nil, true),
                    ["bar"] = UI:StatusBar(rhb, nil, nil, nil, false),
                    ["shield"] = UI:StatusBar(rhb, nil, nil, nil, true),
                },
                ["name"] = UI:Label(rhb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, unitTag, false),
                ["roleIcon"] = UI:Texture(rhb, { LEFT, LEFT, 4, 0 }, { 16, 16 }, nil, 2, false),
                ["classIcon"] = UI:Texture(rhb, { LEFT, LEFT, 1, 0 }, { 20, 20 }, nil, 2, false),
                ["dead"] = UI:Label(rhb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "Status", false),
                ["leader"] = UI:Texture(rhb, { LEFT, LEFT, -2, 0 }, { 28, 28 }, nil, 2, false),
            }
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)

            control.defaultUnitTag = GetGroupUnitTagByIndex(i)
            control:SetMouseEnabled(true)
            control:SetHandler("OnMouseUp", UnitFrames.GroupFrames_OnMouseUp)

            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"

            -- Map by real unitTag as well
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
        -- Pet Frame
        local pet = UI:TopLevel(nil, nil)
        pet:SetDrawLayer(DL_BACKGROUND)
        pet:SetDrawTier(DT_LOW)
        pet:SetDrawLevel(DL_CONTROLS)
        pet.customPositionAttr = "CustomFramesPetFramePos"
        pet.preview = UI:Backdrop(pet, "fill", nil, nil, nil, true)
        pet.previewLabel = UI:Label(pet.preview, { BOTTOM, TOP, 0, -1, nil }, nil, nil, "ZoFontGameMedium", "Player Pets", false)

        local fragment = ZO_HUDFadeSceneFragment:New(pet, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)
        sceneManager:GetScene("loot"):AddFragment(fragment)

        for i = 1, 7 do
            local unitTag = "PetGroup" .. i
            local control = UI:Control(pet, nil, nil, false)
            local shb = UI:Backdrop(control, "fill", nil, nil, nil, false)

            shb:SetDrawLayer(DL_BACKGROUND)
            shb:SetDrawLevel(DL_CONTROLS)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["tlw"] = pet,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = shb,
                    ["label"] = UI:Label(shb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                    ["trauma"] = UI:StatusBar(shb, nil, nil, nil, true),
                    ["bar"] = UI:StatusBar(shb, nil, nil, nil, false),
                    ["shield"] = UI:StatusBar(shb, nil, nil, nil, true),
                },
                ["dead"] = UI:Label(shb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "Status", true),
                ["name"] = UI:Label(shb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, unitTag, false),
            }
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"
        end
    end
end

-- Helper to create the Companion Frame
local function CreateCompanionFrame()
    if UnitFrames.SV.CustomFramesCompanion then
        -- Companion Frame
        local companionTlw = UI:TopLevel(nil, nil)
        companionTlw:SetDrawLayer(DL_BACKGROUND)
        companionTlw:SetDrawTier(DT_LOW)
        companionTlw:SetDrawLevel(DL_CONTROLS)
        companionTlw.customPositionAttr = "CustomFramesCompanionFramePos"
        companionTlw.preview = UI:Backdrop(companionTlw, "fill", nil, nil, nil, true)
        companionTlw.previewLabel = UI:Label(companionTlw.preview, { BOTTOM, TOP, 0, -1, nil }, nil, nil, "ZoFontGameMedium", "Player Companion", false)

        local fragment = ZO_HUDFadeSceneFragment:New(companionTlw, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)
        sceneManager:GetScene("loot"):AddFragment(fragment)

        local companion = UI:Control(companionTlw, nil, nil, false)
        local shb = UI:Backdrop(companion, "fill", nil, nil, nil, false)

        shb:SetDrawLayer(DL_BACKGROUND)
        shb:SetDrawLevel(DL_CONTROLS)

        UnitFrames.CustomFrames["companion"] =
        {
            ["unitTag"] = "companion",
            ["tlw"] = companionTlw,
            ["control"] = companion,
            [COMBAT_MECHANIC_FLAGS_HEALTH] =
            {
                ["backdrop"] = shb,
                ["label"] = UI:Label(shb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                ["trauma"] = UI:StatusBar(shb, nil, nil, nil, true),
                ["bar"] = UI:StatusBar(shb, nil, nil, nil, false),
                ["shield"] = UI:StatusBar(shb, nil, nil, nil, true),
            },
            ["dead"] = UI:Label(shb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "Status", true),
            ["name"] = UI:Label(shb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, nil, false),
        }
        UnitFrames.CustomFrames["companion"].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
        UnitFrames.CustomFrames["companion"][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Current (Percentage%)"
    end
end

-- Helper to create the Bosses Frames
local function CreateBossFrames()
    if UnitFrames.SV.CustomFramesBosses then
        -- Bosses Frame
        local bosses = UI:TopLevel(nil, nil)
        bosses:SetDrawLayer(DL_BACKGROUND)
        bosses:SetDrawTier(DT_LOW)
        bosses:SetDrawLevel(DL_CONTROLS)
        bosses.customPositionAttr = "CustomFramesBossesFramePos"
        bosses.preview = UI:Backdrop(bosses, "fill", nil, nil, nil, true)
        bosses.previewLabel = UI:Label(bosses.preview, { BOTTOM, TOP, 0, -1, bosses }, nil, nil, "ZoFontGameMedium", "Bosses Group", false)

        local fragment = ZO_HUDFadeSceneFragment:New(bosses, 0, 0)

        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)
        sceneManager:GetScene("loot"):AddFragment(fragment)

        for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local unitTag = "boss" .. i
            local control = UI:Control(bosses, nil, nil, false)
            local bhb = UI:Backdrop(control, "fill", nil, nil, nil, false)

            bhb:SetDrawLayer(DL_BACKGROUND)
            bhb:SetDrawLevel(DL_CONTROLS)

            UnitFrames.CustomFrames[unitTag] =
            {
                ["unitTag"] = unitTag,
                ["tlw"] = bosses,
                ["control"] = control,
                [COMBAT_MECHANIC_FLAGS_HEALTH] =
                {
                    ["backdrop"] = bhb,
                    ["label"] = UI:Label(bhb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "zz%", false),
                    ["trauma"] = UI:StatusBar(bhb, nil, nil, nil, true),
                    ["bar"] = UI:StatusBar(bhb, nil, nil, nil, false),
                    ["invulnerable"] = UI:StatusBar(bhb, nil, nil, nil, false),
                    ["invulnerableInlay"] = UI:StatusBar(bhb, nil, nil, nil, false),
                    ["shield"] = UI:StatusBar(bhb, nil, nil, nil, true),
                    ["threshold"] = UnitFrames.targetThreshold,
                },
                ["dead"] = UI:Label(bhb, { RIGHT, RIGHT, -5, 0 }, nil, { 2, 1 }, nil, "Status", true),
                ["name"] = UI:Label(bhb, { LEFT, LEFT, 5, 0 }, nil, { 0, 1 }, nil, unitTag, false),
            }
            UnitFrames.CustomFrames[unitTag].name:SetWrapMode(TEXT_WRAP_MODE_TRUNCATE)
            UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].label.format = "Percentage%"
        end
    end
end

-- Helper to set up common actions for all created frames
local function SetupCommonFrameActions()
    -- Callback used to hide anchor coords preview label on movement start
    local tlwOnMoveStart = function (self)
        eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
            self.preview.anchorLabel:SetText(zo_strformat("<<1>>, <<2>>", self:GetLeft(), self:GetTop()))
        end)
    end
    -- Callback used to save new position of frames
    local tlwOnMoveStop = function (self)
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
        UnitFrames.SV[self.customPositionAttr] = { self:GetLeft(), self:GetTop() }
    end

    -- Common actions for all created frames:
    for _, baseName in pairs(
        {
            "player",
            "reticleover",
            "companion",
            "SmallGroup",
            "RaidGroup",
            "boss",
            "AvaPlayerTarget",
            "PetGroup",
        }) do
        -- set mouse handlers for all created tlws and create anchor coords preview labels
        local unitFrame = UnitFrames.CustomFrames[baseName] or UnitFrames.CustomFrames[baseName .. "1"] or nil
        if unitFrame ~= nil and unitFrame.tlw ~= nil then
            -- Movement handlers
            unitFrame.tlw:SetHandler("OnMoveStart", tlwOnMoveStart)
            unitFrame.tlw:SetHandler("OnMoveStop", tlwOnMoveStop)

            -- Create Texture and a label for Anchor Preview
            unitFrame.tlw.preview.anchorTexture = UI:Texture(unitFrame.tlw.preview, { TOPLEFT, TOPLEFT }, { 16, 16 }, "/esoui/art/reticle/border_topleft.dds", DL_OVERLAY, false)
            unitFrame.tlw.preview.anchorTexture:SetColor(1, 1, 0, 0.9)

            unitFrame.tlw.preview.anchorLabel = UI:Label(unitFrame.tlw.preview, { BOTTOMLEFT, TOPLEFT, 0, -1 }, nil, { 0, 2 }, "ZoFontGameSmall", "xxx, yyy", false)
            unitFrame.tlw.preview.anchorLabel:SetColor(1, 1, 0, 1)
            unitFrame.tlw.preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
            unitFrame.tlw.preview.anchorLabel:SetDrawTier(DT_MEDIUM)
            unitFrame.tlw.preview.anchorLabelBg = UI:Backdrop(unitFrame.tlw.preview.anchorLabel, "fill", nil, { 0, 0, 0, 1 }, { 0, 0, 0, 1 }, false)
            unitFrame.tlw.preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
            unitFrame.tlw.preview.anchorLabelBg:SetDrawTier(DT_LOW)
        end

        -- Now we have to anchor all bars to their backdrops
        local shieldOverlay = (baseName == "RaidGroup" or baseName == "boss") or not UnitFrames.SV.CustomShieldBarSeparate
        for i = 0, 12 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            if UnitFrames.CustomFrames[unitTag] then
                for _, powerType in pairs(
                    {
                        COMBAT_MECHANIC_FLAGS_HEALTH,
                        COMBAT_MECHANIC_FLAGS_MAGICKA,
                        COMBAT_MECHANIC_FLAGS_STAMINA,
                        "alternative",
                    }) do
                    local powerBar = UnitFrames.CustomFrames[unitTag][powerType]
                    if powerBar then
                        powerBar.bar:SetAnchor(TOPLEFT, powerBar.backdrop, TOPLEFT, 1, 1)
                        powerBar.bar:SetAnchor(BOTTOMRIGHT, powerBar.backdrop, BOTTOMRIGHT, -1, -1)

                        -- Also set anchors for enlightenment bar
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

                        if powerBar.shield then
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
                                -- In non-overlay mode we need to create separate backdrop for shield
                                powerBar.shieldbackdrop = UI:Backdrop(UnitFrames.CustomFrames[unitTag].control, nil, nil, nil, nil, true)
                                powerBar.shield:SetAnchor(TOPLEFT, powerBar.shieldbackdrop, TOPLEFT, 1, 1)
                                powerBar.shield:SetAnchor(BOTTOMRIGHT, powerBar.shieldbackdrop, BOTTOMRIGHT, -1, -1)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Helper to set up Player regen/degen animations
local function SetupPlayerRegenAnimations()
    if UnitFrames.SV.PlayerEnableRegen then
        for _, baseName in pairs({ "player", "reticleover", "AvaPlayerTarget" }) do
            local unitTag = baseName
            if UnitFrames.CustomFrames[unitTag] then
                for _, powerType in pairs({ COMBAT_MECHANIC_FLAGS_HEALTH }) do
                    if UnitFrames.CustomFrames[unitTag][powerType] then
                        local backdrop = UnitFrames.CustomFrames[unitTag][powerType].backdrop
                        local size1
                        local size2
                        if baseName == "player" then
                            size1 = UnitFrames.SV.PlayerBarWidth
                            size2 = UnitFrames.SV.PlayerBarHeightHealth
                        elseif baseName == "reticleover" then
                            size1 = UnitFrames.SV.TargetBarWidth
                            size2 = UnitFrames.SV.TargetBarHeight
                        elseif baseName == "AvaPlayerTarget" then
                            size1 = UnitFrames.SV.AvaTargetBarWidth
                            size2 = UnitFrames.SV.AvaTargetBarHeight
                        end
                        if size1 ~= nil and size2 ~= nil then
                            UnitFrames.CustomFrames[unitTag][powerType].regen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "regen1")
                            UnitFrames.CustomFrames[unitTag][powerType].regen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "regen2")
                            UnitFrames.CustomFrames[unitTag][powerType].degen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "degen1")
                            UnitFrames.CustomFrames[unitTag][powerType].degen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "degen2")
                        end
                    end
                end
            end
        end
    end
end

-- Helper to set up Group regen/degen animations
local function SetupGroupRegenAnimations()
    if UnitFrames.SV.GroupEnableRegen then
        for i = 1, 4 do
            local unitTag = "SmallGroup" .. i
            if UnitFrames.CustomFrames[unitTag] then
                for _, powerType in pairs(
                    {
                        COMBAT_MECHANIC_FLAGS_HEALTH,
                        COMBAT_MECHANIC_FLAGS_MAGICKA,
                        COMBAT_MECHANIC_FLAGS_STAMINA,
                    }) do
                    if UnitFrames.CustomFrames[unitTag][powerType] then
                        local backdrop = UnitFrames.CustomFrames[unitTag][powerType].backdrop
                        local size1 = UnitFrames.SV.GroupBarWidth
                        local size2 = UnitFrames.SV.GroupBarHeight
                        if size1 ~= nil and size2 ~= nil then
                            UnitFrames.CustomFrames[unitTag][powerType].regen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.4) }, 0.55, "regen1")
                            UnitFrames.CustomFrames[unitTag][powerType].regen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.4) }, 0.55, "regen2")
                            UnitFrames.CustomFrames[unitTag][powerType].degen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.4) }, 0.55, "degen1")
                            UnitFrames.CustomFrames[unitTag][powerType].degen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.4) }, 0.55, "degen2")
                        end
                    end
                end
            end
        end
    end
end

-- Helper to set up Raid regen/degen animations
local function SetupRaidRegenAnimations()
    if UnitFrames.SV.RaidEnableRegen then
        for i = 1, 12 do
            local unitTag = "RaidGroup" .. i
            if UnitFrames.CustomFrames[unitTag] then
                for _, powerType in pairs(
                    {
                        COMBAT_MECHANIC_FLAGS_HEALTH,
                        COMBAT_MECHANIC_FLAGS_MAGICKA,
                        COMBAT_MECHANIC_FLAGS_STAMINA,
                    }) do
                    if UnitFrames.CustomFrames[unitTag][powerType] then
                        local backdrop = UnitFrames.CustomFrames[unitTag][powerType].backdrop
                        local size1 = UnitFrames.SV.RaidBarWidth
                        local size2 = UnitFrames.SV.RaidBarHeight
                        if size1 ~= nil and size2 ~= nil then
                            UnitFrames.CustomFrames[unitTag][powerType].regen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "regen1")
                            UnitFrames.CustomFrames[unitTag][powerType].regen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "regen2")
                            UnitFrames.CustomFrames[unitTag][powerType].degen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "degen1")
                            UnitFrames.CustomFrames[unitTag][powerType].degen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "degen2")
                        end
                    end
                end
            end
        end
    end
end

-- Helper to set up Boss regen/degen animations
local function SetupBossRegenAnimations()
    if UnitFrames.SV.BossEnableRegen then
        for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local unitTag = "boss" .. i
            if UnitFrames.CustomFrames[unitTag] then
                for _, powerType in pairs(
                    {
                        COMBAT_MECHANIC_FLAGS_HEALTH,
                        COMBAT_MECHANIC_FLAGS_MAGICKA,
                        COMBAT_MECHANIC_FLAGS_STAMINA,
                    }) do
                    if UnitFrames.CustomFrames[unitTag][powerType] then
                        local backdrop = UnitFrames.CustomFrames[unitTag][powerType].backdrop
                        local size1 = UnitFrames.SV.BossBarWidth
                        local size2 = UnitFrames.SV.BossBarHeight
                        if size1 ~= nil and size2 ~= nil then
                            UnitFrames.CustomFrames[unitTag][powerType].regen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "regen1")
                            UnitFrames.CustomFrames[unitTag][powerType].regen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "regen2")
                            UnitFrames.CustomFrames[unitTag][powerType].degen1 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "degen1")
                            UnitFrames.CustomFrames[unitTag][powerType].degen2 = CreateRegenAnimation(backdrop, { CENTER, CENTER, 0, 0 }, { size1 - 4, size2 - (size2 * 0.3) }, 0.55, "degen2")
                        end
                    end
                end
            end
        end
    end
end

-- Helper to set up Player armor overlays
local function SetupPlayerArmorOverlays()
    if UnitFrames.SV.PlayerEnableArmor then
        for _, baseName in pairs({ "player", "reticleover", "AvaPlayerTarget" }) do
            local unitTag = baseName
            if UnitFrames.CustomFrames[unitTag] then
                -- Assume that unitTag DO have [COMBAT_MECHANIC_FLAGS_HEALTH] field
                if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat == nil then
                    UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat = {}
                end
                local backdrop = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
                UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_ARMOR_RATING] =
                {
                    ["dec"] = CreateDecreasedArmorOverlay(backdrop, false),
                    ["inc"] = UI:Texture(backdrop, { CENTER, CENTER, 13, 0 }, { 24, 24 }, "/esoui/art/icons/alchemy/crafting_alchemy_trait_increasearmor.dds", 2, true),
                }
            end
        end
    end
end

-- Helper to set up Group armor overlays
local function SetupGroupArmorOverlays()
    if UnitFrames.SV.GroupEnableArmor then
        for i = 1, 4 do
            local unitTag = "SmallGroup" .. i
            if UnitFrames.CustomFrames[unitTag] then
                -- Assume that unitTag DO have [COMBAT_MECHANIC_FLAGS_HEALTH] field
                if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat == nil then
                    UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat = {}
                end
                local backdrop = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
                UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_ARMOR_RATING] =
                {
                    ["dec"] = CreateDecreasedArmorOverlay(backdrop, false),
                    ["inc"] = UI:Texture(backdrop, { CENTER, CENTER, 13, 0 }, { 24, 24 }, "/esoui/art/icons/alchemy/crafting_alchemy_trait_increasearmor.dds", 2, true),
                }
            end
        end
    end
end

-- Helper to set up Raid armor overlays
local function SetupRaidArmorOverlays()
    if UnitFrames.SV.RaidEnableArmor then
        for i = 1, 12 do
            local unitTag = "RaidGroup" .. i
            if UnitFrames.CustomFrames[unitTag] then
                -- Assume that unitTag DO have [COMBAT_MECHANIC_FLAGS_HEALTH] field
                if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat == nil then
                    UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat = {}
                end
                local backdrop = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
                UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_ARMOR_RATING] =
                {
                    ["dec"] = CreateDecreasedArmorOverlay(backdrop, false),
                    ["inc"] = UI:Texture(backdrop, { CENTER, CENTER, 13, 0 }, { 24, 24 }, "/esoui/art/icons/alchemy/crafting_alchemy_trait_increasearmor.dds", 2, true),
                }
            end
        end
    end
end

-- Helper to set up Boss armor overlays
local function SetupBossArmorOverlays()
    if UnitFrames.SV.BossEnableArmor then
        for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
            local unitTag = "boss" .. i
            if UnitFrames.CustomFrames[unitTag] then
                -- Assume that unitTag DO have [COMBAT_MECHANIC_FLAGS_HEALTH] field
                if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat == nil then
                    UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat = {}
                end
                local backdrop = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].backdrop
                UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_ARMOR_RATING] =
                {
                    ["dec"] = CreateDecreasedArmorOverlay(backdrop, false),
                    ["inc"] = UI:Texture(backdrop, { CENTER, CENTER, 13, 0 }, { 24, 24 }, "/esoui/art/icons/alchemy/crafting_alchemy_trait_increasearmor.dds", 2, true),
                }
            end
        end
    end
end

-- Helper to set up Power Glow animations for all frames that have it displayed
local function SetupPowerGlowAnimations()
    for _, baseName in pairs({ "player", "reticleover", "AvaPlayerTarget", "boss", "SmallGroup", "RaidGroup" }) do
        for i = 0, 12 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            if UnitFrames.CustomFrames[unitTag] then
                if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH] then
                    if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat then
                        if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_POWER] then
                            if UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_POWER].inc then
                                -- Create glow animation
                                local control = UnitFrames.CustomFrames[unitTag][COMBAT_MECHANIC_FLAGS_HEALTH].stat[STAT_POWER].inc
                                local animation, timeline = CreateSimpleAnimation(ANIMATION_TEXTURE, control)
                                animation:SetImageData(4, 8)
                                animation:SetFramerate(GetFramerate())
                                animation:SetDuration(1000)
                                timeline:SetPlaybackType(ANIMATION_PLAYBACK_LOOP, LOOP_INDEFINITELY)

                                control.animation = animation
                                control.timeline = timeline

                                control.timeline:PlayFromStart()
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Add the top level windows to global controls list, so they can be hidden.
local function AddTopLevelWindows()
    for _, unitTag in pairs(
        {
            "player",
            "reticleover",
            "companion",
            "SmallGroup1",
            "RaidGroup1",
            "boss1",
            "AvaPlayerTarget",
            "PetGroup1",
        }) do
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
    SetupPlayerRegenAnimations()
    SetupGroupRegenAnimations()
    SetupRaidRegenAnimations()
    SetupBossRegenAnimations()
    SetupPlayerArmorOverlays()
    SetupGroupArmorOverlays()
    SetupRaidArmorOverlays()
    SetupBossArmorOverlays()
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
    -- Set positions of tlws using saved values or default ones
    UnitFrames.CustomFramesSetPositions()
    -- Apply formatting for labels
    UnitFrames.CustomFramesFormatLabels(true)
    -- Apply bar textures
    UnitFrames.CustomFramesApplyTexture()
    -- Apply fonts
    UnitFrames.CustomFramesApplyFont()
    UnitFrames.CustomFramesApplyBarAlignment()

    AddTopLevelWindows()
end
