--- @diagnostic disable: missing-fields
-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

--- @class (partial) UnitFrames
local UnitFrames = LUIE.UnitFrames
if not UnitFrames then return end

local LuiData = LuiData
local Data = LuiData.Data
local Effects = Data.Effects
local Tooltips = Data.Tooltips
local Abilities = Data.Abilities

--- @class GroupFoodDrinkBuffManager
local GroupFoodDrinkBuffManager = {}
UnitFrames.GroupFoodDrinkBuff = GroupFoodDrinkBuffManager

local Shared = UnitFrames.LibGroupBroadcastShared

-- =====================================================================================================================
-- CONSTANTS
-- =====================================================================================================================

local ICON_FOOD_GREEN = LUIE_MEDIA_ICONS_CONSUMABLES_CONSUMABLE_FOOD_GREEN_DDS
local ICON_FOOD_BLUE = LUIE_MEDIA_ICONS_CONSUMABLES_CONSUMABLE_FOOD_BLUE_DDS
local ICON_FOOD_PURPLE = LUIE_MEDIA_ICONS_CONSUMABLES_CONSUMABLE_FOOD_PURPLE_DDS
local ICON_DRINK_GREEN = LUIE_MEDIA_ICONS_CONSUMABLES_CONSUMABLE_DRINK_GREEN_DDS
local ICON_DRINK_BLUE = LUIE_MEDIA_ICONS_CONSUMABLES_CONSUMABLE_DRINK_BLUE_DDS
local ICON_DRINK_PURPLE = LUIE_MEDIA_ICONS_CONSUMABLES_CONSUMABLE_DRINK_PURPLE_DDS
local ICON_NO_BUFF = ZO_NO_TEXTURE_FILE

local DELAY_GROUP_JOIN = 100
local DELAY_GROUP_LEFT = 100
local DELAY_PLAYER_ACTIVATED = 500
local DELAY_INITIAL_SETUP = 1000
local DELAY_INVENTORY_UPDATE = 50

local ICON_BORDER_SIZE = 2
local ICON_SPACING = 3

local QUALITY_PURPLE_STAT_COUNT = 3
local QUALITY_BLUE_STAT_COUNT = 2

local SLASH_COMMAND = "/luiefoodbuff"

-- Buff type constants (simplified from LibFoodDrinkBuff). Thank you (Scootworks & Baertram)
local BUFF_TYPE_NONE = 0
local BUFF_TYPE_MAX_HEALTH = 1
local BUFF_TYPE_MAX_MAGICKA = 2
local BUFF_TYPE_MAX_STAMINA = 4
local BUFF_TYPE_REGEN_HEALTH = 8
local BUFF_TYPE_REGEN_MAGICKA = 16
local BUFF_TYPE_REGEN_STAMINA = 32

-- Local API references
local GetNumBuffs = GetNumBuffs
local GetUnitBuffInfo = GetUnitBuffInfo
local GetGameTimeMilliseconds = GetGameTimeMilliseconds
local DoesUnitExist = DoesUnitExist
local IsUnitDead = IsUnitDead
local IsUnitOnline = IsUnitOnline
local IsUnitGrouped = IsUnitGrouped
local ITEM_SOUND_CATEGORY_FOOD = ITEM_SOUND_CATEGORY_FOOD
local ITEM_SOUND_CATEGORY_DRINK = ITEM_SOUND_CATEGORY_DRINK

-- Combined food & drink buff lookup table
local AllFoodDrinkBuffs = {}
ZO_CombineNonContiguousTables(AllFoodDrinkBuffs, Effects.IsFoodBuff, Effects.IsDrinkBuff)

-- =====================================================================================================================
-- STATE
-- =====================================================================================================================

local isInitialized = false

-- =====================================================================================================================
-- HELPER FUNCTIONS
-- =====================================================================================================================

local function GetSettings()
    return UnitFrames.SV.GroupFoodDrinkBuff
end

local function IsModuleEnabled()
    local settings = GetSettings()
    return settings and settings.enabled
end

local function ShouldShowOnFrame(isRaid)
    if isRaid then return false end
    return true
end

local function CountBuffTypeStats(buffType)
    local statCount = 0
    local hasRegen = false
    local hasMax = false

    local regenTypes =
    {
        BUFF_TYPE_REGEN_HEALTH,
        BUFF_TYPE_REGEN_MAGICKA,
        BUFF_TYPE_REGEN_STAMINA
    }

    local maxTypes =
    {
        BUFF_TYPE_MAX_HEALTH,
        BUFF_TYPE_MAX_MAGICKA,
        BUFF_TYPE_MAX_STAMINA
    }

    for _, regenType in ipairs(regenTypes) do
        if buffType >= regenType and (buffType % (regenType * 2)) >= regenType then
            statCount = statCount + 1
            hasRegen = true
        end
    end

    for _, maxType in ipairs(maxTypes) do
        if buffType >= maxType and (buffType % (maxType * 2)) >= maxType then
            statCount = statCount + 1
            hasMax = true
        end
    end

    return statCount, hasRegen, hasMax
end

local function DetermineIconQuality(statCount, hasRegen, hasMax)
    if statCount >= QUALITY_PURPLE_STAT_COUNT or (hasMax and hasRegen and statCount >= QUALITY_BLUE_STAT_COUNT) then
        return "purple"
    elseif statCount == QUALITY_BLUE_STAT_COUNT then
        return "blue"
    else
        return "green"
    end
end

local function GetIconForBuffType(buffType, isDrink)
    if buffType == BUFF_TYPE_NONE then
        return ICON_NO_BUFF
    end

    local statCount, hasRegen, hasMax = CountBuffTypeStats(buffType)
    local quality = DetermineIconQuality(statCount, hasRegen, hasMax)

    local iconMap =
    {
        purple = isDrink and ICON_DRINK_PURPLE or ICON_FOOD_PURPLE,
        blue = isDrink and ICON_DRINK_BLUE or ICON_FOOD_BLUE,
        green = isDrink and ICON_DRINK_GREEN or ICON_FOOD_GREEN
    }

    return iconMap[quality]
end

local function GetIconSize()
    local settings = GetSettings()
    local combatStatsSettings = Shared.GetCombatStatsSettings()

    if combatStatsSettings and combatStatsSettings.enabled and combatStatsSettings.showUltimate then
        return combatStatsSettings.ultIconGroupSize
    else
        return settings.iconSizeGroup
    end
end

local function GetIconOffset()
    local settings = GetSettings()
    return settings.iconOffsetXGroup, settings.iconOffsetYGroup
end

local function DetermineAnchorPoint(frameData)
    local backdrop = Shared.GetHealthBackdrop(frameData)
    return backdrop, LEFT, RIGHT, nil
end

local function FindBuffSlotAndIconByAbilityId(unitTag, abilityId)
    local numBuffs = GetNumBuffs(unitTag)
    if numBuffs == 0 then return nil, nil end

    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconTexture, buffType, effectType, abilityType, statusEffectType, buffAbilityId = GetUnitBuffInfo(unitTag, i)
        if buffAbilityId == abilityId then
            return buffSlot, iconTexture
        end
    end

    return nil, nil
end

local function CalculateBuffType(abilityId, buffName)
    if not abilityId or not AllFoodDrinkBuffs[abilityId] then
        return BUFF_TYPE_NONE
    end

    local buffType = BUFF_TYPE_NONE
    local lowerName = buffName and string.lower(buffName) or ""

    if zo_plainstrfind(lowerName, "max health") or zo_plainstrfind(lowerName, "increase health") then
        buffType = buffType + BUFF_TYPE_MAX_HEALTH
    end
    if zo_plainstrfind(lowerName, "max magicka") or zo_plainstrfind(lowerName, "increase magicka") then
        buffType = buffType + BUFF_TYPE_MAX_MAGICKA
    end
    if zo_plainstrfind(lowerName, "max stamina") or zo_plainstrfind(lowerName, "increase stamina") then
        buffType = buffType + BUFF_TYPE_MAX_STAMINA
    end
    if zo_plainstrfind(lowerName, "health recovery") or zo_plainstrfind(lowerName, "regen health") then
        buffType = buffType + BUFF_TYPE_REGEN_HEALTH
    end
    if zo_plainstrfind(lowerName, "magicka recovery") or zo_plainstrfind(lowerName, "regen magicka") then
        buffType = buffType + BUFF_TYPE_REGEN_MAGICKA
    end
    if zo_plainstrfind(lowerName, "stamina recovery") or zo_plainstrfind(lowerName, "regen stamina") then
        buffType = buffType + BUFF_TYPE_REGEN_STAMINA
    end

    if buffType == BUFF_TYPE_NONE then
        buffType = BUFF_TYPE_MAX_HEALTH
    end

    return buffType
end

local function GetFoodBuffInfos(unitTag)
    local numBuffs = GetNumBuffs(unitTag)
    if numBuffs == 0 then
        return BUFF_TYPE_NONE, nil, nil, nil, nil, nil, nil, 0
    end

    for i = 1, numBuffs do
        local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconTexture, buffType, effectType, abilityType, statusEffectType, abilityId = GetUnitBuffInfo(unitTag, i)

        if abilityId and AllFoodDrinkBuffs[abilityId] then
            local calculatedBuffType = CalculateBuffType(abilityId, buffName)
            local isDrink = Effects.IsDrinkBuff[abilityId] == true
            local timeLeft = 0
            if timeEnding then
                local currentTime = GetGameTimeMilliseconds()
                timeLeft = zo_max(0, zo_floor((timeEnding * 1000 - currentTime) / 1000))
            end

            return calculatedBuffType, isDrink, abilityId, buffName, timeStarted, timeEnding, iconTexture, timeLeft
        end
    end

    return BUFF_TYPE_NONE, nil, nil, nil, nil, nil, nil, 0
end

-- =====================================================================================================================
-- TOOLTIP HANDLING
-- =====================================================================================================================

local function ShowBuffTooltip(control, frameData)
    if not frameData.foodDrinkBuff.currentBuffSlot or not frameData.unitTag then return end

    InitializeTooltip(InformationTooltip, control, TOPRIGHT, 0, -2, BOTTOMLEFT)

    local abilityId = frameData.foodDrinkBuff.currentAbilityId
    local effectOverride = Effects.EffectOverride and Effects.EffectOverride[abilityId]

    local tooltipTitle = zo_strformat(SI_ABILITY_TOOLTIP_NAME, frameData.foodDrinkBuff.currentBuffName or "")
    local tooltipText

    if effectOverride and effectOverride.tooltip then
        tooltipText = effectOverride.tooltip
    else
        tooltipText = GetAbilityEffectDescription(frameData.foodDrinkBuff.currentBuffSlot)
    end

    if tooltipText and tooltipText ~= "" then
        InformationTooltip:AddLine(tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil, MODIFY_TEXT_TYPE_NONE)
        InformationTooltip:AddLine(tooltipText, "", ZO_NORMAL_TEXT:UnpackRGBA())
    else
        InformationTooltip:SetAbilityId(abilityId)
    end
end

local function HideBuffTooltip()
    ClearTooltip(InformationTooltip)
end

-- =====================================================================================================================
-- UI CREATION
-- =====================================================================================================================

local function CreateFoodDrinkBuffUI(frameData)
    if frameData.foodDrinkBuff then return end

    local iconSize = GetIconSize()
    local offsetX, offsetY = GetIconOffset()
    local anchorControl, anchorPoint, anchorRelPoint, customOffsetX = DetermineAnchorPoint(frameData)

    if not anchorControl then return end

    if customOffsetX then
        offsetX = customOffsetX
    end

    -- Get the container (already exists in XML)
    local container = frameData.libGroupContainer

    -- Anchor container to health bar if not already anchored
    local numAnchors = container:GetNumAnchors()
    if numAnchors == 0 then
        container:SetAnchor(anchorPoint, anchorControl, anchorRelPoint, offsetX, offsetY)
    end

    frameData.foodDrinkBuff = {}

    -- Get food/drink controls from XML
    local backdrop = container:GetNamedChild("_FoodDrinkBackdrop")
    local icon = backdrop:GetNamedChild("_Icon")
    local label = backdrop:GetNamedChild("_Label")

    -- Set dimensions based on settings
    backdrop:SetDimensions(iconSize, iconSize)
    icon:SetDimensions(iconSize - ICON_BORDER_SIZE, iconSize - ICON_BORDER_SIZE)

    -- Anchor food/drink first in container
    backdrop:ClearAnchors()
    backdrop:SetAnchor(LEFT, container, LEFT, 0, 0)

    -- Set draw properties
    backdrop:SetDrawLayer(DL_BACKGROUND)
    backdrop:SetDrawLevel(13)
    backdrop:SetMouseEnabled(true)
    backdrop:SetHandler("OnMouseEnter", function (control)
        ShowBuffTooltip(control, frameData)
    end)
    backdrop:SetHandler("OnMouseExit", HideBuffTooltip)

    -- Reposition ult/potion icons to come after food/drink
    if frameData.combatStats and frameData.combatStats.ult1Backdrop then
        frameData.combatStats.ult1Backdrop:ClearAnchors()
        frameData.combatStats.ult1Backdrop:SetAnchor(LEFT, backdrop, RIGHT, 3, 0)

        if frameData.combatStats.ult2Backdrop then
            frameData.combatStats.ult2Backdrop:ClearAnchors()
            frameData.combatStats.ult2Backdrop:SetAnchor(LEFT, frameData.combatStats.ult1Backdrop, RIGHT, 3, 0)
        end
    end

    if frameData.potionCooldown and frameData.potionCooldown.backdrop then
        frameData.potionCooldown.backdrop:ClearAnchors()
        if frameData.combatStats and frameData.combatStats.ult2Backdrop then
            frameData.potionCooldown.backdrop:SetAnchor(LEFT, frameData.combatStats.ult2Backdrop, RIGHT, 3, 0)
        elseif frameData.combatStats and frameData.combatStats.ult1Backdrop then
            frameData.potionCooldown.backdrop:SetAnchor(LEFT, frameData.combatStats.ult1Backdrop, RIGHT, 3, 0)
        else
            frameData.potionCooldown.backdrop:SetAnchor(LEFT, backdrop, RIGHT, 3, 0)
        end
    end

    icon:SetDrawLevel(15)

    -- Apply font to label if showRemainingTime is enabled
    local settings = GetSettings()
    if settings and settings.showRemainingTime then
        local fontSize = 12
        label:SetDrawLayer(DL_OVERLAY)
        label:SetDrawLevel(16)
        local appearance = UnitFrames.GetCustomFrameAppearance("group")
        label:SetFont(LUIE.Font.Resolve(appearance.fontFace, fontSize, appearance.fontStyle))
        frameData.foodDrinkBuff.label = label
    end

    frameData.foodDrinkBuff.backdrop = backdrop
    frameData.foodDrinkBuff.icon = icon
end

-- =====================================================================================================================
-- ICON UPDATE LOGIC
-- =====================================================================================================================

local function HideFoodDrinkBuffIcon(frameData)
    if not frameData.foodDrinkBuff then return end

    frameData.foodDrinkBuff.icon:SetHidden(true)
    frameData.foodDrinkBuff.backdrop:SetHidden(true)
    if frameData.foodDrinkBuff.label then
        frameData.foodDrinkBuff.label:SetHidden(true)
    end
    frameData.foodDrinkBuff.currentAbilityId = nil
    frameData.foodDrinkBuff.currentBuffName = nil
    frameData.foodDrinkBuff.currentBuffSlot = nil
    frameData.foodDrinkBuff.currentTimeEnds = nil
end

local function UpdateRemainingTimeDisplay(frameData, timeEnds)
    if not frameData or not frameData.foodDrinkBuff or not frameData.foodDrinkBuff.label then return end

    local settings = GetSettings()
    if not settings or not settings.showRemainingTime then return end

    if not timeEnds then
        frameData.foodDrinkBuff.label:SetHidden(true)
        frameData.foodDrinkBuff.label:SetText("")
        return
    end

    local currentTime = GetGameTimeMilliseconds()
    local remainingMS = (timeEnds * 1000) - currentTime

    if remainingMS > 0 then
        local seconds = zo_ceil(remainingMS / 1000)
        if seconds >= 3600 then
            local hours = zo_floor(seconds / 3600)
            frameData.foodDrinkBuff.label:SetText(string.format("|cFFFFFF%dh|r", hours))
        elseif seconds >= 60 then
            local minutes = zo_floor(seconds / 60)
            frameData.foodDrinkBuff.label:SetText(string.format("|cFFFFFF%dm|r", minutes))
        else
            frameData.foodDrinkBuff.label:SetText(string.format("|cFFFFFF%ds|r", seconds))
        end
        frameData.foodDrinkBuff.label:SetHidden(false)
    else
        frameData.foodDrinkBuff.label:SetHidden(true)
    end
end

local function ShowFoodDrinkBuffIcon(frameData, texture, abilityId, buffName, buffSlot, timeEnds)
    if not frameData.foodDrinkBuff then return end

    frameData.foodDrinkBuff.icon:SetTexture(texture)
    frameData.foodDrinkBuff.icon:SetHidden(false)
    frameData.foodDrinkBuff.backdrop:SetHidden(false)
    frameData.foodDrinkBuff.currentAbilityId = abilityId
    frameData.foodDrinkBuff.currentBuffName = buffName
    frameData.foodDrinkBuff.currentBuffSlot = buffSlot
    frameData.foodDrinkBuff.currentTimeEnds = timeEnds

    UpdateRemainingTimeDisplay(frameData, timeEnds)
end

local function UpdateFoodDrinkIcon(unitTag, frameData)
    if not frameData or not frameData.foodDrinkBuff then return end
    if not IsModuleEnabled() then return end

    local actualUnitTag = frameData.unitTag
    if not actualUnitTag or not DoesUnitExist(actualUnitTag) then
        HideFoodDrinkBuffIcon(frameData)
        return
    end

    if IsUnitDead(actualUnitTag) or not IsUnitOnline(actualUnitTag) then
        HideFoodDrinkBuffIcon(frameData)
        return
    end

    local buffType, isDrink, abilityId, buffName, timeStarted, timeEnds, iconTexture, timeLeft = GetFoodBuffInfos(actualUnitTag)

    if buffType == BUFF_TYPE_NONE then
        local settings = GetSettings()
        if settings.showNoBuff then
            ShowFoodDrinkBuffIcon(frameData, ICON_NO_BUFF, nil, nil, nil, nil)
        else
            HideFoodDrinkBuffIcon(frameData)
        end
        return
    end

    local buffSlot, actualBuffIcon = FindBuffSlotAndIconByAbilityId(actualUnitTag, abilityId)

    local displayTexture
    local displayName = buffName
    local settings = GetSettings()
    local effectOverride = Effects.EffectOverride and Effects.EffectOverride[abilityId]

    if settings.useCustomIcons then
        displayTexture = GetIconForBuffType(buffType, isDrink)
    else
        if effectOverride and effectOverride.icon then
            displayTexture = effectOverride.icon
        elseif actualBuffIcon and actualBuffIcon ~= "" then
            displayTexture = actualBuffIcon
        else
            displayTexture = iconTexture
        end
    end

    if effectOverride and effectOverride.name then
        displayName = effectOverride.name
    end

    ShowFoodDrinkBuffIcon(frameData, displayTexture, abilityId, displayName, buffSlot, timeEnds)
end

local function UpdateAllFoodDrinkIcons()
    if not IsModuleEnabled() then return end

    Shared.ForEachActiveGroupMember(function (unitTag, frameData, index)
        UpdateFoodDrinkIcon(unitTag, frameData)
    end)
end

-- =====================================================================================================================
-- FRAME MANAGEMENT
-- =====================================================================================================================

local function AddFoodDrinkIconToFrame(frameData, isRaid)
    if not frameData or not frameData.control then return end
    if not IsModuleEnabled() then return end
    if not ShouldShowOnFrame(isRaid) then return end

    CreateFoodDrinkBuffUI(frameData)
end

local function ShowFoodDrinkFrame(frameData)
    if frameData.foodDrinkBuff then
        frameData.foodDrinkBuff.icon:SetHidden(false)
        frameData.foodDrinkBuff.backdrop:SetHidden(false)
    end
end

local function SetupFoodDrinkFrames()
    if not IsModuleEnabled() then return end

    Shared.SetupIntegrationFrames("foodDrinkBuff", AddFoodDrinkIconToFrame, ShowFoodDrinkFrame)
    UpdateAllFoodDrinkIcons()
end

local function HideAllFoodDrinkIcons()
    Shared.ForEachGroupFrame(function (unitTag, frameData, isRaid)
        if frameData.foodDrinkBuff then
            frameData.foodDrinkBuff.icon:SetHidden(true)
            frameData.foodDrinkBuff.backdrop:SetHidden(true)
        end
    end)
end

local function ClearFoodDrinkFrames()
    Shared.ForEachGroupFrame(function (unitTag, frameData, isRaid)
        if frameData.foodDrinkBuff then
            frameData.foodDrinkBuff = nil
        end
    end)
end

-- =====================================================================================================================
-- EVENT HANDLERS
-- =====================================================================================================================

local function OnGroupMemberJoined()
    if not isInitialized then return end
    zo_callLater(SetupFoodDrinkFrames, DELAY_GROUP_JOIN)
end

local function OnGroupMemberLeft()
    if not isInitialized then return end
    zo_callLater(UpdateAllFoodDrinkIcons, DELAY_GROUP_LEFT)
end

local function OnGroupUpdate()
    if not isInitialized then return end
    UpdateAllFoodDrinkIcons()
end

local function OnEffectChanged(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    if not isInitialized then return end
    if not abilityId or not AllFoodDrinkBuffs[abilityId] then return end

    local frameData = Shared.GetFrameData(unitTag)
    if frameData then
        UpdateFoodDrinkIcon(unitTag, frameData)
    end
end

local function OnPlayerActivated()
    if not isInitialized then return end
    zo_callLater(SetupFoodDrinkFrames, DELAY_PLAYER_ACTIVATED)
end

local function OnInventoryItemUsed(eventCode, itemSoundCategory)
    if not isInitialized then return end
    if itemSoundCategory == ITEM_SOUND_CATEGORY_FOOD or itemSoundCategory == ITEM_SOUND_CATEGORY_DRINK then
        zo_callLater(UpdateAllFoodDrinkIcons, DELAY_INVENTORY_UPDATE)
    end
end

local function OnInventorySingleSlotUpdate(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange)
    if not isInitialized then return end
    if itemSoundCategory == ITEM_SOUND_CATEGORY_FOOD or itemSoundCategory == ITEM_SOUND_CATEGORY_DRINK then
        zo_callLater(UpdateAllFoodDrinkIcons, DELAY_INVENTORY_UPDATE)
    end
end

-- =====================================================================================================================
-- SLASH COMMAND
-- =====================================================================================================================

local function OnSlashCommand()
    if not isInitialized then
        LUIE.ChatOutput:Print(GetString(LUIE_STRING_UF_FOODDRINK_NOT_INITIALIZED), true)
        return
    end

    LUIE.ChatOutput:Print(GetString(LUIE_STRING_UF_FOODDRINK_REFRESHING))
    GroupFoodDrinkBuffManager.RefreshFrames()
    zo_callLater(function ()
                     LUIE.ChatOutput:Print(GetString(LUIE_STRING_UF_FOODDRINK_REFRESHED), true)
                 end, 200)
end

-- =====================================================================================================================
-- PUBLIC API
-- =====================================================================================================================

function GroupFoodDrinkBuffManager.Initialize()
    if isInitialized then return end
    if not IsModuleEnabled() then return end

    EVENT_MANAGER:RegisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:RegisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_GROUP_MEMBER_JOINED, OnGroupMemberJoined)
    EVENT_MANAGER:RegisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_GROUP_MEMBER_LEFT, OnGroupMemberLeft)
    EVENT_MANAGER:RegisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_GROUP_UPDATE, OnGroupUpdate)
    EVENT_MANAGER:RegisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    EVENT_MANAGER:RegisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_INVENTORY_ITEM_USED, OnInventoryItemUsed)
    EVENT_MANAGER:RegisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySingleSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_BACKPACK, REGISTER_FILTER_IS_NEW_ITEM, false)

    SLASH_COMMANDS[SLASH_COMMAND] = OnSlashCommand

    local settings = GetSettings()
    if settings and settings.showRemainingTime then
        EVENT_MANAGER:RegisterForUpdate("LUIE_GroupFoodDrinkBuff_Update", 1000, function ()
            if not IsUnitGrouped("player") then return end

            Shared.ForEachActiveGroupMember(function (unitTag, frameData)
                if frameData.foodDrinkBuff and frameData.foodDrinkBuff.currentTimeEnds then
                    UpdateRemainingTimeDisplay(frameData, frameData.foodDrinkBuff.currentTimeEnds)
                end
            end)
        end)
    end

    isInitialized = true

    if IsUnitGrouped("player") then
        zo_callLater(SetupFoodDrinkFrames, DELAY_INITIAL_SETUP)
    end
end

function GroupFoodDrinkBuffManager.Uninitialize()
    if not isInitialized then return end

    EVENT_MANAGER:UnregisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_GROUP_MEMBER_JOINED)
    EVENT_MANAGER:UnregisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_GROUP_MEMBER_LEFT)
    EVENT_MANAGER:UnregisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_GROUP_UPDATE)
    EVENT_MANAGER:UnregisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_INVENTORY_ITEM_USED)
    EVENT_MANAGER:UnregisterForEvent("LUIE_GroupFoodDrinkBuff", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    EVENT_MANAGER:UnregisterForUpdate("LUIE_GroupFoodDrinkBuff_Update")

    SLASH_COMMANDS[SLASH_COMMAND] = nil

    HideAllFoodDrinkIcons()

    isInitialized = false
end

function GroupFoodDrinkBuffManager.OnSettingsChanged()
    if not GetSettings() then return end

    if IsModuleEnabled() then
        if not isInitialized then
            GroupFoodDrinkBuffManager.Initialize()
        else
            SetupFoodDrinkFrames()
        end
    else
        if isInitialized then
            GroupFoodDrinkBuffManager.Uninitialize()
        end
    end
end

function GroupFoodDrinkBuffManager.RefreshFrames()
    if not isInitialized then return end

    ClearFoodDrinkFrames()
    SetupFoodDrinkFrames()
end
