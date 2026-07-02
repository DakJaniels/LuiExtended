-- -----------------------------------------------------------------------------
--  LuiExtended                                                               --
--  Distributed under The MIT License (MIT) (see LICENSE file)                --
-- -----------------------------------------------------------------------------

--- @class (partial) LuiExtended
local LUIE = LUIE

-- SpellCastBuffs namespace
--- @class (partial) LUIE.SpellCastBuffs
local SpellCastBuffs = LUIE.SpellCastBuffs

local LuiData = LuiData
--- @type Data
local Data = LuiData.Data
--- @type Effects
local Effects = Data.Effects
local Abilities = Data.Abilities
local Tooltips = Data.Tooltips
local zo_strformat = zo_strformat
local table_insert = table.insert
-- local displayName = GetDisplayName()
local eventManager = GetEventManager()
local sceneManager = SCENE_MANAGER

local moduleName = SpellCastBuffs.moduleName
local ABILITY_ID_LABEL_FIT_MARGIN = 0.92

--- Full string width in UI units (LabelControl:GetStringWidth is layout-native; compare to GetWidth).
--- @param label LabelControl
--- @param idText string
--- @return number
local function GetAbilityIdStringWidthUI(label, idText)
    label:Clean()
    local widthNative = label:GetStringWidth(idText)
    if not widthNative or widthNative <= 0 then
        return 0
    end
    return widthNative / GetUIGlobalScale()
end
local g_scbDisplayAlpha -- Last alpha for buff containers (HUD fade can reset to 1 on reload)



--- @param abilityId integer
--- @return boolean
function SpellCastBuffs.ShouldUseDefaultIcon(abilityId)
    local effect = Effects.EffectOverride[abilityId]

    -- Check if effect exists and has either cc or ccMergedType (with HideReduce enabled)
    if not effect or (not effect.cc and not (SpellCastBuffs.SV.HideReduce and effect.ccMergedType)) then
        return false
    end

    -- Option 1: Always use default icon for all cc effects
    if SpellCastBuffs.SV.DefaultIconOptions == 1 then
        return true

        -- Options 2 and 3: Use default icon only for player ability cc effects
    elseif SpellCastBuffs.SV.DefaultIconOptions == 2 or SpellCastBuffs.SV.DefaultIconOptions == 3 then
        return effect.isPlayerAbility
    end

    return false
end

function SpellCastBuffs.GetDefaultIcon(ccType)
    -- Mapping of action results to icons.
    local iconMap =
    {
        [ACTION_RESULT_STUNNED] = LUIE_CC_ICON_STUN,
        [ACTION_RESULT_KNOCKBACK] = LUIE_CC_ICON_KNOCKBACK,
        [ACTION_RESULT_LEVITATED] = LUIE_CC_ICON_PULL,
        [ACTION_RESULT_FEARED] = LUIE_CC_ICON_FEAR,
        [ACTION_RESULT_CHARMED] = LUIE_CC_ICON_CHARM,
        [ACTION_RESULT_DISORIENTED] = LUIE_CC_ICON_DISORIENT,
        [ACTION_RESULT_SILENCED] = LUIE_CC_ICON_SILENCE,
        [ACTION_RESULT_ROOTED] = LUIE_CC_ICON_ROOT,
        [ACTION_RESULT_SNARED] = LUIE_CC_ICON_SNARE,
        -- Group immune-type results
        [ACTION_RESULT_IMMUNE] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_DODGED] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_BLOCKED] = LUIE_CC_ICON_IMMUNE,
        [ACTION_RESULT_BLOCKED_DAMAGE] = LUIE_CC_ICON_IMMUNE,
    }

    return iconMap[ccType]
end

-- Specifically for clearing a player buff, removes this buff from player1, promd_player, and promb_player containers
function SpellCastBuffs.ClearPlayerBuff(abilityId)
    local context = { "player1", "promd_player", "promb_player" }
    local removedAny = false
    for _, v in pairs(context) do
        local effectsList = SpellCastBuffs.EffectsList[v]
        if effectsList and effectsList[abilityId] then
            effectsList[abilityId] = nil
            removedAny = true
        end
        if SpellCastBuffs.ClearFakeEffectEntry(v, abilityId) then
            removedAny = true
        end
    end
    if removedAny then
        SpellCastBuffs.MarkDisplayDirty()
    end
end

-- Initialize preview labels for all frames
local function InitializePreviewLabels()
    -- Callback to update coordinates while moving
    local function OnMoveStart(self)
        eventManager:RegisterForUpdate(moduleName .. "PreviewMove", 200, function ()
            if self.preview and self.preview.anchorLabel then
                self.preview.anchorLabel:SetText(string.format("%d, %d", self:GetLeft(), self:GetTop()))
            end
        end)
    end

    -- Callback to stop updating coordinates when movement ends
    local function OnMoveStop(self)
        eventManager:UnregisterForUpdate(moduleName .. "PreviewMove")
    end

    local frames =
    {
        { frame = SpellCastBuffs.BuffContainers.playerb,          name = "playerb"          },
        { frame = SpellCastBuffs.BuffContainers.playerd,          name = "playerd"          },
        { frame = SpellCastBuffs.BuffContainers.targetb,          name = "targetb"          },
        { frame = SpellCastBuffs.BuffContainers.targetd,          name = "targetd"          },
        { frame = SpellCastBuffs.BuffContainers.player_long,      name = "player_long"      },
        { frame = SpellCastBuffs.BuffContainers.prominentbuffs,   name = "prominentbuffs"   },
        { frame = SpellCastBuffs.BuffContainers.prominentdebuffs, name = "prominentdebuffs" }
    }

    for _, f in ipairs(frames) do
        if f.frame then
            if not f.frame.preview then
                f.frame.preview = f.frame:GetNamedChild("_Preview")
            end
            local preview = f.frame.preview
            if preview then
                if not preview.anchorTexture then
                    preview.anchorTexture = preview:CreateControl("$(parent)AnchorTexture", CT_TEXTURE)
                    preview.anchorTexture:SetAnchor(TOPLEFT, preview, TOPLEFT)
                    preview.anchorTexture:SetDimensions(16, 16)
                    preview.anchorTexture:SetTexture("/esoui/art/reticle/border_topleft.dds")
                    preview.anchorTexture:SetDrawLayer(DL_OVERLAY)
                    preview.anchorTexture:SetColor(1, 1, 0, 0.9)
                end

                if not preview.anchorLabel then
                    preview.anchorLabel = preview:CreateControl("$(parent)AnchorLabel", CT_LABEL)
                    preview.anchorLabel:SetFont(LUIE.GetPositionLabelFont())
                    preview.anchorLabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
                    preview.anchorLabel:SetVerticalAlignment(TEXT_ALIGN_TOP)
                    preview.anchorLabel:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
                    preview.anchorLabel:SetAnchor(BOTTOMLEFT, preview, TOPLEFT, 0, -1)
                    preview.anchorLabel:SetText("xxx, yyy")
                    preview.anchorLabel:SetColor(1, 1, 0, 1)
                    preview.anchorLabel:SetDrawLayer(DL_OVERLAY)
                    preview.anchorLabel:SetDrawTier(DT_MEDIUM)
                    preview.anchorLabelBg = preview.anchorLabel:CreateControl("$(parent)Bg", CT_BACKDROP)
                    preview.anchorLabelBg:SetCenterColor(0, 0, 0, 1)
                    preview.anchorLabelBg:SetEdgeColor(0, 0, 0, 1)
                    preview.anchorLabelBg:SetEdgeTexture("", 8, 1, 1, 1)
                    preview.anchorLabelBg:SetDrawLayer(DL_BACKGROUND)
                    preview.anchorLabelBg:SetAnchorFill(preview.anchorLabel)
                    preview.anchorLabelBg:SetDrawLayer(DL_OVERLAY)
                    preview.anchorLabelBg:SetDrawTier(DT_LOW)
                else
                    LUIE.ApplyPositionLabelFont(preview.anchorLabel)
                end
            end

            f.frame:SetHandler("OnMoveStart", OnMoveStart)
            f.frame:SetHandler("OnMoveStop", OnMoveStop)
        end
    end
end

-- Flex container classification tables — defined here so Initialize can reference them.
-- WRAP_CONTAINERS: multi-row containers whose iconHolder uses FLEX_WRAP_WRAP / WRAP_REVERSE.
-- SINGLE_AXIS_CONTAINERS: single-line containers that never wrap.
local WRAP_CONTAINERS =
{
    playerb = true,
    playerd = true,
    targetb = true,
    targetd = true,
    player1 = true,
    player2 = true,
    target1 = true,
    target2 = true,
}
local SINGLE_AXIS_CONTAINERS =
{
    player_long = true, prominentbuffs = true, prominentdebuffs = true,
}

-- Returns creation-time width for a container: parent width > SV width > fallback.
local function GetContainerInitWidth(containerKey)
    local buffContainer = SpellCastBuffs.BuffContainers[containerKey]
    local parentWidth = buffContainer and buffContainer:GetWidth()
    if parentWidth and parentWidth > 0 then
        return parentWidth
    end
    if containerKey == "playerb" then return SpellCastBuffs.SV.WidthPlayerBuffs end
    if containerKey == "playerd" then return SpellCastBuffs.SV.WidthPlayerDebuffs end
    if containerKey == "targetb" then return SpellCastBuffs.SV.WidthTargetBuffs end
    if containerKey == "targetd" then return SpellCastBuffs.SV.WidthTargetDebuffs end
    return 400
end

-- Returns the appropriate FLEX_WRAP_* constant for a given container
local function GetFlexWrap(containerKey)
    if SINGLE_AXIS_CONTAINERS[containerKey] then
        return FLEX_WRAP_NO_WRAP
    end
    if containerKey == "player1" or containerKey == "target1" then
        return FLEX_WRAP_WRAP
    end
    if containerKey == "player2" or containerKey == "target2" then
        return FLEX_WRAP_WRAP_REVERSE
    end
    local stackSV =
    {
        playerb = SpellCastBuffs.SV.StackPlayerBuffs,
        playerd = SpellCastBuffs.SV.StackPlayerDebuffs,
        targetb = SpellCastBuffs.SV.StackTargetBuffs,
        targetd = SpellCastBuffs.SV.StackTargetDebuffs,
    }
    return (stackSV[containerKey] == "Down") and FLEX_WRAP_WRAP or FLEX_WRAP_WRAP_REVERSE
end

-- Maps the SV alignment string + the resolved flex direction to a FLEX_JUSTIFICATION_* constant.
local function GetFlexJustification(containerKey, flexDir)
    local dir = SpellCastBuffs.alignmentDirection[containerKey]

    if dir == "Centered" then
        return FLEX_JUSTIFICATION_CENTER
    end

    local wantsPhysicalEnd = (dir == "Right" or dir == "Bottom")
    local isReversed = (flexDir == FLEX_DIRECTION_ROW_REVERSE or flexDir == FLEX_DIRECTION_COLUMN_REVERSE)
    if isReversed then wantsPhysicalEnd = not wantsPhysicalEnd end

    return wantsPhysicalEnd and FLEX_JUSTIFICATION_FLEX_END or FLEX_JUSTIFICATION_FLEX_START
end

--- @param containerKey string
local function ApplyFlexContainerConfig(containerKey)
    local bc = SpellCastBuffs.BuffContainers[containerKey]
    if not bc or not bc.iconHolder then return end

    local sortDir = SpellCastBuffs.sortDirection[containerKey]
    local flexDir
    if     sortDir == "Left to Right" then
        flexDir = FLEX_DIRECTION_ROW
    elseif sortDir == "Right to Left" then
        flexDir = FLEX_DIRECTION_ROW_REVERSE
    elseif sortDir == "Bottom to Top" then
        flexDir = FLEX_DIRECTION_COLUMN_REVERSE
    elseif sortDir == "Top to Bottom" then
        flexDir = FLEX_DIRECTION_COLUMN
    end

    local resolvedFlexDir = flexDir or bc.iconHolder:GetChildFlexDirection()

    if flexDir then bc.iconHolder:SetChildFlexDirection(flexDir) end
    bc.iconHolder:SetChildFlexWrap(GetFlexWrap(containerKey))
    bc.iconHolder:SetChildFlexJustification(GetFlexJustification(containerKey, resolvedFlexDir))
    bc.iconHolder:SetChildFlexContentAlignment(FLEX_ALIGNMENT_FLEX_START)
end

-- Creates a TopLevel, stores it in BuffContainers[containerKey], and sets OnMoveStop to saveCallback(self).
local function CreateDraggableTopLevel(containerKey, saveCallback)
    local tlw = CreateControlFromVirtual("LUIE_SCB_" .. containerKey, GuiRoot, "LUIE_SCB_Tlw_Template")
    SpellCastBuffs.BuffContainers[containerKey] = tlw
    tlw:SetHandler("OnMoveStop", saveCallback)
    return tlw
end

-- Creates a HUD fade fragment for a container and appends it to the given fragments table.
local function AddHudFragment(fragmentsTable, buffContainer)
    table_insert(fragmentsTable, ZO_HUDFadeSceneFragment:New(buffContainer, 0, 0))
end

-- Adds all fragments to the relevant HUD/siege scenes.
local function RegisterFragmentsToScenes(fragmentsTable)
    for _, fragment in pairs(fragmentsTable) do
        sceneManager:GetScene("hud"):AddFragment(fragment)
        sceneManager:GetScene("hudui"):AddFragment(fragment)
        sceneManager:GetScene("siegeBar"):AddFragment(fragment)
        sceneManager:GetScene("siegeBarUI"):AddFragment(fragment)
    end
end

-- Sets buffContainer.alignVertical from SV-style alignment value (1 = horizontal/false, 2 = vertical/true).
local function SetContainerAlignVertical(buffContainer, alignmentSVValue)
    if alignmentSVValue == 1 then
        buffContainer.alignVertical = false
    elseif alignmentSVValue == 2 then
        buffContainer.alignVertical = true
    end
end

--- @param buffContainer Control
local function WireEffectsRegionNamedChildren(buffContainer)
    if not buffContainer.preview then
        buffContainer.preview = buffContainer:GetNamedChild("_Preview")
    end
    if buffContainer.preview and not buffContainer.previewLabel then
        buffContainer.previewLabel = buffContainer.preview:GetNamedChild("_Label")
    end
    if not buffContainer.iconHolder then
        buffContainer.iconHolder = buffContainer:GetNamedChild("_IconHolder")
    end
end

--- @param holder Control
--- @param direction integer|nil
--- @param wrap integer|nil
local function SetupIconHolderFlexLayout(holder, direction, wrap)
    holder:SetChildLayout(CHILD_LAYOUT_TYPE_FLEX)
    if direction then
        holder:SetChildFlexDirection(direction)
    end
    if wrap then
        holder:SetChildFlexWrap(wrap)
    end
    holder:SetChildFlexJustification(FLEX_JUSTIFICATION_FLEX_START)
    holder:SetChildFlexItemAlignment(FLEX_ALIGNMENT_FLEX_START)
    holder:SetChildFlexContentAlignment(FLEX_ALIGNMENT_FLEX_START)
end

-- Creates preview texture/label and iconHolder for a single container; sets draw layer/tier/level and icons table.
local function InitializeContainerLayout(containerKey)
    local buffContainer = SpellCastBuffs.BuffContainers[containerKey]
    buffContainer:SetDrawLayer(DL_BACKGROUND)
    buffContainer:SetDrawTier(DT_LOW)
    buffContainer:SetDrawLevel(DL_CONTROLS)

    WireEffectsRegionNamedChildren(buffContainer)

    local lockedSuffix = (SpellCastBuffs.SV.lockPositionToUnitFrames and (containerKey ~= "player_long" and containerKey ~= "prominentbuffs" and containerKey ~= "prominentdebuffs") and " (locked)" or "")
    if buffContainer.previewLabel then
        buffContainer.previewLabel:SetText(SpellCastBuffs.windowTitles[containerKey] .. lockedSuffix)
        LUIE.ApplyFramePreviewLabelFont(buffContainer.previewLabel)
    end

    local isWrapContainer = WRAP_CONTAINERS[containerKey] == true
    local initialFlexDirection = buffContainer.alignVertical and FLEX_DIRECTION_COLUMN or FLEX_DIRECTION_ROW
    local flexWrapMode = isWrapContainer and FLEX_WRAP_WRAP or FLEX_WRAP_NO_WRAP
    local iconSize = SpellCastBuffs.SV.IconSize
    local initialWidth = GetContainerInitWidth(containerKey)
    local initialHeight = isWrapContainer and (iconSize * 10) or (iconSize + 6)

    if buffContainer.iconHolder then
        buffContainer.iconHolder:SetDimensions(initialWidth, initialHeight)
        SetupIconHolderFlexLayout(buffContainer.iconHolder, initialFlexDirection, flexWrapMode)
    end

    if not buffContainer.icons then
        buffContainer.icons = {}
    end
    if buffContainer:GetType() == CT_TOPLEVELCONTROL then
        LUIE.Components[moduleName .. containerKey] = buffContainer
    end

    ApplyFlexContainerConfig(containerKey)
end

function SpellCastBuffs.RefreshDevDebugEnabled()
    SpellCastBuffs.devDebugEnabled = LUIE.IsDevDebugEnabled()
end

-- Initialization
function SpellCastBuffs.Initialize(enabled)
    -- Load settings
    local isCharacterSpecific = LUIE.IsCharacterSpecificSavedVarsEnabled()
    if isCharacterSpecific then
        SpellCastBuffs.SV = ZO_SavedVars:New(LUIE.ModuleSavedVarNames.SpellCastBuffs, LUIE.SVVer, nil, SpellCastBuffs.Defaults, LUIE.SavedVarsProfile)
    else
        SpellCastBuffs.SV = ZO_SavedVars:NewAccountWide(LUIE.ModuleSavedVarNames.SpellCastBuffs, LUIE.SVVer, nil, SpellCastBuffs.Defaults, LUIE.SavedVarsProfile)
    end

    -- Migrate old string-based font styles to numeric constants (run once)
    -- Migrate font styles (string/display/nil -> valid 0-7); run once per account
    if not LUIE.IsMigrationDone("spellcastbuffs_fontstyles_v2") then
        SpellCastBuffs.SV.BuffFontStyle = LUIE.MigrateFontStyle(SpellCastBuffs.SV.BuffFontStyle)
        SpellCastBuffs.SV.ProminentLabelFontStyle = LUIE.MigrateFontStyle(SpellCastBuffs.SV.ProminentLabelFontStyle)
        LUIE.MarkMigrationDone("spellcastbuffs_fontstyles_v2")
    end

    -- Correct read values
    if SpellCastBuffs.SV.IconSize < 30 or SpellCastBuffs.SV.IconSize > 60 then
        SpellCastBuffs.SV.IconSize = SpellCastBuffs.Defaults.IconSize
    end

    SpellCastBuffs.RefreshDevDebugEnabled()

    -- Disable module if setting not toggled on
    if not enabled then
        return
    end
    SpellCastBuffs.Enabled = true

    if SpellCastBuffs.SV.oocAlpha == nil then
        SpellCastBuffs.SV.oocAlpha = SpellCastBuffs.Defaults.oocAlpha
    end
    if SpellCastBuffs.SV.incAlpha == nil then
        SpellCastBuffs.SV.incAlpha = SpellCastBuffs.Defaults.incAlpha
    end

    -- Before we start creating controls, update icons font
    SpellCastBuffs.ApplyFont()

    SpellCastBuffs.InitializeBuffIconPools()

    -- Create controls
    -- Create temporary table to store references to scenes locally
    local fragments = {}

    -- We will not create TopLevelWindows when buff frames are locked to Custom Unit Frames
    if SpellCastBuffs.SV.lockPositionToUnitFrames and LUIE.UnitFrames.CustomFrames.player and LUIE.UnitFrames.CustomFrames.player.buffs and LUIE.UnitFrames.CustomFrames.player.debuffs then
        SpellCastBuffs.BuffContainers.player1 = LUIE.UnitFrames.CustomFrames.player.buffs
        SpellCastBuffs.BuffContainers.player2 = LUIE.UnitFrames.CustomFrames.player.debuffs
        SpellCastBuffs.containerRouting.player1 = "player1"
        SpellCastBuffs.containerRouting.player2 = "player2"
    else
        CreateDraggableTopLevel("playerb", function (self)
            SpellCastBuffs.SV.playerbOffsetX = self:GetLeft()
            SpellCastBuffs.SV.playerbOffsetY = self:GetTop()
        end)
        CreateDraggableTopLevel("playerd", function (self)
            SpellCastBuffs.SV.playerdOffsetX = self:GetLeft()
            SpellCastBuffs.SV.playerdOffsetY = self:GetTop()
        end)
        SpellCastBuffs.containerRouting.player1 = "playerb"
        SpellCastBuffs.containerRouting.player2 = "playerd"

        AddHudFragment(fragments, SpellCastBuffs.BuffContainers.playerb)
        AddHudFragment(fragments, SpellCastBuffs.BuffContainers.playerd)
    end

    -- Create TopLevelWindows for buff frames when NOT locked to Custom Unit Frames
    if SpellCastBuffs.SV.lockPositionToUnitFrames and LUIE.UnitFrames.CustomFrames.reticleover and LUIE.UnitFrames.CustomFrames.reticleover.buffs and LUIE.UnitFrames.CustomFrames.reticleover.debuffs then
        SpellCastBuffs.BuffContainers.target1 = LUIE.UnitFrames.CustomFrames.reticleover.buffs
        SpellCastBuffs.BuffContainers.target2 = LUIE.UnitFrames.CustomFrames.reticleover.debuffs
        SpellCastBuffs.containerRouting.reticleover1 = "target1"
        SpellCastBuffs.containerRouting.reticleover2 = "target2"
        SpellCastBuffs.containerRouting.ground = "target2"
    else
        CreateDraggableTopLevel("targetb", function (self)
            SpellCastBuffs.SV.targetbOffsetX = self:GetLeft()
            SpellCastBuffs.SV.targetbOffsetY = self:GetTop()
        end)
        CreateDraggableTopLevel("targetd", function (self)
            SpellCastBuffs.SV.targetdOffsetX = self:GetLeft()
            SpellCastBuffs.SV.targetdOffsetY = self:GetTop()
        end)
        SpellCastBuffs.containerRouting.reticleover1 = "targetb"
        SpellCastBuffs.containerRouting.reticleover2 = "targetd"
        SpellCastBuffs.containerRouting.ground = "targetd"

        AddHudFragment(fragments, SpellCastBuffs.BuffContainers.targetb)
        AddHudFragment(fragments, SpellCastBuffs.BuffContainers.targetd)
    end

    -- Create TopLevelWindows for Prominent Buffs
    CreateDraggableTopLevel("prominentbuffs", function (self)
        if self.alignVertical then
            SpellCastBuffs.SV.prominentbVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentbVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.prominentbHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentbHOffsetY = self:GetTop()
        end
    end)
    CreateDraggableTopLevel("prominentdebuffs", function (self)
        if self.alignVertical then
            SpellCastBuffs.SV.prominentdVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentdVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.prominentdHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentdHOffsetY = self:GetTop()
        end
    end)

    SetContainerAlignVertical(SpellCastBuffs.BuffContainers.prominentbuffs, SpellCastBuffs.SV.ProminentBuffContainerAlignment)
    SetContainerAlignVertical(SpellCastBuffs.BuffContainers.prominentdebuffs, SpellCastBuffs.SV.ProminentDebuffContainerAlignment)

    SpellCastBuffs.containerRouting.promb_ground = "prominentbuffs"
    SpellCastBuffs.containerRouting.promb_target = "prominentbuffs"
    SpellCastBuffs.containerRouting.promb_player = "prominentbuffs"
    SpellCastBuffs.containerRouting.promd_ground = "prominentdebuffs"
    SpellCastBuffs.containerRouting.promd_target = "prominentdebuffs"
    SpellCastBuffs.containerRouting.promd_player = "prominentdebuffs"

    AddHudFragment(fragments, SpellCastBuffs.BuffContainers.prominentbuffs)
    AddHudFragment(fragments, SpellCastBuffs.BuffContainers.prominentdebuffs)

    -- Separate container for players long term buffs
    CreateDraggableTopLevel("player_long", function (self)
        SpellCastBuffs.SV.player_longOffsetX = self:GetLeft()
        SpellCastBuffs.SV.player_longOffsetY = self:GetTop()
    end)

    SetContainerAlignVertical(SpellCastBuffs.BuffContainers.player_long, SpellCastBuffs.SV.LongTermEffectsSeparateAlignment)

    SpellCastBuffs.BuffContainers.player_long.skipUpdate = 0
    SpellCastBuffs.containerRouting.player_long = "player_long"

    AddHudFragment(fragments, SpellCastBuffs.BuffContainers.player_long)

    -- Loop over table of fragments to add them to relevant UI Scenes
    RegisterFragmentsToScenes(fragments)
    SpellCastBuffs.BuffFragments = fragments

    -- Set Buff Container Positions
    SpellCastBuffs.SetTlwPosition()

    -- Initialize layout (draw layer, preview, iconHolder, icons) for each container
    for _, routedContainerKey in pairs(SpellCastBuffs.containerRouting) do
        InitializeContainerLayout(routedContainerKey)
    end

    SpellCastBuffs.Reset()
    SpellCastBuffs.UpdateContextHideList()
    SpellCastBuffs.UpdateDisplayOverrideIdList()
    SpellCastBuffs.BuildOffBalanceDebuffLookup()

    -- Register events
    eventManager:RegisterForUpdate(moduleName, 100, SpellCastBuffs.OnUpdate)

    -- Target Events
    eventManager:RegisterForEvent(moduleName, EVENT_TARGET_CHANGED, SpellCastBuffs.OnTargetChange)
    eventManager:RegisterForEvent(moduleName, EVENT_RETICLE_TARGET_CHANGED, SpellCastBuffs.OnReticleTargetChanged)
    eventManager:RegisterForEvent(moduleName .. "Disposition", EVENT_DISPOSITION_UPDATE, SpellCastBuffs.OnDispositionUpdate)
    eventManager:AddFilterForEvent(moduleName .. "Disposition", EVENT_DISPOSITION_UPDATE, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Buff Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED, function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        SpellCastBuffs.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    end)
    eventManager:RegisterForEvent(moduleName .. "Target", EVENT_EFFECT_CHANGED, function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        SpellCastBuffs.OnEffectChanged(changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
    end)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Target", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- GROUND & MINE EFFECTS - add a filtered event for each AbilityId
    for k, v in pairs(Effects.EffectGroundDisplay) do
        eventManager:RegisterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, SpellCastBuffs.OnEffectChangedGround)
        eventManager:AddFilterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, k)
    end
    for k, v in pairs(Effects.LinkedGroundMine) do
        eventManager:RegisterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, SpellCastBuffs.OnEffectChangedGround)
        eventManager:AddFilterForEvent(moduleName .. "Ground" .. tostring(k), EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_ABILITY_ID, k)
    end

    -- Combat Events
    eventManager:RegisterForEvent(moduleName .. "Event1", EVENT_COMBAT_EVENT, SpellCastBuffs.OnCombatEventIn)
    eventManager:RegisterForEvent(moduleName .. "Event2", EVENT_COMBAT_EVENT, SpellCastBuffs.OnCombatEventOut)
    eventManager:RegisterForEvent(moduleName .. "Event3", EVENT_COMBAT_EVENT, SpellCastBuffs.OnCombatEventOut)
    eventManager:AddFilterForEvent(moduleName .. "Event1", EVENT_COMBAT_EVENT, REGISTER_FILTER_TARGET_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)     -- Target -> Player
    eventManager:AddFilterForEvent(moduleName .. "Event2", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER, REGISTER_FILTER_IS_ERROR, false)     -- Player -> Target
    eventManager:AddFilterForEvent(moduleName .. "Event3", EVENT_COMBAT_EVENT, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER_PET, REGISTER_FILTER_IS_ERROR, false) -- Player Pet -> Target
    for k, v in pairs(Effects.AddNameOnEvent) do
        eventManager:RegisterForEvent(moduleName .. "Event4" .. tostring(k), EVENT_COMBAT_EVENT, SpellCastBuffs.OnCombatAddNameEvent)
        eventManager:AddFilterForEvent(moduleName .. "Event4" .. tostring(k), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end
    eventManager:RegisterForEvent(moduleName, EVENT_BOSSES_CHANGED, SpellCastBuffs.AddNameOnBossEngaged)

    -- Stealth Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_STEALTH_STATE_CHANGED, function (eventId, unitTag, stealthState)
        SpellCastBuffs.StealthStateChanged(unitTag, stealthState)
    end)
    eventManager:RegisterForEvent(moduleName .. "Reticleover", EVENT_STEALTH_STATE_CHANGED, function (eventId, unitTag, stealthState)
        SpellCastBuffs.StealthStateChanged(unitTag, stealthState)
    end)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Reticleover", EVENT_STEALTH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Disguise Events
    eventManager:RegisterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, function (eventId, unitTag, disguiseState)
        SpellCastBuffs.DisguiseStateChanged(unitTag, disguiseState)
    end)
    eventManager:RegisterForEvent(moduleName .. "Reticleover", EVENT_DISGUISE_STATE_CHANGED, function (eventId, unitTag, disguiseState)
        SpellCastBuffs.DisguiseStateChanged(unitTag, disguiseState)
    end)
    eventManager:AddFilterForEvent(moduleName .. "Player", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "player")
    eventManager:AddFilterForEvent(moduleName .. "Reticleover", EVENT_DISGUISE_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG, "reticleover")

    -- Artificial Effects Handling
    eventManager:RegisterForEvent(moduleName, EVENT_ARTIFICIAL_EFFECT_ADDED, function (eventId, artificialEffectId)
        SpellCastBuffs.ArtificialEffectUpdate(artificialEffectId)
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_ARTIFICIAL_EFFECT_REMOVED, function (eventId, artificialEffectId)
        SpellCastBuffs.ArtificialEffectUpdate(artificialEffectId)
    end)

    -- Activate/Deactivate Player, Player Dead/Alive, Vibration, and Unit Death
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ACTIVATED, SpellCastBuffs.OnPlayerActivated)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_DEACTIVATED, SpellCastBuffs.OnPlayerDeactivated)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_ALIVE, SpellCastBuffs.OnPlayerAlive)
    eventManager:RegisterForEvent(moduleName, EVENT_PLAYER_DEAD, SpellCastBuffs.OnPlayerDead)
    eventManager:RegisterForEvent(moduleName, EVENT_VIBRATION, SpellCastBuffs.OnVibration)
    eventManager:RegisterForEvent(moduleName, EVENT_UNIT_DEATH_STATE_CHANGED, SpellCastBuffs.OnDeath)

    -- Mount Events
    eventManager:RegisterForEvent(moduleName, EVENT_MOUNTED_STATE_CHANGED, function (_, mounted)
        SpellCastBuffs.MountStatus(mounted)
    end)
    eventManager:RegisterForEvent(moduleName, EVENT_COLLECTIBLE_USE_RESULT, SpellCastBuffs.CollectibleUsed)

    -- Inventory Events
    eventManager:RegisterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function (eventId, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason, stackCountChange, triggeredByCharacterName, triggeredByDisplayName, isLastUpdateForMessage, bonusDropSource)
        SpellCastBuffs.DisguiseItem(bagId, slotIndex)
    end)
    eventManager:AddFilterForEvent(moduleName, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN)

    -- Duel (For resolving Target Battle Spirit Status)
    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_STARTED, SpellCastBuffs.DuelStart)
    eventManager:RegisterForEvent(moduleName, EVENT_DUEL_FINISHED, SpellCastBuffs.DuelEnd)

    -- Register event to update icons/names/tooltips for some abilities where we pull information from the currently learned morph
    eventManager:RegisterForEvent(moduleName, EVENT_SKILLS_FULL_UPDATE, function (eventId)
        -- Mages Guild
        Effects.EffectOverride[40465].tooltip = zo_strformat(GetString(LUIE_STRING_SKILL_SCALDING_RUNE_TP), ((GetAbilityDuration(40468) or 0) / 1000) + GetNumPassiveSkillRanks(GetSkillLineIndicesFromSkillLineId(44), select(2, GetSkillLineIndicesFromSkillLineId(44)), 8))
    end)

    -- Werewolf
    SpellCastBuffs.RegisterWerewolfEvents()

    -- Debug
    SpellCastBuffs.RegisterDebugEvents()

    -- Variable adjustment if needed
    local coreAw = LUIE.GetCoreAccountWideRawTable()
    if not coreAw.AdjustVarsSCB then
        coreAw.AdjustVarsSCB = 0
    end
    if coreAw.AdjustVarsSCB < 2 then
        -- Set buff cc type colors
        SpellCastBuffs.SV.colors.buff = SpellCastBuffs.Defaults.colors.buff
        SpellCastBuffs.SV.colors.debuff = SpellCastBuffs.Defaults.colors.debuff
        SpellCastBuffs.SV.colors.prioritybuff = SpellCastBuffs.Defaults.colors.prioritybuff
        SpellCastBuffs.SV.colors.prioritydebuff = SpellCastBuffs.Defaults.colors.prioritydebuff
        SpellCastBuffs.SV.colors.unbreakable = SpellCastBuffs.Defaults.colors.unbreakable
        SpellCastBuffs.SV.colors.cosmetic = SpellCastBuffs.Defaults.colors.cosmetic
        SpellCastBuffs.SV.colors.nocc = SpellCastBuffs.Defaults.colors.nocc
        SpellCastBuffs.SV.colors.stun = SpellCastBuffs.Defaults.colors.stun
        SpellCastBuffs.SV.colors.knockback = SpellCastBuffs.Defaults.colors.knockback
        SpellCastBuffs.SV.colors.levitate = SpellCastBuffs.Defaults.colors.levitate
        SpellCastBuffs.SV.colors.disorient = SpellCastBuffs.Defaults.colors.disorient
        SpellCastBuffs.SV.colors.fear = SpellCastBuffs.Defaults.colors.fear
        SpellCastBuffs.SV.colors.charm = SpellCastBuffs.Defaults.colors.charm
        SpellCastBuffs.SV.colors.silence = SpellCastBuffs.Defaults.colors.silence
        SpellCastBuffs.SV.colors.stagger = SpellCastBuffs.Defaults.colors.stagger
        SpellCastBuffs.SV.colors.snare = SpellCastBuffs.Defaults.colors.snare
        SpellCastBuffs.SV.colors.root = SpellCastBuffs.Defaults.colors.root
    end
    -- New feature defaults (do not bump AdjustVarsSCB): ensure new keys exist without migrating prior data.
    if SpellCastBuffs.SV.DamageTypeFallback == nil then
        SpellCastBuffs.SV.DamageTypeFallback = SpellCastBuffs.Defaults.DamageTypeFallback
    end
    if SpellCastBuffs.SV.colors.damage == nil then
        SpellCastBuffs.SV.colors.damage = SpellCastBuffs.Defaults.colors.damage
    end
    if SpellCastBuffs.SV.colors.charm == nil then
        SpellCastBuffs.SV.colors.charm = SpellCastBuffs.Defaults.colors.charm
    end
    -- Increment so this doesn't occur again.
    coreAw.AdjustVarsSCB = 2

    -- Initialize preview labels for all frames
    InitializePreviewLabels()
    LUIE.RefreshMoverOverlayFonts()

    eventManager:UnregisterForEvent(moduleName .. "CombatState", EVENT_PLAYER_COMBAT_STATE)
    eventManager:RegisterForEvent(moduleName .. "CombatState", EVENT_PLAYER_COMBAT_STATE, function ()
        SpellCastBuffs.ApplyDisplayAlpha()
    end)

    SpellCastBuffs.ApplyDisplayAlpha()
    if SpellCastBuffs.SV.lockPositionToUnitFrames and LUIE.UnitFrames and LUIE.UnitFrames.CustomFramesApplyInCombat then
        LUIE.UnitFrames.CustomFramesApplyInCombat(true)
    end
    -- HUD fade fragments can force alpha to 1 after init; /reloadui does not fire PLAYER_ACTIVATED
    zo_callLater(function ()
                     if SpellCastBuffs.Enabled then
                         SpellCastBuffs.ApplyDisplayAlpha()
                         if SpellCastBuffs.SV.lockPositionToUnitFrames and LUIE.UnitFrames and LUIE.UnitFrames.CustomFramesApplyInCombat then
                             LUIE.UnitFrames.CustomFramesApplyInCombat(true)
                         end
                     end
                 end, 0)
    zo_callLater(function ()
                     if SpellCastBuffs.Enabled then
                         SpellCastBuffs.ApplyDisplayAlpha()
                         if SpellCastBuffs.SV.lockPositionToUnitFrames and LUIE.UnitFrames and LUIE.UnitFrames.CustomFramesApplyInCombat then
                             LUIE.UnitFrames.CustomFramesApplyInCombat(true)
                         end
                     end
                 end, 300)

    SpellCastBuffs.MarkDisplayDirty()
    SpellCastBuffs.ScheduleAbilityIdDebugLabelRefresh()
end

function SpellCastBuffs.RegisterWerewolfEvents()
    eventManager:UnregisterForEvent(moduleName, EVENT_POWER_UPDATE)
    eventManager:UnregisterForUpdate(moduleName .. "WerewolfTicker")
    eventManager:UnregisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED)
    if SpellCastBuffs.SV.ShowWerewolf then
        eventManager:RegisterForEvent(moduleName, EVENT_WEREWOLF_STATE_CHANGED, SpellCastBuffs.WerewolfState)
        if IsPlayerInWerewolfForm() then
            SpellCastBuffs.WerewolfState(nil, true, true)
        end
    end
end

function SpellCastBuffs.RegisterDebugEvents()
    -- Unregister existing events
    eventManager:UnregisterForEvent(moduleName .. "DebugCombat", EVENT_COMBAT_EVENT)
    -- Register standard debug events if enabled
    if SpellCastBuffs.SV.ShowDebugCombat then
        eventManager:RegisterForEvent(moduleName .. "DebugCombat", EVENT_COMBAT_EVENT, function (eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
            SpellCastBuffs.EventCombatDebug(eventId, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
        end)
    end
    eventManager:UnregisterForEvent(moduleName .. "DebugEffect", EVENT_EFFECT_CHANGED)
    if SpellCastBuffs.SV.ShowDebugEffect then
        eventManager:RegisterForEvent(moduleName .. "DebugEffect", EVENT_EFFECT_CHANGED, function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            SpellCastBuffs.EventEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
        end)
    end

    -- Author-specific debug events
    if SpellCastBuffs.devDebugEnabled then
        eventManager:UnregisterForEvent(moduleName .. "AuthorDebugCombat", EVENT_COMBAT_EVENT)
        if SpellCastBuffs.SV.ShowDebugCombat then
            eventManager:RegisterForEvent(moduleName .. "AuthorDebugCombat", EVENT_COMBAT_EVENT, function (eventId, ...)
                SpellCastBuffs.AuthorCombatDebug(eventId, ...)
            end)
        end
        eventManager:UnregisterForEvent(moduleName .. "AuthorDebugEffect", EVENT_EFFECT_CHANGED)
        if SpellCastBuffs.SV.ShowDebugEffect then
            eventManager:RegisterForEvent(moduleName .. "AuthorDebugEffect", EVENT_EFFECT_CHANGED, function (eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
                SpellCastBuffs.AuthorEffectDebug(eventId, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, deprecatedBuffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType)
            end)
        end
    end
end

function SpellCastBuffs.ResetContainerOrientation()
    ---
    --- @param self TopLevelWindow|table
    local function prominentbuffs_OnMoveStop(self)
        if self.alignVertical then
            SpellCastBuffs.SV.prominentbVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentbVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.prominentbHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentbHOffsetY = self:GetTop()
        end
    end
    -- Create TopLevelWindows for Prominent Buffs
    SpellCastBuffs.BuffContainers.prominentbuffs:SetHandler("OnMoveStop", prominentbuffs_OnMoveStop)
    ---
    --- @param self TopLevelWindow|table
    local function prominentdebuffs_OnMoveStop(self)
        if self.alignVertical then
            SpellCastBuffs.SV.prominentdVOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentdVOffsetY = self:GetTop()
        else
            SpellCastBuffs.SV.prominentdHOffsetX = self:GetLeft()
            SpellCastBuffs.SV.prominentdHOffsetY = self:GetTop()
        end
    end
    SpellCastBuffs.BuffContainers.prominentdebuffs:SetHandler("OnMoveStop", prominentdebuffs_OnMoveStop)

    if SpellCastBuffs.SV.ProminentBuffContainerAlignment == 1 then
        SpellCastBuffs.BuffContainers.prominentbuffs.alignVertical = false
    elseif SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2 then
        SpellCastBuffs.BuffContainers.prominentbuffs.alignVertical = true
    end
    if SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 1 then
        SpellCastBuffs.BuffContainers.prominentdebuffs.alignVertical = false
    elseif SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2 then
        SpellCastBuffs.BuffContainers.prominentdebuffs.alignVertical = true
    end

    SpellCastBuffs.containerRouting.promb_ground = "prominentbuffs"
    SpellCastBuffs.containerRouting.promb_target = "prominentbuffs"
    SpellCastBuffs.containerRouting.promb_player = "prominentbuffs"
    SpellCastBuffs.containerRouting.promd_ground = "prominentdebuffs"
    SpellCastBuffs.containerRouting.promd_target = "prominentdebuffs"
    SpellCastBuffs.containerRouting.promd_player = "prominentdebuffs"

    ---
    --- @param self TopLevelWindow|table
    local function player_long_OnMoveStop(self)
        SpellCastBuffs.SV.player_longOffsetX = self:GetLeft()
        SpellCastBuffs.SV.player_longOffsetY = self:GetTop()
    end
    -- Separate container for players long term buffs
    SpellCastBuffs.BuffContainers.player_long:SetHandler("OnMoveStop", player_long_OnMoveStop)

    if SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 1 then
        SpellCastBuffs.BuffContainers.player_long.alignVertical = false
    elseif SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 2 then
        SpellCastBuffs.BuffContainers.player_long.alignVertical = true
    end

    SpellCastBuffs.BuffContainers.player_long.skipUpdate = 0
    SpellCastBuffs.containerRouting.player_long = "player_long"

    -- Set Buff Container Positions
    SpellCastBuffs.SetTlwPosition()
end

-- Populate SpellCastBuffs.alignmentDirection from SV settings.
-- Values are kept as the SV strings ("Left", "Right", "Centered", "Top", "Bottom")
-- and consumed directly by GetFlexJustification — no translation to anchor constants needed.
-- Called from Settings Menu and on Initialize.
function SpellCastBuffs.SetupContainerAlignment()
    SpellCastBuffs.alignmentDirection = {}

    SpellCastBuffs.alignmentDirection.player1 = SpellCastBuffs.SV.AlignmentBuffsPlayer
    SpellCastBuffs.alignmentDirection.playerb = SpellCastBuffs.SV.AlignmentBuffsPlayer
    SpellCastBuffs.alignmentDirection.player2 = SpellCastBuffs.SV.AlignmentDebuffsPlayer
    SpellCastBuffs.alignmentDirection.playerd = SpellCastBuffs.SV.AlignmentDebuffsPlayer
    SpellCastBuffs.alignmentDirection.target1 = SpellCastBuffs.SV.AlignmentBuffsTarget
    SpellCastBuffs.alignmentDirection.targetb = SpellCastBuffs.SV.AlignmentBuffsTarget
    SpellCastBuffs.alignmentDirection.target2 = SpellCastBuffs.SV.AlignmentDebuffsTarget
    SpellCastBuffs.alignmentDirection.targetd = SpellCastBuffs.SV.AlignmentDebuffsTarget

    if SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 1 then
        SpellCastBuffs.alignmentDirection.player_long = SpellCastBuffs.SV.AlignmentLongHorz
    elseif SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 2 then
        SpellCastBuffs.alignmentDirection.player_long = SpellCastBuffs.SV.AlignmentLongVert
    end

    if SpellCastBuffs.SV.ProminentBuffContainerAlignment == 1 then
        SpellCastBuffs.alignmentDirection.prominentbuffs = SpellCastBuffs.SV.AlignmentPromBuffsHorz
    elseif SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2 then
        SpellCastBuffs.alignmentDirection.prominentbuffs = SpellCastBuffs.SV.AlignmentPromBuffsVert
    end

    if SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 1 then
        SpellCastBuffs.alignmentDirection.prominentdebuffs = SpellCastBuffs.SV.AlignmentPromDebuffsHorz
    elseif SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2 then
        SpellCastBuffs.alignmentDirection.prominentdebuffs = SpellCastBuffs.SV.AlignmentPromDebuffsVert
    end

    for k, v in pairs(SpellCastBuffs.containerRouting) do
        local bc = SpellCastBuffs.BuffContainers[v]
        if bc and bc.iconHolder then
            ApplyFlexContainerConfig(v)
        end
    end
end

-- Set SpellCastBuffs.sortDirection table to equal the values from our SV table. Called from Settings Menu & on Initialize
function SpellCastBuffs.SetupContainerSort()
    -- Clear the sort direction table
    ZO_ClearTable(SpellCastBuffs.sortDirection)

    -- Set sort order for player/target containers
    SpellCastBuffs.sortDirection.player1 = SpellCastBuffs.SV.SortBuffsPlayer
    SpellCastBuffs.sortDirection.playerb = SpellCastBuffs.SV.SortBuffsPlayer
    SpellCastBuffs.sortDirection.player2 = SpellCastBuffs.SV.SortDebuffsPlayer
    SpellCastBuffs.sortDirection.playerd = SpellCastBuffs.SV.SortDebuffsPlayer
    SpellCastBuffs.sortDirection.target1 = SpellCastBuffs.SV.SortBuffsTarget
    SpellCastBuffs.sortDirection.targetb = SpellCastBuffs.SV.SortBuffsTarget
    SpellCastBuffs.sortDirection.target2 = SpellCastBuffs.SV.SortDebuffsTarget
    SpellCastBuffs.sortDirection.targetd = SpellCastBuffs.SV.SortDebuffsTarget

    -- Set Long Term Effects Sort Order
    if SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.sortDirection.player_long = SpellCastBuffs.SV.SortLongHorz
    elseif SpellCastBuffs.SV.LongTermEffectsSeparateAlignment == 2 then
        -- Vertical
        SpellCastBuffs.sortDirection.player_long = SpellCastBuffs.SV.SortLongVert
    end

    -- Set Prominent Buffs Sort Order
    if SpellCastBuffs.SV.ProminentBuffContainerAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.sortDirection.prominentbuffs = SpellCastBuffs.SV.SortPromBuffsHorz
    elseif SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2 then
        -- Vertical
        SpellCastBuffs.sortDirection.prominentbuffs = SpellCastBuffs.SV.SortPromBuffsVert
    end

    -- Set Prominent Debuffs Sort Order
    if SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 1 then
        -- Horizontal
        SpellCastBuffs.sortDirection.prominentdebuffs = SpellCastBuffs.SV.SortPromDebuffsHorz
    elseif SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2 then
        -- Vertical
        SpellCastBuffs.sortDirection.prominentdebuffs = SpellCastBuffs.SV.SortPromDebuffsVert
    end

    for k, v in pairs(SpellCastBuffs.containerRouting) do
        ApplyFlexContainerConfig(v)
    end
end

-- Reset position of windows. Called from Settings Menu.
function SpellCastBuffs.ResetTlwPosition()
    if not SpellCastBuffs.Enabled then
        return
    end
    SpellCastBuffs.SV.playerbOffsetX = nil
    SpellCastBuffs.SV.playerbOffsetY = nil
    SpellCastBuffs.SV.playerdOffsetX = nil
    SpellCastBuffs.SV.playerdOffsetY = nil
    SpellCastBuffs.SV.targetbOffsetX = nil
    SpellCastBuffs.SV.targetbOffsetY = nil
    SpellCastBuffs.SV.targetdOffsetX = nil
    SpellCastBuffs.SV.targetdOffsetY = nil
    SpellCastBuffs.SV.player_longOffsetX = nil
    SpellCastBuffs.SV.player_longOffsetY = nil
    SpellCastBuffs.SV.playerVOffsetX = nil
    SpellCastBuffs.SV.playerVOffsetY = nil
    SpellCastBuffs.SV.playerHOffsetX = nil
    SpellCastBuffs.SV.playerHOffsetY = nil
    SpellCastBuffs.SV.prominentbVOffsetX = nil
    SpellCastBuffs.SV.prominentbVOffsetY = nil
    SpellCastBuffs.SV.prominentbHOffsetX = nil
    SpellCastBuffs.SV.prominentbHOffsetY = nil
    SpellCastBuffs.SV.prominentdVOffsetX = nil
    SpellCastBuffs.SV.prominentdVOffsetY = nil
    SpellCastBuffs.SV.prominentdHOffsetX = nil
    SpellCastBuffs.SV.prominentdHOffsetY = nil
    SpellCastBuffs.SetTlwPosition()
end

-- Cached account-wide lookup for grid snap (evaluated at call time).
local function IsSnapToGridBuffsEnabled()
    return LUIE.GetCoreAccountWideRawTable().snapToGrid_buffs
end

-- Applies saved or default position to a TLW. If savedX/savedY are present, optionally snaps and anchors TOPLEFT to GuiRoot; otherwise uses default anchor.
local function ApplySimpleTlwPosition(container, savedX, savedY, defaultPoint, defaultOwner, defaultOwnerPoint, defaultOffsetX, defaultOffsetY)
    container:ClearAnchors()
    if savedX ~= nil and savedY ~= nil then
        local positionX, positionY = savedX, savedY
        if IsSnapToGridBuffsEnabled() then
            positionX, positionY = LUIE.ApplyGridSnap(positionX, positionY, "buffs")
        end
        container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, positionX, positionY)
    else
        container:SetAnchor(defaultPoint, defaultOwner, defaultOwnerPoint, defaultOffsetX, defaultOffsetY)
    end
end

-- Default anchor descriptor for dual-alignment containers.
local function DefaultAnchor(point, owner, ownerPoint, offsetX, offsetY)
    return { point = point, owner = owner, ownerPoint = ownerPoint, offsetX = offsetX, offsetY = offsetY }
end

-- Applies saved or default position for containers with vertical/horizontal alignment. Picks saved coords and default anchor from container.alignVertical.
local function ApplyDualAlignmentTlwPosition(container, savedVX, savedVY, savedHX, savedHY, defaultVerticalAnchor, defaultHorizontalAnchor)
    container:ClearAnchors()
    local savedX, savedY, defaultAnchor
    if container.alignVertical then
        savedX, savedY = savedVX, savedVY
        defaultAnchor = defaultVerticalAnchor
    else
        savedX, savedY = savedHX, savedHY
        defaultAnchor = defaultHorizontalAnchor
    end
    if savedX ~= nil and savedY ~= nil then
        local positionX, positionY = savedX, savedY
        if IsSnapToGridBuffsEnabled() then
            positionX, positionY = LUIE.ApplyGridSnap(positionX, positionY, "buffs")
        end
        container:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, positionX, positionY)
    else
        container:SetAnchor(defaultAnchor.point, defaultAnchor.owner, defaultAnchor.ownerPoint, defaultAnchor.offsetX, defaultAnchor.offsetY)
    end
end

-- Set position of windows. Called from .Initialize() and .ResetTlwPosition()
function SpellCastBuffs.SetTlwPosition()
    -- If icons are locked to custom frames, BuffContainers are CT_CONTROLs on UnitFrames; otherwise they are CT_TOPLEVELCONTROLs — only position TLWs.
    local lockToUnitFrames = SpellCastBuffs.SV.lockPositionToUnitFrames
    local useSavedPosition = (lockToUnitFrames == nil or not lockToUnitFrames)

    if SpellCastBuffs.BuffContainers.playerb and SpellCastBuffs.BuffContainers.playerb:GetType() == CT_TOPLEVELCONTROL then
        ApplySimpleTlwPosition(
            SpellCastBuffs.BuffContainers.playerb,
            useSavedPosition and SpellCastBuffs.SV.playerbOffsetX or nil,
            useSavedPosition and SpellCastBuffs.SV.playerbOffsetY or nil,
            BOTTOM, ZO_PlayerAttributeHealth, TOP, 0, -10
        )
    end

    if SpellCastBuffs.BuffContainers.playerd and SpellCastBuffs.BuffContainers.playerd:GetType() == CT_TOPLEVELCONTROL then
        ApplySimpleTlwPosition(
            SpellCastBuffs.BuffContainers.playerd,
            useSavedPosition and SpellCastBuffs.SV.playerdOffsetX or nil,
            useSavedPosition and SpellCastBuffs.SV.playerdOffsetY or nil,
            BOTTOM, ZO_PlayerAttributeHealth, TOP, 0, -60
        )
    end

    if SpellCastBuffs.BuffContainers.targetb and SpellCastBuffs.BuffContainers.targetb:GetType() == CT_TOPLEVELCONTROL then
        ApplySimpleTlwPosition(
            SpellCastBuffs.BuffContainers.targetb,
            useSavedPosition and SpellCastBuffs.SV.targetbOffsetX or nil,
            useSavedPosition and SpellCastBuffs.SV.targetbOffsetY or nil,
            TOP, ZO_TargetUnitFramereticleover, BOTTOM, 0, 60
        )
    end

    if SpellCastBuffs.BuffContainers.targetd and SpellCastBuffs.BuffContainers.targetd:GetType() == CT_TOPLEVELCONTROL then
        ApplySimpleTlwPosition(
            SpellCastBuffs.BuffContainers.targetd,
            useSavedPosition and SpellCastBuffs.SV.targetdOffsetX or nil,
            useSavedPosition and SpellCastBuffs.SV.targetdOffsetY or nil,
            TOP, ZO_TargetUnitFramereticleover, BOTTOM, 0, 110
        )
    end

    if SpellCastBuffs.BuffContainers.player_long then
        ApplySimpleTlwPosition(
            SpellCastBuffs.BuffContainers.player_long,
            SpellCastBuffs.SV.player_longOffsetX,
            SpellCastBuffs.SV.player_longOffsetY,
            RIGHT, GuiRoot, RIGHT, 0, 0
        )
    end

    if SpellCastBuffs.BuffContainers.prominentbuffs then
        ApplyDualAlignmentTlwPosition(
            SpellCastBuffs.BuffContainers.prominentbuffs,
            SpellCastBuffs.SV.prominentbVOffsetX, SpellCastBuffs.SV.prominentbVOffsetY,
            SpellCastBuffs.SV.prominentbHOffsetX, SpellCastBuffs.SV.prominentbHOffsetY,
            DefaultAnchor(CENTER, GuiRoot, CENTER, -340, -100),
            DefaultAnchor(CENTER, GuiRoot, CENTER, -340, -100)
        )
    end

    if SpellCastBuffs.BuffContainers.prominentdebuffs then
        ApplyDualAlignmentTlwPosition(
            SpellCastBuffs.BuffContainers.prominentdebuffs,
            SpellCastBuffs.SV.prominentdVOffsetX, SpellCastBuffs.SV.prominentdVOffsetY,
            SpellCastBuffs.SV.prominentdHOffsetX, SpellCastBuffs.SV.prominentdHOffsetY,
            DefaultAnchor(CENTER, GuiRoot, CENTER, 340, -100),
            DefaultAnchor(CENTER, GuiRoot, CENTER, 340, -100)
        )
    end
end

-- Unlock windows for moving. Called from Settings Menu.
function SpellCastBuffs.SetMovingState(state)
    if not SpellCastBuffs.Enabled then
        return
    end

    -- When unlocked on console, add buff fragments to settings scene so frames are visible while addon settings are open
    if ZO_IsConsoleOrGameCoreUI() and SpellCastBuffs.BuffFragments then
        local settingsScene = sceneManager:GetScene("LibHarvensAddonSettingsScene")
        for _, fragment in pairs(SpellCastBuffs.BuffFragments) do
            if state then
                settingsScene:AddFragment(fragment)
            else
                settingsScene:RemoveFragment(fragment)
            end
        end
    end

    local function UpdatePositionLabel(control, label)
        if state and label then
            local left, top = control:GetLeft(), control:GetTop()
            label:SetText(string.format("%d, %d", left, top))
            label:SetHidden(false)
            label:ClearAnchors()
            label:SetAnchor(TOPLEFT, control.preview, TOPLEFT, 2, 2)
        elseif label then
            label:SetHidden(true)
        end
    end

    -- Applies moving state and OnMoveStop (snap + save) to a container. saveCallback(control, left, top) writes to SV.
    local function SetContainerMovingState(container, saveCallback)
        container:SetMouseEnabled(state)
        container:SetMovable(state)
        UpdatePositionLabel(container, container.preview and container.preview.anchorLabel)
        container:SetHandler("OnMoveStop", function (self)
            local left, top = self:GetLeft(), self:GetTop()
            if IsSnapToGridBuffsEnabled() then
                left, top = LUIE.ApplyGridSnap(left, top, "buffs")
                self:ClearAnchors()
                self:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
            end
            saveCallback(self, left, top)
        end)
    end

    local lockToUnitFrames = SpellCastBuffs.SV.lockPositionToUnitFrames
    local canMoveStandalone = (lockToUnitFrames == nil or not lockToUnitFrames)

    if SpellCastBuffs.BuffContainers.playerb and SpellCastBuffs.BuffContainers.playerb:GetType() == CT_TOPLEVELCONTROL and canMoveStandalone then
        SetContainerMovingState(SpellCastBuffs.BuffContainers.playerb, function (_, left, top)
            SpellCastBuffs.SV.playerbOffsetX = left
            SpellCastBuffs.SV.playerbOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.playerd and SpellCastBuffs.BuffContainers.playerd:GetType() == CT_TOPLEVELCONTROL and canMoveStandalone then
        SetContainerMovingState(SpellCastBuffs.BuffContainers.playerd, function (_, left, top)
            SpellCastBuffs.SV.playerdOffsetX = left
            SpellCastBuffs.SV.playerdOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.targetb and SpellCastBuffs.BuffContainers.targetb:GetType() == CT_TOPLEVELCONTROL and canMoveStandalone then
        SetContainerMovingState(SpellCastBuffs.BuffContainers.targetb, function (_, left, top)
            SpellCastBuffs.SV.targetbOffsetX = left
            SpellCastBuffs.SV.targetbOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.targetd and SpellCastBuffs.BuffContainers.targetd:GetType() == CT_TOPLEVELCONTROL and canMoveStandalone then
        SetContainerMovingState(SpellCastBuffs.BuffContainers.targetd, function (_, left, top)
            SpellCastBuffs.SV.targetdOffsetX = left
            SpellCastBuffs.SV.targetdOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.player_long then
        SetContainerMovingState(SpellCastBuffs.BuffContainers.player_long, function (_, left, top)
            SpellCastBuffs.SV.player_longOffsetX = left
            SpellCastBuffs.SV.player_longOffsetY = top
        end)
    end

    if SpellCastBuffs.BuffContainers.prominentbuffs then
        SetContainerMovingState(SpellCastBuffs.BuffContainers.prominentbuffs, function (self, left, top)
            if self.alignVertical then
                SpellCastBuffs.SV.prominentbVOffsetX = left
                SpellCastBuffs.SV.prominentbVOffsetY = top
            else
                SpellCastBuffs.SV.prominentbHOffsetX = left
                SpellCastBuffs.SV.prominentbHOffsetY = top
            end
        end)
    end

    if SpellCastBuffs.BuffContainers.prominentdebuffs then
        SetContainerMovingState(SpellCastBuffs.BuffContainers.prominentdebuffs, function (self, left, top)
            if self.alignVertical then
                SpellCastBuffs.SV.prominentdVOffsetX = left
                SpellCastBuffs.SV.prominentdVOffsetY = top
            else
                SpellCastBuffs.SV.prominentdHOffsetX = left
                SpellCastBuffs.SV.prominentdHOffsetY = top
            end
        end)
    end

    for _, routedContainerKey in pairs(SpellCastBuffs.containerRouting) do
        SpellCastBuffs.BuffContainers[routedContainerKey].preview:SetHidden(not state)
    end

    if state then
        SpellCastBuffs.MenuPreview()
    else
        SpellCastBuffs.Reset()
    end
end

-- Sets dimensions on two TLW wrap containers and their iconHolders (player or target standalone).
local function SetTlwWrapContainerDimensions(containerA, containerB, widthA, widthB, wrapHeight)
    containerA:SetDimensions(widthA, wrapHeight)
    containerB:SetDimensions(widthB, wrapHeight)
    if containerA.iconHolder then containerA.iconHolder:SetDimensions(widthA, wrapHeight) end
    if containerB.iconHolder then containerB.iconHolder:SetDimensions(widthB, wrapHeight) end
end

-- Sets height and iconHolder dimensions on two unit-frame containers (width from control).
local function SetUnitFrameContainerDimensions(containerA, containerB, iconHeight)
    containerA:SetHeight(iconHeight)
    containerB:SetHeight(iconHeight)
    if containerA.iconHolder then containerA.iconHolder:SetDimensions(containerA:GetWidth(), iconHeight) end
    if containerB.iconHolder then containerB.iconHolder:SetDimensions(containerB:GetWidth(), iconHeight) end
end

-- Single-axis container (player_long, prominent): vertical = narrow×tall, horizontal = wide×short.
local function SetSingleAxisContainerDimensions(container, alignVertical, iconSize)
    local width, height
    if alignVertical then
        width, height = iconSize + 6, 400
    else
        width, height = 500, iconSize + 6
    end
    container:SetDimensions(width, height)
    if container.iconHolder then container.iconHolder:SetDimensions(width, height) end
end

-- Reset all buff containers
function SpellCastBuffs.Reset()
    if not SpellCastBuffs.Enabled then
        return
    end

    SpellCastBuffs.padding = zo_floor(0.5 + SpellCastBuffs.SV.IconSize / 13)

    local wrapHeight = SpellCastBuffs.SV.IconSize
    local iconSize = SpellCastBuffs.SV.IconSize
    local buffContainers = SpellCastBuffs.BuffContainers

    -- Player
    if buffContainers.playerb and buffContainers.playerb:GetType() == CT_TOPLEVELCONTROL then
        SetTlwWrapContainerDimensions(buffContainers.playerb, buffContainers.playerd, SpellCastBuffs.SV.WidthPlayerBuffs, SpellCastBuffs.SV.WidthPlayerDebuffs, wrapHeight)
    else
        SetUnitFrameContainerDimensions(buffContainers.player1, buffContainers.player2, iconSize)
    end

    -- Target
    if buffContainers.targetb and buffContainers.targetb:GetType() == CT_TOPLEVELCONTROL then
        SetTlwWrapContainerDimensions(buffContainers.targetb, buffContainers.targetd, SpellCastBuffs.SV.WidthTargetBuffs, SpellCastBuffs.SV.WidthTargetDebuffs, wrapHeight)
    else
        SetUnitFrameContainerDimensions(buffContainers.target1, buffContainers.target2, iconSize)
    end

    -- Player long-term buffs
    if buffContainers.player_long then
        SetSingleAxisContainerDimensions(buffContainers.player_long, buffContainers.player_long.alignVertical, iconSize)
    end

    -- Prominent buffs & debuffs
    if buffContainers.prominentbuffs then
        SetSingleAxisContainerDimensions(buffContainers.prominentbuffs, buffContainers.prominentbuffs.alignVertical, iconSize)
        SetSingleAxisContainerDimensions(buffContainers.prominentdebuffs, buffContainers.prominentdebuffs.alignVertical, iconSize)
    end

    SpellCastBuffs.SetupContainerAlignment()
    SpellCastBuffs.SetupContainerSort()

    for _, routedContainerKey in pairs(SpellCastBuffs.containerRouting) do
        local container = buffContainers[routedContainerKey]
        for iconIndex = 1, #container.icons do
            SpellCastBuffs.ResetSingleIcon(routedContainerKey, container.icons[iconIndex])
        end
    end

    if IsPlayerActivated() then
        SpellCastBuffs.playerActive = true
        SpellCastBuffs.ReloadEffects("player")
        if GetUnitName("reticleover") ~= "" then
            SpellCastBuffs.ReloadEffects("reticleover")
        end
    end

    SpellCastBuffs.MarkDisplayLayoutDirty()
    SpellCastBuffs.ScheduleAbilityIdDebugLabelRefresh()
end

-- Applies the correct flex margins to a single buff icon.
-- Must be called AFTER SetExcludeFromFlexbox(false) so margins are set on a live Yoga node.
-- Called from both ResetSingleIcon (full reset) and updateIcons (every re-show).
--
-- Uses explicit PHYSICAL edges (not FLEX_EDGE_END/START) because ESO's Yoga implementation
-- does not appear to resolve logical edges by flex direction for SetFlexMargin — FLEX_EDGE_END
-- maps to a fixed constant that works for ROW but silently applies the wrong physical edge
-- for COLUMN layouts, resulting in zero vertical gap between stacked icons.
--
-- Main-axis spacing (implementation note, 2025): inter-icon distance is still `gap`, but the
-- legacy "trailing margin only" setup is expressed as SetFlexMargins with half of `gap` on the
-- flex-start physical edge and half on flex-end (integer split). That preserves neighbor spacing
-- while keeping rows even under FLEX_JUSTIFICATION_CENTER + wrap. The physical edges used:
--   ROW            --> LEFT + RIGHT   (formerly all on RIGHT)
--   ROW_REVERSE    --> RIGHT + LEFT   (formerly all on LEFT)
--   COLUMN         --> TOP + BOTTOM   (formerly all on BOTTOM)
--   COLUMN_REVERSE --> BOTTOM + TOP   (formerly all on TOP)
--
-- Cross-axis gutter uses one-sided margin so inter-row gap = exactly padding (not 2×padding).
-- Vertical single-axis columns use IconSize/10 for gap so labels stay readable at any size.
-- `SpellCastBuffs.padding` uses the same formula as older SpellCastBuffs `g_padding`:
-- zo_floor(0.5 + IconSize / 13).
function SpellCastBuffs.ApplyIconFlexMargin(container, buff)
    local holder = SpellCastBuffs.BuffContainers[container].iconHolder
    local flexDir = holder and holder:GetChildFlexDirection()
    local flexWrap = holder and holder:GetChildFlexWrap()
    local isWrap = WRAP_CONTAINERS[container]
    local isRow = (flexDir == FLEX_DIRECTION_ROW or flexDir == FLEX_DIRECTION_ROW_REVERSE)
    local isWrapReverse = (flexWrap == FLEX_WRAP_WRAP_REVERSE)
    local gap = (not isWrap and not isRow)
        and zo_floor(SpellCastBuffs.SV.IconSize / 10)
        or SpellCastBuffs.padding

    local gapStart = zo_floor(gap / 2)
    local gapEnd = gap - gapStart

    local left, top, right, bottom = 0, 0, 0, 0

    if flexDir == FLEX_DIRECTION_ROW then
        left, right = gapStart, gapEnd
    elseif flexDir == FLEX_DIRECTION_ROW_REVERSE then
        left, right = gapEnd, gapStart
    elseif flexDir == FLEX_DIRECTION_COLUMN then
        top, bottom = gapStart, gapEnd
    elseif flexDir == FLEX_DIRECTION_COLUMN_REVERSE then
        top, bottom = gapEnd, gapStart
    else
        right = gap
    end

    if isWrap then
        if isRow then
            if isWrapReverse then
                top = top + SpellCastBuffs.padding
            else
                bottom = bottom + SpellCastBuffs.padding
            end
        else
            if isWrapReverse then
                left = left + SpellCastBuffs.padding
            else
                right = right + SpellCastBuffs.padding
            end
        end
    end

    buff:SetFlexMargins(left, top, right, bottom)
end

-- ZO_BuffDebuff-style 64×64 `abilityFrame_*` / `gp_abilityFrame_*` borders (BuffDebuff.xml,
-- BuffDebuffStyles.lua). `buff.back` fills the slot; without cropping, the full atlas scales into
-- IconSize and the frame ring appears inset (“double frame”).
function SpellCastBuffs.GetBuffBorderTexture()
    return IsInGamepadPreferredMode() and "EsoUI/Art/ActionBar/Gamepad/gp_abilityFrame_buff.dds" or "EsoUI/Art/ActionBar/abilityFrame_buff.dds"
end

-- Debuff variant of GetBuffBorderTexture (same gamepad/keyboard split).
function SpellCastBuffs.GetDebuffBorderTexture()
    return IsInGamepadPreferredMode() and "EsoUI/Art/ActionBar/Gamepad/gp_abilityFrame_debuff.dds" or "EsoUI/Art/ActionBar/abilityFrame_debuff.dds"
end

function SpellCastBuffs.GetGenericIconInsetTexture()
    if IsInGamepadPreferredMode() then
        return "EsoUI/Art/Miscellaneous/Gamepad/gp_edgeFill.dds"
    end
    return "EsoUI/Art/ActionBar/abilityInset.dds"
end

--- @return boolean
function SpellCastBuffs.UseGlowIconBorder()
    return SpellCastBuffs.SV.GlowIcons
end

--- ZO_BUFF_DEBUFF_ICON = frame - 4 (2px per edge at 40px frame). Inset panel must sit under smaller icon art.
--- @param container string|nil
--- @return boolean
function SpellCastBuffs.ShouldShowBuffIconInsetBg(container)
    if container == "player_long" then
        return false
    end
    return SpellCastBuffs.SV.RemainingCooldown
end

--- @param container string|nil
--- @return number
function SpellCastBuffs.GetBuffIconArtInset(container)
    if SpellCastBuffs.ShouldShowBuffIconInsetBg(container) then
        return 2
    end
    return 1
end

--- Radial wedge only for finite-duration effects (ZO_BuffDebuff: not permanent, duration > 0).
--- @param container string|nil
--- @param effect table|nil
--- @return boolean
function SpellCastBuffs.ShouldShowBuffIconRadialCooldown(container, effect)
    if container == "player_long" then
        return false
    end
    if not SpellCastBuffs.SV.RemainingCooldown then
        return false
    end
    if not effect then
        return false
    end
    if effect.fakeDuration then
        return false
    end
    if effect.ends == nil or effect.dur == nil or effect.dur == 0 then
        return false
    end
    return true
end

--- ZO_BuffDebuffIcon: Cooldown level 1, Icon level 2 — radial wedge under art.
--- @param buff SpellCastBuffs_BuffIcon_Control
function SpellCastBuffs.ApplyBuffIconDrawOrder(buff)
    if buff.cd then
        buff.cd:SetDrawLayer(DL_BACKGROUND)
        buff.cd:SetDrawLevel(1)
    end
    if buff.iconbg then
        buff.iconbg:SetDrawLayer(DL_BACKGROUND)
        buff.iconbg:SetDrawLevel(2)
    end
    if buff.icon then
        buff.icon:SetDrawLayer(DL_CONTROLS)
        buff.icon:SetDrawLevel(2)
    end
end

--- @param buff SpellCastBuffs_BuffIcon_Control
--- @param container string|nil
function SpellCastBuffs.ApplyBuffIconInsetAnchors(buff, container)
    if not buff.iconbg then
        return
    end
    local showIconBg = SpellCastBuffs.ShouldShowBuffIconInsetBg(container)
    local iconArtInset = SpellCastBuffs.GetBuffIconArtInset(container)
    local panelInset = zo_max(1, iconArtInset - 1)

    buff.iconbg:ClearAnchors()
    if showIconBg then
        buff.iconbg:SetAnchor(TOPLEFT, buff, TOPLEFT, panelInset, panelInset)
        buff.iconbg:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -panelInset, -panelInset)
    end

    if buff.icon then
        buff.icon:ClearAnchors()
        buff.icon:SetAnchor(TOPLEFT, buff, TOPLEFT, iconArtInset, iconArtInset)
        buff.icon:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -iconArtInset, -iconArtInset)
    end
    if buff.drop then
        buff.drop:ClearAnchors()
        buff.drop:SetAnchor(TOPLEFT, buff, TOPLEFT, iconArtInset, iconArtInset)
        buff.drop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, -iconArtInset, -iconArtInset)
    end
end

--- @param buff SpellCastBuffs_BuffIcon_Control
--- @param container string
--- @param effectContext table|nil
function SpellCastBuffs.ApplyBuffIconInsetVisual(buff, container, effectContext)
    if container == "player_long" then
        if buff.iconbg then
            buff.iconbg:SetHidden(true)
        end
        if buff.cd then
            buff.cd:ResetCooldown()
            buff.cd:SetHidden(true)
        end
        return
    end

    local showRadial = SpellCastBuffs.ShouldShowBuffIconRadialCooldown(container, effectContext)
    local showIconBg = SpellCastBuffs.ShouldShowBuffIconInsetBg(container)

    if buff.cd then
        if showRadial then
            buff.cd:SetHidden(false)
        else
            buff.cd:ResetCooldown()
            buff.cd:SetHidden(true)
        end
    end
    if buff.iconbg then
        buff.iconbg:SetHidden(not showIconBg)
        if showIconBg then
            buff.iconbg:SetTexture(SpellCastBuffs.GetGenericIconInsetTexture())
        end
    end
end

--- Glow/back, inset, and drop chrome after effect bind (single authoritative pass).
--- @param buff SpellCastBuffs_BuffIcon_Control
--- @param container string|nil
--- @param effectContext table|nil effect row from display sort (optional `backdrop`)
function SpellCastBuffs.ApplyBuffIconChrome(buff, container, effectContext)
    local useGlow = SpellCastBuffs.UseGlowIconBorder()
    if buff.back then
        buff.back:SetHidden(useGlow)
    end
    if buff.frame then
        buff.frame:SetHidden(not useGlow)
    end
    if buff.drop and effectContext then
        buff.drop:SetHidden(not effectContext.backdrop)
    end
    SpellCastBuffs.ApplyBuffIconInsetAnchors(buff, container)
    SpellCastBuffs.ApplyBuffIconInsetVisual(buff, container, effectContext)
    SpellCastBuffs.ApplyBuffIconDrawOrder(buff)
    buff.lastChromeLayoutVersion = SpellCastBuffs.displayLayoutVersion
end

--- Crops the 64×64 atlas to the center `iconSize` region (keyboard), or uses the gamepad XML UVs.
--- @param texture TextureControl|nil
--- @param iconSize number Slot width/height in px (SpellCastBuffs.SV.IconSize)
function SpellCastBuffs.ApplyAbilityFrameTextureCoords(texture, iconSize)
    if not texture then
        return
    end
    if IsInGamepadPreferredMode() then
        texture:SetTextureCoords(0.1094, 0.8906, 0.1094, 0.8906)
    else
        local inset = (64 - iconSize) / 2 / 64
        local outer = (64 + iconSize) / 2 / 64
        texture:SetTextureCoords(inset, outer, inset, outer)
    end
end

-- Keeps pooled flex icons square so radial cooldown + abilityFrame UVs are not stretched.
--- @param buff Control
--- @param buffSize number
function SpellCastBuffs.ApplyBuffIconSlotDimensions(buff, buffSize)
    buff:SetDimensions(buffSize, buffSize)
    buff:SetDimensionConstraints(buffSize, buffSize, buffSize, buffSize)
    buff:SetFlexBasis(buffSize)
    buff:SetFlexGrow(0)
    buff:SetFlexShrink(0)
end

-- Prominent vertical column: name in the strip between icon top and progress bar top.
--- @param buff SpellCastBuffs_BuffIcon_Control
--- @param labelOnLeft boolean
local function ApplyProminentNameLabelAnchors(buff, labelOnLeft)
    local xOff = labelOnLeft and -4 or 4
    buff.name:ClearAnchors()
    if labelOnLeft then
        buff.name:SetAnchor(TOPRIGHT, buff, TOPLEFT, xOff, 2)
        buff.name:SetAnchor(BOTTOMLEFT, buff.bar.backdrop, TOPLEFT, 0, -2)
    else
        buff.name:SetAnchor(TOPLEFT, buff, TOPRIGHT, xOff, 2)
        buff.name:SetAnchor(BOTTOMRIGHT, buff.bar.backdrop, TOPRIGHT, 0, -2)
    end
    buff.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    buff.name:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    buff.name:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
    buff.name:SetMaxLineCount(1)
end

--- Ability-id overlay anchors and visibility (pool acquire, icon resize, settings).
--- @param buff SpellCastBuffs_BuffIcon_Control
function SpellCastBuffs.ApplyBuffIconAbilityIdLayout(buff)
    if not buff.abilityId then
        return
    end
    local buffSize = SpellCastBuffs.SV.IconSize
    local showId = SpellCastBuffs.SV.ShowDebugAbilityId
    local idOutset = zo_max(2, zo_floor(buffSize * 0.12))
    if  buff.lastAbilityIdLayoutIconSize == buffSize
    and buff.lastAbilityIdLayoutOutset == idOutset
    and buff.lastAbilityIdLayoutShown == showId then
        return
    end
    buff.lastAbilityIdLayoutIconSize = buffSize
    buff.lastAbilityIdLayoutOutset = idOutset
    buff.lastAbilityIdLayoutShown = showId
    buff.abilityId:SetHidden(not showId)
    buff.abilityId:ClearAnchors()
    buff.abilityId:SetAnchor(TOPLEFT, buff, TOPLEFT, -idOutset, 1)
    buff.abilityId:SetAnchor(TOPRIGHT, buff, TOPRIGHT, idOutset, 1)
    buff.abilityId:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    buff.abilityId:SetVerticalAlignment(TEXT_ALIGN_TOP)
    SpellCastBuffs.MarkAbilityIdLabelDirty(buff)
end

-- Layout, anchors, and visibility for one icon (pool acquire or settings refresh).
function SpellCastBuffs.ApplySingleIconLayout(container, buff)
    local buffSize = SpellCastBuffs.SV.IconSize
    local frameSize = 2 * buffSize + 4

    SpellCastBuffs.ApplyBuffIconSlotDimensions(buff, buffSize)
    buff.frame:ClearAnchors()
    buff.frame:SetAnchor(CENTER, buff, CENTER, 0, 0)
    buff.frame:SetDimensions(frameSize, frameSize)
    buff.frame:SetPixelRoundingEnabled(true)
    if buff.buffType then
        local borderTexture = (buff.buffType == BUFF_EFFECT_TYPE_BUFF) and SpellCastBuffs.GetBuffBorderTexture() or SpellCastBuffs.GetDebuffBorderTexture()
        buff.back:SetTexture(borderTexture)
    end
    SpellCastBuffs.ApplyAbilityFrameTextureCoords(buff.back, buffSize)
    buff.label:SetAnchor(TOPLEFT, buff, LEFT, -SpellCastBuffs.padding, -SpellCastBuffs.SV.LabelPosition)
    buff.label:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, SpellCastBuffs.padding, -2)
    buff.label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    buff.label:SetVerticalAlignment(TEXT_ALIGN_BOTTOM)
    buff.label:SetHidden(not SpellCastBuffs.SV.RemainingText)
    buff.stack:SetAnchor(CENTER, buff, BOTTOMLEFT, 0, 0)
    buff.stack:SetAnchor(CENTER, buff, TOPRIGHT, -SpellCastBuffs.padding * 3, SpellCastBuffs.padding * 3)
    buff.stack:SetHidden(true)

    if buff.name ~= nil then
        if (container == "prominentbuffs" and SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2) or (container == "prominentdebuffs" and SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2) then
            -- Vertical
            buff.name:SetHidden(not SpellCastBuffs.SV.ProminentLabel)
        else
            buff.name:SetHidden(true)
        end
    end

    if buff.bar ~= nil then
        if (container == "prominentbuffs" and SpellCastBuffs.SV.ProminentBuffContainerAlignment == 2) or (container == "prominentdebuffs" and SpellCastBuffs.SV.ProminentDebuffContainerAlignment == 2) then
            -- Vertical
            buff.bar.backdrop:SetHidden(not SpellCastBuffs.SV.ProminentProgress)
            buff.bar.bar:SetHidden(not SpellCastBuffs.SV.ProminentProgress)
        else
            buff.bar.backdrop:SetHidden(true)
            buff.bar.bar:SetHidden(true)
        end
    end

    SpellCastBuffs.ApplyBuffIconAbilityIdLayout(buff)
    if SpellCastBuffs.SV.ShowDebugAbilityId and buff.abilityId and buff.abilityId:GetText() ~= "" then
        if SpellCastBuffs.NeedsAbilityIdLabelFit(buff) then
            SpellCastBuffs.FitAbilityIdLabelFont(buff)
        end
    end

    if buff.back then
        buff.back:ClearAnchors()
        buff.back:SetAnchor(TOPLEFT, buff, TOPLEFT, 0, 0)
        buff.back:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, 0, 0)
    end
    if buff.cd and container ~= "player_long" then
        buff.cd:ClearAnchors()
        buff.cd:SetAnchor(TOPLEFT, buff, TOPLEFT, 0, 0)
        buff.cd:SetAnchor(BOTTOMRIGHT, buff, BOTTOMRIGHT, 0, 0)
    end

    SpellCastBuffs.ApplyBuffIconChrome(buff, container, nil)

    if container == "prominentbuffs" then
        if SpellCastBuffs.SV.ProminentBuffLabelDirection == "Left" then
            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[SpellCastBuffs.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)

            ApplyProminentNameLabelAnchors(buff, true)
        else
            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[SpellCastBuffs.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)

            ApplyProminentNameLabelAnchors(buff, false)
        end
    end

    if container == "prominentdebuffs" then
        if SpellCastBuffs.SV.ProminentDebuffLabelDirection == "Right" then
            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)
            buff.bar.backdrop:SetAnchor(BOTTOMLEFT, buff, BOTTOMRIGHT, 4, 0)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[SpellCastBuffs.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_NORMAL)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)

            ApplyProminentNameLabelAnchors(buff, false)
        else
            buff.bar.backdrop:ClearAnchors()
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)
            buff.bar.backdrop:SetAnchor(BOTTOMRIGHT, buff, BOTTOMLEFT, -4, 0)

            buff.bar.bar:SetTexture(LUIE.StatusbarTextures[SpellCastBuffs.SV.ProminentProgressTexture])
            buff.bar.bar:SetBarAlignment(BAR_ALIGNMENT_REVERSE)
            buff.bar.bar:ClearAnchors()
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)
            buff.bar.bar:SetAnchor(CENTER, buff.bar.backdrop, CENTER, 0, 0)

            ApplyProminentNameLabelAnchors(buff, true)
        end
    end

    buff.lastAppliedIconSize = buffSize
    buff.lastLayoutVersion = SpellCastBuffs.displayLayoutVersion
end

-- Reset only a single icon
function SpellCastBuffs.ResetSingleIcon(container, buff)
    buff:SetHidden(true)
    SpellCastBuffs.ApplySingleIconLayout(container, buff)
    SpellCastBuffs.ApplyIconFlexMargin(container, buff)
end

-- Right Click Cancel Buff function
--- @param self SpellCastBuffs_BuffIcon_Control
--- @param button number
--- @param upInside boolean
function SpellCastBuffs.Buff_OnMouseUp(self, button, upInside)
    if upInside and button == MOUSE_BUTTON_INDEX_RIGHT then
        ClearMenu()
        local id, name = self.effectId, self.effectName

        -- Blacklist
        local blacklist = SpellCastBuffs.SV.BlacklistTable
        local isBlacklisted = blacklist[id] or blacklist[name]
        AddMenuItem(isBlacklisted and "Remove from Blacklist" or "Add to Blacklist", function ()
            if isBlacklisted then
                SpellCastBuffs.RemoveFromCustomList(blacklist, id)
                SpellCastBuffs.RemoveFromCustomList(blacklist, name)
            else
                SpellCastBuffs.AddToCustomList(blacklist, id)
                SpellCastBuffs.AddToCustomList(blacklist, name)
            end
        end)

        -- Prominent Buffs
        local promBuffs = SpellCastBuffs.SV.PromBuffTable
        local isPromBuff = promBuffs[id] or promBuffs[name]
        AddMenuItem(isPromBuff and "Remove from Prominent Buffs" or "Add to Prominent Buffs", function ()
            if isPromBuff then
                SpellCastBuffs.RemoveFromCustomList(promBuffs, id)
                SpellCastBuffs.RemoveFromCustomList(promBuffs, name)
            else
                SpellCastBuffs.AddToCustomList(promBuffs, id)
                SpellCastBuffs.AddToCustomList(promBuffs, name)
            end
        end)

        -- Prominent Debuffs
        local promDebuffs = SpellCastBuffs.SV.PromDebuffTable
        local isPromDebuff = SpellCastBuffs.WantsProminentDebuff(id, name)
        AddMenuItem(isPromDebuff and "Remove from Prominent Debuffs" or "Add to Prominent Debuffs", function ()
            if isPromDebuff then
                SpellCastBuffs.RemoveFromCustomList(promDebuffs, id)
                SpellCastBuffs.RemoveFromCustomList(promDebuffs, name)
                local obName = Abilities.Skill_Off_Balance
                if obName and promDebuffs[obName] then
                    if (id and SpellCastBuffs.offBalanceDebuffById[id]) or id == Effects.OffBalanceImmunityAbilityId then
                        SpellCastBuffs.RemoveFromCustomList(promDebuffs, obName)
                    end
                end
            else
                SpellCastBuffs.AddToCustomList(promDebuffs, id)
                SpellCastBuffs.AddToCustomList(promDebuffs, name)
            end
        end)

        -- Cancel Buff (if possible)
        if self.buffSlot then
            AddMenuItem("Cancel Buff", function ()
                CancelBuff(self.buffSlot)
            end)
        end
        ShowMenu(self)
    end
end

local function ClearStickyTooltip()
    ClearTooltip(InformationTooltip)
    SpellCastBuffs.ClearDebugMetaOverflowTooltip()
    SpellCastBuffs.ClearDebugMetaTooltipLiveUpdate()
    SpellCastBuffs.tooltipHoverState = nil
    eventManager:UnregisterForUpdate(moduleName .. "StickyTooltip")
end

--- Flex relayout / icon pool rebound can fire OnMouseEnter again while the pointer never left the icon.
--- Rebuilding InformationTooltip (and debug overflow) on every repeat causes visible layout flicker.
--- @param control Control
--- @return boolean
local function ShouldSkipRepeatBuffTooltipBuild(control)
    local state = SpellCastBuffs.tooltipHoverState
    if not state or state.control ~= control or state.effectId ~= control.effectId then
        return false
    end
    if InformationTooltip:IsHidden() then
        return false
    end
    if InformationTooltip.GetOwner and InformationTooltip:GetOwner() ~= control then
        return false
    end
    return true
end

local buffTypes =
{
    [LUIE_BUFF_TYPE_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_BUFF),
    [LUIE_BUFF_TYPE_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_DEBUFF),
    [LUIE_BUFF_TYPE_UB_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_UB_BUFF),
    [LUIE_BUFF_TYPE_UB_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_UB_DEBUFF),
    [LUIE_BUFF_TYPE_GROUND_BUFF_TRACKER] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_BUFF_TRACKER),
    [LUIE_BUFF_TYPE_GROUND_DEBUFF_TRACKER] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_DEBUFF_TRACKER),
    [LUIE_BUFF_TYPE_GROUND_AOE_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_AOE_BUFF),
    [LUIE_BUFF_TYPE_GROUND_AOE_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_GROUND_AOE_DEBUFF),
    [LUIE_BUFF_TYPE_ENVIRONMENT_BUFF] = GetString(LUIE_STRING_BUFF_TYPE_ENVIRONMENT_BUFF),
    [LUIE_BUFF_TYPE_ENVIRONMENT_DEBUFF] = GetString(LUIE_STRING_BUFF_TYPE_ENVIRONMENT_DEBUFF),
    [LUIE_BUFF_TYPE_NONE] = GetString(LUIE_STRING_BUFF_TYPE_NONE),
}

--- Routed buff container key --> unit tag for stealth/tooltip APIs.
--- @param container string|nil
--- @return string
local function TooltipUnitTagFromBuffContainer(container)
    if container == "target1" or container == "target2" or container == "targetb" or container == "targetd"
    or container == "promb_target" or container == "promd_target" then
        return "reticleover"
    end
    return "player"
end

function SpellCastBuffs.TooltipBottomLine(control, detailsLine, artificial, unitTag)
    local ttUnit = unitTag or TooltipUnitTagFromBuffContainer(control.container)
    -- Add bottom divider and info if present:
    if SpellCastBuffs.SV.TooltipAbilityId or SpellCastBuffs.SV.TooltipBuffType or SpellCastBuffs.SV.TooltipDebugMeta then
        ZO_Tooltip_AddDivider(InformationTooltip)
        InformationTooltip:SetVerticalPadding(4)
        InformationTooltip:AddLine("", "", ZO_NORMAL_TEXT:UnpackRGB())
        -- Add Ability ID Line
        if SpellCastBuffs.SV.TooltipAbilityId then
            local labelAbilityId = control.effectId or "None"
            local isArtificial = labelAbilityId == "Fake" and true or artificial
            if isArtificial then
                labelAbilityId = "Artificial"
            end
            InformationTooltip:AddHeaderLine("Ability ID", "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
            InformationTooltip:AddHeaderLine(labelAbilityId, "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
            detailsLine = detailsLine + 1
        end

        -- Add Buff Type Line
        if SpellCastBuffs.SV.TooltipBuffType then
            local buffType = control.buffType or LUIE_BUFF_TYPE_NONE
            local effectId = control.effectId
            if effectId and Effects.EffectOverride[effectId] and Effects.EffectOverride[effectId].unbreakable then
                buffType = buffType + 2
            end

            -- Setup tooltips for player aoe trackers
            if effectId and Effects.EffectGroundDisplay[effectId] then
                buffType = buffType + 4
            end

            -- Setup tooltips for ground buff/debuff effects
            if effectId and (Effects.AddGroundDamageAura[effectId] or (Effects.EffectOverride[effectId] and Effects.EffectOverride[effectId].groundLabel)) then
                buffType = buffType + 6
            end

            -- Setup tooltips for Fake Player Offline Auras
            if effectId and Effects.FakePlayerOfflineAura[effectId] then
                if Effects.FakePlayerOfflineAura[effectId].ground then
                    buffType = 6
                else
                    buffType = 5
                end
            end

            InformationTooltip:AddHeaderLine("Type", "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_LEFT, ZO_NORMAL_TEXT:UnpackRGB())
            InformationTooltip:AddHeaderLine(buffTypes[buffType], "ZoFontWinT1", detailsLine, TOOLTIP_HEADER_SIDE_RIGHT, 1, 1, 1)
            detailsLine = detailsLine + 1
        end
    end

    if SpellCastBuffs.SV.TooltipDebugMeta then
        InformationTooltip:AddVerticalPadding(4)
        detailsLine = SpellCastBuffs.AddTooltipDebugMetaLines(control, detailsLine, ttUnit)
    end

    return detailsLine
end

--- @param container string|nil
--- @return string
function SpellCastBuffs.TooltipUnitTagFromBuffContainer(container)
    return TooltipUnitTagFromBuffContainer(container)
end

-- OnMouseEnter for Buff Tooltips
function SpellCastBuffs.Buff_OnMouseEnter(control)
    eventManager:UnregisterForUpdate(moduleName .. "StickyTooltip")

    if ShouldSkipRepeatBuffTooltipBuild(control) then
        return
    end

    SpellCastBuffs.tooltipHoverState =
    {
        control = control,
        effectId = control.effectId,
    }

    SpellCastBuffs.ClearDebugMetaOverflowTooltip()
    SpellCastBuffs.ClearDebugMetaTooltipLiveUpdate()
    InitializeTooltip(InformationTooltip, control, BOTTOM, 0, -5, TOP)
    -- Setup Text
    local tooltipText = ""
    local detailsLine
    local colorText = ZO_NORMAL_TEXT
    local tooltipTitle = zo_strformat(SI_ABILITY_TOOLTIP_NAME, control.effectName)
    if control.isArtificial then
        local artificialEffectId = control.artificialEffectId
        if artificialEffectId == nil and type(control.effectId) == "number" and control.effectId >= 0 and control.effectId <= 8 then
            artificialEffectId = control.effectId
        end
        tooltipText = GetArtificialEffectTooltipText(artificialEffectId)
        InformationTooltip:AddLine(tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
        detailsLine = 3
        if SpellCastBuffs.SV.TooltipEnable then
            InformationTooltip:SetVerticalPadding(1)
            ZO_Tooltip_AddDivider(InformationTooltip)
            InformationTooltip:SetVerticalPadding(5)
            InformationTooltip:AddLine(tooltipText, "", colorText:UnpackRGBA())
            detailsLine = 5
        end
        SpellCastBuffs.TooltipBottomLine(control, detailsLine, true, "player")
    else
        if not SpellCastBuffs.SV.TooltipEnable then
            InformationTooltip:AddLine(tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
            detailsLine = 3
            SpellCastBuffs.TooltipBottomLine(control, detailsLine, false, TooltipUnitTagFromBuffContainer(control.container))
            return
        end

        local ttUnit = TooltipUnitTagFromBuffContainer(control.container)

        if control.tooltip then
            tooltipText = control.tooltip
        else
            local duration = 0
            if type(control.effectId) == "number" then
                duration = zo_floor((control.duration / 1000 * 10) + 0.5) / 10
                local ov = Effects.EffectOverride[control.effectId]

                local formatted = LUIE.FormatOverrideTooltip(control.effectId, duration, ttUnit)
                if formatted then
                    tooltipText = formatted
                end

                local containerContext = control.container
                if containerContext == "target1" or containerContext == "target2" or containerContext == "targetb" or containerContext == "targetd" or containerContext == "promb_target" or containerContext == "promd_target" then
                    if ov and ov.tooltipOther then
                        local otherFormatted = LUIE.FormatOverrideTooltip(control.effectId, duration, ttUnit,
                                                                          { tooltipString = ov.tooltipOther, skipHandler = true })
                        if otherFormatted then
                            tooltipText = otherFormatted
                        end
                    end
                end

                if LUIE.ResolveVeteranDifficulty() == true and ov and ov.tooltipVet then
                    local vetFormatted = LUIE.FormatOverrideTooltip(control.effectId, duration, ttUnit,
                                                                    { tooltipString = ov.tooltipVet, skipHandler = true })
                    if vetFormatted then
                        tooltipText = vetFormatted
                    end
                end

                if Effects.EffectGroundDisplay[control.effectId] and Effects.EffectGroundDisplay[control.effectId].tooltip and control.buffType == BUFF_EFFECT_TYPE_BUFF then
                    local groundFormatted = LUIE.FormatOverrideTooltip(control.effectId, duration, ttUnit,
                                                                       { tooltipString = Effects.EffectGroundDisplay[control.effectId].tooltip, skipHandler = true })
                    if groundFormatted then
                        tooltipText = groundFormatted
                    end
                end

                -- Display Default Tooltip Description if no custom tooltip is present
                if tooltipText == "" or tooltipText == nil then
                    if GetAbilityEffectDescription(control.buffSlot) ~= "" then
                        tooltipText = GetAbilityEffectDescription(control.buffSlot)
                    end
                end

                -- Display Default Description if no internal effect description is present
                if tooltipText == "" or tooltipText == nil then
                    if GetAbilityDescription(control.effectId, nil, ttUnit) ~= "" then
                        tooltipText = GetAbilityDescription(control.effectId, nil, ttUnit)
                    end
                end

                -- Dynamic tooltip when opted in, or when no custom override tooltip is configured
                if  not Effects.TooltipUseDefault[control.effectId]
                and not (ov and ov.tooltip and not ov.dynamicTooltip) then
                    local dynTip = LUIE.DynamicTooltip(control.effectId, ttUnit)
                    if dynTip then
                        tooltipText = dynTip
                    end
                end
            end
        end

        if Effects.TooltipUseDefault[control.effectId] then
            if GetAbilityEffectDescription(control.buffSlot) ~= "" then
                tooltipText = GetAbilityEffectDescription(control.buffSlot)
                tooltipText = LUIE.UpdateMundusTooltipSyntax(control.effectId, tooltipText)
            end
        end

        -- Set the Tooltip to be default if custom tooltips aren't enabled
        if not LUIE.SpellCastBuffs.SV.TooltipCustom then
            tooltipText = GetAbilityEffectDescription(control.buffSlot)
            if not tooltipText or tooltipText == "" then
                tooltipText = GetAbilityDescription(control.effectId, nil, ttUnit)
            end
            if tooltipText then
                tooltipText = StringOnlyGSUB(tooltipText, "\n$", "") -- Remove blank end line
            end
        end

        -- Default-tooltip path: re-apply TooltipHandlers / dynamicTooltip after plain description (matches custom path)
        if type(control.effectId) == "number" and not Effects.TooltipUseDefault[control.effectId] then
            local ov = Effects.EffectOverride[control.effectId]
            if not (ov and ov.tooltip and not ov.dynamicTooltip) then
                local dynTip = LUIE.DynamicTooltip(control.effectId, ttUnit)
                if dynTip then
                    tooltipText = dynTip
                end
            end
        end

        local thirdLine
        local duration = control.duration / 1000

        if Effects.EffectOverride[control.effectId] and Effects.EffectOverride[control.effectId].duration then
            duration = duration + Effects.EffectOverride[control.effectId].duration
        end

        -- if Effects.TooltipNameOverride[control.effectName] then
        --     thirdLine = zo_strformat(Effects.TooltipNameOverride[control.effectName], duration)
        -- end
        -- if Effects.TooltipNameOverride[control.effectId] then
        --     thirdLine = zo_strformat(Effects.TooltipNameOverride[control.effectId], duration)
        -- end

        -- Have to trim trailing spaces on the end of tooltips
        if tooltipText ~= "" then
            tooltipText = string.match(tooltipText, ".*%S")
        end
        if thirdLine ~= "" and thirdLine ~= nil then
            colorText = control.buffType == BUFF_EFFECT_TYPE_DEBUFF and ZO_ERROR_COLOR or ZO_SUCCEEDED_TEXT
        end

        detailsLine = 5

        InformationTooltip:AddLine(tooltipTitle, "ZoFontHeader2", 1, 1, 1, nil)
        if tooltipText ~= "" and tooltipText ~= nil then
            InformationTooltip:SetVerticalPadding(1)
            ZO_Tooltip_AddDivider(InformationTooltip)
            InformationTooltip:SetVerticalPadding(5)
            InformationTooltip:AddLine(tooltipText, "", colorText:UnpackRGBA())
        end
        if thirdLine ~= "" and thirdLine ~= nil then
            if tooltipText == "" or tooltipText == nil then
                InformationTooltip:SetVerticalPadding(1)
                ZO_Tooltip_AddDivider(InformationTooltip)
                InformationTooltip:SetVerticalPadding(5)
            end
            detailsLine = 7
            InformationTooltip:AddLine(thirdLine, "", ZO_NORMAL_TEXT:UnpackRGB())
        end

        SpellCastBuffs.TooltipBottomLine(control, detailsLine, false, ttUnit)

        -- Tooltip Debug
        -- InformationTooltip:SetAbilityId(117391)

        -- Debug show default Tooltip on my account
        -- if LUIE.PlayerDisplayName == "@ArtOfShred" or LUIE.PlayerDisplayName == "@ArtOfShredPTS" --[[or LUIE.PlayerDisplayName == '@dack_janiels']] then
        if SpellCastBuffs.devDebugEnabled then
            InformationTooltip:AddLine("Default Tooltip Below:", "", colorText:UnpackRGBA())

            local newtooltipText = GetAbilityEffectDescription(control.buffSlot)
            if not newtooltipText or newtooltipText == "" then
                newtooltipText = GetAbilityDescription(control.effectId, nil, ttUnit)
            end
            if newtooltipText and newtooltipText ~= "" then
                newtooltipText = StringOnlyGSUB(newtooltipText, "\n$", "")
            else
                newtooltipText = "(no default description)"
            end
            InformationTooltip:SetVerticalPadding(1)
            ZO_Tooltip_AddDivider(InformationTooltip)
            InformationTooltip:SetVerticalPadding(5)
            InformationTooltip:AddLine(newtooltipText, "", colorText:UnpackRGBA())
        end
    end
end

-- OnMouseExit for Buff Tooltips
function SpellCastBuffs.Buff_OnMouseExit(control)
    SpellCastBuffs.tooltipHoverState = nil
    if SpellCastBuffs.SV.TooltipSticky > 0 then
        eventManager:RegisterForUpdate(moduleName .. "StickyTooltip", SpellCastBuffs.SV.TooltipSticky, ClearStickyTooltip)
    else
        ClearTooltip(InformationTooltip)
        SpellCastBuffs.ClearDebugMetaOverflowTooltip()
        SpellCastBuffs.ClearDebugMetaTooltipLiveUpdate()
    end
end

-- Updates local variable with new font and resets all existing icons
--- @param buff SpellCastBuffs_BuffIcon_Control
function SpellCastBuffs.MarkAbilityIdLabelDirty(buff)
    buff.abilityIdLabelDirty = true
end

--- @param buff SpellCastBuffs_BuffIcon_Control
--- @return boolean
function SpellCastBuffs.NeedsAbilityIdLabelFit(buff)
    if buff.abilityIdLabelDirty then
        return true
    end
    local iconSize = SpellCastBuffs.SV.IconSize
    if buff.lastAppliedAbilityIdIconSize ~= iconSize then
        return true
    end
    if buff.lastAppliedAbilityIdLayoutVersion ~= SpellCastBuffs.displayLayoutVersion then
        return true
    end
    return false
end

--- Show Debug Ability ID: set text when needed; FitAbilityIdLabelFont only when text or layout changed.
--- @param buff SpellCastBuffs_BuffIcon_Control
--- @param idText string
function SpellCastBuffs.UpdateAbilityIdDebugLabel(buff, idText)
    if not buff.abilityId then
        return
    end
    if not SpellCastBuffs.SV.ShowDebugAbilityId or idText == "" then
        buff.abilityId:SetHidden(true)
        return
    end
    SpellCastBuffs.ApplyBuffIconAbilityIdLayout(buff)
    buff.abilityId:SetHidden(false)
    local textChanged = buff.lastAbilityIdText ~= idText or buff.abilityId:GetText() ~= idText
    if textChanged then
        buff.abilityId:SetText(idText)
        buff.lastAbilityIdText = idText
        SpellCastBuffs.MarkAbilityIdLabelDirty(buff)
    end
    SpellCastBuffs.FitAbilityIdLabelFont(buff)
end

--- Refit ability-id overlays after layout has dimensions (reloadui / first paint).
function SpellCastBuffs.RefreshAllAbilityIdDebugLabels()
    if not SpellCastBuffs.Enabled or not SpellCastBuffs.SV.ShowDebugAbilityId then
        return
    end
    for _, containerKey in pairs(SpellCastBuffs.containerRouting) do
        local container = SpellCastBuffs.BuffContainers[containerKey]
        if container and container.icons then
            for i = 1, #container.icons do
                local buff = container.icons[i]
                if buff and buff.abilityId and not buff:IsHidden() then
                    local idText = buff.lastAbilityIdText or buff.abilityId:GetText()
                    if idText and idText ~= "" then
                        buff.lastAbilityIdLayoutIconSize = nil
                        SpellCastBuffs.ApplyBuffIconAbilityIdLayout(buff)
                        buff.abilityId:SetHidden(false)
                        SpellCastBuffs.MarkAbilityIdLabelDirty(buff)
                        SpellCastBuffs.FitAbilityIdLabelFont(buff)
                    end
                end
            end
        end
    end
    local longContainer = SpellCastBuffs.BuffContainers.player_long
    if longContainer and longContainer.icons then
        for i = 1, #longContainer.icons do
            local buff = longContainer.icons[i]
            if buff and buff.abilityId and not buff:IsHidden() then
                local idText = buff.lastAbilityIdText or buff.abilityId:GetText()
                if idText and idText ~= "" then
                    buff.lastAbilityIdLayoutIconSize = nil
                    SpellCastBuffs.ApplyBuffIconAbilityIdLayout(buff)
                    buff.abilityId:SetHidden(false)
                    SpellCastBuffs.MarkAbilityIdLabelDirty(buff)
                    SpellCastBuffs.FitAbilityIdLabelFont(buff)
                end
            end
        end
    end
end

function SpellCastBuffs.ScheduleAbilityIdDebugLabelRefresh()
    zo_callLater(function ()
                     if SpellCastBuffs.Enabled then
                         SpellCastBuffs.RefreshAllAbilityIdDebugLabels()
                     end
                 end, 0)
end

--- Shrink ability-id debug text to fit the label width (GetStringWidth vs GetWidth; WasTruncated/GetTextWidth can lie under TRUNCATE).
--- LabelControl:Clean() forces layout before measuring pooled icons.
--- @param buff SpellCastBuffs_BuffIcon_Control
function SpellCastBuffs.FitAbilityIdLabelFont(buff)
    local label = buff.abilityId
    if not label or label:IsHidden() then
        return
    end
    local idText = label:GetText()
    if idText == "" then
        return
    end

    label:SetScale(1)
    label:Clean()

    local availableWidth = label:GetWidth()
    if not availableWidth or availableWidth <= 0 then
        SpellCastBuffs.MarkAbilityIdLabelDirty(buff)
        return
    end

    local function fitsInLabelWidth()
        local textWidthUI = GetAbilityIdStringWidthUI(label, idText)
        return textWidthUI > 0 and textWidthUI <= availableWidth * ABILITY_ID_LABEL_FIT_MARGIN
    end

    local fonts = SpellCastBuffs.abilityIdFonts
    if not fonts or #fonts == 0 then
        label:SetFont(SpellCastBuffs.buffsFont)
    else
        label:SetMaxLineCount(0)
        for _, font in ipairs(fonts) do
            label:SetFont(font)
            if fitsInLabelWidth() then
                break
            end
        end
        label:SetMaxLineCount(1)
    end

    local textWidthUI = GetAbilityIdStringWidthUI(label, idText)
    if textWidthUI > 0 and textWidthUI > availableWidth * ABILITY_ID_LABEL_FIT_MARGIN then
        label:SetScale(zo_min(1, (availableWidth * ABILITY_ID_LABEL_FIT_MARGIN) / textWidthUI))
        label:Clean()
    else
        label:SetScale(1)
    end

    local guard = 0
    while label:WasTruncated() and guard < 8 do
        label:SetScale(label:GetScale() * 0.88)
        label:Clean()
        guard = guard + 1
    end

    buff.abilityIdLabelDirty = nil
    buff.lastAppliedAbilityIdIconSize = SpellCastBuffs.SV.IconSize
    buff.lastAppliedAbilityIdLayoutVersion = SpellCastBuffs.displayLayoutVersion
end

function SpellCastBuffs.ApplyFont()
    if not SpellCastBuffs.Enabled then
        return
    end

    -- Font setup for standard Buffs & Debuffs
    local buffFontKey = SpellCastBuffs.SV.BuffFontFace
    local fontStyle = SpellCastBuffs.SV.BuffFontStyle
    local fontSize = (SpellCastBuffs.SV.BuffFontSize and SpellCastBuffs.SV.BuffFontSize > 0) and SpellCastBuffs.SV.BuffFontSize or 17
    SpellCastBuffs.buffsFont = LUIE.Font.Resolve(buffFontKey, fontSize, fontStyle)

    -- Ability-id labels shrink to fit by stepping through a size ladder. This only
    -- applies to custom slug faces; named fonts are a single fixed token (scaling in
    -- ApplyAbilityIdLabelFont handles overflow).
    SpellCastBuffs.abilityIdFonts = {}
    if LUIE.Font.IsDynamicFaceMedia(buffFontKey) then
        for size = fontSize, 3, -1 do
            SpellCastBuffs.abilityIdFonts[#SpellCastBuffs.abilityIdFonts + 1] = LUIE.Font.Resolve(buffFontKey, size, fontStyle)
        end
    else
        SpellCastBuffs.abilityIdFonts[1] = SpellCastBuffs.buffsFont
    end

    -- Font Setup for Prominent Buffs & Debuffs
    local prominentStyle = SpellCastBuffs.SV.ProminentLabelFontStyle
    local prominentSize = (SpellCastBuffs.SV.ProminentLabelFontSize and SpellCastBuffs.SV.ProminentLabelFontSize > 0) and SpellCastBuffs.SV.ProminentLabelFontSize or 17
    SpellCastBuffs.prominentFont = LUIE.Font.Resolve(SpellCastBuffs.SV.ProminentLabelFontFace, prominentSize, prominentStyle)

    local needs_reset = {}
    -- And reset sizes of already existing icons
    for _, container in pairs(SpellCastBuffs.containerRouting) do
        needs_reset[container] = true
    end
    for _, container in pairs(SpellCastBuffs.containerRouting) do
        if needs_reset[container] then
            for i = 1, #SpellCastBuffs.BuffContainers[container].icons do
                local icon = SpellCastBuffs.BuffContainers[container].icons[i]
                icon.label:SetFont(SpellCastBuffs.buffsFont)
                if icon.stack then
                    icon.stack:SetFont(SpellCastBuffs.buffsFont)
                end
                if icon.abilityId then
                    icon.lastAbilityIdLayoutIconSize = nil
                    SpellCastBuffs.ApplyBuffIconAbilityIdLayout(icon)
                    SpellCastBuffs.MarkAbilityIdLabelDirty(icon)
                    SpellCastBuffs.FitAbilityIdLabelFont(icon)
                end
                if icon.name then
                    icon.name:SetFont(SpellCastBuffs.prominentFont)
                end
            end
        end
        needs_reset[container] = false
    end

    SpellCastBuffs.MarkDisplayLayoutDirty()
end

-- Runs on the EVENT_ARTIFICIAL_EFFECT_ADDED / EVENT_ARTIFICIAL_EFFECT_REMOVED listener.
-- This handler fires whenever an ArtificialEffectId is added or removed
--- @param artificialEffectId integer
function SpellCastBuffs.ArtificialEffectUpdate(artificialEffectId)
    if SpellCastBuffs.SV.HidePlayerBuffs then
        return
    end

    if artificialEffectId and artificialEffectId ~= 1 and artificialEffectId ~= 3 then
        -- Battle Spirit ids 1/3 remap to 999014; managed after the iterator pass (avoid clearing on NOT_AN_EFFECT flicker).
        local context = "player1"
        SpellCastBuffs.EffectsList[context][artificialEffectId] = nil
    end

    local hasValidPlayerBattleSpiritArtificial = false

    for effectId in ZO_GetNextActiveArtificialEffectIdIter do
        -- Skip only this effect when its "show" setting is off; do not bail out of the loop.
        local skip = (effectId == 0 and SpellCastBuffs.SV.IgnoreEsoPlusPlayer) or
            ((effectId == 1 or effectId == 3) and SpellCastBuffs.SV.IgnoreBattleSpiritPlayer) or
            ((effectId == 1 or effectId == 3) and not LUIE.ShouldShowPlayerBattleSpirit())
        if skip then
            -- continue to next effect
        else
            local storeArtificialEffectId = effectId
            local displayName, iconFile, effectType, _, timeStartedS, timeEndingS = GetArtificialEffectInfo(effectId)
            if not LUIE.IsDisplayableArtificialEffectType(effectType) then
                -- continue (e.g. transient NOT_AN_EFFECT placeholder for artificial id 1)
            else
                local duration = 0

                -- ArtificialEffectId (live): 0 ESO Plus, 1 Battle Spirit, 2 LFG, 3 Battle Spirit Imperial City,
                -- 4 Battleground Deserter, 5 Underdog Damage, 6 Underdog Healing, 7 Solo Queue XP, 8 Solo Queue AP.
                if effectId == 4 then
                    duration = 300000
                    timeEndingS = timeStartedS + (GetLFGCooldownTimeRemainingSeconds(LFG_COOLDOWN_BATTLEGROUND_DESERTED_QUEUE) * 1000)
                    effectType = BUFF_EFFECT_TYPE_BUFF
                elseif effectId == 0 or effectId == 1 or effectId == 2 or effectId == 3 then
                    -- No timer for these (Underdog / Solo Queue ids 5–8 keep API start/end from GetArtificialEffectInfo).
                    duration = 0
                    timeEndingS = nil
                end

                local tooltip = nil
                local artificial = true
                if effectId == 0 then
                    tooltip = Tooltips.Innate_ESO_Plus
                elseif effectId == 1 then
                    tooltip = Tooltips.Innate_Battle_Spirit
                    effectId = 999014
                    artificial = false
                    hasValidPlayerBattleSpiritArtificial = true
                elseif effectId == 2 then
                    tooltip = Tooltips.Innate_Looking_for_Group
                elseif effectId == 3 then
                    tooltip = Tooltips.Innate_Battle_Spirit_Imperial_City
                    effectId = 999014
                    artificial = false
                    hasValidPlayerBattleSpiritArtificial = true
                elseif effectId == 4 then
                    tooltip = Tooltips.Innate_Battleground_Deserter
                elseif effectId == 5 then
                    tooltip = Tooltips.Innate_Underdog_Damage
                elseif effectId == 6 then
                    tooltip = Tooltips.Innate_Underdog_Healing
                elseif effectId == 7 then
                    tooltip = Tooltips.Innate_Solo_Queue_XP
                elseif effectId == 8 then
                    tooltip = Tooltips.Innate_Solo_Queue_AP
                end

                -- Route artificial effects (Battle Spirit, ESO Plus, BG Deserter, etc.) always to player context
                -- so they land in player_long when "Show Battle Spirit on Player" / LongTermEffects are enabled.
                -- If we used DetermineContextSimple, 999014 in PromBuffTable would promote to promb_player and
                -- the effect would show in prominent buffs instead of the long-term player container.
                local context = "player1"
                SpellCastBuffs.EffectsList[context][effectId] =
                {
                    uid = storeArtificialEffectId,
                    artificialEffectId = storeArtificialEffectId,
                    target = SpellCastBuffs.DetermineTarget(context),
                    type = effectType,
                    id = effectId,
                    name = displayName,
                    icon = iconFile,
                    tooltip = tooltip,
                    dur = duration,
                    starts = timeStartedS,
                    ends = timeEndingS,
                    forced = "long",
                    restart = true,
                    iconNum = 0,
                    artificial = artificial,
                }
            end
        end
    end

    local playerContext = "player1"
    if not LUIE.ShouldShowPlayerBattleSpirit() then
        SpellCastBuffs.EffectsList[playerContext][999014] = nil
    elseif hasValidPlayerBattleSpiritArtificial then
        -- Written in loop as 999014.
    elseif SpellCastBuffs.ShouldCreatePlayerBattleSpiritFallback() then
        SpellCastBuffs.CreatePlayerBattleSpiritListEntry(1, Tooltips.Innate_Battle_Spirit)
    else
        SpellCastBuffs.EffectsList[playerContext][999014] = nil
    end

    SpellCastBuffs.MarkDisplayDirty()
end

-- EVENT_BOSSES_CHANGED handler
function SpellCastBuffs.AddNameOnBossEngaged(eventCode)
    -- Clear any names we've added this way
    for k, _ in pairs(Effects.AddNameOnBossEngaged) do
        for name, _ in pairs(Effects.AddNameOnBossEngaged[k]) do
            if Effects.AddNameAura[name] then
                Effects.AddNameAura[name] = nil
            end
        end
    end

    -- Check for bosses and add name auras when engaged.
    for i = BOSS_RANK_ITERATION_BEGIN, BOSS_RANK_ITERATION_END do
        local unitTag = "boss" .. i
        local bossName = DoesUnitExist(unitTag) and zo_strformat("<<C:1>>", GetUnitName(unitTag)) or ""
        if Effects.AddNameOnBossEngaged[bossName] then
            for k, v in pairs(Effects.AddNameOnBossEngaged[bossName]) do
                Effects.AddNameAura[k] = {}
                Effects.AddNameAura[k][1] = {}
                Effects.AddNameAura[k][1].id = v
            end
        end
    end

    -- Reload Effects on current target
    if not SpellCastBuffs.SV.HideTargetBuffs then
        SpellCastBuffs.AddNameAura()
    end
end

-- Called from EVENT_PLAYER_ACTIVATED
function SpellCastBuffs.AddZoneBuffs()
    local zoneId = GetZoneId(GetCurrentMapZoneIndex())
    if Effects.ZoneBuffs[zoneId] then
        local abilityId = Effects.ZoneBuffs[zoneId]
        local abilityName = GetAbilityName(abilityId)
        local abilityIcon = GetAbilityIcon(abilityId)
        local beginTime = GetFrameTimeMilliseconds()
        local stack
        local groundLabel
        local toggle

        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList.player1[abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = abilityIcon,
            dur = 0,
            starts = beginTime,
            ends = nil,
            forced = "long",
            restart = true,
            iconNum = 0,
            unbreakable = 0,
            stack = stack,
            groundLabel = groundLabel,
            toggle = toggle,
        }
    end
end

-- Runs on the EVENT_UNIT_DEATH_STATE_CHANGED listener.
-- This handler fires every time a valid unitTag dies or is resurrected
function SpellCastBuffs.OnDeath(eventCode, unitTag, isDead)
    -- Wipe buffs
    if isDead then
        if unitTag == "player" then
            -- Clear all player/ground/prominent containers
            local context = { "player1", "player2", "ground", "promb_ground", "promd_ground", "promb_player", "promd_player" }
            for _, v in pairs(context) do
                SpellCastBuffs.EffectsList[v] = {}
            end

            -- If werewolf is active, reset the icon so it's not removed (otherwise it flashes off for about a second until the trailer function picks up on the fact that no power drain has occurred.
            if SpellCastBuffs.SV.ShowWerewolf and IsPlayerInWerewolfForm() then
                SpellCastBuffs.WerewolfState(nil, true, true)
            end
        else
            -- TODO: Do we need to clear prominent target containers here? (Don't think so)
            for effectType = BUFF_EFFECT_TYPE_BUFF, BUFF_EFFECT_TYPE_DEBUFF do
                SpellCastBuffs.EffectsList[unitTag .. effectType] = {}
            end
        end
    end
end

-- Runs on the EVENT_DISPOSITION_UPDATE listener.
-- This handler fires when the disposition of a reticleover unitTag changes. We filter for only this case.
function SpellCastBuffs.OnDispositionUpdate(eventCode, unitTag)
    if not SpellCastBuffs.SV.HideTargetBuffs then
        SpellCastBuffs.AddNameAura()
    end
end

-- Runs on the EVENT_TARGET_CHANGE listener.
-- This handler fires every time someone target changes.
-- This function is needed in case the player teleports via Way Shrine
function SpellCastBuffs.OnTargetChange(eventCode, unitTag)
    if unitTag ~= "player" then
        return
    end
    SpellCastBuffs.OnReticleTargetChanged(eventCode)
end

-- Runs on the EVENT_RETICLE_TARGET_CHANGED listener.
-- This handler fires every time the player's reticle target changes
function SpellCastBuffs.OnReticleTargetChanged(eventCode)
    SpellCastBuffs.ReloadEffects("reticleover")
end

-- Called by SpellCastBuffs.ReloadEffects - Displays recall cooldown
function SpellCastBuffs.ShowRecallCooldown()
    local recallRemain, _ = GetRecallCooldown()
    if recallRemain > 0 then
        local currentTimeMs = GetFrameTimeMilliseconds()
        local abilityId = 999016
        local abilityName = Abilities.Innate_Recall_Penalty
        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityName] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_RECALL_COOLDOWN_DDS,
            dur = 600000,
            starts = currentTimeMs,
            ends = currentTimeMs + recallRemain,
            forced = "long",
            restart = true,
            iconNum = 0,
            -- unbreakable=1 -- TODO: Maybe re-enable this? It makes prominent show as unbreakable blue since its a buff technically
        }
    end
end

-- Called by EVENT_RETICLE_TARGET_CHANGED listener - Saves active FAKE debuffs on enemies and moves them back and forth between the active container or hidden.
function SpellCastBuffs.RestoreSavedFakeEffects()
    -- Restore Ground Effects
    for _, effectsList in pairs({ SpellCastBuffs.EffectsList.ground, SpellCastBuffs.EffectsList.saved }) do
        -- local container = SpellCastBuffs.containerRouting[context]
        for k, v in pairs(effectsList) do
            if v.savedName ~= nil then
                local unitName = zo_strformat("<<C:1>>", GetUnitName("reticleover"))
                if unitName == v.savedName then
                    if SpellCastBuffs.EffectsList.saved[k] then
                        SpellCastBuffs.EffectsList.ground[k] = SpellCastBuffs.EffectsList.saved[k]
                        SpellCastBuffs.EffectsList.ground[k].iconNum = 0
                        SpellCastBuffs.EffectsList.saved[k] = nil
                    end
                else
                    if SpellCastBuffs.EffectsList.ground[k] then
                        SpellCastBuffs.EffectsList.saved[k] = SpellCastBuffs.EffectsList.ground[k]
                        SpellCastBuffs.EffectsList.ground[k] = nil
                    end
                end
            end
        end
    end
end

-- Called by EVENT_RETICLE_TARGET_CHANGED listener - Displays fake buffs based off unitName (primarily for displaying Boss Immunities)
function SpellCastBuffs.AddNameAura()
    local unitName = GetUnitName("reticleover")
    for _, contextKey in ipairs({ "reticleover1", "reticleover2", "promb_target", "promd_target" }) do
        local effectsList = SpellCastBuffs.EffectsList[contextKey]
        if effectsList then
            for listKey in pairs(effectsList) do
                if SpellCastBuffs.IsSyntheticEffectKey(listKey) and type(listKey) == "string" and listKey:sub(1, 5) == "name:" then
                    effectsList[listKey] = nil
                elseif type(listKey) == "string" and listKey:find("^Name Specific Buff", 1, true) then
                    effectsList[listKey] = nil
                end
            end
        end
    end
    -- We need to check to make sure the mob is not dead, and also check to make sure the unitTag is not the player (just in case someones name exactly matches that of a boss NPC)
    if Effects.AddNameAura[unitName] and GetUnitReaction("reticleover") == UNIT_REACTION_HOSTILE and not IsUnitPlayer("reticleover") and not IsUnitDead("reticleover") then
        for k, v in pairs(Effects.AddNameAura[unitName]) do
            local abilityName = GetAbilityName(v.id)
            local abilityIcon = GetAbilityIcon(v.id)

            -- Bail out if this ability is blacklisted
            if SpellCastBuffs.SV.BlacklistTable[v.id] or SpellCastBuffs.SV.BlacklistTable[abilityName] then
                return
            end

            local stack = v.stack or 0

            local zone = v.zone
            if zone then
                local flag = false
                for i, j in pairs(zone) do
                    if GetZoneId(GetCurrentMapZoneIndex()) == i then
                        flag = true
                    end
                end
                if not flag then
                    return
                end
            end

            local buffType = v.debuff or BUFF_EFFECT_TYPE_BUFF
            local context = v.debuff and "reticleover2" or "reticleover1"
            context = SpellCastBuffs.DetermineContext(context, v.id, abilityName)
            if SpellCastBuffs.UnitHasBuffAbilityId("reticleover", v.id) then
                SpellCastBuffs.RemoveSyntheticEffectsForAbilityId(context, v.id, nil)
            else
                local nameUid = SpellCastBuffs.GetEffectUidNameAura(unitName, v.id)
                SpellCastBuffs.EffectsList[context]["Name Specific Buff" .. k] = nil
                SpellCastBuffs.EffectsList[context][nameUid] =
                {
                    uid = nameUid,
                    target = SpellCastBuffs.DetermineTarget(context),
                    type = buffType,
                    id = v.id,
                    name = abilityName,
                    icon = abilityIcon,
                    dur = 0,
                    starts = 1,
                    ends = nil,
                    forced = "short",
                    restart = true,
                    iconNum = 0,
                    stack = stack,
                }
            end
        end
    end
end

-- Called by menu to preview icon positions. Simply iterates through all containers other than player_long and adds dummy test buffs into them.
function SpellCastBuffs.MenuPreview()
    local currentTimeMs = GetFrameTimeMilliseconds()
    local routing = { "player1", "reticleover1", "promb_player", "player2", "reticleover2", "promd_player" }
    local testEffectDurationList = { 22, 44, 55, 300, 1800000 }
    local abilityId = 999000
    local icon = "/esoui/art/icons/icon_missing.dds"

    for i = 1, 5 do
        for c = 1, 6 do
            local context = routing[c]
            local type = c < 4 and 1 or 2
            local name = ("Test Effect: " .. i)
            local duration = testEffectDurationList[i]
            SpellCastBuffs.EffectsList[context][abilityId] =
            {
                target = SpellCastBuffs.DetermineTarget(context),
                type = type,
                id = 16415,
                name = name,
                icon = icon,
                dur = duration * 1000,
                starts = currentTimeMs,
                ends = currentTimeMs + (duration * 1000),
                forced = "short",
                restart = true,
                iconNum = 0,
            }
            abilityId = abilityId + 1
        end
    end
end

-- Reused scratch table for ApplyDisplayAlpha / EnforceDisplayAlpha de-dupe.
-- Both functions ran a `local seen = {}` allocation per call; EnforceDisplayAlpha
-- runs every 100ms tick (see SpellCastBuffs.OnUpdate L490), so the empty-table
-- churn was real. We cleared between uses with ZO_ClearTable.
local g_displayAlphaSeen = {}

--- When true, Unit Frames PlayerOocAlpha / TargetOocAlpha drive container fade (not SpellCastBuffs oocAlpha).
--- @param containerKey string
--- @return boolean
function SpellCastBuffs.ShouldUnitFramesOwnContainerAlpha(containerKey)
    if not SpellCastBuffs.SV.lockPositionToUnitFrames then
        return false
    end
    return containerKey == "player1"
        or containerKey == "player2"
        or containerKey == "target1"
        or containerKey == "target2"
end

--- When SCB icons are locked to UF, buff/debuff region alpha is driven per icon (container stays at 1).
--- @type table<string, number>
SpellCastBuffs.lockedContainerAlphaByUnit =
{
    player = 1,
    target = 1,
}

--- @param unitKind "player"|"target"
--- @param alpha number
function SpellCastBuffs.SetLockedContainerAlphaForUnit(unitKind, alpha)
    SpellCastBuffs.lockedContainerAlphaByUnit[unitKind] = alpha
end

--- CooldownControl does not inherit parent alpha; multiply by buff container fade (UF OOC or SCB display alpha).
--- @param containerKey string
--- @return number
function SpellCastBuffs.GetBuffContainerAlphaMultiplier(containerKey)
    if SpellCastBuffs.ShouldUnitFramesOwnContainerAlpha(containerKey) then
        local unitFrames = LUIE.UnitFrames
        if unitFrames and unitFrames.GetSpellCastBuffsLockedContainerAlpha then
            local liveAlpha = unitFrames.GetSpellCastBuffsLockedContainerAlpha(containerKey)
            if liveAlpha then
                return liveAlpha
            end
        end
        if containerKey == "player1" or containerKey == "player2" then
            return SpellCastBuffs.lockedContainerAlphaByUnit.player or 1
        end
        if containerKey == "target1" or containerKey == "target2" then
            return SpellCastBuffs.lockedContainerAlphaByUnit.target or 1
        end
        return 1
    end
    local buffContainer = SpellCastBuffs.BuffContainers[containerKey]
    if buffContainer and buffContainer.GetAlpha then
        return buffContainer:GetAlpha()
    end
    return 1
end

--- Expire fade × container OOC/INC alpha (UF-owned or SpellCastBuffs display alpha on container).
--- @param containerKey string
--- @param fadeAlpha number
--- @return number
function SpellCastBuffs.GetBuffIconChainAlpha(containerKey, fadeAlpha)
    return fadeAlpha * SpellCastBuffs.GetBuffContainerAlphaMultiplier(containerKey)
end

local BUFF_ICON_COOLDOWN_BASE_ALPHA = 0.5

--- Reset explicit chrome alphas after pool release or slot rebind (avoid stale OOC overrides).
--- @param buff SpellCastBuffs_BuffIcon_Control
function SpellCastBuffs.ResetBuffIconChromeAlphas(buff)
    if buff.iconbg then
        buff.iconbg:SetAlpha(1)
    end
    if buff.back then
        buff.back:SetAlpha(1)
    end
    if buff.frame then
        buff.frame:SetAlpha(1)
    end
    if buff.drop then
        buff.drop:SetAlpha(1)
    end
    if buff.icon then
        buff.icon:SetAlpha(1)
    end
    if buff.cd then
        buff.cd:SetAlpha(BUFF_ICON_COOLDOWN_BASE_ALPHA)
    end
end

--- CooldownControl and overlay chrome do not inherit buff-root alpha; set leaf alphas with UF buff region at 1.
--- @param buff SpellCastBuffs_BuffIcon_Control
--- @param container string
--- @param fadeAlpha number
function SpellCastBuffs.ApplyBuffIconDisplayAlpha(buff, container, fadeAlpha)
    local unitFramesOwnAlpha = SpellCastBuffs.ShouldUnitFramesOwnContainerAlpha(container)
    local chainAlpha = SpellCastBuffs.GetBuffIconChainAlpha(container, fadeAlpha)
    local useFullAlpha = chainAlpha >= 0.999

    local function applyVisibleLeafAlpha(control)
        if not control then
            return
        end
        if control:IsHidden() then
            if useFullAlpha then
                control:SetAlpha(1)
            end
            return
        end
        if unitFramesOwnAlpha then
            control:SetAlpha(chainAlpha)
        elseif useFullAlpha then
            control:SetAlpha(1)
        end
    end

    if unitFramesOwnAlpha then
        buff:SetAlpha(1)
        applyVisibleLeafAlpha(buff.icon)
        applyVisibleLeafAlpha(buff.iconbg)
        applyVisibleLeafAlpha(buff.back)
        applyVisibleLeafAlpha(buff.frame)
        applyVisibleLeafAlpha(buff.drop)
    else
        buff:SetAlpha(fadeAlpha)
    end

    if buff.cd and container ~= "player_long" then
        if not buff.cd:IsHidden() then
            local cooldownAlpha = BUFF_ICON_COOLDOWN_BASE_ALPHA * chainAlpha
            buff.cd:SetAlpha(cooldownAlpha)
            if buff.cdFillA then
                buff.cd:SetFillColor(buff.cdFillR, buff.cdFillG, buff.cdFillB, buff.cdFillA * chainAlpha)
            end
        elseif useFullAlpha then
            buff.cd:SetAlpha(BUFF_ICON_COOLDOWN_BASE_ALPHA)
        end
    end
end

--- Set buff container opacity from in-combat / out-of-combat saved values (0–100).
function SpellCastBuffs.ApplyDisplayAlpha()
    if not SpellCastBuffs.Enabled then
        g_scbDisplayAlpha = nil
        return
    end

    local oocAlpha = SpellCastBuffs.SV.oocAlpha or 100
    local incAlpha = SpellCastBuffs.SV.incAlpha or 100
    local alpha = 0.01 * (IsUnitInCombat("player") and incAlpha or oocAlpha)
    g_scbDisplayAlpha = alpha

    ZO_ClearTable(g_displayAlphaSeen)
    for containerKey, control in pairs(SpellCastBuffs.BuffContainers) do
        if control and control.SetAlpha and not g_displayAlphaSeen[control] then
            g_displayAlphaSeen[control] = true
            if not SpellCastBuffs.ShouldUnitFramesOwnContainerAlpha(containerKey) then
                control:SetAlpha(alpha)
            end
        end
    end
end

--- Re-apply container alpha if ZO_HUDFadeSceneFragment or other UI reset it.
function SpellCastBuffs.EnforceDisplayAlpha()
    if not g_scbDisplayAlpha then
        return
    end

    local alpha = g_scbDisplayAlpha
    ZO_ClearTable(g_displayAlphaSeen)
    for containerKey, control in pairs(SpellCastBuffs.BuffContainers) do
        if control and control.SetAlpha and control.GetAlpha and not g_displayAlphaSeen[control] then
            g_displayAlphaSeen[control] = true
            if not SpellCastBuffs.ShouldUnitFramesOwnContainerAlpha(containerKey)
            and zo_abs(control:GetAlpha() - alpha) > 0.001 then
                control:SetAlpha(alpha)
            end
        end
    end
end

-- Runs on EVENT_PLAYER_ACTIVATED listener
function SpellCastBuffs.OnPlayerActivated(eventCode)
    SpellCastBuffs.playerActive = true
    SpellCastBuffs.playerResurrectStage = nil

    -- Reload Effects
    SpellCastBuffs.ReloadEffects("player")
    SpellCastBuffs.AddNameOnBossEngaged()

    -- Load Zone Specific Buffs
    if not SpellCastBuffs.SV.HidePlayerBuffs then
        SpellCastBuffs.AddZoneBuffs()
    end

    -- Resolve Duel Target
    SpellCastBuffs.DuelStart()

    -- Resolve Mounted icon
    if not SpellCastBuffs.SV.IgnoreMountPlayer and IsMounted() then
        zo_callLater(function ()
                         SpellCastBuffs.MountStatus(true)
                     end, 50)
    end

    -- Resolve Disguise Icon
    if not SpellCastBuffs.SV.IgnoreDisguise then
        zo_callLater(function ()
                         SpellCastBuffs.DisguiseItem(BAG_WORN, 10)
                     end, 50)
    end

    -- Resolve Assistant Icon
    if not SpellCastBuffs.SV.IgnorePet or not SpellCastBuffs.SV.IgnoreAssistant then
        zo_callLater(function ()
                         SpellCastBuffs.CollectibleBuff()
                     end, 50)
    end

    -- Resolve Werewolf
    if SpellCastBuffs.SV.ShowWerewolf and IsPlayerInWerewolfForm() then
        SpellCastBuffs.WerewolfState(nil, true, true)
    end

    -- Sets the player to dead if reloading UI or loading in while dead.
    if IsUnitDead("player") then
        SpellCastBuffs.playerDead = true
    end

    SpellCastBuffs.ApplyDisplayAlpha()
    SpellCastBuffs.MarkDisplayDirty()
end

-- Runs on the EVENT_PLAYER_DEACTIVATED listener
function SpellCastBuffs.OnPlayerDeactivated(eventCode)
    SpellCastBuffs.playerActive = false
    SpellCastBuffs.playerResurrectStage = nil
end

-- Runs on the EVENT_PLAYER_ALIVE listener
function SpellCastBuffs.OnPlayerAlive(eventCode)
    --[[-- If player clicks "Resurrect at Wayshrine", then player is first deactivated, then he is transferred to new position, then he becomes alive (this event) then player is activated again.
    To register resurrection we need to work in this function if player is already active. --]]
    --
    if not SpellCastBuffs.playerActive or not SpellCastBuffs.playerDead then
        return
    end

    SpellCastBuffs.playerDead = false

    -- This is a good place to reload player buffs, as they were wiped on death
    SpellCastBuffs.ReloadEffects("player")

    -- Start Resurrection Sequence
    SpellCastBuffs.playerResurrectStage = 1
    --[[If it was self resurrection, then there will be 4 EVENT_VIBRATION:
    First - 600ms, Second - 0ms to switch first one off, Third - 350ms, Fourth - 0ms to switch third one off.
    So now we'll listen in the vibration event and progress SpellCastBuffs.playerResurrectStage with first 2 events and then on correct third event we'll create a buff. --]]
end

-- Runs on the EVENT_PLAYER_DEAD listener
function SpellCastBuffs.OnPlayerDead(eventCode)
    if not SpellCastBuffs.playerActive then
        return
    end
    SpellCastBuffs.playerDead = true
end

-- Runs on the EVENT_VIBRATION listener (detects player resurrection stage)
function SpellCastBuffs.OnVibration(eventCode, duration, coarseMotor, fineMotor, leftTriggerMotor, rightTriggerMotor)
    if not SpellCastBuffs.playerResurrectStage then
        return
    end
    if SpellCastBuffs.SV.HidePlayerBuffs then
        return
    end
    if SpellCastBuffs.playerResurrectStage == 1 and duration == 600 then
        SpellCastBuffs.playerResurrectStage = 2
    elseif SpellCastBuffs.playerResurrectStage == 2 and duration == 0 then
        SpellCastBuffs.playerResurrectStage = 3
    elseif SpellCastBuffs.playerResurrectStage == 3 and duration == 350 and SpellCastBuffs.SV.ShowResurrectionImmunity then
        -- We got correct sequence, so let us create a buff and reset the SpellCastBuffs.playerResurrectStage
        SpellCastBuffs.playerResurrectStage = nil
        local currentTimeMs = GetFrameTimeMilliseconds()
        local abilityId = 14646
        local abilityName = Abilities.Innate_Resurrection_Immunity
        local context = SpellCastBuffs.DetermineContextSimple("player1", abilityId, abilityName)
        SpellCastBuffs.EffectsList[context][abilityId] =
        {
            target = SpellCastBuffs.DetermineTarget(context),
            type = 1,
            id = abilityId,
            name = abilityName,
            icon = LUIE_MEDIA_ICONS_ABILITIES_ABILITY_INNATE_RESURRECTION_IMMUNITY_DDS,
            dur = 10000,
            starts = currentTimeMs,
            ends = currentTimeMs + 10000,
            restart = true,
            iconNum = 0,
        }
    else
        -- This event does not seem to have anything to do with player self-resurrection
        SpellCastBuffs.playerResurrectStage = nil
    end
end
