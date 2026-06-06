-- -----------------------------------------------------------------------------
--  LuiExtended - CustomFrames post-create orchestration
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE
--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
local moduleName = UnitFrames.moduleName
local eventManager = GetEventManager()
local PowerData = LUIE.CustomFramesPowerData
--- @type LUIE.CustomFramesShared
local Shared = LUIE.CustomFramesShared

function UnitFrames.CustomFramesApplyShieldBarMode()
    local baseNameKey = nil
    local baseName
    while true do
        baseNameKey, baseName = next(Shared.SHIELD_BAR_FRAME_BASE_NAMES, baseNameKey)
        if baseNameKey == nil then break end
        local shieldOverlay = (baseName == "RaidGroup" or baseName == "boss") or not UnitFrames.SV.CustomShieldBarSeparate

        for i = 0, 12 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            local frame = UnitFrames.CustomFrames[unitTag]
            if frame then
                PowerData:ApplyShieldBarMode(frame, shieldOverlay)
            end
        end
    end
    UnitFrames.RefreshCustomFrameShields()
end

-- Helper to set up common actions for all created frames
local function SetupCommonFrameActions()
    local frameBaseNames = Shared.FRAME_TLW_BASE_NAMES

    local baseNameKey = nil
    local baseName
    while true do
        baseNameKey, baseName = next(frameBaseNames, baseNameKey)
        if baseNameKey == nil then break end
        local unitFrame = UnitFrames.CustomFrames[baseName] or UnitFrames.CustomFrames[baseName .. "1"]
        if unitFrame and unitFrame.tlw and unitFrame.SetupMovementAndPreview then
            unitFrame:SetupMovementAndPreview(moduleName, eventManager)
        end

        for i = 0, 12 do
            local unitTag = (i == 0) and baseName or (baseName .. i)
            local frame = UnitFrames.CustomFrames[unitTag]

            if frame then
                if frame.SetupPowerBarAnchors then
                    frame:SetupPowerBarAnchors()
                end
            end
        end
    end

    UnitFrames.CustomFramesApplyShieldBarMode()
end

local function SetupRegenAnimations(frameConfig)
    PowerData:ApplyRegenStrips(frameConfig)
end

local function SetupArmorOverlays(frameConfig)
    PowerData:ApplyArmorAndPowerOverlays(frameConfig)
end

-- Helper to set up Power Glow animations for all frames that have it displayed
local function SetupPowerGlowAnimations()
    local baseNameList = { "player", "reticleover", "AvaPlayerTarget", "boss", "SmallGroup", "RaidGroup", "companion", "PetGroup" }
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

                if not control.timeline then
                    control.timeline = ANIMATION_MANAGER:CreateTimelineFromVirtual("IncreasedPowerAnimation", control)
                    control.animation = control.timeline:GetAnimation(1)
                    control.animation:SetFramerate(32)
                end
            end
        end
    end
end

-- Add the top level windows to global controls list
local function AddTopLevelWindows()
    for keyIndex = 1, #Shared.MOVER_ANCHOR_REGISTRY_KEYS do
        local unitTag = Shared.MOVER_ANCHOR_REGISTRY_KEYS[keyIndex]
        if UnitFrames.CustomFrames[unitTag] then
            LUIE.Components[moduleName .. "_CustomFrame_" .. unitTag] = UnitFrames.CustomFrames[unitTag].tlw
        end
    end
end

-- Used to create custom frames extender controls for player and target.
-- Called from UnitFrames.Initialize
function UnitFrames.CreateCustomFrames()
    LUIE_PlayerCustomFrameData:New():BuildData()
    LUIE_TargetCustomFrameData:New():BuildData()
    LUIE_AvaTargetCustomFrameData:New():BuildData()
    LUIE_SmallGroupCustomFrameData:New():BuildData()
    LUIE_RaidCustomFrameData:New():BuildData()
    LUIE_PetCustomFrameData:New():BuildData()
    LUIE_CompanionCustomFrameData:New():BuildData()
    LUIE_BossCustomFrameData:New():BuildData()
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
            enableFlag = "TargetEnableRegen",
            widthSV = "TargetBarWidth",
            heightSV = "TargetBarHeight",
            heightMultiplier = 0.3
        },
        {
            prefix = "AvaPlayerTarget",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "TargetEnableRegen",
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
        {
            prefix = "companion",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "CompanionEnableRegen",
            widthSV = "CompanionWidth",
            heightSV = "CompanionHeight",
            heightMultiplier = 0.4
        },
        {
            prefix = "PetGroup",
            startIndex = 1,
            endIndex = 7,
            enableFlag = "PetEnableRegen",
            widthSV = "PetWidth",
            heightSV = "PetHeight",
            heightMultiplier = 0.4
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
            enableFlag = "PlayerEnableArmor",
            powerEnableFlag = "PlayerEnablePower",
        },
        {
            prefix = "reticleover",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "TargetEnableArmor",
            powerEnableFlag = "TargetEnablePower",
        },
        {
            prefix = "AvaPlayerTarget",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "TargetEnableArmor",
            powerEnableFlag = "TargetEnablePower",
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
        {
            prefix = "companion",
            startIndex = 0,
            endIndex = 0,
            enableFlag = "CompanionEnableArmor",
            powerEnableFlag = "CompanionEnablePower",
        },
        {
            prefix = "PetGroup",
            startIndex = 1,
            endIndex = 7,
            enableFlag = "PetEnableArmor",
            powerEnableFlag = "PetEnablePower",
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

    local frameRegistryKey = nil
    local frameEntry
    while true do
        frameRegistryKey, frameEntry = next(UnitFrames.CustomFrames, frameRegistryKey)
        if frameRegistryKey == nil then break end
        if frameEntry and frameEntry.RefreshDynamicData then
            frameEntry:RefreshDynamicData()
        end
    end

    -- Set proper anchors according to user preferences
    UnitFrames.CustomFramesApplyAllLayouts(
        {
            unhide = true,
            includeRaid = true,
            includeBosses = true,
            includeCompanionPetUpdates = true,
        })
    UnitFrames.CustomFramesSetPositions()
    UnitFrames.CustomFramesFormatLabels(true)
    UnitFrames.CustomFramesApplyTexture()
    UnitFrames.CustomFramesApplyFont()
    UnitFrames.CustomFramesApplyBarAlignment()

    LUIE.RefreshMoverOverlayFonts()

    AddTopLevelWindows()
end
